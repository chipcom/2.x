* 28.02.21 ������ �����䨪��� ���� �����客������ V005.xml
function getV005()
  // V005.xml - �����䨪��� ���� �����客������
  //  1 - POLNAME(C)  2 - IDPOL(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {"��᪮�",1,stod(""),stod("")})
    aadd(_arr, {"���᪨�",2,stod(""),stod("")})
  endif

  return _arr