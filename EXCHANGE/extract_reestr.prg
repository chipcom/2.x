#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 18.02.25 вынуть реестр из XML-файлов и записать во временные DBF-файлы
Function extract_reestr( mkod, mname_xml, flag_tmp1, is_all, goal_dir )

  Local p_tip_reestr
  Local tmpSelect
  Local arr_f, ii, oXmlDoc, j, j1, j2, j3, j4, _ar, buf := save_maxrow(), fl := .f., is_old := .f.
  local name_zip := AllTrim( mname_xml ) + szip
  Local ushifr
  local oNode1, oNode11, oNode2, oNode3, oNode4, oNode5
  local lREGNUM, lREGNUM_DOP, lCODE_SH

  Local _table1 := { ;
    { "KOD",      "N", 6, 0 }, ; // код
    { "N_ZAP",    "C", 12, 0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    { "PR_NOV",   "C", 1, 0 }, ;
    { "ID_PAC",   "C", 36, 0 }, ; //
    { "VPOLIS",   "C", 1, 0 }, ; //
    { "SPOLIS",   "C", 10, 0 }, ; //
    { "NPOLIS",   "C", 20, 0 }, ; //
    { "ENP",      "C", 16, 0 }, ; //
    { "SMO",      "C", 5, 0 }, ; //
    { "SMO_OK",   "C", 5, 0 }, ; //
    { "SMO_NAM",  "C", 100, 0 }, ; //
    { "MO_PR",    "C", 6, 0 }, ; //
    { "NOVOR",    "C", 9, 0 }, ; //
    { "VNOV_D",   "C", 4, 0 }, ; // вес новорожденного в граммах
    { "SOC",      "C", 3, 0 }, ; // участники и члены семей участников СВО
    { "INV",      "C", 1, 0 }, ; //
    { "DATA_INV", "C", 10, 0 }, ; //
    { "REASON_INV","C", 2, 0 }, ; //
    { "DS_INV",   "C", 10, 0 }, ; //
    { "MSE",      "C", 1, 0 }, ; //
    { "KD_Z",     "C", 3, 0 }, ; //
    { "KD",       "C", 3, 0 }, ; //
    { "IDCASE",   "C", 12, 0 }, ; //
    { "ID_C",     "C", 36, 0 }, ; //
    { "SL_ID",    "C", 36, 0 }, ; //
    { "DISP",     "C", 3, 0 }, ; //
    { "USL_OK",   "C", 2, 0 }, ; //
    { "VIDPOM",   "C", 4, 0 }, ; //
    { "F_SP",     "C", 1, 0 }, ; // удалено поле
    { "FOR_POM",  "C", 1, 0 }, ; // N1
    { "VID_HMP",  "C", 12, 0 }, ; // C9
    { "ISHOD",    "C", 3, 0 }, ; //
    { "VB_P",     "C", 1, 0 }, ; //
    { "IDSP",     "C", 2, 0 }, ; //
    { "SUMV",     "C", 10, 0 }, ; //
    { "METOD_HMP","C", 4, 0 }, ; // N4 // 12.02.21
    { "NPR_MO",   "C", 6, 0 }, ; //
    { "NPR_DATE", "C", 10, 0 }, ; //
    { "EXTR",     "C", 1, 0 }, ; //
    { "LPU",      "C", 6, 0 }, ; //
    { "LPU_1",    "C", 8, 0 }, ; //
    { "PODR",     "C", 8, 0 }, ; //
    { "PROFIL",   "C", 3, 0 }, ; //
    { "PROFIL_K", "C", 3, 0 }, ; //
    { "DET",      "C", 1, 0 }, ; //
    { "P_CEL",    "C", 3, 0 }, ; //
    { "TAL_D",    "C", 10, 0 }, ; //
    { "TAL_P",    "C", 10, 0 }, ; //
    { "TAL_NUM",  "C", 20, 0 }, ; //
    { "VBR",      "C", 1, 0 }, ; //
    { "NHISTORY", "C", 10, 0 }, ; //
    { "P_OTK",    "C", 1, 0 }, ; //
    { "P_PER",    "C", 1, 0 }, ; //
    { "DATE_Z_1", "C", 10, 0 }, ; //
    { "DATE_Z_2", "C", 10, 0 }, ; //
    { "DATE_1",   "C", 10, 0 }, ; //
    { "DATE_2",   "C", 10, 0 }, ; //
    { "DS0",      "C", 6, 0 }, ; //
    { "DS1",      "C", 6, 0 }, ; //
    { "DS1_PR",   "C", 1, 0 }, ; //
    { "PR_D_N",   "C", 1, 0 }, ; //
    { "DS2",      "C", 6, 0 }, ; //
    { "DS2N",     "C", 6, 0 }, ; //
    { "DS2N_PR",  "C", 1, 0 }, ; //
    { "DS2N_D",   "C", 1, 0 }, ; //
    { "DS2_2",    "C", 6, 0 }, ; //
    { "DS2N_2",   "C", 6, 0 }, ; //
    { "DS2N_2_PR","C", 1, 0 }, ; //
    { "DS2N_2_D", "C", 1, 0 }, ; //
    { "DS2_3",    "C", 6, 0 }, ; //
    { "DS2N_3",   "C", 6, 0 }, ; //
    { "DS2N_3_PR","C", 1, 0 }, ; //
    { "DS2N_3_D", "C", 1, 0 }, ; //
    { "DS2_4",    "C", 6, 0 }, ; //
    { "DS2N_4",   "C", 6, 0 }, ; //
    { "DS2N_4_PR","C", 1, 0 }, ; //
    { "DS2N_4_D", "C", 1, 0 }, ; //
    { "DS2_5",    "C", 6, 0 }, ; //
    { "DS2_6",    "C", 6, 0 }, ; //
    { "DS2_7",    "C", 6, 0 }, ; //
    { "DS3",      "C", 6, 0 }, ; //
    { "DS3_2",    "C", 6, 0 }, ; //
    { "DS3_3",    "C", 6, 0 }, ; //
    { "DS_ONK",   "C", 1, 0 }, ; //
    { "C_ZAB",    "C", 1, 0 }, ; //
    { "DN",       "C", 1, 0 }, ; //
    { "VNOV_M",   "C", 4, 0 }, ; // вес новорожденного в граммах
    { "VNOV_M_2", "C", 4, 0 }, ; // вес новорожденного в граммах
    { "VNOV_M_3", "C", 4, 0 }, ; // вес новорожденного в граммах
    { "CODE_MES1","C", 20, 0 }, ; //
    { "SUM_M",    "C", 10, 0 }, ; //
    { "DS1_T",    "C", 1, 0 }, ; // Повод обращения:0 - первичное лечение;1 - рецидив;2 - прогрессирование
    { "PR_CONS",  "C", 1, 0 }, ; // Сведения о проведении консилиума:1 - определена тактика обследования;2 - определена тактика лечения;3 - изменена тактика лечения.
    { "DT_CONS",  "C", 10, 0 }, ; // Дата проведения консилиума       Обязательно к заполнению при заполненном PR_CONS
    { "STAD",     "C", 3, 0 }, ; // Стадия заболевания       Заполняется в соответствии со справочником N002
    { "ONK_T",    "C", 3, 0 }, ; // Значение Tumor   Заполняется в соответствии со справочником N003
    { "ONK_N",    "C", 3, 0 }, ; // Значение Nodus   Заполняется в соответствии со справочником N004
    { "ONK_M",    "C", 3, 0 }, ; // Значение Metastasis      Заполняется в соответствии со справочником N005
    { "MTSTZ",    "C", 1, 0 }, ; // Признак выявления отдалённых метастазов  Подлежит заполнению значением 1 при выявлении отдалённых метастазов только при DS1_T=1 или DS1_T=2
    { "SOD",      "C", 6, 0 }, ;  // Суммарная очаговая доза Обязательно для заполнения при проведении лучевой или химиолучевой терапии (USL_TIP=3 или USL_TIP=4)
    { "K_FR",     "C", 2, 0 }, ; //
    { "WEI",      "C", 5, 0 }, ; //
    { "HEI",      "C", 5, 0 }, ; //
    { "BSA",      "C", 5, 0 }, ; //
    { "RSLT",     "C", 3, 0 }, ; //
    { "ISHOD",    "C", 3, 0 }, ; //
    { "IDSP",     "C", 2, 0 }, ; //
    { "PRVS",     "C", 9, 0 }, ; //
    { "IDDOKT",   "C", 16, 0 }, ; //
    { "OS_SLUCH", "C", 2, 0 }, ; //
    { "COMENTSL", "C", 250, 0 }, ; //
    { "ED_COL",   "C", 1, 0 }, ; //
    { "N_KSG",    "C", 20, 0 }, ; //
    { "CRIT",     "C", 20, 0 }, ; //
    { "CRIT2",    "C", 20, 0 }, ; //
    { "SL_K",     "C", 9, 0 }, ; //
    { "IT_SL",    "C", 9, 0 }, ; //
    { "AD_CR",    "C", 10, 0 }, ; //
    { "DKK2",     "C", 10, 0 }, ; //
    { "kod_kslp", "C", 5, 0 }, ; //
    { "koef_kslp","C", 6, 0 }, ;  //
    { "kod_kslp2","C", 5, 0 }, ; //
    { "koef_kslp2","C", 6, 0 }, ;  //
    { "kod_kslp3","C", 5, 0 }, ; //
    { "koef_kslp3","C", 6, 0 }, ;  //
    { "CODE_KIRO","C", 1, 0 }, ; //
    { "VAL_K",    "C", 5, 0 }, ; //
    { "NEXT_VISIT","C", 10, 0 }, ; //
    { "TARIF",    "C", 10, 0 }; //
  }
  Local _table2 := { ;
    { "SLUCH",    "N", 6, 0 }, ; // номер случая
    { "KOD",      "N", 6, 0 }, ; // код
    { "IDCASE",   "C", 12, 0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    { "IDSERV",   "C", 36, 0 }, ; //
    { "ID_U",     "C", 36, 0 }, ; //
    { "LPU",      "C", 6, 0 }, ; //
    { "LPU_1",    "C", 8, 0 }, ; //
    { "PODR",     "C", 8, 0 }, ; //
    { "PROFIL",   "C", 3, 0 }, ; //
    { "VID_VME",  "C", 20, 0 }, ; //
    { "DET",      "C", 1, 0 }, ; //
    { "P_OTK",    "C", 1, 0 }, ; //
    { "DATE_IN",  "C", 10, 0 }, ; //
    { "DATE_OUT", "C", 10, 0 }, ; //
    { "DS",       "C", 6, 0 }, ; //
    { "CODE_USL", "C", 20, 0 }, ; //
    { "KOL_USL",  "C", 6, 0 }, ; //
    { "TARIF",    "C", 10, 0 }, ; //
    { "SUMV_USL", "C", 10, 0 }, ; //
    { "USL_TIP",  "C", 1, 0 }, ; // Тип онкоуслуги в соответствии со справочником N013
    { "HIR_TIP",  "C", 1, 0 }, ; // Тип хирургического лечения При USL_TIP=1 в соответствии со справочником N014
    { "LEK_TIP_L","C", 1, 0 }, ; // Линия лекарственной терапии При USL_TIP=2 в соответствии со справочником N015
    { "LEK_TIP_V","C", 1, 0 }, ; // Цикл лекарственной терапии       При USL_TIP=2 в соответствии со справочником N016
    { "LUCH_TIP", "C", 1, 0 }, ; // Тип лучевой терапии      При USL_TIP=3,4 в соответствии со справочником N017
    { "PRVS",     "C", 9, 0 }, ; //
    { "CODE_MD",  "C", 16, 0 }, ; //
    { "COMENTU",  "C", 250, 0 };  //
  }
  Local _table3 := { ;
    { "KOD",      "N", 6, 0 }, ; // код
    { "ID_PAC",   "C", 36, 0 }, ; // код записи о пациенте ;GUID пациента в листе учета;создается при добавлении записи
    { "FAM",      "C", 40, 0 }, ; //
    { "IM",       "C", 40, 0 }, ; //
    { "OT",       "C", 40, 0 }, ; //
    { "W",        "C", 1, 0 }, ; //
    { "DR",       "C", 10, 0 }, ; //
    { "DOST",     "C", 1, 0 }, ; //
    { "TEL",      "C", 10, 0 }, ; //
    { "FAM_P",    "C", 40, 0 }, ; //
    { "IM_P",     "C", 40, 0 }, ; //
    { "OT_P",     "C", 40, 0 }, ; //
    { "W_P",      "C", 1, 0 }, ; //
    { "DR_P",     "C", 10, 0 }, ; //
    { "DOST_P",   "C", 1, 0 }, ; //
    { "MR",       "C", 100, 0 }, ; //
    { "DOCTYPE",  "C", 2, 0 }, ; //
    { "DOCSER",   "C", 10, 0 }, ; //
    { "DOCNUM",   "C", 20, 0 }, ; //
    { "DOCDATE",  "C", 10, 0 }, ; //
    { "DOCORG",   "C", 255, 0 }, ; //
    { "SNILS",    "C", 14, 0 }, ; //
    { "OKATOG",   "C", 11, 0 }, ; //
    { "OKATOP",   "C", 11, 0 }; //
  }
  Local _table4 := { ;
    { "SLUCH",    "N", 6, 0 }, ; // номер случая
    { "KOD",      "N", 6, 0 }, ; // код
    { "IDCASE",   "C", 12, 0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    { "CODE_SL",  "C", 5, 0 }, ; //
    { "VAL_C",    "C", 6, 0 };  //
  }
  Local _table5 := { ;
    { "SLUCH",    "N", 6, 0 }, ; // номер случая
    { "KOD",      "N", 6, 0 }, ; // код
    { "IDCASE",   "C", 12, 0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    { "NAZ_N",    "C", 2, 0 }, ; // PRESCRIPTIONS - Номер по порядку
    { "NAZ_R",    "C", 2, 0 }, ; // PRESCRIPTIONS - Код назначения
    { "NAZR",     "C", 2, 0 }, ; // PRESCRIPTIONS - Код назначения
    { "NAZ_IDDT", "C", 25, 0 }, ; // СНИЛС врача
    { "NAZ_SPDT", "C", 4, 0 }, ; // Код специальности врача V021
    { "NAZ_SP",   "C", 5, 0 }, ; // специальность
    { "NAZ_V",    "C", 1, 0 }, ; // назначение
    { "NAPR_DATE","C", 10, 0 }, ; // Дата направления
    { "NAPR_MO",  "C", 6, 0 }, ; //
    { "NAZ_USL",  "C", 15, 0 }, ;  // шифр услуги
    { "NAZ_PMP",  "C", 3, 0 }, ; //
    { "NAZ_PK",   "C", 3, 0 }; //
  }
  Local _table6 := { ;  // онконаправления
    { "SLUCH",    "N", 6, 0 }, ; // номер случая
    { "KOD",      "N", 6, 0 }, ; // код
    { "IDCASE",   "C", 12, 0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    { "NAPR_DATE","C", 10, 0 }, ; // Дата направления
    { "NAZ_IDDT", "C", 25, 0 }, ; // СНИЛС врача
    { "NAZ_SPDT", "C", 4, 0 }, ; // Код специальности врача V021
    { "NAPR_MO",  "C", 6, 0 }, ; //
    { "NAPR_V",   "C", 1, 0 }, ; // Вид направления:1-к онкологу,2-на биопсию,3-на дообследование,4-для опр.тактики лечения
    { "MET_ISSL", "C", 1, 0 }, ; // Метод диагностического исследования(при NAPR_V=3):1-лаб.диагностика;2-инстр.диагностика;3-луч.диагностика;4-КТ, МРТ, ангиография
    { "U_KOD",    "C", 15, 0 };  // шифр услуги
  }
  Local _table7 := { ;  // Диагностический блок
    { "SLUCH",    "N", 6, 0 }, ; // номер случая
    { "KOD",      "N", 6, 0 }, ; // код
    { "IDCASE",   "C", 12, 0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    { "DIAG_DATE","C", 10, 0 }, ; // Дата взятия материала для проведения диагностики
    { "DIAG_TIP", "C", 1, 0 }, ; // Тип диагностического показателя: 1 - гистологический признак; 2 - маркёр (ИГХ)
    { "DIAG_CODE","C", 3, 0 }, ; // Код диагностического показателя При DIAG_TIP=1 в соответствии со справочником N007 При DIAG_TIP=2 в соответствии со справочником N010
    { "DIAG_RSLT","C", 3, 0 }, ;  // Код результата диагностики При DIAG_TIP=1 в соответствии со справочником N008 При DIAG_TIP=2 в соответствии со справочником N011
    { "REC_RSLT", "C", 1, 0 };
  }
  Local _table8 := { ;  // Сведения об имеющихся противопоказаниях
    { "SLUCH",    "N", 6, 0 }, ; // номер случая
    { "KOD",      "N", 6, 0 }, ; // код
    { "IDCASE",   "C", 12, 0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    { "PROT",     "C", 1, 0 }, ; // Код противопоказания или отказа в соответствии со справочником N001
    { "D_PROT",   "C", 10, 0 };  // Дата регистрации противопоказания или отказа
  }
  Local _table9 := { ;  // Сведения об онкологических услугах
    { "SLUCH",    "N", 6, 0 }, ; // номер случая
    { "KOD",      "N", 6, 0 }, ; // код
    { "IDCASE",   "C", 12, 0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    { "USL_TIP",  "C", 1, 0 }, ; // Тип онкоуслуги в соответствии со справочником N013
    { "HIR_TIP",  "C", 1, 0 }, ; // Тип хирургического лечения При USL_TIP=1 в соответствии со справочником N014
    { "LEK_TIP_L","C", 1, 0 }, ; // Линия лекарственной терапии При USL_TIP=2 в соответствии со справочником N015
    { "LEK_TIP_V","C", 1, 0 }, ; // Цикл лекарственной терапии       При USL_TIP=2 в соответствии со справочником N016
    { "LUCH_TIP", "C", 1, 0 }, ; // Тип лучевой терапии      При USL_TIP=3,4 в соответствии со справочником N017
    { "PPTR",     "C", 1, 0 };
  }
  Local _table10 := { ;  // Сведения об онкологических лек.препаратах
    { 'SLUCH',      'N', 6, 0 }, ; // номер случая
    { 'KOD',        'N', 6, 0 }, ; // код
    { 'IDCASE',     'C', 12, 0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    { 'REGNUM',     'C', 6, 0 }, ;
    { 'REGNUM_DOP', 'C', 25, 0 }, ;
    { 'CODE_SH',    'C', 20, 0 }, ;
    { 'DATE_INJ',   'C', 10, 0 }, ;
    { 'KV_INJ',     'C', 11, 0 }, ; // Количество введенного лекарственного препарата(действующего вещества)
    { 'KIZ_INJ',    'C', 11, 0 }, ; // Количество израсходованного (введеного + утилизированного) лекарственного препарата
    { 'S_INJ',      'C', 21, 0 }, ; // Фактическая стоимость лекарственного препарата за единицу измерения
    { 'SV_INJ',     'C', 21, 0 }, ; // Стоимость введенного лекарственного препарата
    { 'SIZ_INJ',    'C', 21, 0 }, ; // Стоимость израсходованного лекарственного препарата
    { 'RED_INJ',    'C', 1, 0 } ; // Признак применения редукции для лекарственного препарата
  }
  Local _table11 := { ;  // Сведения лек.препаратах применявшихся при лечении
    { 'SLUCH',    'N',   6, 0 }, ; // номер случая
    { 'KOD',      'N',   6, 0 }, ; // код
    { 'IDCASE',   'C',  12, 0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    { 'DATA_INJ', 'C',  10, 0 }, ; // Дата введения лекарственного препарата
    { 'CODE_SH',  'C',  20, 0 }, ; // Код схемы лечения пациента/код группы препарата
    { 'REGNUM',   'C',   6, 0 }, ; // Идентификатор лекарственного препарата
    { 'ED_IZM',   'C',   3, 0 }, ; // Единица измерения дозы лекарственного препарата
    { 'DOSE_INJ', 'C',   8, 0 }, ; // Доза введения лекарственного препарата
    { 'METHOD_I', 'C',   3, 0 }, ; // Путь введения лекарственного препарата
    { 'COL_INJ',  'C',   5, 0 };  // Количество введений в течениедня, указанного в DATA_INJ
  }
  // {"COD_MARK",    "C", 100, 0},; // Код маркировки лекарственного препарата
  Local _table12 := { ;  // Сведения об установленных имплантантах при лечении
    { "SLUCH",    "N",   6, 0 }, ; // номер случая
    { "KOD",      "N",   6, 0 }, ; // код
    { "IDCASE",   "C",  12, 0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
    { "CODE_USL", "C",  20, 0 }, ; //
    { "DATE_MED", "C",  10, 0 }, ; // Дата установки имплантанта
    { "CODE_DEV", "C",  10, 0 }, ; // Код вида медицинского изделия (имплантанта)
    { "NUM_SER",  "C", 100, 0 }; // Серийный номер медицинского изделия (имплантанта)
  }


  //
  Default flag_tmp1 To .f., is_all To .t., goal_dir To dir_server + dir_XML_MO + cslash
  Private pole
  stat_msg( "Распаковка/чтение/анализ " + iif( eq_any( Left( mname_xml, 3 ), "HRM", "FRM" ), "реестра ", "счёта " ) + mname_xml )

  p_tip_reestr := iif( Left( mname_xml, 3 ) == "HRM", 1, 2 )

  If ( arr_f := extract_zip_xml( goal_dir, name_zip ) ) != NIL
    fl := .t.
    dbCreate( cur_dir + "tmp_r_t1", _table1 )
    dbCreate( cur_dir + "tmp_r_t1_1", _table1 )
    dbCreate( cur_dir + "tmp_r_t2", _table2 )
    dbCreate( cur_dir + "tmp_r_t3", _table3 )
    dbCreate( cur_dir + "tmp_r_t4", _table4 )
    dbCreate( cur_dir + "tmp_r_t5", _table5 )
    dbCreate( cur_dir + "tmp_r_t6", _table6 )
    dbCreate( cur_dir + "tmp_r_t7", _table7 )
    dbCreate( cur_dir + "tmp_r_t8", _table8 )
    dbCreate( cur_dir + "tmp_r_t9", _table9 )
    dbCreate( cur_dir + "tmp_r_t10", _table10 )
    dbCreate( cur_dir + "tmp_r_t11", _table11 )
    dbCreate( cur_dir + "tmp_r_t12", _table12 )
    Use ( cur_dir + "tmp_r_t1" ) New Alias T1
    Use ( cur_dir + "tmp_r_t2" ) New Alias T2
    Use ( cur_dir + "tmp_r_t3" ) New Alias T3
    Use ( cur_dir + "tmp_r_t4" ) New Alias T4
    Use ( cur_dir + "tmp_r_t5" ) New Alias T5
    Use ( cur_dir + "tmp_r_t6" ) New Alias T6
    Use ( cur_dir + "tmp_r_t7" ) New Alias T7
    Use ( cur_dir + "tmp_r_t8" ) New Alias T8
    Use ( cur_dir + "tmp_r_t9" ) New Alias T9
    Use ( cur_dir + "tmp_r_t10" ) New Alias T10
    Use ( cur_dir + "tmp_r_t11" ) New Alias T11
    Use ( cur_dir + "tmp_r_t12" ) New Alias T12
    Use ( cur_dir + "tmp_r_t1_1" ) New Alias T1_1
    If flag_tmp1
      dbCreate( cur_dir + "tmp1file", { ;
        { "_VERSION",   "C",  5, 0 }, ;
        { "_DATA",      "D",  8, 0 }, ;
        { "_FILENAME",  "C", 26, 0 }, ;
        { "_SD_Z",      "N",  9, 0 }, ;
        { "_CODE",      "N", 12, 0 }, ;
        { "_CODE_MO",   "C",  6, 0 }, ;
        { "_YEAR",      "N",  4, 0 }, ;
        { "_MONTH",     "N",  2, 0 }, ;
        { "_NSCHET",    "C", 15, 0 }, ;
        { "_DSCHET",    "D",  8, 0 }, ;
        { "_SUMMAV",    "N", 15, 2 }, ;
        { "_KOL",       "N",  6, 0 }, ;
        { "_MAX",       "N",  8, 0 };
        } )
      Use ( cur_dir + "tmp1file" ) New Alias TMP1
      Append Blank
    Endif
    For ii := 1 To Len( arr_f )
      // читаем файл в память
      oXmlDoc := hxmldoc():read( _tmp_dir1() + arr_f[ ii ] )
      If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
        fl := func_error( 4, "Ошибка в чтении файла " + arr_f[ ii ] )
        Exit
      Endif
      For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
        @ MaxRow(), 1 Say PadR( lstr( ii ) + "/" + lstr( j ), 8 ) Color cColorSt2Msg
        oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
        Do Case
        Case flag_tmp1 .and. "ZGLV" == oXmlNode:title
          tmp1->_VERSION :=          mo_read_xml_stroke( oXmlNode, "VERSION" )
          If !eq_any( AllTrim( tmp1->_VERSION ), "3.11", "3.2" )
            is_old := .t.
            Exit
          Endif
          tmp1->_DATA    := xml2date( mo_read_xml_stroke( oXmlNode, "DATA" ) )
          tmp1->_FILENAME :=          mo_read_xml_stroke( oXmlNode, "FILENAME" )
          tmp1->_SD_Z    :=      Val( mo_read_xml_stroke( oXmlNode, "SD_Z",, .f. ) )
        Case flag_tmp1 .and. "SCHET" == oXmlNode:title
          tmp1->_CODE    :=      Val( mo_read_xml_stroke( oXmlNode, "CODE" ) )
          tmp1->_CODE_MO :=          mo_read_xml_stroke( oXmlNode, "CODE_MO" )
          tmp1->_YEAR    :=      Val( mo_read_xml_stroke( oXmlNode, "YEAR" ) )
          tmp1->_MONTH   :=      Val( mo_read_xml_stroke( oXmlNode, "MONTH" ) )
          tmp1->_NSCHET  :=          mo_read_xml_stroke( oXmlNode, "NSCHET" )
          tmp1->_DSCHET  := xml2date( mo_read_xml_stroke( oXmlNode, "DSCHET" ) )
          tmp1->_SUMMAV  :=      Val( mo_read_xml_stroke( oXmlNode, "SUMMAV" ) )
        Case "ZAP" == oXmlNode:title
          If is_all
            Select T1
            Append Blank
            t1->kod := mkod
            t1->N_ZAP := mo_read_xml_stroke( oXmlNode, "N_ZAP" )
            t1->PR_NOV := mo_read_xml_stroke( oXmlNode, "PR_NOV" )
            If ( oNode1 := oXmlNode:find( "PACIENT" ) ) != NIL
              t1->ID_PAC  := mo_read_xml_stroke( oNode1, "ID_PAC" )
              t1->VPOLIS  := mo_read_xml_stroke( oNode1, "VPOLIS" )
              t1->SPOLIS  := mo_read_xml_stroke( oNode1, "SPOLIS",, .f. )
              t1->NPOLIS  := mo_read_xml_stroke( oNode1, "NPOLIS" )
              t1->ENP     := mo_read_xml_stroke( oNode1, "ENP",, .f. )
              t1->SMO     := mo_read_xml_stroke( oNode1, "SMO",, .f. )
              t1->SMO_OK  := mo_read_xml_stroke( oNode1, "SMO_OK",, .f. )
              t1->SMO_NAM := mo_read_xml_stroke( oNode1, "SMO_NAM",, .f. )
              t1->MO_PR   := mo_read_xml_stroke( oNode1, "MO_PR",, .f. )
              t1->NOVOR   := mo_read_xml_stroke( oNode1, "NOVOR",, .f. )
              t1->VNOV_D  := mo_read_xml_stroke( oNode1, "VNOV_D",, .f. )
              t1->SOC     := mo_read_xml_stroke( oNode1, "SOC",, .f. )
              If ( oNode2 := oNode1:find( "DISABILITY" ) ) != NIL
                t1->INV        := mo_read_xml_stroke( oNode2, "INV" )
                t1->DATA_INV   := mo_read_xml_stroke( oNode2, "DATA_INV" )
                t1->REASON_INV := mo_read_xml_stroke( oNode2, "REASON_INV" )
                t1->DS_INV     := mo_read_xml_stroke( oNode2, "DS_INV",, .f. )
              Endif
            Endif
            If ( oNode1 := oXmlNode:find( "Z_SL" ) ) != NIL
              t1->IDCASE   := mo_read_xml_stroke( oNode1, "IDCASE" )
              t1->ID_C     := mo_read_xml_stroke( oNode1, "ID_C" )
              t1->DISP     := mo_read_xml_stroke( oNode1, "DISP",, .f. )  // 2
              t1->USL_OK   := mo_read_xml_stroke( oNode1, "USL_OK" )
              t1->VIDPOM   := mo_read_xml_stroke( oNode1, "VIDPOM" )
              t1->FOR_POM  := mo_read_xml_stroke( oNode1, "FOR_POM",, .f. )
              t1->ISHOD    := mo_read_xml_stroke( oNode1, "ISHOD" )
              t1->VB_P     := mo_read_xml_stroke( oNode1, "VB_P",, .f. )
              t1->IDSP     := mo_read_xml_stroke( oNode1, "IDSP" )
              t1->SUMV     := mo_read_xml_stroke( oNode1, "SUMV" )
              t1->NPR_MO   := mo_read_xml_stroke( oNode1, "NPR_MO",, .f. )
              t1->NPR_DATE := mo_read_xml_stroke( oNode1, "NPR_DATE",, .f. )
              t1->LPU      := mo_read_xml_stroke( oNode1, "LPU" )
              t1->VBR      := mo_read_xml_stroke( oNode1, "VBR",, .f. )
              t1->P_CEL    := mo_read_xml_stroke( oNode1, "P_CEL",, .f. )
              t1->P_OTK    := mo_read_xml_stroke( oNode1, "P_OTK",, .f. )
              t1->DATE_Z_1 := mo_read_xml_stroke( oNode1, "DATE_Z_1" )
              t1->DATE_Z_2 := mo_read_xml_stroke( oNode1, "DATE_Z_2" )
              t1->KD_Z     := mo_read_xml_stroke( oNode1, "KD_Z",, .f. )
              _ar := mo_read_xml_array( oNode1, "VNOV_M" ) // М.Б.НЕСКОЛЬКО VNOV_M
              For j1 := 1 To Min( 3, Len( _ar ) )
                pole := "t1->VNOV_M" + iif( j1 == 1, "", "_" + lstr( j1 ) )
                &pole := _ar[ j1 ]
              Next
              t1->RSLT := mo_read_xml_stroke( oNode1, "RSLT" )
              t1->MSE := mo_read_xml_stroke( oNode1, "MSE",, .f. )
              iisl := 0
              For isl := 1 To Len( oNode1:aitems ) // последовательный просмотр
                oNode11 := oNode1:aItems[ isl ]     // т.к. случаев м.б. несколько
                If ValType( oNode11 ) != "C" .and. oNode11:title == "SL"
                  ++iisl
                  If iisl == 1
                    lal := "t1"
                  Else
                    If iisl > 2 // на всякий случай
                      fl := func_error( 4, "Ошибка в файле " + arr_f[ ii ] + ;
                        ", зак.случай № " + AllTrim( t1->IDCASE ) + ", случай № " + lstr( iisl ) )
                      Exit
                    Endif
                    lal := "t1_1"
                    Select T1_1
                    Append Blank
                    t1_1->kod    := t1->kod
                    t1_1->N_ZAP  := t1->N_ZAP
                    t1_1->ID_PAC := t1->ID_PAC
                    t1_1->IDCASE := t1->IDCASE
                    t1_1->ID_C   := t1->ID_C
                  Endif
                  &lal.->SL_ID     := mo_read_xml_stroke( oNode11, "SL_ID" )
                  &lal.->VID_HMP   := mo_read_xml_stroke( oNode11, "VID_HMP",, .f. )
                  &lal.->METOD_HMP := mo_read_xml_stroke( oNode11, "METOD_HMP",, .f. )
                  &lal.->LPU_1     := mo_read_xml_stroke( oNode11, "LPU_1",, .f. )
                  &lal.->PODR      := mo_read_xml_stroke( oNode11, "PODR",, .f. )
                  &lal.->PROFIL    := mo_read_xml_stroke( oNode11, "PROFIL" )
                  &lal.->PROFIL_K  := mo_read_xml_stroke( oNode11, "PROFIL_K",, .f. )
                  &lal.->DET       := mo_read_xml_stroke( oNode11, "DET",, .f. )
                  s := mo_read_xml_stroke( oNode11, "P_CEL",, .f. )
                  If !Empty( s )
                    &lal.->P_CEL := s
                  Endif
                  &lal.->TAL_D     := mo_read_xml_stroke( oNode11, "TAL_D",, .f. )
                  &lal.->TAL_P     := mo_read_xml_stroke( oNode11, "TAL_P",, .f. )
                  &lal.->TAL_NUM   := mo_read_xml_stroke( oNode11, "TAL_NUM",, .f. )
                  &lal.->NHISTORY  := mo_read_xml_stroke( oNode11, "NHISTORY" )
                  &lal.->P_PER     := mo_read_xml_stroke( oNode11, "P_PER",, .f. )
                  &lal.->DATE_1    := mo_read_xml_stroke( oNode11, "DATE_1" )
                  &lal.->DATE_2    := mo_read_xml_stroke( oNode11, "DATE_2" )
                  &lal.->KD        := mo_read_xml_stroke( oNode11, "KD",, .f. )
                  &lal.->WEI       := mo_read_xml_stroke( oNode11, "WEI", , .f. )
                  &lal.->DS0       := mo_read_xml_stroke( oNode11, "DS0",, .f. )
                  &lal.->DS1       := mo_read_xml_stroke( oNode11, "DS1" )
                  &lal.->DS1_PR    := mo_read_xml_stroke( oNode11, "DS1_PR",, .f. ) // 2
                  &lal.->PR_D_N    := mo_read_xml_stroke( oNode11, "PR_D_N",, .f. ) // 2
                  // DS2 для диспансеризации
                  j1 := 0
                  For i := 1 To Len( oNode11:aitems ) // последовательный просмотр
                    oNode2 := oNode11:aItems[ i ]     // т.к. м.б. несколько
                    If ValType( oNode2 ) != "C" .and. oNode2:title == "DS2_N"
                      If++j1 > 4 ; exit ; Endif
                      pole := lal + "->DS2N" + iif( j1 == 1, "", "_" + lstr( j1 ) )
                      &pole := mo_read_xml_stroke( oNode2, "DS2" )
                      pole := lal + "->DS2N" + iif( j1 == 1, "", "_" + lstr( j1 ) ) + "_PR"
                      &pole := mo_read_xml_stroke( oNode2, "DS2_PR",, .f. )
                      pole := lal + "->DS2N" + iif( j1 == 1, "", "_" + lstr( j1 ) ) + "_D"
                      &pole := mo_read_xml_stroke( oNode2, "PR_D",, .f. )
                    Endif
                  Next
                  // DS2 для обычного листа учёта
                  _ar := mo_read_xml_array( oNode11, "DS2" ) // М.Б.НЕСКОЛЬКО DS2
                  For j1 := 1 To Min( 7, Len( _ar ) )
                    pole := lal + "->DS2" + iif( j1 == 1, "", "_" + lstr( j1 ) )
                    &pole := _ar[ j1 ]
                  Next
                  _ar := mo_read_xml_array( oNode11, "DS3" ) // М.Б.НЕСКОЛЬКО DS3
                  For j1 := 1 To Min( 3, Len( _ar ) )
                    pole := lal + "->DS3" + iif( j1 == 1, "", "_" + lstr( j1 ) )
                    &pole := _ar[ j1 ]
                  Next
                  &lal.->C_ZAB := mo_read_xml_stroke( oNode11, "C_ZAB",, .f. )
                  &lal.->DS_ONK := mo_read_xml_stroke( oNode11, "DS_ONK",, .f. )
                  &lal.->DN := mo_read_xml_stroke( oNode11, "DN",, .f. )
                  If ( oNode3 := oNode11:find( "PRESCRIPTION" ) ) != NIL
                    For i := 1 To Len( oNode3:aitems ) // последовательный просмотр
                      oNode2 := oNode3:aItems[ i ]     // т.к. назначений м.б. несколько
                      If ValType( oNode2 ) != "C" .and. oNode2:title == "PRESCRIPTIONS"
                        Select T5
                        Append Blank
                        t5->sluch  := iisl
                        t5->KOD    := mkod
                        t5->IDCASE := &lal.->IDCASE // для связи со случаем
                        t5->NAZ_N  := mo_read_xml_stroke( oNode2, "NAZ_N",, .f. )
                        t5->NAZ_R  := mo_read_xml_stroke( oNode2, "NAZ_R",, .f. )

                        // добавил по новому ПУМП от 02.08.21
                        If p_tip_reestr == 2 .and. ( xml2date( t1->DATE_Z_2 ) >= 0d20210801 )
                          t5->NAZ_IDDT  := mo_read_xml_stroke( oNode2, "NAZ_IDDOKT",, .f. )
                          t5->NAZ_SPDT  := mo_read_xml_stroke( oNode2, "NAZ_SPDOCT",, .f. )
                        Endif

                        t5->NAZ_SP := mo_read_xml_stroke( oNode2, "NAZ_SP",, .f. )
                          /*_ar := mo_read_xml_array(oNode2,"NAZ_SP") // М.Б.НЕСКОЛЬКО NAZ_SP
                          for j1 := 1 to min(3,len(_ar))
                            pole := "t5->NAZ_SP"+lstr(j1)
                            &pole := _ar[j1]
                          next*/
                        t5->NAZ_V := mo_read_xml_stroke( oNode2, "NAZ_V",, .f. )
                          /*_ar := mo_read_xml_array(oNode2,"NAZ_V") // М.Б.НЕСКОЛЬКО NAZ_V
                          for j1 := 1 to min(3,len(_ar))
                            pole := "t5->NAZ_V"+lstr(j1)
                            &pole := _ar[j1]
                          next*/
                        t5->NAZ_USL  := mo_read_xml_stroke( oNode2, "NAZ_USL",, .f. )
                        t5->NAPR_DATE := mo_read_xml_stroke( oNode2, "NAPR_DATE",, .f. )
                        t5->NAPR_MO  := mo_read_xml_stroke( oNode2, "NAPR_MO",, .f. )
                        t5->NAZ_PMP  := mo_read_xml_stroke( oNode2, "NAZ_PMP",, .f. )
                        t5->NAZ_PK   := mo_read_xml_stroke( oNode2, "NAZ_PK",, .f. )
                      Endif
                    Next
                  Endif
                  &lal.->CODE_MES1 := mo_read_xml_stroke( oNode11, "CODE_MES1",, .f. )
                  If ( oNode3 := oNode11:find( "KSG_KPG" ) ) != NIL
                    &lal.->N_KSG := mo_read_xml_stroke( oNode3, "N_KSG",, .f. )
                    _ar := mo_read_xml_array( oNode3, "CRIT" ) // М.Б.НЕСКОЛЬКО DS3
                    For j1 := 1 To Min( 2, Len( _ar ) )
                      pole := lal + "->CRIT" + iif( j1 == 1, "", lstr( j1 ) )
                      &pole := _ar[ j1 ]
                    Next
                    &lal.->SL_K  := mo_read_xml_stroke( oNode3, "SL_K",, .f. )
                    &lal.->IT_SL := mo_read_xml_stroke( oNode3, "IT_SL",, .f. )
                    jkslp := 0
                    For j1 := 1 To Len( oNode3:aitems ) // последовательный просмотр
                      oNode2 := oNode3:aItems[ j1 ]     // т.к. КСЛП м.б. несколько
                      If ValType( oNode2 ) != "C" .and. oNode2:title == "SL_KOEF"
                        ++jkslp
                        If jkslp == 1
                          &lal.->kod_kslp  := mo_read_xml_stroke( oNode2, "ID_SL" )
                          &lal.->koef_kslp := mo_read_xml_stroke( oNode2, "VAL_C" )
                        Elseif  jkslp == 3
                          &lal.->kod_kslp3 := mo_read_xml_stroke( oNode2, "ID_SL" )
                          &lal.->koef_kslp3 := mo_read_xml_stroke( oNode2, "VAL_C" )
                        Else
                          &lal.->kod_kslp2 := mo_read_xml_stroke( oNode2, "ID_SL" )
                          &lal.->koef_kslp2 := mo_read_xml_stroke( oNode2, "VAL_C" )
                        Endif
                      Elseif ValType( oNode2 ) != "C" .and. oNode2:title == "S_KIRO"
                        &lal.->CODE_KIRO := mo_read_xml_stroke( oNode2, "CODE_KIRO" )
                        &lal.->VAL_K     := mo_read_xml_stroke( oNode2, "VAL_K" )
                      Endif
                    Next j1
                  Endif
                  For j1 := 1 To Len( oNode11:aitems ) // последовательный просмотр
                    oNode2 := oNode11:aItems[ j1 ]     // т.к. услуг м.б. несколько
                    If ValType( oNode2 ) != "C" .and. oNode2:title == "NAPR"
                      Select T6
                      Append Blank
                      t6->sluch    := iisl
                      t6->KOD      := mkod
                      t6->IDCASE   := &lal.->IDCASE // для связи со случаем
                      t6->NAPR_DATE := mo_read_xml_stroke( oNode2, "NAPR_DATE" )
                      // добавил по новому ПУМП от 02.08.21
                      If p_tip_reestr == 2 .and. ( xml2date( t1->DATE_Z_2 ) >= 0d20210801 )
                        t6->NAZ_IDDT  := mo_read_xml_stroke( oNode2, "NAZ_IDDOKT",, .f. )
                        t6->NAZ_SPDT  := mo_read_xml_stroke( oNode2, "NAZ_SPDOCT",, .f. )
                      Endif
                      t6->NAPR_MO  := mo_read_xml_stroke( oNode2, "NAPR_MO",, .f. )
                      t6->NAPR_V   := mo_read_xml_stroke( oNode2, "NAPR_V" )
                      t6->MET_ISSL := mo_read_xml_stroke( oNode2, "MET_ISSL",, .f. )
                      t6->U_KOD    := mo_read_xml_stroke( oNode2, "NAPR_USL",, .f. )
                    Elseif ValType( oNode2 ) != "C" .and. oNode2:title == "CONS"
                      &lal.->PR_CONS := mo_read_xml_stroke( oNode2, "PR_CONS",, .f. )
                      &lal.->DT_CONS := mo_read_xml_stroke( oNode2, "DT_CONS",, .f. )
                    Endif
                  Next
                  If ( oNode3 := oNode11:find( "ONK_SL" ) ) != NIL
                    &lal.->DS1_T := mo_read_xml_stroke( oNode3, "DS1_T",, .f. )
                    &lal.->STAD  := mo_read_xml_stroke( oNode3, "STAD",, .f. )
                    &lal.->ONK_T := mo_read_xml_stroke( oNode3, "ONK_T",, .f. )
                    &lal.->ONK_N := mo_read_xml_stroke( oNode3, "ONK_N",, .f. )
                    &lal.->ONK_M := mo_read_xml_stroke( oNode3, "ONK_M",, .f. )
                    &lal.->MTSTZ := mo_read_xml_stroke( oNode3, "MTSTZ",, .f. )
                    &lal.->SOD   := mo_read_xml_stroke( oNode3, "SOD",, .f. )
                    &lal.->K_FR   := mo_read_xml_stroke( oNode3, "K_FR",, .f. )
                    &lal.->WEI   := mo_read_xml_stroke( oNode3, "WEI",, .f. )
                    &lal.->HEI   := mo_read_xml_stroke( oNode3, "HEI",, .f. )
                    &lal.->BSA   := mo_read_xml_stroke( oNode3, "BSA",, .f. )
                    For j1 := 1 To Len( oNode3:aitems ) // последовательный просмотр
                      oNode2 := oNode3:aItems[ j1 ]     // т.к. услуг м.б. несколько
                      If ValType( oNode2 ) != "C" .and. oNode2:title == "B_DIAG"
                        Select T7
                        Append Blank
                        t7->sluch     := iisl
                        t7->KOD       := mkod
                        t7->IDCASE    := &lal.->IDCASE // для связи со случаем
                        t7->DIAG_DATE := mo_read_xml_stroke( oNode2, "DIAG_DATE",, .f. )
                        t7->DIAG_TIP  := mo_read_xml_stroke( oNode2, "DIAG_TIP",, .f. )
                        t7->DIAG_CODE := mo_read_xml_stroke( oNode2, "DIAG_CODE",, .f. )
                        t7->DIAG_RSLT := mo_read_xml_stroke( oNode2, "DIAG_RSLT",, .f. )
                        t7->REC_RSLT  := mo_read_xml_stroke( oNode2, "REC_RSLT",, .f. )
                      Elseif ValType( oNode2 ) != "C" .and. oNode2:title == "B_PROT"
                        Select T8
                        Append Blank
                        t8->sluch  := iisl
                        t8->KOD    := mkod
                        t8->IDCASE := &lal.->IDCASE // для связи со случаем
                        t8->PROT   := mo_read_xml_stroke( oNode2, "PROT",, .f. )
                        t8->D_PROT := mo_read_xml_stroke( oNode2, "D_PROT",, .f. )
                      Elseif ValType( oNode2 ) != "C" .and. oNode2:title == "ONK_USL"
                        Select T9
                        Append Blank
                        t9->sluch  := iisl
                        t9->KOD    := mkod
                        t9->IDCASE := &lal.->IDCASE // для связи со случаем
                        t9->USL_TIP  := mo_read_xml_stroke( oNode2, "USL_TIP",, .f. )
                        t9->HIR_TIP  := mo_read_xml_stroke( oNode2, "HIR_TIP",, .f. )
                        t9->LEK_TIP_L := mo_read_xml_stroke( oNode2, "LEK_TIP_L",, .f. )
                        t9->LEK_TIP_V := mo_read_xml_stroke( oNode2, "LEK_TIP_V",, .f. )
                        t9->LUCH_TIP := mo_read_xml_stroke( oNode2, "LUCH_TIP",, .f. )
                        t9->PPTR     := mo_read_xml_stroke( oNode2, "PPTR",, .f. )
                        For j2 := 1 To Len( oNode2:aitems ) // последовательный просмотр
                          oNode4 := oNode2:aItems[ j2 ]     // т.к. лекарственных препаратов м.б. несколько
                          If ValType( oNode4 ) != "C" .and. oNode4:title == "LEK_PR"
                            If p_tip_reestr == 1 .and. ( xml2date( t1->DATE_Z_2 ) >= 0d20250101 ) // после 01.01.25
                              lREGNUM := mo_read_xml_stroke( oNode4, "REGNUM",, .f. )
                              lREGNUM_DOP := mo_read_xml_stroke( oNode4, "REGNUM_DOP",, .f. )
                              lCODE_SH := mo_read_xml_stroke( oNode4, "CODE_SH",, .f. )

                              For j4 := 1 To Len( oNode4:aitems ) // последовательный просмотр лекарственных препаратов
                                oNode5 := oNode4:aItems[ j4 ]     // т.к. препаратов м.б. несколько
                                If ValType( oNode5 ) != 'C' .and. oNode5:title == 'INJ'
                                  Select T10
                                  T10->( dbAppend() )
                                  t10->sluch  := iisl
                                  t10->KOD    := mkod
                                  t10->IDCASE := &lal.->IDCASE // для связи со случаем
                                  t10->REGNUM := lREGNUM
                                  t10->REGNUM_DOP := lREGNUM_DOP
                                  t10->CODE_SH := lCODE_SH
                                  t10->DATE_INJ := mo_read_xml_stroke( oNode5, "DATE_INJ",, .f. )
                                  t10->KV_INJ := mo_read_xml_stroke( oNode5, "KV_INJ",, .f. )
                                  t10->KIZ_INJ := mo_read_xml_stroke( oNode5, "KIZ_INJ",, .f. )
                                  t10->S_INJ := mo_read_xml_stroke( oNode5, "S_INJ",, .f. )
                                  t10->SV_INJ := mo_read_xml_stroke( oNode5, "SV_INJ",, .f. )
                                  t10->SIZ_INJ := mo_read_xml_stroke( oNode5, "SIZ_INJ",, .f. )
                                  t10->RED_INJ := mo_read_xml_stroke( oNode5, "RED_INJ",, .f. )
                                endif
                              next            
                            else  // до 01.01.25
                              lREGNUM := mo_read_xml_stroke( oNode4, "REGNUM",, .f. )
                              lCODE_SH := mo_read_xml_stroke( oNode4, "CODE_SH",, .f. )
                              _ar := mo_read_xml_array( oNode4, "DATE_INJ" ) // М.Б.НЕСКОЛЬКО дат
                              For j3 := 1 To Len( _ar )
                                Select T10
                                Append Blank
                                t10->sluch  := iisl
                                t10->KOD    := mkod
                                t10->IDCASE := &lal.->IDCASE // для связи со случаем
                                t10->REGNUM := lREGNUM
                                t10->CODE_SH := lCODE_SH
                                t10->DATE_INJ := _ar[ j3 ]
                              Next j3                            
                            endif
                          Endif
                        Next j2
                      Endif
                    Next j1
                  Endif
                  &lal.->PRVS   := mo_read_xml_stroke( oNode11, "PRVS" )
                  &lal.->IDDOKT := mo_read_xml_stroke( oNode11, "IDDOKT",, .f. )
                  &lal.->ED_COL := mo_read_xml_stroke( oNode11, "ED_COL",, .f. )
                  &lal.->TARIF  := mo_read_xml_stroke( oNode11, "TARIF",, .f. )
                  &lal.->SUM_M  := mo_read_xml_stroke( oNode11, "SUM_M" )
                  // ///// insert LEK_PR
                  For j1 := 1 To Len( oNode11:aitems ) // последовательный просмотр лекарственных препаратов
                    oNode2 := oNode11:aItems[ j1 ]     // т.к. препаратов м.б. несколько
                    If ValType( oNode2 ) != "C" .and. oNode2:title == "LEK_PR"
                      Select T11
                      Append Blank
                      t11->sluch    := iisl
                      t11->KOD      := mkod
                      t11->IDCASE   := &lal.->IDCASE // для связи со случаем
                      t11->DATA_INJ := mo_read_xml_stroke( oNode2, "DATA_INJ" )  // Дата введения лекарственного препарата
                      t11->CODE_SH  := mo_read_xml_stroke( oNode2, "CODE_SH" )  // Код схемы лечения пациента/код группы препарата
                      t11->REGNUM   := mo_read_xml_stroke( oNode2, "REGNUM" )  // Идентификатор лекарственного препарата
                      // t11->COD_MARK    := mo_read_xml_stroke(oNode2,"COD_MARK")
                      If ( oNode3 := oNode2:find( "LEK_DOSE" ) ) != NIL
                        t11->ED_IZM   := mo_read_xml_stroke( oNode3, "ED_IZM" ) // Единица измерения дозы лекарственного препарата
                        t11->DOSE_INJ := mo_read_xml_stroke( oNode3, "DOSE_INJ" ) // Доза введения лекарственного препарата
                        t11->METHOD_I := mo_read_xml_stroke( oNode3, "METHOD_INJ" ) // Путь введения лекарственного препарата
                        t11->COL_INJ  := mo_read_xml_stroke( oNode3, "COL_INJ" ) // Количество введений в течении дня, указанного в DATA_INJ
                      Endif
                    Endif
                  Next j1
                  // //////
                  &lal.->NEXT_VISIT := mo_read_xml_stroke( oNode11, "NEXT_VISIT",, .f. )
                  &lal.->COMENTSL := mo_read_xml_stroke( oNode11, "COMENTSL",, .f. )
                  For j1 := 1 To Len( oNode11:aitems ) // последовательный просмотр
                    oNode2 := oNode11:aItems[ j1 ]     // т.к. услуг м.б. несколько
                    If ValType( oNode2 ) != "C" .and. oNode2:title == "USL"
                      Select T2
                      Append Blank
                      t2->sluch    := iisl
                      t2->KOD      := mkod
                      t2->IDCASE   := &lal.->IDCASE // для связи со случаем
                      t2->IDSERV   := mo_read_xml_stroke( oNode2, "IDSERV" )
                      t2->ID_U     := mo_read_xml_stroke( oNode2, "ID_U" )
                      t2->LPU      := mo_read_xml_stroke( oNode2, "LPU" )
                      t2->LPU_1    := mo_read_xml_stroke( oNode2, "LPU_1",, .f. )
                      t2->PODR     := mo_read_xml_stroke( oNode2, "PODR",, .f. )
                      t2->PROFIL   := mo_read_xml_stroke( oNode2, "PROFIL" )
                      t2->VID_VME  := mo_read_xml_stroke( oNode2, "VID_VME",, .f. )
                      t2->DET      := mo_read_xml_stroke( oNode2, "DET",, .f. )
                      t2->DATE_IN  := mo_read_xml_stroke( oNode2, "DATE_IN" )
                      t2->DATE_OUT := mo_read_xml_stroke( oNode2, "DATE_OUT" )
                      t2->P_OTK    := mo_read_xml_stroke( oNode2, "P_OTK",, .f. )
                      t2->DS       := mo_read_xml_stroke( oNode2, "DS",, .f. )
                      t2->CODE_USL := mo_read_xml_stroke( oNode2, "CODE_USL" )
                      ushifr := t2->CODE_USL
                      t2->KOL_USL  := mo_read_xml_stroke( oNode2, "KOL_USL" )
                      t2->TARIF    := mo_read_xml_stroke( oNode2, "TARIF" )
                      t2->SUMV_USL := mo_read_xml_stroke( oNode2, "SUMV_USL" )

                      If p_tip_reestr == 1 .and. ( xml2date( t1->DATE_Z_2 ) >= 0d20220101 ) // добавил по новому ПУМП от 18.01.22
                        // if (oNode100 := oNode2:Find("MED_DEV")) != NIL
                        // // имплантант
                        // tmpSelect := select()
                        // select T12
                        // append blank
                        // T12->SLUCH    := iisl // номер случая
                        // T12->KOD      := mkod // код
                        // T12->IDCASE   := &lal.->IDCASE // для связи со случаем
                        // T12->DATE_MED := mo_read_xml_stroke(oNode100, "DATE_MED") // Дата установки имплантанта
                        // T12->CODE_DEV := mo_read_xml_stroke(oNode100, "CODE_MEDDEV") // Код вида медицинского изделия (имплантанта)
                        // T12->NUM_SER  := mo_read_xml_stroke(oNode100, "NUMBER_SER") // Серийный номер медицинского изделия (имплантанта)
                        // select(tmpSelect)
                        // endif
                        // ///// insert MED_DEV
                        For j2 := 1 To Len( oNode2:aitems ) // последовательный просмотр медицинских имплантантов
                          oNode100 := oNode2:aItems[ j2 ]     // т.к. имплантантов может быть несколько
                          If ValType( oNode100 ) != "C" .and. oNode100:title == "MED_DEV"
                            tmpSelect := Select()
                            Select T12
                            Append Blank
                            T12->sluch    := iisl
                            T12->KOD      := mkod
                            T12->IDCASE   := &lal.->IDCASE    // для связи со случаем
                            T12->CODE_USL := AllTrim( ushifr )  // для привязки к услуге
                            T12->DATE_MED := mo_read_xml_stroke( oNode100, "DATE_MED" ) // Дата установки имплантанта
                            T12->CODE_DEV := mo_read_xml_stroke( oNode100, "CODE_MEDDEV" ) // Код вида медицинского изделия (имплантанта)
                            T12->NUM_SER  := mo_read_xml_stroke( oNode100, "NUMBER_SER" ) // Серийный номер медицинского изделия (имплантанта)
                            Select( tmpSelect )
                          Endif
                        Next j2
                        // //////

                      Endif

                      If p_tip_reestr == 2 .and. ( xml2date( t1->DATE_Z_2 ) >= 0d20210801 ) // добавил по новому ПУМП от 02.08.21
                        If ( oNode100 := oNode2:find( "MR_USL_N" ) ) != NIL
                          // пока только 1 врач
                          t2->PRVS  := mo_read_xml_stroke( oNode100, "PRVS" )
                          t2->CODE_MD  := mo_read_xml_stroke( oNode100, "CODE_MD",, .f. )
                        Endif
                      Elseif p_tip_reestr == 1 .and. ( xml2date( t1->DATE_Z_2 ) >= 0d20220101 ) // добавил по новому ПУМП от 11.01.22
                        If ( oNode100 := oNode2:find( "MR_USL_N" ) ) != NIL
                          // пока только 1 врач
                          t2->PRVS     := mo_read_xml_stroke( oNode100, "PRVS" )
                          t2->CODE_MD  := mo_read_xml_stroke( oNode100, "CODE_MD",, .f. )
                        Endif
                      Else // по старому ПУМП
                        t2->PRVS     := mo_read_xml_stroke( oNode2, "PRVS" )
                        t2->CODE_MD  := mo_read_xml_stroke( oNode2, "CODE_MD", , .f. )
                      Endif

                      t2->COMENTU  := mo_read_xml_stroke( oNode2, "COMENTU",, .f. )
                    Endif
                  Next j1
                Endif
              Next isl
            Endif
          Endif
          If flag_tmp1
            tmp1->_KOL++
            tmp1->_MAX := Max( tmp1->_MAX, Int( Val( mo_read_xml_stroke( oXmlNode, "N_ZAP" ) ) ) )
          Endif
        Case is_all .and. "PERS" == oXmlNode:title
          Select T3
          Append Blank
          t3->KOD     := mkod
          t3->ID_PAC  := mo_read_xml_stroke( oXmlNode, "ID_PAC" )
          t3->FAM     := mo_read_xml_stroke( oXmlNode, "FAM" )
          t3->IM      := mo_read_xml_stroke( oXmlNode, "IM" )
          t3->OT      := mo_read_xml_stroke( oXmlNode, "OT",, .f. )
          t3->W       := mo_read_xml_stroke( oXmlNode, "W" )
          t3->DR      := mo_read_xml_stroke( oXmlNode, "DR" )
          t3->DOST    := mo_read_xml_stroke( oXmlNode, "DOST",, .f. )
          t3->TEL     := mo_read_xml_stroke( oXmlNode, "TEL",, .f. )
          t3->FAM_P   := mo_read_xml_stroke( oXmlNode, "FAM_P",, .f. )
          t3->IM_P    := mo_read_xml_stroke( oXmlNode, "IM_P",, .f. )
          t3->OT_P    := mo_read_xml_stroke( oXmlNode, "OT_P",, .f. )
          t3->W_P     := mo_read_xml_stroke( oXmlNode, "W_P",, .f. )
          t3->DR_P    := mo_read_xml_stroke( oXmlNode, "DR_P",, .f. )
          t3->DOST_P  := mo_read_xml_stroke( oXmlNode, "DOST_P",, .f. )
          t3->MR      := mo_read_xml_stroke( oXmlNode, "MR",, .f. )
          t3->DOCTYPE := mo_read_xml_stroke( oXmlNode, "DOCTYPE",, .f. )
          t3->DOCSER  := mo_read_xml_stroke( oXmlNode, "DOCSER",, .f. )
          t3->DOCNUM  := mo_read_xml_stroke( oXmlNode, "DOCNUM",, .f. )
          t3->DOCDATE := mo_read_xml_stroke( oXmlNode, "DOCDATE",, .f. )
          t3->DOCORG  := mo_read_xml_stroke( oXmlNode, "DOCORG",, .f. )
          t3->SNILS   := mo_read_xml_stroke( oXmlNode, "SNILS",, .f. )
          t3->OKATOG  := mo_read_xml_stroke( oXmlNode, "OKATOG",, .f. )
          t3->OKATOP  := mo_read_xml_stroke( oXmlNode, "OKATOP",, .f. )
        Endcase
        If j % 2000 == 0
          Commit
        Endif
      Next j
      If is_old
        Exit
      Endif
    Next ii
    If is_old
      // fl := extract_old_reestr(mkod,mname_xml,flag_tmp1,is_all,goal_dir)
    Endif
    t1->( dbCloseArea() )
    t1_1->( dbCloseArea() )
    t2->( dbCloseArea() )
    t3->( dbCloseArea() )
    t4->( dbCloseArea() )
    t5->( dbCloseArea() )
    t6->( dbCloseArea() )
    t7->( dbCloseArea() )
    t8->( dbCloseArea() )
    t9->( dbCloseArea() )
    t10->( dbCloseArea() )
    t11->( dbCloseArea() )
    t12->( dbCloseArea() )
    If flag_tmp1
      tmp1->( dbCloseArea() )
    Endif
  Endif
  rest_box( buf )

  Return fl
