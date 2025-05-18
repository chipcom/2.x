#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_orto()

  local fl

  fl := begin_task_orto()
  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~��⮯���� ' )
  AAdd( main_message, '���� ������ �� ��⮯����᪨� ��㣠� � �⮬�⮫����' )
  AAdd( first_menu, { '~����⨥ ���鸞', ;
    '~�����⨥ ���鸞', 0, ;
    '~����⥪�' ;
  } )
  AAdd( first_message,  { ;
    '����⨥ ���鸞-������ (���������� ���⪠ ��� ��祭�� ���쭮��)', ;
    '�����⨥ ���鸞-������ (।���஢���� ���⪠ ��� ��祭�� ���쭮��)', ;
    '����� � ����⥪��' ;
  } )
  AAdd( func_menu, { 'kart_orto(1)', ;
    'kart_orto(2)', ;
    'oms_kartoteka()' ;
  } )
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
    'Oo_statist()', ;
    'o_sprav(-5)', ;   // X_ORTO = 5
    'Oo_proverka()';
  } )
  If glob_kassa == 1   // 10.10.14
    AAdd( first_menu[ 2 ], 0 )
    AAdd( first_menu[ 2 ], '����� � ~���ᮩ' )
    AAdd( first_message[ 2 ], '���ଠ�� �� ࠡ�� � ���ᮩ' )
    AAdd( func_menu[ 2 ], 'inf_fr_orto()' )
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
  AAdd( first_menu, ;
    { '��⮯����᪨� ~��������', ;
      '��稭� ~�������', ;
      '~��㣨 ��� ��祩', 0, ;
      '�।����� (�/~����)', ;
      '~���஢���� ���', 0, ;
      '~���ਠ��';
    } )
  AAdd( first_message, ;
    { '������஢���� �ࠢ�筨�� ��⮯����᪨� ���������', ;
      '������஢���� �ࠢ�筨�� ��稭 ������� ��⥧��', ;
      '����/।���஢���� ���, � ������ �� �������� ��� (�孨�)', ;
      '��ࠢ�筨� �।���⨩, ࠡ����� �� �����������', ;
      '��ࠢ�筨� ���客�� ��������, �����⢫���� ���஢��쭮� ���.���客����', ;
      '��ࠢ�筨� �ਢ������� ��室㥬�� ���ਠ���';
    } )
  AAdd( func_menu, ;
    { 'orto_diag()', ;
      'f_prich_pol()', ;
      'f_orto_uva()', ;
      'edit_pr_vz()', ;
      'edit_d_smo()', ;
      'edit_ort()';
    } )
  If glob_kassa == 1
    AAdd( first_menu[ 3 ], 0 )
    AAdd( first_menu[ 3 ], '����� � ~���ᮩ' )
    AAdd( first_message[ 3 ], '����ன�� ࠡ��� � ���ᮢ� �����⮬' )
    AAdd( func_menu[ 3 ], 'fr_nastrojka()' )
  Endif
  return fl