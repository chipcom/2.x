
* 06.04.21 вернуть массив ошибок ТФОМС T005.dbf
function loadT005()
  // возвращает массив
  static _T005 := {}
  Local dbName, dbAlias := 'T005'
  local tmp_select := select()
  local row

  // T005.dbf - Перечень ошибок ТФОМС
  //  1 - KOD(3)  2 - NAME(C) 3 - OPIS(M)
  if len(_T005) == 0
    dbName := '_mo_T005'
    tmp_select := select()
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      AAdd(_T005, {(dbAlias)->KOD, alltrim((dbAlias)->NAME), alltrim((dbAlias)->OPIS)} )

      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  for each row in getF014()
    if (j := ascan(_T005, {|x| x[1] == row[1] })) == 0
      AAdd(_T005, {row[1], row[2], row[3]} )
    endif
  next

  return _T005

* 06.04.21 вернуть строку для кода дефекта с описанием ошибки ТФОМС из справочника T005.dbf
Function ret_t005(lkod)
  local arrErrors := loadT005()
  local row := {}

  for each row in arrErrors
    if row[1] == lkod
      return row[2]
    endif
  next

  return 'Неизвестная категория проверки с идентификатором: ' + str(lkod)

* 06.04.21 вернуть массив описателя ошибки для кода дефекта с описанием ошибки ТФОМС из справочника T005.dbf
Function retArr_t005(lkod)
  local arrErrors := loadT005()
  local row := {}

  for each row in arrErrors
    if row[1] == lkod
      return row
    endif
  next

  return {'Неизвестная категория проверки с идентификатором: ' + str(lkod), ''}
