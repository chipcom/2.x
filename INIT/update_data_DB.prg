******* 22.12.21 �஢������ ��������� � ᮤ�ন��� �� �� ����������
function update_data_DB(aVersion)
  local snversion := int(aVersion[1]*10000 + aVersion[2]*100 + aVersion[3])
  local ver_base := get_version_DB()

  if ver_base < 21130 // ���室 �� ����� 2.11.30
    correct_DVN_COVID() // ᪮४�஥� ����� 㣫㡫����� ��ᯠ��ਧ�樨
  endif

  if ver_base < 21131 // ���室 �� ����� 2.11.31
    correct_V004_to_V021() // �������� ���� PRVS_V021 ������ �� �ࠢ�筨�� ���. ᯥ樠�쭮�⥩ V021
  endif
  return nil