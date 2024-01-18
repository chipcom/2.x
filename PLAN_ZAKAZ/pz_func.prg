#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 26.12.23
Function arr_plan_zakaz( ly )
  Local i, apz := {}
  local nameArr //, funcGetPZ

  DEFAULT ly TO WORK_YEAR
  // nameArr := 'glob_array_PZ_' + last_digits_year(ly)
  // funcGetPZ := 'get_array_PZ_' + last_digits_year(ly) + '()'
  // nameArr := &funcGetPZ
  nameArr := get_array_PZ( ly )

  // for i := 1 to len(&nameArr)
  //   aadd(apz, {&nameArr.[i,3], ;
  //               &nameArr.[i,1], ;
  //               0, ;
  //               &nameArr.[i,6], ;
  //               &nameArr.[i,5], ;
  //               {} ;
  //             })
  // next
  for i := 1 to len( nameArr )
    aadd( apz, { nameArr[ i, 3 ], ;
                nameArr[ i, 1 ], ;
                0, ;
                nameArr[ i, 6 ], ;
                nameArr[ i, 5 ], ;
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