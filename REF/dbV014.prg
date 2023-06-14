// 21.10.22 вернуть Классификатор форм медицинской помощи V014.xml
function getV014()
  // V014.xml - Классификатор форм медицинской помощи
  //  1 - FRMMPNAME(C)  2 - IDFRMMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'Экстренная', 1, stod('20130101'), stod('')})
    aadd(_arr, {'Неотложная', 2, stod('20130101'), stod('')})
    aadd(_arr, {'Плановая', 3, stod('20130101'), stod('')})
  endif

  return _arr