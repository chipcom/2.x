#include 'set.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'inkey.ch'
#include 'getexit.ch'

// 10.04.22 Реализация GetReader с помощью меню (различными способами)
Function menu_reader( get, tmp_mas, type_menu, kod_help, mcolor, fl_esc, titul, titul_color, fl_sort, nLen )

  // get       - Get-объект
  // tmp_mas   - указатель на массив
  // type_menu - тип меню
  // kod_help  - код help'а (по умолчанию -1)
  // mcolor    - цвет меню (по умолчанию 'N/BG,W+/N,,,B/W' (cDataCMenu))
  // fl_esc    - флаг выхода по ESC
  // titul     - строка заголовка меню
  // titul_color - цвет заголовка
  // fl_sort   - флаг сортировки меню
  // nLen      - длина вывода
  Local k, buf, r1, c1 := get:col, r2, c2, nr := Len( tmp_mas ), ;
    nc := 0, t_mas := {}, tk_mas := {}, flag_2 := .f., i, ;
    tmp_color := SetColor(), nc1, tmp_help, tmp_nhelp, lregim, ;
    old_value, len_var, tmp_list, old_esc, fl_valid := .t., s, tmp_mas_sort

  Private __mvar := ReadVar()
  If Empty( __mvar )  // если вызов через VGET
    __mvar := get:name
  Endif
  Private __m1var := 'M1' + SubStr( __mvar, 2 )

  Default fl_esc To .t., fl_sort To .f.
  If Type( 'kol_screen' ) == 'N' .and. kol_screen == 1
    fl_esc := .f.  // для ф-ии f_edit_spr
  Endif
  If !( Type( 'gl_area' ) == 'A' )        // на всякий случай, если не определено
    Private gl_area := { 1, 0, MaxRow() -1, MaxCol(), 0 }  // в вызывающей программе
  Endif
  If ValType( get:preBlock ) == 'B' .and. !Eval( get:preBlock, get )
    Return Nil
  Endif
  If ValType( &__mvar ) != 'C'
    &__mvar := Space( 10 ) // на всякий случай, если не определено в вызывающей ф-ии
  Endif
  get:setfocus()
  @ get:row, get:col Say Left( &__mvar, gl_area[ 4 ] - get:col ) Color AfterAtNum( ',', tmp_color, 1 )
  SetCursor( 0 )
  If fl_esc
    Set Key K_ESC To
  Endif
  tmp_help := if( Type( 'chm_help_code' ) == 'N', chm_help_code, help_code )
  tmp_nhelp := ret_nhelp_code()
  If ( k := inkeytrap( 0 ) ) == K_ENTER .or. k >= 32
    Default kod_help To -1, mcolor To 'N/BG,W+/N,,,B/W' // cDataCMenu
    chm_help_code := help_code := kod_help
    nhelp_code := kod_help
    len_var := Len( &__mvar )  // len_var := len(get:buffer)
    old_esc := Set( _SET_ESCAPE, .t. )
    Do Case
    Case eq_any( type_menu, A__MENUHORIZ, A__MENUVERT, A__MENUVERT_SPACE )
      If Len( tmp_mas ) > 0 .and. ValType( tmp_mas[ 1 ] ) == 'A'
        If fl_sort // сортировка допускается только для двумерного массива
          tmp_mas_sort := AClone( tmp_mas )
          ASort( tmp_mas_sort, , , {| x, y| Upper( x[ 1 ] ) < Upper( y[ 1 ] ) } )
          AEval( tmp_mas_sort, {| x| AAdd( t_mas, x[ 1 ] ), AAdd( tk_mas, x[ 2 ] ) } )
        Else
          AEval( tmp_mas, {| x| AAdd( t_mas, x[ 1 ] ), AAdd( tk_mas, x[ 2 ] ) } )
        Endif
        flag_2 := .t.
      Else
        t_mas := AClone( tmp_mas )
      Endif
      AEval( t_mas, {| x| nc := Max( nc, Len( x ) ) } )
      If ( nc1 := nc ) > MaxCol() -5
        nc1 := MaxCol() -5
      Endif
      If type_menu == A__MENUHORIZ
        r1 := r2 := get:row
        c2 := c1
        AEval( t_mas, {| x| c2 += Len( x ) + 2 } )
        dec( c2 )
      Else
        If get:row > Int( MaxRow() / 2 )
          r2 := get:row -1
          r1 := r2 - nr -1
        Else
          r1 := get:row + 1
          r2 := r1 + nr + 1
        Endif
        c2 := c1 + nc1 + 3
      Endif
      If c2 > MaxCol() -2
        c2 := MaxCol() -2
        c1 := MaxCol() - nc1 -5
      Endif
      If r1 < 0
        r1 := 0
      Endif
      If r2 > MaxRow() -2
        r2 := MaxRow() -2
      Endif
      buf := SaveScreen()
      SetColor( mcolor )
      If flag_2
        i := AScan( tk_mas, &__m1var )
        old_value := &__m1var
      Else
        i := AScan( t_mas, &__mvar )
        old_value := &__mvar
      Endif
      Save gets To tmp_list
      If type_menu == A__MENUHORIZ  // горизонтальное меню MENU TO
        @ r1, c1 Clear To r2, c2
        nc1 := c1 + 1
        For k := 1 To Len( t_mas )
          @ r1, nc1 Prompt t_mas[ k ]
          nc1 += Len( t_mas[ k ] ) + 2
        Next
        Menu To i
      Else                    // вертикальное меню POPUP
        If type_menu == A__MENUVERT_SPACE
          lregim := PE_SPACE
          status_key( '^<Esc>^ - отказ;  ^<Enter>^ - выбор;  ^<Пробел>^ - очистка поля' )
        Else
          lregim := NIL
          status_key( '^<Esc>^ - отказ;  ^<Enter>^ - выбор' )
        Endif
        i := Popup( r1, c1, r2, c2, t_mas, i, mcolor, .t., , lregim, titul, titul_color )
      Endif
      Restore gets From tmp_list
      SetColor( tmp_color )
      RestScreen( buf )
      If type_menu == A__MENUVERT_SPACE .and. LastKey() == K_SPACE
        If flag_2
          &__m1var := iif( ValType( old_value ) == 'N', 0, '' )
        Endif
        @ get:row, get:col Clear To get:row, get:col + len_var -1
        &__mvar := Space( 10 )
      Elseif i > 0
        If flag_2
          &__m1var := tk_mas[ i ]
        Endif
        @ get:row, get:col Clear To get:row, get:col + len_var -1
        &__mvar := Left( t_mas[ i ], gl_area[ 4 ] - get:col )
      Endif
    Case type_menu == A__MENUBIT  // вертикальное меню с битовой комбинацией
      If ValType( tmp_mas[ 1 ] ) == 'A'
        AEval( tmp_mas, {| x| AAdd( t_mas, x[ 1 ] ), AAdd( tk_mas, x[ 2 ] ) } )
        flag_2 := .t.
      Else
        t_mas := AClone( tmp_mas )
      Endif
      AEval( t_mas, {| x| nc := Max( nc, Len( x ) ) } )
      nc += 6
      If ( nc1 := nc ) > MaxCol() -7
        nc1 := MaxCol() -7
      Endif
      If get:row > Int( MaxRow() / 2 )
        r2 := get:row -1
        r1 := r2 - nr -1
      Else
        r1 := get:row + 1
        r2 := r1 + nr + 1
      Endif
      c2 := c1 + nc1 + 1
      If c2 > MaxCol() -2
        c2 := MaxCol() -2
        c1 := MaxCol() - nc1 -3
      Endif
      If r2 > MaxRow() -2
        r2 := MaxRow() -2
      Endif
      If r1 < 0
        r1 := 0
      Endif
      buf := save_box( r1, c1, r2 + 1, c2 + 2 )
      buf1 := save_maxrow()
      tmp_color := SetColor( mcolor )
      __m1var := 'M1' + SubStr( __mvar, 2 )
      old_value := k := &__m1var
      If flag_2
        AEval( tmp_mas, {| x, i| t_mas[ i ] := if( IsBit( k, x[ 2 ] ), ' * ', '   ' ) + x[ 1 ] } )
      Else
        AEval( t_mas, {| x, i| t_mas[ i ] := if( IsBit( k, i ), ' * ', '   ' ) + t_mas[ i ] } )
      Endif
      status_key( '^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins>^ - смена признака' )
      Save gets To tmp_list
      If Popup( r1, c1, r2, c2, t_mas, i, mcolor, .t., 'fmenu_reader' ) > 0
        &__m1var := 0
        For i := 1 To nr
          If '*' $ Left( t_mas[ i ], 3 )
            If flag_2
              &__m1var := SetBit( &__m1var, tk_mas[ i ] )
            Else
              &__m1var := SetBit( &__m1var, i )
            Endif
          Endif
        Next
      Endif
      Restore gets From tmp_list
      SetColor( tmp_color )
      rest_box( buf )
      rest_box( buf1 )
      If ( i := AScan( gl_arr, {| x| Upper( x[ A__NAME ] ) == Upper( SubStr( __mvar, 2 ) ) } ) ) > 0
        @ get:row, get:col Clear To get:row, get:col + len_var -1
        &__mvar := Left( Eval( gl_arr[ i, A__FIND ], &__m1var ), gl_area[ 4 ] - get:col )
      Endif
    Case eq_any( type_menu, A__POPUPBASE, A__POPUPBASE1, A__POPUPEDIT, A__POPUPMENU )
      // меню из содержимого 'простой' базы данных - POPUP_EDIT
      t_mas := AClone( tmp_mas )
      ASize( t_mas, 8 )
      // Содержимое массива t_mas:
      // t_mas[1] - имя базы данных с полями kod и name
      // t_mas[2] - сообщение об ошибке при отсутствии необходимых записей
      // t_mas[3] - блок FOR-условия для поиска в БД (если полей больше двух)
      // t_mas[4] - блок кода для записи других полей (если полей больше двух)
      // t_mas[5] - шаблон PICTURE для ввода данных в поле name
      // t_mas[6] - цвет (цифра или строка)
      // t_mas[7] - title
      // t_mas[8] - цвет title (строка)
      Default t_mas[ 6 ] To mcolor
      Default t_mas[ 7 ] To titul
      Default t_mas[ 8 ] To titul_color
      old_value := &__m1var
      If get:row > Int( MaxRow() / 2 )
        r2 := get:row -1
        r1 := r2 -10
      Else
        r1 := get:row + 1
        r2 := r1 + 12
      Endif
      If r2 > MaxRow() -2
        r2 := MaxRow() -2
      Endif
      If r1 < 0
        r1 := 0
      Endif
      Save gets To tmp_list
      Do Case
      Case type_menu == A__POPUPBASE
        i := 2
      Case type_menu == A__POPUPBASE1
        i := 2.5
      Case type_menu == A__POPUPEDIT
        i := 3
      Case type_menu == A__POPUPMENU
        i := 4
      Endcase
      k := popup_edit( t_mas[ 1 ], r1, get:col, r2, &__m1var, i, t_mas[ 6 ], , ;
        t_mas[ 2 ], t_mas[ 3 ], t_mas[ 4 ], t_mas[ 5 ], ( get:row <= Int( MaxRow() / 2 ) ), ;
        t_mas[ 7 ], t_mas[ 8 ] )
      Restore gets From tmp_list
      SetColor( tmp_color )
      If k != NIL
        &__m1var := k[ 1 ]
        @ get:row, get:col Clear To get:row, get:col + len_var -1
        &__mvar := if( !Empty( k[ 2 ] ), Left( RTrim( k[ 2 ] ), gl_area[ 4 ] - get:col ), Space( 10 ) )
      Endif
    Case type_menu == A__FUNCTION // функция общего назначения
      old_value := &__m1var
      // в массиве tmp_mas - первый элемент -> блок кода с вызовом функции,
      // в который передаются три параметра : код (m1...), row и col get'а
      Save gets To tmp_list
      k := Eval( tmp_mas[ 1 ], old_value, get:row, get:col )
      Restore gets From tmp_list
      SetColor( tmp_color )
      If k != NIL
        &__m1var := k[ 1 ]
        s := RTrim( k[ 2 ] )
        If Len( tmp_mas ) > 1 .and. ValType( tmp_mas[ 2 ] ) == 'N'
          s := PadR( s, tmp_mas[ 2 ] )
        Endif
        @ get:row, get:col Clear To get:row, get:col + len_var -1
        &__mvar := if( !Empty( s ), Left( s, gl_area[ 4 ] - get:col ), Space( 10 ) )
        If Len( tmp_mas ) > 1 .and. ValType( tmp_mas[ 2 ] ) == 'N'
          &__mvar := PadR( s, tmp_mas[ 2 ] )
        Endif
      Endif
    Endcase
    If ValType( get:postBlock ) == 'B'
      fl_valid := Eval( get:postBlock, get, old_value )
    Endif
    Set( _SET_ESCAPE, old_esc )
    get:ExitState := if( fl_valid, GE_ENTER, GE_NOEXIT )
    If eq_any( LastKey(), K_ESC, K_PGDN )
      SetLastKey( K_DOWN )
    Endif
  Else
    Do Case
    Case k == K_ESC
      get:ExitState := GE_ESCAPE
    Case k == K_DOWN .or. k == K_TAB
      If ValType( get:postBlock ) == 'B'
        fl_valid := Eval( get:postBlock, get, old_value )
      Endif
      If fl_valid
        get:ExitState := GE_DOWN
      Else
        get:ExitState := GE_NOEXIT
      Endif
    Case k == K_CTRL_W .or. k == K_PGDN .or. k == K_PGUP
      get:ExitState := GE_WRITE
    Otherwise
      get:ExitState := GE_UP
    Endcase
  Endif

  if ! HB_ISNIL( nLen ) .and. ValType( &__mvar ) == 'C'
    &__mvar := SubStr( &__mvar, 1, nLen )
  endif

  get:killfocus()
  If fl_esc
    Set Key K_ESC To f1_edit_spr
  Endif
  SetCursor()
  chm_help_code := help_code := tmp_help
  nhelp_code := tmp_nhelp

  Return Nil

//
Function fmenu_reader( nKey, i )

  Do Case
  Case nKey == K_INS
    parr[ i ] := Stuff( parr[ i ], 2, 1, if( '*' == SubStr( parr[ i ], 2, 1 ), ' ', '*' ) )
    Keyboard Chr( K_TAB )
  Case nKey == 43  // клавиша '+'
    For i := 1 To Len( parr )
      parr[ i ] := Stuff( parr[ i ], 2, 1, '*' )
    Next
  Case nKey == 45  // клавиша '-'
    For i := 1 To Len( parr )
      parr[ i ] := Stuff( parr[ i ], 2, 1, ' ' )
    Next
  Endcase

  Return 0
