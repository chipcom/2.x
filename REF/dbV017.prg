* 12.12.21 вернуть Классификатор результатов диспансеризации (DispR) V017.xml
function getV017()
  // V017.xml - Классификатор результатов диспансеризации (DispR)
  Local dbName, dbAlias := 'V017'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_v017'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - IDDR(N)  2 - DRNAME(C)  3 - DATEBEG(D)  4 - DATEEND(D)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(_arr, { (dbAlias)->IDDR, (dbAlias)->DRNAME, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr