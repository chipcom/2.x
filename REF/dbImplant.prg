#require 'hbsqlit3'

// 08.01.25 вернуть массив по справочнику Минздрава по имплантантам OID 1.2.643.5.1.13.13.11.1079.xml
function get_implantant()
  static _arr := {}
  local dBegin := 0d20220101, dEnd := 0d22221231  // для совместимости
  local db
  local aTable
  local nI

  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
    'id, ' + ;
    'rzn, ' + ;
    'parent, ' + ;
    'name, ' + ;
    'type ' + ;
    'FROM implantant WHERE rzn <> 0')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {str(val(aTable[nI, 2]), 6) + ' ' + alltrim(aTable[nI, 4]), val(aTable[nI, 2]), ;
          dBegin, dEnd, val(aTable[nI, 1]), val(aTable[nI, 3]), alltrim(aTable[nI, 5])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    asort(_arr,,,{|x, y| x[1] < y[1] })
  endif

  return _arr