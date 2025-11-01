#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_registr()

  local fl

  fl := begin_task_regist()
  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~���������� ' )
  AAdd( main_message, '���������� ���㫠�୮-����������᪮�� ��०�����' )
  AAdd( first_menu, { '~������஢����', ;
    '~����������', 0, ;
    '~��������', ;
    '�㡫����騥�� ~�����', 0;
  } )
  AAdd( first_message, { ;
    '������஢���� ���ଠ樨 �� ����窨 ���쭮�� � ����� ���⪠ ���', ;
    '���������� � ����⥪� ���ଠ樨 � ���쭮�', ;
    '�������� ����窨 ���쭮�� �� ����⥪�', ;
    '���� � 㤠����� �㡫�������� ����ᥩ � ����⥪�';
  } )
  AAdd( func_menu, { 'regi_kart()', ;
    'append_kart()', ;
    'view_kart(2)', ;
    'dubl_zap()';
  } )
  If glob_mo[ _MO_IS_UCH ]
    AAdd( first_menu[ 1 ], '�ਪ९�񭭮� ~��ᥫ����' )
    AAdd( first_message[ 1 ], '����� � �ਪ९��� ��ᥫ�����' )
    AAdd( func_menu[ 1 ], 'pripisnoe_naselenie()' )
  Endif
  AAdd( first_menu[ 1 ], '~��ࠢ�� ���' )
  AAdd( first_message[ 1 ], '���� � �ᯥ�⪠ �ࠢ�� � �⮨���� ��������� ����樭᪮� ����� � ��� ���' )
  AAdd( func_menu[ 1 ], 'f_spravka_OMS()' )
  //
  AAdd( cmain_menu, 34 )
  AAdd( main_menu, ' ~���ଠ�� ' )
  AAdd( main_message, '��ᬮ�� / ����� ����⨪� �� ��樥�⠬' )
  AAdd( first_menu, { '����⨪� �� �ਥ~���', ;
    '���ଠ�� �� ~����⥪�' ;
  } )
  AAdd( first_message, { ;
    '����⨪� �� ��ࢨ�� ��祡�� �ਥ���', ;
    '��ᬮ�� / ����� ᯨ᪮� �� ��⥣���, ��������, ࠩ����, ���⪠�,...' ;
    } )
  AAdd( func_menu, { 'regi_stat()', ;
    'prn_kartoteka()' ;
  } )

/*
  if ( ! isnil( edi_FindPath( PLUGINIFILE ) ) ) .and. ( control_podrazdel_ini( edi_FindPath( PLUGINIFILE ) ) )
    AAdd( first_menu[ 4 ], '�������⥫�� ����������' )
    AAdd( first_message[ 4 ], '�������⥫�� ����������' )
    AAdd( func_menu[ 4 ], 'Plugins()' )
  endif
*/
  AAdd( cmain_menu, 51 )
  AAdd( main_menu, ' ~��ࠢ�筨�� ' )
  AAdd( main_message, '������� �ࠢ�筨���' )
  AAdd( first_menu, { '��ࢨ�� ~�ਥ��', 0, ;
    '~����ன�� (㬮�砭��)';
  } )
  AAdd( first_message, { ;  // �ࠢ�筨��
    '������஢���� �ࠢ�筨�� �� ��ࢨ�� ��祡�� �ਥ���', ;
    '����ன�� ���祭�� �� 㬮�砭��';
  } )
  AAdd( func_menu, { 'edit_priem()', ;
    'regi_nastr(2)';
  } )
  If is_r_mu  // ॣ���� �죮⭨���
    ins_array( main_menu, 2, ' ~�죮⭨�� ' )
    ins_array( main_message, 2, '���� 祫����� � 䥤�ࠫ쭮� ॣ���� �죮⭨���' )
    ins_array( cmain_menu, 2, 19 )
    ins_array( first_menu, 2, ;
      { '~����', '~�������ਠ��� ����', 0, '"~���" �죮⭨��' } )
    ins_array( first_message, 2, ;
      { '���� 祫����� � ॣ���� �죮⭨���, ����� ���.����� �� �ଥ 025/�-04', ;
        '�������ਠ��� ���� �� ॣ����� �죮⭨���', ;
        '������� ���ଠ�� �� ��襬� ���⨭����� �� 䥤�ࠫ쭮�� ॣ���� �죮⭨���' ;
      } )
    ins_array( func_menu, 2, { 'r_mu_human()', 'r_mu_poisk()', 'r_mu_svod()' } )
  Endif
  return fl