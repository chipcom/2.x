#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

//
Function func_valid_ismo( get, lkomu, sh, name_var )

  Local r1, r2, n := 4, buf, tmp_keys, tmp_list, tmp_color

  Default name_var To 'company'
  Private mvar := 'm1' + name_var
  If lkomu == 0 .and. &mvar == 34
    If get:Row() > 18
      r2 := get:Row() -1
      r1 := r2 - n
    Else
      r1 := get:Row() + 1
      r2 := r1 + n
    Endif
    buf := SaveScreen()
    change_attr()
    tmp_keys := my_savekey()
    Save gets To tmp_list
    Private mm_ismo := {}
    box_shadow( r1, 2, r2, 77, 'N+/W', 'Ввод иногородней СМО', 'GR/W' )
    tmp_color := SetColor( 'N/W, W+/N, , , B/W' )
    @ r1 + 1, 4 Say 'Субъект РФ' Get mokato ;
      reader {| x| menu_reader( x, ;
      { {| k, r, c| get_srf( k, r, c ) }, 62 }, A__FUNCTION, , , .f. ) } ;
      valid {| g, o| when_ismo( g, o ) }
    @ r1 + 2, 4 Say 'СМО' Get mismo ;
      reader {| x| menu_reader( x, mm_ismo, A__MENUVERT, , , .f. ) } ;
      when {|| Len( mm_ismo ) > 0 .and. Empty( mnameismo ) } ;
      valid {|| iif( Empty( mismo ), , mnameismo := Space( 100 ) ), .t. }
    @ r1 + 3, 4 Say 'Наименование СМО' Get mnameismo Pict '@S56' ;
      When Empty( m1ismo )
    myread()
    SetColor( tmp_color )
    Restore gets From tmp_list
    my_restkey( tmp_keys )
    RestScreen( buf )
    If !emptyall( mismo, mnameismo )
      mvar := 'm' + name_var
      &mvar := PadR( iif( emptyall( mismo ), mnameismo, mismo ), sh )
    Endif
  Endif

  Return .t.

//
Function get_srf( k, r, c )

  Local ret, t_arr[ BR_LEN ], fl := .f.

  Private muslovie := '.t.', str_find := ''

  If r <= MaxRow() / 2
    t_arr[ BR_TOP ] := r
    t_arr[ BR_BOTTOM ] := MaxRow() -2
  Else
    t_arr[ BR_TOP ] := 2
    t_arr[ BR_BOTTOM ] := r - 1
  Endif
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := 'Выбор субъекта РФ (территории страхования)'
  t_arr[ BR_TITUL_COLOR ] := 'BG+/GR'
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B', .f., 72 }
  t_arr[ BR_COLUMN ] := { { 'ОКАТО', {|| tmp->okato } }, ;
    { Center( 'Наименование', 66 ), {|| Left( tmp->name, 66 ) } } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_srf( nk, ob ) }
  t_arr[ BR_ENTER ] := {|| ret := { tmp->okato, tmp->name } }
  //
  Use ( cur_dir() + 'tmp_srf' ) New Alias TMP
  Set Filter To !( okato == '18000' )
  If !Empty( k )
    Locate For okato == k
    If !Found()
      Go Top
    Endif
  Endif
  edit_browse( t_arr )
  tmp->( dbCloseArea() )
  Return ret

//
Function f2_srf( nk, ob )

  Static stmp1 := ''
  Local rec1 := RecNo(), buf := SaveScreen(), tmp_color, ret := -1, ;
    r1 := pr2 - 6, r2 := pr2 - 1, i, j, lf, s, rec

  If nk == K_F2
    box_shadow( r1, pc1 + 1, r2, pc2 - 1, cDataPgDn, 'Поиск по ключу', cDataCSay )
    tmp_color := SetColor( cDataCGet )
    @ r1 + 2, pc1 + 2 Say Center( 'Введите ключевое слово', pc2 - pc1 - 3 )
    SetColor( cDataCGet )
    tmp := PadR( stmp1, pc2 - pc1 - 3 )
    status_key( '^<Esc>^ - отказ от ввода' )
    @ r1 + 3, pc1 + 2 Get tmp Picture '@K@!'
    myread()
    SetColor( color0 )
    If LastKey() == K_ESC .or. Empty( tmp )
      Goto ( rec1 )
    Else
      tmp := AllTrim( tmp )
      stmp1 := tmp
      Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := pr1 + 3, k2 := pr2 - 1
      ob:gotop()
      Do While !Eof()
        If tmp $ Upper( tmp->name )
          AAdd( tmp_mas, tmp->name )
          AAdd( tmp_kod, RecNo() )
        Endif
        Skip
      Enddo
      If ( t_len := Len( tmp_kod ) ) == 0
        func_error( 3, 'Неудачный поиск!' )
        Goto ( rec1 )
      Else
        box_shadow( pr1, pc1, pr2, pc2 )
        SetColor( 'B/BG' )
        @ pr1 + 1, pc1 + 2 Say 'Ключ: ' + tmp
        SetColor( color0 )
        If t_len < pr2 - pr1 - 5
          k2 := k1 + t_len + 2
        Endif
        @ k1, pc1 + 1 Say PadC( 'Найденное количество - ' + lstr( t_len ), pc2 - pc1 - 1 )
        status_key( '^<Esc>^ - отказ от выбора' )
        If ( i := Popup( k1 + 1, pc1 + 1, k2, pc2 - 1, tmp_mas, 1, 0 ) ) > 0
          ob:gotop()
          Goto ( tmp_kod[ i ] )
          ret := 0
        Endif
      Endif
    Endif
  Endif

  Return ret

//
Function when_ismo( get, old )

  Local s

  If !( m1okato == old ) .and. old != NIL
    m1ismo := ''
    mismo := Space( Len( mismo ) )
  Endif
  mm_ismo := {}
  If !Empty( m1okato )
    r_use( dir_exe() + '_mo_smo', cur_dir() + '_mo_smo', 'SMO' )
    find ( m1okato )
    Do While smo->okato == m1okato .and. !Eof()
      s := AllTrim( smo->name )
      If !Empty( smo->d_end )
        s += ' (до ' + full_date( smo->d_end ) + ')'
      Endif
      AAdd( mm_ismo, { s, smo->smo } )
      Skip
    Enddo
    smo->( dbCloseArea() )
  Endif

  Return Len( mm_ismo ) > 0

