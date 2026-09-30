#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 30.09.26
function menu_X_copy()

  local lExistInternet := .f.
  local aTemp := {}

  lExistInternet := hb_ping()

  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~Резервное копирование ' )
  AAdd( main_message, 'Резервное копирование базы данных' )

  AAdd( aTemp, 'Копирование ~базы данных' )
  if lExistInternet
    AAdd( aTemp, 'Отправка базы ~данных' )
    AAdd( aTemp, 'Отправка файла ~ошибок' )
  endif
  AAdd( first_menu, aTemp )

  aTemp := {}
  AAdd( aTemp, 'Резервное копирование базы данных' )
  if lExistInternet
    AAdd( aTemp, 'Резервное копирование базы данных и отправка копии службу поддержки' )
    AAdd( aTemp, 'Резервное копирование файла ошибок и отправка его в службу поддержки' )
  endif
  AAdd( first_message, aTemp )

  aTemp := {}
  AAdd( aTemp, 'm_copy_DB(1)' )
  if lExistInternet
    AAdd( aTemp, 'm_copy_DB(2)' )
    AAdd( aTemp, 'errorFileToFTP()' )
  endif
  AAdd( func_menu, aTemp )

/*
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
*/
  return nil