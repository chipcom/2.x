#include 'function.ch'

#require 'hbsqlit3'

** 26.01.23 вернуть массив по справочнику ФФОМС V036.xml
function getV036()
  // V036.xml - Перечень услуг, требующих имплантацию медицинских изделий (ServImplDv)
  //  1 - S_CODE(C) 2 - NAME(C) 3 - PARAM(N) 4 - COMMENT(C) 5 - DATEBEG(D) 6 - DATEEND(D)
  // local dbName := '_mo_v036'
  // Local dbAlias := 'V036'
  // local tmp_select := select()
  static _arr   //:= {}
  static time_load
  local db
  local aTable
  local nI

  // if len(_arr) == 0
  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT s_code, name, param, comment, datebeg, dateend FROM v036')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), val(aTable[nI, 3]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
    // dbUseArea( .t.,, exe_dir + dbName, dbAlias, .f., .f. )
    // (dbAlias)->(dbGoTop())
    // do while !(dbAlias)->(EOF())
    //   aadd(_arr, { alltrim((dbAlias)->S_CODE), alltrim((dbAlias)->NAME), (dbAlias)->PARAM, alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    //   (dbAlias)->(dbSkip())
    // enddo
    // (dbAlias)->(dbCloseArea())
    // Select(tmp_select)
  endif

  return _arr
