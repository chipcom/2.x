#include 'hbhash.ch' 
#include 'function.ch'
#include 'chip_mo.ch'
#include 'edit_spr.ch'

#require 'hbsqlit3'

// =========== T005 ===================
//
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

// =========== T007 ===================
//
// 02.06.23 вернуть массив ТФОМС T007.dbf
function loadT007()
  // возвращает массив T007
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // T007 - Перечень
  // PROFIL_K,  N,  2
  // PK_V020,   N,  2
  // PROFIL,    N,  2
  // NAME,      C,  255
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'profil_k, ' + ;
        'pk_v020, ' + ;
        'profil, ' + ;
        'name ' + ;
        'FROM t007')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), val(aTable[nI, 2]), val(aTable[nI, 3]), alltrim(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// 04.06.23 массив T007 для выбора
function arr_t007() 
  static arr
  static time_load
  local arrT007 := loadT007()
  local row

  if timeout_load(@time_load)
    arr := {}
    for each row in arrT007
      if AScan(arr, {|x| x[2] == row[1]}) == 0
        aadd(arr, {alltrim(row[4]), row[1], row[2]})
      endif
    next
  endif
  return arr

// 02.06.23 вернуть массив профилей мед. помощи
Function ret_arr_V002_profil_k_t007(lprofil_k)
  local arrT007 := loadT007()
  local arr := {}, row := {}

  for each row in arrT007
    if row[1] == lprofil_k
      aadd(arr, {inieditspr(A__MENUVERT, getV002(), row[3]), row[3]})
    endif
  next

  return arr

// =========== T008 ===================
//
// 23.10.22 вернуть Коды ошибок в протоколах обработки инф.пакетов T008.xml
function getT008()
  // T008.xml - Коды ошибок в протоколах обработки инф.пакетов
  // 1 - NAME (C), 2 - CODE (N), 3 - NAME_F (C), 4 - DATE_B (D), 5 - DATE_E (D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'Файл уже был загружен', 0, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Файл не соответствует xsd-схеме', 1, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Некорректное сочетание кодов МО (codeM и Mcod)', 2, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Некорректный код профиля', 3, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Некорректный код профиля койки', 4, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Некорректный код диагноза', 5, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Некорректная форма оказания МП (V014)', 6, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Некорректный тип документа (F008)', 7, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Некорректный пол (V005)', 8, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Некорректный реестровый код МО юридического лица', 9, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Некорректный регистрационный код МО по ТФОМС', 10, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Данного направления нет в выписанных', 11, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Некорректный код причины аннулирования', 12, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Некорректный реестровый код СМО', 13, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Профиль койки не соответствует профилю МП', 14, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Некорректная дата госпитализации', 15, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Запись по данному направлению уже была загружена', 16, '', stod('20140701'), stod('22220101')})
    aadd(_arr, {'Отсутствуют сведения о выполненных объемах для СМО', 17, '', stod('20160915'), stod('22220101')})
    aadd(_arr, {'Отчетная дата отлична от текущей', 18, '', stod('20170220'), stod('22220101')})
    aadd(_arr, {'Нарушена уникальность ID_D', 19, '', stod('20180829'), stod('22220101')})
    aadd(_arr, {'Дата в имени файла не соответствует DATE_R', 20, '', stod('20180907'), stod('22220101')})
    aadd(_arr, {'Дата в записи не соответствует DATE_R', 21, '', stod('20180907'), stod('22220101')})
    aadd(_arr, {'Превышен срок действия направления (30 дней)', 22, '', stod('20180907'), stod('22220101')})
    aadd(_arr, {'Ошибка в других записях файла', 999, '', stod('20140701'), stod('22220101')})
  endif

  return _arr

// =========== T012 ===================
//
// 26.12.22 вернуть описание ошибки из Классификатора ошибок ИСОМП ISDErr.xml
function getError_T012(code)
  static arr
  local db
  local aTable
  local nI
  local s := 'ошибка ' + lstr(code) + ': '

  if arr == nil
    arr := hb_hash()
  
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT code, name FROM isderr')
    if len(aTable) > 1
      for nI := 2 to Len(aTable)
        hb_hSet(arr, val(aTable[nI, 1]), alltrim(aTable[nI, 2]))
      next
    endif
    db := nil
  endif

  if hb_hHaskey(arr, code) 
    s += alltrim(arr[code])
  else
    s += '(неизвестная ошибка)'
  endif

  return s