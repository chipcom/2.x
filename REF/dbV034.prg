* 07.01.22 вернуть массив по справочнику ФФОМС V034.xml
function getV034()
  // V034.xml - Единицы измерения (UnitMeas)
  //  1 - UNITCODE(N) 2 - UNITMEAS(C) 3 - SHORTTIT(C)  4 - DATEBEG(D)  5 - DATEEND(D)
  local dbName := '_mo_v034'
  Local dbAlias := 'V034'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      aadd(_arr, { alltrim((dbName)->SHORTTIT), (dbName)->UNITCODE, alltrim((dbName)->UNITMEAS), (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr