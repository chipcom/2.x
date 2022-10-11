** 04.10.22 вернуть массив ФФОМС O001.xml
function getO001()
  static _O001 := {}
  Local dbName, dbAlias := 'O001'
  local tmp_select := select()


  // O001.dbf - Общероссийский классификатор стран мира (ОКСМ)
  //  1 - NAME11(C)  2 - KOD(C)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - ALFA2(C)  6 - ALFA3(C)  7 - NAME11(C)
  if len(_O001) == 0
    dbName := '_mo_O001'
    tmp_select := select()
    dbUseArea( .t., 'DBFNTX', exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
        aadd(_O001, { alltrim((dbAlias)->NAME11), (dbAlias)->KOD, (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->ALFA2, (dbAlias)->ALFA3, alltrim((dbAlias)->NAME12) })
        (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _O001

** 04.10.22 вернуть страну
Function getCountry(lstrana)
  Static kod_RF := '643'

  Local s := space(10), i

  if !empty(lstrana) .and. lstrana != kod_RF ;
         .and. (i := ascan(getO001(), {|x| x[2] == lstrana })) > 0
        //  .and. (i := ascan(glob_O001, {|x| x[2] == lstrana })) > 0
    s := getO001()[i, 1]
    // s := glob_O001[i, 1]
  endif
  return s
  
