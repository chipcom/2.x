* 29.12.21 вернуть массив по справочнику ФФОМС V036.xml
function getV036()
  // V036.xml - Перечень услуг, требующих имплантацию медицинских изделий (ServImplDv)
  //  1 - S_CODE(C) 2 - NAME(C) 3 - PARAM(N) 4 - COMMENT(C) 5 - DATEBEG(D) 6 - DATEEND(D)
  local dbName := '_mo_v036'
  Local dbAlias := 'V036'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbAlias, .f., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(_arr, { alltrim((dbAlias)->S_CODE), alltrim((dbAlias)->NAME), (dbAlias)->PARAM, alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr
