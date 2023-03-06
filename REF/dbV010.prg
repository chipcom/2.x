#include 'function.ch'
 
#require 'hbsqlit3'

#define V010_IDSP     1
#define V010_SPNAME   2
#define V010_DATEBEG  3
#define V010_DATEEND  4

* 26.01.23 вернуть массив по справочнику ФФОМС V010.xml
function getV010(work_date)
  // V010.xml - Классификатор способов оплаты медицинской помощи
  static _arr
  static time_load
  local stroke := ''
  local db
  local aTable
  local nI
  local ret_array, row

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
        stroke := StrZero(val(aTable[nI, V010_IDSP]), 2, 0) + '/' + alltrim(aTable[nI, V010_SPNAME])
        aadd(_arr, {stroke, val(aTable[nI, V010_IDSP]), alltrim(aTable[nI, V010_SPNAME]), ctod(aTable[nI, V010_DATEBEG]), ctod(aTable[nI, V010_DATEEND])})
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
