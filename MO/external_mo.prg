#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 03.02.25 в GET-е вернуть {_MO_SHORT_NAME, _MO_KOD_TFOMS} и по пробелу - очистка поля
Function f_get_mo( k, r, c, lusl, lpar )

  Static skodN := ''
  Local arr_mo3 := {}, ret, r1, r2, i, lcolor, tmp_select := Select()

  Default lpar To 1
  Private muslovie, loc_arr_MO, ppar := lpar

  If lusl != NIL
    muslovie := lusl
  Endif
  If muslovie == NIL
    If glob_task == X_PPOKOJ
      arr_mo3 := slist2arr( pp_KEM_NAPR )
    Elseif glob_task == X_OMS
      arr_mo3 := slist2arr( mem_KEM_NAPR )
    Elseif glob_task == X_263
      arr_mo3 := p_arr_stac_VO
    Endif
  Endif

  If ( r1 := r + 1 ) > Int( MaxRow() / 2 )
    r2 := r -1
    r1 := 2
  Else
    r2 := MaxRow() -2
  Endif
  Private p_mo, lmo3 := 1, pkodN := skodN, _fl_space, _fl_add_mo
  If ValType( k ) == 'C' .and. !Empty( k )
    pkodN := k
    If AScan( arr_mo3, k ) == 0
      lmo3 := 0
    Endif
  Endif
  If Empty( arr_mo3 ) .or. ppar == 2
    lmo3 := 0
  Endif
  dbCreate( cur_dir + 'tmp_mo', { ;
    { 'kodN', 'C', 6, 0 }, ;
    { 'kodF', 'C', 6, 0 }, ;
    { 'mo3', 'N', 1, 0 }, ;
    { 'name', 'C', 72, 0 } ;
    } )
  Use ( cur_dir + 'tmp_mo' ) New Alias RG
  Do While .t.
    Zap
    If lmo3 == 0
      lcolor := color5
      If ppar == 2
        Append Blank
        rg->kodN := rg->kodF := '999999'
        rg->name := '=== сторонняя МО (не в ОМС или не в Волгоградской области) ==='
      Endif
      For i := 1 To Len( glob_arr_mo )
        loc_arr_MO := glob_arr_mo[ i ]
        If iif( muslovie == NIL, .t., &muslovie ) // .and. year(sys_date) <= year(glob_arr_mo[i, _MO_DEND])
          Append Blank
          rg->kodN := glob_arr_mo[ i, _MO_KOD_TFOMS ]
          rg->kodF := glob_arr_mo[ i, _MO_KOD_FFOMS ]
          rg->name := glob_arr_mo[ i, _MO_SHORT_NAME ]
          If AScan( arr_mo3, rg->kodN ) > 0
            rg->mo3 := 1
          Endif
        Endif
      Next
    Else
      lcolor := 'N/W*, GR+/R'
      For j := 1 To Len( arr_mo3 )
        If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == arr_mo3[ j ] } ) ) > 0 // .and. Year( sys_date ) <= Year( glob_arr_mo[ i, _MO_DEND ] )
          Append Blank
          rg->kodN := glob_arr_mo[ i, _MO_KOD_TFOMS ]
          rg->kodF := glob_arr_mo[ i, _MO_KOD_FFOMS ]
          rg->name := glob_arr_mo[ i, _MO_SHORT_NAME ]
          rg->mo3 := 1
        Endif
      Next
    Endif
    Index On Upper( name ) to ( cur_dir + 'tmp_mo' )
    Go Top
    If Empty( pkodN )
      pkodN := glob_mo[ _MO_KOD_TFOMS ]
    Endif
    If !Empty( pkodN )
      Locate For kodN == pkodN
      If !Found()
        Go Top
      Endif
    Endif

    p_mo := 0
    _fl_space := .f.
    _fl_add_mo := .f.
    If alpha_browse( r1, 2, r2, 77, 'f2get_mo', lcolor, , , , , , , 'f3get_mo' )
      If _fl_space
        skodN := rg->kodN
        ret := { '', Space( 10 ) }
        Exit
      Elseif _fl_add_mo
        skodN := rg->kodN
        ret := { rg->kodN, AllTrim( rg->name ) }
        Exit
      Elseif p_mo == 0
        skodN := rg->kodN
        ret := { rg->kodN, AllTrim( rg->name ) }
        Exit
      Endif
    Elseif p_mo == 0
      Exit
    Endif
  Enddo
  rg->( dbCloseArea() )
  Select ( tmp_select )

  Return ret

// 13.10.20
Function f2get_mo( oBrow )

  Local n := 72

  oBrow:addcolumn( TBColumnNew( Center( 'Наименование МО', n ), {|| PadR( rg->name, n ) } ) )
  If ppar == 2
    status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор МО' )
    // elseif lmo3 == 0
    // status_key('^<Esc>^ - выход; ^<Enter>^ - выбор; ^<Пробел>^ - очистка'+iif(glob_task==X_263.or.muslovie!=NIL,'','; ^<F3>^ - краткий список'))
  Else
    status_key( '^<Esc>^ - выход; ^<Enter>^ - выбор; ^<Пробел>^ - очистка' + iif( glob_task == X_263 .or. muslovie != NIL, '', '; ^<F3>^ - все МО' ) )
  Endif

  Return Nil

// 13.10.20
Function f3get_mo( nkey, oBrow )

  Local ret := -1, cCode, rec
  Local aRet

  If nKey == K_F2 .and. lmo3 == 0
    If ( cCode := input_value( 18, 2, 20, 77, color1, ;
        'Введите код МО или обособленного подразделения, присвоенный ТФОМС', ;
        Space( 6 ), '999999' ) ) != Nil .and. !Empty( cCode )
      rec := rg->( RecNo() )
      Go Top
      oBrow:gotop()
      Locate For rg->kodN == cCode .or. rg->kodF == cCode
      If !Found()
        Go Top
        oBrow:gotop()
        Goto ( rec )
      Endif
      ret := 0
    Endif
  Elseif nKey == K_F3 .and. glob_task != X_263 .and. muslovie == Nil .and. ppar == 1

    aRet := viewf003()
    If ! Empty( aRet[ 1 ] )
      _fl_add_mo := .t.
      RG->( dbAppend() )  // blank
      rg->kodN := aRet[ 1 ]
      rg->name := aRet[ 2 ]
      rg->mo3 := 0
      glob_arr_mo := getmo_mo_new( '_mo_mo', .t. )
    Endif

    ret := 1
    // p_mo := 1
    // pkodN := rg->kodN
    // lmo3 := iif(lmo3 == 0, 1, 0)
    // if lmo3 == 1 .and. rg->mo3 != lmo3
    // pkodN := ''
    // endif
  Elseif nKey == K_SPACE
    _fl_space := .t.
    ret := 1
  Endif

  Return ret

// вернуть массив по МО с кодом ТФОМС cCode
Function ret_mo( cCode )

  // cCode - код МО по ТФОМС
  Local i, arr := AClone( glob_arr_mo[ 1 ] ) // возьмём первое по порядку МО

  For i := 1 To Len( arr )
    If ValType( arr[ i ] ) == 'C'
      arr[ i ] := Space( 6 ) // и очистим строковые элементы
    Endif
  Next
  If !Empty( cCode )
    If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == cCode } ) ) > 0
      arr := glob_arr_mo[ i ]
    Elseif ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_FFOMS ] == cCode } ) ) > 0
      arr := glob_arr_mo[ i ]
    Endif
  Endif

  Return arr

// 28.02.25 проверить направляющую МО по дате направления и дате окончания действия
Function verify_dend_mo( cCode, ldate, is_record )

  Static a_mo := { ;
    { 255315, { 255416 } }, ;
    { 115309, { 425301 } }, ;
    { 105301, { 185301 } }, ;
    { 155307, { 595301 } }, ;
    { 451001, { 105903, 456001 } }, ;
    { 121125, { 101902 } }, ;
    { 103001, { 103002, 103003 } }, ;
    { 251008, { 255601 } }, ;
    { 251002, { 255802 } }, ;
    { 126501, { 256501, 456501, 396501 } }, ;
    { 251003, { 254504 } }, ;
    { 165531, { 165525 } }, ;
    { 145516, { 145526 } }, ;
    { 115506, { 115510 } }, ;
    { 186002, { 126406 } }, ;
    { 125901, { 158201 } }, ;
    { 134505, { 134510 } }, ;
    { 131001, { 136003 } }, ;
    { 395301, { 395302, 395303 } }, ;
    { 175303, { 175304 } }, ;
    { 155307, { 155306 } }, ;
    { 111008, { 171002 } }, ;
    { 155601, { 155502 } }, ;
    { 175603, { 175627 } }, ;
    { 185515, { 125505 } }, ;
    { 171004, { 171006 } }, ;
    { 184603, { 184512 } }, ;
    { 114504, { 114506 } }, ;
    { 174601, { 175709 } }, ;
    { 124528, { 121018 } }, ;
    { 154602, { 154620, 154608 } }, ;
    { 101003, { 184711, 181003 } }, ;
    { 711001, { 711005 } } ;
  }
  Local i, j, fl, s := ''

  Default is_record To .f.
  cCode := ret_mo( cCode )[ _MO_KOD_TFOMS ]
  If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == cCode } ) ) > 0
    If ldate > glob_arr_mo[ i, _MO_DEND ]
      fl := .f.
      If is_record
        For j := 1 To Len( a_mo )
          If AScan( a_mo[ j, 2 ], Int( Val( cCode ) ) ) > 0
            fl := .t.
            Exit
          Endif
        Next
      Endif

      fl := .t. // пока так

      If fl
        human_->NPR_MO := lstr( a_mo[ j, 1 ] ) // перезаписываем код направляющего МО в листе учёта ОМС
      Else
        s := '<' + glob_arr_mo[ i, _MO_SHORT_NAME ] + '> закончила свою деятельность ' + date_8( glob_arr_mo[ i, _MO_DEND ] ) + 'г.'
      Endif
    Endif
  Else
    s := 'в справочнике медицинских организаций не найдена МО с кодом ' + cCode
  Endif

  Return s

// инициализация выборки нескольких МО
Function ini_ed_mo( lval )

  Local s := ''

  If Empty( lval )
    s := 'Все МО,'
  Else
    AEval( glob_arr_mo, {| x| s += iif( x[ _MO_KOD_TFOMS ] $ lval, AllTrim( x[ _MO_SHORT_NAME ] ) + ',', '' ) } )
  Endif
  s := SubStr( s, 1, Len( s ) -1 )

  Return s

// выбор нескольких МО
Function inp_bit_mo( k, r, c )

  Static arr
  Local mlen, t_mas := {}, buf := SaveScreen(), ret, i, tmp_color := SetColor(), ;
    m1var := '', s := '', r1, r2, top_bottom := ( r < MaxRow() / 2 )

  mywait()
  If arr == NIL
    arr := {}
    AEval( glob_arr_mo, {| x| AAdd( arr, x[ _MO_SHORT_NAME ] ) } )
  Endif
  AEval( glob_arr_mo, {| x| AAdd( t_mas, iif( x[ _MO_KOD_TFOMS ] $ k, ' * ', '   ' ) + x[ _MO_SHORT_NAME ] ) } )
  mlen := Len( t_mas )
  i := 1
  status_key( '^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins,+,->^ - смена выбора МО' )
  If top_bottom     // сверху вниз
    r1 := r + 1
    If ( r2 := r1 + mlen + 1 ) > MaxRow() -2
      r2 := MaxRow() -2
    Endif
  Else
    r2 := r -1
    If ( r1 := r2 - mlen -1 ) < 2
      r1 := 2
    Endif
  Endif
  If ( ret := Popup( r1, 2, r2, 77, t_mas, i, color0, .t., 'fmenu_reader', , ;
      'Выбор наиболее часто встречающихся направляющих МО', 'B/BG' ) ) > 0
    For i := 1 To mlen
      If '*' == SubStr( t_mas[ i ], 2, 1 )
        m1var += glob_arr_mo[ i, _MO_KOD_TFOMS ] + ','
      Endif
    Next
    m1var := Left( m1var, Len( m1var ) -1 )
    s := ini_ed_mo( m1var )
  Endif
  RestScreen( buf )
  SetColor( tmp_color )

  Return iif( ret == 0, NIL, { m1var, s } )
