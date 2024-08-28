  // aPlat[ 1, 1 ] := 1  // номер справки
  // aPlat[ 1, 2 ] := 0  // номер корректировки
  // aPlat[ 1, 3 ] := 1  // налогоплательщик и пациент одно лицо 0 - нет, 1 - да
  // aPlat[ 1, 4 ] := 1234.98  // сумма 1
  // aPlat[ 1, 5 ] := 0.0  // сумма 2
  // aPlat[ 1, 6 ] := '344402247520'  // ИНН
  // aPlat[ 1, 7 ] := ctod( '04.03.1973' )  // дата рождения
  // aPlat[ 1, 8 ] := 21  // документ удостоверяющий личность код
  // aPlat[ 1, 9 ] := '1806 920681'  // документ удостоверяющий личность серия и номер
  // aPlat[ 1, 10 ] := ctod( '09.03.2004' )  // документ удостоверяющий личность дата выдачи
  // aPlat[ 1, 11 ] := 'Сидоров Сидор Петрович' // ФИО плательщика
  // aPlat[ 2, 1 ] := 2
  // aPlat[ 2, 2 ] := 0  // номер корректировки
  // aPlat[ 2, 3 ] := 0  // налогоплательщик и пациент одно лицо 0 - нет, 1 - да
  // aPlat[ 2, 4 ] := 0.00  // сумма 1
  // aPlat[ 2, 5 ] := 154254.0  // сумма 2
  // aPlat[ 2, 6 ] := ''  // ИНН
  // aPlat[ 2, 7 ] := ctod( '10.02.1962' )  // дата рождения
  // aPlat[ 2, 8 ] := 21  // документ удостоверяющий личность код
  // aPlat[ 2, 9 ] := '1818 458756'  // документ удостоверяющий личность серия и номер
  // aPlat[ 2, 10 ] := ctod( '25.08.2019' )  // документ удостоверяющий личность дата выдачи
  // aPlat[ 2, 11 ] := 'Сонина Евдокия Петровна'

  // aPlat[ 2, 12 ] := '344205196771'  // ИНН
  // aPlat[ 2, 13 ] := ctod( '20.09.1957' )  // дата рождения
  // aPlat[ 2, 14 ] := 21  // документ удостоверяющий личность код
  // aPlat[ 2, 15 ] := ''  // документ удостоверяющий личность серия и номер
  // aPlat[ 2, 16 ] := ctod( '' )  // документ удостоверяющий личность дата выдачи
  // aPlat[ 2, 17 ] := 'Бакулина тамара петровна'

// 05.08.24
function collect_pay( nYear )

  local tmp_sel := select()

  hb_alert( 'Собираем чеки' )
  use_base( 'hum_p', 'hum_p' )
  find ( str( glob_kartotek, 7 ) )
  do while hum_p->kod_k == glob_kartotek
    if year( hum_p->K_DATA ) == nYear
      mSumma += hum_p->cena
      AAdd( aCheck, { hum_p->( recno() ), 1, hum_p->cena, hum_p->sum_voz } )
    endif
    hum_p->( dbSkip() )
  enddo
  hum_p->( dbCloseArea() )

  @ nStrSum, 22 Say str( mSumma, 10, 2 )
  @ nStrSum, 54 Say str( mSummaVozvrat, 10, 2 )
  select( tmp_sel )
  return nil
  

// 03.08.24
Function spravka_fns()

  Local buf, str_sem, str_find, muslovie, mtitle
  Local arr_blk

  Private fl_found

  If polikl1_kart() > 0

    str_sem := 'Справка ФНС человека ' + lstr( glob_kartotek )
    If !g_slock( str_sem )
      Return func_error( 4, err_slock )
    Endif
    buf := SaveScreen()

    str_find := Str( glob_kartotek, 7 )
    muslovie := 'fns->kod_k == glob_kartotek'
    // R_Use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'PERSO' )
    // use_base( 'hum_p', 'HUMAN' )
    use_base( 'xml_fns', 'xml' )
    use_base( 'reg_fns', 'fns' )
    Set Relation To kod_xml into xml
    find ( str_find )
    fl_found := Found()

    arr_blk := { {|| findfirst( str_find ) }, ;
      {|| findlast( str_find, -1 ) }, ;
      {| n | skippointer( n, muslovie ) }, ;
      str_find, muslovie ;
      }

    If ! fl_found
      Keyboard Chr( K_INS )
    Endif
    mtitle := 'Справки для ФНС: ' + glob_k_fio
    alpha_browse( T_ROW, 0, MaxRow() -2, 79, 'defColumnSpravkaFNS', color0, mtitle, 'BG+/GR', ;
      .f., .t., arr_blk, , 'operspravkafns', , ;
      { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, GR+/R', .t., 180 } )

    dbCloseAll()
    RestScreen( buf )
    g_sunlock( str_sem )
  Endif

  Return Nil

// 03.08.24
Function defcolumnspravkafns( oBrow )

  Local oColumn, s
  Local blk := {|| iif( Empty( fns->kod_xml ), { 5, 6 }, { 3, 4 } ) } // iif( human->cena > 0, { 1, 2 }, { 3, 4 } ) ) }
  Local tip_bank := { 'бн', 'МИ', 'VI', 'MC', 'БАНК' }

  oColumn := TBColumnNew( ' Год ;     ', {|| put_val( fns->nyear, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' Номер ;справки', {|| put_val( fns->num_s, 7 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Коррек-;тировка', {|| put_val( fns->version, 3 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Сумма 1;       ', {|| put_kop( fns->sum1, 12 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Сумма 2;       ', {|| put_kop( fns->sum2, 12 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Дата;    ', {|| date_8( fns->date ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( 'Статус;      ', {|| iif( fns->kod_xml <= 0, iif( fns->kod_xml == 0, 'не обработано', 'принтер' ), xml->fname  ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )

  // If is_task( X_KASSA )
  // @ MaxRow() -1, 0 Say PadC( '<Esc>выход <Enter>редактирование <Ins>добавление <Del>удаление <F8>возврат', 80 ) Color 'N/W'
  // s := '<Ctrl+Enter>ввод услуг <F9>договор <F3>квитанции <F4>просмотр чеков <F10>печать чека'
  // Else
  // @ MaxRow() -1, 0 Say PadC( '<Esc> выход <Enter> редактирование <Ins> добавление <Del> удаление', 80 ) Color 'N/W'
  // s := '<Ctrl+Enter> ввод услуг <F8> возврат <F9> договор <F10> печать чека'
  // Endif
  @ MaxRow(), 0 Say PadC( s, 80 ) Color 'N/W'
  mark_keys( { '<Esc>', '<Enter>', '<Ins>', '<Del>', '<Ctrl+Enter>', '<F3>', '<F4>', '<F8>', '<F9>', '<F10>' }, 'R/W' )

  Return Nil

// 03.08.24
Function operspravkafns( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), fl := .f., rec, ;
    tmp_color := SetColor(), r1 := 15, c1 := 2, ;
    ln_chek := 0, t_hum_rec := 0, ;
    tip_kart := 2 //, ;
//    err_close := 'Лист учета ЗАКРЫТ. Доступ разрешён только администратору системы!'
  Private ldate_voz, lsum_voz, lfr_data, lfr_time

  Do Case
  Case nKey == K_F3
    // view_p_kvit(K_F3)
  Case nKey == K_F4
    // view_p_kvit(K_F4)
  Case nKey == K_F9
  Case nKey == K_INS  // .or. (nKey == K_ENTER .and. human->kod_k > 0)
    // if nKey == K_ENTER
    // func_error( 4, err_close )
    // return flag
    // endif
    If nKey == K_INS .and. ! fl_found
      ColorWin( 7, 0, 7, 79, 'N/N', 'W+/N' )
      ColorWin( 7, 0, 7, 79, 'N/N', 'BG+/B' )
      ColorWin( 7, 0, 7, 79, 'N/N', 'GR+/R' )
    Endif
    // rec := recno()
    flag := input_spr_fns( nKey )
  Case nKey == K_DEL
  Case nKey == K_CTRL_RET
  Otherwise
    Keyboard ''
  Endcase

  Return flag

// 05.08.24
Function input_spr_fns( nKey )

  Local buf := SaveScreen(), tmp_color := SetColor(), str_1, ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    mYear := year( date() ), mINN := space( 12 ), ;
    mSum1 := 0.0, mSum2 := 0, ;
    ret := -1, j := 0

  Private r1 := 11
  Private aCheck := {}, ;
    mncheck := 'Запуск', m1ncheck := 0, ;
    mSumma := 0.0, mSummaVozvrat := 0.0, ;
    nStrSum, ;
    mplat_fio := Space( 40 ), mplat_inn := Space( 12 ), ;
    mplat_adres := Space( 50 ), ; // адрес плательщика
    mplat_pasport := Space( 15 ), ;  // документ плательщика
    MKEMVYD, M1KEMVYD := 0, MKOGDAVYD := CToD( '' ) // кем и когда выдан паспорт ПЛАТЕЛЬЩИКА

  If mem_plsoput == 2
    --r1
  Endif
  mywait()
    
  If nKey == K_ENTER
  Endif
//  r_use( dir_server + 'hum_plat', dir_server + 'hum_plat', 'KPLAT' )
//  find ( Str( human->( RecNo() ), 7 ) )
//  If Found()
//    mplat_adres   := KPLAT->ADRES
//    mplat_pasport := KPLAT->PASPORT
//    m1kemvyd  := Kplat->kemvyd   // кем выдан документ ПЛАТЕЛЬЩИКА
//    mkogdavyd := kplat->kogdavyd // когда выдан документ ПЛАТЕЛЬЩИКА
//  Endif
//  KPLAT->( dbCloseArea() )
  //
//  mtip_usl := inieditspr( A__MENUVERT, menu_kb, m1tip_usl )
//  mlpu := inieditspr( A__POPUPMENU, dir_server + 'mo_uch', m1lpu )
//  motd := inieditspr( A__POPUPMENU, dir_server + 'mo_otd', m1otd )
//  MKEMVYD := inieditspr( A__POPUPMENU, dir_server + 's_kemvyd', M1KEMVYD )
//  If m1tip_usl == PU_D_SMO
//    mpr_smo := inieditspr( A__POPUPMENU, dir_server + 'p_d_smo', m1pr_smo )
//  Elseif m1tip_usl == PU_PR_VZ
//    mpr_smo := inieditspr( A__POPUPMENU, dir_server + 'p_pr_vz', m1pr_smo )
//  Endif
//  str_1 := ' справки для ФНС'
  If nKey == K_INS
    str_1 := 'добавление' // + str_1
  Else
    str_1 := 'редактирование' // + str_1
  Endif
  Private gl_area := { r1, 0, MaxRow() -1, MaxCol(), 0 }
  box_shadow( r1, 0, MaxRow() -1, MaxCol(), color1, 'Справка для ФНС - ' + str_1, color8 )
  status_key( '^<Esc>^ - выход;  ^<PgDn>^ - запись' )
  //
  Do While .t.
    SetColor( cDataCGet )
    j := r1 + 1
    @ j, 1 Clear To MaxRow() -2, MaxCol() -1
    @ ++j, 2 Say 'Отчетный год' Get mYear pict '9999'  // ;
//      reader {| x| menu_reader( x, { {| k, r, c| ret_uch_otd( k, r, c, sys_date,, X_PLATN ) } }, A__FUNCTION,,, .f. ) }
    @ j, 37 Say 'ИНН плательщика' Get mINN pict '999999999999'
    if nKey == K_INS
      @ ++j, 3 say 'Подбор чеков ...' get mncheck ;
          reader { | x | menu_reader( x, { { | | collect_pay( mYear ) } } ,A__FUNCTION, , , .f. ) }
    endif
    nStrSum := ++j
    @ j, 2 Say 'Оплаченная сумма - '  // + str( mSumma, 10, 2 )
    @ j, 37 Say 'Сумма возвратов - '  // + str( mSummaVozvrat, 10, 2 ) // ;
    @ ++j, 2 Say 'Сумма 1 -' Get mSum1 pict '999999999.99'
    @ j, 37 Say 'Сумма 1 -' Get mSum2 pict '999999999.99'
      //      reader {| x| menu_reader( x, menu_kb, A__MENUVERT,,, .f. ) } ;
//      valid {| g, o| val_tip_usl( g, o ) }
//    get1_p_kart()  // остальные Get'ы
//    If nKey == K_ENTER .and. !ver_pub_date( mk_data, .t. )
//      Keyboard Chr( K_ESC )
//    Endif
    count_edit := myread(, @pos_read, ++k_read )
    If LastKey() != K_ESC
//      err_date_diap( mn_data, 'Дата начала лечения' )
//      err_date_diap( mk_data, 'Дата окончания лечения' )
      If f_esc_enter( 1 )
//        If m1lpu == 0
//          func_error( 4, 'Не введено лечебное учреждение!' )
//          Loop
//        Endif
//        If Empty( mk_data )
//          func_error( 4, 'Не введена дата окончания лечения.' )
//          Loop
//        Endif
        mywait()
//        Select HUMAN
//        If nKey == K_INS
//          addrec( 7 )
//          human->kod_k := glob_kartotek
//          fl_found := .t.
//        Else
//          g_rlock( forever )
//        Endif
// запишем
        Unlock
//        human->( dbCommit() )
//        g_use( dir_server + 'hum_plat', dir_server + 'hum_plat', 'KPLAT' )
//        If Len( AllTrim( mplat_adres ) ) > 2 .or. Len( AllTrim( mplat_pasport ) ) > 2
//          find ( Str( human->( RecNo() ), 7 ) )
//          If !Found()
//            Append Blank
//          Else
//            g_rlock( forever )
//          Endif
//          KPLAT->kod     := human->( RecNo() )
//          KPLAT->ADRES   := mplat_adres
//          KPLAT->PASPORT := mplat_pasport
//          KPLAT->kemvyd := m1kemvyd     // кем выдан документ ПЛАТЕЛЬЩИКА
//          KPLAT->kogdavyd := mkogdavyd  // когда выдан документ ПЛАТЕЛЬЩИКА
//        Else
//          find ( Str( human->( RecNo() ), 7 ) )
//          If Found()
//            deleterec( .t. )
//          Endif
//        Endif
//        KPLAT->( dbCloseArea() )
//        Select HUMAN
        write_work_oper( glob_task, OPER_LIST, iif( nKey == K_INS, 1, 2 ), 1, count_edit )
        ret := 0
      Endif
    Endif
    If nKey == K_INS .and. ! fl_found
      ret := 1
    Endif
    Exit
  Enddo
//  Select HUMAN
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret

