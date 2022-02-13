#include 'function.ch'
#include 'chip_mo.ch'

***** 13.02.21
// возвращает массив V018 на указанную дату
function getV018table( dateSl )
  Local dbName, dbAlias := 'V018'
  local tmp_select := select()
  local yearSl := year(dateSl)
  local _arr

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
    tmp_select := select()
    dbName := '_mo_V018'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - IDHVID(C)  2 - HVIDNAME(C)  3 - DATEBEG(D)  4 - DATEEND(D)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if empty((dbAlias)->DATEEND) .or. between(dateSl, (dbAlias)->DATEBEG, (dbAlias)->DATEEND)
        aadd(_arr, { alltrim((dbAlias)->IDHVID), alltrim((dbAlias)->HVIDNAME), ;
                (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      endif
      (dbAlias)->(dbSkip())
    enddo
    asort(_arr,,,{|x,y| x[1] < y[1] })

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    // поместим в ХЭШ-массив
    hV018[yearSl] := _arr
  endif
  if empty(_arr)
    alertx('На дату ' + DToC(dateSl) + ' V018 отсутствуют!')
  endif
  return _arr
