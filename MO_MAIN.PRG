***** mo_main.prg - главный модуль
*******************************************************************************
* Функции для plug-in'ов
*******************************************************************************
* my_mo_begin_task()
*******************************************************************************
#include "set.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

external ust_printer, ErrorSys, ReadModal, like, flstr, prover_dbf, net_monitor, pr_view, ne_real
// старые (редко используемые) отчёты запускаем из hrb-файлов (для уменьшения задачи)
DYNAMIC i_new_boln
DYNAMIC i_kol_del_zub
DYNAMIC phonegram_15_kz
DYNAMIC forma_792_MIAC
DYNAMIC f1forma_792_MIAC
DYNAMIC monitoring_vid_pom
DYNAMIC b_25_perinat_2

***** 10.03.22
procedure main( ... )
  Local r, s, is_create := .f., is_copy := .f., is_index := .f.
  Local a_parol, buf, is_local_version
  local verify_fio_polzovat := .t.

  FOR EACH s IN hb_AParams() // анализ входных параметров
    s := lower(s)
    DO CASE
      CASE s == "/create"
        is_create := .t.
      CASE s == "/copy"
        is_copy := .t.
      CASE s == "/index"
        is_index := .t.
    ENDCASE
  NEXT
  //
  public Err_version := fs_version(_version())+" от "+_date_version()
  Public kod_VOUNC := '101004'
  Public kod_LIS   := {'125901','805965'}
  //
  Public DELAY_SPRD := 0 // время задержки для разворачивания строк
  Public sdbf := ".DBF", sntx := ".NTX", stxt := ".TXT", szip := ".ZIP",;
       smem := ".MEM", srar := ".RAR", sxml := ".XML", sini := ".INI",;
       sfr3 := ".FR3", sfrm := ".FRM", spdf := ".PDF", scsv := ".CSV",;
       sxls := ".xls", schip := ".CHIP", cslash := "\",;
       sdbt := ".dbt"
  PUBLIC public_mouse := .f., pravo_write := .t., pravo_read := .t., ;
       MenuTo_Minut := 0, sys_date := DATE(), cScrMode := "COLOR", ;
       DemoMode := .f., picture_pf := "@R 999-999-999 99", ;
       pict_cena := "9999999.99", forever := "forever"
  Public gpasskod := ret_gpasskod()
  PUBLIC sem_task := "Учёт работы МО"
  PUBLIC sem_vagno := "Учёт работы МО - ответственный режим"
  PUBLIC err_slock := "В данный момент с этим режимом работает другой пользователь. Доступ запрещён!"
  PUBLIC err_admin := "Доступ в данный режим разрешен только администратору системы!"
  PUBLIC err_sdemo := "Это демонстрационная версия. Операция запрещена!"
  PUBLIC fr_data := "_data", fr_titl := "_titl"
  Public dir_XML_MO := "XML_MO", dir_XML_TF := "XML_TF"
  Public dir_NAPR_MO := "NAPR_MO", dir_NAPR_TF := "NAPR_TF"
  Public _tmp_dir  := "TMP___"
  Public _tmp_dir1 := _tmp_dir+cslash
  Public _tmp2dir  := "TMP2___"
  Public _tmp2dir1 := _tmp2dir+cslash
  Public d_01_04_2013 := 0d20130401
  Public d_01_04_2015 := 0d20150401
  Public d_01_08_2016 := 0d20160801
  Public d_01_08_2017 := 0d20170801
  Public d_01_09_2017 := 0d20170901
  Public d_01_05_2018 := 0d20180501
  Public d_01_05_2019 := 0d20190501
  Public d_01_11_2019 := 0d20191101
  Public d_01_01_2021 := 0d20210101
  Public d_01_01_2022 := 0d20220101 // новый 2022 год и переход на новый ПУМП письмо № 04-18?17 от 28.12.2021
  Public d_01_04_2022 := 0d20220329 // 0d20220401
  //
	// объект пользователя зарегистрировавшегося в системе
	public hb_user_curUser := nil

  SET(_SET_DELETED, .T.)
  SETCLEARB(" ")
  is_local_version := f_first(is_create)
  put_icon(__s_full_name() + __s_version(), 'MAIN_ICON')
  set key K_F1 to f_help()
  hard_err("create")
  FillScreen(p_char_screen,p_color_screen) //FillScreen("█","N+/N")
  cur_year := STR(YEAR(sys_date),4)
  new_dir = ""
  SETCOLOR(color1)

  // инициализация массива МО, запрос кода МО (при необходимости)
  r := init_mo()

  // реконструкция файлов доступа к системе
  Reconstruct_Security(is_local_version)

  // a_parol := inp_password(is_local_version,is_create)
  a_parol := inp_password_bay(is_local_version,is_create)

  checkFilesTFOMS()
  
  // объект организация с которой работаем
  public hb_main_curOrg := TOrganizationDB():GetOrganization() 
  
  if ! hb_user_curUser:IsAdmin()  // tip_polzovat != TIP_ADM
    verify_fio_polzovat := .f.
  endif
  if !G_SOpen(sem_task, sem_vagno, fio_polzovat, p_name_comp)
    if type("verify_fio_polzovat") == "L" .and. verify_fio_polzovat
      func_error('В данный момент работает другой оператор под фамилией "'+fio_polzovat+'"')
    else
      if !hb_user_curUser:IsAdmin()
        hb_Alert("В данный момент другой задачей выполняется ответственный режим. Проверьте системный монитор")
      else
        func_error('Доступ запрещен! В данный момент другой задачей выполняется ответственный режим.')
      endif
    endif
    if !hb_user_curUser:IsAdmin()
      f_end()
    endif
  endif
  //

  checkVersionInternet( r + 3, _version() )

  Public chm_help_code := 0

  Init_first() // начальная инициализация программы (переменных, массивов,...)

  Init_Program() // инициализация программы (переменных, массивов,...)

  if ControlBases(1, _version()) // если необходимо
    if G_SLock1Task(sem_task,sem_vagno)  // запрет доступа всем
      buf := savescreen()
      f_message({"Переход на новую версию программы "+fs_version(_version())+' от '+_date_version()},,,,8)
      // провести реконструкцию БД
      Reconstruct_DB(is_local_version,is_create)
      // провести реконструкцию БД учёта направлений на госпитализацию
      _263_init()
      // для начала работы _first_run() (убрал в NOT_USED)
      pereindex() // обязательно
      update_data_DB(_version())    // провести изменения в базе если необходимо
      // записать новый номер версии
      ControlBases(3)
      if glob_mo[_MO_IS_UCH]
        //correct_polis_from_sptk()  // корректировка полисов из реестров СПТК
        //dubl_zap_kod_tf()          // удалить дубликаты записей в картотеке
      endif
      // разрешение доступа всем
      G_SUnLock(sem_vagno)
      restscreen(buf)
    else
      n_message({'Вы запустили новую версию задачи '+fs_version(_version())+' от '+_date_version(),;
               'Требуется реконструкция (и переиндексирование) базы данных.',;
               'Но в данный момент работают другие задачи.',;
               'Необходимо, чтобы все пользователи вышли из задач.'},;
              {'','Для завершения работы нажмите любую клавишу'},;
              cColorSt2Msg,cColorStMsg,,,"G+/R")
      f_end(.f.)
    endif
  endif

  f_main(r, is_local_version, a_parol)

  f_end()

  return

***** 17.05.21
Function f_main(r0, is_local_version, a_parol)
  Static arr1 := {;
    {"Регистратура поликлиники"            ,X_REGIST,,.t.,"РЕГИСТРАТУРА"},;
    {"Приёмный покой стационара"           ,X_PPOKOJ,,.t.,"ПРИЁМНЫЙ ПОКОЙ"},;
    {"Обязательное медицинское страхование",X_OMS   ,,.t.,"ОМС"},;
    {"Учёт направлений на госпитализацию"  ,X_263   ,,.F.,"ГОСПИТАЛИЗАЦИЯ"},;
    {"Платные услуги"                      ,X_PLATN ,,.t.,"ПЛАТНЫЕ УСЛУГИ"},;
    {"Ортопедические услуги в стоматологии",X_ORTO  ,,.t.,"ОРТОПЕДИЯ"},;
    {"Касса медицинской организации"       ,X_KASSA ,,.t.,"КАССА"},;
    {"КЭК медицинской организации"         ,X_KEK   ,,.F.,"КЭК"};
  }
  Static arr2 := {;
    {"Редактирование справочников"         ,X_SPRAV ,,.t.},;
    {"Сервисы и настройки"                 ,X_SERVIS,,.t.},;
    {"Резервное копирование базы данных"   ,X_COPY  ,,.t.},;
    {"Переиндексирование базы данных"      ,X_INDEX ,,.t.};
  }
  Local i, lens := 0, r, c, oldTfoms, arr, ar, k, fl_exit := .t.
  local buf

  PUBLIC array_tasks := {}, sem_vagno_task[24]
  afill(sem_vagno_task,"")
  for i := 1 to len(arr1)
    aadd(array_tasks,arr1[i])
    sem_vagno_task[arr1[i,2]] := 'Важный режим в задаче "'+arr1[i,5]+'"'
  next

  if glob_mo[_MO_KOD_TFOMS] == kod_VOUNC
    aadd(array_tasks, {"ВОУНЦ - трансплантированные",X_MO,"TABLET_ICON",.T.})
  endif

  for i := 1 to len(arr2)
    aadd(array_tasks,arr2[i])
  next
  //
  arr := {}
  for i := 1 to len(array_tasks)
    if (k := array_tasks[i,2]) < 10  // код задачи
      array_tasks[i,4] := (substr(glob_mo[_MO_PROD],k,1)=='1')
      if array_tasks[i,4]
        fl_exit := .f.
      endif
    endif
    // Учёт направлений на госпитализацию
    if k == X_263 .and. (is_napr_pol .or. is_napr_stac)
      array_tasks[i,4] := .t.
      fl_exit := .f.
    endif
    if is_local_version
      if array_tasks[i,4]
        aadd(arr,array_tasks[i])
        lens := max(lens,len(array_tasks[i,1]))
      endif
    else
      if array_tasks[i,4] .and. hb_user_curUser:IsAllowedTask( i )
        aadd(arr,array_tasks[i])
        lens := max(lens,len(array_tasks[i,1]))
      endif
    endif
  next
  Public glob_task, blk_ekran, g_arr_stand := {},;
       main_menu, main_message, first_menu,;
       first_message, func_menu, cmain_menu
  if fl_exit
    func_error(4,"Нет разрешения на работу ни в одной задаче!")
  else
    // вывести верхние строки главного экрана
    r0 := main_up_screen()
    // вывести центральные строки главного экрана
    main_center_screen(r0,a_parol)
    if hb_user_curUser:IsAdmin()
      find_unfinished_reestr_sp_tk(.f.,.t.)
      find_time_limit_human_reestr_sp_tk()
      find_unfinished_R01()
      find_unfinished_R11()
    endif
    //
    r := int((maxrow()-r0-len(arr))/2)-1
    c := int((maxcol()+1-lens)/2)-1
    ar := GetIniSect(tmp_ini,"task")
    k := i := int(val(a2default(ar,"current_task",lstr(X_OMS))))
    do while .t.
      if (i := popup_2array(arr,r+r0,c,i,,,"Выбор задачи","B+/W","N+/W,W+/N*")) == 0
        exit
      endif
      oldTfoms := glob_mo[_MO_KOD_TFOMS]
      buf := savescreen()
      k := i
      f1main(i)
      restscreen(buf)
      reRead_glob_MO()
      if !(oldTfoms == glob_mo[_MO_KOD_TFOMS])
        // вывести верхние строки главного экрана
        r0 := main_up_screen()
        // вывести центральные строки главного экрана
        main_center_screen(r0)
      endif
      change_sys_date() // перечитать системную дату
      put_icon(__s_full_name() + __s_version(), 'MAIN_ICON') // перевывести заголовок окна
      @ r0,0 say full_date(sys_date) color "W+/N" // перевывести дату
      @ r0,maxcol()-4 say hour_min(seconds()) color "W+/N" // перевывести время
    enddo
    SetIniSect(tmp_ini,"task",{{"current_task",lstr(k)}})
  endif
  return NIL

***** вывести верхние строки главного экрана
Function main_up_screen()
  Local i, k, s, arr[2]

  FillScreen(p_char_screen,p_color_screen) //FillScreen("█","N+/N")
  s := "Код "+iif(glob_mo[_MO_IS_MAIN],"МО","обособленного подразделения")+;
     ", присвоенный ТФОМС: "+glob_mo[_MO_KOD_TFOMS]+;
     " (реестровый № "+glob_mo[_MO_KOD_FFOMS]+")"
  @ 0,0 say padc(s,maxcol()+1) color "W+/N"
  s := iif(glob_mo[_MO_IS_MAIN],"","Обособленное подразделение: ")+;
     glob_mo[_MO_FULL_NAME]
  k := perenos(arr,s,maxcol()+1)
  for i := 1 to k
    @ i,0 say padc(alltrim(arr[i]),maxcol()+1) color "GR+/N"
  next
  i := get_uroven()
  if between(i,1,3)
    s := "Уровень цен на медицинские услуги: "+lstr(i)
  else
    s := "Индивидуальные тарифы на медицинские услуги"
  endif
  @ k+1,0 say space(maxcol()+1) color "G+/N"
  @ k+1,0 say full_date(sys_date) color "W+/N"
  @ k+1,maxcol()-4 say hour_min(seconds()) color "W+/N"
  return k+1

***** вывести центральные строки главного экрана
Function main_center_screen(r0,a_parol)
  Static nLen := 11
  Static arr_name := {"инфаркт", "инсульт", "ЧМТ", "онкология",;
                    "пневмония", "язва", "родовая травма",;
                    "новорожденный с низкой массой тела",;
                    "астма", "диабет","панкреатит"}
  Local s, i, c, k, t_arr, r1, buf, mst := ""

  g_arr_stand := {}
  if valtype(glob_mo[_MO_STANDART]) == "A"
    for k := 1 to len(glob_mo[_MO_STANDART])
      t_arr := {glob_mo[_MO_STANDART,k,1],{}}
      mst := padr(glob_mo[_MO_STANDART,k,2],nLen)
      for i := 1 to nLen
        c := substr(mst,i,1)
        if c == "1"
          aadd(t_arr[2],i)
        endif
      next
      aadd(g_arr_stand,aclone(t_arr))
    next
  endif
  if .t.//empty(mst)
    if valtype(a_parol) == "A" .and. (k := len(a_parol)) > 0
      r1 := r0+int((maxrow()-r0-k)/2)-1
      n_message(a_parol,,"W+/W*","R/W*",r1,,"N+/W*")
    endif
  else
    s := "Нозологические формы, по которым МО участвует в выполнении стандартов:"
    for i := 1 to nLen
      c := substr(mst,i,1)
      if eq_any(c,"1","2")
        s += " "+arr_name[i]
        if c == "2"
          s += "[*]"
        endif
        s += ","
      endif
    next
    s := left(s,len(s)-1)
    t_arr := array(2)
    k := perenos(t_arr,s,64)
    r1 := r0+int((maxrow()-r0-k)/2)-1
    if (k := len(a_parol)) > 0
      if r1-r0 < k+4
        r1 := r0+k+4
      endif
      buf := save_box(r1-k-4,0,r1-1,maxcol())
      f_message(a_parol,,"W+/W*","R/W*",r1-k-3)
    endif
    n_message(t_arr,,"W/W","N/W",r1,,"N+/W")
    if buf != NIL
      rest_box(buf)
    endif
  endif
  return NIL


*****
Function m_help()
  Local tmp_help, pt

  tmp_help := chm_help_code
  chm_help_code := 100  // ?????
  f_help()
  chm_help_code := tmp_help
  return NIL

***** 24.10.17
FUNCTION f_first(is_create)
  Local is_local_version := .t.

  REQUEST HB_CODEPAGE_RU866
  HB_CDPSELECT("RU866")
  REQUEST HB_LANG_RU866
  HB_LANGSELECT("RU866")

  REQUEST DBFNTX
  RDDSETDEFAULT("DBFNTX")

  //SET(_SET_EVENTMASK,INKEY_KEYBOARD)
  SET SCOREBOARD OFF
  SET EXACT ON
  SET DATE GERMAN
  SET WRAP ON
  SET CENTURY ON
  SET EXCLUSIVE ON
  SET DELETED ON
  setblink(.f.)

  PUBLIC help_code := -1

  PUBLIC yes_color := .t.

  PUBLIC color0, color1, cColorWait, cColorSt2Msg, cColorStMsg,;
       cCalcMain, cHelpCMain, cColorText,;
       cHelpCTitle, cHelpCStatus, cDataCScr, cDataCGet, cDataCSay,;
       cDataCMenu, color13, color14, cColorSt1Msg, cDataPgDn, col_tit_popup,;
       color5, color8, col1menu := "", col2menu := "",;
       color_uch, col_tit_uch
  Public n_list := 1, tek_stroke := 0, fp
  Public p_color_screen := "W/N*", p_char_screen := " " // заполнение экрана
  Public c__cw := "N+/N" // цвет теней
  //
  color0 := "N/BG,W+/N"
  color1 := "W+/B,W+/R"
  color_uch := "B/BG,W+/B" ; col_tit_uch := "B+/BG"
  col1menu := color0+",B/BG,BG+/N"
  col2menu := color0+",B/BG,BG+/N"
  col_tit_popup := "B/BG"
  //
  cColorStMsg := "W+/R,,,,B/W"                 //    Stat_msg
  cColorSt1Msg := "W+/R,,,,B/W"                //    Stat_msg
  cColorSt2Msg := "GR+/R,,,,B/W"               //    Stat_msg
  cColorWait := "W+/R*,,,,B/W"                 //    Ждите
  //
  cCalcMain := "N/W,GR+/R"                     //    Калькулятор
  //
  cColorText := "W+/N,BG+/N,,,B/W"
  //
  cHelpCMain := "W+/RB,W+/N,,,B/W"             //    Помощь
  cHelpCTitle := "G+/RB"
  cHelpCStatus := "BG+/RB"
  //                                           //     Ввод данных
  cDataCScr  := "W+/B,B/BG"
  cDataCGet  := "W+/B,W+/R,,,BG+/B"
  cDataCSay  := "BG+/B,W+/R,,,BG+/B"
  cDataCMenu := "N/BG,W+/N,,,B/W"
  cDataPgDn  := "BG/B"
  color5     := "N/W,GR+/R,,,B/W"
  color8     := "GR+/B,W+/R"
  color13    := "W/B,W+/R,,,BG+/B"             // некотоpое выделение
  color14    := "G+/B,W+/R"
  //
  delete file ttt.ttt
  //
  Public cur_drv := DISKNAME()
  Public cur_dir := cur_drv + ":" + DIRNAME(cur_drv) + cslash
  Public dir_server := "", p_name_comp := ""
  Public dir_exe := upper(beforatnum(cslash, exename())) + cslash
  Public exe_dir := dir_exe
  // проверить, запущена ли уже данная задача, если "да" - выход из задачи
  verify_1_task()
  //
  if hb_FileExists("server.mem")
    ft_use("server.mem")
    dir_server := alltrim(ft_readln())
    if !ft_eof()
      ft_skip()
      p_name_comp := alltrim(ft_readln())
      if cslash $ p_name_comp
        p_name_comp := ""
      endif
    endif
    if len(p_name_comp) < 2
      p_name_comp := alltrim(netname())+cslash+hb_username()
    endif
    ft_use()
    is_local_version := .f.
  else // иначе = текущий каталог
    dir_server := cur_dir
  endif
  if right(dir_server,1) != cslash
    dir_server += cslash
  endif
  is_server(dir_server,cur_dir)
  if !is_create .and. !hb_FileExists(dir_server+"human"+sdbf)
    func_error("Не обнаружены файлы базы данных! Обратитесь к системному администратору.")
    QUIT
  endif
  //
  if hb_FileExists(dir_server+"plat.dbf")
    func_error("Вероятнее всего, Вы запускаете программу в каталоге СЧЕТА. Это недопустимо!")
    QUIT
  endif
  SET KEY K_ALT_F3 TO calendar
  SET KEY K_ALT_F2 TO calc
  SET KEY K_ALT_X  TO f_end
  Public flag_chip := .f.
  READINSERT(.T.) // режим редактирования по умолчанию Insert
  KEYBOARD ""
  ksetnum(.t.)    // включить NumLock
  SETCURSOR(0)
  SET COLOR TO
  RETURN is_local_version

***** 02.11.15
Function hard_err(p)
// k = 1 - проверка диска на наличие временного файла hard_err.meh
//         и, если он есть, вывод текста о необходимости переиндексирования;
//         создание временного файла hard_err.meh "CREATE"
// k = 2 - удаление временного файла hard_err.meh "DELETE"
  Local k := 3, arr := {}

  if valtype(p) == "N"
    k := p
  elseif valtype(p) == "C"
    p := upper(p)
    do case
      case p == "CREATE"
        k := 1
      case p == "DELETE"
        k := 2
    endcase
  endif
  do case
    case k == 1
      if file("hard_err.meh")
        FillScreen(p_char_screen,p_color_screen)
        aadd(arr,"Последний раз при выходе из задачи был сбой по питанию.")
        aadd(arr,". . .")
        aadd(arr,"Поэтому Вам настоятельно рекомендуется выполнить")
        aadd(arr,'режим "Переиндексирование", т.к. вполне вероятно, что')
        aadd(arr,"некоторые индексные файлы были испорчены или разрушены.")
        keyboard ""
        f_message(arr,,color1,color8,,,color1)
        if f_alert({padc("Выберите действие",60,".")},;
               {" Выход из задачи "," Продолжение работы "},;
               1,"W+/N","N+/N",20,,"W+/N,N/BG" ) != 2
          SET COLOR TO
          SET CURSOR ON
          CLS
          QUIT
        endif
        FillScreen(p_char_screen,p_color_screen)
      endif
      strfile("hard_error","hard_err.meh")
    case k == 2
      delete file hard_err.meh
  endcase
  return NIL

***** 06.10.19
FUNCTION f_end(yes_copy)
  Static group_ini := "RAB_MESTO"
  Local i, spath := "", bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )

  BEGIN SEQUENCE
    write_rest_pp() // записать незаписанные истории болезней из приёмного покоя
    CLOSE ALL
    DEFAULT yes_copy TO .t.
    if yes_copy
      i := GetIniVar(tmp_ini, {{group_ini,"base_copy","1"},;
                             {group_ini,"path_copy",""}} )
      if i[1] != NIL .and. i[1]=="1" .and. G_SLock1Task(sem_task,sem_vagno)
        if len(i) > 1 .and. i[2] != NIL .and. !empty(i[2])
          spath := i[2]
        endif
        m_copy_DB_from_end(.f.,spath) // резервное копирование
        G_SUnLock(sem_vagno) // разрешение доступа всем
      endif
    endif
  RECOVER USING error
    //
  END
  //
  BEGIN SEQUENCE
    G_SClose(sem_task) // удалить все семафоры для данной задачи
  RECOVER USING error
    //
  END
  ERRORBLOCK(bSaveHandler)
  //
  hard_err("delete")
  if __mvExist( 'cur_dir' )
	  filedelete(cur_dir+"tmp*.dbf")
	  filedelete(cur_dir+"tmp*.ntx")
	  filedelete(_tmp_dir1+"*.*")
	  if hb_DirExists(cur_dir+_tmp_dir) .and. hb_DirDelete(cur_dir+_tmp_dir) != 0
		  //func_error(4,"Не могу удалить каталог "+cur_dir+_tmp_dir)
	  endif
	  filedelete(_tmp2dir1+"*.*")
	  if hb_DirExists(cur_dir+_tmp2dir) .and. hb_DirDelete(cur_dir+_tmp2dir) != 0
		  //func_error(4,"Не могу удалить каталог "+cur_dir+_tmp2dir)
	  endif
  endif
  // удалим файлы отчетов в формате '*.HTML' из временной директории
  filedelete( HB_DirTemp() + "*.HTML")
  // закроем если нужно доплнительный поток для сообщений
  // if __mvExist( 'hb_user_curUser' )
  //	if hb_user_curUser != nil
  //		udpSendMessage( 'KIL', 'ALL', hb_user_curUser:Name1251, '' )
  //	endif
  // endif
  SET KEY K_ALT_F3 TO
  SET KEY K_ALT_F2 TO
  SET KEY K_ALT_X  TO
  SET COLOR TO
  SET CURSOR ON
  CLS
  QUIT
  RETURN NIL

***** 03.12.13
Function f_err_sem_vagno_task(n_Task)
  return func_error(4,'В задаче "'+array_tasks[ind_task(n_Task),5]+;
                    '" выполняется ОТВЕТСТВЕННАЯ операция. Доступ временно запрещён!')

***** 03.12.13
Function mo_Lock_Task(n_Task)
  Local i, fl := .t., n := 0

  DEFAULT n_Task TO glob_task
  if glob_task == n_Task // если вызывается из задачи n_Task,
    ++n                  // то максимум 1 пользователь
  endif
  i := ind_task(n_Task)
  if !G_SValueNLock(f_name_task(n_Task),n,sem_vagno_task[n_Task])
    fl := func_error('В задаче "'+array_tasks[i,5]+'" работают пользователи. Операция временно запрещена!')
  endif
  return fl

***** 03.12.13
Function mo_UnLock_Task(n_Task)
  return G_SUnLock(sem_vagno_task[n_Task])

***** вернуть имя задачи по цифровому коду
Function f_name_task(n_Task)
  Local it, s

  DEFAULT n_Task TO glob_task
  s := lstr(n_Task)
  if (it := ascan(array_tasks, {|x| x[2] == n_Task})) > 0
    s := array_tasks[it,1]
  endif
  return s

***** проверить, доступна ли данному МО конкретная задача
Function is_task(n_Task)
  Local it

  if !(type("array_tasks") == "A") // в начале задачи  ещё не определён массив
    return .f.
  endif
  DEFAULT n_Task TO glob_task
  if (it := ascan(array_tasks, {|x| x[2] == n_Task})) == 0
    return .f.
  endif
  return array_tasks[it,4]

***** вернуть индекс массива конкретной задачи
Function ind_task(n_Task)
  Local it

  DEFAULT n_Task TO glob_task
  if (it := ascan(array_tasks, {|x| x[2] == n_Task})) == 0
    it := 3 // ОМС
  endif
  return it

***** 14.06.21
Function find_unfinished_reestr_sp_tk(is_oper,is_count)
  Static max_rec := 9900000 // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  Local fl := .t., s, buf := save_maxrow(), arr, rech := 0, af := {}, bSaveHandler

  DEFAULT is_oper TO .t., is_count TO .t.

  mywait('Подождите, проверяем завершенность информационного обмена реестрами СП и ТК с ТФОМС...')

  bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
  BEGIN SEQUENCE
    if is_count
      R_Use(dir_server+"human",,"HUMAN")
      rech := lastrec()
      Use
    endif
    R_Use(dir_server+"mo_rees",,"REES")
    R_Use(dir_server+"mo_xml",,"MO_XML")
    set relation to REESTR into REES
    index on FNAME to (cur_dir+"tmp_xml") for TIP_IN == _XML_FILE_SP .and. empty(TWORK2)
    go top
    do while !eof()
      aadd(af, {rtrim(mo_xml->FNAME),lstr(rees->NSCHET)})
      skip
    enddo
    close databases
    rest_box(buf)
    if (fl := (len(af) > 0 .or. rech > max_rec))
      if rech > max_rec
        arr := {"До исчерпания лимита базы данных у Вас",;
              "осталась возможность добавить "+lstr(10000000 - rech)+" листов учёта."}
      endif
      if len(af) > 0
        s := "Не завершено чтение "
        if len(af) == 1
          s += "реестра СП и ТК "+af[1,1]+" (реестр "+af[1,2]+")"
        else
          s += lstr(len(af))+" реестров СП и ТК"
        endif
        arr := {"",s}
      endif
      if is_oper
        aadd(arr,"")
        aadd(arr,"Операция запрещена!")
      endif
      n_message(arr,{"","Обратитесь к разработчикам"},"GR+/R","W+/R",,,"G+/R")
    endif
  RECOVER USING error
    close databases
    rest_box(buf)
  END
  ERRORBLOCK(bSaveHandler)
  return fl

***** 10.06.21 проверить, есть ли неотосланные просроченные листы учёта
Function find_time_limit_human_reestr_sp_tk()
  Local buf := savescreen(), arr[10,2], i, mas_pmt, r, c, n, d := sys_date-23
  Local fl := .f., bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )

  mywait('Подождите, проверяем просроченные случаи (неотправленные в ТФОМС)...')
  BEGIN SEQUENCE
    dbcreate(cur_dir+"tmp_tl",{{"kod_h","N",8,0},;
                             {"kod_xml","N",6,0},;
                             {"dni","N",2,0}})
    use (cur_dir+"tmp_tl") new
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",,"HUMAN")
    set relation to recno() into HUMAN_
    R_Use(dir_server+"mo_refr",dir_server+"mo_refr","REFR")
    R_Use(dir_server+"mo_xml",,"MO_XML")
    R_Use(dir_server+"mo_rees",,"REES")
    set relation to KOD_XML into MO_XML
    R_Use(dir_server+"mo_rhum",,"RHUM")
    set relation to reestr into REES
    index on str(reestr,6) to (cur_dir+"tmp_rhum") for OPLATA == 2 .and. d < rees->DSCHET
    go top
    do while !eof()
      if (r := sys_date - rees->DSCHET) <= 0
        r := 1
      endif
      human->(dbGoto(rhum->kod_hum))
      // проверим, не попал ли ещё в другой реестр (или прочий счёт)
      if emptyall(human->schet,human_->REESTR) .and. rhum->REES_ZAP == human_->REES_ZAP
        select REFR
        find (str(1,1)+str(mo_xml->REESTR,6)+str(1,1)+str(rhum->kod_hum,8))
        do while refr->TIPD == 1 .and. refr->KODD == mo_xml->REESTR .and. ;
               refr->TIPZ == 1 .and. refr->KODZ == rhum->kod_hum  .and. !eof()
          if !eq_any(refr->REFREASON,50,57)
            select TMP_TL
            append blank
            tmp_tl->kod_h   := rhum->kod_hum
            tmp_tl->kod_xml := mo_xml->kod
            tmp_tl->dni     := r
            if lastrec() % 1000 == 0
              Commit
            endif
          endif
          select REFR
          skip
        enddo
      endif
      select RHUM
      skip
    enddo
  RECOVER USING error
    fl := .t.
  END
  ERRORBLOCK(bSaveHandler)
  if fl
    close databases
    restscreen(buf)
    return func_error(4,"Непонятная ошибка. Выполните переиндексирование в подзадаче ОМС")
  endif
  select TMP_TL
  if lastrec() > 0
    afillall(arr,0)
    i := 0
    index on dni to (cur_dir+"tmp_tl") unique
    go top
    if tmp_tl->dni <= 10 // не более 10 дней просрочено, иначе не выводим
      do while !eof()
        ++i
        if i == 10
          arr[i,1] := -1
          exit
        endif
        arr[i,1] := tmp_tl->dni
        skip
      enddo
      set index to
      go top
      do while !eof()
        if (i := ascan(arr, {|x| x[1] == tmp_tl->dni})) == 0
          i := 10
        endif
        arr[i,2] ++
        skip
      enddo
      close databases
      mas_pmt := {} ; n := 0
      for i := 1 to 10
        if emptyany(arr[i,1],arr[i,2])
          exit
        elseif arr[i,1] == -1
          aadd(mas_pmt, lstr(arr[i,2])+" чел. - просрочено более "+lstr(arr[9,1])+" дн.")
        else
          aadd(mas_pmt, lstr(arr[i,2])+" чел. - просрочено "+lstr(arr[i,1])+" дн.")
        endif
        n := max(n,len(atail(mas_pmt)))
      next
      if len(mas_pmt) > 0
        i := 1
        r := maxrow()-len(mas_pmt)-4 ; c := int((80-n-3)/2)
        status_key("^<Esc>^ выход из режима и вход в задачу  ^<Enter>^ просмотр просроченных случаев")
        str_center(r-1,"Обнаружены просроченные случаи:","W+/N*")
        do while (i := popup_prompt(r,c,i,mas_pmt)) > 0
          f1find_time_limit_human_reestr_sp_tk(i,arr)
        enddo
      endif
    endif
  endif
  close databases
  restscreen(buf)
  return NIL

*****
Function f1find_time_limit_human_reestr_sp_tk(i,arr)
  Local n_file := "time_lim"+stxt, sh := 80, HH := 60

  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string("")
  add_string(center("Список случаев, вернувшихся с ошибкой и ещё не отосланных в ТФОМС",sh))
  if i == 10
    add_string(center("(просрочено более "+lstr(arr[9,1])+" дн.)",sh))
  else
    add_string(center("(просрочено "+lstr(arr[i,1])+" дн.)",sh))
  endif
  add_string(center("по состоянию на "+full_date(sys_date)+" "+hour_min(seconds()),sh))
  add_string("")
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_, to otd into OTD
  use (cur_dir+"tmp_tl") new
  set relation to kod_h into HUMAN
  if i == 10
    index on upper(human->fio) to (cur_dir+"tmp_tl") for dni > arr[9,1]
  else
    index on upper(human->fio) to (cur_dir+"tmp_tl") for dni == arr[i,1]
  endif
  i := 0
  go top
  do while !eof()
    verify_FF(HH, .t., sh)
    add_string(lstr(++i)+". "+alltrim(human->fio)+", "+full_date(human->date_r)+;
             iif(empty(otd->SHORT_NAME), "", " ["+alltrim(otd->SHORT_NAME)+"]")+;
             " "+date_8(human->n_data)+"-"+date_8(human->k_data))
    select TMP_TL
    skip
  enddo
  close databases
  fclose(fp)
  viewtext(n_file,,,,.f.,,,2)
  return NIL

*****
Function my_mo_begin_task()
  Local fl := .t.

  if glob_mo[_MO_KOD_TFOMS] == kod_VOUNC
    fl := vounc_begin_task()
  endif
  return fl
