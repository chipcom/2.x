#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_copy()

  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~����ࢭ�� ����஢���� ' )
  AAdd( main_message, '����ࢭ�� ����஢���� ���� ������' )
  AAdd( first_menu, { ;
    '����஢���� ~���� ������', ;
    '��ࠢ�� ���� ~������', ;
    '��ࠢ�� 䠩�� ~�訡��' ;
  } )
  AAdd( first_message, { ;
    '����ࢭ�� ����஢���� ���� ������', ;
    '����ࢭ�� ����஢���� ���� ������ � ��ࠢ�� ����� �㦡� �����প�', ;
    '����ࢭ�� ����஢���� 䠩�� �訡�� � ��ࠢ�� ��� � �㦡� �����প�' ;
    } )
  AAdd( func_menu, { ;
    'm_copy_DB(1)', ;
    'm_copy_DB(2)', ;
    'errorFileToFTP()' ;
  } )
  return nil