#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function menu_X_common()

  // последнее меню для всех одно и то же
  AAdd( cmain_menu, MaxCol() -9 )
  AAdd( main_menu, ' Помо~щь ' )
  AAdd( main_message, 'Помощь, настройка принтера' )
  AAdd( first_menu, { '~Новое в программе', ;
    'Помо~щь', ;
    '~Рабочее место', ;
    '~Принтер', 0, ;
    'Переиндексация рабочего каталога', ;
    'Сетевой ~монитор', ;
    '~Ошибки' } )
  AAdd( first_message, { ;
    'Вывод на экран содержания файла README.RTF с текстом нового в программе', ;
    'Вывод на экран экрана помощи', ;
    'Настройка рабочего места', ;
    'Установка кодов принтера', ;
    'Переидексирование справочников НСИ в рабочем каталоге', ;
    'Режим просмотра - кто находится в задаче и в каком режиме', ;
    'Просмотр файла ошибок' } )
  AAdd( func_menu, { 'view_file_in_Viewer(dir_exe() + "README.RTF")', ;
    'm_help()', ;
    'nastr_rab_mesto()', ;
    'ust_printer(T_ROW)', ;
    'index_work_dir(dir_exe(), cur_dir(), .t.)', ;
    'net_monitor(T_ROW, T_COL - 7, (hb_user_curUser:IsAdmin()))', ;
    'view_errors()' } )
// добавим переиндексирование некоторых файлов внутри задачи
  If eq_any( glob_task, X_PPOKOJ, X_OMS, X_PLATN, X_ORTO, X_KASSA, X_263 )
    AAdd( ATail( first_menu ), 0 )
    AAdd( ATail( first_menu ), 'Пере~индексирование' )
    AAdd( ATail( first_message ), 'Переиндексирование части базы данных для задачи "' + array_tasks[ ind_task(), 5 ] + '"' )
    AAdd( ATail( func_menu ), 'pereindex_task()' )
  Endif
  return nil