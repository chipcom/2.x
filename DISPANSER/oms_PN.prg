#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 20.09.25 ПН - добавление или редактирование случая (листа учета)
Function oms_sluch_pn( Loc_kod, kod_kartotek, f_print )

  // Loc_kod - код по БД human.dbf (если = 0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  // f_print - наименование функции для печати
  Static st_N_DATA, st_K_DATA, st_mo_pr := '      '
  Local L_BEGIN_RSLT := 331
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, arr_del := {}, mrec_hu := 0, ;
    buf := SaveScreen(), tmp_color := SetColor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', arr_usl := {}, ;
    i, j, k, n, s, s1, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod, ;
    tmp_help := chm_help_code, fl_write_sluch := .f., _y, _m, _d, t_arr[ 2 ], ;
    arr_prof := {}, is_3_5_4 := .f.

  local arr_PN_issled
  local arr_PN_osmotr
  local arr_osmotr_KDP2
  local arr_not_zs
  local mm_mesto_prov := { ;
    { 'медицинская организация', 0 }, ;
    { 'общеобразовательное учреждение', 1 } ;
  }
  local mm_step2 := { ;
    { 'нет  ', 0 }, ;
    { 'да   ', 1 }, ;
    { 'ОТКАЗ', 2 } ;
  }
  local dir_DB
  //
  Default st_N_DATA To sys_date, st_K_DATA To sys_date
  Default Loc_kod To 0, kod_kartotek To 0, f_print To ''
  dir_DB := dir_server()
  //
  If kod_kartotek == 0 // добавление в картотеку
    If ( kod_kartotek := edit_kartotek( 0, , , .t. ) ) == 0
      Return Nil
    Endif
  Endif
  chm_help_code := 3002
  Private mfio := Space( 50 ), mpol, mdate_r, madres, mvozrast, mdvozrast, msvozrast := ' ', ;
    M1VZROS_REB, MVZROS_REB, m1novor := 0, ;
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-ОМС, 1-компании, 3-комитеты/ЛПУ, 5-личный счет
    msmo := '34007', rec_inogSMO := 0, ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := Space( 100 ), ;
    mvidpolis, m1vidpolis := 1, mspolis := Space( 10 ), mnpolis := Space( 20 )
  Private mkod := Loc_kod, mtip_h, is_talon := .f., is_disp_19 := .t., ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    M1LPU := glob_uch[ 1 ], MLPU, ;
    M1OTD := glob_otd[ 1 ], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MUCH_DOC    := Space( 10 ), ; // вид и номер учетного документа
    mmobilbr, m1mobilbr := 0, ;
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
    m1rslt  := L_BEGIN_RSLT + 1, ; // результат (присвоена I группа здоровья)
    m1ishod := 306, ; // исход = осмотр
    mn_data := st_N_DATA, ; // дата начала лечения
    mk_data := st_K_DATA, ; // дата окончания лечения
    MVRACH := Space( 10 ), ; // фамилия и инициалы лечащего врача
    M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0, ; // код, таб.№ и спец-ть лечащего врача
    m1povod  := 4, ;   // Профилактический
    m1travma := 0, ;
    m1USL_OK := USL_OK_POLYCLINIC, ; // поликлиника
    m1VIDPOM :=  1, ; // первичная
    m1PROFIL := 68, ; // педиатрия
    m1IDSP   := 17   // законченный случай в п-ке
  //
//  Private mm_kateg_uch := { { 'ребенок-сирота', 0 }, ;
//    { 'ребенок, оставшийся без попечения родителей', 1 }, ;
//    { 'ребенок, находящийся в трудной жизненной ситуации', 2 }, ;
//    { 'нет категории', 3 } }
/*
  Private mm_mesto_prov := { { 'медицинская организация', 0 }, ;
    { 'общеобразовательное учреждение', 1 } }
*/
//  Private mm_fiz_razv := { { 'нормальное', 0 }, ;
//    { 'с отклонениями', 1 } }
//  Private mm_fiz_razv1 := { { 'нет    ', 0 }, ;
//    { 'дефицит', 1 }, ;
//    { 'избыток', 2 } }
//  Private mm_fiz_razv2 := { { 'нет    ', 0 }, ;
//    { 'низкий ', 1 }, ;
//    { 'высокий', 2 } }
//  Private mm_psih2 := { { 'норма', 0 }, { 'нарушения', 1 } }
//  Private mm_142me3 := { { 'регулярные', 0 }, ;
//    { 'нерегулярные', 1 } }
//  Private mm_142me4 := { { 'обильные', 0 }, ;
//    { 'умеренные', 1 }, ;
//    { 'скудные', 2 } }
//  Private mm_142me5 := { { 'болезненные', 0 }, ;
//    { 'безболезненные', 1 } }
  Private mm_dispans := { { 'ранее', 1 }, { 'впервые', 2 }, { 'не уст.', 0 } }
  Private mm_usl := { { 'амб.', 0 }, { 'дн/с', 1 }, { 'стац', 2 } }
  Private mm_uch := { { 'МУЗ ', 1 }, { 'ГУЗ ', 0 }, { 'фед.', 2 }, { 'част', 3 } }
  Private mm_uch1 := AClone( mm_uch )

  AAdd( mm_uch1, { 'сан.', 4 } )
  Private mm_gr_fiz_do := { { 'I', 1 }, { 'II', 2 }, { 'III', 3 }, { 'IV', 4 } }
  Private mm_gr_fiz := AClone( mm_gr_fiz_do )
  AAdd( mm_gr_fiz_do, { 'отсутствует', 0 } )
  AAdd( mm_gr_fiz, { 'не допущен', 0 } )
//  Private mm_invalid2 := { { 'с рождения', 0 }, { 'приобретенная', 1 } }
//  Private mm_invalid5 := { { 'некоторые инфекционные и паразитарные,', 1 }, ;
//    { ' из них: туберкулез,', 101 }, ;
//    { '         сифилис,', 201 }, ;
//    { '         ВИЧ-инфекция;', 301 }, ;
//    { 'новообразования;', 2 }, ;
//    { 'болезни крови, кроветворных органов ...', 3 }, ;
//    { 'болезни эндокринной системы ...', 4 }, ;
//    { ' из них: сахарный диабет;', 104 }, ;
//    { 'психические расстройства и расстройства поведения,', 5 }, ;
//    { ' в том числе умственная отсталость;', 105 }, ;
//    { 'болезни нервной системы,', 6 }, ;
//    { ' из них: церебральный паралич,', 106 }, ;
//    { '         другие паралитические синдромы;', 206 }, ;
//    { 'болезни глаза и его придаточного аппарата;', 7 }, ;
//    { 'болезни уха и сосцевидного отростка;', 8 }, ;
//    { 'болезни системы кровообращения;', 9 }, ;
//    { 'болезни органов дыхания,', 10 }, ;
//    { ' из них: астма,', 110 }, ;
//    { '         астматический статус;', 210 }, ;
//    { 'болезни органов пищеварения;', 11 }, ;
//    { 'болезни кожи и подкожной клетчатки;', 12 }, ;
//    { 'болезни костно-мышечной системы и соединительной ткани;', 13 }, ;
//    { 'болезни мочеполовой системы;', 14 }, ;
//    { 'отдельные состояния, возникающие в перинатальном периоде;', 15 }, ;
//    { 'врожденные аномалии,', 16 }, ;
//    { ' из них: аномалии нервной системы,', 116 }, ;
//    { '         аномалии системы кровообращения,', 216 }, ;
//    { '         аномалии опорно-двигательного аппарата;', 316 }, ;
//    { 'последствия травм, отравлений и др.', 17 } }
//  Private mm_invalid6 := { { 'умственные', 1 }, ;
//    { 'другие психологические', 2 }, ;
//    { 'языковые и речевые', 3 }, ;
//    { 'слуховые и вестибулярные', 4 }, ;
//    { 'зрительные', 5 }, ;
//    { 'висцеральные и метаболические расстройства питания', 6 }, ;
//    { 'двигательные', 7 }, ;
//    { 'уродующие', 8 }, ;
//    { 'общие и генерализованные', 9 } }
//  Private mm_invalid8 := { { 'полностью', 1 }, ;
//    { 'частично', 2 }, ;
//    { 'начата', 3 }, ;
//    { 'не выполнена', 0 } }
//  Private mm_privivki1 := { { 'привит по возрасту', 0 }, ;
//    { 'не привит по медицинским показаниям', 1 }, ;
//    { 'не привит по другим причинам', 2 } }
//  Private mm_privivki2 := { { 'полностью', 1 }, ;
//    { 'частично', 2 } }
  //
  Private metap := 1, mperiod := 0, mshifr_zs := '', mnapr_onk := Space( 10 ), m1napr_onk := 0, ;
    mkateg_uch, m1kateg_uch := 3, ; // Категория учета ребенка:
    mmesto_prov := Space( 10 ), m1mesto_prov := 0, ; // место проведения
    mMO_PR := Space( 10 ), m1MO_PR := st_mo_pr, ; // код МО прикрепления
    mschool := Space( 10 ), m1school := 0, ; // код обр.учреждения
    mWEIGHT := 0, ;   // вес в кг
    mHEIGHT := 0, ;   // рост в см
    mPER_HEAD := 0, ; // окружность головы в см
    mfiz_razv, m1FIZ_RAZV := 0, ; // физическое развитие
    mfiz_razv1, m1FIZ_RAZV1 := 0, ; // отклонение массы тела
    mfiz_razv2, m1FIZ_RAZV2 := 0, ; // отклонение роста
    m1psih11 := 0, ;  // познавательная функция (возраст развития)
    m1psih12 := 0, ;  // моторная функция (возраст развития)
    m1psih13 := 0, ;  // эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития)
    m1psih14 := 0, ;  // предречевое и речевое развитие (возраст развития)
    mpsih21, m1psih21 := 0, ;  // Психомоторная сфера: (норма, отклонение)
    mpsih22, m1psih22 := 0, ;  // Интеллект: (норма, отклонение)
    mpsih23, m1psih23 := 0, ;  // Эмоционально-вегетативная сфера: (норма, отклонение)
    m141p   := 0, ; // Половая формула мальчика P
    m141ax  := 0, ; // Половая формула мальчика Ax
    m141fa  := 0, ; // Половая формула мальчика Fa
    m142p   := 0, ; // Половая формула девочки P
    m142ax  := 0, ; // Половая формула девочки Ax
    m142ma  := 0, ; // Половая формула девочки Ma
    m142me  := 0, ; // Половая формула девочки Me
    m142me1 := 0, ; // Половая формула девочки - menarhe (лет)
    m142me2 := 0, ; // Половая формула девочки - menarhe (месяцев)
    m142me3, m1142me3 := 0, ; // Половая формула девочки - menses (характеристика):
    m142me4, m1142me4 := 1, ; // Половая формула девочки - menses (характеристика):
    m142me5, m1142me5 := 1, ; // Половая формула девочки - menses (характеристика):
    mdiag_15_1, m1diag_15_1 := 1, ; // Состояние здоровья до проведения профосмотра-Практически здоров
    mdiag_15[ 5, 14 ], ; //
    mGRUPPA_DO := 0, ; // группа здоровья до дисп-ии
    mGR_FIZ_DO, m1GR_FIZ_DO := 1, ;
    mdiag_16_1, m1diag_16_1 := 1, ; // Состояние здоровья по результатам проведения профосмотра (Практически здоров)
    mdiag_16[ 5, 16 ], ; //
    minvalid[ 8 ], ;  // раздел 16.7
    mGRUPPA := 0, ;    // группа здоровья после дисп-ии
    mGR_FIZ, m1GR_FIZ := 1, ;
    mPRIVIVKI[ 3 ], ; // Проведение профилактических прививок
    mrek_form := Space( 255 ), ; // 'C100',Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой
    mrek_disp := Space( 255 ), ; // 'C100',Рекомендации по диспансерному наблюдению, лечению, медицинской реабилитации и санаторно-курортному лечению с указанием диагноза (код МКБ), вида медицинской организации и специальности (должности) врача
    mhormon := '0 шт.', m1hormon := 1, not_hormon, ;
    mstep2, m1step2 := 0, m1p_otk := 0, musl2 := 'нет', m1usl2 := 0 //, ;
//    mm_step2 := { { 'нет  ', 0 }, { 'да   ', 1 }, { 'ОТКАЗ', 2 } }
  Private minvalid1, m1invalid1 := 0, ;
    minvalid2, m1invalid2 := 0, ;
    minvalid3 := CToD( '' ), minvalid4 := CToD( '' ), ;
    minvalid5, m1invalid5 := 0, ;
    minvalid6, m1invalid6 := 0, ;
    minvalid7 := CToD( '' ), ;
    minvalid8, m1invalid8 := 0
  Private mprivivki1, m1privivki1 := 0, ;
    mprivivki2, m1privivki2 := 0, ;
    mprivivki3 := Space( 100 )
  Private mvar, m1var, m1lis := 0
  Private mDS_ONK, m1DS_ONK := 0 // Признак подозрения на злокачественное новообразование
  Private mdopo_na, m1dopo_na := 0
  Private mm_dopo_na := arr_mm_dopo_na()
  Private gl_arr := { ;  // для битовых полей
    { 'dopo_na', 'N', 10, 0, , , , {| x| inieditspr( A__MENUBIT, mm_dopo_na, x ) } };
  }
  Private mnapr_v_mo, m1napr_v_mo := 0, mm_napr_v_mo := arr_mm_napr_v_mo(), ;
    arr_mo_spec := {}, ma_mo_spec, m1a_mo_spec := 1
  Private mnapr_stac, m1napr_stac := 0, mm_napr_stac := arr_mm_napr_stac(), ;
    mprofil_stac, m1profil_stac := 0
  Private mnapr_reab, m1napr_reab := 0, mprofil_kojki, m1profil_kojki := 0, arr_usl_otkaz := {}
  Private mm_otkaz := { { 'выпол.', 0 }, { 'ОТКАЗ ', 1 } }, is_neonat := .f.

  Private mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

  Private m1NAPR_MO, mNAPR_MO, mNAPR_DATE, mNAPR_V, m1NAPR_V, mMET_ISSL, m1MET_ISSL, ;
    mshifr, mshifr1, mname_u, mU_KOD, cur_napr := 0, count_napr := 0, tip_onko_napr := 0, ;
    mTab_Number := 0

  arr_osmotr_KDP2 := np_arr_osmotr_KDP2()
  arr_not_zs := np_arr_not_zs() 
  For i := 1 To 5
    For k := 1 To 14
      s := 'diag_15_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := 'm1' + s
        Private &m1var := 0
        Private &mvar := Space( 4 )
      Endif
    Next
  Next
  //
  For i := 1 To 5
    For k := 1 To 16
      s := 'diag_16_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := 'm1' + s
        Private &m1var := 0
        Private &mvar := Space( 3 )
      Endif
    Next
  Next
//  For i := 1 To count_pn_arr_iss // исследования
  For i := 1 To count_pn_arr_iss( Date() ) // исследования
    If eq_any( i, 8, 10 )  // гематолог и детский онколог
      m1var := 'M1ONKO' + lstr( i )
      Private &m1var := 0
      mvar := 'MONKO' + lstr( i )
      Private &mvar := inieditspr( A__MENUVERT, mm_vokod(), &m1var )
    Endif
    mvar := 'MTAB_NOMiv' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMia' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATEi' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MREZi' + lstr( i )
    Private &mvar := Space( 17 )
    mvar := 'MOTKAZi' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := 'M1OTKAZi' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
    m1var := 'M1LIS' + lstr( i )
    Private &m1var := 0
    mvar := 'MLIS' + lstr( i )
    Private &mvar := inieditspr( A__MENUVERT, mm_kdp2, &m1var )
  Next
//  For i := 1 To count_pn_arr_osm // осмотры
/*
  For i := 1 To count_pn_arr_osm( Date() ) // осмотры
    mvar := 'MTAB_NOMov' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMoa' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATEo' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MKOD_DIAGo' + lstr( i )
    Private &mvar := Space( 6 )
    mvar := 'MOTKAZo' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := 'M1OTKAZo' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
  Next
  For i := 1 To 2                // педиатр(ы)
    mvar := 'MTAB_NOMpv' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMpa' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATEp' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MKOD_DIAGp' + lstr( i )
    Private &mvar := Space( 6 )
    mvar := 'MOTKAZp' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := 'M1OTKAZp' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
  Next
*/
  //
  AFill( adiag_talon, 0 )
  //
  dbCreate( cur_dir() + 'tmp', { ;
    { 'U_KOD',    'N',      4,      0 }, ;  // код услуги
    { 'U_SHIFR',    'C',     10,      0 }, ;  // шифр услуги
    { 'U_NAME',     'C',     65,      0 } ;  // наименование услуги
  } )
  Use ( cur_dir() + 'tmp' )
  Index On Str( FIELD->u_kod, 4 ) to ( cur_dir() + 'tmpk' )
  Index On fsort_usl( FIELD->u_shifr ) to ( cur_dir() + 'tmpn' )
  Set Index to ( cur_dir() + 'tmpk' ), ( cur_dir() + 'tmpn' )
  r_use( dir_DB + 'human_', , 'HUMAN_' )
  r_use( dir_DB + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  If mkod_k > 0
    r_use( dir_DB + 'kartote2', , 'KART2' )
    Goto ( mkod_k )
    r_use( dir_DB + 'kartote_', , 'KART_' )
    Goto ( mkod_k )
    r_use( dir_DB + 'kartotek', , 'KART' )
    Goto ( mkod_k )
    M1FIO       := 1
    mfio        := kart->fio
    mpol        := kart->pol
    mdate_r     := kart->date_r
    M1VZROS_REB := kart->VZROS_REB
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    m1RAB_NERAB := kart->RAB_NERAB
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
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
      mnameismo := ret_inogsmo_name( 1,, .t. ) // открыть и закрыть
    Endif
    // проверка исхода = СМЕРТЬ и поиск предыдущих профилактик
    Select HUMAN
    Set Index to ( dir_DB + 'humankk' )
    find ( Str( mkod_k, 7 ) )
    Do While human->kod_k == mkod_k .and. !Eof()
      If RecNo() != Loc_kod .and. human_->oplata != 9 .and. human_->NOVOR == 0 .and. Year( human->k_data ) > 2017
        If is_death( human_->RSLT_NEW )
          a_smert := { 'Данный больной умер!', ;
            'Лечение с ' + full_date( human->N_DATA ) + ;
            ' по ' + full_date( human->K_DATA ) }
        Endif
        If eq_any( human->ishod, 301, 302 ) // если профилактика несовершеннолетних
          read_arr_pn( human->kod, .f. ) // читаем переменную 'mperiod'
          _mperiod := mperiod
          arr_PN_issled := np_arr_issled( human->k_data )
          arr_PN_osmotr := np_arr_osmotr( human->k_data )
          If _mperiod > 0
            AAdd( arr_prof, { _mperiod, human->n_data, human->k_data } )
            If eq_any( _mperiod, 1, 2 )
              r_use( dir_DB + 'uslugi', , 'USL' )
              r_use( dir_DB + 'human_u', dir_DB + 'human_u', 'HU' )
              find ( Str( human->kod, 7 ) )
              Do While hu->kod == human->kod .and. !Eof()
                usl->( dbGoto( hu->u_kod ) )
                If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
                  lshifr := usl->shifr
                Endif
                If AllTrim( lshifr ) == '3.5.4' // Аудиологический скрининг
                  is_3_5_4 := .t.
                Endif
                Select HU
                Skip
              Enddo
              hu->( dbCloseArea() )
              usl->( dbCloseArea() )
            Endif
          Endif
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    Set Index To
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
    M1RAB_NERAB := human->RAB_NERAB     // 0-работающий, 1-неработающий
    mUCH_DOC    := human->uch_doc
    m1VRACH     := human_->vrach
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
    metap      := human->ishod -300
    mGRUPPA    := human_->RSLT_NEW - L_BEGIN_RSLT
    is_disp_19 := !( mk_data < 0d20191101 )
    If metap == 2
      m1step2 := 1
    Endif
    arr_PN_osmotr := np_arr_osmotr( mk_data )
    //
//    larr_i := Array( count_pn_arr_iss )
    larr_i := Array( count_pn_arr_iss( mk_data ) )
    AFill( larr_i, 0 )
    larr_o := Array( Len( arr_PN_osmotr ) ) //count_pn_arr_osm( mk_data ) )
    AFill( larr_o, 0 )
    larr_p := {}
    mdate1 := mdate2 := CToD( '' )
    r_use( dir_DB + 'uslugi', , 'USL' )
    use_base( 'human_u' )
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
        lshifr := usl->shifr
      Endif
      lshifr := AllTrim( lshifr )
      If Left( lshifr, 5 ) == '72.2.'
        mshifr_zs := lshifr
      Elseif hu->is_edit == -1
        Select TMP
        Append Blank
        tmp->U_KOD := hu->u_kod
        tmp->U_SHIFR := usl->shifr
        tmp->U_NAME := usl->name
        ++m1usl2
      Else
        fl := .t.
//        For i := 1 To count_pn_arr_iss
        For i := 1 To count_pn_arr_iss( mk_data )
//          If np_arr_issled[ i, 1 ] == lshifr
          If arr_PN_issled[ i, 1 ] == lshifr
            fl := .f.
            larr_i[ i ] := hu->( RecNo() )
            Exit
//          Elseif ( j := AScan( np_arr_not_zs, {| x| x[ 2 ] == lshifr } ) ) > 0 .and. np_arr_issled[ i, 1 ] == np_arr_not_zs[ j, 1 ]
          Elseif ( j := AScan( arr_not_zs, {| x| x[ 2 ] == lshifr } ) ) > 0 .and. arr_PN_issled[ i, 1 ] == arr_not_zs[ j, 1 ]
            fl := .f.
            larr_i[ i ] := hu->( RecNo() )
            Exit
          Endif
        Next
        If fl
//          For i := 1 To count_pn_arr_osm( mk_data )
//            If Left( np_arr_osmotr[ i, 1 ], 4 ) == '2.4.'
//              If lshifr == np_arr_osmotr[ i, 1 ]
          For i := 1 To Len( arr_PN_osmotr )
            If Left( arr_PN_osmotr[ i, 1 ], 4 ) == '2.4.'
              If lshifr == arr_PN_osmotr[ i, 1 ]
                fl := .f.
                larr_o[ i ] := hu->( RecNo() )
                Exit
              Endif
//            Elseif f_profil_ginek_otolar( np_arr_osmotr[ i, 4 ], hu_->PROFIL )
            Elseif f_profil_ginek_otolar( arr_PN_osmotr[ i, 4 ], hu_->PROFIL )
              fl := .f.
              larr_o[ i ] := hu->( RecNo() )
              Exit
            Endif
          Next i
        Endif
        If fl .and. eq_any( hu_->PROFIL, 68, 57 )
          AAdd( larr_p, { hu->( RecNo() ), c4tod( hu->date_u ) } )
        Endif
      Endif
      AAdd( arr_usl, hu->( RecNo() ) )
      Select HU
      Skip
    Enddo
    If m1step2 == 1
      musl2 := 'Кол-во услуг - ' + lstr( m1usl2 )
    Else
      m1usl2 := 0
      Select TMP
      Zap
    Endif
    If Len( larr_p ) > 1 // если осмотр педиатра I этапа позднее педиатра II этапа
      ASort( larr_p,,, {| x, y| x[ 2 ] < y[ 2 ] } )
      If metap == 1
        ASize( larr_p, 1 ) // отрезать лишние приёмы
      Else
        Do While Len( larr_p ) > 2 // когда педиатр I этапа введён как две услуги (2.3.* и 2.91.*)
          hb_ADel( larr_p, 2, .t. ) // т.е. оставляем первый и последний приём
        Enddo
      Endif
    Endif
    r_use( dir_DB + 'mo_pers', , 'P2' )
    For j := 1 To 3
      If j == 1
        _arr := larr_i
        bukva := 'i'
      Elseif j == 2
        _arr := larr_o
        bukva := 'o'
      Else
        _arr := larr_p
        bukva := 'p'
      Endif
      For i := 1 To Len( _arr )
        k := iif( j == 3, _arr[ i, 1 ], _arr[ i ] )
        If !Empty( k )
          hu->( dbGoto( k ) )
          If hu->kod_vr > 0
            p2->( dbGoto( hu->kod_vr ) )
            mvar := 'MTAB_NOM' + bukva + 'v' + lstr( i )
            &mvar := p2->tab_nom
          Endif
          If hu->kod_as > 0
            p2->( dbGoto( hu->kod_as ) )
            mvar := 'MTAB_NOM' + bukva + 'a' + lstr( i )
            &mvar := p2->tab_nom
          Endif
          mvar := 'MDATE' + bukva + lstr( i )
          &mvar := c4tod( hu->date_u )
          If j == 1
            m1var := 'm1lis' + lstr( i )
            If is_disp_19
              &m1var := 0
//            Elseif glob_yes_kdp2()[ TIP_LU_PN ] .and. AScan( glob_arr_usl_LIS, np_arr_issled[ i, 1 ] ) > 0 .and. hu->is_edit > 0
            Elseif glob_yes_kdp2()[ TIP_LU_PN ] .and. AScan( glob_arr_usl_LIS, arr_PN_issled[ i, 1 ] ) > 0 .and. hu->is_edit > 0
              &m1var := hu->is_edit
            Endif
            mvar := 'mlis' + lstr( i )
            &mvar := inieditspr( A__MENUVERT, mm_kdp2, &m1var )
          Elseif j == 2 .and. eq_any( i, 8, 10 )
            m1var := 'm1onko' + lstr( i )
            If hu->is_edit > 0
              &m1var := hu->is_edit
            Endif
            mvar := 'monko' + lstr( i )
            &mvar := inieditspr( A__MENUVERT, mm_vokod(), &m1var )
          Elseif !Empty( hu_->kod_diag ) .and. !( Left( hu_->kod_diag, 1 ) == 'Z' )
            mvar := 'MKOD_DIAG' + bukva + lstr( i )
            &mvar := hu_->kod_diag
          Endif
          m1var := 'M1OTKAZ' + bukva + lstr( i )
          &m1var := 0 // выполнено
          mvar := 'MOTKAZ' + bukva + lstr( i )
          &mvar := inieditspr( A__MENUVERT, mm_otkaz, &m1var )
        Endif
      Next
    Next
    read_arr_pn( Loc_kod )
    If metap == 1 .and. m1p_otk == 1
      m1step2 := 2
    Endif
    If ValType( arr_usl_otkaz ) == 'A'
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) > 9 .and. ValType( ar[ 5 ] ) == 'C' .and. ;
            ValType( ar[ 10 ] ) == 'C' .and. ar[ 10 ] $ 'io'
          lshifr := AllTrim( ar[ 5 ] )
          bukva := ar[ 10 ]
//          If ( i := AScan( iif( bukva == 'i', np_arr_issled, np_arr_osmotr ), {| x| ValType( x[ 1 ] ) == 'C' .and. x[ 1 ] == lshifr } ) ) > 0
          If ( i := AScan( iif( bukva == 'i', arr_PN_issled, arr_PN_osmotr ), {| x| ValType( x[ 1 ] ) == 'C' .and. x[ 1 ] == lshifr } ) ) > 0
            If ValType( ar[ 1 ] ) == 'N' .and. ar[ 1 ] > 0
              p2->( dbGoto( ar[ 1 ] ) )
              mvar := 'MTAB_NOM' + bukva + 'v' + lstr( i )
              &mvar := p2->tab_nom
            Endif
            If ValType( ar[ 3 ] ) == 'N' .and. ar[ 3 ] > 0
              p2->( dbGoto( ar[ 3 ] ) )
              mvar := 'MTAB_NOM' + bukva + 'a' + lstr( i )
              &mvar := p2->tab_nom
            Endif
            mvar := 'MDATE' + bukva + lstr( i )
            &mvar := mn_data
            If ValType( ar[ 9 ] ) == 'D'
              &mvar := ar[ 9 ]
            Endif
            m1var := 'M1OTKAZ' + bukva + lstr( i )
            &m1var := 1 // отказ
            mvar := 'MOTKAZ' + bukva + lstr( i )
            &mvar := inieditspr( A__MENUVERT, mm_otkaz, &m1var )
          Endif
        Endif
      Next
    Endif
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 2, @rec_inogSMO, .t. ) // открыть и закрыть
    Endif
  Endif
  If !( Left( msmo, 2 ) == '34' ) // не Волгоградская область
    m1ismo := msmo
    msmo := '34'
  Endif

  dbCreate( cur_dir() + 'tmp_onkna', create_struct_temporary_onkna() )
  cur_napr := 1 // при ред-ии - сначала первое направление текущее
  count_napr := collect_napr_zno( Loc_kod )
  If count_napr > 0
    mnapr_onk := 'Количество направлений - ' + lstr( count_napr )
  Endif

  Close databases
  is_talon := .t.

  fv_date_r( iif( Loc_kod > 0, mn_data, ) )
  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  mlpu      := inieditspr( A__POPUPMENU, dir_DB + 'mo_uch', m1lpu )
  motd      := inieditspr( A__POPUPMENU, dir_DB + 'mo_otd', m1otd )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf(), m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
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
  //
  mmesto_prov := inieditspr( A__MENUVERT, mm_mesto_prov, m1mesto_prov ) // место проведения
  mmobilbr := inieditspr( A__MENUVERT, mm_danet, m1mobilbr )
  mschool := inieditspr( A__POPUPMENU, dir_DB + 'mo_schoo', m1school )
  mkateg_uch := inieditspr( A__MENUVERT, mm_kateg_uch(), m1kateg_uch )
  If !Empty( m1MO_PR )
    mMO_PR := ret_mo( m1MO_PR )[ _MO_SHORT_NAME ]
  Endif
  mfiz_razv  := inieditspr( A__MENUVERT, mm_fiz_razv(),  m1FIZ_RAZV )
  mfiz_razv1 := inieditspr( A__MENUVERT, mm_fiz_razv1(), m1FIZ_RAZV1 )
  mfiz_razv2 := inieditspr( A__MENUVERT, mm_fiz_razv2(), m1FIZ_RAZV2 )
  mpsih21 := inieditspr( A__MENUVERT, mm_psih2(), m1psih21 )
  mpsih22 := inieditspr( A__MENUVERT, mm_psih2(), m1psih22 )
  mpsih23 := inieditspr( A__MENUVERT, mm_psih2(), m1psih23 )
  m142me3 := inieditspr( A__MENUVERT, mm_142me3(), m1142me3 )
  m142me4 := inieditspr( A__MENUVERT, mm_142me4(), m1142me4 )
  m142me5 := inieditspr( A__MENUVERT, mm_142me5(), m1142me5 )
  mdiag_15_1 := inieditspr( A__MENUVERT, mm_danet, m1diag_15_1 )
  mdiag_16_1 := inieditspr( A__MENUVERT, mm_danet, m1diag_16_1 )
  mstep2 := inieditspr( A__MENUVERT, mm_step2, m1step2 )
  minvalid1 := inieditspr( A__MENUVERT, mm_danet,    m1invalid1 )
  minvalid2 := inieditspr( A__MENUVERT, mm_invalid2(), m1invalid2 )
  minvalid5 := inieditspr( A__MENUVERT, mm_invalid5(), m1invalid5 )
  minvalid6 := inieditspr( A__MENUVERT, mm_invalid6(), m1invalid6 )
  minvalid8 := inieditspr( A__MENUVERT, mm_invalid8(), m1invalid8 )
  mprivivki1 := inieditspr( A__MENUVERT, mm_privivki1(), m1privivki1 )
  mprivivki2 := inieditspr( A__MENUVERT, mm_privivki2(), m1privivki2 )
  mgr_fiz_do := inieditspr( A__MENUVERT, mm_gr_fiz_do, m1gr_fiz_do )
  mgr_fiz    := inieditspr( A__MENUVERT, mm_gr_fiz, m1gr_fiz )
  mDS_ONK    := inieditspr( A__MENUVERT, mm_danet, M1DS_ONK )
  mdopo_na   := inieditspr( A__MENUBIT,  mm_dopo_na, m1dopo_na )
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
  //
  If !Empty( f_print )
    return &( f_print + '(' + lstr( Loc_kod ) + ',' + lstr( kod_kartotek ) + ',' + lstr( mdvozrast ) + ')' )
  Endif
  //
  str_1 := ' случая профилактики несовершеннолетних'
  If Loc_kod == 0
    str_1 := 'Добавление' + str_1
    mtip_h := yes_vypisan
  Else
    str_1 := 'Редактирование' + str_1
  Endif
  SetColor( color8 )
  //
  Private gl_area
  SetColor( cDataCGet )
  make_diagp( 1 )  // сделать 'шестизначные' диагнозы
  Private num_screen := 1
  Do While .t.
    Close databases
    DispBegin()
    If num_screen == 5
      hS := 32
      wS := 90
      If m1step2 == 2
        hS += 2
      Endif
    Elseif num_screen == 3
      hS := 30
      wS := 80
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
      s1 := ' '
      is_disp_19 := !( mk_data < 0d20191101 )
      arr_PN_issled := np_arr_issled( mk_data )
      arr_PN_osmotr := np_arr_osmotr( mk_data )
      mperiod := ret_period_pn( mdate_r, mn_data, mk_data, @s1 )
      s := AllTrim( mfio )
      If mperiod > 0
        s += s1
      Endif
      @ j, wS - Len( s ) Say s Color color14
      If !Between( mperiod, 1, 31 )
        DispEnd()
        func_error( 4, 'Не удалось определить возрастной период!' )
        If !Empty( s1 )
          func_error( 10, s1 )
        Endif
        num_screen := 1
        Loop
      Elseif ( i := AScan( arr_prof, {| x| x[ 1 ] == mperiod } ) ) > 0
        DispEnd()
        func_error( 4, 'Уже была аналогичная профилактика с ' + date_8( arr_prof[ i, 2 ] ) + ' по ' + date_8( arr_prof[ i, 3 ] ) )
        num_screen := 1
        Loop
      Endif
    Endif
    If num_screen == 1
      @ ++j, 1 Say 'Учреждение' Get mlpu When .f. Color cDataCSay
      @ Row(), Col() + 2 Say 'Отделение' Get motd When .f. Color cDataCSay
      //
      @ ++j, 1 Say 'ФИО' Get mfio_kart ;
        reader {| x| menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
        valid {| g, o| update_get( 'mkomu' ), update_get( 'mcompany' ) }
      @ ++j, 1 Say 'Принадлежность счёта' Get mkomu ;
        reader {| x| menu_reader( x, mm_komu, A__MENUVERT, , , .f. ) } ;
        valid {| g, o| f_valid_komu( g, o ) } ;
        Color colget_menu
      @ Row(), Col() + 1 Say '==>' Get mcompany ;
        reader {| x| menu_reader( x, mm_company, A__MENUVERT, , , .f. ) } ;
        When m1komu < 5 ;
        valid {| g| func_valid_ismo( g, m1komu, 38 ) }
      @ ++j, 1 Say 'Полис ОМС: серия' Get mspolis When m1komu == 0
      @ Row(), Col() + 3 Say 'номер'  Get mnpolis When m1komu == 0
      @ Row(), Col() + 3 Say 'вид'    Get mvidpolis ;
        reader {| x| menu_reader( x, mm_vid_polis, A__MENUVERT, , , .f. ) } ;
        When m1komu == 0 ;
        Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
      @ ++j, 1 To j, 78
      @ ++j, 1 Say 'Категория учета ребенка' Get mkateg_uch ;
        reader {| x| menu_reader( x, mm_kateg_uch(), A__MENUVERT, , , .f. ) }
      ++j
      @ ++j, 1 Say 'Сроки профилактики' Get mn_data ;
        valid {| g| f_k_data( g, 1 ), ;
        iif( mvozrast < 18, nil, func_error( 4, 'Это взрослый пациент!' ) ), ;
        msvozrast := PadR( count_ymd( mdate_r, mn_data ), 40 ), ;
        .t. ;
        }
      @ Row(), Col() + 1 Say '-' Get mk_data valid {| g| f_k_data( g, 2 ) }
      @ Row(), Col() + 3 Get msvozrast When .f. Color color14
      @ ++j, 1 Say '№ амбулаторной карты' Get much_doc Picture '@!' ;
        When !( is_uchastok == 1 .and. is_task( X_REGIST ) ) ;
        .or. mem_edit_ist == 2
      @ ++j, 1 Say 'Место проведения медосмотра' Get mmesto_prov ;
        reader {| x| menu_reader( x, mm_mesto_prov, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say 'Медосмотр проведён мобильной бригадой?' Get mmobilbr ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      ++j
      @ ++j, 1 Say 'МО прикрепления' Get mMO_PR ;
        reader {| x| menu_reader( x, { {| k, r, c| f_get_mo( k, r, c ) } }, A__FUNCTION, , , .f. ) }
      @ ++j, 1 Say 'Общеобразовательное учреждение' Get mschool ;
        reader {| x| menu_reader( x, { dir_DB + 'mo_schoo', , , , , , 'Общеобразовательные учр-ия', 'B/BG' }, A__POPUPBASE, , , .f. ) }
      ++j
      @ ++j, 1 Say 'Вес' Get mWEIGHT Pict '999' ;
        valid {|| iif( Between( mWEIGHT, 2, 170 ), , func_error( 4, 'Неразумный вес' ) ), .t. }
      @ Row(), Col() + 1 Say 'кг, рост' Get mHEIGHT Pict '999' ;
        valid {|| iif( Between( mHEIGHT, 40, 250 ), , func_error( 4, 'Неразумный рост' ) ), .t. }
      @ Row(), Col() + 1 Say 'см, окружность головы' Get mPER_HEAD  Pict '999' ;
        valid {|| iif( mdvozrast < 5, iif( Between( mPER_HEAD, 10, 100 ), , func_error( 4, 'Неразумный размер окружности головы' ) ), ), .t. }
      @ Row(), Col() + 1 Say 'см'
      ++j
      @ ++j, 1 Say 'Физическое развитие' Get mfiz_razv ;
        reader {| x| menu_reader( x, mm_fiz_razv(), A__MENUVERT, , , .f. ) } ;
        valid {|| iif( m1FIZ_RAZV == 0, ( mfiz_razv1 := 'нет    ', m1fiz_razv1 := 0, ;
        mfiz_razv2 := 'нет    ', m1fiz_razv2 := 0 ), nil ), .t. }
      @ ++j, 10 Say 'отклонение массы тела' Get mfiz_razv1 ;
        reader {| x| menu_reader( x, mm_fiz_razv1(), A__MENUVERT, , , .f. ) } ;
        When m1FIZ_RAZV == 1
      @ j, 39 Say ', роста' Get mfiz_razv2 ;
        reader {| x| menu_reader( x, mm_fiz_razv2(), A__MENUVERT, , , .f. ) } ;
        When m1FIZ_RAZV == 1
      status_key( '^<Esc>^ выход без записи ^<PgDn>^ на 2-ю страницу' )
      If !Empty( a_smert )
        n_message( a_smert, , 'GR+/R', 'W+/R', , , 'G+/R' )
      Endif
    Elseif num_screen == 2
      np_oftal_2_85_21( mperiod, mk_data )
      ar := np_arr_1_etap( mk_data )[ mperiod ]

//  For i := 1 To count_pn_arr_osm // осмотры
  For i := 1 To Len( arr_PN_osmotr )  //count_pn_arr_osm( mk_data ) // осмотры
    mvar := 'MTAB_NOMov' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMoa' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATEo' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MKOD_DIAGo' + lstr( i )
    Private &mvar := Space( 6 )
    mvar := 'MOTKAZo' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := 'M1OTKAZo' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
  Next
  For i := 1 To 2                // педиатр(ы)
    mvar := 'MTAB_NOMpv' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMpa' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATEp' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MKOD_DIAGp' + lstr( i )
    Private &mvar := Space( 6 )
    mvar := 'MOTKAZp' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := 'M1OTKAZp' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
  Next


      If !Empty( ar[ 5 ] ) // не пустой массив исследований
        @ ++j, 1 Say 'I этап наименований исследований       Врач Ассис.  Дата     Выполнение Результат' Color 'RB+/B'
        If mem_por_ass == 0
          @ j, 45 Say Space( 6 )
        Endif
        not_hormon := .t.
//        For i := 1 To count_pn_arr_iss
        For i := 1 To count_pn_arr_iss( mk_data )
          fl := .t.
//          If fl .and. !Empty( np_arr_issled[ i, 2 ] )
          If fl .and. !Empty( arr_PN_issled[ i, 2 ] )
            fl := ( mpol == np_arr_issled[ i, 2 ] )
          Endif
          If fl
//            fl := ( AScan( ar[ 5 ], np_arr_issled[ i, 1 ] ) > 0 )
            fl := ( AScan( ar[ 5 ], arr_PN_issled[ i, 1 ] ) > 0 )
          Endif
          /*//if fl .and. np_arr_issled[i, 4] == 1 // гормон
          if fl .and. arr_PN_issled[i, 4] == 1 // гормон
            if not_hormon
         ++j; @ j, 1 say padr('Исследование уровня гормонов в крови', 38) color color8
              @ j, 39 get mhormon ;
                 reader {|x| menu_reader(x, {{|k,r,c| get_hormon_pn(k,r,c)}},A__FUNCTION,,, .f.)}
            endif
            fl := not_hormon := .f.
          endif*/
          If fl
            fl_kdp2 := .f.
//            If !is_disp_19 .and. glob_yes_kdp2()[ TIP_LU_PN ] .and. AScan( glob_arr_usl_LIS, np_arr_issled[ i, 1 ] ) > 0
            If !is_disp_19 .and. glob_yes_kdp2()[ TIP_LU_PN ] .and. AScan( glob_arr_usl_LIS, arr_PN_issled[ i, 1 ] ) > 0
              fl_kdp2 := .t.
            Endif
            mvarv := 'MTAB_NOMiv' + lstr( i )
            mvara := 'MTAB_NOMia' + lstr( i )
            mvard := 'MDATEi' + lstr( i )
            mvarr := 'MREZi' + lstr( i )
            mvaro := 'MOTKAZi' + lstr( i )
            mvarlis := 'MLIS' + lstr( i )
            If Empty( &mvard )
              &mvard := mn_data
            Endif
//            @ ++j, 1 Say PadR( np_arr_issled[ i, 3 ], 38 )
            @ ++j, 1 Say PadR( arr_PN_issled[ i, 3 ], 38 )
            If fl_kdp2
              @ j, 34 get &mvarlis reader {| x| menu_reader( x, mm_kdp2, A__MENUVERT, , , .f. ) }
            Endif
            @ j, 39 get &mvarv Pict '99999' valid {| g| v_kart_vrach( g ) }
            If mem_por_ass > 0
              @ j, 45 get &mvara Pict '99999' valid {| g| v_kart_vrach( g ) }
            Endif
            @ j, 51 get &mvard
            @ j, 62 get &mvaro reader {| x| menu_reader( x, mm_otkaz, A__MENUVERT, , , .f. ) }
            @ j, 69 get &mvarr
          Endif
        Next
      Endif
      @ ++j, 1 Say 'I этап наименований осмотров           Врач Ассис.  Дата     Выполнение' Color 'RB+/B'
      If mem_por_ass == 0
        @ j, 45 Say Space( 6 )
      Endif
      If !Empty( ar[ 4 ] ) // не пустой массив осмотров
        For i := 1 To Len( arr_PN_osmotr )  // count_pn_arr_osm
          fl := .t.
//          If fl .and. !Empty( np_arr_osmotr[ i, 2 ] )
//            fl := ( mpol == np_arr_osmotr[ i, 2 ] )
          If fl .and. !Empty( arr_PN_osmotr[ i, 2 ] )
            fl := ( mpol == arr_PN_osmotr[ i, 2 ] )
          Endif
          If fl
//            fl := ( AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) > 0 )
            fl := ( AScan( ar[ 4 ], arr_PN_osmotr[ i, 1 ] ) > 0 )
          Endif
/*
          If fl .and. mperiod == 16 .and. mk_data < 0d20191101 .and. np_arr_osmotr[ i, 1 ] == '2.4.2' // 2 года
            fl := .f.
          Endif
          If fl .and. mperiod == 20 .and. mk_data < 0d20191101 .and. np_arr_osmotr[ i, 1 ] == '2.85.24' // 6 лет
            fl := .f.
          Endif
*/
          If fl .and. mperiod == 16 .and. mk_data < 0d20191101 .and. arr_PN_osmotr[ i, 1 ] == '2.4.2' // 2 года
            fl := .f.
          Endif
          If fl .and. mperiod == 20 .and. mk_data < 0d20191101 .and. arr_PN_osmotr[ i, 1 ] == '2.85.24' // 6 лет
            fl := .f.
          Endif
          If fl
            mvarv := 'MTAB_NOMov' + lstr( i )
            mvara := 'MTAB_NOMoa' + lstr( i )
            mvard := 'MDATEo' + lstr( i )
            mvaro := 'MOTKAZo' + lstr( i )
            mvarz := 'MKOD_DIAGo' + lstr( i )
            If Empty( &mvard )
              &mvard := mn_data
            Endif
//            @ ++j, 1 Say PadR( np_arr_osmotr[ i, 3 ], 38 )
            @ ++j, 1 Say PadR( arr_PN_osmotr[ i, 3 ], 38 )
            @ j, 39 get &mvarv Pict '99999' valid {| g| v_kart_vrach( g ) }
            If mem_por_ass > 0
              @ j, 45 get &mvara Pict '99999' valid {| g| v_kart_vrach( g ) }
            Endif
            @ j, 51 get &mvard
            @ j, 62 get &mvaro reader {| x| menu_reader( x, mm_otkaz, A__MENUVERT, , , .f. ) }
          Endif
        Next
      Endif
      If Empty( MDATEp1 )
        MDATEp1 := mn_data
      Endif
      @ ++j, 1 Say PadR( 'педиатр (врач общей практики)', 38 ) Color color8
      @ j, 39 Get MTAB_NOMpv1 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMpa1 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Endif
      @ j, 51 Get MDATEp1
      status_key( '^<Esc>^ выход без записи ^<PgUp>^ на 1-ю страницу ^<PgDn>^ на 3-ю страницу' )
    Elseif num_screen == 3
      @ ++j, 1 Say 'Направлен на II этап ?' Get mstep2 ;
        reader {| x| menu_reader( x, mm_step2, A__MENUVERT, , , .f. ) }
      If !is_disp_19
        ++j
        @ ++j, 1 Say 'Дополнительные гематологические исследования в КДП2' Get musl2 ;
          reader {| x| menu_reader( x, { {|k, r, c| ob2_v_usl( .t., r + 1 ) } }, A__FUNCTION, , , .f. ) } ;
          When m1step2 == 1
      Endif
      ar := np_arr_1_etap( mk_data )[ mperiod ]
      @ ++j, 1 Say 'II этап наименований осмотров          Врач Ассис.  Дата     Выполнение' Color 'RB+/B'
      If mem_por_ass == 0
        @ j, 45 Say Space( 6 )
      Endif
      For i := 1 To Len( arr_PN_osmotr )  // count_pn_arr_osm
        fl := .t.
//        If fl .and. !Empty( np_arr_osmotr[ i, 2 ] )
//          fl := ( mpol == np_arr_osmotr[ i, 2 ] )
        If fl .and. !Empty( arr_PN_osmotr[ i, 2 ] )
          fl := ( mpol == arr_PN_osmotr[ i, 2 ] )
        Endif
        If fl .and. !Empty( ar[ 4 ] )
//          fl := ( AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) == 0 )
          fl := ( AScan( ar[ 4 ], arr_PN_osmotr[ i, 1 ] ) == 0 )
        Endif
//        If fl .and. !( np_arr_osmotr[ i, 1 ] == '2.4.2' )
        If fl .and. !( arr_PN_osmotr[ i, 1 ] == '2.4.2' )
          mvonk := 'MONKO' + lstr( i )
          mvarv := 'MTAB_NOMov' + lstr( i )
          mvara := 'MTAB_NOMoa' + lstr( i )
          mvard := 'MDATEo' + lstr( i )
          mvaro := 'MOTKAZo' + lstr( i )
          mvarz := 'MKOD_DIAGo' + lstr( i )
//          @ ++j, 1 Say PadR( np_arr_osmotr[ i, 3 ], 38 )
          @ ++j, 1 Say PadR( arr_PN_osmotr[ i, 3 ], 38 )
          If eq_any( i, 8, 10 )
            @ j, 32 get &mvonk reader {| x| menu_reader( x, mm_vokod(), A__MENUVERT, , , .f. ) } When m1step2 == 1
          Endif
          @ j, 39 get &mvarv Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
          If mem_por_ass > 0
            @ j, 45 get &mvara Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
          Endif
          @ j, 51 get &mvard When m1step2 == 1
          @ j, 62 get &mvaro reader {| x| menu_reader( x, mm_otkaz, A__MENUVERT, , , .f. ) } When m1step2 == 1
        Endif
      Next
      @ ++j, 1 Say PadR( 'педиатр (врач общей практики)', 38 ) Color color8
      @ j, 39 Get MTAB_NOMpv2 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMpa2 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Endif
      @ j, 51 Get MDATEp2 When m1step2 == 1
      status_key( '^<Esc>^ выход без записи ^<PgUp>^ на 2-ю страницу ^<PgDn>^ на 4-ю страницу' )
    Elseif num_screen == 4
      If mdvozrast < 5 // если меньше 5 лет
        @ ++j, 1 Say PadC( 'Оценка психического развития (возраст развития):', 78, '_' )
        @ ++j, 1 Say 'познавательная функция' Get m1psih11 Pict '99'
        @ ++j, 1 Say 'моторная функция      ' Get m1psih12 Pict '99'
        @ --j, 30 Say 'эмоциональная и социальная    ' Get m1psih13 Pict '99'
        @ ++j, 30 Say 'предречевое и речевое развитие' Get m1psih14 Pict '99'
      Else
        @ ++j, 1 Say PadC( 'Оценка психического развития:', 78, '_' )
        @ ++j, 1 Say 'психомоторная сфера' Get mpsih21 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT, , , .f. ) }
        @ ++j, 1 Say 'интеллект          ' Get mpsih22 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT, , , .f. ) }
        @ --j, 40 Say 'эмоц.вегетативная сфера' Get mpsih23 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT, , , .f. ) }
        ++j
      Endif
      ++j
      If mpol == 'М'
        @ ++j, 1 Say 'Половая формула мальчика: P' Get m141p Pict '9'
        @ j, Col() Say ', Ax' Get m141ax Pict '9'
        @ j, Col() Say ', Fa' Get m141fa Pict '9'
      Else
        @ ++j, 1 Say 'Половая формула девочки: P' Get m142p Pict '9'
        @ j, Col() Say ', Ax' Get m142ax Pict '9'
        @ j, Col() Say ', Ma' Get m142ma Pict '9'
        @ j, Col() Say ', Me' Get m142me Pict '9'
        @ ++j, 1 Say '  menarhe' Get m142me1 Pict '99'
        @ j, Col() + 1 Say 'лет,' Get m142me2 Pict '99'
        @ j, Col() + 1 Say 'месяцев, menses' Get m142me3 ;
          reader {| x| menu_reader( x, mm_142me3(), A__MENUVERT, , , .f. ) }
        @ j, 50 Say ',' Get m142me4 ;
          reader {| x| menu_reader( x, mm_142me4(), A__MENUVERT, , , .f. ) }
        @ j, 61 Say ',' Get m142me5 ;
          reader {| x| menu_reader( x, mm_142me5(), A__MENUVERT, , , .f. ) }
      Endif
      ++j
      @ ++j, 1 Say 'ДО ПРОВЕДЕНИЯ ПРОФОСМОРА: практически здоров' Get mdiag_15_1 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '──────┬───────┬─────────────┬─────────┬─────────────┬─────────┬───────────────'
      @ ++j, 1 Say ' Диаг-│Диспанс│Лечение назна│Выполнено│Реаб-ия назна│Выполнена│Высокотехнол.МП'
      @ ++j, 1 Say ' ноз  │набл-ие│че-┌────┬────┼────┬────┤че-┌────┬────┼────┬────┼───────┬───────'
      @ ++j, 1 Say '      │установ│но │усл.│учр.│усл.│учр.│на │усл.│учр.│усл.│учр.│рекомен│оказана'
      @ ++j, 1 Say '──────┴───────┴───┴────┴────┴────┴────┴───┴────┴────┴────┴────┴───────┴───────'
      For i := 1 To 5
        ++j
        fl := .f.
        For k := 1 To 14
          s := 'diag_15_' + lstr( i ) + '_' + lstr( k )
          mvar := 'm' + s
          If k == 1
            fl := !Empty( &mvar )
          Else
            m1var := 'm1' + s
            If fl
              If eq_any( k, 2 )
                mm_m := mm_dispans
              Elseif eq_any( k, 4, 6, 9, 11 )
                mm_m := mm_usl
              Elseif eq_any( k, 5, 7, 10, 12 )
                mm_m := mm_uch1
              Else
                mm_m := mm_danet
              Endif
              &mvar := inieditspr( A__MENUVERT, mm_m, &m1var )
            Else
              &m1var := 0
              &mvar := Space( 4 )
            Endif
          Endif
          Do Case
          Case k == 1
            @ j, 1 get &mvar Picture pic_diag ;
              reader {| o| mygetreader( o, bg ) } Valid val1_10diag( .t., .f., .f., mn_data, mpol ) ;
              When m1diag_15_1 == 0
          Case k == 2
            @ j, 8 get &mvar ;
              reader {| x| menu_reader( x, mm_dispans, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 3
            @ j, 16 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 4
            @ j, 20 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 5
            @ j, 25 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 6
            @ j, 30 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 7
            @ j, 35 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 8
            @ j, 40 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 9
            @ j, 44 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 10
            @ j, 49 get &mvar ;
              reader {| x| menu_reader( x, mm_uch1, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 11
            @ j, 54 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 12
            @ j, 59 get &mvar ;
              reader {| x| menu_reader( x, mm_uch1, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 13
            @ j, 66 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 14
            @ j, 74 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Endcase
        Next
      Next
      @ ++j, 1 To j, 78
      @ ++j, 1 Say 'ГРУППА состояния ЗДОРОВЬЯ до проведения профосмотра' Get mGRUPPA_DO Pict '9'
      @ ++j, 1 Say '        медицинская ГРУППА для занятия физкультурой' Get mGR_FIZ_DO ;
        reader {| x| menu_reader( x, mm_gr_fiz_do, A__MENUVERT, , , .f. ) }
      status_key( '^<Esc>^ выход без записи ^<PgUp>^ на 3-ю страницу ^<PgDn>^ на 5-ю страницу' )
    Elseif num_screen == 5
      @ ++j, 1 Say 'ПО РЕЗУЛЬТАТАМ ПРОВЕДЕНИЯ ПРОФОСМОРА: практически здоров' Get mdiag_16_1 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '──────┬───┬───────┬─────────────┬─────────────┬─────────────┬─────────────┬───'
      @ ++j, 1 Say ' Диаг-│Уст│Диспанс│Доп.конс.назн│Доп.конс.выпо│Лечение назна│Реаб-ия назна│ВМП'
      @ ++j, 1 Say ' ноз  │впе│набл-ие│аче┌────┬────┤лне┌────┬────┤че-┌────┬────┤че-┌────┬────┤рек'
      @ ++j, 1 Say '      │рвы│установ│ны │усл.│учр.│ны │усл.│учр.│но │усл.│учр.│на │усл.│учр.│оме'
      @ ++j, 1 Say '──────┴───┴───────┴───┴────┴────┴───┴────┴────┴───┴────┴────┴───┴────┴────┴───'
      For i := 1 To 5
        ++j
        fl := .f.
        For k := 1 To 16
          s := 'diag_16_' + lstr( i ) + '_' + lstr( k )
          mvar := 'm' + s
          If k == 1
            fl := !Empty( &mvar )
          Else
            m1var := 'm1' + s
            If fl
              If k == 3
                mm_m := mm_dispans
              Elseif eq_any( k, 5, 8, 11, 14 )
                mm_m := mm_usl
              Elseif eq_any( k, 6, 9, 12, 15 )
                mm_m := mm_uch1
              Else
                mm_m := mm_danet
              Endif
              &mvar := inieditspr( A__MENUVERT, mm_m, &m1var )
            Else
              &m1var := 0
              &mvar := Space( 4 )
            Endif
          Endif
          Do Case
          Case k == 1
            @ j, 1 get &mvar Picture pic_diag ;
              reader {| o| mygetreader( o, bg ) } Valid val1_10diag( .t., .f., .f., mn_data, mpol ) ;
              When m1diag_16_1 == 0
          Case k == 2
            @ j, 8 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 3
            @ j, 12 get &mvar ;
              reader {| x| menu_reader( x, mm_dispans, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 4
            @ j, 20 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 5
            @ j, 24 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 6
            @ j, 29 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 7
            @ j, 34 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 8
            @ j, 38 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 9
            @ j, 43 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 10
            @ j, 48 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 11
            @ j, 52 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 12
            @ j, 57 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 13
            @ j, 62 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 14
            @ j, 66 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 15
            @ j, 71 get &mvar ;
              reader {| x| menu_reader( x, mm_uch1, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 16
            @ j, 76 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Endcase
        Next
      Next
      @ ++j, 1 To j, 78
      If m1step2 == 2  // направлен и отказался от 2-го этапа
        @ ++j, 1 Say 'Признак подозрения на злокачественное новообразование' Get mDS_ONK ;
          reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
        @ ++j, 1 Say 'Направления при подозрении на ЗНО' Get mnapr_onk ;
          reader {| x| menu_reader( x, { {| k, r, c| fget_napr_zno( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
          When m1ds_onk == 1
      Endif
      dispans_napr( mk_data, @j, .f. )  // вызов заполнения блока направлений

      @ ++j, 1 To j, 78
      @ ++j, 1 Say 'Инвалидность' Get minvalid1 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ j, 30 Say 'если "да":' Get minvalid2 ;
        reader {| x| menu_reader( x, mm_invalid2(), A__MENUVERT, , , .f. ) } ;
        When m1invalid1 == 1
      @ ++j, 2 Say 'установлена впервые' Get minvalid3 ;
        When m1invalid1 == 1
      @ j, Col() + 1 Say 'дата последнего освидетельствования' Get minvalid4 ;
        When m1invalid1 == 1
      @ ++j, 2 Say 'Заболевания/инвалидность' Get minvalid5 ;
        reader {| x| menu_reader( x, mm_invalid5(), A__MENUVERT, , , .f. ) } ;
        When m1invalid1 == 1
      @ ++j, 2 Say 'Виды нарушений в состоянии здоровья' Get minvalid6 ;
        reader {| x| menu_reader( x, mm_invalid6(), A__MENUVERT, , , .f. ) } ;
        When m1invalid1 == 1
      @ ++j, 2 Say 'Дата назначения индивидуальной программы реабилитации' Get minvalid7 ;
        When m1invalid1 == 1
      @ j, Col() Say ' выполнение' Get minvalid8 ;
        reader {| x| menu_reader( x, mm_invalid8(), A__MENUVERT, , , .f. ) } ;
        When m1invalid1 == 1
      @ ++j, 1 Say 'Прививки' Get mprivivki1 ;
        reader {| x| menu_reader( x, mm_privivki1(), A__MENUVERT, , , .f. ) }
      @ j, 50 Say 'Не привит' Get mprivivki2 ;
        reader {| x| menu_reader( x, mm_privivki2(), A__MENUVERT, , , .f. ) } ;
        When m1privivki1 > 0
      @ ++j, 2 Say 'Нуждается в вакцинации' Get mprivivki3 Pict '@S54' ;
        When m1privivki1 > 0
      @ ++j, 1 Say 'Рекомендации здорового образа жизни' Get mrek_form Pict '@S52'
      @ ++j, 1 Say 'Рекомендации по диспансерному наблюдению' Get mrek_disp Pict '@S47'
      @ ++j, 1 Say 'ГРУППА состояния ЗДОРОВЬЯ по результатам проведения профосмотра' Get mGRUPPA Pict '9'
      @ ++j, 1 Say '                    медицинская ГРУППА для занятия физкультурой' Get mGR_FIZ ;
        reader {| x| menu_reader( x, mm_gr_fiz, A__MENUVERT, , , .f. ) }
      status_key( '^<Esc>^ выход без записи;  ^<PgUp>^ вернуться на 4-ю страницу;  ^<PgDn>^ ЗАПИСЬ' )
    Endif
    DispEnd()
    count_edit += myread()
    If num_screen == 5
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
      If mvozrast >= 18
        func_error( 4, 'Профосмотр оказан взрослому пациенту!' )
        Loop
      Endif
      If !Between( mperiod, 1, 31 )
        func_error( 4, 'Не удалось определить возрастной период!' )
        num_screen := 1
        Loop
      Endif
      If Empty( mk_data )
        func_error( 4, 'Не введена дата окончания лечения.' )
        Loop
      Elseif Year( mk_data ) < 2018
        func_error( 4, 'Профосмотры по новому Приказу Минздрава РФ вводятся с 2018 года' )
        Loop
      Endif
      If Empty( CharRepl( '0', much_doc, Space( 10 ) ) )
        func_error( 4, 'Не заполнен номер амбулаторной карты' )
        Loop
      Endif
      If Empty( mmo_pr )
        func_error( 4, 'Не введено МО, к которому прикреплён несовершеннолетний.' )
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
      If mdvozrast < 5 .and. Empty( mPER_HEAD )
        func_error( 4, 'Не введена окружность головы.' )
        Loop
      Endif
      If m1FIZ_RAZV == 1 .and. emptyall( m1fiz_razv1, m1fiz_razv2 )
        func_error( 4, 'Не введены отклонения массы тела или роста.' )
        Loop
      Endif
      If ! checktabnumberdoctor( mk_data, .f. )
        Loop
      Endif
      If mvozrast < 1
        mdef_diagnoz := 'Z00.1 '
      Elseif mvozrast < 14
        mdef_diagnoz := 'Z00.2 '
      Else
        mdef_diagnoz := 'Z00.3 '
      Endif
//      arr_iss := Array( count_pn_arr_iss, 10 )
      arr_iss := Array( count_pn_arr_iss( mk_data ), 10 )
      afillall( arr_iss, 0 )
      r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'MKB_10' )
      r_use( dir_DB + 'mo_pers', dir_DB + 'mo_pers', 'P2' )
      num_screen := 2
      max_date1 := max_date2 := mn_data
      d12 := mn_data -1
      k := 0
      If metap == 2
        Do While++d12 <= mk_data
          If is_work_day( d12 )
            If++k == 20
              Exit
            Endif
          Endif
        Enddo
      Endif
      fl := .t.
      is_otkaz := .f.
      is_neonat := .f.
      ar := np_arr_1_etap( mk_data )[ mperiod ]
//      For i := 1 To count_pn_arr_iss
      For i := 1 To count_pn_arr_iss( mk_data )
        mvart := 'MTAB_NOMiv' + lstr( i )
        mvara := 'MTAB_NOMia' + lstr( i )
        mvard := 'MDATEi' + lstr( i )
        mvarr := 'MREZi' + lstr( i )
        _fl_ := not_audio_s := .t.
//        If _fl_ .and. !Empty( np_arr_issled[ i, 2 ] )
//          _fl_ := ( mpol == np_arr_issled[ i, 2 ] )
        If _fl_ .and. !Empty( arr_PN_issled[ i, 2 ] )
          _fl_ := ( mpol == arr_PN_issled[ i, 2 ] )
        Endif
        If _fl_
//          _fl_ := ( AScan( ar[ 5 ], np_arr_issled[ i, 1 ] ) > 0 )
          _fl_ := ( AScan( ar[ 5 ], arr_PN_issled[ i, 1 ] ) > 0 )
        Endif
//        If np_arr_issled[ i, 1 ] == '3.5.4' .and. is_3_5_4 // Аудио-скрининг уже был
        If arr_PN_issled[ i, 1 ] == '3.5.4' .and. is_3_5_4 // Аудио-скрининг уже был
          not_audio_s := .f.
        Endif
        If _fl_ .and. not_audio_s /*.and. arr_PN_issled[i, 4] == 0 // не гормон*/
          m1var := 'm1lis' + lstr( i )
          If !is_disp_19 .and. glob_yes_kdp2()[ TIP_LU_PN ] .and. &m1var > 0
            &mvart := -1
          Endif
          If Empty( &mvard )
//            fl := func_error( 4, 'Не введена дата иссл-ия "' + np_arr_issled[ i, 3 ] + '"' )
            fl := func_error( 4, 'Не введена дата иссл-ия "' + arr_PN_issled[ i, 3 ] + '"' )
          Elseif metap == 2 .and. &mvard > d12
//            fl := func_error( 4, 'Дата иссл-ия "' + np_arr_issled[ i, 3 ] + '" не в I-ом этапе (> 20 дней)' )
            fl := func_error( 4, 'Дата иссл-ия "' + arr_PN_issled[ i, 3 ] + '" не в I-ом этапе (> 20 дней)' )
          Elseif Empty( &mvart )
//            fl := func_error( 4, 'Не введен врач в иссл-ии "' + np_arr_issled[ i, 3 ] + '"' )
            fl := func_error( 4, 'Не введен врач в иссл-ии "' + arr_PN_issled[ i, 3 ] + '"' )
          Endif
        Endif
        If _fl_ .and. !emptyany( &mvard, &mvart )
          if &mvart > 0
            Select P2
            find ( Str( &mvart, 5 ) )
            If Found()
              arr_iss[ i, 1 ] := p2->kod
              arr_iss[ i, 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
            Endif
            If !Empty( &mvara )
              Select P2
              find ( Str( &mvara, 5 ) )
              If Found()
                arr_iss[ i, 3 ] := p2->kod
              Endif
            Endif
          Else
//            arr_iss[ i, 2 ] := -ret_new_spec( np_arr_issled[ i, 6, 1 ] )
            arr_iss[ i, 2 ] := -ret_new_spec( arr_PN_issled[ i, 6, 1 ] )
            arr_iss[ i, 10 ] := &m1var // кровь проверяют в КДП2 или в РДЛ
          Endif
/*          If ValType( np_arr_issled[ i, 5 ] ) == 'N'
            arr_iss[ i, 4 ] := np_arr_issled[ i, 5 ] // профиль
          Elseif ( j := AScan( np_arr_issled[ i, 6 ], ret_old_prvs( arr_iss[ i, 2 ] ) ) ) > 0
            arr_iss[ i, 4 ] := np_arr_issled[ i, 5, j ] // профиль
          Endif
          arr_iss[ i, 5 ] := np_arr_issled[ i, 1 ] // шифр услуги
*/
          If ValType( arr_PN_issled[ i, 5 ] ) == 'N'
            arr_iss[ i, 4 ] := arr_PN_issled[ i, 5 ] // профиль
          Elseif ( j := AScan( arr_PN_issled[ i, 6 ], ret_old_prvs( arr_iss[ i, 2 ] ) ) ) > 0
            arr_iss[ i, 4 ] := arr_PN_issled[ i, 5, j ] // профиль
          Endif
          arr_iss[ i, 5 ] := arr_PN_issled[ i, 1 ] // шифр услуги
          arr_iss[ i, 6 ] := mdef_diagnoz
          arr_iss[ i, 9 ] := &mvard
          //
          m1var := 'M1OTKAZi' + lstr( i )
          if &m1var == 1 .and. !Between( arr_iss[ i, 9 ], mn_data, mk_data ) // если отказ и не в диапазоне
            &m1var := 0
          Endif
          if &m1var == 1
            arr_iss[ i, 10 ] := 9 // отказ от услуги
            is_otkaz := .t.
          Elseif Left( arr_iss[ i, 5 ], 5 ) == '4.26.'
            is_neonat := .t.
          Endif
          max_date1 := Max( max_date1, arr_iss[ i, 9 ] )
        Endif
        If !fl
          Exit
        Endif
      Next
      If !fl
        Loop
      Endif
      fl := .t.
//      arr_osm1 := Array( count_pn_arr_osm, 10 )
      arr_osm1 := Array( Len( arr_PN_osmotr ), 10 )
      afillall( arr_osm1, 0 )
      For i := 1 To Len( arr_PN_osmotr )  // count_pn_arr_osm
        _fl_ := .t.
//        If _fl_ .and. !Empty( np_arr_osmotr[ i, 2 ] )
//          _fl_ := ( mpol == np_arr_osmotr[ i, 2 ] )
        If _fl_ .and. !Empty( arr_PN_osmotr[ i, 2 ] )
          _fl_ := ( mpol == arr_PN_osmotr[ i, 2 ] )
        Endif
/*
        If _fl_
          _fl_ := ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) > 0 )
        Endif
        If _fl_ .and. mperiod == 16 .and. mk_data < 0d20191101 .and. np_arr_osmotr[ i, 1 ] == '2.4.2' // 2 года
          _fl_ := .f.
        Endif
        If _fl_ .and. mperiod == 20 .and. mk_data < 0d20191101 .and. np_arr_osmotr[ i, 1 ] == '2.85.24' // 6 лет
          _fl_ := .f.
        Endif
*/
        If _fl_
          _fl_ := ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], arr_PN_osmotr[ i, 1 ] ) > 0 )
        Endif
        If _fl_ .and. mperiod == 16 .and. mk_data < 0d20191101 .and. arr_PN_osmotr[ i, 1 ] == '2.4.2' // 2 года
          _fl_ := .f.
        Endif
        If _fl_ .and. mperiod == 20 .and. mk_data < 0d20191101 .and. arr_PN_osmotr[ i, 1 ] == '2.85.24' // 6 лет
          _fl_ := .f.
        Endif

        If _fl_
          mvart := 'MTAB_NOMov' + lstr( i )
          mvara := 'MTAB_NOMoa' + lstr( i )
          mvard := 'MDATEo' + lstr( i )
          mvarz := 'MKOD_DIAGo' + lstr( i )
          If Empty( &mvard )
//            fl := func_error( 4, 'Не введена дата осмотра I этапа "' + np_arr_osmotr[ i, 3 ] + '"' )
            fl := func_error( 4, 'Не введена дата осмотра I этапа "' + arr_PN_osmotr[ i, 3 ] + '"' )
          Elseif metap == 2 .and. &mvard > d12
//            fl := func_error( 4, 'Дата осмотра "' + np_arr_osmotr[ i, 3 ] + '" не в I-ом этапе (> 20 дней)' )
            fl := func_error( 4, 'Дата осмотра "' + arr_PN_osmotr[ i, 3 ] + '" не в I-ом этапе (> 20 дней)' )
          Elseif Empty( &mvart )
//            fl := func_error( 4, 'Не введен врач в осмотре I этапа "' + np_arr_osmotr[ i, 3 ] + '"' )
            fl := func_error( 4, 'Не введен врач в осмотре I этапа "' + arr_PN_osmotr[ i, 3 ] + '"' )
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
/*
            If ValType( np_arr_osmotr[ i, 4 ] ) == 'N'
              arr_osm1[ i, 4 ] := np_arr_osmotr[ i, 4 ] // профиль
            Elseif ( j := AScan( np_arr_osmotr[ i, 5 ], ret_old_prvs( arr_osm1[ i, 2 ] ) ) ) > 0
              arr_osm1[ i, 4 ] := np_arr_osmotr[ i, 4, j ] // профиль
            Endif
            arr_osm1[ i, 5 ] := np_arr_osmotr[ i, 1 ] // шифр услуги
*/
            If ValType( arr_PN_osmotr[ i, 4 ] ) == 'N'
              arr_osm1[ i, 4 ] := arr_PN_osmotr[ i, 4 ] // профиль
            Elseif ( j := AScan( arr_PN_osmotr[ i, 5 ], ret_old_prvs( arr_osm1[ i, 2 ] ) ) ) > 0
              arr_osm1[ i, 4 ] := arr_PN_osmotr[ i, 4, j ] // профиль
            Endif
            arr_osm1[ i, 5 ] := arr_PN_osmotr[ i, 1 ] // шифр услуги

            If Empty( &mvarz ) .or. Left( &mvarz, 1 ) == 'Z'
              arr_osm1[ i, 6 ] := mdef_diagnoz
            Else
              arr_osm1[ i, 6 ] := &mvarz
              Select MKB_10
              find ( PadR( arr_osm1[ i, 6 ], 6 ) )
              If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
                fl := func_error( 4, 'Несовместимость диагноза по полу ' + arr_osm1[ i, 6 ] )
              Endif
            Endif
            arr_osm1[ i, 9 ] := &mvard
            m1var := 'M1OTKAZo' + lstr( i )
            if &m1var == 1 .and. !Between( arr_osm1[ i, 9 ], mn_data, mk_data ) // если отказ и не в диапазоне
              &m1var := 0
            Endif
            if &m1var == 1
              arr_osm1[ i, 10 ] := 9 // отказ от осмотра
              is_otkaz := .t.
            Endif
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
      If emptyany( MTAB_NOMpv1, MDATEp1 )
        fl := func_error( 4, 'Не введён педиатр (врач общей практики) в осмотрах I этапа' )
      Elseif MDATEp1 < max_date1
        fl := func_error( 4, 'Педиатр (врач общей практики) на I этапе должен проводить осмотр последним!' )
      Elseif metap == 2 .and. MDATEp1 > d12
        fl := func_error( 4, 'Дата осмотра педиатра I этапа не умещается в 20 рабочих дней' )
      Endif
      If !fl
        Loop
      Endif
      m1p_otk := 0
      metap := 1
//      arr_osm2 := Array( count_pn_arr_osm, 10 )
      arr_osm2 := Array( Len( arr_PN_osmotr ), 10 )
      afillall( arr_osm2, 0 )
      If m1step2 == 2 // направлен на 2-ой этап, но отказался
        m1p_otk := 1   // признак отказа
      Elseif m1step2 == 1 // направлен на 2-ой этап
        num_screen := 3
        fl := .t.
        If !emptyany( MTAB_NOMpv2, MDATEp2 )
          metap := 2
        Endif
        ku := 0
        For i := 1 To Len( arr_PN_osmotr )  // count_pn_arr_osm
          _fl_ := .t.
//          If _fl_ .and. !Empty( np_arr_osmotr[ i, 2 ] )
//            _fl_ := ( mpol == np_arr_osmotr[ i, 2 ] )
          If _fl_ .and. !Empty( arr_PN_osmotr[ i, 2 ] )
            _fl_ := ( mpol == arr_PN_osmotr[ i, 2 ] )
          Endif
          If _fl_
//            _fl_ := ( AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) == 0 )
            _fl_ := ( AScan( ar[ 4 ], arr_PN_osmotr[ i, 1 ] ) == 0 )
          Endif
          If _fl_
            mvonk := 'm1onko' + lstr( i )
            mvart := 'MTAB_NOMov' + lstr( i )
            mvara := 'MTAB_NOMoa' + lstr( i )
            mvard := 'MDATEo' + lstr( i )
            mvarz := 'MKOD_DIAGo' + lstr( i )
            If eq_any( i, 8, 10 ) .and. &mvonk == 3
              &mvart := -1
            Endif
            If !Empty( &mvard ) .and. Empty( &mvart )
//              fl := func_error( 4, 'Не введен врач в осмотре II этапа "' + np_arr_osmotr[ i, 3 ] + '"' )
              fl := func_error( 4, 'Не введен врач в осмотре II этапа "' + arr_PN_osmotr[ i, 3 ] + '"' )
            Elseif !Empty( &mvart ) .and. Empty( &mvard )
//              fl := func_error( 4, 'Не введена дата осмотра II этапа "' + np_arr_osmotr[ i, 3 ] + '"' )
              fl := func_error( 4, 'Не введена дата осмотра II этапа "' + arr_PN_osmotr[ i, 3 ] + '"' )
            Elseif !emptyany( &mvard, &mvart )
              ++ku
              metap := 2
              if &mvard < MDATEp1
//                fl := func_error( 4, 'Дата осмотра II этапа "' + np_arr_osmotr[ i, 3 ] + '" внутри I этапа' )
                fl := func_error( 4, 'Дата осмотра II этапа "' + arr_PN_osmotr[ i, 3 ] + '" внутри I этапа' )
              Endif
              if &mvart > 0
                Select P2
                find ( Str( &mvart, 5 ) )
                If Found()
                  arr_osm2[ i, 1 ] := p2->kod
                  arr_osm2[ i, 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
                Endif
                If !Empty( &mvara )
                  Select P2
                  find ( Str( &mvara, 5 ) )
                  If Found()
                    arr_osm2[ i, 3 ] := p2->kod
                  Endif
                Endif
              Else // приём в онкодиспансере
//                arr_osm2[ i, 2 ] := -ret_new_spec( np_arr_osmotr[ i, 5, 1 ] )
                arr_osm2[ i, 2 ] := -ret_new_spec( arr_PN_osmotr[ i, 5, 1 ] )
                arr_osm2[ i, 10 ] := 3
              Endif
/*
              If ValType( np_arr_osmotr[ i, 4 ] ) == 'N'
                arr_osm2[ i, 4 ] := np_arr_osmotr[ i, 4 ] // профиль
              Elseif ( j := AScan( np_arr_osmotr[ i, 5 ], ret_old_prvs( arr_osm2[ i, 2 ] ) ) ) > 0
                arr_osm2[ i, 4 ] := np_arr_osmotr[ i, 4, j ] // профиль
              Endif
              arr_osm2[ i, 5 ] := np_arr_osmotr[ i, 1 ] // шифр услуги
*/
              If ValType( arr_PN_osmotr[ i, 4 ] ) == 'N'
                arr_osm2[ i, 4 ] := arr_PN_osmotr[ i, 4 ] // профиль
              Elseif ( j := AScan( arr_PN_osmotr[ i, 5 ], ret_old_prvs( arr_osm2[ i, 2 ] ) ) ) > 0
                arr_osm2[ i, 4 ] := arr_PN_osmotr[ i, 4, j ] // профиль
              Endif
              arr_osm2[ i, 5 ] := arr_PN_osmotr[ i, 1 ] // шифр услуги

              If Empty( &mvarz ) .or. Left( &mvarz, 1 ) == 'Z'
                arr_osm2[ i, 6 ] := mdef_diagnoz
              Else
                arr_osm2[ i, 6 ] := &mvarz
                Select MKB_10
                find ( PadR( arr_osm2[ i, 6 ], 6 ) )
                If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
                  fl := func_error( 4, 'Несовместимость диагноза по полу ' + arr_osm2[ i, 6 ] )
                Endif
              Endif
              m1var := 'M1OTKAZo' + lstr( i )
              if &m1var == 1
                arr_osm2[ i, 10 ] := 9 // отказ от осмотра
              Endif
              arr_osm2[ i, 9 ] := &mvard
              max_date2 := Max( max_date2, arr_osm2[ i, 9 ] )
            Endif
          Endif
          If !fl
            Exit
          Endif
        Next
        If fl .and. metap == 2
          If emptyany( MTAB_NOMpv2, MDATEp2 )
            fl := func_error( 4, 'Не введён педиатр (врач общей практики) в осмотрах II этапа' )
          Elseif MDATEp1 == MDATEp2
            fl := func_error( 4, 'Педиатры на I и II этапах провели осмотры в один день!' )
          Elseif MDATEp2 < max_date2
            fl := func_error( 4, 'Педиатр (врач общей практики) на II этапе должен проводить осмотр последним!' )
          Elseif Empty( ku )
            fl := func_error( 4, 'На II этапе кроме осмотра педиатра должен быть ещё какой-нибудь осмотр.' )
          Endif
        Endif
        If !fl
          Loop
        Endif
      Endif
      num_screen := 4
      If !Between( mGRUPPA_DO, 1, 5 )
        func_error( 4, 'ГРУППА состояния ЗДОРОВЬЯ ДО проведения профосмотра д.б. от 1 до 5' )
        Loop
      Endif
      num_screen := 5
      arr_diag := {}
      For i := 1 To 5
        mvar := 'mdiag_16_' + lstr( i ) + '_1'
        If !Empty( &mvar )
          If Left( &mvar, 1 ) == 'Z'
            fl := func_error( 4, 'Диагноз ' + RTrim( &mvar ) + '(первый символ "Z") не вводится. Это не заболевание!' )
            Exit
          Endif
          pole_1pervich := 'm1diag_16_' + lstr( i ) + '_2' // 0, 1
          pole_1dispans := 'm1diag_16_' + lstr( i ) + '_3' // mm_dispans := {{'ранее', 1}, {'впервые', 2}, {'не уст.', 0}}
          AAdd( arr_diag, { &mvar, &pole_1pervich, &pole_1dispans } )
        Endif
      Next
      If !fl
        Loop
      Endif
      AFill( adiag_talon, 0 )
      If Empty( arr_diag ) // диагнозы не вводили
        AAdd( arr_diag, { 1, mdef_diagnoz, 0, 0 } ) // диагноз по умолчанию
        MKOD_DIAG := mdef_diagnoz
      Else
        For i := 1 To Len( arr_diag )
          If arr_diag[ i, 2 ] == 0 // 'ранее выявлено'
            arr_diag[ i, 2 ] := 2  // заменяем, как в листе учёта ОМС
          Endif
        Next
        For i := 1 To Len( arr_diag )
          adiag_talon[ i * 2 -1 ] := arr_diag[ i, 2 ]
          adiag_talon[ i * 2 ] := arr_diag[ i, 3 ]
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
      If m1invalid1 == 1 .and. !Empty( minvalid3 ) .and. minvalid3 < mdate_r
        func_error( 4, 'Дата установления инвалидности меньше даты рождения' )
        Loop
      Endif
      If Between( mGRUPPA, 1, 5 )
        m1rslt := L_BEGIN_RSLT + mGRUPPA
      Else
        func_error( 4, 'ГРУППА состояния ЗДОРОВЬЯ по результатам проведения профосмотра - от 1 до 5' )
        Loop
      Endif
      //
      err_date_diap( mn_data, 'Дата начала лечения' )
      err_date_diap( mk_data, 'Дата окончания лечения' )
      //
      RestScreen( buf )
      message_save_LU()
      mywait( 'Ждите. Производится запись листа учёта...' )
      m1lis := 0
      arr_lis2 := {}
      arr_usl_dop := {}
      arr_usl_otkaz := {}
      If !is_disp_19 .and. glob_yes_kdp2()[ TIP_LU_PN ]
//        For i := 1 To count_pn_arr_iss
        For i := 1 To count_pn_arr_iss( mk_data )
          If ValType( arr_iss[ i, 9 ] ) == 'D' .and. arr_iss[ i, 9 ] >= mn_data .and. Len( arr_iss[ i ] ) > 9 ;
              .and. ValType( arr_iss[ i, 10 ] ) == 'N' .and. eq_any( arr_iss[ i, 10 ], 1, 2 )
            m1lis := arr_iss[ i, 10 ] // в рамках диспансеризации
          Endif
        Next
      Endif
      // добавим педиатра I этапа
      AAdd( arr_osm1, add_pediatr_pn( MTAB_NOMpv1, MTAB_NOMpa1, MDATEp1, MKOD_DIAGp1 ) )
      If metap == 1 // I этап
        For i := 1 To Len( arr_iss )
          If ValType( arr_iss[ i, 5 ] ) == 'C'
            If arr_iss[ i, 10 ] == 9 // отказ
              arr_iss[ i, 10 ] := 'i'
              AAdd( arr_usl_otkaz, arr_iss[ i ] )
            Else
              AAdd( arr_usl_dop, arr_iss[ i ] )
              If is_otkaz .and. ; // в случае были отказы
                arr_iss[ i, 10 ] == 0 .and. ; // услуга не в КДП2
                Between( arr_iss[ i, 9 ], mn_data, mk_data ) .and. ; // умещается в период
                ( j := AScan( arr_not_zs, {| x| x[ 1 ] == arr_iss[ i, 5 ] } ) ) > 0
//                ( j := AScan( np_arr_not_zs, {| x| x[ 1 ] == arr_iss[ i, 5 ] } ) ) > 0
                arr := AClone( arr_iss[ i ] )  // добавим
//                arr[ 5 ] := np_arr_not_zs[ j, 2 ] // шифр исследования
                arr[ 5 ] := arr_not_zs[ j, 2 ] // шифр исследования
                AAdd( arr_usl_dop, arr )          // с ценой
              Endif
            Endif
          Endif
        Next
        For i := 1 To Len( arr_osm1 )
          If ValType( arr_osm1[ i, 5 ] ) == 'C'
            If arr_osm1[ i, 10 ] == 9 // отказ
              arr_osm1[ i, 10 ] := 'o'
              AAdd( arr_usl_otkaz, arr_osm1[ i ] )
            Else
              lshifr := AllTrim( arr_osm1[ i, 5 ] )
//              If ( j := AScan( np_arr_osmotr_KDP2, {| x| x[ 1 ] == lshifr } ) ) > 0
//                arr_osm1[ i, 5 ] := np_arr_osmotr_KDP2[ j, 3 ]  // замена на 2.3.*
              If ( j := AScan( arr_osmotr_KDP2, {| x| x[ 1 ] == lshifr } ) ) > 0
                arr_osm1[ i, 5 ] := arr_osmotr_KDP2[ j, 3 ]  // замена на 2.3.*
              Endif
              AAdd( arr_usl_dop, arr_osm1[ i ] )
              If is_otkaz .and. ;// в случае были отказы
                Between( arr_osm1[ i, 9 ], mn_data, mk_data ) ; // и умещается в период
                .and. j > 0  // и найдено соответствие
                arr := AClone( arr_osm1[ i ] )       // добавим
//                arr[ 5 ] := np_arr_osmotr_KDP2[ j, 4 ]  // замена на 2.91.*
                arr[ 5 ] := arr_osmotr_KDP2[ j, 4 ]  // замена на 2.91.*
                AAdd( arr_usl_dop, arr )             // с ценой
              Endif
            Endif
          Endif
        Next
        i := Len( arr_osm1 )
        m1vrach  := arr_osm1[ i, 1 ]
        m1prvs   := arr_osm1[ i, 2 ]
        m1assis  := arr_osm1[ i, 3 ]
        m1PROFIL := arr_osm1[ i, 4 ]
        // MKOD_DIAG := padr(arr_osm1[i, 6], 6)
        If !is_otkaz // добавляем код ЗС
          AAdd( arr_usl_dop, Array( 10 ) )
          j := Len( arr_usl_dop )
          arr_usl_dop[ j, 1 ] := m1vrach
          arr_usl_dop[ j, 2 ] := m1prvs
          arr_usl_dop[ j, 3 ] := m1assis
          arr_usl_dop[ j, 4 ] := 151 // для кода ЗС - мед.осмотрам профилактическим
          arr_usl_dop[ j, 5 ] := ret_shifr_zs_pn( mperiod, mk_data )
          arr_usl_dop[ j, 6 ] := MKOD_DIAG
          arr_usl_dop[ j, 9 ] := mn_data
        Endif
      Else  // оформление 2-го этапа по-новому
        Use ( cur_dir() + 'tmp' ) new
        Go Top
        Do While !Eof()
          If is_lab_usluga( tmp->u_shifr )
            AAdd( arr_lis2, { tmp->u_kod, tmp->u_shifr } )
          Endif
          Skip
        Enddo
        Use
        For i := 1 To Len( arr_iss )
          If ValType( arr_iss[ i, 5 ] ) == 'C'
            If arr_iss[ i, 10 ] == 9 // отказ
              arr_iss[ i, 10 ] := 'i'
              AAdd( arr_usl_otkaz, arr_iss[ i ] )
            Else
              AAdd( arr_usl_dop, arr_iss[ i ] )
              If arr_iss[ i, 10 ] == 0 ; // кровь проверяют у нас в МО
                .and. Between( arr_iss[ i, 9 ], mn_data, mk_data ) .and. ; // и в сроки профосмотра
                ( j := AScan( arr_not_zs, {| x| x[ 1 ] == arr_iss[ i, 5 ] } ) ) > 0
//                ( j := AScan( np_arr_not_zs, {| x| x[ 1 ] == arr_iss[ i, 5 ] } ) ) > 0
                arr := AClone( arr_iss[ i ] )  // добавим
//                arr[ 5 ] := np_arr_not_zs[ j, 2 ] // шифр исследования
                arr[ 5 ] := arr_not_zs[ j, 2 ] // шифр исследования
                AAdd( arr_usl_dop, arr )          // с ценой
              Endif
            Endif
          Endif
        Next
        For i := 1 To Len( arr_osm1 )
          If ValType( arr_osm1[ i, 5 ] ) == 'C'
            lshifr := AllTrim( arr_osm1[ i, 5 ] )
            If arr_osm1[ i, 10 ] == 9 // отказ от осмотра
              arr_osm1[ i, 10 ] := 'o'
              AAdd( arr_usl_otkaz, arr_osm1[ i ] )
            Else
              lshifr := AllTrim( arr_osm1[ i, 5 ] )
//              If ( j := AScan( np_arr_osmotr_KDP2, {| x| x[ 1 ] == lshifr } ) ) > 0
//                arr_osm1[ i, 5 ] := np_arr_osmotr_KDP2[ j, 3 ]  // замена на 2.3.*
//              Endif
              If ( j := AScan( arr_osmotr_KDP2, {| x| x[ 1 ] == lshifr } ) ) > 0
                arr_osm1[ i, 5 ] := arr_osmotr_KDP2[ j, 3 ]  // замена на 2.3.*
              Endif
              AAdd( arr_usl_dop, arr_osm1[ i ] )
              If Between( arr_osm1[ i, 9 ], mn_data, mk_data ) ; // и умещается в период
                .and. j > 0  // и найдено соответствие
                arr := AClone( arr_osm1[ i ] )       // добавим
//                arr[ 5 ] := np_arr_osmotr_KDP2[ j, 4 ]  // замена на 2.91.*
                arr[ 5 ] := arr_osmotr_KDP2[ j, 4 ]  // замена на 2.91.*
                AAdd( arr_usl_dop, arr )             // с ценой
              Endif
            Endif
          Endif
        Next
        // добавим педиатра II этапа
        AAdd( arr_osm2, add_pediatr_pn( MTAB_NOMpv2, MTAB_NOMpa2, MDATEp2, MKOD_DIAGp2 ) )
        i := Len( arr_osm2 )
        m1vrach  := arr_osm2[ i, 1 ]
        m1prvs   := arr_osm2[ i, 2 ]
        m1assis  := arr_osm2[ i, 3 ]
        m1PROFIL := arr_osm2[ i, 4 ]
        // MKOD_DIAG := padr(arr_osm2[i, 6], 6)
        For i := 1 To Len( arr_osm2 )
          If ValType( arr_osm2[ i, 5 ] ) == 'C'
            lshifr := AllTrim( arr_osm2[ i, 5 ] )
            If arr_osm2[ i, 10 ] == 9 // отказ от осмотра
              arr_osm2[ i, 10 ] := 'o'
              AAdd( arr_usl_otkaz, arr_osm2[ i ] )
            Else
              If arr_osm2[ i, 10 ] == 3 // если услуга оказана в ВОКОД
                arr_osm2[ i, 5 ] := '2.3.1'
              Endif
//              If !Empty( arr_lis2 ) .and. ( j := AScan( np_arr_osmotr_KDP2, {| x| x[ 1 ] == lshifr } ) ) > 0
//                arr_osm2[ i, 5 ] := np_arr_osmotr_KDP2[ j, 2 ] // услуги заменим на аналогичные шифры без гематологии
//              Endif
              If !Empty( arr_lis2 ) .and. ( j := AScan( arr_osmotr_KDP2, {| x| x[ 1 ] == lshifr } ) ) > 0
                arr_osm2[ i, 5 ] := arr_osmotr_KDP2[ j, 2 ] // услуги заменим на аналогичные шифры без гематологии
              Endif
              AAdd( arr_usl_dop, arr_osm2[ i ] )
            Endif
          Endif
        Next
        If !Empty( arr_lis2 ) // на 2-ом этапе были направления на анализы в КДП2
          If ( mdate := max_date1 + 1 ) > max_date2 // следующий день после педиатра 1-го этапа
            mdate := max_date2 // если этого много, то окончание 2-го этапа
          Endif
          For j := 1 To Len( arr_lis2 )
            AAdd( arr_usl_dop, Array( 10 ) )
            i := Len( arr_usl_dop )
            AFill( arr_usl_dop[ i ], 0 )
            arr_usl_dop[ i, 4 ] := iif( Left( arr_lis2[ j, 2 ], 5 ) == '4.16.', 6, 34 ) // профиль
            arr_usl_dop[ i, 5 ] := arr_lis2[ j, 2 ] // шифр услуги
            arr_usl_dop[ i, 6 ] := mkod_diag
            arr_usl_dop[ i, 7 ] := arr_lis2[ j, 1 ] // код услуги
            arr_usl_dop[ i, 9 ] := mdate
            arr_usl_dop[ i, 10 ] := -1 // т.е. материал отправлен на анализ в КДП2
          Next
        Endif
      Endif
      make_diagp( 2 )  // сделать 'пятизначные' диагнозы
      //
      use_base( 'lusl' )
      use_base( 'luslc' )
      use_base( 'uslugi' )
      r_use( dir_DB + 'uslugi1', { dir_DB + 'uslugi1', ;
        dir_DB + 'uslugi1s' }, 'USL1' )
      Private mu_cena
      mcena_1 := 0
      glob_podr := ''
      glob_otd_dep := 0
      For i := 1 To Len( arr_usl_dop )
        If Empty( arr_usl_dop[ i, 7 ] ) // т.к. для услуг, направляемых в КДП2, код уже известен (а цена =0)
          arr_usl_dop[ i, 7 ] := foundourusluga( arr_usl_dop[ i, 5 ], mk_data, arr_usl_dop[ i, 4 ], M1VZROS_REB, @mu_cena )
          arr_usl_dop[ i, 8 ] := mu_cena
          mcena_1 += mu_cena
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
      st_K_DATA := MK_DATA
      st_mo_pr := m1mo_pr
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
      human->RAB_NERAB  := M1RAB_NERAB   // 0-работающий, 1-неработающий
      human->KOD_DIAG   := MKOD_DIAG     // шифр 1-ой осн.болезни
      human->KOD_DIAG2  := MKOD_DIAG2    // шифр 2-ой осн.болезни
      human->KOD_DIAG3  := MKOD_DIAG3    // шифр 3-ой осн.болезни
      human->KOD_DIAG4  := MKOD_DIAG4    // шифр 4-ой осн.болезни
      human->SOPUT_B1   := MSOPUT_B1     // шифр 1-ой сопутствующей болезни
      human->SOPUT_B2   := MSOPUT_B2     // шифр 2-ой сопутствующей болезни
      human->SOPUT_B3   := MSOPUT_B3     // шифр 3-ой сопутствующей болезни
      human->SOPUT_B4   := MSOPUT_B4     // шифр 4-ой сопутствующей болезни
      human->diag_plus  := mdiag_plus    //
      human->ZA_SMO     := 0
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
      human->ishod      := 300 + metap
      human->OBRASHEN   := iif( m1DS_ONK == 1, '1', ' ' )
      human->bolnich    := 0
      human->date_b_1   := ''
      human->date_b_2   := ''
      human_->RODIT_DR  := CToD( '' )
      human_->RODIT_POL := ''
      s := '' ; AEval( adiag_talon, {| x| s += Str( x, 1 ) } )
      human_->DISPANS   := s
      human_->STATUS_ST := ''
      human_->POVOD     := m1povod
      human_->POVOD     := 5 // {'2.1-Медицинский осмотр', 5,'2.1'}, ;
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
      human_->IDSP      := iif( metap == 1, 17, 1 )
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
        g_use( dir_DB + 'mo_hismo', , 'SN' )
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
        hu->is_edit := iif( Len( arr_usl_dop[ i ] ) > 9 .and. ValType( arr_usl_dop[ i, 10 ] ) == 'N', arr_usl_dop[ i, 10 ], 0 )
        hu->date_u  := dtoc4( arr_usl_dop[ i, 9 ] )
        hu->otd     := m1otd
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := arr_usl_dop[ i, 8 ]
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
      save_arr_pn( mkod )
      If m1step2 == 2 ; // направлен и отказался от 2-го этапа
        .and. m1ds_onk == 1 // подозрение на злокачественное новообразование
        save_mo_onkna( mkod )
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
    If Type( 'fl_edit_DDS' ) == 'L'
      fl_edit_DDS := .t.
    Endif
    If !Empty( Val( msmo ) )
      verify_oms_sluch( glob_perso )
    Endif
  Endif
  Return Nil
