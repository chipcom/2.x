** 17.01.23
// вернуть массив по справочнику ФФОМС V025 Классификатор целей посещения (KPC)
function getV025()
  // Local dbName, dbAlias := 'V025'
  // local tmp_select := select()
  static _arr := {}, i
  local db
  local aTable, stmt
  local nI
  
  if len(_arr) == 0
    db := openSQL_DB()
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')

    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'idpc, ' + ;
      'n_pc, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v025')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 1]) + '-' + alltrim(aTable[nI, 2]), nI - 1, alltrim(aTable[nI, 1]), ;
            ctod(aTable[nI, 3]), ctod(aTable[nI, 4]) ;
        })
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
    // tmp_select := select()
    // dbName := '_mo_v025'
    // dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    // i := 0
    // //  1 - IDPC(C)  2 - N_PC(C)  3 - DATEBEG(D)  4 - DATEEND(D)
    // (dbAlias)->(dbGoTop())
    // do while !(dbAlias)->(EOF())
    //   ++i
    //   aadd(_arr, { alltrim((dbAlias)->IDPC) + '-' + alltrim((dbAlias)->N_PC), i, alltrim((dbAlias)->IDPC), (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    //   (dbAlias)->(dbSkip())
    // enddo

    // (dbAlias)->(dbCloseArea())
    // Select(tmp_select)
  endif
  return _arr

function get_IDPC_from_V025_by_number(num)
  local tableV025 := getV025()
  local row
  local retIDPC := ''

  for each row in tableV025
    if row[2] == num
      retIDPC := row[3]
      exit
    endif
  next
  return retIDPC
