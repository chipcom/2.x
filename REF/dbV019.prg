***** 04.02.2021
// возвращает массив V019
function getV019table()
  Local dbName, dbAlias := 'V019'
  local tmp_select := select()
  local tmpV019 := {}

  tmp_select := select()
  aV019 := {}
  dbName := '_mo_V019'
  dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

//  1 - IDHM(N)  2 - HMNAME(C)  3 - DIAG(C)  4 - HVID(C)  5 - DATEBEG(D)  6 - DATEEND(D)
(dbAlias)->(dbGoTop())
  do while !(dbAlias)->(EOF())
    aadd(tmpV019, { (dbAlias)->IDHM, (dbAlias)->HMNAME, (dbAlias)->DIAG, (dbAlias)->HVID, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    (dbAlias)->(dbSkip())
  enddo
  (dbAlias)->(dbCloseArea())
  Select(tmp_select)
  return tmpV019
