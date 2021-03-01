* 01.03.21 вернуть массив регионов по справочнику регионов ТФОМС F010.xml
function getf010()
  // F010.xml - Классификатор субъектов Российской Федерации
  //  1 - SUBNAME(C) 2 - KOD_TF(N)  3 - OKRUG(N)  4 - KOD_OKATO(C)  5 - DATEBEG(D)  6 - DATEEND(D)
  local dbName := '_mo_F010'
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      if empty((dbName)->DATEEND)
        aadd(_arr, { (dbName)->SUBNAME, (dbName)->KOD_TF, (dbName)->OKRUG, (dbName)->KOD_OKATO, (dbName)->DATEBEG, (dbName)->DATEEND })
      endif
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    aadd(_arr, {'Федерального подчинения', '99', 0})
    if hb_FileExists(exe_dir + 'f010' + sdbf)
      FErase( exe_dir + 'f010' + sdbf )
    endif

  endif
  return _arr

