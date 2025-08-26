// mo_fr.prg - работа с фискальным регистратором
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"
#include "f_fr.ch"

#require "hbwin"

Static emailTemplate := "^[-._a-z0-9]+@(?:[a-z0-9][-a-z0-9]+\.)+[a-z]{2,6}$"
Static phoneTemplate := "^(\s*)?(\+)?([- _():=+]?\d[- _():=+]?){10,14}(\s*)?$"

//
Function fr_nastrojka( k )

  Static si1 := 1, si2 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "~Настройка работы с КАССОЙ", ;
      "Снятие суточного ~отчета с гашением", ;
      "Снятие суточного отчета ~без гашения", ;
      "Снятие суточного отчета по ~СЕКЦИЯМ", ;
      "Снятие суточного отчета по ~НАЛОГАМ", ;
      "Продолжение ~печати", ;
      "~Аннулирование непробитого чека", ;
      "Установка ~даты в ФР", ;
      "Синхронизация ~времени", ;
      "~Запись КАССИРОВ в ФР" }
    mas_msg := { "Настройка работы с кассой (номер порта, сдача, протокол и т.п.)", ;
      "Снятие суточного отчета c гашением", ;
      "Снятие суточного отчета без гашения", ;
      "Снятие суточного отчета по СЕКЦИЯМ", ;
      "Снятие суточного отчета по НАЛОГАМ", ;
      "Продолжение печати при обрыве ленты", ;
      "Аннулирование чека при ошибке печати", ;
      "Установка даты в фискальном регистраторе", ;
      "Синхронизация времени между ФР и персональным компьютером", ;
      "Копирование КАССИРОВ из Пользователей программы в ФР" }
    mas_fun := { "fr_nastrojka(11)", ;
      "fr_nastrojka(12)", ;
      "fr_nastrojka(13)", ;
      "fr_nastrojka(18)", ;
      "fr_nastrojka(19)", ;
      "fr_nastrojka(14)", ;
      "fr_nastrojka(15)", ;
      "fr_nastrojka(16)", ;
      "fr_nastrojka(17)", ;
      "fr_nastrojka(20)" }
    If ! hb_user_curUser:isadmin()
      ASize( mas_pmt, 7 )
      ASize( mas_msg, 7 )
      ASize( mas_fun, 7 )
    Endif
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    f5_sist_fr( 2 )  // настройка
  Case k == 12
    f3_sist_fr( 1 )  // отчет с гашением
  Case k == 13
    f3_sist_fr( 0 )  // отчет без гашения
  Case k == 14
    f6_sist_fr()   // продолжение печати чека
  Case k == 15
    f7_sist_fr()   // аннулирование непробитого чека
  Case k == 16
    f1_sist_fr()
  Case k == 17
    f2_sist_fr()
  Case k == 18
    f8_sist_fr()
  Case k == 19
    f9_sist_fr()
  Case k == 20
    f10_sist_fr()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 20 )
      si1 := j
    Endif
  Endif
  Return Nil

// 24.08.25
Function f5_sist_fr( k )

  Static mm_da_net := { { "да ", 1 }, { "нет", 2 } }
  Static mm_chek := { { "Сквозной номер документа ККМ", 1 }, { "Номер чека продажи ККМ", 2 } }
  Static n_zapusk := 0
  Local mm_tmp := {}, buf, fl := .f.

  If k == 1
    Public meK_ostato := 0, ;
      meK_bank   := 2, ;
      meK_lof_fi := 2, ;
      meK_otrez  := 1, ;  // отрезка чека
      meK_kassa  := 1, ;  // рабочее место кассира
      meK_pr_FIO := 1, ;
      MEK_KASSIR := Space( 20 ), ;
      mek_chek   := 1, ;
      mek_bnbank := 2, ;
      mek_kod_usl := 1 , ;
      mek_sbp := 2  

    If File( "_kassa_.mem" )
      Restore From _kassa_ Additive
    Else
      Save All Like mek_* To _kassa_
    Endif
    // ////
    // контроль
    If n_zapusk == 0
      ++n_zapusk
      If iif( glob_task == X_KASSA, .t., glob_kassa == 1 ) .and. mek_kassa == 1
        Private drvFR
        If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
          fr_zamena_otrezka( 2 )
          fiskal_inf_fr()
        Endif
      Endif
    Endif
    //
  Elseif k == 2
    // ////
    buf := box_shadow( 1, 0, 22, 78, "B+/B" )
    // Настройки убраны
    // mek_nkassa := 1 //Работаем ТОЛЬКО через драйвер
    meK_lof_fi := 2 // для СОМ
    // mek_tkassa := 2 // ККМ по 54-ФЗ

    Private mostatok := meK_ostato, ;
      mmeK_bank, m1meK_bank := meK_bank, ;
      mmeK_kassa, m1meK_kassa := meK_kassa, ;
      mmek_pr_fio, m1mek_pr_fio := mek_pr_fio, ;
      mnkassa := Space( 10 ), m1nkassa := 0, ;
      mkassir := mek_kassir, ;
      mmek_chek := m1mek_chek := mek_chek, ;
      mmeK_bnbank, m1meK_bnbank := meK_bnbank, ;
      mmek_kod_usl, m1mek_kod_usl := mek_kod_usl, ;
      mmek_sbp,  m1mek_sbp := mek_sbp  

    mmeK_bank   := inieditspr( A__MENUVERT, mm_da_net, m1meK_bank )
    mmeK_bnbank   := inieditspr( A__MENUVERT, mm_da_net, m1meK_bnbank )
    mmeK_kassa  := inieditspr( A__MENUVERT, mm_da_net, m1meK_kassa )
    mmek_pr_fio := inieditspr( A__MENUVERT, mm_da_net, m1mek_pr_fio )
    mmek_chek   := inieditspr( A__MENUVERT, mm_chek, m1mek_chek )
    mmek_kod_usl := inieditspr( A__MENUVERT, mm_da_net, m1mek_kod_usl )
    mmek_sbp := inieditspr( A__MENUVERT, mm_da_net, m1mek_sbp )

    SetColor( cDataCGet )
    ix := 3
    clrlines( 1, MaxRow() -1 )
    If hb_user_curUser:isadmin()
      @ ++ix, 3 Say "Номером документа считать " Get mmek_chek ;
        reader {| x| menu_reader( x, mm_chek, A__MENUVERT,,, .f. ) }
      @ ++ix, 3 Say "Выделять отдельно Переводы СБП " Get mmek_sbp ;
        reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
      @ ++ix, 3 Say "Вызов драйвера ..." Get mnkassa ;
        reader {| x| menu_reader( x, { {|| fr_draiver() } }, A__FUNCTION,,, .f. ) }
    Endif
    @ ++ix, 3 Say "Сумма денег, внесенная в кассу УТРОМ" Get mostatok  Pict "999999.99"
    If hb_user_curUser:isadmin()
      ++ix
      @ ++ix, 3 Say "Учреждение принимает оплату банковскими переводами ?" Get mmeK_bnbank ;
        reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
      @ ++ix, 3 Say "Работать с банковскими картами ?" Get mmeK_bank ;
        reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
      @ ++ix, 3 Say "Это рабочее место кассира ?" Get mmeK_kassa ;
        reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
      @ ++ix, 3 Say "Печатать ФИО пациента/плательщика в чеке?" Get mmek_pr_fio ;
        reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
      @ ++ix, 3 Say "Печатать код услуги учреждения в чеке?" Get mmek_kod_usl ;
        reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
      @ ++ix, 3 Say "ФИО кассира" Get mkassir
    Endif
    status_key( "^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода" )
    myread()
    If LastKey() == K_ESC
      rest_box( buf )
      Return Nil
    Endif
    If f_esc_enter( 1 )
      mek_ostato := mostatok
      mek_kassir := mkassir
      If hb_user_curUser:isadmin()
        mek_bank    := m1mek_bank
        mek_bnbank  := m1mek_bnbank
        mek_kassa   := m1mek_kassa
        mek_pr_fio  := m1mek_pr_fio
        mek_chek    := m1mek_chek
        mek_kod_usl := m1mek_kod_usl
        mek_sbp     := m1mek_sbp
      Endif
      Save All Like mek_* To _kassa_
    Endif
    rest_box( buf )
  Endif
  Return Nil

// 02.07.18
Function f1_sist_fr()

  // Изменение даты в ККМ
  Local fl := .t.,  parol := 0, tt, tt1, s_err

  Private drvFR
  If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    fr_zamena_otrezka()
  Else
    Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
  Endif
  //
  If !ret_dataedit()
    Return Nil
  Endif
  tt := fr_ret_dan()
  If Empty( tt )
    Return func_error( 4, 'НЕ СЧИТАНА ДАТА ИЗ КАССЫ' )
  Endif
  tt1 := tt[ FR_R_DATE ]
  Private mdate := tt1
  Keyboard ""
  SetColor( cDataCGet )
  buf := box_shadow( 19, 9, 21, 70, "B+/B" )
  @ 20, 13 Say " В ФР сегодня " + DToC( tt1 ) + " введите новую дату" Get mdate
  status_key( "^<Esc>^ - выход из задачи;  ^<Enter>^ - подтверждение ввода" )
  myread( { "confirm" } )
  rest_box( buf )
  If LastKey() == K_ESC .or. mdate == tt1
    Return Nil
  Endif
  If ( fl := Empty( s_err := fr_set_date( mdate ) ) )
    stat_msg( "Команда Выполнена!" )
    n_message( { "", "Дата в ФР изменена !" },, ;
      color1, cDataCSay,,, color8 )
    fr_gudok()
  Else
    write_err_kassa( s_err, 'НЕ ПРОИЗОШЛО ИЗМЕНЕНИЯ ДАТЫ' )
  Endif
  Return Nil

//
Static Function ret_dataedit()

  Local buf, r1 := 12, r2 := 20, i, tmp_color := SetColor( color1 )

  buf := box_shadow( r1, 5, r2, 74,, "Установка даты в кассовом аппарате", "W/B" )
  SetColor( color8 )
  str_center( r1 + 2, "Предупреждение!" )
  str_center( r1 + 3, "Этот режим предназначен для изменения даты в кассовом аппарате." )
  str_center( r1 + 4, 'Он выполняется только на обнуленной кассе.' )
  SetColor( color1 )
  str_center( r2 - 2, "Выберите действие:" )
  setmtcolor( "BG+/B,W+/R,GR+/B,GR+/R" )
  @ r2 - 1, 14 Prompt " ~Отказ от операции "
  @ r2 - 1, 35 Prompt " ~Подтверждение изменения даты "
  Menu To i
  SetColor( tmp_color )
  rest_box( buf )

  Return ( i == 2 )

// Синхронизация времени
Function f2_sist_fr()

  Local fl := .t., t, tt, tt1, x, cur_time, ;
    r1 := 11, r2 := 20, i, tmp_color := SetColor( color1 ), buf

  Private drvFR

  If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    fr_read_otrezka()
  Else
    Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
  Endif
  //
  tt := fr_ret_dan()
  If Empty( tt )
    Return func_error( 4, 'НЕ СЧИТАНО ВРЕМЯ ИЗ ФР' )
  Endif
  tt1 := tt[ FR_R_TIME ] ; cur_time := Time()
  buf := box_shadow( r1, 5, r2, 74 )
  SetColor( color8 )
  str_center( r1 + 2, "Предупреждение!" )
  str_center( r1 + 3, "Этот режим предназначен для синхронизации времени" )
  str_center( r1 + 4, "между персональным компьютером и фискальным регистратором." )
  str_center( r1 + 5, "Время в ФР " + tt1 + "   Время в компьютере " + cur_time )
  mark_keys( { tt1, cur_time }, "G+/B" )
  SetColor( color1 )
  str_center( r2 - 2, "Выберите действие:" )
  setmtcolor( "BG+/B,W+/R,GR+/B,GR+/R" )
  @ r2 - 1, 10 Prompt " ~Отказ от операции "
  @ r2 - 1, 35 Prompt " ~Компьютер->ФР "
  @ r2 - 1, 55 Prompt " ~ФР->Компьютер "
  Menu To i
  SetColor( tmp_color )
  rest_box( buf )
  If i == 2
    t := Time()
    x := Val( SubStr( t, 7, 2 ) ) + 30
    If x > 59
      t := SubStr( t, 1, 6 ) + "59"
    Else
      t := SubStr( t, 1, 6 ) + StrZero( x, 2 )
    Endif
    mywait()
    If Empty( fr_set_time( t ) )
      fr_gudok()
      stat_msg( "Команда Выполнена!" )
      n_message( { "", "Установка Времени в ФР произведена" },, ;
        color1, cDataCSay,,, color8 )
    Else
      func_error( 4, 'НЕ ПРОИЗОШЛО УСТАНОВКИ ВРЕМЕНИ' )
    Endif
  Elseif i == 3
    tt := fr_ret_dan()
    If Empty( tt )
      func_error( 4, 'НЕ СЧИТАНО ВРЕМЯ ИЗ ФР' )
    Else
      SetTime( tt[ FR_R_TIME ], .t. )
      stat_msg( "Команда Выполнена!" )
      n_message( { "", "Установка Времени в КОМПЬЮТЕРЕ произведена" },, ;
        color1, cDataCSay,,, color8 )
    Endif
  Endif
  rest_box( buf )
  Return Nil

//
Function f3_sist_fr( tip )

  // 0 - Снятие суточного отчета без гашения
  // 1 - с гашением
  Local fl := .t., s_err, buf

  Private drvFR
  buf := save_row( MaxRow() )
  If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    fr_zamena_otrezka()
  Else
    Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
  Endif
  //
  If !ret_fsytotch( tip )
    Return Nil
  Endif
  If ( fl := Empty( s_err := fr_normgach( tip ) ) )
    rest_box( buf )
    mywait()
    stat_msg( "Команда выполнена!" )
    If tip == 1
      n_message( { "", "Гашение суточного отчета выполнено!" },, ;
        color1, cDataCSay,,, color8 )
    Endif
    fr_otrezka( 1, 3 )
    rest_box( buf )
  Else
    rest_box( buf )
    If tip == 1
      write_err_kassa( s_err, 'НЕ ПРОИЗОШЛО ГАШЕНИЯ СУТОЧНОГО ОТЧЕТА' )
    Else
      write_err_kassa( s_err, 'НЕ ПРОИЗОШЛО СНЯТИЯ СУТОЧНОГО ОТЧЕТА' )
    Endif
  Endif
  rest_box( buf )
  Return Nil

//
Function ret_fsytotch( tip )

  Local buf, r1 := 12, r2 := 20, i, tmp_color := SetColor( color1 )

  buf := box_shadow( r1, 5, r2, 74,, "Снятие суточного отчета", "W/B" )
  SetColor( color8 )
  str_center( r1 + 2, "Предупреждение!" )
  str_center( r1 + 3, "Этот режим предназначен для снятия суточного отчета" )
  If tip == 0
    str_center( r1 + 4, "без гашения." )
  Else
    str_center( r1 + 4, "с гашением." )
  Endif
  SetColor( color1 )
  str_center( r2 - 2, "Выберите действие:" )
  setmtcolor( "BG+/B,W+/R,GR+/B,GR+/R" )
  @ r2 - 1, 14 Prompt " ~Отказ от операции "
  @ r2 - 1, 35 Prompt " ~Подтверждение суточного отчета "
  Menu To i
  SetColor( tmp_color )
  rest_box( buf )
  Return ( i == 2 )

//
Function f6_sist_fr()

  // продолжение печати
  Local fl := .t., s_err, buf
  buf := save_row( MaxRow() )

  Private drvFR
  If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    fr_zamena_otrezka()
  Else
    Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
  Endif
  //
  If ( fl := Empty( s_err := fr_prodol() ) )
    rest_box( buf )
    mywait()
    stat_msg( "Команда выполнена!" )
    fr_otrezka( 1, 2 )
    rest_box( buf )
  Else
    rest_box( buf )
    write_err_kassa( s_err, 'НЕ ПРОИЗОШЛО ПРОДОЛЖЕНИЯ ПЕЧАТИ' )
  Endif
  rest_box( buf )
  Return Nil

//
Function f7_sist_fr()

  // аннулирование чека
  Local fl := .t., s_err, buf
  buf := save_row( MaxRow() )

  Private drvFR
  If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    fr_zamena_otrezka()
  Else
    Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
  Endif
  //
  If ( fl := Empty( s_err := frch_annul() ) )
    rest_box( buf )
    mywait()
    stat_msg( "Команда выполнена!" )
    fr_otrezka( 1, 2 )
    rest_box( buf )
  Else
    rest_box( buf )
    write_err_kassa( s_err, 'НЕ ПРОИЗОШЛО АННУЛИРОВАНИЯ ЧЕКА' )
  Endif
  rest_box( buf )
  Return Nil

// 03.09.17
Function f8_sist_fr()

  // Снятие суточного отчета по СЕКЦИЯМ
  Local fl := .t.,  s_err, buf

  buf := save_row( MaxRow() )
  If glob_kassa == 1 .and. mek_kassa == 1
    Private drvFR
    If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
      fr_zamena_otrezka()
    Else
      Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
    Endif
  Endif
  //
  If !ret_printreport( 1 )
    Return Nil
  Endif
  //
  If ( fl := Empty( s_err := frn_printdepartmentreport() ) )
    rest_box( buf )
    mywait()
    stat_msg( "Команда выполнена!" )
    fr_otrezka( 1, 3 )
    rest_box( buf )
  Else
    rest_box( buf )
    write_err_kassa( s_err, 'НЕ ПРОИЗОШЛО ПЕЧАТИ ОТЧЕТА ПО НАЛОГАМ' )
  Endif
  rest_box( buf )
  Return Nil

// 03.09.17
Function f9_sist_fr()

  // Снятие суточного отчета по НАЛОГАМ
  Local fl := .t., s_err, buf

  buf := save_row( MaxRow() )
  If glob_kassa == 1 .and. mek_kassa == 1
    Private drvFR
    If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
      fr_zamena_otrezka()
    Else
      Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
    Endif
  Endif
  //
  If !ret_printreport( 0 )
    Return Nil
  Endif
  //
  If ( fl := Empty( s_err := frn_printtaxreport() ) )
    rest_box( buf )
    mywait()
    stat_msg( "Команда выполнена!" )
    fr_otrezka( 1, 3 )
    rest_box( buf )
  Else
    rest_box( buf )
    write_err_kassa( s_err, 'НЕ ПРОИЗОШЛО ПЕЧАТИ ОТЧЕТА ПО НАЛОГАМ' )
  Endif
  rest_box( buf )
  Return Nil

//
Function ret_printreport( tip )

  Local buf, r1 := 12, r2 := 20, i, tmp_color := SetColor( color1 )

  buf := box_shadow( r1, 5, r2, 74,, "Снятие суточного отчета", "W/B" )
  SetColor( color8 )
  str_center( r1 + 2, "Предупреждение!" )
  str_center( r1 + 3, "Этот режим предназначен для снятия суточного отчета" )
  If tip == 0
    str_center( r1 + 4, "ПО НАЛОГАМ." )
  Else
    str_center( r1 + 4, "ПО СЕКЦИЯМ." )
  Endif
  SetColor( color1 )
  str_center( r2 - 2, "Выберите действие:" )
  setmtcolor( "BG+/B,W+/R,GR+/B,GR+/R" )
  @ r2 - 1, 14 Prompt " ~Отказ от операции "
  @ r2 - 1, 35 Prompt " ~Подтверждение суточного отчета "
  Menu To i
  SetColor( tmp_color )
  rest_box( buf )
  Return ( i == 2 )

// 03.09.17
Function f10_sist_fr()

  // Кассиры в ФР
  Local fl := .t., buf

  Private drvFR
  buf := save_row( MaxRow() )
  If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    fr_zamena_otrezka()
  Else
    Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
  Endif
  //
  If !ret_writekassir()
    Return Nil
  Endif
  //
  frn_writepassword()
  rest_box( buf )
  Return Nil

//
Function ret_writekassir()

  Local buf, r1 := 12, r2 := 20, i, tmp_color := SetColor( color1 )

  buf := box_shadow( r1, 5, r2, 74,, "Копирование ФИО Кассиров из Программы в ФР", "W/B" )
  SetColor( color8 )
  str_center( r1 + 2, "Предупреждение!" )
  str_center( r1 + 3, "Этот режим предназначен для" )
  str_center( r1 + 4, "Копирования ФИО Кассиров из программы в ФР" )
  SetColor( color1 )
  str_center( r2 - 2, "Выберите действие:" )
  setmtcolor( "BG+/B,W+/R,GR+/B,GR+/R" )
  @ r2 - 1, 14 Prompt " ~Отказ от операции "
  @ r2 - 1, 38 Prompt " ~Подтверждение копирования "
  Menu To i
  SetColor( tmp_color )
  rest_box( buf )
  Return ( i == 2 )

//
Static Function write_err_kassa( s1, s2 )

  Local _tmp, i, t_arr[ 2 ], ar := { "" }

  If !( ValType( s1 ) == "C" )
    s1 := ValType( s1 ) + " - ОШИБКА"
  Endif
  For i := 1 To perenos( t_arr, s1, 70 )
    AAdd( ar, AllTrim( t_arr[ i ] ) )
  Next
  AAdd( ar, s2 )
  //
  _tmp := DToC( Date() ) + "  " + SecToTime( Seconds() ) + "  " + strippath( ExeName() ) + hb_eol()
  For i := 1 To Len( ar )
    If !Empty( ar[ i ] )
      _tmp += ar[ i ] + hb_eol()
    Endif
  Next
  _tmp += Replicate( "*", 79 ) + hb_eol()
  StrFile( _tmp, dir_server() + "error.txt", .t. )
  //
  n_message( ar,, cColorStMsg, cColorStMsg,,, cColorSt2Msg )
  Return Nil

//
Static Function f_err_annul( s1 )

  Local _tmp, i, t_arr[ 2 ], ar := {}, ar2 := { "" }

  //
  For i := 1 To perenos( t_arr, s1, 70 )
    AAdd( ar, AllTrim( t_arr[ i ] ) )
  Next
  //
  _tmp := DToC( Date() ) + "  " + SecToTime( Seconds() ) + "  " + strippath( ExeName() ) + hb_eol()
  For i := 1 To Len( ar )
    If !Empty( ar[ i ] )
      _tmp += ar[ i ] + hb_eol()
    Endif
  Next
  _tmp += Upper( "Программе не удалось провести аннулирование чека!" ) + hb_eol()
  _tmp += Replicate( "*", 79 ) + hb_eol()
  StrFile( _tmp, dir_server() + "error.txt", .t. )
  //
  AAdd( ar2, "При печати чека возникла ошибка!" )
  AAdd( ar2, "Программе не удалось провести аннулирование чека!" )
  AAdd( ar2, "Проведите аннулирование вручную" )
  n_message( ar2,, "GR+/R", "GR+/R",,, "BG+/R" )
  Return Nil

// 24.08.25
Function yes_chek( /*@*/vsum, /*@*/vsd, /*@*/vbank, rm, /*@*/address, /*@*/tip_kart )

  Static spict := "9999999.99"
  Local tip_bank_kart := { { "МИР", 1 }, ;
    { "VISA", 2 }, ;
    { "MasterCard", 3 }, ;
    { "БАНКОВСКИЙ ПЕРЕВОД", 4 } }
  Local j, fl := .f., tmp_color, buf, buf24, a[ 3 ], r := 16

  if mek_sbp == 1
    aadd(tip_bank_kart,  { "СБП", 5 })
  endif  
  //
  If  mek_bnbank == 2
    ASize( tip_bank_kart, 3 )
  Endif
  If p_summa >= 0 // касса по 54-ФЗ
    tmp_color := SetColor( cDataCGet )
    Private vnos_summa := 0, bank_summa := 0, ;
      mbank_kart, m1bank_kart := tip_kart, ;
      maddress := PadR( address, 30 )
    mbank_kart := inieditspr( A__MENUVERT, tip_bank_kart, m1bank_kart )
    r := 14
    Do While .t.
      buf := box_shadow( r, 5, r + 5, 74 )
      buf24 := save_maxrow()
      @ r + 1, 7 Say "Телефон или Электр.почта" Get maddress Pict "@S30" ;
        valid {| g | controladdress( g, maddress ) }
      @ r + 2, 7 Say "Введите вносимую покупателем сумму (для подсчета сдачи)" ;
        Get vnos_summa Picture spict valid {| g| val_y_chek( g, 1 ) }
      @ r + 3, 7 Say "Сумма, вносимая безналичными (по банковской карте)     " ;
        Get bank_summa Picture spict valid {| g| val_y_chek( g, 2 ) } ;
        When round_5( vnos_summa, 2 ) < p_summa
      @ r + 4, 7 Say "Тип банковской карты" Get mbank_kart ;
        reader {| x| menu_reader( x, tip_bank_kart, A__MENUVERT,,, .f. ) };
        When bank_summa > 0
      status_key( "^<Esc>^ - выход без записи чека;  ^<PgDn>^ - запись чека" )
      myread()
      j := f_alert( { PadC( "Выберите действие", 60, "." ) }, ;
        { " Выход без записи ", " Печать чека ", " Возврат в редактирование " }, ;
        iif( LastKey() == K_ESC, 1, 2 ), "W+/N", "N+/N", MaxRow() -2,, "W+/N,N/BG" )
      If j < 2
        Exit
      Elseif j == 3
        Loop
      Endif
      If round_5( bank_summa, 2 ) > 0 .and. LastKey() != K_ESC ;
          .and. !f_esc_enter( "оплаты по карте" )
        rest_box( buf )
        rest_box( buf24 )
        Loop
      Endif
      rest_box( buf )
      rest_box( buf24 )
      If vnos_summa >= p_summa
        a[ 1 ] := vnos_summa
        a[ 2 ] := p_summa
        a[ 3 ] := round_5( vnos_summa - p_summa, 2 )
        f_message( { "Вносимая сумма: " + Str( a[ 1 ], 10, 2 ), ;
          "Сумма чека    : " + Str( a[ 2 ], 10, 2 ), ;
          "──────────────────────────", ;
          "Сумма сдачи   : " + Str( a[ 3 ], 10, 2 ) },, ;
          cHelpCMain, cHelpCMain, rm )
        fl_sdacha := .t.
        vsum := a[ 1 ] ; vsd := a[ 3 ] ; vbank := 0
      Else
        f_message( { "Сумма наличными: " + Str( vnos_summa, 10, 2 ), ;
          "Сумма по карте : " + Str( bank_summa, 10, 2 ), ;
          "Сумма чека     : " + Str( p_summa,   10, 2 ) },, ;
          cHelpCMain, cHelpCMain, rm )
        fl_sdacha := .f.
        vsum := vnos_summa ; vsd := 0 ; vbank := bank_summa
      Endif
      address  := maddress
      tip_kart := m1bank_kart
      fl := .t.
      Exit
    Enddo
    SetColor( tmp_color )
  Elseif p_summa < 0 // касса по 54-ФЗ
    Private vnos_summa := 0, bank_summa := 0, ;
      maddress := PadR( address, 30 ), ;
      mbank_kart, m1bank_kart := tip_kart
    mbank_kart := inieditspr( A__MENUVERT, tip_bank_kart, m1bank_kart )
    tmp_color := SetColor( cHelpCMain )
    buf := box_shadow( r, 5, r + 5, 74 )
    buf24 := save_row( MaxRow() )
    @ r + 1, 7 Say "Телефон или Электронная почта      " Get maddress Pict "@S30" ;
      valid {| g | controladdress( g, maddress ) }
    @ r + 2, 7 Say "Введите сумму возврата                                 " ;
      Get vnos_summa Picture spict valid {| g| val_u_chek( g, 1 ) }
    @ r + 3, 7 Say "Сумма, возврата безналичными (по банковской карте)     " ;
      Get bank_summa Picture spict valid {| g| val_u_chek( g, 2 ) } ;
      When round_5( vnos_summa, 2 ) < ( p_summa * ( -1 ) )
    @ r + 4, 7 Say "Тип банковской карты" Get mbank_kart ;
      reader {| x| menu_reader( x, tip_bank_kart, A__MENUVERT,,, .f. ) };
      When bank_summa > 0
    status_key( "^<Esc>^ - выход без записи чека;  ^<Enter>^ - запись чека" )
    myread()
    rest_box( buf )
    rest_box( buf24 )
    SetColor( tmp_color )
    If LastKey() != K_ESC
      If vnos_summa > 0 .or. bank_summa > 0
        a[ 1 ] := p_summa * ( -1 )
        a[ 2 ] := vnos_summa
        a[ 3 ] := bank_summa
        f_message( { "Cумма ВОЗВРАТА  : " + Str( a[ 1 ], 10, 2 ), ;
          "Сумма наличными : " + Str( a[ 2 ], 10, 2 ), ;
          "Сумма по банку  : " + Str( a[ 3 ], 10, 2 ) },, ;
          cHelpCMain, cHelpCMain, rm )
        fl_sdacha := .t.
        vsum := vnos_summa ; vbank := bank_summa ; vsd := 0
      Endif
      // /*@*/vsum,/*@*/vsd,/*@*/vbank,rm,/*@*/address,/*@*/tip_kart
      // vsum := vnos_summa ; vsd := 0 ; vbank := bank_summa
      address  := maddress
      tip_kart := m1bank_kart
      fl := .t.
    Endif
  Else
    fl := f_esc_enter( "печати ЧЕКА" )
  Endif
  Return fl

// 11.05.14
Function val_y_chek( get, n )

  If n == 1  // сумма наличными
    vnos_summa := round_5( vnos_summa, 2 )
    If vnos_summa < p_summa
      bank_summa := round_5( p_summa - vnos_summa, 2 )
    Else
      bank_summa := 0
    Endif
  Else       // сумма безналичными
    bank_summa := round_5( bank_summa, 2 )
    If bank_summa > p_summa
      func_error( 4, "Сумма, вносимая безналичными, не может быть больше суммы покупки!" )
      bank_summa := p_summa
    Elseif bank_summa > 0
      vnos_summa := round_5( p_summa - bank_summa, 2 )
    Else
      bank_summa := 0
      If round_5( vnos_summa, 2 ) < p_summa
        vnos_summa := p_summa
      Endif
    Endif
  Endif
  Return update_gets()

// 02.05.18
Function val_u_chek( get, n )

  If n == 1  // сумма наличными
    vnos_summa := round_5( vnos_summa, 2 )
    If vnos_summa < ( p_summa * ( -1 ) )
      bank_summa := round_5( ( p_summa * ( -1 ) ) - vnos_summa, 2 )
    Else
      bank_summa := 0
    Endif
  Else       // сумма безналичными
    bank_summa := round_5( bank_summa, 2 )
    If bank_summa > ( p_summa * ( -1 ) )
      func_error( 4, "Сумма, возврата безналичными, не может быть больше суммы чека!" )
      bank_summa := ( p_summa * ( -1 ) )
    Elseif bank_summa > 0
      vnos_summa := round_5( ( p_summa * ( -1 ) ) - bank_summa, 2 )
    Else
      bank_summa := 0
      If round_5( vnos_summa, 2 ) < ( p_summa * ( -1 ) )
        vnos_summa := ( p_summa * ( -1 ) )
      Endif
    Endif
  Endif
  Return update_gets()

// 22.10.19
Function chek_fr( vsum, vsd, /*@*/cur_chek, vbank, sekcia, /*@*/fr_serial_number, address, tip_kart, tip_oplat )

  Local fl := .t., name_tov, buf := save_maxrow(), ;
    s_err := "", s, last_chek := 0, fl_str := 0, fl_err_annul := .f., ;
    cs := 0, timeout := 5, tt1 := {}, sost, t_nds := 0, t_nds18 := 0, ;
    t_nds10 := 0

  Default sekcia To 1
  cur_chek := 0
  lfr_data := ""
  lfr_time := 0
  fr_serial_number := ""
  mywait()
  //
  tt1 := fr_ret_dan()
  If Empty( tt1 )
    Return func_error( 4, 'КАССА НЕ ОТВЕЧАЕТ' )
  Endif
  //
  last_chek        := tt1[ FR_R_NOMER ]
  cur_chek         := tt1[ FR_R_NOMER ]
  lfr_data         := dtoc4( tt1[ FR_R_DATE ] )
  fr_serial_number := tt1[ FR_R_ZAVNOMER ]
  lfr_time         := round_5( TimeToSec( tt1[ FR_R_TIME ] ), 0 )
  sost             := tt1[ FR_R_FLAG ]
  If tt1[ FR_R_REGIM ] == 4  // смена не открыта
    // загрузка текущего кассира
    // fio_polzovat
    // oper_parol
    If oper_parol > 0 .and. oper_parol < 31
      t_vrem := fr_readpassword( oper_parol )
      // if substr(alltrim(t_vrem[1]),1,6) == "КАССИР" //alltrim(fio_polzovat)
      fr_writepassword( oper_parol, fio_polzovat )
      fr_writepassword( 30, fio_polzovat )
      // endif
    Endif
    If fr_read_otrezka() > 0
      meK_otrez  := 2 // не отрезать
    Else
      meK_otrez  := 1 // отрезать
    Endif
    // открыть смену.
    frchn_opensession()
  Endif
  //
  s := ""
  If mek_pr_fio == 1
    If Type( "mplat_fio" ) == "C" .and. !Empty( mplat_fio )
      s := "Больной: "
      If Empty( fr_stroka( "Плательщик: " + fam_i_o( mplat_fio ) ) )
        ++cs
      Endif
      If Type( "mplat_inn" ) == "C" .and. !Empty( mplat_inn )
        If Empty( fr_stroka( "ИНН плательщика: " + mplat_inn ) )
          ++cs
        Endif
      Endif
    Endif
    name_tov := s + lstr( glob_kartotek ) + "  " + fam_i_o( glob_k_fio )
  Else
    name_tov := s + lstr( glob_kartotek )
  Endif
  //
  If Len( name_tov ) > 20
    fr_progon( 1, 1 )
  Endif
  //
  If iif( Len( name_tov ) > 20, Empty( fr_stroka( name_tov ) ), ;
      Empty( fr_b_stroka( name_tov ) ) )
    ++cs
  Endif
  //
  fr_progon( 1, 1 )
  // НАЧАЛО печати услуг
  Select TMP
  Go Top
  Do While !Eof()
    If fl .and. tmp->kol > 0
      name_tov := AllTrim( tmp->name )
      t_nds := 0
      If tmp->nds18 > 0 .or. tmp->nds20 > 0
        t_nds := 1
      Elseif tmp->nds10 > 0
        t_nds := 2
      Endif
      s_err := frchf_registr( tmp->cena, tmp->kol, sekcia, name_tov, t_nds, 1, 4, tip_oplat )
      If ( fl := Empty( s_err ) )
        ++cs // количество продаж
      Else
        func_error( 4, s_err )
      Endif
      If !Empty( tmp->vrach )
        fr_stroka( AllTrim( tmp->vrach ) )   // печать врача
      Endif
    Endif
    Skip
  Enddo
  // КОНЕЦ печати услуг
  If fl .and. Len( AllTrim( address ) ) > 3
    // передача данных покупателя
    frn_customeremail( address )
  Endif
  //
  If Len( AllTrim( oper_fr_inn ) ) == 12
    fr_write_inn_kassir( oper_fr_inn )
  Endif
  //
  If fl
    Default vbank To 0
    If Empty( vbank )
      s := round_5( p_summa, 2 )
      If round_5( p_summa, 2 ) < round_5( vsum, 2 )
        s := vsum
      Endif
    Else
      s := vsum
    Endif
    s_err := frch_close( s, vbank,, t_nds, tip_kart )
    If ( fl := Empty( s_err ) )
      ++cs // количество продаж
    Else
      func_error( 4, s_err )
      Inkey( 0 )
    Endif
  Endif
  //
  If fl
    // tt1 := FR_ret_dan()
    If mek_chek == 1
      // cur_chek := tt1[FR_R_NOMER]-1 //
      cur_chek := fr_ret_dok() + 1
    Else
      cur_chek := fr_ret_chek() // -1
    Endif
    If !IsBit( sost, 10 )
      func_error( 4, "Заканчивается ЧЕКОВАЯ лента." )
    Endif
    If cur_chek > 0 .and. cur_chek != last_chek
      fl := .t. ; s_err := ""
    Endif
  Endif
  // ПРОБЛЕММЫ по печати ЧЕКА
  If !fl
    If frch_annul() == 1
      fl_err_annul := .t.
    Endif
  Endif
  rest_box( buf )
  If fl_err_annul
    f_err_annul( s_err )
  Elseif !fl
    write_err_kassa( s_err, "ЧЕК АННУЛИРОВАН" )
  Endif
  //
  fr_otrezka( 1, 2 )
  //
  // if type("delta_chek") == "N"
  // cur_chek += delta_chek
  // endif
  Return fl

// 28.03.23
Function vozvrat_fr( value, bn_value, /*@*/cur_chek, sekcia, tip_banka )

  Local fl := .t.,  buf := save_maxrow(), tmp_color := SetColor( color1 ), ;
    s_err := "", s, last_chek, fl_err_annul := .f., summa_kassa := 0, ;
    sm_b1 := sm_b2 := smb3 := 0, r1 := 12, r2 := 20, ;
    mas_oplat := { "МИР", "VISA", "MasterCard", "Перевод", "СБП" }

  // запрашиваем наличие наличности в кассе
  If ValType( summa_kassa := ( frch_d_registr( 193 ) ) ) != "N"
    Return func_error( 4, summa_kassa )
  Endif
  If value > summa_kassa
    Return func_error( 4, "Недостаточная сумма в кассе" )
  Endif
  // запрашиваем наличие БЕЗНАЛА в кассе
  If bn_value > 0
    If tip_banka == 1
      If ValType( summa_kassa := ( frch_d_registr( 197 ) ) ) != "N"
        Return func_error( 4, summa_kassa )
      Endif
    Elseif tip_banka == 2
      If ValType( summa_kassa := ( frch_d_registr( 201 ) ) ) != "N"
        Return func_error( 4, summa_kassa )
      Endif
    Else
      If ValType( summa_kassa := ( frch_d_registr( 205 ) ) ) != "N"
        Return func_error( 4, summa_kassa )
      Endif
    Endif
    //
    If bn_value > ( summa_kassa )
      buf := box_shadow( r1, 5, r2, 74,,, "W/B" )
      SetColor( color8 )
      str_center( r1 + 2, "Предупреждение!" )
      str_center( r1 + 3, "принятая за смену сумма по карте " + mas_oplat[ tip_banka ] )
      str_center( r1 + 4, put_kop( summa_kassa, 10 ) + "руб." )
      str_center( r1 + 5, "меньше, чем сумма воврата." )
      SetColor( color1 )
      str_center( r2 - 2, "Выберите действие:" )
      setmtcolor( "BG+/B,W+/R,GR+/B,GR+/R" )
      @ r2 - 1, 10 Prompt " ~Отказ от операции "
      @ r2 - 1, 55 Prompt " ~Провести возврат "
      Menu To i
      SetColor( tmp_color )
      rest_box( buf )
      If i == 1
        Return func_error( 4, "Недостаточная сумма БЕЗНАЛА в кассе" )
      Endif
    Endif
  Endif
  mywait()
  Default sekcia To 1
  cur_chek := 0
  lfr_data := ""
  lfr_time := 0
  fr_serial_number := ""
  mywait()
  //
  s := ""
  //
  fr_progon( 1, 1 )
  // НАЧАЛО печати услуг
  Select TMP
  Go Top
  Do While !Eof()
    If fl .and. tmp->kol1 > 0
      t_nds := 0
      If tmp->nds18 > 0 .or. tmp->nds20 > 0
        t_nds := 1
      Elseif tmp->nds10 > 0
        t_nds := 2
      Endif
      s_err := frchf_registr( tmp->vz_cena, tmp->kol1, sekcia, tmp->name_u, t_nds, 2, 4, 4 )
      If ( fl := Empty( s_err ) )
        // ++cs //количество продаж
      Else
        func_error( 4, s_err )
      Endif
    Endif
    Skip
  Enddo
  // КОНЕЦ печати услуг
  If Len( AllTrim( oper_fr_inn ) ) == 12
    fr_write_inn_kassir( oper_fr_inn )
  Endif
  //
  If fl
    s_err := frch_close( value, bn_value,, 0, tip_banka )
    If ( fl := Empty( s_err ) )
      // количество продаж
    Else
      func_error( 4, s_err )
      Inkey( 0 )
    Endif
  Endif
  fr_gudok()
  //
  If fl
    tt1 := fr_ret_dan()
    If mek_chek == 1
      cur_chek := tt1[ FR_R_NOMER ] -1 //
    Else
      cur_chek := fr_ret_chek() -1
    Endif
    lfr_data := dtoc4( tt1[ FR_R_DATE ] )
    fr_serial_number := tt1[ FR_R_ZAVNOMER ]
    lfr_time := round_5( TimeToSec( tt1[ FR_R_TIME ] ), 0 )
    sost := tt1[ FR_R_FLAG ]
    If !IsBit( sost, 10 )
      func_error( 4, "Заканчивается ЧЕКОВАЯ лента." )
    Endif
    If !fl .and. last_chek > 0
      // и для СОМ
      If cur_chek > 0 .and. cur_chek != last_chek
        fl := .t. ; s_err := ""
      Endif
    Endif
  Endif
  // ПРОБЛЕММЫ по печати ЧЕКА
  If !fl
    If frch_annul() == 1
      fl_err_annul := .t.
    Endif
  Endif
  rest_box( buf )
  If fl_err_annul
    f_err_annul( s_err )
  Elseif !fl
    write_err_kassa( s_err, "ЧЕК АННУЛИРОВАН" )
  Endif
  //
  fr_otrezka( 1 )
  // if type("delta_chek") == "N"
  // cur_chek += delta_chek
  // endif
  //
  Return fl

// 16.11.18 запрос к кассовому аппарату
Function f1_inf_fr( tip )

  Local arr := {}, s,  sd, buf := save_row( MaxRow() ), ;
    c4date := dtoc4( sys_date ), n_file := cur_dir() + "_kassa.txt", ;
    fr_serial_number := "", kol := 0, sum := 0, ;
    lkexchangeStatus, lkmessageStatus := 0, lkmessageCount := 0, ;
    lkdocumentNumber := 0, lkdateDoc, lktimeDoc, mas_sost := {}

  Default tip To 1

  Private drvFR
  If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    fr_zamena_otrezka()
  Else
    Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
  Endif
  //
  mywait()
  AAdd( arr, Center( date_month( sys_date, .t. ), 60 ) )
  If glob_kassa == 1 .and. mek_kassa == 1
    mas_sost := fr_ret_dan()
    AAdd( arr, "Дата в ФР  " + full_date( mas_sost[ FR_R_DATE ] ) )
    AAdd( arr, "Состояние ФР : " + AllTrim( mas_sost[ FR_R_PODREGIM ] ) )
    // fr_serial_number := tt1[FR_R_ZAVNOMER]
    AAdd( arr, " " )
    AAdd( arr, "ПО СВЕДЕНИЮ ФИСКАЛЬНОГО РЕГИСТРАТОРА:" )
    AAdd( arr, " -Накопление наличности в кассе             " + Str( frch_d_registr( 241 ), 15, 2 ) )
    AAdd( arr, " -Продажа наличными за смену                " + Str( frch_d_registr( 193 ), 15, 2 ) )
    AAdd( arr, "  -Возврат продаж наличными за смену        " + Str( frch_d_registr( 195 ), 15, 2 ) )
    AAdd( arr, " -Продажа карта МИР  за смену               " + Str( frch_d_registr( 197 ), 15, 2 ) )
    AAdd( arr, "  -Возврат продаж карта МИР  за смену       " + Str( frch_d_registr( 199 ), 15, 2 ) )
    AAdd( arr, " -Продажа карта VISA за смену               " + Str( frch_d_registr( 201 ), 15, 2 ) )
    AAdd( arr, "  -Возврат продаж карта VISA за смену       " + Str( frch_d_registr( 203 ), 15, 2 ) )
    AAdd( arr, " -Продажа карта MasterCard за смену         " + Str( frch_d_registr( 205 ), 15, 2 ) )
    AAdd( arr, "  -Возврат продаж карта MasterCard за смену " + Str( frch_d_registr( 207 ), 15, 2 ) )
    AAdd( arr, "НДС " )
    AAdd( arr, " -Продажа услуги с НДС 18% (20%)            " + Str( frch_d_registr( 209 ), 15, 2 ) )
    // aadd(arr,"   -Возврат услуги с НДС 18%                "+str(FRCH_d_registr(211),15,2))
    AAdd( arr, " -Продажа НДС 18% (20%)                     " + Str( frch_d_registr( 225 ), 15, 2 ) )
    // aadd(arr,"   -Возврат НДС 18%                         "+str(FRCH_d_registr(227),15,2))
    AAdd( arr, " " )
    AAdd( arr, "СТАТУС ИНФОРМАЦИОННОГО ОБМЕНА" )
    If Empty( frn_getinfoexchangestatusshtih( @lkexchangeStatus,;
        @lkmessageStatus, ;
        @lkmessageCount, ;
        @lkdocumentNumber, ;
        @lkdateDoc, ;
        @lktimeDoc ) )
      AAdd( arr, " -Сообщений для передачи в ОФД                   " + PadR( Str( lkmessageCount ), 10 ) )
      AAdd( arr, " -Номер документа для ОФД первого в очереди      " + PadR( Str( lkdocumentNumber ), 10 ) )
      AAdd( arr, " -Дата документа для ОФД первого в очереди       " + full_date( lkdateDoc ) )
    Else
      AAdd( arr, " -ДАННЫЕ НЕ СЧИТАНЫ" )
    Endif
  Endif
  If tip < 5
    // для chip_mo
    AAdd( arr, " " )
    AAdd( arr, "ПО СВЕДЕНИЮ ПРОГРАММЫ:" )
    s := sv := sd := 0
    If tip == 1
      r_use( dir_server() + "hum_p",, "HUMAN" )
      Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp" ) ;
        For is_kas == 1 .and. equalany( c4date, pdate, date_voz ) ;
        progress
      Go Top
      Do While !Eof()
        If PadR( human->fr_zavod, 8 ) == PadR( fr_serial_number, 8 )
          If c4date == human->pdate
            sd += human->cena
            s += human->cena
          Endif
          If c4date == human->date_voz
            sd -= human->sum_voz
            sv += human->sum_voz
          Endif
        Endif
        Skip
      Enddo
    Elseif tip == 2
      r_use( dir_server() + "hum_oro",, "HUMAN" )
      Index On Str( kod, 7 ) to ( cur_dir() + "tmp" ) ;
        For equalany( c4date, pdate, date_voz ) ;
        progress
      Go Top
      Do While !Eof()
        If PadR( human->fr_zavod, 8 ) == PadR( fr_serial_number, 8 )
          If c4date == human->pdate
            sd += human->cena_opl
            s += human->cena_opl
          Endif
          If c4date == human->date_voz
            sd -= human->sum_voz
            sv += human->sum_voz
          Endif
        Endif
        Skip
      Enddo
    Else
      r_use( dir_server() + "kas_pl", dir_server() + "kas_pl2", "KPL" )
      find ( DToS( sys_date ) )
      Do While kpl->k_data == sys_date .and. !Eof()
        If kpl->smena == glob_smena
          kol++
          sum += kpl->cena
        Endif
        Skip
      Enddo
      r_use( dir_server() + "kas_ort", dir_server() + "kas_ort2", "KOR" )
      find ( DToS( sys_date ) )
      Do While kor->k_data == sys_date .and. !Eof()
        If kor->smena == glob_smena .and. kor->n_chek > 0
          kol++
          sum += kor->cena
        Endif
        Skip
      Enddo
    Endif
    Close databases
    If tip < 3
      AAdd( arr, " -Сумма возвратов:                          " + Str( Abs( sv ), 15, 2 ) )
      AAdd( arr, " -Сумма общего итога оплат за смену:        " + Str( s, 15, 2 ) )
    Else
      AAdd( arr, " -Количество чеков за смену:                " + Str( kol, 15 ) )
      AAdd( arr, " -Сумма общего итога оплат за смену:        " + Str( sum, 15, 2 ) )
    Endif
    AAdd( arr, " -Сумма наличных денег в ящике ККМ:         " + Str( sd, 15, 2 ) )
    If meK_ostato > 0
      AAdd( arr, "" )
      AAdd( arr, " -Сумма денег, внесенная в кассу УТРОМ:        " + Str( meK_ostato, 15, 2 ) )
      AAdd( arr, " -Итого сумма наличных денег в ящике ККМ:      " + Str( sd + meK_ostato, 15, 2 ) )
    Endif
  Endif
  s := hb_eol()
  AEval( arr, {| x| s += Space( 10 ) + x + hb_eol() } )
  StrFile( s, n_file )
  rest_box( buf )
  viewtext( n_file )
  Return Nil

// 28.09.17 запрос к кассовому аппарату
Function fiskal_inf_fr()

  Local lkexchangeStatus, lkmessageStatus := 0, lkmessageCount := 0, ;
    lkdocumentNumber := 0, lkdateDoc, lktimeDoc

  If Empty( frn_getinfoexchangestatusshtih( @lkexchangeStatus,;
      @lkmessageStatus, ;
      @lkmessageCount, ;
      @lkdocumentNumber, ;
      @lkdateDoc, ;
      @lktimeDoc ) )
    If !Empty( lkmessageCount )
      If lkmessageCount > 0
        func_error( 4, "В ОФД не передано " + lstr( lkmessageCount ) + " чеков. Документы в очереди от " + full_date( lkdateDoc ) )
      Endif
    Endif
  Endif
  Return Nil

// гудок на кассовом аппарате
Function fr_gudok()

  If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    drvFR:Password := oper_parol
    drvFR:beep()
  Endif

  Return

// ДРАЙВЕР вывод строки на чековую ленту
Function fr_stroka( stroka, flag )
/* flag - 1 печать на контрольной ленте
          2 печать на чековой ленте
   stroka - строка выводимая на чековую ленту
*/

  Local t, s

  Default flag To 2

  s := AtRepl( ",", AllTrim( stroka ), ";" )   // заменить ";" на "," строки
  stroka := CharOne( " ", s )                    // удалить совмещенные пробелы
  drvFR:Password := oper_parol
  drvFR:StringForPrinting := stroka
  If flag == 1 // контролька
    drvFR:UseJournalRibbon := .t.
  Else
    drvFR:UseReceiptRibbon := .t.
  Endif
  hb_cdpSelect( "RU1251" )
  If drvFR:printstring() < 0
    t := drvFR:ResultCodeDescription
    hb_cdpSelect( "RU866" )
    Return AllTrim( t )
  Endif
  hb_cdpSelect( "RU866" )
  Return Nil

// ДРАЙВЕР вывод строки на чековую ленту
Function fr_b_stroka( stroka, flag )
/* flag - 1 печать на контрольной ленте
          2 печать на чековой ленте
   stroka - строка выводимая на чековую ленту
*/

  Local t

  Default flag To 2

  s := AtRepl( ",", AllTrim( stroka ), ";" )   // заменить ";" на "," строки
  stroka := CharOne( " ", s )                    // удалить совмещенные пробелы
  drvFR:Password := oper_parol
  drvFR:StringForPrinting := stroka
  If flag == 1 // контролька
    drvFR:UseJournalRibbon := .t.
  Else
    drvFR:UseReceiptRibbon := .t.
  Endif
  hb_cdpSelect( "RU1251" )
  If drvFR:printwidestring() < 0
    t := drvFR:ResultCodeDescription
    hb_cdpSelect( "RU866" )
    Return AllTrim( t )
  Endif
  hb_cdpSelect( "RU866" )
  Return Nil

// ДРАЙВЕР отрезка чековой ленты
Function fr_otrezka( flag, zad_time )
/* flag - 0 полная отрезка
          1 частичный отрез
*/

  Default zad_time To 0

  If meK_otrez == 1
    If zad_time > 0
      mywait()
      Inkey( zad_time )
    Endif
    drvFR:Password := oper_parol
    If flag == 0
      drvFR:CutType := 0
    Else
      drvFR:CutType := 1
    Endif
    drvFR:cutcheck()
  Endif
  Return Nil

// ДРАЙВЕР прогон чековой ленты
Function fr_progon( flag, kol_str )
/*  flag - 0 контрольная лента
           1 чековая лента
           2 обе ленты
    kol_str количество прогоняемых строк
*/

  drvFR:Password := oper_parol
  drvFR:StringQuantity := kol_str
  If flag == 0 .or. flag == 2 // контролька
    drvFR:UseJournalRibbon := .t.
  Else
    drvFR:UseReceiptRibbon := .t.
  Endif
  drvFR:feeddocument()
  Return Nil

// 12.08.18 Регистрация товара
Function frchf_registr( cena, kol_vo, sekcia, name, t_nds, Tip_operation, tip_tovar, tip_rachet )
/*  cena          - цена товара в рублях
    kol_vo        - количество товара
    sekcia        - номер секции
    name          - наименование товара
    Tip_operation - 1 == продажа 2 == возврат продажи
    tip_tovar     - тип товара 4 == услуга
    tip_rachet    - тип расчета 4 == полный
*/

  Local t := ""

  Default tip_tovar To 4, tip_rachet To 4

  If Len( name ) > 127
    name := SubStr( name, 1, 128 )
  Endif
  name := Upper( AllTrim( name ) )
  drvFR:Password := oper_parol
  drvFR:CheckType := Tip_operation // 1 - продажа 2 - возврат
  drvFR:Quantity := kol_vo
  drvFR:Price    := cena
  drvFR:Department := sekcia
  drvFR:Summ1Enabled := .f.
  drvFR:StringForPrinting := name
  drvFR:Tax1 := t_nds
  drvFR:PaymentTypeSign := 4 // tip_tovar
  drvFR:PaymentItemSign  := 4 // tip_rachet

  If drvFR:fnoperation() < 0
    t := Upper( drvFR:ResultCodeDescription )
    Return AllTrim( t )
  Endif
  hb_cdpSelect( "RU866" )
  If ( t := Upper( drvFR:ResultCodeDescription ) ) == "ОШИБОК НЕТ"
    Return Nil
  Else
    Return AllTrim( t )
  Endif
  Return Nil

// 24.08.25  Закрытие чека
Function frch_close( summa, summa1, name, t_nds, tip_kart )
/*  summa  - сумма наличных
    summa1 - по кредитной карте
    name   - текст
    t_nds
*/

  Local  t := ""

  Default name To " "

  drvFR:Password := oper_parol
  //
  drvFR:Summ1 := 0
  drvFR:Summ2 := 0
  drvFR:Summ3 := 0
  drvFR:Summ4 := 0
  drvFR:Summ5 := 0
  drvFR:Summ6 := 0
  drvFR:Summ7 := 0
  drvFR:Summ8 := 0
  drvFR:Summ9 := 0
  drvFR:Summ10 := 0
  drvFR:Summ11 := 0
  drvFR:Summ12 := 0
  drvFR:Summ13 := 0
  drvFR:Summ14 := 0
  drvFR:Summ15 := 0
  drvFR:Summ16 := 0
  //
  drvFR:TaxValue1  := 0
  drvFR:TaxValue2  := 0
  drvFR:TaxValue3  := 0
  drvFR:TaxValue4  := 0
  drvFR:TaxValue5  := 0
  drvFR:TaxValue6  := 0
  //
  // drvFR:RoundingSumm :=2
  //
  drvFR:Summ1 := summa
  If tip_kart == 0 // старые кассы
    drvFR:Summ4 := summa1
  Elseif tip_kart == 1 .or. tip_kart == 5 // МИР или оплата СБП
    drvFR:Summ2 := summa1
  Elseif tip_kart == 2 // VISA
    drvFR:Summ3 := summa1
  Elseif tip_kart == 3 // Masterkard
    drvFR:Summ4 := summa1
  Elseif tip_kart == 4 // Банковский перевлд
    drvFR:Summ5 := summa1
  Endif
  drvFR:RoundingSumm := 0  // Сумма округления
  drvFR:StringForPrinting := name
  drvFR:TaxValue1 := t_nds // Налоги
//  !!!!!! ВНИМАНИЕ !!!!!!
  If glob_mo[ _MO_KOD_TFOMS ] == '605301' // ЗАО Стоматолог
    drvFR:TaxType := 2 // УСН
  Else
    drvFR:TaxType := 1 // Основная система Налогооблажения
  Endif
  //
  If drvFR:fnclosecheckex() < 0
    t := Upper( drvFR:ResultCodeDescription )
    Return AllTrim( t )
  Endif
  hb_cdpSelect( "RU866" )
  If ( t := Upper( drvFR:ResultCodeDescription ) ) == "ОШИБОК НЕТ"
    Return Nil
  Else
    Return AllTrim( t )
  Endif
  Return Nil

// Установка времени
Function fr_set_time( time )

  // time   - время в формате ЧЧ:ММ:СС
  Local t := ""

  drvFR:Password := oper_frparol
  drvFR:Time := time
  If drvFR:SetTime() < 0
    t := drvFR:ResultCodeDescription
    Return AllTrim( t )
  Endif
  Return Nil

// Программирование даты (подтверждение программирования даты)
Function fr_set_date( ldate )
/*  n_prot - номер порта
    ldate  - дата в формате даты
*/

  Local  t := ""

  drvFR:Password := oper_frparol
  drvFR:Date := ldate
  If drvFR:SetDate() < 0
    t := drvFR:ResultCodeDescription
    Return AllTrim( t )
  Endif
  //
  If drvFR:confirmdate() < 0
    t := drvFR:ResultCodeDescription
    Return AllTrim( t )
  Endif
  Return Nil

// Снятие суточного отчета
Function fr_normgach( flag )

  Local t := ""

  drvFR:Password := oper_frparol
  If flag == 0 // без гашения
    If drvFR:printreportwithoutcleaning() < 0
      t := drvFR:ResultCodeDescription
      Return AllTrim( t )
    Else
      // t := drvFR:ResultCodeDescription
      Return Nil
    Endif
  Elseif flag == 1
    If Len( AllTrim( oper_fr_inn ) ) == 12
      //
      drvFR:fnbeginclosesession()
      //
      drvFR:Password    := oper_frparol
      drvFR:TagNumber   := 1203
      drvFR:TagType     := 7
      drvFR:TagValueStr := oper_fr_inn
      //
      drvFR:fnsendtag()
      drvFR:Password    := oper_frparol
      If drvFR:printreportwithcleaning() < 0
        t := drvFR:ResultCodeDescription
        Return AllTrim( t )
      Else
        // t := drvFR:ResultCodeDescription
        Return Nil
      Endif
    Else
      If drvFR:printreportwithcleaning() < 0
        t := drvFR:ResultCodeDescription
        Return AllTrim( t )
      Else
        // t := drvFR:ResultCodeDescription
        Return Nil
      Endif
    Endif
  Else
    If drvFR:printdepartmentreport() < 0
      t := drvFR:ResultCodeDescription
      Return AllTrim( t )
    Else
      // t := drvFR:ResultCodeDescription
      Return Nil
    Endif
  Endif
  Return Nil

// Снятие суточного отчета по НАЛОГАМ
Function frn_printtaxreport()

  Local t := ""

  If drvFR:printtaxreport() < 0
    t := drvFR:ResultCodeDescription
    Return AllTrim( t )
  Endif
  Return Nil

// Снятие суточного отчета по СЕКЦИЯМ
Function frn_printdepartmentreport()

  Local t := ""

  If drvFR:printdepartmentreport() < 0
    t := drvFR:ResultCodeDescription
    Return AllTrim( t )
  Endif
  Return Nil

// Аннулирование всего чека до его закрытия
Function frch_annul()
/*  1 - аннулирование неудачно
    0 - аннулирование удачно завершено
*/

  Local t

  drvFR:Password := oper_parol
  If drvFR:cancelcheck() < 0
    t := drvFR:ResultCodeDescription
    Return iif( Empty( AllTrim( t ) ), 0, 1 )
  Endif
  Return 0

// продолжение печати
Function fr_prodol()

  Local t

  drvFR:Password := oper_parol
  If drvFR:continueprint() < 0
    t := drvFR:ResultCodeDescription
    Return AllTrim( t )
  Endif
  Return Nil

// Возвращает текущий номер чека покупки
Function fr_ret_chek()

  Local num_chek := 0

  drvFR:Password := oper_parol
  drvFR:RegisterNumber := 148
  If drvFR:getoperationreg() < 0
    num_chek := drvFR:ResultCodeDescription
    Return 0 // пока так
  Else
    num_chek := drvFR:ContentsOfOperationRegister
  Endif
  Return num_chek

// Возвращает текущий номер документа
Function fr_ret_dok()

  Local num_chek := 0

  drvFR:Password := oper_parol
  drvFR:RegisterNumber := 152
  If drvFR:getoperationreg() < 0
    num_chek := drvFR:ResultCodeDescription
    Return 0 // пока так
  Else
    num_chek := drvFR:ContentsOfOperationRegister
  Endif
  Return num_chek

// Запрос денежного регистра
Function frch_d_registr( registr )

  // registr - номер регистра
  Local t

  drvFR:Password := oper_parol
  drvFR:RegisterNumber := registr
  If drvFR:getcashreg() < 0
    t := drvFR:ResultCodeDescription
    Return AllTrim( t )
  Else
    t := drvFR:ContentsOfCashRegister
  Endif
  Return t

// Возвращает в виде массива состояние ФР
Function fr_ret_dan()

  Local mas_vozvr := {}, t, t1, t2, i, t4

  drvFR:Password := oper_parol
  For i := 1 To FR_R_LEN
    t := " "
    AAdd( mas_vozvr, t )
  Next
  If drvFR:getecrstatus() < 0 // ошибка
    t := drvFR:ResultCodeDescription
    func_error( 4, t )
    Return Nil
  Else
    t := drvFR:ResultCodeDescription
    mas_vozvr[ FR_R_NOMER ] := drvFR:OpenDocumentNumber
    mas_vozvr[ FR_R_DATE ] := drvFR:Date
    mas_vozvr[ FR_R_TIME ] := drvFR:TimeStr
    mas_vozvr[ FR_R_REGIM ] := drvFR:ECRMode
    // 2 - смена открыта 4 - закрытая смена
    // mas_vozvr[FR_R_PORT] := drvFR:PortNumber
    t1 := drvFR:ReceiptRibbonIsPresent
    t2 := drvFR:JournalRibbonIsPresent
    mas_vozvr[ FR_R_PORT ] := drvFR:PortNumber
    mas_vozvr[ FR_R_ZAVNOMER ] := drvFR:SerialNumber
    mas_vozvr[ FR_R_FLAG ] := 0
    If t1
      mas_vozvr[ FR_R_FLAG ] := SetBit( mas_vozvr[ FR_R_FLAG ], 10 )
    Endif
    If t2
      mas_vozvr[ FR_R_FLAG ] := SetBit( mas_vozvr[ FR_R_FLAG ], 9 )
    Endif
    // задействуем поле заводской номер
    mas_vozvr[ FR_R_PODREGIM ] := AllTrim( drvFR:ECRModeDescription )
    If mas_vozvr[ FR_R_REGIM ] == 8
      t4 := drvFR:ECRMode8Status
      If t4 == 0
        mas_vozvr[ FR_R_PODREGIM ] := mas_vozvr[ FR_R_PODREGIM ] + " Открыт чек продажи"
      Elseif  t4 == 1
        mas_vozvr[ FR_R_PODREGIM ] := mas_vozvr[ FR_R_PODREGIM ] + " Открыт чек покупки"
      Elseif  t4 == 2
        mas_vozvr[ FR_R_PODREGIM ] := mas_vozvr[ FR_R_PODREGIM ] + " Открыт чек возврата продажи"
      Else
        mas_vozvr[ FR_R_PODREGIM ] := mas_vozvr[ FR_R_PODREGIM ] + " Открыт чек возврата покупки"
      Endif
    Endif
  Endif
  Return mas_vozvr

// вызов драйвера
Function fr_draiver()

  Local mas_kassa := {}, t := ""
  Local mas_sp_kassa := { 0, 0, 0, 0 }

  Private drvFR

  If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    If drvFR:showproperties()  < 0
      t := drvFR:ResultCodeDescription
      func_error( 4, t )
    Endif
  Endif
  Return Nil

// вызов драйвера
Function fr_lenstring()

  Private drvFR

  If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    If drvFR:getdevicemetrics()  < 0
      fr_zamena_otrezka()
    Else
      t := drvFR:UDescription
    Endif
  Endif
  Return Nil

// 22.10.19  Открытие смены
Function frchn_opensession()

  Local t, tt1

  If Len( AllTrim( oper_fr_inn ) ) == 12
    drvFR:Password := oper_frparol
    drvFR:fnbeginopensession()
    //
    drvFR:Password    := oper_frparol
    drvFR:TagNumber   := 1203
    drvFR:TagType     := 7
    drvFR:TagValueStr := oper_fr_inn
    //
    drvFR:fnsendtag()
    //
    drvFR:Password := oper_parol
    If drvFR:fnopensession() < 0
      t := drvFR:ResultCodeDescription
      Return AllTrim( t )
    Else
      t := drvFR:ContentsOfCashRegister
    Endif
    WaitPeriod( 100 ) // время произвольно
    Do While WaitPeriod()
    Enddo
  Else
    drvFR:Password := oper_parol
    If drvFR:opensession() < 0
      t := drvFR:ResultCodeDescription
      Return AllTrim( t )
    Else
      t := drvFR:ContentsOfCashRegister
    Endif
    WaitPeriod( 100 ) // время произвольно
    Do While WaitPeriod()
    Enddo
  Endif
  //
  WaitPeriod( 5000 )
  // попытка открыть порт в течении 5 секунд
  // время произвольное
  Do While WaitPeriod() // в цикле пробуем открыть с нужными параметрами
    tt1 := fr_ret_dan( 1 )
    If tt1[ FR_R_REGIM ] == 2  // смена открыта 24 часа не кончились
      Return t
    Endif
  Enddo
  Return t

// передача телефона(электронки) покупателя
Function frn_customeremail( address )

  Local  t

  drvFR:Password := oper_parol
  drvFR:CustomerEmail = address
  If drvFR:fnsendcustomeremail() < 0
    t := drvFR:ResultCodeDescription
    Return AllTrim( t )
  Endif
  Return Nil

// ДРАЙВЕР Получение статуса информационного обмена
Function frn_getinfoexchangestatusshtih( /*@*/exchangeStatus , ;
  /*@*/messageStatus, ;
  /*@*/messageCount, ;
  /*@*/documentNumber, ;
  /*@*/dateDoc, ;
  /*@*/timeDoc )

  Local t
  drvFR:Password := oper_frparol
  If drvFR:fngetinfoexchangestatus() < 0
    t := drvFR:ResultCodeDescription
    Return AllTrim( t )
  Endif
  exchangeStatus := drvFR:InfoExchangeStatus
  messageStatus := drvFR:MessageState
  messageCount := drvFR:MessageCount
  documentNumber := drvFR:DocumentNumber
  dateDoc := drvFR:Date
  timeDoc := drvFR:Time
  Return Nil

//
Function fr_writepassword( N_zapis_tabl, name_kassir )

  Local t1

  drvFR:Password    := oper_frparol
  drvFR:TableNumber := 2                // номер таблицы
  drvFR:FieldNumber := 2   // номер поля
  If drvFR:getfieldstruct() < 0
    t := drvFR:ResultCodeDescription
  Else
    t := drvFR:ContentsOfCashRegister
  Endif
  drvFR:Password    := oper_frparol
  drvFR:TableNumber := 2                // номер таблицы
  drvFR:RowNumber   := N_zapis_tabl     // номер ряда
  drvFR:FieldNumber := 2   // номер поля
  drvFR:ValueOfFieldString := name_kassir // Значение СТРОКА
  // drvFR:ValueOfFieldInteger := //Значение ЧИСЛО

  If drvFR:writetable() < 0
    t := drvFR:ResultCodeDescription
    Return AllTrim( t )
  Else
    t := drvFR:ContentsOfCashRegister
  Endif
  Return t

//
Function fr_readpassword( N_zapis_tabl, name_kassir )

  Local t1, t

  drvFR:Password    := oper_frparol
  drvFR:TableNumber := 2                // номер таблицы
  drvFR:FieldNumber := 2   // номер поля
  If drvFR:getfieldstruct() < 0
    t := drvFR:ResultCodeDescription
  Else
    t := drvFR:ContentsOfCashRegister
  Endif
  drvFR:ValueOfFieldString := ""
  drvFR:ValueOfFieldInteger := 0
  // читаем
  drvFR:Password    := oper_frparol
  drvFR:TableNumber := 2                // номер таблицы
  drvFR:RowNumber   := N_zapis_tabl     // номер ряда
  drvFR:FieldNumber := 2   // номер поля
  If drvFR:readtable() < 0
    t := drvFR:ResultCodeDescription
  Else
    t := drvFR:ContentsOfCashRegister
  Endif
  t1 := drvFR:ValueOfFieldString
  // читаем
  drvFR:Password    := oper_frparol
  drvFR:TableNumber := 2                // номер таблицы
  drvFR:RowNumber   := N_zapis_tabl     // номер ряда
  drvFR:FieldNumber := 1   // номер поля
  If drvFR:readtable() < 0
    t := drvFR:ResultCodeDescription
  Else
    t := drvFR:ContentsOfCashRegister
  Endif
  Return { t1, drvFR:ValueOfFieldInteger }

//
Function frn_writepassword()

  Local name_kassir, password_kassir, T_vrem
  Local arr := {}, s, buf := save_row( MaxRow() ), ;
    n_file := cur_dir() + "_kassa.txt"

  If glob_kassa == 1 .and. mek_kassa == 1
    Private drvFR
    If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
      //
    Else
      Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
    Endif
  Endif
  //
  r_use( dir_server() + "base1",, "BASE1" )
  Select BASE1
  Go Top
  Do While !Eof()
    If !Empty( base1->p1 )
      name_kassir     := AllTrim( Crypt( base1->p1, gpasskod ) )
      password_kassir := Val( AllTrim( Crypt( base1->p7, gpasskod ) ) )
      If password_kassir > 0 .and. password_kassir < 31
        fr_writepassword( password_kassir, name_kassir )
      Endif
    Endif
    Skip
  Enddo
  AAdd( arr, " " )
  AAdd( arr, "Установленные в ФР Кассиры:" )
  Select BASE1
  Go Top
  Do While !Eof()
    If !Empty( base1->p1 )
      name_kassir     := AllTrim( Crypt( base1->p1, gpasskod ) )
      password_kassir := Val( AllTrim( Crypt( base1->p7, gpasskod ) ) )
      If password_kassir > 0 .and. password_kassir < 31
        t_vrem := fr_readpassword( password_kassir, name_kassir )
        AAdd( arr, " -Кассир: " + PadR( t_vrem[ 1 ], 30 ) + " Пароль кассы: " + lstr( t_vrem[ 2 ] ) )
      Endif
    Endif
    Skip
  Enddo
  Close databases
  s := hb_eol()
  AEval( arr, {| x| s += Space( 10 ) + x + hb_eol() } )
  StrFile( s, n_file )
  rest_box( buf )
  viewtext( n_file )
  //
  Return Nil

//
Function frn_getdriverfr()

  // открытие и проверки
  Local vozvrat := .f.

  If glob_kassa == 1 .and. mek_kassa == 1
    Private drvFR
    If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    Else
      func_error( 4, "Ошибка запуска драйвера КАССЫ" )
      vozvrat := .t.
    Endif
  Endif
  Return vozvrat

// Контроль адреса электронной gjxns или телефона

Function controladdress( get, address )

  Local ret := .f.

  address := AllTrim( address )

  ret := hb_regexLike( emailTemplate, address ) .or. hb_regexLike( phoneTemplate, address ) .or. Empty( address )

  If !ret
    Alert( "Не верный формат телефона или E-mail адреса!" )
  Endif
  Return ret

// преобразование номера сотового
Function transformphone( address )

  address := AllTrim( address )
  address := AtRepl( '-', address, '' )
  address := AtRepl( ' ', address, '' )
  address := AtRepl( '_', address, '' )
  address := AtRepl( '(', address, '' )
  address := AtRepl( ')', address, '' )
  address := AtRepl( ':', address, '' )
  address := AtRepl( '=', address, '' )
  address := AtRepl( '+', address, '' )
  If Len( address ) == 10
    address := '+7' + address
  Elseif Len( address ) == 11
    If SubStr( address, 1, 1 ) != '7'
      address := '+7' + SubStr( address, 2 )
    Else
      address := '+' + address
    Endif
  Else
    address := ''
  Endif
  Return address

// 24.12.18
Function fr_read_otrezka()

  Local t1, t

  drvFR:Password    := oper_frparol
  drvFR:TableNumber := 1   // номер таблицы
  drvFR:FieldNumber := 7   // номер поля
  If drvFR:getfieldstruct() < 0
    t := drvFR:ResultCodeDescription
  Else
    t := drvFR:ContentsOfCashRegister
  Endif
  drvFR:ValueOfFieldString := ""
  drvFR:ValueOfFieldInteger := 0
  // читаем
  drvFR:Password    := oper_frparol
  drvFR:TableNumber := 1   // номер таблицы
  drvFR:RowNumber   := 1   // номер ряда
  drvFR:FieldNumber := 7   // номер поля
  If drvFR:readtable() < 0
    t := drvFR:ResultCodeDescription
  Else
    t := drvFR:ContentsOfCashRegister
  Endif
  Return drvFR:ValueOfFieldInteger

// 24.12.18
Function fr_zamena_otrezka( tip )

  Default tip To 1

  If tip > 1
    If fr_read_otrezka() > 0
      meK_otrez  := 2 // не отрезать
    Else
      meK_otrez  := 1 // отрезать
    Endif
  Endif
  Return Nil

// 30.06.19
Function fr_write_inn_kassir( inn_kassir )

  Local t1

  //
  drvFR:Password    := oper_parol
  drvFR:TagNumber   := 1203
  drvFR:TagType     := 7
  drvFR:TagValueStr := inn_kassir
  //
  drvFR:fnsendtag()
  Return Nil
