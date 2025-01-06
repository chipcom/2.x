#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 15.01.23
Function init_lek_pr()

  Local s, n

  Use ( cur_dir + 'tmp_onkle' ) New Alias TMPLE
  Index On REGNUM to ( cur_dir + 'tmp_onkle' ) UNIQUE
  n := 0
  dbEval( {|| ++n } )
  s := 'препаратов - ' + lstr( n )
  Index On DToS( DATE_INJ ) to ( cur_dir + 'tmp_onkle' ) UNIQUE
  n := 0
  dbEval( {|| ++n } )
  s += ', дней приёма - ' + lstr( n )
  tmple->( dbCloseArea() )

  Return s


// 09.12.23 проверка на необходимость ввода лекарственных препаратов
Function check_oms_sluch_lek_pr( mkod_human )

  // mkod_human - код по БД human

  Local vidPom, m1USL_OK, m1PROFIL, last_date, mdiagnoz, d1, d2, ad_cr
  Local retFl := .f., mvozrast, p_cel

  g_use( dir_server + 'human_2', , 'HUMAN_2' )
  g_use( dir_server + 'human_', , 'HUMAN_' )
  g_use( dir_server + 'human', { dir_server + 'humank', ;
    dir_server + 'humankk', ;
    dir_server + 'humano' }, 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2

  find ( Str( mkod_human, 7 ) )
  d1 := human->n_data
  d2 := human->k_data
  last_date := human->n_data
  m1USL_OK := human_->USL_OK
  m1PROFIL := human_->PROFIL
  mdiagnoz := diag_to_array(, , , , .t. )
  If Len( mdiagnoz ) == 0
    mdiagnoz := { Space( 6 ) }
  Endif
  human_kod_diag := AllTrim( mdiagnoz[ 1 ] )
  vidPom := human_->VIDPOM
  ad_cr := Lower( AllTrim( human_2->PC3 ) )
  mvozrast := count_years( human->DATE_R, d2 )

  p_cel := get_idpc_from_v025_by_number( human_->povod )

  If eq_any( human_kod_diag, 'U07.1', 'U07.2' ) .and. mvozrast >= 18 .and. !check_diag_pregant() .and. empty(human_->DATE_R2)
    If ( M1USL_OK == USL_OK_HOSPITAL ) .and. ( d2 >= 0d20220101 )
      retFl := ( M1PROFIL != 158 ) .and. ( vidPom != 32 ) .and. ( ad_cr != 'stt5' )
    Elseif ( M1USL_OK == USL_OK_POLYCLINIC ) .and. ( d2 >= 0d20220401 )
      retFl := ( M1PROFIL != 158 ) .and. ( vidPom != 32 ) .and. ( p_cel == '3.0' )
    Endif
  Endif

  HUMAN_2->( dbCloseArea() )
  HUMAN_->( dbCloseArea() )
  HUMAN->( dbCloseArea() )
  Return retFl


// 08.04.22 ввода лекарственных препаратов
Function oms_sluch_lek_pr( mkod_human, mkod_kartotek, fl_edit )

  // mkod_human - код по БД human
  // mkod_kartotek - код по БД kartotek
  Local aDbf, buf := SaveScreen(), l_color, fl_found
  Local mtitle, tmp_color := SetColor( color1 )
  Local nBegin

  Private mSeverity, m1Severity := 0

  Default fl_edit To .f.

  g_use( dir_server + 'human_u', { dir_server + 'human_u', ;
    dir_server + 'human_uk', ;
    dir_server + 'human_ud', ;
    dir_server + 'human_uv', ;
    dir_server + 'human_ua' }, 'HU' )
  g_use( dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU' )

  g_use( dir_server + 'human_2', , 'HUMAN_2' )
  g_use( dir_server + 'human_', , 'HUMAN_' )
  g_use( dir_server + 'human', { dir_server + 'humank', ;
    dir_server + 'humankk', ;
    dir_server + 'humano' }, 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2

  find ( Str( mkod_human, 7 ) ) // встанем на лист учета

  g_use( dir_server + 'human_lek_pr', dir_server + 'human_lek_pr', 'LEK_PR' )

  adbf := { ;
    { 'KOD_HUM',    'N',   7,  0 }, ; // код листа учёта по файлу 'human'
    { 'DATE_INJ',   'D',   8,  0 }, ; // Дата введения лекарственного препарата
    { 'SEVERITY',   'N',   5,  0 }, ; // код тяжести течения заболевания по справочнику _mo_severity.dbf
    { 'SCHEME',     'C',  10,  0 }, ; // схема лечения пациента V030
    { 'SCHEDRUG',   'C',  10,  0 }, ; // сочетание схемы лечения и группы препаратов V032
    { 'REGNUM',     'C',   6,  0 }, ; // лекарственного препарата
    { 'ED_IZM',     'N',   3,  0 }, ; // Единица измерения дозы лекарственного препарата
    { 'DOZE',       'N',   8,  2 }, ; // Доза введения лекарственного препарата
    { 'METHOD',     'N',   3,  0 }, ; // Путь введения лекарственного препарата
    { 'COL_INJ',    'N',   5,  0 }, ; // Количество введений в течениедня, указанного в DATA_INJ
    { 'COD_MARK',   'C', 100,  0 }, ; // Код маркировки лекарственного препарата
    { 'NUMBER',     'N',   3,  0 }, ; // счетчик строк
    { 'REC_N',      'N',   8,  0 };  // номер записи в файле human_lek_pr.dbf
  }
 dbCreate( 'mem:lek_pr', adbf, , .t., 'TMP' )

  Select LEK_PR
  find ( Str( mkod_human, 7 ) )
  If Found()
    Do While LEK_PR->KOD_HUM == mkod_human .and. !Eof()
      Select TMP
      Append Blank
      tmp->NUMBER   := tmp->( RecNo() )
      tmp->KOD_HUM  := LEK_PR->KOD_HUM
      tmp->DATE_INJ := LEK_PR->DATE_INJ
      tmp->SEVERITY := LEK_PR->SEVERITY
      tmp->SCHEME   := LEK_PR->CODE_SH
      tmp->SCHEDRUG := LEK_PR->SCHEDRUG
      tmp->REGNUM   := LEK_PR->REGNUM
      tmp->ED_IZM   := LEK_PR->ED_IZM
      tmp->DOZE     := LEK_PR->DOSE_INJ
      tmp->METHOD   := LEK_PR->METHOD_I
      tmp->COL_INJ  := LEK_PR->COL_INJ
      // tmp->COD_MARK := LEK_PR->COD_MARK
      tmp->REC_N    :=  LEK_PR->( RecNo() )
      LEK_PR->( dbSkip() )
    Enddo
  Endif
  fl_found := ( tmp->( LastRec() ) > 0 )
  Index On DToS( DATE_INJ ) Tag LEK_PR

  cls
  pr_1_str( 'Лекарственные препараты < ' + fio_plus_novor() + ' >' )
  @ 1, 50 Say PadL( 'Лист учета № ' + lstr( mkod_human ), 29 ) Color color14
  l_color := 'W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B'

  SetColor( color1 )

  nBegin := 3

  If fl_found
    tmp->( dbGoTop() )
    Keyboard Chr( K_RIGHT )
  Else
    Keyboard Chr( K_INS )
  Endif

  mtitle := f_srok_lech( human->n_data, human->k_data, human_->usl_ok )
  alpha_browse( nBegin, 0, MaxRow() -2, 79, 'f_oms_sluch_lek_pr', color1, mtitle, col_tit_popup, ;
    .f., .t., , 'f1oms_sluch_lek_pr', 'f2oms_sluch_lek_pr', , ;
    { '═', '░', '═', l_color, .t., 180 } )

  LEK_PR->( dbCloseArea() )
  TMP->( dbCloseArea() )
  dbDrop( 'mem:lek_pr' )  /* освободим память */
  hb_vfErase( 'mem:lek_pr.ntx' )  /* освободим память от индексного файла */

  HUMAN_2->( dbCloseArea() )
  HUMAN_->( dbCloseArea() )
  HUMAN->( dbCloseArea() )
  HU->( dbCloseArea() )
  MOHU->( dbCloseArea() )

  SetColor( tmp_color )
  RestScreen( buf )
  verify_oms_sluch( mkod_human )
  Return Nil

// 08.01.22
Function f_oms_sluch_lek_pr( oBrow )

  Local oColumn, blk_color

  oColumn := TBColumnNew( ' Дата;инекц', ;
    {|| Left( DToC( tmp->DATE_INJ ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Тяже-; сть ', ;
    {|| iif( tmp->SEVERITY == 0, Space( 5 ), PadR( ret_severity_name( tmp->SEVERITY ), 5 ) ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '  Тип препарата   ', ;
    {|| iif( Empty( tmp->SCHEDRUG ), Space( 18 ), PadR( ret_schema_v032( tmp->SCHEDRUG ), 18 ) ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '     Препарат    ', ;
    {|| iif( Empty( tmp->REGNUM ), Space( 17 ), PadR( get_lek_pr_by_id( tmp->REGNUM ), 17 ) ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' Доза', {|| Str( tmp->DOZE, 6, 2 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' Единица; измер-я', ;
    {|| iif( tmp->ED_IZM == 0, Space( 8 ), PadR( ret_ed_izm( tmp->ED_IZM ), 8 ) ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '  Способ; введения ', ;
    {|| iif( tmp->METHOD == 0, Space( 10 ), PadR( ret_meth_method_inj( tmp->METHOD ), 10 ) ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Кол', {|| Str( tmp->COL_INJ, 3, 0 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )

  status_key( '^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление' )
  Return Nil

// 06.01.22
Function f1oms_sluch_lek_pr()

  Local nRow := Row(), nCol := Col()

  Return Nil

// 08.04.22
Function add_lek_pr( dateInjection, nKey )

  If ValType( dateInjection ) == 'C'
    dateInjection := CToD( dateInjection )
  Endif

  Select LEK_PR
  If nKey == K_INS  // при добавлении лекарственного препарата
    addrec( 7 )
    Select tmp
    Append Blank
    tmp->NUMBER       := tmp->( RecNo() )
  Elseif nKey == K_ENTER    // при редатировании лекарственного препарата
    Goto ( tmp->REC_N )
    g_rlock( forever )
    Select TMP
    Goto ( number )
  Endif

  tmp->REC_N        := LEK_PR->( RecNo() )
  tmp->KOD_HUM      := HUMAN->KOD
  tmp->DATE_INJ     := dateInjection
  tmp->SEVERITY     := m1SEVERITY
  tmp->SCHEME       := m1SCHEME
  tmp->SCHEDRUG     := m1SCHEDRUG
  tmp->REGNUM       := m1REGNUM
  If ! Empty( m1REGNUM )
    tmp->ED_IZM       := m1UNITCODE
    tmp->DOZE         := mDOZE
    tmp->METHOD       := m1METHOD
    tmp->COL_INJ      := mKOLVO
  Endif
  // tmp->COD_MARK     := LEK_PR->COD_MARK
  Select LEK_PR
  LEK_PR->KOD_HUM     := HUMAN->KOD
  LEK_PR->DATE_INJ    := dateInjection
  LEK_PR->SEVERITY    := m1SEVERITY
  LEK_PR->CODE_SH     := m1SCHEME
  LEK_PR->SCHEDRUG    := m1SCHEDRUG
  LEK_PR->REGNUM      := m1REGNUM
  If ! Empty( m1REGNUM )
    LEK_PR->ED_IZM      := m1UNITCODE
    LEK_PR->DOSE_INJ    := mDOZE
    LEK_PR->METHOD_I    := m1METHOD
    LEK_PR->COL_INJ     := mKOLVO
  Endif
  Unlock
  // LEK_PR->COD_MARK
  Select tmp
  Return Nil

// 18.10.22
Function f2oms_sluch_lek_pr( nKey, oBrow )

  Local flag := -1, buf := SaveScreen(), k_read := 0, count_edit := 0
  Local r1, ix, number
  Local last_date := human->n_data
  Local flMany := .f.
  Local arr_dni, row, i

  Do Case
  Case nKey == K_F9
  Case nKey == K_F10
  Case nKey == K_INS .or. ( nKey == K_ENTER .and. tmp->KOD_HUM > 0 )
    Private mMNN := .f.
    Private arr_lek_pr := {}
    Private m1date_u1
    Private mdate_u1 := iif( nKey == K_INS, last_date, tmp->DATE_INJ )  // для совместимости с f5editkusl
    Private m1SEVERITY := iif( nKey == K_INS, 0, tmp->SEVERITY ), mSEVERITY
    Private m1SCHEME := iif( nKey == K_INS, '', tmp->SCHEME ), mSCHEME
    Private m1SCHEDRUG := iif( nKey == K_INS, '', tmp->SCHEDRUG ), mSCHEDRUG
    Private m1UNITCODE := iif( nKey == K_INS, 0, tmp->ED_IZM ), mUNITCODE
    Private m1METHOD := iif( nKey == K_INS, 0, tmp->METHOD ), mMETHOD
    Private m1REGNUM := iif( nKey == K_INS, '', tmp->REGNUM ), mREGNUM
    Private mDOZE :=  iif( nKey == K_INS, 0.0, tmp->DOZE )
    Private mKOLVO :=  iif( nKey == K_INS, 0, tmp->COL_INJ )
    Private tmp_V034 := create_classif_ffoms( 2, 'V034' ) // UNITCODE
    Private tmp_MethodINJ := create_classif_ffoms( 2, 'MethodINJ' ) // METHOD

    Private mdate_end_per := mdate_u1      // human->k_data
    Private arrDateUslug

    number :=  iif( nKey == K_INS, 0, tmp->NUMBER )

    If human_->USL_OK == USL_OK_POLYCLINIC
      arrDateUslug := collect_date_uslugi()
      If !Empty( mdate_u1 )
        If ( i := AScan( arrDateUslug, {| x| x[ 1 ] == DToC( mdate_u1 ) } ) ) > 0
          m1date_u1 := arrDateUslug[ i, 2 ]
          mdate_u1 :=  arrDateUslug[ i, 1 ]
        Endif
      Endif
    Endif

    mUNITCODE := Space( iif( mem_n_V034 == 0, 15, 30 ) )
    mMETHOD   := Space( 30 )
    mSCHEDRUG := Space( 42 )
    mREGNUM   := Space( 30 )
    If nKey == K_ENTER
      mSEVERITY := inieditspr( A__MENUVERT, get_severity(), m1SEVERITY )
      mSCHEME := ret_schema_v030( m1SCHEME )
      mSCHEDRUG := PadR( ret_schema_v032( m1SCHEDRUG ), 42 )
      mREGNUM := PadR( get_lek_pr_by_id( m1REGNUM ), 30 )
      mUNITCODE := PadR( inieditspr( A__MENUVERT, get_ed_izm(), m1UNITCODE ), iif( mem_n_V034 == 0, 15, 30 ) )
      mMETHOD := PadR( inieditspr( A__MENUVERT, getmethodinj(), m1METHOD ), 30 )
    Endif

    r1 := 13
    box_shadow( r1, 0, MaxRow() -1, 79, color8, ;
      iif( nKey == K_INS, 'Добавление нового препарата', ;
      'Редактирование препарата' ), iif( yes_color, 'RB+/B', 'W/N' ) )
    Do While .t.
      SetColor( cDataCGet )
      ix := 1

      If ( nKey == K_ENTER .or. nKey == K_INS ) .and. human_->USL_OK == USL_OK_POLYCLINIC
        @ r1 + ix, 2 Say 'Дата назначения препарата' Get mdate_u1 ;
          reader {| x| menu_reader( x, arrDateUslug, A__MENUVERT, , , .f. ) } ;
          valid {| g | f5editpreparat( g, nKey, 2, 1 ) }
      Elseif nKey == K_ENTER .and. human_->USL_OK == USL_OK_HOSPITAL
        @ r1 + ix, 2 Say 'Дата введения препарата' Get mdate_u1 ;
          valid {| g | f5editpreparat( g, nKey, 2, 1 ) }
      Elseif nKey == K_INS .and. human_->USL_OK == USL_OK_HOSPITAL
        @ r1 + ix, 2 Say 'Начало введения препарата' Get mdate_u1 ;
          valid {| g | f5editpreparat( g, nKey, 2, 1 ) }
        @ r1 + ix, Col() Say ', окончание введения препарата' Get mdate_end_per ;
          valid {| g | f5editpreparat( g, nKey, 2, 4 ) }
      Endif

      ++ix
      @ r1 + ix, 2 Say 'Степень тяжести состояния' Get mSEVERITY ;
        reader {| x| menu_reader( x, get_severity(), A__MENUVERT,,, .f. ) } ;
        valid {| g | f5editpreparat( g, nKey, 2, 6 ) }

      ++ix
      @ r1 + ix, 2 Say 'Схема лечения' Get mSCHEME ;
        reader {| x| menu_reader( x, get_schemas_lech( m1Severity, mdate_u1 ), A__MENUVERT,,, .f. ) } ;
        valid {| g | f5editpreparat( g, nKey, 2, 3 ) }

      ++ix
      @ r1 + ix, 2 Say 'Сочетание схемы лечения препаратам' Get mSCHEDRUG ;
        reader {| x| menu_reader( x, get_group_by_schema_lech( m1SCHEME, mdate_u1 ), A__MENUVERT,,, .f. ) } ;
        valid {| g | f5editpreparat( g, nKey, 2, 2 ) }

      ++ix
      @ r1 + ix, 2 Say 'Препарат' Get mREGNUM ;
        reader {| x| menu_reader( x, arr_lek_pr, A__MENUVERT,,, .f. ) } ;
        valid {| g | f5editpreparat( g, nKey, 2, 5 ) } ;
        When mMNN

      ++ix
      @ r1 + ix, 2 Say 'Доза' Get mDOZE Picture '99999.99' ;
        valid {|| mDOZE != 0 } ;
        When mMNN

      ++ix
      @ r1 + ix, 2 Say 'Единица измерения' Get mUNITCODE ;
        reader {| x| menu_reader( x, tmp_V034, A__MENUVERT,,, .f. ) } ;
        valid {|| mUNITCODE := PadR( mUNITCODE, iif( mem_n_V034 == 0, 15, 30 ) ), m1UNITCODE != 0 } ;
        When mMNN

      ++ix
      @ r1 + ix, 2 Say 'Способ введения' Get mMETHOD ;
        reader {| x| menu_reader( x, tmp_MethodINJ, A__MENUVERT,,, .f. ) } ;
        valid {|| mMETHOD := PadR( mMETHOD, 30 ), m1METHOD != 0 } ;
        When mMNN

      ++ix
      @ r1 + ix, 2 Say 'Количество введений' Get mKOLVO Picture '99' ;
        valid {|| mKOLVO != 0 } ;
        When mMNN

      status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи' )
      count_edit := myread( , , ++k_read )
      If LastKey() != K_ESC
        // обработка и выход
        If nKey == K_INS    // добавление
          flMany := ( mdate_end_per > mdate_u1 )
          If flMany
            // добавим пакетом лекарственные препараты
            If ( arr_dni := select_arr_days( mdate_u1, mdate_end_per ) ) != NIL
              For Each row in arr_dni
                add_lek_pr( row[ 2 ], nKey )
                last_date := Max( tmp->DATE_INJ, last_date )
              Next
            Endif
          Else
            add_lek_pr( mdate_u1, nKey )
            last_date := Max( tmp->DATE_INJ, last_date )
          Endif
        Elseif nKey == K_ENTER  // редактирование
          add_lek_pr( mdate_u1, nKey )
          last_date := Max( tmp->DATE_INJ, last_date )
        Endif
        Select TMP
        oBrow:gotop()
        flag := 0
        Exit
      Elseif LastKey() == K_ESC
        Exit
      Endif
    Enddo

  Case nKey == K_DEL .and. tmp->KOD_HUM > 0 .and. f_esc_enter( 2 )
    If tmp->rec_n != 0
      Select LEK_PR
      Goto ( tmp->rec_n )
      deleterec( .t. )  // очистка записи с пометкой на удаление
      Select TMP
    Endif
    deleterec( .t. )  // с пометкой на удаление
    oBrow:gotop()
    Go Top
    If Eof()
      Keyboard Chr( K_INS )
    Endif
    flag := 0
  Otherwise
    Keyboard ''
  Endcase

  RestScreen( buf )
  Return flag

// 19.12.24 функция для when и valid при вводе услуг в лист учёта
Function f5editpreparat( get, nKey, when_valid, k )

  Local fl := .t., arr, row
  Local arr_lek_pr_schema := {} //, tmpSelect
  Local h_arr_N020 := loadn020(), key, t_arr

  If when_valid == 1    // when
    If k == 1     // Дата оказания услуги
    Elseif k == 2 // Сочетание схемы лечения препаратам
    Elseif k == 3 // схема лечения
    Elseif k == 4 // дата окончания периода
    Endif
  Else  // valid
    If k == 1     // Дата оказания услуги
      If ValType( mdate_u1 ) == 'C'
        mdate_u1 := CToD( mdate_u1 )
      Endif
      If !emptyany( human->n_data, mdate_u1 ) .and. mdate_u1 < human->n_data
        fl := func_error( 4, 'Введенная дата меньше даты начала лечения!' )
      Elseif !emptyany( human->k_data, mdate_u1 ) .and. mdate_u1 > human->k_data
        fl := func_error( 4, 'Введенная дата больше даты окончания лечения!' )
      Endif
      If nKey == K_ENTER
      Elseif nKey == K_INS
        If mdate_u1 > mdate_end_per
          mdate_end_per := mdate_u1
          update_get( 'mdate_end_per' )
        Endif
      Endif
    Elseif k == 2 // Сочетание схемы лечения препаратам
      If Empty( get:buffer )
        Return .f.
      Endif
      If AllTrim( get:buffer ) != mSCHEDRUG
        // очистим все
        m1UNITCODE := 0
        mUNITCODE  := Space( iif( mem_n_V034 == 0, 15, 30 ) )
        //
        mMETHOD    := Space( 30 )
        m1METHOD   := 0
        //
        m1REGNUM   := ''
        mREGNUM    := Space( 30 )
        //
        mDOZE      := 0.0
        mKOLVO     := 0.0
        update_get( 'mUNITCODE' )
        update_get( 'mMETHOD' )
        update_get( 'mREGNUM' )
        update_get( 'mDOZE' )
        update_get( 'mKOLVO' )
      Endif
      mSCHEDRUG := AllTrim( mSCHEDRUG )
      If ( arr := get_group_prep_by_kod( SubStr( m1SCHEDRUG, Len( m1SCHEDRUG ) ), mdate_u1 ) ) != nil
        mMNN := iif( arr[ 3 ] == 1, .t., .f. )
        If mMNN
          arr_lek_pr_schema := get_lek_preparat_by_schema_lech( 'covid', m1SCHEDRUG, mdate_u1 )
          If Len( arr_lek_pr_schema ) != 0
//            tmpSelect := Select()
//            r_use( dir_exe() + '_mo_N020', cur_dir + '_mo_N020', 'N20' )
            arr_lek_pr := {}
            For Each row in arr_lek_pr_schema
              key := row[ 2 ]
              if hb_hHaskey( h_arr_N020, key )
                t_arr := h_arr_N020[ key ]
                AAdd( arr_lek_pr, { t_arr[ 2 ], t_arr[ 1 ], t_arr[ 3 ], t_arr[ 4 ] } )
              endif
//              find ( row[ 2 ] )
//              If Found()
//                AAdd( arr_lek_pr, { N20->MNN, N20->ID_LEKP, N20->DATEBEG, N20->DATEEND } )
//              Endif
            Next
//            N20->( dbCloseArea() )
//            Select( tmpSelect )
          Endif
        Else
          arr_lek_pr := {}
          func_error( 1, 'У Данной схемы НЕТ МЕДИКАМЕНТОВ!' )
        Endif
        arr_lek_pr_schema := {}
      Endif
    Elseif k == 3 // схема лечения
      If Empty( get:buffer )
        Return .f.
      Endif
      If AllTrim( get:buffer ) != mSCHEME
        // очистим все
        m1UNITCODE := 0
        mUNITCODE  := Space( iif( mem_n_V034 == 0, 15, 30 ) )
        //
        mMETHOD    := Space( 30 )
        m1METHOD   := 0
        //
        m1SCHEDRUG := ''
        mSCHEDRUG  := Space( 42 )
        //
        m1REGNUM   := ''
        mREGNUM    := Space( 30 )
        //
        mDOZE      := 0.0
        mKOLVO     := 0.0
        update_get( 'mUNITCODE' )
        update_get( 'mMETHOD' )
        update_get( 'mSCHEDRUG' )
        update_get( 'mREGNUM' )
        update_get( 'mDOZE' )
        update_get( 'mKOLVO' )
      Endif
    Elseif k == 4     // Дата окончания периода
      If !emptyany( human->n_data, mdate_end_per ) .and. mdate_end_per < human->n_data
        fl := func_error( 4, 'Введенная дата меньше даты начала лечения!' )
      Elseif !emptyany( human->k_data, mdate_end_per ) .and. mdate_end_per > human->k_data
        fl := func_error( 4, 'Введенная дата больше даты окончания лечения!' )
      Endif
    Elseif k == 5 // препарат
      If Empty( get:buffer )
        Return .f.
      Endif
      If AllTrim( get:buffer ) != mREGNUM
        // очистим все
        m1UNITCODE := 0
        mUNITCODE  := Space( iif( mem_n_V034 == 0, 15, 30 ) )
        mMETHOD    := Space( 30 )
        m1METHOD   := 0
        mDOZE      := 0.0
        mKOLVO     := 0.0
        update_get( 'mUNITCODE' )
        update_get( 'mMETHOD' )
        update_get( 'mDOZE' )
        update_get( 'mKOLVO' )
      Endif
    Elseif k == 6 // Степень тяжести состояния
      If Empty( get:buffer )
        Return .f.
      Endif
      If AllTrim( get:buffer ) != mSEVERITY
        // очистим все
        mSCHEME   := Space( 10 )
        m1SCHEME  := ''
        //
        m1UNITCODE := 0
        mUNITCODE  := Space( iif( mem_n_V034 == 0, 15, 30 ) )
        //
        mMETHOD    := Space( 30 )
        m1METHOD   := 0
        //
        m1SCHEDRUG := ''
        mSCHEDRUG  := Space( 42 )
        //
        m1REGNUM   := ''
        mREGNUM    := Space( 30 )
        //
        mDOZE      := 0.0
        mKOLVO     := 0.0
        update_get( 'mUNITCODE' )
        update_get( 'mMETHOD' )
        update_get( 'mSCHEDRUG' )
        update_get( 'mREGNUM' )
        update_get( 'mDOZE' )
        update_get( 'mKOLVO' )
        update_get( 'mSCHEME' )
      Endif
    Endif
  Endif
  Return fl

// 21.12.24
function collect_lek_pr_onko( mkod_human )

  Local retArr := {}
  Local existAlias := .f.
  Local oldSelect := Select()
  Local lekAlias
  Local cAlias := 'LEK_PR'

  lekAlias := Select( cAlias )
  If lekAlias == 0
//    r_use( dir_server + 'human_lek_pr', dir_server + 'human_lek_pr', cAlias )
    r_use( dir_server + 'mo_onkle', dir_server + 'mo_onkle',  cAlias ) // Сведения о применённых лекарственных препаратах
  Endif
  dbSelectArea( cAlias )
  ( cAlias )->( dbSeek( Str( mkod_human, 7 ) ) )
  If ( cAlias )->( Found() )
//    Do While ( cAlias )->KOD_HUM == mkod_human .and. !Eof()
    Do While ( cAlias )->kod == mkod_human .and. !Eof()
        AAdd( retArr, { ( cAlias )->DATE_INJ, ( cAlias )->CODE_SH, ( cAlias )->REGNUM, 0, ;
        0, 0, 0, '' } )
      ( cAlias )->( dbSkip() )

    Enddo
  Endif

  Select( oldSelect )
  If lekAlias == 0
    ( cAlias )->( dbCloseArea() )
  Endif
  Return retArr

  // 06.03.22
Function collect_lek_pr( mkod_human )

  Local retArr := {}
  Local existAlias := .f.
  Local oldSelect := Select()
  Local lekAlias
  Local cAlias := 'LEK_PR'

  lekAlias := Select( cAlias )
  If lekAlias == 0
    r_use( dir_server + 'human_lek_pr', dir_server + 'human_lek_pr', cAlias )
  Endif
  dbSelectArea( cAlias )
  ( cAlias )->( dbSeek( Str( mkod_human, 7 ) ) )
  If ( cAlias )->( Found() )
    Do While ( cAlias )->KOD_HUM == mkod_human .and. !Eof()
      AAdd( retArr, { ( cAlias )->DATE_INJ, ( cAlias )->CODE_SH, ( cAlias )->REGNUM, ( cAlias )->ED_IZM, ;
        ( cAlias )->DOSE_INJ, ( cAlias )->METHOD_I, ( cAlias )->COL_INJ, ( cAlias )->SCHEDRUG } )
      ( cAlias )->( dbSkip() )
    Enddo
  Endif

  Select( oldSelect )
  If lekAlias == 0
    ( cAlias )->( dbCloseArea() )
  Endif
  Return retArr

// 10.01.22 функция для when и valid при вводе различных полей
Function check_edit_field( get, when_valid, k )

  Local fl := .t.

  If when_valid == 1    // when
    If k == 1     // Вес пациента в кг
    Elseif k == 2 //
    Elseif k == 3 //
    Endif
  Else  // valid
    If k == 1     // Вес пациента в кг
      If Val( get:buffer ) > 500
        get:varput( get:original )
        fl := func_error( 4, 'Введенный вес не может быть выше 500 кг!' )
      Elseif Val( get:buffer ) < 0
        get:varput( get:original )
        fl := func_error( 4, 'Введенный вес не может быть отрицательным!' )
      Endif
    Elseif k == 2 //
    Elseif k == 3 //
    Endif
  Endif
  Return fl

// 06.01.25
Function get_lek_pr( k, r, c, _crit )

  Local i, j, nrec, t_arr := Array( BR_LEN ), ret := { Space( 10 ), Space( 10 ) }

  Local aN021 := getn021( mk_data ), it, row
  local aN020 := getn020()
  local adbf

  Private arr_lek_pr := {}, yes_crit

  adbf := { ;
    { 'ID_LEKP',    'C',  6, 0 }, ; //
    { 'MNN',        'C', 250, 0 }, ; //
    { 'DATEBEG',    'D',  8, 0 }, ; // Дата начала действия записи
    { 'DATEEND',    'D',  8, 0 };  // Дата окончания действия записи
  }
  _crit := AllTrim( _crit )
 
  dbCreate( 'mem:n020', adbf, , .t., 'N20' )
  for each row in aN020
    N20->( dbAppend() )
    N20->ID_LEKP := row[ 1 ]
    N20->MNN := row[ 2 ]
    N20->DATEBEG := row[ 3 ]
    N20->DATEEND := row[ 4 ]
  next
  Index On Upper( mnn ) Tag n020n
  Index On ID_LEKP Tag n020
  Set Filter To between_date( datebeg, dateend, mk_data )

  dbCreate( cur_dir + 'tmp', { { 'id_lekp', 'C', 6, 0 }, ;
    { 'mnn', 'C', 70, 0 }, ;
    { 'kol', 'N', 3, 0 } } )
  Use ( cur_dir + 'tmp' ) new
  Index On id_lekp to ( cur_dir + 'tmp' )
//  r_use( dir_exe() + '_mo_N020', { cur_dir + '_mo_N020', cur_dir + '_mo_N020n' }, 'N20' )
//  Set Filter To between_date( datebeg, dateend, mk_data )

  If ( it := AScan( aN021, {| x| x[ 2 ] + x[ 3 ] == _crit } ) ) == 0
    yes_crit := .t.
  Endif

  Use ( cur_dir + 'tmp_onkle' ) New Alias TMPLE
  Index On REGNUM + DToS( DATE_INJ ) to ( cur_dir + 'tmp_onkle' ) UNIQUE

  If yes_crit // по данному критерию есть препараты в схеме
    For Each row in aN021
//      If AllTrim( row[ 2 ] ) == AllTrim( _crit )
      If row[ 2 ] == _crit
        Select TMP
        Append Blank
        tmp->id_lekp := row[ 3 ]
        AAdd( arr_lek_pr, { tmp->id_lekp, tmp->( RecNo() ), {} } )
        i := Len( arr_lek_pr )
        Select N20
        find ( row[ 3 ] )
        If Found()
          tmp->mnn := n20->mnn
        Else
          tmp->mnn := 'Препарат ' + row[ 3 ] + ' не найден в справочнике N020'
        Endif
        Select TMPLE
        find ( tmp->id_lekp )
        Do While tmp->id_lekp == tmple->REGNUM .and. !Eof()
          AAdd( arr_lek_pr[ i, 3 ], tmple->DATE_INJ )
          Skip
        Enddo
        tmp->kol := Len( arr_lek_pr[ i, 3 ] )
      Endif
    Next
  Else // по данному критерию нет препаратов в схеме
    Select TMPLE
    Go Top
    Do While !Eof()
      Select N20
      find ( tmple->REGNUM )
      If Found() // найден препарат в справочнике
        Select TMP
        find ( tmple->REGNUM )
        If !Found()
          Append Blank
          tmp->id_lekp := tmple->REGNUM
          tmp->mnn := n20->mnn
        Endif
        tmp->kol++
        If ( i := AScan( arr_lek_pr, {| x| x[ 2 ] == tmp->( RecNo() ) } ) ) == 0
          AAdd( arr_lek_pr, { tmp->id_lekp, tmp->( RecNo() ), {} } )
          i := Len( arr_lek_pr )
        Endif
        AAdd( arr_lek_pr[ i, 3 ], tmple->DATE_INJ )
      Endif
      Select TMPLE
      Skip
    Enddo
  Endif
  Select TMPLE
  Set Index To
  nrec := tmp->( LastRec() )
  If yes_crit
    t_arr[ BR_TOP ] := r - nrec -4
  Else//
    t_arr[ BR_TOP ] := r -4 -4
  Endif
  If t_arr[ BR_TOP ] < 2
    t_arr[ BR_TOP ] := 2
  Endif
  t_arr[ BR_BOTTOM ] := r -1
  t_arr[ BR_LEFT ]  := 1
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_COLOR ] := color5
  t_arr[ BR_TITUL ] := 'Редактирование дат введения препаратов для схемы ' + AllTrim( _crit )
  t_arr[ BR_TITUL_COLOR ] := 'BG+/GR'
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', , .t. }
  t_arr[ BR_COLUMN ] := { { ' Наименование препарата', {|| tmp->mnn } }, ;
    { ' Дни', {|| tmp->kol } } }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_get_lek_pr( nk, ob, 'edit', r ) }
  s := '^<Esc>^ - выход;  ^<Enter>^ - редактирование дат'
  If !yes_crit
    s += '; ^<Ins>^ - добавить препарат;  ^<Del>^ - удалить препарат'
  Endif
  t_arr[ BR_STAT_MSG ] := {|| status_key( s ) }
  Select TMP
  Index On Upper( mnn ) to ( cur_dir + 'tmp' )
  Go Top
  If Eof() .and. !yes_crit
    Keyboard Chr( K_INS )
  Endif
  edit_browse( t_arr )
  //
  nrec := tmp->( LastRec() )
  Select TMPLE
  Zap
  For i := 1 To nrec
    If Len( arr_lek_pr ) >= i
      For j := 1 To Len( arr_lek_pr[ i, 3 ] )
        Select TMPLE
        Append Blank
        tmple->REGNUM   := arr_lek_pr[ i, 1 ]
        tmple->CODE_SH  := _crit
        tmple->DATE_INJ := arr_lek_pr[ i, 3, j ]
      Next
    Endif
  Next
  Index On DToS( DATE_INJ ) to ( cur_dir + 'tmp_onkle' ) UNIQUE
  ndn := 0
  dbEval( {|| ++ndn } )
  ret[ 1 ] := ret[ 2 ] := PadR( 'препаратов - ' + lstr( nrec ) + ', дней приёма - ' + lstr( ndn ), 53 )
  //
  tmp->( dbCloseArea() )
  tmple->( dbCloseArea() )
  n20->( dbCloseArea() )
  dbDrop( 'mem:n020' )  /* освободим память */
  hb_vfErase( 'mem:n020n.ntx' )  /* освободим память от индексного файла */
  hb_vfErase( 'mem:n020.ntx' )  /* освободим память от индексного файла */

  Return ret

// 31.01.19 выбор нескольких дат
Function f1_get_lek_pr( nKey, oBrow, regim, get_row )

  Local mlen, t_mas := {}, buf := SaveScreen(), i, j, d, tmp_color := SetColor(), ;
    k, n, r1, r2, top_bottom, r := Row(), ret := -1

  If regim == 'edit'
    If nKey == K_ENTER .and. tmp->( LastRec() ) > 0
      If ( i := AScan( arr_lek_pr, {| x| x[ 2 ] == tmp->( RecNo() ) } ) ) == 0
        func_error( 4, 'Непонятная ошибка!' )
      Else
        For d := mn_data To mk_data
          AAdd( t_mas, iif( AScan( arr_lek_pr[ i, 3 ], d ) > 0, ' * ', '   ' ) + full_date( d ) )
        Next
        mlen := Len( t_mas )
        status_key( '^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins,+,->^ - смена выбора даты' )
        top_bottom := ( r < MaxRow() / 2 )
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
        If Popup( r1, 60, r2, 77, t_mas, i, color0, .t., 'fmenu_reader', , 'Даты введения', 'B/BG' ) > 0
          arr_lek_pr[ i, 3 ] := {}
          For j := 1 To mlen
            If '*' == SubStr( t_mas[ j ], 2, 1 )
              AAdd( arr_lek_pr[ i, 3 ], CToD( SubStr( t_mas[ j ], 4 ) ) )
            Endif
          Next
          tmp->kol := Len( arr_lek_pr[ i, 3 ] )
        Endif
      Endif
    Elseif nKey == K_INS .and. !yes_crit
      If ( k := f2_get_lek_pr( get_row ) ) != NIL
        Select TMP
        Go Top
        Locate For id_lekp == k[ 1 ]
        If Found()
          func_error( 2, 'Данный препарат уже добавлен!' )
        Else
          addrecn()
          tmp->id_lekp := k[ 1 ]
          tmp->mnn := k[ 2 ]
          AAdd( arr_lek_pr, { tmp->id_lekp, tmp->( RecNo() ), {} } )
        Endif
        ret := 0
      Endif
      Select TMP
    Elseif nKey == K_DEL .and. !yes_crit .and. f_esc_enter( 2 )
      If ( i := AScan( arr_lek_pr, {| x| x[ 2 ] == tmp->( RecNo() ) } ) ) > 0
        del_array( arr_lek_pr, i )
      Endif
      deleterec()
      Go Top
      oBrow:gotop()
      ret := 1
    Endif
  Endif
  RestScreen( buf )
  SetColor( tmp_color )
  Return ret

// 31.01.19
Function f2_get_lek_pr( r )

  Static srec := 0
  Local ret, t_arr[ BR_LEN ]

  t_arr[ BR_TOP ] := 3
  t_arr[ BR_BOTTOM ] := r -1
  t_arr[ BR_LEFT ] := 4
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := 'Добавление лекарственного препарата'
  t_arr[ BR_TITUL_COLOR ] := 'BG+/GR'
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N', .f., 72 }
  t_arr[ BR_COLUMN ] := { { Center( 'Наименование', 72 ), {|| Left( n20->mnn, 70 ) } } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f3_get_lek_pr( nk, ob ) }
  t_arr[ BR_ENTER ] := {|| srec := n20->( RecNo() ), ret := { n20->id_lekp, n20->mnn } }
  //
  Select N20
  Set Order To 2
  If srec > 0
    Goto ( srec )
  Else
    Go Top
  Endif
  edit_browse( t_arr )
  Return ret

// 31.01.19
Function f3_get_lek_pr( nk, ob )

  Local ret := -1, rec

  If nk == K_F2
    If ( ret := f4_get_lek_pr( @rec, ob ) ) == 0
      ob:gotop()
      Goto ( rec )
    Endif
  Endif
  Return ret

// 31.01.19
Function f4_get_lek_pr( ret_rec, obrow )

  Static stmp1 := ''
  Local rec1 := RecNo(), buf := SaveScreen(), tmp_color, ret := -1, j, r1 := pr2 -6, r2 := pr2 -1

  box_shadow( r1, pc1 + 1, r2, pc2 -1, cDataPgDn, 'Поиск по ключу', cDataCSay )
  tmp_color := SetColor( cDataCGet )
  @ r1 + 2, pc1 + 2 Say Center( 'Введите ключевое слово', pc2 - pc1 -3 )
  Do While .t.
    SetColor( cDataCGet )
    tmp := PadR( stmp1, pc2 - pc1 -3 )
    status_key( '^<Esc>^ - отказ от ввода' )
    @ r1 + 3, pc1 + 2 Get tmp Picture '@K@!'
    myread()
    SetColor( color0 )
    If LastKey() == K_ESC .or. Empty( tmp )
      Goto ( rec1 )
    Else
      mywait()
      stmp1 := tmp := AllTrim( tmp )
      Private tmp_mas := {}, tmp_kod := {}, i := 0, t_len, k1 := pr1 + 3, k2 := pr2 -1
      oBrow:gotop()
      Do While !Eof()
        If tmp $ Upper( n20->mnn )
          ++i
          AAdd( tmp_mas, n20->mnn )
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

// 19.12.24 вернуть соответствие кода препарата схеме лечения
Function get_lek_preparat_by_schema_lech( vid_lech, _schemeDrug, ldate )

  Local _arr := {}, row

  vid_lech := alltrim( Lower( vid_lech ) )

  if vid_lech == 'covid'
    For Each row in getv033()
      If ( row[ 1 ] == _schemeDrug ) .and. between_date( row[ 3 ], row[ 4 ], ldate )
        AAdd( _arr, { row[ 1 ], row[ 2 ], row[ 3 ], row[ 4 ] } )
      Endif
    Next
  endif
  Return _arr
