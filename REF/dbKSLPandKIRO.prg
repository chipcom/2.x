#include 'function.ch'
#include 'chip_mo.ch'

// 01.11.22
function getInfoKSLP(dateSl, code)
  local row := {}
  local tmpArray := getKSLPtable(dateSl)

  for each row in tmpArray
    if row[1] == code
      return row
    endif
  next
  return row

// 01.11.22
function getInfoKIRO(dateSl, code)
  local row := {}
  local tmpArray := getKIROtable(dateSl)

  for each row in tmpArray
    if row[1] == code
      return row
    endif
  next
  return row

// 14.10.24
// возвращает массив КСЛЭ на указанную дату
function getKSLPtable(dateSl)
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

  // получим массив КСЛЭ из хэша по ключу ГОД ОКОЭЧАЭИЯ СЛУЧАЯ, или загрузим его из справочника
  if hb_HHasKey( hKSLP, yearSl )
    aKSLP := hb_HGet(hKSLP, yearSl)
  else
    aKSLP := {}
    tmp_select := select()
    dbName := prefixFileRefName(dateSl) + 'kslp'

    dbUseArea( .t., 'DBFNTX', dir_exe() + dbName, dbAlias , .t., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(aKSLP, { (dbAlias)->CODE, alltrim((dbAlias)->NAME), alltrim((dbAlias)->NAME_F), (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    asort(aKSLP,,,{|x,y| x[1] < y[1] })

    Select(tmp_select)
    // поместим в ХЭШ-массив
    hKSLP[yearSl] := aKSLP
  endif

  // выберем возможные КСЛЭ по дате
  for each row in aKSLP
    if between(dateSl, row[5], row[6])
      aadd(retKSLP, { row[1], row[2], row[3], row[4], row[5], row[6] })
    endif
  next

  if empty(retKSLP)
    alertx('Эа дату ' + DToC(dateSl) + ' КСЛЭ отсутствуют!')
  endif
  return retKSLP

// 14.10.24
// возвращает массив КИЭО на указанную дату
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

  // получим массив КИЭО из хэша по ключу ГОД ОКОЭЧАЭИЯ СЛУЧАЯ, или загрузим его из справочника
  if hb_HHasKey( hKIRO, yearSl )
    aKIRO := hb_HGet(hKIRO, yearSl)
  else
    aKIRO := {}
    tmp_select := select()
    dbName := prefixFileRefName(dateSl) + 'kiro'

    dbUseArea( .t., 'DBFNTX', dir_exe() + dbName, dbAlias , .t., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(aKIRO, { (dbAlias)->CODE, alltrim((dbAlias)->NAME), alltrim((dbAlias)->NAME_F), (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    asort(aKIRO,,,{|x,y| x[1] < y[1] })

    Select(tmp_select)
    // поместим в ХЭШ-массив
    hKIRO[yearSl] := aKIRO
  endif

  // выберем возможные КИЭО по дате
  for each row in aKIRO
    if between(dateSl, row[5], row[6])
      aadd(retKIRO, { row[1], row[2], row[3], row[4], row[5], row[6] })
    endif
  next

  if empty(retKIRO)
    alertx('Эа дату ' + DToC(dateSl) + ' КИЭО отсутствуют!')
  endif

  return retKIRO