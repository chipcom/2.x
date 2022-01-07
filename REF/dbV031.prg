* 29.12.21 вернуть массив по справочнику ФФОМС V031.xml
function getV031()
  // V031.xml - Группы препаратов для лечения заболевания COVID-19 (GroupDrugs)
  //  1 - DRUGCODE(N) 2 - DRUGGRUP(C) 3 - INDMNN(N)  4 - DATEBEG(D)  5 - DATEEND(D)
  local dbName := "_mo_v031"
  Local dbAlias := 'V031'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      aadd(_arr, { (dbName)->DRUGCODE, alltrim((dbName)->DRUGGRUP), (dbName)->INDMNN, (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

****** 07.01.22 вернуть группу препаратов
function get_group_prep_by_kod(_code, ldate)
  local _arr, row, code

  if ValType(_code) == 'C'
    code := val(_code)
  elseif ValType(_code) == 'N'
    code := _code
  else
    return _arr
  endif
    
  for each row in getV031()
    if (row[1] == code) .and. between_date(row[4], row[5], ldate)
      _arr := { row[1], row[2], row[3], row[4], row[5] }
    endif
  next
  return _arr