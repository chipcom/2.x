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
  AAdd( func_menu, { 'm_index_DB()' } )
  return nil