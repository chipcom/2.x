#include 'function.ch'
#include 'chip_mo.ch'

#define NUMBER_YEAR 3 // число лет для переиндексации назад
#define INDEX_NEED  2 // число лет обязательной переиндексации

// 26.09.23 проверка наличия справочников НСИ
function files_NSI_exists(dir_file)
  local lRet := .t.
  local i
  local sbase
  local aError := {}
  local cDbf := '.dbf'
  local cDbt := '.dbt'
  local arr_f  := {'_okator', '_okatoo', '_okatos', '_okatoo8', '_okatos8'}
  local arr_check := {}
  local countYear
  local prefix
  local arr_TFOMS
  local n_file := cur_dir + 'error_init' + stxt, sh := 80, HH := 60

  sbase := dir_file + FILE_NAME_SQL // 'chip_mo.db'
  if ! hb_FileExists(sbase)
    aadd(aError, 'Отсутствует файл: ' + sbase)
  else
    if (nSize := hb_vfSize(sbase)) < 3362000
      aadd(aError, 'Размер файла "' + sbase + '" меньше 3362000 байт. Обратитесь к разработчикам.')
    endif
  endif

  fill_exists_files_TFOMS(dir_file)

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

  // справочник страховых компаний РФ
  sbase := dir_file + '_mo_smo' + cDbf
  aadd(arr_check, sbase)

  // onkko_vmp
  sbase := dir_file + '_mo_ovmp' + cDbf
  aadd(arr_check, sbase)

  // N0__
  // for i := 1 to 21
  for i := 20 to 21
    sbase := dir_file + '_mo_N' + StrZero(i, 3) + cDbf
    aadd(arr_check, sbase)
  next

  // справочник подразделений из паспорта ЛПУ
  sbase := dir_file + '_mo_podr' + cDbf
  aadd(arr_check, sbase)

  // справочник соответствия профиля мед.помощи с профилем койки
  sbase := dir_file + '_mo_prprk' + cDbf
  aadd(arr_check, sbase)

  // ОКАТО
  for i := 1 to len(arr_f)
    sbase := dir_file + arr_f[i] + cDbf
    aadd(arr_check, sbase)
  next

  // проверим существование файлов
  for i := 1 to len(arr_check)
    if ! hb_FileExists(arr_check[i])
      aadd(aError, 'Отсутствует файл: ' + arr_check[i])
    endif
  next

  prefix := dir_file + prefixFileRefName(WORK_YEAR)
  arr_TFOMS := array_exists_files_TFOMS(WORK_YEAR)
  for i := 1 to len(arr_TFOMS)
    if ! arr_TFOMS[i, 2]
      aadd(aError, 'Отсутствует файл: ' + prefix + arr_TFOMS[i, 1] + cDbf)
    endif
  next

  if len(aError) > 0
    aadd(aError, 'Работа невозможна!')
    f_message(aError, , 'GR+/R', 'W+/R', 13)
    inkey(0)

    lret := .f.
  endif

  return lRet

// 29.09.23 проверка и переиндексирование справочников ТФОМС
Function index_work_dir(dir_spavoch, cur_dir, flag)
  Local fl := .t., i, arr, buf := save_maxrow()
  local arrRefFFOMS := {}, row, row_flag := .t.
  local lSchema := .f.
  local countYear
  local file_index, sbase
  local nSize
  local cVar

  DEFAULT flag TO .f.

  afill(glob_yes_kdp2, .f.)

  if flag
    mywait('Подождите, идет переиндексация файлов НСИ в рабочей области...')
  else
    mywait('Подождите, идет проверка служебных данных в рабочем каталоге...')
  endif

  // справочник диагнозов
  sbase := '_mo_mkb'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on shifr + str(ks, 1) to (cur_dir + sbase)
  close databases

  // услуги <-> специальности
  sbase := '_mo_spec'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on shifr + str(vzros_reb, 1) + str(prvs_new, 6) to (cur_dir + sbase)
  use

  // услуги <-> профили
  sbase := '_mo_prof'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on shifr + str(vzros_reb, 1) + str(profil, 3) to (cur_dir + sbase)
  use

  if flag
    for countYear = 2018 to WORK_YEAR
      fl := dep_index_and_fill(countYear, dir_spavoch, cur_dir, flag)  // справочник отделений на countYear год
      fl := usl_Index(countYear, dir_spavoch, cur_dir, flag)    // справочник услуг ТФОМС на countYear год
      fl := uslc_Index(countYear, dir_spavoch, cur_dir, flag)   // цены на услуги на countYear год
      fl := uslf_Index(countYear, dir_spavoch, cur_dir, flag)   // справочник услуг ФФОМС countYear
      fl := unit_Index(countYear, dir_spavoch, cur_dir, flag)   // план-заказ
      fl := k006_index(countYear, dir_spavoch, cur_dir, flag)
    next
  else
    fl := dep_index_and_fill(WORK_YEAR, dir_spavoch, cur_dir, flag)  // справочник отделений на countYear год
    fl := usl_Index(WORK_YEAR, dir_spavoch, cur_dir, flag)    // справочник услуг ТФОМС на countYear год
    fl := uslc_Index(WORK_YEAR, dir_spavoch, cur_dir, flag)   // цены на услуги на countYear год
    fl := uslf_Index(WORK_YEAR, dir_spavoch, cur_dir, flag)   // справочник услуг ФФОМС countYear
    fl := unit_Index(WORK_YEAR, dir_spavoch, cur_dir, flag)   // план-заказ
    fl := k006_index(WORK_YEAR, dir_spavoch, cur_dir, flag)
  endif

  load_exists_uslugi()

  for i := 2019 to WORK_YEAR
    cVar := 'is_' + substr(str(i, 4), 3) + '_VMP'
    is_MO_VMP := is_MO_VMP .or. __mvGet( cVar )
  next

  // справочник страховых компаний РФ
  sbase := '_mo_smo'
  file_index := cur_dir + sbase + sntx
  // Public glob_array_srf := {}
  glob_array_srf := {}
  R_Use(dir_spavoch + sbase )
  index on okato to (cur_dir + sbase) UNIQUE
  dbeval({|| aadd(glob_array_srf, {'', field->okato})})
  index on okato + smo to (cur_dir + sbase)
  index on smo to (cur_dir + sbase + '2')
  index on okato + ogrn to (cur_dir + sbase + '3')
  use

  // onkko_vmp
  sbase := '_mo_ovmp'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on str(metod, 3) to (cur_dir + sbase)
  use

  // N020
  sbase := '_mo_N020'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on id_lekp to (cur_dir + sbase)
  index on upper(mnn) to (cur_dir + sbase + 'n')
  use

  // справочник подразделений из паспорта ЛПУ
  sbase := '_mo_podr'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on codemo + padr(upper(kodotd), 25) to (cur_dir + sbase)
  use

  // справочник соответствия профиля мед.помощи с профилем койки
  sbase := '_mo_prprk'
  file_index := cur_dir + sbase + sntx
  R_Use(dir_spavoch + sbase )
  index on str(profil, 3) + str(profil_k, 3) to (cur_dir + sbase)
  use

  // справочник ОКАТО
  okato_index(flag)
  //
  dbcreate(cur_dir + 'tmp_srf', {{'okato', 'C', 5, 0}, {'name', 'C', 80, 0}})
  use (cur_dir + 'tmp_srf') new alias TMP
  R_Use(dir_spavoch + '_okator', cur_dir + '_okatr', 'RE')
  R_Use(dir_spavoch + '_okatoo', cur_dir + '_okato', 'OB')
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
  rest_box(buf)

  return nil

// 09.03.23
function dep_index_and_fill(val_year, dir_spavoch, cur_dir, flag)
  local sbase
  local file_index
  
  DEFAULT flag TO .f.
  sbase := prefixFileRefName(val_year) + 'dep'  // справочник отделений на конкретный год
  if hb_vfExists(dir_spavoch + sbase + sdbf)
    file_index := cur_dir + sbase + sntx
    R_Use(dir_spavoch + sbase, , 'DEP')
    index on str(code, 3) to (cur_dir + sbase) for codem == glob_mo[_MO_KOD_TFOMS]

    if val_year == WORK_YEAR
      dbeval({|| aadd(mm_otd_dep, {alltrim(dep->name_short) + ' (' + alltrim(dep->name) + ')', dep->code, dep->place})})
      if (is_otd_dep := (len(mm_otd_dep) > 0))
        asort(mm_otd_dep, , , {|x, y| x[1] < y[1]})
      endif
    endif
    use
    if is_otd_dep
      lIndex := .f.
      sbase := prefixFileRefName(val_year) + 'deppr' // справочник отделения + профили  на конкретный год
      if hb_vfExists(dir_spavoch + sbase + sdbf)
        file_index := cur_dir + sbase + sntx
        R_Use(dir_spavoch + sbase, , 'DEP')
        index on str(code, 3) + str(pr_mp, 3) to (cur_dir + sbase) for codem == glob_mo[_MO_KOD_TFOMS]
        use
      endif
    endif
  endif
  return nil

// 14.03.23
function usl_Index(val_year, dir_spavoch, cur_dir, flag)
  local sbase
  local file_index
  local shifrVMP

  DEFAULT flag TO .f.
  sbase := prefixFileRefName(val_year) + 'usl'  // справочник услуг ТФОМС на конкретный год
  if hb_vfExists(dir_spavoch + sbase + sdbf)
    file_index := cur_dir + sbase + sntx
    R_Use(dir_spavoch + sbase, ,'LUSL')
    index on shifr to (cur_dir + sbase)
    if val_year == WORK_YEAR
      shifrVMP := code_services_VMP(WORK_YEAR)
      find (shifrVMP)
      // find ('1.22.') // ВМП федеральное   // 01.03.23 замена услуг с 1.21 на 1.22 письмо
      // find ('1.21.') // ВМП федеральное   // 10.02.22 замена услуг с 1.20 на 1.21 письмо 12-20-60 от 01.02.22
      // find ('1.20.') // ВМП федеральное   // 07.02.21 замена услуг с 1.12 на 1.20 письмо 12-20-60 от 01.02.21
      // do while left(lusl->shifr,5) == '1.20.' .and. !eof()
      // do while left(lusl->shifr,5) == '1.21.' .and. !eof()
      // do while left(lusl->shifr, 5) == '1.22.' .and. !eof()
      do while left(lusl->shifr, 5) == shifrVMP .and. !eof()
        aadd(arr_12_VMP, int(val(substr(lusl->shifr, 6))))
        skip
      enddo
    endif
    close databases
  endif
  return nil

// 23.03.23
function uslc_Index(val_year, dir_spavoch, cur_dir, flag)
  local sbase, prefix
  local index_usl_name
  local file_index
  
  DEFAULT flag TO .f.
  prefix := prefixFileRefName(val_year)
  sbase :=  prefix + 'uslc'  // цены на услуги на конкретный год
  if hb_vfExists(dir_spavoch + sbase + sdbf)
    index_usl_name :=  prefix + 'uslu'  // 
    file_index := cur_dir + sbase + sntx

    R_Use(dir_spavoch + sbase, , 'LUSLC')
    index on shifr + str(vzros_reb, 1) + str(depart, 3) + dtos(datebeg) to (cur_dir + sbase) ;
              for codemo == glob_mo[_MO_KOD_TFOMS]
    index on codemo + shifr + str(vzros_reb, 1) + str(depart, 3) + dtos(datebeg) to (cur_dir + index_usl_name) ;
              for codemo == glob_mo[_MO_KOD_TFOMS] // для совместимости со старой версией справочника
  
    close databases
  endif
  return nil

// 09.03.23
function uslf_Index(val_year, dir_spavoch, cur_dir, flag)
  local sbase
  local lIndex := .f.
  local file_index
  
  DEFAULT flag TO .f.
  sbase := prefixFileRefName(val_year) + 'uslf'  // справочник услуг ФФОМС на конкретный год
  if hb_vfExists(dir_spavoch + sbase + sdbf)
    file_index := cur_dir + sbase + sntx
    R_Use(dir_spavoch + sbase, , 'LUSLF')
    index on shifr to (cur_dir + sbase)
    use
  endif
  return nil

// 09.03.23
function unit_Index(val_year, dir_spavoch, cur_dir, flag)
  local sbase
  local file_index
      
  DEFAULT flag TO .f.
  sbase := prefixFileRefName(val_year) + 'unit'  // план-заказ на конкретный год
  if hb_vfExists(dir_spavoch + sbase + sdbf)
    file_index := cur_dir + sbase + sntx
    R_Use(dir_spavoch + sbase )
    index on str(code, 3) to (cur_dir + sbase)
    use
  endif
  return nil

// 05.11.23
function k006_index(val_year, dir_spavoch, cur_dir, flag)
  local sbase
  local file_index

  DEFAULT flag TO .f.

  sbase := prefixFileRefName(val_year) + 'k006'  // 
  if hb_vfExists(dir_spavoch + sbase + sdbf) .and. hb_vfExists(dir_spavoch + sbase + sdbt)
    file_index := cur_dir + sbase + sntx
    R_Use(dir_spavoch + sbase)
    index on substr(shifr, 1, 2) + ds + sy + age + sex + los to (cur_dir + sbase) // по диагнозу/операции
    index on substr(shifr, 1, 2) + sy + ds + age + sex + los to (cur_dir + sbase + '_') // по операции/диагнозу
    index on ad_cr to (cur_dir + sbase + 'AD') // по дополнительному критерию Байкин
    // index on ad_cr1 to (cur_dir + sbase + 'AD1') // по диапазону фракций, на будующее
    use
  endif
  return nil