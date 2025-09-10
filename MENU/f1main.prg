#include "common.ch"
#include "set.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 10.09.25
Function f1main( n_Task )
  
  Local it, fl := .t., cNameIcon

  If ( it := AScan( array_tasks(), {| x| x[ 2 ] == n_Task } ) ) == 0
    Return func_error( "Ошибка в вызове задачи" )
  Endif
  cNameIcon := iif( array_tasks()[ it, 3 ] == NIL, "MAIN_ICON", array_tasks()[ it, 3 ] )
  glob_task := n_Task
  sys_date := Date()
  c4sys_date := dtoc4( sys_date )
  blk_ekran := {|| DevPos( MaxRow() -2, MaxCol() -Len( dir_server() ) ), ;
    DevOut( Upper( dir_server() ), "W+/N*" ) }
  main_menu := {}
  main_message := {}
  first_menu := {}
  first_message := {}
  func_menu := {}
  cmain_menu := {}
  put_icon( array_tasks()[ it, 1 ] + ' ' + short_name_version(), cNameIcon )
  SetColor( color1 )
  fillscreen( p_char_screen, p_color_screen )
  Do Case
  Case glob_task == X_REGIST //
    fl := menu_X_registr()
  Case glob_task == X_PPOKOJ  //
    fl := menu_X_prokoj()
  Case glob_task == X_OMS  //
    fl := menu_X_oms()
  Case glob_task == X_263 //
    fl := menu_X_263()
  Case glob_task == X_PLATN //
    fl := menu_X_platn()
  Case glob_task == X_ORTO  //
    fl := menu_X_orto()
  Case glob_task == X_KASSA //
    fl := menu_X_kassa()
  Case glob_task == X_MO //
    fl := menu_X_vounc()
  Case glob_task == X_SPRAV //
    fl := menu_X_sprav()
  Case glob_task == X_SERVIS //
    menu_X_servis()
  Case glob_task == X_COPY //
    menu_X_copy()
  Case glob_task == X_INDEX //
    menu_X_index()
  Endcase
  menu_X_common()
  If fl
    g_splus( f_name_task() )   // плюс 1 пользователь зашёл в задачу
    func_main( .t., blk_ekran )
    g_sminus( f_name_task() )  // минус 1 пользователь (вышел из задачи)
  Endif
  Return Nil

// 18.05.25 подсчитать следующую позицию для главного меню задачи
Function cmain_next_pos( n )

  Default n To 5

  Return ATail( cmain_menu ) + Len( ATail( main_menu ) ) + n