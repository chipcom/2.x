#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_oms()

  local fl

  fl := begin_task_oms()
  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~��� ' )
  AAdd( main_message, '���� ������ �� ��易⥫쭮�� ����樭᪮�� ���客����' )
  AAdd( first_menu, { '~����������', ;
    '~������஢����', ;
    '�~����� ��砨', ;
    '����� ~�⤥�����', ;
    '~��������' ;
  } )
  AAdd( first_message, { ;
    '���������� ���⪠ ��� ��祭�� ���쭮��', ;
    '������஢���� ���⪠ ��� ��祭�� ���쭮��', ;
    '����������, ��ᬮ��, 㤠����� ������� ��砥�', ;
    '������஢���� ���⪠ ��� ��祭�� ���쭮�� � ᬥ��� �⤥�����', ;
    '�������� ���⪠ ��� ��祭�� ���쭮��';
  } )
  AAdd( func_menu, { 'oms_add()', ;
    'oms_edit()', ;
    'oms_double()', ;
    'oms_smena_otd()', ;
    'oms_del()' ;
  } )
  If yes_vypisan == B_END
    AAdd( first_menu[ 1 ], '~�����襭�� ��祭��' )
    AAdd( first_message[ 1 ], '������ ࠡ��� � �����襭��� ��祭��' )
    AAdd( func_menu[ 1 ], 'oms_zav_lech()' )
  Endif
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], '~����⥪�' )
  AAdd( first_message[ 1 ], '����� � ����⥪��' )
  AAdd( func_menu[ 1 ], 'oms_kartoteka()' )
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], '~��ࠢ�� ���' )
  AAdd( first_message[ 1 ], '���� � �ᯥ�⪠ �ࠢ�� � �⮨���� ��������� ����樭᪮� ����� � ��� ���' )
  AAdd( func_menu[ 1 ], 'f_spravka_OMS()' )
  //
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], '��������� ~業 ���' )
  AAdd( first_message[ 1 ], '��������� 業 �� ��㣨 � ᮮ⢥��⢨� � �ࠢ�筨��� ��� �����' )
  AAdd( func_menu[ 1 ], 'Change_Cena_OMS()' )
  //
  AAdd( cmain_menu, cmain_next_pos( 3 ) )
  AAdd( main_menu, ' ~������� ' )
  AAdd( main_message, '����, ����� � ��� ॥��஢ ��砥�' )
  AAdd( first_menu, { '��~��ઠ', ;
    '~���⠢�����', ;
    '~��ᬮ��', ;
    '~���⠢����� 2025 ���', 0, ;
    '��~����', 0 ;
  } )
  AAdd( first_message, { ;
    '�஢�ઠ ��। ��⠢������ ॥��� ��砥�', ;
    '���⠢����� ॥��� ��砥�', ;
    '��ᬮ�� ॥��� ��砥�, ��ࠢ�� � �����', ;
    '���⠢����� ॥��� ��砥� �� 2025 ���', ;
    '������ ॥��� ��砥�' ;
  } )
  AAdd( func_menu, { 'verify_OMS()', ;
    'create_reestr()', ;
    'view_list_reestr()', ;
    'create_reestrZSL_2025()', ;
    'vozvrat_reestr()' ;
  } )
  If glob_mo[ _MO_IS_UCH ]
    AAdd( first_menu[ 2 ], '�~ਪ९�����' )
    AAdd( first_message[ 2 ], '��ᬮ�� 䠩��� �ਪ९����� (� �⢥⮢ �� ���), ������ 䠩��� ��� �����' )
    AAdd( func_menu[ 2 ], 'view_reestr_pripisnoe_naselenie()' )
    AAdd( first_menu[ 2 ], '~��९�����' )
    AAdd( first_message[ 2 ], '��ᬮ�� ����祭��� �� ����� 䠩��� ��९�����' )
    AAdd( func_menu[ 2 ], 'view_otkrep_pripisnoe_naselenie()' )
  Endif
  AAdd( first_menu[ 2 ], '~����⠩�⢠' )
  AAdd( first_message[ 2 ], '��ᬮ��, ������ � �����, 㤠����� 䠩��� 室�⠩��' )
  AAdd( func_menu[ 2 ], 'view_list_hodatajstvo()' )
  //
  AAdd( cmain_menu, cmain_next_pos( 3 ) )
  AAdd( main_menu, ' ~��� ' )
  AAdd( main_message, '��ᬮ��, ����� � ��� ��⮢ �� ���' )
  AAdd( first_menu, { '~�⥭�� �� �����', ;
    '���᮪ ~��⮢', ;
    '~���������', ;
    '~���� ����஫�', ;
    '������ ~���㬥���', 0, ;
    '~��稥 ���' ;
  } )
  AAdd( first_message, { ;
    '�⥭�� ���ଠ樨 �� ����� (�� ���)', ;
    '��ᬮ�� ᯨ᪠ ��⮢ �� ���, ������ ��� �����, ����� ��⮢', ;
    '�⬥⪠ � ॣ����樨 ��⮢ � �����', ;
    '����� � ��⠬� ����஫� ��⮢ (� ॥��ࠬ� ��⮢ ����஫�)', ;
    '����� � �����묨 ���㬥�⠬� �� ����� (� ॥��ࠬ� ������� ���㬥�⮢)', ;
    '����� � ��稬� ��⠬� (ᮧ�����, ।���஢����, ������)', ;
  } )
  AAdd( func_menu, { 'read_from_tf()', ;
    'view_list_schet()', ;
    'registr_schet()', ;
    'akt_kontrol()', ;
    'view_pd()', ;
    'other_schets()' ;
  } )
  //
  AAdd( cmain_menu, cmain_next_pos( 3 ) )
  AAdd( main_menu, ' ~���ଠ�� ' )
  AAdd( main_message, '��ᬮ�� / ����� ���� �ࠢ�筨��� � ����⨪�' )
  AAdd( first_menu, { '���� ~���', ;
    '~����⨪�', ;
    '����-~�����', ;
    '~�஢�ન', ;
    '��ࠢ�~筨��', 0, ;
    '����� ~�������' ;
  } )
  AAdd( first_message, { ;
    '��ᬮ�� / ����� ���⮢ ��� ������', ;
    '��ᬮ�� / ����� ����⨪�', ;
    '����⨪� �� ����-������', ;
    '������� �஢�ન', ;
    '��ᬮ�� / ����� ���� �ࠢ�筨���', ;
    '��ᯥ�⪠ �ᥢ�������� �������';
  } )
  AAdd( func_menu, { 'o_list_uch()', ;
    'e_statist()', ;
    'pz_statist()', ;
    'o_proverka()', ;
    'o_sprav()', ;
    'prn_blank()' ;
  } )
  If yes_parol
    AAdd( first_menu[ 4 ], '����� ~�����஢' )
    AAdd( first_message[ 4 ], '����⨪� �� ࠡ�� �����஢ �� ���� � �� �����' )
    AAdd( func_menu[ 4 ], 'st_operator()' )
  Endif

  if ( ! isnil( edi_FindPath( PLUGINIFILE ) ) ) .and. ( control_podrazdel_ini( edi_FindPath( PLUGINIFILE ) ) )
    AAdd( first_menu[ 4 ], '�������⥫�� ����������' )
    AAdd( first_message[ 4 ], '�������⥫�� ����������' )
    AAdd( func_menu[ 4 ], 'Plugins()' )
  endif
    
  //
  AAdd( cmain_menu, cmain_next_pos( 3 ) )
  AAdd( main_menu, ' ~��ᯠ��ਧ��� ' )
  AAdd( main_message, '��ᯠ��ਧ���, ��䨫��⨪�, ����ᬮ��� � ��ᯠ��୮� �������' )
  AAdd( first_menu, { '~��ᯠ��ਧ��� � ���ᬮ���', 0, '��ᯠ��୮� ~�������' } )
  AAdd( first_message, { '��ᯠ��ਧ���, ��䨫��⨪� � ����ᬮ���', '��ᯠ��୮� �������' } )
  AAdd( func_menu, { 'dispanserizacia()', 'disp_nabludenie()' } )
  return fl