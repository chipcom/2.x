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

****** 04.01.22 ������ ᮮ⢥��⢨� ���� �९��� �奬� ��祭��
function get_drugcode_by_schema_lech(_schemeDrug, ldate)
  local _arr := {}, row

  for each row in getV033()
    if (row[1] == alltrim(_schemeDrug)) .and. between_date(row[3], row[4], ldate)
      aadd(_arr, { row[1], row[2], row[3], row[4] })
    endif
  next
  return _arr