// 21.10.22 ������ �����䨪��� �� ����樭᪮� ����� V014.xml
function getV014()
  // V014.xml - �����䨪��� �� ����樭᪮� �����
  //  1 - FRMMPNAME(C)  2 - IDFRMMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'����७���', 1, stod('20130101'), stod('')})
    aadd(_arr, {'���⫮����', 2, stod('20130101'), stod('')})
    aadd(_arr, {'��������', 3, stod('20130101'), stod('')})
  endif

  return _arr