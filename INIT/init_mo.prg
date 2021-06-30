#include "function.ch"
#include "chip_mo.ch"

***** 10.06.21 инициализация массива МО, запрос кода МО (при необходимости)
Function init_mo()
  Local fl := .t., i, arr, arr1, cCode := '', buf := save_maxrow(), ;
        nfile := exe_dir+'_mo_mo.dbb'

  mywait()
  Public oper_parol := 30  // пароль для фискального регистратора
  Public oper_frparol := 30 // пароль для фискального регистратора ОТЧЕТ
  Public oper_fr_inn  := "" // ИНН кассира
  Public glob_arr_mo := {}, glob_mo, glob_podr := "", glob_podr_2 := ""
  Public is_adres_podr := .f., glob_adres_podr := {;
    {"103001",{{"103001",1,"г.Волгоград, ул.Землячки, д.78"},;
               {"103099",2,"г.Михайловка, ул.Мичурина, д.8"},;
               {"103099",3,"г.Волжский, ул.Комсомольская, д.25"},;
               {"103099",4,"г.Волжский, ул.Оломоуцкая, д.33"},;
               {"103099",5,"г.Камышин, ул.Днепровская, д.43"},;
               {"103099",6,"г.Камышин, ул.Мира, д.51"},;
               {"103099",7,"г.Урюпинск, ул.Фридек-Мистек, д.8"}};
    },;
    {"101003",{{"101003",1,"г.Волгоград, ул.Циолковского, д.1"},;
               {"101099",2,"г.Волгоград, ул.Советская, д.47"}};
    },;
    {"131001",{{"131001",1,"г.Волгоград, ул.Кирова, д.10"},;
               {"131099",2,"г.Волгоград, ул.Саши Чекалина, д.7"},;
               {"131099",3,"г.Волгоград, ул.им.Федотова, д.18"}};
    },;
    {"171004",{{"171004",1,"г.Волгоград, ул.Ополченская, д.40"},;
               {"171099",2,"г.Волгоград, ул.Тракторостроителей, д.13"}};
    };
  }
  if hb_FileExists(nfile)

    // glob_arr_mo := getMo_mo(nfile)

    create_mo_add()
    glob_arr_mo := getMo_mo_New('_mo_mo')

    if hb_FileExists(dir_server+"organiz"+sdbf)
      R_Use(dir_server+"organiz",,"ORG")
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
        func_error(4,'У Вас в справочнике занесён несуществующий код МО "'+cCode+'". Введите его заново.')
        cCode := ""
      endif
    endif
    if empty(cCode)
      if (cCode := input_value(18,2,20,77,color1,;
                               "Введите код МО или обособленного подразделения, присвоенный ТФОМС",;
                               space(6),"999999")) != NIL .and. !empty(cCode)
        if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode})) > 0
          glob_mo := glob_arr_mo[i]
          if hb_FileExists(dir_server+"organiz"+sdbf)
            G_Use(dir_server+"organiz",,"ORG")
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
          fl := func_error('Работа невозможна - введённый код МО "'+cCode+'" неверен.')
        endif
      endif
    endif
    if empty(cCode)
      fl := func_error('Работа невозможна - не введён код МО.')
    endif
  else
    fl := func_error('Работа невозможна - не обнаружен файл "_MO_MO.DBB"')
  endif

  rest_box(buf)

  if ! fl
    hard_err("delete")
    QUIT
  endif

  return main_up_screen()

***** 10.06.21 проверка и переиндексирование справочников ТФОМС
Function checkFilesTFOMS()
  Local fl := .t., i, arr, buf := save_maxrow()
  local arrRefFFOMS := {}, row, row_flag := .t.
  local lSchema := .f.

  mywait('Подождите, идет проверка служебных данных в рабочем каталоге...')

  // справочник диагнозов
  sbase := "_mo_mkb"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase )
    index on shifr+str(ks,1) to (cur_dir+sbase)
    close databases
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // справочник отделений на 2021 год
  sbase := "_mo1dep"
  Public is_otd_dep := .f., glob_otd_dep := 0, mm_otd_dep := {}
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase ,,"DEP")
    index on str(code,3) to (cur_dir+sbase) for codem == glob_mo[_MO_KOD_TFOMS]
    dbeval({|| aadd(mm_otd_dep, {alltrim(dep->name_short)+" ("+alltrim(dep->name)+")",dep->code,dep->place}) })
    use
    if (is_otd_dep := (len(mm_otd_dep) > 0))
      asort(mm_otd_dep,,,{|x,y| x[1] < y[1]})
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  if is_otd_dep
    // справочник отделения + профили
    sbase := "_mo1deppr"
    if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase ,,"DEP")
      index on str(code,3)+str(pr_mp,3) to (cur_dir+sbase) for codem == glob_mo[_MO_KOD_TFOMS]
      use
    else
      fl := notExistsFileNSI( exe_dir + sbase + sdbf )
    endif
  endif

  Public arr_12_VMP := {}
  // private iiiVMP := 0
  // справочник услуг ТФОМС на 2021 год
  sbase := "_mo1usl"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase ,,"LUSL")
    index on shifr to (cur_dir+sbase)
    find ("1.20.") // ВМП федеральное   // 07.02.21 замена услуг с 1.12 на 1.20 письмо 12-20-60 от 01.02.2021
    do while left(lusl->shifr,5) == "1.20." .and. !eof()
    // find ("1.12.") // ВМП федеральное
    // do while left(lusl->shifr,5) == "1.12." .and. !eof()
      aadd(arr_12_VMP,int(val(substr(lusl->shifr,6))))
      skip
    enddo
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // справочник соответствия услуг ВМП услугам ТФОМС на 2021 год
  sbase := "_mo1vmp_usl"
  if hb_FileExists(exe_dir + sbase + sdbf)
    // что-то сделать
    // R_Use(exe_dir + sbase ,,"LUSL")
    // index on shifr to (cur_dir+sbase)
    // find ("1.20.") // ВМП федеральное   // 07.02.21 замена услуг с 1.12 на 1.20 письмо 12-20-60 от 01.02.2021
    // do while left(lusl->shifr,5) == "1.20." .and. !eof()
    //   aadd(arr_12_VMP,int(val(substr(lusl->shifr,6))))
    //   skip
    // enddo
    // use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  // справочник отделений на 2020 год
  sbase := "_mo0dep"
  Public is_otd_dep := .f., glob_otd_dep := 0, mm_otd_dep := {}
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase ,,"DEP")
    index on str(code,3) to (cur_dir+sbase) for codem == glob_mo[_MO_KOD_TFOMS]
    dbeval({|| aadd(mm_otd_dep, {alltrim(dep->name_short)+" ("+alltrim(dep->name)+")",dep->code,dep->place}) })
    use
    if (is_otd_dep := (len(mm_otd_dep) > 0))
      asort(mm_otd_dep,,,{|x,y| x[1] < y[1]})
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  if is_otd_dep
    // справочник отделения + профили
    sbase := "_mo0deppr"
    if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase ,,"DEP")
      index on str(code,3)+str(pr_mp,3) to (cur_dir+sbase) for codem == glob_mo[_MO_KOD_TFOMS]
      use
    else
      fl := notExistsFileNSI( exe_dir + sbase + sdbf )
    endif
  endif
  // Public arr_12_VMP := {}
  // справочник услуг ТФОМС на 2020 год
  sbase := "_mo0usl"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase ,,"LUSL")
    index on shifr to (cur_dir+sbase)
    // 07.02.21 замена услуг с 1.12 на 1.20 письмо 12-20-60 от 01.02.2021
    // find ("1.12.") // ВМП федеральное
    // do while left(lusl->shifr,5) == "1.12." .and. !eof()
    //   aadd(arr_12_VMP,int(val(substr(lusl->shifr,6))))
    //   skip
    // enddo
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  sbase := "_mo9usl"
  if hb_FileExists(exe_dir + sbase + sdbf)
    if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx)
      R_Use(exe_dir + sbase ,,"LUSL")
      index on shifr to (cur_dir+sbase)
      use
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  sbase := "_mo8usl"
  if hb_FileExists(exe_dir + sbase + sdbf)
    if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx)
      R_Use(exe_dir + sbase ,,"LUSL")
      index on shifr to (cur_dir+sbase)
      use
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  Public is_napr_pol := .f.,; // работа с направлениями на госпитализацию в п-ке
         is_napr_stac := .f.,;  // работа с направлениями на госпитализацию в стационаре
         glob_klin_diagn := {} // работа со специальными лабораторными исследованиями
  Public is_ksg_VMP := .f., is_12_VMP := .f., is_14_VMP := .f., is_ds_VMP := .f.
  Public is_21_VMP := .f.
  // справочник цен на услуги ТФОМС
  /*sbase := "_mo_uslc"
  if hb_FileExists(exe_dir + sbase + sdbf)
    if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx)
      R_Use(exe_dir + sbase )
      index on shifr+str(uroven,1)+str(vzros_reb,1)+dtos(datebeg) to (cur_dir+sbase) ;
            for empty(codemo)
      index on codemo+shifr+str(vzros_reb,1)+dtos(datebeg) to (cur_dir+"_mo_uslu") ;
            for codemo==glob_mo[_MO_KOD_TFOMS]//!empty(codemo)
      if valtype(glob_mo) == "A"
        find (glob_mo[_MO_KOD_TFOMS]+"2.") // врачебные приёмы
        do while codemo==glob_mo[_MO_KOD_TFOMS] .and. left(shifr,2)=="2." .and. !eof()
          if left(shifr,5) == "2.82."
            // врачебный прием в приемном отделении стационара
          else
            is_napr_pol := .t. ; exit
          endif
          skip
        enddo
      endif
      use
    endif
  else
    //fl := func_error('Работа невозможна - не обнаружен файл "'+upper(sbase)+sdbf+'"')
  endif*/
  // справочник цен на услуги ТФОМС 2016-2017
  Public glob_MU_dializ := {}//"A18.05.002.001","A18.05.002.002","A18.05.002.003",;
                            //"A18.05.003","A18.05.003.001","A18.05.011","A18.30.001","A18.30.001.001"}
  Public glob_KSG_dializ := {}//"10000901","10000902","10000903","10000905","10000906","10000907","10000913",;
                             //"20000912","20000916","20000917","20000918","20000919","20000920"}
                             //"1000901","1000902","1000903","1000905","1000906","1000907","1000913",;
                             //"2000912","2000916","2000917","2000918","2000919","2000920"}
  
  Public is_vr_pr_pp := .f., is_hemodializ := .f., is_per_dializ := .f., is_reabil_slux := .f.,;
         is_ksg_1300098 := .f., is_dop_ob_em := .f., glob_yes_kdp2[10], glob_menu_mz_rf := {.f.,.f.,.f.}
  afill(glob_yes_kdp2,.f.)
  /*sbase := "_mo5uslc"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir+"_mo_usl",cur_dir+"_mo_usl","LUSL")
    R_Use(exe_dir + sbase ,,"LUSLC")
    index on left(shifr,2)+substr(shifr,6,3) to (cur_dir+"_mo5uslu") ;
          for year(datebeg) > 2016 .and. f_index_uslc()
    t_arr := {"12311","12312","22117","22118"}
    for i := 1 to len(t_arr)
      find (t_arr[i])
      if found()
        is_reabil_slux := .t.
      endif
    next
    index on shifr+str(uroven,1)+str(vzros_reb,1)+dtos(datebeg) to (cur_dir+sbase) ;
          for empty(codemo)
    index on codemo+shifr+str(vzros_reb,1)+dtos(datebeg) to (cur_dir+"_mo5uslu") ;
          for f_index_uslc()
    if valtype(glob_mo) == "A"
      find (glob_mo[_MO_KOD_TFOMS]+"2.") // врачебные приёмы
      do while codemo==glob_mo[_MO_KOD_TFOMS] .and. left(shifr,2)=="2." .and. !eof()
        if left(shifr,5) == "2.82."
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
      find (glob_mo[_MO_KOD_TFOMS]+"1.") // койко-дни
      if (is_napr_stac := found())
        glob_menu_mz_rf[1] := .t.
      endif
      //
      find (glob_mo[_MO_KOD_TFOMS]+"1.12.") // ВМП по-новому
      if !(is_12_VMP := found()) .and. !empty(glob_podr_2)
        find (glob_podr_2+"1.12.") // для второго адреса подразделения
        is_12_VMP := found()
      endif
      //
      find (glob_mo[_MO_KOD_TFOMS]+"55.1.") // дневной стационар
      if found()
        if !is_napr_stac
          is_napr_stac := .t.
        endif
        glob_menu_mz_rf[2] := found()
      endif
      //
      tmp_stom := {"2.78.54","2.78.55","2.78.56","2.78.57","2.78.58","2.78.59","2.78.60"}
      for i := 1 to len(tmp_stom)
        find (glob_mo[_MO_KOD_TFOMS]+tmp_stom[i]) //
        if found()
          glob_menu_mz_rf[3] := .t. ; exit
        endif
      next
      //
      for i := 1 to len(glob_KSG_dializ)-5
        find (glob_mo[_MO_KOD_TFOMS]+glob_KSG_dializ[i]) //
        if found()
          is_ksg_1300098 := .t. ; exit
        endif
      next
      //
      find (glob_mo[_MO_KOD_TFOMS]+"20000916") // гемодиализ
      is_hemodializ := found()
      //
      find (glob_mo[_MO_KOD_TFOMS]+"20000912") // перитонеальный диализ
      is_per_dializ := found()
      //
      find (glob_mo[_MO_KOD_TFOMS]+"4.20.702") // жидкостной цитологии
      if found()
        aadd(glob_klin_diagn,1)
      endif
      find (glob_mo[_MO_KOD_TFOMS]+"4.15.746") // пренатального скрининга
      if found()
        aadd(glob_klin_diagn,2)
      endif
      find (glob_mo[_MO_KOD_TFOMS]+"70.5.15") // Законченный случай диспансеризации детей-сирот (0-11 месяцев), 1 этап без гематологических исследований
      if found()
        glob_yes_kdp2[TIP_LU_DDS] := .t.
      endif
      find (glob_mo[_MO_KOD_TFOMS]+"70.6.13") // Законченный случай диспансеризации детей-сирот (0-11 месяцев), 1 этап без гематологических исследований
      if found()
        glob_yes_kdp2[TIP_LU_DDSOP] := .t.
      endif
      find (glob_mo[_MO_KOD_TFOMS]+"70.3.66") // Законченный случай диспансеризации женщин (в возрасте 21,24,27,30,33,36 лет), 1 этап без гематологических исследований
      if found()
        glob_yes_kdp2[TIP_LU_DVN] := .t.
      endif
      find (glob_mo[_MO_KOD_TFOMS]+"72.2.19") // Законченный случай профилактического осмотра несовершеннолетних (0 месяцев) 1 этап без гематологического исследования
      if found()
        glob_yes_kdp2[TIP_LU_PN] := .t.
      endif
      find (glob_mo[_MO_KOD_TFOMS]+"72.3.5") // Законченный случай предварительного осмотра несовершеннолетних 1 этап без гематологического исследования
      if found()
        glob_yes_kdp2[TIP_LU_PREDN] := .t.
      endif
      find (glob_mo[_MO_KOD_TFOMS]+"72.4.3") // Законченный случай периодического осмотра несовершеннолетних без гематологического исследования
      if found()
        glob_yes_kdp2[TIP_LU_PERN] := .t.
      endif
      // поиск дополнительных объёмов
      set relation to shifr into LUSL
      find (glob_mo[_MO_KOD_TFOMS])
      index on lusl->bukva to (cur_dir+"tmp_usl") ;
            for lusl->bukva == "N" ;
            while codemo == glob_mo[_MO_KOD_TFOMS]
      go top
      if !eof() .and. lusl->bukva == "N"
        is_dop_ob_em := .t.
      endif
    endif
    close databases
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif*/
  
  // цены на услуги на 2021 год
  Public is_alldializ := .f.
  sbase := "_mo1uslc"
  if hb_FileExists(exe_dir + sbase + sdbf) .and. valtype(glob_mo) == "A"
    R_Use(exe_dir + sbase ,,"LUSLC")
    index on shifr+str(vzros_reb,1)+str(depart,3)+dtos(datebeg) to (cur_dir+sbase) ;
          for codemo == glob_mo[_MO_KOD_TFOMS]
    index on codemo+shifr+str(vzros_reb,1)+str(depart,3)+dtos(datebeg) to (cur_dir+"_mo1uslu") ;
          for codemo == glob_mo[_MO_KOD_TFOMS] // для совместимости со старой версией справочника
    // Медицинская реабилитация детей с нарушениями слуха без замены речевого процессора системы кохлеарной имплантации
    find (glob_mo[_MO_KOD_TFOMS]+"st37.015")
    if found()
      is_reabil_slux := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"2.") // врачебные приёмы
    do while codemo==glob_mo[_MO_KOD_TFOMS] .and. left(shifr,2)=="2." .and. !eof()
      if left(shifr,5) == "2.82."
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
    find (glob_mo[_MO_KOD_TFOMS]+"60.3.")
    if found()
      is_alldializ := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"60.3.1 ")
    if found()
      is_per_dializ := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"60.3.9")
    if found()
      is_hemodializ := .t.
    else
      find (glob_mo[_MO_KOD_TFOMS]+"60.3.10")
      if found()
        is_hemodializ := .t.
      endif
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"st") // койко-дни
    if (is_napr_stac := found())
      glob_menu_mz_rf[1] := .t.
    endif
    //
    find (glob_mo[_MO_KOD_TFOMS]+"1.20.") // ВМП 07.02.2021
    is_21_VMP := found()
    //
    find (glob_mo[_MO_KOD_TFOMS]+"ds") // дневной стационар
    if found()
      if !is_napr_stac
        is_napr_stac := .t.
      endif
      glob_menu_mz_rf[2] := found()
    endif
    //
    tmp_stom := {"2.78.54","2.78.55","2.78.56","2.78.57","2.78.58","2.78.59","2.78.60"}
    for i := 1 to len(tmp_stom)
      find (glob_mo[_MO_KOD_TFOMS]+tmp_stom[i]) //
      if found()
        glob_menu_mz_rf[3] := .t. ; exit
      endif
    next
    //
    find (glob_mo[_MO_KOD_TFOMS]+"4.20.702") // жидкостной цитологии
    if found()
      aadd(glob_klin_diagn,1)
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"4.15.746") // пренатального скрининга
    if found()
      aadd(glob_klin_diagn,2)
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"70.5.15") // Законченный случай диспансеризации детей-сирот (0-11 месяцев), 1 этап без гематологических исследований
    if found()
      glob_yes_kdp2[TIP_LU_DDS] := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"70.6.13") // Законченный случай диспансеризации детей-сирот (0-11 месяцев), 1 этап без гематологических исследований
    if found()
      glob_yes_kdp2[TIP_LU_DDSOP] := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"70.3.123") // Законченный случай диспансеризации женщин (в возрасте 21,24,27 лет), 1 этап без гематологических исследований
    if found()
      glob_yes_kdp2[TIP_LU_DVN] := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"72.2.41") // Законченный случай профилактического осмотра несовершеннолетних (2 мес.) 1 этап без гематологического исследования
    if found()
      glob_yes_kdp2[TIP_LU_PN] := .t.
    endif
    close databases
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // цены на услуги на 2020 год
  Public is_alldializ := .f.
  sbase := "_mo0uslc"
  if hb_FileExists(exe_dir + sbase + sdbf) .and. valtype(glob_mo) == "A"
    R_Use(exe_dir + sbase ,,"LUSLC")
    index on shifr+str(vzros_reb,1)+str(depart,3)+dtos(datebeg) to (cur_dir+sbase) ;
          for codemo == glob_mo[_MO_KOD_TFOMS]
    index on codemo+shifr+str(vzros_reb,1)+str(depart,3)+dtos(datebeg) to (cur_dir+"_mo0uslu") ;
          for codemo == glob_mo[_MO_KOD_TFOMS] // для совместимости со старой версией справочника
    // Медицинская реабилитация детей с нарушениями слуха без замены речевого процессора системы кохлеарной имплантации
    find (glob_mo[_MO_KOD_TFOMS]+"st37.015")
    if found()
      is_reabil_slux := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"2.") // врачебные приёмы
    do while codemo==glob_mo[_MO_KOD_TFOMS] .and. left(shifr,2)=="2." .and. !eof()
      if left(shifr,5) == "2.82."
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
    find (glob_mo[_MO_KOD_TFOMS]+"60.3.")
    if found()
      is_alldializ := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"60.3.1 ")
    if found()
      is_per_dializ := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"60.3.9")
    if found()
      is_hemodializ := .t.
    else
      find (glob_mo[_MO_KOD_TFOMS]+"60.3.10")
      if found()
        is_hemodializ := .t.
      endif
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"st") // койко-дни
    if (is_napr_stac := found())
      glob_menu_mz_rf[1] := .t.
    endif
    //
    find (glob_mo[_MO_KOD_TFOMS]+"1.12.") // ВМП // 07.02.2021
    is_12_VMP := found()
    //
    find (glob_mo[_MO_KOD_TFOMS]+"ds") // дневной стационар
    if found()
      if !is_napr_stac
        is_napr_stac := .t.
      endif
      glob_menu_mz_rf[2] := found()
    endif
    //
    tmp_stom := {"2.78.54","2.78.55","2.78.56","2.78.57","2.78.58","2.78.59","2.78.60"}
    for i := 1 to len(tmp_stom)
      find (glob_mo[_MO_KOD_TFOMS]+tmp_stom[i]) //
      if found()
        glob_menu_mz_rf[3] := .t. ; exit
      endif
    next
    //
    find (glob_mo[_MO_KOD_TFOMS]+"4.20.702") // жидкостной цитологии
    if found()
      aadd(glob_klin_diagn,1)
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"4.15.746") // пренатального скрининга
    if found()
      aadd(glob_klin_diagn,2)
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"70.5.15") // Законченный случай диспансеризации детей-сирот (0-11 месяцев), 1 этап без гематологических исследований
    if found()
      glob_yes_kdp2[TIP_LU_DDS] := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"70.6.13") // Законченный случай диспансеризации детей-сирот (0-11 месяцев), 1 этап без гематологических исследований
    if found()
      glob_yes_kdp2[TIP_LU_DDSOP] := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"70.3.123") // Законченный случай диспансеризации женщин (в возрасте 21,24,27 лет), 1 этап без гематологических исследований
    if found()
      glob_yes_kdp2[TIP_LU_DVN] := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"72.2.41") // Законченный случай профилактического осмотра несовершеннолетних (2 мес.) 1 этап без гематологического исследования
    if found()
      glob_yes_kdp2[TIP_LU_PN] := .t.
    endif
    close databases
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // цены на услуги на 2019 год
  sbase := "_mo9uslc"
  if hb_FileExists(exe_dir + sbase + sdbf) .and. valtype(glob_mo) == "A"
    R_Use(exe_dir + sbase ,,"LUSLC")
    index on shifr+str(vzros_reb,1)+str(depart,3)+dtos(datebeg) to (cur_dir+sbase) ;
          for codemo == glob_mo[_MO_KOD_TFOMS]
    index on codemo+shifr+str(vzros_reb,1)+str(depart,3)+dtos(datebeg) to (cur_dir+"_mo9uslu") ;
          for codemo == glob_mo[_MO_KOD_TFOMS] // для совместимости со старой версией справочника
    // Медицинская реабилитация детей с нарушениями слуха без замены речевого процессора системы кохлеарной имплантации
    find (glob_mo[_MO_KOD_TFOMS]+"st37.015")
    if found()
      is_reabil_slux := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"2.") // врачебные приёмы
    do while codemo==glob_mo[_MO_KOD_TFOMS] .and. left(shifr,2)=="2." .and. !eof()
      if left(shifr,5) == "2.82."
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
    find (glob_mo[_MO_KOD_TFOMS]+"60.3.")
    if found()
      is_alldializ := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"60.3.1 ")
    if found()
      is_per_dializ := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"60.3.9")
    if found()
      is_hemodializ := .t.
    else
      find (glob_mo[_MO_KOD_TFOMS]+"60.3.10")
      if found()
        is_hemodializ := .t.
      endif
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"st") // койко-дни
    if (is_napr_stac := found())
      glob_menu_mz_rf[1] := .t.
    endif
    //
    find (glob_mo[_MO_KOD_TFOMS]+"1.12.") // ВМП // 07.02.2021
    // find (glob_mo[_MO_KOD_TFOMS]+"1.20.") // ВМП
    is_12_VMP := found()
    //
    find (glob_mo[_MO_KOD_TFOMS]+"ds") // дневной стационар
    if found()
      if !is_napr_stac
        is_napr_stac := .t.
      endif
      glob_menu_mz_rf[2] := found()
    endif
    //
    tmp_stom := {"2.78.54","2.78.55","2.78.56","2.78.57","2.78.58","2.78.59","2.78.60"}
    for i := 1 to len(tmp_stom)
      find (glob_mo[_MO_KOD_TFOMS]+tmp_stom[i]) //
      if found()
        glob_menu_mz_rf[3] := .t. ; exit
      endif
    next
    //
    find (glob_mo[_MO_KOD_TFOMS]+"4.20.702") // жидкостной цитологии
    if found()
      aadd(glob_klin_diagn,1)
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"4.15.746") // пренатального скрининга
    if found()
      aadd(glob_klin_diagn,2)
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"70.5.15") // Законченный случай диспансеризации детей-сирот (0-11 месяцев), 1 этап без гематологических исследований
    if found()
      glob_yes_kdp2[TIP_LU_DDS] := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"70.6.13") // Законченный случай диспансеризации детей-сирот (0-11 месяцев), 1 этап без гематологических исследований
    if found()
      glob_yes_kdp2[TIP_LU_DDSOP] := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"70.3.123") // Законченный случай диспансеризации женщин (в возрасте 21,24,27 лет), 1 этап без гематологических исследований
    if found()
      glob_yes_kdp2[TIP_LU_DVN] := .t.
    endif
    find (glob_mo[_MO_KOD_TFOMS]+"72.2.41") // Законченный случай профилактического осмотра несовершеннолетних (2 мес.) 1 этап без гематологического исследования
    if found()
      glob_yes_kdp2[TIP_LU_PN] := .t.
    endif
    close databases
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // цены на услуги на 2018 год
  sbase := "_mo8uslc"
  if hb_FileExists(exe_dir + sbase + sdbf) .and. valtype(glob_mo) == "A"
    if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx)
      R_Use(exe_dir + sbase ,,"LUSLC")
      index on shifr+str(vzros_reb,1)+str(depart,3)+dtos(datebeg) to (cur_dir+sbase) ;
          for codemo == glob_mo[_MO_KOD_TFOMS]
      index on codemo+shifr+str(vzros_reb,1)+str(depart,3)+dtos(datebeg) to (cur_dir+"_mo8uslu") ;
          for codemo == glob_mo[_MO_KOD_TFOMS] // для совместимости со старой версией справочника
      close databases
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  Public is_MO_VMP := (is_ksg_VMP .or. is_21_VMP .or. is_12_VMP .or. is_14_VMP .or. is_ds_VMP)
  // справочник доплат по законченным случаям (старый справочник)
  /*sbase := "_mo_usld"
  if hb_FileExists(exe_dir + sbase + sdbf)
    if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx)
      R_Use(exe_dir + sbase )
      index on shifr+dtos(datebeg) to (cur_dir+sbase)
      use
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif*/
  // справочник "услуги по законченным случаям + диагнозы"
  /*sbase := "_mo_uslz"
  if hb_FileExists(exe_dir + sbase + sdbf)
    if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx)
      R_Use(exe_dir + sbase )
      index on shifr+str(type_diag,1)+kod_diag to (cur_dir+sbase)
      use
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif*/
  // справочник услуг ФФОМС 2021
  sbase := "_mo1uslf"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase ,,"LUSLF")
    index on shifr to (cur_dir+sbase)
    close databases
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // справочник услуг ФФОМС 2020
  sbase := "_mo0uslf"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase ,,"LUSLF")
    index on shifr to (cur_dir+sbase)
    close databases
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  // справочник услуг ФФОМС 2019
  sbase := "_mo9uslf"
  if hb_FileExists(exe_dir + sbase + sdbf)
    if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx)
      R_Use(exe_dir + sbase ,,"LUSLF")
      index on shifr to (cur_dir+sbase)
      close databases
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // справочник услуг ФФОМС 2018
  sbase := "_mo8uslf"
  if hb_FileExists(exe_dir + sbase + sdbf)
    if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx)
      R_Use(exe_dir + sbase ,,"LUSLF")
      index on shifr to (cur_dir+sbase)
      close databases
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // услуги <-> профили
  sbase := "_mo_prof"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase )
    index on shifr+str(vzros_reb,1)+str(profil,3) to (cur_dir+sbase)
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // услуги <-> специальности
  sbase := "_mo_spec"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase )
    index on shifr+str(vzros_reb,1)+str(prvs_new,6) to (cur_dir+sbase)
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // план-заказ
  sbase := "_mo1unit"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase )
    index on str(code,3) to (cur_dir+sbase)
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  sbase := "_mo0unit"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase )
    index on str(code,3) to (cur_dir+sbase)
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  sbase := "_mo9unit"
  if hb_FileExists(exe_dir + sbase + sdbf)
    if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx)
      R_Use(exe_dir + sbase )
      index on str(code,3) to (cur_dir+sbase)
      use
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  sbase := "_mo8unit"
  if hb_FileExists(exe_dir + sbase + sdbf)
    if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx)
      R_Use(exe_dir + sbase )
      index on str(code,3) to (cur_dir+sbase)
      use
    endif
  else
    // fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  sbase := "_mo1shema"
  if hb_FileExists(exe_dir + sbase + sdbf)
    // добавлена индексация файла
    R_Use(exe_dir + sbase )
    index on KOD to (cur_dir+sbase) // по коду критерия
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  Public arr_ad_cr_it21 := {}
  // T006 2021 год
  sbase := "_mo1it1"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir+"_mo1shema",cur_dir+"_mo1shema","SCHEMA")
  
    R_Use(exe_dir + sbase ,,"IT")
    ("IT")->(dbGoTop())  // go top
    do while !("IT")->(eof())
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
  
      ("SCHEMA")->(dbGoTop())
      if ("SCHEMA")->(dbSeek( padr(it->CODE,6) ))
        lSchema := .t.
      endif
  
      // aadd(arr_ad_cr_it21,{it->USL_OK,padr(it->CODE,3),ar,ar1,ar2})
      if lSchema
        aadd(arr_ad_cr_it21,{it->USL_OK,padr(it->CODE,6),ar,ar1,ar2, alltrim(SCHEMA->NAME)})
      else
        aadd(arr_ad_cr_it21,{it->USL_OK,padr(it->CODE,6),ar,ar1,ar2, ''})
      endif
      ("IT")->(dbskip()) 
      lSchema := .f.
    enddo
    ("SCHEMA")->(dbCloseArea())
    ("IT")->(dbCloseArea())   //use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  sbase := "_mo1k006"
  if hb_FileExists(exe_dir + sbase + sdbf)
    if hb_FileExists(exe_dir + sbase +".dbt")
        R_Use(exe_dir + sbase )
        index on substr(shifr,1,2)+ds+sy+age+sex+los to (cur_dir+sbase) // по диагнозу/операции
        index on substr(shifr,1,2)+sy+ds+age+sex+los to (cur_dir+sbase+"_") // по операции/диагнозу
        index on ad_cr to (cur_dir+sbase+"AD") // по дополнительному критерию Байкин
        use
    else
      fl := notExistsFileNSI( exe_dir + sbase + '.dbt' )
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  //
  Public arr_ad_cr_it20 := {}
  // T006 2020 год
  sbase := "_mo0it1"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase ,,"IT")
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
      aadd(arr_ad_cr_it20,{it->USL_OK,padr(it->CODE,3),ar,ar1,ar2})
      skip
    enddo
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  sbase := '_mo0shema'
  if !hb_FileExists(exe_dir + sbase + sdbf)
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  sbase := "_mo0k006"
  if hb_FileExists(exe_dir + sbase + sdbf)
    if hb_FileExists(exe_dir + sbase +".dbt")
      if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx)
        R_Use(exe_dir + sbase )
        index on substr(shifr,1,2)+ds+sy+age+sex+los to (cur_dir+sbase) // по диагнозу/операции
        index on substr(shifr,1,2)+sy+ds+age+sex+los to (cur_dir+sbase+"_") // по операции/диагнозу
        index on ad_cr to (cur_dir+sbase+"AD") // по дополнительному критерию Байкин
        use
      endif
    else
      fl := notExistsFileNSI( exe_dir + sbase + '.dbt' )
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // T006 2019 год
  Public arr_ad_cr_it19 := {}
  sbase := "_mo9it"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase ,,"IT")
    index on ds to tmpit memory
    dbeval({|| aadd(arr_ad_cr_it19,{it->ds,it->it}) })
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  sbase := '_mo9shema'
  if !hb_FileExists(exe_dir + sbase + sdbf)
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  sbase := "_mo9k006"
  if hb_FileExists(exe_dir + sbase + sdbf)
    if hb_FileExists(exe_dir + sbase +".dbt")
      if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx) .or. ;
        files_time(exe_dir + sbase + sdbf,cur_dir+sbase+"_"+sntx) .or. ;
        files_time(exe_dir + sbase + sdbf,cur_dir+sbase+"AD"+sntx)
          R_Use(exe_dir + sbase )
          index on substr(shifr,1,2)+ds+sy+age+sex+los to (cur_dir+sbase) // по диагнозу/операции
          index on substr(shifr,1,2)+sy+ds+age+sex+los to (cur_dir+sbase+"_") // по операции/диагнозу
          index on ad_cr to (cur_dir+sbase+"AD") // по дополнительному критерию Байкин
          use
      endif
    else
      fl := notExistsFileNSI( exe_dir + sbase + '.dbt' )
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // T006 2018 год
  /*sbase := "_mo8it"
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase ,,"IT")
    index on ds to tmpit memory
    dbeval({|| aadd(arr_ad_cr_it,{it->ds,it->it}) })
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  sbase := '_mo8shema'
  if !hb_FileExists(exe_dir+"_mo8shema"+sdbf)
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif*/
  sbase := "_mo8k006"
  if hb_FileExists(exe_dir + sbase + sdbf)
    if hb_FileExists(exe_dir + sbase +".dbt")
      if files_time(exe_dir + sbase + sdbf,cur_dir+sbase+sntx) .or. ;
        files_time(exe_dir + sbase + sdbf,cur_dir+sbase+"_"+sntx) .or. ;
        files_time(exe_dir + sbase + sdbf,cur_dir+sbase+"AD"+sntx)
          R_Use(exe_dir + sbase )
          index on substr(shifr,1,1)+ds+sy+age+sex+los to (cur_dir+sbase) // по диагнозу/операции
          index on substr(shifr,1,1)+sy+ds+age+sex+los to (cur_dir+sbase+"_") // по операции/диагнозу
          index on ad_cr to (cur_dir+sbase+"AD") // по дополнительному критерию Байкин
          use
      endif
    else
      fl := notExistsFileNSI( exe_dir + sbase + '.dbt' )
    endif
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  //

  sbase := "_mo_t007"
  Public arr_t007 := {}
  if hb_FileExists(exe_dir + sbase + sdbf)
    R_Use(exe_dir + sbase ,,"T7")
    index on upper(left(NAME,50))+str(profil_k,3) to (cur_dir+sbase) UNIQUE
    dbeval({|| aadd(arr_t007, {alltrim(t7->name),profil_k,pk_V020}) })
    index on str(profil_k,3)+str(profil,3) to (cur_dir+sbase)
    index on str(pk_V020,3)+str(profil,3) to (cur_dir+sbase+"2")
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // справочник страховых компаний РФ
  sbase := "_mo_smo"
  if hb_FileExists(exe_dir + sbase + sdbf)
    Public glob_array_srf := {}
    R_Use(exe_dir + sbase )
    index on okato to (cur_dir+sbase) UNIQUE
    dbeval({|| aadd(glob_array_srf,{"",field->okato}) })
    index on okato+smo to (cur_dir+sbase)
    index on smo to (cur_dir+sbase+'2')
    index on okato+ogrn to (cur_dir+sbase+'3')
    use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // onkko_vmp
  sbase := "_mo_ovmp"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on str(metod,3) to (cur_dir+sbase)
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N002
  sbase := "_mo_N002"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on str(id_st,6) to (cur_dir+sbase)
      index on ds_st+kod_st to (cur_dir+sbase+"d")
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N003
  sbase := "_mo_N003"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on str(id_t,6) to (cur_dir+sbase)
      index on ds_t+kod_t to (cur_dir+sbase+"d")
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N004
  sbase := "_mo_N004"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on str(id_n,6) to (cur_dir+sbase)
      index on ds_n+kod_n to (cur_dir+sbase+"d")
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N005
  sbase := "_mo_N005"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on str(id_m,6) to (cur_dir+sbase)
      index on ds_m+kod_m to (cur_dir+sbase+"d")
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N006 - в 2019 году пустой
  sbase := "_mo_N006"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on ds_gr+str(id_t,6)+str(id_n,6)+str(id_m,6) to (cur_dir+sbase)
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N007
  sbase := "_mo_N007"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on str(id_mrf,6) to (cur_dir+sbase)
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N008
  sbase := "_mo_N008"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on str(id_mrf,6) to (cur_dir+sbase)
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N010
  sbase := "_mo_N010"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on str(id_igh,6) to (cur_dir+sbase)
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N011
  sbase := "_mo_N011"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on str(id_igh,6) to (cur_dir+sbase)
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N020
  sbase := "_mo_N020"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on id_lekp to (cur_dir+sbase)
      index on upper(mnn) to (cur_dir+sbase+"n")
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // N021
  sbase := "_mo_N021"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on code_sh+id_lekp to (cur_dir+sbase)
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // справочник подразделений из паспорта ЛПУ
  sbase := "_mo_podr"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on codemo+padr(upper(kodotd),25) to (cur_dir+sbase)
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif

  // справочник соответствия профиля мед.помощи с профилем койки
  sbase := "_mo_prprk"
  if hb_FileExists(exe_dir + sbase + sdbf)
      R_Use(exe_dir + sbase )
      index on str(profil,3)+str(profil_k,3) to (cur_dir+sbase)
      use
  else
    fl := notExistsFileNSI( exe_dir + sbase + sdbf )
  endif
  
  aadd(arrRefFFOMS, {'_mo_f006', .t., 'F006 - Классификатор видов контроля (VidExp)' } )
  aadd(arrRefFFOMS, {'_mo_f010', .f., 'F010 - Классификатор субъектов Российской Федерации (Subekti)' } )
  aadd(arrRefFFOMS, {'_mo_f011', .f., 'F011 - Классификатор типов документов, удостоверяющих личность (Tipdoc)' } )
  aadd(arrRefFFOMS, {'_mo_O001', .f., 'O001 - Общероссийский классификатор стран мира (ОКСМ)' } )
  aadd(arrRefFFOMS, {'_mo_Q015', .t., 'Q015 - Перечень технологических правил реализации ФЛК в ИС ведения персонифицированного учета сведений об оказанной медицинской помощи (FLK_MPF)' } )
  aadd(arrRefFFOMS, {'_mo_Q016', .t., 'Q016 - Перечень технологических правил реализации ФЛК в ИС ведения персонифицированного учета сведений об оказанной медицинской помощи (FLK_MPF)' } )
  aadd(arrRefFFOMS, {'_mo_Q017', .t., 'Q017 - Перечень категорий проверок ФЛК и МЭК (TEST_K)' } )
  aadd(arrRefFFOMS, {'_mo_V002', .f., 'V002 - Классификатор профилей оказанной медицинской помощи' } )
  aadd(arrRefFFOMS, {'_mo_V018', .f., 'V018 - Классификатор видов высокотехнологичной медицинской помощи (HVid)' } )
  aadd(arrRefFFOMS, {'_mo_V019', .f., 'V019 - Классификатор методов высокотехнологичной медицинской помощи (HMet)' } )
  aadd(arrRefFFOMS, {'_mo_V022', .f., 'V022 - Классификатор моделей пациента при оказании высокотехнологичной медицинской помощи (ModPac)' } )
  aadd(arrRefFFOMS, {'_mo_t005', .t., 'T005 - Справочник ошибок при проведении технологического контроля Реестров сведений и Реестров счетов' } )

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
  
  // справочник ОКАТО
  if fl
    okato_index()
    //
    dbcreate(cur_dir+"tmp_srf",{{"okato","C",5,0},{"name","C",80,0}})
    use (cur_dir+"tmp_srf") new alias TMP
    R_Use(dir_exe+"_okator",cur_dir+"_okatr","RE")
    R_Use(dir_exe+"_okatoo",cur_dir+"_okato","OB")
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
      tmp->name  := iif(substr(glob_array_srf[i,2],3,1)=='0',"","  ")+glob_array_srf[i,1]
    next
    close databases
  else
    hard_err("delete")
    QUIT
  endif
  rest_box(buf)

  // return main_up_screen()
  return nil
