#include 'set.ch'
#include 'hbhash.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 11.12.25
function checking_full_diagnoses_verify( alias, dk, aDiag, ta )

  local mshifr, m1, s, i, j

  if ! ( HB_ISNIL( aDiag ) .or. Len( aDiag ) == 0 )
    for j := 1 to Len( aDiag )
      s := ''
      mshifr := AllTrim( aDiag[ j ] )
      If ! ( '.' $ mshifr ) // если шифр трехзначный
        m1 := AllTrim( mshifr ) + '.'
        // теперь проверим на наличие любого четырехзначного шифра
        ( alias )->( dbSeek( m1 ) ) //  find ( m1 )
        If ( alias )->( Found() )
          For i := 0 To 9
            ( alias )->( dbSeek( m1 + Str( i, 1 ) ) ) //  find ( m1 + Str( i, 1 ) )
            If ( alias )->( Found() )
              if valid_date( dk, ( alias )->dBegin, ( alias )->dEnd )
                s += AllTrim( ( alias )->shifr ) + ','
              endif
            Endif
          Next i
          s := SubStr( s, 1, Len( s ) -1 )
        Endif
      Endif
      if !Empty( s )
        AAdd( ta, 'Не допустимый шифр диагноза: ' + aDiag[ j ] )
        AAdd( ta, '  доступные шифры: ' + s )
      endif
    next j
  endif
  
  return nil

// 09.12.25
Function fill_array_diagnoze( al )

  Local ad

  Default al To 'human'  // alias БД листов учета
  If Empty( al )
    ad := { ;
      MKOD_DIAG, ;
      MKOD_DIAG2, ;
      MKOD_DIAG3, ;
      MKOD_DIAG4, ;
      MSOPUT_B1, ;
      MSOPUT_B2, ;
      MSOPUT_B3, ;
      MSOPUT_B4, ;
      MOSL1, ;
      MOSL2, ;
      MOSL3 ;
    }
  Else
    ad := { ;
      &al.->KOD_DIAG, ;
      &al.->KOD_DIAG2, ;
      &al.->KOD_DIAG3, ;
      &al.->KOD_DIAG4, ;
      &al.->SOPUT_B1, ;
      &al.->SOPUT_B2, ;
      &al.->SOPUT_B3, ;
      &al.->SOPUT_B4 ;
    }
    AAdd( ad, human_2->OSL1 )
    AAdd( ad, human_2->OSL2 )
    AAdd( ad, human_2->OSL3 )
  Endif

  Return ad

// 09.12.25 вернуть диагнозы в массиве
Function diag_to_array( al, fl_trim, fl_dop, fl_del, fl_6, adiag_talon )

  Local ad, _arr := {}, j, k, s, lshifr, dp, dp1, _ta, tmp_select := Select()

  Default al To 'human', ; // alias БД листов учета
    fl_trim To .f., ;     // удалять завершающие пробелы
    fl_dop  To .f., ;     // дописывать букву
    fl_del  To .t., ;     // удалять повторяющиеся диагнозы
    fl_6    To .f.        // разрешать поиск шестизначных диагнозов
  If Empty( al )
    ad := { ;
      MKOD_DIAG, ;
      MKOD_DIAG2, ;
      MKOD_DIAG3, ;
      MKOD_DIAG4, ;
      MSOPUT_B1, ;
      MSOPUT_B2, ;
      MSOPUT_B3, ;
      MSOPUT_B4 ;
    }
  Else
    ad := { ;
      &al.->KOD_DIAG, ;
      &al.->KOD_DIAG2, ;
      &al.->KOD_DIAG3, ;
      &al.->KOD_DIAG4, ;
      &al.->SOPUT_B1, ;
      &al.->SOPUT_B2, ;
      &al.->SOPUT_B3, ;
      &al.->SOPUT_B4 ;
    }
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

// 25.03.23
Function dublicate_diagnoze( arrDiagnoze )

  Local aRet := {}
  Local i, cDiagnose
  Local aHash := hb_Hash()

  For i := 1 To Len( arrDiagnoze )
    cDiagnose := AllTrim( arrDiagnoze[ i ] )
    If Empty( cDiagnose )
      Loop
    Endif
    If ! hb_HHasKey( aHash, cDiagnose )
      hb_HSet( aHash, cDiagnose, .t. )
    Else
      AAdd( aRet, { cDiagnose, iif( i < 9, 'в группе "Сопутствующие диагнозы": ', 'в группе "Диагнозы осложнения": ' ) } )
    Endif
  Next

  Return aRet

// 10.06.26
Function full_main_diagnoz_human( diag, dopDiag )

  Local sDop := SubStr( AllTrim( dopDiag ), 1, 1 )

  diag := AllTrim( diag )

  If !Empty( sDop ) .and. ( sDop >= '0' .and. sDop <= '9' )
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
    arr := { ;
      'MKOD_DIAG', ;
      'MKOD_DIAG2', ;
      'MKOD_DIAG3', ;
      'MKOD_DIAG4', ;
      'MSOPUT_B1', ;
      'MSOPUT_B2', ;
      'MSOPUT_B3', ;
      'MSOPUT_B4' ;
    }
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

// 10.09.26 вывести наименование диагноза при вводе случая
Function diag_screen( k, arr_d, lUp )

  Static buf_d
  Local i, lc, r // := 12

  Default lUp To .f.

//  r := iif( lUp, 5, 12 )
  r := iif( lUp, 5, 13 )
  If Type( 'row_diag_screen' ) == 'N' .and. row_diag_screen > 0
    r := row_diag_screen
  Endif
  If k == 0 // обнулить буфер
    buf_d := nil
  Elseif k == 1 // если надо, отрисовать прямоугольник, и вывести диагноз
    If buf_d == nil
      buf_d := box_shadow( r, 3, r + 5, 76, 'N/RB', 'Диагноз', 'W/RB' )
    Endif
    For i := 1 To Len( arr_d )
      lc := if( 'в ОМС' $ arr_d[ i ] .or. 'по полу' $ arr_d[ i ], 'GR+/RB', 'W+/RB' )
      @ r + i, 5 Say PadR( arr_d[ i ], 71 ) Color lc
    Next
  Elseif k == 2 // восстановить экран  и обнулить буфер
    If buf_d != nil
      rest_box( buf_d )
    Endif
    buf_d := nil
  Endif
  Return .t.


// 10.09.26 вывести мигалки перед диагнозами, если введена доп.инф-ия по талону
Function put_dop_diag()

  // позиции get'ов диагнозов
  Static arc := { { 11, 25 }, { 12, 25 }, { 12, 33 }, { 12, 41 }, { 12, 49 }, { 12, 57 }, { 12, 65 }, { 12, 73 } }
  Local i, j, fl[ 8 ]

  If is_talon
    AFill( fl, .f. )
    j := 0
    For i := 1 To 16
      If i % 2 == 1
        ++j
      Endif
      If adiag_talon[ i ] > 0
        fl[ j ] := .t.
      Endif
    Next
    If !( Type( 'row_dop_diag' ) == 'N' )
      Private row_dop_diag := 0
    Endif
    For i := 1 To 8
      @ arc[ i, 1 ] + row_dop_diag, arc[ i, 2 ] -1 Say iif( fl[ i ], Chr( 16 ), ' ' ) Color color8
    Next
  Endif
  Return .t.

// сделать 'пяти или шести-значные' диагнозы
Function make_diagp( k )

  If k == 1  // сделать 'шестизначные' диагнозы
    MKOD_DIAG  := MKOD_DIAG  + SubStr( mdiag_plus, 1, 1 )
    MKOD_DIAG2 := MKOD_DIAG2 + SubStr( mdiag_plus, 2, 1 )
    MKOD_DIAG3 := MKOD_DIAG3 + SubStr( mdiag_plus, 3, 1 )
    MKOD_DIAG4 := MKOD_DIAG4 + SubStr( mdiag_plus, 4, 1 )
    MSOPUT_B1  := MSOPUT_B1  + SubStr( mdiag_plus, 5, 1 )
    MSOPUT_B2  := MSOPUT_B2  + SubStr( mdiag_plus, 6, 1 )
    MSOPUT_B3  := MSOPUT_B3  + SubStr( mdiag_plus, 7, 1 )
    MSOPUT_B4  := MSOPUT_B4  + SubStr( mdiag_plus, 8, 1 )
  Else       // сделать 'пятизначные' диагнозы
    mdiag_plus := Right( MKOD_DIAG, 1 ) + ;
      Right( MKOD_DIAG2, 1 ) + ;
      Right( MKOD_DIAG3, 1 ) + ;
      Right( MKOD_DIAG4, 1 ) + ;
      Right( MSOPUT_B1, 1 ) + ;
      Right( MSOPUT_B2, 1 ) + ;
      Right( MSOPUT_B3, 1 ) + ;
      Right( MSOPUT_B4, 1 )
    MKOD_DIAG  := Left( MKOD_DIAG, 5 )
    MKOD_DIAG2 := Left( MKOD_DIAG2, 5 )
    MKOD_DIAG3 := Left( MKOD_DIAG3, 5 )
    MKOD_DIAG4 := Left( MKOD_DIAG4, 5 )
    MSOPUT_B1  := Left( MSOPUT_B1, 5 )
    MSOPUT_B2  := Left( MSOPUT_B2, 5 )
    MSOPUT_B3  := Left( MSOPUT_B3, 5 )
    MSOPUT_B4  := Left( MSOPUT_B4, 5 )
  Endif
  Return Nil

// 09.12.23
Function f_oms_beremenn( sdiag, dateSL )

  Static arr := { 'O10', 'O11', 'O12', 'O13', 'O14', 'O15', 'O16', ;
    'O20', 'O21', 'O22', 'O23', 'O24', 'O25', 'O26', 'O28', ;
    'O30', 'O31', 'O32', 'O33', 'O36', 'O40', 'O41', ;
    'O43', 'O44', 'O45', 'O46', 'O47', 'O98', 'O99', ;
    'Z33', 'Z34', 'Z35', 'Z36' }
  Local k := 0, j, c, s
  Local pr_ds_it
  Local ad_criteria // := getAdditionalCriteria(0d20190101)

  Default dateSL To sys_date

  pr_ds_it := 0
  If ( c := Left( sdiag, 1 ) ) == 'C'
    pr_ds_it := k := 3 // онкология
  Elseif c == 'O' .or. c == 'Z'
    If ( s := Left( sdiag, 3 ) ) == 'O04'
      k := 1 // аборт
    Elseif AScan( arr, s ) > 0
      k := 2 // беременность
    Endif
  Endif
  If pr_ds_it == 0 .and. AllTrim( sdiag ) == 'R54'
    pr_ds_it := 4
  Endif

  If eq_any( Year( dateSL ), 2018, 2019 )
    ad_criteria := getadditionalcriteria( dateSL )
    If pr_ds_it == 0 .and. ( j := AScan( ad_criteria, {| x| x[ 1 ] == PadR( sdiag, 5 ) } ) ) > 0
      pr_ds_it := ad_criteria[ j, 2 ]
    Endif
  Endif

  If eq_any( k, 1, 2 ) .and. Type( 'm1USL_OK' ) == 'N' .and. m1USL_OK == USL_OK_AMBULANCE // СМП
    k := 0
  Endif
  Return k

// 27.05.23
Function f_valid_beremenn( sdiag, dateSL )

  Local k

  Default dateSL To sys_date
  If ( ibrm := f_oms_beremenn( sdiag, dateSL ) ) > 0
    SetPos( rdiag, 26 )
    mm_prer_b := iif( ibrm == 1, mm1prer_b, iif( ibrm == 2, mm2prer_b, mm3prer_b ) )
    If ibrm == 1
      DispOut( 'прерывание беременности', cDataCGet )
      If !Between( m1prer_b, 0, 2 )
        m1prer_b := 0
      Endif
    Elseif ibrm == 2
      DispOut( 'дисп.набл.за беременной', cDataCGet )
      If !Between( m1prer_b, 0, 1 )
        m1prer_b := 0
      Endif
    Elseif ibrm == 3
      DispOut( '     боли при онкологии', cDataCGet )
      k := iif( Year( mk_data ) > 2018, 4, 1 )
      If !Between( m1prer_b, 0, k )
        m1prer_b := 0
      Endif
    Endif
    If ibrm == 1 .and. m1prer_b == 0
      mprer_b := Space( 28 )
    Else
      mprer_b := inieditspr( A__MENUVERT, mm_prer_b, m1prer_b )
    Endif
  Else
    m1prer_b := 0
    mprer_b := Space( 28 )
  Endif
  Return update_get( 'mprer_b' )
