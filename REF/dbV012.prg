#require 'hbsqlit3'

** 06.11.22 вернуть исход заболевания по коду
function getISHOD_V012( ishod )
  local ret := NIL
  local i

  if (i := ascan(getV012(), {|x| x[2] == ishod })) > 0
    ret := getV012()[i,1]
  endif
  return ret

** 18.05.22 вернуть исход заболевания по условию оказания и дате
function getISHOD_usl_date(uslovie, date)
  local ret := {}
  local row

  for each row in getV012()
    if (empty(row[4]) .and. date >= row[3]) .or. between_date(row[3], row[4], date)
      if uslovie == row[5]
        aadd(ret, {row[1], row[2], row[3], row[4], row[5]})
      endif
    endif
  next
  return ret

** 10.01.23 вернуть массив по справочнику ФФОМС V012.xml
function getV012()
  // V012.xml - Классификатор исходов заболевания
  // Local dbName, dbAlias := 'V012'
  // local tmp_select := select()
  local stroke := '', vid := ''
  static _arr := {}
  local db
  local aTable
  local nI

  if len(_arr) == 0
    // tmp_select := select()
    // dbName := '_mo_v012'
    // dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    // //  1 - IZNAME(C)  2 - IDIZ(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DL_USLOV(N)
    // (dbAlias)->(dbGoTop())
    // do while !(dbAlias)->(EOF())
    //   if empty((dbAlias)->DATEEND)  // только если поле окончания действия пусто
    //     if (dbAlias)->DL_USLOV == 1
    //       vid := '/ст-р/'
    //     elseif (dbAlias)->DL_USLOV == 2
    //       vid := '/дн.с/'
    //     elseif (dbAlias)->DL_USLOV == 3
    //       vid := '/п-ка/'
    //     else
    //       vid := '/'
    //     endif
    //     stroke := str((dbAlias)->IDIZ, 3) + vid + alltrim((dbAlias)->IZNAME)
    //     aadd(_arr, { stroke, (dbAlias)->IDIZ, (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->DL_USLOV })
    //   endif
    //   (dbAlias)->(dbSkip())
    // enddo

    // (dbAlias)->(dbCloseArea())
    // Select(tmp_select)
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table( db, "SELECT idiz, izname, dl_uslov, datebeg, dateend FROM v012" )
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        if empty(ctod(aTable[nI, 5]))  // только если поле окончания действия пусто
          if val(aTable[nI, 3]) == 1
            vid := '/ст-р/'
          elseif val(aTable[nI, 3]) == 2
            vid := '/дн.с/'
          elseif val(aTable[nI, 3]) == 3
            vid := '/п-ка/'
          else
            vid := '/'
          endif
          stroke := str(val(aTable[nI, 1]), 3) + vid + alltrim(aTable[nI, 2])
        endif
        aadd(_arr, { stroke, val(aTable[nI, 1]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5]), val(aTable[nI, 3]) })
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr 