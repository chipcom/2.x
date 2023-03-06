#include 'function.ch'

#require 'hbsqlit3'

* 26.01.22 вернуть массив по справочнику ФФОМС V032.xml
function getV032()
  // V032.xml - Сочетание схемы лечения и группы препаратов (CombTreat)
  //  1 - SCHEDRUG(C) 2 - NAME(C) 3 - SCHEMCOD(C)  4 - DATEBEG(D)  5 - DATEEND(D)
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT schedrug, name, schemcode, datebeg, dateend FROM v032')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), alltrim(aTable[nI, 1]), alltrim(aTable[nI, 3]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif

  return _arr

****** 04.01.22 вернуть сочетание схемы и группы препаратов
function get_group_by_schema_lech(_scheme, ldate)
  local _arr := {}, row

  for each row in getV032()
    if (row[3] == alltrim(_scheme)) .and. between_date(row[4], row[5], ldate)
      aadd(_arr, { row[1], row[2], row[3], row[4], row[5] })
    endif
  next
  return _arr

***** 08.01.22 вернуть наименование кода схемы
Function ret_schema_V032(s_code)
  // s_code - код схемы
  Local i, ret := ''
  local code := alltrim(s_code)
  
  if !empty(code) .and. ((i := ascan(getV032(), {|x| x[2] == code })) > 0)
    ret := getV032()[i, 1]
  endif
  return ret
