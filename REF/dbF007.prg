
* 27.02.21 ������ ���ᨢ �����䨪��� ������⢥���� �ਭ��������� ����樭᪮� �࣠����樨 F007.xml
function getF007()
  // F007.xml - �����䨪��� ������⢥���� �ਭ��������� ����樭᪮� �࣠����樨
  //  1 - VEDNAME(C)  2 - IDVED(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {"�㭨樯��쭮�� ��ࠧ������",1,stod("20110101"),stod("")})
    aadd(_arr, {"��ꥪ� ���ᨩ᪮� �����樨",2,stod("20110101"),stod("")})
    aadd(_arr, {"�����ࠢ��ࠧ���� ���ᨨ",3,stod("20110101"),stod("")})
    aadd(_arr, {"�����ୠ㪨 ���ᨨ",4,stod("20110101"),stod("")})
    aadd(_arr, {"������஭� ���ᨨ",5,stod("20110101"),stod("")})
    aadd(_arr, {"��� ���ᨨ",6,stod("20110101"),stod("")})
    aadd(_arr, {"������ ���ᨨ ����",7,stod("20110101"),stod("")})
    aadd(_arr, {"��� ���ᨨ",8,stod("20110101"),stod("")})
    aadd(_arr, {"����",9,stod("20110101"),stod("")})
    aadd(_arr, {"���� ���ᨨ",10,stod("20110101"),stod("")})
    aadd(_arr, {"���� 䥤�ࠫ��� ��������� � �������",11,stod("20110101"),stod("")})
    aadd(_arr, {'��� ��� "���"',12,stod("20110101"),stod("")})
    aadd(_arr, {"��⮭���� ��",13,stod("20110101"),stod("")})
    aadd(_arr, {"����⢥����, ५�������� �࣠����権",14,stod("20110101"),stod("")})
    aadd(_arr, {"���",15,stod("20110101"),stod("")})
  endif

  return _arr