// mo_adres.prg
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static skod_volg := '18400'
// УРОВЕНЬ-1 Ter (C-2) код территории
// Начало территории 18-000-000-000-1 - Наименование территорий

// УРОВЕНЬ-2 РАЙОН ИЛИ ГОРОД областного подчинения
// Kod1 2XX-000-000-1 РАЙОН 200- шапка
// KOD1 4XX-000-000-1 ГОРОД 400- шапка
// 110-170 - автономные округа
// 200     - районы
// 400     - города
// 500-550 - города федерального подчинения
// фролово           18-428-000-000-1 ниже нет
// УРОВЕНЬ-3 (если есть)
// внутри городов (обл подчинения только РАЙОНЫ)
// KOD2 -ХХХ
// первая цифра в порядке kod2-не нужна
// центральный (в-д) 18-401-395-000-1
// для Районов области - сельсоветы.
//
// 5xx - ПОДЧИНЕННЫЕ ГОРОДА (ПОСЁЛКИ)

// / инициализация всех БД адресного реестра
/*Function main()
  cls
  f_first()

  Private MtADRES, M1tADRES := space(11)  // адрес
  m1tadres := '18401395000'
  //
  adrr_index()
  @ 1,0 say oktAdRetS(m1tadres)
  //
  @ 5,5 say 'ОКАТО прописки  ' get mtadres reader ;
          {|x| menu_reader(x, {{|k,r,c| oktAdGet(k,r,c, {m1tadres,mtadres,1}) }},A__FUNCTION,,,.f.)}
  myread()

  @ 2,0 say m1tadres
  inkey(0)
  return NIL*/

// 09.03.23 переиндексировать все файлы адресного реестра ОКАТО
Function okato_index( flag )

  Local i
  Local fl_index := .f.
  local ;
    arr_f  := { '_okator', '_okatoo', '_okatos', '_okatoo8', '_okatos8' }, ;
    arr_i1 := { '_okatr', '_okato', '_okats', '_okato8', '_okats8' }, ;
    arr_i2 := { '_okatrn', '_okaton', '_okatsn', '_okaton8', '_okatsn8' }

  Default flag To .f.

  For i := 1 To Len( arr_f )
    If files_time( dir_exe() + arr_f[ i ] + sdbf(), cur_dir() + arr_i1[ i ] + sntx() ) .or. ;
        files_time( dir_exe() + arr_f[ i ] + sdbf(), cur_dir() + arr_i2[ i ] + sntx() )
      fl_index := .t.
      Exit
    Endif
  Next
  If flag .or. fl_index
    For i := 1 To Len( arr_f )
      r_use( dir_exe() + arr_f[ i ] )
      oktadindbase( arr_f[ i ] )
      Use
    Next
  Endif

  Return Nil

//
Static Function oktadindbase( k )

  k := Lower( k )
  Do Case
  Case k == '_okator'
    Index On okato to ( cur_dir() + '_okatr' ) progress
    Index On okato + Upper( SubStr( name, 1, 30 ) ) to ( cur_dir() + '_okatrn' ) progress
  Case k == '_okatoo'
    Index On okato to ( cur_dir() + '_okato' ) progress
    Index On SubStr( okato, 1, 5 ) + Upper( SubStr( name, 1, 30 ) ) to ( cur_dir() + '_okaton' ) progress
  Case k == '_okatos'
    Index On okato to ( cur_dir() + '_okats' ) progress
    Index On SubStr( okato, 1, 8 ) + Upper( SubStr( name, 1, 30 ) ) to ( cur_dir() + '_okatsn' ) progress
  Case k == '_okatoo8'
    Index On okato to ( cur_dir() + '_okato8' ) progress
    Index On SubStr( okato, 1, 5 ) + Upper( SubStr( name, 1, 30 ) ) to ( cur_dir() + '_okaton8' ) progress
  Case k == '_okatos8'
    Index On okato to ( cur_dir() + '_okats8' ) progress
    Index On SubStr( okato, 1, 8 ) + Upper( SubStr( name, 1, 30 ) ) to ( cur_dir() + '_okatsn8' ) progress
  Endcase

  Return Nil

//
Static Function oktadusebase( k, _region )

  k := Lower( k )
  If _region != Nil .and. _region == '18'
    k += '8'
  Endif
  Do Case
  Case k == '_okator'
    r_use( dir_exe() + '_okator', { cur_dir() + '_okatr', cur_dir() + '_okatrn' }, 'REGION' )
  Case k == '_okatoo'
    r_use( dir_exe() + '_okatoo', { cur_dir() + '_okato', cur_dir() + '_okaton' }, 'OBLAST' )
  Case k == '_okatos'
    r_use( dir_exe() + '_okatos', { cur_dir() + '_okats', cur_dir() + '_okatsn' }, 'SELO' )
  Case k == '_okatoo8'
    r_use( dir_exe() + '_okatoo8', { cur_dir() + '_okato8', cur_dir() + '_okaton8' }, 'OBLAST' )
  Case k == '_okatos8'
    r_use( dir_exe() + '_okatos8', { cur_dir() + '_okats8', cur_dir() + '_okatsn8' }, 'SELO' )
  Endcase

  Return Nil

// ввод адреса по ОКАТО в GET'е
Function get_okato_ulica( kod11, r, c, mas_adr )

  Local ret, buf, tmp_help := chm_help_code, tmp_keys

  Private madrs := Space( 120 ), m1adrs := Space( 11 ), madrs1 := Space( 120 ), ;
    mulicadom

  If ValType( mas_adr ) == 'A'
    m1adrs := kod11 // или mas_adr[1]
    madrs := madrs1 := mas_adr[ 2 ]
    mulicadom := mas_adr[ 3 ]
  Endif
  old_adrs1 := madrs1
  buf := SaveScreen()
  tmp_keys := my_savekey()
  chm_help_code := 1  // H_Vvod_adrs
  ret := oktadgetst( r, c )
  chm_help_code := tmp_help
  my_restkey( tmp_keys )
  RestScreen( buf )
  If ret != NIL
    AAdd( ret, mulicadom ) // добавляем в возврат третим элементом улицу и дом
  Endif

  Return ret

// 07.02.13 ф-ия get-а адреса
Static Function oktadgetst( r, c )

  Local tmp_color, ret, s

  Private r1, c1, r2, c2

  r1 := r + 1
  r2 := r1 + 7
  If r2 > MaxRow() -2
    r2 := r -1
    r1 := r2 -7
  Endif
  c1 := 2
  c2 := 77
  box_shadow( r1, c1, r2, c2, 'N+/W', 'Ввод адреса по ОКАТО', 'GR/W' )
  @ r2 -2, c1 Say '╟' + Replicate( '─', c2 - c1 -1 ) + '╢' Color 'N+/W'
  Private pr_adrs := m1adrs, ;
    mregion := Space( 63 ), m1region := Space( 11 ), ;
    moblast := Space( 50 ), m1oblast := Space( 11 ), ;
    mnas_punkt := Space( 39 ), m1nas_punkt := Space( 11 ), ;
    mstr_adrs := AllTrim( madrs )
  Private blk_s_adrs := {|| DevPos( r2 -1, c1 + 1 ), ;
    DevOut( PadC( AllTrim( mstr_adrs ), c2 - c1 -1 ), 'W+/W' ) }
  If Empty( m1adrs )
    madrs1 := Space( 120 )
  Else  // т.е. редактирование
    m1region    := Left( m1adrs, 2 )
    m1oblast    := Left( m1adrs, 5 )
    m1nas_punkt := Left( m1adrs, 11 )
  Endif
  If !Empty( m1adrs )
    oktadusebase( '_okator' )
    find ( m1region )
    mregion := PadR( region->name, 63 )
    region->( dbCloseArea() )
    //
    oktadusebase( '_okatoo' )
    find ( m1oblast )
    moblast := PadR( oblast->name, 50 )
    oblast->( dbCloseArea() )
    //
    oktadusebase( '_okatos' )
    find ( m1nas_punkt )
    mnas_punkt := PadR( selo->name, 39 )
    selo->( dbCloseArea() )
  Endif
  //
  Eval( blk_s_adrs )
  //
  tmp_color := SetColor( 'N/W, W+/N, , , B/W' )
  @ r1 + 1, c1 + 3 Say 'Регион' Get mregion ;
    reader {| x| menu_reader( x, ;
    { {| k, r, c| get_region( k, r, c ) }, 63 }, A__FUNCTION, , , .f. ) } ;
    valid {| g, o| val_adgetst( g, o, 1 ) }
  @ r1 + 2, c1 + 3 Say 'Район области/Город' Get moblast ;
    reader {| x| menu_reader( x, ;
    { {| k, r, c| get_oblast( k, r, c ) }, 50 }, A__FUNCTION, , , .f. ) } ;
    When when_adgetst( 2 ) ;
    valid {| g, o| val_adgetst( g, o, 2 ) }
  @ r1 + 3, c1 + 3 Say 'Населенный пункт/район города' Get mnas_punkt ;
    reader {| x| menu_reader( x, ;
    { {| k, r, c| get_nas_punkt( k, r, c ) }, 39 }, A__FUNCTION, , , .f. ) } ;
    When when_adgetst( 3 ) ;
    valid {| g, o| val_adgetst( g, o, 3 ) }
  s := '^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода адреса'
  If mulicadom != NIL
    @ r1 + 4, c1 + 3 Say 'Улица, дом, квартира' Get mulicadom ;
      When when_adgetst( 3 ) ;
      valid {| g| val_adgetst( g, , 4 ) }
    Set Key K_F3 To v_vvod_adres
    s += ';  ^<F3>^ - выбор улицы'
  Endif
  status_key( s )
  myread()
  If mulicadom != NIL
    Set Key K_F3 To
  Endif
  If LastKey() != K_ESC
    ret := { PadR( AllTrim( pr_adrs ), 11, '0' ), mstr_adrs }
  Endif
  SetColor( tmp_color )

  Return ret

// 31.05.15
Static Function get_region( k, r, c )

  Local ret, t_arr[ BR_LEN ], fl := .f.

  Private muslovie := '.t.', str_find := ''

  If r <= MaxRow() / 2
    t_arr[ BR_TOP ] := r
    t_arr[ BR_BOTTOM ] := MaxRow() -2
  Else
    t_arr[ BR_TOP ] := 2
    t_arr[ BR_BOTTOM ] := r -1
  Endif
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := 'Выбор региона РФ'
  t_arr[ BR_TITUL_COLOR ] := 'BG+/GR'
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B', .f., 72 }
  t_arr[ BR_COLUMN ] := { { Center( 'Наименование', 72 ), {|| ( region->okato + ' ' + region->name ) } } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_adrs( nk, ob, 1, 'region', 1 ) }
  t_arr[ BR_ENTER ] := {|| ret := { region->okato, region->name } }
  //
  oktadusebase( '_okator' )
  If Empty( m1region )
    find ( '18' )
  Else
    find ( m1region )
  Endif
  fl := Found()
  Set Order To 2
  If !fl
    Go Top
  Endif
  edit_browse( t_arr )
  region->( dbCloseArea() )

  Return ret

// 05.06.15
Static Function get_oblast( k, r, c )

  Local ret, t_arr[ BR_LEN ], fl := .f., blk

  Private muslovie := 'substr(oblast->okato, 1, 2) == m1region', ;
    str_find := m1region, vozvr

  If r <= MaxRow() / 2
    t_arr[ BR_TOP ] := r
    t_arr[ BR_BOTTOM ] := MaxRow() -2
  Else
    t_arr[ BR_TOP ] := 2
    t_arr[ BR_BOTTOM ] := r -1
  Endif
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := 'Выбор района области/города'
  t_arr[ BR_TITUL_COLOR ] := 'BG+/GR'
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, GR+/BG, GR+/N', .t., 60 }
  t_arr[ BR_ARR_BLOCK ] := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find ) }, ;
    {| _n| skippointer( _n, muslovie ) }, ;
    str_find, muslovie ;
    }
  blk := {|| if( oblast->fl_zagol == 1, { 3, 4 }, { 1, 2 } ) }
  t_arr[ BR_COLUMN ] := { { Center( 'Наименование', 60 ), {|| oblast->name }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_adrs( nk, ob, 1, 'OBLAST', 2 ) }
  t_arr[ BR_ENTER ] := {|| ret := { oblast->okato, oblast->name } }
  //
  oktadusebase( '_okatoo', m1region )
  If Empty( m1oblast )
    If !Empty( okato_umolch ) .and. m1region == Left( okato_umolch, 2 )
      find ( Left( okato_umolch, 5 ) )
      fl := Found()
    Endif
  Else
    find ( m1oblast )
    fl := Found()
  Endif
  Set Order To 2
  If !fl
    find ( str_find )
    If !Found()
      fl_find := func_error( 4, 'Не найдено областей/городов для данного региона!' )
      Keyboard Chr( K_ESC )
    Endif
  Endif
  edit_browse( t_arr )
  ret := vozvr
  oblast->( dbCloseArea() )

  Return ret

//
Static Function get_nas_punkt( k, r, c )

  Local ret, t_arr[ BR_LEN ], fl := .f.

  Private muslovie := 'substr(selo->okato, 1, 5) == m1oblast', ;
    str_find := m1oblast

  If r <= MaxRow() / 2
    t_arr[ BR_TOP ] := r
    t_arr[ BR_BOTTOM ] := MaxRow() -2
  Else
    t_arr[ BR_TOP ] := 2
    t_arr[ BR_BOTTOM ] := r -1
  Endif
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := 'Выбор населенного пункта [' + AllTrim( moblast ) + ']'
  t_arr[ BR_TITUL_COLOR ] := 'BG+/GR'
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, GR+/BG, GR+/N', .t., 60 }
  t_arr[ BR_ARR_BLOCK ] := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find ) }, ;
    {| _n| skippointer( _n, muslovie ) }, ;
    str_find, muslovie ;
    }
  blk := {|| if( selo->fl_zagol == 1, { 3, 4 }, { 1, 2 } ) }
  t_arr[ BR_COLUMN ] := { { Center( 'Наименование', 60 ), {|| selo->name }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_adrs( nk, ob, 1, 'SELO', 3 ) }
  t_arr[ BR_ENTER ] := {|| ret := { selo->okato, selo->name } }
  //
  oktadusebase( '_okatos', m1region )
  If !Empty( m1nas_punkt )
    find ( m1nas_punkt )
    fl := Found()
  Endif
  Set Order To 2
  If !fl
    find ( str_find )
    If !Found()
      fl_find := func_error( 4, 'Не найдено населенных пунктов для данного района!' )
      Keyboard Chr( K_ESC )
    Endif
  Endif
  edit_browse( t_arr )
  selo->( dbCloseArea() )

  Return ret

//
Static Function f2_adrs( nk, ob, regim, lalias, regim1 )

  Local ret := -1, tmp_color, i, j, lf, s, rec

  If nk == K_F2
    If ( ret := f_poisk_adrs( @rec, ob, regim, lalias ) ) == 0
      ob:gotop()
      Goto ( rec )
    Endif
  Elseif nk == K_ENTER
    if &lalias.->fl_zagol == 1
      // невыбираемая
    Else
      If regim1 == 2
        vozvr := { oblast->okato, oblast->name }
      Elseif regim1 == 3
        vozvr := { selo->okato, selo->name }
      Endif
      ret := 1
    Endif
  Endif

  Return ret

//
Static Function f_poisk_adrs( ret_rec, obrow, regim, lalias )

  Static stmp1 := '', stmp2 := ''
  Local rec1 := RecNo(), buf := SaveScreen(), tmp_color, ret := -1, j, ;
    r1 := pr2 -6, r2 := pr2 -1

  box_shadow( r1, pc1 + 1, r2, pc2 -1, cDataPgDn, 'Поиск по ключу', cDataCSay )
  tmp_color := SetColor( cDataCGet )
  @ r1 + 2, pc1 + 2 Say Center( 'Введите ключевое слово', pc2 - pc1 -3 )
  Do While .t.
    SetColor( cDataCGet )
    If regim == 1
      tmp := PadR( stmp1, pc2 - pc1 -3 )
    Else
      tmp := PadR( stmp2, pc2 - pc1 -3 )
    Endif
    status_key( '^<Esc>^ - отказ от ввода' )
    @ r1 + 3, pc1 + 2 Get tmp Picture '@K@!'
    myread()
    SetColor( color0 )
    If LastKey() == K_ESC .or. Empty( tmp )
      Goto ( rec1 )
    Else
      mywait()
      tmp := AllTrim( tmp )
      If regim == 1
        stmp1 := tmp
      Else
        stmp2 := tmp
      Endif
      Private tmp_mas := {}, tmp_kod := {}, i := 0, t_len, ;
        k1 := pr1 + 3, k2 := pr2 -1
      oBrow:gotop()
      Do while &muslovie .and. !Eof()
        If tmp $ Upper( &lalias.->name )
          ++i
          AAdd( tmp_mas, &lalias.->name )
          AAdd( tmp_kod, RecNo() )
        Endif
        Skip
      Enddo
      If ( t_len := Len( tmp_kod ) ) == 0
        func_error( 3, 'Неудачный поиск!' )
        Loop
      Else
        box_shadow( pr1, pc1, pr2, pc2 )
        SetColor( 'B/BG' )
        @ pr1 + 1, pc1 + 2 Say 'Ключ: ' + tmp
        SetColor( color0 )
        If t_len < pr2 - pr1 -5
          k2 := k1 + t_len + 2
        Endif
        @ k1, pc1 + 1 Say PadC( 'Найденное количество - ' + lstr( i ), pc2 - pc1 -1 )
        status_key( '^<Esc>^ - отказ от выбора' )
        If ( i := Popup( k1 + 1, pc1 + 1, k2, pc2 -1, tmp_mas, 1, 0 ) ) > 0
          ret_rec := tmp_kod[ i ]
          ret := 0
        Endif
      Endif
    Endif
    Exit
  Enddo
  Goto ( rec1 )
  RestScreen( buf )
  SetColor( tmp_color )

  Return ret

//
Static Function when_adgetst( regim )

  Local ret := .t., len_okato := Len( AllTrim( pr_adrs ) )

  If regim == 2 .and. len_okato < 2 // районы
    ret := func_error( 3, 'Не выбран РЕГИОН!' )
  Elseif regim == 3 .and. len_okato < 5 // нас.пункт (улица)
    ret := func_error( 3, 'Не выбран РАЙОН области или ГОРОД!' )
  Endif

  Return ret

//
Static Function val_adgetst( get, old, regim )

  If regim < 4 .and. old == NIL
    Return .t.
  Endif
  Do Case
  Case regim == 1  // районы
    If !( m1region == old ) // .and. m1region > 0
      pr_adrs := PadR( m1region, 11, '0' )
      mstr_adrs := ret_okato_ulica( mulicadom, pr_adrs )
      m1oblast := m1nas_punkt := Space( 11 )
      moblast := Space( 50 )
      mnas_punkt := Space( 39 )
    Endif
  Case regim == 2  // районы
    If !( m1oblast == old )
      pr_adrs := PadR( m1oblast, 11, '0' )
      mstr_adrs := ret_okato_ulica( mulicadom, pr_adrs )
      m1nas_punkt := Space( 11 )
      mnas_punkt := Space( 39 )
    Endif
  Case regim == 3  // поселки
    If !( m1nas_punkt == old )
      pr_adrs := PadR( m1nas_punkt, 11, '0' )
      mstr_adrs := ret_okato_ulica( mulicadom, pr_adrs )
    Endif
  Case regim == 4  // улица
    If !( mulicadom == get:original )
      mstr_adrs := ret_okato_ulica( mulicadom, pr_adrs )
    Endif
  Endcase
  Eval( blk_s_adrs )

  Return update_gets()

// 16.11.23 вернуть адрес в строке
Static Function oktadrets( kod11, is_region, open_base )

  // is_region = 0 - не выводить нашу область
  // is_region = 1 - не выводить нашу область для Волгограда
  // is_region = 2 - выводить область
  // is_region = 3 - выводить область с сокращенным наименованием
  Local lregion, lnas_punkt, loblast, tmp_select := Select()

  Default is_region To 0, open_base To .t.
  //
  If open_base
    oktadusebase( '_okator' )
  Else
    Select REGION
  Endif
  find ( Left( kod11, 2 ) )
  lregion := region->name
  If open_base
    region->( dbCloseArea() )
    oktadusebase( '_okatoo' )
  Else
    Select OBLAST
  Endif
  find ( Left( kod11, 5 ) )
  loblast := oblast->name
  If open_base
    oblast->( dbCloseArea() )
    oktadusebase( '_okatos' )
  Else
    Select SELO
  Endif
  find ( kod11 )
  lnas_punkt := selo->name
  If open_base
    selo->( dbCloseArea() )
  Endif
  If Left( kod11, 2 ) == '18' .and. is_region == 0
    lregion := '' // не выводим наименование Волгоградской области
  Elseif Left( kod11, 2 ) == '18' .and. is_region == 3
    If Left( kod11, 5 ) == '18401'
      lregion := '' // для Волгограда не выводим наименование области
    Else
      lregion := "Волгогр. обл." // выводить область с сокращенным наименованием, а для Волгограда - не выводим
    Endif
  Elseif Left( kod11, 5 ) == '18401' .and. is_region == 1
    lregion := '' // для Волгограда не выводим наименование области
  Endif
  Select ( tmp_select )

  Return AllTrim( RTrim( lregion ) + ' ' + RTrim( loblast ) + ' ' + lnas_punkt )

// 11.03.15 вернуть адрес вместе с улицей
Function ret_okato_ulica( _adres, _okato, _region, _par )

  Local s

  Default _par To 1
  _adres := AllTrim( CharOne( ' ', _adres ) )
  If _par == 1 // сначала улица
    s := iif( Empty( _adres ), '', _adres + ' / ' ) + oktadrets( _okato, _region )
  Else // в конце улица
    s := oktadrets( _okato, _region ) + iif( Empty( _adres ), '', ' ' + _adres )
  Endif

  Return iif( Empty( s ), Space( 10 ), s )

// вернуть адрес в массиве
Function ret_okato_array( kod11, open_base )

  Local arr_okato := { '', '', '', '' }

  Default open_base To .t.
  //
  If open_base
    oktadusebase( '_okator' )
  Else
    Select REGION
  Endif
  find ( Left( kod11, 2 ) )
  arr_okato[ 1 ] := AllTrim( region->name )
  If Left( kod11, 2 ) == '40'
    arr_okato[ 1 ] := 'г.Санкт-Петербург'
  Elseif Left( kod11, 2 ) == '45'
    arr_okato[ 1 ] := 'г.Москва'
  Elseif Left( kod11, 2 ) == '67'
    arr_okato[ 1 ] := 'г.Севастополь'
  Endif
  //
  If open_base
    region->( dbCloseArea() )
    oktadusebase( '_okatoo' )
  Else
    Select OBLAST
  Endif
  find ( Left( kod11, 5 ) )
  If oblast->tip == 3 // города
    arr_okato[ 3 ] := AllTrim( oblast->name )
  Elseif oblast->tip == 4 // федеральные города
    arr_okato[ 3 ] := AllTrim( oblast->name )
  Else
    arr_okato[ 2 ] := AllTrim( oblast->name )
  Endif
  If open_base
    oblast->( dbCloseArea() )
  Endif
  //
  If !( Left( kod11, 6 ) == '184013' ) // ни один из районов Волгограда
    If open_base
      oktadusebase( '_okatos' )
    Else
      Select SELO
    Endif
    find ( kod11 )
    If Found()
      arr_okato[ 4 ] := AllTrim( selo->name )
    Endif
    If open_base
      selo->( dbCloseArea() )
    Endif
  Endif
  //
  Return arr_okato
