//
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch  := 1
Static f39_nastr := "f39_nast.ini"
Static f39_sect := "Форма 39 - "

//
Function forma_57( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "Распечатка ~формы 57", ;
      "Форма 57 + ~диагнозы", ;
      "Форма 57 + ~больные" }
    mas_msg := { "Распечатка формы № 57", ;
      "Распечатка аналога формы № 57 с уточнением диагнозов", ;
      "Распечатка аналога формы № 57 с уточнением диагнозов и со списком больных" }
    mas_fun := { "forma_57(11)", ;
      "forma_57(12)", ;
      "forma_57(13)" }
    If ret_is_talon() .and. pi1 == 1 // по дате окончания лечения
      AAdd( mas_pmt, "~Редактирование стат.талона" )
      AAdd( mas_msg, "Редактирование стат.талона" )
      AAdd( mas_fun, "forma_57(14)" )
    Endif
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    forma_57_( 1 )
  Case k == 12
    forma_57_( 2 )
  Case k == 13
    forma_57_( 3 )
  Case k == 14
    edit_bolnich( 2 )
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// 14.10.24
Function forma_57_( is_diag )

  Static sy := 1
  Local begin_date, end_date, pole, file_form, yes_god
  Local i, j, k, buf := save_maxrow(), adbf, lfp, t_arr1[ 20 ], t_arr2[ 20 ], ;
    fl_exit := .f., jh := 0, jt := 0, mshifr, mvozrast, d1, d2, ;
    arr_stroke := { {}, {}, {} }, fl, s, arr, bbuf, blk_usl, ab := {}

  file_form := dir_exe() + "_mo_form" + sdbf
  If !hb_FileExists( file_form )
    Return func_error( 4, "Не обнаружен файл настройки статистических форм " + Upper( file_form ) )
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  yes_god := ( arr_m[ 2 ] == 1 .and. arr_m[ 3 ] == 12 )
  If ( st_a_uchast := ret_uchast( T_ROW, T_COL - 5 ) ) == NIL
    Return Nil
  Endif
  Private diag1 := { {}, {}, {} }, fl_plus := !Empty( yes_d_plus ), len_diag[ 3 ]
  begin_date := arr_m[ 5 ]
  end_date := arr_m[ 6 ]
  adbf := { { "stroke", "C", 2, 0 }, ;
    { "table", "N", 4, 0 }, ;
    { "voz", "N", 1, 0 }, ;  // 1 - 3
    { "v04", "N", 7, 0 }, ;  // V01-Y98
    { "v05", "N", 7, 0 }, ;  // V01-V99
    { "v06", "N", 7, 0 }, ;  // дорожно-транспортные
    { "v07", "N", 7, 0 }, ;  // W00-X59
    { "v08", "N", 7, 0 }, ;  // W65-W74
    { "v09", "N", 7, 0 }, ;  // X00-X09
    { "v10", "N", 7, 0 }, ;  // X40-X49
    { "v11", "N", 7, 0 }, ;  // X42
    { "v12", "N", 7, 0 }, ;  // X45
    { "v13", "N", 7, 0 }, ;  // X60-X84
    { "v14", "N", 7, 0 }, ;  // X62
    { "v15", "N", 7, 0 }, ;  // X65
    { "v16", "N", 7, 0 }, ;  // X85-Y09
    { "v17", "N", 7, 0 }, ;  // Y10-Y34
    { "v18", "N", 7, 0 }, ;  // Y35-Y38
    { "v19", "N", 7, 0 }, ;  // Y40-Y84
    { "v20", "N", 7, 0 } }   // Y85-Y89
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  s := "V01-V04,V06.1,V09.2-V09.3,V10.4-V10.9,V11.4-V11.9,V12.4-V12.9,V13.4-V13.9," + ;
        "V14.4-V14.9,V15.4-V15.9,V16.4-V16.9,V17.4-V17.9,V18.4-V18.9,V19.4-V19.9," + ;
        "V20.4-V20.9,V21.4-V21.9,V22.4-V22.9,V23.4-V23.9,V24.4-V24.9,V25.4-V25.9," + ;
        "V26.4-V26.9,V27.4-V27.9,V28.4-V28.9,V29.4-V29.9," + ;
        "V30.5-V30.9,V31.5-V31.9,V32.5-V32.9,V33.5-V33.9,V34.5-V34.9,V35.5-V35.9," + ;
        "V36.5-V36.9,V37.5-V37.9,V38.5-V38.9,V39.4-V39.9," + ;
        "V40.5-V40.9,V41.5-V41.9,V42.5-V42.9,V43.5-V43.9,V44.5-V44.9,V45.5-V45.9," + ;
        "V46.5-V46.9,V47.5-V47.9,V48.5-V48.9,V49.4-V49.9," + ;
        "V50.5-V50.9,V51.5-V51.9,V52.5-V52.9,V53.5-V53.9,V54.5-V54.9,V55.5-V55.9," + ;
        "V56.5-V56.9,V57.5-V57.9,V58.5-V58.9,V59.4-V59.9," + ;
        "V60.5-V60.9,V61.5-V61.9,V62.5-V62.9,V63.5-V63.9,V64.5-V64.9,V65.5-V65.9," + ;
        "V66.5-V66.9,V67.5-V67.9,V68.5-V68.9,V69.4-V69.9," + ;
        "V70.5-V70.9,V71.5-V71.9,V72.5-V72.9,V73.5-V73.9,V74.5-V74.9,V75.5-V75.9," + ;
        "V76.5-V76.9,V77.5-V77.9,V78.5-V78.9,V79.4-V79.9,V82.1,V82.9"
  arr   := { "", "", "", ;  // 1 - 3
    "V01-Y98", ;
    "V01-V99", ;
    s, ;         // дорожно-транспортные
    "W00-X59", ;
    "W65-W74", ;
    "X00-X09", ;
    "X40-X49", ;
    "X42", ;
    "X45", ;
    "X60-X84", ;
    "X62", ;
    "X65", ;
    "X85-Y09", ;
    "Y10-Y34", ;
    "Y35-Y38", ;
    "Y40-Y84", ;
    "Y85-Y89" }
  Private yes_rule := read_rule( D_RULE_N_F57 ), arr_57_wide := {}
  For j := 1 To Len( arr )
    diapazon := {} ; s2 := arr[ j ]
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
    AAdd( arr_57_wide, diapazon )
  Next
  //
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On Str( voz, 1 ) + stroke to ( cur_dir() + "tmp" )
  Use ( file_form ) New Alias FRM
  Set Filter To forma == 57
  Go Top
  Do While !Eof()
    updatestatus()
    If frm->table == 1000
      x := 1
    Elseif frm->table == 2000
      x := 2
    Elseif frm->table == 3000
      x := 3
    Endif
    s1 := AllTrim( frm->stroke )     // номер строки
    If iif( is_diag > 1, s1 == "1", .t. )
      s2 := AllTrim( frm->diagnoz )  // диагнозы
      k := iif( "-" $ s2, "", Space( 2 ) )
      s4 := k + iif( frm->bold == 1, "<b>", "" ) + AllTrim( frm->name ) + iif( frm->bold == 1, "</b>", "" )     // наименование
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
      AAdd( arr_stroke[ x ], s1 )
      Select TMP
      Append Blank
      tmp->stroke := s1
      tmp->voz    := x
      tmp->table  := frm->table
      s2 := iif( frm->bold == 1, "<b>", "" ) + s2 + iif( frm->bold == 1, "</b>", "" )     // диагноз
      AAdd( diag1[ x ], { s1, 1, diapazon, frm->table, s2, s4 } )
    Endif
    Select FRM
    Skip
  Enddo
  frm->( dbCloseArea() )
  For i := 1 To 3
    len_diag[ i ] := Len( diag1[ i ] )
  Next
  //
  If is_diag > 1
    AAdd( adbf, { "diagnoz", "C", 5, 0 } )
    dbCreate( cur_dir() + "tmp_dia", adbf )
    Use ( cur_dir() + "tmp_dia" ) New Alias TMP_D
    Index On Str( voz, 1 ) + diagnoz to ( cur_dir() + "tmp_dia" )
  Endif
  If is_diag == 3
    AAdd( adbf, { "kod_human", "N", 7, 0 } )
    dbCreate( cur_dir() + "tmp_hum", adbf )
    Use ( cur_dir() + "tmp_hum" ) New Alias TMP_H
    Index On Str( voz, 1 ) + diagnoz + Str( kod_human, 7 ) to ( cur_dir() + "tmp_hum" )
  Endif
  //
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
  r_use( dir_server() + "human_2",, "HUMAN_2" )
  r_use( dir_server() + "human_",, "HUMAN_" )
  If yes_rule  // "исправляем" в соответствии с правилами статистики
    bbuf := save_maxrow()
    mywait( "Ждите. Создаётся условный индексный файл..." )
    If pi1 == 1 // по дате окончания лечения
      r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
      Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
      dbSeek( DToS( arr_m[ 5 ] ), .t. )
      Index On Str( kod_k, 7 ) + DToS( k_data ) to ( cur_dir() + "tmp_h" ) ;
        While k_data <= arr_m[ 6 ] ;
        For kod > 0 .and. human_->usl_ok == 3 .and. human_->oplata < 9 ;
        .and. human_->NOVOR == 0 .and. func_pi_schet()
    Else
      r_use( dir_server() + "schet",, "SCHET" )
      r_use( dir_server() + "human",, "HUMAN" )
      Set Relation To schet into SCHET, To RecNo() into HUMAN_, To RecNo() into HUMAN_2
      Index On Str( kod_k, 7 ) + DToS( k_data ) to ( cur_dir() + "tmp_h" ) ;
        For kod > 0 .and. human_->usl_ok == 3 .and. human_->oplata < 9 ;
        .and. human_->NOVOR == 0 .and. Between( schet->pdate, arr_m[ 7 ], arr_m[ 8 ] ) ;
        progress
    Endif
    rest_box( bbuf )
    hGauge := gaugenew(,,, "Попытка исправления в соответствии с правилами", .t. )
    gaugedisplay( hGauge )
    blk_usl := {|| f_is_uch( st_a_uch, human->lpu ) .and. f_is_uchast( st_a_uchast, kart->uchast ) }
    Select KART
    Go Top
    Do While !Eof()
      updatestatus()
      gaugeupdate( hGauge, RecNo() / LastRec() )
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If f1_prover_rule( blk_usl, ab, 57 )
        @ MaxRow(), 1 Say lstr( ++jh ) Color cColorSt2Msg
        @ Row(), Col() Say "/" Color "W/R"
        @ Row(), Col() Say lstr( jt ) Color cColorStMsg
        verify12rule( ab, kart->pol, yes_god )
        jt += f2_f57( is_diag )
      Endif
      Select KART
      Skip
    Enddo
    closegauge( hGauge )
  Else  // не "исправляем" в соответствии с правилами статистики
    If pi1 == 1 // по дате окончания лечения
      r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
      Set Relation To kod_k into KART, To RecNo() into HUMAN_, To RecNo() into HUMAN_2
      dbSeek( DToS( begin_date ), .t. )
      Do While human->k_data <= end_date .and. !Eof()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        updatestatus()
        @ MaxRow(), 1 Say lstr( ++jh ) Color cColorSt2Msg
        @ Row(), Col() Say "/" Color "W/R"
        @ Row(), Col() Say lstr( jt ) Color cColorStMsg
        If human_->usl_ok == 3 .and. human_->oplata < 9 .and. func_pi_schet() .and. ;
            f_is_uch( st_a_uch, human->lpu ) .and. f_is_uchast( st_a_uchast, kart->uchast )
          date_24( human->k_data )
          jt += f1_f57( is_diag )
        Endif
        Select HUMAN
        Skip
      Enddo
    Else
      r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
      Set Relation To kod_k into KART, To RecNo() into HUMAN_, To RecNo() into HUMAN_2
      r_use( dir_server() + "schet_",, "SCHET_" )
      r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
      Set Relation To RecNo() into SCHET_
      Set Filter To Empty( schet_->IS_DOPLATA )
      dbSeek( arr_m[ 7 ], .t. )
      Do While schet->pdate <= arr_m[ 8 ] .and. !Eof()
        date_24( c4tod( schet->pdate ) )
        Select HUMAN
        find ( Str( schet->kod, 6 ) )
        Do While human->schet == schet->kod
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          updatestatus()
          @ MaxRow(), 1 Say lstr( ++jh ) Color cColorSt2Msg
          @ Row(), Col() Say "/" Color "W/R"
          @ Row(), Col() Say lstr( jt ) Color cColorStMsg
          If human_->usl_ok == 3 .and. human_->oplata < 9 .and. f_is_uch( st_a_uch, human->lpu ) ;
              .and. f_is_uchast( st_a_uchast, kart->uchast )
            jt += f1_f57( is_diag )
          Endif
          Select HUMAN
          Skip
        Enddo
        Select SCHET
        Skip
      Enddo
    Endif
  Endif
  Close databases
  If fl_exit
    rest_box( buf )
    Return Nil
  Endif
  //
  mywait()
  delfrfiles()
  adbf := { { "name", "C", 255, 0 }, ;
    { "adres", "C", 255, 0 }, ;
    { "name1", "C", 255, 0 }, ;
    { "period", "C", 100, 0 } }
  dbCreate( fr_titl, adbf )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  //
  r_use( dir_server() + "organiz",, "ORG" )
  frt->name := AllTrim( org->name )
  frt->adres := AllTrim( org->adres )
  frt->period := arr_m[ 4 ]
  If pi1 == 1
    frt->name1 := str_pi_schet()
  Else
    frt->name1 := "[ по дате выписки счета ]"
  Endif
  If is_diag > 1
    r_use( dir_exe() + "_mo_mkb", cur_dir() + "_mo_mkb", "MKB10" )
    Use ( cur_dir() + "tmp_dia" ) index ( cur_dir() + "tmp_dia" ) New Alias TMP_D
  Endif
  If is_diag == 3
    r_use( dir_server() + "schet",, "SCHET" )
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human",, "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    Use ( cur_dir() + "tmp_hum" ) New Alias TMP_H
    Set Relation To kod_human into HUMAN
    Index On Str( voz, 1 ) + diagnoz + Upper( human->fio ) + DToS( human->k_data ) to ( cur_dir() + "tmp_hum" )
  Endif
  adbf := { ;
    { "name", "C", 250, 0 }, ;
    { "diagnoz", "C", 40, 0 }, ;
    { "stroke", "C", 10, 0 };
    }
  For i := 4 To 20
    AAdd( adbf, { "kol" + lstr( i ), "N", 8, 0 } )
  Next
  For i := 0 To 2
    name_f := fr_data + iif( i > 0, lstr( i ), "" )
    al := "FRD" + iif( i > 0, lstr( i ), "" )
    dbCreate( cur_dir() + name_f, adbf )
    e_use( cur_dir() + name_f,, al )
  Next
  Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
  For x := 1 To 3 // diag1[x] => {s1,1,diapazon,tmp->table,s2,s4}
    al := "FRD" + iif( x > 1, lstr( x - 1 ), "" )
    // diag1[x] => {s1,p_tip,diapazon,tmp->table,s2,s4}
    For ix := 1 To Len( diag1[ x ] )
      s1 := PadR( diag1[ x, ix, 1 ], 2 ) ; s1_ := diag1[ x, ix, 1 ]
      If iif( is_diag > 1, s1_ == "1", .t. )
        s2 := diag1[ x, ix, 5 ] // строка диагнозов
        s3 := diag1[ x, ix, 6 ] // наименование
        Select TMP
        find ( Str( x, 1 ) + s1 )
        dbSelectArea( al )
        Append Blank
        &al.->name := s3
        &al.->stroke := s1
        &al.->diagnoz := s2
        For i := 4 To 20
          pole1 := "tmp->v" + StrZero( i, 2 )
          pole2 := al + "->kol" + lstr( i )
          &pole2 := &pole1
        Next
        If is_diag > 1
          Select TMP_D
          find ( Str( x, 1 ) )
          Do While tmp_d->voz == x .and. !Eof()
            lshifr := tmp_d->diagnoz
            Select MKB10
            find ( lshifr )
            s := AllTrim( mkb10->name ) + " "
            Skip
            Do While Left( mkb10->shifr, 5 ) == lshifr .and. mkb10->ks > 0 .and. !Eof()
              s += AllTrim( mkb10->name ) + " "
              Skip
            Enddo
            dbSelectArea( al )
            Append Blank
            If is_diag == 3
              &al.->name := "<b>" + s + "</b>"
              &al.->diagnoz := "<b>" + lshifr + "</b>"
            Else
              &al.->name := s
              &al.->diagnoz := lshifr
            Endif
            &al.->stroke := ""
            For i := 4 To 20
              pole1 := "tmp_d->v" + StrZero( i, 2 )
              pole2 := al + "->kol" + lstr( i )
              &pole2 := &pole1
            Next
            If is_diag == 3
              Select TMP_H
              find ( Str( x, 1 ) + lshifr )
              Do While tmp_h->voz == x .and. tmp_h->diagnoz == lshifr .and. !Eof()
                s := ""
                If mem_kodkrt == 2 .and. is_uchastok == 2 .and. human->kod_k > 0
                  s := "[" + lstr( human->kod_k ) + "] "
                Endif
                s += AllTrim( human->fio ) + " " + Left( DToC( human->n_data ), 5 ) + "-" + Left( DToC( human->k_data ), 5 )
                If human->schet > 0
                  schet->( dbGoto( human->schet ) )
                  s += " сч.№" + AllTrim( schet->nomer_s ) + " от " + date_8( c4tod( schet->pdate ) )
                Endif
                dbSelectArea( al )
                Append Blank
                &al.->name := s
                &al.->stroke := ""
                &al.->diagnoz := ""
                For i := 4 To 20
                  pole1 := "tmp_h->v" + StrZero( i, 2 )
                  pole2 := al + "->kol" + lstr( i )
                  &pole2 := &pole1
                Next
                Select TMP_H
                Skip
              Enddo
            Endif
            Select TMP_D
            Skip
          Enddo
        Endif
      Endif
    Next
  Next
  Close databases
  rest_box( buf )
  call_fr( "mo_forma57" )

  Return Nil

// 05.01.17
Function f1_f57( is_diag )

  Local i, j, k, mshifr, mvozrast, d1, d2, fl, arr_d := {}, arr, tip_travma, ;
    mpol, k1, v3 := 0, s, is_talon := .t., adiag_talon[ 16 ]
  Private arr_v := { { 0, 17 }, { 18, 999 } }, arr_all := {}

  AFill( adiag_talon, 0 )
  For i := 1 To 16
    adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
  Next
  arr := { human_2->OSL1, human_2->OSL2, human_2->OSL3 }
  For i := 1 To Len( arr )
    If !Empty( lshifr := AllTrim( arr[ i ] ) )
      If eq_any( Left( lshifr, 1 ), "V", "W", "X", "Y" )
        AAdd( arr_all, PadR( lshifr, 5 ) )
      Endif
    Endif
  Next
  arr := { human->KOD_DIAG, ;
    human->KOD_DIAG2, ;
    human->KOD_DIAG3, ;
    human->KOD_DIAG4, ;
    human->SOPUT_B1, ;
    human->SOPUT_B2, ;
    human->SOPUT_B3, ;
    human->SOPUT_B4 }
  For i := 1 To Len( arr )
    If !Empty( lshifr := AllTrim( arr[ i ] ) )
      If eq_any( Left( lshifr, 1 ), "V", "W", "X", "Y" )
        AAdd( arr_all, PadR( lshifr, 5 ) )
      Endif
    Endif
  Next
  If human_->NOVOR > 0
    mpol := human_->POL2
    mvozrast := count_years( human_->DATE_R2, human->n_data )
  Else
    mpol := human->pol
    mvozrast := count_years( human->date_r, human->n_data )
  Endif
  v := ret_v_f57( mpol, mvozrast, @v3 )
  If Empty( tip_travma := ret_f_57_wide() ) // если NIL, то по-старому из меню типа травмы
    tip_travma := { 4 }
    Do Case
    Case human_->TRAVMA == 4 // {"Дорожно-транспортная пр-венная",4}, ;
      AAdd( tip_travma, 5 )
    Case human_->TRAVMA == 8 // {"Дор.трансп., не связанная с пр-вом",8}, ;
      AAdd( tip_travma, 5 )
      AAdd( tip_travma, 6 )
    Otherwise
      AAdd( tip_travma, 7 )
    Endcase
  Endif
  For i := 1 To Len( arr )
    fl := .f.
    s := SubStr( human->diag_plus, i, 1 )
    If eq_any( s, "+", "-" )  // старая форма
      fl := .t.
    Elseif is_talon
      s := adiag_talon[ i * 2 -1 ]
      fl := eq_any( s, 1, 2 )
      If !fl   // если не определен характер заболевания, то определяем его
        fl := eq_any( adiag_talon[ i * 2 ], 1, 2 )   // принудительно через диспансеризацию
      Endif
    Endif
    mshifr := PadR( arr[ i ], 5 )
    If fl .and. !Empty( mshifr ) .and. AScan( arr_d, mshifr ) == 0 .and. ( k := ret_f_12( v, mshifr ) ) != NIL
      AAdd( arr_d, mshifr )
      s_f1_f57( is_diag, k, mshifr, mpol, v, tip_travma )
      If v3 == 3 .and. ( k3 := ret_f_12( v3, mshifr ) ) != NIL
        s_f1_f57( is_diag, k3, mshifr, mpol, v3, tip_travma )
      Endif
    Endif
  Next

  Return iif( Len( arr_d ) > 0, 1, 0 )

// 05.01.17
Function ret_f_57_wide()

  Local ret := {}, i, j, k, d, r, lshifr

  For k := 1 To Len( arr_all ) // по всем диагнозам данного случая
    lshifr := arr_all[ k ]
    d := diag_to_num( lshifr, 1 )
    For i := 1 To Len( arr_57_wide ) // по всем колонкам в ширину
      r := arr_57_wide[ i ]
      For j := 1 To Len( r ) // по диапазону диагнозов в одной колонке
        If Between( d, r[ j, 1 ], r[ j, 2 ] )
          AAdd( ret, i )
        Endif
      Next j
    Next i
    If !Empty( ret ) ; exit ; Endif // если один из диагнозов нашли, - выходим из цикла
      Next k
    If Len( ret ) == 0 ; ret := NIL ; Endif
    Return ret

// 04.01.17
function s_f1_f57(is_diag, k, mshifr, mpol, v, tip_travma)

  Local i, icol, j, d1, d2, fl, arr_d := {}, s, ta, lk := len( k )

  ta := array( lk, 20)
  afillall( ta, 0 )
  for j := 1 to lk
    for i := 1 to len( tip_travma )
      icol := tip_travma[ i ]
      ta[ j, icol ] ++
    next
  next
  for j := 1 to lk
    select TMP
    find ( str( v, 1 ) + padr( k[ j, 1 ], 2 ) )
    for i := 4 to 20
      pole := "tmp->v" + strzero( i, 2 )
      &pole := &pole + ta[ j, i ]
    next
  next
  if is_diag > 1
    select TMP_D
    find ( str( v, 1 ) + padr( mshifr, 5 ) )
    if ! found()
      append blank
      tmp_d->diagnoz := mshifr
      tmp_d->voz := v
    endif
    for i := 4 to 20
      pole := "tmp_d->v" + strzero( i, 2 )
      &pole := &pole + ta[ 1, i ]
    next
  endif
  if is_diag == 3
    select TMP_H
    find ( str( v, 1 ) + padr( mshifr, 5 ) + str( human->kod, 7 ) )
    if ! found()
      append blank
      tmp_h->diagnoz := mshifr
      tmp_h->voz := v
      tmp_h->kod_human := human->kod
    endif
    for i := 4 to 20
      pole := "tmp_h->v" + strzero( i, 2 )
      &pole := &pole + ta[ 1, i ]
    next
  endif
  return NIL

// 05.01.17
Function f2_f57( is_diag )

  Local i, j, k, ll, mshifr, mvozrast, d1, d2, fl, tip_travma, ret := .f., ;
      v3 := 0, mpol, s, is_talon := .t.

  Private arr_v := { { 0, 17}, { 18, 999 } }
  select TMP1RULE
  find ( "1" )
  do while tmp1rule->tip == 1 .and. ! eof()
    if tmp1rule->kol1 > 0 .and. ! empty( tmp1rule->shifr )
      mshifr := padr( tmp1rule->shifr, 5 )
      mdate := kart->date_r
      select TMP2RULE
      find ( str( tmp1rule->kod, 6 ) )
      do while tmp2rule->kod == tmp1rule->kod .and. ! eof()
        mdate := max( mdate, tmp2rule->n_data )
        if !empty( tmp2rule->travma )
          tip_travma := list2arr( tmp2rule->travma )
        endif
        skip
      enddo
      // определяем возраст по дате начала самого последнего лечения
      mpol := kart->pol
      mvozrast := count_years( kart->date_r, mdate )
      v := ret_v_f57( mpol, mvozrast, @v3 )
      if (k := ret_f_12( v, mshifr ) ) != NIL
        if empty( tip_travma )
          tip_travma := { 4, 7 }
        endif
        ret := .t.
        s_f1_f57( is_diag, k, mshifr, kart->pol, v, tip_travma )
        if v3 == 3 .and. ( k3 := ret_f_12( v3, mshifr ) ) != NIL
          s_f1_f57( is_diag, k3, mshifr, mpol, v3, tip_travma )
        endif
      endif
    endif
    select TMP1RULE
    skip
  enddo
  return iif( ret, 1, 0 )

// 29.12.16
Function ret_v_f57( mpol, mvozrast, /*@*/v3 )

  Local v

  if ( v := ascan( arr_v, { | x | between( mvozrast, x[ 1 ], x[ 2 ] ) } ) ) == 0
    v := 2 // если почему-то не нашли - взрослые
  endif
  v3 := 0
  if v == 2 .and. ( ( mpol == "Ж" .and. mvozrast >= 55 ) .or. ( mpol == "М" .and. mvozrast >= 60 ) )
    v3 := 3 // взрослые старше трудоспособного возраста
  endif
  return v
