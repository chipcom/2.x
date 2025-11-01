#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_platn()

  local fl

  fl := begin_task_plat()
  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~����� ��㣨 ' )
  AAdd( main_message, '���� / ।���஢���� ������ �� ���⮢ ��� ������ ����樭᪨� ���' )
  AAdd( first_menu, { '~���� ������' } )
  AAdd( first_message, { '����������/������஢���� ���⪠ ��� ��祭�� ���⭮�� ���쭮��' } )
  AAdd( func_menu, { 'kart_plat()' } )
  If glob_pl_reg == 1
    AAdd( first_menu[ 1 ], '~����/।-��' )
    AAdd( first_message[ 1 ], '����/������஢���� ���⮢ ��� ��祭�� ������ ������' )
    AAdd( func_menu[ 1 ], 'poisk_plat()' )
  Endif
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], '~����⥪�' )
  AAdd( first_message[ 1 ], '����� � ����⥪��' )
  AAdd( func_menu[ 1 ], 'oms_kartoteka()' )
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], '~����� ��� � �/�' )
  AAdd( first_message[ 1 ], '����/।���஢���� ����� �� ����������� � ���஢��쭮�� ���.���客����' )
  AAdd( func_menu[ 1 ], 'oplata_vz()' )
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], '~�����⨥ �/���' )
  AAdd( first_message[ 1 ], '������� ���� ��� (���� �ਧ��� ������� � ���� ���)' )
  AAdd( func_menu[ 1 ], 'close_lu()' )
  //
  AAdd( cmain_menu, 34 )
  AAdd( main_menu, ' ~���ଠ�� ' )
  AAdd( main_message, '��ᬮ�� / ����� ���� �ࠢ�筨��� � ����⨪�' )
  AAdd( first_menu, { '~����⨪�', ;
    '���~��筨��', ;
    '~�஢�ન' ;
  } )
  AAdd( first_message,  { ;   // ���ଠ��
    '��ᬮ�� ����⨪�', ;
    '��ᬮ�� ���� �ࠢ�筨���', ;
    '������� �஢���� ०���';
  } )
  AAdd( func_menu, { ;    // ���ଠ��
    'Po_statist()', ;
    'o_sprav()', ;
    'Po_proverka()';
  } )
  If glob_kassa == 1
    AAdd( first_menu[ 2 ], 0 )
    AAdd( first_menu[ 2 ], '����� � ~���ᮩ' )
    AAdd( first_message[ 2 ], '���ଠ�� �� ࠡ�� � ���ᮩ' )
    AAdd( func_menu[ 2 ], 'inf_fr()' )
  Endif
  AAdd( first_menu[ 2 ], 0 )
  AAdd( first_menu[ 2 ], '��ࠢ�� ��� ~���' )
  AAdd( first_message[ 2 ], '���⠢����� � ࠡ�� � �ࠢ���� ��� ���' )
  AAdd( func_menu[ 2 ], 'inf_fns()' )
  If yes_parol
    AAdd( first_menu[ 2 ], 0 )
    AAdd( first_menu[ 2 ], '����� ~�����஢' )
    AAdd( first_message[ 2 ], '����⨪� �� ࠡ�� �����஢ �� ���� � �� �����' )
    AAdd( func_menu[ 2 ], 'st_operator()' )
  Endif
  //
  AAdd( cmain_menu, 50 )
  AAdd( main_menu, ' ~��ࠢ�筨�� ' )
  AAdd( main_message, '������� �ࠢ�筨���' )
  AAdd( first_menu, {} )
  AAdd( first_message, {} )
  AAdd( func_menu, {} )
  If is_oplata != 7
    AAdd( first_menu[ 3 ], '~��������' )
    AAdd( first_message[ 3 ], '��ࠢ�筨� ������� ��� ������ ���' )
    AAdd( func_menu[ 3 ], 's_pl_meds(1)' )
    //
    AAdd( first_menu[ 3 ], '~�����ન' )
    AAdd( first_message[ 3 ], '��ࠢ�筨� ᠭ��ப ��� ������ ���' )
    AAdd( func_menu[ 3 ], 's_pl_meds(2)' )
  Endif
  AAdd( first_menu[ 3 ], '�।����� (�/~����)' )
  AAdd( first_message[ 3 ], '��ࠢ�筨� �।���⨩, ࠡ����� �� �����������' )
  AAdd( func_menu[ 3 ], 'edit_pr_vz()' )
  //
  AAdd( first_menu[ 3 ], '~���஢���� ���' ) ; AAdd( first_menu[ 3 ], 0 )
  AAdd( first_message[ 3 ], '��ࠢ�筨� ���客�� ��������, �����⢫���� ���஢��쭮� ���.���客����' )
  AAdd( func_menu[ 3 ], 'edit_d_smo()' )
  //
  AAdd( first_menu[ 3 ], '��㣨 �� ���~�' )
  AAdd( first_message[ 3 ], '������஢���� �ࠢ�筨�� ���, 業� �� ����� ������� � �����-� ����' )
  AAdd( func_menu[ 3 ], 'f_usl_date()' )
  If glob_kassa == 1
    AAdd( first_menu[ 3 ], 0 )
    AAdd( first_menu[ 3 ], '����� � ~���ᮩ' )
    AAdd( first_message[ 3 ], '����ன�� ࠡ��� � ���ᮢ� �����⮬' )
    AAdd( func_menu[ 3 ], 'fr_nastrojka()' )
  Endif
  return fl