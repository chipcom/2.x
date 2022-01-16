* 29.12.21 вернуть массив по справочнику ФФОМС V033.xml
function getV033()
  // V033.xml - Соответствие кода препарата схеме лечения (DgTreatReg)
  //  1 - SCHEDRUG(C) 2 - DRUGCODE(C)  3 - DATEBEG(D)  4 - DATEEND(D)
  local dbName := '_mo_v033'
  Local dbAlias := 'V033'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbAlias, .f., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(_arr, { alltrim((dbAlias)->SCHEDRUG), alltrim((dbAlias)->DRUGCODE), (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

****** 04.01.22 вернуть соответствие кода препарата схеме лечения
function get_drugcode_by_schema_lech(_schemeDrug, ldate)
  local _arr := {}, row

  for each row in getV033()
    if (row[1] == alltrim(_schemeDrug)) .and. between_date(row[3], row[4], ldate)
      aadd(_arr, { row[1], row[2], row[3], row[4] })
    endif
  next
  return _arr