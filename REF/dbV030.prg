* 04.01.22 вернуть массив по справочнику ФФОМС V030.xml
function getV030()
  // V030.xml - Схемы лечения заболевания COVID-19 (TreatReg)
  //  1 - SCHEMCOD(C) 2 - SCHEME(C) 3 - DEGREE(N) 4 - COMMENT(M)  5 - DATEBEG(D)  6 - DATEEND(D)
  local dbName := "_mo_v030"
  Local dbAlias := 'V030'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      aadd(_arr, { alltrim((dbName)->SCHEME), alltrim((dbName)->SCHEMCOD), (dbName)->DEGREE, alltrim((dbName)->COMMENT), (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

****** 04.01.22 вернуть схемы лечения согласно тяжести пациента
function get_schemas_lech(_degree, ldate)
  local _arr := {}, row

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
