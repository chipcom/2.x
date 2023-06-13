#require 'hbsqlit3'

// 19.12.22 вернуть Классификатор типов документов, удостоверяющих личность F011.xml
function getF011()
  // F011.xml - Классификатор типов документов, удостоверяющих личность
  // IDDoc,     "C",   2, 0  // Код типа документа
  // DocName,   "C", 254, 0  // Наименование типа документа
  // DocSer,    "C",  10, 0  // Маска серии документа
  // DocNum,    "C",  20, 0  // Маска номера документа
  // DATEBEG,   "D",   8, 0  // Дата начала действия записи
  // DATEEND,   "D",   8, 0  // Дата окончания действия записи

  static _arr := {}
  local db
  local aTable
  local nI

  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table( db, 'SELECT docname, iddoc, datebeg, dateend, docser, docnum FROM f011')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 1]), val(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4]), alltrim(aTable[nI, 5]), alltrim(aTable[nI, 6])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr