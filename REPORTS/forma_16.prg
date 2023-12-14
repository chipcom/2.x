#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

//
Function forma_16( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j, uch_otd

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { " á¯¥ç âª  ~ä®à¬ë 16¢­", ;
      "”®à¬  16¢­ + ~¤¨ £­®§ë" }
    mas_msg := { " á¯¥ç âª  ä®à¬ë ü 16¢­", ;
      " á¯¥ç âª   ­ «®£  ä®à¬ë ü 16¢­ á ãâ®ç­¥­¨¥¬ ¤¨ £­®§®¢" }
    mas_fun := { "forma_16(11)", ;
      "forma_16(12)" }
    If pi1 == 1 // ¯® ¤ â¥ ®ª®­ç ­¨ï «¥ç¥­¨ï
      AAdd( mas_pmt, "~¥¤ ªâ¨à®¢ ­¨¥ ¡®«ì­¨ç­ëå" )
      AAdd( mas_msg, "¥¤ ªâ¨à®¢ ­¨¥ ¡®«ì­¨ç­ëå" )
      AAdd( mas_fun, "forma_16(13)" )
    Endif
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    forma_16_vn( .f. )
  Case k == 12
    forma_16_vn( .t. )
  Case k == 13
    edit_bolnich( 1 )
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// 15.01.23
Function forma_16_vn( is_diag )

  Static sy := 1
  Local begin_date, end_date, pole, file_form, jh := 0, jt := 0, ;
    i, j, k, buf := save_maxrow(), adbf, lfp, t_arr1[ 20 ], t_arr2[ 20 ], ;
    mdate_b_1, mdate_b_2, mshifr, mdate_r, mvozrast, d1, d2, ;
    arr_title, sh, HH := 76, reg_print := 6, n_file, ;
    yes_otd, fl, lshifr, arr_stroke := {}, ;
    lmenu := { "~‘¢®¤­ ï ¢¥¤®¬®áâì", "‚¥¤®¬®áâì ¯® ~®â¤¥«¥­¨î" }

  n_file := iif( is_diag, "_frm_16d", "_form_16" ) + stxt
  If ( file_form := search_file( "forma_16" + sfrm ) ) == NIL
    Return func_error( 4, "¥ ®¡­ àã¦¥­ ä ©« FORMA_16" + sfrm )
  Endif
  // if count_uch > 1
  AAdd( lmenu, "‚¥¤®¬®áâì ¯® ~ãçà¥¦¤¥­¨î" )
  // endif
  If ( yes_otd := popup_prompt( T_ROW, T_COL -5, sy, lmenu ) ) == 0
    Return Nil
  Elseif yes_otd == 2 .and. ( input_uch( T_ROW, T_COL -5, sys_date ) == Nil .or. ;
      input_otd( T_ROW, T_COL -5, sys_date ) == NIL )
    Return Nil
  Elseif yes_otd == 3 .and. input_uch( T_ROW, T_COL -5, sys_date ) == NIL
    Return Nil
  Endif
  sy := yes_otd
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  st_a_uchast := {}
  If equalany( yes_otd, 1, 3 ) .and. ( st_a_uchast := ret_uchast( T_ROW, T_COL -5 ) ) == NIL
    Return Nil
  Endif
  Private diag1 := {}, len_diag, ;
    s1sluch, s1dni, s1v[ 10 ], s2sluch, s2dni, s2v[ 10 ], ;
    arr_v := { { 15, 19 }, { 20, 24 }, { 25, 29 }, { 30, 34 }, { 35, 39 }, ;
    { 40, 44 }, { 45, 49 }, { 50, 54 }, { 55, 59 }, { 60, 999 } }
  s1sluch := s1dni := s2sluch := s2dni := 0
  AFill( s1v, 0 ) ; AFill( s2v, 0 )
  begin_date := arr_m[ 5 ]
  end_date := arr_m[ 6 ]
  adbf := { { "stroke", "C", 2, 0 }, ;
    { "pol", "C", 1, 0 }, ;
    { "sluch", "N", 7, 0 }, ;
    { "dni", "N", 7, 0 }, ;
    { "v1", "N", 7, 0 }, ;
    { "v2", "N", 7, 0 }, ;
    { "v3", "N", 7, 0 }, ;
    { "v4", "N", 7, 0 }, ;
    { "v5", "N", 7, 0 }, ;
    { "v6", "N", 7, 0 }, ;
    { "v7", "N", 7, 0 }, ;
    { "v8", "N", 7, 0 }, ;
    { "v9", "N", 7, 0 }, ;
    { "v10", "N", 7, 0 } }
  waitstatus()
  //
  dbCreate( cur_dir + "tmp", adbf )
  Use ( cur_dir + "tmp" ) New Alias TMP
  Index On stroke to ( cur_dir + "tmp" )
  lfp := FOpen( file_form )
  Do While .t.
    updatestatus()
    If feof( lfp )
      s := "54.  O03-O08 €¡®àâë"
    Else
      s := freadln( lfp )
    Endif
    If iif( is_diag, !( SubStr( s, 6, 1 ) == " " ), .t. )
      s1 := Left( s, 3 )
      s2 := AllTrim( Token( s, " ", 2 ) )
  /*for i := 1 to len(s2) // ¯à®¢¥àª  ­  àãááª¨¥ ¡ãª¢ë ¢ ¤¨ £­®§ å
    if ISRALPHA(substr(s2,i,1))
      strfile(s2+eos,"ttt.ttt",.t.)
      exit
    endif
  next*/
      diapazon := {}
      For i := 1 To NumToken( s2, "," )
        s3 := Token( s2, ",", i )
        If "-" $ s3
          d1 := Token( s3, "-", 1 )
          d2 := Token( s3, "-", 2 )
        Else
          d1 := d2 := s3
        Endif
        AAdd( diapazon, { diag_to_num( d1, 1 ), diag_to_num( d2, 2 ) } )
      Next
      AAdd( arr_stroke, Left( s1, 2 ) )
      If Right( s1, 1 ) == " "
        Append Blank
        tmp->stroke := s1 ; tmp->pol := "¬"
        AAdd( diag1, { s1, "Œ", diapazon } )
        //
        Append Blank
        s1 := StrZero( Val( s1 ) + 1, 2 )
        tmp->stroke := s1 ; tmp->pol := "¦"
        AAdd( diag1, { s1, "†", diapazon } )
      Else
        Append Blank
        tmp->stroke := s1 ; tmp->pol := "¦"
        AAdd( diag1, { s1, "†", diapazon } )
      Endif
      If tmp->stroke == "54"
        AAdd( arr_stroke, "55" )
        // ¤®¡ ¢«ï¥¬ ¤¢¥ áâà®ª¨ "¯® ãå®¤ã §  à¥¡¥­ª®¬"
        Append Blank
        tmp->stroke := "55" ; tmp->pol := "¬"
        Append Blank
        tmp->stroke := "56" ; tmp->pol := "¦"
        Exit
      Endif
    Endif
  Enddo
  FClose( lfp )
  len_diag := Len( diag1 )
  //
  If is_diag
    AAdd( adbf, { "diagnoz", "C", 5, 0 } )
    dbCreate( cur_dir + "tmp_dia", adbf )
    Use ( cur_dir + "tmp_dia" ) New Alias TMP_D
    Index On diagnoz + Upper( pol ) to ( cur_dir + "tmp_dia" )
  Endif
  //
  r_use( dir_server + "kartotek",, "KART" )
  If pi1 == 1 // ¯® ¤ â¥ ®ª®­ç ­¨ï «¥ç¥­¨ï
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human",, "BO" )
    Set Relation To kod_k into KART, To RecNo() into HUMAN_
    Index On DToS( k_data ) to ( cur_dir + "tmp_f16" ) ;
      For human_->oplata < 9 .and. func_pi_schet( .t., "bo" ) .and. ;
      bolnich > 0 .and. Between( date_b_2, arr_m[ 7 ], arr_m[ 8 ] ) ;
      progress
    Go Top
    Do While !Eof()
      updatestatus()
      @ MaxRow(), 1 Say lstr( ++jh ) Color cColorSt2Msg
      @ Row(), Col() Say "/" Color "W/R"
      @ Row(), Col() Say lstr( jt ) Color cColorStMsg
      date_24( bo->k_data )
      jt += f1_f16( yes_otd, is_diag, st_a_uchast )
      Select BO
      Skip
    Enddo
  Else
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humans", "BO" )
    Set Relation To kod_k into KART, To RecNo() into HUMAN_
    r_use( dir_server + "schet_",, "SCHET_" )
    r_use( dir_server + "schet", dir_server + "schetd", "SCHET" )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( arr_m[ 7 ], .t. )
    Do While schet->pdate <= arr_m[ 8 ] .and. !Eof()
      date_24( c4tod( schet->pdate ) )
      Select BO
      find ( Str( schet->kod, 6 ) )
      Do While bo->schet == schet->kod .and. !Eof()
        updatestatus()
        @ MaxRow(), 1 Say lstr( ++jh ) Color cColorSt2Msg
        @ Row(), Col() Say "/" Color "W/R"
        @ Row(), Col() Say lstr( jt ) Color cColorStMsg
        If human_->oplata < 9
          jt += f1_f16( yes_otd, is_diag, st_a_uchast )
        Endif
        Select BO
        Skip
      Enddo
      Select SCHET
      Skip
    Enddo
  Endif
  Close databases
  //
  mywait()
  arr_title := { ;
    "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÂÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ", ;
    "                            ³   ˜¨äà     ³³NN³—¨á«®  ³—¨á«®  ³        ¢ â®¬ ç¨á«¥ ¯® ¢®§à áâ ¬ («¥â):          ³‘à¥¤­ïï", ;
    "          à¨ç¨­            ³  ¯® ŒŠ    ³®³áâ³¤­¥©   ³á«ãç ¥¢ÃÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄ´¤«¨â-âì", ;
    "     ­¥âàã¤®á¯®á®¡­®áâ¨     ³   10-£®    ³«³à®³¢à¥¬¥­­³¢à¥¬¥­­³15- ³20- ³25- ³30- ³35- ³40- ³45- ³50- ³55- ³60«.³¯à¥¡ë¢.", ;
    "                            ³ ¯¥à¥á¬®âà  ³ ³ª¨³­¥âà-â¨³­¥âà-â¨³  19³  24³  29³  34³  39³  44³  49³  54³  59³¨ áâ³­  ¡/« ", ;
    "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÅÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÄÄÄ", ;
    "              1             ³      2     ³3³4 ³   5   ³   6   ³  7 ³  8 ³  9 ³ 10 ³ 11 ³ 12 ³ 13 ³ 14 ³ 15 ³ 16 ³   -   ", ;
    "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÁÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÁÄÄÄÄÁÄÄÄÄÁÄÄÄÄÁÄÄÄÄÁÄÄÄÄÁÄÄÄÄÁÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄ" }
  fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
  sh := Len( arr_title[ 1 ] )
  r_use( dir_server + "organiz",, "ORG" )
  add_string( PadR( org->name, 60 ) + PadL( "”®à¬  16-¢­", sh -60 ) )
  add_string( PadL( "“â¢¥à¦¤¥­ ", sh ) )
  add_string( PadL( "à¨ª §®¬ ®ááâ â ", sh ) )
  add_string( PadL( "®â 27.12.2022£. ü 985", sh ) )
  add_string( Center( "‘¢¥¤¥­¨ï ® ¯à¨ç¨­ å ¢à¥¬¥­­®© ­¥âàã¤®á¯®á®¡­®áâ¨", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  If yes_otd == 2
    add_string( "" )
    add_string( Center( glob_otd[ 2 ], sh ) )
  Elseif yes_otd == 3
    add_string( "" )
    add_string( Center( glob_uch[ 2 ], sh ) )
  Endif
  title_uchast( st_a_uchast, sh )
  If pi1 == 1
    add_string( Center( str_pi_schet(), sh ) )
  Else
    add_string( Center( "[ ¯® ¤ â¥ ¢ë¯¨áª¨ áç¥â  ]", sh ) )
  Endif
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  If is_diag
    r_use( dir_exe + "_mo_mkb", cur_dir + "_mo_mkb", "MKB10" )
    Use ( cur_dir + "tmp_dia" ) New Alias TMP_D
    Go Top
    Do While !Eof()
      If AScan( arr_stroke, tmp_d->stroke ) == 0
        tmp_d->stroke := StrZero( Val( tmp_d->stroke ) -1, 2 )
      Endif
      Skip
    Enddo
    Index On stroke + diagnoz + iif( pol == "Œ", "1", "2" ) to ( cur_dir + "tmp_dia" )
  Endif
  Use ( cur_dir + "tmp" ) index ( cur_dir + "tmp" ) new
  ft_use( file_form )
  Do While !ft_eof() .and. !Empty( s := ft_readln() )
    If iif( is_diag, !( SubStr( s, 6, 1 ) == " " ), .t. )
      s1 := Left( s, 2 )
      If SubStr( s, 3, 1 ) == " "
        k := 2
      Else
        k := 1
      Endif
      is_found := .f.
      Select TMP
      find ( s1 )
      If Found()
        is_found := ( tmp->dni > 0 )
        If !is_found .and. k == 2
          find ( StrZero( Val( s1 ) + 1, 2 ) )
          If Found()
            is_found := ( tmp->dni > 0 )
          Endif
        Endif
      Endif
      If iif( is_diag, is_found, .t. )
        s2 := Token( s, " ", 2 )
        s3 := Token( s, " ", 3 )
        s3 := SubStr( s, AtNum( s3, s, 1 ) )
        If !( SubStr( s, 6, 1 ) == " " )
          j1 := perenos( t_arr1, s3, 28 )
          If !is_diag .and. !ft_eof()
            ft_skip()
            ls1 := ft_readln()
            If SubStr( ls1, 6, 1 ) == " "
              // ++j1 ; t_arr1[j1] := "  ¢ â®¬ ç¨á«¥:"
            Endif
            ft_skip( -1 )
          Endif
        Elseif !( SubStr( s, 10, 1 ) == " " )
          j1 := perenos( t_arr1, s3, 25 )
          AEval( t_arr1, {| x, i| t_arr1[ i ] := Space( 3 ) + x }, 1, j1 )
        Else
          j1 := perenos( t_arr1, s3, 22 )
          AEval( t_arr1, {| x, i| t_arr1[ i ] := Space( 6 ) + x }, 1, j1 )
        Endif
        j2 := perenos( t_arr2, s2, 12, "," )
        find ( s1 )
        ls1 := PadR( RTrim( t_arr1[ 1 ] ), 28, "." ) + " " + ;
          PadR( t_arr2[ 1 ], 12 ) + " " + if( k == 2, "¬", "¦" ) + " " + s1 + ;
          put_val( tmp->dni, 8 ) + ;
          put_val( tmp->sluch, 8 ) + ;
          put_val( tmp->v1, 5 ) + ;
          put_val( tmp->v2, 5 ) + ;
          put_val( tmp->v3, 5 ) + ;
          put_val( tmp->v4, 5 ) + ;
          put_val( tmp->v5, 5 ) + ;
          put_val( tmp->v6, 5 ) + ;
          put_val( tmp->v7, 5 ) + ;
          put_val( tmp->v8, 5 ) + ;
          put_val( tmp->v9, 5 ) + ;
          put_val( tmp->v10, 5 ) + ;
          if( Empty( tmp->sluch ), "", umest_val( tmp->dni / tmp->sluch, 7, 1 ) )
        ls2 := PadR( t_arr1[ 2 ], 28 ) + " " + PadR( t_arr2[ 2 ], 12 )
        If k == 2
          s1_ := StrZero( Val( s1 ) + 1, 2 )
          find ( s1_ )
          ls2 += " ¦ " + s1_ + ;
            put_val( tmp->dni, 8 ) + ;
            put_val( tmp->sluch, 8 ) + ;
            put_val( tmp->v1, 5 ) + ;
            put_val( tmp->v2, 5 ) + ;
            put_val( tmp->v3, 5 ) + ;
            put_val( tmp->v4, 5 ) + ;
            put_val( tmp->v5, 5 ) + ;
            put_val( tmp->v6, 5 ) + ;
            put_val( tmp->v7, 5 ) + ;
            put_val( tmp->v8, 5 ) + ;
            put_val( tmp->v9, 5 ) + ;
            put_val( tmp->v10, 5 ) + ;
            if( Empty( tmp->sluch ), "", umest_val( tmp->dni / tmp->sluch, 7, 1 ) )
        Endif
        add_string( "" )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( ls1 )
        add_string( ls2 )
        For i := 3 To Max( j1, j2 )
          add_string( PadR( t_arr1[ i ], 28 ) + " " + PadR( t_arr2[ i ], 12 ) )
        Next
        If is_diag
          add_string( Replicate( "-", sh ) )
          Select TMP_D
          find ( s1 )
          Do While tmp_d->stroke == s1 .and. !Eof()
            lshifr := tmp_d->diagnoz
            Select MKB10
            find ( lshifr )
            s := AllTrim( mkb10->name ) + " "
            Skip
            Do While Left( mkb10->shifr, 5 ) == lshifr .and. mkb10->ks > 0 ;
                .and. !Eof()
              s += AllTrim( mkb10->name ) + " "
              Skip
            Enddo
            j1 := perenos( t_arr1, s, 35 )
            ls1 := lshifr + " " + PadR( t_arr1[ 1 ], 35 )
            ls2 := Space( 6 )  + PadR( t_arr1[ 2 ], 35 )
            ls1 += " " + Lower( tmp_d->pol ) + Space( 3 ) + ;
              put_val( tmp_d->dni, 8 ) + ;
              put_val( tmp_d->sluch, 8 ) + ;
              put_val( tmp_d->v1, 5 ) + ;
              put_val( tmp_d->v2, 5 ) + ;
              put_val( tmp_d->v3, 5 ) + ;
              put_val( tmp_d->v4, 5 ) + ;
              put_val( tmp_d->v5, 5 ) + ;
              put_val( tmp_d->v6, 5 ) + ;
              put_val( tmp_d->v7, 5 ) + ;
              put_val( tmp_d->v8, 5 ) + ;
              put_val( tmp_d->v9, 5 ) + ;
              put_val( tmp_d->v10, 5 ) + ;
              if( Empty( tmp_d->sluch ), "", ;
              umest_val( tmp_d->dni / tmp_d->sluch, 7, 1 ) )
            Select TMP_D
            Skip
            If !Eof()
              If lshifr == tmp_d->diagnoz
                ls2 += " " + Lower( tmp_d->pol ) + Space( 3 ) + ;
                  put_val( tmp_d->dni, 8 ) + ;
                  put_val( tmp_d->sluch, 8 ) + ;
                  put_val( tmp_d->v1, 5 ) + ;
                  put_val( tmp_d->v2, 5 ) + ;
                  put_val( tmp_d->v3, 5 ) + ;
                  put_val( tmp_d->v4, 5 ) + ;
                  put_val( tmp_d->v5, 5 ) + ;
                  put_val( tmp_d->v6, 5 ) + ;
                  put_val( tmp_d->v7, 5 ) + ;
                  put_val( tmp_d->v8, 5 ) + ;
                  put_val( tmp_d->v9, 5 ) + ;
                  put_val( tmp_d->v10, 5 ) + ;
                  if( Empty( tmp_d->sluch ), "", ;
                  umest_val( tmp_d->dni / tmp_d->sluch, 7, 1 ) )
              Else
                Skip -1
              Endif
            Endif
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( ls1 )
            add_string( ls2 )
            Select TMP_D
            Skip
          Enddo
          add_string( Replicate( "-", sh ) )
        Endif
      Endif
    Endif
    ft_skip()
  Enddo
  ft_use()
  t_arr1 := { ;
    "", ;
    "‚á¥£® ¯® § ¡®«¥¢ ­¨ï¬                     ¬ 52", ;
    "                                          ¦ 53", ;
    "  ¨§ ­¨å:  ¡®àâë (¨§ áâà.45) O03-O08      ¦ 54", ;
    "", ;
    "   ãå®¤ §  ¡®«ì­ë¬..........              ¬ 55", ;
    "                                          ¦ 56", ;
    "", ;
    "   ®â¯ãáª ¢ á¢ï§¨ á á ­ â®à-              ¬ 57", ;
    "   ­®-ªãà®àâ­ë¬ «¥ç¥­¨¥¬                  ¦ 58", ;
    "   (¡¥§ âã¡¥àªã«¥§  ¨ ¤®«¥-", ;
    "   ç¨¢ ­¨ï ¨­ä àªâ  ¬¨®ª à¤ )", ;
    "", ;
    "   ®á¢®¡®¦¤¥­¨¥ ®â à ¡®âë ¢               ¬ 59", ;
    "   á¢ï§¨ á ª à ­â¨­®¬ ¨                   ¦ 60", ;
    "   ¡ ªâ¥à¨®­®á¨â¥«ìáâ¢®¬", ;
    "", ;
    "  ¨§ ­¨å: ¢ á¢ï§¨ á ª à ­â¨­®¬   Z20.8,   ¬ 61", ;
    "   ¯® COVID-19 (¨§ áâà. 59 - 60) Z22.8,   ¦ 62", ;
    "                                 Z29.0", ;
    "", ;
    "ˆ’ŽƒŽ Ž ‚‘…Œ ˆ—ˆ€Œ                    ¬ 63", ;
    "                                          ¦ 64", ;
    "", ;
    "Žâ¯ãáª ¯® ¡¥à¥¬¥­­®áâ¨ ¨ à®¤ ¬            ¦ 65", ;
    "" }
  last_stroke := "*"
  Select TMP
  For i := 1 To Len( t_arr1 )
    If Empty( t_arr1[ 1 ] ) .and. verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    ls1 := t_arr1[ i ]
    If "¬ 52" == Right( t_arr1[ i ], 4 )
      ls1 := PadR( ls1, 46 ) + ;
        put_val( s1dni, 8 ) + ;
        put_val( s1sluch, 8 ) + ;
        put_val( s1v[ 1 ], 5 ) + ;
        put_val( s1v[ 2 ], 5 ) + ;
        put_val( s1v[ 3 ], 5 ) + ;
        put_val( s1v[ 4 ], 5 ) + ;
        put_val( s1v[ 5 ], 5 ) + ;
        put_val( s1v[ 6 ], 5 ) + ;
        put_val( s1v[ 7 ], 5 ) + ;
        put_val( s1v[ 8 ], 5 ) + ;
        put_val( s1v[ 9 ], 5 ) + ;
        put_val( s1v[ 10 ], 5 ) + ;
        if( Empty( s1sluch ), "", umest_val( s1dni / s1sluch, 7, 1 ) )
    Elseif "¦ 53" == Right( t_arr1[ i ], 4 )
      ls1 := PadR( ls1, 46 ) + ;
        put_val( s2dni, 8 ) + ;
        put_val( s2sluch, 8 ) + ;
        put_val( s2v[ 1 ], 5 ) + ;
        put_val( s2v[ 2 ], 5 ) + ;
        put_val( s2v[ 3 ], 5 ) + ;
        put_val( s2v[ 4 ], 5 ) + ;
        put_val( s2v[ 5 ], 5 ) + ;
        put_val( s2v[ 6 ], 5 ) + ;
        put_val( s2v[ 7 ], 5 ) + ;
        put_val( s2v[ 8 ], 5 ) + ;
        put_val( s2v[ 9 ], 5 ) + ;
        put_val( s2v[ 10 ], 5 ) + ;
        if( Empty( s2sluch ), "", umest_val( s2dni / s2sluch, 7, 1 ) )
    Elseif "¦ 54" == Right( t_arr1[ i ], 4 )
      find ( "54" )
      If iif( is_diag, ( tmp->dni > 0 ), .t. )
        ls1 := PadR( ls1, 46 ) + ;
          put_val( tmp->dni, 8 ) + ;
          put_val( tmp->sluch, 8 ) + ;
          put_val( tmp->v1, 5 ) + ;
          put_val( tmp->v2, 5 ) + ;
          put_val( tmp->v3, 5 ) + ;
          put_val( tmp->v4, 5 ) + ;
          put_val( tmp->v5, 5 ) + ;
          put_val( tmp->v6, 5 ) + ;
          put_val( tmp->v7, 5 ) + ;
          put_val( tmp->v8, 5 ) + ;
          put_val( tmp->v9, 5 ) + ;
          put_val( tmp->v10, 5 ) + ;
          if( Empty( tmp->sluch ), "", umest_val( tmp->dni / tmp->sluch, 7, 1 ) )
      Else
        ls1 := ""
      Endif
    Elseif "¬ 55" == Right( t_arr1[ i ], 4 )  // ¯® ãå®¤ã §  à¥¡¥­ª®¬
      find ( "55" )
      ls1 := PadR( ls1, 46 ) + ;
        put_val( tmp->dni, 8 ) + ;
        put_val( tmp->sluch, 8 ) + ;
        put_val( tmp->v1, 5 ) + ;
        put_val( tmp->v2, 5 ) + ;
        put_val( tmp->v3, 5 ) + ;
        put_val( tmp->v4, 5 ) + ;
        put_val( tmp->v5, 5 ) + ;
        put_val( tmp->v6, 5 ) + ;
        put_val( tmp->v7, 5 ) + ;
        put_val( tmp->v8, 5 ) + ;
        put_val( tmp->v9, 5 ) + ;
        put_val( tmp->v10, 5 ) + ;
        if( Empty( tmp->sluch ), "", umest_val( tmp->dni / tmp->sluch, 7, 1 ) )
      s1dni   += tmp->dni
      s1sluch += tmp->sluch
      s1v[ 1 ]  += tmp->v1
      s1v[ 2 ]  += tmp->v2
      s1v[ 3 ]  += tmp->v3
      s1v[ 4 ]  += tmp->v4
      s1v[ 5 ]  += tmp->v5
      s1v[ 6 ]  += tmp->v6
      s1v[ 7 ]  += tmp->v7
      s1v[ 8 ]  += tmp->v8
      s1v[ 9 ]  += tmp->v9
      s1v[ 10 ] += tmp->v10
    Elseif "¦ 56" == Right( t_arr1[ i ], 4 )  // ¯® ãå®¤ã §  à¥¡¥­ª®¬
      find ( "56" )
      ls1 := PadR( ls1, 46 ) + ;
        put_val( tmp->dni, 8 ) + ;
        put_val( tmp->sluch, 8 ) + ;
        put_val( tmp->v1, 5 ) + ;
        put_val( tmp->v2, 5 ) + ;
        put_val( tmp->v3, 5 ) + ;
        put_val( tmp->v4, 5 ) + ;
        put_val( tmp->v5, 5 ) + ;
        put_val( tmp->v6, 5 ) + ;
        put_val( tmp->v7, 5 ) + ;
        put_val( tmp->v8, 5 ) + ;
        put_val( tmp->v9, 5 ) + ;
        put_val( tmp->v10, 5 ) + ;
        if( Empty( tmp->sluch ), "", umest_val( tmp->dni / tmp->sluch, 7, 1 ) )
      s2dni   += tmp->dni
      s2sluch += tmp->sluch
      s2v[ 1 ]  += tmp->v1
      s2v[ 2 ]  += tmp->v2
      s2v[ 3 ]  += tmp->v3
      s2v[ 4 ]  += tmp->v4
      s2v[ 5 ]  += tmp->v5
      s2v[ 6 ]  += tmp->v6
      s2v[ 7 ]  += tmp->v7
      s2v[ 8 ]  += tmp->v8
      s2v[ 9 ]  += tmp->v9
      s2v[ 10 ] += tmp->v10
    Elseif "¬ 63" == Right( t_arr1[ i ], 4 )
      ls1 := PadR( ls1, 46 ) + ;
        put_val( s1dni, 8 ) + ;
        put_val( s1sluch, 8 ) + ;
        put_val( s1v[ 1 ], 5 ) + ;
        put_val( s1v[ 2 ], 5 ) + ;
        put_val( s1v[ 3 ], 5 ) + ;
        put_val( s1v[ 4 ], 5 ) + ;
        put_val( s1v[ 5 ], 5 ) + ;
        put_val( s1v[ 6 ], 5 ) + ;
        put_val( s1v[ 7 ], 5 ) + ;
        put_val( s1v[ 8 ], 5 ) + ;
        put_val( s1v[ 9 ], 5 ) + ;
        put_val( s1v[ 10 ], 5 ) + ;
        if( Empty( s1sluch ), "", umest_val( s1dni / s1sluch, 7, 1 ) )
    Elseif "¦ 64" == Right( t_arr1[ i ], 4 )
      ls1 := PadR( ls1, 46 ) + ;
        put_val( s2dni, 8 ) + ;
        put_val( s2sluch, 8 ) + ;
        put_val( s2v[ 1 ], 5 ) + ;
        put_val( s2v[ 2 ], 5 ) + ;
        put_val( s2v[ 3 ], 5 ) + ;
        put_val( s2v[ 4 ], 5 ) + ;
        put_val( s2v[ 5 ], 5 ) + ;
        put_val( s2v[ 6 ], 5 ) + ;
        put_val( s2v[ 7 ], 5 ) + ;
        put_val( s2v[ 8 ], 5 ) + ;
        put_val( s2v[ 9 ], 5 ) + ;
        put_val( s2v[ 10 ], 5 ) + ;
        if( Empty( s2sluch ), "", umest_val( s2dni / s2sluch, 7, 1 ) )
    Elseif is_diag
      ls1 := ""
    Endif
    If !emptyall( ls1, last_stroke )
      add_string( ls1 )
    Endif
    last_stroke := ls1
  Next
  Close databases
  FClose( fp )
  rest_box( buf )
  viewtext( n_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 02.01.15
Function f1_f16( yes_otd, is_diag, st_a_uchast )

  Local fl, mdate_b_1, mdate_b_2, mshifr, mpol, mvozrast, mdate_r, i, k, v, ;
    arr, pole, pole1, ret := 0

  If ( fl := ( bo->bolnich > 0 ) )
    mdate_b_1 := c4tod( bo->date_b_1 )
    mdate_b_2 := c4tod( bo->date_b_2 )
    fl := !emptyany( mdate_b_1, mdate_b_2 )
  Endif
  If fl
    fl := f_is_uchast( st_a_uchast, kart->uchast )
  Endif
  If fl
    If yes_otd == 2
      fl := ( bo->otd == glob_otd[ 1 ] )
    Elseif yes_otd == 3
      fl := ( bo->lpu == glob_uch[ 1 ] )
    Endif
  Endif
  If fl
    arr := diag_to_array( "bo" )
    fl := Len( arr ) > 0
  Endif
  If fl
    mshifr := PadR( arr[ 1 ], 5 )   // ¡¥à¥¬ â®«ìª® ®á­®¢­®© ¤¨ £­®§
    mdate_r := iif( human_->NOVOR > 0, human_->DATE_R2, bo->date_r )
    mpol := iif( human_->NOVOR > 0, human_->pol2, bo->pol )
    If ( k := ret_boln( mpol, mshifr ) ) != Nil .or. bo->bolnich == 2
      ret := 1
      If bo->bolnich == 2 // ¯® ãå®¤ã §  à¥¡¥­ª®¬
        mpol := "†" ; k := { "54" }
        mdate_r := human_->RODIT_DR  // ¤ â  à®¦¤¥­¨ï à®¤¨â¥«ï
        If human_->RODIT_POL == "Œ"
          mpol := "Œ" ; k := { "53" }  // ¯¥à¥®¯à¥¤¥«ï¥¬ ­®¬¥à áâà®ª¨
        Endif
      Endif
      mvozrast := count_years( mdate_r, bo->n_data )
      If ( v := AScan( arr_v, {| x| Between( mvozrast, x[ 1 ], x[ 2 ] ) } ) ) == 0
        v := 8
      Endif
      pole := "tmp->v" + lstr( v )
      pole1 := "tmp_d->v" + lstr( v )
      d := mdate_b_2 - mdate_b_1 + 1
      For i := 1 To Len( k )
        Select TMP
        find ( k[ i ] )
        tmp->sluch++
        tmp->dni += d
        &pole := &pole + 1
      Next
      If bo->bolnich < 2 // ­¥ ¯® ãå®¤ã §  à¥¡¥­ª®¬
        If Upper( mpol ) == "Œ"
          s1sluch++
          s1dni += d
          s1v[ v ] ++
        Else
          s2sluch++
          s2dni += d
          s2v[ v ] ++
        Endif
        If is_diag
          Select TMP_D
          find ( PadR( mshifr, 5 ) + Upper( mpol ) )
          If !Found()
            Append Blank
            tmp_d->diagnoz := mshifr
            tmp_d->pol := Upper( mpol )
            If ( i := AScan( k, {| x| Val( x ) < Val( "50" ) } ) ) > 0
              tmp_d->stroke := k[ i ]
            Endif
          Endif
          tmp_d->sluch++
          tmp_d->dni += d
          &pole1 := &pole1 + 1
        Endif
      Endif
    Endif
  Endif

  Return ret

//
Function ret_boln( lpol, lshifr )

  Local ret := {}, i, j, d, r

  d := diag_to_num( lshifr, 1 )
  For i := 1 To len_diag
    If Upper( lpol ) == Upper( diag1[ i, 2 ] )
      r := diag1[ i, 3 ]
      For j := 1 To Len( r )
        If Between( d, r[ j, 1 ], r[ j, 2 ] )
          AAdd( ret, diag1[ i, 1 ] )
          Exit
        Endif
      Next
    Endif
  Next
  If Len( ret ) == 0 ; ret := NIL ; Endif

  Return ret
