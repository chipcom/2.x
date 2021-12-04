***** 04.12.21
// возвращает массив V025
function getV025table()
  Local dbName, dbAlias := 'V025'
  local tmp_select := select()
  static _arr := {}, i
  
  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_v025'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    i := 0
    //  1 - IDPC(C)  2 - N_PC(C)  3 - DATEBEG(D)  4 - DATEEND(D)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      ++i
      aadd(_arr, { alltrim((dbAlias)->IDPC) + '-' + alltrim((dbAlias)->N_PC), i, alltrim((dbAlias)->IDPC), (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _arr

function get_IDPC_from_V025_by_number(num)
  local tableV025 := getV025table()
  local row
  local retIDPC := ''

  for each row in tableV025
    if row[2] == num
      retIDPC := row[3]
      exit
    endif
  next
  return retIDPC
