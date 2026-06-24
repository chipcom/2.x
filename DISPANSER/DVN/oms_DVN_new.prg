#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 24.06.26 ДВН - добавление или редактирование случая (листа учета)
Function oms_sluch_dvn( Loc_kod, kod_kartotek, f_print )

  // Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  // f_print - наименование функции для печати

  Static st_N_DATA, st_K_DATA, s1dispans := 1
  Local bg := {| o, k | get_mkb10( o, k, .t. ) }, arr_del := {}, mrec_hu := 0, ;
    buf := SaveScreen(), tmp_color := SetColor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', arr_usl := {}, ah, ;
    pos_read := 0, k_read := 0, count_edit := 0, ar, larr, lu_kod, ;
    fl, fl_write_sluch := .f., mu_cena, lrslt_1_etap := 0, ;
    k, s, sk
  local aDvn_arr_usl, aDvn_arr_umolch, mm_ndisp1
  local arr_usl_dop := {}
  local j, i, i2
  local usl_zamena, kprof

  local str_head
  local mm_otkaz, mm_otkaz1, mm_otkaz0
  local iKol
  local lRecto_II := .f., aRecto_II // массив ввода врачей для ректо....
  local lMamoGr := .f., aMamoGr // массив ввода врачей для маммография
  local lFluor := .f., aFluor // массив ввода врачей для флюрографии
  local lEKG := .f., aEKG // массив ввода врачей для ЭКГ
  local lOtkazMazok := .f., lNevozCit := .f.  // отказ или невозможность взятия мазка
  local lCit := .f., aCit  // массив ввода врачей для цитологий
  local lTom_II := .f., aTom_II // массив ввода врачей для томографии
  local mm_gruppaD1, mm_gruppaD2, mm_gruppaD4
  local mm_gruppaP  //  , mm_gruppaP_new
  local gender, age
  local mm_gruppa, isNewKart := .f.
  local mm_met_issl
  local ltShifr, lRep_etap := .f.

//  local tmp_help := chm_help_code

  Default st_N_DATA To Date(), st_K_DATA To Date()
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
  Private arr_usl_otkaz := {}, arr_otklon := {}, m1p_otk := 0
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
  Private is_disp_19 := .t., is_disp_nabl := .f.

  // для направлений к специалистам
  Private mnapr_v_mo, m1napr_v_mo := 0, mm_napr_v_mo := arr_mm_napr_v_mo(), ;
    arr_mo_spec := {}, ma_mo_spec, m1a_mo_spec := 1
  
  Private mnapr_stac, m1napr_stac := 0, ;
    mm_napr_stac := arr_mm_napr_stac(), ;
    mprofil_stac, m1profil_stac := 0
  Private mnapr_reab, m1napr_reab := 0, mprofil_kojki, m1profil_kojki := 0
  
  Private mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0
  
  Private m1NAPR_MO, mNAPR_MO, mNAPR_DATE, mNAPR_V, m1NAPR_V, mMET_ISSL, m1MET_ISSL, ;
    mshifr, mshifr1, mname_u, mU_KOD
  Private cur_napr := 0, count_napr := 0, tip_onko_napr := 0, mTab_Number := 0
  
  Private mm_napr_v := { ;
    { 'нет', 0 }, ;
    { 'к онкологу', 1 }, ;
    { 'на дообследование', 3 } }
  //
  Private pole_diag, pole_pervich, pole_1pervich, pole_d_diag, ;
    pole_stadia, pole_dispans, pole_1dispans, pole_d_dispans, pole_dn_dispans
      
  Private mm_pervich := arr_mm_pervich()
  Private mm_dispans := arr_mm_dispans()
  Private mDS_ONK, m1DS_ONK := 0 // Признак подозрения на злокачественное новообразование
//  Private mm_dopo_na := arr_mm_dopo_na()
//  Private gl_arr := { ;  // для битовых полей
//    { 'dopo_na', 'N', 10, 0, , , , {| x | inieditspr( A__MENUBIT, mm_dopo_na, x ) } };
//  }
//  Private mm_dopo_na := getv029()
  Private gl_arr := { ;  // для битовых полей
    { 'dopo_na', 'N', 10, 0, , , , {| x | inieditspr( A__MENUBIT, getv029(), x ) } };
  }

  Private mg_cit := '', m1g_cit := 0, m1lis := 0, mm_g_cit := { ;
    { 'в МО-обычное иссл-е цитологичес.материала', 1 }, ;
    { 'в ВОКОД-жидкостное иссл-ие цит.материала', 2 } }

  
  Return Nil
