#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// 19.05.23 вернуть массив ошибок ТФОМС T005.dbf
function loadT005()
  // возвращает массив ошибок T005
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // T005 - Перечень ошибок ТФОМС
  //  1 - code(3)  2 - error(C) 3 - opis(M)
  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'code, ' + ;
        'error, ' + ;
        'opis ' + ;
        'FROM t005')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil

    // добавим из справочника _mo_f014.dbf
    for each row in getF014()
      if (j := ascan(_arr, {|x| x[1] == row[1] })) == 0
        AAdd(_arr, {row[1], alltrim(row[2]), alltrim(row[3])} )
      endif
    next
  endif
  return _arr

// 04.08.21 вернуть строку для кода дефекта с описанием ошибки ТФОМС из справочника T005.dbf
Function ret_t005(lkod)
  local arrErrors := loadT005()
  local row := {}

  for each row in arrErrors
    if row[1] == lkod
      return '(' + lstr(row[1]) + ') ' + row[2] + ', [' + row[3] + ']'
    endif
  next

  return 'Неизвестная категория проверки с идентификатором: ' + str(lkod)

// 28.06.22 вернуть строку для кода дефекта с описанием ошибки ТФОМС из справочника T005.dbf
Function ret_t005_smol(lkod)
  local arrErrors := loadT005()
  local row := {}

  for each row in arrErrors
    if row[1] == lkod
      return '(' + lstr(row[1]) + ') ' + row[2] 
    endif
  next

  return 'Неизвестная категория проверки с идентификатором: ' + str(lkod)

// 05.08.21 вернуть массив описателя ошибки для кода дефекта с описанием ошибки ТФОМС из справочника T005.dbf
Function retArr_t005(lkod, isEmpty)
  local arrErrors := loadT005()
  local row := {}
  default isEmpty to .f.
   for each row in arrErrors
    if row[1] == lkod
      return row
    endif
  next

  return iif(isEmpty, {}, {'Неизвестная категория проверки с идентификатором: ' + str(lkod), '', ''})
