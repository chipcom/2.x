#include 'function.ch'

#require 'hbsqlit3'

// 28.03.23 вернуть массив по справочнику dlo_lgota
function getDLO_lgota()
  // dlo_lgota - Классификатор кодов льгот по ДЛО
  //  1 - KOD(C) 2 - NAME(C)
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT kod, name FROM dlo_lgota')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), alltrim(aTable[nI, 1])})
      next
    endif
    db := nil
  endif
  return _arr
