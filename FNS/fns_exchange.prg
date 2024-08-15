#include 'common.ch'
#include 'hbhash.ch' 
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 15.08.24
Function reestr_xml_fns()

  Local mtitle
  Local buf := SaveScreen()
  local prefix := 'UT_SVOPLMEDUSL', nameFileXML := ''
  local dt, num

  _fns_nastr( 1 )

  if empty( hb_main_curorg:INN() )
    func_error( 4, '��� �࣠����樨 ��������� ���!' )
    return nil
  endif

  if hb_main_curorg:UrOrIP() .and. empty( hb_main_curorg:KPP() )
    func_error( 4, '��� �࣠����樨 ��������� ���!' )
    return nil
  endif
  if empty( pp_ID_POL )
    func_error( 4, '��������� �����䨪��� �����⥫�, ���஬� ���ࠢ����� 䠩� ������!' )
    return nil
  endif

  if empty( pp_ID_END )
    func_error( 4, '��������� �����䨪��� ����筮�� �����⥫�, ��� ���ண� �।�����祭� ���ଠ�� �� ������� 䠩�� ������!' )
    return nil
  endif

  dt := Date()  //�६����
  num := pp_N_SPR_FILE + 1  //�६����

  nameFileXML := name_file_fns_xml( dt, num )

  createXMLtoFNS( nameFileXML )

  // use_base( 'xml_fns', 'xml' )

  // xml->( dbGoBottom() )
  // mtitle := '����� ���㧪� ��� ���'
  // alpha_browse( 5, 0, MaxRow() - 2, 79, 'defColumn_xml_FNS', color0, mtitle, 'BG+/GR', ;
  //   .f., .t., , , 'serv_xml_fns', , ;
  //   { '�', '�', '�', 'N/BG, W+/N, B/BG, BG+/B, R/BG, GR+/R', .t., 180 } )

  // dbCloseAll()
  RestScreen( buf )

  Return Nil

// 13.08.24
function defColumn_xml_FNS( oBrow )

  Local oColumn, s
//  Local blk := {|| iif( Empty( xml->kod_xml ), { 5, 6 }, { 3, 4 } ) }

  oColumn := TBColumnNew( ' ��� ', {|| str( xml->kod, 6 ) } )
//  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' ��� 䠩�� ', {|| xml->fname } )
//  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' ��� 䠩�� 2', {|| xml->fname2 } )
//  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( '  ���', {|| date_8( xml->dfile ) } )
//  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  s := '<Esc> ��室 <Ins> ����'
  @ MaxRow(), 0 Say PadC( s, 80 ) Color 'N/W'
  mark_keys( { '<Esc>', '<Enter>', '<Ins>', '<Del>', '<Ctrl+Enter>', '<F3>', '<F4>', '<F8>', '<F9>', '<F10>' }, 'R/W' )

  Return Nil

// 13.08.24
function serv_xml_fns( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), ;
    tmp_color := SetColor(), r1 := 15, c1 := 2

  Do Case
  Case nKey == K_F9
  Case nKey == K_INS
  Case nKey == K_DEL
  Otherwise
    Keyboard ''
  Endcase

  Return flag

// 15.08.24
function name_file_fns_xml( dt, num )

  local nameXML
  local prefix := 'UT_SVOPLMEDUSL'

  nameXML := prefix + '_' + pp_ID_POL + '_' + pp_ID_END + '_' + ;
    iif( hb_main_curorg:UrOrIP(), hb_main_curorg:INN() + hb_main_curorg:KPP(), hb_main_curorg:INN() ) + ;
    str( year( dt ), 4 ) + strzero( Month( dt ), 2, 0 ) + strzero( Day( dt ), 2, 0 ) + ;
    alltrim( str( num, 36 ) )

  return nameXML

// 15.08.24
function createXMLtoFNS( nameFileXML )

  local oXmlDoc, oXmlNode, oXmlNodeDoc
  local aFIO, oFIO, oPAC, oUch, oDoc, oPodp, oRash
  local ver := '5.01'

  local dt := date()    // �६����

  // ᮧ����� ���� XML-���㬥��
  oXmlDoc := hxmldoc():new()

  oXmlNode := hxmlnode():new( hb_OEMToANSI( '����' ) )
  oXmlNode:SetAttribute( hb_OEMToANSI( '������' ), nameFileXML )
  oXmlNode:SetAttribute( hb_OEMToANSI( '����ண' ), hb_OEMToANSI( '���_�� ' ) + fs_version( _version() ) )
  oXmlNode:SetAttribute( hb_OEMToANSI( '���ᔮ�' ), ver )
  oXmlDoc:add( oXmlNode )


  oXmlNodeDoc := hxmlnode():new( hb_OEMToANSI( '���㬥��' ) )
  oXmlNodeDoc:SetAttribute( hb_OEMToANSI( '���' ), '1184043' )
  oXmlNodeDoc:SetAttribute( hb_OEMToANSI( '��⠄��' ), transform( dt, '99.99.9999' ) )
  oXmlNodeDoc:SetAttribute( hb_OEMToANSI( '�����' ), pp_ID_POL )
  oXmlNodeDoc:SetAttribute( hb_OEMToANSI( '��烮�' ), str( year( dt ), 4 ) )
  oDOC := oXmlDoc:aItems[ 1 ]:add( oXmlNodeDoc )

  oPAC := oDoc:add( hxmlnode():new( hb_OEMToANSI( '����' ) ) )
  if hb_main_curorg:UrOrIp()
    oUch := oPAC:add( hxmlnode():new( hb_OEMToANSI( '����' ) ) )
    mo_add_xml_stroke( oUch, hb_OEMToANSI( '������' ), hb_main_curorg:Name() )
    mo_add_xml_stroke( oUch, hb_OEMToANSI( '�����' ), hb_main_curorg:INN() )
    mo_add_xml_stroke( oUch, hb_OEMToANSI( '���' ), hb_main_curorg:KPP() )
  else
    oUch := oPAC:add( hxmlnode():new( hb_OEMToANSI( '����' ) ) )
    mo_add_xml_stroke( oUch, hb_OEMToANSI( '�����' ), hb_main_curorg:INN() )
    aFIO := razbor_str_fio( hb_main_curorg:Ruk_fio() )
    oFIO := oUch:add( hxmlnode():new( hb_OEMToANSI( '���' ) ) )
    mo_add_xml_stroke( oFIO, hb_OEMToANSI( '�������' ), hb_OEMToANSI( aFIO[ 1 ] ) )
    mo_add_xml_stroke( oFIO, hb_OEMToANSI( '���' ), hb_OEMToANSI( aFIO[ 2 ] ) )
    if ! empty( aFIO[ 3 ] )
      mo_add_xml_stroke( oFIO, hb_OEMToANSI( '����⢮' ), hb_OEMToANSI( aFIO[ 3 ] ) )
    endif
  endif

  // ���������
  oPodp := oDoc:add( hxmlnode():new( hb_OEMToANSI( '�����ᠭ�' ) ) )
  // �������� � ��室��
  oRash := oDoc:add( hxmlnode():new( hb_OEMToANSI( '���������' ) ) )

  oXmlDoc:save( nameFileXML + sxml )

  return nil
