

***** 01.02.21 
Function f_cena_kiro(/*@*/_cena, lkiro, dateSl )
  // _cena - �����塞�� 業�
  // lkiro - �஢��� ����
  // dateSl - ��� ����
  Local _akiro := {0,1}
  local aKIRO, i

  if year(dateSl) == 2021
    aKIRO := getKIROtable( dateSl )
    if (i := ascan(aKIRO, {|x| x[1] == lkiro })) > 0
      if between_date(aKIRO[i, 5], aKIRO[i, 6], dateSl)
        _akiro := { lkiro, aKIRO[i, 4] }
      endif
    endif
  else
    do case
      case lkiro == 1 // ����� 4-� ����, �믮����� ����.����⥫��⢮
        _akiro := {lkiro,0.8}
      case lkiro == 2 // ����� 4-� ����, ����.��祭�� �� �஢�������
        _akiro := {lkiro,0.2}
      case lkiro == 3 // ����� 3-� ����, �믮����� ����.����⥫��⢮, ��祭�� ��ࢠ��
        _akiro := {lkiro,0.9}
      case lkiro == 4 // ����� 3-� ����, ����.��祭�� �� �஢�������, ��祭�� ��ࢠ��
        _akiro := {lkiro,0.9}
      case lkiro == 5 // ����� 4-� ����, ��ᮡ���� ������樨 �� ���� �९���
        _akiro := {lkiro,0.2}
      case lkiro == 6 // ����� 3-� ����, ��ᮡ���� ������樨 �� ���� �९���, ��祭�� ��ࢠ��
        _akiro := {lkiro,0.9}
    endcase
  endif
  _cena := round_5(_cena*_akiro[2],0)  // ���㣫���� �� �㡫�� � 2019 ����
  return _akiro  