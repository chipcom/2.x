#include 'function.ch'

#require 'hbsqlit3'

// 26.01.23 вернуть массив по справочнику ФФОМС V025 Классификатор целей посещения (KPC)
function getV025()
  static _arr
  static time_load
  local i
  local db
  local aTable
  local nI
  
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')

    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'idpc, ' + ;
      'n_pc, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v025')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 1]) + '-' + alltrim(aTable[nI, 2]), nI - 1, alltrim(aTable[nI, 1]), ;
            ctod(aTable[nI, 3]), ctod(aTable[nI, 4]) ;
        })
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr

function get_IDPC_from_V025_by_number(num)
  local tableV025 := getV025()
  local row
  local retIDPC := ''

  for each row in tableV025
    if row[2] == num
      retIDPC := row[3]
      exit
    endif
  next
  return retIDPC
