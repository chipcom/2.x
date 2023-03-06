#include 'function.ch'

#require 'hbsqlit3'

** 26.01.23 вернуть массив по справочнику ФФОМС V031.xml
function getV031()
  // V031.xml - Группы препаратов для лечения заболевания COVID-19 (GroupDrugs)
  //  1 - DRUGCODE(N) 2 - DRUGGRUP(C) 3 - INDMNN(N)  4 - DATEBEG(D)  5 - DATEEND(D)
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT drugcode, druggrup, indmnn, datebeg, dateend FROM v031')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), val(aTable[nI, 3]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr

****** 29.08.22 вернуть группу препаратов
function get_group_prep_by_kod(_code, ldate)
  local _arr, row, code

  if ValType(_code) == 'C'
    code := val(substr(_code, len(_code)))
  elseif ValType(_code) == 'N'
    code := _code
  else
    return _arr
  endif
    
  for each row in getV031()
    if (row[1] == code) .and. between_date(row[4], row[5], ldate)
      _arr := { row[1], row[2], row[3], row[4], row[5] }
    endif
  next
  return _arr