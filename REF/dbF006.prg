
* 04.03.21 вернуть массив Классификатор видов контроля F006.xml
function getF006()
  // F006.xml - Классификатор видов контроля
  //  1 - VIDNAME(C)  2 - IDVID(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}
  local dbName := '_mo_f006'

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      if empty((dbName)->DATEEND)
        aadd(_arr, { alltrim((dbName)->VIDNAME), (dbName)->IDVID, (dbName)->DATEBEG, (dbName)->DATEEND })
      endif
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
  endif

  return _arr