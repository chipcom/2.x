#include 'function.ch'

#require 'hbsqlit3'

// 26.01.23 возвращает массив V022
function getV022()
  static _arr
  static time_load
  local db
  local aTable, stmt
  local nI
  
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')

    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'idmpac, ' + ;
      'mpacname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v022')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ;
            ctod(aTable[nI, 3]), ctod(aTable[nI, 4]) ;
        })
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
    asort(_arr, , , {|x, y| x[1] < y[1] })
  endif
  return _arr

// 11.02.21 вернуть строку модели пациента ВМП
Function ret_V022(idmpac, lk_data)
  Local i, s := space(10)
  local aV022 := getV022()

  if !empty(idmpac) .and. ((i := ascan(aV022, {|x| x[1] == idmpac })) > 0)
    s := aV022[i, 2]
  endif
  return s