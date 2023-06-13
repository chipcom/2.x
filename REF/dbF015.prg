
// 17.02.21 ������ ���ᨢ �ࠢ�筨�� ����� F015.xml
function getF015()
  // F015.xml - �����䨪��� 䥤�ࠫ��� ���㣮�
  //  1 - OKRNAME(C)  2 - KOD_OK(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  local dbName := "f015"
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {"����ࠫ�� 䥤�ࠫ�� ����",1,stod("20110101"),stod("")})
    aadd(_arr, {"���� 䥤�ࠫ�� ����",2,stod("20110101"),stod("")})
    aadd(_arr, {"�����-������� 䥤�ࠫ�� ����",3,stod("20110101"),stod("")})
    aadd(_arr, {"���쭥������ 䥤�ࠫ�� ����",4,stod("20110101"),stod("")})
    aadd(_arr, {"�����᪨� 䥤�ࠫ�� ����",5,stod("20110101"),stod("")})
    aadd(_arr, {"�ࠫ�᪨� 䥤�ࠫ�� ����",6,stod("20110101"),stod("")})
    aadd(_arr, {"�ਢ���᪨� 䥤�ࠫ�� ����",7,stod("20110101"),stod("")})
    aadd(_arr, {"�����-������᪨� 䥤�ࠫ�� ����",8,stod("20110101"),stod("")})
    aadd(_arr, {"-",0,stod("20110101"),stod("")})
  endif

  return _arr