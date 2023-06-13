// 27.02.21 вернуть Классификатор статуса застрахованного лица F009.xml
function getF009()
  // F009.xml - Классификатор статуса застрахованного лица
  //  1 - StatusName(C)  2 - IDStatus(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'Работающий', 1, stod('20110101'), stod('')})
    aadd(_arr, {'Неработающий', 2, stod('20110101'), stod('')})
  endif

  return _arr