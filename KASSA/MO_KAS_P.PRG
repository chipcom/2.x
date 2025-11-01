//**************************************************************************
// mo_kas_p.prg
//**************************************************************************
// 05.02.14 prn_k_fr(k)
// prn_k_inf()
// 18.11.14 prn_k_svod() - á¢®¤ §  á¬¥­ã
// 14.08.14 prn_k_svod_period() - ¢ë¢®¤ á¢®¤  §  ¯¥à¨®¤ ¢à¥¬¥­¨ (¯® ¢á¥¬ á¬¥­ ¬)
// prn_k_plat()
// prn_k_ort(k)
// prn_rees_ort()
// prn_nez_nar()
// f1p_nez_nar()
//**************************************************************************
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 05.02.14
Function prn_k_fr( k )

  Static si1 := 1, si2 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "ˆ­ä®à¬ æ¨ï ¯® ~ª áá¥", ;
      "‘¢®¤ §  ~á¬¥­ã", ;
      "‘¢®¤ §  ~¯¥à¨®¤" }
    mas_msg := { "®«ãç¥­¨¥ ¨­ä®à¬ æ¨¨ ¯® á®áâ®ï­¨î ª áá®¢®£®  ¯¯ à â ", ;
      "‚ë¢®¤ á¢®¤  §  á¬¥­ã", ;
      "‚ë¢®¤ á¢®¤  §  ¯¥à¨®¤ ¢à¥¬¥­¨ (¯® ¢á¥¬ á¬¥­ ¬)" }
    mas_fun := { "prn_k_fr(11)", ;
      "prn_k_fr(12)", ;
      "prn_k_fr(13)" }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    f1_inf_fr( 3 )
  Case k == 12
    prn_k_svod()
  Case k == 13
    prn_k_svod_period()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif
  Return Nil

// 16.09.25 á¢®¤ §  á¬¥­ã
Function prn_k_svod()

  Local arr_m, buf, i, k, arr, n_file := cur_dir() + "smena.txt", sh := 64, ;
    kol_pl := 0, sum_pl := 0, kol_or := 0, sum_or := 0, ;
    kol_pl_b := 0, sum_pl_b := 0, kol_or_b := 0, sum_or_b := 0

  If ( arr_m := year_month( T_ROW, T_COL + 5,, 1 ) ) == NIL
    Return Nil
  Endif
  buf := save_row( MaxRow() )
  mywait()
  dbCreate( cur_dir() + "tmp", { { "n_chek", "N", 8, 0 }, ; // ­®¬¥à ç¥ª 
  { "pl_ort", "N", 1, 0 }, ; // 1-¯« â­ë¥, 2-®àâ®¯¥¤¨ï
  { "stoim", "N", 10, 2 } } ) // áã¬¬  ç¥ª 
  Use ( cur_dir() + "tmp" ) new
  Index On Str( n_chek, 8 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "kas_pl", dir_server() + "kas_pl2", "KPL" )
  find ( DToS( arr_m[ 5 ] ) )
  Do While kpl->k_data == arr_m[ 5 ] .and. !Eof()
    If kpl->smena == glob_smena
      Select TMP
      find ( Str( kpl->n_chek, 8 ) )
      If !Found()
        Append Blank
        tmp->n_chek := kpl->n_chek
        tmp->pl_ort := 1
        tmp->stoim := kpl->cena
        kol_pl++
        sum_pl += kpl->cena
        If !Empty( kpl->sbank ) // 18.11.14
          kol_pl_b++
          sum_pl_b += kpl->sbank
        Endif
      Endif
    Endif
    Select KPL
    Skip
  Enddo
  r_use( dir_server() + "kas_ort", dir_server() + "kas_ort2", "KOR" )
  find ( DToS( arr_m[ 5 ] ) )
  Do While kor->k_data == arr_m[ 5 ] .and. !Eof()
    If kor->smena == glob_smena .and. kor->n_chek > 0
      Select TMP
      find ( Str( kor->n_chek, 8 ) )
      If !Found()
        Append Blank
        tmp->n_chek := kor->n_chek
        tmp->pl_ort := 2
        tmp->stoim := kor->cena
        kol_or++
        sum_or += kor->cena
        If !Empty( kor->sbank )  // 18.11.14
          kol_or_b++
          sum_or_b += kor->sbank
        Endif
      Endif
    Endif
    Select KOR
    Skip
  Enddo
  Select TMP
  Go Top
  arr := { { tmp->n_chek, tmp->n_chek } } ; i := 1
  Do While !Eof()
    If tmp->n_chek - arr[ i, 2 ] > 1
      AAdd( arr, { tmp->n_chek, tmp->n_chek } ) ; ++i
    Else
      arr[ i, 2 ] := tmp->n_chek
    Endif
    Skip
  Enddo
  Close databases
  fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "‘¢®¤ §  á¬¥­ã ü " + lstr( glob_smena ), sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
//  add_string( Center( "Š áá¨à: " + AllTrim( fio_polzovat ), sh ) )
  add_string( Center( "Š áá¨à: " + AllTrim( AllTrim( hb_user_curUser:FIO ) ), sh ) )
  add_string( "" )
  For i := 1 To Len( arr )
    If arr[ i, 1 ] == arr[ i, 2 ]
      add_string( "—¥ª ü " + lstr( arr[ i, 1 ] ) )
    Else
      add_string( "—¥ª¨ á ü " + lstr( arr[ i, 1 ] ) + " ¯® ü " + lstr( arr[ i, 2 ] ) )
    Endif
  Next
  add_string( Replicate( "Ä", sh ) )
  If kol_pl > 0
    add_string( "‹€’›… “‘‹“ƒˆ   : " + lstr( kol_pl ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_pl, .t. ) + " àã¡." )
    If kol_pl_b > 0
      add_string( " ¢ â.ç. ­ «¨ç­ë¬¨: " + lstr( kol_pl - kol_pl_b ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_pl - sum_pl_b, .t. ) + " àã¡." )
      add_string( "         ¯® ª àâ¥: " + lstr( kol_pl_b ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_pl_b, .t. ) + " àã¡." )
    Endif
    add_string( Replicate( "Ä", sh ) )
  Endif
  If kol_or > 0
    add_string( "Ž’Ž…„ˆŸ        : " + lstr( kol_or ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_or, .t. ) + " àã¡." )
    If kol_or_b > 0
      add_string( " ¢ â.ç. ­ «¨ç­ë¬¨: " + lstr( kol_or - kol_or_b ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_or - sum_or_b, .t. ) + " àã¡." )
      add_string( "         ¯® ª àâ¥: " + lstr( kol_or_b ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_or_b, .t. ) + " àã¡." )
    Endif
    add_string( Replicate( "Ä", sh ) )
  Endif
  add_string( "ˆ_’_Ž_ƒ_Ž        : " + lstr( kol_pl + kol_or ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_pl + sum_or, .t. ) + " àã¡." )
  If kol_pl_b > 0 .or. kol_or > 0
    add_string( " ¢ â.ç. ­ «¨ç­ë¬¨: " + lstr( kol_pl - kol_pl_b + kol_or - kol_or_b ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_pl - sum_pl_b + sum_or - sum_or_b, .t. ) + " àã¡." )
    add_string( "         ¯® ª àâ¥: " + lstr( kol_pl_b + kol_or_b ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_pl_b + sum_or_b, .t. ) + " àã¡." )
  Endif
  add_string( Replicate( "Ä", sh ) )
  For i := 1 To perenos( arr, "‘ã¬¬  ¯à®¯¨áìî:  " + srub_kop( sum_pl + sum_or, .t. ), sh )
    add_string( arr[ i ] )
  Next
  add_string( "" )
  add_string( "" )
  add_string( Center( "®¤¯¨áì: ________________", sh ) )
  FClose( fp )
  rest_box( buf )
  viewtext( n_file )
  Return Nil

// 25.09.14 ¢ë¢®¤ á¢®¤  §  ¯¥à¨®¤ ¢à¥¬¥­¨ (¯® ¢á¥¬ á¬¥­ ¬)
Function prn_k_svod_period()

  Local arr_m, buf, n_file := cur_dir() + "kassa_sv.txt", sh := 64, ;
    kol_pl := 0, sum_pl := 0, kol_or := 0, sum_or := 0, HH := 60, ;
    kol_pl_b := 0, sum_pl_b := 0, kol_or_b := 0, sum_or_b := 0

  If ( arr_m := year_month( T_ROW, T_COL + 5 ) ) == NIL
    Return Nil
  Endif
  buf := save_row( MaxRow() )
  mywait()
  r_use( dir_server() + "kas_pl", dir_server() + "kas_pl2", "KPL" )
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While kpl->k_data <= arr_m[ 6 ] .and. !Eof()
    If kpl->n_chek > 0
      kol_pl++
      sum_pl += kpl->cena
      If kpl->sbank > 0
        kol_pl_b++
        sum_pl_b += kpl->sbank
      Endif
    Endif
    Select KPL
    Skip
  Enddo
  r_use( dir_server() + "kas_ort", dir_server() + "kas_ort2", "KOR" )
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While kor->k_data <= arr_m[ 6 ] .and. !Eof()
    If kor->n_chek > 0
      kol_or++
      sum_or += kor->cena
      If kor->sbank > 0
        kol_or_b++
        sum_or_b += kor->sbank
      Endif
    Endif
    Select KOR
    Skip
  Enddo
  Close databases
  fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "‘¢®¤ ¯® ª áá¥", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( "" )
  add_string( Replicate( "Ä", sh ) )
  If kol_pl > 0
    add_string( "‹€’›… “‘‹“ƒˆ   : " + lstr( kol_pl ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_pl, .t. ) + " àã¡." )
    If kol_pl_b > 0
      add_string( " ¢ â.ç. ­ «¨ç­ë¬¨: " + lstr( kol_pl - kol_pl_b ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_pl - sum_pl_b, .t. ) + " àã¡." )
      add_string( "         ¯® ª àâ¥: " + lstr( kol_pl_b ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_pl_b, .t. ) + " àã¡." )
    Endif
    add_string( Replicate( "Ä", sh ) )
  Endif
  If kol_or > 0
    add_string( "Ž’Ž…„ˆŸ        : " + lstr( kol_or ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_or, .t. ) + " àã¡." )
    If kol_or_b > 0
      add_string( " ¢ â.ç. ­ «¨ç­ë¬¨: " + lstr( kol_or - kol_or_b ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_or - sum_or_b, .t. ) + " àã¡." )
      add_string( "         ¯® ª àâ¥: " + lstr( kol_or_b ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_or_b, .t. ) + " àã¡." )
    Endif
    add_string( Replicate( "Ä", sh ) )
  Endif
  add_string( "ˆ_’_Ž_ƒ_Ž        : " + lstr( kol_pl + kol_or ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_pl + sum_or, .t. ) + " àã¡." )
  If kol_pl_b > 0 .or. kol_or > 0
    add_string( " ¢ â.ç. ­ «¨ç­ë¬¨: " + lstr( kol_pl - kol_pl_b + kol_or - kol_or_b ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_pl - sum_pl_b + sum_or - sum_or_b, .t. ) + " àã¡." )
    add_string( "         ¯® ª àâ¥: " + lstr( kol_pl_b + kol_or_b ) + " ç¥ª®¢ ­  áã¬¬ã " + lput_kop( sum_pl_b + sum_or_b, .t. ) + " àã¡." )
  Endif
  add_string( Replicate( "Ä", sh ) )
  FClose( fp )
  rest_box( buf )
  viewtext( n_file )
  Return Nil

//
Function prn_k_plat( tip_ot )

  Local buf, j, arr_m, s, sh, HH := 78, reg_print, ;
    arr_title, name_file := cur_dir() + "kas_boln.txt", ;
    ss := 0, skol := 0, susl := 0

  Default tip_ot To 1

  If tip_ot == 1
    If ( arr_m := year_month( T_ROW, T_COL + 5,, 1 ) ) == NIL
      Return Nil
    Endif
  Else
    If ( arr_m := year_month( T_ROW, T_COL + 5 ) ) == NIL
      Return Nil
    Endif
  Endif
  buf := save_row( MaxRow() )
  mywait()
  //
  dbCreate( cur_dir() + "tmp", { { "kod_k", "N", 7, 0 }, ; // ª®¤ ¡®«ì­®£® ¯® ª àâ®â¥ª¥
  { "rec_hp", "N", 7, 0 }, ; // ­®¬¥à § ¯¨á¨ ¯® ¡ §¥ "hum_..."
  { "n_chek", "N", 8, 0 }, ; // ­®¬¥à ç¥ª 
  { "KOL","N", 5, 0 }, ; // ª®«¨ç¥áâ¢® ãá«ã£
  { "STOIM","N", 10, 2 } } ) // ¨â®£®¢ ï áâ®¨¬®áâì ãá«ã£¨
  Use ( cur_dir() + "tmp" ) new
  r_use( dir_server() + "kas_pl_u", dir_server() + "kas_pl1u", "HPU" )
  r_use( dir_server() + "kas_pl", dir_server() + "kas_pl2", "HP" )
  If tip_ot == 1
    find ( DToS( arr_m[ 5 ] ) )
    Do While hp->k_data == arr_m[ 5 ] .and. !Eof()
      If iif( tip_ot == 1, hp->smena == glob_smena, .t. )
        Select TMP
        Append Blank
        tmp->kod_k  := hp->kod_k
        tmp->n_chek := hp->n_chek
        tmp->rec_hp := hp->( RecNo() )
        Select HPU
        find ( Str( hp->( RecNo() ), 7 ) )
        Do While hpu->kod == hp->( RecNo() ) .and. !Eof()
          tmp->kol += hpu->kol
          tmp->stoim += hpu->stoim
          Select HPU
          Skip
        Enddo
      Endif
      Select HP
      Skip
    Enddo
  Else
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While hp->k_data <= arr_m[ 6 ] .and. !Eof()
      Select TMP
      Append Blank
      tmp->kod_k  := hp->kod_k
      tmp->n_chek := hp->n_chek
      tmp->rec_hp := hp->( RecNo() )
      Select HPU
      find ( Str( hp->( RecNo() ), 7 ) )
      Do While hpu->kod == hp->( RecNo() ) .and. !Eof()
        tmp->kol += hpu->kol
        tmp->stoim += hpu->stoim
        Select HPU
        Skip
      Enddo
      Select HP
      Skip
    Enddo
  Endif
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If j == 0
    func_error( 4, "¥â á¢¥¤¥­¨© " + arr_m[ 4 ] + ", á¬¥­  " + lstr( glob_smena ) )
  Else
    mywait()
    reg_print := 5
    r_use( dir_server() + "mo_pers",, "PERSO" )
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "kas_pl_u", dir_server() + "kas_pl1u", "HPU" )
    Set Relation To u_kod into USL
    r_use( dir_server() + "kas_pl",, "HP" )
    r_use( dir_server() + "kartotek",, "KART" )
    Use ( cur_dir() + "tmp" ) New Alias TMP
    Set Relation To kod_k into KART, To rec_hp into HP
    Index On Str( n_chek, 8 ) to ( cur_dir() + "tmp" )
    arr_title := { ;
      "ÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ", ;
      "®¬¥à  ¬¡.³ ”.ˆ.Ž. ¡®«ì­®£®                                 ³ N ç¥ª ³ Š®«.³‘â®¨¬®áâì", ;
      "  ª àâë   ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÁÄÄÄÄÄÄÄ´ãá«ã£³  ãá«ã£  ", ;
      "          ³                                       ‚à ç   ³“á«ã£¨    ³     ³         ", ;
      "ÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ" }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "¥¥áâà ¯« â­ëå ãá«ã£", sh ) )
    If tip_ot == 1
      add_string( Center( arr_m[ 4 ] + ", á¬¥­  " + lstr( glob_smena ), sh ) )
//      add_string( Center( "Œ¥¤à¥£¨áâà â®à: " + AllTrim( fio_polzovat ), sh ) )
      add_string( Center( "Œ¥¤à¥£¨áâà â®à: " + AllTrim( hb_user_curUser:FIO ), sh ) )
    Else
      add_string( Center( arr_m[ 4 ], sh ) )
    Endif
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    Go Top
    Do While !Eof()
      If verify_ff( HH - 1, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      s := PadR( amb_kartan(), 11 ) + ;
        PadR( kart->fio, 49 ) + ;
        put_val( tmp->n_chek, 8 ) + ;
        Str( tmp->kol, 4 ) + ;
        put_kope( tmp->stoim, 12 )
      add_string( s )
      add_string( Replicate( "-", sh ) )
      Select HPU
      find ( Str( hp->( RecNo() ), 7 ) )
      Do While hpu->kod == hp->( RecNo() )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        s := PadL( lstr( ret_tabn( hpu->kod_vr ) ), 54 ) + ;
          Space( 4 ) + ;
          usl->shifr + ;
          Str( hpu->kol, 4 ) + ;
          put_kope( hpu->stoim, 12 )
        add_string( s )
        susl += hpu->kol
        //
        Select HPU
        Skip
      Enddo
      add_string( Replicate( "=", sh ) )
      ss += tmp->stoim
      skol++
      Select TMP
      Skip
    Enddo
    Close databases
    add_string( PadR( "ˆâ®£® : " + lstr( skol ) + " ç¥«.", sh - 6 -12 ) + ;
      Str( susl, 6 ) + put_kope( ss, 12 ) )
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  Return Nil

//
Function prn_k_ort( k )

  Static si1 := 1, si2 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "¥¥áâà §  ~¤¥­ì", ;
      "~¥§ ªàëâë¥ ­ àï¤ë" }
    mas_msg := { " á¯¥ç âª  à¥¥áâà  ®àâ®¯¥¤¨ç¥áª¨å ãá«ã£ §  ¤¥­ì", ;
      "‘¯¨á®ª ­¥§ ªàëâëå ­ àï¤®¢" }
    mas_fun := { "prn_k_ort(11)", ;
      "prn_k_ort(12)" }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    prn_rees_ort()
  Case k == 12
    prn_nez_nar()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif
  Return Nil

//
Function prn_rees_ort()

  Local buf, i, j, arr_m, s, sh, HH := 78, reg_print, ;
    arr_title, name_file := cur_dir() + "kas_boln.txt", ;
    ss[ 5 ], skol := 0, susl[ 5 ]

  If ( arr_m := year_month( T_ROW, T_COL + 5,, 1 ) ) == NIL
    Return Nil
  Endif
  buf := save_row( MaxRow() )
  mywait()
  //
  dbCreate( cur_dir() + "tmp", { { "kod_k", "N", 7, 0 }, ; // ª®¤ ¡®«ì­®£® ¯® ª àâ®â¥ª¥
  { "rec_hp", "N", 7, 0 }, ; // ­®¬¥à § ¯¨á¨ ¯® ¡ §¥ "hum_..."
  { "nomer_n", "N", 6, 0 }, ; // ­®¬¥à ­ àï¤ 
  { "year_n", "N", 4, 0 }, ;  // £®¤ ­ àï¤ 
  { "n_chek", "N", 8, 0 }, ; // ­®¬¥à ç¥ª 
  { "CENA", "N", 10, 2 }, ;   // áã¬¬  ®¯« âë
  { "KOD_VR",   "N",     4,     0 }, ; // ª®¤ ¢à ç 
  { "KOD_TEX",   "N",     4,     0 }, ; // ª®¤ â¥å­¨ª 
  { "KOL","N", 5, 0 }, ; // ª®«¨ç¥áâ¢® ãá«ã£
  { "STOIM","N", 10, 2 } } ) // ¨â®£®¢ ï áâ®¨¬®áâì ãá«ã£¨
  Use ( cur_dir() + "tmp" ) new
  r_use( dir_server() + "kas_ortu", dir_server() + "kas_or1u", "HPU" )
  r_use( dir_server() + "kas_ort", dir_server() + "kas_ort2", "HP" )
  find ( DToS( arr_m[ 5 ] ) )
  Do While hp->k_data == arr_m[ 5 ] .and. !Eof()
    If hp->smena == glob_smena
      Select TMP
      Append Blank
      tmp->kod_k   := hp->kod_k
      tmp->n_chek  := hp->n_chek
      tmp->cena    := hp->cena
      tmp->nomer_n := hp->nomer_n
      tmp->year_n  := hp->year_n
      tmp->rec_hp  := hp->( RecNo() )
      Select HPU
      find ( Str( hp->( RecNo() ), 7 ) )
      Do While hpu->kod == hp->( RecNo() ) .and. !Eof()
        tmp->kol += hpu->kol
        tmp->stoim += hpu->stoim
        Select HPU
        Skip
      Enddo
    Endif
    Select HP
    Skip
  Enddo
  If ( j := tmp->( LastRec() ) ) > 0
    Select HP
    Set Index to ( dir_server() + "kas_ort4" )
    Select TMP
    Go Top
    Do While !Eof()
      Select HP
      find ( Str( tmp->year_n, 4 ) + Str( tmp->nomer_n, 6 ) )
      Do While tmp->year_n == hp->year_n .and. tmp->nomer_n == hp->nomer_n .and. !Eof()
        If hp->tip_n > 0
          tmp->KOD_VR  := hp->KOD_VR
          tmp->KOD_TEX := hp->KOD_TEX
        Endif
        Select HP
        Skip
      Enddo
      Select TMP
      Skip
    Enddo
  Endif
  Close databases
  rest_box( buf )
  If j == 0
    func_error( 4, "¥â á¢¥¤¥­¨© " + arr_m[ 4 ] + ", á¬¥­  " + lstr( glob_smena ) )
  Else
    mywait()
    reg_print := 5
    r_use( dir_server() + "mo_pers",, "PERSO" )
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "kas_ortu", dir_server() + "kas_or1u", "HPU" )
    Set Relation To u_kod into USL
    r_use( dir_server() + "kas_ort",, "HP" )
    r_use( dir_server() + "kartotek",, "KART" )
    Use ( cur_dir() + "tmp" ) New Alias TMP
    Set Relation To kod_k into KART, To rec_hp into HP
    Index On Str( n_chek, 8 ) + Str( nomer_n, 6 ) to ( cur_dir() + "tmp" )
    AFill( ss, 0 ) ; AFill( susl, 0 )
    arr_title := { ;
      "ÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ", ;
      "®¬¥à  ¬¡.³®¬¥à ³  ”.ˆ.Ž. ¡®«ì­®£®                  ³     —¥ª      ³ Š®«.³‘â®¨¬®áâì", ;
      "  ª àâë   ³­ àï¤ ³                                   ³   ü (áã¬¬ )  ³ãá«ã£³  ãá«ã£  ", ;
      "ÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´     ³         ", ;
      "                               ‚à ç ³’¥å­¨ª³  ‚¨¤ ãá«ã£¨ ³  “á«ã£¨  ³     ³         ", ;
      "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ" }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "¥¥áâà ®àâ®¯¥¤¨ç¥áª¨å ãá«ã£", sh ) )
    add_string( Center( arr_m[ 4 ] + ", á¬¥­  " + lstr( glob_smena ), sh ) )
//    add_string( Center( "Œ¥¤à¥£¨áâà â®à: " + AllTrim( fio_polzovat ), sh ) )
    add_string( Center( "Œ¥¤à¥£¨áâà â®à: " + AllTrim( hb_user_curUser:FIO ), sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    Go Top
    Do While !Eof()
      If verify_ff( HH - 1, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If tmp->n_chek < 0
        s1 := "-"
      Else
        s1 := lstr( tmp->n_chek ) + " (" + lstr( tmp->cena, 11, 2 ) + ")"
      Endif
      s := PadR( amb_kartan(), 10 ) + ;
        PadC( AllTrim( lstr( tmp->nomer_n ) ), 8 ) + ;
        PadR( kart->fio, 34 ) + " " + ;
        PadC( s1, 16 ) + ;
        Str( tmp->kol, 3 ) + ;
        put_kope( tmp->stoim, 12 )
      add_string( s )
      add_string( Replicate( "-", sh ) )
      Select HPU
      find ( Str( hp->( RecNo() ), 7 ) )
      Do While hpu->kod == hp->( RecNo() )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        s := Str( ret_tabn( tmp->kod_vr ), 36 ) + ;
          put_val( ret_tabn( tmp->kod_tex ), 7 ) + ;
          PadL( AllTrim( inieditspr( 1, mm_kas_vid, hpu->vid ) ), 14 ) + ;
          " " + usl->shifr + ;
          Str( hpu->kol, 4 ) + ;
          put_kope( hpu->stoim, 12 )
        add_string( s )
        If Between( hpu->vid, 1, 5 )
          ss[ hpu->vid ] += hpu->stoim
          susl[ hpu->vid ] += hpu->kol
        Endif
        //
        Select HPU
        Skip
      Enddo
      skol++
      add_string( Replicate( "=", sh ) )
      Select TMP
      Skip
    Enddo
    Close databases
    arr := {}
    For i := 1 To 5
      If susl[ i ] > 0
        AAdd( arr, PadL( mm_kas_vid[ i, 1 ], 13 ) + Str( susl[ i ], 6 ) + put_kope( ss[ i ], 12 ) )
      Endif
    Next
    If Len( arr ) > 0
      add_string( PadR( "ˆâ®£® : " + lstr( skol ) + " ç¥«.", sh - 6 -12 -13 ) + arr[ 1 ] )
      For i := 2 To Len( arr )
        add_string( PadL( arr[ i ], sh ) )
      Next
    Endif
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  Return Nil

//
Function prn_nez_nar()

  Local buf := save_row( MaxRow() ), i, s1, s2, sh, HH := 60, reg_print, arr_title, ;
    name_file := cur_dir() + "nez_nar.txt"

  mywait()
  dbCreate( cur_dir() + "tmp", { { "kod_k", "N", 7, 0 }, ; // ª®¤ ¡®«ì­®£® ¯® ª àâ®â¥ª¥
  { "rec_hp", "N", 7, 0 }, ; // ­®¬¥à § ¯¨á¨ ¯® ¡ §¥ "hum_..."
  { "nomer_n", "N", 6, 0 }, ; // ­®¬¥à ­ àï¤ 
  { "year_n", "N", 4, 0 }, ;  // £®¤ ­ àï¤ 
  { "summa", "N", 10, 2 }, ;  // áã¬¬  ­ àï¤  ¡¥§ ¡¥á¯« â­ëå ãá«ã£
  { "sum_opl", "N", 10, 2 }, ; // áã¬¬  ®¯« âë
  { "KOD_VR", "N", 4, 0 } } )  // ª®¤ ¢à ç 
  Use ( cur_dir() + "tmp" ) new
  use_base( "kas_ortu", "HU" )
  r_use( dir_server() + "kas_ort",, "HUMAN" )
  Index On iif( tip_n > 0, "1", "2" ) to ( cur_dir() + "tmphum" )
  find ( "1" )
  Do While human->tip_n > 0 .and. !Eof()
    Select TMP
    Append Blank
    tmp->kod_k   := human->kod_k
    tmp->rec_hp  := human->( RecNo() )
    tmp->nomer_n := human->nomer_n
    tmp->year_n  := human->year_n
    tmp->KOD_VR  := human->kod_vr
    tmp->sum_opl := human->cena
    f1p_nez_nar()
    Select HUMAN
    Skip
  Enddo
  Select TMP
  Index On Str( year_n, 4 ) + Str( nomer_n, 6 ) to ( cur_dir() + "tmp" )
  Select HUMAN
  find ( "2" )
  Do While human->tip_n == 0 .and. !Eof()
    Select TMP
    find ( Str( human->year_n, 4 ) + Str( human->nomer_n, 6 ) )
    If Found()
      tmp->sum_opl += human->cena
      f1p_nez_nar()
    Endif
    Select HUMAN
    Skip
  Enddo
  r_use( dir_server() + "mo_pers",, "PERSO" )
  arr_title := { ;
    "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄ", ;
    "                                    ³     ³  ®¬¥à  ³  ‘ã¬¬    ³          º Žáâ «®áì ", ;
    "                ‚à ç                ³’ ¡.ü³  ­ àï¤  ³ ¯® ­ àï¤ã³  Ž¯« â   º ®¯« â¨âì ", ;
    "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÐÄÄÄÄÄÄÄÄÄÄ" }
  reg_print := f_reg_print( arr_title, @sh )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "¥§ ªàëâë¥ ®àâ®¯¥¤¨ç¥áª¨¥ ­ àï¤ë", sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  Select TMP
  Set Relation To kod_vr into PERSO
  Index On Upper( perso->fio ) + Str( year_n, 4 ) + Str( nomer_n, 6 ) to ( cur_dir() + "tmp" ) ;
    For !Empty( Round( summa - sum_opl, 2 ) )
  i := s1 := s2 := 0
  Go Top
  Do While !Eof()
    s := PadR( lstr( ++i ) + ". " + perso->fio, 36 )
    s += put_val( perso->tab_nom, 6 )
    s += " " + PadR( lstr( tmp->nomer_n ) + "/" + lstr( tmp->year_n ), 9 )
    s += put_kop( tmp->summa, 11 ) + put_kope( tmp->sum_opl, 11 )
    s += put_kop( tmp->summa - tmp->sum_opl, 11 )
    s1 += tmp->summa
    s2 += tmp->sum_opl
    If verify_ff( HH - 1, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( s )
    Select TMP
    Skip
  Enddo
  Close databases
  add_string( Replicate( "Ä", sh ) )
  add_string( PadL( "ˆâ®£® : ", sh - 11 * 3 ) + ;
    put_kop( s1, 11 ) + put_kope( s2, 11 ) + put_kop( s1 - s2, 11 ) )
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Return Nil

//
Function f1p_nez_nar()

  Select HU
  find ( Str( human->( RecNo() ), 7 ) )
  Do While hu->kod == human->( RecNo() ) .and. !Eof()
    If hu->vid != LPU_KAS_B_PL
      tmp->summa += hu->stoim
    Endif
    If equalany( hu->vid, LPU_KAS_DMS, LPU_KAS_VZ )
      tmp->sum_opl += hu->stoim
    Endif
    Select HU
    Skip
  Enddo
  Return Nil
