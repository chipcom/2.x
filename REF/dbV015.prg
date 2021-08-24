* 16.02.21 вернуть массив по справочнику V015.xml
// возвращает массив V015
function getV015()
  // V015.xml - Классификатор медицинских специальностей
  Local dbName, dbAlias := 'V015'
  local tmp_select := select()
  static _arr := {}
  
  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_v015'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )
    //  1 - NAME(C)  2 - CODE(N)  3 - HIGH(C)  4 - OKSO(C)  5 - DATEBEG(D)  6 - DATEEND(D) 7 - RECID(N)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(_arr, { alltrim((dbAlias)->NAME), (dbAlias)->CODE, alltrim((dbAlias)->HIGH), alltrim((dbAlias)->OKSO), (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->RECID })
      (dbAlias)->(dbSkip())
    enddo
    asort(_arr,,,{|x,y| x[2] < y[2] })

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _arr
