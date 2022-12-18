#require 'hbsqlit3'

** 17.12.22 вернуть Классификатор типов документов, удостоверяющих личность F011.xml
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
        aadd(_arr, {alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4]), alltrim(aTable[nI, 5]), alltrim(aTable[nI, 6])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr

* 17.12.22 вернуть Классификатор типов документов, удостоверяющих личность F011.xml
function getF011_1()
  // F011.xml - Классификатор типов документов, удостоверяющих личность
  //  1 - DocName(C)  2 - IDDoc(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DocSer(C)  6 - DocNum(C)
  static _arr := {}
  local dbName := '_mo_f011'

  if len(_arr) == 0
    dbUseArea(.t.,, exe_dir + dbName, dbName, .f., .f.)
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      if empty((dbName)->DATEEND)
        aadd(_arr, {alltrim((dbName)->DOCNAME), (dbName)->IDDOC, (dbName)->DATEBEG, (dbName)->DATEEND, (dbName)->DOCSER, (dbName)->DOCNUM})
      endif
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
  endif

  return _arr