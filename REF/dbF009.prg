// 27.02.21 ������ �����䨪��� ����� �����客������ ��� F009.xml
function getF009()
  // F009.xml - �����䨪��� ����� �����客������ ���
  //  1 - StatusName(C)  2 - IDStatus(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'������騩', 1, stod('20110101'), stod('')})
    aadd(_arr, {'��ࠡ���騩', 2, stod('20110101'), stod('')})
  endif

  return _arr