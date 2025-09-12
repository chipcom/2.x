//**************************************************************************
// mo_kas_o.prg - ортопедия в задаче "Касса"
//**************************************************************************
// 29.09.15 f_ort_nar()
// f2_kas_ort(oBrow)
// sum_tmphum()
// f3_kas_ort(nKey,oBrow)
// 11.05.14 f4_kas_ort(rec,tmprec)
// fe_ko_kusl(oBrow)
// f3e_ko_kusl()
// f2e_ko_kusl(nKey,oBrow)
// f_glob_nar()
// ret_ort_nar()
// 11.05.14 yes_o_chek(/*@*/vsum,/*@*/vsd,/*@*/s,/*@*/v_bank)
// f41_kas_ort(par)
// f42_kas_ort()
// prn_kas_ort(lnomer_n,fl_hu)
//**************************************************************************
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

#define _KO_K_OPL      6  // итого к оплате по всему наряду
#define _KO_OPL        7  // уже оплачено
#define _KO_DOPL       8  // доплатить
#define _KO_SUMMA      9  // платная сумма наряда
#define _KO_O_SUMMA   10  // общая сумма за день
#define _KO_CENA      11  // сумма оплаты
#define _KO_SUMMA_NAR 12  // общая сумма наряда
#define _KO_LEN       12

Static enter_1 := 0

// 03.07.18
Function f_ort_nar()

  Local buf, str_sem, fl
  Parameters par

  // par = 1 - открытие наряда
  // par = 2 - редактирование наряда
  If  mek_kassa == 1 // .and. mek_nkassa == 1
    Private drvFR
    If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
      fr_zamena_otrezka()
    Else
      Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
    Endif
  Endif

  If par == 1
    fl := ( polikl1_kart() > 0 )
  Else
    If enter_1 > 0
      fl := .t.
    Else
      fl := ret_ort_nar()
    Endif
  Endif
  If fl
    str_sem := "KASSA - Редактирование человека " + lstr( glob_kartotek )
    If !g_slock( str_sem )
      Return func_error( 4, err_slock )
    Endif
    buf := SaveScreen()
    use_base( "kas_ort", "HUMAN" )
    Private adbf := dbStruct()
    AAdd( adbf, { "rec_hum", "N", 7, 0 } )
    dbCreate( cur_dir() + "tmphum", adbf )
    Use ( cur_dir() + "tmphum" ) new
    Index On iif( tip_n > 0, "1", "2" ) + DToS( k_data ) to ( cur_dir() + "tmphum" )
    If par == 2
      Select HUMAN
      adbf := Array( FCount() )
      Set Order To 4
      find ( Str( glob_nar[ 6 ], 4 ) + Str( glob_nar[ 1 ], 6 ) )
      Do While human->year_n == glob_nar[ 6 ] .and. human->nomer_n == glob_nar[ 1 ] .and. !Eof()
        AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
        Select TMPHUM
        Append Blank
        AEval( adbf, {| x, i| FieldPut( i, x ) } )
        tmphum->rec_hum := human->( RecNo() )
        Select HUMAN
        Skip
      Enddo
      Select TMPHUM
      Go Top
    Endif
    Close databases
    Private bOrt_open := ;
      {|| r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" ), ;
      use_base( "kas_ort", "HUMAN" ), ;
      g_use( cur_dir() + "tmphum", cur_dir() + "tmphum",, .t., .t. ), dbGoTop() }
    Eval( bOrt_open )
    If par == 1
      f3_kas_ort( K_INS )
      If enter_1 > 0
        Keyboard Chr( K_TAB ) + Chr( K_ENTER )
      Endif
    Else
      mtitle := glob_k_fio + ", наряд № " + lstr( glob_nar[ 1 ] ) + "/" + lstr( glob_nar[ 6 ] )
      alpha_browse( T_ROW, 2, MaxRow() -2, 77, "f2_kas_ort", color0, mtitle, "BG+/GR", ;
        .f., .t.,,, "f3_kas_ort",, ;
        { "═", "░", "═", "N/BG,W+/N,B/BG,BG+/B,N+/BG,W/N", .t., 180 } )
      enter_1 := 0
    Endif
    Close databases
    RestScreen( buf )
    g_sunlock( str_sem )
  Endif
  Return Nil

//
Function f2_kas_ort( oBrow )

  Local oColumn, blk := {|| iif( tmphum->tip_n == 2, { 3, 4 }, iif( tmphum->tip_n == 1, { 1, 2 }, { 5, 6 } ) ) }
  Local tip_bank := { "бн", "МИ", "VI", "MC" }

  oColumn := TBColumnNew( "Тип", {|| { "   ", "сл.", "пр." }[ tmphum->tip_n + 1 ] } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Вид наряда ", {|| inieditspr( A__MENUVERT, mm_kas_vid, tmphum->vid ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " № наряда", {|| PadR( lstr( tmphum->nomer_n ) + "/" + lstr( tmphum->year_n ), 9 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Дата оплаты", {|| full_date( tmphum->k_data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  // oColumn := TBColumnNew(" № чека",{|| iif(tmphum->sbank > 0, "бн"+put_val(tmphum->n_chek,6), put_val(tmphum->n_chek,8)) })
  //
  oColumn := TBColumnNew( " № чека", {|| iif( tmphum->sbank > 0, ;
    tip_bank[ tmphum->fr_tipkart + 1 ] + iif( tmphum->sbank == tmphum->cena, " ", "Н" ) + put_val( tmphum->n_chek, 5 ), ;
    put_val( tmphum->n_chek, 8 ) ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Сумма чека", {|| put_kop( tmphum->cena, 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Сумма пл.услуг", {|| put_kop( tmphum->summa, 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  status_key( "^<Esc>^ выход;  ^<Enter>^ ред-ие полей;  ^<Ins>^ редактировать наряд;  ^<F9>^ печать" )
  sum_tmphum()
  Return Nil

//
Function sum_tmphum()

  Local s1 := 0, s2 := 0, rec := tmphum->( RecNo() )

  Go Top
  Do While !Eof()
    s1 += tmphum->cena
    s2 += tmphum->summa
    Skip
  Enddo
  Goto ( rec )
  @ 23, 51 Say put_kop( s1, 10 ) Color "W/N"
  @ 23, 62 Say put_kop( s2, 10 ) Color "W/N"
  Return Nil

//
Function f3_kas_ort( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), buf1, fl := .f., rec, ;
    tmp_color := SetColor(), r1 := 13, c1 := 2, str_sem
  Private ldate_voz, lsum_voz

  Do Case
  Case nKey == K_F9 .and. !Empty( tmphum->nomer_n )
    prn_kas_ort( tmphum->nomer_n, .f. )
  Case nKey == K_INS .and. par == 1
    str_sem := "KASSA - Добавление ортопедического наряда"
    If !g_slock( str_sem )
      Return func_error( 4, err_slock )
    Endif
    enter_1 := 0
    Private mvid := Space( 10 ), m1vid := 2, ;
      mtip_n := Space( 10 ), m1tip_n := 1, ;
      mnomer_n := ret_last_n(), ;
      mkod_vr := 0, mtabn_vr := 0, mvrach := Space( 35 ), ;
      mkod_tex := 0, mtabn_tex := 0, mtexnik := Space( 35 ), ;
      gl_area := { 1, 0, 23, 79, 0 }
    mvid := inieditspr( A__MENUVERT, mm_kas_vid, m1vid )
    mtip_n := inieditspr( A__MENUVERT, mm_kas_tip, m1tip_n )
    buf1 := box_shadow( r1, c1, 23, 77, color8, ;
      "Добавление нового наряда", cDataPgDn )
    SetColor( cDataCGet )
    Do While .t.
      @ r1 + 2, c1 + 3 Say "Номер наряда" Get mnomer_n Pict "999999" When .f.
      @ r1 + 3, c1 + 3 Say "Тип наряда" Get mtip_n ;
        reader {| x| menu_reader( x, mm_kas_tip, A__MENUVERT,,, .f. ) }
      @ r1 + 4, c1 + 3 Say "Вид наряда" Get mvid ;
        reader {| x| menu_reader( x, mm_kas_vid, A__MENUVERT,,, .f. ) }
      @ r1 + 5, c1 + 3 Say "Таб.№ врача" Get mtabn_vr Pict "99999" ;
        valid {| g| f5e_kp_kusl( g, 2, 3 ) }
      @ Row(), Col() + 3 Get mvrach When .f. Color color14
      @ r1 + 6, c1 + 3 Say "Таб.№ техника" Get mtabn_tex Pict "99999" ;
        valid {| g| f5e_kp_kusl( g, 2, 4 ) }
      @ Row(), Col() + 3 Get mtexnik When .f. Color color14
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение записи" )
      myread()
      If LastKey() != K_ESC .and. f_esc_enter( 1 )
        If emptyany( m1tip_n, m1vid, mkod_vr )
          func_error( 4, "Введены не все данные!" )
          Loop
        Endif
        Select TMPHUM
        Append Blank
        tmphum->vid := m1vid
        tmphum->tip_n := m1tip_n
        tmphum->KOD_K := glob_kartotek
        tmphum->NOMER_N := mnomer_n
        tmphum->year_n := Year( sys_date )
        tmphum->N_CHEK := 0
        tmphum->SMENA := glob_smena
        tmphum->k_data := sys_date
        tmphum->kod_vr := mkod_vr
        tmphum->kod_tex := mkod_tex
        tmphum->CENA := tmphum->SUMMA := tmphum->O_SUMMA := tmphum->sbank := 0
        tmphum->KOD_OPER := Asc( kod_polzovat )
        //
        Select HUMAN
        addrec( 7 )
        human->vid := m1vid
        human->tip_n := m1tip_n
        human->KOD_K := glob_kartotek
        human->NOMER_N := mnomer_n
        human->year_n := Year( sys_date )
        human->N_CHEK := 0
        human->SMENA := glob_smena
        human->k_data := sys_date
        human->kod_vr := mkod_vr
        human->kod_tex := mkod_tex
        human->CENA := human->SUMMA := human->O_SUMMA := human->sbank := 0
        human->KOD_OPER := Asc( kod_polzovat )
        Commit
        Unlock
        rec := human->( RecNo() )
        tmphum->rec_hum := rec
        rectmp := tmphum->( RecNo() )
        glob_nar := f_glob_nar()
        If f4_kas_ort( rec, rectmp )  // запись чека
          flag := 0
          enter_1 := glob_nar[ 2 ]
        Else
          // если не подтвердили чек - удаляем запись из БД human
          use_base( "kas_ortu", "HU" )
          Do While .t.
            find ( Str( rec, 7 ) )
            If !Found() ; exit ; Endif
            deleterec( .t. )
          Enddo
          hu->( dbCloseArea() )
          Select HUMAN
          Goto ( rec )
          deleterec()
          flag := 1
        Endif
      Endif
      Exit
    Enddo
    rest_box( buf )
    rest_box( buf1 )
    g_sunlock( str_sem )
  Case nKey == K_ENTER .and. par == 2 .and. tmphum->tip_n > 0
    Private mvid, m1vid := tmphum->vid, ;
      mtip_n, m1tip_n := tmphum->tip_n, ;
      mnomer_n := tmphum->NOMER_N, ;
      mkod_vr := tmphum->kod_vr, mtabn_vr, mvrach := Space( 35 ), ;
      mkod_tex := tmphum->kod_tex, mtabn_tex, mtexnik := Space( 35 ), ;
      gl_area := { 1, 0, 23, 79, 0 }
    If mkod_vr > 0
      Select PERSO
      Goto ( mkod_vr )
      If !Eof() .and. !Deleted()
        mvrach := PadR( perso->fio, 35 )
        mtabn_vr := perso->tab_nom
      Endif
    Endif
    If mkod_tex > 0
      Select PERSO
      Goto ( mkod_tex )
      If !Eof() .and. !Deleted()
        mtexnik := PadR( perso->fio, 35 )
        mtabn_tex := perso->tab_nom
      Endif
    Endif
    mvid := inieditspr( A__MENUVERT, mm_kas_vid, m1vid )
    mtip_n := inieditspr( A__MENUVERT, mm_kas_tip, m1tip_n )
    buf1 := box_shadow( r1, c1, 23, 77, color8, ;
      "Редактирование полей в наряде", cDataPgDn )
    SetColor( cDataCGet )
    Do While .t.
      @ r1 + 2, c1 + 3 Say "Номер наряда" Get mnomer_n Pict "999999" When .f.
      @ r1 + 3, c1 + 3 Say "Тип наряда" Get mtip_n ;
        reader {| x| menu_reader( x, mm_kas_tip, A__MENUVERT,,, .f. ) }
      @ r1 + 4, c1 + 3 Say "Вид наряда" Get mvid ;
        reader {| x| menu_reader( x, mm_kas_vid, A__MENUVERT,,, .f. ) }
      @ r1 + 5, c1 + 3 Say "Таб.№ врача" Get mtabn_vr Pict "99999" ;
        valid {| g| f5e_kp_kusl( g, 2, 3 ) }
      @ Row(), Col() + 3 Get mvrach When .f. Color color14
      @ r1 + 6, c1 + 3 Say "Таб.№ техника" Get mtabn_tex Pict "99999" ;
        valid {| g| f5e_kp_kusl( g, 2, 4 ) }
      @ Row(), Col() + 3 Get mtexnik When .f. Color color14
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение записи" )
      myread()
      If LastKey() != K_ESC .and. f_esc_enter( 1 )
        If emptyany( m1tip_n, m1vid, mkod_vr )
          func_error( 4, "Введены не все данные!" )
          Loop
        Endif
        Select TMPHUM
        tmphum->vid := m1vid
        tmphum->tip_n := m1tip_n
        tmphum->kod_vr := mkod_vr
        tmphum->kod_tex := mkod_tex
        //
        Select HUMAN
        Goto ( tmphum->rec_hum )
        g_rlock( forever )
        human->vid := m1vid
        human->tip_n := m1tip_n
        human->kod_vr := mkod_vr
        human->kod_tex := mkod_tex
        Commit
        Unlock
        flag := 0
      Endif
      Exit
    Enddo
    rest_box( buf )
    rest_box( buf1 )
    Select TMPHUM
  Case nKey == K_INS .and. par == 2
    Select TMPHUM
    Append Blank
    tmphum->vid := glob_nar[ 4 ]
    tmphum->tip_n := 0
    tmphum->KOD_K := glob_kartotek
    tmphum->NOMER_N := glob_nar[ 1 ]
    tmphum->year_n := glob_nar[ 6 ]
    tmphum->N_CHEK := 0
    tmphum->SMENA := glob_smena
    tmphum->k_data := sys_date
    tmphum->CENA := tmphum->SUMMA := tmphum->O_SUMMA := tmphum->sbank := 0
    tmphum->KOD_OPER := Asc( kod_polzovat )
    //
    Select HUMAN
    addrec( 7 )
    human->vid := glob_nar[ 4 ]
    human->tip_n := 0
    human->KOD_K := glob_kartotek
    human->NOMER_N := glob_nar[ 1 ]
    human->year_n := glob_nar[ 6 ]
    human->N_CHEK := 0
    human->SMENA := glob_smena
    human->k_data := sys_date
    human->CENA := human->SUMMA := human->O_SUMMA := human->sbank := 0
    human->KOD_OPER := Asc( kod_polzovat )
    rec := human->( RecNo() )
    tmphum->rec_hum := rec
    Commit
    Unlock
    rectmp := tmphum->( RecNo() )
    If f4_kas_ort( rec, rectmp )  // запись чека
      Select TMPHUM
    Else
      use_base( "kas_ortu", "HU" )
      Do While .t.
        find ( Str( rec, 7 ) )
        If !Found() ; exit ; Endif
        deleterec( .t. )
      Enddo
      hu->( dbCloseArea() )
      Select HUMAN
      Goto ( rec )
      deleterec( .t. )
      Select TMPHUM
      deleterec()
      Go Top
    Endif
    sum_tmphum()
    flag := 0
  Case nKey == K_DEL .and. tmphum->KOD_K > 0 .and. tmphum->N_CHEK == 0 .and. f_esc_enter( 2 )
    rec := tmphum->rec_hum
    human->( dbGoto( rec ) )
    use_base( "kas_ortu", "HU" )
    Do While .t.
      find ( Str( rec, 7 ) )
      If !Found() ; exit ; Endif
      deleterec( .t. )
    Enddo
    hu->( dbCloseArea() )
    Select HUMAN
    Goto ( rec )
    deleterec( .t. )
    Select TMPHUM
    deleterec()
    flag := 1
  Otherwise
    Keyboard ""
  Endcase
  Return flag

// 05.08.16
Function f4_kas_ort( rec, tmprec )

  Local fl := .f., adbf, buf := SaveScreen(), tmp_color := SetColor( color1 ), ;
    j, l_color, mtitle, arr, ln_chek := 0, ;
    mi_post, mphone_m, maddress, tip_kart := 2, ;
    fr_zavodnomer := ""
  Private fl_found := .f., mcena[ _KO_LEN ], pvid := human->vid, p_opl := 0
  Private arr_opl := {}

  AFill( mcena, 0 )



  // 00.07.17 поиск номера или э.почты.
/*t_hum_rec := ho->(recno())
kart_kod  := human->kod_k
hum_o_kod := human->(recno())
*/
  mi_post   := Space( 30 )
  mphone_m  := Space( 11 )
/*
t_select := select()
select HO
do while ho->kod == hum_o_kod  .and. !eof()
  if len(alltrim(ho->i_post)) > 4
    mi_post := ho->i_post
  endif
  skip
enddo
goto (t_hum_rec)*/
  // выбираем приоритетом телефон
  // select(t_select)


  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( glob_kartotek )
  Private smvzros_reb := kart->vzros_reb
  kart->( dbCloseArea() )
  // поиск телефона
  r_use( dir_server() + "kartote_",, "KR_" ) // 00.07.17
  goto( glob_kartotek )
  mphone_m := kr_->phone_m
  kr_->( dbCloseArea() )
  mphone_m := transformphone( mphone_m )
  If Len( AllTrim( mphone_m ) ) < 11
    maddress := mi_post
  Else
    maddress := mphone_m
  Endif
  //
  g_use( dir_server() + "kas_usl",, "KU" )
  Index On Str( u_kod, 4 ) to ( cur_dir() + "tmp_ku" )
  f41_kas_ort( 1 )
  If par == 2
    f42_kas_ort()
  Endif
  r_use( dir_server() + "pu_date", dir_server() + "pu_date", "PUD" )
  r_use( dir_server() + "pu_cena", { dir_server() + "pu_cena", ;
    dir_server() + "pu_cenau" }, "PUC" )
  cls
  pr_1_str( "Ввод ортопед.услуг для больного < " + AllTrim( glob_k_fio ) + " >" )
  l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"
  mtitle := "Наряд № " + lstr( human->nomer_n ) + ", дата оплаты: " + full_date( human->k_data ) + "г."
  Private flag_1 := .t.
  Do While .t.
    Select TMP
    Go Top
    If LastRec() == 0
      Keyboard Chr( K_INS )
    Endif
    summa_usl( @mcena )
    f3e_ko_kusl()
    alpha_browse( 2, 0, 18, 79, "fe_ko_kusl", color1, mtitle, col_tit_popup, ;
      .f., .t.,,, "f2e_ko_kusl",, ;
      { "═", "░", "═", l_color, .t., 180 } )
    summa_usl( @mcena )
    If emptyall( mcena[ _KO_O_SUMMA ], mcena[ _KO_DOPL ] )
      j := 1
    Else
      arr := { " Выход без записи ", " Печать чека ", " Возврат в редактирование " }
      If Empty( mcena[ _KO_DOPL ] )
        arr[ 2 ] := " Запись "
      Endif
      j := f_alert( { PadC( "Выберите действие", 60, "." ) }, arr, ;
        2, "W+/N", "N+/N", MaxRow() -2,, "W+/N,N/BG" )
    Endif
    If j == 1
      Exit
    Elseif j == 2
      tmp->( dbCloseArea() )
      fl := .f.
      If Empty( mcena[ _KO_DOPL ] )
        fl := .t.
        ln_chek := -1
      Else
        Private p_summa := mcena[ _KO_DOPL ], fl_sdacha := .f.
        v_summa := v_sdacha := v_bank := 0
        If yes_o_chek( @v_summa, @v_sdacha, @mcena, @v_bank,, @maddress, @tip_kart )
          adbf := { { "name", "C", 128, 0 }, ;  // 00.01.18
          { "vrach", "C", 40, 0 }, ;
            { "cena", "N", 10, 2 }, ;
            { "kol",  "N",  4, 0 }, ;
            { "nds20", "N",  1, 0 }, ; // 10.08.08
          { "nds18", "N",  1, 0 }, ; // 10.08.08
          { "nds10", "N",  1, 0 } }
          dbCreate( cur_dir() + "tmp", adbf )
          Use ( cur_dir() + "tmp" ) new
          Append Blank
          tmp->name := "Наряд номер " + lstr( human->nomer_n )
          tmp->cena := mcena[ _KO_CENA ]
          tmp->kol := 1
          If chek_fr( v_summa, v_sdacha, @ln_chek, v_bank,, @fr_zavodnomer, maddress, tip_kart )
            // if (ln_chek := human->(recno())) > 0
            fl := .t.
          Endif
          tmp->( dbCloseArea() )
          // mywait("Печатается чек...")
          // inkey(5)  // пока так
        Endif
      Endif
      If fl
        Select HUMAN
        Goto ( rec )
        g_rlock( forever )
        human->N_CHEK := ln_chek
        human->cena := mcena[ _KO_CENA ]
        human->summa := mcena[ _KO_SUMMA ]
        human->o_summa := mcena[ _KO_O_SUMMA ]
        human->sbank := v_bank
        human->FR_zavod := fr_zavodnomer
        human->FR_tipkart := tip_kart
        human->fr_tip     := 2
        Unlock
        Select TMPHUM
        Goto ( tmprec )
        tmphum->N_CHEK := ln_chek
        tmphum->cena := mcena[ _KO_CENA ]
        tmphum->summa := mcena[ _KO_SUMMA ]
        tmphum->o_summa := mcena[ _KO_O_SUMMA ]
        tmphum->sbank := v_bank
        tmphum->FR_tipkart := tip_kart
        tmphum->fr_tip     := 2
        Commit
      Endif
      Use ( cur_dir() + "tmp_usl" ) New Alias tmp
      RestScreen( buf )
      Exit
    Elseif j == 3
      Loop
    Endif
  Enddo
  tmp->( dbCloseArea() )
  usl->( dbCloseArea() )
  puc->( dbCloseArea() )
  pud->( dbCloseArea() )
  ku->( dbCloseArea() )
  hu->( dbCloseArea() )
  Select TMPHUM
  SetColor( tmp_color )
  RestScreen( buf )
  Return fl

//
Function fe_ko_kusl( oBrow )

  Local oColumn, blk_color := {|| iif( tmp->is == 1, { 3, 4 }, { 1, 2 } ) }

  //
  oColumn := TBColumnNew( "Вид услуги", {|| PadR( inieditspr( A__MENUVERT, mm_kas_vid, tmp->vid ), 11 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Дата;опла-;ты", {|| Left( full_date( tmp->k_data ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "   Шифр;  услуги", {|| tmp->shifr_u } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "  Наименование;  услуги", {|| Left( tmp->name_u, 20 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Ко-;лич.;усл.", {|| tmp->kol } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "   Цена;  услуги", {|| put_kop( tmp->u_cena, 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Общая; стоимость; услуги", {|| put_kop( tmp->stoim, 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ выход ^<Enter>^ ред-ие ^<Ins>^ добавление ^<Del>^ удаление ^<F9>^ печать" )
  Return Nil

//
Function f3e_ko_kusl()

  Static arr := { { "И_Т_О_Г_О сумма наряда", _KO_SUMMA_NAR }, ;
    { "итого сумма за ", _KO_O_SUMMA }, ;
    { "итого к оплате", _KO_K_OPL }, ;
    { "оплачено", _KO_OPL }, ;
    { "доплатить", _KO_DOPL } }
  Static scolor := "W/B", scolor1 := "G/B", scolor2 := "G+/B", si := 0
  Local i, j

  If si == 0
    si := 1
    arr[ 2, 1 ] += Left( DToC( sys_date ), 5 )
  Endif
  For i := 1 To 5
    @ 18 + i, 0 Say Space( 80 ) Color scolor
    j := arr[ i, 2 ]
    @ 18 + i, 10 Say PadL( arr[ i, 1 ], 22 ) Color scolor
    @ Row(), Col() Say Str( mcena[ j ], 11, 2 ) Color iif( Empty( mcena[ j ] ), scolor1, scolor2 )
    j := i
    @ 18 + i, 54 Say PadL( mm_kas_vid[ i, 1 ], 13 ) Color scolor
    @ Row(), Col() Say Str( mcena[ j ], 11, 2 ) Color iif( Empty( mcena[ j ] ), scolor1, scolor2 )
  Next
  Return Nil

//
Function f2e_ko_kusl( nKey, oBrow )

  Local flag := -1, buf := SaveScreen(), fl := .f., ;
    j := 0, s := 0, so := 0, tmp_color := SetColor(), ;
    rec_tmp := tmp->( RecNo() ), mrec_hu := tmp->rec_hu
  
  Private r1 := 13
  Do Case
  Case nKey == K_F9
    prn_kas_ort( human->nomer_n, .t. )
    r_use( dir_server() + "pu_date", dir_server() + "pu_date", "PUD" )
    r_use( dir_server() + "pu_cena", { dir_server() + "pu_cena", ;
      dir_server() + "pu_cenau" }, "PUC" )
    use_base( "kas_ortu", "HU" )
    g_use( dir_server() + "kas_usl", cur_dir() + "tmp_ku", "KU" )
    r_use( dir_server() + "uslugi", dir_server() + "uslugish", "USL" )
    Use ( cur_dir() + "tmp_usl" ) New index ( cur_dir() + "tmp_usl" ) Alias tmp
    Goto ( rec_tmp )
  Case nKey == K_INS .or. ( nKey == K_ENTER .and. tmp->rec_hu > 0 .and. tmp->is == 0 )
    chm_help_code := 1// HM_Edit1_kart
    If nKey == K_INS .and. !fl_found
      ColorWin( 7, 0, 7, 79, "B/B", "W+/RB" )
    Endif
    Private mu_kod := if( nKey == K_INS, 0, tmp->u_kod ), ;
      mu_cena := if( nKey == K_INS, 0, tmp->u_cena ), ;
      mkol := if( nKey == K_INS, 0, tmp->kol ), ;
      mstoim := if( nKey == K_INS, 0, tmp->stoim ), ;
      mshifr := if( nKey == K_INS, Space( 10 ), tmp->shifr_u ), ;
      mname_u := if( nKey == K_INS, Space( 65 ), tmp->name_u ), ;
      mvid := Space( 10 ), m1vid := if( nKey == K_INS, pvid, tmp->vid ), ;
      gl_area := { 1, 0, 23, 79, 0 }
    mvid := inieditspr( A__MENUVERT, mm_kas_vid, m1vid )
    box_shadow( r1, 0, 23, 79, color8, ;
      if( nKey == K_INS, "Добавление новой", ;
      "Редактирование" ) + " ортопедической услуги в чеке", "RB+/B" )
    Do While .t.
      SetColor( cDataCGet )
      @ r1 + 2, 2 Say "Вид услуги" Get mvid ;
        reader {| x| menu_reader( x, mm_kas_vid, A__MENUVERT,,, .f. ) }
      @ r1 + 3, 2 Say "Шифр услуги" Get mshifr Pict "@!" ;
        when {| g| f5e_kp_kusl( g, 1, 1, 2 ) } ;
        valid {| g| f5e_kp_kusl( g, 2, 1, 2 ) }
      @ r1 + 4, 2 Say "Цена услуги" Get mu_cena Pict pict_cena() ;
        when {| g| f5e_kp_kusl( g, 1, 2 ) } ;
        valid {| g| f5e_kp_kusl( g, 2, 2 ) }
      @ r1 + 5, 2 Say "Услуга" Get mname_u When .f. Color color14
      @ r1 + 6, 2 Say "Количество услуг" Get mkol Pict "999" ;
        valid {| g| f5e_kp_kusl( g, 2, 5 ) }
      @ r1 + 7, 2 Say "Общая стоимость услуги" Get mstoim Pict pict_cena() ;
        When .f.
      status_key( "^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи" )
      myread()
      If LastKey() != K_ESC
        If emptyany( m1vid, mu_kod, mstoim )
          func_error( 4, "Введены не все данные!" )
          Loop
        Else
          mywait()
          Select HU
          If nKey == K_INS
            addrec( 7 )
            mrec_hu := hu->( RecNo() )
            fl_found := .t.
            Select TMP
            Append Blank
            rec_tmp := tmp->( RecNo() )
          Else
            Goto ( mrec_hu )
            g_rlock( forever )
            Select TMP
            Goto ( rec_tmp )
          Endif
          Select HU
          Replace hu->kod     With human->( RecNo() ), ;
            hu->vid     With m1vid, ;
            hu->stoim   With mstoim, ;
            hu->u_kod   With mu_kod, ;
            hu->u_cena  With mu_cena, ;
            hu->kol     With mkol
          Unlock
          Select TMP
          tmp->rec_hu := mrec_hu
          tmp->vid := m1vid
          tmp->k_data := sys_date
          tmp->U_KOD := mu_kod
          tmp->U_CENA := mu_cena
          tmp->KOL := mkol
          tmp->STOIM := mstoim
          tmp->shifr_u := mshifr
          tmp->name_u := mname_u
          tmp->shifr_u := mshifr
          tmp->name_u := mname_u
          tmp->rec_hu := mrec_hu
          summa_usl( @mcena )
          Commit
        Endif
      Endif
      Exit
    Enddo
    flag := 0
    If nKey == K_INS .and. !fl_found
      flag := 1
    Endif
    RestScreen( buf )
    f3e_ko_kusl()
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    SetColor( tmp_color )
  Case nKey == K_DEL .and. tmp->rec_hu > 0 .and. tmp->is == 0
    If f_esc_enter( 2 )
      mywait()
      Select HU
      Goto ( tmp->rec_hu )
      deleterec( .t. )
      Select TMP
      deleterec( .t. )
      Unlock
      Commit
      oBrow:gotop()
      Go Top
      summa_usl( @mcena )
      If Eof()
        fl_found := .f. ; Keyboard Chr( K_INS )
      Endif
      flag := 0
      RestScreen( buf )
      f3e_ko_kusl()
    Endif
  Otherwise
    Keyboard ""
  Endcase
  Return flag

//
Static Function summa_usl( s )

  Local i, fl, rec := tmp->( RecNo() )

  AFill( s, 0 )
  s[ _KO_OPL ] := p_opl  // уже оплачено
  Select TMP
  Go Top
  Do While !Eof()
    s[ _KO_SUMMA_NAR ] += tmp->stoim
    fl := equalany( tmp->vid, LPU_KAS_PLAT, LPU_KAS_PL_S )
    If fl
      s[ _KO_K_OPL ] += tmp->stoim
    Endif
    If Between( tmp->vid, 1, 5 )
      s[ tmp->vid ] += tmp->stoim
    Endif
    If tmp->is == 0
      If fl
        s[ _KO_SUMMA ] += tmp->stoim
      Endif
      s[ _KO_O_SUMMA ] += tmp->stoim
    Endif
    Skip
  Enddo
  Goto ( rec )
  s[ _KO_DOPL ] := s[ _KO_K_OPL ] - s[ _KO_OPL ]  // доплатить
  For i := 1 To Len( s )
    s[ i ] := round_5( s[ i ], 2 )
  Next
  Return Nil

//
Function f_glob_nar()
  Return { human->nomer_n, ;
    human->( RecNo() ), ;
    human->tip_n, ;
    human->vid, ;
    human->kod_k, ;
    human->year_n, ;
    human->k_data }

// вернуть последний номер наряда
Static Function ret_last_n()

  Local n := 0, tmp_select := Select(), rec, y := Year( sys_date )

  Select HUMAN
  rec := human->( RecNo() )
  Set Order To 4
  dbSeek( Str( y + 1, 4 ), .t. )
  Skip -1
  If Year( human->k_data ) == y
    n := human->nomer_n
  Endif
  Set Order To 1
  Goto ( rec )
  Select ( tmp_select )
  Return n + 1

//
Function ret_ort_nar()

  Static si := 1
  Local i, n, r2, fl := .f., arr := {}, arr1 := {}, buf

  If ( i := popup_prompt( T_ROW, T_COL + 5, si, ;
      { "Поиск в ~картотеке", "По номеру ~наряда" } ) ) == 0
    Return fl
  Endif
  If ( si := i ) == 1
    If polikl1_kart() > 0
      use_base( "kas_ort", "HUMAN" )
      find ( Str( glob_kartotek, 7 ) )
      Do While human->kod_k == glob_kartotek .and. !Eof()
        If human->tip_n > 0 .and. AScan( arr, {| x| human->nomer_n == x[ 1 ] } ) == 0
          AAdd( arr, f_glob_nar() )
        Endif
        Skip
      Enddo
      Use
      If Len( arr ) == 0
        fl := func_error( 4, 'Нет открытых нарядов для "' + glob_k_fio + '"' )
      Else
        ASort( arr,,, {| x, y| iif( x[ 6 ] == y[ 6 ], x[ 1 ] > y[ 1 ], x[ 6 ] > y[ 6 ] ) } )
        For i := 1 To Len( arr )
          AAdd( arr1, "Наряд № " + lstr( arr[ i, 1 ] ) + "/" + lstr( arr[ i, 6 ] ) )
        Next
        buf := SaveScreen()
        status_key( "^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор номера наряда" )
        If ( r2 := T_ROW + Len( arr1 ) + 1 ) > MaxRow() -2
          r2 := MaxRow() -2
        Endif
        If ( i := Popup( T_ROW, T_COL + 5, r2, T_COL + 5 + 22, arr1,, color0, .t. ) ) > 0
          glob_nar := arr[ i ]
          fl := .t.
        Endif
        RestScreen( buf )
      Endif
    Endif
  Else
    If ( n := input_value( 20, 15, 22, 64, color1, ;
        Space( 10 ) + "Введите номер наряда", ;
        glob_nar[ 1 ], "999999" ) ) != Nil .and. i > 0
      use_base( "kas_ort", "HUMAN" )
      Set Order To 4
      For i := Year( sys_date ) -10 To Year( sys_date ) + 10
        find ( Str( i, 4 ) + Str( n, 6 ) )
        Do While human->year_n == i .and. human->nomer_n == n .and. !Eof()
          If human->tip_n > 0 .and. human->kod_k > 0
            AAdd( arr, f_glob_nar() )
          Endif
          Skip
        Enddo
      Next
      Use
      If Len( arr ) == 0
        fl := func_error( 4, "Не найден наряд № " + lstr( n ) )
      Elseif Len( arr ) == 1
        glob_nar := arr[ 1 ]
        fl := .t.
      Else
        ASort( arr,,, {| x, y| iif( x[ 6 ] == y[ 6 ], x[ 1 ] > y[ 1 ], x[ 6 ] > y[ 6 ] ) } )
        r_use( dir_server() + "kartotek",, "KART" )
        For i := 1 To Len( arr )
          Goto ( arr[ i, 5 ] )
          AAdd( arr1, "Наряд № " + lstr( arr[ i, 1 ] ) + "/" + lstr( arr[ i, 6 ] ) + "  " + fam_i_o( kart->fio ) )
        Next
        Use
        buf := SaveScreen()
        status_key( "^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор номера наряда" )
        If ( r2 := T_ROW + Len( arr1 ) + 1 ) > MaxRow() -2
          r2 := MaxRow() -2
        Endif
        If ( i := Popup( T_ROW, T_COL + 5, r2, T_COL + 5 + 42, arr1,, color0, .t. ) ) > 0
          glob_nar := arr[ i ]
          fl := .t.
        Endif
        RestScreen( buf )
      Endif
      If fl
        r_use( dir_server() + "kartotek",, "KART" )
        Goto ( glob_nar[ 5 ] )
        glob_kartotek := kart->kod
        glob_k_fio := AllTrim( kart->fio )
        Use
      Endif
    Endif
  Endif
  Return fl

// 11.05.14
Function yes_o_chek( /*@*/vsum, /*@*/vsd, /*@*/s, /*@*/vbank, rm, /*@*/address, /*@*/tip_kart )

  Local tip_bank_kart := { { "МИР", 1 }, ;
    { "VISA", 2 }, ;
    { "MasterCard", 3 } }
  Local fl := .f., tmp_color, buf := SaveScreen(), r := 11, a[ 3 ], ;
    j, spict := "999999.99"

  change_attr()
  If meK_bank == 1
    tmp_color := SetColor( cDataCGet )
    Private vnos_summa := 0, bank_summa := 0, ;
      mbank_kart, m1bank_kart := tip_kart, ;
      maddress := PadR( address, 30 )
    mbank_kart := inieditspr( A__MENUVERT, tip_bank_kart, m1bank_kart )
    p_summa := s[ _KO_DOPL ]
    Do While .t.
      buf := box_shadow( r, 6, r + 10, 73 )
      buf24 := save_maxrow()
      @ r + 1, 8 Say "Телефон или Электр.почта" Get maddress Pict "@S30" ;
        valid {| g | controladdress( g, maddress ) }
      @ r + 2, 8 Say "Итоговая сумма наряда " Get s[ _KO_K_OPL ] Picture spict When .f.
      @ r + 3, 8 Say "Сумма предыдущих оплат" Get s[ _KO_OPL ] Picture spict When .f.
      @ r + 4, 8 Say "Следует доплатить     " Get s[ _KO_DOPL ] Picture spict When .f. ;
        Color "G+/B"
      @ r + 5, 8 Say "Сумма оплаты          " Get p_summa Picture spict ;
        Valid iif( s[ _KO_DOPL ] > 0, p_summa > 0 .and. p_summa <= s[ _KO_DOPL ], .t. )
      @ r + 6, 8 Say "-------------------------------------------------------------"
      @ r + 7, 8 Say "Введите вносимую сумму (для подсчета сдачи)       " ;
        Get vnos_summa Picture spict valid {| g| val_y_chek( g, 1 ) }
      @ r + 8, 8 Say "Сумма, вносимая безналичными (по банковской карте)" ;
        Get bank_summa Picture spict valid {| g| val_y_chek( g, 2 ) } ;
        When round_5( vnos_summa, 2 ) < p_summa
      @ r + 9, 8 Say "Тип банковской карты" Get mbank_kart ;
        reader {| x| menu_reader( x, tip_bank_kart, A__MENUVERT,,, .f. ) };
        When bank_summa > 0
      status_key( "^<Esc>^ - выход без записи чека;  ^<PgDn>^ - запись чека" )
      myread()
      j := f_alert( { PadC( "Выберите действие", 60, "." ) }, ;
        { " Выход без записи ", " Печать чека ", " Возврат в редактирование " }, ;
        iif( LastKey() == K_ESC, 1, 2 ), "W+/N", "N+/N", MaxRow() -2,, "W+/N,N/BG" )
      If j == 1
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
      s[ _KO_CENA ] := p_summa
      If vnos_summa >= p_summa
        a[ 1 ] := vnos_summa
        a[ 2 ] := p_summa
        a[ 3 ] := round_5( vnos_summa - p_summa, 2 )
        f_message( { "Вносимая сумма: " + Str( a[ 1 ], 10, 2 ), ;
          "Сумма чека    : " + Str( a[ 2 ], 10, 2 ), ;
          "──────────────────────────", ;
          "Сумма сдачи   : " + Str( a[ 3 ], 10, 2 ) },, ;
          cHelpCMain, cHelpCMain )
        fl_sdacha := .t.
        vsum := a[ 1 ] ; vsd := a[ 3 ] ; vbank := 0
      Else
        f_message( { "Сумма наличными: " + Str( vnos_summa, 10, 2 ), ;
          "Сумма по карте : " + Str( bank_summa, 10, 2 ), ;
          "Сумма чека     : " + Str( p_summa,   10, 2 ) },, ;
          cHelpCMain, cHelpCMain )
        fl_sdacha := .f.
        vsum := vnos_summa ; vsd := 0 ; vbank := bank_summa

      Endif
      address  := maddress
      tip_kart := m1bank_kart
      fl := .t.
      Exit
    Enddo
    SetColor( tmp_color )
  Else
    tmp_color := SetColor( cDataCGet )
    buf := box_shadow( r, 6, r + 7, 73 )
    buf24 := save_row( MaxRow() )
    Private vnos_summa := 0, mkocena := s[ _KO_DOPL ]
    @ r + 1, 8 Say "Итоговая сумма наряда " Get s[ _KO_K_OPL ] Picture spict When .f.
    @ r + 2, 8 Say "Сумма предыдущих оплат" Get s[ _KO_OPL ] Picture spict When .f.
    @ r + 3, 8 Say "Следует доплатить     " Get s[ _KO_DOPL ] Picture spict When .f. ;
      Color "G+/B"
    @ r + 4, 8 Say "Сумма оплаты          " Get mkocena Picture spict ;
      Valid iif( s[ _KO_DOPL ] > 0, mkocena > 0 .and. mkocena <= s[ _KO_DOPL ], .t. )
    @ r + 5, 8 Say "------------------------------------------------------"
    @ r + 6, 8 Say "Введите вносимую сумму (для подсчета сдачи)" ;
      Get vnos_summa Picture spict ;
      Valid iif( Empty( vnos_summa ), .t., mkocena <= vnos_summa )
    status_key( "^<Esc>^ - выход без записи чека;  ^<Enter>^ - запись и печать чека" )
    myread()
    RestScreen()
    SetColor( tmp_color )
    If LastKey() != K_ESC
      s[ _KO_CENA ] := p_summa := mkocena
      If vnos_summa > 0
        a[ 1 ] := vnos_summa
        a[ 2 ] := p_summa
        a[ 3 ] := round_5( vnos_summa - p_summa, 2 )
        f_message( { "Вносимая сумма: " + Str( a[ 1 ], 10, 2 ), ;
          "Сумма чека    : " + Str( a[ 2 ], 10, 2 ), ;
          "──────────────────────────", ;
          "Сумма сдачи   : " + Str( a[ 3 ], 10, 2 ) },, ;
          cHelpCMain, cHelpCMain )
        fl_sdacha := .t.
        vsum := a[ 1 ] ; vsd := a[ 3 ] ; vbank := 0
      Endif
      fl := .t.
    Endif
  Endif
  Return fl

//
Function f41_kas_ort( par )

  Local adbf := { ;
    { "is",   "N",     1,     0 }, ; // 0-добавление,1-ред-ие
    { "rec_hu",   "N",     7,     0 }, ; // номер записи по БД "HU"
    { "k_data",   "D",     8,     0 }, ; // дата оплаты
    { "VID",   "N",     1,     0 }, ; // вид услуги
    { "U_KOD",   "N",     4,     0 }, ; // код услуги
    { "U_CENA",   "N",    10,     2 }, ; // цена услуги
    { "KOL",   "N",     3,     0 }, ; // количество услуг
    { "STOIM",   "N",    10,     2 }, ; // итоговая стоимость услуги
    { "shifr_u",   "C",    10,     0 }, ;
    { "name_u",   "C",    65,     0 } }
  dbCreate( cur_dir() + "tmp_usl", adbf )
  Use ( cur_dir() + "tmp_usl" ) New Alias tmp
  If par == 1
    Index On Str( 2 -is, 1 ) + Str( vid, 1 ) + DToS( k_data ) + fsort_usl( shifr_u ) to ( cur_dir() + "tmp_usl" )
  Else
    Index On Str( vid, 1 ) + DToS( k_data ) + fsort_usl( shifr_u ) to ( cur_dir() + "tmp_usl" )
  Endif
  use_base( "kas_ortu", "HU" )
  r_use( dir_server() + "uslugi", dir_server() + "uslugish", "USL" )
  Return Nil

//
Function f42_kas_ort()

  Local rec := human->( RecNo() )

  If Type( "p_opl" ) != "N"
    Private p_opl := 0
  Endif
  Select HUMAN
  Set Order To 4
  find ( Str( glob_nar[ 6 ], 4 ) + Str( glob_nar[ 1 ], 6 ) )
  Do While human->year_n == glob_nar[ 6 ] .and. human->nomer_n == glob_nar[ 1 ] .and. !Eof()
    p_opl += human->cena
    AAdd( arr_opl, { human->vid, ;      // 1
    human->TIP_N, ;    // 2
    human->kod_vr, ;   // 3
    human->kod_tex, ;  // 4
    human->N_CHEK, ;   // 5
    human->SMENA, ;    // 6
    human->k_data, ;   // 7
    human->cena, ;     // 8
      human->summa, ;    // 9
    human->o_summa, ;  // 10
    human->kod_oper } ) // 11
    Select HU
    find ( Str( human->( RecNo() ), 7 ) )
    Do While hu->kod == human->( RecNo() ) .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      Select TMP
      Append Blank
      tmp->is      := 1
      tmp->rec_hu  := hu->( RecNo() )
      tmp->k_data  := human->k_data
      tmp->VID     := hu->VID
      tmp->U_KOD   := hu->U_KOD
      tmp->U_CENA  := hu->U_CENA
      tmp->KOL     := hu->KOL
      tmp->STOIM   := hu->STOIM
      tmp->shifr_u := usl->shifr
      tmp->name_u  := usl->name
      Select HU
      Skip
    Enddo
    Select HUMAN
    Skip
  Enddo
  // сначала tip_n=1 или tip_n=2, а затем по дате
  ASort( arr_opl,,, {| x, y| iif( x[ 7 ] == y[ 7 ], x[ 2 ] > y[ 2 ], x[ 7 ] < y[ 7 ] ) } )
  Select HUMAN
  Set Order To 1
  Goto ( rec )
  Return Nil

//
Function prn_kas_ort( lnomer_n, fl_hu )

  Local rec := tmphum->( RecNo() ), i, s

  If !fl_hu
    Private arr_opl := {}
    f41_kas_ort( 2 )
    f42_kas_ort()
  Endif
  Private file_sh
  If !Empty( mem_or_ext ) .and. ;
      !Empty( file_sh := menu_shablon( 3, 3, dir_exe() + "*." + mem_or_ext, color8, .f., .f. ) )
    Private t_arr_opl := {}, mvrach := "", mtexnik := "", ;
      mtabn_vr := mtabn_tex := 0, ;
      mnomer_n := glob_nar[ 1 ], ;
      mvid := inieditspr( A__MENUVERT, mm_kas_vid, glob_nar[ 4 ] ), ;
      mtip_n := inieditspr( A__MENUVERT, mm_kas_tip, glob_nar[ 3 ] )
    If Len( arr_opl ) > 0
      If arr_opl[ 1, 3 ] > 0
        perso->( dbGoto( arr_opl[ 1, 3 ] ) )
        mtabn_vr := perso->tab_nom
        mvrach := AllTrim( perso->fio )
      Endif
      If arr_opl[ 1, 4 ] > 0
        perso->( dbGoto( arr_opl[ 1, 4 ] ) )
        mtabn_tex := perso->tab_nom
        mtexnik := AllTrim( perso->fio )
      Endif
    Endif
    r_use( dir_server() + "base1",, "BASE1" )
    For i := 1 To Len( arr_opl )
      If !emptyall( arr_opl[ i, 8 ], arr_opl[ i, 9 ], arr_opl[ i, 9 ] )
        base1->( dbGoto( arr_opl[ i, 11 ] ) )
        s := ""
        If !Eof() .and. !Empty( base1->p1 )
          s := AllTrim( Crypt( base1->p1, gpasskod ) )
        Endif
        AAdd( t_arr_opl, { arr_opl[ i, 2 ], ;  // 1 - tip_n
        arr_opl[ i, 5 ], ;  // 2 - N_CHEK
        arr_opl[ i, 6 ], ;  // 3 - SMENA
        s, ;             // 4 - регистратор
          arr_opl[ i, 7 ], ;  // 5 - k_data
        arr_opl[ i, 8 ], ;  // 6 - cena
        arr_opl[ i, 9 ], ;  // 7 - summa
        arr_opl[ i, 10 ] } ) // 8 - o_summa
      Endif
    Next
    base1->( dbCloseArea() )
    ASort( t_arr_opl,,, {| x, y| iif( x[ 5 ] == y[ 5 ], x[ 2 ] < y[ 2 ], x[ 5 ] < y[ 5 ] ) } )
    Select TMP
    Index On Str( vid, 1 ) + DToS( k_data ) + fsort_usl( shifr_u ) to ( cur_dir() + "tmp_usl2" )
    Go Top
    kassa_r_list_uch( 1, "f1_pr_shab(file_sh)" )
  Endif
  Close databases
  Eval( bOrt_open )
  Goto ( rec )
  Return Nil
