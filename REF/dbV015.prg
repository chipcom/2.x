#require 'hbsqlit3'

* 12.01.23 вернуть массив по справочнику V015.xml
// возвращает массив V015
function getV015()
  // V015.xml - Классификатор медицинских специальностей
  // Local dbName, dbAlias := 'V015'
  // local tmp_select := select()
  static _arr := {}
  local db
  local aTable
  local nI
  
  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'recid, ' + ;
        'code, ' + ;
        'name, ' + ;
        'high, ' + ;
        'okso, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM v015')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 3]), val(aTable[nI, 2]), alltrim(aTable[nI, 4]), alltrim(aTable[nI, 5]), ctod(aTable[nI, 6]), ctod(aTable[nI, 7]), val(aTable[nI, 1])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil

    // tmp_select := select()
    // dbName := '_mo_v015'
    // dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )
    // //  1 - NAME(C)  2 - CODE(N)  3 - HIGH(C)  4 - OKSO(C)  5 - DATEBEG(D)  6 - DATEEND(D) 7 - RECID(N)
    // (dbAlias)->(dbGoTop())
    // do while !(dbAlias)->(EOF())
    //   aadd(_arr, { alltrim((dbAlias)->NAME), (dbAlias)->CODE, alltrim((dbAlias)->HIGH), alltrim((dbAlias)->OKSO), (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->RECID })
    //   (dbAlias)->(dbSkip())
    // enddo
    // (dbAlias)->(dbCloseArea())
    // Select(tmp_select)

    asort(_arr, , ,{|x, y| x[2] < y[2]})
  endif
  return _arr
