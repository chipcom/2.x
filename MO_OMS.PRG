***** mo_oms.prg - режимы ввода данных для задачи ОМС
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

*****
Function begin_task_oms()
Static n_zapusk := 0
Local i, fl := .t.
if n_zapusk == 0
  ++n_zapusk
  Public arr_opl_7, len_arr_7, mem_oms_pole := 0
endif
if G_SIsLock(sem_vagno_task[X_OMS])
  fl := f_err_sem_vagno_task(X_OMS)
elseif copy_Tools_Ini()
  Tools_Ini_OMS(1,0,0)
  i := GetIniVar(tmp_ini, {{"RAB_MESTO","oms_pole","0"}} )
  if i[1] != NIL
    mem_oms_pole := int(val(i[1]))
  endif
else
  fl := .f.
endif
return fl

***** 01.02.20 ДДС - добавление или редактирование случая (листа учета)
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
  is_disp_19 := !(mk_data < d_01_11_2019)
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
mprofil_stac := inieditspr(A__MENUVERT, glob_V002, m1profil_stac)
mnapr_reab := inieditspr(A__MENUVERT, mm_danet, m1napr_reab)
mprofil_kojki := inieditspr(A__MENUVERT, glob_V020, m1profil_kojki)
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
    is_disp_19 := !(mk_data < d_01_11_2019)
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
    ++j; @ j,1 say "Направлен на дополнительное обследование" get mdopo_na ;
               reader {|x|menu_reader(x,mm_dopo_na,A__MENUBIT,,,.f.)}
    ++j; @ j,1 say "Направлен" get mnapr_v_mo ;
               reader {|x|menu_reader(x,mm_napr_v_mo,A__MENUVERT,,,.f.)} ;
               valid {|| iif(m1napr_v_mo==0, (arr_mo_spec:={},ma_mo_spec:=padr("---",42)), ), update_get("ma_mo_spec")}
         @ j,col()+1 say "к специалистам" get ma_mo_spec ;
               reader {|x|menu_reader(x,{{|k,r,c| fget_spec_deti(k,r,c,arr_mo_spec)}},A__FUNCTION,,,.f.)} ;
               when m1napr_v_mo > 0
    ++j; @ j,1 say "Направлен на лечение" get mnapr_stac ;
               reader {|x|menu_reader(x,mm_napr_stac,A__MENUVERT,,,.f.)} ;
               valid {|| iif(m1napr_stac==0, (m1profil_stac:=0,mprofil_stac:=space(32)), ), update_get("mprofil_stac")}
         @ j,col()+1 say "по профилю" get mprofil_stac ;
               reader {|x|menu_reader(x,glob_V002,A__MENUVERT,,,.f.,,,.t.)} ;
               when m1napr_stac > 0
    ++j; @ j,1 say "Направлен на реабилитацию" get mnapr_reab ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
               valid {|| iif(m1napr_reab==0, (m1profil_kojki:=0,mprofil_kojki:=space(30)), ), update_get("mprofil_kojki")}
         @ j,col()+1 say ", профиль койки" get mprofil_kojki ;
               reader {|x|menu_reader(x,glob_V020,A__MENUVERT,,,.f.,,,.t.)} ;
               when m1napr_reab > 0
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

***** 19.03.19 вернуть шифр услуги законченного случая для диспансеризации детей-сирот
Function ret_shifr_zs_DDS(tip_lu)
Local s := ""
if m1mobilbr == 1 // диспансеризация проведена мобильной бригадой
  if m1lis > 0 // без гематологических иссл-ий
    if mvozrast < 1
      s := iif(tip_lu==TIP_LU_DDS, "70.5.21", "70.6.19")
    elseif mvozrast < 3
      s := iif(tip_lu==TIP_LU_DDS, "70.5.22", "70.6.20")
    elseif mvozrast < 5
      s := iif(tip_lu==TIP_LU_DDS, "70.5.23", "70.6.21")
    elseif mvozrast < 7
      s := iif(tip_lu==TIP_LU_DDS, "70.5.24", "70.6.22")
    elseif mvozrast < 15
      s := iif(tip_lu==TIP_LU_DDS, "70.5.25", "70.6.23")
    else
      s := iif(tip_lu==TIP_LU_DDS, "70.5.26", "70.6.24")
    endif
  else  // гематологические иссл-ия проводятся в ЛПУ
    if mvozrast < 1
      s := iif(tip_lu==TIP_LU_DDS, "70.5.9", "70.6.7")
    elseif mvozrast < 3
      s := iif(tip_lu==TIP_LU_DDS, "70.5.10", "70.6.8")
    elseif mvozrast < 5
      s := iif(tip_lu==TIP_LU_DDS, "70.5.11", "70.6.9")
    elseif mvozrast < 7
      s := iif(tip_lu==TIP_LU_DDS, "70.5.12", "70.6.10")
    elseif mvozrast < 15
      s := iif(tip_lu==TIP_LU_DDS, "70.5.13", "70.6.11")
    else
      s := iif(tip_lu==TIP_LU_DDS, "70.5.14", "70.6.12")
    endif
  endif
else // дисп-ия проведена в МО (не мобильной бригадой)
  if m1lis > 0 // без гематологических иссл-ий
    if mvozrast < 1
      s := iif(tip_lu==TIP_LU_DDS, "70.5.15", "70.6.13")
    elseif mvozrast < 3
      s := iif(tip_lu==TIP_LU_DDS, "70.5.16", "70.6.14")
    elseif mvozrast < 5
      s := iif(tip_lu==TIP_LU_DDS, "70.5.17", "70.6.15")
    elseif mvozrast < 7
      s := iif(tip_lu==TIP_LU_DDS, "70.5.18", "70.6.16")
    elseif mvozrast < 15
      s := iif(tip_lu==TIP_LU_DDS, "70.5.19", "70.6.17")
    else
      s := iif(tip_lu==TIP_LU_DDS, "70.5.20", "70.6.18")
    endif
  else  // гематологические иссл-ия проводятся в ЛПУ
    if mvozrast < 1
      s := iif(tip_lu==TIP_LU_DDS, "70.5.3", "70.6.1")
    elseif mvozrast < 3
      s := iif(tip_lu==TIP_LU_DDS, "70.5.4", "70.6.2")
    elseif mvozrast < 5
      s := iif(tip_lu==TIP_LU_DDS, "70.5.5", "70.6.3")
    elseif mvozrast < 7
      s := iif(tip_lu==TIP_LU_DDS, "70.5.6", "70.6.4")
    elseif mvozrast < 15
      s := iif(tip_lu==TIP_LU_DDS, "70.5.7", "70.6.5")
    else
      s := iif(tip_lu==TIP_LU_DDS, "70.5.8", "70.6.6")
    endif
  endif
endif
return s

***** 01.11.19 СМП - добавление или редактирование случая (листа учета)
Function oms_sluch_SMP(Loc_kod,kod_kartotek,tip_lu)
// Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
// kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
// tip_lu - TIP_LU_SMP или TIP_LU_NMP - скорая помощь (неотложная медицинская помощь)
Static mm_brigada, st_brigada, mm_trombolit, st_trombolit, mm_spec, SKOD_DIAG := '     ',;
       st_N_DATA, st_vrach := 0, st_rslt := 0, st_ishod := 0
Local top2, ar, ibrm := 0
Local bg := {|o,k| get_MKB10(o,k,.t.) }, arr_del := {}, mrec_hu := 0,;
      buf := savescreen(), tmp_color := setcolor(), a_smert := {},;
      arr_usluga := {}, p_uch_doc := "@!", pic_diag := "@K@!",;
      i, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0,;
      tmp_help := chm_help_code, fl_write_sluch := .f.
//
Default st_N_DATA TO sys_date
Default Loc_kod TO 0, kod_kartotek TO 0
Private row_diag_screen, rdiag := 1
if mem_smp_input == 0
  if  kod_kartotek == 0 // добавление в картотеку
    if (kod_kartotek := edit_kartotek(0,,,.t.)) == 0
      return NIL
    endif
  endif
  top2 := 6
  row_diag_screen := 6
else
  top2 := 5
  row_diag_screen := 9
  Private ;
    MFIO        := space(50)         ,; // Ф.И.О. больного
    mfam := space(40), mim := space(40), mot := space(40),;
    mpol        := "М"            ,;
    mdate_r     := boy(addmonth(sys_date,-12*30)) ,;
    MVZROS_REB, M1VZROS_REB := 0,;
    MADRES      := space(50)         ,; // адрес больного
    m1MEST_INOG := 0, newMEST_INOG := 0,;
    MVID_UD                          ,; // вид удостоверения
    M1VID_UD    := 14                ,; // 1-18
    mser_ud := space(10), mnom_ud := space(20), mmesto_r := space(100), ;
    MKEMVYD, M1KEMVYD := 0, MKOGDAVYD := ctod(""),; // кем и когда выдан паспорт
    mspolis := space(10), mnpolis := space(20), msmo := '34007',;
    mnamesmo, m1namesmo,;
    m1company := 0, mcompany, mm_company, ;
    m1KOMU := 0, MKOMU, M1STR_CRB := 0, ;
    mvidpolis, m1vidpolis := 1,;
    msnils := space(11),;
    mokatog := padr(alltrim(okato_umolch),11,"0"),;
    m1adres_reg := 1, madres_reg,;
    rec_inogSMO := 0, ;
    mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100)
  if kod_kartotek > 0
    R_Use(dir_server+"kartote_",,"KART_")
    R_Use(dir_server+"kartotek",,"KART")
    select KART
    goto (kod_kartotek)
    select KART_
    goto (kod_kartotek)
    mFIO        := kart->FIO
    mpol        := kart->pol
    mDATE_R     := kart->DATE_R
    m1VZROS_REB := kart->VZROS_REB
    mADRES      := kart->ADRES
    msnils      := kart->snils
    if kart->MI_GIT == 9
      m1KOMU    := kart->KOMU
      M1STR_CRB := kart->STR_CRB
    endif
    if kart->MEST_INOG == 9 // т.е. отдельно занесены Ф.И.О.
      m1MEST_INOG := kart->MEST_INOG
    endif
    m1vidpolis  := kart_->VPOLIS // вид полиса (от 1 до 3);1-старый,2-врем.,3-новый
    mspolis     := kart_->SPOLIS // серия полиса
    mnpolis     := kart_->NPOLIS // номер полиса
    msmo        := kart_->SMO    // реестровый номер СМО
    m1vid_ud    := kart_->vid_ud   // вид удостоверения личности
    mser_ud     := kart_->ser_ud   // серия удостоверения личности
    mnom_ud     := kart_->nom_ud   // номер удостоверения личности
    m1kemvyd    := kart_->kemvyd   // кем выдан документ
    mkogdavyd   := kart_->kogdavyd // когда выдан документ
    mmesto_r    := kart_->mesto_r      // место рождения
    mokatog     := kart_->okatog       // код места жительства по ОКАТО
    m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
    //
    arr := retFamImOt(1,.f.)
    mfam := padr(arr[1],40)
    mim  := padr(arr[2],40)
    mot  := padr(arr[3],40)
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(1,@rec_inogSMO,.t.)
    elseif left(msmo,2) == '34'
      // Волгоградская область
    elseif !empty(msmo)
      m1ismo := msmo ; msmo := '34'
    endif
  endif
  close databases
endif
if tip_lu == TIP_LU_SMP .and. empty(mm_brigada)
  mm_brigada := {} ; mm_trombolit := {}
  Use_base("luslc")
  set order to 2
  find (glob_mo[_MO_KOD_TFOMS]+"71.")
  do while luslc->CODEMO == glob_mo[_MO_KOD_TFOMS] .and. left(luslc->shifr,3) == "71."
    // поиск цены по дате окончания лечения
    if between_date(luslc->datebeg,luslc->dateend,sys_date)
      if eq_any(left(luslc->shifr,5),"71.1.","71.2.")
        i := right(alltrim(luslc->shifr),1)
        if ascan(mm_brigada,{|x| x[2] == i }) == 0
          aadd(mm_brigada,{"-",i})
        endif
      elseif left(luslc->shifr,5) == "71.3."
        i := AfterAtNum(".",alltrim(luslc->shifr))
        if ascan(mm_trombolit,{|x| x[2] == i }) == 0
          aadd(mm_trombolit,{"-",i})
        endif
      endif
    endif
    skip
  enddo
  luslc->(dbCloseArea())
  if len(mm_brigada) == 0
    return func_error(4,"Ввод скорой помощи не разрешён в Вашей МО по состоянию на "+full_date(sys_date))
  endif
  asort(mm_brigada,,,{|x,y| x[2] < y[2] } )
  for i := 1 to len(mm_brigada)
    do case
      case mm_brigada[i,2] == '1'
        mm_brigada[i,1] := "1-фельдшерская"
        st_brigada := '1'
      case mm_brigada[i,2] == '2'
        mm_brigada[i,1] := "2-врачебная"
        st_brigada := '2'
      case mm_brigada[i,2] == '3'
        mm_brigada[i,1] := "3-интенсивной терапии"
      case mm_brigada[i,2] == '4'
        mm_brigada[i,1] := "4-анестезиологии и реаниматологии"
      case mm_brigada[i,2] == '5'
        mm_brigada[i,1] := "5-кардиологическая"
      case mm_brigada[i,2] == '6'
        mm_brigada[i,1] := "6-педиатрическая"
    endcase
  next
  if len(mm_trombolit) > 0
    asort(mm_trombolit,,,{|x,y| val(x[2]) < val(y[2]) } )
    st_trombolit := mm_trombolit[1,2]
    for i := 1 to len(mm_trombolit)
      do case
        case mm_trombolit[i,2] == '1'
          mm_trombolit[i,1] := "фельдшерская - применение актилизе"
        case mm_trombolit[i,2] == '2'
          mm_trombolit[i,1] := "фельдшерская - применение фортолезина"
        case mm_trombolit[i,2] == '3'
          mm_trombolit[i,1] := "фельдшерская - применение пуролазы"
        case mm_trombolit[i,2] == '4'
          mm_trombolit[i,1] := "фельдшерская - применение метализе"
        case mm_trombolit[i,2] == '5'
          mm_trombolit[i,1] := "врачебная - применение актилизе"
        case mm_trombolit[i,2] == '6'
          mm_trombolit[i,1] := "врачебная - применение фортолезина"
        case mm_trombolit[i,2] == '7'
          mm_trombolit[i,1] := "врачебная - применение пуролазы"
        case mm_trombolit[i,2] == '8'
          mm_trombolit[i,1] := "врачебная - применение метализе"
        case mm_trombolit[i,2] == '9'
          mm_trombolit[i,1] := "спец.врачебная - применение актилизе"
        case mm_trombolit[i,2] == '10'
          mm_trombolit[i,1] := "спец.врачебная - применение фортолезина"
        case mm_trombolit[i,2] == '11'
          mm_trombolit[i,1] := "спец.врачебная - применение пуролазы"
        case mm_trombolit[i,2] == '12'
          mm_trombolit[i,1] := "спец.врачебная - применение метализе"
      endcase
    next
  endif
endif
if tip_lu == TIP_LU_NMP .and. empty(mm_spec)
  mm_spec := {{"фельдшер",1},{"врач",2}}
endif
chm_help_code := 3002
//
ar := GetIniVar(tmp_ini,{{"RAB_MESTO","kart_polis","1"}} )
Private mm_rslt := {}, mm_ishod := {}, rslt_umolch := 401, ishod_umolch := 401, p_find_polis := int(val(ar[1]))
if tip_lu == TIP_LU_NMP
  rslt_umolch := 301 ; ishod_umolch := 301
endif
//
if mem_smp_input == 0
  Private mfio := space(50), mpol, mdate_r, madres, ;
          M1VZROS_REB, MVZROS_REB, m1company := 0, mcompany, mm_company,;
          mkomu, M1KOMU := 0, M1STR_CRB := 0,; // 0-ОМС,1-компании,3-комитеты/ЛПУ,5-личный счет
          msmo := "34007", rec_inogSMO := 0,;
          mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100),;
          mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20)
endif
Private mkod := Loc_kod, mtip_h, is_talon := .f.,;
        mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
  M1LPU := glob_uch[1], MLPU,;
  M1OTD := glob_otd[1], MOTD,;
  M1FIO_KART := 1, MFIO_KART,;
  MUCH_DOC    := 0                 ,; // вид и номер учетного документа
  MKOD_DIAG   := SKOD_DIAG         ,; // шифр 1-ой осн.болезни
  MKOD_DIAG2  := space(5)          ,; // шифр 2-ой осн.болезни
  MKOD_DIAG3  := space(5)          ,; // шифр 3-ой осн.болезни
  MKOD_DIAG4  := space(5)          ,; // шифр 4-ой осн.болезни
  MSOPUT_B1   := space(5)          ,; // шифр 1-ой сопутствующей болезни
  MSOPUT_B2   := space(5)          ,; // шифр 2-ой сопутствующей болезни
  MSOPUT_B3   := space(5)          ,; // шифр 3-ой сопутствующей болезни
  MSOPUT_B4   := space(5)          ,; // шифр 4-ой сопутствующей болезни
  MDIAG_PLUS  := space(8)          ,; // дополнения к диагнозам
  mrslt, m1rslt := st_rslt         ,; // результат
  mishod, m1ishod := st_ishod      ,; // исход
  MN_DATA := MK_DATA := st_N_DATA         ,; // дата начала лечения
  MVRACH      := space(10)         ,; // фамилия и инициалы лечащего врача
  M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0,; // код, таб.№ и спец-ть лечащего врача
  MF14_EKST, M1F14_EKST := 0       ,; //
  m1novor := 0, mnovor, mcount_reb := 0,;
  mDATE_R2 := ctod(""), mpol2 := " ",;
  mbrigada, m1brigada := st_brigada,;
  mtrombolit, m1trombolit := st_trombolit,;
  m1brig := 0, mbrig, mm_brig,;
  m1spec := 1, mspec,;
  mprer_b := space(28), m1prer_b := 0,; // прерывание беременности
  mm1prer_b := {{"по медицинским показаниям   ",1},;
                {"НЕ по медицинским показаниям",2}},;
  mm2prer_b := {{"постановка на учёт по берем.",1},;
                {"продолжение наблюдения      ",0}},;
  mm3prer_b := {{"отсутствие болевого синдрома",0},;
                {"острая боль                 ",1},;
                {"постоянная некупирующ. боль ",2},;
                {"другая постоянная боль      ",3},;
                {"боль неуточнённая           ",4}},;
  mtip, m1tip := 0,;
  musluga, m1usluga := 0,;
  mm_usluga := {{"А05.10.004.001 Расшифровка ЭКГ",1},;
                {"В01.015.007 Консультация кардиолога",2}},;
  m1USL_OK := iif(tip_lu == TIP_LU_SMP, 4, 3),;
  m1VIDPOM := iif(tip_lu == TIP_LU_SMP, 21, 11),;
  m1PROFIL := iif(tip_lu == TIP_LU_SMP, 84, 160),;
  m1IDSP   := iif(tip_lu == TIP_LU_SMP, 24, 41)
Private mm_prer_b := mm2prer_b
//
aeval(glob_V009,{|x| iif(x[5] == m1USL_OK, aadd(mm_rslt,x), nil) })
aeval(glob_V012,{|x| iif(x[5] == m1USL_OK, aadd(mm_ishod,x), nil) })
if ascan(mm_rslt, {|x| x[2] == rslt_umolch}) > 0
  m1rslt := rslt_umolch
endif
if ascan(mm_ishod, {|x| x[2] == ishod_umolch}) > 0
  m1ishod := ishod_umolch
endif
//
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, recno() into HUMAN_2
if mkod_k > 0
  if mem_smp_input == 0
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
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    mmesto_r    := kart_->mesto_r      // место рождения
    m1kemvyd    := kart_->kemvyd   // кем выдан документ
    mkogdavyd   := kart_->kogdavyd // когда выдан документ
    m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
    msmo        := kart_->SMO
    if kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    endif
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(1,,.t.) // открыть и закрыть
    endif
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
  mUCH_DOC    := int(val(human->uch_doc))
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
  mstatus_st  := human_->STATUS_ST
  m1VIDPOLIS  := human_->VPOLIS
  mSPOLIS     := human_->SPOLIS
  mNPOLIS     := human_->NPOLIS
  if empty(val(msmo := human_->SMO))
    m1komu := human->KOMU
    m1str_crb := human->STR_CRB
  else
    m1komu := m1str_crb := 0
  endif
  if human_->NOVOR > 0
    m1novor := 1
    mcount_reb := human_->NOVOR
    mDATE_R2 := human_->DATE_R2
    mpol2 := human_->POL2
  endif
  m1okato    := human_->OKATO  // ОКАТО субъекта РФ территории страхования
  M1F14_EKST := int(val(substr(human_->FORMA14, 1, 1)))
  mn_data := mk_data := human->N_DATA
  m1rslt     := human_->RSLT_NEW
  m1ishod    := human_->ISHOD_NEW
  if (ibrm := f_oms_beremenn(mkod_diag)) > 0
    m1prer_b := human_2->PN2
  endif
  //
  R_Use(dir_server+"uslugi",,"USL")
  use_base("human_u")
  find (str(Loc_kod,7))
  do while hu->kod == Loc_kod .and. !eof()
    usl->(dbGoto(hu->u_kod))
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
      lshifr := usl->shifr
    endif
    if tip_lu == TIP_LU_SMP .and. left(lshifr,3) == "71." .and. mrec_hu == 0
      if left(lshifr,5) == "71.3."
        m1trombolit := right(rtrim(lshifr),1)
        m1tip := 1
      else
        m1brigada := right(rtrim(lshifr),1)
        m1tip := 0
      endif
      mrec_hu := hu->(recno())
    elseif tip_lu == TIP_LU_NMP .and. eq_any(alltrim(lshifr),"2.80.27","2.80.28") .and. mrec_hu == 0
      m1spec := iif(alltrim(lshifr) == "2.80.27", 1, 2)
      mrec_hu := hu->(recno())
    else
      aadd(arr_del,hu->(recno()))
    endif
    select HU
    skip
  enddo
  for i := 1 to len(arr_del)
    select HU
    goto (arr_del[i])
    DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
  next
  if mem_smp_tel == 1
    R_Use(dir_server+"mo_su",,"MOSU")
    G_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
    find (str(Loc_kod,7))
    do while mohu->kod == Loc_kod .and. !eof()
      mosu->(dbGoto(mohu->u_kod))
      if alltrim(mosu->shifr1) == "A05.10.004.001"
        m1usluga := setbit(m1usluga,1)
        aadd(arr_usluga, {1,mohu->(recno())})
      elseif alltrim(mosu->shifr1) == "B01.015.007"
        m1usluga := setbit(m1usluga,2)
        aadd(arr_usluga, {2,mohu->(recno())})
      else
        aadd(arr_usluga, {0,mohu->(recno())})
      endif
      select MOHU
      skip
    enddo
  endif
  if alltrim(msmo) == '34'
    mnameismo := ret_inogSMO_name(2,@rec_inogSMO,.t.) // открыть и закрыть
  endif
endif
if !(left(msmo,2) == '34') // не Волгоградская область
  m1ismo := msmo ; msmo := '34'
endif
if m1vrach > 0
  R_Use(dir_server+"mo_pers",,"P2")
  goto (m1vrach)
  MTAB_NOM := p2->tab_nom
  m1prvs := -ret_new_spec(p2->prvs,p2->prvs_new)
  mvrach := padr(fam_i_o(p2->fio)+" "+ret_tmp_prvs(m1prvs),36)
endif
close databases
fv_date_r( iif(Loc_kod>0,mn_data,) )
MFIO_KART := _f_fio_kart()
mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
MNOVOR    := inieditspr(A__MENUVERT, mm_danet, M1NOVOR)
MF14_EKST := inieditspr(A__MENUVERT, mm_ekst_smp, M1F14_EKST)
mrslt     := inieditspr(A__MENUVERT, glob_V009, m1rslt)
mishod    := inieditspr(A__MENUVERT, glob_V012, m1ishod)
mlpu      := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
motd      := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
MKEMVYD   := inieditspr(A__POPUPMENU, dir_server+"s_kemvyd", M1KEMVYD)
mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
mtip      := inieditspr(A__MENUVERT, mm_danet, m1tip)
musluga   := inieditspr(A__MENUBIT,  mm_usluga,m1usluga)
mismo     := init_ismo(m1ismo)
if ibrm > 0
  mm_prer_b := iif(ibrm == 1, mm1prer_b, iif(ibrm == 2, mm2prer_b, mm3prer_b))
  if ibrm == 1 .and. m1prer_b == 0
    mprer_b := space(28)
  else
    mprer_b := inieditspr(A__MENUVERT, mm_prer_b, m1prer_b)
  endif
endif
if mem_smp_input == 1
  mvid_ud := inieditspr(A__MENUVERT, menu_vidud, m1vid_ud)
  madres_reg := ini_adres(1)
endif
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
if tip_lu == TIP_LU_SMP
  f_valid_brig(,-1,mm_brigada,mm_trombolit,st_brigada,st_trombolit)
  if m1tip == 0
    m1brig := m1brigada
  else
    m1brig := m1trombolit
  endif
  mbrig := inieditspr(A__MENUVERT, mm_brig, m1brig)
  str_1 := " случая оказания СМП"
else
  --top2
  mspec := inieditspr(A__MENUVERT, mm_spec, m1spec)
  str_1 := " случая оказания неотложной медицинской помощи"
endif
if Loc_kod == 0
  str_1 := "Добавление"+str_1
  mtip_h := yes_vypisan
else
  str_1 := "Редактирование"+str_1
endif
setcolor(color8)
myclear(top2)
@ top2-1,0 say padc(str_1,80) color "B/BG*"
Private gl_area := {1,0,maxrow()-1,maxcol(),0}
Private gl_arr := {;  // для битовых полей
  {"usluga","N",10,0,,,,{|x|inieditspr(A__MENUBIT,mm_usluga,x)} };
 }
@ maxrow(),0 say padc("<Esc> - выход;  <PgDn> - запись;  <F1> - помощь",maxcol()+1) color color0
mark_keys({"<F1>","<Esc>","<PgDn>"},"R/BG")
setcolor(cDataCGet)
make_diagP(1)  // сделать "шестизначные" диагнозы
diag_screen(0)
do while .t.
  j := top2
  if yes_num_lu == 1 .and. Loc_kod > 0
    @ j,50 say padl("Лист учета № "+lstr(Loc_kod),29) color color14
  endif
  //
  ++j; @ j,1 say "Учреждение" get mlpu when .f. color cDataCSay
       @ row(),col()+2 say "Отделение" get motd when .f. color cDataCSay
  //
if tip_lu == TIP_LU_SMP
  ++j; @ j,1 say "Карта вызова: №" get much_doc picture "999999"
       @ row(),col() say ", дата выезда" get mn_data ;
             valid {|g| mk_data := mn_data, f_k_data(g,1)}
else
  ++j; @ j,1 say "Карта №" get much_doc picture "999999"
       @ row(),col() say ", дата приёма" get mn_data ;
             valid {|g| mk_data := mn_data, f_k_data(g,1)}
endif
  //
if mem_smp_input == 0
  ++j; @ j,1 say "ФИО" get mfio_kart ;
       reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
       valid {|g,o| update_get("mkomu"),update_get("mcompany") }
else
  ++j; @ j,1 say "Полис ОМС: серия" get mspolis when m1komu == 0
       @ row(),col()+3 say "номер"  get mnpolis when m1komu == 0 ;
                       valid {|| findKartoteka(2,@mkod_k) }
       @ row(),col()+3 say "вид"    get mvidpolis ;
                    reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT,,,.f.)} ;
                    when m1komu == 0 ;
                    valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
  //
  ++j ; @ j,1 say "Фамилия" get mfam pict "@S33" ;
                valid {|g| lastkey()==K_UP .or. valFamImOt(1,mfam) }
    @ row(),col()+1 say "Имя" get mim pict "@S32" ;
                valid {|g| valFamImOt(2,mim) }
  ++j ; @ j,1 say "Отчество" get mot ;
                valid {|g| valFamImOt(3,mot) }
  if mem_pol == 1
    @ row(),70 say "Пол" get mpol ;
            reader {|x|menu_reader(x,menupol,A__MENUVERT,,,.f.)}
  else
    @ row(),70 say "Пол" get mpol pict "@!" valid {|g| mpol $ "МЖ" }
  endif
  ++j ; @ j,1 say "Дата рождения" get mdate_r ;
         valid {|| fv_date_r(mn_data), findKartoteka(1,@mkod_k) }
  @ row(),30 say "==>" get mvzros_reb when .f. color cDataCSay
  @ row(),50 say "СНИЛС" get msnils pict picture_pf ;
         valid {|| val_snils(msnils,1), findKartoteka(3,@mkod_k) }
  ++j ; @ j,1 say "Уд-ие личности:" get mvid_ud ;
         reader {|x|menu_reader(x,menu_vidud,A__MENUVERT,,,.f.)}
         @ j,42 say "Серия" get mser_ud pict "@!" valid val_ud_ser(1,m1vid_ud,mser_ud)
         @ j,col()+1 say "№" get mnom_ud pict "@!S18" valid val_ud_nom(1,m1vid_ud,mnom_ud)
  if tip_lu == TIP_LU_NMP
    ++j ; @ j,2 say "Место рождения" get mmesto_r pict "@S62"
    ++j ; @ j,2 say "Выдано" get mkogdavyd
          @ j,col() say "," get mkemvyd ;
          reader {|x|menu_reader(x,{{|k,r,c|get_s_kemvyd(k,r,c)}},A__FUNCTION,,,.f.)}
  endif
  ++j ; @ j,1 say "Адрес регистрации" get madres_reg ;
        reader {|x| menu_reader(x,{{|k,r,c| get_adres(1,k,r,c)}},A__FUNCTION,,,.f.)}
endif
  ++j; @ j,1 say "Принадлежность счёта" get mkomu ;
             reader {|x|menu_reader(x,mm_komu,A__MENUVERT,,,.f.)} ;
             valid {|g,o| f_valid_komu(g,o) } ;
             color colget_menu
       @ row(),col()+1 say "==>" get mcompany ;
           reader {|x|menu_reader(x,mm_company,A__MENUVERT,,,.f.)} ;
           when diag_screen(2) .and. m1komu < 5 ;
           valid {|g| func_valid_ismo(g,m1komu,38) }
  //
if mem_smp_input == 0
  ++j; @ j,1 say "Полис ОМС: серия" get mspolis when m1komu == 0
       @ row(),col()+3 say "номер"  get mnpolis when m1komu == 0
       @ row(),col()+3 say "вид"    get mvidpolis ;
                    reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT,,,.f.)} ;
                    when m1komu == 0 ;
                    valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
endif
  //
  ++j; @ j,1 say "Новорожденный?" get mnovor ;
             reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
             valid {|g,o| f_valid_novor(g,o) } ;
             color colget_menu
       @ row(),col()+3 say "№/пп ребёнка" get mcount_reb pict "99" range 1,99 ;
             when (m1novor == 1)
       @ row(),col()+3 say "Д.р. ребёнка" get mdate_r2 when (m1novor == 1)
  if mem_pol == 1
       @ row(),col()+3 say "Пол ребёнка" get mpol2 ;
           reader {|x|menu_reader(x,menupol,A__MENUVERT,,,.f.)} ;
           when diag_screen(2) .and. (m1novor == 1)
  else
       @ row(),col()+3 say "Пол ребёнка" get mpol2 pict "@!" ;
           valid {|g| mpol2 $ "МЖ" } ;
           when diag_screen(2) .and. (m1novor == 1)
  endif
  //
  ++j; @ j,1 say "Диагноз(ы)" get mkod_diag picture pic_diag ;
             reader {|o|MyGetReader(o,bg)} ;
             when when_diag() ;
             valid {|| val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2)), f_valid_beremenn(mkod_diag) }
       @ row(),col() say "," get mkod_diag2 picture pic_diag ;
             reader {|o|MyGetReader(o,bg)} ;
             when when_diag() ;
             valid val1_10diag(.t.,.t.,.t.,mn_data,iif(m1novor==0,mpol,mpol2))
if tip_lu == TIP_LU_SMP
       @ row(),col()+3 say "Форма оказания СМП" get MF14_EKST ;
            reader {|x|menu_reader(x,mm_ekst_smp,A__MENUVERT,,,.f.)}
endif
  ++j ; rdiag := j
  if (ibrm := f_oms_beremenn(mkod_diag)) == 1
       @ j,26 say "прерывание беременности"
  elseif ibrm == 2
       @ j,26 say "дисп.набл.за беременной"
  elseif ibrm == 3
       @ j,26 say "     боли при онкологии"
  endif
       @ j,51 get mprer_b ;
              reader {|x| menu_reader(x,mm_prer_b,A__MENUVERT,,,.f.)} ;
              when {|| diag_screen(2),;
                       ibrm := f_oms_beremenn(mkod_diag),;
                       mm_prer_b := iif(ibrm == 1, mm1prer_b, iif(ibrm == 2, mm2prer_b, mm3prer_b)),;
                       (ibrm > 0) }
  //
  ++j; @ j,1 say "Результат обращения" get mrslt ;
           reader {|x|menu_reader(x,mm_rslt,A__MENUVERT,,,.f.)} ;
           valid {|g,o| f_valid_rslt(g,o) }
  //
  ++j; @ j,1 say "Исход заболевания" get mishod ;
           reader {|x|menu_reader(x,mm_ishod,A__MENUVERT,,,.f.)}
  //
if tip_lu == TIP_LU_SMP
 if empty(mm_trombolit)
  ++j; @ j,1 say "Бригада СМП" get mbrig ;
            reader {|x|menu_reader(x,mm_brig,A__MENUVERT,,,.f.)}
 else
  ++j; @ j,1 say "Тромболитическая терапия:" get mtip ;
            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
            valid {|g,o| f_valid_brig(g,o,mm_brigada,mm_trombolit,st_brigada,st_trombolit) }
       @ j,32 say "Бригада СМП" get mbrig ;
            reader {|x|menu_reader(x,mm_brig,A__MENUVERT,,,.f.)}
 endif
 if mem_smp_tel == 1
  ++j; @ j,1 say "Услуга(и) телемедицины" get musluga ;
             reader {|x| menu_reader(x,mm_usluga,A__MENUBIT,,,.f.)}
 endif
else
  ++j; @ j,1 say "Врач (фельдшер)" get mspec ;
            reader {|x|menu_reader(x,mm_spec,A__MENUVERT,,,.f.)}
endif
  //
  ++j; @ j,1 say "Таб.№ врача (фельдшера)" get MTAB_NOM pict "99999" ;
             valid {|g| v_kart_vrach(g,.t.) } when diag_screen(2)
       @ row(),col()+1 get mvrach when .f. color color14
  if !empty(a_smert)
    n_message(a_smert,,"GR+/R","W+/R",,,"G+/R")
  endif
  if pos_read > 0 .and. lower(GetList[pos_read]:name) == "mvrach"
    --pos_read
  endif
  count_edit := myread(,@pos_read,++k_read)
  diag_screen(2)
  k := f_alert({padc("Выберите действие",60,".")},;
               {" Выход без записи "," Запись "," Возврат в редактирование "},;
               iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
  if k == 3
    loop
  elseif k == 2
    if empty(much_doc)
      func_error(4,'Не заполнен номер карты'+iif(tip_lu==TIP_LU_SMP,' вызова',''))
      loop
    endif
    if empty(mn_data)
      func_error(4,'Не введена дата '+iif(tip_lu==TIP_LU_SMP,'выезда.','приёма.'))
      loop
    elseif tip_lu == TIP_LU_SMP .and. year(mn_data) < 2016 .and. m1tip == 1
      func_error(4,"Тромболитическая терапия разрешена только с 2016 года.")
      loop
    endif
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
    if mem_smp_input == 1
      if empty(mfio)
        func_error(4,"Не введены Ф.И.О. Нет записи!")
        loop
      endif
      if empty(mdate_r)
        func_error(4,'Не заполнена дата рождения')
        loop
      endif
      if tip_lu == TIP_LU_NMP .and. eq_any(m1vid_ud,3,14) .and. ;
                                          !empty(mser_ud) .and. empty(del_spec_symbol(mmesto_r))
        func_error(4,iif(m1vid_ud==3,'Для свид-ва о рождении','Для паспорта РФ')+;
                     ' обязательно заполнение поля "Место рождения"')
        loop
      endif
    endif
    if empty(mkod_diag)
      func_error(4,"Не введен шифр основного заболевания.")
      loop
    endif
    err_date_diap(mn_data,"Дата выезда")
    if mem_op_out == 2 .and. yes_parol
      box_shadow(19,10,22,69,cColorStMsg)
      str_center(20,'Оператор "'+fio_polzovat+'".',cColorSt2Msg)
      str_center(21,'Ввод данных за '+date_month(sys_date),cColorStMsg)
    endif
    mywait()
    make_diagP(2)  // сделать "пятизначные" диагнозы
    if m1komu == 0
      msmo := lstr(m1company)
      m1str_crb := 0
    else
      msmo := ""
      m1str_crb := m1company
    endif
    Private old_vzros_reb := M1VZROS_REB
    fv_date_r(MN_DATA) // переопределение M1VZROS_REB
    if tip_lu == TIP_LU_SMP // определяем шифр услуги СМП
      lshifr := "71."
      if m1tip == 0
        if is_komm_SMP() .and. mk_data < 0d20190501 // если это коммерческая скорая
          lshifr += "2."
        elseif m1komu == 0
          if len(alltrim(msmo)) == 5 .and. left(msmo,2) == '34'
            lshifr += "1."
          else
            lshifr += "2."
          endif
        else
          lshifr += "1."
        endif
        lshifr += m1brig
        st_brigada := m1brig
      else // тромболитическая терапия
        lshifr += "3."+m1brig
        st_trombolit := m1brig
        M1F14_EKST := 1 // экстренная
      endif
    else // определяем шифр услуги НМП
      lshifr := iif(m1spec == 1, "2.80.27", "2.80.28")
    endif
    lshifr := padr(lshifr,10)
    //
    Use_base("lusl")
    Use_base("luslc")
    Use_base("uslugi")
    R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                                dir_server+"uslugi1s"},"USL1")
    Private mu_kod, mu_cena
    glob_podr := "" ; glob_otd_dep := 0
    mu_kod := foundOurUsluga(lshifr,mk_data,m1PROFIL,M1VZROS_REB,@mu_cena)
    if mem_smp_input == 1
      mfio := rtrim(mfam)+" "+rtrim(mim)+" "+mot
      if TwoWordFamImOt(mfam) .or. TwoWordFamImOt(mim) .or. TwoWordFamImOt(mot)
        newMEST_INOG := 9
      endif
      Use_base("kartotek")
      if mkod_k == 0  // добавление в картотеку
        Add1Rec(7)
        glob_kartotek := mkod_k := kart->kod := recno()
      else
        find (str(mkod_k,7))
        if found()
          G_RLock(forever)
        else
          Add1Rec(7)
          glob_kartotek := mkod_k := kart->kod := recno()
        endif
      endif
      glob_k_fio := alltrim(mfio)
      //
      kart->FIO       := mfio
      kart->pol       := mpol
      kart->DATE_R    := mdate_r
      kart->VZROS_REB := old_vzros_reb
      kart->ADRES     := mADRES
      kart->POLIS     := make_polis(mspolis,mnpolis) // серия и номер страхового полиса
      kart->snils     := msnils
      kart->KOMU      := m1KOMU
      kart->STR_CRB   := m1str_crb
      kart->MI_GIT    := 9
      kart->MEST_INOG := newMEST_INOG
      //
      select KART2
      do while kart2->(lastrec()) < mkod_k
        APPEND BLANK
      enddo
      //
      select KART_
      do while kart_->(lastrec()) < mkod_k
        APPEND BLANK
      enddo
      goto (mkod_k)
      G_RLock(forever)
      kart_->VPOLIS := m1vidpolis
      kart_->SPOLIS := mSPOLIS
      kart_->NPOLIS := mNPOLIS
      kart_->SMO    := msmo
      kart_->vid_ud := m1vid_ud
      kart_->ser_ud := mser_ud
      kart_->nom_ud := mnom_ud
      if tip_lu == TIP_LU_NMP
        kart_->mesto_r  := mmesto_r
        kart_->kemvyd   := m1kemvyd
        kart_->kogdavyd := mkogdavyd
      endif
      kart_->okatog := mokatog
      Private fl_nameismo := .f.
      if m1komu == 0 .and. m1company == 34
        kart_->KVARTAL_D := m1okato // ОКАТО субъекта РФ территории страхования
        if empty(m1ismo)
          if !empty(mnameismo)
            fl_nameismo := .t.
          endif
        else
          kart_->SMO := m1ismo  // заменяем "34" на код иногородней СМО
        endif
      endif
      if m1MEST_INOG == 9 .or. newMEST_INOG == 9
        G_Use(dir_server+"mo_kfio",,"KFIO")
        index on str(kod,7) to (cur_dir+"tmp_kfio")
        find (str(mkod_k,7))
        if found()
          if newMEST_INOG == 9
            G_RLock(forever)
            kfio->FAM := mFAM
            kfio->IM  := mIM
            kfio->OT  := mOT
          else
            DeleteRec(.t.)
          endif
        else
          if newMEST_INOG == 9
            AddRec(7)
            kfio->kod := mkod_k
            kfio->FAM := mFAM
            kfio->IM  := mIM
            kfio->OT  := mOT
          endif
        endif
      endif
      if fl_nameismo .or. rec_inogSMO > 0
        G_Use(dir_server+"mo_kismo",,"SN")
        index on str(kod,7) to (cur_dir+"tmp_ismo")
        find (str(mkod_k,7))
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
            sn->kod := mkod_k
            sn->smo_name := mnameismo
          endif
        endif
        sn->(dbCloseArea())
      endif
    endif
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
    if isbit(mem_oms_pole,1)  //  "сроки лечения",;  1
      st_N_DATA := MN_DATA
    endif
    if isbit(mem_oms_pole,2)  //  "леч.врач",;       2
      st_VRACH := m1vrach
    endif
    if isbit(mem_oms_pole,3)  //  "осн.диагноз",;    3
      SKOD_DIAG := substr(MKOD_DIAG,1,5)
    endif
    if isbit(mem_oms_pole,5)  //  "результат",;      5
      st_RSLT := m1rslt
    endif
    if isbit(mem_oms_pole,6)  //  "исход",;          6
      st_ISHOD := m1ishod
    endif
    st_brigada := m1brigada
    glob_perso := mkod
    //
    human->kod_k      := mkod_k
    human->TIP_H      := B_STANDART
    human->FIO        := MFIO          // Ф.И.О. больного
    human->POL        := MPOL          // пол
    human->DATE_R     := MDATE_R       // дата рождения больного
    human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
    human->ADRES      := MADRES        // адрес больного
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
    human->POLIS      := make_polis(mspolis,mnpolis) // серия и номер страхового полиса
    human->LPU        := M1LPU         // код учреждения
    human->OTD        := M1OTD         // код отделения
    human->UCH_DOC    := lstr(MUCH_DOC) // вид и номер учетного документа
    human->N_DATA := human->K_DATA := MN_DATA // дата начала-окончания лечения
    human->CENA := human->CENA_1 := mu_cena // стоимость лечения
    human_->DISPANS   := replicate("0",16)
    human_->VPOLIS    := m1vidpolis
    human_->SPOLIS    := ltrim(mspolis)
    human_->NPOLIS    := ltrim(mnpolis)
    human_->OKATO     := "" // это поле вернётся из ТФОМС в случае иногороднего
    human_->NOVOR     := iif(m1novor==0, 0       , mcount_reb)
    human_->DATE_R2   := iif(m1novor==0, ctod(""), mDATE_R2  )
    human_->POL2      := iif(m1novor==0, ""      , mpol2     )
    human_->USL_OK    := m1USL_OK //  4
    human_->VIDPOM    := m1VIDPOM //  2
    human_->PROFIL    := m1PROFIL // 84
    human_->IDSP      := m1IDSP   // 24
    human_->FORMA14   := str(M1F14_EKST,1)+"000"
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
    if f_oms_beremenn(mkod_diag) > 0
      human_2->PN2 := m1prer_b
    endif
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
    use_base("human_u")
    select HU
    if mrec_hu == 0
      Add1Rec(7)
      mrec_hu := hu->(recno())
    else
      goto (mrec_hu)
      G_RLock(forever)
    endif
    replace hu->kod     with human->kod,;
            hu->kod_vr  with m1vrach,;
            hu->kod_as  with 0,;
            hu->u_koef  with 1,;
            hu->u_kod   with mu_kod,;
            hu->u_cena  with mu_cena,;
            hu->is_edit with 0,;
            hu->date_u  with dtoc4(MK_DATA),;
            hu->otd     with m1otd,;
            hu->kol     with 1,;
            hu->stoim   with mu_cena,;
            hu->kol_1   with 1,;
            hu->stoim_1 with mu_cena,;
            hu->KOL_RCP with 0
    select HU_
    do while hu_->(lastrec()) < mrec_hu
      APPEND BLANK
    enddo
    goto (mrec_hu)
    G_RLock(forever)
    if Loc_kod == 0 .or. !valid_GUID(hu_->ID_U)
      hu_->ID_U := mo_guid(3,hu_->(recno()))
    endif
    hu_->PROFIL   := m1PROFIL
    hu_->PRVS     := m1PRVS
    hu_->kod_diag := mkod_diag
    hu_->zf       := ""
    //
    if mem_smp_tel == 1 .and. (len(arr_usluga) > 0 .or. m1usluga > 0)
      for i := 1 to 2
        j := ascan(arr_usluga,{|x| x[1] == i })
        if isbit(m1usluga,i)
          if j == 0
            aadd(arr_usluga, {i,0})
          endif
        else
          if j > 0
            arr_usluga[j,1] := 0
          endif
        endif
      next
      use_base("luslf")
      Use_base("mo_su")
      Use_base("mo_hu")
      for i := 1 to len(arr_usluga)
        if arr_usluga[i,1] > 0
          kod_uslf := 0
          lshifr := iif(arr_usluga[i,1] == 1, "A05.10.004.001", "B01.015.007")
          select MOSU
          set order to 3 // по шифру ФФОМС
          find (padr(lshifr,20))
          if found()
            kod_uslf := mosu->kod
          else
            select LUSLF
            find (padr(lshifr,20))
            if found()
              select MOSU
              set order to 1
              FIND (STR(-1,6))
              if found()
                G_RLock(forever)
              else
                AddRec(6)
              endif
              kod_uslf := mosu->kod := recno()
              mosu->name := luslf->name
              mosu->shifr1 := lshifr
              mosu->PROFIL := 0
            endif
          endif
          if !empty(kod_uslf)
            select MOHU
            if arr_usluga[i,2] > 0
              goto (arr_usluga[i,2])
              G_RLock(forever)
            else
              Add1Rec(7)
            endif
            mohu->kod     := human->kod
            mohu->kod_vr  := 0
            mohu->u_kod   := kod_uslf
            mohu->u_cena  := 0
            mohu->date_u  := dtoc4(MK_DATA)
            mohu->date_u2 := dtoc4(MK_DATA)
            mohu->otd     := m1otd
            mohu->kol_1   := 1
            mohu->stoim_1 := 0
            mohu->ID_U    := mo_guid(4,mohu->(recno()))
            mohu->PROFIL  := m1PROFIL
            mohu->PRVS    := m1PRVS
            mohu->kod_diag:= mkod_diag
          endif
        else
          select MOHU
          if arr_usluga[i,2] > 0
            goto (arr_usluga[i,2])
            DeleteRec(.t.)
          endif
        endif
      next i
    endif
    //
    write_work_oper(glob_task,OPER_LIST,iif(Loc_kod==0,1,2),1,count_edit)
    fl_write_sluch := .t.
    close databases
    stat_msg("Запись завершена!",.f.)
  endif
  exit
enddo
close databases
diag_screen(2)
setcolor(tmp_color)
restscreen(buf)
chm_help_code := tmp_help
if fl_write_sluch // если записали - запускаем проверку
  if type("fl_edit_smp") == "L"
    fl_edit_smp := .t.
  endif
  if !empty(val(msmo))
    verify_OMS_sluch(glob_perso)
  endif
endif
return NIL

***** 26.01.16 действия в ответ на выбор в меню "Тромболитическая терапия:"
Function f_valid_brig(get,old,menu1,menu2,st1,st2)
if m1tip != old .and. old != NIL
  mm_brig := {}
  if m1tip == 0 //
    mm_brig := aclone(menu1)
    m1brig := st1
  else
    mm_brig := aclone(menu2)
    m1brig := st2
  endif
  mbrig := padr(inieditspr(A__MENUVERT, mm_brig, m1brig),40)
  update_get("mbrig")
endif
return .t.

***** 28.04.20 добавление или редактирование случая (листа учета)
Function oms_sluch(Loc_kod,kod_kartotek)
// Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
// kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
Static SKOD_DIAG := '     ', st_l_z := 1, st_N_DATA, st_K_DATA, st_rez_gist,;
       st_vrach := 0, st_profil := 0, st_profil_k := 0, st_rslt := 0, st_ishod := 0, st_povod := 9
Static menu_bolnich := {{"нет",0},{"да ",1},{"РОД",2}}
Local bg := {|o,k| get_MKB10(o,k,.t.) },;
      buf, tmp_color := setcolor(), a_smert := {},;
      p_uch_doc := "@!", pic_diag := "@K@!",;
      i, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0,;
      tmp_help := chm_help_code, fl_write_sluch := .f., when_uch_doc := .t.
Local mm_reg_lech := {{"Основные",0},{"Дополнительные",9}}
if len(glob_otd) > 2 .and. glob_otd[3] == 4 // скорая помощь
  return oms_sluch_SMP(Loc_kod,kod_kartotek,TIP_LU_SMP)
elseif len(glob_otd) > 3
  if eq_any(glob_otd[4],TIP_LU_SMP,TIP_LU_NMP) // скорая помощь (неотложная медицинская помощь)
    return oms_sluch_SMP(Loc_kod,kod_kartotek,glob_otd[4])
  elseif eq_any(glob_otd[4],TIP_LU_DDS,TIP_LU_DDSOP) // диспансеризация сирот
    return oms_sluch_DDS(glob_otd[4],Loc_kod,kod_kartotek)
  elseif glob_otd[4] == TIP_LU_DVN   // диспансеризация взрослого населения
    return oms_sluch_DVN(Loc_kod,kod_kartotek)
  elseif glob_otd[4] == TIP_LU_PN    // профосмотры несовершеннолетних
    return oms_sluch_PN(Loc_kod,kod_kartotek)
  elseif glob_otd[4] == TIP_LU_PREDN // предварительные осмотры несовершеннолетних
    return func_error(4,"С 2018 года предварительные осмотры несовершеннолетних не проводятся")
  elseif glob_otd[4] == TIP_LU_PERN  // периодические осмотры несовершеннолетних
    return func_error(4,"С 2018 года периодические осмотры несовершеннолетних не проводятся")
  elseif glob_otd[4] == TIP_LU_PREND // пренатальная диагностика
    return oms_sluch_PrenD(Loc_kod,kod_kartotek)
  elseif glob_otd[4] == TIP_LU_G_CIT // жидкостная цитология рака шейки матки
    return oms_sluch_g_cit(Loc_kod,kod_kartotek)
  endif
endif
Default st_N_DATA TO sys_date, st_K_DATA TO sys_date
Default Loc_kod TO 0, kod_kartotek TO 0
if kod_kartotek == 0 // добавление в картотеку
  if (kod_kartotek := edit_kartotek(0,,,.t.)) == 0
    return NIL
  endif
endif
if Loc_kod == 0 .and. len(glob_otd) > 3 // только при добавлении
  if is_hemodializ .and. glob_otd[4] == TIP_LU_H_DIA  // гемодиализ
    return oms_sluch_dializ(1,Loc_kod,kod_kartotek)
  elseif is_per_dializ .and. glob_otd[4] == TIP_LU_P_DIA  // перит.диализ
    return oms_sluch_dializ(2,Loc_kod,kod_kartotek)
  endif
endif
// Определить окно k*80 символов
kscr1 := iif(is_MO_VMP,30,26)
if is_dop_ob_em
  ++kscr1
endif
if is_reabil_slux
  ++kscr1
endif
buf := savescreen()
if is_uchastok == 1 .and. is_task(X_REGIST) // У23/12356 и есть "Регистратура"
  when_uch_doc := (mem_edit_ist == 2)
endif
//
chm_help_code := 3002
//
Private tmp_V006 := create_classif_FFOMS(2,"V006") // USL_OK
Private tmp_V002 := create_classif_FFOMS(2,"V002") // PROFIL
Private tmp_V020 := create_classif_FFOMS(2,"V020") // PROFIL_K
Private tmp_V009 := cut_glob_array(glob_V009,sys_date) // rslt
Private tmp_V012 := cut_glob_array(glob_V012,sys_date) // ishod
Private mm_rslt, mm_ishod, rslt_umolch := 0, ishod_umolch := 0
//
Private mkod := Loc_kod, mtip_h, is_talon := .f., ibrm := 0,;
        mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
  M1LPU := glob_uch[1], MLPU,;
  M1OTD := glob_otd[1], MOTD,;
  mfio := space(50), mpol, mdate_r, madres, mmr_dol,;
  M1FIO_KART := 1, MFIO_KART,;
  M1VZROS_REB, MVZROS_REB, mpolis, M1RAB_NERAB,;
  MUCH_DOC    := space(10)         ,; // вид и номер учетного документа
  MKOD_DIAG0  := space(6)          ,; // шифр первичного диагноза
  MKOD_DIAG   := SKOD_DIAG         ,; // шифр 1-ой осн.болезни
  MKOD_DIAG2  := space(5)          ,; // шифр 2-ой осн.болезни
  MKOD_DIAG3  := space(5)          ,; // шифр 3-ой осн.болезни
  MKOD_DIAG4  := space(5)          ,; // шифр 4-ой осн.болезни
  MSOPUT_B1   := space(5)          ,; // шифр 1-ой сопутствующей болезни
  MSOPUT_B2   := space(5)          ,; // шифр 2-ой сопутствующей болезни
  MSOPUT_B3   := space(5)          ,; // шифр 3-ой сопутствующей болезни
  MSOPUT_B4   := space(5)          ,; // шифр 4-ой сопутствующей болезни
  MDIAG_PLUS  := space(8)          ,; // дополнения к диагнозам
  adiag_talon[16]                  ,; // из статталона к диагнозам
  mprer_b := space(28), m1prer_b := 0,; // прерывание беременности
  mrslt, m1rslt := st_rslt         ,; // результат
  mishod, m1ishod := st_ishod      ,; // исход
  m1company := 0, mcompany, mm_company,;
  mkomu, M1KOMU := 0, M1STR_CRB := 0,; // 0-ОМС,1-компании,3-комитеты/ЛПУ,5-личный счет
  m1NPR_MO := "", mNPR_MO := space(10), mNPR_DATE := ctod(""),;
  m1reg_lech := 0, mreg_lech,;
  MN_DATA     := st_N_DATA         ,; // дата начала лечения
  MK_DATA     := st_K_DATA         ,; // дата окончания лечения
  MCENA_1     := 0                 ,; // стоимость лечения
  MVRACH      := space(10)         ,; // фамилия и инициалы лечащего врача
  M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0,; // код, таб.№ и спец-ть лечащего врача
  MBOLNICH, M1BOLNICH := 0         ,; // больничный
  MDATE_B_1   := ctod("")          ,; // дата начала больничного
  MDATE_B_2   := ctod("")          ,; // дата окончания больничного
  mrodit_dr   := ctod("")          ,; // дата рождения родителя
  mrodit_pol  := " "               ,; // пол родителя
  MF14_EKST, M1F14_EKST := 0       ,; //
  MF14_SKOR, M1F14_SKOR := 0       ,; //
  MF14_VSKR, M1F14_VSKR := 0       ,; //
  MF14_RASH, M1F14_RASH := 0       ,; //
  m1novor := 0, mnovor, mcount_reb := 0,;
  mDATE_R2 := ctod(""), mpol2 := " ",;
  m1USL_OK := 0, mUSL_OK,;
  m1P_PER := 0, mP_PER := space(35),; // Признак поступления/перевода 1-4
  m1PROFIL := st_profil, mPROFIL,;
  m1PROFIL_K := st_profil_k, mPROFIL_K,;
  m1vid_reab := 0, mvid_reab,;
  mstatus_st := space(10),;
  mpovod, m1povod := st_povod,;
  mtravma, m1travma := 0, ;
  MOSL1 := SPACE(6)     ,; // шифр 1-ого диагноза осложнения заболевания
  MOSL2 := SPACE(6)     ,; // шифр 2-ого диагноза осложнения заболевания
  MOSL3 := SPACE(6)     ,; // шифр 3-ого диагноза осложнения заболевания
  MVMP, M1VMP := 0      ,; // 0-нет,1-да ВМП
  mtal_num := space(20),; // номер талона на ВМП
  MVIDVMP, M1VIDVMP := SPACE(12),; // вид ВМП по справочнику V018
  MMETVMP, M1METVMP := 0,; // метод ВМП по справочнику V019 //  mstentvmp := " ",; // кол-во стентов для методов ВМП 498,499
  mTAL_D := ctod(""),; // Дата выдачи талона на ВМП
  mTAL_P := ctod(""),; // Дата планируемой госпитализации в соответствии с талоном на ВМП
  MVNR  := space(4)     ,; // вес недоношенного ребёнка (лечится ребёнок)
  MVNR1 := space(4)     ,; // вес 1-го недоношенного ребёнка (лечится мать)
  MVNR2 := space(4)     ,; // вес 2-го недоношенного ребёнка (лечится мать)
  MVNR3 := space(4)     ,; // вес 3-го недоношенного ребёнка (лечится мать)
  input_vnr := .f., input_vnrm := .f.,;
  msmo := "", rec_inogSMO := 0,;
  mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100),;
  mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20),;
  m1_l_z := st_l_z, m_l_z,;             // лечение завершено ?
  mm1prer_b := {{"по медицинским показаниям   ",1},;
                {"НЕ по медицинским показаниям",2}},;
  mm2prer_b := {{"постановка на учёт по берем.",1},;
                {"продолжение наблюдения      ",0}},;
  mm3prer_b := {{"отсутствие болевого синдрома",0},;
                {"острая боль                 ",1},;
                {"постоянная некупирующ. боль ",2},;
                {"другая постоянная боль      ",3},;
                {"боль неуточнённая           ",4}},;
  mm_p_per := {{"Поступил самостоятельно",1},;
               {"Доставлен СМП",2},;
               {"Перевод из другой МО",3},;
               {"Перевод внутри МО",4}}
Private mm_prer_b := mm2prer_b
  if mem_zav_l == 1  // да
    m1_l_z := 1   // да
  elseif mem_zav_l == 2  // нет
    m1_l_z := 0   // нет
  endif
Private mad_cr := space(10), m1ad_cr := space(10), mm_ad_cr := {}, pr_ds_it := 0, input_ad_cr := .f.
// онкология
Private is_oncology := 0, old_oncology := .f.,;
        mDS_ONK, m1DS_ONK := 0,; // Признак подозрения на злокачественное новообразование
        mDS1_T, m1DS1_T := 0,; // Повод обращения:0 - первичное лечение;1 - рецидив;2 - прогрессирование
        mPR_CONS, m1PR_CONS := 0,; // Сведения о проведении консилиума:1 - определена тактика обследования;2 - определена тактика лечения;3 - изменена тактика лечения.
        mDT_CONS := ctod(""),; // Дата проведения консилиума    Обязательно к заполнению при заполненном PR_CONS
        mSTAD, m1STAD := 0,; // Стадия заболевания      Заполняется в соответствии со справочником N002
        mONK_T, m1ONK_T := 0,; // Значение Tumor        Заполняется в соответствии со справочником N003
        mONK_N, m1ONK_N := 0,; // Значение Nodus        Заполняется в соответствии со справочником N004
        mONK_M, m1ONK_M := 0,; // Значение Metastasis   Заполняется в соответствии со справочником N005
        mMTSTZ, m1MTSTZ := 0,;   // Признак выявления отдалённых метастазов       Подлежит заполнению значением 1 при выявлении отдалённых метастазов только при DS1_T=1 или DS1_T=2
        mB_DIAG, m1B_DIAG := 98,; // гистология:99-не надо,98-сделана,97-нет результата,0-отказ,7-не показано,8-противопоказано
        mK_FR := space(2),; // кол-во фракций проведения лучевой терапии	Обязательно для заполнения при проведении лучевой или химиолучевой терапии (USL_TIP=3 или USL_TIP=4)м.б.=0
        mCRIT, m1crit := space(10),; // код схемы лек.терапии V024 (sh..., mt...)
        mCRIT2,; // доп.критерий (fr...)
        mm_shema_err := {{"соблюдён",0},{"не соблюдён",1}},;
        mm_shema_usl := {},;
        mWEI := space(5),; // масса тела в кг	Обязательно для заполнения при проведении лекарственной или химиолучевой терапии (USL_TIP=2 или USL_TIP=4)
        mHEI := space(3),; // рост в см	Обязательно для заполнения при проведении лекарственной или химиолучевой терапии (USL_TIP=2 или USL_TIP=4)
        mBSA := space(4)   // площадь поверхности тела в кв.м.	Обязательно для заполнения при проведении лекарственной или химиолучевой терапии (USL_TIP=2 или USL_TIP=4)
dbcreate(cur_dir+"tmp_onkna", {; // онконаправления
   {"KOD"      ,   "N",     7,     0},; // код больного
   {"NAPR_DATE",   "D",     8,     0},; // Дата направления
   {"NAPR_MO",     "C",     6,     0},; // код другого МО, куда выписано направление
   {"NAPR_V"  ,    "N",     1,     0},; // Вид направления:1-к онкологу,2-на биопсию,3-на дообследование,4-для опр.тактики лечения
   {"MET_ISSL" ,   "N",     1,     0},; // Метод диагностического исследования(при NAPR_V=3):1-лаб.диагностика;2-инстр.диагностика;3-луч.диагностика;4-КТ, МРТ, ангиография
   {"shifr"  ,     "C",    20,     0},;
   {"shifr_u"  ,   "C",    20,     0},;
   {"shifr1"   ,   "C",    20,     0},;
   {"name_u"   ,   "C",    65,     0},;
   {"U_KOD"    ,   "N",     6,     0};  // код услуги
  })
Private m1NAPR_MO, mNAPR_MO, mNAPR_DATE, mNAPR_V, m1NAPR_V, mMET_ISSL, m1MET_ISSL, ;
        mshifr, mshifr1, mname_u, mU_KOD, cur_napr := 0, count_napr := 0, tip_onko_napr := 0
Private mm_napr_v := {{"нет",0},;
                      {"к онкологу",1},;
                      {"на биопсию",2},;
                      {"на дообследование",3},;
                      {"для определения тактики лечения",4}}
Private mm_met_issl := {{"нет",0},;
                        {"лабораторная диагностика",1},;
                        {"инструментальная диагностика",2},;
                        {"методы лучевой диагностики (недорогостоящие)",3},;
                        {"дорогостоящие методы лучевой диагностики",4}}
Private mm_DS1_T := {{"первичное лечение",0},;  // N019
                     {"лечение при рецидиве",1},;
                     {"лечение при прогрессировании",2},;
                     {"динамическое наблюдение",3},;
                     {"диспансерное наблюдение (здоров/ремиссия)",4},;
                     {"диагностика (без специфического лечения)",5},;
                     {"симптоматическое лечение",6}}
Private mm_PR_CONS := {{"отсутствует необходимость проведения",0},; // N019
                       {"определена тактика обследования",1},;
                       {"определена тактика лечения",2},;
                       {"изменена тактика лечения",3}}
if empty(st_rez_gist) // для гистологии в поликлинике
  st_rez_gist := {}
  R_Use(exe_dir+"_mo_N008",cur_dir+"_mo_N008","N8")
  R_Use(exe_dir+"_mo_N007",cur_dir+"_mo_N007","N7")
  go top
  do while !eof()
    aadd(st_rez_gist,{n7->mrf_name,n7->id_mrf,{},0}) ; i := len(st_rez_gist)
    select N8
    find (str(n7->id_mrf,6))
    do while n8->id_mrf == n7->id_mrf .and. !eof()
      aadd(st_rez_gist[i,3], {alltrim(n8->r_m_name),n8->id_r_m})
      skip
    enddo
    select N7
    skip
  enddo
  n7->(dbCloseArea())
  n8->(dbCloseArea())
endif
Private mdiag_date := ctod(""), mgist1, mgist2, m1gist1 := 0, m1gist2 := 0, ;
        mmark1, mmark2, mmark3, mmark4, mmark5, mgist[2], mmark[5],;
        m1mark1 := 0, m1mark2 := 0, m1mark3 := 0, m1mark4 := 0, m1mark5 := 0,;
        is_gisto := .f., mrez_gist, m1rez_gist := 0, arr_rez_gist := aclone(st_rez_gist)
afill(mgist, 0)
afill(mmark, 0)
dbcreate(cur_dir+"tmp_onkco", {; // Сведения о проведении консилиума
   {"KOD"      ,   "N",     7,     0},; // код больного
   {"PR_CONS"  ,   "N",     1,     0},; // Сведения о проведении консилиума(N019):0-отсутствует необходимость;1-определена тактика обследования;2-определена тактика лечения;3-изменена тактика лечения
   {"DT_CONS"  ,   "D",     8,     0};  // Дата проведения консилиума	Обязательно к заполнению при PR_CONS=1,2,3
  })
dbcreate(cur_dir+"tmp_onkdi", {; // Диагностический блок
   {"KOD"      ,   "N",     7,     0},; // код больного
   {"DIAG_DATE",   "D",     8,     0},; // Дата взятия материала для проведения диагностики
   {"DIAG_TIP" ,   "N",     1,     0},; // Тип диагностического показателя: 1 - гистологический признак; 2 - маркёр (ИГХ)
   {"DIAG_CODE",   "N",     3,     0},; // Код диагностического показателя При DIAG_TIP=1 в соответствии со справочником N007 При DIAG_TIP=2 в соответствии со справочником N010
   {"DIAG_RSLT",   "N",     3,     0},; // Код результата диагностики При DIAG_TIP=1 в соответствии со справочником N008 При DIAG_TIP=2 в соответствии со справочником N011
   {"REC_RSLT",    "N",     1,     0};  // признак получения результата диагностики 1 - получен
  })
dbcreate(cur_dir+"tmp_onkpr", {; // Сведения об имеющихся противопоказаниях
   {"KOD"      ,   "N",     7,     0},; // код больного
   {"PROT"     ,   "N",     1,     0},; // Код противопоказания или отказа в соответствии со справочником N001
   {"D_PROT"   ,   "D",     8,     0};  // Дата регистрации противопоказания или отказа
  })
Private mprot1, mprot2, mprot, mprot4, mprot5, mprot6, ;
        m1prot1, m1prot2, m1prot, m1prot4, m1prot5, m1prot6, ;
        mdprot1, mdprot2, mdprot, mdprot4, mdprot5, mdprot6
//
dbcreate(cur_dir+"tmp_onkus", {; // Сведения о проведённых лечениях
   {"KOD"      ,   "N",     7,     0},; // код больного
   {"USL_TIP"  ,   "N",     1,     0},; // Тип онкоуслуги в соответствии со справочником N013
   {"HIR_TIP"  ,   "N",     1,     0},; // Тип хирургического лечения При USL_TIP=1 в соответствии со справочником N014
   {"LEK_TIP_L",   "N",     1,     0},; // Линия лекарственной терапии При USL_TIP=2 в соответствии со справочником N015
   {"LEK_TIP_V",   "N",     1,     0},; // Цикл лекарственной терапии   При USL_TIP=2 в соответствии со справочником N016
   {"LUCH_TIP" ,   "N",     1,     0},; // Тип лучевой терапии  При USL_TIP=3,4 в соответствии со справочником N017
   {"PPTR" ,       "N",     1,     0},; // Признак проведения профилактики тошноты и рвотного рефлекса - указывается "1" при USL_TIP=2,4
   {"SOD"      ,   "N",     6,     2};  // SOD - Суммарная очаговая доза - При USL_TIP=3,4
  })
dbcreate(cur_dir+"tmp_onkle", {; // Сведения о применённых лекарственных препаратах
   {"KOD"      ,   "N",     7,     0},; // код больного
   {"REGNUM",      "C",     6,     0},; // IDD лек.препарата N020
   {"CODE_SH",     "C",    10,     0},; // код схемы лек.терапии V024
   {"DATE_INJ",    "D",     8,     0};  // дата введения лек.препарата
  })
Private musl_tip, m1usl_tip, musl_tip1, m1usl_tip1, musl_tip2, m1usl_tip2, msod, ;
        musl_vmp, m1usl_vmp, musl_vmp1, m1usl_vmp1, musl_vmp2, m1usl_vmp2, msod_vmp, ;
        mpptr, m1pptr := 0, mpptr_vmp, m1pptr_vmp := 0,;
        mIS_ERR, m1is_err := 0,; // Признак несоблюдения схемы лекарственной терапии: 0-нормально, 1-не соблюдена
        mIS_ERR_vmp, m1is_err_vmp := 0,;
        _arr_sh := ret_arr_shema(1), _arr_mt := ret_arr_shema(2), _arr_fr := ret_arr_shema(3),;
        mm_usl_tip := {{"не проводилось",0},; // N013
                       {"Хирургическое лечение",1},;
                       {"Лекарственная противоопухолевая терапия",2},;
                       {"Лучевая терапия",3},;
                       {"Химиолучевая терапия",4},;
                       {"Неспецифическое лечение (катетер, прочее)",5},;
                       {"Диагностика",6}}
mm_USL_TIP_all := aclone(mm_USL_TIP)
asize(mm_USL_TIP,6) // без диагностики
//
afill(adiag_talon,0)
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2
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
                  "Лечение с "+full_date(human->N_DATA)+" по "+full_date(human->K_DATA)}
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
  m1reg_lech  := human->reg_lech
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
  if human->OBRASHEN == '1'
    m1DS_ONK := 1
  endif
  for i := 1 to 16
    adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
  next
  mstatus_st  := human_->STATUS_ST
  m1VIDPOLIS  := human_->VPOLIS
  mSPOLIS     := human_->SPOLIS
  mNPOLIS     := human_->NPOLIS
  if empty(val(msmo := human_->SMO))
    m1komu := human->KOMU
    m1str_crb := human->STR_CRB
  else
    m1komu := m1str_crb := 0
  endif
  if human_->NOVOR > 0
    m1novor := 1
    mcount_reb := human_->NOVOR
    mDATE_R2 := human_->DATE_R2
    mpol2 := human_->POL2
  endif
  m1okato    := human_->OKATO  // ОКАТО субъекта РФ территории страхования
  m1USL_OK   := human_->USL_OK
  m1PROFIL   := human_->PROFIL
  m1PROFIL_K := human_2->PROFIL_K
  m1NPR_MO   := human_->NPR_MO
  mNPR_DATE  := human_2->NPR_DATE
  M1F14_EKST := int(val(substr(human_->FORMA14,1,1)))
  M1F14_SKOR := int(val(substr(human_->FORMA14,2,1)))
  M1F14_VSKR := int(val(substr(human_->FORMA14,3,1)))
  M1F14_RASH := int(val(substr(human_->FORMA14,4,1)))
  mn_data    := human->N_DATA
  mk_data    := human->K_DATA
  m1povod    := human_->POVOD
  m1travma   := human_->TRAVMA
  m1rslt     := human_->RSLT_NEW
  m1ishod    := human_->ISHOD_NEW
  M1BOLNICH  := human->BOLNICH
  if m1bolnich > 0
    MDATE_B_1 := c4tod(human->DATE_B_1)
    MDATE_B_2 := c4tod(human->DATE_B_2)
    if m1bolnich == 2
      mrodit_dr  := human_->RODIT_DR
      mrodit_pol := human_->RODIT_POL
    endif
  endif
  mcena_1 := human->CENA_1
  //
  m1ad_cr := human_2->PC3
  m1P_PER := human_2->P_PER
  MOSL1 := human_2->OSL1
  MOSL2 := human_2->OSL2
  MOSL3 := human_2->OSL3
  M1VMP := human_2->VMP
  M1VIDVMP := human_2->VIDVMP
  M1METVMP := human_2->METVMP
  /*if between(M1METVMP,498,499) .and. year(mk_data)  == 2017
    mstentvmp := left(human_2->PC1,1) // кол-во стентов для методов ВМП 498,499
  endif*/
  mTAL_NUM := human_2->TAL_NUM
  mTAL_D := human_2->TAL_D
  mTAL_P := human_2->TAL_P
  MVNR  := iif(human_2->VNR  > 0, padr(lstr(human_2->VNR ),4), space(4))
  MVNR1 := iif(human_2->VNR1 > 0, padr(lstr(human_2->VNR1),4), space(4))
  MVNR2 := iif(human_2->VNR2 > 0, padr(lstr(human_2->VNR2),4), space(4))
  MVNR3 := iif(human_2->VNR3 > 0, padr(lstr(human_2->VNR3),4), space(4))
  m1vid_reab := human_2->PN1
  if (ibrm := f_oms_beremenn(mkod_diag)) > 0
    m1prer_b := human_2->PN2
  endif
  if alltrim(msmo) == '34'
    mnameismo := ret_inogSMO_name(2,@rec_inogSMO,.t.) // открыть и закрыть
  endif
  if eq_any(m1usl_ok,1,2) .and. is_task(X_PPOKOJ) ;
                          .and. !empty(mUCH_DOC) .and. mem_e_istbol == 1
    R_Use(dir_server+"mo_pp",dir_server+"mo_pp_h","PP")
    find (str(Loc_kod,7))
    if found()
      when_uch_doc := .f.  // нельзя изменять номер истории болезни
    endif
  endif
  is_oncology := f_is_oncology(2)
  if is_oncology > 0 // онкология - направления
    use (cur_dir+"tmp_onkna") new alias TNAPR
    R_Use(dir_server+"mo_su",,"MOSU")
    R_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","NAPR") // онконаправления
    set relation to u_kod into MOSU
    find (str(Loc_kod,7))
    do while napr->kod == Loc_kod .and. !eof()
      old_oncology := .t.
      cur_napr := 1 // при ред-ии - сначала первое направление текущее
      ++count_napr
      select TNAPR
      append blank
      tnapr->NAPR_DATE := napr->NAPR_DATE
      tnapr->NAPR_MO   := napr->NAPR_MO
      tnapr->NAPR_V    := napr->NAPR_V
      tnapr->MET_ISSL  := napr->MET_ISSL
      tnapr->U_KOD     := napr->U_KOD
      tnapr->shifr_u   := iif(empty(mosu->shifr),mosu->shifr1,mosu->shifr)
      tnapr->shifr1    := mosu->shifr1
      tnapr->name_u    := mosu->name
      select NAPR
      skip
    enddo
    R_Use(dir_server+"mo_onkco",dir_server+"mo_onkco","CO")
    find (str(Loc_kod,7))
    if found()
      m1PR_CONS := co->pr_cons
      mDT_CONS := co->dt_cons
    endif
  endif
  if is_oncology == 2 // онкология
    R_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","SL")
    find (str(Loc_kod,7))
    if found()
      old_oncology := .t.
      m1DS1_T := sl->DS1_T
      m1STAD := sl->STAD
      m1ONK_T := sl->ONK_T
      m1ONK_N := sl->ONK_N
      m1ONK_M := sl->ONK_M
      m1MTSTZ := sl->MTSTZ
      m1B_DIAG := sl->b_diag
      if sl->k_fr > 0
        mK_FR := padr(lstr(sl->k_fr),2)
      endif
      m1crit := sl->crit
      m1is_err := sl->is_err
      if sl->WEI > 0
        mWEI := padr(alltrim(str_0(sl->WEI,5,1)),5)
      endif
      if sl->HEI > 0
        mHEI := padr(lstr(sl->HEI),3)
      endif
      if sl->BSA > 0
        mBSA := padr(alltrim(str_0(sl->BSA,4,2)),4)
      endif
    endif
    is_gisto := (m1usl_ok == 3 .and. m1profil == 15)  // поликлиника + профиль = гистология
    i := j := 0
    use (cur_dir+"tmp_onkdi") new alias TDIAG
    R_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","DIAG") // Диагностический блок
    find (str(Loc_kod,7))
    do while diag->kod == Loc_kod .and. !eof()
      old_oncology := .t.
      mDIAG_DATE := diag->DIAG_DATE
      select TDIAG
      append blank
      tdiag->DIAG_DATE := diag->DIAG_DATE
      tdiag->DIAG_TIP  := diag->DIAG_TIP
      tdiag->DIAG_CODE := diag->DIAG_CODE
      tdiag->DIAG_RSLT := diag->DIAG_RSLT
      if diag->DIAG_TIP == 1 // гистологический признак
        if is_gisto .and. (k := ascan(arr_rez_gist, {|x| x[2] == diag->DIAG_CODE })) > 0
          arr_rez_gist[k,4] := diag->DIAG_RSLT
        endif
        if ++i < 3
          mgist[i] := diag->DIAG_CODE
          &("m1gist"+lstr(i)) := diag->DIAG_RSLT
        endif
      elseif diag->DIAG_TIP == 2 // маркёр (ИГХ)
        if ++j < 6
          mmark[j] := diag->DIAG_CODE
          &("m1mark"+lstr(j)) := diag->DIAG_RSLT
        endif
      endif
      select DIAG
      skip
    enddo
    use (cur_dir+"tmp_onkpr") new alias TPR
    R_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","PR") // Сведения об имеющихся противопоказаниях
    find (str(Loc_kod,7))
    do while pr->kod == Loc_kod .and. !eof()
      if between(pr->PROT,1,6)
        old_oncology := .t.
        select TPR
        append blank
        tpr->PROT := pr->PROT
        tpr->D_PROT := pr->D_PROT
      endif
      select PR
      skip
    enddo
    use (cur_dir+"tmp_onkus") new alias TMPOU
    R_Use(dir_server+"mo_onkus",dir_server+"mo_onkus","OU") // Сведения о проведённых лечениях
    find (str(Loc_kod,7))
    do while ou->kod == Loc_kod .and. !eof()
      select TMPOU
      append blank
      tmpou->USL_TIP   := ou->USL_TIP
      tmpou->HIR_TIP   := ou->HIR_TIP
      tmpou->LEK_TIP_L := ou->LEK_TIP_L
      tmpou->LEK_TIP_V := ou->LEK_TIP_V
      tmpou->LUCH_TIP  := ou->LUCH_TIP
      tmpou->SOD       := iif(eq_any(ou->USL_TIP,3,4),sl->sod,0)
      tmpou->PPTR      := iif(eq_any(ou->USL_TIP,2,4),ou->PPTR,0)
      select OU
      skip
    enddo
    select TMPOU
    if lastrec() == 0
      append blank
    endif
    use (cur_dir+"tmp_onkle") new alias TMPLE
    R_Use(dir_server+"mo_onkle",dir_server+"mo_onkle","LE") // Сведения о применённых лекарственных препаратах
    find (str(Loc_kod,7))
    do while le->kod == Loc_kod .and. !eof()
      select TMPLE
      append blank
      tmple->REGNUM   := le->REGNUM
      tmple->CODE_SH  := le->CODE_SH
      tmple->DATE_INJ := le->DATE_INJ
      select LE
      skip
    enddo
  endif
endif
if !(left(msmo,2) == '34') // не Волгоградская область
  m1ismo := msmo ; msmo := '34'
endif
if Loc_kod == 0
  R_Use(dir_server+"mo_otd",,"OTD")
  goto (m1otd)
  m1USL_OK := otd->IDUMP
  if empty(m1PROFIL)
    m1PROFIL := otd->PROFIL
  endif
  if empty(m1PROFIL_K)
    m1PROFIL_K := otd->PROFIL_K
  endif
endif
R_Use(dir_server+"mo_uch",,"UCH")
goto (m1lpu)
is_talon := .t.//(uch->IS_TALON == 1)
mlpu := rtrim(uch->name)
if m1vrach > 0
  R_Use(dir_server+"mo_pers",,"P2")
  goto (m1vrach)
  MTAB_NOM := p2->tab_nom
  m1prvs := -ret_new_spec(p2->prvs,p2->prvs_new)
  mvrach := padr(fam_i_o(p2->fio)+" "+ret_tmp_prvs(m1prvs),36)
endif
close databases
MFIO_KART := _f_fio_kart()
mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
if empty(m1USL_OK) ; m1USL_OK := 1 ; endif // на всякий случай
mUSL_OK   := inieditspr(A__MENUVERT, glob_V006, m1USL_OK)
if eq_any(m1usl_ok,1,2)
  if !between(m1p_per,1,4)
    m1p_per := 1
  endif
  mp_per := inieditspr(A__MENUVERT, mm_p_per, m1p_per)
endif
mPROFIL   := inieditspr(A__MENUVERT, glob_V002, m1PROFIL)
mPROFIL_K := inieditspr(A__MENUVERT, glob_V020, m1PROFIL_K)
mvid_reab := inieditspr(A__MENUVERT, mm_vid_reab, m1vid_reab)
if !empty(m1NPR_MO)
  mNPR_MO := ret_mo(m1NPR_MO)[_MO_SHORT_NAME]
endif
mDS_ONK   := inieditspr(A__MENUVERT, mm_danet, M1DS_ONK)
MVMP      := inieditspr(A__MENUVERT, mm_danet, M1VMP)
MVIDVMP   := ret_V018(M1VIDVMP,mk_data)
MMETVMP   := ret_V019(M1METVMP,M1VIDVMP,mk_data)
mreg_lech := inieditspr(A__MENUVERT, mm_reg_lech, m1reg_lech)
MNOVOR    := inieditspr(A__MENUVERT, mm_danet, M1NOVOR)
MF14_EKST := inieditspr(A__MENUVERT, mm_ekst , M1F14_EKST)
MF14_SKOR := inieditspr(A__MENUVERT, mm_danet, M1F14_SKOR)
MF14_VSKR := inieditspr(A__MENUVERT, mm_vskrytie, M1F14_VSKR)
MF14_RASH := inieditspr(A__MENUVERT, mm_danet, M1F14_RASH)
mrslt     := inieditspr(A__MENUVERT, glob_V009, m1rslt)
mishod    := inieditspr(A__MENUVERT, glob_V012, m1ishod)
mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
mbolnich  := inieditspr(A__MENUVERT, menu_bolnich, m1bolnich)
//mpovod    := inieditspr(A__MENUVERT, stm_povod, m1povod)
//mtravma   := inieditspr(A__MENUVERT, stm_travma, m1travma)
motd      := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
mismo     := init_ismo(m1ismo)
if ibrm > 0
  mm_prer_b := iif(ibrm == 1, mm1prer_b, iif(ibrm == 2, mm2prer_b, mm3prer_b))
  if ibrm == 1 .and. m1prer_b == 0
    mprer_b := space(28)
  else
    mprer_b := inieditspr(A__MENUVERT, mm_prer_b, m1prer_b)
  endif
endif
f_valid_komu(,-1)
if m1komu == 0
  m1company := int(val(msmo))
elseif eq_any(m1komu,1,3)
  m1company := m1str_crb
endif
mcompany  := inieditspr(A__MENUVERT, mm_company, m1company)
if m1company == 34
  if !empty(mismo)
    mcompany := padr(mismo,38)
  elseif !empty(mnameismo)
    mcompany := padr(mnameismo,38)
  endif
endif
str_1 := " случая (листа учёта)"
if Loc_kod == 0
  str_1 := "Добавление"+str_1
  mtip_h := yes_vypisan
else
  str_1 := "Редактирование"+str_1
endif
if yes_vypisan == B_END
  if Loc_kod == 0
    mtip_h += m1_l_z
  else
    m1_l_z := mtip_h - B_END
  endif
  m_l_z := inieditspr(A__MENUVERT, mm_danet, m1_l_z)
endif
pr_1_str(str_1)
setcolor(color8)
myclear(1)
Private gl_area := {1,0,maxrow()-1,maxcol(),0}, ;
        p_nstr_vnr, p_str_vnr, p_str_vnrm, p_nstr_ad_cr, p_str_ad_cr //p_nstr_stent, p_str_stent
setcolor(cDataCGet)
make_diagP(1)  // сделать "шестизначные" диагнозы
f_valid_usl_ok(,-1)
f_valid2ad_cr()
Private rdiag := 1, rpp := 1, num_screen := 1, is_onko_VMP := .f.
do while .t.
  if num_screen == 1 //
    SetMode(kscr1,80)
    pr_1_str(str_1)
    j := 1
    myclear(j)
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j,50 say padl("Лист учета № "+lstr(Loc_kod),29) color color14
    endif
    diag_screen(0)
    pos_read := 0
    put_dop_diag(0)
    ++j; @ j,1 say "Учреждение" get mlpu when .f. color cDataCSay
         @ row(),col()+2 say "Отделение" get motd when .f. color cDataCSay
    //
    ++j; @ j,1 say "ФИО" get mfio_kart ;
         reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
         valid {|g,o| update_get("mkomu"),update_get("mcompany"),;
                      update_get("mspolis"),update_get("mnpolis"),;
                      update_get("mvidpolis") }
    //
    ++j; @ j,1 say "Направление: дата" get mNPR_DATE
         @ j,col()+1 say "из МО" get mNPR_MO ;
              reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c)}},A__FUNCTION,,,.f.)} ;
              color colget_menu
    //
    ++j; @ j,1 say "Новорожденный?" get mnovor ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
               valid {|g,o| f_valid_novor(g,o) } ;
               color colget_menu
         @ row(),col()+3 say "№/пп ребёнка" get mcount_reb pict "99" range 1,99 ;
               when (m1novor == 1)
         @ row(),col()+3 say "Д.р. ребёнка" get mdate_r2 when (m1novor == 1)
    if mem_pol == 1
         @ row(),col()+3 say "Пол ребёнка" get mpol2 ;
             reader {|x|menu_reader(x,menupol,A__MENUVERT,,,.f.)} ;
             when (m1novor == 1)
    else
         @ row(),col()+3 say "Пол ребёнка" get mpol2 pict "@!" ;
             valid {|g| mpol2 $ "МЖ" } ;
             when (m1novor == 1)
    endif
    //
    ++j; @ j,1 say "Сроки лечения" get mn_data valid {|g|f_k_data(g,1)}
         @ row(),col()+1 say "-"   get mk_data valid {|g|f_k_data(g,2)}
         @ row(),col()+3 get mvzros_reb when .f. color cDataCSay
    if yes_vypisan == B_END
         @ row(),col()+5 say " Лечение завершено?" color "G+/B"
         @ row(),col()+1 get m_l_z ;
              reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
              color "GR+/B"
    endif
    //
    ++j; @ j,1 say "№ амб.карты (истории)" get much_doc picture "@!" ;
               when when_uch_doc
         @ row(),col()+1 say "Врач" get MTAB_NOM pict "99999" ;
               valid {|g| v_kart_vrach(g,.t.) } when diag_screen(2)
         @ row(),col()+1 get mvrach when .f. color color14
    //
    ++j; @ j,1 say "Первичный диагноз" get mkod_diag0 picture pic_diag reader {|o| MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.t.,mk_data,iif(m1novor==0,mpol,mpol2)) ;
               when diag_screen(2) .and. when_diag()
    //if yes_bukva // если в настройке для отделения - работа со статусом стом.больного
    //     @ j,34 say "Статус стоматологического больного" get mstatus_st picture "@!" ;
    //           when diag_screen(2) ;
    //           valid {|g| f_valid_status_st(g) }
    //endif
    ++j; rdiag := j
          @ j,1 say "Основной диагноз" get mkod_diag picture pic_diag ;
               reader {|o| MyGetReader(o,bg)} ;
               when when_diag() ;
               valid {|| val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2)), f_valid_beremenn(mkod_diag) }
    if (ibrm := f_oms_beremenn(mkod_diag)) == 1
         @ j,26 say "прерывание беременности"
    elseif ibrm == 2
         @ j,26 say "дисп.набл.за беременной"
    elseif ibrm == 3
         @ j,26 say "     боли при онкологии"
    endif
         @ j,51 get mprer_b ;
                reader {|x| menu_reader(x,mm_prer_b,A__MENUVERT,,,.f.)} ;
                when {|| ibrm := f_oms_beremenn(mkod_diag),;
                         mm_prer_b := iif(ibrm == 1, mm1prer_b, iif(ibrm == 2, mm2prer_b, mm3prer_b)),;
                         (ibrm > 0) }
    //
    ++j; @ j,1 say "Сопутствующие диагнозы " get mkod_diag2 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
         @ row(),col() say ","               get mkod_diag3 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
         @ row(),col() say ","               get mkod_diag4 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
         @ row(),col() say ","               get msoput_b1  picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
         @ row(),col() say ","               get msoput_b2  picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
         @ row(),col() say ","               get msoput_b3  picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
         @ row(),col() say ","               get msoput_b4  picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
    ++j; @ j,1 say "Диагнозы осложнения    " get mosl1 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.f.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
         @ row(),col() say ","               get mosl2 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.f.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
         @ row(),col() say ","               get mosl3 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.f.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
    //
    ++j; @ j,1 say "Принадлежность счёта" get mkomu ;
               reader {|x|menu_reader(x,mm_komu,A__MENUVERT,,,.f.)} ;
               valid {|g,o| f_valid_komu(g,o) } ;
               color colget_menu
         @ row(),col()+1 say "==>" get mcompany ;
             reader {|x|menu_reader(x,mm_company,A__MENUVERT,,,.f.)} ;
             when diag_screen(2) .and. m1komu < 5 ;
             valid {|g| func_valid_ismo(g,m1komu,38) }
    //
    ++j; @ j,1 say "Полис ОМС: серия" get mspolis when m1komu == 0
         @ row(),col()+3 say "номер"  get mnpolis when m1komu == 0
         @ row(),col()+3 say "вид"    get mvidpolis ;
                      reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT,,,.f.)} ;
                      when m1komu == 0 ;
                      valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
    //
    ++j; rpp := j
         @ j,1 say "Мед.помощь: условия оказания" get MUSL_OK ;
             reader {|x|menu_reader(x,tmp_V006,A__MENUVERT,,,.f.)} ;
             when diag_screen(2) ;
             valid {|g,o| iif(eq_any(m1usl_ok,1,2),;
                             (SetPos(rpp,40), DispOut("признак",cDataCGet)),;
                             (mp_per:=space(25),m1p_per:=0)),;
                          update_get("mp_per"), f_valid_usl_ok(g,o)  }
    if eq_any(m1usl_ok,1,2)
         @ j,40 say "признак"
    endif
         @ j,48 get mp_per ;
                reader {|x| menu_reader(x,mm_p_per,A__MENUVERT,,,.f.)} ;
                when eq_any(m1usl_ok,1,2)
    if is_dop_ob_em
      ++j; @ j,3 say "вид объёмов специализированной медицинской помощи" get mreg_lech ;
                 reader {|x|menu_reader(x,mm_reg_lech,A__MENUVERT,,,.f.)} ;
                 when eq_any(m1usl_ok,1,2)
    endif
    ++j; @ j,3 say "профиль мед.помощи" get MPROFIL ;
               reader {|x|menu_reader(x,tmp_V002,A__MENUVERT,,,.f.)} ;
               valid f_valid2ad_cr()
    ++j; @ j,3 say "профиль койки" get MPROFIL_K ;
               reader {|x|menu_reader(x,tmp_V020,A__MENUVERT,,,.f.)} ;
               when eq_any(m1usl_ok,1,2)
    if is_reabil_slux
      ++j; @ j,3 say "вид мед.реабилитации" get mvid_reab ;
               reader {|x|menu_reader(x,mm_vid_reab,A__MENUVERT,,,.f.)} ;
               when eq_any(m1usl_ok,1,2) .and. m1profil == 158
    endif
    //
    ++j; @ j,1 say "Результат обращения" get mrslt ;
             reader {|x|menu_reader(x,mm_rslt,A__MENUVERT,,,.f.)} ;
             valid {|g,o| f_valid_rslt(g,o) }
    //
    ++j; @ j,1 say "Исход заболевания" get mishod ;
             reader {|x|menu_reader(x,mm_ishod,A__MENUVERT,,,.f.)}
    //
    ++j; @ j,1 say "Госпитализирован" get MF14_EKST ;
              reader {|x|menu_reader(x,mm_ekst,A__MENUVERT,,,.f.)} ;
              valid {|g,o| f_valid_f14_ekst(g,o) }
         @ row(),col()+3 say "Доставлен скорой помощью" get MF14_SKOR ;
              reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
              when M1F14_EKST == 1
    ++j; @ j,3 say "вскрытие" get MF14_VSKR ;
              reader {|x|menu_reader(x,mm_vskrytie,A__MENUVERT,,,.f.)} ;
              when is_death(m1RSLT)
      @ row(),col()+3 say "установлено расхождение диагнозов" get MF14_RASH ;
              reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
              when M1F14_VSKR > 0
    /*++j
    if is_talon
      if mem_st_pov == 1
        @ j,1 say "Повод обращения" get mpovod ;
               reader {|x|menu_reader(x,stm_povod,A__MENUVERT,,,.f.)} ;
               color colget_menu
      else
        @ j,1 say "Повод обращения" get m1povod pict "9" ;
               valid {|g| val_st_pov(g) }
        @ row(),col()+1 get mpovod color color14 when .f.
      endif
      if .t.//is_travma // если в настройке для отделения - работа с травмой
        if mem_st_trav == 1
          @ j,43 say "Вид травмы" get mtravma ;
                  reader {|x|menu_reader(x,stm_travma,A__MENUVERT,,,.f.)} ;
                  color colget_menu
        else
          @ j,43 say "Вид травмы" get m1travma pict "99" ;
                  valid {|g| val_st_trav(g) }
          @ row(),col()+1 get mtravma color color14 when .f.
        endif
      endif
    endif*/
    ++j ; p_nstr_vnr := j
    p_str_vnr := "Вес ребёнка в граммах (малая масса тела/недоношенный)   "
    @ j,1 say p_str_vnr get MVNR pict "9999" when input_vnr
    if empty(MVNR)
      @ j,1
    endif
    p_str_vnrm := "Вес родившихся детей в граммах (малая масса/недоношенный)   "
    @ j,1 say p_str_vnrm get MVNR1 pict "9999" when input_vnrm
         @ row(),col()+1 get MVNR2 pict "9999" when input_vnrm
         @ row(),col()+1 get MVNR3 pict "9999" when input_vnrm
    if emptyall(MVNR1,MVNR2,MVNR3)
      @ j,1
    endif
    //
    ++j ; p_nstr_ad_cr := j
    p_str_ad_cr := "Доп.критерий"
    @ p_nstr_ad_cr,1 say p_str_ad_cr get MAD_CR ;
                     reader {|x| menu_reader(x,mm_ad_cr,A__MENUVERT_SPACE,,,.f.)} ;
                     when input_ad_cr ;
                     color colget_menu
    if !input_ad_cr
      @ j,1
    endif
    //
    if is_MO_VMP
      ++j; @ j,1 say "ВМП оказана?" get MVMP ;
             reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
             when m1usl_ok==1 .or. (m1usl_ok==2 .and. is_ds_VMP) ;
             valid {|g,o| f_valid_vmp(g,o) } ;
             color colget_menu
           @ j,col()+5 say "номер талона на ВМП" get mTAL_NUM when m1vmp == 1
      ++j; @ j,1 say "дата выдачи талона на ВМП" get mTAL_D when m1vmp == 1
           @ j,col()+1 say "дата планируемой госпитализации" get mTAL_P when m1vmp == 1
      ++j; @ j,1 say " вид ВМП" get mvidvmp ;
             reader {|x|menu_reader(x,{{|k,r,c|f_get_vidvmp(k,r,c)}},A__FUNCTION,,,.f.)} ;
             when m1vmp == 1 ;
             valid {|g,o| f_valid_vidvmp(g,o) } ;
             color colget_menu
      ++j; @ j,1 say "  метод ВМП" get mmetvmp ;
             reader {|x|menu_reader(x,{{|k,r,c|f_get_metvmp(k,r,c,m1vidvmp)}},A__FUNCTION,,,.f.)} ;
             when m1vmp == 1 .and. !empty(m1vidvmp) ;  //   valid {|| f_valid_metvmp(m1metvmp) } ;
             color colget_menu
      /*++j ; p_nstr_stent := j
      if year(mk_data) == 2017
        p_str_stent := "   число стентов, установленных в коронарные артерии"
        @ p_nstr_stent,1 say iif(between(m1metvmp,498,499), p_str_stent, space(len(p_str_stent)))
        @ p_nstr_stent,col()+1 get mstentvmp ;
                               when between(m1metvmp,498,499) ;
                               valid mstentvmp $ " 123"
      endif*/
    endif
    //
    ++j; @ j,1 say "Больничный" get mbolnich ;
            reader {|x|menu_reader(x,menu_bolnich,A__MENUVERT,,,.f.)} ;
            color colget_menu ;
            valid {|g,o| f_valid_bolnich(g,o) }
         @ row(),col()+1 say "==> с" get mdate_b_1 when m1bolnich > 0
         @ row(),col()+1 say "по" get mdate_b_2 when m1bolnich > 0
         @ row(),col()+1 say "Д.р.родителя" get mrodit_dr when m1bolnich == 2
    if mem_pol == 1
         @ row(),col()+1 say "Пол" get mrodit_pol ;
                reader {|x|menu_reader(x,menupol,A__MENUVERT,,,.f.)} ;
                when m1bolnich == 2
    else
         @ row(),col()+1 say "Пол" get mrodit_pol pict "@!" ;
                valid {|g| mrodit_pol $ "МЖ" } ;
                when m1bolnich == 2
    endif
    @ maxrow()-1,1 say "Признак подозрения на ЗНО" get mDS_ONK ;
             reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
             when {|| when_ds_onk() } ;
             color colget_menu
    @ maxrow()-1,55 say "Сумма лечения" color color1
    @ row(),col()+1 say lput_kop(mcena_1) color color8
    if is_talon
      set key K_F10 TO inp_dop_diag
    endif
    if !empty(a_smert)
      n_message(a_smert,,"GR+/R","W+/R",,,"G+/R")
    endif
    if pos_read > 0
      if lower(GetList[pos_read]:name) == "mds_onk"
        --pos_read
      endif
      if lower(GetList[pos_read]:name) == "mrodit_pol"
        --pos_read
      endif
      if lower(GetList[pos_read]:name) == "mrodit_dr"
        --pos_read
      endif
      if lower(GetList[pos_read]:name) == "mdate_b_2"
        --pos_read
      endif
      if lower(GetList[pos_read]:name) == "mdate_b_1"
        --pos_read
      endif
    endif
    @ maxrow(),0 say padc("<Esc> - выход;  <PgDn> - запись;  <F1> - помощь",maxcol()+1) color color0
    mark_keys({"<F1>","<Esc>","<PgDn>"},"R/BG")
  elseif num_screen == 2 // 
    use_base("luslf")
    Use_base("mo_su")
    use (cur_dir+"tmp_onkna") new alias TNAPR
    count_napr := lastrec()
    mNAPR_MO := space(6)
    if cur_napr > 0 .and. cur_napr <= count_napr
      goto (cur_napr) // номер текущего направления
      mNAPR_DATE := tnapr->NAPR_DATE
      m1NAPR_MO := tnapr->NAPR_MO
      if empty(m1NAPR_MO)
        mNAPR_MO := space(60)
      else
        mNAPR_MO := ret_mo(m1NAPR_MO)[_MO_SHORT_NAME]
      endif
      m1NAPR_V := tnapr->NAPR_V
      m1MET_ISSL := tnapr->MET_ISSL
      mu_kod := iif(m1napr_v == 3, tnapr->U_KOD, 0)
      mshifr := iif(m1napr_v == 3, tnapr->shifr_u, space(20))
      mshifr1 := iif(m1napr_v == 3, tnapr->shifr1, space(20))
      mname_u := iif(m1napr_v == 3, tnapr->name_u, space(65))
    else
      cur_napr := 1
      mNAPR_DATE := ctod("")
      m1NAPR_MO := space(6)
      mNAPR_MO := space(60)
      m1NAPR_V := 0
      m1MET_ISSL := 0
      mu_kod := 0
      mshifr := space(20)
      mshifr1 := space(20)
      mname_u := space(65)
    endif
    mNAPR_V := inieditspr(A__MENUVERT, mm_napr_v, m1napr_v)
    mMET_ISSL := inieditspr(A__MENUVERT, mm_MET_ISSL, m1MET_ISSL)
    tip_onko_napr := 0
    if is_oncology == 2
      is_mgi := .f. ; lshifr := ""
      if Loc_kod > 0 // редактирование
        R_Use(dir_server+"uslugi",,"USL")
        R_Use_base("human_u")
        find (str(Loc_kod,7))
        do while hu->kod == Loc_kod .and. !eof()
          usl->(dbGoto(hu->u_kod))
          if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
            lshifr := usl->shifr
          endif
          lshifr := alltrim(lshifr)
          if left(lshifr,5) == "60.9."  // МГИ
            is_mgi := .t. ; exit
          endif
          select HU
          skip
        enddo
      endif
      for i := 1 to 6
        &("m1prot"+lstr(i)) := 0
        &("mdprot"+lstr(i)) := ctod("")
      next
      use (cur_dir+"tmp_onkpr") new alias TPR
      go top
      do while !eof()
        &("m1prot"+lstr(tpr->prot)) := 1
        &("mdprot"+lstr(tpr->prot)) := tpr->d_prot
        skip
      enddo
      for i := 1 to 6
        &("mprot"+lstr(i)) := inieditspr(A__MENUVERT, mm_danet, &("m1prot"+lstr(i)))
      next
      mPR_CONS := inieditspr(A__MENUVERT, mm_PR_CONS, m1PR_CONS)
      //
      lmm_DS1_T := aclone(mm_DS1_T)
      if m1usl_ok < 3
        Del_Array(lmm_DS1_T,5) // удалим диспансерное наблюдение
        Del_Array(lmm_DS1_T,4) // удалим динамическое наблюдение
      else
        Del_Array(lmm_DS1_T,1) // удаляем первые 3 строки (лечение)
        Del_Array(lmm_DS1_T,1)
        Del_Array(lmm_DS1_T,1)
      endif
      if ascan(lmm_DS1_T,{|x| x[2] == m1DS1_T}) == 0
        m1DS1_T := lmm_DS1_T[1,2]
      endif
      mm_N002 := f_define_tnm(2,mkod_diag)
      mm_N003 := f_define_tnm(3,mkod_diag)
      mm_N004 := f_define_tnm(4,mkod_diag)
      mm_N005 := f_define_tnm(5,mkod_diag)
      mDS1_T := inieditspr(A__MENUVERT, mm_DS1_T, m1DS1_T)
      mMTSTZ := inieditspr(A__MENUVERT, mm_danet, m1MTSTZ)
      if len(mm_N002) == 1
        m1STAD := mm_N002[1,2]
      endif
      if len(mm_N003) == 1
        m1ONK_T := mm_N003[1,2]
      endif
      if len(mm_N004) == 1
        m1ONK_N := mm_N004[1,2]
      endif
      if len(mm_N005) == 1
        m1ONK_M := mm_N005[1,2]
      endif
      mSTAD  := padr(inieditspr(A__MENUVERT, mm_N002, m1STAD),5)
      mONK_T := padr(inieditspr(A__MENUVERT, mm_N003, m1ONK_T),5)
      mONK_N := padr(inieditspr(A__MENUVERT, mm_N004, m1ONK_N),5)
      mONK_M := padr(inieditspr(A__MENUVERT, mm_N005, m1ONK_M),5)
      if m1usl_ok == 3
        mONK_T := mONK_N := mONK_M := space(5)
        m1ONK_T := m1ONK_N := m1ONK_M := 0
      endif
      //
      R_Use(exe_dir+"_mo_N006",cur_dir+"_mo_N006","N6")
      // гистология
      mm_N009 := {}
      if !is_mgi // для МГИ гистология не вводится
        R_Use(exe_dir+"_mo_N009",,"N9")
        dbeval({|| aadd(mm_N009,{"",n9->id_mrf,{}}) }, ;
               {|| between_date(n9->datebeg,n9->dateend,mk_data) .and. left(mkod_diag,3) == n9->ds_mrf })
        asort(mm_N009,,,{|x,y| x[2] < y[2] })
      endif
      if len(mm_N009) > 0
        R_Use(exe_dir+"_mo_N007",cur_dir+"_mo_N007","N7")
        R_Use(exe_dir+"_mo_N008",cur_dir+"_mo_N008","N8")
        for i := 1 to min(2,len(mm_N009))
          select N7
          find (str(mm_N009[i,2],6))
          if found()
            mm_N009[i,1] := alltrim(n7->mrf_name)
          else
            func_error(4,"Не найден гистологический признак ID_MRF="+lstr(mm_N009[i,2])+" для "+mkod_diag)
          endif
          select N8
          find (str(mm_N009[i,2],6))
          do while n8->id_mrf == mm_N009[i,2] .and. !eof()
            aadd(mm_N009[i,3], {alltrim(n8->r_m_name),n8->id_r_m})
            skip
          enddo
          if ascan(mm_N009[i,3], {|x| x[2] == &("m1gist"+lstr(i)) }) == 0
            &("m1gist"+lstr(i)) := 0
          endif
          &("mgist"+lstr(i)) := inieditspr(A__MENUVERT, mm_N009[i,3], &("m1gist"+lstr(i)))
        next
      endif
      // Иммуногистохимия
      mm_N012 := {}
      R_Use(exe_dir+"_mo_N012",,"N12")
      dbeval({|| aadd(mm_N012,{"",n12->id_igh,{}}) }, ;
             {|| between_date(n12->datebeg,n12->dateend,mk_data) .and. left(mkod_diag,3) == n12->ds_igh })
      asort(mm_N012,,,{|x,y| x[2] < y[2] })
      if len(mm_N012) > 0 .and. is_mgi
        if (i := ascan(glob_MGI,{|x| x[1] == lshifr })) > 0 // услуга входит в список ТФОМС
          if (j := ascan(mm_N012,{|x| x[2] == glob_MGI[i,2] })) > 0 // по данному диагнозу присутствует необходимый маркер
            tmp_arr := {}
            aadd(tmp_arr, aclone(mm_N012[j]))
            mm_N012 := aclone(tmp_arr) // оставим в массиве только один нужный нам маркер
          else
            mm_N012 := {}
          endif
        else
          mm_N012 := {}
        endif
      endif
      if len(mm_N012) > 0
        R_Use(exe_dir+"_mo_N010",cur_dir+"_mo_N010","N10")
        R_Use(exe_dir+"_mo_N011",cur_dir+"_mo_N011","N11")
        for i := 1 to min(5,len(mm_N012))
          select N10
          find (str(mm_N012[i,2],6))
          do while n10->id_igh == mm_N012[i,2] .and. !eof()
            if between_date(n10->datebeg,n10->dateend,mk_data)
              mm_N012[i,1] := alltrim(n10->igh_name)
              exit
            endif
            skip
          enddo
          if empty(mm_N012[i,1])
            func_error(4,"Не найден признак иммуногистохимии ID_IGH="+lstr(mm_N012[i,2])+" для "+mkod_diag)
          endif
          select N11
          find (str(mm_N012[i,2],6))
          do while n11->id_igh == mm_N012[i,2] .and. !eof()
            if between_date(n11->datebeg,n11->dateend,mk_data)
              aadd(mm_N012[i,3], {alltrim(n11->kod_r_i),n11->id_r_i})
            endif
            skip
          enddo
          if ascan(mm_N012[i,3], {|x| x[2] == &("m1mark"+lstr(i)) }) == 0
            &("m1mark"+lstr(i)) := 0
          endif
          &("mmark"+lstr(i)) := inieditspr(A__MENUVERT, mm_N012[i,3], &("m1mark"+lstr(i)))
        next
      endif
      is_onko_VMP := .f. ; musl1vmp := musl2vmp := mtipvmp := 0
      if m1usl_ok < 3 .and. m1vmp == 1 .and. m1metvmp > 0
        R_Use(exe_dir+"_mo_ovmp",cur_dir+"_mo_ovmp","OVMP")
        find (str(m1metvmp,3)) // номер метода ВМП
        if found()
          is_onko_VMP := .t.
          musl1vmp := ovmp->usl1  // 1-я услуга
          musl2vmp := ovmp->usl2  // 2-я услуга
          mtipvmp  := ovmp->tip   // 0-применяется одна услуга, 1-применяются две услуги
        endif
        ovmp->(dbCloseArea())
      endif
      //
      mm_N014 := {;
        {"Первичной опухоли, в т.ч. с удалением регионарных лимфатических узлов",1},;
        {"Метастазов",2},;
        {"Симптоматическое",3},;
        {"Выполнено хирургическое стадирование",4},;
        {"Регионарных лимфатических узлов без первичной опухоли",5},;
        {"Криохирургия/криотерапия, лазерная деструкция, ...",6};
      }
      mm_N015 := {}
      R_Use(exe_dir+"_mo_N015",,"N15")
      dbeval({|| aadd(mm_N015, {alltrim(n15->tlek_namel),n15->id_tlek_l}) })
      mm_N016 := {}
      R_Use(exe_dir+"_mo_N016",,"N16")
      dbeval({|| aadd(mm_N016, {alltrim(n16->tlek_namev),n16->id_tlek_v}) })
      mm_N017 := {}
      R_Use(exe_dir+"_mo_N017",,"N17")
      dbeval({|| aadd(mm_N017, {alltrim(n17->tluch_name),n17->id_tluch}) })
      mm_str1 := {"","Тип лечения","Цикл терапии","Тип терапии","Тип терапии",""}
      lstr1 := space(12) ; m1usl_tip1 := 0 ; musl_tip1 := space(69) ; mm_usl_tip1 := {}
      lstr2 := space(13) ; m1usl_tip2 := 0 ; musl_tip2 := space(19) ; mm_usl_tip2 := {}
      lstr_sod := ret_str_onc(1,2) ; mvsod := 0 ; msod := space(6)
      lstr_fr  := ret_str_onc(2,2)
      lstr_wei := ret_str_onc(3,2)
      lstr_hei := ret_str_onc(4,2)
      lstr_bsa := ret_str_onc(5,2)
      lstr_err := ret_str_onc(6,2) ; mis_err := space(11)
      lstr_she := ret_str_onc(7,2) ; mcrit := space(57)
      lstr_lek := ret_str_onc(8,2) ; mlek := space(53) ; m1lek := space(53)
      lstr_ptr := ret_str_onc(6,2) ; mpptr := space(3)
      //
      lstr_vmp1 := space(12) ; m1usl_vmp1 := 0 ; musl_vmp1 := space(69) ; mm_usl_vmp1 := {}
      lstr_vmp2 := space(13) ; m1usl_vmp2 := 0 ; musl_vmp2 := space(19) ; mm_usl_vmp2 := {}
      lstr_vmpsod := ret_str_onc(1,2) ; mvsod_vmp := 0 ; msod_vmp := space(6)
      lstr_vmpfr  := ret_str_onc(2,2)
      lstr_vmpwei := ret_str_onc(3,2)
      lstr_vmphei := ret_str_onc(4,2)
      lstr_vmpbsa := ret_str_onc(5,2)
      lstr_vmperr := ret_str_onc(6,2)
      lstr_vmpshe := ret_str_onc(7,2)
      lstr_vmplek := ret_str_onc(8,2)
      lstr_vmpptr := ret_str_onc(6,2)
      use (cur_dir+"tmp_onkus") new alias TMPOU
      index on str(usl_tip,1) to (cur_dir+"tmp_onkus")
      go top
      if lastrec() == 0
        append blank
      endif
      m1USL_TIP := tmpou->USL_TIP
      is_gisto := .f. ; m1rez_gist := 0 ; kg := 0
      //
      k := 16
      if len(mm_N009) == 0 .and. len(mm_N012) == 0
        if (is_gisto := (m1usl_ok == 3 .and. m1profil == 15))  // поликлиника + профиль = гистология
          aeval(arr_rez_gist,{|x| iif(x[4] > 0, ++kg, )})
          m1rez_gist := iif(kg > 0, 1, 0)
          mrez_gist := "количество гистологий - "+lstr(kg)
          mDIAG_DATE := mn_data
          m1B_DIAG := 98
        endif
        k--
      else
        if len(mm_N009) == 0
          k++
        else
          k += min(2,len(mm_N009))
        endif
        if len(mm_N012) == 0
          k++
        else
          k += min(5,len(mm_N012))
        endif
      endif
      fl_2_4 := fl_3_4 := .f.
      fl2_2_4 := fl2_3_4 := .f.
      if m1usl_ok < 3 // стационар или дневной стационар
        if is_onko_VMP
          k += 14
          m1USL_TIP := musl1vmp
          mm_USL_TIP := {}
          if (i := ascan(mm_USL_TIP_all,{|x| x[2] == musl1vmp })) > 0
            aadd(mm_USL_TIP, aclone(mm_USL_TIP_all[i]))
          endif
          if mtipvmp == 0 // одна услуга
            if musl2vmp > 0 .and. (i := ascan(mm_USL_TIP_all,{|x| x[2] == musl2vmp })) > 0 // одна услуга из двух
              aadd(mm_USL_TIP, aclone(mm_USL_TIP_all[i]))
            endif
            if ascan(mm_USL_TIP, {|x| x[2] == 2 }) > 0
              fl_2_4 := .t.
              k += 5
            endif
            if ascan(mm_USL_TIP, {|x| x[2] == 3 }) > 0
              fl_3_4 := .t.
              ++k
            endif
          else//if mtipvmp == 1 две услуги
            m1usl_vmp := musl2vmp
            if musl1vmp == 2  // 1-я услуга
              fl_2_4 := .t.
              k += 5
            elseif musl1vmp == 3
              fl_3_4 := .t.
              ++k
            endif
            k += 3 // строки наименования и шапки для 2-ой услуги
            if musl2vmp == 2  // 2-я услуга
              fl2_2_4 := .t.
              k += 5
            elseif musl2vmp == 3
              fl2_3_4 := .t.
              ++k
            endif
          endif
        else // нет ВМП
          k += 20
          fl_2_4 := fl_3_4 := .t.
          mm_USL_TIP := aclone(mm_USL_TIP_all)
          //if m1vzros_reb > 0 .or. is_lymphoid(mkod_diag) // если ребёнок или ЗНО кроветворная или лимфоидная
            //Del_Array(mm_USL_TIP,5) // удалим химиолучевую
            //Del_Array(mm_USL_TIP,4) // удалим лучевую
          //endif
        endif
       if is_onko_VMP .and. mtipvmp == 1 // две услуги
        mUSL_VMP := inieditspr(A__MENUVERT, mm_USL_TIP_all, m1USL_VMP)
        select TMPOU
        find (str(m1usl_vmp,1))
        if m1usl_vmp == 2
          m1usl_vmp1 := iif(found(), tmpou->LEK_TIP_V, 0)
          mm_usl_vmp1 := mm_N016
          m1usl_vmp2 := iif(found(), tmpou->LEK_TIP_L, 0)
          mm_usl_vmp2 := mm_N015
          lstr_vmp2 := "Линия терапии"
          musl_vmp2 := inieditspr(A__MENUVERT, mm_usl_vmp2, m1usl_vmp2)
          lstr_vmperr := ret_str_onc(6,1)
          mis_err := inieditspr(A__MENUVERT, mm_shema_err, m1is_err)
          lstr_vmpwei := ret_str_onc(3,1)
          lstr_vmphei := ret_str_onc(4,1)
          lstr_vmpbsa := ret_str_onc(5,1)
          lstr_vmpshe := ret_str_onc(7,1)
          mm_shema_usl := _arr_sh
          mcrit := inieditspr(A__MENUVERT, mm_shema_usl, m1crit)
          lstr_vmplek := ret_str_onc(8,1)
          mlek := m1lek := init_lek_pr(m1usl_vmp,m1crit)
          lstr_vmpptr := ret_str_onc(9,1)
          m1pptr := tmpou->pptr
          mpptr := inieditspr(A__MENUVERT, mm_danet, m1pptr)
        elseif m1usl_vmp == 3
          m1usl_vmp1 := iif(found(), tmpou->LUCH_TIP, 0)
          mm_usl_vmp1 := mm_N017
          mvsod_vmp := iif(found(), tmpou->sod, 0)
          lstr_vmpsod := ret_str_onc(1,1)
          msod_vmp := padr(alltrim(str_0(mvsod_vmp,6,2)),6)
          lstr_vmpfr  := ret_str_onc(2,1)
        endif
        lstr_vmp1 := padr(mm_str1[m1usl_vmp+1],12)
        musl_vmp1 := inieditspr(A__MENUVERT, mm_usl_vmp1, m1usl_vmp1)
       endif
      endif
      //
      mUSL_TIP := inieditspr(A__MENUVERT, mm_USL_TIP, m1USL_TIP)
      select TMPOU
      find (str(m1usl_tip,1))
      if !found()
        go top
      endif
      if m1usl_tip == 1
        m1usl_tip1 := tmpou->HIR_TIP
        mm_usl_tip1 := mm_N014
      elseif m1usl_tip == 2
        m1usl_tip1 := tmpou->LEK_TIP_V
        mm_usl_tip1 := mm_N016
        m1usl_tip2 := tmpou->LEK_TIP_L
        mm_usl_tip2 := mm_N015
      elseif eq_any(m1usl_tip,3,4)
        m1usl_tip1 := tmpou->LUCH_TIP
        mm_usl_tip1 := mm_N017
        mvsod := tmpou->sod
      endif
      if between(m1usl_tip,1,4)
        lstr1 := padr(mm_str1[m1usl_tip+1],12)
        musl_tip1 := inieditspr(A__MENUVERT, mm_usl_tip1, m1usl_tip1)
        if m1usl_tip == 2
          lstr2 := "Линия терапии"
          musl_tip2 := inieditspr(A__MENUVERT, mm_usl_tip2, m1usl_tip2)
          lstr_err := ret_str_onc(6,1)
          mis_err := inieditspr(A__MENUVERT, mm_shema_err, m1is_err)
        endif
        if eq_any(m1usl_tip,3,4)
          lstr_sod := ret_str_onc(1,1)
          msod := padr(alltrim(str_0(mvsod,6,2)),6)
          lstr_fr  := ret_str_onc(2,1)
        endif
        if eq_any(m1usl_tip,2,4)
          lstr_wei := ret_str_onc(3,1)
          lstr_hei := ret_str_onc(4,1)
          lstr_bsa := ret_str_onc(5,1)
          lstr_she := ret_str_onc(7,1)
          if left(m1crit,2) == "mt" .and. m1usl_tip == 2
            m1crit := space(10)
          elseif eq_any(left(m1crit,2),"не","sh") .and. m1usl_tip == 4
            m1crit := space(10)
          endif
          mm_shema_usl := iif(m1usl_tip == 2, _arr_sh, _arr_mt)
          mcrit := inieditspr(A__MENUVERT, mm_shema_usl, m1crit)
          lstr_lek := ret_str_onc(8,1)
          mlek := m1lek := init_lek_pr(m1usl_tip,m1crit)
          lstr_ptr := ret_str_onc(9,1)
          m1pptr := tmpou->pptr
          mpptr := inieditspr(A__MENUVERT, mm_danet, m1pptr)
        endif
      endif
      mmb_diag := {{"выполнено (результат получен)",98},;
                   {"выполнено (результат не получен)",97},;
                   {"выполнено (до 1 сентября 2018г.)",-1},;
                   {"отказ",0},;
                   {"не показано",7},;
                   {"противопоказано",8}}
      mB_DIAG := inieditspr(A__MENUVERT, mmb_diag, m1B_DIAG)
    endif
    SetMode(max(25,k),80)
    pr_1_str("Ввод/редактирование контрольного листа учёта ЗНО")
    j := 1
    myclear(j)
    pos_read := 0
         @ j,1 say "Осн.диагноз" color color8 get mkod_diag when .f.
    if yes_num_lu == 1 .and. Loc_kod > 0
         @ j,50 say padl("Лист учета № "+lstr(Loc_kod),29) color color14
    endif
    ++j; @ j,1 say "ФИО" get mfio_kart when .f.
         @ j,57 get mn_data when .f.
         @ row(),col()+1 say "-" get mk_data when .f.
    ++j; @ j,1 say "НАПРАВЛЕНИЕ №" get cur_napr pict "99" when .f.
         @ j,col() say "(из" get count_napr pict "99" when .f.
         @ j,col() say ")"
         @j,29 say "(<F5> - добавление/редактирование направления №...)" color "G/B"
    ++j; @ j,3 say "Дата направления" get mNAPR_DATE ;
               valid {|| iif(empty(mNAPR_DATE) .or. between(mNAPR_DATE,mn_data,mk_data), .t., ;
                             func_error(4,"Дата направления должна быть внутри сроков лечения")) }
    ++j; @ j,3 say "В какую МО направлен" get mnapr_mo ;
               reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c)}},A__FUNCTION,,,.f.)}
    ++j; @ j,3 say "Вид направления" get mnapr_v ;
               reader {|x|menu_reader(x,mm_napr_v,A__MENUVERT,,,.f.)} //; color colget_menu
    ++j; @ j,5 say "Метод диагностического исследования" get mmet_issl ;
               reader {|x|menu_reader(x,mm_met_issl,A__MENUVERT,,,.f.)} ;
               when m1napr_v == 3 //; color colget_menu
    ++j; @ j,5 say "Медицинская услуга" get mshifr pict "@!" ;
               when {|g| m1napr_v == 3 .and. m1MET_ISSL > 0 } ;
               valid {|g|
                          Local fl := f5editkusl(g,2,2)
                          if empty(mshifr)
                            mu_kod  := 0
                            mname_u := space(65)
                            mshifr1 := mshifr
                          elseif fl .and. tip_onko_napr > 0 .and. tip_onko_napr != m1MET_ISSL
                            func_error(4,"Тип медуслуги не соответствует методу диагностического исследования")
                          endif
                          return fl
                     }
    ++j; @ j,7 say "Услуга" get mname_u when .f. color color14
  if is_oncology == 2
    ++j; @ j,1 say "СВЕДЕНИЯ О СЛУЧАЕ ЛЕЧЕНИЯ ОНКОЛОГИЧЕСКОГО ЗАБОЛЕВАНИЯ"
    ++j; @ j,3 say "Повод обращения" get mDS1_T ;
               reader {|x|menu_reader(x,lmm_DS1_T,A__MENUVERT,,,.f.)} ;
               color colget_menu
    ++j; @ j,3 say "Стадия заболевания:" get mSTAD ;
               reader {|x|menu_reader(x,mm_N002,A__MENUVERT,,,.f.)} ;
               valid {|g| f_valid_tnm(g), mSTAD:=padr(mSTAD,5), .t.} ;
               when between(m1ds1_t,0,4) ;
               color colget_menu
         @ j,col() say " Tumor" get mONK_T ;
               reader {|x|menu_reader(x,mm_N003,A__MENUVERT,,,.f.)} ;
               valid {|g| f_valid_tnm(g), mONK_T:=padr(mONK_T,5), .t.} ;
               when m1ds1_t == 0 .and. m1vzros_reb == 0 ;
               color colget_menu
         @ j,col() say " Nodus" get mONK_N ;
               reader {|x|menu_reader(x,mm_N004,A__MENUVERT,,,.f.)} ;
               valid {|g| f_valid_tnm(g), mONK_N:=padr(mONK_N,5), .t.} ;
               when m1ds1_t == 0 .and. m1vzros_reb == 0 ;
               color colget_menu
         @ j,col() say " Metastasis" get mONK_M ;
               reader {|x|menu_reader(x,mm_N005,A__MENUVERT,,,.f.)} ;
               valid {|g| f_valid_tnm(g), mONK_M:=padr(mONK_M,5), .t.} ;
               when m1ds1_t == 0 .and. m1vzros_reb == 0 ;
               color colget_menu
    ++j; @ j,5 say "Наличие отдаленных метастазов (при рецидиве или прогрессировании)" get mMTSTZ ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
               when eq_any(m1DS1_T,1,2) ;
               color colget_menu
  if len(mm_N009) == 0 .and. len(mm_N012) == 0
    if is_gisto
      ++j; @ j,3 say "Результаты гистологии" get mrez_gist ;
               reader {|x|menu_reader(x,{{|k,r,c| get_rez_gist(k,r,c)}},A__FUNCTION,,,.f.)}
    else
      ++j; @ j,3 say "Гистология / иммуногистохимия: не нужно для "+iif(is_mgi, "МГИ", mkod_diag)
    endif
  else
    ++j; @ j,3 say "Гистология / иммуногистохимия" get mB_DIAG ;
               reader {|x|menu_reader(x,mmb_diag,A__MENUVERT,,,.f.)}
    ++j; @ j,3 say "Дата взятия материала" get mDIAG_DATE ;
               when eq_any(m1b_diag,97,98) ;
               valid {|| iif(empty(mDIAG_DATE) .or. mDIAG_DATE <= mk_data, .t., ;
                             func_error(4,"Дата взятия материала больше даты окончания лечения")) }
   if len(mm_N009) == 0
    ++j; @ j,3 say "Гистология: не нужно для "+iif(is_mgi, "МГИ", mkod_diag)
   else
    ++j; @ j,3 say mm_N009[1,1] get mgist1 ;
               reader {|x|menu_reader(x,mm_N009[1,3],A__MENUVERT,,,.f.)} ;
               when m1b_diag == 98 ;
               color colget_menu
    if len(mm_N009) >= 2
    ++j; @ j,3 say mm_N009[2,1] get mgist2 ;
               reader {|x|menu_reader(x,mm_N009[2,3],A__MENUVERT,,,.f.)} ;
               when m1b_diag == 98 ;
               color colget_menu
    endif
   endif
   if len(mm_N012) == 0
    ++j; @ j,3 say "Иммуногистохимия: не нужно для "+iif(is_mgi, "МГИ", mkod_diag)
   else
    ++j; @ j,3 say mm_N012[1,1] get mmark1 ;
               reader {|x|menu_reader(x,mm_N012[1,3],A__MENUVERT,,,.f.)} ;
               when m1b_diag == 98 ;
               color colget_menu
    if len(mm_N012) >= 2
    ++j; @ j,3 say mm_N012[2,1] get mmark2 ;
               reader {|x|menu_reader(x,mm_N012[2,3],A__MENUVERT,,,.f.)} ;
               when m1b_diag == 98 ;
               color colget_menu
    endif
    if len(mm_N012) >= 3
    ++j; @ j,3 say mm_N012[3,1] get mmark3 ;
               reader {|x|menu_reader(x,mm_N012[3,3],A__MENUVERT,,,.f.)} ;
               when m1b_diag == 98 ;
               color colget_menu
    endif
    if len(mm_N012) >= 4
    ++j; @ j,3 say mm_N012[4,1] get mmark4 ;
               reader {|x|menu_reader(x,mm_N012[4,3],A__MENUVERT,,,.f.)} ;
               when m1b_diag == 98 ;
               color colget_menu
    endif
    if len(mm_N012) >= 5
    ++j; @ j,3 say mm_N012[5,1] get mmark5 ;
               reader {|x|menu_reader(x,mm_N012[5,3],A__MENUVERT,,,.f.)} ;
               when m1b_diag == 98 ;
               color colget_menu
    endif
   endif
  endif
  ++j; @ j,3 say "Консилиум: дата" get mDT_CONS ;
             valid {|| iif(empty(mDT_CONS) .or. between(mDT_CONS,mn_data,mk_data), .t., ;
                           func_error(4,"Дата консилиума должна быть внутри сроков лечения")) }
       @ j,col()+1 say "проведение" get mPR_CONS ;
             reader {|x|menu_reader(x,mm_PR_CONS,A__MENUVERT,,,.f.)} ;
             when !empty(mDT_CONS) ;
             color colget_menu
  if m1usl_ok < 3
    ++j; @ j,3 say "Проведённое лечение" get musl_tip ;
               reader {|x|menu_reader(x,mm_usl_tip,A__MENUVERT,,,.f.)} ;
               when len(mm_usl_tip) > 1 ;
               valid {|g,o| f_valid_usl_tip(g,o) } ;
               color colget_menu
    ++j; @ j,5 get lstr1 color color1 when .f.
         @ j,col()+1 get musl_tip1 ;
               reader {|x|menu_reader(x,mm_usl_tip1,A__MENUVERT,,,.f.)} ;
               when between(m1usl_tip,1,4)
    ++j; @ j,5 get lstr2 color color1 when .f.
         @ j,col()+1 get musl_tip2 ;
               reader {|x|menu_reader(x,mm_usl_tip2,A__MENUVERT,,,.f.)} ;
               when m1usl_tip == 2
   if fl_3_4
    ++j; @ j,5 get lstr_sod color color1 when .f.
         @ j,col()+1 get msod when between(m1usl_tip,3,4)
         @ j,col()+5 get lstr_fr color color1 when .f.
         @ j,col()+1 get mk_fr when between(m1usl_tip,3,4)
   endif
   if fl_2_4
    ++j; @ j,5 get lstr_wei color color1 when .f.
         @ j,col()+1 get mwei when eq_any(m1usl_tip,2,4)
         @ j,col()+1 get lstr_hei color color1 when .f.
         @ j,col()+1 get mhei when eq_any(m1usl_tip,2,4)
         @ j,col()+1 get lstr_bsa color color1 when .f.
         @ j,col()+1 get mbsa when eq_any(m1usl_tip,2,4)
    ++j; @ j,5 get lstr_err color color1 when .f.
         @ j,col()+1 get mis_err ;
               reader {|x|menu_reader(x,mm_shema_err,A__MENUVERT,,,.f.)} ;
               when m1usl_tip == 2
    ++j; @ j,5 get lstr_she color color1 when .f.
         @ j,col()+1 get mcrit ;
               reader {|x| menu_reader(x,mm_shema_usl,A__MENUVERT,,,.f.)} ;
               when eq_any(m1usl_tip,2,4)
    ++j; @ j,5 get lstr_lek color color1 when .f.
         @ j,col()+1 get mlek ;
               reader {|x|menu_reader(x,{{|k,r,c| get_lek_pr(k,r,c,m1crit)}},A__FUNCTION,,,.f.)} ;
               when !empty(m1crit) .and. eq_any(m1usl_tip,2,4)
    ++j; @ j,5 get lstr_ptr color color1 when .f.
         @ j,col()+1 get mpptr ;
               reader {|x| menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
               when eq_any(m1usl_tip,2,4)
   endif
    if is_onko_VMP .and. mtipvmp == 1 // две услуги
    ++j; @ j,3 say "ВМП: дополнительное лечение" get musl_vmp when .f. ;
               color colget_menu
    ++j; @ j,5 get lstr_vmp1 color color1 when .f.
         @ j,col()+1 get musl_vmp1 ;
               reader {|x|menu_reader(x,mm_usl_vmp1,A__MENUVERT,,,.f.)}
    ++j; @ j,5 get lstr_vmp2 color color1 when .f.
         @ j,col()+1 get musl_vmp2 ;
               reader {|x|menu_reader(x,mm_usl_vmp2,A__MENUVERT,,,.f.)} ;
               when m1usl_vmp == 2
     if fl2_3_4
    ++j; @ j,5 get lstr_vmpsod color color1 when .f.
         @ j,col()+1 get msod_vmp when between(m1usl_vmp,3,4)
         @ j,col()+5 get lstr_vmpfr color color1 when .f.
         @ j,col()+1 get mk_fr when between(m1usl_vmp,3,4)
     endif
     if fl2_2_4
    ++j; @ j,5 get lstr_vmpwei color color1 when .f.
         @ j,col()+1 get mwei when eq_any(m1usl_vmp,2,4)
         @ j,col()+1 get lstr_vmphei color color1 when .f.
         @ j,col()+1 get mhei when eq_any(m1usl_vmp,2,4)
         @ j,col()+1 get lstr_vmpbsa color color1 when .f.
         @ j,col()+1 get mbsa when eq_any(m1usl_vmp,2,4)
    ++j; @ j,5 get lstr_vmperr color color1 when .f.
         @ j,col()+1 get mis_err ;
               reader {|x|menu_reader(x,mm_shema_err,A__MENUVERT,,,.f.)} ;
               when m1usl_vmp == 2
    ++j; @ j,5 get lstr_vmpshe color color1 when .f.
         @ j,col()+1 get mcrit ;
               reader {|x| menu_reader(x,mm_shema_usl,A__MENUVERT,,,.f.)} ;
               when eq_any(m1usl_vmp,2,4)
    ++j; @ j,5 get lstr_vmplek color color1 when .f.
         @ j,col()+1 get mlek ;
               reader {|x|menu_reader(x,{{|k,r,c| get_lek_pr(k,r,c,m1crit)}},A__FUNCTION,,,.f.)} ;
               when !empty(m1crit) .and. eq_any(m1usl_vmp,2,4)
    ++j; @ j,5 get lstr_vmpptr color color1 when .f.
         @ j,col()+1 get mpptr ;
               reader {|x| menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
               when eq_any(m1usl_vmp,2,4)
     endif
    endif
    //
    arr := {"хирургического лечения","химиотерапевтического лечения","лучевой терапии"}
    ++j; @ j,3 say "Противопоказания к проведению:"
         @ j,50 say "дата регистрации:"
   for i := 1 to 3
    mval := "mprot"+lstr(i)
    mdval := "mdprot"+lstr(i)
    ++j; @ j,5 say arr[i] get &mval ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
               color colget_menu
         @ j,53 get &mdval
   next i
    ++j; @ j,3 say "Отказы от проведения:"
         @ j,50 say "дата регистрации:"
   for i := 4 to 6
    mval := "mprot"+lstr(i)
    mdval := "mdprot"+lstr(i)
    ++j; @ j,5 say arr[i-3] get &mval ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
               color colget_menu
         @ j,53 get &mdval
   next i
  endif
  endif
    //
    status_key("^<Esc>^ выход без записи ^<PgUp>^ на 1-ю страницу ^<PgDn>^ ЗАПИСЬ")
  endif
  if num_screen == 2
    set key K_F5 TO change_num_napr
  endif
  count_edit += myread(,@pos_read)
  //count_edit := myread(,@pos_read,++k_read)
  close databases
  if num_screen == 2
    set key K_F5 TO
    if !(emptyany(mNAPR_DATE,m1NAPR_V) .and. count_napr == 0)
      if cur_napr == 0
        cur_napr := 1
      endif
      use (cur_dir+"tmp_onkna") new alias TNAPR
      count_napr := lastrec()
      if cur_napr <= count_napr
        goto (cur_napr) // номер текущего направления
      else
        append blank
      endif
      tnapr->NAPR_DATE := mNAPR_DATE
      tnapr->NAPR_MO := m1NAPR_MO
      tnapr->NAPR_V := m1NAPR_V
      tnapr->MET_ISSL := iif(m1NAPR_V == 3, m1MET_ISSL, 0)
      tnapr->U_KOD := iif(m1NAPR_V == 3, mu_kod, 0)
      tnapr->shifr_u := iif(m1NAPR_V == 3, mshifr, "")
      tnapr->shifr1 := iif(m1NAPR_V == 3, mshifr1, "")
      tnapr->name_u := iif(m1NAPR_V == 3, mname_u, "")
      cur_napr := recno()
    endif
    if is_oncology == 2
      use (cur_dir+"tmp_onkdi") new alias TDIAG
      zap
      if eq_any(m1B_DIAG,97,98) // гистология:98-сделана,97-нет результата
        if len(mm_N009) > 0
          for i := 1 to min(2,len(mm_N009))
            append blank
            tdiag->DIAG_DATE := mDIAG_DATE
            tdiag->DIAG_TIP := 1 // 1 - гистологический признак
            tdiag->DIAG_CODE := mm_N009[i,2]
            if m1B_DIAG == 98
              tdiag->DIAG_RSLT := &("m1gist"+lstr(i))
              tdiag->REC_RSLT := 1
            else
              tdiag->DIAG_RSLT := 0
              tdiag->REC_RSLT := 0
            endif
          next
        endif
        if len(mm_N012) > 0
          for i := 1 to min(5,len(mm_N012))
            append blank
            tdiag->DIAG_DATE := mDIAG_DATE
            tdiag->DIAG_TIP := 2 // 2 - маркёр (ИГХ)
            tdiag->DIAG_CODE := mm_N012[i,2]
            if m1B_DIAG == 98
              tdiag->DIAG_RSLT := &("m1mark"+lstr(i))
              tdiag->REC_RSLT := 1
            else
              tdiag->DIAG_RSLT := 0
              tdiag->REC_RSLT := 0
            endif
          next
        endif
      endif
      use (cur_dir+"tmp_onkpr") new alias TPR
      zap
      for i := 1 to 6
        if !emptyany(&("m1prot"+lstr(i)),&("mdprot"+lstr(i)))
          append blank
          tpr->prot := i
          tpr->d_prot := &("mdprot"+lstr(i))
        endif
      next i
      if eq_any(m1B_DIAG,0,7,8) // гистология:0-отказ,7-не показано,8-противопоказано
        append blank
        tpr->prot := m1B_DIAG
        tpr->d_prot := mn_data
      endif
      use (cur_dir+"tmp_onkus") new alias TMPOU
      go top
      if lastrec() == 0
        append blank
      endif
      tmpou->USL_TIP := m1USL_TIP
      tmpou->HIR_TIP := iif(m1usl_tip == 1, m1usl_tip1, 0)
      tmpou->LEK_TIP_V := iif(m1usl_tip == 2, m1usl_tip1, 0)
      tmpou->LEK_TIP_L := iif(m1usl_tip == 2, m1usl_tip2, 0)
      tmpou->LUCH_TIP := iif(eq_any(m1usl_tip,3,4), m1usl_tip1, 0)
      tmpou->PPTR := iif(eq_any(m1usl_tip,2,4), m1PPTR, 0)
      if eq_any(m1usl_tip,3,4)
        if val(msod) < 1000
          tmpou->sod := val(CHARREPL(",",msod,"."))
        else
          tmpou->sod := 100
        endif
      else
        tmpou->sod := 0
      endif
      if is_onko_VMP .and. mtipvmp == 1 // две услуги
        if lastrec() == 1
          append blank
        endif
        goto (2)
        tmpou->USL_TIP := m1USL_VMP
        tmpou->HIR_TIP := iif(m1usl_vmp == 1, m1usl_vmp1, 0)
        tmpou->LEK_TIP_V := iif(m1usl_vmp == 2, m1usl_vmp1, 0)
        tmpou->LEK_TIP_L := iif(m1usl_vmp == 2, m1usl_vmp2, 0)
        tmpou->LUCH_TIP := iif(eq_any(m1usl_vmp,3,4), m1usl_vmp1, 0)
        tmpou->PPTR := iif(eq_any(m1usl_vmp,2,4), m1PPTR, 0)
        if eq_any(m1usl_vmp,3,4)
          if val(msod_vmp) < 1000
            tmpou->sod := val(CHARREPL(",",msod_vmp,"."))
          else
            tmpou->sod := 100
          endif
        else
          tmpou->sod := 0
        endif
      else
        for i := 2 to lastrec()
          goto (i)
          delete
        next
        pack
      endif
    endif
    close databases
  else
    if is_talon
      set key K_F10 TO
    endif
  endif
  diag_screen(2)
  if num_screen == 2
    if lastkey() == K_PGUP
      k := 3
      num_screen := 1
    else
      k := f_alert({padc("Выберите действие",60,".")},;
                   {" Выход без записи "," Запись "," Возврат в редактирование "},;
                   iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
    endif
  else
    is_oncology := f_is_oncology(2)
    if lastkey() != K_ESC .and. is_oncology > 0
      k := 3
      num_screen := 2
    else
      k := f_alert({padc("Выберите действие",60,".")},;
                   {" Выход без записи "," Запись "," Возврат в редактирование "},;
                   iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
    endif
  endif
  SetMode(25,80) // Определить окно 25*80 символов
  if k == 3
    loop
  elseif k == 2
    num_screen := 1  // ошибки 1-го экрана
    if empty(mn_data)
      func_error(4,"Не введена дата начала лечения.")
      loop
    endif
    if empty(mk_data)
      func_error(4,"Не введена дата окончания лечения.")
      loop
    endif
    if m1_l_z == 1 .and. empty(mkod_diag)
      func_error(4,"Не введен шифр основного заболевания.")
      loop
    endif
    if m1bolnich > 0
      if emptyany(mdate_b_1,mdate_b_2)
        func_error(4,"Не заполнены периоды больничного.")
        loop
      endif
      if mdate_b_1 > mdate_b_2
        func_error(4,"Некорректные даты начала и окончания больничного.")
        loop
      endif
      if m1bolnich == 2 .and. emptyany(mrodit_dr,mrodit_pol)
        func_error(4,"Не заполнены реквизиты родителей в больничном")
        loop
      endif
    endif
    if empty(CHARREPL("0",much_doc,space(10)))
      func_error(4,'Не заполнен номер амбулаторной карты (истории болезни)')
      loop
    endif
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
    if is_MO_VMP
      if M1VMP == 1
        if empty(M1VIDVMP)
          func_error(4,'Не заполнен вид ВМП')
          loop
        elseif empty(M1METVMP)
          func_error(4,'Не заполнен метод ВМП')
          loop
        endif
      else
        M1VIDVMP := ""
        M1METVMP := 0
      endif
    else
      M1VMP := 0
      M1VIDVMP := ""
      M1METVMP := 0
    endif
    err_date_diap(mn_data,"Дата начала лечения")
    err_date_diap(mk_data,"Дата окончания лечения")
    restscreen(buf)
    if mem_op_out == 2 .and. yes_parol
      box_shadow(19,10,22,69,cColorStMsg)
      str_center(20,'Оператор "'+fio_polzovat+'".',cColorSt2Msg)
      str_center(21,'Ввод данных за '+date_month(sys_date),cColorStMsg)
    endif
    mywait("Ждите. Производится запись листа учёта ...")
    if yes_vypisan == B_END
      mtip_h := B_END + m1_l_z
      st_l_z := m1_l_z
    endif
    make_diagP(2)  // сделать "пятизначные" диагнозы
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
    if isbit(mem_oms_pole,1)  //  "сроки лечения",;  1
      st_N_DATA := MN_DATA
      st_K_DATA := MK_DATA
    endif
    if isbit(mem_oms_pole,2)  //  "леч.врач",;       2
      st_VRACH := m1vrach
    endif
    if isbit(mem_oms_pole,3)  //  "осн.диагноз",;    3
      SKOD_DIAG := substr(MKOD_DIAG,1,5)
    endif
    if isbit(mem_oms_pole,4)  //  "профиль",;        4
      st_PROFIL := m1PROFIL
    endif
    if isbit(mem_oms_pole,5)  //  "результат",;      5
      st_RSLT := m1rslt
    endif
    if isbit(mem_oms_pole,6)  //  "исход",;          6
      st_ISHOD := m1ishod
    endif
    /*if isbit(mem_oms_pole,7)  //  "повод обращения"  7
      st_povod := m1povod
    endif*/
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
    human->TIP_H      := mtip_h
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
    human->KOMU       := M1KOMU        // от 0 до 5
    human_->SMO       := msmo
    human->STR_CRB    := m1str_crb
    human->POLIS      := make_polis(mspolis,mnpolis) // серия и номер страхового полиса
    human->LPU        := M1LPU         // код учреждения
    human->OTD        := M1OTD         // код отделения
    human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
    human->N_DATA     := MN_DATA       // дата начала лечения
    human->K_DATA     := MK_DATA       // дата окончания лечения
    if is_dop_ob_em
      human->reg_lech := m1reg_lech    // 0-основные, 9-дополнительные объёмы
    endif
    human->CENA       := MCENA_1       // стоимость лечения
    human->CENA_1     := MCENA_1       // стоимость лечения
    human->OBRASHEN := iif(m1DS_ONK == 1, '1', " ")
    human->bolnich    := m1bolnich
    human->date_b_1   := iif(m1bolnich == 0, "", dtoc4(mdate_b_1))
    human->date_b_2   := iif(m1bolnich == 0, "", dtoc4(mdate_b_2))
    human_->RODIT_DR  := iif(m1bolnich < 2, ctod(""), mrodit_dr)
    human_->RODIT_POL := iif(m1bolnich < 2, "", mrodit_pol)
    s := "" ; aeval(adiag_talon, {|x| s += str(x,1) })
    human_->DISPANS   := s
    human_->STATUS_ST := ltrim(MSTATUS_ST)
    //human_->POVOD     := m1povod
    //human_->TRAVMA    := m1travma
    human_->VPOLIS    := m1vidpolis
    human_->SPOLIS    := ltrim(mspolis)
    human_->NPOLIS    := ltrim(mnpolis)
    human_->OKATO     := "" // это поле вернётся из ТФОМС в случае иногороднего
    human_->NOVOR     := iif(m1novor==0, 0       , mcount_reb)
    human_->DATE_R2   := iif(m1novor==0, ctod(""), mDATE_R2  )
    human_->POL2      := iif(m1novor==0, ""      , mpol2     )
    human_->USL_OK    := m1USL_OK
    human_->PROFIL    := m1PROFIL
    human_->NPR_MO    := m1NPR_MO
    human_->FORMA14   := str(M1F14_EKST,1)+str(M1F14_SKOR,1)+str(M1F14_VSKR,1)+str(M1F14_RASH,1)
    human_->KOD_DIAG0 := mkod_diag0
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
    human_2->OSL1   := MOSL1
    human_2->OSL2   := MOSL2
    human_2->OSL3   := MOSL3
    human_2->NPR_DATE := mNPR_DATE
    human_2->PROFIL_K := m1PROFIL_K
    human_2->p_per  := iif(eq_any(m1USL_OK,1,2), m1p_per, 0)
    human_2->VMP    := M1VMP
    human_2->TAL_NUM  := mTAL_NUM
    human_2->TAL_D  := mTAL_D
    human_2->TAL_P  := mTAL_P
    human_2->VIDVMP := M1VIDVMP
    human_2->METVMP := M1METVMP
    /*if year(mk_data) == 2017 .and. between(M1METVMP,498,499)
      human_2->PC1 := mstentvmp // кол-во стентов для методов ВМП 498,499
    endif*/
    human_2->VNR    := val(MVNR)
    human_2->VNR1   := val(MVNR1)
    human_2->VNR2   := val(MVNR2)
    human_2->VNR3   := val(MVNR3)
    if is_reabil_slux .and. eq_any(m1usl_ok,1,2) .and. m1profil == 158
      human_2->PN1 := m1vid_reab
    endif
    human_2->PN2 := iif(f_oms_beremenn(mkod_diag) > 0, m1prer_b, 0)
    human_2->PC3 := iif(input_ad_cr, m1ad_cr, "")
    if is_oncology == 0 // нет онкологии
      if old_oncology // но была в листе учёта
        G_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","NAPR") // онконаправления
        do while .t.
          find (str(mkod,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkco",dir_server+"mo_onkco","CO")
        do while .t.
          find (str(mkod,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
      endif
    endif
    if is_oncology == 1 // только направления
      if old_oncology // но была онкология в листе учёта
        G_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","SL")
        do while .t.
          find (str(mkod,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","DI")
        do while .t.
          find (str(mkod,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","PR")
        do while .t.
          find (str(mkod,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkus",dir_server+"mo_onkus","US")
        do while .t.
          find (str(mkod,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkle",dir_server+"mo_onkle","LE")
        do while .t.
          find (str(mkod,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
      endif
    endif
    if is_oncology > 0 // онкология - направления
      arr := {}
      Use_base("mo_su")
      use (cur_dir+"tmp_onkna") new alias TNAPR
      G_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","NAPR") // онконаправления
      find (str(mkod,7))
      do while napr->kod == mkod .and. !eof()
        aadd(arr,recno())
        skip
      enddo
      cur_napr := 0
      select TNAPR
      go top
      do while !eof()
        if !emptyany(tnapr->NAPR_DATE,tnapr->NAPR_V)
          if tnapr->U_KOD == 0 // добавляем в свой справочник федеральную услугу
            select MOSU
            set order to 3
            find (tnapr->shifr1)
            if found()  // наверное, добавили только что
              tnapr->U_KOD := mosu->kod
            else
              set order to 1
              FIND (STR(-1,6))
              if found()
                G_RLock(forever)
              else
                AddRec(6)
              endif
              tnapr->U_KOD := mosu->kod := recno()
              mosu->name   := tnapr->name_u
              mosu->shifr1 := tnapr->shifr1
            endif
          endif
          select NAPR
          if ++cur_napr > len(arr)
            AddRec(7)
            napr->kod := mkod
          else
            goto (arr[cur_napr])
            G_RLock(forever)
          endif
          napr->NAPR_DATE := tnapr->NAPR_DATE
          napr->NAPR_MO := tnapr->NAPR_MO
          napr->NAPR_V := tnapr->NAPR_V
          napr->MET_ISSL := iif(tnapr->NAPR_V == 3, tnapr->MET_ISSL, 0)
          napr->U_KOD := iif(tnapr->NAPR_V == 3, tnapr->U_KOD, 0)
        endif
        select TNAPR
        skip
      enddo
      select NAPR
      do while ++cur_napr <= len(arr)
        goto (arr[cur_napr])
        DeleteRec(.t.)
      enddo
      //
      G_Use(dir_server+"mo_onkco",dir_server+"mo_onkco","CO")
      find (str(mkod,7))
      if found()
        G_RLock(forever)
      else
        AddRec(7)
        co->kod := mkod
      endif
      co->PR_CONS := iif(emptyany(m1PR_CONS,mDT_CONS), 0, m1PR_CONS)
      co->DT_CONS := iif(emptyany(m1PR_CONS,mDT_CONS), ctod(""), mDT_CONS)
      //
      if is_oncology == 2 // онкология
        G_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","SL")
        find (str(mkod,7))
        if found()
          G_RLock(forever)
        else
          AddRec(7)
          sl->kod := mkod
        endif
        sl->DS1_T := m1DS1_T
        sl->STAD := m1STAD
        sl->ONK_T := m1ONK_T
        sl->ONK_N := m1ONK_N
        sl->ONK_M := m1ONK_M
        sl->MTSTZ := m1MTSTZ
        sl->b_diag := m1b_diag
        sl->sod := 0
        sl->k_fr := iif(eq_any(m1usl_tip,3,4), val(mk_fr), 0)
        if is_onko_VMP .and. mtipvmp == 1 .and. musl2vmp == 3 // две услуги
          sl->k_fr := val(mk_fr)
        endif
        if eq_any(m1usl_tip,2,4)
          sl->crit := m1crit
        else
          sl->crit := ""
        endif
        if sl->k_fr == 0
          sl->crit2 := ""
        elseif (i := ascan(_arr_fr, {|x| between(sl->k_fr,x[3],x[4]) })) > 0
          sl->crit2 := _arr_fr[i,2]
        endif
        if eq_any(m1usl_tip,2,4)
          sl->is_err := iif(m1usl_tip == 2, m1is_err, 0)
          sl->WEI := iif(val(mWEI) < 1000, val(CHARREPL(",",mWEI,".")), 70 )
          sl->HEI := val(mHEI)
          sl->BSA := iif(val(mBSA) < 10, val(CHARREPL(",",mBSA,".")), 2)
        else
          sl->is_err := sl->WEI := sl->HEI := sl->BSA := 0
        endif
        if is_onko_VMP .and. mtipvmp == 1 .and. musl2vmp == 2 // две услуги
          sl->crit := m1crit
          sl->is_err := m1is_err
          sl->WEI := iif(val(mWEI) < 1000, val(CHARREPL(",",mWEI,".")), 70 )
          sl->HEI := val(mHEI)
          sl->BSA := iif(val(mBSA) < 10, val(CHARREPL(",",mBSA,".")), 2)
        endif
        //
        arr := {}
        G_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","DIAG") // Диагностический блок
        find (str(mkod,7))
        do while diag->kod == mkod .and. !eof()
          aadd(arr,recno())
          skip
        enddo
        i := 0
        use (cur_dir+"tmp_onkdi") new alias TDIAG
        go top
        do while !eof()
          select DIAG
          if ++i > len(arr)
            AddRec(7)
            diag->kod := mkod
          else
            goto (arr[i])
            G_RLock(forever)
          endif
          diag->DIAG_DATE := tdiag->DIAG_DATE
          diag->DIAG_TIP  := tdiag->DIAG_TIP
          diag->DIAG_CODE := tdiag->DIAG_CODE
          diag->DIAG_RSLT := tdiag->DIAG_RSLT
          diag->REC_RSLT  := tdiag->REC_RSLT
          select TDIAG
          skip
        enddo
        if is_gisto
          for j := 1 to len(arr_rez_gist)
            if !empty(arr_rez_gist[j,4])
              select DIAG
              if ++i > len(arr)
                AddRec(7)
                diag->kod := mkod
              else
                goto (arr[i])
                G_RLock(forever)
              endif
              diag->DIAG_DATE := mDIAG_DATE
              diag->DIAG_TIP  := 1
              diag->DIAG_CODE := arr_rez_gist[j,2]
              diag->DIAG_RSLT := arr_rez_gist[j,4]
              diag->REC_RSLT  := 1
            endif
          next
        endif
        select DIAG
        do while ++i <= len(arr)
          goto (arr[i])
          DeleteRec(.t.)
        enddo
        //
        arr := {}
        G_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","PR") // Сведения об имеющихся противопоказаниях
        find (str(mkod,7))
        do while pr->kod == mkod .and. !eof()
          aadd(arr,recno())
          skip
        enddo
        i := 0
        use (cur_dir+"tmp_onkpr") new alias TPR
        go top
        do while !eof()
          select PR
          if ++i > len(arr)
            AddRec(7)
            pr->kod := mkod
          else
            goto (arr[i])
            G_RLock(forever)
          endif
          pr->PROT := tpr->PROT
          pr->D_PROT := tpr->D_PROT
          select TPR
          skip
        enddo
        select PR
        do while ++i <= len(arr)
          goto (arr[i])
          DeleteRec(.t.)
        enddo
        arr := {}
        G_Use(dir_server+"mo_onkus",dir_server+"mo_onkus","US")
        find (str(mkod,7))
        do while us->kod == mkod .and. !eof()
          aadd(arr,recno())
          skip
        enddo
        i := 0
        use (cur_dir+"tmp_onkus") new alias TMPOU
        go top
        do while !eof()
          select US
          if ++i > len(arr)
            AddRec(7)
            us->kod := mkod
          else
            goto (arr[i])
            G_RLock(forever)
          endif
          us->USL_TIP   := tmpou->USL_TIP
          us->HIR_TIP   := tmpou->HIR_TIP
          us->LEK_TIP_V := tmpou->LEK_TIP_V
          us->LEK_TIP_L := tmpou->LEK_TIP_L
          us->LUCH_TIP  := tmpou->LUCH_TIP
          us->PPTR      := tmpou->PPTR
          sl->sod += tmpou->sod
          select TMPOU
          skip
        enddo
        select US
        do while ++i <= len(arr)
          goto (arr[i])
          DeleteRec(.t.)
        enddo
        //
        arr := {}
        G_Use(dir_server+"mo_onkle",dir_server+"mo_onkle","LE")
        find (str(mkod,7))
        do while le->kod == mkod .and. !eof()
          aadd(arr,recno())
          skip
        enddo
        i := 0
        if eq_any(m1usl_tip,2,4) .or. (is_onko_VMP .and. mtipvmp == 1 .and. musl2vmp == 2)
          use (cur_dir+"tmp_onkle") new alias TMPLE
          go top
          do while !eof()
            select LE
            if ++i > len(arr)
              AddRec(7)
              le->kod := mkod
            else
              goto (arr[i])
              G_RLock(forever)
            endif
            le->REGNUM   := tmple->REGNUM
            le->CODE_SH  := m1crit // tmple->CODE_SH
            le->DATE_INJ := tmple->DATE_INJ
            select TMPLE
            skip
          enddo
        endif
        select LE
        do while ++i <= len(arr)
          goto (arr[i])
          DeleteRec(.t.)
        enddo
      endif
    endif
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
    write_work_oper(glob_task,OPER_LIST,iif(Loc_kod==0,1,2),1,count_edit)
    fl_write_sluch := .t.
    close databases
    //
    if pp_OMS .and. mtip_h > B_END // приемный покой + лечение завершено
      G_Use(dir_server+"mo_pp",dir_server+"mo_pp_h","PP")
      find (str(mkod,7))
      if found()
        G_RLock(forever)
        if (MKOJKO_DNI := mk_data - mn_data) < 1
          MKOJKO_DNI := 1
        endif
        M1ISHOD1 := M1ISHOD2 := 1
        do case
          case eq_any(m1ishod,101,201,301)  // выздоровление
            M1ISHOD2 := 1
          case eq_any(m1ishod,102,202,303)  // улучшение
            M1ISHOD2 := 2
          case eq_any(m1ishod,103,203,302,304)  // без перемен
            M1ISHOD2 := 3
          case eq_any(m1ishod,104,204,305)  // ухудшение
            M1ISHOD2 := 4
        endcase
        do case
          case eq_any(m1rslt,102,202)  // Переведён в др. ЛПУ
            M1ISHOD1 := 4
          case eq_any(m1rslt,103,204)  // Переведён в дневной стационар
            M1ISHOD1 := 2
          case eq_any(m1rslt,104,203)  // Переведён в стационар
            M1ISHOD1 := 3
          case eq_any(m1rslt,105,106,205,206,313)  // смерть
            M1ISHOD2 := 6
        endcase
        pp->ISHOD1 := M1ISHOD1     // исход
        pp->ISHOD2 := M1ISHOD2     // исход
        if pp->IS_GOSPIT == 0 .and. empty(pp->G_DATA) // 0-госпитализирован и не заполнена дата госпитализации
          pp->G_DATA := MN_DATA      // дата госпитализации
          pp->G_TIME := pp->N_TIME   // время госпитализации
        endif
        // меняем дату окончания/продолжительность госпитализации
        pp->K_DATA    := MK_DATA      // дата окончания лечения
        pp->K_TIME    := "11:00"      // время выписки
        pp->KOJKO_DNI := MKOJKO_DNI   // продолжительность госпитализации
        pp->BOLNICH    := M1BOLNICH    // больничный (0-нет,1-да,2-по уходу)
        if m1bolnich > 0
          pp->DATE_B_1 := MDATE_B_1    // дата начала больничного
          pp->DATE_B_2 := MDATE_B_2    // дата окончания больничного
          if m1bolnich == 2
            pp->DATE_RODIT := mrodit_dr    // дата рождения родителя
            pp->POL_RODIT  := mrodit_pol   // пол родителя
          endif
        endif
      endif
      close databases
    endif
    stat_msg("Запись завершена!",.f.)
  endif
  exit
enddo
close databases
diag_screen(2)
setcolor(tmp_color)
restscreen(buf)
chm_help_code := tmp_help
if fl_write_sluch // если записали
  if eq_any(m1USL_OK,1,2)
    f_1pac_definition_KSG(mkod)
  endif
  if type("fl_edit_oper") == "L" // если находимся в режиме добавления случая
    fl_edit_oper := .t.  // проверку запустим при выходе из набивания услуг
  else // иначе запускаем проверку
    if (mcena_1 > 0 .or. is_smp(m1USL_OK,m1PROFIL)) .and. !empty(val(msmo))
      verify_OMS_sluch(glob_perso)
    endif
  endif
endif
return NIL

* разные функции для oms_sluch()

***** 10.02.17
Function get_fio_kart(k,r,c)
Local s := "", ret, buf, tmp_keys
Private fl_write_kartoteka := .f.
buf := savescreen()
tmp_keys := my_savekey()
edit_kartotek(mkod_k,r+1,,.t.,mkod)
my_restkey(tmp_keys)
if fl_write_kartoteka
  R_Use(dir_server+"kartote2",,"KART2")
  goto (mkod_k)
  R_Use(dir_server+"kartote_",,"KART_")
  goto (mkod_k)
  R_Use(dir_server+"kartotek",,"KART")
  goto (mkod_k)
  M1FIO := 1 ; mfio := kart->fio ; mpol := kart->pol ; mdate_r := kart->date_r
  mfio_kart := _f_fio_kart()
  if type("mn_data") == "D"
    if type("m1novor") == "N" .and. type("mdate_r2") == "D" .and. m1novor > 0
      mvozrast := count_years(mdate_r2,mn_data)
    else
      mvozrast := count_years(mdate_r,mn_data)
    endif
  endif
  if type("m1novor") == "N" .and. m1novor > 0
    M1VZROS_REB := 1 // ребенок
  else
    M1VZROS_REB := kart->VZROS_REB
  endif
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
  mokato      := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
  mkomu       := inieditspr(A__MENUVERT, mm_komu, m1komu)
  mvidpolis   := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  if !empty(mn_data)
    fv_date_r(mn_data,.f.)
  endif
  f_valid_komu(,-1)
  m1company   := int(val(msmo))
  mcompany    := inieditspr(A__MENUVERT, mm_company, m1company)
  if m1company == 34
    mnameismo := ret_inogSMO_name(1,,.t.) // открыть и закрыть
  elseif !(left(msmo,2) == '34')
    m1ismo := msmo ; msmo := '34' ; m1company := 34
    mismo := init_ismo(m1ismo)
  endif
  if m1company == 34
    if !empty(mismo)
      mcompany := mismo
    elseif !empty(mnameismo)
      mcompany := mnameismo
    endif
  endif
  if !empty(mcompany)
    old_name_smo := padr(mcompany,38)
  endif
  if m1komu > 0
    m1company := 0 ; mcompany := ""
    if eq_any(m1komu,1,3)
      m1company := m1str_crb := kart->STR_CRB
      mcompany := inieditspr(A__MENUVERT, mm_company, m1company)
    endif
  endif
  mcompany := padr(mcompany,38)
  if eq_any(is_uchastok,1,3)
    s := amb_kartaN()
  elseif mem_kodkrt == 2
    s := lstr(mkod_k)
  endif
  if !empty(s) .and. valtype(MUCH_DOC) == "C"
    if empty(MUCH_DOC)
      MUCH_DOC := padr(s,10)
    elseif is_uchastok == 3 .and. !(MUCH_DOC == padr(s,10))
      MUCH_DOC := padr(s,10)
    endif
  endif
  close databases
endif
restscreen(buf)
return ret

***** 24.02.16
Function _f_fio_kart()
return padr(alltrim(mfio)+" "+iif(mpol=="М","(муж.)","(жен.)"),50)

***** проверка правильности ввода стоматологического статуса больного
Function f_valid_status_st(get)
Local i, s := "", fl := .t.
for i := 1 to len(mstatus_st)
  if !empty(c := substr(mstatus_st,i,1)) .and. !(c $ yes_d_plus)
    s += c
  endif
next
if !empty(s)
  fl := func_error(4,'Следующие символы не разрешены для ввода в данном поле: "'+s+'"')
endif
return fl

***** действия в ответ на выбор в меню "Новорожденный? (да/нет)"
Function f_valid_novor(get,old)
if m1novor != old .and. old != NIL
  if old == 0 // было "нет" - стало "да"
    mcount_reb := 1 ; mDATE_R2 := sys_date-5 ; mpol2 := "М"
  else
    mcount_reb := 0 ; mDATE_R2 := ctod("") ; mpol2 := " "
  endif
  update_get("mcount_reb")
  update_get("mDATE_R2")
  update_get("mpol2")
endif
fv_date_r(mn_data)
return .t.

***** действия в ответ на выбор в меню "Принадлежность счёта"
Function f_valid_komu(get,old)
Local tmp_select := select()
if m1komu != old .and. old != NIL
  m1company := 0 ; mcompany := space(30) ; mm_company := {}
  if m1komu == 0 // ОМС
    mm_company := aclone(glob_arr_smo)
  elseif m1komu == 1 // Прочие компании
    R_Use(dir_server+"str_komp")
    index on upper(name) to (cur_dir+"tmp_comp") for !between(tfoms,44,47)
    dbeval({|| aadd(mm_company,{alltrim(name),kod}) } )
    Use
  elseif m1komu == 3 // Комитеты/МО
    R_Use(dir_server+"komitet")
    index on upper(name) to (cur_dir+"tmp_comp")
    dbeval({|| aadd(mm_company,{alltrim(name),kod}) } )
    Use
  endif
  if eq_any(m1komu,1,3) .and. empty(mm_company)
    mm_company := {{"Пустой справочник",0}}
  endif
  update_get("mcompany")
endif
select (tmp_select)
return .t.

***** 20.02.20 действия в ответ на выбор в меню "Условия оказания медицинской помощи"
Function f_valid_usl_ok(get,old,is_input)
Local _y, _m, s
DEFAULT is_input TO .t.
if m1usl_ok != old .and. m1usl_ok > 0 .and. old != NIL
  mm_rslt := {}
  if m1usl_ok == 3 .and. is_input // поликлиника - убираем диспансеризацию
    aeval(tmp_V009,{|x| iif(x[5]==m1usl_ok.and.x[2]<316, aadd(mm_rslt,x), nil) })
  else
    aeval(tmp_V009,{|x| iif(x[5]==m1usl_ok, aadd(mm_rslt,x), nil) })
  endif
  mm_ishod := {}
  aeval(tmp_V012,{|x| iif(x[5]==m1usl_ok, aadd(mm_ishod,x), nil) })
  if get != NIL
    m1rslt := 0 ; mrslt := ""
    if ascan(mm_rslt, {|x| x[2] == rslt_umolch}) > 0
      m1rslt := rslt_umolch
      mrslt := inieditspr(A__MENUVERT, tmp_V009, m1rslt)
    endif
    m1ishod := 0 ; mishod := ""
    if ascan(mm_ishod, {|x| x[2] == ishod_umolch}) > 0
      m1ishod := ishod_umolch
      mishod := inieditspr(A__MENUVERT, tmp_V012, m1ishod)
    endif
    mrslt  := padr(mrslt ,60)
    mishod := padr(mishod,60)
    update_get("mrslt")
    update_get("mishod")
  endif
endif
if is_input .and. type("p_nstr_vnr") == "N"
  s := "" ; input_vnr := input_vnrm := .f.
  if m1usl_ok == 1 // стационар
    count_ymd(iif(M1NOVOR==1,mdate_r2,mdate_r),mn_data,@_y,@_m,)
    //if _y == 0 .and. _m < 7 // ребёнок не старше 6 месяцев
    if _y == 0 // ребёнок до года
      s := p_str_vnr ; input_vnr := .t.
    else
      MVNR := space(4)
    endif
    if mpol == "Ж" .and. _y > 10 // "мамаша" старше 10 лет
      s := p_str_vnrm ; input_vnrm := .t.
    else
      MVNR1 := MVNR2 := MVNR3 := space(4)
    endif
  else // другие условия оказания мед.помощи
    MVNR := MVNR1 := MVNR2 := MVNR3 := space(4)
  endif
  @ p_nstr_vnr,1 say padr(s,maxcol()) color cDataCGet
  if input_vnr
    update_get("MVNR")
  elseif input_vnrm
    update_get("MVNR1")
    update_get("MVNR2")
    update_get("MVNR3")
  endif
  if !((m1usl_ok==1 .and. (is_ksg_VMP .or. is_12_VMP .or. is_14_VMP)) .or. (m1usl_ok==2 .and. is_ds_VMP))
    mvmp := "нет"        ; m1vmp := 0
    MVIDVMP := space(70) ; M1VIDVMP := SPACE(12) // вид ВМП по справочнику V018
    MMETVMP := space(67) ; M1METVMP := 0        // метод ВМП по справочнику V019
    update_get("MVIDVMP")
    update_get("MMETVMP")
  endif
endif
return .t.

***** действия в ответ на выбор в меню "Результат"
Function f_valid_rslt(g,o)
if is_death(m1RSLT)
else
endif
return .t.

***** действия в ответ на выбор в меню "Госпитализация"
Static Function f_valid_f14_ekst(get,old)
if M1F14_EKST != old .and. old != NIL
endif
return .t.

***** 23.01.18 действия в ответ на выбор в меню "ВМП"
Function f_valid_vmp(get,old)
if m1vmp != old .and. old != NIL
  if m1vmp == 0
    mTAL_D := mTAL_P := ctod("")
    MVIDVMP := space(70) ; M1VIDVMP := SPACE(12) // вид ВМП по справочнику V018
    MMETVMP := space(67) ; M1METVMP := 0        // метод ВМП по справочнику V019
  else
    input_ad_cr := .f. ; mad_cr := space(66) ; m1ad_cr := space(10)
  endif
  update_get("mTAL_D")
  update_get("mTAL_P")
  update_get("MVIDVMP")
  update_get("MMETVMP")
endif
return .t.

***** 17.01.14 действия в ответ на выбор в меню "Вид ВМП"
Function f_valid_vidvmp(get,old)
if empty(m1vidvmp)
  MMETVMP := space(67) ; M1METVMP := 0
  update_get("MMETVMP")
elseif !(m1vidvmp == old) .and. old != NIL .and. get != NIL
  MMETVMP := space(67) ; M1METVMP := 0
  update_get("MMETVMP")
endif
return .t.

***** действия в ответ на выбор в меню "Больничный"
Function f_valid_bolnich(get,old)
if m1bolnich != old .and. old != NIL
  if m1bolnich == 0
    MDATE_B_1 := ctod("")
    MDATE_B_2 := ctod("")
  endif
  if m1bolnich != 2
    mrodit_dr  := ctod("")
    mrodit_pol := " "
  endif
  if m1bolnich > 0
    MDATE_B_1 := mn_data
    MDATE_B_2 := mk_data
    if m1bolnich == 2                         // по умолчанию больничный выдали
      mrodit_dr  := addmonth(sys_date,-25*12) // 25 летней
      mrodit_pol := "Ж"                       // матери
    endif
  endif
  update_get("MDATE_B_1")
  update_get("MDATE_B_2")
  update_get("mrodit_dr")
  update_get("mrodit_pol")
endif
return .t.

***** проверка введённого цифрами повода обращения
Function val_st_pov(get)
Local i, fl := .t.
if (i := ascan(stm_povod, {|x| x[2] == m1povod } )) > 0
  mpovod := padr(stm_povod[i,1],23) ; update_get("mpovod")
else
  fl := func_error(4,"Недопустимый шифр повода обращения")
  m1povod := get:original
endif
return fl

***** проверка введённого цифрами вида травмы
Function val_st_trav(get)
Local i, fl := .t.
if (i := ascan(stm_travma, {|x| x[2] == m1travma } )) > 0
  mtravma := padr(stm_travma[i,1],34) ; update_get("mtravma")
else
  fl := func_error(4,"Недопустимый шифр вида травмы")
  m1travma := get:original
endif
return fl

***** 11.08.20
Function inp_dop_diag()
Local arr, jt, mshifr, tmp_keys, tmp_gets, buf, tmp_color
Private mvar := upper(readvar())
if empty(mvar) .or. !(type(mvar) == "C")
  return .t.
endif
mshifr := &mvar
arr := {"MKOD_DIAG" ,;
        "MKOD_DIAG2",;
        "MKOD_DIAG3",;
        "MKOD_DIAG4",;
        "MSOPUT_B1" ,;
        "MSOPUT_B2" ,;
        "MSOPUT_B3" ,;
        "MSOPUT_B4"}
if !empty(mshifr) .and. (jt := ascan(arr,mvar)) > 0
  tmp_keys := my_savekey()
  save gets to tmp_gets
  buf := savescreen()
  change_attr()
  Private pr := 9, m1, m2
  m1 := adiag_talon[jt*2-1]
  m2 := adiag_talon[jt*2  ]
  box_shadow(pr,2,pr+4,77,color0,'Диагноз "'+alltrim(mshifr)+'"',"W+/BG")
  tmp_color := setcolor("N/BG,W+/N,,,B/BG")
  @ pr+1,5 say "Характер заболевания (1,2) " get m1 pict "9" valid {|g| v_i_d_diag(g,1) }
  @ pr+2,5 say "Диспансерный учет  (1,2,3) " get m2 pict "9" valid {|g| v_i_d_diag(g,2) }
  status_key("^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода")
  myread()
  if lastkey() != K_ESC
    adiag_talon[jt*2-1] := m1
    adiag_talon[jt*2  ] := m2
  endif
  keyboard chr(K_ENTER)
  restscreen(buf)
  restore gets from tmp_gets
  my_restkey(tmp_keys)
  setcolor(tmp_color)
  setcursor()
  put_dop_diag()
endif
return .t.

*****
Static Function v_i_d_diag(get,par)
Local fl := .t., mval, s := ""
Private mvar := upper(readvar())
mval := &mvar
if mval > 0
  do case
    case par == 1
      if (fl := between(m1,1,2))
        s := {"Выявлено впервые в жизни (или острое)",;
              "Ранее зарегистрированное заболевание"}[m1]
      endif
    case par == 2
      if (fl := between(m2,1,3))
        s := {"Состоит",;
              "Взят",;
              "Снят"}[m2]
      endif
  endcase
endif
@ pr+par,35 say padr(s,42) color "G+/BG"
if !fl
  &mvar := get:original
  mybell()
endif
return fl

*****
Function func_valid_ismo(get,lkomu,sh,name_var)
Local r1, r2, n := 4, buf, tmp_keys, tmp_list, tmp_color
DEFAULT name_var TO "company"
Private mvar := "m1"+name_var
if lkomu == 0 .and. &mvar == 34
  if get:row() > 18
    r2 := get:row()-1 ; r1 := r2-n
  else
    r1 := get:row()+1 ; r2 := r1+n
  endif
  buf := savescreen()
  change_attr()
  tmp_keys := my_savekey()
  save gets to tmp_list
  Private mm_ismo := {}
  box_shadow(r1,2,r2,77,"N+/W","Ввод иногородней СМО","GR/W")
  tmp_color := setcolor("N/W,W+/N,,,B/W")
  @ r1+1,4 say "Субъект РФ" get mokato ;
            reader {|x| menu_reader(x,;
                  {{|k,r,c| get_srf(k,r,c) },62},A__FUNCTION,,,.f.)} ;
            valid {|g,o| when_ismo(g,o) }
  @ r1+2,4 say "СМО" get mismo ;
           reader {|x|menu_reader(x,mm_ismo,A__MENUVERT,,,.f.)} ;
           when {|| len(mm_ismo) > 0 .and. empty(mnameismo) } ;
           valid {|| iif(empty(mismo),,mnameismo:=space(100)), .t. }
  @ r1+3,4 say "Наименование СМО" get mnameismo pict "@S56" ;
           when empty(m1ismo)
  myread()
  setcolor(tmp_color)
  restore gets from tmp_list
  my_restkey(tmp_keys)
  restscreen(buf)
  if !emptyall(mismo,mnameismo)
    mvar := "m"+name_var
    &mvar := padr(iif(emptyall(mismo),mnameismo,mismo),sh)
  endif
endif
return .t.

*****
Static Function get_srf(k,r,c)
Local ret, t_arr[BR_LEN], fl := .f.
Private muslovie := ".t.", str_find := ""
if r <= maxrow()/2
  t_arr[BR_TOP] := r
  t_arr[BR_BOTTOM] := maxrow()-2
else
  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := r-1
endif
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "Выбор субъекта РФ (территории страхования)"
t_arr[BR_TITUL_COLOR] := "BG+/GR"
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.f.,72}
t_arr[BR_COLUMN] := {{"ОКАТО", {|| tmp->okato }},;
                     { center("Наименование",66),{|| left(tmp->name,66)} }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке") }
t_arr[BR_EDIT] := {|nk,ob| f2_srf(nk,ob) }
t_arr[BR_ENTER] := {|| ret := {tmp->okato,tmp->name} }
//
use (cur_dir+"tmp_srf") new alias TMP
set filter to !(okato=='18000')
if !empty(k)
  Locate for okato==k
  if !found()
    go top
  endif
endif
edit_browse(t_arr)
tmp->(dbCloseArea())
return ret

*****
Static Function f2_srf(nk,ob)
Static stmp1 := ""
Local rec1 := recno(), buf := savescreen(), tmp_color, ret := -1,;
      r1 := pr2-6, r2 := pr2-1, i, j, lf, s, rec
if nk == K_F2
  box_shadow(r1,pc1+1,r2,pc2-1,cDataPgDn,"Поиск по ключу",cDataCSay)
  tmp_color := setcolor(cDataCGet)
  @ r1+2,pc1+2 say center("Введите ключевое слово",pc2-pc1-3)
  setcolor(cDataCGet)
  tmp := padr(stmp1,pc2-pc1-3)
  status_key("^<Esc>^ - отказ от ввода")
  @ r1+3,pc1+2 get tmp picture "@K@!"
  myread()
  setcolor(color0)
  if lastkey() == K_ESC .or. empty(tmp)
    goto (rec1)
  else
    tmp := alltrim(tmp)
    stmp1 := tmp
    Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := pr1+3, k2 := pr2-1
    ob:goTop()
    do while !eof()
      if tmp $ upper(tmp->name)
        aadd(tmp_mas, tmp->name)
        aadd(tmp_kod, recno())
      endif
      skip
    enddo
    if (t_len := len(tmp_kod)) == 0
      func_error(3,"Неудачный поиск!")
      goto (rec1)
    else
      box_shadow(pr1,pc1,pr2,pc2)
      SETCOLOR("B/BG")
      @ pr1+1,pc1+2 say "Ключ: "+tmp
      SETCOLOR(color0)
      if t_len < pr2-pr1-5
        k2 := k1 + t_len + 2
      endif
      @ k1,pc1+1 say padc("Найденное количество - "+lstr(t_len),pc2-pc1-1)
      status_key("^<Esc>^ - отказ от выбора")
      if (i := popup(k1+1,pc1+1,k2,pc2-1,tmp_mas,1,0)) > 0
        ob:goTop()
        goto (tmp_kod[i])
        ret := 0
      endif
    endif
  endif
endif
return ret

*****
Static Function when_ismo(get,old)
Local s
if !(m1okato == old) .and. old != NIL
  m1ismo := "" ; mismo := space(len(mismo))
endif
mm_ismo := {}
if !empty(m1okato)
  R_Use(exe_dir+"_mo_smo",cur_dir+"_mo_smo","SMO")
  find (m1okato)
  do while smo->okato == m1okato .and. !eof()
    s := alltrim(smo->name)
    if !empty(smo->d_end)
      s += " (до "+full_date(smo->d_end)+")"
    endif
    aadd(mm_ismo, {s,smo->smo})
    skip
  enddo
  smo->(dbCloseArea())
endif
return len(mm_ismo) > 0

***** 13.10.20 ввод услуг в случай (лист учёта)
Function oms_usl_sluch(mkod_human,mkod_kartotek,fl_edit)
// mkod_human - код по БД human
// mkod_kartotek - код по БД kartotek
Local adbf, buf := savescreen(), i, j := 0, tmp_color := setcolor(color1), rec_ksg := 0,;
      lshifr := "", l_color, tmp_help, mtitle, d1, d2, cd1, cd2, fl_oms, fl, kol_rec, old_is_zf_stomat
DEFAULT fl_edit TO .t.
//
Private fl_edit_usl := fl_edit
Private fl_found, last_date, mvu[3,2], pr1otd, pr_amb_reab := .f.,;
        pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}, is_1_vvod,;
        kod_lech_vr := 0, is_open_u1 := .f., arr_uva := {}, arr_usl1year, u_other := {}
afillall(mvu,0)
//
Private tmp_V002 := create_classif_FFOMS(0,"V002") // PROFIL
//
mywait()
R_Use(dir_server+"usl_uva",,"OU")
dbeval({|| aadd(arr_uva, {alltrim(ou->shifr),ou->kod_vr,ou->kod_as} ) } )
ou->(dbCloseArea())
use_base("lusl")
use_base("luslc")
use_base("luslf")
Use_base("mo_su")
set order to 0
G_Use(dir_server+"uslugi",{dir_server+"uslugish",;
                           dir_server+"uslugi"},"USL")
set order to 0
Use_base("mo_hu")
Use_base("human_u")
G_Use(dir_server+"human_2",,"HUMAN_2")
G_Use(dir_server+"human_",,"HUMAN_")
G_Use(dir_server+"human",{dir_server+"humank",;
                          dir_server+"humankk",;
                          dir_server+"humano"},"HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2
find (str(mkod_human,7))
arr_usl1year := f_arr_usl1()
glob_kartotek := human->kod_k
d1 := human->n_data ; d2 := human->k_data
cd1 := dtoc4(d1) ; cd2 := dtoc4(d2)
last_date := human->n_data
Private m1USL_OK := human_->USL_OK
Private m1PROFIL := human_->PROFIL
Private mdiagnoz := diag_to_array(,,,,.t.)
if len(mdiagnoz) == 0
  mdiagnoz := {space(6)}
endif
Private human_kod_diag := mdiagnoz[1]
//
make_arr_uch_otd(human->n_data,human->LPU)
uch->(dbGoto(human->LPU))
otd->(dbGoto(human->OTD))
f_put_glob_podr(human_->USL_OK,d2) // заполнить код подразделения
// просмотр других случаев данного больного
select HUMAN
set order to 2
find (str(glob_kartotek,7))
do while human->kod_k == glob_kartotek .and. !eof()
  fl := (mkod_human != human->kod)
  if fl .and. human->schet > 0 .and. eq_any(human_->oplata,2,9)
    fl := .f. // лист учёта снят по акту и выставлен повторно
  endif
  // если диапазон лечения частично перекрывается
  if fl .and. human->n_data <= d2 .and. d1 <= human->k_data
    select HU
    find (str(human->kod,7))
    do while hu->kod == human->kod .and. !eof()
      if between(hu->date_u,cd1,cd2) // услуга в том же диапазоне лечения
        aadd(u_other, {hu->u_kod,hu->date_u,hu->kol_1,hu_->profil,0})
      endif
      skip
    enddo
    select MOHU
    find (str(human->kod,7))
    do while mohu->kod == human->kod .and. !eof()
      if between(mohu->date_u,cd1,cd2) // услуга в том же диапазоне лечения
        aadd(u_other, {mohu->u_kod,mohu->date_u,mohu->kol_1,mohu->profil,1})
      endif
      skip
    enddo
  endif
  select HUMAN
  skip
enddo
//
adbf := {;
  {"KOD"      ,   "N",     7,     0},; // код больного
  {"DATE_U"   ,   "C",     4,     0},; // дата оказания услуги
  {"date_u2"  ,   "C",     4,     0},; // дата окончания оказания услуги
  {"date_u1"  ,   "D",     8,     0},;
  {"date_next",   "D",     8,     0},; // дата след.визита для дисп.наблюдения
  {"shifr_u"  ,   "C",    20,     0},;
  {"shifr1"   ,   "C",    20,     0},;
  {"name_u"   ,   "C",    65,     0},;
  {"U_KOD"    ,   "N",     6,     0},; // код услуги
  {"U_CENA"   ,   "N",    10,     2},; // цена услуги
  {"dom"      ,   "N",     2,     0},; // -1 - на дому
  {"KOD_VR"   ,   "N",     4,     0},; // код врача
  {"KOD_AS"   ,   "N",     4,     0},; // код ассистента
  {"OTD"      ,   "N",     3,     0},; // код отделения
  {"KOL_1"    ,   "N",     3,     0},; // оплачиваемое количество услуг
  {"STOIM_1"  ,   "N",    10,     2},; // оплачиваемая стоимость услуги
  {"ZF"       ,   "C",    30,     0},; // зубная формула или парные органы
  {"PAR_ORG"  ,   "C",    40,     0},; // разрешённые парные органы
  {"ID_U"     ,   "C",    36,     0},; // код записи об оказанной услуге;GUID оказанной услуги;создается при добавлении записи
  {"PROFIL"   ,   "N",     3,     0},; // профиль;по справочнику V002
  {"PRVS"     ,   "N",     9,     0},; // Специальность врача;по справочнику V004;
  {"kod_diag" ,   "C",     6,     0},; // диагноз;перенести из основного диагноза
  {"n_base"   ,   "N",     1,     0},; // номер справочника услуг 0-старый,1-новый
  {"is_nul"   ,   "L",     1,     0},;
  {"is_oms"   ,   "L",     1,     0},;
  {"is_zf"    ,   "N",     1,     0},;
  {"is_edit"  ,   "N",     2,     0},;
  {"number"   ,   "N",     3,     0},;
  {"rec_hu"   ,   "N",     8,     0}}
dbcreate(cur_dir+"tmp_usl_",adbf)
use (cur_dir+"tmp_usl_") new alias TMP
select HUMAN
set order to 1
find (str(mkod_human,7))
select HU
set relation to u_kod into USL additive
find (str(mkod_human,7))
if found()
  do while hu->kod == mkod_human .and. !eof()
    select TMP
    append blank
    tmp->KOD     := hu->kod
    tmp->DATE_U  := hu->date_u
    tmp->date_u2 := hu_->date_u2
    tmp->date_u1 := c4tod(hu->date_u)
    tmp->shifr_u := usl->shifr
    tmp->shifr1  := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    if empty(lshifr := tmp->shifr1)
      lshifr := tmp->shifr_u
    endif
    if human_->usl_ok == 3
      if is_usluga_disp_nabl(lshifr)
        tmp->DATE_NEXT := c4tod(human->DATE_OPL)
      elseif left(lshifr,5) == "2.89."
        pr_amb_reab := .t.
      endif
    endif
    tmp->name_u  := usl->name
    tmp->U_KOD   := hu->u_kod
    tmp->U_CENA  := hu->u_cena
    tmp->KOD_VR  := hu->kod_vr
    tmp->dom     := hu->KOL_RCP
    tmp->KOD_AS  := hu->kod_as
    tmp->OTD     := hu->otd
    tmp->KOL_1   := hu->kol_1
    tmp->STOIM_1 := hu->stoim_1
    tmp->ZF      := hu_->ZF
    tmp->ID_U    := hu_->ID_U
    tmp->PROFIL  := hu_->PROFIL
    tmp->PRVS    := hu_->PRVS
    tmp->kod_diag:= hu_->kod_diag
    tmp->n_base  := 0
    tmp->is_edit := hu->is_edit
    tmp->is_nul  := usl->is_nul
    tmp->rec_hu  := hu->(recno())
    last_date := max(tmp->date_u1,last_date)
    if human_->usl_ok < 3 .and. is_ksg(lshifr) // для КСГ цену не переопределяем - сделаем попозже
      rec_ksg := tmp->(recno())
    else
      fl_oms := .f.
      // переопределение цены
      if (v := f1cena_oms(tmp->shifr_u,;
                          tmp->shifr1,;
                          (human->vzros_reb==0),;
                          human->k_data,;
                          tmp->is_nul,;
                          @fl_oms)) != NIL
        tmp->is_oms := fl_oms
        if !(round(tmp->u_cena,2) == round(v,2))
          tmp->u_cena := v
          tmp->stoim_1 := round_5(tmp->u_cena * tmp->kol_1, 2)
          select HU
          G_RLock(forever)
          hu->u_cena := tmp->u_cena
          hu->stoim  := hu->stoim_1 := tmp->stoim_1
          UNLOCK
        endif
      endif
    endif
    select HU
    skip
  enddo
  commit
endif
select MOHU
set relation to u_kod into MOSU
find (str(mkod_human,7))
if found()
  do while mohu->kod == mkod_human .and. !eof()
    select TMP
    append blank
    tmp->KOD     := mohu->kod
    tmp->DATE_U  := mohu->date_u
    tmp->date_u2 := mohu->date_u2
    tmp->date_u1 := c4tod(mohu->date_u)
    tmp->shifr_u := iif(empty(mosu->shifr),mosu->shifr1,mosu->shifr)
    tmp->shifr1  := mosu->shifr1
    tmp->name_u  := mosu->name
    tmp->U_KOD   := mohu->u_kod
    tmp->U_CENA  := mohu->u_cena
    tmp->KOD_VR  := mohu->kod_vr
    tmp->KOD_AS  := mohu->kod_as
    tmp->OTD     := mohu->otd
    tmp->KOL_1   := mohu->kol_1
    tmp->STOIM_1 := mohu->stoim_1
    tmp->ZF      := mohu->ZF
    tmp->ID_U    := mohu->ID_U
    tmp->PROFIL  := mohu->PROFIL
    tmp->PRVS    := mohu->PRVS
    tmp->kod_diag:= mohu->kod_diag
    tmp->n_base  := 1
    tmp->is_nul  := .t.
    tmp->is_oms  := .t.
    tmp->is_zf   := ret_is_zf(tmp->shifr1)
    tmp->rec_hu  := mohu->(recno())
    tmp->par_org := ret_par_org(tmp->shifr1,d2)
    if is_telemedicina(tmp->shifr1)
      tmp->is_edit := -1 // не заполняется код врача
    endif
    last_date := max(tmp->date_u1,last_date)
    select MOHU
    skip
  enddo
  commit
endif
select TMP
fl_found := (tmp->(lastrec()) > 0)
is_1_vvod := (tmp->(lastrec()) == 0 .and. mem_ordu_1 == 1)
if !is_1_vvod
  if mem_ordusl == 1
    index on dtos(date_u1)+fsort_usl(shifr_u) to (cur_dir+"tmp_usl_")
  else
    index on fsort_usl(shifr_u)+dtos(date_u1) to (cur_dir+"tmp_usl_")
  endif
endif
summa_usl(.f.)
//
old_is_zf_stomat := is_zf_stomat
select HU
set relation to  // "отвязываем" human_u_
select USL
set order to 1
is_zf_stomat := 0
if STisZF(m1USL_OK,m1PROFIL)
  is_zf_stomat := 1
endif
if is_zf_stomat == 1
  Use_base("kartdelz")
endif
R_Use(dir_server+"usl_otd",dir_server+"usl_otd","UO")
R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
select TMP
set relation to otd into OTD
go top
i := tmp->(lastrec())
if i == 0
  if mem_coplec == 2
    kod_lech_vr := human_->vrach
  endif
elseif rec_ksg > 0
  aksg := f_usl_definition_KSG(human->kod)
  if mem_coplec == 2 .and. i == 1
    kod_lech_vr := human_->vrach
  endif
endif
cls
pr_1_str("Услуги для < "+fio_plus_novor()+" >")
if yes_num_lu == 1
  @ 1,50 say padl("Лист учета № "+lstr(human->kod),29) color color14
endif
l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"
s := "Полное наименование услуги"
if is_zf_stomat == 1
  s := "Формула зуба / "+s
endif
@ maxrow()-3,0 say "╒"+padc(s,66,"═")+                                                "╤══ Цена ═══╕"
@ maxrow()-2,0 say "│                                                                  │           │"
@ maxrow()-1,0 say "╘══════════════════════════════════════════════════════════════════╧═══════════╛"
if fl_found
  keyboard chr(K_RIGHT)
else
  keyboard chr(K_INS)
endif
setcolor(color1)
tmp_help := chm_help_code
chm_help_code := 3003
mtitle := f_srok_lech(human->n_data,human->k_data,human_->usl_ok)
Alpha_Browse(2,0,maxrow()-5,79,"f_oms_usl_sluch",color1,mtitle,col_tit_popup,;
             .f.,.t.,,"f1oms_usl_sluch","f2oms_usl_sluch",,;
             {"═","░","═",l_color,.t.,180} )
select TMP
pack
kol_rec := lastrec()
Private mcena_1 := human->cena_1, msmo := human_->smo
if yes_parol .and. (mvu[1,1] > 0 .or. mvu[2,1] > 0 .or. mvu[3,1] > 0) ;
             .and. hb_FileExists(dir_server+"mo_opern"+sdbf)
  close databases
  if G_Use(dir_server+"mo_opern",dir_server+"mo_opern","OP")
    for i := 1 to 3
      if mvu[i,1] > 0
        write_work_oper(glob_task,OPER_USL,i,mvu[i,1],mvu[i,2],.f.)
      endif
    next
  endif
endif
close databases
setcolor(tmp_color)
if kol_rec == 0
  n_message({"Не введено ни одной услуги"},,"GR+/R","W+/R",,,"G+/R")
endif
restscreen(buf)
chm_help_code := tmp_help
// запускаем проверку
if (mcena_1 > 0 .or. is_smp(m1USL_OK,m1PROFIL)) .and. !empty(val(msmo))
  verify_OMS_sluch(mkod_human)
endif
is_zf_stomat := old_is_zf_stomat
return NIL

***** 20.12.18
Function f_oms_usl_sluch(oBrow)
Local oColumn, blk_color
oColumn := TBColumnNew(" NN; пп",{|| tmp->number })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
if mem_ordusl == 1
  oColumn := TBColumnNew("Дата; усл.",{|| left(dtoc(tmp->date_u1),5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew(" Шифр услуги",{|| iif(tmp->dom==-1,padr(tmp->shifr_u,11)+"дом",;
                                           iif(tmp->dom==-2,padr(tmp->shifr_u,11)+"д-А",;
                                           padr(tmp->shifr_u,14))) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
if mem_ordusl == 2
  oColumn := TBColumnNew("Дата; усл.",{|| left(dtoc(tmp->date_u1),5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew("Отде-;ление",{|| otd->short_name })
oColumn:defColor := {6,6}
oColumn:colorBlock := {|| {6,6} }
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("МКБ10",{|| tmp->kod_diag })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Профиль услуги",{|| padr(inieditspr(A__MENUVERT,glob_V002,tmp->PROFIL),15) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Врач",{|| put_val(ret_tabn(tmp->kod_vr),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Асс.",{|| put_val(ret_tabn(tmp->kod_as),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол;усл",{|| str(tmp->kol_1,3) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Общая; ст-ть",{|| put_kop(tmp->stoim_1,8) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
status_key("^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление; ^<F1>^ помощь")
return NIL

***** 20.12.18
Function f1oms_usl_sluch()
LOCAL nRow := ROW(), nCol := COL(), s := tmp->name_u, lcolor := cDataCSay
if is_zf_stomat == 1 .and. !empty(tmp->zf)
  s := alltrim(tmp->zf)+" / "+s
  lcolor := color8
endif
@ maxrow()-2,2 say padr(s,65) color lcolor
if empty(tmp->u_cena)
  s := iif(tmp->n_base==0, "", "ФФОМС")
else
  s := alltrim(dellastnul(tmp->u_cena,10,2))
endif
@ maxrow()-2,68 say padc(s,11) color cDataCSay
f3oms_usl_sluch()
@ nRow, nCol SAY ""
return NIL

*****
Function f3oms_usl_sluch()
@ maxrow()-4,59 say padl("Итого: "+lstr(human->cena_1,11,2),20) color "W+/N"
return NIL

***** 13.10.20 ввод услуг в лист учёта
Function f2oms_usl_sluch(nKey,oBrow)
Static skod_k := 0, skod_human := 0, SKOD_DIAG, SZF,;
       st_vzrosl, st_arr_dbf, skod_vr, skod_as, aksg := {}
LOCAL flag := -1, buf := savescreen(), fl := .f., rec, max_date, new_date,;
      i1, k, i, j := 0, s := 0, so := 0, adbf, adbf1, tmp_color := setcolor(), ;
      rec_tmp := tmp->(recno()), arr_u, arr_dni, st_arr_dbf_s,;
      date_tmp := tmp->date_u1, ta, lvid_mp, lerr_mp, v,;
      uch_otd := saveuchotd(), in_array, out_array, pic_diag := "@K@!",;
      k_read := 0, count_edit := 0, bg := {|o,k| get_MKB10(o,k,.t.) }
Local mm_dom := {{"в поликлинике", 0},;
                 {"на дому      ",-1}}
if mem_dom_aktiv == 1
     aadd(mm_dom,{"на дому-АКТИВ",-2})
endif
Private r1 := 10, mrec_hu := tmp->rec_hu
do case
  case nKey == K_F9 .and. !empty(aksg)
    f_put_arr_ksg(aksg)
  case nKey == K_F10 .and. tmp->kod > 0 .and. f_Esc_Enter("запоминания услуг")
    mywait()
    st_vzrosl := (human->vzros_reb==0)
    st_arr_dbf := {}
    select TMP
    adbf1 := array(_HU_LEN)
    go top
    do while !eof()
      adbf1[_HU_DATE_U1 ] := tmp->date_u1
      adbf1[_HU_U_KOD   ] := tmp->U_KOD
      adbf1[_HU_U_CENA  ] := tmp->U_CENA
      adbf1[_HU_SHIFR_U ] := tmp->shifr_u
      adbf1[_HU_SHIFR1  ] := tmp->shifr1
      adbf1[_HU_NAME_U  ] := tmp->name_u
      adbf1[_HU_IS_NUL  ] := tmp->is_nul
      adbf1[_HU_IS_EDIT ] := tmp->is_edit
      adbf1[_HU_IS_OMS  ] := tmp->is_oms
      adbf1[_HU_KOL_RCP ] := tmp->dom
      adbf1[_HU_KOD_VR  ] := tmp->KOD_VR
      adbf1[_HU_KOD_AS  ] := tmp->KOD_AS
      adbf1[_HU_OTD     ] := tmp->OTD
      adbf1[_HU_KOL_1   ] := tmp->KOL_1
      adbf1[_HU_STOIM_1 ] := tmp->STOIM_1
      adbf1[_HU_KOD_DIAG] := tmp->kod_diag
      adbf1[_HU_PROFIL  ] := tmp->PROFIL
      adbf1[_HU_PRVS    ] := tmp->PRVS
      adbf1[_HU_N_BASE  ] := tmp->n_base
      aadd(st_arr_dbf, aclone(adbf1) )
      select TMP
      skip
    enddo
    select TMP
    oBrow:goTop()
    goto (rec_tmp)
    stat_msg("Услуги запомнены!") ; mybell(1,OK)
    restscreen(buf)
    flag := 0
  case eq_any(nKey,K_CTRL_F10,K_F11) .and. st_arr_dbf != NIL
    if !fl_found
      colorwin(6,0,6,79,"B/B","W+/RB")
    endif
    if st_vzrosl != (human->vzros_reb==0)
      func_error(4,'Критерий "взрослый/ребенок" у данного больного отличается от предыдущего!')
    elseif f_Esc_Enter("копирования услуг")
      mywait()
      last_date := human->n_data
      min_date := st_arr_dbf[1,_HU_DATE_U1]
      for k := 1 to len(st_arr_dbf)
        min_date := min(st_arr_dbf[k,_HU_DATE_U1],min_date)
      next
      select HU
      for k := 1 to len(st_arr_dbf)
        fl_found := .t.
        ++mvu[1,1]  // услуги добавлены оператором
        new_date := human->n_data + (st_arr_dbf[k,_HU_DATE_U1] - min_date)
        if !between(new_date,human->n_data,human->k_data)
          new_date := human->k_data
        endif
        if st_arr_dbf[k,_HU_N_BASE] == 0
          select HU
          Add1Rec(7)
          rec := hu->(recno())
          hu->kod     := human->kod
          hu->kod_vr  := st_arr_dbf[k,_HU_KOD_VR]
          hu->kod_as  := st_arr_dbf[k,_HU_KOD_AS]
          hu->u_koef  := 1
          hu->u_kod   := st_arr_dbf[k,_HU_U_KOD ]
          hu->u_cena  := st_arr_dbf[k,_HU_U_CENA]
          hu->kol_rcp := st_arr_dbf[k,_HU_KOL_RCP]
          hu->is_edit := st_arr_dbf[k,_HU_IS_EDIT]
          hu->date_u  := dtoc4(new_date)
          hu->otd     := st_arr_dbf[k,_HU_OTD    ]
          hu->kol     := st_arr_dbf[k,_HU_KOL_1  ]
          hu->stoim   := st_arr_dbf[k,_HU_STOIM_1]
          hu->kol_1   := st_arr_dbf[k,_HU_KOL_1  ]
          hu->stoim_1 := st_arr_dbf[k,_HU_STOIM_1]
          select HU_
          do while hu_->(lastrec()) < hu->(recno())
            APPEND BLANK
          enddo
          goto (hu->(recno()))
          G_RLock(forever)
          hu_->ID_U := mo_guid(3,hu_->(recno()))
          hu_->kod_diag := human_kod_diag
          hu_->PROFIL   := st_arr_dbf[k,_HU_PROFIL  ]
          hu_->PRVS     := st_arr_dbf[k,_HU_PRVS    ]
        else
          select MOHU
          Add1Rec(7)
          rec := mohu->(recno())
          mohu->kod     := human->kod
          mohu->kod_vr  := st_arr_dbf[k,_HU_KOD_VR]
          mohu->kod_as  := st_arr_dbf[k,_HU_KOD_AS]
          mohu->u_kod   := st_arr_dbf[k,_HU_U_KOD ]
          mohu->u_cena  := st_arr_dbf[k,_HU_U_CENA]
          mohu->date_u  := dtoc4(new_date)
          mohu->otd     := st_arr_dbf[k,_HU_OTD    ]
          mohu->kol_1   := st_arr_dbf[k,_HU_KOL_1  ]
          mohu->stoim_1 := st_arr_dbf[k,_HU_STOIM_1]
          mohu->ID_U    := mo_guid(4,mohu->(recno()))
          mohu->kod_diag:= human_kod_diag
          mohu->PROFIL  := st_arr_dbf[k,_HU_PROFIL]
          mohu->PRVS    := st_arr_dbf[k,_HU_PRVS  ]
        endif
        //
        UNLOCK
        select TMP
        append blank
        tmp->kod      := human->kod
        tmp->date_u   := dtoc4(new_date)
        tmp->date_u1  := new_date
        tmp->rec_hu   := rec
        tmp->U_KOD    := st_arr_dbf[k,_HU_U_KOD  ]
        tmp->U_CENA   := st_arr_dbf[k,_HU_U_CENA ]
        tmp->shifr_u  := st_arr_dbf[k,_HU_SHIFR_U]
        tmp->shifr1   := st_arr_dbf[k,_HU_SHIFR1 ]
        tmp->name_u   := st_arr_dbf[k,_HU_NAME_U ]
        tmp->is_nul   := st_arr_dbf[k,_HU_IS_NUL ]
        tmp->is_oms   := st_arr_dbf[k,_HU_IS_OMS ]
        tmp->is_edit  := st_arr_dbf[k,_HU_IS_EDIT]
        tmp->dom      := st_arr_dbf[k,_HU_KOL_RCP]
        tmp->KOD_VR   := st_arr_dbf[k,_HU_KOD_VR ]
        tmp->KOD_AS   := st_arr_dbf[k,_HU_KOD_AS ]
        tmp->OTD      := st_arr_dbf[k,_HU_OTD    ]
        tmp->KOL_1    := st_arr_dbf[k,_HU_KOL_1  ]
        tmp->STOIM_1  := st_arr_dbf[k,_HU_STOIM_1]
        tmp->kod_diag := human_kod_diag
        tmp->PROFIL   := st_arr_dbf[k,_HU_PROFIL]
        tmp->PRVS     := st_arr_dbf[k,_HU_PRVS  ]
        tmp->n_base   := st_arr_dbf[k,_HU_N_BASE]
        last_date := max(tmp->date_u1,last_date)
        if st_arr_dbf[k,_HU_N_BASE] == 0
          // переопределение цены
          if (v := f1cena_oms(tmp->shifr_u,;
                              tmp->shifr1,;
                              (human->vzros_reb==0),;
                              human->k_data,;
                              tmp->is_nul,;
                              @fl)) != NIL
            tmp->is_oms := fl
            if !(round(tmp->u_cena,2)==round(v,2))
              tmp->u_cena := v
              tmp->stoim_1 := round_5(tmp->u_cena * tmp->kol_1, 2)
              select HU
              G_RLock(forever)
              hu->u_cena := tmp->u_cena
              hu->stoim  := hu->stoim_1 := tmp->stoim_1
              UNLOCK
            endif
          endif
        endif
      next
      if human_->USL_OK < 3 // стационар
        aksg := f_usl_definition_KSG(human->kod)
      endif
      summa_usl()
      stat_msg("Услуги скопированы!") ; mybell(1,OK)
      restscreen(buf)
      f3oms_usl_sluch()
      vr_pr_1_den(1,,u_other)
      select TMP
      oBrow:goTop()
      flag := 0
    elseif !fl_found
      flag := 1
    endif
  case eq_any(nKey,K_F4,K_F5,K_CTRL_F5) .and. tmp->kod > 0
    if (arr_dni := uk_arr_dni(nKey)) != NIL
      mywait()
      st_arr_dbf_s := {}
      adbf1 := array(_HU_LEN)
      if eq_any(nkey,K_F4,K_F5)  // запомнить копируемую услугу
        adbf1[_HU_DATE_U1 ] := tmp->date_u1
        adbf1[_HU_U_KOD   ] := tmp->U_KOD
        adbf1[_HU_U_CENA  ] := tmp->U_CENA
        adbf1[_HU_SHIFR_U ] := tmp->shifr_u
        adbf1[_HU_SHIFR1  ] := tmp->shifr1
        adbf1[_HU_NAME_U  ] := tmp->name_u
        adbf1[_HU_IS_NUL  ] := tmp->is_nul
        adbf1[_HU_IS_OMS  ] := tmp->is_oms
        adbf1[_HU_IS_EDIT ] := tmp->is_edit
        adbf1[_HU_KOL_RCP ] := tmp->dom
        adbf1[_HU_KOD_VR  ] := tmp->KOD_VR
        adbf1[_HU_KOD_AS  ] := tmp->KOD_AS
        adbf1[_HU_OTD     ] := tmp->OTD
        adbf1[_HU_KOL_1   ] := tmp->KOL_1
        adbf1[_HU_STOIM_1 ] := tmp->STOIM_1
        adbf1[_HU_KOD_DIAG] := tmp->kod_diag
        adbf1[_HU_PROFIL  ] := tmp->PROFIL
        adbf1[_HU_PRVS    ] := tmp->PRVS
        adbf1[_HU_N_BASE  ] := tmp->n_base
        aadd(st_arr_dbf_s,aclone(adbf1))
      else
        select TMP
        go top
        do while !eof()
          if date_tmp == tmp->date_u1  // запомнить все услуги за этот день
            adbf1[_HU_DATE_U1 ] := tmp->date_u1
            adbf1[_HU_U_KOD   ] := tmp->U_KOD
            adbf1[_HU_U_CENA  ] := tmp->U_CENA
            adbf1[_HU_SHIFR_U ] := tmp->shifr_u
            adbf1[_HU_SHIFR1  ] := tmp->shifr1
            adbf1[_HU_NAME_U  ] := tmp->name_u
            adbf1[_HU_IS_NUL  ] := tmp->is_nul
            adbf1[_HU_IS_OMS  ] := tmp->is_oms
            adbf1[_HU_IS_EDIT ] := tmp->is_edit
            adbf1[_HU_KOL_RCP ] := tmp->dom
            adbf1[_HU_KOD_VR  ] := tmp->KOD_VR
            adbf1[_HU_KOD_AS  ] := tmp->KOD_AS
            adbf1[_HU_OTD     ] := tmp->OTD
            adbf1[_HU_KOL_1   ] := tmp->KOL_1
            adbf1[_HU_STOIM_1 ] := tmp->STOIM_1
            adbf1[_HU_KOD_DIAG] := tmp->kod_diag
            adbf1[_HU_PROFIL  ] := tmp->PROFIL
            adbf1[_HU_PRVS    ] := tmp->PRVS
            adbf1[_HU_N_BASE  ] := tmp->n_base
            aadd(st_arr_dbf_s,aclone(adbf1))
          endif
          select TMP
          skip
        enddo
      endif
      for j := 1 to len(arr_dni)
        for k := 1 to len(st_arr_dbf_s)
          ++mvu[1,1]  // услуги добавлены оператором
          if st_arr_dbf_s[k,_HU_N_BASE] == 0
            select HU
            Add1Rec(7)
            hu->kod     := human->kod
            hu->kod_vr  := st_arr_dbf_s[k,_HU_KOD_VR]
            hu->kod_as  := st_arr_dbf_s[k,_HU_KOD_AS]
            hu->u_koef  := 1
            hu->u_kod   := st_arr_dbf_s[k,_HU_U_KOD ]
            hu->u_cena  := st_arr_dbf_s[k,_HU_U_CENA]
            hu->is_edit := st_arr_dbf_s[k,_HU_IS_EDIT]
            hu->kol_rcp := st_arr_dbf_s[k,_HU_KOL_RCP]
            hu->date_u  := dtoc4(arr_dni[j,2])
            hu->otd     := st_arr_dbf_s[k,_HU_OTD    ]
            hu->kol     := st_arr_dbf_s[k,_HU_KOL_1  ]
            hu->stoim   := st_arr_dbf_s[k,_HU_STOIM_1]
            hu->kol_1   := st_arr_dbf_s[k,_HU_KOL_1  ]
            hu->stoim_1 := st_arr_dbf_s[k,_HU_STOIM_1]
            select HU_
            do while hu_->(lastrec()) < hu->(recno())
              APPEND BLANK
            enddo
            goto (hu->(recno()))
            G_RLock(forever)
            hu_->ID_U     := mo_guid(3,hu_->(recno()))
            hu_->kod_diag := st_arr_dbf_s[k,_HU_KOD_DIAG]
            hu_->PROFIL   := st_arr_dbf_s[k,_HU_PROFIL  ]
            hu_->PRVS     := st_arr_dbf_s[k,_HU_PRVS    ]
            //
            mrec_hu := hu->(recno())
          else
            select MOHU
            Add1Rec(7)
            mohu->kod     := human->kod
            mohu->kod_vr  := st_arr_dbf_s[k,_HU_KOD_VR]
            mohu->kod_as  := st_arr_dbf_s[k,_HU_KOD_AS]
            mohu->u_kod   := st_arr_dbf_s[k,_HU_U_KOD ]
            mohu->u_cena  := st_arr_dbf_s[k,_HU_U_CENA]
            mohu->date_u  := dtoc4(arr_dni[j,2])
            mohu->otd     := st_arr_dbf_s[k,_HU_OTD    ]
            mohu->kol_1   := st_arr_dbf_s[k,_HU_KOL_1  ]
            mohu->stoim_1 := st_arr_dbf_s[k,_HU_STOIM_1]
            mohu->ID_U    := mo_guid(4,mohu->(recno()))
            mohu->kod_diag:= human_kod_diag
            mohu->PROFIL  := st_arr_dbf_s[k,_HU_PROFIL]
            mohu->PRVS    := st_arr_dbf_s[k,_HU_PRVS  ]
            //
            mrec_hu := mohu->(recno())
          endif
          UNLOCK
          select TMP
          append blank
          tmp->kod      := human->kod
          tmp->date_u   := dtoc4(arr_dni[j,2])
          tmp->date_u1  := arr_dni[j,2]
          tmp->rec_hu   := mrec_hu
          tmp->U_KOD    := st_arr_dbf_s[k,_HU_U_KOD   ]
          tmp->U_CENA   := st_arr_dbf_s[k,_HU_U_CENA  ]
          tmp->shifr_u  := st_arr_dbf_s[k,_HU_SHIFR_U ]
          tmp->shifr1   := st_arr_dbf_s[k,_HU_SHIFR1  ]
          tmp->name_u   := st_arr_dbf_s[k,_HU_NAME_U  ]
          tmp->is_nul   := st_arr_dbf_s[k,_HU_IS_NUL  ]
          tmp->is_oms   := st_arr_dbf_s[k,_HU_IS_OMS  ]
          tmp->is_edit  := st_arr_dbf_s[k,_HU_IS_EDIT ]
          tmp->dom      := st_arr_dbf_s[k,_HU_KOL_RCP ]
          tmp->KOD_VR   := st_arr_dbf_s[k,_HU_KOD_VR  ]
          tmp->KOD_AS   := st_arr_dbf_s[k,_HU_KOD_AS  ]
          tmp->OTD      := st_arr_dbf_s[k,_HU_OTD     ]
          tmp->KOL_1    := st_arr_dbf_s[k,_HU_KOL_1   ]
          tmp->STOIM_1  := st_arr_dbf_s[k,_HU_STOIM_1 ]
          tmp->kod_diag := st_arr_dbf_s[k,_HU_KOD_DIAG]
          tmp->PROFIL   := st_arr_dbf_s[k,_HU_PROFIL  ]
          tmp->PRVS     := st_arr_dbf_s[k,_HU_PRVS    ]
          rec_tmp := tmp->(recno())
          if st_arr_dbf_s[k,_HU_N_BASE] == 0
            // переопределение цены
            if (v := f1cena_oms(tmp->shifr_u,;
                                tmp->shifr1,;
                                (human->vzros_reb==0),;
                                human->k_data,;
                                tmp->is_nul)) != NIL
              if !(round(tmp->u_cena,2)==round(v,2))
                tmp->u_cena := v
                tmp->stoim_1 := round_5(tmp->u_cena * tmp->kol_1, 2)
                select HU
                G_RLock(forever)
                hu->u_cena := tmp->u_cena
                hu->stoim  := hu->stoim_1 := tmp->stoim_1
                UNLOCK
                select TMP
              endif
            endif
          endif
        next
      next
      if human_->USL_OK < 3 // стационар
        aksg := f_usl_definition_KSG(human->kod)
      endif
      summa_usl()
      restscreen(buf)
      f3oms_usl_sluch()
      vr_pr_1_den(1,,u_other)
      select TMP
      oBrow:goTop()
      goto (rec_tmp)
      setcolor(tmp_color)
      flag := 0
    endif
  case nKey == K_INS .or. (nKey == K_ENTER .and. tmp->kod > 0)
    if !(skod_human == human->kod .and. skod_k == human->kod_k)
      skod_human := human->kod
      skod_k := human->kod_k
      SKOD_DIAG := padr(human_kod_diag,6)
      SZF := space(30)
    endif
    if nKey == K_INS .and. !fl_found
      colorwin(6,0,6,79,"B/B","W+/RB")
    endif
    if mem_pom_va == 1 .or. skod_vr == NIL
      skod_vr := skod_as := 0
    endif
    if mem_coplec == 2 .and. kod_lech_vr > 0
      skod_vr := kod_lech_vr
      kod_lech_vr := 0
    endif
    Private motd := space(10), ;
            m1otd := iif(nKey == K_INS, iif(pr1otd == NIL, human->otd, pr1otd), tmp->otd),;
            mu_kod := iif(nKey == K_INS, 0, tmp->u_kod),;
            mdate_u1 := iif(nKey == K_INS, last_date, tmp->date_u1),;
            mis_nul := iif(nKey == K_INS, .f., tmp->is_nul),;
            mis_oms := iif(nKey == K_INS, .f., tmp->is_oms),;
            mis_edit := iif(nKey == K_INS, 0, tmp->is_edit),;
            mu_cena := iif(nKey == K_INS, 0, tmp->u_cena),;
            mkod_vr := iif(nKey == K_INS, skod_vr, tmp->kod_vr),;
            mkod_as := iif(nKey == K_INS, skod_as, tmp->kod_as),;
            mtabn_vr := 0, mtabn_as := 0, m1prvs := 0,;
            mshifr := iif(nKey == K_INS, space(20), tmp->shifr_u),;
            mshifr1 := iif(nKey == K_INS, space(20), tmp->shifr1),;
            mname_u := iif(nKey == K_INS, space(65), tmp->name_u),;
            mKOD_DIAG := iif(nKey == K_INS, SKOD_DIAG, tmp->KOD_DIAG),;
            mZF := iif(nKey == K_INS, SZF, tmp->ZF),;
            mpar_org := space(10), m1par_org := iif(nKey == K_INS, "", tmp->ZF),;
            is_gist := .f., mgist := space(10), m1gist := iif(nKey == K_INS, 4, tmp->is_edit),;
            m1PROFIL := iif(nKey == K_INS, human_->profil, tmp->profil), mPROFIL,;
            mkol_1 := iif(nKey == K_INS, 0, tmp->kol_1),;
            mstoim_1 := iif(nKey == K_INS, 0, tmp->stoim_1),;
            mn_base := iif(nKey == K_INS, 0, tmp->n_base),;
            mdom, m1dom := iif(nKey == K_INS, 0, tmp->dom),;
            mdate_next := iif(nKey == K_INS, ctod(""), tmp->DATE_NEXT), fl_date_next := .f.,;
            mvrach := massist := space(35), vr_uva := as_uva := .t., ;
            arr_zf, is_usluga_zf := iif(nKey == K_INS, 0, tmp->is_zf),;
            m1NPR_MO := "", mNPR_MO := space(10),;
            pr_k_usl := {},;  // массив комплексных услуг
            tip_par_org := iif(nKey == K_INS, "", tmp->par_org),;
            tip_telemed := 0, tip_telemed2 := .f.,;
            mnmic := space(10), m1nmic := 0, mnmic1 := space(10), m1nmic1 := 0,;
            row_dom, gl_area := {1,0,maxrow()-1,79,0}
    Private mm_gist := {{"в Волгоградском патал.анат.бюро",4},;
                        {"в нашей медицинской организации",0},;
                        {"в иногороднем патал.анат.бюро  ",5}}
    if nKey == K_ENTER
      mshifr1 := iif(empty(mshifr1), mshifr, mshifr1)
      if is_telemedicina(mshifr1,@tip_telemed2)
        tip_telemed := 1
        if tip_telemed2
          m1nmic := int(val(beforatnum(":",mzf)))
          mnmic := inieditspr(A__MENUVERT, glob_nmic, m1nmic)
          if m1nmic > 0
            m1nmic1 := int(val(afteratnum(":",mzf)))
            mnmic1 := inieditspr(A__MENUVERT, mm_danet, m1nmic1)
          endif
        endif
      endif
      fl_date_next := is_usluga_disp_nabl(mshifr,mshifr1)
      mpar_org := ini_par_org(m1par_org,tip_par_org)
      if left(mshifr1,5) == "60.8."
        mgist := inieditspr(A__MENUVERT, mm_gist, m1gist)
        is_gist := .t.
      endif
      if pr_amb_reab .and. left(mshifr1,2)=='4.'
        m1NPR_MO := left(mzf,6)
        if empty(m1NPR_MO)
          m1NPR_MO := glob_mo[_MO_KOD_TFOMS]
        endif
        if m1NPR_MO = '999999'
          mNPR_MO := '=== сторонняя МО (не в ОМС или не в Волгоградской области) ==='
        else
          mNPR_MO := ret_mo(m1NPR_MO)[_MO_SHORT_NAME]
        endif
      endif
      select TMP
      in_array := get_field()
    endif
    if (i := ascan(pr_arr,{|x| x[1] == m1otd } )) > 0
      motd := pr_arr[i,2]
    elseif nKey == K_ENTER
      if yes_many_uch
        motd := "! некорректное отделение !"
      else
        motd := "! не то учреждение !"
      endif
    endif
    if !empty(mshifr)
      verify_uva(2)
    endif
    if mkod_vr > 0
      select PERSO
      goto (mkod_vr)
      mtabn_vr := perso->tab_nom
      m1prvs := -ret_new_spec(perso->prvs,perso->prvs_new)
      mvrach := padr(fam_i_o(perso->fio)+" "+ret_tmp_prvs(m1prvs),57)
    endif
    if mkod_as > 0
      select PERSO
      goto (mkod_as)
      massist := padr(perso->fio,35)
      mtabn_as := perso->tab_nom
    endif
    if empty(m1PROFIL)
      m1PROFIL := human_->profil
    endif
    mdom := inieditspr(A__MENUVERT, mm_dom, m1dom)
    mPROFIL := padr(inieditspr(A__MENUVERT, glob_V002, m1PROFIL), 69)
    --r1
    box_shadow(r1-1,0,maxrow()-1,79,color8,;
               iif(nKey == K_INS,"Добавление новой услуги",;
                                 "Редактирование услуги"),iif(yes_color,"RB+/B","W/N"))
    if mem_otdusl == 2
      keyboard chr(K_TAB)
    endif
    do while .t.
      setcolor(cDataCGet)
      ix := 1
      if mem_kodotd == 1 .or. mem_otdusl == 2
        @ r1+ix,2 say "Отделение, где оказана услуга" get motd ;
                  reader {|x|menu_reader(x,{{|k,r,c| get_otd(k,r+1,c,.t.) }},A__FUNCTION,,,.f.)}
      else
        @ r1+ix,2 say "Отделение, где оказана услуга" get m1otd pict "99" ;
                  when {|g| f5editkusl(g,1,10) } ;
                  valid {|g| f5editkusl(g,2,10) }
        @ row(),col()+2 get motd color color14 when .f.
      endif
      ++ix
      @ r1+ix,2 say "Дата оказания услуги" get mdate_u1 ;
                valid {|g| f5editkusl(g,2,1) }
      ++ix
      @ r1+ix,2 say "Диагноз по МКБ-10" get mkod_diag picture pic_diag ;
                reader {|o|MyGetReader(o,bg)} ;
                when when_diag() ;
                valid val1_10diag(.t.,.f.,.f.,human->n_data,iif(human_->novor==0,human->pol,human_->pol2))
      if is_zf_stomat == 1
        ++ix
        @ r1+ix,2 say "Зубная формула" get mzf pict pic_diag ;
                  valid {|g| f5editkusl(g,2,101) }
      endif
      ++ix
      @ r1+ix,2 say "Шифр услуги" get mshifr pict "@!" ;
                when {|g| f5editkusl(g,1,2) } ;
                valid {|g| f5editkusl(g,2,2) }
      @ row(),40 say "Цена услуги" get mu_cena pict pict_cena ;
                 when .f. color color14
      ++ix
      @ r1+ix,2 say "Услуга" get mname_u when .f. color color14
      ++ix ; row_dom := r1+ix
      @ row_dom,2 say "Где оказана услуга" get mnmic ;
                  reader {|x|menu_reader(x,glob_nmic,A__MENUVERT,,,.f.)} ;
                  when tip_telemed2 ;
                  valid {|| iif(m1nmic == 0, (mnmic1 := space(10), m1nmic1 := 0), ), update_get("mnmic1") }
      ++ix
      @ row_dom+1,2 say " Получены ли результаты на дату окончания лечения" get mnmic1 ;
                    reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                    when m1nmic > 0
      if !tip_telemed2
        @ row_dom  ,1 say space(78) color color1
        @ row_dom+1,1 say space(78) color color1
        if human_->usl_ok == 3
          if iif(empty(mshifr), .t., is_gist)
           @ row_dom,2 say " Где проведено это исследование" get mgist ;
                       reader {|x|menu_reader(x,mm_gist,A__MENUVERT,,,.f.)} ;
                       when iif(empty(mshifr), .f., is_gist) ;
                       valid {|| mis_edit := m1gist, .t. }
          endif
          if iif(empty(mshifr), .t., DomUslugaTFOMS(mshifr1)) .and. !(is_gist .or. pr_amb_reab)
           @ row_dom,2 say "Где оказана услуга" get mdom ;
                       reader {|x|menu_reader(x,mm_dom,A__MENUVERT,,,.f.)} ;
                       when iif(empty(mshifr), .t., DomUslugaTFOMS(mshifr1))
          endif
          if iif(empty(mshifr), pr_amb_reab, pr_amb_reab.and.left(mshifr1,2)=='4.')
           @ row_dom,2 say "Где оказана услуга" get mNPR_MO ;
                       reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c,,2)}},A__FUNCTION,,,.f.)} ;
                       when iif(empty(mshifr), pr_amb_reab, pr_amb_reab.and.left(mshifr1,2)=='4.')
          endif
          if !(is_gist .or. pr_amb_reab)
           @ row_dom,35 say "Дата след.явки для дисп.набл-ия" get mdate_next when fl_date_next
          endif
        endif
        if human_->usl_ok < 3
          @ row_dom+1,2 say "Органы/части тела" get mpar_org ;
                      reader {|x|menu_reader(x,{{|k,r,c|get_par_org(r,c,k,tip_par_org)}},A__FUNCTION,,,.f.)} ;
                      when !empty(tip_par_org)
        endif
      endif
      ++ix
      @ r1+ix,2 say "Профиль" get MPROFIL ;
                reader {|x|menu_reader(x,tmp_V002,A__MENUVERT,,,.f.)} ;
                when mis_edit == 0 ;
                valid {|| mprofil := padr(mprofil,69), .t. }
      for x := 1 to 3
        if mem_por_vr == x
          ++ix
          @ r1+ix,2 say "Врач(сред.медперсонал)" get mtabn_vr pict "99999" ;
                    when {|g| mis_edit == 0 .and. f5editkusl(g,1,3) } ;
                    valid {|g| f5editkusl(g,2,3) }
          @ row(),col()+3 get mvrach when .f. color color14
        endif
        if mem_por_ass == x
          ++ix
          @ r1+ix,2 say "Таб.№ ассистента" get mtabn_as pict "99999" ;
                    when {|g| mis_edit == 0 .and. f5editkusl(g,1,4) } ;
                    valid {|g| f5editkusl(g,2,4) }
          @ row(),col()+3 get massist when .f. color color14
        endif
        if mem_por_kol == x
          ++ix
          @ r1+ix,2 say "Количество услуг" get mkol_1 pict "999" ;
                    when {|g| f5editkusl(g,1,5) } ;
                    valid {|g| f5editkusl(g,2,5) }
        endif
      next
      ++ix
      @ r1+ix,2 say "Стоимость услуги" get mstoim_1 pict pict_cena ;
                when .f.
      status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи")
      set key K_F11 to clear_gets
      set key K_CTRL_F10 to clear_gets
      count_edit := myread(,,++k_read)
      SetKey( K_F2, NIL )
      SetKey( K_F3, NIL )
      SetKey( K_F5, NIL )
      SetKey( K_F11, NIL )
      SetKey( K_CTRL_F10, NIL )
      if eq_any(lastkey(),K_CTRL_F10,K_F11)
        hb_KeyPut(K_CTRL_F10) //keysend(KS_CTRL_F10)
      elseif lastkey() != K_ESC
        mkol := mkol_1 ; mstoim := mstoim_1
        Private amsg := {}
        if empty(mdate_u1)
          func_error(4,"Не введена дата оказания услуги!")
          loop
        elseif mdate_u1 < human->n_data .and. !(tip_telemed2 .and. m1nmic > 0)
          func_error(4,"Введенная дата меньше даты начала лечения!")
          loop
        elseif len(pr_k_usl) == 0 .and. emptyall(mu_kod,mshifr)
          func_error(4,"Не введена услуга!")
          loop
        elseif len(pr_k_usl) == 0 .and. !mis_nul .and. empty(mstoim_1) .and. !NulUslugaTFOMS(iif(empty(mshifr1), mshifr, mshifr1))
          func_error(4,"Не введена цена услуги!")
          loop
        elseif mis_edit >= 0 .and. empty(mkod_vr) .and. !is_gist .and. is_usluga_TFOMS(mshifr,mshifr1,human->k_data) ;
           .and. !(pr_amb_reab .and. left(mshifr1,2)=='4.' .and. (m1NPR_MO=='999999' .or. m1NPR_MO!=glob_mo[_MO_KOD_TFOMS]))
          func_error(4,"Не введен врач!")
          loop
        else
          err_date_diap(mdate_u1,"Дата оказания услуги")
          mywait()
          if nKey == K_INS
            mvu[1,2] += count_edit
          else
            mvu[2,2] += count_edit
          endif
          if nKey == K_INS .and. len(pr_k_usl) > 0
            // комплексная услуга
            for i := 1 to len(pr_k_usl)
              mshifr := pr_k_usl[i,1]
              mu_kod := pr_k_usl[i,3]
              mname_u := pr_k_usl[i,4]
              mu_cena := pr_k_usl[i,5]
              mshifr1 := pr_k_usl[i,8]
              mis_nul := pr_k_usl[i,9]
              mis_oms := pr_k_usl[i,10]
              mstoim := mstoim_1 := round_5(mu_cena * mkol_1, 2)
              //
              select HU
              Add1Rec(7)
              mrec_hu := hu->(recno())
              fl_found := .t.
              select TMP
              append blank
              rec_tmp := tmp->(recno())
              ++mvu[1,1]  // услуга добавлена оператором
              //
              select HU
              replace hu->kod     with human->kod,;
                      hu->kod_vr  with mkod_vr,;
                      hu->kod_as  with mkod_as,;
                      hu->u_koef  with 1,;
                      hu->u_kod   with mu_kod,;
                      hu->u_cena  with mu_cena,;
                      hu->is_edit with 0,;
                      hu->date_u  with dtoc4(mdate_u1),;
                      hu->otd     with m1otd,;
                      hu->kol     with mkol_1,;
                      hu->stoim   with mstoim_1,;
                      hu->kol_1   with mkol_1,;
                      hu->stoim_1 with mstoim_1
              if len(arr_uva) > 0 .and. (j := ascan(arr_uva, {|x| like(x[1],alltrim(mshifr)) })) > 0
                if arr_uva[j,2] == 1
                  hu->kod_vr := 0
                endif
                if arr_uva[j,3] == 1
                  hu->kod_as := 0
                endif
              endif
              select HU_
              do while hu_->(lastrec()) < mrec_hu
                APPEND BLANK
              enddo
              goto (mrec_hu)
              G_RLock(forever)
              hu_->ID_U   := mo_guid(3,hu_->(recno()))
              hu_->PROFIL := m1PROFIL
              hu_->PRVS   := m1PRVS
              hu_->kod_diag := mkod_diag
              UNLOCK
              //
              pr1otd := m1otd
              adbf := array(fcount())
              aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
              select TMP
              tmp->KOD     := human->kod
              tmp->DATE_U  := dtoc4(mdate_u1)
              tmp->U_KOD   := mu_kod
              tmp->U_CENA  := mu_cena
              tmp->KOD_VR  := mkod_vr
              tmp->KOD_AS  := mkod_as
              tmp->OTD     := m1otd
              tmp->KOL_1   := mkol_1
              tmp->STOIM_1 := mstoim_1
              tmp->kod_diag:= mkod_diag
              tmp->ZF      := mzf
              tmp->PROFIL  := m1profil
              tmp->PRVS    := m1prvs
              tmp->date_u1 := mdate_u1
              tmp->shifr_u := mshifr
              tmp->shifr1  := mshifr1
              tmp->name_u  := mname_u
              tmp->is_nul  := mis_nul
              tmp->is_oms  := mis_oms
              tmp->rec_hu  := mrec_hu
              last_date := tmp->date_u1
            next
          else// запись одной введённой услуги
            SKOD_DIAG := mkod_diag
            if mn_base == 1 .and. mu_kod == 0
              // добавляем в свой справочник федеральную услугу
              select MOSU
              set order to 1
              FIND (STR(-1,6))
              if found()
                G_RLock(forever)
              else
                AddRec(6)
              endif
              mu_kod := mosu->kod := recno()
              mosu->name   := mname_u
              mosu->shifr1 := mshifr1
              mosu->profil := m1PROFIL
            endif
            // одна услуга
            if mn_base == 0
              if human_->usl_ok == 3 .and. left(mshifr1,5) == "2.89."
                pr_amb_reab := .t.
              endif
              select HU
              if nKey == K_INS
                Add1Rec(7)
                mrec_hu := hu->(recno())
                fl_found := .t.
                select TMP
                append blank
                rec_tmp := tmp->(recno())
                ++mvu[1,1]  // услуга добавлена оператором
              else
                goto (mrec_hu)
                G_RLock(forever)
                select TMP
                goto (rec_tmp)
                ++mvu[2,1]  // услуга отредактирована оператором
              endif
              select HU
              replace hu->kod     with human->kod,;
                      hu->kod_vr  with mkod_vr,;
                      hu->kod_as  with mkod_as,;
                      hu->u_koef  with 1,;
                      hu->u_kod   with mu_kod,;
                      hu->u_cena  with mu_cena,;
                      hu->is_edit with mis_edit,;
                      hu->date_u  with dtoc4(mdate_u1),;
                      hu->otd     with m1otd,;
                      hu->kol     with mkol_1,;
                      hu->stoim   with mstoim_1,;
                      hu->kol_1   with mkol_1,;
                      hu->stoim_1 with mstoim_1
              if DomUslugaTFOMS(iif(empty(mshifr1), mshifr, mshifr1))
                hu->KOL_RCP := m1dom
              endif
              select HU_
              do while hu_->(lastrec()) < mrec_hu
                APPEND BLANK
              enddo
              goto (mrec_hu)
              G_RLock(forever)
              if nKey == K_INS .or. !valid_GUID(hu_->ID_U)
                hu_->ID_U := mo_guid(3,hu_->(recno()))
              endif
              hu_->PROFIL   := m1PROFIL
              hu_->PRVS     := m1PRVS
              hu_->kod_diag := mkod_diag
              if pr_amb_reab .and. left(mshifr1,2)=='4.'
                hu_->zf := m1NPR_MO
              endif
            else
              select MOHU
              if nKey == K_INS
                Add1Rec(7)
                mrec_hu := mohu->(recno())
                fl_found := .t.
                select TMP
                append blank
                rec_tmp := tmp->(recno())
                ++mvu[1,1]  // услуга добавлена оператором
              else
                goto (mrec_hu)
                G_RLock(forever)
                select TMP
                goto (rec_tmp)
                ++mvu[2,1]  // услуга отредактирована оператором
              endif
              select MOHU
              mohu->kod     := human->kod
              mohu->kod_vr  := mkod_vr
              mohu->kod_as  := mkod_as
              mohu->u_kod   := mu_kod
              mohu->u_cena  := mu_cena
              mohu->date_u  := dtoc4(mdate_u1)
              mohu->otd     := m1otd
              mohu->kol_1   := mkol_1
              mohu->stoim_1 := mstoim_1
              if nKey == K_INS .or. !valid_GUID(mohu->ID_U)
                mohu->ID_U  := mo_guid(4,mohu->(recno()))
              endif
              mohu->PROFIL  := m1PROFIL
              mohu->PRVS    := m1PRVS
              mohu->kod_diag:= mkod_diag
              if is_zf_stomat == 1
                mohu->ZF    := mzf
              elseif tip_telemed2
                mohu->ZF    := iif(m1nmic > 0, lstr(m1nmic)+":"+lstr(m1nmic1), "")
              else
                mohu->ZF    := m1par_org
              endif
              //
              mrec_hu := mohu->(recno())
              if is_zf_stomat == 1
                if valtype(is_usluga_zf) == "N" .and. is_usluga_zf == 1 ; // должна быть формула зуба
                                 .and. STVerifyKolZf(arr_zf,mkol_1,@amsg) // проверка по количеству зубов
                  func_error(4,amsg[1])
                endif
                //STappendDelZ(human->kod_k,mzf,mohu->date_u,mohu->u_kod)
                select MOHU
              endif
            endif
            UNLOCK
            //
            pr1otd := m1otd
            /*if is_zf_stomat == 1
              STappend(iif(mn_base==0,1,7),mrec_hu,human->kod_k,hu->date_u,mu_kod,mkod_vr,mzf,mkod_diag)
            endif*/
            select TMP
            tmp->KOD     := human->kod
            tmp->DATE_U  := dtoc4(mdate_u1)
            tmp->DATE_NEXT := mdate_next
            tmp->U_KOD   := mu_kod
            tmp->U_CENA  := mu_cena
            tmp->KOD_VR  := mkod_vr
            tmp->KOD_AS  := mkod_as
            tmp->OTD     := m1otd
            tmp->KOL_1   := mkol_1
            tmp->STOIM_1 := mstoim_1
            tmp->kod_diag:= mkod_diag
            if is_zf_stomat == 1
              tmp->ZF    := mzf
            elseif tip_telemed2
              tmp->ZF    := iif(m1nmic > 0, lstr(m1nmic)+":"+lstr(m1nmic1), "")
            elseif pr_amb_reab .and. left(mshifr1,2)=='4.'
              tmp->ZF    := m1NPR_MO
            else
              tmp->ZF    := m1par_org
            endif
            tmp->PROFIL  := m1profil
            tmp->PRVS    := m1prvs
            tmp->date_u1 := mdate_u1
            tmp->shifr_u := mshifr
            tmp->shifr1  := mshifr1
            tmp->name_u  := mname_u
            tmp->is_nul  := mis_nul
            tmp->is_oms  := mis_oms
            tmp->is_edit := mis_edit
            if nKey == K_INS
              tmp->is_zf := is_usluga_zf
            endif
            tmp->par_org := tip_par_org
            tmp->n_base  := mn_base
            tmp->dom     := m1dom
            tmp->rec_hu  := mrec_hu
            last_date := tmp->date_u1
          endif
          aksg := f_usl_definition_KSG(human->kod)
          summa_usl()
          if mem_pom_va == 2
            skod_vr := mkod_vr
            skod_as := mkod_as
          endif
        endif
      endif
      exit
    enddo
    flag := 0
    if nKey == K_INS .and. !fl_found .and. !eq_any(lastkey(),K_CTRL_F10,K_F11)
      flag := 1
    endif
    restscreen(buf)
    f3oms_usl_sluch()
    vr_pr_1_den(1,,u_other)
    select TMP
    oBrow:goTop()
    goto (rec_tmp)
    setcolor(tmp_color)
  case nKey == K_DEL .and. tmp->kod > 0 .and. f_Esc_Enter(2)
    mywait()
    ++mvu[3,1]  // услуга удалена оператором
    if is_zf_stomat == 1  .and. tmp->n_base == 1 .and. !empty(mohu->zf)
      //STDelDelZ(human->kod_k,mohu->zf,mohu->u_kod)
    endif
    if tmp->n_base == 0
      select HU
      goto (tmp->rec_hu)
      DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
      //select HU_
      //goto (tmp->rec_hu)
      //DeleteRec(.t.,.f.)
    else
      select MOHU
      goto (tmp->rec_hu)
      DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
    endif
    select TMP
    DeleteRec(.t.)  // с пометкой на удаление
    aksg := f_usl_definition_KSG(human->kod)
    summa_usl()
    vr_pr_1_den(1,,u_other)
    select TMP
    oBrow:goTop()
    go top
    if eof()
      fl_found := .f. ; keyboard chr(K_INS)
    endif
    flag := 0
    restscreen(buf)
    f3oms_usl_sluch()
  otherwise
    keyboard ""
endcase
restuchotd(uch_otd)
return flag

***** 28.02.18
Function verify_OMS_sluch(mkod)
Local buf := save_maxrow(), fl := .t., name_file := "err_sl"+stxt
mywait()
f_create_diag_srok()
fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("Список обнаруженных ошибок",80))
add_string(center("в листе учёта",80))
add_string("")
//
R_Use(dir_server+"mo_pers",,"PERS")
R_Use(dir_server+"mo_uch",,"UCH")
R_Use(dir_server+"mo_otd",,"OTD")
use_base("lusl")
use_base("luslc")
use_base("luslf")
R_Use(dir_server+"uslugi",,"USL")
G_Use(dir_server+"human_u_",,"HU_")
G_Use(dir_server+"human_u",{dir_server+"human_u",;
                            dir_server+"human_uk",;
                            dir_server+"human_ud",;
                            dir_server+"human_uv",;
                            dir_server+"human_ua"},"HU")
set relation to recno() into HU_, to u_kod into USL
R_Use(dir_server+"mo_su",,"MOSU")
G_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
G_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
G_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","ONKNA") // онконаправления
G_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","ONKSL") // Сведения о случае лечения онкологического заболевания
G_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","ONKDI") // Диагностический блок
G_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","ONKPR") // Сведения об имеющихся противопоказаниях
G_Use(dir_server+"mo_onkus",dir_server+"mo_onkus","ONKUS")
G_Use(dir_server+"mo_onkco",dir_server+"mo_onkco","ONKCO")
G_Use(dir_server+"mo_onkle",dir_server+"mo_onkle","ONKLE")
G_Use(dir_server+"human_2",,"HUMAN_2")
G_Use(dir_server+"human_",,"HUMAN_")
G_Use(dir_server+"human",{dir_server+"humans",;
                          dir_server+"humankk",;
                          dir_server+"humand"},"HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
goto (mkod)
if empty(human->k_data)
  //
elseif year(human->k_data) > 2018
  fl := verify_1_sluch()
else
  fl := verify_1_sluch_18()
endif
if d_srok->(lastrec()) > 0
  am := {"78","80","88","89"}
  if fl
    uch->(dbGoto(human->LPU))
    otd->(dbGoto(human->OTD))
    add_string(alltrim(human->fio)+" "+alltrim(human->kod_diag)+" "+;
               date_8(human->n_data)+"-"+date_8(human->k_data)+;
               iif(d_srok->tip==0, "", " (2."+am[d_srok->tip]+".*)"))
    add_string(alltrim(uch->name)+'/'+alltrim(otd->name)+'/профиль по "'+;
               inieditspr(A__MENUVERT, glob_V002, human_->profil)+'"')
    pers->(dbGoto(human_->VRACH))
    add_string("лечащий врач ["+lstr(pers->tab_nom)+"] "+pers->fio)
  endif
  select HUMAN
  goto (d_srok->kod1)
  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  add_string("")
  add_string(center("Предупреждение!",80))
  add_string("")
  add_string("Обратите внимание, что "+lstr(d_srok->dni)+" дней назад обнаружен случай")
  add_string("с основным диагнозом "+alltrim(human->kod_diag)+" "+;
             date_8(human->n_data)+"-"+date_8(human->k_data)+;
             iif(d_srok->tip1==0, "", " (2."+am[d_srok->tip1]+".*)"))
  add_string(alltrim(uch->name)+'/'+alltrim(otd->name)+'/профиль по "'+;
             inieditspr(A__MENUVERT, glob_V002, human_->profil)+'"')
  pers->(dbGoto(human_->VRACH))
  add_string("лечащий врач ["+lstr(pers->tab_nom)+"] "+pers->fio)
  fl := .f.
endif
close databases
fclose(fp)
rest_box(buf)
if !fl
  viewtext(name_file,,,,.t.,,,5)
endif
return NIL

***** 19.11.13 Добавление листка учета лечения больного
Function oms_add()
Local buf, str_sem
change_sys_date() // перечитать системную дату (для травмпунктов, работающих ночами)
if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. input_otd(T_ROW-1,T_COL+5,sys_date) != NIL
  buf := box_shadow(0,41,2,77,color13)
  @ 1,42 say padc(glob_otd[2],35) color color14
  Private fl_edit_oper, fl_edit_smp, fl_edit_DDS, fl_edit_DVN
  do while .t.
    fl_edit_oper := fl_edit_smp := fl_edit_DDS := fl_edit_DVN := .f.
    polikl_kart(1)
    if fl_edit_oper
      str_sem := "Редактирование человека "+lstr(glob_perso)
      if G_SLock(str_sem)
        oms_usl_sluch(glob_perso,glob_kartotek,.f.)
        G_SUnLock(str_sem)
      else
        func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
      endif
    elseif fl_edit_smp .or. fl_edit_DDS .or. fl_edit_DVN
      // не выходим из цикла
    else
      exit
    endif
  enddo
  if buf != NIL ; rest_box(buf) ; endif
endif
return NIL

***** Редактирование листка учета лечения больного
Function oms_edit(k)
Static sk := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"Выбор по учреждению/отделению",;
                "Выбор по отчётному периоду",;
                "Выбор по ошибке из ТФОМС",;
                "Выбор по акту снятия из СМО"}
    mas_msg := {"Редактирование случая с выбором по учреждению/отделению",;
                "Редактирование случая с выбором по отчётному периоду",;
                "Редактирование случая с выбором по конкретной ошибке из ТФОМС",;
                "Редактирование повторно выставленных случаев (после ввода актов снятия из СМО)"}
    mas_fun := {"oms_edit(1)",;
                "oms_edit(2)",;
                "oms_edit(3)",;
                "oms_edit(4)"}
    //set key K_CTRL_F11 to my_extract_reestr()
    //set key K_CTRL_F12 to create_main_base_from_reestrs()
//test_definition_KSG()
//test_definition_period_PN()
    popup_prompt(T_ROW,T_COL+5,sk,mas_pmt,mas_msg,mas_fun)
    //set key K_CTRL_F12 to
    //set key K_CTRL_F11 to
  case k == 1
    f1oms_edit()
  case k == 2
    f2oms_edit()
  case k == 3
    if !find_unfinished_reestr_sp_tk()
      f3oms_edit()
    endif
  case k == 4
    f4oms_edit()
endcase
if k > 0
  sk := k
endif
return NIL

***** 05.02.19 Редактирование случая с выбором по учреждению/отделению
Function f1oms_edit()
Static si := 1, sk := 1
Local buf, mas_pmt, arr_m, str_sem, i, buf24, buf_scr, dostup, k := 1,;
      str_error, mtitul, str_find
if (arr_m := input_year()) != NIL .and. ;
      input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
          iif(yes_h_otd==1, input_otd(T_ROW-1,T_COL+5,sys_date)!=NIL, .t.)
  if yes_vypisan == B_END
    if (k := popup_prompt(T_ROW,T_COL+5,sk,;
              {"~Не закончившие лечение","~Закончившие лечение"})) > 0
      sk := k
    endif
    if k == 0
      return NIL
    endif
  endif
  dostup := yes_vypisan+k-1
  str_error := "В данный момент"
  mtitul := alltrim(glob_uch[2])
  str_find := str(dostup,1)
  if yes_h_otd == 1
    mtitul += " [ "+alltrim(glob_otd[2])+" ]"
    str_error += " в данном отделении"
    str_find += str(glob_otd[1],3)
  endif
  str_error += " нет пациентов"
  if dostup == B_STANDART
    str_error += ", закончивших лечение"
  else
    str_error += ", не закончивших лечение"
  endif
  if arr_m != NIL
    str_error += " "+arr_m[4]
    mtitul += " "+arr_m[4]
  endif
  buf24 := save_maxrow()
  mywait()
  dbcreate(cur_dir+"tmp_h",{{"kod","N",7,0}})
  use (cur_dir+"tmp_h") new
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humann","HUMAN")
  set relation to recno() into HUMAN_
  find (str_find)
  if yes_h_otd == 1
    if dostup == B_STANDART
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h == dostup .and. otd == glob_otd[1] ;
            for between(k_data,arr_m[5],arr_m[6]) .and. human_->reestr == 0
    else
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h == dostup .and. otd == glob_otd[1] ;
            for between(k_data,arr_m[5],arr_m[6])
    endif
  else
    if dostup == B_STANDART
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h == dostup ;
            for lpu == glob_uch[1] .and. between(k_data,arr_m[5],arr_m[6]) .and. human_->reestr == 0
    else
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h == dostup ;
            for lpu == glob_uch[1] .and. between(k_data,arr_m[5],arr_m[6])
    endif
  endif
  srec := 1
  go top
  do while !eof()
    select TMP_H
    append blank
    replace kod with human->kod
    if human->kod == glob_perso
      srec := tmp_h->(recno())
    endif
    select HUMAN
    skip
  enddo
  i := tmp_h->(lastrec())
  close databases
  rest_box(buf24)
  if i == 0
    func_error(4,str_error)
  else
    Private mr1 := T_ROW, regim_vyb := 2
    do while .t.
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_, to otd into OTD
      use (cur_dir+"tmp_h") new
      set relation to kod into HUMAN
      index on upper(human->fio) to (cur_dir+"tmp_h")
      goto (srec)
      mkod := 0
      buf_scr := savescreen()
      if Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1ret_oms_human",color0,mtitul,'B/BG',,;
                      .t.,,,"f2ret_oms_human",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
        if (glob_perso := tmp_h->kod) == 0
          func_error(4,"Не найдено нужных записей!")
        elseif eq_any(human->ishod,88,89)
          func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
        else
          srec := tmp_h->(recno())
          mkod := glob_perso
          glob_kartotek := human->kod_k
          glob_k_fio := fio_plus_novor()
          glob_otd[1] := human->otd
          glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
          if len(glob_otd) == 2
            aadd(glob_otd,human_->usl_ok)
          else
            glob_otd[3] := human_->usl_ok
          endif
          k := ret_tip_lu()
          if len(glob_otd) == 3
            aadd(glob_otd,k)
          else
            glob_otd[4] := k
          endif
          glob_uch[1] := human->LPU
          glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
          fl_schet := (human->schet > 0)
        endif
      else
        restscreen(buf_scr)
        exit
      endif
      restscreen(buf_scr)
      close databases
      if mkod > 0
        if buf != NIL ; rest_box(buf) ; endif
        buf := box_shadow(0,41,3,77,color13)
        @ 1,42 say padc(glob_otd[2],35) color color14
        @ 2,42 say padc(glob_k_fio,35) color color8
        mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг"}
        if glob_otd[3] == 4 .or. glob_otd[4] > 0
          si := 1
          asize(mas_pmt,1)
          keyboard chr(K_ENTER)
        endif
        do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
          si := i
          str_sem := "Редактирование человека "+lstr(glob_perso)
          if G_SLock(str_sem)
            if i == 1
              oms_sluch(glob_perso,glob_kartotek)
            else
              oms_usl_sluch(glob_perso,glob_kartotek)
            endif
            G_SUnLock(str_sem)
          else
            func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
            exit
          endif
        enddo
      endif
    enddo
  endif
  if buf != NIL ; rest_box(buf) ; endif
  close databases
endif
return NIL

***** 05.02.19 Редактирование случая с выбором по отчётному периоду
Function f2oms_edit()
Static si := 1
Local buf, str_sem, i, arr_m, mas_pmt, buf24, buf_scr, srec, old_yes_h_otd := yes_h_otd
if !myFileDeleted(cur_dir+"tmp_h"+sdbf)
  return NIL
endif
if (arr_m := year_month(T_ROW,T_COL+5,,3)) != NIL
  buf24 := save_maxrow()
  mywait()
  dbcreate(cur_dir+"tmp_h",{{"kod","N",7,0}})
  use (cur_dir+"tmp_h") new
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(arr_m[5]),.t.)
  index on upper(fio) to (cur_dir+"tmp_h2") ;
        while human->k_data <= arr_m[6] ;
        for schet < 1 .and. human_->reestr==0
  srec := 1
  go top
  do while !eof()
    select TMP_H
    append blank
    replace kod with human->kod
    if human->kod == glob_perso
      srec := tmp_h->(recno())
    endif
    select HUMAN
    skip
  enddo
  i := tmp_h->(lastrec())
  close databases
  rest_box(buf24)
  if i == 0
    func_error(4,"В данный момент нет пациентов с датой окончания "+arr_m[4])
  else
    Private mr1 := T_ROW, regim_vyb := 2
    do while .t.
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_, to otd into OTD
      use (cur_dir+"tmp_h") new
      set relation to kod into HUMAN
      index on upper(human->fio) to (cur_dir+"tmp_h")
      goto (srec)
      mkod := 0
      yes_h_otd := 2
      buf_scr := savescreen()
      if Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1ret_oms_human",color0,'По дате окончания лечения "'+arr_m[4]+'"','B/BG',,;
                                     .t.,,,"f2ret_oms_human",,;
                                     {'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
        if (glob_perso := tmp_h->kod) == 0
          func_error(4,"Не найдено нужных записей!")
        elseif eq_any(human->ishod,88,89)
          func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
        else
          srec := tmp_h->(recno())
          mkod := glob_perso
          glob_kartotek := human->kod_k
          glob_k_fio := fio_plus_novor()
          glob_otd[1] := human->otd
          glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
          if len(glob_otd) == 2
            aadd(glob_otd,human_->usl_ok)
          else
            glob_otd[3] := human_->usl_ok
          endif
          k := ret_tip_lu()
          if len(glob_otd) == 3
            aadd(glob_otd,k)
          else
            glob_otd[4] := k
          endif
          glob_uch[1] := human->LPU
          glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
          fl_schet := (human->schet > 0)
        endif
      else
        restscreen(buf_scr)
        exit
      endif
      restscreen(buf_scr)
      close databases
      if mkod > 0
        yes_h_otd := old_yes_h_otd
        if buf != NIL ; rest_box(buf) ; endif
        buf := box_shadow(0,41,3,77,color13)
        @ 1,42 say padc(glob_otd[2],35) color color14
        @ 2,42 say padc(glob_k_fio,35) color color8
        mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг"}
        if glob_otd[3] == 4 .or. glob_otd[4] > 0
          si := 1
          asize(mas_pmt,1)
          keyboard chr(K_ENTER)
        endif
        do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
          si := i
          str_sem := "Редактирование человека "+lstr(glob_perso)
          if G_SLock(str_sem)
            if i == 1
              oms_sluch(glob_perso,glob_kartotek)
            else
              oms_usl_sluch(glob_perso,glob_kartotek)
            endif
            G_SUnLock(str_sem)
          else
            func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
            exit
          endif
        enddo
      endif
    enddo
  endif
  if buf != NIL ; rest_box(buf) ; endif
  yes_h_otd := old_yes_h_otd
  close databases
endif
return NIL

***** 11.05.20 Редактирование случая с выбором по конкретной ошибке из ТФОМС
Function f3oms_edit()
Static si := 1
Local buf, str_sem, i, k, arr, old_yes_h_otd := yes_h_otd, iRefr, ret_arr, srec, buf24, buf_scr, s, mas_pmt
if !myFileDeleted(cur_dir+"tmp_h"+sdbf)
  return NIL
endif
Private arr_m
if (arr_m := year_month(T_ROW,T_COL+5,,3)) != NIL
  buf24 := save_maxrow()
  mywait()
  arr := {}
  dbcreate(cur_dir+"tmp_h",{{"kod","N",7,0},;
                            {"SREFREASON","C",12,0},;
                            {"REFREASON","N",3,0}})
  use (cur_dir+"tmp_h") new
  R_Use(dir_server+"mo_refr",,"REFR")
  index on str(kodz,8) to (cur_dir+"tmp_refr") for tipz == 1
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_, to str(human->kod,8) into REFR
  dbseek(dtos(arr_m[5]),.t.)
  do while human->k_data <= arr_m[6] .and. !eof()
    if human_->reestr == 0 .and. human_->REES_NUM > 0 .and. human->schet == 0
      s := 0 ; s1 := ""
      select REFR
      find (str(human->kod,8))
      do while human->kod == refr->kodz .and. !eof()
        s := refr->REFREASON // берём последнее значение
        s1 := refr->SREFREASON
        skip
      enddo
      if s > 0
        select TMP_H
        append blank
        replace kod with human->kod, REFREASON with s
        if (i := ascan(arr,{|x| x[2]==tmp_h->REFREASON})) == 0
          if empty(s := ret_t005(tmp_h->REFREASON))
            s := lstr(tmp_h->REFREASON)+" неизвестная причина отказа"
          endif
          aadd(arr, {s,tmp_h->REFREASON})
        endif
      elseif !empty(s1)
        select TMP_H
        append blank
        replace kod with human->kod, REFREASON with -99, SREFREASON with s1
        if (i := ascan(arr,{|x| x[2]==tmp_h->REFREASON})) == 0
          s := s1+" новая причина отказа"
          aadd(arr, {s,tmp_h->REFREASON})
        endif
      endif
    endif
    select HUMAN
    skip
  enddo
  close databases
  rest_box(buf24)
  if empty(arr)
    func_error(4,"Нет пациентов с ошибками из ТФОМС "+arr_m[4])
  elseif (iRefr := popup_2array(arr,T_ROW,T_COL+5,,,@ret_arr,"Выбор вида ошибки","B/BG",color0)) > 0
    // в случае выбора ошибки 57 (ошибки в персональных данных) или 599 (неверный пол или дата рождения)
    if eq_any(iRefr,57,599) .and. (i := popup_prompt(T_ROW,T_COL+5,1,;
                     {"Редактирование листов учёта",;
                      "Создание файла ХОДАТАЙСТВА для отсылки в ТФОМС",;
                      "Оформление (печать) ХОДАТАЙСТВА (по старому)"},,,color5)) > 1
      return TFOMS_hodatajstvo(arr_m,iRefr,i-1)
    endif
    Private mr1 := T_ROW, regim_vyb := 2, p_del_error := ret_arr
    do while .t.
      R_Use(dir_server+"mo_otd",,"OTD")
      G_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_, to otd into OTD
      use (cur_dir+"tmp_h") new
      set relation to kod into HUMAN
      index on upper(human->fio) to (cur_dir+"tmp_h") for REFREASON==iRefr
      if srec == NIL
        go top
      else
        goto (srec)
      endif
      mkod := 0
      yes_h_otd := 2
      buf_scr := savescreen()
      box_shadow(maxrow()-3,2,maxrow()-1,77,color0)
      if Alpha_Browse(T_ROW,2,maxrow()-4,77,"f1ret_oms_human",color0,ret_arr[1],'B/BG',,;
                                     .t.,,"f21ret_oms_human","f2ret_oms_human",,;
                                     {'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
        if (glob_perso := tmp_h->kod) == 0
          func_error(4,"Не найдено нужных записей!")
        elseif eq_any(human->ishod,88,89)
          func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
        else
          srec := tmp_h->(recno())
          mkod := glob_perso
          glob_kartotek := human->kod_k
          glob_k_fio := fio_plus_novor()
          glob_otd[1] := human->otd
          glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
          if len(glob_otd) == 2
            aadd(glob_otd,human_->usl_ok)
          else
            glob_otd[3] := human_->usl_ok
          endif
          k := ret_tip_lu()
          if len(glob_otd) == 3
            aadd(glob_otd,k)
          else
            glob_otd[4] := k
          endif
          glob_uch[1] := human->LPU
          glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
          fl_schet := (human->schet > 0)
        endif
      else
        restscreen(buf_scr)
        exit
      endif
      restscreen(buf_scr)
      close databases
      if mkod > 0
        yes_h_otd := old_yes_h_otd
        if buf != NIL ; rest_box(buf) ; endif
        buf := box_shadow(0,41,3,77,color13)
        @ 1,42 say padc(glob_otd[2],35) color color14
        @ 2,42 say padc(glob_k_fio,35) color color8
        mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг"}
        if glob_otd[3] == 4 .or. glob_otd[4] > 0
          si := 1
          asize(mas_pmt,1)
          keyboard chr(K_ENTER)
        endif
        do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
          si := i
          str_sem := "Редактирование человека "+lstr(glob_perso)
          if G_SLock(str_sem)
            if i == 1
              oms_sluch(glob_perso,glob_kartotek)
            else
              oms_usl_sluch(glob_perso,glob_kartotek)
            endif
            G_SUnLock(str_sem)
          else
            func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
            exit
          endif
        enddo
      endif
    enddo
  endif
  if buf != NIL ; rest_box(buf) ; endif
  yes_h_otd := old_yes_h_otd
  close databases
endif
return NIL

***** 05.05.19 Редактирование повторно выставленных случаев (после ввода актов снятия из СМО)
Function f4oms_edit()
Static si := 1
Local buf, str_sem, i, k, arr_m, arr, old_yes_h_otd := yes_h_otd,;
      iRefr, srec, buf24, buf_scr, mas_pmt
if !myFileDeleted(cur_dir+"tmp_h"+sdbf)
  return NIL
endif
if (arr_m := year_month(T_ROW,T_COL+5)) != NIL
  buf24 := save_maxrow()
  mywait()
  dbcreate(cur_dir+"tmp_h",{{"kod","N",7,0}})
  use (cur_dir+"tmp_h") new
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(arr_m[5]),.t.)
  index on upper(fio) to (cur_dir+"tmp_h2") ;
        while human->k_data <= arr_m[6] ;
        for emptyall(human_->reestr,human->schet) .and. human_->kod_up > 0
  go top
  do while !eof()
    select TMP_H
    append blank
    replace kod with human->kod
    select HUMAN
    skip
  enddo
  i := tmp_h->(lastrec())
  close databases
  rest_box(buf24)
  if i == 0
    func_error(4,"Нет повторно выставленных случаев "+arr_m[4])
  else
    Private mr1 := T_ROW, regim_vyb := 2
    srec := 1
    do while .t.
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_, to otd into OTD
      use (cur_dir+"tmp_h") new
      set relation to kod into HUMAN
      index on upper(human->fio) to (cur_dir+"tmp_h")
      goto (srec)
      mkod := 0
      yes_h_otd := 2
      buf_scr := savescreen()
      if Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1ret_oms_human",color0,"Повторно выставленные случаи "+arr_m[4],'B/BG',,;
                                     .t.,,,"f2ret_oms_human",,;
                                     {'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
        if (glob_perso := tmp_h->kod) == 0
          func_error(4,"Не найдено нужных записей!")
        elseif eq_any(human->ishod,88,89)
          func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
        else
          srec := tmp_h->(recno())
          mkod := glob_perso
          glob_kartotek := human->kod_k
          glob_k_fio := fio_plus_novor()
          glob_otd[1] := human->otd
          glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
          if len(glob_otd) == 2
            aadd(glob_otd,human_->usl_ok)
          else
            glob_otd[3] := human_->usl_ok
          endif
          k := ret_tip_lu()
          if len(glob_otd) == 3
            aadd(glob_otd,k)
          else
            glob_otd[4] := k
          endif
          glob_uch[1] := human->LPU
          glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
          fl_schet := (human->schet > 0)
        endif
      else
        restscreen(buf_scr)
        exit
      endif
      restscreen(buf_scr)
      close databases
      if mkod > 0
        yes_h_otd := old_yes_h_otd
        if buf != NIL ; rest_box(buf) ; endif
        buf := box_shadow(0,41,3,77,color13)
        @ 1,42 say padc(glob_otd[2],35) color color14
        @ 2,42 say padc(glob_k_fio,35) color color8
        mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг"}
        if glob_otd[3] == 4 .or. glob_otd[4] > 0
          si := 1
          asize(mas_pmt,1)
          keyboard chr(K_ENTER)
        endif
        do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
          si := i
          str_sem := "Редактирование человека "+lstr(glob_perso)
          if G_SLock(str_sem)
            if i == 1
              oms_sluch(glob_perso,glob_kartotek)
            else
              oms_usl_sluch(glob_perso,glob_kartotek)
            endif
            G_SUnLock(str_sem)
          else
            func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
            exit
          endif
        enddo
      endif
    enddo
  endif
  if buf != NIL ; rest_box(buf) ; endif
  yes_h_otd := old_yes_h_otd
  close databases
endif
return NIL

***** 05.02.19 Редактирование листка учета лечения больного + смена отделения
Function oms_smena_otd()
Static si := 1, sk := 1
Local buf, buf1, buf2, str_sem, i, sou, old_otd, fl, fl1, mas_pmt, k := 1
if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
                            input_otd(T_ROW-1,T_COL+5,sys_date) != NIL
  if yes_vypisan == B_END
    if (k := popup_prompt(T_ROW,T_COL+5,sk,;
              {"~Не закончившие лечение","~Закончившие лечение"})) > 0
      sk := k
    endif
  endif
  buf := box_shadow(0,41,2,77,color13)
  @ 1,42 say padc(glob_otd[2],35) color color14
  if k > 0 .and. ret_oms_human(yes_vypisan+k-1)
    rest_box(buf)
    buf := box_shadow(0,41,3,77,color13)
    @ 1,42 say padc(glob_otd[2],35) color color14
    @ 2,42 say padc(glob_k_fio,35) color color8
    sou := glob_otd[2]+" ["+glob_uch[2]+"]" ; old_otd := glob_otd[1]
    buf1 := box_shadow(0,0,3,35,color5)
    @ 1,1 say padc("Теперь выберите",34) color color5
    @ 2,1 say padc("новое отделение",34) color color5
    if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
                          input_otd(T_ROW-1,T_COL+5,sys_date) != NIL
      rest_box(buf1)
      if old_otd == glob_otd[1]
        fl := func_error(4,"Выбрано то же самое отделение!")
      else
        buf2 := savescreen()
        f_message({"Старое отделение:",;
                   sou,;
                   "Новое отделение:",;
                   glob_otd[2]+" ["+glob_uch[2]+"]"},,"W+/W","N/W")
        if (fl := f_Esc_Enter("смены отделения",.t.))
          fl1 := .f.
          if input_value(maxrow()-4,10,maxrow()-2,69,color1,;
              "   Перезаписывать новое отделение в каждой услуге",0,mm_danet) == 1
            fl1 := .t.
          endif
        endif
        restscreen(buf2)
      endif
      if fl
        str_sem := "Редактирование человека "+lstr(glob_perso)
        if G_SLock(str_sem)
          use_base("human")
          set order to 0
          goto (glob_perso)
          k := human->ishod
          G_RLock(forever)
          human->LPU := glob_uch[1] // код учреждения
          human->OTD := glob_otd[1] // код отделения
          if fl1
            Use_base("mo_hu")
            find (str(glob_perso,7))
            do while mohu->kod == glob_perso .and. !eof()
              G_RLock(forever)
              mohu->otd := glob_otd[1] // код отделения
              skip
            enddo
            Use_base("human_u")
            find (str(glob_perso,7))
            do while hu->kod == glob_perso .and. !eof()
              G_RLock(forever)
              hu->otd := glob_otd[1] // код отделения
              skip
            enddo
          endif
          close databases
          func_error(2,"Смена отделения завершена!")
          if eq_any(k,88,89)
            func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
          else
            @ 1,42 say padc(glob_otd[2],35) color color14
            mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг"}
            if glob_otd[3] == 4 .or. glob_otd[4] > 0
              si := 1
              asize(mas_pmt,1)
            endif
            do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
              if (si := i) == 1
                oms_sluch(glob_perso,glob_kartotek)
              else
                oms_usl_sluch(glob_perso,glob_kartotek)
              endif
            enddo
          endif
          G_SUnLock(str_sem)
        else
          func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
        endif
      endif
    endif
    if buf1 != NIL ; rest_box(buf1) ; endif
  endif
  if buf != NIL ; rest_box(buf) ; endif
endif
return NIL

***** 05.02.19 Удаление листка учета лечения больного
Function oms_del()
Static sk := 1
Local buf, str_sem, j, k := 1, arr_m, fl := .t., lkod_k, lyear
if tip_polzovat != 0
  return func_error(4,err_admin)
endif
if (arr_m := input_year()) != NIL .and. ;
     input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
          iif(yes_h_otd==1, input_otd(T_ROW-1,T_COL+5,sys_date)!=NIL, .t.)
  if yes_vypisan == B_END
    if (k := popup_prompt(T_ROW,T_COL+5,sk,;
              {"~Не закончившие лечение","~Закончившие лечение"})) > 0
      sk := k
    endif
  endif
  if yes_h_otd == 1
    buf := box_shadow(0,41,2,77,color13)
    @ 1,42 say padc(glob_otd[2],35) color color14
  endif
  if k > 0 .and. ret_oms_human(yes_vypisan+k-1,arr_m) .and. f_Esc_Enter(2,.t.)
    str_sem := "Редактирование человека "+lstr(glob_perso)
    if G_SLock(str_sem)
      G_Use(dir_server+"mo_pp",dir_server+"mo_pp_h","PP")
      use_base("mo_hdisp")
      Use_base("mo_hu")
      Use_base("human_u")
      Use_base("human")
      find (str(glob_perso,7))
      if fl .and. eq_any(human->ishod,88,89)
        fl := func_error(10,"Данный случай - часть двойного случая. Удаление запрещено!")
      endif
      if fl .and. human_->KOD_UP > 0
        fl := func_error(10,"Данный случай выставлен повторно (по акту снятия). Удаление запрещено!")
      endif
      if fl .and. human->ishod == 201 // диспансеризация I этап
        lkod_k := human->kod_k
        lyear := year(human->k_data)
        set order to 2
        find (str(lkod_k,7))
        do while human->kod_k == lkod_k .and. !eof()
          if human->ishod == 202 .and. year(human->k_data) == lyear
            fl := func_error(10,"Это I этап диспансеризации, но присутствует II этап. Удаление запрещено!")
            exit
          endif
          skip
        enddo
        set order to 1
        find (str(glob_perso,7))
      endif
      if fl
        flag_pp := .f.
        select PP // приемный покой
        find (str(glob_perso,7))
        if found() .and. human->kod_k == pp->kod_k // тот же пациент
          G_RLock(forever)
          pp->K_DATA := ctod("")  // дата окончания лечения
          pp->K_TIME := ""        // время выписки
          flag_pp := .t.
        endif
        j := 0
        do while .t.
          select HDISP
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        do while .t.
          select MOHU
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.,.f.)  // без пометки на удаление
          ++j
        enddo
        do while .t.
          select HU
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          //
          select HU_
          DeleteRec(.t.,.f.)
          select HU
          DeleteRec(.t.,.f.)  // без пометки на удаление
          ++j
        enddo
        select HUMAN_2
        DeleteRec(.t.,.f.)
        select HUMAN_
        DeleteRec(.t.,.f.)
        select HUMAN
        DeleteRec(.t.,.f.)  // без пометки на удаление
        G_RLock(forever)
        replace human->schet with -1  // (вместо нуля)
        // удаляем онкологию
        G_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","NAPR") // онконаправления
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","SL")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","DI")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","PR")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkus",dir_server+"mo_onkus","US")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkco",dir_server+"mo_onkco","CO")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkle",dir_server+"mo_onkle","LE")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        close databases
        write_work_oper(glob_task,OPER_USL,3,j)
        write_work_oper(glob_task,OPER_LIST,3)
        stat_msg("Лист учёта удалён.") ; mybell(2,OK)
        if flag_pp
          stat_msg("Не забудьте удалить историю болезни в подзадаче ПРИЁМНЫЙ ПОКОЙ") ; mybell(10,OK)
        endif
      else
        close databases
      endif
      G_SUnLock(str_sem)
    else
      func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
    endif
  endif
  if buf != NIL ; rest_box(buf) ; endif
endif
return NIL

***** Режимы работы с завершением лечения
Function oms_zav_lech(k)
Static sk := 1, str_sem := "Завершение лечения"
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"Завершение лечения для ~одного больного",;
                "Завершение лечения для ~всех",;
                "~Убрать у больного отметку о завершении лечения"}
    mas_msg := {"Завершение лечения для одного больного",;
                "Завершение лечения для всех",;
                "Убрать у больного отметку о завершении лечения"}
    mas_fun := {"oms_zav_lech(1)",;
                "oms_zav_lech(2)",;
                "oms_zav_lech(3)"}
    if G_SLock(str_sem)
      popup_prompt(T_ROW-len(mas_pmt)-3,T_COL+5,sk,mas_pmt,mas_msg,mas_fun)
      G_SUnLock(str_sem)
    else
      func_error(4,err_slock)
    endif
  case k == 1
    f1oms_zav_lech(1)
  case k == 2
    f1oms_zav_lech(2)
  case k == 3
    f1oms_zav_lech(3)
endcase
if k > 0
  sk := k
endif
return NIL

*****
Function f1oms_zav_lech(k)
Local buf, str_sem, k1, k2, tmp_color, dbf_tmp, r := 8, mtitul
if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
          iif(yes_h_otd==1, input_otd(T_ROW-1,T_COL+5,sys_date)!=NIL, .t.)
  if k == 1 .or. k == 3  // один человек из отделения
    if ret_oms_human(iif(k==1,B_END,B_STANDART))
      str_sem := "Редактирование человека "+lstr(glob_perso)
      if !G_SLock(str_sem)
        return func_error(4,err_slock)
      endif
      tmp_color := setcolor(color1) ; buf := savescreen()
      box_shadow(r,10,r+7,69,color1,;
             if(k==1,"Завершение лечения",;
                     "Убираем отметку о завершении лечения"),"W/B")
      Use_base("human")
      goto (glob_perso)
      @ r+2,12 say "Ф.И.О. "
      @ row(),col() say human->fio color cDataCSay
      @ r+3,12 say "Дата начала лечения "
      @ row(),col() say full_date(human->n_data) color cDataCSay
      @ r+4,12 say "Дата окончания лечения "
      @ row(),col() say full_date(human->k_data) color cDataCSay
      @ r+5,12 say "Сумма лечения "
      @ row(),col() say lstr(human->cena_1,12,2) color cDataCSay
      if f_Esc_Enter(1) .and. G_RLock(forever)
        human->TIP_H := if(k == 3, B_END, B_STANDART)
        stat_msg(if(k == 1, "Лечение завершено", "Убрана отметка о завершении лечения")+"!")
        mybell(0.5,OK)
      endif
      close databases
      G_SUnLock(str_sem)
      restscreen(buf)
      setcolor(tmp_color)
    endif
  elseif k == 2  // целое отделение/учреждение
    dbf_tmp := {;
       {"KOD"      ,   "N",     7,     0},;
       {"N_DATA"   ,   "D",     8,     0},; // дата начала лечения
       {"K_DATA"   ,   "D",     8,     0},; // дата окончания лечения
       {"FIO"      ,   "C",    50,     0},; // Ф.И.О. больного
       {"CENA"     ,   "N",    12,     2},; // стоимость лечения
       {"PLUS"     ,   "L",     1,     0}}  // включается ли в счет
    buf := save_maxrow()
    mywait()
    dbcreate(cur_dir+"tmp",dbf_tmp)
    k1 := k2 := 0
    Use (cur_dir+"tmp") alias TMP
    R_Use(dir_server+"human",dir_server+"humann","HUMAN")
    find (str(B_END,1))
    do while human->tip_h == B_END .and. !eof()
      if iif(yes_h_otd==1, human->otd == glob_otd[1], .t.)
        k1++
        select TMP
        append blank
        replace tmp->KOD    with human->KOD ,;
                tmp->n_data with human->n_data,;
                tmp->k_data with human->k_data,;
                tmp->FIO    with human->FIO ,;
                tmp->CENA   with human->CENA_1,;
                tmp->PLUS   with .t.
        if k1 == 9999
          exit
        endif
      endif
      select HUMAN
      skip
    enddo
    close databases
    rest_box(buf)
    if k1 == 0
      func_error(4,"Нет больных, не закончивших лечение!")
    else
      buf := savescreen()
      Private old_summa := ob_summa := 0, old_kol := ob_kol := k1, regim_t := 3
      Private p_blk := {|mkol,msum| .t. }
      mtitul := alltrim(glob_uch[2])
      if yes_h_otd == 1
        mtitul += " [ "+alltrim(glob_otd[2])+" ]"
      endif
      Use (cur_dir+"tmp") alias TMP
      index on upper(fio) to (cur_dir+"tmp_hum")
      if Alpha_Browse(T_ROW,0,maxrow()-4,79,"f2oms_zav_lech",color1,;
                      mtitul,"G+/B",.t.,.t.,,,"f3oms_zav_lech",,;
                      {'═','░','═',"W+/B,BG+/R,GR+/B,GR+/R",,300} )
        if ob_kol > 0 .and. f_Esc_Enter("завершения лечения") .and. Use_base("human")
          mywait()
          select TMP
          go top
          do while !eof()
            if tmp->plus
              str_sem := "Редактирование человека "+lstr(tmp->kod)
              if G_SLock(str_sem) // если человек не заблокирован
                select HUMAN
                find (str(tmp->kod,7))
                if found() .and. G_RLock(forever)
                  human->TIP_H := B_STANDART
                  UnLock
                endif
                G_SUnLock(str_sem)
              else
                k2++
              endif
            endif
            select TMP
            skip
          enddo
          close databases
          stat_msg("Лечение завершено!" + if(k2 == 0, "", ;
                               " ("+lstr(k2)+" чел. были заблокированы)") )
          mybell(0.5,OK)
        endif
      endif
      restscreen(buf)
    endif
  endif
endif
close databases
return NIL

*****
Function f2oms_zav_lech(oBrow)
Local oColumn, tmp_color, blk_color := {|| if(tmp->plus, {3,4}, {1,2}) }, s1, s2, s3, n := 46
oColumn := TBColumnNew(" ", {|| if(tmp->plus," ","  ") })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(center("Ф.И.О. больного",n), {|| padr(tmp->fio,n) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Окончан.;лечения", {|| tmp->k_data })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("    Сумма", {|| padl(expand_value(tmp->cena,2),14) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" ", {|| if(tmp->plus," ","  ") })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
tmp_color := setcolor("N/W")
s1 := "завершения лечения"
s2 := "все завершили лечение"
s3 := "все не завершили лечение"
@ maxrow()-3,0 say padr(" <Esc> - выход без изменений;    <Enter> - подтверждение "+s1,80)
@ maxrow()-2,0 say padr(" <Ins> - отметить одного больного или снять отметку с одного больного",80)
@ maxrow()-1,0 say padr(" <+> - отметить всех больных (все завершили лечение)    <F8> - удаление по дате",80)
@ maxrow()-0,0 say padr(" <-> - снять отметку со всех больных (все не завершили лечение)   <F9> - печать",80)
mark_keys({s1},"R/W")
mark_keys({"<Esc>","<Enter>","<Ins>","<+>","<->","<F8>","<F9>"},"B/W")
setcolor(tmp_color)
return NIL

*****
Function f3oms_zav_lech(nKey,oBrow)
Local buf, rec, k := -1, sh, HH, n_file, s, mdate, j
do case
  case nkey == K_F8
    mdate := input_value(21,1,23,78,"W+/N,N/W",;
          space(7)+"Введите дату, ранее которой не завершено лечение",;
           sys_date-30)
    if mdate != NIL .and. f_Esc_Enter("удаления") .and. ;
       f_alert({'После подтверждения данного режима будут удалены',;
                "все листки учета с незавершенным лечением, у которых",;
                "проставлена дата ранее "+date_month(mdate,.t.),;
                "Выберите действие"},;
               {" ~Отказ "," Подтвердить ~удаление "},;
               1,"N+/BG","R/BG",16,,col1menu ) == 2
      buf := save_maxrow()
      mywait()
      j := 0
      Use_base("mo_hu")
      Use_base("human_u")
      Use_base("human")
      select TMP
      go top
      do while !eof()
        if tmp->k_data <= mdate
          ++j
          do while .t.
            select HU
            find (str(tmp->kod,7))
            if !found() ; exit ; endif
            //
            select HU_
            DeleteRec(.t.,.f.)
            select HU
            DeleteRec(.t.,.f.)  // без пометки на удаление
          enddo
          do while .t.
            select MOHU
            find (str(tmp->kod,7))
            if !found() ; exit ; endif
            DeleteRec(.t.,.f.)  // без пометки на удаление
          enddo
          select HUMAN
          goto (tmp->kod)
          select HUMAN_
          DeleteRec(.t.,.f.)
          select HUMAN
          DeleteRec(.t.,.f.)  // без пометки на удаление
          G_RLock(forever)
          replace human->schet with -1  // (вместо нуля)
          UnLock
        endif
        select TMP
        skip
      enddo
      close databases
      stat_msg("Всего удалено листов учета - "+lstr(j)) ; mybell(2,OK)
      Use (cur_dir+"tmp") alias TMP
      rest_box(buf)
      k := 0
      keyboard chr(K_ESC)
    endif
  case nkey == K_F9
    mdate := input_value(21,1,23,78,color1,;
          space(7)+"Введите дату, ранее которой не завершено лечение",;
           sys_date-10)
    if mdate != NIL .and. f_Esc_Enter("печати")
      buf := save_maxrow()
      mywait()
      rec := recno()
      R_Use(dir_server+"human_u",dir_server+"human_u","HU")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"uslugi",,"USL")
      R_Use(dir_server+"mo_pers",,"PERSO")
      arr_title := {;
       "────────────────────────────────────────────────┬────────────────┬──────────────",;
       "               Ф.И.О.                           │ Сроки лечения  │    Сумма     ",;
       "────────────────────────────────────────────────┴────────────────┴──────────────"}
      n_file := "z_lech"+stxt ; sh := 80 ; HH := 57
      fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
      add_string("")
      add_string(center("Больные, не завершившие лечение",sh))
      add_string(center("до "+date_month(mdate,.t.),sh))
      add_string("")
      aeval(arr_title, {|x| add_string(x) } )
      select TMP
      go top
      do while !eof()
        if tmp->k_data <= mdate
          if verify_FF(HH, .t., sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(padr(tmp->fio,49)+;
                     left(dtoc(tmp->n_data),5)+'-'+dtoc(tmp->k_data)+;
                     put_kopE(tmp->cena,13))
          select HUMAN_
          goto (tmp->kod)
          if !eof() .and. human_->vrach > 0
            select PERSO
            goto (human_->vrach)
            if !eof()
              s := space(10)+"Леч.врач: ["+lstr(perso->tab_nom)
              add_string(s+"]  "+alltrim(perso->fio))
            endif
          endif
          arr_usl := {}
          select HU
          find (str(tmp->kod,7))
          do while hu->kod == tmp->kod
            usl->(dbGoto(hu->u_kod))
            if ascan(arr_usl,usl->shifr) == 0
              aadd(arr_usl,usl->shifr)
            endif
            select HU
            skip
          enddo
          if len(arr_usl) > 0
            asort(arr_usl,,,{|x,y| fsort_usl(x) < fsort_usl(y) } )
            s := "Услуги: "
            for j := 1 to len(arr_usl)
              s += alltrim(arr_usl[j])
              if j < len(arr_usl)
                s += ", "
              endif
            next
            for j := 1 to perenos(arr_usl,s,sh-10)
              add_string(space(10)+arr_usl[j])
            next
          endif
        endif
        select TMP
        skip
      enddo
      hu->(dbCloseArea())
      usl->(dbCloseArea())
      human_->(dbCloseArea())
      perso->(dbCloseArea())
      select TMP
      goto (rec)
      fclose(fp)
      rest_box(buf)
      viewtext(n_file,,,,,,,2)
    endif
  case nkey == K_INS
    replace tmp->plus with !tmp->plus
    if tmp->plus
      ob_summa += tmp->cena ; ob_kol++
    else
      ob_summa -= tmp->cena ; ob_kol--
    endif
    eval(p_blk,ob_kol,ob_summa)
    k := 0
    keyboard chr(K_TAB)
  case nkey == 43 .or. nkey == 45  // + или -
    fl := (nkey == 43)
    rec := recno()
    buf := save_maxrow()
    mywait()
    tmp->(dbeval({|| tmp->plus := fl}))
    goto (rec)
    rest_box(buf)
    if fl
      ob_summa := old_summa ; ob_kol := tmp->(lastrec())
    else
      ob_summa := ob_kol := 0
    endif
    eval(p_blk,ob_kol,ob_summa)
    k := 0
endcase
return k

***** поиск больного
Function ret_oms_human(dostup,arr_m)
//  dostup = B_END      = 2 - больные выписались из данного отделения
//  dostup = B_STANDART = 3 - проверен стандарт лечения и не включен в реестр
//  dostup = B_SCHET    = 4 - выписан счет
//  dostup = B_OPL      = 5 - оплачен счет
//  dostup = B_NE_OPL   = 6 - больной по какой-то причине не оплачивается
Local buf := savescreen(), mkod := 0, k, fl := .f., mtitul := ""
mywait()
Private mr1 := T_ROW, str_find, regim_vyb := 1
str_error := "В данный момент"
if dostup == NIL
  str_find := dtos(arr_m[5])
  mtitul := 'По дате окончания лечения "'+arr_m[4]+'"'
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_, to otd into OTD
  dbseek(str_find,.t.)
  index on upper(fio) to (cur_dir+"tmp_hum") ;
        while human->k_data <= arr_m[6] ;
        for schet < 1 .and. human_->reestr==0
  str_error += " нет пациентов с датой окончания "+arr_m[4]
else
  mtitul := alltrim(glob_uch[2])
  str_find := str(dostup,1)
  if yes_h_otd == 1
    mtitul += " [ "+alltrim(glob_otd[2])+" ]"
    str_error += " в данном отделении"
    str_find += str(glob_otd[1],3)
  endif
  str_error += " нет пациентов"
  if dostup == B_STANDART
    str_error += ", закончивших лечение"
  else
    str_error += ", не закончивших лечение"
  endif
  if arr_m != NIL
    str_error += " "+arr_m[4]
    mtitul += " "+arr_m[4]
  endif
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humann","HUMAN")
  set relation to recno() into HUMAN_, to otd into OTD
  find (str_find)
  if yes_h_otd == 1
    if dostup == B_STANDART
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h==dostup .and. otd==glob_otd[1] ;
            for iif(arr_m==NIL, .t., between(k_data,arr_m[5],arr_m[6])) .and. human_->reestr==0
    else
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h==dostup .and. otd==glob_otd[1] ;
            for iif(arr_m==NIL, .t., between(k_data,arr_m[5],arr_m[6]))
    endif
  else
    if dostup == B_STANDART
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h==dostup ;
            for lpu==glob_uch[1] .and. iif(arr_m==NIL, .t., between(k_data,arr_m[5],arr_m[6])) ;
                                 .and. human_->reestr==0

    else
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h==dostup ;
            for lpu==glob_uch[1] .and. iif(arr_m==NIL, .t., between(k_data,arr_m[5],arr_m[6]))
    endif
  endif
endif
go top
if eof()
  close databases
  restscreen(buf)
  str_error += "!"
  return func_error(4,str_error)
endif
if glob_perso > 0
  Locate for human->kod == glob_perso
  if !found()
    go top
  endif
endif
if Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1ret_oms_human",color0,mtitul,'B/BG',,;
                               .t.,,,"f2ret_oms_human",,;
                               {'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
  if (glob_perso := human->kod) == 0
    func_error(4,"Не найдено нужных записей!")
  else
    mkod := glob_perso
    glob_kartotek := human->kod_k
    glob_k_fio := fio_plus_novor()
    glob_otd[1] := human->otd
    glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
    if len(glob_otd) == 2
      aadd(glob_otd,human_->usl_ok)
    else
      glob_otd[3] := human_->usl_ok
    endif
    k := ret_tip_lu()
    if len(glob_otd) == 3
      aadd(glob_otd,k)
    else
      glob_otd[4] := k
    endif
    glob_uch[1] := human->LPU
    glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
    fl_schet := (human->schet > 0)
  endif
  close databases
endif
close databases
restscreen(buf)
return (mkod > 0)

***** 09.09.18
Function f1ret_oms_human(oBrow)
Local oColumn, blk, r := 34
blk := {|| iif(human_->KOD_UP > 0, {3,4}, iif(human_->OPLATA == 2, {5,6},{1,2})) }
if yes_h_otd == 1
  r += 6
endif
oColumn := TBColumnNew(padc("ФИО пациента",r),{|| padr(fio_plus_novor(),r)})
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if yes_h_otd == 2
  oColumn := TBColumnNew("Отд-е", {|| otd->short_name })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew("Осн.;диаг.", {|| human->kod_diag })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Нача-; ло", {|| left(dtoc(human->n_data),5) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Оконч-ие;лечения", {|| date_8(human->k_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Стоимость;  лечения", {|| put_kopE(human->cena_1,10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if tip_polzovat == TIP_ADM
  s := "^<Esc>^ выход  ^<Enter>^ выбор  ^<F2>^ поиск"
  if type("p_del_error") == "A" .and. p_del_error[2] > 0
    s += "  ^<Ctrl+F12>^ снятие флага об ошибке у всех"
  endif
  status_key(s)
else
  status_key("^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск")
endif
return NIL

***** 05.12.19
Function f2ret_oms_human(nkey)
Static tmp := " "
Local buf := savescreen(), buf1, rec1 := recno(), fl := -1, ss := 0, ;
      j, n_file := "omserror"+stxt, sh := 80, HH := 60
Private tmp1
if type("p_del_error") == "A" .and. p_del_error[2] > 0
  if nkey == K_F9
    mywait()
    fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
    add_string("")
    add_string(center("Список случаев, возвращённых ТФОМС с ошибкой",sh))
    add_string(center(p_del_error[1],sh))
    add_string(center(arr_m[4],sh))
    j := 0
    go top
    do while !eof()
      verify_FF(HH-3,.f.,sh)
      add_string("")
      ++j
      add_string(padr(lstr(j)+".",6)+alltrim(human->fio)+", д.р."+full_date(human->date_r)+",")
      if otd->IDUMP == 4
        add_string(space(6)+"карта вызова № "+alltrim(human->uch_doc)+;
                            ", дата выезда "+date_8(human->k_data))
      else
        add_string(space(6)+"лечение с "+date_8(human->n_data)+" по "+date_8(human->k_data)+;
                            ", стоимость "+lstr(human->cena_1,11,2)+"р.")
      endif
      ss += human->cena_1
      skip
    enddo
    goto rec1
    add_string("")
    add_string("Итого стоимость всех случаев "+lstr(ss,15,2)+"р.")
    fclose(fp)
    restscreen(buf)
    viewtext(n_file,,,,(sh>80),,,2)
    return -1
  elseif eq_any(nkey,K_F12,K_CTRL_F12) .and. tip_polzovat == TIP_ADM .and. f_Esc_Enter("снятия флага об ошибке",.t.)
     /*involved_password(1,p_del_error[2],"снятия со всех пациентов флага об ошибке") ;
         .and. f_alert({padc("Выберите действие",60,".")},;
                       {" Отказ "," Снять флаг об ошибке со всех пациентов "},;
                       1,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" ) == 2*/
    go top
    do while !eof()
      human_->(G_RLock(forever))
      human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      skip
    enddo
    goto rec1
    stat_msg('Флаг об ошибке '+lstr(p_del_error[2])+' снят со всех пациентов. Войдите в режим "Реестры/Проверка"')
    mybell(4,OK)
    restscreen(buf)
    return 0
  endif
endif
if nkey != K_F2
  return -1
endif
buf1 := savescreen(13,4,19,77)
do while .t.
  tmp1 := padr(tmp,50)
  setcolor(color8)
  box_shadow(13,14,18,67)
  @ 15,15 say center(" Введите шаблон для поиска фамилий",52)
  status_key("^<Esc>^ - отказ от ввода;  ^<F1>^ - помощь")
  @ 16,16 get tmp1 picture "@K@!"
  myread()
  setcolor(color0)
  if lastkey() == K_ESC .or. empty(tmp1)
    exit
  endif
  mywait()
  tmp := alltrim(tmp1)
  Private tmp_mas := {}, tmp_kod := {}, i := 0, t_len, k1 := mr1+3, ;
          k2 := 21, tmp2 := upper(tmp), ch := left(tmp,1)
  if !("*" $ tmp2)
    tmp2 := "*"+tmp2+"*"
  endif
  ch := left(tmp2,1)
  if !(ch == "*" .or. ch == "?")
    tmp1 := tmp2
    if "*" $ tmp1 ; tmp1 := beforatnum("*",tmp1,1) ; endif
    if "?" $ tmp1 ; tmp1 := beforatnum("?",tmp1,1) ; endif
    ch := len(tmp1)
    find (tmp1)
    do while tmp1 == left(upper(human->fio),ch) .and. !eof()
      if like(tmp2,upper(human->fio))
        if ++i > 4000 ; exit ; endif
        aadd(tmp_mas,fio_plus_novor()) ; aadd(tmp_kod,human->kod)
      endif
      skip
    enddo
  else
    go top
    do while !eof()
      if like(tmp2,upper(human->fio))
        if ++i > 4000 ; exit ; endif
        aadd(tmp_mas,fio_plus_novor()) ; aadd(tmp_kod,human->kod)
      endif
      skip
    enddo
  endif
  if (t_len := len(tmp_kod)) = 0
    stat_msg("Не найдено ни одной записи, удовлетворяющей данному шаблону!")
    mybell(2,ERR)
    restscreen(13,4,19,77,buf1)
    loop
  else
    box_shadow(mr1,2,22,77)
    SETCOLOR(col_tit_popup)
    @ k1-2,15 say "Шаблон: "+tmp2
    SETCOLOR(color0)
    if k1+t_len+2 < 21
      k2 := k1 + t_len + 2
    endif
    @ k1,3 say center(" Количество найденных фамилий - "+lstr(t_len),74)
    i := ascan(tmp_kod, glob_perso)
    status_key("^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор")
    if (i := popup(k1+1,13,k2,66,tmp_mas,i,color0)) > 0
      if regim_vyb == 1
        goto (tmp_kod[i])
      else
        select TMP_H
        go top
        Locate for kod == tmp_kod[i]
      endif
      fl := 0
    endif
    exit
  endif
enddo
if fl == -1
  goto rec1
endif
restscreen(buf)
return fl

***** 05.03.13
Function f21ret_oms_human()
Local s, r := row(), c := col()
s := "Полис ОМС: "+;
     alltrim(rtrim(human_->SPOLIS)+" "+human_->NPOLIS)+" ("+;
     alltrim(inieditspr(A__MENUVERT, mm_vid_polis, human_->VPOLIS))+")"
@ maxrow()-2,3 say padc(s,74) color color0
setpos(r,c)
return NIL

***** 09.02.14 ФИО пациента + если есть, номер новорожденного ребёнка
Function fio_plus_novor()
return alltrim(human->fio)+;
       iif(human_->NOVOR==0,""," ("+lstr(human_->NOVOR)+"-й реб.)")
