#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_orto()

  local fl

  fl := begin_task_orto()
  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~Ортопедия ' )
  AAdd( main_message, 'Ввод данных по ортопедическим услугам в стоматологии' )
  AAdd( first_menu, { '~Открытие наряда', ;
    '~Закрытие наряда', 0, ;
    '~Картотека' ;
  } )
  AAdd( first_message,  { ;
    'Открытие наряда-заказа (добавление листка учета лечения больного)', ;
    'Закрытие наряда-заказа (редактирование листка учета лечения больного)', ;
    'Работа с картотекой' ;
  } )
  AAdd( func_menu, { 'kart_orto(1)', ;
    'kart_orto(2)', ;
    'oms_kartoteka()' ;
  } )
  //
  AAdd( cmain_menu, 34 )
  AAdd( main_menu, ' ~Информация ' )
  AAdd( main_message, 'Просмотр / печать общих справочников и статистики' )
  AAdd( first_menu, { '~Статистика', ;
    'Спра~вочники', ;
    '~Проверки' ;
  } )
  AAdd( first_message,  { ;   // информация
    'Просмотр статистики', ;
    'Просмотр общих справочников', ;
    'Различные проверочные режимы';
  } )
  AAdd( func_menu, { ;    // информация
    'Oo_statist()', ;
    'o_sprav(-5)', ;   // X_ORTO = 5
    'Oo_proverka()';
  } )
  If glob_kassa == 1   // 10.10.14
    AAdd( first_menu[ 2 ], 0 )
    AAdd( first_menu[ 2 ], 'Работа с ~кассой' )
    AAdd( first_message[ 2 ], 'Информация по работе с кассой' )
    AAdd( func_menu[ 2 ], 'inf_fr_orto()' )
  Endif
  AAdd( first_menu[ 2 ], 0 )
  AAdd( first_menu[ 2 ], 'Справки для ~ФНС' )
  AAdd( first_message[ 2 ], 'Составление и работа со справками для ФНС' )
  AAdd( func_menu[ 2 ], 'inf_fns()' )
  If yes_parol
    AAdd( first_menu[ 2 ], 0 )
    AAdd( first_menu[ 2 ], 'Работа ~операторов' )
    AAdd( first_message[ 2 ], 'Статистика по работе операторов за день и за месяц' )
    AAdd( func_menu[ 2 ], 'st_operator()' )
  Endif
  //
  AAdd( cmain_menu, 50 )
  AAdd( main_menu, ' ~Справочники ' )
  AAdd( main_message, 'Ведение справочников' )
  AAdd( first_menu, ;
    { 'Ортопедические ~диагнозы', ;
      'Причины ~поломок', ;
      '~Услуги без врачей', 0, ;
      'Предприятия (в/~зачет)', ;
      '~Добровольные СМО', 0, ;
      '~Материалы';
    } )
  AAdd( first_message, ;
    { 'Редактирование справочника ортопедических диагнозов', ;
      'Редактирование справочника причин поломок протезов', ;
      'Ввод/редактирование услуг, у которых не вводится врач (техник)', ;
      'Справочник предприятий, работающих по взаимозачету', ;
      'Справочник страховых компаний, осуществляющих добровольное мед.страхование', ;
      'Справочник приведенных расходуемых материалов';
    } )
  AAdd( func_menu, ;
    { 'orto_diag()', ;
      'f_prich_pol()', ;
      'f_orto_uva()', ;
      'edit_pr_vz()', ;
      'edit_d_smo()', ;
      'edit_ort()';
    } )
  If glob_kassa == 1
    AAdd( first_menu[ 3 ], 0 )
    AAdd( first_menu[ 3 ], 'Работа с ~кассой' )
    AAdd( first_message[ 3 ], 'Настройка работы с кассовым аппаратом' )
    AAdd( func_menu[ 3 ], 'fr_nastrojka()' )
  Endif
  return fl