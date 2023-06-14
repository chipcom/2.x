#require 'hbsqlit3'

// 26.01.23 вернуть массив по справочнику V015.xml
// возвращает массив V015
function getV015()
  // V015.xml - Классификатор медицинских специальностей
  static _arr
  static time_load
  local db
  local aTable
  local nI
  
  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'recid, ' + ;
        'code, ' + ;
        'name, ' + ;
        'high, ' + ;
        'okso, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM v015')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 3]), val(aTable[nI, 2]), alltrim(aTable[nI, 4]), alltrim(aTable[nI, 5]), ctod(aTable[nI, 6]), ctod(aTable[nI, 7]), val(aTable[nI, 1])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil

    asort(_arr, , ,{|x, y| x[2] < y[2]})
  endif
  return _arr