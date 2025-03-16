#require 'hbsqlit3'

// 12.05.22 вернуть массив ФФОМС O001.xml
function getO001()
  // O001 - Общероссийский классификатор стран мира (ОКСМ)
  // KOD,     "C",    3,      0 // Цифровой код
  // NAME11,  "C",  250,      0 // наименование
  // NAME12", "C",  250,      0 // продолжение наименования
  // ALFA2,   "C",    2,      0 // Буквенный код альфа-2
  // ALFA3,   "C",    3,      0 // Буквенный код альфа-3

  static _O001 := {}
  local db
  local aTable
  local nI

  if len(_O001) == 0
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT name11, kod, alfa2, alfa3, name12 FROM o001')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_O001, {alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), aTable[nI, 3], aTable[nI, 4], alltrim(aTable[nI, 5])})
      next
    endif
    db := nil
  endif
  return _O001

// 01.11.22 вернуть страну
Function getCountry(lstrana)
  
  Static kod_RF := '643'

  Local s := space(10), i

  if !empty(lstrana) .and. lstrana != kod_RF ;
         .and. (i := ascan(getO001(), {|x| x[2] == lstrana })) > 0
    s := getO001()[i, 1]
  endif
  return s