
* 15.02.21 ������ ���ᨢ �� �ࠢ�筨�� ॣ����� ����� V002.xml
function getV002()
  // V002.dbf - �����䨪��� ��䨫�� ��������� ����樭᪮� �����
  //  1 - PRNAME(C)  2 - IDPR(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  local dbName := "_mo_V002"
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      aadd(_arr, { alltrim((dbName)->PRNAME), (dbName)->IDPR, (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
  endif

  return _arr

