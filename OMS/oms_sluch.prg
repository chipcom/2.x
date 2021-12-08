#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

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
    elseif glob_otd[4] == TIP_LU_DVN_COVID // углубленная диспансеризация COVID
      return oms_sluch_DVN_COVID(Loc_kod,kod_kartotek)
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
    mmodpac := space(12),; // модель пациента по справочнику V022
    m1modpac := 0,; // модель пациента по справочнику V022
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

  private MTAB_NOM_NAPR := 0

  if mem_zav_l == 1  // да
    m1_l_z := 1   // да
  elseif mem_zav_l == 2  // нет
    m1_l_z := 0   // нет
  endif
  Private mad_cr := space(60), m1ad_cr := space(60), pr_ds_it := 0, input_ad_cr := .f.

  Private mm_ad_cr := {}
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

  // dbcreate(cur_dir+"tmp_onkna", {; // онконаправления
  //   {"KOD"      ,   "N",     7,     0},; // код больного
  //   {"NAPR_DATE",   "D",     8,     0},; // Дата направления
  //   {"NAPR_MO",     "C",     6,     0},; // код другого МО, куда выписано направление
  //   {"NAPR_V"  ,    "N",     1,     0},; // Вид направления:1-к онкологу,2-на биопсию,3-на дообследование,4-для опр.тактики лечения
  //   {"MET_ISSL" ,   "N",     1,     0},; // Метод диагностического исследования(при NAPR_V=3):1-лаб.диагностика;2-инстр.диагностика;3-луч.диагностика;4-КТ, МРТ, ангиография
  //   {"shifr"  ,     "C",    20,     0},;
  //   {"shifr_u"  ,   "C",    20,     0},;
  //   {"shifr1"   ,   "C",    20,     0},;
  //   {"name_u"   ,   "C",    65,     0},;
  //   {"U_KOD"    ,   "N",     6,     0},;  // код услуги
  //   {"KOD_VR"   ,   "N",     5,     0};  // код врача (справочник mo_pers)
  //   })

  dbcreate(cur_dir+"tmp_onkna", create_struct_temporary_onkna())

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
    m1modpac := human_2->PN5
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
        tnapr->KOD_VR    := napr->KOD_VR
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
  mPROFIL_K := inieditspr(A__MENUVERT, getV020(), m1PROFIL_K)
  mvid_reab := inieditspr(A__MENUVERT, mm_vid_reab, m1vid_reab)
  if !empty(m1NPR_MO)
    mNPR_MO := ret_mo(m1NPR_MO)[_MO_SHORT_NAME]
  endif
  mDS_ONK   := inieditspr(A__MENUVERT, mm_danet, M1DS_ONK)
  MVMP      := inieditspr(A__MENUVERT, mm_danet, M1VMP)
  MVIDVMP   := ret_V018(M1VIDVMP,mk_data)
  MMETVMP   := ret_V019(M1METVMP,M1VIDVMP,mk_data)
  mmodpac   := ret_V022(m1modpac,mk_data)
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
      ++j
      @ j,1 say "Учреждение" get mlpu when .f. color cDataCSay
      @ row(),col()+2 say "Отделение" get motd when .f. color cDataCSay
      //
      ++j
      @ j,1 say "ФИО" get mfio_kart ;
          reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
          valid {|g,o| update_get("mkomu"),update_get("mcompany"),;
            update_get("mspolis"),update_get("mnpolis"),;
            update_get("mvidpolis") }
      //
      ++j
      @ j,1 say "Направление: дата" get mNPR_DATE
      @ j,col()+1 say "из МО" get mNPR_MO ;
          reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c)}},A__FUNCTION,,,.f.)} ;
          color colget_menu
      //
      ++j
      @ j,1 say "Новорожденный?" get mnovor ;
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
      ++j
      @ j,1 say "Сроки лечения" get mn_data valid {|g|f_k_data(g,1)}
      @ row(),col()+1 say "-"   get mk_data valid {|g|f_k_data(g,2)}
      @ row(),col()+3 get mvzros_reb when .f. color cDataCSay
      if yes_vypisan == B_END
        @ row(),col()+5 say " Лечение завершено?" color "G+/B"
        @ row(),col()+1 get m_l_z ;
            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
            color "GR+/B"
      endif
      //
      ++j
      @ j,1 say "№ амб.карты (истории)" get much_doc picture "@!" ;
          when when_uch_doc
      @ row(),col()+1 say "Врач" get MTAB_NOM pict "99999" ;
          valid {|g| v_kart_vrach(g,.t.) } when diag_screen(2)
      @ row(),col()+1 get mvrach when .f. color color14
      //
      ++j
      @ j,1 say "Первичный диагноз" get mkod_diag0 picture pic_diag reader {|o| MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.t.,mk_data,iif(m1novor==0,mpol,mpol2)) ;
          when diag_screen(2) .and. when_diag()
      //if yes_bukva // если в настройке для отделения - работа со статусом стом.больного
      //     @ j,34 say "Статус стоматологического больного" get mstatus_st picture "@!" ;
      //           when diag_screen(2) ;
      //           valid {|g| f_valid_status_st(g) }
      //endif 
      ++j
      rdiag := j
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
      ++j
      @ j,1 say "Сопутствующие диагнозы " get mkod_diag2 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
      @ row(),col() say ","               get mkod_diag3 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
      @ row(),col() say ","               get mkod_diag4 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
      @ row(),col() say ","               get msoput_b1  picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
      @ row(),col() say ","               get msoput_b2  picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
      @ row(),col() say ","               get msoput_b3  picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
      @ row(),col() say ","               get msoput_b4  picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
      ++j
      @ j,1 say "Диагнозы осложнения    " get mosl1 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.f.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
      @ row(),col() say ","               get mosl2 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.f.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
      @ row(),col() say ","               get mosl3 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.f.,.t.,mk_data,iif(m1novor==0,mpol,mpol2))
      //
      ++j
      @ j,1 say "Принадлежность счёта" get mkomu ;
          reader {|x|menu_reader(x,mm_komu,A__MENUVERT,,,.f.)} ;
          valid {|g,o| f_valid_komu(g,o) } ;
          color colget_menu
      @ row(),col()+1 say "==>" get mcompany ;
          reader {|x|menu_reader(x,mm_company,A__MENUVERT,,,.f.)} ;
          when diag_screen(2) .and. m1komu < 5 ;
          valid {|g| func_valid_ismo(g,m1komu,38) }
      //
      ++j
      @ j,1 say "Полис ОМС: серия" get mspolis when m1komu == 0
      @ row(),col()+3 say "номер"  get mnpolis when m1komu == 0
      @ row(),col()+3 say "вид"    get mvidpolis ;
          reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT,,,.f.)} ;
          when m1komu == 0 ;
          valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
      //
      ++j
      rpp := j
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
        ++j
        @ j,3 say "вид объёмов специализированной медицинской помощи" get mreg_lech ;
            reader {|x|menu_reader(x,mm_reg_lech,A__MENUVERT,,,.f.)} ;
            when eq_any(m1usl_ok,1,2)
      endif
      ++j
      @ j,3 say "профиль мед.помощи" get MPROFIL ;
          reader {|x|menu_reader(x,tmp_V002,A__MENUVERT,,,.f.)} ;
          valid f_valid2ad_cr()
      ++j
      @ j,3 say "профиль койки" get MPROFIL_K ;
          reader {|x|menu_reader(x,tmp_V020,A__MENUVERT,,,.f.)} ;
          when eq_any(m1usl_ok,1,2)
      if is_reabil_slux
        ++j
        @ j,3 say "вид мед.реабилитации" get mvid_reab ;
            reader {|x|menu_reader(x,mm_vid_reab,A__MENUVERT,,,.f.)} ;
            when eq_any(m1usl_ok,1,2) .and. m1profil == 158
      endif
      //
      ++j
      @ j,1 say "Результат обращения" get mrslt ;
          reader {|x|menu_reader(x,mm_rslt,A__MENUVERT,,,.f.)} ;
          valid {|g,o| f_valid_rslt(g,o) }
      //
      ++j
      @ j,1 say "Исход заболевания" get mishod ;
          reader {|x|menu_reader(x,mm_ishod,A__MENUVERT,,,.f.)}
      //
      ++j
      @ j,1 say "Госпитализирован" get MF14_EKST ;
          reader {|x|menu_reader(x,mm_ekst,A__MENUVERT,,,.f.)} ;
          valid {|g,o| f_valid_f14_ekst(g,o) }
      @ row(),col()+3 say "Доставлен скорой помощью" get MF14_SKOR ;
          reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
          when M1F14_EKST == 1
      ++j
      @ j,3 say "вскрытие" get MF14_VSKR ;
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
      ++j
      p_nstr_vnr := j
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
      ++j
      p_nstr_ad_cr := j
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
        ++j
        @ j,1 say "ВМП?" get MVMP ;
            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
            when m1usl_ok==1 .or. (m1usl_ok==2 .and. is_ds_VMP) ;
            valid {|g,o| f_valid_vmp(g,o) } ;
            color colget_menu
        @ j,col()+1 say "номер талона" get mTAL_NUM PICTURE '@S12' when m1vmp == 1
        @ j,col()+1 say "выдан" get mTAL_D when m1vmp == 1
        @ j,col()+1 say "план. госп-ция" get mTAL_P when m1vmp == 1
        ++j
        @ j,1 say " вид ВМП" get mvidvmp ;
            reader {|x|menu_reader(x,{{|k,r,c|f_get_vidvmp(k,r,c)}},A__FUNCTION,,,.f.)} ;
            when m1vmp == 1 ;
            valid {|g,o| f_valid_vidvmp(g,o) } ;
            color colget_menu
        ++j
        @ j,1 say " модель" get mmodpac ;
            reader {|x|menu_reader(x,{{|k,r,c|f_get_mmodpac(k,r,c,m1vidvmp, mkod_diag)}},A__FUNCTION,,,.f.)} ;
            when m1vmp == 1 ;
            color colget_menu
            // valid {|g,o| f_valid_mmodpac(g,o) } ;
        ++j
        @ j,1 say " метод ВМП" get mmetvmp ;
            reader {|x|menu_reader(x,{{|k,r,c|f_get_metvmp(k,r,c,m1vidvmp,m1modpac)}},A__FUNCTION,,,.f.)} ;
            when m1vmp == 1 .and. !empty(m1vidvmp) ;  //   valid {|| f_valid_metvmp(m1metvmp) } ;
            color colget_menu
            // reader {|x|menu_reader(x,{{|k,r,c|f_get_metvmp(k,r,c,m1vidvmp, mkod_diag)}},A__FUNCTION,,,.f.)} ;
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
      ++j
      @ j,1 say "Больничный" get mbolnich ;
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

        MTAB_NOM_NAPR := get_tabnom_vrach_by_kod(tnapr->KOD_VR)

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
      @ ++j,1 say "ФИО" get mfio_kart when .f.
      @ j,57 get mn_data when .f.
      @ row(),col()+1 say "-" get mk_data when .f.

      @ ++j,1 say "НАПРАВЛЕНИЕ №" get cur_napr pict "99" when .f.
      @ j,col() say "(из" get count_napr pict "99" when .f.
      @ j,col() say ")"
      @ j,29 say "(<F5> - добавление/редактирование направления №...)" color "G/B"

      @ ++j,3 say "Дата направления" get mNAPR_DATE ;
                valid {|| iif(empty(mNAPR_DATE) .or. between(mNAPR_DATE,mn_data,mk_data), .t., ;
                               func_error(4,"Дата направления должна быть внутри сроков лечения")) }
      @ ++j,3 say "В какую МО направлен" get mnapr_mo ;
                reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c)}},A__FUNCTION,,,.f.)}
      @ ++j,3 say "Вид направления" get mnapr_v ;
                reader {|x|menu_reader(x,mm_napr_v,A__MENUVERT,,,.f.)} //; color colget_menu
      @ ++j,5 say "Метод диагностического исследования" get mmet_issl ;
                reader {|x|menu_reader(x,mm_met_issl,A__MENUVERT,,,.f.)} ;
                when m1napr_v == 3 //; color colget_menu
      @ ++j,5 say "Медицинская услуга" get mshifr pict "@!" ;
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
      @ ++j,7 say "Услуга" get mname_u when .f. color color14
      @ ++j,3 say "Табельный номер направившего врача" get MTAB_NOM_NAPR pict "99999" ;
          valid {|g| iif((m1napr_v != 0) .and. (MTAB_NOM_NAPR == 0) .and. v_kart_vrach(g), func_error(4, 'Необходимо указать табельный направившего врача'),.t.) }
    if is_oncology == 2
      @ ++j,1 say "СВЕДЕНИЯ О СЛУЧАЕ ЛЕЧЕНИЯ ОНКОЛОГИЧЕСКОГО ЗАБОЛЕВАНИЯ"
      @ ++j,3 say "Повод обращения" get mDS1_T ;
                 reader {|x|menu_reader(x,lmm_DS1_T,A__MENUVERT,,,.f.)} ;
                 color colget_menu
      @ ++j,3 say "Стадия заболевания:" get mSTAD ;
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
      @ ++j,5 say "Наличие отдаленных метастазов (при рецидиве или прогрессировании)" get mMTSTZ ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                 when eq_any(m1DS1_T,1,2) ;
                 color colget_menu
    if len(mm_N009) == 0 .and. len(mm_N012) == 0
      if is_gisto
        @ ++j,3 say "Результаты гистологии" get mrez_gist ;
                 reader {|x|menu_reader(x,{{|k,r,c| get_rez_gist(k,r,c)}},A__FUNCTION,,,.f.)}
      else
        @ ++j,3 say "Гистология / иммуногистохимия: не нужно для "+iif(is_mgi, "МГИ", mkod_diag)
      endif
    else
      @ ++j,3 say "Гистология / иммуногистохимия" get mB_DIAG ;
                 reader {|x|menu_reader(x,mmb_diag,A__MENUVERT,,,.f.)}
      @ ++j,3 say "Дата взятия материала" get mDIAG_DATE ;
                 when eq_any(m1b_diag,97,98) ;
                 valid {|| iif(empty(mDIAG_DATE) .or. mDIAG_DATE <= mk_data, .t., ;
                               func_error(4,"Дата взятия материала больше даты окончания лечения")) }
      if len(mm_N009) == 0
        @ ++j,3 say "Гистология: не нужно для "+iif(is_mgi, "МГИ", mkod_diag)
      else
        @ ++j,3 say mm_N009[1,1] get mgist1 ;
                 reader {|x|menu_reader(x,mm_N009[1,3],A__MENUVERT,,,.f.)} ;
                 when m1b_diag == 98 ;
                 color colget_menu
        if len(mm_N009) >= 2
          @ ++j,3 say mm_N009[2,1] get mgist2 ;
                 reader {|x|menu_reader(x,mm_N009[2,3],A__MENUVERT,,,.f.)} ;
                 when m1b_diag == 98 ;
                 color colget_menu
        endif
      endif
      if len(mm_N012) == 0
        @ ++j,3 say "Иммуногистохимия: не нужно для "+iif(is_mgi, "МГИ", mkod_diag)
      else
        @ ++j,3 say mm_N012[1,1] get mmark1 ;
                 reader {|x|menu_reader(x,mm_N012[1,3],A__MENUVERT,,,.f.)} ;
                 when m1b_diag == 98 ;
                 color colget_menu
      if len(mm_N012) >= 2
        @ ++j,3 say mm_N012[2,1] get mmark2 ;
                 reader {|x|menu_reader(x,mm_N012[2,3],A__MENUVERT,,,.f.)} ;
                 when m1b_diag == 98 ;
                 color colget_menu
      endif
      if len(mm_N012) >= 3
        @ ++j,3 say mm_N012[3,1] get mmark3 ;
                 reader {|x|menu_reader(x,mm_N012[3,3],A__MENUVERT,,,.f.)} ;
                 when m1b_diag == 98 ;
                 color colget_menu
      endif
      if len(mm_N012) >= 4
        @ ++j,3 say mm_N012[4,1] get mmark4 ;
                 reader {|x|menu_reader(x,mm_N012[4,3],A__MENUVERT,,,.f.)} ;
                 when m1b_diag == 98 ;
                 color colget_menu
      endif
      if len(mm_N012) >= 5
        @ ++j,3 say mm_N012[5,1] get mmark5 ;
                 reader {|x|menu_reader(x,mm_N012[5,3],A__MENUVERT,,,.f.)} ;
                 when m1b_diag == 98 ;
                 color colget_menu
      endif
     endif
    endif
    @ ++j,3 say "Консилиум: дата" get mDT_CONS ;
               valid {|| iif(empty(mDT_CONS) .or. between(mDT_CONS,mn_data,mk_data), .t., ;
                             func_error(4,"Дата консилиума должна быть внутри сроков лечения")) }
    @ j,col()+1 say "проведение" get mPR_CONS ;
               reader {|x|menu_reader(x,mm_PR_CONS,A__MENUVERT,,,.f.)} ;
               when !empty(mDT_CONS) ;
               color colget_menu
    if m1usl_ok < 3
      @ ++j,3 say "Проведённое лечение" get musl_tip ;
                 reader {|x|menu_reader(x,mm_usl_tip,A__MENUVERT,,,.f.)} ;
                 when len(mm_usl_tip) > 1 ;
                 valid {|g,o| f_valid_usl_tip(g,o) } ;
                 color colget_menu
      @ ++j,5 get lstr1 color color1 when .f.
           @ j,col()+1 get musl_tip1 ;
                 reader {|x|menu_reader(x,mm_usl_tip1,A__MENUVERT,,,.f.)} ;
                 when between(m1usl_tip,1,4)
      @ ++j,5 get lstr2 color color1 when .f.
      @ j,col()+1 get musl_tip2 ;
                 reader {|x|menu_reader(x,mm_usl_tip2,A__MENUVERT,,,.f.)} ;
                 when m1usl_tip == 2
      if fl_3_4
        @ ++j,5 get lstr_sod color color1 when .f.
        @ j,col()+1 get msod when between(m1usl_tip,3,4)
        @ j,col()+5 get lstr_fr color color1 when .f.
        @ j,col()+1 get mk_fr when between(m1usl_tip,3,4)
      endif
      if fl_2_4
        @ ++j,5 get lstr_wei color color1 when .f.
        @ j,col()+1 get mwei when eq_any(m1usl_tip,2,4)
        @ j,col()+1 get lstr_hei color color1 when .f.
        @ j,col()+1 get mhei when eq_any(m1usl_tip,2,4)
        @ j,col()+1 get lstr_bsa color color1 when .f.
        @ j,col()+1 get mbsa when eq_any(m1usl_tip,2,4)
        @ ++j,5 get lstr_err color color1 when .f.
        @ j,col()+1 get mis_err ;
                reader {|x|menu_reader(x,mm_shema_err,A__MENUVERT,,,.f.)} ;
                when m1usl_tip == 2
        @ ++j,5 get lstr_she color color1 when .f.
        @ j,col()+1 get mcrit ;
                reader {|x| menu_reader(x,mm_shema_usl,A__MENUVERT,,,.f.)} ;
                when eq_any(m1usl_tip,2,4)
        @ ++j,5 get lstr_lek color color1 when .f.
        @ j,col()+1 get mlek ;
                reader {|x|menu_reader(x,{{|k,r,c| get_lek_pr(k,r,c,m1crit)}},A__FUNCTION,,,.f.)} ;
                when !empty(m1crit) .and. eq_any(m1usl_tip,2,4)
        @ ++j,5 get lstr_ptr color color1 when .f.
        @ j,col()+1 get mpptr ;
                reader {|x| menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when eq_any(m1usl_tip,2,4)
      endif
      if is_onko_VMP .and. mtipvmp == 1 // две услуги
        @ ++j,3 say "ВМП: дополнительное лечение" get musl_vmp when .f. ;
                color colget_menu
        @ ++j,5 get lstr_vmp1 color color1 when .f.
        @ j,col()+1 get musl_vmp1 ;
                reader {|x|menu_reader(x,mm_usl_vmp1,A__MENUVERT,,,.f.)}
        @ ++j,5 get lstr_vmp2 color color1 when .f.
        @ j,col()+1 get musl_vmp2 ;
                reader {|x|menu_reader(x,mm_usl_vmp2,A__MENUVERT,,,.f.)} ;
                when m1usl_vmp == 2
        if fl2_3_4
          @ ++j,5 get lstr_vmpsod color color1 when .f.
          @ j,col()+1 get msod_vmp when between(m1usl_vmp,3,4)
          @ j,col()+5 get lstr_vmpfr color color1 when .f.
          @ j,col()+1 get mk_fr when between(m1usl_vmp,3,4)
        endif
        if fl2_2_4
          @ ++j,5 get lstr_vmpwei color color1 when .f.
          @ j,col()+1 get mwei when eq_any(m1usl_vmp,2,4)
          @ j,col()+1 get lstr_vmphei color color1 when .f.
          @ j,col()+1 get mhei when eq_any(m1usl_vmp,2,4)
          @ j,col()+1 get lstr_vmpbsa color color1 when .f.
          @ j,col()+1 get mbsa when eq_any(m1usl_vmp,2,4)
          @ ++j,5 get lstr_vmperr color color1 when .f.
          @ j,col()+1 get mis_err ;
                reader {|x|menu_reader(x,mm_shema_err,A__MENUVERT,,,.f.)} ;
                when m1usl_vmp == 2
          @ ++j,5 get lstr_vmpshe color color1 when .f.
          @ j,col()+1 get mcrit ;
                reader {|x| menu_reader(x,mm_shema_usl,A__MENUVERT,,,.f.)} ;
                when eq_any(m1usl_vmp,2,4)
          @ ++j,5 get lstr_vmplek color color1 when .f.
          @ j,col()+1 get mlek ;
                reader {|x|menu_reader(x,{{|k,r,c| get_lek_pr(k,r,c,m1crit)}},A__FUNCTION,,,.f.)} ;
                when !empty(m1crit) .and. eq_any(m1usl_vmp,2,4)
          @ ++j,5 get lstr_vmpptr color color1 when .f.
          @ j,col()+1 get mpptr ;
                reader {|x| menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when eq_any(m1usl_vmp,2,4)
        endif
      endif
      //
      arr := {"хирургического лечения","химиотерапевтического лечения","лучевой терапии"}
      @ ++j,3 say "Противопоказания к проведению:"
      @ j,50 say "дата регистрации:"
      for i := 1 to 3
        mval := "mprot"+lstr(i)
        mdval := "mdprot"+lstr(i)
        @ ++j,5 say arr[i] get &mval ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                color colget_menu
        @ j,53 get &mdval
      next i
      @ ++j,3 say "Отказы от проведения:"
      @ j,50 say "дата регистрации:"
      for i := 4 to 6
        mval := "mprot"+lstr(i)
        mdval := "mdprot"+lstr(i)
        @ ++j,5 say arr[i-3] get &mval ;
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

        tnapr->KOD_VR:= get_kod_vrach_by_tabnom(MTAB_NOM_NAPR)

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
          elseif empty(m1modpac) .and. year(mk_data) >= 2021
            func_error(4,'Не заполнена модель пациента ВМП')
            loop
          endif
        else
          M1VIDVMP := ""
          M1METVMP := 0
          m1modpac := 0
        endif
      else
        M1VMP := 0
        M1VIDVMP := ""
        M1METVMP := 0
        m1modpac := 0
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
      human_2->PN5    := m1modpac
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

      // if year(mk_data)  == 2021 .and. !empty(m1KSLP)  // учет КСЛП
      //   human_2->PC1 := m1KSLP // список КСЛП
      // endif

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
            napr->KOD_VR := tnapr->KOD_VR
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
  