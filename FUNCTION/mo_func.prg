// различные функции общего пользования - mo_func.prg
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 21.01.25
function unique_val_in_array( arr, col )

  local i, retArr := {}, tmpArr := {}, j

  if ValType( arr ) != 'A'
    return retArr
  endif
  for i := 1 to len( arr )
    if ( j := AScan( retArr, {| x| alltrim( x[ col ] ) ==  AllTrim( arr[ i, col ] ) } ) ) == 0
      AAdd( retArr, arr[ i ] )
    endif
  next
  return retArr

// 21.08.17
Function run_my_hrb( name_hrb, name_func )

  Local x, handle, n_file := dir_exe() + name_hrb + '.hrb'

  If hb_FileExists( n_file )
    handle := hb_hrbLoad( n_file )
    x := &( name_func )   // функция из name_hrb.hrb
    hb_hrbUnload( handle )
  Else
    func_error( 4, 'Не обнаружен файл ' + n_file )
  Endif

  Return Nil

// записать объём работы операторов
Function write_work_oper( _pt, _tp, _ae, _kk, _kp, _open )

  // {"PD",      'C',   4,   0}, ; // дата ввода c4tod(pd)
  // {"PO",      'C',   1,   0}, ; // код оператора asc(po)
  // {"PT",      'C',   1,   0}, ; // код задачи
  // {"TP",      'C',   1,   0}, ; // тип (1-карточка, 2-л/у, 3-услуги)
  // {"AE",      'C',   1,   0}, ; // 1-добавление, 2-редактирование, 3-удаление
  // {"KK",      'C',   3,   0}, ; // кол-во (карточек, л/у или услуг)
  // {"KP",      'C',   3,   0};  // количество введённых полей
  Static llen := 6

  Default _kk To 1, _kp To 0, _open To .t.
  If yes_parol .and. hb_FileExists( dir_server + 'mo_opern' + sdbf ) .and. ;
      iif( _open, g_use( dir_server + 'mo_opern', dir_server + 'mo_opern', 'OP' ), .t. )
    _pt := Chr( _pt )
    _tp := Chr( _tp )
    _ae := Chr( _ae )
    find ( c4sys_date + kod_polzovat + _pt + _tp + _ae )
    If Found()
      g_rlock( forever )
      op->kk := ft_Sqzn( _kk + ft_Unsqzn( op->kk, llen ), llen )
      op->kp := ft_Sqzn( _kp + ft_Unsqzn( op->kp, llen ), llen )
    Else
      g_rlock( .t., forever )
      op->PD := c4sys_date
      op->PO := kod_polzovat
      op->pt := _pt
      op->tp := _tp
      op->ae := _ae
      op->kk := ft_Sqzn( _kk, llen )
      op->kp := ft_Sqzn( _kp, llen )
    Endif
    If _open
      op->( dbCloseArea() )
    Endif
  Endif

  Return Nil

// проверить, более одного ли слова отдельно в фамилии, имени и отчестве
Function twowordfamimot( s )

  Static arr_char := { ' ', '-', '.', "'", '"' }
  Local i, fl := .f.

  s := AllTrim( s )
  For i := 1 To Len( arr_char )
    If arr_char[ i ] $ s
      fl := .t.
      Exit
    Endif
  Next

  Return fl

// 26.08.14 вернуть иногороднюю СМО
Function ret_inogsmo_name( ltip, /*@*/rec, fl_close)

  Local s := Space( 100 ), fl := .f., tmp_select := Select()

  Default fl_close To .f.
  If Select( 'SN' ) == 0
    r_use( dir_server + iif( ltip == 1, 'mo_kismo', 'mo_hismo' ), , 'SN' )
    Index On Str( kod, 7 ) to ( cur_dir + 'tmp_ismo' )
    fl := .t.
  Endif
  Select SN
  find ( Str( iif( ltip == 1, kart->kod, human->kod ), 7 ) )
  If Found()
    s := sn->SMO_NAME
    rec := sn->( RecNo() )
  Endif
  If fl .and. fl_close
    sn->( dbCloseArea() )
  Endif
  Select ( tmp_select )

  Return s

// 22.05.15 СМО на экран (печать)
Function smo_to_screen( ltip )

  Local s := '', s1 := '', lsmo, nsmo, lokato

  lsmo := iif( ltip == 1, kart_->smo, human_->smo )
  nsmo := Int( Val( lsmo ) )
  s := inieditspr( A__MENUVERT, glob_arr_smo, nsmo )
  If Empty( s ) .or. nsmo == 34
    If nsmo == 34
      s1 := ret_inogsmo_name( ltip, , .t. )
    Else
      s1 := init_ismo( lsmo )
    Endif
    If !Empty( s1 )
      s := AllTrim( s1 )
    Endif
    lokato := iif( ltip == 1, kart_->KVARTAL_D, human_->okato )
    If !Empty( lokato )
      s += '/' + inieditspr( A__MENUVERT, glob_array_srf, lokato )
    Endif
  Endif

  Return s

// 15.10.14 проверка корректности GUID
Function valid_guid( s, par )

  // par = 1 - GUID из моей программы
  // par = 2 - GUID из чужой программы
  Local fl := .t.

  Default par To 1
  If par == 1
    If Len( CharRem( ' ', s ) ) < 36
      fl := .f.
    Else
      fl := Empty( CharRepl( '0123456789ABCDEF-', Upper( s ), Space( 17 ) ) )
    Endif
  Else // par = 2 - GUID из чужой программы
    fl := !Empty( s ) // просто проверим на пустоту
  Endif

  Return fl

// составить GUID
Function mo_guid( par1, par2 )

  // par1 - от 1 до 3
  // .XXXXX...... для par1 = 1
  // ....XXXXX... для par1 = 2
  // .......XXXXX для par1 = 3
  // .....XXXXXX. для par1 = 4
  // par2 - номер записи
  Local s, s1, s2, k, l

  s := f1createguid( 8 ) + '-' + ;
    f1createguid( 4 ) + '-' + ;
    f1createguid( 4 ) + '-' + ;
    f1createguid( 4 ) + '-'
  s1 := f1createguid( 12 )
  s2 := NToC( par2, 16 ) // номер записи -> в 16-ричное число (строку)
  l := Len( s2 ) // длина 16-ричной строки
  k := { 6, 9, 12, 11 }[ par1 ] - l + 1 // номер позиции, с которой будем замещать

  Return s + Stuff( s1, k, l, s2 )

//
Static Function f1createguid( tmpLength )

  Static strValid := '0123456789ABCDEF'
  Local tmpCounter, tmpGUID := ''

  For tmpCounter := 1 To tmpLength
    tmpGUID += SubStr( strValid, Random() % 16 + 1, 1 )
  Next

  Return tmpGUID

// 21.01.17 определить диапазоны номеров пакетов
Function f_mb_me_nsh( _nyear, /*@*/mb, /*@*/me)

  If mem_bnn13rees <= 0 .or. mem_enn13rees <= 0
    If mem_bnn_rees == 1
      mem_bnn13rees := mem_bnn_rees
    Else
      mem_bnn13rees := Int( Val( lstr( mem_bnn_rees ) + '0' ) )
    Endif
    mem_enn13rees := Int( Val( lstr( mem_enn_rees ) + '9' ) )
  Endif
  mb := mem_bnn13rees
  me := mem_enn13rees
  /*if _nyear < 2013 .and. mem_bnn_rees == 1
    mb := 100
  endif*/

  Return iif( _nyear < 2017, 3, 5 ) // начиная с 2017 года - 5 символов

// проверить, существует файл nfile, и попытаться удалить его
Function myfiledeleted( nfile )

  Static sn := 100 // делаем 100 попыток
  Local i := 0, fl := .f.

  Do While i < sn
    If hb_FileExists( nfile )
      Delete File ( nfile )
    Else
      fl := .t.
      Exit
    Endif
    ++i
  Enddo
  If !fl
    func_error( 4, 'Неудачная попытка удаления файла ' + nfile + '. Попытайтесь снова' )
  Endif

  Return fl

// 15.12.13 корректен ли период для информации "по отчётному периоду"
Function is_otch_period( arr_m )

  Local fl := .t.

  If !( arr_m[ 5 ] == BoM( arr_m[ 5 ] ) .and. arr_m[ 6 ] == EoM( arr_m[ 6 ] ) )
    fl := func_error( 4, 'Для отчётного периода необходимо выбирать кратный месяцу период!' )
  Endif

  Return fl

// попадает ли отч.период (_YEAR,_MONTH) в диапазон с _begin_date по _end_date
Function between_otch_period( _date, _YEAR, _MONTH, _begin_date, _end_date )

  Local mdate

  If emptyany( _YEAR, _MONTH )
    mdate := _date // по-старому, т.е. по дате счёта
  Else
    mdate := SToD( StrZero( _YEAR, 4 ) + StrZero( _MONTH, 2 ) + '15' )
  Endif

  Return Between( mdate, _begin_date, _end_date )

// 21.10.13 проверить перекрытие диапазонов p1-p2 с d1-d2 для стационара
Function overlap_diapazon( p1, p2, d1, d2 )

  Local fl := .f.

  If p1 == d1 .and. p2 == d2 // абсолютно одинаковые диапазоны лечения
    fl := .t.
  Elseif p1 == p2 // первое лечение в один день
    If d1 < d2    // а второе лечение более одного дня
      fl := ( d1 < p1 .and. p2 < d2 ) // первое лечение внутри второго
    Endif
  Elseif d1 == d2 // второе лечение в один день
    If p1 < p2    // а первое лечение более одного дня
      fl := ( p1 < d1 .and. d2 < p2 ) // второе лечение внутри первого
    Endif
  Elseif p1 == d1 .or. p2 == d2 // начало ИЛИ окончание лечения в один день
    fl := .t.
  Else
    If !( fl := ( ( p1 < d1 .and. d1 < p2 ) .or. ( p1 < d2 .and. d2 < p2 ) ) )
      fl := ( ( d1 < p1 .and. p1 < d2 ) .or. ( d1 < p2 .and. p2 < d2 ) )
    Endif
  Endif

  Return fl

// сделать из глобального массива укороченный (отсечь по дате действия)
Function cut_glob_array( _glob_array, _date )

  Local i, tmp_array := {}

  For i := 1 To Len( _glob_array )
    If between_date( _glob_array[ i, 3 ], _glob_array[ i, 4 ], _date )
      AAdd( tmp_array, _glob_array[ i ] )
    Endif
  Next

  Return tmp_array

// создать (name_base).DBF из глобального массива (укороченную) (отсечь по дате действия)
Function init_tmp_glob_array( name_base, _glob_array, _date, is_all )

  Local i, len1, len2, f2type, fl_is, tmp_select

  Default name_base To 'tmp_ga', is_all To .f.
  If !myfiledeleted( cur_dir + name_base + sdbf )
    Return .f.
  Endif
  tmp_select := Select()
  len1 := len2 := 0
  f2type := ValType( _glob_array[ 1, 2 ] )
  For i := 1 To Len( _glob_array )
    If iif( is_all, .t., between_date( _glob_array[ i, 3 ], _glob_array[ i, 4 ], _date ) )
      len1 := Max( len1, Len( AllTrim( _glob_array[ i, 1 ] ) ) )
      If f2type == 'N'
        len2 := Max( len2, Len( lstr( _glob_array[ i, 2 ] ) ) )
      Else
        len2 := Max( len2, Len( AllTrim( _glob_array[ i, 2 ] ) ) )
      Endif
    Endif
  Next
  dbCreate( name_base, { { 'name', 'C', len1, 0 }, ;
    { 'kod', f2type, len2, 0 }, ;
    { 'is', 'L', 1, 0 } } )
  Use ( name_base ) New Alias tmp_ga
  For i := 1 To Len( _glob_array )
    fl_is := between_date( _glob_array[ i, 3 ], _glob_array[ i, 4 ], _date )
    If iif( is_all, .t., fl_is )
      Append Blank
      Replace name With _glob_array[ i, 1 ], ;
        kod With _glob_array[ i, 2 ], ;
        is With fl_is
    Endif
  Next
  Index On Upper( name ) to ( name_base )
  tmp_ga->( dbCloseArea() )
  Select ( tmp_select )

  Return .t.

// 04.05.13 в GET'е выбрать значение из TMP_GA.DBF (глобального массива) с поиском по подстроке
Function fget_tmp_ga( k, r, c, name_base, browTitle, is_F2, sTitle )

  Local ret, fl, cRec, kolRec, nRec, len1, len2, f2type, tmp_select, blk, t_arr[ BR_LEN ]

  Default name_base To 'tmp_ga', browTitle To 'Наименование', is_F2 To .t.
  tmp_select := Select()
  Use ( name_base ) index ( name_base ) New Alias tmp_ga
  kolRec := LastRec()
  len1 := FieldLen( 1 )
  len2 := FieldLen( 2 )
  If r <= MaxRow() / 2
    t_arr[ BR_TOP ] := r + 1
    If ( t_arr[ BR_BOTTOM ] := t_arr[ BR_TOP ] + kolRec + 3 ) > MaxRow() -2
      t_arr[ BR_BOTTOM ] := MaxRow() -2
    Endif
  Else
    t_arr[ BR_BOTTOM ] := r -1
    If ( t_arr[ BR_TOP ] := t_arr[ BR_BOTTOM ] - kolRec -3 ) < 1
      t_arr[ BR_TOP ] := 1
    Endif
  Endif
  t_arr[ BR_LEFT ] := c
  If ( t_arr[ BR_RIGHT ] := c + len1 + 3 ) > 77
    t_arr[ BR_RIGHT ] := 77
    t_arr[ BR_LEFT ] := t_arr[ BR_RIGHT ] - len1 -3
    If t_arr[ BR_LEFT ] < 2
      t_arr[ BR_LEFT ] := 2
    Endif
  Endif
  len1 := t_arr[ BR_RIGHT ] - t_arr[ BR_LEFT ] -3
  blk := {|| iif( tmp_ga->is, { 1, 2 }, { 3, 4 } ) }
  t_arr[ BR_COLOR ] := color0
  If sTitle != NIL
    t_arr[ BR_TITUL ] := sTitle
    t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  Endif
  t_arr[ BR_ARR_BROWSE ] := {, , , 'N/BG,W+/N,B/BG,W+/B', .f. }
  t_arr[ BR_COLUMN ] := { { Center( browTitle, len1 ), {|| Left( tmp_ga->name, len1 ) }, blk } }
  If is_F2
    t_arr[ BR_EDIT ] := {| nk, ob| f1get_tmp_ga( nk, ob, 'edit' ) }
  Endif
  If FieldNum( 'IDUMP' ) > 0 // специально для отделений
    t_arr[ BR_ENTER ] := {|| ret := { tmp_ga->kod, AllTrim( tmp_ga->name ), tmp_ga->idump, tmp_ga->tiplu } }
  Else
    t_arr[ BR_ENTER ] := {|| ret := { tmp_ga->kod, AllTrim( tmp_ga->name ) } }
  Endif
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор' + iif( is_F2, ';  ^<F2>^ - поиск по подстроке', '' ) ) }
  f2type := FieldType( 2 )
  fl := .f.
  nRec := 0
  If k != NIL
    Go Top
    Do While !Eof()
      If f2type == 'N'
        fl := ( tmp_ga->kod == k )
      Else
        fl := ( AllTrim( tmp_ga->kod ) == AllTrim( k ) )
      Endif
      If fl
        cRec := RecNo()
        Exit
      Endif
      ++nRec
      Skip
    Enddo
  Endif
  If !fl
    nRec := 0
  Endif
  Go Top
  If nRec > 0
    If kolRec - nRec < t_arr[ BR_BOTTOM ] - t_arr[ BR_TOP ] -3 // последняя страница?
      Keyboard Chr( K_END ) + Replicate( Chr( K_UP ), kolRec - nRec -1 )
    Else
      Goto ( cRec )
    Endif
  Endif
  edit_browse( t_arr )
  tmp_ga->( dbCloseArea() )
  Select ( tmp_select )

  Return ret

// 23.01.17
Function f1get_tmp_ga( nKey, oBrow, regim, arr )

  Static tmp := ''
  Local ret := -1, buf, buf1, tmp1, rec1 := RecNo()

  If regim == 'edit' .and. nkey == K_INS .and. ValType( arr ) == 'A' .and. FieldNum( 'ISN' ) > 0
    // специально для множественного выбора из справочника новых специальностей V015
    tmp_ga->isn := iif( tmp_ga->isn == 1, 0, 1 )
    Keyboard Chr( K_TAB )
    Return 0
  Endif
  If !( regim == 'edit' .and. nKey == K_F2 )
    Return ret
  Endif
  buf := SaveScreen()
  Do While .t.
    buf1 := save_box( pr2 -3, pc1 + 1, pr2 -1, pc2 -1 )
    box_shadow( pr2 -3, pc1 + 1, pr2 -1, pc2 -1, color1, 'Введите подстроку поиска', color8 )
    tmp1 := PadR( tmp, 15 )
    status_key( '^<Esc>^ - отказ от ввода' )
    @ pr2 -2, pc1 + ( pc2 - pc1 -15 ) / 2 Get tmp1 Picture '@K@!' Color color8
    myread()
    If LastKey() == K_ESC .or. Empty( tmp1 )
      Exit
    Endif
    mywait()
    tmp := AllTrim( tmp1 )
    Private tmp_mas := {}, tmp_kod := {}, t_len, k1, k2
    i := 0
    Go Top
    Do While !Eof()
      If tmp $ Upper( tmp_ga->name )
        AAdd( tmp_mas, tmp_ga->name )
        AAdd( tmp_kod, tmp_ga->( RecNo() ) )
      Endif
      Skip
    Enddo
    rest_box( buf1 )
    If ( t_len := Len( tmp_kod ) ) = 0
      stat_msg( 'Не найдено ни одной записи, удовлетворяющей данной подстроке!' )
      mybell( 2 )
      Loop
    Elseif t_len == 1  // найдена одна строка
      Goto ( tmp_kod[ 1 ] )
      ret := 0
      Exit
    Else
      status_key( '^<Esc>^ - отказ от выбора' )
      If ( i := Popup( pr1 + 3, pc1 + 1, pr2 -1, pc2 -1, tmp_mas, 1, color1, .f., , , ;
          'Кол-во записей с "' + tmp + '" - ' + lstr( t_len ), color8 ) ) > 0
        Goto ( tmp_kod[ i ] )
        ret := 0
      Endif
      Exit
    Endif
  Enddo
  RestScreen( buf )
  If ret == -1
    Goto rec1
  Endif

  Return ret

//
Function is_up_usl( arr_usl, mkod )

  Local i := 0, tmp_select := Select()

  Select USL
  Do While .t.
    find ( Str( mkod, 4 ) )
    If !Found()
      Exit
    Endif
    If usl->kod_up == 0 .or. i > 20
      Exit
    Endif
    mkod := usl->kod_up
    ++i
  Enddo
  If tmp_select > 0
    Select( tmp_select )
  Endif

  Return ( AScan( arr_usl, usl->kod ) > 0 )

// 03.01.19
Function input_usluga( arr_tfoms )

  Local ar, musl, arr_usl, buf, fl_tfoms := ( ValType( arr_tfoms ) == 'A' )

  ar := getinisect( tmp_ini, 'uslugi' )
  musl := PadR( a2default( ar, 'shifr' ), 10 )
  If ( musl := input_value( 18, 6, 20, 73, color1, ;
      Space( 17 ) + 'Введите шифр услуги', musl, '@K' ) ) != Nil .and. !Empty( musl )
    buf := save_maxrow()
    mywait()
    musl := transform_shifr( musl )
    setinisect( tmp_ini, 'uslugi', { { 'shifr', musl } } )
    r_use( dir_server + 'uslugi', dir_server + 'uslugish', 'USL' )
    find ( musl )
    If Found()
      susl := musl
      arr_usl := { usl->kod, AllTrim( usl->shifr ) + '. ' + AllTrim( usl->name ), usl->shifr }
    Else
      func_error( 4, 'Услуга с шифром ' + AllTrim( musl ) + ' не найдена в нашем справочнике!' )
      If fl_tfoms
        arr_usl := { 0, '', '' }
      Endif
    Endif
    usl->( dbCloseArea() )
    If fl_tfoms
      use_base( "lusl" )
      find ( musl )
      If Found()
        arr_tfoms[ 1 ] := lusl->( RecNo() )
        arr_tfoms[ 2 ] := AllTrim( lusl->shifr ) + '. ' + AllTrim( lusl->name )
        arr_tfoms[ 3 ] := lusl->shifr
      Endif
      close_use_base( 'lusl' )
    Endif
    rest_box( buf )
  Endif

  Return arr_usl

//
Function ret_1st_otd( lkod_uch )

  Local k, tmp_select := Select()

  r_use( dir_server + 'mo_otd', , 'OTD' )
  Locate For otd->kod_lpu == lkod_uch
  If Found()
    k := { otd->( RecNo() ), AllTrim( otd->name ) }
  Else
    func_error( 3, 'Нет отделений для данного учреждения!' )
  Endif
  otd->( dbCloseArea() )
  If tmp_select > 0
    Select( tmp_select )
  Endif

  Return k

// вернуть процент выполнения плана
Function ret_trudoem( lkod_vr, ltrudoem, kol_mes, arr_m, /*@*/plan)

  Local i := 0, trd := 0, ltrud, tmp_select := Select()

  plan := 0
  Do While i < kol_mes
    ltrud := 0
    // сначала поиск конкретного месяца
    Select UCHP
    find ( Str( lkod_vr, 4 ) + Str( arr_m[ 1 ], 4 ) + Str( arr_m[ 2 ] + i, 2 ) )
    If Found()
      ltrud := uchp->m_trud
    Endif
    If Empty( ltrud )  // если не нашли
      // то поиск среднемесячного плана
      Select UCHP
      find ( Str( lkod_vr, 4 ) + Str( 0, 4 ) + Str( 0, 2 ) )
      If Found()
        ltrud := uchp->m_trud
      Endif
    Endif
    plan += ltrud
    ++i
  Enddo
  If plan > 0
    trd := ltrudoem / plan * 100
  Endif
  Select ( tmp_select )

  Return trd

// 13.02.14
Function input_uch( r, c, date1, date2 )

  Local ret, k, fl_is, tmp_select := Select()

  If !myfiledeleted( cur_dir + 'tmp_ga' + sdbf )
    Return ret
  Endif
  If Empty( glob_uch[ 1 ] )
    ar := getinivar( tmp_ini, { { 'uch_otd', 'uch', '0' }, ;
      { 'uch_otd', 'OTD', '0' } } )
    glob_uch[ 1 ] := Int( Val( ar[ 1 ] ) )
    glob_otd[ 1 ] := Int( Val( ar[ 2 ] ) )
  Endif
  dbCreate( cur_dir + 'tmp_ga', { { 'name', 'C', 30, 0 }, ;
    { 'kod', 'N', 3, 0 }, ;
    { 'is', 'L', 1, 0 } } )
  Use ( cur_dir + 'tmp_ga' ) new
  r_use( dir_server + 'mo_uch', , 'UCH' )
  Go Top
  Do While !Eof()
    fl_is := between_date( uch->DBEGIN, uch->DEND, date1, date2 )
    If iif( date1 == NIL, .t., fl_is )
      Select TMP_GA
      Append Blank
      Replace name With uch->name, ;
        kod With uch->kod, ;
        is With fl_is
    Endif
    Select UCH
    Skip
  Enddo
  uch->( dbCloseArea() )
  Select TMP_GA
  If ( k := tmp_ga->( LastRec() ) ) == 1
    ret := { tmp_ga->kod, AllTrim( tmp_ga->name ) }
  Else
    Index On Upper( name ) to ( cur_dir + 'tmp_ga' )
  Endif
  tmp_ga->( dbCloseArea() )
  Select ( tmp_select )
  If k == 0
    func_error( 4, 'Пустой справочник учреждений' )
  Elseif k > 1
    ret := fget_tmp_ga( glob_uch[ 1 ], r, c, , 'Выбор учреждения', .f. )
  Endif
  If ret != NIL
    glob_uch := ret
    st_a_uch := { glob_uch }
    setinivar( tmp_ini, { { 'uch_otd', 'UCH', glob_uch[ 1 ] } } )
  Endif

  Return ret

//
Function inpute_otd( r1, c1, r2 )
  Return input_otd( r1, c1, sys_date )

// 13.02.14
Function input_otd( r, c, date1, date2, nTask )

  Local ret, k, fl_is, tmp_select := Select()

  Default nTask To X_OMS
  If !myfiledeleted( cur_dir + 'tmp_ga' + sdbf )
    Return ret
  Endif
  dbCreate( cur_dir + 'tmp_ga', { { 'name', 'C', 30, 0 }, ;
    { 'kod', 'N', 3, 0 }, ;
    { 'idump', 'N', 2, 0 }, ;
    { 'tiplu', 'N', 2, 0 }, ;
    { 'is', 'L', 1, 0 } } )
  Use ( cur_dir + 'tmp_ga' ) new
  r_use( dir_server + 'mo_otd', , 'OTD' )
  Go Top
  Do While !Eof()
    If otd->KOD_LPU == glob_uch[ 1 ]
      If nTask == X_ORTO
        fl_is := between_date( otd->DBEGINO, otd->DENDO, date1, date2 )
      Elseif nTask == X_PLATN
        fl_is := between_date( otd->DBEGINP, otd->DENDP, date1, date2 )
      Else
        fl_is := between_date( otd->DBEGIN, otd->DEND, date1, date2 )
      Endif
      If iif( date1 == NIL, .t., fl_is )
        Select TMP_GA
        Append Blank
        Replace name With otd->name, ;
          kod With otd->kod, ;
          idump With otd->idump, ;
          tiplu With otd->tiplu, ;
          is With fl_is
      Endif
    Endif
    Select OTD
    Skip
  Enddo
  otd->( dbCloseArea() )
  Select TMP_GA
  If ( k := tmp_ga->( LastRec() ) ) == 1
    ret := { tmp_ga->kod, AllTrim( tmp_ga->name ), tmp_ga->idump, tmp_ga->tiplu }
  Else
    Index On Upper( name ) to ( cur_dir + 'tmp_ga' )
  Endif
  tmp_ga->( dbCloseArea() )
  Select ( tmp_select )
  If k == 0
    func_error( 4, 'Не найдено отделений для данного учреждения' )
  Elseif k > 1
    ret := fget_tmp_ga( glob_otd[ 1 ], r, c, , 'Выбор отделения', .f., AllTrim( glob_uch[ 2 ] ) )
  Endif
  If ret != NIL
    glob_otd := ret
    setinivar( tmp_ini, { { 'uch_otd', 'OTD', glob_otd[ 1 ] } } )
  Endif

  Return ret

// 29.10.18
Function input_perso( r, c, is_null, is_rab )

  Static si := 1
  Local fl := .f., fl1 := .f., mas_pmt, s_input, s_glob, s_pict, tmp_help := 0, ;
    arr_dolj := {}, arr_kod := {}, lr, r1, r2, i, buf := save_row( MaxRow() )

  Default is_null To .t., is_rab To .f.
  mas_pmt := { 'Поиск сотрудника по ~таб.номеру', 'Поиск сотрудника по ~фамилии' }
  s_input := Space( 10 ) + 'Введите табельный номер сотрудника'
  s_glob := glob_human[ 5 ]
  s_pict := '99999'
  If ( i := popup_prompt( r, c, si, mas_pmt ) ) == 0
    Return .f.
  Elseif i == 1
    si := 1
    If ( i := input_value( 18, 6, 20, 73, color1, s_input, s_glob, s_pict ) ) == NIL
      Return .f.
    Elseif i == 0
      If is_null
        glob_human := { 0, '', 0, 0, 0, '', 0, 0 }
        Return .t.
      Else
        Return .f.
      Endif
    Elseif i < 0
      Return func_error( 4, 'Неверный ввод - отрицательный код!' )
    Endif
    r_use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'PERSO' )
    find ( Str( i, 5 ) )
    If Found()
      glob_human := { perso->kod, ;
        AllTrim( perso->fio ), ;
        perso->uch, ;
        perso->otd, ;
        i, ;
        AllTrim( perso->name_dolj ), ;
        perso->prvs, ;
        perso->prvs_new }
      fl1 := .t.
    Else
      func_error( 4, 'Сотрудника с табельным номером ' + lstr( i ) + ' нет в базе данных персонала!' )
    Endif
    Close databases
    Return fl1
  Endif
  si := 2
  Private mr := r
  mywait()
  // help_code := H_Input_fio
  If r_use( dir_server + 'mo_pers', , 'PERSO' )
    Index On Upper( fio ) to ( cur_dir + 'tmp_pers' ) For kod > 0
    If glob_human[ 1 ] > 0
      Goto ( glob_human[ 1 ] )
      fl := !Eof() .and. !Deleted()
    Endif
    If !fl
      Go Top
    Endif
    If alpha_browse( r, 9, MaxRow() -2, 70, 'f1inp_perso', color0, , , , , , , , , { '═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B' } )
      lr := Row()
      If perso->kod == 0
        func_error( 4, 'База данных персонала пустая!' )
      Else
        glob_human := { perso->kod, ;
          AllTrim( perso->fio ), ;
          perso->uch, ;
          perso->otd, ;
          perso->tab_nom, ;
          AllTrim( perso->name_dolj ), ;
          perso->prvs, ;
          perso->prvs_new }
        fl1 := .t.
      Endif
    Endif
  Endif
  Close databases
  // help_code := tmp_help
  rest_box( buf )

  Return fl1

// 25.06.24
Function f1inp_perso( oBrow )

  Local oColumn

  oColumn := TBColumnNew( Center( 'Ф.И.О.', 30 ), {|| Left( perso->fio, 30 ) } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Таб.№', {|| perso->tab_nom } )
  oColumn:defColor := { 3, 3 }
  oColumn:colorBlock := {|| { 3, 3 } }
  oBrow:addcolumn( oColumn )
//  oColumn := TBColumnNew( Center( 'Специальность', 21 ), {|| PadR( ret_tmp_prvs( perso->prvs, perso->prvs_new ), 21 ) } )
  oColumn := TBColumnNew( Center( 'Специальность', 21 ), {|| PadR( ret_str_spec( perso->PRVS_021 ), 21 ) } )
  oBrow:addcolumn( oColumn )

  Return Nil

// вернуть учреждение и отделение в GET'е
Function ret_uch_otd( k, r, c, date1, date2, nTask )

  Local ret, n := 1

  If k != Nil .and. k > 0
    glob_uch[ 1 ] := k
  Endif
  If input_uch( r, c, date1, date2 ) != NIL
    If Type( 'm1otd' ) == 'N' .and. m1otd > 0
      glob_otd[ 1 ] := m1otd
    Endif
    If input_otd( r, c, date1, date2, nTask ) != NIL
      If ValType( motd ) == 'C'
        n := Len( motd )
      Endif
      m1otd := glob_otd[ 1 ]
      motd := AllTrim( glob_otd[ 2 ] )
      If Len( motd ) < n
        motd := PadR( motd, n )
      Endif
      ret := glob_uch
    Endif
  Endif

  Return ret

// удаление данных по зубной формуле в HUMANST (для платных услуг)
Function stdelhuman( ltip, lrec )

  Select HUMANST
  Do While .t.
    find ( Str( ltip, 1 ) + Str( lrec, 8 ) )
    If !Found()
      Exit
    Endif
    deleterec( .t. )
  Enddo

  Return Nil

// удаление данных по зубной формуле в картотеке
Function stdelkart( ltip, lrec )

  Select KART_ST
  Set Order To 2
  Do While .t.
    find ( Str( ltip, 1 ) + Str( lrec, 8 ) )
    If !Found()
      Exit
    Endif
    deleterec( .t. )
  Enddo

  Return Nil

// добавление данных по зубной формуле
Function stappend( ltip, lrec, lkod_k, ldate_u, lu_kod, lkod_vr, _zf, _diag )

  Local i, arr_zf := stretarrzf( _zf )

  stdelkart( ltip, lrec )
  If ltip == 2 // платные услуги
    stdelhuman( ltip, lrec )
  Endif
  If Len( arr_zf ) > 0
    If ltip == 2 // платные услуги
      Select HUMANST
      addrec( 1 )
      humanst->TIP_BD    := ltip
      humanst->REC_BD    := lrec
      humanst->KOD_DIAG  := _diag
      humanst->ZF        := _zf
      humanst->( dbUnlock() )
    Endif
    Select KART_ST
    Set Order To 2
    For i := 1 To Len( arr_zf )
      addrec( 1 )
      kart_st->KOD       := lkod_k
      kart_st->ZF        := arr_zf[ i ]
      kart_st->KOD_DIAG  := _diag
      kart_st->TIP_BD    := ltip
      kart_st->REC_BD    := lrec
      kart_st->DATE_U    := ldate_u
      kart_st->U_KOD     := lu_kod
      kart_st->KOD_VR    := lkod_vr
      kart_st->( dbUnlock() )
    Next
  Endif

  Return Nil

// 17.12.18 добавление удалённого зуба
Function stappenddelz( lkod_k, _zf, ldate_u, lu_kod )

  Static arr_STdelzub
  Local i, arr_zf := stretarrzf( _zf )

  Default arr_STdelzub To ret_arr_stdelzub()
  If Len( arr_zf ) > 0 .and. AScan( arr_STdelzub, lu_kod ) > 0 .and. Select( 'KARTDELZ' ) > 0
    Select KARTDELZ
    For i := 1 To Len( arr_zf )
      find ( Str( lkod_k, 7 ) + Str( arr_zf[ i ], 2 ) )
      If Found()
        If !( kartdelz->DATE_U == ldate_u )
          g_rlock( forever )
          kartdelz->DATE_U := ldate_u
          kartdelz->( dbUnlock() )
        Endif
      Else
        addrec( 7 )
        kartdelz->KOD    := lkod_k
        kartdelz->ZF     := arr_zf[ i ]
        kartdelz->DATE_U := ldate_u
        kartdelz->( dbUnlock() )
      Endif
    Next
  Endif

  Return Nil

// 17.12.18 удаление удалённого зуба
Function stdeldelz( lkod_k, _zf, lu_kod )

  Static arr_STdelzub
  Local i, arr_zf := stretarrzf( _zf )

  Default arr_STdelzub To ret_arr_stdelzub()
  If Len( arr_zf ) > 0 .and. AScan( arr_STdelzub, lu_kod ) > 0 .and. Select( 'KARTDELZ' ) > 0
    Select KARTDELZ
    For i := 1 To Len( arr_zf )
      find ( Str( lkod_k, 7 ) + Str( arr_zf[ i ], 2 ) )
      If Found()
        deleterec( .t. )
      Endif
    Next
  Endif

  Return Nil

// 11.12.18 вернуть массив с кодами услуг удаления зуба
Function ret_arr_stdelzub()

  Static arr := { ;
    { 'A16.07.030.001', 'Удаление временного зуба' }, ;
    { 'A16.07.030.002', 'Удаление постоянного зуба' }, ;
    { 'A16.07.030.003', 'Удаление зуба сложное с разъединением корней' }, ;
    { 'A16.07.039', 'Операция удаления ретинированного, дистопированного или сверхкомплектного зуба' } ;
    }
  Static akod := {}
  Local i, s, lkod := 0
  /*if len(akod) == 0
    use_base("mo_su","MOSU1")
    akod := {}
    for i := 1 to len(arr)
      s := arr[i,1]
      select MOSU1
      set order to 3
      find (padr(s,20))
      do while mosu1->shifr1 == padr(s,20) .and. !eof()
        if !("*" $ mosu1->shifr)
          lkod := mosu1->kod ; exit
        endif
        skip
      enddo
      if lkod == 0
        set order to 1
        FIND (STR(-1,6))
        if found()
          G_RLock(forever)
        else
          AddRec(6)
        endif
        lkod := mosu1->kod := recno()
        mosu1->name := arr[i,2]
        mosu1->shifr1 := s
      endif
      aadd(akod,lkod)
    next
    mosu1->(dbCloseArea())
  endif*/

  Return akod

// 17.12.18 проверка, не удалён ли зуб
Function stverdelzub( lkod_k, arr_zf, ldate_u, ltip, lrec, /*@*/amsg)

  Static arr_STdelzub
  Local i

  Default arr_STdelzub To ret_arr_stdelzub()
  If Len( arr_STdelzub ) > 0 .and. Select( 'KARTDELZ' ) > 0
    Select KARTDELZ
    For i := 1 To Len( arr_zf )
      find ( Str( lkod_k, 7 ) + Str( arr_zf[ i ], 2 ) )
      If Found() .and. kartdelz->DATE_U < ldate_u
        AAdd( amsg, lstr( arr_zf[ i ] ) + ': данный зуб удален ' + full_date( c4tod( kartdelz->DATE_U ) ) )
      Endif
    Next
  Endif
  /*if len(arr_STdelzub) > 0
    select KART_ST
    set order to 1
    for i := 1 to len(arr_zf)
      find (str(lkod_k,7)+str(arr_zf[i],2))
      do while kart_st->KOD == lkod_k .and. kart_st->ZF == arr_zf[i]
        if !(kart_st->TIP_BD == ltip .and. kart_st->REC_BD == lrec)
          if kart_st->DATE_U < ldate_u .and. ascan(arr_STdelzub,kart_st->U_KOD) > 0
            aadd(amsg, lstr(arr_zf[i])+': данный зуб удален '+full_date(c4tod(kart_st->DATE_U)))
          endif
        endif
        skip
      enddo
    next
  endif*/

  Return Nil

// 16.01.19 проверка правильности ввода зубной формулы
Function stverifykolzf( arr_zf, mkol, /*@*/amsg, lshifr)

  If ValType( arr_zf ) == 'A' .and. ValType( mkol ) == 'N'
    Default lshifr To ''
    If Len( arr_zf ) == 0 //
      AAdd( amsg, 'не введена зубная формула ' + lshifr )
    Elseif Len( arr_zf ) != mkol
      AAdd( amsg, 'количество зубов не соответствует количеству введённых зубных формул ' + lshifr )
    Endif
  Endif

  Return !Empty( amsg )

// 31.01.19 проверка правильности ввода зубной формулы
Function stverifyzf( _zf, _date_r, _sys_date, /*@*/amsg, lshifr)

  Static fz := { { 11, 18 }, { 21, 28 }, { 31, 38 }, { 41, 48 }, { 51, 55 }, { 61, 65 }, { 71, 75 }, { 81, 85 } }

  // возраст больного с 14 лет   |       возраст до 5 лет
  Local i, j, k, v, arr_zf := stretarrzf( _zf, @amsg, lshifr )
  If Len( arr_zf ) > 0
    Default lshifr To ''
    v := count_years( _date_r, _sys_date )
    For i := 1 To Len( arr_zf )
      k := 0
      For j := 1 To Len( fz )
        If Between( arr_zf[ i ], fz[ j, 1 ], fz[ j, 2 ] )
          k := j
          Exit
        Endif
      Next
      If k == 0
        AAdd( amsg, lstr( arr_zf[ i ] ) + ' - неверная зубная формула ' + lshifr )
        // elseif v <= 5 .and. between(k,1,4)
        // aadd(amsg, lstr(arr_zf[i])+' - у ребенка зубная формула взрослого '+lshifr)
        // elseif v > 14 .and. between(k,5,8)
        // aadd(amsg, lstr(arr_zf[i])+' - у взрослого зубная формула ребенка '+lshifr)
      Endif
    Next
  Endif

  Return arr_zf

// 16.01.19 синтаксический анализ зубной формулы, возврат массива зубов
Function stretarrzf( _zf, /*@*/amsg, lshifr)

  // Static ssymb := "12345678,-МДВЖН", nsymb := 15  так было у Демиденко Татьяны
  Static ssymb := '12345678,-', nsymb := 10
  Local i, j, s, tmps, v1, v2, arr_zf := {}

  Default amsg TO {}, lshifr To ''
  s := CharRem( ' ', _zf ) // удалить все пробелы
  // проверяем на допустимые символы
  tmps := CharRem( ' ', CharRepl( ssymb, s, Space( nsymb ) ) )
  If !Empty( tmps )
    AAdd( amsg, '"' + tmps + '" - зубная формула: некорректные символы ' + lshifr )
  Endif
  For i := 1 To NumToken( s, ',' )
    tmps := Token( s, ',', i )
    If '-' $ tmps // обработка диапазона
      v1 := Token( tmps, '-', 1 )
      v2 := Token( tmps, '-', 2 )
    Else // одиночное значение
      v1 := v2 := tmps
    Endif
    v1 := Int( Val( v1 ) )
    v2 := Int( Val( v2 ) )
    If v2 < v1
      AAdd( amsg, '"' + tmps + '" - зубная формула: некорректный диапазон ' + lshifr )
      v2 := v1
    Endif
    For j := v1 To v2
      AAdd( arr_zf, j ) // массив зубов
    Next
  Next

  Return arr_zf

// 16.01.19 является ли случай стоматологическим для ввода зубной формулы
Function stiszf( _USL_OK, _PROFIL )
  Return ( _USL_OK == 3 .and. eq_any( _PROFIL, 85, 86, 87, 88, 89, 90, 140, 171 ) )

// ввод фразы для места работы из списка
Function v_vvod_mr()

  Local k, nrow := Row(), ncol := Col(), fl := .f., tmp_keys, tmp_gets

  tmp_keys := my_savekey()
  If ( get := get_pointer( "MMR_DOL" ) ) != Nil .and. get:hasFocus
    Save gets To tmp_gets
    SetCursor( 0 )
    If !Empty( k := input_s_mr() )
      fl := .t.
    Else
      @ nrow, ncol Say ""
    Endif
    Restore gets From tmp_gets
    If fl
      Keyboard ( AllTrim( k ) )
    Endif
    SetCursor()
  Endif
  my_restkey( tmp_keys )

  Return Nil

// выбор фразы для места работы
Function input_s_mr()

  Local t_arr[ BR_LEN ], tmp_select := Select(), buf := SaveScreen(), ret := ""

  t_arr[ BR_TOP ] := 2
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 26
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_OPEN ] := {|| f1_s_mr(,, "open" ) }
  t_arr[ BR_CLOSE ] := {|| sa->( dbCloseArea() ) }
  t_arr[ BR_COLOR ] := color0
  // t_arr[BR_ARR_BROWSE] := {,,,,,reg,"*+"}
  t_arr[ BR_COLUMN ] := { { Center( "Список фраз для места работы", 50 ), {|| sa->name } } }
  s_msg := "^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<Ins>^ - добавление"
  t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<Ins>^ - добавление;  ^<F2>^ - поиск" ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_s_mr( nk, ob, "edit" ) }
  t_arr[ BR_ENTER ] := {|| ret := AllTrim( sa->name ) }
  edit_browse( t_arr )
  If tmp_select > 0
    Select( tmp_select )
  Endif
  RestScreen( buf )

  Return ret

//
Function f1_s_mr( nKey, oBrow, regim )

  Static tmp := ' '
  Local ret := -1, j := 0, flag := -1, buf := save_maxrow(), buf1, ;
    fl := .f., rec, mkod, tmp_color := SetColor()

  Do Case
  Case regim == "open"
    g_use( dir_server + "s_mr",, "SA" )
    Index On Upper( name ) to ( cur_dir + "tmp_mr" )
    Go Top
    ret := !Eof()
  Case regim == "edit"
    If nKey == K_F2
      Private tmp1 := PadR( tmp, 30 )
      If ( tmp1 := input_value( pr2 - 2, pc1 + 1, pr2, pc2 - 1, color1, ;
          "Подстрока поиска", ;
          tmp1, "@K@!" ) ) != Nil .and. !Empty( tmp1 )
        tmp := AllTrim( tmp1 )
        Private tmp_mas := {}, tmp_kod := {}
        rec := RecNo()
        Go Top
        Locate For tmp $ Upper( name )
        Do While !Eof()
          If++j > 4000 ; exit ; Endif
          AAdd( tmp_mas, sa->name ) ; AAdd( tmp_kod, sa->( RecNo() ) )
          Continue
        Enddo
        Goto ( rec )
        If Len( tmp_kod ) == 0
          stat_msg( "Неудачный поиск!" ) ; mybell( 2 )
        Else
          status_key( "^<Esc>^ - отказ от выбора" )
          If ( j := Popup( pr1 + 1, pc1 + 1, pr2 - 1, pc2 - 1, tmp_mas,, color5,,,, ;
              'Результат поиска по подстроке "' + tmp + '"', "B/W" ) ) > 0
            oBrow:gotop()
            Goto ( tmp_kod[ j ] )
          Endif
          ret := 0
        Endif
      Endif
    Elseif nKey == K_INS
      rec := RecNo()
      Private mname := if( nKey == K_INS, Space( 50 ), sa->name ), ;
        gl_area := { 1, 0, 23, 79, 0 }
      buf1 := box_shadow( pr2 - 2, pc1 + 1, pr2, pc2 - 1, color8, ;
        iif( nKey == K_INS, "Добавление", "Редактирование" ), cDataPgDn )
      SetColor( cDataCGet )
      @ pr2 - 1, pc1 + 2 Get mname
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение записи" )
      myread()
      If LastKey() != K_ESC .and. !Empty( mname )
        If nKey == K_INS
          addrecn()
          rec := RecNo()
        Else
          g_rlock( forever )
        Endif
        Replace name With mname
        Commit
        Unlock
        oBrow:gotop()
        Goto ( rec )
        ret := 0
      Endif
      SetColor( tmp_color )
      rest_box( buf ) ; rest_box( buf1 )
    Else
      Keyboard ""
    Endif
  Endcase

  Return ret

// 07.02.13 ввод фразы для адреса из списка
Function v_vvod_adres()

  Local k, nrow := Row(), ncol := Col(), fl := .f., tmp_keys, tmp_gets

  tmp_keys := my_savekey()
  If ( get := get_pointer( 'MULICADOM' ) ) != Nil .and. get:hasFocus
    Save gets To tmp_gets
    SetCursor( 0 )
    If !Empty( k := input_s_adres() )
      fl := .t.
    Else
      @ nrow, ncol Say ''
    Endif
    Restore gets From tmp_gets
    If fl
      Keyboard ( AllTrim( k ) + ' ' )
    Endif
    SetCursor()
  Endif
  my_restkey( tmp_keys )

  Return Nil

// выбор фразы для адреса
Function input_s_adres()

  Local t_arr[ BR_LEN ], tmp_select := Select(), buf := SaveScreen(), ret := ''

  t_arr[ BR_TOP ] := 2
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 36
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_OPEN ] := {|| f1_s_adres( , , 'open' ) }
  t_arr[ BR_CLOSE ] := {|| sa->( dbCloseArea() ) }
  t_arr[ BR_COLOR ] := color0
  // t_arr[BR_ARR_BROWSE] := {,,,,,reg,"*+"}
  t_arr[ BR_COLUMN ] := { { Center( 'Список фраз для адреса', 40 ), {|| sa->name } } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<Ins>^ - добавление' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_s_adres( nk, ob, 'edit' ) }
  t_arr[ BR_ENTER ] := {|| ret := AllTrim( sa->name ) }
  edit_browse( t_arr )
  If tmp_select > 0
    Select( tmp_select )
  Endif
  RestScreen( buf )

  Return ret

// форма настройки включаемых/исключаемых услуг
Function forma_nastr( s_titul, arr_strok, nfile, arr, fl )

  Local i, j, r := 2, tmp_color := SetColor( cDataCGet )
  Local buf := SaveScreen(), blk := {|| f9_f_nastr( s_titul, arr_strok ) }

  If nfile != NIL
    arr := rest_arr( nfile )
  Endif
  If arr == Nil .or. Empty( arr )
    arr := { {}, {} }
  Endif
  Private mda[ 15 ], mnet[ 15 ]
  AFill( mda, Space( 10 ) )
  AEval( arr[ 1 ], {| x, i| mda[ i ] := PadR( x, 10 ) } )
  AFill( mnet, Space( 10 ) )
  AEval( arr[ 2 ], {| x, i| mnet[ i ] := PadR( x, 10 ) } )
  box_shadow( r, 0, 23, 79, color1, s_titul, color8 )
  str_center( r + 2, 'Данный режим предназначен для настройки' )
  j := r + 2
  AEval( arr_strok, {| x| str_center( ++j, x, 'G+/B' ) } )
  ++j
  @ ++j, 4 Say '     Включаемые услуги (шаблон)          Исключаемые услуги (шаблон)'
  For i := 1 To 15
    @ j + i, 15 Say Str( i, 2 ) Get mda[ i ]
  Next
  For i := 1 To 15
    @ j + i, 52 Say Str( i, 2 ) Get mnet[ i ]
  Next
  status_key( '^<Esc>^ - выход;  ^<PgDn>^ - запомнить настройки;  ^<F9>^ - печать списка услуг' )
  SetKey( K_F9, blk )
  myread()
  SetKey( K_F9, NIL )
  fl := .f.
  If LastKey() != K_ESC .and. f_esc_enter( 1 )
    fl := .t.
    arr := { {}, {} }
    For i := 1 To 15
      If !Empty( mda[ i ] )
        AAdd( arr[ 1 ], mda[ i ] )
      Endif
      If !Empty( mnet[ i ] )
        AAdd( arr[ 2 ], mnet[ i ] )
      Endif
    Next
    If nfile != NIL
      save_arr( arr, nfile )
    Endif
  Endif
  SetColor( tmp_color )
  RestScreen( buf )

  Return arr

//
Function f9_f_nastr( l_titul, a_strok )

  Local sh := 80, HH := 77, buf := save_maxrow(), n_file := cur_dir + 'frm_nast' + stxt
  Local i, k, nrow := Row(), ncol := Col(), tmp_keys, tmp_gets, ta := {}

  mywait()
  tmp_keys := my_savekey()
  Save gets To tmp_gets
  //
  fp := FCreate( n_file )
  tek_stroke := 0
  n_list := 1
  add_string( '' )
  add_string( Center( l_titul, sh ) )
  add_string( '' )
  add_string( Center( 'Данный список услуг представляет содержание', sh ) )
  AEval( a_strok, {| x| add_string( Center( x, sh ) ) } )
  add_string( '' )
  add_string( '      Включаемые услуги (шаблон)          Исключаемые услуги (шаблон)' )
  k := 0
  For i := 1 To 15
    AAdd( ta, Space( 20 ) + mda[ i ] + Space( 20 ) + mnet[ i ] )
    If !emptyall( mda[ i ], mnet[ i ] )
      k := i
    Endif
  Next
  For i := 1 To k
    add_string( ta[ i ] )
  Next
  r_use( dir_server + 'uslugi', , 'USL' )
  Index On fsort_usl( shifr ) to ( cur_dir + 'tmpu' )
  Go Top
  Do While !Eof()
    If _f_usl_danet( mda, mnet )
      verify_ff( HH, .t., sh )
      add_string( usl->shifr + ' ' + RTrim( usl->name ) )
    Endif
    Skip
  Enddo
  usl->( dbCloseArea() )
  FClose( fp )
  rest_box( buf )
  viewtext( n_file, , , , .f., , , 5 )
  //
  Restore gets From tmp_gets
  my_restkey( tmp_keys )
  SetCursor()

  Return Nil

//
Function ret_f_nastr( a_usl, lshifr )

  Local i, shb, fl := .f.

  For i := 1 To Len( a_usl[ 1 ] )
    If !Empty( shb := a_usl[ 1, i ] )
      If '*' $ shb .or. '?' $ shb
        fl := Like( AllTrim( shb ), lshifr )
      Else
        fl := ( shb == lshifr )
      Endif
      If fl
        Exit
      Endif
    Endif
  Next
  If fl
    For i := 1 To Len( a_usl[ 2 ] )
      If !Empty( shb := a_usl[ 2, i ] )
        If '*' $ shb .or. '?' $ shb
          fl := !Like( AllTrim( shb ), lshifr )
        Else
          fl := !( shb == lshifr )
        Endif
        If !fl
          Exit
        Endif
      Endif
    Next
  Endif

  Return fl

//
Function _f_usl_danet( a_da, a_net )

  Local fl, i, shb

  fl := usl->is_nul .or. !emptyall( usl->cena, usl->cena_d )
  If !fl .and. is_task( X_PLATN ) // для платных услуг
    fl := usl->is_nulp .or. !emptyall( usl->pcena, usl->pcena_d, usl->dms_cena )
  Endif
  If fl
    fl := .f.
    For i := 1 To Len( a_da )
      If !Empty( shb := a_da[ i ] )
        If '*' $ shb .or. '?' $ shb
          fl := Like( AllTrim( shb ), usl->shifr )
        Else
          fl := ( shb == usl->shifr )
        Endif
        If fl
          Exit
        Endif
      Endif
    Next
    If fl
      For i := 1 To Len( a_net )
        If !Empty( shb := a_net[ i ] )
          If '*' $ shb .or. '?' $ shb
            fl := !Like( AllTrim( shb ), usl->shifr )
          Else
            fl := !( shb == usl->shifr )
          Endif
          If !fl
            Exit
          Endif
        Endif
      Next
    Endif
  Endif

  Return fl

// 28.01.20 вывести строку в отладочный массив о КСГ
Function f_put_debug_ksg( k, arr, ars )

  // k = 1 - терапевтическая
  // k = 2 - хирургическая
  Local s := ' ', i, s1, arr1 := {}
  If k == 1
    s += 'терап.'
  Elseif k == 2
    s += 'хирур.'
  Endif
  s += 'КСГ'
  If Len( arr ) == 0
    s += ' не определена'
  Else
    s += ': '
    For i := 1 To Len( arr )
      s1 := ''
      If k == 0 .and. !Empty( arr[ i, 5 ] )
        s1 += 'осн.диаг.,'
      Endif
      If eq_any( k, 0, 1 ) .and. !Empty( arr[ i, 6 ] )
        If AllTrim( arr[ i, 10 ] ) == 'mgi'
          //
        Else
          s1 += 'усл.,'
        Endif
      Endif
      If !Empty( arr[ i, 7 ] )
        s1 += 'возр.,'
      Endif
      If !Empty( arr[ i, 8 ] )
        s1 += 'пол,'
      Endif
      If !Empty( arr[ i, 9 ] )
        s1 += 'дл-ть,'
      Endif
      If !Empty( arr[ i, 10 ] )
        s1 += 'доп.критерий,'
      Endif
      If Len( arr[ i ] ) >= 15 .and. !Empty( arr[ i, 15 ] )
        s1 += 'иной критерий,'
      Endif
      If !Empty( arr[ i, 11 ] )
        s1 += 'соп.диаг.,'
      Endif
      If !Empty( arr[ i, 12 ] )
        s1 += 'диаг.осл.,'
      Endif
      If !Empty( s1 )
        s1 := ' (' + Left( s1, Len( s1 ) -1 ) + ')'
      Endif
      s1 := AllTrim( arr[ i, 1 ] ) + s1 + ' [КЗ=' + lstr( arr[ i, 3 ] ) + ']'
      If AScan( arr1, s1 ) == 0
        AAdd( arr1, s1 )
      Endif
    Next
    For i := 1 To Len( arr1 )
      s += arr1[ i ] + ' '
    Next
  Endif
  AAdd( ars, s )

  Return Len( arr1 )

// 20.01.14 вернуть цену КСГ
Function ret_cena_ksg( lshifr, lvr, ldate, ta )

  Local fl_del := .f., fl_uslc := .f., v := 0

  Default ta TO {}
  v := fcena_oms( lshifr, ;
    ( lvr == 0 ), ;
    ldate, ;
    @fl_del, ;
    @fl_uslc )
  If fl_uslc  // если нашли в справочнике ТФОМС
    If fl_del
      AAdd( ta, ' цена на услугу ' + RTrim( lshifr ) + ' отсутствует в справочнике ТФОМС' )
    Endif
  Else
    AAdd( ta, ' для Вашей МО в справочнике ТФОМС не найдена услуга: ' + lshifr )
  Endif

  Return v

// 28.01.14 вывести в центре экрана протокол определения КСГ
Function f_put_arr_ksg( cLine )

  Local buf := SaveScreen(), i, nLLen := 0, mc := MaxCol() -1, ;
    nLCol, nRCol, nTRow, nBRow, nNumRows := Len( cLine )

  AEval( cLine, {| x, i| nLLen := Max( nLLen, Len( x ) ) } )
  If nLLen > mc
    nLLen := mc
  Endif
  // вычисление координат углов
  nLCol := Int( ( mc - nLLen ) / 2 )
  nRCol := nLCol + nLLen + 1
  nTRow := Int( ( MaxRow() - nNumRows ) / 2 )
  nBRow := nTRow + nNumRows + 1
  put_shadow( nTRow, nLCol, nBRow, nRCol )
  @ nTRow, nLCol Clear To nBRow, nRCol
  DispBox( nTRow, nLCol, nBRow, nRCol, 2, 'GR/GR*' )
  AEval( cLine, {| cSayStr, i| ;
    nSayRow := nTRow + i, ;
    nSayCol := nLCol + 1, ;
    SetPos( nSayRow, nSayCol ), DispOut( PadR( cSayStr, nLLen ), 'N/GR*' ) ;
    } )
  Inkey( 0 )
  RestScreen( buf )

  Return Nil

// // 26.01.18 тест определения КСГ
// Function test_definition_KSG()
// Local arr, buf := save_maxrow(), lshifr, lrec, lu_kod, lcena, lyear, mrec_hu, not_ksg := .t.
// stat_msg("Определение КСГ")
// R_Use(dir_server + "mo_uch",,'UCH')
// R_Use(dir_server + 'mo_otd',,'OTD')
// Use_base("lusl")
// Use_base("luslc")
// Use_base('uslugi')
// R_Use(dir_server + "schet_",,"SCHET_")
// R_Use(dir_server + "uslugi1",{dir_server + "uslugi1", ;
// dir_server + "uslugi1s"},"USL1")
// use_base("human_u") // если понадобится, удалить старый КСГ и добавить новый
// R_Use(dir_server + "mo_su",,"MOSU")
// R_Use(dir_server + "mo_hu",dir_server + "mo_hu","MOHU")
// set relation to u_kod into MOSU
// R_Use(dir_server + "human_2",,"HUMAN_2")
// R_Use(dir_server + "human_",,"HUMAN_")
// G_Use(dir_server + "human",,"HUMAN") // перезаписать сумму
// set relation to recno() into HUMAN_, to recno() into HUMAN_2
// n_file := "test_ksg"+stxt
// fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
// go top
// do while !eof()
// @ maxrow(),0 say str(recno()/lastrec()*100,7,2)+"%" color cColorStMsg
// if inkey() == K_ESC
// exit
// endif
// if human->K_DATA > stod("20190930") .and. eq_any(human_->USL_OK,1,2)
// arr := definition_KSG()
// if len(arr) == 7 // диализ
// add_string("== диализ == ")
// else
// aeval(arr[1],{|x| add_string(x) })
// if !empty(arr[2])
// add_string("ОШИБКА:")
// aeval(arr[2],{|x| add_string(x) })
// endif
// select HU
// find (str(human->kod,7))
// do while hu->kod == human->kod .and. !eof()
// usl->(dbGoto(hu->u_kod))
// if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
// lshifr := usl->shifr
// endif
// if alltrim(lshifr) == arr[3] // уже стоит тот же КСГ
// if !(round(hu->u_cena,2) == round(arr[4],2)) // не та цена
// add_string("в л/у для КСГ="+arr[3]+" стоит цена "+lstr(hu->u_cena,10,2)+", а должна быть "+lstr(arr[4],10,2))
// if human->schet > 0
// schet_->(dbGoto(human->schet))
// add_string("..счёт № "+alltrim(schet_->nschet)+" от "+date_8(schet_->dschet)+"г.")
// endif
// endif
// exit
// endif
// select LUSL
// find (lshifr) // длина lshifr 10 знаков
// if found() .and. (eq_any(left(lshifr,5),"1.12.") .or. is_ksg(lusl->shifr)) // стоит другой КСГ
// add_string("в л/у стоит КСГ="+alltrim(lshifr)+"("+lstr(hu->u_cena,10,2)+;
// "), а должна быть "+arr[3]+"("+lstr(arr[4],10,2)+")")
// if human->schet > 0
// schet_->(dbGoto(human->schet))
// add_string("..счёт № "+alltrim(schet_->nschet)+" от "+date_8(schet_->dschet)+"г.")
// endif
// exit
// endif
// select HU
// skip
// enddo
// endif
// add_string(replicate("*",80))
// endif
// select HUMAN
// skip
// enddo
// close databases
// rest_box(buf)
// fclose(fp)
// return NIL
