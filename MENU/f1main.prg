#include "set.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 21.07.14
Function f1main(n_Task)
  Local it, s, k, fl := .t., cNameIcon
  
if (it := ascan(array_tasks, {|x| x[2] == n_Task})) == 0
  return func_error("Ошибка в вызове задачи")
endif
cNameIcon := iif(array_tasks[it,3]==NIL, "MAIN_ICON", array_tasks[it,3])
glob_task := n_Task
sys_date := DATE()
c4sys_date := dtoc4(sys_date)
blk_ekran := {|| devpos(maxrow()-2,maxcol()-len(dir_server)), ;
                 devout(upper(dir_server),"W+/N*") }
main_menu := {}
main_message := {}
first_menu := {}
first_message := {}
func_menu := {}
cmain_menu := {}
put_icon(array_tasks[it,1] + ' [ЧИП + Учёт работы МО]' + __s_version(), cNameIcon)
SETCOLOR(color1)
FillScreen(p_char_screen,p_color_screen)
do case
  case glob_task == X_REGIST //
    fl := begin_task_regist()
    aadd(cmain_menu,1)
    aadd(main_menu," ~Регистратура ")
    aadd(main_message,"Регистратура амбулаторно-поликлинического учреждения")
    aadd(first_menu, {"~Редактирование",;
                      "~Добавление",0,;
                      "~Удаление",;
                      "Дублирующиеся ~записи",0;
                     })
    aadd(first_message, { ;
       "Редактирование информации из карточки больного и печать листка учета",;
       "Добавление в картотеку информации о больном",;
       "Удаление карточки больного из картотеки",;
       "Поиск и удаление дублирующихся записей в картотеке";
      })
    aadd(func_menu, {"regi_kart()",;
                     "append_kart()",;
                     "view_kart(2)",;
                     "dubl_zap()";
                    })
    if glob_mo[_MO_IS_UCH]
      aadd(first_menu[1],"Прикреплённое ~население")
      aadd(first_message[1],"Работа с прикреплённым населением")
      aadd(func_menu[1],"pripisnoe_naselenie()")
    endif
    aadd(first_menu[1],"~Справка ОМС")
    aadd(first_message[1],"Ввод и распечатка справки о стоимости оказанной медицинской помощи в сфере ОМС")
    aadd(func_menu[1],"f_spravka_OMS()")
    //
    aadd(cmain_menu,34)
    aadd(main_menu," ~Информация ")
    aadd(main_message,"Просмотр / печать статистики по пациентам")
    aadd(first_menu, {"Статистика по прие~мам",;
                      "Информация по ~картотеке",;
                      "~Многовариантный поиск";
                     })
    aadd(first_message, { ;
       "Статистика по первичным врачебным приемам",;
       "Просмотр / печать списков по категориям, компаниям, районам, участкам,...",;
       "Многовариантный поиск в картотеке";
      })
    aadd(func_menu, {"regi_stat()",;
                     "prn_kartoteka()",;
                     "ne_real()" ;
                    })
    //
    aadd(cmain_menu,51)
    aadd(main_menu," ~Справочники ")
    aadd(main_message,"Ведение справочников")
    aadd(first_menu, {"Первичные ~приемы",0,;
                      "~Настройка (умолчания)";
                     })
    aadd(first_message, { ;  // справочники
       "Редактирование справочника по первичным врачебным приемам",;
       "Настройка значений по умолчанию";
      })
    aadd(func_menu, {"edit_priem()",;
                     "regi_nastr(2)";
                    })
    if is_r_mu  // регистр льготников
      Ins_Array(main_menu, 2, " ~Льготники ")
      Ins_Array(main_message, 2, "Поиск человека в федеральном регистре льготников")
      Ins_Array(cmain_menu, 2, 19)
      Ins_Array(first_menu, 2,;
                {"~Поиск","~Многовариантный поиск",0,'"~Наши" льготники'})
      Ins_Array(first_message, 2,;
                {"Поиск человека в регистре льготников, печать мед.карты по форме 025/у-04",;
                 "Многовариантный поиск по регистру льготников",;
                 "Сводная информация по нашему контингенту из федерального регистра льготников"})
      Ins_Array(func_menu, 2, {"r_mu_human()","r_mu_poisk()","r_mu_svod()"})
    endif
  case glob_task == X_PPOKOJ  //
    fl := begin_task_ppokoj()
    aadd(cmain_menu,1)
    aadd(main_menu," ~Приёмный покой ")
    aadd(main_message,"Ввод данных в приёмном покое стационара")
    aadd(first_menu, {"~Добавление",;
                      "~Редактирование",0,;
                      "В другое ~отделение",0,;
                      "~Удаление"})
    aadd(first_message, {;
        "Добавление истории болезни",;
        "Редактирование истории болезни и печать медицинской и стат.карты",;
        "Перевод больного из одного отделения в другое",;
        "Удаление истории болезни";
      } )
    aadd(func_menu, {"add_ppokoj()",;
                     "edit_ppokoj()",;
                     "ppokoj_perevod()",;
                     "del_ppokoj()"})
    aadd(cmain_menu,34)
    aadd(main_menu," ~Информация ")
    aadd(main_message,"Просмотр / печать статистики по больным")
    aadd(first_menu, {"~Журнал регистрации",;
                      "Журнал по ~запросу",0,;
                      "~Сводная информация",0,;
                      "~Перевод м/у отделениями",0,;
                      "Поиск ~ошибок"})
    aadd(first_message, {;
        "Просмотр/печать журнала регистрации стационарных больных",;
        "Просмотр/печать журнала регистрации стационарных больных по запросу",;
        "Подсчет количества принятых больных с разбивкой по отделениям",;
        "Получение информации о переводе между отделениями",;
        "Поиск ошибок ввода";
      } )
    aadd(func_menu, {"pr_gurnal_pp()",;
                     "z_gurnal_pp()",;
                     "pr_svod_pp()",;
                     "pr_perevod_pp()",;
                     "pr_error_pp()"})
    aadd(cmain_menu,51)
    aadd(main_menu," ~Справочники ")
    aadd(main_message,"Ведение справочников")
    aadd(first_menu, {"~Столы",;
                      "~Настройка"})
    aadd(first_message, {;
        "Работа со справочником столов",;
        "Настройка значений по умолчанию";
      } )
    aadd(func_menu, {"f_pp_stol()",;
                     "pp_nastr()"})
  case glob_task == X_OMS  //
    fl := begin_task_oms()
    aadd(cmain_menu,1)
    aadd(main_menu," ~ОМС ")
    aadd(main_message,"Ввод данных по обязательному медицинскому страхованию")
    aadd(first_menu, {"~Добавление",;
                      "~Редактирование",;
                      "Д~войные случаи",;
                      "Смена ~отделения",;
                      "~Удаление"} )
    aadd(first_message, { ;
        "Добавление листка учета лечения больного",;
        "Редактирование листка учета лечения больного",;
        "Добавление, просмотр, удаление двойных случаев",;
        "Редактирование листка учета лечения больного со сменой отделения",;
        "Удаление листка учета лечения больного";
      } )
    aadd(func_menu, {"oms_add()",;
                     "oms_edit()",;
                     "oms_double()",;
                     "oms_smena_otd()",;
                     "oms_del()"} )
    if yes_vypisan == B_END
      aadd(first_menu[1], "~Завершение лечения")
      aadd(first_message[1], "Режимы работы с завершением лечения")
      aadd(func_menu[1], "oms_zav_lech()")
    endif
    aadd(first_menu[1], 0)
    aadd(first_menu[1], "~Картотека")
    aadd(first_message[1], "Работа с картотекой")
    aadd(func_menu[1], "oms_kartoteka()")
    aadd(first_menu[1], 0)
    aadd(first_menu[1],"~Справка ОМС")
    aadd(first_message[1],"Ввод и распечатка справки о стоимости оказанной медицинской помощи в сфере ОМС")
    aadd(func_menu[1],"f_spravka_OMS()")
    //
    aadd(first_menu[1], 0)
    aadd(first_menu[1],"Изменение ~цен ОМС")
    aadd(first_message[1],"Изменение цен на услуги в соответствии со справочником услуг ТФОМС")
    aadd(func_menu[1],"Change_Cena_OMS()")
    //
    aadd(cmain_menu,cmain_next_pos(3))
    aadd(main_menu," ~Реестры ")
    aadd(main_message,"Ввод, печать и учет реестров случаев")
    aadd(first_menu, {"Про~верка",;
                      "~Составление",;
                      "~Просмотр",0,;
                      "Во~зврат",0})
    aadd(first_message, { ;
        "Проверка перед составлением реестра случаев",;
        "Составление реестра случаев",;
        "Просмотр реестра случаев, отправка в ТФОМС",;
        "Возврат реестра случаев"})
    aadd(func_menu, {"verify_OMS()",;
                     "create_reestr()",;
                     "view_list_reestr()",;
                     "vozvrat_reestr()"})
    if glob_mo[_MO_IS_UCH]
      aadd(first_menu[2], "П~рикрепления")
      aadd(first_message[2], "Просмотр файлов прикрепления (и ответов на них), запись файлов для ТФОМС")
      aadd(func_menu[2], "view_reestr_pripisnoe_naselenie()")
      aadd(first_menu[2], "~Открепления")
      aadd(first_message[2], "Просмотр полученных из ТФОМС файлов откреплений")
      aadd(func_menu[2], "view_otkrep_pripisnoe_naselenie()")
    endif
    aadd(first_menu[2], "~Ходатайства")
    aadd(first_message[2], "Просмотр, запись в ТФОМС, удаление файлов ходатайств")
    aadd(func_menu[2], "view_list_hodatajstvo()")
    //
    aadd(cmain_menu,cmain_next_pos(3))
    aadd(main_menu," ~Счета ")
    aadd(main_message,"Просмотр, печать и учет счетов по ОМС")
    aadd(first_menu, {"~Чтение из ТФОМС",;
                      "Список ~счетов",;
                      "~Регистрация",;
                      "~Акты контроля",;
                      "Платёжные ~документы",0,;
                      "~Прочие счета"} )
    aadd(first_message, { ;
        "Чтение информации из ТФОМС (из СМО)",;
        "Просмотр списка счетов по ОМС, запись для ТФОМС, печать счетов",;
        "Отметка о регистрации счетов в ТФОМС",;
        "Работа с актами контроля счетов (с реестрами актов контроля)",;
        "Работа с платёжными документами по оплате (с реестрами платёжных документов)",;
        "Работа с прочими счетами (создание, редактирование, возврат)",;
      } )
    aadd(func_menu, {"read_from_tf()",;
                     "view_list_schet()",;
                     "registr_schet()",;
                     "akt_kontrol()",;
                     "view_pd()",;
                     "other_schets()"} )
    //
    aadd(cmain_menu,cmain_next_pos(3))
    aadd(main_menu," ~Информация ")
    aadd(main_message,"Просмотр / печать общих справочников и статистики")
    aadd(first_menu, {"Лист ~учета",;
                      "~Статистика",;
                      "План-~заказ",;
                      "~Проверки",;
                      "Справо~чники",0,;
                      "Печать ~бланков"} )
    aadd(first_message, { ;
        "Просмотр / печать листов учета больных",;
        "Просмотр / печать статистики",;
        "Статистика по план-заказу",;
        "Различные проверки",;
        "Просмотр / печать общих справочников",;
        "Распечатка всевозможных бланков";
      } )
    aadd(func_menu, {"o_list_uch()",;
                     "e_statist()",;
                     "pz_statist()",;
                     "o_proverka()",;
                     "o_sprav()",;
                     "prn_blank()"} )
    if yes_parol
      aadd(first_menu[4], "Работа ~операторов")
      aadd(first_message[4], "Статистика по работе операторов за день и за месяц")
      aadd(func_menu[4], "st_operator()")
    endif
    //
    aadd(cmain_menu,cmain_next_pos(3))
    aadd(main_menu," ~Диспансеризация ")
    aadd(main_message,"Диспансеризация, профилактика, медосмотры и диспансерное наблюдение")
    aadd(first_menu, {"~Диспансеризация и профосмотры",0,;
                      "Диспансерное ~наблюдение"} )
    aadd(first_message, { ;
        "Диспансеризация, профилактика и медосмотры",;
        "Диспансерное наблюдение";
      } )
    aadd(func_menu, {"dispanserizacia()",;
                     "disp_nabludenie()"} ) 
  case glob_task == X_263 //
    fl := begin_task_263()
    if is_napr_pol
      aadd(cmain_menu,1)
      aadd(main_menu," ~Поликлиника ")
      aadd(main_message,"Ввод / редактирование направлений на госпитализацию по поликлинике")
      aadd(first_menu, {;//"~Проверка",0,;
                        "~Направления",;
                        "~Аннулирование",;
                        "~Информирование",0,;
                        "~Свободные койки",0,;
                        "~Картотека"} )
      aadd(first_message, { ;//"Проверка того, что ещё не сделано в поликлинике",;
          "Ввод / редактирование / просмотр направлений на госпитализацию по поликлинике",;
          "Аннулирование выписанных направлений на госпитализацию по поликлинике",;
          "Информирование наших пациентов о дате предстоящей госпитализации",;
          "Просмотр количества свободных коек по профилям в стационарах/дневных стационарах",;
          "Работа с картотекой";
        } )
      aadd(func_menu, {;//"_263_p_proverka()",;
                       "_263_p_napr()",;
                       "_263_p_annul()",;
                       "_263_p_inform()",;
                       "_263_p_svob_kojki()",;
                       "_263_kartoteka(1)"} )
    endif
    if is_napr_stac
      aadd(cmain_menu,15)
      aadd(main_menu," ~Стационар ")
      aadd(main_message,"Ввод даты госпитализации, учёт госпитализированных и выбывших по стационару")
      aadd(first_menu, {;//"~Проверка",0,;
                        "~Госпитализации",;
                        "~Выписка (выбытие)",;
                        "~Направления",;
                        "~Аннулирование",0,;
                        "~Свободные койки",0,;
                        "~Картотека"} )
      aadd(first_message, { ;// "Проверка того, что ещё не сделано в стационаре",;
          "Добавление / редактирование госпитализаций в стационаре",;
          "Выписка (выбытие) пациента из стационара",;
          "Список направлений, по которым ещё не было госпитализации",;
          "Аннулирование направлений, поступивших из поликлиник через ТФОМС",;
          "Ввод / редактирование количества свободных коек по профилям в стационаре",;
          "Работа с картотекой";
        } )
      aadd(func_menu, {;//"_263_s_proverka()",;
                       "_263_s_gospit()",;
                       "_263_s_vybytie()",;
                       "_263_s_napr()",;
                       "_263_s_annul()",;
                       "_263_s_svob_kojki()",;
                       "_263_kartoteka(2)"} )
    endif
    aadd(cmain_menu,29)
    aadd(main_menu," ~в ТФОМС ")
    aadd(main_message,"Отправка в ТФОМС файлов обмена (просмотр отправленных файлов)")
    aadd(first_menu, {"~Проверка перед составлением пакетов",;
                      "~Составление пакетов для отправки в ТФ",;
                      "Просмотр протоколов ~записи",0})
    aadd(first_message,  { ;   // информация
          "Проверка информации перед составлением пакетов и отправкой в ТФОМС",;
          "Составление информационных пакетов для отправки в ТФОМС",;
          "Просмотр протоколов составления информационных пакетов для отправки в ТФОМС";
         })
    aadd(func_menu, {;    // информация
          "_263_to_proverka()",;
          "_263_to_sostavlenie()",;
          "_263_to_protokol()";
         })
    k := len(first_menu)
    if is_napr_pol
      aadd(first_menu[k], "I0~1-выписанные направления")
      aadd(first_message[k], "Список информационных пакетов с выписанными направлениями")
      aadd(func_menu[k], "_263_to_I01()")
    endif
    aadd(first_menu[k], "I0~3-аннулированные направления")
    aadd(first_message[k], "Список информационных пакетов с аннулированными направлениями")
    aadd(func_menu[k], "_263_to_I03()")
    if is_napr_stac
      aadd(first_menu[k], "I0~4-госпитализации по направлениям")
      aadd(first_message[k], "Список информационных пакетов с госпитализациями по направлениям")
      aadd(func_menu[k], "_263_to_I04(4)")
      //
      aadd(first_menu[k], "I0~5-экстренные госпитализации")
      aadd(first_message[k], "Список информационных пакетов с госпитализациями без направлений (экстр.и неотл.)")
      aadd(func_menu[k], "_263_to_I04(5)")
      //
      aadd(first_menu[k], "I0~6-выбывшие пациенты")
      aadd(first_message[k], "Список информационных пакетов со сведениями о выбывших пациентах")
      aadd(func_menu[k], "_263_to_I06()")
    endif
    aadd(first_menu[k],0)
    aadd(first_menu[k], "~Настройка каталогов")
    aadd(first_message[k], "Настройка каталогов обмена - куда записывать созданные для ТФОМС файлы")
    aadd(func_menu[k], "_263_to_nastr()")
    //
    aadd(cmain_menu,39)
    aadd(main_menu," из ~ТФОМС ")
    aadd(main_message,"Получение из ТФОМС файлов обмена и просмотр полученных файлов")
    aadd(first_menu, {"~Чтение из ТФОМС",;
                      "~Просмотр протоколов чтения",0})
    aadd(first_message,  { ;   // информация
          "Получение из ТФОМС файлов обмена (информационных пакетов)",;
          "Просмотр протоколов чтения информационных пакетов из ТФОМС";
         })
    aadd(func_menu, {;
          "_263_from_read()",;
          "_263_from_protokol()";
         })
    k := len(first_menu)
    if is_napr_stac
      aadd(first_menu[k], "I0~1-полученные направления")
      aadd(first_message[k], "Список информационных пакетов с полученными направлениями от поликлиник")
      aadd(func_menu[k], "_263_from_I01()")
    endif
    aadd(first_menu[k], "I0~3-аннулированные направления")
    aadd(first_message[k], "Список информационных пакетов с аннулированными направлениями")
    aadd(func_menu[k], "_263_from_I03()")
    if is_napr_pol
      aadd(first_menu[k], "I0~4-госпитализации по направлениям")
      aadd(first_message[k], "Список информационных пакетов с госпитализациями по направлениям")
      aadd(func_menu[k], "_263_from_I04()")
      //
      aadd(first_menu[k], "I0~5-экстренные госпитализации")
      aadd(first_message[k], "Список информационных пакетов с госпитализациями без направлений (экстр.и неотл.)")
      aadd(func_menu[k], "_263_from_I05()")
      //
      aadd(first_menu[k], "I0~6-выбывшие пациенты")
      aadd(first_message[k], "Список информационных пакетов со сведениями о выбывших пациентах")
      aadd(func_menu[k], "_263_from_I06()")
      //
      aadd(first_menu[k], "I0~7-наличие свободных мест")
      aadd(first_message[k], "Список информационных пакетов со сведениями о наличии свободных мест")
      aadd(func_menu[k], "_263_from_I07()")
    endif
    aadd(first_menu[k],0)
    aadd(first_menu[k], "~Настройка каталогов")
    aadd(first_message[k], "Настройка каталогов обмена - откуда зачитывать полученные из ТФОМС файлы")
    aadd(func_menu[k], "_263_to_nastr()")
    //
  case glob_task == X_PLATN //
    fl := begin_task_plat()
    aadd(cmain_menu,1)
    aadd(main_menu," ~Платные услуги ")
    aadd(main_message,"Ввод / редактирование данных из листов учета платных медицинских услуг")
    aadd(first_menu, {"~Ввод данных"} )
    aadd(first_message, {"Добавление/Редактирование листка учета лечения платного больного"} )
    aadd(func_menu, {"kart_plat()"} )
    if glob_pl_reg == 1
      aadd(first_menu[1], "~Поиск/ред-ие")
      aadd(first_message[1], "Поиск/Редактирование листов учета лечения платных больных")
      aadd(func_menu[1], "poisk_plat()")
    endif
    aadd(first_menu[1], 0)
    aadd(first_menu[1], "~Картотека")
    aadd(first_message[1], "Работа с картотекой")
    aadd(func_menu[1], "oms_kartoteka()")
    aadd(first_menu[1], 0)
    aadd(first_menu[1], "~Оплата ДМС и в/з")
    aadd(first_message[1], "Ввод/редактирование оплат по взаимозачету и добровольному мед.страхованию")
    aadd(func_menu[1], "oplata_vz()")
    aadd(first_menu[1], 0)
    aadd(first_menu[1], "~Закрытие л/учета")
    aadd(first_message[1], "Закрыть лист учета (снять признак закрытия с листа учета)")
    aadd(func_menu[1], "close_lu()")
    //
    aadd(cmain_menu,34)
    aadd(main_menu," ~Информация ")
    aadd(main_message,"Просмотр / печать общих справочников и статистики")
    aadd(first_menu, {"~Статистика",;
                      "Спра~вочники",;
                      "~Проверки"})
    aadd(first_message,  { ;   // информация
          "Просмотр статистики",;
          "Просмотр общих справочников",;
          "Различные проверочные режимы";
         })
    aadd(func_menu, {;    // информация
          "Po_statist()",;
          "o_sprav()",;
          "Po_proverka()";
         })
    if glob_kassa == 1
      aadd(first_menu[2], 0)
      aadd(first_menu[2], "Работа с ~кассой")
      aadd(first_message[2], "Информация по работе с кассой")
      aadd(func_menu[2], "inf_fr()")
    endif
    if yes_parol
      aadd(first_menu[2], 0)
      aadd(first_menu[2], "Работа ~операторов")
      aadd(first_message[2], "Статистика по работе операторов за день и за месяц")
      aadd(func_menu[2], "st_operator()")
    endif
    //
    aadd(cmain_menu,50)
    aadd(main_menu," ~Справочники ")
    aadd(main_message,"Ведение справочников")
    aadd(first_menu,{})
    aadd(first_message,{})
    aadd(func_menu,{})
    if is_oplata != 7
      aadd(first_menu[3], "~Медсестры")
      aadd(first_message[3], "Справочник медсестер для платных услуг")
      aadd(func_menu[3], "s_pl_meds(1)")
      //
      aadd(first_menu[3], "~Санитарки")
      aadd(first_message[3], "Справочник санитарок для платных услуг")
      aadd(func_menu[3], "s_pl_meds(2)")
    endif
    aadd(first_menu[3], "Предприятия (в/~зачет)")
    aadd(first_message[3], "Справочник предприятий, работающих по взаимозачету")
    aadd(func_menu[3], "edit_pr_vz()")
    //
    aadd(first_menu[3], "~Добровольные СМО") ; aadd(first_menu[3], 0)
    aadd(first_message[3], "Справочник страховых компаний, осуществляющих добровольное мед.страхование")
    aadd(func_menu[3], "edit_d_smo()")
    //
    aadd(first_menu[3], "Услуги по дата~м")
    aadd(first_message[3], "Редактирование справочника услуг, цена по которым действует с какой-то даты")
    aadd(func_menu[3], "f_usl_date()")
    if glob_kassa == 1
      aadd(first_menu[3], 0)
      aadd(first_menu[3], "Работа с ~кассой")
      aadd(first_message[3], "Настройка работы с кассовым аппаратом")
      aadd(func_menu[3], "fr_nastrojka()")
    endif
  case glob_task == X_ORTO  //
    fl := begin_task_orto()
    aadd(cmain_menu,1)
    aadd(main_menu," ~Ортопедия ")
    aadd(main_message,"Ввод данных по ортопедическим услугам в стоматологии")
    aadd(first_menu, {"~Открытие наряда",;
                      "~Закрытие наряда",0,;
                      "~Картотека"})
    aadd(first_message,  {;
         "Открытие наряда-заказа (добавление листка учета лечения больного)",;
         "Закрытие наряда-заказа (редактирование листка учета лечения больного)",;
         "Работа с картотекой"} )
    aadd(func_menu, {"kart_orto(1)",;
                     "kart_orto(2)",;
                     "oms_kartoteka()"})
    //
    aadd(cmain_menu,34)
    aadd(main_menu," ~Информация ")
    aadd(main_message,"Просмотр / печать общих справочников и статистики")
    aadd(first_menu, {"~Статистика",;
                      "Спра~вочники",;
                      "~Проверки"})
    aadd(first_message,  { ;   // информация
          "Просмотр статистики",;
          "Просмотр общих справочников",;
          "Различные проверочные режимы";
         })
    aadd(func_menu, {;    // информация
          "Oo_statist()",;
          "o_sprav(-5)",;   // X_ORTO = 5
          "Oo_proverka()";
         })
    if glob_kassa == 1   //10.10.14
      aadd(first_menu[2], 0)
      aadd(first_menu[2], "Работа с ~кассой")
      aadd(first_message[2], "Информация по работе с кассой")
      aadd(func_menu[2], "inf_fr_orto()")
    endif
    if yes_parol
      aadd(first_menu[2], 0)
      aadd(first_menu[2], "Работа ~операторов")
      aadd(first_message[2], "Статистика по работе операторов за день и за месяц")
      aadd(func_menu[2], "st_operator()")
    endif
    //
    aadd(cmain_menu,50)
    aadd(main_menu," ~Справочники ")
    aadd(main_message,"Ведение справочников")
    aadd(first_menu,;
      {"Ортопедические ~диагнозы",;
       "Причины ~поломок",;
       "~Услуги без врачей",0,;
       "Предприятия (в/~зачет)",;
       "~Добровольные СМО",0,;
       "~Материалы";
      })
    aadd(first_message,;
      {"Редактирование справочника ортопедических диагнозов",;
       "Редактирование справочника причин поломок протезов",;
       "Ввод/редактирование услуг, у которых не вводится врач (техник)",;
       "Справочник предприятий, работающих по взаимозачету",;
       "Справочник страховых компаний, осуществляющих добровольное мед.страхование",;
       "Справочник приведенных расходуемых материалов";
      })
    aadd(func_menu,;
      {"orto_diag()",;
       "f_prich_pol()",;
       "f_orto_uva()",;
       "edit_pr_vz()",;
       "edit_d_smo()",;
       "edit_ort()";
      })
    if glob_kassa == 1
      aadd(first_menu[3], 0)
      aadd(first_menu[3], "Работа с ~кассой")
      aadd(first_message[3], "Настройка работы с кассовым аппаратом")
      aadd(func_menu[3], "fr_nastrojka()")
    endif
  case glob_task == X_KASSA //
    fl := begin_task_kassa()
    //
    aadd(cmain_menu,1)
    aadd(main_menu," ~Касса МО ")
    aadd(main_message,"Ввод данных в кассе МО по платным услугам")
    aadd(first_menu, {"~Ввод данных",0,;
                      "~Картотека"})
    aadd(first_message,  {;
         "Добавление листка учета лечения платного больного",;
         "Ввод/редактирование картотеки (регистратура)"})
    aadd(func_menu, {"kas_plat()",;
                     "oms_kartoteka()"})
    aadd(first_menu[1],0)
    aadd(first_menu[1],"~Справка ОМС")
    aadd(first_message[1],"Ввод и распечатка справки о стоимости оказанной медицинской помощи в сфере ОМС")
    aadd(func_menu[1],"f_spravka_OMS()")
    //
    if is_task(X_ORTO)
      aadd(cmain_menu,cmain_next_pos())
      aadd(main_menu," ~Ортопедия ")
      aadd(main_message,"Ввод данных по ортопедическим услугам")
      aadd(first_menu,{"~Новый наряд",;
                       "~Редактирование наряда",0,;
                       "~Картотека"})
      aadd(first_message,{;
           "Открытие сложного наряда или ввод простого ортопедического наряда",;
           "Редактирование ортопедического наряда (в т.ч. доплата или возврат денег)",;
           "Ввод/редактирование картотеки (регистратура)"})
      aadd(func_menu,{"f_ort_nar(1)",;
                      "f_ort_nar(2)",;
                      "oms_kartoteka()"})
    endif
    //
    aadd(cmain_menu,cmain_next_pos())
    aadd(main_menu," ~Информация ")
    aadd(main_message,"Просмотр / печать")
    aadd(first_menu, {iif(is_task(X_ORTO),"~Платные услуги","~Статистика"),;
                      "Сводная с~татистика",; //10.05
                      "Спра~вочники",;
                      "Работа с ~кассой"})
    aadd(first_message,  { ;   // информация
          "Просмотр / печать статистических отчетов по платным услугам",;
          "Просмотр / печать сводных статистических отчетов",;
          "Просмотр общих справочников",;
          "Информация по работе с кассой";
         })
    aadd(func_menu, {;    // информация
          "prn_k_plat()",;
          "regi_s_plat()",;
          "o_sprav()",;
          "prn_k_fr()";
         })
    if is_task(X_ORTO)
      Ins_Array(first_menu[3],2,"~Ортопедия")
      Ins_Array(first_message[3],2,"Просмотр / печать статистических отчетов по ортопедии")
      Ins_Array(func_menu[3],2,"prn_k_ort()")
    endif
    //
    aadd(cmain_menu,cmain_next_pos())
    aadd(main_menu," ~Справочники ")
    aadd(main_message,"Просмотр / редактирование справочников")
    aadd(first_menu,{"~Услуги со сменой цены",;
                     "~Разовые услуги",;
                     "Работа с ~кассой",0,;
                     "~Настройка программы"})
    aadd(first_message,{;
         "Редактирование списка услуг, при вводе которых разрешается редактировать цену",;
         "Редактирование списка услуг, не выводимых в журнал договоров (если 1 в чеке)",;
         "Настройка работы с кассовым аппаратом",;
         "Настройка программы (некоторых значений по умолчанию)"})
    aadd(func_menu,{"fk_usl_cena()",;
                    "fk_usl_dogov()",;
                    "fr_nastrojka()",;
                    "nastr_kassa(2)"})
  case glob_task == X_KEK  //
    if !between(grup_polzovat,1,3)
      n_message({"Недопустимая группа экспертизы (КЭК): "+lstr(grup_polzovat),;
                 '',;
                 'Пользователям, которым разрешено работать в подзадаче "КЭК МО",',;
                 'необходимо установить группу экспертизы (от 1 до 3)',;
                 'в подзадаче "Редактирование справочников" в режиме "Справочники/Пароли"'},,;
                "GR+/R","W+/R",,,"G+/R")
    else
      fl := begin_task_kek()
      aadd(cmain_menu,1)
      aadd(main_menu," ~КЭК ")
      aadd(main_message,"Ввод данных по КЭК медицинской организации")
      aadd(first_menu, {"~Добавление",;
                        "~Редактирование",;
                        "~Удаление"} )
      aadd(first_message, { ;
          "Добавление данных по экпертизе",;
          "Редактирование данных по экпертизе",;
          "Удаление данных по экпертизе";
        } )
      aadd(func_menu, {"kek_vvod(1)",;
                       "kek_vvod(2)",;
                       "kek_vvod(3)"} )
      aadd(cmain_menu,34)
      aadd(main_menu," ~Информация ")
      aadd(main_message,"Просмотр / печать статистики по экспертизам")
      aadd(first_menu, {"~Экспертная карта",;
                        "Оценка ~качества"} )
      aadd(first_message, {;
          "Распечатка экспертной карты",;
          "Распечатка раличных отчётов по оцеке качества экспертизы"} )
      aadd(func_menu, {"kek_prn_eks()",;
                       "kek_info2017()"})
      aadd(cmain_menu,51)
      aadd(main_menu," ~Справочники ")
      aadd(main_message,"Ведение справочников")
      aadd(first_menu, {"~Настройка"})
      aadd(first_message, {"Настройка значений по умолчанию"} )
      aadd(func_menu, {"kek_nastr()"})
    endif
  case glob_task == X_MO //
    fl := my_mo_begin_task()
    my_mo_f1main()
  case glob_task == X_SPRAV //
    fl := begin_task_sprav()
    //
    aadd(cmain_menu,1)
    aadd(main_menu," ~Справочники ")
    aadd(main_message,"Редактирование справочников")
    aadd(first_menu, {"~Структура организации",;
                      "Справочник ~услуг",;
                      "П~рочие справочники",0,;
                      "~Пользователи",;
                      "~Группы пользователей"} )
    aadd(first_message, { ;
        "Редактирование справочников персонала, отделений, учреждений, организации",;
        "Редактирование справочника услуг",;
        "Редактирование прочих справочников",;
        "Редактирование справочника пользователей системы",;
        "Редактирование справочника групп пользователей в системе";
      } )
    aadd(func_menu, {"spr_struct_org()",;
                     "edit_spr_uslugi()",;
                     "edit_proch_spr()",;
                     "edit_Users_bay()",;   //"edit_password()",;
                     "editRoles()"} )
    //
    aadd(cmain_menu,40)
    aadd(main_menu," ~Информация ")
    aadd(main_message,"Просмотр/печать справочников")
    aadd(first_menu, {"~Общие справочники"} )
    aadd(first_message, { ;
        "Просмотр/печать общих справочников";
      } )
    aadd(func_menu, {"o_sprav()"} )
  case glob_task == X_SERVIS //
    aadd(cmain_menu,1)
    aadd(main_menu," ~Сервисы ")
    aadd(main_message,"Сервисы и настройки")
    //
    if glob_mo[_MO_KOD_TFOMS] == '395301' // Камышин СТОМ
      aadd(first_menu, {"~Проверка целостности",0,;
                        "Изменение ~цен ОМС",0,;
                        "~Импорт",;
                        "~Экспорт",;
                        "~Материалы"} )
      aadd(first_message, { ;
          "Проверка целостности базы данных на файл-сервере",;
          "Изменение цен на услуги в соответствии со справочником услуг ТФОМС",;
          "Различные варианты импорта из других программ",;
          'Различные варианты экспорта в другие программы/организации',;
          "Справочник приведенных расходуемых материалов";
        } )
      aadd(func_menu, {"prover_dbf(,.f.,(tip_polzovat==0))",;
                       "Change_Cena_OMS()",;
                       "f_import()",;
                       "f_export()",;
                       "edit_ort()"} )

    else
      aadd(first_menu, {"~Проверка целостности",0,;
                        "Изменение ~цен ОМС",0,;
                        "~Импорт",;
                        "~Экспорт"} )
      aadd(first_message, { ;
          "Проверка целостности базы данных на файл-сервере",;
          "Изменение цен на услуги в соответствии со справочником услуг ТФОМС",;
          "Различные варианты импорта из других программ",;
          'Различные варианты экспорта в другие программы/организации';
        } )
      aadd(func_menu, {"prover_dbf(,.f.,(tip_polzovat==0))",;
                       "Change_Cena_OMS()",;
                       "f_import()",;
                       "f_export()"} )
    endif
    //
    aadd(cmain_menu,20)
    aadd(main_menu," ~Настройки ")
    aadd(main_message,"Настройки")
    aadd(first_menu, {"~Общие настройки",0,;
                      "Справочники ~ФФОМС",0,;
                      "~Рабочее место"} )
    aadd(first_message, { ;
        "Общие настройки каждой задачи",;
        "Настройка содержимого справочников ФФОМС (уменьшение количества строк)",;
        "Настройка рабочего места";
      } )
    aadd(func_menu, {"nastr_all()",;
                     "nastr_sprav_FFOMS()",;
                     "nastr_rab_mesto()"} )
    aadd(cmain_menu,50)
    aadd(main_menu," Прочие ~отчёты ")
    aadd(main_message,"Редко используемые (устаревшие) отчёты")
    //
    if glob_mo[_MO_KOD_TFOMS] == '395301' // Камышин СТОМ
      aadd(first_menu, { ;
                  "~Новые пациенты",;
                  "Информация о количестве удалённых ~зубов",;
                  "~Модернизация",;
                  "письмо №792 ВОМИА~Ц",;
                  "Мониторин~г по видам мед.помощи",;
                  "Телефонограмма №~15 ВО КЗ",;
                  "Сведения для б-цы ~25 и пер.центра 2",;
                  "~Расход материалов"})
      aadd(first_message, { ;
                  "Журнал регистрации новых пациентов",;
                  "Информация о количестве удалённых постоянных зубов с 2005 по 2015 годы",;
                  "Статистика по модернизации",;
                  "Подготовка формы согласно приложению к письму ВОМИАЦ №792 от 16.06.2017г.",;
                  "Мониторинг по видам медицинской помощи для Комитета здравоохранения ВО",;
                  "Информация по стационарному лечению лиц пожилого возраста за 2017 год",;
                  "Сведения о фактических затратах на оказание медицинской помощи",;
                  "Ведомость по расходу материалов на протезирование"})
      aadd(func_menu, {'run_my_hrb("mo_hrb1","i_new_boln()")',;
                       'run_my_hrb("mo_hrb1","i_kol_del_zub()")',;
                       "modern_statist()",;
                       'run_my_hrb("mo_hrb1","forma_792_MIAC()")',;
                       'run_my_hrb("mo_hrb1","monitoring_vid_pom()")',;
                       'run_my_hrb("mo_hrb1","phonegram_15_kz()")',;
                       'run_my_hrb("mo_hrb1","b_25_perinat_2()")',;
                       'Ort_OMS_material()'} )
    else
      aadd(first_menu, { ;
                  "~Новые пациенты",;
                  "Информация о количестве удалённых ~зубов",;
                  "~Модернизация",;
                  "письмо №792 ВОМИА~Ц",;
                  "Мониторин~г по видам мед.помощи",;
                  "Телефонограмма №~15 ВО КЗ",;
                  "Сведения для б-цы ~25 и пер.центра 2"})
      aadd(first_message, { ;
                  "Журнал регистрации новых пациентов",;
                  "Информация о количестве удалённых постоянных зубов с 2005 по 2015 годы",;
                  "Статистика по модернизации",;
                  "Подготовка формы согласно приложению к письму ВОМИАЦ №792 от 16.06.2017г.",;
                  "Мониторинг по видам медицинской помощи для Комитета здравоохранения ВО",;
                  "Информация по стационарному лечению лиц пожилого возраста за 2017 год",;
                  "Сведения о фактических затратах на оказание медицинской помощи"})
      aadd(func_menu, {'run_my_hrb("mo_hrb1","i_new_boln()")',;
                       'run_my_hrb("mo_hrb1","i_kol_del_zub()")',;
                       "modern_statist()",;
                       'run_my_hrb("mo_hrb1","forma_792_MIAC()")',;
                       'run_my_hrb("mo_hrb1","monitoring_vid_pom()")',;
                       'run_my_hrb("mo_hrb1","phonegram_15_kz()")',;
                       'run_my_hrb("mo_hrb1","b_25_perinat_2()")'} )
    endif
  case glob_task == X_COPY //
    aadd(cmain_menu,1)
    aadd(main_menu," ~Резервное копирование ")
    aadd(main_message,"Резервное копирование базы данных")
    aadd(first_menu, {;
        'Копирование ~базы данных',;
        'Отправка базы ~данных';
        })
    aadd(first_message, { ;
        'Резервное копирование базы данных',;
        'Резервное копирование базы данных и отправка копии службу поддержки';
      } )
    aadd(func_menu, {;
        'm_copy_DB(1)',;
        'm_copy_DB(2)';
      })
  case glob_task == X_INDEX //
    aadd(cmain_menu,1)
    aadd(main_menu," ~Переиндексирование ")
    aadd(main_message,"Переиндексирование базы данных")
    aadd(first_menu, {"~Переиндексирование"} )
    aadd(first_message, { ;
        "Переиндексирование базы данных";
      } )
    aadd(func_menu, {"m_index_DB()"} )
endcase
// последнее меню для всех одно и то же
aadd(cmain_menu,maxcol()-9)
aadd(main_menu," Помо~щь ")
aadd(main_message,"Помощь, настройка принтера")
aadd(first_menu, {"~Новое в программе",;
                  "Помо~щь",;
                  "~Рабочее место",;
                  "~Принтер",0,;
                  "Сетевой ~монитор",;
                  "~Ошибки"})
aadd(first_message, { ;
   "Вывод на экран содержания файла README.RTF с текстом нового в программе",;
   "Вывод на экран экрана помощи",;
   "Настройка рабочего места",;
   "Установка кодов принтера",;
   "Режим просмотра - кто находится в задаче и в каком режиме",;
   "Просмотр файла ошибок"})
aadd(func_menu, {"file_Wordpad(exe_dir + cslash + 'README.RTF')",;
                 "m_help()",;
                 "nastr_rab_mesto()",;
                 "ust_printer(T_ROW)",;
                 "net_monitor(T_ROW,T_COL-7,(tip_polzovat==0))",;
                 "view_errors()"})
// добавим переиндексирование некоторых файлов внутри задачи
if eq_any(glob_task,X_PPOKOJ,X_OMS,X_PLATN,X_ORTO,X_KASSA,X_KEK,X_263)
  aadd(atail(first_menu),0)
  aadd(atail(first_menu),"Пере~индексирование")
  aadd(atail(first_message),'Переиндексирование части базы данных для задачи "'+array_tasks[ind_task(),5]+'"')
  aadd(atail(func_menu),"pereindex_task()")
endif
if fl
  G_SPlus(f_name_task())   // плюс 1 пользователь зашёл в задачу
  func_main(.t.,blk_ekran)
  G_SMinus(f_name_task())  // минус 1 пользователь (вышел из задачи)
endif
return NIL

***** 25.05.13 подсчитать следующую позицию для главного меню задачи
Static Function cmain_next_pos(n)
DEFAULT n TO 5
return atail(cmain_menu)+len(atail(main_menu))+n

***** 05.11.15
Function my_mo_f1main()
  Local old := is_uchastok

  if glob_mo[_MO_KOD_TFOMS] == kod_VOUNC
    is_uchastok := 1 // буква + № участка + № в участке "У25/123"
    vounc_f1main()
    is_uchastok := old
  endif
  return NIL
