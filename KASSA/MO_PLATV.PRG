// mo_platv.prg
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// вернуть тип услуги (тип больного)
Function f_p_tip_usl( r, c )

  Static sk := PU_PLAT
  Local out_arr

  Default r To T_ROW, c To T_COL + 5
  popup_2array( menu_kb, r, c, sk, 1, @out_arr )
  If out_arr != NIL
    sk := out_arr[ 2 ]
  Endif
  Return out_arr

// вернуть тип услуги (bit-овый вариант)
Function fbp_tip_usl( r, c, ret_arr )

  Static sast := { .t., .f., .f. }
  Local i, j, a, out_arr

  Default r To T_ROW, c To T_COL + 5
  If ( a := bit_popup( r, c, menu_kb, sast ) ) != NIL
    out_arr := {} ; AFill( sast, .f. )
    For i := 1 To Len( a )
      AAdd( out_arr, a[ i, 2 ] )
      If ( j := AScan( menu_kb, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
        sast[ j ] := .t.
      Endif
    Next
    If Len( a ) == 1
      If a[ 1, 2 ] == PU_D_SMO  // добр.страхование
        ret_arr := ret_arr_dms( r, c )
      Elseif a[ 1, 2 ] == PU_PR_VZ  // взаимозачет
        ret_arr := ret_arr_vz( r, c )
      Endif
    Endif
  Endif
  Return out_arr

//
Function tit_tip_usl( k, a_dms, sh )

  Local i, s := "[ "

  If Len( k ) < 3
    For i := 1 To Len( k )
      s += AllTrim( inieditspr( A__MENUVERT, menu_kb, k[ i ] ) ) + ", "
    Next
    s := SubStr( s, 1, Len( s ) -2 ) + " ]"
    add_string( Center( s, sh ) )
    If Len( k ) == 1 .and. ValType( a_dms ) == "A"
      If k[ 1 ] == PU_D_SMO  // добр.страхование
        If Len( a_dms ) == 1
          add_string( Center( "ДСМО: " + AllTrim( inieditspr( A__POPUPMENU, dir_server() + "p_d_smo", a_dms[ 1 ] ) ), sh ) )
        Endif
      Elseif k[ 1 ] == PU_PR_VZ  // взаимозачет
        If Len( a_dms ) == 1
          add_string( Center( "Предприятие: " + AllTrim( inieditspr( A__POPUPMENU, dir_server() + "p_pr_vz", a_dms[ 1 ] ) ), sh ) )
        Endif
      Endif
    Endif
  Endif
  Return Nil

//
Function ret_arr_dms( r1, c1 )

  Static sa
  Local r2, c2, nr := 0, arr := {}, t_mas := {}, buf, buf1, i, ret

  Default r1 To T_ROW, c1 To T_COL + 5
  g_use( dir_server() + "p_d_smo",, "MM" )
  dbEval( {|| ++nr, AAdd( arr, { mm->( RecNo() ), mm->name } ) } )
  Use
  If nr == 0
    func_error( 4, "База данных ДСМО пуста!" )
    Return Nil
  Endif
  ASort( arr,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
  AEval( arr, {| x| AAdd( t_mas, x[ 2 ] ) } )
  r2 := r1 + nr + 1
  c2 := c1 + 33 + 1
  If c2 > 77
    c2 := 77 ; c1 := 76 -33
  Endif
  If r2 > MaxRow() -2 ; r2 := MaxRow() -2 ; Endif
  If r2 == MaxRow() -2
    r1 := r2 - nr -1
    If r1 < 2 ; r1 := 2 ; Endif
  Endif
  buf := save_box( r1, c1, r2 + 1, c2 + 2 )
  buf1 := save_row( MaxRow() )
  AEval( t_mas, {| x, i, fl| fl := iif( sa == NIL, .t., AScan( sa, arr[ i, 1 ] ) > 0 ), ;
    t_mas[ i ] := iif( fl, " * ", "   " ) + t_mas[ i ] } )
  status_key( "^<Esc>^-отказ; ^<Enter>^-выбор; ^<Ins,+,->^-смена признака печати данной ДСМО" )
  If Popup( r1, c1, r2, c2, t_mas,, color0, .t., "fmenu_reader" ) > 0
    ret := {}
    For i := 1 To nr
      If "*" $ Left( t_mas[ i ], 3 )
        AAdd( ret, arr[ i, 1 ] )
      Endif
    Next
    If Empty( ret )
      ret := NIL
    Endif
    sa := ret
  Endif
  rest_box( buf )
  rest_box( buf1 )
  Return ret

//
Function ret_arr_vz( r1, c1 )

  Static sa
  Local r2, c2, nr := 0, arr := {}, t_mas := {}, buf, buf1, i, ret

  Default r1 To T_ROW, c1 To T_COL + 5
  g_use( dir_server() + "p_pr_vz",, "MM" )
  dbEval( {|| ++nr, AAdd( arr, { mm->( RecNo() ), mm->name } ) } )
  Use
  If nr == 0
    func_error( 4, "База данных предприятий пуста!" )
    Return Nil
  Endif
  ASort( arr,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
  AEval( arr, {| x| AAdd( t_mas, x[ 2 ] ) } )
  r2 := r1 + nr + 1
  c2 := c1 + 33 + 1
  If c2 > 77
    c2 := 77 ; c1 := 76 -33
  Endif
  If r2 > MaxRow() -2 ; r2 := MaxRow() -2 ; Endif
  If r2 == MaxRow() -2
    r1 := r2 - nr -1
    If r1 < 2 ; r1 := 2 ; Endif
  Endif
  buf := save_box( r1, c1, r2 + 1, c2 + 2 )
  buf1 := save_row( MaxRow() )
  AEval( t_mas, {| x, i, fl| fl := iif( sa == NIL, .t., AScan( sa, arr[ i, 1 ] ) > 0 ), ;
    t_mas[ i ] := iif( fl, " * ", "   " ) + t_mas[ i ] } )
  status_key( "^<Esc>^-отказ; ^<Enter>^-выбор; ^<Ins,+,->^-смена признака печати данного предприятия" )
  If Popup( r1, c1, r2, c2, t_mas,, color0, .t., "fmenu_reader" ) > 0
    ret := {}
    For i := 1 To nr
      If "*" $ Left( t_mas[ i ], 3 )
        AAdd( ret, arr[ i, 1 ] )
      Endif
    Next
    If Empty( ret )
      ret := NIL
    Endif
    sa := ret
  Endif
  rest_box( buf )
  rest_box( buf1 )
  Return ret

// 02.07.18
Function kart_plat()

  Local buf, str_sem

  If polikl1_kart() > 0
    If glob_kassa == 1 .and. mek_kassa == 1 // .and. mek_nkassa == 1
      Private drvFR
      If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
        fr_zamena_otrezka()
      Else
        Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
      Endif
    Endif
    //
    str_sem := "ПУ Редактирование человека " + lstr( glob_kartotek )
    If !g_slock( str_sem )
      Return func_error( 4, err_slock() )
    Endif
    buf := SaveScreen()
    Private fl_found, str_find, muslovie
    str_find := Str( glob_kartotek, 7 )
    muslovie := "human->kod_k == glob_kartotek"
    r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
    use_base( "hum_p", "HUMAN" )
    find ( str_find )
    fl_found := Found()
    arr_blk := { {|| findfirst( str_find ) }, ;
      {|| findlast( str_find, -1 ) }, ;
      {| n| skippointer( n, muslovie ) }, ;
      str_find, muslovie;
      }
    If !fl_found ; Keyboard Chr( K_INS ) ; Endif
    mtitle := "Платные услуги: " + glob_k_fio
    alpha_browse( T_ROW, 0, MaxRow() -2, 79, "f2_k_plat", color0, mtitle, "BG+/GR", ;
      .f., .t., arr_blk,, "f3_k_plat",, ;
      { "═", "░", "═", "N/BG,W+/N,B/BG,BG+/B,R/BG,GR+/R", .t., 180 } )
    Close databases
    RestScreen( buf )
    g_sunlock( str_sem )
  Endif
  Return Nil

// 25.10.25
Function f2_k_plat( oBrow )

  Local oColumn, s, blk := {|| iif( human->is_kas == 2, { 5, 6 }, iif( human->cena > 0, { 1, 2 }, { 3, 4 } ) ) }
  Local tip_bank := { "бн", "МИ", "VI", "MC", "БАНК", "СБП" }

  If glob_kassa == 1 .and. mek_kassa == 1 // в кассе 01.12.2008
    // oColumn := TBColumnNew("  ",{|| iif(human->sbank < 1, "    ",iif(human->sbank == human->cena, "б/н ","б/нН")) })
    oColumn := TBColumnNew( "    ", ;
      {|| iif( human->sbank < 1, "    ", ;
      tip_bank[ human->fr_tipkart + 1 ] + iif( human->sbank == human->cena, " ", "Н" ) ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    oColumn := TBColumnNew( "    ", ;
      {|| iif( human->tip_usl == PU_PLAT, { "    ", Str( human->kv_cia, 4 ), " " }[ human->is_kas + 1 ], ;
      iif( human->tip_usl == PU_PR_VZ, "в/з ", "ДМС " ) ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
  Elseif glob_kassa == 1 .and. mek_kassa == 2 // с ФР но не в КАССЕ 01.12.2008
    oColumn := TBColumnNew( "№ кв.;книжки", {|| put_val( human->n_kvit, 5 ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    oColumn := TBColumnNew( "    ", ;
      {|| iif( human->tip_usl == PU_PLAT, { "    ", Str( human->kv_cia, 4 ), " " }[ human->is_kas + 1 ], ;
      iif( human->tip_usl == PU_PR_VZ, "в/з ", "ДМС " ) ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
  Elseif glob_pl_reg == 1
    oColumn := TBColumnNew( "№ кв.;книжки", {|| put_val( human->n_kvit, 5 ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    //
    oColumn := TBColumnNew( "№ кви-;танции", {|| put_val( human->kv_cia, 6 ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    //
    oColumn := TBColumnNew( "  Дата; оплаты", {|| date_8( c4tod( human->pdate ) ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
  Endif
  //
  oColumn := TBColumnNew( " Начало; лечения", {|| date_8( human->n_data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Окончан.; лечения", {|| date_8( human->k_data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  If mem_naprvr == 2
    oColumn := TBColumnNew( "Напр.;врач", {|| put_val( ret_tabn( human->kod_vr ), 5 ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
  Endif
  //
  oColumn := TBColumnNew( "Стоимость; лечения", {|| put_kop( human->cena, 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  If glob_kassa == 1
    oColumn := TBColumnNew( "  Возврат;  денег", {|| put_kop( human->sum_voz, 10 ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
  Else
    oColumn := TBColumnNew( " ", {|| iif( human->tip_usl == PU_D_SMO, 'д', iif( human->tip_usl == PU_PR_VZ, 'з', ' ' ) ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
  Endif
  //
  oColumn := TBColumnNew( "  Дата;закрытия", {|| date_8( human->date_close ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If is_task( X_KASSA )
    @ MaxRow() -1, 0 Say PadC( "<Esc>выход <Enter>редактирование <Ins>добавление <Del>удаление <F8>возврат", 80 ) Color "N/W"
    s := "<Ctrl+Enter>ввод услуг <F9>договор <F3>квитанции <F4>просмотр чеков <F10>печать чека"
  Else
    @ MaxRow() -1, 0 Say PadC( "<Esc> выход <Enter> редактирование <Ins> добавление <Del> удаление", 80 ) Color "N/W"
    s := "<Ctrl+Enter> ввод услуг <F8> возврат <F9> договор <F10> печать чека"
  Endif
  @ MaxRow(), 0 Say PadC( s, 80 ) Color "N/W"
  mark_keys( { "<Esc>", "<Enter>", "<Ins>", "<Del>", "<Ctrl+Enter>", "<F3>", "<F4>", "<F8>", "<F9>", "<F10>" }, "R/W" )
  Return Nil

// 25.12.25
Function f3_k_plat( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), buf1, fl := .f., rec, mkod, ;
    tmp_color := SetColor(), r1 := 15, c1 := 2, v_summa, v_sdacha, adbf, s, ;
    ln_chek := 0, t_hum_rec := 0, kart_kod, t_k_data, lnds, fr_zavodnomer := "", ;
    mi_post, mphone_m, maddress, tip_kart := 2, mkod_kem_vid, ;
    err_close := "Лист учета ЗАКРЫТ. Доступ разрешён только администратору системы!"
  Private ldate_voz, lsum_voz, lfr_data, lfr_time

  Do Case
  Case nKey == K_F3
    view_p_kvit( K_F3 )
  Case nKey == K_F4 .and. is_task( X_KASSA )
    view_p_kvit( K_F4 )
  Case nKey == K_F8 .and. glob_kassa == 1 .and. human->is_kas == 1 .and. ;
      human->kod_k > 0 .and. ver_pub_date( human->k_data, .t. ) .and. ;
      human->cena > 0
    If !Empty( human->date_close ) .and. !currentuser():isadmin()
      func_error( 4, err_close )
      Return flag
    Endif
    rec := human->( RecNo() )
    vozvrat_platn( rec )
    Select PERSO
    Select HUMAN
    Goto ( rec )
    SetColor( tmp_color )
    rest_box( buf ) ; flag := 0
  Case nKey == K_F10 .and. glob_kassa == 1 .and. human->is_kas == 2 .and. human->cena > 0
    buf := SaveScreen()
    // убрал спецдобавку для КСП3
    clrline( MaxRow() -1, color0 )
    // поиск номера или эл.почты
    t_hum_rec := human->( RecNo() )
    kart_kod  := human->kod_k
    mi_post   := Space( 30 )
    mphone_m  := Space( 11 )
    Select HUMAN
    Do While human->kod_k == kart_kod  .and. !Eof()
      If Len( AllTrim( human->i_post ) ) > 4
        mi_post := human->i_post
      Endif
      Skip
    Enddo
    Goto ( t_hum_rec )
    // поиск телефона
    r_use( dir_server() + "kartote_",, "KR_" )
    goto( human->kod_k )
    mphone_m := kr_->phone_m
    kr_->( dbCloseArea() )
    mphone_m := transformphone( mphone_m )
    // выбираем приоритетом телефон
    If Len( AllTrim( mphone_m ) ) < 11
      maddress := mi_post
    Else
      maddress := mphone_m
    Endif
    //
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
    Set Relation To u_kod into USL
    find ( Str( human->( RecNo() ), 7 ) )
    // сразу сортируем по шифру услуг
    Index On fsort_usl( usl->shifr ) to ( cur_dir() + "tmp" ) While hu->kod == human->( RecNo() )
    adbf := { { "name", "C", 128, 0 }, ;
      { "vrach", "C", 50, 0 }, ;
      { "cena",  "N", 10, 2 }, ;
      { "kol",   "N",  4, 0 }, ;
      { "nds22", "N",  1, 0 }, ;
      { "nds20", "N",  1, 0 }, ;
      { "nds22", "N",  1, 0 }, ;  
      { "nds18", "N",  1, 0 }, ;
      { "nds10", "N",  1, 0 } }
    dbCreate( cur_dir() + "tmp", adbf )
    Use ( cur_dir() + "tmp" ) new
    adbf := {}
    Select HU
    Go Top
    Do While !Eof()
      If hu->kod_vr > 0 .and. AScan( adbf, hu->kod_vr ) == 0
        AAdd( adbf, hu->kod_vr )  // массив врачей
      Endif
      Skip
    Enddo
    fl := .t.
    Select HU
    Go Top
    Do While !Eof()
      If !Empty( round_5( hu->stoim, 2 ) )
        Select TMP
        Append Blank
        If glob_mo[ _MO_KOD_TFOMS ] == '171004' // КБ-4
          tmp->name := AllTrim( usl->name ) + " " + AllTrim( usl->full_name )
        Else
          If mek_kod_usl > 1
            If Len( AllTrim( usl->full_name ) ) > 3
              tmp->name := AllTrim( usl->full_name )
            Else
              tmp->name := AllTrim( usl->name )
            Endif
          Else
            If Len( AllTrim( usl->full_name ) ) > 3
              tmp->name := AllTrim( usl->shifr ) + " " + AllTrim( usl->full_name )
            Else
              tmp->name := AllTrim( usl->shifr ) + " " + AllTrim( usl->name )
            Endif
          Endif
        Endif
        If hu->kod_vr > 0 .and. fl
          perso->( dbGoto( hu->kod_vr ) )
          tmp->vrach := fam_i_o( perso->fio ) + " <" + lstr( perso->tab_nom ) + ">"
          If Len( adbf ) == 1  // если врач один,
            fl := .f.        // то печатаем его только в 1-ой услуге
          Endif
        Endif
        tmp->cena := round_5( hu->stoim / hu->kol, 2 )
        tmp->kol := hu->kol
        // НДС
        If Round( tmp->cena, 2 ) == Round( usl->pcena_d, 2 ) // дети
          lnds := round_5( usl->pnds_d, 0 )
        Else // взрослые
          lnds := round_5( usl->pnds, 0 )
        Endif
        If lnds == 18
          tmp->nds18 := 1
        Elseif lnds == 10
          tmp->nds10 := 1
        Elseif lnds == 20
          tmp->nds20 := 1
        Elseif lnds == 22
          tmp->nds22 := 1
        Endif
      Endif
      Select HU
      Skip
    Enddo
    hu->( dbCloseArea() )
    usl->( dbCloseArea() )
    Private p_summa := round_5( human->cena, 2 ), fl_sdacha := .f., ;
      mplat_fio := human->plat_fio, mplat_inn := human->plat_inn
    v_summa := v_sdacha := v_bank := 0
    If yes_chek( @v_summa, @v_sdacha, @v_bank,, @maddress, @tip_kart ) .and. ;
        chek_fr( v_summa, v_sdacha, @ln_chek, v_bank,, @fr_zavodnomer, maddress, tip_kart ) 
      Select HUMAN
      g_rlock( forever )
      human->is_kas  := 1
      human->kv_cia  := ln_chek
      human->sbank   := v_bank
      human->fr_data := lfr_data
      human->fr_time := lfr_time
      human->pdate   := lfr_data
      human->KOD_OPER := Asc( kod_polzovat )
      human->FR_zavod := fr_zavodnomer
      human->FR_tipkart := tip_kart
      human->fr_tip     := 2
      human->i_post     :=  maddress
      Unlock
      human->( dbCommit() )
      flag := 0
    Endif
    tmp->( dbCloseArea() )
    Select HUMAN
    RestScreen( buf )
  Case nKey == K_F9 // .and. human->cena > 0
    // печать договора
    Private pac_FIO, pac_adres, pac_data, dog_data, pac_kod, pac_1FIO, pac_kvit, phone_m
    Private m1vid_ud, mvidan_ud, mnom, MSER, MVID_UD
    Private mplat_fio := human->plat_fio, mplat_inn := human->plat_inn, nom_prihod := 0
    Private mplat_adres  := Space( 50 ), ; // адрес плательщика
    mplat_pasport := Space( 15 ), ;  // документ плательщика
    mplat_data_ud := Date(), mplat_vidan_ud := " "
    Private lnomer, l1nomer, muchastok
    Private okato_adresr, okato_adresg
    Private mdov_date, mdov_nomer, mdov_dolgn   //
    Private mmesto_r, ;       // место рождения
      m, ;      // документ выдан
    mdata_vidan_ud   // дата выдачи удостоверения
    private mregistrator := AllTrim( currentuser():FIO )
    buf := SaveScreen()
    clrline( 23, color0 )
    mdov_date  := oper_dov_date
    mdov_nomer := oper_dov_nomer
    mdov_dolgn := currentuser():Position
    t_hum_rec := human->( RecNo() )
    kart_kod := human->kod_k
    t_k_data := Year( human->k_data )
    Select HUMAN
    Do While human->kod_k == kart_kod .and. Year( human->k_data ) == t_k_data .and. !Eof()
      ++nom_prihod
      Skip
    Enddo
    Goto ( t_hum_rec )
    pac_kvit := human->kv_cia
    r_use( dir_server() + "kartotek",, "KR" )
    Goto ( human->kod_k )
    lnomer := l1nomer := lstr( kr->kod )
    muchastok := put_val( kr->uchast, 2 )
    luchast := ""
    If is_uchastok == 1
      If !emptyall( kr->bukva, kr->uchast, kr->kod_vu )
        lnomer := ""
        If !Empty( kr->bukva )
          lnomer += kr->bukva
        Endif
        lnomer += lstr( kr->uchast, 2 )
        If kr->kod_vu > 0
          lnomer += "/" + lstr( kr->kod_vu )
        Endif
        l1nomer := lnomer
      Endif
    Elseif eq_any( is_uchastok, 2, 3 )
      If !emptyall( kr->bukva, kr->uchast )
        luchast := " [уч-к "
        If !Empty( kr->bukva )
          luchast += kr->bukva
        Endif
        luchast += lstr( kr->uchast, 2 )
        luchast += "] "
      Endif
      If is_uchastok == 3
        r_use( dir_server() + "kartote2",, "KART2" )
        If human->kod_k <= LastRec()
          Goto ( human->kod_k )
          luchast += AllTrim( kart2->kod_AK )
        Endif
        kart2->( dbCloseArea() )
      Endif
    Endif
    lnomer := Expand( lnomer ) + luchast
    pac_fio   := fam_i_o( kr->fio )
    pac_1fio  := AllTrim( kr->fio )
    pac_adres := AllTrim( kr->adres )
    pac_data  := full_date( kr->date_r )
    pac_kod   := lstr( kr->kod )
    kr->( dbCloseArea() )
    r_use( dir_server() + "kartote_",, "KR_" )
    Goto ( human->kod_k )
    okato_adresg := ret_okato_ulica( "", kr_->okatog, 1, 2 )
    okato_adresr := ret_okato_ulica( "", kr_->okatop, 1, 2 )
    m1vid_ud := kr_->vid_ud
    mnom     := kr_->nom_ud
    mser     := kr_->ser_ud
    mmesto_r := kr_->mesto_r
    mphone_m := kr_->phone_m
    mkod_kem_vid := kr_->kemvyd
    mdata_vidan_ud := kr_->kogdavyd
    kr_->( dbCloseArea() )
    phone_m := transformphone( mphone_m )
    mvid_ud := get_name_vid_ud( m1vid_ud )
    //
    If mkod_kem_vid > 0
      r_use( dir_server() + "s_kemvyd",, "VYD" )
      Goto ( mkod_kem_vid )
      mvidan_ud := vyd->name
      vyd->( dbCloseArea() )
    Endif
    dog_data := human->n_data
    r_use( dir_server() + "hum_plat", dir_server() + "hum_plat", "KPLAT" )
    find ( Str( human->( RecNo() ), 7 ) )
    If Found()
      mplat_adres   := KPLAT->ADRES
      mplat_pasport := KPLAT->PASPORT
      mplat_data_ud := KPLAT->kogdavyd
      If KPLAT->kemvyd > 0
        r_use( dir_server() + "s_kemvyd",, "VYD" )
        Goto ( KPLAT->kemvyd )
        mplat_vidan_ud := vyd->name
        vyd->( dbCloseArea() )
      Endif
    Endif
    KPLAT->( dbCloseArea() )
    //
    use_base( "humanst",,, .t. ) // только для чтения
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
    Set Relation To u_kod into USL
    find ( Str( human->( RecNo() ), 7 ) )
    // сразу сортируем по шифру услуг
    Index On fsort_usl( usl->shifr ) to ( cur_dir() + "tmp" ) While hu->kod == human->( RecNo() )
    adbf := { { "name",      "C", 65, 0 }, ; // наименование услуги
      { "shifr",     "C", 10, 0 }, ; // шифр услуги
      { "cena",      "N", 10, 2 }, ;
      { "kol",       "N",  4, 0 }, ;
      { "kod_vr",    "N",  4, 0 }, ;
      { "full_name", "C", 255, 0 }, ;
      { "vrach",     "C", 50, 0 }, ;
      { "nds22",     "N",  1, 0 }, ;
      { "nds20",     "N",  1, 0 }, ;
      { "nds18",     "N",  1, 0 }, ;
      { "nds10",     "N",  1, 0 }, ;
      { "kod_diag",  "C",  6, 0 }, ;
      { "zf",        "C",  20, 0 } }
    dbCreate( cur_dir() + "tmp", adbf )
    Use ( cur_dir() + "tmp" ) new
    Select HU
    Go Top
    Do While !Eof()
      Select TMP
      Append Blank
      tmp->name      := AllTrim( usl->name )
      tmp->full_name := iif( Len( AllTrim( usl->full_name ) ) < 2, AllTrim( usl->name ), ;
        AllTrim( usl->full_name ) )
      tmp->shifr     := AllTrim( usl->shifr )
      tmp->cena      := round_5( hu->stoim / hu->kol, 2 )
      tmp->kol       := hu->kol
      tmp->kod_vr    := hu->kod_vr
      If hu->kod_vr > 0
        perso->( dbGoto( hu->kod_vr ) )
        tmp->vrach := fam_i_o( perso->fio ) + " <" + lstr( perso->tab_nom ) + ">"
      Endif
      // НДС
      If Round( tmp->cena, 2 ) == Round( usl->pcena_d, 2 ) // дети
        lnds := round_5( usl->pnds_d, 0 )
      Else // взрослые
        lnds := round_5( usl->pnds, 0 )
      Endif
      If lnds == 18
        tmp->nds18 := 1
      Elseif lnds == 10
        tmp->nds10 := 1
      Elseif lnds == 20
        tmp->nds20 := 1
      Elseif lnds == 22
        tmp->nds22 := 1
      Endif
      // зубная формула
      Select HUMANST
      find ( Str( 2, 1 ) + Str( hu->( RecNo() ), 8 ) )
      If Found()
        tmp->KOD_DIAG  := humanst->KOD_DIAG
        tmp->ZF        := humanst->ZF
      Endif
      Select HU
      Skip
    Enddo
    usl->( dbCloseArea() )
    hu->( dbCloseArea() )
    HUMANST->( dbCloseArea() )
    Select TMP
    Index On fsort_usl( FIELD->shifr ) to ( cur_dir() + "tmp" )
    Private p_summa := round_5( human->cena, 2 )
    rec := human->( RecNo() ) ; c1 := human->lpu
    If Len( AllTrim( mem_dogovor ) ) > 3
      print_shablon( AllTrim( mem_dogovor ) )
    Else
      Private file_sh
      If !Empty( AllTrim( mem_dogovor ) ) .and. ;
          !Empty( file_sh := menu_shablon( 3, 3, dir_exe() + "*." + Upper( AllTrim( mem_dogovor ) ), color8, .f. ) )
        Select TMP
        Go Top
        f1_pr_shab( file_sh )
      Endif
    Endif
    Close databases
    //
    r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
    use_base( "hum_p", "HUMAN" )
    Goto ( rec )
    SetColor( tmp_color )
    flag := 0
    RestScreen( buf )
  Case nKey == K_INS .or. ( nKey == K_ENTER .and. human->kod_k > 0 )
    If nKey == K_ENTER .and. !Empty( human->date_close ) .and. !currentuser():isadmin()
      func_error( 4, err_close )
      Return flag
    Endif
    If nKey == K_INS .and. !fl_found
      ColorWin( 7, 0, 7, 79, "N/N", "W+/N" )
      ColorWin( 7, 0, 7, 79, "N/N", "BG+/B" )
      ColorWin( 7, 0, 7, 79, "N/N", "GR+/R" )
    Endif
    rec := RecNo()
    flag := f_p_kart( nKey )
  Case nKey == K_DEL .and. human->is_kas != 1 .and. ;
      human->kod_k > 0 .and. ver_pub_date( human->k_data, .t. )
    If !Empty( human->date_close ) .and. !currentuser():isadmin()
      func_error( 4, err_close )
    Elseif f_esc_enter( 2, .t. )
      mywait()
      g_use( dir_server() + "hum_p_u", { dir_server() + "hum_p_u", ;
        dir_server() + "hum_p_uk", ;
        dir_server() + "hum_p_ud", ;
        dir_server() + "hum_p_uv", ;
        dir_server() + "hum_p_ua" }, "HU" )
      j := 0
      Do While .t.
        Select HU
        find ( Str( human->( RecNo() ), 7 ) )
        If !Found() ; exit ; Endif
        deleterec( .t., .f. )  // очистка записи без пометки на удаление
        ++j
      Enddo
      hu->( dbCloseArea() )
      write_work_oper( glob_task, OPER_USL, 3, j )
      write_work_oper( glob_task, OPER_LIST, 3 )
      Select HUMAN
      deleterec( .t. )
      Commit
      oBrow:gotop()
      find ( str_find )
      If !Found()
        fl_found := .f.
      Endif
      stat_msg( "Лист учета удален!" ) ; mybell( 1, OK )
      flag := 0
      If !fl_found
        flag := 1
      Endif
      rest_box( buf )
    Endif
  Case human->is_kas == 1 .and. nKey == K_DEL .and. human->kod_k > 0 .and. human->cena > 0
    If !Empty( human->date_close ) .and. !currentuser():isadmin()
      func_error( 4, err_close )
    Elseif human->sum_voz > 0
      func_error( 4, "По данному листу учета уже производился возврат денег!" )
    Else
      ldate_voz := sys_date
      lsum_voz := human->CENA - human->sbank
      s := " \" + ;
        "      Общая стоимость услуг = " + lput_kop( human->CENA, .t. ) + " руб.\" + ;
        "      Введите дату  возврата  @           \" + ;
        "      Введите сумму возврата  @           \" + ;
        " \"
      displbox( s, ;
        , ;                   // цвет окна (умолч. - cDataCGet)
        { "ldate_voz", "lsum_voz" }, ; // массив Private-переменных для редактирования
      {, pict_cena() }, ; // массив Picture для редактирования
      17 )
      If LastKey() == K_ESC
        //
      Elseif Round( lsum_voz, 2 ) <= 0
        mybell()
      Elseif lsum_voz > human->CENA - human->sbank
        // func_error(4,"Сумма возврата больше стоимости услуг!")
        func_error( 4, "Возврат чека проводите по клавише <F8> !" )
      Elseif mek_kassa == 1
        // .and. f_Esc_Enter("возврата "+lput_kop(lsum_voz,.t.)+" руб.") .and. vozv_fr(lsum_voz)
        // select HUMAN
        // G_RLock(forever)
        // replace human->date_voz with dtoc4(ldate_voz), human->sum_voz with lsum_voz
        // UnLock
        // human->(dbCommit())
        // stat_msg("Сумма возврата записана!") ; mybell(1,OK)
        // flag := 0
        // rest_box(buf)
        func_error( 4, "Возврат чека проводите по клавише <F8> !" )
      Elseif currentuser():isadmin() .and. mek_kassa == 2 .and. ;
          involved_password( 1, 1, "возврата " + lput_kop( lsum_voz, .t. ) + " руб." ) .and. ;
          f_esc_enter( "возврата " + lput_kop( lsum_voz, .t. ) + " руб." )
        Select HUMAN
        g_rlock( forever )
        Replace human->date_voz With dtoc4( ldate_voz ), human->sum_voz With lsum_voz
        Unlock
        human->( dbCommit() )
        stat_msg( "Сумма возврата записана!" ) ; mybell( 1, OK )
        flag := 0
        rest_box( buf )
      Endif
    Endif
  Case nKey == K_CTRL_RET .and. human->kod_k > 0
    If !Empty( human->date_close ) .and. !currentuser():isadmin()
      func_error( 4, err_close )
      Return flag
    Endif
    rec := human->( RecNo() ) ; c1 := human->lpu
    Close databases
    usl_p_kart( rec, c1 )
    r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
    use_base( "hum_p", "HUMAN" )
    Goto ( rec )
    SetColor( tmp_color )
    rest_box( buf ) ; flag := 0
  Otherwise
    Keyboard ""
  Endcase
  Return flag

//
Function ret_zapros3000()

  Local buf, r1 := 12, r2 := 18, i, tmp_color := SetColor( color1 )

  buf := box_shadow( r1, 10, r2, 69,, "РАБОТА со СКИДОЧНЫМИ картами", "W/R+" )
  SetColor( color8 )
  str_center( r1 + 2, "Внимание !" )
  str_center( r1 + 3, "Плательщик имеет СКИДОЧНУЮ КАРТУ ?" )
  SetColor( color1 )
  str_center( r2 - 2, "Выберите действие:" )
  setmtcolor( "BG+/B,W+/R,GR+/B,GR+/R" )
  @ r2 - 1, 24 Prompt " ~Карты НЕТ "
  @ r2 - 1, 44 Prompt " ~СКИДКА 1000р "
  Menu To i
  SetColor( tmp_color )
  rest_box( buf )
  Return ( i == 2 )

//
Function ret_soob_3000( tip, sum_1, sum_2 )

  Local buf, r1 := 12, r2 := 18, i, tmp_color := SetColor( color1 )

  If tip == 1
    buf := box_shadow( r1, 10, r2, 69,, "РАБОТА со СКИДОЧНЫМИ картами", "W/R+" )
    SetColor( color8 )
    str_center( r1 + 2, "Внимание !" )
    // str_center(r1+3,"Сумма ДО скидки    :"+put_kop(sum_1))
    str_center( r1 + 3, "Сумма ПОСЛЕ скидки :" + put_kop( sum_1 - sum_2, 8 ) )
    str_center( r1 + 4, "Сумма СКИДКИ :" + put_kop( sum_2, 8 ) )
    SetColor( color1 )
    setmtcolor( "BG+/B,W+/R,GR+/B,GR+/R" )
    @ r2 - 1, 37 Prompt " ~ОК "
    Menu To i
    SetColor( tmp_color )
    rest_box( buf )
  Else
    buf := SaveScreen()
    f_message( { "Внимание !", ;
      "", ;
      "Сумма cкидки ВЕЛИКА :" + put_kop( sum_2, 8 ), ;
      "Скидка отменена Проведите скидку вручную !" },, "GR+/R", "W+/R", 13 )
    Inkey( 0 )
    RestScreen( buf )
  Endif
  Return Nil


//
Function view_p_kvit( nkey )

  Local sh := 80, HH := 57, reg_print := 2, buf := save_row( MaxRow() ), i, ;
    name_file := cur_dir() + "tmp.txt", j := 0, tmp_select := Select(), arr_lpu := {}, ;
    rec := human->( RecNo() )

  mywait()
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( iif( nKey == K_F3, "Оплаченные услуги", "Список чеков" ), sh ) )
  add_string( Center( glob_k_fio, sh ) )
  r_use( dir_server() + "uslugi",, "USL" )
  If nKey == K_F3
    r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
    Set Relation To u_kod into USL
    Select HUMAN
    find ( str_find )
    Do while &muslovie
      ++j
      add_string( "" )
      add_string( lstr( j ) + "." )
      add_string( "Квитанционная книжка №:  " + lstr( human->n_kvit ) + ;
        ",  квитанция №:  " + lstr( human->kv_cia ) + ;
        ",  дата оплаты:  " + date_8( c4tod( human->pdate ) ) )
      Select HU
      find ( Str( human->( RecNo() ), 7 ) )
      Do While hu->kod == human->( RecNo() )
        s := Space( 10 ) + "Шифр услуги:  " + usl->shifr + ",  " + ;
          "кол-во услуг:" + Str( hu->kol, 4 )
        If hu->kod_vr > 0
          s += ",  код врача:  " + lstr( ret_tabn( hu->kod_vr ) )
        Endif
        add_string( s )
        Skip
      Enddo
      Select HUMAN
      Skip
    Enddo
    hu->( dbCloseArea() )
    Select HUMAN
    Goto ( rec )
  Else
    r_use( dir_server() + "kas_pl_u", dir_server() + "kas_pl1u", "KPLU" )
    Set Relation To u_kod into USL
    r_use( dir_server() + "kas_pl", dir_server() + "kas_pl1", "KPL" )
    find ( Str( glob_kartotek, 7 ) )
    Do While kpl->kod_k == glob_kartotek
      ++j
      add_string( "" )
      add_string( lstr( j ) + "." )
      add_string( "Дата оплаты: " + full_date( kpl->k_data ) + ;
        ",  чек №: " + lstr( kpl->n_chek ) + ;
        ",  сумма за услуги: " + lput_kop( kpl->cena, .t. ) )
      Select KPLU
      find ( Str( kpl->( RecNo() ), 7 ) )
      Do While kplu->kod == kpl->( RecNo() )
        s := "  Услуга: " + AllTrim( usl->shifr ) + ;
          ", цена: " + lput_kop( kplu->u_cena, .t. ) + ;
          ", кол-во: " + lstr( kplu->kol ) + ;
          ", ст-ть: " + lput_kop( kplu->stoim, .t. ) + ;
          ", врач: " + lstr( ret_tabn( kplu->kod_vr ) )
        add_string( s )
        Select KPLU
        Skip
      Enddo
      Select KPL
      Skip
    Enddo
    kpl->( dbCloseArea() )
    kplu->( dbCloseArea() )
  Endif
  usl->( dbCloseArea() )
  FClose( fp )
  rest_box( buf )
  Select ( tmp_select )
  If j == 0
    func_error( 4, "Не было ввода " + iif( nKey == K_F3, "квитанций", "чеков" ) + " по данному больному!" )
  Else
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  Return Nil

// 18.12.23
Function f_p_kart( nKey )

  Static st_n_kvit := 0
  Static st_tip_usl := 0
  Local buf := SaveScreen(), tmp_color := SetColor(), str_1, fl, ;
    colget_menu := "R/W", i, k, tmp_help := help_code, s_msg, ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    ret := -1
  Private is_mkb10 := .f., r1 := 11

  If mem_plsoput == 2
    --r1
  Endif
  is_mkb10 := .t.
  mywait()
  Private ;
    MKOD_DIAG   := Space( 6 ),; // шифр 1-ой осн.болезни
    MSOPUT_B1   := Space( 6 ),; // шифр 1-ой сопутствующей болезни
    MSOPUT_B2   := Space( 6 ),; // шифр 2-ой сопутствующей болезни
    MSOPUT_B3   := Space( 6 ),; // шифр 3-ой сопутствующей болезни
    MSOPUT_B4   := Space( 6 ),; // шифр 4-ой сопутствующей болезни
    MSOPUT_B5   := Space( 6 ),; // шифр 5-ой сопутствующей болезни
    MN_KVIT     := st_n_kvit,; // номер квитанционной книжки
    mkv_cia     := 0,;
    mdate_u1    := iif( glob_kassa == 1, sys_date, CToD( "" ) ), ;
    MLPU        := glob_uch[ 2 ],; // наименование учреждения
    M1LPU       := glob_uch[ 1 ],; // код учреждения
    MOTD        := glob_otd[ 2 ],; // наименование отделения
    M1OTD       := glob_otd[ 1 ],; // код отделения
    MN_DATA     := sys_date,; // дата начала лечения
    MK_DATA     := sys_date,; // дата окончания лечения
    mkod_vr     := 0,; // код направившего врача
    MCENA       := 0, ;                    // стоимость лечения
    mtabn_vr := 0, mvrach := Space( 35 ), ;
    mtip_usl, m1tip_usl := st_tip_usl, ;
    mpr_smo := Space( 10 ), m1pr_smo := 0, ;
    mpolis := Space( 25 ), ;
    mGP_NOMER := Space( 16 ), mGP_DATE := CToD( "" ), ;
    mGP2NOMER := Space( 16 ), mGP2DATE := CToD( "" ), ;
    mplat_fio := Space( 40 ), mplat_inn := Space( 12 ), ;
    mplat_adres := Space( 50 ), ; // адрес плательщика
    mplat_pasport := Space( 15 ), ;  // документ плательщика
    MKEMVYD, M1KEMVYD := 0, MKOGDAVYD := CToD( '' ) // кем и когда выдан паспорт ПЛАТЕЛЬЩИКА
  Private is_kassa := .t.
  If nKey == K_ENTER
    If human->is_kas == 1
      is_kassa := .f.
    Endif
    MKOD_DIAG   := human->KOD_DIAG      // шифр 1-ой осн.болезни
    MSOPUT_B1   := human->SOPUT_B1      // шифр 1-ой сопутствующей болезни
    MSOPUT_B2   := human->SOPUT_B2      // шифр 2-ой сопутствующей болезни
    MSOPUT_B3   := human->SOPUT_B3      // шифр 3-ой сопутствующей болезни
    MSOPUT_B4   := human->SOPUT_B4      // шифр 4-ой сопутствующей болезни
    MSOPUT_B5   := human->SOPUT_B5      // шифр 5-ой сопутствующей болезни
    MN_KVIT     := human->N_KVIT        // номер квитанционной книжки
    mkv_cia     := human->kv_cia
    mdate_u1    := c4tod( human->pdate )
    M1LPU       := human->LPU           // код учреждения
    M1OTD       := human->OTD           // код отделения
    MN_DATA     := human->N_DATA        // дата начала лечения
    MK_DATA     := human->K_DATA        // дата окончания лечения
    mkod_vr     := human->kod_vr
    MCENA       := human->CENA          // стоимость лечения
    m1tip_usl   := human->tip_usl
    If m1tip_usl == 0
      mplat_fio := human->plat_fio
      mplat_inn := human->plat_inn

    Else
      m1pr_smo := human->pr_smo
      mpolis := human->d_polis
      mGP_NOMER := human->GP_NOMER
      mGP_DATE  := human->GP_DATE
      mGP2NOMER := human->GP2NOMER
      mGP2DATE  := human->GP2DATE
    Endif
    If mkod_vr > 0
      Select PERSO
      Goto ( mkod_vr )
      mvrach := PadR( perso->fio, 35 )
      mtabn_vr := perso->tab_nom
    Endif
  Endif
  r_use( dir_server() + "hum_plat", dir_server() + "hum_plat", "KPLAT" )
  find ( Str( human->( RecNo() ), 7 ) )
  If Found()
    mplat_adres   := KPLAT->ADRES
    mplat_pasport := KPLAT->PASPORT
    m1kemvyd  := Kplat->kemvyd   // кем выдан документ ПЛАТЕЛЬЩИКА
    mkogdavyd := kplat->kogdavyd // когда выдан документ ПЛАТЕЛЬЩИКА
  Endif
  KPLAT->( dbCloseArea() )
  //
  mtip_usl := inieditspr( A__MENUVERT, menu_kb, m1tip_usl )
  mlpu := inieditspr( A__POPUPMENU, dir_server() + "mo_uch", m1lpu )
  motd := inieditspr( A__POPUPMENU, dir_server() + "mo_otd", m1otd )
  MKEMVYD := inieditspr( A__POPUPMENU, dir_server() + 's_kemvyd', M1KEMVYD )
  If m1tip_usl == PU_D_SMO
    mpr_smo := inieditspr( A__POPUPMENU, dir_server() + "p_d_smo", m1pr_smo )
  Elseif m1tip_usl == PU_PR_VZ
    mpr_smo := inieditspr( A__POPUPMENU, dir_server() + "p_pr_vz", m1pr_smo )
  Endif
  str_1 := " карточки лечения больного"
  If nKey == K_INS
    str_1 := "добавление" + str_1
  Else
    str_1 := "редактирование" + str_1
  Endif
  Private gl_area := { r1, 0, MaxRow() -1, MaxCol(), 0 }
  box_shadow( r1, 0, MaxRow() -1, MaxCol(), color1, "Платные услуги - " + str_1, color8 )
  status_key( "^<Esc>^ - выход;  ^<PgDn>^ - запись" )
  help_code := -1
  If nKey == K_INS .and. glob_pl_reg == 1
    mdate_u1 := sys_date
    MN_DATA  := CToD( "" )
    MK_DATA  := CToD( "" )
  Endif
  diag_screen( 0 )
  //
  Do While .t.
    SetColor( cDataCGet )
    @ r1 + 1, 1 Clear To MaxRow() -2, MaxCol() -1
    @ r1 + 2, 2 Say "ЛПУ" Get mlpu ;
      reader {| x| menu_reader( x, { {| k, r, c| ret_uch_otd( k, r, c, sys_date,, X_PLATN ) } }, A__FUNCTION,,, .f. ) }
    @ r1 + 2, 37 Say "Отделение" Get motd When .f.
    @ r1 + 3, 2 Say "Категория больного" Get mtip_usl ;
      reader {| x| menu_reader( x, menu_kb, A__MENUVERT,,, .f. ) } ;
      valid {| g, o| val_tip_usl( g, o ) } ;
      When is_kassa
    get1_p_kart()  // остальные Get'ы
    If nKey == K_ENTER .and. !ver_pub_date( mk_data, .t. )
      Keyboard Chr( K_ESC )
    Endif
    count_edit := myread(, @pos_read, ++k_read )
    If LastKey() != K_ESC
      err_date_diap( mn_data, "Дата начала лечения" )
      err_date_diap( mk_data, "Дата окончания лечения" )
      If glob_pl_reg == 1
        err_date_diap( mdate_u1, "Дата оплаты услуги" )
      Endif
      If f_esc_enter( 1 )
        If m1lpu == 0
          func_error( 4, "Не введено лечебное учреждение!" )
          Loop
        Endif
        If Empty( mk_data )
          func_error( 4, "Не введена дата окончания лечения." )
          Loop
        Endif
        // if empty(mkod_diag)
        // func_error(4,"Не введен шифр заболевания.")
        // loop
        // endif
        mywait()
        Select HUMAN
        If nKey == K_INS
          addrec( 7 )
          human->kod_k := glob_kartotek
          If glob_kassa == 1 .and. m1tip_usl == PU_PLAT  // если не взаимозачет
            human->is_kas := 2
          Endif
          fl_found := .t.
        Else
          g_rlock( forever )
        Endif
        st_n_kvit := mn_kvit
        human->KOD_DIAG := MKOD_DIAG       // шифр 1-ой осн.болезни
        human->SOPUT_B1 := MSOPUT_B1       // шифр 1-ой сопутствующей болезни
        human->SOPUT_B2 := MSOPUT_B2       // шифр 2-ой сопутствующей болезни
        human->SOPUT_B3 := MSOPUT_B3       // шифр 3-ой сопутствующей болезни
        human->SOPUT_B4 := MSOPUT_B4       // шифр 4-ой сопутствующей болезни
        human->SOPUT_B5 := MSOPUT_B5       // шифр 5-ой сопутствующей болезни
        human->N_KVIT   := MN_KVIT         // номер квитанционной книжки
        human->LPU      := M1LPU           // код учреждения
        human->OTD      := M1OTD           // код отделения
        human->N_DATA   := MN_DATA         // дата начала лечения
        human->K_DATA   := MK_DATA         // дата окончания лечения
        human->kod_vr   := mkod_vr
        human->kv_cia   := mkv_cia
        human->pdate    := dtoc4( mdate_u1 )
        human->tip_usl  := m1tip_usl
        If m1tip_usl == 0
          human->pr_smo := 0
          human->plat_fio := mplat_fio
          human->plat_inn := mplat_inn
        Else
          human->pr_smo := m1pr_smo
          human->d_polis := mpolis
          human->GP_NOMER := mGP_NOMER
          human->GP_DATE  := mGP_DATE
          human->GP2NOMER := mGP2NOMER
          human->GP2DATE  := mGP2DATE
          human->is_kas := 0
        Endif
        Unlock
        human->( dbCommit() )
        g_use( dir_server() + "hum_plat", dir_server() + "hum_plat", "KPLAT" )
        If Len( AllTrim( mplat_adres ) ) > 2 .or. Len( AllTrim( mplat_pasport ) ) > 2
          find ( Str( human->( RecNo() ), 7 ) )
          If !Found()
            Append Blank
          Else
            g_rlock( forever )
          Endif
          KPLAT->kod     := human->( RecNo() )
          KPLAT->ADRES   := mplat_adres
          KPLAT->PASPORT := mplat_pasport
          KPLAT->kemvyd := m1kemvyd     // кем выдан документ ПЛАТЕЛЬЩИКА
          KPLAT->kogdavyd := mkogdavyd  // когда выдан документ ПЛАТЕЛЬЩИКА
        Else
          find ( Str( human->( RecNo() ), 7 ) )
          If Found()
            deleterec( .t. )
          Endif
        Endif
        KPLAT->( dbCloseArea() )
        Select HUMAN
        st_tip_usl := m1tip_usl
        write_work_oper( glob_task, OPER_LIST, iif( nKey == K_INS, 1, 2 ), 1, count_edit )
        ret := 0
      Endif
    Endif
    If nKey == K_INS .and. !fl_found
      ret := 1
    Endif
    Exit
  Enddo
  Select HUMAN
  diag_screen( 2 )
  SetColor( tmp_color )
  RestScreen( buf )
  help_code := tmp_help
  Return ret

//
Function val_tip_usl( get, old )

  Local fl := .t.

  If m1tip_usl == 0
    m1pr_smo := 0 ; mpr_smo := Space( 10 )
  Endif
  If old != Nil .and. old != m1tip_usl
    m1pr_smo := 0 ; mpr_smo := Space( 10 )
    get1_p_kart()
  Endif
  Return fl



// 31.03.14
Function get1_p_kart()  // остальные Get'ы

  Local bg := {| o, k| get_mkb10( o, k ) }, j := r1 + 3,  pic_diag := "@K@!"

  ASize( GetList, 3 )   // берем первые 3 элемента
  @ j, 37 Clear To j, MaxCol() -1
  @ j + 1, 1 Clear To MaxRow() -2, MaxCol() -1
  If m1tip_usl == PU_D_SMO
    @ j, 37 Say "СМО" Get mpr_smo reader ;
      {| x| menu_reader( x, ;
      { dir_server() + "p_d_smo",,,,, color0, "Добровольные СМО", "B/BG" }, ;
      A__POPUPBASE1,,, .f. );
      }
    ++j
    @ j, 2 Say "Полис" Get mpolis Picture "@!@S20"
    @ j, Col() + 1 Say "Гарантийное письмо №" Get mGP_NOMER Picture "@!@S14"
    @ j, Col() + 1 Say "от" Get mGP_DATE
    ++j
    @ j, 29      Say "Гарантийное письмо №" Get mGP2NOMER Picture "@!@S14"
    @ j, Col() + 1 Say "от" Get mGP2DATE
  Elseif m1tip_usl == PU_PR_VZ
    @ j, 37 Say "Предприятие" Get mpr_smo reader ;
      {| x| menu_reader( x, ;
      { dir_server() + "p_pr_vz",,,,, color0, "Предприятия по взаимозачету", "B/BG" }, ;
      A__POPUPBASE1,,, .f. );
      }
    ++j
    @ j, 2 Say "Полис" Get mpolis Picture "@!@S20"
    @ j, Col() + 1 Say "Гарантийное письмо №" Get mGP_NOMER Picture "@!@S14"
    @ j, Col() + 1 Say "от" Get mGP_DATE
    ++j
    @ j, 29      Say "Гарантийное письмо №" Get mGP2NOMER Picture "@!@S14"
    @ j, Col() + 1 Say "от" Get mGP2DATE
  Endif
  ++j
  @ j, 2 Say "Шифр основного заболевания" Get mkod_diag ;
    Picture pic_diag reader {| o| mygetreader( o, bg ) } Valid val1_10diag( .t., .f., .f.,, ) ;
    When diag_screen( 2 ) .and. when_diag()
  If mem_plsoput == 2
    ++j
    @ j, 2 Say "Шифры сопуствующих заболеваний" Get msoput_b1;
      Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .f., .f.,, )
    @ Row(), Col() + 1 Say "," Get msoput_b2;
      Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .f., .f.,, )
    @ Row(), Col() + 1 Say "," Get msoput_b3;
      Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .f., .f.,, )
    @ Row(), Col() + 1 Say "," Get msoput_b4;
      Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .f., .f.,, )
    @ Row(), Col() + 1 Say "," Get msoput_b5;
      Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .f., .f.,, )
  Endif
  If mem_naprvr == 2
    ++j
    @ j, 2 Say "Таб.№ направившего врача" Get mtabn_vr Pict "99999" ;
      valid {| g| f5e_p_kusl( g, 2, 3 ) }
    @ Row(), Col() + 1 Get mvrach When .f. Color color14
  Endif
  If glob_pl_reg == 1
    ++j
    @ j, 2 Say "Номер квитанционной книжки" Get mn_kvit Pict "99999"
    ++j
    @ j, 2 Say "Номер квитанции" Get mkv_cia Pict "999999"
  Elseif glob_kassa == 1 .and. mek_kassa == 1 // 01.12.2008
    ++j
    @ j, 12 Say ""
  Elseif glob_kassa == 1 .and. mek_kassa == 2 // 01.12.2008
    ++j
    @ j, 2 Say "Номер квитанционной книжки" Get mn_kvit Pict "99999"
  Endif
  If glob_pl_reg == 1 .or. glob_kassa == 1
    @ Row(), Col() + 2 Say "Дата оплаты услуги" Get mdate_u1 ;
      valid {|| if( Empty( mn_data ), ( mn_data := mdate_u1 ), nil ), ;
      if( Empty( mk_data ), ( mk_data := mdate_u1 ), nil ), ;
      update_get() } ;
      When is_kassa
    ++j
    @ j, 2 Say "Дата начала лечения" Get mn_data // valid {|g|f_k_data(g,1)}
    @ Row(), Col() + 2 Say "Дата окончания лечения" Get mk_data // valid {|g|f_k_data(g,2)}
  Else
    ++j
    @ j, 2 Say "Дата начала лечения" Get mn_data valid {| g| f_k_data( g, 1 ) }
    ++j
    @ j, 2 Say "Дата окончания лечения" Get mk_data valid {| g| f_k_data( g, 2 ) }
  Endif
  If m1tip_usl == PU_PLAT
    ++j
    @ j, 2 Say "Плательщик: ФИО" Get mplat_fio
    @ j, Col() Say ", ИНН" Get mplat_inn
    ++j
    @ j, 2 Say "Адрес" Get mplat_adres Pict "@S45"
    @ j, Col() Say ", № док." Get mplat_pasport
    ++j
    @ j, 2 Say 'Выдано' Get mkogdavyd
    @ j, Col() Say ',' Get mkemvyd reader {| x| menu_reader( x, { {| k, r, c| get_s_kemvyd( k, r, c ) } }, A__FUNCTION, , , .f. ) }
  Endif
  ++j
  @ j, 50 Say "Стоимость лечения " + lstr( mcena, 11, 2 ) Color "GR+/B"
  Return Nil

//
Function f5e_p_kusl( get, when_valid, k )

  Local fl := .t., s, i, j, old_kod, mvar, amsg, arr_zf, ;
    msg1_err := "Код врача равен коду ассистента! Это недопустимо.", ;
    msg2_err := "Человека с таким кодом нет в базе данных персонала!", ;
    blk_sum := {|| mstoim := round_5( mu_cena * mkol, 2 ) }

  If when_valid == 1    // when
    If k == 2     // Шифр услуги
      If !Empty( mshifr )
        fl := .f.
      Endif
    Elseif k == 5 // Количество услуг
      If Empty( mshifr )
        fl := .f.
      Elseif mt_edit > 1
        fl := .f.
      Endif
    Elseif k == 7 // Общая стоимость услуги
      If Empty( mshifr )
        fl := .f.
      Endif
    Elseif k == 10  // код отделения
      SetKey( K_F3, {| p, l, v| get1_otd( p, l, v, get:Row, get:Col ) } )
      @ r1, 45 Say "<F3> - выбор отделения из меню" Color color13
    Endif
  Else                  // valid
    If k == 1     // Дата оказания услуги
      If !emptyany( human->n_data, mdate_u1 ) .and. mdate_u1 < human->n_data
        fl := func_error( 4, "Введенная дата меньше даты начала лечения!" )
      Elseif !emptyany( human->k_data, mdate_u1 ) .and. mdate_u1 > human->k_data
        fl := func_error( 4, "Введенная дата больше даты окончания лечения!" )
      Endif
      If is_zf_stomat == 1 .and. fl
        i := 0
        If !Empty( mkod_diag )
          ++i
        Endif
        If !Empty( mzf )
          ++i
        Endif
        If i > 0 // перепрыгнуть на ввод шифра услуги
          Keyboard Replicate( Chr( K_TAB ), i )
        Endif
      Endif
    Elseif k == 2 // Шифр услуги
      If !Empty( mshifr ) .and. !( mshifr == get:original )
        mshifr := transform_shifr( mshifr )
        Select USL
        Set Order To 1
        find ( mshifr )
        If Found()
          mu_kod := usl->kod
          mname_u := usl->name
          mis_nul := usl->is_nulp
          If mis_nul  // услуга с нулевой ценой
            mu_cena := 0 ; mt_edit := 1
          Else
            // берем цену для платных услуг
            mu_cena := if( smvzros_reb == 0, usl->pcena, usl->pcena_d )
            If human->tip_usl == PU_D_SMO .and. usl->dms_cena > 0
              mu_cena := usl->dms_cena
            Endif
          Endif
          mkol := 1
          Eval( blk_sum )
          update_gets()
          If is_zf_stomat == 1
            usl->( dbGoto( mu_kod ) ) // на всякий случай
            If !Empty( mzf ) .and. usl->zf == 0
              // n_message({"В данную услугу запрещен ввод зубной формулы!",;
              // "(Не будет записана)"},,"W/G","N/G",,,"GR/G")
            Endif
          Endif
        Elseif get_k_usluga( mshifr, smvzros_reb, @fl )
          box_shadow( r1 - 5, 40, r1 - 3, 77, cColorStMsg, ;
            "Комплексная услуга", cColorSt2Msg )
          @ r1 - 4, 41 Say PadC( "Количество услуг - " + lstr( Len( pr_k_usl ) ), 36 ) Color cColorStMsg
          mkol := 1
          If fl  // сменить код врача и ассистента
            mvrach := Space( 35 )
            mtabn_vr := 0
            If mkod_vr > 0
              Select PERSO
              Goto ( mkod_vr )
              If !Eof() .and. !Deleted()
                mvrach := PadR( perso->fio, 35 )
                mtabn_vr := perso->tab_nom
              Endif
            Endif
            massist := Space( 35 )
            mtabn_as := 0
            If mkod_as > 0
              Select PERSO
              Goto ( mkod_as )
              If !Eof() .and. !Deleted()
                massist := PadR( perso->fio, 35 )
                mtabn_as := perso->tab_nom
              Endif
            Endif
          Endif
          fl := update_gets()
        Else
          fl := func_error( 4, "Такого шифра нет в базе данных услуг." )
        Endif
      Endif
    Elseif k == 3 // Код врача
      old_kod := mkod_vr
      If Empty( mtabn_vr )
        mkod_vr := 0
        mvrach := Space( 35 )
      Else
        Select PERSO
        find ( Str( mtabn_vr, 5 ) )
        If Found()
          If Type( "mkod_as" ) == "N" .and. perso->kod == mkod_as
            fl := func_error( 4, msg1_err )
          Elseif mem_kat_va == 2 .and. perso->kateg != 1
            fl := func_error( 4, "Данный сотрудник не является ВРАЧОМ по штатному расписанию" )
          Else
            mkod_vr := perso->kod
            mvrach := PadR( perso->fio, 35 )
          Endif
        Else
          fl := func_error( 4, msg2_err )
        Endif
      Endif
      If old_kod != mkod_vr
        update_get( "mvrach" )
      Endif
    Elseif k == 4 // Код ассистента
      old_kod := mkod_as
      If Empty( mtabn_as )
        mkod_as := 0
        massist := Space( 35 )
      Else
        Select PERSO
        find ( Str( mtabn_as, 5 ) )
        If Found()
          If perso->kod == mkod_vr
            fl := func_error( 4, msg1_err )
          Elseif mem_kat_va == 2 .and. perso->kateg != 2
            fl := func_error( 4, "Данный сотрудник не является СРЕДНИМ МЕД.ПЕРСОНАЛОМ по штатному расписанию" )
          Else
            mkod_as := perso->kod
            massist := PadR( perso->fio, 35 )
          Endif
        Else
          fl := func_error( 4, msg2_err )
        Endif
      Endif
      If old_kod != mkod_as
        update_get( "massist" )
      Endif
    Elseif k == 5 // Количество услуг
      If mkol != get:original
        Eval( blk_sum )
        update_gets()
      Endif
    Elseif k == 6 // Коэффициент индексации услуги
      SetKey( K_F2, NIL )
      @ r1 + 8, 45 Say Space( 28 ) Color color13
      Eval( blk_sum )
      update_gets()
    Elseif k == 7 // Общая стоимость услуги
      If !( Round( mstoim, 2 ) == round_5( mu_cena * mkol, 2 ) )
        If mt_edit == 0
          mt_edit := 2
        Elseif mt_edit == 1
          mt_edit := 3
        Endif
        @ r1 + 8, 37 Say "[ редактировалась стоимость услуги ]" Color color13
      Endif
    Elseif k == 10  // код отделения
      If ( i := AScan( pr_arr, {| x| x[ 1 ] == m1otd } ) ) > 0
        motd := pr_arr[ i, 2 ] ; update_get( "motd" )
        SetKey( K_F3, NIL )
        @ r1, 45 Say Space( 30 ) Color color13
      Else
        fl := func_error( 4, "Данный код отделения не найден!" )
      Endif
    Elseif k == 11  // код медсестры
      mvar := &( ReadVar() )
      If mvar == 0
        mvar := "P" + ReadVar()
        &mvar := 0
      Elseif mvar != get:original
        Select MS
        find ( "1" + Str( mvar, 5 ) )
        If Found()
          mvar := "P" + ReadVar()
          &mvar := ms->( RecNo() )
        Else
          fl := func_error( 4, "Медсестра с данным кодом не найдена!" )
        Endif
      Endif
    Elseif k == 12  // код санитарки
      mvar := &( ReadVar() )
      If mvar == 0
        mvar := "P" + ReadVar()
        &mvar := 0
      Elseif mvar != get:original
        Select MS
        find ( "2" + Str( mvar, 5 ) )
        If Found()
          mvar := "P" + ReadVar()
          &mvar := ms->( RecNo() )
        Else
          fl := func_error( 4, "Санитарка с данным кодом не найдена!" )
        Endif
      Endif
    Elseif k == 101  // зубная формула
      If !Empty( mzf )
        amsg := {}
        If mu_kod > 0
          usl->( dbGoto( mu_kod ) )
          If usl->zf == 0
            AAdd( amsg, "В данную услугу запрещен ввод зубной формулы!" )
          Endif
        Endif
        arr_zf := stverifyzf( mzf, smdate_r, human->n_data, @amsg )
        If Len( arr_zf ) > 0
          If Empty( mkod_diag )
            AAdd( amsg, 'Не введен диагноз!' )
          Endif
          stverdelzub( human->kod_k, arr_zf, dtoc4( mdate_u1 ), 1, mrec_hu, @amsg )
          If Len( amsg ) > 0
            n_message( amsg,, "W/G", "N/G",,, "GR/G" )
          Endif
        Endif
      Endif
    Endif
    If !fl
      &( ReadVar() ) := get:original
    Elseif equalany( k, 3, 4 ) .and. mem_otdusl == 2 .and. Type( "pr1arr_otd" ) == "A"
      If ( old_kod := mkod_vr ) == 0
        old_kod := mkod_as
      Endif
      If old_kod > 0
        Select PERSO
        Goto ( old_kod )
        If iif( yes_many_uch, .t., perso->uch == glob_uch[ 1 ] ) .and. ;
            perso->otd > 0 .and. ;
            ( i := AScan( pr1arr_otd, {| x| x[ 1 ] == perso->otd } ) ) > 0
          m1otd := perso->otd ; motd := pr1arr_otd[ i, 2 ]
          update_get( "m1otd" ) ; update_get( "motd" )
        Else
          &( ReadVar() ) := get:original
          If iif( yes_many_uch, .t., perso->uch == glob_uch[ 1 ] )
            fl := func_error( 4, "Не проставлено отделение, в котором работает данный человек!" )
          Else
            fl := func_error( 4, "Данный человек работает в другом учреждении!" )
          Endif
        /*if (glob_otd := ret_1st_otd(glob_uch[1])) != NIL
          m1otd := glob_otd[1] ; motd := padr(glob_otd[2],30)
        endif*/
        Endif
      Endif
    Endif
  Endif
  Return fl

// 16.10.18
Function poisk_plat()

  Static sdate, sn_kvit := 0, skv1 := 0, skv2 := 0
  Local buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    j := 0, i, ;
    pr_kod_vr, pr_med1, pr_med2, pr_med3, pr_san1, pr_san2, pr_san3, ;
    adbf := { { "REC_HUM",   "N",     7,     0 }, ; // номер записи по БД hum_p
      { "FIO",   "C",    50,     0 }, ;
      { "OTD",   "N",     3,     0 }, ; // код отделения
      { "N_KVIT",   "N",     5,     0 }, ; // номер квитанционной книжки
      { "KV_CIA",   "N",     6,     0 }, ; // номер квитанции
      { "CENA",   "N",    10,     2 }, ; // стоимость лечения
      { "DATA",   "D",     8,     0 }, ; // дата
      { "FL_DATA",   "L",     1,     0 }, ; // флаг равенства дат
      { "kod_vr",   "N",     5,     0 }, ; // код врача
      { "med1",   "N",     5,     0 }, ; // код медсестры
      { "med2",   "N",     5,     0 }, ; // код медсестры
      { "med3",   "N",     5,     0 }, ; // код медсестры
      { "san1",   "N",     5,     0 }, ; // код санитарки
      { "san2",   "N",     5,     0 }, ; // код санитарки
      { "san3",   "N",     5,     0 }, ; // код санитарки
      { "FL_EDIT","L",     1,     0 } }  // флаг редактирования
  Default sdate To sys_date
  If glob_kassa == 1 .and. mek_kassa == 1
    Private drvFR
    If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
      //
    Else
      Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
    Endif
  Endif
  Private mdate := sdate, mn_kvit := sn_kvit, mkv1 := skv1, mkv2 := skv2, ;
    gl_area := { 12, 0, 23, 79, 0 }
  box_shadow( 13, 2, 22, 77,, "Ввод данных для выборки информации", color8 )
  @ 15, 4 Say "Дата окончания лечения" Get mdate Valid !Empty( mdate )
  @ 16, 4 Say "Номер квитанционной книжки" Get mn_kvit Pict "99999"
  If glob_pl_reg == 1
    @ 17, 5 Say "Начальный номер квитанции" Get mkv1 Pict "999999"
    @ 18, 5 Say "Конечный  номер квитанции" Get mkv2 Pict "999999"
  Endif
  status_key( "^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода" )
  myread()
  If LastKey() != K_ESC .and. ver_pub_date( mdate, .t. ) .and. f_esc_enter( "ввода" )
    sdate := mdate ; sn_kvit := mn_kvit ; skv1 := mkv1 ; skv2 := mkv2
    mywait()
    dbCreate( cur_dir() + "tmp", adbf )
    Use ( cur_dir() + "tmp" ) new
    g_use( dir_server() + "plat_ms", dir_server() + "plat_ms", "MS" )
    g_use( dir_server() + "kartotek",, "KART" )
    g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
    g_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUMAN" )
    find ( DToS( mdate ) )
    Do While human->k_data == mdate .and. !Eof()
      fl := .t.
      If fl .and. mn_kvit > 0
        fl := ( mn_kvit == human->n_kvit )
      Endif
      If fl .and. mkv1 > 0
        fl := ( mkv1 <= human->kv_cia )
      Endif
      If fl .and. mkv2 > 0
        fl := ( human->kv_cia <= mkv2 )
      Endif
      If fl
        fld := ( human->n_data == human->k_data )
        If fld .and. glob_pl_reg == 1
          fld := ( human->k_data == c4tod( human->pdate ) )
        Endif
        Select HU
        find ( Str( human->( RecNo() ), 7 ) )
        pr_kod_vr := hu->kod_vr
        pr_med1   := hu->med1
        pr_med2   := hu->med2
        pr_med3   := hu->med3
        pr_san1   := hu->san1
        pr_san2   := hu->san2
        pr_san3   := hu->san3
        Do While hu->kod == human->( RecNo() )
          If fld
            fld := ( human->pdate == hu->date_u )
          Endif
          If pr_kod_vr != hu->kod_vr ; pr_kod_vr := 0 ; Endif
          If pr_med1 != hu->med1     ; pr_med1   := 0 ; Endif
          If pr_med2 != hu->med2     ; pr_med2   := 0 ; Endif
          If pr_med3 != hu->med3     ; pr_med3   := 0 ; Endif
          If pr_san1 != hu->san1     ; pr_san1   := 0 ; Endif
          If pr_san2 != hu->san2     ; pr_san2   := 0 ; Endif
          If pr_san3 != hu->san3     ; pr_san3   := 0 ; Endif
          Skip
        Enddo
        //
        Select MS
        If pr_med1 > 0
          Goto ( pr_med1 )
          If !Eof() .and. ms->tip == 1
            pr_med1 := ms->tab_nom
          Endif
        Endif
        If pr_med2 > 0
          Goto ( pr_med2 )
          If !Eof() .and. ms->tip == 1
            pr_med2 := ms->tab_nom
          Endif
        Endif
        If pr_med3 > 0
          Goto ( pr_med3 )
          If !Eof() .and. ms->tip == 1
            pr_med3 := ms->tab_nom
          Endif
        Endif
        If pr_san1 > 0
          Goto ( pr_san1 )
          If !Eof() .and. ms->tip == 2
            pr_san1 := ms->tab_nom
          Endif
        Endif
        If pr_san2 > 0
          Goto ( pr_san2 )
          If !Eof() .and. ms->tip == 2
            pr_san2 := ms->tab_nom
          Endif
        Endif
        If pr_san3 > 0
          Goto ( pr_san3 )
          If !Eof() .and. ms->tip == 2
            pr_san3 := ms->tab_nom
          Endif
        Endif
        //
        Select KART
        Goto ( human->kod_k )
        Select TMP
        Append Blank
        tmp->REC_HUM := human->( RecNo() )
        tmp->OTD := human->otd
        tmp->FIO := kart->fio
        tmp->N_KVIT := human->n_kvit
        tmp->KV_CIA := human->kv_cia
        tmp->CENA := human->cena
        tmp->DATA := human->k_data
        tmp->fl_data := fld  // одинаковая ли дата ?
        tmp->kod_vr := pr_kod_vr
        tmp->med1   := pr_med1
        tmp->med2   := pr_med2
        tmp->med3   := pr_med3
        tmp->san1   := pr_san1
        tmp->san2   := pr_san2
        tmp->san3   := pr_san3
      Endif
      Select HUMAN
      Skip
    Enddo
    If ( j := tmp->( LastRec() ) ) > 0
      Select TMP
      Sort On n_kvit, kv_cia to ( cur_dir() + "tmp1" )
    Endif
    Close databases
    If j == 0
      func_error( 4, "Не найдено листов учета по данному запросу!" )
    Endif
  Endif
  RestScreen( buf ) ; SetColor( tmp_color )
  If j > 0
    r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
    use_base( "hum_p", "HUMAN" )
    Set Order To 0
    Use ( cur_dir() + "tmp1" ) New Alias TMP
    Go Top
    box_shadow( MaxRow() -4, 2, MaxRow() -2, 77, "W/B" )
    alpha_browse( T_ROW, 0, MaxRow() -6, 79, "f1_po_plat", color0,,, ;
      .f., .t.,, "f2_po_plat", "f3_po_plat",, ;
      { "═", "░", "═", "N/BG,W+/N,B/BG,BG+/B,RB/BG,W+/RB", .t., 180 } )
    Close databases
  Endif
  RestScreen( buf )
  Return Nil

// 05.10.17
Function f1_po_plat( oBrow )

  Local oColumn, blk := {|| iif( tmp->fl_edit, { 5, 6 }, iif( tmp->fl_data, { 1, 2 }, { 3, 4 } ) ) }

  //
  oColumn := TBColumnNew( "№ кв.;книжк", {|| tmp->n_kvit } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "№ кви-;танции", {|| tmp->kv_cia } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Отд", {|| tmp->otd } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "  Дата; оплаты", {|| date_8( tmp->data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Ст-сть; лечения", {|| umest_val( tmp->cena, 8, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Врач", {|| put_val( ret_tabn( tmp->kod_vr ), 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " М/c;  1", {|| put_val( tmp->med1, 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " М/c;  2", {|| put_val( tmp->med2, 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " М/c;  3", {|| put_val( tmp->med3, 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " Сан.;  1", {|| put_val( tmp->san1, 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " Сан.;  2", {|| put_val( tmp->san2, 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " Сан.;  3", {|| put_val( tmp->san3, 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " ", {|| iif( tmp->fl_edit, "", " " ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  status_key( "^<Esc>^ - выход;  ^<Enter>^ - редактирование;  ^<Ctrl+Enter>^ - редактирование услуг" )
  Return Nil

//
Function f2_po_plat()

  @ MaxRow() -3, 4 Say tmp->fio Color color1

  Return Nil

// 05.10.17
Function f3_po_plat( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), buf1, fl := .f., rec, mkod, ;
    rec1, llpu, tmp_color := SetColor(), r, str_sem, is_ed_date

  If nKey == K_ENTER .or. nKey == K_CTRL_RET
    rec1 := tmp->( RecNo() )
    human->( dbGoto( tmp->rec_hum ) )
    rec := human->( RecNo() )
    llpu := human->lpu
    glob_kartotek := human->kod_k
    glob_k_fio := tmp->fio
    str_sem := "ПУ Редактирование человека " + lstr( glob_kartotek )
    If !g_slock( str_sem )
      func_error( 4, err_slock() )
      Return flag
    Endif
    If nKey == K_ENTER
      Private pr_arr := {}
      r_use( dir_server() + "mo_otd",, "OTD" )
      dbEval( {|| AAdd( pr_arr, { otd->( RecNo() ), otd->name } ) }, ;
        {|| otd->kod_lpu == human->lpu .and. between_date( otd->DBEGINP, otd->DENDP, tmp->data ) } )
      ASort( pr_arr,,, {| x, y| x[ 2 ] < y[ 2 ] } )
      r_use( dir_server() + "plat_ms", dir_server() + "plat_ms", "MS" )
      r := T_ROW + 3 + oBrow:rowPos
      Private mn_kvit := tmp->n_kvit, ;
        mkv_cia := tmp->kv_cia, ;
        motd := tmp->otd, ;
        mdate := tmp->data, ;
        mkod_vr := tmp->kod_vr, mtabn_vr := 0, ;
        pmmed1 := 0, mmed1 := tmp->med1, ;
        pmmed2 := 0, mmed2 := tmp->med2, ;
        pmmed3 := 0, mmed3 := tmp->med3, ;
        pmsan1 := 0, msan1 := tmp->san1, ;
        pmsan2 := 0, msan2 := tmp->san2, ;
        pmsan3 := 0, msan3 := tmp->san3
      If mkod_vr > 0
        mtabn_vr := ret_tabn( mkod_vr )
      Endif
      Select MS
      If mmed1 > 0
        find ( "1" + Str( mmed1, 5 ) )
        If Found()
          pmmed1 := ms->( RecNo() )
        Endif
      Endif
      If mmed2 > 0
        find ( "1" + Str( mmed2, 5 ) )
        If Found()
          pmmed2 := ms->( RecNo() )
        Endif
      Endif
      If mmed3 > 0
        find ( "1" + Str( mmed3, 5 ) )
        If Found()
          pmmed3 := ms->( RecNo() )
        Endif
      Endif
      If msan1 > 0
        find ( "2" + Str( msan1, 5 ) )
        If Found()
          pmsan1 := ms->( RecNo() )
        Endif
      Endif
      If msan2 > 0
        find ( "2" + Str( msan2, 5 ) )
        If Found()
          pmsan2 := ms->( RecNo() )
        Endif
      Endif
      If msan3 > 0
        find ( "2" + Str( msan3, 5 ) )
        If Found()
          pmsan3 := ms->( RecNo() )
        Endif
      Endif
      SetColor( cDataCGet )
      status_key( "^<Esc>^ - выход;  ^<PgDn>^ - запись" )
      Do While .t.
        @ r, 1 Get mn_kvit Pict "99999"
        If glob_pl_reg == 1
          @ r, 7 Get mkv_cia Pict "999999"
        Endif
        @ r, 14 Get motd valid {| g| val_pl_otd( g ) }
        If tmp->fl_data
          @ r, 17 Get mdate
        Endif
        If mkod_vr > 0
          @ r, 36 Get mtabn_vr Pict "99999" valid {| g| f5e_p_kusl( g, 2, 3 ) }
        Endif
        If mmed1 > 0
          @ r, 42 Get mmed1 Pict "99999" valid {| g| f5e_p_kusl( g, 2, 11 ) }
        Endif
        If mmed2 > 0
          @ r, 48 Get mmed2 Pict "99999" valid {| g| f5e_p_kusl( g, 2, 11 ) }
        Endif
        If mmed3 > 0
          @ r, 54 Get mmed3 Pict "99999" valid {| g| f5e_p_kusl( g, 2, 11 ) }
        Endif
        If msan1 > 0
          @ r, 60 Get msan1 Pict "99999" valid {| g| f5e_p_kusl( g, 2, 12 ) }
        Endif
        If msan2 > 0
          @ r, 66 Get msan2 Pict "99999" valid {| g| f5e_p_kusl( g, 2, 12 ) }
        Endif
        If msan3 > 0
          @ r, 72 Get msan3 Pict "99999" valid {| g| f5e_p_kusl( g, 2, 12 ) }
        Endif
        myread()
        If LastKey() != K_ESC .and. f_esc_enter( 1 )
          mywait()
          tmp->fl_edit := .t.
          Select HUMAN
          g_rlock( forever )
          If human->n_kvit != mn_kvit
            human->n_kvit := mn_kvit
            tmp->n_kvit := mn_kvit
          Endif
          If glob_pl_reg == 1 .and. human->kv_cia != mkv_cia
            human->kv_cia := mkv_cia
            tmp->kv_cia := mkv_cia
          Endif
          If human->otd != motd
            human->otd := motd
            tmp->otd := motd
          Endif
          is_ed_date := .f.
          If tmp->fl_data .and. human->n_data != mdate
            human->n_data := mdate
            human->k_data := mdate
            human->pdate  := dtoc4( mdate )
            tmp->data     := mdate
            is_ed_date := .t.
          Endif
          Unlock
          g_use( dir_server() + "hum_p_u", { dir_server() + "hum_p_u", ;
            dir_server() + "hum_p_uk", ;
            dir_server() + "hum_p_ud", ;
            dir_server() + "hum_p_uv", ;
            dir_server() + "hum_p_ua" }, "HU" )
          find ( Str( rec, 7 ) )
          Do While hu->kod == rec
            g_rlock( forever )
            If is_ed_date
              hu->date_u := dtoc4( mdate )
            Endif
            If mkod_vr > 0 .and. mkod_vr != hu->kod_vr
              hu->kod_vr := mkod_vr
              tmp->kod_vr := mtabn_vr
            Endif
            If pmmed1 > 0 .and. pmmed1 != hu->med1
              hu->med1 := pmmed1
              tmp->med1 := mmed1
            Endif
            If pmmed2 > 0 .and. pmmed2 != hu->med2
              hu->med2 := pmmed2
              tmp->med2 := mmed2
            Endif
            If pmmed3 > 0 .and. pmmed3 != hu->med3
              hu->med3 := pmmed3
              tmp->med3 := mmed3
            Endif
            If pmsan1 > 0 .and. pmsan1 != hu->san1
              hu->san1 := pmsan1
              tmp->san1 := msan1
            Endif
            If pmsan2 > 0 .and. pmsan2 != hu->san2
              hu->san2 := pmsan2
              tmp->san2 := msan2
            Endif
            If pmsan3 > 0 .and. pmsan3 != hu->san3
              hu->san3 := pmsan3
              tmp->san3 := msan3
            Endif
            Unlock
            Skip
          Enddo
        Endif
        Exit
      Enddo
      Close databases
    Elseif nKey == K_CTRL_RET
      Close databases
      usl_p_kart( rec, llpu )
    Endif
    r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
    use_base( "hum_p", "HUMAN" )
    Set Order To 0
    Goto ( rec )
    Use ( cur_dir() + "tmp1" ) New Alias TMP
    Goto ( rec1 )
    tmp->cena := human->cena
    SetColor( tmp_color )
    rest_box( buf ) ; flag := 0
    g_sunlock( str_sem )
  Else
    Keyboard ""
  Endif
  Return flag

//
Function val_pl_otd( get )

  Local i, fl := .t.

  If ( i := AScan( pr_arr, {| x| x[ 1 ] == motd } ) ) == 0
    fl := func_error( 4, "Данный код отделения не найден!" )
    motd := get:original
  Endif
  Return fl

//
Function close_lu( k )

  Static si1 := 2, si2 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    If !currentuser():isadmin()
      Return func_error( 4, err_admin() )
    Endif
    mas_pmt := { "Закрыть л/учета для ~одного больного", ;
      "Закрыть л/учета для ~всех", ;
      "~Убрать у больного отметку о закрытии л/учета" }
    mas_msg := { "Закрыть лист учета для одного больного", ;
      "Закрыть листы учета для всех", ;
      "Убрать у больного отметку о закрытии листа учета" }
    mas_fun := { "close_lu(11)", ;
      "close_lu(12)", ;
      "close_lu(13)" }
    popup_prompt( T_ROW, T_COL + 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    f1close_lu( 1 )
  Case k == 12
    f1close_lu( 2 )
  Case k == 13
    f1close_lu( 3 )
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Endif
  Endif
  Return Nil

//
Function f1close_lu( par )

  Local buf, str_sem
  Private atip_usl, mtitle, p_regim := par, mdate, arr_m

  If ( atip_usl := f_p_tip_usl() ) == NIL
    Return Nil
  Endif
  Private str_find := Str( atip_usl[ 2 ], 1 ), ;
    muslovie := "hu->tip_usl==" + lstr( atip_usl[ 2 ] )
  Do Case
  Case par == 1  // Закрыть лист учета для одного больного
    str_find += "0"
    muslovie += " .and. empty(date_close)"
  Case par == 2  // Закрыть листы учета для всех
    str_find += "0"
    muslovie += " .and. empty(date_close)"
  Case par == 3  // Убрать у больного отметку о закрытии листа учета
    str_find += "1"
    muslovie += " .and. !empty(date_close)"
  Endcase
  muslovie += " .and. !eof()"
  str_sem := "ПУ Закрытие листа учета"
  If !g_slock( str_sem )
    Return func_error( 4, err_slock() )
  Endif
  Do Case
  Case par == 1  // Закрыть лист учета для одного больного
    f2close_lu()
  Case par == 2  // Закрыть листы учета для всех
    If atip_usl[ 2 ] == PU_D_SMO .and. glob_close == 0  // по оплате
      If f_esc_enter( "закрытия л/учета по ДМС" )
        f1closedms()
      Endif
    Else  // вручную
      mdate := input_value( 20, 2, 22, 77, "GR+/R,W+/N", ;
        Space( 10 ) + "Введите максимальную дату окончания лечения", ;
        sys_date )
      If mdate != NIL
        f2close_lu()
      Endif
    Endif
  Case par == 3  // Убрать у больного отметку о закрытии листа учета
    If ( arr_m := year_month( T_ROW, T_COL + 5 ) ) != NIL
      f2close_lu()
    Endif
  Endcase
  Close databases
  g_sunlock( str_sem )
  Return Nil

//
Function f2close_lu()

  Local buf := SaveScreen(), j, fl

  mywait()
  dbCreate( cur_dir() + "tmp", { { "rec", "N", 7, 0 }, ;
    { "is", "N", 1, 0 } } )
  Use ( cur_dir() + "tmp" ) new
  g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HUP" )
  g_use( dir_server() + "hum_p", dir_server() + "hum_pc", "HU" )
  find ( str_find )
  Do while &muslovie
    fl := .t.
    If p_regim == 2
      fl := ( hu->k_data <= mdate )
    Elseif p_regim == 3
      fl := Between( hu->date_close, arr_m[ 5 ], arr_m[ 6 ] )
    Endif
    If fl
      Select TMP
      Append Blank
      tmp->rec := hu->( RecNo() )
      If hu->cena > 0 .and. p_regim == 2
        tmp->is := 1
        Select HUP
        find ( Str( hu->( RecNo() ), 7 ) )
        Do While hup->kod == hu->( RecNo() )
          If emptyall( hup->kod_vr, hup->kod_as )
            fl := .f. ; Exit
          Endif
          Skip
        Enddo
        If !fl
          tmp->is := 0
        Endif
      Endif
      If tmp->( LastRec() ) % 5000 == 0
        Commit
      Endif
    Endif
    Select HU
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  RestScreen( buf )
  If j == 0
    If p_regim == 3
      Return func_error( 4, "Для данной категории больных нет закрытых листов учета!" )
    Else
      Return func_error( 4, "Для данной категории больных закрыты все листы учета!" )
    Endif
  Else
    If p_regim == 3
      mtitle := 'З'
    Else
      mtitle := 'Нез'
    Endif
    mtitle += 'акрытые л/учета: "' + AllTrim( atip_usl[ 1 ] ) + '"'
    If p_regim == 2
      mtitle += ' [по ' + full_date( mdate ) + 'г.]'
    Elseif p_regim == 3
      mtitle += ' [' + arr_m[ 4 ] + ']'
    Endif
    g_use( dir_server() + "kartotek",, "KART" )
    g_use( dir_server() + "hum_p",, "HU" )
    Set Relation To kod_k into KART
    Use ( cur_dir() + "tmp" ) new
    Set Relation To rec into HU
    Index On Upper( kart->fio ) + Str( hu->kod_k, 7 ) + DToS( hu->k_data ) to ( cur_dir() + "tmp" )
    Go Top
    fl := .f.
    If alpha_browse( 2, 1, MaxRow() -2, 78, "f2_k_close", color0, mtitle, "BG+/GR", ;
        .t., .t.,,, "f3_k_close",, ;
        {,,, "N/BG,W+/N,B/BG,BG+/B,R/BG,GR+/R", .f., 180 } )
      Private pkol := 0, psumma := 0
      kart->( dbCloseArea() )
      Select TMP
      Set Relation To
      If p_regim > 1
        Go Top
        Do While !Eof()
          If tmp->is == 1
            ++pkol
            psumma += hu->cena
          Endif
          Skip
        Enddo
        box_shadow( 18, 2, 18, 77, "W+/R", "Отмечено " + lstr( pkol ) + ;
          " чел. на сумму " + lput_kop( psumma, .t. ) + " руб.",, 0 )
      Endif
      Select HU
      Set Index to ( dir_server() + "hum_pc" )
      Set Order To 0
      Do Case
      Case p_regim == 1
        If atip_usl[ 2 ] == PU_D_SMO .and. glob_close == 0
          func_error( 4, "Для данной категории больных закрывайте все листы учета!" )
        Else
          mdate := input_value( 20, 2, 22, 77, "GR+/R,W+/N", ;
            Space( 15 ) + "Введите дату закрытия листа учета", ;
            sys_date )
          If mdate != Nil .and. f_esc_enter( "закрытия листа учета" )
            fl := .t.
            Select HU
            dbGoto( tmp->rec )
            g_rlock( forever )
            hu->date_close := mdate
            Unlock
          Endif
        Endif
      Case p_regim == 2
        If pkol == 0
          func_error( 4, " " )
        Else
          mdate := input_value( 20, 2, 22, 77, "GR+/R,W+/N", ;
            Space( 15 ) + "Введите дату закрытия листов учета", ;
            sys_date )
          If mdate != Nil .and. f_esc_enter( "закрытия листов учета" )
            fl := .t.
            mywait()
            Select TMP
            Go Top
            Do While !Eof()
              If tmp->is == 1
                Select HU
                dbGoto( tmp->rec )
                g_rlock( forever )
                hu->date_close := mdate
                Unlock
              Endif
              Select TMP
              Skip
            Enddo
          Endif
        Endif
      Case p_regim == 3
        If pkol == 0
          func_error( 4, " " )
        Elseif f_esc_enter( "снятия признака закрытия", .t. )
          fl := .t.
          mywait()
          Select TMP
          Go Top
          Do While !Eof()
            If tmp->is == 1
              Select HU
              dbGoto( tmp->rec )
              g_rlock( forever )
              hu->date_close := CToD( "" )
              Unlock
            Endif
            Select TMP
            Skip
          Enddo
        Endif
      Endcase
    Endif
    Close databases
    If fl
      stat_msg( "Операция завершена!" ) ; mybell( 2, OK )
    Endif
    RestScreen( buf )
  Endif
  Return Nil

//
Function f2_k_close( oBrow )

  Local oColumn, n := 37, s, blk := {|| iif( hu->cena > 0, { 1, 2 }, { 5, 6 } ) }

  If p_regim > 1
    n -= 2
    blk := {|| iif( tmp->is == 1, { 1, 2 }, iif( hu->cena > 0, { 3, 4 }, { 5, 6 } ) ) }
    oColumn := TBColumnNew( " ", {|| iif( tmp->is == 1, Chr( 16 ), " " ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
  Endif
  oColumn := TBColumnNew( Center( "Ф.И.О.", n ), {|| PadR( kart->fio, n ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " Начало; лечения", {|| date_8( hu->n_data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Окончан.;лечения", {|| date_8( hu->k_data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Стоимость; лечения", {|| put_kop( hu->cena, 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  s := "^<Esc>^ выход ^<F9>^ печать "
  Do Case
  Case p_regim == 1
    s += "^<Enter>^ закрыть л/учета"
  Case p_regim > 1
    s += "^<Enter>^ подтверждение ^<Ins,+,->^ отметка"
  Endcase
  s += " ^<F3>^ просмотр"
  status_key( s )
  Return Nil

//
Function f3_k_close( nKey, oBrow )

  Local j := 0, ret := -1, buf := save_row( MaxRow() ), buf1, fl := .f., tmp_rec, ;
    tmp_color := SetColor(), j1, ;
    n_file := cur_dir() + "_close.txt", sh := 80, HH := 60, reg_print := 2

  Do Case
  Case nKey == K_F3
    mywait()
    fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
    arr_title := { ;
      "─────┬──────────┬────────────────────────────────────┬─────┬─────┬────┬─────────", ;
      "Дата │   Шифр   │       Наименование услуги          │ Врач│ Асс.│Кол.│Стоимость", ;
      "─────┴──────────┴────────────────────────────────────┴─────┴─────┴────┴─────────" }
    add_string( "" )
    add_string( "ФИО: " + kart->fio )
    add_string( "Срок лечения: " + full_date( hu->n_data ) + "-" + full_date( hu->k_data ) )
    AEval( arr_title, {| x| add_string( x ) } )
    r_use( dir_server() + "mo_pers",, "PERSO" )
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HUP" )
    Set Relation To u_kod into USL
    find ( Str( hu->( RecNo() ), 7 ) )
    Index On hup->date_u + fsort_usl( usl->shifr ) to ( cur_dir() + "tmp_hup" ) ;
      While hup->kod == hu->( RecNo() )
    Go Top
    Do While !Eof()
      s := Left( full_date( c4tod( hup->date_u ) ), 5 ) + " " + ;
        usl->shifr + " " + Left( usl->name, 36 ) + " "
      s += put_val( ret_tabn( hup->kod_vr ), 5 ) + " " + ;
        put_val( ret_tabn( hup->kod_as ), 5 )
      s += Str( hup->kol, 5 )
      s += put_kop( hup->stoim, 10 )
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( s )
      If emptyall( hup->kod_vr, hup->kod_as )
        add_string( Center( Replicate( "~", sh - 10 ), sh ) )
      Endif
      Skip
    Enddo
    add_string( Replicate( "─", sh ) )
    add_string( put_kop( hu->cena, sh ) )
    hup->( dbCloseArea() )
    usl->( dbCloseArea() )
    FClose( fp )
    rest_box( buf )
    viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
    Select TMP
  Case eq_any( nKey, 43, 45, K_INS ) .and. equalany( p_regim, 2, 3 )
    Do Case
    Case nKey == 45  // минус
      tmp_rec := tmp->( RecNo() )
      tmp->( dbEval( {|| tmp->is := 0 } ) )
      tmp->( dbGoto( tmp_rec ) )
      ret := 0
    Case nKey == 43  // плюс
      tmp_rec := tmp->( RecNo() )
      tmp->( dbEval( {|| tmp->is := 1 } ) )
      tmp->( dbGoto( tmp_rec ) )
      ret := 0
    Case nKey == K_INS
      tmp->is := iif( tmp->is == 1, 0, 1 )
      oBrow:down()
      ret := 0
    Endcase
  Case nKey == K_F9
    tmp_rec := tmp->( RecNo() )
    If ( j := f_alert( { "Выберите порядок сортировки листов учета в выходном документе" }, ;
        { " По ~ФИО больного ", " По ~дате окончания лечения " }, ;
        1, "W/RB", "G+/RB", 20,, "BG+/RB,W+/R,W+/RB,GR+/R" ) ) == 0
      Return ret
    Endif
    fl := .t.
    Do Case
    Case p_regim == 1 // Закрыть лист учета для одного больного
      j1 := 1
      mtitle2 := ""
    Case p_regim == 2 // Закрыть листы учета для всех
      j1 := f_alert( { "Выберите содержание выходного документа" }, ;
        { " ~Весь список ", " ~Отмеченные больные " }, ;
        2, "W/RB", "G+/RB", 20,, "BG+/RB,W+/R,W+/RB,GR+/R" )
      If ( fl := ( j1 > 0 ) )
        mtitle2 := iif( j1 == 1, "", "[больные, отмеченные для закрытия листа учета]" )
      Endif
    Case p_regim == 3 // Убрать у больного отметку о закрытии листа учета
      j1 := f_alert( { "Выберите содержание выходного документа" }, ;
        { " ~Весь список ", " ~Отмеченные больные " }, ;
        1, "W/RB", "G+/RB", 20,, "BG+/RB,W+/R,W+/RB,GR+/R" )
      If ( fl := ( j1 > 0 ) )
        mtitle2 := iif( j1 == 1, "", "[больные, отмеченные для снятия признака закрытия листа учета]" )
      Endif
    Endcase
    If fl
      arr_title := { ;
        "────────────────────────────────────────────────┬──────────┬──────────┬─────────", ;
        "                     Ф.И.О.                     │  Начало  │ Окончание│Стоимость", ;
        "                                                │  лечения │  лечения │ лечения ", ;
        "────────────────────────────────────────────────┴──────────┴──────────┴─────────" }
      If atip_usl[ 2 ] == PU_PLAT
        mywait()
        Select TMP
        If j == 1
          Index On Upper( kart->fio ) + Str( hu->kod_k, 7 ) + DToS( hu->k_data ) to ( cur_dir() + "tmp" )
        Else
          Index On DToS( hu->k_data ) + Upper( kart->fio ) to ( cur_dir() + "tmp" )
        Endif
        fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
        add_string( Center( mtitle, sh ) )
        add_string( Center( mtitle2, sh ) )
        add_string( "" )
        AEval( arr_title, {| x| add_string( x ) } )
        j := 0
        Go Top
        Do While !Eof()
          If iif( j1 == 1, .t., tmp->is == 1 )
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( PadR( lstr( ++j ) + ". " + kart->fio, 48 ) + " " + ;
              full_date( hu->n_data ) + " " + ;
              full_date( hu->k_data ) + ;
              put_kop( hu->cena, 10 ) )
          Endif
          Select TMP
          Skip
        Enddo
        FClose( fp )
        Close databases
        viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
      Elseif atip_usl[ 2 ] == PU_PR_VZ .or. atip_usl[ 2 ] == PU_D_SMO
        mywait()
        If atip_usl[ 2 ] == PU_D_SMO
          g_use( dir_server() + "p_d_smo",, "DMS" )
        Else
          g_use( dir_server() + "p_pr_vz",, "DMS" )
        Endif
        Select HU
        Set Relation To kod_k into KART, To pr_smo into DMS
        Select TMP
        If j == 1
          Index On Upper( dms->name ) + Upper( kart->fio ) + DToS( hu->k_data ) to ( cur_dir() + "tmp" )
        Else
          Index On Upper( dms->name ) + DToS( hu->k_data ) + Upper( kart->fio ) to ( cur_dir() + "tmp" )
        Endif
        fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
        add_string( Center( mtitle, sh ) )
        add_string( Center( mtitle2, sh ) )
        AEval( arr_title, {| x| add_string( x ) } )
        old_dms := -1 ; j := 0
        Go Top
        Do While !Eof()
          If iif( j1 == 1, .t., tmp->is == 1 )
            If old_dms != hu->pr_smo
              If verify_ff( HH - 4, .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              add_string( "" )
              add_string( Center( AllTrim( Upper( dms->name ) ), sh ) )
              add_string( Replicate( "=", sh ) )
              j := 0
            Endif
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( PadR( lstr( ++j ) + ". " + kart->fio, 48 ) + " " + ;
              full_date( hu->n_data ) + " " + ;
              full_date( hu->k_data ) + ;
              put_kop( hu->cena, 10 ) )
            old_dms := hu->pr_smo
          Endif
          Select TMP
          Skip
        Enddo
        FClose( fp )
        Close databases
        viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
      Endif
    Endif
    Close databases
    g_use( dir_server() + "kartotek",, "KART" )
    g_use( dir_server() + "hum_p",, "HU" )
    Set Relation To kod_k into KART
    Use ( cur_dir() + "tmp" ) new
    Set Relation To rec into HU
    Index On Upper( kart->fio ) + Str( hu->kod_k, 7 ) + DToS( hu->k_data ) to ( cur_dir() + "tmp" )
    Goto ( tmp_rec )
    rest_box( buf )
  Otherwise
    Keyboard ""
  Endcase
  Return ret

//
Function f1closedms()

  mywait()
  //
  dbCreate( cur_dir() + "tmpk", { { "kod_k", "N", 7, 0 }, ;
    { "pr_smo", "N", 6, 0 }, ;
    { "summa", "N", 11, 2 }, ;
    { "sum_opl", "N", 11, 2 } } )
  Use ( cur_dir() + "tmpk" ) new
  Index On Str( FIELD->pr_smo, 6 ) + Str( FIELD->kod_k, 7 ) to ( cur_dir() + "tmpk" )
  dbCreate( cur_dir() + "tmph", { { "kod", "N", 7, 0 }, ;
    { "kod_k", "N", 7, 0 }, ;
    { "pr_smo", "N", 6, 0 }, ;
    { "k_data", "D", 8, 0 }, ;
    { "date_opl", "D", 8, 0 }, ;
    { "summa", "N", 11, 2 }, ;
    { "sum_opl", "N", 11, 2 } } )
  Use ( cur_dir() + "tmph" ) new
  g_use( dir_server() + "hum_p", dir_server() + "hum_pc", "HU" )
  find ( Str( atip_usl[ 2 ], 1 ) )
  Do While hu->tip_usl == atip_usl[ 2 ] .and. !Eof()
    Select TMPH
    Append Blank
    tmph->kod := hu->( RecNo() )
    tmph->kod_k := hu->kod_k
    tmph->pr_smo := hu->pr_smo
    tmph->k_data := hu->k_data
    tmph->summa := hu->cena
    If tmph->( LastRec() ) % 2000 == 0
      Commit
    Endif
    Select TMPK
    find ( Str( hu->pr_smo, 6 ) + Str( hu->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmpk->kod_k := hu->kod_k
      tmpk->pr_smo := hu->pr_smo
    Endif
    tmpk->summa += hu->cena
    Select HU
    Skip
  Enddo
  Select TMPH
  Index On Str( FIELD->pr_smo, 6 ) + Str( FIELD->kod_k, 7 ) + DToS( FIELD->k_data ) to ( cur_dir() + "tmph" )
  Select HU
  Set Order To 0
  //
  g_use( dir_server() + "plat_vz", dir_server() + "plat_vz", "PLZ" )
  Select TMPK
  Set Index To
  Go Top
  Do While !Eof()
    ar_opl := {}
    Select PLZ
    find ( Str( atip_usl[ 2 ], 1 ) + Str( tmpk->pr_smo, 6 ) + Str( tmpk->kod_k, 7 ) )
    Do While plz->tip == atip_usl[ 2 ] .and. plz->pr_smo == tmpk->pr_smo ;
        .and. plz->kod_k == tmpk->kod_k .and. !Eof()
      AAdd( ar_opl, { plz->summa_opl, ;
        plz->date_opl } )
      tmpk->sum_opl += plz->summa_opl
      Select PLZ
      Skip
    Enddo
    If tmpk->sum_opl > 0
      ASort( ar_opl,,, {| x, y| x[ 2 ] < y[ 2 ] } )
      Select TMPH
      find ( Str( tmpk->pr_smo, 6 ) + Str( tmpk->kod_k, 7 ) )
      Do While tmph->pr_smo == tmpk->pr_smo .and. tmph->kod_k == tmpk->kod_k .and. !Eof()
        s := tmph->summa
        Do While s > 0 .and. Len( ar_opl ) > 0
          s := round_5( s, 2 )
          mopl := round_5( ar_opl[ 1, 1 ], 2 )
          If mopl > s .or. mopl == s
            so := s   // сумма оплаты = остатку от суммы лечения
            ar_opl[ 1, 1 ] -= s
            s := 0
            tmph->date_opl := Max( ar_opl[ 1, 2 ], tmph->k_data )
            If Empty( mopl := round_5( ar_opl[ 1, 1 ], 2 ) )  // на всякий случай,
              del_array( ar_opl, 1 )    // если не сработало >= (при ==)
            Endif
          Else
            so := mopl   // сумма оплаты = остатку от суммы платежки
            s -= mopl
            del_array( ar_opl, 1 )
          Endif
          tmph->sum_opl += so
          If Len( ar_opl ) == 0
            Exit
          Endif
        Enddo
        Select TMPH
        Skip
      Enddo
      Select TMPH
      find ( Str( tmpk->pr_smo, 6 ) + Str( tmpk->kod_k, 7 ) )
      Do While tmph->pr_smo == tmpk->pr_smo .and. tmph->kod_k == tmpk->kod_k .and. !Eof()
        mdate := CToD( "" )
        If round_5( tmph->summa, 2 ) <= round_5( tmph->sum_opl, 2 )
          mdate := tmph->date_opl
        Endif
        Select HU
        Goto ( tmph->kod )
        If tmph->date_opl != hu->date_close
          g_rlock( forever )
          hu->date_close := mdate
          Unlock
        Endif
        Select TMPH
        Skip
      Enddo
    Endif
    Select TMPK
    If tmpk->( LastRec() ) % 2000 == 0
      Commit
    Endif
    Skip
  Enddo
  stat_msg( "Операция завершена!" ) ; mybell( 2, OK )
  Return Nil

//
Function f_usl_date()

  Local t_arr[ BR_LEN ], buf := SaveScreen(), blk

  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL - 7
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 19
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := ""
  t_arr[ BR_TITUL_COLOR ] := "W+/GR"
  t_arr[ BR_SEMAPHORE ] := "Дата смены цен - платные услуги"
  t_arr[ BR_OPEN ] := {|| f1_usl_date(,, "open" ) }
  t_arr[ BR_CLOSE ] := {|| dbCloseAll() }
  t_arr[ BR_ARR_BROWSE ] := {,,, "N/BG,W+/N,B/BG,BG+/B,W+/BG,N/W", .t., 300 }
  t_arr[ BR_FL_INDEX ] := .t.
  t_arr[ BR_FL_NOCLEAR ] := .t.
  t_arr[ BR_COLUMN ] := { { " Дата смены цен", {|| PadC( full_date( pud->data ), 16 ) }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| ;
    status_key( "^<Esc>^ выход ^<Ctrl+Enter>^ услуги ^<Ins>^ добавить ^<Del>^ удалить ^<F9>^ - печать" ) }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_usl_date( nk, ob, "edit" ) }
  edit_browse( t_arr )
  RestScreen( buf )
  Return Nil

//
Function f1_usl_date( nKey, oBrow, cregim )

  Local ret := -1, r := Row(), c := Col(), buf, fl := .f., rec := 0, k := 19

  Do Case
  Case cregim == "open"
    g_use( dir_server() + "pu_date", dir_server() + "pu_date", "PUD" )
    Go Top
    ret := !Eof()
  Case cregim == "edit"
    Do Case
    Case nKey == K_F9
      f2_usl_date( RecNo() )
    Case nKey == K_INS
      If !fl_found
        ColorWin( pr1 + 3, pc1, pr1 + 3, pc2, "N/N", "W+/N" )
      Endif
      If !Eof()
        rec := RecNo()
      Endif
      Private mdata := sys_date, gl_area := { 1, 0, 23, 79, 0 }
      Save Screen To buf
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, pc1 + 1, 21, pc2 - 1,, "Добавление", cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 3 Say "Дата" Get mdata
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
      myread()
      If LastKey() != K_ESC .and. !Empty( mdata ) .and. f_esc_enter( 1 )
        addrecn()
        rec := RecNo()
        Replace Data With mdata
        Unlock
        Commit
        oBrow:gotop()
        Goto ( rec )
      Endif
      If rec == 0
        ret := 1
      Else
        Goto ( rec )
        ret := 0
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. f_esc_enter( 2, .t. )
      g_use( dir_server() + "pu_cena", { dir_server() + "pu_cena", ;
        dir_server() + "pu_cenau" }, "PUC" )
      Do While .t.
        find ( Str( pud->( RecNo() ), 4 ) )
        If !Found() ; exit ; Endif
        deleterec( .t. )
      Enddo
      puc->( dbCloseArea() )
      Select PUD
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof()
        ret := 1
      Endif
    Case nKey == K_CTRL_ENTER
      f3_usl_date( RecNo() )
      ret := 0
    Endcase
  Endcase
  @ r, c Say ""
  Return ret

//
Function f2_usl_date( rec )

  Local arr[ 2 ], s, i, k, buf := save_row( MaxRow() ), ;
    sh := 80, HH := 60, name_file := cur_dir() + "pl_cena.txt"

  mywait()
  fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
  add_string( "" )
  add_string( Center( "Список платных услуг, у которых изменилась цена " + full_date( pud->data ) + "г.", sh ) )
  add_string( "" )
  g_use( dir_server() + "uslugi",, "USL" )
  g_use( dir_server() + "pu_cena", dir_server() + "pu_cena", "PUC" )
  Set Relation To kod_usl into USL
  find ( Str( rec, 4 ) )
  Index On fsort_usl( usl->shifr ) to ( cur_dir() + "tmp_usl" ) While puc->kod_date == rec
  Go Top
  Do While !Eof()
    s := AllTrim( usl->shifr ) + " " + AllTrim( usl->name ) + ;
      " [ПлЦ=" + lstr( puc->pcena, 11, 2 ) + ;
      ", ПлЦД=" + lstr( puc->pcena_d, 11, 2 ) + ;
      ", ПлДМС=" + lstr( puc->dms_cena, 11, 2 ) + "]"
    k := perenos( arr, s, sh )
    verify_ff( HH, .t., sh )
    add_string( arr[ 1 ] )
    For i := 2 To k
      add_string( PadL( AllTrim( arr[ i ] ), sh ) )
    Next
    Skip
  Enddo
  puc->( dbCloseArea() )
  usl->( dbCloseArea() )
  Select PUD
  rest_box( buf )
  FClose( fp )
  viewtext( name_file,,,, .f.,,, 2 )
  Return Nil

//
Function f3_usl_date( rec )

  Local buf := SaveScreen(), adbf
  Private fl_found, prec := rec

  mywait()
  g_use( dir_server() + "uslugi", dir_server() + "uslugish", "USL" )
  g_use( dir_server() + "pu_cena", { dir_server() + "pu_cena", ;
    dir_server() + "pu_cenau" }, "PUC" )
  adbf := dbStruct()
  AAdd( adbf, { "rec_puc", "N", 6, 0 } )
  AAdd( adbf, { "shifr", "C", 10, 0 } )
  AAdd( adbf, { "name", "C", 64, 0 } )
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On FIELD->shifr to ( cur_dir() + "tmp" )
  Select PUC
  find ( Str( prec, 4 ) )
  If ( fl_found := Found() )
    Do While puc->kod_date == prec .and. !Eof()
      Select USL
      Goto ( puc->kod_usl )
      Select TMP
      Append Blank
      tmp->kod_date := prec
      tmp->kod_usl  := puc->kod_usl
      tmp->pcena    := puc->pcena
      tmp->pcena_d  := puc->pcena_d
      tmp->dms_cena := puc->dms_cena
      tmp->rec_puc  := puc->( RecNo() )
      tmp->shifr    := usl->shifr
      tmp->name     := usl->name
      Select PUC
      Skip
    Enddo
  Endif
  Select TMP
  Go Top
  If !fl_found ; Keyboard Chr( K_INS ) ; Endif
  box_shadow( 0, 2, 0, 77, "GR+/RB", "Список платных услуг, у которых изменилась цена " + full_date( pud->data ) + "г.",, 0 )
  alpha_browse( 2, 1, 23, 77, "f4_usl_date", color0, "", "BG+/GR", ;
    .t., .t.,,, "f5_usl_date",, ;
    { "═", "░", "═", "N/BG,W+/N,B/BG", .t., 58 } )
  puc->( dbCloseArea() )
  usl->( dbCloseArea() )
  tmp->( dbCloseArea() )
  Select PUD
  RestScreen( buf )
  Return Nil

//
Function f4_usl_date( oBrow )

  Local oColumn, n := 40

  oColumn := TBColumnNew( "   Шифр", {|| tmp->shifr } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( "Наименование услуги", n ), {|| Left( tmp->name, n ) } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Пл.цена", {|| umest_val( tmp->pcena, 7, 2 ) } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "ЦенаРеб", {|| umest_val( tmp->pcena_d, 7, 2 ) } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "ЦенаДМС", {|| umest_val( tmp->dms_cena, 7, 2 ) } )
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ - выход;  ^<Ins>^ - добавление;  ^<Enter>^ - ред-ие цен;  ^<Del>^ - удаление" )
  Return Nil

//
Function f5_usl_date( nKey, oBrow )

  Local j := 0, k := -1, buf := save_row( MaxRow() ), buf1, fl := .f., rec, ;
    tmp_color := SetColor(), r1 := 12, c1 := 2, ;
    rec_tmp := tmp->( RecNo() ), rec_puc := tmp->rec_puc

  Do Case
  Case nKey == K_INS .or. nKey == K_ENTER
    If !fl_found .and. nKey == K_INS
      ColorWin( 5, 0, 5, 79, "N/N", "W+/N" )
    Endif
    Private mkod := iif( nKey == K_INS, 0, tmp->kod_usl ), ;
      mname := iif( nKey == K_INS, Space( 60 ), tmp->name ), ;
      mshifr := iif( nKey == K_INS, Space( 10 ), tmp->shifr ), ;
      mpcena := iif( nKey == K_INS, 0, tmp->pcena ), ;
      mpcena_d := iif( nKey == K_INS, 0, tmp->pcena_d ), ;
      mdms_cena := iif( nKey == K_INS, 0, tmp->dms_cena ), ;
      gl_area := { 1, 0, 23, 79, 0 }
    buf1 := box_shadow( r1, c1, 21, 76, color8, ;
      "Добавление новой услуги в список", cDataPgDn )
    SetColor( cDataCGet )
    @ r1 + 2, pc1 + 3 Say "Шифр услуги" Get mshifr Picture "@!" ;
      Valid f6_usl_date() when ( nKey == K_INS )
    @ r1 + 3, pc1 + 3 Say "Наименование услуги"
    @ r1 + 4, pc1 + 5 Get mname When .f.
    @ r1 + 5, pc1 + 3 Say "Цена платной услуги" Get mpcena Pict pict_cena()
    @ r1 + 6, pc1 + 3 Say "Цена платной услуги для ребека" Get mpcena_d Pict pict_cena()
    @ r1 + 7, pc1 + 3 Say "Цена ДМС услуги" Get mdms_cena Pict pict_cena()
    status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
    myread()
    If LastKey() != K_ESC .and. mkod > 0 .and. f_esc_enter( 1 )
      mywait()
      Select PUC
      If nKey == K_INS
        addrec( 4 )
        fl_found := .t.
        puc->kod_date := prec
        puc->kod_usl  := mkod
      Else
        Goto ( rec_puc )
        g_rlock( forever )
      Endif
      puc->pcena    := mpcena
      puc->pcena_d  := mpcena_d
      puc->dms_cena := mdms_cena
      Unlock
      rec_puc := puc->( RecNo() )
      Select TMP
      If nKey == K_INS
        Append Blank
        rec_tmp := tmp->( RecNo() )
        tmp->kod_date := prec
        tmp->kod_usl  := mkod
        tmp->shifr    := mshifr
        tmp->name     := mname
        tmp->rec_puc  := puc->( RecNo() )
      Endif
      tmp->pcena    := mpcena
      tmp->pcena_d  := mpcena_d
      tmp->dms_cena := mdms_cena
      Commit
      k := 0
    Elseif !fl_found
      k := 1
    Endif
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    SetColor( tmp_color )
    rest_box( buf ) ; rest_box( buf1 )
  Case nKey == K_DEL .and. tmp->kod_usl > 0 .and. f_esc_enter( 2 )
    mywait()
    Select PUC
    Goto ( tmp->rec_puc )
    deleterec( .t. )
    Select TMP
    deleterec( .t. )
    Commit
    k := 0
    Select TMP
    oBrow:gotop()
    Go Top
    If Eof()
      fl_found := .f. ; k := 1
    Endif
    rest_box( buf )
  Otherwise
    Keyboard ""
  Endcase
  Return k

//
Function f6_usl_date()

  Local fl := valid_shifr(), rec, ar

  If fl
    Select TMP
    rec := RecNo()
    find ( mshifr )
    If Found()
      fl := func_error( 4, "Вы повторно вводите данную услугу!" )
    Endif
    Goto ( rec )
    If fl
      Select USL
      find ( mshifr )
      If Found()
        mkod := usl->kod
        mname := usl->name
        ar := cenausldate( pud->data - 1, mkod )
        mpcena    := ar[ 1 ]
        mpcena_d  := ar[ 2 ]
        mdms_cena := ar[ 3 ]
        update_gets()
      Else
        fl := func_error( 4, "Нет такого шифра в базе данных услуг!" )
      Endif
    Endif
  Endif
  Return fl

// 28.03.23
Function vozvrat_platn( kod_human )

  Local buf := SaveScreen(), sotgr, str_sem, s, arr_v := {}, arr_p := {}, ;
    s_msg, mtitle, m1title := "", fl, tmp_s, i_m_otv := 0, j := 0, ;
    eval_box := {| _c, _s| box_shadow( 2, 9, 2, 70, _c, _s,, 0 ) }, ln_chek := 0, ;
    sum_bank, sum_nal, sum_itog, tip_banka
  Private rec_rashod, reg_otgruz := 1, ;
    p_otgr_p_gr := 0, a_uch_1, a_uch_2, ;
    summa_oplat := 0, summa_oplat_bn := 0
  Private mkol1 := 0, p_summa := 0, old_summa := 0, p1_summa := 0

  //
  mtitle := 'Возврат услуг'
  RestScreen( buf )
  //

  If human->cena <= human->sum_voz
    Return func_error( 4, ' Уже все вернули !' )
  Endif
  //
  summa_oplat := ( human->cena - human->sum_voz )
  summa_oplat_bn := human->sbank
  tip_banka := human->fr_tipkart
  // human->(dbCloseArea())
  //
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
  adbf := dbStruct()
  AAdd( adbf, { "date_u1", "D",  8, 0 } )
  AAdd( adbf, { "shifr_u", "C", 10, 0 } )
  AAdd( adbf, { "name_u", "C", 128, 0 } )
  AAdd( adbf, { "is_nul",  "L",  1, 0 } )
  AAdd( adbf, { "summa1",  "N",  9, 3 } )
  AAdd( adbf, { "summa2",  "N",  9, 3 } )
  AAdd( adbf, { "vz_cena", "N",  9, 3 } )
  AAdd( adbf, { "kol1",    "N",  5, 0 } )
  AAdd( adbf, { "number",  "N",  6, 0 } )
  AAdd( adbf, { "rec_hu",  "N",  7, 0 } )
  AAdd( adbf, { "nds20",   "N",  1, 0 } )
  AAdd( adbf, { "nds22",   "N",  1, 0 } )
  AAdd( adbf, { "nds18",   "N",  1, 0 } )
  AAdd( adbf, { "nds10",   "N",  1, 0 } )
  //
  dbCreate( cur_dir() + "tmp_usl", adbf )
  Use ( cur_dir() + "tmp_usl" ) New Alias tmp
  Index On Str( FIELD->u_kod, 4 ) + Str( FIELD->kod_vr, 4 ) + FIELD->date_u to ( cur_dir() + "tmp1usl" )
  Select HU
  Set Relation To u_kod into USL
  find ( Str( kod_human, 7 ) )
  If ( fl_found := Found() )
    adbf := Array( FCount() )
    cls
    Do While hu->kod == kod_human .and. !Eof()
      AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
      Select TMP
      find ( Str( hu->u_kod, 4 ) + Str( hu->kod_vr, 4 ) + hu->date_u )
      If Found()
        tmp->kol     := tmp->kol  + hu->kol
        tmp->kol1    := tmp->kol1 + hu->kol
        tmp->summa1  := tmp->summa1 + hu->stoim
        tmp->summa2  := tmp->summa1
        tmp->vz_cena := round_5( tmp->summa1 / tmp->kol, 2 )
      Else
        Append Blank
        AEval( adbf, {| x, i| FieldPut( i, x ) } )
        tmp->date_u1  := c4tod( hu->date_u )
        tmp->shifr_u  := usl->shifr
        If Len( AllTrim( usl->full_name ) ) > 3
          tmp->name_u := AllTrim( usl->shifr ) + " " + AllTrim( usl->full_name )
        Else
          tmp->name_u := AllTrim( usl->shifr ) + " " + AllTrim( usl->name )
        Endif
        If round_5( usl->pnds, 2 ) > 0
          If round_5( usl->pnds, 0 ) == 18
            tmp->nds18 := 1
          Elseif round_5( usl->pnds, 0 ) == 20
            tmp->nds20 := 1
          Elseif round_5( usl->pnds, 0 ) == 22
            tmp->nds22 := 1  
          Elseif round_5( usl->pnds, 0 ) == 10
            tmp->nds10 := 1
          Endif
        Endif
        tmp->is_nul   := usl->is_nulp
        tmp->rec_hu   := hu->( RecNo() )
        tmp->kol1     := hu->kol
        tmp->summa1   := tmp->stoim
        tmp->vz_cena  := round_5( tmp->summa1 / tmp->kol1, 2 )
      Endif
      Select HU
      Skip
    Enddo
  Endif
  Select TMP
  If mem_ordusl == 1
    Index On DToS( FIELD->date_u1 ) + fsort_usl( FIELD->shifr_u ) to ( cur_dir() + "tmp_usl" )
  Else
    Index On fsort_usl( FIELD->shifr_u ) + DToS( FIELD->date_u1 ) to ( cur_dir() + "tmp_usl" )
  Endif
  tmp->( dbEval( {|| tmp->number := ++j } ) )
  hu->( dbCloseArea() )
  usl->( dbCloseArea() )
  // удаление пред-х возвратов
  p_summa := summa_oplat
  //
  Select TMP
  Go Top
  box_shadow( 3, 4, 20, 75, color1, mtitle, color8, 0 )
  alpha_browse( 5, 7, 20, 72, "f1v_vozvrat", color0, m1title, "BG+/GR", ;
    .t., .t.,,, "f2v_vozvrat",, ;
    { "═", "░", "═", "N/BG,W+/N,B/BG,W+/B,R/BG,R/B", .t., 180, "*+" } )
  If f_esc_enter( "возврата", .t. )
    // вначале возвращаем наличку
    If p_summa <= ( summa_oplat - summa_oplat_bn )
      sum_bank  := 0
      tip_banka := 0
      sum_nal   := p_summa
    Else
      sum_nal   := summa_oplat - summa_oplat_bn
      sum_bank  := p_summa - sum_nal
    Endif
    // корректировка
    If sum_nal < 0 .and. sum_bank > 0
      // были предыдущие возвраты
      sum_nal := 0
      sum_bank := p_summa
    Endif
    fl := vozvrat_fr( sum_nal, sum_bank, @ln_chek, 1, tip_banka )
    // сам чек
    If fl
      // заносим возврат
      g_use( dir_server() + "hum_p_u", { dir_server() + "hum_p_u", ;
        dir_server() + "hum_p_uk", ;
        dir_server() + "hum_p_ud", ;
        dir_server() + "hum_p_uv", ;
        dir_server() + "hum_p_ua" }, "HU" )
      Select TMP
      Go Top
      Do While !Eof()
        Select TMP
        If tmp->kol1 > 0
          AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
          Select HU
          Append Blank
          AEval( adbf, {| x, i| FieldPut( i, x ) } )
          hu->kol   := tmp->kol1 * ( -1 )
          hu->stoim := tmp->summa1 * ( -1 )
        Endif
        Select TMP
        Skip
      Enddo
      hu->( dbCloseArea() )
      Select HUMAN
      g_rlock( forever )
      Replace human->date_voz With dtoc4( Date() ), human->sum_voz with ( p_summa + human->sum_voz )
      Unlock
      human->( dbCommit() )
      stat_msg( "Сумма возврата записана!" ) ; mybell( 1, OK )
      is_choice := .f.
      // s := K_END + K_ENTER
      // keysend(s)
    Endif
  Endif
  tmp->( dbCloseArea() )
  RestScreen( buf )
  Return Nil

// 10.09.18
Function f1v_vozvrat( oBrow )

  Local n, oColumn, blk := {|| if( tmp->kol1 > 0, { 3, 4 }, { 5, 6 } ) }

  //
  oColumn := TBColumnNew( " NN; пп", {|| Str( tmp->number, 3 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "   Шифр;  услуги", {|| tmp->shifr_u } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Врач", {|| put_val( ret_tabn( tmp->kod_vr ), 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Асс.", {|| put_val( ret_tabn( tmp->kod_as ), 5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Ко-;лич.;усл.", {|| tmp->kol } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " Общая; стоимость; услуги", {|| put_kop( tmp->stoim, 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Вернуть;кол-во", {|| put_val_0( tmp->kol1, 5, 0 ) } )
  oColumn:defColor := { 5, 5 }
  oColumn:colorBlock := {|| if( tmp->kol1 > 0, { 3, 4 }, { 5, 6 } ) }
  oBrow:addcolumn( oColumn )
  //
  status_key( "^<Esc>^ - выход для записи;  ^<Enter>^ - редактирование количества;" )
  Return Nil

// 10.09.18
Function f2v_vozvrat( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( 24 ), buf1, fl := .f., t_rec, ;
    nr := Row(), c1, rec, mkod, buf0, tmp_color := SetColor(), ;
    blk := {|| DevPos( 1, 2 ), DevOut( PadC( "Услуг к возврату" + ;
    " на сумму - " + lput_kop( p_summa, .t. ) + " руб.", 72 ), "W/B" ) }

  old_summa := 0
  t_rec := RecNo()
  Go Top
  Do While !Eof()
    // old_summa += round(tmp->u_cena * tmp->kol1, 2)
    old_summa += Round( tmp->vz_cena * tmp->kol1, 2 )
    // old_summa += round_5(round_5(tmp->summa2/tmp->kol,2) * tmp->kol1, 2)
    Skip
  Enddo
  Eval( blk )
  Goto t_rec
  Do Case
  Case nKey == K_ESC
    SetColor( tmp_color ) ; flag := 1
  Case nKey == K_ENTER
    SetColor( "GR+/RB,GR+/RB,,,G+/RB" )
    old_kol := mkol1 := tmp->kol1
    c1 :=  58
    @ nr, c1 Get mkol1 Pict "99999" valid {| g| f3v_vozvrat( g ) }
    myread()
    If LastKey() != K_ESC
      // p1_summa := round(tmp->u_cena * tmp->kol1, 2)
      p1_summa := Round( tmp->vz_cena * tmp->kol1, 2 )
      // p1_summa += round((tmp->summa2/tmp->kol) * (tmp->kol1- mkol1), 2)
      p_summa  := old_summa - p1_summa
      // tmp->summa1 := round_5(tmp->u_cena * mkol1, 2)
      tmp->summa1 := round_5( tmp->vz_cena * mkol1, 2 )

      p_summa :=  p_summa + tmp->summa1
      tmp->kol1   := mkol1
      tmp->stoim  := tmp->summa1
      // keyboard chr(K_ESC)
    Endif
    //
    Eval( blk )
    //
    SetColor( tmp_color ) ; flag := 0
  Otherwise
    Keyboard ""
  Endcase
  Return flag

//
Function f3v_vozvrat( get )

  Local lkol1
  Private mvar := ReadVar()

  if &mvar < 0 .and. LastKey() != K_UP
    &mvar := get:original
    Return func_error( 3, "Ошибка! Данное значение не может быть меньше нуля." )
  Endif
  If !( round_5( mkol1, 3 ) == round_5( get:original, 3 ) )
    If mkol1 > tmp->kol
      &mvar := get:original
      Return func_error( 3, "Ошибка! Возвращаемое количество услуг не может превышать фактическое." )
    Endif
  Endif
  Return .t.