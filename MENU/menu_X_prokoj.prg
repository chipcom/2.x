#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_prokoj()

  local fl

  fl := begin_task_ppokoj()
  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~���� ����� ' )
  AAdd( main_message, '���� ������ � ��񬭮� ����� ��樮���' )
  AAdd( first_menu, { '~����������', ;
    '~������஢����', 0, ;
    '� ��㣮� ~�⤥�����', 0, ;
    '~��������' ;
  } )
  AAdd( first_message, { ;
    '���������� ���ਨ �������', ;
    '������஢���� ���ਨ ������� � ����� ����樭᪮� � ���.�����', ;
    '��ॢ�� ���쭮�� �� ������ �⤥����� � ��㣮�', ;
    '�������� ���ਨ �������';
    } )
  AAdd( func_menu, { 'add_ppokoj()', ;
    'edit_ppokoj()', ;
    'ppokoj_perevod()', ;
    'del_ppokoj()' ;
  } )
  AAdd( cmain_menu, 34 )
  AAdd( main_menu, ' ~���ଠ�� ' )
  AAdd( main_message, '��ᬮ�� / ����� ����⨪� �� �����' )
  AAdd( first_menu, { '~��ୠ� ॣ����樨', ;
    '��ୠ� �� ~������', 0, ;
    '~������� ���ଠ��', 0, ;
    '~��ॢ�� �/� �⤥����ﬨ', 0, ;
    '���� ~�訡��' ;
  } )
  AAdd( first_message, { ;
    '��ᬮ��/����� ��ୠ�� ॣ����樨 ��樮����� ������', ;
    '��ᬮ��/����� ��ୠ�� ॣ����樨 ��樮����� ������ �� ������', ;
    '������ ������⢠ �ਭ���� ������ � ࠧ������ �� �⤥�����', ;
    '����祭�� ���ଠ樨 � ��ॢ��� ����� �⤥����ﬨ', ;
    '���� �訡�� �����';
    } )
  AAdd( func_menu, { 'pr_gurnal_pp()', ;
    'z_gurnal_pp()', ;
    'pr_svod_pp()', ;
    'pr_perevod_pp()', ;
    'pr_error_pp()' ;
  } )
  AAdd( cmain_menu, 51 )
  AAdd( main_menu, ' ~��ࠢ�筨�� ' )
  AAdd( main_message, '������� �ࠢ�筨���' )
  AAdd( first_menu, { '~�⮫�', ;
    '~����ன��' ;
  } )
  AAdd( first_message, { ;
    '����� � �ࠢ�筨��� �⮫��', ;
    '����ன�� ���祭�� �� 㬮�砭��';
  } )
  AAdd( func_menu, { 'f_pp_stol()', ;
    'pp_nastr()' ;
  } )
  return fl