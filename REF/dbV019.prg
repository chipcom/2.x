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

//  1 - IDHM(N)  2 - HMNAME(C)  3 - DIAG(C)  4 - HVID(C)  5 - DATEBEG(D)  6 - DATEEND(D)  7 - HGR(N)
  (dbAlias)->(dbGoTop())
  do while !(dbAlias)->(EOF())

    // for j := 1 to len(_glob_V019)
    //   ar := {}
    //   for i := 1 to numtoken(_glob_V019[j,3],";")
    //     s := alltrim(token(_glob_V019[j,3],";",i))
    //     if !empty(s)
    //       aadd(ar,s)
    //     endif
    //   next
    //   _glob_V019[j,3] := aclone(ar) // заменим строковое представление диагнозов массивом диагнозов
    // next

    // aadd(tmpV019, { (dbAlias)->IDHM, (dbAlias)->HMNAME, (dbAlias)->DIAG, (dbAlias)->HVID, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    tArr := alltrim((dbAlias)->DIAG)
    aadd(tmpV019, { (dbAlias)->IDHM, alltrim((dbAlias)->HMNAME), aclone(hb_ATokens(tArr, ';')), alltrim((dbAlias)->HVID), (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->HGR })
    (dbAlias)->(dbSkip())
  enddo
  asort(tmpV019,,,{|x,y| x[1] < y[1] })

  (dbAlias)->(dbCloseArea())
  Select(tmp_select)
  return tmpV019
