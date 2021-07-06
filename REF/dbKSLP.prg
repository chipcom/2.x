#include 'function.ch'

// 06.07.2021
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
    dbName := '_mo' + str((yearSl - 2020),1) + 'kslp'
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
  
// 27.02.2021
// возвращает массив КСЛП на указанную дату
function getKSLPtable__( dateSl )
  Local dbName, dbAlias := 'KSLP_'
  local tmp_select := select()
  local tmpKSLP := {}
  
  // static aKSLP, loadKSLP := .f.
  
  // if loadKSLP //если массив КСЛП существует вернем его
  //   if (iy := ascan(aKSLP, {|x| x[1] == Year(dateSl) })) > 0 // год
  //     return aKSLP[ iy, 2 ]
  //   endif
  // endif
  
  if year(dateSl) == 2021 // КСЛП на 2021 год
    tmp_select := select()
    // aKSLP := {}
    dbName := '_mo1kslp'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )
  
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if between(dateSl, (dbAlias)->DATEBEG, (dbAlias)->DATEEND)
      // if (dateSl >= (dbAlias)->DATEBEG) .and. (dateSl <= (dbAlias)->DATEEND)
        aadd(tmpKSLP, { (dbAlias)->CODE, alltrim((dbAlias)->NAME), alltrim((dbAlias)->NAME_F), (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      endif
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    // aadd(aKSLP, { Year(dateSl), tmpKSLP })
    // loadKSLP := .t.
  else
    alertx('На дату ' + DToC(dateSl) + ' КСЛП отсутствуют!')
  endif
  return tmpKSLP