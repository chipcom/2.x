
* 15.02.21 ������ ���ᨢ ॣ����� �� �ࠢ�筨�� ॣ����� ����� F010.xml
function getf010()
  // F010.xml - �����䨪��� ��ꥪ⮢ ���ᨩ᪮� �����樨
  //  1 - SUBNAME(C) 2 - KOD_TF(N)  3 - OKRUG(N)  4 - KOD_OKATO(C)  5 - DATEBEG(D)  6 - DATEEND(D)
  local dbName := "f010"
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      aadd(_arr, { (dbName)->SUBNAME, (dbName)->KOD_TF, Val((dbName)->OKRUG), (dbName)->KOD_OKATO, (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    aadd(_arr, {'����ࠫ쭮�� ���稭����', '99', 0})
  endif

  return _arr

