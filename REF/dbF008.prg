** 27.02.21 ������ �����䨪��� ⨯�� ���㬥�⮢, ���⢥ত���� 䠪� ���客���� �� ��� F008.xml
function getF008()
  // F008.xml - �����䨪��� ⨯�� ���㬥�⮢, ���⢥ত���� 䠪� ���客���� �� ���
  //  1 - DOCNAME(C)  2 - IDDOC(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'����� ��� ��ண� ��ࠧ�', 1, stod('20110101'), stod('')})
    aadd(_arr, {'�६����� ᢨ��⥫��⢮, ���⢥ত��饥 ��ଫ���� ����� ��易⥫쭮�� ����樭᪮�� ���客����', 2, stod('20110101'), stod('')})
    aadd(_arr, {'����� ��� ������� ��ࠧ�', 3, stod('20110101'), stod('')})
  endif

  return _arr