// mo_func1.prg
#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 18.03.13 признак села
Function f_is_selo( _gorod_selo, _okatog )

  Local arr, ret := .f., fl := .f., tmp_select

  Default _gorod_selo To kart_->gorod_selo, _okatog To kart_->okatog
  If _gorod_selo == 2 // из картотеки
    fl := .t.  // нашли
    ret := .t.   // село
  Endif
  If !fl .and. !Empty( okato_rajon( _okatog, @arr ) )
    If arr[ 5 ] == 1 // город
      fl := .t.  // нашли
      ret := .f.   // город
    Endif
  Endif
  If !fl
    tmp_select := Select()
    r_use( dir_exe() + '_okatos', cur_dir() + '_okats', 'SELO' )
    find ( PadR( _okatog, 11, '0' ) )
    If Found()
      fl := .t.  // нашли
      ret := ( selo->selo == 0 )
    Endif
    Use
    If !fl
      r_use( dir_exe() + '_okatoo', cur_dir() + '_okato', 'OBLAST' )
      find ( PadR( _okatog, 5, '0' ) )
      If Found()
        fl := .t.  // нашли
        ret := ( oblast->selo == 0 )
      Endif
      Use
    Endif
    Select ( tmp_select )
  Endif
  If !fl
  Endif

  Return ret

// вернуть город/область/иногородний
Function okato_mi_git( _okato )

  Local s := ''

  If !Empty( _okato )
    If Left( _okato, 5 ) == '18401'
      s := 'г.Волгоград'
    Elseif Left( _okato, 2 ) == '18'
      s := 'Волгоградская обл.'
    Else
      s := 'иногородний'
    Endif
  Endif

  Return s

// вернуть район по ОКАТО
Function okato_rajon( tokato, /*@*/ret_arr)

  Static arr_rajon := { ;
    { 'Ворошиловский', 0, 11, '18401363', 1 }, ;
    { 'Дзержинский', 0, 12, '18401365', 1 }, ;
    { 'Кировский', 0, 13, '18401370', 1 }, ;
    { 'Красноармейский', 0, 14, '18401375', 1 }, ;
    { 'Краснооктябрьский', 0, 15, '18401380', 1 }, ;
    { 'Советский', 0, 16, '18401385', 1 }, ;
    { 'Тракторозаводской', 0, 17, '18401390', 1 }, ;
    { 'Центральный', 0, 18, '18401395', 1 }, ;
    { 'г.Камышин', 1, 21, '18415000', 1 }, ;
    { 'г.Михайловка', 1, 22, '18420000', 1 }, ;
    { 'г.Урюпинск', 1, 23, '18425000', 1 }, ;
    { 'г.Фролово', 1, 24, '18428000', 1 }, ;
    { 'г.Волжский', 1, 25, '18410000', 1 }, ;
    { 'Алексеевский', 1, 30, '18202000', 2 }, ;
    { 'Быковский', 1, 31, '18204000', 2 }, ;
    { 'Городищенский', 1, 32, '18205000', 2 }, ;
    { 'Даниловский', 1, 33, '18206000', 2 }, ;
    { 'Дубовский', 1, 34, '18208000', 2 }, ;
    { 'Еланский', 1, 35, '18210000', 2 }, ;
    { 'Жирновский', 1, 36, '18212000', 2 }, ;
    { 'Иловлинский', 1, 37, '18214000', 2 }, ;
    { 'Калачевский', 1, 38, '18216000', 2 }, ;
    { 'Камышинский', 1, 39, '18218000', 2 }, ;
    { 'Киквидзенский', 1, 40, '18220000', 2 }, ;
    { 'Клетский', 1, 41, '18222000', 2 }, ;
    { 'Котельниковский', 1, 42, '18224000', 2 }, ;
    { 'Котовский', 1, 43, '18226000', 2 }, ;
    { 'Ленинский', 1, 44, '18230000', 2 }, ;
    { 'Михайловский', 1, 45, '18232000', 2 }, ;
    { 'Нехаевский', 1, 46, '18234000', 2 }, ;
    { 'Николаевский', 1, 47, '18236000', 2 }, ;
    { 'Новоаннинский', 1, 48, '18238000', 2 }, ;
    { 'Новониколаевский', 1, 49, '18240000', 2 }, ;
    { 'Октябрьский', 1, 50, '18242000', 2 }, ;
    { 'Ольховский', 1, 51, '18243000', 2 }, ;
    { 'Палласовский', 1, 52, '18245000', 2 }, ;
    { 'Кумылженский', 1, 53, '18246000', 2 }, ;
    { 'Руднянский', 1, 54, '18247000', 2 }, ;
    { 'Светлоярский', 1, 55, '18249000', 2 }, ;
    { 'Серафимовический', 1, 56, '18250000', 2 }, ;
    { 'Среднеахтубинский', 1, 57, '18251000', 2 }, ;
    { 'Старополтавский', 1, 58, '18252000', 2 }, ;
    { 'Суровикинский', 1, 59, '18253000', 2 }, ;
    { 'Урюпинский', 1, 60, '18254000', 2 }, ;
    { 'Фроловский', 1, 61, '18256000', 2 }, ;
    { 'Чернышковский', 1, 62, '18258000', 2 } ;
    }
  Local t1okato := PadR( tokato, 8 ), vozvr := '', t1

  // сначала поиск по району г.Волгограда
  If ( t1 := AScan( arr_rajon, {| x| PadR( x[ 4 ], 8 ) == t1okato } ) ) > 0
    vozvr := arr_rajon[ t1, 1 ]
    ret_arr := arr_rajon[ t1 ]
  Else // теперь по району области
    t1okato := PadR( tokato, 5 )
    If ( t1 := AScan( arr_rajon, {| x| PadR( x[ 4 ], 5 ) == t1okato } ) ) > 0
      vozvr := arr_rajon[ t1, 1 ]
      ret_arr := arr_rajon[ t1 ]
    Endif
  Endif

  Return vozvr

// 16.01.19 необходимо ли вывести характер заболевания в реестр
Function need_reestr_c_zab( lUSL_OK, osn_diag )

  Local fl := .f.

  If lUSL_OK < 4
    If lUSL_OK == 3 .and. !( Left( osn_diag, 1 ) == 'Z' )
      fl := .t. // условия оказания <амбулаторно> (USL_OK=3) и основной диагноз не из группы Z00-Z99
    Elseif is_oncology == 2
      fl := .t. // при установленном ЗНО
    Endif
  Endif

  Return fl

// работает хотя бы одно учреждение с талоном
Function ret_is_talon()

  Local is_talon := .f., tmp_select := Select()

  r_use( dir_server() + 'mo_uch', , '_UCH' )
  Go Top
  Do While !Eof()
    If between_date( _uch->dbegin, _uch->dend, sys_date ) .and. _uch->IS_TALON == 1
      is_talon := .t.
      Exit
    Endif
    Skip
  Enddo
  _uch->( dbCloseArea() )
  Select ( tmp_select )

  Return is_talon

// ввод шифра услуги
Function valid_shifr()

  Private tmp := ReadVar()

  &tmp := transform_shifr( &tmp )

  Return .t.

// 15.01.19 трансформирование шифра услуги (запятую на точку, посл.точку убрать)
Function transform_shifr( s )

  Local n := Len( s )  // длина поля может быть 10 или 15 символов

  s := delendsymb( CharRepl( ',', s, '.' ), '.' ) // запятую - на точку и удалить последнюю точку
  // русскую букву А,В
  If eq_any( Left( s, 1 ), 'А', 'В' ) .and. SubStr( s, 4, 1 ) == '.' ;
      .and. Empty( CharRepl( '0123456789', SubStr( s, 2, 2 ), Space( 10 ) ) )
    s := iif( Left( s, 1 ) == 'А', 'A', 'B' ) + SubStr( s, 2 )  // заменим на английскую A,B
  Elseif eq_any( Upper( Left( s, 2 ) ), 'ST', 'DS' )
    s := Lower( s )
  Endif

  Return PadR( s, n )

// 28.05.19 удалить все спецсимволы из строки и оставить по одному пробелу
Function del_spec_symbol( s )

  Local i, c, s1 := ''

  For i := 1 To Len( s )
    c := SubStr( s, i, 1 )
    If Asc( c ) == 255
      c := ' '
    Endif // меняем на пробел
    If Asc( c ) >= 32
      s1 += c
    Endif
  Next

  Return CharOne( ' ', s1 )

// подставить впереди строки какое-то кол-во пробелов
Function st_nom_stroke( lstroke )

  Local i, r := 0

  lstroke := AllTrim( lstroke )
  For i := 1 To Len( lstroke )
    If '.' == SubStr( lstroke, i, 1 )
      ++r
    Endif
  Next
  If r == 1 .and. Right( lstroke, 2 ) == '.0'
    r := 0
  Endif

  Return Space( r * 2 )

//
Function a2default( arr, name, sDefault )

  // arr - двумерный массив
  // name - поиск по имени первого элемента
  // sDefault - значение по умолчанию для второго элемента
  Local s := '', i

  If ValType( sDefault ) == 'C'
    s := sDefault
  Endif
  If ( i := AScan( arr, {| x| Upper( x[ 1 ] ) == Upper( name ) } ) ) > 0
    s := arr[ i, 2 ]
  Endif

  Return s

//
Function uk_arr_dni( nKey )

  Local buf := SaveScreen(), arr, d, mtitle, ldate := tmp->date_u1 + 1, ;
    tmp_color := SetColor(), arr1, r

  If eq_any( nkey, K_F4, K_F5 )
    mtitle := 'Копирование услуги ' + AllTrim( tmp->shifr_u ) + ' от ' + date_8( tmp->date_u1 ) + 'г.'
  Else
    mtitle := 'Копирование всех услуг, оказанных ' + date_8( tmp->date_u1 ) + 'г.'
  Endif
  SetColor( color0 + ', , , N/W' )
  If nKey == K_F4
    If ldate > human->k_data
      ldate := human->k_data
    Endif
    box_shadow( 18, 5, 21, 74, color0 )
    @ 19, 6 Say PadC( mtitle, 68 )
    @ 20, 18 Say 'Введите, дату для новой услуги' Get ldate ;
      valid {|| Between( ldate, human->n_data, human->k_data ) }
    myread()
    If LastKey() != K_ESC
      arr := { { date_8( ldate ), ldate } }
    Endif
  Else
    Private mdni := 1, mdate := human->k_data
    If ldate < mdate
      mdni := mdate - ldate + 1
    Endif
    box_shadow( 18, 5, 21, 74, color0, mtitle, 'B/BG' )
    status_key( '^<Esc>^ - отказ;  ^<PgDn>^ - копировать строки' )
    Do While .t.
      @ 19, 9 Say 'Введите, сколько еще копий необходимо сделать' Get mdni Pict '99' ;
        valid {|| mdate := ldate + mdni -1, .t. }
      @ 20, 9 Say 'Введите, по какую дату (включительно) копировать' Get mdate ;
        valid {|| mdni := mdate - ldate + 1, .t. }
      myread()
      If LastKey() == K_ESC
        Exit
      Elseif LastKey() == K_PGDN
        If mdate >= ldate
          arr1 := {}
          For d := ldate To mdate
            AAdd( arr1, { date_8( d ), d } )
          Next
          If ( r := 21 - Len( arr1 ) ) < 2
            r := 2
          Endif
          arr := bit_popup( r, 63, arr1, , color5 )
        Endif
        Exit
      Endif
    Enddo
  Endif
  RestScreen( buf )
  SetColor( tmp_color )

  Return arr

//
Function put_otch_period( full_year )

  Local n := 5, s := StrZero( schet_->nyear, 4 )

  Default full_year To .f.
  If full_year
    n += 2
  Else
    s := Right( s, 2 )
  Endif
  s += '/' + StrZero( schet_->nmonth, 2 )
  If emptyany( schet_->nyear, schet_->nmonth )
    s := Space( n )
  Endif

  Return s

// возврат даты регистрации счёта
Function date_reg_schet()

  // если нет даты регистрации, берём дату счёта

  Return iif( Empty( schet_->dregistr ), schet_->dschet, schet_->dregistr )

// 01.03.23
Function ret_vid_pom( k, mshifr, lk_data )

  Local svp, vp := 0, lal := 'lusl'
  Local y := WORK_YEAR

  If ValType( lk_data ) == 'D'
    y := Year( lk_data )
  Endif
  If Select( 'LUSL' ) == 0
    use_base( 'lusl' )
  Endif
  lal := create_name_alias( lal, y )
  dbSelectArea( lal )
  find ( PadR( mshifr, 10 ) )
  If Found()
    svp := AllTrim( &lal.->VMP_F )
    If Empty( svp )
      vp := 0
    Elseif k == 1
      vp := Int( Val( svp ) )
    Else
      vp := 1
      If svp == '2'
        vp := 2
      Elseif '3' $ svp
        vp := 3
      Endif
    Endif
  Endif
  Return vp

//
Function get_k_usluga( lshifr, lvzros_reb, lvr_as )

  Local i, buf := save_maxrow(), lu_cena, lis_nul, v, fl, arr_k_usl := {}, fl_oms

  mywait()
  lshifr := PadR( lshifr, 10 )
  lvr_as := .f.
  pr_k_usl := {}
  If !is_open_u1
    g_use( dir_server() + 'uslugi1k', dir_server() + 'uslugi1k', 'U1K' )
    g_use( dir_server() + 'uslugi_k', dir_server() + 'uslugi_k', 'UK' )
    is_open_u1 := .t.
  Endif
  Select UK
  find ( lshifr )
  If Found()
    Select U1K
    find ( uk->shifr )
    Do While u1k->shifr == uk->shifr .and. !Eof()
      AAdd( arr_k_usl, { u1k->shifr1, ;
        .f., ;  // 2 все ли корректно ?
      0, ;    // 3 код услуги
      '', ;   // 4 наименование услуги
      0, ;    // 5 цена
      0, ;    // 6 коэффициент
      0, ;    // 7 %% понижения цены
      '', ;   // 8 shifr1
      .f., ;  // 9 is_nul
      .f. } )  // 10 is_oms
      Skip
    Enddo
    For i := 1 To Len( arr_k_usl )
      fl := .f.
      fl_oms := .f.
      Select USL
      Set Order To 1
      find ( arr_k_usl[ i, 1 ] )
      If Found()
        fl := .t.
        lu_cena := 0
        If glob_task == X_PLATN  // для платных услуг
          lu_cena := if( lvzros_reb == 0, usl->pcena, usl->pcena_d )
          If human->tip_usl == PU_D_SMO .and. usl->dms_cena > 0
            lu_cena := usl->dms_cena
          Endif
          lis_nul := usl->is_nulp
        Elseif glob_task == X_KASSA  // для lpukassa.exe
          v := cenausldate( human->k_data, usl->kod )
          lu_cena := if( lvzros_reb == 0, v[ 1 ], v[ 2 ] )
          lis_nul := .f.
        Else  // для ОМС услуг
          lu_cena := if( lvzros_reb == 0, usl->cena, usl->cena_d )
          If ( v := f1cena_oms( usl->shifr, ;
              opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ), ;
              ( lvzros_reb == 0 ), ;
              human->k_data, ;
              usl->is_nul, ;
              @fl_oms ) ) != NIL
            lu_cena := v
          Endif
          lis_nul := usl->is_nul
        Endif
        If Empty( lu_cena ) .and. !lis_nul
          fl := func_error( 1, 'В услуге ' + AllTrim( arr_k_usl[ i, 1 ] ) + ' не проставлена цена!' )
        Else
          Select UO
          find ( Str( usl->kod, 4 ) )
          If Found() .and. glob_task != X_KASSA .and. !( Chr( m1otd ) $ uo->otdel )
            fl := func_error( 1, 'Услугу ' + AllTrim( arr_k_usl[ i, 1 ] ) + ' запрещено вводить в данном отделении!' )
          Else
            Select USL
            arr_k_usl[ i, 3 ] := usl->kod
            arr_k_usl[ i, 4 ] := usl->name
            arr_k_usl[ i, 5 ] := iif( lis_nul, 0, lu_cena )
            arr_k_usl[ i, 6 ] := 1
            arr_k_usl[ i, 8 ] := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            arr_k_usl[ i, 9 ] := lis_nul
            arr_k_usl[ i, 10 ] := fl_oms
          Endif
        Endif
      Endif
      arr_k_usl[ i, 2 ] := fl
    Next
    For i := 1 To Len( arr_k_usl )
      If arr_k_usl[ i, 2 ]
        AAdd( pr_k_usl, AClone( arr_k_usl[ i ] ) )
      Endif
    Next
    If Len( pr_k_usl ) > 0
      mname_u := uk->name
      If !emptyall( uk->kod_vr, uk->kod_as )
        lvr_as := .t.
        mkod_vr := uk->kod_vr
        mkod_as := uk->kod_as
      Endif
    Endif
  Endif
  rest_box( buf )

  Return ( Len( pr_k_usl ) > 0 )

//
Function cenausldate( ldate, lkod )

  Local tmp_select := Select(), rec_pud, rec_puc, arr := { 0, 0, 0 }

  rec_pud := pud->( RecNo() )
  rec_puc := puc->( RecNo() )
  Select PUD
  dbSeek( DToS( ldate ), .t. )
  Do While !Eof()
    Select PUC
    find ( Str( pud->( RecNo() ), 4 ) + Str( lkod, 4 ) )
    If Found() .and. !emptyall( puc->pcena, puc->pcena_d, puc->dms_cena )
      arr := { puc->pcena, puc->pcena_d, puc->dms_cena }
      Exit
    Endif
    Select PUD
    Skip
  Enddo
  If emptyall( arr[ 1 ], arr[ 2 ], arr[ 3 ] )
    usl->( dbGoto( lkod ) )
    arr := { usl->pcena, usl->pcena_d, usl->dms_cena }
  Endif
  pud->( dbGoto( rec_pud ) )
  puc->( dbGoto( rec_puc ) )
  Select ( tmp_select )

  Return arr

//
Function get_otd( mkod, r, c, fl_usl )

  Local k2, fl := .f., buf, r1, r2, c2, delta, mtitle, ;
    i, a_uch := {}, kol_uch := 1

  Default fl_usl To .f.
  If Len( pr_arr ) == 0
    Return Nil
  Endif
  If mkod == 0
    mkod := glob_otd[ 1 ]
  Endif
  k2 := AScan( pr_arr, {| x| x[ 1 ] == mkod } )
  If Len( pr_arr[ 1 ] ) > 2
    For i := 1 To Len( pr_arr )
      If AScan( a_uch, pr_arr[ i, 3 ] ) == 0
        AAdd( a_uch, pr_arr[ i, 3 ] )
      Endif
    Next
    kol_uch := Len( a_uch )
  Endif
  If r > MaxRow() -9
    r2 := r -2
    If ( r1 := r2 - Len( pr_arr ) -1 ) < 2
      r1 := 2
    Endif
  Else
    r1 := r
    If ( r2 := r + Len( pr_arr ) + 1 ) > MaxRow() -2
      r2 := MaxRow() -2
    Endif
  Endif
  delta := iif( kol_uch > 1, 41, 33 )
  mtitle := iif( kol_uch > 1, 'Выбор отделения', AllTrim( glob_uch[ 2 ] ) )
  c2 := c + delta
  If c2 > MaxCol() -2
    c2 := MaxCol() -2
    c := c2 - delta
  Endif
  buf := SaveScreen( r1, 0, MaxRow(), MaxCol() )
  status_key( '^<Esc>^ - выход без выбора;  ^<Enter>^ - выбор отделения' )
  If ( k2 := Popup( r1, c, r2, c2, pr_arr_otd, k2, color0, .t., , , mtitle, col_tit_popup ) ) > 0
    fl := .t.
    If fl_usl .and. mu_kod > 0
      Select UO
      find ( Str( mu_kod, 4 ) )
      If Found() .and. !( Chr( pr_arr[ k2, 1 ] ) $ uo->otdel )
        fl := func_error( 4, 'Данную услугу запрещено вводить в данном отделении!' )
      Endif
    Endif
    If fl
      glob_otd := { pr_arr[ k2, 1 ], pr_arr[ k2, 2 ] }
      // glob_otd := { pr_arr[k2, 1], pr_arr_otd[k2] }
    Endif
  Endif
  RestScreen( r1, 0, MaxRow(), MaxCol(), buf )

  Return if( fl, glob_otd, NIL )

//
Function get1_otd( _1, _2, _3, _r, _c )

  Local fl

  If get_otd( m1otd, _r + 1, _c ) != NIL
    fl := .t.
    If Type( 'mu_kod' ) == 'N' .and. mu_kod > 0
      Select UO
      find ( Str( mu_kod, 4 ) )
      If Found() .and. !( Chr( glob_otd[ 1 ] ) $ uo->otdel )
        fl := func_error( 4, 'Данную услугу запрещено вводить в данном отделении!' )
      Endif
    Endif
    If fl
      m1otd := glob_otd[ 1 ]
      motd := glob_otd[ 2 ]
      update_get( 'm1otd' )
      update_get( 'motd' )
      Keyboard Chr( K_DOWN )
    Endif
  Endif
  SetCursor()

  Return Nil

// сохранить учреждение и отделение
Function saveuchotd()

  Local arr[ 2 ]

  arr[ 1 ] := AClone( glob_uch )
  arr[ 2 ] := AClone( glob_otd )

  Return arr

// восстановить учреждение и отделение
Function restuchotd( arr )

  glob_uch := AClone( arr[ 1 ] )
  glob_otd := AClone( arr[ 2 ] )

  Return Nil

// 09.08.16 определить врача по табельному номеру при вводе листа учета, услуги,...
Function v_kart_vrach( get, is_prvs )

  Local fl := .t., tmp_select

  Private tmp := ReadVar()

  if &tmp != get:original
    if &tmp == 0
      m1vrach := 0
      mvrach := Space( 30 )
      m1prvs := 0
    elseif &tmp != 0
      Default is_prvs To .f.
      tmp_select := Select()
      r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'P2' )
      find ( Str( &tmp, 5 ) )
      If Found()
        m1vrach := p2->kod
        m1prvs := -ret_new_spec( p2->prvs, p2->prvs_new )
        If is_prvs
//          mvrach := PadR( fam_i_o( p2->fio ) + ' ' + ret_tmp_prvs( m1prvs ), 36 )
          mvrach := PadR( fam_i_o( p2->fio ) + ' ' + ret_str_spec( p2->PRVS_021 ), 36 )
        Else
          mvrach := PadR( fam_i_o( p2->fio ), 30 )
        Endif
      Else
        fl := func_error( 3, 'Не найден сотрудник с табельным номером ' + lstr( &tmp ) + ' в справочнике персонала!' )
      Endif
      p2->( dbCloseArea() )
      Select ( tmp_select )
    Endif
    If !fl
      &tmp := get:original
      Return .f.
    Endif
    update_get( 'mvrach' )
  Endif

  Return .t.

// перечитать код МО по ТФОМС и сохранить в glob_MO
Function reread_glob_mo()

  Local i, cCode, tmp_select := Select()

  r_use( dir_server() + 'organiz', , 'ORG' )
  cCode := Left( org->kod_tfoms, 6 )
  ORG->( dbCloseArea() )
  If ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == cCode } ) ) > 0
    glob_mo := glob_arr_mo()[ i ]
  Endif
  Select ( tmp_select )

  Return Nil

// 28.12.21 проверка правильности ввода сроков лечения
Function f_k_data( get, k )

  // k = 1 - дата начала лечения
  // k = 2 - дата окончания лечения

  If k == 1 .and. Year( mn_data ) < 2015
    mn_data := get:original
    Return func_error( 3, 'В дате начала лечения неверно введен год (ранее 2015 года).' )
  Endif

  If k == 2 .and. Empty( mk_data )
    mk_data := get:original
    Return func_error( 3, 'Не введена дата окончания лечения.' )
  Endif
  If k == 2 .and. ;
      !( Year( mk_data ) == Year( sys_date ) .or. Year( mk_data ) == Year( sys_date ) -1 )
    mk_data := get:original
    Return func_error( 3, 'В дате окончания лечения неверно введен год.' )
  Endif
  If !Empty( mk_data ) .and. mn_data > mk_data
    If k == 1
      mn_data := get:original
    Else
      mk_data := get:original
    Endif
    Return func_error( 4, 'Дата начала лечения больше даты окончания лечения. Ошибка!' )
  Endif
  If k == 1 .and. Type( 'mdate_r' ) == 'D'
    fv_date_r( mn_data )
  Endif

  Return .t.

// 17.01.14 переопределение критерия 'взрослый/ребёнок' по дате рождения и '_date'
Function fv_date_r( _data, fl_end )

  Local k, fl, cy, ldate_r := mdate_r

  Default _data To sys_date, fl_end To .t.
  If Type( 'M1NOVOR' ) == 'N' .and. M1NOVOR == 1 .and. Type( 'mdate_r2' ) == 'D'
    ldate_r := mdate_r2
    k := 1
  Endif
  mvozrast := cy := count_years( ldate_r, _data )
  mdvozrast := Year( _data ) - Year( ldate_r )
  If k == NIL
    If cy < 14     ; k := 1  // ребенок
    Elseif cy < 18 ; k := 2  // подросток
    else           ; k := 0  // взрослый
    Endif
  Endif
  If Type( 'm1vzros_reb' ) == 'N' .and. m1vzros_reb != k
    m1vzros_reb := k
    mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
    update_get( 'mvzros_reb' )
  Endif
  If fl_end
    If Type( 'M1RAB_NERAB' ) == 'N' .and. m1vzros_reb == 1 .and. M1RAB_NERAB == 0
      M1RAB_NERAB := 1
      mrab_nerab := inieditspr( A__MENUVERT, menu_rab, m1rab_nerab )
      update_get( 'mrab_nerab' )
    Endif
    If Type( 'm1vid_ud' ) == 'N' .and. Empty( m1vid_ud )
      m1vid_ud := iif( k == 1, 3, 14 )
    Endif
  Endif

  Return .t.


// 14.01.17 ничего не делает в GET'е
Function get_without_input( oGet, nKey )

  If Between( nKey, 32, 255 ) .or. nKey == K_DEL
    oGet:Right()  // сместиться вправо
    If ( oGet:typeOut )
      If ( Set( _SET_BELL ) )
        ?? Chr( 7 )
      Endif
      If ( !Set( _SET_CONFIRM ) )
        oGet:exitState := GE_ENTER
      Endif
    Endif
  Endif

  Return Nil


// 09.02.14 функция сортировки номера счёта (для команды INDEX)
Function fsort_schet( s1, s2 )

  Static cDelimiter := '-'
  Local s

  If Empty( s1 )
    s := Str( Val( AllTrim( s2 ) ), 13 )
  Else
    s1 := AllTrim( s1 )
    s := PadL( AllTrim( Token( s1, cDelimiter, 2 ) ), 6, '0' ) + ;
      PadR( AllTrim( Token( s1, cDelimiter, 3 ) ), 2 ) + ;
      PadR( AllTrim( Token( s1, cDelimiter, 1 ) ), 5, '9' )
  Endif

  Return s

// 15.01.14 функция сортировки шифров услуг по возрастанию (для команды INDEX)
Function fsort_usl( sh_u )

  Static _sg := 5
  Local i, s := '', flag_z := .f., flag_0 := .f., arr

  If Left( sh_u, 1 ) == '*'
    flag_z := .t.
  Elseif Left( sh_u, 1 ) == '0'
    flag_0 := .t.
  Endif
  arr := usl2arr( sh_u )
  For i := 1 To Len( arr )
    If i == 2 .and. flag_z
      s += '9' + StrZero( arr[ i ], _sg )  // для удаленной услуги
    Elseif i == 1 .and. flag_0
      s += ' ' + StrZero( arr[ i ], _sg )  // если впереди стоит 0
    Else
      s += StrZero( arr[ i ], 1 + _sg )
    Endif
  Next

  Return s

// 15.01.19 превратить шифр услуги в 5-мерный числовой массив
Function usl2arr( sh_u, /*@*/j)

  Local i, k, c, ascc, arr := {}, cDelimiter := '.', s := AllTrim( sh_u ), ;
    s1 := '', is_all_digit := .t.

  If Left( s, 1 ) == '*'
    s := SubStr( s, 2 )
  Endif
  For i := 1 To Len( s )
    c := SubStr( s, i, 1 )
    ascc := Asc( c )
    If Between( ascc, 48, 57 ) // цифры
      s1 += c
    Elseif isletter( c ) // буквы
      is_all_digit := .f.
      If Len( s1 ) > 0 .and. Right( s1, 1 ) != cDelimiter
        s1 += cDelimiter // искусственно вставим разделитель
      Endif
      s1 += lstr( ascc )
    Else // любой разделитель
      is_all_digit := .f.
      s1 += cDelimiter
    Endif
  Next
  If is_all_digit .and. eq_any( ( k := Len( s1 ) ), 8, 7 )  // КСГ
    If k == 8
      AAdd( arr, Int( Val( SubStr( s1, 1, 1 ) ) ) )
      AAdd( arr, Int( Val( SubStr( s1, 2, 1 ) ) ) )
      AAdd( arr, Int( Val( SubStr( s1, 3, 1 ) ) ) )
      AAdd( arr, Int( Val( SubStr( s1, 6, 3 ) ) ) )
      AAdd( arr, Int( Val( SubStr( s1, 4, 1 ) ) ) )
    Else
      AAdd( arr, Int( Val( SubStr( s1, 1, 1 ) ) ) )
      AAdd( arr, Int( Val( SubStr( s1, 2, 1 ) ) ) )
      AAdd( arr, Int( Val( SubStr( s1, 3, 1 ) ) ) )
      AAdd( arr, Int( Val( SubStr( s1, 5, 3 ) ) ) )
      AAdd( arr, Int( Val( SubStr( s1, 4, 1 ) ) ) )
    Endif
  Else // остальные услуги
    k := NumToken( AllTrim( s1 ), cDelimiter )
    For i := 1 To k
      j := Int( Val( Token( s1, cDelimiter, i ) ) )
      AAdd( arr, j )
    Next
    If ( j := Len( arr ) ) < 5
      For i := j + 1 To 5
        AAdd( arr, 0 )
      Next
    Endif
  Endif

  Return arr

// 05.03.24 ф-ия between для шифров услуг
Function between_shifr( lshifr, lshifr1, lshifr2 )

  Local fl := .f., k, k1, k2, v, v1, v2

  lshifr  := AllTrim( lshifr )
  lshifr1 := AllTrim( lshifr1 )
  lshifr2 := AllTrim( lshifr2 )
  If Len( lshifr ) == Len( lshifr1 ) .and. Len( lshifr ) == Len( lshifr2 )
    fl := Between( lshifr, lshifr1, lshifr2 )
  Else // для варианта between_shifr(_shifr, '2.88.52', '2.88.103')
    k := RAt( '.', lshifr )
    k1 := RAt( '.', lshifr1 )
    k2 := RAt( '.', lshifr2 )
    If Left( lshifr, k ) == Left( lshifr1, k1 ) .and. k == k1 .and. k1 == k2
      v := Int( Val( SubStr( lshifr, k + 1 ) ) )
      v1 := Int( Val( SubStr( lshifr1, k1 + 1 ) ) )
      v2 := Int( Val( SubStr( lshifr2, k2 + 1 ) ) )
      fl := Between( v, v1, v2 )
    Endif
  Endif

  Return fl

// 03.01.19 является ли шифр услуги кодом КСГ
Function is_ksg( lshifr, k )

  // k = nil - любая КСГ
  // k = 1 - стационар
  // k = 2 - дневной стационар
  Static ss := '0123456789'
  Local i, fl := .f.

  lshifr := AllTrim( lshifr )
  If Left( lshifr, 2 ) == 'st'
    If ValType( k ) == 'N'
      fl := ( Int( k ) == 1 )
    Else
      fl := .t.
    Endif
  Elseif Left( lshifr, 2 ) == 'ds'
    If ValType( k ) == 'N'
      fl := ( Int( k ) == 2 )
    Else
      fl := .t.
    Endif
  Endif
  If fl
    Return fl // для 2019 года
  Endif
  If Left( lshifr, 1 ) $ '12' .and. SubStr( lshifr, 5, 1 ) == '.' .and. Len( lshifr ) == 6 // 18 год
    fl := .t.
    For i := 2 To 6
      If i == 5
        Loop
      Elseif !( SubStr( lshifr, i, 1 ) $ ss )
        fl := .f.
        Exit
      Endif
    Next
  Elseif !( '.' $ lshifr ) .and. eq_any( Len( lshifr ), 8, 7 ) // КСГ за прошлые годы
    fl := Empty( CharRepl( ss, lshifr, Space( 10 ) ) )
  Endif
  If fl .and. ValType( k ) == 'N'
    fl := ( Left( lshifr, 1 ) == lstr( k ) )
  Endif

  Return fl

// исправление введённого полиса
Function val_polis( s )

  Local fl := .t., i, c, s1 := ''

  s := AllTrim( s )
  For i := 1 To Len( s )
    c := SubStr( s, i, 1 )
    If Between( c, '0', '9' ) .or. IsAlpha( c ) .or. c $ ' -'
      s1 += c
    Endif
  Next

  Return LTrim( CharOne( ' ', s1 ) )

// вернуть имя файла без пути и расширения
Function name_without_ext( cFile )

  Local cName

  // LOCAL cPath, cName, cExt, cDrive
  // IF hb_FileExists( cFile )
  // HB_FNameSplit( cFile, @cPath, @cName, @cExt, @cDrive )
  // ENDIF
  hb_FNameSplit( cFile, , @cName )

  Return cName

// вернуть расширение файла
Function name_extention( cFile )

  Local cExt

  // LOCAL cPath, cName, cExt, cDrive
  // IF hb_FileExists( cFile )
  // HB_FNameSplit( cFile, @cPath, @cName, @cExt, @cDrive )
  // ENDIF
  hb_FNameSplit( cFile, , , @cExt )

  Return cExt

// перевод левого верхнего угла прямоугольника из координат 25х80 в 'maxrow(maxcol)'
Function get_row_col_max( r, c, /*@*/r1, /*@*/c1, /*@*/r2, /*@*/c2)

  Local d := 24 - r

  r1 := MaxRow() - d
  r2 := r1 + 2
  d := Int( 79 -2 * c )
  c1 := Int( ( MaxCol() - d ) / 2 )
  c2 := c1 + d

  Return Nil

// проверить дату и время на правильность периода
Function v_date_time( date1, time1, date2, time2 )

  Local fl := .t.

  If date1 > date2
    fl := func_error( 4, 'Начальная дата больше конечной!' )
  Elseif date1 == date2 .and. time1 > time2
    fl := func_error( 4, 'Начальное время больше конечного!' )
  Endif

  Return fl

//
Function between_time( _mdate, _mtime, date1, time1, date2, time2 )

  // _mdate,_mtime - проверяемое время
  // date1,time1,date2,time2 - проверяемый период
  Local fl

  Default time1 To '00:00', time2 To '24:00'
  If ( fl := Between( _mdate, date1, date2 ) )
    If _mdate == date1 .and. _mdate == date2
      fl := ( f_time( _mtime ) >= f_time( time1 ) .and. f_time( _mtime ) <= f_time( time2 ) )
    Elseif _mdate == date1
      fl := ( f_time( _mtime ) >= f_time( time1 ) )
    Elseif _mdate == date2
      fl := ( f_time( _mtime ) <= f_time( time2 ) )
    Endif
  Endif

  Return fl

//
Static Function f_time( t )
  Return round_5( Val( SubStr( t, 1, 2 ) ) + Val( SubStr( t, 4, 2 ) ) / 60, 5 )

// вернуть УЕТ по дате оказания услуги
Function opr_uet( lvzros_reb, k )

  Local muet, mvkoef_v, makoef_v, mvkoef_r, makoef_r, mkoef_v, mkoef_r, mdate, arr, i

  Default k To 0
  Store 0 To muet, mvkoef_v, makoef_v, mvkoef_r, makoef_r, mkoef_v, mkoef_r
  If Select( 'UU' ) == 0
    useuch_usl()
  Endif
  Select UU
  find ( Str( hu->u_kod, 4 ) )
  If Found()
    mvkoef_v := uu->vkoef_v // врач - УЕТ для взрослого
    makoef_v := uu->akoef_v // асс. - УЕТ для взрослого
    mvkoef_r := uu->vkoef_r // врач - УЕТ для ребенка
    makoef_r := uu->akoef_r // асс. - УЕТ для ребенка
    mkoef_v  := uu->koef_v  // итого УЕТ для взрослого
    mkoef_r  := uu->koef_r  // итого УЕТ для ребенка
    //
    mdate := c4tod( hu->date_u )
    arr := {}
    Select UU1
    find ( Str( hu->u_kod, 4 ) )
    Do While uu1->kod == hu->u_kod .and. !Eof()
      AAdd( arr, { uu1->date_b, uu1->( RecNo() ) } )
      Skip
    Enddo
    If Len( arr ) > 0
      ASort( arr, , , {| x, y| x[ 1 ] >= y[ 1 ] } )
      For i := 1 To Len( arr )
        If mdate >= arr[ i, 1 ]
          Goto ( arr[ i, 2 ] )
          mvkoef_v := uu1->vkoef_v // врач - УЕТ для взрослого
          makoef_v := uu1->akoef_v // асс. - УЕТ для взрослого
          mvkoef_r := uu1->vkoef_r // врач - УЕТ для ребенка
          makoef_r := uu1->akoef_r // асс. - УЕТ для ребенка
          mkoef_v  := uu1->koef_v  // итого УЕТ для взрослого
          mkoef_r  := uu1->koef_r  // итого УЕТ для ребенка
          Exit
        Endif
      Next
    Endif
  Endif
  If lvzros_reb == 0
    Do Case
    Case k == 0
      muet := iif( Empty( mkoef_v ), mkoef_r, mkoef_v )
    Case k == 1
      muet := iif( Empty( mvkoef_v ), mvkoef_r, mvkoef_v )
    Case k == 2
      muet := iif( Empty( makoef_v ), makoef_r, makoef_v )
    Endcase
  Else
    Do Case
    Case k == 0
      muet := iif( Empty( mkoef_r ), mkoef_v, mkoef_r )
    Case k == 1
      muet := iif( Empty( mvkoef_r ), mvkoef_v, mvkoef_r )
    Case k == 2
      muet := iif( Empty( makoef_r ), makoef_v, makoef_r )
    Endcase
  Endif

  Return muet

// вернуть шифр ТФОМС по дате окончания лечения
Function opr_shifr_tfoms( lshifr, lkod, ldate )

  Local tmp_select := Select()

  Default ldate To sys_date
  If Select( 'USL1' ) == 0
    r_use( dir_server() + 'uslugi1', { dir_server() + 'uslugi1', ;
      dir_server() + 'uslugi1s' }, 'USL1' )
  Endif
  Select USL1
  Set Order To 1
  find ( Str( lkod, 4 ) )
  If Found()
    lshifr := Space( 10 )
    Do While usl1->kod == lkod .and. !Eof()
      If usl1->date_b > ldate
        Exit
      Endif
      lshifr := usl1->shifr1
      Skip
    Enddo
  Endif
  Select ( tmp_select )

  Return lshifr

// 31.12.17 найти услугу по шифру ТФОМС в нашем справочнике услуг
Function foundourusluga( lshifr, ldate, lprofil, lvzros_reb, /*@*/lu_cena, ipar, not_cycle)

  Local au := {}, s, v1, v2, mname := Space( 65 ), fl := .t., lu_kod

  Default ipar To 1, not_cycle To .t.
  lshifr := PadR( lshifr, 10 )
  Select LUSL
  find ( lshifr )
  If Found()
    mname := AllTrim( lusl->name )
    If Len( mname ) > 65 .and. eq_any( Left( lshifr, 2 ), '2.', '70', '72' )
      mname := Right( mname, 65 )
    Endif
  Endif
  If ipar == 1 // сначала проверим собственный шифр услуги, равный шифру ТФОМС
    Select USL
    Set Order To 2
    find ( lshifr )
    If Found()
      s := Space( 10 )
      Select USL1
      Set Order To 1
      find ( Str( usl->kod, 4 ) )
      If Found()
        Do While usl1->kod == usl->kod .and. !Eof()
          If usl1->date_b > ldate
            Exit
          Endif
          s := usl1->shifr1
          Skip
        Enddo
      Endif
      If Empty( s ) .or. s == lshifr // поле 'шифр ТФОМС' пустое или равно 'lshifr'
        fl := .f.
      Endif
    Endif
    If fl // проверим тех, кто пользовался шифром ТФОМС
      Select USL1
      Set Order To 2
      find ( lshifr )
      Do While usl1->shifr1 == lshifr .and. !Eof()
        If usl1->date_b <= ldate
          AAdd( au, usl1->kod )
        Endif
        Skip
      Enddo
      Select USL1
      Set Order To 1
      For i := 1 To Len( au ) // цикл по кодам услуг, по которым стоит нужный шифр ТФОМС
        s := Space( 10 )
        find ( Str( au[ i ], 4 ) )
        Do While usl1->kod == au[ i ] .and. !Eof()
          If usl1->date_b > ldate
            Exit
          Endif
          s := usl1->shifr1
          Skip
        Enddo
        If s == lshifr
          usl->( dbGoto( au[ i ] ) )
          fl := .f.
          Exit
        Endif
      Next
    Endif
  Endif
  If fl
    v1 := v2 := 0 // если нет услуги в справочнике ТФОМС
    Select LUSL
    find ( PadR( lshifr, 10 ) )
    If Found()
      v1 := fcena_oms( lusl->shifr, .t., ldate )
      v2 := fcena_oms( lusl->shifr, .f., ldate )
    Endif
    Select USL
    If ipar == 1
      Set Order To 1
    Else
      Set Order To 2 // т.к. при вводе листа учёта индексы открыты наоборот
    Endif
    find ( Str( -1, 4 ) )
    If Found()
      g_rlock( forever )
    Else
      addrec( 4 )
    Endif
    usl->kod := RecNo()
    usl->name := mname
    usl->shifr := lshifr
    usl->PROFIL := lprofil
    usl->cena   := v1
    usl->cena_d := v2
    If not_cycle
      Unlock
    Endif
  Endif
  If Empty( usl->name ) .and. !Empty( mname )
    Select USL
    g_rlock( forever )
    usl->name := mname
    If not_cycle
      Unlock
    Endif
  Endif
  lu_kod := usl->kod
  lu_cena := iif( lvzros_reb == 0, usl->cena, usl->cena_d )
  If ( v1 := f1cena_oms( usl->shifr, lshifr, ( lvzros_reb == 0 ), ldate, usl->is_nul ) ) != NIL
    lu_cena := v1
  Endif

  Return lu_kod

// 07.04.14 найти все услуги по шифру ТФОМС в нашем справочнике услуг
Function foundallshifrtf( lshifr, ldate )

  Local au := {}, s, ret_u := {}

  lshifr := PadR( lshifr, 10 )
  // сначала проверим собственный шифр услуги, равный шифру ТФОМС
  Select USL
  Set Order To 2
  find ( lshifr )
  If Found()
    s := Space( 10 )
    Select USL1
    Set Order To 1
    find ( Str( usl->kod, 4 ) )
    If Found()
      Do While usl1->kod == usl->kod .and. !Eof()
        If usl1->date_b > ldate
          Exit
        Endif
        s := usl1->shifr1
        Skip
      Enddo
    Endif
    If Empty( s ) .or. s == lshifr // поле 'шифр ТФОМС' пустое или равно 'lshifr'
      AAdd( ret_u, usl->kod )
    Endif
  Endif
  // проверим тех, кто пользовался шифром ТФОМС
  Select USL1
  Set Order To 2
  find ( lshifr )
  Do While usl1->shifr1 == lshifr .and. !Eof()
    If usl1->date_b <= ldate
      AAdd( au, usl1->kod )
    Endif
    Skip
  Enddo
  Select USL1
  Set Order To 1
  For i := 1 To Len( au ) // цикл по кодам услуг, по которым стоит нужный шифр ТФОМС
    s := Space( 10 )
    find ( Str( au[ i ], 4 ) )
    Do While usl1->kod == au[ i ] .and. !Eof()
      If usl1->date_b > ldate
        Exit
      Endif
      s := usl1->shifr1
      Skip
    Enddo
    If s == lshifr
      AAdd( ret_u, au[ i ] )
    Endif
  Next

  Return ret_u

// 23.12.15 в GET'е вернуть множественный выбор учреждений/отделений
Function ret_nuch_notd( k, r, c )

  Local lcount_uch, lcount_otd, s

  pr_a_uch := {} ; pr_a_otd := {}
  If ( st_a_uch := inputn_uch( -r, c, , , @lcount_uch ) ) != NIL
    pr_a_uch := AClone( st_a_uch )
    If Len( st_a_uch ) == 1
      glob_uch := st_a_uch[ 1 ]
      If ( st_a_otd := inputn_otd( -r, c, .f., .t., glob_uch, @lcount_otd ) ) != NIL
        pr_a_otd := AClone( st_a_otd )
      Endif
    Else
      r_use( dir_server() + 'mo_otd', , 'OTD' )
      Go Top
      Do While !Eof()
        If f_is_uch( st_a_uch, otd->kod_lpu )
          AAdd( pr_a_otd, { otd->( RecNo() ), otd->name } )
        Endif
        Skip
      Enddo
      otd->( dbCloseArea() )
    Endif
  Endif
  If ( k := Len( pr_a_uch ) ) == 0
    s := 'Ничего не выбрано'
  Elseif k == 1
    If ( k := Len( pr_a_otd ) ) == 1
      s := '"' + AllTrim( pr_a_otd[ 1, 2 ] ) + '" в "' + AllTrim( glob_uch[ 2 ] ) + '"'
    Else
      s := 'Выбрано отделений: ' + lstr( k ) + ' в "' + AllTrim( glob_uch[ 2 ] ) + '"'
    Endif
  Else
    s := 'Выбрано учреждений: ' + lstr( k )
  Endif

  Return { k, CharOne( '"', s ) }

// 23.12.15 инициализация выборки нескольких типов счёта
Function ini_ed_tip_schet( lval )

  Local s := lval

  If Empty( lval )
    s := 'Не выбраны типы счетов'
  Elseif Len( lval ) == 18
    s := 'Все типы счетов'
  Endif

  Return s

// 30.03.23 выбор нескольких типов счёта
Function inp_bit_tip_schet( k, r, c )

  Local mlen, t_mas := {}, buf := SaveScreen(), ret, ;
    i, tmp_color := SetColor(), m1var := '', s := '', r1, r2, ;
    top_bottom := ( r < MaxRow() / 2 )

  mywait()
  AEval( get_bukva(), {| x| AAdd( t_mas, iif( x[ 2 ] $ k, ' * ', '   ' ) + x[ 1 ] ) } )
  mlen := Len( t_mas )
  i := 1
  status_key( '^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins,+,->^ - смена выбора типа счёта' )
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
      'Выбор одного/нескольких/всех типов счетов', 'B/BG' ) ) > 0
    For i := 1 To mlen
      If '*' == SubStr( t_mas[ i ], 2, 1 )
        m1var += get_bukva()[ i, 2 ]
      Endif
    Next
    s := ini_ed_tip_schet( m1var )
  Endif
  RestScreen( buf )
  SetColor( tmp_color )

  Return iif( ret == 0, NIL, { m1var, s } )
