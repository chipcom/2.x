***** 11.02.2021
// возвращает массив V022
function getV022table()
  Local dbName, dbAlias := 'V022'
  local tmp_select := select()
  local tmpV022 := {}
  
  tmp_select := select()
  dbName := '_mo_V022'
  dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

  //  1 - IDMPAC(N)  2 - MPACNAME(C)  3 - DATEBEG(D)  4 - DATEEND(D)
  (dbAlias)->(dbGoTop())
  do while !(dbAlias)->(EOF())
    aadd(tmpV022, { (dbAlias)->IDMPAC, alltrim((dbAlias)->MPACNAME), (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    (dbAlias)->(dbSkip())
  enddo
  asort(tmpV022,,,{|x,y| x[1] < y[1] })

  (dbAlias)->(dbCloseArea())
  Select(tmp_select)
  return tmpV022
