#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 19.03.24 ������ ������ ��⮢ ����஫� �� �६���� 䠩��
Function reestr_rak_tmpfile( oXmlDoc, aerr, mname_xml )

  Static s_big := 10000000000000000
  Local j, j1, oXmlNode, oNode1, oNode2, buf := save_maxrow()

  Default aerr TO {}, mname_xml To ""
  stat_msg( "��ᯠ�����/�⥭��/������ ॥��� ��⮢ ����஫� " + BeforAtNum( ".", mname_xml ) )
  dbCreate( cur_dir + "tmp1file", { ; // ���� ������
    { "_VERSION",   "C",  5, 0 }, ;
    { "_DATA",      "D",  8, 0 }, ;
    { "_FILENAME",  "C", 26, 0 }, ;
    { "_SMO",       "C",  5, 0 }, ; // ��� ��� ��� ��
    { "_CODE_MO",   "C",  6, 0 }, ; // ��� ��
    { "KOL_AKT",    "N",  6, 0 }, ; // ���-�� ��⮢ � 䠩��
    { "KOL_SCH",    "N",  6, 0 }, ; // ���-�� ��⮢ � 䠩��
    { "KOL_PAC",    "N",  6, 0 }, ; // ���-�� ��樥�⮢ � 䠩��
    { "KOL_ERR",    "N",  6, 0 }, ; // ���-�� ��樥�⮢ � �訡���
    { "KOL_PEN",    "N",  6, 0 }, ; // ���-�� ���䮢
    { "_YEAR",      "N",  4, 0 }, ;
    { "_MONTH",     "N",  2, 0 };
  } )
  dbCreate( cur_dir + "tmp2file", { ;  // ����� ��⮢
    { "kod_a",      "N",  6, 0 }, ; // ��� ���
    { "_CODEA",     "N", 16, 0 }, ; // ��� ����� ���
    { "_NAKT",      "C", 30, 0 }, ; // ����� ��� ����஫�
    { "_DAKT",      "D",  8, 0 }, ; // ��� ��� ����஫�
    { "KOL_SCH",    "N",  6, 0 }, ; // ���-�� ��⮢ � ���
    { "KOL_PAC",    "N",  6, 0 }, ; // ���-�� ��樥�⮢ � ���
    { "KOL_ERR",    "N",  6, 0 }, ; // ���-�� ��樥�⮢ � �訡���
    { "KOL_PEN",    "N",  6, 0 }, ; // ���-�� ���䮢
    { "_KONT",      "N",  2, 0 }, ; // 1-���, 2-���, 3-���� � �.�.
    { "_TYPEK",     "N",  1, 0 }, ; // 1-��ࢨ�� ����஫�, 2-������
    { "_SKONT",     "N",  1, 0 };  // ��� �ᯥ�⨧�: 0-���, 1-��������, 2-楫����
  } )
  dbCreate( cur_dir + "tmp3file", { ; // � ������ ��� ����� ��⮢
    { "kod_s",      "N",  6, 0 }, ; // ��� ���
    { "kod_a",      "N",  6, 0 }, ; // ��� ���
    { "_CODE",      "N", 12, 0 }, ; // ��� ����� ���
    { "_CODE_MO",   "C",  6, 0 }, ; // ��� �� �� F003
    { "_YEAR",      "N",  4, 0 }, ;
    { "_MONTH",     "N",  2, 0 }, ;
    { "KOD_SCHET",  "N",  6, 0 }, ; // ��� ��襣� ���
    { "_NSCHET",    "C", 15, 0 }, ; // ����� ��襣� ���
    { "_DSCHET",    "D",  8, 0 }, ; // ��� ��襣� ���
    { "KOL_PAC",    "N",  6, 0 }, ; // ���-�� ��樥�⮢ � ���
    { "KOL_ERR",    "N",  6, 0 }, ; // ���-�� ��樥�⮢ � �訡���
    { "KOL_PEN",    "N",  6, 0 }, ; // ���-�� ���䮢
    { "_PLAT",      "C",  5, 0 }, ; // ���⥫�騪 (��� ��� ��)
    { "_SUMMAV",    "N", 15, 2 }, ; // �㬬� ��, ���⠢������ �� ������
    { "_SUMMAP",    "N", 15, 2 }, ; // �㬬�, �ਭ��� � ����� ��� ��� ��
    { "_SANK_MEK",  "N", 15, 2 }, ; // 䨭��ᮢ� ᭪樨 ��� (��� SANK_SUM)
    { "_SANK_MEE",  "N", 15, 2 }, ; // 䨭��ᮢ� ᭪樨 ���
    { "_SANK_EKMP", "N", 15, 2 }, ; // 䨭��ᮢ� ᭪樨 ����
    { "PENALTY",    "N", 15, 2 };  // �㬬� ���䮢
  } )
  dbCreate( cur_dir + "tmp4file", { ;
    { "kod_s",      "N",  6, 0 }, ; // ��� ���
    { "kod_a",      "N",  6, 0 }, ; // ��� ���
    { "_IDCASE",    "N",  8, 0 }, ; // ����� ����� � ���
    { "KOD_H",      "N",  7, 0 }, ; // ��� ���� ��� �� �� "human"
    { "_ID_C",      "C", 36, 0 }, ; // ��� ����
    { "_LPU",       "C",  6, 0 }, ; // ��� �� �� T001
    { "_OPLATA",    "N",  1, 0 }, ;
    { "_SUMP",      "N", 15, 2 }, ;
    { "_REFREASON", "N",  3, 0 }, ;
    { "_SANK_MEK",  "N", 15, 2 }, ;
    { "_SANK_MEE",  "N", 15, 2 }, ;
    { "_SANK_EKMP", "N", 15, 2 }, ;
    { "PENALTY",    "N", 15, 2 };  // �㬬� ���䮢
  } )
  dbCreate( cur_dir + "tmp5file", { ; // ॥��� ��⮢ ����஫� ��⮢ + �ᯥ���
    { "kod_a",      "N",  6, 0 }, ; // ��� ���
    { "CODE_EXP",   "C",  11, 0 };  // ��� �ᯥ�� ����⢠ ���.����� �� F004
  } )
  dbCreate( cur_dir + "tmp6file", { ; // ॥��� ��⮢ ����஫� + ��� + ����� ��� + �訡�� (��-������ - 2019 ���)
    { "kod_s",      "N",  6, 0 }, ; // ��� ���
    { "kod_a",      "N",  6, 0 }, ; // ��� ���
    { "_IDCASE",    "N",  8, 0 }, ; // ����� ����� � ���
    { "S_CODE",     "C", 36, 0 }, ; // �����䨪��� ᠭ�樨
    { "S_SUM",      "N", 10, 2 }, ; // �㬬� 㬥��襭�� ������
    { "REFREASON",  "N",  3, 0 }, ; // ��� ��稭� �⪠�� (���筮�) ������
    { "PENALTY",    "N", 15, 2 }, ; // �㬬� ���䮢
    { "SL_ID",      "C", 36, 0 }, ; // �����䨪��� ���� (� �����祭��� ��砥)
    { "SL_ID2",     "C", 36, 0 }, ; // �����䨪��� ��ண� ���� (� �����祭��� ��砥)
    { "S_COM",      "C", 250, 0 } ; // �������਩ � ᠭ�樨
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
      _ar := mo_read_xml_array( oXmlNode, "CODE_EXP" ) // �.�.��������� �ᯥ�⮢
      For j1 := 1 To Len( _ar )
        Select TMP5
        Append Blank
        tmp5->kod_a    := tmp2->kod_a
        tmp5->CODE_EXP := _ar[ j1 ]
      Next
      For j1 := 1 To Len( oXmlNode:aitems ) // ��᫥����⥫�� ��ᬮ��
        oNode1 := oXmlNode:aItems[ j1 ]     // �.�. ��⮢ �.�. ��᪮�쪮
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
          For j2 := 1 To Len( oNode1:aitems ) // ��᫥����⥫�� ��ᬮ��
            oNode2 := oNode1:aItems[ j2 ]     // �.�. ��砥� �.�. ��᪮�쪮
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
              For j3 := 1 To Len( oNode2:aitems ) // ��᫥����⥫�� ��ᬮ��
                oNode3 := oNode2:aItems[ j3 ]     // �.�. ᠭ�権 �.�. ��᪮�쪮
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

