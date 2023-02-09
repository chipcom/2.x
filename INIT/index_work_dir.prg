#include 'function.ch'
#include 'chip_mo.ch'

#define NUMBER_YEAR 5 // число лет для переиндексации назад
#define INDEX_NEED  2 // число лет обязательной переиндексации

** 09.02.23 проверка наличия справочников НСИ
function files_NSI_exists(dir_file)
  local lRet := .t.
  local i
  local sbase
  local fl := .f.
  local aError := {}
  local cDbf := '.dbf'
  local cDbt := '.dbt'
  local arr_f  := {'_okator', '_okatoo', '_okatos', '_okatoo8', '_okatos8'}
  local arr_check := {}

  sbase := dir_file + 'chip_mo.db'
  aadd(arr_check, sbase)

  // справочники диагнозов
  sbase := dir_file + '_mo_mkb' + cDbf
  aadd(arr_check, sbase)
  sbase := dir_file + '_mo_mkbg' + cDbf
  aadd(arr_check, sbase)
  sbase := dir_file + '_mo_mkbk' + cDbf
  aadd(arr_check, sbase)

  // услуги <-> специальности
  sbase := dir_file + '_mo_spec' + cDbf
  aadd(arr_check, sbase)

  // услуги <-> профили
  sbase := dir_file + '_mo_prof' + cDbf
  aadd(arr_check, sbase)

  sbase := dir_file + '_mo_t007' + cDbf
  aadd(arr_check, sbase)

  // справочник страховых компаний РФ
  sbase := dir_file + '_mo_smo' + cDbf
  aadd(arr_check, sbase)

  // onkko_vmp
  sbase := dir_file + '_mo_ovmp' + cDbf
  aadd(arr_check, sbase)

  // N0__
  for i := 1 to 21
    sbase := dir_file + '_mo_N' + StrZero(i,3) + cDbf
    aadd(arr_check, sbase)
  next

  // справочник подразделений из паспорта ЛПУ
  sbase := dir_file + '_mo_podr' + cDbf
  aadd(arr_check, sbase)

  // справочник соответствия профиля мед.помощи с профилем койки
  sbase := dir_file + '_mo_prprk' + cDbf
  aadd(arr_check, sbase)

  sbase := dir_file + '_mo_t005' + cDbf
  aadd(arr_check, sbase)
  sbase := dir_file + '_mo_t005' + cDbt
  aadd(arr_check, sbase)

  // ОКАТО
  for i := 1 to len(arr_f)
    sbase := dir_file + arr_f[i] + cDbf
    aadd(arr_check, sbase)
  next

  // проверим существование файлов
  for i := 1 to len(arr_check)
    if ! hb_FileExists(arr_check[i])
      aadd(aError, arr_check[i])
      lRet := .f.
    endif
  next
  // if ! hb_FileExists(sbase)
  //   aadd(aError, sbase)
  //   lRet := .f.
  // else
  //   if (nSize := hb_vfSize(sbase)) < 3362000
  //     aadd(aError, 'Размер файла "' + sbase + '" меньше 3362000 байт. Обратитесь к разработчикам.')
  //     lret := .f.
  //   endif
  // endif
altd()
  return lRet

** 08.02.23 проверка и переиндексирование справочников ТФОМС
Function index_work_dir(exe_dir, cur_dir, flag)
  Local fl := .t., i, arr, buf := save_maxrow()
  local arrRefFFOMS := {}, row, row_flag := .t.
  local lSchema := .f.
  local countYear
  local file_index, sbase
  local nSize

  public is_otd_dep := .f., glob_otd_dep := 0, mm_otd_dep := {}

  Public arr_12_VMP := {}
  Public is_napr_pol := .f., ; // работа с направлениями на госпитализацию в п-ке
         is_napr_stac := .f., ;  // работа с направлениями на госпитализацию в стационаре
         glob_klin_diagn := {} // работа со специальными лабораторными исследованиями
  Public is_ksg_VMP := .f., is_12_VMP := .f., is_14_VMP := .f., is_ds_VMP := .f.
  Public is_21_VMP := .f.     // ВМП для 21 года
  Public is_22_VMP := .f.     // ВМП для 22 года
  Public is_23_VMP := .f.     // ВМП для 23 года
  
  DEFAULT flag TO .f.

  // справочник цен на услуги ТФОМС 2016-2017
  Public glob_MU_dializ := {}//'A18.05.002.001','A18.05.002.002','A18.05.002.003',;
                            //'A18.05.003','A18.05.003.001','A18.05.011','A18.30.001','A18.30.001.001'}
  Public glob_KSG_dializ := {}//'10000901','10000902','10000903','10000905','10000906','10000907','10000913',;
                             //'20000912','20000916','20000917','20000918','20000919','20000920'}
                             //'1000901','1000902','1000903','1000905','1000906','1000907','1000913',;
                             //'2000912','2000916','2000917','2000918','2000919','2000920'}
  
  Public is_vr_pr_pp := .f., is_hemodializ := .f., is_per_dializ := .f., is_reabil_slux := .f.,;
         is_ksg_1300098 := .f., is_dop_ob_em := .f., glob_yes_kdp2[10], glob_menu_mz_rf := {.f., .f., .f.}

  Public is_alldializ := .f.

  afill(glob_yes_kdp2, .f.)

  mywait('Подождите, идет проверка служебных данных в рабочем каталоге...')

  // справочник диагнозов
  sbase := '_mo_mkb'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index)
      R_Use(exe_dir + sbase )
      index on shifr + str(ks, 1) to (cur_dir + sbase)
      close databases
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // услуги <-> специальности
  sbase := '_mo_spec'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index)
      R_Use(exe_dir + sbase )
      index on shifr + str(vzros_reb, 1) + str(prvs_new, 6) to (cur_dir + sbase)
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // услуги <-> профили
  sbase := '_mo_prof'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index)
      R_Use(exe_dir + sbase )
      index on shifr + str(vzros_reb, 1) + str(profil, 3) to (cur_dir + sbase)
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // for countYear = WORK_YEAR - 4 to WORK_YEAR
  for countYear = WORK_YEAR - NUMBER_YEAR to WORK_YEAR
    fl := vmp_usl_check(countYear, exe_dir, cur_dir, flag)
    fl := dep_index_and_fill(countYear, exe_dir, cur_dir, flag)  // справочник отделений на countYear год
    fl := usl_Index(countYear, exe_dir, cur_dir, flag)    // справочник услуг ТФОМС на countYear год
    fl := uslc_Index(countYear, exe_dir, cur_dir, flag)   // цены на услуги на countYear год
    fl := uslf_Index(countYear, exe_dir, cur_dir, flag)   // справочник услуг ФФОМС countYear
    fl := unit_Index(countYear, exe_dir, cur_dir, flag)   // план-заказ
    fl := shema_index(countYear, exe_dir, cur_dir, flag)
    // fl := it_Index(countYear, exe_dir, cur_dir, flag)
    fl := k006_index(countYear, exe_dir, cur_dir, flag)
  next

  Public is_MO_VMP := (is_ksg_VMP .or. is_12_VMP .or. is_14_VMP .or. is_ds_VMP .or. is_21_VMP .or. is_22_VMP .or. is_23_VMP)
  // справочник доплат по законченным случаям (старый справочник)
  /*sbase := '_mo_usld'
  if hb_FileExists(exe_dir + sbase + sdbf)
    if files_time(exe_dir + sbase + sdbf,cur_dir + sbase+sntx)
      R_Use(exe_dir + sbase )
      index on shifr+dtos(datebeg) to (cur_dir + sbase)
      use
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif*/
  // справочник 'услуги по законченным случаям + диагнозы'
  /*sbase := '_mo_uslz'
  if hb_FileExists(exe_dir + sbase + sdbf)
    if files_time(exe_dir + sbase + sdbf,cur_dir + sbase+sntx)
      R_Use(exe_dir + sbase )
      index on shifr+str(type_diag,1)+kod_diag to (cur_dir + sbase)
      use
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif*/


  Public arr_t007 := {}
  sbase := '_mo_t007'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index) .or. ;
    //     ! hb_FileExists(cur_dir + sbase + '2' + sntx)
      R_Use(exe_dir + sbase, , 'T7')
      index on upper(left(NAME, 50)) + str(profil_k, 3) to (cur_dir + sbase) UNIQUE
      dbeval({|| aadd(arr_t007, {alltrim(t7->name), t7->profil_k, t7->pk_V020})})
      index on str(profil_k, 3) + str(profil, 3) to (cur_dir + sbase)
      index on str(pk_V020, 3) + str(profil, 3) to (cur_dir + sbase + '2')
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // справочник страховых компаний РФ
  sbase := '_mo_smo'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    Public glob_array_srf := {}
    // if ! hb_FileExists(file_index) .or. ;
    //       ! hb_FileExists(cur_dir + sbase + '2' + sntx) .or. ;
    //       ! hb_FileExists(cur_dir + sbase + '3' + sntx)
      R_Use(exe_dir + sbase )
      index on okato to (cur_dir + sbase) UNIQUE
      dbeval({|| aadd(glob_array_srf, {'', field->okato})})
      index on okato + smo to (cur_dir + sbase)
      index on smo to (cur_dir + sbase + '2')
      index on okato + ogrn to (cur_dir + sbase + '3')
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // onkko_vmp
  sbase := '_mo_ovmp'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index)
      R_Use(exe_dir + sbase )
      index on str(metod, 3) to (cur_dir + sbase)
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N002
  sbase := '_mo_N002'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index) .or. ;
    //       ! hb_FileExists(cur_dir + sbase + 'd' + sntx)
      R_Use(exe_dir + sbase )
      index on str(id_st, 6) to (cur_dir + sbase)
      index on ds_st + kod_st to (cur_dir + sbase + 'd')
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N003
  sbase := '_mo_N003'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index) .or. ;
    //       ! hb_FileExists(cur_dir + sbase + 'd' + sntx)
      R_Use(exe_dir + sbase )
      index on str(id_t, 6) to (cur_dir + sbase)
      index on ds_t + kod_t to (cur_dir + sbase + 'd')
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N004
  sbase := '_mo_N004'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index) .or. ;
    //       ! hb_FileExists(cur_dir + sbase + 'd' + sntx)
      R_Use(exe_dir + sbase )
      index on str(id_n, 6) to (cur_dir + sbase)
      index on ds_n + kod_n to (cur_dir + sbase + 'd')
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N005
  sbase := '_mo_N005'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index) .or. ;
    //       ! hb_FileExists(cur_dir + sbase + 'd' + sntx)
      R_Use(exe_dir + sbase )
      index on str(id_m, 6) to (cur_dir + sbase)
      index on ds_m + kod_m to (cur_dir + sbase + 'd')
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N006 - в 2019 году пустой
  sbase := '_mo_N006'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index)
      R_Use(exe_dir + sbase )
      index on ds_gr + str(id_t, 6) + str(id_n, 6) + str(id_m, 6) to (cur_dir + sbase)
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N007
  sbase := '_mo_N007'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index)
      R_Use(exe_dir + sbase )
      index on str(id_mrf, 6) to (cur_dir + sbase)
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N008
  sbase := '_mo_N008'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index)
      R_Use(exe_dir + sbase )
      index on str(id_mrf, 6) to (cur_dir + sbase)
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N010
  sbase := '_mo_N010'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index)
      R_Use(exe_dir + sbase )
      index on str(id_igh, 6) to (cur_dir + sbase)
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N011
  sbase := '_mo_N011'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index)
      R_Use(exe_dir + sbase )
      index on str(id_igh, 6) to (cur_dir + sbase)
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N020
  sbase := '_mo_N020'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
  //   if ! hb_FileExists(file_index) .or. ;
  //         ! hb_FileExists(cur_dir + sbase + 'n' + sntx)
      R_Use(exe_dir + sbase )
      index on id_lekp to (cur_dir + sbase)
      index on upper(mnn) to (cur_dir + sbase + 'n')
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N021
  sbase := '_mo_N021'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index)
      R_Use(exe_dir + sbase )
      index on code_sh + id_lekp to (cur_dir + sbase)
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // справочник подразделений из паспорта ЛПУ
  sbase := '_mo_podr'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index)
      R_Use(exe_dir + sbase )
      index on codemo + padr(upper(kodotd), 25) to (cur_dir + sbase)
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // справочник соответствия профиля мед.помощи с профилем койки
  sbase := '_mo_prprk'
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if ! hb_FileExists(file_index)
      R_Use(exe_dir + sbase )
      index on str(profil, 3) + str(profil_k, 3) to (cur_dir + sbase)
      use
    // endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  sbase := exe_dir + 'chip_mo.db'
  if hb_FileExists(sbase)
// в дальнейшем удалить
    if (nSize := hb_vfSize(sbase)) < 3362000
      fl := func_error('Размер файла "' + sbase + '" меньше 3362000 байт. Обратитесь к разработчикам.')
    endif
  else
    fl := notExistsFileNSI(sbase)
  endif

  // aadd(arrRefFFOMS, {FILE_NAME_SQL, .f., FILE_NAME_SQL + ' - SQL-файл справочников системы'})
  aadd(arrRefFFOMS, {'_mo_t005', .t., 'T005 - Справочник ошибок при проведении технологического контроля Реестров сведений и Реестров счетов' } )

  for each row in arrRefFFOMS
    sbase := row[1]
    if ! hb_FileExists(exe_dir + sbase + sdbf)
      row_flag := .f.
    endif
    if row[2]
      if ! hb_FileExists(exe_dir + sbase + sdbt)
        row_flag := .f.
      endif
    endif
  next
  fl := row_flag
  if fl
    // справочник ошибок
    sbase := '_mo_t005'
    file_index := cur_dir + sbase + sntx
    // if ! hb_FileExists(file_index)
      R_Use(exe_dir + sbase )
      index on str(kod, 3) to (cur_dir + sbase)
      use
    // endif
  endif

  // справочник ОКАТО
  if fl
    okato_index()
    //
    dbcreate(cur_dir + 'tmp_srf', {{'okato', 'C', 5, 0}, {'name', 'C', 80, 0}})
    use (cur_dir + 'tmp_srf') new alias TMP
    R_Use(dir_exe + '_okator', cur_dir + '_okatr', 'RE')
    R_Use(dir_exe + '_okatoo', cur_dir + '_okato', 'OB')
    for i := 1 to len(glob_array_srf)
      select OB
      find (glob_array_srf[i, 2])
      if found()
        glob_array_srf[i, 1] := rtrim(ob->name)
      else
        select RE
        find (left(glob_array_srf[i, 2], 2))
        if found()
          glob_array_srf[i, 1] := rtrim(re->name)
        elseif left(glob_array_srf[i, 2], 2) == '55'
          glob_array_srf[i, 1] := 'г.Байконур'
        endif
      endif
      select TMP
      append blank
      tmp->okato := glob_array_srf[i, 2]
      tmp->name  := iif(substr(glob_array_srf[i, 2], 3, 1) == '0', '', '  ') + glob_array_srf[i, 1]
    next
    close databases
  else
    hard_err('delete')
    QUIT
  endif
  rest_box(buf)

  return nil

** 08.02.23
function vmp_usl_check(val_year, exe_dir, cur_dir, flag)  // справочник соответствия услуг ВМП услугам ТФОМС на countYear год
  local fl := .t.
  local sbase := prefixFileRefName(val_year) + 'vmp_usl'  // справочник соответствия услуг ВМП услугам ТФОМС
    
  DEFAULT flag TO .f.
  if val_year >= 2021
    if ! hb_FileExists(exe_dir + sbase + sdbf)
      fl := notExistsFileNSI(exe_dir + sbase + sdbf)
    endif
  endif
  return fl

** 08.02.23
function dep_index_and_fill(val_year, exe_dir, cur_dir, flag)
  local fl := .t.
  local sbase
  local lIndex := .f.
  local file_index
  
  DEFAULT flag TO .f.
  // is_otd_dep, glob_otd_dep, mm_otd_dep - объявлены ранее как Public
  sbase := prefixFileRefName(val_year) + 'dep'  // справочник отделений на конкретный год
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if (year(sys_date) - val_year) < INDEX_NEED
      lIndex := .t.
    // endif
    // if ! hb_FileExists(file_index)
    //   lIndex := .t.
    // endif
    if flag
      lIndex := .t.
    endif
    R_Use(exe_dir + sbase, , 'DEP')
    if lIndex
      index on str(code, 3) to (cur_dir + sbase) for codem == glob_mo[_MO_KOD_TFOMS]
    else
      set index to (file_index)
    endif

    if val_year == WORK_YEAR
      dbeval({|| aadd(mm_otd_dep, {alltrim(dep->name_short) + ' (' + alltrim(dep->name) + ')', dep->code, dep->place})})
      if (is_otd_dep := (len(mm_otd_dep) > 0))
        asort(mm_otd_dep, , , {|x, y| x[1] < y[1]})
      endif
    endif
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  if is_otd_dep
    lIndex := .f.
    sbase := prefixFileRefName(val_year) + 'deppr' // справочник отделения + профили  на конкретный год
    file_index := cur_dir + sbase + sntx
    if hb_FileExists(exe_dir + sbase + sdbf)
      if (year(sys_date) - val_year) < INDEX_NEED
        lIndex := .t.
      endif
      if ! hb_FileExists(file_index)
        lIndex := .t.
      endif
      if lIndex
        R_Use(exe_dir + sbase, , 'DEP')
        index on str(code, 3) + str(pr_mp, 3) to (cur_dir + sbase) for codem == glob_mo[_MO_KOD_TFOMS]
        use
      endif

    else
      fl := notExistsFileNSI( exe_dir + sbase + sdbf )
    endif
  endif
  return fl

** 08.02.23
function usl_Index(val_year, exe_dir, cur_dir, flag)
  local fl := .t.
  local sbase
  local lIndex := .f.
  local file_index

  DEFAULT flag TO .f.
  sbase := prefixFileRefName(val_year) + 'usl'  // справочник услуг ТФОМС на конкретный год
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if (year(sys_date) - val_year) < INDEX_NEED
      lIndex := .t.
    // endif
    // if ! hb_FileExists(file_index)
    //   lIndex := .t.
    // endif
    if flag
      lIndex := .t.
    endif
    R_Use(exe_dir + sbase, ,'LUSL')
    if lIndex
      index on shifr to (cur_dir + sbase)
    else
      set index to (file_index)
    endif
    if val_year == WORK_YEAR
      find ('1.21.') // ВМП федеральное   // 10.02.22 замена услуг с 1.20 на 1.21 письмо 12-20-60 от 01.02.22
      // find ('1.20.') // ВМП федеральное   // 07.02.21 замена услуг с 1.12 на 1.20 письмо 12-20-60 от 01.02.21
      // do while left(lusl->shifr,5) == '1.20.' .and. !eof()
      do while left(lusl->shifr,5) == '1.21.' .and. !eof()
        aadd(arr_12_VMP,int(val(substr(lusl->shifr,6))))
        skip
      enddo
    endif
    close databases
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  return fl
  
** 08.02.23
function uslc_Index(val_year, exe_dir, cur_dir, flag)
  local fl := .t.
  local sbase, prefix
  local index_usl_name
  local lIndex := .f.
  local file_index
  
  DEFAULT flag TO .f.
  prefix := prefixFileRefName(val_year)
  sbase :=  prefix + 'uslc'  // цены на услуги на конкретный год
  index_usl_name :=  prefix + 'uslu'  // 
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf) .and. valtype(glob_mo) == 'A'
    // if (year(sys_date) - val_year) < INDEX_NEED
      lIndex := .t.
    // endif
    // if ! hb_FileExists(file_index) .or. ;
    //         ! hb_FileExists(cur_dir + index_usl_name + sntx)
    //   lIndex := .t.
    // endif
    if flag
      lIndex := .t.
    endif
    R_Use(exe_dir + sbase, , 'LUSLC')
    if lIndex
      index on shifr + str(vzros_reb, 1) + str(depart, 3) + dtos(datebeg) to (cur_dir + sbase) ;
              for codemo == glob_mo[_MO_KOD_TFOMS]
      index on codemo + shifr + str(vzros_reb, 1) + str(depart, 3) + dtos(datebeg) to (cur_dir + index_usl_name) ;
              for codemo == glob_mo[_MO_KOD_TFOMS] // для совместимости со старой версией справочника
    else
      set index to (file_index)
      set index to (cur_dir + index_usl_name)
    endif
  
    if val_year == WORK_YEAR // 2020 // 2019 // 2018
      // Медицинская реабилитация детей с нарушениями слуха без замены речевого процессора системы кохлеарной имплантации
      find (glob_mo[_MO_KOD_TFOMS] + 'st37.015')
      if found()
        is_reabil_slux := found()
      endif
  
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

** 08.02.23
function uslf_Index(val_year, exe_dir, cur_dir, flag)
  local fl := .t.
  local sbase
  local lIndex := .f.
  local file_index
  
  DEFAULT flag TO .f.
  sbase := prefixFileRefName(val_year) + 'uslf'  // справочник услуг ФФОМС на конкретный год
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if (year(sys_date) - val_year) < INDEX_NEED
      lIndex := .t.
    // endif
    // if ! hb_FileExists(file_index)
    //   lIndex := .t.
    // endif
    if flag
      lIndex := .t.
    endif
    if lIndex
      R_Use(exe_dir + sbase, , 'LUSLF')
      index on shifr to (cur_dir + sbase)
      use
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  return fl

** 08.02.23
function unit_Index(val_year, exe_dir, cur_dir, flag)
  local fl := .t.
  local sbase
  local lIndex := .f.
  local file_index
      
  DEFAULT flag TO .f.
  sbase := prefixFileRefName(val_year) + 'unit'  // план-заказ на конкретный год
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if (year(sys_date) - val_year) < INDEX_NEED
      lIndex := .t.
    // endif
    // if ! hb_FileExists(file_index)
    //   lIndex := .t.
    // endif
    if flag
      lIndex := .t.
    endif
    if lIndex
      R_Use(exe_dir + sbase )
      index on str(code, 3) to (cur_dir + sbase)
      use
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  return fl

** 08.02.23
function shema_index(val_year, exe_dir, cur_dir, flag)
  local fl := .t.
  local sbase
  local file_index
  local lIndex := .f.

  DEFAULT flag TO .f.
  sbase := prefixFileRefName(val_year) + 'shema'  // 
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    // if (year(sys_date) - val_year) < INDEX_NEED
      lIndex := .t.
    // endif
    // if ! hb_FileExists(file_index)
    //   lIndex := .t.
    // endif
    if flag
      lIndex := .t.
    endif
    if lIndex
      R_Use(exe_dir + sbase )
      index on KOD to (cur_dir + sbase) // по коду критерия
      use
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  return fl

** 08.02.23
function k006_index(val_year, exe_dir, cur_dir, flag)
  local fl := .t.
  local sbase
  local lIndex := .f.
  local file_index

  DEFAULT flag TO .f.
  sbase := prefixFileRefName(val_year) + 'k006'  // 
  file_index := cur_dir + sbase + sntx
  if hb_FileExists(exe_dir + sbase + sdbf)
    if hb_FileExists(exe_dir + sbase + '.dbt')
      // if (year(sys_date) - val_year) < INDEX_NEED
        lIndex := .t.
      // endif
      // if ! hb_FileExists(file_index) .or. ;
      //       ! hb_FileExists(cur_dir + sbase + '_' + sntx) .or. ;
      //       ! hb_FileExists(cur_dir + sbase + 'AD' + sntx)
      //   lIndex := .t.
      // endif
      if flag
        lIndex := .t.
      endif
      if lIndex
        R_Use(exe_dir + sbase)
        index on substr(shifr, 1, 2) + ds + sy + age + sex + los to (cur_dir + sbase) // по диагнозу/операции
        index on substr(shifr, 1, 2) + sy + ds + age + sex + los to (cur_dir + sbase + '_') // по операции/диагнозу
        index on ad_cr to (cur_dir + sbase + 'AD') // по дополнительному критерию Байкин
        use
      endif
    else
      fl := notExistsFileNSI( exe_dir + sbase + '.dbt' )
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  return fl
  
**** 29.01.22
// function it_Index(val_year, exe_dir, cur_dir, flag)
//   local fl := .t.
//   local ar, ar1, ar2, lSchema, i
//   local sbase := prefixFileRefName(val_year) + 'it'  //
//   local sbaseIt1, sbaseIt, sbaseShema
//   local arrName

  // DEFAULT flag TO .f.
//   if val_year < 2018 .or. val_year > WORK_YEAR // года не входит в рабочий диапазон
//     return fl
//   endif

//   sbaseIt := prefixFileRefName(val_year) + 'it'
//   sbaseIt1 := prefixFileRefName(val_year) + 'it1'
//   sbaseShema := prefixFileRefName(val_year) + 'shema'

//   if val_year == 2018
//     arrName := 'arr_ad_cr_it'
//   else
//     arrName := 'arr_ad_cr_it' + last_digits_year(val_year)
//   endif
//   Public &arrName := {}

//   if val_year >= 2021 // == WORK_YEAR

//     // исходный файл T006 22 года
//     if hb_FileExists(exe_dir + sbaseIt1 + sdbf)
//       R_Use(exe_dir + sbaseShema, , 'SCHEMA')
//       index on KOD to (cur_dir + sbaseShema)
  
//       R_Use(exe_dir + sbaseIt1, ,'IT1')
//       ('IT1')->(dbGoTop())  // go top
//       do while !('IT1')->(eof())
//         ar := {}
//         ar1 := {}
//         ar2 := {}
//         if !empty(it1->ds)
//           ar := Slist2arr(it1->ds)
//           for i := 1 to len(ar)
//             ar[i] := padr(ar[i], 5)
//           next
//         endif
//         if !empty(it1->ds1)
//           ar1 := Slist2arr(it1->ds1)
//           for i := 1 to len(ar1)
//             ar1[i] := padr(ar1[i], 5)
//           next
//         endif
//         if !empty(it1->ds2)
//           ar2 := Slist2arr(it1->ds2)
//           for i := 1 to len(ar2)
//             ar2[i] := padr(ar2[i], 5)
//           next
//         endif
  
//         ('SCHEMA')->(dbGoTop())
//         if ('SCHEMA')->(dbSeek( padr(it1->CODE, 6)))
//           lSchema := .t.
//         endif

//         if lSchema
//           aadd(&arrName, {it1->USL_OK, padr(it1->CODE, 6), ar, ar1, ar2, alltrim(SCHEMA->NAME)})
//         else
//           aadd(&arrName, {it1->USL_OK, padr(it1->CODE, 6), ar, ar1, ar2, ''})
//         endif
//         ('IT1')->(dbskip()) 
//         lSchema := .f.
//       enddo
//       ('SCHEMA')->(dbCloseArea())
//       ('IT1')->(dbCloseArea())   //use
//     else
//       fl := notExistsFileNSI( exe_dir + sbaseIt1 + sdbf )
//     endif
//   elseif val_year == 2020
//     // исходный файл  T006 2020 года
//     if hb_FileExists(exe_dir + sbaseIt1 + sdbf)
//       R_Use(exe_dir + sbaseIt1, , 'IT')
//       go top
//       do while !eof()
//         ar := {}
//         ar1 := {}
//         ar2 := {}
//         if !empty(it->ds)
//           ar := Slist2arr(it->ds)
//           for i := 1 to len(ar)
//             ar[i] := padr(ar[i], 5)
//           next
//         endif
//         if !empty(it->ds1)
//           ar1 := Slist2arr(it->ds1)
//           for i := 1 to len(ar1)
//             ar1[i] := padr(ar1[i], 5)
//           next
//         endif
//         if !empty(it->ds2)
//           ar2 := Slist2arr(it->ds2)
//           for i := 1 to len(ar2)
//             ar2[i] := padr(ar2[i], 5)
//           next
//         endif
//         aadd(&arrName, {it->USL_OK, padr(it->CODE, 3), ar, ar1, ar2})
//         skip
//       enddo
//       use
//     else
//       fl := notExistsFileNSI( exe_dir + sbaseIt1 + sdbf )
//     endif
//   elseif val_year == 2019
//     // исходный файл  T006 2019 год
//     sbase := '_mo9it'
//     if hb_FileExists(exe_dir + sbaseIt + sdbf)
//       R_Use(exe_dir + sbaseIt, ,'IT')
//       index on ds to tmpit memory
//       dbeval({|| aadd(arr_ad_cr_it19, {it->ds, it->it}) })
//       use
//     else
//       fl := notExistsFileNSI( exe_dir + sbaseIt + sdbf )
//     endif
//   elseif val_year == 2018
//     if hb_FileExists(exe_dir + sbaseIt + sdbf)
//       R_Use(exe_dir + sbaseIt, , 'IT')
//       index on ds to tmpit memory
//       dbeval({|| aadd(arr_ad_cr_it, {it->ds, it->it}) })
//       use
//     else
//       fl := notExistsFileNSI( exe_dir + sbaseIt + sdbf )
//     endif
//   endif
//   return fl
