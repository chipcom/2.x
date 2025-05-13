#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_263()

  local fl, k

  fl := begin_task_263()
  If is_napr_pol
    AAdd( cmain_menu, 1 )
    AAdd( main_menu, ' ~����������� ' )
    AAdd( main_message, '���� / ।���஢���� ���ࠢ����� �� ��ᯨ⠫����� �� �����������' )
    AAdd( first_menu, { ;// '~�஢�ઠ',0,;
      '~���ࠢ�����', ;
      '~���㫨஢����', ;
      '~���ନ஢����', 0, ;
      '~�������� �����', 0, ;
      '~����⥪�' ;
    } )
    AAdd( first_message, { ;// '�஢�ઠ ⮣�, �� ��� �� ᤥ���� � �����������',;
      '���� / ।���஢���� / ��ᬮ�� ���ࠢ����� �� ��ᯨ⠫����� �� �����������', ;
      '���㫨஢���� �믨ᠭ��� ���ࠢ����� �� ��ᯨ⠫����� �� �����������', ;
      '���ନ஢���� ���� ��樥�⮢ � ��� �।���饩 ��ᯨ⠫���樨', ;
      '��ᬮ�� ������⢠ ᢮������ ���� �� ��䨫� � ��樮����/������� ��樮����', ;
      '����� � ����⥪��';
    } )
    AAdd( func_menu, { ;// '_263_p_proverka()',;
      '_263_p_napr()', ;
      '_263_p_annul()', ;
      '_263_p_inform()', ;
      '_263_p_svob_kojki()', ;
      '_263_kartoteka(1)' ;
    } )
  Endif
  If is_napr_stac
    AAdd( cmain_menu, 15 )
    AAdd( main_menu, ' ~��樮��� ' )
    AAdd( main_message, '���� ���� ��ᯨ⠫���樨, ���� ��ᯨ⠫���஢����� � ����� �� ��樮����' )
    AAdd( first_menu, { ;// '~�஢�ઠ',0,;
      '~��ᯨ⠫���樨', ;
      '~�믨᪠ (���⨥)', ;
      '~���ࠢ�����', ;
      '~���㫨஢����', 0, ;
      '~�������� �����', 0, ;
      '~����⥪�' ;
    } )
    AAdd( first_message, { ;// '�஢�ઠ ⮣�, �� ��� �� ᤥ���� � ��樮���',;
      '���������� / ।���஢���� ��ᯨ⠫���権 � ��樮���', ;
      '�믨᪠ (���⨥) ��樥�� �� ��樮���', ;
      '���᮪ ���ࠢ�����, �� ����� ��� �� �뫮 ��ᯨ⠫���樨', ;
      '���㫨஢���� ���ࠢ�����, ����㯨��� �� ���������� �१ �����', ;
      '���� / ।���஢���� ������⢠ ᢮������ ���� �� ��䨫� � ��樮���', ;
      '����� � ����⥪��';
    } )
    AAdd( func_menu, { ;// '_263_s_proverka()',;
      '_263_s_gospit()', ;
      '_263_s_vybytie()', ;
      '_263_s_napr()', ;
      '_263_s_annul()', ;
      '_263_s_svob_kojki()', ;
      '_263_kartoteka(2)' ;
    } )
  Endif
  AAdd( cmain_menu, 29 )
  AAdd( main_menu, ' ~� ����� ' )
  AAdd( main_message, '��ࠢ�� � ����� 䠩��� ������ (��ᬮ�� ��ࠢ������ 䠩���)' )
  AAdd( first_menu, { '~�஢�ઠ ��। ��⠢������ ����⮢', ;
    '~���⠢����� ����⮢ ��� ��ࠢ�� � ��', ;
    '��ᬮ�� ��⮪���� ~�����', 0 } )
  AAdd( first_message,  { ;   // ���ଠ��
    '�஢�ઠ ���ଠ樨 ��। ��⠢������ ����⮢ � ��ࠢ��� � �����', ;
    '���⠢����� ���ଠ樮���� ����⮢ ��� ��ࠢ�� � �����', ;
    '��ᬮ�� ��⮪���� ��⠢����� ���ଠ樮���� ����⮢ ��� ��ࠢ�� � �����';
  } )
  AAdd( func_menu, { ;    // ���ଠ��
    '_263_to_proverka()', ;
    '_263_to_sostavlenie()', ;
    '_263_to_protokol()';
  } )
  k := Len( first_menu )
  If is_napr_pol
    AAdd( first_menu[ k ], 'I0~1-�믨ᠭ�� ���ࠢ�����' )
    AAdd( first_message[ k ], '���᮪ ���ଠ樮���� ����⮢ � �믨ᠭ�묨 ���ࠢ����ﬨ' )
    AAdd( func_menu[ k ], '_263_to_I01()' )
  Endif
  AAdd( first_menu[ k ], 'I0~3-���㫨஢���� ���ࠢ�����' )
  AAdd( first_message[ k ], '���᮪ ���ଠ樮���� ����⮢ � ���㫨஢���묨 ���ࠢ����ﬨ' )
  AAdd( func_menu[ k ], '_263_to_I03()' )
  If is_napr_stac
    AAdd( first_menu[ k ], 'I0~4-��ᯨ⠫���樨 �� ���ࠢ�����' )
    AAdd( first_message[ k ], '���᮪ ���ଠ樮���� ����⮢ � ��ᯨ⠫����ﬨ �� ���ࠢ�����' )
    AAdd( func_menu[ k ], '_263_to_I04(4)' )
    //
    AAdd( first_menu[ k ], 'I0~5-���७�� ��ᯨ⠫���樨' )
    AAdd( first_message[ k ], '���᮪ ���ଠ樮���� ����⮢ � ��ᯨ⠫����ﬨ ��� ���ࠢ����� (����.� ����.)' )
    AAdd( func_menu[ k ], '_263_to_I04(5)' )
    //
    AAdd( first_menu[ k ], 'I0~6-���訥 ��樥���' )
    AAdd( first_message[ k ], '���᮪ ���ଠ樮���� ����⮢ � ᢥ����ﬨ � ����� ��樥���' )
    AAdd( func_menu[ k ], '_263_to_I06()' )
  Endif
  AAdd( first_menu[ k ], 0 )
  AAdd( first_menu[ k ], '~����ன�� ��⠫����' )
  AAdd( first_message[ k ], '����ன�� ��⠫���� ������ - �㤠 �����뢠�� ᮧ����� ��� ����� 䠩��' )
  AAdd( func_menu[ k ], '_263_to_nastr()' )
  //
  AAdd( cmain_menu, 39 )
  AAdd( main_menu, ' �� ~����� ' )
  AAdd( main_message, '����祭�� �� ����� 䠩��� ������ � ��ᬮ�� ����祭��� 䠩���' )
  AAdd( first_menu, { '~�⥭�� �� �����', ;
    '~��ᬮ�� ��⮪���� �⥭��', 0 } )
  AAdd( first_message,  { ;   // ���ଠ��
    '����祭�� �� ����� 䠩��� ������ (���ଠ樮���� ����⮢)', ;
    '��ᬮ�� ��⮪���� �⥭�� ���ଠ樮���� ����⮢ �� �����';
  } )
  AAdd( func_menu, { ;
    '_263_from_read()', ;
    '_263_from_protokol()';
  } )
  k := Len( first_menu )
  If is_napr_stac
    AAdd( first_menu[ k ], 'I0~1-����祭�� ���ࠢ�����' )
    AAdd( first_message[ k ], '���᮪ ���ଠ樮���� ����⮢ � ����祭�묨 ���ࠢ����ﬨ �� ����������' )
    AAdd( func_menu[ k ], '_263_from_I01()' )
  Endif
  AAdd( first_menu[ k ], 'I0~3-���㫨஢���� ���ࠢ�����' )
  AAdd( first_message[ k ], '���᮪ ���ଠ樮���� ����⮢ � ���㫨஢���묨 ���ࠢ����ﬨ' )
  AAdd( func_menu[ k ], '_263_from_I03()' )
  If is_napr_pol
    AAdd( first_menu[ k ], 'I0~4-��ᯨ⠫���樨 �� ���ࠢ�����' )
    AAdd( first_message[ k ], '���᮪ ���ଠ樮���� ����⮢ � ��ᯨ⠫����ﬨ �� ���ࠢ�����' )
    AAdd( func_menu[ k ], '_263_from_I04()' )
    //
    AAdd( first_menu[ k ], 'I0~5-���७�� ��ᯨ⠫���樨' )
    AAdd( first_message[ k ], '���᮪ ���ଠ樮���� ����⮢ � ��ᯨ⠫����ﬨ ��� ���ࠢ����� (����.� ����.)' )
    AAdd( func_menu[ k ], '_263_from_I05()' )
    //
    AAdd( first_menu[ k ], 'I0~6-���訥 ��樥���' )
    AAdd( first_message[ k ], '���᮪ ���ଠ樮���� ����⮢ � ᢥ����ﬨ � ����� ��樥���' )
    AAdd( func_menu[ k ], '_263_from_I06()' )
    //
    AAdd( first_menu[ k ], 'I0~7-����稥 ᢮������ ����' )
    AAdd( first_message[ k ], '���᮪ ���ଠ樮���� ����⮢ � ᢥ����ﬨ � ����稨 ᢮������ ����' )
    AAdd( func_menu[ k ], '_263_from_I07()' )
  Endif
  AAdd( first_menu[ k ], 0 )
  AAdd( first_menu[ k ], '~����ன�� ��⠫����' )
  AAdd( first_message[ k ], '����ன�� ��⠫���� ������ - ��㤠 ����뢠�� ����祭�� �� ����� 䠩��' )
  AAdd( func_menu[ k ], '_263_to_nastr()' )
    //
  return fl