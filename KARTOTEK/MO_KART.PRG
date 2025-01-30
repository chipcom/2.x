// mo_kart.prg - режимы работы с картотекой
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 10.03.13 Работа с картотекой в задаче ОМС
Function oms_kartoteka( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { '~Добавление', ;
      '~Редактирование', ;
      'Дублирующиеся ~записи', ;
      '~Удаление', ;
      'Просмотр / ~печать' }
    mas_msg := { 'Добавление в картотеку информации о больном', ;
      'Редактирование информации из карточки больного', ;
      'Поиск и удаление дублирующихся записей в картотеке', ;
      'Удаление карточки больного из картотеки', ;
      'Просмотр / печать списков по категориям, компаниям, районам, участкам,...' }
    mas_fun := { 'oms_kartoteka(1)', ;
      'oms_kartoteka(2)', ;
      'oms_kartoteka(3)', ;
      'oms_kartoteka(4)', ;
      'oms_kartoteka(5)' }
    If glob_mo[ _MO_IS_UCH ]
      AAdd( mas_pmt, 'Прикреплённое ~население' )
      AAdd( mas_msg, 'Работа с прикреплённым населением' )
      AAdd( mas_fun, 'oms_kartoteka(6)' )
    Endif
    popup_prompt( T_ROW, T_COL + 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 1
    append_kart()
  Case k == 2
    regi_kart()
  Case k == 3
    dubl_zap()
  Case k == 4
    view_kart( 2 )
  Case k == 5
    prn_kartoteka()
  Case k == 6
    pripisnoe_naselenie()
  Endcase
  If Between( k, 1, 9 )
    si1 := k
  Endif

  Return Nil

//
Function regi_kart()

  If ( lkod := polikl1_kart() ) >= 0
    view_kart( 1 )
  Endif

  Return Nil


// добавление в картотеку
Function append_kart()

  Local k := edit_kartotek( 0 )

  If k > 0
    If mem_kodkrt == 2 .and. !( is_uchastok == 1 )
      f_message( { '', ;
        'Регистрационный номер добавленного больного - ' + lstr( k ), '' }, ;
        'W', , , 16 )
      If glob_task == X_REGIST // регистратура
        Keyboard Chr( K_UP ) + Chr( K_ENTER )
      Endif
    Endif
  Endif

  Return Nil


// 03.09.17
Function edit_kartotek( mkod, _top_r, _bot_r, fl_oms, _Human_kod )

  Local ar := getinivar( tmp_ini, { { 'RAB_MESTO', 'kart_polis', '1' } } )

  Private p_edit_kartoteka := .f., p_find_polis := Int( Val( ar[ 1 ] ) )

  mkod := edit_kartotek_( mkod, _top_r, _bot_r, fl_oms, _Human_kod )
  If p_edit_kartoteka
    glob_kartotek := mkod
    p_edit_kartoteka := .f.
    mkod := edit_kartotek_( mkod, _top_r, _bot_r, fl_oms, _Human_kod )
  Endif

  Return mkod

// 30.01.25
Function edit_kartotek_( mkod, _top_r, _bot_r, fl_oms, _Human_kod )

  Static mm_kart_error := { { 'нет замечаний', 0 }, { 'полис недействителен', -8 }, { 'ошибки в реквизитах', -9 } }
  Static mm_invalid := { { 'нет', 0 }, { '1 группа', 1 }, { '2 группа', 2 }, { '3 группа', 3 }, { 'дети-инвалиды', 4 } }
  Static mm_where_kart := { { 'в регистратуре', 0 }, { 'у врача', 1 }, { 'на руках', 2 } }
  Static st_rab_nerab := 0
  Local tmp_color := SetColor(), tmp_help := chm_help_code, buf := SaveScreen(), ;
    i, c, arr, arr1, dolya := 1, lapp_edit, llen, ldec, in_array, out_array, ;
    is_append := ( mkod == 0 ), old_arr_kart, flag_DVN, ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    count_row := 0, title_top, fl_mr_dol := .f., fl_kis := .f.

  Default fl_oms To .f., _Human_kod To 0
  change_attr()
  If !( Type( '_task_263_' ) == 'L' )
    Private _task_263_ := .f.
  Endif
  // Private is_smp := fl_oms .and. ((type('m1usl_ok') == 'N' .and. m1usl_ok == 4) .or. ;
  // (len(glob_otd) > 2 .and. glob_otd[3] == 4))
  Private is_smp := fl_oms .and. ( ( Type( 'm1usl_ok' ) == 'N' .and. m1usl_ok == USL_OK_AMBULANCE ) .or. ;
    ( Len( glob_otd ) > 2 .and. glob_otd[ 3 ] == 4 ) )
  Private M1NOVOR := 0 // определить новое значение и 'скрыть' старое
  Private is_talon := ret_is_talon()
  Private mbukva := ' ', muchast := 0, mkod_vu := 0, mkod_AK := Space( 6 ), ;
    mkart_error, m1kart_error := 0, ;
    MFIO        := Space( 50 ), ; // Ф.И.О. больного
    mfam := Space( 40 ), mim := Space( 40 ), mot := Space( 40 ), ;
    mpol        := 'М', ;
    mdate_r     := BoY( AddMonth( sys_date, -12 * 30 ) ), ;
    MANONIM, M1ANONIM := 0, ;
    MVZROS_REB, M1VZROS_REB := 0, ;
    MADRES      := Space( 50 ), ; // адрес больного
    MMR_DOL     := Space( 50 ), ; // место работы или причина безработности
    MRAB_NERAB, M1RAB_NERAB := st_rab_nerab, ; // 0-работающий, 1 -неработающий
    m1MEST_INOG := 0, newMEST_INOG := 0, ;
    s_prim1     := '', ;
    MVID_UD, ; // вид удостоверения
    M1VID_UD    := 14, ; // 1-18
    mser_ud := Space( 10 ), mnom_ud := Space( 20 ), ;
    MKEMVYD, M1KEMVYD := 0, MKOGDAVYD := CToD( '' ), ; // кем и когда выдан паспорт
    mspolis := Space( 10 ), mnpolis := Space( 20 ), msmo := Space( 5 ), ;
    mnamesmo, m1namesmo, ;
    m1company := 0, mcompany, mm_company, ;
    m1KOMU := 0, MKOMU, M1STR_CRB := 0, ;
    mBEG_POLIS := CToD( '' ), MSROK_POLIS := CToD( '' ), ; // срок действия страхового полиса
    mSTRANA := Space( 10 ), m1strana := '', ;
    mosn_preb, m1osn_preb := 0, ;
    mvidpolis, m1vidpolis := 3, mmesto_r := Space( 100 ), ;
    mgragd, m1gragd, ;
    msnils := Space( 11 ), ;
    m1gorod_selo := 1, mgorod_selo, ;
    mkategor, m1kategor := ATail( stm_kategor )[ 2 ], ;  // т.е. прочие
    mkategor2, m1kategor2 := 0, ;
    mokatog := PadR( AllTrim( okato_umolch ), 11, '0' ), mokatop := Space( 11 ), madresp := Space( 50 ), ;
    m1adres_reg := 1, madres_reg, ;
    m1adres_pre := 1, madres_pre, ;
    mPHONE_H := Space( 11 ), mPHONE_M := Space( 11 ), mPHONE_W := Space( 11 ), ;
    m1KOD_LGOT := Space( 3 ), mKOD_LGOT, ;
    m1PENSIONER := 0, mPENSIONER, ;
    fl_invalid := .f., m1INVALID := 0, mINVALID, mINVALID_ST := 0, ;
    MDATE_INV := CToD( '' ), ; // дата первичного установления инвалидности
    MPRICH_INV := Space( 10 ), M1PRICH_INV := 0, ; // причина первичного установления инвалидности
    mDIAG_INV := Space( 5 ), ;  //
    mBLOOD_G := 0, mBLOOD_R := ' ', mWEIGHT := 0, mHEIGHT := 0, ;
    m1WHERE_KART := 0, mWHERE_KART, rec_inogSMO := 0, ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := Space( 100 ), ;
    MADRES_PRO := Space( 60 ), ; // адрес проживания в Волг.обл.
    MMIGR_KARTA := Space( 20 ), ; // данные миграционной карты
    MDATE_P_G := CToD( '' ), ; // дата пересечения границы
    MDATE_R_M := CToD( '' ), ; // дата регистрации в миграционной службе
    MKOL_PRED := 0, ;
    MFIO_PR1 := Space( 50 ), ;
    M1STATUS_PR1 := 0, ;
    M1IS_UHOD_PR1 := 0, ;
    M1IS_FOOD_PR1 := 0, ;
    MDATE_R_PR1 := CToD( '' ), ;
    MADRES_PR1 := Space( 50 ), ;
    MMR_DOL_PR1 := Space( 50 ), ;
    MPHONE_PR1 := Space( 11 ), ;
    MPASPORT_PR1 := Space( 15 ), ;
    MPOLIS_PR1 := Space( 25 ), ;
    MFIO_PR2 := Space( 50 ), ;
    M1STATUS_PR2 := 0, ;
    MDATE_R_PR2 := CToD( '' ), ;
    MADRES_PR2 := Space( 50 ), ;
    MMR_DOL_PR2 := Space( 50 ), ;
    MPHONE_PR2 := Space( 11 ), ;
    MPASPORT_PR2 := Space( 15 ), ;
    MPOLIS_PR2 := Space( 25 ), ;
    mmo_pr := '', ;
    gl_area := { 1, 0, MaxRow() -1, 79, 0 }
  private m1SVO := 0, mSVO  // социальная категория
  private m1UchastSVO := 0, mUchastSVO  // участник СВО
  //
  If !is_append .and. r_use( dir_server + 'kartote_', , 'KART_' ) ;
      .and. r_use( dir_server + 'kartote2', , 'KART2' ) ;
      .and. r_use( dir_server + 'kartotek', , 'KART' )
    Select KART
    Goto ( mkod )
    in_array := get_field()
    m1kart_error := kart->ZA_SMO
    mFIO        := kart->FIO
    mpol        := kart->pol
    mDATE_R     := kart->DATE_R
    m1VZROS_REB := kart->VZROS_REB
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    msrok_polis := c4tod( kart->srok_polis )
    m1RAB_NERAB := kart->RAB_NERAB
    msnils      := kart->snils
    If kart->MI_GIT == 9
      m1KOMU    := kart->KOMU
      M1STR_CRB := kart->STR_CRB
    Endif
    If kart->MEST_INOG == 8 // т.е. аноним
      If eq_any( glob_task, X_PLATN, X_KASSA ) .and. mem_anonim == 1
        M1ANONIM := 1
      Endif
    Elseif kart->MEST_INOG == 9 // т.е. отдельно занесены Ф.И.О.
      m1MEST_INOG := kart->MEST_INOG
    Endif
    If is_uchastok > 0
      mbukva  := kart->bukva
      muchast := kart->uchast
      mkod_vu := kart->kod_vu
    Endif
    m1UchastSVO := iif( kart->PN1 == 30, 1, 0 )
    m1SVO := val( kart->PC3 )

    Select KART2
    Goto ( mkod )
    If !Eof()
      If is_uchastok == 3
        mkod_AK := Left( kart2->kod_AK, 6 )
      Endif
      If glob_mo[ _MO_IS_UCH ]
        If Left( kart2->PC2, 1 ) == '1'
          mmo_pr := 'По информации из ТФОМС пациент У_М_Е_Р'
        Elseif kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ]
          mmo_pr := 'Прикреплён '
          If !Empty( kart2->pc4 )
            mmo_pr += 'с ' + AllTrim( kart2->pc4 ) + ' '
          Elseif !Empty( kart2->DATE_PR )
            mmo_pr += 'с ' + date_8( kart2->DATE_PR ) + ' '
          Endif
          mmo_pr += 'к нашей МО'
        Else
          s := AllTrim( inieditspr( A__MENUVERT, glob_arr_mo, kart2->mo_pr ) )
          If Empty( s )
            mmo_pr := 'Прикрепление --- неизвестно ---'
          Else
            mmo_pr := ''
            If !Empty( kart2->pc4 )
              mmo_pr += 'с ' + AllTrim( kart2->pc4 ) + ' '
            Elseif !Empty( kart2->DATE_PR )
              mmo_pr += 'с ' + date_8( kart2->DATE_PR ) + ' '
            Endif
            mmo_pr += 'прикреплён к ' + s
          Endif
        Endif
      Endif
    Endif
    Select KART_
    Goto ( mkod )
    m1vidpolis  := kart_->VPOLIS // вид полиса (от 1 до 3);1-старый, 2-врем., 3-новый
    mspolis     := kart_->SPOLIS // серия полиса
    mnpolis     := kart_->NPOLIS // номер полиса
    msmo        := kart_->SMO    // реестровый номер СМО
    mBEG_POLIS  := c4tod( kart_->beg_polis ) // дата начала действия полиса
    m1strana    := kart_->strana // гражданство пациента (страна)
    m1gorod_selo := kart_->gorod_selo // житель?;1-город, 2-село, 3-рабочий поселок
    m1vid_ud    := kart_->vid_ud   // вид удостоверения личности
    mser_ud     := kart_->ser_ud   // серия удостоверения личности
    mnom_ud     := kart_->nom_ud   // номер удостоверения личности
    m1kemvyd    := kart_->kemvyd   // кем выдан документ
    mkogdavyd   := kart_->kogdavyd // когда выдан документ
    m1kategor   := kart_->kategor  // категория пациента
    m1kategor2  := kart_->kategor2 // категория пациента (собственная для МО)
    mmesto_r    := kart_->mesto_r      // место рождения;;
    mokatog     := kart_->okatog       // код места жительства по ОКАТО
    mokatop     := kart_->okatop       // код места пребывания по ОКАТО
    madresp     := kart_->adresp       // адрес места пребывания
    mPHONE_H    := kart_->PHONE_H      // телефон домашний;;
    mPHONE_M    := kart_->PHONE_M      // телефон мобильный;;
    mPHONE_W    := kart_->PHONE_W      // телефон рабочий;;
    m1KOD_LGOT  := kart_->KOD_LGOT     // код льготы про ДЛО;;
    m1PENSIONER := kart_->PENSIONER    // является пенсионером?;0-нет, 1-да;
    m1INVALID   := kart_->INVALID      // инвалидность;0-нет, 1, 2, 3-группа, 4-дети-инвалиды;
    mINVALID_ST := kart_->INVALID_ST   // степень инвалидности;1 или 2;
    mBLOOD_G    := kart_->BLOOD_G      // группа крови;от 1 до 4;
    mBLOOD_R    := kart_->BLOOD_R      // резус-фактор;'+' или '-';
    mWEIGHT     := kart_->WEIGHT       // вес в кг;;
    mHEIGHT     := kart_->HEIGHT       // рост в см;;
    m1WHERE_KART := kart_->WHERE_KART   // где амбулаторная карта;0-в регистратуре, 1-у врача, 2-на руках;
    m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
    //
    arr := retfamimot( 1, .f. )
    mfam := PadR( arr[ 1 ], 40 )
    mim  := PadR( arr[ 2 ], 40 )
    mot  := PadR( arr[ 3 ], 40 )
    //
    If Between( m1invalid, 1, 4 )
      r_use( dir_server + 'kart_inv', , 'INV' )
      Index On Str( kod, 7 ) to ( cur_dir + 'tmp_inv' )
      find ( Str( mkod, 7 ) )
      If ( fl_invalid := Found() )
        MDATE_INV := inv->DATE_INV
        M1PRICH_INV := inv->PRICH_INV
        MPRICH_INV := inieditspr( A__MENUVERT, getprichinv(), M1PRICH_INV )
        mDIAG_INV := inv->DIAG_INV
      Endif
    Endif
    r_use( dir_server + 'k_prim1', dir_server + 'k_prim1', 'K_PRIM1' )
    find ( Str( mkod, 7 ) )
    Do While k_prim1->kod == mkod .and. !Eof()
      s_prim1 += RTrim( k_prim1->name ) + hb_eol()
      Skip
    Enddo
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 1, @rec_inogSMO, .t. )
    Elseif Left( msmo, 2 ) == '34'
      // Волгоградская область
    Elseif !Empty( msmo )
      m1ismo := msmo ; msmo := '34'
    Endif
    r_use( dir_server + 'mo_kinos', dir_server + 'mo_kinos', 'KIS' )
    find ( Str( mkod, 7 ) )
    If Found()
      fl_kis := .t.
      m1osn_preb  := kis->osn_preb   // основание пребывания в РФ
      MADRES_PRO  := kis->ADRES_PRO  // адрес проживания в Волг.обл.
      MMIGR_KARTA := kis->MIGR_KARTA // данные миграционной карты
      MDATE_P_G   := kis->DATE_P_G   // дата пересечения границы
      MDATE_R_M   := kis->DATE_R_M   // дата регистрации в миграционной службе
    Endif
    r_use( dir_server + 'mo_kpred', dir_server + 'mo_kpred', 'KPR' )
    find ( Str( mkod, 7 ) )
    Do While mkod == kpr->kod .and. !Eof()
      If kpr->nn == 1
        ++mkol_pred
        m1is_uhod_pr1 := kpr->is_uhod
        m1is_food_pr1 := kpr->is_food
        mFIO_PR1 := kpr->fio
        mDATE_R_PR1 := kpr->DATE_R
        m1status_PR1 := kpr->STATUS
        mADRES_PR1 := kpr->ADRES
        mMR_DOL_PR1 := kpr->MR_DOL
        mphone_PR1 := kpr->PHONE
        mpasport_PR1 := kpr->PASPORT
        mpolis_PR1 := kpr->POLIS
      Elseif kpr->nn == 2
        ++mkol_pred
        mFIO_PR2 := kpr->fio
        mDATE_R_PR2 := kpr->DATE_R
        m1status_pr2 := kpr->STATUS
        mADRES_PR2 := kpr->ADRES
        mMR_DOL_PR2 := kpr->MR_DOL
        mphone_PR2 := kpr->PHONE
        mpasport_PR2 := kpr->PASPORT
        mpolis_PR2 := kpr->POLIS
      Endif
      Skip
    Enddo
  Endif
  Close databases
  fv_date_r()
  mkart_error := inieditspr( A__MENUVERT, mm_kart_error, m1kart_error )
  mwhere_kart := inieditspr( A__MENUVERT, mm_where_kart, m1where_kart )
  mokato := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
  mismo := init_ismo( m1ismo )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mgorod_selo := inieditspr( A__MENUVERT, mm_gorod_selo, m1gorod_selo )
  m1gragd := iif( Empty( mSTRANA := getcountry( m1strana ) ), 1, 0 )
  mgragd := inieditspr( A__MENUVERT, mm_danet, m1gragd )
  manonim := inieditspr( A__MENUVERT, mm_danet, m1anonim )
  mPENSIONER := inieditspr( A__MENUVERT, mm_danet, m1PENSIONER )
  mvid_ud  := inieditspr( A__MENUVERT, getvidud(), m1vid_ud )
  MKEMVYD := inieditspr( A__POPUPMENU, dir_server + 's_kemvyd', M1KEMVYD )
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  mrab_nerab := inieditspr( A__MENUVERT, menu_rab, m1rab_nerab )
  mkategor   := inieditspr( A__MENUVERT, stm_kategor, m1kategor )
  mkategor2  := inieditspr( A__MENUVERT, stm_kategor2, m1kategor2 )
  mKOD_LGOT  := inieditspr( A__MENUVERT, getdlo_lgota(), m1KOD_LGOT )
  mkomu      := inieditspr( A__MENUVERT, mm_komu, m1komu )
  minvalid   := inieditspr( A__MENUVERT, mm_invalid, m1invalid )
  mosn_preb  := inieditspr( A__MENUVERT, get_osn_preb_rf(), m1osn_preb )
  mUchastSVO := inieditspr( A__MENUVERT, mm_danet, m1UchastSVO )
  mSVO := inieditspr( A__MENUVERT, mm_SVO(), m1SVO )
  madres_reg := ini_adres( 1 )
  madres_pre := ini_adres( 2 )
  If Empty( m1namesmo := Int( Val( msmo ) ) )
    m1namesmo := glob_arr_smo[ 1, 2 ] // по умолчанию = КапиталЪ Медстрах
  Endif
  mnamesmo := inieditspr( A__MENUVERT, glob_arr_smo, m1namesmo )
  If m1namesmo == 34
    If !Empty( mismo )
      mnamesmo := PadR( mismo, 41 )
    Elseif !Empty( mnameismo )
      mnamesmo := PadR( mnameismo, 41 )
    Endif
  Endif
  f_valid_komu(, -1 )
  If eq_any( m1komu, 1, 3 )
    m1company := m1str_crb
  Endif
  mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
  chm_help_code := 3001
  // подсчет кол-ва строк
  If eq_any( glob_task, X_PLATN, X_KASSA ) .and. mem_anonim == 1
    ++count_row // Аноним
  Endif
  If !is_append .and. hb_user_curUser:isadmin() .and. mem_kart_error == 1
    ++count_row
  Endif
  If glob_task != X_PPOKOJ .and. ( is_uchastok > 0 .or. !Empty( mmo_pr ) ) .and. !is_smp
    ++count_row
  Endif
  count_row += 2 // Ф.И.О.
  ++count_row // Дата рождения
  ++count_row // Удостоверение личности: вид, серия и номер
  If !is_smp
    ++count_row // Место рождения
  Endif
  ++count_row // Кем и когда выдано
  ++count_row // Адрес регистрации
  If !is_smp
    ++count_row // Адрес пребывания
  Endif
  ++count_row // Полис ОМС: серия
  ++count_row // СМО
  If eq_any( glob_task, X_REGIST, X_OMS, X_PPOKOJ, X_PLATN, X_ORTO )
    ++count_row // Принадлежность счёта
  Endif
  flag_DVN := ( Type( 'oms_sluch_DVN' ) == 'L' .and. oms_sluch_DVN )
  If eq_any( glob_task, X_REGIST, X_OMS, X_PPOKOJ, X_MO ) .or. flag_DVN
    If is_talon .or. flag_DVN
      ++count_row // Категория по стат.талону
    Endif
    If !Empty( stm_kategor2 )
      ++count_row // Категория МО
    Endif
    ++count_row // Работающий?
  Endif
  If eq_any( glob_task, X_REGIST, X_PLATN, X_ORTO, X_KASSA, X_PPOKOJ, X_MO )
    ++count_row // Место работы, должность
  Endif
  ++count_row // телефоны
  If !eq_any( glob_task, X_PLATN, X_ORTO, X_KASSA, X_MO )
    ++count_row // инвалидность
  Endif
  If eq_any( glob_task, X_MO )
    ++count_row // льгота по ДЛО
  Endif
  ++count_row // Житель:город/село + Гражданин РФ?
  If eq_any( glob_task, X_PPOKOJ )
    ++count_row // рост и вес
  Endif
  If ( title_top := ( _top_r == NIL ) )
    Default _bot_r To MaxRow() -1
    If ( _top_r := _bot_r - count_row -1 ) < 0
      _top_r := 0
    Endif
  Else
    If ( _bot_r := _top_r + count_row + 1 ) > MaxRow() -1
      _bot_r := MaxRow() -1
      _top_r := _bot_r - count_row -1
    Endif
  Endif
  Do While .t.
    SetColor( cDataCGet )
    clrlines( _top_r, MaxRow() -1 )
    If title_top
      @ _top_r, 0 Say PadC( iif( mkod == 0, 'Добавление в картотеку', 'Редактирование картотеки' ), 80 ) Color 'B/B*'
    Else
      @ _top_r, 0 Say PadC( 'Изменение реквизитов пациента в картотеке', 80 ) Color 'B/B*'
      @ _bot_r, 0 Say Replicate( ' ', 80 ) Color 'B/B*'
    Endif
    ix := _top_r
    If eq_any( glob_task, X_PLATN, X_KASSA ) .and. mem_anonim == 1
      @ ++ix, 50 Say 'Аноним?' Get manonim ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      Keyboard Chr( K_TAB )
    Endif
    If !is_append .and. hb_user_curUser:isadmin() .and. mem_kart_error == 1
      @ ++ix, 50 Say 'Статус' Get mkart_error ;
        reader {| x| menu_reader( x, mm_kart_error, A__MENUVERT, , , .f. ) }
      Keyboard Chr( K_TAB )
    Elseif m1kart_error < 0
      n_message( { 'Внимание!', ;
        'Для карточки пациента установлен статус', ;
        '" ' + Upper( mkart_error ) + ' "' }, , 'GR+/R', 'W+/R', ix + 2, , 'G+/R' )
    Endif
    If glob_task != X_PPOKOJ .and. ( is_uchastok > 0 .or. !Empty( mmo_pr ) ) .and. !is_smp
      ++ix
      c := 1
      If is_uchastok > 0
        @ ix, c Say 'Тип' Get mbukva Pict '@!'
        @ ix, Col() + 3 Say 'Участок' Get muchast Pict '99' ;
          valid {| g| e_k_uchast( g ) }
        If is_uchastok == 1
          @ ix, Col() + 3 Say 'Код в участке' Get mkod_vu Pict '99999' ;
            When e_k_kod_vu()
        Elseif is_uchastok == 3
          @ ix, Col() + 3 Say 'Номер АК МИС' Get mkod_AK Pict '999999'
        Endif
        c := Col() + 3
      Endif
      If !Empty( mmo_pr )
        @ ix, c Say mmo_pr Color color8
      Endif
    Endif
    @ ++ix, 1 Say 'Фамилия' Get mfam Pict '@S33' ;
      valid {| g| LastKey() == K_UP .or. m1anonim == 1 .or. valfamimot( 1, mfam ) }
    @ Row(), Col() + 1 Say 'Имя' Get mim Pict '@S32' valid {| g| m1anonim == 1 .or. valfamimot( 2, mim ) }
    @ ++ix, 1 Say 'Отчество' Get mot valid {| g| m1anonim == 1 .or. valfamimot( 3, mot ) }
    If mem_pol == 1
      @ Row(), 70 Say 'Пол' Get mpol ;
        reader {| x| menu_reader( x, menupol, A__MENUVERT, , , .f. ) }
    Else
      @ Row(), 70 Say 'Пол' Get mpol Pict '@!' valid {| g| mpol $ 'МЖ' }
    Endif
    @ ++ix, 1 Say 'Дата рождения' Get mdate_r ;
      valid {| g| iif( mdate_r == g:original, .t., fv_date_r() ), findkartoteka( 1, @mkod ) }
    @ Row(), 30 Say '==>' Get mvzros_reb When .f. Color cDataCSay
    @ Row(), 50 Say 'СНИЛС' Get msnils Pict picture_pf ;
      valid {|| val_snils( msnils, 1 ), findkartoteka( 3, @mkod ) }
    @ ++ix, 1 Say 'Уд-ие личности:' Get mvid_ud ;
      reader {| x| menu_reader( x, getvidud(), A__MENUVERT, , , .f. ) }
    // @ ix, 42 say 'Серия' get mser_ud pict '@!' valid val_ud_ser(1, m1vid_ud, mser_ud)
    @ ix, 44 Say 'Серия' Get mser_ud Pict '@!' valid {| oGet | checkdocumentseries( oGet, m1vid_ud ) }
    @ ix, Col() + 1 Say '№' Get mnom_ud Pict '@!S18' Valid val_ud_nom( 1, m1vid_ud, mnom_ud )
    If !is_smp
      @ ++ix, 2 Say 'Место рождения' Get mmesto_r Pict '@S62'
    Endif
    @ ++ix, 2 Say 'Выдано' Get mkogdavyd
    @ ix, Col() Say ',' Get mkemvyd reader {| x| menu_reader( x, { {| k, r, c| get_s_kemvyd( k, r, c ) } }, A__FUNCTION, , , .f. ) }
    @ ++ix, 1 Say 'Адрес регистрации' Get madres_reg ;
      reader {| x| menu_reader( x, { {| k, r, c| get_adres( 1, k, r, c ) } }, A__FUNCTION, , , .f. ) }
    If !is_smp
      @ ++ix, 1 Say 'Адрес пребывания' Get madres_pre ;
        reader {| x| menu_reader( x, { {| k, r, c| get_adres( 2, k, r, c ) } }, A__FUNCTION, , , .f. ) }
    Endif

    @ ++ix, 1 Say 'Полис ОМС: серия' Get mspolis
    @ Row(), Col() + 3 Say 'номер' Get mnpolis valid {|| findkartoteka( 2, @mkod ) }
    @ Row(), Col() + 3 Say 'вид' Get mvidpolis ;
      reader {| x| menu_reader( x, mm_vid_polis, A__MENUVERT, , , .f. ) } ;
      Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )

    @ ++ix, 1 Say 'СМО' Get mnamesmo ;
      reader {| x| menu_reader( x, glob_arr_smo, A__MENUVERT, , , .f. ) } ;
      valid {| g| func_valid_ismo( g, 0, 41, 'namesmo' ) }
    @ Row(), 47 Say 'полис с' Get mbeg_polis
    @ Row(), Col() + 1 Say 'по' Get msrok_polis
    If eq_any( glob_task, X_REGIST, X_OMS, X_PPOKOJ, X_PLATN, X_ORTO )
      @ ++ix, 1 Say 'Принадлежность счета' Get mkomu ;
        reader {| x| menu_reader( x, mm_komu, A__MENUVERT, , , .f. ) } ;
        valid {| g, o| f_valid_komu( g, o ) }
      @ Row(), Col() + 1 Say '==>' Get mcompany ;
        reader {| x| menu_reader( x, mm_company, A__MENUVERT, , , .f. ) } ;
        When eq_any( m1komu, 1, 3 )
    Endif
    If eq_any( glob_task, X_REGIST, X_OMS, X_PPOKOJ, X_MO ) .or. flag_DVN
      If is_talon .or. flag_DVN
        @ ++ix, 1 Say 'Код категории льготы'
        c := Col() + 1
        If .t. // mem_st_kat == 1
          @ ix, c Get mkategor ;
            reader {| x| menu_reader( x, mo_cut_menu( stm_kategor ), A__MENUVERT, , , .f. ) }
          c += 24
        Else
          @ ix, c Get m1kategor Pict '99' ;
            valid {| g| val_st_kat( g ) }
          @ Row(), Col() + 3 Get mkategor Color color14 When .f.
          c += 27
        Endif
      Endif
      If !Empty( stm_kategor2 )
        @ ++ix, c Say 'Категория МО' Get mkategor2 ;
          reader {| x| menu_reader( x, stm_kategor2, A__MENUVERT, , , .f. ) }
      Endif
      @ ++ix, 1 Say 'Работающий?' Get mrab_nerab ;
        reader {| x| menu_reader( x, menu_rab, A__MENUVERT, , , .f. ) }
      @ Row(), Col() + 5 Say 'Пенсионер?' Get mpensioner ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
    Endif
    If eq_any( glob_task, X_REGIST, X_PLATN, X_ORTO, X_KASSA, X_PPOKOJ, X_MO )
      fl_mr_dol := .t.
      @ ++ix, 1 Say 'Место работы, должность' Get mmr_dol
    Endif
    @ ++ix, 1 Say 'Телефоны: домашний' Get mPHONE_H valid {| g| valid_phone( g ) }
    @ Row(), Col() + 1 Say ', мобильный' Get mPHONE_M valid {| g| valid_phone( g, .t. ) }
    @ Row(), Col() + 1 Say   ', рабочий' Get mPHONE_W valid {| g| valid_phone( g ) }
    If ! eq_any( glob_task, X_PLATN, X_ORTO, X_KASSA ) // инвалидность
      @ ++ix, 1 Say 'Инвалидность' Get minvalid ;
        reader {| x| menu_reader( x, mm_invalid, A__MENUVERT, , , .f. ) } ;
        valid {|| f_kart_valid_inv( ix ) }
      @ ix, Col() + 6 Say 'Социальная категория' Get mSVO ;
        reader {| x| menu_reader( x, mm_SVO(), A__MENUVERT, , , .f. ) }
    Endif
    If eq_any( glob_task, X_MO )
      @ ++ix, 1 Say 'Льгота по ДЛО' Get mKOD_LGOT ;
        reader {| x| menu_reader( x, getdlo_lgota(), A__MENUVERT, , , .f. ) }
    Endif
    @ ++ix, 1 Say 'Житель:' Get mgorod_selo ;
      reader {| x| menu_reader( x, mm_gorod_selo, A__MENUVERT, , , .f. ) }
    @ ix, 19 Say 'Участник СВО?' get mUchastSVO ;
      reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
    @ ix, Col() + 3 Say 'Гражданин РФ?' Get mgragd ;
      reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
      valid {|| iif( m1gragd == 1, .t., get_oksm( ix ) ) }
    @ ix, Col() + 5 Get mstrana When .f. Color color14
    If eq_any( glob_task, X_PPOKOJ )
      @ ++ix, 1 Say 'Рост' Get mHEIGHT Pict '999'
      @ ix, Col() + 1 Say 'см,  вес' Get mWEIGHT Pict '999'
      @ ix, Col() + 1 Say 'кг'
      @ ix, Col() + 5 Say 'Количество представителей' Get mkol_pred Pict '9' ;
        valid {|| Between( mkol_pred, 0, 2 ) .and. f_kart_valid_pred( ix ) }
    Endif
    If pos_read > 0
      If Lower( GetList[ pos_read ]:name ) == 'mgragd'
        --pos_read
      Endif
      If Lower( GetList[ pos_read ]:name ) == 'mgorod_selo'
        --pos_read
      Endif
      If Lower( GetList[ pos_read ]:name ) == 'minvalid'
        --pos_read
      Endif
    Endif
    status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода' )
    Set Key K_F2 To f_prim1
    If fl_mr_dol
      Set Key K_F4 To v_vvod_mr
    Endif
    count_edit := myread()
    // count_edit := myread(,@pos_read,++k_read)
    If fl_mr_dol
      Set Key K_F4 To
    Endif
    Set Key K_F2 To
    If p_edit_kartoteka // при добавлении нашли в картотеке такого пациента
      Exit
    Endif
    If LastKey() != K_ESC
      MFIO := RTrim( mfam ) + ' ' + RTrim( mim ) + ' ' + mot
      If Empty( mfio )
        func_error( 4, 'Не введены Ф.И.О. Нет записи!' )
        Loop
      Endif
      If eq_any( glob_task, X_REGIST, X_OMS, X_PPOKOJ ) .and. m1KOMU == 0
        If Empty( mdate_r )
          func_error( 4, 'Не заполнена дата рождения' )
          Loop
        Endif
        If Empty( mnpolis ) .and. !_task_263_
          func_error( 4, 'Не заполнен номер полиса' )
          Loop
        Endif
        If !is_smp .and. eq_any( m1vid_ud, 3, 14 ) .and. !Empty( mser_ud ) .and. Empty( del_spec_symbol( mmesto_r ) )
          func_error( 4, iif( m1vid_ud == 3, 'Для свид-ва о рождении', 'Для паспорта РФ' ) + ;
            ' обязательно заполнение поля "Место рождения"' )
          If !( glob_mo[ _MO_KOD_TFOMS ] == '126501' )
            Loop
          Endif
        Endif
      Endif
      func_valid_polis( m1vidpolis, mspolis, mnpolis, Between( m1namesmo, 34001, 34007 ) )
      Close databases
      If f_esc_enter( 1 )
        mywait()
        If m1anonim == 1
          newMEST_INOG := 8
        Elseif twowordfamimot( mfam ) .or. twowordfamimot( mim ) .or. twowordfamimot( mot )
          newMEST_INOG := 9
        Endif
        If Between( m1INVALID, 1, 4 ) .and. emptyany( MDATE_INV, MPRICH_INV )
          m1INVALID := 0
        Endif
        fl_write_kartoteka := .t.
        st_rab_nerab := M1RAB_NERAB
        g_use( dir_server + 'k_prim1', dir_server + 'k_prim1', 'K_PRIM1' )
        use_base( 'kartotek' )
        If is_append  // добавление в картотеку
          add1rec( 7 )
          glob_kartotek := mkod := kart->kod := RecNo()
        Else
          find ( Str( mkod, 7 ) )
          If Found()
            g_rlock( forever )
          Else
            add1rec( 7 )
            glob_kartotek := mkod := kart->kod := RecNo()
          Endif
        Endif
        glob_k_fio := AllTrim( mfio )
        //
        kart->FIO       := mFIO
        kart->pol       := mpol
        kart->DATE_R    := mdate_r
        kart->VZROS_REB := m1VZROS_REB
        kart->ADRES     := mADRES
        kart->MR_DOL    := mMR_DOL
        kart->POLIS     := make_polis( mspolis, mnpolis ) // серия и номер страхового полиса
        kart->srok_polis := dtoc4( msrok_polis )
        kart->RAB_NERAB := m1RAB_NERAB
        kart->snils     := msnils
        kart->ZA_SMO    := m1kart_error
        If eq_any( glob_task, X_REGIST, X_OMS, X_PPOKOJ )
          kart->KOMU    := m1KOMU
          kart->STR_CRB := iif( m1komu == 0, 0, m1company )
          kart->MI_GIT  := 9
        Endif
        kart->MEST_INOG := newMEST_INOG
        If is_uchastok > 0
          kart->bukva  := mbukva
          kart->uchast := muchast
          kart->kod_vu := mkod_vu
        Endif
        kart->PN1 := iif( m1UchastSVO == 1, 30, kart->PN1 )
        kart->PC3 := StrZero( m1SVO, 3 )
        Select KART2
        Do While kart2->( LastRec() ) < mkod
          Append Blank
        Enddo
        Goto ( mkod )
        g_rlock( forever )
        If is_append  // добавление в картотеку
          kart2->kod_tf := 0
          kart2->kod_mis := ''
          kart2->kod_AK := ''
          kart2->MO_PR := ''
          kart2->TIP_PR := 0
          kart2->DATE_PR := CToD( '' )
          kart2->SNILS_VR := '' // уч.врач ещё не привязан
          kart2->PC1 := kod_polzovat + c4sys_date + hour_min( Seconds() )
          kart2->PC2 := ''
          kart2->PC4 := ''
        Endif
        If is_uchastok == 3
          kart2->kod_AK := mkod_AK
        Endif
        Select KART_
        Do While kart_->( LastRec() ) < mkod
          Append Blank
        Enddo
        Goto ( mkod )
        g_rlock( forever )
        kart_->VPOLIS := m1vidpolis
        kart_->SPOLIS := mSPOLIS
        kart_->NPOLIS := mNPOLIS
        kart_->SMO    := lstr( m1namesmo )
        kart_->beg_polis := dtoc4( mbeg_polis )
        kart_->strana    := iif( m1gragd == 0, m1strana, '' )
        kart_->gorod_selo := m1gorod_selo
        kart_->vid_ud   := m1vid_ud
        kart_->ser_ud   := mser_ud
        kart_->nom_ud   := mnom_ud
        kart_->kemvyd   := m1kemvyd
        kart_->kogdavyd := mkogdavyd
        kart_->kategor  := m1kategor
        kart_->kategor2 := m1kategor2
        kart_->mesto_r  := mmesto_r
        kart_->okatog   := mokatog
        kart_->okatop   := mokatop
        kart_->adresp   := madresp
        kart_->PHONE_H  := mPHONE_H
        kart_->PHONE_M  := mPHONE_M
        kart_->PHONE_W  := mPHONE_W
        kart_->KOD_LGOT := m1KOD_LGOT
        kart_->PENSIONER := m1PENSIONER
        kart_->INVALID  := m1INVALID
        // kart_->INVALID_ST := mINVALID_ST
        kart_->BLOOD_G  := mBLOOD_G
        kart_->BLOOD_R  := mBLOOD_R
        kart_->WEIGHT   := mWEIGHT
        kart_->HEIGHT   := mHEIGHT
        kart_->WHERE_KART := m1WHERE_KART
        Private fl_nameismo := .f.
        If m1namesmo == 34
          kart_->KVARTAL_D := m1okato // ОКАТО субъекта РФ территории страхования
          If Empty( m1ismo )
            If !Empty( mnameismo )
              fl_nameismo := .t.
            Endif
          Else
            kart_->SMO := m1ismo  // заменяем '34' на код иногородней СМО
          Endif
        Endif
        If m1MEST_INOG == 9 .or. newMEST_INOG == 9
          g_use( dir_server + 'mo_kfio', , 'KFIO' )
          Index On Str( kod, 7 ) to ( cur_dir + 'tmp_kfio' )
          find ( Str( mkod, 7 ) )
          If Found()
            If newMEST_INOG == 9
              g_rlock( forever )
              kfio->FAM := mFAM
              kfio->IM  := mIM
              kfio->OT  := mOT
            Else
              deleterec( .t. )
            Endif
          Else
            If newMEST_INOG == 9
              addrec( 7 )
              kfio->kod := mkod
              kfio->FAM := mFAM
              kfio->IM  := mIM
              kfio->OT  := mOT
            Endif
          Endif
        Endif
        If Between( m1invalid, 1, 4 ) .or. fl_invalid
          g_use( dir_server + 'kart_inv', , 'INV' )
          Index On Str( kod, 7 ) to ( cur_dir + 'tmp_inv' )
          find ( Str( mkod, 7 ) )
          If Found()
            If m1invalid == 0
              deleterec( .t. )
            Else
              g_rlock( forever )
              inv->DATE_INV := MDATE_INV
              inv->PRICH_INV := M1PRICH_INV
              inv->DIAG_INV := mDIAG_INV
            Endif
          Else
            addrec( 7 )
            inv->kod := mkod
            inv->DATE_INV := MDATE_INV
            inv->PRICH_INV := M1PRICH_INV
            inv->DIAG_INV := mDIAG_INV
          Endif
        Endif
        If fl_nameismo .or. rec_inogSMO > 0
          g_use( dir_server + 'mo_kismo', , 'SN' )
          Index On Str( kod, 7 ) to ( cur_dir + 'tmp_ismo' )
          find ( Str( mkod, 7 ) )
          If Found()
            If fl_nameismo
              g_rlock( forever )
              sn->smo_name := mnameismo
            Else
              deleterec( .t. )
            Endif
          Else
            If fl_nameismo
              addrec( 7 )
              sn->kod := mkod
              sn->smo_name := mnameismo
            Endif
          Endif
        Endif
        //
        Select K_PRIM1
        Do While .t.
          find ( Str( glob_kartotek, 7 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
        If !Empty( s_prim1 )
          For i := 1 To MLCount( s_prim1, 100 )
            addrec( 7 )
            k_prim1->kod := glob_kartotek
            k_prim1->stroke := if( i < 10, i, 9 )
            k_prim1->name := RTrim( MemoLine( s_prim1, 100, i ) )
          Next
        Endif
        If mkol_pred > 1
          If Empty( mFIO_PR2 )
            mkol_pred := 1
          Endif
        Endif
        If mkol_pred > 0
          If Empty( mFIO_PR1 )
            mkol_pred := 0
          Endif
        Endif
        g_use( dir_server + 'mo_kpred', dir_server + 'mo_kpred', 'KPR' )
        fl := .f.
        find ( Str( mkod, 7 ) + '1' )
        If Found()
          If mkol_pred > 0
            g_rlock( forever )
            fl := .t.
          Else
            deleterec( .t. )
          Endif
        Elseif mkol_pred > 0
          addrec( 7 )
          kpr->kod := mkod
          kpr->nn := 1
          fl := .t.
        Endif
        If fl
          kpr->is_uhod := m1is_uhod_pr1
          kpr->is_food := m1is_food_pr1
          kpr->fio     := mFIO_PR1
          kpr->DATE_R  := mDATE_R_PR1
          kpr->STATUS  := m1status_PR1
          kpr->ADRES   := mADRES_PR1
          kpr->MR_DOL  := mMR_DOL_PR1
          kpr->PHONE   := mphone_PR1
          kpr->PASPORT := mpasport_PR1
          kpr->POLIS   := mpolis_PR1
        Endif
        fl := .f.
        find ( Str( mkod, 7 ) + '2' )
        If Found()
          If mkol_pred > 1
            g_rlock( forever )
            fl := .t.
          Else
            deleterec( .t. )
          Endif
        Elseif mkol_pred > 1
          addrec( 7 )
          kpr->kod := mkod
          kpr->nn := 2
          fl := .t.
        Endif
        If fl
          kpr->fio     := mFIO_PR2
          kpr->DATE_R  := mDATE_R_PR2
          kpr->STATUS  := m1status_PR2
          kpr->ADRES   := mADRES_PR2
          kpr->MR_DOL  := mMR_DOL_PR2
          kpr->PHONE   := mphone_PR2
          kpr->PASPORT := mpasport_PR2
          kpr->POLIS   := mpolis_PR2
        Endif
        If fl_kis .or. m1gragd == 0
          g_use( dir_server + 'mo_kinos', dir_server + 'mo_kinos', 'KIS' )
          find ( Str( glob_kartotek, 7 ) )
          If Found()
            If m1gragd == 0
              g_rlock( forever )
            Else
              deleterec( .t. ) // т.е. гражданин РФ
            Endif
          Else
            If m1gragd == 0
              addrec( 7 )
              kis->kod := glob_kartotek
            Endif
          Endif
          If m1gragd == 0
            kis->osn_PREB   := m1osn_preb
            kis->ADRES_PRO  := MADRES_PRO  // адрес проживания в Волг.обл.
            kis->MIGR_KARTA := MMIGR_KARTA // данные миграционной карты
            kis->DATE_P_G   := MDATE_P_G   // дата пересечения границы
            kis->DATE_R_M   := MDATE_R_M   // дата регистрации в миграционной службе
          Endif
        Endif
        Close databases
        write_work_oper( glob_task, OPER_KART, iif( is_append, 1, 2 ), 1, count_edit )
        // если находимся в задаче 'ОМС' и редактируем карточку пациента
        If glob_task == X_OMS .and. !is_append
          arr := {}
          use_base( 'human' )
          Set Order To 2
          find ( Str( mkod, 7 ) )
          Do While human->kod_k == mkod .and. !Eof()
            If emptyall( human->schet, human_->reestr ) .and. _Human_kod != human->kod
              AAdd( arr, human->kod )
            Endif
            Skip
          Enddo
          If ( i := Len( arr ) ) > 0
            Keyboard ''
            If f_alert( { 'По пациенту "' + AllTrim( mfio ) + '" найдено', ;
                'листов учёта (ещё не попавших в реестр): ' + lstr( i ) + '.', ;
                'Предлагается перезаписать отредактированные', ;
                'реквизиты пациента в данные листы учёта', ;
                '', ;
                'Выберите действие:' }, ;
                { ' Отказ ', ' Перезаписать ' }, ;
                2, 'GR+/R', 'W+/R', _top_r + 1, , 'GR+/R,N/BG' ) == 2
              r_use( dir_server + 'kartote_', , 'KART_' )
              Goto ( mkod )
              r_use( dir_server + 'kartotek', , 'KART' )
              Goto ( mkod )
              mfio        := kart->fio
              mpol        := kart->pol
              mdate_r     := kart->date_r
              mADRES      := kart->ADRES
              mMR_DOL     := kart->MR_DOL
              m1RAB_NERAB := kart->RAB_NERAB
              mPOLIS      := kart->POLIS
              m1VIDPOLIS  := kart_->VPOLIS
              mSPOLIS     := kart_->SPOLIS
              mNPOLIS     := kart_->NPOLIS
              m1komu      := kart->komu
              msmo        := kart_->SMO
              m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
              g_use( dir_server + 'mo_hismo', , 'SN' )
              Index On Str( kod, 7 ) to ( cur_dir + 'tmp_ismo' )
              Select HUMAN
              Set Order To 0
              For i := 1 To Len( arr )
                Select HUMAN
                Goto ( arr[ i ] )
                g_rlock( forever )
                Select HUMAN_
                Do While human_->( LastRec() ) < arr[ i ]
                  Append Blank
                Enddo
                Goto ( arr[ i ] )
                g_rlock( forever )
                M1NOVOR := human_->NOVOR
                fv_date_r( human->N_DATA )
                //
                human->FIO       := MFIO          // Ф.И.О. больного
                human->POL       := MPOL          // пол
                human->DATE_R    := MDATE_R       // дата рождения больного
                human->VZROS_REB := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
                human->ADRES     := MADRES        // адрес больного
                human->MR_DOL    := MMR_DOL       // место работы или причина безработности
                human->RAB_NERAB := M1RAB_NERAB   // 0-работающий, 1-неработающий
                human->KOMU      := M1KOMU        // от 0 до 5
                human_->SMO      := msmo
                human->POLIS     := mpolis
                human_->VPOLIS   := m1vidpolis
                human_->SPOLIS   := LTrim( mspolis )
                human_->NPOLIS   := LTrim( mnpolis )
                human_->OKATO    := m1okato // ОКАТО субъекта РФ территории страхования
                Select SN
                find ( Str( arr[ i ], 7 ) )
                If Found()
                  If fl_nameismo
                    g_rlock( forever )
                    sn->smo_name := mnameismo
                  Else
                    deleterec( .t. )
                  Endif
                Else
                  If fl_nameismo
                    addrec( 7 )
                    sn->kod := arr[ i ]
                    sn->smo_name := mnameismo
                  Endif
                Endif
              Next
              stat_msg( 'Запись завершена!' )
              mybell( 2, OK )
            Endif
          Endif
        Endif
      Endif
      Close databases
    Endif
    Exit
  Enddo
  SetColor( tmp_color )
  chm_help_code := tmp_help
  RestScreen( buf )

  Return mkod

// 28.03.23 ввод инвалидности
Function f_kart_valid_inv( r )

  Local c := 2, r1, r2, buf, tmp_help, tmp_list, tmp_color, tek_sost, tmp_keys, ;
    pic_diag := '@K@!', bg := {| o, k| get_mkb10( o, k, .t. ) }

  If !Between( m1invalid, 1, 4 )
    Return .t.
  Endif
  Private gl_area := { 1, 3, MaxRow() -1, 76, 0 }
  r2 := r -1
  r1 := r2 -6
  buf := SaveScreen()
  Save GETS To tmp_list
  tmp_keys := my_savekey()
  change_attr()
  box_shadow( r1, c, r2, 77, , 'Ввод информации об инвалидности', 'G+/B+' )
  @ r1 + 1, c + 1 Say 'Инвалидность' Get MINVALID When .f.
  @ r1 + 2, c + 1 Say 'Дата первичного установления инвалидности' Get MDATE_INV ;
    valid {|| !Empty( MDATE_INV ) .and. mdate_r < MDATE_INV .and. MDATE_INV < sys_date }
  @ r1 + 3, c + 1 Say 'Причина первичного установления инвалидности'
  @ r1 + 4, c + 3 Get MPRICH_INV reader {| x| menu_reader( x, getprichinv(), A__MENUVERT, , , .f. ) } ;
    Valid M1PRICH_INV > 0
  @ r1 + 5, c + 1 Say 'Код основного заболевания (п.4 пп."а")' Get MDIAG_INV Picture pic_diag ;
    reader {| o| mygetreader( o, bg ) } ;
    Valid  val1_10diag( .t., .f., .f., MDATE_INV, mpol )
  status_key( '^<PgDn>^ - запись и переход в карточку пациента' )
  myread()
  RestScreen( buf )
  my_restkey( tmp_keys )
  SetColor( tmp_color )
  Restore GETS From tmp_list

  Return .t.

// 19.07.23 проверка на правильность номера телефона .. и исправление
Function valid_phone( get, is_mobil )

  Local fl := .t.
  Local s, s1

  // local phoneTemplate := '^(\s*)?(\+)?([- _():=+]?\d[- _():=+]?){10,14}(\s*)?$'

  Private tmp := ReadVar()
  s := &tmp
  If !Empty( s )
    s := CharRem( '-', s )
    s := CharRem( ' ', s )
    s1 := CharRepl( '0123456789', s, Space( 10 ) )
    If !Empty( s1 ) .or. !( Left( s, 1 ) == '8' )
      Default is_mobil To .f.
      If is_mobil
        fl := func_error( 4, 'Правильный номер мобильного телефона: "8"+ещё 10 цифр' )
      Else
        fl := func_error( 4, 'Правильный номер телефона: "8"+"код города"+"цифры" (всего 11 цифр)' )
      Endif
    Endif
    If fl .and. Len( s ) < 11
      fl := func_error( 4, 'В номере телефона должно быть 11 знаков' )
    Endif
    &tmp := PadR( s, 11 )
  Endif
  // is_mobil := alltrim(is_mobil)
  // fl := hb_RegexLike(phoneTemplate, is_mobil) .or. empty(is_mobil)
  // if ! fl
  // fl := func_error(4, 'Не верный формат телефона')
  // // hb_Alert( 'Не верный формат телефона или E-mail адреса!', , , 4 )
  // endif

  Return fl

// 27.01.25 поиск пациента в картотеке во время режима добавления
Function findkartoteka( k, /*@*/lkod_k)

  Local s, buf, rec := 0

  If lkod_k > 0
    Return .t.
  Endif
  //
  r_use( dir_server + 'kartotek', , 'KART' )
  If k == 1 .and. !emptyany( mfam, mim, mdate_r )
    mfio := PadR( Upper( RTrim( mfam ) + ' ' + RTrim( mim ) + ' ' + mot ), 50 )
    Set Index to ( dir_server + 'kartoten' )
    find ( '1' + mfio + DToS( mdate_r ) )
    If Found()
      rec := RecNo()
    Endif
  Elseif k == 2 .and. !Empty( mnpolis ) .and. p_find_polis > 0
    mpolis := make_polis( mspolis, mnpolis ) // серия и номер страхового полиса
    Set Index to ( dir_server + 'kartotep' )
    find ( '1' + PadR( mpolis, 17 ) )
    If Found()
      rec := RecNo()
    Endif
  Elseif k == 3 .and. !Empty( CharRepl( '0', msnils, ' ' ) )
    Set Index to ( dir_server + 'kartotes' )
    find ( '1' + msnils )
    If Found()
      rec := RecNo()
    Endif
  Endif
  If rec > 0
    r_use( dir_server + 'kartote2', , 'KART2' )
    Goto ( rec )
    r_use( dir_server + 'kartote_', , 'KART_' )
    Goto ( rec )
    buf := SaveScreen()
    kartotek_to_screen( 11, 18 )
    @ 10, 0 To 19, 79 Color 'G+/B'
    str_center( 10, ' В картотеке найден пациент ' + iif( k == 1, '', iif( k == 2, 'с таким полисом ', 'с таким СНИЛС ' ) ), 'G+/RB' )
    Keyboard ''
    music_m( 'OK' )
    Millisec( 100 )  // задержка на 0.1 с
    Keyboard ''
    If f_alert( { 'Взять этого пациента из картотеки или продолжить вводить нового?' }, ;
        { ' Новый пациент ', ' Взять из картотеки ' }, ;
        2, 'W+/N', 'N+/N', 20, , 'W+/N, N/BG' ) == 2
      lkod_k := rec
      mFIO        := kart->FIO
      mpol        := kart->pol
      mDATE_R     := kart->DATE_R
      m1VZROS_REB := kart->VZROS_REB
      mADRES      := kart->ADRES
      mMR_DOL     := kart->MR_DOL
      m1RAB_NERAB := kart->RAB_NERAB
      msnils      := kart->snils
      If kart->MI_GIT == 9
        m1KOMU    := kart->KOMU
        M1STR_CRB := kart->STR_CRB
      Endif
      If kart->MEST_INOG == 9 // т.е. отдельно занесены Ф.И.О.
        m1MEST_INOG := kart->MEST_INOG
      Endif
      m1UchastSVO := iif( kart->PN1 == 30, 1, 0 )
      m1SVO := val( kart->PC3 )
      m1vidpolis  := kart_->VPOLIS // вид полиса (от 1 до 3);1-старый, 2-врем., 3-новый
      mspolis     := kart_->SPOLIS // серия полиса
      mnpolis     := kart_->NPOLIS // номер полиса
      msmo        := kart_->SMO    // реестровый номер СМО
      m1vid_ud    := kart_->vid_ud   // вид удостоверения личности
      mser_ud     := kart_->ser_ud   // серия удостоверения личности
      mnom_ud     := kart_->nom_ud   // номер удостоверения личности
      mokatog     := kart_->okatog       // код места жительства по ОКАТО
      mmesto_r    := kart_->mesto_r      // место рождения
      m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
      //
      arr := retfamimot( 1, .f. )
      mfam := PadR( arr[ 1 ], 40 )
      mim  := PadR( arr[ 2 ], 40 )
      mot  := PadR( arr[ 3 ], 40 )
      If AllTrim( msmo ) == '34'
        mnameismo := ret_inogsmo_name( 1, @rec_inogSMO, .t. )
      Elseif Left( msmo, 2 ) == '34'
        // Волгоградская область
      Elseif !Empty( msmo )
        m1ismo := msmo
        msmo := '34'
      Endif
      mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
      mokato    := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
      mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
      mismo     := init_ismo( m1ismo )
      mvid_ud   := PadR( inieditspr( A__MENUVERT, getvidud(), m1vid_ud ), 23 )
      madres_reg := ini_adres( 1 )
      f_valid_komu(, -1 )
      If m1komu == 0
        m1company := Int( Val( msmo ) )
      Elseif eq_any( m1komu, 1, 3 )
        m1company := m1str_crb
      Endif
      mcompany := PadR( inieditspr( A__MENUVERT, mm_company, m1company ), 38 )
      If m1company == 34
        If !Empty( mismo )
          mcompany := PadR( mismo, 38 )
        Elseif !Empty( mnameismo )
          mcompany := PadR( mnameismo, 38 )
        Endif
      Endif
    Endif
    kart_->( dbCloseArea() )
    kart2->( dbCloseArea() )
  Endif
  kart->( dbCloseArea() )
  RestScreen( buf )
  If rec > 0 .and. lkod_k == rec
    If Type( 'p_edit_kartoteka' ) == 'L'
      p_edit_kartoteka := .t.
      ReadKill( .t. )
    Else
      update_gets()
    Endif
  Endif

  Return .t.

// 30.03.23
Function get_oksm( r )

  Local c := 7, r1, r2, buf, tmp_help, tmp_list, tmp_color, tmp_cursor, tek_sost, tmp_keys

  If r < Int( MaxRow() / 2 )
    r1 := r + 1
    r2 := r1 + 8
  Else
    r2 := r -1
    r1 := r2 -8
  Endif
  buf := SaveScreen()
  Save GETS To tmp_list
  tmp_color := SetColor( color0 + ' , , , B/BG' )
  tmp_cursor := SetCursor( 0 )
  tmp_keys := my_savekey()
  change_attr()
  box_shadow( r1, c, r2, 77, , 'Ввод дополнительных сведений по иностранцу', 'GR+/BG' )
  SetCursor()
  @ r1 + 1, c + 2 Say 'Страна' Get mstrana ;
    reader {| x| menu_reader( x, { {| k, r, c| f1get_oksm( k, r, c ) } }, A__FUNCTION, , , .f. ) }
  @ r1 + 2, c + 2 Say 'Основание пребывания в РФ' Get mosn_preb ;
    reader {| x| menu_reader( x, get_osn_preb_rf(), A__MENUVERT, , , .f. ) }
  @ r1 + 3, c + 2 Say 'Адрес проживания в Волгоградской области'
  @ r1 + 4, c + 3 Get MADRES_PRO
  @ r1 + 5, c + 2 Say 'Миграционная карта' Get MMIGR_KARTA
  @ r1 + 6, c + 2 Say 'Дата пересечения границы' Get MDATE_P_G
  @ r1 + 7, c + 2 Say 'Дата регистрации в миграционной службе' Get MDATE_R_M
  status_key( '^<PgDn>^ - запись и переход в карточку пациента' )
  myread()
  RestScreen( buf )
  my_restkey( tmp_keys )
  SetColor( tmp_color )
  Restore GETS From tmp_list
  If tmp_cursor != 0
    SetCursor()
  Endif

  Return .t.

// 16.12.22
Function f1get_oksm( k, r, c )

  Static skodN := ''
  Static arr_sng := { ;
    '895', ;// 'АБХАЗИЯ'
    '031', ;// 'АЗЕРБАЙДЖАН'
    '051', ;// 'АРМЕНИЯ'
    '112', ;// 'БЕЛАРУСЬ'
    '268', ;// 'ГРУЗИЯ'
    '398', ;// 'КАЗАХСТАН'
    '417', ;// 'КИРГИЗИЯ'
    '428', ;// 'ЛАТВИЯ'
    '440', ;// 'ЛИТВА'
    '498', ;// 'МОЛДОВА, РЕСПУБЛИКА'
    '762', ;// 'ТАДЖИКИСТАН'
    '795', ;// 'ТУРКМЕНИЯ'
    '860', ;// 'УЗБЕКИСТАН'
    '804', ;// 'УКРАИНА'
    '233', ;// 'ЭСТОНИЯ'
    '896' ;// 'ЮЖНАЯ ОСЕТИЯ'
  }
  Local ret, r1, r2, i, lcolor, tmp_select := Select()

  If ( r1 := r + 1 ) > Int( MaxRow() / 2 )
    r2 := r -1
    r1 := 2
  Else
    r2 := MaxRow() -2
  Endif
  Private p_oksm, lsng := 1, pkodN := skodN
  If ValType( k ) == 'C' .and. !Empty( k )
    pkodN := k
    If AScan( arr_sng, k ) == 0
      lsng := 0
    Endif
  Endif
  dbCreate( cur_dir + 'tmp_oksm', { ;
    { 'kodN', 'C', 3, 0 }, ;
    { 'kodA', 'C', 3, 0 }, ;
    { 'sng', 'N', 1, 0 }, ;
    { 'name', 'C', 60, 0 } ;
    } )
  Use ( cur_dir + 'tmp_oksm' ) New Alias RG
  Do While .t.
    Zap
    If lsng == 0
      lcolor := color5
      For i := 1 To Len( geto001() )
        If !( geto001()[ i, 2 ] == '643' ) // не включать Россию
          Append Blank
          rg->kodN := geto001()[ i, 2 ]
          // rg->kodA := getO001()[i, 6]
          rg->kodA := geto001()[ i, 4 ]
          rg->name := geto001()[ i, 1 ]
          If AScan( arr_sng, rg->kodN ) > 0
            rg->sng := 1
          Endif
        Endif
      Next
    Else
      lcolor := 'N/W*, GR+/R'
      For j := 1 To Len( arr_sng )
        If ( i := AScan( geto001(), {| x| x[ 2 ] == arr_sng[ j ] } ) ) > 0
          Append Blank
          rg->kodN := geto001()[ i, 2 ]
          rg->kodA := geto001()[ i, 4 ]
          rg->name := geto001()[ i, 1 ]
          rg->sng := 1
        Endif
      Next
    Endif
    Index On name to ( cur_dir + 'tmp_oksm' )
    Go Top
    If !Empty( pkodN )
      Locate For kodN == pkodN
      If !Found()
        Go Top
      Endif
    Endif
    p_oksm := 0
    If alpha_browse( r1, 2, r2, 77, 'f2get_oksm', lcolor, , , , , , , 'f3get_oksm' )
      If p_oksm == 0
        skodN := rg->kodN
        ret := { rg->kodN, AllTrim( rg->name ) }
        Exit
      Endif
    Elseif p_oksm == 0
      Exit
    Endif
  Enddo
  rg->( dbCloseArea() )
  Select ( tmp_select )

  Return ret

//
Function f2get_oksm( oBrow )

  Local n := 60

  oBrow:addcolumn( TBColumnNew( 'Код', {|| rg->kodN } ) )
  oBrow:addcolumn( TBColumnNew( '   ', {|| rg->kodA } ) )
  If lsng == 0
    oBrow:addcolumn( TBColumnNew( Center( 'Наименование страны', n ), {|| PadR( rg->name, n ) } ) )
    status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор страны;  ^<F3>^ - страны ближнего зарубежья' )
  Else
    oBrow:addcolumn( TBColumnNew( Center( 'Страны ближнего зарубежья', n ), {|| PadR( rg->name, n ) } ) )
    status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор страны;  ^<F3>^ - все страны' )
  Endif

  Return Nil

//
Function f3get_oksm( nkey )

  Local ret := -1

  If nKey == K_F3
    ret := 1
    p_oksm := 1
    pkodN := rg->kodN
    lsng := iif( lsng == 0, 1, 0 )
    If lsng == 1 .and. rg->sng != lsng
      pkodN := ''
    Endif
  Endif

  Return ret

// ввод представителей
Function f_kart_valid_pred( r )

  Local c := 2, r1, r2, buf, tmp_help, tmp_list, tmp_color, h := 7, ;
    tek_sost, tmp_keys

  If mkol_pred == 0
    Return .t.
  Endif
  Private MIS_UHOD_PR1 := inieditspr( A__MENUVERT, mm_danet, M1IS_UHOD_PR1 ), ;
    MIS_FOOD_PR1 := inieditspr( A__MENUVERT, mm_danet, M1IS_FOOD_PR1 ), ;
    mstatus_PR1 := inieditspr( A__MENUVERT, menu_predst, m1status_PR1 ), ;
    mstatus_pr2 := inieditspr( A__MENUVERT, menu_predst, m1status_pr2 ), ;
    gl_area := { 1, 0, MaxRow() -1, 79, 0 }
  If mkol_pred == 2
    h := 14
  Endif
  ++h
  If r < Int( MaxRow() / 2 )
    r1 := r + 1
    r2 := r1 + h
  Else
    r2 := r -1
    r1 := r2 - h
  Endif
  If r1 < 0
    r1 := 0
    r2 := r1 + h
  Endif
  If r2 > MaxRow() -2
    r2 := MaxRow() -2
    r1 := r2 - h
  Endif
  buf := SaveScreen()
  Save GETS To tmp_list
  tmp_keys := my_savekey()
  change_attr()
  box_shadow( r1, c, r2, 77, , 'Ввод информации о представителях', 'G+/B+' )
  @ r1 + 1, c + 1 Say 'Представитель:'
  @ r1 + 2, c + 3 Say 'ФИО' Get MFIO_PR1
  @ Row(), Col() + 3 Say 'Д.р.' Get MDATE_R_PR1
  @ r1 + 3, c + 3 Say 'Статус' Get MSTATUS_PR1 ;
    reader {| x| menu_reader( x, menu_predst, A__MENUVERT, , , .f. ) }
  @ Row(), 23 Say 'Госпитализирован?' Get MIS_UHOD_PR1 ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
    valid {|| iif( M1IS_UHOD_PR1 == 0, ( MIS_FOOD_PR1 := 'нет', M1IS_FOOD_PR1 := 0 ), nil ), ;
    update_get( 'MIS_FOOD_PR1' ) }
  @ Row(), 48 Say 'С питанием?' Get MIS_FOOD_PR1 ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
    When M1IS_UHOD_PR1 == 1
  @ r1 + 4, c + 3 Say 'Адрес' Get MADRES_PR1
  @ r1 + 5, c + 3 Say 'Место работы' Get MMR_DOL_PR1
  @ r1 + 6, c + 3 Say 'Контактный телефон' Get MPHONE_PR1
  @ r1 + 7, c + 3 Say 'Паспорт' Get MPASPORT_PR1
  @ Row(), Col() + 5 Say 'Полис' Get MPOLIS_PR1
  If mkol_pred == 2
    r1 := r1 + 7
    @ r1 + 1, c + 1 Say 'Второй представитель:'
    @ r1 + 2, c + 3 Say 'ФИО' Get MFIO_PR2
    @ Row(), Col() + 3 Say 'Д.р.' Get MDATE_R_PR2
    @ r1 + 3, c + 3 Say 'Статус' Get MSTATUS_PR2 ;
      reader {| x| menu_reader( x, menu_predst, A__MENUVERT, , , .f. ) }
    @ r1 + 4, c + 3 Say 'Адрес' Get MADRES_PR2
    @ r1 + 5, c + 3 Say 'Место работы' Get MMR_DOL_PR2
    @ r1 + 6, c + 3 Say 'Контактный телефон' Get MPHONE_PR2
    @ r1 + 7, c + 3 Say 'Паспорт' Get MPASPORT_PR2
    @ Row(), Col() + 5 Say 'Полис' Get MPOLIS_PR2
  Endif
  status_key( '^<PgDn>^ - запись и переход в карточку пациента' )
  myread()
  RestScreen( buf )
  my_restkey( tmp_keys )
  SetColor( tmp_color )
  Restore GETS From tmp_list

  Return .t.

//
Function e_k_uchast( get )

  If is_uchastok == 1 .and. muchast != get:original
    mkod_vu := 0
    update_get( 'mkod_vu' )
  Endif

  Return .t.

//
Function e_k_kod_vu()

  Local t_kod_vu := 0, vr_kod_vu, buf := save_maxrow(), is_f := 0

  If muchast > 0 .and. mkod_vu == 0 .and. ;
      r_use( dir_server + 'kartotek', dir_server + 'kartoteu', 'KART' )
    mywait( 'Ждите! Производится поиск свободного кода в участке...' )
    // проверяем есть ли такой участок в базе
    find ( StrZero( muchast, 2 ) )
    If !Found()
      t_kod_vu := 1  // новый участок
    Else
      Go Bottom // если участок последний в списке
      If muchast == kart->uchast
        If kart->kod_vu < 99999 // есть запас по номерам
          t_kod_vu := kart->kod_vu + 1
          is_f := 1
        Else // дошли до 99999
          is_f := 2
        Endif
      Endif
      If is_f == 0
        dbSeek( StrZero( muchast + 1, 2 ), .t. )
        If Eof()
          Go Bottom
        Else
          Skip -1 // выходим на нужный нам участок
        Endif
        If muchast == kart->uchast
          If kart->kod_vu < 99999 // есть запас по номерам
            t_kod_vu := kart->kod_vu + 1
            is_f := 1
          Else // дошли до 99999
            is_f := 2
          Endif
        Endif
      Endif
      If is_f == 2
        vr_kod_vu := 0
        find ( StrZero( muchast, 2 ) )
        Do While muchast == kart->uchast .and. !Eof()
          If kart->kod_vu - vr_kod_vu > 1
            t_kod_vu := vr_kod_vu + 1
            Exit
          Endif
          vr_kod_vu := kart->kod_vu
          Skip
        Enddo
      Endif
    Endif
    kart->( dbCloseArea() )
    rest_box( buf )
    If t_kod_vu > 0
      mkod_vu := t_kod_vu
      update_get( 'mkod_vu' )
    Endif
  Endif

  Return .t.

//
Function f_prim1()

  Static r1 := 14, c1 := 10, r2 := 22, c2 := 69
  Local i, j, mas, tmp, s1, buf, tmp_color, tmp_help := chm_help_code, fl, ;
    tmp_keys, updt_prim1 := .f., bSaveHandler

  buf := SaveScreen()
  tmp_keys := my_savekey()
  change_attr()
  SetKey( K_ESC, {|| __Keyboard( Chr( 23 ) ) } )  // KS_CTRL_W
  bSaveHandler := ErrorBlock( {| x| Break( x ) } )
  Begin Sequence
    chm_help_code := 10 // H_MemoEdit
    tmp_color := SetColor( 'N/W' )
    box_shadow( r1, c1, r2, c2, 'W+/W', 'Текст примечания', 'B/W' )
    status_key( '^<Esc>^ - окончание редактирования;  ^<F1>^ - помощь' )
    SetCursor()
    If ( s1 := MemoEdit( s_prim1, r1 + 1, c1 + 1, r2 -1, c2 -1, .t., ) ) != s_prim1
      updt_prim1 := .t.
      tmp := StrTran( s1, Hos, eos )
    Endif
  RECOVER USING error
    func_error( 4, 'Ошибка запуска внутреннего редактора' )
  End
  // Восстановление начальной программы обработки ошибок
  ErrorBlock( bSaveHandler )
  If updt_prim1
    mas := {}
    fl := .f.
    For i := 1 To MLCount( tmp, 100 )
      AAdd( mas, RTrim( MemoLine( s1, 100, i ) ) )
      If !fl
        fl := !Empty( mas[ i ] )
      Endif
    Next
    s_prim1 := ''
    If fl
      For i := 1 To Len( mas )
        If !Empty( mas[ i ] )
          s_prim1 += mas[ i ] + eos
        Endif
      Next
    Endif
  Endif
  chm_help_code := tmp_help
  SetColor( tmp_color )
  SetKey( K_ESC, NIL )
  my_restkey( tmp_keys )
  RestScreen( buf )

  Return Nil

//
Function val_st_kat( get )

  Local i, fl := .t.

  If ( i := AScan( stm_kategor, {| x| x[ 2 ] == m1kategor } ) ) > 0
    mkategor := PadR( stm_kategor[ i, 1 ], 38 )
    update_get( 'mkategor' )
  Else
    fl := func_error( 4, 'Недопустимый шифр категории' )
    m1kategor := get:original
  Endif

  Return fl

//
Function ini_adres( reg )

  Local s := Space( 10 )

  If reg == 1
    If mo_nodigit( mokatog )
      mokatog := s
    Endif
    If !emptyall( mokatog, madres )
      s := ret_okato_ulica( madres, mokatog )
    Endif
  Else
    If mo_nodigit( mokatop )
      mokatop := s
    Endif
    If emptyall( mokatop, madresp )
      s := 'тот же'
      m1adres_pre := 1
    Else
      s := ret_okato_ulica( madresp, mokatop )
      m1adres_pre := 2
    Endif
  Endif

  Return s

//
Function get_adres( reg, k, r, c )

  Local ret, ret1, oldk, s, mm_menu := { 'тот же', 'другой' }

  If reg == 1
    If ( ret1 := get_okato_ulica( mokatog, r, c, { mokatog, madres_reg, madres } ) ) != NIL
      mokatog := ret1[ 1 ]
      madres_reg := ret1[ 2 ]
      madres := ret1[ 3 ]
      ret := { 1, madres_reg }
    Endif
  Else
    If !emptyall( mokatop, madresp )
      mm_menu[ 2 ] := madres_pre
    Endif
    If c + Len( mm_menu[ 2 ] ) + 3 > 77
      mm_menu[ 2 ] := Left( mm_menu[ 2 ], 77 -3 - c )
    Endif
    oldk := k
    If ( k := popup_prompt( r + 1, c, oldk, mm_menu ) ) > 0
      If k == 1
        mokatop := Space( 11 )
        madres_pre := mm_menu[ 1 ]
        madresp := Space( 50 )
        ret := { 1, madres_pre }
      Else
        s := iif( oldk == 1, okato_umolch, mokatop )
        If ( ret1 := get_okato_ulica( s, r, c, { s, madres_pre, madresp } ) ) != NIL ;
            .and. !( ret1[ 2 ] == mm_menu[ 1 ] )
          mokatop := ret1[ 1 ]
          madres_pre := ret1[ 2 ]
          madresp := ret1[ 3 ]
          ret := { 2, madres_pre }
        Endif
      Endif
    Endif
  Endif

  Return ret

//
Function view_kart( regim, r1, r2 )

  Local buf := SaveScreen(), i, mkod := 0, k, ;
    fl := .f., mtitul, l_color, str_sem, ;
    arr_blk, fl_schet := .f., n_func := ''

  Default regim To 0, r1 To 2, r2 To MaxRow() -2
  Private mr1 := r1, mr2 := r2, str_find := '1', muslovie := 'kart->kod > 0', ;
    p_regim := regim, mstr_crb, top_frm := 14, blk_open
  arr_blk := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find ) }, ;
    {| n| skippointer( n, muslovie ) }, ;
    str_find, muslovie;
    }
  mywait()
  If glob_task == X_REGIST // регистратура
    chm_help_code := 1// H_Input_fioR
    n_func := 'fluorogr_lpu'
  Else
    chm_help_code := 1// H_Input_fio
  Endif
  If regim == 3
    mr1 := r1 := 1
    mr2 := r2 := 11
    n_func := 'f2_v_fio'
    chm_help_code := 1// H3_Input_fio
  Endif
  If !( Type( 'is_r_mu' ) == 'L' )
    Public is_r_mu := .f.
  Endif
  If is_r_mu
    blk_open := {| _rec, _ret| dbCloseAll(), ;
      _ret := use_base( 'r_mushrt' ) .and. use_base( 'kartotek' ), ;
      if( _ret, ( dbSelectArea( 'kart' ), ordSetFocus( 2 ) ), nil ), ;
      if( _ret, dbSetRelation( 'R_MUSHRT', ;
      {|| Upper( kart->fio ) + DToS( kart->date_r ) }, ;
      'upper(kart->fio) + dtos(kart->date_r)' ), nil ), ;
      if( _ret, dbGoto( _rec ), nil ), ;
      _ret ;
      }
  Else
    blk_open := {| _rec, _ret| dbCloseAll(), ;
      _ret := use_base( 'kartotek' ), ;
      if( _ret, ordSetFocus( 2 ), nil ), ;
      if( _ret, dbGoto( _rec ), nil ), ;
      _ret ;
      }
  Endif
  If Eval( blk_open, 1 )
    If regim == 3
      Select KART
      @ 13, 0 Say PadC( '_Просмотр картотеки_', 80, '░' ) Color 'R/BG'
    Endif
    If glob_kartotek > 0
      Set Order To 1
      find ( Str( glob_kartotek, 7 ) )
      fl := Found()
    Endif
    Set Order To 2
    If !fl
      find ( str_find )
      If !Found()
        Use
        Return func_error( 4, 'Не найдено нужных записей!' )
      Endif
    Endif
    If alpha_browse( mr1, 2, mr2, 77, 'f1_v_kart', color0, mtitul, col_tit_popup, , ;
        .t., arr_blk, n_func, 'f2_v_kart', , ;
        { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, R/BG, W+/R', , 300 } )
      If ( glob_kartotek := kart->kod ) == 0
        func_error( 4, 'Не найдено нужных записей!' )
      Else
        mkod := glob_kartotek
        glob_k_fio := AllTrim( kart->fio )
        mstr_crb := kart->str_crb
        Private mbukva := ' ', muchast := 0, mkod_vu := 0
        If is_uchastok > 0
          mbukva := kart->bukva
          muchast := kart->uchast
          mkod_vu := kart->kod_vu
        Endif
        If Empty( kart->snils ) .and. is_r_mu .and. !r_mushrt->( Eof() )
          Select KART
          g_rlock( forever )
          kart->snils := CharRem( '- ', r_mushrt->snils )
        Endif
        Close databases
        If regim == 1 .or. regim == 2 // редактирование или удаление
          str_sem := 'Редактирование картотеки ' + lstr( glob_kartotek )
          If !g_slock( str_sem )
            func_error( 4, 'В данный момент с карточкой этого человека работает другой пользователь.' )
          Else
            If regim == 1  // редактирование
              k := edit_kartotek( glob_kartotek )
            Else   // удаление
              // проверка по БД human на данного человека
              r_use( dir_server + 'human', dir_server + 'humankk', 'HUMAN' )
              find ( Str( glob_kartotek, 7 ) )
              fl := Found()
              If !fl  // платные услуги
                r_use( dir_server + 'hum_p', dir_server + 'hum_pkk', 'HUM_P' )
                find ( Str( glob_kartotek, 7 ) )
                fl := Found()
              Endif
              If !fl  // ортопедия
                r_use( dir_server + 'hum_ort', dir_server + 'hum_ortk', 'HUM_O' )
                find ( Str( glob_kartotek, 7 ) )
                fl := Found()
              Endif
              If !fl  // приемный покой
                r_use( dir_server + 'mo_pp', dir_server + 'mo_pp_r', 'HU_PP' )
                find ( Str( glob_kartotek, 7 ) )
                fl := Found()
              Endif
              If !fl  // касса
                r_use( dir_server + 'kas_pl', dir_server + 'kas_pl1', 'KASP' )
                find ( Str( glob_kartotek, 7 ) )
                fl := Found()
              Endif
              If !fl  // касса
                r_use( dir_server + 'kas_ort', dir_server + 'kas_ort1', 'KASO' )
                find ( Str( glob_kartotek, 7 ) )
                fl := Found()
              Endif
              If !fl  // направления на госпитализацию
                r_use( dir_server + 'mo_nnapr', , 'NAPR' )
                Locate For kod_k == glob_kartotek
                fl := Found()
              Endif
              If !fl .and. File( dir_server + 'vouncnaz' + sdbf ) // ВОУНЦ
                r_use( dir_server + 'vouncnaz', , 'NAZ' )
                Locate For kod_k == glob_kartotek
                fl := Found()
                If !fl
                  r_use( dir_server + 'vouncrec', , 'RCP' )
                  Locate For kod_k == glob_kartotek
                  fl := Found()
                Endif
              Endif
              Close databases
              If fl
                func_error( 4, 'По данному больному выписан лист учета. Удаление запрещено!' )
              Elseif f_esc_enter( 2 )
                mywait()
                If hb_FileExists( dir_server + 'mo_dnab' + sntx )
                  use_base( 'mo_dnab' )
                  Do While .t.
                    find ( Str( glob_kartotek, 7 ) )
                    If !Found()
                      Exit
                    Endif
                    deleterec( .t. )
                  Enddo
                Endif
                g_use( dir_server + 'mo_kinos', dir_server + 'mo_kinos', 'KIS' )
                Do While .t.
                  find ( Str( glob_kartotek, 7 ) )
                  If !Found()
                    Exit
                  Endif
                  deleterec( .t. )
                Enddo
                //
                g_use( dir_server + 'mo_kismo', , 'SN' )
                Index On Str( kod, 7 ) to ( cur_dir + 'tmp_ismo' )
                Do While .t.
                  find ( Str( glob_kartotek, 7 ) )
                  If !Found()
                    Exit
                  Endif
                  deleterec( .t. )
                Enddo
                // подобие регистра застрахованных
                g_use( dir_server + 'kart_etk' )
                Index On Str( kod_k, 7 ) to ( cur_dir + 'tmp_kart_etk' )
                Do While .t.
                  find ( Str( glob_kartotek, 7 ) )
                  If !Found()
                    Exit
                  Endif
                  deleterec( .t. )
                Enddo
                g_use( dir_server + 'k_prim1', dir_server + 'k_prim1', 'K_PRIM1' )
                Do While .t.
                  find ( Str( glob_kartotek, 7 ) )
                  If !Found()
                    Exit
                  Endif
                  deleterec( .t. )
                Enddo
                use_base( 'kartotek' )
                Set Order To 0
                Select KART
                Goto ( glob_kartotek )
                // т.к. relation
                Select KART2
                Goto ( glob_kartotek )
                If !Eof()
                  deleterec( .t., .f. )  // очистка записи без пометки на удаление
                Endif
                Select KART_
                Goto ( glob_kartotek )
                If !Eof()
                  deleterec( .t., .f. )  // очистка записи без пометки на удаление
                Endif
                Select KART
                Goto ( glob_kartotek )
                deleterec( .t., .f. )  // очистка записи без пометки на удаление
                Close databases
                write_work_oper( glob_task, OPER_KART, 3 )
                glob_kartotek := 0
                stat_msg( 'Удаление завершено!' )
                mybell( 2, OK )
              Endif
            Endif
            g_sunlock( str_sem )
          Endif
          Keyboard Chr( K_ENTER )
        Endif
      Endif
    Endif
    Close databases
  Endif
  chm_help_code := -1
  Close databases
  RestScreen( buf )

  Return ( mkod > 0 )

// 20.02.14
Function f1_v_kart( oBrow )

  Local oColumn, blk := {|| { 1, 2 } }, n := 43

  If p_regim == 3
    blk := {|| if( RecNo() == dubl1_kart, { 3, 4 }, ;
      if( RecNo() == dubl2_kart, { 5, 6 }, { 1, 2 } ) ) }
  Elseif glob_mo[ _MO_IS_UCH ]
    blk := {|| iif( kart2->mo_pr == glob_MO[ _MO_KOD_TFOMS ], { 1, 2 }, ;
      iif( Empty( kart2->mo_pr ), { 3, 4 }, { 5, 6 } ) ) }
  Endif
  If mem_kodkrt == 2
    If is_uchastok == 1
      n -= 11
    Elseif eq_any( is_uchastok, 2, 3 )
      n -= 12
    Else
      n -= 7
    Endif
  Endif
  oColumn := TBColumnNew( Center( 'Фамилия, имя, отчество', n ), {|| Left( kart->fio, n ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If mem_kodkrt == 2
    If is_uchastok > 0
      oColumn := TBColumnNew( ' ', {|| kart->bukva } )
      oColumn:defColor := { 3, 3 }
      oColumn:colorBlock := {|| { 3, 3 } }
      oBrow:addcolumn( oColumn )
      oColumn := TBColumnNew( 'Уч', {|| put_val( kart->uchast, 2 ) } )
      oColumn:defColor := { 3, 3 }
      oColumn:colorBlock := {|| { 3, 3 } }
      oBrow:addcolumn( oColumn )
    Endif
    If is_uchastok == 1
      oColumn := TBColumnNew( ' Код', {|| put_val( kart->kod_vu, 5 ) } )
      oColumn:defColor := { 3, 3 }
      oColumn:colorBlock := {|| { 3, 3 } }
      oBrow:addcolumn( oColumn )
    Elseif is_uchastok == 2
      oColumn := TBColumnNew( '  Код', {|| kart->kod } )
      oColumn:defColor := { 3, 3 }
      oColumn:colorBlock := {|| { 3, 3 } }
      oBrow:addcolumn( oColumn )
    Elseif is_uchastok == 3
      oColumn := TBColumnNew( 'Код АК', {|| Left( kart2->kod_AK, 6 ) } )
      oColumn:defColor := { 3, 3 }
      oColumn:colorBlock := {|| { 3, 3 } }
      oBrow:addcolumn( oColumn )
    Endif
  Endif
  oColumn := TBColumnNew( 'Дата рожд.', {|| kart->date_r } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Полис', 17 ), {|| ' ' + kart->polis } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If p_regim == 1
    If is_task( X_REGIST ) // если есть задача 'Регистратура'
      status_key( '^<Esc>^ выход; ^<Enter>^ редактирование; ^<F8>^ печать карты; ^<F9>^ печать листа учета' )
    Else
      status_key( '^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - редактирование' )
    Endif
  Elseif p_regim == 2
    status_key( '^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - удаление' )
  Elseif p_regim == 3
    status_key( '^^ или нач.буква - просмотр; ^<Esc>^ - отказ; ^<Ins>^ - кому переносится информация' )
  Endif
  @ mr1, 48 Say ' <F2> - поиск по шаблону ' Color 'W+/BG'
  mark_keys( { '<F2>' }, 'GR+/BG' )

  Return Nil

// 05.07.16
Function ret_last3_pos()

  Local i, s, arr := {}, mes_arr := {}

  r_use( dir_server + 'mo_regi', dir_server + 'mo_regi3', 'RU' )
  find ( Str( kart->kod, 7 ) )
  If Found()
    Do While ru->kod_k == kart->kod .and. !Eof()
      AAdd( arr, { ru->pdate, ru->CTIME, ru->tip, ru->op } )
      If Len( arr ) == 3
        Exit
      Endif
      Skip
    Enddo
    If Len( arr ) == 1
      AAdd( mes_arr, 'Последнее посещение' )
      AAdd( mes_arr, date_month( c4tod( arr[ 1, 1 ] ), .t. ) )
      If arr[ 1, 3 ] == 1
        AAdd( mes_arr, 'в отделение:' )
        AAdd( mes_arr, AllTrim( inieditspr( A__POPUPMENU, dir_server + 'mo_otd', arr[ 1, 4 ] ) ) )
      Else
        AAdd( mes_arr, 'врачебный прием:' )
        AAdd( mes_arr, AllTrim( inieditspr( A__POPUPMENU, dir_server + 'p_priem', arr[ 1, 4 ] ) ) )
      Endif
    Elseif Len( arr ) > 1
      ASort( arr, , , {| x, y| iif( x[ 1 ] == y[ 1 ], x[ 2 ] < y[ 2 ], x[ 1 ] < y[ 1 ] ) } )
      AAdd( mes_arr, 'Последние посещения:' )
      For i := 1 To Len( arr )
        s := date_8( c4tod( arr[ i, 1 ] ) ) + 'г.'
        If !Empty( arr[ i, 2 ] )
          s += ' в ' + arr[ i, 2 ]
        Endif
        s += ' ['
        If arr[ i, 3 ] == 1
          s += AllTrim( inieditspr( A__POPUPMENU, dir_server + 'mo_otd', arr[ i, 4 ] ) )
        Else
          s += AllTrim( inieditspr( A__POPUPMENU, dir_server + 'p_priem', arr[ i, 4 ] ) )
        Endif
        AAdd( mes_arr, s + ']' )
      Next
    Endif
  Endif
  ru->( dbCloseArea() )
  Select KART

  Return mes_arr

// 05.07.16
Function f2_v_kart( nkey, oBrow )

  Static s_regim := 1, s_shablon := '', s_polis := '', s_snils := ''
  Local buf := SaveScreen(), rec1 := RecNo(), fl := -1, fr := 13, ;
    tmp := '', i, s, fl_number := .t., arr := {}, mes_arr := {}

  If p_regim == 3
    fr := 7
  Endif
  Private tmp1
  If p_regim == 1 .and. is_task( X_REGIST ) // если есть задача 'Регистратура'
    begin_task_regist() // прочитать mem-переменные из Регистратуры
    Select KART
    Do Case
    Case nkey == K_F4
      r_list_uch( 5, 'f_f066' )
    Case nkey == K_F5
      pr_sh_f5()
    Case nkey == K_F6
      If mem_6op == 0
        new_list_uch( 4, 'f_talon025' )
      Else
        If mem_posl_p == 1
          mes_arr := ret_last3_pos()
        Endif
        If !Empty( mes_arr )
          f_message( mes_arr, , cColorSt2Msg, cColorStMsg, 0, 0 )
        Endif
        If mem_6op == 1
          If input_uch( 0, 44, sys_date ) != Nil .and. input_otd( 0, 44, sys_date ) != NIL
            new_list_uch( 4, 'f_talon025' )
          Endif
        Else
          If input_uch( 0, 44, sys_date ) != Nil .and. ;
              ( fr := popup_edit( dir_server + 'p_priem', 0, 49, 12, glob_priem[ 1 ], ;
              PE_RETURN, color5, , , , , , , 'Первичные приемы', col_tit_popup ) ) != NIL
            glob_priem := fr
            new_list_uch( 4, 'f_talon025' )
          Endif
        Endif
      Endif
      RestScreen( buf )
    Case nkey == K_F8
      If mem_t_025u == 0
        r_list_uch( 0, 'ind_karta' )
      Else
        new_list_uch( 0, 'f_f025u' )
      Endif
    Case nkey == K_F9
      If mem_posl_p == 1
        mes_arr := ret_last3_pos()
      Endif
      If !Empty( mes_arr )
        f_message( mes_arr, , cColorSt2Msg, cColorStMsg, 0, 0 )
      Endif
      tmp := 'list_uch'
      If is_r_mu .and. !r_mushrt->( Eof() )
        tmp += '(.t.)'
      Endif
      If mem_op == 1
        If input_uch( 0, 44, sys_date ) != Nil .and. input_otd( 0, 44, sys_date ) != NIL
          r_list_uch( 1, tmp )
        Endif
      Else
        If input_uch( 0, 44, sys_date ) != Nil .and. ;
            ( fr := popup_edit( dir_server + 'p_priem', 0, 49, 12, glob_priem[ 1 ], ;
            PE_RETURN, color5, , , , , , , 'Первичные приемы', col_tit_popup ) ) != NIL
          glob_priem := fr
          r_list_uch( 2, tmp )
        Endif
      Endif
      RestScreen( buf )
    Endcase
    Close databases
    Eval( blk_open, rec1 )
    Select KART
  Elseif p_regim == 3 .and. nkey == K_INS
    If dubl1_kart == 0
      dubl1_kart := kart->kod
      status_key( '^^ или нач.буква - просмотр; ^<Esc>^ - отказ; ^<Ins>^ - отметить удаляемого человека' )
      chm_help_code := 1// H4_Input_fio
    Else
      If dubl1_kart == kart->kod
        func_error( 4, 'Данный человек уже отмечен для переноса к нему всей информации от удаляемого.' )
      Else
        dubl2_kart := kart->kod
        Keyboard Replicate( Chr( K_LEFT ) + Chr( K_RIGHT ), 5 ) + Chr( K_ENTER )
      Endif
    Endif
    Return -1
  Endif
  If nkey != K_F2
    Return -1
  Endif
  Do While .t.
    Do While .t.
      If s_regim == 1
        chm_help_code := 1// HK_shablon_fio
        tmp := PadR( s_shablon, 50 )
        SetColor( color8 )
        box_shadow( fr, 14, fr + 5, 67 )
        @ fr + 2, 15 Say Center( ' Введите шаблон для поиска фамилий', 52 )
        @ fr + 3, 16 Get tmp Picture '@K@!'
        status_key( '^<Esc>^ отказ от ввода;  ^<Enter>^ подтверждение ввода;  ^<F10>^ поиск по полису' )
      Elseif s_regim == 2
        chm_help_code := -1
        tmp := PadR( s_polis, 17 )
        SetColor( color8 )
        box_shadow( fr, 14, fr + 5, 67 )
        @ fr + 2, 15 Say Center( 'Введите ПОЛИС для поиска в картотеке', 52 )
        @ fr + 3, 32 Get tmp Picture '@K@!'
        status_key( '^<Esc>^ отказ от ввода;  ^<Enter>^ подтверждение ввода;  ^<F10>^ поиск по СНИЛС' )
      Elseif s_regim == 3
        chm_help_code := -1
        tmp := PadR( s_snils, 11 )
        tmp_color := SetColor( color14 )
        box_shadow( fr, 14, fr + 5, 67 )
        @ fr + 2, 15 Say Center( 'Введите СНИЛС для поиска в картотеке', 52 )
        @ fr + 3, 33 Get tmp Picture '@K' + picture_pf Valid val_snils( tmp, 1 )
        status_key( '^<Esc>^ отказ от ввода;  ^<Enter>^ подтверждение ввода;  ^<F10>^ поиск по Ф.И.О.' )
      Endif
      Set Key K_F10 To clear_gets
      myread( { 'confirm' } )
      SetColor( color0 )
      Set Key K_F10 To
      If LastKey() == K_F10
        s_regim := iif( ++s_regim == 4, 1, s_regim )
      Else
        If LastKey() == K_ESC .or. Empty( tmp )
          tmp := NIL
        Else
          If s_regim == 1
            s_shablon := AllTrim( tmp )
          Elseif s_regim == 2
            s_polis := tmp
          Else
            s_snils := tmp
          Endif
        Endif
        Exit
      Endif
    Enddo
    If tmp == NIL
      Exit
    Endif
    mywait()
    tmp := AllTrim( tmp )
    If s_regim == 1
      If is_uchastok == 1
        tmp1 := tmp
        If !( Left( tmp, 1 ) $ '0123456789' )
          tmp1 := SubStr( tmp1, 2 )  // отбросить первую букву
        Endif
        For i := 1 To Len( tmp1 )
          If !( SubStr( tmp1, i, 1 ) $ '0123456789/' )
            fl_number := .f.
            Exit
          Endif
        Next
        If fl_number
          If ( i := At( '/', tmp1 ) ) == 0
            fl_number := .f.
          Else
            tmp1 := PadL( AllTrim( SubStr( tmp1, 1, i -1 ) ), 2, '0' ) + ;
              PadL( AllTrim( SubStr( tmp1, i + 1 ) ), 4, '0' )
          Endif
        Endif
      Else
        For i := 1 To Len( tmp )
          If !( SubStr( tmp, i, 1 ) $ '0123456789' )
            fl_number := .f.
            Exit
          Endif
        Next
      Endif
      If fl_number
        If is_uchastok == 1
          Select KART
          Set Order To 4
          find ( tmp1 )
          If Found()
            fl := 0
            i := RecNo()
          Endif
          Set Order To 2
          If fl == 0
            oBrow:gotop()
            Goto ( i )
            Exit
          Else
            func_error( 4, 'В картотеке нет человека с кодом ' + tmp + '.' )
            RestScreen( buf )
            Loop
          Endif
        Else
          Goto ( Int( Val( tmp ) ) )
          If !Eof() .and. kart->kod > 0 .and. !Deleted()
            oBrow:gotop()
            Goto ( Int( Val( tmp ) ) )
            fl := 0
            Exit
          Else
            func_error( 4, 'В картотеке нет человека с кодом ' + tmp + '.' )
            RestScreen( buf )
            Loop
          Endif
        Endif
      Else
        Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := mr1 + 3, ;
          k2 := mr2 -1, tmp2 := Upper( tmp ), ch := Left( tmp, 1 )
        i := 0
        If !( ch == '*' .or. ch == '?' )
          tmp1 := tmp2
          If '*' $ tmp1
            tmp1 := BeforAtNum( '*', tmp1, 1 )
          Endif
          If '?' $ tmp1
            tmp1 := BeforAtNum( '?', tmp1, 1 )
          Endif
          If Len( tmp1 ) > 20
            tmp1 := Left( tmp1, 20 )
          Endif
          ch := Len( tmp1 )
          find ( str_find + tmp1 )
          Do while &( muslovie + ' .and. tmp1 == left(upper(fio),ch) .and. !eof()' )
            If Like( tmp2, Upper( fio ) )
              If++i > 4000
                Exit
              Endif
              AAdd( tmp_mas, Left( kart->fio, 39 ) + ' ░ ' + date_8( kart->date_r ) + ;
                ' ░ ' + AllTrim( kart->polis ) )
              AAdd( tmp_kod, kart->kod )
            Endif
            Skip
          Enddo
        Else
          find ( str_find )
          Do while &( muslovie + ' .and. !eof()' )
            If Like( tmp2, Upper( fio ) )
              If++i > 4000
                Exit
              Endif
              AAdd( tmp_mas, Left( kart->fio, 39 ) + ' ░ ' + date_8( kart->date_r ) + ;
                ' ░ ' + AllTrim( kart->polis ) )
              AAdd( tmp_kod, kart->kod )
            Endif
            Skip
          Enddo
        Endif
        If ( t_len := Len( tmp_kod ) ) = 0
          func_error( 4, 'Не найдено ни одной записи, удовлетворяющей данному шаблону!' )
          RestScreen( buf )
          Loop
        Else
          box_shadow( mr1, 2, mr2, 77 )
          SetColor( col_tit_popup )
          @ k1 -2, 15 Say 'Шаблон: ' + tmp2
          SetColor( color0 )
          If k1 + t_len + 2 < mr2 -1
            k2 := k1 + t_len + 2
          Endif
          @ k1, 3 Say Center( ' Количество найденных фамилий - ' + lstr( t_len ), 74 )
          i := AScan( tmp_kod, glob_perso )
          status_key( '^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор' )
          If ( i := Popup( k1 + 1, 3, k2, 76, tmp_mas, i, color0 ) ) > 0
            Set Order To 1
            find ( Str( tmp_kod[ i ], 7 ) )
            Set Order To 2
            fl := 0
          Endif
          Exit
        Endif
      Endif
    Elseif s_regim == 2 // поиск по полису
      Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := mr1 + 3, ;
        k2 := mr2 -1, tmp2 := PadR( Upper( tmp ), 17 )
      i := 0
      Set Order To 3
      find ( '1' + tmp2 )
      Do While kart->polis == tmp2 .and. kart->kod > 0 .and. !Eof()
        If++i > 4000
          Exit
        Endif
        AAdd( tmp_mas, Left( kart->fio, 39 ) + ' ░ ' + date_8( kart->date_r ) + ;
          ' ░ ' + AllTrim( kart->polis ) )
        AAdd( tmp_kod, kart->kod )
        Skip
      Enddo
      Set Order To 2
      If ( t_len := Len( tmp_kod ) ) = 0
        func_error( 4, 'Не найдено ни одного человека с данным полисом!' )
        RestScreen( buf )
        Loop
      Else
        box_shadow( mr1, 2, mr2, 77 )
        SetColor( col_tit_popup )
        @ k1 -2, 15 Say 'Полис: ' + tmp2
        SetColor( color0 )
        If k1 + t_len + 2 < mr2 -1
          k2 := k1 + t_len + 2
        Endif
        @ k1, 3 Say Center( ' Количество найденных фамилий - ' + lstr( t_len ), 74 )
        i := AScan( tmp_kod, glob_perso )
        status_key( '^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор' )
        If ( i := Popup( k1 + 1, 3, k2, 76, tmp_mas, i, color0 ) ) > 0
          Set Order To 1
          find ( Str( tmp_kod[ i ], 7 ) )
          Set Order To 2
          fl := 0
        Endif
        Exit
      Endif
    Elseif s_regim == 3 // поиск по СНИЛС
      Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := mr1 + 3, ;
        k2 := mr2 -1, tmp2 := tmp
      i := 0
      Set Order To 5
      find ( '1' + tmp2 )
      Do While kart->snils == tmp2 .and. kart->kod > 0 .and. !Eof()
        If++i > 4000
          Exit
        Endif
        AAdd( tmp_mas, Left( kart->fio, 39 ) + ' ░ ' + date_8( kart->date_r ) + ;
          ' ░ ' + AllTrim( kart->polis ) )
        AAdd( tmp_kod, kart->kod )
        Skip
      Enddo
      Set Order To 2
      If ( t_len := Len( tmp_kod ) ) = 0
        func_error( 4, 'Не найдено ни одного человека с данным СНИЛС!' )
        RestScreen( buf )
        Loop
      Else
        box_shadow( mr1, 2, mr2, 77 )
        SetColor( col_tit_popup )
        @ k1 -2, 15 Say 'СНИЛС: ' + Transform( tmp2, picture_pf )
        SetColor( color0 )
        If k1 + t_len + 2 < mr2 -1
          k2 := k1 + t_len + 2
        Endif
        @ k1, 3 Say Center( ' Количество найденных фамилий - ' + lstr( t_len ), 74 )
        i := AScan( tmp_kod, glob_perso )
        status_key( '^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор' )
        If ( i := Popup( k1 + 1, 3, k2, 76, tmp_mas, i, color0 ) ) > 0
          Set Order To 1
          find ( Str( tmp_kod[ i ], 7 ) )
          Set Order To 2
          fl := 0
        Endif
        Exit
      Endif
    Endif
  Enddo
  If fl == -1
    Goto rec1
  Endif
  RestScreen( buf )
  If glob_task == X_REGIST // регистратура
    chm_help_code := 1// H_Input_fioR
  Else
    chm_help_code := 1// H_Input_fio
  Endif

  Return fl

//
Function dubl_zap( r, c )

  Local mas_pmt := { '~Поиск дублирующихся записей', ;
    '~Удаление дублирующихся записей' }
  Local mas_msg := { 'Поиск дублирующихся записей в картотеке', ;
    'Удаление дублирующихся записей из картотеки' }
  Local mas_fun := { 'f1dubl_zap()', ;
    'f2dubl_zap()' }

  Default r To T_ROW, c To T_COL + 5
  popup_prompt( r, c, 1, mas_pmt, mas_msg, mas_fun )

  Return Nil

// 09.07.18
Function f1dubl_zap()

  Static si := 1
  Local hGauge, sh, HH := 77, name_file := cur_dir + 'dubl_zap' + stxt, j1, ;
    fl := .t., sfio, old_fio, k := 0, rec1, curr := 0, buf, ;
    mfio, mdate_r, mpolis, arr_title, reg_print := 4, ;
    arr := { ' По ~ФИО+дата рожд. ', ' По ~полису ', ' По ~СНИЛС ', ' По ~ЕНП ' }

  If ( i := f_alert( { 'Выберите, каким образом будет осуществляться поиск дубликатов записей:', ;
      '' }, ;
      arr, ;
      si, 'N+/BG', 'R/BG', 15, , col1menu ) ) == 0
    Return Nil
  Endif
  si := i
  If !myfiledeleted( cur_dir + 'tmp' + sdbf )
    Return Nil
  Endif
  If !myfiledeleted( cur_dir + 'tmpitg' + sdbf )
    Return Nil
  Endif
  dbCreate( cur_dir + 'tmpitg', { ;
    { 'ID', 'N', 8, 0 }, ;
    { 'fio', 'C', 50, 0 }, ;
    { 'DATE_R', 'D', 8, 0 }, ;
    { 'kod_kart', 'N', 8, 0 }, ;
    { 'kod_tf', 'N', 10, 0 }, ;
    { 'kod_mis', 'C', 20, 0 }, ;
    { 'adres', 'C', 50, 0 }, ;
    { 'fio', 'C', 50, 0 }, ;
    { 'pol', 'C', 1, 0 }, ;
    { 'polis', 'C', 17, 0 }, ;
    { 'uchast', 'N', 2, 0 }, ;
    { 'KOD_VU', 'N', 5, 0 }, ; // код в участке
  { 'snils', 'C', 17, 0 }, ;
    { 'DATE_PR', 'D', 8, 0 }, ;
    { 'MO_PR', 'C', 6, 0 } ;
    } )
  Use ( cur_dir + 'tmpitg' ) new
  r_use( dir_server + 'kartote2', , 'KART2' )
  //
  status_key( '^<Esc>^ - прервать поиск' )
  hGauge := gaugenew(, , , 'Поиск дублирующихся записей', .t. )
  gaugedisplay( hGauge )
  If i == 1
    arr_title := { '────┬─────────────────────────────────────────────┬────────┬──────', ;
      ' NN │                   Ф.И.О.                    │ Дата р.│Кол-во', ;
      '────┴─────────────────────────────────────────────┴────────┴──────' }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file )
    n_list := 1
    tek_stroke := 0
    add_string( '' )
    add_string( Center( 'Список дублирующихся записей в картотеке', sh ) )
    add_string( Center( '(сравнение по полю "Ф.И.О." + "Дата рождения")', sh ) )
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    dbCreate( cur_dir + 'tmp', { { 'fio', 'C', 50, 0 }, { 'DATE_R', 'D', 8, 0 } } )
    Use ( cur_dir + 'tmp' ) new
    Index On Upper( fio ) + DToS( date_r ) to ( cur_dir + 'tmp' )
    r_use( dir_server + 'kartotek', dir_server + 'kartoten', 'KART' )
    Set Relation To RecNo() into KART2
    Index On Upper( fio ) + DToS( date_r ) to ( cur_dir + 'tmp_kart' ) For kod > 0
    Go Top
    Do While !Eof()
      gaugeupdate( hGauge, ++curr / LastRec() )
      If Inkey() == K_ESC
        add_string( Replicate( '*', sh ) )
        add_string( Expand( 'ПОИСК ПРЕРВАН' ) )
        stat_msg( 'Поиск прерван!' )
        mybell( 1, OK )
        Exit
      Endif
      mfio := Upper( kart->fio )
      mdate_r := kart->date_r
      rec1 := RecNo()
      j1 := 0
      find ( mfio + DToS( mdate_r ) )
      Do While Upper( kart->fio ) == mfio .and. kart->date_r == mdate_r .and. !Eof()
        If kart->( RecNo() ) != rec1
          j1++
        Endif
        Skip
      Enddo
      Goto ( rec1 )
      If j1 > 0
        Select TMP
        find ( mfio + DToS( mdate_r ) )
        If !Found()
          Append Blank
          tmp->fio := mfio
          tmp->date_r := mdate_r
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          ++k
          add_string( put_val( k, 4 ) + '. ' + PadR( mfio, 44 ) + ' ' + date_8( mdate_r ) + Str( j1 + 1, 5 ) )
          Select TMPITG
          Append Blank
          TMPITG->id       := k
          TMPITG->fio      := kart->fio
          TMPITG->DATE_R   := kart->date_r
          TMPITG->kod_kart := kart->kod
          TMPITG->adres    := kart->adres
          TMPITG->pol      := kart->pol
          TMPITG->polis    := kart->polis
          TMPITG->uchast   := kart->uchast
          TMPITG->kod_vu   := kart->kod_vu
          TMPITG->snils    := Transform( kart->snils, picture_pf )
          TMPITG->DATE_PR  := kart2->date_pr
          TMPITG->MO_PR    := kart2->mo_pr
          TMPITG->kod_tf   := kart2->kod_tf
          TMPITG->kod_mis  := kart2->kod_mis
          If LastRec() % 1000 == 0
            Commit
          Endif
        Endif
      Endif
      @ MaxRow(), 1 Say lstr( curr ) Color 'W+/R'
      @ Row(), Col() Say '/' Color 'W/R'
      @ Row(), Col() Say lstr( k ) Color 'G+/R'
      Select KART
      Skip
    Enddo
  Elseif i == 2
    mpolis := Space( 17 )
    fp := FCreate( name_file )
    n_list := 1
    tek_stroke := 0
    arr_title := { ;
      '────┬─────────────────┬─────────┬──────────────────────────────────────────────────┬────────', ;
      ' NN │      Полис      │№ амб.к. │                      Ф.И.О.                      │ Дата р.', ;
      '────┴─────────────────┴─────────┴──────────────────────────────────────────────────┴────────' }
    sh := Len( arr_title[ 1 ] )
    reg_print := 5
    add_string( '' )
    add_string( Center( 'Список дублирующихся записей в картотеке', sh ) )
    add_string( Center( '(сравнение по полю "Полис")', sh ) )
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    dbCreate( cur_dir + 'tmp', { { 'POLIS', 'C', 17, 0 } } )
    Use ( cur_dir + 'tmp' ) new
    Index On polis to ( cur_dir + 'tmp' )
    r_use( dir_server + 'kartotek', dir_server + 'kartotep', 'KART' )
    Set Relation To RecNo() into KART2
    find ( '1' )
    Do While !Eof()
      gaugeupdate( hGauge, ++curr / LastRec() )
      If Inkey() == K_ESC
        add_string( Replicate( '*', sh ) )
        add_string( Expand( 'ПОИСК ПРЕРВАН' ) )
        stat_msg( 'Поиск прерван!' )
        mybell( 1, OK )
        Exit
      Endif
      If kart->kod > 0 .and. !Empty( CharRepl( '*-0', kart->polis, Space( 3 ) ) )
        mpolis := kart->polis
        mfio := kart->fio
        rec1 := RecNo()
        j1 := 0
        find ( '1' + mpolis )
        Do While kod > 0 .and. kart->polis == mpolis .and. !Eof()
          If RecNo() != rec1
            j1++
          Endif
          Skip
        Enddo
        Goto ( rec1 )
        If j1 > 0
          Select TMP
          find ( mpolis )
          If !Found()
            Append Blank
            tmp->polis := mpolis
            ++k
            j1 := 0
            Select KART
            find ( '1' + mpolis )
            Do While kod > 0 .and. kart->polis == mpolis .and. !Eof()
              If verify_ff( HH, .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              ++j1
              s := iif( j1 == 1, PadR( lstr( k ) + '.', 5 ), Space( 5 ) )
              add_string( s + mpolis + ' ' + PadR( amb_kartan( .t. ), 10 ) + ;
                PadR( kart->fio, 50 ) + ' ' + date_8( kart->date_r ) )
              Select TMPITG
              Append Blank
              TMPITG->id       := k
              TMPITG->fio      := kart->fio
              TMPITG->DATE_R   := kart->date_r
              TMPITG->kod_kart := kart->kod
              TMPITG->adres    := kart->adres
              TMPITG->pol      := kart->pol
              TMPITG->polis    := kart->polis
              TMPITG->uchast   := kart->uchast
              TMPITG->kod_vu   := kart->kod_vu
              TMPITG->snils    := Transform( kart->snils, picture_pf )
              TMPITG->DATE_PR  := kart2->date_pr
              TMPITG->MO_PR    := kart2->mo_pr
              TMPITG->kod_tf   := kart2->kod_tf
              TMPITG->kod_mis  := kart2->kod_mis
              If LastRec() % 1000 == 0
                Commit
              Endif
              Select KART
              Skip
            Enddo
            Goto ( rec1 )
          Endif
          Select KART
        Endif
      Endif
      @ MaxRow(), 1 Say lstr( curr ) Color 'W+/R'
      @ Row(), Col() Say '/' Color 'W/R'
      @ Row(), Col() Say lstr( k ) Color 'G+/R'
      Skip
    Enddo
  Elseif i == 3
    fp := FCreate( name_file )
    n_list := 1
    tek_stroke := 0
    arr_title := { ;
      '────┬──────────────┬─────────┬──────────────────────────────────────────────────┬────────', ;
      ' NN │    СНИЛС     │№ амб.к. │                      Ф.И.О.                      │ Дата р.', ;
      '────┴──────────────┴─────────┴──────────────────────────────────────────────────┴────────' }
    sh := Len( arr_title[ 1 ] )
    reg_print := 5
    add_string( '' )
    add_string( Center( 'Список дублирующихся записей в картотеке', sh ) )
    add_string( Center( '(сравнение по полю "СНИЛС")', sh ) )
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    dbCreate( cur_dir + 'tmp', { { 'SNILS', 'C', 11, 0 } } )
    Use ( cur_dir + 'tmp' ) new
    Index On snils to ( cur_dir + 'tmp' )
    r_use( dir_server + 'kartotek', dir_server + 'kartotes', 'KART' )
    Set Relation To RecNo() into KART2
    find ( '1' )
    Do While !Eof()
      gaugeupdate( hGauge, ++curr / LastRec() )
      If Inkey() == K_ESC
        add_string( Replicate( '*', sh ) )
        add_string( Expand( 'ПОИСК ПРЕРВАН' ) )
        stat_msg( 'Поиск прерван!' )
        mybell( 1, OK )
        Exit
      Endif
      If kart->kod > 0 .and. !Empty( CharRepl( '0', kart->snils, ' ' ) )
        msnils := kart->snils
        mfio := kart->fio
        rec1 := RecNo()
        j1 := 0
        find ( '1' + msnils )
        Do While kod > 0 .and. kart->snils == msnils .and. !Eof()
          If RecNo() != rec1
            j1++
          Endif
          Skip
        Enddo
        Goto ( rec1 )
        If j1 > 0
          Select TMP
          find ( msnils )
          If !Found()
            Append Blank
            tmp->snils := msnils
            ++k
            j1 := 0
            Select KART
            find ( '1' + msnils )
            Do While kod > 0 .and. kart->snils == msnils .and. !Eof()
              If verify_ff( HH, .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              ++j1
              s := iif( j1 == 1, PadR( lstr( k ) + '.', 5 ), Space( 5 ) )
              add_string( s + Transform( msnils, picture_pf ) + ' ' + PadR( amb_kartan( .t. ), 10 ) + ;
                PadR( kart->fio, 50 ) + ' ' + date_8( kart->date_r ) )
              Select TMPITG
              Append Blank
              TMPITG->id       := k
              TMPITG->fio      := kart->fio
              TMPITG->DATE_R   := kart->date_r
              TMPITG->kod_kart := kart->kod
              TMPITG->adres    := kart->adres
              TMPITG->pol      := kart->pol
              TMPITG->polis    := kart->polis
              TMPITG->uchast   := kart->uchast
              TMPITG->kod_vu   := kart->kod_vu
              TMPITG->snils    := Transform( kart->snils, picture_pf )
              TMPITG->DATE_PR  := kart2->date_pr
              TMPITG->MO_PR    := kart2->mo_pr
              TMPITG->kod_tf   := kart2->kod_tf
              TMPITG->kod_mis  := kart2->kod_mis
              If LastRec() % 1000 == 0
                Commit
              Endif
              Select KART
              Skip
            Enddo
            Goto ( rec1 )
          Endif
          Select KART
        Endif
      Endif
      @ MaxRow(), 1 Say lstr( curr ) Color 'W+/R'
      @ Row(), Col() Say '/' Color 'W/R'
      @ Row(), Col() Say lstr( k ) Color 'G+/R'
      Skip
    Enddo
  Elseif i == 4
    arr_title := { ;
      '────┬────────────────┬─────────┬──────────────────────────────────────────────────┬────────', ;
      ' NN │       ЕНП      │ № амб.к.│                     Ф.И.О.                       │ Дата р.', ;
      '────┴────────────────┴─────────┴──────────────────────────────────────────────────┴────────' }
    sh := Len( arr_title[ 1 ] )
    reg_print := 5
    fp := FCreate( name_file )
    n_list := 1
    tek_stroke := 0
    add_string( '' )
    add_string( Center( 'Список дублирующихся записей в картотеке', sh ) )
    add_string( Center( '(сравнение по полю ЕНП "Единый Номер Полиса")', sh ) )
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    dbCreate( cur_dir + 'tmp', { { 'kod_mis', 'C', 20, 0 } } )
    Use ( cur_dir + 'tmp' ) new
    Index On kod_mis to ( cur_dir + 'tmp' )
    r_use( dir_server + 'kartote_', , 'KART_' )
    r_use( dir_server + 'kartotek', , 'KART' )
    Select KART2
    Set Relation To RecNo() into KART, To RecNo() into KART_
    Index On kod_mis to ( cur_dir + 'tmp_kodmis' ) For !Empty( kod_mis ) .and. !Empty( kart->kod )
    Go Top
    Do While !Eof()
      gaugeupdate( hGauge, ++curr / LastRec() )
      If Inkey() == K_ESC
        add_string( Replicate( '*', sh ) )
        add_string( Expand( 'ПОИСК ПРЕРВАН' ) )
        stat_msg( 'Поиск прерван!' )
        mybell( 1, OK )
        Exit
      Endif
      mkod_mis := kart2->kod_mis
      mfio := kart->fio
      rec1 := RecNo()
      j1 := 0
      find ( mkod_mis )
      Do While kart2->kod_mis == mkod_mis .and. !Eof()
        If RecNo() != rec1
          j1++
        Endif
        Skip
      Enddo
      Goto ( rec1 )
      If j1 > 0
        Select TMP
        find ( mkod_mis )
        If !Found()
          Append Blank
          tmp->kod_mis := mkod_mis
          ++k
          j1 := 0
          Select KART2
          find ( mkod_mis )
          Do While kart2->kod_mis == mkod_mis .and. !Eof()
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            ++j1
            s := iif( j1 == 1, PadR( lstr( k ) + '.', 5 ), Space( 5 ) )
            add_string( s + Left( mkod_mis, 16 ) + ' ' + PadR( amb_kartan( .t. ), 10 ) + ;
              PadR( AllTrim( kart->fio ) + ' (' + AllTrim( inieditspr( A__MENUVERT, mm_vid_polis, kart_->VPOLIS ) ) + ;
              ' полис)', 50 ) + ' ' + date_8( kart->date_r ) )
            Select TMPITG
            Append Blank
            TMPITG->id       := k
            TMPITG->fio      := kart->fio
            TMPITG->DATE_R   := kart->date_r
            TMPITG->kod_kart := kart->kod
            TMPITG->adres    := kart->adres
            TMPITG->pol      := kart->pol
            TMPITG->polis    := kart->polis
            TMPITG->uchast   := kart->uchast
            TMPITG->kod_vu   := kart->kod_vu
            TMPITG->snils    := Transform( kart->snils, picture_pf )
            TMPITG->DATE_PR  := kart2->date_pr
            TMPITG->MO_PR    := kart2->mo_pr
            TMPITG->kod_tf   := kart2->kod_tf
            TMPITG->kod_mis  := kart2->kod_mis
            If LastRec() % 1000 == 0
              Commit
            Endif
            Select KART2
            Skip
          Enddo
        Endif
      Endif
      Select KART2
      Goto ( rec1 )
      @ MaxRow(), 1 Say lstr( curr ) Color 'W+/R'
      @ Row(), Col() Say '/' Color 'W/R'
      @ Row(), Col() Say lstr( k ) Color 'G+/R'
      Skip
    Enddo
  Endif
  Close databases
  FClose( fp )
  closegauge( hGauge )
  If k == 0
    func_error( 4, 'Не найдено дублирующихся записей!' )
  Else
    viewtext( name_file, , , , .t., , , reg_print )
  Endif

  Return Nil

// 18.11.18
Function f2dubl_zap()

  Local buf := SaveScreen()

  Private dubl1_kart := 0, dubl2_kart := 0, top_frm

  SetColor( color0 )
  box_shadow( 15, 2, 22, 77 )
  str_center( 17, 'В общем списке сначала отмечается человек, которому будет перенесена вся' )
  str_center( 18, 'информация из удаляемой карточки - он выделяется синим цветом.' )
  mark_keys( { 'он выделяется' }, col_tit_popup )
  mark_keys( { 'синим цветом' }, 'W+/B' )
  str_center( 19, 'Затем отмечается карточка удаляемого человека;' )
  str_center( 20, 'удаляемая запись выделяется красным цветом.' )
  mark_keys( { 'удаляемая запись выделяется' }, 'R/BG' )
  mark_keys( { 'красным цветом' }, 'W+/R' )
  runstr( 'Нажмите любую клавишу', 21, 3, 76, 'W+/BG' )
  box_shadow( 0, 2, 0, 77, color1, , , 0 )
  str_center( 0, 'Удаление дублирующихся записей в картотеке', color8 )
  If view_kart( 3 ) .and. dubl1_kart > 0 .and. dubl2_kart > 0
    mywait()
    use_base( 'kartotek' )
    // вывод на экран информации
    top_frm := 0
    Goto ( dubl1_kart )
    kartotek_to_screen( 1, 8 )
    @ 0, 0 To 9, 79 Color 'G+/B'
    str_center( 0, ' Человек, которому переносится информация ', 'G+/RB' )
    top_frm := 10
    Goto ( dubl2_kart )
    kartotek_to_screen( 11, 18 )
    @ 10, 0 To 19, 79 double Color color8
    str_center( 10, ' Человек, который удаляется ', 'GR+/R' )
    fillscrarea( 20, 0, 24, 79, '░',color1 )
    If !g_slock( 'Редактирование картотеки ' + lstr( dubl2_kart ) )
      func_error( 4, 'В данный момент с карточкой удаляемого человека работает другой пользователь.' )
    Else
      If f_esc_enter( 2, .t. )
        mywait()
        // список пациентов в реестрах будущих диспансеризаций
        /*G_Use(dir_server + 'mo_r01k', ,'R01K')
        index on str(kod_k, 7) to (cur_dir + 'tmp_r01k')
        do while .t.
          find (str(dubl2_kart, 7))
          if !found() ; exit ; endif
          G_RLock(forever)
          r01k->kod_k := dubl1_kart
        enddo
        close databases*/
        // направления на госпитализацию
        g_use( dir_server + 'mo_nnapr', , 'NAPR' )
        Index On Str( kod_k, 7 ) to ( cur_dir + 'tmp_napr' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          napr->kod_k := dubl1_kart
        Enddo
        Close databases // на всякий случай
        //
        If hb_FileExists( dir_server + 'mo_dnab' + sntx )
          use_base( 'mo_dnab' )
          Do While .t.
            find ( Str( dubl2_kart, 7 ) )
            If !Found()
              Exit
            Endif
            g_rlock( forever )
            dn->kod_k := dubl1_kart
          Enddo
          Close databases // на всякий случай
        Endif
        //
        g_use( dir_server + 'human', dir_server + 'humankk', 'HUMAN' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          human->kod_k := dubl1_kart
        Enddo
        Close databases // на всякий случай (вдруг работает задача ОМС)
        //
        g_use( dir_server + 'mo_kinos', dir_server + 'mo_kinos', 'KIS' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
        //
        g_use( dir_server + 'mo_kismo', , 'SN' )
        Index On Str( kod, 7 ) to ( cur_dir + 'tmp_ismo' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
        // платные услуги
        g_use( dir_server + 'hum_p', dir_server + 'hum_pkk', 'HUM_P' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          hum_p->kod_k := dubl1_kart
          Unlock
        Enddo
        // ортопедия
        g_use( dir_server + 'hum_ort', dir_server + 'hum_ortk', 'HUM_O' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          hum_o->kod_k := dubl1_kart
          Unlock
        Enddo
        // приемный покой
        g_use( dir_server + 'mo_pp', dir_server + 'mo_pp_r', 'HU' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          hu->kod_k := dubl1_kart
          Unlock
        Enddo
        // касса платные
        g_use( dir_server + 'kas_pl', dir_server + 'kas_pl1', 'KASP' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          kasp->kod_k := dubl1_kart
          Unlock
        Enddo
        // касса ортопедия
        g_use( dir_server + 'kas_ort', dir_server + 'kas_ort1', 'KASO' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          kaso->kod_k := dubl1_kart
          Unlock
        Enddo
        // подобие регистра застрахованных
        g_use( dir_server + 'kart_etk' )
        Index On Str( kod_k, 7 ) to ( cur_dir + 'tmp_kart_etk' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
        // примечания к картотеке
        g_use( dir_server + 'k_prim1', dir_server + 'k_prim1', 'K_PRIM1' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
        // оплата по ДМС и взаимозачету
        g_use( dir_server + 'plat_vz', , 'PVZ' )
        Index On Str( kod_k, 7 ) to ( cur_dir + 'tmp_pvz' )
        Set Index to ( cur_dir + 'tmp_pvz' ), ( dir_server + 'plat_vz' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          pvz->kod_k := dubl1_kart
          Unlock
        Enddo
        // регистрация печати л/у
        g_use( dir_server + 'mo_regi', { dir_server + 'mo_regi1', ;
          dir_server + 'mo_regi2', ;
          dir_server + 'mo_regi3' }, 'RU' )
        Set Order To 3
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          ru->kod_k := dubl1_kart
          Unlock
        Enddo
        // МСЭК
        g_use( dir_server + 'msek', dir_server + 'msek', 'MSEK' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          msek->kod_k := dubl1_kart
          Unlock
        Enddo
        // cписок карточек пациентов в отосланных ходатайствах
        g_use( dir_server + 'mo_hod_k', , 'HK' )
        Index On Str( kod_k, 7 ) to ( cur_dir + 'tmp_hk' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          hk->kod_k := dubl1_kart
          Unlock
        Enddo
        // список прикреплений по пациенту во времени
        g_use( dir_server + 'mo_kartp', dir_server + 'mo_kartp', 'KARTP' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          kartp->kod_k := dubl1_kart
          Unlock
        Enddo
        // список карточек в реестрах на прикрепление
        g_use( dir_server + 'mo_krtp', , 'KRTP' )
        Index On Str( kod_k, 7 ) to ( cur_dir + 'tmp_krtp' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          krtp->kod_k := dubl1_kart
          Unlock
        Enddo
        // список ошибок в реестрах на прикрепление
        g_use( dir_server + 'mo_krte', , 'KRTE' )
        Index On Str( kod_k, 7 ) to ( cur_dir + 'tmp_krte' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          krte->kod_k := dubl1_kart
          Unlock
        Enddo
        // список карточек в файлах на открепление
        g_use( dir_server + 'mo_krto', , 'KRTO' )
        Index On Str( kod_k, 7 ) to ( cur_dir + 'tmp_krto' )
        Do While .t.
          find ( Str( dubl2_kart, 7 ) )
          If !Found()
            Exit
          Endif
          g_rlock( forever )
          krto->kod_k := dubl1_kart
          Unlock
        Enddo
        //
        use_base( 'kartotek' )
        Set Order To 0
        Select KART
        Goto ( dubl2_kart )
        // т.к. relation
        Select KART2
        Goto ( dubl2_kart )
        If !Eof()
          deleterec( .t., .f. )  // очистка записи без пометки на удаление
        Endif
        Select KART_
        Goto ( dubl2_kart )
        If !Eof()
          deleterec( .t., .f. )  // очистка записи без пометки на удаление
        Endif
        Select KART
        Goto ( dubl2_kart )
        deleterec( .t., .f. )  // очистка записи без пометки на удаление
        Close databases
        stat_msg( 'Дублирующаяся запись удалена из картотеки!' )
        mybell( 2, OK )
      Endif
      g_sunlock( 'Редактирование картотеки ' + lstr( dubl2_kart ) )
    Endif
    Close databases
    glob_kartotek := dubl1_kart
  Endif
  RestScreen( buf )

  Return Nil

// 10.01.25
Function kartotek_to_screen( r1, r2 )

  Local i, s, s1, mmo_pr, arr := {}, tmp_select := Select()

  is_talon := .t. // пока так
  If is_uchastok > 0 .or. glob_mo[ _MO_IS_UCH ]
    s := ''
    If is_uchastok > 0
      s := 'Тип ' + kart->bukva
      s += Space( 3 ) + 'Участок ' + lstr( kart->uchast )
      If is_uchastok == 1
        s += Space( 3 ) + 'Код ' + lstr( kart->kod_vu )
      Elseif is_uchastok == 3
        s += Space( 3 ) + 'Код АК МИС ' + AllTrim( kart2->kod_AK ) + Space( 5 )
      Endif
      s += Space( 3 )
    Endif
    If glob_mo[ _MO_IS_UCH ]
      If Left( kart2->PC2, 1 ) == '1'
        mmo_pr := 'По информации из ТФОМС пациент У_М_Е_Р'
      Elseif kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ]
        mmo_pr := 'Прикреплён '
        If !Empty( kart2->pc4 )
          mmo_pr += 'с ' + AllTrim( kart2->pc4 ) + ' '
        Elseif !Empty( kart2->DATE_PR )
          mmo_pr += 'с ' + date_8( kart2->DATE_PR ) + ' '
        Endif
        mmo_pr += 'к нашей МО'
      Else
        s1 := AllTrim( inieditspr( A__MENUVERT, glob_arr_mo, kart2->mo_pr ) )
        If Empty( s1 )
          mmo_pr := 'Прикрепление --- неизвестно ---'
        Else
          mmo_pr := ''
          If !Empty( kart2->pc4 )
            mmo_pr += 'с ' + AllTrim( kart2->pc4 ) + ' '
          Elseif !Empty( kart2->DATE_PR )
            mmo_pr += 'с ' + date_8( kart2->DATE_PR ) + ' '
          Endif
          mmo_pr += 'прикреплён к ' + s1
        Endif
      Endif
      s += mmo_pr
    Endif
    AAdd( arr, s )
  Endif
  s := 'Ф.И.О.: ' + kart->fio + Space( 7 ) + iif( kart->pol == 'М', 'мужчина', 'женщина' )
  AAdd( arr, s )
  s := 'Дата рождения: ' + full_date( kart->date_r ) + Space( 5 ) + ;
    '(' + AllTrim( inieditspr( A__MENUVERT, menu_vzros, kart->vzros_reb ) ) + ')'
  If !Empty( kart->snils )
    s += Space( 5 ) + 'СНИЛС: ' + Transform( kart->SNILS, picture_pf )
  Endif
  AAdd( arr, s )
  s := inieditspr( A__MENUVERT, getvidud(), kart_->vid_ud ) + ;
    Space( 3 ) + AllTrim( kart_->ser_ud ) + ' ' + AllTrim( kart_->nom_ud )
  If !Empty( kart_->kogdavyd )
    s += ' выдан ' + full_date( kart_->kogdavyd ) + ' '
    If !Empty( kart_->kemvyd )
      s += inieditspr( A__POPUPMENU, dir_server + 's_kemvyd', kart_->KEMVYD )
    Endif
  Endif
  AAdd( arr, s )
  s := 'Место рождения: ' + AllTrim( kart_->mesto_r )
  AAdd( arr, s )
  s := 'Адрес: '
  If !emptyall( kart_->okatog, kart->adres )
    s += ret_okato_ulica( kart->adres, kart_->okatog )
  Endif
  AAdd( arr, s )
  If !emptyall( kart_->okatop, kart_->adresp )
    s := 'Адрес пребывания: ' + ret_okato_ulica( kart_->adresp, kart_->okatop )
    AAdd( arr, s )
  Endif
  s := 'Полис ОМС: '
  If !Empty( kart2->kod_mis )
    s += '(ЕНП ' + AllTrim( kart2->kod_mis ) + ') '
  Endif
  If !emptyall( kart_->beg_polis, kart->srok_polis )
    s += '('
    If !Empty( kart_->beg_polis )
      s += 'с ' + date_8( c4tod( kart_->beg_polis ) )
    Endif
    If !Empty( kart->srok_polis )
      s += ' по ' + date_8( c4tod( kart->srok_polis ) )
    Endif
    s += ') '
  Endif
  If !Empty( kart_->SPOLIS )
    s += AllTrim( kart_->SPOLIS ) + ' '
  Endif
  s += AllTrim( kart_->NPOLIS ) + ' (' + ;
    AllTrim( inieditspr( A__MENUVERT, mm_vid_polis, kart_->VPOLIS ) ) + ') ' + ;
    smo_to_screen( 1 )
  AAdd( arr, s )
  If eq_any( glob_task, X_REGIST, X_OMS, X_PLATN, X_ORTO, X_KASSA, X_PPOKOJ, X_MO )
    s := Upper( RTrim( inieditspr( A__MENUVERT, menu_rab, kart->rab_nerab ) ) )
    If kart_->PENSIONER == 1
      s += Space( 5 ) + 'пенсионер'
    Endif
    If !Empty( kart->mr_dol )
      s += ',  место работы: ' + kart->mr_dol
    Endif
    AAdd( arr, s )
  Endif
  If eq_any( glob_task, X_MO )
    If !emptyall( kart_->PHONE_H, kart_->PHONE_M, kart_->PHONE_W )
      s := 'Телефоны:'
      If !Empty( kart_->PHONE_H )
        s += ' домашний ' + kart_->PHONE_H
      Endif
      If !Empty( kart_->PHONE_M )
        s += ' мобильный ' + kart_->PHONE_M
      Endif
      If !Empty( kart_->PHONE_W )
        s += ' рабочий ' + kart_->PHONE_W
      Endif
      AAdd( arr, s )
    Endif
    If !Empty( kart_->KOD_LGOT )
      // aadd(arr, inieditspr(A__MENUVERT, glob_katl, kart_->KOD_LGOT))
      AAdd( arr, inieditspr( A__MENUVERT, getdlo_lgota(), kart_->KOD_LGOT ) )
    Endif
  Endif
  If eq_any( glob_task, X_REGIST, X_OMS, X_PPOKOJ, X_MO )
    s := ''
    If is_talon .and. kart_->kategor > 0
      s := 'Код категории льготы: ' + RTrim( inieditspr( A__MENUVERT, stm_kategor, kart_->kategor ) ) + Space( 5 )
    Endif
    If !Empty( stm_kategor2 ) .and. kart_->kategor2 > 0
      s += 'Категория МО: ' + RTrim( inieditspr( A__MENUVERT, stm_kategor2, kart_->kategor2 ) )
    Endif
    AAdd( arr, s )
  Endif
  //
  clrlines( r1, r2, color1 )
  For i := 1 To Len( arr )
    If r1 + i -1 > r2
      Exit
    Endif
    @ r1 + i -1, 1 Say arr[ i ] Color color1
  Next
  Select ( tmp_select )

  Return Nil

// 20.11.15 Подсчёт количества пациентов, прикреплённых ко всем участковым врачам
Function prn_itogo_uch_vrach()

  Local sh, HH := 60, name_file := cur_dir + 'uchvrach' + stxt, arr_title
  Local ii := 0, buf := save_maxrow(), i, j, k, fl, arr := ret_arr_uch_vrach()

  mywait()
  r_use( dir_server + 'mo_pers', , 'P2' )
  Index On snils to ( cur_dir + 'tmp_pers' ) For !Empty( snils )
  r_use_base( 'kartotek' )
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say Str( ++ii / kart->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorWait
    If kart->kod > 0 .and. !( Left( kart2->PC2, 1 ) == '1' ) ;
        .and. kart2->mo_pr == glob_MO[ _MO_KOD_TFOMS ]  // прикреплён к НАМ
      k := iif( count_years( kart->date_r, sys_date ) < 18, 2, 1 )
      If kart->uchast > 0
        fl := .f.
        For i := 1 To Len( arr )
          For j := 1 To Len( arr[ i, 5 ] )
            If arr[ i, 5, j, 1 ] == kart->uchast .and. eq_any( arr[ i, 5, j, 2 ], 0, k )
              fl := .t.
              Exit
            Endif
          Next
          If fl
            Exit
          Endif
        Next
        If !fl
          If ( i := AScan( arr, {| x| x[ 5, 1, 1 ] == kart->uchast .and. x[ 5, 1, 2 ] == k } ) ) == 0
            AAdd( arr, { 0, 0, '', Space( 11 ), { { kart->uchast, k } }, '', 0, 0, 0 } )
            i := Len( arr )
            arr[ i, 3 ] := 'не настроен врач'
            arr[ i, 6 ] += lstr( kart->uchast ) + { '(взр.)', '(дети)' }[ k ]
          Endif
        Endif
        arr[ i, 7 ] ++
      Endif
      If !Empty( kart2->SNILS_VR )
        If ( i := AScan( arr, {| x| x[ 4 ] == kart2->SNILS_VR } ) ) == 0
          AAdd( arr, { 0, 0, '', kart2->snils_vr, { { 0, 0 } }, '--', 0, 0, 0 } )
          i := Len( arr )
          Select P2
          find ( kart2->snils_vr )
          If Found()
            arr[ i, 1 ] := p2->kod
            arr[ i, 2 ] := p2->tab_nom
            arr[ i, 3 ] := RTrim( p2->fio )
          Else
            arr[ i, 3 ] := 'Не наш врач СНИЛС ' + Transform( kart2->snils_vr, picture_pf )
          Endif
        Endif
        arr[ i, 8 ] ++
      Endif
    Endif
    Select KART
    Skip
  Enddo
  Use ( dir_server + 'kart_etk' ) new
  Index On Str( kod_tf, 10 ) to ( cur_dir + 'tmp_kart_etk' )
  r_use( dir_server + 'kart_et' )
  Index On Str( kod_tf, 10 ) to ( cur_dir + 'tmp_kart_et' ) ;
    For mo_pr == glob_MO[ _MO_KOD_TFOMS ] .and. !Empty( snils_vr ) .and. !( kart_et->PC2 == '1' )
  Go Top
  Do While !Eof()
    Select KART_ETK
    find ( Str( kart_et->kod_tf, 10 ) )
    If Found() .and. kart_etk->kod_k > 0
      Select KART
      Goto ( kart_etk->kod_k )
      If kart->kod > 0
        k := iif( count_years( kart->date_r, sys_date ) < 18, 2, 1 )
        If ( i := AScan( arr, {| x| x[ 4 ] == kart_et->SNILS_VR } ) ) == 0
          AAdd( arr, { 0, 0, '', kart_et->snils_vr, { { 0, 0 } }, '--', 0, 0, 0 } )
          i := Len( arr )
          Select P2
          find ( kart_et->snils_vr )
          If Found()
            arr[ i, 1 ] := p2->kod
            arr[ i, 2 ] := p2->tab_nom
            arr[ i, 3 ] := RTrim( p2->fio )
          Else
            arr[ i, 3 ] := 'Не наш врач СНИЛС ' + Transform( kart_et->snils_vr, picture_pf )
          Endif
        Endif
        arr[ i, 9 ] ++
      Endif
    Endif
    Select KART_ET
    Skip
  Enddo
  Close databases
  ASort( arr, , , {| x, y| iif( x[ 5, 1, 1 ] == y[ 5, 1, 1 ], x[ 5, 1, 2 ] < y[ 5, 1, 2 ], x[ 5, 1, 1 ] < y[ 5, 1, 1 ] ) } )
  rest_box( buf )
  arr_title := { ;
    '──────┬─────┬───────────────────────────────────────────┬──────────────────────', ;
    'кол-во│таб.№│ ФИО участкового врача                     │ №№ участка           ', ;
    '──────┴─────┴───────────────────────────────────────────┴──────────────────────' }
  fp := FCreate( name_file )
  tek_stroke := 0
  n_list := 1
  sh := Len( arr_title[ 1 ] )
  add_string( '' )
  add_string( Center( 'Количество пациентов, прикреплённых к участковым врачам', sh ) )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  add_string( Center( '[ по сведениям ТФОМС ]', sh ) )
  For i := 1 To Len( arr )
    If !Empty( arr[ i, 8 ] )
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( put_val( arr[ i, 8 ], 6 ) + put_val( arr[ i, 2 ], 6 ) + ' ' + ;
        PadR( arr[ i, 3 ], 43 ) + ' ' + arr[ i, 6 ] )
    Endif
  Next
  If verify_ff( HH -3, .t., sh )
    AEval( arr_title, {| x| add_string( x ) } )
  Endif
  add_string( '' )
  add_string( Center( '[ по сведениям ТФОМС + учитыая PID пациента ]', sh ) )
  For i := 1 To Len( arr )
    If !Empty( arr[ i, 8 ] )
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( put_val( arr[ i, 9 ], 6 ) + put_val( arr[ i, 2 ], 6 ) + ' ' + ;
        PadR( arr[ i, 3 ], 43 ) + ' ' + arr[ i, 6 ] )
    Endif
  Next
  If verify_ff( HH -3, .t., sh )
    AEval( arr_title, {| x| add_string( x ) } )
  Endif
  add_string( '' )
  add_string( Center( '[ по номерам участков в картотеке ]', sh ) )
  For i := 1 To Len( arr )
    If !Empty( arr[ i, 7 ] )
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( put_val( arr[ i, 7 ], 6 ) + put_val( arr[ i, 2 ], 6 ) + ' ' + ;
        PadR( arr[ i, 3 ], 43 ) + ' ' + arr[ i, 6 ] )
    Endif
  Next
  FClose( fp )
  viewtext( name_file, , , , .t., , , 2 )

  Return Nil

// 28.09.15 вернуть массив участковых врачей
Function ret_arr_uch_vrach()

  Local i, j, ar, arr := {}

  r_use( dir_server + 'mo_pers', , 'P2' )
  r_use( dir_server + 'mo_uchvr', , 'UV' )
  Go Top
  Do While !Eof()
    If Between( uv->uch, 1, 99 )
      If uv->vrach > 0
        f1_ret_arr_uch_vrach( arr, uv->vrach, 0, uv->uch )
      Else
        If uv->vrachv > 0
          f1_ret_arr_uch_vrach( arr, uv->vrachv, 1, uv->uch )
        Endif
        If uv->vrachd > 0
          f1_ret_arr_uch_vrach( arr, uv->vrachd, 2, uv->uch )
        Endif
      Endif
    Endif
    Select UV
    Skip
  Enddo
  Close databases
  For i := 1 To Len( arr )
    ar := AClone( arr[ i, 5 ] )
    ASort( ar, , , {| x, y| iif( x[ 1 ] == y[ 1 ], x[ 2 ] < y[ 2 ], x[ 1 ] < y[ 1 ] ) } )
    For j := 1 To Len( ar )
      arr[ i, 6 ] += lstr( ar[ j, 1 ] )
      If ar[ j, 2 ] > 0
        arr[ i, 6 ] += { '(взр.)', '(дети)' }[ ar[ j, 2 ] ]
      Endif
      arr[ i, 6 ] += ', '
    Next
    arr[ i, 6 ] := Left( arr[ i, 6 ], Len( arr[ i, 6 ] ) -2 )
  Next

  Return arr

// 19.07.23
Function f1_ret_arr_uch_vrach( arr, lkod, k, luch )

  Local i

  Select P2
  Goto ( lkod )
  If ( i := AScan( arr, {| x| x[ 1 ] == lkod } ) ) == 0
    AAdd( arr, { lkod, p2->tab_nom, RTrim( p2->fio ), p2->snils, {}, '', 0, 0, 0 } )
    i := Len( arr )
  Endif
  AAdd( arr[ i, 5 ], { luch, k } )

  Return Nil
