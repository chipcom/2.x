// mo_st39.prg - стоматологическая форма 39 и прочие функции
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static f39h_nastr   := 'f39hnast.ini'
Static f39h_sect    := 'Форма 39Х - '
Static f39hdp_sect  := 'Форма 39ХDP - '
Static f39hdz_sect  := 'Форма 39ХDZ - '
Static f39t_nastr   := 'f39tnast.ini'
Static f39t_sect    := 'Форма 39T - '
Static f39tdp_sect  := 'Форма 39TDP - '
Static f39tdz_sect  := 'Форма 39TDZ - '
Static f39tdd_sect  := 'Форма 39TDD - '

// 16.11.16
Function f_stom_39_hirur()

  f39_hir()

  Return Nil

// 16.11.16
Function f_stom_39_terap()

  f39_ter()

  Return Nil

// 17.11.25 Запрос лиц, подлежащих диспасеризации, методом многовариантного поиска
Function mnog_poisk_dvn1()

  Local mm_tmp := {}, mm_sort, t_arr[ 2 ]
  Local buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    tmp_help := help_code, hGauge, name_file := cur_dir() + '_kartDVN.txt', ;
    sh := 80, HH := 77, i, j, a_diagnoz[ 10 ], ta, name_dbf := cur_dir() + '_kartDVN' + sdbf(), ;
    mm_da_net := { { 'нет', 1 }, { 'да ', 2 } }, ;
    mm_tip := { { 'диспансеризация', 1 }, { 'профилактический осмотр', 2 } }, ;
    mm_mest := { { 'Волгоград или область', 1 }, { 'иногородние', 2 } }, ;
    mm_disp := { { 'неважно', 0 }, { 'не проходили', 1 }, { 'прошли', 2 } }, ;
    mm_death := { { 'выводить всех', 0 }, { 'не выводить умерших', 1 }, { 'выводить только умерших', 2 } }, ;
    mm_prik := { { 'неважно', 0 }, ;
    { 'прикреплён к нашей МО', 1 }, ;
    { 'прикреплён к другим МО', 2 }, ;
    { 'прикрепление неизвестно', 3 } }, ;
    tmp_file := cur_dir() + 'tmp_mn_p' + sdbf(), ;
    k_fio, k_adr, tt_fio[ 10 ], tt_adr[ 10 ], fl_exit := .f.
  Local adbf := { ;
    { 'BUKVA',   'C',  1, 0 }, ; // буква в участке
    { 'UCHAST',   'N',  2, 0 }, ; // номер участка
    { 'KOD_VU',   'N',  6, 0 }, ; // код в участке
    { 'FIO',   'C', 50, 0 }, ; // Ф.И.О. пациента
    { 'PHONE',   'C', 40, 0 }, ; // телефон пациента
    { 'POL',   'C',  1, 0 }, ; // пол
    { 'DATE_R', 'C', 10, 0 }, ; // дата рождения пациента
    { 'LET',   'N',  2, 0 }, ; // сколько лет в этом году
    { 'ADRESR',  'C', 100, 0 }, ; // адрес пациента
    { 'ADRESP',  'C', 100, 0 }, ; // адрес пациента
    { 'RABOTA',   'C', 12, 0 }, ; // 0-работ,1-нераб
    { 'POLIS',     'C', 17, 0 }, ; // полис
    { 'KOD_SMO',   'C',  5, 0 }, ; // реестровый номер СМО
    { 'SMO',       'C', 80, 0 }, ; // наименование СМО
    { 'SNILS',   'C', 14, 0 }, ;
    { 'PENSIONER', 'C', 11, 0 }, ; // является пенсионером?;0-нет, 1-да;
    { 'MO_PR',     'C',  6, 0 }, ; // код МО приписки
    { 'MONAME_PR', 'C', 60, 0 }, ; // наименование МО приписки
    { 'DATE_PR', 'C', 10, 0 }, ; // дата приписки
    { 'LAST_L_U', 'C', 10, 0 };  // дата последнего листа учёта
  }
  If !myfiledeleted( name_dbf )
    Return Nil
  Endif
  Private mm_smo := {}, pyear, mstr_crb := 0, is_kategor2 := .f., is_talon := ret_is_talon()
  If is_talon
    is_kategor2 := !Empty( stm_kategor2 )
  Endif
//  For i := 1 To Len( glob_arr_smo )
//    If glob_arr_smo[ i, 3 ] == 1
//      AAdd( mm_smo, { glob_arr_smo[ i, 1 ], PadR( lstr( glob_arr_smo[ i, 2 ] ), 5 ) } )
//    Endif
//  Next
  For i := 1 To Len( smo_volgograd() )
    If smo_volgograd()[ i, 3 ] == 1
      AAdd( mm_smo, { smo_volgograd()[ i, 1 ], PadR( lstr( smo_volgograd()[ i, 2 ] ), 5 ) } )
    Endif
  Next
  ta := f2_mnog_poisk_dvn2(,,, 1 )
  Keyboard Chr( K_TAB )
  AAdd( mm_tmp, { 'net_dann', 'D', 8, 0,, ;
    nil, ;
    CToD( '' ), nil, ;
    'Не обращался в нашу МО после этой даты' } )
  AAdd( mm_tmp, { 'god', 'N', 4, 0, '9999', ;
    nil, ;
    0, nil, ;
    'Год проведения диспансеризации' } )
  AAdd( mm_tmp, { 'tip_disp', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_tip, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_tip, x ) }, ;
    'Тип диспансеризации', ;
    {| g, o| iif( o == m1tip_disp, ;
    nil, ;
    ( ta := f2_mnog_poisk_dvn2(,,, 1 ), m1v_period := ta[ 1 ], mv_period := ta[ 2 ] );
    ), ;
    .t. ;
    };
    };
    )
  AAdd( mm_tmp, { 'v_period', 'C', 255, 0, NIL, ;
    {| x| menu_reader( x, { {| k, r, c| f2_mnog_poisk_dvn2( k, r, c ) } }, A__FUNCTION ) }, ;
    ta[ 1 ], {| x| ta[ 2 ] }, ;
    'Возрастные периоды диспансеризации' } )
  AAdd( mm_tmp, { 'o_disp', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_disp, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_disp, x ) }, ;
    'Отношение к диспансеризации' } )
  AAdd( mm_tmp, { 'o_prik', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_prik, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_prik, x ) }, ;
    'Отношение к прикреплению' } )
  AAdd( mm_tmp, { 'o_death', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_death, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_death, x ) }, ;
    'Сведения о смерти по сведениям ТФОМС' } )
  Private arr_uchast := {}
  If is_uchastok > 0
    AAdd( mm_tmp, { 'bukva', 'C', 1, 0, '@!', ;
      nil, ;
      ' ', nil, ;
      'Буква (перед участком)' } )
    AAdd( mm_tmp, { 'uchast', 'N', 1, 0,, ;
      {| x| menu_reader( x, ;
      { {| k, r, c| get_uchast( r + 1, c ) } }, A__FUNCTION ) }, ;
      0, {|| init_uchast( arr_uchast ) }, ;
      'Участок (участки)' } )
    mm_sort := { ;
      { '№ участка + Лет дисп-ии + ФИО', 1 }, ;
      { '№ участка + Лет дисп-ии + Адрес', 2 }, ;
      { '№ участка + Адрес + Лет дисп-ии', 4 };
      }
    If is_uchastok == 1
      AAdd( mm_sort, { '№ участка + № в участке', 3 } )
    Elseif is_uchastok == 2
      AAdd( mm_sort, { '№ участка + Код по картотеке', 3 } )
    Elseif is_uchastok == 3
      AAdd( mm_sort, { '№ участка + номер АК МИС', 3 } )
    Endif
  Else
    mm_sort := { ;
      { 'Лет дисп-ии + ФИО', 1 }, ;
      { 'Лет дисп-ии + Адрес', 2 }, ;
      { 'Код по картотеке', 3 };
      }
    del_array( adbf, 1 ) // убираем участок
    del_array( adbf, 1 ) // убираем участок
  Endif
  AAdd( mm_tmp, { 'fio', 'C', 20, 0, '@!', ;
    nil, ;
    Space( 20 ), nil, ;
    'ФИО (начальные буквы или шаблон)' } )
  AAdd( mm_tmp, { 'mi_git', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mm_mest, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    'Место жительства:' } )
  AAdd( mm_tmp, { '_okato', 'C', 11, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| get_okato_ulica( k, r, c, { k, m_okato, } ) } }, A__FUNCTION ) }, ;
    Space( 11 ), {| x| Space( 11 ) }, ;
    'Адрес регистрации (ОКАТО)' } )
  AAdd( mm_tmp, { 'adres', 'C', 20, 0, '@!', ;
    nil, ;
    Space( 20 ), nil, ;
    'Улица (подстрока или шаблон)' } )
  If is_talon
    AAdd( mm_tmp, { 'kategor', 'N', 2, 0, NIL, ;
      {| x| menu_reader( x, mo_cut_menu( stm_kategor ), A__MENUVERT ) }, ;
      0, {|| Space( 10 ) }, ;
      'Код категории льготы' } )
    If is_kategor2
      AAdd( mm_tmp, { 'kategor2', 'N', 4, 0, NIL, ;
        {| x| menu_reader( x, stm_kategor2, A__MENUVERT ) }, ;
        0, {|| Space( 10 ) }, ;
        'Категория МО' } )
    Endif
  Endif
  AAdd( mm_tmp, { 'pol', 'C', 1, 0, '!', ;
    nil, ;
    ' ', nil, ;
    'Пол', {|| mpol $ ' МЖ' } } )
  AAdd( mm_tmp, { 'god_r_min', 'D', 8, 0,, ;
    nil, ;
    CToD( '' ), nil, ;
    'Дата рождения (минимальная)' } )
  AAdd( mm_tmp, { 'god_r_max', 'D', 8, 0,, ;
    nil, ;
    CToD( '' ), nil, ;
    'Дата рождения (максимальная)' } )
  AAdd( mm_tmp, { 'rab_nerab', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, menu_rab(), A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    'Работающий/неработающий' } )
  AAdd( mm_tmp, { 'smo', 'C', 5, 0, NIL, ;
    {| x| menu_reader( x, mm_smo, A__MENUVERT ) }, ;
    Space( 5 ), {|| Space( 10 ) }, ;
    'Страховая компания' } )
  AAdd( mm_tmp, { 'i_sort', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_sort, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_sort, x ) }, ;
    'Сортировка выходного документа' } )
  Delete File ( tmp_file )
  init_base( tmp_file,, mm_tmp, 0 )
  //
  k := f_edit_spr( A__APPEND, mm_tmp, 'множественному запросу', ;
    'e_use(cur_dir()+"tmp_mn_p")', 0, 1,,,,, 'write_mn_p_DVN1' )
  If k > 0
    mywait()
    Use ( tmp_file ) New Alias MN
    If is_talon .and. mn->kategor == 0
      is_talon := ( is_kategor2 .and. mn->kategor2 > 0 )
    Endif
    Private mfio := '', madres := '', arr_vozr := list2arr( mn->v_period ), arrSvozr := slist2arr( mn->v_period )
    If !Empty( mn->fio )
      mfio := AllTrim( mn->fio )
      If !( Right( mfio, 1 ) == '*' )
        mfio += '*'
      Endif
    Endif
    If !Empty( mn->adres )
      madres := AllTrim( mn->adres )
      If !( Left( madres, 1 ) == '*' )
        madres := '*' + madres
      Endif
      If !( Right( madres, 1 ) == '*' )
        madres += '*'
      Endif
    Endif
    Private c_view := 0, c_found := 0
    status_key( '^<Esc>^ - прервать поиск' )
    hGauge := gaugenew(,,, 'Поиск в картотеке', .t. )
    gaugedisplay( hGauge )
    //
    dbCreate( cur_dir() + 'tmp', { { 'kod', 'N', 7, 0 } },, .t., 'TMP' )
    If !Empty( mn->net_dann ) // ВСТАВКА
      r_use( dir_server() + 'hum_p', dir_server() + 'hum_pkk', 'HUM_P' )
      r_use( dir_server() + 'hum_ort', dir_server() + 'hum_ortk', 'HUM_ORT' )
      r_use( dir_server() + 'kas_pl', dir_server() + 'kas_pl1', 'KS_PL' )
      r_use( dir_server() + 'kas_ORT', dir_server() + 'kas_ort1', 'KS_ORT' )
      r_use( dir_server() + 'mo_regi', dir_server() + 'mo_regi3', 'RU' )
      r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_r', 'PP' )
      r_use( dir_server() + 'mo_nnapr',, 'NAPR' )
      Index On Str( FIELD->kod_k, 7 ) + DToS( FIELD->date_d ) To tmp_NA
    Endif // ВСТАВКА- КОНЕЦ
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human', dir_server() + 'humankk', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server() + 'kartote2',, 'KART2' )
    r_use( dir_server() + 'kartote_',, 'KART_' )
    r_use( dir_server() + 'kartotek',, 'KART' )
    Set Relation To RecNo() into KART_, RecNo() into KART2
    Go Top
    Do While !Eof()
      gaugeupdate( hGauge, RecNo() / LastRec() )
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      f1_mnog_poisk_dvn1( @c_view, @c_found )
      Select KART
      Skip
    Enddo
    closegauge( hGauge )
    j := tmp->( LastRec() )
    Close databases
    If j == 0
      If !fl_exit
        func_error( 4, 'Нет сведений!' )
      Endif
    Else
      Use ( tmp_file ) New Alias MN
      arr_title := { ;
        '─────┬', ;
        ' №№  │', ;
        ' пп  │', ;
        '─────┴' }
      If is_uchastok > 0 .or. mn->i_sort == 3 // Код по картотеке
        arr_title[ 1 ] += '──────────┬'
        arr_title[ 2 ] += ' Участок  │'
        arr_title[ 3 ] += '   код    │'
        arr_title[ 4 ] += '──────────┴'
      Endif
      arr_title[ 1 ] += '───────────────────────────────────────────┬──┬──────────┬───────────────────────────────────┬─────┬──────────'
      arr_title[ 2 ] += '             Ф.И.О. пациента               │Ле│   дата   │              Адрес                │при- │последний '
      arr_title[ 3 ] += '                (телефон)                  │т │ рождения │                                   │креп.│л/у по ОМС'
      arr_title[ 4 ] += '───────────────────────────────────────────┴──┴──────────┴───────────────────────────────────┴─────┴──────────'
      reg_print := f_reg_print( arr_title, @sh, 2 )
      dbCreate( name_dbf, adbf,, .t., 'DVN' )
      r_use( dir_server() + 'human', dir_server() + 'humankk', 'HUMAN' )
      r_use( dir_server() + 'kartote2',, 'KART2' )
      r_use( dir_server() + 'kartote_',, 'KART_' )
      r_use( dir_server() + 'kartotek',, 'KART' )
      Set Relation To RecNo() into KART_, To RecNo() into KART2
      Use ( cur_dir() + 'tmp' ) new
      Set Relation To FIELD->kod into KART
      stat_msg( 'Составление текстового и DBF-файлов (' + lstr( tmp->( LastRec() ) ) + ' чел.)' )
      If is_uchastok > 0
        If mn->i_sort == 1 // № участка + Год рождения + ФИО
          Index On Str( kart->uchast, 2 ) + Str( Abs( mn->god - Year( kart->date_r ) ), 4 ) + Upper( kart->fio ) to ( cur_dir() + 'tmp' )
        Elseif mn->i_sort == 2 // № участка + Год рождения + Адрес
          Index On Str( kart->uchast, 2 ) + Str( Abs( mn->god - Year( kart->date_r ) ), 4 ) + Upper( kart->adres ) to ( cur_dir() + 'tmp' )
        Elseif mn->i_sort == 4 // № участка + Адрес + Год рождения
          Index On Str( kart->uchast, 2 ) + Upper( kart->adres ) + Str( Abs( mn->god - Year( kart->date_r ) ), 4 ) to ( cur_dir() + 'tmp' )
        Elseif mn->i_sort == 3 // № участка + Код
          If is_uchastok == 1 // № участка + № в участке
            Index On Str( kart->uchast, 2 ) + Str( kart->kod_vu, 5 ) + Upper( kart->fio ) to ( cur_dir() + 'tmp' )
          Elseif is_uchastok == 2 // № участка + Код по картотеке
            Index On Str( kart->uchast, 2 ) + Str( kart->kod, 7 ) to ( cur_dir() + 'tmp' )
          Elseif is_uchastok == 3 // № участка + номер АК МИС
            Index On Str( kart->uchast, 2 ) + kart2->kod_AK + Upper( kart->fio ) to ( cur_dir() + 'tmp' )
          Endif
        Endif
      Else
        If mn->i_sort == 1 // Год рождения + ФИО
          Index On Str( Abs( mn->god - Year( kart->date_r ) ), 4 ) + Upper( kart->fio ) to ( cur_dir() + 'tmp' )
        Elseif mn->i_sort == 2 // Год рождения + Адрес
          Index On Str( Abs( mn->god - Year( kart->date_r ) ), 4 ) + Upper( kart->adres ) to ( cur_dir() + 'tmp' )
        Elseif mn->i_sort == 3 // Код по картотеке
          Index On Str( FIELD->kod, 7 ) to ( cur_dir() + 'tmp' )
        Endif
      Endif
      fp := FCreate( name_file )
      n_list := 1
      tek_stroke := 0
      add_string( '' )
      add_string( Center( Expand( 'РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА' ), sh ) )
      add_string( '' )
      add_string( ' == ПАРАМЕТРЫ ПОИСКА ==' )
      If !Empty( mn->net_dann )
        add_string( 'Лица, не обращавшиеся в нашу МО после ' + full_date( mn->net_dann ) )
      Endif
      If !Empty( mn->god )
        add_string( 'Год проведения диспансеризации/профосмотра: ' + lstr( mn->god ) )
        add_string( 'Тип: ' + inieditspr( A__MENUVERT, mm_tip, mn->tip_disp ) )
        If !Empty( mn->v_period )
          k := perenos( t_arr, 'Возрастные периоды: ' + AllTrim( mn->v_period ), sh )
          add_string( t_arr[ 1 ] )
          For i := 2 To k
            add_string( Space( 20 ) + t_arr[ i ] )
          Next
        Endif
      Endif
      If mn->o_death == 1
        add_string( 'За исключением умерших (по сведению ТФОМС)' )
      Elseif mn->o_death == 2
        add_string( 'Список умерших (по сведению ТФОМС)' )
      Endif
      If !Empty( mn->o_disp )
        add_string( 'Отношение к диспансеризации: ' + inieditspr( A__MENUVERT, mm_disp, mn->o_disp ) )
      Endif
      If !Empty( mn->o_prik )
        add_string( 'Отношение к прикреплению: ' + inieditspr( A__MENUVERT, mm_prik, mn->o_prik ) )
      Endif
      If is_uchastok > 0
        If !Empty( mn->bukva )
          add_string( 'Буква: ' + mn->bukva )
        Endif
        If !Empty( mn->uchast )
          add_string( 'Участок: ' + init_uchast( arr_uchast ) )
        Endif
      Endif
      If !Empty( mfio )
        add_string( 'ФИО: ' + mfio )
      Endif
      If mn->mi_git > 0
        add_string( 'Место жительства: ' + inieditspr( A__MENUVERT, mm_mest, mn->mi_git ) )
      Endif
      If !Empty( mn->_okato )
        add_string( 'Адрес регистрации (ОКАТО): ' + ret_okato_ulica( '', mn->_okato ) )
      Endif
      If !Empty( madres )
        add_string( 'Улица: ' + madres )
      Endif
      If is_talon .and. mn->kategor > 0
        add_string( 'Код категории льготы: ' + inieditspr( A__MENUVERT, stm_kategor, mn->kategor ) )
      Endif
      If is_talon .and. is_kategor2 .and. mn->kategor2 > 0
        add_string( 'Категория МО: ' + inieditspr( A__MENUVERT, stm_kategor2, mn->kategor2 ) )
      Endif
      If !Empty( mn->pol )
        add_string( 'Пол: ' + mn->pol )
      Endif
      If !Empty( mn->god_r_min ) .or. !Empty( mn->god_r_max )
        If Empty( mn->god_r_min )
          add_string( 'Лица, родившиеся до ' + full_date( mn->god_r_max ) )
        Elseif Empty( mn->god_r_max )
          add_string( 'Лица, родившиеся после ' + full_date( mn->god_r_min ) )
        Else
          add_string( 'Лица, родившиеся с ' + full_date( mn->god_r_min ) + ' по ' + full_date( mn->god_r_max ) )
        Endif
      Endif
      If mn->rab_nerab >= 0
        add_string( Upper( inieditspr( A__MENUVERT, menu_rab(), mn->rab_nerab ) ) )
      Endif
      If !Empty( mn->smo )
        add_string( 'СМО: ' + inieditspr( A__MENUVERT, mm_smo, mn->smo ) )
      Endif
      add_string( '' )
      add_string( 'Найдено пациентов: ' + lstr( tmp->( LastRec() ) ) + ' чел.' )
      AEval( arr_title, {| x| add_string( x ) } )
      ii := 0
      Select TMP
      Go Top
      Do While !Eof()
        ++ii
        @ MaxRow(), 1 Say Str( ii / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorSt2Msg
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        mdate := CToD( '' )
        Select HUMAN
        find ( Str( tmp->kod, 7 ) )
        Do While human->kod_k == tmp->kod .and. !Eof()
          If Empty( mdate )
            mdate := human->k_data
          Else
            mdate := Max( mdate, human->k_data )
          Endif
          Skip
        Enddo
        Select DVN
        Append Blank
        s1 := PadR( lstr( ii ), 6 )
        If is_uchastok > 0 .or. mn->i_sort == 3
          If is_uchastok > 0
            s := AllTrim( kart->bukva )
            dvn->bukva := kart->bukva
            If !Empty( kart->uchast )
              dvn->UCHAST := kart->uchast
              s += lstr( kart->uchast )
            Endif
            If is_uchastok == 1 .and. !Empty( kart->kod_vu ) // № участка + № в участке
              s += '/' + lstr( kart->kod_vu )
              dvn->KOD_VU := kart->kod_vu
            Elseif is_uchastok == 2 // № участка + Код по картотеке
              s += '/' + lstr( kart->kod )
              dvn->KOD_VU := kart->kod
            Elseif is_uchastok == 3 .and. !Empty( kart2->kod_AK ) // № участка + номер АК МИС
              s += '/' + LTrim( kart2->kod_AK )
              dvn->KOD_VU := Val( kart2->kod_AK )
            Endif
          Else
            s := PadL( lstr( tmp->kod ), 10 )
          Endif
          s1 += PadR( s, 11 )
        Endif
        s := ''
        If !Empty( kart_->PHONE_H )
          s += 'д.' + AllTrim( kart_->PHONE_H ) + ' '
        Endif
        If !Empty( kart_->PHONE_M )
          s += 'м.' + AllTrim( kart_->PHONE_M ) + ' '
        Endif
        If !Empty( kart_->PHONE_W )
          s += 'р.' + AllTrim( kart_->PHONE_W )
        Endif
        dvn->FIO := kart->fio
        dvn->PHONE := s
        s := AllTrim( kart->fio ) + ' ' + s
        k_fio := perenos( tt_fio, s, 43 )
        s1 += PadR( tt_fio[ 1 ], 44 )
        If ( k := iif( mn->god > 0, mn->god, Year( sys_date ) ) - Year( kart->date_r ) ) > 99
          k := 99
        Endif
        s1 += Str( k, 2 ) + ' '
        dvn->LET := k
        s1 += full_date( kart->date_r ) + ' '
        dvn->POL := kart->pol
        dvn->DATE_R := full_date( kart->date_r )
        k_adr := perenos( tt_adr, LTrim( kart->adres ), 35 )
        s1 += PadR( tt_adr[ 1 ], 36 )
        dvn->ADRESR := AllTrim( ret_okato_ulica( '', kart_->okatog, 3, 2 ) ) + ' ' + LTrim( kart->adres )
        dvn->ADRESP := AllTrim( ret_okato_ulica( '', kart_->okatop, 3, 2 ) ) + ' ' + LTrim( kart_->adresp )
        dvn->RABOTA := inieditspr( A__MENUVERT, menu_rab(), kart->RAB_NERAB )
        dvn->POLIS := LTrim( kart_->NPOLIS )
        dvn->KOD_SMO := kart_->smo
        dvn->SMO := smo_to_screen( 1 )
//        dvn->SNILS := iif( Empty( kart->SNILS ), '', Transform( kart->SNILS, picture_pf ) )
        dvn->SNILS := iif( Empty( kart->SNILS ), '', Transform_SNILS( kart->SNILS ) )
        dvn->PENSIONER := iif( kart_->PENSIONER == 1, 'пенсионер', '' )
        If !Empty( dvn->mo_pr := kart2->mo_pr )
          dvn->MONAME_PR := ret_mo( kart2->mo_pr )[ _MO_SHORT_NAME ]
          If !Empty( kart2->pc4 )
            dvn->DATE_PR := Left( kart2->pc4, 6 ) + '20' + SubStr( kart2->pc4, 7 )
          Else
            dvn->DATE_PR := full_date( kart2->DATE_PR )
          Endif
        Endif
        If Empty( kart2->MO_PR )
          s := ''
        Elseif kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ]
          s := 'наш'
        Else
          s := 'чужой'
        Endif
        s1 += PadR( s, 6 )
        s1 += full_date( mdate )
        dvn->last_l_u := full_date( mdate )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s1 )
        For i := 2 To Max( k_fio, k_adr )
          s1 := Space( 6 )
          If is_uchastok > 0 .or. mn->i_sort == 3
            s1 += Space( 11 )
          Endif
          s1 += PadR( tt_fio[ i ], 44 )
          s1 += Space( 14 )
          s1 += tt_adr[ i ]
          add_string( s1 )
        Next
        add_string( Replicate( '-', sh ) )
        Select TMP
        Skip
      Enddo
      If fl_exit
        add_string( '*** ' + Expand( 'ОПЕРАЦИЯ ПРЕРВАНА' ) )
      Else
        add_string( 'Итого количество пациентов: ' + lstr( tmp->( LastRec() ) ) + ' чел.' )
      Endif
      FClose( fp )
      Close databases
      RestScreen( buf )
      viewtext( name_file,,,, .t.,,, reg_print )
      n_message( { 'Создан файл для загрузки в Excel: ' + name_dbf },, cColorStMsg, cColorStMsg,,, cColorSt2Msg )
    Endif
  Endif
  Close databases
  RestScreen( buf ) ; SetColor( tmp_color )

  Return Nil

// 21.09.17
Function write_mn_p_dvn1( k )

  Local fl := .t.

  If k == 1
    If Empty( mnet_dann )
      If Empty( mgod )
        fl := func_error( 4, 'Обязательно должно быть заполнено поле "Год проведения диспансеризации"' )
      Elseif Empty( mv_period )
        fl := func_error( 4, 'Обязательно должен быть введён хотя бы один возрастной период диспансеризации' )
      Endif
    Endif
  Endif

  Return fl

// 17.07.19
Static Function f1_mnog_poisk_dvn1( cv, cf )

  Local i, k, n, s, fl := .t., fl_disp := .f.

  ++cv
  If !Empty( mn->net_dann )
    fl := f11_mnog_poisk_dvn1( mn->net_dann )
  Endif
  If fl .and. mn->god > 0
    n := mn->god - Year( kart->date_r )
    k := AScan( arr_vozr, n )
    fl := ( k > 0 )
  Endif
  If fl .and. mn->o_disp > 0 .and. mn->god > 0
    Select HUMAN
    find ( Str( kart->kod, 7 ) )
    Do While human->kod_k == kart->kod .and. !Eof()
      If Year( human->k_data ) == mn->god .and. Between( human->ishod, 201, 205 )
        fl_disp := .t. ; Exit
      Endif
      Skip
    Enddo
    If mn->o_disp == 1 // не проходили
      fl := !fl_disp
    Else // прошли
      fl := fl_disp
    Endif
  Endif
  If fl .and. !Empty( mn->o_prik )
    If mn->o_prik == 1 // к нашей МО
      fl := ( kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] )
    Elseif mn->o_prik == 2 // к другим МО
      fl := !( kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] )
    Else // прикрепление неизвестно
      fl := Empty( kart2->MO_PR )
    Endif
  Endif
  If fl .and. mn->o_death > 0
    If mn->o_death == 1 // За исключением умерших (по сведению ТФОМС)
      fl := !( Left( kart2->PC2, 1 ) == '1' )
    Elseif mn->o_death == 2 // Список умерших (по сведению ТФОМС)
      fl := ( Left( kart2->PC2, 1 ) == '1' )
    Endif
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->bukva )
    fl := ( mn->bukva == kart->bukva )
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->uchast )
    fl := f_is_uchast( arr_uchast, kart->uchast )
  Endif
  If fl .and. !Empty( mfio )
    fl := Like( mfio, Upper( kart->fio ) )
  Endif
  If fl .and. !Empty( madres )
    fl := Like( madres, Upper( kart->adres ) )
  Endif
  If fl .and. is_talon .and. mn->kategor > 0
    fl := ( mn->kategor == kart_->kategor )
  Endif
  If fl .and. is_kategor2 .and. mn->kategor2 > 0
    fl := ( mn->kategor2 == kart_->kategor2 )
  Endif
  If fl .and. !Empty( mn->pol )
    fl := ( kart->pol == mn->pol )
  Endif
  If fl .and. !Empty( mn->god_r_min )
    fl := ( mn->god_r_min <= kart->date_r )
  Endif
  If fl .and. !Empty( mn->god_r_max )
    fl := ( human->date_r <= mn->god_r_max )
  Endif
  If fl .and. mn->rab_nerab >= 0
    fl := ( kart->rab_nerab == mn->rab_nerab )
  Endif
  If fl .and. mn->mi_git > 0
    If mn->mi_git == 1
      fl := ( Left( kart_->okatog, 2 ) == '18' )
    Else
      fl := !( Left( kart_->okatog, 2 ) == '18' )
    Endif
  Endif
  If fl .and. !Empty( mn->_okato )
    s := mn->_okato
    For i := 1 To 3
      If Right( s, 3 ) == '000'
        s := Left( s, Len( s ) -3 )
      Else
        Exit
      Endif
    Next
    fl := ( Left( kart_->okatog, Len( s ) ) == s )
  Endif
  If fl .and. !Empty( mn->smo )
    fl := ( kart_->smo == mn->smo )
  Endif
  //
  If fl
    Select TMP
    Append Blank
    tmp->kod := kart->kod
    If++cf % 5000 == 0
      tmp->( dbCommit() )
    Endif
  Endif
  @ MaxRow(), 1 Say lstr( cv ) Color cColorSt2Msg
  @ Row(), Col() Say '/' Color 'W/R'
  @ Row(), Col() Say lstr( cf ) Color cColorStMsg

  Return Nil

// 17.07.19
Static Function f11_mnog_poisk_dvn1( date_otbor_old )

  Local fl_f11 := .t.

  // ОМС
  Select HUMAN
  find ( Str( kart->kod, 7 ) )
  Do While human->kod_k == kart->kod .and. !Eof()
    If human->k_data >= date_otbor_old
      // был после ХХ убираем из списка
      fl_f11 := .f. ; Exit
    Endif
    Skip
  Enddo
  // дополнительно проверяем регистратуру
  If fl_f11
    Select RU
    find ( Str( kart->kod, 7 ) + dtoc4( date_otbor_old ) )
    Do While ru->kod_k == kart->kod .and. !Eof()
      // индекс обратный
      If ru->pdate >= dtoc4( date_otbor_old )
        // был после ХХ убираем из списка
        fl_f11 := .f. ; Exit
      Endif
      Skip -1
    Enddo
  Endif
  // платные
  If fl_f11
    Select HUM_P
    find ( Str( kart->kod, 7 ) + DToS( date_otbor_old ) )
    Do While hum_p->kod_k == kart->kod .and. !Eof()
      // индекс обратный
      If hum_p->k_data >= date_otbor_old
        fl_f11 := .f. ; Exit
      Endif
      Skip -1
    Enddo
  Endif
  // ортопедия
  If fl_f11
    Select HUM_ORT
    find ( Str( kart->kod, 7 ) + DToS( date_otbor_old ) )
    Do While hum_ort->kod_k == kart->kod .and. !Eof()
      // индекс обратный
      If hum_opt->data >= date_otbor_old
        fl_f11 := .f. ; Exit
      Endif
      Skip -1
    Enddo
  Endif
  // ЛПУ-касса
  If fl_f11
    Select KS_PL
    find ( Str( kart->kod, 7 ) + DToS( date_otbor_old ) )
    Do While ks_pl->kod_k == kart->kod .and. !Eof()
      // сортировка по увеличению даты
      // индекс обратный
      If ks_pl->k_data >= date_otbor_old
        fl_f11 := .f. ; Exit
      Endif
      Skip -1
    Enddo
  Endif
  If fl_f11
    Select KS_ORT
    find ( Str( kart->kod, 7 ) + DToS( date_otbor_old ) )
    Do While ks_ort->kod_k == kart->kod .and. !Eof()
      // индекс обратный
      If ks_ort->k_data >= date_otbor_old
        fl_f11 := .f. ; Exit
      Endif
      Skip -1
    Enddo
  Endif
  // ПРИемный покой
  If fl_f11
    Select PP
    find ( Str( kart->kod, 7 ) + DToS( date_otbor_old ) )
    Do While pp->kod_k == kart->kod .and. !Eof()
      If pp->k_data >= date_otbor_old
        fl_f11 := .f. ; Exit
      Endif
      Skip -1
    Enddo
  Endif
  // госпитализация
  If fl_f11
    Select NAPR
    find ( Str( kart->kod, 7 ) + DToS( date_otbor_old ) )
    Do While napr->kod_k == kart->kod .and. !Eof()
      If napr->date_d >= date_otbor_old
        fl_f11 := .f. ; Exit
      Endif
      Skip
    Enddo
  Endif

  Return fl_f11

// 22.12.14 Многовариантный запрос по диспансеризации/профилактике взрослого населения
Function mnog_poisk_dvn2()

  Static mm_perevyst := { ;
    { 'без учёта случаев с отказом (перевыставленных)', 0 }, ;
    { 'случаи с отказом, которые БЫЛИ перевыставлены', 2 }, ;
    { 'случаи с отказом, которые НЕ были перевыставлены', 3 }, ;
    { 'все случаи', 1 };
    }
  Static mm_vid_obsl := { ;
    { 'ДИСПАНСЕРИЗАЦИЯ проведена', 0 }, ;
    { 'ДИСПАНСЕРИЗАЦИЯ НЕ проведена', 1 }, ;
    { 'ПРОФИЛАКТИКА проведена', 2 };
    }
  Static mm_prikrepl := { ;
    { 'к нашей МО  ', 1 }, ;
    { 'к другому МО', 2 }, ;
    { 'неизвестно  ', 3 };
    }
  Static mm_gruppa := { { 'Присвоена I группа здоровья', 1 }, ;
    { 'Присвоена II группа здоровья', 2 }, ;
    { 'Присвоена III группа здоровья', 3 } }
  Static mm_regschet := { { 'Не зарегистрированные счета', 1 }, { 'Зарегистрированные счета', 2 } }
  Static mm_schet := { { 'Не попавшие в счета', 1 }, { 'Попавшие в счета', 2 } }
  Static mm_reestr := { { 'Не попавшие в реестры', 1 }, { 'Попавшие в реестры', 2 } }
  Static mm_da_net := { { 'нет', 1 }, { 'да ', 2 } }
  Local mm_tmp := {}, k
  Local buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    tmp_help := help_code, name_file := cur_dir() + 'mn_z2dvn.txt', ;
    sh := 80, HH := 77, i, a_diagnoz[ 10 ], lvid_doc := 0, ;
    tmp_file := 'tmp_mn_p' + sdbf(), ;
    tt_diagnoz[ 10 ], tt_usl[ 10 ]
  Private ssumma := 0, suet := 0, mm_company := {}, ;
    is_kategor2 := .f., is_talon := ret_is_talon()

  If is_talon
    is_kategor2 := !Empty( stm_kategor2 )
  Endif
  //
  Close databases
  //
  Private pdate_lech, pdate_vvod, mstr_crb := 0, mstr_crbM := {}, ;
    mm_rslt := { ;
    { '316 Направлен на II этап диспансеризации', 316 }, ;
    { '352 Направлен на II этап, предварительно присвоена I группа здоровья', 352 }, ;
    { '353 Направлен на II этап, предварительно присвоена II группа здоровья', 353 }, ;
    { '354 Направлен на II этап, предварительно присвоена III группа здоровья', 354 };
    }
  //
  AAdd( mm_tmp, { 'date_lech', 'N', 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    if( k == nil, nil, ( pdate_lech := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    'Дата окончания лечения (отч.период)', ;
    {|| iif( Empty( mdate_lech ), func_error( 4, 'Не заполнена дата окончания лечения' ), .t. ) } } )
  AAdd( mm_tmp, { 'date_vvod', 'N', 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    if( k == nil, nil, ( pdate_vvod := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    '  дата ввода информации' } )
  AAdd( mm_tmp, { 'reestr', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_reestr, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    'В реестре?' } )
  AAdd( mm_tmp, { 'schet', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_schet, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    'В счёте?' } )
  AAdd( mm_tmp, { 'regschet', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_regschet, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    'Счёт зарегистрирован в ТФОМС?',, ;
    {|| m1schet == 2 } } )
  AAdd( mm_tmp, { 'perevyst', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_perevyst, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_perevyst, x ) }, ;
    'Какие случаи учитывать?' } )
  AAdd( mm_tmp, { 'vid_obsl', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_vid_obsl, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_vid_obsl, x ) }, ;
    'Вид обследования', ;
    {| g, o| f_valid_mnog_poisk_dvn2( g, o ) } } )
  AAdd( mm_tmp, { 'v_period', 'C', 100, 0, NIL, ;
    {| x| menu_reader( x, { {| k, r, c| f2_mnog_poisk_dvn2( k, r, c ) } }, A__FUNCTION ) }, ;
    Space( 100 ), {| x| Space( 10 ) }, ;
    ' Возрастные периоды диспансеризации',, ;
    {|| m1vid_obsl < 2 } } )
  AAdd( mm_tmp, { 'disp1', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
    ' Проведён I этап диспансеризации?', ;
    {|| iif( m1disp1 == 2, nil, ( mrslt := Space( 60 ), m1rslt := 0, update_get( 'mrslt' ) ) ), .t. }, ;
    {|| m1vid_obsl < 2 } } )
  AAdd( mm_tmp, { 'rslt', 'N', 3, 0, NIL, ;
    {| x| menu_reader( x, mm_rslt, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    ' └─> на II этап?(результат)',, ;
    {|| m1disp1 == 2 } } )
  AAdd( mm_tmp, { 'disp2', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
    ' Проведён II этап диспансеризации?',, ;
    {|| m1vid_obsl < 2 } } )
  AAdd( mm_tmp, { 'prikrepl', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_prikrepl, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    'Прикрепление', ;
    {|| iif( m1prikrepl == 2, nil, ( mmo_prik := Space( 70 ), m1mo_prik := Space( 6 ), update_get( 'mmo_prik' ) ) ), .t. } } )
  AAdd( mm_tmp, { 'mo_prik', 'C', 6, 0, NIL, ;
    {| x| menu_reader( x, { {| k, r, c| f_get_mo( k, r, c, 'loc_arr_MO[10].and.loc_arr_MO[2]!=glob_mo()[2]' ) } }, A__FUNCTION ) }, ;
    Space( 6 ), {| x| Space( 10 ) }, ;
    '└─> к какому МО',, ;
    {|| m1prikrepl == 2 } } )
  AAdd( mm_tmp, { 'gruppa', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_gruppa, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_gruppa, x ) }, ;
    'Группа здоровья?' } )
  AAdd( mm_tmp, { 'uch_doc', 'C', 10, 0, '@!', ;
    nil, ;
    Space( 10 ), nil, ;
    '№ амб.карты/истории болезни (шаблон)' } )
  Private arr_uchast := {}
  If is_uchastok > 0
    AAdd( mm_tmp, { 'bukva', 'C', 1, 0, '@!', ;
      nil, ;
      ' ', nil, ;
      'Буква (перед участком)' } )
    AAdd( mm_tmp, { 'uchast', 'N', 1, 0,, ;
      {| x| menu_reader( x, ;
      { {| k, r, c| get_uchast( r + 1, c ) } }, A__FUNCTION ) }, ;
      0, {|| init_uchast( arr_uchast ) }, ;
      'Участок (участки)' } )
  Endif
  AAdd( mm_tmp, { 'fio', 'C', 20, 0, '@!', ;
    nil, ;
    Space( 20 ), nil, ;
    'ФИО (начальные буквы или шаблон)' } )
  AAdd( mm_tmp, { '_okato', 'C', 11, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| get_okato_ulica( k, r, c, { k, m_okato, } ) } }, A__FUNCTION ) }, ;
    Space( 11 ), {| x| Space( 11 ) }, ;
    'Адрес регистрации (ОКАТО)' } )
  AAdd( mm_tmp, { 'adres', 'C', 20, 0, '@!', ;
    nil, ;
    Space( 20 ), nil, ;
    'Улица (подстрока или шаблон)' } )
  AAdd( mm_tmp, { 'mr_dol', 'C', 20, 0, '@!', ;
    nil, ;
    Space( 20 ), nil, ;
    'Место работы (подстрока или шаблон)' } )
  If is_talon
    AAdd( mm_tmp, { 'kategor', 'N', 2, 0, NIL, ;
      {| x| menu_reader( x, mo_cut_menu( stm_kategor ), A__MENUVERT ) }, ;
      0, {|| Space( 10 ) }, ;
      'Код категории льготы' } )
    If is_kategor2
      AAdd( mm_tmp, { 'kategor2', 'N', 4, 0, NIL, ;
        {| x| menu_reader( x, stm_kategor2, A__MENUVERT ) }, ;
        0, {|| Space( 10 ) }, ;
        'Категория МО' } )
    Endif
  Endif
  AAdd( mm_tmp, { 'pol', 'C', 1, 0, '!', ;
    nil, ;
    ' ', nil, ;
    'Пол', {|| mpol $ ' МЖ' } } )
  AAdd( mm_tmp, { 'god_r_min', 'D', 8, 0,, ;
    nil, ;
    CToD( '' ), nil, ;
    'Дата рождения (минимальная)' } )
  AAdd( mm_tmp, { 'god_r_max', 'D', 8, 0,, ;
    nil, ;
    CToD( '' ), nil, ;
    'Дата рождения (максимальная)' } )
  AAdd( mm_tmp, { 'rab_nerab', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, menu_rab(), A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    'Работающий/неработающий' } )
  AAdd( mm_tmp, { 'vrach1', 'N', 5, 0, NIL, ;
    nil, ;
    0, nil, ;
    'Лечащий врач', ;
    {| g| st_v_vrach( g, 'mvrach' ) } } )
  AAdd( mm_tmp, { 'vrach', 'C', 50, 0, NIL, ;
    nil, ;
    Space( 50 ), nil, ;
    '            ',, ;
    {|| .f. } } )
  AAdd( mm_tmp, { 'ist_fin', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mm_ist_fin, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    'Источник финансирования' } )
  AAdd( mm_tmp, { 'komu', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mm_komu(), A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    'Принадлежность счёта', ;
    {| g, o| f_valid_komu( g, o ) } } )
  AAdd( mm_tmp, { 'company', 'N', 5, 0, NIL, ;
    {| x| menu_reader( x, mm_company, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    '  ==>',, {|| eq_any( m1komu, 0, 1, 3 ) } } )
  AAdd( mm_tmp, { 'is_dbf', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
    1, {|| Space( 10 ) }, ;
    'Создавать DBF-файл (параллельно с текстовым)?' } )
  Delete File ( tmp_file )
  init_base( tmp_file,, mm_tmp, 0 )
  //
  r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'PERSO' )
  k := f_edit_spr( A__APPEND, mm_tmp, 'множественному запросу', ;
    'g_use(cur_dir()+"tmp_mn_p",,,.t.,.t.)', 0, 1,,,,, 'write_mn_p_DVN2' )
  If k > 0
    mywait()
    Use ( tmp_file ) New Alias MN
    If mn->ist_fin >= 0
      Private _arr_if := { mn->ist_fin }, _what_if := _init_if(), _arr_komit := {}
    Endif
    If is_talon .and. mn->kategor == 0
      is_talon := ( is_kategor2 .and. mn->kategor2 > 0 )
    Endif
    // заменить таб.номер на код
    If mn->vrach1 > 0
      r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'PERSO' )
      find ( Str( mn->vrach1, 5 ) )
      If Found()
        mn->vrach1 := perso->kod
      Endif
      perso->( dbCloseArea() )
    Endif
    Private much_doc := '', mfio := '', madres := '', mmr_dol := '', arr_vozr := list2arr( mn->v_period )
    If !Empty( mn->uch_doc )
      much_doc := AllTrim( mn->uch_doc )
      If !( Right( much_doc, 1 ) == '*' )
        much_doc += '*'
      Endif
    Endif
    If !Empty( mn->fio )
      mfio := AllTrim( mn->fio )
      If !( Right( mfio, 1 ) == '*' )
        mfio += '*'
      Endif
    Endif
    If !Empty( mn->adres )
      madres := AllTrim( mn->adres )
      If !( Left( madres, 1 ) == '*' )
        madres := '*' + madres
      Endif
      If !( Right( madres, 1 ) == '*' )
        madres += '*'
      Endif
    Endif
    If !Empty( mn->mr_dol )
      mmr_dol := AllTrim( mn->mr_dol )
      If !( Left( mmr_dol, 1 ) == '*' )
        mmr_dol := '*' + mmr_dol
      Endif
      If !( Right( mmr_dol, 1 ) == '*' )
        mmr_dol += '*'
      Endif
    Endif
    dbCreate( cur_dir() + 'tmp', { { 'kod',      'N', 7, 0 }, ;
      { 'kod_k',    'N', 7, 0 }, ;
      { 'etap',     'N', 1, 0 }, ;
      { 'vozr',     'N', 2, 0 }, ;
      { 'stoim',    'N', 10, 2 } } )
    Use ( cur_dir() + 'tmp' ) new
    dbCreate( cur_dir() + 'tmp_k', { ;
      { 'kod_k', 'N', 7, 0 }, ;
      { 'kol',  'N', 6, 0 } } ;
    )
    Use ( cur_dir() + 'tmp_k' ) new
    Index On Str( FIELD->kod_k, 7 ) to ( cur_dir() + 'tmp_k' )
    fl_exit := .f.
    status_key( '^<Esc>^ - прервать поиск' )
    r_use( dir_server() + 'uslugi',, 'USL' )
    r_use( dir_server() + 'human_u_',, 'HU_' )
    r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
    Set Relation To RecNo() into HU_, To FIELD->u_kod into USL additive
    r_use( dir_server() + 'schet_',, 'SCHET_' )
    r_use( dir_server() + 'schet',, 'SCHET' )
    Set Relation To RecNo() into SCHET_
    //
    r_use( dir_server() + 'kartote2',, 'KART2' )
    r_use( dir_server() + 'kartote_',, 'KART_' )
    r_use( dir_server() + 'kartotek',, 'KART' )
    Set Relation To RecNo() into KART_, To RecNo() into KART2
    //
    Private c_view := 0, c_found := 0
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )  // по дате окончания лечения
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( pdate_lech[ 5 ] ), .t. )
    Do While human->k_data <= pdate_lech[ 6 ] .and. !Eof()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      date_24( human->k_data )
      f1_mnog_poisk_dvn2( @c_view, @c_found )
      Select HUMAN
      Skip
    Enddo
    j := tmp->( LastRec() )
    Close databases
    If j == 0
      If !fl_exit
        func_error( 4, 'Нет сведений!' )
      Endif
    Else
      mywait()
      Use ( tmp_file ) New Alias MN
      arr_title := { ;
        '────────────────────────────────────────┬─────────', ;
        '             Ф.И.О. больного            │  Сумма  ', ;
        '                                        │ лечения ', ;
        '────────────────────────────────────────┴─────────' }
      arr_title[ 1 ] += '┬────────'
      arr_title[ 2 ] += '│  Дата  '
      arr_title[ 3 ] += '│рождения'
      arr_title[ 4 ] += '┴────────'
      arr_title[ 1 ] += '┬────────────────────────'
      arr_title[ 2 ] += '│         Адрес          '
      arr_title[ 3 ] += '│                        '
      arr_title[ 4 ] += '┴────────────────────────'
      arr_title[ 1 ] += '┬────────'
      arr_title[ 2 ] += '│ Сроки  '
      arr_title[ 3 ] += '│лечения '
      arr_title[ 4 ] += '┴────────'
      arr_title[ 1 ] += '┬─────'
      arr_title[ 2 ] += '│ Леч.'
      arr_title[ 3 ] += '│ врач'
      arr_title[ 4 ] += '┴─────'
      If yes_parol
        arr_title[ 1 ] += '┬──────────'
        arr_title[ 2 ] += '│Дата ввода'
        arr_title[ 3 ] += '│и оператор'
        arr_title[ 4 ] += '┴──────────'
      Endif
      reg_print := f_reg_print( arr_title, @sh, 2 )
      If sh < 65 ; sh := 65 ; Endif
      r_use( dir_server() + 'human_u_',, 'HU_' )
      r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
      Set Relation To RecNo() into HU_
      r_use( dir_server() + 'schet_',, 'SCHET_' )
      r_use( dir_server() + 'schet',, 'SCHET' )
      Set Relation To RecNo() into SCHET_
      If yes_parol
        r_use( dir_server() + 'base1',, 'BASE1' )
      Endif
      r_use( dir_server() + 'mo_pers',, 'PERSO' )
      r_use( dir_server() + 'kartote2',, 'KART2' )
      r_use( dir_server() + 'kartote_',, 'KART_' )
      r_use( dir_server() + 'kartotek',, 'KART' )
      Set Relation To RecNo() into KART_, To RecNo() into KART2
      r_use( dir_server() + 'human_',, 'HUMAN_' )
      r_use( dir_server() + 'human', dir_server() + 'humank', 'HUMAN' )
      Set Relation To RecNo() into HUMAN_
      fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( '' )
      add_string( Center( Expand( 'РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА' ), sh ) )
      add_string( '' )
      add_string( ' == ПАРАМЕТРЫ ПОИСКА ==' )
      add_string( 'Дата окончания лечения: ' + pdate_lech[ 4 ] )
      If mn->perevyst != 1
        add_string( Upper( inieditspr( A__MENUVERT, mm_perevyst, mn->perevyst ) ) )
      Endif
      If mn->reestr > 0
        add_string( inieditspr( A__MENUVERT, mm_reestr, mn->reestr ) )
      Endif
      If mn->schet > 0
        add_string( inieditspr( A__MENUVERT, mm_schet, mn->schet ) )
        If mn->schet == 2 .and. mn->regschet > 0
          add_string( inieditspr( A__MENUVERT, mm_regschet, mn->regschet ) )
        Endif
      Endif
      add_string( inieditspr( A__MENUVERT, mm_vid_obsl, mn->vid_obsl ) )
      If mn->vid_obsl < 2
        If mn->disp1 > 0
          add_string( ' Проведён I этап диспансеризации: ' + inieditspr( A__MENUVERT, mm_da_net, mn->disp1 ) )
        Endif
        If mn->disp1 == 2 .and. mn->rslt > 0
          add_string( ' └─> результат обращения: ' + inieditspr( A__MENUVERT, mm_rslt, mn->rslt ) )
        Endif
        If mn->disp2 > 0
          add_string( ' Проведён II этап диспансеризации: ' + inieditspr( A__MENUVERT, mm_da_net, mn->disp2 ) )
        Endif
      Endif
      If mn->prikrepl > 0
        add_string( 'Прикрепление: ' + inieditspr( A__MENUVERT, mm_prikrepl, mn->prikrepl ) )
        If mn->prikrepl == 2 .and. !Empty( mn->mo_prik )
          add_string( '└─> к какому МО прикреплён: ' + ret_mo( mn->mo_prik )[ _MO_SHORT_NAME ] )
        Endif
      Endif
      If mn->gruppa > 0
        add_string( inieditspr( A__MENUVERT, mm_gruppa, mn->gruppa ) )
      Endif
      If !Empty( much_doc )
        add_string( '№ амб.карты/истории болезни: ' + much_doc )
      Endif
      If is_uchastok > 0
        If !Empty( mn->bukva )
          add_string( 'Буква: ' + mn->bukva )
        Endif
        If !Empty( mn->uchast )
          add_string( 'Участок: ' + init_uchast( arr_uchast ) )
        Endif
      Endif
      If !Empty( mfio )
        add_string( 'ФИО: ' + mfio )
      Endif
      If !Empty( mn->_okato )
        add_string( 'Адрес регистрации (ОКАТО): ' + ret_okato_ulica( '', mn->_okato ) )
      Endif
      If !Empty( madres )
        add_string( 'Улица: ' + madres )
      Endif
      If !Empty( mmr_dol )
        add_string( 'Место работы: ' + mmr_dol )
      Endif
      If is_talon .and. mn->kategor > 0
        add_string( 'Код категории льготы: ' + ;
          inieditspr( A__MENUVERT, stm_kategor, mn->kategor ) )
      Endif
      If is_talon .and. is_kategor2 .and. mn->kategor2 > 0
        add_string( 'Категория МО: ' + ;
          inieditspr( A__MENUVERT, stm_kategor2, mn->kategor2 ) )
      Endif
      If !Empty( mn->pol )
        add_string( 'Пол: ' + mn->pol )
      Endif
      If !Empty( mn->god_r_min ) .or. !Empty( mn->god_r_max )
        If Empty( mn->god_r_min )
          add_string( 'Лица, родившиеся до ' + full_date( mn->god_r_max ) )
        Elseif Empty( mn->god_r_max )
          add_string( 'Лица, родившиеся после ' + full_date( mn->god_r_min ) )
        Else
          add_string( 'Лица, родившиеся с ' + ;
            full_date( mn->god_r_min ) + ' по ' + full_date( mn->god_r_max ) )
        Endif
      Endif
      If mn->rab_nerab >= 0
        add_string( Upper( inieditspr( A__MENUVERT, menu_rab(), mn->rab_nerab ) ) )
      Endif
      If mn->vrach1 > 0
        add_string( 'Лечащий врач: ' + AllTrim( mn->vrach ) )
      Endif
      If mn->ist_fin >= 0
        add_string( 'Источник финансирования ' + ;
          inieditspr( A__MENUVERT, mm_ist_fin, mn->ist_fin ) )
      Endif
      If mn->komu >= 0
        add_string( 'Принадлежность счёта: ' + ;
          inieditspr( A__MENUVERT, mm_komu(), mn->komu ) )

        If mn->company > 0
          add_string( '  ==> ' + ;
            inieditspr( A__MENUVERT, mm_company, mn->company ) )
        Endif
      Endif
      If mn->date_vvod > 0
        add_string( 'Дата ввода: ' + pdate_vvod[ 4 ] )
      Endif
      add_string( '' )
      add_string( ' == РЕЗУЛЬТАТЫ ПОИСКА ==' )
      Use ( cur_dir() + 'tmp_k' ) new
      Use ( cur_dir() + 'tmp' ) new
      Set Relation To Str( FIELD->kod, 7 ) into HUMAN
      Index On Upper( human->fio ) + DToS( human->k_data ) to ( cur_dir() + 'tmp' )
      add_string( 'Итого количество больных: ' + lstr( tmp_k->( LastRec() ) ) + ' чел.' )
      s := 'Итого листов учета: ' + lstr( tmp->( LastRec() ) ) + ' на сумму ' + lput_kop( ssumma, .t. ) + ' руб.'
      add_string( s )
      add_string( '' )
      AEval( arr_title, {| x| add_string( x ) } )
      ssumma := skol_lu := 0
      Keyboard ''
      status_key( '^<Esc>^ - прервать составление текстового файла' )
      Select TMP
      Go Top
      Do While !Eof()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        s1 := Left( human->fio, 40 )
        kart->( dbGoto( human->kod_k ) )
        If mem_kodkrt == 2
          s2 := ' ['
          If is_uchastok > 0
            s2 += AllTrim( kart->bukva )
            s2 += lstr( kart->uchast, 2 ) + '/'
          Endif
          If is_uchastok == 1
            s2 += lstr( kart->kod_vu )
          Elseif is_uchastok == 3
            s2 += AllTrim( kart2->kod_AK )
          Else
            s2 += lstr( kart->kod )
          Endif
          s2 += '] '
        Else
          s2 := Space( 7 )
        Endif
        If mn->komu < 0
          s2 += f4_view_list_schet( human->komu, cut_code_smo( human_->smo ), human->str_crb )
        Endif
        s2 := PadR( s2, 50 )
        s3 := iif( mem_kodkrt == 2, Space( 1 ), Space( 7 ) )
        If !Empty( mmr_dol )
          s3 += LTrim( kart->mr_dol )
        Endif
        s3 := PadR( s3, 50 )
        //
        s1 += Str( tmp->stoim, 10, 2 )
        ssumma += tmp->stoim
        ++skol_lu
        //
        s1 += ' ' + date_8( human->date_r )
        s2 += iif( Empty( tmp->vozr ), Space( 9 ), ' возр.:' + Str( tmp->vozr, 2 ) )
        s3 += iif( Empty( tmp->etap ), Space( 9 ), '  ' + PadR( { 'I', 'II' }[ tmp->etap ] + ' этап', 7 ) )
        //
        perenos( a_diagnoz, ret_okato_ulica( kart->adres, kart_->okatog, 0, 2 ), 24 )
        s1 += ' ' + PadR( AllTrim( a_diagnoz[ 1 ] ), 24 )
        s2 += ' ' + PadR( AllTrim( a_diagnoz[ 2 ] ), 24 )
        s3 += ' ' + PadR( AllTrim( a_diagnoz[ 3 ] ), 24 )
        //
        s1 += ' ' + date_8( human->n_data )
        s2 += ' ' + date_8( human->k_data )
        s3 += Space( 9 )
        //
        If human_->vrach > 0
          Select PERSO
          Goto ( human_->vrach )
          s1 += put_val( perso->tab_nom, 6 )
        Else
          s1 += Space( 6 )
        Endif
        s2 += Space( 6 )
        s3 += Space( 6 )
        //
        If yes_parol
          s1 += ' ' + date_8( c4tod( human->date_e ) ) + 'г.'
          If Asc( human->kod_p ) > 0
            Select BASE1
            Goto ( Asc( human->kod_p ) )
            If !Eof() .and. !Empty( base1->p1 )
              s2 += ' ' + Left( Crypt( base1->p1, gpasskod ), 10 )
            Endif
          Endif
        Endif
        add_string( s1 )
        add_string( s2 )
        add_string( s3 )
        Select TMP
        Skip
      Enddo
      add_string( Replicate( '─', sh ) )
      If fl_exit
        add_string( '*** ' + Expand( 'ОПЕРАЦИЯ ПРЕРВАНА' ) )
      Else
        add_string( '  Итого листов учета: ' + lstr( tmp->( LastRec() ) ) + ;
          ' на сумму  ' + lput_kop( ssumma, .t. ) + ' руб.' )
      Endif
      FClose( fp )
      Close databases
      viewtext( name_file,,,, .t.,,, reg_print )
    Endif
  Endif
  Close databases
  RestScreen( buf ) ; SetColor( tmp_color )

  Return Nil

// 18.12.14 valid на переменную 'vid_obsl'
Function f_valid_mnog_poisk_dvn2( get, old )

  If m1vid_obsl != old .and. old != Nil // при смене значения
    If m1vid_obsl == 2                  // на профилактику
      m1v_period := mv_period := Space( 100 )
      m1disp1 := m1disp2 := m1rslt := 0
      mdisp1 := mdisp2 := Space( 3 )
      mrslt := Space( 60 )
      update_get( 'mv_period' )
      update_get( 'mdisp1' )
      update_get( 'mrslt' )
      update_get( 'mdisp2' )
    Endif
  Endif

  Return .t.

// 17.07.19 запрос в GET-е возрастных периодов диспансеризации
Function f2_mnog_poisk_dvn2( k, r, c, par )

  Static sast, sarr, sast2, sarr2
  Local buf := save_maxrow(), a, i, j, s, s1, fl, _arr_vozrast_DVN

  Default par To 2
  If sast == NIL
    sast := {} ; sarr := {}
    _arr_vozrast_DVN := ret_arr_vozrast_dvn( 0d20190701 )
    For j := 1 To Len( _arr_vozrast_DVN )
      AAdd( sast, .t. )
      s := lstr( _arr_vozrast_DVN[ j ] )
      i := Int( Val( Right( s, 1 ) ) )
      If i == 1
        s += ' год'
      Elseif Between( i, 2, 4 )
        s += ' года'
      Else
        s += ' лет'
      Endif
      AAdd( sarr, { s, _arr_vozrast_DVN[ j ], 'МЖ' } )
    Next
    sast2 := {} ; sarr2 := {}
    For j := 18 To 40
      If AScan( _arr_vozrast_DVN, j ) == 0 // профосмотр
        AAdd( sast2, .t. )
        s := lstr( j )
        i := Int( Val( Right( s, 1 ) ) )
        If i == 1
          s += ' год'
        Elseif Between( i, 2, 4 )
          s += ' года'
        Else
          s += ' лет'
        Endif
        AAdd( sarr2, { s, j, 'МЖ' } )
      Endif
    Next
  Endif
  s := s1 := ''
  If par == 1
    sast := {}
    fl := .t. // инициализация до 1-го вызова f_edit_spr()
    If Type( 'm1tip_disp' ) == 'N'
      fl := ( m1tip_disp == 1 )
    Endif
    For i := 1 To Len( sarr )
      AAdd( sast, .t. )
      If fl
        s += lstr( sarr[ i, 2 ] ) + iif( i < Len( sarr ), ',', '' )
      Endif
    Next
    sast2 := {}
    fl := .f. // инициализация после смены значения m1tip_disp внутри f_edit_spr()
    If Type( 'm1tip_disp' ) == 'N'
      fl := ( m1tip_disp == 2 )
    Endif
    For i := 1 To Len( sarr2 )
      AAdd( sast2, .t. )
      If fl
        s += lstr( sarr2[ i, 2 ] ) + iif( sarr2[ i, 3 ] == 'Ж', 'Ж', '' ) + iif( i < Len( sarr2 ), ',', '' )
      Endif
    Next
    s1 := 'все'
  Else
    If m1tip_disp == 1 .and. ( a := bit_popup( r, c, sarr, sast ) ) != Nil // диспансеризация
      AFill( sast, .f. )
      For i := 1 To Len( a )
        If ( j := AScan( sarr, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
          sast[ j ] := .t.
          s += lstr( a[ i, 2 ] ) + iif( i < Len( a ), ',', '' )
        Endif
      Next
      If Len( a ) == Len( sast )
        s1 := 'все'
      Endif
    Elseif m1tip_disp == 2 .and. ( a := bit_popup( r, c, sarr2, sast2 ) ) != Nil // профосмотры
      AFill( sast2, .f. )
      For i := 1 To Len( a )
        If ( j := AScan( sarr2, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
          sast2[ j ] := .t.
          s += lstr( a[ i, 2 ] ) + iif( 'Ж' $ a[ i, 1 ], 'Ж', '' ) + iif( i < Len( a ), ',', '' )
        Endif
      Next
      If Len( a ) == Len( sast2 )
        s1 := 'все'
      Endif
    Endif
  Endif
  If Empty( s )
    s := Space( 10 )
  Endif
  If Empty( s1 )
    s1 := s
  Endif

  Return { s, s1 }

// 16.12.14
Function write_mn_p_dvn2( k )

  Local fl := .t.

  If k == 1
    If Empty( mdate_lech )
      fl := func_error( 4, 'Обязательно должно быть заполнено первое поле даты!' )
    Endif
  Endif

  Return fl

// 22.12.14
Function f1_mnog_poisk_dvn2( cv, cf )

  Static P_BEGIN_RSLT := 342, D_BEGIN_RSLT := 316, D_BEGIN_RSLT2 := 351
  Local i, s, fl := .t., flu := .f., mstoim := 0

  ++cv
  kart->( dbGoto( human->kod_k ) )
  Private metap := 0, m1gruppa := 0, mdvozrast := 0, ;
    arr_usl_dop := {}, arr_usl_otkaz := {}, m1veteran := 0, ;
    m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, ;
    m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
    m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, m1prof_ko := 0, ;
    pole_diag, pole_1stadia, pole_1pervich, mWEIGHT := 0, mHEIGHT := 0
  For i := 1 To 5
    pole_diag := 'mdiag' + lstr( i )
    pole_1stadia := 'm1stadia' + lstr( i )
    pole_1pervich := 'm1pervich' + lstr( i )
    Private &pole_diag := Space( 6 )
    Private &pole_1stadia := 0
    Private &pole_1pervich := 0
  Next
  If mn->vid_obsl == 0      // ДИСПАНСЕРИЗАЦИЯ проведена
    If ( fl := eq_any( human->ishod, 201, 202 ) )
      metap := human->ishod -200
      If human_->RSLT_NEW > D_BEGIN_RSLT2
        m1GRUPPA := human_->RSLT_NEW - D_BEGIN_RSLT2
      Else
        m1GRUPPA := human_->RSLT_NEW - D_BEGIN_RSLT
      Endif
    Endif
  Elseif mn->vid_obsl == 1  // ДИСПАНСЕРИЗАЦИЯ НЕ проведена
    fl := !eq_any( human->ishod, 201, 202, 203, 204, 205 )
  Elseif mn->vid_obsl == 2  // ПРОФИЛАКТИКА проведена
    If ( fl := ( human->ishod == 203 ) )
      m1GRUPPA := human_->RSLT_NEW - P_BEGIN_RSLT
    Endif
  Endif
  If !Between( m1gruppa, 1, 3 )
    m1GRUPPA := 0
  Endif
  If fl .and. mn->perevyst != 1
    If mn->perevyst == 0
      fl := ( human_->oplata != 9 )
    Elseif mn->perevyst == 2
      fl := ( human_->oplata == 9 )
    Elseif mn->perevyst == 3
      fl := ( human_->oplata == 2 )
    Endif
  Endif
  If fl .and. mn->date_vvod > 0
    fl := Between( human->date_e, pdate_vvod[ 7 ], pdate_vvod[ 8 ] )
  Endif
  If fl
    If mn->reestr == 1
      fl := ( human_->reestr == 0 )
    Elseif mn->reestr == 2
      fl := ( human_->reestr > 0 )
    Endif
  Endif
  If fl
    If mn->schet == 1
      fl := ( human->schet <= 0 )
    Elseif mn->schet == 2
      If ( fl := ( human->schet > 0 ) ) .and. mn->regschet > 0
        If schet->kod != human->schet
          schet->( dbGoto( human->schet ) )
        Endif
        If mn->regschet == 1
          fl := ( schet_->NREGISTR != 0 ) // не зарегистрированные
        Elseif mn->regschet == 2
          fl := ( schet_->NREGISTR == 0 ) // зарегистрированные
        Endif
      Endif
    Endif
  Endif
  If fl .and. eq_any( mn->vid_obsl, 0, 2 )
    read_arr_dvn( human->kod )
    ret_tip_mas( mWEIGHT, mHEIGHT, @m1tip_mas )
  Endif
  If fl .and. mn->vid_obsl == 0
    mdvozrast := Year( human->n_data ) - Year( human->date_r )
    If m1veteran == 1
      mdvozrast := ret_vozr_dvn_veteran( mdvozrast, human->k_data )
    Endif
    If !Empty( arr_vozr )
      fl := ( AScan( arr_vozr, mdvozrast ) > 0 )
    Endif
    If fl .and. mn->disp1 > 0
      If mn->disp1 == 2 // да
        fl := ( metap == 1 )
      Else
        fl := ( metap != 1 )
      Endif
      If fl .and. mn->rslt > 0
        fl := ( human_->RSLT_NEW == mn->rslt )
      Endif
    Endif
    If fl .and. mn->disp2 > 0
      If mn->disp2 == 2 // да
        fl := ( metap == 2 )
      Else
        fl := ( metap != 2 )
      Endif
    Endif
  Endif
  If fl .and. mn->prikrepl > 0
    If mn->prikrepl == 1 // к нашей МО
      fl := ( kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] )
    Elseif mn->prikrepl == 2 // к другому МО
      fl := !( kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] )
      If fl .and. !Empty( mn->mo_prik )
        fl := ( kart2->MO_PR == mn->mo_prik )
      Endif
    Elseif mn->prikrepl == 3 // неизвестно
      fl := Empty( kart2->MO_PR )
    Endif
  Endif
  If fl .and. !Empty( much_doc )
    fl := Like( much_doc, human->uch_doc )
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->bukva )
    kart->( dbGoto( human->kod_k ) )
    fl := ( mn->bukva == kart->bukva )
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->uchast )
    kart->( dbGoto( human->kod_k ) )
    fl := f_is_uchast( arr_uchast, kart->uchast )
  Endif
  If fl .and. !Empty( mfio )
    fl := Like( mfio, Upper( human->fio ) )
  Endif
  If fl .and. !Empty( madres )
    fl := Like( madres, Upper( kart->adres ) )
  Endif
  If fl .and. !Empty( mmr_dol )
    fl := Like( mmr_dol, Upper( kart->mr_dol ) )
  Endif
  If fl .and. is_talon .and. mn->kategor > 0
    fl := ( mn->kategor == kart_->kategor )
  Endif
  If fl .and. is_kategor2 .and. mn->kategor2 > 0
    fl := ( mn->kategor2 == kart_->kategor2 )
  Endif
  If fl .and. !Empty( mn->pol )
    fl := ( human->pol == mn->pol )
  Endif
  If fl .and. !Empty( mn->god_r_min )
    fl := ( mn->god_r_min <= human->date_r )
  Endif
  If fl .and. !Empty( mn->god_r_max )
    fl := ( human->date_r <= mn->god_r_max )
  Endif
  If fl .and. mn->rab_nerab >= 0
    fl := ( kart->rab_nerab == mn->rab_nerab )
  Endif
  If fl .and. !Empty( mn->_okato )
    s := mn->_okato
    For i := 1 To 3
      If Right( s, 3 ) == '000'
        s := Left( s, Len( s ) -3 )
      Else
        Exit
      Endif
    Next
    fl := ( Left( kart_->okatog, Len( s ) ) == s )
  Endif
  If fl .and. mn->vrach1 > 0
    fl := ( human_->vrach == mn->vrach1 )
  Endif
  If fl .and. mn->ist_fin >= 0
    fl := _f_ist_fin()
  Endif
  If fl .and. mn->komu >= 0
    If mn->company == 0
      fl := ( mn->komu == human->komu )
    Elseif mn->komu == 0
      If human->schet > 0
        If schet->kod != human->schet
          schet->( dbGoto( human->schet ) )
        Endif
        fl := ( Int( Val( schet_->smo ) ) == mn->company )
      Else
        fl := ( Int( Val( cut_code_smo( human_->smo ) ) ) == mn->company )
      Endif
    Else
      fl := ( mn->komu == human->komu .and. mn->company == human->str_crb )
    Endif
  Endif
  If fl
    Select TMP_K
    find ( Str( human->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmp_k->kod_k := human->kod_k
    Endif
    tmp_k->kol++
    Select TMP
    Append Blank
    tmp->kod := human->kod
    tmp->kod_k := human->kod_k
    tmp->etap := metap
    tmp->vozr := mdvozrast
    tmp->stoim := human->cena_1
    ssumma += tmp->stoim
    If++cf % 5000 == 0
      tmp->( dbCommit() )
      tmp_k->( dbCommit() )
    Endif
  Endif
  @ MaxRow(), 1 Say lstr( cv ) Color cColorSt2Msg
  @ Row(), Col() Say '/' Color 'W/R'
  @ Row(), Col() Say lstr( cf ) Color cColorStMsg

  Return Nil

// 16.11.16
Function f39_hir( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { ;
      'Форма 39 по ~организации', ;
      'Форма 39 по ~врачу', ;
      '~Настройка формы 39', ;
      '~Печать настройки' }
    mas_msg := { ;
      'Распечатка формы 39 в целом по организации', ;
      'Распечатка формы 39 по врачу', ;
      'Настройка для составления формы 39', ;
      'Распечатка настройки формы 39-ХИРУРГИЯ' }
    mas_fun := { ;
      'f39_hir(1)', ;
      'f39_hir(2)', ;
      'f39_hir(3)', ;
      'f39_hir(4)' }
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 1
    forma_39hall( 3 )
  Case k == 2
    forma_39hall( 1 )
  Case k == 3
    forma_39h_na( 1 )
  Case k == 4
    forma_39h_na( 2 )
  Endcase
  If Between( k, 1, 9 )
    si1 := k
  Endif

  Return Nil

//
Function get_nastr_stom_f39h()

  Local nf := dir_server() + f39h_nastr, fl, i, j

  If ( fl := File( nf ) )
    For j := 1 To 35
      t := 'au' + lstr( j )
      &t := getinisect( nf, f39h_sect + lstr( j ) )
    Next
    fl := .f.
    For j := 1 To 35
      t := 'au' + lstr( j )
      For i := 1 To Len( &t )
        fl := .t.
        &t[ i, 2 ] := Int( Val( &t[ i, 2 ] ) )
      Next
    Next
    //
    For j := 1 To 35
      tt := 'aud' + lstr( j )
      &tt := getinisect( nf, f39hdp_sect + lstr( j ) )
    Next
    fl := .f.
    For j := 1 To 35
      tt := 'aud' + lstr( j )
      For i := 1 To Len( &tt )
        fl := .t.
        &tt[ i, 2 ] := Int( Val( &tt[ i, 2 ] ) )
      Next
    Next
    //
    For j := 1 To 35
      ttt := 'auz' + lstr( j )
      &ttt := getinisect( nf, f39hdz_sect + lstr( j ) )
    Next
    fl := .f.
    For j := 1 To 35
      ttt := 'auz' + lstr( j )
      For i := 1 To Len( &ttt )
        fl := .t.
        &ttt[ i, 2 ] := Int( Val( &ttt[ i, 2 ] ) )
      Next
    Next
    //
  Endif
  //
  If !fl
    func_error( 4, 'Не произведена настройка формы 39-ХИРУРГИЯ' )
  Endif

  Return fl

//
Function forma_39hall( tip_f39 )

  Static sds := 0
  Local i, j, k, arr, begin_date, end_date, s, buf := save_row( 24 ), ;
    fl_exit := .f., tm, t, tt, t1, t2, s_lu := 0, s_human := 0, ;
    kh := 0, jh := 0, arr_m, arr_pl, arr_dms, ttt
  Local  mas_pmt := { ;
    'По дате ~окончания лечения', ;
    'По ~дате оказания услуги' }

  // Public menu_vid_opl := {{'ОМС',1},;  //  (битовое)
  // {'Бюджет',2},;
  // {'Пл.услуги',3},;
  // {'ДМС',4},;
  // {'Другое',5}}
  Private Pi1 := 0, Pi1_DATE, Pi1_OMS := 1

  For j := 1 To 35
    t := 'au' + lstr( j )
    tt := 'aud' + lstr( j )
    ttt := 'auz' + lstr( j )
    Private &t
    Private &tt
    Private &ttt
  Next
  Private mas_diag := {}
  //
  If !get_nastr_stom_f39h()
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If ( krvz := fbp_tip_f39( T_ROW, T_COL -5, @arr_dms ) ) == NIL
    Return Nil
  Endif
  If ( j := popup_prompt( T_ROW, T_COL -5, sds, mas_pmt,,, 'B/BG,W+/B,N/BG,BG+/B' ) ) > 0
    sds := j
  Endif
  Pi1 := j
  If tip_f39 == 1 .and. !input_perso( T_ROW, T_COL -5, .f. )
    Return Nil
  Endif
  Private speriod := arr_m[ 4 ]
  begin_date := arr_m[ 7 ]
  end_date := DToS( arr_m[ 6 ] )
  //
  waitstatus( '<Esc> - прервать поиск' ) ; mark_keys( { '<Esc>' } )
  //
  delfrfiles()
  dbCreate( cur_dir() + 'tmp_hum', { ;
    { 'kod_h', 'N', 6, 0 }, ;
    { 'date_u', 'C', 4, 0 } } )
  cre_tmp_39h( { ;
    { 'p_kod', 'C', 4, 0 }, ;
    { 'data', 'D', 8, 0 }, ;
    { 'tip', 'N', 1, 0 }, ;   // 1-весь персонал, 2-перс.в отделении, 3-отделение
    { 'otd', 'N', 2, 0 }, ;
    { 'tab_nom', 'N', 5, 0 }, ;
    { 'name', 'C', 25, 0 }, ;
    { 'summa', 'N', 10, 2 }, ;
    { 'sr_it', 'N', 1, 0 }, ;
    { 'sanirov', 'N', 10, 0 }, ;
    { 'yet', 'N', 10, 2 };
  } )
  Use ( fr_data ) New Alias TMP
  Index On Str( FIELD->tip, 1 ) + FIELD->p_kod to ( cur_dir() + 'tmp' )
  r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'DIAG' )
  //
  If AScan( krvz, 1 ) > 0  // ОМС
    Pi1_OMS := 1
    If Pi1 == 1 // по дате окончания лечения
      r_use( dir_server() + 'kartote_',, 'KARTOTE_' )
      If AScan( krvz, 3 ) > 0 // платные присутствуют
        // Pi1_OMS := 0
        r_use( dir_server() + 'hum_p_u', dir_server() + 'hum_p_u', 'PHU' )
        r_use( dir_server() + 'hum_p', dir_server() + 'hum_pkk', 'PHUMAN' )
      Endif
      r_use( dir_server() + 'human_',, 'HUMAN_' )
      r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
      r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
      dbSeek( arr_m[ 5 ], .t. )
      // цикл по ОМС
      Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
        // проходим по диагнозам
        mas_diag := {}
        If Len( AllTrim( human->kod_diag ) ) > 3
          AAdd( mas_diag, human->kod_diag )
        Endif
        If Len( AllTrim( human->kod_diag2 ) ) > 3
          AAdd( mas_diag, human->kod_diag2 )
        Endif
        If Len( AllTrim( human->kod_diag3 ) ) > 3
          AAdd( mas_diag, human->kod_diag3 )
        Endif
        If Len( AllTrim( human->kod_diag4 ) ) > 3
          AAdd( mas_diag, human->kod_diag4 )
        Endif
        preobr_mkb()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select TMP
        find ( '1' + dtoc4( human->k_data ) )  // поиск по дате
        If !Found()
          Append Blank
          tmp->p_kod := dtoc4( human->k_data )
          tmp->data  := human->k_data
          tmp->tip   := 1
        Endif
        // tmp->summa += human->cena
        If ( arr := yes_f_39h( 0, 0, tip_f39 ) ) != NIL
          ++jh
          For i := 1 To Len( arr )
            write_f39h( arr[ i ] )
          Next
        Endif
        @ 24, 1 Say lstr( ++kh ) Color cColorSt2Msg
        If jh > 0
          @ Row(), Col() Say '/' Color 'W/R'
          @ Row(), Col() Say lstr( jh ) Color cColorStMsg
        Endif
        Select HUMAN
        Skip
      Enddo
      KARTOTE_->( dbCloseArea() )
      HU->( dbCloseArea() )
      HUMAN->( dbCloseArea() )
      HUMAN_->( dbCloseArea() )
      If AScan( krvz, 3 ) > 0 // платные присутствуют
        PHU->( dbCloseArea() )
        PHUMAN->( dbCloseArea() )
      Endif
    Else  // дата оказания услуг
      r_use( dir_server() + 'kartote_',, 'KARTOTE_' )
      If AScan( krvz, 3 ) > 0 // платные присутствуют
        // Pi1_OMS := 0
        r_use( dir_server() + 'hum_p_u', dir_server() + 'hum_p_u', 'PHU' )
        r_use( dir_server() + 'hum_p', dir_server() + 'hum_pkk', 'PHUMAN' )
      Endif
      r_use( dir_server() + 'human_',, 'HUMAN_' )
      r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
      r_use( dir_server() + 'human_u', dir_server() + 'human_ud', 'HU' )
      Use ( cur_dir() + 'tmp_hum' ) New Alias TMP_HUM
      Select HU
      dbSeek( arr_m[ 7 ], .t. )
      Do While hu->date_u <= arr_m[ 8 ] .and. !Eof()
        Select TMP_HUM
        Append Blank
        tmp_hum->kod_h  := hu->kod
        tmp_hum->date_u := hu->date_u
        Select HU
        Skip
      Enddo
      Select TMP_HUM
      Index On Str( FIELD->kod_h, 6 ) + date_u to ( cur_dir() + 'tmp_om' ) Unique progress
      HU->( dbCloseArea() )
      r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
      Select TMP_HUM
      // создаём временный индекс - выбираем все нужные нам случ
      // цикл по ОМС
      Go Top
      Do While !Eof()
        // проходим по диагнозам
        Select HUMAN
        Goto ( TMP_HUM->kod_h )
        Pi1_DATE := tmp_hum->date_u
        mas_diag := {}
        If Len( AllTrim( human->kod_diag ) ) > 3
          AAdd( mas_diag, human->kod_diag )
        Endif
        If Len( AllTrim( human->kod_diag2 ) ) > 3
          AAdd( mas_diag, human->kod_diag2 )
        Endif
        If Len( AllTrim( human->kod_diag3 ) ) > 3
          AAdd( mas_diag, human->kod_diag3 )
        Endif
        If Len( AllTrim( human->kod_diag4 ) ) > 3
          AAdd( mas_diag, human->kod_diag4 )
        Endif
        preobr_mkb()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select TMP
        find ( '1' + tmp_hum->date_u )  // поиск по дате
        If !Found()
          Append Blank
          tmp->p_kod := tmp_hum->date_u
          tmp->data  := c4tod( tmp_hum->date_u )
          tmp->tip   := 1
        Endif
        // tmp->summa += human->cena
        If ( arr := yes_f_39h( 0, 0, tip_f39 ) ) != NIL
          ++jh
          For i := 1 To Len( arr )
            write_f39h( arr[ i ] )
          Next
        Endif
        @ 24, 1 Say lstr( ++kh ) Color cColorSt2Msg
        If jh > 0
          @ Row(), Col() Say '/' Color 'W/R'
          @ Row(), Col() Say lstr( jh ) Color cColorStMsg
        Endif
        Select TMP_HUM
        Skip
      Enddo
      KARTOTE_->( dbCloseArea() )
      HU->( dbCloseArea() )
      HUMAN->( dbCloseArea() )
      HUMAN_->( dbCloseArea() )
      TMP_HUM->( dbCloseArea() )
      If AScan( krvz, 3 ) > 0 // платные присутствуют
        PHU->( dbCloseArea() )
        PHUMAN->( dbCloseArea() )
      Endif
    Endif
  Endif
  // для СОНИРОВАНО
  If AScan( krvz, 1 ) > 0  // ОМС
    r_use( dir_server() + 'kartote_',, 'KARTOTE_' )
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
    dbSeek( arr_m[ 5 ], .t. )
    // цикл по ОМС
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
      // проходим о диагнозам
      Select HUMAN_
      Goto ( human->( RecNo() ) )
      If iif( tip_f39 == 1, glob_human[ 1 ] == human_->vrach, .t. )
        If human_->ISHOD_NEW == 301
          Select TMP
          find( '1' + dtoc4( human->k_data ) )
          If Found()
            g_rlock( forever )
            tmp->p32 += 1
            Unlock
          Endif
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    KARTOTE_->( dbCloseArea() )
    HUMAN->( dbCloseArea() )
    HUMAN_->( dbCloseArea() )
  Endif

  // цикл только по платным
  If AScan( krvz, 3 ) > 0 // .and. ascan(krvz,1) == 0
    Pi1_OMS := 0
    r_use( dir_server() + 'kartote_',, 'KARTOTE_' )
    r_use( dir_server() + 'hum_p_u', dir_server() + 'hum_p_u', 'HU' )
    r_use( dir_server() + 'hum_p', dir_server() + 'hum_pd', 'HUMAN' )
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    // цикл по ОМС
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
      mas_diag := {}
      If Len( AllTrim( human->kod_diag ) ) > 3
        AAdd( mas_diag, human->kod_diag )
      Endif
      If Len( AllTrim( human->soput_b1 ) ) > 3
        AAdd( mas_diag, human->soput_b1 )
      Endif
      If Len( AllTrim( human->soput_b2 ) ) > 3
        AAdd( mas_diag, human->soput_b2 )
      Endif
      If Len( AllTrim( human->soput_b3 ) ) > 3
        AAdd( mas_diag, human->soput_b3 )
      Endif
      If Len( AllTrim( human->soput_b4 ) ) > 3
        AAdd( mas_diag, human->soput_b4 )
      Endif
      If Len( AllTrim( human->soput_b5 ) ) > 3
        AAdd( mas_diag, human->soput_b5 )
      Endif
      preobr_mkb()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      Select TMP
      find ( '1' + dtoc4( human->k_data ) )  //
      If !Found()
        Append Blank
        tmp->p_kod := dtoc4( human->k_data )
        tmp->data  := human->k_data
        tmp->tip   := 1
      Endif
      // tmp->summa += human->cena
      If ( arr := yes_f_39h( 0, 0, tip_f39 ) ) != NIL
        ++jh
        For i := 1 To Len( arr )
          write_f39h( arr[ i ] )
        Next
      Endif
      @ 24, 1 Say lstr( ++kh ) Color cColorSt2Msg
      If jh > 0
        @ Row(), Col() Say '/' Color 'W/R'
        @ Row(), Col() Say lstr( jh ) Color cColorStMsg
      Endif
      Select HUMAN
      Skip
    Enddo
  Endif
  //
  Close databases

  rest_box( buf )
  mybell()
  //
  Use ( fr_data ) new
  Index On FIELD->p_kod to ( fr_data )
  //
  dbCreate( fr_titl, { { 'god', 'N', 4, 0 }, ;
    { 'tit1name', 'C', 130, 0 }, ;
    { 'tit2name', 'C', 130, 0 }, ;
    { 'tit3name', 'C', 130, 0 }, ;
    { 'tit4name', 'C', 130, 0 } } )
  r_use( dir_server() + 'organiz',, 'ORG' )
  add_string( AllTrim( org->name ) )
  Use ( fr_titl ) new
  Append Blank
  Replace tit1name With AllTrim( org->name )
  Replace tit2name With AllTrim( arr_m[ 4 ] )
  If tip_f39 == 1 // по врачу
    Replace tit3name With AllTrim( glob_human[ 2 ] )
  Endif
  t := ''
  If AScan( krvz, 1 ) > 0
    t := 'ОМС'
  Endif
  If AScan( krvz, 3 ) > 0
    t += ' + Платные услуги'
  Endif
  Replace tit4name With t
  Close databases
  call_fr( 'mo_sth39.fr3' )

  Return Nil

Function preobr_mkb()

  // mas_diag
  Local i

  For i := 1 To Len( mas_diag )
    Select DIAG
    find ( mas_diag[ i ] + ' ' )
    If Found()
      mas_diag[ i ] := diag->( RecNo() )
    Endif
  Next

  Return Nil

// проверить больного по БД human и вернуть результат в виде массива
Static Function yes_f_39h( par1, vozrast, vrach )

  Local i, j, k, s, arr, ret, t_human := .t.

  Private t_mas := Array( 45 ), lp := Array( 40 )
  Private mdate_r, m1vzros_reb := 0, t_vrach := vrach

  arr := {}
  // проходим по услугам
  Select HU
  t_human := .t.
  find ( Str( human->( RecNo() ), 6 ) )
  Do While hu->kod == human->( RecNo() ) .and. !Eof()
    If iif( vrach == 1, glob_human[ 1 ] == hu->kod_vr, .t. )
      If iif( Pi1 == 1, .t., hu->date_u == Pi1_DATE )
        k := hu->kol
        AFill( lp, 0 )
        ___f_39h( k )
        lp[ 3 ] := lp[ 1 ]
        lp[ 1 ] := 0
        lp[ 6 ] := lp[ 2 ]
        lp[ 2 ] := 0
        lp[ 7 ] := lp[ 3 ] + lp[ 6 ]
        If vozrast == 1
          mdate_r := human->date_r
          fv_date_r(, .f. )
        Else

        Endif
        If m1vzros_reb == 0 // взрослые
          lp[ 1 ] := lp[ 3 ]
          lp[ 4 ] := lp[ 6 ]
        Else
          lp[ 2 ] := lp[ 3 ]
          lp[ 5 ] := lp[ 6 ]
        Endif

        // УЕТ
        lp[ 36 ] := opr_uet( m1vzros_reb ) * k
        //
        If lp[ 37 ]
          // РЕЗУЛЬТАТ
     /*   if lp[36] > 0
          if Pi1_OMS == 1 .and. t_human
            select HUMAN_
            goto (human->(recno()))
            t_human := .F.
            if human_->RSLT_NEW == 301
              lp[32] := 1
            endif
          endif
        endif
        */
          AAdd( arr, AClone( lp ) )
        Endif
      Endif
    Endif
    Select HU
    Skip
  Enddo
  If Len( arr ) > 0
    // проверяем второй список
    ret := arr
  Endif

  Return ret

//
Function ___f_39h( k )

  Local _1, _2, t_rec, t_flag, t_kart, t_date

  lp[ 37 ] := .f.
  For j := 1 To 35
    t := 'au' + lstr( j )
    t1 := &t
    _1 := ( AScan( &t, {| x| x[ 2 ] == hu->u_kod } ) > 0 )
    If _1
      lp[ 37 ] := .t.
      If j > 2
        lp[ j + 6 ]  := k
      Else
        lp[ j ]  := k
      Endif
    Endif
    // проверяем второй список
    // делаем цикл по всему случаю

    tt := 'aud' + lstr( j )
    t2 := &tt
    If Len( &tt ) > 0
      // если ответ отрицательный - нулируем предыдущий результат
      t_flag := .t.
      t_rec := hu->( RecNo() )
      find ( Str( human->( RecNo() ), 6 ) )
      Do While hu->kod == human->( RecNo() ) .and. !Eof()
        If iif( t_vrach == 1, glob_human[ 1 ] == hu->kod_vr, .t. )
          _2 := ( AScan( &tt, {| x| x[ 2 ] == hu->u_kod } ) > 0 )
          If _2
            t_flag := .f.
          Endif
        Endif
        Skip
      Enddo
      // проверка по ПЛАТНЫМ внутри ОМС
      If AScan( krvz, 3 ) > 0 .and. AScan( krvz, 1 ) > 0 .and. Pi1_OMS == 1
        // @ 10,20 say  human->kod_k
        // inkey(0)
        Select HUMAN
        t_kart := human->kod_k
        // по дате окончания лечения
        If Pi1 == 1 // по дате окончания лечения
          t_date := human->k_data
        Else // по дате услуги
          t_date := c4tod( Pi1_DATE )
        Endif
        Select PHUMAN
        find ( Str( t_kart, 6 ) + DToS( t_date ) )
        // перебираем случаи
        Do While phuman->kod_k == t_kart .and. ;
            phuman->k_data == t_date .and. !Eof()
          Select PHU
          // перебираем услуги
          // t_rec := hu->(recno())
          find ( Str( phuman->( RecNo() ), 6 ) )
          Do While phu->kod == phuman->( RecNo() ) .and. !Eof()
            If iif( t_vrach == 1, glob_human[ 1 ] == phu->kod_vr, .t. )
              _2 := ( AScan( &tt, {| x| x[ 2 ] == phu->u_kod } ) > 0 )
              If _2
                t_flag := .f.
              Endif
            Endif
            Skip
          Enddo
          Select PHUMAN
          Skip
        Enddo
      Endif
      // конец проверки ОМС
      If t_flag
        If j > 2
          lp[ j + 6 ]  := 0
        Else
          lp[ j ]  := 0
        Endif
      Endif
      hu->( dbGoto( t_rec ) )
    Endif
    // проверяем третий список - ДИАГНОЗЫ
    ttt := 'auz' + lstr( j )
    t3 := &ttt
    If Len( &ttt ) > 0
      // если ответ отрицательный - нулируем предыдущий результат
      // у нас есть масси диагнозов
      For ll := 1 To Len( mas_diag )
        _3 := ( AScan( &ttt, {| x| x[ 2 ] == mas_diag[ ll ] } ) > 0 )
        If _3
          Exit
        Else
          If j > 2
            lp[ j + 6 ]  := 0
          Else
            lp[ j ]  := 0
          Endif
        Endif
      Next
    Endif
  Next

  Return Nil

// записать одну строку из массива в TMP-файл
Function write_f39h( ar )

  Local i, pole

  For i := 1 To 35
    pole := 'tmp->p' + lstr( i )
    &pole := &pole + ar[ i ]
  Next
  tmp->yet := tmp->yet + ar[ 36 ]

  Return Nil

//
Function forma_39h_na( tip )

  Static arr := { ;
    'Посещение первичное', ;                  // 1
    'Посещение повторное', ;                  // 2
    'Блокада', ;                              // 3
    'Экстракция зубов с обезболиванием', ;    // 4
    'Экстракция зубов без обезболивания', ;   // 5
    'Экстракция корней зубов', ;              // 6
    'Экстракция молочных зубов ', ;           // 7
    'Экстракция постоянных зубов ', ;         // 8
    'Экстракция зубов периостит', ;           // 9
    'Экстракция зубов остеомиелит', ;         // 10
    'Экстракция зубов резекций верх.корня', ; // 11
    'Реплантарий', ;                          // 12
    'Кюретаж лунки', ;                        // 13
    'Альвелолотомия', ;                       // 14
    'Удаление секвестров', ;                  // 15
    'Удаление аномальных зубов', ;            // 16
    'Удаление ретенционных кист', ;           // 17
    'Удаление мигрирующих гранул', ;          // 18
    'Удаление кист радикулярных', ;           // 19
    'Удаление кист фолликулярных', ;          // 20
    'Удаление доброкачественных опухолей', ;  // 21
    'Вскрытие абсцесса', ;                    // 22
    'Френгуло-пластика', ;                    // 23
    'Операций с общим обезболиванием', ;      // 24
    'Шинирование переломов', ;                // 25
    'Санировано', ;                           // 26
    'Консультаций, советов', ;                // 27
    'Прочие заболевания' }                    // 28
  Static si1
  Local l, sh := 0, f39_scr := SaveScreen(), i, j
  Local HH := 58, name_file := cur_dir() + 'orto_ns.txt', ;
    arr_title := { ;
    '──────────┬──────────────────────────────────────────────────────────────────', ;
    '   Шифр   │                                                                  ', ;
    '  услуги  │                  Наименование услуги                             ', ;
    '──────────┴──────────────────────────────────────────────────────────────────' }

  If tip == 1
    AEval( arr, {| x| sh := Max( sh, Len( x ) ) } )
    Do While ( l := Popup( T_ROW, T_COL -5, 22, T_COL + sh -2, arr, l ) ) > 0
      Default si1 To 1
      mas_pmt := { 'Основная услуга', ;
        'Сопутствующая услуга', ;
        'Обязательный диагноз' }
      If ( j := popup_prompt( T_ROW, T_COL -5, si1, mas_pmt ) ) > 0
        si1 := j
        RestScreen( f39_scr )
        If j == 1
          f1_forma_39h_na( l, arr[ l ], 1 )
        Elseif j == 2
          f1_forma_39h_na( l, arr[ l ], 2 )
        Else
          f1_forma_39h_na_diag( l, arr[ l ] )
        Endif
      Endif
      RestScreen( f39_scr )
    Enddo
    RestScreen( f39_scr )
  Else
    sh := Len( arr_title[ 1 ] )
    waitstatus( '<Esc> - прервать формирование' ) ; mark_keys( { '<Esc>' } )
    reg_print := 2
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( '' )
    add_string( Center( 'Настройка Форма 39-СТОМАТОЛОГИЯ-ХИРУРГИЯ', sh ) )
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    add_string( '' )
    For i := 1 To Len( arr )
      add_string( '' )
      add_string( '==>> ' + arr[ i ] )
      f1_forma_39h_prn_na( i, arr[ i ], 1 )
      If !Eof()
        add_string( '' )
        add_string( '=> ОСНОВНАЯ УСЛУГА' )
      Endif
      Go Top
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( tmp->u_shifr + '  ' + tmp->u_name )
        Skip
      Enddo
      Close databases
      //
      f1_forma_39h_prn_na( i, arr[ i ], 2 )
      If !Eof()
        add_string( '=> ОБЯЗАТЕЛЬНАЯ ДОПОЛНИТЕЛЬНАЯ УСЛУГА' )
      Endif
      Go Top
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( tmp->u_shifr + '  ' + tmp->u_name )
        Skip
      Enddo
      Close databases
      //
      f1_forma_39h_prn_diag_na( i, arr[ i ], 2 )
      If !Eof()
        add_string( '=> ОБЯЗАТЕЛЬНЫЙ ДИАГНОЗ' )
      Endif
      Go Top
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( tmp->d_shifr + '  ' + tmp->d_name )
        Skip
      Enddo
      Close databases
      //
    Next
    FClose( fp )
    RestScreen( f39_scr )
    viewtext( name_file )
    RestScreen( f39_scr )
  Endif

  Return Nil

//
Function f1_forma_39h_na( par, title, tip )

  Local nfile := dir_server() + f39h_nastr, name_sect
  Local adbf, arr_usl, i

  //
  If tip == 1
    name_sect := f39h_sect + lstr( par )
  Else
    name_sect := f39hdp_sect + lstr( par )
  Endif
  arr_usl := getinisect( nFile, name_sect )
  adbf := { ;
    { 'U_KOD',    'N',      4,      0 }, ;  // код услуги
    { 'U_SHIFR',    'C',     10,      0 }, ;  // шифр услуги
    { 'U_NAME',     'C',     65,      0 };   // наименование услуги
  }
  dbCreate( cur_dir() + 'tmp', adbf )
  r_use( dir_server() + 'uslugi',, 'USL' )
  Use ( cur_dir() + 'tmp' ) new
  For i := 1 To Len( arr_usl )
    Select USL
    Goto ( Val( arr_usl[ i, 2 ] ) )
    If !Eof() .and. usl->kod > 0
      Select TMP
      Append Blank
      tmp->u_kod := usl->kod
      tmp->u_shifr := usl->shifr
      tmp->u_name := usl->name
    Endif
  Next
  Select TMP
  Index On Str( FIELD->u_kod, 4 ) to ( cur_dir() + 'tmpk' )
  Index On fsort_usl( FIELD->u_shifr ) to ( cur_dir() + 'tmpn' )
  Close databases
  If tip == 1
    ob2_v_usl(, 2, 'Настройка формы 39-хирургия: колонка ' + title )
  Else
    ob2_v_usl(, 2, 'Настройка формы 39-хирургия: колонка ДОПОЛНЕНИЕ ' + title )
  Endif
  If f_esc_enter( 1 )
    arr_usl := {}
    Use ( cur_dir() + 'tmp' ) index ( cur_dir() + 'tmpn' ) New Alias TMP
    Go Top
    Do While !Eof()
      AAdd( arr_usl, { tmp->u_shifr, lstr( tmp->u_kod ) } )
      Skip
    Enddo
    Close databases
    setinisect( nFile, name_sect, arr_usl )
  Endif

  Return Nil

//
Function f1_forma_39h_prn_na( par, title, tip )

  Local nfile := dir_server() + f39h_nastr, name_sect
  Local adbf, arr_usl, i

  //
  If tip == 1
    name_sect := f39h_sect + lstr( par )
  Else
    name_sect := f39hdp_sect + lstr( par )
  Endif
  arr_usl := getinisect( nFile, name_sect )
  adbf := { ;
    { 'U_KOD',    'N',      4,      0 }, ;  // код услуги
    { 'U_SHIFR',  'C',     10,      0 }, ;  // шифр услуги
    { 'U_NAME',   'C',     65,      0 };   // наименование услуги
  }
  dbCreate( cur_dir() + 'tmp', adbf )
  r_use( dir_server() + 'uslugi',, 'USL' )
  Use ( cur_dir() + 'tmp' ) new
  For i := 1 To Len( arr_usl )
    Select USL
    Goto ( Val( arr_usl[ i, 2 ] ) )
    If !Eof() .and. usl->kod > 0
      Select TMP
      Append Blank
      tmp->u_kod := usl->kod
      tmp->u_shifr := usl->shifr
      tmp->u_name := usl->name
    Endif
  Next
  Select TMP
  Index On fsort_usl( FIELD->u_shifr ) to ( cur_dir() + 'tmpn' )

  Return Nil

//
Function f1_forma_39h_prn_diag_na( par, title )

  Local nfile := dir_server() + f39h_nastr, name_sect
  Local adbf, arr_diag, i

  //
  name_sect := f39hdz_sect + lstr( par )
  arr_diag := getinisect( nFile, name_sect )
  adbf := { ;
    { 'd_KOD',    'N',      4,      0 }, ;  // код услуги
    { 'd_SHIFR',  'C',     10,      0 }, ;  // шифр услуги
    { 'd_NAME',   'C',     65,      0 };   // наименование услуги
  }
  dbCreate( cur_dir() + 'tmp', adbf )
  r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'DIAG' )
  Use ( cur_dir() + 'tmp' ) new
  For i := 1 To Len( arr_diag )
    Select DIAG
    Goto ( Val( arr_diag[ i, 2 ] ) )
    If !Eof() .and. diag->( RecNo() ) > 0
      Select TMP
      Append Blank
      tmp->d_kod   := diag->( RecNo() )
      tmp->d_shifr := diag->shifr
      tmp->d_name  := diag->name
    Endif
  Next
  Select TMP
  Index On FIELD->d_shifr to ( cur_dir() + 'tmpn' )

  Return Nil

//
Static Function cre_tmp_39h( adbf )

  Local i

  For i := 1 To 36
    AAdd( adbf, { 'p' + lstr( i ), 'N', 7, 0 } )
  Next
  dbCreate( fr_data, adbf )

  Return Nil

// вернуть тип услуги (bit-овый вариант)
Function fbp_tip_f39( r, c, ret_arr )

  Static sast := { .t., .f., .t., .f., .f. }
  Local i, j, a, out_arr

  Default r To T_ROW, c To T_COL + 5
  If ( a := bit_popup( r, c, menu_vid_opl, sast ) ) != NIL
    out_arr := {} ; AFill( sast, .f. )
    For i := 1 To Len( a )
      AAdd( out_arr, a[ i, 2 ] )
      If ( j := AScan( menu_vid_opl, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
        sast[ j ] := .t.
      Endif
    Next
  Endif

  Return out_arr

//
Function f1_forma_39h_na_diag( par, title, tip )

  Local nfile := dir_server() + f39h_nastr, name_sect
  Local adbf, arr_diag, i

  //
  name_sect := f39hdz_sect + lstr( par )
  arr_diag := getinisect( nFile, name_sect )
  adbf := { ;
    { 'D_KOD',    'N',      4,      0 }, ;  // код услуги
    { 'D_SHIFR',  'C',      6,      0 }, ;  // шифр услуги
    { 'D_NAME',   'C',     65,      0 };   // наименование услуги
  }
  dbCreate( cur_dir() + 'tmp', adbf )
  r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'DIAG' )
  Use ( cur_dir() + 'tmp' ) new
  For i := 1 To Len( arr_diag )
    Select DIAG
    Goto ( Val( arr_diag[ i, 2 ] ) )
    If !Eof() .and. diag->( RecNo() ) > 0
      Select TMP
      Append Blank
      tmp->d_kod   := diag->( RecNo() )
      tmp->d_shifr := diag->shifr
      tmp->d_name  := diag->name
    Endif
  Next
  Select TMP
  Index On Str( FIELD->d_kod, 4 ) to ( cur_dir() + 'tmpk' )
  Index On FIELD->d_shifr to ( cur_dir() + 'tmpn' )
  Close databases
  ob2_v_diag(, 2, 'Настройка формы 39-хирургия: колонка ДИАГНОЗ ' + title )
  If f_esc_enter( 1 )
    arr_diag := {}
    Use ( cur_dir() + 'tmp' ) index ( cur_dir() + 'tmpn' ) New Alias TMP
    Go Top
    Do While !Eof()
      AAdd( arr_diag, { tmp->d_shifr, lstr( tmp->d_kod ) } )
      Skip
    Enddo
    Close databases
    setinisect( nFile, name_sect, arr_diag )
  Endif

  Return Nil

//
Function ob2_v_diag( is_get, r1, mtitul )

  Local t_arr[ BR_LEN ], buf := SaveScreen(), k, ret

  Default is_get To .f., r1 To T_ROW
  If r1 > 14 ; r1 := 14 ; Endif
  r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'DIAG' )
  Use ( cur_dir() + 'tmp' ) index ( cur_dir() + 'tmpk' ), ( cur_dir() + 'tmpn' ) New Alias TMP
  Set Order To 2
  t_arr[ BR_TOP ] := r1
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 1
  t_arr[ BR_RIGHT ] := 78
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitul
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_OPEN ] := {|| !Eof() }
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═',, .t. }
  t_arr[ BR_COLUMN ] := { ;
    { '   Шифр', {|| tmp->d_shifr } }, ;
    { Center( 'Наименование диагноза', 65 ), {|| tmp->d_name } } }
  t_arr[ BR_STAT_MSG ] := {|| ;
    status_key( '^<Esc>^ выход;  ^<Ins>^ добавление;  ^<Del>^ удаление диагноза;' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| ob21v_diag( nk, ob, 'edit', mtitul ) }
  edit_browse( t_arr )
  If is_get
    Go Top
    k := 0
    dbEval( {|| if( tmp->d_kod > 0, ++k, nil ) } )
    ret := { k, 'Кол-во услуг - ' + lstr( k ) }
  Endif
  tmp->( dbCloseArea() )
  diag->( dbCloseArea() )
  RestScreen( buf )
  If !is_get
    waitstatus( '<Esc> - прервать поиск' ) ; mark_keys( { '<Esc>' } )
  Endif

  Return ret

//
Function ob21v_diag( nKey, oBrow, regim, mtitul )

  Local ret := -1, s
  Local buf, fl := .f., rec, rec1, k := 19, tmp_color, n_file, sh := 80, HH := 60

  Do Case
  Case regim == 'edit'
    Do Case
    Case nKey == K_INS
      Save Screen To buf
      Private mshifr := Space( 6 )
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, pc1 + 1, 21, pc2 -1,, 'Добавление диагноза', cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 27 Say 'Шифр диагн' Get mshifr Picture '@!'
      // valid valid_shifr()
      status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
      myread()
      If LastKey() != K_ESC .and. !Empty( mshifr )
        Select DIAG
        find ( mshifr )
        fl := Found()
        Select TMP
        If fl
          Set Order To 1
          fl_found := .t.
          addrec( 4 )
          rec := RecNo()
          Replace tmp->d_shifr With mshifr, tmp->d_name With diag->name, ;
            tmp->d_kod With diag->( RecNo() )
          Set Order To 2
          oBrow:gotop()
          Goto ( rec )
          ret := 0
        Else
          func_error( 4, 'Диагноза с данным шифром нет в справочнике!' )
        Endif
      Endif
      If !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. !Empty( tmp->d_kod )
      rec1 := 0
      rec := RecNo()
      Skip
      If !Eof()
        rec1 := RecNo()
      Endif
      Goto ( rec )
      deleterec()
      If rec1 == 0
        oBrow:gobottom()
      Else
        Goto ( rec1 )
      Endif
      ret := 0
      If Eof()
        ret := 1
      Endif
    Endcase
  Endcase

  Return ret

// 16.11.16
Function f39_ter( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { ;
      'Форма 39 по ~организации', ;
      'Форма 39 по ~врачу', ;
      '~Настройка формы 39', ;
      '~Печать настройки' }
    mas_msg := { ;
      'Распечатка формы 39 в целом по организации', ;
      'Распечатка формы 39 по врачу', ;
      'Настройка для составления формы 39', ;
      'Распечатка настройки формы 39-ТЕРАПИЯ' }
    mas_fun := { ;
      'f39_ter(1)', ;
      'f39_ter(2)', ;
      'f39_ter(3)', ;
      'f39_ter(4)' }
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 1
    forma_39tall( 3 )
  Case k == 2
    forma_39tall( 1 )
  Case k == 3
    forma_39t_na( 1 )
  Case k == 4
    forma_39t_na( 2 )
  Endcase
  If Between( k, 1, 9 )
    si1 := k
  Endif

  Return Nil

//
Function get_nastr_stom_f39t()

  Local nf := dir_server() + f39t_nastr, fl, i

  If ( fl := File( nf ) )
    For j := 1 To 56
      t := 'au' + lstr( j )
      &t := getinisect( nf, f39t_sect + lstr( j ) )
    Next
    fl := .f.
    For j := 1 To 56
      t := 'au' + lstr( j )
      For i := 1 To Len( &t )
        fl := .t.
        &t[ i, 2 ] := Int( Val( &t[ i, 2 ] ) )
      Next
    Next
    //
    For j := 1 To 56
      tt := 'aud' + lstr( j )
      &tt := getinisect( nf, f39tdp_sect + lstr( j ) )
    Next
    fl := .f.
    For j := 1 To 56
      tt := 'aud' + lstr( j )
      For i := 1 To Len( &tt )
        fl := .t.
        &tt[ i, 2 ] := Int( Val( &tt[ i, 2 ] ) )
      Next
    Next
    //
    For j := 1 To 56
      ttt := 'auz' + lstr( j )
      &ttt := getinisect( nf, f39tdz_sect + lstr( j ) )
    Next
    fl := .f.
    For j := 1 To 56
      ttt := 'auz' + lstr( j )
      For i := 1 To Len( &ttt )
        fl := .t.
        &ttt[ i, 2 ] := Int( Val( &ttt[ i, 2 ] ) )
      Next
    Next
    //
  Endif
  //
  If !fl
    func_error( 4, 'Не произведена настройка формы 39-ТЕРАПИЯ' )
  Endif

  Return fl

// записать одну строку из массива в TMP-файл
Function write_f39t( ar )

  Local i, pole

  For i := 1 To 56
    pole := 'tmp->p' + lstr( i )
    &pole := &pole + ar[ i ]
  Next
  // tmp->p4 := tmp->p5 +tmp->p6

  Return Nil

//
Function forma_39t_na( tip )

  Static arr := { ;
    '02 - Посещений Всего', ;
    '03 - Посещений дети до 15', ;
    '04 - Посещений сельских жителей', ;
    '05 - Посещений с лечебной целью Всего', ;
    '06 - Лечение парадонтоза', ;
    '07 - Лечение слизистой', ;
    '08 - Первичные Всего', ;
    '09 - Первичные Дети до 15', ;
    '10 - Первичные больным пародонтозм', ;
    '11 - Санированных всего', ;
    '12 - Санированных детей до 15', ;
    '13 - Лечение кариеса начато и закончено в одно посещение', ;
    '14 - Лечение кариеса начато и не закончено', ;
    '15 - Лечение кариеса продолжено и не закончено', ;
    '16 - Лечение кариеса продолжено и закончено', ;
    '17 - Лечение пульпита начато и закончено в одно посещение', ;
    '18 - Лечение пульпита начато и не закончено', ;
    '19 - Лечение пульпита продолжено и не закончено', ;
    '20 - Лечение пульпита продолжено и закончено', ;
    '21 - Лечение периодонтита начато и закончено в одно посещение', ;
    '22 - Лечение периодонтита начато и не закончено', ;
    '23 - Лечение периодонтита продолжено и не закончено', ;
    '24 - Лечение периодонтита продолжено и закончено', ;
    '25 - Число лиц, которым удал.отложения на зубах', ;
    '26 - Удалённых зубов всего', ;
    '27 - Удалённых зубов молочных', ;
    '28 - Удалённых зубов постоянных', ;
    '29 - Прочие амбулаторные операции', ;
    '30 - колонка', ;
    '31 - ПРОФ колонка', ;
    '32 - ПРОФ колонка', ;
    '33 - ПРОФ колонка', ;
    '34 - ПРОФ колонка', ;
    '35 - ПРОФ колонка', ;
    '36 - ПРОФ Диспансерных больных', ;
    '37 - ПРОФ Беременных', ;
    '38 - ПРОФ НУЖДАЛИСЬ В СОНАЦИИ - всего', ;
    '39 - ПРОФ НУЖДАЛИСЬ Дошкольников', ;
    '40 - ПРОФ НУЖДАЛИСЬ Учащихся до 15 лет', ;
    '41 - ПРОФ НУЖДАЛИСЬ Учащихся с 15 до 18 лет', ;
    '42 - ПРОФ НУЖДАЛИСЬ Допризывников', ;
    '43 - ПРОФ НУЖДАЛИСЬ Рабочих', ;
    '44 - ПРОФ НУЖДАЛИСЬ Диспансерных больных', ;
    '45 - ПРОФ НУЖДАЛИСЬ Беременных', ;
    '46 - ПРОФ САНИРОВАНО', ;
    '47 - ПРОФ САНИРОВАНО Дошкольников', ;
    '48 - ПРОФ САНИРОВАНО Учащихся до 15 лет', ;
    '49 - ПРОФ САНИРОВАНО Учащихся с 15 до 18 лет', ;
    '50 - ПРОФ САНИРОВАНО Допризывников', ;
    '51 - ПРОФ САНИРОВАНО Рабочих', ;
    '52 - ПРОФ САНИРОВАНО Диспансерных больных', ;
    '53 - ПРОФ САНИРОВАНО Беременных колонка', ;
    '54 - ПРОФ Запломбировано каналов', ;
    '55 - ПРОФ Закончен курс лечения парадонтоза', ;
    '56 - ПРОФ Всего наложено пломб';
    }
  Static si1
  Local l, sh := 0, f39_scr := SaveScreen(), i, j
  Local HH := 58, name_file := cur_dir() + 'orto_ns.txt', ;
    arr_title := { ;
    '──────────┬──────────────────────────────────────────────────────────────────', ;
    '   Шифр   │                                                                  ', ;
    '  услуги  │                  Наименование услуги                             ', ;
    '──────────┴──────────────────────────────────────────────────────────────────' }

  If tip == 1
    AEval( arr, {| x| sh := Max( sh, Len( x ) ) } )
    Do While ( l := Popup( T_ROW, T_COL -5, 22, T_COL + sh -2, arr, l ) ) > 0
      Default si1 To 1
      mas_pmt := { ;
        'Основная услуга', ;
        'Сопутствующая услуга', ;
        'Обязательный диагноз', ;
        'Исключительная услуга' }
      If ( j := popup_prompt( T_ROW, T_COL -5, si1, mas_pmt ) ) > 0
        si1 := j
        RestScreen( f39_scr )
        If j == 1
          f1_forma_39t_na( l, arr[ l ], 1 )
        Elseif j == 2
          f1_forma_39t_na( l, arr[ l ], 2 )
        Elseif j == 3
          f1_forma_39t_na_diag( l, arr[ l ] )
        Else
          f1_forma_39t_na( l, arr[ l ], 3 )
        Endif
      Endif
      RestScreen( f39_scr )
    Enddo
    RestScreen( f39_scr )
  Else
    sh := Len( arr_title[ 1 ] )
    waitstatus( '<Esc> - прервать формирование' ) ; mark_keys( { '<Esc>' } )
    reg_print := 2
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( '' )
    add_string( Center( 'Настройка Форма 39-СТОМАТОЛОГИЯ-ТЕРАПИЯ', sh ) )
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    add_string( '' )
    For i := 1 To Len( arr )
      add_string( '' )
      add_string( '==>> ' + arr[ i ] )
      f1_forma_39t_prn_na( i, arr[ i ], 1 )
      If !Eof()
        add_string( '' )
        add_string( '=> ОСНОВНАЯ УСЛУГА' )
      Endif
      Go Top
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( tmp->u_shifr + '  ' + tmp->u_name )
        Skip
      Enddo
      Close databases
      //
      f1_forma_39t_prn_na( i, arr[ i ], 2 )
      If !Eof()
        add_string( '=> ОБЯЗАТЕЛЬНАЯ ДОПОЛНИТЕЛЬНАЯ УСЛУГА' )
      Endif
      Go Top
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( tmp->u_shifr + '  ' + tmp->u_name )
        Skip
      Enddo
      Close databases
      //
      f1_forma_39t_prn_na( i, arr[ i ], 3 )
      If !Eof()
        add_string( '=> УСЛУГА ОТМЕНЫ' )
      Endif
      Go Top
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( tmp->u_shifr + '  ' + tmp->u_name )
        Skip
      Enddo
      Close databases
      //

      f1_forma_39t_prn_diag_na( i, arr[ i ], 2 )
      If !Eof()
        add_string( '=> ОБЯЗАТЕЛЬНЫЙ ДИАГНОЗ' )
      Endif
      Go Top
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( tmp->d_shifr + '  ' + tmp->d_name )
        Skip
      Enddo
      Close databases
      //
    Next
    FClose( fp )
    RestScreen( f39_scr )
    viewtext( name_file )
    RestScreen( f39_scr )
  Endif

  Return Nil

//
Function f1_forma_39t_na( par, title, tip )

  Local nfile := dir_server() + f39t_nastr, name_sect
  Local adbf, arr_usl, i

  //
  If tip == 1
    name_sect := f39t_sect + lstr( par )
  Elseif tip == 2
    name_sect := f39tdp_sect + lstr( par )
  Else
    name_sect := f39tdd_sect + lstr( par )
  Endif
  arr_usl := getinisect( nFile, name_sect )
  adbf := { ;
    { 'U_KOD',    'N',      4,      0 }, ;  // код услуги
    { 'U_SHIFR',  'C',     10,      0 }, ;  // шифр услуги
    { 'U_NAME',   'C',     65,      0 };   // наименование услуги
  }
  dbCreate( cur_dir() + 'tmp', adbf )
  r_use( dir_server() + 'uslugi',, 'USL' )
  Use ( cur_dir() + 'tmp' ) new
  For i := 1 To Len( arr_usl )
    Select USL
    Goto ( Val( arr_usl[ i, 2 ] ) )
    If !Eof() .and. usl->kod > 0
      Select TMP
      Append Blank
      tmp->u_kod := usl->kod
      tmp->u_shifr := usl->shifr
      tmp->u_name := usl->name
    Endif
  Next
  Select TMP
  Index On Str( FIELD->u_kod, 4 ) to ( cur_dir() + 'tmpk' )
  Index On fsort_usl( FIELD->u_shifr ) to ( cur_dir() + 'tmpn' )
  Close databases
  If tip == 1
    ob2_v_usl(, 2, 'Настройка формы 39-терапия: колонка ' + title )
  Elseif tip == 2
    ob2_v_usl(, 2, 'Настройка формы 39-терапия: колонка ДОПОЛНЕНИЕ ' + title )
  Else
    ob2_v_usl(, 2, 'Настройка формы 39-терапия: колонка ОТМЕНА ' + title )
  Endif
  If f_esc_enter( 1 )
    arr_usl := {}
    Use ( cur_dir() + 'tmp' ) index ( cur_dir() + 'tmpn' ) New Alias TMP
    Go Top
    Do While !Eof()
      AAdd( arr_usl, { tmp->u_shifr, lstr( tmp->u_kod ) } )
      Skip
    Enddo
    Close databases
    setinisect( nFile, name_sect, arr_usl )
  Endif

  Return Nil

//
Function f1_forma_39t_prn_na( par, title, tip )

  Local nfile := dir_server() + f39t_nastr, name_sect
  Local adbf, arr_usl, i

  //
  If tip == 1
    name_sect := f39t_sect + lstr( par )
  Elseif tip == 2
    name_sect := f39tdp_sect + lstr( par )
  Else
    name_sect := f39tdd_sect + lstr( par )
  Endif
  arr_usl := getinisect( nFile, name_sect )
  adbf := { ;
    { 'U_KOD',    'N',      4,      0 }, ;  // код услуги
    { 'U_SHIFR',  'C',     10,      0 }, ;  // шифр услуги
    { 'U_NAME',   'C',     65,      0 };   // наименование услуги
  }
  dbCreate( cur_dir() + 'tmp', adbf )
  r_use( dir_server() + 'uslugi',, 'USL' )
  Use ( cur_dir() + 'tmp' ) new
  For i := 1 To Len( arr_usl )
    Select USL
    Goto ( Val( arr_usl[ i, 2 ] ) )
    If !Eof() .and. usl->kod > 0
      Select TMP
      Append Blank
      tmp->u_kod := usl->kod
      tmp->u_shifr := usl->shifr
      tmp->u_name := usl->name
    Endif
  Next
  Select TMP
  Index On fsort_usl( FIELD->u_shifr ) to ( cur_dir() + 'tmpn' )

  Return Nil

//
Function f1_forma_39t_prn_diag_na( par, title )

  Local nfile := dir_server() + f39t_nastr, name_sect
  Local adbf, arr_diag, i

  //
  name_sect := f39tdz_sect + lstr( par )
  arr_diag := getinisect( nFile, name_sect )
  adbf := { ;
    { 'd_KOD',    'N',      4,      0 }, ;  // код услуги
    { 'd_SHIFR',  'C',     10,      0 }, ;  // шифр услуги
    { 'd_NAME',   'C',     65,      0 };   // наименование услуги
  }
  dbCreate( cur_dir() + 'tmp', adbf )
  r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'DIAG' )
  Use ( cur_dir() + 'tmp' ) new
  For i := 1 To Len( arr_diag )
    Select DIAG
    Goto ( Val( arr_diag[ i, 2 ] ) )
    If !Eof() .and. diag->( RecNo() ) > 0
      Select TMP
      Append Blank
      tmp->d_kod   := diag->( RecNo() )
      tmp->d_shifr := diag->shifr
      tmp->d_name  := diag->name
    Endif
  Next
  Select TMP
  Index On FIELD->d_shifr to ( cur_dir() + 'tmpn' )

  Return Nil

//
Static Function cre_tmp_39t( adbf )

  Local i

  For i := 2 To 55
    AAdd( adbf, { 'p' + lstr( i ), 'N', 7, 0 } )
  Next
  AAdd( adbf, { 'p56', 'N', 9, 2 } )
  dbCreate( fr_data, adbf )

  Return Nil

//
Function f1_forma_39t_na_diag( par, title, tip )

  Local nfile := dir_server() + f39t_nastr, name_sect
  Local adbf, arr_diag, i

  //
  name_sect := f39tdz_sect + lstr( par )
  arr_diag := getinisect( nFile, name_sect )
  adbf := { ;
    { 'D_KOD',    'N',      4,      0 }, ;  // код услуги
    { 'D_SHIFR',  'C',      6,      0 }, ;  // шифр услуги
    { 'D_NAME',   'C',     65,      0 };   // наименование услуги
  }
  dbCreate( cur_dir() + 'tmp', adbf )
  r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'DIAG' )
  Use ( cur_dir() + 'tmp' ) new
  For i := 1 To Len( arr_diag )
    Select DIAG
    Goto ( Val( arr_diag[ i, 2 ] ) )
    If !Eof() .and. diag->( RecNo() ) > 0
      Select TMP
      Append Blank
      tmp->d_kod   := diag->( RecNo() )
      tmp->d_shifr := diag->shifr
      tmp->d_name  := diag->name
    Endif
  Next
  Select TMP
  Index On Str( FIELD->d_kod, 4 ) to ( cur_dir() + 'tmpk' )
  Index On FIELD->d_shifr to ( cur_dir() + 'tmpn' )
  Close databases
  ob2_v_diag(, 2, 'Настройка формы 39-терапия: колонка ДИАГНОЗ ' + title )
  If f_esc_enter( 1 )
    arr_diag := {}
    Use ( cur_dir() + 'tmp' ) index ( cur_dir() + 'tmpn' ) New Alias TMP
    Go Top
    Do While !Eof()
      AAdd( arr_diag, { tmp->d_shifr, lstr( tmp->d_kod ) } )
      Skip
    Enddo
    Close databases
    setinisect( nFile, name_sect, arr_diag )
  Endif

  Return Nil

//
Function forma_39tall( tip_f39 )

  Static sds := 0
  Local i, j, k, arr, begin_date, end_date, s, buf := save_row( 24 ), ;
    fl_exit := .f., tm, t, tt, t1, t2, s_lu := 0, s_human := 0, ;
    kh := 0, jh := 0, arr_m, arr_pl, arr_dms, ttt
  Local  mas_pmt := { ;
    'По дате ~окончания лечения', ;
    'По ~дате оказания услуги' }

  // Public menu_vid_opl := {{'ОМС',1},;  //  (битовое)
  // {'Бюджет',2},;
  // {'Пл.услуги',3},;
  // {'ДМС',4},;
  // {'Другое',5}}
  Private Pi1 := 0, Pi1_DATE, Pi1_OMS := 1

  For j := 1 To 56
    t := 'au' + lstr( j )
    tt := 'aud' + lstr( j )
    ttt := 'auz' + lstr( j )
    Private &t
    Private &tt
    Private &ttt
  Next
  Private mas_diag := {}
  //
  If !get_nastr_stom_f39t()
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If ( krvz := fbp_tip_f39( T_ROW, T_COL -5, @arr_dms ) ) == NIL
    Return Nil
  Endif
  If ( j := popup_prompt( T_ROW, T_COL -5, sds, mas_pmt,,, 'B/BG,W+/B,N/BG,BG+/B' ) ) > 0
    sds := j
  Endif
  Pi1 := j
  If tip_f39 == 1 .and. !input_perso( T_ROW, T_COL -5, .f. )
    Return Nil
  Endif
  Private speriod := arr_m[ 4 ]
  begin_date := arr_m[ 7 ]
  end_date := DToS( arr_m[ 6 ] )
  //
  waitstatus( '<Esc> - прервать поиск' ) ; mark_keys( { '<Esc>' } )
  //
  delfrfiles()
  dbCreate( cur_dir() + 'tmp_hum', { { 'kod_h', 'N', 6, 0 }, ;
    { 'date_u', 'C', 4, 0 } } )
  cre_tmp_39t( { ;
    { 'p_kod', 'C', 4, 0 }, ;
    { 'data', 'D', 8, 0 }, ;
    { 'tip', 'N', 1, 0 }, ;   // 1-весь персонал, 2-перс.в отделении, 3-отделение
    { 'otd', 'N', 2, 0 }, ;
    { 'tab_nom', 'N', 5, 0 }, ;
    { 'name', 'C', 25, 0 }, ;
    { 'summa', 'N', 10, 2 }, ;
    { 'sr_it', 'N', 1, 0 }, ;
    { 'sanirov', 'N', 10, 0 }, ;
    { 'yet', 'N', 10, 2 }, ;
    { 'p1', 'N', 10, 2 };
  } )
  Use ( fr_data ) New Alias TMP
  Index On Str( FIELD->tip, 1 ) + FIELD->p_kod to ( cur_dir() + 'tmp' )
  r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'DIAG' )
  //
  If AScan( krvz, 1 ) > 0  // ОМС
    Pi1_OMS := 1
    If Pi1 == 1 // по дате окончания лечения
      r_use( dir_server() + 'kartote_',, 'KARTOTE_' )
      If AScan( krvz, 3 ) > 0 // платные присутствуют
        // Pi1_OMS := 0
        r_use( dir_server() + 'hum_p_u', dir_server() + 'hum_p_u', 'PHU' )
        r_use( dir_server() + 'hum_p', dir_server() + 'hum_pkk', 'PHUMAN' )
      Endif
      r_use( dir_server() + 'human_',, 'HUMAN_' )
      r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
      r_use( dir_server() + 'human_u_',, 'HU_' )
      r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
      dbSeek( arr_m[ 5 ], .t. )
      // цикл по ОМС
      Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
        // проходим по диагнозам
        mas_diag := {}
/*      if len(alltrim(human->kod_diag)) > 3
        aadd(mas_diag,human->kod_diag)
      endif
      if len(alltrim(human->kod_diag2)) > 3
        aadd(mas_diag,human->kod_diag2)
      endif
      if len(alltrim(human->kod_diag3)) > 3
        aadd(mas_diag,human->kod_diag3)
      endif
      if len(alltrim(human->kod_diag4)) > 3
        aadd(mas_diag,human->kod_diag4)
      endif
      preobr_mkb()
 */
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select TMP
        find ( '1' + dtoc4( human->k_data ) )  // поиск по дате
        If !Found()
          Append Blank
          tmp->p_kod := dtoc4( human->k_data )
          tmp->data  := human->k_data
          tmp->tip   := 1
        Endif
        // tmp->summa += human->cena
        If ( arr := yes_f_39t( 0, 0, tip_f39 ) ) != NIL
          ++jh
          For i := 1 To Len( arr )
            write_f39t( arr[ i ] )
          Next
        Endif
        @ 24, 1 Say lstr( ++kh ) Color cColorSt2Msg
        If jh > 0
          @ Row(), Col() Say '/' Color 'W/R'
          @ Row(), Col() Say lstr( jh ) Color cColorStMsg
        Endif
        Select HUMAN
        Skip
      Enddo
      KARTOTE_->( dbCloseArea() )
      HU->( dbCloseArea() )
      HU_->( dbCloseArea() )
      HUMAN->( dbCloseArea() )
      HUMAN_->( dbCloseArea() )
      If AScan( krvz, 3 ) > 0 // платные присутствуют
        PHU->( dbCloseArea() )
        PHUMAN->( dbCloseArea() )
      Endif
    Else  // дата оказания услуг
      r_use( dir_server() + 'kartote_',, 'KARTOTE_' )
      If AScan( krvz, 3 ) > 0 // платные присутствуют
        // Pi1_OMS := 0
        r_use( dir_server() + 'hum_p_u', dir_server() + 'hum_p_u', 'PHU' )
        r_use( dir_server() + 'hum_p', dir_server() + 'hum_pkk', 'PHUMAN' )
      Endif
      r_use( dir_server() + 'human_',, 'HUMAN_' )
      r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
      r_use( dir_server() + 'human_u_',, 'HU_' )
      r_use( dir_server() + 'human_u', dir_server() + 'human_ud', 'HU' )
      Use ( cur_dir() + 'tmp_hum' ) New Alias TMP_HUM
      Select HU
      dbSeek( arr_m[ 7 ], .t. )
      Do While hu->date_u <= arr_m[ 8 ] .and. !Eof()
        Select TMP_HUM
        Append Blank
        tmp_hum->kod_h  := hu->kod
        tmp_hum->date_u := hu->date_u
        Select HU
        Skip
      Enddo
      Select TMP_HUM
      Index On Str( FIELD->kod_h, 6 ) + FIELD->date_u to ( cur_dir() + 'tmp_om' ) Unique progress
      HU->( dbCloseArea() )
      r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
      Select TMP_HUM
      // создаём временный индекс - выбираем все нужные нам случ
      // цикл по ОМС
      Go Top
      Do While !Eof()
        // проходим по диагнозам
        Select HUMAN
        Goto ( TMP_HUM->kod_h )
        Pi1_DATE := tmp_hum->date_u
        mas_diag := {}
 /*     if len(alltrim(human->kod_diag)) > 3
        aadd(mas_diag,human->kod_diag)
      endif
      if len(alltrim(human->kod_diag2)) > 3
        aadd(mas_diag,human->kod_diag2)
      endif
      if len(alltrim(human->kod_diag3)) > 3
        aadd(mas_diag,human->kod_diag3)
      endif
      if len(alltrim(human->kod_diag4)) > 3
        aadd(mas_diag,human->kod_diag4)
      endif
      preobr_mkb()
 */
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select TMP
        find ( '1' + tmp_hum->date_u )  // поиск по дате
        If !Found()
          Append Blank
          tmp->p_kod := tmp_hum->date_u
          tmp->data  := c4tod( tmp_hum->date_u )
          tmp->tip   := 1
        Endif
        // tmp->summa += human->cena
        If ( arr := yes_f_39t( 0, 0, tip_f39 ) ) != NIL
          ++jh
          For i := 1 To Len( arr )
            write_f39t( arr[ i ] )
          Next
        Endif
        @ 24, 1 Say lstr( ++kh ) Color cColorSt2Msg
        If jh > 0
          @ Row(), Col() Say '/' Color 'W/R'
          @ Row(), Col() Say lstr( jh ) Color cColorStMsg
        Endif
        Select TMP_HUM
        Skip
      Enddo
      KARTOTE_->( dbCloseArea() )
      HU->( dbCloseArea() )
      HU_->( dbCloseArea() )
      HUMAN->( dbCloseArea() )
      HUMAN_->( dbCloseArea() )
      TMP_HUM->( dbCloseArea() )
      If AScan( krvz, 3 ) > 0 // платные присутствуют
        PHU->( dbCloseArea() )
        PHUMAN->( dbCloseArea() )
      Endif
    Endif
  Endif
  // для СОНИРОВАНО
  If AScan( krvz, 1 ) > 0  // ОМС
    r_use( dir_server() + 'kartote_',, 'KARTOTE_' )
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
    dbSeek( arr_m[ 5 ], .t. )
    // цикл по ОМС
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
      // проходим о диагнозам
      Select HUMAN_
      Goto ( human->( RecNo() ) )
      If iif( tip_f39 == 1, glob_human[ 1 ] == human_->vrach, .t. )
        If human_->ISHOD_NEW == 301
          Select TMP
          find( '1' + dtoc4( human->k_data ) )
          If Found()
            g_rlock( forever )
            tmp->p10 += 1
            Unlock
          Endif
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    KARTOTE_->( dbCloseArea() )
    HUMAN->( dbCloseArea() )
    HUMAN_->( dbCloseArea() )
  Endif

  // цикл только по платным
  If AScan( krvz, 3 ) > 0 // .and. ascan(krvz,1) == 0
    Pi1_OMS := 0
    r_use( dir_server() + 'kartote_',, 'KARTOTE_' )
    r_use( dir_server() + 'hum_p_u', dir_server() + 'hum_p_u', 'HU' )
    r_use( dir_server() + 'hum_p', dir_server() + 'hum_pd', 'HUMAN' )
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    // цикл по ОМС
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
/*    mas_diag := {}
    if len(alltrim(human->kod_diag)) > 3
      aadd(mas_diag,human->kod_diag)
    endif
    if len(alltrim(human->soput_b1)) > 3
      aadd(mas_diag,human->soput_b1)
    endif
    if len(alltrim(human->soput_b2)) > 3
      aadd(mas_diag,human->soput_b2)
    endif
    if len(alltrim(human->soput_b3)) > 3
      aadd(mas_diag,human->soput_b3)
    endif
    if len(alltrim(human->soput_b4)) > 3
      aadd(mas_diag,human->soput_b4)
    endif
    if len(alltrim(human->soput_b5)) > 3
      aadd(mas_diag,human->soput_b5)
    endif
    preobr_mkb()
    */
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      Select TMP
      find ( '1' + dtoc4( human->k_data ) )  //
      If !Found()
        Append Blank
        tmp->p_kod := dtoc4( human->k_data )
        tmp->data  := human->k_data
        tmp->tip   := 1
      Endif
      // tmp->summa += human->cena
      If ( arr := yes_f_39t( 0, 0, tip_f39 ) ) != NIL
        ++jh
        For i := 1 To Len( arr )
          write_f39t( arr[ i ] )
        Next
      Endif
      @ 24, 1 Say lstr( ++kh ) Color cColorSt2Msg
      If jh > 0
        @ Row(), Col() Say '/' Color 'W/R'
        @ Row(), Col() Say lstr( jh ) Color cColorStMsg
      Endif
      Select HUMAN
      Skip
    Enddo
  Endif
  //

  Close databases

  rest_box( buf )
  mybell()
  //
  Use ( fr_data ) new
  Index On FIELD->p_kod to ( fr_data )
  //
  dbCreate( fr_titl, { { 'god', 'N', 4, 0 }, ;
    { 'tit1name', 'C', 130, 0 }, ;
    { 'tit2name', 'C', 130, 0 }, ;
    { 'tit3name', 'C', 130, 0 }, ;
    { 'tit4name', 'C', 130, 0 } } )
  r_use( dir_server() + 'organiz',, 'ORG' )
  add_string( AllTrim( org->name ) )
  Use ( fr_titl ) new
  Append Blank
  Replace tit1name With AllTrim( org->name )
  Replace tit2name With AllTrim( arr_m[ 4 ] )
  If tip_f39 == 1 // по врачу
    Replace tit3name With AllTrim( glob_human[ 2 ] )
  Endif
  t := ''
  If AScan( krvz, 1 ) > 0
    t := 'ОМС'
  Endif
  If AScan( krvz, 3 ) > 0
    t += ' + Платные услуги'
  Endif
  Replace tit4name With t
  Close databases
  call_fr( 'mo_stt39.fr3' )

  Return Nil

// проверить больного по БД human и вернуть результат в виде массива
Static Function yes_f_39t( par1, vozrast, vrach )

  Local i, j, k, s, arr, ret, t_human := .t., t_select
  Private t_mas := Array( 65 ), lp := Array( 60 )
  Private mdate_r, m1vzros_reb := 0, t_vrach := vrach

  arr := {}
  // проходим по услугам
  Select HU
  t_human := .t.
  find ( Str( human->( RecNo() ), 6 ) )
  Do While hu->kod == human->( RecNo() ) .and. !Eof()
    If iif( vrach == 1, glob_human[ 1 ] == hu->kod_vr, .t. )
      If iif( Pi1 == 1, .t., hu->date_u == Pi1_DATE )
        Select HU_
        Goto ( hu->( RecNo() ) )
        Select DIAG
        find ( AllTrim( hu_->kod_diag ) + ' ' )
        If Found()
          mas_diag := {}
          TMP_DIAG := diag->( RecNo() )
          AAdd( mas_diag, TMP_DIAG )
        Endif
        Select HU
        //
        k := hu->kol
        AFill( lp, 0 )
        ___f_39t( k )
        If vozrast == 1
          mdate_r := human->date_r
          fv_date_r(, .f. )
        Else

        Endif
        t_select := Select()
        Select KARTOTE_
        Goto human->kod_k
        Select KARTOTE_
        If SubStr( kartote_->okatog, 1, 3 ) == '184'
          lp[ 3 ] := 0
        Endif
        If m1vzros_reb == 0 // взрослые
          // lp[1] := lp[3]
          // lp[4] := lp[6]
        Else
          // lp[2] := lp[3]
          // lp[5] := lp[6]
        Endif

        // УЕТ
        lp[ 56 ] := opr_uet( m1vzros_reb ) * k
        //
        // if lp[37]
        // РЕЗУЛЬТАТ
        AAdd( arr, AClone( lp ) )
        // endif
      Endif
    Endif
    Select HU
    Skip
  Enddo
  If Len( arr ) > 0
    // проверяем второй список
    ret := arr
  Endif

  Return ret

//
Function ___f_39t( k )

  Local _1, _2, t_rec, t_flag, t_kart, t_date, tt1 := 0, tt2 := 0, tt3 := 0, tt4 := 0, ;
    tt5 := 0, tt6 := 0

  t_rec := hu->( RecNo() )

  For j := 1 To 56 // 56
    t := 'au' + lstr( j )
    t1 := &t
    _1 := ( AScan( &t, {| x| x[ 2 ] == hu->u_kod } ) > 0 )
    tt1 := _1
    If _1
      If j < 56
        If Len( AllTrim( hu_->zf ) ) == 2
          lp[ j ]  := 1
        Elseif Len( AllTrim( hu_->zf ) ) > 2
          lp[ j ]  := 2
        Else
          lp[ j ]  := k
        Endif
      Endif

    Endif
    // проверяем второй список
    // делаем цикл по всему случаю
    tt := 'aud' + lstr( j )
    t2 := &tt
    t_flag := .f.
    If Len( &tt ) > 0
      // если ответ отрицательный - нулируем предыдущий результат
      t_flag := .t.
      t_rec := hu->( RecNo() )
      find ( Str( human->( RecNo() ), 6 ) )
      Do While hu->kod == human->( RecNo() ) .and. !Eof()
        If iif( t_vrach == 1, glob_human[ 1 ] == hu->kod_vr, .t. )
          _2 := ( AScan( &tt, {| x| x[ 2 ] == hu->u_kod } ) > 0 )
          tt4 := _2
          If _2
            t_flag := .f.
          Endif
        Endif
        Skip
      Enddo
      // проверка по ПЛАТНЫМ внутри ОМС
    /*  if ascan(krvz,3) > 0 .and. ascan(krvz,1) > 0
        //@ 10,20 say  human->kod_k
        //inkey(0)
        select HUMAN
        t_kart := human->kod_k
        // по дате окончания лечения
        if Pi1 == 1 //по дате окончания лечения
          t_date := human->k_data
        else // по дате услуги
          t_date := c4tod(Pi1_DATE)
        endif
        select PHUMAN
        find (str(t_kart,6)+dtos(t_date))
        // перебираем случаи
        do while phuman->kod_k == t_kart .and.;
                 phuman->k_data == t_date .and. !eof()
          select PHU
          // перебираем услуги
          //t_rec := hu->(recno())
          find (str(phuman->(recno()),6))
          do while phu->kod == phuman->(recno()) .and. !eof()
            if iif(t_vrach== 1,glob_human[1] == phu->kod_vr,.T.)
              _2 := (ascan(&tt,{|x| x[2] == phu->u_kod}) > 0)
              if _2
                t_flag := .F.
              endif
            endif
            skip
          enddo
          select PHUMAN
          skip
        enddo
      endif
      */
      // конец проверки ОМС
      tt2 := t_flag

      If t_flag
        If j < 56
          lp[ j ]  := 0
        Endif
      Endif
      hu->( dbGoto( t_rec ) )
    Endif
    // проверяем третий список - ДИАГНОЗЫ
    ttt := 'auz' + lstr( j )
    t3 := &ttt
    If Len( &ttt ) > 0
      // если ответ отрицательный - нулируем предыдущий результат
      // у нас есть масси диагнозов
      For ll := 1 To Len( mas_diag )
        _3 := ( AScan( &ttt, {| x| x[ 2 ] == mas_diag[ ll ] } ) > 0 )
        tt3 := _3

        If _3
          Exit
        Else
          If j < 56
            lp[ j ]  := 0
          Endif
        Endif
      Next
    Endif
    // проверяем на дублирование зубной формулы
    If j > 11 .and. j < 24

    Endif
  Next

  Return Nil
