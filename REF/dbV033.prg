* 29.12.21 ������ ���ᨢ �� �ࠢ�筨�� ����� V033.xml
function getV033()
  // V033.xml - ���⢥��⢨� ���� �९��� �奬� ��祭�� (DgTreatReg)
  //  1 - SCHEDRUG(C) 2 - DRUGCODE(C)  3 - DATEBEG(D)  4 - DATEEND(D)
  local dbName := '_mo_v033'
  Local dbAlias := 'V033'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      aadd(_arr, { alltrim((dbName)->SCHEDRUG), alltrim((dbName)->DRUGCODE), (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr