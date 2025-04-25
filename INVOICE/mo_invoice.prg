// mo_invoice.prg - работа со списком счетов в задаче ОМС
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 02.04.13 Просмотр списка счетов, запись для ТФОМС, печать счетов
Function view_list_schet()

  Local i, k, buf := SaveScreen(), tmp_help := chm_help_code, mdate := SToD( '20130101' )

  mywait()
  Close databases
  r_use( dir_server + 'mo_rees', , 'REES' )
  g_use( dir_server + 'mo_xml', , 'MO_XML' )
  g_use( dir_server + 'schet_', , 'SCHET_' )
  g_use( dir_server + 'schet', dir_server + 'schetd', 'SCHET' )
  Set Relation To RecNo() into SCHET_
  dbSeek( dtoc4( mdate ), .t. )
  Index On DToS( schet_->dschet ) + fsort_schet( schet_->nschet, nomer_s ) to ( cur_dir + 'tmp_sch' ) ;
    For schet_->dschet >= mdate .and. !Empty( pdate ) .and. ;
    ( schet_->IS_DOPLATA == 1 .or. !Empty( Val( schet_->smo ) ) ) ;
    DESCENDING
  Go Top
  If Eof()
    RestScreen( buf )
    Close databases
    Return func_error( 4, 'Нет выписанных счетов c ' + date_month( mdate ) )
  Endif
  chm_help_code := 122
  box_shadow( MaxRow() -3, 0, MaxRow() -1, 79, color0 )
  alpha_browse( T_ROW, 0, MaxRow() -4, 79, 'f1_view_list_schet', color0, , , , , , 'f21_view_list_schet', ;
    'f2_view_list_schet', , { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, RB/BG, GR/BG', .t., 60 } )
  Close databases
  chm_help_code := tmp_help
  RestScreen( buf )

  Return Nil

// 24.04.25
Function f1_view_list_schet( oBrow )

  Local oColumn, ;
    blk := {|| iif( !Empty( schet_->NAME_XML ) .and. Empty( schet_->date_out ), { 3, 4 }, { 1, 2 } ) }

  oColumn := TBColumnNew( 'Номер счета', {|| schet_->nschet } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '  Дата', {|| date_8( schet_->dschet ) } )
  oColumn:colorBlock := {|| f23_view_list_schet() }
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Пе-;риод', ;
    {|| iif( emptyany( schet_->nyear, schet_->nmonth ), ;
    Space( 5 ), ;
    Right( Str( schet_->nyear, 4 ), 2 ) + '/' + StrZero( schet_->nmonth, 2 ) ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Сумма счета', {|| put_kop( schet->summa, 13 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Кол.;бол.', {|| Str( schet->kol, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Критерий', {|| PadR( f3_view_list_schet(), 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Принадлежность;счета', {|| PadR( f4_view_list_schet(), 14 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '  ', {|| f22_view_list_schet() } )
  oColumn:colorBlock := {|| f23_view_list_schet() }
  oBrow:addcolumn( oColumn )
//  status_key( '^<Esc>^ - выход;  ^<F5>^ - запись счетов за день;  ^<F9>^ - печать счёта/реестра' )
  status_key( '^<Esc>^-выход ^<F5>^-запись счетов за день ^<F6>^-документы за день ^<F9>^-печать счёта/реестра' )
  Return Nil

//
Function f21_view_list_schet()

  Local s := '', fl := .t., r := Row(), c := Col()

  If !emptyany( schet_->name_xml, schet_->kod_xml )
    fl := hb_FileExists( dir_server + dir_XML_MO + cslash + AllTrim( schet_->name_xml ) + szip )
    s := iif( fl, 'XML-файл: ', 'Нет XML-файла: ' ) + AllTrim( schet_->name_xml )
    mo_xml->( dbGoto( schet_->XML_REESTR ) )
    If mo_xml->REESTR > 0
      rees->( dbGoto( mo_xml->REESTR ) )
      s += ', по реестру № ' + lstr( rees->NSCHET ) + ' от ' + ;
        date_8( rees->DSCHET ) + 'г. (' + lstr( rees->KOL ) + ' чел.)'
    Endif
  Endif
  @ MaxRow() -2, 1 Say PadC( s, 78 ) Color iif( fl, color0, 'R/BG' )
  SetPos( r, c )

  Return Nil

//
Function f22_view_list_schet()

  Local s := '  '

  If schet_->NREGISTR == 1 // ещё не зарегистрирован
    s := ''
  Elseif schet_->NREGISTR == 2 // не будет зарегистрирован
    s := '▄▀'
  Elseif schet_->NREGISTR == 3 // удалён
    s := '--'
  Endif

  Return s

//
Function f23_view_list_schet()

  Local arr := iif( !Empty( schet_->NAME_XML ) .and. Empty( schet_->date_out ), { 3, 4 }, { 1, 2 } )

  If schet_->NREGISTR == 1 // ещё не зарегистрирован
    arr[ 1 ] := 5
  Elseif schet_->NREGISTR == 2 // не будет зарегистрирован
    arr[ 1 ] := 6
  Elseif schet_->NREGISTR == 3 // удалён
    arr[ 1 ] := 7
  Endif

  Return arr

// 25.04.25
Function f2_view_list_schet( nKey, oBrow )

  Local ret := -1, rec := schet->( RecNo() ), tmp_color := SetColor(), r, r1, r2, ;
    s, buf := SaveScreen(), arr, i, k, mdate, t_arr[ 2 ], arr_pmt := {}
  local destination, row, print_arr := {}

  Do Case
  Case nKey == K_F9
    print_schet( oBrow )
    Select SCHET
    ret := 0
  Case nKey == K_F6
    r := Row()
    arr := {}
    k := 0
    mdate := schet_->dschet
    find ( DToS( mdate ) )
    Do While schet_->dschet == mdate .and. !Eof()
      If !emptyany( schet_->name_xml, schet_->kod_xml )
        AAdd( arr, { schet_->nschet, schet_->name_xml, schet_->kod_xml, schet->( RecNo() ) } )
//        If Empty( schet_->date_out )
//          ++k
//        Endif
      Endif
      Skip
    Enddo
    If Len( arr ) == 0
      func_error( 4, 'Нечего записывать!' )
    Else
      If Len( arr ) > 1
        ASort( arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
        For i := 1 To Len( arr )
          schet->( dbGoto( arr[ i, 4 ] ) )
          AAdd( arr_pmt, { 'Счёт № ' + AllTrim( schet_->nschet ) + ' (' + ;
            lstr( schet_->nyear ) + '/' + StrZero( schet_->nmonth, 2 ) + ')', ;
            AClone( arr[ i ] ) } )
        Next
        If r + 2 + Len( arr ) > MaxRow() - 2
          r2 := r - 1
          r1 := r2 - Len( arr ) - 1
          If r1 < 0
            r1 := 0
          Endif
        Else
          r1 := r + 1
        Endif
        arr := {} // массив печатаемых счетов
        If ( t_arr := bit_popup( r1, 10, arr_pmt, , color5, 1, 'Запись документов (' + date_8( mdate ) + ')', 'B/W' ) ) != nil
          AEval( t_arr, {| x | AAdd( arr, AClone( x[ 2 ] ) ) } )
        Endif
        t_arr := Array( 2 )
      Endif
      If Len( arr ) > 0
        for each row in arr // выбираем только номера записей счетов для печати
          AAdd( print_arr , row[ 4 ] )
        next
        If f_esc_enter( 'записи за ' + date_8( mdate ) + 'г.' )
          Private p_var_manager := 'copy_schet'
          destination := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 2, .f., , , ) // 'norton' для выбора каталога
          If ! Empty( destination )
            schet_reestr( print_arr, destination )
          Endif
        Endif
      Endif
    Endif
    Select SCHET
    Goto ( rec )
    ret := 0
  Case nKey == K_F5
    r := Row()
    arr := {}
    k := 0
    mdate := schet_->dschet
    find ( DToS( mdate ) )
    Do While schet_->dschet == mdate .and. !Eof()
      If !emptyany( schet_->name_xml, schet_->kod_xml )
        AAdd( arr, { schet_->nschet, schet_->name_xml, schet_->kod_xml, schet->( RecNo() ) } )
        If Empty( schet_->date_out )
          ++k
        Endif
      Endif
      Skip
    Enddo
    If Len( arr ) == 0
      func_error( 4, 'Нечего записывать!' )
    Else
      If Len( arr ) > 1
        ASort( arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
        For i := 1 To Len( arr )
          schet->( dbGoto( arr[ i, 4 ] ) )
          AAdd( arr_pmt, { 'Счёт № ' + AllTrim( schet_->nschet ) + ' (' + ;
            lstr( schet_->nyear ) + '/' + StrZero( schet_->nmonth, 2 ) + ;
            ') файл ' + AllTrim( schet_->name_xml ), AClone( arr[ i ] ) } )
        Next
        If r + 2 + Len( arr ) > MaxRow() -2
          r2 := r -1
          r1 := r2 - Len( arr ) -1
          If r1 < 0
            r1 := 0
          Endif
        Else
          r1 := r + 1
        Endif
        arr := {}
        If ( t_arr := bit_popup( r1, 10, arr_pmt, , color5, 1, 'Записываемые файлы счетов (' + date_8( mdate ) + ')', 'B/W' ) ) != NIL
          AEval( t_arr, {| x| AAdd( arr, AClone( x[ 2 ] ) ) } )
        Endif
        t_arr := Array( 2 )
      Endif
      If Len( arr ) > 0
        s := 'Количество счетов - ' + lstr( Len( arr ) ) + ;
          ', записываются в первый раз - ' + lstr( k ) + ':'
        For i := 1 To Len( arr )
          If i > 1
            s += ','
          Endif
          s += ' ' + AllTrim( arr[ i, 1 ] ) + ' (' + AllTrim( arr[ i, 2 ] ) + szip + ')'
        Next
        perenos( t_arr, s, 74 )
        f_message( t_arr, , color1, color8 )
        If f_esc_enter( 'записи счетов за ' + date_8( mdate ) + 'г.' )
          Private p_var_manager := 'copy_schet'
          s := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 2, .f., , , ) // 'norton' для выбора каталога
          If !Empty( s )
            goal_dir := dir_server + dir_XML_MO + cslash
            If Upper( s ) == Upper( goal_dir )
              func_error( 4, 'Вы выбрали каталог, в котором уже записаны целевые файлы! Это недопустимо.' )
            Else
              cFileProtokol := 'prot_sch' + stxt
              StrFile( hb_eol() + Center( glob_mo[ _MO_SHORT_NAME ], 80 ) + hb_eol() + hb_eol(), cFileProtokol )
              smsg := 'Счета записаны на: ' + s + ;
                ' (' + full_date( sys_date ) + 'г. ' + hour_min( Seconds() ) + ')'
              StrFile( Center( smsg, 80 ) + hb_eol(), cFileProtokol, .t. )
              k := 0
              For i := 1 To Len( arr )
                zip_file := AllTrim( arr[ i, 2 ] ) + szip
                If hb_FileExists( goal_dir + zip_file )
                  mywait( 'Копирование "' + zip_file + '" в каталог "' + s + '"' )
                  // copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
                  Copy File ( goal_dir + zip_file ) to ( s + zip_file )
                  // if hb_fileExists(hb_OemToAnsi(s)+zip_file)
                  If hb_FileExists( s + zip_file )
                    ++k
                    schet->( dbGoto( arr[ i, 4 ] ) )
                    smsg := lstr( i ) + '. Счёт № ' + AllTrim( schet_->nschet ) + ;
                      ' от ' + date_8( mdate ) + 'г. (отч.период ' + ;
                      lstr( schet_->nyear ) + '/' + StrZero( schet_->nmonth, 2 ) + ;
                      ') ' + AllTrim( schet_->name_xml ) + szip
                    StrFile( hb_eol() + smsg + hb_eol(), cFileProtokol, .t. )
                    smsg := '   количество пациентов - ' + lstr( schet->kol ) + ;
                      ', сумма счёта - ' + expand_value( schet->summa, 2 )
                    StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                    schet_->( g_rlock( forever ) )
                    schet_->DATE_OUT := sys_date
                    If schet_->NUMB_OUT < 99
                      schet_->NUMB_OUT++
                    Endif
                    //
                    mo_xml->( dbGoto( arr[ i, 3 ] ) )
                    mo_xml->( g_rlock( forever ) )
                    mo_xml->DREAD := sys_date
                    mo_xml->TREAD := hour_min( Seconds() )
                  Else
                    smsg := '! Ошибка записи файла ' + s + zip_file
                    func_error( 4, smsg )
                    StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                  Endif
                Else
                  smsg := '! Не обнаружен файл ' + goal_dir + zip_file
                  func_error( 4, smsg )
                  StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                Endif
              Next
              Unlock
              Commit
              viewtext( cFileProtokol, , , , .t., , , 2 )
                /*asize(t_arr, 1)
                perenos(t_arr,'Записано счетов - ' + lstr(k) + ' в каталог '+s+;
                     iif(k == len(arr), '', ', не записано счетов - ' + lstr(len(arr)-k)), 60)
                stat_msg('Запись завершена!')
                n_message(t_arr,,'GR+/B','W+/B', 18,,'G+/B')*/
            Endif
          Endif
        Endif
      Endif
    Endif
    Select SCHET
    Goto ( rec )
    ret := 0
  Case nKey == K_CTRL_F11 .and. !Empty( schet_->NAME_XML ) .and. schet_->XML_REESTR > 0
    k := schet_->XML_REESTR // ссылка на реестр СП и ТК
    arr := {}
    Go Top
    Do While !Eof()
      If !emptyany( schet_->name_xml, schet_->kod_xml ) .and. k == schet_->XML_REESTR
        AAdd( arr, schet->( RecNo() ) )
      Endif
      Skip
    Enddo
    If Len( arr ) == 0
      func_error( 4, 'Неудачный поиск!' )
    Else
      If Len( arr ) > 1
        For i := 1 To Len( arr )
          schet->( dbGoto( arr[ i ] ) )
          AAdd( arr_pmt, { 'Счёт № ' + AllTrim( schet_->nschet ) + ' (' + ;
            lstr( schet_->nyear ) + '/' + StrZero( schet_->nmonth, 2 ) + ;
            ') файл ' + AllTrim( schet_->name_xml ), arr[ i ] } )
        Next
        r := Row()
        If r + 2 + Len( arr ) > MaxRow() -2
          r2 := r -1
          r1 := r2 - Len( arr ) -1
          If r1 < 0
            r1 := 0
          Endif
        Else
          r1 := r + 1
        Endif
        arr := {}
        If ( t_arr := bit_popup( r1, 10, arr_pmt, , 'N/W*, GR+/R', 1, 'Пересоздаваемые файлы счетов', 'B/W*' ) ) != NIL
          AEval( t_arr, {| x| AAdd( arr, x[ 2 ] ) } )
        Endif
      Endif
      If Len( arr ) > 0
        recreate_some_schet_from_file_sp( arr )
        Close databases
        r_use( dir_server + 'mo_rees', , 'REES' )
        g_use( dir_server + 'mo_xml', , 'MO_XML' )
        g_use( dir_server + 'schet_', , 'SCHET_' )
        g_use( dir_server + 'schet', dir_server + 'schetd', 'SCHET' )
        Set Relation To RecNo() into SCHET_
        Go Top
        ret := 1
      Endif
    Endif
  Case nKey == K_CTRL_F12 .and. !Empty( schet_->NAME_XML ) .and. schet_->XML_REESTR > 0
    recreate_some_schet_from_file_sp( { schet->( RecNo() ) } )
    Close databases
    r_use( dir_server + 'mo_rees', , 'REES' )
    g_use( dir_server + 'mo_xml', , 'MO_XML' )
    g_use( dir_server + 'schet_', , 'SCHET_' )
    g_use( dir_server + 'schet', dir_server + 'schetd', 'SCHET' )
    Set Relation To RecNo() into SCHET_
    Go Top
    ret := 1
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret

// 26.04.15
Function f3_view_list_schet()

  Local s := ''

  If schet_->nyear < 2013 .and. schet_->IS_MODERN == 1 // является модернизацией?;0-нет, 1-да для IFIN=1
    s := 'модернизация'
  Endif
  If schet_->IS_DOPLATA == 1 // является доплатой?;0-нет, 1-да для IFIN=1 или 2
    s := 'допл.'
    If schet_->IFIN == 1
      s += 'ТФОМС'
    Elseif schet_->IFIN == 2
      s += 'ФФОМС'
    Endif
  Endif
  If Empty( s ) .and. schet_->IFIN > 0
    s := 'ОМС '
    If schet_->bukva     == 'A'
      s += 'п-ка'
    Elseif schet_->bukva == 'D'
      s += 'ДДС'
    Elseif schet_->bukva == 'E'
      s += 'СМП'
    Elseif schet_->bukva == 'F'
      s += 'Нпроф.'
    Elseif schet_->bukva == 'G'
      s += 'дермат'
    Elseif schet_->bukva == 'H'
      s += 'ВМП'
    Elseif schet_->bukva == 'I'
      s += 'Нперио'
    Elseif schet_->bukva == 'J'
      s += 'п-ка'
    Elseif schet_->bukva == 'K'
      s += 'о/м/у'
    Elseif schet_->bukva == 'M'
      s += 'зак/с'
    Elseif schet_->bukva == 'O'
      s += 'ВНдисп'
    Elseif schet_->bukva == 'R'
      s += 'ВНпроф'
    Elseif schet_->bukva == 'S'
      s += 'стац.'
    Elseif schet_->bukva == 'T'
      s += 'стомат'
    Elseif schet_->bukva == 'U'
      s += 'ДДСоп'
    Elseif schet_->bukva == 'V'
      s += 'Нпред.'
    Elseif schet_->bukva == 'Z'
      s += 'дн/ст.'
    Elseif schet_->IFIN == 1
      s += 'ТФОМС'
    Elseif schet_->IFIN == 2
      s += 'ФФОМС'
    Endif
  Endif

  Return s

//
Function f4_view_list_schet( lkomu, lsmo, lstr_crb )

  Local s := ''

  Default lkomu To schet->komu, lsmo To schet_->smo, lstr_crb To schet->str_crb
  If lkomu == 5
    s := 'Личный счёт'
  Elseif !Empty( lsmo )
    s := inieditspr( A__MENUVERT, glob_arr_smo, Int( Val( lsmo ) ) )
    If Empty( s )
      s := inieditspr( A__POPUPMENU, dir_server + 'str_komp', lstr_crb )
      If Empty( s )
        s := lsmo
      Endif
    Endif
  Elseif lkomu == 1
    s := inieditspr( A__POPUPMENU, dir_server + 'str_komp', lstr_crb )
  Elseif lkomu == 3
    s := inieditspr( A__POPUPMENU, dir_server + 'komitet', lstr_crb )
  Endif

  Return s

// для совместимости со старой версией программы
Function func1_komu( lkomu, lstr_crb )
  Return f4_view_list_schet( lkomu, '', lstr_crb )

//
Function print_schet( oBrow )

  Static si := 1
  Local i, r := Row(), r1, r2, mm_menu := {}

  If schet_->IS_DOPLATA == 1 // является доплатой?;0-нет, 1-да для IFIN=1 или 2
    If schet_->IFIN == 1  // 'ТФОМС'
      print_schet_doplata( 1 )
    Elseif schet_->IFIN == 2 // 'ФФОМС'
      print_schet_doplata( 2 )
    Endif
  Elseif !Empty( Val( schet_->smo ) )
    For i := 1 To 2
      AAdd( mm_menu, 'Печать ' + iif( i == 1, '', 'реестра ' ) + 'счёта на оплату медицинской помощи' )
    Next
    If r <= MaxRow() / 2
      r1 := r + 1
      r2 := r1 + 3
    Else
      r2 := r -1
      r1 := r2 -3
    Endif
    If ( i := popup_prompt( r1, 10, si, mm_menu, , , color5 ) ) > 0
      si := i
      print_schet_s( i )
    Endif
  Else
    print_other_schet( 1 )
  Endif

  Return Nil

// Просмотр и печать выписанных счетов/реестров на доплату
Function print_schet_doplata( reg )

  // reg = 1 - доплата ТФОМС
  // reg = 2 - доплата ФФОМС
  Local arr_title, arr1title, sh, HH := 57, n_file := cur_dir + 'schetd' + stxt, ;
    s, i, j, j1, a_shifr[ 10 ], k1, k2, k3, lshifr, v_doplata, rec, ;
    buf := save_maxrow(), t_arr[ 2 ], llpu, lbank, ssumma := 0, ;
    fl_numeration, is_20_11, sdate := SToD( '20121120' ) // 20.11.2012г.

  If schet_->NREGISTR == 0 // зарегистрированные счета
    is_20_11 := ( date_reg_schet() >= sdate )
  Else
    is_20_11 := ( schet_->DSCHET > SToD( '20121210' ) ) // 10.12.2012г.
  Endif
  s1 := iif( reg == 2, Space( 11 ), 'и сопутст. ' )
  s2 := iif( reg == 2, Space( 11 ), 'диагноза   ' )
  arr_title := { ;
    '────┬───────────────┬────────────┬────────┬──────────┬───────────┬──────────────', ;
    '№   │№ счета по ОМС │№ страхового│Дата    │Код       │Код        │Доплата по    ', ;
    'пози│               │случая в    │счета по│закончен- │основного  │данной услуге ', ;
    'ции │               │счете по ОМС│ОМС     │ного      │диагноза   │из средств    ', ;
    'реес│               │            │        │случая    │' + s1 +     '│бюджета ' + iif( reg == 2, 'ФФОМС ', 'ТФОМС ' ), ;
    'тра │               │            │        │          │' + s2 +     '│(рублей)      ', ;
    '────┼───────────────┼────────────┼────────┼──────────┼───────────┼──────────────', ;
    ' 1  │       2       │      3     │   4    │    5     │     6     │       7      ', ;
    '────┴───────────────┴────────────┴────────┴──────────┴───────────┴──────────────' }
  arr1title := { ;
    '────┬───────────────┬────────────┬────────┬──────────┬───────────┬──────────────', ;
    ' 1  │       2       │      3     │   4    │    5     │     6     │       7      ', ;
    '────┴───────────────┴────────────┴────────┴──────────┴───────────┴──────────────' }
  //
  use_base( 'lusl' )
  use_base( 'lusld' )
  use_base( 'luslf' )
  r_use( dir_server + 'uslugi', , 'USL' )
  r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
  Set Relation To u_kod into USL
  r_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', dir_server + 'humans', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  r_use( dir_server + 'organiz', , 'ORG' )
  r_use( dir_server + 'schetd', , 'SD' )
  Index On Str( kod, 6 ) to ( cur_dir + 'tmp_sd' )
  //
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( Center( 'Счет № ' + AllTrim( schet_->nschet ) + ' от ' + full_date( schet_->dschet ) + ' г.', sh ) )
  s := 'на оплату медицинской помощи за счет средств бюджета ' + iif( reg == 2, 'Федерального', 'Территориального' ) + ' фонда '
  s += 'обязательного медицинского страхования ' + iif( reg == 2, '', 'Волгоградской области ' ) + 'по Программе модернизации здравоохранения '
  s += 'Волгоградской области на 2011-2012 годы в части реализации мероприятий по '
  s += 'поэтапному внедрению стандартов медицинской помощи'
  For k := 1 To perenos( t_arr, s, sh )
    add_string( Center( AllTrim( t_arr[ k ] ), sh ) )
  Next
  add_string( '' )
  sinn := org->inn
  skpp := ''
  If '/' $ sinn
    skpp := AfterAtNum( '/', sinn )
    sinn := BeforAtNum( '/', sinn )
  Endif
  sname    := org->name
  sbank    := org->bank
  sr_schet := org->r_schet
  sbik     := org->smfo
  If reg == 2
    If !Empty( org->r_schet2 )
      sbank    := org->bank2
      sr_schet := org->r_schet2
      sbik     := org->smfo2
    Endif
    If !Empty( org->name2 )
      sname := org->name2
    Endif
  Endif
  k := perenos( t_arr, sname, sh -11 )
  add_string( 'Поставщик: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 11 ) + t_arr[ 2 ] )
  Next
  add_string( 'ИНН: ' + PadR( sinn, 12 ) + ', КПП: ' + skpp )
  add_string( 'Адрес: ' + RTrim( org->adres ) )
  k := perenos( t_arr, sbank, sh -17 )
  add_string( 'Банк поставщика: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 17 ) + t_arr[ 2 ] )
  Next
  add_string( 'Расчетный счет: ' + AllTrim( sr_schet ) + ', БИК: ' + AllTrim( sbik ) )
  add_string( '' )
  add_string( '' )
  If ( j := AScan( get_rekv_smo(), {| x| x[ 1 ] == schet_->SMO } ) ) == 0
    j := Len( get_rekv_smo() ) // если не нашли - печатаем реквизиты ТФОМС
  Endif
  k := perenos( t_arr, get_rekv_smo()[ j, 2 ], sh -12 )
  add_string( 'Плательщик: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 12 ) + t_arr[ 2 ] )
  Next
  add_string( 'ИНН: ' + get_rekv_smo()[ j, 3 ] + ', КПП: ' + get_rekv_smo()[ j, 4 ] )
  k := perenos( t_arr, get_rekv_smo()[ j, 6 ], sh -7 )
  add_string( 'Адрес: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 7 ) + t_arr[ 2 ] )
  Next
  k := perenos( t_arr, get_rekv_smo()[ j, 7 ], sh -18 )
  add_string( 'Банк плательщика: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 18 ) + t_arr[ 2 ] )
  Next
  add_string( 'Расчетный счет: ' + AllTrim( get_rekv_smo()[ j, 8 ] ) + ', БИК: ' + AllTrim( get_rekv_smo()[ j, 9 ] ) )
  add_string( '' )
  add_string( '' )
  add_string( Center( 'Реестр счета № ' + AllTrim( schet_->nschet ) + ' от ' + full_date( schet_->dschet ) + ' г.', sh ) )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  Select SCHET
  fl_numeration := emptyany( schet_->nyear, schet_->nmonth )
  rec := RecNo()
  Set Index To
  j := 0
  Select SD
  find ( Str( rec, 6 ) )
  Do While sd->kod == rec .and. !Eof()
    schet->( dbGoto( sd->kod2 ) )
    j1 := 0
    Select HUMAN
    find ( Str( sd->kod2, 6 ) )
    Do While human->schet == sd->kod2 .and. !Eof()
      lshifr := ''
      v_doplata := r_doplata := 0
      ret_zak_sl( @lshifr, @v_doplata, @r_doplata, , , iif( is_20_11, sdate, nil ) )
      If iif( reg == 1, !Empty( r_doplata ), .t. )
        a_diag := diag_for_xml(, .t., , , .t. )
        s_diag := a_diag[ 1 ]
        If reg == 1 .and. Len( a_diag ) > 1 .and. !Empty( a_diag[ 2 ] )
          s_diag += ' ' + a_diag[ 2 ]
        Endif
        s := PadR( lstr( ++j ), 5 ) + ;
          PadC( AllTrim( schet_->nschet ), 15 ) + ' ' + ;
          PadR( Str( iif( fl_numeration, ++j1, human_->SCHET_ZAP ), 7 ), 13 ) + ;
          date_8( schet_->dschet ) + ' ' + ;
          PadC( lshifr, 10 ) + ;
          PadC( AllTrim( s_diag ), 13 ) + ;
          Str( iif( reg == 2, v_doplata, r_doplata ), 11, 2 )
        ssumma += iif( reg == 2, v_doplata, r_doplata )
        If verify_ff( HH, .t., sh )
          AEval( arr1title, {| x| add_string( x ) } )
        Endif
        add_string( s )
      Endif
      //
      Select HUMAN
      Skip
    Enddo
    Select SD
    Skip
  Enddo
  If verify_ff( HH -8, .t., sh )
    AEval( arr1title, {| x| add_string( x ) } )
  Endif
  add_string( Replicate( '─', sh ) )
  add_string( PadL( 'Всего: ' + lstr( ssumma, 14, 2 ), sh -3 ) )
  add_string( '' )
  k := perenos( t_arr, 'К оплате: ' + srub_kop( ssumma, .t. ), sh )
  add_string( t_arr[ 1 ] )
  For j := 2 To k
    add_string( PadL( AllTrim( t_arr[ j ] ), sh ) )
  Next
  add_string( '' )
  add_string( '  Главный врач медицинской организации      _____________ / ' + AllTrim( org->ruk ) + ' /' )
  add_string( '  Главный бухгалтер медицинской организации _____________ / ' + AllTrim( org->bux ) + ' /' )
  add_string( '                                        М.П.' )
  FClose( fp )

  rest_box( buf )
  close_use_base( 'lusl' )
  lusld->( dbCloseArea() )
  close_use_base( 'luslf' )
  usl->( dbCloseArea() )
  hu->( dbCloseArea() )
  human_->( dbCloseArea() )
  human->( dbCloseArea() )
  org->( dbCloseArea() )
  sd->( dbCloseArea() )
  If Select( 'USL1' ) > 0
    usl1->( dbCloseArea() )
  Endif
  Select SCHET
  If !( Round( ssumma, 2 ) == Round( schet->summa, 2 ) )
    // если ТФОМС поменял ценник - перезапишем сумму счёта
    Goto ( rec )
    g_rlock( forever )
    schet->summa := schet->summa_ost := ssumma
    Unlock
    Commit
  Endif
  Set Index to ( cur_dir + 'tmp_sch' )
  Goto ( rec )
  viewtext( n_file, , , , .t., , , 2 )

  Return Nil

// 18.04.25 печать счета
Function print_schet_s( reg )

  Local adbf, j, s, ii := 0, fl_numeration := .f., ;
    lshifr1, ldate1, ldate2, hGauge
  local  buf := save_maxrow()

  local fNameSchet

  mywait()
  delfrfiles()
  adbf := { { 'name', 'C', 130, 0 }, ;
    { 'name_schet', 'C', 130, 0 }, ;
    { 'adres', 'C', 110, 0 }, ;
    { 'ogrn', 'C', 15, 0 }, ;
    { 'inn', 'C', 12, 0 }, ;
    { 'kpp', 'C', 9, 0 }, ;
    { 'bank', 'C', 130, 0 }, ;
    { 'r_schet', 'C', 45, 0 }, ;
    { 'bik', 'C', 10, 0 }, ;
    { 'ruk', 'C', 20, 0 }, ;
    { 'bux', 'C', 20, 0 }, ;
    { 'k_schet', 'C', 45, 0 }, ;
    { 'ispolnit', 'C', 20, 0 }, ;
    { 'plat', 'C', 250, 0 }, ;
    { 'nschet', 'C', 20, 0 }, ;
    { 'dschet', 'C', 30, 0 }, ;
    { 'date_begin', 'C', 30, 0 }, ;
    { 'date_end', 'C', 30, 0 }, ;
    { 'date_podp', 'C', 13, 0 }, ;
    { 'susluga', 'C', 250, 0 }, ;
    { 'summa', 'N', 15, 2 } }
  dbCreate( fr_titl, adbf )
  r_use( dir_server + 'organiz', , 'ORG' )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->name := frt->name_schet := org->name
  If !Empty( org->name_schet )
    frt->name_schet := org->name_schet
  Endif
  s := AllTrim( org->adres )
  If !Empty( CharRem( '-', org->telefon ) )
    s += ' тел.' + AllTrim( org->telefon )
  Endif
  frt->adres := s
  frt->ogrn := org->ogrn
  sinn := org->inn
  skpp := ''
  If '/' $ sinn
    skpp := AfterAtNum( '/', sinn )
    sinn := BeforAtNum( '/', sinn )
  Endif
  frt->inn := sinn
  frt->kpp := skpp
  frt->bank := org->bank
  frt->r_schet := org->r_schet
  frt->bik := org->smfo
  frt->ruk := org->ruk
  frt->bux := org->bux
  frt->k_schet := org->k_schet
  frt->ispolnit := org->ispolnit
  frt->date_podp := full_date( sys_date ) + ' г.'
  s := ''
  If ( j := AScan( get_rekv_smo(), {| x| x[ 1 ] == schet_->SMO } ) ) > 0
    s := get_rekv_smo()[ j, 2 ]
    If reg == 2 .and. Int( Val( schet_->SMO ) ) == 34 // иногородние !
      reg := 3
    Endif
  Elseif schet->str_crb > 0
    If schet->komu == 3
      s := inieditspr( A__POPUPMENU, dir_server + 'komitet', schet->str_crb )
    Else
      s := inieditspr( A__POPUPMENU, dir_server + 'str_komp', schet->str_crb )
    Endif
  Endif
  frt->plat := s
  frt->nschet := schet_->nschet
  frt->dschet := date_month( schet_->dschet )

  fNameSchet := iif( reg == 1, 'SCM', 'SRM' ) + AllTrim( glob_mo[ _MO_KOD_TFOMS ] ) ;
    + iif( AllTrim( schet_->SMO ) == '34', 'T34', 'S' + AllTrim( schet_->SMO ) ) ;
    + '_' + AllTrim( schet_->nschet ) + '_' ;
    + str( Year( schet_->DSCHET ), 4 ) + StrZero( Month( schet_->DSCHET ), 2 ) + StrZero( Day( schet_->DSCHET ), 2 )

  s := 'За медицинскую помощь, оказанную '
  If !Empty( schet_->SMO )
    s += 'застрахованным лицам '
  Endif
  If !emptyany( schet_->nyear, schet_->nmonth )
    s += 'за ' + mm_month[ schet_->nmonth ] + Str( schet_->nyear, 5 ) + ' года'
    ldate := SToD( StrZero( schet_->nyear, 4 ) + StrZero( schet_->nmonth, 2 ) + '01' )
    frt->date_begin := date_month( ldate )
    frt->date_end   := date_month( EoM( ldate ) )
  Else
    s := 'За оказанную медицинскую помощь'
    fl_numeration := .t.
  Endif
  frt->susluga := s
  frt->summa := schet->summa
  org->( dbCloseArea() )
  rest_box( buf )
  //
  If reg > 1
    hGauge := gaugenew( , , { 'GR+/RB', 'BG+/RB', 'G+/RB' }, 'Составление счёта', .t. )
    gaugedisplay( hGauge )
    adbf := { { 'nomer', 'N', 4, 0 }, ;
      { 'fio', 'C', 50, 0 }, ;
      { 'pol', 'C', 10, 0 }, ;
      { 'date_r', 'C', 10, 0 }, ;
      { 'mesto_r', 'C', 100, 0 }, ;
      { 'pasport', 'C', 50, 0 }, ;
      { 'adresp', 'C', 250, 0 }, ;
      { 'adresg', 'C', 250, 0 }, ;
      { 'snils', 'C', 50, 0 }, ;
      { 'polis', 'C', 50, 0 }, ;
      { 'vid_pom', 'C', 10, 0 }, ;
      { 'diagnoz', 'C', 10, 0 }, ;
      { 'n_data', 'C', 10, 0 }, ;
      { 'k_data', 'C', 10, 0 }, ;
      { 'ob_em', 'N', 5, 0 }, ;
      { 'profil', 'C', 10, 0 }, ;
      { 'vrach', 'C', 10, 0 }, ;
      { 'cena', 'N', 12, 2 }, ;
      { 'stoim', 'N', 12, 2 }, ;
      { 'rezultat', 'C', 10, 0 } }
    dbCreate( fr_data, adbf )
    Use ( fr_data ) New Alias FRD
    Index On Str( nomer, 4 ) to ( fr_data )
    use_base( 'lusl' )
    r_use( dir_server + 'uslugi1', { dir_server + 'uslugi1', ;
      dir_server + 'uslugi1s' }, 'USL1' )
    r_use( dir_server + 'uslugi', , 'USL' )
    r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
    Set Relation To u_kod into USL
    r_use( dir_server + 'kartote_', , 'KART_' )
    r_use( dir_server + 'kartotek', , 'KART' )
    Set Relation To RecNo() into KART_
    g_use( dir_server + 'human_3', { dir_server + 'human_3', dir_server + 'human_32' }, 'HUMAN_3' )
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human', dir_server + 'humans', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_, To kod_k into KART
    Select HUMAN
    find ( Str( schet->kod, 6 ) )
    Do While human->schet == schet->kod .and. !Eof()
      fl := .t.
      fl_2 := .f.
      lal := 'human'
      If human->ishod == 88
        fl_2 := .t.
        lal += '_3'
        Select HUMAN_3
        find ( Str( human->kod, 7 ) )
      Elseif human->ishod == 89
        fl := .f. // второй случай в двойном пропускаем
      Endif
      If fl
        gaugeupdate( hGauge, ++ii / schet->kol )
        ldate1 := iif( ldate1 == nil, &lal.->k_data, Min( ldate1, &lal.->k_data ) )
        ldate2 := iif( ldate2 == nil, &lal.->k_data, Max( ldate2, &lal.->k_data ) )
        a_diag := diag_for_xml( , .t., , , .t. )
        is_zak_sl := is_zak_sl_d := is_zak_sl_v := .f.
        lst := kol_dn := mcena := 0
        lvidpom := 1
        au := {}
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , , @lst )
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If ( i := ret_vid_pom( 1, lshifr, human->k_data ) ) > 0
              lvidpom := i
            Endif
            If Left( lshifr, 5 ) == '55.1.' // дневной стационар с 1 апреля 2013 года
              kol_dn += hu->KOL_1
            Elseif eq_any( Left( lshifr, 4 ), '55.2', '55.3', '55.4' ) // старый дневной стационар
              kol_dn += hu->KOL_1
              mcena := hu->u_cena
            Elseif Left( lshifr, 2 ) == '1.'
              kol_dn += hu->KOL_1
              mcena := hu->u_cena
            Endif
            If lst == 1
              If Left( lshifr, 2 ) == '1.'
                is_zak_sl := .t.
                mcena := hu->u_cena
              Elseif Left( lshifr, 3 ) == '55.'
                If human->k_data < 0d20130401 // дневной стационар до 1 апреля 2013
                  is_zak_sl_d := .t.
                Endif
                mcena := hu->u_cena
              Elseif f_is_zak_sl_vr( lshifr ) // зак.случай в п-ке
                is_zak_sl_v := .t.
                mcena := hu->u_cena
              Endif
            Else
              j := AScan( au, {| x| x[ 1 ] == lshifr .and. x[ 2 ] == hu->date_u } )
              If j == 0
                AAdd( au, { lshifr, hu->date_u, 0, hu->u_cena } )
                j := Len( au )
              Endif
              au[ j, 3 ] += hu->kol_1
            Endif
          Endif
          Select HU
          Skip
        Enddo
        If fl_2
          kol_dn := human_3->k_data - human_3->n_data
        Elseif is_zak_sl
          kol_dn := human->k_data - human->n_data
        Elseif is_zak_sl_d
          kol_dn := human->k_data - human->n_data + 1
        Elseif is_zak_sl_v
          For j := 1 To Len( au )
            If Left( au[ j, 1 ], 2 ) == '2.'
              kol_dn += au[ j, 3 ]
            Endif
          Next
        Elseif Empty( kol_dn )
          For j := 1 To Len( au )
            kol_dn += au[ j, 3 ]
          Next
          If kol_dn > 0
            mcena := round_5( human->cena_1 / kol_dn, 2 )
            If !( Round( mcena, 2 ) == Round( au[ 1, 4 ], 2 ) )
              kol_dn := mcena := 0
            Endif
          Endif
        Endif
        Select FRD
        Append Blank
        frd->nomer := iif( fl_numeration, ii, human_->SCHET_ZAP )
        frd->fio := human->fio
        frd->pol := iif( human->pol == 'М', 'муж', 'жен' )
        frd->date_r := full_date( human->date_r )
        frd->mesto_r := kart_->mesto_r
        s :=  get_name_vid_ud( kart_->vid_ud, , ' ' )
        If !Empty( kart_->ser_ud )
          s += AllTrim( kart_->ser_ud ) + ' '
        Endif
        If !Empty( kart_->nom_ud )
          s += AllTrim( kart_->nom_ud )
        Endif
        frd->pasport := s
        frd->adresg := ret_okato_ulica( kart->adres, kart_->okatog, 0, 2 )
        If Empty( kart_->okatop )
          frd->adresp := frd->adresg
        Else
          frd->adresp := ret_okato_ulica( kart_->adresp, kart_->okatop, 0, 2 )
        Endif
        If !Empty( kart->snils )
          frd->snils := Transform( kart->SNILS, picture_pf )
        Endif
        frd->polis := AllTrim( AllTrim( human_->SPOLIS ) + ' ' + human_->NPOLIS )
        frd->vid_pom := lstr( lvidpom )
        If diagnosis_for_replacement( a_diag[ 1 ], human_->USL_OK )
          frd->diagnoz := a_diag[ 2 ]
        Else
          frd->diagnoz := a_diag[ 1 ]
        Endif
        frd->n_data := full_date( &lal.->n_data )
        frd->k_data := full_date( &lal.->k_data )
        frd->ob_em := kol_dn
        If human_->PROFIL > 0
          frd->profil := lstr( human_->PROFIL )
        Endif
        If !Empty( human_->PRVS )
          frd->vrach := put_prvs_to_reestr( human_->PRVS, schet_->nyear )
          lstr( Abs( human_->PRVS ) )
        Endif
        If fl_2
          frd->cena := frd->stoim := human_3->cena_1
          frd->rezultat := lstr( human_3->RSLT_NEW )
        Else
          frd->cena := mcena
          frd->stoim := human->cena_1
          frd->rezultat := lstr( human_->RSLT_NEW )
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    close_use_base( 'lusl' )
    usl1->( dbCloseArea() )
    usl->( dbCloseArea() )
    hu->( dbCloseArea() )
    kart_->( dbCloseArea() )
    kart->( dbCloseArea() )
    human_3->( dbCloseArea() )
    human_->( dbCloseArea() )
    human->( dbCloseArea() )
    frd->( dbCloseArea() )
    If fl_numeration .and. !emptyany( ldate1, ldate2 )
      frt->date_begin := date_month( ldate1 )
      frt->date_end   := date_month( ldate2 )
    Endif
    closegauge( hGauge )
  Endif
  frt->( dbCloseArea() )

  fNameSchet := cur_dir() + fNameSchet + '.pdf'
  Do Case
  Case reg == 1
    call_fr( 'mo_schet' )
//    print_pdf_order( fNameSchet )
  Case reg == 2
    call_fr( 'mo_reesv' )
//    print_pdf_reestr( fNameSchet )
  Case reg == 3
    call_fr( 'mo_reesi' )
  Endcase
  Select SCHET

  Return Nil