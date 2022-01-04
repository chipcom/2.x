* 04.01.22 вернуть массив по справочнику Минздрава по Степень тяжести состояния пациента OID 1.2.643.5.1.13.13.11.1006.xml
function get_severity()
  Local dbName, dbAlias := 'sev'
  local tmp_select := select()
  static _arr := {}


  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_severity'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - ID(N) 2 - NAME(C) 3 - SYN(C) 4 - SCTID(N) 5 - SORT(N)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(_arr, { alltrim((dbAlias)->NAME), (dbAlias)->ID, alltrim((dbAlias)->SYN), (dbAlias)->SCTID, (dbAlias)->SORT })
      (dbAlias)->(dbSkip())
    enddo

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr