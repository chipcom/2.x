#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_prokoj()

  local fl

  fl := begin_task_ppokoj()
  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~Приёмный покой ' )
  AAdd( main_message, 'Ввод данных в приёмном покое стационара' )
  AAdd( first_menu, { ;
    '~Добавление', ;
    '~Редактирование', 0, ;
    'В другое ~отделение', 0, ;
    '~Удаление' ;
  } )
  AAdd( first_message, { ;
    'Добавление истории болезни', ;
    'Редактирование истории болезни и печать медицинской и стат.карты', ;
    'Перевод больного из одного отделения в другое', ;
    'Удаление истории болезни';
    } )
  AAdd( func_menu, { ;
    'add_ppokoj()', ;
    'edit_ppokoj()', ;
    'ppokoj_perevod()', ;
    'del_ppokoj()' ;
  } )
  AAdd( cmain_menu, 34 )
  AAdd( main_menu, ' ~Информация ' )
  AAdd( main_message, 'Просмотр / печать статистики по больным' )
  AAdd( first_menu, { ;
    '~Журнал регистрации', ;
    'Журнал по ~запросу', 0, ;
    '~Сводная информация', 0, ;
    '~Перевод м/у отделениями', 0, ;
    'Поиск ~ошибок' ;
  } )
  AAdd( first_message, { ;
    'Просмотр/печать журнала регистрации стационарных больных', ;
    'Просмотр/печать журнала регистрации стационарных больных по запросу', ;
    'Подсчет количества принятых больных с разбивкой по отделениям', ;
    'Получение информации о переводе между отделениями', ;
    'Поиск ошибок ввода';
    } )
  AAdd( func_menu, { ;
    'pr_gurnal_pp()', ;
    'z_gurnal_pp()', ;
    'pr_svod_pp()', ;
    'pr_perevod_pp()', ;
    'pr_error_pp()' ;
  } )
  AAdd( cmain_menu, 51 )
  AAdd( main_menu, ' ~Справочники ' )
  AAdd( main_message, 'Ведение справочников' )
  AAdd( first_menu, { ;
    '~Столы', ;
    '~Настройка' ;
  } )
  AAdd( first_message, { ;
    'Работа со справочником столов', ;
    'Настройка значений по умолчанию';
  } )
  AAdd( func_menu, { ;
    'f_pp_stol()', ;
    'pp_nastr()' ;
  } )
  return fl