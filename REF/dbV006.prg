* 28.02.21 вернуть Классификатор условий оказания медицинской помощи V006.xml
function getV006()
  // V006.xml - Классификатор условий оказания медицинской помощи
  //  1 - UMPNAME(C)  2 - IDUMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {"Стационар",1,stod("20110101"),stod("")})
    aadd(_arr, {"Дневной стационар",2,stod("20110101"),stod("")})
    aadd(_arr, {"Поликлиника",3,stod("20110101"),stod("")})
    aadd(_arr, {"Скорая помощь",4,stod("20130101"),stod("")})
  endif

  return _arr