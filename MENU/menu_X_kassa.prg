#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_kassa()

  local fl

  fl := begin_task_kassa()
  //
  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~Касса МО ' )
  AAdd( main_message, 'Ввод данных в кассе МО по платным услугам' )
  AAdd( first_menu, { '~Ввод данных', 0, ;
    '~Картотека' ;
  } )
  AAdd( first_message,  { ;
    'Добавление листка учета лечения платного больного', ;
    'Ввод/редактирование картотеки (регистратура)' ;
  } )
  AAdd( func_menu, { 'kas_plat()', ;
    'oms_kartoteka()' ;
  } )
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], '~Справка ОМС' )
  AAdd( first_message[ 1 ], 'Ввод и распечатка справки о стоимости оказанной медицинской помощи в сфере ОМС' )
  AAdd( func_menu[ 1 ], 'f_spravka_OMS()' )
  //
  If is_task( X_ORTO )
    AAdd( cmain_menu, cmain_next_pos() )
    AAdd( main_menu, ' ~Ортопедия ' )
    AAdd( main_message, 'Ввод данных по ортопедическим услугам' )
    AAdd( first_menu, { '~Новый наряд', ;
      '~Редактирование наряда', 0, ;
      '~Картотека' ;
    } )
    AAdd( first_message, { ;
      'Открытие сложного наряда или ввод простого ортопедического наряда', ;
      'Редактирование ортопедического наряда (в т.ч. доплата или возврат денег)', ;
      'Ввод/редактирование картотеки (регистратура)' ;
    } )
    AAdd( func_menu, { 'f_ort_nar(1)', ;
      'f_ort_nar(2)', ;
      'oms_kartoteka()' ;
    } )
  Endif
  //
  AAdd( cmain_menu, cmain_next_pos() )
  AAdd( main_menu, ' ~Информация ' )
  AAdd( main_message, 'Просмотр / печать' )
  AAdd( first_menu, { iif( is_task( X_ORTO ), '~Платные услуги', '~Статистика' ), ;
    'Сводная с~татистика', ; // 10.05
    'Спра~вочники', ;
    'Работа с ~кассой' ;
  } )
  AAdd( first_message,  { ;   // информация
    'Просмотр / печать статистических отчетов по платным услугам', ;
    'Просмотр / печать сводных статистических отчетов', ;
    'Просмотр общих справочников', ;
    'Информация по работе с кассой';
  } )
  AAdd( func_menu, { ;    // информация
    'prn_k_plat()', ;
    'regi_s_plat()', ;
    'o_sprav()', ;
    'prn_k_fr()';
  } )
  If is_task( X_ORTO )
    ins_array( first_menu[ 3 ], 2, '~Ортопедия' )
    ins_array( first_message[ 3 ], 2, 'Просмотр / печать статистических отчетов по ортопедии' )
    ins_array( func_menu[ 3 ], 2, 'prn_k_ort()' )
  Endif
  //
  AAdd( cmain_menu, cmain_next_pos() )
  AAdd( main_menu, ' ~Справочники ' )
  AAdd( main_message, 'Просмотр / редактирование справочников' )
  AAdd( first_menu, { '~Услуги со сменой цены', ;
    '~Разовые услуги', ;
    'Работа с ~кассой', 0, ;
    '~Настройка программы' ;
  } )
  AAdd( first_message, { ;
    'Редактирование списка услуг, при вводе которых разрешается редактировать цену', ;
    'Редактирование списка услуг, не выводимых в журнал договоров (если 1 в чеке)', ;
    'Настройка работы с кассовым аппаратом', ;
    'Настройка программы (некоторых значений по умолчанию)' ;
  } )
  AAdd( func_menu, { 'fk_usl_cena()', ;
    'fk_usl_dogov()', ;
    'fr_nastrojka()', ;
    'nastr_kassa(2)' ;
  } )
  AAdd( first_menu[ 2 ], 0 )
  AAdd( first_menu[ 2 ], 'Справки для ~ФНС' )
  AAdd( first_message[ 2 ], 'Составление и работа со справками для ФНС' )
  AAdd( func_menu[ 2 ], 'inf_fns()' )
  return fl