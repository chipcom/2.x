#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 09.09.25 инициализация массива МО, запрос кода МО (при необходимости)
Function init_mo()

  Local fl := .t., i, cCode := '', buf := save_maxrow()

  test_init()

  mywait()
  Public glob_arr_mo := {}, glob_mo
  
  Public oper_parol := 30  // пароль для фискального регистратора
  Public oper_frparol := 30 // пароль для фискального регистратора ОТЧЕТ
  Public oper_fr_inn  := '' // ИНН кассира
  Public oper_dov_date   := Date()  // дата доверенности
  Public oper_dov_nomer  := Space( 20 )  // номер доверенности
  Public glob_podr := ''

  glob_arr_mo := glob_arr_mo()

  If hb_FileExists( dir_server() + 'organiz' + sdbf() )
    r_use( dir_server() + 'organiz',, 'ORG' )
    If LastRec() > 0
      cCode := Left( org->kod_tfoms, 6 )
    Endif
  Endif
  dbCloseAll()
  If !Empty( cCode )
    If ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == cCode } ) ) > 0
      glob_mo := glob_mo( glob_arr_mo()[ i ] )
      If ( i := AScan( glob_adres_podr(), {| x| x[ 1 ] == glob_mo()[ _MO_KOD_TFOMS ] } ) ) > 0
        is_adres_podr( .t. )
      Endif
    Else
      func_error( 4, 'В справочник занесён несуществующий код МО "' + cCode + '". Введите его заново.' )
      cCode := ''
    Endif
  Endif
  If Empty( cCode )
    If ( cCode := input_value( 18, 2, 20, 77, color1, ;
        'Введите код МО или обособленного подразделения, присвоенный ТФОМС', ;
        Space( 6 ), '999999' ) ) != Nil .and. !Empty( cCode )
      If ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == cCode } ) ) > 0
        glob_mo := glob_mo( glob_arr_mo()[ i ] )
        If hb_FileExists( dir_server() + 'organiz' + sdbf() )
          g_use( dir_server() + 'organiz', , 'ORG' )
          If LastRec() == 0
            addrecn()
          Else
            g_rlock( forever )
          Endif
          org->kod_tfoms := glob_mo()[ _MO_KOD_TFOMS ]
          org->name_tfoms := glob_mo()[ _MO_SHORT_NAME ]
          org->uroven := get_uroven()
        Endif
        Close databases
        dbCloseAll()
      Else
        fl := func_error( 'Работа невозможна - введённый код МО "' + cCode + '" неверен.' )
      Endif
    Endif
  Endif
  If Empty( cCode )
    fl := func_error( 'Работа невозможна - не введён код МО.' )
  Endif
  rest_box( buf )
  If ! fl
    hard_err( 'delete' )
    app_finish()
  Endif
  Return main_up_screen()
