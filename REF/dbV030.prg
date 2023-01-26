#include 'function.ch'

#require 'hbsqlit3'

** 26.01.23 вернуть массив по справочнику ФФОМС V030.xml
function getV030()
  // V030.xml - Схемы лечения заболевания COVID-19 (TreatReg)
  //  1 - SCHEMCOD(C) 2 - SCHEME(C) 3 - DEGREE(N) 4 - COMMENT(M)  5 - DATEBEG(D)  6 - DATEEND(D)
  // local dbName := "_mo_v030"
  // Local dbAlias := 'V030'
  // local tmp_select := select()
  static _arr   // := {}
  static time_load
  local db
  local aTable
  local nI

  // if len(_arr) == 0
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')

    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'schemcode, ' + ;
      'scheme, ' + ;
      'degree, ' + ;
      'comment, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v030')
    // cmdText := 'CREATE TABLE v030(schemcode TEXT(5), scheme TEXT(15), degree INTEGER, comment BLOB, datebeg TEXT(10), dateend TEXT(10))'
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), alltrim(aTable[nI, 1]), ;
            val(aTable[nI, 3]), alltrim(aTable[nI, 4]), ;
            ctod(aTable[nI, 5]), ctod(aTable[nI, 6]) ;
        })
    //   aadd(_arr, { alltrim((dbAlias)->SCHEME), alltrim((dbAlias)->SCHEMCOD), (dbAlias)->DEGREE, alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
    // dbUseArea( .t.,, exe_dir + dbName, dbAlias, .f., .f. )
    // (dbAlias)->(dbGoTop())
    // do while !(dbAlias)->(EOF())
    //   aadd(_arr, { alltrim((dbAlias)->SCHEME), alltrim((dbAlias)->SCHEMCOD), (dbAlias)->DEGREE, alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    //   (dbAlias)->(dbSkip())
    // enddo
    // (dbAlias)->(dbCloseArea())
    // Select(tmp_select)
  endif

  return _arr

****** 11.01.22 вернуть схемы лечения согласно тяжести пациента
function get_schemas_lech(_degree, ldate)
  local _arr := {}, row

  if ValType(_degree) == 'C' .and. empty(_degree)
    return _arr
  endif
  if ValType(_degree) == 'N' .and. _degree == 0
    return _arr
  endif
  for each row in getV030()
    if (row[3] == _degree) .and. between_date(row[5], row[6], ldate)
      aadd(_arr, { row[1], row[2], row[3], row[4], row[5], row[6] })
    endif
  next
  return _arr

***** 07.01.22 вернуть наименование схемы
Function ret_schema_V030(s_code)
  // s_code - код схемы
  Local i, ret := ''
  local code := alltrim(s_code)
  
  if !empty(code) .and. ((i := ascan(getV030(), {|x| x[2] == code })) > 0)
    ret := getV030()[i, 1]
  endif
  return ret
