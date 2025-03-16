#include 'set.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 16.03.25
function get_array_PZ( mYear)

  static hArray
  Local db
  local arr := {}, aTable, nI
  local nameView, strSQL, fl := .f.

  if hArray == nil
    hArray := hb_Hash()
  Endif
  if ! hb_hHaskey( hArray, mYear )
    db := opensql_db()

    nameView := 'PZ_year' + str( mYear, 4 )
    strSQL := 'SELECT id, code, description, short, kd, add_t FROM ' + nameView
    aTable := sqlite3_get_table( db, strSQL )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
//        AAdd( arr, { val( aTable[ nI, 1 ] ), val( aTable[ nI, 2 ] ), alltrim( aTable[ nI, 3 ] ), ;
//          alltrim( aTable[ nI, 4 ] ), alltrim( aTable[ nI, 5 ] ), alltrim( aTable[ nI, 6 ] ) } )
        AAdd( arr, { val( aTable[ nI, PZ_ARRAY_ID ] ), val( aTable[ nI, PZ_ARRAY_CODE ] ), alltrim( aTable[ nI, PZ_ARRAY_NAME ] ), ;
          alltrim( aTable[ nI, PZ_ARRAY_SHORT ] ), alltrim( aTable[ nI, PZ_ARRAY_KD ] ), alltrim( aTable[ nI, PZ_ARRAY_ADD_T ] ) } )
        fl := .t.
      Next
      hb_HSet( hArray, mYear, arr )
    Endif
    db := nil
  else
    fl := .t.
  endif
  if fl
    arr := hArray[ mYear ]
  endif
  return arr

// 16.03.25
FUNCTION initPZarray()

  LOCAL arrPZ
  LOCAL i, nYear, sbase, file_index
  
  FOR nYear := 2018 TO WORK_YEAR
    sbase :=  prefixFileRefName( nYear ) + 'unit'  // справочник на конкретный год
    if exists_file_TFOMS( nYear, 'unit')
      arrPZ := get_array_PZ( nYear )
      file_index := cur_dir() + sbase + sntx
      if hb_FileExists( file_index )
        G_Use( dir_exe() + sbase, cur_dir() + sbase, 'UNIT' )
      else
        G_Use( dir_exe() + sbase, , 'UNIT' )
        index on str( code, 3 ) to ( cur_dir() + sbase )
      endif
      FOR i := 1 TO Len( arrPZ )
//         find ( Str( arrPZ[ i, 2 ], 3 ) )
//        IF Found() .AND. !( unit->pz == arrPZ[ i, 1 ] .AND. unit->ii == i )
        find ( Str( arrPZ[ i, PZ_ARRAY_CODE ], 3 ) )
        IF Found() .AND. !( unit->pz == arrPZ[ i, PZ_ARRAY_ID ] .AND. unit->ii == i )
            G_RLock( forever )
//            unit->pz := arrPZ[ i, 1 ]
            unit->pz := arrPZ[ i, PZ_ARRAY_ID ]
            unit->ii := i
        ENDIF
      NEXT
      unit->( dbCloseArea() )
    endif
   NEXT
   RETURN NIL
