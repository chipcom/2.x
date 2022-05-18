* 18.05.22 ������ �᫮��t �������� ����樭᪮� ����� �� ����
function getUSLOVIE_V006( kod )
  local ret := NIL
  local i

  if (i := ascan(getV006(), {|x| x[2] == kod })) > 0
    ret := getV006()[i,1]
  endif
  return ret

* 28.02.21 ������ �����䨪��� �᫮��� �������� ����樭᪮� ����� V006.xml
function getV006()
  // V006.xml - �����䨪��� �᫮��� �������� ����樭᪮� �����
  //  1 - UMPNAME(C)  2 - IDUMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {"��樮���",1,stod("20110101"),stod("")})
    aadd(_arr, {"������� ��樮���",2,stod("20110101"),stod("")})
    aadd(_arr, {"�����������",3,stod("20110101"),stod("")})
    aadd(_arr, {"����� ������",4,stod("20130101"),stod("")})
  endif

  return _arr