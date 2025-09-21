#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 13.09.25 ДДС - добавление или редактирование случая (листа учета)
Function oms_sluch_dds( tip_lu, Loc_kod, kod_kartotek, f_print )

  // tip_lu - TIP_LU_DDS или TIP_LU_DDSOP
  // Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  // f_print - наименование функции для печати
  Static st_N_DATA, st_K_DATA, ;
    st_stacionar := 0, st_kateg_uch := 0, st_mo_pr := '      '
  Local L_BEGIN_RSLT := iif( tip_lu == TIP_LU_DDS, 320, 346 )
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, arr_del := {}, mrec_hu := 0, ;
    buf := SaveScreen(), tmp_color := SetColor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', arr_usl := {}, ;
    i, j, k, s, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod, ;
    tmp_help := chm_help_code, fl_write_sluch := .f.
  //
  Default st_N_DATA To sys_date, st_K_DATA To sys_date
  Default Loc_kod To 0, kod_kartotek To 0, f_print To ''
  //
  If kod_kartotek == 0 // добавление в картотеку
    If ( kod_kartotek := edit_kartotek( 0,,, .t. ) ) == 0
      Return Nil
    Endif
  Endif
  chm_help_code := 3002
  Private mfio := Space( 50 ), mpol, mdate_r, madres, mvozrast, ;
    M1VZROS_REB, MVZROS_REB, m1novor := 0, ;
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-ОМС,1-компании,3-комитеты/ЛПУ,5-личный счет
    msmo := '34007', rec_inogSMO := 0, ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := Space( 100 ), ;
    mvidpolis, m1vidpolis := 1, mspolis := Space( 10 ), mnpolis := Space( 20 )
  Private mkod := Loc_kod, mtip_h, is_talon := .f., is_disp_19 := .t., ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    M1LPU := glob_uch[ 1 ], MLPU, ;
    M1OTD := glob_otd[ 1 ], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MUCH_DOC    := Space( 10 ),; // вид и номер учетного документа
    mmobilbr, m1mobilbr := 0, ;
    MKOD_DIAG   := Space( 5 ),; // шифр 1-ой осн.болезни
    MKOD_DIAG2  := Space( 5 ),; // шифр 2-ой осн.болезни
    MKOD_DIAG3  := Space( 5 ),; // шифр 3-ой осн.болезни
    MKOD_DIAG4  := Space( 5 ),; // шифр 4-ой осн.болезни
    MSOPUT_B1   := Space( 5 ),; // шифр 1-ой сопутствующей болезни
    MSOPUT_B2   := Space( 5 ),; // шифр 2-ой сопутствующей болезни
    MSOPUT_B3   := Space( 5 ),; // шифр 3-ой сопутствующей болезни
    MSOPUT_B4   := Space( 5 ),; // шифр 4-ой сопутствующей болезни
    MDIAG_PLUS  := Space( 8 ),; // дополнения к диагнозам
    adiag_talon[ 16 ],; // из статталона к диагнозам
    m1rslt  := 321,; // результат (присвоена I группа здоровья)
    m1ishod := 306,; // исход
    MN_DATA := st_N_DATA,; // дата начала лечения
    MK_DATA := st_K_DATA,; // дата окончания лечения
    MVRACH := Space( 10 ),; // фамилия и инициалы лечащего врача
    M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0, ; // код, таб.№ и спец-ть лечащего врача
    m1povod  := 4, ;   // Профилактический
    m1travma := 0, ;
    m1USL_OK :=  USL_OK_POLYCLINIC, ; // поликлиника
    m1VIDPOM :=  1, ; // первичная
    m1PROFIL := 68, ; // педиатрия
    m1IDSP   := 11   // диспансеризация
  //
//  Private mm_kateg_uch := { { 'ребенок-сирота', 0 }, ;
//    { 'ребенок, оставшийся без попечения родителей', 1 }, ;
//    { 'ребенок, находящийся в трудной жизненной ситуации', 2 }, ;
//    { 'нет категории', 3 } }
//  Private mm_gde_nahod := { { 'в стационарном учреждении', 0 }, ;
//    { 'под опекой', 1 }, ;
//    { 'под попечительством', 2 }, ;
//    { 'передан в приемную семью', 3 }, ;
//    { 'передан в патронатную семью', 4 }, ;
//    { 'усыновлен (удочерена)', 5 }, ;
//    { 'другое', 6 } }
  Private mm_gde_nahod1 := AClone( mm_gde_nahod() )
//  Private mm_prich_vyb := { { 'не выбыл', 0 }, ;
//    { 'опека', 1 }, ;
//    { 'попечительство', 2 }, ;
//    { 'усыновление (удочерение)', 3 }, ;
//    { 'передан в приемную семью', 4 }, ;
//    { 'передан в патронатную семью', 5 }, ;
//    { 'выбыл в другое стационарное учреждение', 6 }, ;
//    { 'выбыл по возрасту', 7 }, ;
//    { 'смерть', 8 }, ;
//    { 'другое', 9 } }
//  Private mm_fiz_razv := { { 'нормальное', 0 }, ;
//    { 'с отклонениями', 1 } }
//  Private mm_fiz_razv1 := { { 'нет    ', 0 }, ;
//    { 'дефицит', 1 }, ;
//    { 'избыток', 2 } }
//  Private mm_fiz_razv2 := { { 'нет    ', 0 }, ;
//    { 'низкий ', 1 }, ;
//    { 'высокий', 2 } }
//  Private mm_psih2 := { { 'норма', 0 }, { 'отклонение', 1 } }
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
  Private mstacionar, m1stacionar := st_stacionar, ; // код стационара
    metap := 1, mshifr_zs := '', ;
    mkateg_uch, m1kateg_uch := st_kateg_uch, ; // Категория учета ребенка:
    mgde_nahod, m1gde_nahod := iif( tip_lu == TIP_LU_DDS, 0, 1 ), ; // На момент проведения диспансеризации находится
    mdate_post := CToD( '' ), ; // Дата поступления в стационарное учреждение
    mprich_vyb, m1prich_vyb := 0, ; // Причина выбытия из стационарного учреждения
    mDATE_VYB := CToD( '' ), ;   // Дата выбытия
    mPRICH_OTS := Space( 70 ), ; // причина отсутствия на момент проведения диспансеризации
    mMO_PR := Space( 10 ), m1MO_PR := st_mo_pr, ; // код МО прикрепления
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
    mdiag_15_1, m1diag_15_1 := 1, ; // Состояние здоровья до проведения диспансеризации-Практически здоров
    mdiag_15[ 5, 14 ], ; //
    mGRUPPA_DO := 0, ; // группа здоровья до дисп-ии
    mdiag_16_1, m1diag_16_1 := 1, ; // Состояние здоровья по результатам проведения диспансеризации (Практически здоров)
    mdiag_16[ 5, 16 ], ; //
    minvalid[ 8 ], ;  // раздел 16.7
    mGRUPPA := 0, ;    // группа здоровья после дисп-ии
    mPRIVIVKI[ 3 ], ; // Проведение профилактических прививок
    mrek_form := Space( 255 ), ; // 'C100',Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой
    mrek_disp := Space( 255 ), ; // 'C100',Рекомендации по диспансерному наблюдению, лечению, медицинской реабилитации и санаторно-курортному лечению с указанием диагноза (код МКБ), вида медицинской организации и специальности (должности) врача
    mstep2, m1step2 := 0
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
  Private mvar, m1var, m1lis := 0, m1onko8 := 0, monko8, m1onko10 := 0, monko10
  Private mDS_ONK, m1DS_ONK := 0 // Признак подозрения на злокачественное новообразование
  Private mdopo_na, m1dopo_na := 0
  Private mm_dopo_na := arr_mm_dopo_na()
  Private gl_arr := { ;  // для битовых полей
    { 'dopo_na', 'N', 10, 0,,,, {| x| inieditspr( A__MENUBIT, mm_dopo_na, x ) } };
    }
  Private mnapr_v_mo, m1napr_v_mo := 0, mm_napr_v_mo := arr_mm_napr_v_mo(), ;
    arr_mo_spec := {}, ma_mo_spec, m1a_mo_spec := 1
  Private mnapr_stac, m1napr_stac := 0, ;
    mm_napr_stac := arr_mm_napr_stac(), ;
    mprofil_stac, m1profil_stac := 0
  Private mnapr_reab, m1napr_reab := 0, mprofil_kojki, m1profil_kojki := 0

  Private mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

  //
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
  For i := 1 To Len( dds_arr_iss() )
    mvar := 'MTAB_NOMiv' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMia' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATEi' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MREZi' + lstr( i )
    Private &mvar := Space( 17 )
    m1var := 'M1LIS' + lstr( i )
    Private &m1var := 0
    mvar := 'MLIS' + lstr( i )
    Private &mvar := inieditspr( A__MENUVERT, mm_kdp2, &m1var )
  Next
  For i := 1 To Len( dds_arr_osm1() )
    mvar := 'MTAB_NOMov' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMoa' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATEo' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MKOD_DIAGo' + lstr( i )
    Private &mvar := Space( 6 )
  Next
  For i := 1 To Len( dds_arr_osm2() )
    mvar := 'MTAB_NOM2ov' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOM2oa' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATE2o' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MKOD_DIAG2o' + lstr( i )
    Private &mvar := Space( 6 )
  Next
  //
  AFill( adiag_talon, 0 )
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  r_use( dir_server() + 'human',, 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  If mkod_k > 0
    r_use( dir_server() + 'kartote2',, 'KART2' )
    Goto ( mkod_k )
    r_use( dir_server() + 'kartote_',, 'KART_' )
    Goto ( mkod_k )
    r_use( dir_server() + 'kartotek',, 'KART' )
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
      mnameismo := ret_inogsmo_name( 1,, .t. ) // открыть и закрыть
    Endif
    // проверка исхода = СМЕРТЬ
    Select HUMAN
    Set Index to ( dir_server() + 'humankk' )
    // find (str(mkod_k,7))
    // do while human->kod_k == mkod_k .and. !eof()
    // if recno() != Loc_kod .and. is_death(human_->RSLT_NEW) .and. ;
    // human_->oplata != 9 .and. human_->NOVOR == 0
    // a_smert := {'Данный больной умер!',;
    // 'Лечение с '+full_date(human->N_DATA)+;
    // ' по '+full_date(human->K_DATA)}
    // exit
    // endif
    // skip
    // enddo
    arr_patient_died_during_treatment( mkod_k, loc_kod )
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
    MKOD_DIAG0  := human_->KOD_DIAG0
    MKOD_DIAG   := human->KOD_DIAG
    MKOD_DIAG2  := human->KOD_DIAG2
    MKOD_DIAG3  := human->KOD_DIAG3
    MKOD_DIAG4  := human->KOD_DIAG4
    MSOPUT_B1   := human->SOPUT_B1
    MSOPUT_B2   := human->SOPUT_B2
    MSOPUT_B3   := human->SOPUT_B3
    MSOPUT_B4   := human->SOPUT_B4
    MDIAG_PLUS  := human->DIAG_PLUS
    MPOLIS      := human->POLIS         // серия и номер страхового полиса
    If human->OBRASHEN == '1'
      m1DS_ONK := 1
    Endif
    For i := 1 To 16
      adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
    Next
    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    If Empty( Val( msmo := human_->SMO ) )
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    Else
      m1komu := m1str_crb := 0
    Endif
    m1okato    := human_->OKATO  // ОКАТО субъекта РФ территории страхования
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    m1stacionar := human->ZA_SMO
    mcena_1    := human->CENA_1
    metap      := human->ishod - 100
    mGRUPPA    := human_->RSLT_NEW - L_BEGIN_RSLT
    is_disp_19 := !( mk_data < 0d20191101 )
    //
    larr := Array( 3, Len( dds_arr_osm2() ) ) ; afillall( larr, 0 )
    mdate1 := mdate2 := CToD( '' )
    r_use( dir_server() + 'uslugi',, 'USL' )
    use_base( 'human_u' )
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
        lshifr := usl->shifr
      Endif
      lshifr := AllTrim( lshifr )
      If eq_any( Left( lshifr, 5 ), '70.5.', '70.6.' )
        mshifr_zs := lshifr
      Else
        fl := .t.
        For i := 1 To Len( dds_arr_iss() )
          If AScan( dds_arr_iss()[ i, 7 ], lshifr ) > 0 .and. Empty( larr[ 1, i ] )
            fl := .f. ; larr[ 1, i ] := hu->( RecNo() ) ; Exit
          Endif
        Next
        If fl
          For i := 1 To Len( dds_arr_osm1() )
            If AScan( dds_arr_osm1()[ i, 5 ], hu_->PROFIL ) > 0 .and. Empty( larr[ 2, i ] )
              fl := .f. ; larr[ 2, i ] := hu->( RecNo() )
              If i == Len( dds_arr_osm1() )
                mdate1 := c4tod( hu->date_u )
              Endif
              Exit
            Endif
          Next
        Endif
        If fl .and. metap == 2 // два этапа
          m1step2 := 1
          For i := 1 To Len( dds_arr_osm2() )
            If AScan( dds_arr_osm2()[ i, 5 ], hu_->PROFIL ) > 0 .and. Empty( larr[ 3, i ] )
              fl := .f. ; larr[ 3, i ] := hu->( RecNo() )
              If hu->is_edit == 3
                If hu_->PROFIL == 12
                  m1onko8 := 3
                Elseif hu_->PROFIL == 18
                  m1onko10 := 3
                Endif
              Endif
              If i == Len( dds_arr_osm2() )
                mdate2 := c4tod( hu->date_u )
              Endif
              Exit
            Endif
          Next
        Endif
      Endif
      AAdd( arr_usl, hu->( RecNo() ) )
      Select HU
      Skip
    Enddo
    If !emptyany( mdate1, mdate2 ) .and. mdate1 > mdate2 // если осмотр педиатра I этапа позднее педиатра II этапа
      k := larr[ 2, Len( dds_arr_osm1() ) ] // запомнить
      larr[ 2, Len( dds_arr_osm1() ) ] := larr[ 3, Len( dds_arr_osm2() ) ]
      larr[ 3, Len( dds_arr_osm2() ) ] := k // обменять значения
    Endif
    r_use( dir_server() + 'mo_pers',, 'P2' )
    For j := 1 To 3
      If j == 1
        _arr := dds_arr_iss()  ; bukva := 'i'
      Elseif j == 2
        _arr := dds_arr_osm1() ; bukva := 'o'
      Else
        _arr := dds_arr_osm2() ; bukva := '2o'
      Endif
      For i := 1 To Len( _arr )
        If !Empty( larr[ j, i ] )
          hu->( dbGoto( larr[ j, i ] ) )
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
            Elseif glob_yes_kdp2()[ tip_lu ] .and. AScan( glob_arr_usl_LIS, dds_arr_iss()[ i, 7, 1 ] ) > 0 .and. hu->is_edit > 0
              &m1var := hu->is_edit
            Endif
            mvar := 'mlis' + lstr( i )
            &mvar := inieditspr( A__MENUVERT, mm_kdp2, &m1var )
          Elseif !Empty( hu_->kod_diag ) .and. !( Left( hu_->kod_diag, 1 ) == 'Z' )
            mvar := 'MKOD_DIAG' + bukva + lstr( i )
            &mvar := hu_->kod_diag
          Endif
        Endif
      Next
    Next
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 2, @rec_inogSMO, .t. ) // открыть и закрыть
    Endif
    read_arr_dds( Loc_kod )
  Endif
  If !( Left( msmo, 2 ) == '34' ) // не Волгоградская область
    m1ismo := msmo ; msmo := '34'
  Endif
  is_talon := .t.
  dbCloseAll()
  fv_date_r( iif( Loc_kod > 0, mn_data, ) )
  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  mlpu      := inieditspr( A__POPUPMENU, dir_server() + 'mo_uch', m1lpu )
  motd      := inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', m1otd )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf(), m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
  monko8    := inieditspr( A__MENUVERT, mm_vokod(), m1onko8 )
  monko10   := inieditspr( A__MENUVERT, mm_vokod(), m1onko10 )
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
  If tip_lu == TIP_LU_DDS // На момент проведения диспансеризации находится
    m1gde_nahod := 0    // в стационаре
  Else
    If m1gde_nahod == 0
      m1gde_nahod := 1
    Endif
    mdate_post := CToD( '' )
//    del_array( mm_gde_nahod(), 1 ) ПОКА ТАК, НЕ ЗНАЮ ЗАЧЕМ УДАЛЯЕТСЯ
  Endif
  mmobilbr := inieditspr( A__MENUVERT, mm_danet, m1mobilbr )
  mstacionar := inieditspr( A__POPUPMENU, dir_server() + 'mo_stdds', m1stacionar )
  mkateg_uch := inieditspr( A__MENUVERT, mm_kateg_uch(), m1kateg_uch )
  mgde_nahod := inieditspr( A__MENUVERT, mm_gde_nahod(), m1gde_nahod )
  mprich_vyb := inieditspr( A__MENUVERT, mm_prich_vyb(), m1prich_vyb )
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
  mstep2 := inieditspr( A__MENUVERT, mm_danet, m1step2 )
  minvalid1 := inieditspr( A__MENUVERT, mm_danet,    m1invalid1 )
  minvalid2 := inieditspr( A__MENUVERT, mm_invalid2(), m1invalid2 )
  minvalid5 := inieditspr( A__MENUVERT, mm_invalid5, m1invalid5 )
  minvalid6 := inieditspr( A__MENUVERT, mm_invalid6(), m1invalid6 )
  minvalid8 := inieditspr( A__MENUVERT, mm_invalid8(), m1invalid8 )
  mprivivki1 := inieditspr( A__MENUVERT, mm_privivki1(), m1privivki1 )
  mprivivki2 := inieditspr( A__MENUVERT, mm_privivki2(), m1privivki2 )
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
    return &( f_print + '(' + lstr( Loc_kod ) + ',' + lstr( kod_kartotek ) + ',' + lstr( mvozrast ) + ')' )
  Endif
  //
  str_1 := ' случая диспансеризации детей-сирот'
  If Loc_kod == 0
    str_1 := 'Добавление' + str_1
    mtip_h := yes_vypisan
  Else
    str_1 := 'Редактирование' + str_1
  Endif
  SetColor( color8 )
  @ 0, 0 Say PadC( str_1, 80 ) Color 'B/BG*'
  Private gl_area
  SetColor( cDataCGet )
  make_diagp( 1 )  // сделать 'шестизначные' диагнозы
  Private num_screen := 1
  Do While .t.
    dbCloseAll()
    DispBegin()
    If num_screen == 5
      hS := 32
      wS := 90
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
      @ j, ( wS - 30 ) Say PadL( 'Лист учета № ' + lstr( Loc_kod ), 29 ) Color color14
    Endif
    @ j, 0 Say 'Экран ' + lstr( num_screen ) Color color8
    If num_screen > 1
      is_disp_19 := !( mk_data < 0d20191101 )
      s := AllTrim( mfio ) + ' (' + lstr( mvozrast ) + ' ' + s_let( mvozrast ) + ')'
      @ j, wS - Len( s ) Say s Color color14
    Endif
    If num_screen == 1 // 
      ++j; @ j, 1 Say 'Учреждение' Get mlpu When .f. Color cDataCSay
      @ Row(), Col() + 2 Say 'Отделение' Get motd When .f. Color cDataCSay
      //
      ++j; @ j, 1 Say 'ФИО' Get mfio_kart ;
        reader {| x| menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION,,, .f. ) } ;
        valid {| g, o| update_get( 'mkomu' ), update_get( 'mcompany' ) }
      ++j; @ j, 1 Say 'Принадлежность счёта' Get mkomu ;
        reader {| x| menu_reader( x, mm_komu, A__MENUVERT,,, .f. ) } ;
        valid {| g, o| f_valid_komu( g, o ) } ;
        Color colget_menu
      @ Row(), Col() + 1 Say '==>' Get mcompany ;
        reader {| x| menu_reader( x, mm_company, A__MENUVERT,,, .f. ) } ;
        When m1komu < 5 ;
        valid {| g| func_valid_ismo( g, m1komu, 38 ) }
      ++j; @ j, 1 Say 'Полис ОМС: серия' Get mspolis When m1komu == 0
      @ Row(), Col() + 3 Say 'номер'  Get mnpolis When m1komu == 0
      @ Row(), Col() + 3 Say 'вид'    Get mvidpolis ;
        reader {| x| menu_reader( x, mm_vid_polis, A__MENUVERT,,, .f. ) } ;
        When m1komu == 0 ;
        Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
      ++j; @ j, 1 To j, 78
      If tip_lu == TIP_LU_DDS
        ++j; @ j, 1 Say 'Стационарное учреждение' Get mstacionar reader ;
          {| x| menu_reader( x, ;
          { dir_server() + 'mo_stdds',,,,, color5, 'Стационары, из которых проходит диспансеризация детей-сирот', 'B/W' }, ;
          A__POPUPMENU,,, .f. );
          }
      Endif
      ++j; @ j, 1 Say 'Категория учета ребенка' Get mkateg_uch ;
        reader {| x| menu_reader( x, mm_kateg_uch(), A__MENUVERT,,, .f. ) }
      If tip_lu == TIP_LU_DDS
        ++j; @ j, 1 Say 'Дата поступления в стационарное учреждение' Get mdate_post
      Else
        ++j; @ j, 1 Say 'На момент проведения диспансеризации находится' Get mgde_nahod ;
          reader {| x| menu_reader( x, mm_gde_nahod(), A__MENUVERT,,, .f. ) }
      Endif
      ++j; @ j, 1 Say 'Причина выбытия из стационарного учреждения' Get mprich_vyb ;
        reader {| x| menu_reader( x, mm_prich_vyb(), A__MENUVERT,,, .f. ) } ;
        valid {|| iif( m1prich_vyb == 0, mDATE_VYB := CToD( '' ), nil ), .t. }
      ++j; @ j, 40 Say 'Дата выбытия' Get mDATE_VYB When m1prich_vyb > 0
      ++j; @ j, 1 Say 'Отсутствует на момент проведения диспансеризации' Get mPRICH_OTS Pict '@S29'
      ++j; @ j, 1 To j, 78
      ++j
      ++j; @ j, 1 Say 'Сроки диспансеризации' Get mn_data ;
        valid {| g| f_k_data( g, 1 ), ;
        iif( mvozrast < 18, nil, func_error( 4, 'Это взрослый пациент!' ) ), ;
        .t. ;
        }
      @ Row(), Col() + 1 Say '-'   Get mk_data valid {| g| f_k_data( g, 2 ) }
      @ Row(), Col() + 3 Get mvzros_reb When .f. Color cDataCSay
      ++j; @ j, 1 Say '№ амбулаторной карты' Get much_doc Picture '@!' ;
        When !( is_uchastok == 1 .and. is_task( X_REGIST ) ) ;
        .or. mem_edit_ist == 2
      ++j
      ++j; @ j, 1 Say 'Медосмотр проведён мобильной бригадой?' Get mmobilbr ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      ++j; @ j, 1 Say 'МО прикрепления' Get mMO_PR ;
        reader {| x| menu_reader( x, { {| k, r, c| f_get_mo( k, r, c ) } }, A__FUNCTION,,, .f. ) }
      ++j; @ j, 1 Say 'Вес' Get mWEIGHT Pict '999' ;
        valid {|| iif( Between( mWEIGHT, 2, 170 ),, func_error( 4, 'Неразумный вес' ) ), .t. }
      @ Row(), Col() + 1 Say 'кг, рост' Get mHEIGHT Pict '999' ;
        valid {|| iif( Between( mHEIGHT, 40, 250 ),, func_error( 4, 'Неразумный рост' ) ), .t. }
      @ Row(), Col() + 1 Say 'см, окружность головы' Get mPER_HEAD  Pict '999' ;
        valid {|| iif( Between( mPER_HEAD, 10, 100 ),, func_error( 4, 'Неразумный размер окружности головы' ) ), .t. }
      @ Row(), Col() + 1 Say 'см'
      ++j; @ j, 1 Say 'Физическое развитие' Get mfiz_razv ;
        reader {| x| menu_reader( x, mm_fiz_razv(), A__MENUVERT,,, .f. ) } ;
        valid {|| iif( m1FIZ_RAZV == 0, ( mfiz_razv1 := 'нет    ', m1fiz_razv1 := 0, ;
        mfiz_razv2 := 'нет    ', m1fiz_razv2 := 0 ), nil ), .t. }
      ++j; @ j, 10 Say 'отклонение массы тела' Get mfiz_razv1 ;
        reader {| x| menu_reader( x, mm_fiz_razv1(), A__MENUVERT,,, .f. ) } ;
        When m1FIZ_RAZV == 1
      @ j, 39 Say ', роста' Get mfiz_razv2 ;
        reader {| x| menu_reader( x, mm_fiz_razv2(), A__MENUVERT,,, .f. ) } ;
        When m1FIZ_RAZV == 1
      status_key( '^<Esc>^ выход без записи ^<PgDn>^ на 2-ю страницу' )
      If !Empty( a_smert )
        n_message( a_smert,, 'GR+/R', 'W+/R',,, 'G+/R' )
      Endif
    Elseif num_screen == 2 // 
      fl_kdp2 := Array( Len( dds_arr_iss() ) )
      AFill( fl_kdp2, .f. )
      For i := 1 To Len( dds_arr_iss() )
        mvar := 'MDATEi' + lstr( i )
        If Empty( &mvar )
          &mvar := mn_data
        Endif
        If !is_disp_19 .and. glob_yes_kdp2()[ tip_lu ] .and. AScan( glob_arr_usl_LIS, dds_arr_iss()[ i, 7, 1 ] ) > 0
          fl_kdp2[ i ] := .t.
        Endif
      Next
      For i := 1 To Len( dds_arr_osm1() )
        mvar := 'MDATEo' + lstr( i )
        If Empty( &mvar )
          &mvar := mn_data
        Endif
      Next
      ++j; @ j, 1 Say 'I этап наименований исследований       Врач Ассис.  Дата     Результат' Color 'RB+/B'
      ++j; @ j, 1 Say 'Клинический анализ мочи'
      @ j, 39 Get MTAB_NOMiv1 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMia1 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Else
        @ j - 1, 45 Say Space( 6 )
      Endif
      @ j, 51 Get MDATEi1
      @ j, 62 Get MREZi1
      ++j; @ j, 1 Say 'Клинический анализ крови'
      If fl_kdp2[ 2 ]
        @ j, 34 Get mlis2 reader {| x| menu_reader( x, mm_kdp2, A__MENUVERT,,, .f. ) }
      Endif
      @ j, 39 Get MTAB_NOMiv2 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMia2 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Endif
      @ j, 51 Get MDATEi2
      @ j, 62 Get MREZi2
      ++j; @ j, 1 Say 'Иссл-ние уровня глюкозы в крови'
      If fl_kdp2[ 3 ]
        @ j, 34 Get mlis3 reader {| x| menu_reader( x, mm_kdp2, A__MENUVERT,,, .f. ) }
      Endif
      @ j, 39 Get MTAB_NOMiv3 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMia3 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Endif
      @ j, 51 Get MDATEi3
      @ j, 62 Get MREZi3
      ++j; @ j, 1 Say 'Электрокардиография'
      @ j, 39 Get MTAB_NOMiv4 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMia4 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Endif
      @ j, 51 Get MDATEi4
      @ j, 62 Get MREZi4
      If mvozrast >= 15
        ++j; @ j, 1 Say 'Флюорография легких (с 15 лет)'
        @ j, 39 Get MTAB_NOMiv5 Pict '99999' valid {| g| v_kart_vrach( g ) }
        If mem_por_ass > 0
          @ j, 45 Get MTAB_NOMia5 Pict '99999' valid {| g| v_kart_vrach( g ) }
        Endif
        @ j, 51 Get MDATEi5
        @ j, 62 Get MREZi5
      Endif
      If mvozrast < 1
        ++j; @ j, 1 Say 'УЗИ гол.мозга/нейросонография(до 1г.)'
        @ j, 39 Get MTAB_NOMiv6 Pict '99999' valid {| g| v_kart_vrach( g ) }
        If mem_por_ass > 0
          @ j, 45 Get MTAB_NOMia6 Pict '99999' valid {| g| v_kart_vrach( g ) }
        Endif
        @ j, 51 Get MDATEi6
        @ j, 62 Get MREZi6
      Endif
      If mvozrast >= 7
        ++j; @ j, 1 Say 'УЗИ щитовидной железы (с 7 лет)'
        @ j, 39 Get MTAB_NOMiv7 Pict '99999' valid {| g| v_kart_vrach( g ) }
        If mem_por_ass > 0
          @ j, 45 Get MTAB_NOMia7 Pict '99999' valid {| g| v_kart_vrach( g ) }
        Endif
        @ j, 51 Get MDATEi7
        @ j, 62 Get MREZi7
      Endif
      ++j; @ j, 1 Say 'УЗИ сердца'
      @ j, 39 Get MTAB_NOMiv8 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMia8 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Endif
      @ j, 51 Get MDATEi8
      @ j, 62 Get MREZi8
      If mvozrast < 1
        ++j; @ j, 1 Say 'УЗИ тазобедренных суставов (до 1г.)'
        @ j, 39 Get MTAB_NOMiv9 Pict '99999' valid {| g| v_kart_vrach( g ) }
        If mem_por_ass > 0
          @ j, 45 Get MTAB_NOMia9 Pict '99999' valid {| g| v_kart_vrach( g ) }
        Endif
        @ j, 51 Get MDATEi9
        @ j, 62 Get MREZi9
      Endif
      ++j; @ j, 1 Say 'УЗИ органов брюшной полости'
      @ j, 39 Get MTAB_NOMiv10 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMia10 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Endif
      @ j, 51 Get MDATEi10
      @ j, 62 Get MREZi10
      If mvozrast >= 7
        ++j; @ j, 1 Say 'УЗИ органов репродуктивной системы'
        @ j, 39 Get MTAB_NOMiv11 Pict '99999' valid {| g| v_kart_vrach( g ) }
        If mem_por_ass > 0
          @ j, 45 Get MTAB_NOMia11 Pict '99999' valid {| g| v_kart_vrach( g ) }
        Endif
        @ j, 51 Get MDATEi11
        @ j, 62 Get MREZi11
      Endif
      //
      // ++j; @ j,1 say 'I этап наименований осмотров           Врач Ассис.  Дата     Диагноз' color 'RB+/B'
      ++j; @ j, 1 Say 'I этап наименований осмотров           Врач Ассис.  Дата     ' Color 'RB+/B'
      ++j; @ j, 1 Say 'офтальмолог'
      @ j, 39 Get MTAB_NOMov1 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMoa1 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Else
        @ j - 1, 45 Say Space( 6 )
      Endif
      @ j, 51 Get MDATEo1
      // @ j,62 get mkod_diago1 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      ++j; @ j, 1 Say 'оториноларинголог'
      @ j, 39 Get MTAB_NOMov2 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMoa2 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Endif
      @ j, 51 Get MDATEo2
      // @ j,62 get mkod_diago2 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      ++j; @ j, 1 Say 'детский хирург'
      @ j, 39 Get MTAB_NOMov3 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMoa3 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Endif
      @ j, 51 Get MDATEo3
      // @ j,62 get mkod_diago3 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      ++j; @ j, 1 Say 'травматолог-ортопед'
      @ j, 39 Get MTAB_NOMov4 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMoa4 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Endif
      @ j, 51 Get MDATEo4
      // @ j,62 get mkod_diago4 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      If mpol == 'Ж'
        ++j; @ j, 1 Say 'акушер-гинеколог (девочки)'
        @ j, 39 Get MTAB_NOMov5 Pict '99999' valid {| g| v_kart_vrach( g ) }
        If mem_por_ass > 0
          @ j, 45 Get MTAB_NOMoa5 Pict '99999' valid {| g| v_kart_vrach( g ) }
        Endif
        @ j, 51 Get MDATEo5
        // @ j,62 get mkod_diago5 picture pic_diag ;
        // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      Endif
      If mpol == 'М'
        ++j; @ j, 1 Say 'детский уролог-андролог (мальчики)'
        @ j, 39 Get MTAB_NOMov6 Pict '99999' valid {| g| v_kart_vrach( g ) }
        If mem_por_ass > 0
          @ j, 45 Get MTAB_NOMoa6 Pict '99999' valid {| g| v_kart_vrach( g ) }
        Endif
        @ j, 51 Get MDATEo6
        // @ j,62 get mkod_diago6 picture pic_diag ;
        // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      Endif
      If mvozrast >= 3
        ++j; @ j, 1 Say 'детский стоматолог (с 3 лет)'
        @ j, 39 Get MTAB_NOMov7 Pict '99999' valid {| g| v_kart_vrach( g ) }
        If mem_por_ass > 0
          @ j, 45 Get MTAB_NOMoa7 Pict '99999' valid {| g| v_kart_vrach( g ) }
        Endif
        @ j, 51 Get MDATEo7
        // @ j,62 get mkod_diago7 picture pic_diag ;
        // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      Elseif Empty( MTAB_NOMov7 )
        MDATEo7 := CToD( '' )
      Endif
      If mvozrast >= 5
        ++j; @ j, 1 Say 'детский эндокринолог (с 5 лет)'
        @ j, 39 Get MTAB_NOMov8 Pict '99999' valid {| g| v_kart_vrach( g ) }
        If mem_por_ass > 0
          @ j, 45 Get MTAB_NOMoa8 Pict '99999' valid {| g| v_kart_vrach( g ) }
        Endif
        @ j, 51 Get MDATEo8
        // @ j,62 get mkod_diago8 picture pic_diag ;
        // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      Elseif Empty( MTAB_NOMov8 )
        MDATEo8 := CToD( '' )
      Endif
      ++j; @ j, 1 Say 'невролог'
      @ j, 39 Get MTAB_NOMov9 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMoa9 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Endif
      @ j, 51 Get MDATEo9
      // @ j,62 get mkod_diago9 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      ++j; @ j, 1 Say 'психиатр'
      @ j, 39 Get MTAB_NOMov10 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMoa10 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Endif
      @ j, 51 Get MDATEo10
      // @ j,62 get mkod_diago10 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      ++j; @ j, 1 Say 'педиатр'
      @ j, 39 Get MTAB_NOMov11 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMoa11 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Endif
      @ j, 51 Get MDATEo11
      // @ j,62 get mkod_diago11 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      status_key( '^<Esc>^ выход без записи ^<PgUp>^ на 1-ю страницу ^<PgDn>^ на 3-ю страницу' )
    Elseif num_screen == 3 // 
      ++j; @ j, 1 Say 'II этап диспансеризации детей-сирот и детей, находящихся в тяжелой жизненной'
      ++j; @ j, 1 Say 'ситуации. Выберите, необходимо вводить врачебные осмотры II этапа?' Get mstep2 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      ++j
      // ++j; @ j,1 say ' II этап наим. осмотров       Врач Ассис.  Дата     Диагноз' color 'RB+/B'
      ++j; @ j, 1 Say ' II этап наим. осмотров       Врач Ассис.  Дата     ' Color 'RB+/B'
      If mvozrast < 3
        ++j; @ j, 1 Say 'детский стоматолог до 3 лет'
        @ j, 30 Get MTAB_NOMov7 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
        If mem_por_ass > 0
          @ j, 36 Get MTAB_NOMoa7 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
        Else
          @ j - 1, 36 Say Space( 6 )
        Endif
        @ j, 42 Get MDATEo7 When m1step2 == 1
        // @ j,53 get mkod_diago7 picture pic_diag ;
        // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) when m1step2==1
      Endif
      If mvozrast < 5
        ++j; @ j, 1 Say 'детский эндокринолог до 5 лет'
        @ j, 30 Get MTAB_NOMov8 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
        If mem_por_ass > 0
          @ j, 36 Get MTAB_NOMoa8 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
        Else
          @ j - 1, 36 Say Space( 6 )
        Endif
        @ j, 42 Get MDATEo8 When m1step2 == 1
        // @ j,53 get mkod_diago8 picture pic_diag ;
        // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) when m1step2==1
      Endif
      ++j; @ j, 1 Say 'пульмонолог'
      @ j, 30 Get MTAB_NOM2ov1 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa1 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Else
        @ j - 1, 36 Say Space( 6 )
      Endif
      @ j, 42 Get MDATE2o1 When m1step2 == 1
      // @ j,53 get mkod_diag2o1 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      ++j; @ j, 1 Say 'дерматовенеролог'
      @ j, 30 Get MTAB_NOM2ov2 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa2 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Endif
      @ j, 42 Get MDATE2o2 When m1step2 == 1
      // @ j,53 get mkod_diag2o2 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      ++j; @ j, 1 Say 'ревматолог'
      @ j, 30 Get MTAB_NOM2ov3 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa3 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Endif
      @ j, 42 Get MDATE2o3 When m1step2 == 1
      // @ j,53 get mkod_diag2o3 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      ++j; @ j, 1 Say 'аллерголог-иммунолог'
      @ j, 30 Get MTAB_NOM2ov4 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa4 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Endif
      @ j, 42 Get MDATE2o4 When m1step2 == 1
      // @ j,53 get mkod_diag2o4 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      ++j; @ j, 1 Say 'детский кардиолог'
      @ j, 30 Get MTAB_NOM2ov5 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa5 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Endif
      @ j, 42 Get MDATE2o5 When m1step2 == 1
      // @ j,53 get mkod_diag2o5 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      ++j; @ j, 1 Say 'гастроэнтеролог'
      @ j, 30 Get MTAB_NOM2ov6 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa6 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Endif
      @ j, 42 Get MDATE2o6 When m1step2 == 1
      // @ j,53 get mkod_diag2o6 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      ++j; @ j, 1 Say 'нефролог'
      @ j, 30 Get MTAB_NOM2ov7 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa7 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Endif
      @ j, 42 Get MDATE2o7 When m1step2 == 1
      // @ j,53 get mkod_diag2o7 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      ++j; @ j, 1 Say 'гематолог'
      @ j, 24 Get monko8 reader {| x| menu_reader( x, mm_vokod(), A__MENUVERT,,, .f. ) } When m1step2 == 1
      @ j, 30 Get MTAB_NOM2ov8 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1 .and. m1onko8 == 0
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa8 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1 .and. m1onko8 == 0
      Endif
      @ j, 42 Get MDATE2o8 When m1step2 == 1
      // @ j,53 get mkod_diag2o8 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      ++j; @ j, 1 Say 'инфекционист'
      @ j, 30 Get MTAB_NOM2ov9 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa9 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Endif
      @ j, 42 Get MDATE2o9 When m1step2 == 1
      // @ j,53 get mkod_diag2o9 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      ++j; @ j, 1 Say 'детский онколог'
      @ j, 24 Get monko10 reader {| x| menu_reader( x, mm_vokod(), A__MENUVERT,,, .f. ) } When m1step2 == 1
      @ j, 30 Get MTAB_NOM2ov10 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1 .and. m1onko10 == 0
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa10 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1 .and. m1onko10 == 0
      Endif
      @ j, 42 Get MDATE2o10 When m1step2 == 1
      // @ j,53 get mkod_diag2o10 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      ++j; @ j, 1 Say 'нейрохирург'
      @ j, 30 Get MTAB_NOM2ov11 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa11 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Endif
      @ j, 42 Get MDATE2o11 When m1step2 == 1
      // @ j,53 get mkod_diag2o11 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      ++j; @ j, 1 Say 'колопроктолог'
      @ j, 30 Get MTAB_NOM2ov12 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa12 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Endif
      @ j, 42 Get MDATE2o12 When m1step2 == 1
      // @ j,53 get mkod_diag2o12 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      ++j; @ j, 1 Say 'сердечно-сосудистый хирург'
      @ j, 30 Get MTAB_NOM2ov13 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa13 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Endif
      @ j, 42 Get MDATE2o13 When m1step2 == 1
      // @ j,53 get mkod_diag2o13 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      ++j; @ j, 1 Say 'педиатр'
      @ j, 30 Get MTAB_NOM2ov14 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 36 Get MTAB_NOM2oa14 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Endif
      @ j, 42 Get MDATE2o14 When m1step2 == 1
      // @ j,53 get mkod_diag2o14 picture pic_diag ;
      // reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
      // when m1step2==1
      status_key( '^<Esc>^ выход без записи ^<PgUp>^ на 2-ю страницу ^<PgDn>^ на 4-ю страницу' )
    Elseif num_screen == 4 // 
      If mvozrast < 5
        ++j; @ j, 1 Say PadC( 'Оценка психического развития (возраст развития):', 78, '_' )
        ++j; @ j, 1 Say 'познавательная функция' Get m1psih11 Pict '99'
        ++j; @ j, 1 Say 'моторная функция      ' Get m1psih12 Pict '99'
        --j; @ j, 30 Say 'эмоциональная и социальная    ' Get m1psih13 Pict '99'
        ++j; @ j, 30 Say 'предречевое и речевое развитие' Get m1psih14 Pict '99'
      Else
        ++j; @ j, 1 Say PadC( 'Оценка психического развития:', 78, '_' )
        ++j; @ j, 1 Say 'психомоторная сфера' Get mpsih21 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT,,, .f. ) }
        ++j; @ j, 1 Say 'интеллект          ' Get mpsih22 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT,,, .f. ) }
        --j; @ j, 40 Say 'эмоц.вегетативная сфера' Get mpsih23 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT,,, .f. ) }
        ++j
      Endif
      ++j
      If mpol == 'М'
        ++j; @ j, 1 Say 'Половая формула мальчика: P' Get m141p Pict '9'
        @ j, Col() Say ', Ax' Get m141ax Pict '9'
        @ j, Col() Say ', Fa' Get m141fa Pict '9'
      Else
        ++j; @ j, 1 Say 'Половая формула девочки: P' Get m142p Pict '9'
        @ j, Col() Say ', Ax' Get m142ax Pict '9'
        @ j, Col() Say ', Ma' Get m142ma Pict '9'
        @ j, Col() Say ', Me' Get m142me Pict '9'
        ++j; @ j, 1 Say '  menarhe' Get m142me1 Pict '99'
        @ j, Col() + 1 Say 'лет,' Get m142me2 Pict '99'
        @ j, Col() + 1 Say 'месяцев, menses' Get m142me3 ;
          reader {| x| menu_reader( x, mm_142me3(), A__MENUVERT,,, .f. ) }
        @ j, 50 Say ',' Get m142me4 ;
          reader {| x| menu_reader( x, mm_142me4(), A__MENUVERT,,, .f. ) }
        @ j, 61 Say ',' Get m142me5 ;
          reader {| x| menu_reader( x, mm_142me5(), A__MENUVERT,,, .f. ) }
      Endif
      ++j
      ++j; @ j, 1 Say 'ДО ПРОВЕДЕНИЯ ДИСПАНСЕРИЗАЦИИ: практически здоров' Get mdiag_15_1 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      ++j; @ j, 1 Say '──────┬───────┬─────────────┬─────────┬─────────────┬─────────┬───────────────'
      ++j; @ j, 1 Say ' Диаг-│Диспанс│Лечение назна│Выполнено│Реаб-ия назна│Выполнена│Высокотехнол.МП'
      ++j; @ j, 1 Say ' ноз  │набл-ие│че-┌────┬────┼────┬────┤че-┌────┬────┼────┬────┼───────┬───────'
      ++j; @ j, 1 Say '      │установ│но │усл.│учр.│усл.│учр.│на │усл.│учр.│усл.│учр.│рекомен│оказана'
      ++j; @ j, 1 Say '──────┴───────┴───┴────┴────┴────┴────┴───┴────┴────┴────┴────┴───────┴───────'
      For i := 1 To 5
        ++j ; fl := .f.
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
              reader {| x| menu_reader( x, mm_dispans, A__MENUVERT,,, .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 3
            @ j, 16 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 4
            @ j, 20 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT,,, .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 5
            @ j, 25 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT,,, .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 6
            @ j, 30 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT,,, .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 7
            @ j, 35 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT,,, .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 8
            @ j, 40 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 9
            @ j, 44 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT,,, .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 10
            @ j, 49 get &mvar ;
              reader {| x| menu_reader( x, mm_uch1, A__MENUVERT,,, .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 11
            @ j, 54 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT,,, .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 12
            @ j, 59 get &mvar ;
              reader {| x| menu_reader( x, mm_uch1, A__MENUVERT,,, .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 13
            @ j, 66 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 14
            @ j, 74 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
              When m1diag_15_1 == 0
          Endcase
        Next
      Next
      ++j; @ j, 1 To j, 78
      ++j; @ j, 1 Say 'ГРУППА состояния ЗДОРОВЬЯ ДО проведения диспансеризации' Color color8
      @ j, Col() + 1 Get mGRUPPA_DO Pict '9'
      status_key( '^<Esc>^ выход без записи ^<PgUp>^ на 3-ю страницу ^<PgDn>^ на 5-ю страницу' )
    Elseif num_screen == 5 // 
      ++j; @ j, 1 Say 'ПО РЕЗУЛЬТАТАМ ПРОВЕДЕНИЯ ДИСПАНСЕРИЗАЦИИ: практически здоров' Get mdiag_16_1 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      ++j; @ j, 1 Say '──────┬───┬───────┬─────────────┬─────────────┬─────────────┬─────────────┬───'
      ++j; @ j, 1 Say ' Диаг-│Уст│Диспанс│Доп.конс.назн│Доп.конс.выпо│Лечение назна│Реаб-ия назна│ВМП'
      ++j; @ j, 1 Say ' ноз  │впе│набл-ие│аче┌────┬────┤лне┌────┬────┤че-┌────┬────┤че-┌────┬────┤рек'
      ++j; @ j, 1 Say '      │рвы│установ│ны │усл.│учр.│ны │усл.│учр.│но │усл.│учр.│на │усл.│учр.│оме'
      ++j; @ j, 1 Say '──────┴───┴───────┴───┴────┴────┴───┴────┴────┴───┴────┴────┴───┴────┴────┴───'
      For i := 1 To 5
        ++j ; fl := .f.
        For k := 1 To 16
          s := 'diag_16_' + lstr( i ) + '_' + lstr( k )
          mvar := 'm' + s
          If k == 1
            fl := !Empty( &mvar )
          Else
            m1var := 'm1' + s
            If fl
              If eq_any( k, 3 )
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
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 3
            @ j, 12 get &mvar ;
              reader {| x| menu_reader( x, mm_dispans, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 4
            @ j, 20 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 5
            @ j, 24 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 6
            @ j, 29 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 7
            @ j, 34 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 8
            @ j, 38 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 9
            @ j, 43 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 10
            @ j, 48 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 11
            @ j, 52 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 12
            @ j, 57 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 13
            @ j, 62 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 14
            @ j, 66 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 15
            @ j, 71 get &mvar ;
              reader {| x| menu_reader( x, mm_uch1, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 16
            @ j, 76 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
              When m1diag_16_1 == 0
          Endcase
        Next
      Next
      ++j
      @ j, 1 To j, 78
      // ++j; @ j,1 say 'Признак подозрения на злокачественное новообразование' get mDS_ONK ;
      // reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}

      dispans_napr( mk_data, @j, .f. )  // вызов заполнения блока направлений

      ++j
      @ j, 1 To j, 78
      ++j
      @ j, 1 Say 'Инвалидность' Get minvalid1 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
      @ j, 30 Say 'если "да":' Get minvalid2 ;
        reader {| x| menu_reader( x, mm_invalid2(), A__MENUVERT,,, .f. ) } ;
        When m1invalid1 == 1
      ++j
      @ j, 2 Say 'установлена впервые' Get minvalid3 ;
        When m1invalid1 == 1
      @ j, Col() + 1 Say 'дата последнего освидетельствования' Get minvalid4 ;
        When m1invalid1 == 1
      ++j
      @ j, 2 Say 'Заболевания/инвалидность' Get minvalid5 ;
        reader {| x| menu_reader( x, mm_invalid5, A__MENUVERT,,, .f. ) } ;
        When m1invalid1 == 1
      ++j
      @ j, 2 Say 'Виды нарушений в состоянии здоровья' Get minvalid6 ;
        reader {| x| menu_reader( x, mm_invalid6(), A__MENUVERT,,, .f. ) } ;
        When m1invalid1 == 1
      ++j
      @ j, 2 Say 'Дата назначения индивидуальной программы реабилитации' Get minvalid7 ;
        When m1invalid1 == 1
      @ j, Col() Say ' выполнение' Get minvalid8 ;
        reader {| x| menu_reader( x, mm_invalid8(), A__MENUVERT,,, .f. ) } ;
        When m1invalid1 == 1
      ++j
      @ j, 1 Say 'Прививки' Get mprivivki1 ;
        reader {| x| menu_reader( x, mm_privivki1(), A__MENUVERT,,, .f. ) }
      @ j, 50 Say 'Не привит' Get mprivivki2 ;
        reader {| x| menu_reader( x, mm_privivki2(), A__MENUVERT,,, .f. ) } ;
        When m1privivki1 > 0
      ++j
      @ j, 2 Say 'Нуждается в вакцинации' Get mprivivki3 Pict '@S64' ;
        When m1privivki1 > 0
      ++j
      @ j, 1 Say 'Рекомендации здорового образа жизни' Get mrek_form Pict '@S52'
      ++j
      @ j, 1 Say 'Рекомендации по диспансерному наблюдению' Get mrek_disp Pict '@S47'
      ++j
      @ j, 1 Say 'ГРУППА состояния ЗДОРОВЬЯ по результатам проведения диспансеризации' Color color8
      @ j, Col() + 1 Get mGRUPPA Pict '9'
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
          iif( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2,, 'W+/N,N/BG' )
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
            1, 'W+/N', 'N+/N', MaxRow() -2,, 'W+/N,N/BG' ) ) == 2
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
        else
          s := 'комитета/МО'
        Endif
        func_error( 4, 'Не заполнено наименование ' + s )
        Loop
      Endif
      If m1komu == 0 .and. Empty( mnpolis )
        func_error( 4, 'Не заполнен номер полиса' )
        Loop
      Endif
      If tip_lu == TIP_LU_DDS
        If Empty( m1stacionar )
          func_error( 4, 'Не заполнено стационарное учреждение' )
          Loop
        Endif
        If Empty( mdate_post )
          func_error( 4, 'Не заполнена дата поступления в стационарное учреждение' )
          Loop
        Elseif mdate_post < mdate_r
          func_error( 4, 'Дата поступления в стационарное учреждение МЕНЬШЕ даты рождения' )
          Loop
        Endif
      Else
        m1stacionar := 0
        If m1gde_nahod == 0
          m1gde_nahod := 1
        Endif
        mdate_post := CToD( '' )
      Endif
      If Empty( mn_data )
        func_error( 4, 'Не введена дата начала лечения.' )
        Loop
      Endif
      If mvozrast >= 18
        func_error( 4, 'Диспансеризация детей-сирот оказана взрослому пациенту!' )
        Loop
      Endif
      If Empty( mk_data )
        func_error( 4, 'Не введена дата окончания лечения.' )
        Loop
      Elseif mk_data < SToD( '20130525' )
        func_error( 4, 'Дата окончания лечения не должна быть ранее 25 мая 2013 года' )
        Loop
      Endif
      If Empty( CharRepl( '0', much_doc, Space( 10 ) ) )
        func_error( 4, 'Не заполнен номер амбулаторной карты' )
        Loop
      Endif
      If Empty( mmo_pr )
        func_error( 4, 'Не введено МО, к которому прикреплён ребёнок.' )
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
      If mvozrast < 5 .and. Empty( mPER_HEAD )
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
      arr_iss := Array( Len( dds_arr_iss() ), 10 )
      afillall( arr_iss, 0 )
      r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'MKB_10' )
      r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'P2' )
      num_screen := 2
      max_date1 := max_date2 := mn_data
      d12 := mn_data - 1
      k := 0
      If metap == 2
        Do While++d12 <= mk_data
          If is_work_day( d12 )
            If++k == 10
              Exit
            Endif
          Endif
        Enddo
      Endif
      fl := .t.
      For i := 1 To Len( dds_arr_iss() )
        mvart := 'MTAB_NOMiv' + lstr( i )
        mvara := 'MTAB_NOMia' + lstr( i )
        mvard := 'MDATEi' + lstr( i )
        mvarr := 'MREZi' + lstr( i )
        If Between( mvozrast, dds_arr_iss()[ i, 3 ], dds_arr_iss()[ i, 4 ] )
          m1var := 'm1lis' + lstr( i )
          If !is_disp_19 .and. glob_yes_kdp2()[ tip_lu ] .and. &m1var > 0
            &mvart := -1
          Endif
          If Empty( &mvard )
            fl := func_error( 4, 'Не введена дата иссл-ия "' + dds_arr_iss()[ i, 1 ] + '"' )
          Elseif metap == 2 .and. &mvard > d12
            fl := func_error( 4, 'Дата иссл-ия "' + dds_arr_iss()[ i, 1 ] + '" не в I-ом этапе (> 10 дней)' )
          Elseif Empty( &mvart )
            fl := func_error( 4, 'Не введен врач в иссл-ии "' + dds_arr_iss()[ i, 1 ] + '"' )
          Else
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
              arr_iss[ i, 2 ] := -ret_new_spec( dds_arr_iss()[ i, 6, 1 ] )
              arr_iss[ i, 10 ] := &m1var // кровь проверяют в КДП2
            Endif
            arr_iss[ i, 4 ] := dds_arr_iss()[ i, 5, 1 ]
            arr_iss[ i, 5 ] := dds_arr_iss()[ i, 7, 1 ]
            // УЗИ органов репродуктивной системы {'8.2.2','8.2.3'}
            If Len( dds_arr_iss()[ i, 7 ] ) > 1 .and. mpol == 'Ж'
              arr_iss[ i, 5 ] := dds_arr_iss()[ i, 7, 2 ]
            Endif
            arr_iss[ i, 6 ] := mdef_diagnoz
            arr_iss[ i, 9 ] := &mvard
            //
            max_date1 := Max( max_date1, arr_iss[ i, 9 ] )
          Endif
        Endif
        If !fl
          exit
        Endif
      Next
      If !fl
        Loop
      Endif
      fl := .t.
      k := 0
      arr_osm1 := Array( Len( dds_arr_osm1() ), 10 )
      afillall( arr_osm1, 0 )
      For i := 1 To Len( dds_arr_osm1() )
        mvart := 'MTAB_NOMov' + lstr( i )
        mvara := 'MTAB_NOMoa' + lstr( i )
        mvard := 'MDATEo' + lstr( i )
        mvarz := 'MKOD_DIAGo' + lstr( i )
        if &mvard == mn_data
          k := i
        Endif
        If iif( Empty( dds_arr_osm1()[ i, 2 ] ), .t., dds_arr_osm1()[ i, 2 ] == mpol ) .and. ;
            Between( mvozrast, dds_arr_osm1()[ i, 3 ], dds_arr_osm1()[ i, 4 ] )
          If Empty( &mvard )
            fl := func_error( 4, 'Не введена дата осмотра I этапа "' + dds_arr_osm1()[ i, 1 ] + '"' )
          Elseif metap == 2 .and. &mvard > d12
            fl := func_error( 4, 'Дата осмотра "' + dds_arr_osm1()[ i, 1 ] + '" не в I-ом этапе (> 10 дней)' )
          Elseif Empty( &mvart )
            fl := func_error( 4, 'Не введен врач в осмотре I этапа  "' + dds_arr_osm1()[ i, 1 ] + '"' )
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
            arr_osm1[ i, 4 ] := dds_arr_osm1()[ i, 5, 1 ]
            arr_osm1[ i, 5 ] := dds_arr_osm1()[ i, 7, 1 ]
            // 'педиатр','',0,17,{68,57},{1134,1110},{'2.83.14','2.83.15'}
            If Len( dds_arr_osm1()[ i, 5 ] ) == 2 .and. Len( dds_arr_osm1()[ i, 6 ] ) == 2 ;
                .and. Len( dds_arr_osm1()[ i, 7 ] ) == 2 ;
                .and. dds_arr_osm1()[ i, 6, 2 ] == ret_old_prvs( arr_osm1[ i, 2 ] )
              arr_osm1[ i, 4 ] := dds_arr_osm1()[ i, 5, 2 ]
              arr_osm1[ i, 5 ] := dds_arr_osm1()[ i, 7, 2 ]
            Endif
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
            max_date1 := Max( max_date1, arr_osm1[ i, 9 ] )
          Endif
        Endif
        If !fl
          exit
        Endif
      Next
      If !fl
        Loop
      Endif
      If emptyall( arr_osm1[ Len( dds_arr_osm1() ), 1 ], arr_osm1[ Len( dds_arr_osm1() ), 9 ] )
        fl := func_error( 4, 'Не введён педиатр (врач общей практики) в осмотрах I этапа' )
      Elseif arr_osm1[ Len( dds_arr_osm1() ), 9 ] < max_date1
        fl := func_error( 4, 'Педиатр (врач общей практики) на I этапе должен проводить осмотр последним!' )
      Endif
      If !fl
        Loop
      Endif
      num_screen := 3
      metap := 1
      fl := .t.
      For i := 7 To 8 // стоматолог и эндокринолог на 2 этапе
        mvart := 'MTAB_NOMov' + lstr( i )
        mvara := 'MTAB_NOMoa' + lstr( i )
        mvard := 'MDATEo' + lstr( i )
        mvarz := 'MKOD_DIAGo' + lstr( i )
        If !Between( mvozrast, dds_arr_osm1()[ i, 3 ], dds_arr_osm1()[ i, 4 ] )
          If !Empty( &mvard ) .and. Empty( &mvart )
            fl := func_error( 4, 'Не введен врач в осмотре II этапа  "' + dds_arr_osm1()[ i, 1 ] + '"' )
          Elseif !Empty( &mvart ) .and. Empty( &mvard )
            fl := func_error( 4, 'Не введена дата осмотра II этапа "' + dds_arr_osm1()[ i, 1 ] + '"' )
          Elseif !emptyany( &mvard, &mvart )
            metap := 2
            if &mvard < max_date1
              fl := func_error( 4, 'Дата осмотра II этапа "' + dds_arr_osm1()[ i, 1 ] + '" внутри I этапа' )
            Endif
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
            arr_osm1[ i, 4 ] := dds_arr_osm1()[ i, 5, 1 ]
            arr_osm1[ i, 5 ] := dds_arr_osm1()[ i, 7, 1 ]
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
            max_date2 := Max( max_date2, arr_osm1[ i, 9 ] )
          Endif
        Endif
        If !fl
          exit
        Endif
      Next
      If !fl
        Loop
      Endif
      arr_osm2 := Array( Len( dds_arr_osm2() ), 10 ) ; afillall( arr_osm2, 0 )
      For i := 1 To Len( dds_arr_osm2() )
        mvart := 'MTAB_NOM2ov' + lstr( i )
        mvara := 'MTAB_NOM2oa' + lstr( i )
        mvard := 'MDATE2o' + lstr( i )
        mvarz := 'MKOD_DIAG2o' + lstr( i )
        arr_osm2[ i, 4 ] := dds_arr_osm2()[ i, 5, 1 ]
        If arr_osm2[ i, 4 ] == 12 .and. m1onko8 == 3
          &mvart := -1
        Elseif arr_osm2[ i, 4 ] == 18 .and. m1onko10 == 3
          &mvart := -1
        Endif
        If !Empty( &mvard ) .and. Empty( &mvart )
          fl := func_error( 4, 'Не введен врач в осмотре II этапа  "' + dds_arr_osm2()[ i, 1 ] + '"' )
        Elseif !Empty( &mvart ) .and. Empty( &mvard )
          fl := func_error( 4, 'Не введена дата осмотра II этапа "' + dds_arr_osm2()[ i, 1 ] + '"' )
        Elseif !emptyany( &mvard, &mvart )
          metap := 2
          if &mvard < max_date1
            fl := func_error( 4, 'Дата осмотра II этапа "' + dds_arr_osm2()[ i, 1 ] + '" внутри I этапа' )
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
            arr_osm2[ i, 2 ] := -ret_new_spec( dds_arr_osm2()[ i, 6, 1 ] )
            arr_osm2[ i, 10 ] := 3
          Endif
          arr_osm2[ i, 5 ] := dds_arr_osm2()[ i, 7, 1 ]
          // 'педиатр','',0,17,{68,57},{1134,1110},{'2.83.14','2.83.15'}
          If Len( dds_arr_osm2()[ i, 5 ] ) == 2 .and. Len( dds_arr_osm2()[ i, 6 ] ) == 2 ;
              .and. Len( dds_arr_osm2()[ i, 7 ] ) == 2 ;
              .and. ret_new_spec( dds_arr_osm2()[ i, 6, 2 ] ) == arr_osm2[ i, 2 ]
            arr_osm2[ i, 4 ] := dds_arr_osm2()[ i, 5, 2 ]
            arr_osm2[ i, 5 ] := dds_arr_osm2()[ i, 7, 2 ]
          Endif
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
          arr_osm2[ i, 9 ] := &mvard
          max_date2 := Max( max_date2, arr_osm2[ i, 9 ] )
        Endif
        If !fl ; exit ; Endif
      Next
      If fl .and. metap == 2
        If emptyall( arr_osm2[ Len( dds_arr_osm2() ), 1 ], arr_osm2[ Len( dds_arr_osm2() ), 9 ] )
          fl := func_error( 4, 'Не введён педиатр (врач общей практики) в осмотрах II этапа' )
        Elseif arr_osm1[ Len( dds_arr_osm1() ), 9 ] == arr_osm2[ Len( dds_arr_osm2() ), 9 ]
          fl := func_error( 4, 'Педиатры на I и II этапах провели осмотры в один день!' )
        Elseif arr_osm2[ Len( dds_arr_osm2() ), 9 ] < max_date2
          fl := func_error( 4, 'Педиатр (врач общей практики) на II этапе должен проводить осмотр последним!' )
        Endif
      Endif
      If !fl
        Loop
      Endif
      num_screen := 4
      If !Between( mGRUPPA_DO, 1, 5 )
        func_error( 4, 'ГРУППА состояния ЗДОРОВЬЯ ДО проведения диспансеризации д.б. от 1 до 5' )
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
          pole_1pervich := 'm1diag_16_' + lstr( i ) + '_2' // 0,1
          pole_1dispans := 'm1diag_16_' + lstr( i ) + '_3' // mm_dispans := {{'ранее',1},{'впервые',2},{'не уст.',0}}
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
          adiag_talon[ i * 2  ] := arr_diag[ i, 3 ]
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
          If !fl ; exit ; Endif
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
        func_error( 4, 'ГРУППА состояния ЗДОРОВЬЯ по результатам проведения диспансеризации - от 1 до 5' )
        Loop
      Endif
      //
      err_date_diap( mn_data, 'Дата начала лечения' )
      err_date_diap( mk_data, 'Дата окончания лечения' )
      //
      RestScreen( buf )
      If mem_op_out == 2 .and. yes_parol
        box_shadow( 19, 10, 22, 69, cColorStMsg )
        str_center( 20, 'Оператор "' + AllTrim( hb_user_curUser:FIO ) + '".', cColorSt2Msg )
        str_center( 21, 'Ввод данных за ' + date_month( sys_date ), cColorStMsg )
      Endif
      mywait( 'Ждите. Производится запись листа учёта...' )
      m1lis := 0
      If !is_disp_19 .and. glob_yes_kdp2()[ tip_lu ]
        For i := 1 To Len( dds_arr_iss() )
          If ValType( arr_iss[ i, 9 ] ) == 'D' .and. arr_iss[ i, 9 ] >= mn_data .and. Len( arr_iss[ i ] ) > 9 ;
              .and. ValType( arr_iss[ i, 10 ] ) == 'N' .and. arr_iss[ i, 10 ] > 0
            m1lis := arr_iss[ i, 10 ] // в рамках диспансеризации отправили в КДП2
          Endif
        Next
      Endif
      //
      If metap == 1
        For i := 1 To Len( dds_arr_osm1() )
          If ValType( arr_osm1[ i, 5 ] ) == 'C' .and. Left( arr_osm1[ i, 5 ], 5 ) == '2.83.'
            If eq_any( AllTrim( arr_osm1[ i, 5 ] ), '2.83.14', '2.83.15' ) // педиатр, врач общей практики
              arr_osm1[ i, 5 ] := '2.3.2'
            Else
              arr_osm1[ i, 5 ] := '2.3.1'
            Endif
          Endif
        Next
        AAdd( arr_osm1, Array( 10 ) ) ; i := Len( dds_arr_osm1() ) + 1
        arr_osm1[ i, 1 ] := arr_osm1[ i - 1, 1 ]
        arr_osm1[ i, 2 ] := arr_osm1[ i - 1, 2 ]
        arr_osm1[ i, 3 ] := arr_osm1[ i - 1, 3 ]
        arr_osm1[ i, 4 ] := arr_osm1[ i - 1, 4 ]
        arr_osm1[ i, 5 ] := ret_shifr_zs_dds( tip_lu )
        arr_osm1[ i, 6 ] := arr_osm1[ i - 1, 6 ]
        arr_osm1[ i, 9 ] := mn_data
        m1vrach  := arr_osm1[ i, 1 ]
        m1prvs   := arr_osm1[ i, 2 ]
        m1PROFIL := arr_osm1[ i, 4 ]
        // MKOD_DIAG := padr(arr_osm1[i,6],6)
      Else  // metap := 2
        If m1lis > 0 // услуги заменим на аналогичные шифры без гематологии
          For i := 1 To Len( arr_osm1 )
            If ValType( arr_osm1[ i, 5 ] ) == 'C' .and. ( j := AScan( dds_arr_osmotr_KDP2(), {| x| x[ 1 ] == arr_osm1[ i, 5 ] } ) ) > 0
              arr_osm1[ i, 5 ] := dds_arr_osmotr_KDP2()[ j, 2 ]
            Endif
          Next
          For i := 1 To Len( arr_osm2 )
            If ValType( arr_osm2[ i, 5 ] ) == 'C' .and. ( j := AScan( dds_arr_osmotr_KDP2(), {| x| x[ 1 ] == arr_osm2[ i, 5 ] } ) ) > 0
              arr_osm2[ i, 5 ] := dds_arr_osmotr_KDP2()[ j, 2 ]
            Endif
          Next
        Endif
        For i := 1 To Len( arr_osm2 )
          If arr_osm2[ i, 10 ] == 3 // если услуга оказана в ВОКОД
            arr_osm2[ i, 5 ] := '2.3.1'
          Endif
        Next
        If tip_lu == TIP_LU_DDSOP // дли детей-сирот под опекой вместо услуг '2.83.*' сделаем '2.87.*'
          For i := 1 To Len( dds_arr_osm1() )
            If ValType( arr_osm1[ i, 5 ] ) == 'C' .and. Left( arr_osm1[ i, 5 ], 5 ) == '2.83.'
              arr_osm1[ i, 5 ] := '2.87.' + SubStr( arr_osm1[ i, 5 ], 6 )
            Endif
          Next
          For i := 1 To Len( dds_arr_osm2() )
            If ValType( arr_osm2[ i, 5 ] ) == 'C' .and. Left( arr_osm2[ i, 5 ], 5 ) == '2.83.'
              arr_osm2[ i, 5 ] := '2.87.' + SubStr( arr_osm2[ i, 5 ], 6 )
            Endif
          Next
        Endif
        i := Len( dds_arr_osm2() )
        m1vrach  := arr_osm2[ i, 1 ]
        m1prvs   := arr_osm2[ i, 2 ]
        m1PROFIL := arr_osm2[ i, 4 ]
        // MKOD_DIAG := padr(arr_osm2[i,6],6)
      Endif
      make_diagp( 2 )  // сделать 'пятизначные' диагнозы
      //
      use_base( 'lusl' )
      use_base( 'luslc' )
      use_base( 'uslugi' )
      r_use( dir_server() + 'uslugi1', { dir_server() + 'uslugi1', ;
        dir_server() + 'uslugi1s' }, 'USL1' )
      Private mu_cena
      mcena_1 := 0
      arr_usl_dop := {}
      glob_podr := '' ; glob_otd_dep := 0
      For i := 1 To Len( arr_iss )
        If ValType( arr_iss[ i, 5 ] ) == 'C'
          arr_iss[ i, 7 ] := foundourusluga( arr_iss[ i, 5 ], mk_data, arr_iss[ i, 4 ], M1VZROS_REB, @mu_cena )
          arr_iss[ i, 8 ] := mu_cena
          mcena_1 += mu_cena
          AAdd( arr_usl_dop, arr_iss[ i ] )
        Endif
      Next
      For i := 1 To Len( arr_osm1 )
        If ValType( arr_osm1[ i, 5 ] ) == 'C'
          arr_osm1[ i, 7 ] := foundourusluga( arr_osm1[ i, 5 ], mk_data, arr_osm1[ i, 4 ], M1VZROS_REB, @mu_cena )
          arr_osm1[ i, 8 ] := mu_cena
          mcena_1 += mu_cena
          AAdd( arr_usl_dop, arr_osm1[ i ] )
        Endif
      Next
      If metap == 2
        For i := 1 To Len( arr_osm2 )
          If ValType( arr_osm2[ i, 5 ] ) == 'C'
            arr_osm2[ i, 7 ] := foundourusluga( arr_osm2[ i, 5 ], mk_data, arr_osm2[ i, 4 ], M1VZROS_REB, @mu_cena )
            arr_osm2[ i, 8 ] := mu_cena
            mcena_1 += mu_cena
            AAdd( arr_usl_dop, arr_osm2[ i ] )
          Endif
        Next
      Endif
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
      If m1stacionar > 0
        st_stacionar := m1stacionar
      Endif
      st_kateg_uch := m1kateg_uch
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
      human->KOD_DIAG   := mkod_diag     // шифр 1-ой осн.болезни
      human->KOD_DIAG2  := MKOD_DIAG2    // шифр 2-ой осн.болезни
      human->KOD_DIAG3  := MKOD_DIAG3    // шифр 3-ой осн.болезни
      human->KOD_DIAG4  := MKOD_DIAG4    // шифр 4-ой осн.болезни
      human->SOPUT_B1   := MSOPUT_B1     // шифр 1-ой сопутствующей болезни
      human->SOPUT_B2   := MSOPUT_B2     // шифр 2-ой сопутствующей болезни
      human->SOPUT_B3   := MSOPUT_B3     // шифр 3-ой сопутствующей болезни
      human->SOPUT_B4   := MSOPUT_B4     // шифр 4-ой сопутствующей болезни
      human->diag_plus  := mdiag_plus    //
      human->ZA_SMO     := m1stacionar
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
      human->ishod      := 100 + metap
      human->OBRASHEN   := '' // <Признак подозрения на ЗНО>: - всегда указывается <0>iif(m1DS_ONK == 1, '1', ' ')
      human->bolnich    := 0
      human->date_b_1   := ''
      human->date_b_2   := ''
      human_->RODIT_DR  := CToD( '' )
      human_->RODIT_POL := ''
      s := '' ; AEval( adiag_talon, {| x| s += Str( x, 1 ) } )
      human_->DISPANS   := s
      human_->STATUS_ST := ''
      human_->POVOD     := 6 // {'2.2-Диспансеризация',6,'2.2'},;
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
      human_->IDSP      := m1IDSP
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
        g_use( dir_server() + 'mo_hismo',, 'SN' )
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
        hu_->kod_diag := arr_usl_dop[ i, 6 ]
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
      save_arr_dds( mkod )
      write_work_oper( glob_task, OPER_LIST, iif( Loc_kod == 0, 1, 2 ), 1, count_edit )
      fl_write_sluch := .t.
      dbCloseAll()
      stat_msg( 'Запись завершена!', .f. )
    Endif
    Exit
  Enddo
  dbCloseAll()
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
