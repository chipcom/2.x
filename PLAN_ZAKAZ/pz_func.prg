#include 'hbhash.ch' 
#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 23.01.24
Function arr_plan_zakaz( ly )
  Local i, apz := {}
  local nameArr //, funcGetPZ
  local aValues

  DEFAULT ly TO WORK_YEAR
  nameArr := get_array_PZ( ly )

  aValues := hb_hValues( getUnitsForYear( ly ) )
  ASort( aValues, , , { | x, y | x[ 1 ] < y[ 1 ] } )

  //// for i := 1 to len(&nameArr)
  ////   aadd(apz, {&nameArr.[i,3], ;
  ////               &nameArr.[i,1], ;
  ////               0, ;
  ////               &nameArr.[i,6], ;
  ////               &nameArr.[i,5], ;
  ////               {} ;
  ////             })
  //// next
//  for i := 1 to len( nameArr )
//    aadd( apz, { nameArr[ i, 3 ], ;
//                nameArr[ i, 1 ], ;
//                0, ;
//                nameArr[ i, 6 ], ;
//                nameArr[ i, 5 ], ;
//                { } ;
//              } )
//  next
  for i := 1 to len( aValues )
    aadd( apz, { aValues[ i, 5 ], ;
                aValues[ i, 1 ], ;
                0, ;
                aValues[ i, 8 ], ;
                aValues[ i, 7 ], ;
                { } ;
              } )
  next
  return apz

// 26.12.23 по шифру услуги у году вернуть номер элемента массива 'arr_plan_zakaz' для года
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
      R_Use( dir_exe + sbase, cur_dir + sbase, sAliasUnit )
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
    // nameArrayPZ := 'glob_array_PZ_' + last_digits_year(lyear)
    // i := ascan(&nameArrayPZ, {|x| x[1] == k })
    // funcGetPZ := 'get_array_PZ_' + last_digits_year(lyear) + '()'
    // nameArrayPZ := &funcGetPZ
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
    R_Use( dir_exe + sbase, cur_dir + sbase, 'MOUNIT' )
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
    r_use( dir_exe + dbName, , dbAlias )

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
