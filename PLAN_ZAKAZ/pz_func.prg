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
  local nUnit := 0, i := 0, strUnit := '', aaa
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

// 12.03.25
Function arr_plan_zakaz( ly )
  Local i, apz := {}
  local nameArr //, funcGetPZ
  local aValues

  DEFAULT ly TO WORK_YEAR
  nameArr := get_array_PZ( ly )
  aValues := hb_hValues( getUnitsForYear( ly ) )
  ASort( aValues, , , { | x, y | x[ 1 ] < y[ 1 ] } )
  for i := 1 to len( nameArr )
    aadd( apz, { nameArr[ i, 3 ], ;
                nameArr[ i, 1 ], ;
                0, ;
                nameArr[ i, 4 ], ;  // nameArr[ i, 6 ], ;
                nameArr[ i, 5 ], ;
                { } ;
              } )
  next
  return apz

// 12.03.25 по шифру услуги у году вернуть номер элемента массива 'arr_plan_zakaz' для года
Function f_arr_plan_zakaz( lshifr, lyear )
  Local k := 0, i := 0
  local sbase, sAlias, sAliasUnit
  local nameArrayPZ //, funcGetPZ

  if select( 'LUSL' ) == 0
    Use_base( 'lusl' )
  endif

  sAlias := create_name_alias( 'LUSL', lyear )
  sAliasUnit := create_name_alias( 'MOUNIT', lyear )

  select ( sAlias )
  find ( padr( lshifr, 10 ) )
  if found() .and. ! empty( (sAlias)->unit_code )
    if select( sAliasUnit ) == 0
      sbase := prefixFileRefName( lyear ) + 'unit'
      R_Use( dir_exe() + sbase, cur_dir + sbase, sAliasUnit )
    endif
    select ( sAliasUnit )
    set order to 1
    find ( str( (sAlias)->unit_code, 3 ) )
    if found() .and. (sAliasUnit)->pz > 0
      k := (sAliasUnit)->pz
      i := (sAliasUnit)->ii
    endif
  endif
  if k > 0 .and. empty( i )
    nameArrayPZ := get_array_PZ( lyear )
    i := ascan( nameArrayPZ, { | x | x[ 1 ] == k } )
  endif
  return i

// 29.12.21 вернуть код план-заказа по методу ВМП
Function ret_PZ_VMP( lunit, kDate )
  Local mpztip := 0
  local sbase, nYear := WORK_YEAR

  hb_default( @kDate, WORK_YEAR )

  if valtype( kDate ) == 'D'
    nYear := year( kDate )
  elseif valtype( kDate ) == 'N' .and. kDate >= 2018
    nYear := kDate
  endif

  if select( 'MOUNIT' ) == 0
    sbase := prefixFileRefName( nYear ) + 'unit'
    R_Use( dir_exe() + sbase, cur_dir + sbase, 'MOUNIT' )
  endif
  select MOUNIT
  find ( str( lunit, 3 ) )
  if found() .and. mounit->pz > 0
    mpztip := mounit->pz
  endif
  return mpztip

// 23.01.24
function getUnitsForYear( nYear )

  static hUnits, lHashUnits := .f.
  local yearSl, arr := {}, arrPZ, tCode, i
  local dbName, tmp_select, dbAlias
  local hSingleUnit

  if valtype( nYear ) == 'D'
    yearSl := year( nYear )
  elseif valtype( nYear ) == 'N'
    yearSl := nYear
  else
    return arr
  endif

  if ! lHashUnits   // при отсутствии ХЭШ-массива создадим его
    hUnits := hb_Hash() 
    lHashUnits := .t.
  endif

  // получим массив units план-заказа из хэша по ключу ГОД ОКОНЧАНИЯ СЛУЧАЯ, или загрузим его из справочника
  if hb_HHasKey( hUnits, yearSl )
    arr := hb_HGet(hUnits, yearSl)
  else
    hSingleUnit := hb_Hash() 
    arrPZ := get_array_PZ( yearSl )

    dbName := prefixFileRefName( yearSl ) + 'unit'
    tmp_select := select()
    dbAlias := '__UNIT'
    r_use( dir_exe() + dbName, , dbAlias )

    //  1 - CODE(N)  2 - PZ(N)  3 - II(N)  4 - C_T(N)  5 - NAME(C)  6 - DATEBEG(D)  7 - DATEEND(D)
    ( dbAlias )->( dbGoTop() )
    do while ! ( dbAlias )->( EOF() )
      tCode := ( dbAlias )->CODE

      // создадим хэш для юнита, ключ - CODE из файла unit
      i := ascan(arrPZ, { | x | x[ 2 ] == tCode } )
      hSingleUnit[ ( dbAlias )->CODE ] := { ;
        iif( i == 0, 0, arrPZ[ i, 1 ] ), ;
          ( dbAlias )->CODE, ( dbAlias )->C_T, alltrim( ( dbAlias )->NAME ), ;
        iif( i == 0, 'отсутствует информация для кода - ' + str( tCode, 3 ), arrPZ[ i, 3 ]), ;
        iif( i == 0, 'н/д', arrPZ[ i, 4 ]), ;
        iif( i == 0, 'н/д', arrPZ[ i, 5 ]), ;
        iif( i == 0, 'н/д', arrPZ[ i, 6 ]) }  //, ;
//        ( dbAlias )->DATEBEG, ( dbAlias )->DATEEND }

      hUnits[ yearSl ] := hSingleUnit
      ( dbAlias )->( dbSkip() )
    enddo

    ( dbAlias )->( dbCloseArea() )
    Select( tmp_select )

    // поместим в ХЭШ-массив
    arr := hb_HGet( hUnits, yearSl )
  endif
  return arr
