
* 05.04.21 вернуть массив ошибок ТФОМС T005.dbf
function loadT005()
  // возвращает хэш-массив
  // <key> - идентификатор
  // <value> - массив {'наименование ошибки'}
  static _T005 := {}
  Local dbName, dbAlias := 'T005'
  local tmp_select := select()

  // T005.dbf - Перечень ошибок ТФОМС
  //  1 - KOD(3)  2 - NAME(C)
  if len(_T005) == 0
    // _T005 := hb_hash()
    dbName := '_mo_T005'
    tmp_select := select()
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      AAdd(_T005, {(dbAlias)->KOD, alltrim((dbAlias)->NAME)} )

      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _T005

* 05.04.21 вернуть строку для кода дефекта с описанием ошибки ТФОМС из справочника T005.dbf
Function ret_t005(lkod)
  local arrErrors := loadT005()
  local aRet := {}, i


  if (i := hb_ascan(arrErrors, {|x| x[1] == lkod})) > 0
    return arrErrors[i,2]
  endif

  return 'Неизвестная категория проверки с идентификатором: ' + str(lkod)
