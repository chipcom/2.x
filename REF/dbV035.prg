* 29.12.21 вернуть массив по справочнику ФФОМС V035.xml
function getV035()
  // V035.xml - Способы введения (MethIntro)
  //  1 - METHCODE(N) 2 - METHNAME(C) 3 - DATEBEG(D) 4 - DATEEND(D)
  local dbName := '_mo_v035'
  Local dbAlias := 'V035'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      aadd(_arr, { (dbName)->METHCODE, alltrim((dbName)->METHNAME), (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr