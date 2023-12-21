// mo_r01.prg - функции для работы с информационным сопровождением по диспансеризации
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 18.12.23 инициализация всех файлов инф.сопровождения по диспансеризации
Function f_init_r01()

  Local mo_dr00 := { ; // пул пациентов, подлежащих диспансеризации/профосмотрам взрослого населения
  { "kod",        "N", 7, 0 }, ; // код по картотеке
  { "tip",        "N", 1, 0 }, ; // 1-диспансеризация, 2-профосмотр
  { "tip1",       "N", 1, 0 }, ; // 1-пенсионер,2-65 лет,3-66 лет и старше
  { "voz",        "N", 1, 0 }, ; // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-остальные
  { "n_m",        "N", 2, 0 }, ; // месяц для диспансеризации (1-12)
  { "n_q",        "N", 1, 0 }, ;
    { "enp",        "C", 16, 0 }, ; // ЕНП
  { "smo",        "N", 1, 0 }, ; // оповещён ли СМО
  { "REESTR",     "N", 6, 0 };  // код реестра по файлу "mo_dr01"
  }
  Local mo_dr01m := { ; // пакеты по 12 реестра за год (по месяцам)
  { "REESTR01",    "N", 6, 0 }, ; // код реестра по файлу "mo_dr01"
  { "REESTR02",    "N", 6, 0 }, ; //
  { "REESTR03",    "N", 6, 0 }, ; //
  { "REESTR04",    "N", 6, 0 }, ; //
  { "REESTR05",    "N", 6, 0 }, ; //
  { "REESTR06",    "N", 6, 0 }, ; //
  { "REESTR07",    "N", 6, 0 }, ; //
  { "REESTR08",    "N", 6, 0 }, ; //
  { "REESTR09",    "N", 6, 0 }, ; //
  { "REESTR10",    "N", 6, 0 }, ; //
  { "REESTR11",    "N", 6, 0 }, ; //
  { "REESTR12",    "N", 6, 0 }, ; //
  { "DWORK",       "D", 8, 0 }, ; // дата обработки файла;
  { "TWORK1",      "C", 5, 0 }, ; // время начала обработки;
  { "TWORK2",      "C", 5, 0 };  // время окончания обработки;
  }
  Local mo_dr01 := { ; // отсылаемые файлы о будущих диспансеризациях взрослого населения
  { "KOD",         "N", 6, 0 }, ; // код реестра (номер записи)
  { "tip",         "N", 1, 0 }, ; // 0-R01, 1-R11
  { "DSCHET",      "D", 8, 0 }, ; // дата файла
  { "NYEAR",       "N", 4, 0 }, ; // отчетный год
  { "NMONTH",      "N", 2, 0 }, ; // отчетный месяц
  { "NN",          "N", 3, 0 }, ; // порядковый номер пакета;номер по порядку пакета в данном отчетном периоде (3 знака с лидирующим нулем);
  { "NAME_XML",    "C", 26, 0 }, ; // имя XML-файла без расширения (и ZIP-архива)
  { "KOD_XML",     "N", 6, 0 }, ; // ссылка на файл "mo_xml"
  { "DATE_OUT",    "D", 8, 0 }, ; // дата отправки в ТФОМС
  { "NUMB_OUT",    "N", 2, 0 }, ; // сколько раз всего записывали файл на носитель;
  { "ANSWER",      "N", 1, 0 }, ; // 0-не было ответа, 1-получен ответ (R02)
  { "KOL",         "N", 6, 0 }, ; // количество пациентов в реестре/файле
  { "KOL_ERR",     "N", 6, 0 };  // количество пациентов с ошибками в реестре
  }
  Local mo_dr01k := { ; // список пациентов в реестрах будущих диспансеризаций
  { "REESTR",   "N", 6, 0 }, ; // код реестра по файлу "mo_dr01"
  { "KOD_K",    "N", 7, 0 }, ; // код по картотеке
  { "R01_ZAP",  "N", 6, 0 }, ; // номер позиции записи в реестре;"ZAP" в R01
  { "tip",      "N", 1, 0 }, ; // 1-диспансеризация 1 этап, 2-профосмотр
  { "tip1",     "N", 1, 0 }, ; // 1-пенсионер,2-65 лет,3-66 лет и старше
  { "voz",      "N", 1, 0 }, ; // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-прочие
  { "N_M",      "N", 2, 0 }, ; // месяц для диспансеризации (1-12)
  { "ID_PAC",   "C", 36, 0 }, ; // GUID пациента в R01 (создается при добавлении записи)
  { "OPLATA",   "N", 1, 0 };  // тип оплаты: сначала 0, затем из ТФОМС 1,2,3,4
  }
  Local mo_dr01e := { ; // список ошибок в реестрах будущих диспансеризаций
  { "REESTR",   "N", 6, 0 }, ; // код реестра;по файлу "mo_dr01"
  { "R01_ZAP",  "N", 6, 0 }, ; // номер позиции записи в реестре;"ZAP") в R01
  { "KOD_ERR",  "N", 3, 0 };  // код ошибки ТК
  }
  //
  Local mo_dr05 := { ; // отсылаемые файлы о будущих диспансеризациях взрослого населения
  { "KOD",         "N", 6, 0 }, ; // код реестра (номер записи)
  { "REC_5P",      "N", 3, 0 }, ; // номер записи в файле mo_dr05p
  { "DSCHET",      "D", 8, 0 }, ; // дата файла
  { "NYEAR",       "N", 4, 0 }, ; // отчетный год
  { "NN",          "N", 3, 0 }, ; // порядковый номер пакета в данном отчетном периоде (3 знака с лидирующим нулем)
  { "NAME_XML",    "C", 26, 0 }, ; // имя XML-файла без расширения (и ZIP-архива)
  { "KOD_XML",     "N", 6, 0 }, ; // ссылка на файл "mo_xml"
  { "DATE_OUT",    "D", 8, 0 }, ; // дата отправки в ТФОМС;;
  { "NUMB_OUT",    "N", 2, 0 }, ; // номер отправки в ТФОМС;сколько раз всего записывали файл на носитель;
  { "KOL",         "N", 6, 0 }; // количество пациентов в реестре/файле
  }
  Local mo_dr05k := { ; // кол-во пациентов в реестрах будущих диспансеризаций
  { "REESTR",   "N", 6, 0 }, ; // код реестра по файлу "mo_dr05"
  { "tip",      "N", 1, 0 }, ; // 1-диспансеризация 1 этап, 2-профосмотр
  { "voz",      "N", 1, 0 }, ; // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-прочие
  { "N_Y",      "N", 4, 0 }, ; // год для диспансеризации
  { "N_M",      "N", 2, 0 }, ; // месяц для диспансеризации (1-12)
  { "UCH",      "N", 2, 0 }, ; // номер участка (для отсылки в ТФОМС)
  { "REC_5P",   "N", 3, 0 }, ; // номер записи в файле mo_dr05p
  { "R05_ZAP",  "N", 6, 0 }, ; // номер позиции записи в реестре;"CODE_R" в R05
  { "KOL",      "N", 6, 0 }, ; // количество пациентов в реестре/файле
  { "OPLATA",   "N", 1, 0 };  // тип оплаты: сначала 0, 1 - пришла ошибка
  }
  Local mo_dr05p := { ; // план-график
  { "N_Y",      "N", 4, 0 }, ; // год для диспансеризации
  { "TYPEOFREC", "N", 1, 0 }, ; // 0-первично представленная запись, 1-актуализированная запись
  { "KOL1",     "N", 6, 0 }, ; // количество пациентов для диспансеризации на год
  { "KOL2",     "N", 6, 0 }, ; // количество пациентов для профосмотров на год
  { "KOL11",     "N", 6, 0 }, ; // количество пациентов для диспансеризации на год
  { "KOL12",     "N", 6, 0 }, ; // количество пациентов для диспансеризации на год
  { "KOL13",     "N", 6, 0 }, ; // количество пациентов для диспансеризации на год
  { "KOL1_01",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 1 месяц
  { "KOL1_02",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 2 месяц
  { "KOL1_03",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 3 месяц
  { "KOL1_04",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 4 месяц
  { "KOL1_05",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 5 месяц
  { "KOL1_06",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 6 месяц
  { "KOL1_07",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 7 месяц
  { "KOL1_08",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 8 месяц
  { "KOL1_09",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 9 месяц
  { "KOL1_10",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 10 месяц
  { "KOL1_11",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 11 месяц
  { "KOL1_12",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 12 месяц
  { "KOL2_01",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 1 месяц
  { "KOL2_02",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 2 месяц
  { "KOL2_03",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 3 месяц
  { "KOL2_04",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 4 месяц
  { "KOL2_05",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 5 месяц
  { "KOL2_06",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 6 месяц
  { "KOL2_07",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 7 месяц
  { "KOL2_08",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 8 месяц
  { "KOL2_09",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 9 месяц
  { "KOL2_10",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 10 месяц
  { "KOL2_11",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 11 месяц
  { "KOL2_12",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 12 месяц
  { "KOL11_01",  "N", 6, 0 }, ; //
  { "KOL11_02",  "N", 6, 0 }, ; //
  { "KOL11_03",  "N", 6, 0 }, ; //
  { "KOL11_04",  "N", 6, 0 }, ; //
  { "KOL11_05",  "N", 6, 0 }, ; //
  { "KOL11_06",  "N", 6, 0 }, ; //
  { "KOL11_07",  "N", 6, 0 }, ; //
  { "KOL11_08",  "N", 6, 0 }, ; //
  { "KOL11_09",  "N", 6, 0 }, ; //
  { "KOL11_10",  "N", 6, 0 }, ; //
  { "KOL11_11",  "N", 6, 0 }, ; //
  { "KOL11_12",  "N", 6, 0 }, ; //
  { "KOL12_01",  "N", 6, 0 }, ; //
  { "KOL12_02",  "N", 6, 0 }, ; //
  { "KOL12_03",  "N", 6, 0 }, ; //
  { "KOL12_04",  "N", 6, 0 }, ; //
  { "KOL12_05",  "N", 6, 0 }, ; //
  { "KOL12_06",  "N", 6, 0 }, ; //
  { "KOL12_07",  "N", 6, 0 }, ; //
  { "KOL12_08",  "N", 6, 0 }, ; //
  { "KOL12_09",  "N", 6, 0 }, ; //
  { "KOL12_10",  "N", 6, 0 }, ; //
  { "KOL12_11",  "N", 6, 0 }, ; //
  { "KOL12_12",  "N", 6, 0 }, ; //
  { "KOL13_01",  "N", 6, 0 }, ; //
  { "KOL13_02",  "N", 6, 0 }, ; //
  { "KOL13_03",  "N", 6, 0 }, ; //
  { "KOL13_04",  "N", 6, 0 }, ; //
  { "KOL13_05",  "N", 6, 0 }, ; //
  { "KOL13_06",  "N", 6, 0 }, ; //
  { "KOL13_07",  "N", 6, 0 }, ; //
  { "KOL13_08",  "N", 6, 0 }, ; //
  { "KOL13_09",  "N", 6, 0 }, ; //
  { "KOL13_10",  "N", 6, 0 }, ; //
  { "KOL13_11",  "N", 6, 0 }, ; //
  { "KOL13_12",  "N", 6, 0 }, ; //
  { "D_KZ",     "D", 8, 0 }, ; // дата приказа КЗ ВО
  { "priz",     "N", 1, 0 };
    }
  Local mo_dr05e := { ; // список ошибок в реестрах будущих диспансеризаций
  { "REESTR",   "N", 6, 0 }, ; // код реестра;по файлу "mo_dr05"
  { "R05_ZAP",  "N", 6, 0 }, ; // номер позиции записи в реестре;"ZAP") в R05
  { "KOD_ERR",  "N", 3, 0 };  // код ошибки ТК
  }
  Local fl
  reconstruct( dir_server + "mo_dr01", mo_dr01,,, .t. )
  reconstruct( dir_server + "mo_dr01m", mo_dr01m,,, .t. )
  reconstruct( dir_server + "mo_dr01k", mo_dr01k,,, .t. )
  reconstruct( dir_server + "mo_dr01e", mo_dr01e,,, .t. )
  reconstruct( dir_server + "mo_dr05", mo_dr05,,, .t. )
  reconstruct( dir_server + "mo_dr05p", mo_dr05p,,, .t. )
  reconstruct( dir_server + "mo_dr05k", mo_dr05k,,, .t. )
  reconstruct( dir_server + "mo_dr05e", mo_dr05e,,, .t. )
  reconstruct( dir_server + "mo_dr00", mo_dr00,,, .t. )
  //
  g_use( dir_server + "mo_dr05p",, "R05p" )
  Locate For n_y < 2024  // ЮЮ 14.12.23
  fl := Found()
  Use
  If fl
    f_zap_all_mo_dr()
  Endif

  Return Nil

// 14.12.23 очистить файлы - удалить 2023 год
Function f_zap_all_mo_dr()

  Local i, arrx := {}

  Use ( dir_server + "mo_dr01" ) new
  Zap
  Use ( dir_server + "mo_dr01m" ) new
  Zap
  Use ( dir_server + "mo_dr01k" ) new
  Zap
  Use ( dir_server + "mo_dr01e" ) new
  Zap
  Use ( dir_server + "mo_dr05" ) new
  Zap
  Use ( dir_server + "mo_dr05k" ) new
  Zap
  Use ( dir_server + "mo_dr05e" ) new
  Zap
  Use ( dir_server + "mo_dr00" ) new
  Zap
  g_use( dir_server + "mo_xml",, "MO_XML" )
  Index On FNAME to ( cur_dir + "tmp_xml" ) ;
    For eq_any( tip_in, _XML_FILE_R02, _XML_FILE_R06 ) .or. eq_any( TIP_OUT, _XML_FILE_R01, _XML_FILE_R05 )
  Go Top
  Do While !Eof()
    AAdd( arrx, mo_xml->( RecNo() ) )
    Skip
  Enddo
  Set Index To
  For i := 1 To Len( arrx )
    Goto ( arrx[ i ] )
    deleterec( .t. )
  Next
  Use ( dir_server + "mo_dr05p" ) new
  Zap
  Close databases

  Return Nil

// 14.12.23
Function fff_init_r01()

  Local buf := save_maxrow()

  r_use( dir_server + "mo_dr05p",, "R05p" )
  If FieldNum( "KOL11" ) == 0
    Close databases
    mywait()
    f_init_r01() // инициализация всех файлов инф.сопровождения по диспансеризации
    Close databases
    rest_box( buf )
  Endif
  Close databases

  Return Nil

// 14.12.23 Создание файла обмена R05...
Function f_create_r05()

  Local buf := save_maxrow(), i, fl
  Private mdate, mkol1 := 0, mkol2 := 0, mkol11 := 0, mkol12 := 0, mkol13 := 0, ;
    mrec, CODE_LPU := glob_mo[ _MO_KOD_TFOMS ]
  Private sgod := 2024

  //
  g_use( dir_server + "mo_dr05p",, "R05p" )
  If LastRec() == 0
    g_rlock( .t., forever ) // добавить 2-ую запись
  Endif
  mrec := 1 // пока так
  Goto ( mrec )
  If Empty( r05p->n_y )
    mdate := r05p->D_KZ := 0d20231214
    r05p->N_Y := sgod // год для диспансеризации
    r05p->TYPEOFREC := 0 // 0-первично представленная запись, 1-актуализированная запись
    r05p->KOL1 := 0 // количество пациентов для диспансеризации на год
    r05p->KOL2 := 0 // количество пациентов для профосмотров на год
  Else
    // sgod := r05p->N_Y
    mkol1 := r05p->KOL1
    mkol11 := r05p->KOL11
    mkol12 := r05p->KOL12
    mkol13 := r05p->KOL13
    mkol2 := r05p->KOL2
    mdate := r05p->D_KZ
  Endif
  Use
  //
  // !!! ВНИМАНИЕ
  Private r05_nn := 4, write_reestr := .f., is_reestr := .f.
  verify_packet_r05( 1, {}, @r05_nn )
  Close databases
  If emptyall( mkol1, mkol2 )
    Keyboard Chr( K_HOME ) + Chr( K_ENTER )
  Endif
  mas_pmt := { "План-график на ~год", ;
    "План-график по ~месяцам", ;
    "~Создание файла обмена" }
  mas_msg := { "Ввод/редактирование плана-графика диспансеризации на " + lstr( sgod ) + " год", ;
    "Ввод/редактирование плана-графика с разбивкой по месяцам", ;
    "Создание файла обмена R05 с планом-графиком по месяцам и участкам" }
  mas_fun := { "f1_create_R05()", ;
    "f2_create_R05()", ;
    "f3_create_R05()" }
  popup_prompt( T_ROW, T_COL - 5, 1, mas_pmt, mas_msg, mas_fun )
  rest_box( buf )

  Return Nil

// 12.12.19 Ввод/редактирование плана-графика диспансеризации на год
Function f1_create_r05()

  Local r1 := 13, buf, buf24 := save_maxrow(), tmp_color := SetColor( cDataCGet )
  Private skol1 := 0, skol2 := 0, skol11 := 0, skol12 := 0, skol13 := 0

  buf := box_shadow( r1, 2, MaxRow() -2, 77,, "План-график на " + lstr( sgod ) + " год", color8 )
  Do While .t.
    @ r1 + 1, 54 Say "| прикреплённое" Color color14
    @ r1 + 2, 4 Say "Приказ КЗ ВО №3630 от" Get mdate When .f.
    @ Row(), Col() + 12 Say "_план_|_количество___" Color color14
    @ r1 + 3, 4 Say "Численность лиц для диспансеризации (всего)" Get mkol1  Pict "99999"
    @ Row(), Col() + 1 Say "|" Color color14 Get skol1 Color color8 Pict "99999" When .f.
    @ r1 + 4, 4 Say "            в т.ч. лиц старше труд.возраста" Get mkol11 Pict "99999"
    @ Row(), Col() + 1 Say "|" Color color14 Get skol11 Color color8 Pict "99999" When .f.
    @ r1 + 5, 4 Say "                      лиц в возрасте 65 лет" Get mkol12 Pict "99999"
    @ Row(), Col() + 1 Say "|" Color color14 Get skol12 Color color8 Pict "99999" When .f.
    @ r1 + 6, 4 Say "             лиц в возрасте 66 лет и старше" Get mkol13 Pict "99999"
    @ Row(), Col() + 1 Say "|" Color color14 Get skol13 Color color8 Pict "99999" When .f.
    @ r1 + 7, 4 Say "Численность лиц, подлежащих профосмотрам   " Get mkol2  Pict "99999"
    @ Row(), Col() + 1 Say "|" Color color14 Get skol2 Color color8 Pict "99999" When .f.
    If is_reestr
      status_key( "^<Esc>^ - выход из режима (файл обмена R05 уже составлен)" )
      mybell( 0, ERR )
      clear_gets()
      Exit
    Else
      status_key( "^<Esc>^ выход  ^<Enter>^ подтверждение ввода  ^<F8>^ подсчёт прикреплённого количества" )
      Set Key K_F8 To f_pereschet_R05
      myread()
      Set Key K_F8 To
      If LastKey() != K_ESC .and. f_esc_enter( 1 )
        If mkol1 > mkol11
          If mkol11 > mkol12
            If mkol11 > mkol13
              If mkol12 > mkol13
                func_error( 4, "План лиц 65 лет должен быть меньше плана лиц 66 лет и старше" )
                Loop
              Endif
            Else
              func_error( 4, "План лиц старше труд.возраста должен быть больше плана лиц 66 лет и старше" )
              Loop
            Endif
          Else
            func_error( 4, "План лиц старше труд.возраста должен быть больше плана лиц 65 лет" )
            Loop
          Endif
          If mkol11 > mkol12 + mkol13
          Else
            func_error( 4, "План старше труд.возраста должен быть больше общего плана 65 + 66 лет и старше" )
            Loop
          Endif
        Else
          func_error( 4, "План лиц старше труд.возраста должен быть меньше плана итого" )
          Loop
        Endif
        g_use( dir_server + "mo_dr05p",, "R05p" )
        Goto ( mrec )
        g_rlock( forever )
        If Empty( r05p->n_y )
          r05p->N_Y := sgod // год для диспансеризации
        Endif
        r05p->KOL1 := mkol1
        r05p->KOL11 := mkol11
        r05p->KOL12 := mkol12
        r05p->KOL13 := mkol13
        r05p->KOL2 := mkol2 // количество пациентов для профосмотров на год
        Use
      Endif
      Exit
    Endif
  Enddo
  SetColor( tmp_color )
  rest_box( buf )
  rest_box( buf24 )

  Return Nil

// 14.12.23 Ввод/редактирование плана-графика с разбивкой по месяцам
Function f_pereschet_R05

  Local buf := save_maxrow(), nrow := Row(), ncol := Col(), icurs := SetCursor( 0 ), s, ;
    _arr_vozrast_DVN := ret_arr_vozrast_dvn( 0d20231201 )

  mywait( "Ждите! Производится подсчёт прикреплённого взрослого населения." )
  skol1 := skol2 := skol11 := skol12 := skol13 := 0
  r_use( dir_server + "kartote2",, "KART2" )
  r_use( dir_server + "kartote_",, "KART_" )
  r_use( dir_server + "kartotek",, "KART" )
  Set Relation To RecNo() into KART_, RecNo() into KART2
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say Str( RecNo() / LastRec() * 100, 6, 2 ) + "%" Color cColorWait
    If ( v := sgod - Year( kart->date_r ) ) > 17 .and. v < 100 ; // взрослый
      .and. kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ] ; // прикреплён к нашей МО
      .and. !( Left( kart2->PC2, 1 ) == "1" ) // и не умер
      s := Upper( kart->fio ) + " "
      If " УМЕР " $ s .or. " УМЕРЛА " $ s
        //
      Elseif AScan( _arr_vozrast_DVN, v ) == 0 // профосмотр
        skol2++
      Else
        skol1++
        If v >= iif( kart->POL == "М", 60, 55 )
          skol11++
          If v == 65
            skol12++
          Elseif v > 65
            skol13++
          Endif
        Endif
      Endif
    Endif
    Select KART
    Skip
  Enddo
  Close databases
  rest_box( buf )
  update_gets()
  @ nrow, ncol Say ""
  If icurs != 0
    SetCursor()
  Endif

  Return Nil


// 23.12.19 Ввод/редактирование плана-графика с разбивкой по месяцам
Function f2_create_r05()

  Local buf := SaveScreen(), tmp_color, t_arr[ BR_LEN ], blk, blk1, i, d, tekol[ 5 ]
  Private skol[ 5 ], ekol[ 5 ]

  AFill( ekol, 0 )
  // afill(tekol,0)
  tmp_color := SetColor( color5 )
  r_use( dir_server + "mo_dr05p",, "R05p" )
  Goto ( mrec )
  skol[ 1 ] := r05p->KOL1
  skol[ 2 ] := r05p->KOL2
  skol[ 3 ] := r05p->KOL11
  skol[ 4 ] := r05p->KOL12
  skol[ 5 ] := r05p->KOL13
  dbCreate( "tmp1", { { "MES",   "N", 2, 0 }, ;  // месяц
  { "kol1",  "N", 6, 0 }, ;
    { "kol11",  "N", 6, 0 }, ;
    { "kol12",  "N", 6, 0 }, ;
    { "kol13",  "N", 6, 0 }, ;
    { "kol2",  "N", 6, 0 } } )
  Use tmp1 New
  For i := 1 To 12
    Append Blank
    tmp1->mes := i
    tmp1->kol1 := &( "r05p->kol1_" + StrZero( i, 2 ) )
    tmp1->kol2 := &( "r05p->kol2_" + StrZero( i, 2 ) )
    tmp1->kol11 := &( "r05p->kol11_" + StrZero( i, 2 ) )
    tmp1->kol12 := &( "r05p->kol12_" + StrZero( i, 2 ) )
    tmp1->kol13 := &( "r05p->kol13_" + StrZero( i, 2 ) )
    ekol[ 1 ] += tmp1->kol1
    ekol[ 2 ] += tmp1->kol2
    ekol[ 3 ] += tmp1->kol11
    ekol[ 4 ] += tmp1->kol12
    ekol[ 5 ] += tmp1->kol13
    // tekol[1] += tmp1->kol1
    // tekol[2] += tmp1->kol2
    // tekol[3] += tmp1->kol11
    // tekol[4] += tmp1->kol12
    // tekol[5] += tmp1->kol13
  Next
  //
  /*if emptyall(ekol[1],ekol[2])
  // записываем в запись 2 из записи 1 два месяца
  // первичное заполнение
    select R05P
    goto (1)
    select TMP1
    for i := 1 to 2
      goto (i)
      tmp1->kol1 := &("r05p->kol1_"+strzero(i,2))
      tmp1->kol2 := &("r05p->kol2_"+strzero(i,2))
      tmp1->kol11 := &("r05p->kol11_"+strzero(i,2))
      tmp1->kol12 := &("r05p->kol12_"+strzero(i,2))
      tmp1->kol13 := &("r05p->kol13_"+strzero(i,2))
      ekol[1] += tmp1->kol1
      ekol[2] += tmp1->kol2
      ekol[3] += tmp1->kol11
      ekol[4] += tmp1->kol12
      ekol[5] += tmp1->kol13
      tekol[1] += tmp1->kol1
      tekol[2] += tmp1->kol2
      tekol[3] += tmp1->kol11
      tekol[4] += tmp1->kol12
      tekol[5] += tmp1->kol13
    next
    select R05P
    goto (mrec)
    select TMP1
    //
    for i := 3 to 12
      goto (i)
      tmp1->kol1 := round((skol[1]-tekol[1])/10,0)
      ekol[1] += tmp1->kol1
      tmp1->kol2 := round((skol[2]-tekol[1])/10,0)
      ekol[2] += tmp1->kol2
      tmp1->kol11 := round((skol[3]-tekol[3])/10,0)
      ekol[3] += tmp1->kol11
      tmp1->kol12 := round((skol[4]-tekol[4])/10,0)
      ekol[4] += tmp1->kol12
      tmp1->kol13 := round((skol[5]-tekol[5])/10,0)
      ekol[5] += tmp1->kol13
    next
  /*  for i := 1 to 12
      goto (i)
      tmp1->kol1 := round(skol[1]/12,0)
      ekol[1] += tmp1->kol1
      tmp1->kol2 := round(skol[2]/12,0)
      ekol[2] += tmp1->kol2
      tmp1->kol11 := round(skol[3]/12,0)
      ekol[3] += tmp1->kol11
      tmp1->kol12 := round(skol[4]/12,0)
      ekol[4] += tmp1->kol12
      tmp1->kol13 := round(skol[5]/12,0)
      ekol[5] += tmp1->kol13
    next
  */
   /* d := skol[1] - ekol[1]
    if d != 0
      tmp1->kol1 += d
      ekol[1] += d
    endif
    d := skol[2] - ekol[2]
    if d != 0
      tmp1->kol2 += d
      ekol[2] += d
    endif
    d := skol[3] - ekol[3]
    if d != 0
      tmp1->kol11 += d
      ekol[3] += d
    endif
    d := skol[4] - ekol[4]
    if d != 0
      tmp1->kol12 += d
      ekol[4] += d
    endif
    d := skol[5] - ekol[5]
    if d != 0
      tmp1->kol13 += d
      ekol[5] += d
    endif
  endif
  */
  If emptyall( ekol[ 1 ], ekol[ 2 ] )
    For i := 1 To 12
      Goto ( i )
      tmp1->kol1 := Round( skol[ 1 ] / 12, 0 )
      ekol[ 1 ] += tmp1->kol1
      tmp1->kol2 := Round( skol[ 2 ] / 12, 0 )
      ekol[ 2 ] += tmp1->kol2
      tmp1->kol11 := Round( skol[ 3 ] / 12, 0 )
      ekol[ 3 ] += tmp1->kol11
      tmp1->kol12 := Round( skol[ 4 ] / 12, 0 )
      ekol[ 4 ] += tmp1->kol12
      tmp1->kol13 := Round( skol[ 5 ] / 12, 0 )
      ekol[ 5 ] += tmp1->kol13
    Next
    d := skol[ 1 ] - ekol[ 1 ]
    If d != 0
      tmp1->kol1 += d
      ekol[ 1 ] += d
    Endif
    d := skol[ 2 ] - ekol[ 2 ]
    If d != 0
      tmp1->kol2 += d
      ekol[ 2 ] += d
    Endif
    d := skol[ 3 ] - ekol[ 3 ]
    If d != 0
      tmp1->kol11 += d
      ekol[ 3 ] += d
    Endif
    d := skol[ 4 ] - ekol[ 4 ]
    If d != 0
      tmp1->kol12 += d
      ekol[ 4 ] += d
    Endif
    d := skol[ 5 ] - ekol[ 5 ]
    If d != 0
      tmp1->kol13 += d
      ekol[ 5 ] += d
    Endif
  Endif
  r05p->( dbCloseArea() )
  Select TMP1
  Go Top
  //
  t_arr[ BR_TOP ] := 1
  t_arr[ BR_BOTTOM ] := 17
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 74
  t_arr[ BR_COLOR ] := color5
  t_arr[ BR_TITUL ] := "План-график на " + lstr( sgod ) + " год"
  t_arr[ BR_TITUL_COLOR ] := "B/W"
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', "N/W,W+/N,B/W,W+/B,R/W,W+/R", .t. }
  blk1 := {|| iif( ver_f2_create_r05( tmp1->mes ), { 3, 4 }, { 5, 6 } ) }
  t_arr[ BR_COLUMN ] := { ;
    { "  Месяц;проведения",           {|| PadR( mm_month[ tmp1->mes ], 10 ) }, blk }, ;
    { "  Количество;диспансеризаций", {|| Str( tmp1->kol1, 10 ) }, blk }, ;
    { "старше труд.;возраста",        {|| Str( tmp1->kol11, 10 ) }, blk }, ;
    { "65 лет",                       {|| Str( tmp1->kol12, 6 ) }, blk }, ;
    { "66 лет;и старше",              {|| Str( tmp1->kol13, 8 ) }, blk }, ;
    { "Про;вер",                      {|| iif( ver_f2_create_r05( tmp1->mes ), "OK ", "ERR" ) }, blk1 }, ;
    { " Количество;профосмотров",     {|| Str( tmp1->kol2, 8 ) }, blk };
    }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_f2_create_r05( nk, ob, "edit" ) }
  t_arr[ BR_FL_INDEX ] := .f.
  If is_reestr
    t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - выход (файл обмена R05 уже составлен)" ) }
  Else
    t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - выход;  ^<Enter>^ - редактирование количества по месяцам" ) }
  Endif
  box_shadow( 19, t_arr[ BR_LEFT ], 22, t_arr[ BR_RIGHT ] )
  @ 20, t_arr[ BR_LEFT ] + 2 Say "Итого сумма"   Color color5
  @ 21, t_arr[ BR_LEFT ] + 2 Say "План КЗ" Color color5
  f2_f2_create_r05()
  Private alpha_1_rect := .t.
  Keyboard Chr( K_RIGHT )
  edit_browse( t_arr )
  RestScreen( buf )
  // проверка
  // if !(ver_f3_create_R05())
  // return NIL
  // endif
  //
  If !is_reestr .and. f_esc_enter( 1 )
    g_use( dir_server + "mo_dr05p",, "R05p" )
    Goto ( mrec )
    g_rlock( forever )
    For i := 1 To 12
      Select TMP1
      Goto ( i )
      &( "r05p->kol1_" + StrZero( i, 2 ) ) := tmp1->kol1
      &( "r05p->kol2_" + StrZero( i, 2 ) ) := tmp1->kol2
      &( "r05p->kol11_" + StrZero( i, 2 ) ) := tmp1->kol11
      &( "r05p->kol12_" + StrZero( i, 2 ) ) := tmp1->kol12
      &( "r05p->kol13_" + StrZero( i, 2 ) ) := tmp1->kol13
    Next
  Endif
  Close databases
  SetColor( tmp_color )

  Return Nil

// 23.12.19
Function ver_f2_create_r05( lmes )

  Local fl := .t.

  If tmp1->kol1 >= tmp1->kol11
    If tmp1->kol11 >= tmp1->kol12
      If tmp1->kol11 >= tmp1->kol13
        If tmp1->kol12 >= tmp1->kol13
          fl := .f. // func_error(4,"План лиц 65 лет должен быть меньше плана лиц 66 лет и старше")
        Endif
      Else
        fl := .f. // func_error(4,"План лиц старше труд.возраста должен быть больше плана лиц 66 лет и старше")
      Endif
    Else
      fl := .f. // func_error(4,"План лиц старше труд.возраста должен быть больше плана лиц 65 лет")
    Endif
    If tmp1->kol11 >= tmp1->kol12 + tmp1->kol13
    Else
      fl := .f. // func_error(4,"План старше труд.возраста должен быть больше общего плана 65 + 66 лет и старше")
    Endif
  Else
    fl := .f. // func_error(4,"План лиц старше труд.возраста должен быть меньше плана итого")
  Endif

  Return fl


// 23.12.19
Function f1_f2_create_r05( nKey, oBrow, regim )

  Local ret := -1, rr := Row()

  If regim == "edit" .and. nKey == K_ENTER .and. eq_any( oBrow:colPos, 2, 3, 4, 5, 7 ) .and. !is_reestr
    Private mkol
    If oBrow:colPos == 2
      ncol := 16
      mkol := tmp1->kol1
    Elseif oBrow:colPos == 3
      ncol := 32
      mkol := tmp1->kol11
    Elseif oBrow:colPos == 4
      ncol := 41
      mkol := tmp1->kol12
    Elseif oBrow:colPos == 5
      ncol := 50
      mkol := tmp1->kol13
    Elseif oBrow:colPos == 7
      ncol := 63
      mkol := tmp1->kol2
    Endif
    // if rr == 5 .or. rr == 6
    // @ rr,ncol get mkol color "GR+/R" pict "999999" WHEN .F.
    // else
    @ rr, ncol Get mkol Color "GR+/R" Pict "999999"
    // endif
    myread()
    If LastKey() != K_ESC
      If oBrow:colPos == 2
        tmp1->kol1 := mkol
      Elseif oBrow:colPos == 3
        tmp1->kol11 := mkol
      Elseif oBrow:colPos == 4
        tmp1->kol12 := mkol
      Elseif oBrow:colPos == 5
        tmp1->kol13 := mkol
      Elseif oBrow:colPos == 7
        tmp1->kol2 := mkol
      Endif
      f2_f2_create_r05()
      ret := 0
    Endif
  Endif

  Return ret

// 12.12.19
Function f2_f2_create_r05()

  Local i, rec := tmp1->( RecNo() ), rr := Row(), cc := Col(), lcolor[ 5 ]

  AFill( lcolor, color5 )
  AFill( ekol, 0 )
  For i := 1 To 12
    Goto ( i )
    ekol[ 1 ] += tmp1->kol1
    ekol[ 2 ] += tmp1->kol2
    ekol[ 3 ] += tmp1->kol11
    ekol[ 4 ] += tmp1->kol12
    ekol[ 5 ] += tmp1->kol13
  Next
  Goto ( rec )
  For i := 1 To 5
    If !( ekol[ i ] == skol[ i ] )
      lcolor[ i ] := "R/W"
    Endif
  Next
  @ 20, 15 Say Str( ekol[ 1 ], 7 ) Color lcolor[ 1 ]
  @ 20, 31 Say Str( ekol[ 3 ], 7 ) Color lcolor[ 3 ]
  @ 20, 40 Say Str( ekol[ 4 ], 7 ) Color lcolor[ 4 ]
  @ 20, 49 Say Str( ekol[ 5 ], 7 ) Color lcolor[ 5 ]
  @ 20, 62 Say Str( ekol[ 2 ], 7 ) Color lcolor[ 2 ]
  @ 21, 15 Say Str( skol[ 1 ], 7 ) + Str( skol[ 3 ], 16 ) + Str( skol[ 4 ], 9 ) + Str( skol[ 5 ], 9 ) + Str( skol[ 2 ], 13 ) Color color5
  SetPos( rr, cc )

  Return Nil

// 12.12.19
Function read_r05( full_zip )

  Local arr_f, aerr := {}, name_zip := strippath( full_zip )
  Local fl := .f., n, cName := name_without_ext( name_zip )

  If ( arr_f := extract_zip_xml( keeppath( full_zip ), name_zip ) ) != NIL
    If ( n := AScan( arr_f, {| x| Upper( name_without_ext( x ) ) == Upper( cName ) } ) ) > 0
      cFile := arr_f[ n ]
      mywait( "Производится анализ файла " + cFile )
      cReadFile := name_without_ext( cFile )
      cFileProtokol := cReadFile + stxt
      StrFile( Space( 10 ) + "Протокол обработки файла: " + cFile + hb_eol(), cFileProtokol )
      // читаем файл в память
      oXmlDoc := hxmldoc():read( _tmp_dir1 + cFile )
      If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
        AAdd( aerr, "Ошибка в чтении файла " + cFile )
      Else
        reestr_r05_tmpfile( oXmlDoc, aerr, cReadFile )
      Endif
      If Empty( aerr )
        fl := .t.
      Else
        AEval( aerr, {| x| StrFile( x + hb_eol(), cFileProtokol, .t. ) } )
        viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
        Delete File ( cFileProtokol )
        fl := .f.
      Endif
      Close databases
    Else
      fl := func_error( 4, "В архиве " + name_zip + " нет файла " + cName + sxml )
    Endif
  Endif

  Return fl

// 23.12.19 Создание файла обмена R05
Function f3_create_r05()

  Local buf := save_maxrow(), i, j, skol[ 5 ], ekol := { 0, 0, 0, 0, 0 }, k, n, fl := .t.

  If !write_reestr
    fl := func_error( 4, "Файл обмена R05 уже составлен!" )
  Endif
  Private auch := {}, ames[ 12, 5 ], aumes[ 12, 5 ]
  If fl
    r_use( dir_server + "mo_dr05p",, "R05p" )
    Goto ( mrec )
    For n := 1 To 5
      If n < 3
        skol[ n ] := &( "r05p->KOL" + lstr( n ) )
      Else
        k := n -2
        skol[ n ] := &( "r05p->KOL1" + lstr( k ) )
      Endif
    Next
    If emptyall( skol[ 1 ], skol[ 2 ] )
      fl := func_error( 4, "Не введён план-график на " + lstr( sgod ) + " год" )
    Endif
    For i := 1 To 12
      For j := 1 To 5
        If j < 3
          ames[ i, j ] := &( "r05p->kol" + lstr( j ) + "_" + StrZero( i, 2 ) )
        Else
          k := j -2
          ames[ i, j ] := &( "r05p->kol1" + lstr( k ) + "_" + StrZero( i, 2 ) )
        Endif
        ekol[ j ] += ames[ i, j ]
      Next
    Next
    r05p->( dbCloseArea() )
  Endif
  If fl .and. emptyall( ekol[ 1 ], ekol[ 2 ] )
    fl := func_error( 4, "Не введена разбивка по месяцам плана-график на " + lstr( sgod ) + " год" )
  Endif
  If fl .and. !( skol[ 1 ] == ekol[ 1 ] .and. skol[ 2 ] == ekol[ 2 ] .and. skol[ 3 ] == ekol[ 3 ] ;
      .and. skol[ 4 ] == ekol[ 4 ] .and. skol[ 5 ] == ekol[ 5 ] )
    fl := func_error( 4, "Разбивка по месяцам в сумме не равна плану-графику на " + lstr( sgod ) + " год" )
  Endif
  If fl
    // !!! ВНИМАНИЕ

    For i := 1 To 12 // 3
      If ames[ i, 1 ] >= ames[ i, 3 ]
        If ames[ i, 3 ] >= ames[ i, 4 ]
          If ames[ i, 3 ] >= ames[ i, 5 ]
            If ames[ i, 4 ] >= ames[ i, 5 ]
              fl := func_error( 4, "План лиц 65 лет должен быть меньше плана лиц 66 лет и старше" )
            Endif
          Else
            fl := func_error( 4, "План лиц старше труд.возраста должен быть больше плана лиц 66 лет и старше" )
          Endif
        Else
          fl := func_error( 4, "План лиц старше труд.возраста должен быть больше плана лиц 65 лет" )
        Endif
        If ames[ i, 3 ] >= ames[ i, 4 ] + ames[ i, 5 ]
          //
        Else
          fl := func_error( 4, "План старше труд.возраста должен быть больше общего плана 65 + 66 лет и старше" )
        Endif
      Else
        fl := func_error( 4, "План лиц старше труд.возраста должен быть меньше плана итого" )
      Endif
      If !fl
        func_error( 4, 'Исправьте в плане-графике по месяцам информацию за "' + mm_month[ i ] + '"' )
        Exit
      Endif
    Next
  Endif
  If fl
    waitstatus( "Работа с участками..." )
    r_use_base( "kartotek" )
    Set Order To 4
    r_use( dir_server + "mo_uchvr",, "UV" )
    Index On Str( uch, 2 ) to ( cur_dir + "tmp_uv" )
    Go Top
    Do While !Eof()
      If !emptyall( uv->vrach, uv->vrachv ) // привязан врач к "взрослым" участкам
        AAdd( auch, { uv->uch, 0 } ) ; i := Len( auch )
        Select KART
        find ( StrZero( uv->uch, 2 ) )
        Do While uv->uch == kart->uchast .and. !Eof()
          updatestatus()
          If Year( kart->date_r ) + 17 < sgod .and. !kart2->( Eof() .and. !( Left( kart2->PC2, 1 ) == '1' ) );
              .and. kart2->MO_PR == glob_MO[ _MO_KOD_TFOMS ]
            auch[ i, 2 ] ++
          Endif
          Skip
        Enddo
      Endif
      Select UV
      Skip
    Enddo
    Close databases
    k := 0
    For i := Len( auch ) To 1 Step -1
      If Empty( auch[ i, 2 ] )
        del_array( auch, i )
      Else
        k += auch[ i, 2 ]
      Endif
    Next
    // !!! ВНИМАНИЕ
    For i := 1 To 12  // 3
      For j := 1 To 5
        aumes[ i, j ] := f1_f3_create_r05( ames[ i, j ], k )
      Next
    Next
    rest_box( buf )

    If f_esc_enter( "создания файла R05" )
      // !!! ВНИМАНИЕ
      mmes := 1  // менял 3
      nsh := 3
      r_use( dir_server + "mo_dr05p",, "R05p" )
      Goto ( mrec )
      g_use( dir_server + "mo_dr05k",, "RHUM" )
      Index On Str( REESTR, 6 ) to ( cur_dir + "tmp_rhum" )
      g_use( dir_server + "mo_dr05",, "REES" )
      addrecn()
      rees->KOD    := RecNo()
      rees->REC_5P := mrec // номер записи в файле mo_dr05p
      rees->DSCHET := sys_date
      rees->NYEAR  := sgod
      rees->NN     := r05_nn + 1
      s := "R05" + "T34M" + CODE_LPU + "_" + Right( StrZero( rees->NYEAR, 4 ), 2 ) + "00" + StrZero( rees->NN, nsh )
      rees->NAME_XML := s
      mkod_reestr := rees->KOD
      //
      g_use( dir_server + "mo_xml",, "MO_XML" )
      addrecn()
      mo_xml->KOD    := RecNo()
      mo_xml->FNAME  := s
      mo_xml->FNAME2 := ""
      mo_xml->DFILE  := rees->DSCHET
      mo_xml->TFILE  := hour_min( Seconds() )
      mo_xml->TIP_IN := 0
      mo_xml->TIP_OUT := _XML_FILE_R05  // тип высылаемого файла
      mo_xml->REESTR := mkod_reestr
      //
      rees->KOD_XML := mo_xml->KOD
      Unlock
      Commit
      //
      oXmlDoc := hxmldoc():new()
      oXmlDoc:add( hxmlnode():new( "ZL_LIST" ) )
      oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( "ZGLV" ) )
      mo_add_xml_stroke( oXmlNode, "VERSION", '3.0' )
      mo_add_xml_stroke( oXmlNode, "DATE_F", date2xml( mo_xml->DFILE ) )
      mo_add_xml_stroke( oXmlNode, "NAME_F", mo_xml->FNAME )
      oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( "GENERAL_INFO" ) )
      mo_add_xml_stroke( oXmlNode, "CODEM", CODE_LPU )
      mo_add_xml_stroke( oXmlNode, "YEAR", lstr( rees->NYEAR ) )
      mo_add_xml_stroke( oXmlNode, "SIGN", lstr( r05p->TYPEOFREC ) )
      oVOLUMES := oXmlNode:add( hxmlnode():new( "VOLUMES" ) )
      oVOLUME := oVOLUMES:add( hxmlnode():new( "VOLUME" ) )
      mo_add_xml_stroke( oVOLUME, "PREVENTIVE_ACTION", "R" )
      mo_add_xml_stroke( oVOLUME, "QUANTITY", lstr( r05p->kol2 ) )
      oVOLUME := oVOLUMES:add( hxmlnode():new( "VOLUME" ) )
      mo_add_xml_stroke( oVOLUME, "PREVENTIVE_ACTION", "O" )
      mo_add_xml_stroke( oVOLUME, "QUANTITY", lstr( r05p->kol1 ) )
      oVOLUME := oVOLUMES:add( hxmlnode():new( "VOLUME" ) )
      mo_add_xml_stroke( oVOLUME, "PREVENTIVE_ACTION", "D" )
      mo_add_xml_stroke( oVOLUME, "QUANTITY", lstr( r05p->kol11 ) )
      oVOLUME := oVOLUMES:add( hxmlnode():new( "VOLUME" ) )
      mo_add_xml_stroke( oVOLUME, "PREVENTIVE_ACTION", "P" )
      mo_add_xml_stroke( oVOLUME, "QUANTITY", lstr( r05p->kol12 ) )
      oVOLUME := oVOLUMES:add( hxmlnode():new( "VOLUME" ) )
      mo_add_xml_stroke( oVOLUME, "PREVENTIVE_ACTION", "Y" )
      mo_add_xml_stroke( oVOLUME, "QUANTITY", lstr( r05p->kol13 ) )
      oZAPS := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( "ZAPS" ) )
      icode := 0
      // !!! ВНИМАНИЕ
      For i := mmes To 12 // месяцы
        oZAP := oZAPS:add( hxmlnode():new( "ZAP" ) )
        mo_add_xml_stroke( oZAP, "MONTH", lstr( i ) )
        For l := 1 To 5 // 1-диспансеризация 1 этап, 2-профосмотр
          j := { 2, 1, 3, 4, 5 }[ l ]
          If Len( aumes[ i, j ] ) == 0// участки
            Loop
          Endif
          oQUANTITY_INFO := oZAP:add( hxmlnode():new( "QUANTITY_INFO" ) )
          mo_add_xml_stroke( oQUANTITY_INFO, "PR_ACTION", { "O", "R", "D", "P", "Y" }[ j ] )
          If j < 3
            v := &( "r05p->kol" + lstr( j ) + "_" + StrZero( i, 2 ) )
          Else
            n := j -2
            v := &( "r05p->kol1" + lstr( n ) + "_" + StrZero( i, 2 ) )
          Endif
          mo_add_xml_stroke( oQUANTITY_INFO, "QUANTITY_MONTH", lstr( v ) )
          oRECORDS := oQUANTITY_INFO:add( hxmlnode():new( "RECORDS" ) )
          For k := 1 To Len( aumes[ i, j ] ) // участки
            ++icode
            Select RHUM
            addrec( 6 )
            rhum->REESTR := mkod_reestr
            rhum->tip := j  // 1-диспансеризация 1 этап, 2-профосмотр
            v := 4
            If j == 3
              v := 3
            Elseif j == 4
              v := 1
            Elseif j == 5
              v := 2
            Endif
            rhum->voz := v // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-прочие
            rhum->N_Y := sgod // год для диспансеризации
            rhum->N_M := i // месяц для диспансеризации (1-12)
            rhum->UCH := aumes[ i, j, k, 1 ] // номер участка (для отсылки в ТФОМС)
            rhum->REC_5P := mrec // номер записи в файле mo_dr05p
            rhum->R05_ZAP := icode // номер позиции записи в реестре;"CODE_R" в R05
            rhum->KOL := aumes[ i, j, k, 2 ] // количество пациентов в реестре/файле
            rhum->OPLATA := 0 // тип оплаты: сначала 0...
            oRECORD := oRECORDS:add( hxmlnode():new( "RECORD" ) )
            mo_add_xml_stroke( oRECORD, "CODE_R", lstr( icode ) )
            // mo_add_xml_stroke(oRECORD,"CODE_DISTRICT","")
            mo_add_xml_stroke( oRECORD, "NAME_DISTRICT", lstr( rhum->UCH ) )
            mo_add_xml_stroke( oRECORD, "QUANTITY_D", lstr( rhum->kol ) )
          Next k
        Next j
      Next i
      name_zip := AllTrim( mo_xml->FNAME ) + szip ; arr_zip := {}
      stat_msg( "Запись XML-файла" )
      oXmlDoc:save( AllTrim( mo_xml->FNAME ) + sxml )
      AAdd( arr_zip, AllTrim( mo_xml->FNAME ) + sxml )
      //
      Close databases
      If chip_create_zipxml( name_zip, arr_zip, .t. )
        Keyboard Chr( K_ESC ) + Chr( K_END ) + Chr( K_ENTER )
      Endif
    Endif
  Endif
  rest_box( buf )

  Return Nil

// 11.07.18 разбиение графика за месяц по участкам
Function f1_f3_create_r05( v, su )

  Local i, d, k := 0, l := Len( auch )
  Local arr := Array( l, 2 )

  For i := 1 To l
    arr[ i, 1 ] := auch[ i, 1 ]
    arr[ i, 2 ] := Int( v * auch[ i, 2 ] / su )
    If arr[ i, 2 ] < 0  // не должно быть меньше нуля
      arr[ i, 2 ] := 0
    Endif
    k += arr[ i, 2 ]
  Next
  d := v - k
  If d > 0
    ASort( arr,,, {| x, y| x[ 2 ] < y[ 2 ] } )
    Do While d > 0
      For i := 1 To l
        arr[ i, 2 ] ++
        If--d == 0 ; exit ; Endif
      Next
    Enddo
    ASort( arr,,, {| x, y| x[ 1 ] < y[ 1 ] } )
  Endif

  Return AClone( arr )

// 12.12.19 зачитать R05 во временные файлы
Function reestr_r05_tmpfile( oXmlDoc, aerr, mname_xml )

  Local i, j, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()

  Default aerr TO {}, mname_xml To ""
  stat_msg( "Распаковка/чтение/анализ файла " + BeforAtNum( ".", mname_xml ) )
  dbCreate( cur_dir + "tmp1file", { ;
    { "VERSION",  "C", 5, 0 }, ;
    { "DATE_F",   "D", 8, 0 }, ;
    { "NAME_F",   "C", 26, 0 }, ;
    { "codem",    "C", 6, 0 }, ;
    { "year",     "N", 4, 0 }, ;
    { "sign",     "N", 1, 0 }, ;
    { "kol1",     "N", 6, 0 }, ;
    { "kol2",     "N", 6, 0 }, ;
    { "KOL1_01",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 1 месяц
  { "KOL1_02",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 2 месяц
  { "KOL1_03",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 3 месяц
  { "KOL1_04",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 4 месяц
  { "KOL1_05",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 5 месяц
  { "KOL1_06",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 6 месяц
  { "KOL1_07",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 7 месяц
  { "KOL1_08",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 8 месяц
  { "KOL1_09",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 9 месяц
  { "KOL1_10",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 10 месяц
  { "KOL1_11",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 11 месяц
  { "KOL1_12",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 12 месяц
  { "KOL2_01",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 1 месяц
  { "KOL2_02",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 2 месяц
  { "KOL2_03",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 3 месяц
  { "KOL2_04",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 4 месяц
  { "KOL2_05",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 5 месяц
  { "KOL2_06",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 6 месяц
  { "KOL2_07",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 7 месяц
  { "KOL2_08",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 8 месяц
  { "KOL2_09",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 9 месяц
  { "KOL2_10",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 10 месяц
  { "KOL2_11",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 11 месяц
  { "KOL2_12",  "N", 6, 0 }, ; // количество пациентов для профосмотров на 12 месяц
  { "KOL11_01",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 1 месяц
  { "KOL11_02",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 2 месяц
  { "KOL11_03",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 3 месяц
  { "KOL11_04",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 4 месяц
  { "KOL11_05",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 5 месяц
  { "KOL11_06",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 6 месяц
  { "KOL11_07",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 7 месяц
  { "KOL11_08",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 8 месяц
  { "KOL11_09",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 9 месяц
  { "KOL11_10",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 10 месяц
  { "KOL11_11",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 11 месяц
  { "KOL11_12",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 12 месяц
  { "KOL11_01",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 1 месяц
  { "KOL12_02",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 2 месяц
  { "KOL12_03",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 3 месяц
  { "KOL12_04",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 4 месяц
  { "KOL12_05",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 5 месяц
  { "KOL12_06",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 6 месяц
  { "KOL12_07",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 7 месяц
  { "KOL12_08",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 8 месяц
  { "KOL12_09",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 9 месяц
  { "KOL12_10",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 10 месяц
  { "KOL12_11",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 11 месяц
  { "KOL12_12",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 12 месяц
  { "KOL13_01",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 1 месяц
  { "KOL13_02",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 2 месяц
  { "KOL13_03",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 3 месяц
  { "KOL13_04",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 4 месяц
  { "KOL13_05",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 5 месяц
  { "KOL13_06",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 6 месяц
  { "KOL13_07",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 7 месяц
  { "KOL13_08",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 8 месяц
  { "KOL13_09",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 9 месяц
  { "KOL13_10",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 10 месяц
  { "KOL13_11",  "N", 6, 0 }, ; // количество пациентов для диспансеризации на 11 месяц
  { "KOL13_12",  "N", 6, 0 }; // количество пациентов для диспансеризации на 12 месяц
  } )
  dbCreate( cur_dir + "tmp2file", { ;
    { "tip",      "N", 1, 0 }, ; // 1-диспансеризация 1 этап, 2-профосмотр
  { "N_M",      "N", 2, 0 }, ; // месяц для диспансеризации (1-12)
  { "UCH",      "N", 2, 0 }, ; // номер участка (для отсылки в ТФОМС)
  { "R05_ZAP",  "N", 6, 0 }, ; // номер позиции записи в реестре;"CODE_R" в R05
  { "KOL",      "N", 6, 0 };  // количество пациентов в реестре/файле
  } )
  Use ( cur_dir + "tmp1file" ) New Alias TMP1
  Append Blank
  Use ( cur_dir + "tmp2file" ) New Alias TMP2
  For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
    @ MaxRow(), 1 Say PadR( lstr( j ), 6 ) Color cColorSt2Msg
    oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
    Do Case
    Case "ZGLV" == oXmlNode:title
      tmp1->VERSION :=          mo_read_xml_stroke( oXmlNode, "VERSION", aerr )
      tmp1->DATE_F  := xml2date( mo_read_xml_stroke( oXmlNode, "DATE_F", aerr ) )
      tmp1->NAME_F  :=          mo_read_xml_stroke( oXmlNode, "NAME_F", aerr )
    Case "GENERAL_INFO" == oXmlNode:title
      tmp1->CODEM :=     mo_read_xml_stroke( oXmlNode, "CODEM", aerr )
      tmp1->YEAR  := Val( mo_read_xml_stroke( oXmlNode, "YEAR", aerr ) )
      tmp1->SIGN  := Val( mo_read_xml_stroke( oXmlNode, "SIGN", aerr ) )
      If ( oNode1 := oXmlNode:find( "VOLUMES" ) ) != NIL
        For i := 1 To Len( oNode1:aitems ) // последовательный просмотр
          oNode2 := oNode1:aItems[ i ]     // т.к. м.б. несколько
          If "VOLUME" == oNode2:title
            s := AllTrim( mo_read_xml_stroke( oNode2, "PREVENTIVE_ACTION", aerr ) )
            If s == "O"
              s1 := "1"
            Elseif s == "R"
              s1 := "2"
            Elseif s == "D"
              s1 := "11"
            Elseif s == "P"
              s1 := "12"
            Else
              s1 := "13"
            Endif
            pole := "tmp1->kol" + s1
            &pole := Val( mo_read_xml_stroke( oNode2, "QUANTITY", aerr ) )
          Endif
        Next
      Endif
    Case "ZAPS" == oXmlNode:title
      For j1 := 1 To Len( oXmlNode:aitems )
        oNode1 := oXmlNode:aItems[ j1 ]
        If oNode1:title == "ZAP"
          im := Val( mo_read_xml_stroke( oNode1, "MONTH", aerr ) )
          For j2 := 1 To Len( oNode1:aitems )
            oNode2 := oNode1:aItems[ j2 ]
            If oNode2:title == "QUANTITY_INFO"
              s := AllTrim( mo_read_xml_stroke( oNode2, "PR_ACTION", aerr ) )
              If s == "O"
                s1 := "1"
              Elseif s == "R"
                s1 := "2"
              Elseif s == "D"
                s1 := "11"
              Elseif s == "P"
                s1 := "12"
              Else
                s1 := "13"
              Endif
              pole := "tmp1->kol" + s1 + "_" + StrZero( im, 2 )
              &pole := Val( mo_read_xml_stroke( oNode2, "QUANTITY_MONTH", aerr ) )
              If ( oNode3 := oNode2:find( "RECORDS" ) ) != NIL
                For j4 := 1 To Len( oNode3:aitems )
                  oNode4 := oNode3:aItems[ j4 ]
                  If "RECORD" == oNode4:title
                    Select TMP2
                    Append Blank
                    tmp2->tip     := ip
                    tmp2->N_M     := im
                    tmp2->UCH     := Val( mo_read_xml_stroke( oNode4, "NAME_DISTRICT", aerr ) )
                    tmp2->R05_ZAP := Val( mo_read_xml_stroke( oNode4, "CODE_R", aerr ) )
                    tmp2->KOL     := Val( mo_read_xml_stroke( oNode4, "QUANTITY_D", aerr ) )
                  Endif
                Next j4
              Endif
            Endif
          Next j2
        Endif
      Next j1
    Endcase
  Next j
  Commit
  rest_box( buf )

  Return Nil

// 11.12.17 зачитать R06 во временные файлы
Function reestr_r06_tmpfile( oXmlDoc, aerr, mname_xml )

  Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()

  Default aerr TO {}, mname_xml To ""
  stat_msg( "Распаковка/чтение/анализ файла " + BeforAtNum( ".", mname_xml ) )
  dbCreate( cur_dir + "tmp1file", { ;
    { "_VERSION",   "C",  5, 0 }, ;
    { "_DATE_F",    "D",  8, 0 }, ;
    { "_NAME_F",    "C", 26, 0 }, ;
    { "_NAME_FE",   "C", 26, 0 };
    } )
  dbCreate( cur_dir + "tmp2file", { ;
    { "_N_ZAP",     "N",  6, 0 }, ; // CODE_R
  { "_PR_ACTION", "C",  1, 0 }, ;
    { "_MONTH",     "N",  2, 0 }, ;
    { "_ERROR",     "N",  3, 0 };
    } )
  Use ( cur_dir + "tmp1file" ) New Alias TMP1
  Append Blank
  Use ( cur_dir + "tmp2file" ) New Alias TMP2
  For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
    @ MaxRow(), 1 Say PadR( lstr( j ), 6 ) Color cColorSt2Msg
    oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
    // aadd(aerr,print_array({oXmlNode:title,oXmlNode:type,oXmlNode:aItems,oXmlNode:aAttr}))
    Do Case
    Case "ZGLV" == oXmlNode:title
      tmp1->_VERSION :=          mo_read_xml_stroke( oXmlNode, "VERSION", aerr )
      tmp1->_DATE_F  := xml2date( mo_read_xml_stroke( oXmlNode, "DATE_F", aerr ) )
      tmp1->_NAME_F  :=          mo_read_xml_stroke( oXmlNode, "NAME_F", aerr )
      tmp1->_NAME_FE :=          mo_read_xml_stroke( oXmlNode, "NAME_FE", aerr )
    Case "ERRS" == oXmlNode:title
      Select TMP2
      Append Blank
      tmp2->_ERROR := Val( mo_read_xml_tag( oXmlNode, aerr ) )
    Case "ZAPS" == oXmlNode:title
      Select TMP2
      Append Blank
      tmp2->_N_ZAP     := Val( mo_read_xml_stroke( oXmlNode, "CODE_R",   aerr ) )
      tmp2->_PR_ACTION :=     mo_read_xml_stroke( oXmlNode, "PR_ACTION", aerr )
      tmp2->_MONTH     := Val( mo_read_xml_stroke( oXmlNode, "MONTH",    aerr ) )
      tmp2->_ERROR     := Val( mo_read_xml_stroke( oXmlNode, "ERROR",    aerr ) )
    Endcase
  Next j
  Commit
  rest_box( buf )

  Return Nil

// 26.12.22 прочитать и "разнести" по базам данных файл R06
Function read_xml_file_r06( arr_XML_info, aerr, /*@*/current_i2,lrec_xml)

  Local count_in_schet := 0, bSaveHandler, ii1, ii2, i, j, k, t_arr[ 2 ], ldate_R06, s

  Default lrec_xml To 0
  mkod_reestr := arr_XML_info[ 7 ]
  Use ( cur_dir + "tmp1file" ) New Alias TMP1
  ldate_R06 := tmp1->_DATE_F
  r_use( dir_server + "mo_dr05",, "REES" )
  Goto ( arr_XML_info[ 7 ] )
  StrFile( "Обрабатывается ответ ТФОМС на информационный пакет " + AllTrim( rees->NAME_XML ) + sxml + hb_eol() + ;
    "за " + lstr( rees->NYEAR ) + " год от " + date_8( rees->DSCHET ) + "г." + hb_eol() + hb_eol(), cFileProtokol, .t. )
  //
  r_use( dir_server + "mo_dr05k",, "RHUM" )
  Index On Str( R05_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For REESTR == mkod_reestr
  Use ( cur_dir + "tmp2file" ) New Alias TMP2
  i := 0 ; k := LastRec()
  // сначала проверка
  ii1 := ii2 := 0
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say Str( ++i / k * 100, 6, 2 ) + "%" Color cColorWait
    ++ii2
    If tmp2->_N_ZAP > 0
      Select RHUM
      find ( Str( tmp2->_N_ZAP, 6 ) )
      If !Found()
        AAdd( aerr, "Не найден случай с N_ZAP = " + lstr( tmp2->_N_ZAP ) )
      Endif
    Endif
    Select TMP2
    Skip
  Enddo
  Close databases
  If Empty( aerr ) // если проверка прошла успешно
    // запишем принимаемый файл (реестр СП)
    // chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
    chip_copy_zipxml( full_zip, dir_server + dir_XML_TF )
    g_use( dir_server + "mo_xml",, "MO_XML" )
    If Empty( lrec_xml )
      addrecn()
    Else
      Goto ( lrec_xml )
      g_rlock( forever )
    Endif
    mo_xml->KOD := RecNo()
    mo_xml->FNAME := cReadFile
    mo_xml->DFILE := ldate_R06
    mo_xml->TFILE := ""
    mo_xml->DREAD := sys_date
    mo_xml->TREAD := hour_min( Seconds() )
    mo_xml->TIP_IN := _XML_FILE_R06 // тип принимаемого файла
    mo_xml->TIP_OUT := 0
    mo_xml->DWORK  := sys_date
    mo_xml->TWORK1 := cTimeBegin
    mo_xml->REESTR := mkod_reestr
    //
    mXML_REESTR := mo_xml->KOD
    Use
    If ii2 > 0
      g_use( dir_server + "mo_dr05e",, "REFR" )
      Index On Str( REESTR, 6 ) + Str( R05_ZAP, 6 ) + Str( KOD_ERR, 3 ) to ( cur_dir + "tmp_r05e" )
    Endif
    g_use( dir_server + "mo_dr05k",, "RHUM" )
    Index On Str( R05_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For REESTR == mkod_reestr
    Use ( cur_dir + "tmp2file" ) New Alias TMP2
    Index On Str( _n_zap, 6 ) + Str( _error, 3 ) to ( cur_dir + "tmp2" )
    count_in_schet := LastRec() ; current_i2 := 0
    i := 0
    Go Top
    Do While !Eof()
      @ MaxRow(), 0 Say Str( ++i / k * 100, 6, 2 ) + "%" Color cColorWait
      If tmp2->_N_ZAP > 0
        Select RHUM
        find ( Str( tmp2->_N_ZAP, 6 ) )
        g_rlock( forever )
        rhum->OPLATA := 1
      Endif
      If tmp2->_error > 0
        --count_in_schet    // не включается в счет,
        If current_i2 == 0
          StrFile( Space( 10 ) + "Список ошибок:" + hb_eol() + hb_eol(), cFileProtokol, .t. )
        Endif
        ++current_i2
        s := ""
        Do Case
        Case rhum->tip == 1
          s := "диспансеризация (всего)"
        Case rhum->tip == 2
          s := "профосмотр"
        Case rhum->tip == 3
          s := "диспансеризация (пенсионеры)"
        Case rhum->tip == 4
          s := "диспансеризация (65 лет)"
        Case rhum->tip == 5
          s := "диспансеризация (66 лет и старше)"
        Endcase
        If tmp2->_N_ZAP > 0
          StrFile( "CODE_R=" + lstr( tmp2->_N_ZAP ) + ", " + s + ;
            ", год=" + lstr( rhum->n_y ) + ", " + mm_month[ rhum->n_m ] + ", уч-к=" + lstr( rhum->uch ) + hb_eol(), cFileProtokol, .t. )
        Else
          StrFile( "Ошибка на уровне файла" + hb_eol(), cFileProtokol, .t. )
        Endif
        Select REFR
        Do While .t.
          find ( Str( mkod_reestr, 6 ) + Str( tmp2->_N_ZAP, 6 ) + Str( tmp2->_error, 3 ) )
          If !Found() ; exit ; Endif
          deleterec( .t. )
        Enddo
        Select REFR
        addrec( 6 )
        refr->reestr := mkod_reestr
        refr->R05_ZAP := tmp2->_N_ZAP
        refr->KOD_ERR := tmp2->_ERROR
        // if (j := ascan(getT012(), {|x| x[2] == tmp2->_ERROR })) > 0
        // strfile(space(8) + "ошибка " + lstr(tmp2->_ERROR) + " - " + getT012()[j,1] + hb_eol(), cFileProtokol, .t.)
        // else
        // strfile(space(8)+"ошибка "+lstr(tmp2->_ERROR)+" (неизвестная ошибка)"+hb_eol(),cFileProtokol,.t.)
        // endif
        StrFile( Space( 8 ) + geterror_t012( tmp2->_ERROR ) + hb_eol(), cFileProtokol, .t. )
      Endif
      Unlock All
      Select TMP2
      If RecNo() % 1000 == 0
        Commit
      Endif
      Skip
    Enddo
    If ii2 == 0
      StrFile( "Ошибок не обнаружено." + hb_eol(), cFileProtokol, .t. )
    Endif
  Endif
  Close databases

  Return count_in_schet


// 10.12.17 Просмотр файлов обмена R05... и результатов работы с ними
Function f_view_r05()

  Local i, k, buf := SaveScreen()
  Private goal_dir := dir_server + dir_XML_MO + cslash

  g_use( dir_server + "mo_xml",, "MO_XML" )
  r_use( dir_server + "mo_dr05p",, "R05p" )
  g_use( dir_server + "mo_dr05",, "REES" )
  Index On DToS( dschet ) + Str( nn, 3 ) to ( cur_dir + "tmp_rees" ) DESCENDING
  Set Relation To rec_5p into R05p
  Go Top
  If Eof()
    func_error( 4, "Не было создано файлов R05..." )
  Else
    Private reg := 1
    alpha_browse( T_ROW, 2, MaxRow() -2, 77, "f1_view_R05", color0,,,,,,, ;
      "f2_view_R05",, { '═', '░', '═', "N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R", .t., 180 } )
  Endif
  Close databases
  RestScreen( buf )

  Return Nil

// 10.12.17
Function f1_view_r05( oBrow )

  Local oColumn, ;
    blk := {|| iif( hb_FileExists( goal_dir + AllTrim( rees->NAME_XML ) + szip ), ;
    iif( Empty( rees->date_out ), { 3, 4 }, { 1, 2 } ), ;
    { 5, 6 } ) }

  oColumn := TBColumnNew( " №№", {|| Str( rees->nn, 3 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "  Дата", {|| date_8( rees->dschet ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Период", {|| lstr( rees->nyear, 4 ) + " год" } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "   Дата;приказа КЗ", {|| full_date( r05p->d_kz ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Наименование файла", {|| PadR( rees->NAME_XML, 21 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Примечание", {|| f11_view_r05() } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If reg == 1
    status_key( "^<Esc>^ выход; ^<F5>^ запись для ТФОМС; ^<F3>^ информация о файле" )
  Else
    status_key( "^<Esc>^ - выход;  ^<Enter>^ - выбор реестра для возврата" )
  Endif

  Return Nil

// 10.12.17
Static Function f11_view_r05()

  Local s := ""

  If !hb_FileExists( goal_dir + AllTrim( rees->NAME_XML ) + szip )
    s := "нет файла"
  Elseif Empty( rees->date_out )
    s := "не записан"
  Else
    s := "зап. " + lstr( rees->NUMB_OUT ) + " раз"
  Endif

  Return PadR( s, 10 )

// 10.12.17
Function f2_view_r05( nKey, oBrow )

  Local ret := -1, rec := rees->( RecNo() ), tmp_color := SetColor(), r, r1, r2, ;
    s, buf := SaveScreen(), arr, i, k, mdate, t_arr[ 2 ], arr_pmt := {}

  Do Case
  Case nKey == K_F5
    zip_file := AllTrim( rees->NAME_XML ) + szip
    If f_esc_enter( "записи файла R05 за " + date_8( mdate ) )
      Private p_var_manager := "copy_schet"
      s := manager( T_ROW, T_COL + 5, MaxRow() -2,, .t., 2, .f.,,, ) // "norton" для выбора каталога
      If !Empty( s )
        If Upper( s ) == Upper( goal_dir )
          func_error( 4, "Вы выбрали каталог, в котором уже записан данный файл! Это недопустимо." )
        Elseif hb_FileExists( goal_dir + zip_file )
          mywait( 'Копирование "' + zip_file + '" в каталог "' + s + '"' )
          // copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
          Copy File ( goal_dir + zip_file ) to ( s + zip_file )
          // if hb_fileExists(hb_OemToAnsi(s)+zip_file)
          If hb_FileExists( s + zip_file )
            rees->( g_rlock( forever ) )
            rees->DATE_OUT := sys_date
            If rees->NUMB_OUT < 99
              rees->NUMB_OUT++
            Endif
            //
            mo_xml->( rees->KOD_XML )
            mo_xml->( g_rlock( forever ) )
            mo_xml->DREAD := sys_date
            mo_xml->TREAD := hour_min( Seconds() )
          Else
            func_error( 4, "! Ошибка записи файла " + s + zip_file )
          Endif
        Else
          func_error( 4, "! Не обнаружен файл " + goal_dir + zip_file )
        Endif
      Endif
      dbUnlockAll()
      dbCommitAll()
      n_message( { "Запись завершена!" },, "GR+/B", "W+/B", 18,, "G+/B" )
    Endif
    Select REES
    Goto ( rec )
    ret := 0
  Case nKey == K_F3
    f3_view_r05( oBrow )
    ret := 0
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret

// 20.03.17
Function f3_view_r05( oBrow )

  Static si := 1
  Local i, r := Row(), r1, r2, buf := save_maxrow(), fl, s, ;
    mm_func := { -99 }, ;
    mm_menu := { "~Численность по месяцам из R05" }

  mywait()
  Select MO_XML
  Index On FNAME to ( cur_dir + "tmp_xml" ) ;
    For reestr == rees->kod .and. tip_in == _XML_FILE_R06 .and. Empty( TIP_OUT )
  Go Top
  Do While !Eof()
    s := "Протокол чтения " + RTrim( mo_xml->FNAME ) + " прочитан " + date_8( mo_xml->DWORK )
    If Empty( mo_xml->TWORK2 )
      s += "-ПРОЦЕСС НЕ ЗАВЕРШЁН"
    Else
      s += " в " + mo_xml->TWORK1
    Endif
    AAdd( mm_func, mo_xml->kod )
    AAdd( mm_menu, s )
    Skip
  Enddo
  Select MO_XML
  Set Index To
  If r <= 12
    r1 := r + 1 ; r2 := r1 + Len( mm_menu ) + 1
  Else
    r2 := r - 1 ; r1 := r2 - Len( mm_menu ) -1
  Endif
  rest_box( buf )
  If Len( mm_menu ) == 1
    i := 1
    si := i
    If mm_func[ i ] < 0
      f31_view_r05( Abs( mm_func[ i ] ), mm_menu[ i ] )
    Endif
  Elseif ( i := popup_prompt( r1, 10, si, mm_menu,,, color5 ) ) > 0
    si := i
    If mm_func[ i ] < 0
      f31_view_r05( Abs( mm_func[ i ] ), mm_menu[ i ] )
    Else
      mo_xml->( dbGoto( mm_func[ i ] ) )
      viewtext( devide_into_pages( dir_server + dir_XML_TF + cslash + AllTrim( mo_xml->FNAME ) + stxt, 60, 80 ),,,, .t.,,, 2 )
    Endif
  Endif
  Select REES

  Return Nil

// 12.12.19
Function f31_view_r05( reg, s )

  Local fl, buf := save_maxrow(), i, j, v, sh := 80, HH := 60, n_file := "r05_spis" + stxt

  mywait()
  fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( glob_mo[ _MO_SHORT_NAME ] )
  add_string( "" )
  add_string( Center( "Численность по месяцам из файла " + AllTrim( rees->NAME_XML ) + " от " + date_8( rees->dschet ), sh ) )
  add_string( "" )
  add_string( "Приказ Комитета здравоохранения Волгоградской области от " + full_date( r05p->d_kz ) + "г." )
  For j := 1 To 5
    If j < 3
      v := &( "r05p->kol" + lstr( j ) )
    Else
      v := &( "r05p->kol1" + lstr( j - 2 ) )
    Endif
    If v > 0
      add_string( "" )
      s := { "Диспансеризация", ;
        "Профилактические осмотры взрослых", ;
        "Диспансеризация (старше труд.возраста)", ;
        "Диспансеризация (65 лет)", ;
        "Диспансеризация (66 лет и старше)" }[ j ]
      verify_ff( HH - 13, .t., sh )
      add_string( s + " на " + lstr( r05p->n_y ) + " год - " + lstr( v ) + " чел." )
      fl := .t.
      For i := 1 To 12
        If j < 3
          v := &( "r05p->kol" + lstr( j ) + "_" + StrZero( i, 2 ) )
        Else
          v := &( "r05p->kol1" + lstr( j - 2 ) + "_" + StrZero( i, 2 ) )
        Endif
        If v > 0
          s := iif( fl, "в том числе", "" ) + " на " + mm_month[ i ]
          fl := .f.
          add_string( PadL( s, 25 ) + Str( v, 6 ) )
        Endif
      Next
    Endif
  Next
  FClose( fp )
  rest_box( buf )
  viewtext( n_file,,,, .t.,,, 2 )

  Return Nil


// 14.12.23
Function verify_packet_r05( par, arr, /*@*/ret_nn)

  Local fl := .t.

  is_reestr := .f.
  ret_nn := 0 // !!! ВНИМАНИЕ  0
  r_use( dir_server + "mo_dr05e",, "REFR" )
  r_use( dir_server + "mo_xml",, "MO_XML" )
  Index On Str( reestr, 6 ) to ( cur_dir + "tmp_xml" ) For tip_in == _XML_FILE_R06 .and. Empty( TIP_OUT )
  r_use( dir_server + "mo_dr05",, "R05" )
  Index On Str( REC_5P, 3 ) + Str( 1000 -nn, 4 ) to ( cur_dir + "tmp_r05" ) For nyear == sgod
  find ( Str( mrec, 3 ) )
  If Found()
    is_reestr := .t.
    ret_nn := r05->nn
    Select MO_XML
    find ( Str( r05->kod, 6 ) )
    If Found()
      Select REFR
      Locate For reestr == r05->kod
      If Found()
        fl := .f.
        write_reestr := .t.
        AAdd( arr, "В ответе PR05 на файл обмена R05 присутствуют ошибки" )
        If refr->r05_zap == 0 .and. ( refr->kod_err == 510  .or. refr->kod_err == 508 )
          AAdd( arr, "Ошибка 510 - отредактируйте плановое количество за год и по месяцам" )
          is_reestr := .f.
        Endif
      Else
        write_reestr := .f.
      Endif
    Else
      fl := .f.
      AAdd( arr, "Не получен ответ (PR05) на файл обмена R05" )
      write_reestr := .f.
    Endif
  Else
    fl := .f.
    write_reestr := .t.
    If par == 1 // не выводить данное сообщение (при запуске программы)
      AAdd( arr, "Не составлен файла обмена R05" )
    Endif
  Endif

  Return fl

// 14.12.23 Создание файла обмена R01...
Function f_create_r01()

  Local buf := save_maxrow(), i, j, ir, s := "", arr := {}, fl := .t., fl1 := .f., a_reestr := {}, ;
    azip := {}, aerr := {}, full_zip, name_zip, cFile, cName, oXmlDoc, lgod_r
  Private SMONTH := 1, mdate := sys_date, mrec := 1

  // !!! ВНИМАНИЕ
  Private c_view := 0, c_found := 0, fl_exit := .f., pj, arr_rees := {}, ;
    pkol := 0, CODE_LPU := glob_mo[ _MO_KOD_TFOMS ], CODE_MO := glob_mo[ _MO_KOD_FFOMS ], ;
    mkol := { 0, 0, 0, 0, 0 }, skol[ 5 ], ames[ 12, 5 ], ame[ 12 ], bm := SMONTH, ; // начальный месяц минус один
  _arr_vozrast_DVN := ret_arr_vozrast_dvn( 0d20231201 )
  Private sgod := 2024
  //
  my_debug(, "1111111111111111" )
  f00_create_r01()
  //
  my_debug(, "22222222222222" )
  mywait()
  If ( fl := verify_packet_r05( 1, arr ) )
    r_use( dir_server + "mo_dr05p",, "R05p" )
    Goto ( mrec )
    skol[ 1 ] := r05p->KOL1
    skol[ 2 ] := r05p->KOL2
    skol[ 3 ] := r05p->KOL11
    skol[ 4 ] := r05p->KOL12
    skol[ 5 ] := r05p->KOL13
    skol[ 1 ] -= skol[ 3 ]
    skol[ 3 ] -= skol[ 4 ]
    skol[ 3 ] -= skol[ 5 ]
    For i := 1 To 12
      For j := 1 To 2
        ames[ i, j ] := { &( "r05p->kol" + lstr( j ) + "_" + StrZero( i, 2 ) ), 0 }
      Next
      For j := 1 To 3
        ames[ i, j + 2 ] := { &( "r05p->kol1" + lstr( j ) + "_" + StrZero( i, 2 ) ), 0 }
      Next
      ames[ i, 1, 1 ] -= ames[ i, 3, 1 ]
      ames[ i, 3, 1 ] -= ames[ i, 4, 1 ]
      ames[ i, 3, 1 ] -= ames[ i, 5, 1 ]
    Next
    AFill( ame, 0 )
    //
    Select MO_XML
    Index On Str( reestr, 6 ) to ( cur_dir + "tmp_xml" ) For tip_in == _XML_FILE_R02 .and. Empty( TIP_OUT )
    r_use( dir_server + "mo_dr01",, "REES" )
    Index On Str( nn, 3 ) + Str( NMONTH, 2 ) to ( cur_dir + "tmp_dr01" ) For NYEAR == sgod .and. tip == 0
    Go Top
    Do While !Eof()
      fl1 := .t.
      If rees->kol_err < 0
        // fl := func_error(4,"В файле R02 за "+lstr(rees->NMONTH)+"-й месяц "+;
        // lstr(sgod)+"г. ошибки на уровне файла! Операция запрещена")
      Elseif Empty( rees->answer )
        fl := func_error( 4, "Файл PR01 за " + lstr( rees->NMONTH ) + "-й месяц " + ;
          lstr( sgod ) + " года не был прочитан! Операция запрещена" )
      Else
        Select MO_XML
        find ( Str( rees->kod, 6 ) )
        If Found()
          If Empty( mo_xml->TWORK2 )
            fl := func_error( 4, "Прервано чтение файла " + AllTrim( mo_xml->FNAME ) + ;
              "! Аннулируйте (Ctrl+F12) и прочитайте снова" )
          Else
            AAdd( arr_rees, rees->kod )
          Endif
        Endif
      Endif
      Select REES
      Skip
    Enddo
    //
    If fl
      If fl1 // не первый раз составляется реестр в отчётном году
        r_use( dir_server + "mo_dr01k",, "R01k" )
        Index On Str( reestr, 6 ) + Str( kod_k, 7 ) to ( cur_dir + "tmp_dr01k" )
        Use ( dir_server + "mo_dr00" ) New Alias TMP
        Index On kod to ( cur_dir + "tmp_dr00" ) For reestr == 0
        Go Top
        Do While !Eof()
          j := tmp->tip
          If Between( j, 1, 2 )
            j1 := tmp->tip1
            tmp->n_m := tmp->n_q := 0 // если уже заходили в режим и не подтвердили создание XML
            If Between( j1, 1, 3 )
              mkol[ j1 + 2 ] ++
            Else
              mkol[ j ] ++ // подсчёт оставшегося кол -ва в пуле пациентов
            Endif
          Endif
          Skip
        Enddo
        Commit
        //
        Index On Str( reestr, 6 ) to ( cur_dir + "tmp_dr00" )
        For ir := 1 To Len( arr_rees )
          Select TMP
          find ( Str( arr_rees[ ir ], 6 ) )
          Do While tmp->reestr == arr_rees[ ir ] .and. !Eof()
            Select R01k
            find ( Str( tmp->reestr, 6 ) + Str( tmp->kod, 7 ) )
            If Found()
              If r01k->oplata == 1  // учтён в ТФОМС
                i := tmp->n_m
                If !Between( i, 1, 12 )
                  fl := func_error( 4, "Некорректный месяц в файле MO_DR00.DBF! Операция запрещена" )
                  Exit
                Endif
                j := tmp->tip
                j1 := tmp->tip1
                If !Between( j, 1, 2 )
                  fl := func_error( 4, "Некорректный вид осмотра в файле MO_DR00.DBF! Операция запрещена" )
                  Exit
                Endif
                If Between( j1, 1, 3 )
                  ames[ i, j1 + 2, 2 ] ++
                  skol[ j1 + 2 ] --
                Else
                  ames[ i, j, 2 ] ++
                  skol[ j ] --
                Endif
              Else
                // tp->oplata := r01k->oplata
              Endif
            Endif
            Select TMP
            Skip
          Enddo
          If !fl ; exit ; Endif
        Next ir
        If emptyall( skol[ 1 ], skol[ 2 ], skol[ 3 ], skol[ 4 ], skol[ 5 ] )
          fl := func_error( 4, "Более не требуется создания файлов обмена!" )
        Else
          For j := 1 To 5
            If mkol[ j ] < skol[ j ]
              s := { "диспансеризаций", "профосмотров", "дисп.пенсионеров", "дисп.65 лет", "дисп.66 лет и старше" }[ j ]
              fl := func_error( 4, "Не хватает " + lstr( skol[ j ] -mkol[ j ] ) + " чел. в картотеке для " + s )
            Endif
          Next
        Endif
      Else // первый раз составляется реестр в отчётном году
        status_key( "^<Esc>^ - прервать поиск" )
        hGauge := gaugenew(,,, "Поиск пациентов, подлежащих дисп-ии/профосмотрам", .t. )
        gaugedisplay( hGauge )
        Use ( dir_server + "mo_dr00" ) New Alias TMP
        Zap  // т.к.первый раз
        r_use( dir_server + "human_",, "HUMAN_" )
        r_use( dir_server + "human", dir_server + "humankk", "HUMAN" )
        Set Relation To RecNo() into HUMAN_
        r_use( dir_server + "kartote2",, "KART2" )
        r_use( dir_server + "kartote_",, "KART_" )
        r_use( dir_server + "kartotek",, "KART" )
        Set Relation To RecNo() into KART_, RecNo() into KART2
        Go Top
        Do While !Eof()
          gaugeupdate( hGauge, RecNo() / LastRec() )
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          If kart->kod > 0
            f0_create_r01( sgod, @c_view, @c_found )
          Endif
          Select KART
          Skip
        Enddo
        closegauge( hGauge )
        If tmp->( LastRec() ) == 0
          fl := func_error( 4, "При поиске пациентов для диспансеризации не обнаружено сведений!" )
        Elseif fl_exit
          fl := func_error( 4, "Прервано пользователем!" )
        Endif
      Endif
    Endif
    //
    If fl
      mywait()
      // ставим принудительную заплатку на 3-й месяц
      // конец
      For v := 1 To 5
        j := { 2, 4, 5, 3, 1 }[ v ]
        // порядок: 2-профосмотр, 4-65 лет, 5-66 и старше, 3-пенсионеры, 1-остальная дисп-ия
        If Empty( skol[ j ] )
          Loop
        Endif
        pj := j
        d := koef := Int( mkol[ j ] / skol[ j ] ) + 1 // через сколько записей прыгаем
        If d > 50
          d := koef := 33
        Endif
        i := 0
        Do While skol[ j ] > 0
          Select TMP
          If j == 2 // профосмотр
            Index On kod to ( cur_dir + "tmp_dr00" ) For tmp->tip == 2 .and. tmp->n_q == 0 DESCENDING
          Elseif j == 1 // работоспособного возраста
            Index On kod to ( cur_dir + "tmp_dr00" ) For tmp->tip == 1 .and. tmp->tip1 == 0 .and. tmp->n_q == 0 DESCENDING
          Else  // 4-65 лет, 5-66 и старше, 3-пенсионеры
            // выборка 66 и старше
            // затем 65 лет
            // затем остатки песионеров
            Index On kod to ( cur_dir + "tmp_dr00" ) For eq_any( tmp->tip, 1, 2 ) .and. tmp->tip1 == pj - 2 .and. tmp->n_q == 0 DESCENDING
          Endif
          Go Top
          Do While !Eof()
            If d == koef
              If i >= 12  // месяцы
                i := 0
              Endif
              Do While i < 12
                ++i
                If ames[ i, j, 1 ] > ames[ i, j, 2 ] // если ещё не набрали месяц
                  tmp->n_m := i
                  ames[ i, j, 2 ] ++
                  skol[ j ] --
                  Exit
                Endif
              Enddo
              d := 0
            Endif
            ++d
            If Empty( skol[ j ] )
              Exit
            Endif
            Skip
          Enddo
          //
          Select TMP
          If j == 2
            Index On kod to ( cur_dir + "tmp_dr00" ) For tmp->tip == 2 .and. tmp->n_m > 0
          Elseif j == 1
            Index On kod to ( cur_dir + "tmp_dr00" ) For tmp->tip == 1 .and. tmp->tip1 == 0 .and. tmp->n_m > 0
          Else
            Index On kod to ( cur_dir + "tmp_dr00" ) For eq_any( tmp->tip, 1, 2 ) .and. tmp->tip1 == pj - 2 .and. tmp->n_m > 0
          Endif
          Go Top
          Do While !Eof()
            If tmp->n_q == 0 .and. Between( tmp->n_m, 1, 12 )
              tmp->n_q := Int( ( tmp->n_m + 2 ) / 3 ) // определяем номер квартала по месяцу
              ame[ tmp->n_m ] ++
            Endif
            Skip
          Enddo
          //
        Enddo
      Next v
    Endif
  Else
    func_error( 4, arr[ 1 ] )
  Endif
  Close databases
  rest_box( buf )
  If fl
    If fl1
      If emptyall( ame[ 1 ], ame[ 2 ], ame[ 3 ], ame[ 4 ], ame[ 5 ], ame[ 6 ], ame[ 7 ], ame[ 8 ], ame[ 9 ], ame[ 10 ], ame[ 11 ], ame[ 12 ] )
        func_error( 4, "Больше нет необходимости создавать файлы R01 за " + lstr( sgod ) + " год" )
      Else
        f1_create_r01()
      Endif
    Else
      f1_create_r01()
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil



// 18.12.19
Static Function f0_create_r01( sgod, cv, cf )

  Local fl, v, ltip, ltip1, lvoz, ag, lgod_r, s

  ++cv
  If ( fl := ( kart2->MO_PR == CODE_LPU ) ) // прикреплён к нашей МО
    lgod_r := Year( kart->date_r )
    v := sgod - lgod_r
    If ( fl := ( v > 17 ) ) // только взрослое население
      Select HUMAN
      find ( Str( kart->kod, 7 ) )
      Do While human->kod_k == kart->kod .and. !Eof()
        If Between( human->ishod, 201, 203 ) .and. Year( human->k_data ) == sgod
          fl := .f. ; Exit // в этом году была диспансеризация или профилактика
        Endif
        Skip
      Enddo
      If fl
        lvoz := 4
        ltip1 := 0
        If AScan( _arr_vozrast_DVN, v ) > 0
          ltip := 1 // диспансеризация
          // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-прочие
          If v >= iif( kart->POL == "М", 60, 55 )
            lvoz := 3
            ltip1 := 1
            If v == 65
              lvoz := 1
              ltip1 := 2
            Elseif v > 65
              lvoz := 2
              ltip1 := 3
            Endif
          Endif
        Else
          ltip := 2 // профосмотры
        Endif
      Endif
    Endif
  Endif
  If fl // За исключением умерших (по сведению ТФОМС) и моложе 100 лет
    fl := !( Left( kart2->PC2, 1 ) == "1" ) .or. v < 100
  Endif
  If fl
    s := Upper( kart->fio ) + " "
    If " УМЕР " $ s .or. " УМЕРЛА " $ s
      fl := .f.
    Endif
  Endif
  If fl
    Select TMP
    Append Blank
    tmp->kod := kart->kod
    tmp->tip := ltip
    tmp->tip1 := ltip1
    tmp->voz := lvoz
    If Between( ltip1, 1, 3 )
      ++mkol[ltip1 + 2 ]
    Else
      ++mkol[ltip ]
    Endif
    If++cf % 500 == 0
      tmp->( dbCommit() )
    Endif
  Endif
  @ MaxRow(), 1 Say lstr( cv ) Color cColorSt2Msg
  @ Row(), Col() Say "/" Color "W/R"
  @ Row(), Col() Say lstr( cf ) Color cColorStMsg

  Return Nil

// 14.12.23
Function f00_create_r01()

  Local fl := .f., v, t1, t2, lgod_r, ltip1, ltip, lvoz
  Local sgod := 2024

  status_key( "^<Esc>^ - прервать поиск" )
  hGauge := gaugenew(, , , "Проверка пациентов, подлежащих дисп-ии/профосмотрам", .t. )
  gaugedisplay( hGauge )
  Use ( dir_server + "mo_dr00" ) New Alias TMP
  r_use( dir_server + "kartote2", , "KART2" )
  r_use( dir_server + "kartote_", , "KART_" )
  r_use( dir_server + "kartotek", , "KART" )
  Set Relation To RecNo() into KART_, RecNo() into KART2
  Select TMP
  Go Top
  Do While !Eof()
    fl := .f.
    gaugeupdate( hGauge, RecNo() / LastRec() )
    If Inkey() == K_ESC
      fl_exit := .t.
      Exit
    Endif
    If tmp->reestr == 999999
      Select TMP

      g_rlock( forever )
      tmp->reestr := 0
      Unlock
    Endif
    Skip
  Enddo
  closegauge( hGauge )
  Close databases

  Return Nil


// 14.12.23
Function f1_create_r01()

  Local SMONTH, nsh := 3, smsg, arr_nn[ 12 ]

  If !f_esc_enter( "создания файлов R01", .t. )
    Return Nil
  Endif
  AFill( arr_nn, 0 )
  g_use( dir_server + "mo_dr01m",, "RM" )
  addrecn()
  rm->DWORK := sys_date
  rm->TWORK1 := hour_min( Seconds() )
  Unlock
  //
  g_use( dir_server + "mo_dr01k",, "RHUM" )
  Index On Str( REESTR, 6 ) to ( cur_dir + "tmp_rhum" )
  g_use( dir_server + "mo_dr01",, "REES" )
  Index On Str( NMONTH, 2 ) + Str( nn, 3 ) to ( cur_dir + "tmp_dr01" ) For NYEAR == sgod .and. tip == 0
  For SMONTH := 1 To 12
    find ( Str( SMONTH, 2 ) )
    Do While SMONTH == rees->NMONTH .and. !Eof()
      If arr_nn[ SMONTH ] < rees->nn
        arr_nn[ SMONTH ] := rees->nn
      Endif
      Skip
    Enddo
  Next
  Set Index To
  g_use( dir_server + "mo_xml",, "MO_XML" )
  r_use( dir_server + "kartote2",, "KART2" )
  r_use( dir_server + "kartote_",, "KART_" )
  r_use( dir_server + "kartotek",, "KART" )
  Set Relation To RecNo() into KART_, RecNo() into KART2
  g_use( dir_server + "mo_dr00",, "TMP" )
  Set Relation To kod into KART
  Index On Str( n_m, 2 ) + Upper( kart->fio ) + DToS( kart->date_r ) to ( cur_dir + "tmp_dr00" )
  For SMONTH := 1 To 12
    If Empty( ame[ SMONTH ] )
      Loop
    Endif
    smsg := "Составление файла R01 за " + lstr( SMONTH ) + "-й месяц"
    stat_msg( smsg )
    Select REES
    addrecn()
    rees->KOD    := RecNo()
    rees->DSCHET := sys_date
    rees->NYEAR  := sgod
    rees->NMONTH := SMONTH
    rees->NN     := arr_nn[ SMONTH ] + 1
    s := "R01" + "T34M" + CODE_LPU + "_" + Right( StrZero( rees->NYEAR, 4 ), 2 ) + StrZero( rees->NMONTH, 2 ) + StrZero( rees->NN, nsh )
    rees->NAME_XML := s
    mkod_reestr := rees->KOD
    //
    rm->( g_rlock( forever ) )
    &( "rm->reestr" + StrZero( SMONTH, 2 ) ) := mkod_reestr
    //
    Select MO_XML
    addrecn()
    mo_xml->KOD    := RecNo()
    mo_xml->FNAME  := s
    mo_xml->FNAME2 := ""
    mo_xml->DFILE  := rees->DSCHET
    mo_xml->TFILE  := hour_min( Seconds() )
    mo_xml->TIP_IN := 0
    mo_xml->TIP_OUT := _XML_FILE_R01  // тип высылаемого файла - R01
    mo_xml->REESTR := mkod_reestr
    //
    rees->KOD_XML := mo_xml->KOD
    Unlock
    Commit
    pkol := 0
    Select TMP
    find ( Str( SMONTH, 2 ) )
    Do While tmp->n_m == SMONTH .and. !Eof()
      If tmp->reestr == 0
        ++pkol
        @ MaxRow(), 1 Say lstr( pkol ) Color cColorSt2Msg
        Select TMP
        g_rlock( forever )
        tmp->reestr := mkod_reestr
        //
        Select RHUM
        addrec( 6 )
        rhum->REESTR := mkod_reestr
        rhum->KOD_K := tmp->kod
        rhum->n_m := tmp->n_m
        rhum->tip := tmp->tip
        rhum->tip1 := tmp->tip1
        rhum->voz := tmp->voz
        rhum->R01_ZAP := pkol
        rhum->ID_PAC := mo_guid( 1, tmp->kod )
        rhum->OPLATA := 0
      Endif
      If pkol % 2000 == 0
        dbUnlockAll()
        dbCommitAll()
      Endif
      Select TMP
      Skip
    Enddo
    Select REES
    g_rlock( forever )
    rees->KOL := pkol
    rees->KOL_ERR := 0
    dbUnlockAll()
    dbCommitAll()
    //
    stat_msg( smsg )
    //
    oXmlDoc := hxmldoc():new()
    oXmlDoc:add( hxmlnode():new( "ZL_LIST" ) )
    oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( "ZGLV" ) )
    mo_add_xml_stroke( oXmlNode, "VERSION", '3.0' )
    mo_add_xml_stroke( oXmlNode, "CODEM", CODE_LPU )
    mo_add_xml_stroke( oXmlNode, "DATE_F", date2xml( mo_xml->DFILE ) )
    mo_add_xml_stroke( oXmlNode, "NAME_F", mo_xml->FNAME )
    mo_add_xml_stroke( oXmlNode, "SMO", '34' )
    mo_add_xml_stroke( oXmlNode, "YEAR", lstr( rees->NYEAR ) )
    mo_add_xml_stroke( oXmlNode, "MONTH", lstr( rees->NMONTH ) )
    mo_add_xml_stroke( oXmlNode, "N_PACK", lstr( rees->NN ) )
    //
    Select RHUM
    Set Relation To kod_k into KART
    Index On Str( R01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For REESTR == mkod_reestr
    Go Top
    Do While !Eof()
      @ MaxRow(), 0 Say Str( rhum->R01_ZAP / pkol * 100, 6, 2 ) + "%" Color cColorSt2Msg
      arr_fio := retfamimot( 1, .f. )
      oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( "PERSONS" ) )
      mo_add_xml_stroke( oXmlNode, "ZAP", lstr( rhum->R01_ZAP ) )
      mo_add_xml_stroke( oXmlNode, "IDPAC", rhum->ID_PAC )
      mo_add_xml_stroke( oXmlNode, "SURNAME", arr_fio[ 1 ] )
      mo_add_xml_stroke( oXmlNode, "NAME", arr_fio[ 2 ] )
      If !Empty( arr_fio[ 3 ] )
        mo_add_xml_stroke( oXmlNode, "PATRONYMIC", arr_fio[ 3 ] )
      Endif
      mo_add_xml_stroke( oXmlNode, "BIRTHDAY", date2xml( kart->date_r ) )
      mo_add_xml_stroke( oXmlNode, "SEX", iif( kart->pol == "М", '1', '2' ) )
      If !Empty( kart->snils )
        mo_add_xml_stroke( oXmlNode, "SS", Transform( kart->SNILS, picture_pf ) )
      Endif
      // проверим наличие ЕНП - иначе старый вариант
      If Len( AllTrim( kart2->KOD_MIS ) ) > 14
        mo_add_xml_stroke( oXmlNode, "TYPE_P", lstr( 3 ) ) // только НОВЫЙ
        s := AllTrim( kart2->KOD_MIS )
        s := PadR( s, 16, "0" )
        //
        mo_add_xml_stroke( oXmlNode, "NUM_P", s )
        mo_add_xml_stroke( oXmlNode, "ENP", s )
      Else
        mo_add_xml_stroke( oXmlNode, "TYPE_P", lstr( iif( Between( kart_->VPOLIS, 1, 3 ), kart_->VPOLIS, 1 ) ) )
        If !Empty( kart_->SPOLIS )
          mo_add_xml_stroke( oXmlNode, "SER_P", kart_->SPOLIS )
        Endif
        s := AllTrim( kart_->NPOLIS )
        If kart_->VPOLIS == 3 .and. Len( s ) != 16
          s := PadR( s, 16, "0" )
        Endif
        mo_add_xml_stroke( oXmlNode, "NUM_P", s )
        If kart_->VPOLIS == 3
          mo_add_xml_stroke( oXmlNode, "ENP", s )
        Endif
      Endif
      mo_add_xml_stroke( oXmlNode, "DOCTYPE", lstr( kart_->vid_ud ) )
      If !Empty( kart_->ser_ud )
        mo_add_xml_stroke( oXmlNode, "DOCSER", kart_->ser_ud )
      Endif
      mo_add_xml_stroke( oXmlNode, "DOCNUM", kart_->nom_ud )
      If !Empty( smr := del_spec_symbol( kart_->mesto_r ) )
        mo_add_xml_stroke( oXmlNode, "MR", smr )
      Endif
      mo_add_xml_stroke( oXmlNode, "CATEGORY", '0' )
      mo_add_xml_stroke( oXmlNode, "T_PR", { "O", "R" }[ rhum->tip ] )
      oCONTACTS := oXmlNode:add( hxmlnode():new( "CONTACTS" ) )
      If !Empty( kart_->PHONE_H )
        mo_add_xml_stroke( oCONTACTS, "TEL_F", Left( kart_->PHONE_H, 1 ) + "-" + SubStr( kart_->PHONE_H, 2, 4 ) + "-" + SubStr( kart_->PHONE_H, 6 ) )
      Endif
      If !Empty( kart_->PHONE_M )
        mo_add_xml_stroke( oCONTACTS, "TEL_M", Left( kart_->PHONE_M, 1 ) + "-" + SubStr( kart_->PHONE_M, 2, 3 ) + "-" + SubStr( kart_->PHONE_M, 5 ) )
      Endif
      oADDRESS := oCONTACTS:add( hxmlnode():new( "ADDRESS" ) )
      s := "18000"
      If Len( AllTrim( kart_->okatop ) ) == 11
        s := Left( kart_->okatop, 5 )
      Elseif Len( AllTrim( kart_->okatog ) ) == 11
        s := Left( kart_->okatog, 5 )
      Endif
      mo_add_xml_stroke( oADDRESS, "SUBJ", s )
      If !Empty( kart->adres )
        mo_add_xml_stroke( oADDRESS, "UL", kart->adres )
      Endif
      Select RHUM
      Skip
    Enddo
    stat_msg( "Запись XML-файла" )
    oXmlDoc:save( AllTrim( mo_xml->FNAME ) + sxml )
    chip_create_zipxml( AllTrim( mo_xml->FNAME ) + szip, { AllTrim( mo_xml->FNAME ) + sxml }, .t. )
  Next SMONTH
  rm->( g_rlock( forever ) )
  rm->TWORK2 := hour_min( Seconds() )
  Close databases
  Keyboard Chr( K_TAB ) + Chr( K_ENTER )
  // rest_box(buf)

  Return Nil

// 29.01.20 Просмотр файлов обмена R01... и результатов работы с ними
Function f_view_r01( tip_f )

  Local i, k, buf := SaveScreen()

  Default tip_f To _XML_FILE_R01
  Private goal_dir := dir_server + dir_XML_MO + cslash, ptip_f := tip_f, pname_f := iif( tip_f == _XML_FILE_R01, "R01", "R11" )
  g_use( dir_server + "mo_xml",, "MO_XML" )
  g_use( dir_server + "mo_dr01",, "REES" )
  If tip_f == _XML_FILE_R01
    Index On Descend( DToS( dschet ) ) + Str( NMONTH, 2 ) + StrZero( nn, 3 ) to ( cur_dir + "tmp_rees" ) For tip == 0
  Else
    Index On Descend( StrZero( NMONTH, 2 ) + StrZero( nn, 3 ) ) to ( cur_dir + "tmp_rees" ) For tip == 1
  Endif
  Go Top
  If Eof()
    func_error( 4, "Не было создано файлов " + pname_f )
  Else
    Private reg := 1
    alpha_browse( T_ROW, 2, MaxRow() -2, 77, "f1_view_R01", color0,,,,,,, ;
      "f2_view_R01",, { '═', '░', '═', "N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R", .t., 180 } )
  Endif
  Close databases
  RestScreen( buf )

  Return Nil

// 06.02.20
Function f1_view_r01( oBrow )

  Local oColumn, ;
    blk := {|| iif( hb_FileExists( goal_dir + AllTrim( rees->NAME_XML ) + szip ), ;
    iif( Empty( rees->date_out ), { 3, 4 }, { 1, 2 } ), ;
    { 5, 6 } ) }

  oColumn := TBColumnNew( " №№", {|| Str( rees->nn, 3 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "  Дата", {|| date_8( rees->dschet ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Период", {|| Str( rees->nyear, 4 ) + "/" + StrZero( rees->NMONTH, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Кол-во;пациентов", {|| Str( rees->kol, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Кол-во; ошибок", {|| iif( rees->kol_err < 0, "в файле", put_val( rees->kol_err, 7 ) ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "От-;вет", {|| iif( rees->answer == 1, "да ", "нет" ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Наименование файла", {|| PadR( rees->NAME_XML, 21 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Примечание", {|| f11_view_r01() } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If reg == 1
    status_key( "^<Esc>^ выход ^<F5>^ запись для ТФОМС ^<F3>^ информация о файле ^<F9>^ общая информация" )
  Else
    status_key( "^<Esc>^ - выход;  ^<Enter>^ - выбор реестра для возврата" )
  Endif

  Return Nil

// 14.12.17
Static Function f11_view_r01()

  Local s := ""

  If !hb_FileExists( goal_dir + AllTrim( rees->NAME_XML ) + szip )
    s := "нет файла"
  Elseif Empty( rees->date_out )
    s := "не записан"
  Else
    s := "зап. " + lstr( rees->NUMB_OUT ) + " раз"
  Endif

  Return PadR( s, 10 )

// 06.02.20
Function f2_view_r01( nKey, oBrow )

  Local ret := -1, rec := rees->( RecNo() ), tmp_color := SetColor(), r, r1, r2, ;
    s, buf := SaveScreen(), arr, i, k, mdate, t_arr[ 2 ], arr_pmt := {}

  Do Case
  Case nKey == K_F9
    If ptip_f == _XML_FILE_R01
      f32_view_r01()
    Else
      f32_view_r11( rees->NMONTH )
    Endif
    Select REES
    Goto ( rec )
    ret := 0
  Case nKey == K_F5
    mdate := rees->dschet
    r_use( dir_server + "mo_dr01m",, "RM" )
    Locate for &( "rm->reestr" + StrZero( rees->NMONTH, 2 ) ) == rees->kod
    If !Found()
      func_error( 4, "В файле MO_DR01M.DBF не найдена ссылка на данный реестр" )
    Else
      arr := {} ; k := 0
      For i := 1 To 12
        Select REES
        Locate for &( "rm->reestr" + StrZero( i, 2 ) ) == rees->kod
        If Found()
          AAdd( arr, { Str( rees->nyear, 4 ) + "/" + StrZero( rees->NMONTH, 2 ), rees->name_xml, rees->kod_xml, rees->( RecNo() ) } )
          If Empty( rees->date_out )
            ++k
          Endif
        Endif
      Next i
      If Len( arr ) == 0
        func_error( 4, "Нечего записывать!" )
      Else
        s := "Количество файлов " + pname_f + " - " + lstr( Len( arr ) ) + ", записываются в первый раз - " + lstr( k ) + ":"
        For i := 1 To Len( arr )
          If i > 1
            s += ","
          Endif
          s += " " + AllTrim( arr[ i, 1 ] ) + " (" + AllTrim( arr[ i, 2 ] ) + szip + ")"
        Next
        perenos( t_arr, s, 74 )
        f_message( t_arr,, color1, color8 )
        If f_esc_enter( "записи файлов " + pname_f )
          Private p_var_manager := "copy_schet"
          s := manager( T_ROW, T_COL + 5, MaxRow() -2,, .t., 2, .f.,,, ) // "norton" для выбора каталога
          If !Empty( s )
            If Upper( s ) == Upper( goal_dir )
              func_error( 4, "Вы выбрали каталог, в котором уже записаны целевые файлы! Это недопустимо." )
            Else
              cFileProtokol := "prot_sch" + stxt
              StrFile( hb_eol() + Center( glob_mo[ _MO_SHORT_NAME ], 80 ) + hb_eol() + hb_eol(), cFileProtokol )
              smsg := "Файлы R01 записаны на: " + s + " (" + full_date( sys_date ) + "г. " + hour_min( Seconds() ) + ")"
              StrFile( Center( smsg, 80 ) + hb_eol(), cFileProtokol, .t. )
              k := 0
              For i := 1 To Len( arr )
                zip_file := AllTrim( arr[ i, 2 ] ) + szip
                If hb_FileExists( goal_dir + zip_file )
                  mywait( 'Копирование "' + zip_file + '" в каталог "' + s + '"' )
                  // copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
                  Copy File ( goal_dir + zip_file ) to ( s + zip_file )
                  // if hb_fileExists(hb_OemToAnsi(s)+zip_file)
                  If hb_FileExists( s + zip_file )
                    ++k
                    rees->( dbGoto( arr[ i, 4 ] ) )
                    smsg := lstr( i ) + ". Пакет " + pname_f + " № " + lstr( rees->nn ) + ;
                      " от " + date_8( mdate ) + "г. (отч.период " + ;
                      lstr( rees->nyear ) + "/" + StrZero( rees->NMONTH, 2 ) + ;
                      ") " + AllTrim( rees->name_xml ) + szip
                    StrFile( hb_eol() + smsg + hb_eol(), cFileProtokol, .t. )
                    smsg := "   количество пациентов - " + lstr( rees->kol )
                    StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                    rees->( g_rlock( forever ) )
                    rees->DATE_OUT := sys_date
                    If rees->NUMB_OUT < 99
                      rees->NUMB_OUT++
                    Endif
                    //
                    mo_xml->( dbGoto( arr[ i, 3 ] ) )
                    mo_xml->( g_rlock( forever ) )
                    mo_xml->DREAD := sys_date
                    mo_xml->TREAD := hour_min( Seconds() )
                  Else
                    smsg := "! Ошибка записи файла " + s + zip_file
                    func_error( 4, smsg )
                    StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                  Endif
                Else
                  smsg := "! Не обнаружен файл " + goal_dir + zip_file
                  func_error( 4, smsg )
                  StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                Endif
              Next i
              Unlock
              Commit
              viewtext( cFileProtokol,,,, .t.,,, 2 )
            Endif
          Endif
        Endif
      Endif
    Endif
    rm->( dbCloseArea() )
    Select REES
    Goto ( rec )
    ret := 0
  Case nKey == K_F3
    f3_view_r01( oBrow )
    ret := 0
  Case nKey == K_CTRL_F12
    ret := delete_reestr_r02( rees->( RecNo() ), AllTrim( rees->NAME_XML ) )
    Close databases
    g_use( dir_server + "mo_xml",, "MO_XML" )
    g_use( dir_server + "mo_dr01", cur_dir + "tmp_rees", "REES" )
    Goto ( rec )
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret

// 14.12.17
Function f3_view_r01( oBrow )

  Static si := 1
  Local i, r := Row(), r1, r2, buf := save_maxrow(), fl, s, ;
    mm_func := { -99 }, ;
    mm_menu := { "Список ~всех пациентов из R01" }

  mywait()
  Select MO_XML
  Index On FNAME to ( cur_dir + "tmp_xml" ) ;
    For reestr == rees->kod .and. tip_in == ptip_f + 1 .and. Empty( TIP_OUT ) .and. DToS( dfile ) > "20221201"
  Go Top
  Do While !Eof()
    AAdd( mm_func, -1 )
    AAdd( mm_menu, "1-установлена страх.принадлежность, подтверждено прикрепление к МО" )
    AAdd( mm_func, -2 )
    AAdd( mm_menu, "2-присутствуют ошибки технологического контроля" )
    AAdd( mm_func, -3 )
    AAdd( mm_menu, "3-не установлена страховая принадлежность" )
    AAdd( mm_func, -4 )
    AAdd( mm_menu, "4-не установлена страх.принадлежность, не подтверждено прикрепление к МО" )
    s := "Протокол чтения " + RTrim( mo_xml->FNAME ) + " прочитан " + date_8( mo_xml->DWORK )
    If Empty( mo_xml->TWORK2 )
      s += "-ПРОЦЕСС НЕ ЗАВЕРШЁН"
    Else
      s += " в " + mo_xml->TWORK1
    Endif
    AAdd( mm_func, mo_xml->kod )
    AAdd( mm_menu, s )
    Skip
  Enddo
  Select MO_XML
  Set Index To
  If r <= 12
    r1 := r + 1 ; r2 := r1 + Len( mm_menu ) + 1
  Else
    r2 := r - 1 ; r1 := r2 - Len( mm_menu ) -1
  Endif
  rest_box( buf )
  If Len( mm_menu ) == 1
    i := 1
    si := i
    If mm_func[ i ] < 0
      f31_view_r01( Abs( mm_func[ i ] ), mm_menu[ i ] )
    Endif
  Elseif ( i := popup_prompt( r1, 10, si, mm_menu,,, color5 ) ) > 0
    si := i
    If mm_func[ i ] < 0
      f31_view_r01( Abs( mm_func[ i ] ), mm_menu[ i ] )
    Else
      mo_xml->( dbGoto( mm_func[ i ] ) )
      viewtext( devide_into_pages( dir_server + dir_XML_TF + cslash + AllTrim( mo_xml->FNAME ) + stxt, 60, 80 ),,,, .t.,,, 2 )
    Endif
  Endif
  Select REES

  Return Nil

// 17.08.23
Function f31_view_r01( reg, s )

  Local fl := .t., buf := save_maxrow(), k := 0, n_file := pname_f + "_SPIS" + stxt, tt := " "

  mywait()
  // arr_title := {"────┬───┬───────┬───────────────────────────────────────────┬──────────┬─────────────────────────────────────────┬──────────────────",;
  // " NN │У/к│  Код  │               Ф.И.О.                      │  Дата р. │                   Адрес                 │                  ",;
  // "────┴───┴───────┴───────────────────────────────────────────┴──────────┴─────────────────────────────────────────┴──────────────────"}
  arr_title := { "─────┬───────────────────────────────────────────┬──────────┬─────────────────────────────────────────┬──────────────────", ;
    "  NN │               Ф.И.О.                      │  Дата р. │                   Адрес                 │                  ", ;
    "─────┴───────────────────────────────────────────┴──────────┴─────────────────────────────────────────┴──────────────────" }
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Список пациентов файла " + AllTrim( rees->NAME_XML ) + " от " + date_8( rees->dschet ), 120 ) )
  If reg == 99
    s := "все пациенты"
  Endif
  If reg == 98
    s := "пациенты без ошибок"
  Endif
  add_string( Center( "[ " + s + " ]", 120 ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  // создаем для отчета
  dbCreate( cur_dir + "_r01", { { "nyh", "C", 2, 0 }, ;
    { "kod", "C", 7, 0 }, ;
    { "fio", "C", 50, 0 }, ;
    { "date_r", "C", 10, 0 }, ;
    { "adres", "C", 50, 0 }, ;
    { "tip", "C", 7, 0 }, ;
    { "mes", "C", 7, 0 } } )
  Use ( cur_dir + "_r01" ) new
  //
  r_use( dir_server + "kartotek",, "KART" )
  r_use( dir_server + "mo_dr01k",, "RHUM" )
  Set Relation To kod_k into KART
  Index On Str( rhum->R01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For reestr == rees->kod
  Go Top
  Do While !Eof()
    If reg == 1 // 98
      If rhum->OPLATA == 1
        ++k
        s := Str( rhum->R01_ZAP, 4 ) + ". "
        If Empty( kart->fio )
          s += "удалён дубликат в картотеке (код=" + lstr( kod_k ) + ")"
        Else
          If is_uchastok == 1
            tt := PadR( lstr( kart->kod_vu ), 7 )
          Elseif is_uchastok == 2
            tt := PadR( lstr( kart->kod ), 7 )
          Else
            tt := PadR( lstr( kart->kod ), 7 )
          Endif
          s += PadR( lstr( kart->uchast ), 2 ) + " " + tt + " " + PadR( Upper( kart->fio ), 43 ) + " " + full_date( kart->date_r ) + " "
        Endif
        s += PadR( kart->adres, 40 ) + " (" + iif( rhum->tip == 1, "ДИСП", "проф." ) + ") " + Str( rhum->n_m, 2 ) + "мес."
        Select _R01
        Append Blank
        _r01->nyh    := PadR( lstr( kart->uchast ), 2 )
        _r01->kod    := tt
        _r01->fio    := PadR( Upper( kart->fio ), 50 )
        _r01->date_r := full_date( kart->date_r )
        _r01->adres  := PadR( kart->adres, 50 )
        _r01->tip    := iif( rhum->tip == 1, "ДИСП", "проф." )
        _r01->mes    := Str( rhum->n_m, 2 ) + "мес."
        Select RHUM
        If verify_ff( 60, .t., 120 )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s )
      Endif
    Elseif iif( reg == 99, .t., rhum->OPLATA == reg )
      ++k
      s := Str( rhum->R01_ZAP, 4 ) + ". "
      If Empty( kart->fio )
        s += "удалён дубликат в картотеке (код=" + lstr( kod_k ) + ")"
      Else
        s += PadR( Upper( kart->fio ), 43 ) + " " + full_date( kart->date_r )
      Endif
      s += " (" + iif( rhum->tip == 1, "ДИСП", "проф." ) + ") " + Str( rhum->n_m, 2 ) + "мес."
      If verify_ff( 60, .t., 120 )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( s )
      Select _R01
      Append Blank
      _r01->nyh    := PadR( lstr( kart->uchast ), 2 )
      _r01->kod    := tt
      _r01->fio    := PadR( Upper( kart->fio ), 50 )
      _r01->date_r := full_date( kart->date_r )
      _r01->adres  := PadR( kart->adres, 50 )
      _r01->tip    := iif( rhum->tip == 1, "ДИСП", "проф." )
      _r01->mes    := Str( rhum->n_m, 2 ) + "мес."
      Select RHUM
    Endif
    Select RHUM
    Skip
  Enddo
  add_string( "" )
  add_string( "Всего " + lstr( k ) + " чел." )
  kart->( dbCloseArea() )
  rhum->( dbCloseArea() )
  _r01->( dbCloseArea() )
  FClose( fp )
  rest_box( buf )
  viewtext( n_file,,,, .t.,,, 6 )
  n_file := "_dispr01"
  Copy File ( cur_dir + "_r01" + sdbf ) to ( cur_dir + n_file + sdbf )
  n_message( { "В каталоге " + Upper( cur_dir ), ;
    "создан файл " + Upper( n_file + sdbf ), ;
    "со сведениями о планах диспансеризации пациентов." },, ;
    cColorStMsg, cColorStMsg,,, cColorSt2Msg )

  Return Nil

// 18.12.19
Function f32_view_r01()

  Local fl := .t., buf := save_maxrow(), k := 0, skol[ 5, 3 ], ames[ 12, 5, 3 ], mrec := 2, n_file := "r01_itog" + stxt
  Private par := .f.

  afillall( skol, 0 )
  afillall( ames, 0 )
  mywait()
  r_use( dir_server + "mo_dr05p",, "R05p" )
  Goto ( mrec )
  skol[ 1, 1 ] := r05p->KOL1
  skol[ 2, 1 ] := r05p->KOL2
  skol[ 3, 1 ] := r05p->KOL11
  skol[ 4, 1 ] := r05p->KOL12
  skol[ 5, 1 ] := r05p->KOL13
  If par
    skol[ 1, 1 ] -= skol[ 3, 1 ]
    skol[ 3, 1 ] -= skol[ 4, 1 ]
    skol[ 3, 1 ] -= skol[ 5, 1 ]
  Endif
  For i := 1 To 12
    For j := 1 To 2
      ames[ i, j, 1 ] := &( "r05p->kol" + lstr( j ) + "_" + StrZero( i, 2 ) )
    Next
    For j := 1 To 3
      ames[ i, j + 2, 1 ] := &( "r05p->kol1" + lstr( j ) + "_" + StrZero( i, 2 ) )
    Next
    If par
      ames[ i, 1, 1 ] -= ames[ i, 3, 1 ]
      ames[ i, 3, 1 ] -= ames[ i, 4, 1 ]
      ames[ i, 3, 1 ] -= ames[ i, 5, 1 ]
    Endif
  Next
  r05p->( dbCloseArea() )
  r_use( dir_server + "mo_dr01k",, "RHUM" )
  Index On Str( reestr, 6 ) + Str( rhum->R01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" )
  r_use( dir_server + "mo_dr01m",, "RM" )
  Go Top
  Do While !Eof()
    For i := 1 To 12
      If ( mkod_reestr := &( "rm->reestr" + StrZero( i, 2 ) ) ) > 0
        Select RHUM
        find ( Str( mkod_reestr, 6 ) )
        Do While rhum->reestr == mkod_reestr .and. !Eof()
          If rhum->OPLATA < 2
            j := rhum->tip
            j1 := rhum->tip1
            If Between( j1, 1, 3 )
              ames[ i, j1 + 2, 2 ] ++
            Elseif Between( j, 1, 2 )
              ames[ i, j, 2 ] ++
            Endif
            If rhum->OPLATA == 1
              If Between( j1, 1, 3 )
                ames[ i, j1 + 2, 3 ] ++
              Elseif Between( j, 1, 2 )
                ames[ i, j, 3 ] ++
              Endif
            Endif
          Endif
          Select RHUM
          Skip
        Enddo
      Endif
    Next
    Select RM
    Skip
  Enddo
  rm->( dbCloseArea() )
  rhum->( dbCloseArea() )
  If !par
    For i := 1 To 12
      For k := 2 To 3
        ames[ i, 3, k ] += ames[ i, 4, k ]
        ames[ i, 3, k ] += ames[ i, 5, k ]
        ames[ i, 1, k ] += ames[ i, 3, k ]
      Next
      If i < 4
        For j := 1 To 5
          ames[ i, j, 2 ] := ames[ i, j, 1 ]
          ames[ i, j, 3 ] := ames[ i, j, 1 ]
        Next
      Endif
    Next
  Endif
  //
  fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Общая информация (R01)", 80 ) )
  add_string( "" )
  mmt := { "диспансеризация", "профосмотр", "дисп.пенсионеры", "дисп.65 лет", "дисп.66 и старше" }
  For i := 1 To 12
    If verify_ff( 55, .t., 80 ) .or. i == 1
      add_string( "──────────────────────────┬─────────────┬─────────────┬────────────┬────────────" )
      add_string( "     месяц                │  по плану   │  отправлено │  в ТФОМСе  │ расхождение" )
      add_string( "──────────────────────────┴─────────────┴─────────────┴────────────┴────────────" )
    Endif
    n := 26
    add_string( PadR( mm_month[ i ], n ) )
    For j := 1 To 5
      add_string( PadL( mmt[ j ], n ) + put_val( ames[ i, j, 1 ], 11 ) + ;
        put_val( ames[ i, j, 2 ], 14 ) + ;
        put_val( ames[ i, j, 3 ], 13 ) + ;
        put_val( ames[ i, j, 1 ] -ames[ i, j, 3 ], 12 ) )
      skol[ j, 2 ] += ames[ i, j, 2 ]
      skol[ j, 3 ] += ames[ i, j, 3 ]
    Next
  Next
  add_string( PadR( "Итого:", n ) )
  For j := 1 To 5
    add_string( PadL( mmt[ j ], n ) + put_val( skol[ j, 1 ], 11 ) + ;
      put_val( skol[ j, 2 ], 14 ) + ;
      put_val( skol[ j, 3 ], 13 ) + ;
      put_val( skol[ j, 1 ] -skol[ j, 3 ], 12 ) )
  Next
  FClose( fp )
  rest_box( buf )
  viewtext( n_file,,,, .t.,,, 2 )

  Return Nil

// 17.12.19 зачитать R01 во временные файлы
Function reestr_r01_tmpfile( oXmlDoc, aerr, mname_xml )

  Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()

  Default aerr TO {}, mname_xml To ""
  stat_msg( "Распаковка/чтение/анализ файла " + mname_xml )
  dbCreate( cur_dir + "tmp4file", { ;
    { "ZAP",        "N",  6, 0 }, ;
    { "IDPAC",      "C", 36, 0 }, ;
    { "SURNAME",    "C", 40, 0 }, ;
    { "NAME",       "C", 40, 0 }, ;
    { "PATRONYMIC", "C", 40, 0 }, ;
    { "BIRTHDAY",   "C", 10, 0 }, ;
    { "SEX",        "C",  1, 0 }, ;
    { "SS",         "C", 14, 0 }, ;
    { "TYPE_P",     "C",  1, 0 }, ;
    { "SER_P",      "C", 10, 0 }, ;
    { "NUM_P",      "C", 20, 0 }, ;
    { "ENP",        "C", 16, 0 }, ;
    { "DOCTYPE",    "C",  2, 0 }, ;
    { "DOCSER",     "C", 10, 0 }, ;
    { "DOCNUM",     "C", 20, 0 }, ;
    { "MR",         "C", 100, 0 }, ;
    { "CATEGORY",   "C",  2, 0 }, ;
    { "T_PR",       "C",  1, 0 }, ;
    { "TEL_F",      "C", 13, 0 }, ;
    { "TEL_M",      "C", 13, 0 }, ;
    { "SUBJ",       "C",  5, 0 }, ;
    { "UL",         "C", 120, 0 }, ;
    { "kod_k",      "N",  7, 0 }, ;
    { "N_M",        "N",  2, 0 }, ;
    { "tip",        "N",  1, 0 }, ;
    { "OPLATA",     "N",  1, 0 };
    } )
  Use ( cur_dir + "tmp4file" ) New Alias TMP2
  For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
    @ MaxRow(), 1 Say PadR( lstr( j ), 6 ) Color cColorSt2Msg
    oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
    If "PERSONS" == oXmlNode:title
      Select TMP2
      Append Blank
      tmp2->ZAP       := Val( mo_read_xml_stroke( oXmlNode, "ZAP", aerr ) )
      tmp2->IDPAC     :=     mo_read_xml_stroke( oXmlNode, "IDPAC", aerr, .f. )
      tmp2->SURNAME   :=     mo_read_xml_stroke( oXmlNode, "SURNAME", aerr, .f. )
      tmp2->NAME      :=     mo_read_xml_stroke( oXmlNode, "NAME", aerr, .f. )
      tmp2->PATRONYMIC :=     mo_read_xml_stroke( oXmlNode, "PATRONYMIC", aerr, .f. )
      tmp2->BIRTHDAY  :=     mo_read_xml_stroke( oXmlNode, "BIRTHDAY", aerr, .f. )
      tmp2->SEX       :=     mo_read_xml_stroke( oXmlNode, "SEX", aerr, .f. )
      tmp2->SS        :=     mo_read_xml_stroke( oXmlNode, "SS", aerr, .f. )
      tmp2->TYPE_P    :=     mo_read_xml_stroke( oXmlNode, "TYPE_P", aerr, .f. )
      tmp2->SER_P     :=     mo_read_xml_stroke( oXmlNode, "SER_P", aerr, .f. )
      tmp2->NUM_P     :=     mo_read_xml_stroke( oXmlNode, "NUM_P", aerr, .f. )
      tmp2->ENP       :=     mo_read_xml_stroke( oXmlNode, "ENP", aerr, .f. )
      tmp2->DOCTYPE   :=     mo_read_xml_stroke( oXmlNode, "DOCTYPE", aerr, .f. )
      tmp2->DOCSER    :=     mo_read_xml_stroke( oXmlNode, "DOCSER", aerr, .f. )
      tmp2->DOCNUM    :=     mo_read_xml_stroke( oXmlNode, "DOCNUM", aerr, .f. )
      tmp2->MR        :=     mo_read_xml_stroke( oXmlNode, "MR", aerr, .f. )
      tmp2->CATEGORY  :=     mo_read_xml_stroke( oXmlNode, "CATEGORY", aerr, .f. )
      tmp2->T_PR      :=     mo_read_xml_stroke( oXmlNode, "T_PR", aerr, .f. )
      If ( oNode1 := oXmlNode:find( "CONTACTS" ) ) != NIL
        tmp2->TEL_F   :=     mo_read_xml_stroke( oNode1, "TEL_F", aerr, .f. )
        tmp2->TEL_M   :=     mo_read_xml_stroke( oNode1, "TEL_M", aerr, .f. )
        If ( oNode2 := oNode1:find( "ADDRESS" ) ) != NIL
          tmp2->SUBJ  :=     mo_read_xml_stroke( oNode2, "SUBJ", aerr, .f. )
          tmp2->UL    :=     mo_read_xml_stroke( oNode2, "UL", aerr, .f. )
        Endif
      Endif
    Endif
  Next j
  tmp2->( dbCloseArea() )
  rest_box( buf )

  Return Nil

// 14.12.17 зачитать R02 во временные файлы
Function reestr_r02_tmpfile( oXmlDoc, aerr, mname_xml )

  Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()

  Default aerr TO {}, mname_xml To ""
  stat_msg( "Распаковка/чтение/анализ файла " + mname_xml )
  dbCreate( cur_dir + "tmp1file", { ;
    { "_VERSION",   "C",  5, 0 }, ;
    { "_DATE_F",    "D",  8, 0 }, ;
    { "_NAME_F",    "C", 26, 0 }, ;
    { "_NAME_FE",   "C", 26, 0 }, ;
    { "KOL",        "N",  6, 0 }, ; // количество пациентов в реестре/файле
  { "KOL_ERR",    "N",  6, 0 };  // количество пациентов с ошибками в реестре
  } )
  dbCreate( cur_dir + "tmp2file", { ;
    { "_N_ZAP",     "N",  6, 0 }, ;
    { "_SMO",       "C",  5, 0 }, ;
    { "_ENP",       "C", 16, 0 }, ;
    { "_OPLATA",    "N",  1, 0 };
    } )
  dbCreate( cur_dir + "tmp3file", { ;
    { "_N_ZAP",     "N",  6, 0 }, ;
    { "_ERROR",     "N",  3, 0 };
    } )
  Use ( cur_dir + "tmp1file" ) New Alias TMP1
  Append Blank
  Use ( cur_dir + "tmp2file" ) New Alias TMP2
  Use ( cur_dir + "tmp3file" ) New Alias TMP3
  For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
    @ MaxRow(), 1 Say PadR( lstr( j ), 6 ) Color cColorSt2Msg
    oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
    Do Case
    Case "ZGLV" == oXmlNode:title
      tmp1->_VERSION :=          mo_read_xml_stroke( oXmlNode, "VERSION", aerr )
      tmp1->_DATE_F  := xml2date( mo_read_xml_stroke( oXmlNode, "DATE_F", aerr ) )
      tmp1->_NAME_F  :=          mo_read_xml_stroke( oXmlNode, "NAME_F", aerr )
      tmp1->_NAME_FE :=          mo_read_xml_stroke( oXmlNode, "NAME_FE", aerr )
    Case "ERRS" == oXmlNode:title
      Select TMP3
      Append Blank
      tmp3->_N_ZAP := 0
      tmp3->_ERROR := Val( mo_read_xml_tag( oXmlNode, aerr ) )
    Case "ZAPS" == oXmlNode:title
      Select TMP2
      Append Blank
      tmp2->_N_ZAP  := Val( mo_read_xml_stroke( oXmlNode, "ZAP", aerr ) )
      tmp2->_ENP    :=     mo_read_xml_stroke( oXmlNode, "ENP", aerr, .f. )
      tmp2->_SMO    :=     mo_read_xml_stroke( oXmlNode, "SMO", aerr, .f. )
      tmp2->_OPLATA := Val( mo_read_xml_stroke( oXmlNode, "RESULT", aerr ) )
      If tmp2->_OPLATA > 1 .and. ( oNode1 := oXmlNode:find( "ERRORS" ) ) != NIL
        _ar := mo_read_xml_array( oNode1, "ERROR" )
        For j1 := 1 To Len( _ar )
          Select TMP3
          Append Blank
          tmp3->_N_ZAP := tmp2->_N_ZAP
          tmp3->_ERROR := Val( _ar[ j1 ] )
        Next
      Endif
    Endcase
  Next j
  Commit
  rest_box( buf )

  Return Nil

// 26.12.22 прочитать и "разнести" по базам данных файл R02
Function read_xml_file_r02( arr_XML_info, aerr, /*@*/current_i2,tip_f)

  Local count_in_schet := 0, bSaveHandler, ii1, ii2, i, j, k, t_arr[ 2 ], ldate_R02, s, err_file := .f.

  Default tip_f To _XML_FILE_R02
  mkod_reestr := arr_XML_info[ 7 ]
  Use ( cur_dir + "tmp1file" ) New Alias TMP1
  ldate_R02 := tmp1->_DATE_F
  r_use( dir_server + "mo_dr01",, "REES" )
  Goto ( arr_XML_info[ 7 ] )
  StrFile( "Обрабатывается ответ ТФОМС на информационный пакет " + AllTrim( rees->NAME_XML ) + sxml + hb_eol() + ;
    "за " + lstr( rees->NMONTH ) + " мес. " + lstr( rees->NYEAR ) + " года от " + date_8( rees->DSCHET ) + ;
    "г. (" + lstr( rees->kol ) + " чел.)" + hb_eol() + hb_eol(), cFileProtokol, .t. )
  //
  r_use( dir_server + "mo_dr01k",, "RHUM" )
  Index On Str( R01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For REESTR == mkod_reestr
  Use ( cur_dir + "tmp2file" ) New Alias TMP2
  i := 0 ; k := LastRec()
  // сначала проверка
  ii1 := ii2 := 0
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say Str( ++i / k * 100, 6, 2 ) + "%" Color cColorWait
    If tmp2->_OPLATA == 1
      ++ii1
      If !Empty( tmp2->_SMO ) .and. AScan( glob_arr_smo, {| x| x[ 2 ] == Int( Val( tmp2->_SMO ) ) } ) == 0
        AAdd( aerr, "Некорректное значение атрибута SMO: " + tmp2->_SMO )
      Endif
    Elseif Between( tmp2->_OPLATA, 2, 4 )
      ++ii2
    Else
      AAdd( aerr, "Некорректное значение атрибута RESULT: " + lstr( tmp2->_OPLATA ) )
    Endif
    Select RHUM
    find ( Str( tmp2->_N_ZAP, 6 ) )
    If !Found()
      AAdd( aerr, "Не найден случай с N_ZAP = " + lstr( tmp2->_N_ZAP ) )
    Endif
    Select TMP2
    Skip
  Enddo
  tmp1->kol := ii1
  tmp1->kol_err := ii2
  If Empty( ii2 )
    Use ( cur_dir + "tmp3file" ) New Alias TMP3
    Index On Str( _n_zap, 6 ) to ( cur_dir + "tmp3" )
    find ( Str( 0, 6 ) )
    err_file := Found() // ошибки на уровне файла
  Endif
  Close databases
  If Empty( aerr ) // если проверка прошла успешно
    // запишем принимаемый файл (реестр СП)
    // chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
    chip_copy_zipxml( full_zip, dir_server + dir_XML_TF )
    g_use( dir_server + "mo_xml",, "MO_XML" )
    addrecn()
    mo_xml->KOD := RecNo()
    mo_xml->KOD := RecNo()
    mo_xml->FNAME := cReadFile
    mo_xml->DFILE := ldate_R02
    mo_xml->TFILE := ""
    mo_xml->DREAD := sys_date
    mo_xml->TREAD := hour_min( Seconds() )
    mo_xml->TIP_IN := tip_f // тип принимаемого файла
    mo_xml->DWORK  := sys_date
    mo_xml->TWORK1 := cTimeBegin
    mo_xml->REESTR := mkod_reestr
    mo_xml->KOL1 := ii1
    mo_xml->KOL2 := ii2
    //
    mXML_REESTR := mo_xml->KOD
    Use
    g_use( dir_server + "mo_dr01",, "REES" )
    Goto ( mkod_reestr )
    g_rlock( forever )
    rees->answer := 1
    If ii2 > 0
      rees->kol_err := ii2
    Elseif err_file
      rees->kol_err := -1
    Endif
    Use
    If ii2 > 0 .or. err_file
      Use ( cur_dir + "tmp3file" ) New Alias TMP3
      Index On Str( _n_zap, 6 ) to ( cur_dir + "tmp3" )
      g_use( dir_server + "mo_dr01e",, "REFR" )
      Index On Str( REESTR, 6 ) + Str( R01_ZAP, 6 ) to ( cur_dir + "tmp_r01e" )
      If err_file
        Select REFR
        Do While .t.
          find ( Str( mkod_reestr, 6 ) + Str( 0, 6 ) )
          If !Found() ; exit ; Endif
          deleterec( .t. )
        Enddo
        StrFile( "Ошибки на уровне файла:" + hb_eol(), cFileProtokol, .t. )
        Select TMP3
        find ( Str( 0, 6 ) )
        Do While tmp3->_N_ZAP == 0 .and. !Eof()
          Select REFR
          addrec( 6 )
          refr->reestr := mkod_reestr
          refr->R01_ZAP := 0
          refr->KOD_ERR := tmp3->_ERROR
          StrFile( Space( 8 ) + geterror_t012( tmp3->_ERROR ) + hb_eol(), cFileProtokol, .t. )
          Select TMP3
          Skip
        Enddo
      Endif
      tmp3->( dbCloseArea() )
    Endif
    g_use( dir_server + "kartote2",, "KART2" )
    g_use( dir_server + "kartote_",, "KART_" )
    g_use( dir_server + "kartotek",, "KART" )
    g_use( dir_server + "mo_dr01k",, "RHUM" )
    Index On Str( R01_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For REESTR == mkod_reestr
    Use ( cur_dir + "tmp3file" ) New Alias TMP3
    Index On Str( _n_zap, 6 ) to ( cur_dir + "tmp3" )
    Use ( cur_dir + "tmp2file" ) New Alias TMP2
    Index On Str( _n_zap, 6 ) to ( cur_dir + "tmp2" )
    count_in_schet := LastRec() ; current_i2 := 0
    i := 0
    Go Top
    Do While !Eof()
      @ MaxRow(), 0 Say Str( ++i / k * 100, 6, 2 ) + "%" Color cColorWait
      Select RHUM
      find ( Str( tmp2->_N_ZAP, 6 ) )
      g_rlock( forever )
      rhum->OPLATA := tmp2->_OPLATA
      If !Empty( tmp2->_enp )
        Select KART2
        Do While kart2->( LastRec() ) < rhum->kod_k
          Append Blank
        Enddo
        Goto ( rhum->kod_k )
        If Len( AllTrim( kart2->kod_mis ) ) != 16
          g_rlock( forever )
          kart2->kod_mis := tmp2->_enp
          dbUnlock()
        Endif
      Endif
      If tmp2->_OPLATA > 1
        --count_in_schet    // не включается в счет,
        If current_i2 == 0
          StrFile( Space( 10 ) + "Список случаев с ошибками:" + hb_eol() + hb_eol(), cFileProtokol, .t. )
        Endif
        ++current_i2
        kart->( dbGoto( rhum->kod_k ) )
        If Empty( kart->fio )
          StrFile( Str( tmp2->_N_ZAP, 6 ) + ". Пациент с кодом по картотеке " + lstr( kart->( RecNo() ) ) + hb_eol(), cFileProtokol, .t. )
        Else
          StrFile( Str( tmp2->_N_ZAP, 6 ) + ". " + AllTrim( kart->fio ) + ", " + full_date( kart->date_r ) + hb_eol(), cFileProtokol, .t. )
        Endif
        Select REFR
        Do While .t.
          find ( Str( mkod_reestr, 6 ) + Str( tmp2->_N_ZAP, 6 ) )
          If !Found() ; exit ; Endif
          deleterec( .t. )
        Enddo
        Select TMP3
        find ( Str( tmp2->_N_ZAP, 6 ) )
        Do While tmp2->_N_ZAP == tmp3->_N_ZAP .and. !Eof()
          Select REFR
          addrec( 6 )
          refr->reestr := mkod_reestr
          refr->R01_ZAP := tmp2->_N_ZAP
          refr->KOD_ERR := tmp3->_ERROR
          StrFile( Space( 8 ) + geterror_t012( tmp3->_ERROR ) + hb_eol(), cFileProtokol, .t. )
          Select TMP3
          Skip
        Enddo
        If tmp2->_OPLATA == 3
          StrFile( Space( 8 ) + "не установлена страховая принадлежность" + hb_eol(), cFileProtokol, .t. )
        Elseif tmp2->_OPLATA == 4
          StrFile( Space( 8 ) + "не установлена страховая принадлежность, не подтверждено прикрепление к МО" + hb_eol(), cFileProtokol, .t. )
        Endif
      Endif
      Unlock All
      Select TMP2
      If RecNo() % 1000 == 0
        Commit
      Endif
      Skip
    Enddo
  Endif
  Close databases

  Return count_in_schet

// 09.02.20 аннулировать чтение недочитанного реестра R02
Function delete_reestr_r02( mkod_reestr, mname_reestr )

  Local i, s, r := Row(), r1, r2, buf := save_maxrow(), ;
    mm_menu := {}, mm_func := {}, mm_flag := {}, mreestr_sp_tk, ;
    arr_f, cFile, oXmlDoc, aerr := {}, is_allow_delete, ;
    cFileProtokol := "tmp" + stxt

  mywait()
  Select MO_XML
  Index On FNAME to ( cur_dir + "tmp_xml" ) ;
    For reestr == mkod_reestr .and. tip_in == ptip_f + 1 .and. TIP_OUT == 0
  Go Top
  Do While !Eof()
    AAdd( mm_func, mo_xml->kod )
    s := "Протокол чтения " + RTrim( mo_xml->FNAME ) + " прочитан " + date_8( mo_xml->DWORK )
    If Empty( mo_xml->TWORK2 )
      AAdd( mm_flag, .t. )
      s += "-ПРОЦЕСС НЕ ЗАВЕРШЁН"
    Else
      AAdd( mm_flag, .f. )
      s += " в " + mo_xml->TWORK1
    Endif
    AAdd( mm_menu, s )
    Skip
  Enddo
  Select MO_XML
  Set Index To
  rest_box( buf )
  If Len( mm_menu ) == 0
    func_error( 4, "Не было чтения файла P" + pname_f )
    Return 0
  Endif
  If r <= 18
    r1 := r + 1 ; r2 := r1 + Len( mm_menu ) + 1
  Else
    r2 := r - 1 ; r1 := r2 - Len( mm_menu ) -1
  Endif
  If ( i := popup_prompt( r1, 10, 1, mm_menu,,, color5 ) ) > 0
    is_allow_delete := mm_flag[ i ]
    mreestr_sp_tk := mm_func[ i ]
    Select MO_XML
    Goto ( mreestr_sp_tk )
    cFile := AllTrim( mo_xml->FNAME )
    mtip_in := mo_xml->TIP_IN
    Close databases
    If !is_allow_delete
      func_error( 4, "Файл " + cFile + sxml + " корректно прочитан. Аннулирование запрещено!" )
      Return 0
    Endif
    If ( arr_f := extract_zip_xml( dir_server + dir_XML_TF, cFile + szip ) ) != NIL
      cFile += sxml
      // читаем файл в память
      oXmlDoc := hxmldoc():read( _tmp_dir1 + cFile )
      If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
        func_error( 4, "Ошибка в чтении файла " + cFile )
      Else // читаем и записываем XML-файл во временные TMP-файлы
        reestr_r02_tmpfile( oXmlDoc, aerr, cFile )
        If !Empty( aerr )
          ins_array( aerr, 1, "" )
          ins_array( aerr, 1, Center( "Ошибки в чтении файла " + cFile, 80 ) )
          AEval( aerr, {| x| StrFile( x + hb_eol(), cFileProtokol, .t. ) } )
          viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
          Delete File ( cFileProtokol )
        Else
          If !is_allow_delete .and. involved_password( 2, cFile, "аннулирования чтения файла P" + pname_f )
            is_allow_delete := .t.
          Endif
          If is_allow_delete
            Close databases
            g_use( dir_server + "mo_dr01",, "REES" )
            Goto ( mkod_reestr )
            Use ( cur_dir + "tmp1file" ) New Alias TMP1
            Use ( cur_dir + "tmp2file" ) New Alias TMP2
            arr := {}
            AAdd( arr, "Информационный пакет " + AllTrim( rees->NAME_XML ) + sxml + " от " + date_8( rees->DSCHET ) + "г." )
            AAdd( arr, "за " + lstr( rees->NMONTH ) + " мес. " + lstr( rees->NYEAR ) + ;
              " года, кол-во пациентов " + lstr( rees->kol ) + " чел." )
            AAdd( arr, "" )
            g_use( dir_server + "mo_xml",, "MO_XML" )
            Goto ( mreestr_sp_tk )
            AAdd( arr, "Аннулируется файл ответа " + cFile + " от " + date_8( mo_xml->DFILE ) + "г." )
            AAdd( arr, "После подтверждения аннулирования все последствия чтения данного" )
            AAdd( arr, "файла P" + pname_f + ", а также сам файл P" + pname_f + ", будут удалены." )
            f_message( arr,, cColorSt2Msg, cColorSt1Msg )
            s := "Подтвердите аннулирование файла P" + pname_f
            stat_msg( s ) ; mybell( 1 )
            is_allow_delete := .f.
            If f_esc_enter( "аннулирования", .t. )
              stat_msg( s + " ещё раз." ) ; mybell( 3 )
              If f_esc_enter( "аннулирования", .t. )
                mywait()
                is_allow_delete := .t.
              Endif
            Endif
            Close databases
          Endif
          If is_allow_delete
            f2_delete_reestr_r02( mkod_reestr, mreestr_sp_tk )
            stat_msg( "Файл " + cFile + " успешно аннулирован. Можно прочитать ещё раз." ) ; mybell( 5 )
          Endif
        Endif
      Endif
    Endif
  Endif
  rest_box( buf )

  Return 0

// 09.02.20 аннулировать чтение реестра PR01(PR11)
Function f2_delete_reestr_r02( mkod_reestr, mreestr_sp_tk )

  g_use( dir_server + "mo_dr01e",, "REFR" )
  Index On Str( REESTR, 6 ) to ( cur_dir + "tmp_r01e" )
  Do While .t.
    find ( Str( mkod_reestr, 6 ) ) // удалим ошибки
    If !Found() ; exit ; Endif
    deleterec( .t. )
  Enddo
  g_use( dir_server + "mo_dr01k",, "RHUM" )
  Index On Str( REESTR, 6 ) to ( cur_dir + "tmp_rhum" )
  find ( Str( mkod_reestr, 6 ) )
  Do While rhum->reestr == mkod_reestr .and. !Eof()
    g_rlock( forever )
    rhum->OPLATA := 0 // обнулим поле оплаты
    Unlock
    Skip
  Enddo
  g_use( dir_server + "mo_dr01",, "REES" )
  Goto ( mkod_reestr )
  g_rlock( forever )
  rees->answer := 0
  rees->kol_err := 0
  g_use( dir_server + "mo_xml",, "MO_XML" )
  Goto ( mreestr_sp_tk )
  deleterec()
  Close databases

  Return Nil

// 28.12.21
Function need_delete_reestr_r01()

  Local fl := .f.

  If hb_user_curUser:isadmin()
    r_use( dir_server + "mo_dr01m",, "R01m" )
    Go Top
    Do While !Eof()
      If Empty( r01m->twork2 )
        fl := .t. ; Exit
      Endif
      Skip
    Enddo
    Use
  Endif

  Return fl

// 28.12.21
Function delete_reestr_r01()

  Local t_arr[ BR_LEN ], blk

  If ! hb_user_curUser:isadmin()
    Return func_error( 4, err_admin )
  Endif
  g_use( dir_server + "mo_dr01m",, "R01m" )
  Index On Descend( DToS( DWORK ) + TWORK1 ) to ( cur_dir + "tmp_dr01m" )
  Go Top
  If Eof()
    func_error( 4, "Не было создано файлов R01..." )
  Else
    t_arr[ BR_TOP ] := T_ROW
    t_arr[ BR_BOTTOM ] := MaxRow() -2
    t_arr[ BR_LEFT ] := 2
    t_arr[ BR_RIGHT ] := 77
    t_arr[ BR_COLOR ] := color0
    t_arr[ BR_TITUL ] := "Список созданных пакетов реестров R01"
    t_arr[ BR_TITUL_COLOR ] := "B/BG"
    t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', "N/BG,W+/N,B/BG,W+/B", .t. }
    blk := {|| iif( Empty( r01m->twork2 ), { 3, 4 }, { 1, 2 } ) }
    t_arr[ BR_COLUMN ] := { ;
      { "  Дата;создания", {|| date_8( r01m->dwork ) }, blk }, ;
      { "янв;арь", {|| iif( r01m->reestr01 > 0, "да ", "нет" ) }, blk }, ;
      { "фев;рал", {|| iif( r01m->reestr02 > 0, "да ", "нет" ) }, blk }, ;
      { "мар;т  ", {|| iif( r01m->reestr03 > 0, "да ", "нет" ) }, blk }, ;
      { "апр;ель", {|| iif( r01m->reestr04 > 0, "да ", "нет" ) }, blk }, ;
      { "май;   ", {|| iif( r01m->reestr05 > 0, "да ", "нет" ) }, blk }, ;
      { "июн;ь  ", {|| iif( r01m->reestr06 > 0, "да ", "нет" ) }, blk }, ;
      { "июл;ь  ", {|| iif( r01m->reestr07 > 0, "да ", "нет" ) }, blk }, ;
      { "авг;уст", {|| iif( r01m->reestr08 > 0, "да ", "нет" ) }, blk }, ;
      { "сен;тяб", {|| iif( r01m->reestr09 > 0, "да ", "нет" ) }, blk }, ;
      { "окт;ябр", {|| iif( r01m->reestr10 > 0, "да ", "нет" ) }, blk }, ;
      { "ноя;брь", {|| iif( r01m->reestr11 > 0, "да ", "нет" ) }, blk }, ;
      { "дек;абр", {|| iif( r01m->reestr12 > 0, "да ", "нет" ) }, blk }, ;
      { "Время;начала",    {|| r01m->twork1 }, blk }, ;
      { "Время;окончания", {|| PadR( iif( Empty( r01m->twork2 ), "НЕ ЗАВЕРШЕНО", r01m->twork2 ), 10 ) }, blk };
      }
    t_arr[ BR_EDIT ] := {| nk, ob| f1_delete_reestr_r01( nk, ob, "edit" ) }
    t_arr[ BR_FL_INDEX ] := .f.
    t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - выход;  ^<Enter>^ - аннулирование создания пакета реестров R01" ) }
    edit_browse( t_arr )
  Endif
  Close databases

  Return Nil

// 17.12.19
Function f1_delete_reestr_r01( nKey, oBrow, regim )

  Local ret := -1, rec := r01m->( RecNo() ), ir, fl := .t.

  If regim == "edit" .and. nKey == K_ENTER
    If Empty( r01m->twork2 )
      g_use( dir_server + "mo_dr01",, "REES" )
      For ir := 1 To 12
        mkod_reestr := &( "r01m->reestr" + StrZero( ir, 2 ) )
        If mkod_reestr > 0
          Select REES
          Goto ( mkod_reestr )
          If rees->tip == 1
            fl := func_error( 4, "Это файл R11. Операция запрещена!" )
            Exit
          Elseif rees->ANSWER == 1
            fl := func_error( 4, "Уже получен ответ PR01 за " + lstr( ir ) + "-й месяц. Операция запрещена!" )
            Exit
          Endif
        Endif
      Next
      REES->( dbCloseArea() )
      Select R01m
      If fl .and. f_esc_enter( "аннулирования R01" )
        mywait()
        g_use( dir_server + "mo_xml",, "MO_XML" )
        g_use( dir_server + "mo_dr00",, "TMP" )
        Index On Str( REESTR, 6 ) to ( cur_dir + "tmp_dr00" )
        g_use( dir_server + "mo_dr01k",, "RHUM" )
        Index On Str( REESTR, 6 ) to ( cur_dir + "tmp_rhum" )
        g_use( dir_server + "mo_dr01",, "REES" )
        For ir := 12 To 1 Step -1
          mkod_reestr := &( "r01m->reestr" + StrZero( ir, 2 ) )
          If mkod_reestr > 0
            Select REES
            Goto ( mkod_reestr )
            Select TMP
            Do While .t.
              find ( Str( mkod_reestr, 6 ) )
              If !Found() ; exit ; Endif
              g_rlock( forever )
              tmp->n_m := 0
              tmp->n_q := 0
              tmp->reestr := 0
              dbUnlock()
            Enddo
            Select RHUM
            Do While .t.
              find ( Str( mkod_reestr, 6 ) )
              If !Found() ; exit ; Endif
              deleterec( .t. )
            Enddo
            Select MO_XML
            Goto ( rees->KOD_XML )
            deleterec( .t. )
            Select REES
            deleterec( .t. )
            Select R01m
            g_rlock( forever )
            &( "r01m->reestr" + StrZero( ir, 2 ) ) := 0
            dbUnlockAll()
            dbCommitAll()
          Endif
        Next
        mo_xml->( dbCloseArea() )
        tmp->( dbCloseArea() )
        RHUM->( dbCloseArea() )
        REES->( dbCloseArea() )
        Select R01m
        deleterec()
        stat_msg( "Аннулирование завершено!" ) ; mybell( 2, OK )
        ret := 1
      Endif
    Else
      func_error( 4, "Процесс создания пакета реестров R01 завершён корректно. Операция запрещена!" )
    Endif
  Endif

  Return ret

// 14.12.23 проверить, есть ли не до конца обработанные операции с файлами R01...
Function find_unfinished_r01()

  Local fl := .t., fl1, skol := 0, mkol := 0, arr := {}, rec, fl_date := .t., vrem := 0
  Private sgod := 2024, mrec := 1

  If glob_mo[ _MO_IS_UCH ]
    If ( fl := verify_packet_r05( 2, arr ) )
      r_use( dir_server + "mo_dr05p",, "R05p" )
      Goto ( mrec )
      // skol := r05p->KOL1 + r05p->KOL2
      For i := 1 To 12
        vrem := 0
        For j := 1 To 2
          vrem += &( "r05p->kol" + lstr( j ) + "_" + StrZero( i, 2 ) )
        Next
        skol += vrem
      Next
      Select MO_XML
      Index On Str( reestr, 6 ) to ( cur_dir + "tmp_xml" ) For tip_in == _XML_FILE_R02 .and. Empty( TIP_OUT )
      r_use( dir_server + "mo_dr01",, "REES" )
      Index On Str( nn, 3 ) + Str( NMONTH, 2 ) to ( cur_dir + "tmp_dr01" ) For NYEAR == sgod .and. tip == 0
      Go Top
      Do While fl .and. !Eof()
        If rees->kol_err < 0
          fl := .f.
          AAdd( arr, "В файле PR01 за " + lstr( rees->NMONTH ) + "-й месяц " + lstr( sgod ) + "г. ошибки на уровне файла" )
        Elseif Empty( rees->answer )
          fl := .f.
          AAdd( arr, "Файл PR01 за " + lstr( rees->NMONTH ) + "-й месяц " + lstr( sgod ) + " года не был прочитан" )
        Else
          If rees->NMONTH > 3
            mkol += ( rees->KOL - rees->KOL_ERR )
            Select MO_XML
            find ( Str( rees->kod, 6 ) )
            If Found() .and. Empty( mo_xml->TWORK2 )
              fl := .f.
              AAdd( arr, "Прервано чтение файла " + AllTrim( mo_xml->FNAME ) + "! Аннулируйте (Ctrl+F12) и прочитайте снова" )
            Endif
          Endif
        Endif
        Select REES
        Skip
      Enddo
      If fl .and. skol != mkol
        fl := .f.
        AAdd( arr, "Количество, определённое в план-графике 1-12 месяц = " + lstr( skol ) )
        AAdd( arr, "Количество, отправленное в ТФОМС        1-12 месяц = " + lstr( mkol ) )
      Endif
    Endif
    Close databases
    If !fl .and. !Empty( arr )
      ins_array( arr, 1, "" )
      ins_array( arr, 1, "-------------------------------------------------------" )
      ins_array( arr, 1, "Операции создания (обмена) файлов R01(PR01) и R05(PR05)" )
      n_message( arr,, "GR+/R", "W+/R",,, "G+/R" )
    Endif
  Endif

  Return Nil


// 14.12.23 проверить, есть ли не до конца обработанные операции с файлами R11...
Function find_unfinished_r11()

  Local fl := .t., fl1, skol := 0, mkol := 0, arr := {}, rec, fl_date := .t.

  Private mrec := 1, smonth := 1

  // Private sgod := 2021
  Private sgod := 2024

  If glob_mo[ _MO_IS_UCH ]
    If ( fl := verify_packet_r05( 2, arr ) )
      r_use( dir_server + "mo_dr05p",, "R05p" )
      Goto ( mrec )
      skol := &( "r05p->kol1_" + StrZero( smonth, 2 ) ) + &( "r05p->kol2_" + StrZero( smonth, 2 ) )
      Select MO_XML
      Index On Str( reestr, 6 ) to ( cur_dir + "tmp_xml" ) For tip_in == _XML_FILE_R12 .and. Empty( TIP_OUT )
      r_use( dir_server + "mo_dr01",, "REES" )
      Index On Str( nn, 3 ) to ( cur_dir + "tmp_dr01" ) For NYEAR == sgod .and. NMONTH == smonth .and. tip == 1
      Go Top
      Do While fl .and. !Eof()
        If rees->kol_err < 0
          fl := .f.
          AAdd( arr, "В файле PR11 за " + lstr( rees->NMONTH ) + "-й месяц " + lstr( sgod ) + "г. ошибки на уровне файла" )
        Elseif Empty( rees->answer )
          fl := .f.
          AAdd( arr, "Файл PR11 за " + lstr( rees->NMONTH ) + "-й месяц " + lstr( sgod ) + " года не был прочитан" )
        Else
          mkol += ( rees->KOL - rees->KOL_ERR )
          Select MO_XML
          find ( Str( rees->kod, 6 ) )
          If Found() .and. Empty( mo_xml->TWORK2 )
            fl := .f.
            AAdd( arr, "Прервано чтение файла " + AllTrim( mo_xml->FNAME ) + "! Аннулируйте (Ctrl+F12) и прочитайте снова" )
          Endif
        Endif
        Select REES
        Skip
      Enddo
      If fl .and. skol != mkol
        fl := .f.
        AAdd( arr, "Количество, определённое в план-графике = " + lstr( skol ) )
        AAdd( arr, "Количество, отправленное в ТФОМС        = " + lstr( mkol ) )
      Endif
    Endif
    Close databases
    If !fl .and. !Empty( arr )
      ins_array( arr, 1, "" )
      ins_array( arr, 1, "-------------------------------------------" )
      ins_array( arr, 1, "Операции создания (обмена) файлов R11(PR11)" )
      n_message( arr,, "GR+/R", "W+/R",,, "G+/R" )
    Endif
  Endif

  Return Nil


// 14.12.23
/*Function find_new_R00()
  Private c_view := 0, c_found := 0, sgod := 2024, CODE_LPU := glob_mo[_MO_KOD_TFOMS]
  Private _arr_vozrast_DVN := ret_arr_vozrast_DVN(0d20231201), mkol := {0,0,0,0,0}

  Status_Key("^<Esc>^ - прервать поиск")
  hGauge := GaugeNew(,,,"Поиск пациентов, подлежащих дисп-ии/профосмотрам",.t.)
  GaugeDisplay( hGauge )
  G_Use (dir_server + "mo_dr00",,"TMP")
  index on str(kod,7) to tmp2
  R_Use(dir_server + "kartote2",,"KART2")
  R_Use(dir_server + "kartote_",,"KART_")
  R_Use(dir_server + "kartotek",,"KART")
  set relation to recno() into KART_, recno() into KART2
  go top
  do while !eof()
    GaugeUpdate( hGauge, recno()/lastrec() )
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if kart->kod > 0
      select tmp
      find(str(kart->kod,7))
      if !found()
        f0_create_new_R01(sgod,@c_view,@c_found)
      endif
    endif
    select KART
    skip
  enddo
  close databases
  CloseGauge(hGauge)
  func_error(4,"Поиск закончен!")
return NIL
*/



// 26.07.23
/*Static Function f0_create_new_R01(sgod,cv,cf)
  Local fl, v, ltip, ltip1, lvoz, ag, lgod_r, s
  ++cv
  if (fl := (kart2->MO_PR == CODE_LPU)) // прикреплён к нашей МО
    lgod_r := year(kart->date_r)
    v := sgod - lgod_r
    if (fl := (v > 17)) // только взрослое население
      if fl
        lvoz := 4
        ltip1 := 0
        if ascan(_arr_vozrast_DVN,v) > 0
          ltip := 1 // диспансеризация
          // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-прочие
          if v >= iif(kart->POL == "М", 60, 55)
            lvoz := 3
            ltip1 := 1
            if v == 65
              lvoz := 1
              ltip1 := 2
            elseif v > 65
              lvoz := 2
              ltip1 := 3
            endif
          endif
        else
          ltip := 2 // профосмотры
        endif
      endif
    endif
  endif
  if fl // За исключением умерших (по сведению ТФОМС) и моложе 100 лет
    fl := !(left(kart2->PC2,1) == "1") .or. v < 100
  endif
  if fl
    select TMP
    append blank
    tmp->kod := kart->kod
    tmp->tip := ltip
    tmp->tip1 := ltip1
    tmp->voz := lvoz
    //my_debug(,ltip)
    //my_debug(,kart->kod)
    //my_debug(,tmp->kod)
    //my_debug(,tmp->(recno()))
    if between(ltip1,1,3)
      //++mkol[ltip1+2]
    else
      //++mkol[ltip]
    endif
    if ++cf % 500 == 0
      tmp->(dbCommit())
    endif
  endif
  @ maxrow(),1 say lstr(cv) color cColorSt2Msg
  @ row(),col() say "/" color "W/R"
  @ row(),col() say lstr(cf) color cColorStMsg
  return NIL
  */
