#include 'function.ch'

#require 'hbsqlit3'

// 26.01.23 вернуть Классификатор результатов диспансеризации (DispR) V017.xml
function getV017()
  // V017.xml - Классификатор результатов диспансеризации (DispR)
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT iddr, drname, datebeg, dateend FROM v017')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr

// 13.12.21 вернуть список результатов диспансеризации на дату в соответствии со списком кодов
function get_list_DispR(mdate, arrDR)
  local _arr := {}, code, i
  local tmpArr := getV017()
  local lenArr := len(tmpArr)

  for each code in arrDR
    for i := 1 to lenArr
      if code == tmpArr[i, 1] .and. between_date(tmpArr[i, 3], tmpArr[i, 4], mdate)
        aadd(_arr, tmpArr[i, 2])
      endif
    next
  next

  return _arr