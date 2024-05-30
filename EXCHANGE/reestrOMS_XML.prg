// реестры/счета с 2019 года
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define BASE_ISHOD_RZD 500  //

Static sadiag1  // := {}

// 07.05.24 создание XML-файлов реестра
Function create2reestr19( _recno, _nyear, _nmonth, reg_sort )

  Local mnn, mnschet := 1, fl, mkod_reestr, name_zip, arr_zip := {}, lst, lshifr1, code_reestr, mb, me, nsh
  Local iAKSLP, tKSLP, cKSLP // счетчик для цикла по КСЛП
  Local reserveKSG_ID_C := '' // GUID для вложенных двойных случаев
  Local arrLP, row
  Local ser_num
  Local controlVer
  Local endDateZK
  Local diagnoz_replace := ''
  Local aImpl
  Local flLekPreparat
  Local lReplaceDiagnose := .f.
  Local lTypeLUOnkoDisp := .f.  // флаг листа учета постановки на диспансерное наблюдение онкобольных
  local dPUMPver40 := 0d20240301

  //
  Close databases
  // if empty(sadiag1)
  // Private file_form, diag1 := {}, len_diag := 0
  // if (file_form := search_file('DISP_NAB' + sfrm)) == NIL
  // return func_error(4, 'Не обнаружен файл DISP_NAB' + sfrm)
  // endif
  // f2_vvod_disp_nabl('A00')
  // sadiag1 := diag1
  // endif
  If ISNIL( sadiag1 )
    sadiag1 := load_diagnoze_disp_nabl_from_file()
  Endif
  For i := 1 To 5
    sk := lstr( i )
    pole_diag := 'mdiag' + sk
    pole_1dispans := 'm1dispans' + sk
    pole_dn_dispans := 'mdndispans' + sk
    Private &pole_diag := Space( 6 )
    Private &pole_1dispans := 0
    Private &pole_dn_dispans := CToD( '' )
  Next
  stat_msg( 'Составление реестра случаев' )
  nsh := f_mb_me_nsh( _nyear, @mb, @me )
  r_use( dir_exe + '_mo_mkb', , 'MKB_10' )
  Index On shifr + Str( ks, 1 ) to ( cur_dir + '_mo_mkb' )
  g_use( dir_server + 'mo_rees', , 'REES' )
  Index On Str( nn, nsh ) to ( cur_dir + 'tmp_rees' ) For nyear == _nyear .and. nmonth == _nmonth
  fl := .f.
  For mnn := mb To me
    find ( Str( mnn, nsh ) )
    If !Found() // нашли свободный номер
      fl := .t.
      Exit
    Endif
  Next
  If !fl
    Close databases
    Return func_error( 10, 'Не удалось найти свободный номер пакета в ТФОМС. Проверьте настройки!' )
  Endif
  Index On Str( nschet, 6 ) to ( cur_dir + 'tmp_rees' ) For nyear == _nyear
  If !Eof()
    Go Bottom
    mnschet := rees->nschet + 1
  Endif
  If !Between( mnschet, mem_beg_rees, mem_end_rees )
    fl := .f.
    For mnschet := mem_beg_rees To mem_end_rees
      find ( Str( mnschet, 6 ) )
      If !Found() // нашли свободный номер
        fl := .t.
        Exit
      Endif
    Next
    If !fl
      Close databases
      Return func_error( 10, 'Не удалось найти свободный номер реестра. Проверьте настройки!' )
    Endif
  Endif
  Set Index To
  addrecn()
  rees->KOD    := RecNo()
  rees->NSCHET := mnschet
  rees->DSCHET := sys_date
  rees->NYEAR  := _NYEAR
  rees->NMONTH := _NMONTH
  rees->NN     := mnn
  s := 'RM' + CODE_LPU + 'T34' + '_' + Right( StrZero( _NYEAR, 4 ), 2 ) + StrZero( _NMONTH, 2 ) + StrZero( mnn, nsh )
  rees->NAME_XML := { 'H', 'F' }[ p_tip_reestr ] + s
  mkod_reestr := rees->KOD
  rees->CODE  := ret_unique_code( mkod_reestr )
  code_reestr := rees->CODE
  //
  g_use( dir_server + 'mo_xml', , 'MO_XML' )
  addrecn()
  mo_xml->KOD    := RecNo()
  mo_xml->FNAME  := rees->NAME_XML
  mo_xml->FNAME2 := 'L' + s
  mo_xml->DFILE  := rees->DSCHET
  mo_xml->TFILE  := hour_min( Seconds() )
  mo_xml->TIP_OUT := _XML_FILE_REESTR // тип высылаемого файла;1-реестр
  mo_xml->REESTR := mkod_reestr
  //
  rees->KOD_XML := mo_xml->KOD
  Unlock
  Commit
  //
  use_base( 'lusl' )
  use_base( 'luslc' )
  use_base( 'luslf' )
  r_use( dir_server + 'human_im', dir_server + 'human_im', 'IMPL' )
  r_use( dir_server + 'human_lek_pr', dir_server + 'human_lek_pr', 'LEK_PR' )

  laluslf := create_name_alias( 'luslf', _nyear )
  r_use( dir_server + 'mo_uch', , 'UCH' )
  r_use( dir_server + 'mo_otd', , 'OTD' )
  r_use( dir_server + 'mo_pers', , 'P2' )
  r_use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'P2TABN' )
  r_use( dir_server + 'uslugi', , 'USL' )
  g_use( dir_server + 'mo_rhum', , 'RHUM' )
  Index On Str( REESTR, 6 ) to ( cur_dir + 'tmp_rhum' )
  g_use( dir_server + 'human_u_', , 'HU_' )
  r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server + 'mo_su', , 'MOSU' )
  g_use( dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU' )
  Set Relation To u_kod into MOSU
  If p_tip_reestr == 1
    r_use( dir_server + 'kart_inv', , 'INV' )
    Index On Str( kod, 7 ) to ( cur_dir + 'tmp_inv' )
  Endif
  r_use( dir_server + 'kartote2', , 'KART2' )
  r_use( dir_server + 'kartote_', , 'KART_' )
  r_use( dir_server + 'kartotek', , 'KART' )
  Set Relation To RecNo() into KART_, To RecNo() into KART2
  r_use( dir_server + 'mo_onkna', dir_server + 'mo_onkna', 'ONKNA' ) // онконаправления
  r_use( dir_server + 'mo_onkco', dir_server + 'mo_onkco', 'ONKCO' )
  r_use( dir_server + 'mo_onksl', dir_server + 'mo_onksl', 'ONKSL' ) // Сведения о случае лечения онкологического заболевания
  r_use( dir_server + 'mo_onkdi', dir_server + 'mo_onkdi', 'ONKDI' ) // Диагностический блок
  r_use( dir_server + 'mo_onkpr', dir_server + 'mo_onkpr', 'ONKPR' ) // Сведения об имеющихся противопоказаниях
  g_use( dir_server + 'mo_onkus', dir_server + 'mo_onkus', 'ONKUS' )
  g_use( dir_server + 'mo_onkle', dir_server + 'mo_onkle', 'ONKLE' )
  g_use( dir_server + 'human_3', { dir_server + 'human_3', dir_server + 'human_32' }, 'HUMAN_3' )
  Set Order To 2 // индекс по 2-му случаю
  g_use( dir_server + 'human_2', , 'HUMAN_2' )
  g_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2, To kod_k into KART
  r_use( dir_exe + '_mo_t2_v1', , 'T21' )
  Index On shifr to ( cur_dir + 'tmp_t21' )
  Use ( cur_dir + 'tmpb' ) new
  If reg_sort == 1
    Index On Upper( fio ) to ( cur_dir + 'tmpb' ) For kod_tmp == _recno .and. plus
  Else
    Index On Str( pz, 2 ) + Str( 10000000 - cena_1, 11, 2 ) to ( cur_dir + 'tmpb' ) For kod_tmp == _recno .and. plus
  Endif
  pkol := psumma := iusl := 0
  Go Top
  Do While !Eof()
    arrLP := {}
    @ MaxRow(), 1 Say lstr( pkol ) Color cColorSt2Msg
    Select HUMAN
    Goto ( tmpb->kod_human )

    otd->( dbGoto( human->OTD ) )
    lTypeLUOnkoDisp := ( otd->tiplu == TIP_LU_ONKO_DISP )

    pkol++
    psumma += human->cena_1
    Select RHUM
    addrec( 6 )
    rhum->REESTR := mkod_reestr
    rhum->KOD_HUM := human->kod
    rhum->REES_ZAP := pkol
    human_->( g_rlock( forever ) )
    If human_->REES_NUM < 99
      human_->REES_NUM := human_->REES_NUM + 1
    Endif
    human_->REESTR := mkod_reestr
    human_->REES_ZAP := pkol
    If tmpb->ishod == 89  // 2-й случай
      Select HUMAN_3
      find ( Str( tmpb->kod_human, 7 ) )
      If Found()
        g_rlock( forever )
        If human_3->REES_NUM < 99
          human_3->REES_NUM := human_3->REES_NUM + 1
        Endif
        human_3->REESTR := mkod_reestr
        human_3->REES_ZAP := pkol
        //
        Select HUMAN
        Goto ( human_3->kod )  // встать на 1-й случай
        human_->( g_rlock( forever ) )
        psumma += human->cena_1
        If human_->REES_NUM < 99
          human_->REES_NUM := human_->REES_NUM + 1
        Endif
        human_->REESTR := mkod_reestr
        human_->REES_ZAP := pkol
      Endif
    Endif
    If pkol % 2000 == 0
      dbUnlockAll()
      dbCommitAll()
    Endif
    Select TMPB
    Skip
  Enddo
  Select REES
  g_rlock( forever )
  rees->KOL := pkol
  rees->SUMMA := psumma
  dbUnlockAll()
  dbCommitAll()
  //
  //
  Private arr_usl_otkaz, adiag_talon[ 16 ]
  //
  // создадим новый XML-документ
  oXmlDoc := hxmldoc():new()

  // заполним корневой элемент XML-документа
  oXmlDoc:add( hxmlnode():new( 'ZL_LIST' ) )
  oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )

  // заполним заголовок XML-документа
  s := '3.11'
  controlVer := _nyear * 100 + _nmonth
  If ( controlVer >= 202201 ) .and. ( p_tip_reestr == 1 ) // с января 2022 года
    s := '3.2'
  Endif
  If ( controlVer >= 202403 ) .and. ( p_tip_reestr == 1 ) // с марта 2024 года
    s := '4.0'
  Endif
  mo_add_xml_stroke( oXmlNode, 'VERSION',s )
  mo_add_xml_stroke( oXmlNode, 'DATA', date2xml( rees->DSCHET ) )
  mo_add_xml_stroke( oXmlNode, 'FILENAME', mo_xml->FNAME )
  mo_add_xml_stroke( oXmlNode, 'SD_Z', lstr( pkol ) )

  // заполним реестр случаев для XML-документа
  oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'SCHET' ) )
  mo_add_xml_stroke( oXmlNode, 'CODE', lstr( code_reestr ) )
  mo_add_xml_stroke( oXmlNode, 'CODE_MO', CODE_MO )
  mo_add_xml_stroke( oXmlNode, 'YEAR', lstr( _NYEAR ) )
  mo_add_xml_stroke( oXmlNode, 'MONTH', lstr( _NMONTH ) )
  mo_add_xml_stroke( oXmlNode, 'NSCHET', lstr( rees->NSCHET ) )
  mo_add_xml_stroke( oXmlNode, 'DSCHET', date2xml( rees->DSCHET ) )
  mo_add_xml_stroke( oXmlNode, 'SUMMAV', Str( psumma, 15, 2 ) )
  // mo_add_xml_stroke(oXmlNode, 'COMENTS', '')
  //
  //
  Select RHUM
  Index On Str( REES_ZAP, 6 ) to ( cur_dir + 'tmp_rhum' ) For REESTR == mkod_reestr
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say Str( rhum->REES_ZAP / pkol * 100, 6, 2 ) + '%' Color cColorSt2Msg
    //
    fl_DISABILITY := is_zak_sl := is_zak_sl_vr := .f.
    lshifr_zak_sl := lvidpoms := cSMOname := ''
    a_usl := {}
    a_usl_name := {}
    a_fusl := {}
    lvidpom := 1
    lfor_pom := 3
    atmpusl := {}
    akslp := {}
    akiro := {}
    mdiagnoz := {}
    mdiagnoz3 := {}
    is_KSG := is_mgi := .f.
    kol_kd := v_reabil_slux := m1veteran := m1mobilbr := 0  // мобильная бригада
    tarif_zak_sl := m1mesto_prov := m1p_otk := 0    // признак отказа
    m1dopo_na := m1napr_v_mo := 0
    arr_mo_spec := {}
    m1napr_stac := 0
    m1profil_stac := m1napr_reab := m1profil_kojki := 0
    pr_amb_reab := fl_disp_nabl := is_disp_DVN := is_disp_DVN_COVID := is_disp_DRZ := .f.
    ldate_next := CToD( '' )
    ar_dn := {}
    is_oncology_smp := is_oncology := 0
    arr_onkna := {}
    arr_onkdi := {}
    arr_onkpr := {}
    arr_onk_usl := {}
    a_otkaz := {}
    arr_nazn := {}

    mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

    flLekPreparat := .f.

    //
    Select HUMAN
    Goto ( rhum->kod_hum )  // встали на 2-ой лист учёта
    kol_sl := iif( human->ishod == 89, 2, 1 )
    ksl_date := nil
    For isl := 1 To kol_sl
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
      f1_create2reestr19( _nyear, _nmonth ) 

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
        // mo_add_xml_stroke(oPAC, 'MO_PR', ???)
        If human_->USL_OK == 1 .and. human_2->VNR > 0
          // стационар + л/у на недоношенного ребёнка
          mo_add_xml_stroke( oPAC, 'VNOV_D', lstr( human_2->VNR ) )
        Endif
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
        // заполним сведения о законченном случае оказания медицинской помощи для XML-документа
        oSLUCH := oZAP:add( hxmlnode():new( 'Z_SL' ) )
        mo_add_xml_stroke( oSLUCH, 'IDCASE', lstr( rhum->REES_ZAP ) )

        If ! Empty( reserveKSG_ID_C ) // проверим GUID для вложенного двойного случая
          mo_add_xml_stroke( oSLUCH, 'ID_C', reserveKSG_ID_C )
          reserveKSG_ID_C := ''
        Else
          mo_add_xml_stroke( oSLUCH, 'ID_C', human_->ID_C )
        Endif

        If p_tip_reestr == 2  // для реестров по диспансеризации
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
        If p_tip_reestr == 1
          lal := iif( kol_sl == 2, 'human_3', 'human_' )
          mo_add_xml_stroke( oSLUCH, 'ISHOD', lstr( &lal.->ISHOD_NEW ) )
          If kol_sl == 2
            mo_add_xml_stroke( oSLUCH, 'VB_P', '1' ) // Признак внутрибольничного перевода при оплате законченного случая как суммы стоимостей пребывания пациента в разных профильных отделениях, каждое из которых оплачивается по КСГ
          Endif
          mo_add_xml_stroke( oSLUCH, 'IDSP', lstr( human_->IDSP ) )
          lal := iif( kol_sl == 2, 'human_3', 'human' )
          mo_add_xml_stroke( oSLUCH, 'SUMV', lstr( &lal.->cena_1, 10, 2 ) )
          Do Case
          Case human_->USL_OK == 1 // стационар
            i := iif( Left( human_->FORMA14, 1 ) == '1', 1, 3 )
          Case human_->USL_OK == 2 // дневной стационар
            i := iif( Left( human_->FORMA14, 1 ) == '2', 2, 3 )
          Case human_->USL_OK == 4 // скорая помощь
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

        If p_tip_reestr == 1
          If kol_sl == 2
            mo_add_xml_stroke( oSLUCH, 'KD_Z', lstr( human_3->k_data - human_3->n_data ) ) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
          Elseif kol_kd > 0
            mo_add_xml_stroke( oSLUCH, 'KD_Z', lstr( kol_kd ) ) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
          Endif
        Endif
        If human_->USL_OK == 1 // стационар
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
        If p_tip_reestr == 1
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
      If ( is_vmp := human_->USL_OK == 1 .and. human_2->VMP == 1 ;// ВМП
        .and. !emptyany( human_2->VIDVMP, human_2->METVMP ) )
        mo_add_xml_stroke( oSL, 'VID_HMP', human_2->VIDVMP )
        mo_add_xml_stroke( oSL, 'METOD_HMP', lstr( human_2->METVMP ) )
      Endif
      otd->( dbGoto( human->OTD ) )
      // if human->K_DATA < 0d20230601 .and. human_->USL_OK == 1 .and. is_otd_dep
      If human_->USL_OK == 1 .and. is_otd_dep .and. ( ! disable_podrazdelenie_tfoms( human->K_DATA ) )
        f_put_glob_podr( human_->USL_OK, human->K_DATA ) // заполнить код подразделения
        If ( i := AScan( mm_otd_dep, {| x| x[ 2 ] == glob_otd_dep } ) ) == 0
          i := 1
        Endif
        mo_add_xml_stroke( oSL, 'LPU_1', lstr( mm_otd_dep[ i, 3 ] ) )
        mo_add_xml_stroke( oSL, 'PODR', lstr( glob_otd_dep ) )
      Endif
      mo_add_xml_stroke( oSL, 'PROFIL', lstr( human_->PROFIL ) )
      If p_tip_reestr == 1
        If human_->USL_OK < 3
          mo_add_xml_stroke( oSL, 'PROFIL_K', lstr( human_2->PROFIL_K ) )
        Endif
        mo_add_xml_stroke( oSL, 'DET', iif( human->VZROS_REB == 0, '0', '1' ) )
        If human_->USL_OK == 3
          If ( s := get_idpc_from_v025_by_number( human_->povod ) ) == ''
            s := '2.6'
          Endif
          If lTypeLUOnkoDisp
            s := '1.3'
          Endif
          if ( ascan( a_usl_name, '2.80.67' ) > 0 ) .or. ( ascan( a_usl_name, '2.88.14' ) > 0 )
            s := '1.0'
          endif
          mo_add_xml_stroke( oSL, 'P_CEL', s )
        Endif
      Endif
      If is_vmp
        mo_add_xml_stroke( oSL, 'TAL_D', date2xml( human_2->TAL_D ) ) // Дата выдачи талона на ВМП
        mo_add_xml_stroke( oSL, 'TAL_P', date2xml( human_2->TAL_P ) ) // Дата планируемой госпитализации в соответствии с талоном на ВМП
        mo_add_xml_stroke( oSL, 'TAL_NUM', human_2->TAL_NUM ) // номер талона на ВМП
      Endif
      mo_add_xml_stroke( oSL, 'NHISTORY', iif( Empty( human->UCH_DOC ), lstr( human->kod ), human->UCH_DOC ) )

      If !is_vmp .and. eq_any( human_->USL_OK, 1, 2 )
        mo_add_xml_stroke( oSL, 'P_PER', lstr( human_2->P_PER ) ) // Признак поступления/перевода
      Endif
      mo_add_xml_stroke( oSL, 'DATE_1', date2xml( human->N_DATA ) )
      mo_add_xml_stroke( oSL, 'DATE_2', date2xml( human->K_DATA ) )
      If p_tip_reestr == 1
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
      If p_tip_reestr == 2  // для реестров по диспансеризации
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
      If p_tip_reestr == 1
        For i := 2 To Len( mdiagnoz )
          If !Empty( mdiagnoz[ i ] )
            mo_add_xml_stroke( oSL, 'DS2',RTrim( mdiagnoz[ i ] ) )
          Endif
        Next
        For i := 1 To Len( mdiagnoz3 ) // ЕЩЁ ДИАГНОЗы ОСЛОЖНЕНИЯ ЗАБОЛЕВАНИЯ
          If !Empty( mdiagnoz3[ i ] )
            mo_add_xml_stroke( oSL, 'DS3', RTrim( mdiagnoz3[ i ] ) )
          Endif
        Next
        If need_reestr_c_zab( human_->USL_OK, mdiagnoz[ 1 ] ) .or. is_oncology_smp > 0
          If lTypeLUOnkoDisp
            mo_add_xml_stroke( oSL, 'C_ZAB', '2' ) //
          Else
            If human_->USL_OK == 3 .and. human_->povod == 4 // если P_CEL=1.3
              mo_add_xml_stroke( oSL, 'C_ZAB', '2' ) // При диспансерном наблюдении характер заболевания не может быть <Острое>
            Else
              mo_add_xml_stroke( oSL, 'C_ZAB', '1' ) // Характер основного заболевания
            Endif
          Endif
        Endif
        If human_->USL_OK < 4
          i := 0
          If human->OBRASHEN == '1' .and. is_oncology < 2
            i := 1
          Endif
          mo_add_xml_stroke( oSL, 'DS_ONK', lstr( i ) )
        Else
          mo_add_xml_stroke( oSL, 'DS_ONK', '0' )
        Endif
        If human_->USL_OK == 3 .and. human_->povod == 4 // Обязательно, если P_CEL=1.3
          s := 2 // взят
          If adiag_talon[ 1 ] == 2 // ранее
            If adiag_talon[ 2 ] == 1
              s := 1 // состоит
            Elseif adiag_talon[ 2 ] == 2
              s := 2 // взят
            Elseif adiag_talon[ 2 ] == 3 // снят
              s := 4 // снят по причине выздоровления
            Elseif adiag_talon[ 2 ] == 4
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
        oKSG := oSL:add( hxmlnode():new( 'KSG_KPG' ) )
        mo_add_xml_stroke( oKSG, 'N_KSG', lshifr_zak_sl )

        if endDateZK >= dPUMPver40   // дата окончания случая после 01.03.24
          mo_add_xml_stroke( oKSG, 'K_ZP', '1' )  // пока ставим 1
        endif

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
      If human_->USL_OK == 3 .and. lTypeLUOnkoDisp  // постановка на учет онкобольного
        oONK_SL := oSL:add( hxmlnode():new( 'ONK_SL' ) )
        mo_add_xml_stroke( oONK_SL, 'DS1_T', lstr( onksl->DS1_T ) )
        mo_add_xml_stroke( oONK_SL, 'STAD', lstr( onksl->STAD ) )
      Endif
      If human_->USL_OK < 4 .and. is_oncology == 2 .and. ! lTypeLUOnkoDisp
        // заполним сведения об онкологии для XML-документа
        oONK_SL := oSL:add( hxmlnode():new( 'ONK_SL' ) )
        mo_add_xml_stroke( oONK_SL, 'DS1_T', lstr( onksl->DS1_T ) )
        If Between( onksl->DS1_T, 0, 4 )
          mo_add_xml_stroke( oONK_SL, 'STAD', lstr( onksl->STAD ) )
          If onksl->DS1_T == 0 .and. human->vzros_reb == 0
            mo_add_xml_stroke( oONK_SL, 'ONK_T', lstr( onksl->ONK_T ) )
            mo_add_xml_stroke( oONK_SL, 'ONK_N', lstr( onksl->ONK_N ) )
            mo_add_xml_stroke( oONK_SL, 'ONK_M', lstr( onksl->ONK_M ) )
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
          if ! empty( arr_onkdi[ j, 1 ] ) // только если заполнена дата исследования
            // заполним сведения о диагностических услугах для XML-документа
            oDIAG := oONK_SL:add( hxmlnode():new( 'B_DIAG' ) )
            mo_add_xml_stroke( oDIAG, 'DIAG_DATE', date2xml( arr_onkdi[ j, 1 ] ) )
            mo_add_xml_stroke( oDIAG, 'DIAG_TIP', lstr( arr_onkdi[ j, 2 ] ) )
            mo_add_xml_stroke( oDIAG, 'DIAG_CODE', lstr( arr_onkdi[ j, 3 ] ) )
            If arr_onkdi[ j, 4 ] > 0
              mo_add_xml_stroke( oDIAG, 'DIAG_RSLT', lstr( arr_onkdi[ j, 4 ] ) )
              mo_add_xml_stroke( oDIAG, 'REC_RSLT', '1' )
            Endif
          endif
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
                old_lek := Space( 6 ) ; old_sh := Space( 10 )
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
                  old_lek := onkle->REGNUM ; old_sh := onkle->CODE_SH
                  Select ONKLE
                  Skip
                Enddo
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
      If p_tip_reestr == 1
        mo_add_xml_stroke( oSL, 'PRVS', put_prvs_to_reestr( human_->PRVS, _NYEAR ) )
        If ( !is_mgi .and. AScan( kod_LIS, glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. eq_any( human_->profil, 6, 34 ) ) .or. human_->profil == 15 // гистология
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
          If ( human_->USL_OK == 1 ) .and. ( human->k_data >= 0d20220101 )
            flLekPreparat := ( human_->PROFIL != 158 ) .and. ( human_->VIDPOM != 32 ) ;
              .and. ( Lower( AllTrim( human_2->PC3 ) ) != 'stt5' )
          Elseif ( human_->USL_OK == 3 ) .and. ( human->k_data >= 0d20220401 )
            flLekPreparat := ( human_->PROFIL != 158 ) .and. ( human_->VIDPOM != 32 ) ;
              .and. ( get_idpc_from_v025_by_number( human_->povod ) == '3.0' )
          Endif
        Endif

        If flLekPreparat
          // добавим в xml-документ информацию о лекарственных препаратах
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
        Endif

        If !Empty( ldate_next )
          mo_add_xml_stroke( oSL, 'NEXT_VISIT', date2xml( BoM( ldate_next ) ) )
        Endif
        //
        j := 0
        If ( ibrm := f_oms_beremenn( mdiagnoz[ 1 ], human->K_DATA ) ) == 1 .and. eq_any( human_->profil, 136, 137 ) // акушерству и гинекологии
          j := iif( human_2->pn2 == 1, 4, 3 )
        Elseif ibrm == 2 .and. human_->USL_OK == 3 // поликлиника
          j := iif( human_2->pn2 == 1, 5, 6 )
          If j == 5 .and. !eq_any( human_->profil, 136, 137 )
            j := 6  // т.е. только акушер-гинеколог может поставить на учёт по беременности
          Endif
        Endif
        If j > 0
          sCOMENTSL += lstr( j )
        Endif
        If human_->USL_OK == 3 .and. eq_any( lvidpom, 1, 11, 12, 13 )
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
          if kart->pn1 == 30 .and. eq_any( hb_main_curOrg:Kod_Tfoms, '101201', '451001', '391002')
            j := 30
          endif
          sCOMENTSL := lstr( j )
        Elseif Between( human->ishod, 301, 302 )
          j := iif( Between( m1mesto_prov, 0, 1 ), m1mesto_prov, 0 )
          sCOMENTSL := lstr( j )
        Endif
      Endif
      If p_tip_reestr == 1 .and. !Empty( sCOMENTSL ) // .and. ! lTypeLUOnkoDisp
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
            mo_add_xml_stroke( oUSL, 'LPU', kod_LIS[ hu->is_edit ] ) // иссл-ие проводится в КДП2 или РДЛ
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
          If p_tip_reestr == 1
            // if human->K_DATA < 0d20230601 .and. human_->USL_OK == 1 .and. is_otd_dep
            If human_->USL_OK == 1 .and. is_otd_dep .and. ( ! disable_podrazdelenie_tfoms( human->K_DATA ) )
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
          If p_tip_reestr == 1
            mo_add_xml_stroke( oUSL, 'DET', iif( human->VZROS_REB == 0, '0', '1' ) )
          Endif
          mo_add_xml_stroke( oUSL, 'DATE_IN', date2xml( c4tod( hu->DATE_U ) ) )
          If p_tip_reestr == 1
            If ! Empty( hu_->DATE_END ) .and. ( hu->KOL_1 > 1 )
              mo_add_xml_stroke( oUSL, 'DATE_OUT', date2xml( hu_->DATE_END ) )
            Else
              mo_add_xml_stroke( oUSL, 'DATE_OUT', date2xml( c4tod( hu_->DATE_U2 ) ) )
            Endif
          Else
            mo_add_xml_stroke( oUSL, 'DATE_OUT', date2xml( c4tod( hu_->DATE_U2 ) ) )
          Endif
          If p_tip_reestr == 1
            // подменим диагноз если необходимо для генно-инженерных препаратов или
            // операции по поводу грыж, взрослые (уровень 4), для случаев проведения
            // антимикробной терапии инфекций, вызванных полирезистентными микроорганизмами
            If lReplaceDiagnose
              mo_add_xml_stroke( oUSL, 'DS', diagnoz_replace )
            Else
              mo_add_xml_stroke( oUSL, 'DS', hu_->kod_diag )
            Endif
          Else
            mo_add_xml_stroke( oUSL, 'P_OTK','0' )
          Endif
          mo_add_xml_stroke( oUSL, 'CODE_USL', lshifr )
          mo_add_xml_stroke( oUSL, 'KOL_USL', lstr( hu->KOL_1, 6, 2 ) )
          mo_add_xml_stroke( oUSL, 'TARIF', lstr( hu->U_CENA, 10, 2 ) )
          mo_add_xml_stroke( oUSL, 'SUMV_USL', lstr( hu->STOIM_1, 10, 2 ) )

          If ( human->k_data >= 0d20210801 .and. p_tip_reestr == 2 ) ;      // правила заполнения с 01.08.21 письмо № 04-18-13 от 20.07.21
            .or. ( endDateZK >= 0d20220101 .and. p_tip_reestr == 1 )  // правила заполнения с 01.01.22 письмо № 04-18?17 от 28.12.2021
            // .or. (human->k_data >= 0d20220101 .and. p_tip_reestr == 1)  // правила заполнения с 01.01.22 письмо № 04-18?17 от 28.12.2021

            If between_date( human->n_data, human->k_data, c4tod( hu->DATE_U ) )
              oMR_USL_N := oUSL:add( hxmlnode():new( 'MR_USL_N' ) )
              mo_add_xml_stroke( oMR_USL_N, 'MR_N', lstr( 1 ) )   // пока ставим 1 исполнитель
              mo_add_xml_stroke( oMR_USL_N, 'PRVS', put_prvs_to_reestr( hu_->PRVS, _NYEAR ) )
              p2->( dbGoto( hu->kod_vr ) )
              mo_add_xml_stroke( oMR_USL_N, 'CODE_MD', p2->snils )
            Endif
          Else  // if (human->k_data < 0d20210801 .and. p_tip_reestr == 2)
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
      If p_tip_reestr == 2 .and. Len( a_otkaz ) > 0 // отказы (диспансеризация или профосмоты несовешеннолетних)
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

          If human->k_data >= 0d20210801 .and. p_tip_reestr == 2 ; // новые правила заполнения с 01.08.21 письмо № 04-18-13 от 20.07.21
            .or. ( endDateZK >= 0d20220101 .and. p_tip_reestr == 1 )  // правила заполнения с 01.01.22 письмо № 04-18?17 от 28.12.2021
            // Закомментировал после разъяснения Л.А.Антоновой 18.08.21
            // oMR_USL_N := oUSL:Add( HXMLNode():New( 'MR_USL_N' ) )
            // mo_add_xml_stroke(oMR_USL_N, 'MR_N', lstr(1))   // уточнить
            // mo_add_xml_stroke(oMR_USL_N, 'PRVS', put_prvs_to_reestr(a_otkaz[j, 5], _NYEAR))
            // mo_add_xml_stroke(oMR_USL_N, 'CODE_MD','0') // не заполняется код врача
          Else  // if human->k_data < 0d20210801 .and. p_tip_reestr == 2
            mo_add_xml_stroke( oUSL, 'PRVS', put_prvs_to_reestr( a_otkaz[ j, 5 ], _NYEAR ) )
            mo_add_xml_stroke( oUSL, 'CODE_MD','0' ) // отказ => 0
          Endif

        Next
      Endif
      // if p_tip_reestr == 1 .and. len(a_fusl) > 0 // добавляем операции
      If Len( a_fusl ) > 0 // добавляем операции // исправил чтобы брала углубленную диспансеризацию COVID
        For j := 1 To Len( a_fusl )
          Select MOHU
          Goto ( a_fusl[ j ] )
          If mohu->kod_vr == 0
            Loop
          Endif
          mohu->( g_rlock( forever ) )
          mohu->REES_ZAP := ++iusl
          lshifr := AllTrim( mosu->shifr1 )
          // заполним сведения об услугах для XML-документа
          oUSL := oSL:add( hxmlnode():new( 'USL' ) )
          mo_add_xml_stroke( oUSL, 'IDSERV', lstr( mohu->REES_ZAP ) )
          mo_add_xml_stroke( oUSL, 'ID_U', mohu->ID_U )
          mo_add_xml_stroke( oUSL, 'LPU', CODE_LPU )
          // if human->K_DATA < 0d20230601 .and. human_->USL_OK == 1 .and. is_otd_dep
          If human_->USL_OK == 1 .and. is_otd_dep .and. ( ! disable_podrazdelenie_tfoms( human->K_DATA ) )
            otd->( dbGoto( mohu->OTD ) )
            f_put_glob_podr( human_->USL_OK, human->K_DATA ) // заполнить код подразделения
            If ( i := AScan( mm_otd_dep, {| x| x[ 2 ] == glob_otd_dep } ) ) == 0
              i := 1
            Endif
            mo_add_xml_stroke( oUSL, 'LPU_1', lstr( mm_otd_dep[ i, 3 ] ) )
            mo_add_xml_stroke( oUSL, 'PODR', lstr( glob_otd_dep ) )
          Endif
          mo_add_xml_stroke( oUSL, 'PROFIL', lstr( mohu->PROFIL ) )
          If p_tip_reestr == 1
            mo_add_xml_stroke( oUSL, 'VID_VME', lshifr )
            mo_add_xml_stroke( oUSL, 'DET', iif( human->VZROS_REB == 0, '0', '1' ) )
          Endif
          mo_add_xml_stroke( oUSL, 'DATE_IN', date2xml( c4tod( mohu->DATE_U ) ) )
          mo_add_xml_stroke( oUSL, 'DATE_OUT', date2xml( c4tod( mohu->DATE_U2 ) ) )
          If p_tip_reestr == 1
            // подменим диагноз если необходимо для генно-инженерных препаратов или
            // операции по поводу грыж, взрослые (уровень 4), для случаев проведения
            // антимикробной терапии инфекций, вызванных полирезистентными микроорганизмами
            If lReplaceDiagnose
              mo_add_xml_stroke( oUSL, 'DS', diagnoz_replace )
            Else
              mo_add_xml_stroke( oUSL, 'DS', mohu->kod_diag )
            Endif
          Endif
          If p_tip_reestr == 2
            // разобраться с отказами услугами ФФОМС
            mo_add_xml_stroke( oUSL, 'P_OTK','0' )
          Endif
          mo_add_xml_stroke( oUSL, 'CODE_USL', lshifr )
          mo_add_xml_stroke( oUSL, 'KOL_USL', lstr( mohu->KOL_1, 6, 2 ) )
          If p_tip_reestr == 1
            mo_add_xml_stroke( oUSL, 'TARIF', lstr( mohu->U_CENA, 10, 2 ) )// lstr(mohu->U_CENA, 10, 2))
            mo_add_xml_stroke( oUSL, 'SUMV_USL', lstr( mohu->STOIM_1, 10, 2 ) )// lstr(mohu->STOIM_1, 10, 2))
          Elseif p_tip_reestr == 2
            mo_add_xml_stroke( oUSL, 'TARIF', '0' )// lstr(mohu->U_CENA, 10, 2))
            mo_add_xml_stroke( oUSL, 'SUMV_USL', '0' )// lstr(mohu->STOIM_1, 10, 2))
          Endif
          // mo_add_xml_stroke(oUSL, 'PRVS', put_prvs_to_reestr(mohu->PRVS, _NYEAR))  // закоментировал 04.08.21
          fl := .f.
          If is_telemedicina( lshifr, @fl ) // не заполняется код врача
            mo_add_xml_stroke( oUSL, 'PRVS', put_prvs_to_reestr( mohu->PRVS, _NYEAR ) )  // добавил 04.08.21
            mo_add_xml_stroke( oUSL, 'CODE_MD', '0' )
          Else
            If ( human->k_data >= 0d20210801 .and. p_tip_reestr == 2 ) ;      // правила заполнения с 01.08.21 письмо № 04-18-13 от 20.07.21
              .or. ( human->k_data >= 0d20220101 .and. p_tip_reestr == 1 )  // правила заполнения с 01.01.22 письмо № 04-18?17 от 28.12.2021
              // if (p_tip_reestr == 1) .and. ((aImpl := ret_impl_V036(lshifr, c4tod(hu_->DATE_U2))) != NIL)
              // // проверим наличие имплантантов
              // IMPL->(dbSeek(str(human->kod, 7), .t.))
              // if IMPL->(found())
              // oMED_DEV := oUSL:Add( HXMLNode():New( 'MED_DEV' ) )
              // mo_add_xml_stroke(oMED_DEV, 'DATE_MED', date2xml(IMPL->DATE_UST))   // пока ставим 1 исполнитель
              // mo_add_xml_stroke(oMED_DEV, 'CODE_MEDDEV', lstr(IMPL->RZN))

              // if (ser_num := chek_implantant_ser_number(IMPL->(recno()))) != nil
              // mo_add_xml_stroke(oMED_DEV, 'NUMBER_SER', alltrim(ser_num))
              // endif
              // endif
              // aImpl := nil
              // ser_num := nil
              // endif
              If ( p_tip_reestr == 1 ) .and. ( Year( human->k_data ) > 2021 ) .and. service_requires_implants( lshifr, c4tod( hu_->DATE_U2 ) )
                For Each row in collect_implantant( human->kod, mohu->( RecNo() ) )
                  oMED_DEV := oUSL:add( hxmlnode():new( 'MED_DEV' ) )
                  mo_add_xml_stroke( oMED_DEV, 'DATE_MED', date2xml( row[ 3 ] ) )
                  mo_add_xml_stroke( oMED_DEV, 'CODE_MEDDEV', lstr( row[ 4 ] ) )
                  mo_add_xml_stroke( oMED_DEV, 'NUMBER_SER', AllTrim( row[ 5 ] ) )
                Next
              Endif

              If between_date( human->n_data, human->k_data, c4tod( mohu->DATE_U ) )
                oMR_USL_N := oUSL:add( hxmlnode():new( 'MR_USL_N' ) )
                mo_add_xml_stroke( oMR_USL_N, 'MR_N', lstr( 1 ) )   // пока ставим 1 исполнитель
                mo_add_xml_stroke( oMR_USL_N, 'PRVS', put_prvs_to_reestr( mohu->PRVS, _NYEAR ) )
                p2->( dbGoto( mohu->kod_vr ) )
                mo_add_xml_stroke( oMR_USL_N, 'CODE_MD', p2->snils )
              Endif
            Else  // if human->k_data < 0d20220101 .and. p_tip_reestr == 1
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
      If p_tip_reestr == 2 .and. !Empty( sCOMENTSL )   // для реестров по диспансеризации
        If ( is_disp_DVN .or. is_disp_DVN_COVID .or. is_disp_DRZ )
          sCOMENTSL += ':'
          If !Empty( ar_dn ) // взят на диспансерное наблюдение
            For i := 1 To 5
              sk := lstr( i )
              pole_diag := 'mdiag' + sk
              pole_1dispans := 'm1dispans' + sk
              pole_dn_dispans := 'mdndispans' + sk
              If !Empty( &pole_diag ) .and. &pole_1dispans == 1 .and. AScan( sadiag1, AllTrim( &pole_diag ) ) > 0 ;
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
    Skip
  Enddo
  dbUnlockAll()
  dbCommitAll()

  stat_msg( 'Запись XML-документа в файл реестра случаев' )

  oXmlDoc:save( AllTrim( mo_xml->FNAME ) + sxml )
  name_zip := AllTrim( mo_xml->FNAME ) + szip
  AAdd( arr_zip, AllTrim( mo_xml->FNAME ) + sxml )
  //
  //
  fl_ver := 311
  stat_msg( 'Составление реестра пациентов' )
  oXmlDoc := hxmldoc():new()
  // заполним корневой элемент реестра пациентов для XML-документа
  oXmlDoc:add( hxmlnode():new( 'PERS_LIST' ) )
  // заполним заголовок файла реестра пациентов для XML-документа
  oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )
  s := '3.11'
  If StrZero( _nyear, 4 ) + StrZero( _nmonth, 2 ) > '201910' // с ноября 2019 года
    fl_ver := 32
    s := '3.2'
  Endif
  mo_add_xml_stroke( oXmlNode, 'VERSION',s )
  mo_add_xml_stroke( oXmlNode, 'DATA', date2xml( rees->DSCHET ) )
  mo_add_xml_stroke( oXmlNode, 'FILENAME', mo_xml->FNAME2 )
  mo_add_xml_stroke( oXmlNode, 'FILENAME1', mo_xml->FNAME )
  Select RHUM
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say Str( rhum->REES_ZAP / pkol * 100, 6, 2 ) + '%' Color cColorSt2Msg
    Select HUMAN
    Goto ( rhum->kod_hum )  // встали на 1-ый лист учёта
    If human->ishod == 89  // а это не 1-ый, а 2-ой л/у
      Select HUMAN_3
      Set Order To 2
      find ( Str( rhum->kod_hum, 7 ) )
      Select HUMAN
      Goto ( human_3->kod )  // встали на 1-й лист учёта
    Endif
    arr_fio := retfamimot( 2, .f. )
    // заполним сведения о пациенте для XML-документа
    oPAC := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'PERS' ) )
    mo_add_xml_stroke( oPAC, 'ID_PAC', human_->ID_PAC )
    If human_->NOVOR == 0
      mo_add_xml_stroke( oPAC, 'FAM', arr_fio[ 1 ] )
      If !Empty( arr_fio[ 2 ] )
        mo_add_xml_stroke( oPAC, 'IM', arr_fio[ 2 ] )
      Endif
      If !Empty( arr_fio[ 3 ] )
        mo_add_xml_stroke( oPAC, 'OT', arr_fio[ 3 ] )
      Endif
      mo_add_xml_stroke( oPAC, 'W', iif( human->pol == 'М', '1', '2' ) )
      mo_add_xml_stroke( oPAC, 'DR', date2xml( human->date_r ) )
      If Empty( arr_fio[ 3 ] )
        mo_add_xml_stroke( oPAC, 'DOST', '1' ) // отсутствует отчество
      Endif
      If Empty( arr_fio[ 2 ] )
        mo_add_xml_stroke( oPAC, 'DOST', '3' ) // отсутствует имя
      Endif
      If p_tip_reestr == 2 // Указывается только для диспансеризации при предоставлении сведений
        If     Len( AllTrim( kart_->PHONE_H ) ) == 11
          mo_add_xml_stroke( oPAC, 'TEL', SubStr( kart_->PHONE_H, 2 ) )
        Elseif Len( AllTrim( kart_->PHONE_M ) ) == 11
          mo_add_xml_stroke( oPAC, 'TEL', SubStr( kart_->PHONE_M, 2 ) )
        Elseif Len( AllTrim( kart_->PHONE_W ) ) == 11
          mo_add_xml_stroke( oPAC, 'TEL', SubStr( kart_->PHONE_W, 2 ) )
        Endif
      Endif
    Else
      mo_add_xml_stroke( oPAC, 'W', iif( human_->pol2 == 'М', '1', '2' ) )
      mo_add_xml_stroke( oPAC, 'DR', date2xml( human_->date_r2 ) )
      mo_add_xml_stroke( oPAC, 'FAM_P', arr_fio[ 1 ] )
      If !Empty( arr_fio[ 2 ] )
        mo_add_xml_stroke( oPAC, 'IM_P', arr_fio[ 2 ] )
      Endif
      If !Empty( arr_fio[ 3 ] )
        mo_add_xml_stroke( oPAC, 'OT_P', arr_fio[ 3 ] )
      Endif
      mo_add_xml_stroke( oPAC, 'W_P', iif( human->pol == 'М', '1', '2' ) )
      mo_add_xml_stroke( oPAC, 'DR_P', date2xml( human->date_r ) )
      If Empty( arr_fio[ 3 ] )
        mo_add_xml_stroke( oPAC, 'DOST_P', '1' ) // отсутствует отчество
      Endif
      If Empty( arr_fio[ 2 ] )
        mo_add_xml_stroke( oPAC, 'DOST_P', '3' ) // отсутствует имя
      Endif
    Endif
    If !Empty( smr := del_spec_symbol( kart_->mesto_r ) )
      mo_add_xml_stroke( oPAC, 'MR', smr )
    Endif
    If human_->vpolis == 3 .and. emptyany( kart_->nom_ud, kart_->nom_ud )
      // для нового полиса паспорт необязателен
    Else
      mo_add_xml_stroke( oPAC, 'DOCTYPE', lstr( kart_->vid_ud ) )
      If !Empty( kart_->ser_ud )
        mo_add_xml_stroke( oPAC, 'DOCSER', kart_->ser_ud )
      Endif
      mo_add_xml_stroke( oPAC, 'DOCNUM', kart_->nom_ud )
    Endif
    If fl_ver == 32 .and. human_->vpolis < 3 .and. !eq_any( Left( human_->OKATO, 2 ), '  ', '18' ) // иногородние
      If !Empty( kart_->kogdavyd )
        mo_add_xml_stroke( oPAC, 'DOCDATE', date2xml( kart_->kogdavyd ) )
      Endif
      If !Empty( kart_->kemvyd ) .and. ;
          !Empty( smr := del_spec_symbol( inieditspr( A__POPUPMENU, dir_server + 's_kemvyd', kart_->kemvyd ) ) )
        mo_add_xml_stroke( oPAC, 'DOCORG', smr )
      Endif
    Endif
    If !Empty( kart->snils )
      mo_add_xml_stroke( oPAC, 'SNILS', Transform( kart->SNILS, picture_pf ) )
    Endif
    If human_->vpolis == 3 .and. Empty( kart_->okatog )
      // для нового полиса место регистрации необязательно
    Else
      mo_add_xml_stroke( oPAC, 'OKATOG', kart_->okatog )
    Endif
    If Len( AllTrim( kart_->okatop ) ) == 11
      mo_add_xml_stroke( oPAC, 'OKATOP', kart_->okatop )
    Endif
    Select RHUM
    Skip
  Enddo
  stat_msg( 'Запись XML-документа в файл реестр пациентов' )
  oXmlDoc:save( AllTrim( mo_xml->FNAME2 ) + sxml )
  AAdd( arr_zip, AllTrim( mo_xml->FNAME2 ) + sxml )
  //
  Close databases
  If chip_create_zipxml( name_zip, arr_zip, .t. )
    Keyboard Chr( K_TAB ) + Chr( K_ENTER )
  Endif

  Return Nil


// 03.05.24 работаем по текущей записи
Function f1_create2reestr19( _nyear, _nmonth )

  Local i, j, lst, s

  fl_DISABILITY := is_zak_sl := is_zak_sl_vr := .f.
  lshifr_zak_sl := lvidpoms := ''
  a_usl := {} ; a_fusl := {} ; lvidpom := 1 ; lfor_pom := 3
  a_usl_name := {}
  atmpusl := {} ; akslp := {} ; akiro := {} ; tarif_zak_sl := human->cena_1
  kol_kd := 0
  is_KSG := is_mgi := .f.
  v_reabil_slux := 0
  m1veteran := 0
  m1mobilbr := 0  // мобильная бригада
  m1mesto_prov := 0
  m1p_otk := 0    // признак отказа
  m1dopo_na := 0
  m1napr_v_mo := 0
  arr_mo_spec := {}
  m1napr_stac := 0
  m1profil_stac := 0
  m1napr_reab := 0
  m1profil_kojki := 0
  pr_amb_reab := .f.
  fl_disp_nabl := .f.
  is_disp_DVN := .f.
  is_disp_DVN_COVID := .f.
  is_disp_DRZ := .f.
  ldate_next := CToD( '' )
  ar_dn := {}
  //
  is_oncology_smp := 0
  is_oncology := f_is_oncology( 1, @is_oncology_smp )
  If p_tip_reestr == 2
    is_oncology := 0
  Endif
  arr_onkna := {}
  Select ONKNA
  find ( Str( human->kod, 7 ) )
  Do While onkna->kod == human->kod .and. !Eof()
    P2TABN->( dbGoto( onkna->KOD_VR ) )
    If !( P2TABN->( Eof() ) ) .and. !( P2TABN->( Bof() ) )
      // aadd(arr_nazn, {3, i, P2TABN->snils, lstr(ret_prvs_V015toV021(P2TABN->PRVS_NEW))}) // теперь каждое назначение в отдельном PRESCRIPTIONS
      mosu->( dbGoto( onkna->U_KOD ) )
      AAdd( arr_onkna, { onkna->NAPR_DATE, onkna->NAPR_V, onkna->MET_ISSL, mosu->shifr1, onkna->NAPR_MO, P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } )
    Else
      // aadd(arr_nazn, {3, i, '', ''}) // теперь каждое назначение в отдельном PRESCRIPTIONS
      mosu->( dbGoto( onkna->U_KOD ) )
      AAdd( arr_onkna, { onkna->NAPR_DATE, onkna->NAPR_V, onkna->MET_ISSL, mosu->shifr1, onkna->NAPR_MO, '', '' } )
    Endif

    // mosu->(dbGoto(onkna->U_KOD))
    // aadd(arr_onkna, {onkna->NAPR_DATE, onkna->NAPR_V, onkna->MET_ISSL,mosu->shifr1, onkna->NAPR_MO})
    Skip
  Enddo
  Select ONKCO
  find ( Str( human->kod, 7 ) )
  //
  Select ONKSL
  find ( Str( human->kod, 7 ) )
  //
  arr_onkdi := {}
  If eq_any( onksl->b_diag, 98, 99 ) 
    Select ONKDI
    find ( Str( human->kod, 7 ) )
    Do While onkdi->kod == human->kod .and. !Eof()
      AAdd( arr_onkdi, { onkdi->DIAG_DATE, onkdi->DIAG_TIP, onkdi->DIAG_CODE, onkdi->DIAG_RSLT } )
      Skip
    Enddo
  Endif
  //
  arr_onkpr := {}
  If human_->USL_OK < 3 // противопоказания по лечению только в стационаре и дневном стационаре
    Select ONKPR
    find ( Str( human->kod, 7 ) )
    Do While onkpr->kod == human->kod .and. !Eof()
      AAdd( arr_onkpr, { onkpr->PROT, onkpr->D_PROT } )
      Skip
    Enddo
  Endif
  If eq_any( onksl->b_diag, 0, 7, 8 ) .and. AScan( arr_onkpr, {| x| x[ 1 ] == onksl->b_diag } ) == 0
    // добавим отказ,не показано,противопоказано по гистологии
    AAdd( arr_onkpr, { onksl->b_diag, human->n_data } )
  Endif
  //
  arr_onk_usl := {}
  If iif( human_2->VMP == 1, .t., Between( onksl->DS1_T, 0, 2 ) )
    Select ONKUS
    find ( Str( human->kod, 7 ) )
    Do While onkus->kod == human->kod .and. !Eof()
      If Between( onkus->USL_TIP, 1, 5 )
        AAdd( arr_onk_usl, onkus->USL_TIP )
      Endif
      Skip
    Enddo
  Endif
  //
  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , , @lst, , @s )
      lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
      If human_->USL_OK == 3 .and. is_usluga_disp_nabl( lshifr )
        ldate_next := c4tod( human->DATE_OPL )
        fl_disp_nabl := .t.
      Endif
      AAdd( atmpusl, lshifr )
      If eq_any( Left( lshifr, 5 ), '1.11.', '55.1.' )
        kol_kd += hu->kol_1
        is_KSG := .t.
      Elseif Left( lshifr, 5 ) == '2.89.'
        pr_amb_reab := .t.
      Elseif Left( lshifr, 5 ) == '60.9.'
        is_mgi := .t.
      Endif
      If !Empty( s ) .and. ',' $ s
        lvidpoms := s
      Endif
      // попытка правки
      If AllTrim( lshifr ) == '2.78.107'
        // терпевт + общая врачебная практика
        If eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '76', '39' )
          lvidpoms := '12'
        Elseif eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '2', '17', '24', '25', '35', '41', '45', '46', ;
            '68', '71', '79', '84', '90', '92', '95' )
          lvidpoms := '13'
        Endif
        // фельдшер
        // lvidpoms := '11'
      Endif
      If ( hu->stoim_1 > 0 .or. Left( lshifr, 3 ) == '71.' ) .and. ( i := ret_vid_pom( 1, lshifr, human->k_data ) ) > 0
        lvidpom := i
      Endif
      If human_->USL_OK == 3
        If f_is_neotl_pom( lshifr )
          lfor_pom := 2 // неотложная
        Elseif eq_any( Left( lshifr, 5 ), '60.4.', '60.5.', '60.6.', '60.7.', '60.8.' )
          Select OTD
          dbGoto( human->otd )
          If FieldNum( 'TIP_OTD' ) > 0 .and. otd->TIP_OTD == 1  // отделение приёмного покоя стационара
            lfor_pom := 2 // неотложная
          Endif
        Endif
      Endif
      If lst == 1
        lshifr_zak_sl := lshifr
        If f_is_zak_sl_vr( lshifr ) // зак.случай в п-ке
          is_zak_sl_vr := .t.
        Else
          is_zak_sl_vr := .t. // КСГ
          If human_->USL_OK < 3 .and. p_tip_reestr == 1
            tarif_zak_sl := hu->STOIM_1
            If !Empty( human_2->pc1 )
              akslp := list2arr( human_2->pc1 )
            Endif
            If !Empty( human_2->pc2 )
              akiro := list2arr( human_2->pc2 )
            Endif
          Endif
          If !Empty( akslp ) .or. !Empty( akiro )
            otd->( dbGoto( human->OTD ) )
            f_put_glob_podr( human_->USL_OK, human->K_DATA ) // заполнить код подразделения
            if isnil( ksl_date )  // это не двойной случай
              tarif_zak_sl := fcena_oms( lshifr, ( human->vzros_reb == 0 ), human->k_data )
            else
              tarif_zak_sl := fcena_oms( lshifr, ( human->vzros_reb == 0 ), ksl_date )
            endif
          Endif
        Endif
      Else
        AAdd( a_usl, hu->( RecNo() ) )
        AAdd( a_usl_name, lshifr )
      Endif
    Endif
    Select HU
    Skip
  Enddo
  If human_->USL_OK == 1 .and. human_2->VMP == 1 .and. !emptyany( human_2->VIDVMP, human_2->METVMP ) // ВМП
    is_KSG := .f.
  Endif
  If !Empty( lvidpoms )
    If !eq_ascan( atmpusl, '55.1.2', '55.1.3' ) .or. glob_mo[ _MO_KOD_TFOMS ] == '801935' // ЭКО-Москва
      lvidpoms := ret_vidpom_licensia( human_->USL_OK, lvidpoms, human_->profil ) // только для дн.стационара при стационаре
    Elseif eq_ascan( atmpusl, '55.1.2' ) .and. glob_mo[ _MO_KOD_TFOMS ] == '805960'  // грязелечебница
      lvidpoms := ret_vidpom_licensia( human_->USL_OK, lvidpoms, human_->profil ) // только для дн.стационара при стационаре
    Else
      If eq_ascan( atmpusl, '55.1.3' )
        lvidpoms := ret_vidpom_st_dom_licensia( human_->USL_OK, lvidpoms, human_->profil )
      Endif
    Endif
    If !Empty( lvidpoms ) .and. !( ',' $ lvidpoms )
      lvidpom := Int( Val( lvidpoms ) )
      lvidpoms := ''
    Endif
  Endif
  If !Empty( lvidpoms )
    If eq_ascan( atmpusl, '55.1.1', '55.1.4' )
      If '31' $ lvidpoms
        lvidpom := 31
      Endif
    Elseif eq_ascan( atmpusl, '55.1.2', '55.1.3', '2.76.6', '2.76.7', '2.81.67' )
      If eq_any( human_->PROFIL, 57, 68, 97 ) // терапия,педиатр,врач общ.практики
        If '12' $ lvidpoms
          lvidpom := 12
        Endif
      Else
        If '13' $ lvidpoms
          lvidpom := 13
        Endif
      Endif
    Elseif eq_ascan( atmpusl, '2.78.109' )
      If eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '39', '69', '71', '76', '95' )
        // врачи
        lvidpom := 12
      elseif eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '2', '17', '24', '35', ;
        '41', '45', '46', '79', '84', '90', '92' )
        // врачи специализированнные
        lvidpom := 13
      elseif eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '206', '207' )
        // фельдшеры
        lvidpom := 11
      endif
    Elseif eq_ascan( atmpusl, '2.78.110' )
      // врачи специализированнные
      If eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '9', '41' )
        lvidpom := 13
      endif
    Elseif eq_ascan( atmpusl, '2.78.111' )
      // врачи
      If eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '39', '76', '95' )
        lvidpom := 12
      elseIf eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '92' )
        // врачи специализированнные
        lvidpom := 13
      elseif eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '206' )
        // фельдшеры
        lvidpom := 11
      endif
    Elseif eq_ascan( atmpusl, '2.78.112' )
      // врачи
      If eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '39', '76', '95' )
        lvidpom := 12
      elseIf eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '25' )
        // врачи специализированнные
        lvidpom := 13
      elseif eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '206' )
        // фельдшеры
        lvidpom := 11
      endif
    Elseif eq_ascan( atmpusl, '2.78.107' )
      // терпевт + общая врачебная практика
      If eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '76', '39' )
        lvidpom := 12
      Elseif eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '2', '17', '24', '25', '35', '41', '45', '46', ;
          '68', '71', '79', '84', '90', '92', '95' )
        lvidpom := 13
      Endif
      // фельдшер
      // lvidpoms := '11'
    Endif
  Endif
  Select MOHU
  find ( Str( human->kod, 7 ) )
  Do While mohu->kod == human->kod .and. !Eof()
    AAdd( a_fusl, mohu->( RecNo() ) )
    Skip
  Enddo
  a_otkaz := {}
  arr_nazn := {}
  If eq_any( human->ishod, 101, 102 ) // дисп-ия детей-сирот
    read_arr_dds( human->kod )
  Elseif eq_any( human->ishod, 301, 302 ) // профосмотры несовершеннолетних
    arr_usl_otkaz := {}
    read_arr_pn( human->kod )
    If ValType( arr_usl_otkaz ) == 'A'
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) > 9 .and. ValType( ar[ 5 ] ) == 'C' .and. ;
            ValType( ar[ 10 ] ) == 'C' .and. ar[ 10 ] $ 'io'
          lshifr := AllTrim( ar[ 5 ] )
          ldate := human->N_DATA // дата
          If ValType( ar[ 9 ] ) == 'D'
            ldate := ar[ 9 ]
          Endif
          If ar[ 10 ] == 'i' // исследования
            If ( i := AScan( np_arr_issled, {| x| ValType( x[ 1 ] ) == 'C' .and. x[ 1 ] == lshifr } ) ) > 0
              AAdd( a_otkaz, { lshifr, ;
                ar[ 6 ], ; // диагноз
              ldate, ; // дата
              correct_profil( ar[ 4 ] ), ; // профиль
              ar[ 2 ], ; // специальность
              0, ;     // цена
              1 } )     // 1-отказ, 2-невозможность
            Endif
          Elseif ( i := AScan( np_arr_osmotr, {| x| ValType( x[ 1 ] ) == 'C' .and. x[ 1 ] == lshifr } ) ) > 0 // осмотры
            If ( i := AScan( np_arr_osmotr_KDP2, {| x| x[ 1 ] == lshifr } ) ) > 0
              lshifr := np_arr_osmotr_KDP2[ i, 3 ]  // замена врачебного приёма на 2.3.*
            Endif
            AAdd( a_otkaz, { lshifr, ;
              ar[ 6 ], ; // диагноз
            ldate, ; // дата
            correct_profil( ar[ 4 ] ), ; // профиль
            ar[ 2 ], ; // специальность
            0, ;     // цена
            1 } )     // 1-отказ, 2-невозможность
          Endif
        Endif
      Next j
    Endif
  Elseif Between( human->ishod, 201, 205 ) // дисп-ия I этап или профилактика
    is_disp_DVN := .t.
    arr_usl_otkaz := {}
    For i := 1 To 5
      sk := lstr( i )
      pole_diag := 'mdiag' + sk
      pole_1dispans := 'm1dispans' + sk
      pole_dn_dispans := 'mdndispans' + sk
      &pole_diag := Space( 6 )
      &pole_1dispans := 0
      &pole_dn_dispans := CToD( '' )
    Next
    read_arr_dvn( human->kod )
    If ValType( arr_usl_otkaz ) == 'A' .and. eq_any( human->ishod, 201, 203 ) // не II этап
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) >= 10 .and. ValType( ar[ 5 ] ) == 'C'
          lshifr := AllTrim( ar[ 5 ] )
          If ( i := AScan( dvn_arr_usl, {| x| ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == lshifr } ) ) > 0
            If ValType( ar[ 10 ] ) == 'N' .and. Between( ar[ 10 ], 1, 2 )
              AAdd( a_otkaz, { lshifr, ;
                ar[ 6 ], ; // диагноз
              human->N_DATA, ; // дата
              correct_profil( ar[ 4 ] ), ; // профиль
              ar[ 2 ], ; // специальность
              ar[ 8 ], ; // цена
              ar[ 10 ] } ) // 1-отказ, 2-невозможность
            Endif
          Endif
        Endif
      Next j
    Endif
  Elseif Between( human->ishod, 401, 402 ) // углубленная диспансеризация после COVID
    is_disp_DVN_COVID := .t.
    arr_usl_otkaz := {}
    For i := 1 To 5
      sk := lstr( i )
      pole_diag := 'mdiag' + sk
      pole_1dispans := 'm1dispans' + sk
      pole_dn_dispans := 'mdndispans' + sk
      &pole_diag := Space( 6 )
      &pole_1dispans := 0
      &pole_dn_dispans := CToD( '' )
    Next
    read_arr_dvn_covid( human->kod )
    If ValType( arr_usl_otkaz ) == 'A'
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) >= 10 .and. ValType( ar[ 5 ] ) == 'C'
          lshifr := AllTrim( ar[ 5 ] )
          If ( i := AScan( uslugietap_dvn_covid( iif( human->ishod == 401, 1, 2 ) ), {| x| ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == lshifr } ) ) > 0
          Else   // записываем только федеральные услуги
            If ValType( ar[ 10 ] ) == 'N' .and. Between( ar[ 10 ], 1, 2 )
              AAdd( a_otkaz, { lshifr, ;
                ar[ 6 ], ; // диагноз
              human->N_DATA, ; // дата
              correct_profil( ar[ 4 ] ), ; // профиль
              ar[ 2 ], ; // специальность
              ar[ 8 ], ; // цена
              ar[ 10 ] } ) // 1-отказ, 2-невозможность
            Endif
          Endif
        Endif
      Next j
    Endif
  elseif Between( human->ishod, BASE_ISHOD_RZD + 1, BASE_ISHOD_RZD + 2 ) // диспансеризации репродуктивного здоровья
    is_disp_DRZ := .t.
    arr_usl_otkaz := {}
    arr_ne_nazn := {}
    For i := 1 To 5
      sk := lstr( i )
      pole_diag := 'mdiag' + sk
      pole_1dispans := 'm1dispans' + sk
      pole_dn_dispans := 'mdndispans' + sk
      &pole_diag := Space( 6 )
      &pole_1dispans := 0
      &pole_dn_dispans := CToD( '' )
    Next
    read_arr_drz( human->kod )
    // не понятно что делать с неназначенными услугами
    If ValType( arr_ne_nazn ) == 'A'
      For j := 1 To Len( arr_ne_nazn )
        ar := arr_ne_nazn[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) >= 10 .and. ValType( ar[ 5 ] ) == 'C'
          lshifr := AllTrim( ar[ 5 ] )

          If ( i := AScan( uslugietap_drz( iif( human->ishod == BASE_ISHOD_RZD + 1, 1, 2 ), count_years( human->DATE_R, human->k_data ), human->pol ), {| x| ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == lshifr } ) ) > 0
//            
          Else   // записываем только федеральные услуги
            If ValType( ar[ 10 ] ) == 'N' .and. Between( ar[ 10 ], 1, 2 )
              AAdd( a_otkaz, { lshifr, ;
                ar[ 6 ], ; // диагноз
              human->N_DATA, ; // дата
              correct_profil( ar[ 4 ] ), ; // профиль
              ar[ 2 ], ; // специальность
              ar[ 8 ], ; // цена
              ar[ 10 ] } ) // 1-отказ, 2-невозможность
            Endif
          Endif
        Endif
      Next j
    Endif
  Endif
  If m1dopo_na > 0
    For i := 1 To 4
      If IsBit( m1dopo_na, i )
        If mtab_v_dopo_na != 0
          If P2TABN->( dbSeek( Str( mtab_v_dopo_na, 5 ) ) )
            AAdd( arr_nazn, { 3, i, P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } ) // теперь каждое назначение в отдельном PRESCRIPTIONS
          Else
            AAdd( arr_nazn, { 3, i, '', '' } ) // теперь каждое назначение в отдельном PRESCRIPTIONS
          Endif
        Else
          AAdd( arr_nazn, { 3, i, '', '' } ) // теперь каждое назначение в отдельном PRESCRIPTIONS
        Endif
      Endif
    Next
  Endif
  If Between( m1napr_v_mo, 1, 2 ) .and. !Empty( arr_mo_spec )
    For i := 1 To Len( arr_mo_spec ) // теперь каждая специальность в отдельном PRESCRIPTIONS
      If mtab_v_mo != 0
        If P2TABN->( dbSeek( Str( mtab_v_mo, 5 ) ) )
          AAdd( arr_nazn, { m1napr_v_mo, put_prvs_to_reestr( -arr_mo_spec[ i ], _NYEAR ), P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } )  // '-', т.к. спец-ть была в кодировке V015
        Else
          AAdd( arr_nazn, { m1napr_v_mo, put_prvs_to_reestr( -arr_mo_spec[ i ], _NYEAR ), '', '' } ) // '-', т.к. спец-ть была в кодировке V015
        Endif
      Else
        AAdd( arr_nazn, { m1napr_v_mo, put_prvs_to_reestr( -arr_mo_spec[ i ], _NYEAR ), '', '' } ) // '-', т.к. спец-ть была в кодировке V015
      Endif
    Next
  Endif
  If Between( m1napr_stac, 1, 2 ) .and. m1profil_stac > 0
    If mtab_v_stac != 0
      If P2TABN->( dbSeek( Str( mtab_v_stac, 5 ) ) )
        AAdd( arr_nazn, { iif( m1napr_stac == 1, 5, 4 ), m1profil_stac, P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } )
      Else
        AAdd( arr_nazn, { iif( m1napr_stac == 1, 5, 4 ), m1profil_stac, '', '' } )
      Endif
    Else
      AAdd( arr_nazn, { iif( m1napr_stac == 1, 5, 4 ), m1profil_stac, '', '' } )
    Endif
  Endif
  If m1napr_reab == 1 .and. m1profil_kojki > 0
    If mtab_v_reab != 0
      If P2TABN->( dbSeek( Str( mtab_v_reab, 5 ) ) )
        AAdd( arr_nazn, { 6, m1profil_kojki, P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } )
      Else
        AAdd( arr_nazn, { 6, m1profil_kojki, '', '' } )
      Endif
    Else
      AAdd( arr_nazn, { 6, m1profil_kojki, '', '' } )
    Endif
  Endif
  cSMOname := ''
  If AllTrim( human_->smo ) == '34'
    cSMOname := ret_inogsmo_name( 2 )
  Endif
  mdiagnoz := diag_for_xml( , .t., , , .t. )
  If p_tip_reestr == 1
    If glob_mo[ _MO_IS_UCH ] .and. ;                    // наше МО имеет прикреплённое население
        human_->USL_OK == 3 .and. ;                    // поликлиника
        kart2->MO_PR == glob_MO[ _MO_KOD_TFOMS ] .and. ; // прикреплён к нашему МО
      Between( kart_->INVALID, 1, 4 )                    // инвалид
      Select INV
      find ( Str( human->kod_k, 7 ) )
      If Found() .and. !emptyany( inv->DATE_INV, inv->PRICH_INV )
        // дата начала лечения отстоит от даты первичного установления инвалидности не более чем на год
        fl_DISABILITY := ( inv->DATE_INV < human->n_data .and. human->n_data <= AddMonth( inv->DATE_INV, 12 ) )
      Endif
    Endif
  Else
    If human->OBRASHEN == '1' .and. AScan( mdiagnoz, {| x| PadR( x, 5 ) == 'Z03.1' } ) == 0
      AAdd( mdiagnoz, 'Z03.1' )
    Endif
    AFill( adiag_talon, 0 )
    For i := 1 To 16
      adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
    Next
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

  Return Nil

// 10.01.24
Function create1reestr19( _recno, _nyear, _nmonth )

  Local buf := SaveScreen(), s, i, j, pole
  Local nameArr // , funcGetPZ
  local lenPZ := 0  // кол-во строк план заказа на год составления реестра

  Private mpz, oldpz, atip
//  private p_array_PZ  // перенес в create_reestr

  // nameArr := 'glob_array_PZ_' + last_digits_year( _nyear )
  // p_array_PZ := &nameArr
  // funcGetPZ := 'get_array_PZ_' + last_digits_year( _nyear ) + '()'
  // p_array_PZ := &funcGetPZ

//  p_array_PZ := get_array_pz( _nyear )  // перенес в create_reestr
  lenPZ := len( p_array_PZ )

  mpz := Array( lenPZ + 1 )
  oldpz := Array( lenPZ + 1 )
  atip := Array( lenPZ + 1 )

//  For j := 0 To 150    // для таблицы _moXunit 03.02.23
  For j := 0 To lenPZ    // для таблицы _moXunit 03.02.23
    pole := 'tmp->PZ' + lstr( j )
    mpz[ j + 1 ] := oldpz[ j + 1 ] := &pole
    atip[ j + 1 ] := '-'
    If ( i := AScan( p_array_PZ, {| x| x[ 1 ] == j } ) ) > 0
      atip[ j + 1 ] := p_array_PZ[ i, 4 ]
    Endif
  Next

  Private pkol := tmp->kol, psumma := tmp->summa, pnyear := _nyear
  Private old_kol := pkol, old_summa := psumma, p_blk := {| mkol, msum| f_blk_create1reestr19( _nyear ) }
  Close databases
  r_use( dir_server + 'human_3', { dir_server + 'human_3', dir_server + 'human_32' }, 'HUMAN_3' )
  Set Order To 2
  r_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  Use ( cur_dir + 'tmpb' ) New Alias TMP
  Set Relation To kod_human into HUMAN
  Index On Upper( human->fio ) + DToS( tmp->k_data ) to ( cur_dir + 'tmpb' ) For kod_tmp == _recno
  Go Top
  Eval( p_blk )
  If alpha_browse( 3, 0, MaxRow() -4, 79, 'f1create1reestr19', color0, ;
      'Составление реестра случаев за ' + mm_month[ _nmonth ] + Str( _nyear, 5 ) + ' года', 'BG+/GR', ;
      .t., .t., , , 'f2create1reestr19', , ;
      { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B', , 300 } )
    If pkol > 0 .and. ( j := f_alert( { '', ;
        'Каким образом сортировать реестр, отправляемый в ТФОМС', ;
        '' }, ;
        { ' по ~ФИО пациента ', ' по ~убыванию стоимости ' }, ;
        1, 'W/RB', 'G+/RB', MaxRow() -6, , 'BG+/RB, W+/R, W+/RB, GR+/R' ) ) > 0
      f_message( { 'Системная дата: ' + date_month( sys_date, .t. ), ;
        'Обращаем Ваше внимание, что', ;
        'реестр будет создан с этой датой.', ;
        '', ;
        'Изменить её будет НЕВОЗМОЖНО!', ;
        '', ;
        'Сортировка реестра: ' + { 'по ФИО пациента', 'по убыванию стоимости лечения' }[ j ] }, , ;
        'GR+/R', 'W+/R' )
      If f_esc_enter( 'составления реестра' )
        RestScreen( buf )
        create2reestr19( _recno, _nyear, _nmonth, j )
      Endif
    Endif
  Endif
  Close databases
  RestScreen( buf )

  Return Nil

// 21.05.17
Function f_blk_create1reestr19( _nyear )

  Local i, s, ta[ 2 ], sh := MaxCol() + 1

  s := 'Случаев - ' + expand_value( pkol ) + ' на сумму ' + expand_value( psumma, 2 ) + ' руб.'
  @ 0, 0 Say PadC( s, sh ) Color color1
  s := ''
  For i := 1 To Len( mpz )
    If !Empty( mpz[ i ] )
      s += AllTrim( str_0( mpz[ i ], 9, 2 ) ) + ' ' + atip[ i ] + ', '
    Endif
  Next
  If !Empty( s )
    s := '(п/з: ' + SubStr( s, 1, Len( s ) -2 ) + ')'
  Endif
  perenos( ta, s, sh )
  For i := 1 To 2
    @ i, 0 Say PadC( AllTrim( ta[ i ] ), sh ) Color color1
  Next

  Return Nil

// 19.01.20
Static Function f_p_z19( _pzkol, _pz, k )

  Local s, s2, i

  s2 := AllTrim( str_0( _pzkol, 9, 2 ) )
  s := atip[ _pz + 1 ]
  If ( i := AScan( p_array_PZ, {| x| x[ 1 ] == _pz } ) ) > 0 .and. !Empty( p_array_PZ[ i, 5 ] )
    s2 += p_array_PZ[ i, 5 ]
  Endif

  Return iif( k == 1, s, s2 )

// 06.02.19
Function f1create1reestr19( oBrow )

  Local oColumn, tmp_color, blk_color := {|| if( tmp->plus, { 1, 2 }, { 3, 4 } ) }, n := 32

  oColumn := TBColumnNew( ' ', {|| if( tmp->plus, '', ' ' ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Ф.И.О. больного', n ), {|| iif( tmp->ishod == 89, PadR( human->fio, n -4 ) + ' 2сл', PadR( human->fio, n ) ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'План-заказ', {|| PadC( f_p_z19( tmp->pzkol, tmp->pz, 1 ), 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Кол-во', {|| PadC( f_p_z19( tmp->pzkol, tmp->pz, 2 ), 6 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Нача-; ло', {|| Left( DToC( tmp->n_data ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Окончан.;лечения', {|| date_8( tmp->k_data ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Стоимость; лечения', {|| put_kope( tmp->cena_1, 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  tmp_color := SetColor( 'N/BG' )
  @ MaxRow() -3, 0 Say PadR( ' <Esc> - выход     <Enter> - подтверждение составления реестра', 80 )
  @ MaxRow() -2, 0 Say PadR( ' <Ins> - отметить одного пациента или снять отметку с одного пациента', 80 )
  @ MaxRow() -1, 0 Say PadR( ' <+> - отметить всех пациентов (или по одному виду ПЛАНА-ЗАКАЗА) ', 80 )
  @ MaxRow() -0, 0 Say PadR( ' <-> - снять со всех отметки (никто не попадает в реестр)', 80 )
  mark_keys( { '<Esc>', '<Enter>', '<Ins>', '<+>', '<->', '<F9>' }, 'R/BG' )
  SetColor( tmp_color )

  Return Nil

// 19.01.20
Function f2create1reestr19( nKey, oBrow )

  Local buf, rec, k := -1, s, i, j, mas_pmt := {}, arr, r1, r2

  Do Case
  Case nkey == K_INS
    Replace tmp->plus With !tmp->plus
    j := tmp->pz + 1
    i := AScan( p_array_PZ, {| x| x[ 1 ] == tmp->PZ } )
    If tmp->plus
      psumma += tmp->cena_1
      pkol++
      If i > 0 .and. !Empty( p_array_PZ[ i, 5 ] )
        mpz[ j ] ++
      Else
        mpz[ j ] += tmp->PZKOL
      Endif
    Else
      psumma -= tmp->cena_1
      pkol--
      If i > 0 .and. !Empty( p_array_PZ[ i, 5 ] )
        mpz[ j ] --
      Else
        mpz[ j ] -= tmp->PZKOL
      Endif
    Endif
    Eval( p_blk )
    k := 0
    Keyboard Chr( K_TAB )
  Case nkey == 43  // +
    arr := {}
    AAdd( mas_pmt, 'Отметить всех пациентов' )
    AAdd( arr, -1 )
    If !Empty( oldpz[ 1 ] )
      AAdd( mas_pmt, 'Отметить неопределённых пациентов' )
      AAdd( arr, 0 )
    Endif
    For j := 2 To Len( oldpz )
      If !Empty( oldpz[ j ] ) .and. ( i := AScan( p_array_PZ, {| x| x[ 1 ] == j -1 } ) ) > 0
        AAdd( mas_pmt, 'Отметить "' + p_array_PZ[ i, 3 ] + '"' )
        AAdd( arr, j -1 )
      Endif
    Next
    r1 := 12
    r2 := r1 + Len( mas_pmt ) + 1
    If r2 > MaxRow() -2
      r2 := MaxRow() -2
      r1 := r2 - Len( mas_pmt ) -1
      If r1 < 2
        r1 := 2
      Endif
    Endif
    If ( j := popup_scr( r1, 12, r2, 67, mas_pmt, 1, color5, .t. ) ) > 0
      j := arr[ j ]
      rec := RecNo()
      buf := save_maxrow()
      mywait()
      If j == -1
        tmp->( dbEval( {|| tmp->plus := .t. } ) )
        psumma := old_summa
        pkol := old_kol
        AEval( mpz, {| x, i| mpz[ i ] := oldpz[ i ] } )
      Else
        psumma := pkol := 0
        AFill( mpz, 0 )
        mpz[ j + 1 ] := oldpz[ j + 1 ]
        Go Top
        Do While !Eof()
          If tmp->pz == j
            tmp->plus := .t.
            psumma += tmp->cena_1
            pkol++
          Else
            tmp->plus := .f.
          Endif
          Skip
        Enddo
      Endif
      Goto ( rec )
      rest_box( buf )
      Eval( p_blk )
      k := 0
    Endif
  Case nkey == 45  // -
    rec := RecNo()
    buf := save_maxrow()
    mywait()
    tmp->( dbEval( {|| tmp->plus := .f. } ) )
    Goto ( rec )
    rest_box( buf )
    psumma := pkol := 0
    AFill( mpz, 0 )
    Eval( p_blk )
    k := 0
  Endcase

  Return k
