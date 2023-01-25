#include 'function.ch'
#include 'chip_mo.ch'

** 25.01.23
// возвращает массив V018 на указанную дату
function getV018( dateSl )
  // Local dbName, dbAlias := 'V018'
  // local tmp_select := select()
  local yearSl := year(dateSl)
  local _arr
  local db
  local aTable, stmt
  local nI

  static hV018, lHashV018 := .f.

  // при отсутствии ХЭШ-массива создадим его
  if !lHashV018
    hV018 := hb_Hash()
    lHashV018 := .t.
  endif

  // получим массив V018 из хэша по ключу ГОД ОКОНЧАНИЯ СЛУЧАЯ, или загрузим его из справочника
  if hb_HHasKey( hV018, yearSl )
    _arr := hb_HGet(hV018, yearSl)
  else
    _arr := {}

    db := openSQL_DB()
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'idhvid, ' + ;
      'hvidname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v018')

    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        if (year(ctod(aTable[nI, 3])) <= yearSl) .and. (empty(ctod(aTable[nI, 4])) .or. year(ctod(aTable[nI, 4])) >= yearSl)   // только если поле окончания действия пусто
          aadd(_arr, { alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
        endif
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
    asort(_arr,,,{|x,y| x[1] < y[1] })

    // tmp_select := select()
    // dbName := '_mo_V018'
    // dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    // //  1 - IDHVID(C)  2 - HVIDNAME(C)  3 - DATEBEG(D)  4 - DATEEND(D)
    // (dbAlias)->(dbGoTop())
    // do while !(dbAlias)->(EOF())
    //   if empty((dbAlias)->DATEEND) .or. between(dateSl, (dbAlias)->DATEBEG, (dbAlias)->DATEEND)
    //     aadd(_arr, { alltrim((dbAlias)->IDHVID), alltrim((dbAlias)->HVIDNAME), ;
    //             (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
    //   endif
    //   (dbAlias)->(dbSkip())
    // enddo
    // (dbAlias)->(dbCloseArea())
    // Select(tmp_select)
    // поместим в ХЭШ-массив
    hV018[yearSl] := _arr

  endif
  if empty(_arr)
    alertx('На дату ' + DToC(dateSl) + ' V018 отсутствуют!')
  endif
  return _arr
