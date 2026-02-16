#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 03.02.26 ДВН - добавление или редактирование случая (листа учета)
Function oms_sluch_dvn( Loc_kod, kod_kartotek, f_print )

  // Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  // f_print - наименование функции для печати
  // Static sadiag1
  Static st_N_DATA, st_K_DATA, s1dispans := 1
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, arr_del := {}, mrec_hu := 0, ;
    buf := SaveScreen(), tmp_color := SetColor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', arr_usl := {}, ah, ;
    i, j, k, s, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, ar, larr, lu_kod, ;
    fl, tmp_help := chm_help_code, fl_write_sluch := .f., mu_cena, lrslt_1_etap := 0, ;
    sk
  //
  Private tmp_V040 := create_classif_ffoms( 2, 'V040' ) // MOP

  Default st_N_DATA To sys_date, st_K_DATA To sys_date
  Default Loc_kod To 0, kod_kartotek To 0
  //
  Private oms_sluch_DVN := .t., ps1dispans := s1dispans, is_prazdnik
  Private mfio := Space( 50 ), mpol, mdate_r, madres, mvozrast, mdvozrast, ;
    M1VZROS_REB, MVZROS_REB, m1novor := 0, ;
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-ОМС, 1-компании, 3-комитеты/ЛПУ, 5-личный счет
    msmo := '34007', rec_inogSMO := 0, ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := Space( 100 ), ;
    mvidpolis, m1vidpolis := 1, mspolis := Space( 10 ), mnpolis := Space( 20 )
  Private mkod := Loc_kod, mtip_h, is_talon := .f., mshifr_zs := '', ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    M1LPU := glob_uch[ 1 ], MLPU, ;
    M1OTD := glob_otd[ 1 ], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MRAB_NERAB, M1RAB_NERAB := 0, ; // 0-работающий, 1 -неработающий
    M1VZ := 1, ;
    mveteran, m1veteran := 0, ;
    mmobilbr, m1mobilbr := 0, ;
    MUCH_DOC    := Space( 10 ), ; // вид и номер учетного документа
    MKOD_DIAG   := Space( 5 ), ; // шифр 1-ой осн.болезни
    MKOD_DIAG2  := Space( 5 ), ; // шифр 2-ой осн.болезни
    MKOD_DIAG3  := Space( 5 ), ; // шифр 3-ой осн.болезни
    MKOD_DIAG4  := Space( 5 ), ; // шифр 4-ой осн.болезни
    MSOPUT_B1   := Space( 5 ), ; // шифр 1-ой сопутствующей болезни
    MSOPUT_B2   := Space( 5 ), ; // шифр 2-ой сопутствующей болезни
    MSOPUT_B3   := Space( 5 ), ; // шифр 3-ой сопутствующей болезни
    MSOPUT_B4   := Space( 5 ), ; // шифр 4-ой сопутствующей болезни
    MDIAG_PLUS  := Space( 8 ), ; // дополнения к диагнозам
    adiag_talon[ 16 ], ; // из статталона к диагнозам
    m1rslt  := 317, ; // результат (присвоена I группа здоровья)
    m1ishod := 306, ; // исход = осмотр
    MN_DATA := st_N_DATA, ; // дата начала лечения
    MK_DATA := st_K_DATA, ; // дата окончания лечения
    MVRACH := Space( 10 ), ; // фамилия и инициалы лечащего врача
    M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0, ; // код, таб.№ и спец-ть лечащего врача
    m1povod  := 4, ;   // Профилактический
    m1travma := 0, ;
    m1USL_OK := USL_OK_POLYCLINIC, ; // поликлиника
    m1VIDPOM :=  1, ; // первичная
    m1PROFIL := 97, ; // 97-терапия, 57-общая врач.практика (семейн.мед-а), 42-лечебное дело
    m1IDSP   := 11, ; // доп.диспансеризация
    mcena_1 := 0, ;
    m1MOP := 1, mMOP  // место обращения (посещения) tmp_V040
  //
  Private arr_usl_dop := {}, arr_usl_otkaz := {}, arr_otklon := {}, m1p_otk := 0
  Private metap := 0, ;  // 1-первый этап, 2-второй этап, 3-профилактика
    m1ndisp := 3, mndisp, is_dostup_2_year := .f., mnapr_onk := Space( 10 ), m1napr_onk := 0, ;
    mWEIGHT := 0, ;   // вес в кг
    mHEIGHT := 0, ;   // рост в см
    mOKR_TALII := 0, ; // окружность талии в см
    mtip_mas, m1tip_mas := 0, ;
    mkurenie, m1kurenie := 0, ; //
    mriskalk, m1riskalk := 0, ; //
    mpod_alk, m1pod_alk := 0, ; //
    mpsih_na, m1psih_na := 0, ; //
    mfiz_akt, m1fiz_akt := 0, ; //
    mner_pit, m1ner_pit := 0, ; //
    maddn, m1addn := 0, mad1 := 120, mad2 := 80, ; // давление
    mholestdn, m1holestdn := 0, mholest := 0, ; // '99.99'
    mglukozadn, m1glukozadn := 0, mglukoza := 0, ; // '99.99'
    mssr := 0, ; // '99'
    mgruppa, m1gruppa := 9      // группа здоровья
  Private mot_nasl1, m1ot_nasl1 := 0, mot_nasl2, m1ot_nasl2 := 0, ;
    mot_nasl3, m1ot_nasl3 := 0, mot_nasl4, m1ot_nasl4 := 0
  Private mdispans, m1dispans := 0, mnazn_l, m1nazn_l  := 0, ;
    mdopo_na, m1dopo_na := 0, mssh_na, m1ssh_na  := 0, ;
    mspec_na, m1spec_na := 0, msank_na, m1sank_na := 0
  Private mvar, m1var
  Private mm_ndisp := { ;
    { 'Диспансеризация I  этап', 1 }, ;
    { 'Диспансеризация II этап', 2 }, ;
    { 'Профилактический осмотр', 3 }, ;
    { 'Дисп.1этап(раз в 2года)', 4 }, ;
    { 'Дисп.2этап(раз в 2года)', 5 } }
  Private mm_gruppa, mm_ndisp1, is_disp_19 := .t., ;
    is_disp_21 := .t., is_disp_nabl := .f.
//      is_disp_24 := .t.

  Private mnapr_v_mo, m1napr_v_mo := 0, mm_napr_v_mo := arr_mm_napr_v_mo(), ;
    arr_mo_spec := {}, ma_mo_spec, m1a_mo_spec := 1
  Private mnapr_stac, m1napr_stac := 0, ;
    mm_napr_stac := arr_mm_napr_stac(), ;
    mprofil_stac, m1profil_stac := 0
  Private mnapr_reab, m1napr_reab := 0, mprofil_kojki, m1profil_kojki := 0
  
  Private mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0
  
  Private m1NAPR_MO, mNAPR_MO, mNAPR_DATE, mNAPR_V, m1NAPR_V, mMET_ISSL, m1MET_ISSL, ;
    mshifr, mshifr1, mname_u, mU_KOD, cur_napr := 0, count_napr := 0, tip_onko_napr := 0, ;
    mTab_Number := 0
  
  Private mm_napr_v := { { 'нет', 0 }, ;
    { 'к онкологу', 1 }, ;
    { 'на дообследование', 3 } }
    /*Private mm_napr_v := {{'нет', 0}, ;
                          {'к онкологу', 1}, ;
                          {'на биопсию', 2}, ;
                          {'на дообследование', 3}, ;
                          {'для опредения тактики лечения', 4}}*/
  Private mm_met_issl := { { 'нет', 0 }, ;
    { 'лабораторная диагностика', 1 }, ;
    { 'инструментальная диагностика', 2 }, ;
    { 'методы лучевой диагностики (недорогостоящие)', 3 }, ;
    { 'дорогостоящие методы лучевой диагностики', 4 } }
  //
  Private pole_diag, pole_pervich, pole_1pervich, pole_d_diag, ;
    pole_stadia, pole_dispans, pole_1dispans, pole_d_dispans, pole_dn_dispans
      
  Private mm_pervich := arr_mm_pervich()
  Private mm_dispans := arr_mm_dispans()
  Private mDS_ONK, m1DS_ONK := 0 // Признак подозрения на злокачественное новообразование
  Private mm_dopo_na := arr_mm_dopo_na()
  Private gl_arr := { ;  // для битовых полей
    { 'dopo_na', 'N', 10, 0, , , , {| x | inieditspr( A__MENUBIT, mm_dopo_na, x ) } };
  }

  Private mm_gruppaP := arr_mm_gruppap()
  Private mm_gruppaP_old := AClone( mm_gruppaP )
  ASize( mm_gruppaP_old, 3 )
  Private mm_gruppaP_new := AClone( mm_gruppaP )
  hb_ADel( mm_gruppaP_new, 3, .t. )
  Private mm_gruppaD1 := { ;
    { 'Проведена диспансеризация - присвоена I группа здоровья', 1, 317 }, ;
    { 'Проведена диспансеризация - присвоена II группа здоровья', 2, 318 }, ;
    { 'Проведена диспансеризация - присвоена IIIа группа здоровья', 3, 355 }, ;
    { 'Проведена диспансеризация - присвоена IIIб группа здоровья', 4, 356 }, ;
    { 'Направлен на 2 этап, предварительно присвоена I группа здоровья', 11, 352 }, ;
    { 'Направлен на 2 этап, предварительно присвоена II группа здоровья', 12, 353 }, ;
    { 'Направлен на 2 этап, предварительно присвоена IIIа группа здоровья', 13, 357 }, ;
    { 'Направлен на 2 этап, предварительно присвоена IIIб группа здоровья', 14, 358 }, ;
    { 'Направлен на 2 этап и ОТКАЗАЛСЯ, присвоена I группа здоровья', 21, 352 }, ;
    { 'Направлен на 2 этап и ОТКАЗАЛСЯ, присвоена II группа здоровья', 22, 353 }, ;
    { 'Направлен на 2 этап и ОТКАЗАЛСЯ, присвоена IIIа группа здоровья', 23, 357 }, ;
    { 'Направлен на 2 этап и ОТКАЗАЛСЯ, присвоена IIIб группа здоровья', 24, 358 } }
  Private mm_gruppaD2 := AClone( mm_gruppaD1 )
  ASize( mm_gruppaD2, 4 )
  Private mm_gruppaD4 := AClone( mm_gruppaD1 )
  ASize( mm_gruppaD4, 8 )
  Private mm_otkaz := arr_mm_otkaz()
  Private mm_otkaz1 := AClone( mm_otkaz )
  ASize( mm_otkaz1, 3 )
  Private mm_otkaz0 := AClone( mm_otkaz )
  ASize( mm_otkaz0, 2 )
      
//  If kod_kartotek == 0 // добавление в картотеку
  If kod_kartotek >= 0 // работаем из картотеки
    If kod_kartotek == 0 // добавление в картотеку
      If ( kod_kartotek := edit_kartotek( 0, , , .t. ) ) == 0
        Return Nil
      Endif
    endif
    mkod_k := kod_kartotek
    r_use( dir_server() + 'kartotek', , 'KART' )
    Goto ( mkod_k )
    mpol        := kart->pol
    mdate_r     := kart->date_r
    kart->( dbCloseArea() )
  Elseif Loc_kod > 0
    r_use( dir_server() + 'human', , 'HUMAN' )
    Goto ( Loc_kod )
    mpol    := human->pol
    mdate_r := human->date_r
    MN_DATA := human->N_DATA
    fl := ( Year( human->k_data ) < 2018 )
    Use
    If fl
      Return func_error( 4, 'Это случай диспансеризации ранее 2018 года' )
    Endif
  Endif

  fv_date_r( iif( Loc_kod > 0, MN_DATA, ) )

  // If ISNIL( sadiag1 )
  //   sadiag1 := load_diagnoze_disp_nabl_from_file()
  // Endif

  chm_help_code := 3002

  mm_ndisp1 := AClone( mm_ndisp )
    // оставляем 3-ий и 4-ый этапы
  ASize( mm_ndisp1, 4 )
  hb_ADel( mm_ndisp1, 1, .t. )
  hb_ADel( mm_ndisp1, 1, .t. )

  arr := {} // массив для направлений

  For i := 1 To 5
    sk := lstr( i )
    pole_diag := 'mdiag' + sk
    pole_d_diag := 'mddiag' + sk
    pole_pervich := 'mpervich' + sk
    pole_1pervich := 'm1pervich' + sk
    pole_stadia := 'm1stadia' + sk
    pole_dispans := 'mdispans' + sk
    pole_1dispans := 'm1dispans' + sk
    pole_d_dispans := 'mddispans' + sk
    pole_dn_dispans := 'mdndispans' + sk
    Private &pole_diag := Space( 6 )
    Private &pole_d_diag := CToD( '' )
    Private &pole_pervich := Space( 7 )
    Private &pole_1pervich := 0
    Private &pole_stadia := 1
    Private &pole_dispans := Space( 10 )
    Private &pole_1dispans := 0
    Private &pole_d_dispans := CToD( '' )
    Private &pole_dn_dispans := CToD( '' )
  Next
  Private mg_cit := '', m1g_cit := 0, m1lis := 0, mm_g_cit := { ;
    { 'в МО-обычное иссл-е цитологичес.материала', 1 }, ;
    { 'в ВОКОД-жидкостное иссл-ие цит.материала', 2 } }
  // for i := 1 to 33 //count_dvn_arr_usl 19.10.21
  For i := 1 To 34 // count_dvn_arr_usl 08.09.24
    mvar := 'MTAB_NOMv' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMa' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATE' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MKOD_DIAG' + lstr( i )
    Private &mvar := Space( 6 )
    mvar := 'MOTKAZ' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := 'M1OTKAZ' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
    m1var := 'M1LIS' + lstr( i )
    Private &m1var := 0
    mvar := 'MLIS' + lstr( i )
    Private &mvar := inieditspr( A__MENUVERT, mm_kdp2, &m1var )
  Next
  //
  AFill( adiag_talon, 0 )
  r_use( dir_server() + 'human_2', , 'HUMAN_2' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  If mkod_k > 0
    r_use( dir_server() + 'kartote2', , 'KART2' )
    Goto ( mkod_k )
    r_use( dir_server() + 'kartote_', , 'KART_' )
    Goto ( mkod_k )
    r_use( dir_server() + 'kartotek', , 'KART' )
    Goto ( mkod_k )
    M1FIO       := 1
    mfio        := kart->fio
    mpol        := kart->pol
    mdate_r     := kart->date_r
    M1VZROS_REB := kart->VZROS_REB
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    m1RAB_NERAB := kart->RAB_NERAB
    M1VZ        := kart->VZ
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
    msmo        := kart_->SMO
    m1MO_PR     := kart2->MO_PR
    If kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    Endif
    If eq_any( is_uchastok, 1, 3 )
      MUCH_DOC := PadR( amb_kartan(), 10 )
    Elseif mem_kodkrt == 2
      MUCH_DOC := PadR( lstr( mkod_k ), 10 )
    Endif
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 1, , .t. ) // открыть и закрыть
    Endif
    // проверка исхода = СМЕРТЬ
    ah := {}
    Select HUMAN
    Set Index to ( dir_server() + 'humankk' )
    find ( Str( mkod_k, 7 ) )
    Do While human->kod_k == mkod_k .and. !Eof()
      If human_->oplata != 9 .and. human_->NOVOR == 0 .and. RecNo() != Loc_kod
        If is_death( human_->RSLT_NEW ) .and. Empty( a_smert )
          a_smert := { 'Данный больной умер!', ;
            'Лечение с ' + full_date( human->N_DATA ) + ' по ' + full_date( human->K_DATA ) }
        Endif
        If Between( human->ishod, 201, 205 )
          AAdd( ah, { human->( RecNo() ), human->K_DATA } )
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    Set Index To
    If Len( ah ) > 0
      ASort( ah, , , {| x, y | x[ 2 ] < y[ 2 ] } )
      Select HUMAN
      Goto ( ATail( ah )[ 1 ] )
      M1RAB_NERAB := human->RAB_NERAB // 0-работающий, 1-неработающий, 2-обучающ.ОЧНО
      M1VZ        := human->VZ
      letap := human->ishod -200
      If eq_any( letap, 1, 4 )
        lrslt_1_etap := human_->RSLT_NEW
      Endif
      read_arr_dvn( human->kod, .f. )
    Endif
  Endif
  If Empty( mWEIGHT )
    mWEIGHT := iif( mpol == 'М', 70, 55 )   // вес в кг
  Endif
  If Empty( mHEIGHT )
    mHEIGHT := iif( mpol == 'М', 170, 160 )  // рост в см
  Endif
  If Empty( mOKR_TALII )
    mOKR_TALII := iif( mpol == 'М', 94, 80 ) // окружность талии в см
  Endif
  If Loc_kod > 0
    Select HUMAN
    Goto ( Loc_kod )
    M1LPU       := human->LPU
    M1OTD       := human->OTD
    M1FIO       := 1
    mfio        := human->fio
    mpol        := human->pol
    mdate_r     := human->date_r
    MTIP_H      := human->tip_h
    M1VZROS_REB := human->VZROS_REB
    MADRES      := human->ADRES         // адрес больного
    MMR_DOL     := human->MR_DOL        // место работы или причина безработности
    M1RAB_NERAB := human->RAB_NERAB     // 0-работающий, 1-неработающий, 2-обучающ.ОЧНО
    M1VZ        := human->VZ
    mUCH_DOC    := human->uch_doc
    m1MOP       := human->MOP           // место обращения
    m1VRACH     := human_->vrach
    /*MKOD_DIAG0  := human_->KOD_DIAG0
    MKOD_DIAG   := human->KOD_DIAG
    MKOD_DIAG2  := human->KOD_DIAG2
    MKOD_DIAG3  := human->KOD_DIAG3
    MKOD_DIAG4  := human->KOD_DIAG4
    MSOPUT_B1   := human->SOPUT_B1
    MSOPUT_B2   := human->SOPUT_B2
    MSOPUT_B3   := human->SOPUT_B3
    MSOPUT_B4   := human->SOPUT_B4
    MDIAG_PLUS  := human->DIAG_PLUS
    for i := 1 to 16
      adiag_talon[i] := int(val(substr(human_->DISPANS,i, 1)))
    next*/
    MPOLIS      := human->POLIS         // серия и номер страхового полиса
    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    If human->OBRASHEN == '1'
      m1DS_ONK := 1
    Endif
    If Empty( Val( msmo := human_->SMO ) )
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    Else
      m1komu := m1str_crb := 0
    Endif
    m1okato    := human_->OKATO  // ОКАТО субъекта РФ территории страхования
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    mcena_1    := human->CENA_1
    m1rslt     := human_->RSLT_NEW
    //
    is_prazdnik := f_is_prazdnik_dvn( mn_data )
    is_disp_19 := !( mk_data < 0d20190501 )
    //
    is_disp_21 := !( mk_data < 0d20210101 )
    //
//    is_disp_24 := !( mk_data < 0d20240901 )
    //
    ret_arr_vozrast_dvn( mk_data )
    // / !!!!
    ret_arrays_disp( mk_data )
    metap := human->ishod - 200
    If is_disp_19
      mdvozrast := Year( mn_data ) - Year( mdate_r )
      // если это профосмотр
      If metap == 3 .and. AScan( ret_arr_vozrast_dvn( mk_data ), mdvozrast ) > 0 // а возраст диспансеризации
        metap := 1 // превращаем в диспансеризацию
        If mk_data < 0d20191101 .and. m1rslt == 345
          m1rslt := 355
        Elseif mk_data >= 0d20191101 .and. m1rslt == 373
          m1rslt := 355
        Elseif mk_data >= 0d20191101 .and. m1rslt == 374
          m1rslt := 356
        Elseif m1rslt == 344
          m1rslt := 318
        Else
          m1rslt := 317
        Endif
      Endif
      If metap == 4
        func_error( 4, 'Это диспансеризация раз в 2 года - преобразуем в обычную диспансеризацию' )
        metap := 1
      Elseif metap == 5
        func_error( 4, 'Это второй этап диспансеризации раз в 2 года - удалите этот случай!' )
        Close databases
        Return Nil
      Endif
    Endif
    If Between( metap, 1, 5 )
      mm_gruppa := { mm_gruppaD1, mm_gruppaD2, mm_gruppaP, mm_gruppaD4, mm_gruppaD2 }[ metap ]
      If ( i := AScan( mm_gruppa, {| x | x[ 3 ] == m1rslt } ) ) > 0
        m1GRUPPA := mm_gruppa[ i, 2 ]
      Endif
    Endif
    //
    fl_4_1_12 := .f.
    larr := Array( 2, count_dvn_arr_usl )
    afillall( larr, 0 )
    r_use( dir_server() + 'uslugi', , 'USL' )
    use_base( 'human_u' )
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
        lshifr := usl->shifr
      Endif
      lshifr := AllTrim( lshifr )
      If eq_any( Left( lshifr, 5 ), '70.3.', '70.7.', '72.1.', '72.5.', '72.6.', '72.7.' )
        mshifr_zs := lshifr
      Else
        fl := .t.
        If is_disp_19
          //
        Else
          If lshifr == '2.3.3' .and. hu_->PROFIL == 3  ; // акушерскому делу
            .and. ( i := AScan( dvn_arr_usl, {| x | ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == '4.1.12' } ) ) > 0
            fl_4_1_12 := .t.
            fl := .f.
            larr[ 1, i ] := hu->( RecNo() )
          Endif
        Endif
        If fl
          For i := 1 To count_dvn_arr_umolch
            If Empty( larr[ 2, i ] ) .and. dvn_arr_umolch[ i, 2 ] == lshifr
              fl := .f.
              larr[ 2, i ] := hu->( RecNo() )
              Exit
            Endif
          Next
        Endif
        If fl
          For i := 1 To count_dvn_arr_usl
            If Empty( larr[ 1, i ] )
              If ValType( dvn_arr_usl[ i, 2 ] ) == 'C'
                If dvn_arr_usl[ i, 2 ] == '4.20.1'
                  If lshifr == '4.20.1'
                    m1g_cit := 1
                  Elseif lshifr == '4.20.2'
                    m1g_cit := 2
                    fl := .f.
                  Endif
                Endif
                If dvn_arr_usl[ i, 2 ] == lshifr
                  fl := .f.
                  m1var := 'm1lis' + lstr( i )
                  If is_disp_19
                    &m1var := 0
                  Elseif glob_yes_kdp2()[ TIP_LU_DVN ] .and. AScan( glob_arr_usl_LIS(), dvn_arr_usl[ i, 2 ] ) > 0 .and. hu->is_edit > 0
                    &m1var := hu->is_edit
                  Endif
                  mvar := 'mlis' + lstr( i )
                  &mvar := inieditspr( A__MENUVERT, mm_kdp2, &m1var )
                Endif
              Endif
              If fl .and. Len( dvn_arr_usl[ i ] ) > 11 .and. ValType( dvn_arr_usl[ i, 12 ] ) == 'A'
                If AScan( dvn_arr_usl[ i, 12 ], {| x | x[ 1 ] == lshifr .and. x[ 2 ] == hu_->PROFIL } ) > 0
                  fl := .f.
                Endif
              Endif
              If !fl
                larr[ 1, i ] := hu->( RecNo() )
                Exit
              Endif
            Endif
          Next
        Endif
        If fl .and. AScan( dvn_700(), {| x | x[ 2 ] == lshifr } ) > 0
          fl := .f. // к нулевой услуге добавлена услуга с ценой на '700'
        Endif
        If fl
          n_message( { 'Некорректная настройка в справочнике услуг:', ;
            AllTrim( usl->name ), ;
            'шифр услуги в справочнике ' + usl->shifr, ;
            'шифр ТФОМС - ' + opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) }, , ;
            'GR+/R', 'W+/R', , , 'G+/R' )
        Endif
      Endif
      AAdd( arr_usl, hu->( RecNo() ) )
      Select HU
      Skip
    Enddo
    r_use( dir_server() + 'mo_pers', , 'P2' )
    read_arr_dvn( Loc_kod )
    If metap == 1 .and. Between( m1GRUPPA, 11, 14 ) .and. m1p_otk == 1
      m1GRUPPA += 10
    Endif
    // R_Use(dir_server() + 'mo_pers',,'P2')
    For i := 1 To count_dvn_arr_usl
      If !Empty( larr[ 1, i ] )
        hu->( dbGoto( larr[ 1, i ] ) )
        If hu->kod_vr > 0
          p2->( dbGoto( hu->kod_vr ) )
          mvar := 'MTAB_NOMv' + lstr( i )
          &mvar := p2->tab_nom
        Endif
        If hu->kod_as > 0
          p2->( dbGoto( hu->kod_as ) )
          mvar := 'MTAB_NOMa' + lstr( i )
          &mvar := p2->tab_nom
        Endif
        mvar := 'MDATE' + lstr( i )
        &mvar := c4tod( hu->date_u )
        If !Empty( hu_->kod_diag ) .and. !( Left( hu_->kod_diag, 1 ) == 'Z' )
          mvar := 'MKOD_DIAG' + lstr( i )
          &mvar := hu_->kod_diag
        Endif
        m1var := 'M1OTKAZ' + lstr( i )
        &m1var := 0 // выполнено
        If ValType( dvn_arr_usl[ i, 2 ] ) == 'C'
          If AScan( arr_otklon, dvn_arr_usl[ i, 2 ] ) > 0
            &m1var := 3 // выполнено, обнаружены отклонения
          Elseif dvn_arr_usl[ i, 2 ] == '2.3.1' .and. AScan( arr_otklon, '2.3.3' ) > 0
            &m1var := 3 // выполнено, обнаружены отклонения
          Elseif dvn_arr_usl[ i, 2 ] == '4.20.1' .and. m1g_cit == 2 .and. AScan( arr_otklon, '4.20.2' ) > 0
            &m1var := 3 // выполнено, обнаружены отклонения
          Elseif fl_4_1_12 .and. dvn_arr_usl[ i, 2 ] == '4.1.12'
            &m1var := 2 // НЕВОЗМОЖНОсть
          Endif
        Endif
        mvar := 'MOTKAZ' + lstr( i )
        &mvar := inieditspr( A__MENUVERT, mm_otkaz, &m1var )
      Endif
    Next
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 2, @rec_inogSMO, .t. ) // открыть и закрыть
    Endif
    If ValType( arr_usl_otkaz ) == 'A'
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) >= 5 .and. ValType( ar[ 5 ] ) == 'C'
          lshifr := AllTrim( ar[ 5 ] )
          For i := 1 To count_dvn_arr_usl
            If ValType( dvn_arr_usl[ i, 2 ] ) == 'C' .and. ;
                ( dvn_arr_usl[ i, 2 ] == lshifr .or. ( Len( dvn_arr_usl[ i ] ) > 11 .and. ValType( dvn_arr_usl[ i, 12 ] ) == 'A' ;
                .and. AScan( dvn_arr_usl[ i, 12 ], {| x | x[ 1 ] == lshifr } ) > 0 ) )
              If ValType( ar[ 1 ] ) == 'N' .and. ar[ 1 ] > 0
                p2->( dbGoto( ar[ 1 ] ) )
                mvar := 'MTAB_NOMv' + lstr( i )
                &mvar := p2->tab_nom
              Endif
              If ValType( ar[ 3 ] ) == 'N' .and. ar[ 3 ] > 0
                p2->( dbGoto( ar[ 3 ] ) )
                mvar := 'MTAB_NOMa' + lstr( i )
                &mvar := p2->tab_nom
              Endif
              mvar := 'MDATE' + lstr( i )
              &mvar := mn_data
              If Len( ar ) >= 9 .and. ValType( ar[ 9 ] ) == 'D'
                &mvar := ar[ 9 ]
              Endif
              m1var := 'M1OTKAZ' + lstr( i )
              &m1var := 1
              If Len( ar ) >= 10 .and. ValType( ar[ 10 ] ) == 'N' .and. Between( ar[ 10 ], 1, 2 )
                &m1var := ar[ 10 ]
              Endif
              mvar := 'MOTKAZ' + lstr( i )
              &mvar := inieditspr( A__MENUVERT, mm_otkaz, &m1var )
            Endif
          Next i
        Endif
      Next j
    Endif
    // собираем онкологические направления
    dbCreate( cur_dir() + 'tmp_onkna', create_struct_temporary_onkna() )
    cur_napr := 1 // при ред-ии - сначала первое направление текущее
    count_napr := collect_napr_zno( Loc_kod, _NPR_DISP_ZNO )
    If count_napr > 0
      mnapr_onk := 'Количество направлений - ' + lstr( count_napr )
    Endif
    For i := 1 To 5
      f_valid_diag_oms_sluch_dvn( , i )
    Next i
  Endif
  If !( Left( msmo, 2 ) == '34' ) // не Волгоградская область
    m1ismo := msmo
    msmo := '34'
  Endif
  is_talon := .t.
  Close databases
  fv_date_r( iif( Loc_kod > 0, mn_data, ) )
  MFIO_KART := _f_fio_kart()
  mndisp    := inieditspr( A__MENUVERT, mm_ndisp, metap )
  mrab_nerab := inieditspr( A__MENUVERT, menu_rab, m1rab_nerab )
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  mlpu      := inieditspr( A__POPUPMENU, dir_server() + 'mo_uch', m1lpu )
  motd      := inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', m1otd )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf(), m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu(), m1komu )
  mMOP      := inieditspr( A__MENUVERT, getv040(), m1MOP )
  mismo     := init_ismo( m1ismo )
  f_valid_komu(, -1 )
  If m1komu == 0
    m1company := Int( Val( msmo ) )
  Elseif eq_any( m1komu, 1, 3 )
    m1company := m1str_crb
  Endif
  mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
  If m1company == 34
    If !Empty( mismo )
      mcompany := PadR( mismo, 38 )
    Elseif !Empty( mnameismo )
      mcompany := PadR( mnameismo, 38 )
    Endif
  Endif
  mveteran := inieditspr( A__MENUVERT, mm_danet, m1veteran )
  mmobilbr := inieditspr( A__MENUVERT, mm_danet, m1mobilbr )
  mkurenie := inieditspr( A__MENUVERT, mm_danet, m1kurenie )
  mriskalk := inieditspr( A__MENUVERT, mm_danet, m1riskalk )
  mpod_alk := inieditspr( A__MENUVERT, mm_danet, m1pod_alk )
  If emptyall( m1riskalk, m1pod_alk )
    m1psih_na := 0
  Endif
  mpsih_na := inieditspr( A__MENUVERT, mm_danet, m1psih_na )
  mfiz_akt := inieditspr( A__MENUVERT, mm_danet, m1fiz_akt )
  mner_pit := inieditspr( A__MENUVERT, mm_danet, m1ner_pit )
  maddn    := inieditspr( A__MENUVERT, mm_danet, m1addn )
  mholestdn := inieditspr( A__MENUVERT, mm_danet, m1holestdn )
  mglukozadn := inieditspr( A__MENUVERT, mm_danet, m1glukozadn )
  mot_nasl1 := inieditspr( A__MENUVERT, mm_danet, m1ot_nasl1 )
  mot_nasl2 := inieditspr( A__MENUVERT, mm_danet, m1ot_nasl2 )
  mot_nasl3 := inieditspr( A__MENUVERT, mm_danet, m1ot_nasl3 )
  mot_nasl4 := inieditspr( A__MENUVERT, mm_danet, m1ot_nasl4 )
  mdispans  := inieditspr( A__MENUVERT, mm_dispans, m1dispans )
  mDS_ONK   := inieditspr( A__MENUVERT, mm_danet, M1DS_ONK )
  mnazn_l   := inieditspr( A__MENUVERT, mm_danet, m1nazn_l )
  mdopo_na  := inieditspr( A__MENUBIT, mm_dopo_na, m1dopo_na )
  mnapr_v_mo := inieditspr( A__MENUVERT, mm_napr_v_mo, m1napr_v_mo )
  If Empty( arr_mo_spec )
    ma_mo_spec := '---'
  Else
    ma_mo_spec := ''
    For i := 1 To Len( arr_mo_spec )
      ma_mo_spec += lstr( arr_mo_spec[ i ] ) + ','
    Next
    ma_mo_spec := Left( ma_mo_spec, Len( ma_mo_spec ) -1 )
  Endif
  mnapr_stac := inieditspr( A__MENUVERT, mm_napr_stac, m1napr_stac )
  mprofil_stac := inieditspr( A__MENUVERT, getv002(), m1profil_stac )
  mnapr_reab := inieditspr( A__MENUVERT, mm_danet, m1napr_reab )
  mprofil_kojki := inieditspr( A__MENUVERT, getv020(), m1profil_kojki )
  mssh_na   := inieditspr( A__MENUVERT, mm_danet, m1ssh_na )
  mspec_na  := inieditspr( A__MENUVERT, mm_danet, m1spec_na )
  msank_na  := inieditspr( A__MENUVERT, mm_danet, m1sank_na )
  mtip_mas := ret_tip_mas( mWEIGHT, mHEIGHT, @m1tip_mas )
  ret_ndisp( Loc_kod, kod_kartotek )
  //
  If !Empty( f_print )
    return &( f_print + '(' + lstr( Loc_kod ) + ',' + lstr( kod_kartotek ) + ')' )
  Endif
  //
  str_1 := ' случая диспансеризации/профосмотра взрослого населения'
  If Loc_kod == 0
    str_1 := 'Добавление' + str_1
    mtip_h := yes_vypisan
  Else
    str_1 := 'Редактирование' + str_1
  Endif
  SetColor( color8 )
  Private gl_area
  SetColor( cDataCGet )
  make_diagp( 1 )  // сделать 'шестизначные' диагнозы
  Private num_screen := 1
  Do While .t.
    Close databases
    DispBegin()
    If metap == 2 .and. num_screen == 2
      hS := 30
      wS := 80
    Elseif num_screen == 3
      hS := 26
      wS := 85
    Else
      hS := 25
      wS := 80
    Endif
    SetMode( hS, wS )
    @ 0, 0 Say PadC( str_1, wS ) Color 'B/BG*'
    gl_area := { 1, 0, MaxRow() -1, MaxCol(), 0 }
    j := 1
    myclear( j )
    If yes_num_lu == 1 .and. Loc_kod > 0
      @ j, ( wS -30 ) Say PadL( 'Лист учета № ' + lstr( Loc_kod ), 29 ) Color color14
    Endif
    @ j, 0 Say 'Экран ' + lstr( num_screen ) Color color8
    If num_screen > 1
      s := AllTrim( mfio ) + ' (' + lstr( mvozrast ) + ' ' + s_let( mvozrast ) + ')'
      @ j, wS - Len( s ) Say s Color color14
    Endif
    If num_screen == 1 // 
      @ ++j, 1 Say 'ФИО' Get mfio_kart ;
        reader {| x | menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
        valid {| g, o | update_get( 'mdate_r' ), ;
        update_get( 'mkomu' ), update_get( 'mcompany' ) }
      @ Row(), Col() + 5 Say 'Д.р.' Get mdate_r When .f. Color color14
      @ ++j, 1 Say ' Работающий?' Get mrab_nerab ;
        reader {| x | menu_reader( x, menu_rab, A__MENUVERT, , , .f. ) }
      @ j, 40 Say 'Ветеран ВОВ (блокадник)?' Get mveteran ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say ' Принадлежность счёта' Get mkomu ;
        reader {| x | menu_reader( x, mm_komu(), A__MENUVERT, , , .f. ) } ;
        valid {| g, o | f_valid_komu( g, o ) } ;
        Color colget_menu
      @ Row(), Col() + 1 Say '==>' Get mcompany ;
        reader {| x | menu_reader( x, mm_company, A__MENUVERT, , , .f. ) } ;
        When m1komu < 5 ;
        valid {| g | func_valid_ismo( g, m1komu, 38 ) }
      @ ++j, 1 Say ' Полис ОМС: серия' Get mspolis When m1komu == 0
      @ Row(), Col() + 3 Say 'номер'  Get mnpolis When m1komu == 0
      @ Row(), Col() + 3 Say 'вид'    Get mvidpolis ;
        reader {| x | menu_reader( x, mm_vid_polis, A__MENUVERT, , , .f. ) } ;
        When m1komu == 0 ;
        Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
      //
      @ ++j, 1 Say 'Сроки' Get mn_data ;
        valid {| g | f_k_data( g, 1 ), ;
        iif( mvozrast < 18, func_error( 4, 'Это не взрослый пациент!' ), nil ), ;
        ret_ndisp( Loc_kod, kod_kartotek ) ;
        }
      @ Row(), Col() + 1 Say '-' Get mk_data ;
        valid {| g | f_k_data( g, 2 ), ;
        ret_ndisp( Loc_kod, kod_kartotek ) ;
        }
      If eq_any( metap, 3, 4 ) .and. is_dostup_2_year
        @ Row(), Col() + 7 Get mndisp /*color color14*/ reader { | x | menu_reader(x, mm_ndisp1, A__MENUVERT, , , .f. ) } ;
        valid {|| metap := m1ndisp, .t. }
      Else
        @ Row(), Col() + 7 Get mndisp When .f. Color color14
      Endif
      @ ++j, 1 Say '№ амбулаторной карты' Get much_doc Picture '@!' ;
        When !( is_uchastok == 1 .and. is_task( X_REGIST ) ) .or. mem_edit_ist == 2
      @ j,Col() + 5 Say 'Мобильная бригада?' Get mmobilbr ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say 'Место обращения' Get mMOP ;
        reader {| x| menu_reader( x, tmp_V040, A__MENUVERT, , , .f. ) }

      ++j
      @ ++j, 1 Say 'Курение/употребление табака' Get mkurenie ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say 'Риск пагубного потребления алкоголя (употребление алкоголя)' Get mriskalk ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say 'Риск потребления наркотических/психотропных веществ без назначения врача' Get mpod_alk ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say 'Низкая физическая активность (недостаток физической активности)' Get mfiz_akt ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say 'Нерациональное питание (неприемлемая диета/вредные привычки питания)' Get mner_pit ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say 'Отягощённая наследственность: по злокачественным новообразованиям' Get mot_nasl1 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '                            - по сердечно-сосудистым заболеваниям' Get mot_nasl2 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '               - по хроническим болезням нижних дыхательных путей' Get mot_nasl3 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '                                           - по сахарному диабету' Get mot_nasl4 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      ++j
      @ ++j, 1 Say 'Вес' Get mWEIGHT Pict '999' ;
        valid {|| iif( Between( mWEIGHT, 30, 200 ), , func_error( 4, 'Неразумный вес' ) ), ;
        mtip_mas := ret_tip_mas( mWEIGHT, mHEIGHT ), ;
        update_get( 'mtip_mas' ) }
      @ Row(), Col() + 1 Say 'кг, рост' Get mHEIGHT Pict '999' ;
        valid {|| iif( Between( mHEIGHT, 40, 250 ), , func_error( 4, 'Неразумный рост' ) ), ;
        mtip_mas := ret_tip_mas( mWEIGHT, mHEIGHT ), ;
        update_get( 'mtip_mas' ) }
      @ Row(), Col() + 1 Say 'см, окружность талии' Get mOKR_TALII  Pict '999' ;
        valid {|| iif( Between( mOKR_TALII, 40, 200 ), , func_error( 4, 'Неразумное значение окружности талии' ) ), .t. }
      @ Row(), Col() + 1 Say 'см'
      @ Row(), Col() + 5 Get mtip_mas Color color14 When .f.
      @ ++j, 1 Say ' Артериальное давление' Get mad1 Pict '999' ;
        valid {|| iif( Between( mad1, 60, 220 ), , func_error( 4, 'Неразумное давление' ) ), .t. }
      @ Row(), Col() Say '/' Get mad2 Pict '999';
        valid {|| iif( Between( mad1, 40, 180 ), , func_error( 4, 'Неразумное давление' ) ), ;
        iif( mad1 > mad2, , func_error( 4, 'Неразумное давление' ) ), ;
        .t. }
      @ Row(), Col() + 1 Say 'мм рт.ст.    Гипотензивная терапия' Get maddn ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say ' Общий холестерин' Get mholest Pict '99.99' ;
        valid {|| iif( Empty( mholest ) .or. Between( mholest, 3, 8 ), , func_error( 4, 'Неразумное значение холестерина' ) ), .t. }
      @ Row(), Col() + 1 Say 'ммоль/л     Гиполипидемическая терапия' Get mholestdn ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say ' Глюкоза' Get mglukoza Pict '99.99' ;
        valid {|| iif( Empty( mglukoza ) .or. Between( mglukoza, 2.2, 25 ), , func_error( 4, 'Критическое значение глюкозы' ) ), .t. }
      @ Row(), Col() + 1 Say 'ммоль/л     Гипогликемическая терапия' Get mglukozadn ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      status_key( '^<Esc>^ выход без записи ^<PgDn>^ на 2-ю страницу' )
      If !Empty( a_smert )
        n_message( a_smert, , 'GR+/R', 'W+/R', , , 'G+/R' )
      Endif
    Elseif num_screen == 2 // 
      ret_ndisp( Loc_kod, kod_kartotek )
      @ ++j, 8 Get mndisp When .f. Color color14
      If mvozrast != mdvozrast
        If m1veteran == 1
          s := '(для ветерана проводится по возрасту ' + lstr( mdvozrast ) + ' ' + s_let( mdvozrast ) + ')'
        Else
          s := '(в ' + lstr( Year( mn_data ) ) + ' году исполняется ' + lstr( mdvozrast ) + ' ' + s_let( mdvozrast ) + ')'
        Endif
        @ j, 80 - Len( s ) Say s Color color14
      Endif
      @ ++j, 1 Say '────────────────────────────────────────────┬─────┬─────┬──────────┬──────────' Color color8
      @ ++j, 1 Say 'Наименования исследований                   │врач │ассис│дата услуг│выполнение' Color color8
      @ ++j, 1 Say '────────────────────────────────────────────┴─────┴─────┴──────────┴──────────' Color color8
      // ++j; @ j, 0 say replicate('─', 80) color color8
      // ++j; @ j, 0 say '_Наименования исследований____________________врач__ассис_дата услуг_выполнение_' color color8
      If mem_por_ass == 0
        @ j -1, 52 Say Space( 5 )
      Endif
      fl_vrach := .t.
      For i := 1 To count_dvn_arr_usl
        fl_diag := .f.
        i_otkaz := 0
        If f_is_usl_oms_sluch_dvn( i, metap, iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast ), mpol, @fl_diag, @i_otkaz )
          If fl_diag .and. fl_vrach
            @ ++j, 1 Say '────────────────────────────────────────────┬─────┬─────┬───────────' Color color8
            @ ++j, 1 Say 'Наименования осмотров                       │врач │ассис│дата услуги' Color color8
            @ ++j, 1 Say '────────────────────────────────────────────┴─────┴─────┴───────────' Color color8
            // ++j; @ j, 0 say replicate('─', 80) color color8
            // ++j; @ j, 0 say '_Наименования осмотров________________________врач__ассис_дата услуг_диагноз____' color color8
            If mem_por_ass == 0
              @ j -1, 52 Say Space( 5 )
            Endif
            fl_vrach := .f.
          Endif
          fl_g_cit := fl_kdp2 := .f.
          If ValType( dvn_arr_usl[ i, 2 ] ) == 'C'
            If ( fl_g_cit := ( dvn_arr_usl[ i, 2 ] == '4.20.1' ) )
              If m1g_cit == 0
                m1g_cit := 1 // начальное присвоение
              Endif
              mg_cit := inieditspr( A__MENUVERT, mm_g_cit, m1g_cit )
              If mk_data > 0d20190831
                fl_g_cit := .f.
                m1g_cit := 1 // в МО
              Endif
            Elseif !is_disp_19 .and. glob_yes_kdp2()[ TIP_LU_DVN ] .and. AScan( glob_arr_usl_LIS(), dvn_arr_usl[ i, 2 ] ) > 0
              fl_kdp2 := .t.
            Endif
          Endif
          mvarv := 'MTAB_NOMv' + lstr( i )
          mvara := 'MTAB_NOMa' + lstr( i )
          mvard := 'MDATE' + lstr( i )
          If Empty( &mvard )
            &mvard := mn_data
          Endif
          mvarz := 'MKOD_DIAG' + lstr( i )
          mvaro := 'MOTKAZ' + lstr( i )
          mvarlis := 'MLIS' + lstr( i )
          ++j
          If fl_g_cit
            @ j, 1 Get mg_cit reader {| x | menu_reader( x, mm_g_cit, A__MENUVERT, , , .f. ) }
          Else
            @ j, 1 Say dvn_arr_usl[ i, 1 ]
          Endif
          If fl_kdp2
            @ j, 41 get &mvarlis reader {| x | menu_reader( x, mm_kdp2, A__MENUVERT, , , .f. ) }
          Endif
          @ j, 46 get &mvarv Pict '99999' valid {| g | v_kart_vrach( g ) }
          If mem_por_ass > 0
            @ j, 52 get &mvara Pict '99999' valid {| g | v_kart_vrach( g ) }
          Endif
          @ j, 58 get &mvard
          If fl_diag
            // @ j, 69 get &mvarz picture pic_diag ;
            // reader {| o |MyGetReader( o, bg ) } valid val1_10diag(.t., .f., .f., mn_data, mpol)
          Elseif i_otkaz == 0
            @ j, 69 get &mvaro ;
              reader {| x | menu_reader( x, mm_otkaz0, A__MENUVERT, , , .f. ) }
          Elseif i_otkaz == 1
            @ j, 69 get &mvaro ;
              reader {| x | menu_reader( x, mm_otkaz1, A__MENUVERT, , , .f. ) }
          Elseif eq_any( i_otkaz, 2, 3 )
            @ j, 69 get &mvaro ;
              reader {| x | menu_reader( x, mm_otkaz, A__MENUVERT, , , .f. ) }
          Endif
        Endif
      Next
      @ ++j, 1 Say Replicate( '─', 68 ) Color color8
      status_key( '^<Esc>^ выход без записи ^<PgUp>^ на 1-ю страницу ^<PgDn>^ на 3-ю страницу' )
    Elseif num_screen == 3 // 
      mm_gruppa := { mm_gruppaD1, mm_gruppaD2, mm_gruppaP, mm_gruppaD4, mm_gruppaD2 }[ metap ]
      If metap == 3
        If mk_data < 0d20191101
          mm_gruppa := mm_gruppaP_old
        Else
          mm_gruppa := mm_gruppaP_new
        Endif
      Endif
      mgruppa := inieditspr( A__MENUVERT, mm_gruppa, m1gruppa )
      ret_ndisp( Loc_kod, kod_kartotek )
      @ ++j, 8 Get mndisp When .f. Color color14
      If mvozrast != mdvozrast
        If m1veteran == 1
          s := '(для ветерана проводится по возрасту ' + lstr( mdvozrast ) + ' ' + s_let( mdvozrast ) + ')'
        Else
          s := '(в ' + lstr( Year( mn_data ) ) + ' году исполняется ' + lstr( mdvozrast ) + ' ' + s_let( mdvozrast ) + ')'
        Endif
        @ j, 80 - Len( s ) Say s Color color14
      Endif
      @ ++j, 1  Say '───────┬────────────┬──────────┬──────┬───────────────────────────────────────'
      @ ++j, 1  Say '       │  выявлено  │   дата   │стадия│установлено диспансерное Дата следующего'
      @ ++j, 1  Say 'диагноз│заболевание │выявления │забол.│наблюдение     (когда)     визита'
      @ ++j, 1  Say '───────┴────────────┴──────────┴──────┴───────────────────────────────────────'
      //             2      9            22         35     44        54
      @ ++j, 2  Get mdiag1 Picture pic_diag ;
        reader {| o | mygetreader( o, bg ) } ;
        valid  {| g | iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn( g, 1 ), ;
        .f. ) }
      @ j, 9  Get mpervich1 ;
        reader {| x | menu_reader( x, mm_pervich, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag1 )
      @ j, 22 Get mddiag1 When !Empty( mdiag1 )
      @ j, 35 Get m1stadia1 Pict '9' Range 1, 4 ;
        When !Empty( mdiag1 )
      @ j, 44 Get mdispans1 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag1 )
      @ j, 54 Get mddispans1 When m1dispans1 == 1
      @ j, 67 Get mdndispans1 When m1dispans1 == 1
      //
      @ ++j, 2  Get mdiag2 Picture pic_diag ;
        reader {| o | mygetreader( o, bg ) } ;
        valid  {| g | iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn( g, 2 ), ;
        .f. ) }
      @ j, 9  Get mpervich2 ;
        reader {| x | menu_reader( x, mm_pervich, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag2 )
      @ j, 22 Get mddiag2 When !Empty( mdiag2 )
      @ j, 35 Get m1stadia2 Pict '9' Range 1, 4 ;
        When !Empty( mdiag2 )
      @ j, 44 Get mdispans2 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag2 )
      @ j, 54 Get mddispans2 When m1dispans2 == 1
      @ j, 67 Get mdndispans2 When m1dispans2 == 1
      //
      @ ++j, 2  Get mdiag3 Picture pic_diag ;
        reader {| o | mygetreader( o, bg ) } ;
        valid  {| g | iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn( g, 3 ), ;
        .f. ) }
      @ j, 9  Get mpervich3 ;
        reader {| x | menu_reader( x, mm_pervich, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag3 )
      @ j, 22 Get mddiag3 When !Empty( mdiag3 )
      @ j, 35 Get m1stadia3 Pict '9' Range 1, 4 ;
        When !Empty( mdiag3 )
      @ j, 44 Get mdispans3 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag3 )
      @ j, 54 Get mddispans3 When m1dispans3 == 1
      @ j, 67 Get mdndispans3 When m1dispans3 == 1
      //
      @ ++j, 2  Get mdiag4 Picture pic_diag ;
        reader {| o | mygetreader( o, bg ) } ;
        valid  {| g | iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn( g, 4 ), ;
        .f. ) }
      @ j, 9  Get mpervich4 ;
        reader {| x | menu_reader( x, mm_pervich, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag4 )
      @ j, 22 Get mddiag4 When !Empty( mdiag4 )
      @ j, 35 Get m1stadia4 Pict '9' Range 1, 4 ;
        When !Empty( mdiag4 )
      @ j, 44 Get mdispans4 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag4 )
      @ j, 54 Get mddispans4 When m1dispans4 == 1
      @ j, 67 Get mdndispans4 When m1dispans4 == 1
      //
      @ ++j, 2  Get mdiag5 Picture pic_diag ;
        reader {| o | mygetreader( o, bg ) } ;
        valid  {| g | iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn( g, 5 ), ;
        .f. ) }
      @ j, 9  Get mpervich5 ;
        reader {| x | menu_reader( x, mm_pervich, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag5 )
      @ j, 22 Get mddiag5 When !Empty( mdiag5 )
      @ j, 35 Get m1stadia5 Pict '9' Range 1, 4 ;
        When !Empty( mdiag5 )
      @ j, 44 Get mdispans5 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag5 )
      @ j, 54 Get mddispans5 When m1dispans5 == 1
      @ j, 67 Get mdndispans5 When m1dispans5 == 1
      //
      @ ++j, 1 Say Replicate( '─', 78 ) Color color1
      @ ++j, 1 Say 'Диспансерное наблюдение установлено' Get mdispans ;
        reader {| x | menu_reader( x, mm_dispans, A__MENUVERT, , , .f. ) } ;
        When !emptyall( mdispans1, mdispans2, mdispans3, mdispans4, mdispans5 )
      If is_disp_19
        If eq_any( metap, 1, 3 ) .and. mdvozrast < 65
          @ ++j, 1 Say iif( mdvozrast < 40, 'Относительный', 'Абсолютный' ) + ' суммарный сердечно-сосудистый риск' Get mssr Pict '99' ;
            valid {|| iif( Between( mssr, 0, 47 ), , func_error( 4, 'Неразумное значение суммарного сердечно-сосудистого риска' ) ), .t. }
          @ Row(), Col() Say '%'
        Else
          // ++j
        Endif
      Else
        If metap == 1 .and. mdvozrast < 66
          @ ++j, 1 Say iif( mdvozrast < 40, 'Относительный', 'Абсолютный' ) + ' суммарный сердечно-сосудистый риск' Get mssr Pict '99' ;
            valid {|| iif( Between( mssr, 0, 47 ), , func_error( 4, 'Неразумное значение суммарного сердечно-сосудистого риска' ) ), .t. }
          @ Row(), Col() Say '%'
        Elseif metap == 3 .and. mvozrast < 66
          @ ++j, 1 Say 'Суммарный сердечно-сосудистый риск' Get mssr Pict '99' ;
            valid {|| iif( Between( mssr, 0, 47 ), , func_error( 4, 'Неразумное значение суммарного сердечно-сосудистого риска' ) ), .t. }
          @ Row(), Col() Say '%'
        Else
          // ++j
        Endif
      Endif
      @ ++j, 1 Say 'Признак подозрения на злокачественное новообразование' Get mDS_ONK ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say 'Направления при подозрении на ЗНО' Get mnapr_onk ;
        reader {| x | menu_reader( x, { {| k, r, c| fget_napr_zno( k, r, c ) } }, A__FUNCTION, , , .f. ) }  //  When m1ds_onk == 0
      @ ++j, 1 Say 'Назначено лечение (для ф.131)' Get mnazn_l ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }  // When m1ds_onk == 0

      dispans_napr( mk_data, @j, .t. )  // вызов заполнения блока направлений

      @ ++j, 1 Say 'ГРУППА состояния ЗДОРОВЬЯ'
      @ j, Col() + 1 Get mGRUPPA ;
        reader {| x | menu_reader( x, mm_gruppa, A__MENUVERT, , , .f. ) }
//        reader {| x | menu_reader( x, iif( m1DS_ONK == 1, mm_gruppaD2, mm_gruppa ), A__MENUVERT, , , .f. ) }
      status_key( '^<Esc>^ выход без записи ^<PgUp>^ на 2-ю страницу ^<PgDn>^ ЗАПИСЬ' )
    Endif
    DispEnd()
    count_edit += myread()
    If num_screen == 3
      If LastKey() == K_PGUP
        k := 3
        --num_screen
      Else
        k := f_alert( { PadC( 'Выберите действие', 60, '.' ) }, ;
          { ' Выход без записи ', ' Запись ', ' Возврат в редактирование ' }, ;
          iif( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N, N/BG' )
      Endif
    Else
      If LastKey() == K_PGUP
        k := 3
        If num_screen > 1
          --num_screen
        Endif
      Elseif LastKey() == K_ESC
        If ( k := f_alert( { PadC( 'Выберите действие', 60, '.' ) }, ;
            { ' Выход без записи ', ' Возврат в редактирование ' }, ;
            1, 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N, N/BG' ) ) == 2
          k := 3
        Endif
      Else
        k := 3
        ++num_screen
        If mvozrast < 18
          num_screen := 1
          func_error( 4, 'Это не взрослый пациент!' )
        Elseif metap == 0
          num_screen := 1
          func_error( 4, 'Проверьте сроки лечения!' )
        Endif
      Endif
    Endif
    SetMode( 25, 80 )
    If k == 3
      Loop
    Elseif k == 2
      num_screen := 1
      If m1komu < 5 .and. Empty( m1company )
        If m1komu == 0
          s := 'СМО'
        Elseif m1komu == 1
          s := 'компании'
        Else
          s := 'комитета/МО'
        Endif
        func_error( 4, 'Не заполнено наименование ' + s )
        Loop
      Endif
      If m1komu == 0 .and. Empty( mnpolis )
        func_error( 4, 'Не заполнен номер полиса' )
        Loop
      Endif
      If Empty( mn_data )
        func_error( 4, 'Не введена дата начала лечения.' )
        Loop
      Endif
      If mvozrast < 18
        func_error( 4, 'Профилактика оказана НЕ взрослому пациенту!' )
        Loop
      Endif
      If Empty( mk_data )
        func_error( 4, 'Не введена дата окончания лечения.' )
        Loop
      Endif
      If Empty( CharRepl( '0', much_doc, Space( 10 ) ) )
        func_error( 4, 'Не заполнен номер амбулаторной карты' )
        Loop
      Endif
      // if eq_any(m1gruppa, 3, 4, 13, 14, 23, 24) ;
      // .and. m1DS_ONK != 1 .and. len(arr) == 0 ;
      // .and. (m1dopo_na == 0) ;
      // .and. (m1napr_v_mo == 0) .and. (m1napr_stac == 0) .and. (m1napr_reab == 0)
      // func_error(4, 'Для выбранной ГРУППЫ ЗДОРОВЬЯ выберите назначения (направления) для пациента!')
      If check_group_nazn( '1', 3, 4, 13, 14, 23, 24 ) .and. m1DS_ONK != 1 .and. Len( arr ) == 0
        Loop
      Endif
      If ! checktabnumberdoctor( mk_data, .t. )
        Loop
      Endif
      If Empty( mWEIGHT )
        func_error( 4, 'Не введён вес.' )
        Loop
      Endif
      If Empty( mHEIGHT )
        func_error( 4, 'Не введён рост.' )
        Loop
      Endif
      If Empty( mOKR_TALII )
        func_error( 4, 'Не введена окружность талии.' )
        Loop
      Endif
      If m1veteran == 1
        If metap == 3
          func_error( 4, 'Профилактику взрослых не проводят ветеранам ВОВ (блокадникам)' )
          Loop
        Endif
      Endif
      If ! checktabnumberdoctor( mk_data )
        Loop
      Endif
      //
      mdef_diagnoz := iif( metap == 2, 'Z01.8 ', 'Z00.8 ' )
      r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'MKB_10' )
      r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'P2' )
      num_screen := 2
      max_date1 := mn_data
      fl := .t.
      not_4_20_1 := .f.
      date_4_1_12 := CToD( '' )
      k := ku := kol_d_usl := 0
      arr_osm1 := Array( count_dvn_arr_usl, 11 )
      afillall( arr_osm1, 0 )
      For i := 1 To count_dvn_arr_usl
        fl_diag := fl_ekg := .f.
        i_otkaz := 0
        If f_is_usl_oms_sluch_dvn( i, metap, iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast ), mpol, @fl_diag, @i_otkaz, @fl_ekg )
          mvart := 'MTAB_NOMv' + lstr( i )
          If Empty( &mvart ) .and. ( eq_any( metap, 2, 5 ) .or. fl_ekg ) // ЭКГ, не введён врач
            Loop                                                 // и необязательный возраст
          Endif
          ar := dvn_arr_usl[ i ]
          mvara := 'MTAB_NOMa' + lstr( i )
          mvard := 'MDATE' + lstr( i )
          mvarz := 'MKOD_DIAG' + lstr( i )
          mvaro := 'M1OTKAZ' + lstr( i )
          if &mvard == mn_data
            k := i
          Endif
          If ValType( ar[ 2 ] ) == 'C' .and. ar[ 2 ] == '4.20.1'
            If not_4_20_1 // не включать услугу
              Loop
            Endif
            If m1g_cit == 2
              If Empty( &mvard )
                fl := func_error( 4, 'Не введена дата услуги "' + mg_cit + '"' )
              Endif
              arr_osm1[ i, 1 ]  := 0        // врач
              arr_osm1[ i, 2 ]  := -13 // 1107     // специальность
              arr_osm1[ i, 3 ]  := 0        // ассистент
              arr_osm1[ i, 4 ]  := 34       // профиль
              arr_osm1[ i, 5 ]  := '4.20.2' // шифр услуги
              arr_osm1[ i, 6 ]  := mdef_diagnoz
              arr_osm1[ i, 9 ]  := &mvard
              arr_osm1[ i, 10 ] := &mvaro
              // if date_4_1_12 < mn_data ; // если 4.1.12 оказано раньше дисп-ии
              // .or. arr_osm1[i, 9] < date_4_1_12 // или 4.20.1 раньше 4.1.12
              // arr_osm1[i, 9] := date_4_1_12 // приравняем даты
              // endif
              max_date1 := Max( max_date1, arr_osm1[ i, 9 ] )
              ++ku
              Loop
            Endif
          Else
            ++kol_d_usl
          Endif
          If i_otkaz == 2 .and. &mvaro == 2 // если исследование невозможно
            Select P2
            find ( Str( &mvart, 5 ) )
            If Found()
              arr_osm1[ i, 1 ] := p2->kod
            Endif
            If ValType( ar[ 11 ] ) == 'A' // специальность
              arr_osm1[ i, 2 ] := ar[ 11, 1 ]
            Endif
            If ValType( ar[ 10 ] ) == 'N' // профиль
              arr_osm1[ i, 4 ] := ar[ 10 ]
            Endif
            arr_osm1[ i, 5 ] := ar[ 2 ] // шифр услуги
            arr_osm1[ i, 9 ] := iif( Empty( &mvard ), mn_data, &mvard )
            arr_osm1[ i, 10 ] := &mvaro
            --kol_d_usl
          Elseif Empty( &mvard )
            fl := func_error( 4, 'Не введена дата услуги "' + LTrim( ar[ 1 ] ) + '"' )
          Elseif Empty( &mvart ) .and. ! is_lab_usluga( ar[ 2 ] ) // для услуг ЦКДЛ допускается пустое значение врача
            fl := func_error( 4, 'Не введен врач в услуге "' + LTrim( ar[ 1 ] ) + '"' )
          Else
            Select P2
            find ( Str( &mvart, 5 ) )
            If Found()
              arr_osm1[ i, 1 ] := p2->kod
              arr_osm1[ i, 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
            Endif
            If !Empty( &mvara )
              Select P2
              find ( Str( &mvara, 5 ) )
              If Found()
                arr_osm1[ i, 3 ] := p2->kod
              Endif
            Endif
            If ValType( ar[ 10 ] ) == 'N' // профиль
              arr_osm1[ i, 4 ] := ret_profil_dispans( ar[ 10 ], arr_osm1[ i, 2 ] )
            Else
              If Len( ar[ 10 ] ) == Len( ar[ 11 ] ) ; // кол-во профилей = кол-ву спец-тей
                .and. arr_osm1[ i, 2 ] < 0 ; // и нашли специальность по V015
                .and. ( j := AScan( ar[ 11 ], ret_old_prvs( arr_osm1[ i, 2 ] ) ) ) > 0
                // берём профиль, соответствующий специальности
              Else
                j := 1 // если нет, берём первый профиль из списка
              Endif
              arr_osm1[ i, 4 ] := ar[ 10, j ] // профиль
            Endif
            ++ku
            If ValType( ar[ 2 ] ) == 'C'
              arr_osm1[ i, 5 ] := ar[ 2 ] // шифр услуги
              m1var := 'm1lis' + lstr( i )
              If !is_disp_19 .and. glob_yes_kdp2()[ TIP_LU_DVN ] .and. &m1var > 0
                arr_osm1[ i, 11 ] := &m1var // кровь проверяют в КДП2
              Endif
              If ar[ 2 ] == '2.3.1'
                If eq_any( arr_osm1[ i, 2 ], 2002, -206 ) // специальность-фельдшер
                  arr_osm1[ i, 5 ] := '2.3.3' // шифр услуги
                  arr_osm1[ i, 4 ] := 42 // профиль - лечебному делу
                Elseif eq_any( arr_osm1[ i, 2 ], 2003, -207 ) // Акушерское дело
                  arr_osm1[ i, 5 ] := '2.3.3' // шифр услуги
                  arr_osm1[ i, 4 ] := 3 // профиль - акушерскому делу
                Endif
              Endif
            Else
              If Len( ar[ 2 ] ) >= metap
                j := metap
              Else
                j := 1
              Endif
              arr_osm1[ i, 5 ] := ar[ 2, j ] // шифр услуги
              If i == count_dvn_arr_usl // последняя услуга из массива - терапевт
                If eq_any( metap, 2, 5 )
                  If eq_any( arr_osm1[ i, 2 ], 2002, -206 ) // специальность-фельдшер
                    fl := func_error( 4, 'Фельдшер не может заменить терапевта на II этапе диспансеризации' )
                  Endif
                Else // 1 и 3 этап
                  If eq_any( arr_osm1[ i, 2 ], 2002, -206 ) // специальность-фельдшер
                    arr_osm1[ i, 5 ] := iif( is_disp_19, '2.3.4', '2.3.3' ) // шифр услуги
                    arr_osm1[ i, 4 ] := 42 // профиль - лечебному делу
                  Endif
                Endif
              Endif
            Endif
            If !fl_diag .or. Empty( &mvarz ) .or. Left( &mvarz, 1 ) == 'Z'
              arr_osm1[ i, 6 ] := mdef_diagnoz
            Else
              arr_osm1[ i, 6 ] := &mvarz
              Select MKB_10
              find ( PadR( arr_osm1[ i, 6 ], 6 ) )
              If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
                fl := func_error( 4, 'Несовместимость диагноза по полу ' + arr_osm1[ i, 6 ] )
              Endif
            Endif
            If ( arr_osm1[ i, 10 ] := &mvaro ) == 1 // отказ
              If arr_osm1[ i, 5 ] == '4.1.12' // Осмотр акушеркой, взятие мазка (соскоба)
                not_4_20_1 := .t. // не включать услугу
              Endif
            Endif
            If i_otkaz == 3 .and. &mvaro == 2 // НЕВОЗМОЖНОСТЬ для услуги 4.1.12
              If is_disp_19
                not_4_20_1 := .t. // не включать услугу
              Else
                If arr_osm1[ i, 2 ] == 1101 // если указана спец-ть врача
                  arr_osm1[ i, 5 ] := '2.3.1' // приём врача акушера-гинеколога
                  arr_osm1[ i, 4 ] := 136 // профиль - акушерству и гинекологии (за исключением использования вспомогательных репродуктивных технологий)
                Else
                  arr_osm1[ i, 5 ] := '2.3.3' // приём фельдшера-акушера
                  arr_osm1[ i, 4 ] := 3 // профиль - акушерскому делу
                Endif
                arr_osm1[ i, 10 ] := 0 // нет отказа (? может поставить 3-отклонение?)
                not_4_20_1 := .t. // не включать услугу
              Endif
            Endif
            arr_osm1[ i, 9 ] := &mvard
            // перепишем дату по 'связанным' услугам
            Do Case
            Case arr_osm1[ i, 5 ] == '4.1.12' // взятие мазка (соскоба)
              date_4_1_12 := arr_osm1[ i, 9 ]
            Case arr_osm1[ i, 5 ] == '4.20.1' // Иссл-е взятого цитологического материала
              // if date_4_1_12 < mn_data ; // если 4.1.12 оказано раньше дисп-ии
              // .or. arr_osm1[i, 9] < date_4_1_12 // или 4.20.1 раньше 4.1.12
              // arr_osm1[i, 9] := date_4_1_12 // приравняем даты
              // endif
            Endcase
            max_date1 := Max( max_date1, arr_osm1[ i, 9 ] )
          Endif
        Endif
        If !fl
          Exit
        Endif
      Next
      If !fl
        Loop
      Endif
      i_56_1_723 := 0
      If eq_any( metap, 2, 5 )
        If ku < 2
          If !is_disp_19 .and. ( i_56_1_723 := AScan( arr_osm1, {| x | ValType( x[ 5 ] ) == 'C' .and. x[ 5 ] == '56.1.723' } ) ) > 0
            // одно индивидуальное или групповое углубленное профилактическое консультирование - '56.1.723'
          Else
            func_error( 4, 'На II этапе обязателен осмотр терапевта и ещё какие-либо услуги.' )
            Loop
          Endif
        Endif
        If k == 0
          func_error( 4, 'Дата первого осмотра (исследования) должна равняться дате начала лечения.' )
          Loop
        Endif
      Endif
      fl := .t.
      If emptyany( arr_osm1[ count_dvn_arr_usl, 1 ], arr_osm1[ count_dvn_arr_usl, 9 ] )
        If metap == 2 .and. i_56_1_723 > 0
          If !( arr_osm1[ i_56_1_723, 9 ] == mn_data .and. arr_osm1[ i_56_1_723, 9 ] == mk_data )
            fl := func_error( 4, 'Начало и окончание должно равняться дате углубленного профилактич.консультирования' )
          Elseif lrslt_1_etap == 353 // Направлен на 2 этап, предварительно присвоена II группа здоровья
            If m1gruppa != 2
              fl := func_error( 4, 'Результатом 2-го этапа должна быть II группа здоровья (как и на 1-ом этапе)' )
              num_screen := 3
            Endif
          Else // другой результат
            fl := func_error( 4, 'Результатом 1-го этапа должна быть II группа (и направлен на 2-ой этап)' )
            num_screen := 3
          Endif
        Else
          fl := func_error( 4, 'Не введён приём терапевта (врача общей практики)' )
        Endif
      Elseif arr_osm1[ count_dvn_arr_usl, 9 ] < mk_data
        fl := func_error( 4, 'Терапевт (врач общей практики) должен проводить осмотр последним!' )
      Endif
      If !fl
        Loop
      Endif
      num_screen := 3
      arr_diag := {}
      For i := 1 To 5
        sk := lstr( i )
        pole_diag := 'mdiag' + sk
        pole_d_diag := 'mddiag' + sk
        pole_1pervich := 'm1pervich' + sk
        pole_1dispans := 'm1dispans' + sk
        pole_d_dispans := 'mddispans' + sk
        pole_dn_dispans := 'mdndispans' + sk
        If !Empty( &pole_diag )
          If Left( &pole_diag, 1 ) == 'Z'
            fl := func_error( 4, 'Диагноз ' + RTrim( &pole_diag ) + '(первый символ "Z") не вводится. Это не заболевание!' )
          elseif &pole_1pervich == 0
            If Empty( &pole_d_diag )
              fl := func_error( 4, 'Не введена дата выявления диагноза ' + &pole_diag )
            elseif &pole_1dispans == 1 .and. Empty( &pole_d_dispans )
              fl := func_error( 4, 'Не введена дата установления диспансерного наблюдения для диагноза ' + &pole_diag )
            Endif
          Endif
          If fl .and. Between( &pole_1pervich, 0, 1 ) // предварительные диагнозы не берём
            AAdd( arr_diag, { &pole_diag, &pole_1pervich, &pole_1dispans, &pole_dn_dispans } )
          Endif
        Endif
        If !fl
          Exit
        Endif
      Next
      If !fl
        Loop
      Endif
      is_disp_nabl := .f.
      AFill( adiag_talon, 0 )
      If Empty( arr_diag ) // диагнозы не вводили
        AAdd( arr_diag, { mdef_diagnoz, 0, 0, CToD( '' ) } ) // диагноз по умолчанию
        MKOD_DIAG := mdef_diagnoz
      Else
        For i := 1 To Len( arr_diag )
          If arr_diag[ i, 2 ] == 0 // 'ранее выявлено'
            arr_diag[ i, 2 ] := 2  // заменяем, как в листе учёта ОМС
          Endif
          If arr_diag[ i, 3 ] > 0 // 'дисп.наблюдение установлено' и 'ранее выявлено'
            If arr_diag[ i, 2 ] == 2 // 'ранее выявлено'
              arr_diag[ i, 3 ] := 1 // то 'Состоит'
            Else
              arr_diag[ i, 3 ] := 2 // то 'Взят'
            Endif
          Endif
        Next
        For i := 1 To Len( arr_diag )
//          If AScan( sadiag1, AllTrim( arr_diag[ i, 1 ] ) ) > 0 .and. ;
          If diag_in_list_dn( arr_diag[ i, 1 ] ) .and. ;
              arr_diag[ i, 3 ] == 1 .and. !Empty( arr_diag[ i, 4 ] ) .and. arr_diag[ i, 4 ] > mk_data
            is_disp_nabl := .t.
          Endif
          adiag_talon[ i * 2 -1 ] := arr_diag[ i, 2 ]
          adiag_talon[ i * 2    ] := arr_diag[ i, 3 ]
          If i == 1
            MKOD_DIAG := arr_diag[ i, 1 ]
          Elseif i == 2
            MKOD_DIAG2 := arr_diag[ i, 1 ]
          Elseif i == 3
            MKOD_DIAG3 := arr_diag[ i, 1 ]
          Elseif i == 4
            MKOD_DIAG4 := arr_diag[ i, 1 ]
          Elseif i == 5
            MSOPUT_B1 := arr_diag[ i, 1 ]
          Endif
          Select MKB_10
          find ( PadR( arr_diag[ i, 1 ], 6 ) )
          If Found()
            If !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
              fl := func_error( 4, 'несовместимость диагноза по полу ' + AllTrim( arr_diag[ i, 1 ] ) )
            Endif
          Else
            fl := func_error( 4, 'не найден диагноз ' + AllTrim( arr_diag[ i, 1 ] ) + ' в справочнике МКБ-10' )
          Endif
          If !fl
            Exit
          Endif
        Next
        If !fl
          Loop
        Endif
      Endif
      mm_gruppa := { mm_gruppaD1, mm_gruppaD2, mm_gruppaP, mm_gruppaD4, mm_gruppaD2 }[ metap ]
      If metap == 3
        If mk_data < 0d20191101
          mm_gruppa := mm_gruppaP_old
        Else
          mm_gruppa := mm_gruppaP_new
        Endif
      Endif
      m1p_otk := 0
      If ( i := AScan( mm_gruppa, {| x | x[ 2 ] == m1GRUPPA } ) ) > 0
        If ( m1rslt := mm_gruppa[ i, 3 ] ) == 352
          m1rslt := 353 // по письму ТФОМС от 06.07.18 №09-30-96
        Endif
        If eq_any( m1GRUPPA, 11, 21 )
          m1GRUPPA++ // по письму ТФОМС от 06.07.18 №09 -30 -96
        Endif
        If m1GRUPPA > 20
          m1p_otk := 1 // отказ от прихода на 2-й этап
        Endif
      Else
        func_error( 4, 'Не введена ГРУППА состояния ЗДОРОВЬЯ' )
        Loop
      Endif
      m1ssh_na := m1psih_na := m1spec_na := 0
      If m1napr_v_mo > 0
        If eq_ascan( arr_mo_spec, 45, 141 ) // Направлен к врачу-сердечно-сосудистому хирургу
          m1ssh_na := 1
        Endif
        If eq_ascan( arr_mo_spec, 23, 97 ) // Направлен к врачу-психиатру (врачу-психиатру-наркологу)
          m1psih_na := 1
        Endif
      Endif
      If m1napr_stac > 0 .and. m1profil_stac > 0
        m1spec_na := 1 // Направлен для получения специализированной медицинской помощи (в т.ч. ВМП)
      Endif
      //
      err_date_diap( mn_data, 'Дата начала лечения' )
      err_date_diap( mk_data, 'Дата окончания лечения' )
      //
      message_save_LU()
      mywait()
      //
      m1lis := 0
      For i := 1 To count_dvn_arr_usl
        If ValType( arr_osm1[ i, 9 ] ) == 'D'
          If arr_osm1[ i, 5 ] == '4.20.2' .and. arr_osm1[ i, 9 ] < mn_data // не в рамках диспансеризации
            m1g_cit := 1 // если и было =2, убираем
          Elseif !is_disp_19 .and. glob_yes_kdp2()[ TIP_LU_DVN ] .and. arr_osm1[ i, 9 ] >= mn_data .and. Len( arr_osm1[ i ] ) > 10 ;
              .and. ValType( arr_osm1[ i, 11 ] ) == 'N' .and. arr_osm1[ i, 11 ] > 0
            m1lis := arr_osm1[ i, 11 ] // в рамках диспансеризации
          Endif
        Endif
      Next
      is_prazdnik := f_is_prazdnik_dvn( mn_data )
      If eq_any( metap, 2, 5 )
        i := count_dvn_arr_usl
        m1vrach  := arr_osm1[ i, 1 ]
        m1prvs   := arr_osm1[ i, 2 ]
        m1assis  := arr_osm1[ i, 3 ]
        m1PROFIL := arr_osm1[ i, 4 ]
        // MKOD_DIAG := padr(arr_osm1[i, 6], 6)
      Else  // metap := 1, 3, 4
        i := Len( arr_osm1 )
        m1vrach  := arr_osm1[ i, 1 ]
        m1prvs   := arr_osm1[ i, 2 ]
        m1assis  := arr_osm1[ i, 3 ]
        m1PROFIL := arr_osm1[ i, 4 ]
        // MKOD_DIAG := padr(arr_osm1[i, 6], 6)
        AAdd( arr_osm1, Array( 11 ) )
        i := i_zs := Len( arr_osm1 )
        arr_osm1[ i, 1 ] := arr_osm1[ i - 1, 1 ]
        arr_osm1[ i, 2 ] := arr_osm1[ i -1, 2 ]
        arr_osm1[ i, 3 ] := arr_osm1[ i -1, 3 ]
        arr_osm1[ i, 4 ] := 151 // для кода ЗС - мед.осмотрам профилактическим
        arr_osm1[ i, 5 ] := ret_shifr_zs_dvn( metap, iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast ), mpol, mk_data )
        arr_osm1[ i, 6 ] := arr_osm1[ i -1, 6 ]
        arr_osm1[ i, 9 ] := mn_data
        arr_osm1[ i, 10 ] := 0
      Endif
      For i := 1 To count_dvn_arr_umolch
        If f_is_umolch_sluch_dvn( i, metap, iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast ), mpol )
          ++kol_d_usl
          AAdd( arr_osm1, Array( 11 ) )
          j := Len( arr_osm1 )
          arr_osm1[ j, 1 ] := m1vrach
          arr_osm1[ j, 2 ] := m1prvs
          arr_osm1[ j, 3 ] := m1assis
          arr_osm1[ j, 4 ] := m1PROFIL
          arr_osm1[ j, 5 ] := dvn_arr_umolch[ i, 2 ]
          arr_osm1[ j, 6 ] := mdef_diagnoz
          arr_osm1[ j, 9 ] := iif( dvn_arr_umolch[ i, 8 ] == 0, mn_data, mk_data )
          arr_osm1[ j, 10 ] := 0
        Endif
      Next
      If eq_any( metap, 1, 3, 4 ) // если первый этап, проверим на 85%
        not_zs := .f.
        kol := kol_otkaz := kol_n_date := kol_ob_otkaz := 0
        For i := 1 To Len( arr_osm1 )
          If i == i_zs
            Loop // пропустим код законченного случая
          Endif
          If ValType( arr_osm1[ i, 5 ] ) == 'C' .and. !eq_any( arr_osm1[ i, 5 ], '4.20.1', '4.20.2' )
            ++kol // кол-во реально введённых услуг
            If eq_any( arr_osm1[ i, 10 ], 0, 3 )
              If is_disp_19
                If arr_osm1[ i, 9 ] < mn_data .and. Year( arr_osm1[ i, 9 ] ) < Year( mn_data ) // кол-во услуг без отказа выполнены ранее
                  ++kol_n_date                 // начала проведения диспансеризации и не принадлежат текущему календарному году
                Endif
              Else
                If arr_osm1[ i, 9 ] < mn_data
                  ++kol_n_date // кол-во услуг без отказа до периода диспансеризации
                Endif
              Endif
            Elseif arr_osm1[ i, 10 ] == 1
              ++kol_otkaz // кол-во отказов
  /* При проведении диспансеризации обязательным для всех граждан является:
  - '7.57.3' проведение маммографии,
  - '4.8.4' исследование кала на скрытую кровь иммунохимическим качественным или количественным методом,
  - '2.3.1','2.3.3' осмотр фельдшером (акушеркой) или врачом акушером-гинекологом,
  - '4.1.12' взятие мазка с шейки матки,
  - '4.20.1','4.20.2' цитологическое исследование мазка с шейки матки,
  - '4.14.66' определение простат-специфического антигена в крови */
              If is_disp_19 .and. eq_any( arr_osm1[ i, 5 ], '4.8.4', '4.14.66', '7.57.3', '2.3.1', '2.3.3', '4.1.12', '4.20.1', '4.20.2' )
                ++kol_ob_otkaz // кол-во отказов от обязательных услуг
              Endif
            Else// if arr_osm1[i, 10] == 2 если невозможность проведения - просто вычитаем общее кол-во
              --kol
            Endif
          Endif
        Next
        // kol_d_usl = 100% (должно равняться 'kol')
        If kol_d_usl != kol
          // func_error(4, 'kol_d_usl (' + lstr(kol_d_usl)+') != kol ' + lstr(kol))
        Endif
        If metap == 4
          If kol_n_date == 1
            not_zs := .t. // выставляем по отдельным тарифам
          Endif
        Elseif ( i := AScan( dvn_85(), {| x | x[ 1 ] == kol } ) ) > 0 // определить 85%
          k := dvn_85()[ i, 1 ] - dvn_85()[ i, 2 ] // 15%
          If is_disp_19
            If kol_n_date + kol_otkaz <= k // отказы + ранее оказано менее 15%
              // выставляем по законченному случаю
              If kol_ob_otkaz > 0 .and. metap == 1 // надо переделать в профосмотр !!!!!
                If ( i := AScan( arr_osm1, {| x | ValType( x[ 5 ] ) == 'C' .and. x[ 5 ] == '2.3.7' } ) ) > 0
                  arr_osm1[ i, 5 ] := '2.3.2' // шифр услуги приёма терапевта для профосмотра
                Endif
                metap := 3
                If eq_any( m1rslt, 355, 356, 357, 358 ) .and. mk_data < 0d20191101 // III группа
                  m1rslt := 345
                  m1gruppa := 3
                Elseif eq_any( m1rslt, 355, 357 ) // IIIа группа
                  m1rslt := 373
                  m1gruppa := 3
                Elseif eq_any( m1rslt, 356, 358 ) // IIIб группа
                  m1rslt := 374
                  m1gruppa := 4
                Elseif eq_any( m1rslt, 318, 353 )
                  m1rslt := 344
                  m1gruppa := 2
                Else
                  m1rslt := 343
                  m1gruppa := 1
                Endif
                arr_osm1[ i_zs, 5 ] := ret_shifr_zs_dvn( metap, mdvozrast, mpol, mk_data )
                func_error( 4, 'Отказ от обязательного исследования - оформляем профилактический осмотр ' + arr_osm1[ i_zs, 5 ] )
              Endif
            Else
              // если < 85%, отсечём в проверке
            Endif
          Else
            If kol_otkaz <= k // оказано 85% и более
              If kol_n_date + kol_otkaz <= k // отказы + ранее оказано менее 15%
                // выставляем по законченному случаю
              Else
                not_zs := .t. // выставляем по отдельным тарифам
              Endif
            Else
              // если 'kol - kol_otkaz' < 85%, отсечём в проверке
            Endif
          Endif
        Else
          // если такого кол-ва услуг нет в массиве 'dvn_85()', отсечём в проверке
        Endif
        If not_zs // выставляем по отдельным тарифам
          del_array( arr_osm1, i_zs ) // удаляем законченный случай
          larr := {}
          For i := 1 To Len( arr_osm1 )
            If ValType( arr_osm1[ i, 5 ] ) == 'C' ;
                .and. !( Len( arr_osm1[ i ] ) > 10 .and. ValType( arr_osm1[ i, 11 ] ) == 'N' .and. arr_osm1[ i, 11 ] > 0 ) ; // не в КДП2
              .and. eq_any( arr_osm1[ i, 10 ], 0, 3 ) ; // не отказ
              .and. arr_osm1[ i, 9 ] >= mn_data ; // оказано во время дисп-ии
              .and. ( k := AScan( dvn_700(), {| x | x[ 1 ] == arr_osm1[ i, 5 ] } ) ) > 0
              AAdd( larr, AClone( arr_osm1[ i ] ) )
              j := Len( larr )
              larr[ j, 5 ] := dvn_700()[ k, 2 ]
            Endif
          Next
          For i := 1 To Len( larr )
            AAdd( arr_osm1, AClone( larr[ i ] ) ) // добавим в массив услуги на '700'
          Next
        Endif
      Endif
      make_diagp( 2 )  // сделать 'пятизначные' диагнозы
      If m1dispans > 0
        s1dispans := m1dispans
      Endif
      //
      use_base( 'lusl' )
      use_base( 'luslc' )
      use_base( 'uslugi' )
      r_use( dir_server() + 'uslugi1', { dir_server() + 'uslugi1', ;
        dir_server() + 'uslugi1s' }, 'USL1' )
      mcena_1 := mu_cena := 0
      arr_usl_dop := {}
      arr_usl_otkaz := {}
      arr_otklon := {}
      glob_podr := ''
      glob_otd_dep := 0
      For i := 1 To Len( arr_osm1 )
        If ValType( arr_osm1[ i, 5 ] ) == 'C'
          arr_osm1[ i, 7 ] := foundourusluga( arr_osm1[ i, 5 ], mk_data, arr_osm1[ i, 4 ], M1VZROS_REB, @mu_cena )
          arr_osm1[ i, 8 ] := mu_cena
          mcena_1 += mu_cena
          If eq_any( arr_osm1[ i, 10 ], 0, 3 ) // выполнено
            AAdd( arr_usl_dop, arr_osm1[ i ] )
            If arr_osm1[ i, 10 ] == 3 // обнаружены отклонения
              AAdd( arr_otklon, arr_osm1[ i, 5 ] )
            Endif
          Else // отказ и невозможность
            AAdd( arr_usl_otkaz, arr_osm1[ i ] )
          Endif
        Endif
      Next
      //
      use_base( 'human' )
      If Loc_kod > 0
        find ( Str( Loc_kod, 7 ) )
        mkod := Loc_kod
        g_rlock( forever )
      Else
        add1rec( 7 )
        mkod := RecNo()
        Replace human->kod With mkod
      Endif
      Select HUMAN_
      Do While human_->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      //
      Select HUMAN_2
      Do While human_2->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      //
      st_N_DATA := MN_DATA
      glob_perso := mkod
      If m1komu == 0
        msmo := lstr( m1company )
        m1str_crb := 0
      Else
        msmo := ''
        m1str_crb := m1company
      Endif
      //
      human->kod_k      := glob_kartotek
      human->TIP_H      := B_STANDART // 3-лечение завершено
      human->FIO        := MFIO          // Ф.И.О. больного
      human->POL        := MPOL          // пол
      human->DATE_R     := MDATE_R       // дата рождения больного
      human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
      human->ADRES      := MADRES        // адрес больного
      human->MR_DOL     := MMR_DOL       // место работы или причина безработности
      human->RAB_NERAB  := M1RAB_NERAB   // 0-работающий, 1-неработающий, 2-студент
      human->VZ         := M1VZ          // Вид занятости, указывается в соответствии со справочником V039 ФФОМС
      human->KOD_DIAG   := MKOD_DIAG     // шифр 1-ой осн.болезни
      human->KOD_DIAG2  := MKOD_DIAG2    // шифр 2-ой осн.болезни
      human->KOD_DIAG3  := MKOD_DIAG3    // шифр 3-ой осн.болезни
      human->KOD_DIAG4  := MKOD_DIAG4    // шифр 4-ой осн.болезни
      human->SOPUT_B1   := MSOPUT_B1     // шифр 1-ой сопутствующей болезни
      human->SOPUT_B2   := MSOPUT_B2     // шифр 2-ой сопутствующей болезни
      human->SOPUT_B3   := MSOPUT_B3     // шифр 3-ой сопутствующей болезни
      human->SOPUT_B4   := MSOPUT_B4     // шифр 4-ой сопутствующей болезни
      human->diag_plus  := mdiag_plus    //
      human->KOMU       := M1KOMU        // от 0 до 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis( mspolis, mnpolis ) // серия и номер страхового полиса
      human->LPU        := M1LPU         // код учреждения
      human->OTD        := M1OTD         // код отделения
      human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
      human->N_DATA     := MN_DATA       // дата начала лечения
      human->K_DATA     := MK_DATA       // дата окончания лечения
      human->CENA := human->CENA_1 := MCENA_1 // стоимость лечения
      human->ishod      := 200 + metap
      human->OBRASHEN   := iif( m1DS_ONK == 1, '1', ' ' )
      human->bolnich    := 0
      human->date_b_1   := ''
      human->date_b_2   := ''
      human->MOP        := m1MOP
      human->MO_PR      := code_TFOMS_to_FFOMS( m1MO_PR )    //  glob_mo()[ _MO_KOD_FFOMS ]
      human_->RODIT_DR  := CToD( '' )
      human_->RODIT_POL := ''
      s := ''
      AEval( adiag_talon, {| x | s += Str( x, 1 ) } )
      human_->DISPANS   := s
      human_->STATUS_ST := ''
      human_->POVOD     := iif( metap == 3, 5, 6 )
      // human_->TRAVMA    := m1travma
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := LTrim( mspolis )
      human_->NPOLIS    := LTrim( mnpolis )
      human_->OKATO     := '' // это поле вернётся из ТФОМС в случае иногороднего
      human_->NOVOR     := 0
      human_->DATE_R2   := CToD( '' )
      human_->POL2      := ''
      human_->USL_OK    := m1USL_OK
      human_->VIDPOM    := m1VIDPOM
      human_->PROFIL    := m1PROFIL
      human_->IDSP      := iif( metap == 3, 17, 11 )
      human_->NPR_MO    := ''
      human_->FORMA14   := '0000'
      human_->KOD_DIAG0 := ''
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // уберём '2', если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      If Loc_kod == 0  // при добавлении
        human_->ID_PAC    := mo_guid( 1, human_->( RecNo() ) )
        human_->ID_C      := mo_guid( 2, human_->( RecNo() ) )
        human_->SUMP      := 0
        human_->SANK_MEK  := 0
        human_->SANK_MEE  := 0
        human_->SANK_EKMP := 0
        human_->REESTR    := 0
        human_->REES_ZAP  := 0
        human->schet      := 0
        human_->SCHET_ZAP := 0
        human->kod_p   := kod_polzovat    // код оператора
        human->date_e  := c4sys_date
      Else // при редактированиии
        human_->kod_p2  := kod_polzovat    // код оператора
        human_->date_e2 := c4sys_date
      Endif
      put_0_human_2()
      Private fl_nameismo := .f.
      If m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ОКАТО субъекта РФ территории страхования
        If Empty( m1ismo )
          If !Empty( mnameismo )
            fl_nameismo := .t.
          Endif
        Else
          human_->SMO := m1ismo  // заменяем '34' на код иногородней СМО
        Endif
      Endif
      If fl_nameismo .or. rec_inogSMO > 0
        g_use( dir_server() + 'mo_hismo', , 'SN' )
        Index On Str( FIELD->kod, 7 ) to ( cur_dir() + 'tmp_ismo' )
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
      i1 := Len( arr_usl )
      i2 := Len( arr_usl_dop )
      use_base( 'human_u' )
      For i := 1 To i2
        Select HU
        If i > i1
          add1rec( 7 )
          hu->kod := human->kod
        Else
          Goto ( arr_usl[ i ] )
          g_rlock( forever )
        Endif
        mrec_hu := hu->( RecNo() )
        hu->kod_vr  := arr_usl_dop[ i, 1 ]
        hu->kod_as  := arr_usl_dop[ i, 3 ]
        hu->u_koef  := 1
        hu->u_kod   := arr_usl_dop[ i, 7 ]
        hu->u_cena  := arr_usl_dop[ i, 8 ]
        hu->is_edit := iif( Len( arr_usl_dop[ i ] ) > 10 .and. ValType( arr_usl_dop[ i, 11 ] ) == 'N', arr_usl_dop[ i, 11 ], 0 )
        hu->date_u  := dtoc4( arr_usl_dop[ i, 9 ] )
        hu->otd     := m1otd
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := arr_usl_dop[ i, 8 ]
        hu->KOL_RCP := 0
        Select HU_
        Do While hu_->( LastRec() ) < mrec_hu
          Append Blank
        Enddo
        Goto ( mrec_hu )
        g_rlock( forever )
        If i > i1 .or. !valid_guid( hu_->ID_U )
          hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
        Endif
        hu_->PROFIL := arr_usl_dop[ i, 4 ]
        hu_->PRVS   := arr_usl_dop[ i, 2 ]
        hu_->kod_diag := iif( Empty( arr_usl_dop[ i, 6 ] ), MKOD_DIAG, arr_usl_dop[ i, 6 ] )
        hu_->zf := ''
        Unlock
      Next
      If i2 < i1
        For i := i2 + 1 To i1
          Select HU
          Goto ( arr_usl[ i ] )
          deleterec( .t., .f. )  // очистка записи без пометки на удаление
        Next
      Endif
      save_arr_dvn( mkod )
      If m1ds_onk == 1 // подозрение на злокачественное новообразование
        save_mo_onkna( mkod, _NPR_DISP_ZNO )
      Endif
      write_work_oper( glob_task, OPER_LIST, iif( Loc_kod == 0, 1, 2 ), 1, count_edit )
      fl_write_sluch := .t.
      Close databases
      stat_msg( 'Запись завершена!', .f. )
    Endif
    Exit
  Enddo
  Close databases
  SetColor( tmp_color )
  RestScreen( buf )
  chm_help_code := tmp_help
  If fl_write_sluch // если записали - запускаем проверку
    If Type( 'fl_edit_DVN' ) == 'L'
      fl_edit_DVN := .t.
    Endif
    If !Empty( Val( msmo ) )
      verify_oms_sluch( glob_perso )
    Endif
  Endif

  Return Nil
