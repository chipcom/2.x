
// 27.02.21 ������ ���ᨢ �����䨪��� ����ᮢ ������ ����樭᪮� ����� F005.xml
function getF005()
  // F005.xml - �����䨪��� ����ᮢ ������ ����樭᪮� �����
  //  1 - STNAME(C)  2 - IDIDST(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'�� �ਭ�� �襭�� �� �����', 0, stod('20110101'), stod('')})
    aadd(_arr, {'����祭�', 1, stod('20110101'), stod('')})
    aadd(_arr, {'�� ����祭�', 2, stod('20110101'), stod('')})
    aadd(_arr, {'����筮 ����祭�', 3, stod('20110101'), stod('')})
  endif

  return _arr