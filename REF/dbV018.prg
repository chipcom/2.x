***** 07.02.2021
// возвращает массив V018
function getV018table()
  Local dbName, dbAlias := 'V018'
  local tmp_select := select()
  local tmpV018 := {}
  
  tmp_select := select()
  dbName := '_mo_V018'
  dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

  //  1 - IDHVID(C)  2 - HVIDNAME(C)  3 - DATEBEG(D)  4 - DATEEND(D)
  (dbAlias)->(dbGoTop())
  do while !(dbAlias)->(EOF())
    aadd(tmpV018, { (dbAlias)->IDHVID, (dbAlias)->HVIDNAME, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    (dbAlias)->(dbSkip())
  enddo
  asort(tmpV018,,,{|x,y| x[1] < y[1] })

  (dbAlias)->(dbCloseArea())
  Select(tmp_select)
  return tmpV018
