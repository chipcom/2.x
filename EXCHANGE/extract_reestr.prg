#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 21.01.22 вынуть реестр из XML-файлов и записать во временные DBF-файлы
Function extract_reestr(mkod,mname_xml,flag_tmp1,is_all,goal_dir)
  local p_tip_reestr
  local tmpSelect
  Local _table1 := {;
     {"KOD",      "N", 6,0},; // код
     {"N_ZAP",    "C",12,0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
     {"PR_NOV",   "C", 1,0},;
     {"ID_PAC",   "C",36,0},; //
     {"VPOLIS",   "C", 1,0},; //
     {"SPOLIS",   "C",10,0},; //
     {"NPOLIS",   "C",20,0},; //
     {"ENP",      "C",16,0},; //
     {"SMO",      "C", 5,0},; //
     {"SMO_OK",   "C", 5,0},; //
     {"SMO_NAM", "C",100,0},; //
     {"MO_PR",    "C", 6,0},; //
     {"NOVOR",    "C", 9,0},; //
     {"VNOV_D",   "C", 4,0},; // вес новорожденного в граммах
     {"INV",      "C", 1,0},; //
     {"DATA_INV", "C",10,0},; //
     {"REASON_INV","C",2,0},; //
     {"DS_INV",   "C",10,0},; //
     {"MSE",      "C", 1,0},; //
     {"KD_Z",     "C", 3,0},; //
     {"KD",       "C", 3,0},; //
     {"IDCASE",   "C",12,0},; //
     {"ID_C",     "C",36,0},; //
     {"SL_ID",    "C",36,0},; //
     {"DISP",     "C", 3,0},; //
     {"USL_OK",   "C", 2,0},; //
     {"VIDPOM",   "C", 4,0},; //
     {"F_SP",     "C", 1,0},; // удалено поле
     {"FOR_POM",  "C", 1,0},; // N1
     {"VID_HMP",  "C",12,0},; // C9
     {"ISHOD"   , "C", 3,0},; //
     {"VB_P"    , "C", 1,0},; //
     {"IDSP"    , "C", 2,0},; //
     {"SUMV"    , "C",10,0},; //
     {"METOD_HMP","C", 4,0},; // N4 // 12.02.21
     {"NPR_MO",   "C", 6,0},; //
     {"NPR_DATE", "C",10,0},; //
     {"EXTR",     "C", 1,0},; //
     {"LPU"     , "C", 6,0},; //
     {"LPU_1"   , "C", 8,0},; //
     {"PODR"    , "C", 8,0},; //
     {"PROFIL"  , "C", 3,0},; //
     {"PROFIL_K", "C", 3,0},; //
     {"DET"     , "C", 1,0},; //
     {"P_CEL",    "C", 3,0},; //
     {"TAL_D",    "C",10,0},; //
     {"TAL_P",    "C",10,0},; //
     {"TAL_NUM",  "C",20,0},; //
     {"VBR",      "C", 1,0},; //
     {"NHISTORY", "C",10,0},; //
     {"P_OTK",    "C", 1,0},; //
     {"P_PER",    "C", 1,0},; //
     {"DATE_Z_1", "C",10,0},; //
     {"DATE_Z_2", "C",10,0},; //
     {"DATE_1"  , "C",10,0},; //
     {"DATE_2"  , "C",10,0},; //
     {"DS0"   ,   "C", 6,0},; //
     {"DS1"   ,   "C", 6,0},; //
     {"DS1_PR",   "C", 1,0},; //
     {"PR_D_N",   "C", 1,0},; //
     {"DS2"   ,   "C", 6,0},; //
     {"DS2N"   ,  "C", 6,0},; //
     {"DS2N_PR",  "C", 1,0},; //
     {"DS2N_D",   "C", 1,0},; //
     {"DS2_2" ,   "C", 6,0},; //
     {"DS2N_2" ,  "C", 6,0},; //
     {"DS2N_2_PR","C", 1,0},; //
     {"DS2N_2_D", "C", 1,0},; //
     {"DS2_3" ,   "C", 6,0},; //
     {"DS2N_3" ,  "C", 6,0},; //
     {"DS2N_3_PR","C", 1,0},; //
     {"DS2N_3_D", "C", 1,0},; //
     {"DS2_4" ,   "C", 6,0},; //
     {"DS2N_4" ,  "C", 6,0},; //
     {"DS2N_4_PR","C", 1,0},; //
     {"DS2N_4_D", "C", 1,0},; //
     {"DS2_5" ,   "C", 6,0},; //
     {"DS2_6" ,   "C", 6,0},; //
     {"DS2_7" ,   "C", 6,0},; //
     {"DS3"   ,   "C", 6,0},; //
     {"DS3_2" ,   "C", 6,0},; //
     {"DS3_3" ,   "C", 6,0},; //
     {"DS_ONK",   "C", 1,0},; //
     {"C_ZAB" ,   "C", 1,0},; //
     {"DN"    ,   "C", 1,0},; //
     {"VNOV_M",   "C", 4,0},; // вес новорожденного в граммах
     {"VNOV_M_2", "C", 4,0},; // вес новорожденного в граммах
     {"VNOV_M_3", "C", 4,0},; // вес новорожденного в граммах
     {"CODE_MES1","C",20,0},; //
     {"SUM_M"   , "C",10,0},; //
     {"DS1_T"    ,"C", 1,0},; // Повод обращения:0 - первичное лечение;1 - рецидив;2 - прогрессирование
     {"PR_CONS"  ,"C", 1,0},; // Сведения о проведении консилиума:1 - определена тактика обследования;2 - определена тактика лечения;3 - изменена тактика лечения.
     {"DT_CONS"  ,"C",10,0},; // Дата проведения консилиума       Обязательно к заполнению при заполненном PR_CONS
     {"STAD"     ,"C", 3,0},; // Стадия заболевания       Заполняется в соответствии со справочником N002
     {"ONK_T"    ,"C", 3,0},; // Значение Tumor   Заполняется в соответствии со справочником N003
     {"ONK_N"    ,"C", 3,0},; // Значение Nodus   Заполняется в соответствии со справочником N004
     {"ONK_M"    ,"C", 3,0},; // Значение Metastasis      Заполняется в соответствии со справочником N005
     {"MTSTZ"    ,"C", 1,0},; // Признак выявления отдалённых метастазов  Подлежит заполнению значением 1 при выявлении отдалённых метастазов только при DS1_T=1 или DS1_T=2
     {"SOD"      ,"C", 6,0},;  // Суммарная очаговая доза Обязательно для заполнения при проведении лучевой или химиолучевой терапии (USL_TIP=3 или USL_TIP=4)
     {"K_FR"    , "C", 2,0},; //
     {"WEI"    ,  "C", 5,0},; //
     {"HEI"    ,  "C", 5,0},; //
     {"BSA"    ,  "C", 5,0},; //
     {"RSLT"    , "C", 3,0},; //
     {"ISHOD"   , "C", 3,0},; //
     {"IDSP"    , "C", 2,0},; //
     {"PRVS"    , "C", 9,0},; //
     {"IDDOKT",   "C",16,0},; //
     {"OS_SLUCH", "C", 2,0},; //
     {"COMENTSL", "C",250,0},; //
     {"ED_COL",   "C", 1,0},; //
     {"N_KSG",    "C",20,0},; //
     {"CRIT"    , "C",10,0},; //
     {"CRIT2"   , "C",10,0},; //
     {"SL_K"    , "C", 9,0},; //
     {"IT_SL"   , "C", 9,0},; //
     {"AD_CR"   , "C",10,0},; //
     {"DKK2"    , "C",10,0},; //
     {"kod_kslp", "C", 5,0},; //
     {"koef_kslp","C", 6,0},;  //
     {"kod_kslp2", "C", 5,0},; //
     {"koef_kslp2","C", 6,0},;  //
     {"kod_kslp3", "C", 5,0},; //
     {"koef_kslp3","C", 6,0},;  //
     {"CODE_KIRO","C", 1,0},; //
     {"VAL_K"   , "C", 5,0},; //
     {"NEXT_VISIT","C",10,0},; //
     {"TARIF" ,   "C",10,0}; //
  }
  Local _table2 := {;
     {"SLUCH",    "N", 6,0},; // номер случая
     {"KOD",      "N", 6,0},; // код
     {"IDCASE",   "C",12,0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
     {"IDSERV"  , "C",36,0},; //
     {"ID_U"    , "C",36,0},; //
     {"LPU"     , "C", 6,0},; //
     {"LPU_1"   , "C", 8,0},; //
     {"PODR"    , "C", 8,0},; //
     {"PROFIL"  , "C", 3,0},; //
     {"VID_VME" , "C",20,0},; //
     {"DET"     , "C", 1,0},; //
     {"P_OTK"   , "C", 1,0},; //
     {"DATE_IN" , "C",10,0},; //
     {"DATE_OUT", "C",10,0},; //
     {"DS"      , "C", 6,0},; //
     {"CODE_USL", "C",20,0},; //
     {"KOL_USL" , "C", 6,0},; //
     {"TARIF"   , "C",10,0},; //
     {"SUMV_USL", "C",10,0},; //
     {"USL_TIP"  ,"C", 1,0},; // Тип онкоуслуги в соответствии со справочником N013
     {"HIR_TIP"  ,"C", 1,0},; // Тип хирургического лечения При USL_TIP=1 в соответствии со справочником N014
     {"LEK_TIP_L","C", 1,0},; // Линия лекарственной терапии При USL_TIP=2 в соответствии со справочником N015
     {"LEK_TIP_V","C", 1,0},; // Цикл лекарственной терапии       При USL_TIP=2 в соответствии со справочником N016
     {"LUCH_TIP" ,"C", 1,0},; // Тип лучевой терапии      При USL_TIP=3,4 в соответствии со справочником N017
     {"PRVS"    , "C", 9,0},; //
     {"CODE_MD",  "C",16,0},; //
     {"COMENTU" , "C",250,0};  //
  }
  Local _table3 := {;
     {"KOD",      "N", 6,0},; // код
     {"ID_PAC",   "C",36,0},; // код записи о пациенте ;GUID пациента в листе учета;создается при добавлении записи
     {"FAM"  ,    "C",40,0},; //
     {"IM"   ,    "C",40,0},; //
     {"OT"   ,    "C",40,0},; //
     {"W"    ,    "C", 1,0},; //
     {"DR"   ,    "C",10,0},; //
     {"DOST" ,    "C", 1,0},; //
     {"TEL"  ,    "C",10,0},; //
     {"FAM_P",    "C",40,0},; //
     {"IM_P" ,    "C",40,0},; //
     {"OT_P" ,    "C",40,0},; //
     {"W_P"  ,    "C", 1,0},; //
     {"DR_P" ,    "C",10,0},; //
     {"DOST_P",   "C", 1,0},; //
     {"MR"   ,    "C",100,0},; //
     {"DOCTYPE",  "C", 2,0},; //
     {"DOCSER" ,  "C",10,0},; //
     {"DOCNUM" ,  "C",20,0},; //
     {"DOCDATE" , "C",10,0},; //
     {"DOCORG" ,  "C",255,0},; //
     {"SNILS",    "C",14,0},; //
     {"OKATOG" ,  "C",11,0},; //
     {"OKATOP",   "C",11,0}; //
  }
  Local _table4 := {;
     {"SLUCH",    "N", 6,0},; // номер случая
     {"KOD",      "N", 6,0},; // код
     {"IDCASE",   "C",12,0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
     {"CODE_SL",  "C", 5,0},; //
     {"VAL_C",    "C", 6,0};  //
  }
  Local _table5 := {;
     {"SLUCH",    "N", 6,0},; // номер случая
     {"KOD",      "N", 6,0},; // код
     {"IDCASE",   "C",12,0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
     {"NAZ_N"   , "C", 2,0},; // PRESCRIPTIONS - Номер по порядку
     {"NAZ_R"   , "C", 2,0},; // PRESCRIPTIONS - Код назначения
     {"NAZR"    , "C", 2,0},; // PRESCRIPTIONS - Код назначения
     {"NAZ_IDDT", "C",25,0},; // СНИЛС врача
     {"NAZ_SPDT", "C", 4,0},; // Код специальности врача V021
     {"NAZ_SP"  , "C", 5,0},; // специальность
     {"NAZ_V"   , "C", 1,0},; // назначение
     {"NAPR_DATE","C",10,0},; // Дата направления
     {"NAPR_MO",  "C", 6,0},; //
     {"NAZ_USL"  ,"C",15,0},;  // шифр услуги
     {"NAZ_PMP" , "C", 3,0},; //
     {"NAZ_PK"  , "C", 3,0}; //
  }
  Local _table6 := {;  // онконаправления
     {"SLUCH",    "N", 6,0},; // номер случая
     {"KOD",      "N", 6,0},; // код
     {"IDCASE",   "C",12,0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
     {"NAPR_DATE","C",10,0},; // Дата направления
     {"NAZ_IDDT", "C",25,0},; // СНИЛС врача
     {"NAZ_SPDT", "C", 4,0},; // Код специальности врача V021
     {"NAPR_MO",  "C", 6,0},; //
     {"NAPR_V"  , "C", 1,0},; // Вид направления:1-к онкологу,2-на биопсию,3-на дообследование,4-для опр.тактики лечения
     {"MET_ISSL" ,"C", 1,0},; // Метод диагностического исследования(при NAPR_V=3):1-лаб.диагностика;2-инстр.диагностика;3-луч.диагностика;4-КТ, МРТ, ангиография
     {"U_KOD"    ,"C",15,0};  // шифр услуги
  }
  Local _table7 := {;  // Диагностический блок
     {"SLUCH",    "N", 6,0},; // номер случая
     {"KOD",      "N", 6,0},; // код
     {"IDCASE",   "C",12,0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
     {"DIAG_DATE","C",10,0},; // Дата взятия материала для проведения диагностики
     {"DIAG_TIP" ,"C", 1,0},; // Тип диагностического показателя: 1 - гистологический признак; 2 - маркёр (ИГХ)
     {"DIAG_CODE","C", 3,0},; // Код диагностического показателя При DIAG_TIP=1 в соответствии со справочником N007 При DIAG_TIP=2 в соответствии со справочником N010
     {"DIAG_RSLT","C", 3,0},;  // Код результата диагностики При DIAG_TIP=1 в соответствии со справочником N008 При DIAG_TIP=2 в соответствии со справочником N011
     {"REC_RSLT", "C", 1,0};
  }
  Local _table8 := {;  // Сведения об имеющихся противопоказаниях
     {"SLUCH",    "N", 6,0},; // номер случая
     {"KOD",      "N", 6,0},; // код
     {"IDCASE",   "C",12,0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
     {"PROT"     ,"C", 1,0},; // Код противопоказания или отказа в соответствии со справочником N001
     {"D_PROT"   ,"C",10,0};  // Дата регистрации противопоказания или отказа
  }
  Local _table9 := {;  // Сведения об онкологических услугах
     {"SLUCH",    "N", 6,0},; // номер случая
     {"KOD",      "N", 6,0},; // код
     {"IDCASE",   "C",12,0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
     {"USL_TIP"  ,"C", 1,0},; // Тип онкоуслуги в соответствии со справочником N013
     {"HIR_TIP"  ,"C", 1,0},; // Тип хирургического лечения При USL_TIP=1 в соответствии со справочником N014
     {"LEK_TIP_L","C", 1,0},; // Линия лекарственной терапии При USL_TIP=2 в соответствии со справочником N015
     {"LEK_TIP_V","C", 1,0},; // Цикл лекарственной терапии       При USL_TIP=2 в соответствии со справочником N016
     {"LUCH_TIP" ,"C", 1,0},; // Тип лучевой терапии      При USL_TIP=3,4 в соответствии со справочником N017
     {"PPTR"     ,"C", 1,0};
  }
  Local _table10 := {;  // Сведения об онкологических лек.препаратах
     {"SLUCH",    "N", 6,0},; // номер случая
     {"KOD",      "N", 6,0},; // код
     {"IDCASE",   "C",12,0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
     {"REGNUM",   "C", 6,0},;
     {"CODE_SH" , "C",10,0},;
     {"DATE_INJ" ,"C",10,0};
  }
  Local _table11 := {;  // Сведения лек.препаратах применявшихся при лечении
    {"SLUCH",    "N",   6, 0},; // номер случая
    {"KOD",      "N",   6, 0},; // код
    {"IDCASE",   "C",  12, 0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    {"DATA_INJ", "C",  10, 0},; // Дата введения лекарственного препарата
    {"CODE_SH",  "C",  10, 0},; // Код схемы лечения пациента/код группы препарата
    {"REGNUM",   "C",   6, 0},; // Идентификатор лекарственного препарата
    {"ED_IZM",   "C",   3, 0},; // Единица измерения дозы лекарственного препарата
    {"DOSE_INJ", "C",   8, 0},; // Доза введения лекарственного препарата
    {"METHOD_I", "C",   3, 0},; // Путь введения лекарственного препарата
    {"COL_INJ",  "C",   5, 0};  // Количество введений в течениедня, указанного в DATA_INJ
  }
  // {"COD_MARK",    "C", 100, 0},; // Код маркировки лекарственного препарата
  Local _table12 := {;  // Сведения об установленных имплантантах при лечении
    {"SLUCH",    "N",   6, 0},; // номер случая
    {"KOD",      "N",   6, 0},; // код
    {"IDCASE",   "C",  12, 0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    {"DATE_MED", "C",  10, 0},; // Дата установки имплантанта
    {"CODE_DEV", "C",  10, 0},; // Код вида медицинского изделия (имплантанта)
    {"NUM_SER",  "C", 100, 0}; // Серийный номер медицинского изделия (имплантанта)
  }


  Local arr_f, ii, oXmlDoc, j, j1, _ar, buf := save_maxrow(), name_zip := alltrim(mname_xml)+szip, fl := .f., is_old := .f.

  //
  DEFAULT flag_tmp1 TO .f., is_all TO .t., goal_dir TO dir_server+dir_XML_MO+cslash
  Private pole
  stat_msg("Распаковка/чтение/анализ "+iif(eq_any(left(mname_xml,3),"HRM","FRM"),"реестра ","счёта ")+mname_xml)

  p_tip_reestr := iif(left(mname_xml,3) == "HRM", 1, 2)

  if (arr_f := Extract_Zip_XML(goal_dir,name_zip)) != NIL
    fl := .t.
    dbcreate(cur_dir+"tmp_r_t1",_table1)
    dbcreate(cur_dir+"tmp_r_t1_1",_table1)
    dbcreate(cur_dir+"tmp_r_t2",_table2)
    dbcreate(cur_dir+"tmp_r_t3",_table3)
    dbcreate(cur_dir+"tmp_r_t4",_table4)
    dbcreate(cur_dir+"tmp_r_t5",_table5)
    dbcreate(cur_dir+"tmp_r_t6",_table6)
    dbcreate(cur_dir+"tmp_r_t7",_table7)
    dbcreate(cur_dir+"tmp_r_t8",_table8)
    dbcreate(cur_dir+"tmp_r_t9",_table9)
    dbcreate(cur_dir+"tmp_r_t10",_table10)
    dbcreate(cur_dir+"tmp_r_t11",_table11)
    dbcreate(cur_dir+"tmp_r_t12",_table12)
    use (cur_dir+"tmp_r_t1") new alias T1
    use (cur_dir+"tmp_r_t2") new alias T2
    use (cur_dir+"tmp_r_t3") new alias T3
    use (cur_dir+"tmp_r_t4") new alias T4
    use (cur_dir+"tmp_r_t5") new alias T5
    use (cur_dir+"tmp_r_t6") new alias T6
    use (cur_dir+"tmp_r_t7") new alias T7
    use (cur_dir+"tmp_r_t8") new alias T8
    use (cur_dir+"tmp_r_t9") new alias T9
    use (cur_dir+"tmp_r_t10") new alias T10
    use (cur_dir+"tmp_r_t11") new alias T11
    use (cur_dir+"tmp_r_t12") new alias T12
    use (cur_dir+"tmp_r_t1_1") new alias T1_1
    if flag_tmp1
      dbcreate(cur_dir+"tmp1file", {;
       {"_VERSION",   "C",  5,0},;
       {"_DATA",      "D",  8,0},;
       {"_FILENAME",  "C", 26,0},;
       {"_SD_Z",      "N",  9,0},;
       {"_CODE",      "N", 12,0},;
       {"_CODE_MO",   "C",  6,0},;
       {"_YEAR",      "N",  4,0},;
       {"_MONTH",     "N",  2,0},;
       {"_NSCHET",    "C", 15,0},;
       {"_DSCHET",    "D",  8,0},;
       {"_SUMMAV",    "N", 15,2},;
       {"_KOL",       "N",  6,0},;
       {"_MAX",       "N",  8,0};
      })
      use (cur_dir+"tmp1file") new alias TMP1
      append blank
    endif
    for ii := 1 to len(arr_f)
      // читаем файл в память
      oXmlDoc := HXMLDoc():Read(_tmp_dir1+arr_f[ii])
      if oXmlDoc == NIL .or. Empty( oXmlDoc:aItems )
        fl := func_error(4,"Ошибка в чтении файла "+arr_f[ii])
        exit
      endif
      FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
        @ maxrow(),1 say padr(lstr(ii)+"/"+lstr(j),8) color cColorSt2Msg
        oXmlNode := oXmlDoc:aItems[1]:aItems[j]
        do case
          case flag_tmp1 .and. "ZGLV" == oXmlNode:title
            tmp1->_VERSION :=          mo_read_xml_stroke(oXmlNode,"VERSION")
            if !eq_any(alltrim(tmp1->_VERSION),"3.11","3.2")
              is_old := .t.
              exit
            endif
            tmp1->_DATA    := xml2date(mo_read_xml_stroke(oXmlNode,"DATA"))
            tmp1->_FILENAME:=          mo_read_xml_stroke(oXmlNode,"FILENAME")
            tmp1->_SD_Z    :=      val(mo_read_xml_stroke(oXmlNode,"SD_Z",,.f.))
          case flag_tmp1 .and. "SCHET" == oXmlNode:title
            tmp1->_CODE    :=      val(mo_read_xml_stroke(oXmlNode,"CODE"))
            tmp1->_CODE_MO :=          mo_read_xml_stroke(oXmlNode,"CODE_MO")
            tmp1->_YEAR    :=      val(mo_read_xml_stroke(oXmlNode,"YEAR"))
            tmp1->_MONTH   :=      val(mo_read_xml_stroke(oXmlNode,"MONTH"))
            tmp1->_NSCHET  :=          mo_read_xml_stroke(oXmlNode,"NSCHET")
            tmp1->_DSCHET  := xml2date(mo_read_xml_stroke(oXmlNode,"DSCHET"))
            tmp1->_SUMMAV  :=      val(mo_read_xml_stroke(oXmlNode,"SUMMAV"))
          case "ZAP" == oXmlNode:title
            if is_all
              select T1
              append blank
              t1->kod := mkod
              t1->N_ZAP := mo_read_xml_stroke(oXmlNode,"N_ZAP")
              t1->PR_NOV := mo_read_xml_stroke(oXmlNode,"PR_NOV")
              if (oNode1 := oXmlNode:Find("PACIENT")) != NIL
                t1->ID_PAC  := mo_read_xml_stroke(oNode1,"ID_PAC")
                t1->VPOLIS  := mo_read_xml_stroke(oNode1,"VPOLIS")
                t1->SPOLIS  := mo_read_xml_stroke(oNode1,"SPOLIS",,.f.)
                t1->NPOLIS  := mo_read_xml_stroke(oNode1,"NPOLIS")
                t1->ENP     := mo_read_xml_stroke(oNode1,"ENP",,.f.)
                t1->SMO     := mo_read_xml_stroke(oNode1,"SMO",,.f.)
                t1->SMO_OK  := mo_read_xml_stroke(oNode1,"SMO_OK",,.f.)
                t1->SMO_NAM := mo_read_xml_stroke(oNode1,"SMO_NAM",,.f.)
                t1->MO_PR   := mo_read_xml_stroke(oNode1,"MO_PR",,.f.)
                t1->NOVOR   := mo_read_xml_stroke(oNode1,"NOVOR",,.f.)
                t1->VNOV_D  := mo_read_xml_stroke(oNode1,"VNOV_D",,.f.)
                if (oNode2 := oNode1:Find("DISABILITY")) != NIL
                  t1->INV        := mo_read_xml_stroke(oNode2,"INV")
                  t1->DATA_INV   := mo_read_xml_stroke(oNode2,"DATA_INV")
                  t1->REASON_INV := mo_read_xml_stroke(oNode2,"REASON_INV")
                  t1->DS_INV     := mo_read_xml_stroke(oNode2,"DS_INV",,.f.)
                endif
              endif
              if (oNode1 := oXmlNode:Find("Z_SL")) != NIL
                t1->IDCASE   := mo_read_xml_stroke(oNode1,"IDCASE")
                t1->ID_C     := mo_read_xml_stroke(oNode1,"ID_C")
                t1->DISP     := mo_read_xml_stroke(oNode1,"DISP",,.f.)  // 2
                t1->USL_OK   := mo_read_xml_stroke(oNode1,"USL_OK")
                t1->VIDPOM   := mo_read_xml_stroke(oNode1,"VIDPOM")
                t1->FOR_POM  := mo_read_xml_stroke(oNode1,"FOR_POM",,.f.)
                t1->ISHOD    := mo_read_xml_stroke(oNode1,"ISHOD")
                t1->VB_P     := mo_read_xml_stroke(oNode1,"VB_P",,.f.)
                t1->IDSP     := mo_read_xml_stroke(oNode1,"IDSP")
                t1->SUMV     := mo_read_xml_stroke(oNode1,"SUMV")
                t1->NPR_MO   := mo_read_xml_stroke(oNode1,"NPR_MO",,.f.)
                t1->NPR_DATE := mo_read_xml_stroke(oNode1,"NPR_DATE",,.f.)
                t1->LPU      := mo_read_xml_stroke(oNode1,"LPU")
                t1->VBR      := mo_read_xml_stroke(oNode1,"VBR",,.f.)
                t1->P_CEL    := mo_read_xml_stroke(oNode1,"P_CEL",,.f.)
                t1->P_OTK    := mo_read_xml_stroke(oNode1,"P_OTK",,.f.)
                t1->DATE_Z_1 := mo_read_xml_stroke(oNode1,"DATE_Z_1")
                t1->DATE_Z_2 := mo_read_xml_stroke(oNode1,"DATE_Z_2")
                t1->KD_Z     := mo_read_xml_stroke(oNode1,"KD_Z",,.f.)
                _ar := mo_read_xml_array(oNode1,"VNOV_M") // М.Б.НЕСКОЛЬКО VNOV_M
                for j1 := 1 to min(3,len(_ar))
                  pole := "t1->VNOV_M"+iif(j1==1, "", "_"+lstr(j1))
                  &pole := _ar[j1]
                next
                t1->RSLT := mo_read_xml_stroke(oNode1,"RSLT")
                t1->MSE := mo_read_xml_stroke(oNode1,"MSE",,.f.)
                iisl := 0
                for isl := 1 to len(oNode1:aitems) // последовательный просмотр
                  oNode11 := oNode1:aItems[isl]     // т.к. случаев м.б. несколько
                  if valtype(oNode11) != "C" .AND. oNode11:title == "SL"
                    ++iisl
                    if iisl == 1
                      lal := "t1"
                    else
                      if iisl > 2 // на всякий случай
                        fl := func_error(4,"Ошибка в файле "+arr_f[ii]+;
                                           ", зак.случай № "+alltrim(t1->IDCASE)+", случай № "+lstr(iisl))
                        exit
                      endif
                      lal := "t1_1"
                      select T1_1
                      append blank
                      t1_1->kod    := t1->kod
                      t1_1->N_ZAP  := t1->N_ZAP
                      t1_1->ID_PAC := t1->ID_PAC
                      t1_1->IDCASE := t1->IDCASE
                      t1_1->ID_C   := t1->ID_C
                    endif
                    &lal.->SL_ID     := mo_read_xml_stroke(oNode11,"SL_ID")
                    &lal.->VID_HMP   := mo_read_xml_stroke(oNode11,"VID_HMP",,.f.)
                    &lal.->METOD_HMP := mo_read_xml_stroke(oNode11,"METOD_HMP",,.f.)
                    &lal.->LPU_1     := mo_read_xml_stroke(oNode11,"LPU_1",,.f.)
                    &lal.->PODR      := mo_read_xml_stroke(oNode11,"PODR",,.f.)
                    &lal.->PROFIL    := mo_read_xml_stroke(oNode11,"PROFIL")
                    &lal.->PROFIL_K  := mo_read_xml_stroke(oNode11,"PROFIL_K",,.f.)
                    &lal.->DET       := mo_read_xml_stroke(oNode11,"DET",,.f.)
                    s := mo_read_xml_stroke(oNode11,"P_CEL",,.f.)
                    if !empty(s)
                      &lal.->P_CEL := s
                    endif
                    &lal.->TAL_D     := mo_read_xml_stroke(oNode11,"TAL_D",,.f.)
                    &lal.->TAL_P     := mo_read_xml_stroke(oNode11,"TAL_P",,.f.)
                    &lal.->TAL_NUM   := mo_read_xml_stroke(oNode11,"TAL_NUM",,.f.)
                    &lal.->NHISTORY  := mo_read_xml_stroke(oNode11,"NHISTORY")
                    &lal.->P_PER     := mo_read_xml_stroke(oNode11,"P_PER",,.f.)
                    &lal.->DATE_1    := mo_read_xml_stroke(oNode11,"DATE_1")
                    &lal.->DATE_2    := mo_read_xml_stroke(oNode11,"DATE_2")
                    &lal.->KD        := mo_read_xml_stroke(oNode11,"KD",,.f.)
                    &lal.->WEI       := mo_read_xml_stroke(oNode3,"WEI", , .f.)
                    &lal.->DS0       := mo_read_xml_stroke(oNode11,"DS0",,.f.)
                    &lal.->DS1       := mo_read_xml_stroke(oNode11,"DS1")
                    &lal.->DS1_PR    := mo_read_xml_stroke(oNode11,"DS1_PR",,.f.) // 2
                    &lal.->PR_D_N    := mo_read_xml_stroke(oNode11,"PR_D_N",,.f.) // 2
                    // DS2 для диспансеризации
                    j1 := 0
                    for i := 1 to len(oNode11:aitems) // последовательный просмотр
                      oNode2 := oNode11:aItems[i]     // т.к. м.б. несколько
                      if valtype(oNode2) != "C" .AND. oNode2:title == "DS2_N"
                        if ++j1 > 4 ; exit ; endif
                        pole := lal+"->DS2N"+iif(j1==1, "", "_"+lstr(j1))
                        &pole := mo_read_xml_stroke(oNode2,"DS2")
                        pole := lal+"->DS2N"+iif(j1==1, "", "_"+lstr(j1))+"_PR"
                        &pole := mo_read_xml_stroke(oNode2,"DS2_PR",,.f.)
                        pole := lal+"->DS2N"+iif(j1==1, "", "_"+lstr(j1))+"_D"
                        &pole := mo_read_xml_stroke(oNode2,"PR_D",,.f.)
                      endif
                    next
                    // DS2 для обычного листа учёта
                    _ar := mo_read_xml_array(oNode11,"DS2") // М.Б.НЕСКОЛЬКО DS2
                    for j1 := 1 to min(7,len(_ar))
                      pole := lal+"->DS2"+iif(j1==1, "", "_"+lstr(j1))
                      &pole := _ar[j1]
                    next
                    _ar := mo_read_xml_array(oNode11,"DS3") // М.Б.НЕСКОЛЬКО DS3
                    for j1 := 1 to min(3,len(_ar))
                      pole := lal+"->DS3"+iif(j1==1, "", "_"+lstr(j1))
                      &pole := _ar[j1]
                    next
                    &lal.->C_ZAB := mo_read_xml_stroke(oNode11,"C_ZAB",,.f.)
                    &lal.->DS_ONK := mo_read_xml_stroke(oNode11,"DS_ONK",,.f.)
                    &lal.->DN := mo_read_xml_stroke(oNode11,"DN",,.f.)
                    if (oNode3 := oNode11:Find("PRESCRIPTION")) != NIL
                      for i := 1 to len(oNode3:aitems) // последовательный просмотр
                        oNode2 := oNode3:aItems[i]     // т.к. назначений м.б. несколько
                        if valtype(oNode2) != "C" .AND. oNode2:title == "PRESCRIPTIONS"
                          select T5
                          append blank
                          t5->sluch  := iisl
                          t5->KOD    := mkod
                          t5->IDCASE := &lal.->IDCASE // для связи со случаем
                          t5->NAZ_N  := mo_read_xml_stroke(oNode2,"NAZ_N",,.f.)
                          t5->NAZ_R  := mo_read_xml_stroke(oNode2,"NAZ_R",,.f.)

                          // добавил по новому ПУМП от 02.08.21
                          if p_tip_reestr == 2 .and. (xml2date(t1->DATE_Z_2) >= 0d20210801)
                            t5->NAZ_IDDT  := mo_read_xml_stroke(oNode2,"NAZ_IDDOKT",,.f.)
                            t5->NAZ_SPDT  := mo_read_xml_stroke(oNode2,"NAZ_SPDOCT",,.f.)
                          endif
                                                    
                          t5->NAZ_SP := mo_read_xml_stroke(oNode2,"NAZ_SP",,.f.)
                          /*_ar := mo_read_xml_array(oNode2,"NAZ_SP") // М.Б.НЕСКОЛЬКО NAZ_SP
                          for j1 := 1 to min(3,len(_ar))
                            pole := "t5->NAZ_SP"+lstr(j1)
                            &pole := _ar[j1]
                          next*/
                          t5->NAZ_V := mo_read_xml_stroke(oNode2,"NAZ_V",,.f.)
                          /*_ar := mo_read_xml_array(oNode2,"NAZ_V") // М.Б.НЕСКОЛЬКО NAZ_V
                          for j1 := 1 to min(3,len(_ar))
                            pole := "t5->NAZ_V"+lstr(j1)
                            &pole := _ar[j1]
                          next*/
                          t5->NAZ_USL  := mo_read_xml_stroke(oNode2,"NAZ_USL",,.f.)
                          t5->NAPR_DATE:= mo_read_xml_stroke(oNode2,"NAPR_DATE",,.f.)
                          t5->NAPR_MO  := mo_read_xml_stroke(oNode2,"NAPR_MO",,.f.)
                          t5->NAZ_PMP  := mo_read_xml_stroke(oNode2,"NAZ_PMP",,.f.)
                          t5->NAZ_PK   := mo_read_xml_stroke(oNode2,"NAZ_PK",,.f.)
                        endif
                      next
                    endif
                    &lal.->CODE_MES1:= mo_read_xml_stroke(oNode11,"CODE_MES1",,.f.)
                    if (oNode3 := oNode11:Find("KSG_KPG")) != NIL
                      &lal.->N_KSG := mo_read_xml_stroke(oNode3,"N_KSG",,.f.)
                      _ar := mo_read_xml_array(oNode3,"CRIT") // М.Б.НЕСКОЛЬКО DS3
                      for j1 := 1 to min(2,len(_ar))
                        pole := lal+"->CRIT"+iif(j1==1, "", lstr(j1))
                        &pole := _ar[j1]
                      next
                      &lal.->SL_K  := mo_read_xml_stroke(oNode3,"SL_K",,.f.)
                      &lal.->IT_SL := mo_read_xml_stroke(oNode3,"IT_SL",,.f.)
                      jkslp := 0
                      for j1 := 1 to len(oNode3:aitems) // последовательный просмотр 
                        oNode2 := oNode3:aItems[j1]     // т.к. КСЛП м.б. несколько
                        if valtype(oNode2) != "C" .AND. oNode2:title == "SL_KOEF"
                          ++jkslp
                          if jkslp == 1
                            &lal.->kod_kslp  := mo_read_xml_stroke(oNode2,"ID_SL")
                            &lal.->koef_kslp := mo_read_xml_stroke(oNode2,"VAL_C")
                          elseif  jkslp == 3
                            &lal.->kod_kslp3 := mo_read_xml_stroke(oNode2,"ID_SL")
                            &lal.->koef_kslp3:= mo_read_xml_stroke(oNode2,"VAL_C")
                          else
                            &lal.->kod_kslp2 := mo_read_xml_stroke(oNode2,"ID_SL")
                            &lal.->koef_kslp2:= mo_read_xml_stroke(oNode2,"VAL_C")
                          endif
                        elseif valtype(oNode2) != "C" .AND. oNode2:title == "S_KIRO"
                          &lal.->CODE_KIRO := mo_read_xml_stroke(oNode2,"CODE_KIRO")
                          &lal.->VAL_K     := mo_read_xml_stroke(oNode2,"VAL_K")
                        endif
                      next j1
                    endif
                    for j1 := 1 to len(oNode11:aitems) // последовательный просмотр
                      oNode2 := oNode11:aItems[j1]     // т.к. услуг м.б. несколько
                      if valtype(oNode2) != "C" .AND. oNode2:title == "NAPR"
                        select T6
                        append blank
                        t6->sluch    := iisl
                        t6->KOD      := mkod
                        t6->IDCASE   := &lal.->IDCASE // для связи со случаем
                        t6->NAPR_DATE:= mo_read_xml_stroke(oNode2,"NAPR_DATE")
                        // добавил по новому ПУМП от 02.08.21
                        if p_tip_reestr == 2 .and. (xml2date(t1->DATE_Z_2) >= 0d20210801)
                          t6->NAZ_IDDT  := mo_read_xml_stroke(oNode2,"NAZ_IDDOKT",,.f.)
                          t6->NAZ_SPDT  := mo_read_xml_stroke(oNode2,"NAZ_SPDOCT",,.f.)
                        endif
                        t6->NAPR_MO  := mo_read_xml_stroke(oNode2,"NAPR_MO",,.f.)
                        t6->NAPR_V   := mo_read_xml_stroke(oNode2,"NAPR_V")
                        t6->MET_ISSL := mo_read_xml_stroke(oNode2,"MET_ISSL",,.f.)
                        t6->U_KOD    := mo_read_xml_stroke(oNode2,"NAPR_USL",,.f.)
                      elseif valtype(oNode2) != "C" .AND. oNode2:title == "CONS"
                        &lal.->PR_CONS := mo_read_xml_stroke(oNode2,"PR_CONS",,.f.)
                        &lal.->DT_CONS := mo_read_xml_stroke(oNode2,"DT_CONS",,.f.)
                      endif
                    next
                    if (oNode3 := oNode11:Find("ONK_SL")) != NIL
                      &lal.->DS1_T := mo_read_xml_stroke(oNode3,"DS1_T",,.f.)
                      &lal.->STAD  := mo_read_xml_stroke(oNode3,"STAD",,.f.)
                      &lal.->ONK_T := mo_read_xml_stroke(oNode3,"ONK_T",,.f.)
                      &lal.->ONK_N := mo_read_xml_stroke(oNode3,"ONK_N",,.f.)
                      &lal.->ONK_M := mo_read_xml_stroke(oNode3,"ONK_M",,.f.)
                      &lal.->MTSTZ := mo_read_xml_stroke(oNode3,"MTSTZ",,.f.)
                      &lal.->SOD   := mo_read_xml_stroke(oNode3,"SOD",,.f.)
                      &lal.->K_FR   := mo_read_xml_stroke(oNode3,"K_FR",,.f.)
                      &lal.->WEI   := mo_read_xml_stroke(oNode3,"WEI",,.f.)
                      &lal.->HEI   := mo_read_xml_stroke(oNode3,"HEI",,.f.)
                      &lal.->BSA   := mo_read_xml_stroke(oNode3,"BSA",,.f.)
                      for j1 := 1 to len(oNode3:aitems) // последовательный просмотр
                        oNode2 := oNode3:aItems[j1]     // т.к. услуг м.б. несколько
                        if valtype(oNode2) != "C" .AND. oNode2:title == "B_DIAG"
                          select T7
                          append blank
                          t7->sluch     := iisl
                          t7->KOD       := mkod
                          t7->IDCASE    := &lal.->IDCASE // для связи со случаем
                          t7->DIAG_DATE := mo_read_xml_stroke(oNode2,"DIAG_DATE",,.f.)
                          t7->DIAG_TIP  := mo_read_xml_stroke(oNode2,"DIAG_TIP",,.f.)
                          t7->DIAG_CODE := mo_read_xml_stroke(oNode2,"DIAG_CODE",,.f.)
                          t7->DIAG_RSLT := mo_read_xml_stroke(oNode2,"DIAG_RSLT",,.f.)
                          t7->REC_RSLT  := mo_read_xml_stroke(oNode2,"REC_RSLT",,.f.)
                        elseif valtype(oNode2) != "C" .AND. oNode2:title == "B_PROT"
                          select T8
                          append blank
                          t8->sluch  := iisl
                          t8->KOD    := mkod
                          t8->IDCASE := &lal.->IDCASE // для связи со случаем
                          t8->PROT   := mo_read_xml_stroke(oNode2,"PROT",,.f.)
                          t8->D_PROT := mo_read_xml_stroke(oNode2,"D_PROT",,.f.)
                        elseif valtype(oNode2) != "C" .AND. oNode2:title == "ONK_USL"
                          select T9
                          append blank
                          t9->sluch  := iisl
                          t9->KOD    := mkod
                          t9->IDCASE := &lal.->IDCASE // для связи со случаем
                          t9->USL_TIP  := mo_read_xml_stroke(oNode2,"USL_TIP",,.f.)
                          t9->HIR_TIP  := mo_read_xml_stroke(oNode2,"HIR_TIP",,.f.)
                          t9->LEK_TIP_L:= mo_read_xml_stroke(oNode2,"LEK_TIP_L",,.f.)
                          t9->LEK_TIP_V:= mo_read_xml_stroke(oNode2,"LEK_TIP_V",,.f.)
                          t9->LUCH_TIP := mo_read_xml_stroke(oNode2,"LUCH_TIP",,.f.)
                          t9->PPTR     := mo_read_xml_stroke(oNode2,"PPTR",,.f.)
                          for j2 := 1 to len(oNode2:aitems) // последовательный просмотр
                            oNode4 := oNode2:aItems[j2]     // т.к. услуг м.б. несколько
                            if valtype(oNode4) != "C" .AND. oNode4:title == "LEK_PR"
                              lREGNUM := mo_read_xml_stroke(oNode4,"REGNUM",,.f.)
                              lCODE_SH := mo_read_xml_stroke(oNode4,"CODE_SH",,.f.)
                              _ar := mo_read_xml_array(oNode4,"DATE_INJ") // М.Б.НЕСКОЛЬКО дат
                              for j3 := 1 to len(_ar)
                                select T10
                                append blank
                                t10->sluch  := iisl
                                t10->KOD    := mkod
                                t10->IDCASE := &lal.->IDCASE // для связи со случаем
                                t10->REGNUM := lREGNUM
                                t10->CODE_SH := lCODE_SH
                                t10->DATE_INJ := _ar[j3]
                              next j3
                            endif
                          next j2
                        endif
                      next j1
                    endif
                    &lal.->PRVS   := mo_read_xml_stroke(oNode11,"PRVS")
                    &lal.->IDDOKT := mo_read_xml_stroke(oNode11,"IDDOKT",,.f.)
                    &lal.->ED_COL := mo_read_xml_stroke(oNode11,"ED_COL",,.f.)
                    &lal.->TARIF  := mo_read_xml_stroke(oNode11,"TARIF",,.f.)
                    &lal.->SUM_M  := mo_read_xml_stroke(oNode11,"SUM_M")
/////// insert LEK_PR                    
                    for j1 := 1 to len(oNode11:aitems) // последовательный просмотр лекарственных препаратов
                      oNode2 := oNode11:aItems[j1]     // т.к. препаратов м.б. несколько
                      if valtype(oNode2) != "C" .AND. oNode2:title == "LEK_PR"
                        select T11
                        append blank
                        t11->sluch    := iisl
                        t11->KOD      := mkod
                        t11->IDCASE   := &lal.->IDCASE // для связи со случаем
                        t11->DATA_INJ := mo_read_xml_stroke(oNode2,"DATA_INJ")  // Дата введения лекарственного препарата
                        t11->CODE_SH  := mo_read_xml_stroke(oNode2,"CODE_SH")  // Код схемы лечения пациента/код группы препарата
                        t11->REGNUM   := mo_read_xml_stroke(oNode2,"REGNUM")  // Идентификатор лекарственного препарата
                        // t11->COD_MARK    := mo_read_xml_stroke(oNode2,"COD_MARK")
                        if (oNode3 := oNode2:Find("LEK_DOSE")) != NIL
                          t11->ED_IZM   := mo_read_xml_stroke(oNode3, "ED_IZM") // Единица измерения дозы лекарственного препарата
                          t11->DOSE_INJ := mo_read_xml_stroke(oNode3, "DOSE_INJ") // Доза введения лекарственного препарата
                          t11->METHOD_I := mo_read_xml_stroke(oNode3, "METHOD_INJ") // Путь введения лекарственного препарата
                          t11->COL_INJ  := mo_read_xml_stroke(oNode3, "COL_INJ") // Количество введений в течении дня, указанного в DATA_INJ
                        endif
                      endif
                    next j1
////////
                    &lal.->NEXT_VISIT := mo_read_xml_stroke(oNode11,"NEXT_VISIT",,.f.)
                    &lal.->COMENTSL := mo_read_xml_stroke(oNode11,"COMENTSL",,.f.)
                    for j1 := 1 to len(oNode11:aitems) // последовательный просмотр
                      oNode2 := oNode11:aItems[j1]     // т.к. услуг м.б. несколько
                      if valtype(oNode2) != "C" .AND. oNode2:title == "USL"
                        select T2
                        append blank
                        t2->sluch    := iisl
                        t2->KOD      := mkod
                        t2->IDCASE   := &lal.->IDCASE // для связи со случаем
                        t2->IDSERV   := mo_read_xml_stroke(oNode2,"IDSERV")
                        t2->ID_U     := mo_read_xml_stroke(oNode2,"ID_U")
                        t2->LPU      := mo_read_xml_stroke(oNode2,"LPU")
                        t2->LPU_1    := mo_read_xml_stroke(oNode2,"LPU_1",,.f.)
                        t2->PODR     := mo_read_xml_stroke(oNode2,"PODR",,.f.)
                        t2->PROFIL   := mo_read_xml_stroke(oNode2,"PROFIL")
                        t2->VID_VME  := mo_read_xml_stroke(oNode2,"VID_VME",,.f.)
                        t2->DET      := mo_read_xml_stroke(oNode2,"DET",,.f.)
                        t2->DATE_IN  := mo_read_xml_stroke(oNode2,"DATE_IN")
                        t2->DATE_OUT := mo_read_xml_stroke(oNode2,"DATE_OUT")
                        t2->P_OTK    := mo_read_xml_stroke(oNode2,"P_OTK",,.f.)
                        t2->DS       := mo_read_xml_stroke(oNode2,"DS",,.f.)
                        t2->CODE_USL := mo_read_xml_stroke(oNode2,"CODE_USL")
                        t2->KOL_USL  := mo_read_xml_stroke(oNode2,"KOL_USL")
                        t2->TARIF    := mo_read_xml_stroke(oNode2,"TARIF")
                        t2->SUMV_USL := mo_read_xml_stroke(oNode2,"SUMV_USL")

                        if p_tip_reestr == 1 .and. (xml2date(t1->DATE_Z_2) >= 0d20220101) // добавил по новому ПУМП от 18.01.22
                          if (oNode100 := oNode2:Find("MED_DEV")) != NIL
                            // имплантант
                            tmpSelect := select()                            
                            select T12
                            append blank
                            T12->SLUCH    := iisl // номер случая
                            T12->KOD      := mkod // код
                            T12->IDCASE   := &lal.->IDCASE // для связи со случаем
                            T12->DATE_MED := mo_read_xml_stroke(oNode2, "DATE_MED") // Дата установки имплантанта
                            T12->CODE_DEV := mo_read_xml_stroke(oNode2, "CODE_MEDDEV") // Код вида медицинского изделия (имплантанта)
                            T12->NUM_SER  := mo_read_xml_stroke(oNode2, "NUMBER_SER") // Серийный номер медицинского изделия (имплантанта)
                            select(tmpSelect)
                          endif
                        endif

                        if p_tip_reestr == 2 .and. (xml2date(t1->DATE_Z_2) >= 0d20210801) // добавил по новому ПУМП от 02.08.21
                          if (oNode100 := oNode2:Find("MR_USL_N")) != NIL
                            // пока только 1 врач
                            t2->PRVS  := mo_read_xml_stroke(oNode100,"PRVS")
                            t2->CODE_MD  := mo_read_xml_stroke(oNode100,"CODE_MD",,.f.)
                          endif
                        elseif p_tip_reestr == 1 .and. (xml2date(t1->DATE_Z_2) >= d_01_01_2022) // добавил по новому ПУМП от 11.01.22
                          t2->PRVS     := mo_read_xml_stroke(oNode2,"PRVS")
                          t2->CODE_MD  := mo_read_xml_stroke(oNode2,"CODE_MD",,.f.)
                        endif

                        t2->COMENTU  := mo_read_xml_stroke(oNode2,"COMENTU",,.f.)
                      endif
                    next j1
                  endif
                next isl
              endif
            endif
            if flag_tmp1
              tmp1->_KOL ++
              tmp1->_MAX := max(tmp1->_MAX,int(val(mo_read_xml_stroke(oXmlNode,"N_ZAP"))))
            endif
          case is_all .and. "PERS" == oXmlNode:title
            select T3
            append blank
            t3->KOD     := mkod
            t3->ID_PAC  := mo_read_xml_stroke(oXmlNode,"ID_PAC")
            t3->FAM     := mo_read_xml_stroke(oXmlNode,"FAM")
            t3->IM      := mo_read_xml_stroke(oXmlNode,"IM")
            t3->OT      := mo_read_xml_stroke(oXmlNode,"OT",,.f.)
            t3->W       := mo_read_xml_stroke(oXmlNode,"W")
            t3->DR      := mo_read_xml_stroke(oXmlNode,"DR")
            t3->DOST    := mo_read_xml_stroke(oXmlNode,"DOST",,.f.)
            t3->TEL     := mo_read_xml_stroke(oXmlNode,"TEL",,.f.)
            t3->FAM_P   := mo_read_xml_stroke(oXmlNode,"FAM_P",,.f.)
            t3->IM_P    := mo_read_xml_stroke(oXmlNode,"IM_P",,.f.)
            t3->OT_P    := mo_read_xml_stroke(oXmlNode,"OT_P",,.f.)
            t3->W_P     := mo_read_xml_stroke(oXmlNode,"W_P",,.f.)
            t3->DR_P    := mo_read_xml_stroke(oXmlNode,"DR_P",,.f.)
            t3->DOST_P  := mo_read_xml_stroke(oXmlNode,"DOST_P",,.f.)
            t3->MR      := mo_read_xml_stroke(oXmlNode,"MR",,.f.)
            t3->DOCTYPE := mo_read_xml_stroke(oXmlNode,"DOCTYPE",,.f.)
            t3->DOCSER  := mo_read_xml_stroke(oXmlNode,"DOCSER",,.f.)
            t3->DOCNUM  := mo_read_xml_stroke(oXmlNode,"DOCNUM",,.f.)
            t3->DOCDATE := mo_read_xml_stroke(oXmlNode,"DOCDATE",,.f.)
            t3->DOCORG  := mo_read_xml_stroke(oXmlNode,"DOCORG",,.f.)
            t3->SNILS   := mo_read_xml_stroke(oXmlNode,"SNILS",,.f.)
            t3->OKATOG  := mo_read_xml_stroke(oXmlNode,"OKATOG",,.f.)
            t3->OKATOP  := mo_read_xml_stroke(oXmlNode,"OKATOP",,.f.)
        endcase
        if j % 2000 == 0
          commit
        endif
      next j
      if is_old
        exit
      endif
    next ii
    if is_old
      fl := extract_old_reestr(mkod,mname_xml,flag_tmp1,is_all,goal_dir)
    endif
    t1->(dbCloseArea())
    t1_1->(dbCloseArea())
    t2->(dbCloseArea())
    t3->(dbCloseArea())
    t4->(dbCloseArea())
    t5->(dbCloseArea())
    t6->(dbCloseArea())
    t7->(dbCloseArea())
    t8->(dbCloseArea())
    t9->(dbCloseArea())
    t10->(dbCloseArea())
    t11->(dbCloseArea())
    t12->(dbCloseArea())
    if flag_tmp1
      tmp1->(dbCloseArea())
    endif
  endif
  rest_box(buf)
  return fl
  