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
//  Public glob_podr_2 := ''
//  Public is_adres_podr := .f.
//  Public glob_adres_podr := { ;
//    { '103001', { { '103001', 1, 'г.Волгоград, ул.Землячки, д.78' }, ;
//    { '103099', 2, 'г.Михайловка, ул.Мичурина, д.8' }, ;
//    { '103099', 3, 'г.Волжский, ул.Комсомольская, д.25' }, ;
//    { '103099', 4, 'г.Волжский, ул.Оломоуцкая, д.33' }, ;
//    { '103099', 5, 'г.Камышин, ул.Днепровская, д.43' }, ;
//    { '103099', 6, 'г.Камышин, ул.Мира, д.51' }, ;
//    { '103099', 7, 'г.Урюпинск, ул.Фридек-Мистек, д.8' } };
//    }, ;
//    { '101003', { { '101003', 1, 'г.Волгоград, ул.Циолковского, д.1' }, ;
//    { '101099', 2, 'г.Волгоград, ул.Советская, д.47' } };
//    }, ;
//    { '131001', { { '131001', 1, 'г.Волгоград, ул.Кирова, д.10' }, ;
//    { '131099', 2, 'г.Волгоград, ул.Саши Чекалина, д.7' }, ;
//    { '131099', 3, 'г.Волгоград, ул.им.Федотова, д.18' } };
//    }, ;
//    { '171004', { { '171004', 1, 'г.Волгоград, ул.Ополченская, д.40' }, ;
//    { '171099', 2, 'г.Волгоград, ул.Тракторостроителей, д.13' } };
//    };
//    }

//  create_mo_add()
//  glob_arr_mo := getmo_mo( '_mo_mo' )
  glob_arr_mo := glob_arr_mo()

  If hb_FileExists( dir_server() + 'organiz' + sdbf() )
    r_use( dir_server() + 'organiz',, 'ORG' )
    If LastRec() > 0
      cCode := Left( org->kod_tfoms, 6 )
    Endif
  Endif
//  Close databases
  dbCloseAll()
  If !Empty( cCode )
//    If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == cCode } ) ) > 0
//      glob_mo := glob_arr_mo[ i ]
    If ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == cCode } ) ) > 0
      glob_mo := glob_mo( glob_arr_mo()[ i ] )
//      If ( i := AScan( glob_adres_podr, {| x| x[ 1 ] == glob_mo[ _MO_KOD_TFOMS ] } ) ) > 0
      If ( i := AScan( glob_adres_podr(), {| x| x[ 1 ] == glob_mo()[ _MO_KOD_TFOMS ] } ) ) > 0
//        is_adres_podr := .t.
        is_adres_podr( .t. )
//        glob_podr_2 := glob_adres_podr()[ i, 2, 2, 1 ] // второй код для удалённого адреса
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
//      If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == cCode } ) ) > 0
//        glob_mo := glob_arr_mo[ i ]
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
