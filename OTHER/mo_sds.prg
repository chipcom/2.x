// mo_sds.prg - интеграция с программой Smart Delta Systems
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 11.08.17 Интеграция с программой Smart Delta Systems
Function integration_sds( k )

  Static sk := 1
  Local mas_pmt, mas_msg, mas_fun, j, s, n_file

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { "~Просмотр XML-файла", ;
      "~Импорт XML-файла", ;
      "Согласование ~отделений" }
    mas_msg := { "Просмотр содержимого XML-файла от Smart Delta Systems", ;
      "Импорт XML-файла от Smart Delta Systems/создание листов учёта в программе CHIP_MO", ;
      "Согласование кодов отделений с кодами из программы Smart Delta Systems" }
    mas_fun := { "integration_SDS(1)", ;
      "integration_SDS(2)", ;
      "integration_SDS(3)" }
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL + 5, sk, mas_pmt, mas_msg, mas_fun )
  Case k == 1
    Private pikol := { 0, 0, 0 }, file_error := cur_dir() + "err_sds.txt"
    If ( n_file := f_get_file_xml_sds() ) != Nil .and. read_file_xml_sds( n_file )
      n_message( { "Просмотр XML-файла " + n_file, ;
        "", ;
        "Всего записей - " + lstr( pikol[ 1 ] ), ;
        "Записей без ошибок - " + lstr( pikol[ 2 ] ), ;
        "Записей с ошибками - " + lstr( pikol[ 3 ] );
        }, , "GR+/R", "W+/R", ,, "G+/R" )
      If pikol[ 3 ] > 0
        viewtext( devide_into_pages( file_error, 60, 80 ), ,, , .t., ,, 2 )
      Else
        viewtext( devide_into_pages( "ttt.ttt", 60, 80 ), ,, , .t., ,, 2 )
      Endif
    Endif
  Case k == 2
    Private pikol := { 0, 0, 0 }, file_error := cur_dir() + "err_sds.txt", t1 := Seconds()
    If ( n_file := f_get_file_xml_sds( @s ) ) != Nil .and. read_file_xml_sds( n_file )
      If pikol[ 3 ] > 0
        viewtext( devide_into_pages( file_error, 60, 80 ), ,, , .t., ,, 2 )
      Else
        write_file_xml_sds( n_file, s )
      Endif
    Endif
  Case k == 3
    sds_kod_sogl_otd()
  Endcase
  If k > 0
    sk := k
  Endif

  Return Nil

// 12.09.25
Function read_file_xml_sds( n_file )

  Static cDelimiter := " , "
  Local _sluch := { ;
    { "REC_HUMAN",   "N",     7,     0 }, ; // в какой номер записи файла human будет записан
    { "ID_SDS",  "N",    15,     0 }, ;
    { "KOD",   "N",     7,     0 }, ;
    { "N_ZAP",   "C",     8,     0 }, ; // номер позиции записи в реестре;поле "ZAP"
    { "FIO",   "C",    50,     0 }, ;
    { "FAM",   "C",    40,     0 }, ;
    { "IM",   "C",    40,     0 }, ;
    { "OT",   "C",    40,     0 }, ;
    { "W",   "N",     1,     0 }, ;
    { "DR",   "D",     8,     0 }, ;
    { "VPOLIS",    "N",     1,     0 }, ;
    { "SPOLIS",    "C",    10,     0 }, ;
    { "NPOLIS",    "C",    20,     0 }, ;
    { "SMO",         "C",     5,     0 }, ;
    { "SMO_OK",      "C",     5,     0 }, ;
    { "SMO_NAM",     "C",   100,     0 }, ; // наименование иногородней СМО
    { "DOCTYPE",     "N",     2,     0 }, ;
    { "DOCSER",      "C",    10,     0 }, ;
    { "DOCNUM",      "C",    20,     0 }, ;
    { "MR",          "C",   100,     0 }, ;
    { "OKATOG",      "C",    11,     0 }, ;
    { "OKATOP",      "C",    11,     0 }, ;
    { "SNILS",   "C",    11,     0 }, ;
    { "OTD",   "N",     3,     0 }, ;
    { "OTD_SDS",   "N",    10,     0 }, ;
    { "PROFIL",      "N",     3,     0 }, ;
    { "PROFIL_K",    "N",     3,     0 }, ;
    { "NHISTORY",  "C",    10,     0 }, ;
    { "DATE_1",   "D",     8,     0 }, ;
    { "DATE_2",   "D",     8,     0 }, ;
    { "DS0",         "C",     6,     0 }, ;
    { "DS1",        "C",     6,     0 }, ;
    { "DS2",         "C",     6,     0 }, ;
    { "DS2_2",       "C",     6,     0 }, ;
    { "DS2_3",       "C",     6,     0 }, ;
    { "DS2_4",       "C",     6,     0 }, ;
    { "DS2_5",       "C",     6,     0 }, ;
    { "DS2_6",       "C",     6,     0 }, ;
    { "DS2_7",       "C",     6,     0 }, ;
    { "DS3",         "C",     6,     0 }, ;
    { "DS3_2",       "C",     6,     0 }, ;
    { "DS3_3",       "C",     6,     0 }, ;
    { "C_ZAB",       "N",     1,     0 }, ;
    { "NOVOR",       "N",     1,     0 }, ;
    { "REB_NUMBER",  "N",     2,     0 }, ;
    { "REB_DR",      "D",     8,     0 }, ;
    { "REB_POL",     "N",     1,     0 }, ;
    { "USL_OK",      "N",     1,     0 }, ;
    { "DN_STAC",     "N",     1,     0 }, ;
    { "REABIL",      "N",     3,     0 }, ;
    { "VID_AMB",     "N",     2,     0 }, ;
    { "BRIG_SMP",    "N",     2,     0 }, ;
    { "P_PER",       "N",     1,     0 }, ;
    { "FOR_POM",     "N",     1,     0 }, ;
    { "RSLT",        "N",     3,     0 }, ;
    { "ISHOD",       "N",     3,     0 }, ;
    { "VRACH",       "N",     5,     0 }, ;
    { "VRACH_SDS",   "N",     5,     0 }, ;
    { "VR_SNILS",    "C",    11,     0 }, ;
    { "PRVS",        "N",     4,     0 }, ;
    { "VID_HMP",     "C",    12,     0 }, ; // вид ВМП по справочнику V018
    { "METOD_HMP",   "N",     4,     0 }, ; // метод ВМП по справочнику V019
    { "TAL_NUM",     "C",    20,     0 }, ; // Номер талона на ВМП
    { "TAL_D",       "D",     8,     0 }, ; // Дата выдачи талона на ВМП
    { "TAL_P",       "D",     8,     0 }, ; // Дата планируемой госпитализации в соответствии с талоном на ВМП
    { "NPR_MO",      "C",     6,     0 }, ;
    { "NPR_DATE",    "D",     8,     0 }, ;
    { "DN",          "N",     1,     0 }, ;
    { "NEXT_VIZIT",  "D",     8,     0 }, ;
    { "VNR1",        "N",     4,     0 }, ; // вес 1-го недоношенного ребёнка (лечится мать)
    { "VNR2",        "N",     4,     0 }, ; // вес 2-го недоношенного ребёнка (лечится мать)
    { "VNR3",        "N",     4,     0 }, ; // вес 3-го недоношенного ребёнка (лечится мать)
    { "DS_ONK",      "N",     1,     0 }, ;
    { "PR_CONS",   "N",     1,     0 }, ; // Сведения о проведении консилиума(N019):0-отсутствует необходимость;1-определена тактика обследования;2-определена тактика лечения;3-изменена тактика лечения
    { "DT_CONS",   "D",     8,     0 }, ;  // Дата проведения консилиума Обязательно к заполнению при PR_CONS=1,2,3
    { "DS1_T",   "N",     1,     0 }, ; // Повод обращения(N018):0-первичное лечение;1-рецидив;2-прогрессирование;3-динам.наблюдение;4-диспанс.наблюдение;5-диагностика;6-симптоматическое лечение
    { "STAD",   "N",     3,     0 }, ; // Стадия заболевания(N002)обязательно при DS1_T = от 0 до 4
    { "ONK_T",   "N",     3,     0 }, ; // Значение Tumor(N003) обязательно для взрослых при при DS1_T=0
    { "ONK_N",   "N",     3,     0 }, ; // Значение Nodus(N004) обязательно для взрослых при при DS1_T=0
    { "ONK_M",   "N",     3,     0 }, ; // Значение Metastasis(N005) обязательно для взрослых при при DS1_T=0
    { "MTSTZ",   "N",     1,     0 }, ; // Признак выявления отдалённых метастазов Подлежит заполнению значением 1 при выявлении отдалённых метастазов только при DS1_T=1,2
    { "B_DIAG",   "N",     2,     0 }, ; // гистология:99-не надо,98-сделана(результат получен),97-сделана(результат не получен),0-отказ,7-не показано,8-противопоказано
    { "SOD",   "N",     6,     2 }, ; // Суммарная очаговая доза Обязательно для заполнения при проведении лучевой или химиолучевой терапии (USL_TIP=3 или USL_TIP=4)м.б.=0
    { "K_FR",   "N",     2,     0 }, ; // кол-во фракций проведения лучевой терапии Обязательно для заполнения при проведении лучевой или химиолучевой терапии (USL_TIP=3 или USL_TIP=4)м.б.=0
    { "AD_CR",   "C",    10,     0 }, ; // критерий
    { "AD_CR2",   "C",    10,     0 }, ; // доп.критерий (fr...)
    { "IS_ERR",   "N",     1,     0 }, ; // Признак несоблюдения схемы лекарственной терапии: 0-нормально, 1-не соблюдена
    { "WEI",   "N",     5,     1 }, ; // масса тела в кг Обязательно для заполнения при проведении лекарственной или химиолучевой терапии (USL_TIP=2 или USL_TIP=4)
    { "HEI",   "N",     3,     0 }, ; // рост в см Обязательно для заполнения при проведении лекарственной или химиолучевой терапии (USL_TIP=2 или USL_TIP=4)
    { "BSA",   "N",     4,     2 }, ;  // площадь поверхности тела в кв.м. Обязательно для заполнения при проведении лекарственной или химиолучевой терапии (USL_TIP=2 или USL_TIP=4)
    { "KSLP",        "C",    20,     0 }, ;
    { "KIRO",        "C",    10,     0 }, ;
    { "KSG",         "C",    10,     0 }, ;
    { "CENA_KSG",   "N",    10,     2 }, ;
    { "SUMV",   "N",    10,     2 }, ;
    { "PN6",   "N",    1,      0 };    // m1NMSE направление на МСЭ
    }
  Local _sluch_na := { ; // онконаправления
    { "KOD",   "N",     7,     0 }, ; // код больного
    { "NAPR_DATE",   "D",     8,     0 }, ; // Дата направления
    { "NAPR_MO",     "C",     6,     0 }, ; // код другого МО, куда выписано направление
    { "NAPR_V",    "N",     1,     0 }, ; // Вид направления(V028):1-к онкологу,2-на биопсию,3-на дообследование,4-для опр.тактики лечения
    { "MET_ISSL",   "N",     1,     0 }, ; // Метод диагн.исследования(V029)(при NAPR_V=3):1-лаб.диагностика;2-инстр.диагностика;3-луч.диагностика;4-КТ, МРТ, ангиография
    { "CODE_USL", "C",    20,     0 }, ;
    { "NAME_U",      "C",   255,     0 }, ; // наименование
    { "U_KOD",   "N",     6,     0 };  // код услуги(V001)
    }
  Local _sluch_di := { ; // Диагностический онкоблок
    { "KOD",   "N",     7,     0 }, ; // код больного
    { "DIAG_DATE",   "D",     8,     0 }, ; // Дата взятия материала для проведения диагностики
    { "DIAG_TIP",   "N",     1,     0 }, ; // Тип диагностического показателя: 1 - гистологический признак; 2 - маркёр (ИГХ)
    { "DIAG_CODE",   "N",     3,     0 }, ; // Код диагностического показателя При DIAG_TIP=1 в соответствии со справочником N007 При DIAG_TIP=2 в соответствии со справочником N010
    { "DIAG_RSLT",   "N",     3,     0 }, ; // Код результата диагностики При DIAG_TIP=1 в соответствии со справочником N008 При DIAG_TIP=2 в соответствии со справочником N011
    { "REC_RSLT",    "N",     1,     0 };  // признак получения результата диагностики 1 - получен
  }
  Local _sluch_pr := { ; // Сведения об имеющихся противопоказаниях
    { "KOD",   "N",     7,     0 }, ; // код больного
    { "PROT",   "N",     1,     0 }, ; // Код противопоказания или отказа в соответствии со справочником N001
    { "D_PROT",   "D",     8,     0 };  // Дата регистрации противопоказания или отказа
  }
  Local _sluch_us := { ; // Сведения о проведённых лечениях
    { "KOD",   "N",     7,     0 }, ; // код больного
    { "USL_TIP",   "N",     1,     0 }, ; // Тип онкоуслуги в соответствии со справочником N013
    { "HIR_TIP",   "N",     1,     0 }, ; // Тип хирургического лечения При USL_TIP=1 в соответствии со справочником N014
    { "LEK_TIP_L",   "N",     1,     0 }, ; // Линия лекарственной терапии При USL_TIP=2 в соответствии со справочником N015
    { "LEK_TIP_V",   "N",     1,     0 }, ; // Цикл лекарственной терапии При USL_TIP=2 в соответствии со справочником N016
    { "LUCH_TIP",   "N",     1,     0 }, ; // Тип лучевой терапии При USL_TIP=3,4 в соответствии со справочником N017
    { "PPTR",       "N",     1,     0 };  // Признак проведения профилактики тошноты и рвотного рефлекса - указывается "1" при USL_TIP=2,4
  }
  Local _sluch_le := { ; // Сведения о применённых лекарственных препаратах
    { "KOD",   "N",     7,     0 }, ; // код больного
    { "REGNUM",      "C",     6,     0 }, ; // IDD лек.препарата N020
    { "CODE_SH",     "C",    20,     0 }, ; // код схемы лек.терапии V024
    { "DATE_INJ",    "D",     8,     0 };  // дата введения лек.препарата
  }
  Local _sluch_p := { ; // подразделения (отделения)
    { "KOD",   "N",     7,     0 }, ; // код по файлу _sluch
    { "OTD",   "N",     3,     0 }, ;
    { "OTD_SDS",   "N",    10,     0 }, ;
    { "DATE_1",   "D",     8,     0 }, ;
    { "DATE_2",   "D",     8,     0 }, ;
    { "PROFIL",      "N",     3,     0 }, ;
    { "DS",          "C",     6,     0 }, ;
    { "KOL_PD",      "N",     5,     0 }, ; // кол-во пациенто-дней для дневного стационара
    { "VRACH",       "N",     5,     0 }, ;
    { "VRACH_SDS",   "N",     5,     0 }, ;
    { "VR_SNILS",    "C",    11,     0 }, ;
    { "PRVS",        "N",     4,     0 };
    }
  Local _sluch_u := { ; // услуги (в отделении)
    { "KOD",   "N",     7,     0 }, ; // код по файлу _sluch
    { "KODP",   "N",     7,     0 }, ; // код по файлу _sluch_p
    { "OTD",   "N",     3,     0 }, ;
    { "OTD_SDS",   "N",    10,     0 }, ;
    { "PROFIL",      "N",     3,     0 }, ;
    { "DS",          "C",     6,     0 }, ;
    { "CODE_USL", "C",    20,     0 }, ;
    { "PAR_ORG",     "C",    30,     0 }, ;
    { "ZF",          "C",    30,     0 }, ;
    { "DATE_IN",  "D",     8,     0 }, ;
    { "DATE_OUT",  "D",     8,     0 }, ;
    { "KOL_USL",   "N",     3,     0 }, ;
    { "TARIF",    "N",    10,     2 }, ;
    { "SUMV_USL",   "N",    10,     2 }, ;
    { "VRACH",       "N",     5,     0 }, ;
    { "VRACH_SDS",   "N",     5,     0 }, ;
    { "VR_SNILS",    "C",    11,     0 }, ;
    { "PRVS",        "N",     4,     0 };
    }
  Local fl := .t., buf := save_maxrow()
  Local arrV018
  Local arrV019
  //
  mywait( "Чтение XML-файла ..." )
  dbCreate( cur_dir() + "_sluch", _sluch )
  dbCreate( cur_dir() + "_sluch_p", _sluch_p )
  dbCreate( cur_dir() + "_sluch_u", _sluch_u )
  dbCreate( cur_dir() + "_sluch_na", _sluch_na )
  dbCreate( cur_dir() + "_sluch_di", _sluch_di )
  dbCreate( cur_dir() + "_sluch_pr", _sluch_pr )
  dbCreate( cur_dir() + "_sluch_us", _sluch_us )
  dbCreate( cur_dir() + "_sluch_le", _sluch_le )
  Use ( cur_dir() + "_sluch" ) New Alias IHUMAN
  Index On Str( kod, 10 ) to ( cur_dir() + "tmp_ihum" )
  Use ( cur_dir() + "_sluch_na" ) New Alias NA
  Index On Str( kod, 10 ) to ( cur_dir() + "tmp_na" )
  Use ( cur_dir() + "_sluch_di" ) New Alias DI
  Index On Str( kod, 10 ) to ( cur_dir() + "tmp_di" )
  Use ( cur_dir() + "_sluch_pr" ) New Alias PR
  Index On Str( kod, 10 ) to ( cur_dir() + "tmp_pr" )
  Use ( cur_dir() + "_sluch_us" ) New Alias US
  Index On Str( kod, 10 ) to ( cur_dir() + "tmp_us" )
  Use ( cur_dir() + "_sluch_le" ) New Alias LE
  Index On Str( kod, 10 ) to ( cur_dir() + "tmp_le" )
  Use ( cur_dir() + "_sluch_p" ) New Alias IPODR
  Index On Str( kod, 10 ) to ( cur_dir() + "tmp_ip" )
  Use ( cur_dir() + "_sluch_u" ) New Alias IHU
  Index On Str( kod, 10 ) to ( cur_dir() + "tmp_ihu" )
  Index On Str( kodp, 10 ) to ( cur_dir() + "tmp_ihup" )
  Set Index to ( cur_dir() + "tmp_ihu" ), ( cur_dir() + "tmp_ihup" )
  Set Order To 2
  dbCreate( cur_dir() + "tmp1file", { ;
    { "VERSION",   "C",  5, 0 }, ;
    { "FILENAME",  "C", 26, 0 }, ;
    { "DATA",      "D",  8, 0 }, ;
    { "TIME",      "C",  5, 0 }, ;
    { "DATE_1",   "D",  8, 0 }, ;
    { "DATE_2",   "D",  8, 0 }, ;
    { "FILENAME2", "C", 26, 0 }, ;
    { "DATA2",     "D",  8, 0 }, ;
    { "TIME2",     "C",  5, 0 }, ;
    { "KOL",       "N",  6, 0 };
    } )
  Use ( cur_dir() + "tmp1file" ) New Alias TMP1
  Append Blank
  // читаем файл в память
  oXmlDoc := hxmldoc():read( n_file )
  If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
    Close databases
    rest_box( buf )
    Return func_error( 4, "Ошибка в чтении файла " + n_file )
  Endif
  For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
    @ MaxRow(), 1 Say "строка " + lstr( j ) Color cColorWait
    oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
    Do Case
    Case "ZGLV" == oXmlNode:title
      tmp1->VERSION :=          mo_read_xml_stroke( oXmlNode, "VERSION" )
      tmp1->DATA    := xml2date( mo_read_xml_stroke( oXmlNode, "DATA" ) )
      tmp1->TIME    :=          mo_read_xml_stroke( oXmlNode, "TIME" )
      tmp1->FILENAME :=          mo_read_xml_stroke( oXmlNode, "FILE" )
      If "-" $ tmp1->TIME
        tmp1->TIME := CharRepl( "-", tmp1->TIME, ":" ) // время в моём формате
      Endif
    Case "ZAP" == oXmlNode:title
      tmp1->kol++
      Select IHUMAN
      Append Blank
      ihuman->kod      := ihuman->( RecNo() )
      ihuman->N_ZAP    :=          mo_read_xml_stroke( oXmlNode, "N_ZAP" )
      ihuman->ID_SDS   :=      Val( mo_read_xml_stroke( oXmlNode, "ID_SDS" ) )
      ihuman->VPOLIS   :=      Val( mo_read_xml_stroke( oXmlNode, "VPOLIS", , .f. ) )
      ihuman->SPOLIS   :=          mo_read_xml_stroke( oXmlNode, "SPOLIS", , .f. )
      ihuman->NPOLIS   :=          mo_read_xml_stroke( oXmlNode, "NPOLIS", , .f. )
      ihuman->SMO      :=          mo_read_xml_stroke( oXmlNode, "SMO", , .f. )
      ihuman->SMO_OK   :=          mo_read_xml_stroke( oXmlNode, "SMO_OK", , .f. )
      ihuman->SMO_NAM  :=          mo_read_xml_stroke( oXmlNode, "SMO_NAM", , .f. )
      ihuman->FAM      :=          mo_read_xml_stroke( oXmlNode, "FAM" )
      ihuman->IM       :=          mo_read_xml_stroke( oXmlNode, "IM" )
      ihuman->OT       :=          mo_read_xml_stroke( oXmlNode, "OT", , .f. )
      ihuman->W        :=      Val( mo_read_xml_stroke( oXmlNode, "W" ) )
      ihuman->DR       := xml2date( mo_read_xml_stroke( oXmlNode, "DR" ) )
      ihuman->MR       :=          mo_read_xml_stroke( oXmlNode, "MR", , .f. )
      ihuman->DOCTYPE  :=      Val( mo_read_xml_stroke( oXmlNode, "DOCTYPE", , .f. ) )
      ihuman->DOCSER   :=          mo_read_xml_stroke( oXmlNode, "DOCSER", , .f. )
      ihuman->DOCNUM   :=          mo_read_xml_stroke( oXmlNode, "DOCNUM", , .f. )
      ihuman->SNILS    := CharRem( " -", mo_read_xml_stroke( oXmlNode, "SNILS", , .f. ) )
      ihuman->OKATOG   :=          mo_read_xml_stroke( oXmlNode, "OKATOG", , .f. )
      ihuman->OKATOP   :=          mo_read_xml_stroke( oXmlNode, "OKATOP", , .f. )
      ihuman->USL_OK   :=      Val( mo_read_xml_stroke( oXmlNode, "USL_OK" ) )
      ihuman->DN_STAC  :=      Val( mo_read_xml_stroke( oXmlNode, "DN_STAC", , .f. ) )
      ihuman->VID_AMB  :=      Val( mo_read_xml_stroke( oXmlNode, "VID_AMB", , .f. ) )
      ihuman->VID_HMP  :=          mo_read_xml_stroke( oXmlNode, "VID_HMP", , .f. )
      ihuman->METOD_HMP :=      Val( mo_read_xml_stroke( oXmlNode, "METOD_HMP", , .f. ) )
      ihuman->NPR_MO   :=          mo_read_xml_stroke( oXmlNode, "NPR_MO", , .f. )
      ihuman->NPR_DATE := xml2date( mo_read_xml_stroke( oXmlNode, "NPR_DATE", , .f. ) )
      ihuman->REABIL   :=      Val( mo_read_xml_stroke( oXmlNode, "REHABILITATION", , .f. ) )
      ihuman->AD_CR    :=          mo_read_xml_stroke( oXmlNode, "AD_CR", , .f. )
      ihuman->FOR_POM  :=      Val( mo_read_xml_stroke( oXmlNode, "FOR_POM", , .f. ) )
      ihuman->PROFIL   :=      Val( mo_read_xml_stroke( oXmlNode, "PROFIL", , .f. ) )
      ihuman->PROFIL_K :=      Val( mo_read_xml_stroke( oXmlNode, "PROFIL_K", , .f. ) )
      ihuman->NHISTORY :=          mo_read_xml_stroke( oXmlNode, "NHISTORY" )
      ihuman->P_PER    :=      Val( mo_read_xml_stroke( oXmlNode, "P_PER", , .f. ) )
      ihuman->DATE_1   := xml2date( mo_read_xml_stroke( oXmlNode, "DATE_1" ) )
      ihuman->DATE_2   := xml2date( mo_read_xml_stroke( oXmlNode, "DATE_2" ) )
      ihuman->DS0      :=          mo_read_xml_stroke( oXmlNode, "DS0", , .f. )
      ihuman->DS1      :=          mo_read_xml_stroke( oXmlNode, "DS1", , .f. )
      If ihuman->REABIL == 2 // если это реабилитация
        ihuman->PROFIL := 158 // то профиль на уровне случая = 158 (мед.реабилитация)
      Endif
      s := mo_read_xml_stroke( oXmlNode, "DS2", , .f. ) ; _ar := {}
      For i := 1 To NumToken( s, cDelimiter )
        s1 := AllTrim( Token( s, cDelimiter, i ) )
        If !Empty( s1 )
          AAdd( _ar, s1 )
        Endif
      Next
      For j1 := 1 To Min( 7, Len( _ar ) )
        pole := "ihuman->DS2" + iif( j1 == 1, "", "_" + lstr( j1 ) )
        &pole := _ar[ j1 ]
      Next
      s := mo_read_xml_stroke( oXmlNode, "DS3", , .f. ) ; _ar := {}
      For i := 1 To NumToken( s, cDelimiter )
        s1 := AllTrim( Token( s, cDelimiter, i ) )
        If !Empty( s1 )
          AAdd( _ar, s1 )
        Endif
      Next
      For j1 := 1 To Min( 3, Len( _ar ) )
        pole := "ihuman->DS3" + iif( j1 == 1, "", "_" + lstr( j1 ) )
        &pole := _ar[ j1 ]
      Next
      ihuman->C_ZAB := Val( mo_read_xml_stroke( oXmlNode, "C_ZAB", , .f. ) )
      ihuman->DS_ONK := Val( mo_read_xml_stroke( oXmlNode, "DS_ONK", , .f. ) )
      ihuman->DN    := Val( mo_read_xml_stroke( oXmlNode, "DN", , .f. ) )
      ihuman->NEXT_VIZIT := xml2date( mo_read_xml_stroke( oXmlNode, "NEXT_VIZIT", , .f. ) )
      ihuman->RSLT  := Val( mo_read_xml_stroke( oXmlNode, "RSLT" ) )
      ihuman->ISHOD := Val( mo_read_xml_stroke( oXmlNode, "ISHOD" ) )
      ihuman->PRVS  := Val( mo_read_xml_stroke( oXmlNode, "PRVS", , .f. ) )
      If Empty( ihuman->PN6 := Val( mo_read_xml_stroke( oXmlNode, "NAPR_MSE", , .f. ) ) )
        ihuman->PN6 := 0
      Endif
      If Empty( ihuman->VRACH_SDS := Val( mo_read_xml_stroke( oXmlNode, "VRACH", , .f. ) ) )
        ihuman->VR_SNILS := CharRem( " -", mo_read_xml_stroke( oXmlNode, "VRACH_SNILS", , .f. ) )
      Endif
      For j1 := 1 To Len( oXmlNode:aitems ) // последовательный просмотр
        oNode2 := oXmlNode:aItems[ j1 ]
        If ValType( oNode2 ) != "C" .and. oNode2:title == "NAPR"
          Select NA
          Append Blank
          na->KOD      := ihuman->kod
          na->NAPR_DATE := xml2date( mo_read_xml_stroke( oNode2, "NAPR_DATE" ) )
          na->NAPR_MO  :=          mo_read_xml_stroke( oNode2, "NAPR_MO", , .f. )
          na->NAPR_V   :=      Val( mo_read_xml_stroke( oNode2, "NAPR_V" ) )
          na->MET_ISSL :=      Val( mo_read_xml_stroke( oNode2, "MET_ISSL", , .f. ) )
          na->CODE_USL :=          mo_read_xml_stroke( oNode2, "CODE_USL", , .f. )
        Elseif ValType( oNode2 ) != "C" .and. oNode2:title == "ONK_SL"
          ihuman->DS1_T := Val( mo_read_xml_stroke( oNode2, "DS1_T", , .f. ) )
          ihuman->PR_CONS :=      Val( mo_read_xml_stroke( oNode2, "PR_CONS", , .f. ) )
          ihuman->DT_CONS := xml2date( mo_read_xml_stroke( oNode2, "DT_CONS", , .f. ) )
          ihuman->STAD    :=      Val( mo_read_xml_stroke( oNode2, "STAD", , .f. ) )
          ihuman->ONK_T   :=      Val( mo_read_xml_stroke( oNode2, "ONK_T", , .f. ) )
          ihuman->ONK_N   :=      Val( mo_read_xml_stroke( oNode2, "ONK_N", , .f. ) )
          ihuman->ONK_M   :=      Val( mo_read_xml_stroke( oNode2, "ONK_M", , .f. ) )
          ihuman->MTSTZ   :=      Val( mo_read_xml_stroke( oNode2, "MTSTZ", , .f. ) )
          ihuman->SOD     :=      Val( mo_read_xml_stroke( oNode2, "SOD", , .f. ) )
          ihuman->K_FR    :=      Val( mo_read_xml_stroke( oNode2, "K_FR", , .f. ) )
          ihuman->WEI     :=      Val( mo_read_xml_stroke( oNode2, "WEI", , .f. ) )
          ihuman->HEI     :=      Val( mo_read_xml_stroke( oNode2, "HEI", , .f. ) )
          ihuman->BSA     :=      Val( mo_read_xml_stroke( oNode2, "BSA", , .f. ) )
          If ihuman->K_FR > 0 .and. ( i := AScan( _arr_fr, {| x| Between( ihuman->k_fr, x[ 3 ], x[ 4 ] ) } ) ) > 0
            ihuman->AD_CR2 := _arr_fr[ i, 2 ]
          Endif
          mDIAG_DATE := CToD( "" )
          For j2 := 1 To Len( oNode2:aitems ) // последовательный просмотр
            oNode3 := oNode2:aItems[ j2 ]
            If ValType( oNode3 ) != "C" .and. oNode3:title == "B_DIAG"
              Select DI
              Append Blank
              di->KOD       := ihuman->kod
              ldate := xml2date( mo_read_xml_stroke( oNode3, "DIAG_DATE" ) )
              If !Empty( ldate )
                mDIAG_DATE := ldate
              Endif
              di->DIAG_DATE := mDIAG_DATE
              di->DIAG_TIP  :=      Val( mo_read_xml_stroke( oNode3, "DIAG_TIP" ) )
              di->DIAG_CODE :=      Val( mo_read_xml_stroke( oNode3, "DIAG_CODE" ) )
              di->DIAG_RSLT :=      Val( mo_read_xml_stroke( oNode3, "DIAG_RSLT", , .f. ) )
              di->REC_RSLT  :=      Val( mo_read_xml_stroke( oNode3, "REC_RSLT", , .f. ) )
            Elseif ValType( oNode3 ) != "C" .and. oNode3:title == "B_PROT"
              Select PR
              Append Blank
              pr->KOD    := ihuman->kod
              pr->PROT   :=      Val( mo_read_xml_stroke( oNode3, "PROT" ) )
              pr->D_PROT := xml2date( mo_read_xml_stroke( oNode3, "D_PROT" ) )
            Elseif ValType( oNode3 ) != "C" .and. oNode3:title == "ONK_USL"
              Select US
              Append Blank
              us->KOD       := ihuman->kod
              us->USL_TIP   := Val( mo_read_xml_stroke( oNode3, "USL_TIP" ) )
              us->HIR_TIP   := Val( mo_read_xml_stroke( oNode3, "HIR_TIP", , .f. ) )
              us->LEK_TIP_L := Val( mo_read_xml_stroke( oNode3, "LEK_TIP_L", , .f. ) )
              us->LEK_TIP_V := Val( mo_read_xml_stroke( oNode3, "LEK_TIP_V", , .f. ) )
              us->LUCH_TIP  := Val( mo_read_xml_stroke( oNode3, "LUCH_TIP", , .f. ) )
              us->PPTR      := Val( mo_read_xml_stroke( oNode3, "PPTR", , .f. ) )
              If us->USL_TIP == 2
                ihuman->IS_ERR := Val( mo_read_xml_stroke( oNode3, "NOT_REGIM", , .f. ) )
              Endif
              For j3 := 1 To Len( oNode3:aitems ) // последовательный просмотр
                oNode4 := oNode3:aItems[ j3 ]
                If ValType( oNode3 ) != "C" .and. oNode4:title == "LEK_PR"
                  lREGNUM  := mo_read_xml_stroke( oNode4, "REGNUM" )
                  ihuman->AD_CR := mo_read_xml_stroke( oNode4, "CODE_SH" )
                  _ar := mo_read_xml_array( oNode4, "DATE_INJ" ) // М.Б.НЕСКОЛЬКО DATE_INJ
                  For j4 := 1 To Len( _ar )
                    Select LE
                    Append Blank
                    le->KOD      := ihuman->kod
                    le->REGNUM   := lREGNUM
                    le->CODE_SH  := ihuman->AD_CR
                    le->DATE_INJ := xml2date( _ar[ j4 ] )
                  Next j4
                Endif
              Next j3
            Endif
          Next j2
        Elseif ValType( oNode2 ) != "C" .and. oNode2:title == "PODR"
          Select IPODR
          Append Blank
          ipodr->KOD       := ihuman->kod
          ipodr->OTD_SDS   :=      Val( mo_read_xml_stroke( oNode2, "OTD" ) )
          ipodr->DATE_1    := xml2date( mo_read_xml_stroke( oNode2, "DATE_1" ) )
          ipodr->DATE_2    := xml2date( mo_read_xml_stroke( oNode2, "DATE_2" ) )
          ipodr->PROFIL    :=      Val( mo_read_xml_stroke( oNode2, "PROFIL", , .f. ) )
          ipodr->DS        :=          mo_read_xml_stroke( oNode2, "DS", , .f. )
          ipodr->KOL_PD    :=      Val( mo_read_xml_stroke( oNode2, "PATIENT_DAYS", , .f. ) )
          ipodr->PRVS      :=      Val( mo_read_xml_stroke( oNode2, "PRVS", , .f. ) )
          If Empty( ipodr->VRACH_SDS := Val( mo_read_xml_stroke( oNode2, "VRACH", , .f. ) ) )
            ipodr->VR_SNILS := CharRem( " -", mo_read_xml_stroke( oNode2, "VRACH_SNILS", , .f. ) )
          Endif
          If Empty( ipodr->DS ) .and. !Empty( ihuman->DS1 )
            ipodr->DS := ihuman->DS1
          Endif
          For j2 := 1 To Len( oNode2:aitems ) // последовательный просмотр
            oNode3 := oNode2:aItems[ j2 ]     // т.к. услуг м.б. несколько
            If ValType( oNode3 ) != "C" .and. oNode3:title == "USL"
              Select IHU
              Append Blank
              ihu->KODP      := ipodr->( RecNo() )
              ihu->KOD       := ihuman->kod
              ihu->OTD_SDS   := ipodr->OTD_SDS
              ihu->PROFIL    :=      Val( mo_read_xml_stroke( oNode3, "PROFIL", , .f. ) )
              ihu->DS        :=          mo_read_xml_stroke( oNode3, "DS", , .f. )
              ihu->DATE_IN   := xml2date( mo_read_xml_stroke( oNode3, "DATE" ) )
              ihu->CODE_USL  :=          mo_read_xml_stroke( oNode3, "CODE_USL" )
              ihu->KOL_USL   :=      Val( mo_read_xml_stroke( oNode3, "KOL_USL", , .f. ) )
              ihu->PRVS      :=      Val( mo_read_xml_stroke( oNode3, "PRVS", , .f. ) )
              If !Empty( s := mo_read_xml_stroke( oNode3, "COMENTU" ) )
                If eq_any( ihuman->USL_OK, 1, 2 )
                  ihu->PAR_ORG := s
                Elseif ihuman->USL_OK == 3
                  ihu->zf := s
                Endif
              Endif
              If Empty( ihu->VRACH_SDS := Val( mo_read_xml_stroke( oNode3, "VRACH", , .f. ) ) )
                ihu->VR_SNILS := CharRem( " -", mo_read_xml_stroke( oNode3, "VRACH_SNILS", , .f. ) )
              Endif
              If Empty( ihu->VRACH_SDS )
                ihu->VRACH_SDS := ipodr->VRACH_SDS
              Elseif Empty( ipodr->VRACH_SDS )
                ipodr->VRACH_SDS := ihu->VRACH_SDS
              Endif
              If Empty( ihu->VR_SNILS )
                ihu->VR_SNILS := ipodr->VR_SNILS
              Elseif Empty( ipodr->VR_SNILS )
                ipodr->VR_SNILS := ihu->VR_SNILS
              Endif
              If Empty( ihu->PRVS )
                ihu->PRVS := ipodr->PRVS
              Elseif Empty( ipodr->PRVS )
                ipodr->PRVS := ihu->PRVS
              Endif
              If Empty( ihu->PROFIL )
                ihu->PROFIL := ipodr->PROFIL
              Endif
              If Empty( ihu->DS )
                ihu->ds := ipodr->DS
              Elseif Empty( ipodr->DS )
                ipodr->DS := ihu->ds
              Endif
            Endif
          Next j2
          If !Empty( ipodr->VRACH_SDS )
            ihuman->VRACH_SDS := ipodr->VRACH_SDS
          Endif
          If !Empty( ipodr->VR_SNILS )
            ihuman->VR_SNILS := ipodr->VR_SNILS
          Endif
          If !Empty( ipodr->PRVS )
            ihuman->PRVS := ipodr->PRVS
          Endif
          If !Empty( ipodr->OTD_SDS )
            ihuman->OTD_SDS := ipodr->OTD_SDS
          Endif
          If !Empty( ipodr->PROFIL ) .and. Empty( ihuman->PROFIL )
            ihuman->PROFIL := ipodr->PROFIL
          Endif
          If Empty( ihuman->DS1 )
            ihuman->DS1 := ipodr->DS
          Endif
        Endif
      Next j1
    Endcase
    If j % 500 == 0
      Commit
    Endif
  Next j
  Commit
  //
  mywait( "Анализ XML-файла ..." )
  Private pr_otd := {} // массив кодов согласования отделений
  r_use( dir_server() + "mo_otd", , "OTD" )
  Go Top
  Do While !Eof()
    If otd->KOD_SOGL > 0
      AAdd( pr_otd, { otd->KOD_SOGL, otd->kod } )
    Elseif !Empty( otd->SOME_SOGL )
      arr := list2arr( otd->SOME_SOGL )
      For i := 1 To Len( arr )
        AAdd( pr_otd, { arr[ i ], otd->kod } )
      Next
    Endif
    Skip
  Enddo
  //
  StrFile( Center( "Список ошибок в импортируемом файле", 80 ) + hb_eol(), file_error )
  StrFile( Center( n_file, 80 ) + hb_eol() + hb_eol(), file_error, .t. )
  StrFile( Center( "Протокол чтения файла", 80 ) + hb_eol(), "ttt.ttt" )
  StrFile( Center( n_file, 80 ) + hb_eol() + hb_eol(), "ttt.ttt", .t. )
  Private paso, pasv, pasp, pass
  r_use( dir_exe() + "_okator", cur_dir() + "_okatr", "REGION" )
  r_use( dir_exe() + "_okatoo", cur_dir() + "_okato", "OBLAST" )
  r_use( dir_exe() + "_okatos", cur_dir() + "_okats", "SELO" )
  r_use( dir_exe() + "_mo_mkb", cur_dir() + "_mo_mkb", "MKB_10" )
  use_base( "lusl" )
  use_base( "luslc" )
  use_base( "luslf" )
  r_use( dir_exe() + "_mo_t2_v1", , "T2V1" )
  Index On PadR( shifr_mz, 20 ) to ( cur_dir() + "tmp_t2v1" )
  r_use( dir_exe() + "_mo_prof", , "MOPROF" )
  Index On Str( vzros_reb, 1 ) + Str( profil, 3 ) + shifr to ( cur_dir() + "tmp_prof" )
  r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERS" )
  Index On snils + Str( prvs_new, 4 ) to ( cur_dir() + "tmppsnils" )
  Index On snils + Str( prvs, 9 ) to ( cur_dir() + "tmppsnils1" )
  Set Index to ( dir_server() + "mo_pers" ), ( cur_dir() + "tmppsnils" ), ( cur_dir() + "tmppsnils1" )
  use_base( "mo_su" )
  use_base( "uslugi" )
  r_use( dir_server() + "uslugi1", { dir_server() + "uslugi1", ;
    dir_server() + "uslugi1s" }, "USL1" )
  r_use( dir_exe() + "_mo_smo", { cur_dir() + "_mo_smo", cur_dir() + "_mo_smo2" }, "SMO" )
  //
  Select IHUMAN
  Go Top
  Do While !Eof()
    @ MaxRow(), 1 Say "строка " + lstr( RecNo() ) Color cColorWait
    //
    f1_read_file_xml_sds( 0 )
    ae := {} ; ai := {}
    If Empty( ihuman->date_1 )
      ihuman->date_1 := sys_date
      AAdd( ae, "не заполнена дата начала лечения" )
    Endif
    If Empty( ihuman->date_2 )
      ihuman->date_2 := sys_date
      AAdd( ae, "не заполнена дата окончания лечения" )
    Endif
    If Empty( ihuman->ds1 )
      AAdd( ae, 'DS1 - не заполнено поле "ОСНОВНОЙ ДИАГНОЗ"' )
    Else
      Select MKB_10
      find ( PadR( ihuman->ds1, 6 ) )
      If !Found()
        AAdd( ae, 'DS1="' + RTrim( ihuman->DS1 ) + '"-основной диагноз не найден в справочнике МКБ-10' )
      Elseif !between_date( mkb_10->dbegin, mkb_10->dend, ihuman->DATE_2 )
        AAdd( ae, 'DS1="' + RTrim( ihuman->DS1 ) + '"-основной диагноз не входит в ОМС' )
      Elseif !Empty( mkb_10->pol ) .and. !( mkb_10->pol == iif( ihuman->W == 1, "М", "Ж" ) )
        AAdd( ae, 'DS1="' + RTrim( ihuman->DS1 ) + '"-несовместимость диагноза по полу' )
      Endif
    Endif
    If Empty( ihuman->VPOLIS )
      ihuman->VPOLIS := 1
    Endif
    If ihuman->VPOLIS == 1
      If Empty( ihuman->NPOLIS )
        ihuman->NPOLIS := CharRem( " ", ihuman->SPOLIS )
        ihuman->SPOLIS := ""
      Elseif !Empty( ihuman->SPOLIS ) .and. Left( ihuman->smo, 2 ) == '34'
        ihuman->NPOLIS := CharRem( " ", ihuman->SPOLIS ) + CharRem( " ", ihuman->NPOLIS )
        ihuman->SPOLIS := ""
      Endif
    Else
      ihuman->NPOLIS := CharRem( " ", ihuman->SPOLIS ) + CharRem( " ", ihuman->NPOLIS )
      ihuman->SPOLIS := ""
    Endif
    valid_sn_polis( ihuman->vpolis, ihuman->SPOLIS, ihuman->NPOLIS, ae, , Between( ihuman->SMO, '34001', '34007' ) )
    If AScan( getvidud(), {| x| x[ 2 ] == ihuman->DOCTYPE } ) == 0
      If ihuman->VPOLIS < 3
        AAdd( ae, 'DOCTYPE-не заполнено поле "ВИД удостоверения личности"' )
      Endif
    Else
      If Empty( ihuman->DOCNUM )
        If ihuman->VPOLIS < 3
          AAdd( ae, 'DOCNUM-должно быть заполнено поле "НОМЕР удостоверения личности"' )
        Endif
      Elseif !ver_number( ihuman->DOCNUM )
        AAdd( ae, 'DOCNUM-поле "НОМЕР удостоверения личности" должно быть цифровым' )
      Endif
      If !Empty( ihuman->DOCNUM )
        s := Space( 80 )
        If !val_ud_nom( 2, ihuman->DOCTYPE, ihuman->DOCNUM, @s )
          AAdd( ae, 'DOCNUM-' + s )
        Endif
      Endif
      If eq_any( ihuman->DOCTYPE, 1, 3, 14 ) .and. Empty( ihuman->DOCSER )
        If !( ihuman->VPOLIS == 3 .and. Empty( ihuman->DOCNUM ) )
          AAdd( ae, 'DOCSER-должно быть заполнено поле "СЕРИЯ удостоверения личности"' )
        Endif
      Endif
      If !Empty( ihuman->DOCSER )
        If ihuman->DOCTYPE == 14 .and. !( SubStr( ihuman->DOCSER, 3, 1 ) == " " )
          s := CharRem( " ", ihuman->DOCSER )
          ihuman->DOCSER := Left( s, 2 ) + " " + SubStr( s, 3 ) // исправить серию паспорта
        Endif
        s := Space( 80 )
        If !val_ud_ser( 2, ihuman->DOCTYPE, ihuman->DOCSER, @s )
          AAdd( ae, 'DOCSER-' + s )
        Endif
      Endif
    Endif
    afio := { ihuman->fam, ihuman->im, ihuman->ot }
    ihuman->fio := mfio := AllTrim( afio[ 1 ] ) + " " + AllTrim( afio[ 2 ] ) + " " + AllTrim( afio[ 3 ] )
    If emptyany( ihuman->fam, ihuman->im )
      AAdd( ae, 'не заполнены обязательные поля FAM, IM' )
    Endif
    val_fio( afio, ae )
    If !Empty( ihuman->SNILS )
      s := Space( 80 )
      If !val_snils( ihuman->snils, 2, @s )
//        AAdd( ai, 'SNILS="' + Transform( ihuman->SNILS, picture_pf ) + '"-' + s )
        AAdd( ai, 'SNILS="' + Transform_SNILS( ihuman->SNILS ) + '"-' + s )
      Endif
    Endif
    If Empty( ihuman->NPR_MO )
      If eq_any( ihuman->USL_OK, 1, 2 ) .and. ihuman->FOR_POM == 3 // плановая госпитализация
        ihuman->NPR_MO := glob_mo[ _MO_KOD_TFOMS ]
      Endif
    Else
      If ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == ihuman->NPR_MO } ) ) > 0
        //
      Elseif ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_FFOMS ] == ihuman->NPR_MO } ) ) > 0
        //
      Endif
      If i == 0
        AAdd( ai, "неверное значение поля NPR_MO = " + ihuman->NPR_MO )
      Endif
    Endif
    fl_okatosmo := .f. ; fl_nameismo := .f. ; fl_34 := .f.
    If Empty( ihuman->SMO )
      AAdd( ae, "не введен код СМО" )
    Else
      Select SMO
      Set Order To 2
      find ( ihuman->SMO )
      If Found()
        //
      Elseif Int( Val( ihuman->SMO ) ) == 34
        fl_34 := .t.
      Else
        AAdd( ae, "неверное значение поля SMO = " + ihuman->SMO )
      Endif
    Endif
    If fl_34 .and. !Empty( ihuman->SMO_OK )
      Select SMO
      Set Order To 1
      find ( ihuman->SMO_OK )
      If Found()
        fl_okatosmo := .t.
      Else
        AAdd( ae, "неверное значение поля SMO_OK = " + ihuman->SMO_OK )
      Endif
    Endif
    If fl_34 .and. !Empty( ihuman->SMO_NAM )
      fl_nameismo := .t.
    Endif
    If fl_34
      If !fl_okatosmo
        AAdd( ae, "не введено ОКАТО территории страхования" )
      Endif
      If !fl_nameismo
        AAdd( ae, "не введено наименование иногородней СМО" )
      Endif
    Endif
    If !Empty( ihuman->OKATOG ) .and. !import_verify_okato( ihuman->OKATOG )
      AAdd( ae, "неверное значение поля OKATOG = " + ihuman->OKATOG )
    Endif
    If !Empty( ihuman->OKATOP ) .and. !import_verify_okato( ihuman->OKATOP )
      AAdd( ae, "неверное значение поля OKATOP = " + ihuman->OKATOP )
    Endif
    If ihuman->USL_OK == 1
      //
    Elseif ihuman->USL_OK == 2
      If !Between( ihuman->DN_STAC, 1, 3 )
        AAdd( ae, "неверное значение поля DN_STAC = " + lstr( ihuman->DN_STAC ) )
      Endif
    Elseif ihuman->USL_OK == 3
      If !eq_any( ihuman->VID_AMB, 1, 11, 2, 3, 4, 5, 6, 7, 22, 40, 41 )
        AAdd( ae, "неверное значение поля VID_AMB = " + lstr( ihuman->VID_AMB ) )
      Endif
    Else
      AAdd( ae, "неверное значение поля USL_OK = " + lstr( ihuman->USL_OK ) )
    Endif
    If !Empty( ihuman->USL_OK ) .and. AScan( getv006(), {| x| x[ 2 ] == ihuman->USL_OK } ) == 0
      AAdd( ae, 'неверное значение поля USL_OK = ' + lstr( ihuman->USL_OK ) )
    Endif
    If Empty( ihuman->RSLT )
      AAdd( ae, 'не заполнен результат лечения RSLT' )
    Else
      If Int( Val( Left( lstr( ihuman->RSLT ), 1 ) ) ) != ihuman->USL_OK
        AAdd( ae, 'поле USL_OK = ' + lstr( ihuman->USL_OK ) + ' не соответствует значению поля RSLT = ' + lstr( ihuman->RSLT ) )
      Elseif AScan( getv009(), {| x| x[ 2 ] == ihuman->RSLT } ) == 0
        AAdd( ae, 'неверное значение поля RSLT = ' + lstr( ihuman->RSLT ) )
      Endif
    Endif
    If Empty( ihuman->ISHOD )
      AAdd( ae, 'не заполнен исход лечения ISHOD' )
    Else
      If Int( Val( Left( lstr( ihuman->ISHOD ), 1 ) ) ) != ihuman->USL_OK
        AAdd( ae, 'поле USL_OK = ' + lstr( ihuman->USL_OK ) + ' не соответствует значению поля ISHOD = ' + lstr( ihuman->ISHOD ) )
      Elseif AScan( getv012(), {| x| x[ 2 ] == ihuman->ISHOD } ) == 0
        AAdd( ae, 'неверное значение поля ISHOD = ' + lstr( ihuman->ISHOD ) )
      Endif
    Endif
    lkol_usl := 0
    not_otd := .f.
    // подстановка наших кодов отделений и врачей
    If f1_read_file_xml_sds( 1, "ihuman", ae, ai, ihuman->profil ) == 2
      not_otd := .t.
    Endif
    Select NA
    find ( Str( ihuman->kod, 10 ) )
    Do While ihuman->kod == na->kod .and. !Eof()
      If !Empty( na->CODE_USL )
        Select LUSLF
        find ( PadR( na->CODE_USL, 20 ) )
        If Found()
          na->name_u := luslf->name
          If luslf->onko_napr != na->MET_ISSL
            AAdd( ae, "тип медуслуги в направлении на онкологическое обследование " + AllTrim( na->CODE_USL ) + ;
              " не соответствует методу диагностического исследования" )
          Endif
        Else
          AAdd( ae, "в направлении на онкологическое обследование не найдена услуга " + AllTrim( na->CODE_USL ) )
        Endif
      Endif
      Select NA
      Skip
    Enddo
    Select IPODR
    find ( Str( ihuman->kod, 10 ) )
    Do While ihuman->kod == ipodr->kod .and. !Eof()
      If Empty( ipodr->otd_sds )
        AAdd( ae, "не заполнено отделение" )
      Endif
      If Empty( ipodr->date_1 )
        ipodr->date_1 := sys_date
        // aadd(ae, "пустая дата начала лечения")
      Endif
      If Empty( ipodr->date_2 )
        ipodr->date_2 := sys_date
        // aadd(ae, "пустая дата окончания лечения")
      Endif
      If ihuman->USL_OK == 2 .and. Empty( ipodr->KOL_PD )
        AAdd( ae, "не заполнено количество пациенто-дней (PATIENT_DAYS)" )
      Endif
      If f1_read_file_xml_sds( 2, "ipodr", ae, ai, ipodr->profil ) == 2
        not_otd := .t.
      Endif
      Select IHU
      Set Order To 2
      find ( Str( ipodr->( RecNo() ), 10 ) )
      Do While ihu->kodp == ipodr->( RecNo() ) .and. !Eof()
        If Empty( ihu->CODE_USL )
          If ihuman->USL_OK == 3 .and. eq_any( ihuman->VID_AMB, 1, 11 ) // обращение в поликлинике
            // потом определим
          Else
            otd->( dbGoto( ipodr->otd ) )
            AAdd( ai, 'в отделении "' + RTrim( otd->short_name ) + '" не введён шифр услуги от ' + date_8( ipodr->DATE_1 ) )
          Endif
        Else
          Select LUSLF
          find ( PadR( ihu->CODE_USL, 20 ) )
          If Found()
            If luslf->zf == 1
              If Empty( ihu->zf )
                AAdd( ae, "в услуге " + AllTrim( ihu->CODE_USL ) + " не проставлена зубная формула" )
              Else
                arr_zf := stverifyzf( ihu->zf, ihuman->dr, ihuman->date_1, ae, AllTrim( ihu->CODE_USL ) )
                stverifykolzf( arr_zf, ihu->kol_usl, ae, AllTrim( ihu->CODE_USL ) )
              Endif
            Elseif !Empty( luslf->par_org )
              If Empty( ihu->par_org )
                AAdd( ae, "в услуге " + AllTrim( ihu->CODE_USL ) + " не введены органы (части тела), на которых выполнена операция" )
              Else
                a1 := list2arr( ihu->par_org )
                a2 := list2arr( luslf->par_org )
                s1 := ""
                For i := 1 To Len( a2 )
                  If AScan( a1, a2[ i ] ) > 0
                    s1 += lstr( a2[ i ] ) + ", "
                  Endif
                Next
                If !Empty( s1 )
                  s1 := Left( s1, Len( s1 ) -1 )
                Endif
                If Empty( s1 ) .or. !( s1 == AllTrim( ihu->par_org ) )
                  AAdd( ae, 'в услуге ' + AllTrim( ihu->CODE_USL ) + ' некорректно введены органы (части тела) ' + AllTrim( ihu->par_org ) )
                Endif
              Endif
            Endif
          Else
            Select LUSL
            find ( PadR( ihu->CODE_USL, 10 ) )
            If !Found()
              AAdd( ae, "в справочниках ТФОМС не найдена услуга " + AllTrim( ihu->CODE_USL ) )
            Endif
          Endif
        Endif
        If !Between( ihu->DATE_IN, ihuman->date_1, ihuman->date_2 )
          AAdd( ae, "дата услуги " + AllTrim( ihu->CODE_USL ) + " (" + date_8( ihu->DATE_IN ) + ") не попадает в диапазон лечения: " + ;
            date_8( ihuman->date_1 ) + "-" + date_8( ihuman->date_2 ) )
        Endif
        ++lkol_usl
        If f1_read_file_xml_sds( 3, "ihu", ae, ai, ihu->profil ) == 2
          not_otd := .t.
        Endif
        Select IHU
        Skip
      Enddo
      Select IPODR
      Skip
    Enddo
    // добавление услуг 1.11.* и 55.1.*
    If eq_any( ihuman->USL_OK, 1, 2 ) // стационар и дневной стационар
      Select IPODR
      find ( Str( ihuman->kod, 10 ) )
      Do While ihuman->kod == ipodr->kod .and. !Eof()
        otd->( dbGoto( ipodr->otd ) )
        If ipodr->DATE_1 == ipodr->DATE_2 .and. ihuman->DATE_2 > ihuman->DATE_1
          AAdd( ai, 'дата начала и окончания лечения в отделении "' + RTrim( otd->short_name ) + ;
            '" - один и тот же день ' + date_8( ipodr->DATE_1 ) )
        Else
          If !Between( ipodr->DATE_1, ihuman->DATE_1, ihuman->DATE_2 )
            AAdd( ae, 'дата начала лечения в отделении "' + RTrim( otd->short_name ) + ;
              '" - ' + date_8( ipodr->DATE_1 ) + ' за пределами сроков лечения' )
          Endif
          If !Between( ipodr->DATE_2, ihuman->DATE_1, ihuman->DATE_2 )
            AAdd( ae, 'дата окончания лечения в отделении "' + RTrim( otd->short_name ) + ;
              '" - ' + date_8( ipodr->DATE_2 ) + ' за пределами сроков лечения' )
          Endif
          Select IHU
          Append Blank
          ihu->KOD := ihuman->kod
          ihu->KODP := ipodr->( RecNo() )
          ihu->PROFIL := ipodr->PROFIL
          ihu->otd := ipodr->otd
          ihu->otd_sds := ipodr->otd_sds
          ihu->DS := ipodr->DS
          If ihuman->USL_OK == 1 // стационар
            If ihuman->REABIL == 2
              ihu->CODE_USL := "1.11.2"
            Else
              ihu->CODE_USL := "1.11.1"
            Endif
            ihu->KOL_USL := ipodr->DATE_2 - ipodr->DATE_1
            If Empty( ihu->KOL_USL ) .and. ihuman->DATE_1 == ihuman->DATE_2
              ihu->KOL_USL := 1 // выписан в тот же день, что и поступил
            Endif
          Else
            If ihuman->REABIL == 2
              ihu->CODE_USL := "55.1.4"
            Else
              ihu->CODE_USL := "55.1." + lstr( ihuman->DN_STAC )
            Endif
            ihu->KOL_USL := ipodr->KOL_PD
          Endif
          ihu->DATE_IN := ipodr->DATE_1
          ihu->DATE_OUT := ipodr->DATE_2
          ihu->TARIF := ihu->SUMV_USL := 0
          ihu->VRACH := ipodr->VRACH
          ihu->VRACH_SDS := ipodr->VRACH_SDS
          ihu->VR_SNILS := ipodr->VR_SNILS
        Endif
        Select IPODR
        Skip
      Enddo
      If !Empty( ihuman->VID_HMP ) .and. ihuman->USL_OK == 1 // стационар
        arrV018 := getv018( ihuman->date_2 )
        arrV019 := getv019( ihuman->date_2 )

        If AScan( arrV018, {| x| x[ 1 ] == ihuman->VID_HMP } ) == 0
          AAdd( ae, 'не найден вид ВМП "' + RTrim( ihuman->VID_HMP ) + '" в справочнике V018' )
        Elseif Empty( ihuman->METOD_HMP )
          AAdd( ae, 'ВМП оказана, введён вид ВМП, но не введён метод ВМП' )
        Elseif ( i := AScan( arrV019, {| x| x[ 1 ] == ihuman->METOD_HMP } ) ) > 0
          If arrV019[ i, 4 ] == ihuman->VID_HMP
            If AScan( arrV019[ i, 3 ], {| x| Left( ihuman->ds1, Len( x ) ) == x } ) == 0
              AAdd( ae, 'основной диагноз не соответствует методу ВМП' )
            Endif
          Else
            AAdd( ae, 'метод ВМП ' + lstr( ihuman->METOD_HMP ) + ' не соответствует виду ВМП ' + ihuman->VID_HMP )
          Endif
        Else
          AAdd( ae, 'не найден метод ВМП ' + lstr( ihuman->METOD_HMP ) + ' в справочнике V019' )
        Endif
      Endif
    Endif
    If Empty( ihuman->PROFIL )
      AAdd( ae, 'не заполнен профиль' )
    Endif
    mdate_r := ihuman->dr ; m1VZROS_REB := 0 ; M1NOVOR := ihuman->novor
    mDATE_R2 := CToD( "" )
    fv_date_r( ihuman->DATE_1 )
    If eq_any( ihuman->USL_OK, 1, 2 ) // стационар и дневной стационар
      If Empty( ihuman->PROFIL_K )
        AAdd( ae, 'не заполнен профиль койки' )
      Elseif !Empty( ihuman->PROFIL )
        If Select( "PRPRK" ) == 0
          r_use( dir_exe() + "_mo_prprk", cur_dir() + "_mo_prprk", "PRPRK" )
          // index on str(profil,3) +str(profil_k,3) to (cur_dir()+sbase)
        Endif
        Select PRPRK
        find ( Str( ihuman->profil, 3 ) + Str( ihuman->profil_k, 3 ) )
        If Found()
          If !Empty( prprk->vozr )
            If m1VZROS_REB == 0
              If prprk->vozr == "Д"
                AAdd( ae, 'возраст пациента не соответствует профилю койки' )
              Endif
            Else
              If prprk->vozr == "В"
                AAdd( ae, 'возраст пациента не соответствует профилю койки' )
              Endif
            Endif
          Endif
          If !Empty( prprk->pol ) .and. !( iif( ihuman->W == 1, "М", "Ж" ) == prprk->pol )
            AAdd( ae, 'значение поля "Пол" не соответствует профилю койки' )
          Endif
        Else
          s := ""
          Select PRPRK
          find ( Str( ihuman->profil, 3 ) )
          Do While prprk->profil == ihuman->profil .and. !Eof()
            s += '"' + lstr( prprk->profil_k ) + '-' + inieditspr( A__MENUVERT, getv020(), prprk->profil_k ) + '" '
            Skip
          Enddo
          If Empty( s )
            AAdd( ae, 'профиль медицинской помощи не оплачивается в ОМС' )
          Else
            AAdd( ae, 'профиль мед.помощи не соответствует профилю койки; допустимый профиль койки: ' + s )
          Endif
        Endif
      Endif
      If emptyall( ihuman->ds1, lkol_usl )
        AAdd( ae, 'невозможно определить КСГ - нет основного диагноза и ни одной услуги' )
      Else
        // заплатка 23.11.2022 Резниченко
        If Select( 'HUMAN_2' ) < 1
          g_use ( dir_server() + 'human_2', , 'HUMAN_2' )
        Endif
        //
        Select IHU
        Set Order To 1
        arr_ksg := definition_ksg( 2 )
        sdial := 0
        If Len( arr_ksg ) == 7 ; // диализ
          .and. ValType( arr_ksg[ 7 ] ) == "N"
          sdial := arr_ksg[ 7 ] // для 2019 года
        Endif
        If Empty( arr_ksg[ 2 ] ) // если нет ошибок
          Select IHU
          Append Blank
          ihu->KOD := ihuman->kod
          ihu->PROFIL := ihuman->PROFIL
          ihu->DS := ihuman->DS1
          ihu->otd := ihuman->otd
          ihu->otd_sds := ihuman->otd_sds
          ihu->CODE_USL := arr_ksg[ 3 ]
          ihu->DATE_IN := ihuman->DATE_1
          ihu->KOL_USL := 1
          ihuman->sumv := ihu->TARIF := ihu->SUMV_USL := arr_ksg[ 4 ]
          ihu->VRACH := ihuman->VRACH
          ihu->VRACH_SDS := ihuman->VRACH_SDS
          ihu->VR_SNILS := ihuman->VR_SNILS
          If Len( arr_ksg ) > 4 .and. !Empty( arr_ksg[ 5 ] )
            ihuman->kslp := lstr( arr_ksg[ 5, 1 ] ) + ", " + lstr( arr_ksg[ 5, 2 ], 5, 2 )
            If Len( arr_ksg[ 5 ] ) >= 4
              ihuman->kslp := AllTrim( ihuman->kslp ) + ", " + lstr( arr_ksg[ 5, 3 ] ) + ", " + lstr( arr_ksg[ 5, 4 ], 5, 2 )
            Endif
          Endif
          If Len( arr_ksg ) > 5 .and. !Empty( arr_ksg[ 6 ] )
            ihuman->kiro := lstr( arr_ksg[ 6, 1 ] ) + ", " + lstr( arr_ksg[ 6, 2 ], 5, 2 )
          Endif
          // aeval(arr_ksg[1],{|x| aadd(ai,x) })
          If Empty( ihuman->VID_HMP )
            AAdd( ai, 'определена КСГ "' + arr_ksg[ 3 ] + '" с ценой ' + lstr( arr_ksg[ 4 ], 11, 2 ) + 'р.' )
          Else
            AAdd( ai, 'определена услуга ВМП "' + arr_ksg[ 3 ] + '" с ценой ' + lstr( arr_ksg[ 4 ], 11, 2 ) + 'р.' )
          Endif
        Else
          AEval( arr_ksg[ 2 ], {| x| AAdd( ae, x ) } )
        Endif
      Endif
    Elseif ihuman->USL_OK == 3 .and. eq_any( ihuman->VID_AMB, 1, 11, 2, 3, 4, 5, 6, 7, 22, 40, 41 )// поликлиника
      a_vid_amb := { ; // В теге <VID_AMB> проставляется вид амбулаторно-поликлинического случая, а именно:
      { 1, "2.78." }, ; // Обращение с лечебной целью
      { 11, "2.78." }, ; // Обращение с лечебной целью
      { 2, "2.79." }, ; // Посещение с профилактической целью
      { 22, "2.79.44", "2.79.50" }, ; // патронажное посещение на дому
      { 3, "2.80." }, ; // Посещение в неотложной форме
      { 4, "2.88.1", "2.88.147" }, ; // Разовое посещение по поводу заболевания (замена 2.88.51 на 2.88.147)
      { 40, "2.88.78", "2.88.106" }, ; // Разовое посещение по поводу заболевания с целью проведения диспансерного наблюдения первичное
      { 41, "2.88.52", "2.88.77" }, ; // Разовое посещение по поводу заболевания с целью проведения диспансерного наблюдения повторное
      { 5, "2.82." }, ; // Врачебный приём в приёмном покое стационара
      { 6, "2.81." }, ;  // Консультация
      { 7, "60." };  //
      } // исправить потом для "2.88.104" !!!!!!!
      glob_otd_dep := 0 // для поликлиники всегда
      LVZROS_REB := iif( m1VZROS_REB == 0, 0, 1 )
      v := 0
      fl := .f.
      If ( i := AScan( a_vid_amb, {| x| x[ 1 ] == ihuman->VID_AMB } ) ) > 0
        If ihuman->VID_AMB == 7 // отдельные услуги
          is_kt := is_mrt := is_uzi := is_endo := is_gisto := .f.
          ssum := 0
          Select IHU
          Set Order To 1
          find ( Str( ihuman->kod, 10 ) )
          Do While ihu->KOD == ihuman->kod .and. !Eof()
            Select T2V1
            find ( PadR( ihu->CODE_USL, 20 ) )
            If Found()
              ihu->CODE_USL := t2v1->shifr
            Endif
            If Left( ihu->CODE_USL, 3 ) == "60."
              k := Int( Val( SubStr( ihu->CODE_USL, 4, 1 ) ) )
              If k == 4
                is_kt := .t.
              Elseif k == 5
                is_mrt := .t.
              Elseif k == 6
                is_uzi := .t.
              Elseif k == 7
                is_endo := .t.
              Elseif k == 8
                is_gisto := .t.
              Endif
              fldel := .f.
              v := fcena_oms( ihu->CODE_USL, ( LVZROS_REB == 0 ), ihuman->DATE_2, @fldel )
              If !fldel
                ihu->TARIF := v
                ihu->SUMV_USL := v * ihu->KOL_USL
                ssum += ihu->SUMV_USL
              Endif
            Else
              AAdd( ae, 'не найдена услуга ' + AllTrim( ihu->CODE_USL ) + ' (' + iif( m1VZROS_REB == 0, "взрослый", "ребёнок" ) )
            Endif
            Select IHU
            Skip
          Enddo
          ihuman->sumv := ssum
          k := 0
          Select IPODR
          find ( Str( ihuman->kod, 10 ) )
          Do While ihuman->kod == ipodr->kod .and. !Eof()
            ++k
            Skip
          Enddo
          If k == 0
            AAdd( ae, 'не заполнено подразделение' )
          Elseif k > 1
            AAdd( ae, 'для поликлиники нельзя вводить более одного подразделения' )
          Else
            Select IPODR
            find ( Str( ihuman->kod, 10 ) )
            otd->( dbGoto( ipodr->otd ) )
            If !( ipodr->DATE_1 == ihuman->DATE_1 .and. ipodr->DATE_2 == ihuman->DATE_2 )
              AAdd( ai, 'дата начала и окончания лечения в отделении "' + RTrim( otd->short_name ) + ;
                '" не равны аналогичным датам в случае' )
            Endif
          Endif
          If Empty( ae ) // ошибок ещё нет?
            If Empty( ihuman->NPR_MO )
              ihuman->NPR_MO := glob_mo[ _MO_KOD_TFOMS ]
            Endif
            If Empty( ihuman->NPR_DATE )
              ihuman->NPR_DATE := ihuman->DATE_1
            Endif
            If !eq_any( ihuman->RSLT, 314 )
              ihuman->RSLT := 314
            Endif
            If !eq_any( ihuman->ISHOD, 304 )
              ihuman->ISHOD := 304
            Endif
            If Left( ihuman->ds1, 1 ) == "C" .or. Between( Left( ihuman->ds1, 3 ), "D00", "D09" ) .or. Between( Left( ihuman->ds1, 3 ), "D45", "D47" )
              // оставляем онкологический диагноз
            Elseif PadR( ihuman->ds1, 5 ) == "Z03.1"
              If ihuman->DS_ONK != 1
                AAdd( ae, 'если основной (или сопутствующий) диагноз Z03.1 "наблюдение при подозрении на злокачественную опухоль", то в поле "признак подозрения на ЗНО" должна стоять "1"' )
              Endif
            Elseif is_kt
              If !( PadR( ihuman->ds1, 5 ) == "Z01.6" )
                ihuman->ds1 := "Z01.6"
              Endif
            Elseif is_mrt .or. is_uzi .or. is_endo
              If !( PadR( ihuman->ds1, 5 ) == "Z01.8" )
                ihuman->ds1 := "Z01.8"
              Endif
            Elseif is_gisto
              AAdd( ae, 'для гистологии основной диагноз не может быть ' + RTrim( ihuman->ds1 ) + ;
                ' (кроме онкологического диагноза разрешается использовать только Z03.1)' )
            Endif
            Select IHU
            Set Order To 1
            find ( Str( ihuman->kod, 10 ) )
            Do While ihu->KOD == ihuman->kod .and. !Eof()
              ihu->ds := ihuman->ds1
              Select IHU
              Skip
            Enddo
          Endif
        Else
          If eq_any( ihuman->VID_AMB, 11 ) // ищем вторую услугу
            ku := 1 // 2
          Else // ищем первую услугу
            ku := 1
          Endif
          iu := 0
          lshifr := a_vid_amb[ i, 2 ]
          lshifr2 := iif( Len( a_vid_amb[ i ] ) == 3, a_vid_amb[ i, 3 ], "" )
          Select MOPROF
          find ( Str( LVZROS_REB, 1 ) + Str( ihuman->PROFIL, 3 ) + Left( lshifr, 5 ) )
          Do While moprof->vzros_reb == LVZROS_REB .and. moprof->profil == ihuman->PROFIL ;
              .and. Left( moprof->shifr, 5 ) == Left( lshifr, 5 ) .and. !Eof()
            If AllTrim( moprof->shifr ) == "2.78.107" .or. AllTrim( moprof->shifr ) == "2.78.106" .or. ;
                between_shifr( AllTrim( moprof->shifr ), "2.78.61", "2.78.72" ) .or. ;
                between_shifr( AllTrim( moprof->shifr ), "2.78.74", "2.78.86" ) .or. ;
                between_shifr( AllTrim( moprof->shifr ), "2.78.109", "2.78.112" )
              // отбраковываем Диспансеризацию
              // 2.78.61 ? 2.78.72, 2.78.74 ? 2.78.86, 2.78.106., 2.78.109-2.78.112
            Else
              If iif( Empty( lshifr2 ), .t., between_shifr( AllTrim( moprof->shifr ), lshifr, lshifr2 ) )
                fldel := .f.
                v := fcena_oms( moprof->shifr, ( LVZROS_REB == 0 ), ihuman->DATE_2, @fldel )
                If !fldel
                  ++iu
                  If iu == ku
                    fl := .t. ; Exit
                  Endif
                Endif
              Endif
            Endif
            Select MOPROF
            Skip
          Enddo
          If fl
            lshifr := moprof->shifr
            k := 0
            Select IPODR
            find ( Str( ihuman->kod, 10 ) )
            Do While ihuman->kod == ipodr->kod .and. !Eof()
              ++k
              Skip
            Enddo
            If k == 0
              AAdd( ae, 'не заполнено подразделение' )
            Elseif k > 1
              AAdd( ae, 'для поликлиники нельзя вводить более одного подразделения' )
            Else
              Select IPODR
              find ( Str( ihuman->kod, 10 ) )
              otd->( dbGoto( ipodr->otd ) )
              If !( ipodr->DATE_1 == ihuman->DATE_1 .and. ipodr->DATE_2 == ihuman->DATE_2 )
                AAdd( ai, 'дата начала и окончания лечения в отделении "' + RTrim( otd->short_name ) + ;
                  '" не равны аналогичным датам в случае' )
              Endif
              If !eq_any( ihuman->VID_AMB, 1, 11 ) .and. ihuman->DATE_1 < ihuman->DATE_2
                AAdd( ae, 'дата начала и окончания лечения должна быть один день' )
              Endif
              Select IHU
              Append Blank
              ihu->KOD := ihuman->kod
              ihu->KODP := ipodr->( RecNo() )
              ihu->PROFIL := ipodr->PROFIL
              ihu->otd := ipodr->otd
              ihu->otd_sds := ipodr->otd_sds
              ihu->DS := ipodr->DS
              ihu->CODE_USL := lshifr
              ihu->KOL_USL := 1
              ihu->DATE_IN := ihu->DATE_OUT := ipodr->DATE_1
              ihuman->sumv := ihu->TARIF := ihu->SUMV_USL := v
              ihu->VRACH := ipodr->VRACH
              ihu->VRACH_SDS := ipodr->VRACH_SDS
              ihu->VR_SNILS := ipodr->VR_SNILS
              ihu->prvs := ipodr->prvs
              Select IHU
              Set Order To 2
              find ( Str( ipodr->( RecNo() ), 10 ) )
              Do While ihu->kodp == ipodr->( RecNo() ) .and. !Eof()
                If Empty( ihu->CODE_USL )
                  ihu->CODE_USL := ret_shifr_2_60( ihu->profil, m1VZROS_REB )
                Endif
                Select IHU
                Skip
              Enddo
            Endif
          Elseif ihuman->PROFIL > 0
            AAdd( ae, 'не найдена соответствующая услуга ' + Left( lshifr, 5 ) + '* (' + iif( m1VZROS_REB == 0, 'взрослый', 'ребёнок' ) + ;
              ') для профиля "' + inieditspr( A__MENUVERT, getv002(), ihuman->PROFIL ) + '"' )
          Endif
        Endif
      Else
        AAdd( ae, 'некорректный вид амбулаторно-поликлинического случая ' + lstr( ihuman->VID_AMB ) )
      Endif
    Endif
    If ihuman->STAD > 0
      f_verify_tnm( 2, ihuman->STAD, ihuman->ds1, ihuman->DATE_2, ae )
      If ihuman->ds1_t == 0 .and. m1vzros_reb == 0
        If Empty( ihuman->ONK_T )
          AAdd( ae, "не заполнена стадия заболевания T" )
        Else
          f_verify_tnm( 3, ihuman->ONK_T, ihuman->ds1, ihuman->DATE_2, ae )
        Endif
        If Empty( ihuman->ONK_N )
          AAdd( ae, "не заполнена стадия заболевания N" )
        Else
          f_verify_tnm( 4, ihuman->ONK_N, ihuman->ds1, ihuman->DATE_2, ae )
        Endif
        If Empty( ihuman->ONK_M )
          AAdd( ae, "не заполнена стадия заболевания M" )
        Else
          f_verify_tnm( 5, ihuman->ONK_M, ihuman->ds1, ihuman->DATE_2, ae )
        Endif
      Endif
      Select DI
      find ( Str( ihuman->kod, 10 ) )
      Do While di->kod == ihuman->kod .and. !Eof()
        If Empty( di->DIAG_DATE )
          AAdd( ae, "не заполнена дата взятия материала для гистологии/иммуногистохимии" )
        Endif
        // di->DIAG_TIP
        // di->DIAG_CODE
        // di->DIAG_RSLT
        // di->REC_RSLT
        Select DI
        Skip
      Enddo
    Endif
    //

    pikol[ 1 ] ++
    // if glob_mo[_MO_KOD_TFOMS] == '131940' .and. not_otd
    // в ФМБА две базы, поэтому не генерируем ошибку отсутствия кода отделения в согласовании
    // else
    otd->( dbGoto( ihuman->otd ) )
    my_debug(, AllTrim( ihuman->n_zap ) + ". " + AllTrim( mfio ) + " д.р." + full_date( ihuman->dr ) )
    my_debug(, "   " + date_8( ihuman->date_1 ) + "-" + date_8( ihuman->date_2 ) + " " + otd->name )
    If Len( ae ) > 0
      StrFile( AllTrim( ihuman->n_zap ) + ". " + AllTrim( mfio ) + " д.р." + full_date( ihuman->dr ) + hb_eol(), file_error, .t. )
      StrFile( "   " + date_8( ihuman->date_1 ) + "-" + date_8( ihuman->date_2 ) + " " + otd->name + hb_eol(), file_error, .t. )
      For i := 1 To Len( ae )
        put_long_str( "-error: " + LTrim( ae[ i ] ), , 3 ) // my_debug
        put_long_str( "-error: " + LTrim( ae[ i ] ), file_error, 3 )
      Next
      pikol[ 3 ] ++
    Else
      pikol[ 2 ] ++
    Endif
    For i := 1 To Len( ai )
      put_long_str( "-info: " + ai[ i ], , 3 ) // my_debug
    Next
    // endif
    Select IHUMAN
    Skip
  Enddo
  Close databases
  rest_box( buf )

  Return .t.

// * 06.11.22 вернуть шифр услуги 2.60.*
Function ret_shifr_2_60( lprofil, lvzros_reb )

  Local lshifr

  // 2.60.1 врач
  // 2.60.2 участковый терапевт, педиатр, врач общей практики
  // 2.60.3 фельдшер
  // 2.60.4 участковый фельдшер
  // 2.60.5 не участковый терапевт, педиатр, врач общей практики
  If lprofil == 97 .and. lvzros_reb == 0 .or. lprofil == 68 .and. lvzros_reb > 0
    lshifr := "2.60.5"
  Else
    lshifr := "2.60.1"
  Endif

  Return lshifr

// 12.09.25
Function f1_read_file_xml_sds( k, lal, aerr, ainf, lprofil )

  Static aprvs
  Local i, s, lk, lprvs, ret := 0

  If k == 0
    paso := {} ; pasv := {} ; pasp := {} ; pass := {}
    Return ret
  Endif
  If !Empty( k := &lal.->PROFIL )
    If AScan( getv002(), {| x| x[ 2 ] == k } ) == 0
      If AScan( pasp, k ) == 0
        AAdd( pasp, k )
        AAdd( aerr, 'Указано неверное значение поля PROFIL = ' + lstr( k ) )
      Endif
      ret := 1
    Endif
  Endif
  If !Empty( k := &lal.->otd_sds )
    If ( i := AScan( pr_otd, {| x| x[ 1 ] == k } ) ) > 0
      &lal.->otd := pr_otd[ i, 2 ]
    Else
      If AScan( paso, k ) == 0
        AAdd( paso, k )
        AAdd( aerr, "В справочнике отделений не согласовано отделение с кодом " + lstr( k ) )
      Endif
      ret := 2
    Endif
  Endif
  If !Empty( k := &lal.->vrach_sds )
    Select PERS
    Set Order To 1
    find ( Str( k, 5 ) )
    If Found()
      &lal.->vrach := pers->kod
    Else
      If AScan( pasv, k ) == 0
        AAdd( pasv, k )
        AAdd( aerr, "В справочнике персонала не обнаружен сотрудник с табельным номером " + lstr( k ) )
      Endif
      If Empty( ret )
        ret := 3
      Endif
    Endif
  Elseif !Empty( k := &lal.->vr_snils ) .and. Empty( &lal.->prvs )
    Default lprofil To 0
    lk := 0
    Select PERS
    Set Order To 2
    find ( PadR( k, 11 ) )
    Do While k == pers->snils .and. !Eof()
      If Empty( lk )
        lk := pers->kod // первый найденный запоминаем
      Endif
      If FieldPos( "profil" ) > 0 .and. lprofil == pers->profil // согласован профиль
        lk := pers->kod
        Exit
      Endif
      Skip
    Enddo
    If lk > 0
      &lal.->vrach := lk
    Else
      If AScan( pass, {| x| x[ 1 ] == k .and. x[ 2 ] == 0 } ) == 0
        AAdd( pass, { k, 0 } )
        s := Space( 80 )
        If !val_snils( k, 2, @s )
//          AAdd( aerr, 'VRACH_SNILS="' + Transform( k, picture_pf ) + '"-' + s )
          AAdd( aerr, 'VRACH_SNILS="' + Transform_SNILS( k ) + '"-' + s )
        Endif
        AAdd( aerr, "В справочнике персонала не обнаружен сотрудник со СНИЛС " + Transform_SNILS( k ) )
      Endif
      If Empty( ret )
        ret := 3
      Endif
    Endif
  Elseif !Empty( k := &lal.->vr_snils ) .and. !Empty( &lal.->prvs )
    Default aprvs To ret_arr_new_olds_prvs() // массив соответствий специальности V015 специальностям V0004
    lprvs := &lal.->prvs
    lk := 0
    Select PERS
    Set Order To 2
    find ( PadR( k, 11 ) + Str( lprvs, 4 ) ) // ищем по коду новой специальности
    If Found()
      lk := pers->kod
    Elseif ( j := AScan( aprvs, {| x| x[ 1 ] == lprvs } ) ) > 0
      Set Order To 3
      For i := 1 To Len( aprvs[ j, 2 ] )
        find ( PadR( k, 11 ) + Str( aprvs[ j, 2, i ], 9 ) )  // ищем по коду старой специальности
        If Found()
          lk := pers->kod
          Exit
        Endif
      Next
    Endif
    If lk > 0
      &lal.->vrach := lk
    Else
      If AScan( pass, {| x| x[ 1 ] == k .and. x[ 2 ] == lprvs } ) == 0
        AAdd( pass, { k, lprvs } )
        s := Space( 80 )
        If !val_snils( k, 2, @s )
//          AAdd( aerr, 'VRACH_SNILS="' + Transform( k, picture_pf ) + '"-' + s )
          AAdd( aerr, 'VRACH_SNILS="' + Transform_SNILS( k ) + '"-' + s )
        Endif
//        AAdd( aerr, 'В справочнике персонала не обнаружен сотрудник со СНИЛС ' + Transform( k, picture_pf ) + ;
        AAdd( aerr, 'В справочнике персонала не обнаружен сотрудник со СНИЛС ' + Transform_SNILS( k ) + ;
          ' и специальностью "' + inieditspr( A__MENUVERT, getv015(), lprvs ) + '"' )
      Endif
      If Empty( ret )
        ret := 3
      Endif
    Endif
  Endif

  Return ret

// 19.10.17
Function write_file_xml_sds( n_file, path2_sds )

  Local i, fl := .f.
  Local name_file := strippath( n_file )  // имя файла без пути
  Private cFileProtokol := cur_dir() + "protokol.txt"

  Delete File ( cur_dir() + cFileProtokol )
  If mo_lock_task( X_OMS )
    fl := f1_write_file_xml_sds( n_file )
    mo_unlock_task( X_OMS )
  Endif
  If hb_FileExists( cur_dir() + cFileProtokol )
    viewtext( devide_into_pages( cur_dir() + cFileProtokol, 60, 80 ), ,, , .t., ,, 2 )
  Endif
  If fl
    For i := 1 To 3
      Copy File ( n_file ) to ( path2_sds + name_file )
      If hb_FileExists( path2_sds + name_file )
        Delete File ( n_file )
        Exit
      Endif
    Next i
  Endif

  Return Nil

// 04.02.22
Function f1_write_file_xml_sds( n_file )

  Local buf := save_maxrow(), aerr := {}, arr, fl, i, j, t2, s, s1, afio[ 3 ], adiag_talon[ 16 ]

  mywait( "Импорт XML-файла ..." )
  StrFile( Center( "Протокол импорта файла", 80 ) + hb_eol(), "ttt.ttt" )
  StrFile( Center( n_file, 80 ) + hb_eol() + hb_eol(), "ttt.ttt", .t. )
  glob_podr := "" ; glob_otd_dep := 0
  Private is := 0, is1 := 0, iz := 0, isp1 := 0, isp2 := 0  // ,;
  // _arr_sh := ret_arr_shema(1), _arr_mt := ret_arr_shema(2), _arr_fr := ret_arr_shema(3)
  use_base( "lusl" )
  use_base( "luslc" )
  use_base( "luslf" )
  use_base( "mo_su" )
  use_base( "uslugi" )
  r_use( dir_server() + "uslugi1", { dir_server() + "uslugi1", ;
    dir_server() + "uslugi1s" }, "USL1" )
  g_use( dir_server() + "mo_onkna", dir_server() + "mo_onkna", "NAPR" ) // онконаправления
  g_use( dir_server() + "mo_onkco", dir_server() + "mo_onkco", "CO" )
  g_use( dir_server() + "mo_onksl", dir_server() + "mo_onksl", "SL" )
  g_use( dir_server() + "mo_onkdi", dir_server() + "mo_onkdi", "DIAG" ) // Диагностический блок
  g_use( dir_server() + "mo_onkpr", dir_server() + "mo_onkpr", "PR" ) // Сведения об имеющихся противопоказаниях
  g_use( dir_server() + "mo_onkus", dir_server() + "mo_onkus", "US" )
  g_use( dir_server() + "mo_onkle", dir_server() + "mo_onkle", "LE" )
  use_base( "mo_hu", , .t. )
  r_use( dir_server() + "mo_otd", , "OTD" )
  use_base( "human_u", , .t. )
  use_base( "human", , .t. )
  Set Relation To
  Select HUMAN_2
  Index On Str( pn3, 10 ) to ( cur_dir() + "tmp_human2" )
  g_use( dir_server() + "mo_kfio", , "KFIO" )
  Index On Str( kod, 7 ) to ( cur_dir() + "tmp_kfio" )
  g_use( dir_server() + "mo_kismo", , "KSN" )
  Index On Str( kod, 7 ) to ( cur_dir() + "tmpkismo" )
  g_use( dir_server() + "mo_hismo", , "HSN" )
  Index On Str( kod, 7 ) to ( cur_dir() + "tmphismo" )
  use_base( "kartotek" )
  Use ( cur_dir() + "_sluch_na" ) index ( cur_dir() + "tmp_na" ) New Alias NA
  Use ( cur_dir() + "_sluch_di" ) index ( cur_dir() + "tmp_di" ) New Alias TDIAG
  Use ( cur_dir() + "_sluch_pr" ) index ( cur_dir() + "tmp_pr" ) New Alias TPR
  Use ( cur_dir() + "_sluch_us" ) index ( cur_dir() + "tmp_us" ) New Alias TMPOU
  Use ( cur_dir() + "_sluch_le" ) index ( cur_dir() + "tmp_le" ) New Alias TMPLE
  Use ( cur_dir() + "_sluch_p" ) index ( cur_dir() + "tmp_ip" ) New Alias IPODR
  Use ( cur_dir() + "_sluch_u" ) index ( cur_dir() + "tmp_ihu" ), ( cur_dir() + "tmp_ihup" ) New Alias IHU
  Use ( cur_dir() + "_sluch" ) New Alias IHUMAN
  Go Top
  Do While !Eof()
    ++is
    If ihuman->otd > 0 // согласован код отделения - можно загружать
      ++is1 ; fl := .t.
      afio[ 1 ] := ihuman->fam
      afio[ 2 ] := ihuman->im
      afio[ 3 ] := ihuman->ot
      mfio := AllTrim( afio[ 1 ] ) + " " + AllTrim( afio[ 2 ] ) + " " + AllTrim( afio[ 3 ] )
      If ihuman->id_sds > 0
        Select HUMAN_2
        Set Order To 1
        find ( Str( ihuman->id_sds, 10 ) )
        If Found()
          ++isp1 ; fl := .f. // т.е. данный случай заносили через данную функцию
            s1 := "РАНЕЕ ЗАПИСАН"
        Endif
        Select HUMAN_2
        Set Order To 0
      Endif
      If fl
        lkod_k := 0 ; mfio := PadR( mfio, 50 )
        Select KART
        Set Order To 2
        find ( "1" + Upper( mfio ) + DToS( ihuman->dr ) )
        If Found()
          lkod_k := kart->kod
          Select HUMAN
          Set Order To 2
          find ( Str( lkod_k, 7 ) )
          Do While lkod_k == human->kod_k .and. !Eof()
            Select HUMAN_
            Goto ( human->kod )
            If human->k_data == ihuman->DATE_2 .and. human_->USL_OK == ihuman->USL_OK .and. human_->PROFIL == ihuman->PROFIL
              ++isp2 ; fl := .f. // т.е. данный случай заносили ручками
              Select HUMAN_2
              Goto ( human->kod )
              If human_2->PN3 > 0
                s1 := "УЖЕ ДОБАВЛЕН в данном XML-файле (ID=" + lstr( human_2->PN3 ) + ")"
              Else
                s1 := "РАНЕЕ ДОБАВЛЕН ОПЕРАТОРОМ"
              Endif
              Exit
            Endif
            Select HUMAN
            Skip
          Enddo
        Endif
      Endif
      If fl
        ++iz
        Select KART
        Set Order To 1
        If Empty( lkod_k )
          add1rec( 7 )
          lkod_k := kart->kod := RecNo()
          kart->FIO    := mfio
          kart->DATE_R := ihuman->dr
        Else
          Goto ( lkod_k )
          g_rlock( forever )
        Endif
        mdate_r := kart->DATE_R ; m1VZROS_REB := M1NOVOR := 0
        fv_date_r()
        kart->pol       := iif( ihuman->W == 1, "М", "Ж" )
        kart->VZROS_REB := m1VZROS_REB
        kart->POLIS     := make_polis( ihuman->spolis, ihuman->npolis )
        kart->snils     := ihuman->snils
        If twowordfamimot( afio[ 1 ] ) .or. twowordfamimot( afio[ 2 ] ) .or. twowordfamimot( afio[ 3 ] )
          kart->MEST_INOG := 9
        Else
          kart->MEST_INOG := 0
        Endif
        Select KART2
        Do While kart2->( LastRec() ) < lkod_k
          Append Blank
        Enddo
        Goto ( lkod_k )
        g_rlock( forever )
        //
        Select KART_
        Do While kart_->( LastRec() ) < lkod_k
          Append Blank
        Enddo
        Goto ( lkod_k )
        g_rlock( forever )
        //
        kart_->VPOLIS := ihuman->vpolis
        kart_->SPOLIS := ihuman->SPOLIS
        kart_->NPOLIS := ihuman->NPOLIS
        kart_->SMO    := ihuman->smo
        kart_->vid_ud := ihuman->DOCTYPE
        kart_->ser_ud := ihuman->DOCSER
        kart_->nom_ud := ihuman->DOCNUM
        kart_->mesto_r := ihuman->MR
        kart_->okatog := ihuman->OKATOG
        kart_->okatop := ihuman->OKATOP
        //
        Select KFIO
        find ( Str( lkod_k, 7 ) )
        If Found()
          If kart->MEST_INOG == 9
            g_rlock( forever )
            kfio->FAM := afio[ 1 ]
            kfio->IM  := afio[ 2 ]
            kfio->OT  := afio[ 3 ]
          Else
            deleterec( .t. )
          Endif
        Else
          If kart->MEST_INOG == 9
            addrec( 7 )
            kfio->kod := lkod_k
            kfio->FAM := afio[ 1 ]
            kfio->IM  := afio[ 2 ]
            kfio->OT  := afio[ 3 ]
          Endif
        Endif
        fl_nameismo := .f.
        If Int( Val( ihuman->SMO ) ) == 34
          fl_nameismo := .t.
          kart_->KVARTAL_D := ihuman->SMO_OK // ОКАТО субъекта РФ территории страхования
        Endif
        Select KSN
        find ( Str( lkod_k, 7 ) )
        If Found()
          If fl_nameismo
            g_rlock( forever )
            ksn->smo_name := ihuman->SMO_NAM
          Else
            deleterec( .t. )
          Endif
        Else
          If fl_nameismo
            addrec( 7 )
            ksn->kod := lkod_k
            ksn->smo_name := ihuman->SMO_NAM
          Endif
        Endif
        // UnLock
        //
        M1NOVOR := ihuman->NOVOR ; mDATE_R2 := ihuman->REB_DR
        fv_date_r( ihuman->DATE_1 )
        Select HUMAN
        Set Order To 1
        add1rec( 7, .t. )
        mkod := human->kod := RecNo()
        Select HUMAN_
        Do While human_->( LastRec() ) < mkod
          Append Blank
        Enddo
        Goto ( mkod )
        //
        Select HUMAN_2
        Do While human_2->( LastRec() ) < mkod
          Append Blank
        Enddo
        Goto ( mkod )
        //
        human->kod_k      := lkod_k
        human->TIP_H      := B_STANDART
        human->FIO        := kart->FIO          // Ф.И.О. больного
        human->POL        := kart->POL          // пол
        human->DATE_R     := kart->DATE_R       // дата рождения больного
        human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
        human->KOD_DIAG   := ihuman->ds1
        s := Right( ihuman->ds1, 1 )
        For i := 1 To 7
          pole := "ihuman->ds2" + iif( i == 1, "", "_" + lstr( i ) )
          s += Right( &pole, 1 )
          If !Empty( &pole )
            poleh := { "KOD_DIAG2", "KOD_DIAG3", "KOD_DIAG4", "SOPUT_B1", "SOPUT_B2", "SOPUT_B3", "SOPUT_B4" }[ i ]
            poleh := "human->" + poleh
            &poleh := &pole
          Endif
        Next
        human->diag_plus  := s
        human->KOMU       := 0
        human_->SMO       := ihuman->smo
        human->POLIS      := make_polis( ihuman->spolis, ihuman->npolis )
        human->OTD        := ihuman->otd
        otd->( dbGoto( ihuman->otd ) )
        human->LPU        := otd->kod_lpu
        human->UCH_DOC    := ihuman->NHISTORY
        human->N_DATA     := ihuman->DATE_1
        human->K_DATA     := ihuman->DATE_2
        human->CENA := human->CENA_1 := ihuman->SUMV
        human->OBRASHEN := iif( ihuman->DS_ONK == 1, '1', " " )

        // заполним для онкологии
        Private _arr_sh := ret_arr_shema( 1, ihuman->DATE_2 ), _arr_mt := ret_arr_shema( 2, ihuman->DATE_2 ), _arr_fr := ret_arr_shema( 3, ihuman->DATE_2 )

        AFill( adiag_talon, 0 )
        If ihuman->c_zab == 3
          adiag_talon[ 1 ] := 2
        Elseif eq_any( ihuman->c_zab, 1, 2 )
          adiag_talon[ 1 ] := 1
        Endif
        If ihuman->dn == 1
          adiag_talon[ 2 ] := 1
        Elseif ihuman->dn == 2
          adiag_talon[ 2 ] := 2
        Elseif eq_any( ihuman->dn, 4, 6 )
          adiag_talon[ 2 ] := 3
        Endif
        s := "" ; AEval( adiag_talon, {| x| s += Str( x, 1 ) } )
        human_->DISPANS   := s
        human_->VPOLIS    := ihuman->vpolis
        human_->SPOLIS    := ihuman->SPOLIS
        human_->NPOLIS    := ihuman->NPOLIS
        human_->OKATO     := ""
        If ihuman->novor == 0
          human_->NOVOR   := 0
          human_->DATE_R2 := CToD( "" )
          human_->POL2    := ""
        Else
          human_->NOVOR   := ihuman->REB_NUMBER
          human_->DATE_R2 := ihuman->REB_DR
          human_->POL2    := iif( ihuman->REB_POL == 1, "М", "Ж" )
        Endif
        human_->USL_OK    := ihuman->USL_OK
        human_->VIDPOM    := 1// ihuman->VIDPOM
        human_->PROFIL    := ihuman->PROFIL
        human_->NPR_MO    := ihuman->NPR_MO
        v := 1
        If eq_any( ihuman->USL_OK, 1, 2 )
          v := 1
          If eq_any( ihuman->for_pom, 1, 3 )
            v := iif( ihuman->for_pom == 1, 2, 1 )
          Endif
          human_->FORMA14 := Str( v - 1, 1 ) + "000"
        Elseif ihuman->USL_OK == 4
          If eq_any( ihuman->for_pom, 1, 2 )
            v := iif( ihuman->for_pom == 1, 2, 1 )
          Endif
          human_->FORMA14 := Str( v - 1, 1 ) + "000"
        Endif
        human_->KOD_DIAG0 := ihuman->ds0
        human_->RSLT_NEW  := ihuman->rslt
        human_->ISHOD_NEW := ihuman->ishod
        human_->VRACH     := ihuman->vrach
        human_->OPLATA    := 0
        human_->ST_VERIFY := 0 // ещё не проверен
        human_->ID_PAC    := mo_guid( 1, human_->( RecNo() ) )
        human_->ID_C      := mo_guid( 2, human_->( RecNo() ) )
        human_->SUMP      := 0
        human_->OPLATA    := 0
        human_->SANK_MEK  := 0
        human_->SANK_MEE  := 0
        human_->SANK_EKMP := 0
        human_->REESTR    := 0
        human_->REES_ZAP  := 0
        human->schet      := 0
        human_->SCHET_ZAP := 0
        human->kod_p   := Chr( 0 )
        human->date_e  := c4sys_date
        If fl_nameismo
          human_->OKATO := ihuman->SMO_OK // ОКАТО субъекта РФ территории страхования
        Endif
        For i := 1 To 3
          pole := "ihuman->ds3" + iif( i == 1, "", "_" + lstr( i ) )
          If !Empty( &pole )
            poleh := "human_2->osl" + lstr( i )
            &poleh := &pole
          Endif
        Next
        put_0_human_2()
        human_2->PN6 := ihuman->PN6
        If !Empty( ihuman->VID_HMP )
          human_2->VMP := 1
          human_2->VIDVMP := ihuman->VID_HMP
          human_2->METVMP := ihuman->METOD_HMP
        Endif
        human_2->NPR_DATE := ihuman->NPR_DATE
        human_2->p_per  := iif( eq_any( ihuman->USL_OK, 1, 2 ) .and. Between( ihuman->p_per, 1, 4 ), ihuman->p_per, 0 )
        human_2->PROFIL_K := ihuman->PROFIL_K
        If eq_any( human_->usl_ok, 1, 2 ) .and. human_->profil == 158 // реабилитация в стационаре и дневном стационаре
          human_2->PN1 := 1 // без наличия системы кохлеарной имплантации у пациента
        Endif
        human_2->pc1 := ihuman->kslp
        human_2->pc2 := ihuman->kiro
        human_2->pc3 := ihuman->AD_CR
        human_2->PN3 := ihuman->id_sds // ключевое поле !!!
        Select HSN
        find ( Str( mkod, 7 ) )
        If Found()
          If fl_nameismo
            hsn->smo_name := ihuman->SMO_NAM
          Else
            deleterec( .t. )
          Endif
        Else
          If fl_nameismo
            addrec( 7 )
            hsn->kod := mkod
            hsn->smo_name := ihuman->SMO_NAM
          Endif
        Endif
        ihuman->REC_HUMAN := mkod
        // UnLock
        Select IHU
        find ( Str( ihuman->kod, 10 ) )
        Do While ihu->kod == ihuman->kod .and. !Eof()
          kod_usl := kod_uslf := 0
          If Len( AllTrim( ihu->CODE_USL ) ) > 9
            kod_uslf := append_shifr_mo_su( ihu->CODE_USL, .f. )
            If !Empty( kod_uslf )
              Select MOHU
              add1rec( 7, .t. )
              mohu->kod     := human->kod
              mohu->kod_vr  := ihu->vrach
              // mohu->kod_as  := lassis
              mohu->u_kod   := kod_uslf
              mohu->u_cena  := 0// ihu->tarif
              mohu->date_u  := dtoc4( ihu->DATE_IN )
              mohu->date_u2 := dtoc4( ihu->DATE_OUT )
              mohu->otd     := ihu->otd
              mohu->kol_1   := ihu->KOL_USL
              mohu->stoim_1 := 0// ihu->SUMV_USL
              mohu->ID_U    := mo_guid( 4, mohu->( RecNo() ) )
              mohu->PROFIL  := ihu->PROFIL
              // mohu->PRVS    := ihu->PRVS
              mohu->kod_diag := ihu->ds
              If !Empty( ihu->zf )
                mohu->ZF := ihu->zf
              Elseif !Empty( ihu->par_org )
                mohu->ZF := ihu->par_org
              Endif
            Endif
          Endif
          If Empty( kod_uslf )
            Select USL
            Set Order To 2
            find ( PadR( ihu->CODE_USL, 10 ) )
            If Found()
              kod_usl := usl->kod
            Else
              v1 := v2 := 0 ; mname := ""
              Select LUSL
              find ( PadR( ihu->CODE_USL, 10 ) )
              If Found()
                mname := lusl->name
                v1 := fcena_oms( lusl->shifr, .t., sys_date )
                v2 := fcena_oms( lusl->shifr, .f., sys_date )
              Endif
              Select USL
              Set Order To 1
              find ( Str( -1, 4 ) )
              If Found()
                g_rlock( forever )
              Else
                addrec( 4 )
              Endif
              kod_usl := usl->kod := RecNo()
              usl->name := mname
              usl->shifr := ihu->CODE_USL
              usl->PROFIL := ihu->PROFIL
              usl->cena   := v1
              usl->cena_d := v2
              // UnLock
            Endif
            //
            Select HU
            add1rec( 7, .t. )
            hu->kod     := human->kod
            hu->kod_vr  := ihu->vrach
            // hu->kod_as  := lassis
            hu->u_koef  := 1
            hu->u_kod   := kod_usl
          /*if ihu->(fieldpos("dom")) > 0 ;
                          .and. ihu->(fieldtype("dom")) == "N" ;
                          .and. eq_any(ihu->dom,1,2)
            hu->KOL_RCP := -ihu->dom
          endif*/
            hu->u_cena  := ihu->tarif
            hu->is_edit := 0
            hu->date_u  := dtoc4( ihu->DATE_IN )
            hu->otd     := ihu->otd
            hu->kol := hu->kol_1 := ihu->KOL_USL
            hu->stoim := hu->stoim_1 := ihu->SUMV_USL
            Select HU_
            Do While hu_->( LastRec() ) < hu->( RecNo() )
              Append Blank
            Enddo
            Goto ( hu->( RecNo() ) )
            hu_->date_u2 := dtoc4( ihu->DATE_OUT )
            hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
            hu_->PROFIL := ihu->PROFIL
            // hu_->PRVS   := ihu->PRVS
            hu_->kod_diag := ihu->ds
          Endif
          Select IHU
          Skip
        Enddo
        Select NA
        find ( Str( ihuman->kod, 10 ) )
        Do While na->kod == ihuman->kod .and. !Eof()
          If !emptyany( na->NAPR_DATE, na->NAPR_V )
            If !Empty( na->CODE_USL ) // добавляем в свой справочник федеральную услугу
              na->U_KOD := append_shifr_mo_su( na->CODE_USL, .f. )
            Endif
            Select NAPR
            addrec( 7 )
            napr->kod := mkod
            napr->NAPR_DATE := na->NAPR_DATE
            napr->NAPR_MO := na->NAPR_MO
            napr->NAPR_V := na->NAPR_V
            napr->MET_ISSL := iif( na->NAPR_V == 3, na->MET_ISSL, 0 )
            napr->U_KOD := iif( na->NAPR_V == 3, na->U_KOD, 0 )
          Endif
          Select NA
          Skip
        Enddo
        If ihuman->PR_CONS > 0
          Select CO
          addrec( 7 )
          co->kod := mkod
          co->PR_CONS := ihuman->PR_CONS
          co->DT_CONS := ihuman->DT_CONS
        Endif
        If !emptyall( ihuman->DS1_T, ihuman->STAD, ihuman->ONK_T, ihuman->B_DIAG )
          Select SL
          addrec( 7 )
          sl->kod := mkod
          sl->DS1_T := ihuman->DS1_T
          sl->STAD := ihuman->STAD
          sl->ONK_T := ihuman->ONK_T
          sl->ONK_N := ihuman->ONK_N
          sl->ONK_M := ihuman->ONK_M
          sl->MTSTZ := ihuman->MTSTZ
          sl->sod := ihuman->sod
          sl->k_fr := ihuman->k_fr
          If sl->k_fr > 0 .and. ( i := AScan( _arr_fr, {| x| Between( sl->k_fr, x[ 3 ], x[ 4 ] ) } ) ) > 0
            sl->crit2 := _arr_fr[ i, 2 ]
          Endif
          sl->is_err := ihuman->is_err
          sl->WEI := ihuman->WEI
          sl->HEI := ihuman->HEI
          sl->BSA := ihuman->BSA
          //
          fl := .f.
          Select TDIAG
          find ( Str( ihuman->kod, 10 ) )
          Do While tdiag->kod == ihuman->kod .and. !Eof()
            fl := .t.
            Select DIAG
            addrec( 7 )
            diag->kod := mkod
            diag->DIAG_DATE := tdiag->DIAG_DATE
            diag->DIAG_TIP  := tdiag->DIAG_TIP
            diag->DIAG_CODE := tdiag->DIAG_CODE
            diag->DIAG_RSLT := tdiag->DIAG_RSLT
            diag->REC_RSLT  := tdiag->REC_RSLT
            If diag->REC_RSLT == 1
              sl->b_diag := 98
            Endif
            Select TDIAG
            Skip
          Enddo
          If Empty( sl->b_diag )
            sl->b_diag := iif( fl, 97, 99 )
          Endif
          Select TPR
          find ( Str( ihuman->kod, 10 ) )
          Do While tpr->kod == ihuman->kod .and. !Eof()
            Select PR
            addrec( 7 )
            pr->kod := mkod
            pr->PROT := tpr->PROT
            pr->D_PROT := tpr->D_PROT
            Select TPR
            Skip
          Enddo
          Select TMPOU
          find ( Str( ihuman->kod, 10 ) )
          Do While tmpou->kod == ihuman->kod .and. !Eof()
            Select US
            addrec( 7 )
            us->kod := mkod
            us->USL_TIP   := tmpou->USL_TIP
            us->HIR_TIP   := tmpou->HIR_TIP
            us->LEK_TIP_V := tmpou->LEK_TIP_V
            us->LEK_TIP_L := tmpou->LEK_TIP_L
            us->LUCH_TIP  := tmpou->LUCH_TIP
            us->PPTR      := tmpou->PPTR
            Select TMPOU
            Skip
          Enddo
          Select TMPLE
          find ( Str( ihuman->kod, 10 ) )
          Do While tmple->kod == ihuman->kod .and. !Eof()
            Select LE
            addrec( 7 )
            le->kod := mkod
            le->REGNUM   := tmple->REGNUM
            le->CODE_SH  := tmple->CODE_SH
            le->DATE_INJ := tmple->DATE_INJ
            sl->crit := tmple->CODE_SH
            human_2->pc3 := "" // в этом случае очистим доп.критерий
            Select TMPLE
            Skip
          Enddo
        Endif
        s1 := "ЗАГРУЖЕН"
        //
        @ MaxRow(), 0 Say "случаев " + lstr( is1 ) Color "G+/R*"
        @ Row(), Col() Say "/" Color "W/R*"
        @ Row(), Col() Say "загружено " + lstr( iz ) Color "GR+/R*"
        If iz % 100 == 0
          dbUnlockAll()
          dbCommitAll()
        Endif
      Endif
      otd->( dbGoto( ihuman->otd ) )
      my_debug(, AllTrim( ihuman->n_zap ) + ". " + AllTrim( mfio ) + " д.р." + full_date( ihuman->dr ) )
      my_debug(, "   " + date_8( ihuman->date_1 ) + "-" + date_8( ihuman->date_2 ) + " " + otd->name + "  " + s1 )
    Endif
    Select IHUMAN
    Skip
  Enddo
  Close databases
  rest_box( buf )
  t2 := Seconds() - t1
  arr := { 'Файл "' + AllTrim( n_file ) + '" импортирован.', ;
    "Время работы - " + SecToTime( t2 ) + "." }
  AAdd( arr, "Количество случаев в файле " + lstr( is ) + iif( is == is1, "", ", случаев для загрузки " + lstr( is1 ) ) )
  s := ""
  If isp1 > 0
    s := "ранее загружено случаев " + lstr( isp1 )
  Endif
  If isp2 > 0
    s += iif( Empty( s ), "", ", " ) + "ранее добавлено случаев " + lstr( isp2 )
  Endif
  If !Empty( s )
    AAdd( arr, "(" + s + ")" )
  Endif
  AAdd( arr, "Загружено случаев " + lstr( iz ) )
  n_message( arr, , "GR+/R", "W+/R", ,, "G+/R" )
  //
  viewtext( devide_into_pages( "ttt.ttt", 60, 80 ), ,, , .t., ,, 2 )

  Return .t.

// 28.12.21
Function f_get_file_xml_sds( /*@*/path2_sds)

  Static ini_file := "_manager", ini_group := "Read_Write"
  Local path1_sds, name_zip, ar

  If !is_obmen_sds()
    Return Nil
  Endif
  If ! hb_user_curUser:isadmin()
    func_error( 4, err_admin )
    Return Nil
  Endif
  ar := getinisect( tmp_ini, "RAB_MESTO" )
  path1_sds := AllTrim( a2default( ar, "path1_sds" ) )
  path2_sds := AllTrim( a2default( ar, "path2_sds" ) )
  If Empty( path1_sds )
    func_error( 4, "Не настроен каталог для файлов обмена с программой Smart Delta Systems!" )
    Return Nil
  Else
    If Empty( path2_sds )
      path1_sds := NIL
      func_error( 4, "Не настроен каталог для обработанных файлов Smart Delta Systems!" )
      Return Nil
    Endif
    If Right( path1_sds, 1 ) != hb_ps()
      path1_sds += hb_ps()
    Endif
    If Right( path2_sds, 1 ) != hb_ps()
      path2_sds += hb_ps()
    Endif
    If Upper( path1_sds ) == Upper( path2_sds )
      path1_sds := NIL
      func_error( 4, "Два раза выбран тот же каталог для файлов Smart Delta Systems. Недопустимо!" )
      Return Nil
    Endif
    Private p_var_manager := "Read_From_SDS"
    setinivar( ini_file, { { ini_group, p_var_manager, path1_sds } } )
    name_zip := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 1, ,, , "*.xml" )
  Endif

  Return iif( Empty( name_zip ), NIL, name_zip )

//

// 25.03.16 Согласование кодов отделений с кодами из программы Smart Delta Systems
Function sds_kod_sogl_otd()

  Private t_arr := Array( BR_LEN ), s_msg, bc, n, c_plus, buf := save_maxrow()

  mywait()
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := "Редактирование кодов согласования отделений из программы SDS"
  t_arr[ BR_TITUL_COLOR ] := "BG+/GR"
  t_arr[ BR_ARR_BROWSE ] := { "═", "░", "═", "N/BG,W+/N,B/BG,BG+/B", .t. }
#ifdef NET
  t_arr[ BR_SEMAPHORE ] := t_arr[ BR_TITUL ]
#endif
  bc := {|| iif( emptyall( otd->kod_sogl, otd->some_sogl ), { 3, 4 }, { 1, 2 } ) }
  t_arr[ BR_COLUMN ] := { ;
    { " Наименование учреждения", {|| uch->name }, bc }, ;
    { " Наименование отделения",  {|| otd->name }, bc }, ;
    { "Код согласования", {|| PadR( iif( Empty( otd->kod_sogl ), otd->some_sogl, put_val( otd->kod_sogl, 10 ) ), 16 ) }, bc };
    }
  s_msg := "^<Esc>^ - выход;  ^<Enter>^ - редактирование кода согласования"
  t_arr[ BR_STAT_MSG ] := {|| status_key( s_msg ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f1sds_kod_sogl_otd( nk, ob, 'edit' ) }
  r_use( dir_server() + "mo_uch", , "UCH" )
  g_use( dir_server() + "mo_otd", , "OTD" )
  Set Relation To kod_lpu into UCH
  Index On Upper( uch->name ) + Str( kod_lpu, 3 ) + Upper( name ) + Str( kod, 3 ) to ( cur_dir() + "tmp_otd" )
  rest_box( buf )
  Go Top
  If !Eof()
    edit_browse( t_arr )
  Endif
  Close databases

  Return Nil

// 05.06.17
Function f1sds_kod_sogl_otd( nKey, oBrow, cregim )

  Local ret := -1, i, s := "", buf, tmp_color := SetColor()

  Do Case
  Case cregim == "edit"
    Do Case
    Case nKey == K_ENTER
      Private mkod_sogl := otd->kod_sogl, msome_sogl := otd->some_sogl, gl_area := { 1, 0, 23, 79, 0 }
      buf := box_shadow( 15, 0, 20, 77, color8 )
      tmp_color := SetColor( cDataCGet )
      @ 16, 2 Say "Наименование учреждения" Get uch->name When .f.
      @ 17, 2 Say "Наименование отделения" Get otd->name When .f.
      @ 18, 2 Say "Код согласования/один к одному" Get mkod_sogl When Empty( msome_sogl )
      @ 19, 2 Say "Код согласования/один ко многим/через запятую" Get msome_sogl Pict "@S29" ;
        When Empty( mkod_sogl )
      myread()
      If LastKey() != K_ESC
        For i := 1 To Len( msome_sogl )
          If SubStr( msome_sogl, i, 1 ) $ ",0123456789"
            s += SubStr( msome_sogl, i, 1 )
          Endif
        Next
        g_rlock( forever )
        Replace kod_sogl With mkod_sogl, some_sogl With s
        Commit
        Unlock
        oBrow:down()
        ret := 0
      Endif
      SetColor( tmp_color )
      rest_box( buf )
    Otherwise
      Keyboard ""
    Endcase
  Endcase

  Return ret

// 

// обмен информацией с программой Smart Delta Systems
Function is_obmen_sds()
  Return .t. // substr(glob_mo[_MO_PROD],X_RISZ,1) == '1'

// 21.09.16 ф-ия для обмена информацией с программой Smart Delta Systems
Function import_kart_from_sds()

  Static struct_sds := { ;
    { "PCODE",      "N",     18,      0 }, ; // ID
    { "PAT_TYPE",   "C",    128,      0 }, ; // буква
    { "CARDNUM",    "C",     48,      0 }, ; // номер участка/номер в участке
    { "UCHST_KOD",  "C",     24,      0 }, ; // номер участка
    { "LASTNAME",   "C",     32,      0 }, ; // фамилия
    { "FIRSTNAME",  "C",     32,      0 }, ; // имя
    { "MIDNAME",    "C",     32,      0 }, ; // отчество
    { "POL",        "N",      4,      0 }, ; // N1   пол
    { "BDATE",      "D",      8,      0 }, ; // дата рождения
    { "SNILS",      "C",     24,      0 }, ; // C11  СНИЛС
    { "PASPTYPE",   "N",     18,      0 }, ; // N2   вид док-та, уд-го личность (1-18)
    { "PASPSER",    "C",     12,      0 }, ; // серия документа
    { "PASPNUM",    "C",     12,      0 }, ; // номер документа
    { "BIRTHPLACE", "C",    255,      0 }, ; // C100 место рождения
    { "PASPPLACE",  "C",    128,      0 }, ; // кем выдан документ
    { "PASPDATE",   "D",      8,      0 }, ; // когда выдан документ
    { "ADDR_REG",   "C",    255,      0 }, ; // C50  адрес регистрации (КЛАДР)
    { "OKATO_REG",  "C",     12,      0 }, ; // C11  ОКАТО регистрации
    { "ADDR_PROJ",  "C",    255,      0 }, ; // C50  адрес пребывания (КЛАДР)
    { "OKATO_PROJ", "C",     12,      0 }, ; // C11  ОКАТО пребывания
    { "WORKPLACE",  "C",    255,      0 }, ; // C50  место работы
    { "POLIS_SER",  "C",     24,      0 }, ; // C10  серия полиса
    { "POLIS_NUM",  "C",     64,      0 }, ; // C20  номер полиса
    { "P_DATABEG",  "D",      8,      0 }, ; // начало полиса
    { "P_DATAFIN",  "D",      8,      0 }, ; // окончание полиса
    { "P_DATACAN",  "D",      8,      0 }, ; // ---------------
    { "SMO_NAME",   "C",    255,      0 }, ; // C100 наименование СМО
    { "SMO_KODTER", "C",      9,      0 }, ; // C5   код территории страхования?
    { "SMO_KOD",    "C",     48,      0 }, ; // C5   код СМО
    { "SOC_STATUS", "N",     18,      0 }, ; // N2   социальный статус?
    { "POLIS_TYPE", "N",     18,      0 };  // N1   тип полиса (1-3)
  }
  Static struct_chip := { ;
    { "CHIPCODE",   "N",      7,      0 }, ; // код по картотеке
    { "PCODE",      "N",     18,      0 }, ; // ID
    { "PAT_TYPE",   "C",      1,      0 }, ; // буква
    { "CARDNUM",    "C",     10,      0 }, ; // номер участка/номер в участке
    { "LASTNAME",   "C",     32,      0 }, ; // фамилия
    { "FIRSTNAME",  "C",     32,      0 }, ; // имя
    { "MIDNAME",    "C",     32,      0 }, ; // отчество
    { "POL",        "N",      1,      0 }, ; // пол
    { "BDATE",      "D",      8,      0 }, ; // дата рождения
    { "SNILS",      "C",     14,      0 }, ; // СНИЛС
    { "PASPTYPE",   "N",      2,      0 }, ; // вид док-та, уд-го личность (1-18)
    { "PASPSER",    "C",     12,      0 }, ; // серия документа
    { "PASPNUM",    "C",     12,      0 }, ; // номер документа
    { "BIRTHPLACE", "C",    100,      0 }, ; // место рождения
    { "PASPPLACE",  "C",     70,      0 }, ; // кем выдан документ
    { "PASPDATE",   "D",      8,      0 }, ; // когда выдан документ
    { "ADDR_REG",   "C",     50,      0 }, ; // адрес регистрации (КЛАДР)
    { "OKATO_REG",  "C",     11,      0 }, ; // ОКАТО регистрации
    { "ADDR_PROJ",  "C",     50,      0 }, ; // адрес пребывания (КЛАДР)
    { "OKATO_PROJ", "C",     11,      0 }, ; // ОКАТО пребывания
    { "WORKPLACE",  "C",     50,      0 }, ; // место работы
    { "POLIS_SER",  "C",     10,      0 }, ; // серия полиса
    { "POLIS_NUM",  "C",     20,      0 }, ; // номер полиса
    { "P_DATABEG",  "D",      8,      0 }, ; //
    { "P_DATAFIN",  "D",      8,      0 }, ; //
    { "SMO_NAME",   "C",    100,      0 }, ; // наименование СМО
    { "SMO_KODTER", "C",      5,      0 }, ; // код территории страхования
    { "SMO_KOD",    "C",      5,      0 }, ; // код СМО
    { "SOC_STATUS", "N",      2,      0 }, ; // социальный статус?
    { "POLIS_TYPE", "N",      1,      0 };  // тип полиса (1-3)
  }
  Static path1_sds, path2_sds
  //
  Local ic, ii, i, j, arr_f, cFile, buf, bSaveHandler, fl, ar, arr_bad := {}
  If !is_obmen_sds()
    Return Nil
  Endif
  If path1_sds == Nil // проверяем только один раз
    ar := getinisect( tmp_ini, "RAB_MESTO" )
    path1_sds := AllTrim( a2default( ar, "path1_sds" ) )
    path2_sds := AllTrim( a2default( ar, "path2_sds" ) )
    If !Empty( path1_sds )
      If Empty( path2_sds )
        path1_sds := NIL
        Return func_error( 4, "Не настроен каталог для обработанных файлов Smart Delta Systems!" )
      Endif
      If Right( path1_sds, 1 ) != hb_ps()
        path1_sds += hb_ps()
      Endif
      If Right( path2_sds, 1 ) != hb_ps()
        path2_sds += hb_ps()
      Endif
      If Upper( path1_sds ) == Upper( path2_sds )
        path1_sds := NIL
        Return func_error( 4, "Два раза выбран тот же каталог для файлов Smart Delta Systems. Недопустимо!" )
      Endif
    Endif
  Endif
  If !Empty( path1_sds )
    arr_f := Directory( path1_sds + "*" + sdbf() ) // все DBF-файлы - в массив
    If Empty( arr_f )
      Return Nil
    Endif
    buf := save_maxrow()
    stat_msg( "Ждите! Обрабатываются изменения в картотеке (от Smart Delta Systems)" )
    g_use( dir_server() + "s_kemvyd", dir_server() + "s_kemvyd", "SA" )
    g_use( dir_server() + "mo_kfio", , "KFIO" )
    Index On Str( kod, 7 ) to ( cur_dir() + "tmp_kfio" )
    g_use( dir_server() + "mo_kismo", , "KSN" )
    Index On Str( kod, 7 ) to ( cur_dir() + "tmp_ismo" )
    use_base( "kartotek" )
    For ic := 1 To 20 // для надёжности 20 циклов опроса каталога
      If ic > 1 // второй и т.д. циклы
        arr_f := Directory( path1_sds + "*" + sdbf() ) // все DBF-файлы - в массив
        If Empty( arr_f )
          Exit
        Endif
      Endif
      For ii := 1 To Len( arr_f )
        cFile := strippath( arr_f[ ii, 1 ] )  // имя файла без пути (на всякий случай)
        If ic > 1 .and. AScan( arr_bad, cFile ) > 0
          Loop
        Endif
        @ MaxRow(), 1 Say lstr( ii ) + "(" + lstr( ic ) + ")" Color cColorSt2Msg
        bSaveHandler := ErrorBlock( {| x| Break( x ) } )
        //
        Begin Sequence
          Use ( path1_sds + cFile ) New Alias T1
          fl := .t.
          For j := 1 To Len( struct_sds )
            If FieldNum( struct_sds[ j, 1 ] ) == 0
              fl := func_error( 4, "В файле " + path1_sds + cFile + " нет поля " + struct_sds[ j, 1 ] )
              AAdd( arr_bad, cFile )
              Exit
            Endif
          Next
          If fl
            dbCreate( path2_sds + cFile, struct_chip )
            Use ( path2_sds + cFile ) New Alias T2
            Select T1
            Go Top
            Do While !Eof()
              MFIO := AllTrim( t1->LASTNAME ) + " " + AllTrim( t1->FIRSTNAME ) + " " + AllTrim( t1->MIDNAME )
              lkod_k := 0 ; mfio := PadR( CharOne( " ", mfio ), 50 )
              If !emptyany( mfio, t1->bdate )
                Select KART
                Set Order To 2
                find ( "1" + Upper( mfio ) + DToS( t1->bdate ) )
                If Found()
                  lkod_k := kart->kod
                Endif
                Select KART
                Set Order To 1
                If Empty( lkod_k )
                  add1rec( 7 )
                  lkod_k := kart->kod := RecNo()
                  kart->FIO    := mFIO
                  kart->DATE_R := t1->bdate
                Else
                  Goto ( lkod_k )
                  g_rlock( forever )
                Endif
                mdate_r := kart->DATE_R ; m1VZROS_REB := M1NOVOR := 0
                fv_date_r()
                kart->VZROS_REB := m1VZROS_REB
                If Between( t1->pol, 1, 2 )
                  kart->pol := iif( t1->pol == 1, "М", "Ж" )
                Endif
                If !Empty( t1->snils )
                  kart->snils := CharRem( " -", t1->snils )
                Endif
                If !Empty( t1->ADDR_REG )
                  kart->ADRES := f_adres_sds( t1->ADDR_REG )
                Endif
                If !Empty( t1->WORKPLACE )
                  kart->MR_DOL := LTrim( CharOne( " ", t1->WORKPLACE ) )
                Endif
                If !Empty( t1->P_DATAFIN )
                  kart->srok_polis := dtoc4( t1->P_DATAFIN )
                Endif
                kart->KOMU    := 0 // все ОМС
                kart->STR_CRB := 0
                kart->MI_GIT  := 9
                If !Empty( t1->PAT_TYPE )
                  kart->bukva := LTrim( t1->PAT_TYPE )
                Endif
                much_doc := LTrim( t1->CARDNUM )
                If !Empty( CharRem( "/", much_doc ) )
                  muchast := mkod_vu := 0
                  If Left( much_doc, 1 ) == "/"
                    much_doc := "0" + much_doc
                  Endif
                  If ( muchast := Int( Val( much_doc ) ) ) > 99
                    muchast := 0
                  Endif
                  If ( i := At( "/", much_doc ) ) > 0
                    If ( mkod_vu := Int( Val( SubStr( much_doc, i + 1 ) ) ) ) > 99999
                      mkod_vu := 0
                    Endif
                  Endif
                  kart->uchast := muchast
                  kart->kod_vu := mkod_vu
                Endif
                If twowordfamimot( t1->LASTNAME ) .or. twowordfamimot( t1->FIRSTNAME );
                    .or. twowordfamimot( t1->MIDNAME )
                  kart->MEST_INOG := 9
                Else
                  kart->MEST_INOG := 0
                Endif
                //
                Select KART2
                Do While kart2->( LastRec() ) < lkod_k
                  Append Blank
                Enddo
                Goto ( lkod_k )
                g_rlock( forever )
                //
                Select KART_
                Do While kart_->( LastRec() ) < lkod_k
                  Append Blank
                Enddo
                Goto ( lkod_k )
                g_rlock( forever )
                If !emptyall( t1->POLIS_SER, t1->POLIS_NUM )
                  kart->POLIS   := make_polis( t1->POLIS_SER, t1->POLIS_NUM )
                  kart_->VPOLIS := iif( Between( t1->POLIS_TYPE, 1, 3 ), t1->POLIS_TYPE, 1 )
                  kart_->SPOLIS := LTrim( t1->POLIS_SER )
                  kart_->NPOLIS := LTrim( t1->POLIS_NUM )
                Endif
                fl_nameismo := Empty( t1->SMO_KOD ) .and. !Empty( t1->SMO_NAME )
                If fl_nameismo
                  kart_->SMO := '34'
                Elseif !Empty( t1->SMO_KOD )
                  kart_->SMO := LTrim( t1->SMO_KOD )
                Endif
                If !Empty( t1->P_DATABEG )
                  kart_->beg_polis := dtoc4( t1->P_DATABEG )
                Endif
                If !emptyall( t1->PASPSER, t1->PASPNUM )
                  kart_->vid_ud := f_vid_ud_sds( t1->PASPTYPE )
                  kart_->ser_ud := LTrim( t1->PASPSER )
                  kart_->nom_ud := LTrim( t1->PASPNUM )
                Endif
                If !Empty( t1->PASPPLACE )
                  kart_->kemvyd := f_kemvyd_sds( t1->PASPPLACE )
                Endif
                If !Empty( t1->PASPDATE )
                  kart_->kogdavyd := t1->PASPDATE
                Endif
                If !Empty( t1->BIRTHPLACE )
                  kart_->mesto_r := t1->BIRTHPLACE
                Endif
                If !Empty( t1->OKATO_REG )
                  kart_->okatog := t1->OKATO_REG
                Endif
                If !Empty( t1->OKATO_PROJ )
                  kart_->okatop := t1->OKATO_PROJ
                Endif
                If !Empty( t1->ADDR_PROJ )
                  kart_->adresp := f_adres_sds( t1->ADDR_PROJ )
                Endif
                If kart_->okatog == kart_->okatop .and. kart->adres == kart_->adresp
                  kart_->okatop := kart_->adresp := ""
                Endif
                If Between( t1->SOC_STATUS, 1, 3 )
                  kart->RAB_NERAB := iif( t1->SOC_STATUS == 1, 0, 1 )
                  kart_->PENSIONER := iif( t1->SOC_STATUS == 2, 1, 0 )
                Endif
                //
                Select KFIO
                find ( Str( lkod_k, 7 ) )
                If Found()
                  If kart->MEST_INOG == 9
                    g_rlock( forever )
                    kfio->FAM := LTrim( CharOne( " ", t1->LASTNAME ) )
                    kfio->IM  := LTrim( CharOne( " ", t1->FIRSTNAME ) )
                    kfio->OT  := LTrim( CharOne( " ", t1->MIDNAME ) )
                  Else
                    deleterec( .t. )
                  Endif
                Else
                  If kart->MEST_INOG == 9
                    addrec( 7 )
                    kfio->kod := lkod_k
                    kfio->FAM := LTrim( CharOne( " ", t1->LASTNAME ) )
                    kfio->IM  := LTrim( CharOne( " ", t1->FIRSTNAME ) )
                    kfio->OT  := LTrim( CharOne( " ", t1->MIDNAME ) )
                  Endif
                Endif
                If !Empty( t1->SMO_KODTER )
                  kart_->KVARTAL_D := LTrim( t1->SMO_KODTER ) // ОКАТО субъекта РФ территории страхования
                Endif
                Select KSN
                find ( Str( lkod_k, 7 ) )
                If Found()
                  If fl_nameismo
                    g_rlock( forever )
                    ksn->smo_name := LTrim( t1->SMO_NAME )
                  Else
                    deleterec( .t. )
                  Endif
                Else
                  If fl_nameismo
                    addrec( 7 )
                    ksn->kod := lkod_k
                    ksn->smo_name := LTrim( t1->SMO_NAME )
                  Endif
                Endif
                Unlock
              Endif
              //
              Select T2
              Append Blank
              t2->CHIPCODE   := lkod_k
              t2->PCODE      := t1->PCODE
              t2->PAT_TYPE   := t1->PAT_TYPE
              t2->CARDNUM    := t1->CARDNUM
              t2->LASTNAME   := t1->LASTNAME
              t2->FIRSTNAME  := t1->FIRSTNAME
              t2->MIDNAME    := t1->MIDNAME
              t2->POL        := t1->POL
              t2->BDATE      := t1->BDATE
              t2->SNILS      := t1->SNILS
              t2->PASPTYPE   := t1->PASPTYPE
              t2->PASPSER    := t1->PASPSER
              t2->PASPNUM    := t1->PASPNUM
              t2->BIRTHPLACE := t1->BIRTHPLACE
              t2->PASPPLACE  := t1->PASPPLACE
              t2->PASPDATE   := t1->PASPDATE
              t2->ADDR_REG   := t1->ADDR_REG
              t2->OKATO_REG  := t1->OKATO_REG
              t2->ADDR_PROJ  := t1->ADDR_PROJ
              t2->OKATO_PROJ := t1->OKATO_PROJ
              t2->WORKPLACE  := t1->WORKPLACE
              t2->POLIS_SER  := t1->POLIS_SER
              t2->POLIS_NUM  := t1->POLIS_NUM
              t2->P_DATABEG  := t1->P_DATABEG
              t2->P_DATAFIN  := t1->P_DATAFIN
              t2->SMO_NAME   := t1->SMO_NAME
              t2->SMO_KODTER := t1->SMO_KODTER
              t2->SMO_KOD    := t1->SMO_KOD
              t2->SOC_STATUS := t1->SOC_STATUS
              t2->POLIS_TYPE := t1->POLIS_TYPE
              //
              Select T1
              Skip
            Enddo
            t1->( dbCloseArea() )
            t2->( dbCloseArea() )
            Delete File ( path1_sds + cFile )
          Else // если не наш файл, то просто закрываем
            t1->( dbCloseArea() )
          Endif
        RECOVER USING error
          If Select( "t1" ) > 0   // если вылетели по ошибке
            t1->( dbCloseArea() ) // закрыть файл
          Endif
          If Select( "t2" ) > 0   // если вылетели по ошибке
            t2->( dbCloseArea() ) // закрыть файл
          Endif
          // Построение сообщения об ошибке
          cMessage := errormessage( error )
          If !Empty( error:osCode )
            cMessage += " (код " + lstr( error:osCode ) + ")"
          End
          If ValType( error:osCode ) == "N" .and. error:osCode == 32
            // файл уже обрабатывается другой раб.станцией - ошибку не отображаем
          Else
            func_error( 4, cMessage ) // остальные ошибки выводим в последней строке
          Endif
        End
        //
        ErrorBlock( bSaveHandler )
      Next
    Next
    Close databases
    rest_box( buf )
  Endif

  Return Nil

//
Static Function f_adres_sds( s )

  Static cDelimiter := ", ", sa := { "д.", "к.", "стр.", "кв." }
  Local i, j, s1, s2 := ""

  s := AllTrim( CharOne( " ", s ) )
  For i := 1 To NumToken( s, cDelimiter )
    s1 := AllTrim( Token( s, cDelimiter, i ) )
    For j := 1 To Len( sa )
      If s1 == sa[ j ]
        s1 := "" ; Exit
      Endif
    Next
    If !Empty( s1 )
      If i > 1
        s1 := CharRem( " ", s1 )
      Endif
      s2 += s1 + ", "
    Endif
  Next
  s2 := Left( s2, Len( s2 ) -2 )
  If Len( s2 ) > 50
    s2 := CharRem( " ", s2 )
  Endif
  Do While Len( s2 ) > 50
    s2 := SubStr( s2, 2 )
  Enddo

  Return s2

//
Static Function f_vid_ud_sds( n )

  Local v := 0

  Do Case
  Case n == 1  ; v := 14 // Паспорт РФ
  Case n == 2  ; v := 1  // Паспорт СССР
  Case n == 3  ; v := 15 // Заграничный паспорт РФ
  Case n == 4  ; v := 2  // Заграничный паспорт СССР
  Case n == 5  ; v := 3  // Свидетельство о рождении
  Case n == 6  ; v := 4  // Удостоверение личности офицера
  Case n == 7  ; v := 5  // Справка об освобождении из места лишения свободы
  Case n == 8  ; v := 7  // Военный билет
  Case n == 9  ; v := 8  // Дипломатический паспорт РФ
  Case n == 10 ; v := 9  // Иностранный паспорт
  Case n == 11 ; v := 10 // Свидетельство беженца
  Case n == 12 ; v := 11 // Вид на жительство
  Case n == 13 ; v := 12 // Удостоверение беженца
  Case n == 14 ; v := 13 // Временное удостоверение
  Case n == 15 ; v := 16 // Паспорт моряка
  Case n == 16 ; v := 17 // Военный билет офицера запаса
  Case n == 88 ; v := 18 // Иные документы
  Endcase

  Return v

// 12.07.17
Static Function f_kemvyd_sds( s )

  Local l, lkod := 0, fl := .f.

  If !Empty( s )
    Select SA
    l := FieldSize( FieldNum( "name" ) )
    s := PadR( AllTrim( CharOne( " ", s ) ), l )
    find ( Upper( s ) )
    If Found()
      lkod := sa->( RecNo() )
    Endif
    If lkod == 0 .and. LastRec() < 9999
      addrecn()
      Replace name With s
      lkod := sa->( RecNo() )
      Unlock
    Endif
  Endif
  Return lkod
