#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_copy()

  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~Резервное копирование ' )
  AAdd( main_message, 'Резервное копирование базы данных' )
  AAdd( first_menu, { ;
    'Копирование ~базы данных', ;
    'Отправка базы ~данных', ;
    'Отправка файла ~ошибок' ;
  } )
  AAdd( first_message, { ;
    'Резервное копирование базы данных', ;
    'Резервное копирование базы данных и отправка копии службу поддержки', ;
    'Резервное копирование файла ошибок и отправка его в службу поддержки' ;
    } )
  AAdd( func_menu, { ;
    'm_copy_DB(1)', ;
    'm_copy_DB(2)', ;
    'errorFileToFTP()' ;
  } )
  return nil