* 04.02.22 вернуть массив по справочнику Минздрава по имплантантам OID 1.2.643.5.1.13.13.11.1079.xml
function get_implantant()
  Local dbName, dbAlias := 'impl'
  local tmp_select := select()
  static _arr := {}
  local dBegin := 0d20220101, dEnd := 0d20241231  // для совместимости
  // local db
  // local aTable
  // local nI

  if len(_arr) == 0
    // Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    // db := openSQL_DB()
    // aTable := sqlite3_get_table(db, 'SELECT ' + ;
    // 'id, ' + ;
    // 'rzn, ' + ;
    // 'parent, ' + ;
    // 'name, ' + ;
    // 'local, ' + ;
    // 'material, ' + ;
    // '_order, ' + ;
    // 'type ' + ;
    // 'FROM implantant')
    // if len(aTable) > 1
    //   for nI := 2 to Len( aTable )
    //     aadd(_arr, {str(aTable[nI, 2], 6) + ' ' + alltrim(aTable[nI, 4]), val(aTable[nI, 2]), dBegin, dEnd, val(aTable[nI, 1]), val(aTable[nI, 3]), ;
    //       alltrim(aTable[nI, 5]), alltrim(aTable[nI, 6]), val(aTable[nI, 7])})
    //   next
    // endif
    // db := nil
    // Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    // asort(_arr,,,{|x, y| x[1] < y[1] })
    tmp_select := select()
    dbName := '_mo_impl'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - ID(N)  2 - RZN(N) 3 - PARENT(N) 4 - NAME(C) 5 - LOCAl(C) 6 - MATERIAL(C) 7 - METAL(L)  8 - ORDER(N)  9 - TYPE(C)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if (dbAlias)->TYPE == 'L'
        aadd(_arr, { str((dbAlias)->RZN, 6) + ' ' + alltrim((dbAlias)->NAME), (dbAlias)->RZN, dBegin, dEnd, (dbAlias)->ID, (dbAlias)->PARENT, alltrim((dbAlias)->LOCAL), alltrim((dbAlias)->MATERIAL), (dbAlias)->METAL, (dbAlias)->ORDER })
      endif
      (dbAlias)->(dbSkip())
    enddo
    
    asort(_arr,,,{|x, y| x[1] < y[1] })

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr