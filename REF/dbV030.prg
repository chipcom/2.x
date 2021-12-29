* 29.12.21 вернуть массив по справочнику ФФОМС V030.xml
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
      aadd(_arr, { alltrim((dbName)->SCHEMCOD), alltrim((dbName)->SCHEME), (dbName)->DEGREE, alltrim((dbName)->COMMENT), (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

