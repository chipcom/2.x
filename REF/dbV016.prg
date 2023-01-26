#include 'function.ch'
 
#require 'hbsqlit3'

** 26.01.23 вернуть Классификатор видов диспансеризации/профосмотров V016.xml
function getV016()
  // V016.xml - Классификатор видов диспансеризации/профосмотров
  // Local dbName, dbAlias := 'V016'
  // local tmp_select := select()
  static _arr   // := {}
  static time_load
  local ar := {}
  local db
  local aTable
  local nI

  // if len(_arr) == 0
  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT iddt, dtname, rule, datebeg, dateend FROM v016')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        ar := list2Arr(aTable[nI, 3])
        aadd(_arr, {alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), ar, ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil

    // tmp_select := select()
    // dbName := '_mo_v016'
    // dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    // //  1 - IDDT(C)  2 - DTNAME(C)  3 - RULE(C)  4 - DATEBEG(D)  5 - DATEEND(D)
    // (dbAlias)->(dbGoTop())
    // do while !(dbAlias)->(EOF())
    //   ar := list2Arr((dbAlias)->RULE)
    //   aadd(_arr, { (dbAlias)->IDDT, (dbAlias)->DTNAME, ar, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    //   (dbAlias)->(dbSkip())
    // enddo

    // (dbAlias)->(dbCloseArea())
    // Select(tmp_select)

  endif

  return _arr

**** 13.12.21 вернуть описатель типа диспнсеризации по коду
function get_type_DispT(mdate, codeDispT)
  local dispT := Upper(alltrim(codeDispT))
  local _arr := {}, i
  local tmpArr := getV016()
  local lengthArr := len(tmpArr)

  for i := 1 to lengthArr
    if dispT == tmpArr[i, 1] .and. between_date(tmpArr[i, 4], tmpArr[i, 5], mdate)
      aadd(_arr, tmpArr[i, 1])
      aadd(_arr, tmpArr[i, 2])
      aadd(_arr, tmpArr[i, 3])
    endif
  next
  return _arr