#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_oms()

  local fl

  fl := begin_task_oms()
  AAdd( cmain_menu, 1 )
  AAdd( main_menu, ' ~ОМС ' )
  AAdd( main_message, 'Ввод данных по обязательному медицинскому страхованию' )
  AAdd( first_menu, { ;
    '~Добавление', ;
    '~Редактирование', ;
    'Д~войные случаи', ;
    'Смена ~отделения', ;
    '~Удаление' ;
  } )
  AAdd( first_message, { ;
    'Добавление листка учета лечения больного', ;
    'Редактирование листка учета лечения больного', ;
    'Добавление, просмотр, удаление двойных случаев', ;
    'Редактирование листка учета лечения больного со сменой отделения', ;
    'Удаление листка учета лечения больного';
  } )
  AAdd( func_menu, { ;
    'oms_add()', ;
    'oms_edit()', ;
    'oms_double()', ;
    'oms_smena_otd()', ;
    'oms_del()' ;
  } )
  If yes_vypisan == B_END
    AAdd( first_menu[ 1 ], '~Завершение лечения' )
    AAdd( first_message[ 1 ], 'Режимы работы с завершением лечения' )
    AAdd( func_menu[ 1 ], 'oms_zav_lech()' )
  Endif
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], '~Картотека' )
  AAdd( first_message[ 1 ], 'Работа с картотекой' )
  AAdd( func_menu[ 1 ], 'oms_kartoteka()' )
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], '~Справка ОМС' )
  AAdd( first_message[ 1 ], 'Ввод и распечатка справки о стоимости оказанной медицинской помощи в сфере ОМС' )
  AAdd( func_menu[ 1 ], 'f_spravka_OMS()' )
  //
  AAdd( first_menu[ 1 ], 0 )
  AAdd( first_menu[ 1 ], 'Изменение ~цен ОМС' )
  AAdd( first_message[ 1 ], 'Изменение цен на услуги в соответствии со справочником услуг ТФОМС' )
  AAdd( func_menu[ 1 ], 'Change_Cena_OMS()' )
  //
  AAdd( cmain_menu, cmain_next_pos( 3 ) )
  AAdd( main_menu, ' ~Реестры ' )
  AAdd( main_message, 'Ввод, печать и учет реестров случаев' )
  AAdd( first_menu, { ;
    'Про~верка', ;
    '~Составление', ;
    '~Просмотр', 0, ;
    'Во~зврат', 0 ;
  } )
  AAdd( first_message, { ;
    'Проверка перед составлением реестра случаев', ;
    'Составление реестра случаев', ;
    'Просмотр реестра случаев, отправка в ТФОМС', ;
    'Возврат реестра случаев' ;
  } )
  AAdd( func_menu, { ;
    'verify_OMS()', ;
    'create_reestr_main()', ;
    'view_list_reestr()', ;
    'vozvrat_reestr()' ;
  } )
  If glob_mo[ _MO_IS_UCH ]
    AAdd( first_menu[ 2 ], 'П~рикрепления' )
    AAdd( first_message[ 2 ], 'Просмотр файлов прикрепления (и ответов на них), запись файлов для ТФОМС' )
    AAdd( func_menu[ 2 ], 'view_reestr_pripisnoe_naselenie()' )
    AAdd( first_menu[ 2 ], '~Открепления' )
    AAdd( first_message[ 2 ], 'Просмотр полученных из ТФОМС файлов откреплений' )
    AAdd( func_menu[ 2 ], 'view_otkrep_pripisnoe_naselenie()' )
  Endif
  AAdd( first_menu[ 2 ], '~Ходатайства' )
  AAdd( first_message[ 2 ], 'Просмотр, запись в ТФОМС, удаление файлов ходатайств' )
  AAdd( func_menu[ 2 ], 'view_list_hodatajstvo()' )
  //
  AAdd( cmain_menu, cmain_next_pos( 3 ) )
  AAdd( main_menu, ' ~Счета ' )
  AAdd( main_message, 'Просмотр, печать и учет счетов по ОМС' )
  AAdd( first_menu, { ;
    '~Чтение из ТФОМС', ;
    'Список ~счетов', ;
    '~Регистрация', ;
    '~Акты контроля', ;
    'Платёжные ~документы', 0, ;
    '~Прочие счета' ;
  } )
  AAdd( first_message, { ;
    'Чтение информации из ТФОМС (из СМО)', ;
    'Просмотр списка счетов по ОМС, запись для ТФОМС, печать счетов', ;
    'Отметка о регистрации счетов в ТФОМС', ;
    'Работа с актами контроля счетов (с реестрами актов контроля)', ;
    'Работа с платёжными документами по оплате (с реестрами платёжных документов)', ;
    'Работа с прочими счетами (создание, редактирование, возврат)', ;
  } )
  AAdd( func_menu, { ;
    'read_from_tf()', ;
    'view_list_schet()', ;
    'registr_schet()', ;
    'akt_kontrol()', ;
    'view_pd()', ;
    'other_schets()' ;
  } )
  //
  AAdd( cmain_menu, cmain_next_pos( 3 ) )
  AAdd( main_menu, ' ~Информация ' )
  AAdd( main_message, 'Просмотр / печать общих справочников и статистики' )
  AAdd( first_menu, { ;
    'Лист ~учета', ;
    '~Статистика', ;
    'План-~заказ', ;
    '~Проверки', ;
    'Справо~чники', 0, ;
    'Печать ~бланков' ;
  } )
  AAdd( first_message, { ;
    'Просмотр / печать листов учета больных', ;
    'Просмотр / печать статистики', ;
    'Статистика по план-заказу', ;
    'Различные проверки', ;
    'Просмотр / печать общих справочников', ;
    'Распечатка всевозможных бланков';
  } )
  AAdd( func_menu, { ;
    'o_list_uch()', ;
    'e_statist()', ;
    'pz_statist()', ;
    'o_proverka()', ;
    'o_sprav()', ;
    'prn_blank()' ;
  } )
  If yes_parol
    AAdd( first_menu[ 4 ], 'Работа ~операторов' )
    AAdd( first_message[ 4 ], 'Статистика по работе операторов за день и за месяц' )
    AAdd( func_menu[ 4 ], 'st_operator()' )
  Endif

  if ( ! isnil( edi_FindPath( PLUGINIFILE ) ) ) .and. ( control_podrazdel_ini( edi_FindPath( PLUGINIFILE ) ) )
    AAdd( first_menu[ 4 ], 'Дополнительные возможности' )
    AAdd( first_message[ 4 ], 'Дополнительные возможности' )
    AAdd( func_menu[ 4 ], 'Plugins()' )
  endif
    
  //
  AAdd( cmain_menu, cmain_next_pos( 3 ) )
  AAdd( main_menu, ' ~Диспансеризация ' )
  AAdd( main_message, 'Диспансеризация, профилактика, медосмотры и диспансерное наблюдение' )
  AAdd( first_menu, { ;
    '~Диспансеризация и профосмотры', ;
    0, ;
    'Диспансерное ~наблюдение' ;
  } )
  AAdd( first_message, { ;
    'Диспансеризация, профилактика и медосмотры', ;
    'Диспансерное наблюдение' ;
  } )
  AAdd( func_menu, { ;
    'dispanserizacia()', ;
    'disp_nabludenie()' ;
  } )
  return fl