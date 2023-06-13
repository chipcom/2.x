
// 27.02.21 вернуть массив Классификатор статусов оплаты медицинской помощи F005.xml
function getF005()
  // F005.xml - Классификатор статусов оплаты медицинской помощи
  //  1 - STNAME(C)  2 - IDIDST(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'Не принято решение об оплате', 0, stod('20110101'), stod('')})
    aadd(_arr, {'Оплачена', 1, stod('20110101'), stod('')})
    aadd(_arr, {'Не оплачена', 2, stod('20110101'), stod('')})
    aadd(_arr, {'Частично оплачена', 3, stod('20110101'), stod('')})
  endif

  return _arr