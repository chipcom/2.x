#include 'function.ch'

// �㭪樨 �஢�ન �ਬ������� ���� � 2021 ����
//
// 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=1 ��� 2021 ����
function conditionKSLP_1_21( aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration, usl_ok, lad_cr )
  // ����=1 ��樥��� ���� 75 ���

  local fl := .f., age

  count_ymd( ctod( DOB ), ctod( n_date), @age )
  if age >= 75
    if ( profil != 16 .and. ! ( lshifr == 'st38.001' ) )
      fl := .t.
    endif
  endif
  return fl

// 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=3 ��� 2021 ����
function conditionKSLP_3_21( aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration, usl_ok, lad_cr )
  // ����=3 ᯠ�쭮� ���� ��������� �।�⠢�⥫�, ����� ������
  // �㭪� 3.1.1
  // �।��⠢����� ᯠ�쭮�� ���� � ��⠭�� ��������� �।�⠢�⥫�, �� ������ 
  // ॡ���� ���� 4 ���, �����⢫���� �� ����稨 ����樭᪨� ��������� � 
  // ��ଫ���� ��⮪���� ��祡��� �����ᨨ � ��易⥫�� 㪠������ � ��ࢨ筮� 
  // ����樭᪮� ���㬥��樨.

  local fl := .f., y
  local aKSLP_

  count_ymd( ctod(DOB), ctod(n_date), @y )
  aKSLP_ := list2arr( aKSLP )  // �८�ࠧ㥬 ��ப� ��࠭��� ���� � ���ᨢ
  if between( y, 0, 18 ) .and. ascan( aKSLP_, 3 ) > 0
    fl := .t.
    endif
  return fl

// 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=4 ��� 2021 ����
function conditionKSLP_4_21( aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration, usl_ok, lad_cr )
  // ����=4 ���㭨���� ���, ����� ������
  // �㭪� 3.1.2
  // ���� �ਬ������ � ����� �᫨ �ப� �஢������ ��ࢮ� ���㭨��樨 ��⨢ 
  // �ᯨ��୮-ᨭ�⨠�쭮� ����᭮� (���) ��䥪樨 ᮢ������ �� �६��� � 
  // ��ᯨ⠫���樥� �� ������ ��祭�� ����襭��, ���������� � ��ਭ�⠫쭮� 
  // ��ਮ��, ������ ���������� � ���㭨��樨.

  local fl := .f., y
  local aKSLP_

  count_ymd( ctod( DOB ), ctod( n_date ), @y )
  aKSLP_ := list2arr( aKSLP )  // �८�ࠧ㥬 ��ப� ��࠭��� ���� � ���ᨢ
  if between( y, 0, 18 ) .and. ascan( aKSLP_, 4 ) > 0
    fl := .t.
  endif
  return fl

// 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=5 ��� 2021 ����
function conditionKSLP_5_21( aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration, usl_ok, lad_cr )
  // ����=5 ࠧ����뢠��� �������㠫쭮�� ����, ����� ������

  local fl := .f.
  local aKSLP_

  aKSLP_ := list2arr( aKSLP )  // �८�ࠧ㥬 ��ப� ��࠭��� ���� � ���ᨢ
  if ascan( aKSLP_, 5 ) > 0
    fl := .t.
  endif
  return fl

// 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=6 ��� 2021 ����
function conditionKSLP_6_21( aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration, usl_ok, lad_cr )
  // ����=6 ��⠭�� ���ࣨ�᪨� ����樨
  // �㭪� 3.1.3
  // ���祭� ��⠭��� (ᨬ��⠭���) ���ࣨ�᪨� ����⥫���, �믮��塞�� �� 
  // �६� ����� ��ᯨ⠫���樨, �।�⠢��� � ⠡���:        

  local fl := .f.
  local aKSLP_

  aKSLP_ := list2arr( aKSLP )  // �८�ࠧ㥬 ��ப� ��࠭��� ���� � ���ᨢ
  if ascan( aKSLP_, 6 ) > 0
    fl := .t.
  endif
  return fl

// 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=7 ��� 2021 ����
function conditionKSLP_7_21( aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration, usl_ok, lad_cr )
  // ����=7 ���� �࣠�� � ������� ���� �࣠��
  // �㭪� 3.1.4
  // � ����� ������ 楫�ᮮ�ࠧ�� �⭮��� ����樨 �� ����� �࣠���/����� ⥫�,
  // �� �믮������ ������ ����室���, � ⮬ �᫥ ��ண����騥 ��室�� ���ਠ��.
  // ���祭� ���ࣨ�᪨� ����⥫���, �� �஢������ ������ �����६���� �� ����
  // ����� �࣠��� ����� ���� �ਬ���� ����, �।�⠢��� � ⠡���:

  local fl := .f.

  if lpar_org > 1
    fl := .t.
  endif
  return fl

// 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=8 ��� 2021 ����
function conditionKSLP_8_21( aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration, usl_ok, lad_cr )
  // ���� = 8 ��⨬��஡��� �࠯��, ����� ������
  // �㭪� 3.1.5
  // � ����� ��祭�� ��樥�⮢ � ��樮����� �᫮���� �� ������������ � �� 
  // �᫮�������, �맢����� ���ம࣠������� � ��⨡��⨪�१��⥭⭮����, � ⠪�� 
  // � ����� ��祭�� �� ������ ���������� ������� �ਬ������ ���� � ᮮ⢥��⢨� 
  // � �ᥬ� ����᫥��묨 ����ﬨ:
  //  1)�����稥 ��䥪樮����� �������� � ����� ����10, �뭥ᥭ���� � ������᪨� 
  //    ������� (�⮫��� �����஢�� ��㯯 ?�᭮���� �������? ��� ?������� �᫮������?);
  //  2)�����稥 १���⮢ ���஡�������᪮�� ��᫥������� � ��।������� 
  //    ���⢨⥫쭮�� �뤥������ ���ம࣠������ � ��⨡���ਠ��� �९��⠬ 
  //    �/��� ��⥪樨 �᭮���� ����ᮢ ��ࡠ������� (�ਭ���, ��⠫����⠫��⠬���),
  //    ���⢥ত���� ���᭮�������� �����祭�� �奬� ��⨡���ਠ�쭮� �࠯�� 
  //    (�।���������� ����稥 १���⮢ �� ������ �����襭�� ���� ��ᯨ⠫���樨, 
  //    � ⮬ �᫥ ��ࢠ�����);
  //  3)��ਬ������ ��� ������ ������ ������⢥����� �९��� � ��७�ࠫ쭮� �ଥ 
  //    �� ����� ��� � ��⠢� �奬 ��⨡���ਠ�쭮� �/��� ��⨬�����᪮� �࠯�� 
  //    � �祭�� �� ����� 祬 5 ��⮪:        

  local fl := .f.
  local aKSLP_

  aKSLP_ := list2arr( aKSLP )  // �८�ࠧ㥬 ��ப� ��࠭��� ���� � ���ᨢ
  if ascan( aKSLP_, 8 ) > 0
    fl := .t.
  endif
  return fl

// 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=9 ��� 2021 ����
function conditionKSLP_9_21( aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration, usl_ok, lad_cr )
  // arr_diag - ���ᨢ ���������, 1 ������� - �᭮���� �������,
  //   ��⠫�� ᮯ������騥 � �᫮������
  //
  // �������� �����騥 �� ���� 9
  // �㭪� 3.1.6
  //  � ⠪�� ᮯ������騬 ����������� � �᫮������ ����������� �⭮�����:
  //    ? ����� ������ ⨯� 1 � 2 (E10.0-E10.9; E11.0-E11.9);
  //    ? �����������, ����祭�� � ���祭� ।��� (��䠭���) �����������, 
  //      ࠧ��饭�� �� ��樠�쭮� ᠩ� ��������⢠ ��ࠢ���࠭���� ��1;
  //    ? ����ﭭ� ᪫�஧ (G35);
  //    ? �஭��᪨� �������� ������ (C91.1);
  //    ? ����ﭨ� ��᫥ �࠭ᯫ���樨 �࣠��� � (���) ⪠��� 
  //      (Z94.0; Z94.1; Z94.4; Z94.8);
  //    ? ���᪨� �ॡࠫ�� ��ࠫ�� (G80.0-G80.9);
  //    ? ���/����, �⠤�� 4� � 4�, ����� (B20 ? B24);
  //    ? ��ਭ�⠫�� ���⠪� �� ���-��䥪樨, ��� (Z20.6).
  // �� �ਬ������ ����9 � ��易⥫쭮� ���浪� � ��ࢨ筮� ����樭᪮� 
  // ���㬥��樨 ��ࠦ����� ��ய���� �஢����� �� ������ ��祭�� 
  // ���㪠������ �殮��� ᮯ������饩 ��⮫���� (���ਬ��: �������⥫�� 
  // ��祡��-���������᪨� ��ய����, �����祭�� ������⢥���� �९��⮢, 
  // 㢥��祭�� �ப� ��ᯨ⠫���樨 � �.�.), ����� ��ࠦ��� �������⥫�� 
  // ������ ����樭᪮� �࣠����樨 �� ��祭�� ������� ��樥��. 

  local diag, i := 0
  local inclDIAG := { ;
    "E10.0", "E10.1", "E10.2", "E10.3", "E10.4", "E10.5", "E10.6", "E10.7", "E10.8", "E10.9", ;
    "E11.0", "E11.1", "E11.2", "E11.3", "E11.4", "E11.5", "E11.6", "E11.7", "E11.8", "E11.9", ;
    "G35", "C91.1", "Z94.0", "Z94.1", "Z94.4", "Z94.8", ;
    "G80.0", "G80.1", "G80.2", "G80.3", "G80.4", "G80.8", "G80.9", ;
    "B20", "B21", "B22", "B23", "B24", ;
    "Z20.6" ;
  }
  local fl := .f., aDiagnozis, y

  aDiagnozis := Slist2arr( arr_diag )  // �८�ࠧ㥬 ��ப� ��࠭��� ��������� � ���ᨢ
  count_ymd( ctod( DOB ), ctod( n_date ), @y )
  if between( y, 0, 18 ) .and. ( len( aDiagnozis ) > 1 )
    return .t.
  endif
  for each diag in aDiagnozis
    i++
    if i == 1 // �ய�᪠�� �᭮���� �������, ���� ⮫쪮 ᮯ������騥 � �᫮������
      loop
    endif
    if upper( substr( diag, 1, 1 ) ) == 'B' // ��-� � ���
      diag := upper( substr( diag, 1, 3 ) )
    else
      diag := upper( diag )
    endif
    if ascan( inclDIAG, diag ) > 0
      fl := .t.
      exit
    endif
  next
  return fl

// 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=10 ��� 2021 ����
function conditionKSLP_10_21( aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration, usl_ok, lad_cr )
  // duration - �த����⥫쭮��� ��祭�� � ����
  // lshifr - ��� ��㣨 ���
  //
  // �㭪� 3.1.7
  // �ࠢ��� �⭥ᥭ�� ��砥� � ᢥ�夫�⥫�� �� �����࠭����� �� ���, 
  // ��ꥤ����騥 ��砨 �஢������ ��祢�� �࠯��, � ⮬ �᫥ � ��⠭�� 
  // � ������⢥���� �࠯��� (st19.075-st19.089, ds19.050-ds19.062), 
  // �.�. 㪠����� ��砨 �� ����� ������� ᢥ�夫�⥫�묨 � ����稢����� 
  // � �ਬ������� ����10.
  //
  // ��㣨 ��� �᪫�祭�� ��� ���� 10

  local exclKSG := { "st19.075", "st19.076", "st19.077", "st19.078", "st19.079", ;
    "st19.080", "st19.081", "st19.082", "st19.083", "st19.084", "st19.085", ;
    "st19.086", "st19.087", "st19.088", "st19.089",; 
    "ds19.050", "ds19.051", "ds19.052", "ds19.053", "ds19.054", "ds19.055", ;
    "ds19.056", "ds19.057", "ds19.058", "ds19.059", "ds19.060", "ds19.061", ;
    "ds19.062" }
  local fl := .f.

  if ( duration > 70 ) .and. ( ascan( exclKSG, lshifr ) == 0 )
    fl := .t.
  endif
  return fl