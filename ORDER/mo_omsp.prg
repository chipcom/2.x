// mo_omsp.prg - ࠡ�� � �����묨 ���㬥�⠬� � ����� ���
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 19.02.20 ������ � "ࠧ����" �� ����� ������ ���
Function read_xml_file_rpd( arr_XML_info, aerr )

  Local fl_PD, fl_schet, blk_PD, blk_schet, i, k, s, s1, arr_s := {}, t_arr[ 2 ], ssum, ;
    arr, apd := {}, no_write := .t.

  blk_PD := {|| AAdd( aerr, "������ ���㬥�� � " + AllTrim( tmp2->_N_PD ) + " �� " + date_8( tmp2->_D_PD ) ) }
  blk_schet := {|| AAdd( aerr, " ��� � " + AllTrim( tmp3->_nschet ) + " �� " + date_8( tmp3->_dschet ) ) }
  Use ( cur_dir() + "tmp1file" ) New Alias TMP1
  tmp1->_SMO     := arr_XML_info[ 2 ]
  tmp1->_CODE_MO := arr_XML_info[ 3 ]
  Use ( cur_dir() + "tmp2file" ) New Alias TMP2
  Use ( cur_dir() + "tmp3file" ) New Alias TMP3
  Index On Str( kod_pd, 10 ) to ( cur_dir() + "tmp3" )
  Use ( cur_dir() + "tmp4file" ) New Alias TMP4
  Index On Str( kod_pd, 10 ) + Str( kod_s, 10 ) to ( cur_dir() + "tmp4" )
  // ᭠砫� ����� ���� ��⮢ � ���� ���⮢ ����
  g_use( dir_server + "schet_", , "SCHET_" )
  Index On DToS( dschet ) + Upper( nschet ) to ( cur_dir() + "tmp_sch_" )
  r_use( dir_server + "mo_otd", , "OTD" )
  g_use( dir_server + "human_", , "HUMAN_" )
  g_use( dir_server + "human", , "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To otd into OTD
  Select TMP2
  Go Top
  Do While !Eof()
    fl_PD := .t. ; arr := {}
    Select TMP3
    find ( Str( tmp2->kod_pd, 10 ) )
    Do While tmp2->kod_pd == tmp3->kod_pd .and. !Eof()
      fl_schet := .t.
      Select SCHET_
      find ( DToS( tmp3->_dschet ) + Upper( tmp3->_nschet ) )
      If Found()
        no_write := .f.
        AAdd( arr, schet_->( RecNo() ) )
        tmp3->kod_schet := schet_->( RecNo() )
        If !( tmp3->_PLAT == schet_->smo )
          If fl_PD
            Eval( blk_PD ) ; fl_PD := .f.
          Endif
          If fl_schet
            Eval( blk_schet ) ; fl_schet := .f.
          Endif
          AAdd( aerr, "  �� ࠢ�� ��� ���⥫�騪�: � 䠩�� - " + AllTrim( tmp3->_PLAT ) + ", � ��� - " + AllTrim( schet_->smo ) )
        Endif
        //
        Select HUMAN
        Set Index to ( dir_server + "humans" )
        find ( Str( tmp3->kod_schet, 6 ) )
        Index On Str( human_->schet_zap, 6 ) to ( cur_dir() + "tmp_hum" ) For ishod != 89 While schet == tmp3->kod_schet
        Select TMP4
        find ( Str( tmp3->kod_pd, 10 ) + Str( tmp3->kod_s, 10 ) )
        Do While tmp3->kod_pd == tmp4->kod_pd .and. tmp3->kod_s == tmp4->kod_s .and. !Eof()
          Select HUMAN
          find ( Str( tmp4->_IDCASE, 6 ) )
          If Found()
            tmp4->KOD_H := human->kod
            If !( Upper( tmp4->_ID_C ) == Upper( human_->ID_C ) )
              If fl_PD
                Eval( blk_PD ) ; fl_PD := .f.
              Endif
              If fl_schet
                Eval( blk_schet ) ; fl_schet := .f.
              Endif
              AAdd( aerr, "  ��砩 � " + lstr( tmp4->_IDCASE ) + ", " + AllTrim( human->fio ) + ", �/� " + lstr( human->kod ) )
              AAdd( aerr, "   ID_C � ��� = " + tmp4->_ID_C + ", ID_C � ��� = " + human_->ID_C )
            Endif
          Else
            If fl_PD
              Eval( blk_PD ) ; fl_PD := .f.
            Endif
            If fl_schet
              Eval( blk_schet ) ; fl_schet := .f.
            Endif
            AAdd( aerr, "   �� ������ ��樥�� � IDCASE = " + lstr( tmp4->_IDCASE ) )
          Endif
          Select TMP4
          Skip
        Enddo
      Else
        If fl_PD
          // eval(blk_PD) ; fl_PD := .f.
        Endif
        AAdd( arr_s, { tmp3->kod_pd, tmp3->kod_s, ;
          " �� ������ ��� � " + AllTrim( tmp3->_nschet ) + " �� " + date_8( tmp3->_dschet ) } )
      Endif
      Select TMP3
      Skip
    Enddo
    AAdd( apd, { tmp2->kod_pd, arr } )
    Select TMP2
    Skip
  Enddo
  Commit
  If no_write
    AAdd( aerr, " �� �⮣� ��� ��祣� �����뢠�� � ⥪���� ���� ������" )
  Endif
  If !Empty( aerr )
    For i := 1 To Len( arr_s )
      AAdd( aerr, arr_s[ i, 3 ] )
    Next
    Return Nil
  Endif
  // ����襬 �ਭ������ 䠩� (���)
  // chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF())
  chip_copy_zipxml( full_zip, dir_server + dir_XML_TF() )
  g_use( dir_server + "mo_xml", , "MO_XML" )
  addrecn()
  mo_xml->KOD := RecNo()
  mo_xml->FNAME := cReadFile
  mo_xml->DFILE := tmp1->_DATA
  mo_xml->TFILE := ""
  mo_xml->DREAD := sys_date
  mo_xml->TREAD := hour_min( Seconds() )
  mo_xml->TIP_IN := _XML_FILE_RPD
  mo_xml->DWORK  := sys_date
  mo_xml->TWORK1 := hour_min( Seconds() )
  mo_xml->TWORK2 := ""
  mo_xml->KOL1   := tmp1->KOL_PD
  mo_xml->KOL2   := tmp1->KOL_SCH
  StrFile( hb_eol() + ;
    "������⢮ ������� ���㬥�⮢ - " + lstr( tmp1->KOL_PD ) + hb_eol() + ;
    "������⢮ ��⮢ - " + lstr( tmp1->KOL_SCH ) + hb_eol() + ;
    "������⢮ ����祭��� ��樥�⮢ - " + lstr( tmp1->KOL_PAC ) + hb_eol(), cFileProtokol, .t. )
  //
  Select HUMAN
  Set Index To
  r_use( dir_server + "human_3", { dir_server + "human_3", dir_server + "human_32" }, "HUMAN_3" )
  g_use( dir_server + "schet", , "SCHET" )
  g_use( dir_server + "mo_rpd", , "RPD" )
  Index On Str( PD, 6 ) to ( cur_dir() + "tmprpd" )
  g_use( dir_server + "mo_rpds", , "RPDS" )
  Index On Str( PD, 6 ) to ( cur_dir() + "tmprpds" )
  g_use( dir_server + "mo_rpdsh", , "RPDSH" )
  Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmprpdsh" )
  Select TMP2
  Go Top
  Do While !Eof()
    s := hb_eol() + "������ ���㬥�� � " + AllTrim( tmp2->_N_PD ) + " �� " + date_8( tmp2->_D_PD )
    If ( i := AScan( apd, {| x| x[ 1 ] == tmp2->kod_pd } ) ) > 0 .and. Empty( apd[ i, 2 ] )
      StrFile( s + " - �� ������� ��⮢ � ���� ������" + hb_eol() + hb_eol(), cFileProtokol, .t. )
    Else
      StrFile( s + ", ��⮢ - " + lstr( tmp2->KOL_SCH ) + ;
        ", ��樥�⮢ - " + lstr( tmp2->KOL_PAC ) + hb_eol(), cFileProtokol, .t. )
      Select RPD
      addrec( 6 )
      rpd->PD      := RecNo() // ��� ��
      rpd->KOD_XML := mo_xml->KOD
      rpd->T_PD    := tmp2->_T_PD
      rpd->N_PD    := tmp2->_N_PD
      rpd->D_PD    := tmp2->_D_PD
      rpd->NSCHET  := ""
      rpd->KOL_SCH := tmp2->KOL_SCH
      rpd->KOL_PAC := tmp2->KOL_PAC
      rpd->S_PD    := tmp2->_S_PD
      rpd->S_ALL   := tmp2->_S_ALL
      rpd->KBK     := tmp2->_KBK
      Select TMP3
      find ( Str( tmp2->kod_pd, 10 ) )
      Do While tmp2->kod_pd == tmp3->kod_pd .and. !Eof()
        If tmp3->kod_schet == 0
          If ( i := AScan( arr_s, {| x| x[ 1 ] == tmp3->kod_pd .and. x[ 2 ] == tmp3->kod_s } ) ) > 0
            StrFile( hb_eol() + " " + arr_s[ i, 3 ] + hb_eol() + hb_eol(), cFileProtokol, .t. )
          Endif
        Else
          schet_->( dbGoto( tmp3->kod_schet ) )
          schet->( dbGoto( tmp3->kod_schet ) )
          If tmp2->KOL_SCH == 1
            rpd->NSCHET := schet_->NSCHET
          Endif
          //
          StrFile( hb_eol() + ;
            "  ��� � " + AllTrim( tmp3->_nschet ) + " �� " + date_8( tmp3->_dschet ) + ;
            ", ������ ��ਮ� - " + StrZero( schet_->nyear, 4 ) + "/" + StrZero( schet_->nmonth, 2 ) + hb_eol() + ;
            "  ���⠢����: ��樥�⮢ -" + Str( schet->kol, 5 ) + ", �� �㬬� - " + lstr( schet->SUMMA, 15, 2 ) + "�." + hb_eol() + ;
            "  ����祭�  : ��樥�⮢ -" + Str( tmp3->KOL_PAC, 5 ) + ", �� �㬬� - " + lstr( tmp3->_S_SCH, 15, 2 ) + "�." + hb_eol(), cFileProtokol, .t. )
          Select RPDS
          addrec( 6 )
          rpds->KOD_RPDS := RecNo()
          rpds->PD       := rpd->PD
          rpds->SCHET    := tmp3->kod_schet
          rpds->KOL_PAC  := tmp3->KOL_PAC
          rpds->PLAT     := tmp3->_PLAT
          rpds->S_SCH    := tmp3->_S_SCH
          Commit
          k := k1 := 0
          Select TMP4
          find ( Str( tmp3->kod_pd, 10 ) + Str( tmp3->kod_s, 10 ) )
          Do While tmp3->kod_pd == tmp4->kod_pd .and. tmp3->kod_s == tmp4->kod_s .and. !Eof()
            human->( dbGoto( tmp4->KOD_H ) )
            // human->(G_RLock(forever))
            // human->DATE_OPL := dtoc4(rpd->D_PD) �.�. �㤥� ������� next_vizit
            ssum := human->cena_1
            If human->ishod == 88
              Select HUMAN_3
              Set Order To 1
              find ( Str( human->kod, 7 ) )
              ssum := human_3->CENA_1
            Endif
            If Round( ssum, 2 ) == Round( tmp4->_S_SL, 2 )
              ++k
            Else
              sumr := 0
              Select RPDSH
              find ( Str( tmp4->KOD_H, 7 ) )
              Do While rpdsh->KOD_H == tmp4->KOD_H .and. !Eof()
                sumr += rpdsh->S_SL
                Skip
              Enddo
              s := Space( 4 ) + "�㬬� ��祭��: " + lstr( ssum, 15, 2 ) + "�., " + ;
                "����祭�: " + lstr( tmp4->_S_SL, 15, 2 ) + "�., "
              If Empty( sumr )
                s += "�� ����祭�: " + lstr( ssum - tmp4->_S_SL, 15, 2 ) + "�."
              Else
                s += "࠭�� ����祭�: " + lstr( sumr, 15, 2 ) + "�."
                If Round( ssum, 2 ) == Round( sumr + tmp4->_S_SL, 2 )
                  ++k1
                  s += hb_eol() + Space( 4 ) + "=�⮣� ��砩 ��������� ����祭="
                Endif
              Endif
              StrFile( "  - " + "���砩 � " + lstr( tmp4->_IDCASE ) + ". " + AllTrim( human->fio ) + ", " + ;
                full_date( human->date_r ) + ;
                iif( Empty( otd->SHORT_NAME ), "", " [" + AllTrim( otd->SHORT_NAME ) + "]" ) + ;
                " " + date_8( human->n_data ) + "-" + ;
                date_8( human->k_data ) + hb_eol() + s + ;
                hb_eol(), cFileProtokol, .t. )
            Endif
            //
            Select RPDSH
            addrec( 7 )
            rpdsh->KOD_RPDS := rpds->KOD_RPDS
            rpdsh->KOD_H    := tmp4->KOD_H
            rpdsh->S_SL     := tmp4->_S_SL
            Select TMP4
            Skip
          Enddo
          Commit
          If k > 0
            If k == tmp3->KOL_PAC .and. k == schet->kol
              StrFile( "  �� ��樥��� ����祭� ���������" + hb_eol(), cFileProtokol, .t. )
            Else
              StrFile( "  ��������� ����祭� ��樥�⮢ - " + lstr( k ) + hb_eol(), cFileProtokol, .t. )
              If tmp3->KOL_PAC > k
                If tmp3->KOL_PAC - k > k1
                  StrFile( "  �� ��������� ����祭� ��樥�⮢ - " + lstr( tmp3->KOL_PAC - k - k1 ) + hb_eol(), cFileProtokol, .t. )
                Endif
                If k1 > 0
                  StrFile( "  ������祭� ��樥�⮢ - " + lstr( k1 ) + hb_eol(), cFileProtokol, .t. )
                Endif
              Endif
            Endif
          Endif
        Endif
        Select TMP3
        Skip
      Enddo
    Endif
    Select TMP2
    Skip
  Enddo
  // ����襬 �६� ����砭�� ��ࠡ�⪨
  mo_xml->TWORK2 := hour_min( Seconds() )
  Close databases

  Return Nil

// 10.02.17 ������ ������ ������� ���㬥�⮢ �� �६���� 䠩��
Function reestr_rpd_tmpfile( oXmlDoc, aerr, mname_xml )

  Local j, j1, oXmlNode, oNode1, oNode2, buf := save_maxrow()

  Default aerr TO {}, mname_xml To ""
  stat_msg( "��ᯠ�����/�⥭��/������ ॥��� ������� ����㥭⮢ " + BeforAtNum( ".", mname_xml ) )
  dbCreate( cur_dir() + "tmp1file", { ; // ���� ������
  { "_VERSION",   "C",  5, 0 }, ;
    { "_DATA",      "D",  8, 0 }, ;
    { "_FILENAME",  "C", 26, 0 }, ;
    { "_SMO",       "C",  5, 0 }, ; // ��� ��� ��� ��
  { "_CODE_MO",   "C",  6, 0 }, ; // ��� ��
  { "KOL_PD",     "N",  6, 0 }, ; // ���-�� �� � 䠩��
  { "KOL_SCH",    "N",  6, 0 }, ; // ���-�� ��⮢ � 䠩��
  { "KOL_PAC",    "N",  6, 0 };  // ���-�� ��樥�⮢ � 䠩��
  } )
  dbCreate( cur_dir() + "tmp2file", { ;  // ����� ��
  { "kod_pd",     "N",  6, 0 }, ; // ��� ����� ��
  { "_T_PD",      "N",  1, 0 }, ; // 1-����񦭮� ����祭��, 2-���쬮 �� 㬥��襭�� �������������
  { "_N_PD",      "C", 25, 0 }, ; // ����� ��
  { "_D_PD",      "D",  8, 0 }, ; // ��� ��
  { "KOL_SCH",    "N",  6, 0 }, ; // ���-�� ��⮢ � ��
  { "KOL_PAC",    "N",  6, 0 }, ; // ���-�� ��樥�⮢ � ��
  { "_S_PD",      "N", 15, 2 }, ; // �㬬� ��
  { "_S_ALL",     "N", 15, 2 }, ; // �㬬� ������
  { "_KBK",       "C", 20, 0 };  // ���
  } )
  dbCreate( cur_dir() + "tmp3file", { ; // � ������ �� ����� ��⮢
  { "kod_pd",     "N",  6, 0 }, ; // ��� ����� ��
  { "kod_s",      "N",  6, 0 }, ; // ��� ���
  { "_CODE",      "N", 12, 0 }, ; // ��� ����� ���
  { "_CODE_MO",   "C",  6, 0 }, ; // ��� �� �� F003
  { "_YEAR",      "N",  4, 0 }, ;
    { "_MONTH",     "N",  2, 0 }, ;
    { "KOD_SCHET",  "N",  6, 0 }, ; // ��� ��襣� ���
  { "_NSCHET",    "C", 15, 0 }, ; // ����� ��襣� ���
  { "_DSCHET",    "D",  8, 0 }, ; // ��� ��襣� ���
  { "KOL_PAC",    "N",  6, 0 }, ; // ���-�� ��樥�⮢ � ���
  { "_PLAT",      "C",  5, 0 }, ; // ���⥫�騪 (��� ��� ��)
  { "_S_SCH",     "N", 15, 2 };  // �㬬� ������ ���� � ��
  } )
  dbCreate( cur_dir() + "tmp4file", { ;
    { "kod_pd",     "N",  6, 0 }, ; // ��� ����� ��
  { "kod_s",      "N",  6, 0 }, ; // ��� ���
  { "_CODE",      "N", 12, 0 }, ; // ��� ����� ���
  { "_IDCASE",    "N",  8, 0 }, ; // ����� ����� � ���
  { "KOD_H",      "N",  7, 0 }, ; // ��� ���� ��� �� �� "human"
  { "_ID_C",      "C", 36, 0 }, ; // ��� ����
  { "_S_SL",      "N", 11, 2 };  // �㬬� ������ ���� � ��
  } )
  Use ( cur_dir() + "tmp1file" ) New Alias TMP1
  Append Blank
  Use ( cur_dir() + "tmp2file" ) New Alias TMP2
  Use ( cur_dir() + "tmp3file" ) New Alias TMP3
  Use ( cur_dir() + "tmp4file" ) New Alias TMP4
  For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
    @ 24, 1 Say PadR( lstr( j ), 6 ) Color cColorSt2Msg
    oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
    Do Case
    Case "ZGLV" == oXmlNode:title
      tmp1->_VERSION  :=          mo_read_xml_stroke( oXmlNode, "VERSION", aerr )
      tmp1->_DATA     := xml2date( mo_read_xml_stroke( oXmlNode, "DATA",    aerr ) )
      tmp1->_FILENAME :=          mo_read_xml_stroke( oXmlNode, "FILENAME", aerr )
    Case "PD" == oXmlNode:title
      tmp1->KOL_PD++
      Select TMP2
      Append Blank
      tmp2->kod_pd  := RecNo()
      tmp2->_T_PD   :=      Val( mo_read_xml_stroke( oXmlNode, "T_PD", aerr ) )
      tmp2->_N_PD   :=          mo_read_xml_stroke( oXmlNode, "N_PD", aerr )
      tmp2->_D_PD   := xml2date( mo_read_xml_stroke( oXmlNode, "D_PD", aerr ) )
      tmp2->_S_PD   :=      Val( mo_read_xml_stroke( oXmlNode, "S_PD", aerr ) )
      tmp2->_S_ALL  :=      Val( mo_read_xml_stroke( oXmlNode, "S_ALL", aerr ) )
      tmp2->_KBK    :=          mo_read_xml_stroke( oXmlNode, "KBK", aerr )
      For j1 := 1 To Len( oXmlNode:aitems ) // ��᫥����⥫�� ��ᬮ��
        oNode1 := oXmlNode:aItems[ j1 ]     // �.�. ��⮢ �.�. ��᪮�쪮
        If ValType( oNode1 ) != "C" .and. oNode1:title == "SCHET"
          tmp1->KOL_SCH++
          tmp2->KOL_SCH++
          Select TMP3
          Append Blank
          tmp3->kod_pd   := tmp2->kod_pd
          tmp3->kod_s    := RecNo()
          tmp3->_CODE    :=      Val( mo_read_xml_stroke( oNode1, "CODE", aerr ) )
          tmp3->_CODE_MO :=          mo_read_xml_stroke( oNode1, "CODE_MO", aerr )
          tmp3->_YEAR    :=      Val( mo_read_xml_stroke( oNode1, "YEAR", aerr ) )
          tmp3->_MONTH   :=      Val( mo_read_xml_stroke( oNode1, "MONTH", aerr ) )
          tmp3->_NSCHET  :=    Upper( mo_read_xml_stroke( oNode1, "NSCHET", aerr ) )
          tmp3->_DSCHET  := xml2date( mo_read_xml_stroke( oNode1, "DSCHET", aerr ) )
          tmp3->_PLAT    :=          mo_read_xml_stroke( oNode1, "PLAT", aerr )
          tmp3->_S_SCH   :=      Val( mo_read_xml_stroke( oNode1, "S_SCH", aerr ) )
          For j2 := 1 To Len( oNode1:aitems ) // ��᫥����⥫�� ��ᬮ��
            oNode2 := oNode1:aItems[ j2 ]     // �.�. ��砥� �.�. ��᪮�쪮
            If ValType( oNode2 ) != "C" .and. oNode2:title == "SLUCH"
              tmp1->KOL_PAC++
              tmp2->KOL_PAC++
              tmp3->KOL_PAC++
              Select TMP4
              Append Blank
              tmp4->kod_pd  := tmp3->kod_pd
              tmp4->kod_s   := tmp3->kod_s
              tmp4->_CODE   := tmp3->_CODE
              tmp4->_IDCASE :=   Val( mo_read_xml_stroke( oNode2, "IDCASE", aerr ) )
              tmp4->_ID_C   := Upper( mo_read_xml_stroke( oNode2, "ID_C", aerr ) )
              tmp4->_S_SL   :=   Val( mo_read_xml_stroke( oNode2, "S_SL", aerr ) )
            Endif
          Next j2
        Endif
      Next j1
    Endcase
  Next j
  Commit
  rest_box( buf )

  Return Nil

// 17.03.13
Function view_pd()

  g_use( dir_server + "mo_xml", , "MO_XML" )
  Index On DToS( DFILE ) to ( cur_dir() + "tmp_xml" ) For tip_in == _XML_FILE_RPD DESCENDING
  Go Top
  If Eof()
    func_error( 4, "��� ॥��஢ ������� ���㬥�⮢" )
  Else
    alpha_browse( T_ROW, 2, 22, 77, "f1_view_rpd", color0, , , , , , , ;
      "f2_view_rpd", , { '�', '�', '�', "N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R", .t., 180 } )
  Endif
  Close databases

  Return Nil

// 17.03.13
Function f1_view_rpd( oBrow )

  Local oColumn, blk := {|| iif( Empty( mo_xml->TWORK2 ), { 5, 6 }, { 1, 2 } ) }

  oColumn := TBColumnNew( "������������ 䠩��;॥��� ����.���㬥�⮢", {|| PadR( mo_xml->FNAME, 23 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "��� 䠩��; ॥���", {|| full_date( mo_xml->dfile ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " ���.; ��", {|| Str( mo_xml->kol1, 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " ���.;��⮢", {|| Str( mo_xml->kol2, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "  ���; �⥭��", {|| date_8( mo_xml->dread ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "�६�;�⥭��", {|| mo_xml->tread } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "�ਬ�砭��", {|| PadR( iif( Empty( mo_xml->TWORK2 ), "�� ���⠭", "" ), 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ ��室; ^<Enter>^ ��ᬮ�� ������� ���㬥�⮢; ^<F3>^ ��⮪�� �⥭�� 䠩��" )

  Return Nil

// 17.03.13
Function f2_view_rpd( nKey, oBrow )

  Local ret := -1, rec := mo_xml->( RecNo() ), buf := SaveScreen()

  Do Case
  Case nKey == K_F3
    viewtext( devide_into_pages( dir_server + dir_XML_TF() + hb_ps() + AllTrim( mo_xml->FNAME ) + stxt(), 60, 80 ), , , , .t., , , 2 )
    ret := 0
  Case nKey == K_ENTER
    view_rpd_pd( rec )
    Close databases
    //
    g_use( dir_server + "mo_xml", cur_dir() + "tmp_xml", "MO_XML" )
    Goto ( rec )
    ret := 0
  Case nKey == K_CTRL_F12
    ret := delete_rpd( rec, AllTrim( mo_xml->FNAME ), Empty( mo_xml->TWORK2 ) )
    Close databases
    g_use( dir_server + "mo_xml", cur_dir() + "tmp_xml", "MO_XML" )
    Goto ( rec )
  Endcase
  RestScreen( buf )

  Return ret


// 21.12.21
Function delete_rpd( lrec, lname, not_end )

  Local ret := 0, fl, ia, is, ih

  If not_end .or. hb_user_curUser:isadmin()
    fl := .t.
  Else
    fl := involved_password( 2, lname, "���⢥ত���� ���ନ஢���� ���" )
  Endif
  If fl .and. f_esc_enter( "���ନ஢���� ���", .t. )
    stat_msg( "���⢥न� ���ନ஢���� ��� ࠧ." ) ; mybell( 2 )
    If f_esc_enter( "���ନ஢���� ���", .t. )
      mywait( "����. �ந�������� ���ନ஢���� ���." )
      g_use( dir_server + "mo_rpdsh", , "RPDSH" )
      Index On Str( kod_rpds, 6 ) to ( cur_dir() + "tmprpdsh" )
      g_use( dir_server + "mo_rpds", , "RPDS" )
      Index On Str( pd, 6 ) to ( cur_dir() + "tmprpds" )
      g_use( dir_server + "mo_rpd", , "RPD" )
      Index On Str( kod_xml, 6 ) to ( cur_dir() + "tmprpd" )
      ia := is := ih := 0
      Do While .t.
        ++ia
        Select RPD
        find ( Str( lrec, 6 ) )
        If !Found() ; exit ; Endif
        Do While .t.
          ++is
          Select RPDS
          find ( Str( rpd->pd, 6 ) )
          If !Found() ; exit ; Endif
          Do While .t.
            ++ih
            Select RPDSH
            find ( Str( rpds->KOD_RPDS, 6 ) )
            If !Found() ; exit ; Endif
            @ MaxRow(), 1  Say lstr( ia ) Color "G+/R*"
            @ Row(), Col() Say "/"      Color "R/R*"
            @ Row(), Col() Say lstr( is ) Color "GR+/R*"
            @ Row(), Col() Say "/"      Color "R/R*"
            @ Row(), Col() Say lstr( ih ) Color "W+/R*"
            deleterec( .t. )
          Enddo
          Select RPDS
          deleterec( .t. )
        Enddo
        Select RPD
        deleterec( .t. )
      Enddo
      Select MO_XML
      deleterec( .t. )
      stat_msg( "������ ������� ���㬥�⮢ " + lname + " 㤠��!" ) ; mybell( 2, OK )
      ret := 1
    Endif
  Endif

  Return ret

// 17.03.13
Function view_rpd_pd( lrec )

  Local blk, blk_t_pd, t_arr[ BR_LEN ]

  r_use( dir_server + "mo_rpd", , "RPD" )
  Index On n_pd to ( cur_dir() + "tmp_rpd" ) For kod_xml == lrec
  Go Top
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := 22
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_TITUL ] := "��� " + AllTrim( mo_xml->FNAME ) + sxml + " �� " + date_8( mo_xml->dfile )
  t_arr[ BR_TITUL_COLOR ] := "B/G*"
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '�', '�', '�', "N/BG,W+/N,B/BG,W+/B", .t. }
  blk_t_pd := {|| iif( rpd->t_pd == 1, "����.����祭��", "㬥���.������." ) }
  t_arr[ BR_COLUMN ] := { { " ����� ��", {|| Left( rpd->n_pd, 15 ) }, blk }, ;
    { " ��� ��", {|| date_8( rpd->d_pd ) }, blk }, ;
    { " ��� ��", {|| PadR( Eval( blk_t_pd ), 14 ) }, blk }, ;
    { "���-��;��⮢", {|| Str( rpd->kol_sch, 6 ) }, blk }, ;
    { "�㬬� ��", {|| put_kop( rpd->S_PD, 13 ) }, blk }, ;
    { "�㬬� ������", {|| put_kop( rpd->S_ALL, 13 ) }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - ��室;  ^<Enter>^ - �롮� �� ��� ��ᬮ�� ��⮢" ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_view_rpd_pd( nk, ob, "edit" ) }
  edit_browse( t_arr )

  Return Nil

// 17.03.13
Function f1_view_rpd_pd( nk, ob, regim )

  Local ret := -1, rec

  If regim == "edit" .and. nk == K_ENTER
    rec := rpd->( RecNo() )
    view_rpd_pd_schet( rpd->pd )
    Close databases
    //
    r_use( dir_server + "mo_rpd", cur_dir() + "tmp_rpd", "rpd" )
    Goto ( rec )
    ret := 0
  Endif

  Return ret

// 17.03.13
Function view_rpd_pd_schet( lpd )

  Local blk, t_arr[ BR_LEN ]

  r_use( dir_server + "schet_", , "SCHET_" )
  r_use( dir_server + "schet", , "SCHET" )
  r_use( dir_server + "mo_rpds", , "RPDS" )
  Set Relation To schet into SCHET, To schet into SCHET_
  Index On DToS( schet_->dschet ) + schet_->nschet to ( cur_dir() + "tmp_rpds" ) For pd == lpd
  Go Top
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := 22
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_TITUL ] := iif( rpd->t_pd == 1, "������ ���㬥��", "���쬮 �� 㬥��襭�� ������������" ) + ;
    " � " + AllTrim( rpd->n_pd ) + " �� " + date_8( rpd->d_pd )
  t_arr[ BR_TITUL_COLOR ] := "B/GR*"
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '�', '�', '�', "N/BG,W+/N,B/BG,W+/B", .t. }
  blk := {|| iif( Round( schet->SUMMA, 2 ) == Round( rpds->S_SCH, 2 ), { 1, 2 }, { 3, 4 } ) }
  t_arr[ BR_COLUMN ] := { { " ����� ����", {|| schet_->nschet }, blk }, ;
    { "��-;ਮ�", {|| Right( Str( schet_->nyear, 4 ), 2 ) + "/" + StrZero( schet_->nmonth, 2 ) }, blk }, ;
    { "  ���; ����", {|| date_8( schet_->dschet ) }, blk }, ;
    { "���-;��⮢", {|| Str( schet->kol, 5 ) }, blk }, ;
    { "����-;祭�", {|| put_val( rpds->kol_pac, 5 ) }, blk }, ;
    { " �㬬� ����", {|| put_kop( schet->SUMMA, 13 ) }, blk }, ;
    { " ����祭���; �㬬�", {|| put_kop( rpds->S_SCH, 13 ) }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - ��室;  ^<Enter>^ - �롮� ���� ��� ��ᬮ�� ��樥�⮢" ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_view_rpd_pd_schet( nk, ob, "edit" ) }
  edit_browse( t_arr )

  Return Nil

// 20.03.13
Function f1_view_rpd_pd_schet( nk, ob, regim )

  Local ret := -1, rec

  If regim == "edit" .and. nk == K_ENTER
    rec := rpds->( RecNo() )
    view_rpd_pd_schet_human( rpds->kod_rpds, Round( schet->SUMMA, 2 ) == Round( rpds->S_SCH, 2 ) )
    Close databases
    //
    r_use( dir_server + "schet_", , "SCHET_" )
    r_use( dir_server + "schet", , "SCHET" )
    r_use( dir_server + "mo_rpds", cur_dir() + "tmp_rpds", "RPDS" )
    Set Relation To schet into SCHET, To schet into SCHET_
    Goto ( rec )
    ret := 0
  Endif

  Return ret

// 20.03.13
Function view_rpd_pd_schet_human( lkod_rpds, is_equal )

  Local blk, t_arr[ BR_LEN ]

  r_use( dir_server + "human_", , "HUMAN_" )
  r_use( dir_server + "human", , "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  g_use( dir_server + "mo_rpdsh", , "rpdSH" )
  Set Relation To KOD_H into HUMAN
  If is_equal
    Index On Str( kod_h, 7 ) to ( cur_dir() + "tmp_rpdsh1" ) For kod_rpds == lkod_rpds
  Else
    Index On Str( kod_h, 7 ) to ( cur_dir() + "tmp_rpdsh1" )
  Endif
  Index On Str( human_->SCHET_ZAP, 6 ) to ( cur_dir() + "tmp_rpdsh" ) For kod_rpds == lkod_rpds
  Set Index to ( cur_dir() + "tmp_rpdsh" ), ( cur_dir() + "tmp_rpdsh1" )
  Go Top
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := 23
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_TITUL ] := "���� � " + AllTrim( schet_->nschet ) + " �� " + ;
    date_8( schet_->dschet ) + " " + f4_view_list_schet()
  t_arr[ BR_TITUL_COLOR ] := "B/W*"
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '�', '�', '�', "N/BG,W+/N,B/BG,W+/B", .t. }
  blk := {|| iif( Round( human->cena_1, 2 ) == Round( rpdsh->S_SL, 2 ), { 1, 2 }, { 3, 4 } ) }
  t_arr[ BR_COLUMN ] := { { " ��;���", {|| Str( human_->SCHET_ZAP, 4 ) }, blk }, ;
    { " �.�.�.", {|| PadR( human->fio, 38 ) }, blk }, ;
    { "��� ஦�.", {|| full_date( human->date_r ) }, blk }, ;
    { " �⮨�����", {|| put_kop( human->cena_1, 10 ) }, blk }, ;
    { " ����祭�", {|| put_kop( rpdsh->s_sl, 10 ) }, blk }, ;
    { " ", {|| f1_view_rpd_pd_schet_human( 1 ) }, blk } }
  t_arr[ BR_EDIT ] := {| nk| f1_view_rpd_pd_schet_human( 2, nk, "edit" ) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - ��室;  ^<Enter>^ - ��ᬮ�� ����� ����" ) }
  edit_browse( t_arr )

  Return Nil

// 20.03.13
Function f1_view_rpd_pd_schet_human( par, nk, regim )

  Local ret := -1, c := " ", rec, lkod, sumr := 0, i, n, r1, r2, ar := {}, buf

  If par == 2 .and. !( regim == "edit" .and. nk == K_ENTER )
    Return ret
  Endif
  If !( Round( human->cena_1, 2 ) == Round( rpdsh->S_SL, 2 ) )
    rec := rpdsh->( RecNo() )
    lkod := rpdsh->kod_h
    If par == 2
      If Select( "RPDS" ) == 0
        r_use( dir_server + "mo_rpds", , "RPDS" )
      Else
        Select RPDS
        Set Index To
      Endif
      If Select( "RPD" ) == 0
        r_use( dir_server + "mo_rpd", , "RPD" )
      Else
        Select RPD
        Set Index To
      Endif
    Endif
    i := 0
    Select RPDSH
    Set Order To 2
    find ( Str( lkod, 7 ) )
    Do While lkod == rpdsh->kod_h .and. !Eof()
      ++i
      If i > 1
        c := "+"
      Endif
      sumr += rpdsh->s_sl
      If par == 2
        rpds->( dbGoto( rpdsh->kod_rpds ) )
        rpd->( dbGoto( rpds->pd ) )
        AAdd( ar, { AllTrim( rpd->n_pd ), rpd->d_pd, rpdsh->s_sl } )
      Endif
      Select RPDSH
      Skip
    Enddo
    ASort( ar, , , {| x, y| x[ 2 ] < y[ 2 ] } )
    For i := 1 To Len( ar )
      ar[ i ] := Str( ar[ i, 3 ], 10, 2 ) + " - ��.� " + ar[ i, 1 ] + " �� " + date_8( ar[ i, 2 ] )
    Next
    Select RPDSH
    Set Order To 1
    Goto ( rec )
    If Round( human->cena_1, 2 ) == Round( sumr, 2 )
      AAdd( ar, "      =    - ��砩 ����祭" )
      c := "="
    Else
      AAdd( ar, Str( human->cena_1 - sumr, 10, 2 ) + " - ��������祭�" )
    Endif
    If par == 2
      n := 0 ; AEval( ar, {| x| n := Max( n, Len( x ) ) } )
      If Row() > 13
        r2 := Row() -1
        r1 := r2 - Len( ar ) -1
      Else
        r1 := Row() + 1
        r2 := r1 + Len( ar ) + 1
      Endif
      buf := box_shadow( r1, 77 -3 -n, r2, 77, color5, "����� ����", "B/W*" )
      For i := 1 To Len( ar )
        @ r1 + i, 77 -1 -n Say ar[ i ] Color color5
      Next
      mybell()
      Inkey( 0 )
      rest_box( buf )
    Endif
    ret := 0
  Endif

  Return iif( par == 1, c, ret )

// 15.12.13
Function ret_menu_rpd_schet( r, c )

  Static si := 4, ;
    arr := { { "�� ��� ����⭮�� ��ਮ��", 1 }, ;
    { "�� ��� �믨᪨ ����", 2 }, ;
    { "�� ��� ॣ����樨 ����", 3 }, ;
    { "�� ��� ����񦭮�� ���㬥��", 4 }, ;
    { "�� ��� �����ࠏ�����儮�㬥�⮢", 5 } }
  Local i, ret, ret_arr

  Default r To T_ROW, c To T_COL - 5
  If popup_2array( arr, r, c, si, 1, @ret_arr ) > 0 .and. ValType( ret_arr ) == "A"
    si := ret_arr[ 2 ]
    ret := { ret_arr[ 2 ], ret_arr[ 1 ] }
  Endif

  Return ret

// 30.03.23 ᯨ᮪ ������� ����祭��
Function i_list_of_pd()

  Local buf := save_maxrow(), lsmo := {}, arr_smo, lmenu, i, j, k, s, t_arr[ 2 ], ;
    fl, arr_m, name_file := cur_dir() + 'spis_pd', sh := 80, HH := 60

  If ( lmenu := ret_menu_rpd_schet() ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month( T_ROW, T_COL - 5 ) ) == NIL
    Return Nil
  Endif
  If lmenu[ 1 ] == 1 .and. !is_otch_period( arr_m )
    Return Nil
  Endif
  mywait()
  dbCreate( cur_dir() + "tmp", { ;
    { "tip", "N", 1, 0 }, ;
    { "rec", "N", 7, 0 }, ;
    { "rec_up", "N", 7, 0 }, ;
    { "plat", "C", 5, 0 }, ;
    { "summa", "N", 15, 2 } } )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( tip, 1 ) + Str( rec, 7 ) to ( cur_dir() + "tmp" )
  dbCreate( cur_dir() + "tmp1", { ;
    { "tip", "N", 1, 0 }, ;
    { "rec", "N", 7, 0 }, ;
    { "bukva", "C", 1, 0 }, ;
    { "summa", "N", 15, 2 } } )
  Use ( cur_dir() + "tmp1" ) new
  Index On Str( tip, 1 ) + Str( rec, 7 ) + bukva to ( cur_dir() + "tmp1" )
  r_use( dir_server + "schet_", , "SCHET_" )
  r_use( dir_server + "schet", , "SCHET" )
  Set Relation To RecNo() into SCHET_
  r_use( dir_server + "mo_otd", , "OTD" )
  r_use( dir_server + "human_", , "HUMAN_" )
  r_use( dir_server + "human", , "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To otd into OTD
  r_use( dir_server + "mo_rpdsh", , "RPDSH" )
  Index On Str( KOD_RPDS, 6 ) to ( cur_dir() + "tmprpdsh" )
  r_use( dir_server + "mo_rpds", , "RPDS" )
  Index On Str( PD, 6 ) to ( cur_dir() + "tmprpds" )
  r_use( dir_server + "mo_rpd", , "RPD" )
  Index On Str( kod_xml, 6 ) to ( cur_dir() + "tmprpd" )
  r_use( dir_server + "mo_xml", , "MO_XML" )
  Index On dfile to ( cur_dir() + "tmp_xml" ) For TIP_IN == _XML_FILE_RPD
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say date_8( mo_xml->DFILE ) Color cColorWait
    If iif( lmenu[ 1 ] == 5, Between( mo_xml->DFILE, arr_m[ 5 ], arr_m[ 6 ] ), .t. )
      Select RPD
      find ( Str( mo_xml->kod, 6 ) )
      Do While mo_xml->kod == rpd->kod_xml .and. !Eof()
        If iif( lmenu[ 1 ] == 4, Between( rpd->D_PD, arr_m[ 5 ], arr_m[ 6 ] ), .t. )
          Select RPDS
          find ( Str( rpd->pd, 6 ) )
          Do While rpd->pd == rpds->pd .and. !Eof()
            schet->( dbGoto( rpds->schet ) )
            fl := .t.
            If lmenu[ 1 ] == 1
              fl := between_otch_period( schet_->dschet, schet_->NYEAR, schet_->NMONTH, arr_m[ 5 ], arr_m[ 6 ] )
            Elseif lmenu[ 1 ] == 2
              fl := Between( schet_->dschet, arr_m[ 5 ], arr_m[ 6 ] )
            Elseif lmenu[ 1 ] == 3
              fl := ( schet_->NREGISTR == 0 .and. Between( date_reg_schet(), arr_m[ 5 ], arr_m[ 6 ] ) )
            Endif
            If fl
              If AScan( lsmo, rpds->plat ) == 0
                AAdd( lsmo, rpds->plat )
              Endif
              arr := { { 1, 0 }, ;
                { mo_xml->kod, 1 }, ;
                { rpd->pd, 2 }, ;
                { rpds->KOD_RPDS, 3 };
                }
              For i := 1 To Len( arr )
                Select TMP
                find ( Str( arr[ i, 2 ], 1 ) + Str( arr[ i, 1 ], 7 ) )
                If !Found()
                  Append Blank
                  tmp->tip := arr[ i, 2 ]
                  tmp->rec := arr[ i, 1 ]
                  If i > 1
                    tmp->rec_up := arr[ i - 1, 1 ]
                  Endif
                  tmp->plat := rpds->plat
                Endif
                tmp->summa += rpds->S_SCH
                Select TMP1
                find ( Str( arr[ i, 2 ], 1 ) + Str( arr[ i, 1 ], 7 ) + schet_->BUKVA )
                If !Found()
                  Append Blank
                  tmp1->tip := arr[ i, 2 ]
                  tmp1->rec := arr[ i, 1 ]
                  tmp1->bukva := schet_->BUKVA
                Endif
                tmp1->summa += rpds->S_SCH
              Next
              Select RPDSH
              find ( Str( rpds->kod_rpds, 6 ) )
              Do While rpds->kod_rpds == rpdsh->kod_rpds .and. !Eof()
                Select TMP
                find ( Str( 4, 1 ) + Str( rpdsh->KOD_H, 7 ) )
                If !Found()
                  Append Blank
                  tmp->tip := 4
                  tmp->rec := rpdsh->KOD_H
                  tmp->rec_up := rpds->KOD_RPDS
                  tmp->plat := rpds->plat
                Endif
                tmp->summa += rpdsh->S_SL
                Select RPDSH
                Skip
              Enddo
            Endif
            Select RPDS
            Skip
          Enddo
        Endif
        Select RPD
        Skip
      Enddo
    Endif
    Select MO_XML
    Skip
  Enddo
  arr_bukva := {}
  Select TMP1
  find ( Str( 0, 1 ) )
  Do While tmp1->tip == 0 .and. !Eof()
    If !Empty( bukva ) .and. AScan( arr_bukva, {| x| x[ 2 ] == tmp1->bukva } ) == 0 ;
        .and. ( j := AScan( get_bukva(), {| x| x[ 2 ] == tmp1->bukva } ) ) > 0
      AAdd( arr_bukva, { get_bukva()[ j, 1 ], get_bukva()[ j, 2 ], 0 } )
    Endif
    Skip
  Enddo
  Close databases
  arr_smo := {}
  For i := 1 To Len( glob_arr_smo )
    If AScan( lsmo, {| x| Int( Val( x ) ) == glob_arr_smo[ i, 2 ] } ) > 0
      AAdd( arr_smo, glob_arr_smo[ i ] )
    Endif
  Next
  rest_box( buf )
  If Empty( arr_smo )
    Return func_error( 4, "��� ���ଠ樨!" )
  Endif
  ireg := 1
  Do While .t.
    mybell( 1, OK )
    Keyboard ""
    If Len( arr_smo ) == 1
      lsmo := AClone( arr_smo )
    Elseif ( lsmo := bit_popup( T_ROW, T_COL - 5, arr_smo ) ) == NIL
      Exit
    Endif
    If Len( arr_bukva ) == 1
      lbukva := AClone( arr_bukva )
    Elseif ( lbukva := bit_popup( T_ROW, T_COL - 5, arr_bukva ) ) == NIL
      Exit
    Endif
    AEval( lbukva, {| x, i| lbukva[ i, 3 ] := 0 } )
    mas_pmt := { ;
      "������� ������� ���㬥�⮢", ;
      "��� + ������ ���㬥���", ;
      "��� + �� + ����", ;
      "��� + �� + ���� + ��樥���";
      }
    If ( ireg := popup_prompt( T_ROW, T_COL - 5, ireg, mas_pmt ) ) == 0
      Exit
    Endif
    n_file := name_file + lstr( ireg ) + stxt()
    mywait()
    fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( PadR( glob_mo[ _MO_SHORT_NAME ], sh - 14 ) + date_8( sys_date ) + " " + hour_min( Seconds() ) )
    add_string( "" )
    add_string( Center( "������ ����祭��", sh ) )
    add_string( Center( arr_m[ 4 ], sh ) )
    add_string( Center( "[ " + lmenu[ 2 ] + " ]", sh ) )
    If Len( lsmo ) < Len( arr_smo )
      s := ""
      AEval( lsmo, {| x| s += x[ 1 ] + ", " } )
      add_string( Center( "���: " + Left( s, Len( s ) -2 ), sh ) )
    Endif
    If Len( lbukva ) < Len( arr_bukva )
      s := ""
      AEval( lbukva, {| x| s += x[ 2 ] + ", " } )
      add_string( Center( "���� ��⮢: " + Left( s, Len( s ) -2 ), sh ) )
    Endif
    add_string( "" )
    sv := 0
    Do Case
    Case ireg == 1
      arr_title := { ;
        "��������������������������������������������������������������������������������", ;
        "     �㬬�     �  ������������ 䠩�� ���  �   ���                              ", ;
        "��������������������������������������������������������������������������������" }
      AEval( arr_title, {| x| add_string( x ) } )
      r_use( dir_server + "mo_xml", , "MO_XML" )
      Use ( cur_dir() + "tmp1" ) index ( cur_dir() + "tmp1" ) new
      Use ( cur_dir() + "tmp" ) new
      Set Relation To rec into MO_XML
      Index On DToS( mo_xml->DFILE ) + mo_xml->FNAME to ( cur_dir() + "tmp_" ) For tip == 1
      Go Top
      Do While !Eof()
        If AScan( lsmo, {| x| Int( Val( tmp->plat ) ) == x[ 2 ] } ) > 0
          v := 0 ; arr := {}
          Select TMP1
          find ( Str( 1, 1 ) + Str( tmp->rec, 7 ) )
          Do While tmp1->tip == 1 .and. tmp1->rec == tmp->rec .and. !Eof()
            If ( j := AScan( lbukva, {| x| tmp1->bukva == x[ 2 ] } ) ) > 0
              v += tmp1->summa
              AAdd( arr, Str( tmp1->summa, 16, 2 ) + " " + lbukva[ j, 1 ] )
              lbukva[ j, 3 ] += tmp1->summa
            Endif
            Skip
          Enddo
          If !Empty( v )
            sv += v
            If verify_ff( HH - 2 -Len( arr ), .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( Str( v, 15, 2 ) + " " + PadR( mo_xml->FNAME, 27 ) + full_date( mo_xml->DFILE ) )
            add_string( Replicate( "-", sh ) )
            AEval( arr, {| x| add_string( x ) } )
            add_string( Replicate( "-", sh ) )
          Endif
        Endif
        Select TMP
        Skip
      Enddo
    Case ireg == 2
      arr_title := { ;
        "��������������������������������������������������������������������������������", ;
        "     �㬬�     �  ����� ����񦭮�� ���-� �   ���                              ", ;
        "��������������������������������������������������������������������������������" }
      AEval( arr_title, {| x| add_string( x ) } )
      r_use( dir_server + "mo_rpd", , "RPD" )
      r_use( dir_server + "mo_xml", , "MO_XML" )
      Use ( cur_dir() + "tmp1" ) index ( cur_dir() + "tmp1" ) new
      Use ( cur_dir() + "tmp" ) new
      Set Relation To rec into MO_XML, To rec into RPD
      Index On DToS( mo_xml->DFILE ) + mo_xml->FNAME to ( cur_dir() + "tmp_" ) For tip == 1
      Index On Str( rec_up, 7 ) + DToS( rpd->D_PD ) + rpd->N_PD to ( cur_dir() + "tmp2_" ) For tip == 2
      Set Index to ( cur_dir() + "tmp_" ), ( cur_dir() + "tmp2_" )
      Set Order To 1
      Go Top
      Do While !Eof()
        If AScan( lsmo, {| x| Int( Val( tmp->plat ) ) == x[ 2 ] } ) > 0
          s_xml := PadL( " ���:", 15, "=" ) + " " + AllTrim( mo_xml->FNAME ) + " �� " + full_date( mo_xml->DFILE )
          rec_tmp := tmp->( RecNo() )
          lrec := tmp->rec
          Select TMP
          Set Order To 2
          find ( Str( lrec, 7 ) )
          Do While lrec == tmp->rec_up .and. !Eof()
            v := 0 ; arr := {}
            Select TMP1
            find ( Str( 2, 1 ) + Str( tmp->rec, 7 ) )
            Do While tmp1->tip == 2 .and. tmp1->rec == tmp->rec .and. !Eof()
              If ( j := AScan( lbukva, {| x| tmp1->bukva == x[ 2 ] } ) ) > 0
                v += tmp1->summa
                AAdd( arr, Str( tmp1->summa, 16, 2 ) + " " + lbukva[ j, 1 ] )
                lbukva[ j, 3 ] += tmp1->summa
              Endif
              Skip
            Enddo
            If !Empty( v )
              If !Empty( s_xml )
                add_string( s_xml )
                add_string( Replicate( "-", sh ) )
                s_xml := ""
              Endif
              sv += v
              If verify_ff( HH - 2 -Len( arr ), .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              add_string( Str( v, 15, 2 ) + " " + PadR( rpd->N_PD, 27 ) + full_date( rpd->D_PD ) )
              add_string( Replicate( "-", sh ) )
              AEval( arr, {| x| add_string( x ) } )
              add_string( Replicate( "-", sh ) )
            Endif
            Select TMP
            Skip
          Enddo
          Select TMP
          Set Order To 1
          Goto ( rec_tmp )
        Endif
        Select TMP
        Skip
      Enddo
    Case ireg == 3
      arr_title := { ;
        "��������������������������������������������������������������������������������", ;
        "     �㬬�     � ����� ����   ���� ���⠳��� ॣ����樨                     ", ;
        "��������������������������������������������������������������������������������" }
      AEval( arr_title, {| x| add_string( x ) } )
      r_use( dir_server + "schet_", , "SCHET_" )
      r_use( dir_server + "mo_rpds", , "RPDS" )
      Set Relation To schet into SCHET_
      r_use( dir_server + "mo_rpd", , "RPD" )
      r_use( dir_server + "mo_xml", , "MO_XML" )
      Use ( cur_dir() + "tmp1" ) index ( cur_dir() + "tmp1" ) new
      Use ( cur_dir() + "tmp" ) new
      Set Relation To rec into MO_XML, To rec into RPD, To rec into RPDS
      Index On DToS( mo_xml->DFILE ) + mo_xml->FNAME to ( cur_dir() + "tmp_" ) For tip == 1
      Index On Str( rec_up, 7 ) + DToS( rpd->D_PD ) + rpd->N_PD to ( cur_dir() + "tmp2_" ) For tip == 2
      Index On Str( rec_up, 7 ) + DToS( schet_->DSCHET ) + schet_->NSCHET to ( cur_dir() + "tmp3_" ) For tip == 3
      Set Index to ( cur_dir() + "tmp_" ), ( cur_dir() + "tmp2_" ), ( cur_dir() + "tmp3_" )
      Set Order To 1
      Go Top
      Do While !Eof()
        If AScan( lsmo, {| x| Int( Val( tmp->plat ) ) == x[ 2 ] } ) > 0
          s_xml := PadL( " ���:", 15, "=" ) + " " + AllTrim( mo_xml->FNAME ) + " �� " + full_date( mo_xml->DFILE )
          rec_tmp := tmp->( RecNo() )
          lrec := tmp->rec
          Select TMP
          Set Order To 2
          find ( Str( lrec, 7 ) )
          Do While lrec == tmp->rec_up .and. !Eof()
            s_pd := " " + PadL( " ��:", 14, ">" ) + " " + AllTrim( rpd->N_PD ) + " �� " + full_date( rpd->D_PD )
            rec_tmp2 := tmp->( RecNo() )
            lrec2 := tmp->rec
            v := 0 ; arr := {}
            Select TMP
            Set Order To 3
            find ( Str( lrec2, 7 ) )
            Do While lrec2 == tmp->rec_up .and. !Eof()
              If ( j := AScan( lbukva, {| x| schet_->bukva == x[ 2 ] } ) ) > 0
                v += tmp->summa
                AAdd( arr, Str( tmp->summa, 15, 2 ) + " " + ;
                  PadR( schet_->NSCHET, 16 ) + full_date( schet_->DSCHET ) + " " + ;
                  iif( schet_->NREGISTR == 0, full_date( date_reg_schet() ), "" ) )
                lbukva[ j, 3 ] += tmp->summa
              Endif
              Skip
            Enddo
            If !Empty( v )
              If !Empty( s_xml )
                add_string( s_xml )
                add_string( Replicate( "-", sh ) )
                s_xml := ""
              Endif
              If !Empty( s_pd )
                add_string( s_pd )
                add_string( Replicate( "-", sh ) )
                s_pd := ""
              Endif
              sv += v
              If verify_ff( HH - Len( arr ), .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              AEval( arr, {| x| add_string( x ) } )
              add_string( Replicate( "-", sh ) )
            Endif
            Select TMP
            Set Order To 2
            Goto ( rec_tmp2 )
            Skip
          Enddo
          Select TMP
          Set Order To 1
          Goto ( rec_tmp )
        Endif
        Select TMP
        Skip
      Enddo
    Case ireg == 4
      arr_title := { ;
        "��������������������������������������������������������������������������������", ;
        "   �����  ��㬬� ���� � � ����, ��� ��樥��, ��., �ப� ��祭��          ", ;
        "��������������������������������������������������������������������������������" }
      AEval( arr_title, {| x| add_string( x ) } )
      r_use( dir_server + "mo_otd", , "OTD" )
      r_use( dir_server + "human_", , "HUMAN_" )
      r_use( dir_server + "human", , "HUMAN" )
      Set Relation To RecNo() into HUMAN_, To otd into OTD
      r_use( dir_server + "schet_", , "SCHET_" )
      r_use( dir_server + "mo_rpds", , "RPDS" )
      Set Relation To schet into SCHET_
      r_use( dir_server + "mo_rpd", , "RPD" )
      r_use( dir_server + "mo_xml", , "MO_XML" )
      Use ( cur_dir() + "tmp1" ) index ( cur_dir() + "tmp1" ) new
      Use ( cur_dir() + "tmp" ) new
      Set Relation To rec into MO_XML, To rec into RPD, To rec into RPDS, To rec into HUMAN
      Index On DToS( mo_xml->DFILE ) + mo_xml->FNAME to ( cur_dir() + "tmp_" ) For tip == 1
      Index On Str( rec_up, 7 ) + DToS( rpd->D_PD ) + rpd->N_PD to ( cur_dir() + "tmp2_" ) For tip == 2
      Index On Str( rec_up, 7 ) + DToS( schet_->DSCHET ) + schet_->NSCHET to ( cur_dir() + "tmp3_" ) For tip == 3
      Index On Str( rec_up, 7 ) + Str( human_->SCHET_ZAP, 6 ) to ( cur_dir() + "tmp4_" ) For tip == 4
      Set Index to ( cur_dir() + "tmp_" ), ( cur_dir() + "tmp2_" ), ( cur_dir() + "tmp3_" ), ( cur_dir() + "tmp4_" )
      Set Order To 1
      Go Top
      Do While !Eof()
        If AScan( lsmo, {| x| Int( Val( tmp->plat ) ) == x[ 2 ] } ) > 0
          s_xml := PadL( " ���:", 15, "=" ) + " " + AllTrim( mo_xml->FNAME ) + " �� " + full_date( mo_xml->DFILE )
          rec_tmp := tmp->( RecNo() )
          lrec := tmp->rec
          Select TMP
          Set Order To 2
          find ( Str( lrec, 7 ) )
          Do While lrec == tmp->rec_up .and. !Eof()
            s_pd := " " + PadL( " ��:", 14, ">" ) + " " + AllTrim( rpd->N_PD ) + " �� " + full_date( rpd->D_PD )
            rec_tmp2 := tmp->( RecNo() )
            lrec2 := tmp->rec
            Select TMP
            Set Order To 3
            find ( Str( lrec2, 7 ) )
            Do While lrec2 == tmp->rec_up .and. !Eof()
              If ( j := AScan( lbukva, {| x| schet_->bukva == x[ 2 ] } ) ) > 0
                s_schet := "  " + PadL( " ����:", 13, "<" ) + " " + ;
                  AllTrim( schet_->NSCHET ) + " " + full_date( schet_->DSCHET ) + ;
                  iif( schet_->NREGISTR == 0, " (ॣ." + full_date( date_reg_schet() ) + ")", "" )
                rec_tmp3 := tmp->( RecNo() )
                lrec3 := tmp->rec
                Select TMP
                Set Order To 4
                find ( Str( lrec3, 7 ) )
                Do While lrec3 == tmp->rec_up .and. !Eof()
                  If verify_ff( HH - 6, .t., sh )
                    AEval( arr_title, {| x| add_string( x ) } )
                  Endif
                  If !Empty( s_xml )
                    add_string( s_xml )
                    add_string( Replicate( "-", sh ) )
                  Endif
                  If !Empty( s_pd )
                    add_string( s_pd )
                    add_string( Replicate( "-", sh ) )
                  Endif
                  If !Empty( s_schet )
                    add_string( s_schet )
                    add_string( Replicate( "-", sh ) )
                  Endif
                  s_xml := s_pd := s_schet := ""
                  sv += tmp->summa
                  If Round( tmp->summa, 2 ) < Round( human->cena_1, 2 )
                    s := " <"
                  Elseif Round( tmp->summa, 2 ) > Round( human->cena_1, 2 )
                    s := " >"
                  Else
                    s := " ="
                  Endif
                  add_string( Str( tmp->summa, 11, 2 ) + s + Str( human->cena_1, 11, 2 ) + " " + ;
                    lstr( human_->SCHET_ZAP ) + ". " + AllTrim( human->fio ) + " " + ;
                    iif( Empty( otd->SHORT_NAME ), "", "[" + AllTrim( otd->SHORT_NAME ) + "] " ) + ;
                    date_8( human->n_data ) + "-" + date_8( human->k_data ) )
                  lbukva[ j, 3 ] += tmp->summa
                  Select TMP
                  Skip
                Enddo
                add_string( Replicate( "-", sh ) )
                Select TMP
                Set Order To 3
                Goto ( rec_tmp3 )
              Endif
              Select TMP
              Skip
            Enddo
            Select TMP
            Set Order To 2
            Goto ( rec_tmp2 )
            Skip
          Enddo
          Select TMP
          Set Order To 1
          Goto ( rec_tmp )
        Endif
        Select TMP
        Skip
      Enddo
    Endcase
    If !Empty( sv )
      arr := {}
      AEval( lbukva, {| x| iif( Empty( x[ 3 ] ), , AAdd( arr, Str( x[ 3 ], 16, 2 ) + " " + x[ 1 ] ) ) } )
      If verify_ff( HH - 2 -Len( arr ), .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( Str( sv, 15, 2 ) + " �_�_�_�_�" )
      add_string( Replicate( "-", sh ) )
      AEval( arr, {| x| add_string( x ) } )
      add_string( Replicate( "-", sh ) )
    Endif
    FClose( fp )
    Close databases
    rest_box( buf )
    viewtext( n_file, , , , .t., , , 2 )
  Enddo

  Return Nil

// 05.06.23 ������ ��� �ᯥ�⨧�
Function ret_vid_eks()

  Local i

  If rak->TYPEK > 0
    i := rak->SKONT // �� 2019 ����
  Elseif rak->kont < 4    // ����� ࠡ�⠥� �� F006
    i := rak->kont -1    // 1, 2, 3
  Elseif rak->kont < 20
    i := 0 // ���
  Elseif rak->kont < 30
    i := 1 // ���
  Elseif rak->kont < 50
    i := 2 // ����
  Elseif rak->kont < 70  // c 25.05.2021 ���
    i := 1 // ���
  Elseif rak->kont < 88  // c 05.06.2023  �� 87
    i := 2 // ����
  Elseif rak->kont == 88
    i := 1 // ���
  Elseif rak->kont == 89
    i := 2 // ����
  Elseif rak->kont < 94
    i := 1 // ���
  Else      //
    i := 2 // ����
  Endif

  Return i

// 28.06.22 ���� ᢥન �� ���
Function akt_sverki_smo()

  Static sitog := { ;
    "2. ���� �㬬� �।�� �� ������ �� ��ॣ.��⠬ �� �����", ;
    "3. �㬬� �।��, 㤥ঠ���� �� १���⠬ ����஫�", ;
    " 3.1. �� १���⠬ ���", ;
    " 3.2. �� १���⠬ ���", ;
    " 3.3. �� १���⠬ ����", ;
    "5. ����᫥���� �㬬� �।��", ;
    "      �஬� ⮣�, �㬬� ���䮢" }
  Local buf := save_maxrow(), lsmo, i, j, k, s, aitog[ 2, 7 ], hitog[ 2, 7 ], ismo, vid_eks, ;
    b1, b2, a1, a2, name_file := "aktsver", sh := 80, HH := 60, is_smp := { .f., .f. }, ;
    mas_txt[ 30 ], k_txt := 0, ii

  If ( lsmo := ret_actual_smo() ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month(, , , 3 ) ) == NIL
    Return Nil
  Endif
  mywait()
  ret_days_for_akt_sverki( arr_m, @b1, @b2, @a1, @a2 )
  adbf := { { "tip", "N", 1, 0 }, ;
    { "nomer", "N", 1, 0 }, ;
    { "ndoc", "C", 25, 0 }, ;
    { "ddoc", "D", 8, 0 }, ;
    { "nsch", "C", 15, 0 }, ;
    { "dsch", "D", 8, 0 }, ;
    { "summa", "N", 15, 2 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) new
  afillall( aitog, 0 )
  r_use( dir_server + "schet_", , "SCHET_" )
  r_use( dir_server + "schet", , "SCHET" )
  Set Relation To RecNo() into SCHET_
  Go Top
  Do While !Eof()
    If schet_->IS_DOPLATA == 0 .and. schet_->smo == lsmo[ 1 ] .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
      ismo := Int( Val( schet_->smo ) )
      @ MaxRow(), 0 Say PadR( "� " + AllTrim( schet_->NSCHET ) + " �� " + date_8( schet_->DSCHET ), 28 ) Color cColorWait
      mdate := date_reg_schet() // ��� ॣ����樨
      If Between( mdate, arr_m[ 5 ] + iif( ismo == 34, 0, b1 ), arr_m[ 6 ] + iif( ismo == 34, 0, b2 ) )
        ltip := iif( schet_->BUKVA == "E", 2, 1 )
        is_smp[ ltip ] := .t.
        aitog[ ltip, 1 ] += schet->SUMMA
        Select TMP
        Append Blank
        tmp->tip := ltip
        tmp->nomer := 1
        tmp->nsch := schet_->NSCHET
        tmp->dsch := schet_->DSCHET
        tmp->summa := schet->SUMMA
      Endif
    Endif
    Select SCHET
    Skip
  Enddo
  r_use( dir_server + "human_", , "HUMAN_" )
  r_use( dir_server + "human", , "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  r_use( dir_server + "mo_raksh", , "RAKSH" )
  Set Relation To KOD_H into HUMAN
  Index On Str( kod_raks, 6 ) to ( cur_dir() + "tmp_raksh" ) For !emptyall( SANK_MEK, SANK_MEE, SANK_EKMP, PENALTY )
  r_use( dir_server + "mo_raks", , "RAKS" )
  Set Relation To schet into SCHET
  Index On Str( akt, 6 ) to ( cur_dir() + "tmpraks" ) For plat == lsmo[ 1 ]
  r_use( dir_server + "mo_rak", , "RAK" )
  Index On Str( kod_xml, 6 ) to ( cur_dir() + "tmprak" ) // for between(dakt,arr_m[5],arr_m[6])
  r_use( dir_server + "mo_xml", , "MO_XML" )
  If ismo == 34
    Index On dfile to ( cur_dir() + "tmp_xml" ) For TIP_IN == _XML_FILE_RAK .and. Between( dfile, arr_m[ 5 ], arr_m[ 6 ] )
  Else
    Index On dfile to ( cur_dir() + "tmp_xml" ) For TIP_IN == _XML_FILE_RAK .and. Between( dfile, arr_m[ 5 ] + a1, arr_m[ 6 ] + a2 )
  Endif
  Go Top
  Do While !Eof()
    Select RAK
    find ( Str( mo_xml->kod, 6 ) )
    Do While mo_xml->kod == rak->kod_xml .and. !Eof()
      vid_eks := ret_vid_eks()
      Select RAKS
      find ( Str( rak->akt, 6 ) )
      Do While rak->akt == raks->akt .and. !Eof()
        ltip := iif( schet_->BUKVA == "E", 2, 1 )
        s := raks->SANK_MEK + raks->SANK_MEE + raks->SANK_EKMP
        If !emptyall( s, raks->PENALTY )
          is_smp[ ltip ] := .t.
          If vid_eks == 2 .or. !Empty( raks->SANK_EKMP )
            s := f1akt_sverki_smo( 5, s, hitog )
            aitog[ ltip, 5 ] += s
          Elseif vid_eks == 1 .or. !Empty( raks->SANK_MEE )
            s := f1akt_sverki_smo( 4, s, hitog )
            aitog[ ltip, 4 ] += s
          Else
            s := f1akt_sverki_smo( 3, s, hitog )
            aitog[ ltip, 3 ] += s
          Endif
          aitog[ ltip, 2 ] += s
          //
          s := f1akt_sverki_smo( 7, raks->PENALTY, hitog )
          aitog[ ltip, 7 ] += s
        Endif
        Select RAKS
        Skip
      Enddo
      Select RAK
      Skip
    Enddo
    Select MO_XML
    Skip
  Enddo
  Select RAKS
  Set Relation To
  r_use( dir_server + "mo_rpds", , "RPDS" )
  Set Relation To schet into SCHET
  Index On Str( PD, 6 ) to ( cur_dir() + "tmprpds" ) For plat == lsmo[ 1 ]
  r_use( dir_server + "mo_rpd", , "RPD" )
  Index On Str( kod_xml, 6 ) to ( cur_dir() + "tmprpd" ) // for between(d_pd,arr_m[5],arr_m[6])
  Select MO_XML
  If ismo == 34
    Index On dfile to ( cur_dir() + "tmp_xml" ) For TIP_IN == _XML_FILE_RPD .and. Between( dfile, arr_m[ 5 ], arr_m[ 6 ] )
  Else
    Index On dfile to ( cur_dir() + "tmp_xml" ) For TIP_IN == _XML_FILE_RPD .and. Between( dfile, arr_m[ 5 ] + a1, arr_m[ 6 ] + a2 )
  Endif
  Go Top
  Do While !Eof()
    Select RPD
    find ( Str( mo_xml->kod, 6 ) )
    Do While mo_xml->kod == rpd->kod_xml .and. !Eof()
      Select RPDS
      find ( Str( rpd->pd, 6 ) )
      Do While rpd->pd == rpds->pd .and. !Eof()
        ltip := iif( schet_->BUKVA == "E", 2, 1 )
        is_smp[ ltip ] := .t.
        aitog[ ltip, 6 ] += rpds->S_SCH
        Select TMP
        Append Blank
        tmp->tip := ltip
        tmp->nomer := 6
        tmp->ndoc := rpd->N_PD
        tmp->ddoc := rpd->D_PD
        tmp->nsch := schet_->NSCHET
        tmp->dsch := schet_->DSCHET
        tmp->summa := rpds->S_SCH
        Select RPDS
        Skip
      Enddo
      Select RPD
      Skip
    Enddo
    Select MO_XML
    Skip
  Enddo
  Close databases
  //
  mas_pmt := { "��ᯥ�⪠ ��� ᢥન" }
  If is_smp[ 1 ]
    AAdd( mas_pmt, "��⮪�� ��� ᢥન" )
  Endif
  If is_smp[ 2 ]
    AAdd( mas_pmt, "��⮪�� ��� ᢥન ��� ���" )
  Endif
  rest_box( buf )
  If ( ireg := popup_prompt( T_ROW, T_COL - 5, 1, mas_pmt ) ) == 0
    Return Nil
  Endif
  If ireg == 2
    name_file += "p"
  Elseif ireg == 3
    name_file += "s"
  Endif
  mywait()
  fp := FCreate( name_file + stxt() ) ; n_list := 1 ; tek_stroke := 0
  add_string( glob_mo[ _MO_SHORT_NAME ] )
  If ireg == 1
    For i := 1 To 2
      If is_smp[ i ]
        add_string( "" )
        If i == 1
          add_string( Center( "��� ᢥન (�� ���⮬ ���)", sh ) )
        Else
          add_string( Center( "��� ᢥન (���)", sh ) )
        Endif
        add_string( Center( lsmo[ 2 ], sh ) )
        add_string( Center( "�� ���ﭨ� �� " + date_month( arr_m[ 6 ] + 1, .t. ), sh ) )
        add_string( "" )
        For j := 1 To 6
          add_string( PadR( sitog[ j ], sh - 15 ) + Str( aitog[ i, j ], 15, 2 ) )
          If j == 5 .and. !Empty( aitog[ i, 7 ] )
            add_string( PadR( sitog[ 7 ], sh - 15 ) + Str( aitog[ i, 7 ], 15, 2 ) )
          Endif
        Next
      Endif
    Next
  Else
    Use ( cur_dir() + "tmp" ) new
    Index On Str( tip, 1 ) + Str( nomer, 1 ) + DToS( dsch ) + nsch to ( cur_dir() + "tmp" )
    arr_title := { ;
      "��������������������������������������������������������������������������������", ;
      "     �㬬�     �   ����� � ��� ����   �� � ��� ��� ����஫� (����.���㬥��)", ;
      "��������������������������������������������������������������������������������" }
    add_string( "" )
    If ireg == 2
      add_string( Center( "��⮪�� ��� ᢥન (�� ���⮬ ���)", sh ) )
    Else
      add_string( Center( "��⮪�� ��� ᢥન (���)", sh ) )
    Endif
    add_string( Center( lsmo[ 2 ], sh ) )
    add_string( Center( "�� ���ﭨ� �� " + date_month( arr_m[ 6 ] + 1, .t. ), sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    For k := 1 To 7
      If k == 6
        j := 7
      Elseif k == 7
        j := 6
      Else
        j := k
      Endif
      If verify_ff( HH - 3, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If j > 1 .and. skol > 0
        add_string( Replicate( "-", sh ) )
      Endif
      skol := 0
      add_string( Str( aitog[ ireg - 1, j ], 15, 2 ) + " " + sitog[ j ] )
      add_string( Replicate( "-", sh ) )
      If eq_any( j, 3, 4, 5, 7 ) .and. ValType( hitog[ ireg - 1, j ] ) == "A"
        ASort( hitog[ ireg - 1, j ], , , {| x, y| x[ 1 ] < y[ 1 ] } )
        For j1 := 1 To Len( hitog[ ireg - 1, j ] )
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          k_txt := perenos( mas_txt, AllTrim( ret_t005_smol( hitog[ ireg - 1, j, j1, 1 ] ) ), 38 )
          add_string( Str( hitog[ ireg - 1, j, j1, 2 ], 15, 2 ) + ;
            " (" + lstr( hitog[ ireg - 1, j, j1, 3 ] ) + " �/�) " + ;
            mas_txt[ 1 ] )
          For ii := 2 To k_txt
            add_string( Space( 42 ) + mas_txt[ ii ] )
          Next
        Next
        add_string( Replicate( "-", sh ) )
      Endif
      find ( Str( ireg - 1, 1 ) + Str( j, 1 ) )
      Do While tmp->tip == ireg - 1 .and. tmp->nomer == j .and. !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        s := Str( tmp->summa, 15, 2 ) + " " + tmp->nsch + " " + date_8( tmp->dsch ) + "  "
        If !Empty( tmp->ndoc )
          s += AllTrim( tmp->ndoc ) + " "
        Endif
        If !Empty( tmp->ddoc )
          s += "�� " + date_8( tmp->ddoc )
        Endif
        ++skol
        add_string( s )
        Skip
      Enddo
    Next k
  Endif
  Close databases
  FClose( fp )
  rest_box( buf )
  viewtext( name_file + stxt(), , , , .t., , , 2 )

  Return Nil

// 14.02.19
Function f1akt_sverki_smo( k, s, hitog )

  Local i, s1

  If !Empty( s )
    s := 0 // ����塞, �.�. � ��� �� �஢�� ���� �.�. �訡��
    Select RAKSH
    find ( Str( raks->kod_raks, 6 ) )
    Do While raks->kod_raks == raksh->kod_raks .and. !Eof()
      If k == 7
        s1 := raksh->penalty
      Else
        s1 := raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
      Endif
      If !Empty( s1 )
        If hitog[ ltip, k ] == NIL
          hitog[ ltip, k ] := {}
        Endif
        If ( i := AScan( hitog[ ltip, k ], {| x| x[ 1 ] == raksh->REFREASON } ) ) == 0
          AAdd( hitog[ ltip, k ], { raksh->REFREASON, 0, 0 } ) ; i := Len( hitog[ ltip, k ] )
        Endif
        hitog[ ltip, k, i, 2 ] += s1
        hitog[ ltip, k, i, 3 ] ++
        s += s1
      Endif
      Select RAKSH
      Skip
    Enddo
    If !Empty( s )
      Select TMP
      Append Blank
      tmp->tip := ltip
      tmp->nomer := k
      tmp->ndoc := rak->NAKT
      tmp->ddoc := rak->DAKT
      tmp->nsch := schet_->NSCHET
      tmp->dsch := schet_->DSCHET
      tmp->summa := s
    Endif
  Endif

  Return s

// 30.03.23 ��ᯥ�⪠ ���ଠ樨 �� ���⠢����� ��⠬, ���� �� ���, ����� � �����
Function pr1_oborot_schet()

  Static arr_smo
  Static mm_poisk := { { "�� ��� ����⭮�� ��ਮ��", 0 }, ;
    { "�� ��� ���⠢����� ���", 1 }, ;
    { "�� ��� ॣ����樨 ���", 2 } }
  Static mm_dolg := { { "�� ��ப�", 0 }, ;
    { "⮫쪮 ��ப� � ������", 1 } }
  Static mm_schet := { { "�⮣� �� ���", 0 }, ;
    { "�⮣� �� ��०�����/�⤥�����", 1 }, ;
    { "�⮣� �� ⨯�� ��⮢", 2 }, ;
    { "�⤥�쭮 �� ������� �����", 3 } }
  Static s1poisk := 0, s1schet := 3, s1dolg := 0, s1smo := 0, s1bukva := ""
  Local buf := SaveScreen(), i, ar, s, r := 13

  If Empty( s1bukva )
    s1bukva := ''
    For i := 1 To Len( get_bukva() )
      s1bukva += get_bukva()[ i, 2 ]
    Next
  Endif
  If arr_smo == NIL
    arr_smo := mo_cut_menu( glob_arr_smo )
    For i := 1 To Len( arr_smo )
      arr_smo[ i, 3 ] := PadR( lstr( arr_smo[ i, 2 ] ), 5 )
      arr_smo[ i, 2 ] := i
    Next
  Endif
  If Empty( s1smo )
    s1smo := 0
    For i := 1 To Len( arr_smo )
      s1smo := SetBit( s1smo, arr_smo[ i, 2 ] )
    Next
  Endif
  Private mdate := Space( 10 ), m1date := 0, ;
    mpoisk, m1poisk := s1poisk, ;
    mschet, m1schet := s1schet, ;
    msmo, m1smo := s1smo, ;
    mdolg, m1dolg := s1dolg, ;
    much_otd := Space( 10 ), m1uch_otd := 0, ;
    mbukva := ini_ed_tip_schet( s1bukva ), m1bukva := s1bukva
  Private pdate, gl_arr := { ;  // ��� ��⮢�� �����
  { "smo", "N", 10, 0, , , , {| x| inieditspr( A__MENUBIT, arr_smo, x ) } };
    }
  Private pr_a_uch := {}, pr_a_otd := {}
  mpoisk := inieditspr( A__MENUVERT, mm_poisk, m1poisk )
  mschet := inieditspr( A__MENUVERT, mm_schet, m1schet )
  mdolg  := inieditspr( A__MENUVERT, mm_dolg,  m1dolg )
  msmo   := inieditspr( A__MENUBIT,  arr_smo,  m1smo  )
  SetColor( cDataCGet )
  myclear( r )
  Private gl_area := { r, 1, MaxRow() -1, MaxCol(), 0 }, pdate
  status_key( "^<Esc>^ - ��室;  ^<PgDn>^ - ��⠢����� ���㬥��" )
  //
  @ r, 0 To MaxRow() -1, MaxCol() Color color8
  str_center( r, " �����, ����� � ����� �� ��⠬ (�����⮢�� ���ଠ樨) ", color14 )
  Do While .t.
    @ r + 2, 2 Say "�롮ઠ ���ଠ樨" Get mpoisk ;
      reader {| x| menu_reader( x, mm_poisk, A__MENUVERT, , , .f. ) }
    @ r + 3, 2 Say "���客��(�) ��������(�)" Get msmo ;
      reader {| x| menu_reader( x, arr_smo, A__MENUBIT, , , .f. ) }
    @ r + 4, 2 Say "��०�����/�⤥�����" Get much_otd ;
      reader {| x| menu_reader( x, { {| k, r, c| ret_nuch_notd( k, r, c ) } }, A__FUNCTION, , , .f. ) }
    @ r + 5, 2 Say "���� ��⮢" Get mbukva ;
      reader {| x| menu_reader( x, { {| k, r, c| inp_bit_tip_schet( k, r, c ) } }, A__FUNCTION, , , .f. ) }
    @ r + 6, 2 Say "��ਮ� �६���" Get mdate ;
      reader {| x| menu_reader( x, { {| k, r, c| ;
      k := year_month( r + 1, c ), iif( k == nil, nil, ( pdate := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
      k } }, A__FUNCTION, , , .f. ) }
    @ r + 7, 2 Say "��㯯�஢�� ��室��� ���ଠ樨" Get mschet ;
      reader {| x| menu_reader( x, mm_schet, A__MENUVERT, , , .f. ) }
    @ r + 8, 2 Say "�� �� ��ப� �뢮����" Get mdolg ;
      reader {| x| menu_reader( x, mm_dolg, A__MENUVERT, , , .f. ) }
    myread()
    If LastKey() == K_ESC
      Exit
    Endif
    s1smo   := m1smo
    s1schet := m1schet
    s1poisk := m1poisk
    s1dolg  := m1dolg
    s1bukva := m1bukva
    If Empty( pdate )
      func_error( 4, "�� ����� ��ਮ� �६���" )
    Elseif Empty( m1smo )
      func_error( 4, "�� ������� ���客�� ��������" )
    Elseif Empty( m1bukva )
      func_error( 4, "�� ��࠭� ⨯� ��⮢" )
    Elseif Empty( m1uch_otd )
      func_error( 4, "�� ��࠭� ��०�����/�⤥�����" )
    Elseif m1poisk == 0 .and. !is_otch_period( pdate )
      //
    Else
      ar := {} ; s := ""
      For i := 1 To Len( arr_smo )
        If IsBit( s1smo, i )
          AAdd( ar, arr_smo[ i, 3 ] )
          s += arr_smo[ i, 1 ] + ", "
        Endif
      Next
      s := SubStr( s, 1, Len( s ) -2 )
      f1pr1_oborot_schet( ar, s )
    Endif
  Enddo
  RestScreen( buf )

  Return Nil

// 30.03.23
Function f1pr1_oborot_schet( asmo, ssmo )

  Local adbf, i, n, arr_title, n_file := "oborot1" + stxt(), sh, HH := 60, buf := save_maxrow()

  mywait()
  adbf := { { "nschet", "C", 15, 0 }, ;
    { "dschet", "D", 8, 0 }, ;
    { "dregis", "D", 8, 0 }, ;
    { "schet", "N", 6, 0 }, ;
    { "BUKVA", "C", 1, 0 }, ; // �㪢� �� ���� ���
    { "SMO",  "C", 5, 0 }, ; // ��� �����⥫�;॥��஢� ����� ��� ��� 34 ��� �����த���;
    { "ot_per", "C", 4, 0 }, ;
    { "uch", "N", 2, 0 }, ;
    { "otd", "N", 3, 0 }, ;
    { "kol", "N", 6, 0 }, ;
    { "kol1", "N", 6, 0 }, ;
    { "summa", "N", 15, 2 }, ;
    { "summa1", "N", 15, 2 }, ;
    { "sum_sn", "N", 15, 2 }, ;
    { "penalty", "N", 15, 2 }, ;
    { "sum_op", "N", 15, 2 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) new
  dbCreate( cur_dir() + "tmp1", adbf )
  Use ( cur_dir() + "tmp1" ) new
  Do Case
  Case m1schet == 0 // �⮣� �� ���
    Index On smo to ( cur_dir() + "tmp1" )
  Case m1schet == 1 // �⮣� �� ��०�����/�⤥�����
    Index On Str( otd, 3 ) to ( cur_dir() + "tmp1" )
  Case m1schet == 2 // �⮣� �� ⨯�� ��⮢
    Index On bukva to ( cur_dir() + "tmp1" )
  Endcase
  Private arr_m := pdate
  r_use( dir_server + "mo_uch", , "UCH" )
  r_use( dir_server + "mo_otd", , "OTD" )
  r_use( dir_server + "human_", , "HUMAN_" )
  r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  r_use( dir_server + "mo_raksh", , "RAKSH" )
  Index On Str( kod_h, 7 ) to ( cur_dir() + "tmp_raksh" ) For !emptyall( SANK_MEK, SANK_MEE, SANK_EKMP )
  r_use( dir_server + "mo_rpdsh", , "RPDSH" )
  Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmprpdsh" )
  //
  r_use( dir_server + "schet_", , "SCHET_" )
  r_use( dir_server + "schet", dir_server + "schetd", "SCHET" )
  Set Relation To RecNo() into SCHET_
  Do Case
  Case m1poisk == 0 // �� ��� ����⭮�� ��ਮ��
    Index On pdate + fsort_schet( schet_->nschet, nomer_s ) to ( cur_dir() + "tmp" ) ;
      For schet_->NREGISTR == 0 .and. Empty( schet_->IS_DOPLATA ) .and. ;
      between_otch_period( schet_->dschet, schet_->NYEAR, schet_->NMONTH, arr_m[ 5 ], arr_m[ 6 ] )
  Case m1poisk == 1 // �� ��� ���⠢����� ���
    dbSeek( arr_m[ 7 ], .t. )
    Index On pdate + fsort_schet( schet_->nschet, nomer_s ) to ( cur_dir() + "tmp" ) ;
      For schet_->NREGISTR == 0 .and. Empty( schet_->IS_DOPLATA ) ;
      While pdate <= arr_m[ 8 ]
  Case m1poisk == 2 // �� ��� ॣ����樨 ���
    Index On pdate + fsort_schet( schet_->nschet, nomer_s ) to ( cur_dir() + "tmp" ) ;
      For schet_->NREGISTR == 0 .and. Empty( schet_->IS_DOPLATA ) .and. ;
      Between( date_reg_schet(), arr_m[ 5 ], arr_m[ 6 ] )
  Endcase
  Go Top
  Do While !Eof()
    Select TMP
    Append Blank
    tmp->nschet := schet_->nschet
    tmp->dschet := schet_->dschet
    tmp->dregis := schet_->DREGISTR
    tmp->schet  := schet->kod
    tmp->ot_per := Right( Str( schet_->NYEAR, 4 ), 2 ) + StrZero( schet_->NMONTH, 2 )
    tmp->BUKVA  := schet_->bukva
    tmp->SMO    := schet_->smo
    tmp->kol    := schet->kol
    tmp->kol1   := 0
    tmp->summa  := schet->summa
    tmp->summa1 := 0
    tmp->sum_sn := 0
    tmp->sum_op := 0
    tmp->penalty := 0
    If AScan( asmo, schet_->smo ) > 0 .and. schet_->bukva $ m1bukva
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While schet->kod == human->schet .and. !Eof()
        If AScan( pr_a_otd, {| x| x[ 1 ] == human->otd } ) > 0
          tmp->kol1++
          tmp->summa1 += human->cena_1
          If m1schet == 1 // �⮣� �� ��०�����/�⤥�����
            Select TMP1
            find ( Str( human->otd, 3 ) )
            If !Found()
              Append Blank
              tmp1->otd := human->otd
              otd->( dbGoto( human->otd ) )
              tmp1->uch := otd->kod_lpu
            Endif
            tmp1->kol1++
            tmp1->summa1 += human->cena_1
          Endif
          Select RAKSH
          find( Str( human->kod, 7 ) )
          Do While raksh->kod_h == human->kod .and. !Eof()
            tmp->sum_sn += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
            tmp->penalty += raksh->penalty
            If m1schet == 1 // �⮣� �� ��०�����/�⤥�����
              tmp1->sum_sn += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
              tmp1->penalty += raksh->penalty
            Endif
            Select RAKSH
            Skip
          Enddo
          Select RPDSH
          find( Str( human->kod, 7 ) )
          Do While rpdsh->kod_h == human->kod .and. !Eof()
            tmp->sum_op += rpdsh->S_SL
            If m1schet == 1 // �⮣� �� ��०�����/�⤥�����
              tmp1->sum_op += rpdsh->S_SL
            Endif
            Select RPDSH
            Skip
          Enddo
        Endif
        Select HUMAN
        Skip
      Enddo
    Endif
    Select SCHET
    Skip
  Enddo
  Commit
  If eq_any( m1schet, 0, 2 )
    Select TMP
    Go Top
    Do While !Eof()
      If tmp->kol1 > 0
        Select TMP1
        If m1schet == 0 // �⮣� �� ���
          find ( tmp->smo )
          If !Found()
            Append Blank
            tmp1->smo := tmp->smo
          Endif
        Else // �⮣� �� ⨯�� ��⮢
          find ( tmp->bukva )
          If !Found()
            Append Blank
            tmp1->bukva := tmp->bukva
          Endif
        Endif
        tmp1->kol1   += tmp->kol1
        tmp1->summa1 += tmp->summa1
        tmp1->sum_sn += tmp->sum_sn
        tmp1->sum_op += tmp->sum_op
        tmp1->penalty += tmp->penalty
      Endif
      Select TMP
      Skip
    Enddo
  Elseif m1schet == 3 // �� ��⠬
    Close databases
    Copy file tmp.dbf To tmp1.dbf
    Use ( cur_dir() + "tmp1" ) new
  Endif
  Commit
  Select TMP1
  Do Case
  Case m1schet == 0 // �� ���
    Index On smo to ( cur_dir() + "tmp1" )
    n := 25 // glob_arr_smo[i, 1]
    arr_title := { ;
      "_________________________", ;
      "    ���客�� ��������   ", ;
      "_________________________" }
  Case m1schet == 1 // �� �⤥�����
    Set Relation To otd into OTD, To uch into UCH
    Index On Upper( uch->name ) + Str( uch, 3 ) + Upper( otd->name ) + Str( otd, 3 ) to ( cur_dir() + "tmp1" )
    n := 31
    arr_title := { ;
      "_______________________________", ;
      "    ��०�����/�⤥�����       ", ;
      "_______________________________" }
  Case m1schet == 2 // �� ⨯�� ��⮢
    Index On bukva to ( cur_dir() + "tmp1" )
    n := 45
    arr_title := { ;
      "_____________________________________________", ;
      "   ���� ��⮢                               ", ;
      "_____________________________________________" }
  Case m1schet == 3 // �� ��⠬
    Index On ot_per + smo + nschet + DToS( dschet ) to ( cur_dir() + "tmp1" ) ;
      For kol1 > 0 .and. iif( m1dolg == 0, .t., !Empty( summa1 - sum_sn - sum_op ) )
    n := 39
    arr_title := { ;
      "_______________________________________", ;
      " ����� ����   |  ���  |��� ॣ|��/��", ;
      "_______________|________|________|_____" }
  Endcase
  arr_title[ 1 ] += "_________________________________________________________"
  arr_title[ 2 ] += "|  ���⠢����  |   ���   |  ����祭�    |    ����      "
  arr_title[ 3 ] += "|______________|___________|______________|______________"
  sh := Len( arr_title[ 1 ] )
  //
  fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
  add_string( glob_mo[ _MO_SHORT_NAME ] )
  add_string( "" )
  add_string( Center( "�����, ����� � ����� �� ��⠬" + iif( m1dolg == 1 .and. m1schet == 3, " (⮫쪮 ��ப� � ������)", "" ), sh ) )
  add_string( Center( "���: " + ssmo, sh ) )
  add_string( Center( "��०�����/�⤥�����: " + much_otd, sh ) )
  add_string( Center( "���� ��⮢: " + mbukva, sh ) )
  add_string( Center( "[" + mpoisk + "] " + pdate[ 4 ], sh ) )
  AEval( arr_title, {| x| add_string( x ) } )
  s1 := s2 := s3 := spenalty := 0
  Do Case
  Case m1schet == 0 // �� ���
    For i := 1 To Len( glob_arr_smo )
      find ( PadR( lstr( glob_arr_smo[ i, 2 ] ), 5 ) )
      If Found()
        add_string( PadR( glob_arr_smo[ i, 1 ], n ) + put_kop( tmp1->summa1, 15, 2 ) + ;
          put_kope( tmp1->sum_sn, 12, 2 ) + put_kope( tmp1->sum_op, 15, 2 ) + ;
          put_kope( tmp1->summa1 - tmp1->sum_sn - tmp1->sum_op, 15, 2 ) )
        s1 += tmp1->summa1
        s2 += tmp1->sum_sn
        s3 += tmp1->sum_op
        If !Empty( tmp1->penalty )
          add_string( put_kop( tmp1->penalty, n + 15 + 12, 2 ) + "(����)" )
          spenalty += tmp1->penalty
        Endif
      Endif
    Next
  Case m1schet == 1 // �� �⤥�����
    old_uch := 0
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If old_uch != tmp1->uch
        If old_uch > 0
          add_string( "" )
        Endif
        add_string( Upper( uch->name ) )
        add_string( Replicate( "�", sh ) )
        old_uch := tmp1->uch
      Endif
      add_string( PadR( otd->name, n ) + put_kop( tmp1->summa1, 15, 2 ) + ;
        put_kope( tmp1->sum_sn, 12, 2 ) + put_kope( tmp1->sum_op, 15, 2 ) + ;
        put_kope( tmp1->summa1 - tmp1->sum_sn - tmp1->sum_op, 15, 2 ) )
      s1 += tmp1->summa1
      s2 += tmp1->sum_sn
      s3 += tmp1->sum_op
      If !Empty( tmp1->penalty )
        add_string( put_kop( tmp1->penalty, n + 15 + 12, 2 ) + "(����)" )
        spenalty += tmp1->penalty
      Endif
      Select TMP1
      Skip
    Enddo
  Case m1schet == 2 // �� ⨯�� ��⮢
    For i := 1 To Len( get_bukva() )
      find ( get_bukva()[ i, 2 ] )
      If Found()
        add_string( PadR( get_bukva()[ i, 1 ], n ) + put_kop( tmp1->summa1, 15, 2 ) + ;
          put_kope( tmp1->sum_sn, 12, 2 ) + put_kope( tmp1->sum_op, 15, 2 ) + ;
          put_kope( tmp1->summa1 - tmp1->sum_sn - tmp1->sum_op, 15, 2 ) )
        s1 += tmp1->summa1
        s2 += tmp1->sum_sn
        s3 += tmp1->sum_op
        If !Empty( tmp1->penalty )
          add_string( put_kop( tmp1->penalty, n + 15 + 12, 2 ) + '(����)' )
          spenalty += tmp1->penalty
        Endif
      Endif
    Next
  Case m1schet == 3 // �� ��⠬
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( tmp1->nschet + " " + date_8( tmp1->dschet ) + " " + date_8( tmp1->dregis ) + " " + ;
        Left( tmp1->ot_per, 2 ) + "/" + Right( tmp1->ot_per, 2 ) + put_kop( tmp1->summa1, 15, 2 ) + ;
        put_kope( tmp1->sum_sn, 12, 2 ) + put_kope( tmp1->sum_op, 15, 2 ) + ;
        put_kope( tmp1->summa1 - tmp1->sum_sn - tmp1->sum_op, 15, 2 ) )
      s1 += tmp1->summa1
      s2 += tmp1->sum_sn
      s3 += tmp1->sum_op
      If !Empty( tmp1->penalty )
        add_string( put_kop( tmp1->penalty, n + 15 + 12, 2 ) + "(����)" )
        spenalty += tmp1->penalty
      Endif
      Select TMP1
      Skip
    Enddo
  Endcase
  add_string( Replicate( "�", sh ) )
  add_string( PadC( "�⮣�:", n ) + put_kop( s1, 15, 2 ) + ;
    put_kope( s2, 12, 2 ) + put_kope( s3, 15, 2 ) + ;
    put_kope( s1 - s2 - s3, 15, 2 ) )
  If !Empty( spenalty )
    add_string( put_kop( spenalty, n + 15 + 12, 2 ) + "(����)" )
  Endif
  Close databases
  FClose( fp )
  rest_box( buf )
  viewtext( n_file, , , , .t., , , 2 )

  Return Nil

// ���⠢����� ����⭮� ��������
Function pr2_oborot_schet()

  ne_real()

  Return Nil

// ���� �室�饣� ᠫ줮 ��� ���४⭮�� �ନ஢���� ����⭮� ��������
Function saldo_oborot_schet()

  ne_real()

  Return Nil
