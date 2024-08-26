#include 'common.ch'
#include 'hbhash.ch' 
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define NALOG_PLAT  1
#define PACIENT     2

Static reestr_xml_fns_sem := '����� � ॥��ࠬ� �ࠢ�� ���'
Static reestr_xml_fns_err := '� ����� ������ � ॥��ࠬ� ��� ࠡ�⠥� ��㣮� ���짮��⥫�.'

// 25.08.24
Function view_list_xml_fns()

  Local i, k, buf := SaveScreen()
//  local prefix := 'UT_SVOPLMEDUSL', nameFileXML := ''
//  local org := hb_main_curorg

  If ! g_slock( reestr_xml_fns_sem )
    Return func_error( 4, reestr_xml_fns_err )
  Endif

//  Private goal_dir := dir_server + dir_XML_MO + cslash
  g_use( dir_server + 'reg_xml_fns', , 'xml' )
  Index On str( kod, 6 ) to ( cur_dir() + 'tmp_xml' ) DESCENDING
  Go Top
  xml->( dbGoTop() )
  If xml->( Eof() )
    func_error( 4, '��� ॥��஢ �ࠢ��' )
  Else
    alpha_browse( 5, 0, 23, 79, 'defColumn_xml_FNS', color0,,,,,,, ;
      'serv_xml_fns',, { '�', '�', '�', 'N/BG, W+/N, B/BG, BG+/B, R/BG, GR+/R', .t., 180 } )
  Endif

  // mtitle := '����� ���㧪� ��� ���'
  // alpha_browse( 5, 0, MaxRow() - 2, 79, 'defColumn_xml_FNS', color0, mtitle, 'BG+/GR', ;
  //   .f., .t., , , 'serv_xml_fns', , ;
  //   { '�', '�', '�', 'N/BG, W+/N, B/BG, BG+/B, R/BG, GR+/R', .t., 180 } )

  dbCloseAll()
  g_sunlock( reestr_xml_fns_sem )
  RestScreen( buf )
  return nil

// 26.08.24
function serv_xml_fns( nKey, oBrow )

  Local j := 0, ret := -1, buf := SaveScreen(), ;
    tmp_color := SetColor(), r1 := 15, c1 := 2, ;
    xml_file, s, k := 0, smsg := ''
  local nResult

  Do Case
  Case nKey == K_F5
    s := manager( T_ROW, T_COL + 5, MaxRow() - 2, , .t., 2, .f.,,, ) // "norton" ��� �롮� ��⠫���
    If !Empty( s )
      If Upper( s ) == Upper( dir_XML_FNS() )
        func_error( 4, '�� ��ࠫ� ��⠫��, � ���஬ 㦥 ����ᠭ� 楫��� 䠩��! �� �������⨬�.' )
      Else
        xml_file := alltrim( xml->fname ) + sxml
        If hb_FileExists( dir_XML_FNS() + xml_file )
          mywait( '����஢���� "' + xml_file + '" � ��⠫�� "' + s + '"' )
          if ( nResult := hb_vfCopyFile( dir_XML_FNS() + xml_file, s + xml_file ) ) == 0  // ᪮��஢��� ��� �訡��
//          If hb_FileExists( s + xml_file )
            xml->( g_rlock( forever ) )
            xml->DATE_OUT := sys_date
            If xml->NUMB_OUT < 99
              xml->NUMB_OUT++
            Endif
            //
          Else
            smsg := '! �訡�� ����� 䠩�� ' + s + xml_file
            func_error( 4, smsg )
          Endif
        Else
          smsg := '! �� �����㦥� 䠩� ' + dir_XML_FNS() + xml_file
          func_error( 4, smsg )
        Endif
        Unlock
        Commit
      Endif
    endif
    ret := 0

  Case nKey == K_F3
    view_list_xml( oBrow )
    ret := 0
  Case nKey == K_F9
  Case nKey == K_DEL
  Otherwise
    Keyboard ''
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )
  Return ret

// 26.08.24
Function view_list_xml( oBrow )

  Static si := 1
  Local i, r := Row(), r1, r2, buf := save_maxrow(), ;
    mm_nalog := {}, ;
    mm_func := { -1, -2, -3 }, ;
    tmp_select := select(), ;
    mm_menu := { '���᮪ ~��� ���������⥫�訪�� � ॥���', ;
      '���᮪ ~��ࠡ�⠭��� � ���', ;
      '���᮪ ~�� ��ࠡ�⠭��� � ���' ;
    }

  mywait()
  r_use( dir_server + 'register_fns', , 'fns' )
  // Select MO_XML
  // Index On FNAME to ( cur_dir + "tmp_xml" ) ;
  //   For reestr == rees->kod .and. Between( TIP_IN, _XML_FILE_FLK, _XML_FILE_SP ) .and. Empty( TIP_OUT )
  fns->( dbGoTop() )
  Do While ! fns->( Eof() )
    if fns->kod_xml == xml->kod
      AAdd( mm_nalog, fns->plat_fio )
    endif
  //   AAdd( mm_func, mo_xml->kod )
  //   AAdd( mm_menu, "��⮪�� �⥭�� " + RTrim( mo_xml->FNAME ) + iif( Empty( mo_xml->TWORK2 ), "-������ �� ���������", "" ) )
    fns->( dbSkip() )
  Enddo
  // Select MO_XML
  // Set Index To
  If r <= 12
    r1 := r + 1
    r2 := r1 + Len( mm_menu ) + 1
  Else
    r2 := r - 1
    r1 := r2 - Len( mm_menu ) - 1
  Endif
  rest_box( buf )
  If ( i := popup_prompt( r1, 10, si, mm_menu,,, color5 ) ) > 0
    si := i
    // If mm_func[ i ] < 0
    //   f31_view_list_reestr( Abs( mm_func[ i ] ), mm_menu[ i ] )
    // Else
    //   mo_xml->( dbGoto( mm_func[ i ] ) )
    //   viewtext( devide_into_pages( dir_server + dir_XML_TF + cslash + AllTrim( mo_xml->FNAME ) + stxt, 60, 80 ),,,, .t.,,, 2 )
    // Endif
  Endif
  // Select REES
  select( tmp_select )
  fns->( dbCloseArea() )
  Return Nil

// 25.08.24
function defColumn_xml_FNS( oBrow )

  Local oColumn, s, ;
  blk := {|| iif( hb_FileExists( dir_XML_FNS() + AllTrim( xml->fname ) + sxml ), ;
    iif( Empty( xml->date_out ), { 3, 4 }, { 1, 2 } ), ;
    { 5, 6 } ) }

  oColumn := TBColumnNew( ' ����� ', {|| padl( alltrim( substr( xml->fname, hb_RAt( '_', xml->fname ) + 1 ) ), 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '  ���', {|| date_8( xml->dfile ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '���.;��.', {|| str( xml->kol1, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' ��� 䠩�� ', {|| substr( xml->fname, 26 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '�ਬ�砭��', {|| view_xml_fns() } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  status_key( '^<Esc>^ ��室; ^<F5>^ ������ ��� ���' )
  Return Nil

// 25.08.24
Function view_xml_fns()

  Local s := ''
  
  If ! hb_FileExists( dir_XML_FNS() + AllTrim( xml->fname ) + sxml )
    s := '��� 䠩��'
  Elseif Empty( xml->date_out )
    s := '�� ����ᠭ'
  Else
    s := '���. ' + lstr( xml->NUMB_OUT ) + ' ࠧ'
  Endif
  Return PadR( s, 10 )
  
  // 25.08.24
Function reestr_xml_fns()

//  Local buf := SaveScreen()
  local prefix := 'UT_SVOPLMEDUSL', nameFileXML := ''
  local org := hb_main_curorg

  _fns_nastr( 1 )

  if empty( org:INN() )
    func_error( 4, '��� �࣠����樨 ��������� ���!' )
    return nil
  endif

  if org:UrOrIP() .and. empty( org:KPP() )
    func_error( 4, '��� �࣠����樨 ��������� ���!' )
    return nil
  endif
  if empty( fns_ID_POL )
    func_error( 4, '��������� �����䨪��� �����⥫�, ���஬� ���ࠢ����� 䠩� ������!' )
    return nil
  endif

  if empty( fns_ID_END )
    func_error( 4, '��������� �����䨪��� ����筮�� �����⥫�, ��� ���ண� �।�����祭� ���ଠ�� �� ������� 䠩�� ������!' )
    return nil
  endif

  createXMLtoFNS()
//  RestScreen( buf )
  Return Nil

// 22.08.24
function name_file_fns_xml( org, dt, num, id_pol, id_end )

  local nameXML
  local prefix := 'UT_SVOPLMEDUSL'

  nameXML := prefix + '_' + id_pol + '_' + id_end + '_' + ;
    iif( org:UrOrIP(), org:INN() + org:KPP(), org:INN() ) + '_' + ;
    str( year( dt ), 4 ) + strzero( Month( dt ), 2, 0 ) + strzero( Day( dt ), 2, 0 ) + '_' + ;
    alltrim( str( num, 36 ) )

  return nameXML

// 23.08.24
function createXMLtoFNS()

  local aPlat := Array( 2, 17 )
  local oXmlDoc, oXmlNode, oXmlNodeDoc
  local oPAC, oUch, oDoc, oPodp, oRash, oSved
  local arr_m, i, mYear, curPreds := ''
  local org := hb_main_curorg
  local ver := '5.01'
  local nameFileXML
  local xml_created := .f., kolSpravka := 0, arr_spravka := {}
  local totalSpravka := 0, totalFile := 0
  local dir_xml := dir_XML_FNS()

  local tmp_fns := { ;  // ��ୠ� �뤠���� �ࠢ�� ��� ���
    { 'KOD',     'N',     7,   0 }, ; // recno()
    { 'DATE',    'D',     8,   0 }, ; // ��� ��⠢�����
    { 'KOD_K',   'N',     7,   0 }, ; // ��� �� ����⥪�
    { 'NYEAR',   'N',     4,   0 }, ; // ����� ���
    { 'NUM_S',   'N',     7,   0 }, ; // ����� �ࠢ��
    { 'VERSION', 'N',     3,   0 }, ; // ����� ���४�஢��
    { 'ATTRIBUT','N',     1,   0 }, ; // �ਧ��� 0 - ���������⥫�騪 � ��樥�� �� ����� ����� ��殬; 1 - ���������⥫�騪 � ��樥�� ����� ����� ��殬.
    { 'INN',     'C',    12,   0 }, ; // ��� ���⥫�騪�
    { 'PLAT_FIO','C',    50,   0 }, ; // ��� ���������⥫�騪�
    { 'PLAT_DOB','D',     8,   0 }, ; // ��� ஦����� ���������⥫�騪�
    { 'VIDDOC',  'N',     2,   0 }, ; // ��� ���㬥�� ���������⥫�騪�
    { 'SER_NUM', 'C',    20,   0 }, ; // ��� � ����� ���㬥�� ���������⥫�騪�
    { 'DATEVYD', 'D',     8,   0 }, ; // ��� �뤠� ���㬥�� ���������⥫�騪�
    { 'SUM1',    'N',    16,   2 }, ; // �㬬� 1
    { 'SUM2',    'N',    16,   2 }, ; // �㬬� 2
    { 'PRED_RUK','N',     1,   0 }, ; // �ਧ��� 1 - �।�⠢�⥫� �㪮����⥫� ��; 2 - �।�⠢�⥫�, ���㤭�� ��
    { 'PREDST',  'C',    50,   0 }, ; // �।�⠢�⥫� �࣠����樨
    { 'PRED_DOC','C',    50,   0 }, ; // ���㬥�� �।�⠢�⥫�
    { 'KOD_XML', 'N',     6,   0 } ; // ��뫪� �� 䠩� 'mo_xml_fns', ��� ��ࠢ�� � ��� ��� �᫮ -1 �᫨ ���⭠� �ଠ, 0 - �᫨ xml 䠩� �� �ନ஢����
  }

  If ( arr_m := input_year() ) == NIL
    Return Nil
  Endif
  mYear := arr_m[ 1 ]

  use_base( 'xml_fns', 'xml_fns', .t. )

  dbCreate( cur_dir() + 'tmp_fns', tmp_fns,, .t., 'tmp_fns' )
  Index On predst + Str( num_s, 7 ) to ( cur_dir() + 'tmp_fns' )
  use_base( 'reg_fns', 'fns', .t. )
  fns->( dbGoTop() )
  do while ! fns->( Eof() )
    if fns->nyear == mYear .and. fns->KOD_XML <= 0
      tmp_fns->( dbAppend() )
      tmp_fns->kod := fns->kod
      tmp_fns->date := fns->date
      tmp_fns->kod_k := fns->kod_k
      tmp_fns->nyear := fns->nyear
      tmp_fns->num_s := fns->num_s
      tmp_fns->version := fns->version
      tmp_fns->attribut := fns->attribut
      tmp_fns->inn := fns->inn
      tmp_fns->plat_fio := fns->plat_fio
      tmp_fns->plat_dob := fns->plat_dob
      tmp_fns->viddoc := fns->viddoc
      tmp_fns->ser_num := fns->ser_num
      tmp_fns->datevyd := fns->datevyd
      tmp_fns->sum1 := fns->sum1
      tmp_fns->sum2 := fns->sum2
      tmp_fns->pred_ruk := fns->pred_ruk
      tmp_fns->predst := fns->predst
      tmp_fns->pred_doc := fns->pred_doc
    endif
    fns->( dbSkip() )
  enddo
  tmp_fns->( dbSelectArea() )
  tmp_fns->( dbGoTop() )

  do while ! tmp_fns->( Eof() )

    if curPreds != tmp_fns->predst
      if xml_created
        check_and_create_dir( dir_xml )
        oXmlDoc:save( dir_xml + nameFileXML + sxml )
        
        xml_fns->( dbAppend() )
        xml_fns->kod := xml_fns->( recno() )
        xml_fns->fname := nameFileXML
        xml_fns->dfile := date()
        xml_fns->tfile := hour_min( Seconds() )
        xml_fns->kol1 := kolSpravka
        fill_pole_spravok( 'fns', arr_spravka, xml_fns->kod )

        G_Use( dir_server + 'reg_fns_nastr', , 'NASTR_FNS' )
        G_RLock( forever )
        NASTR_FNS->N_FILE_UP := fns_N_SPR_FILE
        nastr_fns->( dbCloseArea() )
        totalFile++
      endif

      arr_spravka := {}
      kolSpravka := 0
      curPreds := tmp_fns->predst
      nameFileXML := name_file_fns_xml( org, date(), ++fns_N_SPR_FILE, fns_ID_POL, fns_ID_END )
  
      // ᮧ����� ���� XML-���㬥��
      oXmlDoc := hxmldoc():new()
      xml_created := .t.

      oXmlNode := hxmlnode():new( hb_OEMToANSI( '����' ) )
      oXmlNode:SetAttribute( hb_OEMToANSI( '������' ), nameFileXML )
      oXmlNode:SetAttribute( hb_OEMToANSI( '����ண' ), hb_OEMToANSI( '���_�� ' ) + fs_version_short( _version() ) )
      oXmlNode:SetAttribute( hb_OEMToANSI( '���ᔮ�' ), ver )
      oXmlDoc:add( oXmlNode )

      oXmlNodeDoc := hxmlnode():new( hb_OEMToANSI( '���㬥��' ) )
      oXmlNodeDoc:SetAttribute( hb_OEMToANSI( '���' ), '1184043' )
      oXmlNodeDoc:SetAttribute( hb_OEMToANSI( '��⠄��' ), transform( date(), '99.99.9999' ) )
      oXmlNodeDoc:SetAttribute( hb_OEMToANSI( '�����' ), fns_ID_POL )
      oXmlNodeDoc:SetAttribute( hb_OEMToANSI( '��烮�' ), str( mYear, 4 ) )
      oDOC := oXmlDoc:aItems[ 1 ]:add( oXmlNodeDoc )

      oPAC := oDoc:add( hxmlnode():new( hb_OEMToANSI( '����' ) ) )
      if org:UrOrIp()
        oUch := oPAC:add( hxmlnode():new( hb_OEMToANSI( '����' ) ) )
        oUch:SetAttribute( hb_OEMToANSI( '������' ), hb_OEMToANSI( alltrim( org:Name() ) ) )
        oUch:SetAttribute( hb_OEMToANSI( '�����' ), hb_OEMToANSI( alltrim( org:INN() ) ) )
        oUch:SetAttribute( hb_OEMToANSI( '���' ), hb_OEMToANSI( alltrim( org:KPP() ) ) )
      else
        oUch := oPAC:add( hxmlnode():new( hb_OEMToANSI( '����' ) ) )
        oUch:SetAttribute( hb_OEMToANSI( '�����' ), hb_OEMToANSI( alltrim( org:INN() ) ) )
        node_fio_tip_fns( oUch, org:Ruk_fio() )
      endif

      // ���������
      oPodp := oDoc:add( hxmlnode():new( hb_OEMToANSI( '�����ᠭ�' ) ) )
      if tmp_fns->pred_ruk == 0
        oPodp:SetAttribute( hb_OEMToANSI( '������' ), '2' )
        node_fio_tip_fns( oPodp, alltrim( tmp_fns->predst ) )

        oSved := oPodp:add( hxmlnode():new( hb_OEMToANSI( '���।' ) ) )
        oSved:SetAttribute( hb_OEMToANSI( '�������' ), hb_OEMToANSI( Upper( alltrim( tmp_fns->pred_doc ) ) ) )
      else
        oPodp:SetAttribute( hb_OEMToANSI( '������' ), '1' )
        if org:UrOrIp()
          node_fio_tip_fns( oPodp, org:Ruk_fio() )
        endif
      endif
    endif
    totalSpravka++
    kolSpravka++
    AAdd( arr_spravka, tmp_fns->kod )
    // �������� � ��室��
    oRash := oDoc:add( hxmlnode():new( hb_OEMToANSI( '���������' ) ) )
    oRash:SetAttribute( hb_OEMToANSI( '���������' ), alltrim( str( tmp_fns->num_s, 12 ) ) )
    oRash:SetAttribute( hb_OEMToANSI( '�������' ), alltrim( str( tmp_fns->version, 3 ) ) )
    oRash:SetAttribute( hb_OEMToANSI( '����樥��' ), str( tmp_fns->attribut, 1 ) )
    if tmp_fns->sum1 > 0
      oRash:SetAttribute( hb_OEMToANSI( '�㬬����1' ), alltrim( str( tmp_fns->sum1, 15, 2 ) ) )
    endif
    if tmp_fns->sum2 > 0
      oRash:SetAttribute( hb_OEMToANSI( '�㬬����2' ), alltrim( str( tmp_fns->sum2, 15, 2 ) ) )
    endif
    node_DAN_FIO_TIP( oRash, NALOG_PLAT, tmp_fns->inn, tmp_fns->plat_dob, tmp_fns->plat_fio, tmp_fns->viddoc, tmp_fns->ser_num, tmp_fns->datevyd )

    if tmp_fns->attribut == 0 // �஢�ઠ �� ᮢ������� ���������⥫�騪� � ��樥��
//      node_DAN_FIO_TIP( oRash, PACIENT, aPlat[ i, 12 ], aPlat[ i, 13 ], aPlat[ i, 17 ], aPlat[ i, 14 ], aPlat[ i, 15 ], aPlat[ i, 16 ] )
    endif

    tmp_fns->( dbSkip() )
  enddo
  if xml_created
    check_and_create_dir( dir_xml )
    oXmlDoc:save( dir_xml + nameFileXML + sxml )

    xml_fns->( dbAppend() )
    xml_fns->kod := xml_fns->( recno() )
    xml_fns->fname := nameFileXML
    xml_fns->dfile := date()
    xml_fns->tfile := hour_min( Seconds() )
    xml_fns->kol1 := kolSpravka
    fill_pole_spravok( 'fns', arr_spravka, xml_fns->kod )

    G_Use( dir_server + 'reg_fns_nastr', , 'NASTR_FNS' )
    G_RLock( forever )
    NASTR_FNS->N_FILE_UP := fns_N_SPR_FILE
    nastr_fns->( dbCloseArea() )
    totalFile++
  endif

  tmp_fns->( dbCloseArea() )
  xml_fns->( dbCloseArea() )
  fns->( dbCloseArea() )
  hb_Alert( '��ࠡ�⠭�: ' + alltrim( str( totalSpravka ) ) + ' �ࠢ��, ᮧ���� ' + alltrim( str( totalFile ) ) + ' 䠩���.' )
  return nil

// 22.08.24
function check_and_create_dir( dir )

  if ! hb_vfDirExists( dir )
    hb_vfDirMake( dir )
  endif
  return nil

// 21.08.24
function fill_pole_spravok( alias, arr_spravka, kod )

  local tmpRec, i

  tmpRec := ( alias )->( recno() )

  for i := 1 to len( arr_spravka )
    ( alias )->( dbGoto( arr_spravka[ i ] ) )
    ( alias )->kod_xml := kod
  next

  ( alias )->( dbGoto( tmpRec ) )
  return nil

// 23.08.24
function node_DAN_FIO_TIP( obj, node_type, inn, dob, fio, docType, docSerNum, docDate )

  local oDAN_FIO_TIP

  oDAN_FIO_TIP := obj:add( hxmlnode():new( hb_OEMToANSI( iif( node_type == NALOG_PLAT, '�����⌥���', '��樥��' ) ) ) )
  if ! empty( inn )
    oDAN_FIO_TIP:SetAttribute( hb_OEMToANSI( '���' ), alltrim( inn ) )
  endif
  oDAN_FIO_TIP:SetAttribute( hb_OEMToANSI( '��⠐���' ), transform( dob, '99.99.9999' ) )
  node_fio_tip_fns( oDAN_FIO_TIP, fio )
  if empty( inn )
    node_Sved_Doc_fns( oDAN_FIO_TIP, docType, docSerNum, docDate )
  endif
  return nil

// 23.08.24
function node_Sved_Doc_fns( obj, kod, sernum, datedoc )

  local oSvedDoc

  oSvedDoc := obj:add( hxmlnode():new( hb_OEMToANSI( '�������' ) ) )
  oSvedDoc:SetAttribute( hb_OEMToANSI( '���������' ), strzero( kod, 2 ) )
  oSvedDoc:SetAttribute( hb_OEMToANSI( '���������' ), alltrim( sernum ) )
  oSvedDoc:SetAttribute( hb_OEMToANSI( '��⠄��' ), transform( datedoc, '99.99.9999' ) )
  return nil

// 23.08.24
function node_fio_tip_fns( obj, fio )

  local aFio, node_fio

  aFIO := razbor_str_fio( Upper( fio ) )
  node_fio := obj:add( hxmlnode():new( hb_OEMToANSI( '���' ) ) )
  node_fio:SetAttribute( hb_OEMToANSI( '�������' ), hb_OEMToANSI( aFIO[ 1 ] ) )
  node_fio:SetAttribute( hb_OEMToANSI( '���' ), hb_OEMToANSI( aFIO[ 2 ] ) )
  if ! empty( aFIO[ 3 ] )
    node_fio:SetAttribute( hb_OEMToANSI( '����⢮' ), hb_OEMToANSI( aFIO[ 3 ] ) )
  endif
  return nil