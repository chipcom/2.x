#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 04.04.24
Function full_diagnoz_human( diag, dopDiag )

  Local sDop := AllTrim( dopDiag )

  diag := AllTrim( diag )

  If Len( sDop ) == 1 .and. ( sDop >= '0' .and. sDop <= '9' )
    diag := diag + sDop
  Endif

  Return diag

// 01.02.22
Function check_diag_pregant()

  Local fl := .f.

  fl := iif( ;
    between_diag( HUMAN->KOD_DIAG2, 'O00', 'O99' ) .or. ;
    between_diag( HUMAN->KOD_DIAG3, 'O00', 'O99' ) .or. ;
    between_diag( HUMAN->KOD_DIAG4, 'O00', 'O99' ) .or. ;
    between_diag( HUMAN->SOPUT_B1, 'O00', 'O99' ) .or. ;
    between_diag( HUMAN->SOPUT_B2, 'O00', 'O99' ) .or. ;
    between_diag( HUMAN->SOPUT_B3, 'O00', 'O99' ) .or. ;
    between_diag( HUMAN->SOPUT_B4, 'O00', 'O99' ) .or. ;
    between_diag( HUMAN->KOD_DIAG2, 'Z34', 'Z35' ) .or. ;
    between_diag( HUMAN->KOD_DIAG3, 'Z34', 'Z35' ) .or. ;
    between_diag( HUMAN->KOD_DIAG4, 'Z34', 'Z35' ) .or. ;
    between_diag( HUMAN->SOPUT_B1, 'Z34', 'Z35' ) .or. ;
    between_diag( HUMAN->SOPUT_B2, 'Z34', 'Z35' ) .or. ;
    between_diag( HUMAN->SOPUT_B3, 'Z34', 'Z35' ) .or. ;
    between_diag( HUMAN->SOPUT_B4, 'Z34', 'Z35' ), .t., .f. )

  Return fl

// 23.11.22
Function between_diag_array( sDiag, aDiag )

  Local fl := .f., i

  If ValType( aDiag ) != 'A'
    Return fl
  Endif
  For i := 1 To Len( aDiag )
    fl := between_diag( sDiag, aDiag[ i, 1 ], aDiag[ i, 2 ] )
    If fl
      Return fl
    Endif
  Next

  Return fl

// 22.11.22
Function between_diag( sDiag, bDiag, eDiag )

  Local fl := .f.
  Local l, l1, l2
  Local k, k1, k2, v, v1, v2

  sDiag := AllTrim( sDiag )
  bDiag := AllTrim( bDiag )
  eDiag := AllTrim( eDiag )
  l := SubStr( sDiag, 1, 1 )
  l1 := SubStr( bDiag, 1, 1 )
  l2 := SubStr( eDiag, 1, 1 )

  If Empty( sDiag ) .or. ! Between( l, l1, l2 )
    Return fl
  Endif

  k := RAt( '.', sDiag )
  sDiag := SubStr( sDiag, 2, k - iif( k > 0, 2, 0 ) )
  k1 := RAt( '.', bDiag )
  bDiag := SubStr( bDiag, 2 )
  k2 := RAt( '.', eDiag )
  eDiag := SubStr( eDiag, 2 )

  v := Int( Val( sDiag ) )
  v1 := Int( Val( bDiag ) )
  v2 := Int( Val( eDiag ) )
  fl := Between( v, v1, v2 )

  Return fl

// 19.05.22 проверка ввода диагноза в случае ОМС
Function val1_10diag( fl_search, fl_plus, fl_screen, ldate, lpol, lUp )

  // fl_search - искать введённый диагноз в справочнике
  // fl_plus   - допускается ли ввод первично(+)/повторно(-) в конце диагноза
  // fl_screen - выводить ли на экран наименование диагноза
  // ldate     - дата, по которой проверяется диагноз по ОМС
  // lpol      - пол для проверки допустимости ввода диагноза по полу
  Local fl := .t., mshifr, tmp_select := Select(), c_plus := ' ', i, arr, ;
    lis_talon := .f., jt, m1, s, mshifr6, fl_4
  Local isGeneralDiagnoze

  Default fl_search To .t., fl_plus To .f., fl_screen To .f., ldate To sys_date
  Default lUp To .f.

  If Type( 'is_talon' ) == 'L' .and. is_talon
    lis_talon := .t.
  Endif
  Private mvar := Upper( ReadVar() )

  isGeneralDiagnoze := ( mvar == 'MKOD_DIAG' )  // установим является ли проверяемое поле основным диагнозом

  mshifr := AllTrim( &mvar )
  If lis_talon
    arr := { 'MKOD_DIAG',;
      'MKOD_DIAG2', ;
      'MKOD_DIAG3', ;
      'MKOD_DIAG4', ;
      'MSOPUT_B1',;
      'MSOPUT_B2',;
      'MSOPUT_B3',;
      'MSOPUT_B4' }
    If ( jt := AScan( arr, mvar ) ) == 0
      lis_talon := .f.
    Endif
  Endif
  If fl_plus
    If ( c_plus := Right( mshifr, 1 ) ) $ yes_d_plus  // '+-'
      mshifr := AllTrim( Left( mshifr, Len( mshifr ) -1 ) )
    Else
      c_plus := ' '
    Endif
  Endif
  mshifr6 := PadR( mshifr, 6 )
  mshifr := PadR( mshifr, 5 )
  If Empty( mshifr )
    diag_screen( 2 )
  Elseif fl_search
    r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'DIAG' )
    mshifr := mshifr6
    find ( mshifr )
    If Found()
      fl_4 := .f.
      If !Empty( ldate ) .and. !between_date( diag->dbegin, diag->dend, ldate, , isGeneralDiagnoze )
        fl_4 := .t.  // Диагноз не входит в ОМС
      Endif
      If fl_4 .and. mem_diag4 == 2 .and. !( '.' $ mshifr ) // если шифр трехзначный
        m1 := AllTrim( mshifr ) + '.'
        // теперь проверим на наличие любого четырехзначного шифра
        find ( m1 )
        If Found()
          s := ''
          For i := 0 To 9
            find ( m1 + Str( i, 1 ) )
            If Found()
              s += AllTrim( diag->shifr ) + ','
            Endif
          Next
          s := SubStr( s, 1, Len( s ) -1 )
          &mvar := PadR( m1, 5 ) + c_plus
          fl := func_error( 4, 'Доступные шифры: ' + s )
        Endif
      Endif
      If fl .and. fl_screen .and. mem_diagno == 2
        arr := { '', '', '', '' }
        i := 1
        find ( mshifr )
        arr[ 1 ] := mshifr + ' ' + diag->name
        Skip
        Do While i < 4 .and. diag->shifr == mshifr .and. !Eof()
          arr[ ++i ] := Space( 6 ) + diag->name
          Skip
        Enddo
        s := ''
        find ( mshifr )
        If !Empty( ldate ) .and. !between_date( diag->dbegin, diag->dend, ldate, , isGeneralDiagnoze )
          s := 'Диагноз не входит в ОМС'
        Endif
        If !Empty( lpol ) .and. !Empty( diag->pol ) .and. !( diag->pol == lpol )
          If Empty( s )
            s := 'Н'
          Else
            s += ', н'
          Endif
          s += 'есовместимость диагноза по полу'
        Endif
        If !Empty( s )
          arr[ 4 ] := PadC( AllTrim( s ) + '!', 71 )
          mybell()
        Endif
        diag_screen( 1, arr, lUp )
      Endif
    Else
      If '.' $ mshifr  // если шифр четырехзначный
        m1 := BeforAtNum( '.', mshifr )
        // сначала проверим на наличие трехзначного шифра
        find ( m1 )
        If Found()
          // теперь проверим на наличие любого четырехзначного шифра
          find ( m1 + '.' )
          If Found()
            s := ''
            For i := 0 To 9
              find ( m1 + '.' + Str( i, 1 ) )
              If Found()
                s += AllTrim( diag->shifr ) + ','
              Endif
            Next
            s := SubStr( s, 1, Len( s ) -1 )
            &mvar := PadR( m1 + '.', 5 ) + c_plus
            fl := func_error( 4, 'Доступные шифры: ' + s )
          Else
            &mvar := PadR( m1, 5 ) + c_plus
            fl := func_error( 4, 'Данный диагноз присутствует только в виде ТРЕХзначного шифра!' )
          Endif
        Endif
      Endif
      If fl
        &mvar := Space( if( fl_plus, 6, 5 ) )
        fl := func_error( 4, 'Диагноз с таким шифром не найден!' )
      Endif
    Endif
    diag->( dbCloseArea() )
    If tmp_select > 0
      Select ( tmp_select )
    Endif
  Endif
  If fl
    If Right( mshifr6, 1 ) != ' '
      &mvar := mshifr6
    Else
      &mvar := PadR( mshifr, 5 ) + c_plus
    Endif
  Endif
  If lis_talon .and. Type( 'adiag_talon' ) == 'A'
    If Empty( &mvar )  // если пустой диагноз -> обнуляем добавки к нему
      For i := jt * 2 -1 To jt * 2
        adiag_talon[ i ] := 0
      Next
    Endif
    put_dop_diag()
  Endif

  Return fl

// упрощённая проверка ввода диагноза
Function val2_10diag()

  Local fl := .t., mshifr, tmp_select := Select()

  Private mvar := Upper( ReadVar() )

  mshifr := AllTrim( &mvar )
  mshifr := PadR( AllTrim( &mvar ), 5 )
  If !Empty( mshifr )
    r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'DIAG' )
    find ( mshifr )
    fl := Found()
    diag->( dbCloseArea() )
    If tmp_select > 0
      Select ( tmp_select )
    Endif
    If !fl
      func_error( 4, 'Диагноз не соответствует МКБ-10' )
    Endif
  Endif

  Return fl

// запрос на ввод диагноза
Function input_10diag()

  Static sshifr := '     '
  Local buf := box_shadow( 18, 20, 20, 59, color8 ), bg := {| o, k| get_mkb10( o, k ) }

  Private mshifr := sshifr, ashifr := {}, fl_F3 := .f.

  @ 19, 26 Say 'Введите шифр заболевания' Color color1 ;
    Get mshifr Picture '@K@!' ;
    reader {| o| mygetreader( o, bg ) } ;
    Valid val1_10diag( .f. ) Color color1
  status_key( '^<Esc>^ - отказ от ввода;  ^<Enter>^ - подтверждение ввода;  ^<F3>^ - выбор из списка' )
  Set Key K_F3 To f1input_10diag()
  myread( { 'confirm' } )
  Set Key K_F3 To
  If fl_F3
    sshifr := mshifr
  Elseif LastKey() != K_ESC .and. !Empty( mshifr )
    r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'DIAG' )
    find ( mshifr )
    If Found()
      sshifr := mshifr
      ashifr := f2input_10diag()
    Else
      mshifr := ''
      func_error( 4, 'Диагноз с таким шифром не найден!' )
    Endif
    Use
  Endif
  rest_box( buf )

  Return { mshifr, ashifr }

//
Function f1input_10diag()

  Local buf := SaveScreen(), agets, fl := .f.

  Private pregim := 1, uregim := 1

  Set Key K_F3 To
  Save GETS To agets
  r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'DIAG' )
  If !Empty( mshifr )
    find ( AllTrim( mshifr ) )
    fl := Found()
  Endif
  If !fl
    Go Top
  Endif
  If alpha_browse( 2, 1, MaxRow() -2, 77, 'f1_10diag', color0, , , .t., , , , 'f2_10diag', , , {, , , 'N/BG,W+/N,B/BG,BG+/B' } )
    fl_F3 := .t.
    mshifr := FIELD->shifr
    ashifr := f2input_10diag()
    Keyboard Chr( K_ENTER )
  Endif
  Close databases
  RestScreen( buf )
  Restore GETS From agets
  Set Key K_F3 To f1input_10diag()

  Return Nil

//
Static Function f2input_10diag()

  Local arr_t := {}

  Do While FIELD->ks > 0
    Skip -1
  Enddo
  AAdd( arr_t, AllTrim( FIELD->name ) )
  Skip
  Do While FIELD->ks > 0
    AAdd( arr_t, AllTrim( FIELD->name ) )
    Skip
  Enddo

  Return arr_t

// меняет русские буквы на латинские при вводе диагноза
Function get_mkb10( oGet, nKey, fl_F7 )

  Local cKey, arr, i, mvar, mvar_old

  If nKey == K_F7 .and. fl_F7 .and. !( yes_d_plus == '+-' )
    arr := { 'MKOD_DIAG',;
      'MKOD_DIAG2', ;
      'MKOD_DIAG3', ;
      'MKOD_DIAG4', ;
      'MSOPUT_B1',;
      'MSOPUT_B2',;
      'MSOPUT_B3',;
      'MSOPUT_B4',;
      'MKOD_DIAG0' }
    mvar := ReadVar()
    If ( i := AScan( arr, {| x| x == mvar } ) ) > 1
      mvar_old := arr[ i -1 ]
      If !Empty( &mvar_old )
        Keyboard Chr( K_HOME ) + Left( &mvar_old, 5 )
      Endif
    Endif
  Elseif Between( nKey, 32, 255 )
    cKey := Chr( nKey )
    // //////////// найти ЛАТ букву, стоящую на клавиатуре там же, где и РУС
    If oGet:pos < 4  // курсор в начале
      cKey := kb_rus_lat( ckey )  // если русская буква
    Endif
    If cKey == ','
      cKey := '.' // замениь запятую на точку (цифровая клавиатура под Windows)
    Endif
    If oGet:pos > 3 .and. ( cKey == 'Ю' .or. cKey == 'ю' )
      cKey := '.' // замениь букву 'Ю' на точку (цифровая клавиатура под Windows)
    Endif
    // ////////////
    If ( Set( _SET_INSERT ) )
      oGet:insert( cKey )
    Else
      oGet:overstrike( cKey )
    Endif
    If ( oGet:typeOut )
      If ( Set( _SET_BELL ) )
        ?? Chr( 7 )
      Endif
      If ( ! Set( _SET_CONFIRM ) )
        oGet:exitState := GE_ENTER
      Endif
    Endif
  Endif

  Return Nil

// в поле 'диагноз' включить курсор
Function when_diag()

  SetCursor()

  Return .t.

// 25.03.23
Function fill_array_diagnoze( al )

  Local aDiagnoze, tmpSelect

  Default al      To 'human'  // alias БД листов учета
  If Empty( al )
    ad := { MKOD_DIAG, ;
      MKOD_DIAG2, ;
      MKOD_DIAG3, ;
      MKOD_DIAG4, ;
      MSOPUT_B1, ;
      MSOPUT_B2, ;
      MSOPUT_B3, ;
      MSOPUT_B4, ;
      MOSL1, ;
      MOSL2, ;
      MOSL3 }
  Else
    ad := { &al.->KOD_DIAG, ;
      &al.->KOD_DIAG2, ;
      &al.->KOD_DIAG3, ;
      &al.->KOD_DIAG4, ;
      &al.->SOPUT_B1, ;
      &al.->SOPUT_B2, ;
      &al.->SOPUT_B3, ;
      &al.->SOPUT_B4 }
    AAdd( ad, human_2->OSL1 )
    AAdd( ad, human_2->OSL2 )
    AAdd( ad, human_2->OSL3 )
  Endif

  Return ad

// 31.10.22 вернуть диагнозы в массиве
Function diag_to_array( al, fl_trim, fl_dop, fl_del, fl_6, adiag_talon )

  Local ad, _arr := {}, j, k, s, lshifr, dp, dp1, _ta, tmp_select := Select()

  Default al      To 'human', ; // alias БД листов учета
  fl_trim To .f., ;     // удалять завершающие пробелы
    fl_dop  To .f., ;     // дописывать букву
    fl_del  To .t., ;     // удалять повторяющиеся диагнозы
    fl_6    To .f.        // разрешать поиск шестизначных диагнозов
  If Empty( al )
    ad := { MKOD_DIAG, ;
      MKOD_DIAG2, ;
      MKOD_DIAG3, ;
      MKOD_DIAG4, ;
      MSOPUT_B1, ;
      MSOPUT_B2, ;
      MSOPUT_B3, ;
      MSOPUT_B4 }
  Else
    ad := { &al.->KOD_DIAG, ;
      &al.->KOD_DIAG2, ;
      &al.->KOD_DIAG3, ;
      &al.->KOD_DIAG4, ;
      &al.->SOPUT_B1, ;
      &al.->SOPUT_B2, ;
      &al.->SOPUT_B3, ;
      &al.->SOPUT_B4 }
  Endif
  If fl_6
    If Select( 'MKB_10' ) == 0
      r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'MKB_10' )
    Endif
    Select MKB_10
  Endif
  For j := 1 To 8
    If iif( fl_del, !Empty( ad[ j ] ), .t. )
      lshifr := ad[ j ]
      dp := dp1 := ''
      If fl_trim
        lshifr := AllTrim( lshifr )
      Endif
      If adiag_talon != NIL
        s := adiag_talon[ j * 2 -1 ]
        If eq_any( s, 1, 2 )
          dp := iif( s == 1, '+', '-' )
        Endif
        s := adiag_talon[ j * 2 ]
        If s > 0
          dp += 'д' + lstr( s )
        Endif
      Endif
      If !Empty( al )
        k := SubStr( &al.->diag_plus, j, 1 )
        If fl_6 .and. !Empty( k )
          find ( ad[ j ] + k )
          If Found() // если нашли шестизначный шифр
            lshifr := ad[ j ] + k
          Endif
        Endif
        If fl_dop .and. !Empty( k ) .and. k $ yes_d_plus
          dp1 := k
        Endif
      Endif
      AAdd( _arr, { lshifr, dp + dp1 } )
    Endif
  Next
  _ta := {}
  If fl_del // удалим из списка повторяющиеся диагнозы
    For j := 1 To Len( _arr )
      If AScan( _ta, {| x| x == _arr[ j, 1 ] } ) == 0
        AAdd( _ta, _arr[ j, 1 ] )
      Endif
    Next
    For j := 1 To Len( _ta )
      s := ''
      For k := 1 To Len( _arr )
        If _arr[ k, 1 ] == _ta[ j ]
          s += _arr[ k, 2 ]
        Endif
      Next
      _ta[ j ] += s
    Next
  Else
    For j := 1 To Len( _arr )
      AAdd( _ta, _arr[ j, 1 ] + _arr[ j, 2 ] )
    Next
  Endif
  If tmp_select > 0
    Select ( tmp_select )
  Endif

  Return _ta
