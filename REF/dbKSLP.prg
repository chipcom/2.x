#include 'function.ch'
#include 'chip_mo.ch'

// 30.11.21
// возвращает массив КСЛП на указанную дату
function getKSLPtable( dateSl )
  Local dbName, dbAlias := 'KSLP_'
  local tmp_select := select()
  local retKSLP := {}
  local aKSLP, row
  local yearSl := year(dateSl)

  static hKSLP, lHashKSLP := .f.

  // при отсутствии ХЭШ-массива создадим его
  if !lHashKSLP
    hKSLP := hb_Hash()
    lHashKSLP := .t.
  endif

  // получим массив КСЛП из хэша по ключу ГОД ОКОНЧАНИЯ СЛУЧАЯ, или загрузим его из справочника
  if hb_HHasKey( hKSLP, yearSl )
    aKSLP := hb_HGet(hKSLP, yearSl)
  else
    aKSLP := {}
    tmp_select := select()
    dbName := prefixFileRefName(dateSl) + 'kslp'

    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(aKSLP, { (dbAlias)->CODE, alltrim((dbAlias)->NAME), alltrim((dbAlias)->NAME_F), (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())

    Select(tmp_select)
    // поместим в ХЭШ-массив
    hKSLP[yearSl] := aKSLP
  endif

  // выберем возможные КСЛП по дате
  for each row in aKSLP
    if between(dateSl, row[5], row[6])
      aadd(retKSLP, { row[1], row[2], row[3], row[4], row[5], row[6] })
    endif
  next

  if empty(retKSLP)
    alertx('На дату ' + DToC(dateSl) + ' КСЛП отсутствуют!')
  endif
  return retKSLP
