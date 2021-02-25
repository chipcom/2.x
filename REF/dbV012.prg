* 17.02.21 ������ ���ᨢ �� �ࠢ�筨�� ����� V012.xml
function getV012()
  // V012.xml - �����䨪��� ��室�� �����������
  //  1 - IZNAME(C)  2 - IDIZ(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DL_USLOV(N)
  local _v012 := {}

  aadd(_v012, {"101/��-�/�매�஢�����",101,stod("20110101"),stod(""),1})
  aadd(_v012, {"102/��-�/����襭��",102,stod("20110101"),stod(""),1})
  aadd(_v012, {"103/��-�/��� ��६��",103,stod("20110101"),stod(""),1})
  aadd(_v012, {"104/��-�/���襭��",104,stod("20110101"),stod(""),1})
  aadd(_v012, {"201/��.�/�매�஢�����",201,stod("20110101"),stod(""),2})
  aadd(_v012, {"202/��.�/����襭��",202,stod("20110101"),stod(""),2})
  aadd(_v012, {"203/��.�/��� ��६��",203,stod("20110101"),stod(""),2})
  aadd(_v012, {"204/��.�/���襭��",204,stod("20110101"),stod(""),2})
  aadd(_v012, {"301/�-��/�매�஢�����",301,stod("20110101"),stod(""),3})
  aadd(_v012, {"302/�-��/�������",302,stod("20110101"),stod(""),3})
  aadd(_v012, {"303/�-��/����襭��",303,stod("20110101"),stod(""),3})
  aadd(_v012, {"304/�-��/��� ��६��",304,stod("20110101"),stod(""),3})
  aadd(_v012, {"305/�-��/���襭��",305,stod("20110101"),stod(""),3})
  aadd(_v012, {"306/�-��/�ᬮ��",306,stod("20120123"),stod(""),3})
  aadd(_v012, {"401/����襭��",401,stod("20110101"),stod(""),4})
  aadd(_v012, {"402/��� ��䥪�",402,stod("20110101"),stod(""),4})
  aadd(_v012, {"403/���襭��",403,stod("20110101"),stod(""),4})

  return _v012 