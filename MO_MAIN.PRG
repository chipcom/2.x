// mo_main.prg - главный модуль
//
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

External ust_printer, ErrorSys, ReadModal, like, flstr, prover_dbf, net_monitor, pr_view, ne_real
// старые (редко используемые) отчёты запускаем из hrb-файлов (для уменьшения задачи)
Dynamic i_new_boln
Dynamic i_kol_del_zub
Dynamic phonegram_15_kz
Dynamic forma_792_MIAC
Dynamic f1forma_792_MIAC
Dynamic monitoring_vid_pom
Dynamic b_25_perinat_2

// 04.06.23
Procedure Main( ... )
  Local r, s, is_create := .f., is_copy := .f., is_index := .f.
  Local a_parol, buf, is_local_version
  Local verify_fio_polzovat := .t.
  Local cVar, i

  For Each s IN hb_AParams() // анализ входных параметров
    s := Lower( s )
    Do Case
    Case s == '/create'
      is_create := .t.
    Case s == '/copy'
      is_copy := .t.
    Case s == '/index'
      is_index := .t.
    Endcase
  Next
  //
  Public Err_version := fs_version( _version() ) + ' от ' + _date_version()
  Public kod_VOUNC := '101004'
  Public kod_LIS   := { '125901', '805965' }
  //
  Public DELAY_SPRD := 0 // время задержки для разворачивания строк
  Public sdbf := '.DBF', sntx := '.NTX', stxt := '.TXT', szip := '.ZIP', ;
    smem := '.MEM', srar := '.RAR', sxml := '.XML', sini := '.INI', ;
    sfr3 := '.FR3', sfrm := '.FRM', spdf := '.PDF', scsv := '.CSV', ;
    sxls := '.xls', schip := '.CHIP', sdbt := '.dbt'
  Public cslash := hb_ps()    // '\'

  Public public_mouse := .f., pravo_write := .t., pravo_read := .t., ;
    MenuTo_Minut := 0, sys_date := Date(), cScrMode := 'COLOR', ;
    DemoMode := .f., picture_pf := '@R 999-999-999 99', ;
    pict_cena := '9999999.99', forever := 'forever'
  Public gpasskod := ret_gpasskod()
  Public sem_task := 'Учёт работы МО'
  Public sem_vagno := 'Учёт работы МО - ответственный режим'
  Public err_slock := 'В данный момент с этим режимом работает другой пользователь. Доступ запрещён!'
  Public err_admin := 'Доступ в данный режим разрешен только администратору системы!'
  Public err_sdemo := 'Это демонстрационная версия. Операция запрещена!'
  Public fr_data := '_data', fr_titl := '_titl'
  Public dir_XML_MO := 'XML_MO', dir_XML_TF := 'XML_TF'
  Public dir_NAPR_MO := 'NAPR_MO', dir_NAPR_TF := 'NAPR_TF'
  Public _tmp_dir  := 'TMP___'
  Public _tmp_dir1 := _tmp_dir + cslash
  Public _tmp2dir  := 'TMP2___'
  Public _tmp2dir1 := _tmp2dir + cslash
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
  Public d_01_04_2022 := 0d20220401 // изменения в ПУМП 04-18-007 от 23.03.22
  Public d_01_01_2023 := 0d20230101 // новый 2023 год
  //
  // объект пользователя зарегистрировавшегося в системе
  Public hb_user_curUser := nil

  Public chm_help_code := 0
  // объект организация с которой работаем
  Public hb_main_curOrg

  // перенес из index_work_dir
  Public is_otd_dep := .f., glob_otd_dep := 0, mm_otd_dep := {}

  Public arr_12_VMP := {}
  Public is_napr_pol := .f., ; // работа с направлениями на госпитализацию в п-ке
        is_napr_stac := .f., ; // работа с направлениями на госпитализацию в стационаре
        glob_klin_diagn := {}  // работа со специальными лабораторными исследованиями

  // создадим глобальные переменные для ВМП
  Public is_MO_VMP := .f.
  For i := 2019 To WORK_YEAR
    cVar := 'is_' + SubStr( Str( i, 4 ), 3 ) + '_VMP'
    __mvPublic( cVar )
    __mvPut( cVar, .f. )
  Next

  // справочник цен на услуги ТФОМС 2016-2017
  Public glob_MU_dializ := {}// 'A18.05.002.001','A18.05.002.002','A18.05.002.003', ;
  // 'A18.05.003','A18.05.003.001','A18.05.011','A18.30.001','A18.30.001.001'}
  Public glob_KSG_dializ := {}// '10000901','10000902','10000903','10000905','10000906','10000907','10000913', ;
  // '20000912','20000916','20000917','20000918','20000919','20000920'}
  // '1000901','1000902','1000903','1000905','1000906','1000907','1000913', ;
  // '2000912','2000916','2000917','2000918','2000919','2000920'}

  Public is_vr_pr_pp := .f., is_hemodializ := .f., is_per_dializ := .f., ;
    is_reabil_slux := .f., is_ksg_1300098 := .f., is_dop_ob_em := .f., glob_yes_kdp2[ 10 ], ;
    glob_menu_mz_rf := { .f., .f., .f. }

  Public is_alldializ := .f.

  // Public arr_t007 // массив видов профилей
  Public glob_array_srf // массив страховых компаний

  // конец переноса из index_work_dir

  Set( _SET_DELETED, .t. )
  SetClearB( ' ' )
  is_local_version := f_first( is_create )
  // put_icon(__s_full_name() + __s_version(), 'MAIN_ICON')
  put_icon( full_name_version(), 'MAIN_ICON' )
  Set Key K_F1 To f_help()
  hard_err( 'create' )
  fillscreen( p_char_screen, p_color_screen ) // FillScreen('█','N+/N')
  cur_year := Str( Year( sys_date ), 4 )
  new_dir = ''
  SetColor( color1 )

  // инициализация массива МО, запрос кода МО (при необходимости)
  r := init_mo()

  // реконструкция файлов доступа к системе
  reconstruct_security( is_local_version )

  If ! files_nsi_exists( dir_exe )
    hard_err( 'delete' )
    Quit
  Endif

  // a_parol := inp_password(is_local_version,is_create)
  a_parol := inp_password_bay( is_local_version, is_create )

  index_work_dir( dir_exe, cur_dir )    // checkFilesTFOMS() переименовал

  hb_main_curOrg := torganizationdb():getorganization()

  If ! hb_user_curUser:isadmin()  // tip_polzovat != TIP_ADM
    verify_fio_polzovat := .f.
  Endif
  If !g_sopen( sem_task, sem_vagno, fio_polzovat, p_name_comp )
    If Type( 'verify_fio_polzovat' ) == 'L' .and. verify_fio_polzovat
      func_error( 'В данный момент работает другой оператор под фамилией "' + fio_polzovat + '"' )
    Else
      If !hb_user_curUser:isadmin()
        hb_Alert( 'В данный момент другой задачей выполняется ответственный режим. Проверьте системный монитор' )
      Else
        func_error( 'Доступ запрещен! В данный момент другой задачей выполняется ответственный режим.' )
      Endif
    Endif
    If !hb_user_curUser:isadmin()
      f_end()
    Endif
  Endif
  //

  checkversioninternet( r + 3, _version() )

  init_first() // начальная инициализация программы (переменных, массивов,...)

  init_program() // инициализация программы (переменных, массивов,...)

  If controlbases( 1, _version() ) // если необходимо
    If g_slock1task( sem_task, sem_vagno )  // запрет доступа всем
      buf := SaveScreen()
      f_message( { 'Переход на новую версию программы ' + fs_version( _version() ) + ' от ' + _date_version() }, , , , 8 )
      // провести реконструкцию БД
      reconstruct_db( is_local_version, is_create )
      // провести реконструкцию БД учёта направлений на госпитализацию
      _263_init()
      // для начала работы _first_run() (убрал в NOT_USED)
      pereindex() // обязательно
      update_data_db( _version() )    // провести изменения в базе если необходимо
      // записать новый номер версии
      controlbases( 3 )
      If glob_mo[ _MO_IS_UCH ]
        // correct_polis_from_sptk()  // корректировка полисов из реестров СПТК
        // dubl_zap_kod_tf()          // удалить дубликаты записей в картотеке
      Endif
      // разрешение доступа всем
      g_sunlock( sem_vagno )
      RestScreen( buf )
    Else
      n_message( { 'Вы запустили новую версию задачи ' + fs_version( _version() ) + ' от ' + _date_version(), ;
        'Требуется реконструкция (и переиндексирование) базы данных.', ;
        'Но в данный момент работают другие задачи.', ;
        'Необходимо, чтобы все пользователи вышли из задач.' }, ;
        { '', 'Для завершения работы нажмите любую клавишу' }, ;
        cColorSt2Msg, cColorStMsg, , , 'G+/R' )
      f_end( .f. )
    Endif
  Endif

  f_main( r, is_local_version, a_parol )

  f_end()

  Return

// 11.06.23
Function f_main( r0, is_local_version, a_parol )
  Static arr1 := { ;
    { 'Регистратура поликлиники', X_REGIST, , .t., 'РЕГИСТРАТУРА' }, ;
    { 'Приёмный покой стационара', X_PPOKOJ, , .t., 'ПРИЁМНЫЙ ПОКОЙ' }, ;
    { 'Обязательное медицинское страхование', X_OMS, , .t., 'ОМС' }, ;
    { 'Учёт направлений на госпитализацию', X_263, , .f., 'ГОСПИТАЛИЗАЦИЯ' }, ;
    { 'Платные услуги', X_PLATN, , .t., 'ПЛАТНЫЕ УСЛУГИ' }, ;
    { 'Ортопедические услуги в стоматологии', X_ORTO, , .t., 'ОРТОПЕДИЯ' }, ;
    { 'Касса медицинской организации', X_KASSA, , .t., 'КАССА' }, ;
    { 'КЭК медицинской организации', X_KEK, , .f., 'КЭК' } ;
    }
  Static arr2 := { ;
    { 'Редактирование справочников', X_SPRAV, , .t. }, ;
    { 'Сервисы и настройки', X_SERVIS, , .t. }, ;
    { 'Резервное копирование базы данных', X_COPY, , .t. }, ;
    { 'Переиндексирование базы данных', X_INDEX, , .t. } ;
    }
  Local i, lens := 0, r, c, oldTfoms, arr, ar, k, fl_exit := .t.
  Local buf

  Public array_tasks := {}, sem_vagno_task[ 24 ]

  AFill( sem_vagno_task, '' )
  For i := 1 To Len( arr1 )
    AAdd( array_tasks, arr1[ i ] )
    sem_vagno_task[ arr1[ i, 2 ] ] := 'Важный режим в задаче "' + arr1[ i, 5 ] + '"'
  Next

  If glob_mo[ _MO_KOD_TFOMS ] == kod_VOUNC
    AAdd( array_tasks, { 'ВОУНЦ - трансплантированные', X_MO, 'TABLET_ICON', .t. } )
  Endif

  For i := 1 To Len( arr2 )
    AAdd( array_tasks, arr2[ i ] )
  Next
  //
  arr := {}
  For i := 1 To Len( array_tasks )
    If ( k := array_tasks[ i, 2 ] ) < 10  // код задачи
      array_tasks[ i, 4 ] := ( SubStr( glob_mo[ _MO_PROD ], k, 1 ) == '1' )
      If array_tasks[ i, 4 ]
        fl_exit := .f.
      Endif
    Endif
    // Учёт направлений на госпитализацию
    If k == X_263 .and. ( is_napr_pol .or. is_napr_stac )
      array_tasks[ i, 4 ] := .t.
      fl_exit := .f.
    Endif
    If is_local_version
      If array_tasks[ i, 4 ]
        AAdd( arr, array_tasks[ i ] )
        lens := Max( lens, Len( array_tasks[ i, 1 ] ) )
      Endif
    Else
      If array_tasks[ i, 4 ] .and. hb_user_curUser:isallowedtask( i )
        AAdd( arr, array_tasks[ i ] )
        lens := Max( lens, Len( array_tasks[ i, 1 ] ) )
      Endif
    Endif
  Next
  Public glob_task, blk_ekran, g_arr_stand := {}, ;
    main_menu, main_message, first_menu, ;
    first_message, func_menu, cmain_menu
  If fl_exit
    func_error( 4, 'Нет разрешения на работу ни в одной задаче!' )
  Else
    delete_base_dict( dir_exe, cur_dir )
    // вывести верхние строки главного экрана
    r0 := main_up_screen()
    // вывести центральные строки главного экрана
    main_center_screen( r0, a_parol )
    If hb_user_curUser:isadmin()
      find_unfinished_reestr_sp_tk( .f., .t. )
      find_time_limit_human_reestr_sp_tk()
      find_unfinished_r01()
      find_unfinished_r11()
    Endif
    //
    r := Int( ( MaxRow() - r0 - Len( arr ) ) / 2 ) -1
    c := Int( ( MaxCol() + 1 - lens ) / 2 ) -1
    ar := getinisect( tmp_ini, 'task' )
    k := i := Int( Val( a2default( ar, 'current_task', lstr( X_OMS ) ) ) )
    Do While .t.
      If ( i := popup_2array( arr, r + r0, c, i, , , 'Выбор задачи', 'B+/W', 'N+/W, W+/N*' ) ) == 0
        Exit
      Endif
      oldTfoms := glob_mo[ _MO_KOD_TFOMS ]
      buf := SaveScreen()
      k := i
      f1main( i )
      RestScreen( buf )
      reread_glob_mo()
      If !( oldTfoms == glob_mo[ _MO_KOD_TFOMS ] )
        // вывести верхние строки главного экрана
        r0 := main_up_screen()
        // вывести центральные строки главного экрана
        main_center_screen( r0 )
      Endif
      change_sys_date() // перечитать системную дату
      // put_icon(__s_full_name() + __s_version(), 'MAIN_ICON') // перевывести заголовок окна
      put_icon( full_name_version(), 'MAIN_ICON' ) // перевывести заголовок окна
      @ r0, 0 Say full_date( sys_date ) Color 'W+/N' // перевывести дату
      @ r0, MaxCol() -4 Say hour_min( Seconds() ) Color 'W+/N' // перевывести время
    Enddo
    setinisect( tmp_ini, 'task', { { 'current_task', lstr( k ) } } )
  Endif

  Return Nil

// вывести верхние строки главного экрана
Function main_up_screen()
  Local i, k, s, arr[ 2 ]

  fillscreen( p_char_screen, p_color_screen ) // FillScreen('█','N+/N')
  s := 'Код ' + iif( glob_mo[ _MO_IS_MAIN ], 'МО', 'обособленного подразделения' ) + ;
    ', присвоенный ТФОМС: ' + glob_mo[ _MO_KOD_TFOMS ] + ;
    ' (реестровый № ' + glob_mo[ _MO_KOD_FFOMS ] + ')'
  @ 0, 0 Say PadC( s, MaxCol() + 1 ) Color 'W+/N'
  s := iif( glob_mo[ _MO_IS_MAIN ], '', 'Обособленное подразделение: ' ) + ;
    glob_mo[ _MO_FULL_NAME ]
  k := perenos( arr, s, MaxCol() + 1 )
  For i := 1 To k
    @ i, 0 Say PadC( AllTrim( arr[ i ] ), MaxCol() + 1 ) Color 'GR+/N'
  Next
  i := get_uroven()
  If Between( i, 1, 3 )
    s := 'Уровень цен на медицинские услуги: ' + lstr( i )
  Else
    s := 'Индивидуальные тарифы на медицинские услуги'
  Endif
  @ k + 1, 0 Say Space( MaxCol() + 1 ) Color 'G+/N'
  @ k + 1, 0 Say full_date( sys_date ) Color 'W+/N'
  @ k + 1, MaxCol() -4 Say hour_min( Seconds() ) Color 'W+/N'

  Return k + 1

// вывести центральные строки главного экрана
Function main_center_screen( r0, a_parol )
  Static nLen := 11
  Static arr_name := { 'инфаркт', 'инсульт', 'ЧМТ', 'онкология', ;
    'пневмония', 'язва', 'родовая травма', ;
    'новорожденный с низкой массой тела', ;
    'астма', 'диабет', 'панкреатит' }
  Local s, i, c, k, t_arr, r1, buf, mst := ''

  g_arr_stand := {}
  If ValType( glob_mo[ _MO_STANDART ] ) == 'A'
    For k := 1 To Len( glob_mo[ _MO_STANDART ] )
      t_arr := { glob_mo[ _MO_STANDART, k, 1 ], {} }
      mst := PadR( glob_mo[ _MO_STANDART, k, 2 ], nLen )
      For i := 1 To nLen
        c := SubStr( mst, i, 1 )
        If c == '1'
          AAdd( t_arr[ 2 ], i )
        Endif
      Next
      AAdd( g_arr_stand, AClone( t_arr ) )
    Next
  Endif
  If .t. // empty(mst)
    If ValType( a_parol ) == 'A' .and. ( k := Len( a_parol ) ) > 0
      r1 := r0 + Int( ( MaxRow() - r0 - k ) / 2 ) -1
      n_message( a_parol, , 'W+/W*', 'R/W*', r1, , 'N+/W*' )
    Endif
  Else
    s := 'Нозологические формы, по которым МО участвует в выполнении стандартов:'
    For i := 1 To nLen
      c := SubStr( mst, i, 1 )
      If eq_any( c, '1', '2' )
        s += ' ' + arr_name[ i ]
        If c == '2'
          s += '[*]'
        Endif
        s += ','
      Endif
    Next
    s := Left( s, Len( s ) -1 )
    t_arr := Array( 2 )
    k := perenos( t_arr, s, 64 )
    r1 := r0 + Int( ( MaxRow() - r0 - k ) / 2 ) -1
    If ( k := Len( a_parol ) ) > 0
      If r1 - r0 < k + 4
        r1 := r0 + k + 4
      Endif
      buf := save_box( r1 - k -4, 0, r1 -1, MaxCol() )
      f_message( a_parol, , 'W+/W*', 'R/W*', r1 - k -3 )
    Endif
    n_message( t_arr, , 'W/W', 'N/W', r1, , 'N+/W' )
    If buf != NIL
      rest_box( buf )
    Endif
  Endif

  Return Nil

//
Function m_help()
  Local tmp_help, pt

  tmp_help := chm_help_code
  chm_help_code := 100  // ?????
  f_help()
  chm_help_code := tmp_help

  Return Nil

// 16.11.23
Function f_first( is_create )
  Local is_local_version := .t.
  Local nameTask := strippath( hb_argv( 0 ) ) // имя запущенной задачи

  Request HB_CODEPAGE_RU866
  hb_cdpSelect( 'RU866' )
  Request HB_LANG_RU866
  hb_langSelect( 'RU866' )

  Request DBFNTX
  rddSetDefault( 'DBFNTX' )

  // SET(_SET_EVENTMASK,INKEY_KEYBOARD)
  Set Scoreboard Off
  Set Exact On
  Set Date GERMAN
  Set Wrap On
  Set Century On
  Set Exclusive On
  Set Deleted On
  SetBlink( .f. )

  Public help_code := -1

  Public yes_color := .t.

  Public color0, color1, cColorWait, cColorSt2Msg, cColorStMsg, ;
    cCalcMain, cHelpCMain, cColorText, ;
    cHelpCTitle, cHelpCStatus, cDataCScr, cDataCGet, cDataCSay, ;
    cDataCMenu, color13, color14, cColorSt1Msg, cDataPgDn, col_tit_popup, ;
    color5, color8, col1menu := '', col2menu := '', ;
    color_uch, col_tit_uch
  Public n_list := 1, tek_stroke := 0, fp
  Public p_color_screen := 'W/N*', p_char_screen := ' ' // заполнение экрана
  Public c__cw := 'N+/N' // цвет теней
  //
  Public cur_drv := DiskName()
  Public cur_dir := chip_currpath()
  Public dir_server := '', p_name_comp := ''
  Public dir_exe := hb_DirBase()

  color0 := 'N/BG, W+/N'
  color1 := 'W+/B, W+/R'
  color_uch := 'B/BG, W+/B' ; col_tit_uch := 'B+/BG'
  col1menu := color0 + ', B/BG, BG+/N'
  col2menu := color0 + ', B/BG, BG+/N'
  col_tit_popup := 'B/BG'
  //
  cColorStMsg := 'W+/R, , , , B/W'                 // Stat_msg
  cColorSt1Msg := 'W+/R, , , , B/W'                // Stat_msg
  cColorSt2Msg := 'GR+/R, , , , B/W'               // Stat_msg
  cColorWait := 'W+/R*, , , , B/W'                 // Ждите
  //
  cCalcMain := 'N/W, GR+/R'                     // Калькулятор
  //
  cColorText := 'W+/N, BG+/N, , , B/W'
  //
  cHelpCMain := 'W+/RB, W+/N, , , B/W'             // Помощь
  cHelpCTitle := 'G+/RB'
  cHelpCStatus := 'BG+/RB'
  //     Ввод данных
  cDataCScr  := 'W+/B, B/BG'
  cDataCGet  := 'W+/B, W+/R, , , BG+/B'
  cDataCSay  := 'BG+/B, W+/R, , , BG+/B'
  cDataCMenu := 'N/BG, W+/N, , , B/W'
  cDataPgDn  := 'BG/B'
  color5     := 'N/W, GR+/R, , , B/W'
  color8     := 'GR+/B, W+/R'
  color13    := 'W/B, W+/R, , , BG+/B'             // некотоpое выделение
  color14    := 'G+/B, W+/R'
  //
  Delete file ttt.ttt
  //

  // verify_1_task()
  If isexerunning( nameTask ) // проверить, запущена ли уже данная задача, если 'да' - выход из задачи
    func_error( 10, 'Программа "' + Upper( nameTask ) + '" уже запущена. Запуск второй копии не разрешён!' )
    Set Color To
    Set Cursor On
    CLS
    Quit
  Endif
  //
  If hb_FileExists( 'server.mem' )
    ft_use( 'server.mem' )
    dir_server := AllTrim( ft_readln() )
    If !ft_eof()
      ft_skip()
      p_name_comp := AllTrim( ft_readln() )
      If cslash $ p_name_comp
        p_name_comp := ''
      Endif
    Endif
    If Len( p_name_comp ) < 2
      p_name_comp := AllTrim( NetName() ) + cslash + hb_UserName()
    Endif
    ft_use()
    is_local_version := .f.
  Else // иначе = текущий каталог
    dir_server := cur_dir
  Endif
  If Right( dir_server, 1 ) != cslash
    dir_server += cslash
  Endif
  is_server( dir_server, cur_dir )
  If !is_create .and. !hb_FileExists( dir_server + 'human' + sdbf )
    func_error( 'Не обнаружены файлы базы данных! Обратитесь к системному администратору.' )
    Quit
  Endif
  //
  If hb_FileExists( dir_server + 'plat.dbf' )
    func_error( 'Вероятнее всего, Вы запускаете программу в каталоге СЧЕТА. Это недопустимо!' )
    Quit
  Endif
  Set Key K_ALT_F3 To calendar
  Set Key K_ALT_F2 To calc
  Set Key K_ALT_X  To f_end
  Public flag_chip := .f.
  ReadInsert( .t. ) // режим редактирования по умолчанию Insert
  Keyboard ''
  KSetNum( .t. )    // включить NumLock
  SetCursor( 0 )
  Set Color To

  Return is_local_version

// 02.11.15
Function hard_err( p )
  // k = 1 - проверка диска на наличие временного файла hard_err.meh
  // и, если он есть, вывод текста о необходимости переиндексирования;
  // создание временного файла hard_err.meh 'CREATE'
  // k = 2 - удаление временного файла hard_err.meh 'DELETE'
  Local k := 3, arr := {}

  If ValType( p ) == 'N'
    k := p
  Elseif ValType( p ) == 'C'
    p := Upper( p )
    Do Case
    Case p == 'CREATE'
      k := 1
    Case p == 'DELETE'
      k := 2
    Endcase
  Endif
  Do Case
  Case k == 1
    If File( 'hard_err.meh' )
      fillscreen( p_char_screen, p_color_screen )
      AAdd( arr, 'Последний раз при выходе из задачи был сбой по питанию.' )
      AAdd( arr, '. . .' )
      AAdd( arr, 'Поэтому Вам настоятельно рекомендуется выполнить' )
      AAdd( arr, 'режим "Переиндексирование", т.к. вполне вероятно, что' )
      AAdd( arr, 'некоторые индексные файлы были испорчены или разрушены.' )
      Keyboard ''
      f_message( arr, , color1, color8, , , color1 )
      If f_alert( { PadC( 'Выберите действие', 60, '.' ) }, ;
          { ' Выход из задачи ', ' Продолжение работы ' }, ;
          1, 'W+/N', 'N+/N', 20, , 'W+/N, N/BG' ) != 2
        Set Color To
        Set Cursor On
        CLS
        Quit
      Endif
      fillscreen( p_char_screen, p_color_screen )
    Endif
    StrFile( 'hard_error', 'hard_err.meh' )
  Case k == 2
    Delete file hard_err.meh
  Endcase

  Return Nil

// 13.06.22
Function f_end( yes_copy )
  Static group_ini := 'RAB_MESTO'
  Local i, spath := '', bSaveHandler := ErrorBlock( {| x| Break( x ) } )

  Begin Sequence
    write_rest_pp() // записать незаписанные истории болезней из приёмного покоя
    Close All
    Default yes_copy To .t.
    If yes_copy
      i := getinivar( tmp_ini, { { group_ini, 'base_copy', '1' }, ;
        { group_ini, 'path_copy', '' } } )
      If i[ 1 ] != Nil .and. i[ 1 ] == '1' .and. g_slock1task( sem_task, sem_vagno )
        If Len( i ) > 1 .and. i[ 2 ] != Nil .and. !Empty( i[ 2 ] )
          spath := i[ 2 ]
        Endif
        m_copy_db_from_end( .f., spath ) // резервное копирование
        g_sunlock( sem_vagno ) // разрешение доступа всем
      Endif
    Endif
  RECOVER USING error
    //
  End
  //
  Begin Sequence
    g_sclose( sem_task ) // удалить все семафоры для данной задачи
  RECOVER USING error
    //
  End
  ErrorBlock( bSaveHandler )
  //
  hard_err( 'delete' )
  If __mvExist( 'cur_dir' )
    FileDelete( cur_dir + 'tmp*.dbf' )
    FileDelete( cur_dir + 'tmp*.ntx' )
    FileDelete( _tmp_dir1 + '*.*' )
    If hb_DirExists( cur_dir + _tmp_dir ) .and. hb_DirDelete( cur_dir + _tmp_dir ) != 0
      // func_error(4, 'Не могу удалить каталог ''+'cur_dir'+'_tmp_dir)
    Endif
    FileDelete( _tmp2dir1 + '*.*' )
    If hb_DirExists( cur_dir + _tmp2dir ) .and. hb_DirDelete( cur_dir + _tmp2dir ) != 0
      // func_error(4, 'Не могу удалить каталог ' + cur_dir + _tmp2dir)
    Endif
  Endif
  // удалим файлы отчетов в формате '*.HTML' из временной директории
  FileDelete( hb_DirTemp() + '*.html' )
  Set Key K_ALT_F3 To
  Set Key K_ALT_F2 To
  Set Key K_ALT_X  To
  Set Color To
  Set Cursor On
  CLS
  Quit

  Return Nil

// 03.12.13
Function f_err_sem_vagno_task( n_Task )

  Return func_error( 4, 'В задаче "' + array_tasks[ ind_task( n_Task ), 5 ] + ;
    '" выполняется ОТВЕТСТВЕННАЯ операция. Доступ временно запрещён!' )

// 03.12.13
Function mo_lock_task( n_Task )
  Local i, fl := .t., n := 0

  Default n_Task To glob_task
  If glob_task == n_Task // если вызывается из задачи n_Task,
    ++n                  // то максимум 1 пользователь
  Endif
  i := ind_task( n_Task )
  If !g_svaluenlock( f_name_task( n_Task ), n, sem_vagno_task[ n_Task ] )
    fl := func_error( 'В задаче "' + array_tasks[ i, 5 ] + '" работают пользователи. Операция временно запрещена!' )
  Endif

  Return fl

// 03.12.13
Function mo_unlock_task( n_Task )

  Return g_sunlock( sem_vagno_task[ n_Task ] )

// вернуть имя задачи по цифровому коду
Function f_name_task( n_Task )
  Local it, s

  Default n_Task To glob_task
  s := lstr( n_Task )
  If ( it := AScan( array_tasks, {| x| x[ 2 ] == n_Task } ) ) > 0
    s := array_tasks[ it, 1 ]
  Endif

  Return s

// проверить, доступна ли данному МО конкретная задача
Function is_task( n_Task )
  Local it

  If !( Type( 'array_tasks' ) == 'A' ) // в начале задачи  ещё не определён массив
    Return .f.
  Endif
  Default n_Task To glob_task
  If ( it := AScan( array_tasks, {| x| x[ 2 ] == n_Task } ) ) == 0
    Return .f.
  Endif

  Return array_tasks[ it, 4 ]

// вернуть индекс массива конкретной задачи
Function ind_task( n_Task )
  Local it

  Default n_Task To glob_task
  If ( it := AScan( array_tasks, {| x| x[ 2 ] == n_Task } ) ) == 0
    it := 3 // ОМС
  Endif

  Return it

// 14.06.21
Function find_unfinished_reestr_sp_tk( is_oper, is_count )
  Static max_rec := 9900000 // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  Local fl := .t., s, buf := save_maxrow(), arr, rech := 0, af := {}, bSaveHandler

  Default is_oper To .t., is_count To .t.

  mywait( 'Подождите, проверяем завершенность информационного обмена реестрами СП и ТК с ТФОМС...' )

  bSaveHandler := ErrorBlock( {| x| Break( x ) } )
  Begin Sequence
    If is_count
      r_use( dir_server + 'human', , 'HUMAN' )
      rech := LastRec()
      Use
    Endif
    r_use( dir_server + 'mo_rees', , 'REES' )
    r_use( dir_server + 'mo_xml', , 'MO_XML' )
    Set Relation To REESTR into REES
    Index On FNAME to ( cur_dir + 'tmp_xml' ) For TIP_IN == _XML_FILE_SP .and. Empty( TWORK2 )
    Go Top
    Do While !Eof()
      AAdd( af, { RTrim( mo_xml->FNAME ), lstr( rees->NSCHET ) } )
      Skip
    Enddo
    Close databases
    rest_box( buf )
    If ( fl := ( Len( af ) > 0 .or. rech > max_rec ) )
      If rech > max_rec
        arr := { 'До исчерпания лимита базы данных у Вас', ;
          'осталась возможность добавить ' + lstr( 10000000 - rech ) + ' листов учёта.' }
      Endif
      If Len( af ) > 0
        s := 'Не завершено чтение '
        If Len( af ) == 1
          s += 'реестра СП и ТК ' + af[ 1, 1 ] + ' (реестр ' + af[ 1, 2 ] + ')'
        Else
          s += lstr( Len( af ) ) + ' реестров СП и ТК'
        Endif
        arr := { '', s }
      Endif
      If is_oper
        AAdd( arr, '' )
        AAdd( arr, 'Операция запрещена!' )
      Endif
      n_message( arr, { '', 'Обратитесь к разработчикам' }, 'GR+/R', 'W+/R', , , 'G+/R' )
    Endif
  RECOVER USING error
    Close databases
    rest_box( buf )
  End
  ErrorBlock( bSaveHandler )

  Return fl

// 10.06.21 проверить, есть ли неотосланные просроченные листы учёта
Function find_time_limit_human_reestr_sp_tk()
  Local buf := SaveScreen(), arr[ 10, 2 ], i, mas_pmt, r, c, n, d := sys_date -23
  Local fl := .f., bSaveHandler := ErrorBlock( {| x| Break( x ) } )

  mywait( 'Подождите, проверяем просроченные случаи (неотправленные в ТФОМС)...' )
  Begin Sequence
    dbCreate( cur_dir + 'tmp_tl', { { 'kod_h', 'N', 8, 0 }, ;
      { 'kod_xml', 'N', 6, 0 }, ;
      { 'dni', 'N', 2, 0 } } )
    Use ( cur_dir + 'tmp_tl' ) new
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human', , 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server + 'mo_refr', dir_server + 'mo_refr', 'REFR' )
    r_use( dir_server + 'mo_xml', , 'MO_XML' )
    r_use( dir_server + 'mo_rees', , 'REES' )
    Set Relation To KOD_XML into MO_XML
    r_use( dir_server + 'mo_rhum', , 'RHUM' )
    Set Relation To reestr into REES
    Index On Str( reestr, 6 ) to ( cur_dir + 'tmp_rhum' ) For OPLATA == 2 .and. d < rees->DSCHET
    Go Top
    Do While !Eof()
      If ( r := sys_date - rees->DSCHET ) <= 0
        r := 1
      Endif
      human->( dbGoto( rhum->kod_hum ) )
      // проверим, не попал ли ещё в другой реестр (или прочий счёт)
      If emptyall( human->schet, human_->REESTR ) .and. rhum->REES_ZAP == human_->REES_ZAP
        Select REFR
        find ( Str( 1, 1 ) + Str( mo_xml->REESTR, 6 ) + Str( 1, 1 ) + Str( rhum->kod_hum, 8 ) )
        Do While refr->TIPD == 1 .and. refr->KODD == mo_xml->REESTR .and. ;
            refr->TIPZ == 1 .and. refr->KODZ == rhum->kod_hum  .and. !Eof()
          If !eq_any( refr->REFREASON, 50, 57 )
            Select TMP_TL
            Append Blank
            tmp_tl->kod_h   := rhum->kod_hum
            tmp_tl->kod_xml := mo_xml->kod
            tmp_tl->dni     := r
            If LastRec() % 1000 == 0
              Commit
            Endif
          Endif
          Select REFR
          Skip
        Enddo
      Endif
      Select RHUM
      Skip
    Enddo
  RECOVER USING error
    fl := .t.
  End
  ErrorBlock( bSaveHandler )
  If fl
    Close databases
    RestScreen( buf )
    Return func_error( 4, 'Непонятная ошибка. Выполните переиндексирование в подзадаче ОМС' )
  Endif
  Select TMP_TL
  If LastRec() > 0
    afillall( arr, 0 )
    i := 0
    Index On dni to ( cur_dir + 'tmp_tl' ) unique
    Go Top
    If tmp_tl->dni <= 10 // не более 10 дней просрочено, иначе не выводим
      Do While !Eof()
        ++i
        If i == 10
          arr[ i, 1 ] := -1
          Exit
        Endif
        arr[ i, 1 ] := tmp_tl->dni
        Skip
      Enddo
      Set Index To
      Go Top
      Do While !Eof()
        If ( i := AScan( arr, {| x| x[ 1 ] == tmp_tl->dni } ) ) == 0
          i := 10
        Endif
        arr[ i, 2 ] ++
        Skip
      Enddo
      Close databases
      mas_pmt := {}
      n := 0
      For i := 1 To 10
        If emptyany( arr[ i, 1 ], arr[ i, 2 ] )
          Exit
        Elseif arr[ i, 1 ] == -1
          AAdd( mas_pmt, lstr( arr[ i, 2 ] ) + ' чел. - просрочено более ' + lstr( arr[ 9, 1 ] ) + ' дн.' )
        Else
          AAdd( mas_pmt, lstr( arr[ i, 2 ] ) + ' чел. - просрочено ' + lstr( arr[ i, 1 ] ) + ' дн.' )
        Endif
        n := Max( n, Len( ATail( mas_pmt ) ) )
      Next
      If Len( mas_pmt ) > 0
        i := 1
        r := MaxRow() - Len( mas_pmt ) -4
        c := Int( ( 80 - n -3 ) / 2 )
        status_key( '^<Esc>^ выход из режима и вход в задачу  ^<Enter>^ просмотр просроченных случаев' )
        str_center( r -1, 'Обнаружены просроченные случаи:', 'W+/N*' )
        Do While ( i := popup_prompt( r, c, i, mas_pmt ) ) > 0
          f1find_time_limit_human_reestr_sp_tk( i, arr )
        Enddo
      Endif
    Endif
  Endif
  Close databases
  RestScreen( buf )

  Return Nil

//
Function f1find_time_limit_human_reestr_sp_tk( i, arr )
  Local n_file := cur_dir + 'time_lim' + stxt, sh := 80, HH := 60

  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( '' )
  add_string( Center( 'Список случаев, вернувшихся с ошибкой и ещё не отосланных в ТФОМС', sh ) )
  If i == 10
    add_string( Center( '(просрочено более ' + lstr( arr[ 9, 1 ] ) + ' дн.)', sh ) )
  Else
    add_string( Center( '(просрочено ' + lstr( arr[ i, 1 ] ) + ' дн.)', sh ) )
  Endif
  add_string( Center( 'по состоянию на ' + full_date( sys_date ) + ' ' + hour_min( Seconds() ), sh ) )
  add_string( '' )
  r_use( dir_server + 'mo_otd', , 'OTD' )
  r_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To otd into OTD
  Use ( cur_dir + 'tmp_tl' ) new
  Set Relation To kod_h into HUMAN
  If i == 10
    Index On Upper( human->fio ) to ( cur_dir + 'tmp_tl' ) For dni > arr[ 9, 1 ]
  Else
    Index On Upper( human->fio ) to ( cur_dir + 'tmp_tl' ) For dni == arr[ i, 1 ]
  Endif
  i := 0
  Go Top
  Do While !Eof()
    verify_ff( HH, .t., sh )
    add_string( lstr( ++i ) + '. ' + AllTrim( human->fio ) + ', ' + full_date( human->date_r ) + ;
      iif( Empty( otd->SHORT_NAME ), '', ' [' + AllTrim( otd->SHORT_NAME ) + ']' ) + ;
      ' ' + date_8( human->n_data ) + '-' + date_8( human->k_data ) )
    Select TMP_TL
    Skip
  Enddo
  Close databases
  FClose( fp )
  viewtext( n_file, , , , .f., , , 2 )

  Return Nil

//
Function my_mo_begin_task()
  Local fl := .t.

  If glob_mo[ _MO_KOD_TFOMS ] == kod_VOUNC
    fl := vounc_begin_task()
  Endif

  Return fl
