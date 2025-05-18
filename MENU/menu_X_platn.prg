#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_platn()

  local fl

  fl := begin_task_plat()
  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~Платные услуги ' )
  AAdd( main_message, 'Ввод / редактирование данных из листов учета платных медицинских услуг' )
  AAdd( first_menu, { '~Ввод данных' } )
  AAdd( first_message, { 'Добавление/Редактирование листка учета лечения платного больного' } )
  AAdd( func_menu, { 'kart_plat()' } )
  If glob_pl_reg == 1
    AAdd( first_menu[ 1 ], '~Поиск/ред-ие' )
    AAdd( first_message[ 1 ], 'Поиск/Редактирование листов учета лечения платных больных' )
    AAdd( func_menu[ 1 ], 'poisk_plat()' )
  Endif
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], '~Картотека' )
  AAdd( first_message[ 1 ], 'Работа с картотекой' )
  AAdd( func_menu[ 1 ], 'oms_kartoteka()' )
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], '~Оплата ДМС и в/з' )
  AAdd( first_message[ 1 ], 'Ввод/редактирование оплат по взаимозачету и добровольному мед.страхованию' )
  AAdd( func_menu[ 1 ], 'oplata_vz()' )
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], '~Закрытие л/учета' )
  AAdd( first_message[ 1 ], 'Закрыть лист учета (снять признак закрытия с листа учета)' )
  AAdd( func_menu[ 1 ], 'close_lu()' )
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
    'Po_statist()', ;
    'o_sprav()', ;
    'Po_proverka()';
  } )
  If glob_kassa == 1
    AAdd( first_menu[ 2 ], 0 )
    AAdd( first_menu[ 2 ], 'Работа с ~кассой' )
    AAdd( first_message[ 2 ], 'Информация по работе с кассой' )
    AAdd( func_menu[ 2 ], 'inf_fr()' )
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
  AAdd( first_menu, {} )
  AAdd( first_message, {} )
  AAdd( func_menu, {} )
  If is_oplata != 7
    AAdd( first_menu[ 3 ], '~Медсестры' )
    AAdd( first_message[ 3 ], 'Справочник медсестер для платных услуг' )
    AAdd( func_menu[ 3 ], 's_pl_meds(1)' )
    //
    AAdd( first_menu[ 3 ], '~Санитарки' )
    AAdd( first_message[ 3 ], 'Справочник санитарок для платных услуг' )
    AAdd( func_menu[ 3 ], 's_pl_meds(2)' )
  Endif
  AAdd( first_menu[ 3 ], 'Предприятия (в/~зачет)' )
  AAdd( first_message[ 3 ], 'Справочник предприятий, работающих по взаимозачету' )
  AAdd( func_menu[ 3 ], 'edit_pr_vz()' )
  //
  AAdd( first_menu[ 3 ], '~Добровольные СМО' ) ; AAdd( first_menu[ 3 ], 0 )
  AAdd( first_message[ 3 ], 'Справочник страховых компаний, осуществляющих добровольное мед.страхование' )
  AAdd( func_menu[ 3 ], 'edit_d_smo()' )
  //
  AAdd( first_menu[ 3 ], 'Услуги по дата~м' )
  AAdd( first_message[ 3 ], 'Редактирование справочника услуг, цена по которым действует с какой-то даты' )
  AAdd( func_menu[ 3 ], 'f_usl_date()' )
  If glob_kassa == 1
    AAdd( first_menu[ 3 ], 0 )
    AAdd( first_menu[ 3 ], 'Работа с ~кассой' )
    AAdd( first_message[ 3 ], 'Настройка работы с кассовым аппаратом' )
    AAdd( func_menu[ 3 ], 'fr_nastrojka()' )
  Endif
  return fl