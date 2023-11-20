#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 27.06.23 ДДС - добавление или редактирование случая (листа учета)
Function oms_sluch_DDS(tip_lu,Loc_kod,kod_kartotek,f_print)
  // tip_lu - TIP_LU_DDS или TIP_LU_DDSOP
  // Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  // f_print - наименование функции для печати
  Static st_N_DATA, st_K_DATA,;
         st_stacionar := 0, st_kateg_uch := 0, st_mo_pr := '      '
  Local L_BEGIN_RSLT := iif(tip_lu == TIP_LU_DDS, 320, 346)
  Local bg := {|o,k| get_MKB10(o,k,.t.) }, arr_del := {}, mrec_hu := 0,;
        buf := savescreen(), tmp_color := setcolor(), a_smert := {},;
        p_uch_doc := "@!", pic_diag := "@K@!", arr_usl := {},;
        i, j, k, s, colget_menu := "R/W", colgetImenu := "R/BG",;
        pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod,;
        tmp_help := chm_help_code, fl_write_sluch := .f.
  //
  Default st_N_DATA TO sys_date, st_K_DATA TO sys_date
  Default Loc_kod TO 0, kod_kartotek TO 0, f_print TO ""
  //
  if kod_kartotek == 0 // добавление в картотеку
    if (kod_kartotek := edit_kartotek(0,,,.t.)) == 0
      return NIL
    endif
  endif
  chm_help_code := 3002
  Private mfio := space(50), mpol, mdate_r, madres, mvozrast,;
    M1VZROS_REB, MVZROS_REB, m1novor := 0,;
    m1company := 0, mcompany, mm_company,;
    mkomu, M1KOMU := 0, M1STR_CRB := 0,; // 0-ОМС,1-компании,3-комитеты/ЛПУ,5-личный счет
    msmo := "34007", rec_inogSMO := 0,;
    mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100),;
    mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20)
  Private mkod := Loc_kod, mtip_h, is_talon := .f., is_disp_19 := .t.,;
          mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
    M1LPU := glob_uch[1], MLPU,;
    M1OTD := glob_otd[1], MOTD,;
    M1FIO_KART := 1, MFIO_KART,;
    MUCH_DOC    := space(10)         ,; // вид и номер учетного документа
    mmobilbr, m1mobilbr := 0,;
    MKOD_DIAG   := space(5)          ,; // шифр 1-ой осн.болезни
    MKOD_DIAG2  := space(5)          ,; // шифр 2-ой осн.болезни
    MKOD_DIAG3  := space(5)          ,; // шифр 3-ой осн.болезни
    MKOD_DIAG4  := space(5)          ,; // шифр 4-ой осн.болезни
    MSOPUT_B1   := space(5)          ,; // шифр 1-ой сопутствующей болезни
    MSOPUT_B2   := space(5)          ,; // шифр 2-ой сопутствующей болезни
    MSOPUT_B3   := space(5)          ,; // шифр 3-ой сопутствующей болезни
    MSOPUT_B4   := space(5)          ,; // шифр 4-ой сопутствующей болезни
    MDIAG_PLUS  := space(8)          ,; // дополнения к диагнозам
    adiag_talon[16]                  ,; // из статталона к диагнозам
    m1rslt  := 321      ,; // результат (присвоена I группа здоровья)
    m1ishod := 306      ,; // исход
    MN_DATA := st_N_DATA         ,; // дата начала лечения
    MK_DATA := st_K_DATA         ,; // дата окончания лечения
    MVRACH := space(10)         ,; // фамилия и инициалы лечащего врача
    M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0,; // код, таб.№ и спец-ть лечащего врача
    m1povod  := 4,;   // Профилактический
    m1travma := 0, ;
    m1USL_OK :=  3,; // поликлиника
    m1VIDPOM :=  1,; // первичная
    m1PROFIL := 68,; // педиатрия
    m1IDSP   := 11   // диспансеризация
  //
  Private mm_kateg_uch := {{"ребенок-сирота",0},;
                           {"ребенок, оставшийся без попечения родителей",1},;
                           {"ребенок, находящийся в трудной жизненной ситуации",2},;
                           {"нет категории",3}}
  Private mm_gde_nahod := {{"в стационарном учреждении",0},;
                           {"под опекой",1},;
                           {"под попечительством",2},;
                           {"передан в приемную семью",3},;
                           {"передан в патронатную семью",4},;
                           {"усыновлен (удочерена)",5},;
                           {"другое",6}}
  Private mm_gde_nahod1 := aclone(mm_gde_nahod)
  Private mm_prich_vyb := {{"не выбыл",0},;
                           {"опека",1},;
                           {"попечительство",2},;
                           {"усыновление (удочерение)",3},;
                           {"передан в приемную семью",4},;
                           {"передан в патронатную семью",5},;
                           {"выбыл в другое стационарное учреждение",6},;
                           {"выбыл по возрасту",7},;
                           {"смерть",8},;
                           {"другое",9}}
  Private mm_fiz_razv := {{"нормальное",0},;
                          {"с отклонениями",1}}
  Private mm_fiz_razv1 := {{"нет    ",0},;
                           {"дефицит",1},;
                           {"избыток",2}}
  Private mm_fiz_razv2 := {{"нет    ",0},;
                           {"низкий ",1},;
                           {"высокий",2}}
  Private mm_psih2 := {{"норма",0},{"отклонение",1}}
  Private mm_142me3 := {{"регулярные",0},;
                        {"нерегулярные",1}}
  Private mm_142me4 := {{"обильные",0},;
                        {"умеренные",1},;
                        {"скудные",2}}
  Private mm_142me5 := {{"болезненные",0},;
                        {"безболезненные",1}}
  Private mm_dispans := {{"ранее",1},{"впервые",2},{"не уст.",0}}
  Private mm_usl := {{"амб.",0},{"дн/с",1},{"стац",2}}
  Private mm_uch := {{"МУЗ ",1},{"ГУЗ ",0},{"фед.",2},{"част",3}}
  Private mm_uch1 := aclone(mm_uch)
  aadd(mm_uch1,{"сан.",4})
  Private mm_invalid2 := {{"с рождения",0},{"приобретенная",1}}
  Private mm_invalid5 := {{"некоторые инфекционные и паразитарные,",1},;
                          {" из них: туберкулез,",101},;
                          {"         сифилис,",201},;
                          {"         ВИЧ-инфекция;",301},;
                          {"новообразования;",2},;
                          {"болезни крови, кроветворных органов ...",3},;
                          {"болезни эндокринной системы ...",4},;
                          {" из них: сахарный диабет;",104},;
                          {"психические расстройства и расстройства поведения,",5},;
                          {" в том числе умственная отсталость;",105},;
                          {"болезни нервной системы,",6},;
                          {" из них: церебральный паралич,",106},;
                          {"         другие паралитические синдромы;",206},;
                          {"болезни глаза и его придаточного аппарата;",7},;
                          {"болезни уха и сосцевидного отростка;",8},;
                          {"болезни системы кровообращения;",9},;
                          {"болезни органов дыхания,",10},;
                          {" из них: астма,",110},;
                          {"         астматический статус;",210},;
                          {"болезни органов пищеварения;",11},;
                          {"болезни кожи и подкожной клетчатки;",12},;
                          {"болезни костно-мышечной системы и соединительной ткани;",13},;
                          {"болезни мочеполовой системы;",14},;
                          {"отдельные состояния, возникающие в перинатальном периоде;",15},;
                          {"врожденные аномалии,",16},;
                          {" из них: аномалии нервной системы,",116},;
                          {"         аномалии системы кровообращения,",216},;
                          {"         аномалии опорно-двигательного аппарата;",316},;
                          {"последствия травм, отравлений и др.",17}}
  Private mm_invalid6 := {{"умственные",1},;
                          {"другие психологические",2},;
                          {"языковые и речевые",3},;
                          {"слуховые и вестибулярные",4},;
                          {"зрительные",5},;
                          {"висцеральные и метаболические расстройства питания",6},;
                          {"двигательные",7},;
                          {"уродующие",8},;
                          {"общие и генерализованные",9}}
  Private mm_invalid8 := {{"полностью",1},;
                          {"частично",2},;
                          {"начата",3},;
                          {"не выполнена",0}}
  Private mm_privivki1 := {{"привит по возрасту",0},;
                           {"не привит по медицинским показаниям",1},;
                           {"не привит по другим причинам",2}}
  Private mm_privivki2 := {{"полностью",1},;
                           {"частично",2}}
  //
  Private mstacionar, m1stacionar := st_stacionar,; // код стационара
          metap := 1, mshifr_zs := "",;
          mkateg_uch, m1kateg_uch := st_kateg_uch,; // Категория учета ребенка:
          mgde_nahod, m1gde_nahod := iif(tip_lu==TIP_LU_DDS,0,1),; // На момент проведения диспансеризации находится
          mdate_post := ctod(""),; // Дата поступления в стационарное учреждение
          mprich_vyb, m1prich_vyb := 0,; // Причина выбытия из стационарного учреждения
          mDATE_VYB := ctod(""),;   // Дата выбытия
          mPRICH_OTS := space(70),; // причина отсутствия на момент проведения диспансеризации
          mMO_PR := space(10), m1MO_PR := st_mo_pr,; // код МО прикрепления
          mWEIGHT := 0,;   // вес в кг
          mHEIGHT := 0,;   // рост в см
          mPER_HEAD := 0,; // окружность головы в см
          mfiz_razv, m1FIZ_RAZV := 0,; // физическое развитие
          mfiz_razv1, m1FIZ_RAZV1 := 0,; // отклонение массы тела
          mfiz_razv2, m1FIZ_RAZV2 := 0,; // отклонение роста
          m1psih11 := 0,;  // познавательная функция (возраст развития)
          m1psih12 := 0,;  // моторная функция (возраст развития)
          m1psih13 := 0,;  // эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития)
          m1psih14 := 0,;  // предречевое и речевое развитие (возраст развития)
          mpsih21, m1psih21 := 0,;  // Психомоторная сфера: (норма, отклонение)
          mpsih22, m1psih22 := 0,;  // Интеллект: (норма, отклонение)
          mpsih23, m1psih23 := 0,;  // Эмоционально-вегетативная сфера: (норма, отклонение)
          m141p   := 0,; // Половая формула мальчика P
          m141ax  := 0,; // Половая формула мальчика Ax
          m141fa  := 0,; // Половая формула мальчика Fa
          m142p   := 0,; // Половая формула девочки P
          m142ax  := 0,; // Половая формула девочки Ax
          m142ma  := 0,; // Половая формула девочки Ma
          m142me  := 0,; // Половая формула девочки Me
          m142me1 := 0,; // Половая формула девочки - menarhe (лет)
          m142me2 := 0,; // Половая формула девочки - menarhe (месяцев)
          m142me3, m1142me3 := 0,; // Половая формула девочки - menses (характеристика):
          m142me4, m1142me4 := 1,; // Половая формула девочки - menses (характеристика):
          m142me5, m1142me5 := 1,; // Половая формула девочки - menses (характеристика):
          mdiag_15_1, m1diag_15_1 := 1,; // Состояние здоровья до проведения диспансеризации-Практически здоров
          mdiag_15[5,14],; //
          mGRUPPA_DO := 0,; // группа здоровья до дисп-ии
          mdiag_16_1, m1diag_16_1 := 1,; // Состояние здоровья по результатам проведения диспансеризации (Практически здоров)
          mdiag_16[5,16],; //
          minvalid[8],;  // раздел 16.7
          mGRUPPA := 0,;    // группа здоровья после дисп-ии
          mPRIVIVKI[3],; // Проведение профилактических прививок
          mrek_form := space(255),; // "C100",Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой
          mrek_disp := space(255),; // "C100",Рекомендации по диспансерному наблюдению, лечению, медицинской реабилитации и санаторно-курортному лечению с указанием диагноза (код МКБ), вида медицинской организации и специальности (должности) врача
          mstep2, m1step2 := 0
  Private minvalid1, m1invalid1 := 0,;
          minvalid2, m1invalid2 := 0,;
          minvalid3 := ctod(""), minvalid4 := ctod(""),;
          minvalid5, m1invalid5 := 0,;
          minvalid6, m1invalid6 := 0,;
          minvalid7 := ctod(""),;
          minvalid8, m1invalid8 := 0
  Private mprivivki1, m1privivki1 := 0,;
          mprivivki2, m1privivki2 := 0,;
          mprivivki3 := space(100)
  Private mvar, m1var, m1lis := 0, m1onko8 := 0, monko8, m1onko10 := 0, monko10
  //Private mDS_ONK, m1DS_ONK := 0 // Признак подозрения на злокачественное новообразование
  Private mdopo_na, m1dopo_na := 0
  Private mm_dopo_na := {{"лаб.диагностика",1},{"инстр.диагностика",2},{"лучевая диагностика",3},{"КТ, МРТ, ангиография",4}}
  Private gl_arr := {;  // для битовых полей
    {"dopo_na","N",10,0,,,,{|x|inieditspr(A__MENUBIT,mm_dopo_na,x)} };
   }
  Private mnapr_v_mo, m1napr_v_mo := 0, ;
          mm_napr_v_mo := {{"-- нет --",0},{"в нашу МО",1},{"в иную МО",2}}, ;
          arr_mo_spec := {}, ma_mo_spec, m1a_mo_spec := 1
  Private mnapr_stac, m1napr_stac := 0, ;
          mm_napr_stac := {{"--- нет ---",0},{"в стационар",1},{"в дн. стац.",2}}, ;
          mprofil_stac, m1profil_stac := 0
  Private mnapr_reab, m1napr_reab := 0, mprofil_kojki, m1profil_kojki := 0

  private mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

  //
  for i := 1 to 5
    for k := 1 to 14
      s := "diag_15_"+lstr(i)+"_"+lstr(k)
      mvar := "m"+s
      if k == 1
        Private &mvar := space(6)
      else
        m1var := "m1"+s
        Private &m1var := 0
        Private &mvar := space(4)
      endif
    next
  next
  //
  for i := 1 to 5
    for k := 1 to 16
      s := "diag_16_"+lstr(i)+"_"+lstr(k)
      mvar := "m"+s
      if k == 1
        Private &mvar := space(6)
      else
        m1var := "m1"+s
        Private &m1var := 0
        Private &mvar := space(3)
      endif
    next
  next
  for i := 1 to count_dds_arr_iss
    mvar := "MTAB_NOMiv"+lstr(i)
    Private &mvar := 0
    mvar := "MTAB_NOMia"+lstr(i)
    Private &mvar := 0
    mvar := "MDATEi"+lstr(i)
    Private &mvar := ctod("")
    mvar := "MREZi"+lstr(i)
    Private &mvar := space(17)
    m1var := "M1LIS"+lstr(i)
    Private &m1var := 0
    mvar := "MLIS"+lstr(i)
    Private &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
  next
  for i := 1 to count_dds_arr_osm1
    mvar := "MTAB_NOMov"+lstr(i)
    Private &mvar := 0
    mvar := "MTAB_NOMoa"+lstr(i)
    Private &mvar := 0
    mvar := "MDATEo"+lstr(i)
    Private &mvar := ctod("")
    mvar := "MKOD_DIAGo"+lstr(i)
    Private &mvar := space(6)
  next
  for i := 1 to count_dds_arr_osm2
    mvar := "MTAB_NOM2ov"+lstr(i)
    Private &mvar := 0
    mvar := "MTAB_NOM2oa"+lstr(i)
    Private &mvar := 0
    mvar := "MDATE2o"+lstr(i)
    Private &mvar := ctod("")
    mvar := "MKOD_DIAG2o"+lstr(i)
    Private &mvar := space(6)
  next
  //
  afill(adiag_talon,0)
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_
  if mkod_k > 0
    R_Use(dir_server+"kartote2",,"KART2")
    goto (mkod_k)
    R_Use(dir_server+"kartote_",,"KART_")
    goto (mkod_k)
    R_Use(dir_server+"kartotek",,"KART")
    goto (mkod_k)
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
    if kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    endif
    if eq_any(is_uchastok,1,3)
      MUCH_DOC := padr(amb_kartaN(),10)
    elseif mem_kodkrt == 2
      MUCH_DOC := padr(lstr(mkod_k),10)
    endif
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(1,,.t.) // открыть и закрыть
    endif
    // проверка исхода = СМЕРТЬ
    select HUMAN
    set index to (dir_server+"humankk")
    find (str(mkod_k,7))
    do while human->kod_k == mkod_k .and. !eof()
      if recno() != Loc_kod .and. is_death(human_->RSLT_NEW) .and. ;
                                   human_->oplata != 9 .and. human_->NOVOR == 0
        a_smert := {"Данный больной умер!",;
                    "Лечение с "+full_date(human->N_DATA)+;
                          " по "+full_date(human->K_DATA)}
        exit
      endif
      skip
    enddo
    set index to
  endif
  if Loc_kod > 0
    select HUMAN
    goto (Loc_kod)
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
    //if human->OBRASHEN == '1'
      //m1DS_ONK := 1
    //endif
    for i := 1 to 16
      adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
    next
    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    if empty(val(msmo := human_->SMO))
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    else
      m1komu := m1str_crb := 0
    endif
    m1okato    := human_->OKATO  // ОКАТО субъекта РФ территории страхования
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    m1stacionar:= human->ZA_SMO
    mcena_1    := human->CENA_1
    metap      := human->ishod-100
    mGRUPPA    := human_->RSLT_NEW-L_BEGIN_RSLT
    is_disp_19 := !(mk_data < 0d20191101)
    //
    larr := array(3,count_dds_arr_osm2) ; afillall(larr,0)
    mdate1 := mdate2 := ctod("")
    R_Use(dir_server+"uslugi",,"USL")
    use_base("human_u")
    find (str(Loc_kod,7))
    do while hu->kod == Loc_kod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
        lshifr := usl->shifr
      endif
      lshifr := alltrim(lshifr)
      if eq_any(left(lshifr,5),"70.5.","70.6.")
        mshifr_zs := lshifr
      else
        fl := .t.
        for i := 1 to count_dds_arr_iss
          if ascan(dds_arr_iss[i,7],lshifr) > 0 .and. empty(larr[1,i])
            fl := .f. ; larr[1,i] := hu->(recno()) ; exit
          endif
        next
        if fl
          for i := 1 to count_dds_arr_osm1
            if ascan(dds_arr_osm1[i,5],hu_->PROFIL) > 0 .and. empty(larr[2,i])
              fl := .f. ; larr[2,i] := hu->(recno())
              if i == count_dds_arr_osm1
                mdate1 := c4tod(hu->date_u)
              endif
              exit
            endif
          next
        endif
        if fl .and. metap == 2 // два этапа
          m1step2 := 1
          for i := 1 to count_dds_arr_osm2
            if ascan(dds_arr_osm2[i,5],hu_->PROFIL) > 0 .and. empty(larr[3,i])
              fl := .f. ; larr[3,i] := hu->(recno())
              if hu->is_edit == 3
                if hu_->PROFIL == 12
                  m1onko8 := 3
                elseif hu_->PROFIL == 18
                  m1onko10 := 3
                endif
              endif
              if i == count_dds_arr_osm2
                mdate2 := c4tod(hu->date_u)
              endif
              exit
            endif
          next
        endif
      endif
      aadd(arr_usl,hu->(recno()))
      select HU
      skip
    enddo
    if !emptyany(mdate1,mdate2) .and. mdate1 > mdate2 // если осмотр педиатра I этапа позднее педиатра II этапа
      k := larr[2,count_dds_arr_osm1] // запомнить
      larr[2,count_dds_arr_osm1] := larr[3,count_dds_arr_osm2]
      larr[3,count_dds_arr_osm2] := k // обменять значения
    endif
    R_Use(dir_server+"mo_pers",,"P2")
    for j := 1 to 3
      if j == 1
        _arr := dds_arr_iss  ; bukva := "i"
      elseif j == 2
        _arr := dds_arr_osm1 ; bukva := "o"
      else
        _arr := dds_arr_osm2 ; bukva := "2o"
      endif
      for i := 1 to len(_arr)
        if !empty(larr[j,i])
          hu->(dbGoto(larr[j,i]))
          if hu->kod_vr > 0
            p2->(dbGoto(hu->kod_vr))
            mvar := "MTAB_NOM"+bukva+"v"+lstr(i)
            &mvar := p2->tab_nom
          endif
          if hu->kod_as > 0
            p2->(dbGoto(hu->kod_as))
            mvar := "MTAB_NOM"+bukva+"a"+lstr(i)
            &mvar := p2->tab_nom
          endif
          mvar := "MDATE"+bukva+lstr(i)
          &mvar := c4tod(hu->date_u)
          if j == 1
            m1var := "m1lis"+lstr(i)
            if is_disp_19
              &m1var := 0
            elseif glob_yes_kdp2[tip_lu] .and. ascan(glob_arr_usl_LIS,dds_arr_iss[i,7,1]) > 0 .and. hu->is_edit > 0
              &m1var := hu->is_edit
            endif
            mvar := "mlis"+lstr(i)
            &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
          elseif !empty(hu_->kod_diag) .and. !(left(hu_->kod_diag,1)=="Z")
            mvar := "MKOD_DIAG"+bukva+lstr(i)
            &mvar := hu_->kod_diag
          endif
        endif
      next
    next
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(2,@rec_inogSMO,.t.) // открыть и закрыть
    endif
    read_arr_DDS(Loc_kod)
  endif
  if !(left(msmo,2) == '34') // не Волгоградская область
    m1ismo := msmo ; msmo := '34'
  endif
  is_talon := .t.
  close databases
  fv_date_r( iif(Loc_kod>0,mn_data,) )
  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  mlpu      := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
  motd      := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
  mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
  mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
  monko8    := inieditspr(A__MENUVERT, mm_vokod, m1onko8)
  monko10   := inieditspr(A__MENUVERT, mm_vokod, m1onko10)
  mismo     := init_ismo(m1ismo)
  f_valid_komu(,-1)
  if m1komu == 0
    m1company := int(val(msmo))
  elseif eq_any(m1komu,1,3)
    m1company := m1str_crb
  endif
  mcompany := inieditspr(A__MENUVERT, mm_company, m1company)
  if m1company == 34
    if !empty(mismo)
      mcompany := padr(mismo,38)
    elseif !empty(mnameismo)
      mcompany := padr(mnameismo,38)
    endif
  endif
  //
  if tip_lu == TIP_LU_DDS // На момент проведения диспансеризации находится
    m1gde_nahod := 0    // в стационаре
  else
    if m1gde_nahod == 0
      m1gde_nahod := 1
    endif
    mdate_post := ctod("")
    Del_Array(mm_gde_nahod,1)
  endif
  mmobilbr := inieditspr(A__MENUVERT, mm_danet, m1mobilbr)
  mstacionar := inieditspr(A__POPUPMENU, dir_server+"mo_stdds",m1stacionar)
  mkateg_uch := inieditspr(A__MENUVERT, mm_kateg_uch, m1kateg_uch)
  mgde_nahod := inieditspr(A__MENUVERT, mm_gde_nahod, m1gde_nahod)
  mprich_vyb := inieditspr(A__MENUVERT, mm_prich_vyb, m1prich_vyb)
  if !empty(m1MO_PR)
    mMO_PR := ret_mo(m1MO_PR)[_MO_SHORT_NAME]
  endif
  mfiz_razv  := inieditspr(A__MENUVERT, mm_fiz_razv,  m1FIZ_RAZV)
  mfiz_razv1 := inieditspr(A__MENUVERT, mm_fiz_razv1, m1FIZ_RAZV1)
  mfiz_razv2 := inieditspr(A__MENUVERT, mm_fiz_razv2, m1FIZ_RAZV2)
  mpsih21 := inieditspr(A__MENUVERT, mm_psih2, m1psih21)
  mpsih22 := inieditspr(A__MENUVERT, mm_psih2, m1psih22)
  mpsih23 := inieditspr(A__MENUVERT, mm_psih2, m1psih23)
  m142me3 := inieditspr(A__MENUVERT, mm_142me3, m1142me3)
  m142me4 := inieditspr(A__MENUVERT, mm_142me4, m1142me4)
  m142me5 := inieditspr(A__MENUVERT, mm_142me5, m1142me5)
  mdiag_15_1 := inieditspr(A__MENUVERT, mm_danet, m1diag_15_1)
  mdiag_16_1 := inieditspr(A__MENUVERT, mm_danet, m1diag_16_1)
  mstep2 := inieditspr(A__MENUVERT, mm_danet, m1step2)
  minvalid1 := inieditspr(A__MENUVERT, mm_danet,    m1invalid1)
  minvalid2 := inieditspr(A__MENUVERT, mm_invalid2, m1invalid2)
  minvalid5 := inieditspr(A__MENUVERT, mm_invalid5, m1invalid5)
  minvalid6 := inieditspr(A__MENUVERT, mm_invalid6, m1invalid6)
  minvalid8 := inieditspr(A__MENUVERT, mm_invalid8, m1invalid8)
  mprivivki1 := inieditspr(A__MENUVERT, mm_privivki1, m1privivki1)
  mprivivki2 := inieditspr(A__MENUVERT, mm_privivki2, m1privivki2)
  //mDS_ONK    := inieditspr(A__MENUVERT, mm_danet, M1DS_ONK)
  mdopo_na   := inieditspr(A__MENUBIT,  mm_dopo_na, m1dopo_na)
  mnapr_v_mo := inieditspr(A__MENUVERT, mm_napr_v_mo, m1napr_v_mo)
  if empty(arr_mo_spec)
    ma_mo_spec := "---"
  else
    ma_mo_spec := ""
    for i := 1 to len(arr_mo_spec)
      ma_mo_spec += lstr(arr_mo_spec[i])+","
    next
    ma_mo_spec := left(ma_mo_spec,len(ma_mo_spec)-1)
  endif
  mnapr_stac := inieditspr(A__MENUVERT, mm_napr_stac, m1napr_stac)
  mprofil_stac := inieditspr(A__MENUVERT, getV002(), m1profil_stac)
  mnapr_reab := inieditspr(A__MENUVERT, mm_danet, m1napr_reab)
  mprofil_kojki := inieditspr(A__MENUVERT, getV020(), m1profil_kojki)
  //
  if !empty(f_print)
    return &(f_print+"("+lstr(Loc_kod)+","+lstr(kod_kartotek)+","+lstr(mvozrast)+")")
  endif
  //
  str_1 := " случая диспансеризации детей-сирот"
  if Loc_kod == 0
    str_1 := "Добавление"+str_1
    mtip_h := yes_vypisan
  else
    str_1 := "Редактирование"+str_1
  endif
  setcolor(color8)
  @ 0,0 say padc(str_1,80) color "B/BG*"
  Private gl_area
  setcolor(cDataCGet)
  make_diagP(1)  // сделать "шестизначные" диагнозы
  Private num_screen := 1
  do while .t.
    close databases
    DispBegin()
    if num_screen == 5
      hS := 32 ; wS := 90
    else
      hS := 25 ; wS := 80
    endif
    SetMode(hS,wS)
    @ 0,0 say padc(str_1,wS) color "B/BG*"
    gl_area := {1,0,maxrow()-1,maxcol(),0}
    j := 1
    myclear(j)
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j,(wS-30) say padl("Лист учета № "+lstr(Loc_kod),29) color color14
    endif
    @ j,0 say "Экран "+lstr(num_screen) color color8
    if num_screen > 1
      is_disp_19 := !(mk_data < 0d20191101)
      s := alltrim(mfio)+" ("+lstr(mvozrast)+" "+s_let(mvozrast)+")"
      @ j,wS-len(s) say s color color14
    endif
    if num_screen == 1 //
      ++j; @ j,1 say "Учреждение" get mlpu when .f. color cDataCSay
           @ row(),col()+2 say "Отделение" get motd when .f. color cDataCSay
      //
      ++j; @ j,1 say "ФИО" get mfio_kart ;
           reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
           valid {|g,o| update_get("mkomu"),update_get("mcompany") }
      ++j; @ j,1 say "Принадлежность счёта" get mkomu ;
                 reader {|x|menu_reader(x,mm_komu,A__MENUVERT,,,.f.)} ;
                 valid {|g,o| f_valid_komu(g,o) } ;
                 color colget_menu
           @ row(),col()+1 say "==>" get mcompany ;
               reader {|x|menu_reader(x,mm_company,A__MENUVERT,,,.f.)} ;
               when m1komu < 5 ;
               valid {|g| func_valid_ismo(g,m1komu,38) }
      ++j; @ j,1 say "Полис ОМС: серия" get mspolis when m1komu == 0
           @ row(),col()+3 say "номер"  get mnpolis when m1komu == 0
           @ row(),col()+3 say "вид"    get mvidpolis ;
                        reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT,,,.f.)} ;
                        when m1komu == 0 ;
                        valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
      ++j; @ j,1 to j,78
      if tip_lu == TIP_LU_DDS
        ++j; @ j,1 say "Стационарное учреждение" get mstacionar reader ;
              {|x| menu_reader(x,;
                   {dir_server+"mo_stdds",,,,,color5,"Стационары, из которых проходит диспансеризация детей-сирот","B/W"},;
                   A__POPUPMENU,,,.f.);
              }
      endif
      ++j; @ j,1 say "Категория учета ребенка" get mkateg_uch ;
               reader {|x|menu_reader(x,mm_kateg_uch,A__MENUVERT,,,.f.)}
      if tip_lu == TIP_LU_DDS
        ++j; @ j,1 say "Дата поступления в стационарное учреждение" get mdate_post
      else
        ++j; @ j,1 say "На момент проведения диспансеризации находится" get mgde_nahod ;
                 reader {|x|menu_reader(x,mm_gde_nahod,A__MENUVERT,,,.f.)}
      endif
      ++j; @ j,1 say "Причина выбытия из стационарного учреждения" get mprich_vyb ;
               reader {|x|menu_reader(x,mm_prich_vyb,A__MENUVERT,,,.f.)} ;
               valid {|| iif(m1prich_vyb==0, mDATE_VYB:=ctod(""), nil), .t. }
      ++j; @ j,40 say "Дата выбытия" get mDATE_VYB when m1prich_vyb > 0
      ++j; @ j,1 say "Отсутствует на момент проведения диспансеризации" get mPRICH_OTS pict "@S29"
      ++j; @ j,1 to j,78
      ++j
      ++j; @ j,1 say "Сроки диспансеризации" get mn_data ;
                 valid {|g| f_k_data(g,1),;
                            iif(mvozrast < 18, nil, func_error(4,"Это взрослый пациент!")),;
                            .t.;
                       }
           @ row(),col()+1 say "-"   get mk_data valid {|g|f_k_data(g,2)}
           @ row(),col()+3 get mvzros_reb when .f. color cDataCSay
      ++j; @ j,1 say "№ амбулаторной карты" get much_doc picture "@!" ;
                 when !(is_uchastok == 1 .and. is_task(X_REGIST)) ;
                       .or. mem_edit_ist==2
      ++j
      ++j; @ j,1 say "Медосмотр проведён мобильной бригадой?" get mmobilbr ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
      ++j; @ j,1 say "МО прикрепления" get mMO_PR ;
                reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c)}},A__FUNCTION,,,.f.)}
      ++j; @ j,1 say "Вес" get mWEIGHT pict "999" ;
                 valid {|| iif(between(mWEIGHT,2,170),,func_error(4,"Неразумный вес")), .t.}
           @ row(),col()+1 say "кг, рост" get mHEIGHT pict "999" ;
                 valid {|| iif(between(mHEIGHT,40,250),,func_error(4,"Неразумный рост")), .t.}
           @ row(),col()+1 say "см, окружность головы" get mPER_HEAD  pict "999" ;
                 valid {|| iif(between(mPER_HEAD,10,100),,func_error(4,"Неразумный размер окружности головы")), .t.}
           @ row(),col()+1 say "см"
      ++j; @ j,1 say "Физическое развитие" get mfiz_razv ;
               reader {|x|menu_reader(x,mm_fiz_razv,A__MENUVERT,,,.f.)} ;
               valid {|| iif(m1FIZ_RAZV == 0, (mfiz_razv1:="нет    ",m1fiz_razv1:=0,;
                                               mfiz_razv2:="нет    ",m1fiz_razv2:=0), nil), .t. }
      ++j; @ j,10 say "отклонение массы тела" get mfiz_razv1 ;
               reader {|x|menu_reader(x,mm_fiz_razv1,A__MENUVERT,,,.f.)} ;
               when m1FIZ_RAZV == 1
           @ j,39 say ", роста" get mfiz_razv2 ;
               reader {|x|menu_reader(x,mm_fiz_razv2,A__MENUVERT,,,.f.)} ;
               when m1FIZ_RAZV == 1
      status_key("^<Esc>^ выход без записи ^<PgDn>^ на 2-ю страницу")
      if !empty(a_smert)
        n_message(a_smert,,"GR+/R","W+/R",,,"G+/R")
      endif
    elseif num_screen == 2 //
      fl_kdp2 := array(count_dds_arr_iss) ; afill(fl_kdp2,.f.)
      for i := 1 to count_dds_arr_iss
        mvar := "MDATEi"+lstr(i)
        if empty(&mvar)
          &mvar := mn_data
        endif
        if !is_disp_19 .and. glob_yes_kdp2[tip_lu] .and. ascan(glob_arr_usl_LIS,dds_arr_iss[i,7,1]) > 0
          fl_kdp2[i] := .t.
        endif
      next
      for i := 1 to count_dds_arr_osm1
        mvar := "MDATEo"+lstr(i)
        if empty(&mvar)
          &mvar := mn_data
        endif
      next
      ++j; @ j,1 say "I этап наименований исследований       Врач Ассис.  Дата     Результат" color "RB+/B"
      ++j; @ j,1 say "Клинический анализ мочи"
           @ j,39 get MTAB_NOMiv1 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMia1 pict "99999" valid {|g| v_kart_vrach(g) }
         else
           @ j-1,45 say space(6)
         endif
           @ j,51 get MDATEi1
           @ j,62 get MREZi1
      ++j; @ j,1 say "Клинический анализ крови"
         if fl_kdp2[2]
           @ j,34 get mlis2 reader {|x|menu_reader(x,mm_kdp2,A__MENUVERT,,,.f.)}
         endif
           @ j,39 get MTAB_NOMiv2 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMia2 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEi2
           @ j,62 get MREZi2
      ++j; @ j,1 say "Иссл-ние уровня глюкозы в крови"
         if fl_kdp2[3]
           @ j,34 get mlis3 reader {|x|menu_reader(x,mm_kdp2,A__MENUVERT,,,.f.)}
         endif
           @ j,39 get MTAB_NOMiv3 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMia3 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEi3
           @ j,62 get MREZi3
      ++j; @ j,1 say "Электрокардиография"
           @ j,39 get MTAB_NOMiv4 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMia4 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEi4
           @ j,62 get MREZi4
    if mvozrast >= 15
      ++j; @ j,1 say "Флюорография легких (с 15 лет)"
           @ j,39 get MTAB_NOMiv5 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMia5 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEi5
           @ j,62 get MREZi5
    endif
    if mvozrast < 1
      ++j; @ j,1 say "УЗИ гол.мозга/нейросонография(до 1г.)"
           @ j,39 get MTAB_NOMiv6 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMia6 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEi6
           @ j,62 get MREZi6
    endif
    if mvozrast >= 7
      ++j; @ j,1 say "УЗИ щитовидной железы (с 7 лет)"
           @ j,39 get MTAB_NOMiv7 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMia7 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEi7
           @ j,62 get MREZi7
    endif
      ++j; @ j,1 say "УЗИ сердца"
           @ j,39 get MTAB_NOMiv8 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMia8 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEi8
           @ j,62 get MREZi8
    if mvozrast < 1
      ++j; @ j,1 say "УЗИ тазобедренных суставов (до 1г.)"
           @ j,39 get MTAB_NOMiv9 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMia9 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEi9
           @ j,62 get MREZi9
    endif
      ++j; @ j,1 say "УЗИ органов брюшной полости"
           @ j,39 get MTAB_NOMiv10 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMia10 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEi10
           @ j,62 get MREZi10
    if mvozrast >= 7
      ++j; @ j,1 say "УЗИ органов репродуктивной системы"
           @ j,39 get MTAB_NOMiv11 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMia11 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEi11
           @ j,62 get MREZi11
    endif
      //
      //++j; @ j,1 say "I этап наименований осмотров           Врач Ассис.  Дата     Диагноз" color "RB+/B"
      ++j; @ j,1 say "I этап наименований осмотров           Врач Ассис.  Дата     " color "RB+/B"
      ++j; @ j,1 say "офтальмолог"
           @ j,39 get MTAB_NOMov1 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMoa1 pict "99999" valid {|g| v_kart_vrach(g) }
         else
           @ j-1,45 say space(6)
         endif
           @ j,51 get MDATEo1
           //@ j,62 get mkod_diago1 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      ++j; @ j,1 say "оториноларинголог"
           @ j,39 get MTAB_NOMov2 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMoa2 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEo2
           //@ j,62 get mkod_diago2 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      ++j; @ j,1 say "детский хирург"
           @ j,39 get MTAB_NOMov3 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMoa3 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEo3
           //@ j,62 get mkod_diago3 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      ++j; @ j,1 say "травматолог-ортопед"
           @ j,39 get MTAB_NOMov4 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMoa4 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEo4
           //@ j,62 get mkod_diago4 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
    if mpol == "Ж"
      ++j; @ j,1 say "акушер-гинеколог (девочки)"
           @ j,39 get MTAB_NOMov5 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMoa5 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEo5
           //@ j,62 get mkod_diago5 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
    endif
    if mpol == "М"
      ++j; @ j,1 say "детский уролог-андролог (мальчики)"
           @ j,39 get MTAB_NOMov6 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMoa6 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEo6
           //@ j,62 get mkod_diago6 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
    endif
    if mvozrast >= 3
      ++j; @ j,1 say "детский стоматолог (с 3 лет)"
           @ j,39 get MTAB_NOMov7 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMoa7 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEo7
           //@ j,62 get mkod_diago7 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
    elseif empty(MTAB_NOMov7)
      MDATEo7 := ctod("")
    endif
    if mvozrast >= 5
      ++j; @ j,1 say "детский эндокринолог (с 5 лет)"
           @ j,39 get MTAB_NOMov8 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMoa8 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEo8
           //@ j,62 get mkod_diago8 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
    elseif empty(MTAB_NOMov8)
      MDATEo8 := ctod("")
    endif
      ++j; @ j,1 say "невролог"
           @ j,39 get MTAB_NOMov9 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMoa9 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEo9
           //@ j,62 get mkod_diago9 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      ++j; @ j,1 say "психиатр"
           @ j,39 get MTAB_NOMov10 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMoa10 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEo10
           //@ j,62 get mkod_diago10 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      ++j; @ j,1 say "педиатр"
           @ j,39 get MTAB_NOMov11 pict "99999" valid {|g| v_kart_vrach(g) }
         if mem_por_ass > 0
           @ j,45 get MTAB_NOMoa11 pict "99999" valid {|g| v_kart_vrach(g) }
         endif
           @ j,51 get MDATEo11
           //@ j,62 get mkod_diago11 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      status_key("^<Esc>^ выход без записи ^<PgUp>^ на 1-ю страницу ^<PgDn>^ на 3-ю страницу")
    elseif num_screen == 3 //
      ++j; @ j,1 say "II этап диспансеризации детей-сирот и детей, находящихся в тяжелой жизненной"
      ++j; @ j,1 say "ситуации. Выберите, необходимо вводить врачебные осмотры II этапа?" get mstep2 ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
      ++j
      //++j; @ j,1 say " II этап наим. осмотров       Врач Ассис.  Дата     Диагноз" color "RB+/B"
      ++j; @ j,1 say " II этап наим. осмотров       Врач Ассис.  Дата     " color "RB+/B"
    if mvozrast < 3
      ++j; @ j,1 say "детский стоматолог до 3 лет"
           @ j,30 get MTAB_NOMov7 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOMoa7 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         else
           @ j-1,36 say space(6)
         endif
           @ j,42 get MDATEo7 when m1step2==1
           //@ j,53 get mkod_diago7 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) when m1step2==1
    endif
    if mvozrast < 5
      ++j; @ j,1 say "детский эндокринолог до 5 лет"
           @ j,30 get MTAB_NOMov8 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOMoa8 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         else
           @ j-1,36 say space(6)
         endif
           @ j,42 get MDATEo8 when m1step2==1
           //@ j,53 get mkod_diago8 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) when m1step2==1
    endif
      ++j; @ j,1 say "пульмонолог"
           @ j,30 get MTAB_NOM2ov1 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa1 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         else
           @ j-1,36 say space(6)
         endif
           @ j,42 get MDATE2o1 when m1step2==1
           //@ j,53 get mkod_diag2o1 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      ++j; @ j,1 say "дерматовенеролог"
           @ j,30 get MTAB_NOM2ov2 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa2 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         endif
           @ j,42 get MDATE2o2 when m1step2==1
           //@ j,53 get mkod_diag2o2 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      ++j; @ j,1 say "ревматолог"
           @ j,30 get MTAB_NOM2ov3 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa3 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         endif
           @ j,42 get MDATE2o3 when m1step2==1
           //@ j,53 get mkod_diag2o3 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      ++j; @ j,1 say "аллерголог-иммунолог"
           @ j,30 get MTAB_NOM2ov4 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa4 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         endif
           @ j,42 get MDATE2o4 when m1step2==1
           //@ j,53 get mkod_diag2o4 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      ++j; @ j,1 say "детский кардиолог"
           @ j,30 get MTAB_NOM2ov5 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa5 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         endif
           @ j,42 get MDATE2o5 when m1step2==1
           //@ j,53 get mkod_diag2o5 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      ++j; @ j,1 say "гастроэнтеролог"
           @ j,30 get MTAB_NOM2ov6 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa6 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         endif
           @ j,42 get MDATE2o6 when m1step2==1
           //@ j,53 get mkod_diag2o6 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      ++j; @ j,1 say "нефролог"
           @ j,30 get MTAB_NOM2ov7 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa7 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         endif
           @ j,42 get MDATE2o7 when m1step2==1
           //@ j,53 get mkod_diag2o7 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      ++j; @ j,1 say "гематолог"
           @ j,24 get monko8 reader {|x|menu_reader(x,mm_vokod,A__MENUVERT,,,.f.)} when m1step2==1
           @ j,30 get MTAB_NOM2ov8 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1 .and. m1onko8==0
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa8 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1 .and. m1onko8==0
         endif
           @ j,42 get MDATE2o8 when m1step2==1
           //@ j,53 get mkod_diag2o8 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      ++j; @ j,1 say "инфекционист"
           @ j,30 get MTAB_NOM2ov9 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa9 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         endif
           @ j,42 get MDATE2o9 when m1step2==1
           //@ j,53 get mkod_diag2o9 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      ++j; @ j,1 say "детский онколог"
           @ j,24 get monko10 reader {|x|menu_reader(x,mm_vokod,A__MENUVERT,,,.f.)} when m1step2==1
           @ j,30 get MTAB_NOM2ov10 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1 .and. m1onko10==0
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa10 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1 .and. m1onko10==0
         endif
           @ j,42 get MDATE2o10 when m1step2==1
           //@ j,53 get mkod_diag2o10 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      ++j; @ j,1 say "нейрохирург"
           @ j,30 get MTAB_NOM2ov11 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa11 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         endif
           @ j,42 get MDATE2o11 when m1step2==1
           //@ j,53 get mkod_diag2o11 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      ++j; @ j,1 say "колопроктолог"
           @ j,30 get MTAB_NOM2ov12 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa12 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         endif
           @ j,42 get MDATE2o12 when m1step2==1
           //@ j,53 get mkod_diag2o12 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      ++j; @ j,1 say "сердечно-сосудистый хирург"
           @ j,30 get MTAB_NOM2ov13 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa13 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         endif
           @ j,42 get MDATE2o13 when m1step2==1
           //@ j,53 get mkod_diag2o13 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      ++j; @ j,1 say "педиатр"
           @ j,30 get MTAB_NOM2ov14 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         if mem_por_ass > 0
           @ j,36 get MTAB_NOM2oa14 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
         endif
           @ j,42 get MDATE2o14 when m1step2==1
           //@ j,53 get mkod_diag2o14 picture pic_diag ;
           //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           //       when m1step2==1
      status_key("^<Esc>^ выход без записи ^<PgUp>^ на 2-ю страницу ^<PgDn>^ на 4-ю страницу")
    elseif num_screen == 4 //
    if mvozrast < 5
      ++j; @ j,1 say padc("Оценка психического развития (возраст развития):",78,"_")
      ++j; @ j,1 say "познавательная функция" get m1psih11 pict "99"
      ++j; @ j,1 say "моторная функция      " get m1psih12 pict "99"
      --j; @ j,30 say "эмоциональная и социальная    " get m1psih13 pict "99"
      ++j; @ j,30 say "предречевое и речевое развитие" get m1psih14 pict "99"
    else
      ++j; @ j,1 say padc("Оценка психического развития:",78,"_")
      ++j; @ j,1 say "психомоторная сфера" get mpsih21 reader {|x|menu_reader(x,mm_psih2,A__MENUVERT,,,.f.)}
      ++j; @ j,1 say "интеллект          " get mpsih22 reader {|x|menu_reader(x,mm_psih2,A__MENUVERT,,,.f.)}
      --j; @ j,40 say "эмоц.вегетативная сфера" get mpsih23 reader {|x|menu_reader(x,mm_psih2,A__MENUVERT,,,.f.)}
      ++j
    endif
      ++j
    if mpol == "М"
      ++j; @ j,1 say "Половая формула мальчика: P" get m141p pict "9"
           @ j,col() say ", Ax" get m141ax pict "9"
           @ j,col() say ", Fa" get m141fa pict "9"
    else
      ++j; @ j,1 say "Половая формула девочки: P" get m142p pict "9"
           @ j,col() say ", Ax" get m142ax pict "9"
           @ j,col() say ", Ma" get m142ma pict "9"
           @ j,col() say ", Me" get m142me pict "9"
      ++j; @ j,1 say "  menarhe" get m142me1 pict "99"
           @ j,col()+1 say "лет," get m142me2 pict "99"
           @ j,col()+1 say "месяцев, menses" get m142me3 ;
                  reader {|x|menu_reader(x,mm_142me3,A__MENUVERT,,,.f.)}
           @ j,50 say "," get m142me4 ;
                  reader {|x|menu_reader(x,mm_142me4,A__MENUVERT,,,.f.)}
           @ j,61 say "," get m142me5 ;
                  reader {|x|menu_reader(x,mm_142me5,A__MENUVERT,,,.f.)}
    endif
      ++j
      ++j; @ j,1 say "ДО ПРОВЕДЕНИЯ ДИСПАНСЕРИЗАЦИИ: практически здоров" get mdiag_15_1 ;
                  reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
      ++j; @ j,1 say "──────┬───────┬─────────────┬─────────┬─────────────┬─────────┬───────────────"
      ++j; @ j,1 say " Диаг-│Диспанс│Лечение назна│Выполнено│Реаб-ия назна│Выполнена│Высокотехнол.МП"
      ++j; @ j,1 say " ноз  │набл-ие│че-┌────┬────┼────┬────┤че-┌────┬────┼────┬────┼───────┬───────"
      ++j; @ j,1 say "      │установ│но │усл.│учр.│усл.│учр.│на │усл.│учр.│усл.│учр.│рекомен│оказана"
      ++j; @ j,1 say "──────┴───────┴───┴────┴────┴────┴────┴───┴────┴────┴────┴────┴───────┴───────"
      for i := 1 to 5
        ++j ; fl := .f.
        for k := 1 to 14
          s := "diag_15_"+lstr(i)+"_"+lstr(k)
          mvar := "m"+s
          if k == 1
            fl := !empty(&mvar)
          else
            m1var := "m1"+s
            if fl
              if eq_any(k,2)
                mm_m := mm_dispans
              elseif eq_any(k,4,6,9,11)
                mm_m := mm_usl
              elseif eq_any(k,5,7,10,12)
                mm_m := mm_uch1
              else
                mm_m := mm_danet
              endif
              &mvar := inieditspr(A__MENUVERT, mm_m, &m1var)
            else
              &m1var := 0
              &mvar := space(4)
            endif
          endif
          do case
            case k == 1
              @ j,1 get &mvar picture pic_diag ;
                 reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
                 when m1diag_15_1 == 0
            case k == 2
              @ j,8 get &mvar ;
                 reader {|x|menu_reader(x,mm_dispans,A__MENUVERT,,,.f.)} ;
                 when m1diag_15_1 == 0
            case k == 3
              @ j,16 get &mvar ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                 when m1diag_15_1 == 0
            case k == 4
              @ j,20 get &mvar ;
                 reader {|x|menu_reader(x,mm_usl,A__MENUVERT,,,.f.)} ;
                 when m1diag_15_1 == 0
            case k == 5
              @ j,25 get &mvar ;
                 reader {|x|menu_reader(x,mm_uch,A__MENUVERT,,,.f.)} ;
                 when m1diag_15_1 == 0
            case k == 6
              @ j,30 get &mvar ;
                 reader {|x|menu_reader(x,mm_usl,A__MENUVERT,,,.f.)} ;
                 when m1diag_15_1 == 0
            case k == 7
              @ j,35 get &mvar ;
                 reader {|x|menu_reader(x,mm_uch,A__MENUVERT,,,.f.)} ;
                 when m1diag_15_1 == 0
            case k == 8
              @ j,40 get &mvar ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                 when m1diag_15_1 == 0
            case k == 9
              @ j,44 get &mvar ;
                 reader {|x|menu_reader(x,mm_usl,A__MENUVERT,,,.f.)} ;
                 when m1diag_15_1 == 0
            case k == 10
              @ j,49 get &mvar ;
                 reader {|x|menu_reader(x,mm_uch1,A__MENUVERT,,,.f.)} ;
                 when m1diag_15_1 == 0
            case k == 11
              @ j,54 get &mvar ;
                 reader {|x|menu_reader(x,mm_usl,A__MENUVERT,,,.f.)} ;
                 when m1diag_15_1 == 0
            case k == 12
              @ j,59 get &mvar ;
                 reader {|x|menu_reader(x,mm_uch1,A__MENUVERT,,,.f.)} ;
                 when m1diag_15_1 == 0
            case k == 13
              @ j,66 get &mvar ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                 when m1diag_15_1 == 0
            case k == 14
              @ j,74 get &mvar ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                 when m1diag_15_1 == 0
          endcase
        next
      next
      ++j; @ j,1 to j,78
      ++j; @ j,1 say "ГРУППА состояния ЗДОРОВЬЯ ДО проведения диспансеризации" color color8
           @ j,col()+1 get mGRUPPA_DO pict "9"
      status_key("^<Esc>^ выход без записи ^<PgUp>^ на 3-ю страницу ^<PgDn>^ на 5-ю страницу")
    elseif num_screen == 5 //
      ++j; @ j,1 say "ПО РЕЗУЛЬТАТАМ ПРОВЕДЕНИЯ ДИСПАНСЕРИЗАЦИИ: практически здоров" get mdiag_16_1 ;
                  reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
      ++j; @ j,1 say "──────┬───┬───────┬─────────────┬─────────────┬─────────────┬─────────────┬───"
      ++j; @ j,1 say " Диаг-│Уст│Диспанс│Доп.конс.назн│Доп.конс.выпо│Лечение назна│Реаб-ия назна│ВМП"
      ++j; @ j,1 say " ноз  │впе│набл-ие│аче┌────┬────┤лне┌────┬────┤че-┌────┬────┤че-┌────┬────┤рек"
      ++j; @ j,1 say "      │рвы│установ│ны │усл.│учр.│ны │усл.│учр.│но │усл.│учр.│на │усл.│учр.│оме"
      ++j; @ j,1 say "──────┴───┴───────┴───┴────┴────┴───┴────┴────┴───┴────┴────┴───┴────┴────┴───"
      for i := 1 to 5
        ++j ; fl := .f.
        for k := 1 to 16
          s := "diag_16_"+lstr(i)+"_"+lstr(k)
          mvar := "m"+s
          if k == 1
            fl := !empty(&mvar)
          else
            m1var := "m1"+s
            if fl
              if eq_any(k,3)
                mm_m := mm_dispans
              elseif eq_any(k,5,8,11,14)
                mm_m := mm_usl
              elseif eq_any(k,6,9,12,15)
                mm_m := mm_uch1
              else
                mm_m := mm_danet
              endif
              &mvar := inieditspr(A__MENUVERT, mm_m, &m1var)
            else
              &m1var := 0
              &mvar := space(4)
            endif
          endif
          do case
            case k == 1
              @ j,1 get &mvar picture pic_diag ;
                 reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
                 when m1diag_16_1 == 0
            case k == 2
              @ j,8 get &mvar ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 3
              @ j,12 get &mvar ;
                 reader {|x|menu_reader(x,mm_dispans,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 4
              @ j,20 get &mvar ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 5
              @ j,24 get &mvar ;
                 reader {|x|menu_reader(x,mm_usl,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 6
              @ j,29 get &mvar ;
                 reader {|x|menu_reader(x,mm_uch,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 7
              @ j,34 get &mvar ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 8
              @ j,38 get &mvar ;
                 reader {|x|menu_reader(x,mm_usl,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 9
              @ j,43 get &mvar ;
                 reader {|x|menu_reader(x,mm_uch,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 10
              @ j,48 get &mvar ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 11
              @ j,52 get &mvar ;
                 reader {|x|menu_reader(x,mm_usl,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 12
              @ j,57 get &mvar ;
                 reader {|x|menu_reader(x,mm_uch,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 13
              @ j,62 get &mvar ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 14
              @ j,66 get &mvar ;
                 reader {|x|menu_reader(x,mm_usl,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 15
              @ j,71 get &mvar ;
                 reader {|x|menu_reader(x,mm_uch1,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
            case k == 16
              @ j,76 get &mvar ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                 when m1diag_16_1 == 0
          endcase
        next
      next
      ++j; @ j,1 to j,78
      //++j; @ j,1 say "Признак подозрения на злокачественное новообразование" get mDS_ONK ;
      //           reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}

      dispans_napr(mk_data, @j, .f.)  // вызов заполнения блока направлений

      ++j; @ j,1 to j,78
      ++j; @ j,1 say "Инвалидность" get minvalid1 ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
           @ j,30 say 'если "да":' get minvalid2 ;
                 reader {|x|menu_reader(x,mm_invalid2,A__MENUVERT,,,.f.)} ;
                 when m1invalid1 == 1
      ++j; @ j,2 say "установлена впервые" get minvalid3 ;
                 when m1invalid1 == 1
           @ j,col()+1 say "дата последнего освидетельствования" get minvalid4 ;
                 when m1invalid1 == 1
      ++j; @ j,2 say "Заболевания/инвалидность" get minvalid5 ;
                 reader {|x|menu_reader(x,mm_invalid5,A__MENUVERT,,,.f.)} ;
                 when m1invalid1 == 1
      ++j; @ j,2 say "Виды нарушений в состоянии здоровья" get minvalid6 ;
                 reader {|x|menu_reader(x,mm_invalid6,A__MENUVERT,,,.f.)} ;
                 when m1invalid1 == 1
      ++j; @ j,2 say "Дата назначения индивидуальной программы реабилитации" get minvalid7 ;
                 when m1invalid1 == 1
           @ j,col() say " выполнение" get minvalid8 ;
                 reader {|x|menu_reader(x,mm_invalid8,A__MENUVERT,,,.f.)} ;
                 when m1invalid1 == 1
      ++j; @ j,1 say "Прививки" get mprivivki1 ;
                 reader {|x|menu_reader(x,mm_privivki1,A__MENUVERT,,,.f.)}
           @ j,50 say "Не привит" get mprivivki2 ;
                 reader {|x|menu_reader(x,mm_privivki2,A__MENUVERT,,,.f.)} ;
                 when m1privivki1 > 0
      ++j; @ j,2 say "Нуждается в вакцинации" get mprivivki3 pict "@S64" ;
                 when m1privivki1 > 0
      ++j; @ j,1 say "Рекомендации здорового образа жизни" get mrek_form pict "@S52"
      ++j; @ j,1 say "Рекомендации по диспансерному наблюдению" get mrek_disp pict "@S47"
      ++j; @ j,1 say "ГРУППА состояния ЗДОРОВЬЯ по результатам проведения диспансеризации" color color8
           @ j,col()+1 get mGRUPPA pict "9"
      status_key("^<Esc>^ выход без записи;  ^<PgUp>^ вернуться на 4-ю страницу;  ^<PgDn>^ ЗАПИСЬ")
    endif
    DispEnd()
    count_edit += myread()
    if num_screen == 5
      if lastkey() == K_PGUP
        k := 3
        --num_screen
      else
        k := f_alert({padc("Выберите действие",60,".")},;
                     {" Выход без записи "," Запись "," Возврат в редактирование "},;
                     iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
      endif
    else
      if lastkey() == K_PGUP
        k := 3
        if num_screen > 1
          --num_screen
        endif
      elseif lastkey() == K_ESC
        if (k := f_alert({padc("Выберите действие",60,".")},;
                         {" Выход без записи "," Возврат в редактирование "},;
                         1,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )) == 2
          k := 3
        endif
      else
        k := 3
        ++num_screen
      endif
    endif
    SetMode(25,80)
    if k == 3
      loop
    elseif k == 2
      num_screen := 1
      if m1komu < 5 .and. empty(m1company)
        if m1komu == 0     ; s := "СМО"
        elseif m1komu == 1 ; s := "компании"
        else               ; s := "комитета/МО"
        endif
        func_error(4,'Не заполнено наименование '+s)
        loop
      endif
      if m1komu == 0 .and. empty(mnpolis)
        func_error(4,'Не заполнен номер полиса')
        loop
      endif
      if tip_lu == TIP_LU_DDS
        if empty(m1stacionar)
          func_error(4,'Не заполнено стационарное учреждение')
          loop
        endif
        if empty(mdate_post)
          func_error(4,'Не заполнена дата поступления в стационарное учреждение')
          loop
        elseif mdate_post < mdate_r
          func_error(4,'Дата поступления в стационарное учреждение МЕНЬШЕ даты рождения')
          loop
        endif
      else
        m1stacionar := 0
        if m1gde_nahod == 0
          m1gde_nahod := 1
        endif
        mdate_post := ctod("")
      endif
      if empty(mn_data)
        func_error(4,"Не введена дата начала лечения.")
        loop
      endif
      if mvozrast >= 18
        func_error(4,"Диспансеризация детей-сирот оказана взрослому пациенту!")
        loop
      endif
      if empty(mk_data)
        func_error(4,"Не введена дата окончания лечения.")
        loop
      elseif mk_data < stod("20130525")
        func_error(4,"Дата окончания лечения не должна быть ранее 25 мая 2013 года")
        loop
      endif
      if empty(CHARREPL("0",much_doc,space(10)))
        func_error(4,'Не заполнен номер амбулаторной карты')
        loop
      endif
      if empty(mmo_pr)
        func_error(4,"Не введено МО, к которому прикреплён ребёнок.")
        loop
      endif
      if empty(mWEIGHT)
        func_error(4,"Не введён вес.")
        loop
      endif
      if empty(mHEIGHT)
        func_error(4,"Не введён рост.")
        loop
      endif
      if mvozrast < 5 .and. empty(mPER_HEAD)
        func_error(4,"Не введена окружность головы.")
        loop
      endif
      if m1FIZ_RAZV == 1 .and. emptyall(m1fiz_razv1,m1fiz_razv2)
        func_error(4,"Не введены отклонения массы тела или роста.")
        loop
      endif
      if ! checkTabNumberDoctor(mk_data, .f.)
        loop
      endif
      if mvozrast < 1
        mdef_diagnoz := "Z00.1 "
      elseif mvozrast < 14
        mdef_diagnoz := "Z00.2 "
      else
        mdef_diagnoz := "Z00.3 "
      endif
      arr_iss := array(count_dds_arr_iss,10) ; afillall(arr_iss,0)
      R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
      R_Use(dir_server+"mo_pers",dir_server+"mo_pers","P2")
      num_screen := 2
      max_date1 := max_date2 := mn_data
      d12 := mn_data-1
      k := 0
      if metap == 2
        do while ++d12 <= mk_data
          if is_work_day(d12)
            if ++k == 10
              exit
            endif
          endif
        enddo
      endif
      fl := .t.
      for i := 1 to count_dds_arr_iss
        mvart := "MTAB_NOMiv"+lstr(i)
        mvara := "MTAB_NOMia"+lstr(i)
        mvard := "MDATEi"+lstr(i)
        mvarr := "MREZi"+lstr(i)
        if between(mvozrast,dds_arr_iss[i,3],dds_arr_iss[i,4])
          m1var := "m1lis"+lstr(i)
          if !is_disp_19 .and. glob_yes_kdp2[tip_lu] .and. &m1var > 0
            &mvart := -1
          endif
          if empty(&mvard)
            fl := func_error(4,'Не введена дата иссл-ия "'+dds_arr_iss[i,1]+'"')
          elseif metap == 2 .and. &mvard > d12
            fl := func_error(4,'Дата иссл-ия "'+dds_arr_iss[i,1]+'" не в I-ом этапе (> 10 дней)')
          elseif empty(&mvart)
            fl := func_error(4,'Не введен врач в иссл-ии "'+dds_arr_iss[i,1]+'"')
          else
            if &mvart > 0
              select P2
              find (str(&mvart,5))
              if found()
                arr_iss[i,1] := p2->kod
                arr_iss[i,2] := -ret_new_spec(p2->prvs,p2->prvs_new)
              endif
              if !empty(&mvara)
                select P2
                find (str(&mvara,5))
                if found()
                  arr_iss[i,3] := p2->kod
                endif
              endif
            else
              arr_iss[i,2] := -ret_new_spec(dds_arr_iss[i,6,1])
              arr_iss[i,10] := &m1var // кровь проверяют в КДП2
            endif
            arr_iss[i,4] := dds_arr_iss[i,5,1]
            arr_iss[i,5] := dds_arr_iss[i,7,1]
            // УЗИ органов репродуктивной системы {"8.2.2","8.2.3"}
            if len(dds_arr_iss[i,7]) > 1 .and. mpol == "Ж"
              arr_iss[i,5] := dds_arr_iss[i,7,2]
            endif
            arr_iss[i,6] := mdef_diagnoz
            arr_iss[i,9] := &mvard
            //
            max_date1 := max(max_date1,arr_iss[i,9])
          endif
        endif
        if !fl ; exit ; endif
      next
      if !fl
        loop
      endif
      fl := .t.
      k := 0
      arr_osm1 := array(count_dds_arr_osm1,10) ; afillall(arr_osm1,0)
      for i := 1 to count_dds_arr_osm1
        mvart := "MTAB_NOMov"+lstr(i)
        mvara := "MTAB_NOMoa"+lstr(i)
        mvard := "MDATEo"+lstr(i)
        mvarz := "MKOD_DIAGo"+lstr(i)
        if &mvard == mn_data
          k := i
        endif
        if iif(empty(dds_arr_osm1[i,2]), .t., dds_arr_osm1[i,2]==mpol) .and. ;
           between(mvozrast,dds_arr_osm1[i,3],dds_arr_osm1[i,4])
          if empty(&mvard)
            fl := func_error(4,'Не введена дата осмотра I этапа "'+dds_arr_osm1[i,1]+'"')
          elseif metap == 2 .and. &mvard > d12
            fl := func_error(4,'Дата осмотра "'+dds_arr_osm1[i,1]+'" не в I-ом этапе (> 10 дней)')
          elseif empty(&mvart)
            fl := func_error(4,'Не введен врач в осмотре I этапа  "'+dds_arr_osm1[i,1]+'"')
          else
            select P2
            find (str(&mvart,5))
            if found()
              arr_osm1[i,1] := p2->kod
              arr_osm1[i,2] := -ret_new_spec(p2->prvs,p2->prvs_new)
            endif
            if !empty(&mvara)
              select P2
              find (str(&mvara,5))
              if found()
                arr_osm1[i,3] := p2->kod
              endif
            endif
            arr_osm1[i,4] := dds_arr_osm1[i,5,1]
            arr_osm1[i,5] := dds_arr_osm1[i,7,1]
            // "педиатр","",0,17,{68,57},{1134,1110},{"2.83.14","2.83.15"}
            if len(dds_arr_osm1[i,5]) == 2 .and. len(dds_arr_osm1[i,6]) == 2 ;
                                           .and. len(dds_arr_osm1[i,7]) == 2 ;
                                           .and. dds_arr_osm1[i,6,2] == ret_old_prvs(arr_osm1[i,2])
              arr_osm1[i,4] := dds_arr_osm1[i,5,2]
              arr_osm1[i,5] := dds_arr_osm1[i,7,2]
            endif
            if empty(&mvarz) .or. left(&mvarz,1) == "Z"
              arr_osm1[i,6] := mdef_diagnoz
            else
              arr_osm1[i,6] := &mvarz
              select MKB_10
              find (padr(arr_osm1[i,6],6))
              if found() .and. !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
                fl := func_error(4,"Несовместимость диагноза по полу "+arr_osm1[i,6])
              endif
            endif
            arr_osm1[i,9] := &mvard
            max_date1 := max(max_date1,arr_osm1[i,9])
          endif
        endif
        if !fl ; exit ; endif
      next
      if !fl
        loop
      endif
      if emptyall(arr_osm1[count_dds_arr_osm1,1],arr_osm1[count_dds_arr_osm1,9])
        fl := func_error(4,'Не введён педиатр (врач общей практики) в осмотрах I этапа')
      elseif arr_osm1[count_dds_arr_osm1,9] < max_date1
        fl := func_error(4,'Педиатр (врач общей практики) на I этапе должен проводить осмотр последним!')
      endif
      if !fl
        loop
      endif
      num_screen := 3
      metap := 1
      fl := .t.
      for i := 7 to 8 // стоматолог и эндокринолог на 2 этапе
        mvart := "MTAB_NOMov"+lstr(i)
        mvara := "MTAB_NOMoa"+lstr(i)
        mvard := "MDATEo"+lstr(i)
        mvarz := "MKOD_DIAGo"+lstr(i)
        if !between(mvozrast,dds_arr_osm1[i,3],dds_arr_osm1[i,4])
          if !empty(&mvard) .and. empty(&mvart)
            fl := func_error(4,'Не введен врач в осмотре II этапа  "'+dds_arr_osm1[i,1]+'"')
          elseif !empty(&mvart) .and. empty(&mvard)
            fl := func_error(4,'Не введена дата осмотра II этапа "'+dds_arr_osm1[i,1]+'"')
          elseif !emptyany(&mvard,&mvart)
            metap := 2
            if &mvard < max_date1
              fl := func_error(4,'Дата осмотра II этапа "'+dds_arr_osm1[i,1]+'" внутри I этапа')
            endif
            select P2
            find (str(&mvart,5))
            if found()
              arr_osm1[i,1] := p2->kod
              arr_osm1[i,2] := -ret_new_spec(p2->prvs,p2->prvs_new)
            endif
            if !empty(&mvara)
              select P2
              find (str(&mvara,5))
              if found()
                arr_osm1[i,3] := p2->kod
              endif
            endif
            arr_osm1[i,4] := dds_arr_osm1[i,5,1]
            arr_osm1[i,5] := dds_arr_osm1[i,7,1]
            if empty(&mvarz) .or. left(&mvarz,1) == "Z"
              arr_osm1[i,6] := mdef_diagnoz
            else
              arr_osm1[i,6] := &mvarz
              select MKB_10
              find (padr(arr_osm1[i,6],6))
              if found() .and. !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
                fl := func_error(4,"Несовместимость диагноза по полу "+arr_osm1[i,6])
              endif
            endif
            arr_osm1[i,9] := &mvard
            max_date2 := max(max_date2,arr_osm1[i,9])
          endif
        endif
        if !fl ; exit ; endif
      next
      if !fl
        loop
      endif
      arr_osm2 := array(count_dds_arr_osm2,10) ; afillall(arr_osm2,0)
      for i := 1 to count_dds_arr_osm2
        mvart := "MTAB_NOM2ov"+lstr(i)
        mvara := "MTAB_NOM2oa"+lstr(i)
        mvard := "MDATE2o"+lstr(i)
        mvarz := "MKOD_DIAG2o"+lstr(i)
        arr_osm2[i,4] := dds_arr_osm2[i,5,1]
        if arr_osm2[i,4] == 12 .and. m1onko8 == 3
          &mvart := -1
        elseif arr_osm2[i,4] == 18 .and. m1onko10 == 3
          &mvart := -1
        endif
        if !empty(&mvard) .and. empty(&mvart)
          fl := func_error(4,'Не введен врач в осмотре II этапа  "'+dds_arr_osm2[i,1]+'"')
        elseif !empty(&mvart) .and. empty(&mvard)
          fl := func_error(4,'Не введена дата осмотра II этапа "'+dds_arr_osm2[i,1]+'"')
        elseif !emptyany(&mvard,&mvart)
          metap := 2
          if &mvard < max_date1
            fl := func_error(4,'Дата осмотра II этапа "'+dds_arr_osm2[i,1]+'" внутри I этапа')
          endif
          if &mvart > 0
            select P2
            find (str(&mvart,5))
            if found()
              arr_osm2[i,1] := p2->kod
              arr_osm2[i,2] := -ret_new_spec(p2->prvs,p2->prvs_new)
            endif
            if !empty(&mvara)
              select P2
              find (str(&mvara,5))
              if found()
                arr_osm2[i,3] := p2->kod
              endif
            endif
          else // приём в онкодиспансере
            arr_osm2[i,2] := -ret_new_spec(dds_arr_osm2[i,6,1])
            arr_osm2[i,10] := 3
          endif
          arr_osm2[i,5] := dds_arr_osm2[i,7,1]
          // "педиатр","",0,17,{68,57},{1134,1110},{"2.83.14","2.83.15"}
          if len(dds_arr_osm2[i,5]) == 2 .and. len(dds_arr_osm2[i,6]) == 2 ;
                                         .and. len(dds_arr_osm2[i,7]) == 2 ;
                                         .and. ret_new_spec(dds_arr_osm2[i,6,2]) == arr_osm2[i,2]
            arr_osm2[i,4] := dds_arr_osm2[i,5,2]
            arr_osm2[i,5] := dds_arr_osm2[i,7,2]
          endif
          if empty(&mvarz) .or. left(&mvarz,1) == "Z"
            arr_osm2[i,6] := mdef_diagnoz
          else
            arr_osm2[i,6] := &mvarz
            select MKB_10
            find (padr(arr_osm2[i,6],6))
            if found() .and. !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
              fl := func_error(4,"Несовместимость диагноза по полу "+arr_osm2[i,6])
            endif
          endif
          arr_osm2[i,9] := &mvard
          max_date2 := max(max_date2,arr_osm2[i,9])
        endif
        if !fl ; exit ; endif
      next
      if fl .and. metap == 2
        if emptyall(arr_osm2[count_dds_arr_osm2,1],arr_osm2[count_dds_arr_osm2,9])
          fl := func_error(4,'Не введён педиатр (врач общей практики) в осмотрах II этапа')
        elseif arr_osm1[count_dds_arr_osm1,9] == arr_osm2[count_dds_arr_osm2,9]
          fl := func_error(4,'Педиатры на I и II этапах провели осмотры в один день!')
        elseif arr_osm2[count_dds_arr_osm2,9] < max_date2
          fl := func_error(4,'Педиатр (врач общей практики) на II этапе должен проводить осмотр последним!')
        endif
      endif
      if !fl
        loop
      endif
      num_screen := 4
      if !between(mGRUPPA_DO,1,5)
        func_error(4,"ГРУППА состояния ЗДОРОВЬЯ ДО проведения диспансеризации д.б. от 1 до 5")
        loop
      endif
      num_screen := 5
      arr_diag := {}
      for i := 1 to 5
        mvar := "mdiag_16_"+lstr(i)+"_1"
        if !empty(&mvar)
          if left(&mvar,1) == "Z"
            fl := func_error(4,'Диагноз '+rtrim(&mvar)+'(первый символ "Z") не вводится. Это не заболевание!')
            exit
          endif
          pole_1pervich := "m1diag_16_"+lstr(i)+"_2" // 0,1
          pole_1dispans := "m1diag_16_"+lstr(i)+"_3" // mm_dispans := {{"ранее",1},{"впервые",2},{"не уст.",0}}
          aadd(arr_diag, {&mvar,&pole_1pervich,&pole_1dispans})
        endif
      next
      if !fl
        loop
      endif
      afill(adiag_talon,0)
      if empty(arr_diag) // диагнозы не вводили
        aadd(arr_diag, {1,mdef_diagnoz,0,0}) // диагноз по умолчанию
        MKOD_DIAG := mdef_diagnoz
      else
        for i := 1 to len(arr_diag)
          if arr_diag[i,2] == 0 // "ранее выявлено"
            arr_diag[i,2] := 2  // заменяем, как в листе учёта ОМС
          endif
        next
        for i := 1 to len(arr_diag)
          adiag_talon[i*2-1] := arr_diag[i,2]
          adiag_talon[i*2  ] := arr_diag[i,3]
          if i == 1
            MKOD_DIAG := arr_diag[i,1]
          elseif i == 2
            MKOD_DIAG2 := arr_diag[i,1]
          elseif i == 3
            MKOD_DIAG3 := arr_diag[i,1]
          elseif i == 4
            MKOD_DIAG4 := arr_diag[i,1]
          elseif i == 5
            MSOPUT_B1 := arr_diag[i,1]
          endif
          select MKB_10
          find (padr(arr_diag[i,1],6))
          if found()
            if !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
              fl := func_error(4,"несовместимость диагноза по полу "+alltrim(arr_diag[i,1]))
            endif
          else
            fl := func_error(4,"не найден диагноз "+alltrim(arr_diag[i,1])+" в справочнике МКБ-10")
          endif
          if !fl ; exit ; endif
        next
        if !fl
          loop
        endif
      endif
      if m1invalid1 == 1 .and. !empty(minvalid3) .and. minvalid3 < mdate_r
        func_error(4,"Дата установления инвалидности меньше даты рождения")
        loop
      endif
      if between(mGRUPPA,1,5)
        m1rslt := L_BEGIN_RSLT+mGRUPPA
      else
        func_error(4,"ГРУППА состояния ЗДОРОВЬЯ по результатам проведения диспансеризации - от 1 до 5")
        loop
      endif
      //
      err_date_diap(mn_data,"Дата начала лечения")
      err_date_diap(mk_data,"Дата окончания лечения")
      //
      restscreen(buf)
      if mem_op_out == 2 .and. yes_parol
        box_shadow(19,10,22,69,cColorStMsg)
        str_center(20,'Оператор "'+fio_polzovat+'".',cColorSt2Msg)
        str_center(21,'Ввод данных за '+date_month(sys_date),cColorStMsg)
      endif
      mywait("Ждите. Производится запись листа учёта...")
      m1lis := 0
      if !is_disp_19 .and. glob_yes_kdp2[tip_lu]
        for i := 1 to count_dds_arr_iss
          if valtype(arr_iss[i,9]) == "D" .and. arr_iss[i,9] >= mn_data .and. len(arr_iss[i]) > 9 ;
                                          .and. valtype(arr_iss[i,10]) == "N" .and. arr_iss[i,10] > 0
            m1lis := arr_iss[i,10] // в рамках диспансеризации отправили в КДП2
          endif
        next
      endif
      //
      if metap == 1
        for i := 1 to count_dds_arr_osm1
          if valtype(arr_osm1[i,5])=="C" .and. left(arr_osm1[i,5],5)=="2.83."
            if eq_any(alltrim(arr_osm1[i,5]),"2.83.14","2.83.15") // педиатр, врач общей практики
              arr_osm1[i,5] := "2.3.2"
            else
              arr_osm1[i,5] := "2.3.1"
            endif
          endif
        next
        aadd(arr_osm1,array(10)) ; i := count_dds_arr_osm1+1
        arr_osm1[i,1] := arr_osm1[i-1,1]
        arr_osm1[i,2] := arr_osm1[i-1,2]
        arr_osm1[i,3] := arr_osm1[i-1,3]
        arr_osm1[i,4] := arr_osm1[i-1,4]
        arr_osm1[i,5] := ret_shifr_zs_DDS(tip_lu)
        arr_osm1[i,6] := arr_osm1[i-1,6]
        arr_osm1[i,9] := mn_data
        m1vrach  := arr_osm1[i,1]
        m1prvs   := arr_osm1[i,2]
        m1PROFIL := arr_osm1[i,4]
        //MKOD_DIAG := padr(arr_osm1[i,6],6)
      else  // metap := 2
        if m1lis > 0 // услуги заменим на аналогичные шифры без гематологии
          for i := 1 to len(arr_osm1)
            if valtype(arr_osm1[i,5]) == "C" .and. (j := ascan(dds_arr_osmotr_KDP2,{|x| x[1] == arr_osm1[i,5]})) > 0
              arr_osm1[i,5] := dds_arr_osmotr_KDP2[j,2]
            endif
          next
          for i := 1 to len(arr_osm2)
            if valtype(arr_osm2[i,5]) == "C" .and. (j := ascan(dds_arr_osmotr_KDP2,{|x| x[1] == arr_osm2[i,5]})) > 0
              arr_osm2[i,5] := dds_arr_osmotr_KDP2[j,2]
            endif
          next
        endif
        for i := 1 to len(arr_osm2)
          if arr_osm2[i,10] == 3 // если услуга оказана в ВОКОД
            arr_osm2[i,5] := "2.3.1"
          endif
        next
        if tip_lu == TIP_LU_DDSOP // дли детей-сирот под опекой вместо услуг "2.83.*" сделаем "2.87.*"
          for i := 1 to count_dds_arr_osm1
            if valtype(arr_osm1[i,5])=="C" .and. left(arr_osm1[i,5],5)=="2.83."
              arr_osm1[i,5] := "2.87."+substr(arr_osm1[i,5],6)
            endif
          next
          for i := 1 to count_dds_arr_osm2
            if valtype(arr_osm2[i,5])=="C" .and. left(arr_osm2[i,5],5)=="2.83."
              arr_osm2[i,5] := "2.87."+substr(arr_osm2[i,5],6)
            endif
          next
        endif
        i := count_dds_arr_osm2
        m1vrach  := arr_osm2[i,1]
        m1prvs   := arr_osm2[i,2]
        m1PROFIL := arr_osm2[i,4]
        //MKOD_DIAG := padr(arr_osm2[i,6],6)
      endif
      make_diagP(2)  // сделать "пятизначные" диагнозы
      //
      Use_base("lusl")
      Use_base("luslc")
      Use_base("uslugi")
      R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                                  dir_server+"uslugi1s"},"USL1")
      Private mu_cena
      mcena_1 := 0
      arr_usl_dop := {}
      glob_podr := "" ; glob_otd_dep := 0
      for i := 1 to len(arr_iss)
        if valtype(arr_iss[i,5]) == "C"
          arr_iss[i,7] := foundOurUsluga(arr_iss[i,5],mk_data,arr_iss[i,4],M1VZROS_REB,@mu_cena)
          arr_iss[i,8] := mu_cena
          mcena_1 += mu_cena
          aadd(arr_usl_dop,arr_iss[i])
        endif
      next
      for i := 1 to len(arr_osm1)
        if valtype(arr_osm1[i,5]) == "C"
          arr_osm1[i,7] := foundOurUsluga(arr_osm1[i,5],mk_data,arr_osm1[i,4],M1VZROS_REB,@mu_cena)
          arr_osm1[i,8] := mu_cena
          mcena_1 += mu_cena
          aadd(arr_usl_dop,arr_osm1[i])
        endif
      next
      if metap == 2
        for i := 1 to len(arr_osm2)
          if valtype(arr_osm2[i,5]) == "C"
            arr_osm2[i,7] := foundOurUsluga(arr_osm2[i,5],mk_data,arr_osm2[i,4],M1VZROS_REB,@mu_cena)
            arr_osm2[i,8] := mu_cena
            mcena_1 += mu_cena
            aadd(arr_usl_dop,arr_osm2[i])
          endif
        next
      endif
      //
      Use_base("human")
      if Loc_kod > 0
        find (str(Loc_kod,7))
        mkod := Loc_kod
        G_RLock(forever)
      else
        Add1Rec(7)
        mkod := recno()
        replace human->kod with mkod
      endif
      select HUMAN_
      do while human_->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      //
      select HUMAN_2
      do while human_2->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      //
      st_N_DATA := MN_DATA
      st_K_DATA := MK_DATA
      if m1stacionar > 0
        st_stacionar := m1stacionar
      endif
      st_kateg_uch := m1kateg_uch
      st_mo_pr := m1mo_pr
      glob_perso := mkod
      if m1komu == 0
        msmo := lstr(m1company)
        m1str_crb := 0
      else
        msmo := ""
        m1str_crb := m1company
      endif
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
      human->POLIS      := make_polis(mspolis,mnpolis) // серия и номер страхового полиса
      human->LPU        := M1LPU         // код учреждения
      human->OTD        := M1OTD         // код отделения
      human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
      human->N_DATA     := MN_DATA       // дата начала лечения
      human->K_DATA     := MK_DATA       // дата окончания лечения
      human->CENA := human->CENA_1 := MCENA_1 // стоимость лечения
      human->ishod      := 100+metap
      human->OBRASHEN   := "" // <Признак подозрения на ЗНО>: - всегда указывается <0>iif(m1DS_ONK == 1, '1', " ")
      human->bolnich    := 0
      human->date_b_1   := ""
      human->date_b_2   := ""
      human_->RODIT_DR  := ctod("")
      human_->RODIT_POL := ""
      s := "" ; aeval(adiag_talon, {|x| s += str(x,1) })
      human_->DISPANS   := s
      human_->STATUS_ST := ""
      human_->POVOD     := 6 // {"2.2-Диспансеризация",6,"2.2"},;
      //human_->TRAVMA    := m1travma
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := ltrim(mspolis)
      human_->NPOLIS    := ltrim(mnpolis)
      human_->OKATO     := "" // это поле вернётся из ТФОМС в случае иногороднего
      human_->NOVOR     := 0
      human_->DATE_R2   := ctod("")
      human_->POL2      := ""
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
      human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      if Loc_kod == 0  // при добавлении
        human_->ID_PAC    := mo_guid(1,human_->(recno()))
        human_->ID_C      := mo_guid(2,human_->(recno()))
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
      else // при редактированиии
        human_->kod_p2  := kod_polzovat    // код оператора
        human_->date_e2 := c4sys_date
      endif
      put_0_human_2()
      Private fl_nameismo := .f.
      if m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ОКАТО субъекта РФ территории страхования
        if empty(m1ismo)
          if !empty(mnameismo)
            fl_nameismo := .t.
          endif
        else
          human_->SMO := m1ismo  // заменяем "34" на код иногородней СМО
        endif
      endif
      if fl_nameismo .or. rec_inogSMO > 0
        G_Use(dir_server+"mo_hismo",,"SN")
        index on str(kod,7) to (cur_dir+"tmp_ismo")
        find (str(mkod,7))
        if found()
          if fl_nameismo
            G_RLock(forever)
            sn->smo_name := mnameismo
          else
            DeleteRec(.t.)
          endif
        else
          if fl_nameismo
            AddRec(7)
            sn->kod := mkod
            sn->smo_name := mnameismo
          endif
        endif
      endif
      i1 := len(arr_usl)
      i2 := len(arr_usl_dop)
      Use_base("human_u")
      for i := 1 to i2
        select HU
        if i > i1
          Add1Rec(7)
          hu->kod := human->kod
        else
          goto (arr_usl[i])
          G_RLock(forever)
        endif
        mrec_hu := hu->(recno())
        hu->kod_vr  := arr_usl_dop[i,1]
        hu->kod_as  := arr_usl_dop[i,3]
        hu->u_koef  := 1
        hu->u_kod   := arr_usl_dop[i,7]
        hu->u_cena  := arr_usl_dop[i,8]
        hu->is_edit := iif(len(arr_usl_dop[i]) > 9 .and. valtype(arr_usl_dop[i,10]) == "N", arr_usl_dop[i,10], 0)
        hu->date_u  := dtoc4(arr_usl_dop[i,9])
        hu->otd     := m1otd
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := arr_usl_dop[i,8]
        select HU_
        do while hu_->(lastrec()) < mrec_hu
          APPEND BLANK
        enddo
        goto (mrec_hu)
        G_RLock(forever)
        if i > i1 .or. !valid_GUID(hu_->ID_U)
          hu_->ID_U := mo_guid(3,hu_->(recno()))
        endif
        hu_->PROFIL := arr_usl_dop[i,4]
        hu_->PRVS   := arr_usl_dop[i,2]
        hu_->kod_diag := arr_usl_dop[i,6]
        hu_->zf := ""
        UNLOCK
      next
      if i2 < i1
        for i := i2+1 to i1
          select HU
          goto (arr_usl[i])
          DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
        next
      endif
      save_arr_DDS(mkod)
      write_work_oper(glob_task,OPER_LIST,iif(Loc_kod==0,1,2),1,count_edit)
      fl_write_sluch := .t.
      close databases
      stat_msg("Запись завершена!",.f.)
    endif
    exit
  enddo
  close databases
  setcolor(tmp_color)
  restscreen(buf)
  chm_help_code := tmp_help
  if fl_write_sluch // если записали - запускаем проверку
    if type("fl_edit_DDS") == "L"
      fl_edit_DDS := .t.
    endif
    if !empty(val(msmo))
      verify_OMS_sluch(glob_perso)
    endif
  endif
  return NIL
  