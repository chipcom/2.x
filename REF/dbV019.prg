***** 07.02.2021
// возвращает массив V019
function getV019table()
  Local dbName, dbAlias := 'V019'
  local tmp_select := select()
  local tmpV019 := {}
  local tStr

  tmp_select := select()
  dbName := '_mo_V019'
  dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

//  1 - IDHM(N)  2 - HMNAME(C)  3 - DIAG(C)  4 - HVID(C)  5 - DATEBEG(D)  6 - DATEEND(D)  7 - HGR(N)  8 - IDMODP(N)
  (dbAlias)->(dbGoTop())
  do while !(dbAlias)->(EOF())

    tArr := alltrim((dbAlias)->DIAG)
    aadd(tmpV019, { (dbAlias)->IDHM, alltrim((dbAlias)->HMNAME), aclone(hb_ATokens(tArr, ';')), alltrim((dbAlias)->HVID), (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->HGR, (dbAlias)->IDMODP })
    (dbAlias)->(dbSkip())
  enddo
  asort(tmpV019,,,{|x,y| x[1] < y[1] })

  (dbAlias)->(dbCloseArea())
  Select(tmp_select)
  return tmpV019
