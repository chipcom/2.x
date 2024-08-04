#include "common.ch"
#include "set.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 04.08.24
Function f1main( n_Task )
  Local it, s, k, fl := .t., cNameIcon

  If ( it := AScan( array_tasks, {| x| x[ 2 ] == n_Task } ) ) == 0
    Return func_error( "Ошибка в вызове задачи" )
  Endif
  cNameIcon := iif( array_tasks[ it, 3 ] == NIL, "MAIN_ICON", array_tasks[ it, 3 ] )
  glob_task := n_Task
  sys_date := Date()
  c4sys_date := dtoc4( sys_date )
  blk_ekran := {|| DevPos( MaxRow() -2, MaxCol() -Len( dir_server ) ), ;
    DevOut( Upper( dir_server ), "W+/N*" ) }
  main_menu := {}
  main_message := {}
  first_menu := {}
  first_message := {}
  func_menu := {}
  cmain_menu := {}
  put_icon( array_tasks[ it, 1 ] + ' ' + short_name_version(), cNameIcon )
  SetColor( color1 )
  fillscreen( p_char_screen, p_color_screen )
  Do Case
  Case glob_task == X_REGIST //
    fl := begin_task_regist()
    AAdd( cmain_menu, 1 )
    AAdd( main_menu, " ~Регистратура " )
    AAdd( main_message, "Регистратура амбулаторно-поликлинического учреждения" )
    AAdd( first_menu, { "~Редактирование", ;
      "~Добавление", 0, ;
      "~Удаление", ;
      "Дублирующиеся ~записи", 0;
      } )
    AAdd( first_message, { ;
      "Редактирование информации из карточки больного и печать листка учета", ;
      "Добавление в картотеку информации о больном", ;
      "Удаление карточки больного из картотеки", ;
      "Поиск и удаление дублирующихся записей в картотеке";
      } )
    AAdd( func_menu, { "regi_kart()", ;
      "append_kart()", ;
      "view_kart(2)", ;
      "dubl_zap()";
      } )
    If glob_mo[ _MO_IS_UCH ]
      AAdd( first_menu[ 1 ], "Прикреплённое ~население" )
      AAdd( first_message[ 1 ], "Работа с прикреплённым населением" )
      AAdd( func_menu[ 1 ], "pripisnoe_naselenie()" )
    Endif
    AAdd( first_menu[ 1 ], "~Справка ОМС" )
    AAdd( first_message[ 1 ], "Ввод и распечатка справки о стоимости оказанной медицинской помощи в сфере ОМС" )
    AAdd( func_menu[ 1 ], "f_spravka_OMS()" )
    //
    AAdd( cmain_menu, 34 )
    AAdd( main_menu, " ~Информация " )
    AAdd( main_message, "Просмотр / печать статистики по пациентам" )
    AAdd( first_menu, { "Статистика по прие~мам", ;
      "Информация по ~картотеке", ;
      "~Многовариантный поиск";
      } )
    AAdd( first_message, { ;
      "Статистика по первичным врачебным приемам", ;
      "Просмотр / печать списков по категориям, компаниям, районам, участкам,...", ;
      "Многовариантный поиск в картотеке";
      } )
    AAdd( func_menu, { "regi_stat()", ;
      "prn_kartoteka()", ;
      "ne_real()" ;
      } )

    // if ( ! isnil( edi_FindPath( PLUGINIFILE ) ) ) .and. ( control_podrazdel_ini( edi_FindPath( PLUGINIFILE ) ) )
    //   AAdd( first_menu[ 4 ], "Дополнительные возможности" )
    //   AAdd( first_message[ 4 ], "Дополнительные возможности" )
    //   AAdd( func_menu[ 4 ], "Plugins()" )
    // endif
    //
    AAdd( cmain_menu, 51 )
    AAdd( main_menu, " ~Справочники " )
    AAdd( main_message, "Ведение справочников" )
    AAdd( first_menu, { "Первичные ~приемы", 0, ;
      "~Настройка (умолчания)";
      } )
    AAdd( first_message, { ;  // справочники
    "Редактирование справочника по первичным врачебным приемам", ;
      "Настройка значений по умолчанию";
      } )
    AAdd( func_menu, { "edit_priem()", ;
      "regi_nastr(2)";
      } )
    If is_r_mu  // регистр льготников
      ins_array( main_menu, 2, " ~Льготники " )
      ins_array( main_message, 2, "Поиск человека в федеральном регистре льготников" )
      ins_array( cmain_menu, 2, 19 )
      ins_array( first_menu, 2, ;
        { "~Поиск", "~Многовариантный поиск", 0, '"~Наши" льготники' } )
      ins_array( first_message, 2, ;
        { "Поиск человека в регистре льготников, печать мед.карты по форме 025/у-04", ;
        "Многовариантный поиск по регистру льготников", ;
        "Сводная информация по нашему контингенту из федерального регистра льготников" } )
      ins_array( func_menu, 2, { "r_mu_human()", "r_mu_poisk()", "r_mu_svod()" } )
    Endif
  Case glob_task == X_PPOKOJ  //
    fl := begin_task_ppokoj()
    AAdd( cmain_menu, 1 )
    AAdd( main_menu, " ~Приёмный покой " )
    AAdd( main_message, "Ввод данных в приёмном покое стационара" )
    AAdd( first_menu, { "~Добавление", ;
      "~Редактирование", 0, ;
      "В другое ~отделение", 0, ;
      "~Удаление" } )
    AAdd( first_message, { ;
      "Добавление истории болезни", ;
      "Редактирование истории болезни и печать медицинской и стат.карты", ;
      "Перевод больного из одного отделения в другое", ;
      "Удаление истории болезни";
      } )
    AAdd( func_menu, { "add_ppokoj()", ;
      "edit_ppokoj()", ;
      "ppokoj_perevod()", ;
      "del_ppokoj()" } )
    AAdd( cmain_menu, 34 )
    AAdd( main_menu, " ~Информация " )
    AAdd( main_message, "Просмотр / печать статистики по больным" )
    AAdd( first_menu, { "~Журнал регистрации", ;
      "Журнал по ~запросу", 0, ;
      "~Сводная информация", 0, ;
      "~Перевод м/у отделениями", 0, ;
      "Поиск ~ошибок" } )
    AAdd( first_message, { ;
      "Просмотр/печать журнала регистрации стационарных больных", ;
      "Просмотр/печать журнала регистрации стационарных больных по запросу", ;
      "Подсчет количества принятых больных с разбивкой по отделениям", ;
      "Получение информации о переводе между отделениями", ;
      "Поиск ошибок ввода";
      } )
    AAdd( func_menu, { "pr_gurnal_pp()", ;
      "z_gurnal_pp()", ;
      "pr_svod_pp()", ;
      "pr_perevod_pp()", ;
      "pr_error_pp()" } )
    AAdd( cmain_menu, 51 )
    AAdd( main_menu, " ~Справочники " )
    AAdd( main_message, "Ведение справочников" )
    AAdd( first_menu, { "~Столы", ;
      "~Настройка" } )
    AAdd( first_message, { ;
      "Работа со справочником столов", ;
      "Настройка значений по умолчанию";
      } )
    AAdd( func_menu, { "f_pp_stol()", ;
      "pp_nastr()" } )
  Case glob_task == X_OMS  //
    fl := begin_task_oms()
    AAdd( cmain_menu, 1 )
    AAdd( main_menu, " ~ОМС " )
    AAdd( main_message, "Ввод данных по обязательному медицинскому страхованию" )
    AAdd( first_menu, { "~Добавление", ;
      "~Редактирование", ;
      "Д~войные случаи", ;
      "Смена ~отделения", ;
      "~Удаление" } )
    AAdd( first_message, { ;
      "Добавление листка учета лечения больного", ;
      "Редактирование листка учета лечения больного", ;
      "Добавление, просмотр, удаление двойных случаев", ;
      "Редактирование листка учета лечения больного со сменой отделения", ;
      "Удаление листка учета лечения больного";
      } )
    AAdd( func_menu, { "oms_add()", ;
      "oms_edit()", ;
      "oms_double()", ;
      "oms_smena_otd()", ;
      "oms_del()" } )
    If yes_vypisan == B_END
      AAdd( first_menu[ 1 ], "~Завершение лечения" )
      AAdd( first_message[ 1 ], "Режимы работы с завершением лечения" )
      AAdd( func_menu[ 1 ], "oms_zav_lech()" )
    Endif
    AAdd( first_menu[ 1 ], 0 )
    AAdd( first_menu[ 1 ], "~Картотека" )
    AAdd( first_message[ 1 ], "Работа с картотекой" )
    AAdd( func_menu[ 1 ], "oms_kartoteka()" )
    AAdd( first_menu[ 1 ], 0 )
    AAdd( first_menu[ 1 ], "~Справка ОМС" )
    AAdd( first_message[ 1 ], "Ввод и распечатка справки о стоимости оказанной медицинской помощи в сфере ОМС" )
    AAdd( func_menu[ 1 ], "f_spravka_OMS()" )
    //
    AAdd( first_menu[ 1 ], 0 )
    AAdd( first_menu[ 1 ], "Изменение ~цен ОМС" )
    AAdd( first_message[ 1 ], "Изменение цен на услуги в соответствии со справочником услуг ТФОМС" )
    AAdd( func_menu[ 1 ], "Change_Cena_OMS()" )
    //
    AAdd( cmain_menu, cmain_next_pos( 3 ) )
    AAdd( main_menu, " ~Реестры " )
    AAdd( main_message, "Ввод, печать и учет реестров случаев" )
    AAdd( first_menu, { "Про~верка", ;
      "~Составление", ;
      "~Просмотр", 0, ;
      "Во~зврат", 0 } )
    AAdd( first_message, { ;
      "Проверка перед составлением реестра случаев", ;
      "Составление реестра случаев", ;
      "Просмотр реестра случаев, отправка в ТФОМС", ;
      "Возврат реестра случаев" } )
    AAdd( func_menu, { "verify_OMS()", ;
      "create_reestr()", ;
      "view_list_reestr()", ;
      "vozvrat_reestr()" } )
    If glob_mo[ _MO_IS_UCH ]
      AAdd( first_menu[ 2 ], "П~рикрепления" )
      AAdd( first_message[ 2 ], "Просмотр файлов прикрепления (и ответов на них), запись файлов для ТФОМС" )
      AAdd( func_menu[ 2 ], "view_reestr_pripisnoe_naselenie()" )
      AAdd( first_menu[ 2 ], "~Открепления" )
      AAdd( first_message[ 2 ], "Просмотр полученных из ТФОМС файлов откреплений" )
      AAdd( func_menu[ 2 ], "view_otkrep_pripisnoe_naselenie()" )
    Endif
    AAdd( first_menu[ 2 ], "~Ходатайства" )
    AAdd( first_message[ 2 ], "Просмотр, запись в ТФОМС, удаление файлов ходатайств" )
    AAdd( func_menu[ 2 ], "view_list_hodatajstvo()" )
    //
    AAdd( cmain_menu, cmain_next_pos( 3 ) )
    AAdd( main_menu, " ~Счета " )
    AAdd( main_message, "Просмотр, печать и учет счетов по ОМС" )
    AAdd( first_menu, { "~Чтение из ТФОМС", ;
      "Список ~счетов", ;
      "~Регистрация", ;
      "~Акты контроля", ;
      "Платёжные ~документы", 0, ;
      "~Прочие счета" } )
    AAdd( first_message, { ;
      "Чтение информации из ТФОМС (из СМО)", ;
      "Просмотр списка счетов по ОМС, запись для ТФОМС, печать счетов", ;
      "Отметка о регистрации счетов в ТФОМС", ;
      "Работа с актами контроля счетов (с реестрами актов контроля)", ;
      "Работа с платёжными документами по оплате (с реестрами платёжных документов)", ;
      "Работа с прочими счетами (создание, редактирование, возврат)", ;
      } )
    AAdd( func_menu, { "read_from_tf()", ;
      "view_list_schet()", ;
      "registr_schet()", ;
      "akt_kontrol()", ;
      "view_pd()", ;
      "other_schets()" } )
    //
    AAdd( cmain_menu, cmain_next_pos( 3 ) )
    AAdd( main_menu, " ~Информация " )
    AAdd( main_message, "Просмотр / печать общих справочников и статистики" )
    AAdd( first_menu, { "Лист ~учета", ;
      "~Статистика", ;
      "План-~заказ", ;
      "~Проверки", ;
      "Справо~чники", 0, ;
      "Печать ~бланков" } )
    AAdd( first_message, { ;
      "Просмотр / печать листов учета больных", ;
      "Просмотр / печать статистики", ;
      "Статистика по план-заказу", ;
      "Различные проверки", ;
      "Просмотр / печать общих справочников", ;
      "Распечатка всевозможных бланков";
      } )
    AAdd( func_menu, { "o_list_uch()", ;
      "e_statist()", ;
      "pz_statist()", ;
      "o_proverka()", ;
      "o_sprav()", ;
      "prn_blank()" } )
    If yes_parol
      AAdd( first_menu[ 4 ], "Работа ~операторов" )
      AAdd( first_message[ 4 ], "Статистика по работе операторов за день и за месяц" )
      AAdd( func_menu[ 4 ], "st_operator()" )
    Endif

    if ( ! isnil( edi_FindPath( PLUGINIFILE ) ) ) .and. ( control_podrazdel_ini( edi_FindPath( PLUGINIFILE ) ) )
      AAdd( first_menu[ 4 ], "Дополнительные возможности" )
      AAdd( first_message[ 4 ], "Дополнительные возможности" )
      AAdd( func_menu[ 4 ], "Plugins()" )
    endif
    
    //
    AAdd( cmain_menu, cmain_next_pos( 3 ) )
    AAdd( main_menu, " ~Диспансеризация " )
    AAdd( main_message, "Диспансеризация, профилактика, медосмотры и диспансерное наблюдение" )
    AAdd( first_menu, { "~Диспансеризация и профосмотры", 0, ;
      "Диспансерное ~наблюдение" } )
    AAdd( first_message, { ;
      "Диспансеризация, профилактика и медосмотры", ;
      "Диспансерное наблюдение";
      } )
    AAdd( func_menu, { "dispanserizacia()", ;
      "disp_nabludenie()" } )
  Case glob_task == X_263 //
    fl := begin_task_263()
    If is_napr_pol
      AAdd( cmain_menu, 1 )
      AAdd( main_menu, " ~Поликлиника " )
      AAdd( main_message, "Ввод / редактирование направлений на госпитализацию по поликлинике" )
      AAdd( first_menu, { ;// "~Проверка",0,;
      "~Направления", ;
        "~Аннулирование", ;
        "~Информирование", 0, ;
        "~Свободные койки", 0, ;
        "~Картотека" } )
      AAdd( first_message, { ;// "Проверка того, что ещё не сделано в поликлинике",;
      "Ввод / редактирование / просмотр направлений на госпитализацию по поликлинике", ;
        "Аннулирование выписанных направлений на госпитализацию по поликлинике", ;
        "Информирование наших пациентов о дате предстоящей госпитализации", ;
        "Просмотр количества свободных коек по профилям в стационарах/дневных стационарах", ;
        "Работа с картотекой";
        } )
      AAdd( func_menu, { ;// "_263_p_proverka()",;
      "_263_p_napr()", ;
        "_263_p_annul()", ;
        "_263_p_inform()", ;
        "_263_p_svob_kojki()", ;
        "_263_kartoteka(1)" } )
    Endif
    If is_napr_stac
      AAdd( cmain_menu, 15 )
      AAdd( main_menu, " ~Стационар " )
      AAdd( main_message, "Ввод даты госпитализации, учёт госпитализированных и выбывших по стационару" )
      AAdd( first_menu, { ;// "~Проверка",0,;
      "~Госпитализации", ;
        "~Выписка (выбытие)", ;
        "~Направления", ;
        "~Аннулирование", 0, ;
        "~Свободные койки", 0, ;
        "~Картотека" } )
      AAdd( first_message, { ;// "Проверка того, что ещё не сделано в стационаре",;
      "Добавление / редактирование госпитализаций в стационаре", ;
        "Выписка (выбытие) пациента из стационара", ;
        "Список направлений, по которым ещё не было госпитализации", ;
        "Аннулирование направлений, поступивших из поликлиник через ТФОМС", ;
        "Ввод / редактирование количества свободных коек по профилям в стационаре", ;
        "Работа с картотекой";
        } )
      AAdd( func_menu, { ;// "_263_s_proverka()",;
      "_263_s_gospit()", ;
        "_263_s_vybytie()", ;
        "_263_s_napr()", ;
        "_263_s_annul()", ;
        "_263_s_svob_kojki()", ;
        "_263_kartoteka(2)" } )
    Endif
    AAdd( cmain_menu, 29 )
    AAdd( main_menu, " ~в ТФОМС " )
    AAdd( main_message, "Отправка в ТФОМС файлов обмена (просмотр отправленных файлов)" )
    AAdd( first_menu, { "~Проверка перед составлением пакетов", ;
      "~Составление пакетов для отправки в ТФ", ;
      "Просмотр протоколов ~записи", 0 } )
    AAdd( first_message,  { ;   // информация
    "Проверка информации перед составлением пакетов и отправкой в ТФОМС", ;
      "Составление информационных пакетов для отправки в ТФОМС", ;
      "Просмотр протоколов составления информационных пакетов для отправки в ТФОМС";
      } )
    AAdd( func_menu, { ;    // информация
    "_263_to_proverka()", ;
      "_263_to_sostavlenie()", ;
      "_263_to_protokol()";
      } )
    k := Len( first_menu )
    If is_napr_pol
      AAdd( first_menu[ k ], "I0~1-выписанные направления" )
      AAdd( first_message[ k ], "Список информационных пакетов с выписанными направлениями" )
      AAdd( func_menu[ k ], "_263_to_I01()" )
    Endif
    AAdd( first_menu[ k ], "I0~3-аннулированные направления" )
    AAdd( first_message[ k ], "Список информационных пакетов с аннулированными направлениями" )
    AAdd( func_menu[ k ], "_263_to_I03()" )
    If is_napr_stac
      AAdd( first_menu[ k ], "I0~4-госпитализации по направлениям" )
      AAdd( first_message[ k ], "Список информационных пакетов с госпитализациями по направлениям" )
      AAdd( func_menu[ k ], "_263_to_I04(4)" )
      //
      AAdd( first_menu[ k ], "I0~5-экстренные госпитализации" )
      AAdd( first_message[ k ], "Список информационных пакетов с госпитализациями без направлений (экстр.и неотл.)" )
      AAdd( func_menu[ k ], "_263_to_I04(5)" )
      //
      AAdd( first_menu[ k ], "I0~6-выбывшие пациенты" )
      AAdd( first_message[ k ], "Список информационных пакетов со сведениями о выбывших пациентах" )
      AAdd( func_menu[ k ], "_263_to_I06()" )
    Endif
    AAdd( first_menu[ k ], 0 )
    AAdd( first_menu[ k ], "~Настройка каталогов" )
    AAdd( first_message[ k ], "Настройка каталогов обмена - куда записывать созданные для ТФОМС файлы" )
    AAdd( func_menu[ k ], "_263_to_nastr()" )
    //
    AAdd( cmain_menu, 39 )
    AAdd( main_menu, " из ~ТФОМС " )
    AAdd( main_message, "Получение из ТФОМС файлов обмена и просмотр полученных файлов" )
    AAdd( first_menu, { "~Чтение из ТФОМС", ;
      "~Просмотр протоколов чтения", 0 } )
    AAdd( first_message,  { ;   // информация
    "Получение из ТФОМС файлов обмена (информационных пакетов)", ;
      "Просмотр протоколов чтения информационных пакетов из ТФОМС";
      } )
    AAdd( func_menu, { ;
      "_263_from_read()", ;
      "_263_from_protokol()";
      } )
    k := Len( first_menu )
    If is_napr_stac
      AAdd( first_menu[ k ], "I0~1-полученные направления" )
      AAdd( first_message[ k ], "Список информационных пакетов с полученными направлениями от поликлиник" )
      AAdd( func_menu[ k ], "_263_from_I01()" )
    Endif
    AAdd( first_menu[ k ], "I0~3-аннулированные направления" )
    AAdd( first_message[ k ], "Список информационных пакетов с аннулированными направлениями" )
    AAdd( func_menu[ k ], "_263_from_I03()" )
    If is_napr_pol
      AAdd( first_menu[ k ], "I0~4-госпитализации по направлениям" )
      AAdd( first_message[ k ], "Список информационных пакетов с госпитализациями по направлениям" )
      AAdd( func_menu[ k ], "_263_from_I04()" )
      //
      AAdd( first_menu[ k ], "I0~5-экстренные госпитализации" )
      AAdd( first_message[ k ], "Список информационных пакетов с госпитализациями без направлений (экстр.и неотл.)" )
      AAdd( func_menu[ k ], "_263_from_I05()" )
      //
      AAdd( first_menu[ k ], "I0~6-выбывшие пациенты" )
      AAdd( first_message[ k ], "Список информационных пакетов со сведениями о выбывших пациентах" )
      AAdd( func_menu[ k ], "_263_from_I06()" )
      //
      AAdd( first_menu[ k ], "I0~7-наличие свободных мест" )
      AAdd( first_message[ k ], "Список информационных пакетов со сведениями о наличии свободных мест" )
      AAdd( func_menu[ k ], "_263_from_I07()" )
    Endif
    AAdd( first_menu[ k ], 0 )
    AAdd( first_menu[ k ], "~Настройка каталогов" )
    AAdd( first_message[ k ], "Настройка каталогов обмена - откуда зачитывать полученные из ТФОМС файлы" )
    AAdd( func_menu[ k ], "_263_to_nastr()" )
    //
  Case glob_task == X_PLATN //
    fl := begin_task_plat()
    AAdd( cmain_menu, 1 )
    AAdd( main_menu, " ~Платные услуги " )
    AAdd( main_message, "Ввод / редактирование данных из листов учета платных медицинских услуг" )
    AAdd( first_menu, { "~Ввод данных" } )
    AAdd( first_message, { "Добавление/Редактирование листка учета лечения платного больного" } )
    AAdd( func_menu, { "kart_plat()" } )
    If glob_pl_reg == 1
      AAdd( first_menu[ 1 ], "~Поиск/ред-ие" )
      AAdd( first_message[ 1 ], "Поиск/Редактирование листов учета лечения платных больных" )
      AAdd( func_menu[ 1 ], "poisk_plat()" )
    Endif
    AAdd( first_menu[ 1 ], 0 )
    AAdd( first_menu[ 1 ], "~Картотека" )
    AAdd( first_message[ 1 ], "Работа с картотекой" )
    AAdd( func_menu[ 1 ], "oms_kartoteka()" )
    AAdd( first_menu[ 1 ], 0 )
    AAdd( first_menu[ 1 ], "~Оплата ДМС и в/з" )
    AAdd( first_message[ 1 ], "Ввод/редактирование оплат по взаимозачету и добровольному мед.страхованию" )
    AAdd( func_menu[ 1 ], "oplata_vz()" )
    AAdd( first_menu[ 1 ], 0 )
    AAdd( first_menu[ 1 ], "~Закрытие л/учета" )
    AAdd( first_message[ 1 ], "Закрыть лист учета (снять признак закрытия с листа учета)" )
    AAdd( func_menu[ 1 ], "close_lu()" )
    //
    AAdd( cmain_menu, 34 )
    AAdd( main_menu, " ~Информация " )
    AAdd( main_message, "Просмотр / печать общих справочников и статистики" )
    AAdd( first_menu, { "~Статистика", ;
      "Спра~вочники", ;
      "~Проверки" } )
    AAdd( first_message,  { ;   // информация
    "Просмотр статистики", ;
      "Просмотр общих справочников", ;
      "Различные проверочные режимы";
      } )
    AAdd( func_menu, { ;    // информация
    "Po_statist()", ;
      "o_sprav()", ;
      "Po_proverka()";
      } )
    If glob_kassa == 1
      AAdd( first_menu[ 2 ], 0 )
      AAdd( first_menu[ 2 ], "Работа с ~кассой" )
      AAdd( first_message[ 2 ], "Информация по работе с кассой" )
      AAdd( func_menu[ 2 ], "inf_fr()" )
    Endif
    AAdd( first_menu[ 2 ], 0 )
    AAdd( first_menu[ 2 ], 'Справки для ~ФНС' )
    AAdd( first_message[ 2 ], 'Составление и работа со справками для ФНС' )
    AAdd( func_menu[ 2 ], 'inf_fns()' )
    If yes_parol
      AAdd( first_menu[ 2 ], 0 )
      AAdd( first_menu[ 2 ], "Работа ~операторов" )
      AAdd( first_message[ 2 ], "Статистика по работе операторов за день и за месяц" )
      AAdd( func_menu[ 2 ], "st_operator()" )
    Endif
    //
    AAdd( cmain_menu, 50 )
    AAdd( main_menu, " ~Справочники " )
    AAdd( main_message, "Ведение справочников" )
    AAdd( first_menu, {} )
    AAdd( first_message, {} )
    AAdd( func_menu, {} )
    If is_oplata != 7
      AAdd( first_menu[ 3 ], "~Медсестры" )
      AAdd( first_message[ 3 ], "Справочник медсестер для платных услуг" )
      AAdd( func_menu[ 3 ], "s_pl_meds(1)" )
      //
      AAdd( first_menu[ 3 ], "~Санитарки" )
      AAdd( first_message[ 3 ], "Справочник санитарок для платных услуг" )
      AAdd( func_menu[ 3 ], "s_pl_meds(2)" )
    Endif
    AAdd( first_menu[ 3 ], "Предприятия (в/~зачет)" )
    AAdd( first_message[ 3 ], "Справочник предприятий, работающих по взаимозачету" )
    AAdd( func_menu[ 3 ], "edit_pr_vz()" )
    //
    AAdd( first_menu[ 3 ], "~Добровольные СМО" ) ; AAdd( first_menu[ 3 ], 0 )
    AAdd( first_message[ 3 ], "Справочник страховых компаний, осуществляющих добровольное мед.страхование" )
    AAdd( func_menu[ 3 ], "edit_d_smo()" )
    //
    AAdd( first_menu[ 3 ], "Услуги по дата~м" )
    AAdd( first_message[ 3 ], "Редактирование справочника услуг, цена по которым действует с какой-то даты" )
    AAdd( func_menu[ 3 ], "f_usl_date()" )
    If glob_kassa == 1
      AAdd( first_menu[ 3 ], 0 )
      AAdd( first_menu[ 3 ], "Работа с ~кассой" )
      AAdd( first_message[ 3 ], "Настройка работы с кассовым аппаратом" )
      AAdd( func_menu[ 3 ], "fr_nastrojka()" )
    Endif
  Case glob_task == X_ORTO  //
    fl := begin_task_orto()
    AAdd( cmain_menu, 1 )
    AAdd( main_menu, " ~Ортопедия " )
    AAdd( main_message, "Ввод данных по ортопедическим услугам в стоматологии" )
    AAdd( first_menu, { "~Открытие наряда", ;
      "~Закрытие наряда", 0, ;
      "~Картотека" } )
    AAdd( first_message,  { ;
      "Открытие наряда-заказа (добавление листка учета лечения больного)", ;
      "Закрытие наряда-заказа (редактирование листка учета лечения больного)", ;
      "Работа с картотекой" } )
    AAdd( func_menu, { "kart_orto(1)", ;
      "kart_orto(2)", ;
      "oms_kartoteka()" } )
    //
    AAdd( cmain_menu, 34 )
    AAdd( main_menu, " ~Информация " )
    AAdd( main_message, "Просмотр / печать общих справочников и статистики" )
    AAdd( first_menu, { "~Статистика", ;
      "Спра~вочники", ;
      "~Проверки" } )
    AAdd( first_message,  { ;   // информация
      "Просмотр статистики", ;
      "Просмотр общих справочников", ;
      "Различные проверочные режимы";
    } )
    AAdd( func_menu, { ;    // информация
      "Oo_statist()", ;
      "o_sprav(-5)", ;   // X_ORTO = 5
      "Oo_proverka()";
    } )
    If glob_kassa == 1   // 10.10.14
      AAdd( first_menu[ 2 ], 0 )
      AAdd( first_menu[ 2 ], "Работа с ~кассой" )
      AAdd( first_message[ 2 ], "Информация по работе с кассой" )
      AAdd( func_menu[ 2 ], "inf_fr_orto()" )
    Endif
    AAdd( first_menu[ 2 ], 0 )
    AAdd( first_menu[ 2 ], 'Справки для ~ФНС' )
    AAdd( first_message[ 2 ], 'Составление и работа со справками для ФНС' )
    AAdd( func_menu[ 2 ], 'inf_fns()' )
    If yes_parol
      AAdd( first_menu[ 2 ], 0 )
      AAdd( first_menu[ 2 ], "Работа ~операторов" )
      AAdd( first_message[ 2 ], "Статистика по работе операторов за день и за месяц" )
      AAdd( func_menu[ 2 ], "st_operator()" )
    Endif
    //
    AAdd( cmain_menu, 50 )
    AAdd( main_menu, " ~Справочники " )
    AAdd( main_message, "Ведение справочников" )
    AAdd( first_menu, ;
      { "Ортопедические ~диагнозы", ;
      "Причины ~поломок", ;
      "~Услуги без врачей", 0, ;
      "Предприятия (в/~зачет)", ;
      "~Добровольные СМО", 0, ;
      "~Материалы";
      } )
    AAdd( first_message, ;
      { "Редактирование справочника ортопедических диагнозов", ;
      "Редактирование справочника причин поломок протезов", ;
      "Ввод/редактирование услуг, у которых не вводится врач (техник)", ;
      "Справочник предприятий, работающих по взаимозачету", ;
      "Справочник страховых компаний, осуществляющих добровольное мед.страхование", ;
      "Справочник приведенных расходуемых материалов";
      } )
    AAdd( func_menu, ;
      { "orto_diag()", ;
      "f_prich_pol()", ;
      "f_orto_uva()", ;
      "edit_pr_vz()", ;
      "edit_d_smo()", ;
      "edit_ort()";
      } )
    If glob_kassa == 1
      AAdd( first_menu[ 3 ], 0 )
      AAdd( first_menu[ 3 ], "Работа с ~кассой" )
      AAdd( first_message[ 3 ], "Настройка работы с кассовым аппаратом" )
      AAdd( func_menu[ 3 ], "fr_nastrojka()" )
    Endif
  Case glob_task == X_KASSA //
    fl := begin_task_kassa()
    //
    AAdd( cmain_menu, 1 )
    AAdd( main_menu, " ~Касса МО " )
    AAdd( main_message, "Ввод данных в кассе МО по платным услугам" )
    AAdd( first_menu, { "~Ввод данных", 0, ;
      "~Картотека" } )
    AAdd( first_message,  { ;
      "Добавление листка учета лечения платного больного", ;
      "Ввод/редактирование картотеки (регистратура)" } )
    AAdd( func_menu, { "kas_plat()", ;
      "oms_kartoteka()" } )
    AAdd( first_menu[ 1 ], 0 )
    AAdd( first_menu[ 1 ], "~Справка ОМС" )
    AAdd( first_message[ 1 ], "Ввод и распечатка справки о стоимости оказанной медицинской помощи в сфере ОМС" )
    AAdd( func_menu[ 1 ], "f_spravka_OMS()" )
    //
    If is_task( X_ORTO )
      AAdd( cmain_menu, cmain_next_pos() )
      AAdd( main_menu, " ~Ортопедия " )
      AAdd( main_message, "Ввод данных по ортопедическим услугам" )
      AAdd( first_menu, { "~Новый наряд", ;
        "~Редактирование наряда", 0, ;
        "~Картотека" } )
      AAdd( first_message, { ;
        "Открытие сложного наряда или ввод простого ортопедического наряда", ;
        "Редактирование ортопедического наряда (в т.ч. доплата или возврат денег)", ;
        "Ввод/редактирование картотеки (регистратура)" } )
      AAdd( func_menu, { "f_ort_nar(1)", ;
        "f_ort_nar(2)", ;
        "oms_kartoteka()" } )
    Endif
    //
    AAdd( cmain_menu, cmain_next_pos() )
    AAdd( main_menu, " ~Информация " )
    AAdd( main_message, "Просмотр / печать" )
    AAdd( first_menu, { iif( is_task( X_ORTO ), "~Платные услуги", "~Статистика" ), ;
      "Сводная с~татистика", ; // 10.05
      "Спра~вочники", ;
      "Работа с ~кассой" } )
    AAdd( first_message,  { ;   // информация
      "Просмотр / печать статистических отчетов по платным услугам", ;
      "Просмотр / печать сводных статистических отчетов", ;
      "Просмотр общих справочников", ;
      "Информация по работе с кассой";
    } )
    AAdd( func_menu, { ;    // информация
      "prn_k_plat()", ;
      "regi_s_plat()", ;
      "o_sprav()", ;
      "prn_k_fr()";
    } )
    If is_task( X_ORTO )
      ins_array( first_menu[ 3 ], 2, "~Ортопедия" )
      ins_array( first_message[ 3 ], 2, "Просмотр / печать статистических отчетов по ортопедии" )
      ins_array( func_menu[ 3 ], 2, "prn_k_ort()" )
    Endif
    //
    AAdd( cmain_menu, cmain_next_pos() )
    AAdd( main_menu, " ~Справочники " )
    AAdd( main_message, "Просмотр / редактирование справочников" )
    AAdd( first_menu, { "~Услуги со сменой цены", ;
      "~Разовые услуги", ;
      "Работа с ~кассой", 0, ;
      "~Настройка программы" } )
    AAdd( first_message, { ;
      "Редактирование списка услуг, при вводе которых разрешается редактировать цену", ;
      "Редактирование списка услуг, не выводимых в журнал договоров (если 1 в чеке)", ;
      "Настройка работы с кассовым аппаратом", ;
      "Настройка программы (некоторых значений по умолчанию)" } )
    AAdd( func_menu, { "fk_usl_cena()", ;
      "fk_usl_dogov()", ;
      "fr_nastrojka()", ;
      "nastr_kassa(2)" } )
    AAdd( first_menu[ 2 ], 0 )
    AAdd( first_menu[ 2 ], 'Справки для ~ФНС' )
    AAdd( first_message[ 2 ], 'Составление и работа со справками для ФНС' )
    AAdd( func_menu[ 2 ], 'inf_fns()' )
//  Case glob_task == X_KEK  //
//    If !Between( hb_user_curUser:KEK, 1, 3 )
//      n_message( { "Недопустимая группа экспертизы (КЭК): " + lstr( hb_user_curUser:KEK ), ;
//        '', ;
//        'Пользователям, которым разрешено работать в подзадаче "КЭК МО",', ;
//        'необходимо установить группу экспертизы (от 1 до 3)', ;
//        'в подзадаче "Редактирование справочников" в режиме "Справочники/Пароли"' },, ;
//        "GR+/R", "W+/R",,, "G+/R" )
//    Else
//      fl := begin_task_kek()
//      AAdd( cmain_menu, 1 )
//      AAdd( main_menu, " ~КЭК " )
//      AAdd( main_message, "Ввод данных по КЭК медицинской организации" )
//      AAdd( first_menu, { "~Добавление", ;
//        "~Редактирование", ;
//        "~Удаление" } )
//      AAdd( first_message, { ;
//        "Добавление данных по экпертизе", ;
//        "Редактирование данных по экпертизе", ;
//        "Удаление данных по экпертизе";
//        } )
//      AAdd( func_menu, { "kek_vvod(1)", ;
//        "kek_vvod(2)", ;
//        "kek_vvod(3)" } )
//      AAdd( cmain_menu, 34 )
//      AAdd( main_menu, " ~Информация " )
//      AAdd( main_message, "Просмотр / печать статистики по экспертизам" )
//      AAdd( first_menu, { "~Экспертная карта", ;
//        "Оценка ~качества" } )
//      AAdd( first_message, { ;
//        "Распечатка экспертной карты", ;
//        "Распечатка раличных отчётов по оцеке качества экспертизы" } )
//      AAdd( func_menu, { "kek_prn_eks()", ;
//        "kek_info2017()" } )
//      AAdd( cmain_menu, 51 )
//      AAdd( main_menu, " ~Справочники " )
//      AAdd( main_message, "Ведение справочников" )
//      AAdd( first_menu, { "~Настройка" } )
//      AAdd( first_message, { "Настройка значений по умолчанию" } )
//      AAdd( func_menu, { "kek_nastr()" } )
//    Endif
  Case glob_task == X_MO //
    fl := my_mo_begin_task()
    my_mo_f1main()
  Case glob_task == X_SPRAV //
    fl := begin_task_sprav()
    //
    AAdd( cmain_menu, 1 )
    AAdd( main_menu, " ~Справочники " )
    AAdd( main_message, "Редактирование справочников" )
    AAdd( first_menu, { "~Структура организации", ;
      "Справочник ~услуг", ;
      "П~рочие справочники";
      } )
    AAdd( first_message, { ;
      "Редактирование справочников персонала, отделений, учреждений, организации", ;
      "Редактирование справочника услуг", ;
      "Редактирование прочих справочников"; // ,;
    } )
    AAdd( func_menu, { "spr_struct_org()", ;
      "edit_spr_uslugi()", ;
      "edit_proch_spr()";
      } )
    //
    // перестройка меню
    If hb_user_curUser:ID != 0 .or. hb_user_curUser:issuperuser()
      hb_AIns( first_menu[ Len( first_menu ) ], 4, 0, .t. )
      hb_AIns( first_menu[ Len( first_menu ) ], 5, '~Пользователи', .t. )
      hb_AIns( first_menu[ Len( first_menu ) ], 6, '~Группы пользователей', .t. )
      hb_AIns( first_message[ Len( first_message ) ], 4, 'Редактирование справочника пользователей системы', .t. )
      hb_AIns( first_message[ Len( first_message ) ], 5, 'Редактирование справочника групп пользователей в системе', .t. )
      If hb_main_curOrg:KOD_TFOMS == '102604'
        hb_AIns( func_menu[ Len( func_menu ) ], 4, 'edit_Users_bay()', .t. )
      Else
        hb_AIns( func_menu[ Len( func_menu ) ], 4, 'edit_password()', .t. )
      Endif
      hb_AIns( func_menu[ Len( func_menu ) ], 5, 'editRoles()', .t. )
    Endif
    // конец перестройки меню

    AAdd( cmain_menu, 40 )
    AAdd( main_menu, " ~Информация " )
    AAdd( main_message, "Просмотр/печать справочников" )
    AAdd( first_menu, { "~Общие справочники" } )
    AAdd( first_message, { ;
      "Просмотр/печать общих справочников";
      } )
    AAdd( func_menu, { "o_sprav()" } )
  Case glob_task == X_SERVIS //
    AAdd( cmain_menu, 1 )
    AAdd( main_menu, " ~Сервисы " )
    AAdd( main_message, "Сервисы и настройки" )
    //
    If glob_mo[ _MO_KOD_TFOMS ] == '395301' // Камышин СТОМ
      AAdd( first_menu, { "~Проверка целостности", 0, ;
        "Изменение ~цен ОМС", 0, ;
        "~Импорт", ;
        "~Экспорт", ;
        "~Материалы" } )
      AAdd( first_message, { ;
        "Проверка целостности базы данных на файл-сервере", ;
        "Изменение цен на услуги в соответствии со справочником услуг ТФОМС", ;
        "Различные варианты импорта из других программ", ;
        'Различные варианты экспорта в другие программы/организации', ;
        "Справочник приведенных расходуемых материалов";
        } )
      AAdd( func_menu, { "prover_dbf(,.f.,(hb_user_curUser:IsAdmin()))", ;
        "Change_Cena_OMS()", ;
        "f_import()", ;
        "f_export()", ;
        "edit_ort()" } )

    Else
      AAdd( first_menu, { "~Проверка целостности", 0, ;
        "Изменение ~цен ОМС", 0, ;
        "~Импорт", ;
        "~Экспорт" } )
      AAdd( first_message, { ;
        "Проверка целостности базы данных на файл-сервере", ;
        "Изменение цен на услуги в соответствии со справочником услуг ТФОМС", ;
        "Различные варианты импорта из других программ", ;
        'Различные варианты экспорта в другие программы/организации';
        } )
      AAdd( func_menu, { "prover_dbf(,.f.,(hb_user_curUser:IsAdmin()))", ;
        "Change_Cena_OMS()", ;
        "f_import()", ;
        "f_export()" } )
    Endif
    //
    AAdd( cmain_menu, 20 )
    AAdd( main_menu, " ~Настройки " )
    AAdd( main_message, "Настройки" )
    AAdd( first_menu, { "~Общие настройки", 0, ;
      "Справочники ~ФФОМС", 0, ;
      "~Рабочее место" } )
    AAdd( first_message, { ;
      "Общие настройки каждой задачи", ;
      "Настройка содержимого справочников ФФОМС (уменьшение количества строк)", ;
      "Настройка рабочего места";
      } )
    AAdd( func_menu, { "nastr_all()", ;
      "nastr_sprav_FFOMS()", ;
      "nastr_rab_mesto()" } )
    AAdd( cmain_menu, 50 )
    AAdd( main_menu, " Прочие ~отчёты " )
    AAdd( main_message, "Редко используемые (устаревшие) отчёты" )
    //
    If glob_mo[ _MO_KOD_TFOMS ] == '395301' // Камышин СТОМ
      AAdd( first_menu, { ;
        "~Новые пациенты", ;
        "Информация о количестве удалённых ~зубов", ;
        "письмо №792 ВОМИА~Ц", ;
        "Мониторин~г по видам мед.помощи", ;
        "Телефонограмма №~15 ВО КЗ", ;
        "Сведения для б-цы ~25 и пер.центра 2", ;
        "~Расход материалов" } )
      // "~Модернизация",;
      AAdd( first_message, { ;
        "Журнал регистрации новых пациентов", ;
        "Информация о количестве удалённых постоянных зубов с 2005 по 2015 годы", ;
        "Подготовка формы согласно приложению к письму ВОМИАЦ №792 от 16.06.2017г.", ;
        "Мониторинг по видам медицинской помощи для Комитета здравоохранения ВО", ;
        "Информация по стационарному лечению лиц пожилого возраста за 2017 год", ;
        "Сведения о фактических затратах на оказание медицинской помощи", ;
        "Ведомость по расходу материалов на протезирование" } )
      // "Статистика по модернизации",;
      AAdd( func_menu, { 'run_my_hrb("mo_hrb1","i_new_boln()")', ;
        'run_my_hrb("mo_hrb1","i_kol_del_zub()")', ;
        'run_my_hrb("mo_hrb1","forma_792_MIAC()")', ;
        'run_my_hrb("mo_hrb1","monitoring_vid_pom()")', ;
        'run_my_hrb("mo_hrb1","phonegram_15_kz()")', ;
        'run_my_hrb("mo_hrb1","b_25_perinat_2()")', ;
        'Ort_OMS_material()' } )
      // "modern_statist()",;
    Else
      AAdd( first_menu, { ;
        "~Новые пациенты", ;
        "Информация о количестве удалённых ~зубов", ;
        "письмо №792 ВОМИА~Ц", ;
        "Мониторин~г по видам мед.помощи", ;
        "Телефонограмма №~15 ВО КЗ", ;
        "Сведения для б-цы ~25 и пер.центра 2" } )
      // "~Модернизация",;
      AAdd( first_message, { ;
        "Журнал регистрации новых пациентов", ;
        "Информация о количестве удалённых постоянных зубов с 2005 по 2015 годы", ;
        "Подготовка формы согласно приложению к письму ВОМИАЦ №792 от 16.06.2017г.", ;
        "Мониторинг по видам медицинской помощи для Комитета здравоохранения ВО", ;
        "Информация по стационарному лечению лиц пожилого возраста за 2017 год", ;
        "Сведения о фактических затратах на оказание медицинской помощи" } )
      // "Статистика по модернизации",;
      AAdd( func_menu, { 'run_my_hrb("mo_hrb1","i_new_boln()")', ;
        'run_my_hrb("mo_hrb1","i_kol_del_zub()")', ;
        'run_my_hrb("mo_hrb1","forma_792_MIAC()")', ;
        'run_my_hrb("mo_hrb1","monitoring_vid_pom()")', ;
        'run_my_hrb("mo_hrb1","phonegram_15_kz()")', ;
        'run_my_hrb("mo_hrb1","b_25_perinat_2()")' } )
      // "modern_statist()",;
    Endif
  Case glob_task == X_COPY //
    AAdd( cmain_menu, 1 )
    AAdd( main_menu, " ~Резервное копирование " )
    AAdd( main_message, "Резервное копирование базы данных" )
    AAdd( first_menu, { ;
      'Копирование ~базы данных', ;
      'Отправка базы ~данных', ;
      'Отправка файла ~ошибок' ;
      } )
    AAdd( first_message, { ;
      'Резервное копирование базы данных', ;
      'Резервное копирование базы данных и отправка копии службу поддержки', ;
      'Резервное копирование файла ошибок и отправка его в службу поддержки' ;
      } )
    AAdd( func_menu, { ;
      'm_copy_DB(1)', ;
      'm_copy_DB(2)', ;
      'errorFileToFTP()' ;
      } )
  Case glob_task == X_INDEX //
    AAdd( cmain_menu, 1 )
    AAdd( main_menu, " ~Переиндексирование " )
    AAdd( main_message, "Переиндексирование базы данных" )
    AAdd( first_menu, { "~Переиндексирование" } )
    AAdd( first_message, { ;
      "Переиндексирование базы данных";
      } )
    AAdd( func_menu, { "m_index_DB()" } )
  Endcase
  // последнее меню для всех одно и то же
  AAdd( cmain_menu, MaxCol() -9 )
  AAdd( main_menu, " Помо~щь " )
  AAdd( main_message, "Помощь, настройка принтера" )
  AAdd( first_menu, { "~Новое в программе", ;
    "Помо~щь", ;
    "~Рабочее место", ;
    "~Принтер", 0, ;
    "Переиндексация рабочего каталога", ;
    "Сетевой ~монитор", ;
    "~Ошибки" } )
  AAdd( first_message, { ;
    "Вывод на экран содержания файла README.RTF с текстом нового в программе", ;
    "Вывод на экран экрана помощи", ;
    "Настройка рабочего места", ;
    "Установка кодов принтера", ;
    "Переидексирование справочников НСИ в рабочем каталоге", ;
    "Режим просмотра - кто находится в задаче и в каком режиме", ;
    "Просмотр файла ошибок" } )
  // aadd(func_menu, {"file_Wordpad(dir_exe + cslash + 'README.RTF')",;
  AAdd( func_menu, { "view_file_in_Viewer(dir_exe + cslash + 'README.RTF')", ;
    "m_help()", ;
    "nastr_rab_mesto()", ;
    "ust_printer(T_ROW)", ;
    "index_work_dir(dir_exe, cur_dir, .t.)", ;
    "net_monitor(T_ROW,T_COL-7,(hb_user_curUser:IsAdmin()))", ;
    "view_errors()" } )
  // добавим переиндексирование некоторых файлов внутри задачи
//  If eq_any( glob_task, X_PPOKOJ, X_OMS, X_PLATN, X_ORTO, X_KASSA, X_KEK, X_263 )
  If eq_any( glob_task, X_PPOKOJ, X_OMS, X_PLATN, X_ORTO, X_KASSA, X_263 )
    AAdd( ATail( first_menu ), 0 )
    AAdd( ATail( first_menu ), "Пере~индексирование" )
    AAdd( ATail( first_message ), 'Переиндексирование части базы данных для задачи "' + array_tasks[ ind_task(), 5 ] + '"' )
    AAdd( ATail( func_menu ), "pereindex_task()" )
  Endif
  If fl
    g_splus( f_name_task() )   // плюс 1 пользователь зашёл в задачу
    func_main( .t., blk_ekran )
    g_sminus( f_name_task() )  // минус 1 пользователь (вышел из задачи)
  Endif

  Return Nil

// 25.05.13 подсчитать следующую позицию для главного меню задачи
Static Function cmain_next_pos( n )

  Default n To 5

  Return ATail( cmain_menu ) + Len( ATail( main_menu ) ) + n

// 05.11.15
Function my_mo_f1main()
  Local old := is_uchastok

  If glob_mo[ _MO_KOD_TFOMS ] == kod_VOUNC
    is_uchastok := 1 // буква + № участка + № в участке "У25/123"
    vounc_f1main()
    is_uchastok := old
  Endif

  Return Nil
