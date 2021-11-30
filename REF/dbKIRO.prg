#include 'function.ch'
#include 'chip_mo.ch'

***** 30.11.21
// возвращает массив КИРО на указанную дату
function getKIROtable( dateSl )
  Local dbName, dbAlias := 'KIRO_'
  local tmp_select := select()
  local retKIRO := {}
  local aKIRO, row
  local yearSl := year(dateSl)

  static hKIRO, lHashKIRO := .f.

  // при отсутствии ХЭШ-массива создадим его
  if !lHashKIRO
    hKIRO := hb_Hash()
    lHashKIRO := .t.
  endif

  // получим массив КИРО из хэша по ключу ГОД ОКОНЧАНИЯ СЛУЧАЯ, или загрузим его из справочника
  if hb_HHasKey( hKIRO, yearSl )
    aKIRO := hb_HGet(hKIRO, yearSl)
  else
    aKIRO := {}
    tmp_select := select()
    dbName := prefixFileRefName(dateSl) + 'kiro'

    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(aKIRO, { (dbAlias)->CODE, alltrim((dbAlias)->NAME), alltrim((dbAlias)->NAME_F), (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())

    Select(tmp_select)
    // поместим в ХЭШ-массив
    hKIRO[yearSl] := aKIRO
  endif

  // выберем возможные КИРО по дате
  for each row in aKIRO
    if between(dateSl, row[5], row[6])
      aadd(retKIRO, { row[1], row[2], row[3], row[4], row[5], row[6] })
    endif
  next

  if empty(retKIRO)
    alertx('На дату ' + DToC(dateSl) + ' КИРО отсутствуют!')
  endif

  return retKIRO