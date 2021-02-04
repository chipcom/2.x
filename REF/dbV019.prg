***** 04.02.2021
// возвращает массив V019
function getV019table()
  Local dbName, dbAlias := 'V019'
  local tmp_select := select()
  local tmpV019 := {}
  local sDiagnozis, ar, s

  tmp_select := select()
  dbName := '_mo_V019'
  dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

//  1 - IDHM(N)  2 - HMNAME(C)  3 - DIAG(C)  4 - HVID(C)  5 - DATEBEG(D)  6 - DATEEND(D)
(dbAlias)->(dbGoTop())
  do while !(dbAlias)->(EOF())
    // sDiagnozis := (dbAlias)->DIAG
    // ar := {}
    // for i := 1 to numtoken(sDiagnozis,";")
    //   s := alltrim(token(sDiagnozis,";",i))
    //   if !empty(s)
    //     aadd(ar,s)
    //   endif
    // next
    // sDiagnozis := aclone(ar) // заменим строковое представление диагнозов массивом диагнозов

    aadd(tmpV019, { (dbAlias)->IDHM, (dbAlias)->HMNAME, (dbAlias)->DIAG, (dbAlias)->HVID, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    (dbAlias)->(dbSkip())
  enddo
  (dbAlias)->(dbCloseArea())
  Select(tmp_select)
  return tmpV019

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
