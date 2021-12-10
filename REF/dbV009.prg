
* 25.05.21 ������ १���� ���饭�� �� ����樭᪮� ������� �� ����
function getRSLT_V009( result )
  local ret := NIL
  local i

  if (i := ascan(glob_V009, {|x| x[2] == result })) > 0
    ret := glob_V009[i,1]
  endif
  return ret


* 10.12.21 ������ ���ᨢ �� �ࠢ�筨�� ����� V009.xml
function getV009()
  // V009.xml - �����䨪��� १���⮢ ���饭�� �� ����樭᪮� �������
  Local dbName, dbAlias := 'V009'
  local tmp_select := select()
  local stroke := '', vid := ''
  static _arr := {} 

  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_v009'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

  //  1 - RMPNAME(C)  2 - IDRMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DL_USLOV(N)
  (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if empty((dbAlias)->DATEEND)  // ⮫쪮 �᫨ ���� ����砭�� ����⢨� ����
        if (dbAlias)->DL_USLOV == 1
          vid := '/��-�/'
        elseif (dbAlias)->DL_USLOV == 2
          vid := '/��.�/'
        elseif (dbAlias)->DL_USLOV == 3 .and. (dbAlias)->IDRMP < 316
          vid := '/�-��/'
        else
          vid := '/'
        endif
        stroke := str((dbAlias)->IDRMP, 3) + vid + alltrim((dbAlias)->RMPNAME)
        // aadd(_arr, { alltrim((dbAlias)->RMPNAME), (dbAlias)->IDRMP, (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->DL_USLOV })
        aadd(_arr, { stroke, (dbAlias)->IDRMP, (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->DL_USLOV })
      endif
      (dbAlias)->(dbSkip())
    enddo

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)


    // aadd(_arr, {"101/��-�/�믨ᠭ",101,stod("20110101"),stod(""),1})
    // aadd(_arr, {"102/��-�/��ॢ��� � ��. ���",102,stod("20110101"),stod(""),1})
    // aadd(_arr, {"103/��-�/��ॢ��� � ������� ��樮���",103,stod("20110101"),stod(""),1})
    // aadd(_arr, {"104/��-�/��ॢ��� �� ��㣮� ��䨫� ����",104,stod("20110101"),stod(""),1})
    // aadd(_arr, {"105/��-�/����",105,stod("20110101"),stod(""),1})
    // aadd(_arr, {"106/��-�/���� � ��񬭮� �����",106,stod("20110101"),stod(""),1})
    // aadd(_arr, {"107/��-�/��祭�� ��ࢠ�� �� ���樠⨢� ��樥��",107,stod("20111216"),stod(""),1})
    // aadd(_arr, {"108/��-�/��祭�� ��ࢠ�� �� ���樠⨢� ���",108,stod("20111216"),stod(""),1})
    // aadd(_arr, {"109/��-�/��祭�� �த������",109,stod("20111216"),stod(""),1})
    // aadd(_arr, {"110/��-�/�������쭮 ��ࢠ���� ��祭��",110,stod("20120123"),stod(""),1})
    // aadd(_arr, {"201/��.�/�믨ᠭ",201,stod("20110101"),stod(""),2})
    // aadd(_arr, {"202/��.�/��ॢ��� � ��. ���",202,stod("20110101"),stod(""),2})
    // aadd(_arr, {"203/��.�/��ॢ��� � ��樮���",203,stod("20110101"),stod(""),2})
    // aadd(_arr, {"204/��.�/��ॢ��� �� ��㣮� ��䨫� ����",204,stod("20110101"),stod(""),2})
    // aadd(_arr, {"205/��.�/����",205,stod("20110101"),stod(""),2})
    // aadd(_arr, {"206/��.�/���� � ��񬭮� �����",206,stod("20110101"),stod(""),2})
    // aadd(_arr, {"207/��.�/��祭�� ��ࢠ�� �� ���樠⨢� ��樥��",207,stod("20130704"),stod(""),2})
    // aadd(_arr, {"208/��.�/��祭�� ��ࢠ�� �� ���樠⨢� ���",208,stod("20130704"),stod(""),2})
    // aadd(_arr, {"301/�-��/��祭�� �����襭�",301,stod("20110101"),stod(""),3})
    // aadd(_arr, {"302/�-��/��祭�� ��ࢠ�� �� ���樠⨢� ��樥��",302,stod("20110101"),stod(""),3})
    // aadd(_arr, {"303/�-��/��祭�� ��ࢠ�� �� ���樠⨢� ���",303,stod("20110101"),stod(""),3})
    // aadd(_arr, {"304/�-��/��祭�� �த������",304,stod("20110101"),stod(""),3})
    // aadd(_arr, {"305/�-��/���ࠢ��� �� ��ᯨ⠫�����",305,stod("20110101"),stod(""),3})
    // aadd(_arr, {"306/�-��/���ࠢ��� � ������� ��樮���",306,stod("20110101"),stod(""),3})
    // aadd(_arr, {"307/�-��/���ࠢ��� � ��樮��� �� ����",307,stod("20110101"),stod(""),3})
    // aadd(_arr, {"308/�-��/���ࠢ��� �� ���������",308,stod("20110101"),stod(""),3})
    // aadd(_arr, {"309/�-��/���ࠢ��� �� ��������� � ��㣮� ���",309,stod("20110101"),stod(""),3})
    // aadd(_arr, {"310/�-��/���ࠢ��� � ॠ�����樮���� �⤥�����",310,stod("20110101"),stod(""),3})
    // aadd(_arr, {"311/�-��/���ࠢ��� �� ᠭ��୮-����⭮� ��祭��",311,stod("20110101"),stod(""),3})
    // aadd(_arr, {"312/�-��/�஢����� �������⥫쭠� ��ᯠ��ਧ���",312,stod("20110101"),stod(""),3})
    // aadd(_arr, {"313/�-��/�������� 䠪� ᬥ��",313,stod("20110101"),stod(""),3})
    // aadd(_arr, {"314/�-��/�������᪮� �������",314,stod("20120123"),stod(""),3})
    // aadd(_arr, {"315/�-��/���ࠢ��� �� ��᫥�������",315,stod("20120123"),stod(""),3})
    // aadd(_arr, {"316/���ࠢ��� �� II �⠯ ��ᯠ��ਧ�樨 ��।������� ��㯯 ���᫮�� ��ᥫ����",316,stod("20130425"),stod(""),3})
    // aadd(_arr, {"317/�஢����� ��ᯠ��ਧ��� ��।������� ��㯯 ���᫮�� ��ᥫ���� - ��᢮��� I ��㯯� ���஢��",317,stod("20130425"),stod(""),3})
    // aadd(_arr, {"318/�஢����� ��ᯠ��ਧ��� ��।������� ��㯯 ���᫮�� ��ᥫ���� - ��᢮��� II ��㯯� ���஢��",318,stod("20130425"),stod(""),3})
    // aadd(_arr, {"319/�஢����� ��ᯠ��ਧ��� ��।������� ��㯯 ���᫮�� ��ᥫ���� - ��᢮��� III ��㯯� ���஢��",319,stod("20130425"),stod(""),3})
    // aadd(_arr, {"320/���ࠢ��� �� II �⠯ ��ᯠ��ਧ�樨 �ॡ뢠��� � ��樮����� ��०������ ��⥩-��� � ��⥩, ��室����� � ��㤭�� ��������� ���樨",320,stod("20130425"),stod("20130522"),3})
    // aadd(_arr, {"321/�஢����� ��ᯠ��ਧ��� �ॡ뢠��� � ��樮����� ��०������ ��⥩-��� � ��⥩, ��室����� � ��㤭�� ��������� ���樨 - ��᢮��� I ��㯯� ���஢��",321,stod("20130425"),stod(""),3})
    // aadd(_arr, {"322/�஢����� ��ᯠ��ਧ��� �ॡ뢠��� � ��樮����� ��०������ ��⥩-��� � ��⥩, ��室����� � ��㤭�� ��������� ���樨 - ��᢮��� II ��㯯� ���஢��",322,stod("20130425"),stod(""),3})
    // aadd(_arr, {"323/�஢����� ��ᯠ��ਧ��� �ॡ뢠��� � ��樮����� ��०������ ��⥩-��� � ��⥩, ��室����� � ��㤭�� ��������� ���樨 - ��᢮��� III ��㯯� ���஢��",323,stod("20130425"),stod(""),3})
    // aadd(_arr, {"324/�஢����� ��ᯠ��ਧ��� �ॡ뢠��� � ��樮����� ��०������ ��⥩-��� � ��⥩, ��室����� � ��㤭�� ��������� ���樨 - ��᢮��� IV ��㯯� ���஢��",324,stod("20130425"),stod(""),3})
    // aadd(_arr, {"325/�஢����� ��ᯠ��ਧ��� �ॡ뢠��� � ��樮����� ��०������ ��⥩-��� � ��⥩, ��室����� � ��㤭�� ��������� ���樨 - ��᢮��� V ��㯯� ���஢��",325,stod("20130425"),stod(""),3})
    // aadd(_arr, {"326/���ࠢ��� �� II �⠯ ����樭᪮�� �ᬮ��",326,stod("20130425"),stod("20130522"),3})
    // aadd(_arr, {"327/�஢���� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� I ��㯯� ���஢��",327,stod("20130425"),stod("20130522"),3})
    // aadd(_arr, {"328/�஢���� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� II ��㯯� ���஢��",328,stod("20130425"),stod("20130522"),3})
    // aadd(_arr, {"329/�஢���� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� III ��㯯� ���஢��",329,stod("20130425"),stod("20130522"),3})
    // aadd(_arr, {"330/�஢���� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� IV ��㯯� ���஢��",330,stod("20130425"),stod("20130522"),3})
    // aadd(_arr, {"331/�஢���� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� V ��㯯� ���஢��",331,stod("20130425"),stod("20130522"),3})
    // aadd(_arr, {"332/�஢���� ��䨫����᪨� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� I ��㯯� ���஢��",332,stod("20130522"),stod(""),3})
    // aadd(_arr, {"333/�஢���� ��䨫����᪨� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� II ��㯯� ���஢��",333,stod("20130522"),stod(""),3})
    // aadd(_arr, {"334/�஢���� ��䨫����᪨� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� III ��㯯� ���஢��",334,stod("20130522"),stod(""),3})
    // aadd(_arr, {"335/�஢���� ��䨫����᪨� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� IV ��㯯� ���஢��",335,stod("20130522"),stod(""),3})
    // aadd(_arr, {"336/�஢���� ��䨫����᪨� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� V ��㯯� ���஢��",336,stod("20130522"),stod(""),3})
    // aadd(_arr, {"337/�஢���� �।���⥫�� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� I ��㯯� ���஢��",337,stod("20130522"),stod(""),3})
    // aadd(_arr, {"338/�஢���� �।���⥫�� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� II ��㯯� ���஢��",338,stod("20130522"),stod(""),3})
    // aadd(_arr, {"339/�஢���� �।���⥫�� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� III ��㯯� ���஢��",339,stod("20130522"),stod(""),3})
    // aadd(_arr, {"340/�஢���� �।���⥫�� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� IV ��㯯� ���஢��",340,stod("20130522"),stod(""),3})
    // aadd(_arr, {"341/�஢���� �।���⥫�� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥�� - ��᢮��� V ��㯯� ���஢��",341,stod("20130522"),stod(""),3})
    // aadd(_arr, {"342/�஢���� ��ਮ���᪨� ����樭᪨� �ᬮ�� ��ᮢ��襭����⭥��",342,stod("20130522"),stod(""),3})
    // aadd(_arr, {"343/�஢���� ��䨫����᪨� ����樭᪨� �ᬮ�� ���᫮�� ��ᥫ���� - ��᢮��� I ��㯯� ���஢��",343,stod("20130522"),stod(""),3})
    // aadd(_arr, {"344/�஢���� ��䨫����᪨� ����樭᪨� �ᬮ�� ���᫮�� ��ᥫ���� - ��᢮��� II ��㯯� ���஢��",344,stod("20130522"),stod(""),3})
    // aadd(_arr, {"345/�஢���� ��䨫����᪨� ����樭᪨� �ᬮ�� ���᫮�� ��ᥫ���� - ��᢮��� III ��㯯� ���஢��",345,stod("20130522"),stod(""),3})
    // aadd(_arr, {"346/��室�� II �⠯ ��ᯠ��ਧ�樨 ��।������� ��㯯 ���᫮�� ��ᥫ����",346,stod("20130522"),stod(""),3})
    // aadd(_arr, {"347/�஢����� ��ᯠ��ਧ��� ��⥩-��� � ��⥩, ��⠢���� ��� ����祭�� த�⥫��, � ⮬ �᫥ ��뭮������� (㤮�७���), �ਭ���� ��� �����, � �ਥ���� ��� ���஭���� ᥬ�� - ��᢮��� I ��㯯� ���஢��",347,stod("20130709"),stod(""),3})
    // aadd(_arr, {"348/�஢����� ��ᯠ��ਧ��� ��⥩-��� � ��⥩, ��⠢���� ��� ����祭�� த�⥫��, � ⮬ �᫥ ��뭮������� (㤮�७���), �ਭ���� ��� �����, � �ਥ���� ��� ���஭���� ᥬ�� - ��᢮��� II ��㯯� ���஢��",348,stod("20130709"),stod(""),3})
    // aadd(_arr, {"349/�஢����� ��ᯠ��ਧ��� ��⥩-��� � ��⥩, ��⠢���� ��� ����祭�� த�⥫��, � ⮬ �᫥ ��뭮������� (㤮�७���), �ਭ���� ��� �����, � �ਥ���� ��� ���஭���� ᥬ�� - ��᢮��� III ��㯯� ���஢��",349,stod("20130709"),stod(""),3})
    // aadd(_arr, {"350/�஢����� ��ᯠ��ਧ��� ��⥩-��� � ��⥩, ��⠢���� ��� ����祭�� த�⥫��, � ⮬ �᫥ ��뭮������� (㤮�७���), �ਭ���� ��� �����, � �ਥ���� ��� ���஭���� ᥬ�� - ��᢮��� IV ��㯯� ���஢��",350,stod("20130709"),stod(""),3})
    // aadd(_arr, {"351/�஢����� ��ᯠ��ਧ��� ��⥩-��� � ��⥩, ��⠢���� ��� ����祭�� த�⥫��, � ⮬ �᫥ ��뭮������� (㤮�७���), �ਭ���� ��� �����, � �ਥ���� ��� ���஭���� ᥬ�� - ��᢮��� V ��㯯� ���஢��",351,stod("20130709"),stod(""),3})
    // aadd(_arr, {"352/���ࠢ��� �� II �⠯ ��ᯠ��ਧ�樨 ��।������� ��㯯 ���᫮�� ��ᥫ����, �।���⥫쭮 ��᢮��� I ��㯯� ���஢��",352,stod("20140306"),stod(""),3})
    // aadd(_arr, {"353/���ࠢ��� �� II �⠯ ��ᯠ��ਧ�樨 ��।������� ��㯯 ���᫮�� ��ᥫ����, �।���⥫쭮 ��᢮��� II ��㯯� ���஢��",353,stod("20140306"),stod(""),3})
    // aadd(_arr, {"354/���ࠢ��� �� II �⠯ ��ᯠ��ਧ�樨 ��।������� ��㯯 ���᫮�� ��ᥫ����, �।���⥫쭮 ��᢮��� III ��㯯� ���஢��",354,stod("20140306"),stod(""),3})
    // aadd(_arr, {"355/�஢����� ��ᯠ��ਧ��� ��।������� ��㯯 ���᫮�� ��ᥫ���� - ��᢮��� III� ��㯯� ���஢��",355,stod("20150401"),stod(""),3})
    // aadd(_arr, {"356/�஢����� ��ᯠ��ਧ��� ��।������� ��㯯 ���᫮�� ��ᥫ���� - ��᢮��� III� ��㯯� ���஢��",356,stod("20150401"),stod(""),3})
    // aadd(_arr, {"357/���ࠢ��� �� II �⠯ ��ᯠ��ਧ�樨 ��।������� ��㯯 ���᫮�� ��ᥫ����, �।���⥫쭮 ��᢮��� III� ��㯯� ���஢��",357,stod("20150401"),stod(""),3})
    // aadd(_arr, {"358/���ࠢ��� �� II �⠯ ��ᯠ��ਧ�樨 ��।������� ��㯯 ���᫮�� ��ᥫ����, �।���⥫쭮 ��᢮��� III� ��㯯� ���஢��",358,stod("20150401"),stod(""),3})
    // aadd(_arr, {"373/�஢���� ��䨫����᪨� ����樭᪨� �ᬮ�� ���᫮�� ��ᥫ���� - ��᢮��� III� ��㯯� ���஢��",373,stod("20191101"),stod(""),3})
    // aadd(_arr, {"374/�஢���� ��䨫����᪨� ����樭᪨� �ᬮ�� ���᫮�� ��ᥫ���� - ��᢮��� III� ��㯯� ���஢��",374,stod("20191101"),stod(""),3})
    // aadd(_arr, {"401/������� ������, ���쭮� ��⠢��� �� ����",401,stod("20110101"),stod(""),4})
    // aadd(_arr, {"402/���⠢��� � �ࠢ��㭪�",402,stod("20110101"),stod(""),4})
    // aadd(_arr, {"403/���⠢��� � ���쭨��",403,stod("20110101"),stod(""),4})
    // aadd(_arr, {"404/��।�� ᯥ樠����஢����� �ਣ��� ���",404,stod("20110101"),stod(""),4})
    // aadd(_arr, {"405/������ � ������⢨� �ਣ��� ���",405,stod("20110101"),stod(""),4})
    // aadd(_arr, {"406/������ � ��⮬����� ���",406,stod("20110101"),stod(""),4})
    // aadd(_arr, {"407/���쭮� �� ������ �� ����",407,stod("20110101"),stod(""),4})
    // aadd(_arr, {"408/�⪠� �� �����",408,stod("20110101"),stod(""),4})
    // aadd(_arr, {"409/���� �� ������",409,stod("20110101"),stod(""),4})
    // aadd(_arr, {"410/����� �맮�",410,stod("20110101"),stod(""),4})
    // aadd(_arr, {"411/������ �� �ਥ��� �ਣ��� ���",411,stod("20110101"),stod(""),4})
    // aadd(_arr, {"412/���쭮� 㢥�� �� �ਡ��� ���",412,stod("20110101"),stod(""),4})
    // aadd(_arr, {"413/���쭮� ���㦥� ��箬 ����������� �� �ਡ��� ���",413,stod("20110101"),stod(""),4})
    // aadd(_arr, {"414/�맮� �⬥��",414,stod("20110101"),stod(""),4})
    // aadd(_arr, {"415/��樥�� �ࠪ��᪨ ���஢",415,stod("20110101"),stod(""),4})
    // aadd(_arr, {"416/������⢮",416,stod("20110101"),stod(""),4})
    // aadd(_arr, {"417/�⪠� �� �࠭ᯮ��஢�� ��� ��ᯨ⠫���樨 � ��樮���",417,stod("20130101"),stod(""),4})
  endif

  return _arr