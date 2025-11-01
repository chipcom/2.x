#include "common.ch"
#include "set.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 10.09.25
Function f1main( n_Task )
  
  Local it, fl := .t., cNameIcon

  If ( it := AScan( array_tasks(), {| x| x[ 2 ] == n_Task } ) ) == 0
    Return func_error( "�訡�� � �맮�� �����" )
  Endif
  cNameIcon := iif( array_tasks()[ it, 3 ] == NIL, "MAIN_ICON", array_tasks()[ it, 3 ] )
  glob_task := n_Task
  sys_date := Date()
  c4sys_date := dtoc4( sys_date )
  blk_ekran := {|| DevPos( MaxRow() -2, MaxCol() -Len( dir_server() ) ), ;
    DevOut( Upper( dir_server() ), "W+/N*" ) }
  main_menu := {}
  main_message := {}
  first_menu := {}
  first_message := {}
  func_menu := {}
  cmain_menu := {}
  put_icon( array_tasks()[ it, 1 ] + ' ' + short_name_version(), cNameIcon )
  SetColor( color1 )
  fillscreen( p_char_screen, p_color_screen )
  Do Case
  Case glob_task == X_REGIST //
    fl := menu_X_registr()
  Case glob_task == X_PPOKOJ  //
    fl := menu_X_prokoj()
  Case glob_task == X_OMS  //
    fl := menu_X_oms()
  Case glob_task == X_263 //
    fl := menu_X_263()
  Case glob_task == X_PLATN //
    fl := menu_X_platn()
  Case glob_task == X_ORTO  //
    fl := menu_X_orto()
  Case glob_task == X_KASSA //
    fl := menu_X_kassa()
  Case glob_task == X_MO //
    fl := menu_X_vounc()
  Case glob_task == X_SPRAV //
    fl := menu_X_sprav()
  Case glob_task == X_SERVIS //
    menu_X_servis()
  Case glob_task == X_COPY //
    menu_X_copy()
  Case glob_task == X_INDEX //
    menu_X_index()
  Endcase
<<<<<<< HEAD
  // ��᫥���� ���� ��� ��� ���� � � ��
  AAdd( cmain_menu, MaxCol() -9 )
  AAdd( main_menu, " ����~�� " )
  AAdd( main_message, "������, ����ன�� �ਭ��" )
  AAdd( first_menu, { "~����� � �ணࠬ��", ;
    "����~��", ;
    "~����祥 ����", ;
    "~�ਭ��", 0, ;
    "��२������� ࠡ�祣� ��⠫���", ;
    "��⥢�� ~������", ;
    "~�訡��" } )
  AAdd( first_message, { ;
    "�뢮� �� �࠭ ᮤ�ঠ��� 䠩�� README.RTF � ⥪�⮬ ������ � �ணࠬ��", ;
    "�뢮� �� �࠭ �࠭� �����", ;
    "����ன�� ࠡ�祣� ����", ;
    "��⠭���� ����� �ਭ��", ;
    "��२����஢���� �ࠢ�筨��� ��� � ࠡ�祬 ��⠫���", ;
    "����� ��ᬮ�� - �� ��室���� � ����� � � ����� ०���", ;
    "��ᬮ�� 䠩�� �訡��" } )
  AAdd( func_menu, { "view_file_in_Viewer(dir_exe() + 'README.RTF')", ;
    "m_help()", ;
    "nastr_rab_mesto()", ;
    "ust_printer(T_ROW)", ;
    "index_work_dir(dir_exe(), cur_dir(), .t.)", ;
    "net_monitor(T_ROW, T_COL - 7, (hb_user_curUser:IsAdmin()))", ;
    "view_errors()" } )
// ������� ��२�����஢���� �������� 䠩��� ����� �����
//  If eq_any( glob_task, X_PPOKOJ, X_OMS, X_PLATN, X_ORTO, X_KASSA, X_KEK, X_263 )
  If eq_any( glob_task, X_PPOKOJ, X_OMS, X_PLATN, X_ORTO, X_KASSA, X_263 )
    AAdd( ATail( first_menu ), 0 )
    AAdd( ATail( first_menu ), "���~������஢����" )
    AAdd( ATail( first_message ), '��२�����஢���� ��� ���� ������ ��� ����� "' + array_tasks[ ind_task(), 5 ] + '"' )
    AAdd( ATail( func_menu ), "pereindex_task()" )
  Endif

  // ࠡ�� � Plugins
  aadd(atail(first_menu),0)
  aadd(atail(first_menu),"�������⥫�� ����������")
  aadd(atail(first_message),'����� Plugins')
  aadd(atail(func_menu),"plugins()")
  
=======
  menu_X_common()
>>>>>>> master
  If fl
    g_splus( f_name_task() )   // ���� 1 ���짮��⥫� ���� � ������
    func_main( .t., blk_ekran )
    g_sminus( f_name_task() )  // ����� 1 ���짮��⥫� (��襫 �� �����)
  Endif
  Return Nil

// 18.05.25 �������� ᫥������ ������ ��� �������� ���� �����
Function cmain_next_pos( n )

  Default n To 5

  Return ATail( cmain_menu ) + Len( ATail( main_menu ) ) + n