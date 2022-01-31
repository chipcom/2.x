#include "function.ch"

// �㭪樨 �஢�ન �ਬ������� ���� � 2022 ����
//
***** 18.01.22 �஢�ઠ ��㢨� ��� �ਬ������ ����=1 ��� 2022 ����
function conditionKSLP_1_22(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f., y

  // ����=1 ᯠ�쭮� ���� ��������� �।�⠢�⥫�, ����� ������
  count_ymd( ctod(DOB), ctod(n_date), @y )
  aKSLP_ := list2arr(aKSLP)  // �८�ࠧ㥬 ��ப� ��࠭��� ���� � ���ᨢ
  if between(y, 0, 18) .and. ascan(aKSLP_, 1) > 0
    // �㭪� 3.1.1 �।��⠢����� ᯠ�쭮�� ���� � ��⠭�� ��������� �।�⠢�⥫� ��ᮢ��襭����⭨�
    // (��� �� 4 ���, ��� ���� 4 ��� �� ����稨 ����樭᪨� ���������) (����1, ����2).
    // �।��⠢����� ᯠ�쭮�� ���� � ��⠭�� ��������� �।�⠢�⥫�, �� ������ ॡ���� 
    // ���� 4 ���, �����⢫���� �� ����稨 ����樭᪨� ��������� � ��ଫ���� 
    // ��⮪���� ��祡��� �����ᨨ � ��易⥫�� 㪠������ � ��ࢨ筮� ����樭᪮� ���㬥��樨.
    fl := .t.
    endif
  return fl

***** 18.01.22 �஢�ઠ ��㢨� ��� �ਬ������ ����=2 ��� 2022 ����
function conditionKSLP_2_22(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f., y
  
  // ����=2 ᯠ�쭮� ���� ��������� �।�⠢�⥫�, ����� ������
  count_ymd( ctod(DOB), ctod(n_date), @y )
  aKSLP_ := list2arr(aKSLP)  // �८�ࠧ㥬 ��ப� ��࠭��� ���� � ���ᨢ
  if between(y, 0, 18) .and. ascan(aKSLP_, 2) > 0
    // �㭪� 3.1.1 �।��⠢����� ᯠ�쭮�� ���� � ��⠭�� ��������� �।�⠢�⥫� ��ᮢ��襭����⭨�
    // (��� �� 4 ���, ��� ���� 4 ��� �� ����稨 ����樭᪨� ���������) (����1, ����2).
    // �।��⠢����� ᯠ�쭮�� ���� � ��⠭�� ��������� �।�⠢�⥫�, �� ������ ॡ���� 
    // ���� 4 ���, �����⢫���� �� ����稨 ����樭᪨� ��������� � ��ଫ���� 
    // ��⮪���� ��祡��� �����ᨨ � ��易⥫�� 㪠������ � ��ࢨ筮� ����樭᪮� ���㬥��樨.
    fl := .t.
    endif
  return fl
  
  ***** 18.01.22 �஢�ઠ �᫮��� ��� �ਬ������ ����=3 ��� 2022 ����
function conditionKSLP_3_22(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f., age

  // ����=3 ��樥��� ���� 75 ���
  count_ymd( ctod(DOB), ctod(n_date), @age )
  if age >= 75
    // 3.1.2. �������� ����樭᪮� ����� ��樥��� � ������ ���� 75 ��� � ��砥 
    // �஢������ �������樨 ���-��ਠ��.
    // �ਬ������ �� �������� ����樭᪮� ����� ��樥�⠬ � ������ 75 ��� 
    // � ����� �� ��易⥫쭮� �஢������ �������樨 ���-��ਠ��. 
    // �� �ਬ������ �� ��ᯨ⠫���樨 �� ��䨫�� ��஭⮫����᪨� �����.
    if (profil != 16 .and. ! (lshifr == "st38.001"))
      fl := .t.
    endif
  endif
  return fl