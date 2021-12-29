* 29.12.21 ������ ���ᨢ �� �ࠢ�筨�� ����� V032.xml
function getV032()
  // V032.xml - ���⠭�� �奬� ��祭�� � ��㯯� �९��⮢ (CombTreat)
  //  1 - SCHEDRUG(C) 2 - NAME(C) 3 - SCHEMCOD(C)  4 - DATEBEG(D)  5 - DATEEND(D)
  local dbName := '_mo_v032'
  Local dbAlias := 'V032'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      aadd(_arr, { alltrim((dbName)->SCHEDRUG), alltrim((dbName)->NAME), (dbName)->SCHEMCOD, (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr