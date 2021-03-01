
* 27.02.21 ������ ���ᨢ �����䨪��� ����� ����஫� F006.xml
function getF006()
  // F006.xml - �����䨪��� ����� ����஫�
  //  1 - VIDNAME(C)  2 - IDVID(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {"��� (������-��������᪨� ����஫�)",1,stod("20110101"),stod("")})
    aadd(_arr, {"��� (������-��������᪠� ��ᯥ�⨧�)",2,stod("20110101"),stod("20180331")})
    aadd(_arr, {"���� (��ᯥ�⨧� ����⢠ ����樭᪮� �����)",3,stod("20110101"),stod("20180331")})
    aadd(_arr, {"������ ������-��������᪨� ����஫� � �������� ���浪�",10,stod("20180401"),stod("")})
    aadd(_arr, {"������ ������-��������᪨� ����஫� �� ��⥭��� ��",11,stod("20180401"),stod("")})
    aadd(_arr, {"������ ������-��������᪨� ����஫� �� ��㣨� ��稭��",12,stod("20180401"),stod("")})
    aadd(_arr, {"������᪠� ������-��������᪠� ��ᯥ�⨧�",20,stod("20180401"),stod("")})
    aadd(_arr, {"�������� ������-��������᪠� ��ᯥ�⨧� (��砩��� �롮ઠ)",21,stod("20180401"),stod("")})
    aadd(_arr, {"������� ������-��������᪠� ��ᯥ�⨧� �� ������ ����୮�� ���饭�� �� ������ ������ � ⮣� �� ����������� (� �祭�� 15 ���� - �� �������� ���, � �祭�� 30 ���� - �� ����୮� ��ᯨ⠫���樨; � �祭�� 24 �ᮢ �� ������ �।�����饣� �맮�� - �� ����୮� �맮�� ���)",22,stod("20180401"),stod("")})
    aadd(_arr, {"������� ������-��������᪠� ��ᯥ�⨧� �� ������ �� �����客������ ��� ��� ��� �।�⠢�⥫� �� ����㯭���� ����樭᪮� ����� � ����樭᪮� �࣠����樨",23,stod("20180401"),stod("")})
    aadd(_arr, {"����ୠ� ������-��������᪠� ��ᯥ�⨧� � �������� ���浪�",24,stod("20180401"),stod("")})
    aadd(_arr, {"����ୠ� ������-��������᪠� ��ᯥ�⨧� �� ��⥭��� ��",25,stod("20180401"),stod("")})
    aadd(_arr, {"����ୠ� ������-��������᪠� ��ᯥ�⨧� �� ��㣨� ��稭��",26,stod("20180401"),stod("")})
    aadd(_arr, {"������᪠� ��ᯥ�⨧� ����⢠ ����樭᪮� �����",30,stod("20180401"),stod("")})
    aadd(_arr, {"�������� ��ᯥ�⨧� ����⢠ ����樭᪮� ����� (��砩��� �롮ઠ)",31,stod("20180401"),stod("")})
    aadd(_arr, {"������� ��ᯥ�⨧� ����⢠ ����樭᪮� ����� �� ������ �� �����客������ ��� ��� ��� �।�⠢�⥫� �� ����㯭���� � ����⢮ ����樭᪮� ����� � ����樭᪮� �࣠����樨",32,stod("20180401"),stod("")})
    aadd(_arr, {"������� ��ᯥ�⨧� ����⢠ ����樭᪮� ����� �� ���� � ��⠫�� ��室��",33,stod("20180401"),stod("")})
    aadd(_arr, {"������� ��ᯥ�⨧� ����⢠ ����樭᪮� ����� �� ���� ����ਡ��쭨筮�� ����஢���� � �᫮������ �����������",34,stod("20180401"),stod("")})
    aadd(_arr, {"������� ��ᯥ�⨧� ����⢠ ����樭᪮� ����� �� ���� ��ࢨ筮�� ��室� �� ������������ ��� ��㤮ᯮᮡ���� ������ � ��⥩",35,stod("20180401"),stod("")})
    aadd(_arr, {"������� ��ᯥ�⨧� ����⢠ ����樭᪮� ����� �� ������ ����୮�� ���᭮������� ���饭�� �� ������ ������ � ⮣� �� ����������� (� �祭�� 15 ���� - �� �������� ���, � �祭�� 30 ���� - �� ����୮� ��ᯨ⠫���樨; � �祭�� 24 �ᮢ �� ������ �।�����饣� �맮�� - �� ����୮� �맮�� ���)",36,stod("20180401"),stod("")})
    aadd(_arr, {"������� ��ᯥ�⨧� ����⢠ ����樭᪮� ����� �� ���� �⮡࠭��� �� १���⠬ 楫���� ������-��������᪮� ��ᯥ�⨧�",37,stod("20180401"),stod("")})
    aadd(_arr, {"�筠� ��ᯥ�⨧� ����⢠ ����樭᪮� �����",38,stod("20180401"),stod("")})
    aadd(_arr, {"����ୠ� ��ᯥ�⨧� ����⢠ ����樭᪮� ����� � �������� ���浪�",39,stod("20180401"),stod("")})
    aadd(_arr, {"����ୠ� ��ᯥ�⨧� ����⢠ ����樭᪮� ����� �� ��⥭��� ��",40,stod("20180401"),stod("")})
    aadd(_arr, {"����ୠ� ��ᯥ�⨧� ����⢠ ����樭᪮� ����� �� ��㣨� ��稭��",41,stod("20180401"),stod("")})
  endif

  return _arr