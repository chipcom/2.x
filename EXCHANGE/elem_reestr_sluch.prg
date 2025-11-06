// реестры пацентов
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 06.11.25
Function elem_reestr_sluch( oXmlDoc, p_tip_reestr, _nyear  )

  Local oZAP
  Local oSL, oSLUCH
  Local oPRESCRIPTION, oPRESCRIPTIONS, oNAPR, oCONS
  Local oONK_SL, oDIAG, oPROT, oONK
  Local oUSL
  Local oPAC

  Local fl, lshifr1
  Local i, j
  Local reserveKSG_ID_C := '' // GUID для вложенных двойных случаев
  Local endDateZK
  Local diagnoz_replace := ''
  Local flLekPreparat
  Local lReplaceDiagnose := .f.
  Local lTypeLUOnkoDisp := .f.  // флаг листа учета постановки на диспансерное наблюдение онкобольных
  Local dPUMPver40 := 0d20240301
  Local mnovor
  Local kol_sl, isl
  Local is_oncology_smp, is_oncology, arr_onkna, arr_onkco, arr_onksl, arr_onkdi, arr_onkpr, arr_onk_usl
  Local mdiagnoz, mdiagnoz3
  Local cSMOname
  Local adiag_talon[ 16 ], tmpSelect
  Local a_fusl
  Local laluslf, lal
  Local s, sCOMENTSL
  local ar_dn

//  Local iAKSLP, tKSLP, cKSLP // счетчик для цикла по КСЛП
//  Local oKSG, oSLk, oMR_USL_N, oDISAB, fl_DISABILITY := .f.
//  Local oLEK, oDOSE, oMED_DEV, oINJ
//  Local arrLP, row
//  Local old_lek, old_sh
//  Local aRegnum, iLekPr

  Private is_zak_sl, is_zak_sl_vr
  Private lshifr_zak_sl //  , lvidpoms
  Private a_usl
  Private a_usl_name
  Private lvidpom
  Private lfor_pom
  Private akslp
  Private akiro
  Private is_KSG, is_mgi
  Private kol_kd, v_reabil_slux, m1veteran, m1mobilbr  // мобильная бригада
  Private tarif_zak_sl, m1mesto_prov, m1p_otk    // признак отказа
  Private m1dopo_na, m1napr_v_mo
  Private arr_mo_spec
  Private m1napr_stac
  Private m1profil_stac, m1napr_reab, m1profil_kojki
  Private pr_amb_reab, fl_disp_nabl, is_disp_DVN, is_disp_DVN_COVID, is_disp_DRZ
  Private ldate_next
  Private a_otkaz
  Private arr_nazn
  Private arr_ne_vozm
  Private mtab_v_dopo_na, mtab_v_mo, mtab_v_stac, mtab_v_reab, mtab_v_sanat
  Private arr_usl_otkaz
//  Private atmpusl
//  Private ar_dn

  flLekPreparat := .f.

  laluslf := create_name_alias( 'luslf', _nyear )

  //
  Select HUMAN
  Goto ( rhum->kod_hum )  // встали на 2-ой лист учёта
  kol_sl := iif( human->ishod == 89, 2, 1 )
  ksl_date := nil
  For isl := 1 To kol_sl

    a_fusl := {}
    ar_dn := {}
    a_usl := {} // для корректной работы с двойным сдучаем
    is_zak_sl := is_zak_sl_vr := .f.
    lshifr_zak_sl := '' //  lvidpoms := ''
    a_usl_name := {}
    lvidpom := 1
    lfor_pom := 3
    akslp := {}
    akiro := {}
    is_KSG := is_mgi := .f.
    kol_kd := v_reabil_slux := m1veteran := m1mobilbr := 0  // мобильная бригада
    tarif_zak_sl := m1mesto_prov := m1p_otk := 0    // признак отказа
    m1dopo_na := m1napr_v_mo := 0
    arr_mo_spec := {}
    m1napr_stac := 0
    m1profil_stac := m1napr_reab := m1profil_kojki := 0
    pr_amb_reab := fl_disp_nabl := is_disp_DVN := is_disp_DVN_COVID := is_disp_DRZ := .f.
    ldate_next := CToD( '' )
    a_otkaz := {}
    arr_nazn := {}
    arr_ne_vozm := {}
    mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0
//    atmpusl := {}

    If isl == 1 .and. kol_sl == 2
      Select HUMAN_3
      ksl_date := human_3->K_DATA
      find ( Str( rhum->kod_hum, 7 ) )
      reserveKSG_ID_C := human_3->ID_C
      Select HUMAN
      Goto ( human_3->kod )  // встали на 1-й лист учёта
    Endif
    If isl == 2
      Select HUMAN
      ksl_date := human_3->K_DATA
      Goto ( human_3->kod2 )  // встали на 2-ой лист учёта
    Endif
    is_oncology := schet_is_oncology( p_tip_reestr, @is_oncology_smp )
    If is_oncology > 0
      arr_onkna := collect_schet_onkna()
      arr_onkco := collect_schet_onkco()
      arr_onksl := collect_schet_onksl()
      arr_onkdi := collect_schet_onkdi()
      arr_onkpr := collect_schet_onkpr()
      arr_onk_usl := collect_schet_onkusl()
    Else
      arr_onkna := {}
      arr_onkco := {}
      arr_onksl := {}
      arr_onkdi := {}
      arr_onkpr := {}
      arr_onk_usl := {}
    Endif

    mdiagnoz := diag_for_xml( , .t., , , .t. )
    If p_tip_reestr == TYPE_REESTR_DISPASER
      If human->OBRASHEN == '1' .and. AScan( mdiagnoz, {| x| PadR( x, 5 ) == 'Z03.1' } ) == 0
        AAdd( mdiagnoz, 'Z03.1' )
      Endif
    Endif

    mdiagnoz3 := {}
    If !Empty( human_2->OSL1 )
      AAdd( mdiagnoz3, human_2->OSL1 )
    Endif
    If !Empty( human_2->OSL2 )
      AAdd( mdiagnoz3, human_2->OSL2 )
    Endif
    If !Empty( human_2->OSL3 )
      AAdd( mdiagnoz3, human_2->OSL3 )
    Endif
    cSMOname := schet_smoname()

    AFill( adiag_talon, 0 )
    For i := 1 To 16
      adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
    Next

    tmpSelect := Select()
    dbSelectArea( 'MOHU' )
    mohu->( dbSeek( Str( human->kod, 7 ) ) )
    Do While mohu->kod == human->kod .and. ! mohu->( Eof() )
      AAdd( a_fusl, mohu->( RecNo() ) )
      mohu->( dbSkip() )
    Enddo
    Select( tmpSelect )


    f1_create2reestr19( _nyear, p_tip_reestr )
    // заполним реестр записями для XML-документа
    If isl == 1
      oZAP := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZAP' ) )
      mo_add_xml_stroke( oZAP, 'N_ZAP', lstr( rhum->REES_ZAP ) )
      mo_add_xml_stroke( oZAP, 'PR_NOV', iif( human_->SCHET_NUM > 0, '1', '0' ) ) // если попал в счёт 2-й раз и т.д.

      // заполним сведения о пациенте для XML-документа
      oPAC := oZAP:add( hxmlnode():new( 'PACIENT' ) )
      mo_add_xml_stroke( oPAC, 'ID_PAC', human_->ID_PAC )
      mo_add_xml_stroke( oPAC, 'VPOLIS', lstr( human_->VPOLIS ) )
      If !Empty( human_->SPOLIS )
        mo_add_xml_stroke( oPAC, 'SPOLIS', human_->SPOLIS )
      Endif
      mo_add_xml_stroke( oPAC, 'NPOLIS', human_->NPOLIS )
      If Len( AllTrim( kart2->kod_mis ) ) == 16
        mo_add_xml_stroke( oPAC, 'ENP', kart2->kod_mis ) // Единый номер полиса единого образца
      Endif
      // mo_add_xml_stroke(oPAC, 'ST_OKATO' ,...) // Регион страхования
      If Empty( cSMOname )
        mo_add_xml_stroke( oPAC, 'SMO', human_->smo )
      Endif
      mo_add_xml_stroke( oPAC, 'SMO_OK', iif( Empty( human_->OKATO ), '18000', human_->OKATO ) )
      If !Empty( cSMOname )
        mo_add_xml_stroke( oPAC, 'SMO_NAM', cSMOname )
      Endif
      If human_->NOVOR == 0
        mo_add_xml_stroke( oPAC, 'NOVOR', '0' )
      Else
        mnovor := iif( human_->pol2 == 'М', '1', '2' ) + ;
          StrZero( Day( human_->DATE_R2 ), 2 ) + ;
          StrZero( Month( human_->DATE_R2 ), 2 ) + ;
          Right( lstr( Year( human_->DATE_R2 ) ), 2 ) + ;
          StrZero( human_->NOVOR, 2 )
        mo_add_xml_stroke( oPAC, 'NOVOR', mnovor )
      Endif
      If human_->USL_OK == USL_OK_HOSPITAL .and. human_2->VNR > 0
        // стационар + л/у на недоношенного ребёнка
        mo_add_xml_stroke( oPAC, 'VNOV_D', lstr( human_2->VNR ) )
      Endif

//      If ( p_tip_reestr == 1 )
        If ( kol_sl == 1 .and. ( human->k_data >= 0d20250101 ) ) ;  // одинарный случай
          .or. ( kol_sl == 2 .and. ( ksl_date >= 0d20250101 ) )   // двойной случай
          mo_add_xml_stroke( oPAC, 'SOC', iif( Empty( kart->pc3 ), '000', kart->pc3 ) )
        Endif
//      Endif

      // mo_add_xml_stroke(oPAC, 'MO_PR', ???)
      if p_tip_reestr == TYPE_REESTR_GENERAL .and. ;                    // реестр окоазания мед. помощи за исключенем диспансеризации
          human_->USL_OK == USL_OK_POLYCLINIC .and. ; // поликлиника
          glob_mo[ _MO_IS_UCH ] .and. ;               // наше МО имеет прикреплённое население
          kart2->MO_PR == glob_MO[ _MO_KOD_TFOMS ]    // прикреплён к нашему МО
        elem_disability( oPac )
      endif
/*
      fl_DISABILITY := is_disability( p_tip_reestr )

      If fl_DISABILITY // Сведения о первичном признании застрахованного лица инвалидом
        // заполним сведения об инвалидности пациента для XML-документа
        oDISAB := oPAC:add( hxmlnode():new( 'DISABILITY' ) )
        // группа инвалидности при первичном признании застрахованного лица инвалидом
        mo_add_xml_stroke( oDISAB, 'INV', lstr( kart_->invalid ) )
        // Дата первичного установления инвалидности
        mo_add_xml_stroke( oDISAB, 'DATA_INV', date2xml( inv->DATE_INV ) )
        // Код причины установления  инвалидности
        mo_add_xml_stroke( oDISAB, 'REASON_INV', lstr( inv->PRICH_INV ) )
        If !Empty( inv->DIAG_INV ) // Код основного заболевания по МКБ-10
          mo_add_xml_stroke( oDISAB, 'DS_INV', inv->DIAG_INV )
        Endif
      Endif
*/
/*
      If ( p_tip_reestr == TYPE_REESTR_DISPASER ) .and. ( human->k_data >= 0d20250101 )
        mo_add_xml_stroke( oPAC, 'SOC', iif( Empty( kart->pc3 ), '000', kart->pc3 ) )
      Endif
*/
      // заполним сведения о законченном случае оказания медицинской помощи для XML-документа
      oSLUCH := oZAP:add( hxmlnode():new( 'Z_SL' ) )
      mo_add_xml_stroke( oSLUCH, 'IDCASE', lstr( rhum->REES_ZAP ) )

      If ! Empty( reserveKSG_ID_C ) // проверим GUID для вложенного двойного случая
        mo_add_xml_stroke( oSLUCH, 'ID_C', reserveKSG_ID_C )
        reserveKSG_ID_C := ''
      Else
        mo_add_xml_stroke( oSLUCH, 'ID_C', human_->ID_C )
      Endif

      If p_tip_reestr == TYPE_REESTR_DISPASER  // для реестров по диспансеризации
        s := Space( 3 )
        ret_tip_lu( @s )
        If !Empty( s )
          mo_add_xml_stroke( oSLUCH, 'DISP', s ) // Тип диспансеризации
        Endif
      Endif
      mo_add_xml_stroke( oSLUCH, 'USL_OK', lstr( human_->USL_OK ) )
      If lTypeLUOnkoDisp
        mo_add_xml_stroke( oSLUCH, 'VIDPOM', '13' )
      Else
        mo_add_xml_stroke( oSLUCH, 'VIDPOM', lstr( lvidpom ) )
      Endif
      If p_tip_reestr == TYPE_REESTR_GENERAL
        lal := iif( kol_sl == 2, 'human_3', 'human_' )
        mo_add_xml_stroke( oSLUCH, 'ISHOD', lstr( &lal.->ISHOD_NEW ) )
        If kol_sl == 2
          mo_add_xml_stroke( oSLUCH, 'VB_P', '1' ) // Признак внутрибольничного перевода при оплате законченного случая как суммы стоимостей пребывания пациента в разных профильных отделениях, каждое из которых оплачивается по КСГ
        Endif
        mo_add_xml_stroke( oSLUCH, 'IDSP', lstr( human_->IDSP ) )
        lal := iif( kol_sl == 2, 'human_3', 'human' )
        mo_add_xml_stroke( oSLUCH, 'SUMV', lstr( &lal.->cena_1, 10, 2 ) )
        Do Case
        Case human_->USL_OK == USL_OK_HOSPITAL // стационар
          i := iif( Left( human_->FORMA14, 1 ) == '1', 1, 3 )
        Case human_->USL_OK == USL_OK_DAY_HOSPITAL // дневной стационар
          i := iif( Left( human_->FORMA14, 1 ) == '2', 2, 3 )
        Case human_->USL_OK == USL_OK_AMBULANCE // скорая помощь
          i := iif( Left( human_->FORMA14, 1 ) == '1', 1, 2 )
        Otherwise
          i := lfor_pom
        Endcase
        mo_add_xml_stroke( oSLUCH, 'FOR_POM', lstr( i ) ) // 1 - экстренная, 2 - неотложная, 3 - плановая
        If !Empty( human_->NPR_MO ) .and. !Empty( mNPR_MO := ret_mo( human_->NPR_MO )[ _MO_KOD_FFOMS ] )
          mo_add_xml_stroke( oSLUCH, 'NPR_MO', mNPR_MO )
          s := iif( Empty( human_2->NPR_DATE ), human->N_DATA, human_2->NPR_DATE )
          mo_add_xml_stroke( oSLUCH, 'NPR_DATE', date2xml( s ) )
        Endif
        mo_add_xml_stroke( oSLUCH, 'LPU', CODE_LPU )
      Else  // для реестров по диспансеризации
        mo_add_xml_stroke( oSLUCH, 'FOR_POM', '3' ) // 3 - плановая
        mo_add_xml_stroke( oSLUCH, 'LPU', CODE_LPU )
        mo_add_xml_stroke( oSLUCH, 'VBR', iif( m1mobilbr == 0, '0', '1' ) )
        If eq_any( human->ishod, 301, 302, 203 )
          s := '2.1' // Медицинский осмотр
        Else
          s := '2.2' // Диспансеризация
        Endif
        mo_add_xml_stroke( oSLUCH, 'P_CEL', s )
        mo_add_xml_stroke( oSLUCH, 'P_OTK', iif( m1p_otk == 0, '0', '1' ) ) // Признак отказа
      Endif
      lal := iif( kol_sl == 2, 'human_3', 'human' )
      mo_add_xml_stroke( oSLUCH, 'DATE_Z_1', date2xml( &lal.->N_DATA ) )
      mo_add_xml_stroke( oSLUCH, 'DATE_Z_2', date2xml( &lal.->K_DATA ) )

      endDateZK := &lal.->K_DATA

      If p_tip_reestr == TYPE_REESTR_GENERAL
        If kol_sl == 2
          mo_add_xml_stroke( oSLUCH, 'KD_Z', lstr( human_3->k_data - human_3->n_data ) ) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
        Elseif kol_kd > 0
          mo_add_xml_stroke( oSLUCH, 'KD_Z', lstr( kol_kd ) ) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
        Endif
      Endif
      If human_->USL_OK == USL_OK_HOSPITAL // стационар
        // вес недоношенных детей для л/у матери
        lal := iif( kol_sl == 2, 'human_3', 'human_2' )
        if &lal.->VNR1 > 0
          mo_add_xml_stroke( oSLUCH, 'VNOV_M', lstr( &lal.->VNR1 ) )
        Endif
        if &lal.->VNR2 > 0
          mo_add_xml_stroke( oSLUCH, 'VNOV_M', lstr( &lal.->VNR2 ) )
        Endif
        if &lal.->VNR3 > 0
          mo_add_xml_stroke( oSLUCH, 'VNOV_M', lstr( &lal.->VNR3 ) )
        Endif
      Endif
      lal := iif( kol_sl == 2, 'human_3', 'human_' )
      mo_add_xml_stroke( oSLUCH, 'RSLT', lstr( &lal.->RSLT_NEW ) )
      If p_tip_reestr == TYPE_REESTR_GENERAL
        If human_2->PN6 == 1
          mo_add_xml_stroke( oSLUCH, 'MSE', '1' )
        Endif
      Else    // для реестров по диспансеризации
        mo_add_xml_stroke( oSLUCH, 'ISHOD', lstr( human_->ISHOD_NEW ) )
        mo_add_xml_stroke( oSLUCH, 'IDSP', lstr( human_->IDSP ) )
        mo_add_xml_stroke( oSLUCH, 'SUMV', lstr( human->cena_1, 10, 2 ) )
      Endif
    Endif // окончание тегов ZAP + PACIENT + Z_SL

    // заполним сведения о случае оказания медицинской помощи для XML-документа
    oSL := oSLUCH:add( hxmlnode():new( 'SL' ) )
    mo_add_xml_stroke( oSL, 'SL_ID', human_->ID_C )
    If ( is_vmp := human_->USL_OK == USL_OK_HOSPITAL .and. human_2->VMP == 1 ;// ВМП
      .and. !emptyany( human_2->VIDVMP, human_2->METVMP ) )
      mo_add_xml_stroke( oSL, 'VID_HMP', human_2->VIDVMP )
      mo_add_xml_stroke( oSL, 'METOD_HMP', lstr( human_2->METVMP ) )
    Endif
    otd->( dbGoto( human->OTD ) )
    If human_->USL_OK == USL_OK_HOSPITAL .and. is_otd_dep .and. ( ! disable_podrazdelenie_tfoms( human->K_DATA ) )
      f_put_glob_podr( human_->USL_OK, human->K_DATA ) // заполнить код подразделения
      If ( i := AScan( mm_otd_dep, {| x| x[ 2 ] == glob_otd_dep } ) ) == 0
        i := 1
      Endif
      mo_add_xml_stroke( oSL, 'LPU_1', lstr( mm_otd_dep[ i, 3 ] ) )
      mo_add_xml_stroke( oSL, 'PODR', lstr( glob_otd_dep ) )
    Endif
    mo_add_xml_stroke( oSL, 'PROFIL', lstr( human_->PROFIL ) )
    If p_tip_reestr == TYPE_REESTR_GENERAL
      If human_->USL_OK < 3 // стационар или дневной стационар
        mo_add_xml_stroke( oSL, 'PROFIL_K', lstr( human_2->PROFIL_K ) )
      Endif
      mo_add_xml_stroke( oSL, 'DET', iif( human->VZROS_REB == 0, '0', '1' ) )
      If human_->USL_OK == USL_OK_POLYCLINIC
        If ( s := get_idpc_from_v025_by_number( human_->povod ) ) == ''
          s := '2.6'
        Endif
        If lTypeLUOnkoDisp
          s := '1.3'
        Endif
        If ( AScan( a_usl_name, '2.80.67' ) > 0 ) .or. ( AScan( a_usl_name, '2.88.14' ) > 0 )
          s := '1.0'
          If human->K_DATA >= 0d20250401 .and. ( AScan( a_usl_name, '2.80.67' ) > 0 ) // письмо Мызгин А.В. от 14.04.25
            s := '1.1'
          Endif
        Endif
          if ( ascan( a_usl_name, '2.76.100' ) > 0 ) .or. ( ascan( a_usl_name, '2.76.101' ) > 0 ) .or. ( ascan( a_usl_name, '2.76.102' ) > 0 ) .or. ;
              ( ascan( a_usl_name, '2.76.103' ) > 0 ) .or. ( ascan( a_usl_name, '2.76.104' ) > 0 )
          s := '2.7'
        Endif
        mo_add_xml_stroke( oSL, 'P_CEL', s )
      Endif
    Endif
    If is_vmp
      mo_add_xml_stroke( oSL, 'TAL_D', date2xml( human_2->TAL_D ) ) // Дата выдачи талона на ВМП
      mo_add_xml_stroke( oSL, 'TAL_P', date2xml( human_2->TAL_P ) ) // Дата планируемой госпитализации в соответствии с талоном на ВМП
      mo_add_xml_stroke( oSL, 'TAL_NUM', human_2->TAL_NUM ) // номер талона на ВМП
    Endif
    mo_add_xml_stroke( oSL, 'NHISTORY', iif( Empty( human->UCH_DOC ), lstr( human->kod ), human->UCH_DOC ) )

    If !is_vmp .and. eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
      mo_add_xml_stroke( oSL, 'P_PER', lstr( human_2->P_PER ) ) // Признак поступления/перевода
    Endif
    mo_add_xml_stroke( oSL, 'DATE_1', date2xml( human->N_DATA ) )
    mo_add_xml_stroke( oSL, 'DATE_2', date2xml( human->K_DATA ) )
    If p_tip_reestr == TYPE_REESTR_GENERAL
      If kol_kd > 0
        mo_add_xml_stroke( oSL, 'KD', lstr( kol_kd ) ) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
      Endif

      If ! Empty( human_2->PC4 ) .and. Year( human->K_DATA ) > 2021
        mo_add_xml_stroke( oSL, 'WEI', AllTrim( human_2->PC4 ) )
      Endif

      If !Empty( human_->kod_diag0 )
        mo_add_xml_stroke( oSL, 'DS0', human_->kod_diag0 )
      Endif
    Endif
    // подменим диагноз если необходимо для генно-инженерных препаратов или
    // операции по поводу грыж, взрослые (уровень 4), для случаев проведения
    // антимикробной терапии инфекций, вызванных полирезистентными микроорганизмами,
    // проведение иммунизации против респираторно-синцитиальной вирусной инфекции
    lReplaceDiagnose := .f.
    If endDateZK >= 0d20220101 .and. diagnosis_for_replacement( mdiagnoz[ 1 ], human_->USL_OK, kol_sl == 2 )
      mdiagnoz[ 1 ] := mdiagnoz[ 2 ]
      diagnoz_replace := mdiagnoz[ 2 ]
      mdiagnoz[ 2 ] := ''
      lReplaceDiagnose := .t.
    Endif
    mo_add_xml_stroke( oSL, 'DS1', RTrim( mdiagnoz[ 1 ] ) )
    If p_tip_reestr == TYPE_REESTR_DISPASER  // для реестров по диспансеризации
      s := 3 // не подлежит диспансерному наблюдению
      If adiag_talon[ 1 ] == 1 // впервые
        mo_add_xml_stroke( oSL, 'DS1_PR', '1' ) // Признак первичного установления  диагноза
        If adiag_talon[ 2 ] == 2
          s := 2 // взят на диспансерное наблюдение
        Endif
      Elseif adiag_talon[ 1 ] == 2 // ранее
        If adiag_talon[ 2 ] == 1
          s := 1 // состоит на диспансерном наблюдении
        Elseif adiag_talon[ 2 ] == 2
          s := 2 // взят на диспансерное наблюдение
        Endif
      Endif
      mo_add_xml_stroke( oSL, 'PR_D_N', lstr( s ) )
      If ( is_disp_DVN .or. is_disp_DVN_COVID .or. is_disp_DRZ ) .and. s == 2 // взят на диспансерное наблюдение
        AAdd( ar_dn, { '2', RTrim( mdiagnoz[ 1 ] ), '', '' } )
      Endif
    Endif
    If p_tip_reestr == TYPE_REESTR_GENERAL
      For i := 2 To Len( mdiagnoz )
        If !Empty( mdiagnoz[ i ] )
          mo_add_xml_stroke( oSL, 'DS2', RTrim( mdiagnoz[ i ] ) )
        Endif
      Next
      For i := 1 To Len( mdiagnoz3 ) // ЕЩЁ ДИАГНОЗы ОСЛОЖНЕНИЯ ЗАБОЛЕВАНИЯ
        If !Empty( mdiagnoz3[ i ] )
          mo_add_xml_stroke( oSL, 'DS3', RTrim( mdiagnoz3[ i ] ) )
        Endif
      Next
      If need_reestr_c_zab_2025( is_oncology, human_->USL_OK, mdiagnoz[ 1 ] ) .or. is_oncology_smp > 0
        If lTypeLUOnkoDisp
          // mo_add_xml_stroke( oSL, 'C_ZAB', '2' ) //
          mo_add_xml_stroke( oSL, 'C_ZAB', '3' ) // согласно разговора с Антоновой 23.10.24
        Else
          If human_->USL_OK == USL_OK_POLYCLINIC .and. human_->povod == 4 // если P_CEL=1.3
            // mo_add_xml_stroke( oSL, 'C_ZAB', '2' ) // При диспансерном наблюдении характер заболевания не может быть <Острое>
            mo_add_xml_stroke( oSL, 'C_ZAB', '3' ) // согласно разговора с Антоновой 23.10.24
          Else
            mo_add_xml_stroke( oSL, 'C_ZAB', '1' ) // Характер основного заболевания
          Endif
        Endif
      Endif
      If human_->USL_OK < 4 // все кроме скорой помощи
        i := 0
        If human->OBRASHEN == '1' .and. is_oncology < 2
          i := 1
        Endif
        mo_add_xml_stroke( oSL, 'DS_ONK', lstr( i ) )
      Else
        mo_add_xml_stroke( oSL, 'DS_ONK', '0' )
      Endif
      If human_->USL_OK == USL_OK_POLYCLINIC .and. human_->povod == 4 // Обязательно, если P_CEL=1.3
        s := 1 // состоит
        If adiag_talon[ 1 ] == 2 // ранее
          If adiag_talon[ 2 ] == 1
            s := 1 // состоит
          Elseif adiag_talon[ 2 ] == 2
            s := 2 // взят
          Elseif adiag_talon[ 2 ] == 3 // снят
            s := 4 // снят по причине выздоровления
          Elseif adiag_talon[ 2 ] == 4 // снят
            s := 4 // снят по причине выздоровления
          Elseif adiag_talon[ 2 ] == 6
            // Elseif adiag_talon[ 2 ] == 4
            s := 6 // снят по другим причинам
          Endif
        Endif
        mo_add_xml_stroke( oSL, 'DN', lstr( s ) )
      Elseif lTypeLUOnkoDisp
        s := 2 // взят
        mo_add_xml_stroke( oSL, 'DN', lstr( s ) )
      Endif
    Else   // для реестров по диспансеризации
      For i := 2 To Len( mdiagnoz )
        If !Empty( mdiagnoz[ i ] )
          oDiag := oSL:add( hxmlnode():new( 'DS2_N' ) )
          mo_add_xml_stroke( oDiag, 'DS2', RTrim( mdiagnoz[ i ] ) )
          s := 3 // не подлежит диспансерному наблюдению
          If adiag_talon[ i * 2 -1 ] == 1 // впервые
            mo_add_xml_stroke( oDiag, 'DS2_PR', '1' )
            If adiag_talon[ i * 2 ] == 2
              s := 2 // взят на диспансерное наблюдение
            Endif
          Elseif adiag_talon[ i * 2 -1 ] == 2 // ранее
            If adiag_talon[ i * 2 ] == 1
              s := 1 // состоит на диспансерном наблюдении
            Elseif adiag_talon[ i * 2 ] == 2
              s := 2 // взят на диспансерное наблюдение
            Endif
          Endif
          mo_add_xml_stroke( oDiag, 'PR_D', lstr( s ) )
          If ( is_disp_DVN .or. is_disp_DVN_COVID .or. is_disp_DRZ ) .and. s == 2 // взят на диспансерное наблюдение
            AAdd( ar_dn, { '2', RTrim( mdiagnoz[ i ] ), '', '' } )
          Endif
        Endif
      Next
      i := iif( human->OBRASHEN == '1', 1, 0 )
      mo_add_xml_stroke( oSL, 'DS_ONK', lstr( i ) )
      If Len( arr_nazn ) > 0 .or. ( human->OBRASHEN == '1' .and. Len( arr_onkna ) > 0 )
        // заполним сведения о назначениях по результатам диспансеризации для XML-документа
        oPRESCRIPTION := oSL:add( hxmlnode():new( 'PRESCRIPTION' ) )
        For j := 1 To Len( arr_nazn )
          oPRESCRIPTIONS := oPRESCRIPTION:add( hxmlnode():new( 'PRESCRIPTIONS' ) )
          mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_N', lstr( j ) )
          mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_R', lstr( arr_nazn[ j, 1 ] ) )

          If !Empty( arr_nazn[ j, 3 ] )   // по новому ПУМП с 01.08.21
            mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_IDDOKT', arr_nazn[ j, 3 ] )
          Endif

          If !Empty( arr_nazn[ j, 4 ] )   // по новому ПУМП с 01.08.21
            mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_SPDOCT', arr_nazn[ j, 4 ] )
          Endif

          If eq_any( arr_nazn[ j, 1 ], 1, 2 )
            // к какому специалисту направлен
            mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_SP', arr_nazn[ j, 2 ] ) // результат ф-ии put_prvs_to_reestr(human_->PRVS, _NYEAR)
          Elseif arr_nazn[ j, 1 ] == 3
            mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_V', lstr( arr_nazn[ j, 2 ] ) )
            // if human->OBRASHEN == '1'
            // mo_add_xml_stroke(oPRESCRIPTIONS,'NAZ_USL',arr_nazn[j, 3]) // Мед.услуга (код), указанная в направлении
            // endif
          Elseif eq_any( arr_nazn[ j, 1 ], 4, 5 )
            mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_PMP', lstr( arr_nazn[ j, 2 ] ) )
          Elseif arr_nazn[ j, 1 ] == 6
            mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_PK', lstr( arr_nazn[ j, 2 ] ) )
          Endif
        Next j
        If human->OBRASHEN == '1' // подозрение на ЗНО
          For j := 1 To Len( arr_onkna )
            // заполним сведения о назначениях по результатам диспансеризации для XML-документа
            oPRESCRIPTIONS := oPRESCRIPTION:add( hxmlnode():new( 'PRESCRIPTIONS' ) )
            mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_N', lstr( j + Len( arr_nazn ) ) )
            mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_R', lstr( iif( arr_onkna[ j, 2 ] == 1, 2, arr_onkna[ j, 2 ] ) ) )

            If !Empty( arr_onkna[ j, 6 ] )   // по новому ПУМП с 01.08.21
              mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_IDDOKT', arr_onkna[ j, 6 ] )
            Endif

            If !Empty( arr_onkna[ j, 7 ] )   // по новому ПУМП с 01.08.21
              mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_SPDOCT', arr_onkna[ j, 7 ] )
            Endif

            If arr_onkna[ j, 2 ] == 1 // направление к онкологу
              mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_SP', iif( human->VZROS_REB == 0, '41', '19' ) ) // спец-ть онкология или детская онкология
            Else // == 3 на дообследование
              mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_V', lstr( arr_onkna[ j, 3 ] ) )
              mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_USL', arr_onkna[ j, 4 ] )
            Endif
            mo_add_xml_stroke( oPRESCRIPTIONS, 'NAPR_DATE', date2xml( arr_onkna[ j, 1 ] ) )
            If !Empty( arr_onkna[ j, 5 ] ) .and. !Empty( mNPR_MO := ret_mo( arr_onkna[ j, 5 ] )[ _MO_KOD_FFOMS ] )
              mo_add_xml_stroke( oPRESCRIPTIONS, 'NAPR_MO', mNPR_MO )
            Endif
          Next j
        Endif
      Endif
    Endif
    If is_KSG
      // заполним сведения о КСГ для XML-документа
      elem_ksg( oSl, lshifr_zak_sl, endDateZK, is_oncology )
/*
      oKSG := oSL:add( hxmlnode():new( 'KSG_KPG' ) )
      mo_add_xml_stroke( oKSG, 'N_KSG', lshifr_zak_sl )

      If endDateZK >= dPUMPver40   // дата окончания случая после 01.03.24
        mo_add_xml_stroke( oKSG, 'K_ZP', '1' )  // пока ставим 1
      Endif

      If !Empty( human_2->pc3 ) .and. !Left( human_2->pc3, 1 ) == '6' // кроме 'старости'
        mo_add_xml_stroke( oKSG, 'CRIT', human_2->pc3 )
      Elseif is_oncology  == 2
        If !Empty( onksl->crit ) .and. !( AllTrim( onksl->crit ) == 'нет' )
          mo_add_xml_stroke( oKSG, 'CRIT', onksl->crit )
        Endif
        If !Empty( onksl->crit2 )
          mo_add_xml_stroke( oKSG, 'CRIT', onksl->crit2 )  // второй критерий
        Endif
      Endif
      mo_add_xml_stroke( oKSG, 'SL_K', iif( Empty( akslp ), '0', '1' ) )
      If !Empty( akslp )
        // заполним сведения о КСГ для XML-документа
        If Year( human->K_DATA ) >= 2021     // 02.02.21 Байкин
          tKSLP := getkslptable( human->K_DATA )

          mo_add_xml_stroke( oKSG, 'IT_SL', lstr( ret_koef_kslp_21_xml( akslp, tKSLP, Year( human->K_DATA ) ), 7, 5 ) )

          For iAKSLP := 1 To Len( akslp )
            If ( cKSLP := AScan( tKSLP, {| x| x[ 1 ] == akslp[ iAKSLP ] } ) ) > 0
              oSLk := oKSG:add( hxmlnode():new( 'SL_KOEF' ) )
              mo_add_xml_stroke( oSLk, 'ID_SL', lstr( akslp[ iAKSLP ] ) )
              mo_add_xml_stroke( oSLk, 'VAL_C', lstr( tKSLP[ cKSLP, 4 ], 7, 5 ) )
            Endif
          Next
        Else
          mo_add_xml_stroke( oKSG, 'IT_SL', lstr( ret_koef_kslp( akslp ), 7, 5 ) )
          oSLk := oKSG:add( hxmlnode():new( 'SL_KOEF' ) )
          mo_add_xml_stroke( oSLk, 'ID_SL', lstr( akslp[ 1 ] ) )
          mo_add_xml_stroke( oSLk, 'VAL_C', lstr( akslp[ 2 ], 7, 5 ) )
          If Len( akslp ) >= 4
            oSLk := oKSG:add( hxmlnode():new( 'SL_KOEF' ) )
            mo_add_xml_stroke( oSLk, 'ID_SL', lstr( akslp[ 3 ] ) )
            mo_add_xml_stroke( oSLk, 'VAL_C', lstr( akslp[ 4 ], 7, 5 ) )
          Endif
        Endif
      Endif
      If !Empty( akiro )
        // заполним сведения о КИРО для XML-документа
        oSLk := oKSG:add( hxmlnode():new( 'S_KIRO' ) )
        mo_add_xml_stroke( oSLk, 'CODE_KIRO', lstr( akiro[ 1 ] ) )
        mo_add_xml_stroke( oSLk, 'VAL_K', lstr( akiro[ 2 ], 4, 2 ) )
      Endif
*/
    Elseif is_zak_sl .or. is_zak_sl_vr
      mo_add_xml_stroke( oSL, 'CODE_MES1', lshifr_zak_sl )
    Endif
    If human_->USL_OK < 4 .and. is_oncology > 0
      For j := 1 To Len( arr_onkna )
        // заполним сведения о направлениях для XML-документа
        oNAPR := oSL:add( hxmlnode():new( 'NAPR' ) )
        mo_add_xml_stroke( oNAPR, 'NAPR_DATE', date2xml( arr_onkna[ j, 1 ] ) )
        If !Empty( arr_onkna[ j, 5 ] ) .and. !Empty( mNPR_MO := ret_mo( arr_onkna[ j, 5 ] )[ _MO_KOD_FFOMS ] )
          mo_add_xml_stroke( oNAPR, 'NAPR_MO', mNPR_MO )
        Endif
        mo_add_xml_stroke( oNAPR, 'NAPR_V', lstr( arr_onkna[ j, 2 ] ) )
        If arr_onkna[ j, 2 ] == 3
          mo_add_xml_stroke( oNAPR, 'MET_ISSL', lstr( arr_onkna[ j, 3 ] ) )
          mo_add_xml_stroke( oNAPR, 'NAPR_USL', arr_onkna[ j, 4 ] )
        Endif
      Next j
    Endif
    If ( is_oncology > 0 .or. is_oncology_smp > 0 ) .and. ! lTypeLUOnkoDisp
      // заполним сведения о консилиумах для XML-документа
      oCONS := oSL:add( hxmlnode():new( 'CONS' ) ) // консилиумов м.б.несколько (но у нас один)
      mo_add_xml_stroke( oCONS, 'PR_CONS', lstr( onkco->PR_CONS ) ) // N019
      If !Empty( onkco->DT_CONS )
        mo_add_xml_stroke( oCONS, 'DT_CONS', date2xml( onkco->DT_CONS ) )
      Endif
    Endif
    If  lTypeLUOnkoDisp
      // заполним сведения о консилиумах для XML-документа
      oCONS := oSL:add( hxmlnode():new( 'CONS' ) ) // консилиумов м.б.несколько (но у нас один)
      mo_add_xml_stroke( oCONS, 'PR_CONS', lstr( onkco->PR_CONS ) ) // N019
      If !Empty( onkco->DT_CONS )
        mo_add_xml_stroke( oCONS, 'DT_CONS', date2xml( onkco->DT_CONS ) )
      Endif
    Endif
    If human_->USL_OK == USL_OK_POLYCLINIC .and. lTypeLUOnkoDisp  // постановка на учет онкобольного
      oONK_SL := oSL:add( hxmlnode():new( 'ONK_SL' ) )
      mo_add_xml_stroke( oONK_SL, 'DS1_T', lstr( onksl->DS1_T ) )
      If ! Empty( onksl->STAD )
        mo_add_xml_stroke( oONK_SL, 'STAD', lstr( onksl->STAD ) )
      Endif
    Endif
    If human_->USL_OK < 4 .and. is_oncology == 2 .and. ! lTypeLUOnkoDisp
      // заполним сведения об онкологии для XML-документа
      oONK_SL := oSL:add( hxmlnode():new( 'ONK_SL' ) )
      mo_add_xml_stroke( oONK_SL, 'DS1_T', lstr( onksl->DS1_T ) )
      If Between( onksl->DS1_T, 0, 4 )
        If ! Empty( onksl->STAD )
          mo_add_xml_stroke( oONK_SL, 'STAD', lstr( onksl->STAD ) )
        Endif
        If onksl->DS1_T == 0 .and. human->vzros_reb == 0
          If ! Empty( onksl->ONK_T )
            mo_add_xml_stroke( oONK_SL, 'ONK_T', lstr( onksl->ONK_T ) )
          Endif
          If ! Empty( onksl->ONK_N )
            mo_add_xml_stroke( oONK_SL, 'ONK_N', lstr( onksl->ONK_N ) )
          Endif
          If ! Empty( onksl->ONK_M )
            mo_add_xml_stroke( oONK_SL, 'ONK_M', lstr( onksl->ONK_M ) )
          Endif
        Endif
        If Between( onksl->DS1_T, 1, 2 ) .and. onksl->MTSTZ == 1
          mo_add_xml_stroke( oONK_SL, 'MTSTZ', lstr( onksl->MTSTZ ) )
        Endif
      Endif
      If eq_ascan( arr_onk_usl, 3, 4 )
        mo_add_xml_stroke( oONK_SL, 'SOD', lstr( onksl->sod, 6, 2 ) )
        mo_add_xml_stroke( oONK_SL, 'K_FR', lstr( onksl->k_fr ) )
      Endif
      If eq_ascan( arr_onk_usl, 2, 4 )
        mo_add_xml_stroke( oONK_SL, 'WEI', lstr( onksl->WEI, 5, 1 ) )
        mo_add_xml_stroke( oONK_SL, 'HEI', lstr( onksl->HEI ) )
        mo_add_xml_stroke( oONK_SL, 'BSA', lstr( onksl->BSA, 5, 2 ) )
      Endif
      For j := 1 To Len( arr_onkdi )
        If ! Empty( arr_onkdi[ j, 1 ] ) // только если заполнена дата исследования
          // заполним сведения о диагностических услугах для XML-документа
          oDIAG := oONK_SL:add( hxmlnode():new( 'B_DIAG' ) )
          mo_add_xml_stroke( oDIAG, 'DIAG_DATE', date2xml( arr_onkdi[ j, 1 ] ) )
          mo_add_xml_stroke( oDIAG, 'DIAG_TIP', lstr( arr_onkdi[ j, 2 ] ) )
          mo_add_xml_stroke( oDIAG, 'DIAG_CODE', lstr( arr_onkdi[ j, 3 ] ) )
          If arr_onkdi[ j, 4 ] > 0
            mo_add_xml_stroke( oDIAG, 'DIAG_RSLT', lstr( arr_onkdi[ j, 4 ] ) )
          Endif
          mo_add_xml_stroke( oDIAG, 'REC_RSLT', '1' )
        Endif
      Next j
      For j := 1 To Len( arr_onkpr )
        // заполним сведения о противоказаниях и отказах для XML-документа
        oPROT := oONK_SL:add( hxmlnode():new( 'B_PROT' ) )
        mo_add_xml_stroke( oPROT, 'PROT', lstr( arr_onkpr[ j, 1 ] ) )
        mo_add_xml_stroke( oPROT, 'D_PROT', date2xml( arr_onkpr[ j, 2 ] ) )
      Next j
      If human_->USL_OK < 3 .and. iif( human_2->VMP == 1, .t., Between( onksl->DS1_T, 0, 2 ) ) .and. Len( arr_onk_usl ) > 0
        Select ONKUS
        find ( Str( human->kod, 7 ) )
        Do While onkus->kod == human->kod .and. !Eof()
          If Between( onkus->USL_TIP, 1, 5 )
            // заполним сведения об услуге прилечении онкологического больного для XML-документа
            oONK := oONK_SL:add( hxmlnode():new( 'ONK_USL' ) )
            mo_add_xml_stroke( oONK, 'USL_TIP', lstr( onkus->USL_TIP ) )
            If onkus->USL_TIP == 1
              mo_add_xml_stroke( oONK, 'HIR_TIP', lstr( onkus->HIR_TIP ) )
            Endif
            If onkus->USL_TIP == 2
              mo_add_xml_stroke( oONK, 'LEK_TIP_L', lstr( onkus->LEK_TIP_L ) )
              mo_add_xml_stroke( oONK, 'LEK_TIP_V', lstr( onkus->LEK_TIP_V ) )
            Endif
            If eq_any( onkus->USL_TIP, 3, 4 )
              mo_add_xml_stroke( oONK, 'LUCH_TIP', lstr( onkus->LUCH_TIP ) )
            Endif
            If eq_any( onkus->USL_TIP, 2, 4 )
/*
              If human->k_data >= 0d20250101
                arrLP := collect_lek_pr( human->( RecNo() ) )
                If Len( arrLP ) > 0
                  aRegnum := unique_val_in_array( arrLP, 3 ) // получим уникальные REGNUM
                  For i := 1 To Len( aRegnum )
                    // Соберем типы лек. препаратов
                    // заполним сведения о примененных лекарственных препаратах при лечении онкологического больного для XML-документа
                    oLEK := oONK:add( hxmlnode():new( 'LEK_PR' ) )
                    mo_add_xml_stroke( oLEK, 'REGNUM', aRegnum[ i, 3 ] )
                    mo_add_xml_stroke( oLEK, 'REGNUM_DOP', ;
                      get_sootv_n021( aRegnum[ i, 2 ], aRegnum[ i, 3 ], human->k_data )[ 7 ] )
                    mo_add_xml_stroke( oLEK, 'CODE_SH', aRegnum[ i, 2 ] )
                    For iLekPr := 1 To Len( arrLp )
                      If arrLP[ iLekPr, 3 ] == aRegnum[ i, 3 ]
                        oINJ := oLek:add( hxmlnode():new( 'INJ' ) )
                        mo_add_xml_stroke( oINJ, 'DATE_INJ', date2xml( arrLP[ iLekPr, 1 ] ) )
                        mo_add_xml_stroke( oINJ, 'KV_INJ', Str( arrLP[ iLekPr, 5 ], 8, 3 ) )
                        mo_add_xml_stroke( oINJ, 'KIZ_INJ', Str( arrLP[ iLekPr, 9 ], 8, 3 ) )
                        mo_add_xml_stroke( oINJ, 'S_INJ', Str( arrLP[ iLekPr, 10 ], 15, 6 ) )
                        mo_add_xml_stroke( oINJ, 'SV_INJ', ;
                          Str( arrLP[ iLekPr, 5 ] * arrLP[ iLekPr, 10 ], 15, 2 ) )
                        mo_add_xml_stroke( oINJ, 'SIZ_INJ', ;
                          Str( arrLP[ iLekPr, 9 ] * arrLP[ iLekPr, 10 ], 15, 2 ) )
                        mo_add_xml_stroke( oINJ, 'RED_INJ', Str( arrLP[ iLekPr, 11 ], 1, 0 ) )
                      Endif
                    Next
                  Next
                Endif
              Else
                old_lek := Space( 6 )
                old_sh := Space( 10 )
                Select ONKLE  // цикл по БД лекарств
                find ( Str( human->kod, 7 ) )
                Do While onkle->kod == human->kod .and. !Eof()
                  If !( old_lek == onkle->REGNUM .and. old_sh == onkle->CODE_SH )
                    // заполним сведения о примененных лекарственных препаратах при лечении онкологического больного для XML-документа
                    oLEK := oONK:add( hxmlnode():new( 'LEK_PR' ) )
                    mo_add_xml_stroke( oLEK, 'REGNUM', onkle->REGNUM )
                    mo_add_xml_stroke( oLEK, 'CODE_SH', onkle->CODE_SH )
                  Endif
                  // цикл по датам приёма данного лекарства
                  mo_add_xml_stroke( oLEK, 'DATE_INJ', date2xml( onkle->DATE_INJ ) )
                  old_lek := onkle->REGNUM
                  old_sh := onkle->CODE_SH
                  Select ONKLE
                  Skip
                Enddo
              Endif
*/
              elem_lek_pr_zno( oONK, human->k_data, human->( RecNo() ), human->kod )

              If onkus->PPTR > 0
                mo_add_xml_stroke( oONK, 'PPTR', '1' )
              Endif
            Endif
          Endif
          Select ONKUS
          Skip
        Enddo
      Endif
    Endif
    sCOMENTSL := ''
    If p_tip_reestr == TYPE_REESTR_GENERAL
      mo_add_xml_stroke( oSL, 'PRVS', put_prvs_to_reestr( human_->PRVS, _NYEAR ) )
      If ( !is_mgi .and. AScan( kod_lis(), glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 ) ) .or. human_->profil == 15 // гистология
        mo_add_xml_stroke( oSL, 'IDDOKT', '0' )
      Else
        p2->( dbGoto( human_->vrach ) )
        mo_add_xml_stroke( oSL, 'IDDOKT', p2->snils )
      Endif
      If is_zak_sl .or. is_zak_sl_vr
        mo_add_xml_stroke( oSL, 'ED_COL', '1' )
        mo_add_xml_stroke( oSL, 'TARIF', lstr( tarif_zak_sl, 10, 2 ) )
      Endif
      mo_add_xml_stroke( oSL, 'SUM_M', lstr( human->cena_1, 10, 2 ) )

      // проверим лекарственные препараты
      If eq_any( RTrim( mdiagnoz[ 1 ] ), 'U07.1', 'U07.2' ) .and. ( count_years( human->DATE_R, human->k_data ) >= 18 ) ;
          .and. !check_diag_pregant()
        If ( human_->USL_OK == USL_OK_HOSPITAL ) .and. ( human->k_data >= 0d20220101 )
          flLekPreparat := ( human_->PROFIL != 158 ) .and. ( human_->VIDPOM != 32 ) ;
            .and. ( Lower( AllTrim( human_2->PC3 ) ) != 'stt5' )
        Elseif ( human_->USL_OK == USL_OK_POLYCLINIC ) .and. ( human->k_data >= 0d20220401 )
          flLekPreparat := ( human_->PROFIL != 158 ) .and. ( human_->VIDPOM != 32 ) ;
            .and. ( get_idpc_from_v025_by_number( human_->povod ) == '3.0' )
        Endif
      Endif

      If flLekPreparat
        // добавим в xml-документ информацию о лекарственных препаратах
/*
        arrLP := collect_lek_pr( human->( RecNo() ) )
        If Len( arrLP ) != 0
          For Each row in arrLP
            oLEK := oSL:add( hxmlnode():new( 'LEK_PR' ) )
            mo_add_xml_stroke( oLEK, 'DATA_INJ', date2xml( row[ 1 ] ) )
            mo_add_xml_stroke( oLEK, 'CODE_SH', row[ 8 ] )
            If ! Empty( row[ 3 ] )
              mo_add_xml_stroke( oLEK, 'REGNUM', row[ 3 ] )
              // mo_add_xml_stroke(oLEK, 'CODE_MARK', '')  // для дальнейшего использования
              oDOSE := oLEK:add( hxmlnode():new( 'LEK_DOSE' ) )
              mo_add_xml_stroke( oDOSE, 'ED_IZM', Str( row[ 4 ], 3, 0 ) )
              mo_add_xml_stroke( oDOSE, 'DOSE_INJ', Str( row[ 5 ], 8, 2 ) )
              mo_add_xml_stroke( oDOSE, 'METHOD_INJ', Str( row[ 6 ], 3, 0 ) )
              mo_add_xml_stroke( oDOSE, 'COL_INJ', Str( row[ 7 ], 5, 0 ) )
            Endif
          Next
        Endif
*/
        elem_lek_pr( oSl, human->( RecNo() ) )
      Endif

      If !Empty( ldate_next )
        If human->N_DATA < 0d20241201
          mo_add_xml_stroke( oSL, 'NEXT_VISIT', date2xml( BoM( ldate_next ) ) )
        Else  // согласно письма ТФОМС 09-20-615 от 21.11.24
          If eq_any( adiag_talon[ 2 ], NIL, 0, 1, 2 ) // NIL или 0 - в поле human_->DISPANS ничего не проставлено
            mo_add_xml_stroke( oSL, 'NEXT_VISIT', date2xml( BoM( ldate_next ) ) )
          Endif
        Endif
      Endif
      //
      j := 0
      If ( ibrm := f_oms_beremenn( mdiagnoz[ 1 ], human->K_DATA ) ) == 1 .and. eq_any( human_->profil, 136, 137 ) // акушерству и гинекологии
        j := iif( human_2->pn2 == 1, 4, 3 )
      Elseif ibrm == 2 .and. human_->USL_OK == USL_OK_POLYCLINIC // поликлиника
        j := iif( human_2->pn2 == 1, 5, 6 )
        If j == 5 .and. !eq_any( human_->profil, 136, 137 )
          j := 6  // т.е. только акушер-гинеколог может поставить на учёт по беременности
        Endif
      Endif
      If j > 0
        sCOMENTSL += lstr( j )
      Endif
      If human_->USL_OK == USL_OK_POLYCLINIC .and. eq_any( lvidpom, 1, 11, 12, 13 )
        sCOMENTSL += ':;' // пока так (потом добавим дисп.наблюдение)
      Endif
    Else   // для реестров по диспансеризации
      If is_zak_sl .or. is_zak_sl_vr
        mo_add_xml_stroke( oSL, 'ED_COL', '1' )
      Endif
      mo_add_xml_stroke( oSL, 'PRVS', put_prvs_to_reestr( human_->PRVS, _NYEAR ) )
      If is_zak_sl .or. is_zak_sl_vr
        mo_add_xml_stroke( oSL, 'TARIF', lstr( tarif_zak_sl, 10, 2 ) )
      Endif
      mo_add_xml_stroke( oSL, 'SUM_M', lstr( human->cena_1, 10, 2 ) )
      //
      If Between( human->ishod, 201, 205 ) // ДВН
        j := iif( human->RAB_NERAB == 0, 20, iif( human->RAB_NERAB == 1, 10, 14 ) )
        If human->ishod != 203 .and. m1veteran == 1
          j := iif( human->RAB_NERAB == 0, 21, 11 )
        Endif
        ( 'kart' )->( dbGoto( human->kod_k ) )  // для участников СВО
        If kart->pn1 == 30 .and. eq_any( hb_main_curOrg:Kod_Tfoms, '101201', '451001', '391002' )
          j := 30
        Endif
        sCOMENTSL := lstr( j )
      Elseif Between( human->ishod, 301, 302 )
        j := iif( Between( m1mesto_prov, 0, 1 ), m1mesto_prov, 0 )
        sCOMENTSL := lstr( j )
      Endif
    Endif
    If p_tip_reestr == TYPE_REESTR_GENERAL .and. !Empty( sCOMENTSL ) // .and. ! lTypeLUOnkoDisp
      mo_add_xml_stroke( oSL, 'COMENTSL', sCOMENTSL )
    Endif
    If !is_zak_sl
      For j := 1 To Len( a_usl )
        Select HU
        Goto ( a_usl[ j ] )
        If hu->kod_vr == 0
          Loop
        Endif
        hu_->( g_rlock( forever ) )
        hu_->REES_ZAP := ++iusl
        lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
        lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
        // заполним сведения об услугах для XML-документа
        oUSL := oSL:add( hxmlnode():new( 'USL' ) )
        mo_add_xml_stroke( oUSL, 'IDSERV', lstr( hu_->REES_ZAP ) )
        mo_add_xml_stroke( oUSL, 'ID_U', hu_->ID_U )
        fl := .f.
        If eq_any( hu->is_edit, 1, 2 ) // гематологические исследования
          mo_add_xml_stroke( oUSL, 'LPU', kod_lis()[ hu->is_edit ] ) // иссл-ие проводится в КДП2 или РДЛ
        Elseif lshifr == '4.20.2' .or. hu->is_edit == 3 // жидкостная цитология или приём в ВОКОД
          mo_add_xml_stroke( oUSL, 'LPU', '103001' ) // т.е. иссл-ие проводится в онкологии
        Elseif hu->is_edit == 4
          mo_add_xml_stroke( oUSL, 'LPU', '000000' ) // т.е. иссл-ие проводится в нашем пат.анат.бюро
        Elseif hu->is_edit == 5
          mo_add_xml_stroke( oUSL, 'LPU', '999999' ) // т.е. иссл-ие проводится в пат.анат.бюро в другой области
        Else
          If pr_amb_reab .and. Left( lshifr, 2 ) == '4.' .and. Left( hu_->zf, 6 ) == '999999'
            fl := .t.
            mo_add_xml_stroke( oUSL, 'LPU', '999999' )
          Elseif pr_amb_reab .and. Left( lshifr, 2 ) == '4.' .and. !Empty( Left( hu_->zf, 6 ) ) .and. Left( hu_->zf, 6 ) != glob_mo[ _MO_KOD_TFOMS ]
            fl := .t.
            mo_add_xml_stroke( oUSL, 'LPU', Left( hu_->zf, 6 ) )
          Else
            mo_add_xml_stroke( oUSL, 'LPU', CODE_LPU )
          Endif
        Endif
        If p_tip_reestr == TYPE_REESTR_GENERAL
          // if human->K_DATA < 0d20230601 .and. human_->USL_OK == USL_OK_HOSPITAL .and. is_otd_dep
          If human_->USL_OK == USL_OK_HOSPITAL .and. is_otd_dep .and. ( ! disable_podrazdelenie_tfoms( human->K_DATA ) )
            otd->( dbGoto( hu->OTD ) )
            f_put_glob_podr( human_->USL_OK, human->K_DATA ) // заполнить код подразделения
            If ( i := AScan( mm_otd_dep, {| x| x[ 2 ] == glob_otd_dep } ) ) == 0
              i := 1
            Endif
            mo_add_xml_stroke( oUSL, 'LPU_1', lstr( mm_otd_dep[ i, 3 ] ) )
            mo_add_xml_stroke( oUSL, 'PODR', lstr( glob_otd_dep ) )
          Elseif hu->KOL_RCP < 0 .and. domuslugatfoms( lshifr )
            mo_add_xml_stroke( oUSL, 'PODR', '0' )
          Endif
        Endif
        mo_add_xml_stroke( oUSL, 'PROFIL', lstr( hu_->PROFIL ) )
        Select T21
        find ( PadR( lshifr, 10 ) )
        If Found()
          mo_add_xml_stroke( oUSL, 'VID_VME', AllTrim( t21->shifr_mz ) )
        Endif
        If p_tip_reestr == TYPE_REESTR_GENERAL
          mo_add_xml_stroke( oUSL, 'DET', iif( human->VZROS_REB == 0, '0', '1' ) )
        Endif
        mo_add_xml_stroke( oUSL, 'DATE_IN', date2xml( c4tod( hu->DATE_U ) ) )
        If p_tip_reestr == TYPE_REESTR_GENERAL
          If ! Empty( hu_->DATE_END ) .and. ( hu->KOL_1 > 1 )
            mo_add_xml_stroke( oUSL, 'DATE_OUT', date2xml( hu_->DATE_END ) )
          Else
            mo_add_xml_stroke( oUSL, 'DATE_OUT', date2xml( c4tod( hu_->DATE_U2 ) ) )
          Endif
        Else
          mo_add_xml_stroke( oUSL, 'DATE_OUT', date2xml( c4tod( hu_->DATE_U2 ) ) )
        Endif
        If p_tip_reestr == TYPE_REESTR_GENERAL
          // подменим диагноз если необходимо для генно-инженерных препаратов или
          // операции по поводу грыж, взрослые (уровень 4), для случаев проведения
          // антимикробной терапии инфекций, вызванных полирезистентными микроорганизмами
          If lReplaceDiagnose
            mo_add_xml_stroke( oUSL, 'DS', diagnoz_replace )
          Else
            mo_add_xml_stroke( oUSL, 'DS', hu_->kod_diag )
          Endif
        Else
          If AScan( arr_ne_vozm, lshifr ) > 0
            mo_add_xml_stroke( oUSL, 'P_OTK', '2' )
          Else
            mo_add_xml_stroke( oUSL, 'P_OTK', '0' )
          Endif
        Endif
        mo_add_xml_stroke( oUSL, 'CODE_USL', lshifr )
        mo_add_xml_stroke( oUSL, 'KOL_USL', lstr( hu->KOL_1, 6, 2 ) )
        mo_add_xml_stroke( oUSL, 'TARIF', lstr( hu->U_CENA, 10, 2 ) )
        mo_add_xml_stroke( oUSL, 'SUMV_USL', lstr( hu->STOIM_1, 10, 2 ) )

        If ( human->k_data >= 0d20210801 .and. p_tip_reestr == TYPE_REESTR_DISPASER ) ;      // правила заполнения с 01.08.21 письмо № 04-18-13 от 20.07.21
          .or. ( endDateZK >= 0d20220101 .and. p_tip_reestr == TYPE_REESTR_GENERAL )  // правила заполнения с 01.01.22 письмо № 04-18?17 от 28.12.2021

          If between_date( human->n_data, human->k_data, c4tod( hu->DATE_U ) )
//            oMR_USL_N := oUSL:add( hxmlnode():new( 'MR_USL_N' ) )
//            mo_add_xml_stroke( oMR_USL_N, 'MR_N', lstr( 1 ) )   // пока ставим 1 исполнитель
//            mo_add_xml_stroke( oMR_USL_N, 'PRVS', put_prvs_to_reestr( hu_->PRVS, _NYEAR ) )
            p2->( dbGoto( hu->kod_vr ) )
//            mo_add_xml_stroke( oMR_USL_N, 'CODE_MD', p2->snils )
            elem_mr_usl_n( oUsl, _nyear, 1, hu_->PRVS, p2->snils ) // пока ставим 1 исполнитель
          Endif
        Else  // if (human->k_data < 0d20210801 .and. p_tip_reestr == TYPE_REESTR_DISPASER)
          mo_add_xml_stroke( oUSL, 'PRVS', put_prvs_to_reestr( hu_->PRVS, _NYEAR ) )
          If c4tod( hu->DATE_U ) < human->n_data ; // если сделано ранее
            .or. eq_any( hu->is_edit, -1, 1, 2, 3 ) .or. lshifr == '4.20.2' .or. Left( lshifr, 5 ) == '60.8.' .or. fl
            mo_add_xml_stroke( oUSL, 'CODE_MD', '0' ) // не заполняется код врача
          Else
            p2->( dbGoto( hu->kod_vr ) )
            mo_add_xml_stroke( oUSL, 'CODE_MD', p2->snils )
          Endif
        Endif
      Next
    Endif
    If p_tip_reestr == TYPE_REESTR_DISPASER .and. Len( a_otkaz ) > 0 // отказы (диспансеризация или профосмоты несовешеннолетних)
      // заполним сведения об услугах для XML-документа
      For j := 1 To Len( a_otkaz )
        oUSL := oSL:add( hxmlnode():new( 'USL' ) )
        mo_add_xml_stroke( oUSL, 'IDSERV', lstr( ++iusl ) )
        mo_add_xml_stroke( oUSL, 'ID_U', mo_guid( 3, iusl ) )
        mo_add_xml_stroke( oUSL, 'LPU', CODE_LPU )
        mo_add_xml_stroke( oUSL, 'PROFIL', lstr( a_otkaz[ j, 4 ] ) )
        Select T21
        find ( PadR( a_otkaz[ j, 1 ], 10 ) )
        If Found()
          mo_add_xml_stroke( oUSL, 'VID_VME', AllTrim( t21->shifr_mz ) )
        Endif
        mo_add_xml_stroke( oUSL, 'DATE_IN', date2xml( a_otkaz[ j, 3 ] ) )
        mo_add_xml_stroke( oUSL, 'DATE_OUT', date2xml( a_otkaz[ j, 3 ] ) )
        mo_add_xml_stroke( oUSL, 'P_OTK', lstr( a_otkaz[ j, 7 ] ) )
        mo_add_xml_stroke( oUSL, 'CODE_USL', a_otkaz[ j, 1 ] )
        mo_add_xml_stroke( oUSL, 'KOL_USL', lstr( 1, 6, 2 ) )
        mo_add_xml_stroke( oUSL, 'TARIF', lstr( a_otkaz[ j, 6 ], 10, 2 ) )
        mo_add_xml_stroke( oUSL, 'SUMV_USL', lstr( a_otkaz[ j, 6 ], 10, 2 ) )

        If human->k_data >= 0d20210801 .and. p_tip_reestr == TYPE_REESTR_DISPASER ; // новые правила заполнения с 01.08.21 письмо № 04-18-13 от 20.07.21
          .or. ( endDateZK >= 0d20220101 .and. p_tip_reestr == TYPE_REESTR_GENERAL )  // правила заполнения с 01.01.22 письмо № 04-18?17 от 28.12.2021
        Else
          mo_add_xml_stroke( oUSL, 'PRVS', put_prvs_to_reestr( a_otkaz[ j, 5 ], _NYEAR ) )
          mo_add_xml_stroke( oUSL, 'CODE_MD', '0' ) // отказ => 0
        Endif

      Next
    Endif

    // if p_tip_reestr == TYPE_REESTR_GENERAL .and. len(a_fusl) > 0 // добавляем операции
    If Len( a_fusl ) > 0 // добавляем операции // исправил чтобы брала углубленную диспансеризацию COVID
      For j := 1 To Len( a_fusl )
        Select MOHU
        Goto ( a_fusl[ j ] )
        If mohu->kod_vr == 0
          Loop
        Endif
        // mohu->( g_rlock( forever ) )
        mohu->( dbRLock() )
        mohu->REES_ZAP := ++iusl
        lshifr := AllTrim( mosu->shifr1 )
        // заполним сведения об услугах для XML-документа
        oUSL := oSL:add( hxmlnode():new( 'USL' ) )
        mo_add_xml_stroke( oUSL, 'IDSERV', lstr( mohu->REES_ZAP ) )
        mo_add_xml_stroke( oUSL, 'ID_U', mohu->ID_U )
        mo_add_xml_stroke( oUSL, 'LPU', CODE_LPU )
        If human_->USL_OK == USL_OK_HOSPITAL .and. is_otd_dep .and. ( ! disable_podrazdelenie_tfoms( human->K_DATA ) )
          otd->( dbGoto( mohu->OTD ) )
          f_put_glob_podr( human_->USL_OK, human->K_DATA ) // заполнить код подразделения
          If ( i := AScan( mm_otd_dep, {| x| x[ 2 ] == glob_otd_dep } ) ) == 0
            i := 1
          Endif
          mo_add_xml_stroke( oUSL, 'LPU_1', lstr( mm_otd_dep[ i, 3 ] ) )
          mo_add_xml_stroke( oUSL, 'PODR', lstr( glob_otd_dep ) )
        Endif
        mo_add_xml_stroke( oUSL, 'PROFIL', lstr( mohu->PROFIL ) )
        If p_tip_reestr == TYPE_REESTR_GENERAL
          mo_add_xml_stroke( oUSL, 'VID_VME', lshifr )
          mo_add_xml_stroke( oUSL, 'DET', iif( human->VZROS_REB == 0, '0', '1' ) )
        Endif
        mo_add_xml_stroke( oUSL, 'DATE_IN', date2xml( c4tod( mohu->DATE_U ) ) )
        mo_add_xml_stroke( oUSL, 'DATE_OUT', date2xml( c4tod( mohu->DATE_U2 ) ) )
        If p_tip_reestr == TYPE_REESTR_GENERAL
          // подменим диагноз если необходимо для генно-инженерных препаратов или
          // операции по поводу грыж, взрослые (уровень 4), для случаев проведения
          // антимикробной терапии инфекций, вызванных полирезистентными микроорганизмами
          If lReplaceDiagnose
            mo_add_xml_stroke( oUSL, 'DS', diagnoz_replace )
          Else
            mo_add_xml_stroke( oUSL, 'DS', mohu->kod_diag )
          Endif
        Endif
        If p_tip_reestr == TYPE_REESTR_DISPASER
          // разобраться с отказами услугами ФФОМС
          If AScan( arr_ne_vozm, lshifr ) > 0
            mo_add_xml_stroke( oUSL, 'P_OTK', '2' )
          Else
            mo_add_xml_stroke( oUSL, 'P_OTK', '0' )
          Endif
        Endif
        mo_add_xml_stroke( oUSL, 'CODE_USL', lshifr )
        mo_add_xml_stroke( oUSL, 'KOL_USL', lstr( mohu->KOL_1, 6, 2 ) )
        If p_tip_reestr == TYPE_REESTR_GENERAL
          mo_add_xml_stroke( oUSL, 'TARIF', lstr( mohu->U_CENA, 10, 2 ) )// lstr(mohu->U_CENA, 10, 2))
          mo_add_xml_stroke( oUSL, 'SUMV_USL', lstr( mohu->STOIM_1, 10, 2 ) )// lstr(mohu->STOIM_1, 10, 2))
        Elseif p_tip_reestr == TYPE_REESTR_DISPASER
          mo_add_xml_stroke( oUSL, 'TARIF', '0' )// lstr(mohu->U_CENA, 10, 2))
          mo_add_xml_stroke( oUSL, 'SUMV_USL', '0' )// lstr(mohu->STOIM_1, 10, 2))
        Endif
        fl := .f.
        If is_telemedicina( lshifr, @fl ) // не заполняется код врача
          mo_add_xml_stroke( oUSL, 'PRVS', put_prvs_to_reestr( mohu->PRVS, _NYEAR ) )  // добавил 04.08.21
          mo_add_xml_stroke( oUSL, 'CODE_MD', '0' )
        Else
          If ( human->k_data >= 0d20210801 .and. p_tip_reestr == TYPE_REESTR_DISPASER ) ;      // правила заполнения с 01.08.21 письмо № 04-18-13 от 20.07.21
              .or. ( human->k_data >= 0d20220101 .and. p_tip_reestr == TYPE_REESTR_GENERAL )  // правила заполнения с 01.01.22 письмо № 04-18?17 от 28.12.2021
            If ( p_tip_reestr == TYPE_REESTR_GENERAL ) .and. service_requires_implants( lshifr, c4tod( hu_->DATE_U2 ) )
/*
              For Each row in collect_implantant( human->kod, mohu->( RecNo() ) )
                oMED_DEV := oUSL:add( hxmlnode():new( 'MED_DEV' ) )
                mo_add_xml_stroke( oMED_DEV, 'DATE_MED', date2xml( row[ 3 ] ) )
                mo_add_xml_stroke( oMED_DEV, 'CODE_MEDDEV', lstr( row[ 4 ] ) )
                mo_add_xml_stroke( oMED_DEV, 'NUMBER_SER', AllTrim( row[ 5 ] ) )
              Next
*/
              elem_med_dev( oUsl, human->kod, mohu->( RecNo() ) )
            Endif
            If between_date( human->n_data, human->k_data, c4tod( mohu->DATE_U ) )
//              oMR_USL_N := oUSL:add( hxmlnode():new( 'MR_USL_N' ) )
//              mo_add_xml_stroke( oMR_USL_N, 'MR_N', lstr( 1 ) )   // пока ставим 1 исполнитель
//              mo_add_xml_stroke( oMR_USL_N, 'PRVS', put_prvs_to_reestr( mohu->PRVS, _NYEAR ) )
              p2->( dbGoto( mohu->kod_vr ) )
//              mo_add_xml_stroke( oMR_USL_N, 'CODE_MD', p2->snils )
              elem_mr_usl_n( oUsl, _nyear, 1, mohu->PRVS, p2->snils ) // пока ставим 1 исполнитель
            Endif
          Else  // if human->k_data < 0d20220101 .and. p_tip_reestr == TYPE_REESTR_GENERAL
            mo_add_xml_stroke( oUSL, 'PRVS', put_prvs_to_reestr( mohu->PRVS, _NYEAR ) )  // добавил 04.08.21
            p2->( dbGoto( mohu->kod_vr ) )                                            // добавил 04.08.21
            mo_add_xml_stroke( oUSL, 'CODE_MD', p2->snils )                          // добавил 04.08.21
          Endif
        Endif
        If !Empty( mohu->zf )
          dbSelectArea( laluslf )
          find ( PadR( lshifr, 20 ) )
          If Found()
            If fl // телемедицина + НМИЦ
              mo_add_xml_stroke( oUSL, 'COMENTU', mohu->zf ) // код НМИЦ:факт получения результата
            Elseif stiszf( human_->USL_OK, human_->PROFIL ) .and. &laluslf.->zf == 1  // обязателен ввод зубной формулы
              mo_add_xml_stroke( oUSL, 'COMENTU', arr2list( stretarrzf( mohu->zf ) ) ) // формула зуба
            Elseif !Empty( &laluslf.->par_org ) // проверим на парные операции
              mo_add_xml_stroke( oUSL, 'COMENTU', mohu->zf ) // парные органы
            Endif
          Endif
        Endif
      Next j
    Endif
    If p_tip_reestr == TYPE_REESTR_DISPASER .and. !Empty( sCOMENTSL )   // для реестров по диспансеризации
      If ( is_disp_DVN .or. is_disp_DVN_COVID .or. is_disp_DRZ )
        sCOMENTSL += ':'
        If !Empty( ar_dn ) // взят на диспансерное наблюдение
          For i := 1 To 5
            sk := lstr( i )
            pole_diag := 'mdiag' + sk
            pole_1dispans := 'm1dispans' + sk
            pole_dn_dispans := 'mdndispans' + sk
            // If !Empty( &pole_diag ) .and. &pole_1dispans == 1 .and. AScan( sadiag1, AllTrim( &pole_diag ) ) > 0 ;
            If !Empty( &pole_diag ) .and. &pole_1dispans == 1 .and. diag_in_list_dn( &pole_diag ) ;
                .and. !Empty( &pole_dn_dispans ) ;
                .and. ( j := AScan( ar_dn, {| x| AllTrim( x[ 2 ] ) == AllTrim( &pole_diag ) } ) ) > 0
              ar_dn[ j, 4 ] := date2xml( BoM( &pole_dn_dispans ) )
            Endif
          Next
          For j := 1 To Len( ar_dn )
            If !Empty( ar_dn[ j, 4 ] )
              sCOMENTSL += '2,' + AllTrim( ar_dn[ j, 2 ] ) + ',,' + ar_dn[ j, 4 ] + '/'
            Endif
          Next
          If Right( sCOMENTSL, 1 ) == '/'
            sCOMENTSL := Left( sCOMENTSL, Len( sCOMENTSL ) -1 )
          Endif
        Endif
        sCOMENTSL += ';' 
      Endif
      mo_add_xml_stroke( oSL, 'COMENTSL', sCOMENTSL )
    Endif
  Next isl
  Select RHUM
  If rhum->REES_ZAP % 2000 == 0
    dbUnlockAll()
    dbCommitAll()
  Endif

  Return Nil
