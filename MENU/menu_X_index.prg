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
  mydebug(,glob_mo[ _MO_KOD_TFOMS ] )
  
  If glob_mo[ _MO_KOD_TFOMS ] == '103001'
    If !hb_user_curUser:isadmin()
      AAdd( func_menu, { 'func_error( 4, "�室 ⮫쪮 �������������� !" )' } )
    else
      AAdd( func_menu, { 'm_index_DB()' } )
    endif
  else  
    AAdd( func_menu, { 'm_index_DB()' } )
  endif  
  return nil