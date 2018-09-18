***** mo_oms1.prg - режимы ввода данных для задачи ОМС (продолжение)
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 03.09.18 ПН - добавление или редактирование случая (листа учета)
Function oms_sluch_PN(Loc_kod,kod_kartotek,f_print)
// Loc_kod - код по БД human.dbf (если = 0 - добавление листа учета)
// kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
// f_print - наименование функции для печати
Static st_N_DATA, st_K_DATA, st_mo_pr := '      '
Local L_BEGIN_RSLT := 331
Local bg := {|o,k| get_MKB10(o,k,.t.) }, arr_del := {}, mrec_hu := 0,;
      buf := savescreen(), tmp_color := setcolor(), a_smert := {},;
      p_uch_doc := "@!", pic_diag := "@K@!", arr_usl := {},;
      i, j, k, n, s, s1, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod,;
      tmp_help := chm_help_code, fl_write_sluch := .f., _y, _m, _d, t_arr[2],;
      arr_prof := {}, is_3_5_4 := .f.
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
Private mfio := space(50), mpol, mdate_r, madres, mvozrast, mdvozrast, msvozrast := " ",;
  M1VZROS_REB, MVZROS_REB, m1novor := 0,;
  m1company := 0, mcompany, mm_company,;
  mkomu, M1KOMU := 0, M1STR_CRB := 0,; // 0-ОМС,1-компании,3-комитеты/ЛПУ,5-личный счет
  msmo := "34007", rec_inogSMO := 0,;
  mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100),;
  mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20)
Private mkod := Loc_kod, mtip_h, is_talon := .f.,;
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
  m1rslt  := L_BEGIN_RSLT+1 ,; // результат (присвоена I группа здоровья)
  m1ishod := 306      ,; // исход = осмотр
  MN_DATA := st_N_DATA         ,; // дата начала лечения
  MK_DATA := st_K_DATA         ,; // дата окончания лечения
  MVRACH := space(10)         ,; // фамилия и инициалы лечащего врача
  M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0,; // код, таб.№ и спец-ть лечащего врача
  m1povod  := 4,;   // Профилактический
  m1travma := 0, ;
  m1USL_OK :=  3,; // поликлиника
  m1VIDPOM :=  1,; // первичная
  m1PROFIL := 68,; // педиатрия
  m1IDSP   := 17   // законченный случай в п-ке
//
Private mm_kateg_uch := {{"ребенок-сирота",0},;
                         {"ребенок, оставшийся без попечения родителей",1},;
                         {"ребенок, находящийся в трудной жизненной ситуации",2},;
                         {"нет категории",3}}
Private mm_mesto_prov := {{"медицинская организация",0},;
                          {"общеобразовательное учреждение",1}}
Private mm_fiz_razv := {{"нормальное",0},;
                        {"с отклонениями",1}}
Private mm_fiz_razv1 := {{"нет    ",0},;
                         {"дефицит",1},;
                         {"избыток",2}}
Private mm_fiz_razv2 := {{"нет    ",0},;
                         {"низкий ",1},;
                         {"высокий",2}}
Private mm_psih2 := {{"норма",0},{"нарушения",1}}
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
Private mm_gr_fiz_do := {{"I",1},{"II",2},{"III",3},{"IV",4}}
Private mm_gr_fiz := aclone(mm_gr_fiz_do)
aadd(mm_gr_fiz_do,{"отсутствует",0})
aadd(mm_gr_fiz,{"не допущен",0})
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
Private metap := 1, mperiod := 0, mshifr_zs := "",;
        mkateg_uch, m1kateg_uch := 3,; // Категория учета ребенка:
        mmesto_prov := space(10), m1mesto_prov := 0,; // место проведения
        mMO_PR := space(10), m1MO_PR := st_mo_pr,; // код МО прикрепления
        mschool := space(10), m1school := 0,; // код обр.учреждения
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
        mdiag_15_1, m1diag_15_1 := 1,; // Состояние здоровья до проведения профосмотра-Практически здоров
        mdiag_15[5,14],; //
        mGRUPPA_DO := 0,; // группа здоровья до дисп-ии
        mGR_FIZ_DO, m1GR_FIZ_DO := 1,;
        mdiag_16_1, m1diag_16_1 := 1,; // Состояние здоровья по результатам проведения профосмотра (Практически здоров)
        mdiag_16[5,16],; //
        minvalid[8],;  // раздел 16.7
        mGRUPPA := 0,;    // группа здоровья после дисп-ии
        mGR_FIZ, m1GR_FIZ := 1,;
        mPRIVIVKI[3],; // Проведение профилактических прививок
        mrek_form := space(255),; // "C100",Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой
        mrek_disp := space(255),; // "C100",Рекомендации по диспансерному наблюдению, лечению, медицинской реабилитации и санаторно-курортному лечению с указанием диагноза (код МКБ), вида медицинской организации и специальности (должности) врача
        mhormon := "0 шт.", m1hormon := 1, not_hormon,;
        mm_step2 := {{"нет  ",0},{"да   ",1},{"ОТКАЗ",2}}, ;
        mstep2, m1step2 := 0, m1p_otk := 0, musl2 := "нет", m1usl2 := 0
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
Private mvar, m1var, m1lis := 0
Private mDS_ONK, m1DS_ONK := 0 // Признак подозрения на злокачественное новообразование
Private mnapr_stac, m1napr_stac := 0, ;
        mm_napr_stac := {{"--- нет ---",0},{"в стационар",1},{"в дн. стац.",2}}, ;
        mprofil_stac, m1profil_stac := 0
Private mnapr_reab, m1napr_reab := 0, mprofil_kojki, m1profil_kojki := 0, arr_usl_otkaz := {}   
Private mm_otkaz := {{"выпол.",0},{"ОТКАЗ ",1}}, is_neonat := .f.
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
for i := 1 to count_pn_arr_iss // исследования
  mvar := "MTAB_NOMiv"+lstr(i)
  Private &mvar := 0
  mvar := "MTAB_NOMia"+lstr(i)
  Private &mvar := 0
  mvar := "MDATEi"+lstr(i)
  Private &mvar := ctod("")
  mvar := "MREZi"+lstr(i)
  Private &mvar := space(17)
  mvar := "MOTKAZi"+lstr(i)
  Private &mvar := mm_otkaz[1,1]
  mvar := "M1OTKAZi"+lstr(i)
  Private &mvar := mm_otkaz[1,2]
  m1var := "M1LIS"+lstr(i)
  Private &m1var := 0
  mvar := "MLIS"+lstr(i)
  Private &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
next
for i := 1 to count_pn_arr_osm // осмотры
  mvar := "MTAB_NOMov"+lstr(i)
  Private &mvar := 0
  mvar := "MTAB_NOMoa"+lstr(i)
  Private &mvar := 0
  mvar := "MDATEo"+lstr(i)
  Private &mvar := ctod("")
  mvar := "MKOD_DIAGo"+lstr(i)
  Private &mvar := space(6)
  mvar := "MOTKAZo"+lstr(i)
  Private &mvar := mm_otkaz[1,1]
  mvar := "M1OTKAZo"+lstr(i)
  Private &mvar := mm_otkaz[1,2]
next
for i := 1 to 2                // педиатр(ы)
  mvar := "MTAB_NOMpv"+lstr(i)
  Private &mvar := 0
  mvar := "MTAB_NOMpa"+lstr(i)
  Private &mvar := 0
  mvar := "MDATEp"+lstr(i)
  Private &mvar := ctod("")
  mvar := "MKOD_DIAGp"+lstr(i)
  Private &mvar := space(6)
  mvar := "MOTKAZp"+lstr(i)
  Private &mvar := mm_otkaz[1,1]
  mvar := "M1OTKAZp"+lstr(i)
  Private &mvar := mm_otkaz[1,2]
next
//
afill(adiag_talon,0)
//
dbcreate(cur_dir+"tmp", {;
   {"U_KOD"  ,    "N",      4,      0},;  // код услуги
   {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
   {"U_NAME",     "C",     65,      0} ;  // наименование услуги
  })
use (cur_dir+"tmp")
index on str(u_kod,4) to (cur_dir+"tmpk")
index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
set index to (cur_dir+"tmpk"),(cur_dir+"tmpn") 
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
  m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
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
  // проверка исхода = СМЕРТЬ и поиск предыдущих профилактик
  select HUMAN
  set index to (dir_server+"humankk")
  find (str(mkod_k,7))
  do while human->kod_k == mkod_k .and. !eof()
    if recno() != Loc_kod .and. human_->oplata != 9 .and. human_->NOVOR == 0 .and. year(human->k_data) > 2017
      if is_death(human_->RSLT_NEW)
        a_smert := {"Данный больной умер!",;
                    "Лечение с "+full_date(human->N_DATA)+;
                          " по "+full_date(human->K_DATA)}
      endif
      if eq_any(human->ishod,301,302) // если профилактика несовершеннолетних
        read_arr_PN(human->kod,.f.) // читаем переменную "mperiod"
        _mperiod := mperiod
        if _mperiod > 0
          aadd(arr_prof, {_mperiod,human->n_data,human->k_data})
          if eq_any(_mperiod,1,2)
            R_Use(dir_server+"uslugi",,"USL")
            R_Use(dir_server+"human_u",dir_server+"human_u","HU")
            find (str(human->kod,7))
            do while hu->kod == human->kod .and. !eof()
              usl->(dbGoto(hu->u_kod))
              if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
                lshifr := usl->shifr
              endif
              if alltrim(lshifr) == "3.5.4" // Аудиологический скрининг
                is_3_5_4 := .t.
              endif
              select HU
              skip
            enddo
            hu->(dbCloseArea())
            usl->(dbCloseArea())
          endif
        endif
      endif
    endif
    select HUMAN
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
    adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
  next*/
  MPOLIS      := human->POLIS         // серия и номер страхового полиса
  m1VIDPOLIS  := human_->VPOLIS
  mSPOLIS     := human_->SPOLIS
  mNPOLIS     := human_->NPOLIS
  if human->OBRASHEN == '1'
    m1DS_ONK := 1
  endif
  if empty(val(msmo := human_->SMO))
    m1komu := human->KOMU
    m1str_crb := human->STR_CRB
  else
    m1komu := m1str_crb := 0
  endif
  m1okato    := human_->OKATO  // ОКАТО субъекта РФ территории страхования
  mn_data    := human->N_DATA
  mk_data    := human->K_DATA
  mcena_1    := human->CENA_1
  metap      := human->ishod-300
  mGRUPPA    := human_->RSLT_NEW-L_BEGIN_RSLT
  if metap == 2
    m1step2 := 1
  endif
  //
  larr_i := array(count_pn_arr_iss) ; afill(larr_i,0)
  larr_o := array(count_pn_arr_osm) ; afill(larr_o,0)
  larr_p := {}
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
    if left(lshifr,5) == "72.2."
      mshifr_zs := lshifr
    elseif hu->is_edit == -1
      select TMP
      append blank
      tmp->U_KOD := hu->u_kod
      tmp->U_SHIFR := usl->shifr
      tmp->U_NAME := usl->name
      ++m1usl2
    else
      fl := .t.
      for i := 1 to count_pn_arr_iss
        if np_arr_issled[i,1] == lshifr
          fl := .f. ; larr_i[i] := hu->(recno()) ; exit
        elseif (j := ascan(np_arr_not_zs,{|x| x[2] == lshifr })) > 0 .and. ;
                                        np_arr_issled[i,1] == np_arr_not_zs[j,1] 
          fl := .f. ; larr_i[i] := hu->(recno()) ; exit
        endif
      next
      if fl
        for i := 1 to count_pn_arr_osm
          if f_profil_ginek_otolar(np_arr_osmotr[i,4],hu_->PROFIL)
            fl := .f. ; larr_o[i] := hu->(recno())
            exit
          endif
        next
      endif
      if fl .and. eq_any(hu_->PROFIL,68,57)
        aadd(larr_p,{hu->(recno()),c4tod(hu->date_u)})
      endif
    endif
    aadd(arr_usl,hu->(recno()))
    select HU
    skip
  enddo
  if m1step2 == 1
    musl2 := "Кол-во услуг - "+lstr(m1usl2)
  else
    m1usl2 := 0
    select TMP
    zap
  endif
  if len(larr_p) > 1 // если осмотр педиатра I этапа позднее педиатра II этапа
    asort(larr_p,,,{|x,y| x[2] < y[2] } )
    if metap == 1
      asize(larr_p,1) // отрезать лишние приёмы
    else
      do while len(larr_p) > 2 // когда педиатр I этапа введён как две услуги (2.3.* и 2.91.*)
        hb_ADel(larr_p, 2, .t.) // т.е. оставляем первый м последний приём
      enddo
    endif
  endif
  R_Use(dir_server+"mo_pers",,"P2")
  for j := 1 to 3
    if j == 1
      _arr := larr_i ; bukva := "i"
    elseif j == 2
      _arr := larr_o ; bukva := "o"
    else
      _arr := larr_p ; bukva := "p"
    endif
    for i := 1 to len(_arr)
      k := iif(j == 3, _arr[i,1], _arr[i])
      if !empty(k)
        hu->(dbGoto(k))
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
          if glob_yes_kdp2[TIP_LU_PN] .and. ascan(glob_arr_usl_LIS,np_arr_issled[i,1]) > 0 ;
                                      .and. hu->is_edit == 1
            &m1var := 1
          endif
          mvar := "mlis"+lstr(i)
          &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
        elseif !empty(hu_->kod_diag) .and. !(left(hu_->kod_diag,1)=="Z")
          mvar := "MKOD_DIAG"+bukva+lstr(i)
          &mvar := hu_->kod_diag
        endif
        m1var := "M1OTKAZ"+bukva+lstr(i)
        &m1var := 0 // выполнено
        mvar := "MOTKAZ"+bukva+lstr(i)
        &mvar := inieditspr(A__MENUVERT, mm_otkaz, &m1var)
      endif
    next
  next
  read_arr_PN(Loc_kod)
  if metap == 1 .and. m1p_otk == 1 
    m1step2 := 2
  endif
  if valtype(arr_usl_otkaz) == "A"
    for j := 1 to len(arr_usl_otkaz)
      ar := arr_usl_otkaz[j]
      if valtype(ar) == "A" .and. len(ar) > 9 .and. valtype(ar[5]) == "C" .and. ;
                                                    valtype(ar[10]) == "C" .and. ar[10] $ "io"
        lshifr := alltrim(ar[5])
        bukva := ar[10]
        if (i := ascan(iif(bukva=="i",np_arr_issled,np_arr_osmotr), {|x| valtype(x[1])=="C" .and. x[1]==lshifr})) > 0
          if valtype(ar[1]) == "N" .and. ar[1] > 0
            p2->(dbGoto(ar[1]))
            mvar := "MTAB_NOM"+bukva+"v"+lstr(i)
            &mvar := p2->tab_nom
          endif
          if valtype(ar[3]) == "N" .and. ar[3] > 0
            p2->(dbGoto(ar[3]))
            mvar := "MTAB_NOM"+bukva+"a"+lstr(i)
            &mvar := p2->tab_nom
          endif
          mvar := "MDATE"+bukva+lstr(i)
          &mvar := mn_data
          if valtype(ar[9]) == "D"
            &mvar := ar[9]
          endif
          m1var := "M1OTKAZ"+bukva+lstr(i)
          &m1var := 1 // отказ
          mvar := "MOTKAZ"+bukva+lstr(i)
          &mvar := inieditspr(A__MENUVERT, mm_otkaz, &m1var)
        endif
      endif
    next
  endif
  if alltrim(msmo) == '34'
    mnameismo := ret_inogSMO_name(2,@rec_inogSMO,.t.) // открыть и закрыть
  endif
endif
if !(left(msmo,2) == '34') // не Волгоградская область
  m1ismo := msmo ; msmo := '34'
endif
close databases
is_talon := .t.
fv_date_r( iif(Loc_kod>0,mn_data,) )
MFIO_KART := _f_fio_kart()
mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
mlpu      := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
motd      := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
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
mmesto_prov := inieditspr(A__MENUVERT, mm_mesto_prov, m1mesto_prov) // место проведения
mmobilbr := inieditspr(A__MENUVERT, mm_danet, m1mobilbr)
mschool := inieditspr(A__POPUPMENU, dir_server+"mo_schoo", m1school)
mkateg_uch := inieditspr(A__MENUVERT, mm_kateg_uch, m1kateg_uch)
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
mstep2 := inieditspr(A__MENUVERT, mm_step2, m1step2)
minvalid1 := inieditspr(A__MENUVERT, mm_danet,    m1invalid1)
minvalid2 := inieditspr(A__MENUVERT, mm_invalid2, m1invalid2)
minvalid5 := inieditspr(A__MENUVERT, mm_invalid5, m1invalid5)
minvalid6 := inieditspr(A__MENUVERT, mm_invalid6, m1invalid6)
minvalid8 := inieditspr(A__MENUVERT, mm_invalid8, m1invalid8)
mprivivki1 := inieditspr(A__MENUVERT, mm_privivki1, m1privivki1)
mprivivki2 := inieditspr(A__MENUVERT, mm_privivki2, m1privivki2)
mgr_fiz_do := inieditspr(A__MENUVERT, mm_gr_fiz_do, m1gr_fiz_do)
mgr_fiz    := inieditspr(A__MENUVERT, mm_gr_fiz, m1gr_fiz)
mDS_ONK    := inieditspr(A__MENUVERT, mm_danet, M1DS_ONK)
mnapr_stac := inieditspr(A__MENUVERT, mm_napr_stac, m1napr_stac)
mprofil_stac := inieditspr(A__MENUVERT, glob_V002, m1profil_stac)
mnapr_reab := inieditspr(A__MENUVERT, mm_danet, m1napr_reab)
mprofil_kojki := inieditspr(A__MENUVERT, glob_V020, m1profil_kojki)   
//
if !empty(f_print)
  return &(f_print+"("+lstr(Loc_kod)+","+lstr(kod_kartotek)+","+lstr(mdvozrast)+")")
endif
//
str_1 := " случая профилактики несовершеннолетних"
if Loc_kod == 0
  str_1 := "Добавление"+str_1
  mtip_h := yes_vypisan
else
  str_1 := "Редактирование"+str_1
endif
setcolor(color8)
//
Private gl_area
setcolor(cDataCGet)
make_diagP(1)  // сделать "шестизначные" диагнозы
Private num_screen := 1
do while .t.
  close databases
  DispBegin()
  if num_screen == 5
    hS := 31 ; wS := 90
  elseif num_screen == 3
    hS := 30 ; wS := 80
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
    s1 := " "
    mperiod := ret_period_PN(mdate_r,mn_data,mk_data,@s1)
    s := alltrim(mfio)
    if mperiod > 0
      s += s1
    endif
    @ j,wS-len(s) say s color color14
    if !between(mperiod,1,31)
      DispEnd()
      func_error(4,"Не удалось определить возрастной период!")
      if !empty(s1)
        func_error(10,s1)
      endif
      num_screen := 1
      loop
    elseif (i := ascan(arr_prof,{|x| x[1] == mperiod})) > 0
      DispEnd()
      func_error(4,"Уже была аналогичная профилактика с "+date_8(arr_prof[i,2])+" по "+date_8(arr_prof[i,3]))
      num_screen := 1
      loop
    endif
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
    ++j; @ j,1 say "Категория учета ребенка" get mkateg_uch ;
             reader {|x|menu_reader(x,mm_kateg_uch,A__MENUVERT,,,.f.)}
    ++j
    ++j; @ j,1 say "Сроки профилактики" get mn_data ;
               valid {|g| f_k_data(g,1),;
                          iif(mvozrast < 18, nil, func_error(4,"Это взрослый пациент!")),;
                          msvozrast := padr(count_ymd(mdate_r,mn_data),40),;
                          .t.;
                     }
         @ row(),col()+1 say "-" get mk_data valid {|g|f_k_data(g,2)}
         @ row(),col()+3 get msvozrast when .f. color color14
    ++j; @ j,1 say "№ амбулаторной карты" get much_doc picture "@!" ;
               when !(is_uchastok == 1 .and. is_task(X_REGIST)) ;
                     .or. mem_edit_ist==2
    ++j; @ j,1 say "Место проведения медосмотра" get mmesto_prov ;
               reader {|x|menu_reader(x,mm_mesto_prov,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "Медосмотр проведён мобильной бригадой?" get mmobilbr ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j
    ++j; @ j,1 say "МО прикрепления" get mMO_PR ;
              reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c)}},A__FUNCTION,,,.f.)}
    ++j; @ j,1 say "Общеобразовательное учреждение" get mschool ;
             reader {|x|menu_reader(x,{dir_server+"mo_schoo",,,,,,"Общеобразовательные учр-ия","B/BG"},A__POPUPBASE,,,.f.)}
    ++j
    ++j; @ j,1 say "Вес" get mWEIGHT pict "999" ;
               valid {|| iif(between(mWEIGHT,2,170),,func_error(4,"Неразумный вес")), .t.}
         @ row(),col()+1 say "кг, рост" get mHEIGHT pict "999" ;
               valid {|| iif(between(mHEIGHT,40,250),,func_error(4,"Неразумный рост")), .t.}
         @ row(),col()+1 say "см, окружность головы" get mPER_HEAD  pict "999" ;
               valid {|| iif(mdvozrast < 5, iif(between(mPER_HEAD,10,100),,func_error(4,"Неразумный размер окружности головы")),), .t.}
         @ row(),col()+1 say "см"
    ++j
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
    ar := np_arr_1_etap[mperiod]
    if !empty(ar[5]) // не пустой массив исследований
      ++j; @ j,1 say "I этап наименований исследований       Врач Ассис.  Дата     Выполнение Результат" color "RB+/B"
      if mem_por_ass == 0
        @ j,45 say space(6)
      endif
      not_hormon := .t.
      for i := 1 to count_pn_arr_iss
        fl := .t.
        if fl .and. !empty(np_arr_issled[i,2])
          fl := (mpol == np_arr_issled[i,2])
        endif
        if fl
          fl := (ascan(ar[5],np_arr_issled[i,1]) > 0)
        endif
        /*if fl .and. np_arr_issled[i,4] == 1 // гормон
          if not_hormon
       ++j; @ j,1 say padr("Исследование уровня гормонов в крови",38) color color8
            @ j,39 get mhormon ;
               reader {|x| menu_reader(x,{{|k,r,c| get_hormon_pn(k,r,c)}},A__FUNCTION,,,.f.)}
          endif
          fl := not_hormon := .f.
        endif*/
        if fl
          fl_kdp2 := .f.
          if glob_yes_kdp2[TIP_LU_PN] .and. ascan(glob_arr_usl_LIS,np_arr_issled[i,1]) > 0
            fl_kdp2 := .t.
          endif 
          mvarv := "MTAB_NOMiv"+lstr(i)
          mvara := "MTAB_NOMia"+lstr(i)
          mvard := "MDATEi"+lstr(i)
          mvarr := "MREZi"+lstr(i)
          mvaro := "MOTKAZi"+lstr(i)
          mvarlis := "MLIS"+lstr(i)
          if empty(&mvard)
            &mvard := mn_data
          endif
     ++j; @ j,1 say padr(np_arr_issled[i,3],38)
          if fl_kdp2
            @ j,34 get &mvarlis reader {|x|menu_reader(x,mm_kdp2,A__MENUVERT,,,.f.)}
          endif         
          @ j,39 get &mvarv pict "99999" valid {|g| v_kart_vrach(g) }
        if mem_por_ass > 0
          @ j,45 get &mvara pict "99999" valid {|g| v_kart_vrach(g) }
        endif
          @ j,51 get &mvard
          @ j,62 get &mvaro reader {|x|menu_reader(x,mm_otkaz,A__MENUVERT,,,.f.)}
          @ j,69 get &mvarr
        endif
      next
    endif
    ++j; @ j,1 say "I этап наименований осмотров           Врач Ассис.  Дата     Выполнение" color "RB+/B"
    if mem_por_ass == 0
      @ j,45 say space(6)
    endif
    if !empty(ar[4]) // не пустой массив осмотров
      for i := 1 to count_pn_arr_osm
        fl := .t.
        if fl .and. !empty(np_arr_osmotr[i,2])
          fl := (mpol == np_arr_osmotr[i,2])
        endif
        if fl
          fl := (ascan(ar[4],np_arr_osmotr[i,1]) > 0)
        endif
        if fl
          mvarv := "MTAB_NOMov"+lstr(i)
          mvara := "MTAB_NOMoa"+lstr(i)
          mvard := "MDATEo"+lstr(i)
          mvaro := "MOTKAZo"+lstr(i)
          mvarz := "MKOD_DIAGo"+lstr(i)
          if empty(&mvard)
            &mvard := mn_data
          endif
     ++j; @ j,1 say padr(np_arr_osmotr[i,3],38)
          @ j,39 get &mvarv pict "99999" valid {|g| v_kart_vrach(g) }
        if mem_por_ass > 0
          @ j,45 get &mvara pict "99999" valid {|g| v_kart_vrach(g) }
        endif
          @ j,51 get &mvard
          @ j,62 get &mvaro reader {|x|menu_reader(x,mm_otkaz,A__MENUVERT,,,.f.)}
        endif
      next
    endif
    if empty(MDATEp1)
      MDATEp1 := mn_data
    endif
    ++j
    @ j,1 say padr("педиатр (врач общей практики)",38) color color8
    @ j,39 get MTAB_NOMpv1 pict "99999" valid {|g| v_kart_vrach(g) }
  if mem_por_ass > 0
    @ j,45 get MTAB_NOMpa1 pict "99999" valid {|g| v_kart_vrach(g) }
  endif
    @ j,51 get MDATEp1
    status_key("^<Esc>^ выход без записи ^<PgUp>^ на 1-ю страницу ^<PgDn>^ на 3-ю страницу")
  elseif num_screen == 3 //
    ++j; @ j,1 say "Направлен на II этап ?" get mstep2 ;
               reader {|x|menu_reader(x,mm_step2,A__MENUVERT,,,.f.)}
    ++j
    ++j; @ j,1 say "Дополнительные гематологические исследования в КДП2" get musl2 ;
               reader {|x| menu_reader(x, { { |k,r,c| ob2_v_usl(.t.,r+1) }},A__FUNCTION,,,.f.)} ;
               when m1step2 == 1
    ar := np_arr_1_etap[mperiod]
    ++j; @ j,1 say "II этап наименований осмотров          Врач Ассис.  Дата     Выполнение" color "RB+/B"
    if mem_por_ass == 0
      @ j,45 say space(6)
    endif
    for i := 1 to count_pn_arr_osm
      fl := .t.
      if fl .and. !empty(np_arr_osmotr[i,2])
        fl := (mpol == np_arr_osmotr[i,2])
      endif
      if fl .and. !empty(ar[4])
        fl := (ascan(ar[4],np_arr_osmotr[i,1]) == 0)
      endif
      if fl
        mvarv := "MTAB_NOMov"+lstr(i)
        mvara := "MTAB_NOMoa"+lstr(i)
        mvard := "MDATEo"+lstr(i)
        mvaro := "MOTKAZo"+lstr(i)
        mvarz := "MKOD_DIAGo"+lstr(i)
   ++j; @ j,1 say padr(np_arr_osmotr[i,3],38)
        @ j,39 get &mvarv pict "99999" valid {|g| v_kart_vrach(g) } when m1step2 == 1
      if mem_por_ass > 0
        @ j,45 get &mvara pict "99999" valid {|g| v_kart_vrach(g) } when m1step2 == 1
      endif
        @ j,51 get &mvard when m1step2 == 1
        @ j,62 get &mvaro reader {|x|menu_reader(x,mm_otkaz,A__MENUVERT,,,.f.)} when m1step2 == 1
      endif
    next
    ++j
    @ j,1 say padr("педиатр (врач общей практики)",38) color color8
    @ j,39 get MTAB_NOMpv2 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2 == 1
  if mem_por_ass > 0
    @ j,45 get MTAB_NOMpa2 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2 == 1
  endif
    @ j,51 get MDATEp2 when m1step2 == 1
    status_key("^<Esc>^ выход без записи ^<PgUp>^ на 2-ю страницу ^<PgDn>^ на 4-ю страницу")
  elseif num_screen == 4 //
  if mdvozrast < 5 // если меньше 5 лет
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
    ++j; @ j,1 say "ДО ПРОВЕДЕНИЯ ПРОФОСМОРА: практически здоров" get mdiag_15_1 ;
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
    ++j; @ j,1 say "ГРУППА состояния ЗДОРОВЬЯ до проведения профосмотра" get mGRUPPA_DO pict "9"
    ++j; @ j,1 say "        медицинская ГРУППА для занятия физкультурой" get mGR_FIZ_DO ;
               reader {|x|menu_reader(x,mm_gr_fiz_do,A__MENUVERT,,,.f.)}
    status_key("^<Esc>^ выход без записи ^<PgUp>^ на 3-ю страницу ^<PgDn>^ на 5-ю страницу")
  elseif num_screen == 5 //
    ++j; @ j,1 say "ПО РЕЗУЛЬТАТАМ ПРОВЕДЕНИЯ ПРОФОСМОРА: практически здоров" get mdiag_16_1 ;
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
            if k == 3
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
    ++j; @ j,1 say "Признак подозрения на злокачественное новообразование" get mDS_ONK ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} 
    ++j; @ j,1 say "Направлен на лечение" get mnapr_stac ;
               reader {|x|menu_reader(x,mm_napr_stac,A__MENUVERT,,,.f.)} ; 
               valid {|| iif(m1napr_stac==0, (m1profil_stac:=0,mprofil_stac:=space(32)), ), update_get("mprofil_stac")}  
         @ j,col()+1 say "по профилю" get mprofil_stac ;      
               reader {|x|menu_reader(x,glob_V002,A__MENUVERT,,,.f.)} ; 
               when m1napr_stac > 0
    ++j; @ j,1 say "Направлен на реабилитацию" get mnapr_reab ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
               valid {|| iif(m1napr_reab==0, (m1profil_kojki:=0,mprofil_kojki:=space(30)), ), update_get("mprofil_kojki")}  
         @ j,col()+1 say ", профиль койки" get mprofil_kojki ;      
               reader {|x|menu_reader(x,glob_V020,A__MENUVERT,,,.f.)} ; 
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
    ++j; @ j,2 say "Нуждается в вакцинации" get mprivivki3 pict "@S54" ;
               when m1privivki1 > 0
    ++j; @ j,1 say "Рекомендации здорового образа жизни" get mrek_form pict "@S52"
    ++j; @ j,1 say "Рекомендации по диспансерному наблюдению" get mrek_disp pict "@S47"
    ++j; @ j,1 say "ГРУППА состояния ЗДОРОВЬЯ по результатам проведения профосмотра" get mGRUPPA pict "9"
    ++j; @ j,1 say "                    медицинская ГРУППА для занятия физкультурой" get mGR_FIZ ;
               reader {|x|menu_reader(x,mm_gr_fiz,A__MENUVERT,,,.f.)}
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
    if empty(mn_data)
      func_error(4,"Не введена дата начала лечения.")
      loop
    endif
    if mvozrast >= 18
      func_error(4,"Профосмотр оказан взрослому пациенту!")
      loop
    endif
    if !between(mperiod,1,31)
      func_error(4,"Не удалось определить возрастной период!")
      num_screen := 1
      loop
    endif
    if empty(mk_data)
      func_error(4,"Не введена дата окончания лечения.")
      loop
    elseif year(mk_data) < 2018
      func_error(4,"Профосмотры по новому Приказу Минздрава РФ вводятся с 2018 года")
      loop
    endif
    if empty(CHARREPL("0",much_doc,space(10)))
      func_error(4,'Не заполнен номер амбулаторной карты')
      loop
    endif
    if empty(mmo_pr)
      func_error(4,"Не введено МО, к которому прикреплён несовершеннолетний.")
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
    if mdvozrast < 5 .and. empty(mPER_HEAD)
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
    arr_iss := array(count_pn_arr_iss,10) ; afillall(arr_iss,0)
    R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","P2")
    num_screen := 2
    max_date1 := max_date2 := mn_data
    d12 := mn_data-1
    k := 0
    if metap == 2
      do while ++d12 <= mk_data
        if is_work_day(d12)
          if ++k == 20
            exit
          endif
        endif
      enddo
    endif
    fl := .t. ; is_otkaz := .f. ; is_neonat := .f.
    ar := np_arr_1_etap[mperiod]
    for i := 1 to count_pn_arr_iss
      mvart := "MTAB_NOMiv"+lstr(i)
      mvara := "MTAB_NOMia"+lstr(i)
      mvard := "MDATEi"+lstr(i)
      mvarr := "MREZi"+lstr(i)
      _fl_ := not_audio_s := .t.
      if _fl_ .and. !empty(np_arr_issled[i,2])
        _fl_ := (mpol == np_arr_issled[i,2])
      endif
      if _fl_
        _fl_ := (ascan(ar[5],np_arr_issled[i,1]) > 0)
      endif
      if np_arr_issled[i,1] == "3.5.4" .and. is_3_5_4 // Аудио-скрининг уже был
        not_audio_s := .f.
      endif
      if _fl_ .and. not_audio_s /*.and. np_arr_issled[i,4] == 0 // не гормон*/
        if empty(&mvard)
          fl := func_error(4,'Не введена дата иссл-ия "'+np_arr_issled[i,3]+'"')
        elseif metap == 2 .and. &mvard > d12
          fl := func_error(4,'Дата иссл-ия "'+np_arr_issled[i,3]+'" не в I-ом этапе (> 20 дней)')
        elseif empty(&mvart)
          fl := func_error(4,'Не введен врач в иссл-ии "'+np_arr_issled[i,3]+'"')
        endif
      endif
      if _fl_ .and. !emptyany(&mvard,&mvart)
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
        if valtype(np_arr_issled[i,5]) == "N"
          arr_iss[i,4] := np_arr_issled[i,5] // профиль
        elseif arr_iss[i,2] > 0 .and. (j := ascan(np_arr_issled[i,6],arr_iss[i,2])) > 0
          arr_iss[i,4] := np_arr_issled[i,5,j] // профиль
        endif
        arr_iss[i,5] := np_arr_issled[i,1] // шифр услуги
        arr_iss[i,6] := mdef_diagnoz
        arr_iss[i,9] := &mvard  
        //        
        m1var := "m1lis"+lstr(i)
        if glob_yes_kdp2[TIP_LU_PN] .and. &m1var == 1 
          arr_iss[i,10] := 1 // кровь проверяют в КДП2
        endif
        m1var := "M1OTKAZi"+lstr(i)
        if &m1var == 1 .and. !between(arr_iss[i,9],mn_data,mk_data) // если отказ и не в диапазоне
          &m1var := 0
        endif
        if &m1var == 1
          arr_iss[i,10] := 2 // отказ от услуги
          is_otkaz := .t.
        elseif left(arr_iss[i,5],5) == "4.26."
          is_neonat := .t.
        endif
        max_date1 := max(max_date1,arr_iss[i,9])
      endif
      if !fl ; exit ; endif
    next
    if !fl
      loop
    endif
    fl := .t.
    arr_osm1 := array(count_pn_arr_osm,10) ; afillall(arr_osm1,0)
    for i := 1 to count_pn_arr_osm
      _fl_ := .t.
      if _fl_ .and. !empty(np_arr_osmotr[i,2])
        _fl_ := (mpol == np_arr_osmotr[i,2])
      endif
      if _fl_
        _fl_ := (!empty(ar[4]) .and. ascan(ar[4],np_arr_osmotr[i,1]) > 0)
      endif
      if _fl_
        mvart := "MTAB_NOMov"+lstr(i)
        mvara := "MTAB_NOMoa"+lstr(i)
        mvard := "MDATEo"+lstr(i)
        mvarz := "MKOD_DIAGo"+lstr(i)
        if empty(&mvard)
          fl := func_error(4,'Не введена дата осмотра I этапа "'+np_arr_osmotr[i,3]+'"')
        elseif metap == 2 .and. &mvard > d12
          fl := func_error(4,'Дата осмотра "'+np_arr_osmotr[i,3]+'" не в I-ом этапе (> 20 дней)')
        elseif empty(&mvart)
          fl := func_error(4,'Не введен врач в осмотре I этапа "'+np_arr_osmotr[i,3]+'"')
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
          arr_osm1[i,4] := np_arr_osmotr[i,4] // профиль
          arr_osm1[i,5] := np_arr_osmotr[i,1] // шифр услуги
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
          m1var := "M1OTKAZo"+lstr(i)
          if &m1var == 1 .and. !between(arr_osm1[i,9],mn_data,mk_data) // если отказ и не в диапазоне
            &m1var := 0
          endif
          if &m1var == 1
            arr_osm1[i,10] := 2 // отказ от осмотра
            is_otkaz := .t.
          endif
          max_date1 := max(max_date1,arr_osm1[i,9])
        endif
      endif
      if !fl ; exit ; endif
    next
    if !fl
      loop
    endif
    if emptyany(MTAB_NOMpv1,MDATEp1)
      fl := func_error(4,'Не введён педиатр (врач общей практики) в осмотрах I этапа')
    elseif MDATEp1 < max_date1
      fl := func_error(4,'Педиатр (врач общей практики) на I этапе должен проводить осмотр последним!')
    elseif metap == 2 .and. MDATEp1 > d12
      fl := func_error(4,'Дата осмотра педиатра I этапа не умещается в 20 рабочих дней')
    endif
    if !fl
      loop
    endif
    m1p_otk := 0
    metap := 1
    arr_osm2 := array(count_pn_arr_osm,10) ; afillall(arr_osm2,0)
    if m1step2 == 2 // направлен на 2-ой этап, но отказался
      m1p_otk := 1   // признак отказа
    elseif m1step2 == 1 // направлен на 2-ой этап
      num_screen := 3
      fl := .t.
      if !emptyany(MTAB_NOMpv2,MDATEp2)
        metap := 2
      endif
      ku := 0
      for i := 1 to count_pn_arr_osm
        _fl_ := .t.
        if _fl_ .and. !empty(np_arr_osmotr[i,2])
          _fl_ := (mpol == np_arr_osmotr[i,2])
        endif
        if _fl_
          _fl_ := (ascan(ar[4],np_arr_osmotr[i,1]) == 0)
        endif
        if _fl_
          mvart := "MTAB_NOMov"+lstr(i)
          mvara := "MTAB_NOMoa"+lstr(i)
          mvard := "MDATEo"+lstr(i)
          mvarz := "MKOD_DIAGo"+lstr(i)
          if !empty(&mvard) .and. empty(&mvart)
            fl := func_error(4,'Не введен врач в осмотре II этапа "'+np_arr_osmotr[i,3]+'"')
          elseif !empty(&mvart) .and. empty(&mvard)
            fl := func_error(4,'Не введена дата осмотра II этапа "'+np_arr_osmotr[i,3]+'"')
          elseif !emptyany(&mvard,&mvart)
            ++ku
            metap := 2
            if &mvard < MDATEp1
              fl := func_error(4,'Дата осмотра II этапа "'+np_arr_osmotr[i,3]+'" внутри I этапа')
            endif
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
            arr_osm2[i,4] := np_arr_osmotr[i,4] // профиль
            arr_osm2[i,5] := np_arr_osmotr[i,1] // шифр услуги
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
            m1var := "M1OTKAZo"+lstr(i)
            if &m1var == 1
              arr_osm2[i,10] := 2 // отказ от осмотра
            endif
            arr_osm2[i,9] := &mvard
            max_date2 := max(max_date2,arr_osm2[i,9])
          endif
        endif
        if !fl ; exit ; endif
      next
      if fl .and. metap == 2
        if emptyany(MTAB_NOMpv2,MDATEp2)
          fl := func_error(4,'Не введён педиатр (врач общей практики) в осмотрах II этапа')
        elseif MDATEp1 == MDATEp2
          fl := func_error(4,'Педиатры на I и II этапах провели осмотры в один день!')
        elseif MDATEp2 < max_date2
          fl := func_error(4,'Педиатр (врач общей практики) на II этапе должен проводить осмотр последним!')
        elseif empty(ku)
          fl := func_error(4,"На II этапе кроме осмотра педиатра должен быть ещё какой-нибудь осмотр.")
        endif
      endif
      if !fl
        loop
      endif
    endif
    num_screen := 4
    if !between(mGRUPPA_DO,1,5)
      func_error(4,"ГРУППА состояния ЗДОРОВЬЯ ДО проведения профосмотра д.б. от 1 до 5")
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
      func_error(4,"ГРУППА состояния ЗДОРОВЬЯ по результатам проведения профосмотра - от 1 до 5")
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
    m1lis := 0 ; arr_lis2 := {}
    arr_usl_dop := {} ; arr_usl_otkaz := {}
    if glob_yes_kdp2[TIP_LU_PN]
      for i := 1 to count_pn_arr_iss
        if valtype(arr_iss[i,9]) == "D" .and. arr_iss[i,9] >= mn_data .and. len(arr_iss[i]) > 9 ;
                                        .and. valtype(arr_iss[i,10]) == "N" .and. arr_iss[i,10] == 1
          m1lis := 1 // в рамках диспансеризации
        endif
      next
    endif
    // добавим педиатра I этапа
    aadd(arr_osm1,add_pediatr_PN(MTAB_NOMpv1,MTAB_NOMpa1,MDATEp1,MKOD_DIAGp1))
    if metap == 1 // I этап
      for i := 1 to len(arr_iss)
        if valtype(arr_iss[i,5]) == "C"
          if arr_iss[i,10] == 2 // отказ
            arr_iss[i,10] := "i"
            aadd(arr_usl_otkaz,arr_iss[i])
          else
            aadd(arr_usl_dop,arr_iss[i])
            if is_otkaz .and. ; // в случае были отказы
                  arr_iss[i,10] == 0 .and. ; // услуга не в КДП2
                     between(arr_iss[i,9],mn_data,mk_data) .and. ; // умещается в период
                                     (j := ascan(np_arr_not_zs, {|x| x[1] == arr_iss[i,5]})) > 0
              arr := aclone(arr_iss[i])  // добавим                       
              arr[5] := np_arr_not_zs[j,2] // шифр исследования
              aadd(arr_usl_dop,arr)          // с ценой
            endif                          
          endif
        endif
      next
      for i := 1 to len(arr_osm1)
        if valtype(arr_osm1[i,5]) == "C"
          if arr_osm1[i,10] == 2 // отказ
            arr_osm1[i,10] := "o"
            aadd(arr_usl_otkaz,arr_osm1[i])
          else
            lshifr := alltrim(arr_osm1[i,5])
            if (j := ascan(np_arr_osmotr_KDP2,{|x| x[1] == lshifr})) > 0
              arr_osm1[i,5] := np_arr_osmotr_KDP2[j,3]  // замена на 2.3.*
            endif
            aadd(arr_usl_dop,arr_osm1[i])
            if is_otkaz .and.;// в случае были отказы
                     between(arr_osm1[i,9],mn_data,mk_data) ; // и умещается в период
                                                    .and. j > 0  // и найдено соответствие
              arr := aclone(arr_osm1[i])       // добавим                       
              arr[5] := np_arr_osmotr_KDP2[j,4]  // замена на 2.91.*
              aadd(arr_usl_dop,arr)             // с ценой
            endif
          endif
        endif
      next
      i := len(arr_osm1)
      m1vrach  := arr_osm1[i,1]
      m1prvs   := arr_osm1[i,2]
      m1assis  := arr_osm1[i,3]
      m1PROFIL := arr_osm1[i,4]
      //MKOD_DIAG := padr(arr_osm1[i,6],6)
      if !is_otkaz // добавляем код ЗС
        aadd(arr_usl_dop,array(10)) ; j := len(arr_usl_dop)
        arr_usl_dop[j,1] := m1vrach
        arr_usl_dop[j,2] := m1prvs
        arr_usl_dop[j,3] := m1assis
        arr_usl_dop[j,4] := 151 // для кода ЗС - мед.осмотрам профилактическим
        arr_usl_dop[j,5] := ret_shifr_zs_PN(mperiod)
        arr_usl_dop[j,6] := MKOD_DIAG
        arr_usl_dop[j,9] := mn_data
      endif
    else  // оформление 2-го этапа по-новому
      use (cur_dir+"tmp") new
      go top
      do while !eof()
        if is_lab_usluga(tmp->u_shifr)
          aadd(arr_lis2, {tmp->u_kod,tmp->u_shifr})
        endif
        skip
      enddo
      use
      for i := 1 to len(arr_iss)
        if valtype(arr_iss[i,5]) == "C"
          if arr_iss[i,10] == 2 // отказ
            arr_iss[i,10] := "i"
            aadd(arr_usl_otkaz,arr_iss[i])
          else
            aadd(arr_usl_dop,arr_iss[i])
            if arr_iss[i,10] == 0 ; // кровь проверяют у нас в МО
                        .and. between(arr_iss[i,9],mn_data,mk_data) .and. ; // и в сроки профосмотра
                                     (j := ascan(np_arr_not_zs, {|x| x[1] == arr_iss[i,5]})) > 0
              arr := aclone(arr_iss[i])  // добавим                       
              arr[5] := np_arr_not_zs[j,2] // шифр исследования
              aadd(arr_usl_dop,arr)          // с ценой
            endif                          
          endif
        endif
      next
      for i := 1 to len(arr_osm1)
        if valtype(arr_osm1[i,5]) == "C"
          lshifr := alltrim(arr_osm1[i,5])
          if arr_osm1[i,10] == 2 // отказ от осмотра
            arr_osm1[i,10] := "o"
            aadd(arr_usl_otkaz,arr_osm1[i])
          else
            lshifr := alltrim(arr_osm1[i,5])
            if (j := ascan(np_arr_osmotr_KDP2,{|x| x[1] == lshifr})) > 0
              arr_osm1[i,5] := np_arr_osmotr_KDP2[j,3]  // замена на 2.3.*
            endif
            aadd(arr_usl_dop,arr_osm1[i])
            if between(arr_osm1[i,9],mn_data,mk_data) ; // и умещается в период
                                                    .and. j > 0  // и найдено соответствие
              arr := aclone(arr_osm1[i])       // добавим                       
              arr[5] := np_arr_osmotr_KDP2[j,4]  // замена на 2.91.*
              aadd(arr_usl_dop,arr)             // с ценой
            endif
          endif
        endif
      next
      // добавим педиатра II этапа
      aadd(arr_osm2,add_pediatr_PN(MTAB_NOMpv2,MTAB_NOMpa2,MDATEp2,MKOD_DIAGp2))
      i := len(arr_osm2)
      m1vrach  := arr_osm2[i,1]
      m1prvs   := arr_osm2[i,2]
      m1assis  := arr_osm2[i,3]
      m1PROFIL := arr_osm2[i,4]
      //MKOD_DIAG := padr(arr_osm2[i,6],6)
      for i := 1 to len(arr_osm2)
        if valtype(arr_osm2[i,5]) == "C"
          lshifr := alltrim(arr_osm2[i,5])
          if arr_osm2[i,10] == 2 // отказ от осмотра
            arr_osm2[i,10] := "o"
            aadd(arr_usl_otkaz,arr_osm2[i])
          else
            if !empty(arr_lis2) .and.; 
                 (j := ascan(np_arr_osmotr_KDP2,{|x| x[1] == lshifr})) > 0
              arr_osm2[i,5] := np_arr_osmotr_KDP2[j,2] // услуги заменим на аналогичные шифры без гематологии
            endif
            aadd(arr_usl_dop,arr_osm2[i])
          endif
        endif
      next
      if !empty(arr_lis2) // были направления на анализы в КДП2
        if (mdate := max_date1+1) > max_date2 // следующий день после педиатра 1-го этапа
          mdate := max_date2 // если этого много, то окончание 2-го этапа
        endif
        for j := 1 to len(arr_lis2)
          aadd(arr_usl_dop, array(10)) ; i := len(arr_usl_dop)
          afill(arr_usl_dop[i],0)
          arr_usl_dop[i,4] := 34 // профиль
          arr_usl_dop[i,5] := arr_lis2[j,2] // шифр услуги
          arr_usl_dop[i,6] := mkod_diag
          arr_usl_dop[i,7] := arr_lis2[j,1] // код услуги
          arr_usl_dop[i,9] := mdate
          arr_usl_dop[i,10] := -1 // т.е. материал отправлен на анализ в КДП2
        next
      endif
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
    glob_podr := "" ; glob_otd_dep := 0
    for i := 1 to len(arr_usl_dop)
      if empty(arr_usl_dop[i,7]) // т.к. для услуг, направляемых в КДП2, код уже известен (а цена =0)
        arr_usl_dop[i,7] := foundOurUsluga(arr_usl_dop[i,5],mk_data,arr_usl_dop[i,4],M1VZROS_REB,@mu_cena)
        arr_usl_dop[i,8] := mu_cena
        mcena_1 += mu_cena
      endif
    next
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
    human->POLIS      := make_polis(mspolis,mnpolis) // серия и номер страхового полиса
    human->LPU        := M1LPU         // код учреждения
    human->OTD        := M1OTD         // код отделения
    human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
    human->N_DATA     := MN_DATA       // дата начала лечения
    human->K_DATA     := MK_DATA       // дата окончания лечения
    human->CENA := human->CENA_1 := MCENA_1 // стоимость лечения
    human->ishod      := 300+metap
    human->OBRASHEN   := iif(m1DS_ONK == 1, '1', " ")
    human->bolnich    := 0
    human->date_b_1   := ""
    human->date_b_2   := ""
    human_->RODIT_DR  := ctod("")
    human_->RODIT_POL := ""
    s := "" ; aeval(adiag_talon, {|x| s += str(x,1) })
    human_->DISPANS   := s
    human_->STATUS_ST := ""
    human_->POVOD     := m1povod
    human_->POVOD     := 5 // {"2.1-Медицинский осмотр",5,"2.1"},;
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
    human_->IDSP      := iif(metap==1, 17, 1)
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
      hu_->kod_diag := iif(empty(arr_usl_dop[i,6]), MKOD_DIAG, arr_usl_dop[i,6])
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
    save_arr_PN(mkod)
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

***** 28.01.18 вернуть шифр услуги законченного случая для ПН
Function ret_shifr_zs_PN(_period)
Local lshifr := ""
do case
  case _period == 1
    lshifr := iif(is_neonat, "72.2.37", "72.2.38") // 0 месяцев
  case _period == 2
    lshifr := "72.2.39" // 1 месяц
  case _period == 3
    lshifr := iif(m1lis == 1, "72.2.41", "72.2.40") // 2 мес
  case _period == 4
    lshifr := "72.2.43" // 3 месяца
  case eq_any(_period,5,6,7,8,9,10,11,12,14,15)
    lshifr := "72.2.42" // 4мес,5мес,6мес,7мес,8мес,9мес,10мес,11мес,1год3мес,1год6мес
  case _period == 13
    lshifr := iif(m1lis == 1, "72.2.45", "72.2.44") // 12 месяцев
    //!!!!!!!!!!!!!!! с 1 сентября !!!!!!!!!!!!!!!!!!!!!!!!!!
      //lshifr := iif(m1lis == 1, "72.2.65", "72.2.64") // 12 месяцев
  case _period == 16
    lshifr := "72.2.46" // 2 года
  case _period == 17
    lshifr := iif(m1lis == 1, "72.2.48", "72.2.47") // 3 года
  case eq_any(_period,18,19,22,23,25,26)
    lshifr := "72.2.49" // 4 года,5 лет,8 лет,9 лет,11 лет,12лет
  case _period == 20
    lshifr := iif(m1lis == 1, "72.2.51", "72.2.50") // 6 лет
  case _period == 21
    lshifr := iif(m1lis == 1, "72.2.53", "72.2.52") // 7 лет
  case _period == 24
    lshifr := iif(m1lis == 1, "72.2.55", "72.2.54") // 10 лет
  case _period == 27
    lshifr := "72.2.56" // 13 лет
  case _period == 28
    lshifr := "72.2.57" // 14 лет
  case _period == 29
    lshifr := iif(m1lis == 1, "72.2.59", "72.2.58") // 15 лет
  case _period == 30
    lshifr := iif(m1lis == 1, "72.2.61", "72.2.60") // 16 лет
  case _period == 31
    lshifr := iif(m1lis == 1, "72.2.63", "72.2.62") // 17 лет
endcase
return lshifr

***** 28.01.18
Function add_pediatr_PN(_pv,_pa,_date,_diag)
Local arr[10]
afill(arr,0)
select P2
find (str(_pv,5))
if found()
  arr[1] := p2->kod
  arr[2] := -ret_new_spec(p2->prvs,p2->prvs_new)
endif
if !empty(_pa)
  select P2
  find (str(_pa,5))
  if found()
    arr[3] := p2->kod
  endif
endif
arr[4] := iif(eq_any(arr[2],1110,-16), 57, 68) // профиль
arr[5] := iif(eq_any(arr[2],1110,-16), "2.85.15", "2.85.14") // шифр услуги
if empty(_diag) .or. left(_diag,1) == "Z"
  arr[6] := mdef_diagnoz
else
  arr[6] := _diag
  select MKB_10
  find (padr(arr[6],6))
  if found() .and. !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
    func_error(4,"Несовместимость диагноза по полу "+arr[6])
  endif
endif
arr[9] := _date
return arr

***** 28.01.18 вернуть возрастной период для профилактики несовершеннолетних
Function ret_period_PN(ldate_r,ln_data,lk_data,/*@*/ls,/*@*/ret_i)
Local i, _m, _d, _y, _m2, _d2, _y2, lperiod, sm, sm_, sm1, sm2, yn_data, yk_data
Store 0 TO _m, _d, _y, _m2, _d2, _y2, lperiod
yn_data := year(ln_data) ; yk_data := year(lk_data) ; ls := ""
count_ymd(ldate_r,ln_data,@_y,@_m,@_d) // реальный возраст на начало
count_ymd(ldate_r,lk_data,@_y2,@_m2,@_d2) // реальный возраст на окончание
ret_i := 31
for i := len(np_arr_1_etap) to 1 step -1
  if i > 17 // 4 года и старше
    if mdvozrast == np_arr_1_etap[i,2,1]
      ret_i := lperiod := i
      ls := " ("+lstr(mdvozrast)+" "+s_let(mdvozrast)+")"
      if yn_data != yk_data
        lperiod := 0
        ls := "Ошибка! Начало и окончание профилактики должны быть в одном календарном году"
      endif
      exit
    endif
  elseif mdvozrast < 4 // до 3 лет (включительно)
    sm1 := round(val(lstr(np_arr_1_etap[i,2,1])+"."+strzero(np_arr_1_etap[i,2,2],2)), 4)
    sm2 := round(val(lstr(np_arr_1_etap[i,3,1])+"."+strzero(np_arr_1_etap[i,3,2],2)), 4)
    sm := round(val(lstr(_y)+"."+strzero(_m,2)+strzero(_d,2)), 4)
    sm_ := round(val(lstr(_y2)+"."+strzero(_m2,2)+strzero(_d2,2)), 4)
    if sm1 <= sm
      ret_i := i
      if sm_ <= sm2
        lperiod := i
        if lperiod == 1 // новорожденный
          ls := "(новорожденный)"
          if _m2 == 1 .or. _d2 > 29
            lperiod := 0
            ls := "Ошибка! Новорожденному должно быть не более 29 дней"
          endif
          exit
        elseif lperiod == 16 // 2 года
          ls := " (2 года)"
          if mdvozrast > 2
            lperiod := 0
            ls := "Ошибка! Ребёнку в "+lstr(yn_data)+" календарном году уже исполняется 3 года"
          endif
          exit
        elseif lperiod == 17 // 3 года
          ls := " (3 года)"
          exit
        endif
        ls := " ("
        if np_arr_1_etap[i,2,1] > 0
          ls += lstr(np_arr_1_etap[i,2,1])+" "+s_let(np_arr_1_etap[i,2,1])+" "
        endif
        if np_arr_1_etap[i,2,2] > 0
          ls += lstr(np_arr_1_etap[i,2,2])+" "+mes_cev(np_arr_1_etap[i,2,2])
        endif
        ls := rtrim(ls)+")"
      else
        ls := "Должен быть период "+;
              iif(np_arr_1_etap[i,2,1]==0,"",lstr(np_arr_1_etap[i,2,1])+"г.")+;
              iif(np_arr_1_etap[i,2,2]==0,"",lstr(np_arr_1_etap[i,2,2])+"мес.")+"-"+;
              iif(np_arr_1_etap[i,3,1]==0,"",lstr(np_arr_1_etap[i,3,1])+"г.")+;
              iif(np_arr_1_etap[i,3,2]==0,"",lstr(np_arr_1_etap[i,3,2])+"мес.")+", а у Вас "+;
              iif(_y ==0,"",lstr(_y) +"г.")+;
              iif(_m ==0,"",lstr(_m) +"мес.")+;
              iif(_d ==0,"",lstr(_d) +"дн.")+"-"+;
              iif(_y2==0,"",lstr(_y2)+"г.")+;
              iif(_m2==0,"",lstr(_m2)+"мес.")+;
              iif(_d2==0,"",lstr(_d2)+"дн.")
      endif
      exit
    endif
  endif
next
return lperiod

*

***** 13.02.17 ПредН - добавление или редактирование случая (листа учета)
Function oms_sluch_PREDN(Loc_kod,kod_kartotek,f_print)
// Loc_kod - код по БД human.dbf (если = 0 - добавление листа учета)
// kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
// f_print - наименование функции для печати
Static st_N_DATA, st_K_DATA, st_mo_pr := '      ', st_school := 0
Local L_BEGIN_RSLT := 336
Local bg := {|o,k| get_MKB10(o,k,.t.) }, arr_del := {}, mrec_hu := 0,;
      buf := savescreen(), tmp_color := setcolor(), a_smert := {},;
      p_uch_doc := "@!", pic_diag := "@K@!", arr_usl := {},;
      i, j, k, n, s, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod,;
      tmp_help := chm_help_code, fl_write_sluch := .f., _y, _m, _d, t_arr[2]
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
Private mfio := space(50), mpol, mdate_r, madres, mvozrast, mdvozrast, msvozrast := " ",;
  M1VZROS_REB, MVZROS_REB, m1novor := 0,;
  m1company := 0, mcompany, mm_company,;
  mkomu, M1KOMU := 0, M1STR_CRB := 0,; // 0-ОМС,1-компании,3-комитеты/ЛПУ,5-личный счет
  msmo := "34007", rec_inogSMO := 0,;
  mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100),;
  mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20)
Private mkod := Loc_kod, mtip_h, is_talon := .f.,;
        mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
  M1LPU := glob_uch[1], MLPU,;
  M1OTD := glob_otd[1], MOTD,;
  M1FIO_KART := 1, MFIO_KART,;
  MUCH_DOC    := space(10)         ,; // вид и номер учетного документа
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
  m1rslt  := L_BEGIN_RSLT+1 ,; // результат (присвоена I группа здоровья)
  m1ishod := 306      ,; // исход = осмотр
  MN_DATA := st_N_DATA         ,; // дата начала лечения
  MK_DATA := st_K_DATA         ,; // дата окончания лечения
  MVRACH := space(10)         ,; // фамилия и инициалы лечащего врача
  M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0,; // код, таб.№ и спец-ть лечащего врача
  m1povod  := 4,;   // Профилактический
  m1travma := 0, ;
  m1USL_OK :=  3,; // поликлиника
  m1VIDPOM :=  1,; // первичная
  m1PROFIL := 68,; // педиатрия
  m1IDSP   := 17   // законченный случай в п-ке
//
Private mm_gr_fiz := {{"I",1},{"II",2},{"III",3},{"IV",4},{"не допущен",0}}
//
Private metap := 1, mperiod := 0, mshifr_zs := "",;
        mMO_PR := space(10), m1MO_PR := st_mo_pr,; // код МО прикрепления
        mschool := space(10), m1school := st_school,; // код обр.учреждения
        mtip_school := space(10), m1tip_school := 0,; // тип обр.учреждения
        mGRUPPA := 0,;    // группа здоровья после дисп-ии
        mGR_FIZ, m1GR_FIZ := 1,;
        mstep2, m1step2 := 0
Private mvar, m1var, m1lis := 0
//
for i := 1 to count_predn_arr_iss // исследования
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
for i := 1 to count_predn_arr_osm // осмотры
  mvar := "MTAB_NOMov"+lstr(i)
  Private &mvar := 0
  mvar := "MTAB_NOMoa"+lstr(i)
  Private &mvar := 0
  mvar := "MDATEo"+lstr(i)
  Private &mvar := ctod("")
  mvar := "MKOD_DIAGo"+lstr(i)
  Private &mvar := space(6)
next
for i := 1 to 2                // педиатр(ы)
  mvar := "MTAB_NOMpv"+lstr(i)
  Private &mvar := 0
  mvar := "MTAB_NOMpa"+lstr(i)
  Private &mvar := 0
  mvar := "MDATEp"+lstr(i)
  Private &mvar := ctod("")
  mvar := "MKOD_DIAGp"+lstr(i)
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
  m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
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
  mcena_1    := human->CENA_1
  metap      := human->ishod-302
  mGRUPPA    := human_->RSLT_NEW-L_BEGIN_RSLT
  if metap == 2
    m1step2 := 1
  endif
  //
  larr_i := array(count_predn_arr_iss) ; afill(larr_i,0)
  larr_o := array(count_predn_arr_osm) ; afill(larr_o,0)
  larr_p := {}
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
    if left(lshifr,5) == "72.3."
      mshifr_zs := lshifr
    else
      fl := .t.
      for i := 1 to count_predn_arr_iss
        if npred_arr_issled[i,1] == lshifr
          fl := .f. ; larr_i[i] := hu->(recno()) ; exit
        endif
      next
      if fl
        for i := 1 to count_predn_arr_osm
          if f_profil_ginek_otolar(npred_arr_osmotr[i,4],hu_->PROFIL)
            fl := .f. ; larr_o[i] := hu->(recno())
            exit
          endif
        next
      endif
      if fl .and. eq_any(hu_->PROFIL,68,57)
        aadd(larr_p,{hu->(recno()),c4tod(hu->date_u)})
      endif
    endif
    aadd(arr_usl,hu->(recno()))
    select HU
    skip
  enddo
  if len(larr_p) > 1 // если осмотр педиатра I этапа позднее педиатра II этапа
    asort(larr_p,,,{|x,y| x[2] < y[2] } )
    asize(larr_p,2) // отрезать лишние приёмы
  endif
  R_Use(dir_server+"mo_pers",,"P2")
  for j := 1 to 3
    if j == 1
      _arr := larr_i ; bukva := "i"
    elseif j == 2
      _arr := larr_o ; bukva := "o"
    else
      _arr := larr_p ; bukva := "p"
    endif
    for i := 1 to len(_arr)
      k := iif(j == 3, _arr[i,1], _arr[i])
      if !empty(k)
        hu->(dbGoto(k))
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
          if glob_yes_kdp2[TIP_LU_PREDN] .and. ascan(glob_arr_usl_LIS,npred_arr_issled[i,1]) > 0 ;
                                         .and. hu->is_edit == 1
            &m1var := 1
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
  read_arr_PredN(Loc_kod)
endif
if !(left(msmo,2) == '34') // не Волгоградская область
  m1ismo := msmo ; msmo := '34'
endif
close databases
is_talon := .t.
fv_date_r( iif(Loc_kod>0,mn_data,) )
MFIO_KART := _f_fio_kart()
mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
mlpu      := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
motd      := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
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
if !empty(m1MO_PR)
  mMO_PR := ret_mo(m1MO_PR)[_MO_SHORT_NAME]
endif
mschool := inieditspr(A__POPUPMENU, dir_server+"mo_schoo", m1school)
mtip_school := inieditspr(A__MENUVERT, mm_tip_school, m1tip_school)
mstep2  := inieditspr(A__MENUVERT, mm_danet, m1step2)
mgr_fiz := inieditspr(A__MENUVERT, mm_gr_fiz, m1gr_fiz)
//
if !empty(f_print)
  return &(f_print+"("+lstr(Loc_kod)+","+lstr(kod_kartotek)+","+lstr(mvozrast)+")")
endif
//
str_1 := " случая предварительного осмотра несовершеннолетних"
if Loc_kod == 0
  str_1 := "Добавление"+str_1
  mtip_h := yes_vypisan
else
  str_1 := "Редактирование"+str_1
endif
setcolor(color8)
Private gl_area := {1,0,maxrow()-1,maxcol(),0}
setcolor(cDataCGet)
make_diagP(1)  // сделать "шестизначные" диагнозы
Private num_screen := 1
do while .t.
  close databases
  @ 0,0 say padc(str_1,80) color "B/BG*"
  j := 1
  myclear(j)
  if yes_num_lu == 1 .and. Loc_kod > 0
    @ j,50 say padl("Лист учета № "+lstr(Loc_kod),29) color color14
  endif
  @ j,0 say "Экран "+lstr(num_screen) color color8
  if num_screen > 1
    mperiod := 0
    s := alltrim(mfio)
    for i := 1 to len(npred_arr_1_etap)
      if npred_arr_1_etap[i,1] == m1tip_school .and. ;
            between(mvozrast,npred_arr_1_etap[i,2],npred_arr_1_etap[i,3])
        mperiod := i
        s += " ("+npred_arr_1_etap[i,6]+")"
        exit
      endif
    next
    @ j,80-len(s) say s color color14
    if !between(mperiod,1,4)
      func_error(4,"Не удалось определить возрастной период!")
      num_screen := 1
      loop
    endif
  endif
  if num_screen == 1 //
    ++j; @ j,1 say "Учреждение" get mlpu when .f. color cDataCSay
         @ row(),col()+2 say "Отделение" get motd when .f. color cDataCSay
    //
    ++j
    ++j; @ j,1 say "ФИО" get mfio_kart ;
         reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
         valid {|g,o| update_get("mdate_r"),;
                      update_get("mkomu"),update_get("mcompany") }
         @ row(),col()+5 say "Д.р." get mdate_r when .f. color color14
    ++j
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
    ++j
    ++j; @ j,1 to j,78
    ++j
    ++j; @ j,1 say "Сроки осмотра" get mn_data ;
               valid {|g| f_k_data(g,1),;
                          iif(mvozrast < 18, nil, func_error(4,"Это взрослый пациент!")),;
                          msvozrast := padr(count_ymd(mdate_r,mn_data),40),;
                          .t.;
                     }
         @ row(),col()+1 say "-" get mk_data valid {|g|f_k_data(g,2)}
         @ row(),col()+3 get msvozrast when .f. color color14
    ++j; @ j,1 say "№ амбулаторной карты" get much_doc picture "@!" ;
               when !(is_uchastok == 1 .and. is_task(X_REGIST)) ;
                     .or. mem_edit_ist==2
    ++j
    ++j; @ j,1 say "МО прикрепления" get mMO_PR ;
              reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c)}},A__FUNCTION,,,.f.)}
    ++j
    ++j; @ j,1 say "Общеобразовательное учреждение" get mschool ;
             reader {|x|menu_reader(x,{dir_server+"mo_schoo",,,,,,"Общеобразовательные учр-ия","B/BG"},A__POPUPBASE1,,,.f.)}
    ++j; @ j,1 say "Тип общеобразовательного учреждения" get mtip_school ;
               reader {|x|menu_reader(x,mm_tip_school,A__MENUVERT,,,.f.)}
    status_key("^<Esc>^ выход без записи ^<PgDn>^ на 2-ю страницу")
    if !empty(a_smert)
      n_message(a_smert,,"GR+/R","W+/R",,,"G+/R")
    endif
  elseif num_screen == 2 //
    ar := npred_arr_1_etap[mperiod]
    ++j; @ j,1 say "I этап наименований исследований       Врач Ассис.  Дата     Результат" color "RB+/B"
    if mem_por_ass == 0
      @ j,45 say space(6)
    endif
    for i := 1 to count_predn_arr_iss
      fl := .t.
      if fl .and. !empty(npred_arr_issled[i,2])
        fl := (mpol == npred_arr_issled[i,2])
      endif
      if fl
        fl := (ascan(ar[5],npred_arr_issled[i,1]) > 0)
      endif
      if fl
        mvarv := "MTAB_NOMiv"+lstr(i)
        mvara := "MTAB_NOMia"+lstr(i)
        mvard := "MDATEi"+lstr(i)
        mvarr := "MREZi"+lstr(i)
        mvarlis := "MLIS"+lstr(i)
        if empty(&mvard)
          &mvard := mn_data
        endif
        fl_kdp2 := .f.
        if glob_yes_kdp2[TIP_LU_PREDN] .and. ascan(glob_arr_usl_LIS,npred_arr_issled[i,1]) > 0
          fl_kdp2 := .t.
        endif 
   ++j; @ j,1 say padr(npred_arr_issled[i,3],38)
        if fl_kdp2
          @ j,34 get &mvarlis reader {|x|menu_reader(x,mm_kdp2,A__MENUVERT,,,.f.)}
        endif         
        @ j,39 get &mvarv pict "99999" valid {|g| v_kart_vrach(g) }
      if mem_por_ass > 0
        @ j,45 get &mvara pict "99999" valid {|g| v_kart_vrach(g) }
      endif
        @ j,51 get &mvard
        @ j,62 get &mvarr
      endif
    next
    ++j; @ j,1 say "I этап наименований осмотров           Врач Ассис.  Дата     Диагноз" color "RB+/B"
    if mem_por_ass == 0
      @ j,45 say space(6)
    endif
    for i := 1 to count_predn_arr_osm
      fl := .t.
      if fl .and. !empty(npred_arr_osmotr[i,2])
        fl := (mpol == npred_arr_osmotr[i,2])
      endif
      if fl
        fl := (ascan(ar[4],npred_arr_osmotr[i,1]) > 0)
      endif
      if fl
        mvarv := "MTAB_NOMov"+lstr(i)
        mvara := "MTAB_NOMoa"+lstr(i)
        mvard := "MDATEo"+lstr(i)
        mvarz := "MKOD_DIAGo"+lstr(i)
        if empty(&mvard)
          &mvard := mn_data
        endif
   ++j; @ j,1 say padr(npred_arr_osmotr[i,3],38)
        @ j,39 get &mvarv pict "99999" valid {|g| v_kart_vrach(g) }
      if mem_por_ass > 0
        @ j,45 get &mvara pict "99999" valid {|g| v_kart_vrach(g) }
      endif
        @ j,51 get &mvard
        @ j,62 get &mvarz picture pic_diag ;
               reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
      endif
    next
    if empty(MDATEp1)
      MDATEp1 := mn_data
    endif
    ++j
    @ j,1 say padr("педиатр (врач общей практики)",38) color color8
    @ j,39 get MTAB_NOMpv1 pict "99999" valid {|g| v_kart_vrach(g) }
  if mem_por_ass > 0
    @ j,45 get MTAB_NOMpa1 pict "99999" valid {|g| v_kart_vrach(g) }
  endif
    @ j,51 get MDATEp1
    @ j,62 get MKOD_DIAGp1 picture pic_diag ;
           reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
    //
    status_key("^<Esc>^ выход без записи ^<PgUp>^ на 1-ю страницу ^<PgDn>^ на 3-ю страницу")
  elseif num_screen == 3 //
    ++j; @ j,1 say "Присутствуют врачебные осмотры II этапа ?" get mstep2 ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j
    ar := npred_arr_1_etap[mperiod]
    ++j; @ j,1 say "II этап наименований осмотров          Врач Ассис.  Дата     Диагноз" color "RB+/B"
    if mem_por_ass == 0
      @ j,45 say space(6)
    endif
    for i := 1 to count_predn_arr_osm
      fl := .t.
      if fl .and. !empty(npred_arr_osmotr[i,2])
        fl := (mpol == npred_arr_osmotr[i,2])
      endif
      if fl
        fl := (ascan(ar[4],npred_arr_osmotr[i,1]) == 0)
      endif
      if fl
        mvarv := "MTAB_NOMov"+lstr(i)
        mvara := "MTAB_NOMoa"+lstr(i)
        mvard := "MDATEo"+lstr(i)
        mvarz := "MKOD_DIAGo"+lstr(i)
   ++j; @ j,1 say padr(npred_arr_osmotr[i,3],38)
        @ j,39 get &mvarv pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
      if mem_por_ass > 0
        @ j,45 get &mvara pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
      endif
        @ j,51 get &mvard when m1step2==1
        @ j,62 get &mvarz picture pic_diag ;
               reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
               when m1step2==1
      endif
    next
    ++j
    @ j,1 say padr("педиатр (врач общей практики)",38) color color8
    @ j,39 get MTAB_NOMpv2 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
  if mem_por_ass > 0
    @ j,45 get MTAB_NOMpa2 pict "99999" valid {|g| v_kart_vrach(g) } when m1step2==1
  endif
    @ j,51 get MDATEp2 when m1step2==1
    @ j,62 get MKOD_DIAGp2 picture pic_diag ;
           reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol) ;
           when m1step2==1
    ++j
    ++j; @ j,1 say "ГРУППА состояния ЗДОРОВЬЯ по результатам проведения осмотра" get mGRUPPA pict "9"
    ++j; @ j,1 say "                медицинская ГРУППА для занятия физкультурой" get mGR_FIZ ;
               reader {|x|menu_reader(x,mm_gr_fiz,A__MENUVERT,,,.f.)}
    status_key("^<Esc>^ выход без записи ^<PgUp>^ на 2-ю страницу ^<PgDn>^ ЗАПИСЬ")
  endif
  count_edit += myread()
  if num_screen == 3
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
    if empty(mn_data)
      func_error(4,"Не введена дата начала лечения.")
      loop
    endif
    if mvozrast >= 18
      func_error(4,"Предварительный осмотр оказан взрослому пациенту!")
      loop
    endif
    if !between(mperiod,1,4)
      func_error(4,"Не удалось определить возрастной период!")
      num_screen := 1
      loop
    endif
    if empty(mk_data)
      func_error(4,"Не введена дата окончания лечения.")
      loop
    elseif year(mk_data) == 2018
      func_error(4,"Предварительные осмотры с 2018 года более не проводятся")
      loop
    endif
    if empty(CHARREPL("0",much_doc,space(10)))
      func_error(4,'Не заполнен номер амбулаторной карты')
      loop
    endif
    if empty(mmo_pr)
      func_error(4,"Не введено МО, к которому прикреплён несовершеннолетний.")
      loop
    endif
    if empty(m1school)
      func_error(4,"Не введено общеобразовательное учреждение.")
      loop
    endif
    if mvozrast < 1
      mdef_diagnoz := "Z00.1 "
    elseif mvozrast < 14
      mdef_diagnoz := "Z00.2 "
    else
      mdef_diagnoz := "Z00.3 "
    endif
    arr_iss := array(count_predn_arr_iss,10) ; afillall(arr_iss,0)
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
    ar := npred_arr_1_etap[mperiod]
    for i := 1 to count_predn_arr_iss
      mvart := "MTAB_NOMiv"+lstr(i)
      mvara := "MTAB_NOMia"+lstr(i)
      mvard := "MDATEi"+lstr(i)
      mvarr := "MREZi"+lstr(i)
      _fl_ := .t.
      if _fl_ .and. !empty(npred_arr_issled[i,2])
        _fl_ := (mpol == npred_arr_issled[i,2])
      endif
      if _fl_
        _fl_ := (ascan(ar[5],npred_arr_issled[i,1]) > 0)
      endif
      if _fl_
        if empty(&mvard)
          fl := func_error(4,'Не введена дата иссл-ия "'+npred_arr_issled[i,3]+'"')
        elseif metap == 2 .and. &mvard > d12
          fl := func_error(4,'Дата иссл-ия "'+npred_arr_issled[i,3]+'" не в I-ом этапе (> 10 дней)')
        elseif empty(&mvart)
          fl := func_error(4,'Не введен врач в иссл-ии "'+npred_arr_issled[i,3]+'"')
        endif
      endif
      if _fl_ .and. !emptyany(&mvard,&mvart)
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
        arr_iss[i,4] := npred_arr_issled[i,5] // профиль
        arr_iss[i,5] := npred_arr_issled[i,1] // шифр услуги
        arr_iss[i,6] := mdef_diagnoz
        arr_iss[i,9] := &mvard
        m1var := "m1lis"+lstr(i)
        if glob_yes_kdp2[TIP_LU_PREDN] .and. &m1var == 1 
          arr_iss[i,10] := 1 // кровь проверяют в КДП2
        endif
        max_date1 := max(max_date1,arr_iss[i,9])
      endif
      if !fl ; exit ; endif
    next
    if !fl
      loop
    endif
    fl := .t.
    arr_osm1 := array(count_predn_arr_osm,9) ; afillall(arr_osm1,0)
    for i := 1 to count_predn_arr_osm
      _fl_ := .t.
      if _fl_ .and. !empty(npred_arr_osmotr[i,2])
        _fl_ := (mpol == npred_arr_osmotr[i,2])
      endif
      if _fl_
        _fl_ := (ascan(ar[4],npred_arr_osmotr[i,1]) > 0)
      endif
      if _fl_
        mvart := "MTAB_NOMov"+lstr(i)
        mvara := "MTAB_NOMoa"+lstr(i)
        mvard := "MDATEo"+lstr(i)
        mvarz := "MKOD_DIAGo"+lstr(i)
        if empty(&mvard)
          fl := func_error(4,'Не введена дата осмотра I этапа "'+npred_arr_osmotr[i,3]+'"')
        elseif metap == 2 .and. &mvard > d12
          fl := func_error(4,'Дата осмотра "'+npred_arr_osmotr[i,3]+'" не в I-ом этапе (> 10 дней)')
        elseif empty(&mvart)
          fl := func_error(4,'Не введен врач в осмотре I этапа "'+npred_arr_osmotr[i,3]+'"')
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
          arr_osm1[i,4] := npred_arr_osmotr[i,4] // профиль
          arr_osm1[i,5] := npred_arr_osmotr[i,1] // шифр услуги
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
    if emptyany(MTAB_NOMpv1,MDATEp1)
      fl := func_error(4,'Не введён педиатр (врач общей практики) в осмотрах I этапа')
    elseif MDATEp1 < max_date1
      fl := func_error(4,'Педиатр (врач общей практики) на I этапе должен проводить осмотр последним!')
    elseif metap == 2 .and. MDATEp1 > d12
      fl := func_error(4,'Дата осмотра педиатра I этапа не умещается в 10 рабочих дней')
    endif
    if !fl
      loop
    endif
    metap := 1
    arr_osm2 := array(count_predn_arr_osm,9) ; afillall(arr_osm2,0)
    if m1step2 == 1
      num_screen := 3
      fl := .t.
      if !emptyany(MTAB_NOMpv2,MDATEp2)
        metap := 2
      endif
      ku := 0
      for i := 1 to count_predn_arr_osm
        _fl_ := .t.
        if _fl_ .and. !empty(npred_arr_osmotr[i,2])
          _fl_ := (mpol == npred_arr_osmotr[i,2])
        endif
        if _fl_
          _fl_ := (ascan(ar[4],npred_arr_osmotr[i,1]) == 0)
        endif
        if _fl_
          mvart := "MTAB_NOMov"+lstr(i)
          mvara := "MTAB_NOMoa"+lstr(i)
          mvard := "MDATEo"+lstr(i)
          mvarz := "MKOD_DIAGo"+lstr(i)
          if !empty(&mvard) .and. empty(&mvart)
            fl := func_error(4,'Не введен врач в осмотре II этапа "'+npred_arr_osmotr[i,3]+'"')
          elseif !empty(&mvart) .and. empty(&mvard)
            fl := func_error(4,'Не введена дата осмотра II этапа "'+npred_arr_osmotr[i,3]+'"')
          elseif !emptyany(&mvard,&mvart)
            ++ku
            metap := 2
            if &mvard < MDATEp1
              fl := func_error(4,'Дата осмотра II этапа "'+npred_arr_osmotr[i,3]+'" внутри I этапа')
            endif
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
            arr_osm2[i,4] := npred_arr_osmotr[i,4] // профиль
            arr_osm2[i,5] := npred_arr_osmotr[i,1] // шифр услуги
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
        endif
        if !fl ; exit ; endif
      next
      if fl .and. metap == 2
        if emptyany(MTAB_NOMpv2,MDATEp2)
          fl := func_error(4,'Не введён педиатр (врач общей практики) в осмотрах II этапа')
        elseif MDATEp1 == MDATEp2
          fl := func_error(4,'Педиатры на I и II этапах провели осмотры в один день!')
        elseif MDATEp2 < max_date2
          fl := func_error(4,'Педиатр (врач общей практики) на II этапе должен проводить осмотр последним!')
        elseif empty(ku)
          fl := func_error(4,"На II этапе кроме осмотра педиатра должен быть ещё какой-нибудь осмотр.")
        endif
      endif
      if !fl
        loop
      endif
    endif
    num_screen := 3
    if between(mGRUPPA,1,5)
      m1rslt := L_BEGIN_RSLT+mGRUPPA
    else
      func_error(4,"ГРУППА состояния ЗДОРОВЬЯ по результатам проведения медосмотра - от 1 до 5")
      loop
    endif
    //
    err_date_diap(mn_data,"Дата начала лечения")
    err_date_diap(mk_data,"Дата окончания лечения")
    //
    if mem_op_out == 2 .and. yes_parol
      box_shadow(19,10,22,69,cColorStMsg)
      str_center(20,'Оператор "'+fio_polzovat+'".',cColorSt2Msg)
      str_center(21,'Ввод данных за '+date_month(sys_date),cColorStMsg)
    endif
    mywait("Ждите. Производится запись листа учёта...")
    m1lis := 0
    if glob_yes_kdp2[TIP_LU_PREDN]
      for i := 1 to count_predn_arr_iss
        if valtype(arr_iss[i,9]) == "D" .and. arr_iss[i,9] >= mn_data .and. len(arr_iss[i]) > 9 ;
                                        .and. valtype(arr_iss[i,10]) == "N" .and. arr_iss[i,10] == 1
          m1lis := 1 // в рамках диспансеризации
        endif
      next
    endif
    // добавим педиатра I этапа
    aadd(arr_osm1,add_pediatr_PredN(MTAB_NOMpv1,MTAB_NOMpa1,MDATEp1,MKOD_DIAGp1))
    if metap == 1
      for i := 1 to len(arr_osm1)
        if valtype(arr_osm1[i,5])=="C" .and. left(arr_osm1[i,5],5)=="2.86."
          if eq_any(alltrim(arr_osm1[i,5]),"2.86.14","2.86.15") // педиатр, врач общей практики
            arr_osm1[i,5] := "2.3.2"
          else
            arr_osm1[i,5] := "2.3.1"
          endif
        endif
      next
      i := len(arr_osm1)
      m1vrach  := arr_osm1[i,1]
      m1prvs   := arr_osm1[i,2]
      m1assis  := arr_osm1[i,3]
      m1PROFIL := arr_osm1[i,4]
      MKOD_DIAG := padr(arr_osm1[i,6],6)
      aadd(arr_osm1,array(9)) ; i := len(arr_osm1)
      arr_osm1[i,1] := arr_osm1[i-1,1]
      arr_osm1[i,2] := arr_osm1[i-1,2]
      arr_osm1[i,3] := arr_osm1[i-1,3]
      arr_osm1[i,4] := 48 // медицинским осмотрам (предварительным, периодическим)
      arr_osm1[i,5] := ret_shifr_zs_PredN(mperiod)
      arr_osm1[i,6] := arr_osm1[i-1,6]
      arr_osm1[i,9] := mn_data
    else  // metap := 2
      // добавим педиатра II этапа
      aadd(arr_osm2,add_pediatr_PredN(MTAB_NOMpv2,MTAB_NOMpa2,MDATEp2,MKOD_DIAGp2))
      i := len(arr_osm2)
      m1vrach  := arr_osm2[i,1]
      m1prvs   := arr_osm2[i,2]
      m1assis  := arr_osm2[i,3]
      m1PROFIL := arr_osm2[i,4]
      MKOD_DIAG := padr(arr_osm2[i,6],6)
      for i := 1 to len(arr_osm1)
        if valtype(arr_osm1[i,5]) == "C" .and. (j := ascan(npred_arr_osmotr_KDP2,{|x| x[1] == arr_osm1[i,5]})) > 0
          arr_osm1[i,5] := npred_arr_osmotr_KDP2[j,2]
        endif
      next
      for i := 1 to len(arr_osm2)
        if valtype(arr_osm2[i,5]) == "C" .and. (j := ascan(npred_arr_osmotr_KDP2,{|x| x[1] == arr_osm2[i,5]})) > 0
          arr_osm2[i,5] := npred_arr_osmotr_KDP2[j,2]
        endif
      next
    endif
    select MKB_10
    find (MKOD_DIAG)
    if found() .and. !between_date(mkb_10->dbegin,mkb_10->dend,mk_data)
      MKOD_DIAG := mdef_diagnoz // если диагноз не входит в ОМС, то умолчание
    endif
    for i := 1 to count_predn_arr_iss
      if npred_arr_issled[i,4]==2 .and. ascan(npred_arr_issled[i,6],metap) > 0
        aadd(arr_iss,array(9)) ; j := len(arr_iss)
        arr_iss[j,1] := m1vrach
        arr_iss[j,2] := m1prvs
        arr_iss[j,3] := m1assis
        arr_iss[j,4] := m1PROFIL
        arr_iss[j,5] := npred_arr_issled[i,1] // шифр услуги
        arr_iss[j,6] := mdef_diagnoz
        arr_iss[j,9] := mk_data
      endif
    next
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
    st_mo_pr := m1mo_pr
    st_school := m1school
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
    human->diag_plus  := mdiag_plus    //
    human->ZA_SMO     := 0
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
    human->ishod      := 302+metap
    human->bolnich    := 0
    human->date_b_1   := ""
    human->date_b_2   := ""
    human_->RODIT_DR  := ctod("")
    human_->RODIT_POL := ""
    s := "" ; aeval(adiag_talon, {|x| s += str(x,1) })
    human_->DISPANS   := s
    human_->STATUS_ST := ""
    //human_->POVOD     := m1povod
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
    human_->IDSP      := iif(metap==1, 17, 1)
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
    save_arr_PredN(mkod)
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

***** 04.02.16 вернуть шифр услуги законченного случая для ПредН
Function ret_shifr_zs_PredN(_period)
Local lshifr := ""
do case
  case _period == 1
    lshifr := iif(m1lis == 1, "72.3.5", "72.3.1")//"Законченный случай предварительного осмотра несовершеннолетних при поступлении в ДОУ 1 этап"
  case _period == 2
    lshifr := iif(m1lis == 1, "72.3.6", "72.3.2")//"Законченный случай предварительного осмотра несовершеннолетних при поступлении в ООУ 1 этап"
  case _period == 3
    lshifr := iif(m1lis == 1, "72.3.7", "72.3.3")//"Законченный случай предварительного осмотра несовершеннолетних при поступлении в ОУ НПО, ВПО, СОУ, ОУ для детей-сирот от 0 до 14 лет 1 этап"
  case _period == 4
    lshifr := iif(m1lis == 1, "72.3.8", "72.3.4")//"Законченный случай предварительного осмотра несовершеннолетних при поступлении в ОУ НПО, ВПО, СОУ, ОУ для детей-сирот с 15 лет 1 этап"
endcase
return lshifr

***** 14.08.13
Function add_pediatr_PredN(_pv,_pa,_date,_diag)
Local arr[9]
afill(arr,0)
select P2
find (str(_pv,5))
if found()
  arr[1] := p2->kod
  arr[2] := -ret_new_spec(p2->prvs,p2->prvs_new)
endif
if !empty(_pa)
  select P2
  find (str(_pa,5))
  if found()
    arr[3] := p2->kod
  endif
endif
arr[4] := iif(eq_any(arr[2],1110,-16), 57, 68) // профиль
arr[5] := iif(eq_any(arr[2],1110,-16), "2.86.15", "2.86.14") // шифр услуги
if empty(_diag) .or. left(_diag,1) == "Z"
  arr[6] := mdef_diagnoz
else
  arr[6] := _diag
  select MKB_10
  find (padr(arr[6],6))
  if found() .and. !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
    func_error(4,"Несовместимость диагноза по полу "+arr[6])
  endif
endif
arr[9] := _date
return arr

*

***** 13.02.17 ПерН - добавление или редактирование случая (листа учета)
Function oms_sluch_PerN(Loc_kod,kod_kartotek,f_print)
// Loc_kod - код по БД human.dbf (если = 0 - добавление листа учета)
// kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
// f_print - наименование функции для печати
Static st_N_DATA, st_K_DATA, st_mo_pr := '      ', ;
       st_school := 0, st_tip_school := 0
Local L_BEGIN_RSLT := 342
Local bg := {|o,k| get_MKB10(o,k,.t.) }, arr_del := {}, mrec_hu := 0,;
      buf := savescreen(), tmp_color := setcolor(), a_smert := {},;
      p_uch_doc := "@!", pic_diag := "@K@!", arr_usl := {},;
      i, j, k, n, s, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod,;
      tmp_help := chm_help_code, fl_write_sluch := .f., _y, _m, _d, t_arr[2]
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
Private mfio := space(50), mpol, mdate_r, madres, mvozrast, mdvozrast, msvozrast := " ",;
  M1VZROS_REB, MVZROS_REB, m1novor := 0,;
  m1company := 0, mcompany, mm_company,;
  mkomu, M1KOMU := 0, M1STR_CRB := 0,; // 0-ОМС,1-компании,3-комитеты/ЛПУ,5-личный счет
  msmo := "34007", rec_inogSMO := 0,;
  mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100),;
  mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20)
Private mkod := Loc_kod, mtip_h, is_talon := .f.,;
        mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
  M1LPU := glob_uch[1], MLPU,;
  M1OTD := glob_otd[1], MOTD,;
  M1FIO_KART := 1, MFIO_KART,;
  MUCH_DOC    := space(10)         ,; // вид и номер учетного документа
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
  m1rslt  := L_BEGIN_RSLT          ,; // результат лечения
  m1ishod := 306      ,; // исход = осмотр
  MN_DATA := st_N_DATA         ,; // дата начала лечения
  MK_DATA := st_K_DATA         ,; // дата окончания лечения
  MVRACH := space(10)         ,; // фамилия и инициалы лечащего врача
  M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0,; // код, таб.№ и спец-ть лечащего врача
  m1povod  := 4,;   // Профилактический
  m1travma := 0, ;
  m1USL_OK :=  3,; // поликлиника
  m1VIDPOM :=  1,; // первичная
  m1PROFIL := 68,; // педиатрия
  m1IDSP   := 17   // законченный случай в п-ке
//
Private mperiod := 0, mshifr_zs := "",;
        mMO_PR := space(10), m1MO_PR := st_mo_pr,; // код МО прикрепления
        mschool := space(10), m1school := st_school,; // код обр.учреждения
        mtip_school := space(10), m1tip_school := st_tip_school,; // тип обр.учреждения
        mprotivo, m1protivo := 0, mgruppa := 0, m1GR_FIZ := 0
Private mvar, m1var, m1lis := 0
//
for i := 1 to count_Pern_arr_iss // исследования
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
// педиатр
Private MTAB_NOMpv1 := 0, MTAB_NOMpa1 := 0, MDATEp1 := ctod(""), MKOD_DIAGp1 := space(6)
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
  m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
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
  mcena_1    := human->CENA_1
  //
  larr_i := array(count_Pern_arr_iss) ; afill(larr_i,0)
  larr_p := {}
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
    if left(lshifr,5) == "72.4."
      mshifr_zs := lshifr
    else
      fl := .t.
      for i := 1 to count_Pern_arr_iss
        if nPer_arr_issled[i,1] == lshifr
          fl := .f. ; larr_i[i] := hu->(recno()) ; exit
        endif
      next
      if fl .and. eq_any(hu_->PROFIL,68,57)
        aadd(larr_p,{hu->(recno()),c4tod(hu->date_u)})
      endif
    endif
    aadd(arr_usl,hu->(recno()))
    select HU
    skip
  enddo
  if len(larr_p) > 1 // если осмотров педиатра почему-то более 1
    asort(larr_p,,,{|x,y| x[2] < y[2] } )  // отсортировать по дате
    asize(larr_p,1) // отрезать лишние приёмы
  endif
  R_Use(dir_server+"mo_pers",,"P2")
  for j := 1 to 2
    if j == 1
      _arr := larr_i ; bukva := "i"
    else
      _arr := larr_p ; bukva := "p"
    endif
    for i := 1 to len(_arr)
      k := iif(j == 2, _arr[i,1], _arr[i])
      if !empty(k)
        hu->(dbGoto(k))
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
          if glob_yes_kdp2[TIP_LU_PERN] .and. ascan(glob_arr_usl_LIS,nper_arr_issled[i,1]) > 0 ;
                                        .and. hu->is_edit == 1
            &m1var := 1
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
  read_arr_PerN(Loc_kod)
endif
if !(left(msmo,2) == '34') // не Волгоградская область
  m1ismo := msmo ; msmo := '34'
endif
close databases
is_talon := .t.
fv_date_r( iif(Loc_kod>0,mn_data,) )
MFIO_KART := _f_fio_kart()
mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
mlpu      := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
motd      := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
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
if !empty(m1MO_PR)
  mMO_PR := ret_mo(m1MO_PR)[_MO_SHORT_NAME]
endif
mschool := inieditspr(A__POPUPMENU, dir_server+"mo_schoo", m1school)
mtip_school := inieditspr(A__MENUVERT, mm_tip_school, m1tip_school)
mprotivo := inieditspr(A__MENUVERT, mm_danet, m1protivo)
//
if !empty(f_print)
  return &(f_print+"("+lstr(Loc_kod)+","+lstr(kod_kartotek)+","+lstr(mvozrast)+")")
endif
//
str_1 := " случая периодического осмотра несовершеннолетних"
if Loc_kod == 0
  str_1 := "Добавление"+str_1
  mtip_h := yes_vypisan
else
  str_1 := "Редактирование"+str_1
endif
setcolor(color8)
Private gl_area := {1,0,maxrow()-1,maxcol(),0}
setcolor(cDataCGet)
make_diagP(1)  // сделать "шестизначные" диагнозы
do while .t.
  close databases
  @ 0,0 say padc(str_1,80) color "B/BG*"
  j := 1
  myclear(j)
  if yes_num_lu == 1 .and. Loc_kod > 0
    @ j,50 say padl("Лист учета № "+lstr(Loc_kod),29) color color14
  endif
  ++j; @ j,1 say "Учреждение" get mlpu when .f. color cDataCSay
       @ row(),col()+2 say "Отделение" get motd when .f. color cDataCSay
  //
  ++j; @ j,1 say "ФИО" get mfio_kart ;
       reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
       valid {|g,o| update_get("mdate_r"),;
                    update_get("mkomu"),update_get("mcompany") }
       @ row(),col()+5 say "Д.р." get mdate_r when .f. color color14
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
  ++j; @ j,1 say "Сроки осмотра" get mn_data ;
             valid {|g| f_k_data(g,1),;
                        iif(mvozrast < 18, nil, func_error(4,"Это взрослый пациент!")),;
                        msvozrast := padr(count_ymd(mdate_r,mn_data),40),;
                        .t.;
                   }
       @ row(),col()+1 say "-" get mk_data valid {|g|f_k_data(g,2)}
       @ row(),col()+3 get msvozrast when .f. color color14
  ++j; @ j,1 say "№ амбулаторной карты" get much_doc picture "@!" ;
             when !(is_uchastok == 1 .and. is_task(X_REGIST)) ;
                   .or. mem_edit_ist==2
  ++j
  ++j; @ j,1 say "МО прикрепления" get mMO_PR ;
            reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c)}},A__FUNCTION,,,.f.)}
  ++j; @ j,1 say "Общеобразовательное учреждение" get mschool ;
           reader {|x|menu_reader(x,{dir_server+"mo_schoo",,,,,,"Общеобразовательные учр-ия","B/BG"},A__POPUPBASE1,,,.f.)}
  ++j; @ j,1 say "Тип общеобразовательного учреждения" get mtip_school ;
             reader {|x|menu_reader(x,mm_tip_school,A__MENUVERT,,,.f.)} ;
             valid {|| mperiod := iif(m1tip_school==1, 1, 2),;
                       iif(mperiod==1, (MTAB_NOMiv3 := MTAB_NOMia3 := 0, MDATEi3 := ctod(""), MREZi3 := space(17)),),;
                       iif(mperiod==2.and.empty(MDATEi3), MDATEi3 := mn_data,),;
                       .t.}
  ++j; @ j,1 to j,78
  ++j; @ j,1 say "Наименования исследований              Врач Ассис.  Дата     Результат" color "RB+/B"
  if mem_por_ass == 0
    @ j,45 say space(6)
  endif
  ++j
  if empty(MDATEi1)
    MDATEi1 := mn_data
  endif
  @ j,1 say padr("Общий анализ мочи",38)
  @ j,39 get MTAB_NOMiv1 pict "99999" valid {|g| v_kart_vrach(g) }
  if mem_por_ass > 0
    @ j,45 get MTAB_NOMia1 pict "99999" valid {|g| v_kart_vrach(g) }
  endif
  @ j,51 get MDATEi1
  @ j,62 get MREZi1
  //
  ++j
  if empty(MDATEi2)
    MDATEi2 := mn_data
  endif
  @ j,1 say padr("Клинический анализ крови",38)
  if glob_yes_kdp2[TIP_LU_PERN] .and. ascan(glob_arr_usl_LIS,nper_arr_issled[2,1]) > 0
    @ j,34 get mlis2 reader {|x|menu_reader(x,mm_kdp2,A__MENUVERT,,,.f.)}
  endif
  @ j,39 get MTAB_NOMiv2 pict "99999" valid {|g| v_kart_vrach(g) }
  if mem_por_ass > 0
    @ j,45 get MTAB_NOMia2 pict "99999" valid {|g| v_kart_vrach(g) }
  endif
  @ j,51 get MDATEi2
  @ j,62 get MREZi2
  //
  ++j
  if mperiod == 1
    MTAB_NOMiv3 := MTAB_NOMia3 := 0
    MDATEi3 := ctod("")
    MREZi3 := space(17)
  elseif empty(MDATEi3)
    MDATEi3 := mn_data
  endif
  @ j,1 say padr("Анализ окиси углерода выдыхаем.воздуха",38)
  @ j,39 get MTAB_NOMiv3 pict "99999" valid {|g| v_kart_vrach(g) } ;
         when mperiod == 2
  if mem_por_ass > 0
    @ j,45 get MTAB_NOMia3 pict "99999" valid {|g| v_kart_vrach(g) } ;
           when mperiod == 2
  endif
  @ j,51 get MDATEi3 when mperiod == 2
  @ j,62 get MREZi3 when mperiod == 2
  //
  ++j; @ j,1 say "Наименование осмотра                   Врач Ассис.  Дата     Диагноз" color "RB+/B"
  if mem_por_ass == 0
    @ j,45 say space(6)
  endif
  ++j
  if empty(MDATEp1)
    MDATEp1 := mn_data
  endif
  @ j,1 say padr("педиатр (врач общей практики)",38) color color8
  @ j,39 get MTAB_NOMpv1 pict "99999" valid {|g| v_kart_vrach(g) }
  if mem_por_ass > 0
    @ j,45 get MTAB_NOMpa1 pict "99999" valid {|g| v_kart_vrach(g) }
  endif
  @ j,51 get MDATEp1
  @ j,62 get MKOD_DIAGp1 picture pic_diag ;
         reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
  ++j; @ j,1 to j,78
  ++j; @ j,1 say "Обнаружены медицинские противопоказания к продолжению учёбы?" get mprotivo ;
             reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
  status_key("^<Esc>^ - выход без записи; ^<PgDn>^ - запись")
  if !empty(a_smert)
    n_message(a_smert,,"GR+/R","W+/R",,,"G+/R")
  endif
  count_edit += myread(,,++k_read)
  k := f_alert({padc("Выберите действие",60,".")},;
               {" Выход без записи "," Запись "," Возврат в редактирование "},;
               iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
  if k == 3
    loop
  elseif k == 2
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
    if empty(mn_data)
      func_error(4,"Не введена дата начала лечения.")
      loop
    endif
    if mvozrast >= 18
      func_error(4,"Периодический осмотр оказан взрослому пациенту!")
      loop
    endif
    if !between(mperiod,1,2)
      func_error(4,"Не удалось определить возрастной период!")
      loop
    endif
    if empty(mk_data)
      func_error(4,"Не введена дата окончания лечения.")
      loop
    elseif year(mk_data) == 2018
      func_error(4,"Периодические осмотры с 2018 года более не проводятся")
      loop
    endif
    if empty(CHARREPL("0",much_doc,space(10)))
      func_error(4,'Не заполнен номер амбулаторной карты')
      loop
    endif
    if empty(mmo_pr)
      func_error(4,"Не введено МО, к которому прикреплён несовершеннолетний.")
      loop
    endif
    if empty(m1school)
      func_error(4,"Не введено общеобразовательное учреждение.")
      loop
    endif
    if mvozrast < 1
      mdef_diagnoz := "Z00.1 "
    elseif mvozrast < 14
      mdef_diagnoz := "Z00.2 "
    else
      mdef_diagnoz := "Z00.3 "
    endif
    arr_iss := array(count_Pern_arr_iss,10) ; afillall(arr_iss,0)
    R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","P2")
    max_date1 := max_date2 := mn_data
    fl := .t.
    ar := nPer_arr_1_etap[mperiod]
    for i := 1 to count_Pern_arr_iss
      if ascan(ar[5],nPer_arr_issled[i,1]) > 0
        mvart := "MTAB_NOMiv"+lstr(i)
        mvara := "MTAB_NOMia"+lstr(i)
        mvard := "MDATEi"+lstr(i)
        mvarr := "MREZi"+lstr(i)
        if empty(&mvard)
          fl := func_error(4,'Не введена дата иссл-ия "'+nPer_arr_issled[i,3]+'"')
        elseif empty(&mvart)
          fl := func_error(4,'Не введен врач в иссл-ии "'+nPer_arr_issled[i,3]+'"')
        else
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
          arr_iss[i,4] := nPer_arr_issled[i,5] // профиль
          arr_iss[i,5] := nPer_arr_issled[i,1] // шифр услуги
          arr_iss[i,6] := mdef_diagnoz
          arr_iss[i,9] := &mvard
          m1var := "m1lis"+lstr(i)
          if glob_yes_kdp2[TIP_LU_PERN] .and. &m1var == 1 
            arr_iss[i,10] := 1 // кровь проверяют в КДП2
          endif
          max_date1 := max(max_date1,arr_iss[i,9])
        endif
      endif
      if !fl ; exit ; endif
    next
    if !fl
      loop
    endif
    if emptyany(MTAB_NOMpv1,MDATEp1)
      fl := func_error(4,'Не введён педиатр (врач общей практики)')
    elseif MDATEp1 < max_date1
      fl := func_error(4,'Педиатр (врач общей практики) должен проводить осмотр последним!')
    endif
    if !fl
      loop
    endif
    m1rslt := L_BEGIN_RSLT
    //
    err_date_diap(mn_data,"Дата начала лечения")
    err_date_diap(mk_data,"Дата окончания лечения")
    //
    if mem_op_out == 2 .and. yes_parol
      box_shadow(19,10,22,69,cColorStMsg)
      str_center(20,'Оператор "'+fio_polzovat+'".',cColorSt2Msg)
      str_center(21,'Ввод данных за '+date_month(sys_date),cColorStMsg)
    endif
    mywait("Ждите. Производится запись листа учёта...")
    m1lis := 0
    if glob_yes_kdp2[TIP_LU_PN]
      for i := 1 to count_Pern_arr_iss
        if valtype(arr_iss[i,9]) == "D" .and. arr_iss[i,9] >= mn_data .and. len(arr_iss[i]) > 9 ;
                                        .and. valtype(arr_iss[i,10]) == "N" .and. arr_iss[i,10] == 1
          m1lis := 1 // в рамках диспансеризации
        endif
      next
    endif
    arr_osm1 := {}
    // добавим педиатра
    aadd(arr_osm1,add_pediatr_PerN(MTAB_NOMpv1,MTAB_NOMpa1,MDATEp1,MKOD_DIAGp1))
    i := len(arr_osm1)
    m1vrach  := arr_osm1[i,1]
    m1prvs   := arr_osm1[i,2]
    m1assis  := arr_osm1[i,3]
    m1PROFIL := arr_osm1[i,4]
    MKOD_DIAG := padr(arr_osm1[i,6],6)
    // добавим код законченного случая
    aadd(arr_osm1,array(9)) ; i := len(arr_osm1)
    arr_osm1[i,1] := arr_osm1[i-1,1]
    arr_osm1[i,2] := arr_osm1[i-1,2]
    arr_osm1[i,3] := arr_osm1[i-1,3]
    arr_osm1[i,4] := 48 // медицинским осмотрам (предварительным, периодическим)
    arr_osm1[i,5] := ret_shifr_zs_PerN(mperiod)
    arr_osm1[i,6] := arr_osm1[i-1,6]
    arr_osm1[i,9] := mn_data
    select MKB_10
    find (MKOD_DIAG)
    if found() .and. !between_date(mkb_10->dbegin,mkb_10->dend,mk_data)
      MKOD_DIAG := mdef_diagnoz // если диагноз не входит в ОМС, то умолчание
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
    st_mo_pr := m1mo_pr
    st_school := m1school
    st_tip_school := m1tip_school
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
    human->diag_plus  := mdiag_plus    //
    human->ZA_SMO     := 0
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
    human->ishod      := 305
    human->bolnich    := 0
    human->date_b_1   := ""
    human->date_b_2   := ""
    human_->RODIT_DR  := ctod("")
    human_->RODIT_POL := ""
    s := "" ; aeval(adiag_talon, {|x| s += str(x,1) })
    human_->DISPANS   := s
    human_->STATUS_ST := ""
    //human_->POVOD     := m1povod
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
    human_->IDSP      := 17
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
    save_arr_PerN(mkod)
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

***** 25.08.13 вернуть шифр услуги законченного случая для ПерН
Function ret_shifr_zs_PerN(_period)
Local lshifr := ""
do case
  case _period == 1
    lshifr := iif(m1lis == 1, "72.4.3", "72.4.1")//"Законченный случай периодического осмотра несовершеннолетних, обучающихся в ДОУ
  case _period == 2
    lshifr := iif(m1lis == 1, "72.4.4", "72.4.2")//"Законченный случай периодического осмотра несовершеннолетних, обучающихся в ООУ, ОУ НПО, ВПО, СОУ, ОУ для детей-сирот
endcase
return lshifr

***** 25.08.13
Function add_pediatr_PerN(_pv,_pa,_date,_diag)
Local arr[9]
afill(arr,0)
select P2
find (str(_pv,5))
if found()
  arr[1] := p2->kod
  arr[2] := -ret_new_spec(p2->prvs,p2->prvs_new)
endif
if !empty(_pa)
  select P2
  find (str(_pa,5))
  if found()
    arr[3] := p2->kod
  endif
endif
arr[4] := iif(eq_any(arr[2],1110,-16), 57, 68) // профиль
//arr[5] := iif(eq_any(arr[2],1110,-16), "2.3.2", "2.3.1") // шифр услуги
arr[5] := "2.3.2" // шифр услуги
if empty(_diag) .or. left(_diag,1) == "Z"
  arr[6] := mdef_diagnoz
else
  arr[6] := _diag
  select MKB_10
  find (padr(arr[6],6))
  if found() .and. !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
    func_error(4,"Несовместимость диагноза по полу "+arr[6])
  endif
endif
arr[9] := _date
return arr

*

***** 16.10.14 ПренД - добавление или редактирование случая (листа учета)
Function oms_sluch_PrenD(Loc_kod,kod_kartotek)
// Loc_kod - код по БД human.dbf (если = 0 - добавление листа учета)
// kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
Static st_N_DATA, sv1 := 0, sv2 := 0, sv3 := 0
Local arr_del := {}, mrec_hu := 0, buf := savescreen(), tmp_color := setcolor(), ;
      a_smert := {}, p_uch_doc := "@!", arr_usl := {},;
      i, j, k, n, s, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod,;
      tmp_help := chm_help_code, fl_write_sluch := .f., t_arr[2]
Local top2 := 9
//
Default st_N_DATA TO sys_date
Default Loc_kod TO 0, kod_kartotek TO 0
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
Private mkod := Loc_kod, mtip_h, is_talon := .f.,;
        mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
  M1LPU := glob_uch[1], MLPU,;
  M1OTD := glob_otd[1], MOTD,;
  M1FIO_KART := 1, MFIO_KART,;
  MUCH_DOC    := space(10)         ,; // вид и номер учетного документа
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
  m1rslt  := 314                   ,; // результат лечения
  m1ishod := 306      ,; // исход = осмотр
  MN_DATA := st_N_DATA         ,; // дата начала лечения
  MK_DATA,;
  MVRACH := space(10)         ,; // фамилия и инициалы лечащего врача
  M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0,; // код, таб.№ и спец-ть лечащего врача
  m1povod  := 1,;   // Лечебно-диагностический
  m1travma := 0
//
Private MTAB_NOM1 := sv1, MTAB_NOM2 := sv2, MTAB_NOM3 := sv3
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
  m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
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
  mcena_1    := human->CENA_1
  //
  R_Use(dir_server+"mo_pers",,"P2")
  R_Use(dir_server+"uslugi",,"USL")
  use_base("human_u")
  find (str(Loc_kod,7))
  do while hu->kod == Loc_kod .and. !eof()
    if hu->kod_vr > 0
      p2->(dbGoto(hu->kod_vr))
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
        lshifr := usl->shifr
      endif
      lshifr := alltrim(lshifr)
      if eq_any(lshifr,"2.79.51","8.30.3")
        MTAB_NOM1 := p2->tab_nom
      elseif lshifr == "4.26.6"
        MTAB_NOM2 := p2->tab_nom
      elseif lshifr == "2.5.1"
        MTAB_NOM3 := p2->tab_nom
      endif
    endif
    aadd(arr_usl,hu->(recno()))
    select HU
    skip
  enddo
  if alltrim(msmo) == '34'
    mnameismo := ret_inogSMO_name(2,@rec_inogSMO,.t.) // открыть и закрыть
  endif
endif
if !(left(msmo,2) == '34') // не Волгоградская область
  m1ismo := msmo ; msmo := '34'
endif
close databases
is_talon := .t.
fv_date_r( iif(Loc_kod>0,mn_data,) )
MFIO_KART := _f_fio_kart()
mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
mlpu      := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
motd      := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
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
str_1 := " случая ПРЕНАТАЛЬНОЙ диагностики в окружном кабинете"
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
setcolor(cDataCGet)
do while .t.
  close databases
  j := top2
  if yes_num_lu == 1 .and. Loc_kod > 0
    @ j,50 say padl("Лист учета № "+lstr(Loc_kod),29) color color14
  endif
  ++j; @ j,1 say "Учреждение" get mlpu when .f. color cDataCSay
       @ row(),col()+2 say "Отделение" get motd when .f. color cDataCSay
  //
  ++j; @ j,1 say "ФИО" get mfio_kart ;
       reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
       valid {|g,o| update_get("mdate_r"),;
                    update_get("mkomu"),update_get("mcompany") }
       @ row(),col()+5 say "Д.р." get mdate_r when .f. color color14
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
  ++j; @ j,1 say "Дата диагностики" get mn_data ;
             valid {|g| f_k_data(g,1), mk_data := mn_data, f_k_data(g,2) }
  ++j; @ j,1 say "№ амбулаторной карты" get much_doc picture "@!" ;
             when !(is_uchastok == 1 .and. is_task(X_REGIST)) ;
                   .or. mem_edit_ist==2
  ++j; @ j,1 to j,78
  ++j
  @ j,1 say padr("Табельный номер врача окружного кабинета (УЗИ)",51) ;
        get MTAB_NOM1 pict "99999" valid {|g| v_kart_vrach(g) }
  ++j
  @ j,1 say padr("Таб.номер медсестры (взятие крови из вены ВПР и ХА)",51) ;
        get MTAB_NOM2 pict "99999" valid {|g| v_kart_vrach(g) }
  ++j
  @ j,1 say padr("Таб.номер акушерки окружного кабинета (при наличии)",51) ;
        get MTAB_NOM3 pict "99999" valid {|g| v_kart_vrach(g) }
  status_key("^<Esc>^ - выход без записи; ^<PgDn>^ - запись")
  if !empty(a_smert)
    n_message(a_smert,,"GR+/R","W+/R",,,"G+/R")
  endif
  count_edit += myread(,,++k_read)
  k := f_alert({padc("Выберите действие",60,".")},;
               {" Выход без записи "," Запись "," Возврат в редактирование "},;
               iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
  if k == 3
    loop
  elseif k == 2
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
    if empty(mn_data)
      func_error(4,"Не введена дата диагностики.")
      loop
    endif
    if empty(MTAB_NOM1)
      func_error(4,"Не введен табельный номер врача окружного кабинета (УЗИ)")
      loop
    endif
    if empty(MTAB_NOM2)
      func_error(4,"Не введен табельный номер медсестры, взявшей кровь из вены")
      loop
    endif
    mdef_diagnoz := "Z01.7 "
    arr_iss := array(4,9) ; afillall(arr_iss,0)
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","P2")
    select P2
    find (str(MTAB_NOM1,5))
    if found()
      arr_iss[1,1] := arr_iss[2,1] := p2->kod
      arr_iss[1,2] := arr_iss[2,2] := -ret_new_spec(p2->prvs,p2->prvs_new)
    endif
    arr_iss[1,4] := arr_iss[2,4] := 106 // профиль
    arr_iss[1,5] := "2.79.51" // шифр услуги
    arr_iss[2,5] := "8.30.3" // шифр услуги
    //
    find (str(MTAB_NOM2,5))
    if found()
      arr_iss[3,1] := p2->kod
      arr_iss[3,2] := -ret_new_spec(p2->prvs,p2->prvs_new)
    endif
    arr_iss[3,4] := 82 // профиль
    arr_iss[3,5] := "4.26.6" // шифр услуги
    //
    if !empty(MTAB_NOM3)
      find (str(MTAB_NOM3,5))
      if found()
        arr_iss[4,1] := p2->kod
        arr_iss[4,2] := -ret_new_spec(p2->prvs,p2->prvs_new)
      endif
      arr_iss[4,4] := 3 // профиль
      arr_iss[4,5] := "2.5.1" // шифр услуги
    endif
    err_date_diap(mn_data,"Дата диагностики")
    //
    if mem_op_out == 2 .and. yes_parol
      box_shadow(19,10,22,69,cColorStMsg)
      str_center(20,'Оператор "'+fio_polzovat+'".',cColorSt2Msg)
      str_center(21,'Ввод данных за '+date_month(sys_date),cColorStMsg)
    endif
    mywait()
    //
    sv1 := MTAB_NOM1
    sv2 := MTAB_NOM2
    sv3 := MTAB_NOM3
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
        arr_iss[i,7] := foundOurUsluga(arr_iss[i,5],mn_data,arr_iss[i,4],M1VZROS_REB,@mu_cena)
        arr_iss[i,8] := mu_cena
        mcena_1 += mu_cena
        aadd(arr_usl_dop,arr_iss[i])
      endif
    next
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
    human_->KOD_DIAG0 := ""
    human->KOD_DIAG   := mdef_diagnoz  // шифр 1-ой осн.болезни
    human->KOD_DIAG2  := ""
    human->KOD_DIAG3  := ""
    human->KOD_DIAG4  := ""
    human->SOPUT_B1   := ""
    human->SOPUT_B2   := ""
    human->SOPUT_B3   := ""
    human->SOPUT_B4   := ""
    human->diag_plus  := ""            //
    human->ZA_SMO     := 0
    human->KOMU       := M1KOMU        // от 0 до 5
    human_->SMO       := msmo
    human->STR_CRB    := m1str_crb
    human->POLIS      := make_polis(mspolis,mnpolis) // серия и номер страхового полиса
    human->LPU        := M1LPU         // код учреждения
    human->OTD        := M1OTD         // код отделения
    human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
    human->N_DATA     := MN_DATA       // дата начала лечения
    human->K_DATA     := MN_DATA       // дата окончания лечения
    human->CENA := human->CENA_1 := MCENA_1 // стоимость лечения
    human->ishod      := 99 // пренатальная диагностика (на будущее)
    human->bolnich    := 0
    human->date_b_1   := ""
    human->date_b_2   := ""
    human_->RODIT_DR  := ctod("")
    human_->RODIT_POL := ""
    s := "" ; aeval(adiag_talon, {|x| s += str(x,1) })
    human_->DISPANS   := s
    human_->STATUS_ST := ""
    human_->POVOD     := 9 // {"2.6-Посещение по другим обстоятельствам", 9,"2.6"},;
    //human_->TRAVMA    := m1travma
    human_->VPOLIS    := m1vidpolis
    human_->SPOLIS    := ltrim(mspolis)
    human_->NPOLIS    := ltrim(mnpolis)
    human_->OKATO     := "" // это поле вернётся из ТФОМС в случае иногороднего
    human_->NOVOR     := 0
    human_->DATE_R2   := ctod("")
    human_->POL2      := ""
    human_->USL_OK    := 3
    human_->VIDPOM    := 1
    human_->PROFIL    := 106 // ультразвуковой диагностике
    human_->IDSP      := 29 // за посещение в поликлинике
    human_->NPR_MO    := ''
    human_->FORMA14   := '0000'
    human_->KOD_DIAG0 := ''
    human_->RSLT_NEW  := 314 // динамическое наблюдение
    human_->ISHOD_NEW := 306 // осмотр
    human_->VRACH     := arr_iss[1,1]
    human_->PRVS      := arr_iss[1,2]
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
      hu->kod_as  := 0
      hu->u_koef  := 1
      hu->u_kod   := arr_usl_dop[i,7]
      hu->u_cena  := arr_usl_dop[i,8]
      hu->is_edit := 0
      hu->date_u  := dtoc4(mn_data)
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
      hu_->kod_diag := mdef_diagnoz
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

*

***** 09.08.16 жидкостная цитология рака шейки матки
Function oms_sluch_g_cit(Loc_kod,kod_kartotek)
// Loc_kod - код по БД human.dbf (если = 0 - добавление листа учета)
// kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
Static st_N_DATA, sv1 := 0
Local arr_del := {}, mrec_hu := 0, buf := savescreen(), tmp_color := setcolor(), ;
      a_smert := {}, p_uch_doc := "@!", pic_diag := "@K@!", arr_usl := {},;
      i, j, k, n, s, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod,;
      tmp_help := chm_help_code, fl_write_sluch := .f., t_arr[2],;
      bg := {|o,k| get_MKB10(o,k,.t.) }
Local top2 := 11
if empty(glob_klin_diagn)
  return func_error(4,"В вашем учреждении не разрешены специальные лабораторные исследования")
endif
//
Default st_N_DATA TO sys_date
Default Loc_kod TO 0, kod_kartotek TO 0
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
Private mkod := Loc_kod, mtip_h, is_talon := .f.,;
        mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
  M1LPU := glob_uch[1], MLPU,;
  M1OTD := glob_otd[1], MOTD,;
  M1FIO_KART := 1, MFIO_KART,;
  MUCH_DOC    := space(10)         ,; // вид и номер учетного документа
  MKOD_DIAG   := "Z01.7"           ,; // шифр 1-ой осн.болезни
  m1rslt  := 314                   ,; // результат лечения
  m1ishod := 304                   ,; // исход = без перемен
  m1NPR_MO := "", mNPR_MO := space(10), mNPR_DATE := ctod(""),;
  MN_DATA := st_N_DATA         ,; // дата начала лечения
  MK_DATA,;
  MVRACH := space(10)         ,; // фамилия и инициалы лечащего врача
  M1VRACH := 0, MTAB_NOM := sv1, m1prvs := 0,; // код, таб.№ и спец-ть лечащего врача
  m1povod  := 1,;   // Лечебно-диагностический
  m1travma := 0
//
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
  m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
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
  m1NPR_MO    := human_->NPR_MO
  mNPR_DATE   := human_2->NPR_DATE
  m1VRACH     := human_->vrach
  MKOD_DIAG   := human->KOD_DIAG
  MPOLIS      := human->POLIS         // серия и номер страхового полиса
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
  mcena_1    := human->CENA_1
  //
  use_base("human_u")
  find (str(Loc_kod,7))
  do while hu->kod == Loc_kod .and. !eof()
    aadd(arr_usl,hu->(recno()))
    select HU
    skip
  enddo
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
is_talon := .t.
fv_date_r( iif(Loc_kod>0,mn_data,) )
MFIO_KART := _f_fio_kart()
if !empty(m1NPR_MO)
  mNPR_MO := ret_mo(m1NPR_MO)[_MO_SHORT_NAME]
endif
MKOD_DIAG := padr(MKOD_DIAG,6) 
mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
mlpu      := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
motd      := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
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
str_1 := " случая леч.-диагн.процедуры при проведении "
if ascan(glob_klin_diagn,1) > 0
  str_1 += "жидкостной цитологии"
elseif ascan(glob_klin_diagn,2) > 0
  str_1 += "пренатального скрининга"
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
setcolor(cDataCGet)
diag_screen(0)
do while .t.
  close databases
  j := top2
  if yes_num_lu == 1 .and. Loc_kod > 0
    @ j,50 say padl("Лист учета № "+lstr(Loc_kod),29) color color14
  endif
  ++j; @ j,1 say "Учреждение" get mlpu when .f. color cDataCSay
       @ row(),col()+2 say "Отделение" get motd when .f. color cDataCSay
  //
  ++j; @ j,1 say "ФИО" get mfio_kart ;
       reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
       valid {|g,o| update_get("mkomu"),update_get("mcompany"),;
                    update_get("mspolis"),update_get("mnpolis"),;
                    update_get("mvidpolis") }
       @ row(),col()+5 say "Д.р." get mdate_r when .f. color color14
  //
  ++j; @ j,1 say "Направление: дата" get mNPR_DATE
       @ j,col()+1 say "из МО" get mNPR_MO ;
            reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c)}},A__FUNCTION,,,.f.)} ;
            color colget_menu
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
  ++j; @ j,1 say "Дата процедуры" get mn_data ;
             valid {|g| f_k_data(g,1), mk_data := mn_data, f_k_data(g,2) }
  ++j; @ j,1 say "№ амбулаторной карты" get much_doc picture "@!" ;
             when diag_screen(2) .and. ;
                  (!(is_uchastok == 1 .and. is_task(X_REGIST)) .or. mem_edit_ist==2)
  ++j; @ j,1 say "Основной диагноз" get mkod_diag picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mn_data,mpol)
  ++j; @ j,1 say "Табельный номер лечащего врача" ;
             get MTAB_NOM pict "99999" valid {|g| v_kart_vrach(g,.t.) } ;
             when diag_screen(2)
       @ row(),col()+1 get mvrach when .f. color color14
  status_key("^<Esc>^ - выход без записи; ^<PgDn>^ - запись")
  if !empty(a_smert)
    n_message(a_smert,,"GR+/R","W+/R",,,"G+/R")
  endif
  count_edit += myread(,,++k_read)
  diag_screen(2)
  k := f_alert({padc("Выберите действие",60,".")},;
               {" Выход без записи "," Запись "," Возврат в редактирование "},;
               iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
  if k == 3
    loop
  elseif k == 2
    if m1komu < 5 .and. empty(m1company)
      if m1komu == 0     ; s := "СМО"
      elseif m1komu == 1 ; s := "компании"
      else               ; s := "комитета/МО"
      endif
      func_error(4,'Не заполнено наименование '+s)
      loop
    elseif m1komu == 0 .and. empty(mnpolis)
      func_error(4,'Не заполнен номер полиса')
      loop
    elseif mpol == "М"
      func_error(4,"Данная процедура выполняется только для женщин.")
      loop
    elseif empty(mn_data)
      func_error(4,"Не введена дата процедуры.")
      loop
    elseif empty(MTAB_NOM)
      func_error(4,"Не введен табельный номер врача")
      loop
    elseif empty(m1NPR_MO)
      func_error(4,"Не введена направившая медицинская организация")
      loop
    elseif left(mkod_diag,1) == "Z" .and. !(alltrim(mkod_diag) == "Z01.7")  
      func_error(4,"Основной диагноз на Z может быть только Z01.7")
      loop
    endif
    if empty(mkod_diag)
      mkod_diag := "Z01.7 "
    endif
    arr_iss := array(1,9) ; afillall(arr_iss,0)
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","P2")
    find (str(MTAB_NOM,5))
    if found()
      arr_iss[1,1] := p2->kod
      arr_iss[1,2] := -ret_new_spec(p2->prvs,p2->prvs_new) 
    endif
    arr_iss[1,4] := 34 // профиль - клиническая лабораторная диагностика
    if ascan(glob_klin_diagn,1) > 0 // жидкостной цитологии
      arr_iss[1,5] := "4.20.702" // шифр услуги
    elseif ascan(glob_klin_diagn,2) > 0 // пренатального скрининга
      arr_iss[1,5] := "4.15.746" // шифр услуги
    endif
    err_date_diap(mn_data,"Дата диагностики")
    //
    if mem_op_out == 2 .and. yes_parol
      box_shadow(19,10,22,69,cColorStMsg)
      str_center(20,'Оператор "'+fio_polzovat+'".',cColorSt2Msg)
      str_center(21,'Ввод данных за '+date_month(sys_date),cColorStMsg)
    endif
    mywait()
    //
    sv1 := MTAB_NOM
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
        arr_iss[i,7] := foundOurUsluga(arr_iss[i,5],mn_data,arr_iss[i,4],M1VZROS_REB,@mu_cena)
        arr_iss[i,8] := mu_cena
        mcena_1 += mu_cena
        aadd(arr_usl_dop,arr_iss[i])
      endif
    next
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
    human_->KOD_DIAG0 := ""
    human->KOD_DIAG   := MKOD_DIAG     // шифр 1-ой осн.болезни
    human->KOD_DIAG2  := ""
    human->KOD_DIAG3  := ""
    human->KOD_DIAG4  := ""
    human->SOPUT_B1   := ""
    human->SOPUT_B2   := ""
    human->SOPUT_B3   := ""
    human->SOPUT_B4   := ""
    human->diag_plus  := ""            //
    human->ZA_SMO     := 0
    human->KOMU       := M1KOMU        // от 0 до 5
    human_->SMO       := msmo
    human->STR_CRB    := m1str_crb
    human->POLIS      := make_polis(mspolis,mnpolis) // серия и номер страхового полиса
    human->LPU        := M1LPU         // код учреждения
    human->OTD        := M1OTD         // код отделения
    human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
    human->N_DATA     := MN_DATA       // дата начала лечения
    human->K_DATA     := MN_DATA       // дата окончания лечения
    human->CENA := human->CENA_1 := MCENA_1 // стоимость лечения
    human->ishod      := 98 // жидкостная цитология рака шейки матки
    human->bolnich    := 0
    human->date_b_1   := ""
    human->date_b_2   := ""
    human_->RODIT_DR  := ctod("")
    human_->RODIT_POL := ""
    human_->DISPANS   := replicate("0",16)
    human_->STATUS_ST := ""
    human_->POVOD     := 9 // {"2.6-Посещение по другим обстоятельствам", 9,"2.6"},;
    //human_->TRAVMA    := m1travma
    human_->VPOLIS    := m1vidpolis
    human_->SPOLIS    := ltrim(mspolis)
    human_->NPOLIS    := ltrim(mnpolis)
    human_->OKATO     := "" // это поле вернётся из ТФОМС в случае иногороднего
    human_->NOVOR     := 0
    human_->DATE_R2   := ctod("")
    human_->POL2      := ""
    human_->USL_OK    := 3
    human_->VIDPOM    := 13
    human_->PROFIL    := 34 // клинической лабораторной диагностике
    human_->IDSP      := 4 // лечебно-диагностическая процедура
    human_->NPR_MO    := m1NPR_MO
    human_->FORMA14   := '0000'
    human_->KOD_DIAG0 := ''
    human_->RSLT_NEW  := 314 // динамическое наблюдение
    human_->ISHOD_NEW := 304 // исход = без перемен
    human_->VRACH     := arr_iss[1,1]
    human_->PRVS      := arr_iss[1,2]
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
    human_2->NPR_DATE := mNPR_DATE
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
      hu->kod_as  := 0
      hu->u_koef  := 1
      hu->u_kod   := arr_usl_dop[i,7]
      hu->u_cena  := arr_usl_dop[i,8]
      hu->is_edit := 0
      hu->date_u  := dtoc4(mn_data)
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
      hu_->kod_diag := mkod_diag
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
  if type("fl_edit_DDS") == "L"
    fl_edit_DDS := .t.
  endif
  if !empty(val(msmo))
    verify_OMS_sluch(glob_perso)
  endif
endif
return NIL

*

***** 15.02.18 вернуть тип вводимого листа учёта
Function ret_tip_lu(/*@*/stip)
Local k := 0
// V016.xml - Классификатор видов диспансеризации/профосмотров
//aadd(glob_V016, {201,"ДВ1","Первый этап диспансеризации определенных групп взрослого населения",stod("2016-01-01")})
//aadd(glob_V016, {202,"ДВ2","Второй этап диспансеризации определенных групп взрослого населения",stod("2016-01-01")})
//aadd(glob_V016, {203,"ОПВ","Профилактические медицинские осмотры взрослого населения",stod("2013-12-26")})
//aadd(glob_V016, {204,"ДВ3","Первый этап диспансеризации определенных групп взрослого населения (1 раз в 2 года)",stod("2018-01-01")})
//aadd(glob_V016, {205,"ДВ2","Второй этап диспансеризации определенных групп взрослого населения (1 раз в 2 года)",stod("2018-01-01")})
//aadd(glob_V016, {101,"ДС1","Диспансеризация пребывающих в стационарных учреждениях детей-сирот и детей, находящихся в трудной жизненной ситуации (состоящая из 1 этапа)",stod("2017-01-01")})
//aadd(glob_V016, {102,"ДС2","Диспансеризация пребывающих в стационарных учреждениях детей-сирот и детей, находящихся в трудной жизненной ситуации  (состоящая из 2-х этапов)",stod("2017-01-01")})
//aadd(glob_V016, {101,"ДУ1","Диспансеризация детей-сирот и детей, оставшихся без попечения родителей, в том числе усыновленных (удочеренных), принятых под опеку (попечительство) в приемную или патронатную семью  (состоящая из 1 этапа)",stod("2017-01-01")})
//aadd(glob_V016, {102,"ДУ2","Диспансеризация детей-сирот и детей, оставшихся без попечения родителей, в том числе усыновленных (удочеренных), принятых под опеку (попечительство) в приемную или патронатную семью  (состоящая из 2-х этапов)",stod("2017-01-01")})
//aadd(glob_V016, {301,"ОН1","Медицинские осмотры несовершеннолетних, в том числе при поступлении в образовательные учреждения и в период обучения в них (профилактические) (состоящие из 1 этапа)",stod("2017-01-01")})
//aadd(glob_V016, {302,"ОН2","Медицинские осмотры несовершеннолетних, в том числе при поступлении в образовательные учреждения и в период обучения в них (профилактические) (состоящие из 2-х этапов)",stod("2017-01-01")})
//aadd(glob_V016, {303,"ПО1","Медицинские осмотры несовершеннолетних, в том числе при поступлении в образовательные учреждения и в период обучения в них (предварительные) (состоящие из 1 этапа)",stod("2017-01-01")})
//aadd(glob_V016, {304,"ПО2","Медицинские осмотры несовершеннолетних, в том числе при поступлении в образовательные учреждения и в период обучения в них (предварительные) (состоящие из 2-х этапов)",stod("2017-01-01")})
//aadd(glob_V016, {305,"ОПН","Медицинские осмотры несовершеннолетних, в том числе при поступлении в образовательные учреждения и в период обучения в них (периодические)",stod("2017-01-01")})
stip := "   "
if between(human->ishod,101,102)
  k := iif(!empty(human->ZA_SMO), TIP_LU_DDS, TIP_LU_DDSOP)
  if human->ishod == 101
    stip := iif(!empty(human->ZA_SMO), "ДС1", "ДУ1")
  else //102
    stip := iif(!empty(human->ZA_SMO), "ДС2", "ДУ2")
  endif
elseif between(human->ishod,201,205)
  k := TIP_LU_DVN
  if human->ishod == 201
    stip := "ДВ1"
  elseif eq_any(human->ishod,202,205)
    stip := "ДВ2"
  elseif human->ishod == 204
    stip := "ДВ3"
  else // 203
    stip := "ОПВ"
  endif
elseif between(human->ishod,301,302)
  k := TIP_LU_PN
  if human->ishod == 301
    stip := "ОН1"
  else //302
    stip := "ОН2"
  endif
elseif between(human->ishod,303,304)
  k := TIP_LU_PREDN
  if human->ishod == 303
    stip := "ПО1"
  else // 304
    stip := "ПО2"
  endif
elseif human->ishod == 305
  k := TIP_LU_PERN
  stip := "ОПН"
elseif human->ishod == 98
  k := TIP_LU_G_CIT
elseif human->ishod == 99
  k := TIP_LU_PREND
endif
return k

*

***** 14.12.14 сравнение профилей с учётом изменения правил в 2014 году
Function f_profil_ginek_otolar(lp1,lp2)
Static arr_ginek := {2,136} // акушерству и гинекологии
Static arr_otolar := {64,162} // отоларингологии
Local fl := .f.
if lp1 == lp2
  fl := .t.
elseif ascan(arr_ginek,lp1) > 0
  fl := (ascan(arr_ginek,lp2) > 0)
elseif ascan(arr_otolar,lp1) > 0
  fl := (ascan(arr_otolar,lp2) > 0)
endif
return fl
