#include 'function.ch'
#include 'chip_mo.ch'

***** 13.02.21
// возвращает массив V019
function getV019table( dateSl )
  Local dbName, dbAlias := 'V019'
  local tmp_select := select()
  local yearSl := year(dateSl)
  local _arr

  static hV019, lHashV019 := .f.

  // при отсутствии ХЭШ-массива создадим его
  if !lHashV019
    hV019 := hb_Hash()
    lHashV019 := .t.
  endif

  // получим массив V019 из хэша по ключу ГОД ОКОНЧАНИЯ СЛУЧАЯ, или загрузим его из справочника
  if hb_HHasKey( hV019, yearSl )
    _arr := hb_HGet(hV019, yearSl)
  else
    _arr := {}
    tmp_select := select()
    dbName := '_mo_V019'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - IDHM(N)  2 - HMNAME(C)  3 - DIAG(M)  4 - HVID(C)  5 - DATEBEG(D)  6 - DATEEND(D)  7 - HGR(N)  8 - IDMODP(N)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if empty((dbAlias)->DATEEND) .or. between(dateSl, (dbAlias)->DATEBEG, (dbAlias)->DATEEND)
        aadd(_arr, { (dbAlias)->IDHM, alltrim((dbAlias)->HMNAME), aclone(Split(alltrim((dbAlias)->DIAG), ', ')), ;
            alltrim((dbAlias)->HVID), (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->HGR, (dbAlias)->IDMODP })
      endif
      (dbAlias)->(dbSkip())
    enddo
    asort(_arr,,,{|x,y| x[1] < y[1] })
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    // поместим в ХЭШ-массив
    hV019[yearSl] := _arr
  endif
  if empty(_arr)
    alertx('На дату ' + DToC(dateSl) + ' V019 отсутствуют!')
  endif
  return _arr
