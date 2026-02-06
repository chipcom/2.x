#include 'function.ch'
#include 'chip_mo.ch'

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

// 06.02.26 соответствие профиля МЗ РФ профилю из V002
function soot_v002_m003( profil, vzros_reb )

  static hArray
  local vzr, retM003

  Default vzros_reb To 0
  if hArray == nil
    hArray := hb_Hash()
    hb_HSet( hArray, StrZero( 3, 4 ), 1 )
    hb_HSet( hArray, StrZero( 4, 4 ), 3 )
    hb_HSet( hArray, StrZero( 5, 4 ), 4 )
    hb_HSet( hArray, StrZero( 11, 4 ), 5 )
    hb_HSet( hArray, StrZero( 12, 4 ), 6 )
    hb_HSet( hArray, StrZero( 14, 4 ), 7 )
    hb_HSet( hArray, StrZero( 16, 4 ), 8 )
    hb_HSet( hArray, StrZero( 17, 4 ), 9 )
    hb_HSet( hArray, StrZero( 18, 4 ), 10 )
    hb_HSet( hArray, StrZero( 19, 4 ), 11 )
    hb_HSet( hArray, StrZero( 20, 4 ), 12 )
    hb_HSet( hArray, StrZero( 21, 4 ), 13 )
    hb_HSet( hArray, StrZero( 23, 4 ), 50 )
    hb_HSet( hArray, StrZero( 28, 4 ), 14 )
    hb_HSet( hArray, StrZero( 29, 4 ), 15 )
    hb_HSet( hArray, StrZero( 30, 4 ), 16 )
    hb_HSet( hArray, StrZero( 36, 4 ), 51 )
    hb_HSet( hArray, StrZero( 41, 4 ), 53 )
    hb_HSet( hArray, StrZero( 43, 4 ), 54 )
    hb_HSet( hArray, StrZero( 53, 4 ), 18 )
    hb_HSet( hArray, StrZero( 54, 4 ), 19 )
    hb_HSet( hArray, StrZero( 55, 4 ), 20 )
    hb_HSet( hArray, StrZero( 56, 4 ), 21 )
    hb_HSet( hArray, StrZero( 60, 4 ), 22 )
    hb_HSet( hArray, StrZero( 65, 4 ), 24 )
    hb_HSet( hArray, StrZero( 68, 4 ), 26 )
    hb_HSet( hArray, StrZero( 71, 4 ), 28 )
    hb_HSet( hArray, StrZero( 73, 4 ), 30 )
    hb_HSet( hArray, StrZero( 75, 4 ), 31 )
    hb_HSet( hArray, StrZero( 76, 4 ), 32 )
    hb_HSet( hArray, StrZero( 77, 4 ), 33 )
    hb_HSet( hArray, StrZero( 81, 4 ), 34 )
    hb_HSet( hArray, StrZero( 84, 4 ), 35 )
    hb_HSet( hArray, StrZero( 85, 4 ), 57 )
    hb_HSet( hArray, StrZero( 86, 4 ), 36 )
    hb_HSet( hArray, StrZero( 87, 4 ), { 57, 36 } )
//    hb_HSet( hArray, StrZero( 87, 4 ), 36 )
    hb_HSet( hArray, StrZero( 88, 4 ), 57 )
    hb_HSet( hArray, StrZero( 89, 4 ), 57 )
    hb_HSet( hArray, StrZero( 90, 4 ), 57 )
    hb_HSet( hArray, StrZero( 96, 4 ), 23 )
    hb_HSet( hArray, StrZero( 97, 4 ), 37 )
    hb_HSet( hArray, StrZero( 98, 4 ), 38 )
    hb_HSet( hArray, StrZero( 99, 4 ), 39 )
    hb_HSet( hArray, StrZero( 100, 4 ), 40 )
    hb_HSet( hArray, StrZero( 105, 4 ), 58 )
    hb_HSet( hArray, StrZero( 108, 4 ), 42 )
    hb_HSet( hArray, StrZero( 110, 4 ), 43 )
    hb_HSet( hArray, StrZero( 112, 4 ), 44 )
    hb_HSet( hArray, StrZero( 114, 4 ), 46 )
    hb_HSet( hArray, StrZero( 116, 4 ), 48 )
    hb_HSet( hArray, StrZero( 122, 4 ), 49 )
    hb_HSet( hArray, StrZero( 136, 4 ), 2 )
    hb_HSet( hArray, StrZero( 137, 4 ), 2 )
    hb_HSet( hArray, StrZero( 146, 4 ), 52 )
    hb_HSet( hArray, StrZero( 147, 4 ), 53 )
    hb_HSet( hArray, StrZero( 158, 4 ), { 17, 55 } )
//    hb_HSet( hArray, StrZero( 158, 4 ), 55 )
    hb_HSet( hArray, StrZero( 163, 4 ), 23 )
    hb_HSet( hArray, StrZero( 164, 4 ), 27 )
    hb_HSet( hArray, StrZero( 166, 4 ), 32 )
    hb_HSet( hArray, StrZero( 167, 4 ), 4 )
    hb_HSet( hArray, StrZero( 171, 4 ), 57 )
    hb_HSet( hArray, StrZero( 177, 4 ), 41 )
    hb_HSet( hArray, StrZero( 179, 4 ), 47 )
    hb_HSet( hArray, StrZero( 184, 4 ), 2 )
    hb_HSet( hArray, StrZero( 185, 4 ), 56 )
  Endif

  retM003 := 0
  vzr := iif( vzros_reb == 0, '0', '1' )
  if hb_hHaskey( hArray, StrZero( profil, 4 ) )
    retM003 := hArray[ StrZero( profil, 4 ) ]
    if ValType( retM003 ) == 'A'
      if vzros_reb == 0
        retM003 := retM003[ 1 ]
      else
        retM003 := retM003[ 2 ]
      endif
    endif
  endif

  return retM003