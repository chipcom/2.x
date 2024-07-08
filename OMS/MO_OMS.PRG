// mo_oms.prg - режимы ввода данных для задачи ОМС
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

//
Function begin_task_oms()

  Static n_zapusk := 0
  Local i, fl := .t.

  If n_zapusk == 0
    ++n_zapusk
    Public arr_opl_7, len_arr_7, mem_oms_pole := 0
  Endif
  If g_sislock( sem_vagno_task[ X_OMS ] )
    fl := f_err_sem_vagno_task( X_OMS )
  Elseif copy_tools_ini()
    tools_ini_oms( 1, 0, 0 )
    i := getinivar( tmp_ini, { { 'RAB_MESTO', 'oms_pole', '0' } } )
    If i[ 1 ] != NIL
      mem_oms_pole := Int( Val( i[ 1 ] ) )
    Endif
  Else
    fl := .f.
  Endif

  Return fl

// разные функции для oms_sluch()

// 10.02.17
Function get_fio_kart( k, r, c )

  Local s := '', ret, buf, tmp_keys

  Private fl_write_kartoteka := .f.

  buf := SaveScreen()
  tmp_keys := my_savekey()
  edit_kartotek( mkod_k, r + 1, , .t., mkod )
  my_restkey( tmp_keys )
  If fl_write_kartoteka
    r_use( dir_server + 'kartote2', , 'KART2' )
    Goto ( mkod_k )
    r_use( dir_server + 'kartote_', , 'KART_' )
    Goto ( mkod_k )
    r_use( dir_server + 'kartotek', , 'KART' )
    Goto ( mkod_k )
    M1FIO := 1
    mfio := kart->fio
    mpol := kart->pol
    mdate_r := kart->date_r
    mfio_kart := _f_fio_kart()
    If Type( 'mn_data' ) == 'D'
      If Type( 'm1novor' ) == 'N' .and. Type( 'mdate_r2' ) == 'D' .and. m1novor > 0
        mvozrast := count_years( mdate_r2, mn_data )
      Else
        mvozrast := count_years( mdate_r, mn_data )
      Endif
    Endif
    If Type( 'm1novor' ) == 'N' .and. m1novor > 0
      M1VZROS_REB := 1 // ребенок
    Else
      M1VZROS_REB := kart->VZROS_REB
    Endif
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    m1RAB_NERAB := kart->RAB_NERAB
    m1komu      := kart->komu
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    msmo        := kart_->SMO
    m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
    mokato      := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
    mkomu       := inieditspr( A__MENUVERT, mm_komu, m1komu )
    mvidpolis   := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
    If !Empty( mn_data )
      fv_date_r( mn_data, .f. )
    Endif
    f_valid_komu(, -1 )
    m1company   := Int( Val( msmo ) )
    mcompany    := inieditspr( A__MENUVERT, mm_company, m1company )
    If m1company == 34
      mnameismo := ret_inogsmo_name( 1, , .t. ) // открыть и закрыть
    Elseif !( Left( msmo, 2 ) == '34' )
      m1ismo := msmo
      msmo := '34'
      m1company := 34
      mismo := init_ismo( m1ismo )
    Endif
    If m1company == 34
      If !Empty( mismo )
        mcompany := mismo
      Elseif !Empty( mnameismo )
        mcompany := mnameismo
      Endif
    Endif
    If !Empty( mcompany )
      old_name_smo := PadR( mcompany, 38 )
    Endif
    If m1komu > 0
      m1company := 0
      mcompany := ''
      If eq_any( m1komu, 1, 3 )
        m1company := m1str_crb := kart->STR_CRB
        mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
      Endif
    Endif
    mcompany := PadR( mcompany, 38 )
    If eq_any( is_uchastok, 1, 3 )
      s := amb_kartan()
    Elseif mem_kodkrt == 2
      s := lstr( mkod_k )
    Endif
    If !Empty( s ) .and. ValType( MUCH_DOC ) == 'C'
      If Empty( MUCH_DOC )
        MUCH_DOC := PadR( s, 10 )
      Elseif is_uchastok == 3 .and. !( MUCH_DOC == PadR( s, 10 ) )
        MUCH_DOC := PadR( s, 10 )
      Endif
    Endif
    Close databases
  Endif
  RestScreen( buf )

  Return ret

// 24.02.16
Function _f_fio_kart()

  Return PadR( AllTrim( mfio ) + ' ' + iif( mpol == 'М', '(муж.)', '(жен.)' ), 50 )

// проверка правильности ввода стоматологического статуса больного
Function f_valid_status_st( get )

  Local i, s := '', fl := .t.

  For i := 1 To Len( mstatus_st )
    If !Empty( c := SubStr( mstatus_st, i, 1 ) ) .and. !( c $ yes_d_plus )
      s += c
    Endif
  Next
  If !Empty( s )
    fl := func_error( 4, 'Следующие символы не разрешены для ввода в данном поле: "' + s + '"' )
  Endif

  Return fl

// действия в ответ на выбор в меню 'Новорожденный? (да/нет)'
Function f_valid_novor( get, old )

  If m1novor != old .and. old != NIL
    If old == 0 // было 'нет' - стало 'да'
      mcount_reb := 1
      mDATE_R2 := sys_date - 5
      mpol2 := 'М'
    Else
      mcount_reb := 0
      mDATE_R2 := CToD( '' )
      mpol2 := ' '
    Endif
    update_get( 'mcount_reb' )
    update_get( 'mDATE_R2' )
    update_get( 'mpol2' )
  Endif
  fv_date_r( mn_data )

  Return .t.

// действия в ответ на выбор в меню 'Принадлежность счёта'
Function f_valid_komu( get, old )

  Local tmp_select := Select()

  If m1komu != old .and. old != NIL
    m1company := 0
    mcompany := Space( 30 )
    mm_company := {}
    If m1komu == 0 // ОМС
      mm_company := AClone( glob_arr_smo )
    Elseif m1komu == 1 // Прочие компании
      r_use( dir_server + 'str_komp' )
      Index On Upper( name ) to ( cur_dir + 'tmp_comp' ) For !Between( tfoms, 44, 47 )
      dbEval( {|| AAdd( mm_company, { AllTrim( name ), kod } ) } )
      Use
    Elseif m1komu == 3 // Комитеты/МО
      r_use( dir_server + 'komitet' )
      Index On Upper( name ) to ( cur_dir + 'tmp_comp' )
      dbEval( {|| AAdd( mm_company, { AllTrim( name ), kod } ) } )
      Use
    Endif
    If eq_any( m1komu, 1, 3 ) .and. Empty( mm_company )
      mm_company := { { 'Пустой справочник', 0 } }
    Endif
    update_get( 'mcompany' )
  Endif
  Select ( tmp_select )

  Return .t.

// 09.12.23 действия в ответ на выбор в меню 'Условия оказания медицинской помощи'
Function f_valid_usl_ok( get, old, is_input )

  Local _y, _m, s

  Default is_input To .t.

  If m1usl_ok != old .and. m1usl_ok > 0 .and. old != NIL
    mm_rslt := {}
    If m1usl_ok == USL_OK_POLYCLINIC .and. is_input // поликлиника - убираем диспансеризацию
      AEval( tmp_V009, {| x| iif( x[ 5 ] == m1usl_ok .and. x[ 2 ] < 316, AAdd( mm_rslt, x ), nil ) } )
    Else
      AEval( tmp_V009, {| x| iif( x[ 5 ] == m1usl_ok, AAdd( mm_rslt, x ), nil ) } )
    Endif
    mm_ishod := {}
    AEval( tmp_V012, {| x| iif( x[ 5 ] == m1usl_ok, AAdd( mm_ishod, x ), nil ) } )
    If get != NIL
      m1rslt := 0
      mrslt := ''
      If AScan( mm_rslt, {| x| x[ 2 ] == rslt_umolch } ) > 0
        m1rslt := rslt_umolch
        mrslt := inieditspr( A__MENUVERT, tmp_V009, m1rslt )
      Endif
      m1ishod := 0
      mishod := ''
      If AScan( mm_ishod, {| x| x[ 2 ] == ishod_umolch } ) > 0
        m1ishod := ishod_umolch
        mishod := inieditspr( A__MENUVERT, tmp_V012, m1ishod )
      Endif
      mrslt  := PadR( mrslt, 58 )
      mishod := PadR( mishod, 20 )
      update_get( 'mrslt' )
      update_get( 'mishod' )
    Endif
  Endif
  If is_input .and. Type( 'p_nstr_vnr' ) == 'N'
    s := ''
    input_vnr := input_vnrm := .f.
    If m1usl_ok == USL_OK_HOSPITAL // стационар
      count_ymd( iif( M1NOVOR == 1, mdate_r2, mdate_r ), mn_data, @_y, @_m, )
      // if _y == 0 .and. _m < 7 // ребёнок не старше 6 месяцев
      If _y == 0 // ребёнок до года
        s := p_str_vnr
        input_vnr := .t.
      Else
        MVNR := Space( 4 )
      Endif
      If mpol == 'Ж' .and. _y > 10 // 'мамаша' старше 10 лет
        s := p_str_vnrm
        input_vnrm := .t.
      Else
        MVNR1 := MVNR2 := MVNR3 := Space( 4 )
      Endif
    Else // другие условия оказания мед.помощи
      MVNR := MVNR1 := MVNR2 := MVNR3 := Space( 4 )
    Endif
    @ p_nstr_vnr, 1 Say PadR( s, MaxCol() ) Color cDataCGet
    If input_vnr
      update_get( 'MVNR' )
    Elseif input_vnrm
      update_get( 'MVNR1' )
      update_get( 'MVNR2' )
      update_get( 'MVNR3' )
    Endif
    // if !(m1usl_ok == 1 .and. (is_ksg_VMP .or. is_21_VMP .or. is_12_VMP .or. is_22_VMP .or. is_23_VMP))
    // if !(m1usl_ok == 1 .and. (is_19_VMP .or. is_20_VMP .or. is_21_VMP .or. is_22_VMP .or. is_23_VMP))
    If !( m1usl_ok == USL_OK_HOSPITAL .and. is_MO_VMP )
      mvmp := 'нет'
      m1vmp := 0
      MVIDVMP := Space( 70 )
      M1VIDVMP := Space( 12 ) // вид ВМП по справочнику V018
      MMETVMP := Space( 67 )
      M1METVMP := 0        // метод ВМП по справочнику V019
      update_get( 'MVIDVMP' )
      update_get( 'MMETVMP' )
    Endif
  Endif

  Return .t.

// действия в ответ на выбор в меню 'Результат'
Function f_valid_rslt( g, o )

  If is_death( m1RSLT )
  Else
  Endif

  Return .t.

// действия в ответ на выбор в меню 'Госпитализация'
Function f_valid_f14_ekst( get, old )

  // Static Function f_valid_f14_ekst(get, old)

  If M1F14_EKST != old .and. old != NIL
  Endif

  Return .t.

// 13.02.22 действия в ответ на выбор в меню 'ВМП'
Function f_valid_vmp( get, old )

  If m1vmp != old .and. old != NIL
    If m1vmp == 0
      mTAL_NUM := Space( 20 )
      mTAL_D := mTAL_P := CToD( '' )
      MVIDVMP := Space( 70 )
      M1VIDVMP := Space( 12 ) // вид ВМП по справочнику V018
      MMETVMP := Space( 67 )
      M1METVMP := 0        // метод ВМП по справочнику V019
      mmodpac := Space( 71 )
      m1modpac := 0        // модель пациента
    Else
      input_ad_cr := .f.
      mad_cr := Space( 66 )
      m1ad_cr := Space( 10 )
    Endif
    update_get( 'mTAL_NUM' )
    update_get( 'mTAL_D' )
    update_get( 'mTAL_P' )
    update_get( 'MVIDVMP' )
    update_get( 'MMETVMP' )
    update_get( 'mmodpac' )
  Endif

  Return .t.

// действия в ответ на выбор в меню 'Больничный'
Function f_valid_bolnich( get, old )

  If m1bolnich != old .and. old != NIL
    If m1bolnich == 0
      MDATE_B_1 := CToD( '' )
      MDATE_B_2 := CToD( '' )
    Endif
    If m1bolnich != 2
      mrodit_dr  := CToD( '' )
      mrodit_pol := ' '
    Endif
    If m1bolnich > 0
      MDATE_B_1 := mn_data
      MDATE_B_2 := mk_data
      If m1bolnich == 2                         // по умолчанию больничный выдали
        mrodit_dr  := AddMonth( sys_date, -25 * 12 ) // 25 летней
        mrodit_pol := 'Ж'                       // матери
      Endif
    Endif
    update_get( 'MDATE_B_1' )
    update_get( 'MDATE_B_2' )
    update_get( 'mrodit_dr' )
    update_get( 'mrodit_pol' )
  Endif

  Return .t.

// проверка введённого цифрами повода обращения
Function val_st_pov( get )

  Local i, fl := .t.

  If ( i := AScan( stm_povod, {| x| x[ 2 ] == m1povod } ) ) > 0
    mpovod := PadR( stm_povod[ i, 1 ], 23 )
    update_get( 'mpovod' )
  Else
    fl := func_error( 4, 'Недопустимый шифр повода обращения' )
    m1povod := get:original
  Endif

  Return fl

// проверка введённого цифрами вида травмы
Function val_st_trav( get )

  Local i, fl := .t.

  If ( i := AScan( stm_travma, {| x| x[ 2 ] == m1travma } ) ) > 0
    mtravma := PadR( stm_travma[ i, 1 ], 34 )
    update_get( 'mtravma' )
  Else
    fl := func_error( 4, 'Недопустимый шифр вида травмы' )
    m1travma := get:original
  Endif

  Return fl

// 11.08.20
Function inp_dop_diag()

  Local arr, jt, mshifr, tmp_keys, tmp_gets, buf, tmp_color

  Private mvar := Upper( ReadVar() )

  If Empty( mvar ) .or. !( Type( mvar ) == 'C' )
    Return .t.
  Endif
  mshifr := &mvar
  arr := { 'MKOD_DIAG', ;
    'MKOD_DIAG2', ;
    'MKOD_DIAG3', ;
    'MKOD_DIAG4', ;
    'MSOPUT_B1', ;
    'MSOPUT_B2', ;
    'MSOPUT_B3', ;
    'MSOPUT_B4' }
  If !Empty( mshifr ) .and. ( jt := AScan( arr, mvar ) ) > 0
    tmp_keys := my_savekey()
    Save gets To tmp_gets
    buf := SaveScreen()
    change_attr()
    Private pr := 9, m1, m2
    m1 := adiag_talon[ jt * 2 -1 ]
    m2 := adiag_talon[ jt * 2  ]
    box_shadow( pr, 2, pr + 4, 77, color0, 'Диагноз "' + AllTrim( mshifr ) + '"', 'W+/BG' )
    tmp_color := SetColor( 'N/BG, W+/N, , , B/BG' )
    @ pr + 1, 5 Say 'Характер заболевания (1, 2) ' Get m1 Pict '9' valid {| g| v_i_d_diag( g, 1 ) }
    @ pr + 2, 5 Say 'Диспансерный учет  (1, 2, 3) ' Get m2 Pict '9' valid {| g| v_i_d_diag( g, 2 ) }
    status_key( '^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода' )
    myread()
    If LastKey() != K_ESC
      adiag_talon[ jt * 2 -1 ] := m1
      adiag_talon[ jt * 2  ] := m2
    Endif
    Keyboard Chr( K_ENTER )
    RestScreen( buf )
    Restore gets From tmp_gets
    my_restkey( tmp_keys )
    SetColor( tmp_color )
    SetCursor()
    put_dop_diag()
  Endif

  Return .t.

//
Static Function v_i_d_diag( get, par )

  Local fl := .t., mval, s := ''

  Private mvar := Upper( ReadVar() )

  mval := &mvar
  If mval > 0
    Do Case
    Case par == 1
      If ( fl := Between( m1, 1, 2 ) )
        s := { 'Выявлено впервые в жизни (или острое)', ;
          'Ранее зарегистрированное заболевание' }[ m1 ]
      Endif
    Case par == 2
      If ( fl := Between( m2, 1, 3 ) )
        s := { 'Состоит', ;
          'Взят', ;
          'Снят' }[ m2 ]
      Endif
    Endcase
  Endif
  @ pr + par, 35 Say PadR( s, 42 ) Color 'G+/BG'
  If !fl
    &mvar := get:original
    mybell()
  Endif

  Return fl

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
Static Function get_srf( k, r, c )

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
  Use ( cur_dir + 'tmp_srf' ) New Alias TMP
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
Static Function f2_srf( nk, ob )

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
Static Function when_ismo( get, old )

  Local s

  If !( m1okato == old ) .and. old != NIL
    m1ismo := ''
    mismo := Space( Len( mismo ) )
  Endif
  mm_ismo := {}
  If !Empty( m1okato )
    r_use( dir_exe + '_mo_smo', cur_dir + '_mo_smo', 'SMO' )
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

// 27.03.24 Добавление листка учета лечения больного
Function oms_add()

  Local buf, str_sem

  change_sys_date() // перечитать системную дату (для травмпунктов, работающих ночами)
  If input_uch( T_ROW - 1, T_COL + 5, sys_date ) != Nil .and. input_otd( T_ROW - 1, T_COL + 5, sys_date ) != NIL
    buf := box_shadow( 0, 41, 2, 77, color13 )
    @ 1, 42 Say PadC( glob_otd[ 2 ], 35 ) Color color14
    Private fl_edit_oper, fl_edit_smp, fl_edit_DDS, fl_edit_DVN, fl_edit_DVN_COVID, fl_edit_dvn_drz
    Do While .t.
      fl_edit_oper := fl_edit_smp := fl_edit_DDS := fl_edit_DVN := fl_edit_DVN_COVID := fl_edit_dvn_drz := .f.
      polikl_kart( 1 )
      If fl_edit_oper
        str_sem := 'Редактирование человека ' + lstr( glob_perso )
        If g_slock( str_sem )
          oms_usl_sluch( glob_perso, glob_kartotek, .f. )

          If check_oms_sluch_lek_pr( glob_perso )
            oms_sluch_lek_pr( glob_perso, glob_kartotek, .f. )
          Endif

          g_sunlock( str_sem )
        Else
          func_error( 4, 'В данный момент с карточкой этого пациента работает другой пользователь.' )
        Endif
      Elseif fl_edit_smp .or. fl_edit_DDS .or. fl_edit_DVN .or. fl_edit_DVN_COVID .or. fl_edit_dvn_drz
        // не выходим из цикла
      Else
        Exit
      Endif
    Enddo
    If buf != NIL
      rest_box( buf )
    Endif
  Endif

  Return Nil

// Редактирование листка учета лечения больного
Function oms_edit( k )

  Static sk := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { 'Выбор по учреждению/отделению', ;
      'Выбор по отчётному периоду', ;
      'Выбор по ошибке из ТФОМС', ;
      'Выбор по акту снятия из СМО' }
    mas_msg := { 'Редактирование случая с выбором по учреждению/отделению', ;
      'Редактирование случая с выбором по отчётному периоду', ;
      'Редактирование случая с выбором по конкретной ошибке из ТФОМС', ;
      'Редактирование повторно выставленных случаев (после ввода актов снятия из СМО)' }
    mas_fun := { 'oms_edit(1)', ;
      'oms_edit(2)', ;
      'oms_edit(3)', ;
      'oms_edit(4)' }
    // set key K_CTRL_F11 to my_extract_reestr()
    // set key K_CTRL_F12 to create_main_base_from_reestrs()
    // test_definition_KSG()
    popup_prompt( T_ROW, T_COL + 5, sk, mas_pmt, mas_msg, mas_fun )
    // set key K_CTRL_F12 to
    // set key K_CTRL_F11 to
  Case k == 1
    f1oms_edit()
  Case k == 2
    f2oms_edit()
  Case k == 3
    If !find_unfinished_reestr_sp_tk()
      f3oms_edit()
    Endif
  Case k == 4
    f4oms_edit()
  Endcase
  If k > 0
    sk := k
  Endif

  Return Nil

// 20.05.22 Редактирование случая с выбором по учреждению/отделению
Function f1oms_edit()

  Static si := 1, sk := 1
  Local buf, mas_pmt, arr_m, str_sem, i, buf24, buf_scr, dostup, k := 1, ;
    str_error, mtitul, str_find
  Local lek_pr := .f.

  If ( arr_m := input_year() ) != Nil .and. ;
      input_uch( T_ROW - 1, T_COL + 5, sys_date ) != Nil .and. ;
      iif( yes_h_otd == 1, input_otd( T_ROW - 1, T_COL + 5, sys_date ) != NIL, .t. )
    If yes_vypisan == B_END
      If ( k := popup_prompt( T_ROW, T_COL + 5, sk, ;
          { '~Не закончившие лечение', '~Закончившие лечение' } ) ) > 0
        sk := k
      Endif
      If k == 0
        Return Nil
      Endif
    Endif
    dostup := yes_vypisan + k - 1
    str_error := 'В данный момент'
    mtitul := AllTrim( glob_uch[ 2 ] )
    str_find := Str( dostup, 1 )
    If yes_h_otd == 1
      mtitul += ' [ ' + AllTrim( glob_otd[ 2 ] ) + ' ]'
      str_error += ' в данном отделении'
      str_find += Str( glob_otd[ 1 ], 3 )
    Endif
    str_error += ' нет пациентов'
    If dostup == B_STANDART
      str_error += ', закончивших лечение'
    Else
      str_error += ', не закончивших лечение'
    Endif
    If arr_m != NIL
      str_error += ' ' + arr_m[ 4 ]
      mtitul += ' ' + arr_m[ 4 ]
    Endif
    buf24 := save_maxrow()
    mywait()
    dbCreate( cur_dir + 'tmp_h', { { 'kod', 'N', 7, 0 } } )
    Use ( cur_dir + 'tmp_h' ) new
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human', dir_server + 'humann', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    find ( str_find )
    If yes_h_otd == 1
      If dostup == B_STANDART
        Index On Upper( fio ) to ( cur_dir + 'tmp_hum' ) ;
          While tip_h == dostup .and. otd == glob_otd[ 1 ] ;
          For Between( k_data, arr_m[ 5 ], arr_m[ 6 ] ) .and. human_->reestr == 0
      Else
        Index On Upper( fio ) to ( cur_dir + 'tmp_hum' ) ;
          While tip_h == dostup .and. otd == glob_otd[ 1 ] ;
          For Between( k_data, arr_m[ 5 ], arr_m[ 6 ] )
      Endif
    Else
      If dostup == B_STANDART
        Index On Upper( fio ) to ( cur_dir + 'tmp_hum' ) ;
          While tip_h == dostup ;
          For lpu == glob_uch[ 1 ] .and. Between( k_data, arr_m[ 5 ], arr_m[ 6 ] ) .and. human_->reestr == 0
      Else
        Index On Upper( fio ) to ( cur_dir + 'tmp_hum' ) ;
          While tip_h == dostup ;
          For lpu == glob_uch[ 1 ] .and. Between( k_data, arr_m[ 5 ], arr_m[ 6 ] )
      Endif
    Endif
    srec := 1
    Go Top
    Do While !Eof()
      Select TMP_H
      Append Blank
      Replace kod With human->kod
      If human->kod == glob_perso
        srec := tmp_h->( RecNo() )
      Endif
      Select HUMAN
      Skip
    Enddo
    i := tmp_h->( LastRec() )
    Close databases
    rest_box( buf24 )
    If i == 0
      func_error( 4, str_error )
    Else
      Private mr1 := T_ROW, regim_vyb := 2
      Do While .t.
        r_use( dir_server + 'mo_otd', , 'OTD' )
        r_use( dir_server + 'human_', , 'HUMAN_' )
        r_use( dir_server + 'human', , 'HUMAN' )
        Set Relation To RecNo() into HUMAN_, To otd into OTD
        Use ( cur_dir + 'tmp_h' ) new
        Set Relation To kod into HUMAN
        Index On Upper( human->fio ) to ( cur_dir + 'tmp_h' )
        Goto ( srec )
        mkod := 0
        buf_scr := SaveScreen()
        If alpha_browse( T_ROW, 2, MaxRow() -2, 77, 'f1ret_oms_human', color0, mtitul, 'B/BG', , ;
            .t., , , 'f2ret_oms_human', , { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, W+/R' } )
          If ( glob_perso := tmp_h->kod ) == 0
            func_error( 4, 'Не найдено нужных записей!' )
          Elseif eq_any( human->ishod, 88, 89 )
            func_error( 4, 'Данный случай - часть двойного случая. Редактирование запрещено!' )
          Else
            srec := tmp_h->( RecNo() )
            mkod := glob_perso
            glob_kartotek := human->kod_k
            glob_k_fio := fio_plus_novor()
            glob_otd[ 1 ] := human->otd
            glob_otd[ 2 ] := inieditspr( A__POPUPMENU, dir_server + 'mo_otd', human->otd )
            If Len( glob_otd ) == 2
              AAdd( glob_otd, human_->usl_ok )
            Else
              glob_otd[ 3 ] := human_->usl_ok
            Endif
            k := ret_tip_lu()
            If Len( glob_otd ) == 3
              AAdd( glob_otd, k )
            Else
              glob_otd[ 4 ] := k
            Endif
            glob_uch[ 1 ] := human->LPU
            glob_uch[ 2 ] := inieditspr( A__POPUPMENU, dir_server + 'mo_uch', human->LPU )
            fl_schet := ( human->schet > 0 )
          Endif
        Else
          RestScreen( buf_scr )
          Exit
        Endif
        RestScreen( buf_scr )
        Close databases
        If mkod > 0
          lek_pr := check_oms_sluch_lek_pr( glob_perso )
          If buf != NIL
            rest_box( buf )
          Endif
          buf := box_shadow( 0, 41, 3, 77, color13 )
          @ 1, 42 Say PadC( glob_otd[ 2 ], 35 ) Color color14
          @ 2, 42 Say PadC( glob_k_fio, 35 ) Color color8
          If lek_pr
            mas_pmt := { 'Редактирование ~карточки', 'Редактирование ~услуг', 'Использованные ~лекарства' }
          Else
            mas_pmt := { 'Редактирование ~карточки', 'Редактирование ~услуг' }
          Endif
          If glob_otd[ 3 ] == 4 .or. ;
              ( glob_otd[ 4 ] > 0 .and. ;
              glob_otd[ 4 ] != TIP_LU_MED_REAB .and. ;
              glob_otd[ 4 ] != TIP_LU_H_DIA .and. ;
              glob_otd[ 4 ] != TIP_LU_P_DIA )
            si := 1
            ASize( mas_pmt, 1 )
            Keyboard Chr( K_ENTER )
          Endif
          Do While ( i := popup_prompt( T_ROW, T_COL + 5, si, mas_pmt ) ) > 0
            si := i
            str_sem := 'Редактирование человека ' + lstr( glob_perso )
            If g_slock( str_sem )
              If i == 1
                oms_sluch( glob_perso, glob_kartotek )
              Elseif i == 2
                oms_usl_sluch( glob_perso, glob_kartotek )
              Elseif i == 3
                oms_sluch_lek_pr( glob_perso, glob_kartotek )
              Endif
              g_sunlock( str_sem )
            Else
              func_error( 4, 'В данный момент с карточкой этого пациента работает другой пользователь.' )
              Exit
            Endif
          Enddo
        Endif
      Enddo
    Endif
    If buf != NIL
      rest_box( buf )
    Endif
    Close databases
  Endif

  Return Nil

// 01.12.22 Редактирование случая с выбором по отчётному периоду
Function f2oms_edit()

  Static si := 1
  Local buf, str_sem, i, arr_m, mas_pmt, buf24, buf_scr, srec, old_yes_h_otd := yes_h_otd
  Local lek_pr := .f.

  If !myfiledeleted( cur_dir + 'tmp_h' + sdbf )
    Return Nil
  Endif
  If ( arr_m := year_month( T_ROW, T_COL + 5, , 3 ) ) != NIL
    buf24 := save_maxrow()
    mywait()
    dbCreate( cur_dir + 'tmp_h', { { 'kod', 'N', 7, 0 } } )
    Use ( cur_dir + 'tmp_h' ) new
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human', dir_server + 'humand', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Index On Upper( fio ) to ( cur_dir + 'tmp_h2' ) ;
      While human->k_data <= arr_m[ 6 ] ;
      For schet < 1 .and. human_->reestr == 0
    srec := 1
    Go Top
    Do While !Eof()
      Select TMP_H
      Append Blank
      Replace kod With human->kod
      If human->kod == glob_perso
        srec := tmp_h->( RecNo() )
      Endif
      Select HUMAN
      Skip
    Enddo
    i := tmp_h->( LastRec() )
    Close databases
    rest_box( buf24 )
    If i == 0
      func_error( 4, 'В данный момент нет пациентов с датой окончания ' + arr_m[ 4 ] )
    Else
      Private mr1 := T_ROW, regim_vyb := 2
      Do While .t.
        r_use( dir_server + 'mo_otd', , 'OTD' )
        r_use( dir_server + 'human_', , 'HUMAN_' )
        r_use( dir_server + 'human', , 'HUMAN' )
        Set Relation To RecNo() into HUMAN_, To otd into OTD
        Use ( cur_dir + 'tmp_h' ) new
        Set Relation To kod into HUMAN
        Index On Upper( human->fio ) to ( cur_dir + 'tmp_h' )
        Goto ( srec )
        mkod := 0
        yes_h_otd := 2
        buf_scr := SaveScreen()
        If alpha_browse( T_ROW, 2, MaxRow() -2, 77, 'f1ret_oms_human', color0, 'По дате окончания лечения "' + arr_m[ 4 ] + '"', 'B/BG', , ;
            .t., , , 'f2ret_oms_human', , ;
            { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, W+/R' } )
          If ( glob_perso := tmp_h->kod ) == 0
            func_error( 4, 'Не найдено нужных записей!' )
          Elseif eq_any( human->ishod, 88, 89 )
            func_error( 4, 'Данный случай - часть двойного случая. Редактирование запрещено!' )
          Else
            srec := tmp_h->( RecNo() )
            mkod := glob_perso
            glob_kartotek := human->kod_k
            glob_k_fio := fio_plus_novor()
            glob_otd[ 1 ] := human->otd
            glob_otd[ 2 ] := inieditspr( A__POPUPMENU, dir_server + 'mo_otd', human->otd )
            If Len( glob_otd ) == 2
              AAdd( glob_otd, human_->usl_ok )
            Else
              glob_otd[ 3 ] := human_->usl_ok
            Endif
            k := ret_tip_lu()
            If Len( glob_otd ) == 3
              AAdd( glob_otd, k )
            Else
              glob_otd[ 4 ] := k
            Endif
            glob_uch[ 1 ] := human->LPU
            glob_uch[ 2 ] := inieditspr( A__POPUPMENU, dir_server + 'mo_uch', human->LPU )
            fl_schet := ( human->schet > 0 )
          Endif
        Else
          RestScreen( buf_scr )
          Exit
        Endif
        RestScreen( buf_scr )
        Close databases
        If mkod > 0
          lek_pr := check_oms_sluch_lek_pr( glob_perso )
          yes_h_otd := old_yes_h_otd
          If buf != NIL
            rest_box( buf )
          Endif
          buf := box_shadow( 0, 41, 3, 77, color13 )
          @ 1, 42 Say PadC( glob_otd[ 2 ], 35 ) Color color14
          @ 2, 42 Say PadC( glob_k_fio, 35 ) Color color8
          If lek_pr
            mas_pmt := { 'Редактирование ~карточки', 'Редактирование ~услуг', 'Использованные ~лекарства' }
          Else
            mas_pmt := { 'Редактирование ~карточки', 'Редактирование ~услуг' }
          Endif
          If glob_otd[ 3 ] == 4 .or. ;
              ( glob_otd[ 4 ] > 0 .and. ;
              glob_otd[ 4 ] != TIP_LU_MED_REAB .and. ;
              glob_otd[ 4 ] != TIP_LU_H_DIA .and. ;
              glob_otd[ 4 ] != TIP_LU_P_DIA )
            si := 1
            ASize( mas_pmt, 1 )
            Keyboard Chr( K_ENTER )
          Endif
          Do While ( i := popup_prompt( T_ROW, T_COL + 5, si, mas_pmt ) ) > 0
            si := i
            str_sem := 'Редактирование человека ' + lstr( glob_perso )
            If g_slock( str_sem )
              If i == 1
                oms_sluch( glob_perso, glob_kartotek )
              Elseif i == 2
                oms_usl_sluch( glob_perso, glob_kartotek )
              Elseif i == 3
                oms_sluch_lek_pr( glob_perso, glob_kartotek )
              Endif
              g_sunlock( str_sem )
            Else
              func_error( 4, 'В данный момент с карточкой этого пациента работает другой пользователь.' )
              Exit
            Endif
          Enddo
        Endif
      Enddo
    Endif
    If buf != NIL
      rest_box( buf )
    Endif
    yes_h_otd := old_yes_h_otd
    Close databases
  Endif

  Return Nil

// 20.05.22 Редактирование повторно выставленных случаев (после ввода актов снятия из СМО)
Function f4oms_edit()

  Static si := 1
  Local buf, str_sem, i, k, arr_m, arr, old_yes_h_otd := yes_h_otd, ;
    iRefr, srec, buf24, buf_scr, mas_pmt
  Local lek_pr := .f.

  If !myfiledeleted( cur_dir + 'tmp_h' + sdbf )
    Return Nil
  Endif
  If ( arr_m := year_month( T_ROW, T_COL + 5 ) ) != NIL
    buf24 := save_maxrow()
    mywait()
    dbCreate( cur_dir + 'tmp_h', { { 'kod', 'N', 7, 0 } } )
    Use ( cur_dir + 'tmp_h' ) new
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human', dir_server + 'humand', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Index On Upper( fio ) to ( cur_dir + 'tmp_h2' ) ;
      While human->k_data <= arr_m[ 6 ] ;
      For emptyall( human_->reestr, human->schet ) .and. human_->kod_up > 0
    Go Top
    Do While !Eof()
      Select TMP_H
      Append Blank
      Replace kod With human->kod
      Select HUMAN
      Skip
    Enddo
    i := tmp_h->( LastRec() )
    Close databases
    rest_box( buf24 )
    If i == 0
      func_error( 4, 'Нет повторно выставленных случаев ' + arr_m[ 4 ] )
    Else
      Private mr1 := T_ROW, regim_vyb := 2
      srec := 1
      Do While .t.
        r_use( dir_server + 'mo_otd', , 'OTD' )
        r_use( dir_server + 'human_', , 'HUMAN_' )
        r_use( dir_server + 'human', , 'HUMAN' )
        Set Relation To RecNo() into HUMAN_, To otd into OTD
        Use ( cur_dir + 'tmp_h' ) new
        Set Relation To kod into HUMAN
        Index On Upper( human->fio ) to ( cur_dir + 'tmp_h' )
        Goto ( srec )
        mkod := 0
        yes_h_otd := 2
        buf_scr := SaveScreen()
        If alpha_browse( T_ROW, 2, MaxRow() -2, 77, 'f1ret_oms_human', color0, 'Повторно выставленные случаи ' + arr_m[ 4 ], 'B/BG', , ;
            .t., , , 'f2ret_oms_human', , ;
            { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, W+/R' } )
          If ( glob_perso := tmp_h->kod ) == 0
            func_error( 4, 'Не найдено нужных записей!' )
          Elseif eq_any( human->ishod, 88, 89 )
            func_error( 4, 'Данный случай - часть двойного случая. Редактирование запрещено!' )
          Else
            srec := tmp_h->( RecNo() )
            mkod := glob_perso
            glob_kartotek := human->kod_k
            glob_k_fio := fio_plus_novor()
            glob_otd[ 1 ] := human->otd
            glob_otd[ 2 ] := inieditspr( A__POPUPMENU, dir_server + 'mo_otd', human->otd )
            If Len( glob_otd ) == 2
              AAdd( glob_otd, human_->usl_ok )
            Else
              glob_otd[ 3 ] := human_->usl_ok
            Endif
            k := ret_tip_lu()
            If Len( glob_otd ) == 3
              AAdd( glob_otd, k )
            Else
              glob_otd[ 4 ] := k
            Endif
            glob_uch[ 1 ] := human->LPU
            glob_uch[ 2 ] := inieditspr( A__POPUPMENU, dir_server + 'mo_uch', human->LPU )
            fl_schet := ( human->schet > 0 )
          Endif
        Else
          RestScreen( buf_scr )
          Exit
        Endif
        RestScreen( buf_scr )
        Close databases
        If mkod > 0
          lek_pr := check_oms_sluch_lek_pr( glob_perso )
          yes_h_otd := old_yes_h_otd
          If buf != NIL
            rest_box( buf )
          Endif
          buf := box_shadow( 0, 41, 3, 77, color13 )
          @ 1, 42 Say PadC( glob_otd[ 2 ], 35 ) Color color14
          @ 2, 42 Say PadC( glob_k_fio, 35 ) Color color8
          If lek_pr
            mas_pmt := { 'Редактирование ~карточки', 'Редактирование ~услуг', 'Использованные ~лекарства' }
          Else
            mas_pmt := { 'Редактирование ~карточки', 'Редактирование ~услуг' }
          Endif
          If glob_otd[ 3 ] == 4 .or. ;
              ( glob_otd[ 4 ] > 0 .and. ;
              glob_otd[ 4 ] != TIP_LU_MED_REAB .and. ;
              glob_otd[ 4 ] != TIP_LU_H_DIA .and. ;
              glob_otd[ 4 ] != TIP_LU_P_DIA )
            si := 1
            ASize( mas_pmt, 1 )
            Keyboard Chr( K_ENTER )
          Endif
          Do While ( i := popup_prompt( T_ROW, T_COL + 5, si, mas_pmt ) ) > 0
            si := i
            str_sem := 'Редактирование человека ' + lstr( glob_perso )
            If g_slock( str_sem )
              If i == 1
                oms_sluch( glob_perso, glob_kartotek )
              Elseif i == 2
                oms_usl_sluch( glob_perso, glob_kartotek )
              Elseif i == 3
                oms_sluch_lek_pr( glob_perso, glob_kartotek )
              Endif
              g_sunlock( str_sem )
            Else
              func_error( 4, 'В данный момент с карточкой этого пациента работает другой пользователь.' )
              Exit
            Endif
          Enddo
        Endif
      Enddo
    Endif
    If buf != NIL
      rest_box( buf )
    Endif
    yes_h_otd := old_yes_h_otd
    Close databases
  Endif

  Return Nil

// 05.02.19 Редактирование листка учета лечения больного + смена отделения
Function oms_smena_otd()

  Static si := 1, sk := 1
  Local buf, buf1, buf2, str_sem, i, sou, old_otd, fl, fl1, mas_pmt, k := 1

  If input_uch( T_ROW - 1, T_COL + 5, sys_date ) != Nil .and. ;
      input_otd( T_ROW - 1, T_COL + 5, sys_date ) != NIL
    If yes_vypisan == B_END
      If ( k := popup_prompt( T_ROW, T_COL + 5, sk, ;
          { '~Не закончившие лечение', '~Закончившие лечение' } ) ) > 0
        sk := k
      Endif
    Endif
    buf := box_shadow( 0, 41, 2, 77, color13 )
    @ 1, 42 Say PadC( glob_otd[ 2 ], 35 ) Color color14
    If k > 0 .and. ret_oms_human( yes_vypisan + k - 1 )
      rest_box( buf )
      buf := box_shadow( 0, 41, 3, 77, color13 )
      @ 1, 42 Say PadC( glob_otd[ 2 ], 35 ) Color color14
      @ 2, 42 Say PadC( glob_k_fio, 35 ) Color color8
      sou := glob_otd[ 2 ] + ' [' + glob_uch[ 2 ] + ']'
      old_otd := glob_otd[ 1 ]
      buf1 := box_shadow( 0, 0, 3, 35, color5 )
      @ 1, 1 Say PadC( 'Теперь выберите', 34 ) Color color5
      @ 2, 1 Say PadC( 'новое отделение', 34 ) Color color5
      If input_uch( T_ROW - 1, T_COL + 5, sys_date ) != Nil .and. ;
          input_otd( T_ROW - 1, T_COL + 5, sys_date ) != NIL
        rest_box( buf1 )
        If old_otd == glob_otd[ 1 ]
          fl := func_error( 4, 'Выбрано то же самое отделение!' )
        Else
          buf2 := SaveScreen()
          f_message( { 'Старое отделение:', ;
            sou, ;
            'Новое отделение:', ;
            glob_otd[ 2 ] + ' [' + glob_uch[ 2 ] + ']' }, , 'W+/W', 'N/W' )
          If ( fl := f_esc_enter( 'смены отделения', .t. ) )
            fl1 := .f.
            If input_value( MaxRow() -4, 10, MaxRow() -2, 69, color1, ;
                '   Перезаписывать новое отделение в каждой услуге', 0, mm_danet ) == 1
              fl1 := .t.
            Endif
          Endif
          RestScreen( buf2 )
        Endif
        If fl
          str_sem := 'Редактирование человека ' + lstr( glob_perso )
          If g_slock( str_sem )
            use_base( 'human' )
            Set Order To 0
            Goto ( glob_perso )
            k := human->ishod
            g_rlock( forever )
            human->LPU := glob_uch[ 1 ] // код учреждения
            human->OTD := glob_otd[ 1 ] // код отделения
            If fl1
              use_base( 'mo_hu' )
              find ( Str( glob_perso, 7 ) )
              Do While mohu->kod == glob_perso .and. !Eof()
                g_rlock( forever )
                mohu->otd := glob_otd[ 1 ] // код отделения
                Skip
              Enddo
              use_base( 'human_u' )
              find ( Str( glob_perso, 7 ) )
              Do While hu->kod == glob_perso .and. !Eof()
                g_rlock( forever )
                hu->otd := glob_otd[ 1 ] // код отделения
                Skip
              Enddo
            Endif
            Close databases
            func_error( 2, 'Смена отделения завершена!' )
            If eq_any( k, 88, 89 )
              func_error( 4, 'Данный случай - часть двойного случая. Редактирование запрещено!' )
            Else
              @ 1, 42 Say PadC( glob_otd[ 2 ], 35 ) Color color14
              mas_pmt := { 'Редактирование ~карточки', 'Редактирование ~услуг' }
              If glob_otd[ 3 ] == 4 .or. ;
                  ( glob_otd[ 4 ] > 0 .and. ;
                  glob_otd[ 4 ] != TIP_LU_MED_REAB .and. ;
                  glob_otd[ 4 ] != TIP_LU_H_DIA .and. ;
                  glob_otd[ 4 ] != TIP_LU_P_DIA )
                si := 1
                ASize( mas_pmt, 1 )
              Endif
              Do While ( i := popup_prompt( T_ROW, T_COL + 5, si, mas_pmt ) ) > 0
                If ( si := i ) == 1
                  oms_sluch( glob_perso, glob_kartotek )
                Else
                  oms_usl_sluch( glob_perso, glob_kartotek )
                Endif
              Enddo
            Endif
            g_sunlock( str_sem )
          Else
            func_error( 4, 'В данный момент с карточкой этого пациента работает другой пользователь.' )
          Endif
        Endif
      Endif
      If buf1 != NIL
        rest_box( buf1 )
      Endif
    Endif
    If buf != NIL
      rest_box( buf )
    Endif
  Endif

  Return Nil

// 16.03.22 Удаление листка учета лечения больного
Function oms_del()

  Static sk := 1
  Local buf, str_sem, j, k := 1, arr_m, fl := .t., lkod_k, lyear

  If ! hb_user_curUser:isadmin()
    Return func_error( 4, err_admin )
  Endif
  If ( arr_m := input_year() ) != Nil .and. ;
      input_uch( T_ROW - 1, T_COL + 5, sys_date ) != Nil .and. ;
      iif( yes_h_otd == 1, input_otd( T_ROW - 1, T_COL + 5, sys_date ) != NIL, .t. )
    If yes_vypisan == B_END
      If ( k := popup_prompt( T_ROW, T_COL + 5, sk, ;
          { '~Не закончившие лечение', '~Закончившие лечение' } ) ) > 0
        sk := k
      Endif
    Endif
    If yes_h_otd == 1
      buf := box_shadow( 0, 41, 2, 77, color13 )
      @ 1, 42 Say PadC( glob_otd[ 2 ], 35 ) Color color14
    Endif
    If k > 0 .and. ret_oms_human( yes_vypisan + k - 1, arr_m ) .and. f_esc_enter( 2, .t. )
      str_sem := 'Редактирование человека ' + lstr( glob_perso )
      If g_slock( str_sem )
        g_use( dir_server + 'mo_pp', dir_server + 'mo_pp_h', 'PP' )
        use_base( 'mo_hdisp' )
        use_base( 'mo_hu' )
        use_base( 'human_u' )
        use_base( 'human' )
        find ( Str( glob_perso, 7 ) )
        If fl .and. eq_any( human->ishod, 88, 89 )
          fl := func_error( 10, 'Данный случай - часть двойного случая. Удаление запрещено!' )
        Endif
        If fl .and. human_->KOD_UP > 0
          fl := func_error( 10, 'Данный случай выставлен повторно (по акту снятия). Удаление запрещено!' )
        Endif
        If fl .and. human->ishod == 201 // диспансеризация I этап
          lkod_k := human->kod_k
          lyear := Year( human->k_data )
          Set Order To 2
          find ( Str( lkod_k, 7 ) )
          Do While human->kod_k == lkod_k .and. !Eof()
            If human->ishod == 202 .and. Year( human->k_data ) == lyear
              fl := func_error( 10, 'Это I этап диспансеризации, но присутствует II этап. Удаление запрещено!' )
              Exit
            Endif
            Skip
          Enddo
          Set Order To 1
          find ( Str( glob_perso, 7 ) )
        Endif
        If fl
          flag_pp := .f.
          Select PP // приемный покой
          find ( Str( glob_perso, 7 ) )
          If Found() .and. human->kod_k == pp->kod_k // тот же пациент
            g_rlock( forever )
            pp->K_DATA := CToD( '' )  // дата окончания лечения
            pp->K_TIME := ''        // время выписки
            flag_pp := .t.
          Endif
          j := 0
          Do While .t.
            Select HDISP
            find ( Str( glob_perso, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
          Do While .t.
            Select MOHU
            find ( Str( glob_perso, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t., .f. )  // без пометки на удаление
            ++j
          Enddo
          Do While .t.
            Select HU
            find ( Str( glob_perso, 7 ) )
            If !Found()
              Exit
            Endif
            //
            Select HU_
            deleterec( .t., .f. )
            Select HU
            deleterec( .t., .f. )  // без пометки на удаление
            ++j
          Enddo
          Select HUMAN_2
          deleterec( .t., .f. )
          Select HUMAN_
          deleterec( .t., .f. )
          Select HUMAN
          deleterec( .t., .f. )  // без пометки на удаление
          g_rlock( forever )
          Replace human->schet With -1  // (вместо нуля)
          // удаляем онкологию
          g_use( dir_server + 'mo_onkna', dir_server + 'mo_onkna', 'NAPR' ) // онконаправления
          Do While .t.
            find ( Str( glob_perso, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
          g_use( dir_server + 'mo_onksl', dir_server + 'mo_onksl', 'SL' )
          Do While .t.
            find ( Str( glob_perso, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
          g_use( dir_server + 'mo_onkdi', dir_server + 'mo_onkdi', 'DI' )
          Do While .t.
            find ( Str( glob_perso, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
          g_use( dir_server + 'mo_onkpr', dir_server + 'mo_onkpr', 'PR' )
          Do While .t.
            find ( Str( glob_perso, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
          g_use( dir_server + 'mo_onkus', dir_server + 'mo_onkus', 'US' )
          Do While .t.
            find ( Str( glob_perso, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
          g_use( dir_server + 'mo_onkco', dir_server + 'mo_onkco', 'CO' )
          Do While .t.
            find ( Str( glob_perso, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
          g_use( dir_server + 'mo_onkle', dir_server + 'mo_onkle', 'LE' )
          Do While .t.
            find ( Str( glob_perso, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo

          // удаление имплантантов
          delete_implantants( glob_perso )

          // удаление лекарственных препаратов
          g_use( dir_server + 'human_lek_pr', dir_server + 'human_lek_pr', 'LEK' )
          Do While .t.
            find ( Str( glob_perso, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo

          Close databases
          write_work_oper( glob_task, OPER_USL, 3, j )
          write_work_oper( glob_task, OPER_LIST, 3 )
          stat_msg( 'Лист учёта удалён.' )
          mybell( 2, OK )
          If flag_pp
            stat_msg( 'Не забудьте удалить историю болезни в подзадаче ПРИЁМНЫЙ ПОКОЙ' )
            mybell( 10, OK )
          Endif
        Else
          Close databases
        Endif
        g_sunlock( str_sem )
      Else
        func_error( 4, 'В данный момент с карточкой этого пациента работает другой пользователь.' )
      Endif
    Endif
    If buf != NIL
      rest_box( buf )
    Endif
  Endif

  Return Nil

// Режимы работы с завершением лечения
Function oms_zav_lech( k )

  Static sk := 1, str_sem := 'Завершение лечения'
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { 'Завершение лечения для ~одного больного', ;
      'Завершение лечения для ~всех', ;
      '~Убрать у больного отметку о завершении лечения' }
    mas_msg := { 'Завершение лечения для одного больного', ;
      'Завершение лечения для всех', ;
      'Убрать у больного отметку о завершении лечения' }
    mas_fun := { 'oms_zav_lech(1)', ;
      'oms_zav_lech(2)', ;
      'oms_zav_lech(3)' }
    If g_slock( str_sem )
      popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL + 5, sk, mas_pmt, mas_msg, mas_fun )
      g_sunlock( str_sem )
    Else
      func_error( 4, err_slock )
    Endif
  Case k == 1
    f1oms_zav_lech( 1 )
  Case k == 2
    f1oms_zav_lech( 2 )
  Case k == 3
    f1oms_zav_lech( 3 )
  Endcase
  If k > 0
    sk := k
  Endif

  Return Nil

//
Function f1oms_zav_lech( k )

  Local buf, str_sem, k1, k2, tmp_color, dbf_tmp, r := 8, mtitul

  If input_uch( T_ROW - 1, T_COL + 5, sys_date ) != Nil .and. ;
      iif( yes_h_otd == 1, input_otd( T_ROW - 1, T_COL + 5, sys_date ) != NIL, .t. )
    If k == 1 .or. k == 3  // один человек из отделения
      If ret_oms_human( iif( k == 1, B_END, B_STANDART ) )
        str_sem := 'Редактирование человека ' + lstr( glob_perso )
        If !g_slock( str_sem )
          Return func_error( 4, err_slock )
        Endif
        tmp_color := SetColor( color1 )
        buf := SaveScreen()
        box_shadow( r, 10, r + 7, 69, color1, ;
          if( k == 1, 'Завершение лечения', ;
          'Убираем отметку о завершении лечения' ), 'W/B' )
        use_base( 'human' )
        Goto ( glob_perso )
        @ r + 2, 12 Say 'Ф.И.О. '
        @ Row(), Col() Say human->fio Color cDataCSay
        @ r + 3, 12 Say 'Дата начала лечения '
        @ Row(), Col() Say full_date( human->n_data ) Color cDataCSay
        @ r + 4, 12 Say 'Дата окончания лечения '
        @ Row(), Col() Say full_date( human->k_data ) Color cDataCSay
        @ r + 5, 12 Say 'Сумма лечения '
        @ Row(), Col() Say lstr( human->cena_1, 12, 2 ) Color cDataCSay
        If f_esc_enter( 1 ) .and. g_rlock( forever )
          human->TIP_H := if( k == 3, B_END, B_STANDART )
          stat_msg( if( k == 1, 'Лечение завершено', 'Убрана отметка о завершении лечения' ) + '!' )
          mybell( 0.5, OK )
        Endif
        Close databases
        g_sunlock( str_sem )
        RestScreen( buf )
        SetColor( tmp_color )
      Endif
    Elseif k == 2  // целое отделение/учреждение
      dbf_tmp := { ;
        { 'KOD',   'N',     7,     0 }, ;
        { 'N_DATA',   'D',     8,     0 }, ; // дата начала лечения
      { 'K_DATA',   'D',     8,     0 }, ; // дата окончания лечения
      { 'FIO',   'C',    50,     0 }, ; // Ф.И.О. больного
      { 'CENA',   'N',    12,     2 }, ; // стоимость лечения
      { 'PLUS',   'L',     1,     0 } }  // включается ли в счет
      buf := save_maxrow()
      mywait()
      dbCreate( cur_dir + 'tmp', dbf_tmp )
      k1 := k2 := 0
      Use ( cur_dir + 'tmp' ) Alias TMP
      r_use( dir_server + 'human', dir_server + 'humann', 'HUMAN' )
      find ( Str( B_END, 1 ) )
      Do While human->tip_h == B_END .and. !Eof()
        If iif( yes_h_otd == 1, human->otd == glob_otd[ 1 ], .t. )
          k1++
          Select TMP
          Append Blank
          Replace tmp->KOD    With human->KOD, ;
            tmp->n_data With human->n_data, ;
            tmp->k_data With human->k_data, ;
            tmp->FIO    With human->FIO, ;
            tmp->CENA   With human->CENA_1, ;
            tmp->PLUS   With .t.
          If k1 == 9999
            Exit
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
      Close databases
      rest_box( buf )
      If k1 == 0
        func_error( 4, 'Нет больных, не закончивших лечение!' )
      Else
        buf := SaveScreen()
        Private old_summa := ob_summa := 0, old_kol := ob_kol := k1, regim_t := 3
        Private p_blk := {| mkol, msum| .t. }
        mtitul := AllTrim( glob_uch[ 2 ] )
        If yes_h_otd == 1
          mtitul += ' [ ' + AllTrim( glob_otd[ 2 ] ) + ' ]'
        Endif
        Use ( cur_dir + 'tmp' ) Alias TMP
        Index On Upper( fio ) to ( cur_dir + 'tmp_hum' )
        If alpha_browse( T_ROW, 0, MaxRow() -4, 79, 'f2oms_zav_lech', color1, ;
            mtitul, 'G+/B', .t., .t., ,, 'f3oms_zav_lech', , ;
            { '═', '░', '═', 'W+/B, BG+/R, GR+/B, GR+/R', , 300 } )
          If ob_kol > 0 .and. f_esc_enter( 'завершения лечения' ) .and. use_base( 'human' )
            mywait()
            Select TMP
            Go Top
            Do While !Eof()
              If tmp->plus
                str_sem := 'Редактирование человека ' + lstr( tmp->kod )
                If g_slock( str_sem ) // если человек не заблокирован
                  Select HUMAN
                  find ( Str( tmp->kod, 7 ) )
                  If Found() .and. g_rlock( forever )
                    human->TIP_H := B_STANDART
                    Unlock
                  Endif
                  g_sunlock( str_sem )
                Else
                  k2++
                Endif
              Endif
              Select TMP
              Skip
            Enddo
            Close databases
            stat_msg( 'Лечение завершено!' + if( k2 == 0, '', ;
              ' (' + lstr( k2 ) + ' чел. были заблокированы)' ) )
            mybell( 0.5, OK )
          Endif
        Endif
        RestScreen( buf )
      Endif
    Endif
  Endif
  Close databases

  Return Nil

//
Function f2oms_zav_lech( oBrow )

  Local oColumn, tmp_color, blk_color := {|| if( tmp->plus, { 3, 4 }, { 1, 2 } ) }, s1, s2, s3, n := 46

  oColumn := TBColumnNew( ' ', {|| if( tmp->plus, ' ', '  ' ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Ф.И.О. больного', n ), {|| PadR( tmp->fio, n ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Окончан.;лечения', {|| tmp->k_data } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '    Сумма', {|| PadL( expand_value( tmp->cena, 2 ), 14 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' ', {|| if( tmp->plus, ' ', '  ' ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  tmp_color := SetColor( 'N/W' )
  s1 := 'завершения лечения'
  s2 := 'все завершили лечение'
  s3 := 'все не завершили лечение'
  @ MaxRow() -3, 0 Say PadR( ' <Esc> - выход без изменений;    <Enter> - подтверждение ' + s1, 80 )
  @ MaxRow() -2, 0 Say PadR( ' <Ins> - отметить одного больного или снять отметку с одного больного', 80 )
  @ MaxRow() -1, 0 Say PadR( ' <+> - отметить всех больных (все завершили лечение)    <F8> - удаление по дате', 80 )
  @ MaxRow() -0, 0 Say PadR( ' <-> - снять отметку со всех больных (все не завершили лечение)   <F9> - печать', 80 )
  mark_keys( { s1 }, 'R/W' )
  mark_keys( { '<Esc>', '<Enter>', '<Ins>', '<+>', '<->', '<F8>', '<F9>' }, 'B/W' )
  SetColor( tmp_color )

  Return Nil

//
Function f3oms_zav_lech( nKey, oBrow )

  Local buf, rec, k := -1, sh, HH, n_file, s, mdate, j

  Do Case
  Case nkey == K_F8
    mdate := input_value( 21, 1, 23, 78, 'W+/N, N/W', ;
      Space( 7 ) + 'Введите дату, ранее которой не завершено лечение', ;
      sys_date - 30 )
    If mdate != Nil .and. f_esc_enter( 'удаления' ) .and. ;
        f_alert( { 'После подтверждения данного режима будут удалены', ;
        'все листки учета с незавершенным лечением, у которых', ;
        'проставлена дата ранее ' + date_month( mdate, .t. ), ;
        'Выберите действие' }, ;
        { ' ~Отказ ', ' Подтвердить ~удаление ' }, ;
        1, 'N+/BG', 'R/BG', 16, , col1menu ) == 2
      buf := save_maxrow()
      mywait()
      j := 0
      use_base( 'mo_hu' )
      use_base( 'human_u' )
      use_base( 'human' )
      Select TMP
      Go Top
      Do While !Eof()
        If tmp->k_data <= mdate
          ++j
          Do While .t.
            Select HU
            find ( Str( tmp->kod, 7 ) )
            If !Found()
              Exit
            Endif
            //
            Select HU_
            deleterec( .t., .f. )
            Select HU
            deleterec( .t., .f. )  // без пометки на удаление
          Enddo
          Do While .t.
            Select MOHU
            find ( Str( tmp->kod, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t., .f. )  // без пометки на удаление
          Enddo
          Select HUMAN
          Goto ( tmp->kod )
          Select HUMAN_
          deleterec( .t., .f. )
          Select HUMAN
          deleterec( .t., .f. )  // без пометки на удаление
          g_rlock( forever )
          Replace human->schet With -1  // (вместо нуля)
          Unlock
        Endif
        Select TMP
        Skip
      Enddo
      Close databases
      stat_msg( 'Всего удалено листов учета - ' + lstr( j ) )
      mybell( 2, OK )
      Use ( cur_dir + 'tmp' ) Alias TMP
      rest_box( buf )
      k := 0
      Keyboard Chr( K_ESC )
    Endif
  Case nkey == K_F9
    mdate := input_value( 21, 1, 23, 78, color1, ;
      Space( 7 ) + 'Введите дату, ранее которой не завершено лечение', ;
      sys_date - 10 )
    If mdate != Nil .and. f_esc_enter( 'печати' )
      buf := save_maxrow()
      mywait()
      rec := RecNo()
      r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
      r_use( dir_server + 'human_', , 'HUMAN_' )
      r_use( dir_server + 'uslugi', , 'USL' )
      r_use( dir_server + 'mo_pers', , 'PERSO' )
      arr_title := { ;
        '────────────────────────────────────────────────┬────────────────┬──────────────', ;
        '               Ф.И.О.                           │ Сроки лечения  │    Сумма     ', ;
        '────────────────────────────────────────────────┴────────────────┴──────────────' }
      n_file := cur_dir + 'z_lech' + stxt
      sh := 80
      HH := 57
      fp := FCreate( n_file )
      n_list := 1
      tek_stroke := 0
      add_string( '' )
      add_string( Center( 'Больные, не завершившие лечение', sh ) )
      add_string( Center( 'до ' + date_month( mdate, .t. ), sh ) )
      add_string( '' )
      AEval( arr_title, {| x| add_string( x ) } )
      Select TMP
      Go Top
      Do While !Eof()
        If tmp->k_data <= mdate
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          add_string( PadR( tmp->fio, 49 ) + ;
            Left( DToC( tmp->n_data ), 5 ) + '-' + DToC( tmp->k_data ) + ;
            put_kope( tmp->cena, 13 ) )
          Select HUMAN_
          Goto ( tmp->kod )
          If !Eof() .and. human_->vrach > 0
            Select PERSO
            Goto ( human_->vrach )
            If !Eof()
              s := Space( 10 ) + 'Леч.врач: [' + lstr( perso->tab_nom )
              add_string( s + ']  ' + AllTrim( perso->fio ) )
            Endif
          Endif
          arr_usl := {}
          Select HU
          find ( Str( tmp->kod, 7 ) )
          Do While hu->kod == tmp->kod
            usl->( dbGoto( hu->u_kod ) )
            If AScan( arr_usl, usl->shifr ) == 0
              AAdd( arr_usl, usl->shifr )
            Endif
            Select HU
            Skip
          Enddo
          If Len( arr_usl ) > 0
            ASort( arr_usl, , , {| x, y| fsort_usl( x ) < fsort_usl( y ) } )
            s := 'Услуги: '
            For j := 1 To Len( arr_usl )
              s += AllTrim( arr_usl[ j ] )
              If j < Len( arr_usl )
                s += ', '
              Endif
            Next
            For j := 1 To perenos( arr_usl, s, sh - 10 )
              add_string( Space( 10 ) + arr_usl[ j ] )
            Next
          Endif
        Endif
        Select TMP
        Skip
      Enddo
      hu->( dbCloseArea() )
      usl->( dbCloseArea() )
      human_->( dbCloseArea() )
      perso->( dbCloseArea() )
      Select TMP
      Goto ( rec )
      FClose( fp )
      rest_box( buf )
      viewtext( n_file, , , , , , , 2 )
    Endif
  Case nkey == K_INS
    Replace tmp->plus With !tmp->plus
    If tmp->plus
      ob_summa += tmp->cena
      ob_kol++
    Else
      ob_summa -= tmp->cena
      ob_kol--
    Endif
    Eval( p_blk, ob_kol, ob_summa )
    k := 0
    Keyboard Chr( K_TAB )
  Case nkey == 43 .or. nkey == 45  // + или -
    fl := ( nkey == 43 )
    rec := RecNo()
    buf := save_maxrow()
    mywait()
    tmp->( dbEval( {|| tmp->plus := fl } ) )
    Goto ( rec )
    rest_box( buf )
    If fl
      ob_summa := old_summa
      ob_kol := tmp->( LastRec() )
    Else
      ob_summa := ob_kol := 0
    Endif
    Eval( p_blk, ob_kol, ob_summa )
    k := 0
  Endcase

  Return k

// 20.05.22 поиск больного
Function ret_oms_human( dostup, arr_m )

  // dostup = B_END      = 2 - больные выписались из данного отделения
  // dostup = B_STANDART = 3 - проверен стандарт лечения и не включен в реестр
  // dostup = B_SCHET    = 4 - выписан счет
  // dostup = B_OPL      = 5 - оплачен счет
  // dostup = B_NE_OPL   = 6 - больной по какой-то причине не оплачивается
  Local buf := SaveScreen(), mkod := 0, k, fl := .f., mtitul := ''

  mywait()
  Private mr1 := T_ROW, str_find, regim_vyb := 1
  str_error := 'В данный момент'
  If dostup == NIL
    str_find := DToS( arr_m[ 5 ] )
    mtitul := 'По дате окончания лечения "' + arr_m[ 4 ] + '"'
    r_use( dir_server + 'mo_otd', , 'OTD' )
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human', dir_server + 'humand', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_, To otd into OTD
    dbSeek( str_find, .t. )
    Index On Upper( fio ) to ( cur_dir + 'tmp_hum' ) ;
      While human->k_data <= arr_m[ 6 ] ;
      For schet < 1 .and. human_->reestr == 0
    str_error += ' нет пациентов с датой окончания ' + arr_m[ 4 ]
  Else
    mtitul := AllTrim( glob_uch[ 2 ] )
    str_find := Str( dostup, 1 )
    If yes_h_otd == 1
      mtitul += ' [ ' + AllTrim( glob_otd[ 2 ] ) + ' ]'
      str_error += ' в данном отделении'
      str_find += Str( glob_otd[ 1 ], 3 )
    Endif
    str_error += ' нет пациентов'
    If dostup == B_STANDART
      str_error += ', закончивших лечение'
    Else
      str_error += ', не закончивших лечение'
    Endif
    If arr_m != NIL
      str_error += ' ' + arr_m[ 4 ]
      mtitul += ' ' + arr_m[ 4 ]
    Endif
    r_use( dir_server + 'mo_otd', , 'OTD' )
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human', dir_server + 'humann', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_, To otd into OTD
    find ( str_find )
    If yes_h_otd == 1
      If dostup == B_STANDART
        Index On Upper( fio ) to ( cur_dir + 'tmp_hum' ) ;
          While tip_h == dostup .and. otd == glob_otd[ 1 ] ;
          For iif( arr_m == NIL, .t., Between( k_data, arr_m[ 5 ], arr_m[ 6 ] ) ) .and. human_->reestr == 0
      Else
        Index On Upper( fio ) to ( cur_dir + 'tmp_hum' ) ;
          While tip_h == dostup .and. otd == glob_otd[ 1 ] ;
          For iif( arr_m == NIL, .t., Between( k_data, arr_m[ 5 ], arr_m[ 6 ] ) )
      Endif
    Else
      If dostup == B_STANDART
        Index On Upper( fio ) to ( cur_dir + 'tmp_hum' ) ;
          While tip_h == dostup ;
          For lpu == glob_uch[ 1 ] .and. iif( arr_m == NIL, .t., Between( k_data, arr_m[ 5 ], arr_m[ 6 ] ) ) ;
          .and. human_->reestr == 0

      Else
        Index On Upper( fio ) to ( cur_dir + 'tmp_hum' ) ;
          While tip_h == dostup ;
          For lpu == glob_uch[ 1 ] .and. iif( arr_m == NIL, .t., Between( k_data, arr_m[ 5 ], arr_m[ 6 ] ) )
      Endif
    Endif
  Endif
  Go Top
  If Eof()
    Close databases
    RestScreen( buf )
    str_error += '!'
    Return func_error( 4, str_error )
  Endif
  If glob_perso > 0
    Locate For human->kod == glob_perso
    If !Found()
      Go Top
    Endif
  Endif
  If alpha_browse( T_ROW, 2, MaxRow() -2, 77, 'f1ret_oms_human', color0, mtitul, 'B/BG', , ;
      .t., , , 'f2ret_oms_human', , ;
      { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, W+/R' } )
    If ( glob_perso := human->kod ) == 0
      func_error( 4, 'Не найдено нужных записей!' )
    Else
      mkod := glob_perso
      glob_kartotek := human->kod_k
      glob_k_fio := fio_plus_novor()
      glob_otd[ 1 ] := human->otd
      glob_otd[ 2 ] := inieditspr( A__POPUPMENU, dir_server + 'mo_otd', human->otd )
      If Len( glob_otd ) == 2
        AAdd( glob_otd, human_->usl_ok )
      Else
        glob_otd[ 3 ] := human_->usl_ok
      Endif
      k := ret_tip_lu()
      If Len( glob_otd ) == 3
        AAdd( glob_otd, k )
      Else
        glob_otd[ 4 ] := k
      Endif
      glob_uch[ 1 ] := human->LPU
      glob_uch[ 2 ] := inieditspr( A__POPUPMENU, dir_server + 'mo_uch', human->LPU )
      fl_schet := ( human->schet > 0 )
    Endif
    Close databases
  Endif
  Close databases
  RestScreen( buf )

  Return ( mkod > 0 )

// 28.12.21
Function f1ret_oms_human( oBrow )

  Local oColumn, blk, r := 34

  blk := {|| iif( human_->KOD_UP > 0, { 3, 4 }, iif( human_->OPLATA == 2, { 5, 6 }, { 1, 2 } ) ) }
  If yes_h_otd == 1
    r += 6
  Endif
  oColumn := TBColumnNew( PadC( 'ФИО пациента', r ), {|| PadR( fio_plus_novor(), r ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If yes_h_otd == 2
    oColumn := TBColumnNew( 'Отд-е', {|| otd->short_name } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
  Endif
  oColumn := TBColumnNew( 'Осн.;диаг.', {|| human->kod_diag } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Нача-; ло', {|| Left( DToC( human->n_data ), 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Оконч-ие;лечения', {|| date_8( human->k_data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Стоимость;  лечения', {|| put_kope( human->cena_1, 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If hb_user_curUser:isadmin()
    s := '^<Esc>^ выход  ^<Enter>^ выбор  ^<F2>^ поиск'
    If Type( 'p_del_error' ) == 'A' .and. p_del_error[ 2 ] > 0
      s += '  ^<Ctrl+F12>^ снятие флага об ошибке у всех'
    Endif
    status_key( s )
  Else
    status_key( '^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск' )
  Endif

  Return Nil

// 08.07.24
Function f2ret_oms_human( nkey )

  Static tmp := ' '
  Local buf := SaveScreen(), buf1, rec1 := RecNo(), fl := -1, ss := 0, ;
    j, n_file := cur_dir + 'omserror' + stxt, sh := 80, HH := 60, ii
  Local mas_otchet := {}
  Local tmpSelect, flag_RDL := .F.

  For ii := 1 To 48
    AAdd( mas_otchet, { 0, 0, 0, 0 } )
  Next
  Private tmp1
  If Type( 'p_del_error' ) == 'A' .and. p_del_error[ 2 ] > 0
    If nkey == K_F9
      mywait()
      fp := FCreate( n_file )
      tek_stroke := 0
      n_list := 1
      add_string( '' )
      add_string( Center( 'Список случаев, возвращённых ТФОМС с ошибкой', sh ) )
      add_string( Center( p_del_error[ 1 ], sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      j := 0
      Go Top
      Do While !Eof()
        verify_ff( HH - 3, .f., sh )
        add_string( '' )
        ++j
        add_string( PadR( lstr( j ) + '.', 6 ) + AllTrim( human->fio ) + ', д.р.' + full_date( human->date_r ) + ',' )
        If otd->IDUMP == 4
          add_string( Space( 6 ) + 'карта вызова № ' + AllTrim( human->uch_doc ) + ;
            ', дата выезда ' + date_8( human->k_data ) )
        Else
          add_string( Space( 6 ) + 'лечение с ' + date_8( human->n_data ) + ' по ' + date_8( human->k_data ) + ;
            ', стоимость ' + lstr( human->cena_1, 11, 2 ) + 'р.' )
        Endif
        ss += human->cena_1
        Skip
      Enddo
      Goto rec1
      add_string( '' )
      add_string( 'Итого стоимость всех случаев ' + lstr( ss, 15, 2 ) + 'р.' )
      FClose( fp )
      RestScreen( buf )
      viewtext( n_file, , , , ( sh > 80 ), , , 2 )
      Return -1
      // elseif eq_any(nkey,K_F12,K_CTRL_F12) .and. tip_polzovat == TIP_ADM .and. f_Esc_Enter('снятия флага об ошибке', .t.)
    Elseif eq_any( nkey, K_F12, K_CTRL_F12 ) .and. hb_user_curUser:isadmin() .and. f_esc_enter( 'снятия флага об ошибке', .t. )
       /*involved_password(1,p_del_error[2],'снятия со всех пациентов флага об ошибке') ;
           .and. f_alert({padc('Выберите действие', 60,'.')}, ;
                         {' Отказ ',' Снять флаг об ошибке со всех пациентов '}, ;
                         1,'W+/N','N+/N',maxrow() - 2, ,'W+/N,N/BG' ) == 2*/
      Go Top
      Do While !Eof()
        human_->( g_rlock( forever ) )
        human_->OPLATA    := 0 // уберём '2', если отредактировали запись из реестра СП и ТК
        human_->ST_VERIFY := 0 // снова ещё не проверен
        Skip
      Enddo
      Goto rec1
      stat_msg( 'Флаг об ошибке ' + lstr( p_del_error[ 2 ] ) + ' снят со всех пациентов. Войдите в режим "Реестры/Проверка"' )
      mybell( 4, OK )
      RestScreen( buf )
      Return 0
    Elseif nkey == K_CTRL_F5
      If glob_mo[ _MO_KOD_TFOMS ] == '805965' // РДЛ
        tmpSelect := Select()
        if hb_vfExists(cur_dir + fr_data + '2' + sdbf)  
          Use ( cur_dir + fr_data + '2' ) New Alias FRD2
          if frd2->(lastrec()) > 1
            flag_RDL := .T.
          endif     
          frd2->(dbCloseArea())
        endif
        if flag_RDL
          // надо фильтр по коду ошибки
          adbf1 :=  { { 'num_usl', 'C', 10, 0 }, ;    // номер услуги по порядку
          { 'shifr_usl', 'C', 10, 0 }, ;  // шифр услуги
          { 'name_usl', 'C', 250, 0 }, ; // наименование услуги
          { 'NUMORDER', 'N', 10, 0 }, ;   // Номер заявки(ORDER Number)
          { 'fio', 'C', 70, 0 }, ;
          { 'kol_usl', 'N', 10, 0 }, ;    // кол-во услуг
          { 'cena_1', 'N', 11, 2 }, ;
          { 'otd', 'C', 42, 0 }, ;
          { 'otd_kod', 'N', 3, 0 }, ;
          { 'napr_uch', 'C', 6, 0 }  }
          dbCreate( cur_dir + 'tmp_err', adbf1 )
          Use ( cur_dir + fr_data + '2' ) New Alias FRD2
          Use ( cur_dir + 'tmp_err' ) New Alias FRD3

          Private ii_otd
          For ii_otd := 1 To 4
            Select frd2
            Index On shifr_usl + smo_kod + Str( numorder, 10 ) To tmp_frd9  for ( otd_kod == ii_otd .and. REFREASON == kod_REFREASON_menu )
            Go Top
            Select FRD3
            Append Blank
            frd3->fio := frd2->otd
            temp_1 := ' '
            temp_2 := 1
            temp_3 := 0 // кол_во
            temp_4 := 0 // сумма

            Select FRD3
            Append Blank
            // добавляем шапку
            tsmo := ''
            If frd2->smo_kod == '34007'
              tsmo := '"Капитал МС"'
            Elseif  frd2->smo_kod == '34002'
              tsmo := '"Согаз"'
            Else
              tsmo := ' Иногородние ТФОМС'
            Endif
            frd3->fio :=  tsmo
            //
            Do While !Eof()
              If frd2->smo_kod == '34007'
                tsmo := '"Капитал МС"'
              Elseif  frd2->smo_kod == '34002'
                tsmo := '"Согаз"'
              Else
                tsmo := ' Иногородние ТФОМС'
              Endif
              Select FRD3
              Append Blank
              If frd2->shifr_usl != temp_1
                If temp_3 == 0
                  //
                Else
                  frd3->name_usl   := ' ВСЕГО :'
                  frd3->kol_usl    := temp_3
                  frd3->cena_1     := temp_4
                  Append Blank
                  // добавляем шапку
                  frd3->fio :=  tsmo
                  Append Blank
                Endif
                frd3->num_usl    := Str( temp_2 )
                frd3->shifr_usl  := frd2->shifr_usl
                frd3->name_usl   := frd2->name_usl
                temp_1 := frd2->shifr_usl
                temp_2++
                temp_3 := frd2->kol_usl
                temp_4 := frd2->cena_1
              Else
                frd3->shifr_usl  := ' '
                frd3->name_usl   := ' '
                temp_3 += frd2->kol_usl
                temp_4 += frd2->cena_1
              Endif
              frd3->kol_usl    := frd2->kol_usl
              frd3->cena_1     := frd2->cena_1
              frd3->fio        := frd2->fio
              frd3->otd        := frd2->otd
              frd3->NUMORDER   := frd2->NUMORDER
              frd3->napr_uch   := frd2->napr_uch
              Select frd2
              Skip
            Enddo
            Select FRD3
            Append Blank
            frd3->fio        := ' ВСЕГО :'
            frd3->kol_usl    := temp_3
            frd3->cena_1     := temp_4
          Next
          frd3->( dbCloseArea() )
          frd2->( dbCloseArea() )

          Select( tmpSelect )
          // Здесь запрос на запись ЭКСЕЛЯ
          create_xls_rdl( 'rdl_report' )  // , arr_m, st_a_uch, lcount_uch, st_a_otd, lcount_otd)
          saveto( cur_dir + 'rdl_report.xlsx' )
        else
          Select( tmpSelect )
          func_error(4,"Отчет не формировался !")
        endif  

      Endif
    Elseif nkey == K_CTRL_F9
      mywait()
      sh := 110
      fl_povtor := .t.
      fl_povtor1 := .t.
      fl_povtor2 := .t.
      fl_povtor3 := .t.
      fl_povtor4 := .t.
      fp := FCreate( n_file )
      tek_stroke := 0
      n_list := 1
      add_string( '' )
      add_string( Center( 'Сведения об отклоненных от оплаты случаях и стоимости медицинской помощи', sh ) )
      add_string( Center( p_del_error[ 1 ], sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      tmp_1 := Select()
      r_use( dir_server + 'uslugi', , 'USL' )
      // R_Use(dir_server + 'human', ,'HUMAN')
      r_use( dir_server + 'human_u_', , 'HU_' )
      r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
      Set Relation To RecNo() into HU_, To u_kod into USL
      Select ( tmp_1 )
      //
      Private mas_otch := { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, ;
        { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }
      // mas_otch := array(16, 2)
      // afill(mas_otch, 0)
      // arr_iss := array(1, 9) ; afillall(arr_iss, 0)
      //

      Go Top
      Do While !Eof()
        fl_povtor := .t.
        fl_povtor1 := .t.
        fl_povtor2 := .t.
        fl_povtor3 := .t.
        fl_povtor4 := .t.
        verify_ff( HH - 3, .f., sh )
        //
        flag_covid := .f.
        flag_gepat_C := .f.
        If eq_any( human->kod_diag, 'U07.1', 'U07.2' )
          flag_covid := .t.
        Endif
        If !flag_covid
          If eq_any( human->kod_diag2, 'U07.1', 'U07.2' )
            flag_covid := .t.
          Endif
        Endif
        If !flag_covid
          If eq_any( human->kod_diag3, 'U07.1', 'U07.2' )
            flag_covid := .t.
          Endif
        Endif
        If !flag_covid
          If eq_any( human->kod_diag4, 'U07.1', 'U07.2' )
            flag_covid := .t.
          Endif
        Endif
        If AllTrim( human->kod_diag ) == 'B18.2'
          flag_gepat_C  := .t.
        Endif
        If !flag_gepat_C
          If AllTrim( human->kod_diag2 ) == 'B18.2'
            flag_gepat_C  := .t.
          Endif
        Endif
        If !flag_gepat_C
          If AllTrim( human->kod_diag3 ) == 'B18.2'
            flag_gepat_C  := .t.
          Endif
        Endif
        If !flag_gepat_C
          If AllTrim( human->kod_diag4 ) == 'B18.2'
            flag_gepat_C  := .t.
          Endif
        Endif
        //
        // select HUMAN_
        Goto ( ( tmp_1 )->( RecNo() ) )
        // goto (human->(recno()))
        //
        // Диспансеризация
        // If eq_any( human->ishod, 401, 402 ) .and. HUMAN_->Usl_ok == 3 // амбулаторная// УД 
        If is_sluch_dispanser_COVID( human->ishod ) .and. HUMAN_->Usl_ok == 3 // амбулаторная// УД 
          If human->vzros_reb == 0 // взрослый
            mas_otchet[ 10, 1 ] += 1
            mas_otchet[ 10, 2 ] += human->cena_1
          Else
            mas_otchet[ 10, 3 ] += 1
            mas_otchet[ 10, 4 ] += human->cena_1
          Endif
        Elseif eq_any( human->ishod, 201, 202, 101, 102 ) .and. HUMAN_->Usl_ok == 3 // амбулаторная// Диспансеризация
          If human->vzros_reb == 0 // взрослый
            mas_otchet[ 9, 1 ] += 1
            mas_otchet[ 9, 2 ] += human->cena_1
          Else
            mas_otchet[ 9, 3 ] += 1
            mas_otchet[ 9, 4 ] += human->cena_1
          Endif
        Elseif eq_any( human->ishod, 203, 301, 302, 303, 304, 305 ) .and. HUMAN_->Usl_ok == 3 // амбулаторная// Профосмотры
          If human->vzros_reb == 0 // взрослый
            mas_otchet[ 7, 1 ] += 1
            mas_otchet[ 7, 2 ] += human->cena_1
          Else
            mas_otchet[ 7, 3 ] += 1
            mas_otchet[ 7, 4 ] += human->cena_1
          Endif
        Elseif eq_any( human->ishod, 501 ) .and. HUMAN_->Usl_ok == 3 // амбулаторная// Репродуктивка
          If human->vzros_reb == 0 // взрослый
            mas_otchet[ 43, 1 ] += 1
            mas_otchet[ 43, 2 ] += human->cena_1
          Else
            mas_otchet[ 43, 3 ] += 1
            mas_otchet[ 43, 4 ] += human->cena_1
          Endif
        Endif  // прочее

        Select HU
        find ( Str( human->kod, 7 ) )
        Do While human->kod == hu->kod .and. !Eof()
          // ныряем в услуги - если Диагностика - должно быть 60.*
          lshifr := ''
          svp := Space( 5 )
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , , , , @svp )
            lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
          Endif
          //
          If HUMAN_->Usl_ok == 1 // стационар
            If PadR( lshifr, 2 ) == 'st' // KSG
              mas_otch[ 1, 1 ] += 1
              mas_otch[ 2, 1 ] += human->cena_1 // hu->stoim
              If eq_any( PadR( AllTrim( lshifr ), 8 ), 'st12.015', 'st12.016', ;
                  'st12.017', 'st12.018', 'st12.019' )
                mas_otch[ 1, 2 ] += 1
                mas_otch[ 2, 2 ] += human->cena_1 // hu->stoim
              Endif
              If HUMAN_->profil == 60 // онкология
                If human->vzros_reb == 0 // взрослый
                  mas_otchet[ 29, 1 ] += 1
                  mas_otchet[ 29, 2 ] += human->cena_1
                Else
                  mas_otchet[ 29, 3 ] += 1
                  mas_otchet[ 29, 4 ] += human->cena_1
                Endif
              Elseif  HUMAN_->profil == 158   // медицинская реабилитация
                If human->vzros_reb == 0 // взрослый
                  mas_otchet[ 30, 1 ] += 1
                  mas_otchet[ 30, 2 ] += human->cena_1
                Else
                  mas_otchet[ 30, 3 ] += 1
                  mas_otchet[ 30, 4 ] += human->cena_1
                Endif
              Else // Иные профили, всего, в том числе
                If human->vzros_reb == 0 // взрослый
                  mas_otchet[ 31, 1 ] += 1
                  mas_otchet[ 31, 2 ] += human->cena_1
                Else
                  mas_otchet[ 31, 3 ] += 1
                  mas_otchet[ 31, 4 ] += human->cena_1
                Endif
                If flag_covid // пациентам с новой коронавирусной инфекцией COVID-19
                  If human->vzros_reb == 0 // взрослый
                    mas_otchet[ 32, 1 ] += 1
                    mas_otchet[ 32, 2 ] += human->cena_1
                  Else
                    mas_otchet[ 32, 3 ] += 1
                    mas_otchet[ 32, 4 ] += human->cena_1
                  Endif
                Endif
                // гепатит C (B18.2)
                If flag_gepat_C
                  If human->vzros_reb == 0 // взрослый
                    mas_otchet[ 37, 1 ] += 1
                    mas_otchet[ 37, 2 ] += human->cena_1
                  Else
                    mas_otchet[ 37, 3 ] += 1
                    mas_otchet[ 37, 4 ] += human->cena_1
                  Endif
                Endif
              Endif
              // 28 = 29+30+31 Стационарная медицинская помощь
              If human->vzros_reb == 0 // взрослый
                mas_otchet[ 28, 1 ] += 1
                mas_otchet[ 28, 2 ] += human->cena_1
              Else
                mas_otchet[ 28, 3 ] += 1
                mas_otchet[ 28, 4 ] += human->cena_1
              Endif
            Endif
          Endif
          //
          If HUMAN_->Usl_ok == 2 // дневной стационар
            If PadR( lshifr, 2 ) == 'ds' // KSG -дневной стационар
              mas_otch[ 3, 1 ] += 1
              mas_otch[ 4, 1 ] += human->cena_1
              If flag_covid
                mas_otch[ 3, 2 ] += 1
                mas_otch[ 4, 2 ] += human->cena_1
              Endif
              If HUMAN_->profil == 60 // онкология
                If human->vzros_reb == 0 // взрослый
                  mas_otchet[ 25, 1 ] += 1
                  mas_otchet[ 25, 2 ] += human->cena_1
                Else
                  mas_otchet[ 25, 3 ] += 1
                  mas_otchet[ 25, 4 ] += human->cena_1
                Endif
              Elseif  HUMAN_->profil == 137   // ЭКО
                If human->vzros_reb == 0 // взрослый
                  mas_otchet[ 26, 1 ] += 1
                  mas_otchet[ 26, 2 ] += human->cena_1
                Else
                  mas_otchet[ 26, 3 ] += 1
                  mas_otchet[ 26, 4 ] += human->cena_1
                Endif
              Elseif human_->profil == 158
                If human->vzros_reb == 0 // взрослый
                  mas_otchet[ 38, 1 ] += 1
                  mas_otchet[ 38, 2 ] += human->cena_1
                Else
                  mas_otchet[ 38, 3 ] += 1
                  mas_otchet[ 38, 4 ] += human->cena_1
                Endif
              Else // иные профили
                If human->vzros_reb == 0 // взрослый
                  mas_otchet[ 27, 1 ] += 1
                  mas_otchet[ 27, 2 ] += human->cena_1
                Else
                  mas_otchet[ 27, 3 ] += 1
                  mas_otchet[ 27, 4 ] += human->cena_1
                Endif
                // гепатит C (B18.2)
                If flag_gepat_C
                  If human->vzros_reb == 0 // взрослый
                    mas_otchet[ 36, 1 ] += 1
                    mas_otchet[ 36, 2 ] += human->cena_1
                  Else
                    mas_otchet[ 36, 3 ] += 1
                    mas_otchet[ 36, 4 ] += human->cena_1
                  Endif
                Endif
              Endif
              If human->vzros_reb == 0 // взрослый
                mas_otchet[ 24, 1 ] += 1  // 24 = 25+26+27 Дневные стационары, всего,
                mas_otchet[ 24, 2 ] += human->cena_1
              Else
                mas_otchet[ 24, 3 ] += 1  // 24 = 25+26+27 Дневные стационары, всего,
                mas_otchet[ 24, 4 ] += human->cena_1
              Endif
            Endif
          Endif
          //
          If HUMAN_->Usl_ok == 3 // амбулаторная
            // Диспансеризация
            // If eq_any( human->ishod, 401, 402 ) // УД
            If is_sluch_dispanser_COVID( human->ishod ) // УД
              // mas_otchet[10, 1] += 1
              // mas_otchet[10, 2] += human->cena_1
            Elseif eq_any( human->ishod, 201, 202, 101, 102 ) // Диспансеризация
              // mas_otchet[9, 1] += 1
              // mas_otchet[9, 2] += human->cena_1
            Elseif eq_any( human->ishod, 203, 301, 302, 303, 304, 305 ) // Профосмотры
              // mas_otchet[7, 1] += 1
              // mas_otchet[7, 2] += human->cena_1
            Elseif eq_any( human->ishod, 501 ) // Репродуктивка 
              //
            Else  // прочее
              If PadR( lshifr, 3 ) == '60.' // Диагностика
                If PadR( lshifr, 4 ) == '60.4' // КТ
                  mas_otch[ 13, 1 ] += 1
                  mas_otch[ 14, 1 ] += hu->stoim
                  //
                  If human->vzros_reb == 0 // взрослый
                    If fl_povtor1
                      mas_otchet[ 17, 1 ] += 1
                      fl_povtor1 := .f.
                    Endif
                    mas_otchet[ 17, 2 ] += hu->stoim // human->cena_1
                  Else
                    If fl_povtor1
                      mas_otchet[ 17, 3 ] += 1
                      fl_povtor1 := .f.
                    Endif
                    mas_otchet[ 17, 4 ] += hu->stoim // human->cena_1
                  Endif
                Endif
                If PadR( lshifr, 4 ) == '60.5' // МРТ
                  If human->vzros_reb == 0 // взрослый
                    If fl_povtor2
                      mas_otchet[ 18, 1 ] += 1
                      fl_povtor2 := .f.
                    Endif
                    mas_otchet[ 18, 2 ] += hu->stoim // human->cena_1
                  Else
                    If fl_povtor2
                      mas_otchet[ 18, 3 ] += 1
                      fl_povtor2 := .f.
                    Endif
                    mas_otchet[ 18, 4 ] += hu->stoim // human->cena_1
                  Endif
                Endif
                If PadR( lshifr, 4 ) == '60.6' // CCC
                  If human->vzros_reb == 0 // взрослый
                    If fl_povtor3
                      mas_otchet[ 19, 1 ] += 1
                      fl_povtor3 := .f.
                    Endif
                    mas_otchet[ 19, 2 ] +=  hu->stoim // human->cena_1
                  Else
                    If fl_povtor3
                      mas_otchet[ 19, 3 ] += 1
                      fl_povtor3 := .f.
                    Endif
                    mas_otchet[ 19, 4 ] += hu->stoim // human->cena_1
                  Endif
                Endif
                If PadR( lshifr, 4 ) == '60.7' // эндоскопические диагностические исследования
                  If human->vzros_reb == 0 // взрослый
                    If fl_povtor4
                      mas_otchet[ 20, 1 ] += 1
                      fl_povtor4 := .f.
                    Endif
                    mas_otchet[ 20, 2 ] += hu->stoim // human->cena_1
                  Else
                    If fl_povtor4
                      mas_otchet[ 20, 3 ] += 1
                      fl_povtor4 := .f.
                    Endif
                    mas_otchet[ 20, 4 ] += hu->stoim // human->cena_1
                  Endif
                Endif
                If PadR( lshifr, 4 ) == '60.8' // патанатомия
                  If human->vzros_reb == 0 // взрослый
                    mas_otchet[ 22, 1 ] += 1
                    mas_otchet[ 22, 2 ] += human->cena_1
                  Else
                    mas_otchet[ 22, 3 ] += 1
                    mas_otchet[ 22, 4 ] += human->cena_1
                  Endif
                Endif
                If PadR( lshifr, 4 ) == '60.9' // генная
                  If human->vzros_reb == 0 // взрослый
                    mas_otchet[ 21, 1 ] += 1
                    mas_otchet[ 21, 2 ] += human->cena_1
                  Else
                    mas_otchet[ 21, 3 ] += 1
                    mas_otchet[ 21, 4 ] += human->cena_1
                  Endif
                Endif
                //
                mas_otch[ 11, 1 ] += 1
                mas_otch[ 12, 1 ] += hu->stoim
                If flag_covid
                  mas_otch[ 11, 2 ] += 1
                  mas_otch[ 12, 2 ] += hu->stoim
                Endif
              Endif
              //
              If PadR( AllTrim( lshifr ), 8 ) == '4.17.785' .or. ;
                  PadR( AllTrim( lshifr ), 8 ) == '4.17.786' .or. ;
                  PadR( AllTrim( lshifr ), 8 ) == '4.17.787'     // COVID
                //
                mas_otch[ 15, 1 ] += 1
                mas_otch[ 16, 1 ] += hu->stoim
                //
                mas_otch[ 11, 1 ] += 1
                mas_otch[ 12, 1 ] += hu->stoim
                If flag_covid
                  mas_otch[ 11, 2 ] += 1
                  mas_otch[ 12, 2 ] += hu->stoim
                Endif
                If human->vzros_reb == 0 // взрослый
                  mas_otchet[ 23, 1 ] += 1
                  mas_otchet[ 23, 2 ] += human->cena_1
                Else
                  mas_otchet[ 23, 3 ] += 1
                  mas_otchet[ 23, 4 ] += human->cena_1
                Endif
              Endif
              If PadR( AllTrim( lshifr ), 6 ) == '2.92.1' .or. ;
                  PadR( AllTrim( lshifr ), 6 ) == '2.92.2' .or. ;
                  PadR( AllTrim( lshifr ), 6 ) == '2.92.3'
                If PadR( AllTrim( lshifr ), 6 ) == '2.92.3' // дети
                  mas_otchet[ 34, 3 ] += 1
                  mas_otchet[ 34, 4 ] += human->cena_1
                Else
                  mas_otchet[ 34, 1 ] += 1
                  mas_otchet[ 34, 2 ] += human->cena_1
                Endif
              Endif
              // профеля
              If PadR( lshifr, 5 ) == '2.80.' .or. ; // Неотложка
                PadR( lshifr, 5 ) == '2.82.'        // ПРиемный покой
                mas_otch[ 9, 1 ]  += 1
                mas_otch[ 10, 1 ] += hu->stoim
                If human->vzros_reb == 0 // взрослый
                  mas_otchet[ 12, 1 ] += 1
                  mas_otchet[ 12, 2 ] += human->cena_1
                Else
                  mas_otchet[ 12, 3 ] += 1
                  mas_otchet[ 12, 4 ] += human->cena_1
                Endif
                If flag_covid
                  mas_otch[ 9, 2 ]  += 1
                  mas_otch[ 10, 2 ] += hu->stoim
                Endif
              Elseif PadR( lshifr, 5 ) == '2.78.' // Обращения
                // нужен фильтр по профилям
                // Акушерство и генология == 2, 136, 137
                // Дерматовенерология  == 16
                // Онкология == 60
                // Травматология и ортопедия == 100
                // Стоматологии 85, 86, 87, 88, 89, 90, 171,
                // Медреабилитация 158
                If PadR( lshifr, 8 ) == '2.78.110' // онкология
                  If human->vzros_reb == 0 // взрослый
                    mas_otchet[ 44, 1 ] += 1
                    mas_otchet[ 44, 2 ] += human->cena_1
                  Else
                    mas_otchet[ 44, 3 ] += 1
                    mas_otchet[ 44, 4 ] += human->cena_1
                  Endif
                Endif
                If PadR( lshifr, 8 ) == '2.78.112' // ССЗ
                  If human->vzros_reb == 0 // взрослый
                    mas_otchet[ 45, 1 ] += 1
                    mas_otchet[ 45, 2 ] += human->cena_1
                  Else
                    mas_otchet[ 45, 3 ] += 1
                    mas_otchet[ 45, 4 ] += human->cena_1
                  Endif
                Endif
                If PadR( lshifr, 8 ) == '2.78.111' // Сахарный диабет
                  If human->vzros_reb == 0 // взрослый
                    mas_otchet[ 46, 1 ] += 1
                    mas_otchet[ 46, 2 ] += human->cena_1
                  Else
                    mas_otchet[ 46, 3 ] += 1
                    mas_otchet[ 46, 4 ] += human->cena_1
                  Endif
                Endif
                If  PadR( lshifr, 8 ) == '2.78.109' // прочее диспансерное наблюдение
                  If human->vzros_reb == 0 // взрослый
                    mas_otchet[ 47, 1 ] += 1
                    mas_otchet[ 47, 2 ] += human->cena_1
                  Else
                    mas_otchet[ 47, 3 ] += 1
                    mas_otchet[ 47, 4 ] += human->cena_1
                  Endif
                Endif
                mas_otchet[ 35, 1 ] := mas_otchet[ 44, 1 ] + mas_otchet[ 45, 1 ] + mas_otchet[ 46, 1 ] + mas_otchet[ 47, 1 ]
                mas_otchet[ 35, 2 ] := mas_otchet[ 44, 2 ] + mas_otchet[ 45, 2 ] + mas_otchet[ 46, 2 ] + mas_otchet[ 47, 2 ]
                mas_otchet[ 35, 3 ] := mas_otchet[ 44, 3 ] + mas_otchet[ 45, 3 ] + mas_otchet[ 46, 3 ] + mas_otchet[ 47, 3 ]
                mas_otchet[ 35, 4 ] := mas_otchet[ 44, 4 ] + mas_otchet[ 45, 4 ] + mas_otchet[ 46, 4 ] + mas_otchet[ 47, 4 ]
                //
                If eq_any( human_->profil, 2, 136, 137, 16, 60, 100, 85, 86, 87, 89, 90, 171, 158 )
                  mas_otch[ 7, 1 ] += 1
                  mas_otch[ 8, 1 ] += hu->stoim
                  If flag_covid
                    mas_otch[ 7, 2 ] += 1
                    mas_otch[ 8, 2 ] += hu->stoim
                  Endif
                  If human_->profil == 158
                    If human->vzros_reb == 0 // взрослый
                      mas_otchet[ 13, 1 ] += 1
                      mas_otchet[ 13, 2 ] += human->cena_1
                    Else
                      mas_otchet[ 13, 3 ] += 1
                      mas_otchet[ 13, 4 ] += human->cena_1
                    Endif
                  Else
                    If human->vzros_reb == 0 // взрослый
                      mas_otchet[ 14, 1 ] += 1
                      mas_otchet[ 14, 2 ] += human->cena_1
                    Else
                      mas_otchet[ 14, 3 ] += 1
                      mas_otchet[ 14, 4 ] += human->cena_1
                    Endif
                    If flag_covid
                      If human->vzros_reb == 0 // взрослый
                        mas_otchet[ 15, 1 ] += 1
                        mas_otchet[ 15, 2 ] += human->cena_1
                      Else
                        mas_otchet[ 15, 3 ] += 1
                        mas_otchet[ 15, 4 ] += human->cena_1
                      Endif
                    Endif
                  Endif
                Endif
              Else // посещения с иными целями
                // отсекаем нулевки
                If hu->stoim > 0
                  If human->vzros_reb == 0 // взрослый
                    If fl_povtor
                      mas_otchet[ 11, 1 ] += 1
                      fl_povtor := .f.
                    Endif
                    mas_otchet[ 11, 2 ] += hu->stoim // human->cena_1
                  Else
                    If fl_povtor
                      mas_otchet[ 11, 3 ] += 1
                      fl_povtor := .f.
                    Endif
                    mas_otchet[ 11, 4 ] += hu->stoim // human->cena_1
                  Endif
                Endif
              Endif
            Endif
            //
            If PadR( lshifr, 5 ) == '2.79.' .or. ; // Посещения профилактические
              PadR( lshifr, 5 ) == '2.88.'       //
              // нужен фильтр по профилям
              If eq_any( human_->profil, 2, 136, 137, 16, 60, 100, 85, 86, 87, 89, 90, 171, 158 )
                mas_otch[ 5, 1 ] += 1
                mas_otch[ 6, 1 ] += hu->stoim
                If flag_covid
                  mas_otch[ 5, 2 ] += 1
                  mas_otch[ 6, 2 ] += hu->stoim
                Endif
              Endif
            Endif
            If PadR( lshifr, 3 ) == '71.' // Скорая
              If human->vzros_reb == 0 // взрослый
                mas_otchet[ 3, 1 ] += 1
                mas_otchet[ 3, 2 ] += human->cena_1
              Else
                mas_otchet[ 3, 3 ] += 1
                mas_otchet[ 3, 4 ] += human->cena_1
              Endif
              If flag_covid
                If human->vzros_reb == 0 // взрослый
                  mas_otchet[ 4, 1 ] += 1
                  mas_otchet[ 4, 2 ] += human->cena_1
                Else
                  mas_otchet[ 4, 3 ] += 1
                  mas_otchet[ 4, 4 ] += human->cena_1
                Endif
              Endif
            Endif
          Endif
          Select HU
          Skip
        Enddo
        Select ( tmp_1 )
        Skip
      Enddo
      // подбивка
      my_debug(, print_array( mas_otchet ) )
      mas_otchet[ 8, 1 ] := mas_otchet[ 9, 1 ] + mas_otchet[ 10, 1 ] + mas_otchet[ 43, 1 ]
      mas_otchet[ 8, 2 ] := mas_otchet[ 9, 2 ] + mas_otchet[ 10, 2 ] + mas_otchet[ 43, 2 ]
      mas_otchet[ 8, 3 ] := mas_otchet[ 9, 3 ] + mas_otchet[ 10, 3 ] + mas_otchet[ 43, 3 ]
      mas_otchet[ 8, 4 ] := mas_otchet[ 9, 4 ] + mas_otchet[ 10, 4 ] + mas_otchet[ 43, 4 ]
      //
      mas_otchet[ 6, 1 ] := mas_otchet[ 7, 1 ] + mas_otchet[ 8, 1 ]
      mas_otchet[ 6, 2 ] := mas_otchet[ 7, 2 ] + mas_otchet[ 8, 2 ]
      mas_otchet[ 6, 3 ] := mas_otchet[ 7, 3 ] + mas_otchet[ 8, 3 ]
      mas_otchet[ 6, 4 ] := mas_otchet[ 7, 4 ] + mas_otchet[ 8, 4 ]
      //
      mas_otchet[ 5, 1 ] := mas_otchet[ 6, 1 ] + mas_otchet[ 11, 1 ] + mas_otchet[ 12, 1 ] + mas_otchet[ 13, 1 ] + mas_otchet[ 14, 1 ]
      mas_otchet[ 5, 2 ] := mas_otchet[ 6, 2 ] + mas_otchet[ 11, 2 ] + mas_otchet[ 12, 2 ] + mas_otchet[ 13, 2 ] + mas_otchet[ 14, 2 ]
      mas_otchet[ 5, 3 ] := mas_otchet[ 6, 3 ] + mas_otchet[ 11, 3 ] + mas_otchet[ 12, 3 ] + mas_otchet[ 13, 3 ] + mas_otchet[ 14, 3 ]
      mas_otchet[ 5, 4 ] := mas_otchet[ 6, 4 ] + mas_otchet[ 11, 4 ] + mas_otchet[ 12, 4 ] + mas_otchet[ 13, 4 ] + mas_otchet[ 14, 4 ]
      //
      mas_otchet[ 1, 1 ] := mas_otchet[ 3, 1 ] + mas_otchet[ 5, 1 ] + mas_otchet[ 24, 1 ] + mas_otchet[ 28, 1 ]
      mas_otchet[ 1, 2 ] := mas_otchet[ 3, 2 ] + mas_otchet[ 5, 2 ] + mas_otchet[ 24, 2 ] + mas_otchet[ 28, 2 ]
      mas_otchet[ 1, 3 ] := mas_otchet[ 3, 3 ] + mas_otchet[ 5, 3 ] + mas_otchet[ 24, 3 ] + mas_otchet[ 28, 3 ]
      mas_otchet[ 1, 4 ] := mas_otchet[ 3, 4 ] + mas_otchet[ 5, 4 ] + mas_otchet[ 24, 4 ] + mas_otchet[ 28, 4 ]
      //
      mas_otchet[ 2, 1 ] := mas_otchet[ 4, 1 ] + mas_otchet[ 15, 1 ] + mas_otchet[ 23, 1 ] + mas_otchet[ 32, 1 ]
      mas_otchet[ 2, 2 ] := mas_otchet[ 4, 2 ] + mas_otchet[ 15, 2 ] + mas_otchet[ 23, 2 ] + mas_otchet[ 32, 2 ]
      mas_otchet[ 2, 3 ] := mas_otchet[ 4, 3 ] + mas_otchet[ 15, 3 ] + mas_otchet[ 23, 3 ] + mas_otchet[ 32, 3 ]
      mas_otchet[ 2, 4 ] := mas_otchet[ 4, 4 ] + mas_otchet[ 15, 4 ] + mas_otchet[ 23, 4 ] + mas_otchet[ 32, 4 ]
      //
      mas_otchet[ 14, 2 ] += mas_otchet[ 17, 2 ] + mas_otchet[ 18, 2 ] + mas_otchet[ 19, 2 ] + mas_otchet[ 20, 2 ] + mas_otchet[ 21, 2 ] + ;
        mas_otchet[ 22, 2 ] + mas_otchet[ 23, 2 ]
      mas_otchet[ 14, 4 ] += mas_otchet[ 17, 4 ] + mas_otchet[ 18, 4 ] + mas_otchet[ 19, 4 ] + mas_otchet[ 20, 4 ] + mas_otchet[ 21, 4 ] + ;
        mas_otchet[ 22, 4 ] + mas_otchet[ 23, 4 ]
      //
      //
      add_string( '                                                          Взрослые   Дети     Итого         Взрослые     Дети    Итого' )
      add_string( ' 1 = 3+5+31+37 Всего, в том числе                      ' + prn_novor( mas_otchet, 1 ) )
      add_string( ' 2 = 4+15+25+41 пациентам с COVID-19                   ' + prn_novor( mas_otchet, 2 ) )
      add_string( ' 3 Скорая медицинская помощь, всего, в том числе       ' + prn_novor( mas_otchet, 3 ) ) //
      add_string( ' 4 пациентам с новой коронавирусной инфекцией COVID-19 ' + prn_novor( mas_otchet, 4 ) ) //
      add_string( ' 5 = 6+11+13+14+17+30 Амбулаторно-поликлиническая пом. ' + prn_novor( mas_otchet, 5 ) )
      add_string( ' 6 = 7+8 Посещения с профилактическими целями          ' + prn_novor( mas_otchet, 6 ) ) //
      add_string( ' 7 для проведения профилактических медицинских осмотров' + prn_novor( mas_otchet, 7 ) ) //
      add_string( ' 8 для проведения диспансеризации, всего               ' + prn_novor( mas_otchet, 8 ) ) //
      add_string( '  9 угубленная диспансеризации                         ' + prn_novor( mas_otchet, 10 ) ) //
      add_string( '  10 репродуктивного возраста                          ' + prn_novor( mas_otchet, 43 ) ) // !!!!!!!!!!!!!!!!!!!!!!!!!!!
      add_string( ' 11 Посещений с иными целями                           ' + prn_novor( mas_otchet, 11 ) )
      add_string( ' 12 из них: школы для больных сахарным диабетом        ' + prn_novor( mas_otchet, 34 ) )
      add_string( ' 13 Посещения по неотложной помощи                     ' + prn_novor( mas_otchet, 12 ) )
      add_string( ' 14 Обращения по заболеваниям - мед. реабилитация      ' + prn_novor( mas_otchet, 13 ) )
      add_string( ' 15 из них: посещения на дому                          ' )                            // ----------------
      add_string( ' 16         телемедицина                               ' )                            // ----------------
      add_string( ' 17 Обращения по заболеваниям, всего, из них           ' + prn_novor( mas_otchet, 14 ) ) //
      add_string( ' 18 пациентам с новой коронавирусной инфекцией COVID-19' + prn_novor( mas_otchet, 15 ) ) //
      add_string( ' 19 компьютерная томография                            ' + prn_novor( mas_otchet, 17 ) ) //
      add_string( ' 20 магнитно-резонансная томография                    ' + prn_novor( mas_otchet, 18 ) ) //
      add_string( ' 21 ультразвуковое исследование ССС                    ' + prn_novor( mas_otchet, 19 ) ) //
      add_string( ' 22 эндоскопические диагностические исследования       ' + prn_novor( mas_otchet, 20 ) ) //
      add_string( ' 23 молекулярно-биологическое исследования             ' + prn_novor( mas_otchet, 21 ) ) //
      add_string( ' 24 патолого-анатомическое исследование материала      ' + prn_novor( mas_otchet, 22 ) ) //
      add_string( ' 25 тестирование на выявление  инфекции COVID-19       ' + prn_novor( mas_otchet, 23 ) ) //
      add_string( ' 26 тестирование на наличие ОРВи и Гриппа              ' )                           // ----------------
      add_string( ' 27 из них: по заболеванию грипп                       ' )                           // ----------------
      add_string( ' 28 из них: по заболеванию ОРВи                        ' )                           // ----------------
      add_string( ' 29 Телемедицина                                       ' )                           // ----------------
      add_string( ' 30 Диспансерное наблюдение  ВСЕГО                     ' + prn_novor( mas_otchet, 35 ) )
      add_string( ' 30.1 ДН с онкозаболеваниями                           ' + prn_novor( mas_otchet, 44 ) )
      add_string( ' 30.2 ДН с ССЗ                                         ' + prn_novor( mas_otchet, 45 ) )
      add_string( ' 30.3 ДН с сахарным диабетом                           ' + prn_novor( mas_otchet, 46 ) )
      add_string( ' 30.4 ДН прочие                                        ' + prn_novor( mas_otchet, 47 ) )
      add_string( ' 30.5 ДН на рабочем месте                              ' + prn_novor( mas_otchet, 48 ) )
      add_string( '                   ДНЕВНОЙ СТАЦИОНАР' )
      add_string( ' 31 = 32+33+34+35+36 Дневные стационары, всего, в т.ч. ' + prn_novor( mas_otchet, 24 ) )
      add_string( ' 32 по профилю "Онкология"                             ' + prn_novor( mas_otchet, 25 ) )
      add_string( ' 33 экстракорпоральное оплодотворение                  ' + prn_novor( mas_otchet, 26 ) )
      add_string( ' 34 иные профили, Всего, из них                        ' + prn_novor( mas_otchet, 27 ) )
      add_string( ' 35 медицинская реабилитация                           ' + prn_novor( mas_otchet, 36 ) )
      add_string( ' 36 по заболеванию гепатитом С                         ' + prn_novor( mas_otchet, 36 ) )
      add_string( '            Стационарная медицинская помощь' )
      add_string( ' 37 = 38+39+40 Стационарная медицинская помощь, всего, ' + prn_novor( mas_otchet, 28 ) )
      add_string( ' 38 по профилю "Онкология"                             ' + prn_novor( mas_otchet, 29 ) )
      add_string( ' 39 медицинская реабилитация                           ' + prn_novor( mas_otchet, 30 ) )
      add_string( ' 40 Иные профили, всего, в том числе                   ' + prn_novor( mas_otchet, 31 ) )
      add_string( ' 41 пациентам с  инфекцией COVID-19                    ' + prn_novor( mas_otchet, 32 ) )
      add_string( ' 42 по заболеванию гепатитом С                         ' + prn_novor( mas_otchet, 37 ) )
      //
      //
      USL->( dbCloseArea() )
      HU_->( dbCloseArea() )
      HU->( dbCloseArea() )
      Select ( tmp_1 )
      Goto rec1
      add_string( '' )
      FClose( fp )
      RestScreen( buf )
      viewtext( n_file, , , , ( sh > 80 ), , , 3 )
      Return -1
      // заплатка
      // elseif eq_any(nkey,K_F10,K_CTRL_F10) .and. tip_polzovat == TIP_ADM .and. f_Esc_Enter('смена услуги', .t.)
    Elseif eq_any( nkey, K_F10, K_CTRL_F10 ) .and. hb_user_curUser:isadmin() .and. f_esc_enter( 'смена услуги', .t. )
      tmp_1 := Select()
      g_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
      Select ( tmp_1 )
      Go Top
      Do While !Eof()
        human_->( g_rlock( forever ) )
        human_->OPLATA    := 0 // уберём '2', если отредактировали запись из реестра СП и ТК
        human_->ST_VERIFY := 0 // снова ещё не проверен
        //
        Select ( 'HU' )
        find ( Str( human->kod, 7 ) )
        if( hu->u_kod == 217 ) // 611
          hu->( g_rlock( forever ) )
          hu->u_kod := 220  // 614
        Endif
        //
        if( hu->u_kod == 219 )
          hu->( g_rlock( forever ) )
          hu->u_kod := 220
        Endif
        //
        Select ( tmp_1 )
        Skip
      Enddo
      Goto rec1
      stat_msg( 'Услуга заменена у всех пациентов. Войдите в режим "Реестры/Проверка"' )
      mybell( 4, OK )
      RestScreen( buf )
      Return 0

    Endif
  Endif
  If nkey != K_F2
    Return -1
  Endif
  buf1 := SaveScreen( 13, 4, 19, 77 )
  Do While .t.
    tmp1 := PadR( tmp, 50 )
    SetColor( color8 )
    box_shadow( 13, 14, 18, 67 )
    @ 15, 15 Say Center( ' Введите шаблон для поиска фамилий', 52 )
    status_key( '^<Esc>^ - отказ от ввода;  ^<F1>^ - помощь' )
    @ 16, 16 Get tmp1 Picture '@K@!'
    myread()
    SetColor( color0 )
    If LastKey() == K_ESC .or. Empty( tmp1 )
      Exit
    Endif
    mywait()
    tmp := AllTrim( tmp1 )
    Private tmp_mas := {}, tmp_kod := {}, i := 0, t_len, k1 := mr1 + 3, ;
      k2 := 21, tmp2 := Upper( tmp ), ch := Left( tmp, 1 )
    If !( '*' $ tmp2 )
      tmp2 := '*' + tmp2 + '*'
    Endif
    ch := Left( tmp2, 1 )
    If !( ch == '*' .or. ch == '?' )
      tmp1 := tmp2
      If '*' $ tmp1
        tmp1 := BeforAtNum( '*', tmp1, 1 )
      Endif
      If '?' $ tmp1
        tmp1 := BeforAtNum( '?', tmp1, 1 )
      Endif
      ch := Len( tmp1 )
      find ( tmp1 )
      Do While tmp1 == Left( Upper( human->fio ), ch ) .and. !Eof()
        If Like( tmp2, Upper( human->fio ) )
          If++i > 4000
            Exit
          Endif
          AAdd( tmp_mas, fio_plus_novor() )
          AAdd( tmp_kod, human->kod )
        Endif
        Skip
      Enddo
    Else
      Go Top
      Do While !Eof()
        If Like( tmp2, Upper( human->fio ) )
          If++i > 4000
            Exit
          Endif
          AAdd( tmp_mas, fio_plus_novor() )
          AAdd( tmp_kod, human->kod )
        Endif
        Skip
      Enddo
    Endif
    If ( t_len := Len( tmp_kod ) ) = 0
      stat_msg( 'Не найдено ни одной записи, удовлетворяющей данному шаблону!' )
      mybell( 2, ERR )
      RestScreen( 13, 4, 19, 77, buf1 )
      Loop
    Else
      box_shadow( mr1, 2, 22, 77 )
      SetColor( col_tit_popup )
      @ k1 - 2, 15 Say 'Шаблон: ' + tmp2
      SetColor( color0 )
      If k1 + t_len + 2 < 21
        k2 := k1 + t_len + 2
      Endif
      @ k1, 3 Say Center( ' Количество найденных фамилий - ' + lstr( t_len ), 74 )
      i := AScan( tmp_kod, glob_perso )
      status_key( '^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор' )
      If ( i := Popup( k1 + 1, 13, k2, 66, tmp_mas, i, color0 ) ) > 0
        If regim_vyb == 1
          Goto ( tmp_kod[ i ] )
        Else
          Select TMP_H
          Go Top
          Locate For kod == tmp_kod[ i ]
        Endif
        fl := 0
      Endif
      Exit
    Endif
  Enddo
  If fl == -1
    Goto rec1
  Endif
  RestScreen( buf )

  Return fl

// 05.03.13
Function f21ret_oms_human()

  Local s, r := Row(), c := Col()

  s := 'Полис ОМС: ' + ;
    AllTrim( RTrim( human_->SPOLIS ) + ' ' + human_->NPOLIS ) + ' (' + ;
    AllTrim( inieditspr( A__MENUVERT, mm_vid_polis, human_->VPOLIS ) ) + ')'
  @ MaxRow() -2, 3 Say PadC( s, 74 ) Color color0
  SetPos( r, c )

  Return Nil

// 09.02.14 ФИО пациента + если есть, номер новорожденного ребёнка
Function fio_plus_novor()

  Return AllTrim( human->fio ) + ;
    iif( human_->NOVOR == 0, '', ' (' + lstr( human_->NOVOR ) + '-й реб.)' )

// 05.04.23
Function prn_novor( mas_otchet, pozic )

  Local c

  c := PadL( lstr( mas_otchet[ pozic, 1 ] ), 8 ) + ;
    PadL( lstr( mas_otchet[ pozic, 3 ] ), 9 ) + ;
    PadL( lstr( mas_otchet[ pozic, 1 ] + mas_otchet[ pozic, 3 ] ), 9 ) + '  сумма:' + ;
    put_kop( mas_otchet[ pozic, 2 ], 10 ) + ;
    put_kop( mas_otchet[ pozic, 4 ], 11 ) + ;
    put_kop( mas_otchet[ pozic, 2 ] + mas_otchet[ pozic, 4 ], 11 )

  Return c
