#include 'function.ch'
#include 'chip_mo.ch'

#define FILE_HASH   'files.hst'   // имя файла для хэшев файлов
#define NUMBER_YEAR 3 // число лет для переиндексации назад

***** 19.02.22 инициализация массива МО, запрос кода МО (при необходимости)
Function init_mo()
  Local fl := .t., i, arr, arr1, cCode := '', buf := save_maxrow(), ;
        nfile := exe_dir+'_mo_mo.dbb'

  mywait()
  Public oper_parol := 30  // пароль для фискального регистратора
  Public oper_frparol := 30 // пароль для фискального регистратора ОТЧЕТ
  Public oper_fr_inn  := '' // ИНН кассира
  Public glob_arr_mo := {}, glob_mo, glob_podr := '', glob_podr_2 := ''
  Public is_adres_podr := .f., glob_adres_podr := {;
    {'103001',{{'103001',1,'г.Волгоград, ул.Землячки, д.78'},;
               {'103099',2,'г.Михайловка, ул.Мичурина, д.8'},;
               {'103099',3,'г.Волжский, ул.Комсомольская, д.25'},;
               {'103099',4,'г.Волжский, ул.Оломоуцкая, д.33'},;
               {'103099',5,'г.Камышин, ул.Днепровская, д.43'},;
               {'103099',6,'г.Камышин, ул.Мира, д.51'},;
               {'103099',7,'г.Урюпинск, ул.Фридек-Мистек, д.8'}};
    },;
    {'101003',{{'101003',1,'г.Волгоград, ул.Циолковского, д.1'},;
               {'101099',2,'г.Волгоград, ул.Советская, д.47'}};
    },;
    {'131001',{{'131001',1,'г.Волгоград, ул.Кирова, д.10'},;
               {'131099',2,'г.Волгоград, ул.Саши Чекалина, д.7'},;
               {'131099',3,'г.Волгоград, ул.им.Федотова, д.18'}};
    },;
    {'171004',{{'171004',1,'г.Волгоград, ул.Ополченская, д.40'},;
               {'171099',2,'г.Волгоград, ул.Тракторостроителей, д.13'}};
    };
  }

  create_mo_add()
  glob_arr_mo := getMo_mo_New('_mo_mo')

  if hb_FileExists(dir_server + 'organiz' +sdbf)
    R_Use(dir_server + 'organiz',,'ORG')
    if lastrec() > 0
      cCode := left(org->kod_tfoms,6)
    endif
  endif
  close databases
  if !empty(cCode)
    if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode})) > 0
      glob_mo := glob_arr_mo[i]
      if (i := ascan(glob_adres_podr, {|x| x[1] == glob_mo[_MO_KOD_TFOMS] })) > 0
        is_adres_podr := .t. ; glob_podr_2 := glob_adres_podr[i,2,2,1] // второй код для удалённого адреса
      endif
    else
      func_error(4,'В справочник занесён несуществующий код МО "' + cCode + '". Введите его заново.')
      cCode := ''
    endif
  endif
  if empty(cCode)
    if (cCode := input_value(18,2,20,77,color1,;
                              'Введите код МО или обособленного подразделения, присвоенный ТФОМС',;
                              space(6),'999999')) != NIL .and. !empty(cCode)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode})) > 0
        glob_mo := glob_arr_mo[i]
        if hb_FileExists(dir_server + 'organiz' + sdbf)
          G_Use(dir_server + 'organiz',,'ORG')
          if lastrec() == 0
            AddRecN()
          else
            G_RLock(forever)
          endif
          org->kod_tfoms := glob_mo[_MO_KOD_TFOMS]
          org->name_tfoms := glob_mo[_MO_SHORT_NAME]
          org->uroven := get_uroven()
        endif
        close databases
      else
        fl := func_error('Работа невозможна - введённый код МО "' + cCode + '" неверен.')
      endif
    endif
  endif
  if empty(cCode)
    fl := func_error('Работа невозможна - не введён код МО.')
  endif

  rest_box(buf)

  if ! fl
    hard_err('delete')
    QUIT
  endif

  return main_up_screen()

** 29.12.22 проверка и переиндексирование справочников ТФОМС
Function checkFilesTFOMS()
  Local fl := .t., i, arr, buf := save_maxrow()
  local arrRefFFOMS := {}, row, row_flag := .t.
  local lSchema := .f.
  local countYear
  local hash_files
  local file_index, sMD5, sbase

  public is_otd_dep := .f., glob_otd_dep := 0, mm_otd_dep := {}

  Public arr_12_VMP := {}
  Public is_napr_pol := .f.,; // работа с направлениями на госпитализацию в п-ке
         is_napr_stac := .f.,;  // работа с направлениями на госпитализацию в стационаре
         glob_klin_diagn := {} // работа со специальными лабораторными исследованиями
  Public is_ksg_VMP := .f., is_12_VMP := .f., is_14_VMP := .f., is_ds_VMP := .f.
  Public is_21_VMP := .f.     // ВМП для 21 года
  Public is_22_VMP := .f.     // ВМП для 22 года
  Public is_23_VMP := .f.     // ВМП для 23 года
  
  // справочник цен на услуги ТФОМС 2016-2017
  Public glob_MU_dializ := {}//'A18.05.002.001','A18.05.002.002','A18.05.002.003',;
                            //'A18.05.003','A18.05.003.001','A18.05.011','A18.30.001','A18.30.001.001'}
  Public glob_KSG_dializ := {}//'10000901','10000902','10000903','10000905','10000906','10000907','10000913',;
                             //'20000912','20000916','20000917','20000918','20000919','20000920'}
                             //'1000901','1000902','1000903','1000905','1000906','1000907','1000913',;
                             //'2000912','2000916','2000917','2000918','2000919','2000920'}
  
  Public is_vr_pr_pp := .f., is_hemodializ := .f., is_per_dializ := .f., is_reabil_slux := .f.,;
         is_ksg_1300098 := .f., is_dop_ob_em := .f., glob_yes_kdp2[10], glob_menu_mz_rf := {.f.,.f.,.f.}

  Public is_alldializ := .f.

  afill(glob_yes_kdp2,.f.)

  mywait('Подождите, идет проверка служебных данных в рабочем каталоге...')

  // hash_files := read_files_md5(cur_dir + FILE_HASH)

  // справочник диагнозов
  sbase := '_mo_mkb'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on shifr+str(ks,1) to (cur_dir+sbase)
      close databases
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // услуги <-> специальности
  sbase := '_mo_spec'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on shifr+str(vzros_reb,1)+str(prvs_new,6) to (cur_dir+sbase)
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // услуги <-> профили
  sbase := '_mo_prof'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on shifr+str(vzros_reb,1)+str(profil,3) to (cur_dir+sbase)
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  for countYear = WORK_YEAR - 4 to WORK_YEAR
    fl := vmp_usl_check(countYear, @hash_files)
    fl := dep_index_and_fill(countYear, @hash_files)  // справочник отделений на countYear год
    fl := usl_Index(countYear, @hash_files)    // справочник услуг ТФОМС на countYear год
    fl := uslc_Index(countYear, @hash_files)   // цены на услуги на countYear год
    fl := uslf_Index(countYear, @hash_files)   // справочник услуг ФФОМС countYear
    fl := unit_Index(countYear, @hash_files)   // план-заказ
    fl := shema_index(countYear, @hash_files)
    // fl := it_Index(countYear, @hash_files)
    fl := k006_index(countYear, @hash_files)
  next

  Public is_MO_VMP := (is_ksg_VMP .or. is_12_VMP .or. is_14_VMP .or. is_ds_VMP .or. is_21_VMP .or. is_22_VMP .or. is_23_VMP)
  // справочник доплат по законченным случаям (старый справочник)
  /*sbase := '_mo_usld'
  if hb_FileExists(exe_dir + sbase + sdbf)
    if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx)
      R_Use(exe_dir + sbase )
      index on shifr+dtos(datebeg) to (cur_dir+sbase)
      use
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif*/
  // справочник 'услуги по законченным случаям + диагнозы'
  /*sbase := '_mo_uslz'
  if hb_FileExists(exe_dir + sbase + sdbf)
    if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx)
      R_Use(exe_dir + sbase )
      index on shifr+str(type_diag,1)+kod_diag to (cur_dir+sbase)
      use
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif*/


  Public arr_t007 := {}
  sbase := '_mo_t007'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
        ! hb_FileExists(cur_dir + sbase + '2' + sntx) .or. ;
        ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase ,,'T7')
      index on upper(left(NAME,50))+str(profil_k,3) to (cur_dir+sbase) UNIQUE
      dbeval({|| aadd(arr_t007, {alltrim(t7->name),profil_k,pk_V020}) })
      index on str(profil_k,3)+str(profil,3) to (cur_dir+sbase)
      index on str(pk_V020,3)+str(profil,3) to (cur_dir+sbase+'2')
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // справочник страховых компаний РФ
  sbase := '_mo_smo'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    Public glob_array_srf := {}
    if ! hb_FileExists(file_index) .or. ;
          ! hb_FileExists(cur_dir + sbase + '2' + sntx) .or. ;
          ! hb_FileExists(cur_dir + sbase + '3' + sntx) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on okato to (cur_dir+sbase) UNIQUE
      dbeval({|| aadd(glob_array_srf,{'',field->okato}) })
      index on okato+smo to (cur_dir+sbase)
      index on smo to (cur_dir+sbase+'2')
      index on okato+ogrn to (cur_dir+sbase+'3')
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // impl - справочник имплантантов
  sbase := '_mo_impl'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on str(ID, 4) to (cur_dir + sbase)
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // onkko_vmp
  sbase := '_mo_ovmp'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on str(metod,3) to (cur_dir+sbase)
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N002
  sbase := '_mo_N002'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! hb_FileExists(cur_dir + sbase + 'd' + sntx) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on str(id_st,6) to (cur_dir+sbase)
      index on ds_st+kod_st to (cur_dir+sbase+'d')
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N003
  sbase := '_mo_N003'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! hb_FileExists(cur_dir + sbase + 'd' + sntx) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on str(id_t,6) to (cur_dir+sbase)
      index on ds_t+kod_t to (cur_dir+sbase+'d')
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N004
  sbase := '_mo_N004'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! hb_FileExists(cur_dir + sbase + 'd' + sntx) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on str(id_n,6) to (cur_dir+sbase)
      index on ds_n+kod_n to (cur_dir+sbase+'d')
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N005
  sbase := '_mo_N005'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! hb_FileExists(cur_dir + sbase + 'd' + sntx) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on str(id_m,6) to (cur_dir+sbase)
      index on ds_m+kod_m to (cur_dir+sbase+'d')
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N006 - в 2019 году пустой
  sbase := '_mo_N006'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on ds_gr+str(id_t,6)+str(id_n,6)+str(id_m,6) to (cur_dir+sbase)
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N007
  sbase := '_mo_N007'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on str(id_mrf,6) to (cur_dir+sbase)
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N008
  sbase := '_mo_N008'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on str(id_mrf,6) to (cur_dir+sbase)
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N010
  sbase := '_mo_N010'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on str(id_igh,6) to (cur_dir+sbase)
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N011
  sbase := '_mo_N011'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on str(id_igh,6) to (cur_dir+sbase)
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N020
  sbase := '_mo_N020'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! hb_FileExists(cur_dir + sbase + 'n' + sntx) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on id_lekp to (cur_dir+sbase)
      index on upper(mnn) to (cur_dir+sbase+'n')
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N021
  sbase := '_mo_N021'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on code_sh+id_lekp to (cur_dir+sbase)
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // справочник подразделений из паспорта ЛПУ
  sbase := '_mo_podr'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on codemo+padr(upper(kodotd),25) to (cur_dir+sbase)
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // справочник соответствия профиля мед.помощи с профилем койки
  sbase := '_mo_prprk'
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on str(profil,3)+str(profil_k,3) to (cur_dir+sbase)
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  
  // aadd(arrRefFFOMS, {'_mo_f006', .t., 'F006 - Классификатор видов контроля (VidExp)' } )
  // aadd(arrRefFFOMS, {'_mo_f010', .f., 'F010 - Классификатор субъектов Российской Федерации (Subekti)' } )
  // aadd(arrRefFFOMS, {'_mo_f011', .f., 'F011 - Классификатор типов документов, удостоверяющих личность (Tipdoc)' } )
  // aadd(arrRefFFOMS, {'_mo_o001', .f., 'O001 - Общероссийский классификатор стран мира (ОКСМ)' } )
  // aadd(arrRefFFOMS, {'_mo_q015', .t., 'Q015 - Перечень технологических правил реализации ФЛК в ИС ведения персонифицированного учета сведений об оказанной медицинской помощи (FLK_MPF)' } )
  // aadd(arrRefFFOMS, {'_mo_q016', .t., 'Q016 - Перечень технологических правил реализации ФЛК в ИС ведения персонифицированного учета сведений об оказанной медицинской помощи (FLK_MPF)' } )
  // aadd(arrRefFFOMS, {'_mo_q017', .t., 'Q017 - Перечень категорий проверок ФЛК и МЭК (TEST_K)' } )
  aadd(arrRefFFOMS, {'_mo_v002', .f., 'V002 - Классификатор профилей оказанной медицинской помощи (Rezult)' } )
  aadd(arrRefFFOMS, {'_mo_v009', .f., 'V009 - Классификатор результатов обращения за медицинской помощью' } )
  aadd(arrRefFFOMS, {'_mo_v010', .f., 'V010 - Классификатор способов оплаты медицинской помощи (Sposob)' } )
  aadd(arrRefFFOMS, {'_mo_v012', .f., 'V012 - Классификатор исходов заболевания (Ishod)' } )
  aadd(arrRefFFOMS, {'_mo_v015', .f., 'V015 - Классификатор медицинских специальностей (Medspec)' } )
  aadd(arrRefFFOMS, {'_mo_v016', .f., 'V016 - Классификатор типов диспансеризации (DispT)' } )
  aadd(arrRefFFOMS, {'_mo_v018', .f., 'V018 - Классификатор видов высокотехнологичной медицинской помощи (HVid)' } )
  aadd(arrRefFFOMS, {'_mo_v019', .t., 'V019 - Классификатор методов высокотехнологичной медицинской помощи (HMet)' } )
  aadd(arrRefFFOMS, {'_mo_v020', .f., 'V020 - Классификатор профилей койки' } )
  aadd(arrRefFFOMS, {'_mo_v021', .f., 'V021 - Классификатор медицинских специальностей (должностей) (MedSpec)' } )
  aadd(arrRefFFOMS, {'_mo_v022', .t., 'V022 - Классификатор моделей пациента при оказании высокотехнологичной медицинской помощи (ModPac)' } )
  aadd(arrRefFFOMS, {'_mo_v025', .f., 'V025 - Классификатор целей посещения (KPC)' } )
  aadd(arrRefFFOMS, {'_mo_v030', .t., 'V030 - Схемы лечения заболевания COVID-19 (TreatReg)' } )
  aadd(arrRefFFOMS, {'_mo_v031', .f., 'V031 - Группы препаратов для лечения заболевания COVID-19 (GroupDrugs)' } )
  aadd(arrRefFFOMS, {'_mo_v032', .f., 'V032 - Сочетание схемы лечения и группы препаратов (CombTreat)' } )
  aadd(arrRefFFOMS, {'_mo_v033', .f., 'V033 - Соответствие кода препарата схеме лечения (DgTreatReg)' } )
  aadd(arrRefFFOMS, {'_mo_v036', .f., 'V036 - Перечень услуг, требующих имплантацию медицинских изделий (ServImplDv)' } )
  aadd(arrRefFFOMS, {'_mo_method_inj', .f., 'OID 1.2.643.5.1.13.13.11.1468 - Методы введения лекарственных препаратов' } )
  aadd(arrRefFFOMS, {'_mo_v036', .f., 'V036 - Перечень услуг, требующих имплантацию медицинских изделий (ServImplDv)' } )
  aadd(arrRefFFOMS, {'_mo_impl', .f., '_mo_impl - Перечень допустимых имплантантов' } )
  aadd(arrRefFFOMS, {'_mo_t005', .t., 'T005 - Справочник ошибок при проведении технологического контроля Реестров сведений и Реестров счетов' } )
  // aadd(arrRefFFOMS, {'_mo_v034', .f., 'V034 - Единицы измерения (UnitMeas)' } )
  // aadd(arrRefFFOMS, {'_mo_v035', .f., 'V035 - Способы введения (MethIntro)' } )
  // aadd(arrRefFFOMS, {'_mo_v037', .f., 'V037 - Перечень методов ВМП, требующих имплантацию медицинских изделий' } )

  for each row in arrRefFFOMS
    sbase := row[1]
    if ! hb_FileExists(exe_dir + sbase + sdbf)
      row_flag := .f.
      notExistsFileNSI( exe_dir + sbase + sdbf )
    endif
    if row[2]
      if ! hb_FileExists(exe_dir + sbase + sdbt)
        row_flag := .f.
        notExistsFileNSI( exe_dir + sbase + sdbt )
      endif
    endif
  next
  fl := row_flag
  if fl
    // справочник ошибок
    sbase := '_mo_t005'
    file_index := cur_dir + sbase + sntx
    sMD5 := ''
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      R_Use(exe_dir + sbase )
      index on str(kod,3) to (cur_dir+sbase)
      use
    endif
    hash_files := add_hash_row(hash_files, sbase, sMD5)
  endif

  // справочник ОКАТО
  if fl
    okato_index(hash_files)
    //
    dbcreate(cur_dir+'tmp_srf',{{'okato','C',5,0},{'name','C',80,0}})
    use (cur_dir+'tmp_srf') new alias TMP
    R_Use(dir_exe+'_okator',cur_dir+'_okatr','RE')
    R_Use(dir_exe+'_okatoo',cur_dir+'_okato','OB')
    for i := 1 to len(glob_array_srf)
      select OB
      find (glob_array_srf[i,2])
      if found()
        glob_array_srf[i,1] := rtrim(ob->name)
      else
        select RE
        find (left(glob_array_srf[i,2],2))
        if found()
          glob_array_srf[i,1] := rtrim(re->name)
        elseif left(glob_array_srf[i,2],2) == '55'
          glob_array_srf[i,1] := 'г.Байконур'
        endif
      endif
      select TMP
      append blank
      tmp->okato := glob_array_srf[i,2]
      tmp->name  := iif(substr(glob_array_srf[i,2],3,1)=='0','','  ')+glob_array_srf[i,1]
    next
    close databases
  else
    hard_err('delete')
    QUIT
  endif
  save_files_md5(hash_files, cur_dir + FILE_HASH)
  rest_box(buf)

  return nil

**** 24.02.22
function vmp_usl_check(val_year, /*@*/hash_files)  // справочник соответствия услуг ВМП услугам ТФОМС на countYear год
  local fl := .t.
  local sbase := prefixFileRefName(val_year) + 'vmp_usl'  // справочник соответствия услуг ВМП услугам ТФОМС
    
  if val_year >= 2021
    if ! hb_FileExists(exe_dir + sbase + sdbf)
      fl := notExistsFileNSI( exe_dir + sbase + sdbf )
    endif
  endif
  return fl

**** 26.02.22
function dep_index_and_fill(val_year, /*@*/hash_files)
  local fl := .t.
  local sbase
  local file_index, sMD5
  
  // is_otd_dep, glob_otd_dep, mm_otd_dep - объявлены ранее как Public
  sbase := prefixFileRefName(val_year) + 'dep'  // справочник отделений на конкретный год
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    R_Use(exe_dir + sbase, , 'DEP')
    if ! hb_FileExists(file_index) .or. ;
          ! check_izm_file_MD5(hash_files, sbase, sMD5)
      index on str(code, 3) to (cur_dir + sbase) for codem == glob_mo[_MO_KOD_TFOMS]
      hash_files := add_hash_row(hash_files, sbase, sMD5)
    else
      set index to (file_index)
    endif
    if val_year == WORK_YEAR
      dbeval({|| aadd(mm_otd_dep, {alltrim(dep->name_short) + ' (' + alltrim(dep->name) + ')', dep->code, dep->place}) })
      if (is_otd_dep := (len(mm_otd_dep) > 0))
        asort(mm_otd_dep, , , {|x, y| x[1] < y[1]})
      endif
    endif
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  if is_otd_dep
    sbase := prefixFileRefName(val_year) + 'deppr' // справочник отделения + профили  на конкретный год
    file_index := cur_dir + sbase + sntx
    sMD5 := ''
    if hb_FileExists(exe_dir + sbase + sdbf)
      sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
      if ! hb_FileExists(file_index) .or. ;
            ! check_izm_file_MD5(hash_files, sbase, sMD5)
        R_Use(exe_dir + sbase, , 'DEP')
        index on str(code, 3) + str(pr_mp, 3) to (cur_dir + sbase) for codem == glob_mo[_MO_KOD_TFOMS]
        use
      endif
      hash_files := add_hash_row(hash_files, sbase, sMD5)
    else
      fl := notExistsFileNSI( exe_dir + sbase + sdbf )
    endif
  endif
  return fl

**** 26.02.22
function usl_Index(val_year, /*@*/hash_files)
  local fl := .t.
  local sbase
  local file_index, sMD5

  sbase := prefixFileRefName(val_year) + 'usl'  // справочник услуг ТФОМС на конкретный год
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    R_Use(exe_dir + sbase, ,'LUSL')
    if (year(sys_date) - val_year) < NUMBER_YEAR .or. files_time(exe_dir + sbase + sdbf, cur_dir + sbase + sntx)
      if ! hb_FileExists(file_index) .or. ;
            ! check_izm_file_MD5(hash_files, sbase, sMD5)
        index on shifr to (cur_dir + sbase)
        hash_files := add_hash_row(hash_files, sbase, sMD5)
      else
        set index to (file_index)
      endif
      // сбор данных для ВМП
      if val_year = WORK_YEAR
        find ('1.21.') // ВМП федеральное   // 10.02.22 замена услуг с 1.20 на 1.21 письмо 12-20-60 от 01.02.22
        // find ('1.20.') // ВМП федеральное   // 07.02.21 замена услуг с 1.12 на 1.20 письмо 12-20-60 от 01.02.21
        // do while left(lusl->shifr,5) == '1.20.' .and. !eof()
        do while left(lusl->shifr,5) == '1.21.' .and. !eof()
          aadd(arr_12_VMP,int(val(substr(lusl->shifr,6))))
          skip
        enddo
      endif
    endif
    close databases
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  return fl
  
**** 28.02.22
function uslc_Index(val_year, /*@*/hash_files)
  local fl := .t.
  local sbase, prefix := prefixFileRefName(val_year)
  local index_usl_name
  local file_index, sMD5
  
  sbase :=  prefix + 'uslc'  // цены на услуги на конкретный год
  index_usl_name :=  prefix + 'uslu'  // 
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf) .and. valtype(glob_mo) == 'A'
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    R_Use(exe_dir + sbase, , 'LUSLC')
  
    if (year(sys_date) - val_year) < NUMBER_YEAR .or. ;
          files_time(exe_dir + sbase + sdbf, cur_dir + sbase + sntx) .or. ;
          files_time(exe_dir + sbase + sdbf, cur_dir + index_usl_name + sntx)
      if ! hb_FileExists(file_index) .or. ;
            ! hb_FileExists(cur_dir + index_usl_name + sntx) .or. ;
            ! check_izm_file_MD5(hash_files, sbase, sMD5)
        index on shifr + str(vzros_reb, 1) + str(depart, 3) + dtos(datebeg) to (cur_dir + sbase) ;
              for codemo == glob_mo[_MO_KOD_TFOMS]
        index on codemo + shifr + str(vzros_reb, 1) + str(depart, 3) + dtos(datebeg) to (cur_dir + index_usl_name) ;
              for codemo == glob_mo[_MO_KOD_TFOMS] // для совместимости со старой версией справочника
        hash_files := add_hash_row(hash_files, sbase, sMD5)
      else
        set index to (file_index)
        set index to (cur_dir + index_usl_name)
      endif
    endif
  
    if val_year > 2020 // 2019 // 2018
      // Медицинская реабилитация детей с нарушениями слуха без замены речевого процессора системы кохлеарной имплантации
      find (glob_mo[_MO_KOD_TFOMS] + 'st37.015')
      if found()
        is_reabil_slux := found()
      endif
  
  //
      find (glob_mo[_MO_KOD_TFOMS] + '2.') // врачебные приёмы
      do while codemo == glob_mo[_MO_KOD_TFOMS] .and. left(shifr, 2) == '2.' .and. !eof()
        if left(shifr, 5) == '2.82.'
          is_vr_pr_pp := .t. // врачебный прием в приёмном отделении стационара
          if is_napr_pol
            exit
          endif
        else
          is_napr_pol := .t.
          if is_vr_pr_pp
            exit
          endif
        endif
        skip
      enddo
    
    //
      find (glob_mo[_MO_KOD_TFOMS] + '60.3.')
      if found()
        is_alldializ := .t.
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + '60.3.1')
      if found()
        is_per_dializ := .t.
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + '60.3.9')
      if found()
        is_hemodializ := .t.
      else
        find (glob_mo[_MO_KOD_TFOMS] + '60.3.10')
        if found()
          is_hemodializ := .t.
        endif
      endif
  
    //
      find (glob_mo[_MO_KOD_TFOMS] + 'st') // койко-дни
      if (is_napr_stac := found())
        glob_menu_mz_rf[1] := .t.
      endif
    //
      if val_year == WORK_YEAR
        find (glob_mo[_MO_KOD_TFOMS] + '1.21.') // ВМП исправить
        is_23_VMP := found()
      elseif val_year == 2022
        find (glob_mo[_MO_KOD_TFOMS] + '1.21.') // ВМП 11.02.22
        is_22_VMP := found()
      elseif val_year == 2021
        find (glob_mo[_MO_KOD_TFOMS] + '1.20.') // ВМП 07.02.21
        is_21_VMP := found()
      elseif val_year == 2020 .or. val_year == 2019
        find (glob_mo[_MO_KOD_TFOMS] + '1.12.') // ВМП 2020 и 2019 года
        is_12_VMP := found()
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + 'ds') // дневной стационар
      if found()
        if !is_napr_stac
          is_napr_stac := .t.
        endif
        glob_menu_mz_rf[2] := found()
      endif
    
    //
      tmp_stom := {'2.78.54', '2.78.55', '2.78.56', '2.78.57', '2.78.58', '2.78.59', '2.78.60'}
      for i := 1 to len(tmp_stom)
        find (glob_mo[_MO_KOD_TFOMS] + tmp_stom[i]) //
        if found()
          glob_menu_mz_rf[3] := .t.
          exit
        endif
      next
    
    //
      find (glob_mo[_MO_KOD_TFOMS] + '4.20.702') // жидкостной цитологии
      if found()
        aadd(glob_klin_diagn, 1)
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + '4.15.746') // пренатального скрининга
      if found()
        aadd(glob_klin_diagn, 2)
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + '70.5.15') // Законченный случай диспансеризации детей-сирот (0-11 месяцев), 1 этап без гематологических исследований
      if found()
        glob_yes_kdp2[TIP_LU_DDS] := .t.
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + '70.6.13') // Законченный случай диспансеризации детей-сирот (0-11 месяцев), 1 этап без гематологических исследований
      if found()
        glob_yes_kdp2[TIP_LU_DDSOP] := .t.
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + '70.3.123') // Законченный случай диспансеризации женщин (в возрасте 21,24,27 лет), 1 этап без гематологических исследований
      if found()
        glob_yes_kdp2[TIP_LU_DVN] := .t.
      endif
    //
      find (glob_mo[_MO_KOD_TFOMS] + '72.2.41') // Законченный случай профилактического осмотра несовершеннолетних (2 мес.) 1 этап без гематологического исследования
      if found()
        glob_yes_kdp2[TIP_LU_PN] := .t.
      endif
  
    endif
    close databases
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  
  return fl

**** 26.02.22
function uslf_Index(val_year, /*@*/hash_files)
  local fl := .t.
  local sbase
  local file_index, sMD5
  
  sbase := prefixFileRefName(val_year) + 'uslf'  // справочник услуг ФФОМС на конкретный год
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    R_Use(exe_dir + sbase, ,'LUSLF')
    if (year(sys_date) - val_year) < NUMBER_YEAR .or. files_time(exe_dir + sbase + sdbf, cur_dir + sbase + sntx)
      if ! hb_FileExists(file_index) .or. ;
            ! check_izm_file_MD5(hash_files, sbase, sMD5)
        index on shifr to (cur_dir + sbase)
        hash_files := add_hash_row(hash_files, sbase, sMD5)
      endif
    endif
    close databases
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  return fl

**** 26.02.22
function unit_Index(val_year, /*@*/hash_files)
  local fl := .t.
  local sbase
  local file_index, sMD5
      
  sbase := prefixFileRefName(val_year) + 'unit'  // план-заказ на конкретный год
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    R_Use(exe_dir + sbase )
    if (year(sys_date) - val_year) < NUMBER_YEAR .or. files_time(exe_dir + sbase + sdbf, cur_dir + sbase + sntx)
      if ! hb_FileExists(file_index) .or. ;
            ! check_izm_file_MD5(hash_files, sbase, sMD5)
        index on str(code, 3) to (cur_dir + sbase)
        hash_files := add_hash_row(hash_files, sbase, sMD5)
      endif
    endif
    close databases
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  return fl

**** 26.02.22
function shema_index(val_year, /*@*/hash_files)
  local fl := .t.
  local sbase
  local file_index, sMD5

  sbase := prefixFileRefName(val_year) + 'shema'  // 
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
    if val_year == WORK_YEAR
      // добавлена индексация файла
      if ! hb_FileExists(file_index) .or. ;
            ! check_izm_file_MD5(hash_files, sbase, sMD5)
        R_Use(exe_dir + sbase )
        index on KOD to (cur_dir + sbase) // по коду критерия
        use
        hash_files := add_hash_row(hash_files, sbase, sMD5)
      endif
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  return fl

**** 29.01.22
function it_Index(val_year, /*@*/hash_files)
  local fl := .t.
  local ar, ar1, ar2, lSchema, i
  local sbase := prefixFileRefName(val_year) + 'it'  //
  local sbaseIt1, sbaseIt, sbaseShema
  local arrName

  if val_year < 2018 .or. val_year > WORK_YEAR // года не входит в рабочий диапазон
    return fl
  endif

  sbaseIt := prefixFileRefName(val_year) + 'it'
  sbaseIt1 := prefixFileRefName(val_year) + 'it1'
  sbaseShema := prefixFileRefName(val_year) + 'shema'

  if val_year == 2018
    arrName := 'arr_ad_cr_it'
  else
    arrName := 'arr_ad_cr_it' + last_digits_year(val_year)
  endif
  Public &arrName := {}

  if val_year >= 2021 // == WORK_YEAR

    // исходный файл T006 22 года
    if hb_FileExists(exe_dir + sbaseIt1 + sdbf)
      R_Use(exe_dir + sbaseShema, , 'SCHEMA')
      index on KOD to (cur_dir + sbaseShema)
  
      R_Use(exe_dir + sbaseIt1, ,'IT1')
      ('IT1')->(dbGoTop())  // go top
      do while !('IT1')->(eof())
        ar := {}
        ar1 := {}
        ar2 := {}
        if !empty(it1->ds)
          ar := Slist2arr(it1->ds)
          for i := 1 to len(ar)
            ar[i] := padr(ar[i],5)
          next
        endif
        if !empty(it1->ds1)
          ar1 := Slist2arr(it1->ds1)
          for i := 1 to len(ar1)
            ar1[i] := padr(ar1[i],5)
          next
        endif
        if !empty(it1->ds2)
          ar2 := Slist2arr(it1->ds2)
          for i := 1 to len(ar2)
            ar2[i] := padr(ar2[i],5)
          next
        endif
  
        ('SCHEMA')->(dbGoTop())
        if ('SCHEMA')->(dbSeek( padr(it1->CODE,6) ))
          lSchema := .t.
        endif

        if lSchema
          aadd(&arrName, {it1->USL_OK, padr(it1->CODE, 6), ar, ar1, ar2, alltrim(SCHEMA->NAME)})
        else
          aadd(&arrName, {it1->USL_OK, padr(it1->CODE, 6), ar, ar1, ar2, ''})
        endif
        ('IT1')->(dbskip()) 
        lSchema := .f.
      enddo
      ('SCHEMA')->(dbCloseArea())
      ('IT1')->(dbCloseArea())   //use
    else
      fl := notExistsFileNSI( exe_dir + sbaseIt1 + sdbf )
    endif
  elseif val_year == 2020
    // исходный файл  T006 2020 года
    if hb_FileExists(exe_dir + sbaseIt1 + sdbf)
      R_Use(exe_dir + sbaseIt1, , 'IT')
      go top
      do while !eof()
        ar := {}
        ar1 := {}
        ar2 := {}
        if !empty(it->ds)
          ar := Slist2arr(it->ds)
          for i := 1 to len(ar)
            ar[i] := padr(ar[i],5)
          next
        endif
        if !empty(it->ds1)
          ar1 := Slist2arr(it->ds1)
          for i := 1 to len(ar1)
            ar1[i] := padr(ar1[i],5)
          next
        endif
        if !empty(it->ds2)
          ar2 := Slist2arr(it->ds2)
          for i := 1 to len(ar2)
            ar2[i] := padr(ar2[i],5)
          next
        endif
        aadd(&arrName, {it->USL_OK, padr(it->CODE, 3), ar, ar1, ar2})
        skip
      enddo
      use
    else
      fl := notExistsFileNSI( exe_dir + sbaseIt1 + sdbf )
    endif
  elseif val_year == 2019
    // исходный файл  T006 2019 год
    sbase := '_mo9it'
    if hb_FileExists(exe_dir + sbaseIt + sdbf)
      R_Use(exe_dir + sbaseIt, ,'IT')
      index on ds to tmpit memory
      dbeval({|| aadd(arr_ad_cr_it19, {it->ds,it->it}) })
      use
    else
      fl := notExistsFileNSI( exe_dir + sbaseIt + sdbf )
    endif
  elseif val_year == 2018
    if hb_FileExists(exe_dir + sbaseIt + sdbf)
      R_Use(exe_dir + sbaseIt, , 'IT')
      index on ds to tmpit memory
      dbeval({|| aadd(arr_ad_cr_it, {it->ds, it->it}) })
      use
    else
      fl := notExistsFileNSI( exe_dir + sbaseIt + sdbf )
    endif
  endif
  return fl

**** 26.02.22
function k006_index(val_year, /*@*/hash_files)
  local fl := .t.
  local sbase
  local file_index, sMD5


  sbase := prefixFileRefName(val_year) + 'k006'  // 
  file_index := cur_dir + sbase + sntx
  sMD5 := ''
  if hb_FileExists(exe_dir + sbase + sdbf)
    if hb_FileExists(exe_dir + sbase + '.dbt')
      sMD5 := hb_MD5File( exe_dir + sbase + sdbf )
      R_Use(exe_dir + sbase)
      if (year(sys_date) - val_year) < NUMBER_YEAR .or. ;
            files_time(exe_dir + sbase + sdbf, cur_dir + sbase + sntx) .or. ;
            files_time(exe_dir + sbase + sdbf, cur_dir + sbase + '_' + sntx) .or. ;
            files_time(exe_dir + sbase + sdbf, cur_dir + sbase + 'AD' + sntx)

        if ! hb_FileExists(file_index) .or. ;
              ! hb_FileExists(cur_dir + sbase + '_' + sntx) .or. ;
              ! hb_FileExists(cur_dir + sbase + 'AD' + sntx) .or. ;
              ! check_izm_file_MD5(hash_files, sbase, sMD5)
              
          index on substr(shifr, 1, 2) + ds + sy + age + sex + los to (cur_dir + sbase) // по диагнозу/операции
          index on substr(shifr, 1, 2) + sy + ds + age + sex + los to (cur_dir + sbase + '_') // по операции/диагнозу
          index on ad_cr to (cur_dir + sbase + 'AD') // по дополнительному критерию Байкин
          hash_files := add_hash_row(hash_files, sbase, sMD5)
        endif
      endif
      use
    else
      fl := notExistsFileNSI( exe_dir + sbase + '.dbt' )
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  return fl
  