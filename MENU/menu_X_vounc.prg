#include "common.ch"
#include "function.ch"
#include "chip_mo.ch"

function menu_X_vounc()

  Local old, fl := .t.

  If glob_mo[ _MO_KOD_TFOMS ] == kod_VOUNC

    fl := vounc_begin_task()
    old := is_uchastok
    is_uchastok := 1 // буква + № участка + № в участке "У25/123"

    AAdd( cmain_menu, 1 )
    AAdd( main_menu, ' ~Ввод данных ' )
    AAdd( main_message, 'Ввод данных' )
    AAdd( first_menu, { '~Назначения', ;
      '~Рецепты', 0, ;
      '~Картотека' } )
    AAdd( first_message,  { ;
      'Редактирование назначений лекарственных препаратов', ;
      'Ввод/редактирование рецептов', ;
      'Ввод/редактирование картотеки (регистратура)' } )
    AAdd( func_menu, { 'vounc_input_nazn()', ;
      'vounc_input_recept()', ;
      'oms_kartoteka()' } )
    //
    AAdd( cmain_menu, 34 )
    AAdd( main_menu, ' ~Информация ' )
    AAdd( main_message, 'Просмотр / печать' )
    AAdd( first_menu, { '~Назначения', ;
      '~Рецепты', ;
      '~Справочники' } )
    AAdd( first_message,  { ;   // информация
      'Просмотр / печать назначений', ;
      'Просмотр / печать отчетов по выписке рецептов', ;
      'Просмотр/печать справочников' ;
      } )
    AAdd( func_menu, { ;    // информация
      'vounc_info_nazn()', ;
      'vounc_info_recept()', ;
      'vounc_info_sprav()' ;
      } )
    //
    AAdd( cmain_menu, 51 )
    AAdd( main_menu, ' ~Справочники ' )
    AAdd( main_message, 'Редактирование справочников' )
    AAdd( first_menu, { '~Торговые наименования', ;
      '~МНН', 0, ;
      '~Настройка программы' } )
    AAdd( first_message, { ;
      'Редактирование торговых наименований препаратов', ;
      'Редактирование международных непатентованных наименований препаратов', ;
      'Настройка программы (некоторых значений по умолчанию)' } )
    AAdd( func_menu, { 'vounc_sprav_trn()', ;
      'vounc_sprav_mnn()', ;
      'vounc_sprav_nastr(2)' } )
  endif
  is_uchastok := old
  return fl
