#include 'function.ch'

#require 'hbsqlit3'

** 26.01.23
// возвращает массив V022
function getV022()
  // Local dbName, dbAlias := 'V022'
  // local tmp_select := select()
  static _arr   // := {}
  static time_load
  local db
  local aTable, stmt
  local nI
  
  // if len(_arr) == 0
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
    // tmp_select := select()
    // dbName := '_mo_V022'
    // dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    // // 1 - IDMPAC(N)  2 - MPACNAME(C)  3 - DATEBEG(D)  4 - DATEEND(D)
    // (dbAlias)->(dbGoTop())
    // do while !(dbAlias)->(EOF())
    //   aadd(_arr, { (dbAlias)->IDMPAC, alltrim((dbAlias)->MPACNAME), (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    //   (dbAlias)->(dbSkip())
    // enddo

    // (dbAlias)->(dbCloseArea())
    // Select(tmp_select)
    asort(_arr, , , {|x, y| x[1] < y[1] })
  endif
  return _arr

***** 11.02.21 вернуть строку модели пациента ВМП
Function ret_V022(idmpac,lk_data)
  Local i, s := space(10)
  local aV022 := getV022()

  // make_V018_V019(lk_data)
  if !empty(idmpac) .and. ((i := ascan(aV022, {|x| x[1] == idmpac })) > 0)
    s := aV022[i,2]
  endif
  return s

***** 11.02.21 действия в ответ на выбор в меню "Вид модели пациента ВМП"
// Function f_valid_mmodpac(get,old)
//   if empty(m1modpac)
//     mmodpac := space(67) ; m1modpac := 0
//     update_get("mmodpac")
//   elseif !(m1modpac == old) .and. old != NIL .and. get != NIL
//     mmodpac := space(67) ; m1modpac := 0
//     update_get("mmodpac")
//   endif
//   return .t.
