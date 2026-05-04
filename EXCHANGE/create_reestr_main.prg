#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static Sreestr_sem := 'Работа с реестрами'
Static Sreestr_err := 'В данный момент с реестрами работает другой пользователь.'

// 16.12.25
Function create_reestr_main()

  Local buf := save_maxrow(), k := 0, k1 := 0
  local arr_m

  If ! currentUser():isadmin()
    Return func_error( 4, err_admin() )
  Endif
  If find_unfinished_reestr_sp_tk()
    Return func_error( 4, 'Попытайтесь снова' )
  Endif
  If ( arr_m := year_month( T_ROW, T_COL + 5, , 3 ) ) == NIL
    Return Nil
  Endif

  If DONT_CREATE_REESTR_YEAR == arr_m[ 1 ]
    Return func_error( 4, 'Реестры за ' + Str( DONT_CREATE_REESTR_YEAR, 4 ) + ' год недоступны' )
  elseif arr_m[ 1 ] <= 2025
    return func_error( 10, 'Реестр ранее 2025 года не формируется!' )
  else
    create_reestr26( arr_m )
  Endif

  Return Nil
