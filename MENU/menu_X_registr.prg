#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_registr()

  local fl

  fl := begin_task_regist()
  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~Регистратура ' )
  AAdd( main_message, 'Регистратура амбулаторно-поликлинического учреждения' )
  AAdd( first_menu, { '~Редактирование', ;
    '~Добавление', 0, ;
    '~Удаление', ;
    'Дублирующиеся ~записи', 0;
  } )
  AAdd( first_message, { ;
    'Редактирование информации из карточки больного и печать листка учета', ;
    'Добавление в картотеку информации о больном', ;
    'Удаление карточки больного из картотеки', ;
    'Поиск и удаление дублирующихся записей в картотеке';
  } )
  AAdd( func_menu, { 'regi_kart()', ;
    'append_kart()', ;
    'view_kart(2)', ;
    'dubl_zap()';
  } )
  If glob_mo[ _MO_IS_UCH ]
    AAdd( first_menu[ 1 ], 'Прикреплённое ~население' )
    AAdd( first_message[ 1 ], 'Работа с прикреплённым населением' )
    AAdd( func_menu[ 1 ], 'pripisnoe_naselenie()' )
  Endif
  AAdd( first_menu[ 1 ], '~Справка ОМС' )
  AAdd( first_message[ 1 ], 'Ввод и распечатка справки о стоимости оказанной медицинской помощи в сфере ОМС' )
  AAdd( func_menu[ 1 ], 'f_spravka_OMS()' )
  //
  AAdd( cmain_menu, 34 )
  AAdd( main_menu, ' ~Информация ' )
  AAdd( main_message, 'Просмотр / печать статистики по пациентам' )
  AAdd( first_menu, { 'Статистика по прие~мам', ;
    'Информация по ~картотеке' ;
  } )
  AAdd( first_message, { ;
    'Статистика по первичным врачебным приемам', ;
    'Просмотр / печать списков по категориям, компаниям, районам, участкам,...' ;
    } )
  AAdd( func_menu, { 'regi_stat()', ;
    'prn_kartoteka()' ;
  } )

/*
  if ( ! isnil( edi_FindPath( PLUGINIFILE ) ) ) .and. ( control_podrazdel_ini( edi_FindPath( PLUGINIFILE ) ) )
    AAdd( first_menu[ 4 ], 'Дополнительные возможности' )
    AAdd( first_message[ 4 ], 'Дополнительные возможности' )
    AAdd( func_menu[ 4 ], 'Plugins()' )
  endif
*/
  AAdd( cmain_menu, 51 )
  AAdd( main_menu, ' ~Справочники ' )
  AAdd( main_message, 'Ведение справочников' )
  AAdd( first_menu, { 'Первичные ~приемы', 0, ;
    '~Настройка (умолчания)';
  } )
  AAdd( first_message, { ;  // справочники
    'Редактирование справочника по первичным врачебным приемам', ;
    'Настройка значений по умолчанию';
  } )
  AAdd( func_menu, { 'edit_priem()', ;
    'regi_nastr(2)';
  } )
  If is_r_mu  // регистр льготников
    ins_array( main_menu, 2, ' ~Льготники ' )
    ins_array( main_message, 2, 'Поиск человека в федеральном регистре льготников' )
    ins_array( cmain_menu, 2, 19 )
    ins_array( first_menu, 2, ;
      { '~Поиск', '~Многовариантный поиск', 0, '"~Наши" льготники' } )
    ins_array( first_message, 2, ;
      { 'Поиск человека в регистре льготников, печать мед.карты по форме 025/у-04', ;
        'Многовариантный поиск по регистру льготников', ;
        'Сводная информация по нашему контингенту из федерального регистра льготников' ;
      } )
    ins_array( func_menu, 2, { 'r_mu_human()', 'r_mu_poisk()', 'r_mu_svod()' } )
  Endif
  return fl