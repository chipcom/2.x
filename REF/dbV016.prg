* 28.02.21 ������ �����䨪��� ����� ��ᯠ��ਧ�樨/���ᬮ�஢ V016.xml
function getV016()
  // V016.xml - �����䨪��� ����� ��ᯠ��ਧ�樨/���ᬮ�஢
  //  1 - kod(N), 2 - IDDT(C)  3 - DTNAME(C)  4 - DATEBEG(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {201,"��1","���� �⠯ ��ᯠ��ਧ�樨 ��।������� ��㯯 ���᫮�� ��ᥫ���� (1 ࠧ � 3 ����)",stod("2016-01-01")})
    aadd(_arr, {202,"��2","��ன �⠯ ��ᯠ��ਧ�樨 ��।������� ��㯯 ���᫮�� ��ᥫ���� (1 ࠧ � 3 ����)",stod("2016-01-01")})
    aadd(_arr, {203,"���","��䨫����᪨� ����樭᪨� �ᬮ��� ���᫮�� ��ᥫ����",stod("2013-12-26")})
    aadd(_arr, {204,"��3","���� �⠯ ��ᯠ��ਧ�樨 ��।������� ��㯯 ���᫮�� ��ᥫ���� (1 ࠧ � 2 ����)",stod("2018-01-01")})
    aadd(_arr, {205,"��2","��ன �⠯ ��ᯠ��ਧ�樨 ��।������� ��㯯 ���᫮�� ��ᥫ���� (1 ࠧ � 2 ����)",stod("2018-01-01")})
    aadd(_arr, {101,"��1","��ᯠ��ਧ��� �ॡ뢠��� � ��樮����� ��०������ ��⥩-��� � ��⥩, ��室����� � ��㤭�� ��������� ���樨 (������ �� 1 �⠯�)",stod("2017-01-01")})
    aadd(_arr, {102,"��2","��ᯠ��ਧ��� �ॡ뢠��� � ��樮����� ��०������ ��⥩-��� � ��⥩, ��室����� � ��㤭�� ��������� ���樨  (������ �� 2-� �⠯��)",stod("2017-01-01")})
    aadd(_arr, {101,"��1","��ᯠ��ਧ��� ��⥩-��� � ��⥩, ��⠢���� ��� ����祭�� த�⥫��, � ⮬ �᫥ ��뭮������� (㤮�७���), �ਭ���� ��� ����� (�����⥫��⢮) � �ਥ���� ��� ���஭���� ᥬ��  (������ �� 1 �⠯�)",stod("2017-01-01")})
    aadd(_arr, {102,"��2","��ᯠ��ਧ��� ��⥩-��� � ��⥩, ��⠢���� ��� ����祭�� த�⥫��, � ⮬ �᫥ ��뭮������� (㤮�७���), �ਭ���� ��� ����� (�����⥫��⢮) � �ਥ���� ��� ���஭���� ᥬ��  (������ �� 2-� �⠯��)",stod("2017-01-01")})
    aadd(_arr, {301,"��1","����樭᪨� �ᬮ��� ��ᮢ��襭����⭨�, � ⮬ �᫥ �� ����㯫���� � ��ࠧ���⥫�� ��०����� � � ��ਮ� ���祭�� � ��� (��䨫����᪨�) (����騥 �� 1 �⠯�)",stod("2017-01-01")})
    aadd(_arr, {302,"��2","����樭᪨� �ᬮ��� ��ᮢ��襭����⭨�, � ⮬ �᫥ �� ����㯫���� � ��ࠧ���⥫�� ��०����� � � ��ਮ� ���祭�� � ��� (��䨫����᪨�) (����騥 �� 2-� �⠯��)",stod("2017-01-01")})
    aadd(_arr, {303,"��1","����樭᪨� �ᬮ��� ��ᮢ��襭����⭨�, � ⮬ �᫥ �� ����㯫���� � ��ࠧ���⥫�� ��०����� � � ��ਮ� ���祭�� � ��� (�।���⥫��) (����騥 �� 1 �⠯�)",stod("2017-01-01")})
    aadd(_arr, {304,"��2","����樭᪨� �ᬮ��� ��ᮢ��襭����⭨�, � ⮬ �᫥ �� ����㯫���� � ��ࠧ���⥫�� ��०����� � � ��ਮ� ���祭�� � ��� (�।���⥫��) (����騥 �� 2-� �⠯��)",stod("2017-01-01")})
    aadd(_arr, {305,"���","����樭᪨� �ᬮ��� ��ᮢ��襭����⭨�, � ⮬ �᫥ �� ����㯫���� � ��ࠧ���⥫�� ��०����� � � ��ਮ� ���祭�� � ��� (��ਮ���᪨�)",stod("2017-01-01")})
  endif

  return _arr