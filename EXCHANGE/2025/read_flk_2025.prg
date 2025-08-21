#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 21.08.25 ������ ���� ��⮪�� ���.
Function reestr_sp_tk_tmpfile_2025( oXmlDoc, aerr, mname_xml )

  Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()
  local s

  Default aerr TO {}, mname_xml To ''
  stat_msg( '��ᯠ�����/�⥭��/������ ॥��� �� � �� ' + BeforAtNum( '.', mname_xml ) )
  dbCreate( cur_dir() + 'tmp1file', { ;
    { '_VERSION',   'C',  5, 0 }, ;
    { '_DATA',      'D',  8, 0 }, ;
    { '_FILENAME',  'C', 26, 0 }, ;
    { '_CODE',      'N',  8, 0 }, ;
    { '_CODE_MO',   'C',  6, 0 }, ;
    { '_YEAR',      'N',  4, 0 }, ;
    { '_MONTH',     'N',  2, 0 }, ;
    { '_NSCHET',    'C', 15, 0 }, ;
    { '_DSCHET',    'D',  8, 0 }, ;
    { 'KOL1',       'N',  6, 0 }, ;
    { 'KOL2',       'N',  6, 0 };
    } )
  dbCreate( cur_dir() + 'tmp2file', { ;
    { '_N_ZAP',     'N',  8, 0 }, ;
    { '_ID_PAC',    'C', 36, 0 }, ;
    { '_VPOLIS',    'N',  1, 0 }, ;
    { '_SPOLIS',    'C', 10, 0 }, ;
    { '_NPOLIS',    'C', 20, 0 }, ;
    { '_ENP',       'C', 16, 0 }, ;
    { '_SMO',       'C',  5, 0 }, ;
    { '_SMO_OK',    'C',  5, 0 }, ;
    { '_MO_PR',     'C',  6, 0 }, ;
    { 'KOD_HUMAN',  'N',  7, 0 }, ; // ��� �� �� ���⮢ ����
    { 'FIO',        'C', 50, 0 }, ;
    { 'SCHET_CHAR', 'C',  1, 0 }, ; // ����, �㪢� 'M', ��� �㪢� 'D'
    { 'SCHET',  'N',  6, 0 }, ; // ��� ���
    { 'SCHET_ZAP',  'N',  6, 0 }, ; // ����� ����樨 ����� � ���
    { '_IDCASE',    'N',  8, 0 }, ;
    { '_ID_C',      'C', 36, 0 }, ;
    { '_IDENTITY',  'N',  1, 0 }, ;
    { 'CORRECT',    'C',  2, 0 }, ;
    { '_FAM',     'C', 40, 0 }, ; //
    { '_IM',     'C', 40, 0 }, ; //
    { '_OT',     'C', 40, 0 }, ; //
    { '_DR',     'C', 10, 0 }, ; //
    { '_OPLATA',    'N',  1, 0 };
    } )
  dbCreate( cur_dir() + 'tmp3file', { ;
    { '_N_ZAP',     'N',  8, 0 }, ;
    { '_REFREASON', 'N',  3, 0 }, ;
    { 'SREFREASON', 'C', 12, 0 };
    } )
  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
  Append Blank
  Use ( cur_dir() + 'tmp2file' ) New Alias TMP2
  Use ( cur_dir() + 'tmp3file' ) New Alias TMP3
  For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
    @ MaxRow(), 1 Say PadR( lstr( j ), 6 ) Color cColorSt2Msg
    oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
    Do Case
    Case 'ZGLV' == oXmlNode:title
      tmp1->_VERSION :=          mo_read_xml_stroke( oXmlNode, 'VERSION', aerr )
      tmp1->_DATA    := xml2date( mo_read_xml_stroke( oXmlNode, 'DATA',    aerr ) )
      tmp1->_FILENAME :=          mo_read_xml_stroke( oXmlNode, 'FILENAME', aerr )
    Case 'SCHET' == oXmlNode:title
      tmp1->_CODE    :=      Val( mo_read_xml_stroke( oXmlNode, 'CODE',   aerr ) )
      tmp1->_CODE_MO :=          mo_read_xml_stroke( oXmlNode, 'CODE_MO', aerr )
      tmp1->_YEAR    :=      Val( mo_read_xml_stroke( oXmlNode, 'YEAR',   aerr ) )
      tmp1->_MONTH   :=      Val( mo_read_xml_stroke( oXmlNode, 'MONTH',  aerr ) )
      tmp1->_NSCHET  :=          mo_read_xml_stroke( oXmlNode, 'NSCHET', aerr )
      tmp1->_DSCHET  := xml2date( mo_read_xml_stroke( oXmlNode, 'DSCHET', aerr ) )
    Case 'ZAP' == oXmlNode:title
//      Select TMP2
//      Append Blank
      dbSelectArea( 'TMP2' )
      tmp2->( dbAppend() )
      tmp2->_N_ZAP := Val( mo_read_xml_stroke( oXmlNode, 'N_ZAP', aerr ) )
      If ( oNode1 := oXmlNode:find( 'PACIENT' ) ) == NIL
        AAdd( aerr, '��������� ���祭�� ��易⥫쭮�� �� "PACIENT"' )
      Else
        tmp2->_ID_PAC := Upper( mo_read_xml_stroke( oNode1, 'ID_PAC', aerr ) )
        tmp2->_VPOLIS :=   Val( mo_read_xml_stroke( oNode1, 'VPOLIS', aerr ) )
        tmp2->_SPOLIS :=       mo_read_xml_stroke( oNode1, 'SPOLIS', aerr, .f. )
        tmp2->_NPOLIS :=       mo_read_xml_stroke( oNode1, 'NPOLIS', aerr )
        tmp2->_ENP    :=       mo_read_xml_stroke( oNode1, 'ENP', aerr, .f. )
        tmp2->_SMO    :=       mo_read_xml_stroke( oNode1, 'SMO', aerr )
        tmp2->_SMO_OK :=       mo_read_xml_stroke( oNode1, 'SMO_OK', aerr )
        tmp2->_MO_PR  :=       mo_read_xml_stroke( oNode1, 'MO_PR', aerr, .f. )
        tmp2->_IDENTITY := Val( mo_read_xml_stroke( oNode1, 'IDENTITY', aerr, .f. ) )
        If Empty( tmp2->_MO_PR )
          tmp2->_MO_PR := Replicate( '0', 6 )
        Endif
        If ( oNode2 := oNode1:find( 'CORRECTION' ) ) != NIL
          tmp2->_FAM := mo_read_xml_stroke( oNode2, 'FAM', aerr, .f. )
          tmp2->_IM  := mo_read_xml_stroke( oNode2, 'IM', aerr, .f. )
          tmp2->_OT  := mo_read_xml_stroke( oNode2, 'OT', aerr, .f. )
          tmp2->_DR  := mo_read_xml_stroke( oNode2, 'DR', aerr, .f. )
          If oNode2:find( 'OT' ) != Nil .and. Empty( tmp2->_OT )
            tmp2->CORRECT := 'OT' // �.�. ���⮥ ����⢮
          Endif
        Endif
      Endif
      If AllTrim( tmp1->_VERSION ) == '3.11'
        If ( oNode1 := oXmlNode:find( 'Z_SL' ) ) == NIL
          AAdd( aerr, '��������� ���祭�� ��易⥫쭮�� �� "Z_SL"' )
        Endif
      Else
        If ( oNode1 := oXmlNode:find( 'SLUCH' ) ) == NIL
          AAdd( aerr, '��������� ���祭�� ��易⥫쭮�� �� "SLUCH"' )
        Endif
      Endif
      If oNode1 != NIL
        tmp2->_IDCASE :=   Val( mo_read_xml_stroke( oNode1, 'IDCASE', aerr ) )
        tmp2->_ID_C   := Upper( mo_read_xml_stroke( oNode1, 'ID_C', aerr ) )
        tmp2->_OPLATA :=   Val( mo_read_xml_stroke( oNode1, 'OPLATA', aerr ) )
        If tmp2->_OPLATA > 1
          _ar := mo_read_xml_array( oNode1, 'REFREASON' )
          For j1 := 1 To Len( _ar )
//            Select TMP3
//            Append Blank
            dbSelectArea( 'TMP3' )
            tmp3->( dbAppend() )
            tmp3->_N_ZAP := tmp2->_N_ZAP
            s := AllTrim( _ar[ j1 ] )
            If Len( s ) > 3 .or. '.' $ s
              tmp3->SREFREASON := s
            Else
              tmp3->_REFREASON := Val( s )
            Endif
          Next
        Endif
      Endif
    Endcase
  Next j
//  Commit
  dbCommitAll()
  rest_box( buf )
  Return Nil

// 21.08.25 ������ ��⮪�� ��� �� �६���� 䠩�� ����� �����
Function protokol_flk_tmpfile_2025( arr_f, aerr )

  Local adbf, ii, j, s, oXmlDoc, oXmlNode, is_err_FLK := .f.

  adbf := { ;
    { 'FNAME',  'C', 27, 0 }, ;
    { 'FNAME1', 'C', 26, 0 }, ;
    { 'FNAME2', 'C', 26, 0 }, ;
    { 'KOL2',   'N',  6, 0 };   // ���-�� �訡��
  }
//  { 'DATE_F', 'D',  8, 0 }, ;
  dbCreate( cur_dir() + 'tmp1file', adbf, , .t., 'TMP1' )
//  Use ( cur_dir() + 'tmp1file' ) New Alias TMP1
//  Append Blank
  tmp1->( dbAppend() )

  adbf := { ; // ������ PR
  { 'TIP',        'N',   1, 0 }, ;  // ⨯(�����) ��ࠡ��뢠����� 䠩��
  { 'OSHIB',      'N',   3, 0 }, ;  // ��� �訡�� T005
  { 'SOSHIB',     'C',  12, 0 }, ;  // ��� �訡�� Q015, Q022
  { 'IM_POL',     'C',  20, 0 }, ;  // ��� ����, � ���஬ �訡��
  { 'ZN_POL',     'C', 100, 0 }, ;  // ���祭�� ����, �맢��襥 �訡��. �� ����������, �᫨ �訡�� �⭮���� � 䠩�� � 楫��
  { 'NSCHET',     'C',  15, 0 }, ;  // ����� ���, � ���஬ �����㦥�� �訡��
  { 'BAS_EL',     'C',  20, 0 }, ;  // ��� �������� �����
  { 'N_ZAP',      'C',  36, 0 }, ;  // ����� �����, � ����� �� ����� ���ன �����㦥�� �訡��
  { 'ID_PAC',     'C',  36, 0 }, ;  // ��� ����� � ��樥��, � ���ன �����㦥�� �訡��. �� ���������� ⮫쪮 � ⮬ ��砥, �᫨ �訡�� �⭮���� � 䠩�� � 楫��.
  { 'IDCASE',     'N',  11, 0 }, ;  // ����� �����祭���� ����, � ���஬ �����㦥�� �訡��(㪠�뢠����, �᫨ �訡�� �����㦥�� ����� ⥣� ?Z_SL?, � ⮬ �᫥ �� �室��� � ���� ������ ?SL? � ��㣠�)
  { 'SL_ID',      'C',  36, 0 }, ;  // �����䨪��� ����, � ���஬ �����㦥�� �訡�� (㪠�뢠����, �᫨ �訡�� �����㦥�� ����� ⥣� ?SL?, � ⮬ �᫥ �� �室��� � ���� ��㣠�)
  { 'IDSERV',     'C',  36, 0 }, ;  // ����� ��㣨, � ���ன �����㦥�� �訡�� (㪠�뢠����, �᫨ �訡�� �����㦨������ ����� ⥣� ?USL?)
  { 'COMMENT',    'C', 250, 0 }, ;  // ���ᠭ�� �訡��
  { 'N_ZAP',      'N',   6, 0 }, ;  // ���� �� ��ࢨ筮�� ॥���
  { 'KOD_HUMAN',  'N',   7, 0 };   // ��� �� �� ���⮢ ����
  }
  dbCreate( cur_dir() + 'tmp2file', adbf, , .t., 'TMP2' ) // ������ PR
//  Use ( cur_dir() + 'tmp2file' ) New Alias TMP2

  dbCreate( cur_dir() + 'tmp22fil', adbf ) // ���.䠩�, �᫨ �� ������ ��樥��� > 1 ���� ����

  For ii := 1 To Len( arr_f )
    // �.�. � ZIP'� ��� XML-䠩��, ��ன 䠩� ⠪�� ������
    If Upper( Right( arr_f[ ii ], 4 ) ) == sxml() .and. ValType( oXmlDoc := hxmldoc():read( _tmp_dir1() + arr_f[ ii ] ) ) == 'O'
      For j := 1 To Len( oXmlDoc:aItems[ 1 ]:aItems )
        oXmlNode := oXmlDoc:aItems[ 1 ]:aItems[ j ]
        Do Case
        Case 'FNAME' == oXmlNode:title
          tmp1->FNAME := mo_read_xml_tag( oXmlNode, aerr, .t. )
        Case 'FNAME_I' == oXmlNode:title
          If ii == 1
            tmp1->FNAME1 := mo_read_xml_tag( oXmlNode, aerr, .t. )
          Else
            tmp1->FNAME2 := mo_read_xml_tag( oXmlNode, aerr, .t. )
          Endif
//        Case 'DATE_F' == oXmlNode:title
//          tmp1->DATE_F := xml2date( mo_read_xml_stroke( oXmlNode, 'DATE_F', aerr, .f. ) )
        Case 'PR' == oXmlNode:title
//          Select TMP2
//          Append Blank
          dbSelectArea( 'TMP2' )
          tmp2->( dbAppend() )
          tmp2->tip := ii
          s := AllTrim( mo_read_xml_stroke( oXmlNode, 'OSHIB', aerr ) )
          If Len( s ) > 3 .or. '.' $ s
            tmp2->SOSHIB := s
          Else
            tmp2->OSHIB := Val( s )
          Endif
          tmp2->IM_POL  := mo_read_xml_stroke( oXmlNode, 'IM_POL', aerr, .f. )
          tmp2->ZN_POL  := mo_read_xml_stroke( oXmlNode, 'ZN_POL', aerr, .f. )
          tmp2->NSCHET  := mo_read_xml_stroke( oXmlNode, 'NSCHET', aerr, .f. )
          tmp2->BAS_EL  := mo_read_xml_stroke( oXmlNode, 'BAS_EL', aerr, .f. )
          tmp2->N_ZAP   := mo_read_xml_stroke( oXmlNode, 'N_ZAP', aerr, .f. )
          tmp2->ID_PAC  := mo_read_xml_stroke( oXmlNode, 'ID_PAC', aerr, .f. )
          tmp2->IDCASE  := Val( mo_read_xml_stroke( oXmlNode, 'IDCASE', aerr, .f. ) )
          tmp2->SL_ID   := mo_read_xml_stroke( oXmlNode, 'SL_ID', aerr, .f. )
          tmp2->IDSERV  := mo_read_xml_stroke( oXmlNode, 'IDSERV', aerr, .f. )
          tmp2->COMMENT := mo_read_xml_stroke( oXmlNode, 'COMMENT', aerr, .f. )
          If ! Empty( tmp2->BAS_EL )   // .and. !Empty( tmp2->ID_BAS )
            is_err_FLK := .t.
            tmp1->KOL2++
          Endif
        Endcase
      Next j
    Endif
  Next ii
//  Commit
  dbCommitAll()
  Return is_err_FLK
