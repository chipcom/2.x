#include 'function.ch'

#require 'hbsqlit3'

// #define TRACE

** 26.01.23
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
  
  ***** 23.01.22 вернуть наименование единицы измерения
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

** 23.01.22 вернуть массив по справочнику Минздрава OID 1.2.643.5.1.13.13.11.1358_*.*.xml (единицы измерений)
// function get_ed_izm1()
//   // OID 1.2.643.5.1.13.13.11.1358_*.*.xml - Единицы измерения
//   //  1 - ID(N)       // Уникальный идентификатор единицы измерения лабораторного теста, целое число
//   //  2 - FULLNAME(C) // Полное наименование, Строчный
//   //  3 - SHOTNAME(C) // Краткое наименование, Строчный;
//   //  4 - PRNNAME(C)  // Наименование для печати, Строчный;
//   //  5 - MEASUR(C)   // Размерность, Строчный;
//   //  6 - UCUM(C)     // Код UCUM, Строчный;
//   //  7 - COEF(C)     // Коэффициент пересчета, Строчный, Коэффициент пересчета в рамках одной размерности.;
//   //  8 - CONV_ID(N)  // Код единицы измерения для пересчета, Целочисленный, Код единицы измерения, в которую осуществляется пересчет.;
//   //  9 - CONV_NAM(C) // Единица измерения для пересчета, Строчный, Краткое наименование единицы измерения, в которую осуществляется пересчет.;
//   // 10 - OKEI_COD(N) // Код ОКЕИ, Строчный, Соответствующий код Общероссийского классификатора единиц измерений.;

//   local dbName := '_mo_ed_izm'
//   Local dbAlias := '_ED_IZM'
//   local tmp_select := select()
//   static _arr := {}

//   if len(_arr) == 0
//     dbUseArea( .t.,, exe_dir + dbName, dbAlias, .f., .f. )
//     (dbAlias)->(dbGoTop())
//     do while !(dbAlias)->(EOF())
//       if mem_n_V034 == 0
//          aadd(_arr, { alltrim((dbAlias)->SHOTNAME), (dbAlias)->ID, CToD(''), CToD('') })
//       else
//         aadd(_arr, { alltrim((dbAlias)->FULLNAME), (dbAlias)->ID, CToD(''), CToD('') })
//       endif  
//       (dbAlias)->(dbSkip())
//     enddo
//     (dbAlias)->(dbCloseArea())
//     Select(tmp_select)
//   endif
//   return _arr
