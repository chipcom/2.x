#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 18.10.25
function input_psih_health( j, age, mdata )

  // j - ⥪��� ��ப� �� �࠭�
  // age - ������
  // mdata - ��� �஢�����
  @ ++j, 1 Say PadC( '�業�� ����᪮�� ࠧ���� ' + iif( age < 5, '(������ ࠧ����):', '' ), 78, '_' )
  If age < 5 .and. mdata < 0d20250901 // �᫨ ����� 5 ��� � mdata < 0d20250901
    @ ++j, 1 Say '�������⥫쭠� �㭪��' Get m1psih11 Pict '99'
    @ ++j, 1 Say '���ୠ� �㭪��      ' Get m1psih12 Pict '99'
    @ --j, 30 Say '�樮���쭠� � �樠�쭠�    ' Get m1psih13 Pict '99'
    @ ++j, 30 Say '�।�祢�� � �祢�� ࠧ��⨥' Get m1psih14 Pict '99'
  elseif age >= 5 .and. mdata < 0d20250901
    @ ++j, 1 Say '��宬��ୠ� ���' Get mpsih21 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say '��⥫����          ' Get mpsih22 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT, , , .f. ) }
    @ --j, 40 Say '��.�����⨢��� ���' Get mpsih23 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT, , , .f. ) }
    ++j
  elseif age < 5 .and. mdata >= 0d20250901
    @ ++j, 1 Say  '�������⥫쭠� �㭪�� ' Get m1psih11 Pict '99'
    @ j, 28 Say  '���ୠ� �㭪�� ' Get m1psih12 Pict '99'
    @ j, 50 Say '�祢�� ࠧ��⨥    ' Get m1psih14 Pict '99'
    @ ++j, 1 Say '���.�����⨢�� �-樨  ' Get mpsih24 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ j, 40 Say '���. �祡�� ���모   ' Get mpsih25 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say '�樮����� ����襭��' Get mpsih26 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ j, 40 Say '�।�祢�� ࠧ��⨥  ' Get mpsih27 reader {| x| menu_reader( x, mm_activ(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say '��������� ��         ' Get mpsih28 reader {| x| menu_reader( x, mm_partial(), A__MENUVERT, , , .f. ) }
    @ j, 40 Say '��⨢��� ���         ' Get mpsih29 reader {| x| menu_reader( x, mm_used(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say '���.����㭨��⨢. ���. ' Get mpsih30 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ j, 40 Say 'ᥭ�୮� ࠧ��⨥    ' Get mpsih31 reader {| x| menu_reader( x, mm_sensor(), A__MENUVERT, , , .f. ) }
  elseif age >= 5 .and. mdata >= 0d20250901
    @ ++j, 1 Say '���譨� ���              ' Get mpsih32 reader {| x| menu_reader( x, mm_view_obraz(), A__MENUVERT, , , .f. ) }
    @ j, 45 Say  '����㯥� � ���⠪��' Get mpsih33 reader {| x| menu_reader( x, mm_contact(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say '䮭 ����஥���           ' Get mpsih34 reader {| x| menu_reader( x, mm_nastroenie(), A__MENUVERT, , , .f. ) }
    @ j, 45 Say  '������ �������' Get mpsih35 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say '��⥫����㠫쭠� �㭪�� ' Get mpsih36 reader {| x| menu_reader( x, mm_intelect(), A__MENUVERT, , , .f. ) }
    @ j, 45 Say  '����襭�� �����⨢��� �㭪権' Get mpsih37 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say '����襭�� �祡��� ���몮�' Get mpsih38 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ j, 45 Say  '��樤���� ����������' Get mpsih39 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say 'ᠬ����०�����          ' Get mpsih40 reader {| x| menu_reader( x, mm_self_harm(), A__MENUVERT, , , .f. ) }
    @ j, 45 Say  '�樠�쭠� ���' Get mpsih41 reader {| x| menu_reader( x, mm_socium(), A__MENUVERT, , , .f. ) }
  endif
  return j

// 15.10.25
function mm_activ()
  return { { '��', 1 }, { '�� ��⨢��', 2 }, { '���', 0 } }

// 15.10.25
function mm_partial()
  return { { '��', 1 }, { '���筮', 2 }, { '���', 0 } }

// 15.10.25
function mm_used()
  return { { '��', 1 }, { '�� ��������', 2 }, { '���', 0 } }

// 15.10.25
function mm_sensor()
  return { { 'ࠧ���', 1 }, { '���筮 ࠧ���', 2 }, { '�� ࠧ���', 0 } }

// 15.10.25
function mm_view_obraz()
  return { { '����⥭', 1 }, { '�� ����⥭', 0 } }

// 15.10.25
function mm_access()
  return { { '��', 1 }, { '���筮 ����㯥�', 2 }, { '���', 0 } }

// 15.10.25
function mm_nastr()
  return { { '஢��', 1 }, { '�������', 2 }, { '�������', 3 }, { '�ॢ����', 0 } }

// 15.10.25
function mm_intelect()
  return { { '��� �ᮡ�����⥩', 0 }, { '����饭�', 1 } }

// 15.10.25
function mm_self_harm()
  return { { '����', 0 }, { '���', 1 } }

// 15.10.25
function mm_socium()
  return { { '����襭�', 0 }, { '�� ����襭�', 1 } }

// 16.10.25
function mm_contact()
  return { { '��', 1 }, { '���筮 ����㯥�', 2 }, { '���', 0 } }

// 16.10.25
function mm_nastroenie()
  return { { '஢��', 1 }, { '�������', 2 }, { '�������', 3 }, { '�ॢ����', 0 } }

function mm_invalid2()
  return { { '� ஦�����', 0 }, { '�ਮ��⥭���', 1 } }
  
function mm_invalid5()
  
  local arr := { ;
    { '������� ��䥪樮��� � ��ࠧ����,', 1 }, ;
    { ' �� ���: �㡥�㫥�,', 101 }, ;
    { '         �䨫��,', 201 }, ;
    { '         ���-��䥪��;', 301 }, ;
    { '������ࠧ������;', 2 }, ;
    { '������� �஢�, �஢�⢮��� �࣠��� ...', 3 }, ;
    { '������� ���ਭ��� ��⥬� ...', 4 }, ;
    { ' �� ���: ���� ������;', 104 }, ;
    { '����᪨� ����ன�⢠ � ����ன�⢠ ���������,', 5 }, ;
    { ' � ⮬ �᫥ ��⢥���� ���⠫����;', 105 }, ;
    { '������� ��ࢭ�� ��⥬�,', 6 }, ;
    { ' �� ���: �ॡࠫ�� ��ࠫ��,', 106 }, ;
    { '         ��㣨� ��ࠫ���᪨� ᨭ�஬�;', 206 }, ;
    { '������� ����� � ��� �ਤ��筮�� ������;', 7 }, ;
    { '������� �� � ��楢������ ����⪠;', 8 }, ;
    { '������� ��⥬� �஢����饭��;', 9 }, ;
    { '������� �࣠��� ��堭��,', 10 }, ;
    { ' �� ���: ��⬠,', 110 }, ;
    { '         ��⬠��᪨� �����;', 210 }, ;
    { '������� �࣠��� ��饢�७��;', 11 }, ;
    { '������� ���� � ��������� �����⪨;', 12 }, ;
    { '������� ���⭮-���筮� ��⥬� � ᮥ����⥫쭮� ⪠��;', 13 }, ;
    { '������� ��祯������ ��⥬�;', 14 }, ;
    { '�⤥��� ���ﭨ�, ��������騥 � ��ਭ�⠫쭮� ��ਮ��;', 15 }, ;
    { '�஦����� ��������,', 16 }, ;
    { ' �� ���: �������� ��ࢭ�� ��⥬�,', 116 }, ;
    { '         �������� ��⥬� �஢����饭��,', 216 }, ;
    { '         �������� ���୮-�����⥫쭮�� ������;', 316 }, ;
    { '��᫥��⢨� �ࠢ�, ��ࠢ����� � ��.', 17 } ;
  }
  return arr

function mm_invalid6()
  
  local arr := { ;
    { '��⢥���', 1 }, ;
    { '��㣨� ��宫����᪨�', 2 }, ;
    { '�몮�� � �祢�', 3 }, ;
    { '��客� � ���⨡����', 4 }, ;
    { '��⥫��', 5 }, ;
    { '����ࠫ�� � ��⠡����᪨� ����ன�⢠ ��⠭��', 6 }, ;
    { '�����⥫��', 7 }, ;
    { '�த��騥', 8 }, ;
    { '��騥 � ����ࠫ��������', 9 } ;
  }
  return arr
  
function mm_invalid8()
  return { { '���������', 1 }, { '���筮', 2 }, { '����', 3 }, { '�� �믮�����', 0 } }
  
function mm_privivki1()
  
  local arr := { ;
    { '�ਢ�� �� �������', 0 }, ;
    { '�� �ਢ�� �� ����樭᪨� ���������', 1 }, ;
    { '�� �ਢ�� �� ��㣨� ��稭��', 2 } ;
  }
  return arr
  
function mm_privivki2()
  return { { '���������', 1 }, { '���筮', 2 } }

function mm_fiz_razv()
  return { { '��ଠ�쭮�', 0 }, { '� �⪫�����ﬨ', 1 } }

function mm_fiz_razv1()
  return { { '���    ', 0 }, { '�����', 1 }, { '����⮪', 2 } }
  
function mm_fiz_razv2()
  return { { '���    ', 0 }, { '������ ', 1 }, { '��᮪��', 2 } }
  
function mm_psih2()
  return { { '��ଠ', 0 }, { '�⪫������', 1 } }

function mm_142me3()
  return { { 'ॣ����', 0 }, { '��ॣ����', 1 } }

function mm_142me4()
  return { { '������', 0 }, { '㬥७��', 1 }, { '�㤭�', 2 } }
  
function mm_142me5()
  return { { '����������', 0 }, { '�������������', 1 } }
  
// 20.09.25
function mm_dispans()
  return { { '࠭��', 1 }, { '�����', 2 }, { '�� ���.', 0 } }

// 20.09.25
function mm_usl()
  return { { '���.', 0 }, { '��/�', 1 }, { '���', 2 } }
  
// 20.09.25
function mm_uch()
  return { { '��� ', 1 }, { '��� ', 0 }, { '䥤.', 2 }, { '���', 3 } }

// 20.09.25
function mm_gr_fiz_do()
  return { { 'I', 1 }, { 'II', 2 }, { 'III', 3 }, { 'IV', 4 } }