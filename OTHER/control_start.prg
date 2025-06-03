#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 03.06.25
Function find_unfinished_reestr_sp_tk( is_oper, is_count )

  Static max_rec := 9990000 // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  Local fl := .t., s, buf := save_maxrow(), arr, rech := 0, af := {}, bSaveHandler

  Default is_oper To .t., is_count To .t.

  mywait( 'Подождите, проверяем завершенность информационного обмена реестрами СП и ТК с ТФОМС...' )

  bSaveHandler := ErrorBlock( {| x| Break( x ) } )
  Begin Sequence
    If is_count
      r_use( dir_server() + 'human', , 'HUMAN' )
      rech := LastRec()
      Use
    Endif
    r_use( dir_server() + 'mo_rees', , 'REES' )
    r_use( dir_server() + 'mo_xml', , 'MO_XML' )
    Set Relation To REESTR into REES
    Index On FNAME to ( cur_dir() + 'tmp_xml' ) For TIP_IN == _XML_FILE_SP .and. Empty( TWORK2 )
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

// 03.06.25 проверить, есть ли неотосланные просроченные листы учёта
Function find_time_limit_human_reestr_sp_tk()

  Local buf := SaveScreen(), arr[ 10, 2 ], i, mas_pmt, r, c, n, d := sys_date - 23
  Local fl := .f., bSaveHandler := ErrorBlock( {| x| Break( x ) } )

  mywait( 'Подождите, проверяем просроченные случаи (неотправленные в ТФОМС)...' )
  Begin Sequence
    dbCreate( cur_dir() + 'tmp_tl', { { 'kod_h', 'N', 8, 0 }, ;
      { 'kod_xml', 'N', 6, 0 }, ;
      { 'dni', 'N', 2, 0 } } )
    Use ( cur_dir() + 'tmp_tl' ) new
    r_use( dir_server() + 'human_', , 'HUMAN_' )
    r_use( dir_server() + 'human', , 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server() + 'mo_refr', dir_server() + 'mo_refr', 'REFR' )
    r_use( dir_server() + 'mo_xml', , 'MO_XML' )
    r_use( dir_server() + 'mo_rees', , 'REES' )
    Set Relation To KOD_XML into MO_XML
    r_use( dir_server() + 'mo_rhum', , 'RHUM' )
    Set Relation To reestr into REES
    Index On Str( reestr, 6 ) to ( cur_dir() + 'tmp_rhum' ) For OPLATA == 2 .and. d < rees->DSCHET
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
    Index On dni to ( cur_dir() + 'tmp_tl' ) unique
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
        c := Int( ( 80 - n - 3 ) / 2 )
        status_key( '^<Esc>^ выход из режима и вход в задачу  ^<Enter>^ просмотр просроченных случаев' )
        str_center( r - 1, 'Обнаружены просроченные случаи:', 'W+/N*' )
        Do While ( i := popup_prompt( r, c, i, mas_pmt ) ) > 0
          f1find_time_limit_human_reestr_sp_tk( i, arr )
        Enddo
      Endif
    Endif
  Endif
  Close databases
  RestScreen( buf )
  Return Nil

// 03.06.25
Function f1find_time_limit_human_reestr_sp_tk( i, arr )

  Local n_file := cur_dir() + 'time_lim.txt', sh := 80, HH := 60

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
  r_use( dir_server() + 'mo_otd', , 'OTD' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To otd into OTD
  Use ( cur_dir() + 'tmp_tl' ) new
  Set Relation To kod_h into HUMAN
  If i == 10
    Index On Upper( human->fio ) to ( cur_dir() + 'tmp_tl' ) For dni > arr[ 9, 1 ]
  Else
    Index On Upper( human->fio ) to ( cur_dir() + 'tmp_tl' ) For dni == arr[ i, 1 ]
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