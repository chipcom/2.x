#include 'function.ch'

#require 'hbsqlit3'

// 13.01.24 вернуть массив по справочнику Минздрава по Степень тяжести состояния пациента OID 1.2.643.5.1.13.13.11.1006.xml
function get_severity()
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    // выбираем только до 4 степени тяжести по приказу
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id, ' + ;
        'name, ' + ;
        'syn, ' + ;
        'sctid, ' + ;
        'sort ' + ;
        'FROM Severity ' + ;
        'WHERE id <= 4' ;
    )
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), alltrim(aTable[nI, 3]), val(aTable[nI, 4]), val(aTable[nI, 5])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif

  return _arr

// 08.01.22 вернуть описание тяжести состояния пациента
Function ret_severity_name(s_code)
  // s_code - код тяжести
  Local i, ret := ''
  local code
  
  if ValType(s_code) == 'C'
    code := val(s_code)
  elseif ValType(s_code) == 'N'
    code := s_code
  else
    return ret
  endif

  if !empty(code) .and. ((i := ascan(get_severity(), {|x| x[2] == code })) > 0)
    ret := get_severity()[i, 1]
  endif
  return ret