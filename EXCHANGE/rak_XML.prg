#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 19.03.24 зачитать Реестр Актов Контроля во временные файлы
Function reestr_rak_tmpfile( oXmlDoc, aerr, mname_xml )

  Static s_big := 10000000000000000
  Local j, j1, oXmlNode, oNode1, oNode2, buf := save_maxrow()

  Default aerr TO {}, mname_xml To ""
  stat_msg( "Распаковка/чтение/анализ реестра актов контроля " + BeforAtNum( ".", mname_xml ) )
  dbCreate( cur_dir + "tmp1file", { ; // одна запись
    { "_VERSION",   "C",  5, 0 }, ;
    { "_DATA",      "D",  8, 0 }, ;
    { "_FILENAME",  "C", 26, 0 }, ;
    { "_SMO",       "C",  5, 0 }, ; // код СМО или ТФ
    { "_CODE_MO",   "C",  6, 0 }, ; // код МО
    { "KOL_AKT",    "N",  6, 0 }, ; // кол-во актов в файле
    { "KOL_SCH",    "N",  6, 0 }, ; // кол-во счетов в файле
    { "KOL_PAC",    "N",  6, 0 }, ; // кол-во пациентов в файле
    { "KOL_ERR",    "N",  6, 0 }, ; // кол-во пациентов с ошибкой
    { "KOL_PEN",    "N",  6, 0 }, ; // кол-во штрафов
    { "_YEAR",      "N",  4, 0 }, ;
    { "_MONTH",     "N",  2, 0 };
  } )
  dbCreate( cur_dir + "tmp2file", { ;  // много актов
    { "kod_a",      "N",  6, 0 }, ; // код акта
    { "_CODEA",     "N", 16, 0 }, ; // код записи акта
    { "_NAKT",      "C", 30, 0 }, ; // номер акта контроля
    { "_DAKT",      "D",  8, 0 }, ; // дата акта контроля
    { "KOL_SCH",    "N",  6, 0 }, ; // кол-во счетов в акте
    { "KOL_PAC",    "N",  6, 0 }, ; // кол-во пациентов в акте
    { "KOL_ERR",    "N",  6, 0 }, ; // кол-во пациентов с ошибкой
    { "KOL_PEN",    "N",  6, 0 }, ; // кол-во штрафов
    { "_KONT",      "N",  2, 0 }, ; // 1-МЭК, 2-МЭЭ, 3-ЭКМП и т.д.
    { "_TYPEK",     "N",  1, 0 }, ; // 1-первичный контроль, 2-повторный
    { "_SKONT",     "N",  1, 0 };  // вид экспертизы: 0-МЭК, 1-плановая, 2-целевая
  } )
  dbCreate( cur_dir + "tmp3file", { ; // в каждом акте много счетов
    { "kod_s",      "N",  6, 0 }, ; // код счета
    { "kod_a",      "N",  6, 0 }, ; // код акта
    { "_CODE",      "N", 12, 0 }, ; // код записи счета
    { "_CODE_MO",   "C",  6, 0 }, ; // код МО по F003
    { "_YEAR",      "N",  4, 0 }, ;
    { "_MONTH",     "N",  2, 0 }, ;
    { "KOD_SCHET",  "N",  6, 0 }, ; // код нашего счета
    { "_NSCHET",    "C", 15, 0 }, ; // номер нашего счета
    { "_DSCHET",    "D",  8, 0 }, ; // дата нашего счета
    { "KOL_PAC",    "N",  6, 0 }, ; // кол-во пациентов в счете
    { "KOL_ERR",    "N",  6, 0 }, ; // кол-во пациентов с ошибкой
    { "KOL_PEN",    "N",  6, 0 }, ; // кол-во штрафов
    { "_PLAT",      "C",  5, 0 }, ; // плательщик (СМО или ТФ)
    { "_SUMMAV",    "N", 15, 2 }, ; // сумма МО, выставленная на оплату
    { "_SUMMAP",    "N", 15, 2 }, ; // сумма, принятая к оплате СМО или ТФ
    { "_SANK_MEK",  "N", 15, 2 }, ; // финансовые снкции МЭК (или SANK_SUM)
    { "_SANK_MEE",  "N", 15, 2 }, ; // финансовые снкции МЭЭ
    { "_SANK_EKMP", "N", 15, 2 }, ; // финансовые снкции ЭКМП
    { "PENALTY",    "N", 15, 2 };  // Сумма штрафов
  } )
  dbCreate( cur_dir + "tmp4file", { ;
    { "kod_s",      "N",  6, 0 }, ; // код счета
    { "kod_a",      "N",  6, 0 }, ; // код акта
    { "_IDCASE",    "N",  8, 0 }, ; // номер записи в счете
    { "KOD_H",      "N",  7, 0 }, ; // код листа учета по БД "human"
    { "_ID_C",      "C", 36, 0 }, ; // код случая
    { "_LPU",       "C",  6, 0 }, ; // код МО по T001
    { "_OPLATA",    "N",  1, 0 }, ;
    { "_SUMP",      "N", 15, 2 }, ;
    { "_REFREASON", "N",  3, 0 }, ;
    { "_SANK_MEK",  "N", 15, 2 }, ;
    { "_SANK_MEE",  "N", 15, 2 }, ;
    { "_SANK_EKMP", "N", 15, 2 }, ;
    { "PENALTY",    "N", 15, 2 };  // Сумма штрафов
  } )
  dbCreate( cur_dir + "tmp5file", { ; // реестр актов контроля счетов + эксперты
    { "kod_a",      "N",  6, 0 }, ; // код акта
    { "CODE_EXP",   "C",  11, 0 };  // код эксперта качества мед.помощи по F004
  } )
  dbCreate( cur_dir + "tmp6file", { ; // реестр актов контроля + счета + листы учета + ошибки (по-новому - 2019 год)
    { "kod_s",      "N",  6, 0 }, ; // код счета
    { "kod_a",      "N",  6, 0 }, ; // код акта
    { "_IDCASE",    "N",  8, 0 }, ; // номер записи в счете
    { "S_CODE",     "C", 36, 0 }, ; // идентификатор санкции
    { "S_SUM",      "N", 10, 2 }, ; // сумма уменьшения оплаты
    { "REFREASON",  "N",  3, 0 }, ; // код причины отказа (частичной) оплаты
    { "PENALTY",    "N", 15, 2 }, ; // Сумма штрафов
    { "SL_ID",      "C", 36, 0 }, ; // идентификатор случая (в законченном случае)
    { "SL_ID2",     "C", 36, 0 }, ; // идентификатор второго случая (в законченном случае)
    { "S_COM",      "C", 250, 0 } ; // Комментарий к санкции
  } )
  Use ( cur_dir + "tmp1file" ) New Alias TMP1
  Append Blank
  Use ( cur_dir + "tmp2file" ) New Alias TMP2
  Use ( cur_dir + "tmp3file" ) New Alias TMP3
  Use ( cur_dir + "tmp4file" ) New Alias TMP4
  Use ( cur_dir + "tmp5file" ) New Alias TMP5
  Use ( cur_dir + "tmp6file" ) New Alias TMP6
  For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
    @ MaxRow(), 1 Say PadR( lstr( j ), 6 ) Color cColorSt2Msg
    oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
    Do Case
    Case "ZGLV" == oXmlNode:title
      tmp1->_VERSION :=          mo_read_xml_stroke( oXmlNode, "VERSION", aerr )
      tmp1->_DATA    := xml2date( mo_read_xml_stroke( oXmlNode, "DATA",    aerr ) )
      tmp1->_FILENAME :=          mo_read_xml_stroke( oXmlNode, "FILENAME", aerr )
    Case "AKT" == oXmlNode:title
      tmp1->KOL_AKT++
      Select TMP2
      Append Blank
      tmp2->kod_a   := RecNo()
      tmp2->_CODEA  :=      Val( mo_read_xml_stroke( oXmlNode, "CODEA", aerr ) )
      tmp2->_NAKT   :=      mo_read_xml_stroke( oXmlNode, "NAKT", aerr )
      tmp2->_DAKT   := xml2date( mo_read_xml_stroke( oXmlNode, "DAKT", aerr ) )
      tmp2->_KONT   :=      Val( mo_read_xml_stroke( oXmlNode, "KONT", aerr ) )
      tmp2->_TYPEK  :=      Val( mo_read_xml_stroke( oXmlNode, "TYPEK", aerr, .f. ) )
      tmp2->_SKONT  :=      Val( mo_read_xml_stroke( oXmlNode, "SKONT", aerr, .f. ) )
      If Empty( tmp2->_CODEA )
        tmp2->_CODEA := s_big - tmp2->( RecNo() )
      Endif
      _ar := mo_read_xml_array( oXmlNode, "CODE_EXP" ) // М.Б.НЕСКОЛЬКО экспертов
      For j1 := 1 To Len( _ar )
        Select TMP5
        Append Blank
        tmp5->kod_a    := tmp2->kod_a
        tmp5->CODE_EXP := _ar[ j1 ]
      Next
      For j1 := 1 To Len( oXmlNode:aitems ) // последовательный просмотр
        oNode1 := oXmlNode:aItems[ j1 ]     // т.к. счетов м.б. несколько
        If ValType( oNode1 ) != "C" .and. oNode1:title == "SCHET"
          tmp1->KOL_SCH++
          tmp2->KOL_SCH++
          Select TMP3
          Append Blank
          tmp3->kod_a     := tmp2->kod_a
          tmp3->kod_s     := RecNo()
          tmp3->_CODE     :=      Val( mo_read_xml_stroke( oNode1, "CODE", aerr ) )
          tmp3->_CODE_MO  :=          mo_read_xml_stroke( oNode1, "CODE_MO", aerr )
          tmp3->_YEAR     :=      Val( mo_read_xml_stroke( oNode1, "YEAR", aerr ) )
          tmp3->_MONTH    :=      Val( mo_read_xml_stroke( oNode1, "MONTH", aerr ) )
          tmp3->_NSCHET   :=    Upper( mo_read_xml_stroke( oNode1, "NSCHET", aerr ) )
          tmp3->_DSCHET   := xml2date( mo_read_xml_stroke( oNode1, "DSCHET", aerr ) )
          tmp3->_PLAT     :=          mo_read_xml_stroke( oNode1, "PLAT", aerr )
          tmp3->_SUMMAV   :=      Val( mo_read_xml_stroke( oNode1, "SUMMAV", aerr ) )
          tmp3->_SUMMAP   :=      Val( mo_read_xml_stroke( oNode1, "SUMMAP", aerr ) )
          If Len( mo_read_xml_array( oNode1, "SANK_MEK" ) ) > 0
            tmp3->_SANK_MEK := Val( mo_read_xml_stroke( oNode1, "SANK_MEK", aerr ) )
            tmp3->_SANK_MEE := Val( mo_read_xml_stroke( oNode1, "SANK_MEE", aerr ) )
            tmp3->_SANK_EKMP := Val( mo_read_xml_stroke( oNode1, "SANK_EKMP", aerr ) )
          Endif
          If Len( mo_read_xml_array( oNode1, "SANK_SUM" ) ) > 0
            tmp3->_SANK_MEK := Val( mo_read_xml_stroke( oNode1, "SANK_SUM", aerr ) )
            tmp3->PENALTY   := Val( mo_read_xml_stroke( oNode1, "PENALTY_SUM", aerr ) )
          Endif
          For j2 := 1 To Len( oNode1:aitems ) // последовательный просмотр
            oNode2 := oNode1:aItems[ j2 ]     // т.к. случаев м.б. несколько
            If ValType( oNode2 ) != "C" .and. oNode2:title == "SLUCH"
              tmp1->KOL_PAC++
              tmp2->KOL_PAC++
              tmp3->KOL_PAC++
              Select TMP4
              Append Blank
              tmp4->kod_a     := tmp3->kod_a
              tmp4->kod_s     := tmp3->kod_s
              tmp4->_IDCASE   :=   Val( mo_read_xml_stroke( oNode2, "IDCASE", aerr ) )
              tmp4->_ID_C     := Upper( mo_read_xml_stroke( oNode2, "ID_C", aerr ) )
              tmp4->_LPU      :=       mo_read_xml_stroke( oNode2, "LPU", aerr )
              tmp4->_OPLATA   :=   Val( mo_read_xml_stroke( oNode2, "OPLATA", aerr ) )
              tmp4->_SUMP     :=   Val( mo_read_xml_stroke( oNode2, "SUMP", aerr ) )
              tmp4->_REFREASON :=   Val( mo_read_xml_stroke( oNode2, "REFREASON", aerr, .f. ) )
              If Len( mo_read_xml_array( oNode2, "SANK_MEK" ) ) > 0
                tmp4->_SANK_MEK := Val( mo_read_xml_stroke( oNode2, "SANK_MEK", aerr ) )
                tmp4->_SANK_MEE := Val( mo_read_xml_stroke( oNode2, "SANK_MEE", aerr ) )
                tmp4->_SANK_EKMP := Val( mo_read_xml_stroke( oNode2, "SANK_EKMP", aerr ) )
              Endif
              If Len( mo_read_xml_array( oNode2, "SANK_IT" ) ) > 0
                tmp4->_SANK_MEK := Val( mo_read_xml_stroke( oNode2, "SANK_IT", aerr ) )
                tmp4->PENALTY   := Val( mo_read_xml_stroke( oNode2, "PENALTY", aerr ) )
              Endif
              If tmp4->_OPLATA > 1
                tmp1->KOL_ERR++
                tmp2->KOL_ERR++
                tmp3->KOL_ERR++
              Endif
              If !Empty( tmp4->PENALTY )
                tmp1->KOL_PEN++
                tmp2->KOL_PEN++
                tmp3->KOL_PEN++
              Endif
              For j3 := 1 To Len( oNode2:aitems ) // последовательный просмотр
                oNode3 := oNode2:aItems[ j3 ]     // т.к. санкций м.б. несколько
                If ValType( oNode3 ) != "C" .and. oNode3:title == "SANK"
                  Select TMP6
                  Append Blank
                  tmp6->kod_a     :=     tmp4->kod_a
                  tmp6->kod_s     :=     tmp4->kod_s
                  tmp6->_IDCASE   :=     tmp4->_IDCASE
                  tmp6->S_CODE    :=     mo_read_xml_stroke( oNode3, "S_CODE", aerr )
                  tmp6->S_SUM     := Val( mo_read_xml_stroke( oNode3, "S_SUM", aerr ) )
                  tmp6->REFREASON := Val( mo_read_xml_stroke( oNode3, "S_OSN", aerr ) )
                  tmp6->PENALTY   := Val( mo_read_xml_stroke( oNode3, "FIN_PENALTY", aerr ) )
                  If Len( _ar := mo_read_xml_array( oNode3, "SL_ID" ) ) > 0
                    tmp6->SL_ID := _ar[ 1 ]
                  Elseif Len( _ar ) > 1
                    tmp6->SL_ID2 := _ar[ 2 ]
                  Endif
                  tmp6->S_COM := mo_read_xml_stroke( oNode3, "S_COM", aerr, .f. )
                Endif
              Next j3
            Endif
          Next j2
        Endif
      Next j1
    Endcase
  Next j
  Commit
  rest_box( buf )

  Return Nil

