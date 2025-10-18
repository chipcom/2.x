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

// 18.10.25
function rep_psih_health_and_sex( lvozrast, mdata, type )

  // type - ⨯ ���� ���

  local st, ub, ue, fl, s, blk, head_psih, head_sex

  st := Space( 5 )
  ub := '<u><b>'
  ue := '</b></u>'
  head_psih := iif( type == TIP_LU_PN, '13.', '14.' )
  head_sex := iif( type == TIP_LU_PN, '14.', '15.' )
  blk := {| s| __dbAppend(), field->stroke := s }
  fl := ( lvozrast < 5 )
  s := st + head_psih + ' �業�� ����᪮�� ࠧ���� (���ﭨ�):'
  frd->( Eval( blk, s ) )
  if mdata < 0d20250901
    s := st + head_psih + '1. ��� ��⥩ � ������ 0 - 4 ���:'
    frd->( Eval( blk, s ) )
    s := st + '�������⥫쭠� �㭪�� (������ ࠧ����) ' + iif( !fl, '________', ub + st + lstr( m1psih11 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '���ୠ� �㭪�� (������ ࠧ����) ' + iif( !fl, '________', ub + st + lstr( m1psih12 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '�樮���쭠� � �樠�쭠� (���⠪� � ���㦠�騬 ��஬) �㭪樨 (������ ࠧ����) ' + iif( !fl, '________', ub + st + lstr( m1psih13 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '�।�祢�� � �祢�� ࠧ��⨥ (������ ࠧ����) ' + iif( !fl, '________', ub + st + lstr( m1psih14 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    fl := ( lvozrast > 4 )
    s := st + head_psih + '2. ��� ��⥩ � ������ 5 - 17 ���:'
    frd->( Eval( blk, s ) )
    s := st + head_psih + '2.1. ��宬��ୠ� ���: ' + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih21, -1 ),, ub, ue )
    frd->( Eval( blk, s ) )
    s := st + head_psih + '2.2. ��⥫����: ' + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih22, -1 ),, ub, ue )
    frd->( Eval( blk, s ) )
    s := st + head_psih + '2.3. ���樮���쭮-�����⨢��� ���: ' + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih23, -1 ),, ub, ue )
    frd->( Eval( blk, s ) )
  else
    s := st + head_psih + '1. ��� ��⥩ � ������ 0 - 4 ���:'
    frd->( Eval( blk, s ) )
    s := st + '�������⥫쭠� �㭪�� (������ ࠧ����) ' + iif( !fl, '________', ub + st + lstr( m1psih11 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '����襭�� �����⨢��� �㭪権 ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih24 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '����襭�� �祡��� ���몮� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih25 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '���ୠ� �㭪�� (������ ࠧ����) ' + iif( !fl, '________', ub + st + lstr( m1psih12 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '�樮����� ����襭�� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih26 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '�।�祢�� ࠧ��⨥ ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_activ(), m1psih27 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + '�祢�� ࠧ��⨥ (������ ࠧ����) ' + iif( !fl, '________', ub + st + lstr( m1psih14 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + '��������� �� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_partial(), m1psih28 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + '��⨢��� ��� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_used(), m1psih29 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + '����襭�� ����㭨��⨢��� ���몮� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih30 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + 'ᥭ�୮� ࠧ��⨥ ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_sensor(), m1psih31 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    fl := ( lvozrast > 4 )
    s := st + head_psih + '2. ��� ��⥩ � ������ 5 - 17 ���:'
    frd->( Eval( blk, s ) )
    s := st + '���譨� ��� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_view_obraz(), m1psih32 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '����㯥� � ���⠪�� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_contact(), m1psih33 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '䮭 ����஥��� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_nastroenie(), m1psih34 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '������ ������� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih35 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '��⥫����㠫쭠� �㭪�� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_intelect(), m1psih36 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '����襭�� �����⨢��� �㭪権 ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih37 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '����襭�� �祡��� ���몮� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih38 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '��樤���� ���������� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih39 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'ᠬ����०����� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_self_harm(), m1psih40 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + '�樠�쭠� ��� ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_socium(), m1psih41 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
  endif

  // ������� �ࠪ���⨪�
  fl := ( mpol == '�' .and. lvozrast > 9 )
  s := st + '14. �業�� �������� ࠧ���� (� 10 ���):'
  frd->( Eval( blk, s ) )
  s := st + head_sex + '1. ������� ��㫠 ����稪�: � ' + iif( !fl .or. m141p == 0, '________', ub + st + lstr( m141p ) + st + ue )
  s += ' �� ' + iif( !fl .or. m141ax == 0, '________', ub + st + lstr( m141ax ) + st + ue )
  s += ' Fa ' + iif( !fl .or. m141fa == 0, '________', ub + st + lstr( m141fa ) + st + ue ) + '.'
  frd->( Eval( blk, s ) )
  fl := ( mpol == '�' .and. lvozrast > 9 )
  s := st + head_sex + '2. ������� ��㫠 ����窨: � ' + iif( !fl .or. m142p == 0, '________', ub + st + lstr( m142p ) + st + ue )
  s += ' �� ' + iif( !fl .or. m142ax == 0, '________', ub + st + lstr( m142ax ) + st + ue )
  s += ' Ma ' + iif( !fl .or. m142ma == 0, '________', ub + st + lstr( m142ma ) + st + ue )
  s += ' Me ' + iif( !fl .or. m142me == 0, '________', ub + st + lstr( m142me ) + st + ue ) + ';'
  frd->( Eval( blk, s ) )
  s := st + '�ࠪ���⨪� ������㠫쭮� �㭪樨: menarhe ('
  s += iif( !fl .or. m142me1 == 0, '________', ub + st + lstr( m142me1 ) + st + ue ) + ' ���, '
  s += iif( !fl .or. m142me2 == 0, '________', ub + st + lstr( m142me2 ) + st + ue ) + ' ����楢); '
  If fl .and. emptyall( m142p, m142ax, m142ma, m142me, m142me1, m142me2 )
    m1142me3 := m1142me4 := m1142me5 := -1
  Endif
  s += 'menses (�ࠪ���⨪�): ' + f3_inf_dds_karta( mm_142me3(), iif( fl, m1142me3, -1 ),, ub, ue, .f. )
  s += ', ' + f3_inf_dds_karta( mm_142me4(), iif( fl, m1142me4, -1 ),, ub, ue, .f. )
  s += ', ' + f3_inf_dds_karta( mm_142me5(), iif( fl, m1142me5, -1 ), ' � ', ub, ue )
  frd->( Eval( blk, s ) )
  return nil

// 16.10.25
function calc_imt( /*@*/IMT )

  IMT := iif( mHEIGHT != 0, ( mWEIGHT / ( ( mHEIGHT / 100 ) ** 2 ) ), 0 )
  update_get( 'IMT' )
  return .t.

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