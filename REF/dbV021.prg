* 16.02.21 ������ ���ᨢ �� �ࠢ�筨�� ����� V021.xml
function getV021()
  // V021.xml - �����䨪��� ����樭᪨� ᯥ樠�쭮�⥩ (��᫥����)
  //  1 - SPECNAME(C)  2 - IDSPEC(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  local dbName := "_mo_V021"
  local _v021 := {}

  dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
  (dbName)->(dbGoTop())
  do while !(dbName)->(EOF())
      aadd(_v021, { (dbName)->SPECNAME, (dbName)->IDSPEC, (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
  enddo
  (dbName)->(dbCloseArea())

  return _v021

