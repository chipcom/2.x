* 07.01.22 вернуть массив по справочнику ФФОМС V032.xml
function getV032()
  // V032.xml - Сочетание схемы лечения и группы препаратов (CombTreat)
  //  1 - SCHEDRUG(C) 2 - NAME(C) 3 - SCHEMCOD(C)  4 - DATEBEG(D)  5 - DATEEND(D)
  local dbName := '_mo_v032'
  Local dbAlias := 'V032'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t., , exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      aadd(_arr, { alltrim((dbName)->NAME), alltrim((dbName)->SCHEDRUG), alltrim((dbName)->SCHEMCOD), (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

****** 04.01.22 вернуть сочетание схемы и группы препаратов
function get_group_by_schema_lech(_scheme, ldate)
  local _arr := {}, row

  for each row in getV032()
    if (row[3] == alltrim(_scheme)) .and. between_date(row[4], row[5], ldate)
      aadd(_arr, { row[1], row[2], row[3], row[4], row[5] })
    endif
  next
  return _arr

***** 08.01.22 вернуть наименование кода схемы
Function ret_schema_V032(s_code)
  // s_code - код схемы
  Local i, ret := ''
  local code := alltrim(s_code)
  
  if !empty(code) .and. ((i := ascan(getV032(), {|x| x[3] == code })) > 0)
    ret := getV032()[i, 1]
  endif
  return ret
