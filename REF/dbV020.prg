#include 'function.ch'

#require 'hbsqlit3'

** 26.01.23 вернуть массив по справочнику ФФОМС V020.xml - Классификатор профилей койки
function getV020()
  // Local dbName, dbAlias := 'V020'
  // local tmp_select := select()
  static _arr   //:= {}
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
      'idk_pr, ' + ;
      'k_prname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v020')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), ;
            ctod(aTable[nI, 3]), ctod(aTable[nI, 4]) ;
        })
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
    // tmp_select := select()
    // dbName := '_mo_v020'
    // dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    // //  1 - K_PRNAME(C)  2 - IDK_PR(N)  3 - DATEBEG(D)  4 - DATEEND(D)
    // (dbAlias)->(dbGoTop())
    // do while !(dbAlias)->(EOF())
    //   aadd(_arr, { alltrim((dbAlias)->K_PRNAME), (dbAlias)->IDK_PR, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    //   (dbAlias)->(dbSkip())
    // enddo

    // (dbAlias)->(dbCloseArea())
    // Select(tmp_select)
  endif

  return _arr