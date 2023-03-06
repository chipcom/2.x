#include 'function.ch'

#require 'hbsqlit3'

#define V002_IDPR     1
#define V002_PRNAME   2
#define V002_DATEBEG  3
#define V002_DATEEND  4

** 23.01.23 вернуть массив по справочнику регионов ТФОМС V002.xml
function getV002(work_date)
  // V002.dbf - Классификатор профилей оказанной медицинской помощи
  //  1 - PRNAME(C)  2 - IDPR(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI
  local ret_array

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
        // aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
        aadd(_arr, {alltrim(aTable[nI, V002_PRNAME]), val(aTable[nI, V002_IDPR]), ctod(aTable[nI, V002_DATEBEG]), ctod(aTable[nI, V002_DATEEND])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
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
  return ret_array

