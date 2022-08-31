* 10.12.21 вернуть массив по справочнику ФФОМС V010.xml
function getV010()
  // V010.xml - Классификатор способов оплаты медицинской помощи
  Local dbName, dbAlias := 'V010'
  local tmp_select := select()
  local stroke := ''
  static _arr := {}

  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_v010'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - SPNAME(C)  2 - IDSP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      stroke := StrZero((dbAlias)->IDSP, 2, 0) + '/' + alltrim((dbAlias)->SPNAME)
      aadd(_arr, { stroke, (dbAlias)->IDSP, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr