#include 'function.ch'

#require 'hbsqlit3'

// #define TRACE

// 26.01.23
function get_ed_izm()
  // OID 1.2.643.5.1.13.13.11.1358_*.*.xml - Единицы измерения
  //  1 - ID(N)       // Уникальный идентификатор единицы измерения лабораторного теста, целое число
  //  2 - FULLNAME(C) // Полное наименование, Строчный
  //  3 - SHORTNAME(C) // Краткое наименование, Строчный;
  
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id, ' + ;
        'fullname, ' + ;
        'shortname ' + ;
        'FROM ed_izm')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        if mem_n_V034 == 0
          aadd(_arr, {alltrim(aTable[nI, 3]), val(aTable[nI, 1]), CToD(''), CToD('')})
        else
          aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), CToD(''), CToD('')})
        endif  
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr
  
// 23.01.22 вернуть наименование единицы измерения
Function ret_ed_izm(id)
  // id - код единицы измерения
  Local i, ret := ''
  // local code

  if ValType(id) == 'C'
    id:= val(alltrim(id))
  elseif ValType(id) == 'N'
    // id := id
  else
    return ret
  endif
  
  if !empty(id) .and. ((i := ascan(get_ed_izm(), {|x| x[2] == id })) > 0)
    ret := get_ed_izm()[i, 1]
  endif
  return ret