* 04.03.21 вернуть Классификатор типов документов, удостоверяющих личность F011.xml
function getF011()
  // F011.xml - Классификатор типов документов, удостоверяющих личность
  //  1 - DocName(C)  2 - IDDoc(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DocSer(C)  6 - DocNum(C)
  static _arr := {}
  local dbName := '_mo_f011'

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      if empty((dbName)->DATEEND)
        aadd(_arr, { alltrim((dbName)->DOCNAME), (dbName)->IDDOC, (dbName)->DATEBEG, (dbName)->DATEEND, (dbName)->DOCSER, (dbName)->DOCNUM })
      endif
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
  endif

  return _arr