#require 'hbsqlit3'

* 10.01.23 вернуть массив по справочнику ФФОМС V010.xml
function getV010()
  // V010.xml - Классификатор способов оплаты медицинской помощи
  // Local dbName, dbAlias := 'V010'
  // local tmp_select := select()
  static _arr := {}
  local stroke := ''
  local db
  local aTable
  local nI

  if len(_arr) == 0
    // tmp_select := select()
    // dbName := '_mo_v010'
    // dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    // //  1 - SPNAME(C)  2 - IDSP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
    // (dbAlias)->(dbGoTop())
    // do while !(dbAlias)->(EOF())
    //   stroke := StrZero((dbAlias)->IDSP, 2, 0) + '/' + alltrim((dbAlias)->SPNAME)
    //   aadd(_arr, { stroke, (dbAlias)->IDSP, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    //   (dbAlias)->(dbSkip())
    // enddo

    // (dbAlias)->(dbCloseArea())
    // Select(tmp_select)
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'idsp, ' + ;
        'spname, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM v010')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        stroke := StrZero(val(aTable[nI, 1]), 2, 0) + '/' + alltrim(aTable[nI, 2])
        aadd(_arr, {stroke, val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr