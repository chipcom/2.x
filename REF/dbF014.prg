
#include 'function.ch'

* 09.07.21 вернуть массив справочнику ФФОМС F014.xml
function getF014()
  // F014.xml - Классификатор причин отказа в оплате медицинской помощи
  //  1 - Komment(C)  2 - Kod(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - IDVID(N)  6 - Naim(C)  7 - Osn(C)  8 - KodPG(C)

  // возвращает массив
  static _F014 := {}
  Local dbName, dbAlias := 'F014'
  local tmp_select := select()

  // _mo_f014.dbf - Классификатор причин отказа в оплате медицинской помощи
  //  1 - KOD(3)  2 - NAME(C) 3 - OPIS(M) 4 - DATEBEG(D) 5 - DATEEND(D)
  if len(_F014) == 0
    dbName := '_mo_f014'
    tmp_select := select()
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      // if between(sys_date, (dbAlias)->DATEBEG, (dbAlias)->DATEEND)
        AAdd(_F014, {(dbAlias)->KOD, alltrim((dbAlias)->NAME), alltrim((dbAlias)->OPIS)} )
      // endif

      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _F014
