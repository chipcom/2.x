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
        aadd( arr, { alltrim( aTable[ nI, 2 ] ), val( aTable[ nI, 1 ] ), 0d20260101, 0d22221231 } )
      next
    endif
    db := nil
  endif

  return arr

// 02.02.26 соответствие профиля МЗ РФ профилю из V002
function soot_v002_m003( profil )

  static hArray

  local retM003 := 0

  if hArray == nil
    hArray := hb_Hash()
    hb_HSet( hArray, 3, 1 )
    hb_HSet( hArray, 4, 3 )
    hb_HSet( hArray, 5, 4 )
    hb_HSet( hArray, 11, 5 )
    hb_HSet( hArray, 12, 6 )
    hb_HSet( hArray, 14, 7 )
    hb_HSet( hArray, 16, 8 )
    hb_HSet( hArray, 17, 9 )
    hb_HSet( hArray, 18, 10 )
    hb_HSet( hArray, 19, 11 )
    hb_HSet( hArray, 20, 12 )
    hb_HSet( hArray, 21, 13 )
    hb_HSet( hArray, 23, 50 )
    hb_HSet( hArray, 28, 14 )
    hb_HSet( hArray, 29, 15 )
    hb_HSet( hArray, 30, 16 )
    hb_HSet( hArray, 36, 51 )
    hb_HSet( hArray, 41, 53 )
    hb_HSet( hArray, 43, 54 )
    hb_HSet( hArray, 53, 18 )
    hb_HSet( hArray, 54, 19 )
    hb_HSet( hArray, 55, 20 )
    hb_HSet( hArray, 56, 21 )
    hb_HSet( hArray, 60, 22 )
    hb_HSet( hArray, 65, 24 )
    hb_HSet( hArray, 68, 26 )
    hb_HSet( hArray, 71, 28 )
    hb_HSet( hArray, 73, 30 )
    hb_HSet( hArray, 75, 31 )
    hb_HSet( hArray, 76, 32 )
    hb_HSet( hArray, 77, 33 )
    hb_HSet( hArray, 81, 34 )
    hb_HSet( hArray, 84, 35 )
    hb_HSet( hArray, 85, 57 )
    hb_HSet( hArray, 86, 36 )
    hb_HSet( hArray, 87, 36 )
    hb_HSet( hArray, 87, 36 )
    hb_HSet( hArray, 88, 36 )
    hb_HSet( hArray, 89, 36 )
    hb_HSet( hArray, 90, 36 )
    hb_HSet( hArray, 96, 23 )
    hb_HSet( hArray, 97, 37 )
    hb_HSet( hArray, 98, 38 )
    hb_HSet( hArray, 99, 39 )
    hb_HSet( hArray, 100, 40 )
    hb_HSet( hArray, 105, 58 )
    hb_HSet( hArray, 108, 42 )
    hb_HSet( hArray, 110, 43 )
    hb_HSet( hArray, 112, 44 )
    hb_HSet( hArray, 114, 46 )
    hb_HSet( hArray, 116, 48 )
    hb_HSet( hArray, 122, 49 )
    hb_HSet( hArray, 136, 2 )
    hb_HSet( hArray, 137, 2 )
    hb_HSet( hArray, 146, 52 )
    hb_HSet( hArray, 147, 53 )
    hb_HSet( hArray, 158, 17 )
    hb_HSet( hArray, 158, 55 )
    hb_HSet( hArray, 163, 23 )
    hb_HSet( hArray, 164, 27 )
    hb_HSet( hArray, 166, 32 )
    hb_HSet( hArray, 167, 4 )
    hb_HSet( hArray, 171, 57 )
    hb_HSet( hArray, 171, 57 )
    hb_HSet( hArray, 177, 41 )
    hb_HSet( hArray, 179, 47 )
    hb_HSet( hArray, 184, 2 )
    hb_HSet( hArray, 185, 56 )
  Endif
  if hb_hHaskey( hArray, profil )
    retM003 := hArray[ profil ]
  endif

  return retM003