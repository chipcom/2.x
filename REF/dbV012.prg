* 25.05.21 ������ ��室 ����������� �� ����
function getISHOD_V012( ishod )
  local ret := NIL
  local i

  if (i := ascan(glob_V012, {|x| x[2] == ishod })) > 0
    ret := glob_V012[i,1]
  endif
  return ret

* 17.02.21 ������ ���ᨢ �� �ࠢ�筨�� ����� V012.xml
function getV012()
  // V012.xml - �����䨪��� ��室�� �����������
  //  1 - IZNAME(C)  2 - IDIZ(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DL_USLOV(N)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {"101/��-�/�매�஢�����",101,stod("20110101"),stod(""),1})
    aadd(_arr, {"102/��-�/����襭��",102,stod("20110101"),stod(""),1})
    aadd(_arr, {"103/��-�/��� ��६��",103,stod("20110101"),stod(""),1})
    aadd(_arr, {"104/��-�/���襭��",104,stod("20110101"),stod(""),1})
    aadd(_arr, {"201/��.�/�매�஢�����",201,stod("20110101"),stod(""),2})
    aadd(_arr, {"202/��.�/����襭��",202,stod("20110101"),stod(""),2})
    aadd(_arr, {"203/��.�/��� ��६��",203,stod("20110101"),stod(""),2})
    aadd(_arr, {"204/��.�/���襭��",204,stod("20110101"),stod(""),2})
    aadd(_arr, {"301/�-��/�매�஢�����",301,stod("20110101"),stod(""),3})
    aadd(_arr, {"302/�-��/�������",302,stod("20110101"),stod(""),3})
    aadd(_arr, {"303/�-��/����襭��",303,stod("20110101"),stod(""),3})
    aadd(_arr, {"304/�-��/��� ��६��",304,stod("20110101"),stod(""),3})
    aadd(_arr, {"305/�-��/���襭��",305,stod("20110101"),stod(""),3})
    aadd(_arr, {"306/�-��/�ᬮ��",306,stod("20120123"),stod(""),3})
    aadd(_arr, {"401/����襭��",401,stod("20110101"),stod(""),4})
    aadd(_arr, {"402/��� ��䥪�",402,stod("20110101"),stod(""),4})
    aadd(_arr, {"403/���襭��",403,stod("20110101"),stod(""),4})
  endif

  return _arr 