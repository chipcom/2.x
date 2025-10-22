// ॥���� ��業⮢
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 21.10.25
function elem_reestr_pacient( oXmlDoc, fl_ver, p_tip_reestr )

  local arr_fio, smr
  local oPAC
  local tmpSelect

//      @ MaxRow(), 0 Say Str( rhum->REES_ZAP / pkol * 100, 6, 2 ) + '%' Color cColorSt2Msg
  tmpSelect := Select()
  dbSelectArea( 'HUMAN' )
  human->( dbGoto( rhum->kod_hum ) )  // ��⠫� �� 1-� ���� ����
  If human->ishod == 89  // � �� �� 1-�, � 2-�� �/�
    dbSelectArea( 'HUMAN_3' )
    Set Order To 2
    human_3->( dbSeek( Str( rhum->kod_hum, 7 ) ) )
    dbSelectArea( 'HUMAN' )
    human->( dbGoto( human_3->kod ) )  // ��⠫� �� 1-� ���� ����
  Endif
  arr_fio := retfamimot( 2, .f. )
  // �������� ᢥ����� � ��樥�� ��� XML-���㬥��
  oPAC := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'PERS' ) )
  mo_add_xml_stroke( oPAC, 'ID_PAC', human_->ID_PAC )
  If human_->NOVOR == 0
    mo_add_xml_stroke( oPAC, 'FAM', arr_fio[ 1 ] )
    If !Empty( arr_fio[ 2 ] )
      mo_add_xml_stroke( oPAC, 'IM', arr_fio[ 2 ] )
    Endif
    If !Empty( arr_fio[ 3 ] )
      mo_add_xml_stroke( oPAC, 'OT', arr_fio[ 3 ] )
    Endif
    mo_add_xml_stroke( oPAC, 'W', iif( human->pol == '�', '1', '2' ) )
    mo_add_xml_stroke( oPAC, 'DR', date2xml( human->date_r ) )
    If Empty( arr_fio[ 3 ] )
      mo_add_xml_stroke( oPAC, 'DOST', '1' ) // ��������� ����⢮
    Endif
    If Empty( arr_fio[ 2 ] )
      mo_add_xml_stroke( oPAC, 'DOST', '3' ) // ��������� ���
    Endif
    If p_tip_reestr == 2 // ����뢠���� ⮫쪮 ��� ��ᯠ��ਧ�樨 �� �।��⠢����� ᢥ�����
      If Len( AllTrim( kart_->PHONE_H ) ) == 11
        mo_add_xml_stroke( oPAC, 'TEL', SubStr( kart_->PHONE_H, 2 ) )
      Elseif Len( AllTrim( kart_->PHONE_M ) ) == 11
        mo_add_xml_stroke( oPAC, 'TEL', SubStr( kart_->PHONE_M, 2 ) )
      Elseif Len( AllTrim( kart_->PHONE_W ) ) == 11
        mo_add_xml_stroke( oPAC, 'TEL', SubStr( kart_->PHONE_W, 2 ) )
      Endif
    Endif
  Else
    mo_add_xml_stroke( oPAC, 'W', iif( human_->pol2 == '�', '1', '2' ) )
    mo_add_xml_stroke( oPAC, 'DR', date2xml( human_->date_r2 ) )
    mo_add_xml_stroke( oPAC, 'FAM_P', arr_fio[ 1 ] )
    If !Empty( arr_fio[ 2 ] )
      mo_add_xml_stroke( oPAC, 'IM_P', arr_fio[ 2 ] )
    Endif
    If !Empty( arr_fio[ 3 ] )
      mo_add_xml_stroke( oPAC, 'OT_P', arr_fio[ 3 ] )
    Endif
    mo_add_xml_stroke( oPAC, 'W_P', iif( human->pol == '�', '1', '2' ) )
    mo_add_xml_stroke( oPAC, 'DR_P', date2xml( human->date_r ) )
    If Empty( arr_fio[ 3 ] )
      mo_add_xml_stroke( oPAC, 'DOST_P', '1' ) // ��������� ����⢮
    Endif
    If Empty( arr_fio[ 2 ] )
      mo_add_xml_stroke( oPAC, 'DOST_P', '3' ) // ��������� ���
    Endif
  Endif
  If !Empty( smr := del_spec_symbol( kart_->mesto_r ) )
    mo_add_xml_stroke( oPAC, 'MR', smr )
  Endif
  If human_->vpolis == 3 .and. emptyany( kart_->nom_ud, kart_->nom_ud )
    // ��� ������ ����� ��ᯮ�� ����易⥫��
  Else
    mo_add_xml_stroke( oPAC, 'DOCTYPE', lstr( kart_->vid_ud ) )
    If !Empty( kart_->ser_ud )
      mo_add_xml_stroke( oPAC, 'DOCSER', kart_->ser_ud )
    Endif
    mo_add_xml_stroke( oPAC, 'DOCNUM', kart_->nom_ud )
  Endif
  If fl_ver == 32 .and. human_->vpolis < 3 .and. !eq_any( Left( human_->OKATO, 2 ), '  ', '18' ) // �����த���
    If !Empty( kart_->kogdavyd )
      mo_add_xml_stroke( oPAC, 'DOCDATE', date2xml( kart_->kogdavyd ) )
    Endif
    If !Empty( kart_->kemvyd ) .and. ;
        !Empty( smr := del_spec_symbol( inieditspr( A__POPUPMENU, dir_server() + 's_kemvyd', kart_->kemvyd ) ) )
      mo_add_xml_stroke( oPAC, 'DOCORG', smr )
    Endif
  Endif
  If !Empty( kart->snils )
    mo_add_xml_stroke( oPAC, 'SNILS', Transform_SNILS( kart->SNILS ) )
  Endif
  If human_->vpolis == 3 .and. Empty( kart_->okatog )
    // ��� ������ ����� ���� ॣ����樨 ����易⥫쭮
  Else
    mo_add_xml_stroke( oPAC, 'OKATOG', kart_->okatog )
  Endif
  If Len( AllTrim( kart_->okatop ) ) == 11
    mo_add_xml_stroke( oPAC, 'OKATOP', kart_->okatop )
  Endif
  Select( tmpSelect )
  return nil