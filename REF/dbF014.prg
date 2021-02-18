
* 17.02.21 ������ ���ᨢ �ࠢ�筨�� ����� F014.xml
function getF014()
  // F014.xml - �����䨪��� ��稭 �⪠�� � ����� ����樭᪮� �����
  //  1 - Komment(C)  2 - Kod(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - IDVID(N)  6 - Naim(C)  7 - Osn(C)  8 - KodPG(C)
  local dbName := "f014"
  local _f014 := {}

  /*
  aadd(_f014, {"����襭�� �ࠢ �� �� �롮� ��",1,stod("20110101"),stod(""),0,"����襭�� �ࠢ �����客����� ��� �� ����祭�� ����樭᪮� ����� � ����樭᪮� �࣠����樨 �� �롮� ����樭᪮� �࣠����樨 �� ����樭᪨� �࣠����権, �������� � ॠ����樨 ����ਠ�쭮� �ணࠬ�� ��易⥫쭮�� ����樭᪮�� ���客����.","1.1.1.",""})
  aadd(_f014, {"����襭�� �ࠢ �� �� �롮� ���",2,stod("20110101"),stod(""),0,"����襭�� �ࠢ �����客����� ��� �� ����祭�� ����樭᪮� ����� � ����樭᪮� �࣠����樨 �� �롮� ��� ��⥬ ����� ������ ��筮 ��� �१ ᢮��� �।�⠢�⥫� �� ��� �㪮����⥫� ����樭᪮� �࣠����樨.","1.1.2.",""})
  aadd(_f014, {"����襭�� �ࠢ �� (�᫮��� �������� ��, �ப� ��������)",3,stod("20110101"),stod(""),0,"����襭�� �ࠢ �����客����� ��� �� ����祭�� ����樭᪮� ����� � ����樭᪮� �࣠����樨: ����襭�� �᫮��� �������� ����樭᪮� �����, � ⮬ �᫥ �ப� �������� ����樭᪮� �����, �।��⠢�塞�� � �������� ���浪�.","1.1.3.",""})
  aadd(_f014, {"�����᭮����� �⪠� �� � ��, �� ������訩 �।�",4,stod("20110101"),stod(""),0,"�����᭮����� �⪠� �����客���� ��栬 � �������� ����樭᪮� ����� � ᮮ⢥��⢨� � ����ਠ�쭮� �ணࠬ��� ���, �� ������訩 �� ᮡ�� ��稭���� �।� ���஢��, �� ᮧ���訩 �᪠ �ண���஢���� ����饣��� �����������, �� ᮧ���訩 �᪠ ������������� ������ �����������.","1.2.1.",""})
  aadd(_f014, {"�����᭮����� �⪠� �� � ��, ������訩 �।",5,stod("20110101"),stod(""),0,"�����᭮����� �⪠� �����客���� ��栬 � �������� ����樭᪮� ����� � ᮮ⢥��⢨� � ����ਠ�쭮� �ணࠬ��� ���, ������訩 �� ᮡ�� ��稭���� �।� ���஢��, ���� ᮧ���訩 �� �ண���஢���� ����饣��� �����������, ���� ᮧ���訩 �� ������������� ������ �����������.","1.2.2.",""})
  aadd(_f014, {"�����᭮����� �⪠� �� � �� �� ��㣮� ���., �� ������訩 �।�",6,stod("20110101"),stod(""),0,"�����᭮����� �⪠� �����客���� ��栬 � ��ᯫ�⭮� �������� ����樭᪮� ����� �� ����㯫���� ���客��� ���� �� �।����� ����ਨ ��ꥪ� ���ᨩ᪮� �����樨, � ���஬ �뤠� ����� ��易⥫쭮�� ����樭᪮�� ���客����, � ��ꥬ�, ��⠭�������� ������� �ணࠬ��� ��易⥫쭮�� ����樭᪮�� ���客����, �� ������訩 �� ᮡ�� ��稭���� �।� ���஢��, �� ᮧ���訩 �᪠ �ண���஢���� ����饣��� �����������, �� ᮧ���訩 �᪠ ������������� ������ �����������.","1.3.1.",""})
  aadd(_f014, {"�����᭮����� �⪠� �� � �� �� ��㣮� ���., ������訩 �।",7,stod("20110101"),stod(""),0,"�����᭮����� �⪠� �����客���� ��栬 � ��ᯫ�⭮� �������� ����樭᪮� ����� �� ����㯫���� ���客��� ���� �� �।����� ����ਨ ��ꥪ� ���ᨩ᪮� �����樨, � ���஬ �뤠� ����� ��易⥫쭮�� ����樭᪮�� ���客����, � ��ꥬ�, ��⠭�������� ������� �ணࠬ��� ��易⥫쭮�� ����樭᪮�� ���客����, ������訩 �� ᮡ�� ��稭���� �।� ���஢��, ���� ᮧ���訩 �� �ண���஢���� ����饣��� �����������, ���� ᮧ���訩 �� ������������� ������ �����������.","1.3.2.",""})
  aadd(_f014, {"�������� ����� �� ��, �।�ᬮ�७��� ���. �ணࠬ��� ���",8,stod("20110101"),stod(""),0,"�������� ����� � �����客����� ��� (� ࠬ��� ���஢��쭮�� ����樭᪮�� ���客���� ��� � ���� �������� ������ ���) �� ��������� ����樭��� ������, �।�ᬮ�७��� ����ਠ�쭮� �ணࠬ��� ��易⥫쭮�� ����樭᪮�� ���客����.","1.4.",""})
  aadd(_f014, {"�ਮ��⥭�� ��樥�⮬ ��, � ��樮���, �� �����",9,stod("20110101"),stod(""),0,"�ਮ��⥭�� ��樥�⮬ ������⢥���� �।�� � ������� ����樭᪮�� �����祭��, � ��ਮ� �ॡ뢠��� � ��樮��� �� �����祭�� ���, ����祭��� � <���祭� �������� ����室���� � �������� ������⢥���� �।��>, <������ ��祭�� ��樮��୮�� ���쭮��>, ᮣ��ᮢ������ � �⢥ত������ � ��⠭�������� ���浪�; �� �᭮����� �⠭���⮢ ����樭᪮� �����.","1.5.",""})
  aadd(_f014, {"������⢨� ᠩ� ��",10,stod("20110101"),stod(""),0,"������⢨� ��樠�쭮�� ᠩ� ����樭᪮� �࣠����樨 � �� ���୥�.","2.1.",""})
  aadd(_f014, {"������⢨� �� ᠩ� �� ���ଠ樨 � ०��� ࠡ��� ��",11,stod("20110101"),stod(""),0,"������⢨� �� ��樠�쭮� ᠩ� ����樭᪮� �࣠����樨 � �� ���୥� ���ଠ樨 � ०��� ࠡ��� ����樭᪮� �࣠����樨.","2.2.1.",""})
  aadd(_f014, {"������⢨� �� ᠩ� �� ���ଠ樨 �� ��. �������� ��, ��⠭�������� ����",12,stod("20110101"),stod(""),0,"������⢨� �� ��樠�쭮� ᠩ� ����樭᪮� �࣠����樨 � �� ���୥� ���ଠ樨 �� �᫮���� �������� ����樭᪮� �����, ��⠭�������� ����ਠ�쭮� �ணࠬ��� ���㤠��⢥���� ��࠭⨩ �������� �ࠦ����� ���ᨩ᪮� �����樨 ��ᯫ�⭮� ����樭᪮� �����, � ⮬ �᫥ � �ப�� �������� ����樭᪮� �����.","2.2.2.",""})
  aadd(_f014, {"������⢨� �� ᠩ� �� ���ଠ樨 � ����� ����뢠���� ��",13,stod("20110101"),stod(""),0,"������⢨� �� ��樠�쭮� ᠩ� ����樭᪮� �࣠����樨 � �� ���୥� ���ଠ樨 � ����� ����뢠���� ����樭᪮� �����.","2.2.3.",""})
  aadd(_f014, {"������⢨� �� ᠩ� �� ���ଠ樨 � ������⥫�� ����㯭��� � ����⢠ ��",14,stod("20110101"),stod(""),0,"������⢨� �� ��樠�쭮� ᠩ� ����樭᪮� �࣠����樨 � �� ���୥� ���ଠ樨 � ������⥫�� ����㯭��� � ����⢠ ����樭᪮� �����.","2.2.4.",""})
  aadd(_f014, {"������⢨� �� ᠩ� �� ���ଠ樨 � �����",15,stod("20110101"),stod(""),0,"������⢨� �� ��樠�쭮� ᠩ� ����樭᪮� �࣠����樨 � �� <��୥� ���ଠ樨 � ���筥 �������� ����室���� � �������� ������⢥���� �९��⮢, �ਬ��塞�� �� �������� ��樮��୮� ����樭᪮� �����, � ⠪�� ᪮ன � ���⫮���� ����樭᪮� ����� ��ᯫ�⭮","2.2.5.",""})
  aadd(_f014, {"������⢨� �� ᠩ� �� ���ଠ樨 � �죮⭮� �뤠� ��",16,stod("20110101"),stod(""),0,"������⢨� �� ��樠�쭮� ᠩ� ����樭᪮� �࣠����樨 � �� ���୥� ���ଠ樨 � ���筥 ������⢥���� �९��⮢, ���᪠���� ��ᥫ���� � ᮮ⢥��⢨� � ���筥� ��㯯 ��ᥫ���� � ��⥣�਩ �����������, �� ���㫠�୮� ��祭�� ������ ������⢥��� �९���� � ������� ����樭᪮�� �����祭�� ���᪠���� �� �楯⠬ ��祩 ��ᯫ�⭮, � ⠪�� � ᮮ⢥��⢨� � ���筥� ��㯯 ��ᥫ����, �� ���㫠�୮� ��祭�� ������ ������⢥��� �९���� ���᪠���� �� �楯⠬ ��祩 � 50-��業⭮� ᪨���� � ᢮������ 業.","2.2.6.",""})
  aadd(_f014, {"������⢨� ����. �⥭��� � ��",17,stod("20110101"),stod(""),0,"������⢨� ���ଠ樮���� �⥭��� � ����樭᪨� �࣠�������.","2.3.",""})
  aadd(_f014, {"������⢨� � �� ���ଠ樨 � ०��� ࠡ���",18,stod("20110101"),stod(""),0,"������⢨� �� ���ଠ樮���� �⥭��� � ����樭᪨� �࣠������� ���ଠ樨 � ०��� ࠡ��� ����樭᪮� �࣠����樨.","2.4.1.",""})
  aadd(_f014, {"������⢨� � �� ���ଠ樨 �� ��. �������� ��, ��⠭�������� ����",19,stod("20110101"),stod(""),0,"������⢨� �� ���ଠ樮���� �⥭��� � ����樭᪨� �࣠������� ���ଠ樨 �� �᫮���� �������� ����樭᪮� �����, ��⠭�������� ����ਠ�쭮� �ணࠬ��� ���㤠��⢥���� ��࠭⨩ �������� �ࠦ����� ���ᨩ᪮� �����樨, � ⮬ �᫥ �ப�� �������� ����樭᪮� �����.","2.4.2.",""})
  aadd(_f014, {"������⢨� � �� ���ଠ樨 � ����� ��",20,stod("20110101"),stod(""),0,"������⢨� �� ���ଠ樮���� �⥭��� � ����樭᪨� �࣠������� ���ଠ樨 � ����� ����뢠���� ����樭᪮� ����� � ������ ����樭᪮� �࣠����樨.","2.4.3.",""})
  aadd(_f014, {"������⢨� � �� ���ଠ樨 � ������⥫�� ����㯭��� � ����⢠ ��",21,stod("20110101"),stod(""),0,"������⢨� �� ���ଠ樮���� �⥭��� � ����樭᪨� �࣠������� ���ଠ樨 � ������⥫�� ����㯭��� � ����⢠ ����樭᪮� �����.","2.4.4.",""})
  aadd(_f014, {"������⢨� � �� ���ଠ樨 � ��������-����室���� � �������� ��",22,stod("20110101"),stod(""),0,"������⢨� �� ���ଠ樮���� �⥭��� � ����樭᪨� �࣠������� ���ଠ樨 � ���筥 �������� ����室���� � �������� ������⢥���� �९��⮢, �ਬ��塞�� �� �������� ��樮��୮� ����樭᪮� �����, � ⠪�� ᪮ன � ���⫮���� ����樭᪮� ����� ��ᯫ�⭮.","2.4.5.",""})
  aadd(_f014, {"������⢨� � �� ���ଠ樨 � �죮⭮� �뤠� ��",23,stod("20110101"),stod(""),0,"������⢨� �� ���ଠ樮���� �⥭��� � ����樭᪨� �࣠������� ���ଠ樨 ���筥 ������⢥���� �९��⮢, ���᪠���� ��ᥫ���� � ᮮ⢥��⢨� � ���筥� ��㯯 ��ᥫ���� � ��⥣�਩ �����������, �� ���㫠�୮� ��祭�� ������ ������⢥��� �९���� � ������� ����樭᪮�� �����祭�� ���᪠���� �� �楯⠬ ��祩 ��ᯫ�⭮, � ⠪�� � ᮮ⢥��⢨� � ���筥� ��㯯 ��ᥫ����, �� ���㫠�୮� ��祭�� ������ ������⢥��� �९���� ���᪠���� �� �楯⠬ ��祩 � 50-��業⭮� ᪨���� � ᢮������ 業.","2.4.6.",""})
  aadd(_f014, {"����襭�� ��祡��� �⨪� � ����⮫���� ࠡ�⭨���� ��",24,stod("20110101"),stod(""),0,"��������� � ��⠭�������� ���浪� ��砨 ����襭�� ��祡��� �⨪� � ����⮫���� ࠡ�⭨���� ����樭᪮� �࣠����樨 (��⠭���������� �� ���饭�� �����客����� ���).","3.1.",""})
  aadd(_f014, {"���믮������ ����樭᪨� ���, �� ������襥 �� ���஢� ��",25,stod("20110101"),stod(""),0,"���믮������, ��᢮��६����� ��� ���������饥 �믮������ ����室���� ��樥��� ���������᪨� � (���) ��祡��� ��ய��⨩, ����⨢��� ����⥫��� � ᮮ⢥��⢨� � ���浪�� �������� ����樭᪮� ����� � (���) �⠭���⠬� ����樭᪮� �����, �� ������襥 �� ���ﭨ� ���஢�� �����客������ ���.","3.2.1.",""})
  aadd(_f014, {"���믮������ ����室���� ��, �ਢ��襥 � 㤫������ �ப�� ��祭�� (�� �᪫�祭��� �⪠�� ��)",26,stod("20110101"),stod(""),0,"���믮������, ��᢮��६����� ��� ���������饥 �믮������ ����室���� ��樥��� ���������᪨� � (���) ��祡��� ��ய��⨩, ����⨢��� ����⥫��� � ᮮ⢥��⢨� � ���浪�� �������� ����樭᪮� ����� � (���) �⠭���⠬� ����樭᪮� �����, �ਢ���� � 㤫������ �ப�� ��祭�� ᢥ�� ��⠭�������� (�� �᪫�祭��� ��砥� �⪠�� �����客������ ��� �� ����樭᪮�� ����⥫��⢠ � (���) ������⢨� ���쬥����� ᮣ���� �� ��祭��, � ��⠭�������� ��������⥫��⢮� ���ᨩ᪮� �����樨 �����).","3.2.2.",""})
  aadd(_f014, {"���믮������ ����室���� �� ��, ������襥 �।",27,stod("20110101"),stod(""),0,"���믮������, ��᢮��६����� ��� ���������饥 �믮������ ����室���� ��樥��� ���������᪨� � (���) ��祡��� ��ய��⨩, ����⨢��� ����⥫��� � ᮮ⢥��⢨� � ���浪�� �������� ����樭᪮� ����� � (���) �⠭���⠬� ����樭᪮� �����, �ਢ���� � ���襭�� ���ﭨ� ���஢�� �����客������ ���, ���� ᮧ���襥 �� �ண���஢���� ����饣��� �����������, ���� ᮧ���襥 �� ������������� ������ ����������� (�� �᪫�祭��� ��砥� �⪠�� �����客������ ���, ��ଫ������ � ��⠭�������� ���浪�).","3.2.3.",""})
  aadd(_f014, {"���믮������ ����室���� ��, �ਢ��襥 � ����������樨",28,stod("20110101"),stod(""),0,"���믮������, ��᢮��६����� ��� ���������饥 �믮������ ����室���� ��樥��� ���������᪨� � (���) ��祡��� ��ய��⨩, ����⨢��� ����⥫��� � ᮮ⢥��⢨� � ���浪�� �������� ����樭᪮� ����� � (���) �⠭���⠬� ����樭᪮� �����, �ਢ���� � ����������樨 (�� �᪫�祭��� ��砥� �⪠�� �����客������ ���, ��ଫ������ � ��⠭�������� ���浪�).","3.2.4.",""})
  aadd(_f014, {"���믮������ ����室���� ��, �ਢ��襥 � ��⠫쭮�� ��室�",29,stod("20110101"),stod(""),0,"���믮������, ��᢮��६����� ��� ���������饥 �믮������ ����室���� ��樥��� ���������᪨� � (���) ��祡��� ��ய��⨩, ����⨢��� ����⥫��� � ᮮ⢥��⢨� � ���浪�� �������� ����樭᪮� ����� � (���) �⠭���⠬� ����樭᪮� �����, �ਢ���� � ��⠫쭮�� ��室� (�� �᪫�祭��� ��砥� �⪠�� �����客������ ���, ��ଫ������ � ��⠭�������� ���浪�).","3.2.5.",""})
  aadd(_f014, {"�����᭮������ 㤫������ �ப��, 㤮஦���� �⮨���� ��祭��, �� �� ������襥 �।",30,stod("20110101"),stod(""),0,"�믮������ ������������, ����ࠢ������ � ������᪮� �窨 �७��, �� ॣ������஢����� �⠭���⠬� ����樭᪮� ����� ��ய��⨩, �ਢ���� � 㤫������ �ப�� ��祭��, 㤮஦���� �⮨���� ��祭�� �� ������⢨� ����⥫��� ��᫥��⢨� ��� ���ﭨ� ���஢�� �����客������ ���.","3.3.1.",""})
  aadd(_f014, {"�����᭮������ ��, �������� �।",31,stod("20110101"),stod(""),0,"�믮������ ������������, ����ࠢ������ � ������᪮� �窨 �७��, �� ॣ������஢����� �⠭���⠬� ����樭᪮� ����� ��ய��⨩, �ਢ���� � ���襭�� ���ﭨ� ���஢�� �����客������ ���, ���� ᮧ���襥 �� �ண���஢���� ����饣��� �����������, ���� ᮧ���襥 �� ������������� ������ ����������� (�� �᪫�祭��� ��砥� �⪠�� �����客������ ���, ��ଫ������ � ��⠭�������� ���浪�).","3.3.2.",""})
  aadd(_f014, {"�०���६����� �४�饭�� ��祡��� ��ய��⨩",32,stod("20110101"),stod(""),0,"�०���६����� � ������᪮� �窨 �७�� �४�饭�� �஢������ ��祡��� ��ய��⨩ �� ������⢨� ������᪮�� ��䥪� (�஬� ��ଫ����� � ��⠭�������� ���浪� ��砥� �⪠�� �� ��祭��).","3.4.",""})
  aadd(_f014, {"����୮� ���᭮������ ���饭�� �� �� ��",33,stod("20110101"),stod(""),0,"����୮� ���᭮������ ���饭�� �����客������ ��� �� ����樭᪮� ������� �� ������ ⮣� �� ����������� � �祭�� 30 ���� � ��� �����襭�� ���㫠�୮�� ��祭�� � 90 ���� � ��� �����襭�� ��祭�� � ��樮���, �᫥��⢨� ������⢨� ������⥫쭮� �������� � ���ﭨ� ���஢��, ���⢥ত����� �஢������� 楫���� ��� �������� ��ᯥ�⨧�� (�� �᪫�祭��� ��砥� �⠯���� ��祭��).","3.5.",""})
  aadd(_f014, {"����襭�� �॥��⢥����� � ��祭�� , �ਢ��襥 � 㢥��祭�� �ப�� ��祭�� ��� ������襥 �।",34,stod("20110101"),stod(""),0,"����襭�� �� ���� ����樭᪮� �࣠����樨 �॥��⢥����� � ��祭�� (� ⮬ �᫥ ��᢮��६���� ��ॢ�� ��樥�� � ����樭��� �࣠������ ����� ��᮪��� �஢��), �ਢ��襥 � 㤫������ �ப�� ��祭�� � (���) ���襭�� ���ﭨ� ���஢�� �����客������ ���.","3.6.",""})
  aadd(_f014, {"�����᭮������ ��ᯨ⠫����� ��",35,stod("20110101"),stod(""),0,"��ᯨ⠫����� �����客������ ��� ��� ����樭᪨� ��������� (�����᭮������ ��ᯨ⠫�����), ����樭᪠� ������ ���஬� ����� ���� �।��⠢���� � ��⠭�������� ��ꥬ� � ���㫠�୮-����������᪨� �᫮����, � �᫮���� �������� ��樮���.","3.7.",""})
  aadd(_f014, {"����䨫쭠� ��ᯨ⠫����� ��",36,stod("20110101"),stod(""),0,"��ᯨ⠫����� �����客������ ���, ����樭᪠� ������ ���஬� ������ ���� ������� � ��樮��� ��㣮�� ��䨫� (����䨫쭠� ��ᯨ⠫�����), �஬� ��砥� ��ᯨ⠫���樨 �� ���⫮��� ���������.","3.8.",""})
  aadd(_f014, {"�����᭮������ 㤫������ �ப�� ��祭�� � 㢥��祭�� ������⢠ ����樭᪨� ��� �� ���� ��",37,stod("20110101"),stod(""),0,"�����᭮������ 㤫������ �ப�� ��祭�� �� ���� ����樭᪮� �࣠����樨, � ⠪�� 㢥��祭�� ������⢠ ����樭᪨� ���, ���饭��, �����-����, �� �易���� � �஢������� ���������᪨�, ��祡��� ��ய��⨩, ����⨢��� ����⥫��� � ࠬ��� �⠭���⮢ ����樭᪮� �����.","3.9.",""})
  aadd(_f014, {"����୮� ���饭�� ��� ����� � ⮩ �� ᯥ樠�쭮�� � ���� ���� �� ���㫠�୮� ��",38,stod("20110101"),stod(""),0,"����୮� ���饭�� ��� ����� � ⮩ �� ᯥ樠�쭮�� � ���� ���� �� �������� ���㫠�୮� ����樭᪮� �����, �� �᪫�祭��� ����୮�� ���饭�� ��� ��।������ ��������� � ��ᯨ⠫���樨, ����樨, ��������� � ��㣨� ����樭᪨� �࣠�������.","3.10.",""})
  aadd(_f014, {"����⢨� ��� �������⢨� ���. ���ᮭ���, ���᫮���襥 ࠧ��⨥ ������ �����������",39,stod("20110101"),stod(""),0,"����⢨� ��� �������⢨� ����樭᪮�� ���ᮭ���, ���᫮���襥 ࠧ��⨥ ������ ����������� �����客������ ��� (ࠧ��⨥ ��ண������ �����������).","3.11.",""})
  aadd(_f014, {"�����᭮������ ��� ����୮� �����祭�� ��",40,stod("20110101"),stod(""),0,"�����᭮������ �����祭�� ������⢥���� �࠯��; �����६����� �����祭�� ������⢥���� �।�� - ᨭ������, �������� ��� ��⠣����⮢ �� �ଠ�������᪮�� ����⢨� � �.�., �易���� � �᪮� ��� ���஢�� ��樥�� �/��� �ਢ���饥 � 㤮஦���� ��祭��.","3.12.",""})
  aadd(_f014, {"���믮������ �� ���� �� ��易⥫쭮�� ��⮫������⮬��᪮�� ������",41,stod("20110101"),stod(""),0,"���믮������ �� ���� ����樭᪮� �࣠����樨 ��易⥫쭮�� ��⮫������⮬��᪮�� ������ � ᮮ⢥��⢨� � �������騬 ��������⥫��⢮�.","3.13.",""})
  aadd(_f014, {"����稥 ��宦����� ������᪮�� � ��⮫������⮬��᪮�� ��������� 2-3 ��⥣�ਨ",42,stod("20110101"),stod(""),0,"����稥 ��宦����� ������᪮�� � ��⮫������⮬��᪮�� ��������� 2-3 ��⥣�ਨ.","3.14.",""})
  aadd(_f014, {"���।�⠢����� ���. ���㬥�⮢ �� �������� ��",43,stod("20110101"),stod(""),0,"���।�⠢����� ��ࢨ筮� ����樭᪮� ���㬥��樨, ���⢥ত��饩 䠪� �������� �����客������ ���� ����樭᪮� ����� � ����樭᪮� �࣠����樨 ��� ��ꥪ⨢��� ��稭.","4.1.",""})
  aadd(_f014, {"��䥪�� ��ଫ���� ��ࢨ筮� ����樭᪮� ���㬥��樨",44,stod("20110101"),stod(""),0,"��䥪�� ��ଫ���� ��ࢨ筮� ����樭᪮� ���㬥��樨, �९������騥 �஢������ ��ᯥ�⨧� ����⢠ ����樭᪮� ����� (������������� �業��� �������� ���ﭨ� ���஢�� �����客������ ���, ��ꥬ, �ࠪ�� � �᫮��� �।��⠢����� ����樭᪮� �����).","4.2.",""})
  aadd(_f014, {"������⢨� � ��ࢨ筮� ���㬥��樨 ᮣ���� �� �� ��",45,stod("20110101"),stod(""),0,"������⢨� � ��ࢨ筮� ���㬥��樨: ���ନ஢������ ���஢��쭮�� ᮣ���� �����客������ ��� �� ����樭᪮� ����⥫��⢮ ��� �⪠�� �����客������ ��� �� ����樭᪮�� ����⥫��⢠ � (���) ���쬥����� ᮣ���� �� ��祭��, � ��⠭�������� ��������⥫��⢮� ���ᨩ᪮� �����樨 �����.","4.3.",""})
  aadd(_f014, {"����稥 �ਧ����� 䠫��䨪�樨 ����樭᪮� ���㬥��樨",46,stod("20110101"),stod(""),0,"����稥 �ਧ����� 䠫��䨪�樨 ����樭᪮� ���㬥��樨 (����᪨, ��ࠢ�����, <�������>, ������ ��८�ଫ���� ���ਨ �������, � ��諥��� �᪠������ ᢥ����� � �஢������� ���������᪨� � ��祡��� ��ய�����, ������᪮� ���⨭� �����������).","4.4.",""})
  aadd(_f014, {"�� ᮢ������� ���� �� � ��ࢨ筮� ���-�� � ���� ⠡��� ࠡ. �६���",47,stod("20110101"),stod(""),0,"��� �������� ����樭᪮� �����, ��ॣ����஢����� � ��ࢨ筮� ����樭᪮� ���㬥��樨 � ॥��� ��⮢, �� ᮮ⢥����� ⠡��� ��� ࠡ�祣� �६��� ��� (�������� ����樭᪮� ����� � ��ਮ� ���᪠, �祡�, �������஢��, ��室��� ���� � �.�.).","4.5.",""})
  aadd(_f014, {"��ᮮ⢥��⢨� ������ ��ࢨ筮� ���. ���㬥��樨 ����� ॥��� ��⮢",48,stod("20110101"),stod(""),0,"��ᮮ⢥��⢨� ������ ��ࢨ筮� ����樭᪮� ���㬥��樨 ����� ॥��� ��⮢: ����祭�� � ��� �� ������ ����樭᪮� ����� � ॥��� ��⮢ ���饭��, �����-���� � ��., �� ���⢥ত����� ��ࢨ筮� ����樭᪮� ���㬥��樥�.","4.6.1.",""})
  aadd(_f014, {"��ᮮ⢥��⢨� ������ ��ࢨ筮� ���. ���㬥��樨 � ॥��� ��⮢ �� �ப�� ��祭��",49,stod("20110101"),stod(""),0,"��ᮮ⢥��⢨� ������ ��ࢨ筮� ����樭᪮� ���㬥��樨 ����� ॥��� ��⮢: ��ᮮ⢥��⢨� �ப�� ��祭��, ᮣ��᭮ ��ࢨ筮� ����樭᪮� ���㬥��樨, �����客������ ��� �ப��, 㪠����� � ॥��� ���.","4.6.2.",""})
  aadd(_f014, {"�訡�� � ४������ �� ��ଫ���� � �।����� ��⮢",50,stod("20110101"),stod(""),0,"����襭��, �易��� � ��ଫ����� � �।������ �� ������ ��⮢ � ॥��஢ ��⮢: ����稥 �訡�� �/��� �����⮢�୮� ���ଠ樨 � ४������ ���.","5.1.1.",""})
  aadd(_f014, {"��ᮮ⢥��⢨� �㬬� � ��� �� ������ � � �⮣���� �㬬� �� ॥���� ��⮢",51,stod("20110101"),stod(""),0,"����襭��, �易��� � ��ଫ����� � �।������ �� ������ ��⮢ � ॥��஢ ��⮢: �㬬� ��� �� ᮮ⢥����� �⮣���� �㬬� �।��⠢������ ����樭᪮� ����� �� ॥���� ��⮢.","5.1.2.",""})
  aadd(_f014, {"�������� ���������� ����� ॥��� ��⮢",52,stod("20110101"),stod(""),0,"����襭��, �易��� � ��ଫ����� � �।������ �� ������ ��⮢ � ॥��஢ ��⮢: ����稥 ������������� ����� ॥��� ��⮢, ��易⥫��� � ����������.","5.1.3.",""})
  aadd(_f014, {"�����४⭮� ���������� ����� ॥��� ��⮢",53,stod("20110101"),stod(""),0,"����襭��, �易��� � ��ଫ����� � �।������ �� ������ ��⮢ � ॥��஢ ��⮢: �����४⭮� ���������� ����� ॥��� ��⮢.","5.1.4.",""})
  aadd(_f014, {"������� �㬬� �� ����樨 ॥��� ��⮢ �� ���४⭠",54,stod("20110101"),stod(""),0,"����襭��, �易��� � ��ଫ����� � �।������ �� ������ ��⮢ � ॥��஢ ��⮢: ������� �㬬� �� ����樨 ॥��� ��⮢ �� ���४⭠ (ᮤ�ন� ��䬥����� �訡��).","5.1.5.",""})
  aadd(_f014, {"��� �������� �� � ॥��� ��⮢ �� ᮮ⢥����� ���⭮�� ��ਮ��/��ਮ�� ������",55,stod("20110101"),stod(""),0,"����襭��, �易��� � ��ଫ����� � �।������ �� ������ ��⮢ � ॥��஢ ��⮢: ��� �������� ����樭᪮� ����� � ॥��� ��⮢ �� ᮮ⢥����� ���⭮�� ��ਮ��/��ਮ�� ������.","5.1.6.",""})
  aadd(_f014, {"�������� �� ����, �����客������ ��㣮� ���",56,stod("20110101"),stod(""),0,"����襭��, �易��� � ��।������� �ਭ��������� �����客������ ��� � ���客�� ����樭᪮� �࣠����樨: ����祭�� � ॥��� ��⮢ ��砥� �������� ����樭᪮� ����� ����, �����客������ ��㣮� ���客�� ����樭᪮� �࣠����樥�.","5.2.1.",""})
  aadd(_f014, {"�訡�� � ���ᮭ����� ������ ��, �ਢ���騥 � ������������ ��� �����䨪�樨",57,stod("20110101"),stod(""),0,"����襭��, �易��� � ��।������� �ਭ��������� �����客������ ��� � ���客�� ����樭᪮� �࣠����樨: �������� � ॥��� ��⮢ �����⮢���� ���ᮭ����� ������ �����客������ ���, �ਢ���饥 � ������������ ��� ������ �����䨪�樨 (�訡�� � �ਨ � ����� ����� ���, ���� � �.�.).","5.2.2.",""})
  aadd(_f014, {"�������� �� ��, ����稢襬� ����� ��� �� ����ਨ ��㣮�� ��ꥪ� ��",58,stod("20110101"),stod(""),0,"����襭��, �易��� � ��।������� �ਭ��������� �����客������ ��� � ���客�� ����樭᪮� �࣠����樨: ����祭�� � ॥��� ��⮢ ��砥� �������� ����樭᪮� ����� �����客������ ����, ����稢襣� ����� ��� �� ����ਨ ��㣮�� ��ꥪ� ��.","5.2.3.",""})
  aadd(_f014, {"����稥 � ॥��� ��� �����㠫��� ������ � ��",59,stod("20110101"),stod(""),0,"����襭��, �易��� � ��।������� �ਭ��������� �����客������ ��� � ���客�� ����樭᪮� �࣠����樨: ����稥 � ॥��� ��� �����㠫��� ������ � �����客����� ����.","5.2.4.",""})
  aadd(_f014, {"�।��⠢����� �� �ࠦ�����, �� �������騬 ���客���� �� ��� �� ����ਨ ��",60,stod("20110101"),stod(""),0,"����襭��, �易��� � ��।������� �ਭ��������� �����客������ ��� � ���客�� ����樭᪮� �࣠����樨: ����祭�� � ॥���� ��⮢ ��砥� �������� ����樭᪮� �����, �।��⠢������ ��⥣��� �ࠦ���, �� �������騬 ���客���� �� ��� �� ����ਨ ��.","5.2.5.",""})
  aadd(_f014, {"����祭�� � ॥��� ��⮢ ����� ��, �� �室��� � ���. �ணࠬ�� ���",61,stod("20110101"),stod(""),0,"����祭�� � ॥��� ��⮢ ����� ����樭᪮� �����, �� �室��� � ����ਠ���� �ணࠬ�� ���.","5.3.1.",""})
  aadd(_f014, {"����祭�� � ॥��� �� ᢥ�� ���. �ணࠬ�� ���",62,stod("20110101"),stod(""),0,"�।����� � ����� ��砥� �������� ����樭᪮� ����� ᢥ�� ��।�������� ��ꥬ� �।��⠢����� ����樭᪮� �����, ��⠭��������� �襭��� �����ᨨ �� ࠧࠡ�⪥ ����ਠ�쭮� �ணࠬ��.","5.3.2.",""})
  aadd(_f014, {"����祭�� � ॥��� ��⮢ ��砥�, �� �室��� � ���. �ணࠬ�� ���",63,stod("20110101"),stod(""),0,"����祭�� � ॥��� ��⮢ ��砥� �������� ����樭᪮� �����, ��������� ����� �� ��㣨� ���筨��� 䨭���஢���� (�殮�� ������� ��砨 �� �ந�����⢥, ����稢���� ������ �樠�쭮�� ���客����).","5.3.3.",""})
  aadd(_f014, {"������⢨� ���",64,stod("20110101"),stod(""),0,"����祭�� � ॥��� ��⮢ ��砥� �������� ����樭᪮� ����� �� ��䠬 �� ������ ����樭᪮� �����, ���������騬 � ��䭮� ᮣ��襭��.","5.4.1.",""})
  aadd(_f014, {"��ᮮ⢥��⢨� ���",65,stod("20110101"),stod(""),0,"����祭�� � ॥��� ��⮢ ��砥� �������� ����樭᪮� ����� �� ��䠬 �� ������ ����樭᪮� �����, �� ᮮ⢥�����騬 �⢥ত���� � ��䭮� ᮣ��襭��.","5.4.2.",""})
  aadd(_f014, {"����業��஢����� ��(������⢨� ��業���)",66,stod("20110101"),stod(""),0,"����祭�� � ॥��� ��⮢ ��砥� �������� ����樭᪮� ����� �� ����� ����樭᪮� ���⥫쭮��, ���������騬 � �������饩 ��業��� ����樭᪮� �࣠����樨.","5.5.1.",""})
  aadd(_f014, {"����業��஢����� ��(����砭�� ��業���)",67,stod("20110101"),stod(""),0,"�।��⠢����� ॥��஢ ��⮢ � ��砥 �४�饭�� � ��⠭�������� ���浪� ����⢨� ��業��� ����樭᪮� �࣠����樨.","5.5.2.",""})
  aadd(_f014, {"����業��஢����� ��(����襭�� �᫮���)",68,stod("20110101"),stod(""),0,"�।��⠢����� �� ������ ॥��஢ ��⮢, � ��砥 ����襭�� ��業������� �᫮��� � �ॡ������ �� �������� ����樭᪮� �����: ����� ��業��� �� ᮮ⢥������ 䠪��᪨� ���ᠬ �����⢫���� ����樭᪮� �࣠����樥� ��業���㥬��� ���� ���⥫쭮�� � ��. (�� 䠪�� ������, � ⠪�� �� �᭮����� ���ଠ樨 ��業������� �࣠���).","5.5.3.",""})
  aadd(_f014, {"����䨫쭮� �������� ��",69,stod("20110101"),stod(""),0,"����祭�� � ॥��� ��⮢ ��砥� �������� ����樭᪮� ����� ᯥ樠���⮬, �� ����騬 ���䨪�� ��� ᢨ��⥫��⢠ �� ���।��樨 �� ��䨫� �������� ����樭᪮� �����.","5.6.",""})
  aadd(_f014, {"����୮� ���⠢����� ��� �� 㦥 ����祭��� ��",70,stod("20110101"),stod(""),0,"����襭��, �易��� � ������ ��� �����᭮����� ����祭��� � ॥��� ��⮢ ����樭᪮� �����: ������ ॥��� ��⮢ ����祭� ࠭�� (����୮� ���⠢����� ��� �� ������ ��砥� �������� ����樭᪮� �����, ����� �뫨 ����祭� ࠭��).","5.7.1.",""})
  aadd(_f014, {"�㡫�஢���� ��砥� �������� �� � ����� ॥���",71,stod("20110101"),stod(""),0,"����襭��, �易��� � ������ ��� �����᭮����� ����祭��� � ॥��� ��⮢ ����樭᪮� �����: �㡫�஢���� ��砥� �������� ����樭᪮� ����� � ����� ॥���.","5.7.2.",""})
  aadd(_f014, {"����୮� ����祭�� ��㣨, ��⥭��� � ��㣮� ��㣥",72,stod("20110101"),stod(""),0,"����襭��, �易��� � ������ ��� �����᭮����� ����祭��� � ॥��� ��⮢ ����樭᪮� �����: �⮨����� �⤥�쭮� ��㣨, ����祭��� � ���, ��⥭� � ��� �� ������ ����樭᪮� ����� ��㣮� ��㣨, ⠪�� �।������ � ����� ����樭᪮� �࣠����樥�.","5.7.3.",""})
  aadd(_f014, {"����୮� ����祭�� ��㣨, ��⥭��� � ��ଠ⨢� 䨭���஢����",73,stod("20110101"),stod(""),0,"����襭��, �易��� � ������ ��� �����᭮����� ����祭��� � ॥��� ��⮢ ����樭᪮� �����: �⮨����� ��㣨 ����祭� � ��ଠ⨢ 䨭���஢���� ���ᯥ祭�� ������ ���㫠�୮� ����樭᪮� ����� �� �ਪ९������ ��ᥫ����, �����客����� � ��⥬� ���.","5.7.4.",""})
  aadd(_f014, {"����祭�� �ப�� ��祭��",74,stod("20110101"),stod(""),0,"����襭��, �易��� � ������ ��� �����᭮����� ����祭��� � ॥��� ��⮢ ����樭᪮� �����: ����祭�� � ॥��� ��⮢ ����樭᪮� �����: - ���㫠���� ���饭�� � ��ਮ� �ॡ뢠��� �����客������ ��� � ��㣫����筮� ��樮��� (�஬� ��� ����㯫���� � �믨᪨ �� ��樮���, � ⠪�� �������権 � ��㣨� ����樭᪨� �࣠������� � ࠬ��� �⠭���⮢ ����樭᪮� �����); - ��樥�� - ���� �ॡ뢠��� �����客������ ��� � ������� ��樮��� � ��ਮ� �ॡ뢠��� ��樥�� � ��㣫����筮� ��樮��� (�஬� ��� ����㯫���� � �믨᪨ �� ��樮���, � ⠪�� �������権 � ��㣨� ����樭᪨� �࣠�������).","5.7.5.",""})
  aadd(_f014, {"����୮� ����祭�� � ���� ��ਮ� ��᪮�쪨� ��樮����� �ॡ뢠���",75,stod("20110101"),stod(""),0,"����襭��, �易��� � ������ ��� �����᭮����� ����祭��� � ॥��� ��⮢ ����樭᪮� �����: ����祭�� � ॥��� ��⮢ ��᪮�쪨� ��砥� �������� ��樮��୮� ����樭᪮� ����� �����客������ ���� � ���� ��ਮ� ������ � ����祭��� ��� ᮢ�������� �ப�� ��祭��.","5.7.6.",""})
  aadd(_f014, {"�����祭�� �ப�� �������� ᪮ன �� (�� 50 �� 100 % �� ��ଠ⨢�), �� �������� �।�",76,stod("20130101"),stod(""),0,"�����祭�� �ப�� �������� ᪮ன ����樭᪮� �����: �� 50 �� 100 ��業⮢ �� ��ଠ⨢�, ��⠭��������� ����ਠ�쭮� �ணࠬ��� ���㤠��⢥���� ��࠭⨩ �� ������訩 �� ᮡ�� ��稭���� �।� ���஢��, �� ᮧ���訩 �᪠ �ண���஢���� ����饣��� �����������, �� ᮧ���訩 �᪠ ������������� ������ �����������.","6.1.",""})
  aadd(_f014, {"�����祭�� �ப�� �������� ᪮ன �� (�� 50 �� 100 % �� ��ଠ⨢�), �������� �।",77,stod("20130101"),stod(""),0,"�����祭�� �ப�� �������� ᪮ன ����樭᪮� �����: �� 50 �� 100 ��業⮢ �� ��ଠ⨢�, ��⠭��������� ����ਠ�쭮� �ணࠬ��� ���㤠��⢥���� ��࠭⨩ ������訩 �� ᮡ�� ��稭���� �।� ���஢��, ���� ᮧ���訩 �� �ண���஢���� ����饣��� �����������, ���� ᮧ���訩 �� ������������� ������ �����������.","6.1.1.",""})
  aadd(_f014, {"�����祭�� �ப�� �������� ᪮ன �� (����� 100 %), �� �������� �।�",78,stod("20130101"),stod(""),0,"�����祭�� �ப�� �������� ᪮ன ����樭᪮� �����: ����� 100 ��業⮢ �� ��ଠ⨢�, ��⠭��������� ����ਠ�쭮� �ணࠬ��� ���㤠��⢥���� ��࠭⨩ �� ������訩 �� ᮡ�� ��稭���� �।� ���஢��, �� ᮧ���訩 �᪠ �ண���஢���� ����饣��� �����������, �� ᮧ���訩 �᪠ ������������� ������ �����������.","6.1.2.",""})
  aadd(_f014, {"�����祭�� �ப�� �������� ᪮ன �� (����� 100 % �� ��ଠ⨢�), �������� �।",79,stod("20130101"),stod(""),0,"�����祭�� �ப�� �������� ᪮ன ����樭᪮� �����: ����� 100 ��業⮢ �� ��ଠ⨢�, ��⠭��������� ����ਠ�쭮� �ணࠬ��� ���㤠��⢥���� ��࠭⨩ ������訩 �� ᮡ�� ��稭���� �।� ���஢��, ���� ᮧ���訩 �� �ண���஢���� ����饣��� �����������, ���� ᮧ���訩 �� ������������� ������ �����������.","6.1.2.1.",""})
  aadd(_f014, {"�����᭮����� �⪠� �� � ᪮ன ��, �� ������訩 �।�",80,stod("20130101"),stod(""),0,"�����᭮����� �⪠� �����客���� ��栬 � �������� ᪮ன ����樭᪮� ����� � ᮮ⢥��⢨� � ����ਠ�쭮� �ணࠬ��� ��� (��⠭���������� �� ���饭�� �����客����� ��� ��� �� �।�⠢�⥫��), � ⮬ �᫥: �� ������訩 �� ᮡ�� ��稭���� �।� ���஢��, �� ᮧ���訩 �᪠ �ண���஢���� ����饣��� �����������, �� ᮧ���訩 �᪠ ������������� ������ �����������.","6.2.",""})
  aadd(_f014, {"�����᭮����� �⪠� �� � ᪮ன ��, �ਢ��訩 � ��⠫쭮�� ��室�",81,stod("20130101"),stod(""),0,"�����᭮����� �⪠� �����客���� ��栬 � �������� ᪮ன ����樭᪮� ����� � ᮮ⢥��⢨� � ����ਠ�쭮� �ணࠬ��� ��� (��⠭���������� �� ���饭�� �����客����� ��� ��� �� �।�⠢�⥫��), � ⮬ �᫥: ������訩 �� ᮡ�� ��稭���� �।� ���஢��, � ⮬ �᫥ �ਢ��訩 � ����������樨, ���� ᮧ���訩 �� �ண���஢���� ����饣��� �����������, ���� ᮧ���訩 �� ������������� ������ ����������� (�� �᪫�祭��� ��砥� �⪠�� �����客������ ���, ��ଫ������ � ��⠭�������� ���浪�).","6.2.1.",""})
  aadd(_f014, {"�����᭮����� �⪠� �� � ᪮ன ��, �� ������訩 �।�",82,stod("20130101"),stod(""),0,"�����᭮����� �⪠� �����客���� ��栬 � �������� ᪮ன ����樭᪮� ����� � ᮮ⢥��⢨� � ����ਠ�쭮� �ணࠬ��� ��� (��⠭���������� �� ���饭�� �����客����� ��� ��� �� �।�⠢�⥫��), � ⮬ �᫥: �ਢ��訩 � ��⠫쭮�� ��室� (�� �᪫�祭��� ��砥� �⪠�� �����客������ ���, ��ଫ������ � ��⠭�������� ���浪�).","6.2.3.",""})
  aadd(_f014, {"�����᭮����� �⪠� �� � ᪮ன �� �� ��㣮� ���., �� ������訩 �।�",83,stod("20130101"),stod(""),0,"�����᭮����� �⪠� �����客���� ��栬 � �������� ᪮ன ����樭᪮� ����� �� ����㯫���� ���客��� ���� �� �।����� ����ਨ ��ꥪ� ���ᨩ᪮� �����樨, � ���஬ �뤠� ����� ��易⥫쭮�� ����樭᪮�� ���客����, � ��ꥬ�, ��⠭�������� ������� �ணࠬ��� ��易⥫쭮�� ����樭᪮�� ���客����, � ⮬ �᫥: �� ������訩 �� ᮡ�� ��稭���� �।� ���஢��, �� ᮧ���訩 �᪠ �ண���஢���� ����饣��� �����������, �� ᮧ���訩 �᪠ ������������� ������ �����������.","6.3.",""})
  aadd(_f014, {"�����᭮����� �⪠� �� � ᪮ன �� �� ��㣮� ���., ������訩 �।",84,stod("20130101"),stod(""),0,"�����᭮����� �⪠� �����客���� ��栬 � �������� ᪮ன ����樭᪮� ����� �� ����㯫���� ���客��� ���� �� �।����� ����ਨ ��ꥪ� ���ᨩ᪮� �����樨, � ���஬ �뤠� ����� ��易⥫쭮�� ����樭᪮�� ���客����, � ��ꥬ�, ��⠭�������� ������� �ணࠬ��� ��易⥫쭮�� ����樭᪮�� ���客����, � ⮬ �᫥: ������訩 �� ᮡ�� ��稭���� �।� ���஢��, ���� ᮧ���訩 �� �ண���஢���� ����饣��� �����������, ���� ᮧ���訩 �� ������������� ������ �����������.","6.3.1.",""})
  aadd(_f014, {"�����᭮����� �⪠� �� � ᪮ன �� �� ��㣮� ���., �ਢ��襥 � ��⠫쭮�� ��室�",85,stod("20130101"),stod(""),0,"�����᭮����� �⪠� �����客���� ��栬 � �������� ᪮ன ����樭᪮� ����� �� ����㯫���� ���客��� ���� �� �।����� ����ਨ ��ꥪ� ���ᨩ᪮� �����樨, � ���஬ �뤠� ����� ��易⥫쭮�� ����樭᪮�� ���客����, � ��ꥬ�, ��⠭�������� ������� �ணࠬ��� ��易⥫쭮�� ����樭᪮�� ���客����, � ⮬ �᫥: �ਢ��訥 � ��⠫쭮�� ��室� (�� �᪫�祭��� ��砥� �⪠�� �����客������ ���, ��ଫ������ � ��⠭�������� ���浪�).","6.3.2.",""})
  aadd(_f014, {"�������� ����� � �� �� ��������� ᪮��� ��, �।�ᬮ�७��� ���. �ணࠬ��� ���",86,stod("20130101"),stod(""),0,"�������� ����� � �����客����� ��� �� ��������� ᪮��� ����樭��� ������: �।�ᬮ�७��� ����ਠ�쭮� �ணࠬ��� ��易⥫쭮�� ����樭᪮�� ���客����.","6.4.",""})
  aadd(_f014, {"�������� ����� � �� �� ��������� ᪮��� �� �� ��㣮� ���, �।�ᬮ�७��� ������� �ணࠬ��� ���",87,stod("20130101"),stod(""),0,"�������� ����� � �����客����� ��� �� ��������� ᪮��� ����樭��� ������: �� ����㯫���� ���客��� ���� �� �।����� ����ਨ ��ꥪ� ���ᨩ᪮� �����樨, � ���஬ �뤠� ����� ��易⥫쭮�� ����樭᪮�� ���客����, � ��ꥬ�, ��⠭�������� ������� �ணࠬ��� ��易⥫쭮�� ����樭᪮�� ���客����","6.4.1.",""})
  aadd(_f014, {"������⢨� �� ᠩ� �� ���ଠ樨 �� �᫮���� �������� ᪮ன ��, ��⠭�������� ����",88,stod("20130101"),stod(""),0,"������⢨� �� ��樠�쭮� ᠩ� ����樭᪮� �࣠����樨 � �� <���୥�> ᫥���饩 ���ଠ樨: �� �᫮���� �������� ᪮ன ����樭᪮� �����, ��⠭�������� ����ਠ�쭮� �ணࠬ��� ���㤠��⢥���� ��࠭⨩ �������� �ࠦ����� ���ᨩ᪮� �����樨 ��ᯫ�⭮� ����樭᪮� �����, � ⮬ �᫥ � �ப�� �������� ᪮ன ����樭᪮� �����.","6.5.",""})
  aadd(_f014, {"������⢨� �� ᠩ� �� ���ଠ樨 � ������⥫�� ����㯭��� � ����⢠ ᪮ன ��",89,stod("20130101"),stod(""),0,"������⢨� �� ��樠�쭮� ᠩ� ����樭᪮� �࣠����樨 � �� <���୥�> ᫥���饩 ���ଠ樨: � ������⥫�� ����㯭��� � ����⢠ ᪮ன ����樭᪮� �����.","6.5.1.",""})
  aadd(_f014, {"����襭�� ��祡��� �⨪� � ����⮫���� ࠡ�⭨���� ��",90,stod("20130101"),stod(""),0,"��������� � ��⠭�������� ���浪�: ����襭�� ��祡��� �⨪� � ����⮫���� ࠡ�⭨���� ����樭᪮� �࣠����樨 (��⠭���������� �� ���饭�� �����客����� ���).","6.6.",""})
  aadd(_f014, {"������襭�� ᢥ�����, ��⠢����� ��祡��� ⠩��",91,stod("20130101"),stod(""),0,"��������� � ��⠭�������� ���浪�: ࠧ���襭�� ᢥ�����, ��⠢����� ��祡��� ⠩��, � ⮬ �᫥ ��᫥ ᬥ�� 祫�����, ��栬�, ����� ��� �⠫� ������� �� ���祭��, �ᯮ������ ��㤮���, ����������, �㦥���� � ���� ��易����⥩, ��⠭�������� �� ���饭�� �����客������ ��� ��⥬ �஢������ ���������⨢���� ��᫥������� ���������樥� ����樭᪮� �࣠����樨 ��� ���, �ਭ���� �����⥭�묨 �࣠����.","6.6.1.",""})
  aadd(_f014, {"��ᮡ���� ��祡��� ⠩��",92,stod("20130101"),stod(""),0,"��������� � ��⠭�������� ���浪�: ��ᮡ���� ��祡��� ⠩��, � ⮬ �᫥ ���䨤��樠�쭮�� ���ᮭ����� ������, �ᯮ��㥬�� � ����樭᪨� ���ଠ樮���� ��⥬��, ��⠭�������� �����⥭�묨 �࣠���� �� ���饭�� �����客������ ���.","6.6.2.",""})
  aadd(_f014, {"���믮������ ����樭᪨� ���, �� ������襥 �� ���஢� ��",93,stod("20130101"),stod(""),0,"���믮������, ��᢮��६����� ��� ���������饥 �믮������ ����室���� ��樥��� ���������᪨� � (���) ��祡��� ��ய��⨩ � ᮮ⢥��⢨� � ���浪�� �������� ����樭᪮� ����� � (���) �⠭���⠬� ����樭᪮� �����: �� ������襥 �� ���ﭨ� ���஢�� �����客������ ���.","6.7.",""})
  aadd(_f014, {"���믮������ ����室���� ��, �ਢ���� ���襭�� ���ﭨ� ���஢�� �� (�� �᪫�祭��� �⪠�� ��)",94,stod("20130101"),stod(""),0,"���믮������, ��᢮��६����� ��� ���������饥 �믮������ ����室���� ��樥��� ���������᪨� � (���) ��祡��� ��ய��⨩ � ᮮ⢥��⢨� � ���浪�� �������� ����樭᪮� ����� � (���) �⠭���⠬� ����樭᪮� �����: �ਢ���� � ���襭�� ���ﭨ� ���஢�� �����客������ ���, ���� ᮧ���襥 �� �ண���஢���� ����饣��� �����������, ���� ᮧ���襥 �� ������������� ������ ����������� (�� �᪫�祭��� ��砥� �⪠�� �����客������ ��� �� ��祭��, ��ଫ������ � ��⠭�������� ���浪�).","6.7.1.",""})
  aadd(_f014, {"���믮������ ����室���� ��, �ਢ��襥 � ��⠫쭮�� ��室�",95,stod("20130101"),stod(""),0,"���믮������, ��᢮��६����� ��� ���������饥 �믮������ ����室���� ��樥��� ���������᪨� � (���) ��祡��� ��ய��⨩ � ᮮ⢥��⢨� � ���浪�� �������� ����樭᪮� ����� � (���) �⠭���⠬� ����樭᪮� �����: �ਢ���� � ��⠫쭮�� ��室� (�� �᪫�祭��� ��砥� �⪠�� �����客������ ��� �� ��祭��, ��ଫ������ � ��⠭�������� ���浪�).","6.7.2.",""})
  aadd(_f014, {"�����᭮������ 㤮஦���� �⮨���� ��祭��, �� �� �������� �।�",96,stod("20130101"),stod(""),0,"�믮������ ������������, ����ࠢ������ � ������᪮� �窨 �७��, �� ॣ������஢����� �⠭���⠬� ����樭᪮� ����� ��ய��⨩: �ਢ���� � 㤮஦���� �⮨���� ��祭�� �� ������⢨� ����⥫��� ��᫥��⢨� ��� ���ﭨ� ���஢�� �����客������ ���.","6.8.",""})
  aadd(_f014, {"�����᭮������ ��, �������� �।",97,stod("20130101"),stod(""),0,"�믮������ ������������, ����ࠢ������ � ������᪮� �窨 �७��, �� ॣ������஢����� �⠭���⠬� ����樭᪮� ����� ��ய��⨩ �ਢ���� � ���襭�� ���ﭨ� ���஢�� �����客������ ���, ���� ᮧ���襥 �� �ண���஢���� ����饣��� �����������, ���� ᮧ���襥 �� ������������� ������ ����������� (�� �᪫�祭��� ��砥� �⪠�� �����客������ ��� �� ��祭��, ��ଫ������ � ��⠭�������� ���浪�).","6.8.1.",""})
  aadd(_f014, {"�����᭮������ ��, �ਢ���� � ��⠫쭮�� ��室�",98,stod("20130101"),stod(""),0,"�믮������ ������������, ����ࠢ������ � ������᪮� �窨 �७��, �� ॣ������஢����� �⠭���⠬� ����樭᪮� ����� ��ய��⨩ �ਢ���� � ��⠫쭮�� ��室� (�� �᪫�祭��� ��砥� �⪠�� �����客������ ��� �� ��祭��, ��ଫ������ � ��⠭�������� ���浪�).","6.8.2.",""})
  aadd(_f014, {"�०���६����� �४�饭�� ��祡��� ��ய��⨩, �� �� ������襥 �।",99,stod("20130101"),stod(""),0,"�०���६����� � ������᪮� �窨 �७�� �४�饭�� �஢������ ��祡��� ��ய��⨩ �� ������⢨� ������᪮�� ��䥪� (�஬� ��ଫ����� � ��⠭�������� ���浪� ��砥� �⪠�� �� ��祭��), �� ������襥 �� ���ﭨ� ���஢�� �����客������ ���","6.9.",""})
  aadd(_f014, {"�����᭮������ ��, �������� �। (�� �᪫�祭��� �⪠�� ��)",100,stod("20130101"),stod(""),0,"�०���६����� � ������᪮� �窨 �७�� �४�饭�� �஢������ ��祡��� ��ய��⨩ �� ������⢨� ������᪮�� ��䥪� (�஬� ��ଫ����� � ��⠭�������� ���浪� ��砥� �⪠�� �� ��祭��), �ਢ��襥 � ���襭�� ���ﭨ� ���஢�� �����客������ ���, ���� ᮧ���襥 �� �ண���஢���� ����饣��� �����������, ���� ᮧ���襥 �� ������������� ������ ����������� (�� �᪫�祭��� ��砥� �⪠�� �����客������ ��� �� ��祭��, ��ଫ������ � ��⠭�������� ���浪�)","6.9.1.",""})
  aadd(_f014, {"�����᭮������ ��, �ਢ���� � ��⠫쭮�� ��室� (�� �᪫�祭��� �⪠�� ��)",101,stod("20130101"),stod(""),0,"�०���६����� � ������᪮� �窨 �७�� �४�饭�� �஢������ ��祡��� ��ய��⨩ �� ������⢨� ������᪮�� ��䥪� (�஬� ��ଫ����� � ��⠭�������� ���浪� ��砥� �⪠�� �� ��祭��): �ਢ��襥 � ��⠫쭮�� ��室� (�� �᪫�祭��� ��砥� �⪠�� �����客������ ��� �� ��祭��, ��ଫ������ � ��⠭�������� ���浪�).","6.9.2.",""})
  aadd(_f014, {"����୮� ���᭮������ ���饭�� �� �� ������ ⮣� �� ����������� �� ��������� ᪮ன ��",102,stod("20130101"),stod(""),0,"����୮� ���᭮������ ���饭�� �����客������ ��� �� ��������� ᪮ன ����樭᪮� ������� �� ������ ⮣� �� ����������� � �祭�� 24 �ᮢ.","6.10.",""})
  aadd(_f014, {"����⢨� ��� �������⢨� ���. ���ᮭ���, ���᫮���襥 ࠧ��⨥ ������ �����������",103,stod("20130101"),stod(""),0,"����⢨� ��� �������⢨� �� �������� ᪮ன ����樭᪮� �����, ���᫮���襥 ࠧ��⨥ ������ ����������� �����客������ ��� (ࠧ��⨥ ��ண������ �����������).","6.11.",""})
  aadd(_f014, {"�����᭮������ �����祭�� ������⢥���� �࠯��",104,stod("20130101"),stod(""),0,"�����᭮������ �����祭�� ������⢥���� �࠯��; �����६����� �����祭�� ������⢥���� �।�� - ᨭ������, �������� ��� ��⠣����⮢ �� �ଠ�������᪮�� ����⢨� � �.�., �易���� � �᪮� ��� ���஢�� ��樥�� �/��� �ਢ��襥 � 㤮஦���� �⮨���� ��祭��.","6.12.",""})
  aadd(_f014, {"����稥 ��宦����� �������� �᭮����� ����������� ᪮ன �� � ������᪮�� ��������",105,stod("20130101"),stod(""),0,"����稥 ��宦����� �������� �᭮����� ����������� (�ࠢ��) ᪮ன ����樭᪮� ����� � ������᪮�� ��������, ��⠭��������� � �ਥ���� �⤥����� ����樭᪮� �࣠����樨, ����뢠�饩 ᪮��� ����樭��� ������ �� ��ᯨ⠫쭮� �⠯�.","6.13.",""})
  aadd(_f014, {"���।�⠢����� ���. ���㬥�⮢ �� �������� ��",106,stod("20130101"),stod(""),0,"���।�⠢����� ����樭᪮� ���㬥��樨, ���⢥ত��饩 䠪� �������� �����客������ ���� ᪮ன ����樭᪮� �����, ��� ��ꥪ⨢��� ��稭.","6.14.",""})
  aadd(_f014, {"��䥪�� ��ଫ���� ��ࢨ筮� ����樭᪮� ���㬥��樨",107,stod("20130101"),stod(""),0,"��䥪�� ��ଫ���� ����樭᪮� ���㬥��樨, �९������騥 �஢������ ������-��������᪮� ��ᯥ�⨧� � / ��� ��ᯥ�⨧� ����⢠ ����樭᪮� ����� (������������� �業��� �������� ���ﭨ� ���஢�� �����客������ ���, ��ꥬ, �ࠪ�� � �᫮��� �।��⠢����� ᪮ன ����樭᪮� �����).","6.15.",""})
  aadd(_f014, {"����稥 �ਧ����� 䠫��䨪�樨 ����樭᪮� ���㬥��樨",108,stod("20130101"),stod(""),0,"����稥 �ਧ����� 䠫��䨪�樨 ����樭᪮� ���㬥��樨 (����᪨, ��ࠢ�����, <�������>, ������ ��८�ଫ����, � ��諥��� �᪠������ ᢥ����� � �஢������� ���������᪨� � / ��� ��祡��� ��ய�����, ������᪮� ���⨭� �����������).","6.16.",""})
  aadd(_f014, {"��ᮮ⢥��⢨� ������ ��ࢨ筮� ���. ���㬥��樨 ����� ॥��� ��⮢",109,stod("20130101"),stod(""),0,"��ᮮ⢥��⢨� ������ ����樭᪮� ���㬥��樨 ����� ��� � ॥��� ��⮢ �� ������ ᪮ன ����樭᪮� �����, � ⮬ �᫥: ����祭�� � ��� � ॥��� ��⮢ ��砥�, �� ���⢥ত����� ����樭᪮� ���㬥��樥�.","6.17.",""})
  aadd(_f014, {"��ᮮ⢥��⢨� ������ ��ࢨ筮� ���. ���㬥��樨 � ॥��� ��⮢ �� �ப�� ��祭��",110,stod("20130101"),stod(""),0,"��ᮮ⢥��⢨� ������ ����樭᪮� ���㬥��樨 ����� ��� � ॥��� ��⮢ �� ������ ᪮ன ����樭᪮� �����, � ⮬ �᫥: ��ᮮ⢥��⢨� �ப�� ��祭��, ᮣ��᭮ ����樭᪮� ���㬥��樨, �ப��, 㪠����� � ॥��� ���.","6.17.1.",""})
  aadd(_f014, {"��ᮮ⢥��⢨� ������ �������� ��ࢨ筮� ���. ���㬥��樨 � ॥��� ��⮢",111,stod("20130101"),stod(""),0,"��ᮮ⢥��⢨� ������ ����樭᪮� ���㬥��樨 ����� ��� � ॥��� ��⮢ �� ������ ᪮ன ����樭᪮� �����, � ⮬ �᫥: ��ᮮ⢥��⢨� ��������, ᮣ��᭮ ��ࢨ筮� ����樭᪮� ���㬥��樨, �����客������ ��� ��������, 㪠������� � ॥��� ���.","6.17.2.",""})
  aadd(_f014, {"�訡�� � ४������ �� ��ଫ���� � �।����� ��⮢",112,stod("20130101"),stod(""),0,"����襭��, �易��� � ��ଫ����� � �।������ �� ������ ��⮢ � ॥��஢ ��⮢, � ⮬ �᫥: ����稥 �訡�� �/��� �����⮢�୮� ���ଠ樨 � ४������ ���.","6.18.",""})
  aadd(_f014, {"��ᮮ⢥��⢨� �㬬� � ��� �� ������ � � �⮣���� �㬬� �� ॥���� ��⮢",113,stod("20130101"),stod(""),0,"����襭��, �易��� � ��ଫ����� � �।������ �� ������ ��⮢ � ॥��஢ ��⮢, � ⮬ �᫥: �㬬� ��� �� ᮮ⢥����� �⮣���� �㬬� �।��⠢������ ����樭᪮� ����� �� ॥���� ��⮢.","6.18.1.",""})
  aadd(_f014, {"�������� ���������� ����� ॥��� ��⮢",114,stod("20130101"),stod(""),0,"����襭��, �易��� � ��ଫ����� � �।������ �� ������ ��⮢ � ॥��஢ ��⮢, � ⮬ �᫥: ����稥 ������������� ����� ॥��� ��⮢, ��易⥫��� � ����������.","6.18.2.",""})
  aadd(_f014, {"�����४⭮� ���������� ����� ॥��� ��⮢",115,stod("20130101"),stod(""),0,"����襭��, �易��� � ��ଫ����� � �।������ �� ������ ��⮢ � ॥��஢ ��⮢, � ⮬ �᫥: �����४⭮� ���������� ����� ॥��� ��⮢.","6.18.3.",""})
  aadd(_f014, {"������� �㬬� �� ����樨 ॥��� ��⮢ �� ���४⭠",116,stod("20130101"),stod(""),0,"����襭��, �易��� � ��ଫ����� � �।������ �� ������ ��⮢ � ॥��஢ ��⮢, � ⮬ �᫥: ������� �㬬� �� ����樨 ॥��� ��⮢ �� ���४⭠ (ᮤ�ন� ��䬥����� �訡��).","6.18.4.",""})
  aadd(_f014, {"��� �������� �� � ॥��� ��⮢ �� ᮮ⢥����� ���⭮�� ��ਮ��/��ਮ�� ������",117,stod("20130101"),stod(""),0,"����襭��, �易��� � ��ଫ����� � �।������ �� ������ ��⮢ � ॥��஢ ��⮢, � ⮬ �᫥: ��� �������� ����樭᪮� ����� � ॥��� ��⮢ �� ᮮ⢥����� ���⭮�� ��ਮ��/��ਮ�� ������.","6.18.5.",""})
  aadd(_f014, {"��ᮮ⢥��⢨� ���� ��㣨 ��������, ����, �������, ��䨫� �⤥�����",118,stod("20130101"),stod(""),0,"����襭��, �易��� � ��ଫ����� � �।������ �� ������ ��⮢ � ॥��஢ ��⮢, � ⮬ �᫥: ��ᮮ⢥��⢨� ���� ��㣨 ��������, ����, �������, ��䨫� �⤥�����.","6.18.6.",""})
  aadd(_f014, {"�������� �� ����, �����客������ ��㣮� ���",119,stod("20130101"),stod(""),0,"����襭��, �易��� � ��।������� �ਭ��������� �����客������ ��� � ���客�� ����樭᪮� �࣠����樨: ����祭�� � ॥��� ��⮢ ��砥� �������� ����樭᪮� ����� ����, �����客������ ��㣮� ���客�� ����樭᪮� �࣠����樥�.","6.19.",""})
  aadd(_f014, {"�訡�� � ���ᮭ����� ������ ��, �ਢ���騥 � ������������ ��� �����䨪�樨",120,stod("20130101"),stod(""),0,"����襭��, �易��� � ��।������� �ਭ��������� �����客������ ��� � ���客�� ����樭᪮� �࣠����樨: �������� � ॥��� ��⮢ �����⮢���� ���ᮭ����� ������ �����客������ ���, �ਢ���饥 � ������������ ��� ������ �����䨪�樨 (�訡�� � �ਨ � ����� ����� ���, ���� � �.�.).","6.19.1.",""})
  aadd(_f014, {"�������� �� ��, ����稢襬� ����� ��� �� ����ਨ ��㣮�� ��ꥪ� ��",121,stod("20130101"),stod(""),0,"����襭��, �易��� � ��।������� �ਭ��������� �����客������ ��� � ���客�� ����樭᪮� �࣠����樨: ����祭�� � ॥��� ��⮢ ��砥� �������� ����樭᪮� ����� �����客������ ����, ����稢襣� ����� ��� �� ����ਨ ��㣮�� ��ꥪ� ���ᨩ᪮� �����樨.","6.19.2.",""})
  aadd(_f014, {"�।��⠢����� ᪮ன �� �ࠦ�����, �� �������騬 ���客���� �� ��� �� ����ਨ ��",122,stod("20130101"),stod(""),0,"����襭��, �易��� � ��।������� �ਭ��������� �����客������ ��� � ���客�� ����樭᪮� �࣠����樨: ����祭�� � ॥���� ��⮢ ��砥� �������� ᪮ன ����樭᪮� �����, �।��⠢������ ��⥣��� �ࠦ���, �� �������騬 ���客���� �� ��� �� ����ਨ ���ᨩ᪮� �����樨.","6.19.3.",""})
  aadd(_f014, {"�����᭮������ �ਬ������ ��� �� ��",123,stod("20130101"),stod(""),0,"����襭��, �易��� � �����᭮����� �ਬ������� ��� �� ����樭��� ������.","6.20.",""})
  aadd(_f014, {"����䨫쭮� �������� ��",124,stod("20130101"),stod(""),0,"����祭�� � ॥��� ��⮢ ��砥� �������� ����樭᪮� ����� ����樭᪨� ࠡ�⭨���, �� ����騬 ���䨪�� ��� ᢨ��⥫��⢠ �� ���।��樨 �� ��䨫� �������� ����樭᪮� �����.","6.21.",""})
  aadd(_f014, {"����୮� ���⠢����� ��� �� ������ ��砥� �������� ��, ����� �뫨 ����祭� ࠭��",125,stod("20130101"),stod(""),0,"����襭��, �易��� � ������ ��� �����᭮����� ����祭��� � ॥��� ��⮢ ����樭᪮� �����: ������ ॥��� ��⮢ ����祭� ࠭�� (����୮� ���⠢����� ��� �� ������ ��砥� �������� ����樭᪮� �����, ����� �뫨 ����祭� ࠭��).","6.22.",""})
  aadd(_f014, {"�㡫�஢���� ��砥� �������� �� � ����� ॥��� ��⮢",126,stod("20130101"),stod(""),0,"����襭��, �易��� � ������ ��� �����᭮����� ����祭��� � ॥��� ��⮢ ����樭᪮� �����: �㡫�஢���� ��砥� �������� ����樭᪮� ����� � ����� ॥��� ��⮢.","6.22.1.",""})
  */

  return _f014
