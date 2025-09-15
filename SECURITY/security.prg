#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 22.02.19 запрос 'хитрого' пароля для доступа к операции аннулирования
Function involved_password( par, _n_reestr, smsg )

  Local fl := .f., c, c1, n := 0, n1, s, i, i_p := 0, n_reestr

  Default smsg To ''
  smsg := 'Введите пароль для ' + smsg
  If ( n := Len( smsg ) ) > 61
    smsg := PadR( smsg, 61 )
  Elseif n < 59
    smsg := Space( ( 61 -n ) / 2 ) + smsg
  Endif
  c1 := Int( ( MaxCol() -75 ) / 2 )
  n := 0
  Do While i_p < 3  // до 3х попыток
    ++i_p
    n_reestr := _n_reestr
    If ( n := input_value( MaxRow() -6, c1, MaxRow() -4, MaxCol() -c1, color1, smsg, n, '9999999999' ) ) != NIL
      If par == 1 // реестр
        s := lstr( n_reestr )
      Elseif par == 2 // РАК или РПД
        s := SubStr( n_reestr, 3 )
        s := Right( BeforAtNum( 'M', s ), 1 ) + Left( AfterAtNum( '_', s ), 7 )
      Elseif eq_any( par, 3, 4 ) // счёт
        s := iif( par == 3, '', '1' )
        n_reestr := SubStr( AllTrim( Upper( n_reestr ) ), 3 )
        For i := 1 To Len( n_reestr )
          c := SubStr( n_reestr, i, 1 )
          If Between( c, '0', '9' )
            s += c
          Elseif Between( c, 'A', 'Z' )
            s += lstr( Asc( c ) )
          Endif
        Next
      Endif
      s := CharRem( '0', s ) + lstr( _version()[ 1 ] ) + lstr( _version()[ 2 ] ) + lstr( _version()[ 3 ] * 7, 10, 0 )
      Do While Len( s ) > 7
        s := Left( s, Len( s ) -1 )
      Enddo
      n1 := Int( Val( NToC( s, 8 ) ) )
      If n == n1
        fl := .t. ; Exit
      Else
        func_error( 4, 'Пароль неверен. Нет доступа к данному режиму!' )
      Endif
    Else
      Exit
    Endif
  Enddo
  Return fl

// 11.08.24
Function edit_password()

  Local buf := save_maxrow()
  Local mas11 := {}, mpic := {,,, { 1, 0 } }, mas13 := { .f., .f., .t. }, ;
    mas12 := { { 1, PadR( ' Ф.И.О.', 20 ) }, ;
    { 2, PadR( ' Тип доступа', 13 ) }, ;
    { 3, PadR( ' Должность', 20 ) };
    }
  Local blk := {| b, ar, nDim, nElem, nKey| f1editpass( b, ar, nDim, nElem, nKey ) }
  Private menu_tip := { { 'АДМИНИСТРАТОР', 0 }, ;
    { 'ОПЕРАТОР     ', 1 }, ;
    { 'КОНТРОЛЕР    ', 3 } }
  Private c_1 := T_COL + 5, c_2

  If ! hb_user_curUser:isadmin()
    Return func_error( 4, err_admin() )
  Endif
  If !g_slock( 'edit_pass' )
    Return func_error( 4, 'В данный момент пароли редактирует другой администратор. Ждите.' )
  Endif
  mywait()
  c_2 := c_1 + 64
  // if is_task(X_KEK)
  // c_1 := 2 ; c_2 := 77
  // aadd(mas12, {4,'Группа КЭК'})
  // endif
  r_use( dir_server() + 'base1' )
  Do While !Eof()
    AAdd( mas11, { Crypt( p1, gpasskod ), ;                       // 1
      inieditspr( A__MENUVERT, menu_tip, p2 ), ;      // 2
    iif( Empty( p5 ), p5, Crypt( p5, gpasskod ) ), ;   // 3
    p6, ;                        // 4
      Crypt( p3, gpasskod ), ;        // 5
    p2, ;                        // 6
      RecNo(), ;                   // 7
      iif( Empty( p7 ), p7, Crypt( p7, gpasskod ) ), ;     // 8
    iif( Empty( p8 ), p8, Crypt( p8, gpasskod ) ), ;     // 9
    iif( Empty( inn ), inn, Crypt( inn, gpasskod ) ), ;  // 10
    IDROLE, ;                                     // 11
      iif( Empty( dov_data ), dov_data, Crypt( dov_data, gpasskod ) ), ;  // 12
    iif( Empty( dov_nom ), dov_nom, Crypt( dov_nom, gpasskod ) );   // 13
    };
      )
    Skip
  Enddo
  Close databases
  If Len( mas11 ) == 0
    AAdd( mas11, { Space( 20 ), Space( 25 ), Space( 20 ), 0, Space( 10 ), 1, 0, Space( 10 ), Space( 10 ), Space( 12 ), 0, Space( 8 ), Space( 20 ) } )
  Endif
  //
  If Len( mas11 ) > 254
    mas13[ 3 ] := .f.
  Endif
  //
  arrn_browse( T_ROW, c_1, MaxRow() -2, c_2, mas11, mas12, 1,, color5,,,,, mpic, blk, mas13 )
  Close databases
  SetColor( color0 )
  rest_box( buf )
  g_sunlock( 'edit_pass' )
  Return Nil

// 11.07.24
Static Function f1editpass( b, ar, nDim, nElem, nKey )

  Local nRow := Row(), nCol := Col(), tmp_color, buf := save_maxrow(), buf1, fl := .f., r1, r2, i, ;
    mm_gruppa := { ;
    { '0 - не работает в задаче КЭК', 0 }, ;
    { '1 - уровень зав.отделением', 1 }, ;
    { '2 - уровень зам.гл.врача', 2 }, ;
    { '3 - уровень комиссии КЭК', 3 } }
  Local obj, menu_idrole := {}

  // собирем доступные группы пользователей
  AAdd( menu_idrole, { 'Группа пользователей не выбрана', 0 } )
  For Each obj in troleuserdb():getlist()
    AAdd( menu_idrole, { obj:Name, obj:ID } )
  Next

  Keyboard ''
  If nKey == K_ENTER
    Private mfio, mdolj, mgruppa, m1gruppa := 0, mtip, m1tip, mpass, moper, ;
      mfroper, minn,  mdov_date, mdov_nomer, gl_area := { 1, 0, MaxRow() -1, 79, 0 }

    If ar[ nElem, 7 ] == 0 .and. Len( ar ) > 1
      ar[ nElem, 6 ] := 1 // по умолчанию добавляется оператор
    Endif
    mfio := PadRight( ar[ nElem, 1 ], 50 )
    mdolj := ar[ nElem, 3 ]
    m1tip := ar[ nElem, 6 ]
    mtip := inieditspr( A__MENUVERT, menu_tip, m1tip )
    mpass := ar[ nElem, 5 ]
    tmp_color := SetColor( cDataCGet )
    r1 := MaxRow() -10
    r2 := MaxRow() -3
    // if is_task(X_KEK)
    // m1gruppa := ar[nElem, 4]
    // mgruppa := inieditspr(A__MENUVERT, mm_gruppa, m1gruppa)
    // --r1
    // endif
    If is_task( X_PLATN ) .or. is_task( X_ORTO ) .or. is_task( X_KASSA )
      minn  := ar[ nElem, 10 ]
      moper := ar[ nElem, 8 ]
      --r1
      --r1
      mfroper := ar[ nElem, 9 ]
      --r1
    Endif

    m1idrole := ar[ nElem, 11 ]
    midrole := inieditspr( A__MENUVERT, menu_idrole, m1idrole )
    mdov_date  := SToD( ar[ nElem, 12 ] )
    mdov_nomer :=  ar[ nElem, 13 ]

    buf1 := box_shadow( r1, c_1 + 1, r2, c_2 -1, , iif( ar[ nElem, 7 ] == 0, 'Добавление', 'Редактирование' ), cDataPgDn )
    If is_task( X_PLATN ) .or. is_task( X_ORTO ) .or. is_task( X_KASSA )
      // @ r1 + 2, c_1 + 3 say 'Ф.И.О. пользователя' get mfio valid func_empty(mfio)
      // @ r1 + 2, c_1 + 46 say 'ИНН' get minn
      @ r1 + 1, c_1 + 3 Say 'Ф.И.О.' Get mfio Valid func_empty( mfio ) Picture '@!@S50'
      @ r1 + 2, c_1 + 3 Say 'ИНН' Get minn
    Else
      // @ r1 + 2, c_1 + 3 say 'Ф.И.О. пользователя' get mfio valid func_empty(mfio)
      @ r1 + 2, c_1 + 3 Say 'Ф.И.О.' Get mfio Valid func_empty( mfio )
    Endif
    @ r1 + 3, c_1 + 3 Say 'Должность' Get mdolj

    @ r1 + 4, c_1 + 3 Say 'Группа пользователей' Get midrole READER {| x| menu_reader( x, menu_idrole, A__MENUVERT, , , .f. ) }

    @ r1 + 5, c_1 + 3 Say 'Тип доступа' Get mtip READER {| x| menu_reader( x, menu_tip, A__MENUVERT, , , .f. ) }
    @ r1 + 6, c_1 + 3 Say 'Пароль' Get mpass Picture '@!' Valid func_empty( mpass )
    i := 6
    // if is_task(X_KEK)
    // ++i
    // @ r1 + i, c_1 + 3 say 'Группа КЭК' get mgruppa READER {|x|menu_reader(x, mm_gruppa, A__MENUVERT, , , .f.)}
    // endif
    If is_task( X_PLATN ) .or. is_task( X_ORTO ) .or. is_task( X_KASSA )
      ++i
      @ r1 + i, c_1 + 3 Say 'Пароль для фискального регистратора' Get moper Picture '@!'
      ++i
      @ r1 + i, c_1 + 3 Say 'Пароль для снятия отчета фискального регистратора' Get mfroper Picture '@!'
      ++i
      @ r1 + i, c_1 + 3 Say 'N доверен-ти' Get mdov_nomer
      @ r1 + i, c_1 + 36 Say 'Дата доверен-ти' Get mdov_date
    Endif
    status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
    myread()
    rest_box( buf )
    SetColor( tmp_color )
    If LastKey() != K_ESC .and. f_esc_enter( 1 )
      ar[ nElem, 1 ]  := mfio
      ar[ nElem, 6 ]  := m1tip
      ar[ nElem, 3 ]  := mdolj
      ar[ nElem, 4 ]  := m1gruppa
      ar[ nElem, 2 ]  := inieditspr( A__MENUVERT, menu_tip, m1tip )
      ar[ nElem, 5 ]  := mpass
      ar[ nElem, 8 ]  := moper
      ar[ nElem, 9 ]  := mfroper
      ar[ nElem, 10 ] := minn
      ar[ nElem, 11 ] := m1idrole
      ar[ nElem, 12 ] := DToS( mdov_date )
      ar[ nElem, 13 ] := mdov_nomer
      If g_use( dir_server() + 'base1', , , .t. )
        If ar[ nElem, 7 ] == 0
          g_rlock( .t., FOREVER )
          ar[ nElem, 7 ] := RecNo()
        Else
          Goto ( ar[ nElem, 7 ] )
          g_rlock( FOREVER )
        Endif
        Replace p1  With Crypt( mfio, gpasskod ), ;
          p2  With m1tip, ;
          p3  With Crypt( mpass, gpasskod ), ;
          p5  With Crypt( mdolj, gpasskod ), ;
          p6  With m1gruppa, ;
          p7  With Crypt( moper, gpasskod ), ;
          p8  With Crypt( mfroper, gpasskod ), ;
          inn With Crypt( minn, gpasskod ), ;
          IDROLE  With m1idrole, ;
          DOV_DATA  With Crypt( DToS( mdov_date ), gpasskod ), ;
          DOV_NOM   With Crypt ( mdov_nomer, gpasskod )

        b:refreshall()
        fl := .t.
      Endif
    Endif
    Close databases
    rest_box( buf1 )
    @ nRow, nCol Say ''
  Endif
  Return fl
