#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_index()

  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~��२�����஢���� ' )
  AAdd( main_message, '��२�����஢���� ���� ������' )
  AAdd( first_menu, { '~��२�����஢����' } )
  AAdd( first_message, { ;
    '��२�����஢���� ���� ������';
  } )
  AAdd( func_menu, { 'm_index_DB()' } )
  return nil