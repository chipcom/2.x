#include 'common.ch'
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'chip_lis.ch'

// 23.12.17
Function import_from_LIS()
  Local full_o79
  
  Private p_var_manager := 'Read_from_LIS', cFileProtokol := cur_dir + 'protokol' + stxt
  //full_o79 := manager(T_ROW, T_COL + 5,maxrow()-2, ,.t., 1, , , ,'export*.o79')
  full_o79 := manager(T_ROW, T_COL + 5, maxrow() - 2, , .t., 1, , , , '*.?79')
  if !empty(full_o79) .and. hb_FileExists(full_o79)
    hb_vfErase(cur_dir + cFileProtokol)
    G_SPlus(f_name_task(X_OMS)) // плюс 1 пользователь зашёл в задачу ОМС
    if G_SIsLock(sem_vagno_task[X_OMS])
      f_err_sem_vagno_task(X_OMS)
    elseif lower(right(full_o79, 3)) == 'x79' // XML-файл
      f1_impXML_from_LIS(full_o79)
    elseif lower(right(full_o79, 3)) == 'o79' // текстовый файл с разделителями
      f1_import_from_LIS(full_o79)
    endif
    G_SMinus(f_name_task(X_OMS))  // минус 1 пользователь (вышел из задачи ОМС)
    if hb_FileExists(cur_dir + cFileProtokol)
      viewtext(Devide_Into_Pages(cur_dir + cFileProtokol, 60, 80), , , , .t., , , 2)
    endif
  endif
  return NIL
  
// 12.09.23
Function f1_impXML_from_LIS(name_file)
  Local buf := save_maxrow(), aerr := {}, arr, fl_exit := .f., fl := .f., i, j, t1, t2, s, s1

  if !hb_FileExists(dir_server + 'mo_flis' + sdbf)
    dbcreate(dir_server + 'mo_flis', { ; // Список принятых файлов из ЛИС
      {'KOD',         'N', 6, 0}, ; // код;номер записи
      {'FNAME',       'C', 50, 0}, ; // имя файла
      {'DREAD',       'D', 8, 0}, ; // дата чтения
      {'TREAD1',      'C', 5, 0}, ; // время начала чтения
      {'TREAD2',      'C', 5, 0}, ; // время окончания чтения
      {'KOLP',        'N', 6, 0}, ; // количество пациентов
      {'KOLS',        'N', 6, 0}, ; // количество случаев
      {'KOLU',        'N', 6, 0} ;  // количество услуг
    })
  endif
  sname := StripPath(name_file)
  G_Use(dir_server + 'mo_flis', , 'FL')
  index on upper(fname) to tmp_fl
  find (padr(upper(sname), 50))
  if found()
    if empty(fl->tread2)
      fl := f_alert({'Файл "' + alltrim(sname) + '".', ;
                     'Чтение начато ' + date_8(fl->dread) + ' в ' + fl->tread1 + ' и не было завершено.', ;
                     '', ;
                     'Выберите действие:'}, ;
                    {' Выход ', ' Попытка повторного чтения '}, ;
                    1, 'GR+/R', 'W+/R', , , 'GR+/R,N/BG') == 2
    else
      func_error(4, 'Файл ' + alltrim(sname) + ' уже был прочитан ' + date_8(fl->dread) + ' в ' + fl->tread2)
    endif
  else
    fl := .t.
  endif
  if fl .and. f_Esc_Enter('чтения файла из ЛИС')
    select FL
    G_RLock(!found(), forever) // добавить ИЛИ заблокировать запись
    fl->KOD := recno()
    fl->FNAME := upper(sname)
    fl->DREAD := sys_date
    fl->TREAD1 := hour_min(seconds())
    fl->TREAD2 := ''
    fl->KOLP := fl->KOLS := fl->KOLU := 0
    UnLock
    Commit
    //
    t1 := seconds()
    @ maxrow(), 0 say padl(sname, 80) color 'W/R'
    R_Use(dir_exe + '_mo_mkb', cur_dir + '_mo_mkb', 'MKB_10')
    use_base('lusl')
    use_base('luslc')
    Use_base('uslugi')
    R_Use(dir_exe + '_mo_prof', cur_dir + '_mo_prof', 'MOPROF')
    R_Use(dir_server + 'uslugi1', {dir_server + 'uslugi1', ;
                                  dir_server + 'uslugi1s'}, 'USL1')
    // R_Use(dir_exe+'_mo_N012', ,'N12')
    G_Use(dir_server + 'mo_onkco', dir_server + 'mo_onkco', 'CO')
    G_Use(dir_server + 'mo_onksl', dir_server + 'mo_onksl', 'SL')
    G_Use(dir_server + 'mo_onkdi', dir_server + 'mo_onkdi', 'DIAG') // Диагностический блок
    G_Use(dir_server + 'human_u_', , 'HU_')
    index on padr(zf, 30) to (cur_dir + 'tmp_hu_') progress
    set order to 0
    G_Use(dir_server + 'human_u', {dir_server + 'human_u', ;
                                  dir_server + 'human_uk', ;
                                  dir_server + 'human_ud', ;
                                  dir_server + 'human_uv', ;
                                  dir_server + 'human_ua'}, 'HU')
    G_Use(dir_server + 'human_', , 'HUMAN_')
    G_Use(dir_server + 'human_2', , 'HUMAN_2')
    //index on str(pn3, 10) to (cur_dir + 'tmp_human2') progress
    G_Use(dir_server + 'human', {dir_server + 'humank', ;
                                dir_server + 'humankk', ;
                                dir_server + 'humann', ;
                                dir_server + 'humand', ;
                                dir_server + 'humano', ;
                                dir_server + 'humans'}, 'HUMAN')
    G_Use(dir_server + 'mo_pers', , 'PERSO')
    index on snils to (cur_dir + 'tmp_pers')
    set index to (cur_dir + 'tmp_pers'), (dir_server + 'mo_pers')
    G_Use(dir_server + 'mo_kfio', , 'KFIO')
    index on str(kod, 7) to (cur_dir + 'tmp_kfio')
    G_Use(dir_server + 'mo_kismo', , 'KSN')
    index on str(kod, 7) to (cur_dir + 'tmpkismo')
    G_Use(dir_server + 'mo_hismo', , 'HSN')
    index on str(kod, 7) to (cur_dir + 'tmphismo')
    G_Use(dir_server + 'kartote_', , 'KART_')
    G_Use(dir_server + 'kartote2', , 'KART2')
    index on kod_AK to (cur_dir + 'tmp_kart2') progress
    G_Use(dir_server + 'kartotek', {dir_server + 'kartotek', ;
                                   dir_server + 'kartoten', ;
                                   dir_server + 'kartotep', ;
                                   dir_server + 'kartoteu', ;
                                   dir_server + 'kartotes'}, 'KART')
    Private such := 1, sotd := 1, ; // код отделения 'Лаборатория-ЛИС на Ангарском'
            sotd2 := 3 // код отделения 'ЛИС в Краснооктябрьском р-не'
            //sotd4 := 4   // код отделения 'ЛИС на Елецкой'
    Private _arr_otd := {{'MIH', 1}, {'ANG', 2}, {'MET', 3}, {'ELE', 4}}
    for i := 1 to len(_arr_otd)
      if _arr_otd[i, 1] $ upper(name_file)
        sotd2 := i
        exit
      endif
    next
    dbcreate('ttmp', { ;
      {'nn', 'N', 6, 0}, ;
      {'ko', 'N', 6, 0}, ;
      {'ko1', 'N', 6, 0}, ;
      {'ku', 'N', 6, 0}, ;
      {'ku1', 'N', 6, 0}, ;
      {'t2', 'N', 7, 3}, ;
      {'t3', 'N', 7, 3}, ;
      {'t4', 'N', 7, 3}, ;
      {'fc', 'C', 1, 0}})
    use ttmp new alias TMP
    Private arr_pac[15], arr_order, arr_usl := {}, ip := 0, is := 0, isp := 0, iu := 0
    glob_podr := '' ; glob_otd_dep := 0
    fl_exit := .f.
    // читаем XML-файл
    lfp := fopen(name_file)
    do while !feof(lfp)
      s := Utf82Oem(fReadLn(lfp))
      if '<PAT ' $ s
        arr := {s}
        do while !feof(lfp)
          s := fReadLn(lfp)
          aadd(arr, s)
          if '</PAT>' $ s
            exit
          endif
        enddo
        if !empty(aerr := f2_impXML_from_LIS(arr))
          fl_exit := .t.
          exit
        endif
      endif
      if inkey() == K_ESC
        fl_exit := .t.
        exit
      endif
    enddo
    fclose(lfp)
    if !fl_exit
      select FL
      G_RLock(forever) // заблокировать запись
      fl->TREAD2 := hour_min(seconds())
      fl->KOLP := ip
      fl->KOLS := is
      fl->KOLU := iu
    endif
    dbUnlockAll()
    dbCommitAll()
    close databases
    keyboard ''
    t2 := seconds() - t1
    rest_box(buf)
    if fl_exit
      arr := aclone(aerr)
      if !empty(arr)
        Ins_Array(arr, 1, 'Ошибка в файле "' + alltrim(sname) + '":')
      endif
      aadd(arr, '')
      aadd(arr, 'Операция импорта прервана!')
    else
      arr := {'Файл "' + alltrim(sname) + '" импортирован.', ;
              '', ;
              'Время работы - ' + sectotime(t2) + '.', ;
              '', ;
              'Пациентов ' + lstr(ip) + ', случаев ' + lstr(is) + iif(isp == 0, '', ' (в т.ч.повторно ' + lstr(isp) + ')') + ', услуг ' + lstr(iu) + '.'}
    endif
    n_message(arr, , 'GR+/R', 'W+/R', , , 'G+/R')
  endif
  close databases
  rest_box(buf)
  return NIL
  
// 03.05.17
Function f1_import_from_LIS(name_file)
  Local buf := save_maxrow(), aerr := {}, arr, fl_exit, fl := .f., i, j, t1, t2, s, s1, iencode

  if !hb_FileExists(dir_server + "mo_flis" + sdbf)
    dbcreate(dir_server + "mo_flis", { ; // Список принятых файлов из ЛИС
      {"KOD",         "N", 6, 0}, ; // код;номер записи
      {"FNAME",       "C", 50, 0}, ; // имя файла
      {"DREAD",       "D", 8, 0}, ; // дата чтения
      {"TREAD1",      "C", 5, 0}, ; // время начала чтения
      {"TREAD2",      "C", 5, 0}, ; // время окончания чтения
      {"KOLP",        "N", 6, 0}, ; // количество пациентов
      {"KOLS",        "N", 6, 0}, ; // количество случаев
      {"KOLU",        "N", 6, 0};  // количество услуг
    })
  endif
  sname := StripPath(name_file)
  G_Use(dir_server + "mo_flis", , "FL")
  index on upper(fname) to tmp_fl
  find (padr(upper(sname), 50))
  if found()
    if empty(fl->tread2)
      fl := f_alert({'Файл "' + alltrim(sname) + '".', ;
                     "Чтение начато " + date_8(fl->dread) + " в " + fl->tread1 + " и не было завершено.", ;
                     "", ;
                     "Выберите действие:"}, ;
                    {" Выход ", " Попытка повторного чтения "}, ;
                    1, "GR+/R", "W+/R", , , "GR+/R, N/BG") == 2
    else
      func_error(4, "Файл " + alltrim(sname) + " уже был прочитан " + date_8(fl->dread) + " в " + fl->tread2)
    endif
  else
    fl := .t.
  endif
  if fl .and. f_Esc_Enter("чтения файла из ЛИС") .and. (iencode := f_define_LIS_coding(name_file)) > 0
    G_RLock(!found(), forever) // добавить ИЛИ заблокировать запись
    fl->KOD := recno()
    fl->FNAME := upper(sname)
    fl->DREAD := sys_date
    fl->TREAD1 := hour_min(seconds())
    fl->TREAD2 := ""
    fl->KOLP := fl->KOLS := fl->KOLU := 0
    UnLock
    Commit
    //
    t1 := seconds()
    @ maxrow(), 0 say padl(sname, 80) color "W/R"
    R_Use(dir_exe + "_mo_mkb", cur_dir + "_mo_mkb", "MKB_10")
    use_base("lusl")
    use_base("luslc")
    Use_base("uslugi")
    R_Use(dir_exe + "_mo_prof", cur_dir + "_mo_prof", "MOPROF")
    R_Use(dir_server + "uslugi1", {dir_server + "uslugi1", ;
                                  dir_server + "uslugi1s"}, "USL1")
    Use_base("human_u")
    G_Use(dir_server + "human_", , "HUMAN_")
    G_Use(dir_server + "human_2", , "HUMAN_2")
    index on str(pn3, 10) to (cur_dir + "tmp_human2")
    G_Use(dir_server + "human", {dir_server + "humank", ;
                                dir_server + "humankk", ;
                                dir_server + "humann", ;
                                dir_server + "humand", ;
                                dir_server + "humano", ;
                                dir_server + "humans"},"HUMAN")
    G_Use(dir_server + "mo_pers", , "PERSO")
    index on snils to (cur_dir + "tmp_pers")
    set index to (cur_dir + "tmp_pers"), (dir_server + "mo_pers")
    G_Use(dir_server + "mo_kfio", , "KFIO")
    index on str(kod, 7) to (cur_dir + "tmp_kfio")
    G_Use(dir_server + "mo_kismo", , "KSN")
    index on str(kod, 7) to (cur_dir + "tmpkismo")
    G_Use(dir_server + "mo_hismo", , "HSN")
    index on str(kod, 7) to (cur_dir + "tmphismo")
    G_Use(dir_server + "kartote_", , "KART_")
    G_Use(dir_server + "kartote2", , "KART2")
    index on kod_AK to (cur_dir + "tmp_kart2")
    G_Use(dir_server + "kartotek", {dir_server + "kartotek", ;
                                   dir_server + "kartoten", ;
                                   dir_server + "kartotep", ;
                                   dir_server + "kartoteu", ;
                                   dir_server + "kartotes"}, "KART")
    Private such := 1, sotd := 1 // код отделения "Лаборатория-ЛИС на Ангарском"
    if left(fl->FNAME, 4) == "LAB2"
      sotd := 3 // код отделения "ЛИС в Краснооктябрьском р-не"
    endif
    Private arr_pac := {}, arr_order := {}, arr_usl := {}, ip := 0, is := 0, isp := 0, iu := 0
    glob_podr := ""
    glob_otd_dep := 0
    fl_exit := .f.
    ft_use(name_file)
    ft_gotop()
    do while !ft_eof()
      if !empty( s := ft_ReadLn() )
        if iencode == 1
          s := hb_AnsiToOem(s)
        else
          s := Utf82Oem(s)
        endif
        if upper(left(s, 3)) == "PAT"
          if !empty(arr_pac)
            if !empty(aerr := f2_import_from_LIS(1))
              fl_exit := .t.
              exit
            endif
            arr_pac := {}
            arr_order := {}
          endif
          for i := 2 to numtoken(s, ";", 1)
            s1 := alltrim(token(s, ";", i, 1))
            aadd(arr_pac, s1)
          next
          do while len(arr_pac) < 15 // добавим пустые поля (вдруг что-то не так со строкой)
            aadd(arr_pac, " ")
          enddo
        elseif upper(left(s, 5)) == "ORDER"
          aadd(arr_order, {}) ; j := len(arr_order)
          for i := 2 to numtoken(s, ";", 1)
            s1 := alltrim(token(s, ";", i, 1))
            aadd(arr_order[j], s1)
          next
          do while len(arr_order[j]) < 6 // 5 И 6 ЭЛЕМЕНТЫ ДЛЯ СРОКОВ ЛЕЧЕНИЯ
            aadd(arr_order[j], " ")
          enddo
          arr_order[j, 4] := {} // для занесения услуг
        elseif upper(left(s, 4)) == "EXAM" .and. len(arr_order) > 0
          arr := {}
          for i := 2 to numtoken(s, ";", 1)
            s1 := alltrim(token(s, ";", i, 1))
            aadd(arr, s1)
          next
          do while len(arr) < 7
            aadd(arr, " ")
          enddo
          aadd(arr_order[j, 4],aclone(arr))
        endif
      endif
      ft_skip()
    enddo
    ft_use()
    if !fl_exit .and. !empty(arr_pac) .and. !empty(aerr := f2_import_from_LIS(1))
      fl_exit := .t.
    endif
    if !fl_exit
      select FL
      G_RLock(forever) // заблокировать запись
      fl->TREAD2 := hour_min(seconds())
      fl->KOLP := ip
      fl->KOLS := is
      fl->KOLU := iu
    endif
    dbUnlockAll()
    dbCommitAll()
    close databases
    t2 := seconds() - t1
    rest_box(buf)
    if fl_exit
      arr := aclone(aerr)
      Ins_Array(arr, 1, 'Ошибка в файле "' + alltrim(sname) + '":')
      aadd(arr, "")
      aadd(arr, "Операция импорта прервана!")
    else
      arr := {'Файл "' + alltrim(sname) + '" импортирован.', ;
              "", ;
              "Время работы - " + sectotime(t2) + ".", ;
              "", ;
              "Пациентов " + lstr(ip) + ", случаев " + lstr(is) + iif(isp == 0, "", " (в т.ч.повторно " + lstr(isp) + ")") + ", услуг " + lstr(iu) + "."}
    endif
    n_message(arr, , "GR+/R", "W+/R", , , "G+/R")
  endif
  close databases
  rest_box(buf)
  return NIL
  
// 28.04.20
Function f2_impXML_from_LIS(ta)
  Static arr[LISU_D_RSLT]
  Local i, j := 1, s
  s := afteratnum('Pat_code="', ta[1]) ; arr_pac[LIS_KOD_AK ] := beforatnum('"', s, 1)
  s := afteratnum('Last_name="', s)    ; arr_pac[LIS_FAM    ] := beforatnum('"', s, 1)
  s := afteratnum('First_name="', s)   ; arr_pac[LIS_IMA    ] := beforatnum('"', s, 1)
  s := afteratnum('Father_name="', s)  ; arr_pac[LIS_OTS    ] := beforatnum('"', s, 1)
  s := afteratnum('Birth_date="', s)   ; arr_pac[LIS_DATE_R ] := beforatnum('"', s, 1)
  s := afteratnum('Sex="', s)          ; arr_pac[LIS_POL    ] := beforatnum('"', s, 1)
  s := afteratnum('OMS_type="', s)     ; arr_pac[LIS_VPOLIS ] := beforatnum('"', s, 1)
  s := afteratnum('OMS_series="', s)   ; arr_pac[LIS_SPOLIS ] := beforatnum('"', s, 1)
  s := afteratnum('OMS_number="', s)   ; arr_pac[LIS_NPOLIS ] := beforatnum('"', s, 1)
  s := afteratnum('Ins_OKATO="', s)    ; arr_pac[LIS_OKATO  ] := beforatnum('"', s, 1)
  s := afteratnum('UDL_type="', s)     ; arr_pac[LIS_VID_UD ] := beforatnum('"', s, 1)
  s := afteratnum('UDL_series="', s)   ; arr_pac[LIS_SER_UD ] := beforatnum('"', s, 1)
  s := afteratnum('UDL_number="', s)   ; arr_pac[LIS_NOM_UD ] := beforatnum('"', s, 1)
  s := afteratnum('Birth_place="', s)  ; arr_pac[LIS_MESTO_R] := beforatnum('"', s, 1)
  s := afteratnum('SNILS="', s)        ; arr_pac[LIS_SNILS  ] := beforatnum('"', s, 1)
  arr_order := {}
  for i := 2 to len(ta)
    ta[i] := ltrim(ta[i])
    if left(ta[i], 7) == "<ORDER "
      aadd(arr_order, {}) ; j := len(arr_order)
      s := afteratnum('Number="', ta[i])  ; aadd(arr_order[j], beforatnum('"', s, 1))
      s := afteratnum('DS="', s)          ; aadd(arr_order[j], beforatnum('"', s, 1))
      s := afteratnum('Sender_code="', s) ; aadd(arr_order[j], beforatnum('"', s, 1))
      aadd(arr_order[j], {}) // для занесения услуг
      aadd(arr_order[j], " ") // 5 И 6 ЭЛЕМЕНТЫ ДЛЯ СРОКОВ ЛЕЧЕНИЯ
      aadd(arr_order[j], " ")
      aadd(arr_order[j], sotd)
    endif
    if left(ta[i], 6) == "<EXAM "
      afill(arr, "")
      s := afteratnum('ExamID="', ta[i]) ; arr[LISU_ID   ] := beforatnum('"', s, 1)
      s := afteratnum('Exam_code="', s)  ; arr[LISU_SHIFR] := beforatnum('"', s, 1)
      s := afteratnum('Exec_date="', s)  ; arr[LISU_DATE ] := beforatnum('"', s, 1)
      s := afteratnum('Doc_spec="', s)   ; arr[LISU_SPEC ] := beforatnum('"', s, 1)
      s := afteratnum('Doc_SNILS="', s)  ; arr[LISU_SNILS] := beforatnum('"', s, 1)
      if 'Diag_rslt' $ s
        s := afteratnum('Diag_rslt="', s) ; arr[LISU_D_RSLT] := beforatnum('"', s, 1)
      endif
      if j <= len(arr_order)
        aadd(arr_order[j, 4], aclone(arr))
      endif
    endif
  next j
  return f2_import_from_LIS(2)
  
// 28.04.20
Function f2_import_from_LIS(par)
  Static siu := 0, jsiu := 0
  Local i, j, k, fl, afio[3], mfio, aerr := {}, tmp_arr := {}, arr_unit, lvzros_reb, i_738, i_739
  Local t1, t2, t3, t4, ku := 0, ku1 := 0, is_mgi, ko := len(arr_order)
  t1 := seconds()
  ++ip
  afio[1] := f_LIS_fio(arr_pac[LIS_FAM], 1)
  afio[2] := f_LIS_fio(arr_pac[LIS_IMA], 2)
  afio[3] := f_LIS_fio(arr_pac[LIS_OTS], 3)
  mfio := afio[1]+" "+afio[2]+" "+afio[3]
  if empty(int(val(arr_pac[LIS_KOD_AK])))
    aadd(aerr, "Некорректный код PAT у пациента - "+mfio)
    return aerr
  endif
  if !val_fio(afio,aerr)
    aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'"')
    return aerr
  endif
  arr_pac[LIS_DATE_R] := ctod(arr_pac[LIS_DATE_R])
  if empty(arr_pac[LIS_DATE_R])
    aadd(aerr,"Некорректная дата рождения у пациента")
    aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'"')
    return aerr
  endif
  arr_pac[LIS_POL] := iif(arr_pac[LIS_POL]=="M", "М", "Ж")
  f_LIS_polis()
  f_LIS_pasport()
  arr_pac[LIS_SNILS] := charrem("- ",arr_pac[LIS_SNILS])
  for j := 1 to len(arr_order)
    arr_order[j,LISS_KOD] := int(val(arr_order[j,LISS_KOD]))
    if empty(arr_order[j,LISS_KOD])
      aadd(aerr,"Некорректный ORDER у пациента")
      aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'"')
      return aerr
    endif
    if empty(arr_order[j,LISS_MO])
      aadd(aerr,"Не заполнена направляющая мед.организация у пациента")
      aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER=' + lstr(arr_order[j,LISS_KOD])+')')
      return aerr
    elseif (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_FFOMS] == arr_order[j,LISS_MO] })) == 0
      aadd(aerr,"В справочнике МО не найдена направляющая мед.организация "+arr_order[j,LISS_MO]+" у пациента")
      aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER=' + lstr(arr_order[j,LISS_KOD])+')')
      return aerr
    else
      arr_order[j,LISS_MO] := ret_mo(arr_order[j,LISS_MO])[_MO_KOD_TFOMS]
    endif
    //asort(arr_order[j,LISS_USL], ,,{|x,y| iif(x[2] == y[2], fsort_usl(x[1]) < fsort_usl(y[1]), x[2] < y[2])})
    i_738 := i_739 := 0
    if len(arr_order[j,LISS_USL]) == 0
      aadd(aerr,"Не введены услуги у пациента")
      aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER=' + lstr(arr_order[j,LISS_KOD])+')')
      return aerr
    endif
    for i := 1 to len(arr_order[j,LISS_USL])
      ++iu
      ++ku
      if empty(arr_order[j,LISS_USL, i,LISU_SHIFR])
        aadd(aerr, "Не введена услуга у пациента")
        aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER=' + lstr(arr_order[j,LISS_KOD])+')')
        return aerr
      endif
      if par == 2 // по-новому / из XML-файла / ключевое поле - ID услуги
        if empty(arr_order[j,LISS_USL, i,LISU_ID])
          aadd(aerr,"Некорректное значение ExamID в услуге "+arr_order[j,LISS_USL, i,LISU_SHIFR]+" у пациента")
          aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER=' + lstr(arr_order[j,LISS_KOD])+')')
          return aerr
        endif
        //if eq_any(left(arr_order[j,LISS_USL, i,LISU_SHIFR], 5),"4.16.","4.17.")
          //arr_order[j,LISS_OTD] := sotd2 // код отделения в Краснооктябрьском р-не
        //endif
      endif
      select LUSL
      find (padr(arr_order[j,LISS_USL, i,LISU_SHIFR], 10))
      if found()
        arr_order[j,LISS_USL, i,LISU_UNIT] := lusl->unit_code
      else
        aadd(aerr, "В справочнике не найдена услуга "+arr_order[j,LISS_USL, i,LISU_SHIFR]+" у пациента")
        aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER=' + lstr(arr_order[j,LISS_KOD])+')')
        return aerr
      endif
      if left(arr_order[j,LISS_USL, i,LISU_SHIFR], 5) == "60.9." .and. !(left(arr_order[j,LISS_DIAG], 1) == "C")
        aadd(aerr, "Для МГИ диагноз должен быыть ОНКОЛОГИЯ у пациента")
        aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER=' + lstr(arr_order[j,LISS_KOD])+')')
        return aerr
      endif
      if arr_order[j,LISS_USL, i,LISU_SHIFR] == "4.11.738"
        i_738 := i
      elseif arr_order[j,LISS_USL, i,LISU_SHIFR] == "4.11.739"
        i_739 := i
      endif
      arr_order[j,LISS_USL, i,LISU_DATE] := ctod(arr_order[j,LISS_USL, i,LISU_DATE])
      if empty(arr_order[j,LISS_USL, i,LISU_DATE])
        aadd(aerr, "Некорректная дата услуги у пациента")
        aadd(aerr,"PAT="+arr_pac[LIS_KOD_AK]+' "'+mfio+'" (ORDER=' + lstr(arr_order[j,LISS_KOD])+')')
        return aerr
      endif
      if empty(arr_order[j,LISS_NDATA])
        arr_order[j,LISS_NDATA] := arr_order[j,LISS_KDATA] := arr_order[j,LISS_USL, i,LISU_DATE]
      else
        arr_order[j,LISS_NDATA] := min(arr_order[j,LISS_NDATA],arr_order[j,LISS_USL, i,LISU_DATE])
        arr_order[j,LISS_KDATA] := max(arr_order[j,LISS_KDATA],arr_order[j,LISS_USL, i,LISU_DATE])
      endif
      arr_order[j,LISS_USL, i,LISU_SPEC] := int(val(arr_order[j,LISS_USL, i,LISU_SPEC]))
      if ascan(getV004(), {|x| x[2] == arr_order[j, LISS_USL, i, LISU_SPEC] }) == 0
        arr_order[j, LISS_USL, i, LISU_SPEC] := 1107 // Клиническая лабораторная диагностика
      endif
      arr_order[j,LISS_USL, i,LISU_SNILS] := charrem("- ",arr_order[j,LISS_USL, i,LISU_SNILS])
      if empty(arr_order[j,LISS_USL, i,LISU_SNILS])
        arr_order[j,LISS_USL, i,LISU_SNILS] := 0
      else
        select PERSO
        set order to 1
        find (padr(arr_order[j,LISS_USL, i,LISU_SNILS], 11))
        if !found()
          set order to 2
          AddRec(5)
          perso->kod := recno()
          perso->tab_nom := -perso->kod
          perso->fio  := "Сотрудник с кодом " + lstr(perso->kod)
          perso->uch  := such
          perso->otd  := sotd2
          //if par == 1
            //perso->otd := sotd
          //else
            //perso->otd := arr_order[j,LISS_OTD]
          //endif
          perso->prvs := arr_order[j,LISS_USL, i,LISU_SPEC]
          perso->snils := arr_order[j,LISS_USL, i,LISU_SNILS]
        endif
        arr_order[j,LISS_USL, i,LISU_SPEC] := perso->prvs
        arr_order[j,LISS_USL, i,LISU_SNILS] := perso->kod
      endif
    next i
    if i_738 > 0 .and. i_739 > 0 // если встречаются в одном случае "4.11.738" и "4.11.739"
      Del_Array(arr_order[j,LISS_USL], i_738) // то удаляем "4.11.738" (она дешевле)
    endif
  next
  t2 := seconds()
  Private mdate_r, m1vzros_reb := 0, M1NOVOR := 0, mprofil
  select KART2
  set order to 1
  find (padr(arr_pac[LIS_KOD_AK], 10))
  if found()
    lkod_k := recno()
    select KART
    set order to 0
    goto (lkod_k)
    select KART_
    goto (lkod_k)
  else
    select KART
    set order to 1
    Add1Rec(7)
    lkod_k := kart->kod := recno()
    kart->FIO := mfio
    kart->DATE_R := arr_pac[LIS_DATE_R]
    mdate_r := kart->DATE_R
    fv_date_r()
    kart->pol := arr_pac[LIS_POL]
    kart->VZROS_REB := m1VZROS_REB
    kart->POLIS := make_polis(arr_pac[LIS_SPOLIS],arr_pac[LIS_NPOLIS])
    kart->snils := arr_pac[LIS_SNILS]
    if TwoWordFamImOt(afio[1]) .or. TwoWordFamImOt(afio[2]) .or. TwoWordFamImOt(afio[3])
      kart->MEST_INOG := 9
    else
      kart->MEST_INOG := 0
    endif
    //
    dbf_equalization("KART_",lkod_k)
    kart_->VPOLIS := arr_pac[LIS_VPOLIS]
    kart_->SPOLIS := arr_pac[LIS_SPOLIS]
    kart_->NPOLIS := arr_pac[LIS_NPOLIS]
    kart_->vid_ud := arr_pac[LIS_VID_UD]
    kart_->ser_ud := arr_pac[LIS_SER_UD]
    kart_->nom_ud := arr_pac[LIS_NOM_UD]
    kart_->mesto_r:= arr_pac[LIS_MESTO_R]
    kart_->okatog := arr_pac[LIS_OKATO]
    kart_->okatop := kart_->okatog
    if left(kart_->okatog, 2) == "18" // Волгоградская область
      kart_->SMO := "34007" // ООО "РГС-Медицина"
    else
      kart_->SMO := "34"    // ТФОМС
      kart_->KVARTAL_D := left(kart_->okatog, 5) // ОКАТО субъекта РФ территории страхования
    endif
    //
    select KART2
    set order to 0
    dbf_equalization("KART2",lkod_k)
    kart2->kod_tf := 0
    kart2->kod_mis := ""
    kart2->kod_AK := arr_pac[LIS_KOD_AK]  // ключевое поле !!!
    kart2->MO_PR := ""
    kart2->TIP_PR := 0
    kart2->DATE_PR := ctod("")
    kart2->SNILS_VR := "" // уч.врач ещё не привязан
    kart2->PC1 := kod_polzovat+c4sys_date+hour_min(seconds())
    kart2->PC2 := ""
    kart2->PC3 := ""
    kart2->PC4 := ""
    //
    select KFIO
    find (str(lkod_k, 7))
    if found()
      if kart->MEST_INOG == 9
        G_RLock(forever)
        kfio->FAM := afio[1]
        kfio->IM  := afio[2]
        kfio->OT  := afio[3]
      else
        DeleteRec(.t.)
      endif
    else
      if kart->MEST_INOG == 9
        AddRec(7)
        kfio->kod := lkod_k
        kfio->FAM := afio[1]
        kfio->IM  := afio[2]
        kfio->OT  := afio[3]
      endif
    endif
  endif
  if par == 1 // по-старому / из текстового файла / ключевое поле - номер наряда-заказа
    for j := 1 to len(arr_order)
      select HUMAN_2
      set order to 1
      find (str(arr_order[j,LISS_KOD], 10))
      if found()
        arr_order[j,LISS_KOD] := 0 // т.е. данный случай заносили
      endif
    next
  endif
  for j := 1 to len(arr_order) // разбивка случаев по план-заказу
    arr_unit := {}
    for i := 1 to len(arr_order[j,LISS_USL])
      if ascan(arr_unit,arr_order[j,LISS_USL, i,LISU_UNIT]) == 0
        aadd(arr_unit,arr_order[j,LISS_USL, i,LISU_UNIT])
      endif
    next
    if len(arr_unit) > 1
      for k := 1 to len(arr_unit)
        if par == 1
          aadd(tmp_arr,{arr_order[j, 1],arr_order[j, 2],arr_order[j, 3],{},ctod(""),ctod("")})
        else
          aadd(tmp_arr,{arr_order[j, 1],arr_order[j, 2],arr_order[j, 3],{},ctod(""),ctod(""),arr_order[j, 7]})
        endif
        n := len(tmp_arr)
        for i := 1 to len(arr_order[j,LISS_USL])
          if arr_unit[k] == arr_order[j,LISS_USL, i,LISU_UNIT]
            aadd(tmp_arr[n,LISS_USL],aclone(arr_order[j,LISS_USL, i]))
            if empty(tmp_arr[n,LISS_NDATA])
              tmp_arr[n,LISS_NDATA] := tmp_arr[n,LISS_KDATA] := arr_order[j,LISS_USL, i,LISU_DATE]
            else
              tmp_arr[n,LISS_NDATA] := min(tmp_arr[n,LISS_NDATA],arr_order[j,LISS_USL, i,LISU_DATE])
              tmp_arr[n,LISS_KDATA] := max(tmp_arr[n,LISS_KDATA],arr_order[j,LISS_USL, i,LISU_DATE])
            endif
          endif
        next
      next
    else
      aadd(tmp_arr,aclone(arr_order[j]))
    endif
  next
  arr_order := aclone(tmp_arr) ; tmp_arr := nil
  t3 := seconds()
  if par == 2 // по-новому / из XML-файла / ключевое поле - ID услуги
    select HU_
    set order to 1
    for j := 1 to len(arr_order)
      for i := 1 to len(arr_order[j,LISS_USL])
        find (padr(arr_order[j,LISS_USL, i,LISU_ID], 30))
        if found() // данную услугу уже заносили
          arr_order[j,LISS_KOD] := 0 // значит считаем, что данный случай также заносили
          exit
        endif
      next i
    next j
    set order to 0
  endif
  select HUMAN
  set order to 1
  select HUMAN_2
  set order to 0
  aat := {}
  for j := 1 to len(arr_order)
    ++is
    if arr_order[j,LISS_KOD] == 0 .or. len(arr_order[j,LISS_USL]) == 0
      ++isp
    else // т.е. данный случай ещё не заносили
      lvzros_reb := 1 // ребенок по умолчанию
      if (k := count_years(kart->DATE_R,arr_order[j,LISS_NDATA])) < 14
        m1vzros_reb := 1  // ребенок
      elseif k < 18
        m1vzros_reb := 2  // подросток
      else
        lvzros_reb := m1vzros_reb := 0  // взрослый
      endif
      mprofil := 34
      select MOPROF
      find (padr(arr_order[j,LISS_USL, 1,LISU_SHIFR], 20) + str(lvzros_reb, 1))
      if found()
        mprofil := moprof->profil
      endif
      is_mgi := (left(arr_order[j,LISS_USL, 1,LISU_SHIFR], 5) == "60.9.")
      if is_mgi
        //
      else
        arr_order[j,LISS_DIAG] := "Z01.7" // всегда
      endif
      select HUMAN
      Add1Rec(7)
      mkod := human->kod := recno()
      dbf_equalization("HUMAN_",mkod)
      dbf_equalization("HUMAN_2",mkod)
      //
      human->kod_k      := lkod_k
      human->TIP_H      := B_STANDART
      human->FIO        := kart->FIO          // Ф.И.О. больного
      human->POL        := kart->POL          // пол
      human->DATE_R     := kart->DATE_R       // дата рождения больного
      human->VZROS_REB  := M1VZROS_REB        // 0-взрослый, 1-ребенок, 2-подросток
      human->KOD_DIAG   := arr_order[j,LISS_DIAG]
      human->KOD_DIAG2  := human->KOD_DIAG3 := human->KOD_DIAG4 := ""
      human->SOPUT_B1   := human->SOPUT_B2 := human->SOPUT_B3 := human->SOPUT_B4 := ""
      if len(arr_order[j,LISS_DIAG]) == 6
        human->diag_plus := padr(right(arr_order[j,LISS_DIAG], 1), 8)
      endif
      human->KOMU       := 0
      human->POLIS      := kart->polis
      human->LPU        := such
      human->OTD        := sotd2
      //if par == 1
        //human->OTD      := sotd
      //else
        //human->OTD      := arr_order[j,LISS_OTD]
      //endif
      human->UCH_DOC    := lstr(arr_order[j,LISS_KOD]) // ORDER по ЛИС
      human->N_DATA     := arr_order[j,LISS_NDATA]
      human->K_DATA     := arr_order[j,LISS_KDATA]
      //
      human_->SMO       := kart_->SMO
      human_->VPOLIS    := kart_->VPOLIS
      human_->SPOLIS    := kart_->SPOLIS
      human_->NPOLIS    := kart_->NPOLIS
      if alltrim(human_->smo) == '34'
        human_->OKATO   := kart_->KVARTAL_D
      endif
      human_->NOVOR     := 0
      human_->DATE_R2   := ctod("")
      human_->POL2      := ""
      human_->USL_OK    := 3  // амбулаторно
      human_->VIDPOM    := 13 // первичная специализированная
      human_->PROFIL    := mprofil // клиническая лабораторная диагностика или бактериология
      human_->IDSP      := 4  // лечебно-диагностическая процедура
      human_->NPR_MO    := arr_order[j,LISS_MO]
      human_->KOD_DIAG0 := ""
      human_->RSLT_NEW  := 314 // динамическое наблюдение
      human_->ISHOD_NEW := 304 // без перемен
      human_->VRACH     := 0
      human_->PRVS      := iif(mprofil == 34, -13, -54) // Клиническая лабораторная диагностика
      human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      human_->ID_PAC    := mo_guid(1,human_->(recno()))
      human_->ID_C      := mo_guid(2,human_->(recno()))
      human_->SUMP      := 0
      human_->OPLATA    := 0
      human_->SANK_MEK  := 0
      human_->SANK_MEE  := 0
      human_->SANK_EKMP := 0
      human_->REESTR    := 0
      human_->REES_ZAP  := 0
      human->schet      := 0
      human_->SCHET_ZAP := 0
      human->kod_p   := chr(0)
      human->date_e  := ''
      //
      human_2->NPR_DATE := human->N_DATA
      human_2->OSL1 := human_2->OSL2 := human_2->OSL3 := ""
      human_2->VMP := 0
      human_2->VIDVMP := ""
      human_2->METVMP := 0
      human_2->VNR := human_2->VNR1 := human_2->VNR2 := human_2->VNR3 := 0
      human_2->PC1 := human_2->PC2 := human_2->PC3 := ""
      human_2->PN1 := human_2->PN2 := 0
      human_2->PN3 := arr_order[j,LISS_KOD] // ключевое поле
      sstoim := 0
      for i := 1 to len(arr_order[j,LISS_USL])
        if (n := ascan(arr_usl, {|x| x[1]==arr_order[j,LISS_USL, i,LISU_SHIFR] .and. x[4]==lvzros_reb})) == 0
          ++ku1
          arr_order[j,LISS_USL, i,LISU_CENA] := 0
          arr_order[j,LISS_USL, i,LISU_KODU] := foundOurUsluga(arr_order[j,LISS_USL, i,LISU_SHIFR], ;
                                                              arr_order[j,LISS_KDATA], ;
                                                              mprofil, ;
                                                              m1VZROS_REB, ;
                                                              @arr_order[j,LISS_USL, i,LISU_CENA], 1,.f.)
          aadd(arr_usl,{arr_order[j,LISS_USL, i,LISU_SHIFR], ;
                        arr_order[j,LISS_USL, i,LISU_KODU], ;
                        arr_order[j,LISS_USL, i,LISU_CENA], ;
                        lvzros_reb})
        else
          arr_order[j,LISS_USL, i,LISU_KODU] := arr_usl[n, 2]
          arr_order[j,LISS_USL, i,LISU_CENA] := arr_usl[n, 3]
        endif
        sstoim += arr_order[j,LISS_USL, i,LISU_CENA]
        select HU
        Add1Rec(7)
        hu->kod     := human->kod
        hu->kod_vr  := arr_order[j,LISS_USL, i,LISU_SNILS]
        hu->kod_as  := 0
        hu->u_koef  := 1
        hu->u_kod   := arr_order[j,LISS_USL, i,LISU_KODU]
        hu->u_cena  := arr_order[j,LISS_USL, i,LISU_CENA]
        hu->is_edit := 0
        hu->date_u  := dtoc4(arr_order[j,LISS_USL, i,LISU_DATE])
        hu->otd     := human->OTD
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := arr_order[j,LISS_USL, i,LISU_CENA]
        hu->KOL_RCP := 0
        //
        dbf_equalization("HU_",hu->(recno()))
        hu_->ID_U := mo_guid(3,hu_->(recno()))
        hu_->PROFIL := human_->PROFIL
        hu_->PRVS   := arr_order[j,LISS_USL, i,LISU_SPEC]
        hu_->kod_diag := human->KOD_DIAG
        if par == 2 // по-новому / из XML-файла / ключевое поле - ID услуги
          hu_->zf := arr_order[j,LISS_USL, i,LISU_ID]
        else
          hu_->zf := ""
        endif
        ++siu
      next
      human->CENA := human->CENA_1 := sstoim
      if is_mgi
        human_->VRACH := hu->kod_vr
        f_LIS_mgi(human->kod,arr_order[j])
      endif
      aadd(aat,{seconds(),len(arr_order[j,LISS_USL])})
    endif
  next
  t4 := seconds()
  /*select TMP
  append blank
  tmp->nn := ip
  tmp->ko := ko
  tmp->ko1 := len(arr_order)
  tmp->ku := ku
  tmp->ku1 := ku1
  tmp->t2 := t2-t1
  tmp->t3 := t3-t1
  tmp->t4 := t4-t1
  if tmp->t4 > 5
    k := t3
    for i := 1 to len(aat)
      aat[i, 1] -= k
      k += aat[i, 1]
    next
    my_debug(,lstr(ip)+print_array(aat))
  endif*/
  @ maxrow(), 0 say "пациентов " + lstr(ip) color "G+/R"
  @ row(),col() say "/" color "W/R"
  @ row(),col() say "случаев " + lstr(is) + iif(isp==0,""," (повтор " + lstr(isp) + ")") color cColorSt2Msg
  @ row(),col() say "/" color "W/R"
  @ row(),col() say "услуг " + lstr(iu) color cColorStMsg
  if siu > 500
    //tmp->fc := "t"
    @ maxrow(), 0 say "запись... " color "W/R"
    dbUnlockAll()
    dbCommitAll()
    siu := 0
  endif
  return aerr
  
// 12.09.23 записать онкологическую добавку по МГИ
Function f_LIS_mgi(mkod,ao)
  Local i, ar_N012 := {}
  local aN012_DS := getDS_N012(), it

  select CO
  AddRec(7)
  co->kod := mkod
  co->PR_CONS := 0
  co->DT_CONS := ctod('')
  //
  select SL
  AddRec(7)
  sl->kod := mkod
  sl->DS1_T := 5
  sl->b_diag := 98 // выполнено (результат получен)
  //
  if (i := ascan(glob_MGI, {|x| x[1] == ao[LISS_USL, 1, LISU_SHIFR] })) > 0 // услуга входит в список ТФОМС
    // select N12
    // dbeval({|| aadd(ar_N012, n12->id_igh) }, ;
    //      {|| between_date(n12->datebeg, n12->dateend, ao[LISS_USL, 1, LISU_DATE]) .and. left(human->KOD_DIAG, 3) == n12->ds_igh })
    if (it := ascan(aN012_DS, {|x| left(x[1], 3) == left(human->KOD_DIAG, 3)})) > 0
      ar_N012 := aclone(aN012_DS[it, 2])
    endif

    if ascan(ar_N012, glob_MGI[i, 2]) > 0 // по данному диагнозу присутствует необходимый маркер
      select DIAG
      AddRec(7)
      diag->kod       := mkod
      diag->DIAG_DATE := ao[LISS_USL, 1, LISU_DATE]
      diag->DIAG_TIP  := 2
      diag->DIAG_CODE := glob_MGI[i, 2]
      diag->DIAG_RSLT := iif(ao[LISS_USL, 1, LISU_D_RSLT] == '1', glob_MGI[i, 4], glob_MGI[i, 3])
      diag->REC_RSLT  := 1
    endif
  endif
  return NIL

// 14.01.17 проверить отдельно фамилию, имя или отчество при импорте из ЛИС
Function f_LIS_fio(s,n)
Static arr_char := {" ","-",".","'",'"'} // разрешённые спецсимволы
Local i, c, s1 := ""
s := alltrim(s) // убрать пробелы
for i := 1 to len(arr_char)
  s := charone(arr_char[i], s) // оставить 1 спецсимвол подряд
next
s := lat_rus(s)  // заменить латинские символы на соответствующие русские (если встретились)
s1 := charrem("0123456789", s) // убрать цифры
if empty(s1) .and. n < 3 // если в фамилии или имени были только цифры, - оставить их
  s1 := s
endif
s := s1 ; s1 := ""
for i := 1 to len(s)
  c := substr(s, i, 1)
  if isralpha(c) // буква
    s1 += c
  elseif ascan(arr_char,c) > 0 // разрешённый спецсимвол
    s1 += c
  elseif between(asc(c), 48, 57) // в фамилии или имени были только цифры
    s1 += c
  endif
next
return s1

// 15.01.17 проверить полис при импорте из ЛИС
Function f_LIS_polis()
Local n
if empty(arr_pac[LIS_OKATO]) .or. mo_nodigit(arr_pac[LIS_OKATO]) // пустое или не цифры
  arr_pac[LIS_OKATO] := "18"
endif
arr_pac[LIS_OKATO] := padr(arr_pac[LIS_OKATO], 11,"0")
if ascan(glob_array_srf, {|x| x[2] == left(arr_pac[LIS_OKATO], 2) }) == 0
  arr_pac[LIS_OKATO] := padr("18", 11,"0")
endif
//
arr_pac[LIS_VPOLIS] := int(val(arr_pac[LIS_VPOLIS]))
if !between(arr_pac[LIS_VPOLIS], 1, 3)
  arr_pac[LIS_VPOLIS] := 3
endif
arr_pac[LIS_SPOLIS] := val_polis(arr_pac[LIS_SPOLIS])
arr_pac[LIS_NPOLIS] := val_polis(arr_pac[LIS_NPOLIS])
if !empty(arr_pac[LIS_SPOLIS]) .and. !mo_nodigit(arr_pac[LIS_SPOLIS]) // цифры в серии полиса
  arr_pac[LIS_NPOLIS] := arr_pac[LIS_SPOLIS] + arr_pac[LIS_NPOLIS] // склеим серию и номер = получим номер
  arr_pac[LIS_SPOLIS] := ""
endif
n := len(arr_pac[LIS_NPOLIS])
if n == 9 .and. empty(arr_pac[LIS_SPOLIS])
  arr_pac[LIS_VPOLIS] := 2  // то пусть это будет временный полис
endif
if n == 16 .and. !empty(arr_pac[LIS_SPOLIS])
  arr_pac[LIS_SPOLIS] := ""  // то очистим - какой-то мусор
endif
if arr_pac[LIS_VPOLIS] == 1
  if left(arr_pac[LIS_OKATO], 2) == "18" .and. empty(arr_pac[LIS_SPOLIS]) .and. n != 16
    arr_pac[LIS_NPOLIS] := padr(arr_pac[LIS_NPOLIS], 16,"0")
  endif
elseif arr_pac[LIS_VPOLIS] == 2
  if n != 9
    arr_pac[LIS_NPOLIS] := padr(arr_pac[LIS_NPOLIS], 9,"0")
  endif
elseif arr_pac[LIS_VPOLIS] == 3
  if n != 16
    arr_pac[LIS_NPOLIS] := padr(arr_pac[LIS_NPOLIS], 16,"0")
  endif
  if !f_checksum_polis(arr_pac[LIS_NPOLIS]) // если неверная контрольная сумма в новом полисе
    arr_pac[LIS_VPOLIS] := 1  // то пусть это будет старый полис
  endif
endif
return NIL

// 29.03.23 проверить паспорт при импорте из ЛИС
Function f_LIS_pasport()
Local i, _sl, _sr
arr_pac[LIS_VID_UD] := int(val(arr_pac[LIS_VID_UD]))
if ascan(getVidUd(), {|x| x[2] == arr_pac[LIS_VID_UD] }) == 0
  arr_pac[LIS_VID_UD] := iif(arr_pac[LIS_VPOLIS] < 3, 14, 0)
endif
if arr_pac[LIS_VID_UD] == 0 // ели новый полис и нет документа, очистим серию и номер документа
  arr_pac[LIS_SER_UD] := ""
  arr_pac[LIS_NOM_UD] := ""
else
  arr_pac[LIS_SER_UD] := upper(arr_pac[LIS_SER_UD])
  if eq_any(arr_pac[LIS_VID_UD], 1, 3) // "Паспорт гражд.СССР" или "Свид-во о рождении"
    if "-" $ arr_pac[LIS_SER_UD]
      _sl := ALLTRIM(TOKEN(arr_pac[LIS_SER_UD], "-", 1))
      _sr := ALLTRIM(TOKEN(arr_pac[LIS_SER_UD], "-", 2))
      arr_pac[LIS_SER_UD] := _sl+"-"+lat_rus(_sr) // латынь -> в русский
    else
      if !mo_nodigit(charrem(" ",arr_pac[LIS_SER_UD])) // если только цифры в серии
        arr_pac[LIS_VID_UD] := 14 // то это паспорт РФ
      else
        arr_pac[LIS_VID_UD] := 18 // иначе "Иные документы"
      endif
    endif
  endif
  if arr_pac[LIS_VID_UD] == 14 .and. !(" " $ arr_pac[LIS_SER_UD]) // если серия в виде "1803" - без пробела
    arr_pac[LIS_SER_UD] := left(arr_pac[LIS_SER_UD], 2) + " "+substr(arr_pac[LIS_SER_UD], 3)
  endif
  if mo_nodigit(arr_pac[LIS_NOM_UD]) // не цифры
    arr_pac[LIS_VID_UD] := 18 // "Иные документы"
  else
    if (eq_any(arr_pac[LIS_VID_UD], 1, 3) .and. len(arr_pac[LIS_NOM_UD]) != 6) .or. ;
             (arr_pac[LIS_VID_UD] == 14 .and. !eq_any(len(arr_pac[LIS_NOM_UD]), 6, 7))
      arr_pac[LIS_NOM_UD] := padr(arr_pac[LIS_NOM_UD], 6,"9") // т.е. делаем 6 знаков в длину
    endif
  endif
  if eq_any(arr_pac[LIS_VID_UD], 3, 14)
    if empty(arr_pac[LIS_MESTO_R])
      arr_pac[LIS_MESTO_R] := "г.Волгоград"
    else
      arr_pac[LIS_MESTO_R] := del_spec_symbol(arr_pac[LIS_MESTO_R])
    endif
  endif
endif
return NIL

// 03.05.17
Function f_define_LIS_coding(name_file)
Local arr_pac, a1[3], a2[3], fl[3], i, j := 0, ret := {.t.,.t.}
ft_use(name_file)
ft_gotop()
do while !ft_eof()
  if !empty( s := ft_ReadLn() )
    if upper(left(s, 3)) == "PAT"
      arr_pac := {}
      for i := 3 to numtoken(s,";", 1)
        s1 := alltrim(token(s,";", i, 1))
        aadd(arr_pac, s1)
        if len(arr_pac) == 3 ; exit ; endif
      next
      for i := 1 to 3
        a1[i] := hb_AnsiToOem(arr_pac[i])
        a2[i] := hb_OemToAnsi(a1[i])
        fl[i] := (arr_pac[i] == a2[i])
        if !fl[i]
          ret[1] := .f.
        endif
      next
      for i := 1 to 3
        a1[i] := hb_Utf8ToStr(arr_pac[i],"RU866")
        a2[i] := hb_StrToUtf8(a1[i],"RU866")
        fl[i] := (arr_pac[i] == a2[i])
        if !fl[i]
          ret[2] := .f.
        endif
      next
      if ++j == 5 ; exit ; endif
    endif
  endif
  ft_skip()
enddo
ft_use()
j := 0
if ret[1] == ret[2]
  func_error(4, "Не удалось автоматически определить кодировку файла "+StripPath(name_file))
else
  j := iif(ret[1], 1, 2)
endif
return j

    