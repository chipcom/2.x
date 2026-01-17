// mo_spr.prg
#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

//
Function begin_task_sprav()

  Static n_zapusk := 0
  Local fl := .t.

  If n_zapusk == 0
    ++n_zapusk
  Endif
  If copy_tools_ini()
    tools_ini_oms( 1, 0, 0 )
  Else
    fl := .f.
  Endif
  Return fl

//
Function inp_bit_otd( k, r, c )

  Local mlen, t_mas := {}, buf := SaveScreen(), ret, ;
    i, tmp_color := SetColor(), m1var := '', s := '', ;
    tmp_select := Select(), r1, a_uch := {}
  local curDate

  curDate := sys_date
  mywait()
  r_use( dir_server() + 'mo_uch', , 'LPU' )
  dbEval( {|| iif( between_date( lpu->dbegin, lpu->dend, curDate ), ;
    AAdd( a_uch, lpu->( RecNo() ) ), nil ) } )
  r_use( dir_server() + 'mo_otd', , 'OTD' )
  Set Relation To FIELD->kod_lpu into LPU
  dbEval( {|| s := if( Chr( RecNo() ) $ k, ' * ', '   ' ) + ;
    PadR( otd->name, 30 ) + ' ' + PadR( lpu->short_name, 5 ) + Str( RecNo(), 10 ), ;
    AAdd( t_mas, s ) }, ;
    {|| between_date( otd->dbegin, otd->dend, curDate ) .and. ;
    AScan( a_uch, otd->kod_lpu ) > 0 };
    )
  otd->( dbCloseArea() )
  lpu->( dbCloseArea() )
  If tmp_select > 0
    Select( tmp_select )
  Endif
  mlen := Len( t_mas )
  ASort( t_mas, , , {| x, y| if( SubStr( x, 35, 5 ) == SubStr( y, 35, 5 ), ;
    ( SubStr( x, 4, 30 ) < SubStr( y, 4, 30 ) ), ;
    ( SubStr( x, 35, 5 ) < SubStr( y, 35, 5 ) ) ) } )
  i := 1
  status_key( '^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins>^ - смена опции текущей альтернативы' )
  If ( r1 := r -1 - mlen -1 ) < 2
    r1 := 2
  Endif
  If ( ret := Popup( r1, 19, r -1, 62, t_mas, i, color0, .t., 'fmenu_reader', , ;
      'В каких отделениях разрешается ввод услуги', col_tit_popup ) ) > 0
    For i := 1 To mlen
      If '*' == SubStr( t_mas[ i ], 2, 1 )
        k := Chr( Int( Val( Right( t_mas[ i ], 10 ) ) ) )
        m1var += k
      Endif
    Next
    s := '= ' + lstr( Len( m1var ) ) + 'отд. ='
  Endif
  RestScreen( buf )
  SetColor( tmp_color )
  Return iif( ret == 0, NIL, { m1var, s } )

//
Function fget_slugba( k, r, c )

  Local tmp_help := chm_help_code, k1, fl

  chm_help_code := -1
  Select SL
  find ( Str( k, 3 ) )
  If !Found()
    Go Top
  Endif
  If ( fl := alpha_browse( 2, c, r -1, c + 50, 'f51_uslugi', color0, , , .f. ) )
    k1 := { sl->shifr, lstr( sl->shifr ) + '. ' + AllTrim( sl->name ) }
  Endif
  chm_help_code := tmp_help
  Return k1

//
Function f1_ns_uslugi( oBrow )

  Local oColumn

  oColumn := TBColumnNew( Center( 'Несовместимые услуги', 30 ), {|| uk->name } )
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ выход; ^<Enter>^ ред-ние; ^<Ins>^ добавление; ^<Del>^ удал.; ^<Ctrl+Enter>^ услуги' )
  Return Nil

// прочие справочники
Function edit_proch_spr( k )

  Static sk1 := 1, sk2 := 1
  Local str_sem, mas_pmt, mas_msg, mas_fun

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { 'Подстрока ~адреса', ;
      'Подстрока ~места работы', ;
      'Кем ~выдан документ', ;
      '~Прочие компании', ;
      '~Комитеты (МО)', ;
      'О~бразовательные учреждения', ;
      'Стационары детей-~сирот' }
    mas_msg := { 'Редактирование справочника подстроки адреса', ;
      'Редактирование справочника подстроки места работы', ;
      'Редактирование справочника организаций, выдающих документы', ;
      'Редактирование информации по прочим компаниям', ;
      'Редактирование информации по комитетам здравоохранения (МО)', ;
      'Редактирование справочника образовательных учреждений', ;
      'Редактирование справочника стационаров детей-сирот' }
    mas_fun := { 'edit_proch_spr(1)', ;
      'edit_proch_spr(2)', ;
      'edit_proch_spr(3)', ;
      'edit_proch_spr(4)', ;
      'edit_proch_spr(5)', ;
      'edit_proch_spr(6)', ;
      'edit_proch_spr(7)' }
    If eq_any( is_oplata, 5, 6, 7 )
      AAdd( mas_pmt, 'Способ ~оплаты' )
      AAdd( mas_msg, 'Ввод / редактирование справочников для Вашего способа оплаты' )
      If eq_any( is_oplata, 5, 6 )
        AAdd( mas_fun, 'spr_opl_5()' )
      Elseif is_oplata == 7
        AAdd( mas_fun, 'spr_opl_7()' )
      Endif
    Endif
    popup_prompt( T_ROW, T_COL + 5, sk1, mas_pmt, mas_msg, mas_fun )
  Case k == 1
    edit_s_adres()
  Case k == 2
    str_sem := 'Редактирование места работы'
    If g_slock( str_sem )
      popup_edit( dir_server() + 's_mr', T_ROW, T_COL + 5, MaxRow() -2, , 1 )
      g_sunlock( str_sem )
    Else
      func_error( 4, err_slock() )
    Endif
  Case k == 3
    mas_pmt := { '~Редактирование', ;
      'Удаление ~дубликатов' }
    mas_msg := { 'Редактирование справочника организаций, выдающих документы', ;
      'Удаление дубликатов организаций' }
    mas_fun := { 'edit_proch_spr(11)', ;
      'edit_proch_spr(12)' }
    popup_prompt( T_ROW, T_COL + 5, sk2, mas_pmt, mas_msg, mas_fun )
  Case k == 4
    edit_strah()
  Case k == 5
    edit_komit()
  Case k == 6
    edit_school()
  Case k == 7
    edit_dds_stac()
  Case k == 11
    fedit_s_kem()
  Case k == 12
    fdeld_s_kem()
  Endcase
  If Between( k, 1, 10 )
    sk1 := k
  Elseif Between( k, 11, 20 )
    sk2 := k
  Endif
  Return Nil

// справочник подстроки адреса
Function edit_s_adres()

  Local t_arr[ BR_LEN ], buf := SaveScreen()

  t_arr[ BR_TOP ] := 2
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL + 5
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 43
  t_arr[ BR_OPEN ] := {|| f1_s_adres(, , 'open' ) }
  t_arr[ BR_CLOSE ] := {|| sa->( dbCloseArea() ) }
  t_arr[ BR_SEMAPHORE ] := 'Редактирование адреса'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := {, , , , .t., 60 }
  t_arr[ BR_COLUMN ] := { { Center( 'Подстрока адреса', 40 ), {|| sa->name } } }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_s_adres( nk, ob, 'edit' ) }
  edit_browse( t_arr )
  RestScreen( buf )
  Return Nil

//
Function f1_s_adres( nKey, oBrow, regim )

  Local ret := -1, j := 0, flag := -1, buf := save_maxrow(), buf1, ;
    fl := .f., rec, tmp_color := SetColor()

  Do Case
  Case regim == 'open'
    g_use( dir_server() + 's_adres', dir_server() + 's_adres', 'SA' )
    Go Top
    ret := !Eof()
  Case regim == 'edit'
    If nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( sa->name ) )
      rec := RecNo()
      Private mname := if( nKey == K_INS, Space( 40 ), sa->name ), ;
        gl_area := { 1, 0, MaxRow() -1, 79, 0 }
      buf1 := box_shadow( pr2 -3, pc1 + 1, pr2 -1, pc2 -1, color8, ;
        iif( nKey == K_INS, 'Добавление', 'Редактирование' ), cDataPgDn )
      SetColor( cDataCGet )
      @ pr2 -2, pc1 + 2 Get mname
      status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение записи' )
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
      rest_box( buf )
      rest_box( buf1 )
    Elseif nKey == K_DEL .and. !Empty( sa->name ) .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
    Else
      Keyboard ''
    Endif
  Endcase
  Return ret

//
Function fedit_s_kem()

  Local t_arr[ BR_LEN ], buf := SaveScreen()

  t_arr[ BR_TOP ] := 2
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 4
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_OPEN ] := {|| f1_s_kemvyd(, , 'open' ) }
  t_arr[ BR_CLOSE ] := {|| sa->( dbCloseArea() ) }
  t_arr[ BR_SEMAPHORE ] := 'КЕМ ВЫДАН'
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := {, , , , .t., 60 }
  t_arr[ BR_COLUMN ] := { { Center( 'Наименование организаций, выдающих документы', 70 ), {|| PadR( sa->name, 70 ) } } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ выход ^<Enter>^ ред-ие ^<Del>^ удаление ^<Ins>^ добавление ^<F2>^ поиск' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_s_kemvyd( nk, ob, 'edit', 1 ) }
  edit_browse( t_arr )
  RestScreen( buf )
  Return Nil

// 12.07.17
Function f1_s_kemvyd( nKey, oBrow, regim, par )

  Local ret := -1, j := 0, flag := -1, buf := save_maxrow(), buf1, ;
    fl := .f., rec, tmp_color := SetColor()

  Do Case
  Case regim == 'open'
    g_use( dir_server() + 's_kemvyd', dir_server() + 's_kemvyd', 'SA' )
    Go Top
    If par != Nil .and. par > 0
      Goto ( par )
      If Deleted() .or. Eof()
        Go Top
      Endif
    Endif
    ret := !Eof()
  Case regim == 'edit'
    If nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( sa->name ) )
      rec := RecNo()
      Private mname := iif( nKey == K_INS, Space( 150 ), sa->name ), gl_area := { 1, 0, MaxRow() -1, 79, 0 }
      buf1 := box_shadow( pr2 -3, pc1 + 1, pr2 -1, pc2 -1, color8, ;
        iif( nKey == K_INS, 'Добавление', 'Редактирование' ), cDataPgDn )
      SetColor( cDataCGet )
      @ pr2 -2, pc1 + 2 Get mname Pict '@S70'
      status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение записи' )
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
      rest_box( buf )
      rest_box( buf1 )
    Elseif nKey == K_SPACE .and. par == 2
      _fl_space := .t.
      ret := 1
    Elseif nKey == K_DEL .and. !Empty( sa->name ) .and. f_esc_enter( 2 )
      If yes_d_kemvyd( sa->( RecNo() ) )
        deleterec()
        oBrow:gotop()
        ret := 0
      Endif
    Elseif nKey == K_F2
      If ( rec := poisk_kemvyd( pr1 ) ) != NIL
        oBrow:gotop()
        Goto ( rec )
        ret := 0
      Endif
    Else
      Keyboard ''
    Endif
  Endcase
  Return ret

//
Function poisk_kemvyd( mr1 )

  Static tmp := ''
  Local ret, rec := sa->( RecNo() ), buf := SaveScreen(), i, tmp1

  Do While .t.
    tmp1 := PadR( tmp, 50 )
    SetColor( color8 )
    box_shadow( 13, 14, 18, 67 )
    @ 15, 15 Say Center( 'Введите подстроку поиска', 52 )
    status_key( '^<Esc>^ - отказ;  ^<Enter>^ - поиск' )
    @ 16, 16 Get tmp1 Picture '@K@!'
    myread()
    SetColor( color0 )
    If LastKey() == K_ESC .or. Empty( tmp1 )
      Exit
    Endif
    mywait()
    tmp := AllTrim( tmp1 )
    i := 0
    Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := mr1 + 3, k2 := 21, tmp2 := Upper( tmp )
    Go Top
    Do While !Eof()
      If tmp2 $ Upper( sa->name )
        If++i > 100
          Exit
        Endif
        AAdd( tmp_mas, sa->name )
        AAdd( tmp_kod, sa->( RecNo() ) )
      Endif
      Skip
    Enddo
    If ( t_len := Len( tmp_kod ) ) = 0
      stat_msg( 'Неудачный поиск!' )
      mybell( 2, ERR )
      Loop
    Else
      box_shadow( mr1, 2, 22, 77 )
      SetColor( col_tit_popup )
      @ k1 -2, 15 Say 'Поиск: ' + tmp2
      SetColor( color0 )
      If k1 + t_len + 2 < 21
        k2 := k1 + t_len + 2
      Endif
      i := AScan( tmp_kod, rec )
      @ k1, 3 Say Center( ' Количество найденных строк - ' + lstr( t_len ), 74 )
      status_key( '^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор' )
      If ( i := Popup( k1 + 1, 13, k2, 66, tmp_mas, i, color0 ) ) > 0
        ret := tmp_kod[ i ]
      Endif
      Exit
    Endif
  Enddo
  Goto ( rec )
  RestScreen( buf )
  Return ret

//
Function get_s_kemvyd( k, r, c )

  Local r1, r2

  If ( r1 := r + 1 ) > MaxRow() / 2
    r2 := r -1
    r1 := 2
  Else
    r2 := MaxRow() -2
  Endif
  Return input_s_kemvyd( k, r1, r2 )

//
Function input_s_kemvyd( k, r1, r2 )

  Local t_arr[ BR_LEN ], tmp_select := Select(), buf := SaveScreen(), ret, tmp_keys

  Private _fl_space := .f.

  t_arr[ BR_TOP ] := r1
  t_arr[ BR_BOTTOM ] := r2
  t_arr[ BR_LEFT ] := 4
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_OPEN ] := {|| f1_s_kemvyd(, , 'open', k ) }
  t_arr[ BR_CLOSE ] := {|| sa->( dbCloseArea() ) }
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_COLUMN ] := { { Center( 'Наименование организаций, выдающих документы', 70 ), {|| PadR( sa->name, 70 ) } } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ выход ^<Enter>^ выбор ^<Пробел>^ очистка поля ^<Ins>^ добавление ^<F2>^ поиск' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_s_kemvyd( nk, ob, 'edit', 2 ) }
  t_arr[ BR_ENTER ] := {|| ret := { sa->( RecNo() ), AllTrim( sa->name ) } }
  tmp_keys := my_savekey()
  edit_browse( t_arr )
  my_restkey( tmp_keys )
  If tmp_select > 0
    Select( tmp_select )
  Endif
  RestScreen( buf )
  If _fl_space
    ret := { 0, Space( 10 ) }
  Endif
  Return ret

//
Function yes_d_kemvyd( rec )

  Local tmp_select := Select(), fl := .t.

  r_use( dir_server() + 'kartote_', , 'TMPKART' )
  Locate For kemvyd == rec progress
  If Found()
    fl := func_error( 4, 'Данная организация уже "привязана" к пациенту. Удаление запрещено!' )
  Endif
  tmpkart->( dbCloseArea() )
  If tmp_select > 0
    Select( tmp_select )
  Endif
  Return fl

// удаление дубликатов организаций, выдающих документы
Function fdeld_s_kem()

  Static sk
  Local buf, s1, s2, k1, k2, hGauge, r

  buf := SaveScreen()
  s1 := s2 := ''
  r := T_ROW
  If ! currentuser():isadmin()
    Return func_error( 4, 'Оператору доступ в данный режим запрещен!' )
  Endif
  If !g_slock1task( sem_task(), sem_vagno() )  // запрет доступа всем
    Return func_error( 'В данный момент УДАЛЕНИЕ ДУБЛИКАТА запрещено. Работает другая задача.' )
  Endif
  n_message( { 'Данный режим предназначен для удаления одной строки', ;
    '"кем выдан документ" и переноса всей относящейся', ;
    'к ней информации другой строке' }, , ;
    cColorStMsg, cColorStMsg, , , cColorSt2Msg )
  f_message( { 'Выберите удаляемую строку' }, , color1, color8, 0 )
  If ( k1 := input_s_kemvyd( sk, r, MaxRow() -2 ) ) != NIL
    s1 := k1[ 2 ]
    RestScreen( buf )
    f_message( { 'Выберите строку, на которую переносится информация', ;
      'от <.. ' + s1 + ' ..>' }, , ;
      color1, color8, 0 )
    If ( k2 := input_s_kemvyd( k1[ 1 ], r, MaxRow() -2 ) ) != NIL
      RestScreen( buf )
      If k1[ 1 ] == k2[ 1 ]
        func_error( 4, 'Два раза выбрана одна и та же организация!' )
      Else
        RestScreen( buf )
        s2 := k2[ 2 ]
        f_message( { 'Удаляемая строка:', ;
          '"' + s1 + '".', ;
          'Вся информация переносится в строку:', ;
          '"' + s2 + '".' }, , ;
          color1, color8 )
        If f_esc_enter( 'удаления', .t. )
          sk := k2[ 1 ]
          mywait()
          hGauge := gaugenew(, , , '', .t. )
          gaugedisplay( hGauge )
          g_use( dir_server() + 'kartote_', , 'TMPKART' )
          Go Top
          Do While !Eof()
            gaugeupdate( hGauge, RecNo() / LastRec() )
            If tmpkart->kemvyd == k1[ 1 ]
              g_rlock( forever )
              tmpkart->kemvyd := k2[ 1 ]
              Unlock
            Endif
            Skip
          Enddo
          closegauge( hGauge )
          //
          g_use( dir_server() + 's_kemvyd', dir_server() + 's_kemvyd', 'SA' )
          Set Order To 0
          Goto ( k1[ 1 ] )
          deleterec( .t. )
          Close databases
          stat_msg( 'Операция завершена!' )
          mybell( 2, OK )
        Endif
      Endif
    Endif
  Endif
  RestScreen( buf )
  g_sunlock( sem_vagno() )
  Return Nil

// 29.07.13
Function edit_school()

  Local blk, arr[ US_LEN ]

  arr[ US_BOTTOM   ] := MaxRow() -2
  arr[ US_LEFT     ] := 2
  arr[ US_RIGHT    ] := 77
  arr[ US_BASE     ] := dir_server() + 'mo_schoo'
  arr[ US_ARR_BROWSE ] := { '═', '░', '═', , .t. }
  arr[ US_COLUMN   ] := { { ' Наименование', {|| name }, blk }, ;
    { ' Адрес', {|| Left( adres, 26 ) }, blk }, ;
    { ' Тип', {|| PadR( inieditspr( A__MENUVERT, mm_tip_school, tip ), 14 ) }, blk } }
  arr[ US_BLK_DEL  ] := {| _k| fdel_school( _k ) }
  arr[ US_IM_PADEG ] := arr[ US_SEMAPHORE ] := 'образовательные учреждения'
  arr[ US_ROD_PADEG ] := 'образовательных учреждений'
  arr[ US_EDIT_SPR ] := { { 'name', 'C', 30, 0, , , Space( 30 ), , 'Сокращённое наименование' }, ;
    { 'fname', 'C', 250, 0, , , Space( 250 ), , 'Полное наименование' }, ;
    { 'adres', 'C', 250, 0, , , Space( 250 ), , 'Юридический адрес' }, ;
    { 'tip', 'N', 1, 0, , ;
    {| x| menu_reader( x, mm_tip_school, A__MENUVERT, , , .f. ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_tip_school, x ) }, 'Тип' };
    }
  edit_u_spr( 1, arr )
  Return Nil

// 08.11.22
Function fdel_school( k )

  Local _fl := .t., arr, i

  r_use( dir_server() + 'human', , '__B' )
  Index On FIELD->kod to ( cur_dir() + 'tmp_b' ) For Between( FIELD->ishod, 301, 309 )
  Go Top
  Do While !Eof()
    arr := read_arr_dispans( __b->kod )
    For i := 1 To Len( arr )
      If ValType( arr[ i ] ) == 'A' .and. ValType( arr[ i, 1 ] ) == 'C' ;
          .and. arr[ i, 1 ] == '8' .and. ValType( arr[ i, 2 ] ) == 'N'
        If ( arr[ i, 2 ] == k )
          _fl := .f.
        Endif
        Exit
      Endif
    Next
    If !_fl
      Exit
    Endif
    Select __B
    Skip
  Enddo
  dbCloseArea()
  Return _fl

// 25.05.13
Function edit_dds_stac()

  Static mm_vedom := { { 'органы здравоохранения', 0 }, ;
    { 'органы образования', 1 }, ;
    { 'органы социальной защиты', 2 }, ;
    { 'другое', 3 } }
  Local blk, arr[ US_LEN ]

  arr[ US_BOTTOM   ] := MaxRow() -2
  arr[ US_LEFT     ] := 2
  arr[ US_RIGHT    ] := 77
  arr[ US_BASE     ] := dir_server() + 'mo_stdds'
  arr[ US_ARR_BROWSE ] := { '═', '░', '═', , .t. }
  arr[ US_COLUMN   ] := { { ' Наименование', {|| Left( name, 40 ) }, blk }, ;
    { ' Адрес', {|| Left( adres, 16 ) }, blk }, ;
    { 'Ведомственная;принадлежность', {|| PadR( inieditspr( A__MENUVERT, mm_vedom, vedom ), 14 ) }, blk } }
  arr[ US_BLK_DEL  ] := {| _k| fdel_dds_stac( _k ) }
  arr[ US_IM_PADEG ] := arr[ US_SEMAPHORE ] := 'Стационары детей-сирот'
  arr[ US_ROD_PADEG ] := 'учреждений'
  arr[ US_EDIT_SPR ] := { { 'name', 'C', 250, 0, , , Space( 250 ), , 'Наименование стационара' }, ;
    { 'adres', 'C', 250, 0, , , Space( 250 ), , 'Адрес' }, ;
    { 'vedom', 'N', 1, 0, , ;
    {| x| menu_reader( x, mm_vedom, A__MENUVERT, , , .f. ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_vedom, x ) }, ;
    'Ведомственная принадлежность' };
    }
  edit_u_spr( 1, arr )
  Return Nil

// 08.11.22
Function fdel_dds_stac( k )

  Local _fl := .f.

  r_use( dir_server() + 'human', , '__B' )
  dblocateprogress( {|| __b->ZA_SMO == k } )
  _fl := ! Found()
  dbCloseArea()
  Return _fl

//
Function spr_opl_5( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { 'Смена ~классов оплаты персоналу', ;
      '% оплаты ~врачам (ОМС)', ;
      '% оплаты ~ассистентам (ОМС)' }
    mas_msg := { 'Настройка классов оплаты (и отдаленности работы) персонала', ;
      'Настройка групп услуг (установка процентов оплаты врачей по ОМС)', ;
      'Настройка групп услуг (установка процентов оплаты ассистентов по ОМС)' }
    mas_fun := { 'spr_opl_5(11)', ;
      'spr_opl_5(12)', ;
      'spr_opl_5(13)' }
    If is_task( X_PLATN ) // для платных услуг
      AAdd( mas_pmt, '% оплаты вра~чам (платные)' )
      AAdd( mas_msg, 'Настройка групп услуг (установка процентов оплаты врачей по ПЛАТНЫМ УСЛУГАМ)' )
      AAdd( mas_fun, 'spr_opl_5(16)' )
      AAdd( mas_pmt, '% оплаты асс~истентам (платные)' )
      AAdd( mas_msg, 'Настройка групп услуг (установка процентов оплаты ассистентов по ПЛАТНЫМ УСЛУГАМ)' )
      AAdd( mas_fun, 'spr_opl_5(17)' )
      AAdd( mas_pmt, '% оплаты за ~направление на пл.услуги' )
      AAdd( mas_msg, 'Настройка групп услуг (проценты оплаты за направление на платные услуги)' )
      AAdd( mas_fun, 'spr_opl_5(18)' )
    Endif
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL + 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    spr_opl_52()
  Case k == 12
    spr_opl_51( O5_VR_OMS, 'врачам (ОМС)' )
  Case k == 13
    spr_opl_51( O5_AS_OMS, 'ассистентам (ОМС)' )
  Case k == 16
    spr_opl_51( O5_VR_PLAT, 'врачам (платные услуги)' )
  Case k == 17
    spr_opl_51( O5_AS_PLAT, 'ассистентам (платные услуги)' )
  Case k == 18
    spr_opl_51( O5_VR_NAPR, 'за направление на платные услуги' )
  Endcase
  If Between( k, 11, 20 )
    si1 := k -10
  Endif
  Return Nil

//
Function spr_opl_7( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { '~Стоимость УЕТ', ;
      '% оплаты ~врачам (ОМС)', ;
      '% оплаты ~ассистентам (ОМС)' }
    mas_msg := { 'Настройка стоимости УЕТ для врача и ассистента по группам услуг', ;
      'Настройка групп услуг (установка процентов оплаты врачей по ОМС)', ;
      'Настройка групп услуг (установка процентов оплаты ассистентов по ОМС)' }
    mas_fun := { 'spr_opl_7(11)', ;
      'spr_opl_7(12)', ;
      'spr_opl_7(13)' }
    If is_task( X_PLATN ) // для платных услуг
      AAdd( mas_pmt, '% оплаты вра~чам (платные)' )
      AAdd( mas_msg, 'Настройка групп услуг (установка процентов оплаты врачей по ПЛАТНЫМ УСЛУГАМ)' )
      AAdd( mas_fun, 'spr_opl_7(14)' )
      AAdd( mas_pmt, '% оплаты асс~истентам (платные)' )
      AAdd( mas_msg, 'Настройка групп услуг (установка процентов оплаты ассистентов по ПЛАТНЫМ УСЛУГАМ)' )
      AAdd( mas_fun, 'spr_opl_7(15)' )
      AAdd( mas_pmt, '% оплаты врачам (~ДМС)' )
      AAdd( mas_msg, 'Настройка групп услуг (установка процентов оплаты врачей по ДМС)' )
      AAdd( mas_fun, 'spr_opl_7(16)' )
      AAdd( mas_pmt, '% оплаты ассистентам (Д~МС)' )
      AAdd( mas_msg, 'Настройка групп услуг (установка процентов оплаты ассистентов по ДМС)' )
      AAdd( mas_fun, 'spr_opl_7(17)' )
    Endif
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL + 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    spr_opl_71()
  Case k == 12
    spr_opl_51( O5_VR_OMS, 'врачам (ОМС)' )
  Case k == 13
    spr_opl_51( O5_AS_OMS, 'ассистентам (ОМС)' )
  Case k == 14
    spr_opl_51( O5_VR_PLAT, 'врачам (платные услуги)' )
  Case k == 15
    spr_opl_51( O5_AS_PLAT, 'ассистентам (платные услуги)' )
  Case k == 16
    spr_opl_51( O5_VR_DMS, 'врачам (ДМС)' )
  Case k == 17
    spr_opl_51( O5_AS_DMS, 'ассистентам (ДМС)' )
  Endcase
  If Between( k, 11, 20 )
    si1 := k -10
  Endif
  Return Nil

//
Function spr_opl_51( reg, s )

  Local blk, t_arr[ BR_LEN ], mtitle := '% оплаты ' + s

  Private str_find := Str( reg, 2 ), muslovie := 'u5->tip==' + lstr( reg )

  t_arr[ BR_TOP ] := 2
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 13
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 52
  t_arr[ BR_OPEN ] := {|| fs_opl_51(, , 'open', reg ) }
  t_arr[ BR_CLOSE ] := {|| dbCloseAll() }
  t_arr[ BR_ARR_BLOCK ] := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find ) }, ;
    {| n| skippointer( n, muslovie ) }, ;
    str_find, muslovie;
    }
  t_arr[ BR_SEMAPHORE ] := mtitle
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitle
  t_arr[ BR_TITUL_COLOR ] := 'W+/GR'
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t., 300 }
  blk := {|| if( Empty( u5->razryad ), { 3, 4 }, { 1, 2 } ) }
  t_arr[ BR_COLUMN ] := {}
  AAdd( t_arr[ BR_COLUMN ], { 'Класс;оплаты', {|| put_val( u5->razryad, 2 ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { 'Отдален-;ность', {|| PadC( iif( u5->otdal == 1, '√', '' ), 9 ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { 'Услуги с:', {|| u5->usl_1 }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { '  по:', {|| u5->usl_2 }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { '  Процент;  оплаты', {|| ft_opl_51( u5->procent, u5->procent2, 10 ) }, blk } )
  t_arr[ BR_STAT_MSG ] := {|| ;
    status_key( '^<Esc>^ выход ^<Enter>^ редактирование ^<Ins>^ добавление ^<Del>^ удаление ^<F9>^ печать' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| fs_opl_51( nk, ob, 'edit', reg ) }
  edit_browse( t_arr )
  Return Nil

//
Function fs_opl_51( nKey, oBrow, regim, lregim )

  Local ret := -1
  Local buf, fl := .f., rec, k := 14, tmp_color

  Do Case
  Case regim == 'open'
    buf := save_maxrow()
    mywait()
    g_use( dir_server() + 'u_usl_5', , 'U5' )
    Go Top
    Do While !Eof()
      g_rlock( forever )
      u5->_usl_1 := fsort_usl( u5->usl_1 )
      u5->_usl_2 := fsort_usl( iif( Empty( u5->usl_2 ), u5->usl_1, u5->usl_2 ) )
      Unlock
      Skip
    Enddo
    Commit
    Index On Str( FIELD->tip, 2 ) + FIELD->_usl_1 + Str( FIELD->razryad, 2 ) + Str( FIELD->otdal, 1 ) to ( cur_dir() + 'tmp_u5' )
    find ( str_find )
    ret := Found()
    rest_box( buf )
  Case regim == 'edit'
    Do Case
    Case nKey == K_F9
      buf := save_maxrow()
      mywait()
      rec := RecNo()
      arr_title := { ;
        '─────┬─────┬─────────────────────╥─────────────────────', ;
        'Класс│Отда-│       Услуги        ║   % оплаты по ОМС   ', ;
        'опла-│лен- ├──────────┬──────────╫──────────┬──────────', ;
        'ты   │ность│    с     │    по    ║   врач   │ассистент ', ;
        '─────┴─────┴──────────┴──────────╨──────────┴──────────' }
      If is_task( X_PLATN ) // для платных услуг
        If is_oplata == 7
          arr_title[ 1 ] := arr_title[ 1 ] + '╥───────────────────────────'
          arr_title[ 2 ] := arr_title[ 2 ] + '║% оплаты по платным услугам'
          arr_title[ 3 ] := arr_title[ 3 ] + '╫──────┬──────┬──────┬──────'
          arr_title[ 4 ] := arr_title[ 4 ] + '║ врач │ асс. │вр.ДМС│ассДМС'
          arr_title[ 5 ] := arr_title[ 5 ] + '╨──────┴──────┴──────┴──────'
        Else
          arr_title[ 1 ] := arr_title[ 1 ] + '╥────────────────────'
          arr_title[ 2 ] := arr_title[ 2 ] + '║ % оплаты по пл.усл.'
          arr_title[ 3 ] := arr_title[ 3 ] + '╫──────┬──────╥──────'
          arr_title[ 4 ] := arr_title[ 4 ] + '║ врач │ асс. ║направ'
          arr_title[ 5 ] := arr_title[ 5 ] + '╨──────┴──────╨──────'
        Endif
      Endif
      n_file := 'pers_o51.txt'
      HH := 58
      sh := 60
      Private reg_print := f_reg_print( arr_title, @sh )
      fp := FCreate( n_file )
      n_list := 1
      tek_stroke := 0
      add_string( '' )
      add_string( Center( 'Проценты оплаты персоналу', sh ) )
      add_string( Center( 'на ' + date_month( sys_date, .t. ), sh ) )
      add_string( '' )
      AEval( arr_title, {| x| add_string( x ) } )
      Go Top
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        s := put_val( u5->razryad, 4 ) + ;
          iif( u5->otdal == 1, '   да', Space( 5 ) ) + ;
          Space( 3 ) + ;
          u5->usl_1 + ' ' + ;
          if( Empty( u5->usl_2 ), u5->usl_1, u5->usl_2 )
        s1 := ''
        Do Case
        Case u5->tip == O5_VR_OMS
          s1 := ' ' + ft_opl_51( u5->procent, u5->procent2, 10 )
        Case u5->tip == O5_AS_OMS
          s1 := Space( 12 ) + ft_opl_51( u5->procent, u5->procent2, 10 )
        Case u5->tip == O5_VR_PLAT
          s1 := Space( 22 ) + put_val_0( u5->procent, 7, 2 )
        Case u5->tip == O5_AS_PLAT
          s1 := Space( 22 + 7 ) + put_val_0( u5->procent, 7, 2 )
        Case u5->tip == O5_VR_NAPR .or. ( u5->tip == O5_VR_DMS .and. is_oplata == 7 )
          s1 := Space( 22 + 7 + 7 ) + put_val_0( u5->procent, 7, 2 )
        Case ( u5->tip == O5_AS_DMS .and. is_oplata == 7 )
          s1 := Space( 22 + 7 + 7 + 7 ) + put_val_0( u5->procent, 7, 2 )
        Endcase
        If !Empty( s1 )
          add_string( s + s1 )
        Endif
        Skip
      Enddo
      Goto ( rec )
      FClose( fp )
      rest_box( buf )
      viewtext( n_file, , , , ( sh > 80 ), , , reg_print )
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( u5->usl_1 ) )
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 4, pc1, pr1 + 4, pc2, 'N/N', 'W+/N' )
        ColorWin( pr1 + 4, pc1, pr1 + 4, pc2, 'N/N', 'W+/B' )
      Endif
      rec := RecNo()
      Private mrazryad := if( nkey == K_INS, 0, u5->razryad ), ;
        motdal := if( nkey == K_INS, ' ', iif( u5->otdal == 1, '√', ' ' ) ), ;
        musl_1 := if( nkey == K_INS, Space( 10 ), u5->usl_1 ), ;
        musl_2 := if( nkey == K_INS, Space( 10 ), u5->usl_2 ), ;
        mprocent := if( nkey == K_INS, 0, u5->procent ), ;
        mprocent2 := if( nkey == K_INS, 0, u5->procent2 ), ;
        bg := {| o, k| get_c_symb( o, k, '√' ) }, ;
        gl_area := { 1, 0, MaxRow() -1, 79, 0 }
      tmp_color := SetColor( cDataCScr )
      k := MaxRow() -10
      box_shadow( k, pc1 + 1, MaxRow() -3, pc2 -1, , ;
        if( nKey == K_INS, 'Добавление', 'Редактирование' ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 3 Say 'Класс оплаты' Get mrazryad Pict '99' Range 0, 99
      @ k + 2, pc1 + 3 Say 'Отдаленность' Get motdal reader {| o| mygetreader( o, bg ) }
      @ k + 3, pc1 + 3 Say 'Услуги с:' Get musl_1
      @ k + 4, pc1 + 3 Say '      по:' Get musl_2
      @ k + 5, pc1 + 3 Say 'Процент оплаты' Get mprocent Pict '99.99'
      If eq_any( lregim, O5_VR_OMS, O5_VR_PLAT, O5_VR_DMS )
        @ k + 6, pc1 + 3 Say 'Процент оплаты врачу без ассистента' Get mprocent2 Pict '99.99'
      Elseif eq_any( lregim, O5_AS_OMS, O5_AS_PLAT, O5_AS_DMS )
        @ k + 6, pc1 + 3 Say 'Процент оплаты ассистенту без врача' Get mprocent2 Pict '99.99'
      Endif
      status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
      myread()
      If LastKey() != K_ESC .and. !emptyany( musl_1, mprocent ) .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          addrec( 2 )
          Replace u5->tip With lregim
          rec := RecNo()
        Else
          g_rlock( forever )
        Endif
        u5->usl_1    := musl_1
        u5->usl_2    := musl_2
        u5->procent  := mprocent
        u5->procent2 := mprocent2
        u5->razryad  := mrazryad
        u5->otdal    := iif( Empty( motdal ), 0, 1 )
        u5->_usl_1   := fsort_usl( musl_1 )
        u5->_usl_2   := fsort_usl( iif( Empty( musl_2 ), musl_1, musl_2 ) )
        Unlock
        Commit
        oBrow:gotop()
        Goto ( rec )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. !Empty( u5->usl_1 ) .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      find ( str_find )
      ret := 0
      If !Found()
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

//
Function ft_opl_51( p1, p2, n )

  Local s1 := AllTrim( put_val_0( p1, 5, 2 ) ), s2

  If !Empty( p2 )
    s2 := AllTrim( put_val_0( p2, 5, 2 ) )
    If Len( s1 ) + Len( s2 ) + 3 <= n
      s1 += ' '
    Endif
    s1 += '(' + s2 + ')'
  Endif
  Return PadC( s1, n )

//
Function spr_opl_52()

  Local buf := SaveScreen(), t_arr[ BR_LEN ], n := 36

  Private menu_kateg := { { ' без', 0 }, ;
    { '2-ая', 1 }, ;
    { '1-ая', 2 }, ;
    { 'высш', 3 } }

  mywait()
  g_use( dir_server() + 'mo_pers', , 'PERSO' )
  Index On Upper( FIELD->fio ) to ( cur_dir() + 'tmp_pers' )
  Go Top
  t_arr[ BR_TOP ] := 2
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := 'Корректировка уровней оплаты персонала'
  t_arr[ BR_TITUL_COLOR ] := 'W+/GR'
  t_arr[ BR_ARR_BROWSE ] := {, , , 'N/BG,W+/N,B/BG,W+/B,N+/BG', .t., 300 }
  t_arr[ BR_FL_INDEX ] := .t.
  t_arr[ BR_FL_NOCLEAR ] := .t.
  t_arr[ BR_SEMAPHORE ] := t_arr[ BR_TITUL ]
  blk := {|| if( Empty( perso->uroven ), { 3, 4 }, { 1, 2 } ) }
  t_arr[ BR_COLUMN ] := { { PadC( 'Ф.И.О.', n ), {|| Left( perso->fio, n ) }, blk } }
  AAdd( t_arr[ BR_COLUMN ], { ' Таб.;номер', {|| put_val( perso->tab_nom, 5 ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { 'Кате;гор.', {|| PadR( inieditspr( A__MENUVERT, menu_kateg, perso->kateg ), 4 ) }, {|| { 5, 5 } }, { 5, 5 } } )
  AAdd( t_arr[ BR_COLUMN ], { 'Класс;оплаты', {|| put_val( perso->uroven, 2 ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { 'Отдален-;ность', {|| PadC( iif( perso->otdal == 1, '√', '' ), 9 ) }, blk } )
  t_arr[ BR_STAT_MSG ] := {|| ;
    status_key( '^<Esc>^ - выход;  ^<Enter>^ - редактирование;  ^<F9>^ - печать' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| fs_opl_52( nk, ob, 'edit' ) }
  edit_browse( t_arr )
  Close databases
  RestScreen( buf )
  Return Nil

//
Function fs_opl_52( nKey, oBrow, cregim )

  Local ret := -1, r := Row(), c := Col(), buf, fl := .f., ;
    tmp_color := SetColor(), n_file, sh, HH

  Do Case
  Case cregim == 'edit'
    Do Case
    Case nKey == K_F9
      buf := save_maxrow()
      mywait()
      rec := RecNo()
      arr_title := { ;
        '──────────────────────────────────────────────────┬─────┬─────', ;
        '                                                  │Класс│Отда-', ;
        '                     Ф.И.О.                       │опла-│лен- ', ;
        '                                                  │ты   │ность', ;
        '──────────────────────────────────────────────────┴─────┴─────' }
      n_file := 'pers_o52.txt'
      sh := Len( arr_title[ 1 ] )
      HH := 57
      fp := FCreate( n_file )
      n_list := 1 ; tek_stroke := 0
      add_string( '' )
      add_string( Center( 'Список персонала', sh ) )
      add_string( Center( 'на ' + date_month( sys_date, .t. ), sh ) )
      add_string( '' )
      AEval( arr_title, {| x| add_string( x ) } )
      Go Top
      Do While !Eof()
        If !( emptyall( perso->UROVEN, perso->otdal ) )
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          lfio := PadR( '[' + lstr( perso->tab_nom ) + ']', 8 )
          lfio += perso->fio
          add_string( Left( lfio, 50 ) + ;
            put_val( perso->UROVEN, 5 ) + ;
            iif( perso->otdal == 1, '   да', '' ) )
        Endif
        Skip
      Enddo
      Goto ( rec )
      FClose( fp )
      rest_box( buf )
      viewtext( n_file, , , , ( sh > 80 ), , , 2 )
    Case nKey == K_ENTER
      buf := save_maxrow()
      Private mrazryad := perso->UROVEN, ;
        motdal := iif( perso->otdal == 1, '√', ' ' ), ;
        bg := {| o, k| get_c_symb( o, k, '√' ) }, ;
        gl_area := { 1, 0, MaxRow() -1, 79, 0 }
      SetColor( cDataCGet )
      @ Row(), 58 Clear To Row(), 76
      @ Row(), 58 Get mrazryad Pict '99' Range 0, 99
      @ Row(), 71 Get motdal reader {| o| mygetreader( o, bg ) }
      status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи' )
      myread()
      If LastKey() != K_ESC
        g_rlock( forever )
        perso->UROVEN := mrazryad
        perso->otdal := iif( Empty( motdal ), 0, 1 )
        Unlock
        Commit
        oBrow:down()
      Endif
      rest_box( buf )
      SetColor( tmp_color )
      ret := 0
    Endcase
  Endcase
  @ r, c Say ''
  Return ret

//
Function get_c_symb( oGet, nKey, char_symbol )

  Local mvar

  If nKey >= 32
    mvar := ReadVar()
    If Empty( &mvar )
      cKey := char_symbol
    Else
      cKey := ' '  // пробел
    Endif
    oGet:overstrike( cKey )
    If ( oGet:typeOut )
      If ( !Set( _SET_CONFIRM ) )
        oGet:exitState := GE_ENTER
      Endif
    Endif
  Endif
  Return Nil

//
Function spr_opl_71()

  Local blk, t_arr[ BR_LEN ], mtitle := 'Стоимость УЕТ для группы услуг'

  t_arr[ BR_TOP ] := 2
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_OPEN ] := {|| fs_opl_71(, , 'open' ) }
  t_arr[ BR_CLOSE ] := {|| dbCloseAll() }
  t_arr[ BR_SEMAPHORE ] := mtitle
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitle
  t_arr[ BR_TITUL_COLOR ] := 'W+/GR'
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t., 300 }
  blk := {|| if( Empty( u7->usl_ins ), { 3, 4 }, { 1, 2 } ) }
  t_arr[ BR_COLUMN ] := {}
  AAdd( t_arr[ BR_COLUMN ], { 'Наименование услуг', {|| u7->name }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { 'Вар;рас;чет', {|| iif( u7->variant == 1, ' 1 ', ' 2 ' ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { 'Врач; УЕТ; ОМС', {|| put_val_0( u7->v_uet_oms, 6, 2 ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { 'Ассис.; УЕТ; ОМС', {|| put_val_0( u7->a_uet_oms, 6, 2 ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { 'Врач; УЕТ;платн.', {|| put_val_0( u7->v_uet_pl, 6, 2 ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { 'Ассис.; УЕТ;платн.', {|| put_val_0( u7->a_uet_pl, 6, 2 ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { 'Врач; УЕТ; ДМС', {|| put_val_0( u7->v_uet_dms, 6, 2 ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { 'Ассис.; УЕТ; ДМС', {|| put_val_0( u7->a_uet_dms, 6, 2 ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { 'Услуги', {|| PadR( u7->usl_ins, 11 ) }, blk } )
  t_arr[ BR_STAT_MSG ] := {|| ;
    status_key( '^<Esc>^ выход ^<Enter>^ ред-е ^<Ins>^ доб. ^<Del>^ удал. ^<Ctrl+Enter>^ услуги ^<F9>^ печать' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| fs_opl_71( nk, ob, 'edit', mtitle ) }
  edit_browse( t_arr )
  Return Nil

//
Function fs_opl_71( nKey, oBrow, regim, mtitle )

  Static menu_variant := { { '1 - при отсутствии асс-та врачу кол-во УЕТ врача и асс-та', 1 }, ;
    { '2 - при отсутствии асс-та врачу ст-ть УЕТ врача и асс-та', 0 } }
  Local ret := -1, sh
  Local buf, fl := .f., rec, k := 12, tmp_color, a_da, a_net, t_arr[ 2 ]

  Do Case
  Case regim == 'open'
    g_use( dir_server() + 'u_usl_7', , 'U7' )
    Index On Upper( FIELD->name ) to ( cur_dir() + 'tmp_u7' )
    Go Top
    ret := !Eof()
  Case regim == 'edit'
    Do Case
    Case nKey == K_F9
      buf := save_maxrow()
      mywait()
      rec := RecNo()
      arr_title := { ;
        '────────────────────────────────────────────────────────────────────┬─────┬─────', ;
        '                                                                    │ Врач│Ассис', ;
        '           Наименование услуги                                      │ УЕТ │ УЕТ ', ;
        '────────────────────────────────────────────────────────────────────┴─────┴─────' }
      n_file := 'pers_o71.txt'
      HH := 58
      Private reg_print := f_reg_print( arr_title, @sh )
      fp := FCreate( n_file )
      n_list := 1
      tek_stroke := 0
      add_string( '' )
      add_string( Center( mtitle + ' "' + AllTrim( u7->name ) + '"', sh ) )
      add_string( Center( 'на ' + date_month( sys_date, .t. ), sh ) )
      add_string( '' )
      s := 'Cтоимость УЕТ '
      add_string( s + 'ОМС для врача          :' + Str( u7->v_uet_oms, 7, 2 ) )
      add_string( s + 'ОМС для ассистента     :' + Str( u7->a_uet_oms, 7, 2 ) )
      add_string( s + 'пл.услуг для врача     :' + Str( u7->v_uet_pl, 7, 2 ) )
      add_string( s + 'пл.услуг для ассистента:' + Str( u7->a_uet_pl, 7, 2 ) )
      add_string( s + 'ДМС для врача          :' + Str( u7->v_uet_dms, 7, 2 ) )
      add_string( s + 'ДМС для ассистента     :' + Str( u7->a_uet_dms, 7, 2 ) )
      add_string( '' )
      AEval( arr_title, {| x| add_string( x ) } )
      a_da := slist2arr( u7->usl_ins )
      a_net := slist2arr( u7->usl_del )
      useuch_usl()
      r_use( dir_server() + 'uslugi', , 'USL' )
      Index On fsort_usl( FIELD->shifr ) to ( cur_dir() + 'tmpu' )
      Go Top
      Do While !Eof()
        If _f_usl_danet( a_da, a_net )
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          Select UU
          find ( Str( usl->kod, 4 ) )
          k := perenos( t_arr, usl->name, sh -11 -12 )
          add_string( usl->shifr + ' ' + PadR( t_arr[ 1 ], sh -11 -12 ) + ;
            put_val_0( uu->vkoef_v, 6, 2 ) + put_val_0( uu->akoef_v, 6, 2 ) )
          For i := 2 To k
            add_string( Space( 11 ) + t_arr[ i ] )
          Next
        Endif
        Select USL
        Skip
      Enddo
      uu->( dbCloseArea() )
      usl->( dbCloseArea() )
      FClose( fp )
      rest_box( buf )
      viewtext( n_file, , , , ( sh > 80 ), , , reg_print )
      Select U7
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( u7->name ) )
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 4, pc1, pr1 + 4, pc2, 'N/N', 'W+/N' )
        ColorWin( pr1 + 4, pc1, pr1 + 4, pc2, 'N/N', 'W+/B' )
      Endif
      rec := RecNo()
      Private mname := if( nkey == K_INS, Space( 20 ), u7->name ), ;
        m1variant := if( nkey == K_INS, 0, u7->variant ), ;
        mv_uet_oms := if( nkey == K_INS, 0, u7->v_uet_oms ), ;
        ma_uet_oms := if( nkey == K_INS, 0, u7->a_uet_oms ), ;
        mv_uet_pl  := if( nkey == K_INS, 0, u7->v_uet_pl ), ;
        ma_uet_pl  := if( nkey == K_INS, 0, u7->a_uet_pl ), ;
        mv_uet_dms := if( nkey == K_INS, 0, u7->v_uet_dms ), ;
        ma_uet_dms := if( nkey == K_INS, 0, u7->a_uet_dms ), ;
        mvariant, gl_area := { 1, 0, MaxRow() -1, 79, 0 }
      k := MaxRow() -12
      mvariant := inieditspr( A__MENUVERT, menu_variant, m1variant )
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, pc1 + 1, MaxRow() -3, pc2 -1, , ;
        if( nKey == K_INS, 'Добавление', 'Редактирование' ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 3 Say 'Наименование группы услуг' Get mname
      @ k + 2, pc1 + 3 Say 'Вариант расчета' Get mvariant ;
        reader {| x| menu_reader( x, menu_variant, A__MENUVERT, , , .f. ) }
      @ k + 3, pc1 + 3 Say 'Cтоимость УЕТ ОМС для врача          ' Get mv_uet_oms Pict '999.99'
      @ k + 4, pc1 + 3 Say 'Cтоимость УЕТ ОМС для ассистента     ' Get ma_uet_oms Pict '999.99'
      @ k + 5, pc1 + 3 Say 'Cтоимость УЕТ пл.услуг для врача     ' Get mv_uet_pl  Pict '999.99'
      @ k + 6, pc1 + 3 Say 'Cтоимость УЕТ пл.услуг для ассистента' Get ma_uet_pl  Pict '999.99'
      @ k + 7, pc1 + 3 Say 'Cтоимость УЕТ ДМС для врача          ' Get mv_uet_dms Pict '999.99'
      @ k + 8, pc1 + 3 Say 'Cтоимость УЕТ ДМС для ассистента     ' Get ma_uet_dms Pict '999.99'
      status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
      myread()
      If LastKey() != K_ESC .and. !Empty( mname ) .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          addrecn()
          rec := RecNo()
        Else
          g_rlock( forever )
        Endif
        u7->name      := mname
        u7->variant   := m1variant
        u7->v_uet_oms := mv_uet_oms
        u7->a_uet_oms := ma_uet_oms
        u7->v_uet_pl  := mv_uet_pl
        u7->a_uet_pl  := ma_uet_pl
        u7->v_uet_dms := mv_uet_dms
        u7->a_uet_dms := ma_uet_dms
        Unlock
        Commit
        oBrow:gotop()
        Goto ( rec )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. !Empty( u7->name ) .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If !Found()
        ret := 1
      Endif
    Case nKey == K_CTRL_ENTER .and. !Empty( u7->name )
      fs_opl_72( { slist2arr( u7->usl_ins ), slist2arr( u7->usl_del ) } )
      ret := 0
    Endcase
  Endcase
  Return ret

//
Function fs_opl_72( arr )

  Local s, ar, is_write := .f.

  s := 'Список услуг для группы "' + AllTrim( u7->name ) + '"'
  ar := forma_nastr( s, { s }, , arr, @is_write )
  Select U7
  If is_write
    g_rlock( forever )
    Replace u7->usl_ins With arr2slist( ar[ 1 ] ), ;
      u7->usl_del With arr2slist( ar[ 2 ] )
    Unlock
  Endif
  Return Nil

// 02.12.24 редактирование справочников персонала, отделений, учреждений, организации
Function spr_struct_org( k )

  Static sk := 1
  Local str_sem, mas_pmt, mas_msg, mas_fun

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { ;
      '~Персонал', ;
      '~Отделения', ;
      '~Учреждения', ;
      '~Ваша организация' }
    mas_msg := { ;
      'Редактирование справочника персонала', ;
      'Редактирование справочника отделений', ;
      'Редактирование справочника учреждений', ;
      'Редактирование наименования, адреса и банковских реквизитов Вашей организации' }
    mas_fun := { ;
      'spr_struct_org(1)', ;
      'spr_struct_org(2)', ;
      'spr_struct_org(3)', ;
      'spr_struct_org(4)' }
    If is_uchastok > 0
      AAdd( mas_pmt, 'У~частковые врачи' )
      AAdd( mas_msg, 'Привязка участковых врачей к участкам' )
      AAdd( mas_fun, 'spr_struct_org(5)' )
    Endif
    popup_prompt( T_ROW, T_COL + 5, sk, mas_pmt, mas_msg, mas_fun )
  Case k == 1
    edit_pers()
  Case k == 2
    edit_otd()
  Case k == 3
    edit_uch()
//    editDepartments()
  Case k == 4 
    str_sem := 'Редактирование реквизитов организации'
    If g_slock( str_sem )
      f_edit_spr( A__EDIT, get_struct_organiz(), 'реквизитам Вашей организации', ;
        'use_base("organiz")', 0, 1 )
      g_sunlock( str_sem )
      reread_glob_mo() // перечитать массив glob_MO
      hb_main_curOrg := torganizationdb():getorganization()
    Else
      func_error( 4, err_slock() )
    Endif
  Case k == 5
    str_sem := 'Привязка участковых врачей к участкам'
    If g_slock( str_sem )
      f_attach_uch_vrach()
      g_sunlock( str_sem )
    Else
      func_error( 4, err_slock() )
    Endif
  Endcase
  If k > 0
    sk := k
  Endif
  Return Nil

// 11.10.15 привязка участковых врачей к участкам
Function f_attach_uch_vrach()

  Local i, blk, arr := {}, t_arr[ BR_LEN ]

  r_use( dir_server() + 'kartotek', dir_server() + 'kartoteu', 'KART' )
  For i := 1 To 99
    find ( StrZero( i, 2 ) )
    If Found()
      AAdd( arr, i )
    Endif
  Next
  dbCloseArea()
  If Len( arr ) == 0
    Return func_error( 4, 'В картотеке не настроены участки!' )
  Endif
  Private p2blk := {| i| i := iif( Between( p2->kateg, 1, 4 ), p2->kateg, 1 ), ;
    ' (' + { 'вр', 'ср', 'мл', 'пр' }[ i ] + '.) ' }
  g_use( dir_server() + 'mo_uchvr', , 'UV' )
  Index On Str( FIELD->uch, 2 ) to ( cur_dir() + 'tmp' )
  For i := 1 To Len( arr )
    find ( Str( arr[ i ], 2 ) )
    If !Found()
      addrec( 2 )
      uv->uch := arr[ i ]
    Else
      g_rlock( forever )
    Endif
    uv->is := 1
  Next
  dbUnlockAll()
  Set Index To
  Go Top
  Do While !Eof()
    If AScan( arr, uv->uch ) == 0
      g_rlock( forever )
      uv->is := 0
    Endif
    Skip
  Enddo
  dbUnlockAll()
  Index On Str( FIELD->uch, 2 ) to ( cur_dir() + 'tmp' ) For FIELD->is == 1
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ]  := 2
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := '"Привязка" участковых врачей к участкам'
  t_arr[ BR_TITUL_COLOR ] := 'BG+/GR'
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', , .t. }
  t_arr[ BR_COLUMN ] := { { 'Уч-к', {|| Str( uv->uch, 3 ) + ' ' }, blk }, ;
    { ' Участковый врач', {|| PadR( f1_attach_uch_vrach(), 67 ) }, blk } }
  t_arr[ BR_EDIT ] := {| nk, ob| f2_attach_uch_vrach( nk, ob, 'edit' ) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - редактирование участкового врача' ) }
  r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'P2' )
  Select UV
  Go Top
  edit_browse( t_arr )
  Close databases
  Return Nil

// 11.10.15
Function f1_attach_uch_vrach()

  Local s := ''

  Select P2
  If uv->vrach > 0
    Goto ( uv->vrach )
    s := AllTrim( p2->fio ) + Eval( p2blk ) + ' [' + lstr( p2->tab_nom ) + ']'
  Elseif uv->vrachv > 0
    Goto ( uv->vrachv )
    If uv->vrachd > 0
      s := 'взр.: ' + fam_i_o( p2->fio ) + Eval( p2blk ) + ' [' + lstr( p2->tab_nom ) + ']'
      Goto ( uv->vrachd )
      s += ', дети: ' + fam_i_o( p2->fio ) + Eval( p2blk ) + ' [' + lstr( p2->tab_nom ) + ']'
    Else
      s := 'взрослые: ' + AllTrim( p2->fio ) + Eval( p2blk ) + ' [' + lstr( p2->tab_nom ) + ']'
    Endif
  Elseif uv->vrachd > 0
    Goto ( uv->vrachd )
    s := 'дети: ' + AllTrim( p2->fio ) + Eval( p2blk ) + ' [' + lstr( p2->tab_nom ) + ']'
  Endif
  Select UV
  Return s

// 11.10.15
Function f2_attach_uch_vrach( nKey, oBrow, regim )

  Local ret := -1, buf

  If regim == 'edit' .and. nKey == K_ENTER
    Save Screen To buf
    If nkey == K_INS .and. !fl_found
      ColorWin( pr1 + 4, pc1, pr1 + 4, pc2, 'W/W', 'GR+/R' )
    Endif
    Private gl_area := { 1, 0, MaxRow() -1, 79, 0 }, ;
      m1vrach  := uv->vrach, ;
      m1vrachv := uv->vrachv, ;
      m1vrachd := uv->vrachd, ;
      mvrach  := Space( 36 ), ;
      mvrachv := Space( 36 ), ;
      mvrachd := Space( 36 ), ;
      mtab_nom  := 0, ;
      mtab_nomv := 0, ;
      mtab_nomd := 0
    Select P2
    If m1vrach > 0
      Goto ( m1vrach )
      MTAB_NOM := p2->tab_nom
      mvrach := PadR( fam_i_o( p2->fio ) + Eval( p2blk ) + ' ' + ret_tmp_prvs( p2->prvs, p2->prvs_new ), 36 )
    Endif
    If m1vrachv > 0
      Goto ( m1vrachv )
      MTAB_NOMv := p2->tab_nom
      mvrachv := PadR( fam_i_o( p2->fio ) + Eval( p2blk ) + ' ' + ret_tmp_prvs( p2->prvs, p2->prvs_new ), 36 )
    Endif
    If m1vrachd > 0
      Goto ( m1vrachd )
      MTAB_NOMd := p2->tab_nom
      mvrachd := PadR( fam_i_o( p2->fio ) + Eval( p2blk ) + ' ' + ret_tmp_prvs( p2->prvs, p2->prvs_new ), 36 )
    Endif
    Select UV
    tmp_color := SetColor( cDataCScr )
    box_shadow( pr2 -5, 2, pr2 -1, 77, , 'Редактирование участкового врача', cDataPgDn )
    SetColor( cDataCGet )
    @ pr2 -4, 4 Say 'Участ.врач (все возраста)' Get mtab_nom Pict '99999' ;
      valid {| g| v_kart_vrach_spr( g, 1 ) } ;
      When emptyall( m1vrachv, m1vrachd )
    @ Row(), Col() + 1 Get mvrach When .f. Color color14
    @ pr2 -3, 4 Say 'Участ.врач (взрослые)' Get mtab_nomv Pict '99999' ;
      valid {| g| v_kart_vrach_spr( g, 2 ) } ;
      When Empty( m1vrach )
    @ Row(), Col() + 1 Get mvrachv When .f. Color color14
    @ pr2 -2, 4 Say 'Участ.врач (дети)' Get mtab_nomd Pict '99999' ;
      valid {| g| v_kart_vrach_spr( g, 3 ) } ;
      When Empty( m1vrach )
    @ Row(), Col() + 1 Get mvrachd When .f. Color color14
    status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
    myread()
    If LastKey() != K_ESC .and. f_esc_enter( 1 )
      g_rlock( forever )
      uv->vrach  := m1vrach
      uv->vrachv := m1vrachv
      uv->vrachd := m1vrachd
      Unlock
      Commit
      ret := 0
    Endif
    SetColor( tmp_color )
    Restore Screen From buf
  Endif
  Return ret

// 08.11.22 определить врача по табельному номеру для редактирования справочников
Function v_kart_vrach_spr( get, k )

  Local fl := .t.

  Private tmp := ReadVar()

  if &tmp != get:original
    if &tmp == 0
      Do Case
      Case k == 1
        m1vrach := 0
        mvrach := Space( 36 )
      Case k == 2
        m1vrachv := 0
        mvrachv := Space( 36 )
      Case k == 3
        m1vrachd := 0
        mvrachd := Space( 36 )
      Endcase
    elseif &tmp != 0
      Select P2
      find ( Str( &tmp, 5 ) )
      If Found()
        Do Case
        Case k == 1
          m1vrach := p2->kod
          mvrach := PadR( fam_i_o( p2->fio ) + Eval( p2blk ) + ' ' + ret_tmp_prvs( p2->prvs, p2->prvs_new ), 36 )
        Case k == 2
          m1vrachv := p2->kod
          mvrachv := PadR( fam_i_o( p2->fio ) + Eval( p2blk ) + ' ' + ret_tmp_prvs( p2->prvs, p2->prvs_new ), 36 )
        Case k == 3
          m1vrachd := p2->kod
          mvrachd := PadR( fam_i_o( p2->fio ) + Eval( p2blk ) + ' ' + ret_tmp_prvs( p2->prvs, p2->prvs_new ), 36 )
        Endcase
      Else
        fl := func_error( 3, 'Не найден сотрудник с табельным номером ' + lstr( &tmp ) + ' в справочнике персонала!' )
      Endif
      Select UV
    Endif
    If !fl
      &tmp := get:original
      Return .f.
    Endif
    Do Case
    Case k == 1
      update_get( 'mvrach' )
    Case k == 2
      update_get( 'mvrachv' )
    Case k == 3
      update_get( 'mvrachd' )
    Endcase
  Endif
  Return .t.

// 09.09.25 проверка правильности введенного кода ТФОМС
Function valid_kod_tfoms( get )

  Local fl := .t., i, cCode := Left( mkod_tfoms, 6 )

  If ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == cCode } ) ) > 0
    glob_mo := glob_arr_mo()[ i ]
    mname_tfoms := PadR( glob_mo[ _MO_SHORT_NAME ], 60 )
    muroven := get_uroven()
  Else
    fl := func_error( 4, 'Вы ввели несуществующий код МО "' + cCode + '". Попробуйте ешё раз.' )
    mkod_tfoms := get:original
  Endif
  Return fl

// 17.01.26 редактирование справочника отделений
Function edit_otd()

  Local i, j, blk, arr[ US_LEN ], fl

  local aaa

  If input_uch( T_ROW -1, T_COL + 5 ) == NIL
    Return Nil
  Endif
  Private tmp_V002 := create_classif_ffoms( 1, 'V002' ) // PROFIL
  Private tmp_V020 := create_classif_ffoms( 1, 'V020' ) // PROFIL_K
  Private tmp_V006 := create_classif_ffoms( 1, 'V006' ) // USL_OK
  // Private tmp_V008 := create_classif_FFOMS(1, 'V008') // VIDPOM
  // Private tmp_V010 := create_classif_FFOMS(1, 'V010') // IDSP
  Private mm_adres_podr := {}
  Private mm_tiplu := { ;
    { 'стандартный', 0           }, ;  // 1
    { 'скорая медицинская помощь',TIP_LU_SMP  }, ;  // 2
    { 'дисп-ия детей-сирот в стационаре',TIP_LU_DDS  }, ;  // 3
    { 'дисп-ия детей-сирот под опекой',TIP_LU_DDSOP }, ;  // 4
    { 'профилактика несовешеннолетних',TIP_LU_PN   }, ;  // 5
    { 'предварит.осмотры несовешеннолетних',TIP_LU_PREDN }, ;  // 6
    { 'периодич.осмотры несовешеннолетних',TIP_LU_PERN }, ;  // 7
    { 'диспансеризация/профосмотр взрослых',TIP_LU_DVN  }, ;  // 8
    { 'пренатальная диагностика',TIP_LU_PREND }, ;  // 9
    { 'гемодиализ',TIP_LU_H_DIA }, ;  // 10
    { 'перитонеальный диализ',TIP_LU_P_DIA }, ;  // 11
    { 'COVID - углубленная диспансеризация',TIP_LU_DVN_COVID }, ;  // 15
    { 'медицинская реабилитация',TIP_LU_MED_REAB }, ;  // 16
    { 'постановка на наблюдение онкопациентов', TIP_LU_ONKO_DISP }, ;  // 17
	  { 'диспансеризация репродуктивного здоровья',TIP_LU_DRZ } }  // 18

  If glob_mo()[ _MO_KOD_TFOMS ] == '126501'
    ins_array( mm_tiplu, 3, { 'неотложная медицинская помощь', TIP_LU_NMP } )
  Endif
  If AScan( glob_klin_diagn(), 1 ) > 0
    AAdd( mm_tiplu, { 'жидкостная цитология рака шейки матки', TIP_LU_G_CIT } )
  Elseif AScan( glob_klin_diagn(), 2 ) > 0
    AAdd( mm_tiplu, { 'пренатальный скрининг наруш.внутр.разв.', TIP_LU_G_CIT } )
  Endif
  Private mm1tiplu := AClone( mm_tiplu )
  hb_ADel( mm1tiplu, 7, .t. )
  hb_ADel( mm1tiplu, 6, .t. )

  Private mm1lpu1 := AClone( get_f033( glob_mo()[ _MO_KOD_FFOMS ] ) )

  blk := {|| iif( between_date( dbegin, dend ), { 1, 2 }, { 3, 4 } ) }
  arr[ US_BOTTOM   ] := MaxRow() -2
  arr[ US_LEFT     ] := 2
  arr[ US_RIGHT    ] := 77
  arr[ US_BASE     ] := dir_server() + 'mo_otd'
  arr[ US_TITUL    ] := glob_uch[ 2 ]
  arr[ US_TITUL_COLOR ] := 'BG+/GR'
  arr[ US_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t. }
  arr[ US_BLK_FILTER ] := {|| dbSetFilter( {|| kod_lpu == glob_uch[ 1 ] }, 'kod_lpu == glob_uch[1]' ) }
  arr[ US_BLK_WRITE ] := {|| __us->kod_lpu := glob_uch[ 1 ] }
  arr[ US_COLUMN   ] := { { ' Наименование отделения', {|| name }, blk }, ;
    { ' ', {|| iif( Empty( KOD_PODR ), ' ', '√' ) }, blk }, ;
    { 'Сокр.', {|| short_name }, blk }, ;
    { ' Вид листа учёта', {|| PadR( inieditspr( A__MENUVERT, mm_tiplu, tiplu ), 19 ) }, blk }, ;
    { ' Профиль', {|| PadR( inieditspr( A__MENUVERT, getv002(), profil ), 15 ) }, blk } ;
    }
  arr[ US_BLK_DEL  ] := {| _k| fdel_otd( _k ) }
  arr[ US_IM_PADEG ] := arr[ US_SEMAPHORE ] := 'отделения'
  arr[ US_ROD_PADEG ] := 'отделений'
  arr[ US_EDIT_SPR ] := { ;
    { 'name', 'C', 30, 0, , , Space( 30 ), , 'Наименование отделения' }, ;
    { 'short_name', 'C', 5, 0, , , Space( 5 ), , 'Сокращённое наименование отделения' }, ;
    { 'TIPLU', 'N', 2, 0, , ;
    {| x| menu_reader( x, mm1tiplu, A__MENUVERT, , , .f. ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_tiplu, x ) }, ;
    'Вид листа учёта при вводе данных' }, ;
    { 'LPU_1', 'C',17, 0, , ;
    {| x| menu_reader( x, mm1lpu1, A__MENUVERT, , , .f. ) }, ;
    0, {| x| inieditspr( A__MENUVERT, get_f033( glob_mo()[ _MO_KOD_FFOMS ] ), x ) }, ;
    'Структурное подразделение по ФФОМС' }, ;
    { 'TIP_OTD', 'N', 2, 0, , ;
    {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
    'Является данное отделение приёмным покоем стационара' }, ;
    { 'PROFIL', 'N', 3, 0, , ;
    {| x| menu_reader( x, tmp_V002, A__MENUVERT_SPACE, , , .f. ) }, ;
    0, {| x| inieditspr( A__MENUVERT, getv002(), x ) }, ;
    'Профиль мед.помощи' }, ;
    { 'PROFIL_K', 'N', 3, 0, , ;
    {| x| menu_reader( x, tmp_V020, A__MENUVERT_SPACE, , , .f. ) }, ;
    0, {| x| inieditspr( A__MENUVERT, getv020(), x ) }, ;
    'Профиль койки' }, ;
    { 'IDUMP', 'N', 2, 0, , ;
    {| x| menu_reader( x, tmp_V006, A__MENUVERT, , , .f. ) }, ;
    0, {| x| inieditspr( A__MENUVERT, getv006(), x ) }, ;
    'Условия оказания медицинской помощи' }, ;
    { 'KOD_PODR', 'C', 25, 0, , ;
    {| x| menu_reader( x, { {| k, r, c| get_kod_podr( k, r, c ) } }, A__FUNCTION, , , .f. ) }, ;
    '', {| x| ini_kod_podr( x ) }, ;
    'Код подразделения из паспорта ЛПУ' }, ;
    { 'ADDRESS', 'C', 150, 0, , , Space( 150 ), , 'Адрес' }, ;
    { 'dbegin', 'D', 8, 0, , , BoY( sys_date ), , ;
    'Дата начала работы в задаче ОМС' }, ;
    { 'dend', 'D', 8, 0, , , CToD( '' ), , ;
    '     Дата окончания работы в задаче ОМС' };
    }
  If is_otd_dep
    ins_array( arr[ US_EDIT_SPR ], 6, { 'CODE_DEP', 'N', 2, 0, , ;
      {| x| menu_reader( x, mm_otd_dep, A__MENUVERT_SPACE, , , .f. ) }, ;
      0, {| x| inieditspr( A__MENUVERT, mm_otd_dep, x ) }, ;
      'По справочнику ТФОМС' } )
  Endif
  If is_task( X_PLATN )
    AAdd( arr[ US_EDIT_SPR ], { 'dbeginp', 'D', 8, 0, , , BoY( sys_date ), , ;
      'Дата начала работы в задаче "Платные услуги"' } )
    AAdd( arr[ US_EDIT_SPR ], { 'dendp', 'D', 8, 0, , , CToD( '' ), , ;
      '     Дата окончания работы в задаче "Платные услуги"' } )
  Endif
  If is_task( X_ORTO )
    AAdd( arr[ US_EDIT_SPR ], { 'dbegino', 'D', 8, 0, , , BoY( sys_date ), , ;
      'Дата начала работы в задаче "Ортопедия"' } )
    AAdd( arr[ US_EDIT_SPR ], { 'dendo', 'D', 8, 0, , , CToD( '' ), , ;
      '     Дата окончания работы в задаче "Ортопедия"' } )
  Endif
  AAdd( arr[ US_EDIT_SPR ], { 'PLAN_VP', 'N', 6, 0, , , 0, , 'План врачебных приемов на месяц' } )
  AAdd( arr[ US_EDIT_SPR ], { 'PLAN_PF', 'N', 6, 0, , , 0, , 'План профилактик на месяц' } )
  AAdd( arr[ US_EDIT_SPR ], { 'PLAN_PD', 'N', 6, 0, , , 0, , 'План приемов на дому на месяц' } )
  edit_u_spr( 1, arr )
  Return Nil

// 08.11.22
Function fdel_otd( k )

  Local _fl, i, tmp_select := Select()

  r_use( dir_server() + 'mo_pers', , '__B' )
  dblocateprogress( {|| __b->otd == k } )
  _fl := !Found()
  dbCloseArea()
  If _fl
    r_use( dir_server() + 'human', dir_server() + 'humann', '__B' )
    For i := 0 To 9
      find ( Str( i, 1 ) + Str( k, 3 ) ) // index on str(FIELD->tip_h, 1)+ str(FIELD->otd, 3)+...
      If Found()
        _fl := .f.
        Exit
      Endif
    Next
    dbCloseArea()
  Endif
  If _fl
    r_use( dir_server() + 'hum_p', dir_server() + 'hum_pn', '__B' )
    find ( Str( k, 3 ) ) // index on str(otd, 3)+...
    _fl := !Found()
    dbCloseArea()
  Endif
  Select ( tmp_select )
  Return _fl

// 19.11.25
Function get_kod_podr( k, r, c )

  Static arr
  Local ret, ret_arr, tmp_select
  local gMO

  gMo := glob_mo()[ _MO_KOD_TFOMS ]
  If arr == Nil // только при первом вызове
    arr := {}
    tmp_select := Select()
    r_use( dir_exe() + '_mo_podr', cur_dir() + '_mo_podr', 'PODR' )
    podr->( dbSeek( gMo ) )    // find ( glob_mo[ _MO_KOD_TFOMS ] )
    Do While podr->codemo == gMo .and. ! podr->( Eof() )
      AAdd( arr, { '(' + AllTrim( podr->KODOTD ) + ') ' + AllTrim( podr->NAMEOTD ), podr->KODOTD } )
      podr->( dbSkip() )    //  Skip
    Enddo
    dbCloseArea()
    Select ( tmp_select )
  Endif
  popup_2array( arr, -r, c, k, 1, @ret_arr, 'Выбор из паспорта ЛПУ', 'GR+/RB', 'BG+/RB,N/BG' )
  If ValType( ret_arr ) == 'A'
    ret := Array( 2 )
    ret[ 1 ] := ret_arr[ 2 ]
    ret[ 2 ] := ret_arr[ 1 ]
  Endif
  Return ret

// 19.11.25
Function ini_kod_podr( lkod )

  Local s := Space( 10 ), tmp_select := Select()

  r_use( dir_exe() + '_mo_podr', cur_dir() + '_mo_podr', 'PODR' )
  podr->( dbSeek( glob_mo()[ _MO_KOD_TFOMS ] + PadR( Upper( lkod ), 25 ) ) )    //   find ( glob_mo[ _MO_KOD_TFOMS ] + PadR( Upper( lkod ), 25 ) )
  If podr->( Found() )
    s := '(' + AllTrim( podr->KODOTD ) + ') ' + AllTrim( podr->NAMEOTD )
  Endif
  dbCloseArea()
  Select ( tmp_select )
  Return s

// 24.08.24 редактирование справочника учреждений
Function edit_uch()

  Local blk, arr[ US_LEN ]
  local obj, menu_users := {}

  private m1idchief

  // собирем доступных сотрудников
  for each obj in TEmployeeDB():getList()
    aadd( menu_users, { obj:Name, obj:ID } )
  next
  ASort( menu_users, , , { | x, y | x[ 1 ] < y[ 1 ] } )
  hb_AIns( menu_users, 1, { 'Сотрудник не выбран', 0 }, .t. )

  blk := {|| iif( between_date( dbegin, dend ), { 1, 2 }, { 3, 4 } ) }
  arr[ US_BOTTOM   ] := MaxRow() -2
  arr[ US_LEFT     ] := T_COL + 5
  arr[ US_RIGHT    ] := arr[ US_LEFT ] + 48
  arr[ US_BASE     ] := dir_server() + 'mo_uch'
  arr[ US_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t. }
  arr[ US_COLUMN   ] := { { ' Наименование', {|| name }, blk }, ;
    { 'Сокр.;наим.', {|| SHORT_NAME }, blk }, ;
    { 'Работа с;талоном', {|| PadC( inieditspr( A__MENUVERT, mm_danet, is_talon ), 8 ) }, blk } }
  arr[ US_BLK_DEL  ] := {| _k| fdel_uch( _k ) }
  arr[ US_IM_PADEG ] := arr[ US_SEMAPHORE ] := 'учреждения'
  arr[ US_ROD_PADEG ] := 'учреждений' 
  arr[ US_EDIT_SPR ] := { { 'name', 'C', 30, 0, , , Space( 30 ), , 'Наименование учреждения' }, ;
    { 'short_name', 'C', 5, 0, , , Space( 5 ), , 'Сокращённое наименование' }, ;
    { 'ADDRESS', 'C', 150, 0, , , Space( 150 ), , 'Адрес' }, ;
    { 'IDCHIEF', 'N', 4, 0, , ;
      { | x | menu_reader( x, menu_users, A__MENUVERT, , , .f. ) }, ;
      , { | x | inieditspr( A__MENUVERT, menu_users, x ) }, ;
      'Таб.№ руководителя' }, ;
    { 'is_talon', 'N', 1, 0, , ;
      { | x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }, ;
      0, { | x | inieditspr( A__MENUVERT, mm_danet, x ) }, ;
      'Работаем со стат.талоном?' }, ;
    { 'dbegin', 'D', 8, 0, , , BoY( sys_date ), , ;
    'Дата начала работы с учреждением' }, ;
    { 'dend', 'D', 8, 0, , , CToD( '' ), , ;
    '     Дата окончания работы' };
    }
  edit_u_spr( 1, arr )
  Return Nil

// 08.11.22
Function fdel_uch( k )

  Local _fl, tmp_select := Select()

  r_use( dir_server() + 'mo_otd', , '__B' )
  dblocateprogress( {|| __b->kod_lpu == k } )
  _fl := !Found()
  dbCloseArea()
  Select ( tmp_select )
  Return _fl

// 01.04.23 редактирование справочника прочих компаний
Function edit_strah()

  Static mas_edit := { '~Просмотр', ;
    '~Редактирование', ;
    '~Добавление', ;
    '~Удаление' }

  // Local arr := aclone(gmenu_strah)
  Local arr := AClone( get_strah() )
  Local i := 1, k, buf := SaveScreen(), str_sem := 'Редактирование прочих компаний'

  If !g_slock( str_sem )
    Return func_error( 4, err_slock() )
  Endif
  If ( k := AScan( arr, {| x| Lower( x[ 1 ] ) == 'tfoms' } ) ) > 0
    del_array( arr, k )
  Endif
  Do While i > 0
    If ( i := popup_prompt( T_ROW, T_COL + 5, i, mas_edit, , , , .f. ) ) == A__APPEND
      If ( k := f_edit_spr( A__APPEND, arr, 'прочей компании', ;
          'use_base("str_komp")', 2, , , , , , 'f_emp_strah' ) ) > 0
        glob_strah[ 1 ] := k
      Endif
    Elseif i != 0 .and. ;
        ( k := popup_edit( dir_server() + 'str_komp', T_ROW + i + 1, T_COL + 5, ;
        T_ROW + i + 7, glob_strah[ 1 ], PE_RETURN, , , , {|| !Between( tfoms, 44, 47 ) } ) ) != NIL
      glob_strah := k
      f_edit_spr( i, arr, 'прочей компании', ;
        'use_base("str_komp")', 2, k[ 1 ], , 'fdel_strah', , , 'f_emp_strah' )
    Endif
  Enddo
  g_sunlock( str_sem )
  RestScreen( buf )
  Return Nil

// редактирование справочника комитетов (МО)
Function edit_komit( d )

  Static mas_edit := { '~Просмотр', ;
    '~Редактирование', ;
    '~Добавление', ;
    '~Удаление' }
  Local i := 1, k, buf := SaveScreen(), str_sem := 'Редактирование комитетов (МО)'

  If !g_slock( str_sem )
    Return func_error( 4, err_slock() )
  Endif
  Do While i > 0
    If ( i := popup_prompt( T_ROW, T_COL + 5, i, mas_edit, , , , .f. ) ) == A__APPEND
      If ( k := f_edit_spr( A__APPEND, get_komitet(), 'комитету (МО)', ;
          'use_base("komitet")', 2, , , , , , 'f_emp_strah' ) ) > 0
        glob_komitet[ 1 ] := k
      Endif
    Elseif i != 0 .and. ;
        ( k := popup_edit( dir_server() + 'komitet', T_ROW + i + 1, T_COL + 5, ;
        T_ROW + i + 7, glob_komitet[ 1 ], PE_RETURN ) ) != NIL
      glob_komitet := k
      f_edit_spr( i, get_komitet(), 'комитету (МО)', ;
        'use_base("komitet")', 2, k[ 1 ], , 'fdel_komit', , , 'f_emp_strah' )
    Endif
  Enddo
  g_sunlock( str_sem )
  RestScreen( buf )
  Return Nil

//
Function fdel_strah( k )

  Local fl

  If ! ( fl := fdel_ksc( 1, k ) )
    func_error( 4, 'Данная компания встречается в других базах данных!' )
  Endif
  Return fl

//
Function fdel_komit( k )

  Local fl

  If !( fl := fdel_ksc( 3, k ) )
    func_error( 4, 'Данный комитет (МО) встречается в других базах данных!' )
  Endif
  Return fl

// 08.11.22
Function fdel_ksc( n, k )

  Local fl := .t., buf, i, afile := { 'kartotek', 'human' }

  If k == 1
    buf := save_maxrow()
    stat_msg( 'Ждите! Производится проверка на допустимость удаления.' )
    For i := 1 To Len( afile )
      r_use( dir_server() + afile[ i ], , 'KK' )
      Locate For kk->komu == n .and. kk->str_crb == mkod ;
        progress { 'GR+/B', 'GR+/B', 'W*/B' } NUMPROCENT
      fl := !Found()
      dbCloseArea()
      If !fl
        Exit
      Endif
    Next
    rest_box( buf )
  Endif
  Return fl

//
Function f_emp_strah( k )

  Local fl := .t.

  If k == 1 .and. Empty( mname )
    fl := func_error( 4, 'Поле НАЗВАНИЕ не должно быть пустым!' )
  Endif
  Return fl
