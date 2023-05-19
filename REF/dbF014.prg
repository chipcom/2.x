
#include 'function.ch'

#require 'hbsqlit3'

// 19.05.23 вернуть массив справочнику ФФОМС F014.xml
function getF014()
  // F014.xml - Классификатор причин отказа в оплате медицинской помощи
  // Kod,     "N",   3, 0  // Код ошибки
  // IDVID,   "N",   1, 0  // Код вида контроля, резервное поле
  // Naim,    "C",1000, 0  // Наименование причины отказа
  // Osn,     "C",  20, 0  // Основание отказа
  // Komment, "C", 100, 0  // Служебный комментарий
  // KodPG,   "C",  20, 0  // Код по форме N ПГ
  // DATEBEG, "D",   8, 0  // Дата начала действия записи
  // DATEEND, "D",   8, 0   // Дата окончания действия записи

  // возвращает массив
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'kod, ' + ;
      'osn, ' + ;
      'naim, ' + ;
      'komment, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM f014')
    if len(aTable) > 1
      for nI := 2 to Len(aTable)
        aadd(_arr, {val(aTable[nI, 1]), ;
          alltrim(aTable[nI, 1]) + ' (' + alltrim(aTable[nI, 2]) + ') ' + alltrim(aTable[nI, 3]), ;
          alltrim(aTable[nI, 4]), ;
          alltrim(aTable[nI, 2])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr