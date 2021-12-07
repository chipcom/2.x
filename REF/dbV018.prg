***** 07.02.21
// возвращает массив V018
function getV018table()
  Local dbName, dbAlias := 'V018'
  local tmp_select := select()
  static _arr := {}
  
  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_V018'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - IDHVID(C)  2 - HVIDNAME(C)  3 - DATEBEG(D)  4 - DATEEND(D)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(_arr, { alltrim((dbAlias)->IDHVID), alltrim((dbAlias)->HVIDNAME), (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    asort(_arr,,,{|x,y| x[1] < y[1] })

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _arr
