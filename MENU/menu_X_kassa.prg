#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_kassa()

  local fl

  fl := begin_task_kassa()
  //
  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~���� �� ' )
  AAdd( main_message, '���� ������ � ���� �� �� ����� ��㣠�' )
  AAdd( first_menu, { '~���� ������', 0, ;
    '~����⥪�' ;
  } )
  AAdd( first_message,  { ;
    '���������� ���⪠ ��� ��祭�� ���⭮�� ���쭮��', ;
    '����/।���஢���� ����⥪� (ॣ�������)' ;
  } )
  AAdd( func_menu, { 'kas_plat()', ;
    'oms_kartoteka()' ;
  } )
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], '~��ࠢ�� ���' )
  AAdd( first_message[ 1 ], '���� � �ᯥ�⪠ �ࠢ�� � �⮨���� ��������� ����樭᪮� ����� � ��� ���' )
  AAdd( func_menu[ 1 ], 'f_spravka_OMS()' )
  //
  If is_task( X_ORTO )
    AAdd( cmain_menu, cmain_next_pos() )
    AAdd( main_menu, ' ~��⮯���� ' )
    AAdd( main_message, '���� ������ �� ��⮯����᪨� ��㣠�' )
    AAdd( first_menu, { '~���� ����', ;
      '~������஢���� ���鸞', 0, ;
      '~����⥪�' ;
    } )
    AAdd( first_message, { ;
      '����⨥ ᫮����� ���鸞 ��� ���� ���⮣� ��⮯����᪮�� ���鸞', ;
      '������஢���� ��⮯����᪮�� ���鸞 (� �.�. ������ ��� ������ �����)', ;
      '����/।���஢���� ����⥪� (ॣ�������)' ;
    } )
    AAdd( func_menu, { 'f_ort_nar(1)', ;
      'f_ort_nar(2)', ;
      'oms_kartoteka()' ;
    } )
  Endif
  //
  AAdd( cmain_menu, cmain_next_pos() )
  AAdd( main_menu, ' ~���ଠ�� ' )
  AAdd( main_message, '��ᬮ�� / �����' )
  AAdd( first_menu, { iif( is_task( X_ORTO ), '~����� ��㣨', '~����⨪�' ), ;
    '������� �~���⨪�', ; // 10.05
    '���~��筨��', ;
    '����� � ~���ᮩ' ;
  } )
  AAdd( first_message,  { ;   // ���ଠ��
    '��ᬮ�� / ����� ������᪨� ���⮢ �� ����� ��㣠�', ;
    '��ᬮ�� / ����� ᢮���� ������᪨� ���⮢', ;
    '��ᬮ�� ���� �ࠢ�筨���', ;
    '���ଠ�� �� ࠡ�� � ���ᮩ';
  } )
  AAdd( func_menu, { ;    // ���ଠ��
    'prn_k_plat()', ;
    'regi_s_plat()', ;
    'o_sprav()', ;
    'prn_k_fr()';
  } )
  If is_task( X_ORTO )
    ins_array( first_menu[ 3 ], 2, '~��⮯����' )
    ins_array( first_message[ 3 ], 2, '��ᬮ�� / ����� ������᪨� ���⮢ �� ��⮯����' )
    ins_array( func_menu[ 3 ], 2, 'prn_k_ort()' )
  Endif
  //
  AAdd( cmain_menu, cmain_next_pos() )
  AAdd( main_menu, ' ~��ࠢ�筨�� ' )
  AAdd( main_message, '��ᬮ�� / ।���஢���� �ࠢ�筨���' )
  AAdd( first_menu, { '~��㣨 � ᬥ��� 業�', ;
    '~������ ��㣨', ;
    '����� � ~���ᮩ', 0, ;
    '~����ன�� �ணࠬ��' ;
  } )
  AAdd( first_message, { ;
    '������஢���� ᯨ᪠ ���, �� ����� ������ ࠧ�蠥��� ।���஢��� 業�', ;
    '������஢���� ᯨ᪠ ���, �� �뢮����� � ��ୠ� ������஢ (�᫨ 1 � 祪�)', ;
    '����ன�� ࠡ��� � ���ᮢ� �����⮬', ;
    '����ன�� �ணࠬ�� (�������� ���祭�� �� 㬮�砭��)' ;
  } )
  AAdd( func_menu, { 'fk_usl_cena()', ;
    'fk_usl_dogov()', ;
    'fr_nastrojka()', ;
    'nastr_kassa(2)' ;
  } )
  AAdd( first_menu[ 2 ], 0 )
  AAdd( first_menu[ 2 ], '��ࠢ�� ��� ~���' )
  AAdd( first_message[ 2 ], '���⠢����� � ࠡ�� � �ࠢ���� ��� ���' )
  AAdd( func_menu[ 2 ], 'inf_fns()' )
  return fl