#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_common()

  // ��᫥���� ���� ��� ��� ���� � � ��
  AAdd( cmain_menu, MaxCol() -9 )
  AAdd( main_menu, ' ����~�� ' )
  AAdd( main_message, '������, ����ன�� �ਭ��' )
  AAdd( first_menu, { '~����� � �ணࠬ��', ;
    '����~��', ;
    '~����祥 ����', ;
    '~�ਭ��', 0, ;
    '��२������� ࠡ�祣� ��⠫���', ;
    '��⥢�� ~������', ;
    '~�訡��' } )
  AAdd( first_message, { ;
    '�뢮� �� �࠭ ᮤ�ঠ��� 䠩�� README.RTF � ⥪�⮬ ������ � �ணࠬ��', ;
    '�뢮� �� �࠭ �࠭� �����', ;
    '����ன�� ࠡ�祣� ����', ;
    '��⠭���� ����� �ਭ��', ;
    '��२����஢���� �ࠢ�筨��� ��� � ࠡ�祬 ��⠫���', ;
    '����� ��ᬮ�� - �� ��室���� � ����� � � ����� ०���', ;
    '��ᬮ�� 䠩�� �訡��' } )
  AAdd( func_menu, { 'view_file_in_Viewer(dir_exe() + "README.RTF")', ;
    'm_help()', ;
    'nastr_rab_mesto()', ;
    'ust_printer(T_ROW)', ;
    'index_work_dir(dir_exe(), cur_dir(), .t.)', ;
    'net_monitor(T_ROW, T_COL - 7, (hb_user_curUser:IsAdmin()))', ;
    'view_errors()' } )
// ������� ��२�����஢���� �������� 䠩��� ����� �����
  If eq_any( glob_task, X_PPOKOJ, X_OMS, X_PLATN, X_ORTO, X_KASSA, X_263 )
    AAdd( ATail( first_menu ), 0 )
    AAdd( ATail( first_menu ), '���~������஢����' )
    AAdd( ATail( first_message ), '��२�����஢���� ��� ���� ������ ��� ����� "' + array_tasks[ ind_task(), 5 ] + '"' )
    AAdd( ATail( func_menu ), 'pereindex_task()' )
  Endif
  return nil