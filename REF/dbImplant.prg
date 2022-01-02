* 02.01.22 вернуть массив по справочнику Минздрава по имплантантам OID 1.2.643.5.1.13.13.11.1079.xml
function get_implant()
  Local dbName, dbAlias := 'impl'
  local tmp_select := select()
  static _arr := {}


  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_impl'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - ID(N)  2 - RZN(N) 3 - PARENT(N) 4 - NAME(C) 5 - LOCAl(C) 6 - MATERIAL(C) 7 - METAL(L)  8 - ORDER(N)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(_arr, { alltrim((dbAlias)->NAME), (dbAlias)->RZN, (dbAlias)->ID, (dbAlias)->PARENT, alltrim((dbAlias)->LOCAL), alltrim((dbAlias)->MATERIAL), (dbAlias)->METAL, (dbAlias)->ORDER })
      (dbAlias)->(dbSkip())
    enddo

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr