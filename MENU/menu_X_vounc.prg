#include "common.ch"
#include "function.ch"
#include "chip_mo.ch"

// 21.05.25
function menu_X_vounc()

  Local old, fl := .t.

  old := is_uchastok
  If glob_mo[ _MO_KOD_TFOMS ] == TF_KOD_MO_VOUNC
    fl := vounc_begin_task()
    is_uchastok := 1 // �㪢� + � ���⪠ + � � ���⪥ "�25/123"

    AAdd( cmain_menu, 1 )
    AAdd( main_menu, ' ~���� ������ ' )
    AAdd( main_message, '���� ������' )
    AAdd( first_menu, { ;
      '~�����祭��', ;
      '~��楯��', 0, ;
      '~����⥪�' ;
    } )
    AAdd( first_message,  { ;
      '������஢���� �����祭�� ������⢥���� �९��⮢', ;
      '����/।���஢���� �楯⮢', ;
      '����/।���஢���� ����⥪� (ॣ�������)' ;
    } )
    AAdd( func_menu, { ;
      'vounc_input_nazn()', ;
      'vounc_input_recept()', ;
      'oms_kartoteka()' ;
    } )
    //
    AAdd( cmain_menu, 34 )
    AAdd( main_menu, ' ~���ଠ�� ' )
    AAdd( main_message, '��ᬮ�� / �����' )
    AAdd( first_menu, { ;
      '~�����祭��', ;
      '~��楯��', ;
      '~��ࠢ�筨��' ;
    } )
    AAdd( first_message,  { ;   // ���ଠ��
      '��ᬮ�� / ����� �����祭��', ;
      '��ᬮ�� / ����� ���⮢ �� �믨᪥ �楯⮢', ;
      '��ᬮ��/����� �ࠢ�筨���' ;
    } )
    AAdd( func_menu, { ;    // ���ଠ��
      'vounc_info_nazn()', ;
      'vounc_info_recept()', ;
      'vounc_info_sprav()' ;
    } )
    //
    AAdd( cmain_menu, 51 )
    AAdd( main_menu, ' ~��ࠢ�筨�� ' )
    AAdd( main_message, '������஢���� �ࠢ�筨���' )
    AAdd( first_menu, { '~��࣮�� ������������', ;
      '~���', 0, ;
      '~����ன�� �ணࠬ��' ;
    } )
    AAdd( first_message, { ;
      '������஢���� �࣮��� ������������ �९��⮢', ;
      '������஢���� ����㭠த��� ����⥭⮢����� ������������ �९��⮢', ;
      '����ன�� �ணࠬ�� (�������� ���祭�� �� 㬮�砭��)' ;
    } )
    AAdd( func_menu, { 'vounc_sprav_trn()', ;
      'vounc_sprav_mnn()', ;
      'vounc_sprav_nastr(2)' ;
    } )

    is_uchastok := old
  Endif
  return fl

// 21.05.25
/*
Function my_mo_f1main()
  Local old := is_uchastok

  If glob_mo[ _MO_KOD_TFOMS ] == TF_KOD_MO_VOUNC
    is_uchastok := 1 // �㪢� + � ���⪠ + � � ���⪥ "�25/123"
    vounc_f1main()
    is_uchastok := old
  Endif
  Return Nil
*/