#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_sprav()

  local fl

  fl := begin_task_sprav()
  //
  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~Справочники ' )
  AAdd( main_message, 'Редактирование справочников' )
  AAdd( first_menu, { '~Структура организации', ;
    'Справочник ~услуг', ;
    'П~рочие справочники';
    } )
  AAdd( first_message, { ;
    'Редактирование справочников персонала, отделений, учреждений, организации', ;
    'Редактирование справочника услуг', ;
    'Редактирование прочих справочников'; // ,;
  } )
  AAdd( func_menu, { 'spr_struct_org()', ;
    'edit_spr_uslugi()', ;
    'edit_proch_spr()';
    } )
  //
  // перестройка меню
  If hb_user_curUser:ID != 0 .or. hb_user_curUser:issuperuser()
    hb_AIns( first_menu[ Len( first_menu ) ], 4, 0, .t. )
    hb_AIns( first_menu[ Len( first_menu ) ], 5, '~Пользователи', .t. )
    hb_AIns( first_menu[ Len( first_menu ) ], 6, '~Группы пользователей', .t. )
    hb_AIns( first_message[ Len( first_message ) ], 4, 'Редактирование справочника пользователей системы', .t. )
    hb_AIns( first_message[ Len( first_message ) ], 5, 'Редактирование справочника групп пользователей в системе', .t. )
//        hb_AIns( func_menu[ Len( func_menu ) ], 4, 'edit_Users_bay()', .t. )
      hb_AIns( func_menu[ Len( func_menu ) ], 4, 'edit_password()', .t. )
    hb_AIns( func_menu[ Len( func_menu ) ], 5, 'editRoles()', .t. )
  Endif
  // конец перестройки меню

  AAdd( cmain_menu, 40 )
  AAdd( main_menu, ' ~Информация ' )
  AAdd( main_message, 'Просмотр/печать справочников' )
  AAdd( first_menu, { '~Общие справочники' } )
  AAdd( first_message, { ;
    'Просмотр/печать общих справочников';
    } )
  AAdd( func_menu, { 'o_sprav()' } )
  return fl