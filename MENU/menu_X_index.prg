#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_index()

  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~Переиндексирование ' )
  AAdd( main_message, 'Переиндексирование базы данных' )
  AAdd( first_menu, { '~Переиндексирование' } )
  AAdd( first_message, { ;
    'Переиндексирование базы данных';
  } )
  mydebug(,glob_mo[ _MO_KOD_TFOMS ] )
  
  If glob_mo[ _MO_KOD_TFOMS ] == '103001'
    If !currentuser():isadmin()
      AAdd( func_menu, { 'func_error( 4, "Вход только АДМИНИСТРАТОРУ !" )' } )
    else
      AAdd( func_menu, { 'm_index_DB()' } )
    endif
  else  
    AAdd( func_menu, { 'm_index_DB()' } )
  endif  
  return nil