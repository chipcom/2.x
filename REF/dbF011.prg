* 27.02.21 ������ �����䨪��� ⨯�� ���㬥�⮢, 㤮�⮢������ ��筮��� F011.xml
function getF011()
  // F011.xml - �����䨪��� ⨯�� ���㬥�⮢, 㤮�⮢������ ��筮���
  //  1 - DocName(C)  2 - IDDoc(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DocSer(C)  6 - DocNum(C)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {"��ᯮ�� �ࠦ������ ����",1,stod("20110101"),stod(""),"R-��","999999"})
    aadd(_arr, {"���࠭��ᯮ�� �ࠦ������ ����",2,stod("20110101"),stod(""),"S","00000009"})
    aadd(_arr, {"�����⥫��⢮ � ஦�����, �뤠���� � ���ᨩ᪮� �����樨",3,stod("20110101"),stod(""),"R-��","999999"})
    aadd(_arr, {"����⮢�७�� ��筮�� ����",4,stod("20110101"),stod(""),"��","9999999"})
    aadd(_arr, {"��ࠢ�� �� �᢮�������� �� ���� ��襭�� ᢮����",5,stod("20110101"),stod(""),"S","00000009"})
    aadd(_arr, {"��ᯮ�� ������䫮�",6,stod("20110101"),stod(""),"��","999999"})
    aadd(_arr, {"������ �����",7,stod("20110101"),stod(""),"��","9999990"})
    aadd(_arr, {"���������᪨� ��ᯮ�� �ࠦ������ ���ᨩ᪮� �����樨",8,stod("20110101"),stod(""),"99","9999999"})
    aadd(_arr, {"��ᯮ�� �����࠭���� �ࠦ������",9,stod("20110101"),stod(""),"S","0000000009"})
    aadd(_arr, {"�����⥫��⢮ � ॣ����樨 室�⠩�⢠ � �ਧ����� �����࠭� �����楬 �� ����ਨ ���ᨩ᪮� �����樨",10,stod("20110101"),stod(""),"S","00000009"})
    aadd(_arr, {"��� �� ��⥫��⢮",11,stod("20110101"),stod(""),"S1","00000009"})
    aadd(_arr, {"����⮢�७�� ������ � ���ᨩ᪮� �����樨",12,stod("20110101"),stod(""),"S","00000009"})
    aadd(_arr, {"�६����� 㤮�⮢�७�� ��筮�� �ࠦ������ ���ᨩ᪮� �����樨",13,stod("20110101"),stod(""),"S","00000009"})
    aadd(_arr, {"��ᯮ�� �ࠦ������ ���ᨩ᪮� �����樨",14,stod("20110101"),stod(""),"99 99","9999990"})
    aadd(_arr, {"���࠭��� ��ᯮ�� �ࠦ������ ���ᨩ᪮� �����樨",15,stod("20110101"),stod(""),"99","9999999"})
    aadd(_arr, {"��ᯮ�� ���猪",16,stod("20110101"),stod(""),"��","9999990"})
    aadd(_arr, {"������ ����� ���� �����",17,stod("20110101"),stod(""),"��","999999"})
    aadd(_arr, {"��� ���㬥���",18,stod("20110101"),stod(""),"S1","0000000009"})
    aadd(_arr, {"���㬥�� �����࠭���� �ࠦ������",21,stod("20130704"),stod(""),"S1","000000000009"})
    aadd(_arr, {"���㬥�� ��� ��� �ࠦ����⢠",22,stod("20130704"),stod(""),"S1","000000000009"})
    aadd(_arr, {"����襭�� �� �६����� �஦������",23,stod("20130704"),stod(""),"S1","000000000009"})
    aadd(_arr, {"�����⥫��⢮ � ஦�����, �뤠���� �� � ���ᨩ᪮� �����樨",24,stod("20130704"),stod(""),"S1","000000000009"})
  endif

  return _arr