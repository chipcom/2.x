//**************************************************************************
// mo_ortop.prg
//**************************************************************************
// sin_ysl()
// f1edit_ort(oBrow)
// f2edit_ort(nKey,oBrow)
// vvod_tor_ysl()
// ff1edit_ysl(oBrow)
// ff2edit_ysl(nKey,oBrow)
// fore_o_kusl(get,when_valid,k)
// MT_use_base(k)
// Ort_boln(par1)
// add_orto_usl(larr,lkod)
// Ort_oborot()
// Ort_diagnoz()
// O_dms_reestr()
// f1_Ort_vzaim(nKey,oBrow,regim)
// f2_Ort_vzaim(nKey,oBrow,regim)
// Orees2_vzaim(name_file)
// Oo_proverka(k)
// Oo_1_proverka()
// Oo_2_proverka()
// Ort_den_sr(par)
// Oo_statist(k)
// Oob_statist(par1,par2,par3)
// Oob1_statist(par1)
// Ort_material()
// Ort_dolgi(tip)
// Ort_otkr_nar(par1,par2)
// Ort_mnog_poisk()
// s1_mnog_poisk(cv,cf)
// writeOmn_p(k)
// O_ret_pl_b()
// O_ved_narabot()
// O_vr_kol_nar() - врачи/техники + количество нарядов
// inputNorpozic(r,c,fl_max)
// pl_ordogovor()
// pl_or2dogovor(tip_jurn)
// oo_spmater()
// oo1spmater()
// f1_forma_30_prn_na(par,title)
// cre_tmp_30(adbf)
// get_nastr_orto_f30()
// f1_forma_30_na(par,title)
// forma_30_na(tip)
// write_f30(ar)
// ___f_30(k)
// yes_f_30(par1)
// forma_30all(tip_f30)
// or_vozvrat()
//**************************************************************************
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static f30_nastr := "f30_nast.ini"
Static f30_sect := "Форма 30 - "

// 

// 13.11.18
Function sin_ysl()

  Local buf := save_row( MaxRow() ), fl := .f.
  Private rr := T_ROW, fl_found := .f., reg_klient := 1

  mywait()
  If r_use( dir_server() + "tip_orto",, "TO" )
    Go Top
    alpha_browse( rr, 27, MaxRow() -2, 70, "f1edit_ort", color0,,,,,,, "f2edit_ort",, {,,, "N/BG,W+/N", .t., 200 } )
    to->( dbCloseArea() )
  Endif
  rest_box( buf )

  Return Nil

//
Function f1edit_ort( oBrow )

  Local blk := { { 1, 2 } }

  oBrow:addcolumn( TBColumnNew( Center( "Услуга", 40 ), {|| to->name } ) )
  //
  status_key( "^<Esc>^ - выход; ^<Ctrl+Enter>^ - редактирование" )

  Return Nil

//
Function f2edit_ort( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), buf1, fl := .f., rec, ;
    mkod, t_arr

  Do Case
  Case nKey == K_CTRL_RET
    mkod := RecNo()
    Private big_kod := mkod
    vvod_tor_ysl()
    Select To
    oBrow:gotop()
    Goto ( mkod )
    flag := 0
  Otherwise
    Keyboard ""
  Endcase

  Return flag

// 

// 13.03.19
Function vvod_tor_ysl()

  Local buf := save_row( MaxRow() ), fl := .f.
  Private rr := T_ROW, fl_found := .f., reg_klient := 1

  // if glob_mo[_MO_KOD_TFOMS] == '395301' // Камышин СТОМ
  // str_find := STR(big_kod,6)
  // else
  str_find := Str( big_kod, 4 )
  // endif
  muslovie := "kod_tip==big_kod"
  arr_blk := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find ) }, ;
    {| n| skippointer( n, muslovie ) }, ;
    str_find, muslovie;
    }
  If glob_mo[ _MO_KOD_TFOMS ] == '395301' // Камышин СТОМ
    r_use( dir_server() + "mo_su", { dir_server() + "mo_su", ;
      dir_server() + "mo_sush" }, "USL" )
    g_use( dir_server() + "ortoped2", dir_server() + "ortoped2", "ORTO2" ) // 19.04
    Set Relation To Str( kod_usl, 6 ) into USL
  Else
    r_use( dir_server() + "uslugi", { dir_server() + "uslugi", ;
      dir_server() + "uslugish" }, "USL" )
    g_use( dir_server() + "ortoped2", dir_server() + "ortoped2", "ORTO2" ) // 19.04
    Set Relation To Str( kod_usl, 4 ) into USL
  Endif
  find ( str_find )
  If !( fl_found := Found() )
    Keyboard Chr( K_INS )
  Endif
  alpha_browse( 5, 5, MaxRow() -2, 73, "ff1edit_ysl", color0,,,,, arr_blk,, "ff2edit_ysl",, {,,, "N/BG,W+/N", .t., 200 } )
  usl->( dbCloseArea() )
  orto2->( dbCloseArea() )
  rest_box( buf )

  Return Nil

//
Function ff1edit_ysl( oBrow )

  Local blk := { { 1, 2 } }

  oBrow:addcolumn( TBColumnNew( Center( to->name, 65 ), {|| usl->shifr + " " + PadR( usl->name, 56 ) } ) )
  //
  status_key( "^<Esc>^ - выход;  ^<Enter>^ - редактирование;  ^<Ins>^ - добавление;  ^<Del>^ - удаление" )

  Return Nil

//
Function ff2edit_ysl( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), buf1, fl := .f., rec, ;
    mkod, t_arr

  Do Case
  Case nKey == K_INS .or. nKey == K_ENTER
    If nKey == K_INS
      ColorWin( 8, 6, 8, 72, "N/N", "W+/N" )
      ColorWin( 8, 6, 8, 72, "N/N", "W+/B" )
    Endif
    mkod := RecNo()
    str_sem := "Редактирование состава услуги"
    If !g_slock( str_sem )
      Return func_error( 4, err_slock() )
    Endif
    buf1 := box_shadow( 9, 5, 14, 75, color8, ;
      if( nKey == K_INS, "Добавление новой услуги", ;
      "Редактирование услуги" ), cDataPgDn )
    Private mu_kod := if( nKey == K_INS, 0, orto2->kod_usl ), ;
      mshifr := if( nKey == K_INS, Space( 10 ), usl->shifr ), ;
      mname_u := if( nKey == K_INS, Space( 65 ), usl->name )
    SetColor( cDataCGet )
    @ 11, 7 Say "Шифр услуги из ОРТОПЕДИИ / ОМС" Get mshifr Pict "@!" ;
      when {| g| fore_o_kusl( g, 1, 2 ) } ;
      valid {| g| fore_o_kusl( g, 2, 2 ) }
    @ 12, 7 Say "Услуга" Get mname_u Pict "@S55" When .f.
    myread()
    Select orto2
    Goto ( mkod )
    If LastKey() != K_ESC .and. f_esc_enter( 1 )
      If nKey == K_INS
        Append Blank
        orto2->kod_tip := big_kod
      Else
        g_rlock( forever )
      Endif
      orto2->kod_usl := mu_kod
      Unlock
      Commit
    Endif
    g_sunlock( str_sem )
    If nKey == K_INS
      Go Top
      oBrow:gotop()
      Goto ( mkod )
    Endif
    Select orto2
    rest_box( buf ) ; rest_box( buf1 ) ; flag := 0
  Case nKey == K_DEL .and. f_esc_enter( 2 )
    Select ORTO2
    g_rlock( forever )
    deleterec()
    oBrow:gotop()
    flag := 0
  Otherwise
    Keyboard ""
  Endcase

  Return flag

// 

//
Function fore_o_kusl( get, when_valid, k )

  Local fl := .t., s, old_kod

  If when_valid == 1    // when
    If k == 2     // Шифр услуги
      If !Empty( mshifr )
        fl := .f.
      Endif
    Endif
  Else                  // valid
    If k == 2 // Шифр услуги
      If !Empty( mshifr ) .and. !( mshifr == get:original )
        mshifr := transform_shifr( mshifr )
        Select USL
        Set Order To 2
        find ( mshifr )
        If Found()
          mu_kod := usl->kod
          mname_u := usl->name
          update_gets()
        Else
          fl := func_error( 4, "Такого шифра нет в базе данных услуг." )
        Endif
        Set Order To 1
      Endif
    Endif
    If !fl
      &( ReadVar() ) := get:original
    Endif
  Endif

  Return fl

// 

//
Function mt_use_base( k )

  Local fl := .t.

  k := Lower( k )
  Do Case
  Case k == "ortoped"
    fl := g_use( dir_server() + "ortoped" )
  Case k == "ortoped1"
    fl := g_use( dir_server() + "ortoped1" )
  Case k == "tip_orto"
    fl := g_use( dir_server() + "tip_orto" )
  Endcase

  Return fl

// 

// 13.11.18
Function mt_r_use_base( k )

  Local fl := .t.

  k := Lower( k )
  Do Case
  Case k == "ortoped"
    fl := r_use( dir_server() + "ortoped" )
  Case k == "ortoped1"
    fl := r_use( dir_server() + "ortoped1" )
  Case k == "tip_orto"
    fl := r_use( dir_server() + "tip_orto" )
  Endcase

  Return fl

//
Function ort_boln( par1 )

  Local arr, arr_title, reg_print, sh, HH := 58, buf, s, s1, s2, fl, j, ;
    begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "orto_b1.txt", ;
    mperso, i, k

  Default par1 To ""
  If ( pr_pl_bes := o_ret_pl_b() ) == 0
    Return Nil
  Endif
  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  begin_date := arr[ 5 ]
  end_date := arr[ 6 ]
  buf := save_row( MaxRow() )
  If eq_any( par1, "vr", "tehn" )
    If ( mperso := input_kperso() ) == Nil  // ==> весь персонал
      mywait()
      mperso := {}
      r_use( dir_server() + "mo_pers",, "perso" )
      Go Top
      Do While !Eof()
        If perso->kod > 0
          AAdd( mperso, { perso->kod, "" } )
        Endif
        Skip
      Enddo
      perso->( dbCloseArea() )
    Endif
    dbCreate( cur_dir() + "tmp1", { ;
      { "KOD",        "N",      4,      0 }, ;  // код персонала
    { "FIO",        "C",     50,      0 }, ;  // Ф.И.О.
    { "STOIM_B",    "N",     12,      2 }, ;  // бесплатная стоимость лечения
    { "STOIM_P",    "N",     12,      2 }, ;  // платная стоимость лечения
    { "STOIM_N",    "N",     12,      2 } ;  // стоимость напыления
    } )
    Use ( cur_dir() + "tmp1" ) new
    Index On Str( kod, 4 ) to ( cur_dir() + "tmp1" )
  Endif
  musluga := AllTrim( mem_ort_na )
  If Empty( musluga ) .or. musluga == "*"
    musluga := "9999999999"
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  dbCreate( cur_dir() + "tmp", { ;
    { "KOD",        "N",      4,      0 }, ;  // код по БД tmp1
  { "KOD_H",      "N",      7,      0 }, ;  // код по БД hum_ort
  { "FIO",        "C",     50,      0 }, ;  // Ф.И.О. больного
  { "ADRES",      "C",     50,      0 }, ;  // адрес больного
  { "N_NAR",      "N",      5,      0 }, ;  // номер наряда
  { "N_DATA",     "D",      8,      0 }, ;  // дата начала лечения
  { "K_DATA",     "D",      8,      0 }, ;  // дата окончания лечения
  { "STOIM_B",    "N",     12,      2 }, ;  // бесплатная стоимость лечения
  { "STOIM_P",    "N",     12,      2 }, ;  // платная стоимость лечения
  { "STOIM_N",    "N",     12,      2 }, ;  // стоимость напыления
  { "KOL_POS",    "N",      2,      0 };   // количество посещений
  } )
  Use ( cur_dir() + "tmp" ) new
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "mo_pers",, "PERSO" )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
  Set Relation To u_kod into USL
  r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
  Set Relation To kod_k into KART
  dbSeek( DToS( begin_date ), .t. )
  Do While human->k_data <= end_date .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    s1 := s2 := s3 := 0
    Select HU
    find ( Str( human->( RecNo() ), 7 ) )
    Do While hu->kod == human->( RecNo() ) .and. !Eof()
      If hu->tip_usl != OU_B_PLAT  // платная услуга
        s2 += hu->stoim
      Else
        s1 += hu->stoim
      Endif
      If Like( musluga, usl->shifr )
        s3 += hu->stoim  // напыление
      Endif
      Skip
    Enddo
    fl := .f. ; s1 := Round( s1, 2 ) ; s2 := Round( s2, 2 ) ; s3 := Round( s3, 2 )
    Do Case
    Case pr_pl_bes == 1  // платные
      // fl := empty(s1) .and. !empty(s2)
      fl := !Empty( s2 )
    Case pr_pl_bes == 2  // бесплатные
      fl := !Empty( s1 )
    Case pr_pl_bes == 3  // все
      fl := !emptyall( s1, s2 )
    Endcase
    If fl
      If eq_any( par1, "vr", "tehn" )
        mkod := if( par1 == "vr", human->kod_vr, human->kod_as )
        If ( fl := ( mkod > 0 .and. AScan( mperso, {| x| x[ 1 ] == mkod } ) > 0 ) )
          Select TMP1
          find ( Str( mkod, 4 ) )
          If !Found()
            Append Blank
            tmp1->kod := mkod
            Select PERSO
            Goto ( mkod )
            tmp1->fio := perso->fio
          Endif
          tmp1->STOIM_B += s1
          tmp1->STOIM_P += s2
          tmp1->STOIM_N += s3
        Endif
      Endif
      If fl
        Select TMP
        Append Blank
        If eq_any( par1, "vr", "tehn" )
          tmp->kod := tmp1->kod
        Endif
        tmp->FIO := kart->fio
        tmp->ADRES := kart->adres
        tmp->KOD_H := human->( RecNo() )
        tmp->N_NAR := human->nar_z
        tmp->N_DATA := human->n_data
        tmp->K_DATA := human->k_data
        tmp->STOIM_B := s1
        tmp->STOIM_P := s2
        tmp->STOIM_N := s3
        tmp->KOL_POS := human->kol_pos
        If tmp->( LastRec() ) % 5000 == 0
          tmp->( dbCommit() )
        Endif
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    Return Nil
  Endif
  If j == 0
    Return func_error( 4, "Нет сведений!" )
  Endif
  mywait()
  //
  arr_title := { ;
    "──────────────────────────────┬─────┬────────┬────────┬──────", ;
    "                              │Наряд│  Дата  │  Дата  │Кол-во", ;
    "           Ф.И.О.             │заказ│нач.леч.│ ок.леч.│посещ.", ;
    "──────────────────────────────┴─────┴────────┴────────┴──────" }
  reg_print := 3
  If pr_pl_bes == 1
    arr_title[ 1 ] += "┬───────────"
    arr_title[ 2 ] += "│   Сумма   "
    arr_title[ 3 ] += "│  лечения  "
    arr_title[ 4 ] += "┴───────────"
  Else
    arr_title[ 1 ] += "┬────────┬──────────┬────────"
    arr_title[ 2 ] += "│Бесплат.│ Платная  │ в т.ч. "
    arr_title[ 3 ] += "│сумма л.│сумма леч.│напыл-ие"
    arr_title[ 4 ] += "┴────────┴──────────┴────────"
  Endif
  arr_title[ 1 ] += "┬──────────────────────────────"
  arr_title[ 2 ] += "│                              "
  arr_title[ 3 ] += "│        Список услуг          "
  arr_title[ 4 ] += "┴──────────────────────────────"
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Статистика по пролеченным больным", sh ) )
  If par1 == "vr"
    add_string( Center( "[ по лечащим врачам ]", sh ) )
  Elseif par1 == "tehn"
    add_string( Center( "[ по зубным техникам ]", sh ) )
  Endif
  add_string( Center( arr[ 4 ], sh ) )
  add_string( Center( pr_titul, sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
  Set Relation To u_kod into USL
  If eq_any( par1, "vr", "tehn" )
    Use ( cur_dir() + "tmp" ) new
    Index On Str( kod, 4 ) + Upper( fio ) to ( cur_dir() + "tmp" )
    Use ( cur_dir() + "tmp1" ) new
    Index On Upper( fio ) to ( cur_dir() + "tmp1" )
    Go Top
    Do While !Eof()
      s := PadR( Space( 4 ) + "[" + lstr( tmp1->kod ) + "]  " + Upper( tmp1->fio ), 61 )
      If pr_pl_bes == 1
        s += put_kope( tmp1->stoim_p, 12 )
      Else
        s += put_kope( tmp1->stoim_b, 9 ) + ;
          put_kope( tmp1->stoim_p, 11 ) + ;
          put_kope( tmp1->stoim_n, 9 )
      Endif
      If verify_ff( HH - 3, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( s )
      add_string( Space( 4 ) + Replicate( ".", sh - 4 ) )
      Select TMP
      find ( Str( tmp1->kod, 4 ) )
      Do While tmp->kod == tmp1->kod
        s := Left( tmp->fio, 30 ) + PadC( lstr( tmp->n_nar ), 7 ) + ;
          date_8( tmp->n_data ) + " " + date_8( tmp->k_data ) + ;
          PadC( lstr( tmp->kol_pos ), 7 )
        If pr_pl_bes == 1
          s += put_kope( tmp->stoim_p, 12 )
        Else
          s += put_kope( tmp->stoim_b, 9 ) + ;
            put_kope( tmp->stoim_p, 11 ) + ;
            put_kope( tmp->stoim_n, 9 )
        Endif
        k := add_orto_usl( arr, tmp->kod_h )
        s += " " + arr[ 1 ]
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s )
        For i := 2 To k
          add_string( Space( sh - 30 ) + arr[ i ] )
        Next
        Skip
      Enddo
      add_string( Replicate( "─", sh ) )
      Select TMP1
      Skip
    Enddo
    Close databases
    If fl_exit
      add_string( Replicate( "*", sh ) )
      add_string( Expand( "ПРОЦЕСС ПРЕРВАН" ) )
    Endif
  Else
    s1 := s2 := s3 := 0
    Use ( cur_dir() + "tmp" ) new
    Index On Upper( fio ) to ( cur_dir() + "tmp" )
    Go Top
    Do While !Eof()
      s := Left( tmp->fio, 30 ) + PadC( lstr( tmp->n_nar ), 7 ) + ;
        date_8( tmp->n_data ) + " " + date_8( tmp->k_data ) + ;
        PadC( lstr( tmp->kol_pos ), 7 )
      If pr_pl_bes == 1
        s += put_kope( tmp->stoim_p, 12 )
      Else
        s += put_kope( tmp->stoim_b, 9 ) + ;
          put_kope( tmp->stoim_p, 11 ) + ;
          put_kope( tmp->stoim_n, 9 )
        s1 += tmp->stoim_b
        s3 += tmp->stoim_n
      Endif
      k := add_orto_usl( arr, tmp->kod_h )
      s += " " + arr[ 1 ]
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( s )
      s2 += tmp->stoim_p
      add_string( PadR( Space( 4 ) + tmp->adres, sh - 30 ) + arr[ 2 ] )
      For i := 3 To k
        add_string( Space( sh - 30 ) + arr[ i ] )
      Next
      Skip
    Enddo
    Close databases
    If fl_exit
      add_string( Replicate( "*", sh ) )
      add_string( Expand( "ПРОЦЕСС ПРЕРВАН" ) )
    Endif
    add_string( Replicate( "─", sh ) )
    If pr_pl_bes == 1
      s := put_kope( s2, 12 )
    Else
      s := put_kope( s1, 9 ) + put_kope( s2, 11 ) + put_kope( s3, 9 )
    Endif
    add_string( PadR( "Кол-во больных - " + lstr( j ), 25 ) + PadL( s, sh - 25 -31 ) )
  Endif
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

//
Function add_orto_usl( larr, lkod )

  Local i, k, s := "", arr := {}, tmp_select := Select()

  Select HU
  find ( Str( lkod, 7 ) )
  Do While hu->kod == lkod
    AAdd( arr, AllTrim( usl->shifr ) )
    Skip
  Enddo
  ASort( arr,,, {| x, y| fsort_usl( x ) < fsort_usl( y ) } )
  AEval( arr, {| x| s += x + "," } )
  If Len( s ) > 0
    s := Left( s, Len( s ) -1 )
  Endif
  k := perenos( larr, s, 30 )
  AEval( larr, {| x, i| larr[ i ] := Center( AllTrim( x ), 30 ) } )
  Select ( tmp_select )

  Return k

//
Function ort_oborot()

  Local arr, arr_title, reg_print, sh, HH := 38, buf, s, s1, s2, s3, fl, j, ;
    begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "orto_OB.txt", ;
    mperso, i, k, s4, s5, s11, s21, s31, s41, s51

  If ( pr_pl_bes := o_ret_pl_b() ) == 0
    Return Nil
  Endif
  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  begin_date := arr[ 5 ]
  end_date := arr[ 6 ]
  buf := save_row( MaxRow() )
  musluga := AllTrim( mem_ort_na )
  If Empty( musluga ) .or. musluga == "*"
    musluga := "9999999999"
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  dbCreate( cur_dir() + "tmp", { ;
    { "KOD",        "N",      4,      0 }, ;  // код по БД tmp1
  { "KOD_H",      "N",      7,      0 }, ;  // код по БД hum_ort
  { "FIO",        "C",     50,      0 }, ;  // Ф.И.О. больного
  { "N_NAR",      "N",      5,      0 }, ;  // номер наряда
  { "N_DATA",     "D",      8,      0 }, ;  // дата начала лечения
  { "K_DATA",     "D",      8,      0 }, ;  // дата окончания лечения
  { "STOIM_P",    "N",     12,      2 }, ;  // платная стоимость лечения
  { "STOIM_N",    "N",     12,      2 }, ;  // стоимость напыления
  { "OPLATA",     "N",     12,      2 }, ;  // оплаченая сумма
  { "OPLATA_N",   "N",     12,      2 }, ;   // оплаченая сумма напыление
  { "D_STOIM_P",  "N",     12,      2 }, ;  // платная стоимость лечения
  { "D_STOIM_N",  "N",     12,      2 }, ;  // стоимость напыления
  { "D_OPLATA",   "N",     12,      2 }, ;  // оплаченая сумма
  { "D_OPLATA_N", "N",     12,      2 };   // оплаченая сумма напыление
  } )
  Use ( cur_dir() + "tmp" ) new
  r_use( dir_server() + "hum_oro", dir_server() + "hum_oro", "HO" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "mo_pers",, "PERSO" )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
  Set Relation To u_kod into USL
  r_use( dir_server() + "hum_ort",, "HUMAN" )
  Set Relation To kod_k into KART
  Go Top
  Do While !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    fl := .t.
    Do Case
    Case pr_pl_bes == 1  // платные
      fl := ( human->tip_usl == 0 )
    Case pr_pl_bes == 2  // бесплатные
      fl := ( human->tip_usl == 1 )
    Endcase
    If fl
      s1 := s2 := s3 := s4 := s5 := 0
      s11 := s21 := s31 := s41 := s51 := 0
      // Дебет - оказанные услуги попадают только при закрытии
      // т.к. наряд может быть откорректирован
      If Between( human->k_data, begin_date, end_date )
        // услуги в диапазоне закрытия
        Select HU
        find ( Str( human->( RecNo() ), 7 ) )
        Do While hu->kod == human->( RecNo() ) .and. !Eof()
          If Like( musluga, usl->shifr )
            s31 += hu->stoim  // напыление
          Elseif eq_any( hu->tip_usl, 0, 2 )  // платная услуга
            s21 += hu->stoim
          Endif
          Skip
        Enddo
      Elseif !Empty( human->k_data ) .and. human->k_data < begin_date
        // закрыт до текущего периода
        Select HU
        find ( Str( human->( RecNo() ), 7 ) )
        Do While hu->kod == human->( RecNo() ) .and. !Eof()
          If Like( musluga, usl->shifr )
            s3 += hu->stoim  // напыление
          Elseif eq_any( hu->tip_usl, 0, 2 )  // платная услуга
            s2 += hu->stoim
          Endif
          Skip
        Enddo
      Endif
      // оплата всегда
      Select HO
      find ( Str( human->( RecNo() ), 7 ) )
      Do While ho->kod == human->( RecNo() ) .and. !Eof()
        If Empty( ho->kv_cia )
          // s3 += ho->cena_opl  // бесплатно
        Else
          If ho->tip_opl == 2
            If Between( c4tod( ho->pdate ), begin_date, end_date )
              s51 += ( ho->cena_opl - ho->sum_voz )  // напыление
            Elseif c4tod( ho->pdate ) < begin_date
              s5 += ho->cena_opl  // напыление
            Endif
          Else
            If Between( c4tod( ho->pdate ), begin_date, end_date )
              s41 += ( ho->cena_opl - ho->sum_voz )  // платно
            Elseif c4tod( ho->pdate ) < begin_date
              s4 += ( ho->cena_opl - ho->sum_voz )  // платно
            Endif
          Endif
        Endif
        Skip
      Enddo
      s2 := Round( s2, 2 ) ; s3 := Round( s3, 2 )
      s4 := Round( s4, 2 ) ; s5 := Round( s5, 2 )
      If human->k_data >= begin_date .or. ( ( s2 + s3 ) != ( s4 + s5 ) .and. human->k_data < begin_date );
          .or. s21 != 0 .or. s31 != 0 .or. s41 != 0 .or. s51 != 0
        Select TMP
        Append Blank
        tmp->FIO := kart->fio
        tmp->KOD_H := human->( RecNo() )
        tmp->N_NAR := human->nar_z
        tmp->N_DATA := human->n_data
        tmp->K_DATA := human->k_data
        tmp->STOIM_P  := s2
        tmp->STOIM_N  := s3
        tmp->OPLATA   := s4
        tmp->OPLATA_N := s5
        tmp->D_STOIM_P  := s21
        tmp->D_STOIM_N  := s31
        tmp->D_OPLATA   := s41
        tmp->D_OPLATA_N := s51
        If tmp->( LastRec() ) % 5000 == 0
          tmp->( dbCommit() )
        Endif
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    Return Nil
  Endif
  If j == 0
    Return func_error( 4, "Нет сведений!" )
  Endif
  mywait()
  //
  arr_title := { ;
    "─────┬──────────────────────────────┬─────────────────────────────────┬─────────────────────────────────┬─────────────────────────────────", ;
    "Наряд│                              │__________Входное сальдо_________│____________Движение_____________│________Выходное сальдо__________", ;
    "заказ│           Ф.И.О.             │ Сделано│Напылен│Оплачено│Напылен│ Сделано│Напылен│Оплачено│Напылен│ Сделано│Напылен│Оплачено│Напылен", ;
    "─────┴──────────────────────────────┴────────┴───────┴────────┴───────┴────────┴───────┴────────┴───────┴────────┴───────┴────────┴───────" }
  reg_print := 3
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Оборотная ведомость по пролеченным больным", sh ) )
  add_string( Center( arr[ 4 ], sh ) )
  add_string( Center( pr_titul, sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  s1 := s2 := s3 := s4 := s5 := 0
  s11 := s21 := s31 := s41 := s51 := 0
  s6 := s7 := s8 := s9 := 0
  Use ( cur_dir() + "tmp" ) new
  Index On n_nar to ( cur_dir() + "tmp" )
  Go Top
  j := 1
  Do While !Eof()
    s := PadC( lstr( tmp->n_nar ), 6 ) + Left( tmp->fio, 30 )
    s += put_kope( tmp->stoim_p, 9 ) + ;
      put_kope( tmp->stoim_n, 8 ) + ;
      put_kope( tmp->oplata, 9 ) + ;
      put_kope( tmp->oplata_n, 8 )
    s += put_kope( tmp->d_stoim_p, 9 ) + ;
      put_kope( tmp->d_stoim_n, 8 ) + ;
      put_kope( tmp->d_oplata, 9 ) + ;
      put_kope( tmp->d_oplata_n, 8 )
    t1 := t2 := t3 := t4 := 0
    z := tmp->stoim_p + tmp->d_stoim_p - tmp->oplata - tmp->d_oplata
    If z > 0
      t1 := z
    Else
      t3 := z * ( -1 )
    Endif
    z := tmp->stoim_n + tmp->d_stoim_n - tmp->oplata_n - tmp->d_oplata_n
    If z > 0
      t2 := z
    Else
      t4 := z * ( -1 )
    Endif
    s += put_kope( t1, 9 ) + ;
      put_kope( t2, 8 ) + ;
      put_kope( t3, 9 ) + ;
      put_kope( t4, 8 )
    If !Empty( SubStr( s, 38 ) )
      add_string( s )
      ++j
    Endif
    s2 += tmp->stoim_p
    s3 += tmp->stoim_n
    s4 += tmp->oplata
    s5 += tmp->oplata_n
    s21 += tmp->d_stoim_p
    s31 += tmp->d_stoim_n
    s41 += tmp->d_oplata
    s51 += tmp->d_oplata_n
    s6 += t1
    s7 += t2
    s8 += t3
    s9 += t4
    If verify_ff( HH - 3, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    Skip
  Enddo
  Close databases
  If fl_exit
    add_string( Replicate( "*", sh ) )
    add_string( Expand( "ПРОЦЕСС ПРЕРВАН" ) )
  Endif
  add_string( Replicate( "─", sh ) )
  add_string( PadR( "Кол-во больных - " + lstr( j ), 30 + 5 ) + ;
    put_kop( s2, 10 ) + ;
    Space( 7 ) + ;
    put_kop( s4, 10 ) + ;
    Space( 7 ) + ;
    put_kop( s21, 10 ) + ;
    Space( 7 ) + ;
    put_kop( s41, 10 ) + ;
    Space( 7 ) + ;
    put_kop( s6, 10 ) + ;
    Space( 7 ) + ;
    put_kop( s8, 10 ) )
  add_string( Space( 30 + 6 ) + ;
    Space( 8 ) + ;
    put_kop( s3, 9 ) + ;
    Space( 8 ) + ;
    put_kop( s5, 9 ) + ;
    Space( 8 ) + ;
    put_kop( s31, 9 ) + ;
    Space( 8 ) + ;
    put_kop( s51, 9 ) + ;
    Space( 8 ) + ;
    put_kop( s7, 9 ) + ;
    Space( 8 ) + ;
    put_kop( s9, 9 ) )
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 

//
Function ort_diagnoz()

  Local arr, arr_title, reg_print := 2, sh, HH := 58, i, s, s1, s2, fl, ;
    begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "ort_diag.txt", ;
    adbf, arr_diag := {}, ob_kol := 0, t_arr[ 4 ], kol_bez := 0
  Local buf := save_row( MaxRow() )

  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  begin_date := arr[ 5 ]
  end_date := arr[ 6 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  r_use( dir_server() + "diag_ort", dir_server() + "diag_ort", "DIAG" )
  dbEval( {|| AAdd( arr_diag, { RecNo(), 0, shifr, name } ) } )
  adbf := { ;
    { "KOD",        "N",      4,      0 }, ;  // код персонала
  { "FIO",        "C",     50,      0 };  // Ф.И.О.
  }
  For i := 1 To Len( arr_diag )
    AAdd( adbf, { "diag" + lstr( arr_diag[ i, 1 ] ), "N", 5, 0 } )
  Next
  AAdd( adbf, { "diag999999", "N", 5, 0 } )
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod, 4 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "mo_pers",, "PERSO" )
  r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
  dbSeek( DToS( begin_date ), .t. )
  Do While human->k_data <= end_date .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If !Empty( human->kod_vr )
      If emptyall( human->kod_diag, human->kod_diag2, human->kod_diag3 )
        ++ob_kol
        Select TMP
        find ( Str( human->kod_vr, 4 ) )
        If !Found()
          Append Blank
          tmp->kod := human->kod_vr
          perso->( dbGoto( human->kod_vr ) )
          tmp->fio := perso->fio
        Endif
        tmp->diag999999++
        // arr_diag[k,2] ++
        ++kol_bez
      Else
        fl := .f.
        For i := 1 To 3
          Do Case
          Case i == 1
            pole := "human->kod_diag"
          Case i == 2
            pole := "human->kod_diag2"
          Case i == 3
            pole := "human->kod_diag3"
          Endcase
          If !Empty( &pole )
            Select DIAG
            find ( &pole )
            If Found() .and. ( k := AScan( arr_diag, {| x| x[ 1 ] == diag->( RecNo() ) } ) ) > 0
              If !fl
                ++ob_kol ; fl := .t.
              Endif
              Select TMP
              find ( Str( human->kod_vr, 4 ) )
              If !Found()
                Append Blank
                tmp->kod := human->kod_vr
                perso->( dbGoto( human->kod_vr ) )
                tmp->fio := perso->fio
              Endif
              pole1 := "tmp->diag" + lstr( diag->( RecNo() ) )
              &pole1 := &pole1 + 1
              arr_diag[ k, 2 ] ++
            Endif
          Endif
        Next
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    Return Nil
  Endif
  If j == 0
    Return func_error( 4, "Нет сведений!" )
  Endif
  mywait()
  ASort( arr_diag,,, {| x, y| x[ 3 ] < y[ 3 ] } )
  If kol_bez > 0
    AAdd( arr_diag, { 999999, kol_bez, "", "без указания диагноза" } )
  Endif
  //
  arr_title := { ;
    "──────────────────────────────", ;
    "                              ", ;
    "                              ", ;
    "        Ф.И.О. врача          ", ;
    "                              ", ;
    "                              ", ;
    "──────────────────────────────" }
  For i := 1 To Len( arr_diag )
    If arr_diag[ i, 2 ] > 0
      perenos( t_arr, arr_diag[ i, 4 ], 10 )
      arr_title[ 1 ] += "┬──────────"
      arr_title[ 2 ] += "│" + PadC( AllTrim( arr_diag[ i, 3 ] ), 10 )
      arr_title[ 3 ] += "│" + PadR( t_arr[ 1 ], 10 )
      arr_title[ 4 ] += "│" + PadR( t_arr[ 2 ], 10 )
      arr_title[ 5 ] += "│" + PadR( t_arr[ 3 ], 10 )
      arr_title[ 6 ] += "│" + PadR( t_arr[ 4 ], 10 )
      arr_title[ 7 ] += "┴──────────"
    Endif
  Next
  sh := Len( arr_title[ 1 ] )
  If sh <= 64
    sh := 64
    reg_print := 1
  Elseif sh <= 84
    reg_print := 2
  Elseif sh <= 120
    reg_print := 3
  Elseif sh <= 160
    reg_print := 2
  Else
    reg_print := 3
  Endif
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Статистика по диагнозам", sh ) )
  add_string( Center( arr[ 4 ], sh ) )
  Use ( cur_dir() + "tmp" ) new
  Index On Upper( fio ) to ( cur_dir() + "tmp" )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  Go Top
  Do While !Eof()
    s := PadR( tmp->fio, 30 )
    For i := 1 To Len( arr_diag )
      If arr_diag[ i, 2 ] > 0
        pole := "tmp->diag" + lstr( arr_diag[ i, 1 ] )
        s += put_val( &pole, 7 ) + Space( 4 )
      Endif
    Next
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( s )
    Skip
  Enddo
  Close databases
  If fl_exit
    add_string( Replicate( "*", sh ) )
    add_string( Expand( "ПРОЦЕСС ПРЕРВАН" ) )
  Endif
  add_string( Replicate( "═", sh ) )
  s := PadR( "Кол-во случаев: " + lstr( ob_kol ), 30 )
  For i := 1 To Len( arr_diag )
    If arr_diag[ i, 2 ] > 0
      s += put_val( arr_diag[ i, 2 ], 7 ) + Space( 4 )
    Endif
  Next
  add_string( s )
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 

// 11.02.13 Распечатка реестра по ДМС
Function o_dms_reestr()

  Local i, j, k, fl, fl_exit := .f., buf := save_row( MaxRow() ), ;
    t_arr[ BR_LEN ], blk, fl1 := .f., fl2 := .f., arr
  Private arr_m

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  dbCreate( cur_dir() + "tmp", { { "kod_k","N", 7, 0 }, ; // код больного по картотеке
  { "tip_usl", "N", 1, 0 }, ; // взаимозачет или добр.СМО
  { "pr_smo","N", 6, 0 }, ; // код предприятия / СМО
  { "nar_z","N", 5, 0 }, ; // наряд-заказ
  { "D_POLIS", "C", 25, 0 }, ; // полис
  { "N_DATA","D", 8, 0 }, ; // дата начала лечения
  { "K_DATA","D", 8, 0 }, ; // дата окончания лечения
  { "STOIM","N", 10, 2 } } ) // итоговая стоимость услуг
  Use ( cur_dir() + "tmp" ) new
  Index On Str( tip_usl, 1 ) + Str( pr_smo, 6 ) + Str( kod_k, 7 ) to ( cur_dir() + "tmp" )
  dbCreate( cur_dir() + "tmp2", { { "rec_tmp", "N", 6, 0 }, ;
    { "rec_hp","N", 7, 0 }, ;
    { "D_POLIS", "C", 25, 0 } } ) // полис
  Use ( cur_dir() + "tmp2" ) new
  r_use( dir_server() + "hum_oro", dir_server() + "hum_oro", "HO" )
  r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    arr := {} ; mpolis := ""
    Select HO
    find ( Str( human->( RecNo() ), 7 ) )
    Do While ho->kod == human->( RecNo() ) .and. !Eof()
      If eq_any( ho->tip_usl, OU_PR_VZ, OU_D_SMO )
        mpolis := ho->d_polis
        If ( j := AScan( arr, {| x| x[ 1 ] == ho->tip_usl .and. x[ 2 ] == ho->pr_smo } ) ) == 0
          AAdd( arr, { ho->tip_usl, ho->pr_smo, 0 } ) ; j := Len( arr )
        Endif
        arr[ j, 3 ] += ho->cena_opl
      Endif
      Skip
    Enddo
    For j := 1 To Len( arr )
      Select TMP
      find ( Str( arr[ j, 1 ], 1 ) + Str( arr[ j, 2 ], 3 ) + Str( human->kod_k, 7 ) )
      If !Found()
        Append Blank
        tmp->tip_usl := arr[ j, 1 ]
        tmp->pr_smo  := arr[ j, 2 ]
        tmp->kod_k   := human->kod_k
        tmp->n_data  := human->n_data
        tmp->k_data  := human->k_data
        tmp->d_polis := mpolis
      Endif
      If tmp->n_data > human->n_data
        tmp->n_data := human->n_data
      Endif
      If tmp->k_data < human->k_data
        tmp->k_data := human->k_data
      Endif
      tmp->nar_z := human->nar_z
      tmp->stoim += arr[ j, 3 ]
      //
      Select TMP2
      Append Blank
      tmp2->rec_tmp := tmp->( RecNo() )
      tmp2->rec_hp  := human->( RecNo() )
      tmp2->d_polis := mpolis
      If tmp2->( LastRec() ) % 5000 == 0
        Commit
      Endif
    Next
    Select HUMAN
    Skip
  Enddo
  j := tmp->( LastRec() )
  If !fl_exit .and. j > 0
    dbCreate( cur_dir() + "tmp1", { { "name","C", 30, 0 }, ; // наименование предприятия
    { "tip_usl", "N", 1, 0 }, ; // взаимозачет или добр.СМО
    { "pr_smo","N", 6, 0 }, ; // код предприятия / СМО
    { "KOL","N", 6, 0 }, ; // количество больных
    { "STOIM","N", 11, 2 } } ) // итоговая стоимость лечения
    r_use( dir_server() + "p_pr_vz",, "PRED" )
    r_use( dir_server() + "p_d_smo",, "SMO" )
    Use ( cur_dir() + "tmp1" ) new
    Index On Str( tip_usl, 1 ) + Str( pr_smo, 6 ) to ( cur_dir() + "tmp1" )
    Select TMP
    Go Top
    Do While !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      Select TMP1
      find ( Str( tmp->tip_usl, 1 ) + Str( tmp->pr_smo, 6 ) )
      If !Found()
        Append Blank
        tmp1->tip_usl := tmp->tip_usl
        tmp1->pr_smo  := tmp->pr_smo
        If tmp->tip_usl == OU_D_SMO
          smo->( dbGoto( tmp->pr_smo ) )
          tmp1->name := smo->name
          fl1 := .t.
        Else
          pred->( dbGoto( tmp->pr_smo ) )
          tmp1->name := pred->name
          fl2 := .t.
        Endif
        If tmp->pr_smo == 0
          tmp1->name := "...без выбора..."
        Endif
      Endif
      tmp1->kol++
      tmp1->stoim += tmp->stoim
      Select TMP
      Skip
    Enddo
    j := tmp1->( LastRec() )
    mywait()
    Select TMP2
    Index On Str( rec_tmp, 6 ) to ( cur_dir() + "tmp2" )
  Endif
  Close databases
  rest_box( buf )
  If fl_exit
    // ничего
  Elseif j == 0
    func_error( 4, "Нет сведений по ДМС и взаимозачету " + arr_m[ 4 ] )
  Else
    t_arr[ BR_TOP ] := T_ROW
    t_arr[ BR_BOTTOM ] := MaxRow() -2
    t_arr[ BR_LEFT ] := 11
    t_arr[ BR_RIGHT ] := 68
    t_arr[ BR_COLOR ] := color0
    t_arr[ BR_TITUL ] := arr_m[ 4 ]
    If fl1
      t_arr[ BR_TITUL ] += " (добр/страх.)"
    Endif
    If fl2
      t_arr[ BR_TITUL ] += " (в/зачет)"
    Endif
    t_arr[ BR_TITUL_COLOR ] := "BG+/GR"
    t_arr[ BR_ARR_BROWSE ] := {,,, "N/BG,W+/N,B/BG,W+/B", .t., 0 }
    blk := {|| iif( tip_usl == OU_D_SMO, { 1, 2 }, { 3, 4 } ) }
    t_arr[ BR_COLUMN ] := { { Center( "Наименование", 30 ), {|| tmp1->name }, blk }, ;
      { "Кол-во;больных", {|| Str( kol, 7 ) }, blk }, ;
      { "   Сумма;  лечения", {|| put_kop( stoim, 11 ) }, blk } }
    t_arr[ BR_EDIT ] := {| nk, ob| f1_ort_vzaim( nk, ob, "edit" ) }
    t_arr[ BR_STAT_MSG ] := {|| ;
      status_key( "^<Esc>^ - выход;  ^<Enter>^ - выбор для печати" ) }
    Use ( cur_dir() + "tmp1" ) new
    Index On Upper( name ) to ( cur_dir() + "tmp1" )
    Go Top
    edit_browse( t_arr )
    Close databases
    rest_box( buf )
  Endif

  Return Nil

// 

//
Function f1_ort_vzaim( nKey, oBrow, regim )

  Local ret := -1, buf, fl := .f., rec, t_arr[ BR_LEN ]

  If regim == "edit" .and. nKey == K_ENTER
    rec := tmp1->( RecNo() )
    buf := SaveScreen()
    mywait()
    t_arr[ BR_TOP ] := 2
    t_arr[ BR_BOTTOM ] := MaxRow() -2
    t_arr[ BR_LEFT ] := 2
    t_arr[ BR_RIGHT ] := 77
    t_arr[ BR_COLOR ] := color0
    If tmp1->tip_usl == OU_D_SMO
      glob_d_smo := { tmp1->pr_smo, AllTrim( tmp1->name ) }
      t_arr[ BR_TITUL ] := glob_d_smo[ 2 ] + " (добр/страх.) " + arr_m[ 4 ]
    Else
      glob_pr_vz := { tmp1->pr_smo, AllTrim( tmp1->name ) }
      t_arr[ BR_TITUL ] := glob_pr_vz[ 2 ] + " (в/зачет) " + arr_m[ 4 ]
    Endif
    t_arr[ BR_TITUL_COLOR ] := "B/BG"
    t_arr[ BR_ARR_BROWSE ] := {,,, "N/BG,W+/N,B/BG,W+/B", .t., 0 }
    n := 31
    t_arr[ BR_COLUMN ] := { { Center( "Ф.И.О.", n ), {|| PadR( kart->fio, n ) } }, ;
      { "Наряд", {|| Str( nar_z, 5 ) } }, ;
      { Center( "Срок лечения", 17 ), {|| date_8( n_data ) + "-" + date_8( k_data ) } }, ;
      { " Сумма", {|| put_kop( stoim, 10 ) } } }
    t_arr[ BR_EDIT ] := {| nk, ob| f2_ort_vzaim( nk, ob, "edit" ) }
    t_arr[ BR_STAT_MSG ] := {|| ;
      status_key( "^<Esc>^ - выход;  ^<Enter>^ - выбор для печати;  ^<F9>^ - печать реестра" ) }
    mywait()
    Use ( cur_dir() + "tmp2" ) index ( cur_dir() + "tmp2" ) new
    r_use( dir_server() + "kartotek",, "KART" )
    Use ( cur_dir() + "tmp" ) New Alias TMP
    Set Relation To kod_k into KART
    Index On Upper( kart->fio ) to ( cur_dir() + "tmp" ) ;
      For tmp1->tip_usl == tmp->tip_usl .and. tmp1->pr_smo == tmp->pr_smo
    edit_browse( t_arr )
    Close databases
    RestScreen( buf )
    Use ( cur_dir() + "tmp1" ) index ( cur_dir() + "tmp1" ) new
    Goto ( rec )
  Endif

  Return ret

// 

//
Function f2_ort_vzaim( nKey, oBrow, regim )

  Local ret := -1, buf, fl := .f., rec, ;
    HH := 76, name_file := cur_dir() + "ortorees.txt"

  Do Case
  Case regim == "edit"
    Do Case
    Case nKey == K_F9
      rec := tmp->( RecNo() )
      orees2_vzaim( name_file )
      Select TMP
      Goto ( rec )
    Case nKey == K_ENTER
      ne_real()
    Endcase
  Endcase

  Return ret

// 

// 11.02.13
Function orees2_vzaim( name_file )

  Local buf := save_row( MaxRow() ), sh, HH := 57, arr_title, s, i, j, k, sk, ss, ;
    arr2title, reg_print := 6, afio[ 2 ], lfio := 19, kfio, lsk, lss

  mywait()
  arr_title := { ;
    "───┬───────────────────┬─────────────────┬────────┬──────────┬─────────────────────────────────────────────────────────────────┬─────┬───────┬────┬──────────┬───────────", ;
    "NN │       Ф.И.О.      │      Номер      │  Дата  │ Код мани-│                   Название медицинской услуги                   │Отде-│  Цена │Кол.│ Сумма за │ Примечание", ;
    "пп │  застрахованного  │   страхового    │оказания│ пуляции  │                                                                 │ление│ каждой│оказ│все кол-во│           ", ;
    "   │                   │    полиса и     │  мед.  │          │                                                                 │     │ услуги│ус- │оказ.услуг│           ", ;
    "   │                   │  сумма оплаты   │ услуги │          │                                                                 │     │ (руб.)│луг │  (руб.)  │           ", ;
    "───┴───────────────────┴─────────────────┴────────┴──────────┴─────────────────────────────────────────────────────────────────┴─────┴───────┴────┴──────────┴───────────" }
  arr2title := { ;
    "───┬───────────────────┬─────────────────┬────────┬──────────┬─────────────────────────────────────────────────────────────────┬─────┬───────┬────┬──────────┬───────────", ;
    " 1 │         2         │        3        │    4   │     5    │                              6                                  │  7  │   8   │ 9  │    10    │     11    ", ;
    "───┴───────────────────┴─────────────────┴────────┴──────────┴─────────────────────────────────────────────────────────────────┴─────┴───────┴────┴──────────┴───────────" }
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + "organiz",, "ORG" )
  add_string( AllTrim( org->name ) )
  org->( dbCloseArea() )
  If tmp1->tip_usl == OU_D_SMO
    add_string( Center( "Реестр N_____ оказанных медицинских услуг", sh ) )
    add_string( Center( "по полисам ДМС " + AllTrim( tmp1->name ), sh ) )
  Else
    add_string( Center( "Реестр платных услуг (взаимозачет)", sh ) )
    add_string( Center( "по предприятию: " + Upper( AllTrim( tmp1->name ) ), sh ) )
  Endif
  add_string( Center( arr_m[ 4 ], sh ) )
  r_use( dir_server() + "mo_otd",, "OTD" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "hum_oro", dir_server() + "hum_oro", "HO" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HPU" )
  r_use( dir_server() + "hum_ort",, "HP" )
  AEval( arr_title, {| x| add_string( x ) } )
  j := sk := ss := so := 0
  Select TMP
  Go Top
  Do While !Eof()
    arr := {} ; au := {}
    Select TMP2
    find ( Str( tmp->( RecNo() ), 6 ) )
    Do While tmp2->rec_tmp == tmp->( RecNo() ) .and. !Eof()
      Select HP
      Goto ( tmp2->rec_hp )
      Select HO
      find ( Str( hp->( RecNo() ), 7 ) )
      Do While ho->kod == hp->( RecNo() ) .and. !Eof()
        If tmp->tip_usl == ho->tip_usl
          If ( i := AScan( arr, {| x| x[ 1 ] == ho->d_polis } ) ) == 0
            AAdd( arr, { ho->d_polis, 0 } ) ; i := Len( arr )
          Endif
          arr[ i, 2 ] += ho->cena_opl
        Endif
        Skip
      Enddo
      Select HPU
      find ( Str( hp->( RecNo() ), 7 ) )
      Do While hpu->kod == hp->( RecNo() )
        If tmp->tip_usl == hpu->tip_usl
          otd->( dbGoto( hpu->otd ) )
          usl->( dbGoto( hpu->u_kod ) )
          AAdd( au, { c4tod( hpu->date_u ), ;
            usl->shifr, ;
            usl->name, ;
            otd->short_name, ;
            hpu->kol, ;
            hpu->stoim;
            } )
        Endif
        Select HPU
        Skip
      Enddo
      Select TMP2
      Skip
    Enddo
    lsk := lss := lso := 0
    kfio := perenos( afio, AllTrim( kart->fio ), lfio )
    kpolis := 0 ; apolis := {}
    For i := 1 To Len( arr )
      s := AllTrim( arr[ i, 1 ] )
      If Len( s ) <= 17
        AAdd( apolis, s )
        AAdd( apolis, lstr( arr[ i, 2 ], 10, 2 ) )
      Else
        AAdd( apolis, Left( s, 17 ) )
        AAdd( apolis, SubStr( s, 18 ) + "/" + lstr( arr[ i, 2 ], 10, 2 ) )
      Endif
      kpolis += 2
      lso += arr[ i, 2 ]
    Next
    ASort( au,,, {| x, y| iif( x[ 1 ] == y[ 1 ], fsort_usl( x[ 2 ] ) < fsort_usl( y[ 2 ] ), x[ 1 ] < y[ 1 ] ) } )
    ku := Len( au )
    For k := 1 To Max( kfio, kpolis, ku )
      If verify_ff( HH, .t., sh )
        AEval( arr2title, {| x| add_string( x ) } )
      Endif
      If k == 1
        s := PadR( lstr( ++j ) + ". ", 4 )
      Else
        s := Space( 4 )
      Endif
      If k <= kfio
        s += PadR( afio[ k ], lfio ) + " "
      Else
        s += Space( lfio + 1 )
      Endif
      If k <= kpolis
        s += PadC( AllTrim( apolis[ k ] ), 17 ) + " "
      Else
        s += Space( 17 + 1 )
      Endif
      If k <= ku
        s += date_8( au[ k, 1 ] ) + " " + ;
          au[ k, 2 ] + " " + ;
          au[ k, 3 ] + " " + ;
          au[ k, 4 ] + ;
          Str( au[ k, 6 ] / au[ k, 5 ], 8, 2 ) + ;
          Str( au[ k, 5 ], 5 ) + ;
          Str( au[ k, 6 ], 11, 2 )
        lsk += au[ k, 5 ]
        lss += au[ k, 6 ]
      Endif
      add_string( s )
    Next
    sk += lsk
    ss += lss
    so += lso
    add_string( PadL( Replicate( "-", sh - 24 ), sh ) )
    add_string( Space( 24 ) + ;
      PadC( lstr( lso, 11, 2 ), 17 ) + ;
      Space( 99 ) + ;
      Str( lsk, 6 ) + Str( lss, 11, 2 ) )
    add_string( "" )
    Select TMP
    Skip
  Enddo
  ho->( dbCloseArea() )
  hp->( dbCloseArea() )
  hpu->( dbCloseArea() )
  usl->( dbCloseArea() )
  otd->( dbCloseArea() )
  If verify_ff( HH - 5, .t., sh )
    AEval( arr2title, {| x| add_string( x ) } )
  Endif
  add_string( Replicate( "─", sh ) )
  add_string( PadL( "Итого : ", 24 ) + ;
    PadC( lstr( so, 11, 2 ), 17 ) + ;
    Space( 99 ) + ;
    Str( sk, 6 ) + Str( ss, 11, 2 ) )
  add_string( "" )
  add_string( "" )
  add_string( Center( "Главный бухгалтер _________________", sh ) )
  FClose( fp )
  rest_box( buf )
  Private yes_albom := .t.
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 
// 19.07.14
//
Function oo_proverka( k )

  Static si1 := 1, si2 := 1, si3 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "~Сравнение оплаты и услуг", "Врачи+техники" }
    mas_msg := { "Сравнение суммы оплаты и услуг по типу оплаты", ;
      "Сравнение врачей и техников в услугах наряда " }
    mas_fun := { "Oo_proverka(11)", "Oo_proverka(12)" }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    oo_1_proverka()
  Case k == 12
    oo_2_proverka()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// 

// Сравнение суммы оплаты и услуг по типу оплаты
Function oo_1_proverka()

  Local arr, arr_title, reg_print := 1, sh := 60, HH := 58, s, ;
    begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "orto_pro.txt", ;
    mperso, i, j := 0, k, buf := save_row( MaxRow() )

  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  begin_date := arr[ 5 ]
  end_date := arr[ 6 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Сравнение сумм оплаты и сумм услуг по типу оплаты", sh ) )
  add_string( Center( arr[ 4 ], sh ) )
  //
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "hum_oro", dir_server() + "hum_oro", "HO" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
  r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
  Set Relation To kod_k into KART
  dbSeek( DToS( begin_date ), .t. )
  Do While human->k_data <= end_date .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    su0 := su2 := su3 := so0 := so2 := so3 := 0
    Select HU
    find ( Str( human->( RecNo() ), 7 ) )
    Do While hu->kod == human->( RecNo() ) .and. !Eof()
      Do Case
      Case hu->tip_usl == OU_PLAT     // 0 платный больной
        su0 += hu->stoim
      Case hu->tip_usl == OU_PR_VZ    // 2 взаимозачет
        su2 += hu->stoim
      Case hu->tip_usl == OU_D_SMO    // 3 добровольное страхование
        su3 += hu->stoim
      Endcase
      Skip
    Enddo
    Select HO
    find ( Str( human->( RecNo() ), 7 ) )
    Do While ho->kod == human->( RecNo() ) .and. !Eof()
      Do Case
      Case ho->tip_usl == OU_PLAT     // 0 платный больной
        so0 += ho->cena_opl
      Case ho->tip_usl == OU_PR_VZ    // 2 взаимозачет
        so2 += ho->cena_opl
      Case ho->tip_usl == OU_D_SMO    // 3 добровольное страхование
        so3 += ho->cena_opl
      Endcase
      Skip
    Enddo
    su0 := round_5( su0, 2 )
    su2 := round_5( su2, 2 )
    su3 := round_5( su3, 2 )
    so0 := round_5( so0, 2 )
    so2 := round_5( so2, 2 )
    so3 := round_5( so3, 2 )
    If !( su0 == so0 .and. su2 == so2 .and. su3 == so3 )
      ++j
      verify_ff( HH - 4, .t., sh )
      add_string( "" )
      add_string( "Наряд заказ N " + PadR( lstr( human->nar_z ), 5 ) + " " + ;
        date_8( human->n_data ) + "-" + date_8( human->k_data ) )
      add_string( " " + AllTrim( kart->fio ) )
      If !( su0 == so0 )
        verify_ff( HH, .t., sh )
        add_string( "  платные: услуги=" + lstr( su0, 9, 2 ) + ", оплата=" + lstr( so0, 9, 2 ) )
      Endif
      If !( su2 == so2 )
        verify_ff( HH, .t., sh )
        add_string( "  в/зачет: услуги=" + lstr( su2, 9, 2 ) + ", оплата=" + lstr( so2, 9, 2 ) )
      Endif
      If !( su3 == so3 )
        verify_ff( HH, .t., sh )
        add_string( "  ДМС    : услуги=" + lstr( su3, 9, 2 ) + ", оплата=" + lstr( so3, 9, 2 ) )
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  Close databases
  If j > 0 .and. fl_exit
    add_string( Replicate( "*", sh ) )
    add_string( Expand( "ПРОЦЕСС ПРЕРВАН" ) )
  Endif
  rest_box( buf )
  FClose( fp )
  If j == 0
    stat_msg( "Расхождений не найдено!" ) ; mybell( 2, OK )
  Else
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif

  Return Nil

// 

// 16.04.15
// Сравнение суммы оплаты и услуг по типу оплаты
Function oo_2_proverka()

  Local arr, arr_title, reg_print := 1, sh := 60, HH := 58, s, ;
    begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "orto_pro.txt", ;
    mperso, i, j := 0, k, buf := save_row( MaxRow() ), flag_VR

  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  begin_date := arr[ 5 ]
  end_date := arr[ 6 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  Private flag_1 := .t., arr_uva := {}, vr_uva := .t., as_uva := .t., ms_uva := .t., ;
    mshifr := Space( 10 )
  r_use( dir_server() + "orto_uva",, "OU" )
  dbEval( {|| AAdd( arr_uva, { AllTrim( ou->shifr ), ou->kod_vr, ou->kod_as, ou->kod_ms } ) } )
  ou->( dbCloseArea() )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Сравнение врачей и техников в наряде и услугах", sh ) )
  add_string( Center( arr[ 4 ], sh ) )
  //
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "mo_pers",, "PERS" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "hum_oro", dir_server() + "hum_oro", "HO" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
  r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
  Set Relation To kod_k into KART
  dbSeek( DToS( begin_date ), .t. )
  Do While human->k_data <= end_date .and. !Eof()
    flag_vr := .f.
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    mm_vr  := human->kod_vr
    mm_teh := human->kod_as
    Select HU
    find ( Str( human->( RecNo() ), 7 ) )
    Do While hu->kod == human->( RecNo() ) .and. !Eof()
      vr_uva := .t.
      as_uva := .t.
      ms_uva := .t.
      Select USL
      Goto ( hu->u_kod )
      mshifr := usl->shifr
      verify_o_uva()
      Select HU
      If vr_uva
        If hu->kod_vr != human->kod_vr
          flag_vr := .t.
        Endif
      Endif
      If as_uva
        If hu->kod_as != human->kod_as
          flag_vr := .t.
        Endif
      Endif
      If !ms_uva
        If !Empty( hu->kod_ms )
          flag_vr := .t.
        Endif
      Else
        If Empty( hu->kod_ms )
          flag_vr := .t.
        Endif
      Endif
      Skip
    Enddo
    If flag_vr
      ++j
      verify_ff( HH - 4, .t., sh )
      add_string( "" )
      add_string( "Наряд заказ N " + PadR( lstr( human->nar_z ), 5 ) + " " + ;
        date_8( human->n_data ) + "-" + date_8( human->k_data ) )
      add_string( " " + AllTrim( kart->fio ) )
      verify_ff( HH, .t., sh )
      Select PERS
      Goto human->kod_vr
      add_string( "Врач в наряде   " + pers->fio )
      verify_ff( HH, .t., sh )
      Goto human->kod_as
      add_string( "Техник в наряде " + pers->fio )
      Select HU
      find ( Str( human->( RecNo() ), 7 ) )
      Do While hu->kod == human->( RecNo() ) .and. !Eof()
        verify_ff( HH, .t., sh )
        Select USL
        Goto hu->u_kod
        add_string( "Услуга " + AllTrim( usl->shifr ) + " " + usl->name )
        Select PERS
        Goto hu->kod_vr
        add_string( "   Врач в услуге   " + pers->fio )
        verify_ff( HH, .t., sh )
        Goto hu->kod_as
        add_string( "   Техник в услуге " + pers->fio )
        verify_ff( HH, .t., sh )
        Goto hu->kod_ms
        add_string( "   Медсестра в наряде " + pers->fio )
        Select HU
        Skip
      Enddo
    Endif
    Select HUMAN
    Skip
  Enddo
  Close databases
  If j > 0 .and. fl_exit
    add_string( Replicate( "*", sh ) )
    add_string( Expand( "ПРОЦЕСС ПРЕРВАН" ) )
  Endif
  rest_box( buf )
  FClose( fp )
  If j == 0
    stat_msg( "Расхождений не найдено!" ) ; mybell( 2, OK )
  Else
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif

  Return Nil

// 

//
Function ort_den_sr( par )

  Local arr, arr_title, reg_print, sh, HH := 77, buf, s, s1, s2, fl, j, ;
    begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "orto_den.txt", ;
    mperso, i, k, muslovie := ".t.", s3, s4, s5

  If ( pr_pl_bes := o_ret_pl_b() ) == 0
    Return Nil
  Endif
  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  begin_date := arr[ 5 ]
  end_date := arr[ 6 ]
  buf := save_row( MaxRow() )
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  dbCreate( cur_dir() + "tmp", { ;
    { "KOD_H",      "N",      7,      0 }, ;  // код по БД hum_ort
  { "DATA",       "D",      8,      0 }, ;  // дата наряда
  { "N_NAR",      "N",      5,      0 }, ;  // номер наряда
  { "STOIM",      "N",     12,      2 }, ;   // сумма оплаты
  { "STOIM_P",    "N",     12,      2 }, ;  // сумма оплаты платно
  { "STOIM_B",    "N",     12,      2 }, ;  // сумма оплаты бесплатно
  { "STOIM_N",    "N",     12,      2 };   // сумма оплаты напыление
  } )
  Use ( cur_dir() + "tmp" ) new
  Do Case
  Case pr_pl_bes == 1  // платные
    muslovie := "human->tip_usl != 1"
  Case pr_pl_bes == 2  // бесплатные
    muslovie := "human->tip_usl == 1"
  Endcase
  Do Case
  Case par == 1
    r_use( dir_server() + "hum_oro", dir_server() + "hum_oro", "HO" )
    r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
    dbSeek( DToS( begin_date ), .t. )
    Do While human->k_data <= end_date .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      if &muslovie
        s1 := 0 ; s3 := 0 ; s4 := 0 ; s5 := 0
        Select HO
        find ( Str( human->( RecNo() ), 7 ) )
        Do While ho->kod == human->( RecNo() ) .and. !Eof()
          s1 += ho->cena_opl
          If pr_pl_bes == 1  // платные
            If ho->tip_opl == 2
              s5 += ho->cena_opl // напыление
            Else
              s4 += ho->cena_opl // платно
            Endif
          Elseif pr_pl_bes == 2 .or. pr_pl_bes == 3 // бесплатные
            If emptyall( ho->n_kvit, ho->kv_cia )
              s3 += ho->cena_opl  // бесплатно
            Else
              If ho->tip_opl == 2
                s5 += ho->cena_opl  // напыление
              Else
                s4 += ho->cena_opl  // платно
              Endif
            Endif
          Endif
          Skip
        Enddo
        s1 := Round( s1, 2 )
        If !Empty( s1 )
          Select TMP
          Append Blank
          tmp->KOD_H := human->( RecNo() )
          tmp->N_NAR := human->nar_z
          tmp->STOIM := s1
          tmp->STOIM_P := s4
          tmp->STOIM_B := s3
          tmp->STOIM_N := s5
          If tmp->( LastRec() ) % 5000 == 0
            Commit
          Endif
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
  Case par == 2
    r_use( dir_server() + "hum_oro", dir_server() + "hum_oro", "HO" )
    r_use( dir_server() + "hum_ort", dir_server() + "hum_orto", "HUMAN" )
    dbSeek( DToS( begin_date ), .t. )
    Do While human->data <= end_date .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      if &muslovie .and. iif( is_open, Empty( human->k_data ), .t. )
        s1 := 0 ; s3 := 0 ; s4 := 0 ; s5 := 0
        Select HO
        find ( Str( human->( RecNo() ), 7 ) )
        Do While ho->kod == human->( RecNo() ) .and. !Eof()
          s1 += ho->cena_opl
          If pr_pl_bes == 1  // платные
            If ho->tip_opl == 2
              s5 += ho->cena_opl // напыление
            Else
              s4 += ho->cena_opl // платно
            Endif
          Elseif pr_pl_bes == 2 .or. pr_pl_bes == 3 // бесплатные
            If emptyall( ho->n_kvit, ho->kv_cia )
              s3 += ho->cena_opl  // бесплатно
            Else
              If ho->tip_opl == 2
                s5 += ho->cena_opl  // напыление
              Else
                s4 += ho->cena_opl  // платно
              Endif
            Endif
          Endif
          Skip
        Enddo
        s1 := Round( s1, 2 )
        s3 := Round( s3, 2 )
        s4 := Round( s4, 2 )
        s5 := Round( s5, 2 )
        // if !empty(s1)
        Select TMP
        Append Blank
        tmp->KOD_H := human->( RecNo() )
        tmp->DATA := human->data
        tmp->N_NAR := human->nar_z
        tmp->STOIM := s1
        tmp->STOIM_P := s3
        tmp->STOIM_B := s4
        tmp->STOIM_N := s5
        If tmp->( LastRec() ) % 5000 == 0
          Commit
        Endif
        // endif
      Endif
      Select HUMAN
      Skip
    Enddo
  Case par == 3
    Select TMP
    Index On Str( kod_h, 7 ) to ( cur_dir() + "tmp" )
    r_use( dir_server() + "hum_ort",, "HUMAN" )
    r_use( dir_server() + "hum_oro", dir_server() + "hum_orod", "HO" )
    Set Relation To kod into HUMAN
    dbSeek( arr[ 7 ], .t. )
    Do While ho->pdate <= arr[ 8 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      if &muslovie .and. iif( is_open, Empty( human->k_data ), .t. )
        Select TMP
        find ( Str( ho->kod, 7 ) )
        If !Found()
          Append Blank
          tmp->KOD_H := human->( RecNo() )
          tmp->N_NAR := human->nar_z
          If tmp->( LastRec() ) % 1000 == 0
            Commit
          Endif
        Endif
        tmp->STOIM += ho->cena_opl
        If pr_pl_bes == 1  // платные
          If ho->tip_opl == 2
            tmp->STOIM_N += ho->cena_opl
          Else
            tmp->STOIM_P += ho->cena_opl
          Endif
        Elseif pr_pl_bes == 2  .or. pr_pl_bes == 3// бесплатные
          If emptyall( ho->n_kvit, ho->kv_cia )
            tmp->STOIM_B += ho->cena_opl
          Else
            If ho->tip_opl == 2
              tmp->STOIM_N += ho->cena_opl
            Else
              tmp->STOIM_P += ho->cena_opl
            Endif
          Endif
        Endif
      Endif
      Select HO
      Skip
    Enddo
  Endcase
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    Return Nil
  Endif
  If j == 0
    Return func_error( 4, "Нет сведений!" )
  Endif
  mywait()
  //
  arr_title := { ;
    "─────┬───────────────────────────────────────────┬────┬─────┬──────", ;
    "Наряд│                                           │    │№ кв.│№ кви-", ;
    "заказ│         Ф.И.О. и адрес больного           │Врач│книж.│танции", ;
    "─────┴───────────────────────────────────────────┴────┴─────┴──────" }

  If pr_pl_bes == 1  // платные
    arr_title[ 1 ] += "┬─────────┬─────────"
    arr_title[ 2 ] += "│  Сумма  │  Сумма  "
    arr_title[ 3 ] += "│ протез. │напыления"
    arr_title[ 4 ] += "┴─────────┴─────────"
  Elseif pr_pl_bes == 2 .or. pr_pl_bes == 3// бесплатные
    arr_title[ 1 ] += "┬─────────┬─────────┬─────────"
    arr_title[ 2 ] += "│  Сумма  │  Сумма  │  Сумма  "
    arr_title[ 3 ] += "│ч/з кассу│   РЗО   │напыления"
    arr_title[ 4 ] += "┴─────────┴─────────┴─────────"
  Endif
  arr_title[ 1 ] += "┬─────────"
  arr_title[ 2 ] += "│  Сумма  "
  arr_title[ 3 ] += "│  оплаты "
  arr_title[ 4 ] += "┴─────────"
  If par == 2
    arr_title[ 1 ] += "┬────────"
    arr_title[ 2 ] += "│  Дата  "
    arr_title[ 3 ] += "│закрытия"
    arr_title[ 4 ] += "┴────────"
  Endif
  sh := Len( arr_title[ 1 ] )
  //
  If pr_pl_bes == 1 .or. pr_pl_bes == 2
    reg_print := 3
  Else
    reg_print := 6
  Endif
  //
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  Do Case
  Case par == 1
    add_string( Center( "Реестр поступления денежных средств за протезирование", sh ) )
    add_string( Center( arr[ 4 ], sh ) )
    add_string( Center( "[ по дате окончания лечения ]", sh ) )
  Case par == 2
    add_string( Center( "Журнал регистрации нарядов-заказов", sh ) )
    add_string( Center( arr[ 4 ], sh ) )
    add_string( Center( iif( is_open, "[ открытые", "[ все" ) + " наряды-заказы ]", sh ) )
    add_string( "" )
    add_string( Center( "по состоянию на " + date_month( sys_date, .t. ), sh ) )
  Case par == 3
    add_string( Center( "Реестр поступления денежных средств за протезирование", sh ) )
    add_string( Center( arr[ 4 ], sh ) )
    add_string( Center( "[ оплата за конкретный период времени ]", sh ) )
    add_string( Center( iif( is_open, "[ открытые", "[ все" ) + " наряды-заказы ]", sh ) )
  Endcase
  add_string( "" )
  If pr_pl_bes != 3
    add_string( Center( pr_titul, sh ) )
    add_string( "" )
  Endif
  AEval( arr_title, {| x| add_string( x ) } )
  r_use( dir_server() + "mo_pers",, "PERSO" )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "hum_oro", dir_server() + "hum_oro", "HO" )
  r_use( dir_server() + "hum_ort",, "HUMAN" )
  Set Relation To kod_k into KART, To kod_vr into PERSO
  Use ( cur_dir() + "tmp" ) new
  If par == 2
    Index On DToS( data ) + Str( n_nar, 5 ) to ( cur_dir() + "tmp" )
  Else
    Index On Str( n_nar, 5 ) to ( cur_dir() + "tmp" )
  Endif
  Set Relation To kod_h into HUMAN
  j := s1  := s3 := s4 := s5 := 0 ; old_date := begin_date -1
  Go Top
  Do While !Eof()
    add_string( "" )
    If verify_ff( HH - 3, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    If par == 2 .and. old_date != tmp->data
      add_string( PadR( full_date( tmp->data ), 12 ) + "│" )
      add_string(                  "────────────┘" )
      old_date := tmp->data
    Endif
    ++j ; s1 += tmp->stoim ; s3 += tmp->stoim_b ; s4 += tmp->stoim_p
    s5 += tmp->stoim_n
    s := PadC( lstr( tmp->n_nar ), 5 ) + "  " + ;
      PadR( AllTrim( kart->fio ), 42, "." ) + ;
      PadL( lstr( perso->tab_nom ), 5, "." )
    If pr_pl_bes == 1 // платные
      s += PadL( put_val( tmp->stoim_p, 10, 2, "." ), 23, "." ) + ;
        PadL( put_val( tmp->stoim_n, 10, 2, "." ), 10, "." ) + ;
        PadL( lput_kop( tmp->stoim ), 10, "." )
    Elseif pr_pl_bes == 3 .or. pr_pl_bes == 2 // бесплатные
      s += PadL( put_val( tmp->stoim_p, 10, 2, "." ), 23, "." ) + ;
        PadL( put_val( tmp->stoim_b, 10, 2, "." ), 10, "." ) + ;
        PadL( put_val( tmp->stoim_n, 10, 2, "." ), 10, "." ) + ;
        PadL( lput_kop( tmp->stoim ), 10, "." )
    Else
      s += PadL( lput_kop( tmp->stoim ), 23, "." )
    Endif
    add_string( s )
    s := if( pr_pl_bes == 3, Space( 2 ) + { "П", "Б", "З", "Д" }[ human->tip_usl + 1 ], Space( 3 ) ) + ;
      Space( 4 ) + AllTrim( kart->adres )
    If par == 2 .and. !Empty( human->k_data )
      s := PadR( s, sh - 8 ) + date_8( human->k_data )
    Endif
    add_string( s )
    Select HO
    find ( Str( tmp->kod_h, 7 ) )
    Do While ho->kod == tmp->kod_h
      If iif( par == 3, Between( ho->pdate, arr[ 7 ], arr[ 8 ] ), .t. )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        s := Space( 44 ) + full_date( c4tod( ho->pdate ) ) + ;
          Str( ho->n_kvit, 6 ) + ;
          Str( ho->kv_cia, 7 )
        If pr_pl_bes == 1 // платные
          s += iif( ho->tip_opl == 2, Space( 10 ), "" )  // сдвиг для напыления
        Elseif pr_pl_bes == 2 .or. pr_pl_bes == 3// бесплатные
          If emptyall( ho->n_kvit, ho->kv_cia )
            s += Space( 10 ) // сдвиг для бесплатных
          Else
            s += iif( ho->tip_opl == 2, Space( 20 ), "" )  // сдвиг для напыления
          Endif
        Endif
        add_string( s + put_kope( ho->cena_opl, 10 ) )
      Endif
      Skip
    Enddo
    Select TMP
    Skip
  Enddo
  Close databases
  If fl_exit
    add_string( Replicate( "*", sh ) )
    add_string( Expand( "ПРОЦЕСС ПРЕРВАН" ) )
  Endif
  add_string( Replicate( "─", sh ) )
  s := PadR( "Кол-во больных - " + lstr( j ), 25 )
  If pr_pl_bes == 1 // платные
    s += put_kope( s4, sh - iif( par == 2, 54, 45 ) ) + put_kope( s5, 10 ) + put_kope( s1, 10 )
  Elseif pr_pl_bes == 2 .or. pr_pl_bes == 3// бесплатные
    s += put_kope( s4, sh - iif( par == 2, 64, 55 ) ) + put_kope( s3, 10 ) + ;
      put_kope( s5, 10 ) + put_kope( s1, 10 )
  Else
    s += put_kope( s1, sh - iif( par == 2, 34, 25 ) )
  Endif
  add_string( s )
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 

// 19.07.14
Function oo_statist( k )

  Static si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 1, si6 := 1, ;
    si7 := 1, si8 := 1, si9 := 1, si10 := 1, si11 := 1, si12 := 1
  Local mas_pmt, mas_msg, mas_fun, j, mdate, arr_gr
  Local uch_otd

  Default k To 1
  Do Case
  Case k == 1
    uch_otd := saveuchotd()
    Private p_net_otd := .t., pr_pl_bes := 0, pr_titul, is_open
    mas_pmt := { "~Открытые наряды-заказы", ;
      "~Закрытые наряды-заказы", ;
      "~Все наряды-заказы", ;
      "~Многовариантный поиск", ;
      "~ДМС и взаимозачет" }
    mas_msg := { "Статистика по открытым (еще не закрытым) нарядам-заказам", ;
      "Статистика по закрытым нарядам-заказам", ;
      "Статистика по всем (открытым и закрытым) нарядам-заказам", ;
      "Получение сводной информации (многовариантный поиск)", ;
      "Получение информации по ДМС и взаимозачету" }
    mas_fun := { "Oo_statist(11)", ;
      "Oo_statist(12)", ;
      "Oo_statist(13)", ;
      "Oo_statist(14)", ;
      "Oo_statist(15)" }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
    restuchotd( uch_otd )
    //************
  Case eq_any( k, 11, 13 )
    is_open := ( k == 11 )
    mas_pmt := { "Объем ~работ", ;
      "Объем работ по ~врачам", ;
      "Объем работ по ~больным", ;
      "Поступление ~денежных средств" }
    mas_msg := { "Статистика по объему работ персонала", ;
      "Статистика по лечащим врачам", ;
      "Статистика по пролеченным больным [+ по лечащим врачам]", ;
      "Статистика по поступлению денежных средств" }
    mas_fun := { "Oo_statist(131)", ;    // 06.10.23
    "Oo_statist(21)", ;
      "Oo_statist(22)", ;
      "Oo_statist(23)" }
    If k == 11
      AAdd( mas_pmt, "Не~закрытые наряды-заказы" )
      AAdd( mas_msg, "Общий список не закрытых нарядов-заказов" )
      AAdd( mas_fun, "Oo_statist(24)" )
      // if glob_or_pol == 1
      AAdd( mas_pmt, "~Долги по оплате" )
      AAdd( mas_msg, "Долги по оплате" )
      AAdd( mas_fun, "Oo_statist(25)" )
      // endif
      AAdd( mas_pmt, "~Расход материалов" )
      AAdd( mas_msg, "Ведомость по расходу материалов на протезирование" )
      AAdd( mas_fun, "Oo_statist(39)" )     // 05.03.13
      //
      AAdd( mas_pmt, "~Журнал Регистрации" )
      AAdd( mas_msg, "Журнал регистрации договоров" )
      AAdd( mas_fun, "Oo_statist(26)" )
      //
      AAdd( mas_pmt, "~Настраиваемый журнал Регистрации" )
      AAdd( mas_msg, "Настраиваемый журнал Регистрации" )
      AAdd( mas_fun, "Oo_statist(27)" )
    Endif
    popup_prompt( T_ROW, T_COL - 5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 12
    is_open := .f.
    mas_pmt := { "Объем ~работ", ;
      "Статистика по ~больным", ;
      "Статистика по ~диагнозам", ;
      "О~плата", ;
      "~Оборотная ведомость", ;
      "Форма ~39 по ортопедии", ;
      "~Расход материалов", ;
      "Поломки про~тезов", ;
      "~Журнал Регистрации", ;
      "~Настраиваемый журнал Регистрации", ;
      "Журнал ~Закрытых нарядов" }     // 24.06.08
    mas_msg := { "Статистика по объему работ персонала", ;
      "Статистика по больным", ;
      "Статистика по диагнозам", ;
      "Статистика по оплате", ;
      "Оборотная ведомость по оплате нарядов-заказов", ;
      "Статистистическая форма 39 по ортопедии", ;
      "Ведомость по расходу материалов на протезирование", ;
      "Статистика по поломкам протезов", ;
      "Журнал регистрации договоров", ;
      "Настраиваемый журнал Регистрации", ;
      "Журнал Закрытых нарядов" }      // 24.06.08
    mas_fun := { "Oo_statist(31)", ;
      "Oo_statist(32)", ;
      "Oo_statist(33)", ;
      "Oo_statist(34)", ;
      "Oo_statist(35)", ;
      "Oo_statist(36)", ;
      "Oo_statist(37)", ;
      "Oo_statist(38)", ;
      "Oo_statist(26)", ;
      "Oo_statist(27)", ;
      "Oo_statist(28)" } // 24.06.08
    popup_prompt( T_ROW, T_COL - 5, si3, mas_pmt, mas_msg, mas_fun )
  Case k == 14
    ort_mnog_poisk()
  Case k == 15
    mas_pmt := { "~Реестр по ДМС" }
    mas_msg := { "Распечатка реестра по ДМС" }
    mas_fun := { "Oo_statist(101)" }
    popup_prompt( T_ROW, T_COL - 5, si10, mas_pmt, mas_msg, mas_fun )
    //************
  Case k == 21
    ort_otkr_nar( 1, 2 )
  Case k == 22
    ort_otkr_nar( 1, 1 )
  Case k == 23
    mas_pmt := { "По дате ~открытия наряда", ;
      "За ~период времени" }
    mas_msg := { "Журнал регистрации нарядов-заказов [по дате открытия наряда]", ;
      "Реестр поступления денежных средств за конкретный период времени" }
    mas_fun := { "Ort_den_sr(2)", ;
      "Ort_den_sr(3)" }
    popup_prompt( T_ROW, T_COL - 5, 2, mas_pmt, mas_msg, mas_fun )
  Case k == 24
    ort_otkr_nar( 2 )
  Case k == 25
    ort_dolgi( 2 )
  Case k == 26
    pl_ordogovor()  // 16.06.08
  Case k == 27
    pl_or2dogovor( 1 ) // 24.06.08
  Case k == 28
    pl_or2dogovor( 2 ) // 24.06.08

    //************
  Case k == 31
    Private ptip_date := 1 // закрытые наряды - по умолчанию
    mas_pmt := { "По ~персоналу", ;
      "По ~услугам" }
    mas_msg := { "Статистика по объему работ персонала", ;
      "Статистика по оказанным услугам" }
    mas_fun := { "Oo_statist(41)", ;
      "Oo_statist(42)" }
    popup_prompt( T_ROW, T_COL - 5, si4, mas_pmt, mas_msg, mas_fun )
  Case k == 32
    mas_pmt := { "Список ~больных", ;
      "~Леч.врач + больные", ;
      "~Зуб.техник + больные" }
    mas_msg := { "Статистика по пролеченным больным", ;
      "Статистика по пролеченным больным [по лечащим врачам]", ;
      "Статистика по пролеченным больным [по зубным техникам]" }
    mas_fun := { "Oo_statist(51)", ;
      "Oo_statist(52)", ;
      "Oo_statist(53)" }
    popup_prompt( T_ROW, T_COL - 5, si5, mas_pmt, mas_msg, mas_fun )
  Case k == 33
    ort_diagnoz()
  Case k == 34
    mas_pmt := { "~Поступление денежных средств", ;
      "~Долги по оплате" }
    mas_msg := { "Реестр поступления денежных средств за протезирование", ;
      "Долги по оплате" }
    mas_fun := { "Oo_statist(61)", ;
      "Oo_statist(62)" }
    popup_prompt( T_ROW, T_COL - 5, si6, mas_pmt, mas_msg, mas_fun )
  Case k == 35
    ort_oborot()
  Case k == 36
    mas_pmt := { "Форма 39 по ~организации", ;
      "Форма 39 по ~врачу", ;
      "~Настройка формы 39", ;
      "Печать настройки" }
    mas_msg := { "Распечатка формы 39 в целом по организации", ;
      "Распечатка формы 39 по врачу", ;
      "Настройка для составления формы 39", ;
      "Печать настройки для составления формы 39" }
    mas_fun := { "Oo_statist(121)", ;
      "Oo_statist(122)", ;
      "Oo_statist(123)", ;
      "Oo_statist(124)" }
    Private lp := Array( 65 )
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL - 5, si12, mas_pmt, mas_msg, mas_fun )
  Case k == 37
    ort_material( 1 ) // 05.03.13
  Case k == 38
    mas_pmt := { "~Причины поломок протезов", ;
      "~Список больных по поломкам" }
    mas_msg := { "Причины поломок протезов", ;
      "Список больных по поломкам" }
    mas_fun := { "Oo_statist(111)", ;
      "Oo_statist(112)" }
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL - 5, si11, mas_pmt, mas_msg, mas_fun )
  Case k == 39      // 05.03.13
    ort_material( 2 )
    //************
  Case k == 41
    mas_pmt := { "По ~врачам", ;
      "По ~зубным техникам", ;
      "По ~медсестрам" }
    mas_msg := { "врачи", ;
      "зуб.техники", ;
      "медсестры" }
    AEval( mas_msg, {| x, i| mas_msg[ i ] := "Статистика по персоналу [" + x + "]" } )
    mas_fun := { "Oo_statist(71)", ;
      "Oo_statist(72)", ;
      "Oo_statist(73)" }
    popup_prompt( T_ROW, T_COL - 5, si7, mas_pmt, mas_msg, mas_fun )
  Case k == 42
    mas_pmt := { "Список ~услуг", ;
      "~Врачи + услуги", ;
      "~Зуб.техники + услуги", ;
      "~Медсестры + услуги" }
    mas_msg := { "Статистика по оказанным услугам", ;
      "Статистика по услугам + врачи", ;
      "Статистика по услугам + зубные техники", ;
      "Статистика по услугам + медсестры" }
    mas_fun := { "Oo_statist(81)", ;
      "Oo_statist(82)", ;
      "Oo_statist(83)", ;
      "Oo_statist(84)" }
    popup_prompt( T_ROW, T_COL - 5, si8, mas_pmt, mas_msg, mas_fun )
    //************
  Case k == 51
    ort_boln()
  Case k == 52
    ort_boln( "vr" )
  Case k == 53
    ort_boln( "tehn" )
    //************
  Case k == 61
    ort_den_sr( 1 )
  Case k == 62
    ort_dolgi( 1 )
    //************
  Case Between( k, 71, 73 )
    Private ptip_pers := { "vr", "tehn", "meds" }[ k - 70 ]
    mas_pmt := { "Персонал + ~больные (сокр.)", ;
      "Персонал + больные (полна~я)", ;
      "~Персонал", ;
      "Персонал + суммы ~услуг" }
    mas_msg := { "персонал + больные (сокр.форма)", ;
      "персонал + больные (полная форма)", ;
      "персонал", ;
      "персонал + суммы услуг" }
    AEval( mas_msg, {| x, i| mas_msg[ i ] := "Статистика по персоналу [" + x + "]" } )
    mas_fun := { "Oo_statist(91)", ;
      "Oo_statist(92)", ;
      "Oo_statist(93)", ;
      "Oo_statist(94)" }
    If eq_any( k, 71, 72 )  // врачи или техники
      AAdd( mas_pmt, "~Ведомость наработки" )
      AAdd( mas_msg, "Ведомость наработки персонала за период времени" )
      AAdd( mas_fun, "Oo_statist(95)" )
      // if k == 71   19.07.14
      AAdd( mas_pmt, "Персонал + количество ~нарядов" )
      AAdd( mas_msg, "Подсчёт количества закрытых нарядов-заказов по врачам за период" )
      AAdd( mas_fun, "Oo_statist(96)" )
      // endif
    Endif
    popup_prompt( T_ROW, T_COL - 5, si9, mas_pmt, mas_msg, mas_fun )
    //************
  Case k == 81
    oob_statist( "usl" )
  Case k == 82
    oob_statist( "pers", "vr", "usl" )
  Case k == 83
    oob_statist( "pers", "tehn", "usl" )
  Case k == 84
    oob_statist( "pers", "meds", "usl" )
    //************
  Case k == 91
    oob_statist( "pers", ptip_pers, "boln" )
  Case k == 92
    oob1_statist( ptip_pers )   // "pers","boln"
  Case k == 93
    oob_statist( "pers", ptip_pers )
  Case k == 94
    oob_statist( "pers", ptip_pers, "summa" )
  Case k == 95
    o_ved_narabot()
  Case k == 96
    o_vr_kol_nar()
  Case k == 101
    o_dms_reestr()
  Case k == 111
    o_pr_polom()
  Case k == 112
    o_sb_pr_polom()
  Case k == 121
    forma_30all( 3 )
  Case k == 122
    forma_30all( 1 )
  Case k == 123
    forma_30_na( 1 )
  Case k == 124
    forma_30_na( 2 )
    //************
  Case k == 131
    Private ptip_date := 2 // не закрытые наряды
    mas_pmt := { "По ~персоналу", ;
      "По ~услугам" }
    mas_msg := { "Предварительная Статистика по объему работ персонала", ;
      "Предварительная Статистика по оказанным услугам" }
    mas_fun := { "Oo_statist(132)", ;
      "Oo_statist(133)" }
    popup_prompt( T_ROW, T_COL - 5, si7, mas_pmt, mas_msg, mas_fun )
  Case k == 132
    mas_pmt := { "По ~врачам", ;
      "По ~зубным техникам", ;
      "По ~медсестрам" }
    mas_msg := { "врачи", ;
      "зуб.техники", ;
      "медсестры" }
    AEval( mas_msg, {| x, i| mas_msg[ i ] := "Статистика по персоналу [" + x + "]" } )
    mas_fun := { "Oo_statist(71)", ;
      "Oo_statist(72)", ;
      "Oo_statist(73)" }
    popup_prompt( T_ROW, T_COL - 5, si7, mas_pmt, mas_msg, mas_fun )
  Case k == 133
    mas_pmt := { "Список ~услуг", ;
      "~Врачи + услуги", ;
      "~Зуб.техники + услуги", ;
      "~Медсестры + услуги" }
    mas_msg := { "Статистика по оказанным услугам", ;
      "Статистика по услугам + врачи", ;
      "Статистика по услугам + зубные техники", ;
      "Статистика по услугам + медсестры" }
    mas_fun := { "Oo_statist(81)", ;
      "Oo_statist(82)", ;
      "Oo_statist(83)", ;
      "Oo_statist(84)" }
    popup_prompt( T_ROW, T_COL - 5, si8, mas_pmt, mas_msg, mas_fun )
    //************
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 ) .or. k == 131
      si2 := j
    Elseif Between( k, 31, 39 )
      si3 := j
    Elseif Between( k, 41, 49 )
      si4 := j
    Elseif Between( k, 51, 59 )
      si5 := j
    Elseif Between( k, 61, 69 )
      si6 := j
    Elseif Between( k, 71, 79 )
      si7 := j
    Elseif Between( k, 91, 99 )
      si8 := j
    Elseif Between( k, 91, 99 )
      si9 := j
    Elseif Between( k, 101, 109 )
      si10 := j
    Elseif Between( k, 111, 119 )
      si11 := j
    Elseif Between( k, 121, 129 )
      si12 := j
    Elseif Between( k, 131, 139 )
      si13 := j
    Endif
  Endif

  Return Nil

// 

//
Function oob_statist( par1, par2, par3 )

  Local arr, arr_title, reg_print := 2, sh, HH := 58, s, s1, s2, s3, fl, ;
    begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "orto_st.txt", ;
    tip_tit, s4, parametr4 := 1 // по умолчанию
  Local reg, reg1, mperso, musluga, mkod, buf := save_row( MaxRow() )
  Local msl1usluga, msl2usluga, l_delen, mslusluga

  Default par1 To "", par2 To "", par3 To ""
  parametr4 := ptip_date // по дате окончания или без оной
  If !( par3 == "summa" ) .and. ( pr_pl_bes := o_ret_pl_b() ) == 0
    Return Nil
  Endif
  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  Do Case
  Case par1 == "pers"
    reg := 1 ; reg1 := if( par2 == "vr", 1, if( par2 == "tehn", 2, 3 ) )
    If ( mperso := input_kperso() ) == Nil  // ==> весь персонал
      mywait()
      mperso := {}
      r_use( dir_server() + "mo_pers",, "PERSO" )
      Go Top
      Do While !Eof()
        If perso->kod > 0
          AAdd( mperso, { perso->kod, "" } )
        Endif
        Skip
      Enddo
      perso->( dbCloseArea() )
    Endif
  Case par1 == "usl"
    reg := 2
    If ( musluga := input_value( 18, 9, 20, 70, color1, ;
        "Введите шаблон для поиска необходимых услуг", ;
        PadR( "*", 10 ) ) ) == NIL
      Return Nil
    Endif
    musluga := AllTrim( musluga )
  Endcase
  begin_date := arr[ 5 ]
  end_date := arr[ 6 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  If par3 == "summa"
    pr_pl_bes := 0
    mslusluga := AllTrim( mem_ort_sl )
    l_delen := At( ",", mem_ort_sl )
    If Empty( mslusluga ) .or. mslusluga == "*"
      msl1usluga := "9999999999"
      msl2usluga := "9999999999"
    Else
      msl1usluga := AllTrim( SubStr( mslusluga, 1, l_delen - 1 ) )
      msl2usluga := AllTrim( SubStr( mslusluga, l_delen + 1, 40 ) )
    Endif
    musluga := AllTrim( mem_ort_na )
    If Empty( musluga ) .or. musluga == "*"
      musluga := "9999999999"
    Endif
    dbCreate( cur_dir() + "tmp", { ;
      { "KOD",        "N",      4,      0 }, ;  // код персонала (услуги)
    { "FIO",        "C",     50,      0 }, ;  // Ф.И.О. (шифр услуги)
    { "KOL",        "N",     10,      3 }, ;  // кол-во услуг
    { "TRUDOEM",    "N",     11,      4 }, ;  // трудоемкость услуг УЕТ
    { "STOIM_P",    "N",     14,      2 }, ;  // стоимость пл.услуг
    { "STOIM_B",    "N",     14,      2 }, ;  // стоимость беспл.услуг
    { "STOIM_N",    "N",     14,      2 }, ;  // стоимость напыления
    { "STOIM_S",    "N",     14,      2 }, ;  // стоимость слепков
    { "STOIM",      "N",     14,      2 } ;  // общая стоимость
    } )
  Else
    dbCreate( cur_dir() + "tmp", { ;
      { "KOD",        "N",      4,      0 }, ;  // код персонала (услуги)
    { "FIO",        "C",     50,      0 }, ;  // Ф.И.О. (шифр услуги)
    { "KOL",        "N",     10,      3 }, ;  // кол-во услуг
    { "TRUDOEM",    "N",     11,      4 }, ;  // трудоемкость услуг УЕТ
    { "STOIM",      "N",     14,      2 } ;  // стоимость лечения
    } )
    If !Empty( par3 )
      dbCreate( cur_dir() + "tmp1", { ;
        { "KOD",        "N",      4,      0 }, ;  // код персонала
      { "KOD_H",      "N",      7,      0 }, ;  // код больного по картотеке
      { "KOL",        "N",     10,      3 }, ;  // кол-во услуг
      { "TRUDOEM",    "N",     11,      4 }, ;  // трудоемкость услуг УЕТ
      { "STOIM",      "N",     14,      2 } ;  // стоимость лечения
      } )
      Use ( cur_dir() + "tmp1" ) new
      Index On Str( kod, 4 ) + Str( kod_h, 7 ) to ( cur_dir() + "tmp1" )
    Endif
  Endif
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod, 4 ) to ( cur_dir() + "tmp" )
  If mem_trudoem == 2
    useuch_usl()
  Endif
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "mo_pers",, "PERSO" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
  If reg == 2 .or. par3 == "summa"
    Set Relation To u_kod into USL
  Endif
  r_use( dir_server() + "kartotek",, "KART" )
  If parametr4 == 1
    r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
    dbSeek( DToS( begin_date ), .t. )
  Else
    r_use( dir_server() + "hum_ort", dir_server() + "hum_orto", "HUMAN" )
    dbSeek( DToS( begin_date ), .t. )
  Endif
  Do While iif( parametr4 == 1, human->k_data, human->data ) <= end_date .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    Select HU
    find ( Str( human->( RecNo() ), 7 ) )
    Do While hu->kod == human->( RecNo() ) .and. !Eof()
      fl := .f.
      If reg == 1
        Do Case
        Case reg1 == 1
          mkod := hu->kod_vr
        Case reg1 == 2
          mkod := hu->kod_as
        Case reg1 == 3
          mkod := hu->kod_ms
        Endcase
        If ( fl := ( mkod > 0 .and. AScan( mperso, {| x| x[ 1 ] == mkod } ) > 0 ) )
          Select PERSO
          Goto ( mkod )
        Endif
      Else
        If ( fl := Like( musluga, usl->shifr ) )
          mkod := hu->u_kod
        Endif
      Endif
      If fl
        If pr_pl_bes == 1  // платные
          fl := ( hu->tip_usl != OU_B_PLAT )
        Elseif pr_pl_bes == 2  // бесплатные
          fl := ( hu->tip_usl == OU_B_PLAT )
        Endif
        If fl
          mtrud := 0
          If mem_trudoem == 2
            kart->( dbGoto( human->kod_k ) )
            mtrud := round_5( hu->kol * opr_uet( kart->vzros_reb ), 4 )
          Endif
          Select TMP
          find ( Str( mkod, 4 ) )
          If !Found()
            Append Blank
            tmp->kod := mkod
            If reg == 1
              tmp->fio := perso->fio
            Else
              tmp->fio := usl->shifr
            Endif
          Endif
          If reg == 2 .or. par3 == "usl"
            tmp->kol += hu->kol
            tmp->trudoem += mtrud
          Endif
          tmp->stoim += hu->stoim
          If par3 == "boln"
            Select TMP1
            find ( Str( mkod, 4 ) + Str( human->kod_k, 7 ) )
            If !Found()
              Append Blank
              tmp1->kod := mkod
              tmp1->kod_h := human->kod_k
            Endif
            tmp1->stoim += hu->stoim
          Elseif par3 == "usl"
            Select TMP1
            find ( Str( mkod, 4 ) + Str( hu->u_kod, 7 ) )
            If !Found()
              Append Blank
              tmp1->kod := mkod
              tmp1->kod_h := hu->u_kod
            Endif
            tmp1->kol += hu->kol
            tmp1->trudoem += mtrud
            tmp1->stoim += hu->stoim
          Elseif par3 == "summa"
            s := s1 := s2 := s3 := s4 := 0
            If hu->tip_usl != OU_B_PLAT  // платные
              If Like( musluga, usl->shifr )
                s := hu->stoim  // напыление
              Else
                s1 := hu->stoim
              Endif
              If Like( msl2usluga, usl->shifr ) .or. Like( msl1usluga, usl->shifr )
                s3 := hu->stoim  // слепки
              Endif
            Else
              s2 := hu->stoim
            Endif
            tmp->stoim_p += s1
            tmp->stoim_b += s2
            tmp->stoim_n += s
            tmp->stoim_s += s3
          Endif
        Endif
      Endif
      Select HU
      Skip
    Enddo
    Select HUMAN
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    Return Nil
  Endif
  If j == 0
    Return func_error( 4, "Нет сведений!" )
  Endif
  mywait()
  //
  len_n := 60
  If mem_trudoem == 2
    len_n := 51
  Endif
  tip_tit := if( reg == 1, 1, 2 )
  If par3 == "usl"
    tip_tit := 2
  Elseif par3 == "summa"
    tip_tit := 3
  Endif
  If tip_tit == 1
    If Empty( par3 )  // общий список
      len_n := 50
      arr_title := { ;
        "──────────────────────────────────────────────────┬─────────────", ;
        "                     Ф.И.О.                       │Сумма лечения", ;
        "──────────────────────────────────────────────────┴─────────────" }
    Else
      len_n := 54
      arr_title := { ;
        "──────────────────────────────────────────────────────┬─────────────", ;
        "                Ф.И.О. и адрес больного               │Сумма лечения", ;
        "──────────────────────────────────────────────────────┴─────────────" }
    Endif
  Elseif tip_tit == 2
    arr_title := Array( 4 )
    arr_title[ 1 ] := Replicate( "─", len_n )
    arr_title[ 2 ] := Space( len_n )
    arr_title[ 3 ] := PadC( "Наименование услуг", len_n )
    arr_title[ 4 ] := Replicate( "─", len_n )
    arr_title[ 1 ] += "┬─────"
    arr_title[ 2 ] += "│ Кол."
    arr_title[ 3 ] += "│услуг"
    arr_title[ 4 ] += "┴─────"
    If mem_trudoem == 2
      arr_title[ 1 ] += "┬────────"
      arr_title[ 2 ] += "│        "
      arr_title[ 3 ] += "│ У.Е.Т. "
      arr_title[ 4 ] += "┴────────"
    Endif
    arr_title[ 1 ] += "┬─────────────"
    arr_title[ 2 ] += "│             "
    arr_title[ 3 ] += "│Сумма лечения"
    arr_title[ 4 ] += "┴─────────────"
  Else
    arr_title := { ;
      "────────────────────────────────╥───────────┬───────────┬───────────┬───────────╥───────────", ;
      "              Ф.И.О.            ║  Платные  │ Бесплатные│  Слепки   │ Напыление ║   Всего   ", ;
      "────────────────────────────────╨───────────┴───────────┴───────────┴───────────╨───────────" }
  Endif
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Объем работ", sh ) )
  add_string( Center( arr[ 4 ], sh ) )
  If !( par3 == "summa" )
    add_string( Center( pr_titul, sh ) )
  Endif
  r_use( dir_server() + "mo_pers",, "PERSO" )
  Use ( cur_dir() + "tmp" ) new
  If reg == 1
    Index On Upper( fio ) to ( cur_dir() + "tmp" )
    add_string( Center( { "[ По врачам ]", ;
      "[ По зубным техникам ]", ;
      "[ По медсестрам ]" }[ reg1 ], sh ) )
    If par3 == "boln"
      r_use( dir_server() + "kartotek",, "KART" )
      Use ( cur_dir() + "tmp1" ) new
      Set Relation To kod_h into KART
      Index On Str( kod, 4 ) + Upper( Left( kart->fio, 20 ) ) to ( cur_dir() + "tmp1" )
      Select TMP
    Elseif par3 == "usl"
      r_use( dir_server() + "uslugi",, "USL" )
      Use ( cur_dir() + "tmp1" ) new
      Set Relation To kod_h into USL
      Index On Str( kod, 4 ) + fsort_usl( usl->shifr ) to ( cur_dir() + "tmp1" )
      Select TMP
    Endif
  Else
    Index On fsort_usl( Left( fio, 10 ) ) to ( cur_dir() + "tmp" )
    r_use( dir_server() + "uslugi",, "USL" )
    Select TMP
    Set Relation To kod into USL
    If !( musluga == "*" )
      add_string( Center( "Услуги: " + musluga, sh ) )
    Endif
  Endif
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  s := s1 := s2 := s3 := s4 := 0
  Go Top
  Do While !Eof()
    If par3 == "summa"
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      perso->( dbGoto( tmp->kod ) )
      add_string( PadR( fam_i_o( tmp->fio ) + "  [" + lstr( perso->tab_nom ) + "]", 32 ) + ;
        put_kope( tmp->stoim_p, 12 ) + ;
        put_kope( tmp->stoim_b, 12 ) + ;
        put_kope( tmp->stoim_s, 12 ) + ;
        put_kope( tmp->stoim_n, 12 ) + ;
        put_kope( tmp->stoim, 12 ) )
      s1 += tmp->stoim_p
      s2 += tmp->stoim_b
      s3 += tmp->stoim_s
      s  += tmp->stoim_n
    Else
      If reg == 1
        j := 1
        If Empty( par3 )
          s := PadR( AllTrim( tmp->fio ) + "  [" + lstr( tmp->kod ) + "]", 50 )
        Else
          s := PadR( Space( 4 ) + "[" + lstr( tmp->kod ) + "]  " + Upper( tmp->fio ), len_n )
          If par3 == "usl"
            s += umest_val( tmp->kol, 6, 3 )
            If mem_trudoem == 2
              s += put_val_0( tmp->trudoem, 9, 1 )
            Endif
          Endif
        Endif
      Else
        j := perenos( arr, usl->name, len_n - 11 )
        s := usl->shifr + " " + PadR( arr[ 1 ], len_n - 11 ) + umest_val( tmp->kol, 6, 3 )
        If mem_trudoem == 2
          s += put_val_0( tmp->trudoem, 9, 1 )
        Endif
      Endif
      s += put_kope( tmp->stoim, 14 )
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( s )
      For i := 2 To j
        add_string( Space( 11 ) + PadL( AllTrim( arr[ i ] ), len_n - 11 ) )
      Next
      s1 += tmp->kol
      s2 += tmp->stoim
      s4 += tmp->trudoem
      If reg == 1 .and. !Empty( par3 )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( Space( 4 ) + Replicate( ".", sh - 4 ) )
        j := 0
        Select TMP1
        find ( Str( tmp->kod, 4 ) )
        Do While tmp1->kod == tmp->kod .and. !Eof()
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          If par3 == "boln"
            ++j
            add_string( PadR( lstr( j ) + ". " + kart->fio, 54 ) + put_kope( tmp1->stoim, 14 ) )
            add_string( Space( Len( lstr( j ) ) + 3 ) + kart->adres )
          Elseif par3 == "usl"
            j := perenos( arr, usl->name, len_n - 11 )
            s := usl->shifr + " " + PadR( arr[ 1 ], len_n - 11 ) + umest_val( tmp1->kol, 6, 3 ) + ;
              if( mem_trudoem == 2, put_val_0( tmp1->trudoem, 9, 1 ), "" ) + ;
              put_kope( tmp1->stoim, 14 )
            add_string( s )
            For i := 2 To j
              add_string( Space( 11 ) + PadL( AllTrim( arr[ i ] ), len_n - 11 ) )
            Next
          Endif
          Select TMP1
          Skip
        Enddo
        add_string( Replicate( "─", sh ) )
      Endif
    Endif
    Select TMP
    Skip
  Enddo
  Close databases
  If fl_exit
    add_string( Replicate( "*", sh ) )
    add_string( Expand( "ПРОЦЕСС ПРЕРВАН" ) )
  Endif
  add_string( Replicate( "═", sh ) )
  If par3 == "summa"
    add_string( PadC( "Итого:", 32 ) + put_kope( s1, 12 ) + ;
      put_kope( s2, 12 ) + put_kope( s3, 12 ) + put_kope( s, 12 ) + ;
      put_kope( s1 + s2 + s, 12 ) )
  Else
    s := ""
    If mem_trudoem == 2
      s += put_val_0( s4, 9, 1 )
    Endif
    s += put_kope( s2, 14 )
    // s := umest_val(s1,14,3)
    add_string( PadL( s, sh ) )
  Endif
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 

//
Function oob1_statist( par1 )

  Local arr, arr_title, reg_print := 2, sh, HH := 58, s, s1, s2, fl, ;
    begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "orto_st1.txt", ;
    tip_tit
  Local reg, reg1, mperso, mkod, buf := save_row( MaxRow() )

  Default par1 To ""
  If ( pr_pl_bes := o_ret_pl_b() ) == 0
    Return Nil
  Endif
  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  reg1 := if( par1 == "vr", 1, if( par1 == "tehn", 2, 3 ) )
  If ( mperso := input_kperso() ) == Nil  // ==> весь персонал
    mywait()
    mperso := {}
    r_use( dir_server() + "mo_pers",, "PERSO" )
    Go Top
    Do While !Eof()
      If perso->kod > 0
        AAdd( mperso, { perso->kod, "" } )
      Endif
      Skip
    Enddo
    perso->( dbCloseArea() )
  Endif
  begin_date := arr[ 5 ]
  end_date := arr[ 6 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  dbCreate( cur_dir() + "tmp", { ;
    { "KOD",        "N",      4,      0 }, ;  // код персонала
  { "FIO",        "C",     50,      0 }, ;  // Ф.И.О. персонала
  { "KOL",        "N",      4,      0 }, ;  // количество нарядов по врачу
  { "STOIM_B",    "N",     12,      2 }, ;  // бесплатная стоимость лечения
  { "STOIM_P",    "N",     12,      2 }, ;  // платная стоимость лечения
  { "STOIM_N",    "N",     12,      2 } ;  // стоимость напыления
  } )
  dbCreate( cur_dir() + "tmp1", { ;
    { "KOD",        "N",      4,      0 }, ;  // код персонала
  { "KOD_H",      "N",      7,      0 }, ;  // код больного по hum_ort
  { "FIO",        "C",     50,      0 }, ;  // Ф.И.О. больного
  { "ADRES",      "C",     50,      0 }, ;  // адрес больного
  { "N_NAR",      "N",      5,      0 }, ;  // номер наряда
  { "STOIM_B",    "N",     12,      2 }, ;  // бесплатная стоимость лечения
  { "STOIM_P",    "N",     12,      2 }, ;  // платная стоимость лечения
  { "STOIM_N",    "N",     12,      2 } ;  // стоимость напыления
  } )
  Use ( cur_dir() + "tmp1" ) new
  Index On Str( kod, 4 ) + Str( kod_h, 7 ) to ( cur_dir() + "tmp1" )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod, 4 ) to ( cur_dir() + "tmp" )
  musluga := AllTrim( mem_ort_na )
  If Empty( musluga ) .or. musluga == "*"
    musluga := "9999999999"
  Endif
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "mo_pers",, "PERSO" )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
  Set Relation To u_kod into USL
  r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
  Set Relation To kod_k into KART
  dbSeek( DToS( begin_date ), .t. )
  Do While human->k_data <= end_date .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    Select HU
    find ( Str( human->( RecNo() ), 7 ) )
    Do While hu->kod == human->( RecNo() ) .and. !Eof()
      Do Case
      Case reg1 == 1
        mkod := hu->kod_vr
      Case reg1 == 2
        mkod := hu->kod_as
      Case reg1 == 3
        mkod := hu->kod_ms
      Endcase
      If ( fl := ( mkod > 0 .and. AScan( mperso, {| x| x[ 1 ] == mkod } ) > 0 ) )
        Select PERSO
        Goto ( mkod )
      Endif
      If fl
        s1 := s2 := s3 := s4 := 0
        If hu->tip_usl != OU_B_PLAT  // платные
          s2 += hu->stoim
        Else
          s1 += hu->stoim
        Endif
        If Like( musluga, usl->shifr )
          s3 += hu->stoim  // напыление
        Endif
        fl := .f. ; s1 := Round( s1, 2 ) ; s2 := Round( s2, 2 ) ; s3 := Round( s3, 2 )
        Do Case
        Case pr_pl_bes == 1  // платные
          // fl := empty(s1) .and. !empty(s2)
          fl := !Empty( s2 )
        Case pr_pl_bes == 2  // бесплатные
          fl := !Empty( s1 )
        Case pr_pl_bes == 3  // все
          fl := !emptyall( s1, s2 )
        Endcase
        If fl
          Select TMP
          find ( Str( mkod, 4 ) )
          If !Found()
            Append Blank
            tmp->kod := mkod
            tmp->fio := perso->fio
          Endif
          tmp->STOIM_B += s1
          tmp->STOIM_P += s2
          tmp->STOIM_N += s3
          Select TMP1
          find ( Str( mkod, 4 ) + Str( human->( RecNo() ), 7 ) )
          If !Found()
            Append Blank
            tmp1->kod   := mkod
            tmp1->FIO   := kart->fio
            tmp1->ADRES := kart->adres
            tmp1->KOD_H := human->( RecNo() )
            tmp1->N_NAR := human->nar_z
            //
            tmp->kol++
          Endif
          tmp1->STOIM_B += s1
          tmp1->STOIM_P += s2
          tmp1->STOIM_N += s3
        Endif
      Endif
      Select HU
      Skip
    Enddo
    Select HUMAN
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    Return Nil
  Endif
  If j == 0
    Return func_error( 4, "Нет сведений!" )
  Endif
  mywait()
  //
  arr_title := { ;
    "────────────────────────────────────────┬─────┬────────┬──────────┬────────╥──────────", ;
    "                                        │Наряд│Бесплат.│ Платная  │ в т.ч. ║          ", ;
    "                Ф.И.О.                  │заказ│сумма л.│сумма леч.│напыл-ие║  ИТОГО   ", ;
    "────────────────────────────────────────┴─────┴────────┴──────────┴────────╨──────────" }
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Объем работ", sh ) )
  add_string( Center( arr[ 4 ], sh ) )
  add_string( Center( pr_titul, sh ) )
  add_string( Center( { "[ По врачам ]", ;
    "[ По зубным техникам ]", ;
    "[ По медсестрам ]" }[ reg1 ], sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  //
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "mo_pers",, "PERSO" )
  Use ( cur_dir() + "tmp1" ) new
  Index On Str( kod, 4 ) + Upper( fio ) to ( cur_dir() + "tmp1" )
  Use ( cur_dir() + "tmp" ) new
  Set Relation To kod into PERSO
  Index On Upper( fio ) to ( cur_dir() + "tmp" )
  Go Top
  Do While !Eof()
    If verify_ff( HH - 3, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    s := PadR( Space( 4 ) + "[" + lstr( perso->tab_nom ) + "]  " + Upper( tmp->fio ), 41 )
    s += put_val( tmp->kol, 5 )
    s += put_kope( tmp->stoim_b, 9 ) + ;
      put_kope( tmp->stoim_p, 11 ) + ;
      put_kope( tmp->stoim_n, 9 ) + ;
      put_kope( tmp->stoim_b + tmp->stoim_p, 11 )
    add_string( s )
    add_string( Space( 4 ) + Replicate( ".", sh - 4 ) )
    Select TMP1
    find ( Str( tmp->kod, 4 ) )
    Do While tmp1->kod == tmp->kod
      s := Left( tmp1->fio, 40 ) + put_val( tmp1->n_nar, 6 )
      s += put_kope( tmp1->stoim_b, 9 ) + ;
        put_kope( tmp1->stoim_p, 11 ) + ;
        put_kope( tmp1->stoim_n, 9 ) + ;
        put_kope( tmp1->stoim_b + tmp1->stoim_p, 11 )
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( s )
      add_string( Space( 4 ) + AllTrim( tmp1->adres ) )
      Select TMP1
      Skip
    Enddo
    add_string( Replicate( "─", sh ) )
    Select TMP
    Skip
  Enddo
  Close databases
  If fl_exit
    add_string( Replicate( "*", sh ) )
    add_string( Expand( "ПРОЦЕСС ПРЕРВАН" ) )
  Endif
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 

//  16.08.21
Function ort_material( Tip_data )

  Local reg, reg1, mperso, musluga, mkod, buf := save_row( MaxRow() ), ;
    msl1usluga, msl2usluga, l_delen, mslusluga, arr, sh, HH := 76, ;
    s, s1, s2, s3, fl, begin_date, end_date, fl_exit := .f., ;
    name_file := cur_dir() + "orto_mt.txt", tip_tit, s4, arr_title := { ;
    "────────────────────────────────────────────────────────────────────────────────┬──────────────", ;
    "                           Наименование материала                               │              ", ;
    "------------------------------------------------------------------------------- │    Расход    ", ;
    " № наряда │     ФИО пациента                                                    │              ", ;
    "──────────┴─────────────────────────────────────────────────────────────────────┴──────────────" }

  Private mm_orto_mat := { ;
    { "Нет привязки", 0 }, ;
    { "Бухгалтерия", 1 }, ;
    { "Руководство", 2 };
    }

  If ( pr_pl_bes := o_ret_pl_b() ) == 0
    Return Nil
  Endif
  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  If ( glob_mas_pr := inputnist_pr( T_ROW, T_COL - 5 ) ) == NIL
    Return Nil
  Endif
  reg := 2 // техники
  If ( mperso := input_kperso() ) == Nil  // ==> весь персонал
    mywait()
    mperso := {}
    r_use( dir_server() + "mo_pers",, "PERSO" )
    Go Top
    Do While !Eof()
      If perso->kod > 0
        AAdd( mperso, { perso->kod, "" } )
      Endif
      Skip
    Enddo
    perso->( dbCloseArea() )
  Endif
  begin_date := arr[ 5 ]
  end_date := arr[ 6 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  sh := Len( arr_title[ 1 ] )
  add_string( "" )
  If Tip_data == 1
    If  f_is_ist_pr( glob_mas_pr, 3 ) .and. !f_is_ist_pr( glob_mas_pr, 1 ) .and. !f_is_ist_pr( glob_mas_pr, 2 )
      add_string( Center( "Ведомость расходования жидкости, содержащей прекурсор метилметакрила", sh ) )
      If Empty( arr[ 3 ] )
        add_string( Center( "Ведомость № _____ , от  '____' ___________ 202  г.", sh ) ) // full_date(date())
      Else
        add_string( Center( "Ведомость № " + lstr( arr[ 3 ] ) + " , от " + full_date( Date() ), sh ) )
      Endif
      add_string( Center( arr[ 4 ], sh ) )
    Else
      add_string( Center( "Расход материалов", sh ) )
      add_string( Center( arr[ 4 ], sh ) )
      add_string( Center( "[ по дате окончания лечения ]", sh ) )
    Endif
  Else
    add_string( Center( "Предварительный Расход материалов", sh ) )
    add_string( Center( arr[ 4 ], sh ) )
    add_string( Center( "[ по дате начала лечения ]", sh ) )
  Endif
  add_string( "" )
  dbCreate( cur_dir() + "tmp_it", { ;
    { "KOD",        "N",      4,      0 }, ;  // код (услуги)
  { "KOL",        "N",     12,      3 }, ;  // кол-во услуг
  { "STOIM",      "N",     14,      2 } ;  // стоимость лечения
  } )

  dbCreate( cur_dir() + "tmp", { ;
    { "KOD",        "N",      4,      0 }, ;  // код (услуги)
  { "KOL",        "N",     10,      3 }, ;  // кол-во услуг
  { "STOIM",      "N",     14,      2 } ;  // стоимость лечения
  } )

  dbCreate( cur_dir() + "tmp_vah", { ;
    { "KOD",        "N",      4,      0 }, ;  // код (услуги)
  { "human",      "N",     10,      0 }, ;  // код human
  { "FIO",        "C",     50,      0 }, ;  //
  { "Narad",      "N",     10,      0 }, ;  //
  { "KOL",        "N",     10,      3 }, ;  // кол-во услуг
  { "STOIM",      "N",     14,      2 } ;  // стоимость лечения
  } )
  Use ( cur_dir() + "tmp_vah" ) new

  Use ( cur_dir() + "tmp_it" ) new
  Index On Str( kod, 4 ) to ( cur_dir() + "tmp_it" )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod, 4 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "tip_orto",, "ORT" )
  r_use( dir_server() + "ortoped",, "OR" )
  r_use( dir_server() + "ortoped1",, "OR1" )
  r_use( dir_server() + "ortoped2",, "OR2" )
  r_use( dir_server() + "mo_pers",, "PERSO" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
  If Tip_data == 1
    r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
  Else
    r_use( dir_server() + "hum_ort", dir_server() + "hum_orto", "HUMAN" )
  Endif
  For prr := 1 To Len( mm_orto_mat )
    If f_is_ist_pr( glob_mas_pr, prr )
      If f_is_ist_pr( glob_mas_pr, 3 ) .and. !f_is_ist_pr( glob_mas_pr, 1 ) .and. !f_is_ist_pr( glob_mas_pr, 2 )
        //
      Else
        add_string( PadR( "─", sh, "─" ) )
        add_string( Center( mm_orto_mat[ prr, 1 ], sh ) )
        add_string( PadR( "─", sh, "─" ) )
        add_string( "" )
      Endif
      For pr := 1 To Len( mperso )
        Select TMP
        Zap
        Select TMP_VAH
        Zap
        T_PERSO := mperso[ pr, 1 ]
        Select HUMAN
        dbSeek( DToS( begin_date ), .t. )
        Do While iif( Tip_data == 1, human->k_data, human->data ) <= end_date .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          Select HU
          find ( Str( human->( RecNo() ), 7 ) )
          Do While hu->kod == human->( RecNo() ) .and. !Eof()
            If hu->kod_as == t_perso
              fl := .f.
              If pr_pl_bes == 1  // платные
                fl := ( hu->tip_usl != OU_B_PLAT )
              Elseif pr_pl_bes == 2  // бесплатные
                fl := ( hu->tip_usl == OU_B_PLAT )
              Elseif pr_pl_bes == 3  // ВСЕ
                FL := .t.
              Endif
              If fl
                Select TMP
                find ( Str( hu->u_kod, 4 ) )
                If !Found()
                  Append Blank
                  tmp->kod := hu->u_kod
                Endif
                tmp->kol += hu->kol
                //
                Select tmp_vah
                Append Blank
                tmp_vah->KOD   := hu->u_kod
                tmp_vah->human := hu->kod
                tmp_vah->kOL   := hu->kol
                tmp_vah->Narad := human->nar_z
                Select KART
                Goto human->kod_k
                tmp_vah->fio   := kart->fio
              Endif
            Endif
            Select HU
            Skip
          Enddo
          Select HUMAN
          Skip
        Enddo
        // пересчет в материал
        j := tmp->( LastRec() )
        If j > 0
          arr_mt := {}
          Select TMP
          Go Top
          Do While !Eof()
            Select OR2
            Go Top
            Locate For or2->kod_usl == tmp->kod
            If Found()
              t := or2->kod_tip
              Select ORT
              Goto t
              If ort->tip == 0 // техники
                Select OR1
                Go Top
                Do While !Eof()

                  If or1->kod_menu == t
                    If ( k := AScan( arr_mt, {| x| x[ 1 ] == or1->kod_ort } ) ) == 0
                      AAdd( arr_mt, { or1->kod_ort, 0, 0, "", 0, 0 } ) ; k := Len( arr_mt )
                    Endif
                    arr_mt[ k, 2 ] += tmp->kol
                    arr_mt[ k, 3 ] += or1->massa * tmp->kol
                  Endif
                  Select OR1
                  Skip
                Enddo
              Endif
            Endif
            Select TMP
            Skip
          Enddo
          // пересчет в материал 2-й раз
          arr_mt_vah := {}
          Select TMP_VAH
          Go Top
          Do While !Eof()
            Select OR2
            Go Top
            Locate For or2->kod_usl == tmp_vah->kod
            If Found()
              t := or2->kod_tip
              Select ORT
              Goto t
              If ort->tip == 0 // техники
                Select OR1
                Go Top
                Do While !Eof()

                  If or1->kod_menu == t
                    If ( k := AScan( arr_mt_vah, {| x| x[ 1 ] == or1->kod_ort .and. ;
                        x[ 6 ] == tmp_vah->narad  } ) ) == 0
                      AAdd( arr_mt_vah, { or1->kod_ort, 0, 0, "", 0, tmp_vah->narad, tmp_vah->fio } )
                      k := Len( arr_mt_vah )
                    Endif
                    arr_mt_vah[ k, 2 ] += tmp_vah->kol
                    arr_mt_vah[ k, 3 ] += or1->massa * tmp_vah->kol
                  Endif
                  Select OR1
                  Skip
                Enddo
              Endif
            Endif
            Select TMP_VAH
            Skip
          Enddo
          // присваиваем наименование и ключ важности
          If Len( arr_mt ) > 0
            Select OR
            For i := 1 To Len( arr_mt )
              Goto ( arr_mt[ i, 1 ] )
              arr_mt[ i, 4 ] := or->name
              arr_mt[ i, 5 ] := or->kod
              arr_mt[ i, 6 ] := or->kod1
            Next
            Select perso
            Goto ( mperso[ pr, 1 ] )
            xxx := 0
            For i := 1 To Len( arr_mt )
              If verify_ff( HH, .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              If arr_mt[ i, 3 ] > 0 .and. arr_mt[ i, 5 ] == prr - 1
                If xxx == 0
                  add_string( "   " + AllTrim( perso->fio ) )
                  add_string( "   ТЕХНИК" )
                  AEval( arr_title, {| x| add_string( x ) } )
                  ++xxx
                Endif
                add_string( PadR( arr_mt[ i, 4 ], 80 ) + " " + umest_val( arr_mt[ i, 3 ], 12, 3 ) )
                If arr_mt[ i, 6 ] > 0
                  // разворачиваем материал как важный
                  For jj := 1 To Len( arr_mt_vah )
                    If verify_ff( HH, .t., sh )
                      AEval( arr_title, {| x| add_string( x ) } )
                    Endif
                    //
                    If arr_mt_vah[ jj, 1 ] == arr_mt[ i, 1 ] .and. arr_mt_vah[ jj, 3 ] > 0
                      add_string( Space( 5 ) + PadR( lstr( arr_mt_vah[ jj, 6 ] ), 5 ) + " " + ;
                        PadR( arr_mt_vah[ jj, 7 ], 69 ) + " " + umest_val( arr_mt_vah[ jj, 3 ], 12, 3 ) )
                    Endif
                  Next
                Endif
              Endif
            Next
            If xxx > 0
              add_string( "" )
              add_string( "" )
            Endif
          Endif
        Endif
        //
        Select TMP
        Go Top
        Do While !Eof()
          Select TMP_IT
          find ( Str( tmp->kod, 4 ) )
          If !Found()
            Append Blank
            tmp_it->kod := tmp->kod
          Endif
          tmp_it->kol += tmp->kol
          Select TMP
          Skip
        Enddo
      Next
      // Итого по техникам
      // пересчет в материал
      j := tmp_it->( LastRec() )
      If j > 0
        arr_mt := {}
        Select TMP_IT
        Go Top
        Do While !Eof()
          Select OR2
          Go Top
          Locate For or2->kod_usl == tmp_it->kod
          If Found()
            t := or2->kod_tip
            Select ORT
            Goto t
            If ort->tip == 0 // техники
              Select OR1
              Go Top
              Do While !Eof()

                If or1->kod_menu == t
                  If ( k := AScan( arr_mt, {| x| x[ 1 ] == or1->kod_ort } ) ) == 0
                    AAdd( arr_mt, { or1->kod_ort, 0, 0, "", 0 } ) ; k := Len( arr_mt )
                  Endif
                  arr_mt[ k, 2 ] += tmp_it->kol
                  arr_mt[ k, 3 ] += or1->massa * tmp_it->kol
                Endif
                Select OR1
                Skip
              Enddo
            Endif
          Endif
          Select TMP_IT
          Skip
        Enddo
        // присваиваем наименование
        If Len( arr_mt ) > 0
          Select OR
          For i := 1 To Len( arr_mt )
            Goto ( arr_mt[ i, 1 ] )
            arr_mt[ i, 4 ] := or->name
            arr_mt[ i, 5 ] := or->kod
          Next
          add_string( "   ИТОГО по ТЕХНИКАМ" )
          AEval( arr_title, {| x| add_string( x ) } )
          For i := 1 To Len( arr_mt )
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            If arr_mt[ i, 3 ] > 0 .and. arr_mt[ i, 5 ] == prr - 1
              add_string( PadR( arr_mt[ i, 4 ], 80 ) + " " + umest_val( arr_mt[ i, 3 ], 12, 3 ) )
            Endif
          Next
          add_string( "" )
          add_string( "" )
        Endif
      Endif
    Endif
    //
    Select TMP_IT
    Zap
  Next
  //
  For prr := 1 To Len( mm_orto_mat )
    If f_is_ist_pr( glob_mas_pr, prr )
      If f_is_ist_pr( glob_mas_pr, 3 ) .and. !f_is_ist_pr( glob_mas_pr, 1 ) .and. !f_is_ist_pr( glob_mas_pr, 2 )
        //
      Else
        add_string( PadR( "─", sh, "─" ) )
        add_string( Center( mm_orto_mat[ prr, 1 ], sh ) )
        add_string( PadR( "─", sh, "─" ) )
        add_string( "" )
      Endif
      For pr := 1 To Len( mperso )
        Select TMP
        Zap
        Select TMP_VAH
        Zap
        T_PERSO := mperso[ pr, 1 ]
        Select HUMAN
        dbSeek( DToS( begin_date ), .t. )
        Do While iif( Tip_data == 1, human->k_data, human->data ) <= end_date .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          Select HU
          find ( Str( human->( RecNo() ), 7 ) )
          Do While hu->kod == human->( RecNo() ) .and. !Eof()
            If hu->kod_vr == t_perso
              fl := .f.
              If pr_pl_bes == 1  // платные
                fl := ( hu->tip_usl != OU_B_PLAT )
              Elseif pr_pl_bes == 2  // бесплатные
                fl := ( hu->tip_usl == OU_B_PLAT )
              Elseif pr_pl_bes == 3  // ВСЕ
                FL := .t.
              Endif
              If fl
                Select TMP
                find ( Str( hu->u_kod, 4 ) )
                If !Found()
                  Append Blank
                  tmp->kod := hu->u_kod
                Endif
                tmp->kol += hu->kol
              Endif
            Endif
            Select HU
            Skip
          Enddo
          Select HUMAN
          Skip
        Enddo
        // пересчет в материал
        j := tmp->( LastRec() )
        If j > 0
          arr_mt := {}
          Select TMP
          Go Top
          Do While !Eof()
            Select OR2
            Go Top
            Locate For or2->kod_usl == tmp->kod
            If Found()
              t := or2->kod_tip
              Select ORT
              Goto t
              If ort->tip == 1 // врачи
                Select OR1
                Go Top
                Do While !Eof()
                  If or1->kod_menu == t
                    If ( k := AScan( arr_mt, {| x| x[ 1 ] == or1->kod_ort } ) ) == 0
                      AAdd( arr_mt, { or1->kod_ort, 0, 0, "", 0 } ) ; k := Len( arr_mt )
                    Endif
                    arr_mt[ k, 2 ] += tmp->kol
                    arr_mt[ k, 3 ] += or1->massa * tmp->kol
                  Endif
                  Select OR1
                  Skip
                Enddo
              Endif
            Endif
            Select TMP
            Skip
          Enddo
          // присваиваем наименование
          If Len( arr_mt ) > 0
            Select OR
            For i := 1 To Len( arr_mt )
              Goto ( arr_mt[ i, 1 ] )
              arr_mt[ i, 4 ] := or->name
              arr_mt[ i, 5 ] := or->kod
            Next
            Select perso
            Goto ( mperso[ pr, 1 ] )
            xxx := 0
            For i := 1 To Len( arr_mt )
              If verify_ff( HH, .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              If arr_mt[ i, 3 ] > 0 .and. arr_mt[ i, 5 ] == prr - 1
                If xxx == 0
                  add_string( "   " + AllTrim( perso->fio ) )
                  add_string( "   ВРАЧ" )
                  AEval( arr_title, {| x| add_string( x ) } )
                  ++xxx
                Endif
                add_string( PadR( arr_mt[ i, 4 ], 80 ) + " " + umest_val( arr_mt[ i, 3 ], 12, 3 ) )
              Endif
            Next
            If xxx > 0
              add_string( "" )
              add_string( "" )
            Endif
          Endif
        Endif
        //
        Select TMP
        Go Top
        Do While !Eof()
          Select TMP_IT
          find ( Str( tmp->kod, 4 ) )
          If !Found()
            Append Blank
            tmp_it->kod := tmp->kod
          Endif
          tmp_it->kol += tmp->kol
          Select TMP
          Skip
        Enddo
      Next

      // пересчет в материал
      j := tmp_it->( LastRec() )
      If j > 0
        arr_mt := {}
        Select TMP_IT
        Go Top
        Do While !Eof()
          Select OR2
          Go Top
          Locate For or2->kod_usl == tmp_it->kod
          If Found()
            t := or2->kod_tip
            Select ORT
            Goto t
            If ort->tip == 1 // техники
              Select OR1
              Go Top
              Do While !Eof()

                If or1->kod_menu == t
                  If ( k := AScan( arr_mt, {| x| x[ 1 ] == or1->kod_ort } ) ) == 0
                    AAdd( arr_mt, { or1->kod_ort, 0, 0, "", 0 } ) ; k := Len( arr_mt )
                  Endif
                  arr_mt[ k, 2 ] += tmp_it->kol
                  arr_mt[ k, 3 ] += or1->massa * tmp_it->kol
                Endif
                Select OR1
                Skip
              Enddo
            Endif
          Endif
          Select TMP_IT
          Skip
        Enddo
        //
        // присваиваем наименование
        If Len( arr_mt ) > 0
          Select OR
          For i := 1 To Len( arr_mt )
            Goto ( arr_mt[ i, 1 ] )
            arr_mt[ i, 4 ] := or->name
            arr_mt[ i, 5 ] := or->kod
          Next
          add_string( "   ИТОГО по ВРАЧАМ" )
          AEval( arr_title, {| x| add_string( x ) } )
          For i := 1 To Len( arr_mt )
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            If arr_mt[ i, 3 ] > 0 .and. arr_mt[ i, 5 ] == prr - 1
              add_string( PadR( arr_mt[ i, 4 ], 80 ) + " " + umest_val( arr_mt[ i, 3 ], 12, 3 ) )
            Endif
          Next
          add_string( "" )
          add_string( "" )
        Endif
      Endif
    Endif
    Select TMP_IT
    Zap
  Next
  If f_is_ist_pr( glob_mas_pr, 3 ) .and. !f_is_ist_pr( glob_mas_pr, 1 ) .and. !f_is_ist_pr( glob_mas_pr, 2 )
    add_string( Center( "________________ (должность) _________________ (подпись) ________________ (расшифровка)    М.П.", sh ) )
  Endif
  Close databases
  FClose( fp )
  rest_box( buf )
  If !fl_exit
    viewtext( name_file,,,, ( sh > 80 ),,, 6 )
  Endif

  Return Nil

// 

//  13.11.16
Function ort_oms_material()

  Local reg, reg1, mperso, musluga, mkod, buf := save_row( MaxRow() ), ;
    msl1usluga, msl2usluga, l_delen, mslusluga, arr, sh, HH := 76, ;
    s, s1, s2, s3, fl, begin_date, end_date, fl_exit := .f., ;
    name_file := cur_dir() + "orto_mt.txt", tip_tit, s4, arr_title := { ;
    "────────────────────────────────────────────────────────────────────────────────┬──────────────", ;
    "                           Наименование материала                               │    Расход    ", ;
    "────────────────────────────────────────────────────────────────────────────────┴──────────────" }
  Private mm_orto_mat := { ;
    { "Нет привязки", 0 }, ;
    { "Бухгалтерия", 1 }, ;
    { "Руководство", 2 };
    }

  // if (pr_pl_bes := O_ret_pl_b()) == 0
  // return NIL
  // endif
  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  If ( glob_mas_pr := inputnist_pr( T_ROW, T_COL - 5 ) ) == NIL
    Return Nil
  Endif
  reg := 2 // техники
  If ( mperso := input_kperso() ) == Nil  // ==> весь персонал
    mywait()
    mperso := {}
    r_use( dir_server() + "mo_pers",, "PERSO" )
    Go Top
    Do While !Eof()
      If perso->kod > 0
        AAdd( mperso, { perso->kod, "" } )
      Endif
      Skip
    Enddo
    perso->( dbCloseArea() )
  Endif
  begin_date := arr[ 5 ]
  end_date := arr[ 6 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  sh := Len( arr_title[ 1 ] )
  add_string( "" )
  add_string( Center( "Расход материалов", sh ) )
  add_string( Center( arr[ 4 ], sh ) )
  add_string( Center( "[ по дате окончания лечения ]", sh ) )
  add_string( "" )
  dbCreate( cur_dir() + "tmp_it", { ;
    { "KOD",        "N",      4,      0 }, ;  // код (услуги)
  { "KOL",        "N",     12,      3 }, ;  // кол-во услуг
  { "STOIM",      "N",     14,      2 } ;  // стоимость лечения
  } )

  dbCreate( cur_dir() + "tmp", { ;
    { "KOD",        "N",      4,      0 }, ;  // код (услуги)
  { "KOL",        "N",     10,      3 }, ;  // кол-во услуг
  { "STOIM",      "N",     14,      2 } ;  // стоимость лечения
  } )
  Use ( cur_dir() + "tmp_it" ) new
  Index On Str( kod, 4 ) to ( cur_dir() + "tmp_it" )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod, 4 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "tip_orto",, "ORT" )
  r_use( dir_server() + "ortoped",, "OR" )
  r_use( dir_server() + "ortoped1",, "OR1" )
  r_use( dir_server() + "ortoped2",, "OR2" )
  r_use( dir_server() + "mo_pers",, "PERSO" )
  r_use( dir_server() + "mo_hu", dir_server() + "mo_hu", "HU" )
  //
  r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
  //
  For prr := 1 To Len( mm_orto_mat )
    // prr := 2
    If f_is_ist_pr( glob_mas_pr, prr )
      add_string( PadR( "─", sh, "─" ) )
      add_string( Center( mm_orto_mat[ prr, 1 ], sh ) )
      add_string( PadR( "─", sh, "─" ) )
      add_string( "" )
      For pr := 1 To Len( mperso )
        Select TMP
        Zap
        T_PERSO := mperso[ pr, 1 ]
        Select HUMAN
        dbSeek( DToS( begin_date ), .t. )
        Do While human->k_data <= end_date .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          Select HU
          find ( Str( human->( RecNo() ), 7 ) )
          Do While hu->kod == human->( RecNo() ) .and. !Eof()
            If hu->kod_as == t_perso
              Select TMP
              find ( Str( hu->u_kod, 4 ) )
              If !Found()
                Append Blank
                tmp->kod := hu->u_kod
              Endif
              tmp->kol += hu->kol_1
            Endif
            Select HU
            Skip
          Enddo
          Select HUMAN
          Skip
        Enddo
        // пересчет в материал
        j := tmp->( LastRec() )
        If j > 0
          arr_mt := {}
          Select TMP
          Go Top
          Do While !Eof()
            Select OR2
            Go Top
            Locate For or2->kod_usl == tmp->kod
            If Found()
              t := or2->kod_tip
              Select ORT
              Goto t
              If ort->tip == 0 // техники
                Select OR1
                Go Top
                Do While !Eof()

                  If or1->kod_menu == t
                    If ( k := AScan( arr_mt, {| x| x[ 1 ] == or1->kod_ort } ) ) == 0
                      AAdd( arr_mt, { or1->kod_ort, 0, 0, "", 0 } ) ; k := Len( arr_mt )
                    Endif
                    arr_mt[ k, 2 ] += tmp->kol
                    arr_mt[ k, 3 ] += or1->massa * tmp->kol
                  Endif
                  Select OR1
                  Skip
                Enddo
              Endif
            Endif
            Select TMP
            Skip
          Enddo
          // присваиваем наименование
          If Len( arr_mt ) > 0
            Select OR
            For i := 1 To Len( arr_mt )
              Goto ( arr_mt[ i, 1 ] )
              arr_mt[ i, 4 ] := or->name
              arr_mt[ i, 5 ] := or->kod
            Next
            Select perso
            Goto ( mperso[ pr, 1 ] )
            xxx := 0
            For i := 1 To Len( arr_mt )
              If verify_ff( HH, .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              If arr_mt[ i, 3 ] > 0 .and. arr_mt[ i, 5 ] == prr - 1
                If xxx == 0
                  add_string( "   " + AllTrim( perso->fio ) )
                  add_string( "   ТЕХНИК" )
                  AEval( arr_title, {| x| add_string( x ) } )
                  ++xxx
                Endif
                add_string( PadR( arr_mt[ i, 4 ], 80 ) + " " + umest_val( arr_mt[ i, 3 ], 12, 3 ) )
              Endif
            Next
            If xxx > 0
              add_string( "" )
              add_string( "" )
            Endif
          Endif
        Endif
        //
        Select TMP
        Go Top
        Do While !Eof()
          Select TMP_IT
          find ( Str( tmp->kod, 4 ) )
          If !Found()
            Append Blank
            tmp_it->kod := tmp->kod
          Endif
          tmp_it->kol += tmp->kol
          Select TMP
          Skip
        Enddo
      Next
      // Итого по техникам
      // пересчет в материал
      j := tmp_it->( LastRec() )
      If j > 0
        arr_mt := {}
        Select TMP_IT
        Go Top
        Do While !Eof()
          Select OR2
          Go Top
          Locate For or2->kod_usl == tmp_it->kod
          If Found()
            t := or2->kod_tip
            Select ORT
            Goto t
            If ort->tip == 0 // техники
              Select OR1
              Go Top
              Do While !Eof()

                If or1->kod_menu == t
                  If ( k := AScan( arr_mt, {| x| x[ 1 ] == or1->kod_ort } ) ) == 0
                    AAdd( arr_mt, { or1->kod_ort, 0, 0, "", 0 } ) ; k := Len( arr_mt )
                  Endif
                  arr_mt[ k, 2 ] += tmp_it->kol
                  arr_mt[ k, 3 ] += or1->massa * tmp_it->kol
                Endif
                Select OR1
                Skip
              Enddo
            Endif
          Endif
          Select TMP_IT
          Skip
        Enddo
        // присваиваем наименование
        If Len( arr_mt ) > 0
          Select OR
          For i := 1 To Len( arr_mt )
            Goto ( arr_mt[ i, 1 ] )
            arr_mt[ i, 4 ] := or->name
            arr_mt[ i, 5 ] := or->kod
          Next
          add_string( "   ИТОГО по ТЕХНИКАМ" )
          AEval( arr_title, {| x| add_string( x ) } )
          For i := 1 To Len( arr_mt )
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            If arr_mt[ i, 3 ] > 0 .and. arr_mt[ i, 5 ] == prr - 1
              add_string( PadR( arr_mt[ i, 4 ], 80 ) + " " + umest_val( arr_mt[ i, 3 ], 12, 3 ) )
            Endif
          Next
          add_string( "" )
          add_string( "" )
        Endif
      Endif
    Endif
    //
    Select TMP_IT
    Zap
  Next
  //
  For prr := 1 To Len( mm_orto_mat )
    // prr := 2
    If f_is_ist_pr( glob_mas_pr, prr )
      add_string( PadR( "─", sh, "─" ) )
      add_string( Center( mm_orto_mat[ prr, 1 ], sh ) )
      add_string( PadR( "─", sh, "─" ) )
      add_string( "" )
      For pr := 1 To Len( mperso )
        Select TMP
        Zap
        T_PERSO := mperso[ pr, 1 ]
        Select HUMAN
        dbSeek( DToS( begin_date ), .t. )
        Do While human->k_data <= end_date .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          Select HU
          find ( Str( human->( RecNo() ), 7 ) )
          Do While hu->kod == human->( RecNo() ) .and. !Eof()
            If hu->kod_vr == t_perso
              Select TMP
              find ( Str( hu->u_kod, 4 ) )
              If !Found()
                Append Blank
                tmp->kod := hu->u_kod
              Endif
              tmp->kol += hu->kol_1
            Endif
            Select HU
            Skip
          Enddo
          Select HUMAN
          Skip
        Enddo
        // пересчет в материал
        j := tmp->( LastRec() )
        If j > 0
          arr_mt := {}
          Select TMP
          Go Top
          Do While !Eof()
            Select OR2
            Go Top
            Locate For or2->kod_usl == tmp->kod
            If Found()
              t := or2->kod_tip
              Select ORT
              Goto t
              If ort->tip == 1 // врачи
                Select OR1
                Go Top
                Do While !Eof()
                  If or1->kod_menu == t
                    If ( k := AScan( arr_mt, {| x| x[ 1 ] == or1->kod_ort } ) ) == 0
                      AAdd( arr_mt, { or1->kod_ort, 0, 0, "", 0 } ) ; k := Len( arr_mt )
                    Endif
                    arr_mt[ k, 2 ] += tmp->kol
                    arr_mt[ k, 3 ] += or1->massa * tmp->kol
                  Endif
                  Select OR1
                  Skip
                Enddo
              Endif
            Endif
            Select TMP
            Skip
          Enddo
          // присваиваем наименование
          If Len( arr_mt ) > 0
            Select OR
            For i := 1 To Len( arr_mt )
              Goto ( arr_mt[ i, 1 ] )
              arr_mt[ i, 4 ] := or->name
              arr_mt[ i, 5 ] := or->kod
            Next
            Select perso
            Goto ( mperso[ pr, 1 ] )
            xxx := 0
            For i := 1 To Len( arr_mt )
              If verify_ff( HH, .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              If arr_mt[ i, 3 ] > 0 .and. arr_mt[ i, 5 ] == prr - 1
                If xxx == 0
                  add_string( "   " + AllTrim( perso->fio ) )
                  add_string( "   ВРАЧ" )
                  AEval( arr_title, {| x| add_string( x ) } )
                  ++xxx
                Endif
                add_string( PadR( arr_mt[ i, 4 ], 80 ) + " " + umest_val( arr_mt[ i, 3 ], 12, 3 ) )
              Endif
            Next
            If xxx > 0
              add_string( "" )
              add_string( "" )
            Endif
          Endif
        Endif
        //
        Select TMP
        Go Top
        Do While !Eof()
          Select TMP_IT
          find ( Str( tmp->kod, 4 ) )
          If !Found()
            Append Blank
            tmp_it->kod := tmp->kod
          Endif
          tmp_it->kol += tmp->kol
          Select TMP
          Skip
        Enddo
      Next

      // пересчет в материал
      j := tmp_it->( LastRec() )
      If j > 0
        arr_mt := {}
        Select TMP_IT
        Go Top
        Do While !Eof()
          Select OR2
          Go Top
          Locate For or2->kod_usl == tmp_it->kod
          If Found()
            t := or2->kod_tip
            Select ORT
            Goto t
            If ort->tip == 1 // техники
              Select OR1
              Go Top
              Do While !Eof()

                If or1->kod_menu == t
                  If ( k := AScan( arr_mt, {| x| x[ 1 ] == or1->kod_ort } ) ) == 0
                    AAdd( arr_mt, { or1->kod_ort, 0, 0, "", 0 } ) ; k := Len( arr_mt )
                  Endif
                  arr_mt[ k, 2 ] += tmp_it->kol
                  arr_mt[ k, 3 ] += or1->massa * tmp_it->kol
                Endif
                Select OR1
                Skip
              Enddo
            Endif
          Endif
          Select TMP_IT
          Skip
        Enddo
        //
        // присваиваем наименование
        If Len( arr_mt ) > 0
          Select OR
          For i := 1 To Len( arr_mt )
            Goto ( arr_mt[ i, 1 ] )
            arr_mt[ i, 4 ] := or->name
            arr_mt[ i, 5 ] := or->kod
          Next
          add_string( "   ИТОГО по ВРАЧАМ" )
          AEval( arr_title, {| x| add_string( x ) } )
          For i := 1 To Len( arr_mt )
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            If arr_mt[ i, 3 ] > 0 .and. arr_mt[ i, 5 ] == prr - 1
              add_string( PadR( arr_mt[ i, 4 ], 80 ) + " " + umest_val( arr_mt[ i, 3 ], 12, 3 ) )
            Endif
          Next
          add_string( "" )
          add_string( "" )
        Endif
      Endif
    Endif
    Select TMP_IT
    Zap
  Next
  Close databases
  FClose( fp )
  rest_box( buf )
  If !fl_exit
    viewtext( name_file,,,, ( sh > 80 ),,, 6 )
  Endif

  Return Nil


// 13.11.16
Function inputnist_pr( r, c, fl_max )

  Static st_ist_fin := {}
  Local i, k, t_mas, buf := SaveScreen(), l_a_ist_fin, mas_s := {}, mas := { 0, 1, 2 }

  Default fl_max To .f.
  Private mm_orto_mat := { ;
    { "Нет привязки", 0 }, ;
    { "Бухгалтерия", 1 }, ;
    { "Руководство", 2 } }
  For i := 1 To Len( mm_orto_mat )
    AAdd( mas_s, mm_orto_mat[ i, 1 ] )
  Next
  If ( k := r + 4 ) > 22
    k := 22
  Endif
  If c + 21 > 77
    c := 77 -25
  Endif
  t_mas := AClone( mas_s )
  If fl_max  // принудительное полное заполнение
    AEval( mas, {| x| AAdd( st_ist_fin, x ) } )
  Endif
  AEval( t_mas, {| x, i| ;
    t_mas[ i ] := iif( AScan( st_ist_fin, mas[ i ] ) > 0, " * ", "   " ) + t_mas[ i ] } )
  status_key( "^<Esc>^ - отказ ^<Enter>^ - подтверждение ^<Ins>^ - смена признака выбора ист.финансир." )
  Do While .t.
    l_a_ist_fin := NIL
    If Popup( r, c, k, c + 21, t_mas, i, color5, .t., "fmenu_reader",, "Привязка", "W+/W" ) > 0
      l_a_ist_fin := {} ; st_ist_fin := {}
      For i := 1 To 3
        If "*" == SubStr( t_mas[ i ], 2, 1 )
          AAdd( l_a_ist_fin, { i, AllTrim( mas_s[ i ] ) } )
          AAdd( st_ist_fin, mas[ i ] )
        Endif
      Next
      If Empty( l_a_ist_fin )
        func_error( 4, "Необходимо отметить хотя бы одну привязку!" )
        Loop
      Else
        Exit
      Endif
    Else
      Exit
    Endif
  Enddo
  RestScreen( buf )

  Return l_a_ist_fin

// 13.11.16
Function f_is_ist_pr( arr_s, ist_pr )
  Return ( AScan( arr_s, {| x| ist_pr == x[ 1 ] } ) > 0 )

// 

//
Function ort_dolgi( tip )

  Local arr, arr_title, reg_print, sh, HH := 77, buf, s, s1, s2, fl, j, ;
    begin_date, fl_exit := .f., name_file := cur_dir() + "ort_dolg.txt", ;
    mperso, i, k

  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  begin_date := arr[ 5 ]
  Private end_date := arr[ 6 ], uslovie
  buf := save_row( MaxRow() )
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  dbCreate( cur_dir() + "tmp", { ;
    { "KOD_H",      "N",      7,      0 }, ;  // код по БД hum_ort
  { "N_NAR",      "N",      5,      0 }, ;  // номер наряда
  { "STOIM",      "N",     12,      2 };   // сумма оплаты
  } )
  Use ( cur_dir() + "tmp" ) new
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
  r_use( dir_server() + "hum_oro", dir_server() + "hum_oro", "HO" )
  If tip == 1
    r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
    uslovie := "human->k_data <= end_date"
  Else
    r_use( dir_server() + "hum_ort", dir_server() + "hum_orto", "HUMAN" )
    uslovie := "human->n_data <= end_date"
  Endif
  dbSeek( DToS( begin_date ), .t. )
  Do while &uslovie .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If tip == 1 .or. ( tip == 2 .and. Empty( human->k_data ) )
      s1 := 0
      Select HO
      find ( Str( human->( RecNo() ), 7 ) )
      Do While ho->kod == human->( RecNo() ) .and. !Eof()
        s1 += ho->cena_opl
        Skip
      Enddo
      s1 := Round( s1, 2 )
      s2 := 0
      Select HU
      find ( Str( human->( RecNo() ), 7 ) )
      Do While hu->kod == human->( RecNo() ) .and. !Eof()
        If hu->tip_usl != OU_B_PLAT  // платные
          s2 += hu->stoim
        Endif
        Select HU
        Skip
      Enddo
      s2 := Round( s2, 2 )
      If !( s1 == s2 )
        Select TMP
        Append Blank
        tmp->KOD_H := human->( RecNo() )
        tmp->N_NAR := human->nar_z
        tmp->STOIM := s2 - s1
        If tmp->( LastRec() ) % 5000 == 0
          Commit
        Endif
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    Return Nil
  Endif
  If j == 0
    Return func_error( 4, "Нет сведений!" )
  Endif
  mywait()
  //
  arr_title := { ;
    "─────┬────────────────────────────────────────────────┬─────┬─────┬───────────", ;
    "Наряд│                                                │ Код │ Код │   Сумма   ", ;
    "заказ│         Ф.И.О. и адрес больного                │врача│техн.│   долга   ", ;
    "─────┴────────────────────────────────────────────────┴─────┴─────┴───────────" }
  sh := Len( arr_title[ 1 ] )
  reg_print := 5
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Долги по больным", sh ) )
  add_string( Center( arr[ 4 ], sh ) )
  If tip == 1
    add_string( Center( "[ по дате окончания лечения ]", sh ) )
  Else
    add_string( Center( "[ по дате начала лечения ]", sh ) )
    add_string( Center( "незакрытые наряды-заказы", sh ) )
  Endif
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "hum_oro", dir_server() + "hum_oro", "HO" )
  r_use( dir_server() + "hum_ort",, "HUMAN" )
  Set Relation To kod_k into KART
  Use ( cur_dir() + "tmp" ) new
  Index On Str( n_nar, 5 ) to ( cur_dir() + "tmp" )
  Set Relation To kod_h into HUMAN
  j := s1 := 0
  Go Top
  Do While !Eof()
    add_string( "" )
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    ++j ; s1 += tmp->stoim
    add_string( PadC( lstr( tmp->n_nar ), 5 ) + "  " + ;
      PadR( AllTrim( kart->fio ), 47 ) + ;
      put_val( human->kod_vr, 6 ) + ;
      put_val( human->kod_as, 6 ) + ;
      put_kope( tmp->stoim, 12 ) )
    add_string( Space( 7 ) + AllTrim( kart->adres ) )
    Select TMP
    Skip
  Enddo
  Close databases
  If fl_exit
    add_string( Replicate( "*", sh ) )
    add_string( Expand( "ПРОЦЕСС ПРЕРВАН" ) )
  Endif
  add_string( Replicate( "─", sh ) )
  add_string( PadR( "Кол-во больных - " + lstr( j ), 25 ) + PadL( put_kop( s1, 15 ), sh - 25 ) )
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 

// 09.03.14
Function ort_otkr_nar( par1, par2 )

  Local arr, arr_title, reg_print, sh, HH := 58, buf, s, s1, s2, fl, j, ;
    begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "orto_o1.txt", ;
    mperso, i, k, is_fio := 1

  Default par2 To 1
  If ( pr_pl_bes := o_ret_pl_b() ) == 0
    Return Nil
  Endif
  If par1 == 1
    If ( arr := year_month() ) == NIL
      Return Nil
    Endif
    begin_date := arr[ 5 ]
    end_date := arr[ 6 ]
  Endif
  If par2 == 1
    If ( is_fio := f_alert( { 'Каким образом производить сортировку документа.', ;
        "Выберите действие:" }, ;
        { " По ~Ф.И.О. ", ;
        " По ~номеру наряда " }, ;
        1, "N+/BG", "R/BG", 17,, col1menu ) ) == 0
      Return Nil
    Endif
  Endif
  buf := save_row( MaxRow() )
  mywait()
  dbCreate( cur_dir() + "tmp", { ;
    { "KOD",        "N",      4,      0 }, ;  // код по БД tmp1
  { "KOD_H",      "N",      7,      0 }, ;  // код по БД hum_ort
  { "FIO",        "C",     50,      0 }, ;  // Ф.И.О. больного
  { "ADRES",      "C",     50,      0 }, ;  // адрес больного
  { "KOD_VR",     "N",      4,      0 }, ;  // код врача
  { "N_NAR",      "N",      5,      0 }, ;  // номер наряда
  { "DATA",       "D",      8,      0 }, ;  // дата наряда
  { "STOIM_B",    "N",     12,      2 }, ;  // бесплатные больные
  { "STOIM_P",    "N",     12,      2 } ;  // платные больные
  } )
  Use ( cur_dir() + "tmp" ) new
  dbCreate( cur_dir() + "tmpvr", { ;
    { "KOD_VR",     "N",      4,      0 }, ;  // код врача
  { "STOIM_B",    "N",     12,      2 }, ;  // бесплатные больные
  { "STOIM_P",    "N",     12,      2 } ;  // платные больные
  } )
  Use ( cur_dir() + "tmpvr" ) new
  Index On Str( kod_vr, 4 ) to ( cur_dir() + "tmpvr" )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "hum_ort",, "HUMAN" )
  Set Relation To kod_k into KART
  If par1 == 1
    Set Index to ( dir_server() + "hum_orto" )
    dbSeek( DToS( begin_date ), .t. )
    If is_open
      Index On DToS( data ) to ( cur_dir() + "tmp_hum" ) While data <= end_date For Empty( k_data )
    Else
      Index On DToS( data ) to ( cur_dir() + "tmp_hum" ) While data <= end_date
    Endif
  Else
    Index On DToS( data ) to ( cur_dir() + "tmp_hum" ) For Empty( k_data )
  Endif
  Go Top
  Do While !Eof()
    s1 := s2 := 0 ; fl := .f.
    Do Case
    Case pr_pl_bes == 1  // платные
      fl := ( human->tip_usl != OU_B_PLAT )
      s1 := human->cena_opl
    Case pr_pl_bes == 2  // бесплатные
      fl := ( human->tip_usl == OU_B_PLAT )
      s1 := human->cena_opl
    Case pr_pl_bes == 3  // все
      fl := .t.
      If human->tip_usl != OU_B_PLAT  // платные
        s2 := human->cena_opl
      Else
        s1 := human->cena_opl
      Endif
    Endcase
    If fl
      If fl
        Select TMP
        Append Blank
        tmp->FIO := kart->fio
        tmp->ADRES := kart->adres
        tmp->KOD_H := human->( RecNo() )
        tmp->KOD_VR := human->kod_vr
        tmp->N_NAR := human->nar_z
        tmp->DATA := human->data
        tmp->STOIM_B := s1
        tmp->STOIM_P := s2
        //
        Select TMPVR
        find ( Str( human->kod_vr, 4 ) )
        If !Found()
          Append Blank
          tmpvr->KOD_VR := human->kod_vr
        Endif
        tmpvr->STOIM_B += s1
        tmpvr->STOIM_P += s2
        If tmp->( LastRec() ) % 5000 == 0
          Commit
        Endif
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If j == 0
    Return func_error( 4, "Нет сведений!" )
  Endif
  mywait()
  //
  arr_title := { ;
    "─────┬────────", ;
    "Наряд│  Дата  ", ;
    "номер│ наряда ", ;
    "─────┴────────" }
  If par2 == 1
    arr_title[ 1 ] += "┬─────"
    arr_title[ 2 ] += "│     "
    arr_title[ 3 ] += "│ Врач"
    arr_title[ 4 ] += "┴─────"
  Endif
  arr_title[ 1 ] += "┬────────────────────────────────────────"
  arr_title[ 2 ] += "│                                        "
  arr_title[ 3 ] += "│              Ф.И.О., адрес             "
  arr_title[ 4 ] += "┴────────────────────────────────────────"
  reg_print := 2
  If pr_pl_bes < 3
    arr_title[ 1 ] += "┬───────────"
    arr_title[ 2 ] += "│   Сумма   "
    arr_title[ 3 ] += "│  лечения  "
    arr_title[ 4 ] += "┴───────────"
  Else
    arr_title[ 1 ] += "┬────────┬──────────"
    arr_title[ 2 ] += "│Бесплат.│ Платная  "
    arr_title[ 3 ] += "│сумма л.│сумма леч."
    arr_title[ 4 ] += "┴────────┴──────────"
  Endif
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  If par1 == 1
    add_string( Center( "Статистика по " + iif( is_open, "открытым ", "" ) + "нарядам-заказам", sh ) )
    add_string( Center( arr[ 4 ], sh ) )
  Else
    add_string( Center( "Незакрытые наряды-заказы", sh ) )
  Endif
  add_string( Center( pr_titul, sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  s1 := s2 := 0
  r_use( dir_server() + "mo_pers",, "PERSO" )
  Use ( cur_dir() + "tmpvr" ) index ( cur_dir() + "tmpvr" ) new
  Use ( cur_dir() + "tmp" ) new
  If par2 == 1
    If is_fio == 1
      Index On Upper( fio ) to ( cur_dir() + "tmp" )
    Else
      Index On Str( n_nar, 6 ) to ( cur_dir() + "tmp" )
    Endif
  Else
    Set Relation To kod_vr into perso
    Index On Upper( perso->fio ) + Upper( fio ) to ( cur_dir() + "tmp" )
    old_vr := 0
  Endif
  Go Top
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    If par2 == 2 .and. old_vr != tmp->kod_vr
      Select TMPVR
      find ( Str( tmp->kod_vr, 4 ) )
      s := "    [" + lstr( perso->tab_nom ) + "] " + AllTrim( Upper( perso->fio ) )
      If pr_pl_bes < 3
        s := PadR( s, sh - 12 ) + put_kope( tmpvr->stoim_b, 12 )
      Else
        s := PadR( s, sh - 20 ) + put_kope( tmpvr->stoim_b, 9 ) + put_kope( tmpvr->stoim_p, 11 )
      Endif
      add_string( CharRepl( " ", s, "." ) )
    Endif
    s := PadC( lstr( tmp->n_nar ), 5 ) + " " + date_8( tmp->data )
    If par2 == 1
      s += put_val( perso->tab_nom, 6 )
    Endif
    s += " " + Left( tmp->fio, 40 )
    s1 += tmp->stoim_b
    If pr_pl_bes < 3
      s += put_kope( tmp->stoim_b, 12 )
    Else
      s += put_kope( tmp->stoim_b, 9 ) + ;
        put_kope( tmp->stoim_p, 11 )
      s2 += tmp->stoim_p
    Endif
    add_string( s )
    add_string( Space( { 21, 15 }[ par2 ] ) + tmp->adres )
    If par2 == 2
      old_vr := tmp->kod_vr
    Endif
    Select TMP
    Skip
  Enddo
  Close databases
  If fl_exit
    add_string( Replicate( "*", sh ) )
    add_string( Expand( "ПРОЦЕСС ПРЕРВАН" ) )
  Endif
  add_string( Replicate( "─", sh ) )
  If pr_pl_bes < 3
    s := put_kope( s1, 12 )
  Else
    s := put_kope( s1, 9 ) + put_kope( s2, 11 )
  Endif
  add_string( PadR( "Кол-во нарядов - " + lstr( j ), sh - 20 ) + PadL( s, 20 ) )
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 

// 22.03.17
Function ort_mnog_poisk()

  Local mm_tmp := {}, k
  Local buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    tmp_help := help_code, hGauge, name_file := cur_dir() + "ort_mnog.txt", ;
    sh := 80, HH := 77, r1 := 1, a_diagnoz[ 3 ], fl_stom := .f., ;
    mm_da_net := { { "нет", 1 }, { "да ", 2 } }, lvid_doc := 0, ;
    menu_plat := { { "платные    ", 0 }, ;
    { "бесплатные ", 1 }, ;
    { "взаимозачет", 2 }, ;
    { "ДМС        ", 3 } }, ;
    menu_kb := { { "платный    ", 0 }, ;
    { "бесплатный ", 1 }, ;
    { "взаимозачет", 2 }, ;
    { "ДМС        ", 3 } }, ;
    tmp_file := "tmp_mn_p" + sdbf()
  Private arr_doc := { "Дата рожд.", ;
    "Адрес", ;
    "Вид,N уч/док", ;
    "Наряд-заказ", ;
    "Диагноз", ;
    "Врач/Техник", ;
    "Услуги", ;
    "Номер очереди", ;
    "Примечание" }

  If input_uch( T_ROW, T_COL - 5 ) == NIL
    Return Nil
  Endif
  Private pr_arr := {}, pr_arr_otd := {}, is_talon := ret_is_talon(), ;
    pdata, pk_data
  //
  r_use( dir_server() + "mo_otd",, "OTD" )
  dbEval( {|| AAdd( pr_arr, { otd->( RecNo() ), otd->name, otd->kod_lpu, "" } ) }, ;
    {|| otd->kod_lpu == glob_uch[ 1 ] .and. between_date( otd->dbegino, otd->dendo, sys_date ) } )
  r_use( dir_server() + "mo_uch",, "UCH" )
  AEval( pr_arr, {| x, i| dbGoto( x[ 3 ] ), pr_arr[ i, 4 ] := uch->name } )
  //
  ASort( pr_arr,,, {| x, y| iif( x[ 3 ] == y[ 3 ], Upper( x[ 2 ] ) < Upper( y[ 2 ] ), ;
    Upper( x[ 4 ] ) < Upper( y[ 4 ] ) ) } )
  AEval( pr_arr, {| x| AAdd( pr_arr_otd, x[ 2 ] + " " + x[ 4 ] ) } )
  Close databases
  //
  lvid_doc := SetBit( lvid_doc, 1 )
  lvid_doc := SetBit( lvid_doc, 4 )
  //
  dbCreate( cur_dir() + "tmp", { ;
    { "U_KOD",    "N",      4,      0 }, ;  // код услуги
  { "U_SHIFR",    "C",     10,      0 }, ;  // шифр услуги
  { "U_NAME",     "C",     65,      0 } ;  // наименование услуги
  } )
  Use ( cur_dir() + "tmp" )
  Index On Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
  Index On fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
  tmp->( dbCloseArea() )
  AAdd( mm_tmp, { "data", "N", 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    if( k == nil, nil, ( pdata := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    'Дата наряда-заказа' } )
  AAdd( mm_tmp, { "k_data", "N", 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    if( k == nil, nil, ( pk_data := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    'Дата окончания лечения' } )
  AAdd( mm_tmp, { "nar_z", "N", 5, 0,, ;
    nil, ;
    0, nil, ;
    "Номер наряда-заказа [с]" } )
  AAdd( mm_tmp, { "nar_z2", "N", 5, 0,, ;
    nil, ;
    0, nil, ;
    "                    [по]" } )
  AAdd( mm_tmp, { "tip_nar", "N", 2, 0, NIL, ;
    {| x| menu_reader( x, menu_kb, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    "Категория больного (наряда)" } )
  If is_talon
    AAdd( mm_tmp, { "kategor", "N", 2, 0, NIL, ;
      {| x| menu_reader( x, mo_cut_menu( stm_kategor ), A__MENUVERT ) }, ;
      0, {|| Space( 10 ) }, ;
      "Код категории льготы" } )
  Endif
  AAdd( mm_tmp, { "uch_doc", "C", 10, 0, "@!", ;
    nil, ;
    Space( 10 ), nil, ;
    "Вид и номер учетного документа (шаблон)" } )
  Private arr_uchast := {}
  If is_uchastok > 0
    AAdd( mm_tmp, { "bukva", "C", 1, 0, "@!", ;
      nil, ;
      " ", nil, ;
      "Буква (перед участком)" } )
    AAdd( mm_tmp, { "uchast", "N", 1, 0,, ;
      {| x| menu_reader( x, ;
      { {|k, r, c| get_uchast( r + 1, c ) } }, A__FUNCTION ) }, ;
      0, {|| init_uchast( arr_uchast ) }, ;
      "Участок (участки)" } )
  Endif
  AAdd( mm_tmp, { "fio", "C", 20, 0, "@!", ;
    nil, ;
    Space( 20 ), nil, ;
    "ФИО (начальные буквы или шаблон)" } )
  AAdd( mm_tmp, { "inostran", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    "Документы иностранных граждан:" } )
  AAdd( mm_tmp, { "adres", "C", 20, 0, "@!", ;
    nil, ;
    Space( 20 ), nil, ;
    "Адрес (подстрока или шаблон)" } )
  AAdd( mm_tmp, { "mr_dol", "C", 20, 0, "@!", ;
    nil, ;
    Space( 20 ), nil, ;
    "Место работы (подстрока или шаблон)" } )
  AAdd( mm_tmp, { "pol", "C", 1, 0, "!", ;
    nil, ;
    " ", nil, ;
    "Пол", {|| mpol $ " МЖ" } } )
  AAdd( mm_tmp, { "vzros_reb", "N", 2, 0, NIL, ;
    {| x| menu_reader( x, menu_vzros, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    "Возрастная принадлежность" } )
  AAdd( mm_tmp, { "god_r_min", "D", 8, 0,, ;
    nil, ;
    CToD( "" ), nil, ;
    "Дата рождения (минимальная)" } )
  AAdd( mm_tmp, { "god_r_max", "D", 8, 0,, ;
    nil, ;
    CToD( "" ), nil, ;
    "Дата рождения (максимальная)" } )
  AAdd( mm_tmp, { "rab_nerab", "N", 2, 0, NIL, ;
    {| x| menu_reader( x, menu_rab, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    "Работающий/неработающий" } )
/*aadd(mm_tmp, {"mi_git","N",2,0,NIL,;
              {|x|menu_reader(x,menu_mest,A__MENUVERT)},;
              -1,{|| space(10) },;
              "МЕСТО ЖИТЕЛЬСТВА: г/о/и",;
              {|g,o|valid_mest_inog(g,o,2)} })
aadd(mm_tmp, {"rajon_git","N",2,0,NIL,;
              {|x|menu_reader(x,{dir_server()+"rajon",,;
                      {||FIELD->tip==m1mi_git}},A__POPUPMENU)},;
              0,{|| space(10) },;
              "   район",,;
              {|| equalany(m1mi_git,0,1) } })
aadd(mm_tmp, {"mest_inog","N",2,0,NIL,;
              {|x|menu_reader(x,menu_mest,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Финансирование: г/о/и",;
              {|g,o|valid_mest_inog(g,o)} })
aadd(mm_tmp, {"rajon","N",2,0,NIL,;
              {|x|menu_reader(x,{dir_server()+"rajon",,;
                      {||FIELD->tip==m1mest_inog}},A__POPUPMENU)},;
              0,{|| space(10) },;
              "   район",,;
              {|| equalany(m1mest_inog,0,1) } })
              */
  AAdd( mm_tmp, { "kod_vr1", "N", 5, 0, NIL, ;
    nil, ;
    0, nil, ;
    "Лечащий врач", ;
    {| g| st_v_vrach( g, "mkod_vr" ) } } )
  AAdd( mm_tmp, { "kod_vr", "C", 50, 0, NIL, ;
    nil, ;
    Space( 50 ), nil, ;
    "            ",, ;
    {|| .f. } } )
  AAdd( mm_tmp, { "kod_as1", "N", 5, 0, NIL, ;
    nil, ;
    0, nil, ;
    "Зубной техник", ;
    {| g| st_v_vrach( g, "mkod_as" ) } } )
  AAdd( mm_tmp, { "kod_as", "C", 50, 0, NIL, ;
    nil, ;
    Space( 50 ), nil, ;
    "            ",, ;
    {|| .f. } } )
  AAdd( mm_tmp, { "diag1", "C", 6, 0, "@!", ;
    nil, ;
    Space( 6 ), nil, ;
    "Шифры заболеваний [ включаемые ]: 1)", ;
    {| g| v_ort_diag() } } )
  AAdd( mm_tmp, { "diag2", "C", 6, 0, "@!", ;
    nil, ;
    Space( 6 ), nil, ;
    "                                  2)", ;
    {| g| v_ort_diag() } } )
  AAdd( mm_tmp, { "diag3", "C", 6, 0, "@!", ;
    nil, ;
    Space( 6 ), nil, ;
    "                                  3)", ;
    {| g| v_ort_diag() } } )
  AAdd( mm_tmp, { "diag4", "C", 6, 0, "@!", ;
    nil, ;
    Space( 6 ), nil, ;
    "                                  4)", ;
    {| g| v_ort_diag() } } )
  AAdd( mm_tmp, { "idiag1", "C", 6, 0, "@!", ;
    nil, ;
    Space( 6 ), nil, ;
    "Шифры заболеваний [ исключаемые ]: 1)", ;
    {| g| v_ort_diag() } } )
  AAdd( mm_tmp, { "idiag2", "C", 6, 0, "@!", ;
    nil, ;
    Space( 6 ), nil, ;
    "                                   2)", ;
    {| g| v_ort_diag() } } )
  AAdd( mm_tmp, { "idiag3", "C", 6, 0, "@!", ;
    nil, ;
    Space( 6 ), nil, ;
    "                                   3)", ;
    {| g| v_ort_diag() } } )
  AAdd( mm_tmp, { "idiag4", "C", 6, 0, "@!", ;
    nil, ;
    Space( 6 ), nil, ;
    "                                   4)", ;
    {| g| v_ort_diag() } } )
  If yes_h_otd == 1
    AAdd( mm_tmp, { "otd", "N", 3, 0, NIL, ;
      {| x| menu_reader( x, ;
      { {|k, r, c| get_otd( k, r + 1, c ) } }, A__FUNCTION ) }, ;
      0, {|| Space( 10 ) }, ;
      "Отделение" } )
  Endif
  AAdd( mm_tmp, { "tip_usl", "N", 2, 0, NIL, ;
    {| x| menu_reader( x, menu_plat, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    "Тип (оплаты) услуг" } )
  AAdd( mm_tmp, { "uslugi", "N", 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {|k, r, c| ob2_v_usl( .t., r + 1 ) } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    "Оказанные услуги" } )
  AAdd( mm_tmp, { "otd_usl", "N", 3, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {|k, r, c| get_otd( k, r + 1, c ) } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    "Отделение, в котором оказана услуга" } )
  AAdd( mm_tmp, { "ukod_vr1", "N", 5, 0, NIL, ;
    nil, ;
    0, nil, ;
    "Врач, оказавший услугу(и)", ;
    {| g| st_v_vrach( g, "mukod_vr" ) } } )
  AAdd( mm_tmp, { "ukod_vr", "C", 50, 0, NIL, ;
    nil, ;
    Space( 50 ), nil, ;
    "                         ",, ;
    {|| .f. } } )
  AAdd( mm_tmp, { "isvr", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    "Проставлен код врача, оказавшего услугу(и)",, ;
    {|| mukod_vr1 == 0 } } )
  AAdd( mm_tmp, { "ukod_as1", "N", 5, 0, NIL, ;
    nil, ;
    0, nil, ;
    "Техник, оказавший услугу(и)", ;
    {| g| st_v_vrach( g, "mukod_as" ) } } )
  AAdd( mm_tmp, { "ukod_as", "C", 50, 0, NIL, ;
    nil, ;
    Space( 50 ), nil, ;
    "                         ",, ;
    {|| .f. } } )
  AAdd( mm_tmp, { "ukod_ms1", "N", 5, 0, NIL, ;
    nil, ;
    0, nil, ;
    "Медсестра, оказавшая услугу(и)", ;
    {| g| st_v_vrach( g, "mukod_ms" ) } } )
  AAdd( mm_tmp, { "ukod_ms", "C", 50, 0, NIL, ;
    nil, ;
    Space( 50 ), nil, ;
    "                         ",, ;
    {|| .f. } } )
  AAdd( mm_tmp, { "PRICH_POL", "N", 3, 0, NIL, ;
    {| x| menu_reader( x, { dir_server() + "ort_brk" }, A__POPUPEDIT ) }, ;
    0, {|| Space( 10 ) }, ;
    "Причина поломки протеза" } )
  AAdd( mm_tmp, { "summa_min", "N", 10, 2,, ;
    nil, ;
    0, nil, ;
    "Сумма лечения (минимальная)" } )
  AAdd( mm_tmp, { "summa_max", "N", 10, 2,, ;
    nil, ;
    0, nil, ;
    "Сумма лечения (максимальная)" } )
  AAdd( mm_tmp, { "vid_doc", "N", 17, 0, NIL, ;
    {| x| menu_reader( x, arr_doc, A__MENUBIT ) }, ;
    lvid_doc, {| x| inieditspr( A__MENUBIT, arr_doc, x ) }, ;
    "Вид документа", NIL } )
  Delete File ( tmp_file )
  init_base( tmp_file,, mm_tmp, 0 )
  //
  r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
  pict_vr := "99999"
  k := f_edit_spr( A__APPEND, mm_tmp, "множественному запросу", ;
    "g_use(cur_dir()+'tmp_mn_p',,,.t.,.t.)", 0, 1,,,,, "writeOmn_p" )
  If k > 0
    Use ( tmp_file ) New Alias MN
    If is_talon .and. mn->kategor == 0
      is_talon := .f.
    Endif
    // заменить таб.номер на код
    r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERS" )
    If mn->kod_vr1 > 0
      find ( Str( mn->kod_vr1, 5 ) )
      If Found()
        mn->kod_vr1 := pers->kod
      Endif
    Endif
    If mn->kod_as1 > 0
      find ( Str( mn->kod_as1, 5 ) )
      If Found()
        mn->kod_as1 := pers->kod
      Endif
    Endif
    If mn->ukod_vr1 > 0
      find ( Str( mn->ukod_vr1, 5 ) )
      If Found()
        mn->ukod_vr1 := pers->kod
      Endif
    Endif
    If mn->ukod_as1 > 0
      find ( Str( mn->ukod_as1, 5 ) )
      If Found()
        mn->ukod_as1 := pers->kod
      Endif
    Endif
    pers->( dbCloseArea() )
    //
    Private much_doc := "", mfio := "", madres := "", mmr_dol := ""
    If !Empty( mn->uch_doc )
      much_doc := AllTrim( mn->uch_doc )
      If !( Right( much_doc, 1 ) == "*" )
        much_doc += "*"
      Endif
    Endif
    If !Empty( mn->fio )
      mfio := AllTrim( mn->fio )
      If !( Right( mfio, 1 ) == "*" )
        mfio += "*"
      Endif
    Endif
    If !Empty( mn->adres )
      madres := AllTrim( mn->adres )
      If !( Left( madres, 1 ) == "*" )
        madres := "*" + madres
      Endif
      If !( Right( madres, 1 ) == "*" )
        madres += "*"
      Endif
    Endif
    If !Empty( mn->mr_dol )
      mmr_dol := AllTrim( mn->mr_dol )
      If !( Left( mmr_dol, 1 ) == "*" )
        mmr_dol := "*" + mmr_dol
      Endif
      If !( Right( mmr_dol, 1 ) == "*" )
        mmr_dol += "*"
      Endif
    Endif
    Private mvkl_diag := ""
    If !Empty( mn->diag1 )
      mvkl_diag += mn->diag1 + ","
    Endif
    If !Empty( mn->diag2 )
      mvkl_diag += mn->diag2 + ","
    Endif
    If !Empty( mn->diag3 )
      mvkl_diag += mn->diag3 + ","
    Endif
    If !Empty( mn->diag4 )
      mvkl_diag += mn->diag4 + ","
    Endif
    If !Empty( mvkl_diag )
      mvkl_diag := SubStr( mvkl_diag, 1, Len( mvkl_diag ) -1 )
    Endif
    Private misk_diag := ""
    If !Empty( mn->idiag1 )
      misk_diag += mn->idiag1 + ","
    Endif
    If !Empty( mn->idiag2 )
      misk_diag += mn->idiag2 + ","
    Endif
    If !Empty( mn->idiag3 )
      misk_diag += mn->idiag3 + ","
    Endif
    If !Empty( mn->idiag4 )
      misk_diag += mn->idiag4 + ","
    Endif
    If !Empty( misk_diag )
      misk_diag := SubStr( misk_diag, 1, Len( misk_diag ) -1 )
    Endif
    Private arr_usl := {}, fl_summa := .t., flag_hu := .f.
    If mn->otd_usl > 0 .or. mn->isvr > 0 .or. mn->ukod_vr1 > 0 .or. ;
        mn->ukod_as1 > 0 .or. mn->ukod_ms1 > 0 .or. ;
        mn->uslugi > 0 .or. mn->tip_usl >= 0 .or. IsBit( mn->vid_doc, 7 )
      fl_summa := .f.
      flag_hu := .t.
    Endif
    If mn->uslugi > 0
      Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmpn" ) new
      Go Top
      dbEval( {|| AAdd( arr_usl, { tmp->u_kod, tmp->u_shifr, tmp->u_name, 0, 0 } ) } )
      tmp->( dbCloseArea() )
    Endif
    dbCreate( cur_dir() + "tmp", { { "kod", "N", 7, 0 }, ;
      { "stoim", "N", 10, 2 } } )
    Use ( cur_dir() + "tmp" ) new
    dbCreate( cur_dir() + "tmp1", { { "kod", "N", 7, 0 }, ;
      { "shifr", "C", 15, 0 } } )
    Use ( cur_dir() + "tmp1" ) new
    fl_exit := .f.
    status_key( "^<Esc>^ - прервать поиск" )
    Private c_view := 0, c_found := 0
    If is_talon
      ab_open()
    Endif
    r_use( dir_server() + "kartote2",, "KART2" )
    r_use( dir_server() + "kartote_",, "KART_" )
    r_use( dir_server() + "kartotek",, "KART" )
    Set Relation To RecNo() into KART_, RecNo() into KART2
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
    Set Relation To u_kod into USL
    If pk_data != NIL
      r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
      Set Relation To kod_k into KART
      dbSeek( DToS( pk_data[ 5 ] ), .t. )
      Do While human->k_data <= pk_data[ 6 ] .and. !Eof()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human->lpu == glob_uch[ 1 ]
          s1_mnog_poisk( @c_view, @c_found )
        Endif
        Select HUMAN
        Skip
      Enddo
    Else
      r_use( dir_server() + "hum_ort", dir_server() + "hum_orto", "HUMAN" )
      Set Relation To kod_k into KART
      dbSeek( DToS( pdata[ 5 ] ), .t. )
      Do While human->data <= pdata[ 6 ] .and. !Eof()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human->lpu == glob_uch[ 1 ]
          s1_mnog_poisk( @c_view, @c_found )
        Endif
        Select HUMAN
        Skip
      Enddo
    Endif
    j := tmp->( LastRec() )
    Close databases
    If fl_exit
      // ничего - просто выход
    Elseif j == 0
      func_error( 4, "Нет сведений!" )
    Else
      mywait()
      s1 := if( fl_summa, "  Сумма  ", "Стоимость" )
      s2 := if( fl_summa, " лечения ", "  услуг  " )
      arr_title := { ;
        "────────────────────────────────────────┬─────────", ;
        "             Ф.И.О. больного            │" + s1,;
        "                                        │" + s2,;
        "────────────────────────────────────────┴─────────" }
      Use ( tmp_file ) New Alias MN
      If IsBit( mn->vid_doc, 1 )
        arr_title[ 1 ] += "┬────────"
        arr_title[ 2 ] += "│  Дата  "
        arr_title[ 3 ] += "│рождения"
        arr_title[ 4 ] += "┴────────"
      Endif
      If IsBit( mn->vid_doc, 2 )
        arr_title[ 1 ] += "┬────────────────────────"
        arr_title[ 2 ] += "│         Адрес          "
        arr_title[ 3 ] += "│                        "
        arr_title[ 4 ] += "┴────────────────────────"
      Endif
      If IsBit( mn->vid_doc, 3 )
        arr_title[ 1 ] += "┬──────────"
        arr_title[ 2 ] += "│ Вид и N  "
        arr_title[ 3 ] += "│ уч.док-та"
        arr_title[ 4 ] += "┴──────────"
      Endif
      If IsBit( mn->vid_doc, 4 )
        arr_title[ 1 ] += "┬────────"
        arr_title[ 2 ] += "│ Наряд  "
        arr_title[ 3 ] += "│N, дата "
        arr_title[ 4 ] += "┴────────"
      Endif
      If IsBit( mn->vid_doc, 5 )
        arr_title[ 1 ] += "┬─────────────"
        arr_title[ 2 ] += "│   Диагноз   "
        arr_title[ 3 ] += "│             "
        arr_title[ 4 ] += "┴─────────────"
      Endif
      If IsBit( mn->vid_doc, 6 )
        arr_title[ 1 ] += "┬─────"
        arr_title[ 2 ] += "│Врач/"
        arr_title[ 3 ] += "│техн."
        arr_title[ 4 ] += "┴─────"
      Endif
      If IsBit( mn->vid_doc, 7 )
        arr_title[ 1 ] += "┬───────────────────────"
        arr_title[ 2 ] += "│                       "
        arr_title[ 3 ] += "│     Список услуг      "
        arr_title[ 4 ] += "┴───────────────────────"
      Endif
      If IsBit( mn->vid_doc, 8 )
        arr_title[ 1 ] += "┬──────────"
        arr_title[ 2 ] += "│  Номер   "
        arr_title[ 3 ] += "│ очереди  "
        arr_title[ 4 ] += "┴──────────"
      Endif
      If IsBit( mn->vid_doc, 9 )
        arr_title[ 1 ] += "┬───────────────"
        arr_title[ 2 ] += "│               "
        arr_title[ 3 ] += "│  Примечание   "
        arr_title[ 4 ] += "┴───────────────"
      Endif
      sh := Len( arr_title[ 1 ] )
      If sh <= 65
        sh := 65
        reg_print := 4
      Elseif sh <= 84
        reg_print := 5
      Elseif sh <= 120
        reg_print := 6
      Elseif sh <= 160
        reg_print := 5
      Else
        reg_print := 6
      Endif
      r_use( dir_server() + "mo_pers",, "PERSO" )
      r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
      r_use( dir_server() + "kartote2",, "KART2" )
      r_use( dir_server() + "kartote_",, "KART_" )
      r_use( dir_server() + "kartotek",, "KART" )
      Set Relation To RecNo() into KART_, RecNo() into KART2
      r_use( dir_server() + "hum_ort",, "HUMAN" )
      Set Relation To kod_k into KART
      Use ( cur_dir() + "tmp1" ) new
      Index On Str( kod, 7 ) + fsort_usl( shifr ) to ( cur_dir() + "tmp1" )
      Use ( cur_dir() + "tmp" ) new
      Set Relation To kod into HUMAN
      If pk_data != NIL
        Index On Upper( kart->fio ) + DToS( human->k_data ) to ( cur_dir() + "tmp" )
      Else
        Index On Upper( kart->fio ) + DToS( human->data ) to ( cur_dir() + "tmp" )
      Endif
      fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( "" )
      add_string( Center( Expand( "РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА" ), sh ) )
      add_string( "" )
      add_string( " == ПАРАМЕТРЫ ПОИСКА ==" )
      If mn->nar_z > 0
        If mn->nar_z2 > mn->nar_z
          add_string( "Наряды-заказы с " + lstr( mn->nar_z ) + " по " + lstr( mn->nar_z2 ) )
        Else
          add_string( "Наряд-заказ номер: " + lstr( mn->nar_z ) )
        Endif
      Endif
      If pdata != NIL
        add_string( "Дата открытия наряда-заказа: " + pdata[ 4 ] )
      Elseif pk_data != NIL
        add_string( "Дата окончания лечения: " + pk_data[ 4 ] )
      Endif
      If mn->tip_nar >= 0
        add_string( "Категория больного: " + ;
          inieditspr( A__MENUVERT, menu_kb, mn->tip_nar ) )
      Endif
      If !Empty( much_doc )
        add_string( "Вид и номер учетного документа: " + much_doc )
      Endif
      If !Empty( mfio )
        add_string( "ФИО: " + mfio )
      Endif
      If mn->inostran > 0
        add_string( "Документы иностранных граждан: " + ;
          inieditspr( A__MENUVERT, mm_da_net, mn->inostran ) )
      Endif
      If !Empty( madres )
        add_string( "Адрес: " + madres )
      Endif
      If !Empty( mmr_dol )
        add_string( "Место работы: " + mmr_dol )
      Endif
      If is_talon .and. mn->kategor > 0
        add_string( "Код категории льготы: " + ;
          inieditspr( A__MENUVERT, stm_kategor, mn->kategor ) )
      Endif
      If is_uchastok > 0
        If !Empty( mn->bukva )
          add_string( "Буква: " + mn->bukva )
        Endif
        If !Empty( mn->uchast )
          add_string( "Участок: " + init_uchast( arr_uchast ) )
        Endif
      Endif
      If !Empty( mn->pol )
        add_string( "Пол: " + mn->pol )
      Endif
      If mn->vzros_reb >= 0
        add_string( "Возрастная принадлежность: " + ;
          inieditspr( A__MENUVERT, menu_vzros, mn->vzros_reb ) )
      Endif
      If !Empty( mn->god_r_min ) .or. !Empty( mn->god_r_max )
        If Empty( mn->god_r_min )
          add_string( "Лица, родившиеся до " + full_date( mn->god_r_max ) )
        Elseif Empty( mn->god_r_max )
          add_string( "Лица, родившиеся после " + full_date( mn->god_r_min ) )
        Else
          add_string( "Лица, родившиеся с " + ;
            full_date( mn->god_r_min ) + " по " + full_date( mn->god_r_max ) )
        Endif
      Endif
      If mn->rab_nerab >= 0
        add_string( Upper( inieditspr( A__MENUVERT, menu_rab, mn->rab_nerab ) ) )
      Endif
/*    if mn->mi_git >= 0
      add_string("Место жительства: "+;
                 inieditspr(A__MENUVERT, menu_mest, mn->mi_git))
    endif
    if mn->rajon_git > 0
      add_string("  Район: "+inieditspr(A__POPUPMENU, dir_server()+"rajon", mn->rajon_git))
    endif
    if mn->mest_inog >= 0
      add_string("Финансирование: "+;
                 inieditspr(A__MENUVERT, menu_mest, mn->mest_inog))
    endif
    if mn->rajon > 0
      add_string("  Район: "+inieditspr(A__POPUPMENU, dir_server()+"rajon", mn->rajon))
    endif   */
      If mn->kod_vr1 > 0
        add_string( "Лечащий врач: " + mn->kod_vr )
      Endif
      If mn->kod_as1 > 0
        add_string( "Зубной техник: " + mn->kod_as )
      Endif
      If !Empty( mvkl_diag )
        add_string( "Шифры включаемых заболеваний: " + mvkl_diag )
      Endif
      If !Empty( misk_diag )
        add_string( "Шифры исключаемых заболеваний: " + misk_diag )
      Endif
      If yes_h_otd == 1 .and. mn->otd > 0
        add_string( "Отделение: " + ;
          inieditspr( A__POPUPMENU, dir_server() + "mo_otd", mn->otd ) )
      Endif
      If mn->PRICH_POL > 0
        add_string( "Причина поломки протеза: " + ;
          inieditspr( A__POPUPMENU, dir_server() + "ort_brk", mn->PRICH_POL ) )
      Endif
      If mn->summa_min > 0 .or. mn->summa_max > 0
        If Empty( mn->summa_min )
          add_string( "Стоимость лечения менее " + lstr( mn->summa_max, 10, 2 ) )
        Elseif Empty( mn->summa_max )
          add_string( "Стоимость лечения более " + lstr( mn->summa_min, 10, 2 ) )
        Else
          add_string( "Стоимость лечения в диапазоне от " + ;
            lstr( mn->summa_min, 10, 2 ) + " до " + lstr( mn->summa_max, 10, 2 ) )
        Endif
      Endif
      If mn->otd_usl > 0
        add_string( "Отделение, в котором оказана услуга: " + ;
          inieditspr( A__POPUPMENU, dir_server() + "mo_otd", mn->otd_usl ) )
      Endif
      If mn->ukod_vr1 > 0
        add_string( "Врач, оказавший услугу(и): " + AllTrim( mn->ukod_vr ) )
      Endif
      If mn->isvr > 0
        add_string( "Код врача, оказавшего услугу, " + if( mn->isvr == 1, "не ", "" ) + "проставлен" )
      Endif
      If mn->ukod_as1 > 0
        add_string( "Ассистент, оказавший услугу(и): " + AllTrim( mn->ukod_as ) )
      Endif
      If mn->ukod_ms1 > 0
        add_string( "Медсестра, оказавшая услугу(и): " + AllTrim( mn->ukod_ms ) )
      Endif
      If mn->tip_usl >= 0
        add_string( "Тип услуг: " + ;
          inieditspr( A__MENUVERT, menu_plat, mn->tip_usl ) )
      Endif
      If mn->uslugi > 0
        l := 0
        AEval( arr_usl, {| x| l := Max( l, Len( RTrim( x[ 3 ] ) ) ) } )
        add_string( PadR( "Оказанные услуги:", l + 16 ) + "|Кол-во| Ст-ть" )
        AEval( arr_usl, {| x| add_string( Space( 5 ) + x[ 2 ] + " " + ;
          PadR( x[ 3 ], l ) + "|" + umest_val( x[ 4 ], 5, 3 ) + " |" + put_kop( x[ 5 ], 8 ) ) } )
      Endif
      add_string( "" )
      AEval( arr_title, {| x| add_string( x ) } )
      ss := 0
      Go Top
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        s1 := Left( kart->fio, 40 )
        s3 := ""
        //
        s1 += put_kope( tmp->stoim, 10 )
        ss += tmp->stoim
        If mem_kodkrt == 2 .or. is_uchastok > 0
          s2 := " ["
          If is_uchastok > 0
            s2 += AllTrim( kart->bukva )
            s2 += lstr( kart->uchast, 2 ) + "/"
          Endif
          If is_uchastok == 1
            s2 += lstr( kart->kod_vu )
          Else
            s2 += lstr( kart->kod )
          Endif
          s2 += "] "
        Else
          s2 := " "
        Endif
        If !Empty( mmr_dol )
          s2 += LTrim( kart->mr_dol )
        Endif
        s2 := PadR( s2, 50 )
        s3 := PadR( s3, 50 )
        //
        If IsBit( mn->vid_doc, 1 )
          s1 += " " + date_8( kart->date_r )
          s2 += Space( 9 )
          s3 += Space( 9 )
        Endif
        //
        If IsBit( mn->vid_doc, 2 )
          perenos( a_diagnoz, kart->adres, 24 )
          s1 += " " + PadR( AllTrim( a_diagnoz[ 1 ] ), 24 )
          s2 += " " + PadR( AllTrim( a_diagnoz[ 2 ] ), 24 )
          s3 += " " + PadR( AllTrim( a_diagnoz[ 3 ] ), 24 )
        Endif
        //
        If IsBit( mn->vid_doc, 3 )
          s1 += " " + PadC( AllTrim( human->uch_doc ), 10 )
          s2 += Space( 11 )
          s3 += Space( 11 )
        Endif
        //
        If IsBit( mn->vid_doc, 4 )
          s1 += " " + PadC( lstr( human->nar_z ), 8 )
          s2 += " " + date_8( human->k_data )
          If Empty( human->k_data )
            s3 += " " + date_8( human->data )
          Else
            s3 += Space( 9 )
          Endif
        Endif
        //
        If IsBit( mn->vid_doc, 5 )
          tmp1 := "" ; arr_d := {}
          For i := 1 To 3
            Do Case
            Case i == 1
              pole := "human->kod_diag"
            Case i == 2
              pole := "human->kod_diag2"
            Case i == 3
              pole := "human->kod_diag3"
            Endcase
            If !Empty( &pole )
              If AScan( arr_d, &pole ) == 0
                AAdd( arr_d, &pole )
                tmp1 += " " + AllTrim( &pole )
              Endif
            Endif
          Next
          perenos( a_diagnoz, tmp1, 13 )
          s1 += " " + PadC( AllTrim( a_diagnoz[ 1 ] ), 13 )
          s2 += " " + PadC( AllTrim( a_diagnoz[ 2 ] ), 13 )
          s3 += " " + PadC( AllTrim( a_diagnoz[ 3 ] ), 13 )
        Endif
        //
        If IsBit( mn->vid_doc, 6 )
          s1 += put_val( ret_tabn( human->kod_vr ), 6 )
          s2 += put_val( ret_tabn( human->kod_as ), 6 )
          s3 += Space( 6 )
        Endif
        //
        If IsBit( mn->vid_doc, 7 )
          tmp1 := ""
          Select TMP1
          find ( Str( human->( RecNo() ), 7 ) )
          Do While tmp1->kod == human->( RecNo() ) .and. !Eof()
            tmp1 += AllTrim( tmp1->shifr ) + ","
            Skip
          Enddo
          tmp1 := Left( tmp1, Len( tmp1 ) -1 )
          perenos( a_diagnoz, tmp1, 23, "," )
          s1 += " " + PadC( AllTrim( a_diagnoz[ 1 ] ), 23 )
          s2 += " " + PadC( AllTrim( a_diagnoz[ 2 ] ), 23 )
          s3 += " " + PadC( AllTrim( a_diagnoz[ 3 ] ), 23 )
        Endif
        //
        If IsBit( mn->vid_doc, 8 )
          s1 += " " + PadC( AllTrim( human->n_och ), 10 )
          s2 += Space( 11 )
          s3 += Space( 11 )
        Endif
        //
        If IsBit( mn->vid_doc, 9 )
          s1 += " " + PadC( AllTrim( human->prim ), 15 )
          s2 += Space( 16 )
          s3 += Space( 16 )
        Endif
        //
        add_string( s1 )
        add_string( s2 )
        add_string( s3 )
        Select TMP
        Skip
      Enddo
      add_string( Replicate( "─", sh ) )
      add_string( "  Итого количество больных : " + lstr( tmp->( LastRec() ) ) + ;
        " чел.  на сумму  " + lput_kop( ss, .t. ) + " руб." )
      FClose( fp )
      Close databases
      viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
    Endif
  Endif
  Close databases
  RestScreen( buf ) ; SetColor( tmp_color )

  Return Nil

// 

// 22.03.17
Static Function s1_mnog_poisk( cv, cf )

  Local i, fl := .t., flu := .f., mkol, mstoim := 0, luch_doc := "", arr, lshifr1

  ++cv
  If fl
    If pdata != NIL
      fl := Between( human->data, pdata[ 5 ], pdata[ 6 ] )
    Elseif pk_data != NIL
      fl := Between( human->k_data, pk_data[ 5 ], pk_data[ 6 ] )
    Endif
  Endif
  If fl .and. mn->nar_z > 0
    If mn->nar_z2 > mn->nar_z
      fl := Between( human->nar_z, mn->nar_z, mn->nar_z2 )
    Else
      fl := ( human->nar_z == mn->nar_z )
    Endif
  Endif
  If fl .and. mn->tip_nar >= 0
    fl := ( human->tip_usl == mn->tip_nar )
  Endif
  If fl .and. !Empty( much_doc )
    fl := Like( much_doc, human->uch_doc )
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->bukva )
    kart->( dbGoto( human->kod_k ) )
    fl := ( mn->bukva == kart->bukva )
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->uchast )
    kart->( dbGoto( human->kod_k ) )
    fl := f_is_uchast( arr_uchast, kart->uchast )
  Endif
  If fl .and. !Empty( mfio )
    fl := Like( mfio, Upper( kart->fio ) )
  Endif
  If fl .and. mn->inostran > 0
    If mn->inostran == 1 // нет
      // 9,21,22,23,24
      fl := !equalany( kart_->vid_ud, 9, 21, 22, 23, 24 )
    Else
      fl := equalany( kart_->vid_ud, 9, 21, 22, 23, 24 )
    Endif
  Endif
  If fl .and. !Empty( madres )
    fl := Like( madres, Upper( kart->adres ) )
  Endif
  If fl .and. !Empty( mmr_dol )
    fl := Like( mmr_dol, Upper( kart->mr_dol ) )
  Endif
  If fl .and. is_talon .and. mn->kategor > 0
    fl := ( mn->kategor == kart_->kategor )
  Endif
  If fl .and. !Empty( mn->pol )
    fl := ( kart->pol == mn->pol )
  Endif
  If fl .and. mn->vzros_reb >= 0
    fl := ( kart->vzros_reb == mn->vzros_reb )
  Endif
  If fl .and. !Empty( mn->god_r_min )
    fl := ( mn->god_r_min <= kart->date_r )
  Endif
  If fl .and. !Empty( mn->god_r_max )
    fl := ( kart->date_r <= mn->god_r_max )
  Endif
  If fl .and. mn->rab_nerab >= 0
    fl := ( kart->rab_nerab == mn->rab_nerab )
  Endif
/*if fl .and. mn->mi_git >= 0
  fl := (kart->mi_git == mn->mi_git)
endif
if fl .and. mn->rajon_git > 0
  fl := (kart->rajon_git == mn->rajon_git)
endif
if fl .and. mn->mest_inog >= 0
  fl := (kart->mest_inog == mn->mest_inog)
endif
if fl .and. mn->rajon > 0
  fl := (kart->rajon == mn->rajon)
endif*/
  If fl .and. !Empty( mvkl_diag )
    fl := ( human->KOD_DIAG $ mvkl_diag .or. ;
      human->KOD_DIAG2 $ mvkl_diag .or. ;
      human->KOD_DIAG3 $ mvkl_diag )
  Endif
  If fl .and. !Empty( misk_diag )
    fl := !( human->KOD_DIAG $ misk_diag .or. ;
      human->KOD_DIAG2 $ misk_diag .or. ;
      human->KOD_DIAG3 $ misk_diag )
  Endif
  If fl .and. yes_h_otd == 1 .and. mn->otd > 0
    fl := ( human->otd == mn->otd )
  Endif
  If fl .and. mn->kod_vr1 > 0
    fl := ( human->kod_vr == mn->kod_vr1 )
  Endif
  If fl .and. mn->kod_as1 > 0
    fl := ( human->kod_as == mn->kod_as1 )
  Endif
  If fl .and. mn->PRICH_POL > 0
    fl := ( mn->PRICH_POL == human->PRICH_POL )
  Endif
  If fl .and. mn->summa_min > 0
    fl := ( mn->summa_min <= human->cena )
  Endif
  If fl .and. mn->summa_max > 0
    fl := ( human->cena <= mn->summa_max )
  Endif
  If fl
    If flag_hu
      mkol := 0
      Select HU
      find ( Str( human->( RecNo() ), 7 ) )
      Do While hu->kod == human->( RecNo() )
        flu := .t.
        If flu .and. mn->otd_usl > 0
          flu := ( hu->otd == mn->otd_usl )
        Endif
        If flu .and. mn->isvr > 0
          If mn->isvr == 1  // нет
            flu := ( hu->kod_vr == 0 )
          Else
            flu := ( hu->kod_vr > 0 )
          Endif
        Endif
        If flu .and. mn->ukod_vr1 > 0
          flu := ( hu->kod_vr == mn->ukod_vr1 )
        Endif
        If flu .and. mn->ukod_as1 > 0
          flu := ( hu->kod_as == mn->ukod_as1 )
        Endif
        If flu .and. mn->ukod_ms1 > 0
          flu := ( hu->kod_ms == mn->ukod_ms1 )
        Endif
        If flu .and. mn->uslugi > 0
          i := AScan( arr_usl, {| x| x[ 1 ] == hu->u_kod } )
          If ( flu := ( i > 0 ) )
            arr_usl[ i, 4 ] += hu->kol
            arr_usl[ i, 5 ] += hu->stoim
          Endif
        Endif
        If flu .and. mn->tip_usl >= 0
          flu := ( hu->tip_usl == mn->tip_usl )
        Endif
        If flu
          mkol += hu->kol
          mstoim += hu->stoim
          If IsBit( mn->vid_doc, 7 )
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            Select TMP1
            Append Blank
            tmp1->kod := human->( RecNo() )
            tmp1->shifr := AllTrim( if( Empty( lshifr1 ), usl->shifr, lshifr1 ) ) + ;
              "(" + AllTrim( str_0( hu->kol, 7, 3 ) ) + ")"
          Endif
        Endif
        Select HU
        Skip
      Enddo
      If emptyall( mkol, mstoim )
        fl := .f.
      Endif
    Else
      mstoim := human->cena
    Endif
  Endif
  If fl
    Select TMP
    Append Blank
    tmp->kod := human->( RecNo() )
    tmp->stoim := mstoim
    If++cf % 2000 == 0
      Commit
    Endif
  Endif
  @ 24, 1 Say lstr( cv ) Color cColorSt2Msg
  @ Row(), Col() Say "/" Color "W/R"
  @ Row(), Col() Say lstr( cf ) Color cColorStMsg

  Return Nil

//
Function writeomn_p( k )

  Local fl := .t.

  If k == 1
    If emptyall( mdata, mk_data )
      fl := func_error( 4, "Обязательно должно быть заполнено хотя бы одно поле даты!" )
    Endif
  Endif

  Return fl

// 

// 28.10.14
Function o_ret_pl_b()

  Static si := 1
  Local mas_pmt := { "~Платные больные", ;
    "~Бесплатные больные", ;
    "~Общие больные" }
  Local mas_msg := { "Статистика для платных больных (все услуги платные)", ;
    "Статистика для бесплатных больных (хотя бы одна услуга бесплатная)", ;
    "Статистика для всех больных" }
  Local i := Len( mas_pmt ), k := T_ROW

  If k + i + 2 > MaxRow() -1
    k := T_ROW - i -3
  Endif
  If ( i := popup_prompt( k, T_COL - 5, si, mas_pmt, mas_msg ) ) > 0
    si := i ; pr_titul := "-= " + CharRem( "~", mas_pmt[ i ] ) + " =-"
  Endif

  Return i

// 

//  13.11.18
Function o_ved_narabot()

  Static sname1 := "", s1d1, s1d2, ;
    sname2 := "", s2d1, s2d2, ;
    sname3 := "", s3d1, s3d2
  Local arr, arr_title, reg_print := 6, sh, HH := 80, s, s1, s2, fl, ;
    begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "orto_ved.txt", ;
    tip_tit, i, sitogo
  Local par, mperso, mkod, buf := save_row( MaxRow() ), ;
    arr_diag := {}, a_diag, all_diag := .f.

  Default s1d1 To CToD( "" ), s1d2 To CToD( "" ), ;
    s2d1 To CToD( "" ), s2d2 To CToD( "" ), ;
    s3d1 To CToD( "" ), s3d2 To CToD( "" )
  r_use( dir_server() + "diag_ort", dir_server() + "diag_ort" )
  dbEval( {|| AAdd( arr_diag, { shifr + " " + name, shifr } ) } )
  diag_ort->( dbCloseArea() )
  If ( a_diag := bit_popup( T_ROW, T_COL - 5, arr_diag ) ) == NIL
    Return Nil
  Endif
  If Len( a_diag ) == Len( arr_diag )
    all_diag := .t.
  Endif
  Private ym_kol_mes := 0
  Private mname1 := PadR( sname1, 15 ), m1d1 := s1d1, m1d2 := s1d2, ;
    mname2 := PadR( sname2, 15 ), m2d1 := s2d1, m2d2 := s2d2, ;
    mname3 := PadR( sname3, 15 ), m3d1 := s3d1, m3d2 := s3d2
  displbox( ;
    " \" + ;
    " Введите наименования и диапазоны времени для отображения периодов\" + ;
    "       1-ый период @              , с @          по @           \" + ;
    "       2-ой период @              , с @          по @           \" + ;
    "       3-ий период @              , с @          по @           \" + ;
    " \", ;               // текст в окне, ( \ - перевод строки, @ - Get'ы )
    , ;                   // цвет окна (умолч. - cDataCGet)
    { "mname1", "m1d1", "m1d2", "mname2", "m2d1", "m2d2", "mname3", "m3d1", "m3d2" }, ; // массив Private-переменных для редактирования
  {,,,,,,,, }, ; // массив Picture для редактирования
  16, ;                 // row - левый верхний угол окна (по умолч. - центрирование)
    , ;                   // col - левый верхний угол окна (по умолч. - центрирование)
    , ;                   // массив влоков кода условий WHEN
    )           // массив блоков кода условий VALID
  arr := { { AllTrim( mname1 ), m1d1, m1d2, 1 }, ;
    { AllTrim( mname2 ), m2d1, m2d2, 2 }, ;
    { AllTrim( mname3 ), m3d1, m3d2, 3 } }
  Do While .t.
    k := Len( arr ) ; fl := .f.
    For i := 1 To k
      If emptyany( arr[ i, 2 ], arr[ i, 3 ] )
        ADel( arr, i )
        ASize( arr, k - 1 )
        fl := .t.
        Exit
      Endif
    Next
    If !fl ; exit ; Endif
  Enddo
  If ( ym_kol_mes := Len( arr ) ) == 0
    Return Nil
  Elseif ym_kol_mes == 1
    reg_print := 5
  Endif
  sitogo := Array( ym_kol_mes, 9 )
  afillall( sitogo, 0 )
  //
  sname1 := mname1 ; s1d1 := m1d1 ; s1d2 := m1d2
  sname2 := mname2 ; s2d1 := m2d1 ; s2d2 := m2d2
  sname3 := mname3 ; s3d1 := m3d1 ; s3d2 := m3d2
  ASort( arr,,, {| x, y| x[ 2 ] < y[ 2 ] } )
  AEval( arr, {| x, i| arr[ i, 4 ] := i } )
  begin_date := arr[ 1, 2 ]
  end_date := arr[ ym_kol_mes, 3 ]
  //
  par := if( ptip_pers == "vr", 1, 2 )
  If ( mperso := input_kperso() ) == Nil  // ==> весь персонал
    mywait()
    mperso := {}
    r_use( dir_server() + "mo_pers",, "PERSO" )
    Go Top
    Do While !Eof()
      If perso->kod > 0
        AAdd( mperso, { perso->kod, perso->fio } )
      Endif
      Skip
    Enddo
    perso->( dbCloseArea() )
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  adbf := { { "KOD", "N", 4, 0 }, ;  // код персонала
  { "MES", "N", 2, 0 }, ;  // номер месяца
  { "KOL_P", "N", 4, 0 }, ;  // количество платных нарядов по врачу
  { "KOL_PS", "N", 4, 0 }, ;  // количество посещений в платных нарядах
  { "STOIM_P", "N", 12, 2 }, ;  // платная стоимость лечения
  { "KOL_B", "N", 4, 0 }, ;  // количество бесплатных нарядов по врачу
  { "KOL_BS", "N", 4, 0 }, ;  // количество посещений в бесплатных нарядах
  { "STOIM_B", "N", 12, 2 }, ;  // бесплатная стоимость лечения
  { "STOIM_BP", "N", 12, 2 } }   // платные услуги (для бесплатных больных)
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod, 4 ) + Str( mes, 2 ) to ( cur_dir() + "tmp" )
  musluga := AllTrim( mem_ort_na )
  If Empty( musluga ) .or. musluga == "*"
    musluga := "9999999999"
  Endif
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
  Set Relation To u_kod into USL
  r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
  dbSeek( DToS( begin_date ), .t. )
  Do While human->k_data <= end_date .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    fl := .f.
    If all_diag
      fl := .t.
    Else
      fl := ( AScan( a_diag, {| x| x[ 2 ] == human->kod_diag } ) > 0 )
    Endif
    If fl .and. ( lmes := AScan( arr, {| x| Between( human->k_data, x[ 2 ], x[ 3 ] ) } ) ) > 0
      a_p := {}
      Select HU
      find ( Str( human->( RecNo() ), 7 ) )
      Do While hu->kod == human->( RecNo() ) .and. !Eof()
        Do Case
        Case par == 1
          mkod := hu->kod_vr
        Case par == 2
          mkod := hu->kod_as
        Endcase
        If ( fl := ( mkod > 0 .and. AScan( mperso, {| x| x[ 1 ] == mkod } ) > 0 ) )
          fl_boln := .t.
          If AScan( a_p, mkod ) == 0
            AAdd( a_p, mkod )
          Else
            fl_boln := .f.
          Endif
          s1 := s2 := 0
          If hu->tip_usl != OU_B_PLAT  // платные
            s2 += hu->stoim
          Else
            s1 += hu->stoim
          Endif
          If Like( musluga, usl->shifr )
            sitogo[ lmes, 4 ] += hu->stoim  // напыление
          Endif
          Select TMP
          find ( Str( mkod, 4 ) + Str( lmes, 2 ) )
          If !Found()
            Append Blank
            tmp->kod := mkod
            tmp->mes := lmes
          Endif
          If human->tip_usl != OU_B_PLAT  // платный больной
            If fl_boln
              tmp->KOL_P++
              tmp->KOL_PS += human->kol_pos
            Endif
            tmp->STOIM_P += s2
          Else
            If fl_boln
              tmp->KOL_B++
              tmp->KOL_BS += human->kol_pos
            Endif
            tmp->STOIM_B += s1
            tmp->STOIM_BP += s2
          Endif
        Endif
        Select HU
        Skip
      Enddo
      If Len( a_p ) > 0
        sitogo[ lmes, 1 ] ++
        sitogo[ lmes, 7 ] += human->kol_pos
        If human->tip_usl != OU_B_PLAT
          sitogo[ lmes, 5 ] ++
          sitogo[ lmes, 8 ] += human->kol_pos
        Else
          sitogo[ lmes, 6 ] ++
          sitogo[ lmes, 9 ] += human->kol_pos
        Endif
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    Return Nil
  Endif
  If j == 0
    Return func_error( 4, "Нет сведений!" )
  Endif
  mywait()
  //
  arr_title := Array( 8 )
  nf := 16
  arr_title[ 1 ] := Replicate( "─", nf )
  arr_title[ 2 ] := Space( nf )
  arr_title[ 3 ] := Space( nf )
  arr_title[ 4 ] := PadC( "Ф.И.О.", nf )
  arr_title[ 5 ] := Space( nf )
  arr_title[ 6 ] := Space( nf )
  arr_title[ 7 ] := Space( nf )
  arr_title[ 8 ] := Replicate( "─", nf )
  //
  kb := ym_kol_mes
  ar := Array( kb )
  For i := 1 To ym_kol_mes
    ar[ i ] := LTrim( arr[ i, 1 ] + " [ с " + full_date( arr[ i, 2 ] ) + "г. по " + ;
      full_date( arr[ i, 3 ] ) + "г.]" )
  Next
  If ym_kol_mes > 1
    ++kb
    AAdd( ar, "И_Т_О_Г_О" )
  Endif
  nk := 68
  For i := 1 To kb
    arr_title[ 1 ] += "┬────────────────────────────────────────────────────────────────────"
    arr_title[ 2 ] += "│" + PadC( ar[ i ], nk )
    arr_title[ 3 ] += "├───────────────────┬────────────────────────────┬───────────────────"
    arr_title[ 4 ] += "│  платные больные  │     бесплатные больные     │   общие больные   "
    arr_title[ 5 ] += "├─────────┬────┬────┼─────────┬────────┬────┬────┼─────────┬────┬────"
    arr_title[ 6 ] += "│платные  │кол.│кол.│бесплатн.│платные │кол.│кол.│стоимость│кол.│кол."
    arr_title[ 7 ] += "│услуги   │нар.│пос.│услуги   │услуги  │нар.│пос.│услуг    │нар.│пос."
    arr_title[ 8 ] += "┴─────────┴────┴────┴─────────┴────────┴────┴────┴─────────┴────┴────"
  Next
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( Center( "Ведомость наработки " + { "врачей", "зубных техников" }[ par ], sh ) )
  If all_diag
    add_string( Center( "[ по всем нозологиям ]", sh ) )
  Else
    s := "[ "
    AEval( a_diag, {| x| s += AllTrim( x[ 2 ] ) + "," } )
    s := SubStr( s, 1, Len( s ) -1 ) + " ]"
    add_string( Center( s, sh ) )
  Endif
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  //
  r_use( dir_server() + "mo_pers",, "PERSO" )
  Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
  ASort( mperso,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
  For p := 1 To Len( mperso )
    find ( Str( mperso[ p, 1 ], 4 ) )
    If Found()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      perso->( dbGoto( tmp->kod ) )
      s := PadR( lstr( perso->tab_nom ) + "/" + fam_i_o( mperso[ p, 2 ] ), nf )
      msp := mkp := mkps := msb := msbp := mkb := mkbs := 0
      For i := 1 To ym_kol_mes
        find ( Str( mperso[ p, 1 ], 4 ) + Str( arr[ i, 4 ], 2 ) )
        s += put_kope( tmp->stoim_p, 10 ) + ;
          put_val( tmp->kol_p, 5 ) + ;
          put_val( tmp->kol_ps, 5 ) + ;
          put_kope( tmp->stoim_b, 10 ) + ;
          put_kope( tmp->stoim_bp, 9 ) + ;
          put_val( tmp->kol_b, 5 ) + ;
          put_val( tmp->kol_bs, 5 ) + ;
          put_kope( tmp->stoim_p + tmp->stoim_b + tmp->stoim_bp, 10 ) + ;
          put_val( tmp->kol_p + tmp->kol_b, 5 ) + ;
          put_val( tmp->kol_ps + tmp->kol_bs, 5 )
        msp += tmp->stoim_p
        mkp += tmp->kol_p
        mkps += tmp->kol_ps
        msb += tmp->stoim_b
        msbp += tmp->stoim_bp
        mkb += tmp->kol_b
        mkbs += tmp->kol_bs
        //
        sitogo[ i, 2 ] += ( tmp->stoim_p + tmp->stoim_bp )
        sitogo[ i, 3 ] += ( tmp->stoim_b )
      Next
      If ym_kol_mes > 1
        s += put_kope( msp,10 ) + ;
          put_val( mkp,5 ) + ;
          put_val( mkps, 5 ) + ;
          put_kope( msb,10 ) + ;
          put_kope( msbp, 9 ) + ;
          put_val( mkb,5 ) + ;
          put_val( mkbs, 5 ) + ;
          put_kope( msp + msb + msbp, 10 ) + ;
          put_val( mkp + mkb, 5 ) + ;
          put_val( mkps + mkbs, 5 )
      Endif
      add_string( s )
      add_string( Replicate( "-", sh ) )
    Endif
  Next
  Close databases
  If fl_exit
    add_string( Replicate( "*", sh ) )
    add_string( Expand( "ПРОЦЕСС ПРЕРВАН" ) )
  Else
    If verify_ff( HH - 5, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    y := Array( 3 )
    s := Array( 5 )
    AFill( s, Space( nf + 1 ) )
    For i := 1 To ym_kol_mes
      s[ 1 ] += PadR( "Итого: кол.нарядов - " + lstr( sitogo[ i, 1 ] ) + ;
        " [пл.-" + lstr( sitogo[ i, 5 ] ) + ",бес.-" + lstr( sitogo[ i, 6 ] ) + "]", nk + 1 )
      s[ 2 ] += PadR( " кол.посещений - " + lstr( sitogo[ i, 7 ] ) + ;
        " [пл.-" + lstr( sitogo[ i, 8 ] ) + ",бес.-" + lstr( sitogo[ i, 9 ] ) + "]", nk + 1 )
      s[ 3 ] += PadR( " сумма платных услуг (без напыления) - " + lput_kop( sitogo[ i, 2 ] ), nk + 1 )
      s[ 4 ] += PadR( " сумма бесплатных услуг - " + lput_kop( sitogo[ i, 3 ] ), nk + 1 )
      s[ 5 ] += PadR( " сумма напыления - " + lput_kop( sitogo[ i, 4 ] ), nk + 1 )
    Next
    If ym_kol_mes > 1
      AFill( y, 0 ) ; AEval( sitogo, {| x| y[ 1 ] += x[ 1 ], y[ 2 ] += x[ 5 ], y[ 3 ] += x[ 6 ] } )
      s[ 1 ] += PadR( "ИТОГО: кол.нарядов - " + lstr( y[ 1 ] ) + " [пл.-" + lstr( y[ 2 ] ) + ",бес.-" + lstr( y[ 3 ] ) + "]", nk + 1 )
      AFill( y, 0 ) ; AEval( sitogo, {| x| y[ 1 ] += x[ 7 ], y[ 2 ] += x[ 8 ], y[ 3 ] += x[ 9 ] } )
      s[ 2 ] += PadR( " кол.посещений - " + lstr( y[ 1 ] ) + " [пл.-" + lstr( y[ 2 ] ) + ",бес.-" + lstr( y[ 3 ] ) + "]", nk + 1 )
      y := 0 ; AEval( sitogo, {| x| y += x[ 2 ] } )
      s[ 3 ] += PadR( " сумма платных услуг (без напыления) - " + lput_kop( y ), nk + 1 )
      y := 0 ; AEval( sitogo, {| x| y += x[ 3 ] } )
      s[ 4 ] += PadR( " сумма бесплатных услуг - " + lput_kop( y ), nk + 1 )
      y := 0 ; AEval( sitogo, {| x| y += x[ 4 ] } )
      s[ 5 ] += PadR( " сумма напыления - " + lput_kop( y ), nk + 1 )
    Endif
    AEval( s, {| x| add_string( x ) } )
  Endif
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 

// 28.10.14 врачи/техники + количество нарядов
Function o_vr_kol_nar()

  Local buf := save_maxrow(), sh, HH := 51, arr_title, s, reg_print := 5, ;
    j, arr_m, name_file := cur_dir() + "o_kolnar.txt", fl_exit := .f., ;
    arr_sm := { 0, 0, 0, 0, 0, 0, 0, 0 }, pr_pl_bes := 0, fl := .f.

  If ( pr_pl_bes := o_ret_pl_b() ) == 0
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  adbf := { { "KOD",   "N", 4, 0 }, ;  // код персонала
  { "KOL_N1", "N", 4, 0 }, ;  // количество открытых нарядов на начало
  { "KOL_N2", "N", 4, 0 }, ;  // количество закрытых нарядов за период
  { "KOL_N3", "N", 4, 0 }, ;  // количество открытых нарядов на конец
  { "AVANS1", "N", 12, 2 }, ;  //
  { "AVANS3", "N", 12, 2 }, ;  //
  { "STOIM1", "N", 12, 2 }, ;  //
  { "STOIM2", "N", 12, 2 }, ;  //
  { "STOIM3", "N", 12, 2 } }   //
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod, 4 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "hum_oro", dir_server() + "hum_oro", "HO" )
  // наряды, ещё не закрытые на начало (конец) периода
  r_use( dir_server() + "hum_ort", dir_server() + "hum_orto", "HUMAN" )
  Go Top
  Do While !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    Do Case
    Case pr_pl_bes == 1  // платные
      fl := ( human->tip_usl != OU_B_PLAT )
    Case pr_pl_bes == 2  // бесплатные
      fl := ( human->tip_usl == OU_B_PLAT )
    Case pr_pl_bes == 3  // все
      fl := .t.
    Endcase
    If ( Empty( human->k_data ) .and. human->data < arr_m[ 5 ] ) .or. human->k_data >= arr_m[ 5 ]
      If FL
        Select TMP
        If ptip_pers == "vr"
          find ( Str( human->kod_vr, 4 ) )
          If !Found()
            Append Blank
            tmp->kod := human->kod_vr
          Endif
        Else
          find ( Str( human->kod_as, 4 ) )
          If !Found()
            Append Blank
            tmp->kod := human->kod_as
          Endif
        Endif
        tmp->kol_n1++
        tmp->stoim1 += human->cena
        //
        s := 0
        Select HO
        find ( Str( human->( RecNo() ), 7 ) )
        Do While ho->kod == human->( RecNo() ) .and. !Eof()
          If ho->pdate < arr_m[ 7 ]
            s += ho->cena_opl
          Endif
          If ho->sum_voz > 0 .and. ho->date_voz < arr_m[ 7 ]
            s -= ho->sum_voz
          Endif
          Skip
        Enddo
        If !Empty( Round( s, 2 ) )
          tmp->avans1 += s
        Endif
      Endif
    Endif
    If ( Empty( human->k_data ) .and. human->data <= arr_m[ 6 ] ) .or. human->k_data > arr_m[ 6 ]
      If FL
        Select TMP
        If ptip_pers == "vr"
          find ( Str( human->kod_vr, 4 ) )
          If !Found()
            Append Blank
            tmp->kod := human->kod_vr
          Endif
        Else
          find ( Str( human->kod_as, 4 ) )
          If !Found()
            Append Blank
            tmp->kod := human->kod_as
          Endif
        Endif
        tmp->kol_n3++
        tmp->stoim3 += human->cena
        //
        s := 0
        Select HO
        find ( Str( human->( RecNo() ), 7 ) )
        Do While ho->kod == human->( RecNo() ) .and. !Eof()
          If ho->pdate <= arr_m[ 8 ]
            s += ho->cena_opl
          Endif
          If ho->sum_voz > 0 .and. ho->date_voz <= arr_m[ 8 ]
            s -= ho->sum_voz
          Endif
          Skip
        Enddo
        If !Empty( Round( s, 2 ) )
          tmp->avans3 += s
        Endif
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  If !fl_exit // наряды, закрытые за период
    Select HUMAN
    Set Index to ( dir_server() + "hum_ortd" )
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      Do Case
      Case pr_pl_bes == 1  // платные
        fl := ( human->tip_usl != OU_B_PLAT )
      Case pr_pl_bes == 2  // бесплатные
        fl := ( human->tip_usl == OU_B_PLAT )
      Case pr_pl_bes == 3  // все
        fl := .t.
      Endcase
      If FL
        Select TMP
        If ptip_pers == "vr"
          find ( Str( human->kod_vr, 4 ) )
          If !Found()
            Append Blank
            tmp->kod := human->kod_vr
          Endif
        Else
          find ( Str( human->kod_as, 4 ) )
          If !Found()
            Append Blank
            tmp->kod := human->kod_as
          Endif
        Endif
        tmp->kol_n2++
        tmp->stoim2 += human->cena
      Endif
      Select HUMAN
      Skip
    Enddo
  Endif
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    Return Nil
  Endif
  If j == 0
    Return func_error( 4, "Нет сведений!" )
  Endif
  mywait()
  s1 := date_8( arr_m[ 5 ] )
  s2 := date_8( arr_m[ 6 ] )
  If ptip_pers == "vr"
    s3 := "врача  "
  Else
    s3 := "техника"
  Endif
  arr_title := { ;
    "─────────────────────────────────────────┬──────────────────────┬────────────────┬──────────────────────", ;
    "                                         │ наряды, ещё открытые │наряды, закрытые│ наряды, ещё открытые ", ;
    "                                         │ на утро " + s1 + "     │   за период    │ на вечер " + s2, ;
    "                                         ├────┬───────┬─────────┼────┬───────────┼────┬───────┬─────────", ;
    "            Ф.И.О. " + s3 + "               │кол.│ аванс │к доплате│кол.│   сумма   │кол.│ аванс │к доплате", ;
    "─────────────────────────────────────────┴────┴───────┴─────────┴────┴───────────┴────┴───────┴─────────" }
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + "organiz",, "ORG" )
  r_use( dir_server() + "mo_pers",, "PERSO" )
  add_string( org->name )
  add_string( "" )
  add_string( Center( "Количество нарядов-заказов", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  Use ( cur_dir() + "TMP" ) new
  Set Relation To kod into PERSO
  Index On Upper( perso->fio ) to ( cur_dir() + "tmp" )
  Go Top
  Do While !Eof()
    s := PadR( "[" + lstr( perso->tab_nom ) + "] " + perso->fio, 41 ) + ;
      put_val( tmp->KOL_N1, 5 ) + " " + umest_val( tmp->AVANS1, 7, 1 ) + " " + umest_val( tmp->STOIM1 - tmp->AVANS1, 9, 2 ) + ;
      put_val( tmp->KOL_N2, 5 ) + " " + umest_val( tmp->STOIM2, 11, 2 ) + ;
      put_val( tmp->KOL_N3, 5 ) + " " + umest_val( tmp->AVANS3, 7, 2 ) + " " + umest_val( tmp->STOIM3 - tmp->AVANS3, 9, 2 )
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( s )
    arr_sm[ 1 ] += tmp->KOL_N1
    arr_sm[ 2 ] += tmp->AVANS1
    arr_sm[ 3 ] += ( tmp->STOIM1 - tmp->AVANS1 )
    arr_sm[ 4 ] += tmp->KOL_N2
    arr_sm[ 5 ] += tmp->STOIM2
    arr_sm[ 6 ] += tmp->KOL_N3
    arr_sm[ 7 ] += tmp->AVANS3
    arr_sm[ 8 ] += ( tmp->STOIM3 - tmp->AVANS3 )
    Skip
  Enddo
  add_string( Replicate( "─", sh ) )
  s := PadR( "  ИТОГО: ", 41 ) + ;
    put_val( arr_sm[ 1 ], 5 ) + " " + umest_val( arr_sm[ 2 ], 7, 1 ) + " " + umest_val( arr_sm[ 3 ], 9, 2 ) + ;
    put_val( arr_sm[ 4 ], 5 ) + " " + umest_val( arr_sm[ 5 ], 11, 2 ) + ;
    put_val( arr_sm[ 6 ], 5 ) + " " + umest_val( arr_sm[ 7 ], 7, 2 ) + " " + umest_val( arr_sm[ 8 ], 9, 2 )
  add_string( s )
  FClose( fp )
  Close databases
  rest_box( buf )
  Private yes_albom := .t.
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 

//
Function inputnorpozic( r, c, fl_max )

  Static st_pozic := {}
  Local r1, r2, i, k, t_mas, ;
    buf := SaveScreen(), l_a_pozic
  Local mas_s := { "Номер карты", ;
    "Номер чека", ;
    "Дата оплаты мед.услуги", ;
    "Дата оказания мед.услуги", ;
    "Шифр мед.услуги", ;
    "Наименование мед.услуги", ;
    "Код Врача", ;
    "Код Техника", ;
    "ФИО врача+техника", ;
    "Цена услуги", ;
    "Количество услуг" }

  Local mas := { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 }

  Default fl_max To .f.
  r2 := r - 2
  r1 := r2 - Len( mas_s ) -1
  If r1 < 0
    r1 := r
    If ( r2 := r1 + Len( mas_s ) + 1 ) > MaxRow() -2
      r2 := MaxRow() -2
    Endif
  Endif
  If c + 35 > 77
    c := 77 -35
  Endif
  t_mas := AClone( mas_s )
  If fl_max  // принудительное полное заполнение
    AEval( mas, {| x| AAdd( st_pozic, x ) } )
  Endif
  AEval( t_mas, {| x, i| ;
    t_mas[ i ] := if( AScan( st_pozic, mas[ i ] ) > 0, " * ", "   " ) + t_mas[ i ] } )
  status_key( "^<Esc>^ - отказ ^<Enter>^ - подтверждение ^<Ins>^ - смена признака выбора" )
  Do While .t.
    l_a_pozic := NIL
    If Popup( r1, c, r2, c + 35, t_mas, i, color0, .t., "fmenu_reader",, "Колонки информации", "B/BG" ) > 0
      l_a_pozic := {} ; st_pozic := {}
      For i := 1 To 11
        If "*" == SubStr( t_mas[ i ], 2, 1 )
          AAdd( l_a_pozic, { ( i - 1 ), AllTrim( mas_s[ i ] ), } )
          AAdd( st_pozic, mas[ i ] )
        Endif
      Next
      If Empty( l_a_pozic )
        // func_error(4,"Необходимо отметить хотя бы один источник финансирования!")
        // loop
        Exit
      Else
        Exit
      Endif
    Else
      Exit
    Endif
  Enddo
  RestScreen( buf )

  Return l_a_pozic

// 

//*
// Function f_is_pozic(arr_s,pozic)
// Local fl := .t.
// fl := ( ascan(arr_s,{|x| pozic==x[1] }) > 0 )
// return fl

// 

// 02.12.12
Function pl_ordogovor()

  Local buf := save_maxrow(), sh, HH := 51, arr_title, s, i, j, k, sk, ss, ;
    arr2title, reg_print := 6, afio[ 10 ], lfio := 19, kfio, lsk, lss, adbf, ;
    aadres[ 2 ], kadres, apolis[ 10 ], kpolis, name_file := cur_dir() + "jurnal.txt"

  arr_title := { ;
    "─────────────────────────────┬───────┬─────────────────────────────────────────────────────────────────┬───────┬────┬──────────┬───────────────┬──────────┬──────────", ;
    "        Ф.И.О., адрес        │ НОМЕР │                   Вид медицинской услуги                        │ Стоим-│Кол.│ Сумма за │Ф.И.О специали-│   Дата   │   Срок   ", ;
    "        застрахованного      │медицин│                                                                 │  сть  │оказ│все кол-во│ ста оказавшего│  приема  │ оказания ", ;
    "                             │ карты │                                                                 │ услуги│ус- │оказ.услуг│  мед. услугу  │          │   мед.   ", ;
    "                             │       │                                                                 │ (руб.)│луг │  (руб.)  │               │          │  услуги  ", ;
    "─────────────────────────────┴───────┴─────────────────────────────────────────────────────────────────┴───────┴────┴──────────┴───────────────┴──────────┴──────────" }
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  mywait()
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + "mo_pers",, "perso" )
  r_use( dir_server() + "organiz",, "ORG" )
  add_string( Center( "Ж У Р Н А Л", sh ) )
  add_string( Center( "учета заказов граждан на предоставление им платных медицинских услуг(помощи)", sh ) )
  add_string( Center( "по " + iif( is_open, "открытым ", "закрытым " ) + "нарядам-заказам", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HPU" )
  r_use( dir_server() + "hum_ort",, "HU" )
  AEval( arr_title, {| x| add_string( x ) } )
  j := sk := ss := 0
  Select HU
  Go Top
  Do While !Eof()
    If arr_m[ 5 ] <= hu->Data .and. hu->data <= arr_m[ 6 ] .and. ;
        if( is_open, .t., !Empty( hu->k_data ) )
      // if(is_open,empty(hu->k_data),!empty(hu->k_data))
      ss += hu->cena
      Select KART
      Goto hu->kod_k
      kfio := perenos( afio, AllTrim( kart->fio ) + " " + AllTrim( kart->adres ), 29 )
      fl_hu := .t. ; i := 0
      Select HPU
      t_kod := hu->( RecNo() )
      find ( Str( t_kod, 7 ) )
      Do While t_kod == hpu->kod .and. !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        usl->( dbGoto( hpu->u_kod ) )
        Select PERSO
        Goto ( hpu->kod_vr )
        t_vr := perso->tab_nom
        t_nvr := fam_i_o( perso->fio )
        If fl_hu
          fl_hu := .f.
          add_string( afio[ 1 ] + " " + ;
            PadR( lstr( hu->kod_k ), 7 ) + " " + ;
            PadR( usl->name, 65 ) + " " + put_kop( hpu->u_cena, 7 ) + " " + ;
            PadR( lstr( hpu->kol ), 4 ) + " " + put_kop( hpu->stoim, 10 ) + " " + ;
            PadR( t_nvr, 15 ) + " " + ;
            full_date( c4tod( hpu->date_u ) ) + " " + ;
            full_date( iif( Empty( hu->k_data ), sys_date, hu->k_data ) ) )
          i := 1
        Else
          ++i
          add_string( iif( i <= kfio, afio[ i ], Space( 29 ) ) + " " + ;
            Space( 7 ) + " " + ;
            PadR( usl->name, 65 ) + " " + put_kop( hpu->u_cena, 7 ) + " " + ;
            PadR( lstr( hpu->kol ), 4 ) + " " + put_kop( hpu->stoim, 10 ) + " " + ;
            PadR( t_nvr, 15 ) + " " + ;
            full_date( c4tod( hpu->date_u ) ) + " " + ;
            full_date( iif( Empty( hu->k_data ), sys_date, hu->k_data ) ) )
        Endif
        Select HPU
        Skip
      Enddo
      If i == 1
        add_string( iif( 1 < kfio, afio[ 2 ], Space( 29 ) ) )
      Endif
      // подбивка итого
      add_string( Space( 29 ) + " " + ;
        Space( 7 ) + " " + ;
        Space( 65 ) + Space( 7 ) + ;
        "Итого: " + put_kop( hu->cena, 10 ) )
    Endif
    Select HU
    Skip
  Enddo
  Close databases
  add_string( Replicate( "─", sh ) )
  add_string( PadL( "Итого : " + Str( ss, 11, 2 ), sh - 12 ) )
  add_string( "" )
  add_string( "" )
  add_string( Center( "Главный врач _________________                         Главный бухгалтер _________________", sh ) )
  FClose( fp )
  rest_box( buf )
  Private yes_albom := .t.
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 

//
Function pl_or2dogovor( tip_jurn )

  Local buf := save_row( MaxRow() ), sh, HH := 51, arr_title, s, i, k, sk, ss, ;
    arr2title, reg_print := 6, afio[ 10 ], lfio := 19, kfio, lsk, lss, adbf, ;
    aadres[ 2 ], kadres, apolis[ 10 ], kpolis, name_file := cur_dir() + "jurnal1.txt", ;
    op_sm[ 10 ], op_date[ 10 ], op_kvit[ 10 ], op_tip[ 10 ], mas_tip := { "П", " ", "з", "Д" }, ;
    kol_opl := 0,sm_b := { 0, 0, 0 }, sm_pl := { 0, 0, 0 }, sm_dms := { 0, 0, 0 }, sm_vz := { 0, 0, 0 }, ;
    t_vr, t_as, t_nvr, t_nas

  arr_title := { ;
    "─────────────────────────────┬────────", ;
    "        Ф.И.О., адрес        │  Дата  ", ;
    "        застрахованного      │рождения", ;
    "                             │        ", ;
    "                             │        ", ;
    "─────────────────────────────┴────────" }
  // номер карты
  arr_1 := { ;
    "┬───────", ;
    "│ НОМЕР ", ;
    "│медицин", ;
    "│ карты ", ;
    "│Nнаряда", ;
    "┴───────" }
  // номер чека
  arr_2 := { ;
    "┬───────────────", ;
    "│    Оплата     ", ;
    "├──────┬────────", ;
    "│ Номер│ Сумма  ", ;
    "│ чека │        ", ;
    "┴──────┴────────" }
  // дата оплаты услуги
  arr_3 := { ;
    "┬────────", ;
    "│  Дата  ", ;
    "│ оплаты ", ;
    "│  мед.  ", ;
    "│ услуги ", ;
    "┴────────" }
  // дата оказания услуги
  arr_4 := { ;
    "┬─────────────────", ;
    "│      Лечение    ", ;
    "├────────┬────────", ;
    "│  Дата  │  Дата  ", ;
    "│ начала │ окон-ия", ;
    "┴────────┴────────" }
  // шифр услуги
  arr_5 := { ;
    "┬──────────", ;
    "│ Код мани-", ;
    "│ пуляции  ", ;
    "│          ", ;
    "│          ", ;
    "┴──────────" }
  // наименование услуги
  arr_6 := { ;
    "┬──────────────────────────────────────────────────", ;
    "│                                                  ", ;
    "│       Вид (наименование) медицинской услуги      ", ;
    "│                                                  ", ;
    "│                                                  ", ;
    "┴──────────────────────────────────────────────────" }
  // код врач
  arr_7 := { ;
    "┬─────", ;
    "│     ", ;
    "│     ", ;
    "│Врач ", ;
    "│     ", ;
    "┴─────" }
  // код м/c
  arr_8 := { ;
    "┬─────", ;
    "│     ", ;
    "│ Тех ", ;
    "│ ник ", ;
    "│     ", ;
    "┴─────" }
  // фио врача+м/с
  arr_9  := { ;
    "┬───────────────", ;
    "│               ", ;
    "│     Врач      ", ;
    "├───────────────", ;
    "│               ", ;
    "┴───────────────" }
  // цена услуги
  arr_10 := { ;
    "┬───────", ;
    "│  Цена ", ;
    "│ каждой", ;
    "│ услуги", ;
    "│ (руб.)", ;
    "┴───────" }
  // количество услуг
  arr_11 := { ;
    "┬────", ;
    "│Кол.", ;
    "│оказ", ;
    "│ус- ", ;
    "│луг ", ;
    "┴────" }
  // сумма услуг
  arr_00 := { ;
    "┬──────────", ;
    "│ Сумма за ", ;
    "│все кол-во", ;
    "│оказ.услуг", ;
    "│  (руб.)  ", ;
    "┴──────────" }
  Private glob_pozic
  If ( glob_pozic := inputnorpozic( T_ROW, T_COL - 5 ) ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  mywait()
  // создаем заголовок
  For i := 0 To 10
    If f_is_pozic( glob_pozic, i )
      For j := 1 To 6
        arr_title[ j ] += &( "arr_" + lstr( i + 1 ) + "[j]" )
      Next
    Endif
  Next
  For j := 1 To 6
    arr_title[ j ] += arr_00[ j ]
  Next
  //
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + "mo_pers",, "PERSO" )
  r_use( dir_server() + "organiz",, "ORG" )
  add_string( Center( "Ж У Р Н А Л", sh ) )
  If tip_jurn == 1
    add_string( Center( "учета заказов граждан на оказание им платных медицинских услуг(помощи)", sh ) )
  Else
    add_string( Center( "оказания ортопедических услуг по закрытым нарядам", sh ) )
  Endif
  add_string( Center( arr_m[ 4 ], sh ) )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HPU" )
  r_use( dir_server() + "hum_oro", dir_server() + "hum_oro", "HPO" )
  r_use( dir_server() + "hum_ort",, "HU" )
  If tip_jurn == 1
    Index On N_data to ( cur_dir() + "tmp_hum" ) For Between( N_data, arr_m[ 5 ], arr_m[ 6 ] )
  Else
    Index On k_data to ( cur_dir() + "tmp_hum" ) For Between( k_data, arr_m[ 5 ], arr_m[ 6 ] )
  Endif
  AEval( arr_title, {| x| add_string( x ) } )
  j := sk := ss := 0
  Select HU
  Go Top
  Do While !Eof()
    If hu->tip_usl == 0
      ++sm_pl[1 ]
      sm_pl[ 2 ] += hu->cena
    Elseif hu->tip_usl == 1
      ++sm_b[1 ]
      sm_b[ 2 ] += hu->cena
    Elseif hu->tip_usl == 2
      ++sm_vz[1 ]
      sm_vz[ 2 ] += hu->cena
    Else
      ++sm_dms[1 ]
      sm_dms[ 2 ] += hu->cena
    Endif
    ss += hu->cena
    Select KART
    Goto hu->kod_k
    kfio := perenos( afio, AllTrim( kart->fio ) + " " + AllTrim( kart->adres ), 29 )
    kol_opl := 0
    Select HPO
    find ( Str( hu->( RecNo() ), 7 ) )
    Do While hu->( RecNo() ) == hpo->kod .and. !Eof()
      ++kol_opl
      op_sm[ kol_opl ]   := hpo->cena_opl
      op_date[ kol_opl ] := hpo->PDATE
      op_kvit[ kol_opl ] := hpo->KV_CIA
      op_tip[ kol_opl ]  := mas_tip[ hpo->tip_usl + 1 ]
      If hpo->tip_usl == 0
        sm_pl[ 3 ] += hpo->cena_opl
      Elseif hpo->tip_usl == 1
        sm_b[ 3 ] += hpo->cena_opl
      Elseif hpo->tip_usl == 2
        sm_vz[ 3 ] += hpo->cena_opl
      Else
        sm_dms[ 3 ] += hpo->cena_opl
      Endif
      Skip
    Enddo
    fl_hu := .t.
    Select HPU
    t_kod := hu->( RecNo() )
    find ( Str( t_kod, 7 ) )
    Do While t_kod == hpu->kod .and. !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      usl->( dbGoto( hpu->u_kod ) )
      t_vr := ret_tabn( hpu->kod_vr )
      t_as := ret_tabn( hpu->kod_as )
      If fl_hu
        fl_hu := .f.
        Select PERSO
        Goto ( hpu->kod_vr )
        t_nvr := fam_i_o( perso->fio )
        add_string( afio[ 1 ] + " " + ;
          date_8( kart->date_r ) + " " + ; //
        iif( f_is_pozic( glob_pozic, 0 ), PadR( lstr( hu->kod_k ), 7 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 1 ), PadL( lstr( op_kvit[ 1 ] ) + op_tip[ 1 ], 6 ) + " " + put_kop( op_sm[ 1 ], 8 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 2 ), date_8( c4tod( op_date[ 1 ] ) ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 3 ), date_8( hu->n_data ) + " " + date_8( hu->k_data ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 4 ), usl->shifr + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 5 ), PadR( usl->name, 50 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 6 ), iif( t_vr > 0, PadL( lstr( t_vr ), 5 ), Space( 5 ) ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 7 ), iif( t_as > 0, PadL( lstr( t_as ), 5 ), Space( 5 ) ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 8 ), PadR( t_nvr, 15 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 9 ), put_kop( hpu->u_cena, 7 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 10 ), PadR( lstr( hpu->kol ), 4 ) + " ", "" ) + ;
          put_kop( hpu->stoim, 10 ) )
        i := 1
      Else
        ++i
        add_string( iif( i <= kfio, afio[ i ], Space( 29 ) ) + " " + ;
          Space( 8 ) + " " + ;
          iif( f_is_pozic( glob_pozic, 0 ), iif( i != 2,      Space( 7 ), "N " + PadL( lstr( hu->NAR_Z ), 5 ) ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 1 ), iif( i > kol_opl, iif( i == ( kol_opl + 1 ), "Итого: " + put_kop( hu->CENA, 8 ),Space( 15 ) ), ;
          PadL( lstr( op_kvit[ i ] ) + op_tip[ i ], 6 ) + " " + ;
          put_kop( op_sm[ i ], 8 ) ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 2 ), iif( i > kol_opl, Space( 8 ), date_8( c4tod( op_date[ kol_opl ] ) ) ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 3 ), Space( 18 ), "" ) + ;
          iif( f_is_pozic( glob_pozic, 4 ), usl->shifr + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 5 ), PadR( usl->name, 50 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 6 ), iif( t_vr > 0, PadL( lstr( t_vr ), 5 ), Space( 5 ) ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 7 ), iif( t_as > 0, PadL( lstr( t_as ), 5 ), Space( 5 ) ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 8 ), PadR( t_nvr, 15 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 9 ), put_kop( hpu->u_cena, 7 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 10 ), PadR( lstr( hpu->kol ), 4 ) + " ", "" ) + ;
          put_kop( hpu->stoim, 10 ) )
      Endif
      Select HPU
      Skip
    Enddo
    If i == 1 .and. 1 < kfio
      add_string( afio[ 2 ] )
    Endif
    // if mem_dop_st == 2
    add_string( "" )
    // endif
    Select HU
    Skip
  Enddo
  Close databases
  add_string( Replicate( "─", sh ) )
  add_string( PadL( "Итого : " + lstr( ss, 14, 2 ), sh ) )
  add_string( " Вид оплаты      Кол-во      Сумма нар-ов   Сумма оплаты" )
  add_string( "   Платные     " + Str( sm_pl[ 1 ], 11 ) + "   " + put_kop( sm_pl[ 2 ], 11 ) + "   " + put_kop( sm_pl[ 3 ], 11 ) )
  add_string( "   Бюджетный   " + Str( sm_b[ 1 ], 11 )  + "   " + put_kop( sm_b[ 2 ], 11 )  + "   " + put_kop( sm_b[ 3 ], 11 ) )
  add_string( "   Взаимозачет " + Str( sm_vz[ 1 ], 11 ) + "   " + put_kop( sm_vz[ 2 ], 11 ) + "   " + put_kop( sm_vz[ 3 ], 11 ) )
  add_string( "   ДМС         " + Str( sm_dms[ 1 ], 11 ) + "   " + put_kop( sm_dms[ 2 ], 11 ) + "   " + put_kop( sm_dms[ 3 ], 11 ) )
  If tip_jurn == 1
    add_string( "" )
    add_string( Center( "Главный врач _________________                         Главный бухгалтер _________________", sh ) )
  Endif
  FClose( fp )
  rest_box( buf )
  Private yes_albom := .t.
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 

// 13.11.18
Function oo_spmater()

  Local arr, sh, HH := 58, s, s1, s2, s3, fl, ;
    begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "orto_mt.txt", ;
    tip_tit, s4, ;
    arr_title := { ;
    "───────────────────────────────────────────────────────────────────────────────────┬───────────", ;
    "                  Наименование Услуги (входящие материалы)                         │   Расход  ", ;
    "───────────────────────────────────────────────────────────────────────────────────┴───────────" }
  Local reg, reg1, mperso, musluga, mkod, buf := save_row( MaxRow() )
  Local msl1usluga, msl2usluga, l_delen, mslusluga

  mywait()
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  sh := Len( arr_title[ 1 ] )
  add_string( "" )
  add_string( Center( "Настройка расхода материалов", sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  r_use( dir_server() + "tip_orto",, "OR0" )
  Index On Str( tip, 1 ) + name to ( cur_dir() + "tmp1" )
  r_use( dir_server() + "uslugi", dir_server() + "uslugi", "USL" )
  r_use( dir_server() + "ortoped",, "OR" )
  r_use( dir_server() + "ortoped1",, "OR1" )
  Index On Str( kod_menu, 4 ) to ( cur_dir() + "tmp2" )
  Set Relation To kod_ort into OR
  r_use( dir_server() + "ortoped2",, "OR2" )
  Set Relation To Str( kod_usl, 4 ) into USL
  //
  Select OR0
  Go Top
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( "" )
    add_string( or0->name )
    add_string( "  - исполнитель " + AllTrim( inieditspr( A__MENUVERT, mm_ortispol, or0->tip ) ) )
    Select OR2
    Index On usl->shifr to ( cur_dir() + "tmp4" ) For kod_tip == or0->( RecNo() )
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( "  -" + PadR( PadL( AllTrim( usl->shifr ), 9 ) + " " + usl->name, 82 ) )
      Skip
    Enddo
    add_string( "" )
    Select OR1
    find( Str( or0->( RecNo() ), 4 ) )
    Do While or0->( RecNo() ) == or1->kod_menu .and. !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If round_5( or1->massa, 3 ) > 0
        add_string( "  -" + PadR( AllTrim( or->name ), 83 ) + " " + Str( or1->massa, 8, 3 ) )
      Endif
      Skip
    Enddo
    Select OR0
    Skip
  Enddo
  Close databases
  FClose( fp )
  rest_box( buf )
  If !fl_exit
    viewtext( name_file,,,, ( sh > 80 ),,, 3 )
  Endif

  Return Nil

// 

// 13.11.18
Function oo1spmater()

  Local arr, sh, HH := 58, s, s1, s2, s3, fl, ;
    begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "orto1mt.txt", ;
    tip_tit, s4, ;
    arr_title := { ;
    "───────────────────────────────────────────────────────────────────────────────────┬───────────", ;
    "                   Наименование Услуги (входящие материалы)                        │   Расход  ", ;
    "───────────────────────────────────────────────────────────────────────────────────┴───────────" }
  Local reg, reg1, mperso, musluga, mkod, buf := save_row( MaxRow() )
  Local msl1usluga, msl2usluga, l_delen, mslusluga

  mywait()
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  sh := Len( arr_title[ 1 ] )
  add_string( "" )
  add_string( Center( "Настройка расхода материалов", sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  r_use( dir_server() + "uslugi", dir_server() + "uslugi", "USL" )
  r_use( dir_server() + "ortoped",, "OR" )
  //
  r_use( dir_server() + "ortoped1",, "OR1" )
  Index On Str( kod_menu, 4 ) to ( cur_dir() + "tmp2" )
  Set Relation To kod_ort into OR
  //
  r_use( dir_server() + "ortoped2",, "OR2" )
  Set Relation To Str( kod_usl, 4 ) into USL
  Index On usl->shifr to ( cur_dir() + "tmp1" )
  //
  Select OR2
  Go Top
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( "" )
    add_string( PadR( PadL( AllTrim( usl->shifr ), 9 ) + " " + usl->name, 82 ) )
    Select OR1
    find( Str( or2->kod_tip, 4 ) )
    Do While or2->kod_tip == or1->kod_menu .and. !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If round_5( or1->massa, 3 ) > 0
        add_string( "    -" + PadR( AllTrim( or->name ), 83 ) + " " + Str( or1->massa, 8, 3 ) )
      Endif
      Select OR1
      Skip
    Enddo
    //
    Select OR2
    Skip
  Enddo
  Close databases
  FClose( fp )
  rest_box( buf )
  If !fl_exit
    viewtext( name_file,,,, ( sh > 80 ),,, 3 )
  Endif

  Return Nil

// 

//
Function forma_30all( tip_f30 )

  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., tm, t, t1, t2, s_lu := 0, s_human := 0, ;
    kh := 0, jh := 0, arr_m, arr_pl, fl_per

  For j := 1 To 48
    t := "au" + lstr( j )
    Private &t
  Next
  If !get_nastr_orto_f30()
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If tip_f30 == 1 .and. !input_perso( T_ROW, T_COL - 5, .f. )
    Return Nil
  Endif
  Private speriod := arr_m[ 4 ]
  begin_date := arr_m[ 7 ]
  end_date := arr_m[ 8 ]
  //
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  delfrfiles()
  cre_tmp_30( { { "p_kod", "C", 4, 0 }, ;
    { "ddd", "D", 8, 0 }, ;
    { "sr_it", "N", 1, 0 }, ;
    { "tip", "N", 1, 0 }, ;   // 1-весь персонал, 2-перс.в отделении, 3-отделение
  { "otd", "N", 3, 0 }, ;
    { "tab_nom", "N", 5, 0 }, ;
    { "name", "C", 25, 0 }, ;
    { "kol_pos", "N", 4, 0 }, ;
    { "kol_ppos", "N", 4, 0 }, ;
    { "summa", "N", 12, 2 }, ;
    { "yet", "N", 10, 2 }, ;
    { "bud_hum", "N", 4, 0 }, ;
    { "bud_prot", "N", 4, 0 };
    } )
  Use ( fr_data ) New Alias TMP
  Index On Str( tip, 1 ) + p_kod to ( cur_dir() + "tmp" )
  r_use( dir_server() + "mo_otd",, "OTD" )
  r_use( dir_server() + "diag_ort", dir_server() + "diag_ort", "DBF1" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
  r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
  dbSeek( arr_m[ 5 ], .t. )
  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    If iif( tip_f30 == 1, glob_human[ 1 ] == human->kod_vr, .t. )
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      Select TMP
      find ( "1" + dtoc4( human->k_data ) )  // поиск по коду врача
      If !Found()
        Append Blank
        tmp->p_kod := dtoc4( human->k_data )
        tmp->ddd   := human->k_data
        tmp->tip   := 1
      Endif
      // блок по случаю
      // протезы
      k := human->KOL_PR1 + human->KOL_PR2 + human->KOL_PR3 + ;
        human->KOL_PR4 + human->KOL_PR5 + human->KOL_PR6
      If Empty( k )
        tmp->p22 += human->KOL_CELNL
        tmp->p16 += human->KOL_MOSTP
      Else
        tmp->p17 += human->KOL_PR1
        tmp->p18 += human->KOL_PR2
        tmp->p19 += human->KOL_PR3
        tmp->p20 += human->KOL_PR4
        tmp->p21 += human->KOL_PR5
        tmp->p22 += human->KOL_PR6
        tmp->p16 += k
      Endif
      tmp->p53++
      // диагнозы
      For i := 1 To 7
        pole := "human->kod_diag" + iif( i == 1, "", lstr( i ) )
        Select DBF1
        find ( &pole )
        If Found() .and. Between( dbf1->col_f39, 54, 60 )
          pole := "tmp->p" + lstr( dbf1->col_f39 )
          &pole := &pole + 1
        Endif
      Next
      // прочие
      tmp->kol_pos += human->kol_pos
      // проверяем на первичность
      Select HUMAN
      t := human->( RecNo() )
      t1 := Year( human->k_data )
      t2 := human->kod_k
      Skip -1
      fl_per := .t.
      Do While t1 == Year( human->k_data ) .and. !Bof()
        If t2 == human->kod_k
          fl_per := .f.
        Endif
        Skip -1
      Enddo
      If fl_per
        tmp->kol_ppos++
      Endif
      human->( dbGoto( t ) )
      tmp->summa += human->cena
      If human->tip_usl == 1 // бесплатные
        tmp->bud_hum++
        tmp->bud_prot := human->KOL_PR1 + human->KOL_PR2 + human->KOL_PR3 + ;
          human->KOL_PR4 + human->KOL_PR5 + human->KOL_PR6
      Endif
      If ( arr := yes_f_30( 0 ) ) != NIL
        ++jh
        For i := 1 To Len( arr )
          write_f30( arr[ i ] )
        Next
      Endif
      @ 24, 1 Say lstr( ++kh ) Color cColorSt2Msg
      If jh > 0
        @ Row(), Col() Say "/" Color "W/R"
        @ Row(), Col() Say lstr( jh ) Color cColorStMsg
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  Close databases
  rest_box( buf )
  mybell()
  //
  Use ( fr_data ) new
  Index On p_kod to ( fr_data )
  //
  dbCreate( fr_titl, { { "god", "N", 4, 0 }, ;
    { "tit1name", "C", 130, 0 }, ;
    { "tit2name", "C", 130, 0 }, ;
    { "tit3name", "C", 130, 0 } } )
  r_use( dir_server() + "organiz",, "ORG" )
  add_string( AllTrim( org->name ) )
  Use ( fr_titl ) new
  Append Blank
  Replace tit1name With AllTrim( org->name )
  Replace tit2name With AllTrim( arr_m[ 4 ] )
  If tip_f30 == 1 // по врачу
    Replace tit3name With AllTrim( glob_human[ 2 ] )
  Endif
  Close databases
  call_fr( "mo_ort39.fr3" )

  Return Nil

// 

// проверить больного по БД human и вернуть результат в виде массива
Static Function yes_f_30( par1 )

  Local i, j, k, s, arr, ret
  Private t_mas := Array( 45 )

  arr := {}
  Select HU
  find ( Str( human->( RecNo() ), 7 ) )
  Do While hu->kod == human->( RecNo() ) .and. !Eof()
    otd->( dbGoto( hu->otd ) )
    k := hu->kol
    AFill( lp, 0 )
    ___f_30( k )
    // УЕТ
    lp[ 63 ] := opr_uet( 0 ) * k
    If lp[ 64 ]
      AAdd( arr, AClone( lp ) )
    Endif
    Select HU
    Skip
  Enddo
  If Len( arr ) > 0
    Do Case
    Case par1 == 0  // по учреждению
      ret := arr
    Endcase
  Endif

  Return ret

// 

//
Function ___f_30( k )

  Local _1

  lp[ 64 ] := .f.
  For j := 1 To 48
    t := "au" + lstr( j )
    t1 := &t
    _1 := ( AScan( &t, {| x| x[ 2 ] == hu->u_kod } ) > 0 )
    If _1
      lp[ 64 ] := .t.
      lp[ j + 4 ]  := k
      If ( j + 4 ) == 41   // 15.12.13
        lp[ j + 1 ] := k * ( -1 )   // 38
      Endif
      If ( j + 4 ) == 39   // 15.12.13
        lp[ j + 2 ] := k * ( -1 )   // 3
      Endif
    Endif
  Next

  Return Nil

// 

// записать одну строку из массива в TMP-файл
Function write_f30( ar )

  Local i, pole

  For i := 1 To 52 // 16
    // поля 16-22 не записывать
    If Between( i, 16, 22 )
      //
    Else
      pole := "tmp->p" + lstr( i )
      &pole := &pole + ar[ i ]
    Endif
  Next
  tmp->yet := tmp->yet + ar[ 63 ]

  Return Nil

// 

// 02.12.12
Function forma_30_na( tip )

  Static arr := { 'Штифтово-культевая конструкция', ;                        // 1
    'Коронки металлические штампованные', ;                    // 2
    'Коронки цельнолитые', ;                                   // 3
    'Коронки пластмассовые', ;                                 // 4
    'Коронки металло-керамические', ;                          // 5
    'Коронки "безметалловая керамика прессованная"', ;         // 6
    'Коронки оксид-циркониевые', ;                             // 7
    'Коронки одиночные на имплантах', ;                        // 8
    'Коронки металло-акриловае', ;                             // 9
    'Коронки комбинированные', ;                               // 10
    'Коронки бюгельные', ;   // РАЗРЫВ 6                       // 11
  'Мостовидные протезы - "коронки "', ;          // 12
    'Мостовидные протезы - "коронки титановые"', ;             // 13
    'Мостовидные протезы - "коронки металло-керамические"', ;  // 14
  'Мостовидные протезы - "коронки оксид-циркониевые"', ;     // 15
    'Мостовидные протезы - "коронки металло-акриловые"', ;     // 16
    'Мостовидные протезы - "коронки штампованные"', ;          // 17
    'Мостовидные протезы - "коронки цельнолитые"', ;           // 18
    'Мостовидные протезы - "зубы литые"', ;                    // 19
    'Мостовидные протезы - "зубы фасеток"', ;                  // 20
    'Мостовидные протезы - "зубы металло-керамические"', ;     // 21
    'Мостовидные протезы - "зубы металло-акриловые"', ;        // 22
    'РЕЗЕРВ', ;                                                // 23
    'Мостовидные протезы - "зубы пластмассовые"', ;            // 24
    'Мостовидные протезы - "зубы цельнолитые"', ;              // 25
    'Съёмные протезы полные', ;                                // 26
    'Съёмные протезы полные с армированием', ;                 // 27
    'Съёмные протезы "частично съёмные"', ;                    // 28
    'Съёмные протезы "условно-съёмные"', ;                     // 29
    'Съёмные протезы с метал.базисом', ;                       // 30
    'Съёмные протезы паяные', ;                                // 31
    'Съёмные протезы цельнолитые', ;                           // 32
    'Съёмные протезы на замках', ;                             // 33
    'Иммедиат протезы', ;                                      // 34
    'Индивидуальные ложки', ;                                  // 35
    'Избирательное шлифование зубов', ;                        // 36
    'Снятие коронок', ;                                        // 37
    'Консультации', ;                                          // 38
    'Коррекции', ;                                             // 39
    'РЕЗЕРВ', ;                                                // 40
    'Починки протезов' }                                       // 41
  Local l, sh := 0, f39_scr := SaveScreen(), i
  Local HH := 58, name_file := cur_dir() + "orto_ns.txt", ;
    arr_title := { ;
    "──────────┬──────────────────────────────────────────────────────────────────", ;
    "   Шифр   │                                                                  ", ;
    "  услуги  │                  Наименование услуги                             ", ;
    "──────────┴──────────────────────────────────────────────────────────────────" }
  If tip == 1
    AEval( arr, {| x| sh := Max( sh, Len( x ) ) } )
    Do While ( l := Popup( T_ROW, T_COL - 5, 22, T_COL + sh - 2, arr, l ) ) > 0
      RestScreen( f39_scr )
      f1_forma_30_na( l, arr[ l ] )
    Enddo
    RestScreen( f39_scr )
  Else
    sh := Len( arr_title[ 1 ] )
    waitstatus( "<Esc> - прервать формирование" ) ; mark_keys( { "<Esc>" } )
    reg_print := 2
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "Настройка Форма 39-ОРТОПЕДИЯ", sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    add_string( "" )
    For i := 1 To 41
      add_string( "" )
      add_string( "==>> " + arr[ i ] )
      add_string( "" )
      f1_forma_30_prn_na( i, arr[ i ] )
      Go Top
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( tmp->u_shifr + "  " + tmp->u_name )
        Skip
      Enddo
      Close databases
    Next
    FClose( fp )
    RestScreen( f39_scr )
    viewtext( name_file )
    RestScreen( f39_scr )
  Endif

  Return Nil

// 

//
Function f1_forma_30_na( par, title )

  Local nfile := dir_server() + f30_nastr, name_sect
  Local adbf, arr_usl, i

  //
  name_sect := f30_sect + lstr( iif( par > 11, par + 7, par ) )
  arr_usl := getinisect( nFile, name_sect )
  adbf := { ;
    { "U_KOD",    "N",      4,      0 }, ;  // код услуги
  { "U_SHIFR",    "C",     10,      0 }, ;  // шифр услуги
  { "U_NAME",     "C",     65,      0 };   // наименование услуги
  }
  dbCreate( cur_dir() + "tmp", adbf )
  r_use( dir_server() + "uslugi",, "USL" )
  Use ( cur_dir() + "tmp" ) new
  For i := 1 To Len( arr_usl )
    Select USL
    Goto ( Val( arr_usl[ i, 2 ] ) )
    If !Eof() .and. usl->kod > 0
      Select TMP
      Append Blank
      tmp->u_kod := usl->kod
      tmp->u_shifr := usl->shifr
      tmp->u_name := usl->name
    Endif
  Next
  Select TMP
  Index On Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
  Index On fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
  Close databases
  ob2_v_usl(, 2, "Настройка формы 39: колонка " + title )
  If f_esc_enter( 1 )
    arr_usl := {}
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmpn" ) New Alias TMP
    Go Top
    Do While !Eof()
      AAdd( arr_usl, { tmp->u_shifr, lstr( tmp->u_kod ) } )
      Skip
    Enddo
    Close databases
    setinisect( nFile, name_sect, arr_usl )
  Endif

  Return Nil

// 

//
Function get_nastr_orto_f30()

  Local nf := dir_server() + f30_nastr, fl, i

  If ( fl := File( nf ) )
    For j := 1 To 48
      t := "au" + lstr( j )
      &t := getinisect( nf, f30_sect + lstr( j ) )
    Next
    fl := .f.
    For j := 1 To 48
      t := "au" + lstr( j )
      For i := 1 To Len( &t )
        fl := .t.
        &t[ i, 2 ] := Int( Val( &t[ i, 2 ] ) )
      Next
    Next
  Endif
  If !fl
    func_error( 4, "Не произведена настройка формы 39-ОРТ" )
  Endif

  Return fl

// 

//
Static Function cre_tmp_30( adbf )

  Local i

  For i := 1 To 60
    AAdd( adbf, { "p" + lstr( i ), "N", 7, 0 } )
  Next
  dbCreate( fr_data, adbf )

  Return Nil


// 

//
Function f1_forma_30_prn_na( par, title )

  Local nfile := dir_server() + f30_nastr, name_sect
  Local adbf, arr_usl, i

  //
  name_sect := f30_sect + lstr( iif( par > 11, par + 7, par ) )
  arr_usl := getinisect( nFile, name_sect )
  adbf := { ;
    { "U_KOD",    "N",      4,      0 }, ;  // код услуги
  { "U_SHIFR",    "C",     10,      0 }, ;  // шифр услуги
  { "U_NAME",     "C",     65,      0 };   // наименование услуги
  }
  dbCreate( cur_dir() + "tmp", adbf )
  r_use( dir_server() + "uslugi",, "USL" )
  Use ( cur_dir() + "tmp" ) new
  For i := 1 To Len( arr_usl )
    Select USL
    Goto ( Val( arr_usl[ i, 2 ] ) )
    If !Eof() .and. usl->kod > 0
      Select TMP
      Append Blank
      tmp->u_kod := usl->kod
      tmp->u_shifr := usl->shifr
      tmp->u_name := usl->name
    Endif
  Next
  Select TMP
  Index On fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )

  Return Nil

// 

// 18.11.14
Function or_vozvrat()

  Local fl := .t., buf := save_row( MaxRow() ), sm := 0, HH := 52, ;
    n_file := cur_dir() + "platn.txt", arr_m, sh, sm_sn := 0, krvz, arr_dms, ;
    sm_usl := 0
  Local arr_title := { ;
    "────────────────────────────────────────────────────────────┬───────────", ;
    "                           Пациент                          │   Сумма   ", ;
    "────────────────────────────────────────────────────────────┴───────────";
    }

  sh := Len( arr_title[ 1 ] )
  // if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
  // return NIL
  // endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  //
  mywait()
  fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
  add_string( Center( "ВОЗВРАТ оплаты нарядов", sh ) )
  add_string( Center( "(по дате возврата)", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  // tit_tip_usl(krvz,arr_dms,sh)
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  //
  r_use( dir_server() + "mo_pers",, "P2" )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "hum_ort",, "HUM_T" )
  r_use( dir_server() + "hum_oro",, "HUM_O" )
  Go Top
  Do While !Eof()
    If Between( hum_o->date_voz, arr_m[ 7 ], arr_m[ 8 ] ) .and. ;
        hum_o->SUM_VOZ > 0
      // ascan(krvz,hum_o->tip_usl) > 0 .and.
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      Select HUM_T
      Goto ( hum_o->kod )
      Select KART
      Goto ( hum_t->kod_k )
      add_string( PadR( "--" + AllTrim( kart->fio ) + "  ВОЗВРАТ", 59 ) + put_kope( hum_o->SUM_VOZ, 12 ) )
      sm_sn += hum_o->SUM_VOZ
      Select P2
      Goto ( hum_t->kod_vr )
      add_string( PadR( "Врач " + p2->fio, 50 ) )
      add_string( "" )
    Endif
    Select HUM_O
    Skip
  Enddo
  add_string( Replicate( "─", sh ) )
  add_string( PadR( "ИТОГО возврат: ",59 ) + put_kope( sm_sn,12 ) )
  Close databases
  FClose( fp )
  viewtext( n_file,,,, ( sh > 80 ),,, 1 )
  rest_box( buf )

  Return Nil


// 28.12.21
Function ort_priemshk()

  Local fl := .t., buf := save_row( MaxRow() ), sm2 := 0, HH := 52, ;
    n_file := cur_dir() + "platn.txt", arr_m, sh, krvz, arr_dms, ;
    sm_1 := 0, sm_2 := 0, sm_3 := 0, sm_bn := 0, ;
    mas_op1 := {}, mas_op2 := {}, i, arr[ 2 ]
  Local  arr_title := { ;
    "───┬──────────────────────────────────────┬──────┬─────┬──────┬──────────┬───┬─────┬──────────────", ;
    " N │           Ф.И.О. пациента            │Время │ Чек │Код П │  Сумма   │Тип│Наряд│      Врач    ", ;
    "───┴──────────────────────────────────────┴──────┴─────┴──────┴──────────┴───┴─────┴──────────────" }
  Local menu_opl := { { "ава", 0 }, ;
    { "опл", 1 }, ;
    { "нап", 2 } }

  sh := Len( arr_title[ 1 ] )
  // if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
  // return NIL
  // endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If !myfiledeleted( cur_dir() + "tmp" + sdbf() )
    Return Nil
  Endif
  //
  mywait()
  dbCreate( cur_dir() + "tmp", { { "kod",     "N",  4,  0 }, ;
    { "fio",     "C", 60,  0 }, ;
    { "chek",    "N", 10,  0 }, ;
    { "kod_hum", "N", 10,  0 }, ;
    { "operat",  "N", 10,  0 }, ;
    { "operatf", "C", 40,  0 }, ;
    { "fr_data", "D",  8,  0 }, ;
    { "fr_time", "N",  5,  0 }, ;
    { "t_flag",  "N",  1,  0 }, ;
    { "kod_vr",  "N",  4,  0 }, ;
    { "fio_vr",  "C", 60,  0 }, ;
    { "tip_op",  "N",  1,  0 }, ;
    { "nar_z",   "N",  5,  0 }, ;
    { "summa_bn", "N", 12,  2 }, ;
    { "summaN",  "N", 12,  2 }, ;
    { "summa",   "N", 12,  2 } } )
  Use ( cur_dir() + "tmp" ) new
  If yes_parol
    r_use( dir_server() + "base1",, "BASE1" )
  Endif
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "hum_ort",, "HUMAN" )
  r_use( dir_server() + "mo_pers",, "PERS" )
  r_use_base( "hum_oro" )
  Go Top
  Do While !Eof()
    If !Empty( ho->fr_data ) .and. Between( ho->fr_data, arr_m[ 7 ], arr_m[ 8 ] )
      Select HUMAN
      Goto ( ho->kod )
      Select KART
      Goto ( human->kod_k )
      Select TMP
      If ho->kod_reg == Asc( kod_polzovat ) .or. currentuser():isadmin() .or. currentuser():iskontroler()
        Append Blank
        tmp->fio      := kart->fio
        tmp->chek     := ho->kv_cia
        tmp->kod_hum  := human->kod_k
        tmp->fr_data  := c4tod( ho->fr_data )
        tmp->fr_time  := ho->fr_time
        tmp->summa    := ho->cena_opl
        tmp->kod_vr   := human->kod_vr
        tmp->tip_op   := ho->tip_opl
        tmp->nar_z    := human->nar_z
        tmp->summa_bn := ho->sbank
        Select PERS
        Goto ( human->kod_vr )
        tmp->fio_vr  := pers->fio
        tmp->operat  := ho->kod_reg
        tmp->t_flag := 0
        If yes_parol .and. ho->kod_reg > 0
          Select BASE1
          Goto ( ho->kod_reg )
          If !Eof() .and. !Empty( base1->p1 )
            tmp->operatf := AllTrim( Crypt( base1->p1, gpasskod ) )
          Endif
        Endif
      Endif
    Endif
    Select HO
    Skip
  Enddo
  Close databases
  Use ( cur_dir() + "tmp" ) new
  Index On operat to ( cur_dir() + "tmp_u" ) unique
  Go Top
  Do While !Eof()
    AAdd( mas_op1, tmp->operat )
    AAdd( mas_op2, tmp->operatf )
    Skip
  Enddo
  Close databases
  rest_box( buf )
  // запрос по операторам
  If Len( mas_op1 ) == 0
    bkol_oper := 0
    func_error( 4, "Нет информации " + arr_m[ 4 ] )
  Elseif Len( mas_op1 ) == 1
    bkol_oper := 1
  Else
    bkol_oper := popup_prompt( T_ROW, T_COL + 5, 1, mas_op2 )
  Endif
  If bkol_oper > 0
    fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( Center( "Р Е Е С Т Р", sh ) )
    add_string( Center( "регистрации чеков на оплату оказанных медицинских платных услуг населению", sh ) )
    r_use( dir_server() + "organiz",, "ORG" )
    For i := 1 To perenos( arr, AllTrim( org->name ), sh )
      add_string( Center( AllTrim( arr[ i ] ), sh ) )
    Next
    add_string( Center( arr_m[ 4 ], sh ) )
    // tit_tip_usl(krvz,arr_dms,sh)
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    sm2 := ii := 0
    Use ( cur_dir() + "tmp" ) new
    Index On fr_time to ( cur_dir() + "tmp_u" ) For operat == mas_op1[ bkol_oper ]
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      tt1 := inieditspr( A__MENUVERT, menu_opl, tmp->tip_op )
      add_string( Str( ++ii, 3 ) + " " + ;
        PadR( tmp->fio, 38 ) + ;
        iif( tmp->summa_bn > 0, "БН", "  " ) + ;
        PadR( SecToTime( tmp->fr_time ), 5 ) + " " + ;
        PadL( lstr( tmp->chek ), 5 ) + " " + ;
        PadL( lstr( tmp->kod_hum ), 6 ) + " " + ;
        iif( tmp->summa_bn > 0, put_kope( tmp->summa_bn, 10 ), put_kope( tmp->summa, 10 ) ) + " " + ;
        PadR( AllTrim( tt1 ), 3 ) + " " + ;
        PadL( lstr( tmp->nar_z ), 5 ) + " " + ;
        fam_i_o( tmp->fio_vr ) + ;
        iif( tmp->t_flag == 1, "*", " " ) )
      If tmp->summa > tmp->summa_bn .and. tmp->summa_bn > 0
        add_string( Str( ++ii, 3 ) + " " + ;
          PadR( tmp->fio, 38 ) + "  " + ;
          PadR( SecToTime( tmp->fr_time ), 5 ) + " " + ;
          PadL( lstr( tmp->chek ), 5 ) + " " + ;
          PadL( lstr( tmp->kod_hum ), 6 ) + " " + ;
          put_kope( tmp->summa - tmp->summa_bn, 10 ) + " " + ;
          PadR( AllTrim( tt1 ), 3 ) + " " + ;
          PadL( lstr( tmp->nar_z ), 5 ) + " " + ;
          fam_i_o( tmp->fio_vr ) + ;
          iif( tmp->t_flag == 1, "*", " " ) )
      Endif
      If tmp->tip_op == 0
        sm_1 += tmp->summa
      Elseif tmp->tip_op == 1
        sm_2 += tmp->summa
      Else
        sm_3 += tmp->summa
      Endif
      sm2 += tmp->summa
      sm_bn += tmp->summa_bn
      Select TMP
      Skip
    Enddo
    add_string( Replicate( "─", sh ) )
    add_string( PadR( "Итого: ", 61 ) + put_kope( sm2, 12 ) )
    add_string( Replicate( "─", sh ) )
    For i := 1 To perenos( arr, "Всего на сумму: " + srub_kop( sm2, .t. ), sh )
      add_string( arr[ i ] )
    Next
    If meK_bank == 1
      For i := 1 To perenos( arr, "из них в кассу: " + srub_kop( sm2 - sm_bn, .t. ), sh )
        add_string( arr[ i ] )
      Next
    Endif
    // add_string(padR("Аванс:    ",61)+put_kope(sm_1,12))
    // add_string(padR("Оплата:   ",61)+put_kope(sm_2,12))
    // add_string(padR("Напылене: ",61)+put_kope(sm_3,12))
    add_string( "" )
    add_string( "            Сдал мед.регистратор:              /" + AllTrim( mas_op2[ bkol_oper ] ) + "/" )
    add_string( "" )
    add_string( "            Принял кассир:                                /" + AllTrim( mek_kassir ) + "/" )
    FClose( fp )
    Close databases
    viewtext( n_file,,,, ( sh > 80 ),,, 3 )
  Endif

  Return Nil


// 

// 18.11.14 вызывается в "Ортопедия/Информация/Работа с кассой"
Function inf_fr_orto( k )

  Static si1 := 1, si2 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "Информация по ~кассе", ;
      "Реестр", ;
      "Возвраты" }
    mas_msg := { "Получение информации по состоянию кассового аппарата", ;
      "Реестр регистрации чеков на оплату", ;
      "Информация по возвратам" }
    mas_fun := { "inf_fr_orto(11)", ;
      "inf_fr_orto(12)", ;
      "inf_fr_orto(13)" }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    f1_inf_fr( 2 )
  Case k == 12
    ort_priemshk()
  Case k == 13
    or_vozvrat()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil
