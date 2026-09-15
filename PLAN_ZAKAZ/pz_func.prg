#include 'hbhash.ch' 
#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 10.03.24
function get_unit_uslugi( lshifr, ldate_usl )

  Local tmp_select := Select(), fl := .f.
  Local lal := 'lusl', y := WORK_YEAR
  local nUnit := 0, i := 0, strUnit := ''
  local arrPZ := get_array_PZ( year( ldate_usl ) )

  y := Year( ldate_usl )
  If Select( 'LUSL' ) == 0
    use_base( 'lusl' )
  Endif

  lal := create_name_alias( lal, y )
  dbSelectArea( lal )
  find ( PadR( lshifr, 10 ) )
  If Found()
    nUnit := &lal.->unit_code
  endif
  Select ( tmp_select )
  if ( i := ascan(arrPZ, { | x | x[ 2 ] == nUnit } ) ) > 0
    strUnit := left( arrPZ[ i, 4 ], 16 )
  endif

  return strUnit

// 18.03.25
Function arr_plan_zakaz( ly )

  Local i, apz := {}
  local nameArr

  DEFAULT ly TO WORK_YEAR
  nameArr := get_array_PZ( ly )
  for i := 1 to len( nameArr )
    aadd( apz, { nameArr[ i, 3 ], ;
                nameArr[ i, 1 ], ;
                0, ;
                nameArr[ i, 4 ], ;
                nameArr[ i, 5 ], ;
                { } ;
              } )
  next
  return apz

// 15.09.26 по шифру услуги у году вернуть номер элемента массива 'arr_plan_zakaz' для года
Function f_arr_plan_zakaz( lshifr, lyear )

  Local i := 0
  local sAlias
  local arrPZ, iFind
  local k := 0


  if select( 'LUSL' ) == 0
    Use_base( 'lusl' )
  endif
  arrPZ := get_array_PZ( lyear )
  sAlias := create_name_alias( 'LUSL', lyear )
  select ( sAlias )
//  find ( padr( lshifr, 10 ) )
  ( sAlias )->( dbSeek( padr( lshifr, 10 ) ) )
  if ( sAlias )->( found() ) .and. ! empty( ( sAlias )->unit_code )
    if ( iFind := AScan( arrPZ, { | x | x[ 2 ] == ( sAlias )->unit_code } ) ) > 0
      i := arrPZ[ iFind, PZ_ARRAY_ID ]
    endif
  endif

  return i

// 15.09.26 вернуть код план-заказа по методу ВМП
Function ret_PZ_VMP( lunit, kDate )

  Local arr, i
  Local mpztip := 0
  local nYear := WORK_YEAR

  hb_default( @kDate, WORK_YEAR )

  if valtype( kDate ) == 'D'
    nYear := year( kDate )
  elseif valtype( kDate ) == 'N' .and. kDate >= BEGIN_YEAR
    nYear := kDate
  endif

  arr := get_array_PZ( nYear )
  if ( i := hb_AScan( arr, { | x | x[ 2 ] == lunit } ) ) > 0
    mpztip := arr[ i, 1 ]
  endif

  return mpztip
