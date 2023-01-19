#include 'function.ch'

** 19.01.23 вернуть массив по справочнику регионов ТФОМС V002.xml
function getV002(work_date)
  // V002.dbf - Классификатор профилей оказанной медицинской помощи
  //  1 - PRNAME(C)  2 - IDPR(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  // local dbName := "_mo_V002"
  static _arr // := {}
  static time_load
  local db
  local aTable
  local nI
  local ret_array

  DEFAULT work_date TO sys_date
  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'idpr, ' + ;
        'prname, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM v002')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
    // dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    // (dbName)->(dbGoTop())
    // do while !(dbName)->(EOF())
    //   aadd(_arr, { alltrim((dbName)->PRNAME), (dbName)->IDPR, (dbName)->DATEBEG, (dbName)->DATEEND })
    //   (dbName)->(dbSkip())
    // enddo
    // (dbName)->(dbCloseArea())
  endif
  ret_array := {}

  return _arr

