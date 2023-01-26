#include 'function.ch'
 
#require 'hbsqlit3'

#define V010_IDSP     1
#define V010_SPNAME   2
#define V010_DATEBEG  3
#define V010_DATEEND  4

* 26.01.23 вернуть массив по справочнику ФФОМС V010.xml
function getV010(work_date)
  // V010.xml - Классификатор способов оплаты медицинской помощи
  // Local dbName, dbAlias := 'V010'
  // local tmp_select := select()
  static _arr   // := {}
  static time_load
  local stroke := ''
  local db
  local aTable
  local nI
  local ret_array, row

  // if len(_arr) == 0
  if timeout_load(@time_load)
    _arr := {}
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
        // stroke := StrZero(val(aTable[nI, 1]), 2, 0) + '/' + alltrim(aTable[nI, 2])
        stroke := StrZero(val(aTable[nI, V010_IDSP]), 2, 0) + '/' + alltrim(aTable[nI, V010_SPNAME])
        aadd(_arr, {stroke, val(aTable[nI, V010_IDSP]), alltrim(aTable[nI, V010_SPNAME]), ctod(aTable[nI, V010_DATEBEG]), ctod(aTable[nI, V010_DATEEND])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
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
  endif

  if hb_isnil(work_date)
    return _arr
  else
    ret_array := {}
    for each row in _arr
      if correct_date_dictionary(work_date, row[3], row[4])
        aadd(ret_array, row)
      endif
    next
  endif
  // return _arr
  return ret_array
