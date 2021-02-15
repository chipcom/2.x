
* 15.02.21 вернуть массив регионов по справочнику регионов ТФОМС F010.xml
function getf010()
  // F010.xml - Классификатор субъектов Российской Федерации
  //  1 - SUBNAME(C) 2 - KOD_TF(N)  3 - OKRUG(N)  4 - KOD_OKATO(C)  5 - DATEBEG(D)  6 - DATEEND(D)
  local dbName := "f010"
  local _f010 := {}

  dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
  (dbName)->(dbGoTop())
  do while !(dbName)->(EOF())
      aadd(_f010, { (dbName)->SUBNAME, (dbName)->KOD_TF, Val((dbName)->OKRUG), (dbName)->KOD_OKATO, (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
  enddo
  (dbName)->(dbCloseArea())
  aadd(_f010, {'Федерального подчинения', '99', 0})

  return _f010

