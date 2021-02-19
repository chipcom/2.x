#include "hbhash.ch" 

* 19.02.21 вернуть массив ФФОМС Q017.xml
function getQ017()
  static _Q017
  Local dbName, dbAlias := 'Q017'
  local tmp_select := select()


  // Q017.dbf - Перечень категорий проверок ФЛК и МЭК (TEST_K)
  //  1 - ID_KTEST(4)  2 - NAM_KTEST(C) 3 - COMMENT(M)  4 - DATEBEG(D)  5 - DATEEND(D)  5 - ALFA2(C)  6 - ALFA3(C)
  if _Q017 == nil
    _Q017 := hb_hash()
    hb_hSet( _Q017, 'Key', {'xValue',1} )      
    dbName := '_mo_Q017'
    tmp_select := select()
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
    // исправить далее
    //     aadd(_Q017, { (dbAlias)->SUBNAME, (dbAlias)->KOD_TF, Val((dbAlias)->OKRUG), (dbAlias)->KOD_OKATO, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    //     (dbAlias)->(dbSkip())
      hb_hSet( _Q017, alltrim((dbAlias)->ID_KTEST), {alltrim((dbAlias)->NAM_KTEST), alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND} )
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)

  endif

  return _Q017
