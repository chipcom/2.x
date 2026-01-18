#require 'hbsqlit3'

// 08.01.25 вернуть массив по справочнику Минздрава РФ OID 1.2.643.5.1.13.13.99.2.798.xml
function getMzrf798()
  // OID 1.2.643.5.1.13.13.99.2.798.xml - справочник характеристик высвобождения активных веществ из лекарственных препаратов
  //  1 - ID(N) 2 - NAME(C) 3 - NAMEENG(C) 4 - COMMENT(C)
  static _arr := {}
  local dBegin := 0d20220101, dEnd := 0d20241231  // для совместимости
  local cmdText
  local db
  local aTable
  local nI

  if len(_arr) == 0
    db := openSQL_DB()
    cmdText := 'SELECT id, name, nameEng, comment FROM mzrf798'
    aTable := sqlite3_get_table(db, cmdText)
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, { val( aTable[ nI, 1 ] ), alltrim( aTable[ nI, 2 ] ), ;
            alltrim( aTable[ nI, 3 ] ), alltrim( aTable[ nI, 4 ] ) } )
      next
    endif
    db := nil
  endif
  return _arr

// 08.01.25 вернуть наименование метода введения препарата
Function ret_character_vysv( s_code )
  // s_code - код характеристики

  Local i, ret := ''
  local code
  
  if ValType(s_code) == 'C'
    code := val( s_code )
  elseif ValType( s_code ) == 'N'
    code := s_code
  else
    return ret
  endif

  if !empty( code ) .and. ( ( i := ascan( getMzrf798(), { | x | x[ 1 ] == code } ) ) > 0 )
    ret := getMzrf798()[ i, 2 ]
  endif
  return ret

// 18.01.26  вернуть массив по справочнику Минздрава РФ OID 1.2.643.5.1.13.13.11.1119.xml
function getM003()


  // OID 1.2.643.5.1.13.13.11.1119.xml - Профили медицинской помощи
  //  1 - ID(N) 2 - PROFILE(C)
  local arr := {}
  local cmdText
  local db
  local aTable
  local nI

  if len( arr ) == 0
    db := openSQL_DB()
    cmdText := 'SELECT id, profile FROM m003'
    aTable := sqlite3_get_table(db, cmdText)
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd( arr, { alltrim( aTable[ nI, 2 ] ), val( aTable[ nI, 1 ] ), 0d20260101, 0d20260131 } )
      next
    endif
    db := nil
  endif

  return arr