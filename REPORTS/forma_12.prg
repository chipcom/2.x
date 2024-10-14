#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch  := 1

//
Function forma_12( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j, uch_otd

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "Распечатка ~формы 12", ;
      "Форма + ~диагнозы", ;
      "С разбивкой по ~отделениям", ;
      "На 100000 ~населения" }
    mas_msg := { "Распечатка формы № 12", ;
      "Распечатка аналога формы 12 с уточнением диагнозов", ;
      "Распечатка аналога формы 12 (статистики по диагнозам) с разбивкой по отд-иям", ;
      "Распечатка аналога формы 12 на 100000 населения" }
    mas_fun := { "forma_12(11)", ;
      "forma_12(12)", ;
      "forma_12(13)", ;
      "forma_12(14)" }
    If ret_is_talon() .and. pi1 == 1 // по дате окончания лечения
      AAdd( mas_pmt, "~Редактирование стат.талона" )
      AAdd( mas_msg, "Редактирование стат.талона" )
      AAdd( mas_fun, "forma_12(15)" )
    Endif
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    forma_12_( .f., .f. )
  Case k == 12
    forma_12_( .t., .f. )
  Case k == 13
    forma_12_o()
  Case k == 14
    forma_12_( .f., .t. )
  Case k == 15
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
Function forma_12_( is_diag, is_100000 )

  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    s1_, s1, s2, s3, s4, d1, d2, diapazon, kh, hGauge, v, ;
    j1, j2, t_arr1, t_arr2, ls1, ls2, name1, ;
    fl_exit := .f., sh, sh1, HH := 80, reg_print, speriod, ;
    arr_title, name_file, s_lu := 0, tmp_color, adbf, lfp, ;
    md_plus, sd_plus, k_plus, jh := 0, arr_m, yes_god, ;
    file_form, is_talon := .t., bbuf, blk_usl, ab := {}

  If is_100000
    name_file := cur_dir + "_form12a" + stxt
  Else
    name_file := cur_dir + iif( is_diag, "_frm_12d", "_form_12" ) + stxt
  Endif
  Private adiag_talon[ 16 ], arr_v := { { 0, 14 }, { 0, 3 }, { 15, 17 }, { 18, 999 } }, ;
    len_name := { 28, 28, 28, 28, 28 }, kol_dt, koef_dt[ 5 ], p_is_voz[ 5 ], ;
    GOD_PENSIONEROV
  AFill( p_is_voz, .f. )

  file_form := dir_exe() + "_mo_form" + sdbf
  If !hb_FileExists( file_form )
    Return func_error( 4, "Не обнаружен файл настройки статистических форм _MO_FORM" + sdbf )
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  GOD_PENSIONEROV := arr_m[ 1 ]
  yes_god := ( arr_m[ 2 ] == 1 .and. arr_m[ 3 ] == 12 )
  If ( st_a_uchast := ret_uchast( T_ROW, T_COL - 5 ) ) == NIL
    Return Nil
  Endif
  If is_100000
    kol_dt := { 10000, 3000, 5000, 15000, 7000 }
    tmp_color := SetColor( cDataCGet )
    buf := box_shadow( 14, 2, 22, 77, color1, "Введите количество обслуживаемого населения", color8 )
    @ 16, 10 Say PadL( "Дети (до 14 лет)", 40 ) Get kol_dt[ 1 ] Pict "999999"
    @ 17, 10 Say PadL( "Дети первых трех лет жизни", 40 ) Get kol_dt[ 2 ] Pict "999999"
    @ 18, 10 Say PadL( "Дети (15-17 лет)", 40 ) Get kol_dt[ 3 ] Pict "999999"
    @ 19, 10 Say PadL( "Взрослые (старше 18 лет)", 40 ) Get kol_dt[ 4 ] Pict "999999"
    @ 20, 10 Say PadL( "Взрослые старше трудоспособного возраста", 40 ) Get kol_dt[ 5 ] Pict "999999"
    myread()
    rest_box( buf )
    If LastKey() == K_ESC
      Return Nil
    Endif
    For i := 1 To Len( kol_dt )
      koef_dt[ i ] := iif( kol_dt[ i ] > 0, 100000 / kol_dt[ i ], 0 )
    Next
  Endif
  Private fl_12_selo := ( f_alert( { 'Каким образом распечатывать форму 12 ?', ;
    '' }, ;
    { " Итого ", " По сельскому населению " }, ;
    1, "GR+/R", "W+/R", 18,, "GR+/R,N/BG" ) == 2 )
  buf := save_maxrow()
  Private fl_plus := .f.
  If !Empty( yes_d_plus )
    fl_plus := .t. ; md_plus := Array( Len( yes_d_plus ) )
    k_plus := Len( md_plus )
    AFill( md_plus, " " )
    AEval( md_plus, {| x, i| md_plus[ i ] := SubStr( yes_d_plus, i, 1 ) } )
    sd_plus := Array( k_plus )
    AFill( sd_plus, 0 )
  Endif
  speriod := arr_m[ 4 ]
  //
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  Private yes_rule := read_rule( D_RULE_N_F12 )
  //
  adbf := { { "stroke", "C", 8, 0 }, ;
    { "table", "N", 4, 0 }, ;
    { "tip", "N", 1, 0 }, ;
    { "voz", "N", 1, 0 }, ;   // 1 - 5
  { "sluch", "N", 7, 0 }, ;
    { "sluch5", "N", 7, 0 }, ;
    { "sluch6", "N", 7, 0 }, ;
    { "sluch7", "N", 7, 0 }, ;
    { "sluch8", "N", 7, 0 }, ;
    { "sluch9", "N", 7, 0 }, ;
    { "sluch10", "N", 7, 0 }, ;
    { "sluch11", "N", 7, 0 }, ;
    { "sluch12", "N", 7, 0 }, ;
    { "sluch13", "N", 7, 0 }, ;
    { "sluch14", "N", 7, 0 }, ;
    { "sluch15", "N", 7, 0 }, ;
    { "sluch16", "N", 7, 0 }, ;
    { "sluch17", "N", 7, 0 }, ;
    { "sluch18", "N", 7, 0 }, ;
    { "sluch19", "N", 7, 0 }, ;
    { "sluch20", "N", 7, 0 }, ;
    { "sluch21", "N", 7, 0 }, ;
    { "sluch22", "N", 7, 0 }, ;
    { "sluch23", "N", 7, 0 }, ;
    { "sluch24", "N", 7, 0 }, ;
    { "sluch25", "N", 7, 0 }, ;
    { "pervich", "N", 7, 0 }, ;
    { "dispans1", "N", 7, 0 }, ;
    { "dispans", "N", 7, 0 }, ;
    { "i_sluch", "N", 7, 0 }, ;
    { "i_pervich", "N", 7, 0 }, ;
    { "i_dispans", "N", 7, 0 } }
  //
  dbCreate( cur_dir + "tmp_tab", adbf )
  Use ( cur_dir + "tmp_tab" ) New Alias TMP_TAB
  Index On stroke + Str( tip, 1 ) + Str( voz, 1 ) to ( cur_dir + "tmp_tab" )
  //
  dbCreate( cur_dir + "tmp_kart", { { "kod_k", "N", 7, 0 }, ;
    { "voz", "N", 1, 0 }, ;   // 1 - 5
  { "let", "N", 2, 0 }, ;
    { "perv", "N", 1, 0 }, ;
    { "disp1", "N", 1, 0 }, ;
    { "disp", "N", 1, 0 } } )
  Use ( cur_dir + "tmp_kart" ) new
  Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_kart" )
  //
  Private diag1 := { {}, {}, {}, {}, {} }, len_diag[ 5 ], p_tip := 1, x := 0
  Use ( file_form ) New Alias TMP
  Set Filter To forma == 12
  Go Top
  Do While !Eof()
    updatestatus()
    If tmp->table == 1000
      x := 1
    Elseif tmp->table == 1500
      x := 2
    Elseif tmp->table == 2000
      x := 3
    Elseif tmp->table == 3000
      x := 4
    Elseif tmp->table == 4000
      x := 5
    Endif
    s1 := AllTrim( tmp->stroke )     // номер строки
    If iif( is_diag, ( Right( s1, 2 ) == ".0" ), .t. )
      s2 := AllTrim( tmp->diagnoz )  // диагнозы
      k := st_nom_stroke( s1 )
      s4 := k + iif( tmp->bold == 1, "<b>", "" ) + AllTrim( tmp->name ) + iif( tmp->bold == 1, "</b>", "" )     // наименование
      diapazon := {}
      For i := 1 To NumToken( s2, ", ;" )
        s3 := Token( s2, ", ;", i )
        If "-" $ s3
          d1 := Token( s3, "-", 1 )
          d2 := Token( s3, "-", 2 )
        Else
          d1 := d2 := s3
        Endif
        AAdd( diapazon, { diag_to_num( d1, 1 ), diag_to_num( d2, 2 ) } )
      Next
      p_tip := 1
      If eq_any( SubStr( lstr( tmp->table ), 2, 1 ), "1", "6" )
        p_tip := 2
      Endif
      Select TMP_TAB
      Append Blank
      tmp_tab->stroke := s1
      tmp_tab->tip    := p_tip
      tmp_tab->voz    := x
      tmp_tab->table  := tmp->table
      AAdd( diag1[ x ], { s1, p_tip, diapazon, tmp->table, s2, s4 } )
    Endif
    Select TMP
    Skip
  Enddo
  tmp->( dbCloseArea() )
  //
  For i := 1 To 5
    len_diag[ i ] := Len( diag1[ i ] )
  Next
  If is_diag
    AAdd( adbf, { "diagnoz", "C", 5, 0 } )
    dbCreate( cur_dir + "tmp_dia", adbf )
    Use ( cur_dir + "tmp_dia" ) New Alias TMP_D
    Index On Str( voz, 1 ) + diagnoz to ( cur_dir + "tmp_dia" )
  Endif
  delfrfiles()
  adbf := { { "name", "C", 255, 0 }, ;
    { "adres", "C", 255, 0 }, ;
    { "name1", "C", 255, 0 }, ;
    { "v1001_1", "N", 6, 0 }, ;
    { "v1001_2", "N", 6, 0 }, ;
    { "v1001_3", "N", 6, 0 }, ;
    { "v1002_1", "N", 6, 0 }, ;
    { "v1002_2", "N", 6, 0 }, ;
    { "v1650_1", "N", 6, 0 }, ;
    { "v1700_1", "N", 6, 0 }, ;
    { "v1800_1", "N", 6, 0 }, ;
    { "v1800_2", "N", 6, 0 }, ;
    { "v1800_3", "N", 6, 0 }, ;
    { "v1800_4", "N", 6, 0 }, ;
    { "v1900_5", "N", 6, 0 }, ;
    { "v1900_6", "N", 6, 0 }, ;
    { "v1900_7", "N", 6, 0 }, ;
    { "v1900_8", "N", 6, 0 }, ;
    { "v1900_9", "N", 6, 0 }, ;
    { "v2001_1", "N", 6, 0 }, ;
    { "v2001_2", "N", 6, 0 }, ;
    { "v2001_3", "N", 6, 0 }, ;
    { "v2001_4", "N", 6, 0 }, ;
    { "v3002_1", "N", 6, 0 }, ;
    { "v3002_2", "N", 6, 0 }, ;
    { "v3002_3", "N", 6, 0 }, ;
    { "v4001_1", "N", 6, 0 }, ;
    { "v4001_2", "N", 6, 0 }, ;
    { "v4001_3", "N", 6, 0 }, ;
    { "v5000_1", "N", 6, 0 }, ;
    { "v5000_2", "N", 6, 0 }, ;
    { "v5000_3", "N", 6, 0 }, ;
    { "v5000_4", "N", 6, 0 }, ;
    { "v5100_1", "N", 6, 0 }, ;
    { "v5100_2", "N", 6, 0 }, ;
    { "period", "C", 100, 0 } }
  dbCreate( fr_titl, adbf )
  Use ( fr_titl ) New Alias FRT
  Append Blank

  //
  //
  r_use( dir_server + "kartote_",, "KART_" )
  r_use( dir_server + "kartotek",, "KART" )
  Set Relation To RecNo() into KART_
  r_use( dir_server + "uslugi",, "USL" )
  r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
  r_use( dir_server + "human_2",, "HUMAN_2" )
  kh := 0
  adbf := NIL
  If yes_rule  // "исправляем" в соответствии с правилами статистики
    bbuf := save_maxrow()
    mywait( "Ждите. Создаётся условный индексный файл..." )
    If pi1 == 1 // по дате окончания лечения
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human", dir_server + "humand", "HUMAN" )
      Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
      dbSeek( DToS( arr_m[ 5 ] ), .t. )
      Index On Str( kod_k, 7 ) + DToS( k_data ) to ( cur_dir + "tmp_h" ) ;
        While k_data <= arr_m[ 6 ] ;
        For kod > 0 .and. human_->usl_ok == 3 .and. human_->oplata < 9 ;
        .and. human_->NOVOR == 0 .and. func_pi_schet()
    Else
      r_use( dir_server + "schet",, "SCHET" )
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human",, "HUMAN" )
      Set Relation To schet into SCHET, To RecNo() into HUMAN_, To RecNo() into HUMAN_2
      Index On Str( kod_k, 7 ) + DToS( k_data ) to ( cur_dir + "tmp_h" ) ;
        For kod > 0 .and. schet > 0 .and. human_->usl_ok == 3 .and. human_->oplata < 9 ;
        .and. human_->NOVOR == 0 .and. Between( schet->pdate, arr_m[ 7 ], arr_m[ 8 ] ) ;
        progress
    Endif
    rest_box( bbuf )
    hGauge := gaugenew(,,, "Попытка исправления в соответствии с правилами", .t. )
    gaugedisplay( hGauge )
    If fl_12_selo
      blk_usl := {|| f_is_selo( kart_->gorod_selo, kart_->okatog ) .and. ;
        f_is_uch( st_a_uch, human->lpu ) .and. ;
        f_is_uchast( st_a_uchast, kart->uchast ) }
    Else
      blk_usl := {|| f_is_uch( st_a_uch, human->lpu ) .and. ;
        f_is_uchast( st_a_uchast, kart->uchast ) }
    Endif
    Select KART
    Go Top
    Do While !Eof()
      updatestatus()
      gaugeupdate( hGauge, RecNo() / LastRec() )
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If f1_prover_rule( blk_usl, ab, 12 )
        @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
        If jh > 0
          @ Row(), Col() Say "/" Color "W/R"
          @ Row(), Col() Say lstr( jh ) Color cColorStMsg
        Endif
        verify12rule( ab, kart->pol, yes_god )
        jh := f2_f12( jh, is_diag )
      Endif
      Select KART
      If RecNo() % 5000 == 0
        Commit
      Endif
      Skip
    Enddo
    closegauge( hGauge )
  Else  // не "исправляем" в соответствии с правилами статистики
    If pi1 == 1 // по дате окончания лечения
      begin_date := arr_m[ 5 ]
      end_date := arr_m[ 6 ]
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human", { dir_server + "humand", ;
        dir_server + "humank" }, "HUMAN" )
      Set Relation To kod_k into KART, To RecNo() into HUMAN_, To RecNo() into HUMAN_2
      dbSeek( DToS( begin_date ), .t. )
      Do While human->k_data <= end_date .and. !Eof()
        @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
        If jh > 0
          @ Row(), Col() Say "/" Color "W/R"
          @ Row(), Col() Say lstr( jh ) Color cColorStMsg
        Endif

        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human_->usl_ok == 3 .and. human_->oplata < 9 .and. ;
            iif( fl_12_selo, f_is_selo( kart_->gorod_selo, kart_->okatog ), .t. ) .and. ;
            func_pi_schet() .and. f_is_uch( st_a_uch, human->lpu ) .and. f_is_uchast( st_a_uchast, kart->uchast )
          date_24( human->k_data )
          jh := f1_f12( jh, is_diag )
        Endif
        Select HUMAN
        Skip
      Enddo
    Else
      begin_date := arr_m[ 7 ]
      end_date := arr_m[ 8 ]
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human", { dir_server + "humans", ;
        dir_server + "humank" }, "HUMAN" )
      Set Relation To kod_k into KART, To RecNo() into HUMAN_, To RecNo() into HUMAN_2
      r_use( dir_server + "schet_",, "SCHET_" )
      r_use( dir_server + "schet", dir_server + "schetd", "SCHET" )
      Set Relation To RecNo() into SCHET_
      Set Filter To Empty( schet_->IS_DOPLATA )
      dbSeek( begin_date, .t. )
      Do While schet->pdate <= end_date .and. !Eof()
        date_24( c4tod( schet->pdate ) )
        Select HUMAN
        find ( Str( schet->kod, 6 ) )
        Do While human->schet == schet->kod .and. !Eof()
          @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
          If human_->usl_ok == 3 .and. human_->oplata < 9 .and. ;
              iif( fl_12_selo, f_is_selo( kart_->gorod_selo, kart_->okatog ), .t. ) .and. ;
              f_is_uch( st_a_uch, human->lpu ) .and. f_is_uchast( st_a_uchast, kart->uchast )
            If jh > 0
              @ Row(), Col() Say "/" Color "W/R"
              @ Row(), Col() Say lstr( jh ) Color cColorStMsg
            Endif
            updatestatus()
            If Inkey() == K_ESC
              fl_exit := .t. ; Exit
            Endif
            jh := f1_f12( jh, is_diag )
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
  rest_box( buf )
  If fl_exit ; Return NIL ; Endif
  //
  mywait()
  reg_print := 6
  x := 1
  If is_100000
    arr_title := f12_100000_title()
  Else
    arr_title := f12_title()
  Endif
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server + "organiz",, "ORG" )
  add_string( AllTrim( org->name ) )
  add_string( AllTrim( org->adres ) )
  add_string( PadL( "Форма № 12", sh ) )
  add_string( PadL( "Утверждена", sh ) )
  add_string( PadL( "Приказом Росстата", sh ) )
  add_string( PadL( "от 22.11.2019г. № 679", sh ) )
  add_string( Center( "СВЕДЕНИЯ О ЧИСЛЕ ЗАБОЛЕВАНИЙ, ЗАРЕГИСТРИРОВАННЫХ У ПАЦИЕНТОВ,", sh ) )
  add_string( Center( "ПРОЖИВАЮЩИХ В РАЙОНЕ ОБСЛУЖИВАНИЯ МЕДИЦИНСКОЙ ОРГАНИЗАЦИИ", sh ) )
  add_string( Center( speriod, sh ) )
  add_string( Center( iif( fl_12_selo, "(по сельскому населению)", "" ), sh ) )
  titlen_uch( st_a_uch, sh, lcount_uch )
  title_uchast( st_a_uchast, sh )
  If pi1 == 1
    add_string( Center( str_pi_schet(), sh ) )
  Else
    add_string( Center( "[ по дате выписки счета ]", sh ) )
  Endif
  add_string()
  //
  Use ( fr_titl ) New Alias FRT
  frt->name := AllTrim( org->name )
  frt->adres := AllTrim( org->adres )
  frt->period := speriod
  If fl_12_selo
    frt->name1 := "(по сельскому населению)"
  Endif
  adbf := { ;
    { "name", "C", 250, 0 }, ;
    { "stroke", "C", 10, 0 }, ;
    { "diagnoz", "C", 40, 0 };
    }
  For i := 4 To 19
    AAdd( adbf, { "kol" + lstr( i ), "N", 8, 0 } )
  Next
  For i := 0 To 9
    name_f := fr_data + iif( i > 0, lstr( i ), "" )
    al := "FRD" + iif( i > 0, lstr( i ), "" )
    dbCreate( cur_dir + name_f, adbf )
    e_use( cur_dir + name_f,, al )
  Next
  If is_diag
    r_use( dir_exe() + "_mo_mkb", cur_dir + "_mo_mkb", "MKB10" )
    Use ( cur_dir + "tmp_dia" ) New Alias TMP_D
    Index On stroke + Str( tip, 1 ) + Str( voz, 1 ) + diagnoz to ( cur_dir + "tmp_dia" )
  Endif
  Use ( cur_dir + "tmp_tab" ) index ( cur_dir + "tmp_tab" ) New Alias TMP
  For x := 1 To 5 // diag1[x] => {s1,p_tip,diapazon,tmp->table,s2,s4}
    If !p_is_voz[ x ] ; loop ; Endif
    If is_100000
      arr_title := f12_100000_title()
    Else
      arr_title := f12_title()
    Endif
    sh := sh1 := Len( arr_title[ 1 ] )
    name1 := { "Дети (0-14 лет включительно)", ;
      "Дети первых трех лет жизни", ;
      "Дети (15-17 лет включительно)", ;
      "Взрослые 18 лет и более", ;
      "Взрослые старше трудоспособного возраста (с 55 лет у женщин и с 60 лет у мужчин)" }[ x ]
    If x > 1
      add_string( Chr( 12 ) ) ; tek_stroke := 0 ; n_list++
      next_list( sh )
    Endif
    add_string( Center( lstr( x ) + ". " + name1, sh ) )
    add_string( " (" + lstr( diag1[ x, 1, 4 ] ) + ")" + PadL( "Код по ОКЕИ: человек - 792", sh - 8 ) )
    AEval( arr_title, {| x| add_string( x ) } )
    v := x
    al := "FRD" + iif( x > 1, lstr( Int( x * 2 -2 ) ), "" )
    // diag1[x] => {s1,p_tip,diapazon,tmp->table,s2,s4}
    For ix := 1 To Len( diag1[ x ] )
      s1 := PadR( diag1[ x, ix, 1 ], 8 ) ; s1_ := diag1[ x, ix, 1 ]
      p_tip := diag1[ x, ix, 2 ]
      If p_tip == 2 .and. v == x
        v := 0
        If !is_100000
          If is_diag
            add_string( Replicate( "-", sh1 ) )
          Else
            f_bot_f12( x, HH, sh )
          Endif
          ASize( arr_title, 6 )
          arr_title[ 1 ] := Left( arr_title[ 1 ], len_name[ x ] + 22 ) + "┬───────────────────"
          arr_title[ 2 ] := Left( arr_title[ 2 ], len_name[ x ] + 22 ) + "│     Обращения     "
          arr_title[ 3 ] := Left( arr_title[ 3 ], len_name[ x ] + 22 ) + "├─────────┬─────────"
          arr_title[ 4 ] := Left( arr_title[ 4 ], len_name[ x ] + 22 ) + "│         │ из них  "
          arr_title[ 5 ] := Left( arr_title[ 5 ], len_name[ x ] + 22 ) + "│  всего  │повторные"
          arr_title[ 6 ] := Left( arr_title[ 6 ], len_name[ x ] + 22 ) + "┴─────────┴─────────"
          sh1 := Len( arr_title[ 1 ] )
          If !verify_ff( HH - 13, .t., sh )
            add_string( "" )
          Endif
          add_string( Center( name1, sh1 ) )
          add_string( Center( "Факторы, влияющие на состояние здоровья населения и обращения", sh1 ) )
          add_string( Center( "в медиицнские организации (с профилактической и иными целями)", sh1 ) )
          add_string( "" )
          add_string( " (" + lstr( diag1[ x, ix, 4 ] ) + ")" + PadL( "Код по ОКЕИ: единица - 642", sh1 - 8 ) )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        al := "FRD" + lstr( Int( x * 2 -1 ) )
        --ix
      Elseif iif( is_diag, ( Right( s1_, 2 ) == ".0" ), .t. )
        If is_100000 .and. p_tip == 2
          ft_skip()
          Loop
        Endif
        s2 := diag1[ x, ix, 5 ] // строка диагнозов
        s3 := diag1[ x, ix, 6 ] // наименование
        Select TMP
        find ( s1 + Str( p_tip, 1 ) + Str( x, 1 ) )
        If Found() .and. iif( is_diag, ( tmp->sluch + tmp->dispans > 0 ), .t. )
          t_arr1 := {} ; t_arr2 := Array( 12 )
          j1 := perenos( t_arr1, CharRepl( eos, s3, "  " ), len_name[ x ] )
          j2 := perenos( t_arr2, s2, 12, ", ;" )
          For i := j1 + 1 To j2
            ++j1 ; AAdd( t_arr1, "" )
          Next
          Select TMP
          find ( s1 + Str( p_tip, 1 ) + Str( x, 1 ) )
          ls1 := PadR( t_arr1[ 1 ], len_name[ x ] ) + ;
            PadC( AllTrim( s1 ), 10 ) + ;
            PadC( AllTrim( t_arr2[ 1 ] ), 12 )
          dbSelectArea( al )
          Append Blank
          &al.->name := s3
          &al.->stroke := s1
          &al.->diagnoz := s2
          If is_100000
            ls1 += put_val( tmp->sluch, 7 ) + ;
              put_val( tmp->sluch7, 7 )
            ls1 += put_val( tmp->sluch * koef_dt[ x ], 7 ) + ;
              put_val( tmp->sluch7 * koef_dt[ x ], 7 )
            If !emptyany( tmp->sluch7, tmp->sluch )
              ls1 += umest_val( tmp->sluch7 / tmp->sluch * 100, 7, 2 )
            Endif
          Else
            k15 := tmp->sluch6 - tmp->sluch12
            If ( k16 := tmp->sluch14 ) > k15
              k16 := k15
              If tmp->sluch > tmp->sluch5 .and. k16 > 0
                --k16
              Endif
            Endif
            If p_tip == 2
              &al.->kol4  := tmp->sluch
              &al.->kol5  := tmp->sluch5
              ls1 += put_val( tmp->sluch, 8 )
            Elseif x == 1
              &al.->kol4  := tmp->sluch
              &al.->kol5  := tmp->sluch11
              &al.->kol6  := tmp->sluch14
              &al.->kol8  := tmp->sluch6
              &al.->kol9  := tmp->sluch7
              &al.->kol10 := tmp->sluch8
              &al.->kol11 := tmp->sluch9
              &al.->kol14 := tmp->sluch12
              &al.->kol15 := k15
              ls1 += put_val( tmp->sluch, 8 ) + ;
                put_val( tmp->sluch11, 7 ) + ;
                put_val( tmp->sluch14, 7 ) + ;
                put_val( tmp->sluch6, 7 ) + ;
                put_val( tmp->sluch7, 7 ) + ;
                put_val( tmp->sluch8, 7 ) + ;
                put_val( tmp->sluch9, 7 ) + ;
                put_val( tmp->sluch12, 6 ) + ;
                put_val( k15, 6 )
            Elseif x == 2
              &al.->kol4  := tmp->sluch
              &al.->kol5  := tmp->sluch24
              &al.->kol6  := tmp->sluch25
              &al.->kol7  := tmp->sluch5
              &al.->kol8  := tmp->sluch6
              &al.->kol9  := tmp->sluch16
              &al.->kol10 := tmp->sluch7
              &al.->kol11 := tmp->sluch17
              &al.->kol12 := tmp->sluch8
              &al.->kol13 := tmp->sluch18
              &al.->kol14 := tmp->sluch9
              &al.->kol15 := tmp->sluch19
              &al.->kol16 := tmp->sluch12
              &al.->kol17 := tmp->sluch22
              &al.->kol18 := tmp->sluch6 - tmp->sluch12
              &al.->kol19 := tmp->sluch16 - tmp->sluch22
              ls1 += put_val( tmp->sluch, 8 ) + ;
                put_val( tmp->sluch5, 7 ) + ;
                put_val( tmp->sluch6, 7 ) + ;
                put_val( tmp->sluch7, 7 ) + ;
                put_val( tmp->sluch8, 7 ) + ;
                put_val( tmp->sluch9, 7 ) + ;
                put_val( tmp->sluch12, 6 ) + ;
                put_val( k15, 6 )
            Elseif x == 3
              &al.->kol4  := tmp->sluch
              &al.->kol7  := tmp->sluch5
              &al.->kol8  := tmp->sluch6
              &al.->kol9  := tmp->sluch7
              &al.->kol10 := tmp->sluch8
              &al.->kol11 := tmp->sluch9
              &al.->kol12 := tmp->sluch10
              &al.->kol13 := tmp->sluch11
              &al.->kol14 := tmp->sluch12
              &al.->kol15 := k15
              &al.->kol16 := k16
              ls1 += put_val( tmp->sluch, 6 ) + ;
                put_val( tmp->sluch5, 6 ) + ;
                put_val( tmp->sluch6, 5 ) + ;
                put_val( tmp->sluch7, 5 ) + ;
                put_val( tmp->sluch8, 5 ) + ;
                put_val( tmp->sluch9, 5 ) + ;
                put_val( tmp->sluch10, 3 ) + ;
                put_val( tmp->sluch11, 5 ) + ;
                put_val( tmp->sluch12, 5 ) + ;
                put_val( k15, 5 ) + ;
                put_val( k16, 5 )
            Else
              &al.->kol4  := tmp->sluch
              &al.->kol8  := tmp->sluch6
              &al.->kol9  := tmp->sluch7
              &al.->kol10 := tmp->sluch8
              &al.->kol11 := tmp->sluch9
              &al.->kol12 := tmp->sluch10
              &al.->kol14 := tmp->sluch12
              &al.->kol15 := k15
              ls1 += put_val( tmp->sluch, 8 ) + ;
                put_val( tmp->sluch6, 7 ) + ;
                put_val( tmp->sluch7, 7 ) + ;
                put_val( tmp->sluch8, 7 ) + ;
                put_val( tmp->sluch9, 7 ) + ;
                put_val( tmp->sluch10, 7 ) + ;
                put_val( tmp->sluch12, 6 ) + ;
                put_val( k15, 6 )
            Endif
          Endif
          If verify_ff( HH - Max( j1, j2 ), .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          If is_diag .and. !( s1_ == "1.0" )
            add_string( Replicate( "-", sh1 ) )
          Endif
          add_string( ls1 )
          For i := 2 To Max( j1, j2 )
            ls2 := PadR( t_arr1[ i ], len_name[ x ] ) + ;
              Space( 10 ) + ;
              PadC( AllTrim( t_arr2[ i ] ), 12 )
            add_string( ls2 )
          Next
          If iif( is_diag, !( s1_ == "1.0" .and. p_tip == 1 ), .t. )
            add_string( Replicate( "-", sh1 ) )
          Endif
          If is_diag
            Select TMP_D
            find ( s1 + Str( p_tip, 1 ) + Str( x, 1 ) )
            Do While tmp_d->stroke == s1 .and. tmp_d->tip == p_tip .and. tmp_d->voz == x .and. !Eof()
              Select MKB10
              find ( tmp_d->diagnoz )
              s := AllTrim( mkb10->name ) + " "
              Skip
              Do While Left( mkb10->shifr, 5 ) == tmp_d->diagnoz .and. mkb10->ks > 0 .and. !Eof()
                s += AllTrim( mkb10->name ) + " "
                Skip
              Enddo
              j1 := perenos( t_arr1, s, len_name[ x ] + 10 )
              If verify_ff( HH - j1, .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              dbSelectArea( al )
              Append Blank
              &al.->name := s
              &al.->diagnoz := tmp_d->diagnoz
              ls1 := PadR( t_arr1[ 1 ], len_name[ x ] + 10 ) + ;
                PadC( AllTrim( tmp_d->diagnoz ), 12 )
              k15 := tmp_d->sluch6 - tmp_d->sluch12
              If ( k16 := tmp_d->sluch14 ) > k15
                k16 := k15
                If tmp_d->sluch > tmp_d->sluch5 .and. k16 > 0
                  --k16
                Endif
              Endif
              If p_tip == 2
                &al.->kol4  := tmp_d->sluch
                &al.->kol5  := tmp_d->sluch5
                ls1 += put_val( tmp_d->sluch, 8 )
              Elseif x == 1
                &al.->kol4  := tmp_d->sluch
                &al.->kol5  := tmp_d->sluch11
                &al.->kol6  := tmp_d->sluch14
                &al.->kol8  := tmp_d->sluch6
                &al.->kol9  := tmp_d->sluch7
                &al.->kol10 := tmp_d->sluch8
                &al.->kol11 := tmp_d->sluch9
                &al.->kol14 := tmp_d->sluch12
                &al.->kol15 := k15
                ls1 += put_val( tmp_d->sluch, 8 ) + ;
                  put_val( tmp_d->sluch11, 7 ) + ;
                  put_val( tmp_d->sluch14, 7 ) + ;
                  put_val( tmp_d->sluch6, 7 ) + ;
                  put_val( tmp_d->sluch7, 7 ) + ;
                  put_val( tmp_d->sluch8, 7 ) + ;
                  put_val( tmp_d->sluch9, 7 ) + ;
                  put_val( tmp_d->sluch12, 6 ) + ;
                  put_val( k15, 6 )
              Elseif x == 2
                &al.->kol4  := tmp_d->sluch
                &al.->kol5  := tmp_d->sluch24
                &al.->kol6  := tmp_d->sluch25
                &al.->kol7  := tmp_d->sluch5
                &al.->kol8  := tmp_d->sluch6
                &al.->kol9  := tmp_d->sluch16
                &al.->kol10 := tmp_d->sluch7
                &al.->kol11 := tmp_d->sluch17
                &al.->kol12 := tmp_d->sluch8
                &al.->kol13 := tmp_d->sluch18
                &al.->kol14 := tmp_d->sluch9
                &al.->kol15 := tmp_d->sluch19
                &al.->kol16 := tmp_d->sluch12
                &al.->kol17 := tmp_d->sluch22
                &al.->kol18 := tmp_d->sluch6 - tmp_d->sluch12
                &al.->kol19 := tmp_d->sluch16 - tmp_d->sluch22
                ls1 += put_val( tmp_d->sluch, 8 ) + ;
                  put_val( tmp_d->sluch5, 7 ) + ;
                  put_val( tmp_d->sluch6, 7 ) + ;
                  put_val( tmp_d->sluch7, 7 ) + ;
                  put_val( tmp_d->sluch8, 7 ) + ;
                  put_val( tmp_d->sluch9, 7 ) + ;
                  put_val( tmp_d->sluch12, 6 ) + ;
                  put_val( k15, 6 )
              Elseif x == 3
                &al.->kol4  := tmp_d->sluch
                &al.->kol7  := tmp_d->sluch5
                &al.->kol8  := tmp_d->sluch6
                &al.->kol9  := tmp_d->sluch7
                &al.->kol10 := tmp_d->sluch8
                &al.->kol11 := tmp_d->sluch9
                &al.->kol12 := tmp_d->sluch10
                &al.->kol13 := tmp_d->sluch11
                &al.->kol14 := tmp_d->sluch12
                &al.->kol15 := k15
                &al.->kol16 := k16
                ls1 += put_val( tmp_d->sluch, 6 ) + ;
                  put_val( tmp_d->sluch5, 6 ) + ;
                  put_val( tmp_d->sluch6, 5 ) + ;
                  put_val( tmp_d->sluch7, 5 ) + ;
                  put_val( tmp_d->sluch8, 5 ) + ;
                  put_val( tmp_d->sluch9, 5 ) + ;
                  put_val( tmp_d->sluch10, 3 ) + ;
                  put_val( tmp_d->sluch11, 5 ) + ;
                  put_val( tmp_d->sluch12, 5 ) + ;
                  put_val( k15, 5 ) + ;
                  put_val( k16, 5 )
              Else
                &al.->kol4  := tmp_d->sluch
                &al.->kol8  := tmp_d->sluch6
                &al.->kol9  := tmp_d->sluch7
                &al.->kol10 := tmp_d->sluch8
                &al.->kol11 := tmp_d->sluch9
                &al.->kol12 := tmp_d->sluch10
                &al.->kol14 := tmp_d->sluch12
                &al.->kol15 := k15
                ls1 += put_val( tmp_d->sluch, 8 ) + ;
                  put_val( tmp_d->sluch6, 7 ) + ;
                  put_val( tmp_d->sluch7, 7 ) + ;
                  put_val( tmp_d->sluch8, 7 ) + ;
                  put_val( tmp_d->sluch9, 7 ) + ;
                  put_val( tmp_d->sluch10, 7 ) + ;
                  put_val( tmp_d->sluch12, 6 ) + ;
                  put_val( k15, 6 )
              Endif
              add_string( ls1 )
              For i := 2 To j1
                add_string( PadL( AllTrim( t_arr1[ i ] ), len_name[ x ] + 10 ) )
              Next
              Select TMP_D
              Skip
            Enddo
          Endif
        Endif
      Endif
    Next
  Next
  FClose( fp )
  Close databases
  rest_box( buf )
  If is_100000
    viewtext( name_file,,,, .t.,,, reg_print )
  Else
    call_fr( "mo_forma12" )
  Endif

  Return Nil

// 11.12.16
Function f_bot_f12( x, HH, sh )

  Local v1 := 0, v2 := 0, v3 := 0, v4 := 0, v5 := 0, v6 := 0

  Use ( cur_dir + "TMP_KART" ) new
  If x == 1
    Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_kart" ) For voz < 3 // т.к. дети и новорожденные считались отдельно
  Elseif x == 4
    Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_kart" ) For voz > 3 // т.к. взрослые и пенсионеры считались отдельно
  Else
    Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_kart" ) For voz == x
  Endif
  Go Top
  Do While !Eof()
    ++v1
    If perv > 0
      ++v2
    Endif
    If disp > 0
      ++v3
      If let < 5
        ++v5
      Elseif let < 10
        ++v6
      Elseif let == 18
        ++v4
      Endif
    Endif
    Skip
  Enddo
  Use
  verify_ff( HH - 3, .t., sh )
  add_string( "(" + lstr( diag1[ x, 1, 4 ] + 1 ) + ") Число физических лиц зарегистрированных пациентов - всего 1(___" + lstr( v1 ) + "___)," )
  add_string( Space( 7 ) + "из них с диагнозом, установленным впервые в жизни 2(___" + lstr( v2 ) + "___)," )
  add_string( Space( 7 ) + "состоит под диспансерным наблюдением на конец отчетного года (из гр.13, стр.1.0) 3(___" + lstr( v3 ) + "___)." )
  Do Case
  Case x == 1
    frt->v1001_1 := v1
    frt->v1001_2 := v2
    frt->v1001_3 := v3
    frt->v1002_1 := v5
    frt->v1002_2 := v6
  Case x == 2
    frt->v1700_1 := v1
  Case x == 3
    frt->v2001_1 := v1
    frt->v2001_2 := v2
    frt->v2001_3 := v3
    frt->v2001_4 := v4
  Case x == 4
    frt->v3002_1 := v1
    frt->v3002_2 := v2
    frt->v3002_3 := v3
  Case x == 5
    frt->v4001_1 := v1
    frt->v4001_2 := v2
    frt->v4001_3 := v3
  Endcase

  Return Nil

// 03.01.16
Function f12_title()

  Local arr := Array( 8 )

  arr[ 1 ] := Replicate( "─", len_name[ x ] )
  arr[ 2 ] := PadC( "", len_name[ x ] )
  arr[ 3 ] := PadC( "Наименование классов и", len_name[ x ] )
  arr[ 4 ] := PadC( "отдельных болезней", len_name[ x ] )
  arr[ 5 ] := PadC( "", len_name[ x ] )
  arr[ 6 ] := Replicate( "─", len_name[ x ] )
  arr[ 7 ] := PadC( "1", len_name[ x ] )
  arr[ 8 ] := Replicate( "─", len_name[ x ] )
  arr[ 1 ] := arr[ 1 ] + "┬────────┬────────────"
  arr[ 2 ] := arr[ 2 ] + "│        │   Код по   "
  arr[ 3 ] := arr[ 3 ] + "│   №    │   МКБ-10   "
  arr[ 4 ] := arr[ 4 ] + "│ строки │ пересмотра "
  arr[ 5 ] := arr[ 5 ] + "│        │            "
  arr[ 6 ] := arr[ 6 ] + "┼────────┼────────────"
  arr[ 7 ] := arr[ 7 ] + "│   2    │     3      "
  arr[ 8 ] := arr[ 8 ] + "┴────────┴────────────"
  If x == 1
    arr[ 1 ] := arr[ 1 ] + "┬─────────────────────────────────────────────────┬─────┬─────"
    arr[ 2 ] := arr[ 2 ] + "│          Зарегистрировано заболеваний           │Снято│Состо"
    arr[ 3 ] := arr[ 3 ] + "├───────┬──────┬──────┬─из графы 4──┬──из графы 7─┤сДисп│итПод"
    arr[ 4 ] := arr[ 4 ] + "│ всего │  0-4 │  5-9 │взято │впервы│взято │Проф. │наблю│Дисп."
    arr[ 5 ] := arr[ 5 ] + "│       │ года │  лет │наДисп│Диагно│наДисп│осмотр│дения│набл."
    arr[ 6 ] := arr[ 6 ] + "┼───────┼──────┼──────┼──────┼──────┼──────┼──────┼─────┼─────"
    arr[ 7 ] := arr[ 7 ] + "│   4   │   5  │   6  │  8   │  9   │  10  │  11  │ 14  │ 15  "
    arr[ 8 ] := arr[ 8 ] + "┴───────┴──────┴──────┴──────┴──────┴──────┴──────┴─────┴─────"
  Elseif x == 2
    arr[ 1 ] := arr[ 1 ] + "┬──────────────────────────────────────────┬─────┬─────"
    arr[ 2 ] := arr[ 2 ] + "│       Зарегистрировано заболеваний       │Снято│Состо"
    arr[ 3 ] := arr[ 3 ] + "├───────┬──────┬─из графы 4──┬──из графы 7─┤сДисп│итПод"
    arr[ 4 ] := arr[ 4 ] + "│ всего │до 1  │взято │впервы│взято │Проф. │наблю│Дисп."
    arr[ 5 ] := arr[ 5 ] + "│       │месяца│наДисп│Диагно│наДисп│осмотр│дения│набл."
    arr[ 6 ] := arr[ 6 ] + "┼───────┼──────┼──────┼──────┼──────┼──────┼─────┼─────"
    arr[ 7 ] := arr[ 7 ] + "│   4   │  5   │  8   │  9   │  10  │  11  │ 14  │ 15  "
    arr[ 8 ] := arr[ 8 ] + "┴───────┴──────┴──────┴──────┴──────┴──────┴─────┴─────"
  Elseif x == 3
    arr[ 1 ] := arr[ 1 ] + "┬───────────────────────────────────────┬────┬────┬────"
    arr[ 2 ] := arr[ 2 ] + "│     Зарегистрировано заболеваний      │Снят│Сост│Из  "
    arr[ 3 ] := arr[ 3 ] + "├─────┬─────┬─из гр.4─┬─из графы 7─┬────┤сДис│оит │граф"
    arr[ 4 ] := arr[ 4 ] + "│всего│изНих│взят│впер│на  │Проф│Ди│изГ8│набл│подД│ 13 "
    arr[ 5 ] := arr[ 5 ] + "│     │юноши│наДи│вые │Дисп│осмо│Вз│юнош│юден│набл│юнош"
    arr[ 6 ] := arr[ 6 ] + "┼─────┼─────┼────┼────┼────┼────┼──┼────┼────┼────┼────"
    arr[ 7 ] := arr[ 7 ] + "│  4  │  7  │  8 │  9 │ 10 │ 11 │12│ 13 │ 14 │ 15 │ 16 "
    arr[ 8 ] := arr[ 8 ] + "┴─────┴─────┴────┴────┴────┴────┴──┴────┴────┴────┴────"
  Else
    arr[ 1 ] := arr[ 1 ] + "┬──────────────────────────────────────────┬─────┬─────"
    arr[ 2 ] := arr[ 2 ] + "│        Зарегистрировано заболеваний      │Снято│Состо"
    arr[ 3 ] := arr[ 3 ] + "├───────┬─из графы 4──┬─────из графы 7─────┤сДисп│итПод"
    arr[ 4 ] := arr[ 4 ] + "│ всего │взято │впервы│взято │Проф. │Диспан│наблю│Дисп."
    arr[ 5 ] := arr[ 5 ] + "│       │наДисп│Диагно│наДисп│осмотр│ВзрНас│дения│набл."
    arr[ 6 ] := arr[ 6 ] + "┼───────┼──────┼──────┼──────┼──────┼──────┼─────┼─────"
    arr[ 7 ] := arr[ 7 ] + "│   4   │  8   │  9   │  10  │  11  │  12  │ 14  │ 15  "
    arr[ 8 ] := arr[ 8 ] + "┴───────┴──────┴──────┴──────┴──────┴──────┴─────┴─────"
  Endif

  Return arr

//
Function f12_100000_title()

  Local arr := Array( 6 )

  arr[ 1 ] := Replicate( "─", len_name[ x ] )
  arr[ 2 ] := PadC( "", len_name[ x ] )
  arr[ 3 ] := PadC( "Наименование классов и", len_name[ x ] )
  arr[ 4 ] := PadC( "отдельных болезней", len_name[ x ] )
  arr[ 5 ] := PadC( "", len_name[ x ] )
  arr[ 6 ] := Replicate( "─", len_name[ x ] )
  arr[ 1 ] := arr[ 1 ] + '┬────────┬────────────┬─────────────┬─────────────┬──────'
  arr[ 2 ] := arr[ 2 ] + '│        │   Код по   │Зарегистриров│  на 100000  │Часто-'
  arr[ 3 ] := arr[ 3 ] + '│   №    │   МКБ-10   ├──────┬──────┼──────┬──────┤та вы-'
  arr[ 4 ] := arr[ 4 ] + '│ строки │ пересмотра │всего │в т.ч.│всего │в т.ч.│явле- '
  arr[ 5 ] := arr[ 5 ] + '│        │            │      │с "+" │      │с "+" │ния % '
  arr[ 6 ] := arr[ 6 ] + '┴────────┴────────────┴──────┴──────┴──────┴──────┴──────'

  Return arr

// 13.12.16 возврат массива диагнозов для формы 12 из дисп-ии взрослого населения
Function ret_f12_dvn( Loc_kod, par )

  Local rec, rec2 := 0, lkod_k, ldate, lyear, arr := {}, i, j, k, s, is_student, is_1 := .f., is_disp := .f.

  rec := human->( RecNo() )
  is_student := ( human->RAB_NERAB == 2 )
  If par == 1 .and. human->ishod == 201
    rec := human->( RecNo() )
    lyear := Year( human->k_data )
    lkod_k := human->kod_k
    Select HUMAN
    Set Order To 2
    find ( Str( lkod_k, 7 ) )
    Do While lkod_k == human->kod_k .and. !Eof()
      If human->ishod == 202 .and. lyear == Year( human->k_data ) .and. human_->oplata < 9
        rec2 := human->( RecNo() ) ; Exit
      Endif
      Skip
    Enddo
    Set Order To 1
    Goto ( rec )
  Endif
  Select HUMAN
  If rec2 > 0
    Goto ( rec2 )
  Endif
  Private pole_diag, pole_1pervich, pole_1dispans
  For i := 1 To 5
    pole_diag := "mdiag" + lstr( i )
    pole_1pervich := "m1pervich" + lstr( i )
    pole_1dispans := "m1dispans" + lstr( i )
    Private &pole_diag := Space( 6 )
    Private &pole_1pervich := 0
    Private &pole_1dispans := 0
  Next
  read_arr_dvn( human->( RecNo() ) )
  For i := 1 To 5
    pole_diag := "mdiag" + lstr( i )
    pole_1pervich := "m1pervich" + lstr( i )
    pole_1dispans := "m1dispans" + lstr( i )
    If !Empty( &pole_diag ) .and. !( Left( &pole_diag, 1 ) == "Z" )
      if &pole_1pervich < 2 // впервые и ранее выявленный
        if &pole_1pervich == 1 // впервые
          is_1 := .t.
        Else // ранее выявленный
          &pole_1pervich := 2
        Endif
        if &pole_1dispans == 1
          if &pole_1pervich == 1 // впервые
            is_disp := .t.
            &pole_1dispans := 2
          Else // ранее выявленный
            &pole_1dispans := 1
          Endif
        Endif
        AAdd( arr, { &pole_diag, &pole_1pervich, &pole_1dispans } )
      Endif
    Endif
  Next
  If rec2 > 0
    Goto ( rec )
  Endif
  If is_student .and. Select( "frt" ) > 0
    frt->v5000_1++
    frt->v5000_2++
    If is_1
      frt->v5000_3++
      If is_disp
        frt->v5000_4++
      Endif
    Endif
  Endif

  Return arr

// 12.12.16 возврат массива диагнозов для формы 12 из профосмотров несовершеннолетних и дисп-ии детей-сирот
Function ret_f12_pn( Loc_kod, par )

  Local arr, ad := {}, i, j, k, s, lshifr

  For i := 1 To 5
    For k := 1 To 16
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := "m1" + s
        Private &m1var := 0
        Private &mvar := Space( 3 )
      Endif
    Next
  Next
  If par == 1
    read_arr_dds( Loc_kod )
  Else
    For i := 1 To count_pn_arr_iss // исследования
      mvar := "MREZi" + lstr( i )
      Private &mvar := Space( 17 )
    Next
    read_arr_pn( Loc_kod )
    If Select( "frt" ) > 0
      Select HU
      find ( Str( Loc_kod, 7 ) )
      Do While hu->kod == Loc_kod .and. !Eof()
        usl->( dbGoto( hu->u_kod ) )
        If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
          lshifr := usl->shifr
        Endif
        lshifr := AllTrim( lshifr )
        For i := 1 To count_pn_arr_iss // исследования
          If np_arr_issled[ i, 1 ] == lshifr
            If lshifr == "3.5.4"  // "Аудиологический скрининг"
              frt->v1800_1++
              mvar := "MREZi" + lstr( i )
              If !Empty( &mvar )
                frt->v1800_2++
              Endif
            Elseif lshifr == "4.26.1" // "Неонатальный скрининг на гипотиреоз"
              frt->v1900_6++
            Elseif lshifr == "4.26.2" // "Неонатальный скрининг на фенилкетонурию"
              frt->v1900_5++
            Elseif lshifr == "4.26.3" // "Неонатальный скрининг на адреногенитальный синдром"
              frt->v1900_7++
            Elseif lshifr == "4.26.4" // "Неонатальный скрининг на муковисцидоз"
              frt->v1900_9++
            Elseif lshifr == "4.26.5" // "Неонатальный скрининг на галактоземию"
              frt->v1900_8++
            Endif
          Endif
        Next
        Select HU
        Skip
      Enddo
    Endif
  Endif
  For i := 1 To 5
    j := 0
    For k := 1 To 3
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        If !Empty( &mvar ) .and. !( Left( &mvar, 1 ) == "Z" )
          arr := Array( 3 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := "m1" + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  arr := {}
  For i := 1 To Len( ad ) // цикл по диагнозам
    AAdd( arr, { ad[ i, 1 ], iif( ad[ i, 2 ] == 0, 2, 1 ), ad[ i, 3 ] } )
    // ad[i,2] = 1 - уст.впервые, 2 - повторно
    // ad[i,3] = 1 - состоит, 2 - взят
  Next

  Return arr

// 16.01.20
Function f1_f12( jh, is_diag )

  Local arr_d := {}, is_talon := .t., arr := {}, i, j, k, m, k4, k1, s, v, v4 := 0, ;
    mvozrast, fl, fl_plus, _dispans, kol_sluch, kol_plus, fl_z, mpol, lnum_kol := 0
  Private spec_vozrast := 0, spec1vozrast := 0, mlet := 0

  If human_->NOVOR > 0
    mpol := human_->POL2
    mvozrast := count_years( human_->DATE_R2, human->n_data )
  Else
    mpol := human->pol
    mvozrast := count_years( human->date_r, human->n_data )
    mlet := Year( human->n_data ) - Year( human->date_r )
  Endif
  If mvozrast < 5
    spec_vozrast := 2
    If mvozrast == 0
      m := 0
      If human_->NOVOR > 0
        count_ymd( human_->DATE_R2, human->n_data,, @m, )
      Else
        count_ymd( human->DATE_R, human->n_data,, @m, )
      Endif
      If m == 0
        spec_vozrast := 1  // до месяца
      Endif
    Endif
    If mvozrast < 1
      spec1vozrast := 1
    Elseif mvozrast < 4
      spec1vozrast := 2
    Endif
  Elseif mvozrast < 10
    spec_vozrast := 3
  Endif

  v := ret_v_f12( mpol, mvozrast, @v4 )

  If eq_any( human->ishod, 101, 102, 201, 202, 203, 204, 205, 301, 302 )

    If eq_any( human->ishod, 101, 102 )
      arr := ret_f12_pn( human->kod, 1 )
      lnum_kol := 9 // профосмотр
    Elseif eq_any( human->ishod, 201, 203, 204 )
      arr := ret_f12_dvn( human->kod, 1 )
      lnum_kol := iif( human->ishod == 203, 9, 10 ) // профосмотр или диспансеризация
    Elseif eq_any( human->ishod, 301, 302 )
      arr := ret_f12_pn( human->kod, 2 )
      lnum_kol := 9 // профосмотр
    Endif
    If Empty( arr ) .and. eq_any( human->ishod, 202, 205 )
      AAdd( arr, { human->KOD_DIAG, 0, 0 } )
    Endif
    For i := 1 To Len( arr )
      arr[ i, 1 ] := PadR( arr[ i, 1 ], 5 )
      If !Empty( arr[ i, 1 ] ) .and. AScan( arr_d, arr[ i, 1 ] ) == 0 .and. ( k := ret_f_12( v, arr[ i, 1 ] ) ) != NIL
        fl := fl_plus := .f.
        _dispans := arr[ i, 3 ]
        If arr[ i, 2 ] > 0
          fl := .t.
          fl_plus := ( arr[ i, 2 ] == 1 )
        Endif
        fl_z := .f.
        If !fl .and. Left( arr[ i, 1 ], 1 ) == "Z"
          fl := fl_z := .t.
        Endif
        If fl
          kol_sluch := iif( fl, 1, 0 )
          kol_plus := iif( fl_plus, 1, 0 )
          AAdd( arr_d, arr[ i, 1 ] )
          p_is_voz[ v ] := .t.
          s_f1_f12( is_diag, arr[ i, 1 ], k, v, mpol, kol_sluch, kol_plus, _dispans, lnum_kol )
          If v4 > 0 .and. ( k4 := ret_f_12( v4, arr[ i, 1 ] ) ) != NIL
            p_is_voz[ v4 ] := .t.
            s_f1_f12( is_diag, arr[ i, 1 ], k4, v4, mpol, kol_sluch, kol_plus, _dispans, lnum_kol )
          Endif
          If !fl_z
            f12_kod_k( human->kod_k, v, v4, kol_plus, _dispans )
          Endif
        Endif
      Endif
    Next
  Else
    AFill( adiag_talon, 0 )
    For i := 1 To 16
      adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
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
      arr[ i ] := PadR( arr[ i ], 5 )
      If !Empty( arr[ i ] ) .and. AScan( arr_d, arr[ i ] ) == 0 .and. ( k := ret_f_12( v, arr[ i ] ) ) != NIL
        fl := fl_plus := .f. ; _dispans := 0
        s := SubStr( human->diag_plus, i, 1 )
        If eq_any( s, "+", "-" )  // старая форма
          fl := .t.
          fl_plus := ( s == "+" )
        Elseif is_talon
          s := adiag_talon[ i * 2 -1 ]
          fl := eq_any( s, 1, 2 )
          fl_plus := ( s == 1 )
        Endif
        If is_talon
          k1 := adiag_talon[ i * 2 ]
          If Between( k1, 1, 3 )
            _dispans := k1
          Endif
          If !fl .and. _dispans > 0  // если не определен характер заболевания,
            fl_plus := ( _dispans == 2 )   // то определяем его принудительно
            fl := .t.
          Endif
        Endif
        fl_z := .f.
        If !fl .and. Left( arr[ i ], 1 ) == "Z"
          fl := fl_z := .t.
        Endif
        If fl
          kol_sluch := iif( fl, 1, 0 )
          kol_plus := iif( fl_plus, 1, 0 )
          AAdd( arr_d, arr[ i ] )
          p_is_voz[ v ] := .t.
          s_f1_f12( is_diag, arr[ i ], k, v, mpol, kol_sluch, kol_plus, _dispans )
          If v4 > 0 .and. ( k4 := ret_f_12( v4, arr[ i ] ) ) != NIL
            p_is_voz[ v4 ] := .t.
            s_f1_f12( is_diag, arr[ i ], k4, v4, mpol, kol_sluch, kol_plus, _dispans )
          Endif
          If !fl_z
            f12_kod_k( human->kod_k, v, v4, kol_plus, _dispans )
          Endif
        Endif
      Endif
    Next
  Endif
  If Len( arr_d ) > 0
    ++jh
  Endif

  Return jh

// 14.01.20
Function s_f1_f12( is_diag, lshifr, k, v, lpol, kol_sluch, kol_plus, _dispans, lnom_kol )

  Local j, n
  Private pole

  Default lnom_kol To 0
  For j := 1 To Len( k )
    Select TMP_TAB
    find ( PadR( k[ j, 1 ], 8 ) + Str( k[ j, 2 ], 1 ) + Str( v, 1 ) )
    tmp_tab->sluch += kol_sluch
    tmp_tab->sluch7 += kol_plus
    If eq_any( _dispans, 1, 2 ) // Состоит, Взят
      tmp_tab->sluch6 += kol_sluch
      tmp_tab->sluch13 += kol_sluch
      If kol_plus > 0 .and. _dispans == 2 // Взят
        tmp_tab->sluch8 += kol_plus
      Endif
    Elseif _dispans == 3 // Снят
      tmp_tab->sluch12 += kol_sluch
    Endif
    If kol_plus > 0 .and. eq_any( lnom_kol, 9, 10 )
      pole := "tmp_tab->sluch" + lstr( lnom_kol )
      &pole := &pole + Min( 1, kol_plus )
    Endif
    If v == 1
      If spec_vozrast == 2
        tmp_tab->sluch11 += kol_plus
      Elseif spec_vozrast == 3
        tmp_tab->sluch14 += kol_sluch
      Endif
    Elseif v == 2
      If spec_vozrast == 1 // до 1 месяца
        tmp_tab->sluch5 += kol_sluch
      Endif
      If spec1vozrast == 1 // до 1 года
        tmp_tab->sluch24 += kol_sluch
      Else
        tmp_tab->sluch25 += kol_sluch
        tmp_tab->sluch7 -= kol_plus
        tmp_tab->sluch17 += kol_plus
        If eq_any( _dispans, 1, 2 ) // Состоит, Взят
          tmp_tab->sluch6 -= kol_sluch
          tmp_tab->sluch16 += kol_sluch
          tmp_tab->sluch13 -= kol_sluch
          tmp_tab->sluch23 += kol_sluch
          If kol_plus > 0 .and. _dispans == 2 // Взят
            tmp_tab->sluch8 -= kol_plus
            tmp_tab->sluch18 += kol_plus
          Endif
        Elseif _dispans == 3 // Снят
          tmp_tab->sluch12 -= kol_sluch
          tmp_tab->sluch22 += kol_sluch
        Endif
        If kol_plus > 0 .and. eq_any( lnom_kol, 9, 10 )
          pole := "tmp_tab->sluch" + lstr( lnom_kol )
          &pole := &pole - Min( 1, kol_plus )
          pole := "tmp_tab->sluch" + lstr( lnom_kol + 10 )
          &pole := &pole + Min( 1, kol_plus )
        Endif
      Endif
    Elseif v == 3 .and. Upper( lpol ) == "М"
      tmp_tab->sluch5 += kol_sluch
      If kol_plus > 0 .and. _dispans == 2 // Взят
        tmp_tab->sluch11 += kol_plus
      Endif
      If eq_any( _dispans, 1, 2 ) // Состоит, Взят
        tmp_tab->sluch14 += kol_sluch
      Endif
    Endif
  Next
  If is_diag
    Select TMP_D
    find ( Str( v, 1 ) + PadR( lshifr, 5 ) )
    If !Found()
      Append Blank
      tmp_d->diagnoz := lshifr
      If ( j := AScan( k, {| x| n := AllTrim( x[ 1 ] ), ( !( n == "1.0" .and. x[ 2 ] == 1 ) .and. Right( n, 2 ) == ".0" ) } ) ) > 0
        tmp_d->stroke := PadR( k[ j, 1 ], 8 )
        tmp_d->tip := k[ j, 2 ]
      Endif
      tmp_d->voz := v
    Endif
    tmp_d->sluch += kol_sluch
    tmp_d->sluch7 += kol_plus
    If eq_any( _dispans, 1, 2 ) // Состоит, Взят
      tmp_d->sluch6 += kol_sluch
      tmp_d->sluch13 += kol_sluch
      If kol_plus > 0 .and. _dispans == 2 // Взят
        tmp_d->sluch8 += kol_plus
      Endif
    Elseif _dispans == 3 // Снят
      tmp_d->sluch12 += kol_sluch
    Endif
    If kol_plus > 0 .and. eq_any( lnom_kol, 9, 10 )
      pole := "tmp_d->sluch" + lstr( lnom_kol )
      &pole := &pole + Min( 1, kol_plus )
    Endif
    If v == 1
      If spec_vozrast == 2
        tmp_d->sluch11 += kol_plus
      Elseif spec_vozrast == 3
        tmp_d->sluch14 += kol_sluch
      Endif
    Elseif v == 2
      If spec_vozrast == 1
        tmp_d->sluch5 += kol_sluch
      Endif
      If spec1vozrast == 1
        tmp_d->sluch24 += kol_sluch
      Else
        tmp_d->sluch25 += kol_sluch
        tmp_d->sluch7 -= kol_plus
        tmp_d->sluch17 += kol_plus
        If eq_any( _dispans, 1, 2 ) // Состоит, Взят
          tmp_d->sluch6 -= kol_sluch
          tmp_d->sluch16 += kol_sluch
          tmp_d->sluch13 -= kol_sluch
          tmp_d->sluch23 += kol_sluch
          If kol_plus > 0 .and. _dispans == 2 // Взят
            tmp_d->sluch8 -= kol_plus
            tmp_d->sluch18 += kol_plus
          Endif
        Elseif _dispans == 3 // Снят
          tmp_d->sluch12 -= kol_sluch
          tmp_d->sluch22 += kol_sluch
        Endif
        If kol_plus > 0 .and. eq_any( lnom_kol, 9, 10 )
          pole := "tmp_d->sluch" + lstr( lnom_kol )
          &pole := &pole - Min( 1, kol_plus )
          pole := "tmp_d->sluch" + lstr( lnom_kol + 10 )
          &pole := &pole + Min( 1, kol_plus )
        Endif
      Endif
    Elseif v == 3 .and. Upper( lpol ) == "М"
      tmp_d->sluch5 += kol_sluch
      If kol_plus > 0 .and. _dispans == 2 // Взят
        tmp_d->sluch11 += kol_plus
      Endif
      If eq_any( _dispans, 1, 2 ) // Состоит, Взят
        tmp_d->sluch14 += kol_sluch
      Endif
    Endif
  Endif

  Return Nil

// 14.01.20
Function f2_f12( jh, is_diag )

  Local i, j, k, k4, m, s, v, v4 := 0, mvozrast, mdate, ll, a3 := {}, fl_z, kz, ad := {}, ;
    lshifr, fl, fl_plus, _dispans, ret := .f., kol_sluch, kol_plus, lshifr3, lnum_kol := 0
  Private spec_vozrast := 0, spec1vozrast := 0, mlet := 0

  Select TMP1RULE
  find ( "1" )
  Do While tmp1rule->tip == 1 .and. !Eof()
    kz := lnum_kol := 0
    fl := fl_plus := fl_z := .f. ; _dispans := 0
    lshifr := PadR( tmp1rule->shifr, 5 )
    If Left( lshifr, 1 ) == "Z"
      fl := fl_z := .t.
    Elseif tmp1rule->kol1 > 0 .or. tmp1rule->kol2 > 0 .or. tmp1rule->dispan > 0
      lshifr3 := Left( lshifr, 3 )
      AAdd( a3, lshifr3 )
      fl := .t.
      If ( fl_plus := ( tmp1rule->kol1 > 0 ) )
        lnum_kol := tmp1rule->num_kol
      Endif
      If tmp1rule->dispan > 0 .and. AScan( ad, lshifr3 ) == 0
        AAdd( ad, lshifr3 )
        _dispans := tmp1rule->dispan
      Endif
    Endif
    mdate := kart->date_r
    Select TMP2RULE
    find ( Str( tmp1rule->kod, 6 ) )
    Do While tmp2rule->kod == tmp1rule->kod .and. !Eof()
      ++kz
      mdate := Max( mdate, tmp2rule->n_data )
      Skip
    Enddo
    // определяем возраст по дате начала самого последнего лечения
    mvozrast := count_years( kart->date_r, mdate )
    mlet := Year( mdate ) - Year( kart->date_r )
    spec_vozrast := 0
    If mvozrast < 5
      spec_vozrast := 2
      If mvozrast == 0
        count_ymd( kart->date_r, mdate,, @m, )
        If m == 0
          spec_vozrast := 1
        Endif
      Endif
      If mvozrast < 1
        spec1vozrast := 1
      Elseif mvozrast < 4
        spec1vozrast := 2
      Endif
    Elseif mvozrast < 10
      spec_vozrast := 3
    Endif
    v := ret_v_f12( kart->pol, mvozrast, @v4 )
    If fl .or. _dispans > 0
      If !Empty( lshifr ) .and. ( k := ret_f_12( v, lshifr ) ) != NIL
        ret := .t.
        If fl_z
          kol_sluch := kol_plus := kz
        Else
          kol_sluch := tmp1rule->kol1 + tmp1rule->kol2
        Endif
        kol_plus := tmp1rule->kol1
        p_is_voz[ v ] := .t.
        s_f1_f12( is_diag, lshifr, k, v, kart->pol, kol_sluch, kol_plus, _dispans, lnum_kol )
        If v4 > 0 .and. ( k4 := ret_f_12( v4, lshifr ) ) != NIL
          p_is_voz[ v4 ] := .t.
          s_f1_f12( is_diag, lshifr, k4, v4, kart->pol, kol_sluch, kol_plus, _dispans, lnum_kol )
        Endif
        If !fl_z
          f12_kod_k( kart->kod, v, v4, kol_plus, _dispans )
        Endif
      Endif
    Endif
    Select TMP1RULE
    Skip
  Enddo
  Select TMP1RULE
  find ( "2" )
  Do While tmp1rule->tip == 2 .and. !Eof()
    fl := fl_plus := fl_z := .f. ; dispans := lnum_kol := 0
    lshifr := Left( tmp1rule->shifr, 3 )
    If Left( lshifr, 1 ) == "Z"
      fl := fl_z := .t.  // т.к. уже занесли пятизначный шифр
    Elseif AScan( a3, lshifr ) == 0 .and. ( tmp1rule->kol1 > 0 .or. tmp1rule->kol2 > 0 )
      AAdd( a3, lshifr )
      fl := .t.
      If ( fl_plus := ( tmp1rule->kol1 > 0 ) )
        lnum_kol := tmp1rule->num_kol
      Endif
    Endif
    If fl .or. _dispans > 0
      mdate := kart->date_r
      Select TMP2RULE
      find ( Str( tmp1rule->kod, 6 ) )
      Do While tmp2rule->kod == tmp1rule->kod .and. !Eof()
        mdate := Max( mdate, tmp2rule->n_data )
        Skip
      Enddo
      // определяем возраст по дате начала самого последнего лечения
      mvozrast := count_years( kart->date_r, mdate )
      mlet := Year( mdate ) - Year( kart->date_r )
      spec_vozrast := 0
      If mvozrast < 5
        spec_vozrast := 2
        If mvozrast == 0
          count_ymd( kart->date_r, mdate,, @m, )
          If m == 0
            spec_vozrast := 1
          Endif
        Endif
        If mvozrast < 1
          spec1vozrast := 1
        Elseif mvozrast < 4
          spec1vozrast := 2
        Endif
      Elseif mvozrast < 10
        spec_vozrast := 3
      Endif
      v := ret_v_f12( kart->pol, mvozrast, @v4 )
      lshifr := PadR( lshifr, 5 )
      If !Empty( lshifr ) .and. ( k := ret_f_12( v, lshifr ) ) != NIL
        ret := .t.
        kol_sluch := tmp1rule->kol1 + tmp1rule->kol2
        kol_plus := tmp1rule->kol1
        p_is_voz[ v ] := .t.
        s_f1_f12( is_diag, lshifr, k, v, kart->pol, kol_sluch, kol_plus, _dispans, lnum_kol )
        If v4 > 0 .and. ( k4 := ret_f_12( v4, lshifr ) ) != NIL
          p_is_voz[ v4 ] := .t.
          s_f1_f12( is_diag, lshifr, k4, v4, kart->pol, kol_sluch, kol_plus, _dispans, lnum_kol )
        Endif
        If !fl_z
          f12_kod_k( kart->kod, v, v4, kol_plus, _dispans )
        Endif
      Endif
    Endif
    Select TMP1RULE
    Skip
  Enddo
  If ret
    ++jh
  Endif

  Return jh

//
Function ret_f_12( k, lshifr )

  Local ret := {}, i, j, d, r

  d := diag_to_num( lshifr, 1 )
  If k == 0
    For i := 1 To len_diag
      r := diag1[ i, 3 ]
      For j := 1 To Len( r )
        If Between( d, r[ j, 1 ], r[ j, 2 ] )
          AAdd( ret, { diag1[ i, 1 ], diag1[ i, 2 ] } )
          Exit
        Endif
      Next
    Next
  Else
    For i := 1 To len_diag[ k ]
      r := diag1[ k, i, 3 ]
      For j := 1 To Len( r )
        If Between( d, r[ j, 1 ], r[ j, 2 ] )
          AAdd( ret, { diag1[ k, i, 1 ], diag1[ k, i, 2 ] } )
          Exit
        Endif
      Next
    Next
  Endif
  If Len( ret ) == 0 ; ret := NIL ; Endif

  Return ret

// 15.01.23
Function ret_v_f12( mpol, mvozrast, /*@*/v4)

  Local v

  If ( v := AScan( arr_v, {| x| Between( mvozrast, x[ 1 ], x[ 2 ] ) } ) ) == 0
    v := 4 // если почему-то не нашли - взрослые
  Endif
  v4 := 0
  If v == 1 .and. mvozrast < 4
    v4 := 2 // дети до 3х лет
  Elseif v == 4
    If GOD_PENSIONEROV < 2020
      If ( ( mpol == "Ж" .and. mvozrast >= 55 ) .or. ( mpol == "М" .and. mvozrast >= 60 ) )
        v4 := 5 // взрослые старше трудоспособного возраста
      Endif
    Elseif GOD_PENSIONEROV < 2022
      If ( ( mpol == "Ж" .and. mvozrast >= 56 ) .or. ( mpol == "М" .and. mvozrast >= 61 ) )
        v4 := 5 // взрослые старше трудоспособного возраста
      Endif
    Elseif GOD_PENSIONEROV < 2024
      If ( ( mpol == "Ж" .and. mvozrast >= 57 ) .or. ( mpol == "М" .and. mvozrast >= 62 ) )
        v4 := 5 // взрослые старше трудоспособного возраста
      Endif
    Elseif GOD_PENSIONEROV < 2026
      If ( ( mpol == "Ж" .and. mvozrast >= 58 ) .or. ( mpol == "М" .and. mvozrast >= 63 ) )
        v4 := 5 // взрослые старше трудоспособного возраста
      Endif
    Else
      If ( ( mpol == "Ж" .and. mvozrast >= 59 ) .or. ( mpol == "М" .and. mvozrast >= 64 ) )
        v4 := 5 // взрослые старше трудоспособного возраста
      Endif
    Endif
  Endif

  Return v

// 15.01.23
Function forma_12_o()

  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., sh := 79, HH := 80, reg_print := 5, speriod, ;
    arr_title, name_file :=  cur_dir + "_frm_12o" + stxt, s_lu := 0, s_human := 0, ;
    fl_plus := .f., md_plus, sd_plus, k_plus, jh := 0, arr_m, ;
    is_talon := .t., pole, arv, nf, adbf, kh, s1, s2, s3
  Private au1, au2, adiag_talon[ 16 ], GOD_PENSIONEROV

  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  GOD_PENSIONEROV := arr_m[ 1 ]
  If !Empty( yes_d_plus )
    fl_plus := .t. ; md_plus := Array( Len( yes_d_plus ) )
    k_plus := Len( md_plus )
    AFill( md_plus, " " )
    AEval( md_plus, {| x, i| md_plus[ i ] := SubStr( yes_d_plus, i, 1 ) } )
    sd_plus := Array( k_plus )
    AFill( sd_plus, 0 )
  Endif
  speriod := arr_m[ 4 ]
  //
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  nf := dir_server + "f39_nast" + smem
  If File( nf )
    arv := rest_arr( nf )
    au1 := arv[ 1 ]
    au2 := arv[ 2 ]
  Else
    au1 := { { "2.*" }, {} }   // Врачебные приемы
    au2 := { {}, {} }
  Endif
  //
  adbf := { { "otd", "N", 3, 0 }, ;
    { "lu", "N", 7, 0 }, ;
    { "stt_lu", "N", 7, 0 }, ;
    { "stt_diag", "N", 7, 0 } }
  dbCreate( cur_dir + "tmp_tab", adbf )
  Use ( cur_dir + "tmp_tab" ) New Alias TMP_TAB
  Index On Str( otd, 3 ) to ( cur_dir + "tmp_tab" )
  //
  adbf := { { "otd", "N", 3, 0 }, ;
    { "kod", "N", 7, 0 }, ;
    { "vrach", "C", 30, 0 }, ;
    { "diag1", "C", 6, 0 }, ;
    { "diag2", "C", 6, 0 }, ;
    { "diag3", "C", 6, 0 }, ;
    { "diag4", "C", 6, 0 }, ;
    { "diag5", "C", 6, 0 }, ;
    { "diag6", "C", 6, 0 }, ;
    { "diag7", "C", 6, 0 }, ;
    { "diag8", "C", 6, 0 } }
  dbCreate( cur_dir + "tmp_fio", adbf )
  Use ( cur_dir + "tmp_fio" ) New Alias TMP_FIO
  adbf := NIL
  //
  kh := 0
  r_use( dir_server + "mo_pers",, "PERSO" )
  r_use( dir_server + "uslugi",, "USL" )
  r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
  Set Relation To u_kod into USL
  If pi1 == 1  // по дате окончания лечения
    begin_date := arr_m[ 5 ]
    end_date := arr_m[ 6 ]
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", { dir_server + "humand", dir_server + "humank" }, "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( begin_date ), .t. )
    Do While human->k_data <= end_date .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
      If jh > 0
        @ Row(), Col() Say "/" Color "W/R"
        @ Row(), Col() Say lstr( jh ) Color cColorStMsg
      Endif
      If human_->usl_ok == 3 .and. human_->oplata < 9 .and. ;
          func_pi_schet() .and. f_is_uch( st_a_uch, human->lpu )
        date_24( human->k_data )
        jh := f1_f12_o( jh )
      Endif
      Select HUMAN
      Skip
    Enddo
  Else
    begin_date := arr_m[ 7 ]
    end_date := arr_m[ 8 ]
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", { dir_server + "humans", dir_server + "humank" }, "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server + "schet_",, "SCHET_" )
    r_use( dir_server + "schet", dir_server + "schetd", "SCHET" )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( begin_date, .t. )
    Do While schet->pdate <= end_date .and. !Eof()
      date_24( c4tod( schet->pdate ) )
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
        If jh > 0
          @ Row(), Col() Say "/" Color "W/R"
          @ Row(), Col() Say lstr( jh ) Color cColorStMsg
        Endif
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human_->usl_ok == 3 .and. human_->oplata < 9 .and. f_is_uch( st_a_uch, human->lpu )
          jh := f1_f12_o( jh )
        Endif
        Select HUMAN
        Skip
      Enddo
      If fl_exit
        Exit
      Endif
      Select SCHET
      Skip
    Enddo
  Endif
  s_human := tmp_fio->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit ; Return NIL ; Endif
  //
  mywait()
  arr_title := { ;
    "──────────────────────────────┬──────────────┬───────────────┬─────────────────", ;
    "                              │  Количество  │   Случаев с   │   Диагнозов с   ", ;
    "          Отделение           │   случаев    │первич./повтор.│ первич./повтор. ", ;
    "──────────────────────────────┴──────────────┴───────────────┴─────────────────" }
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( Center( "Статистика о первичных (повторных) заболеваниях", sh ) )
  titlen_uch( st_a_uch, sh, lcount_uch )
  add_string( "" )
  add_string( Center( speriod, sh ) )
  If pi1 == 1
    add_string( Center( str_pi_schet(), sh ) )
  Else
    add_string( Center( "[ по дате выписки счета ]", sh ) )
  Endif
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  //
  r_use( dir_server + "mo_otd",, "OTD" )
  Use ( cur_dir + "tmp_tab" ) New Alias TMP
  Set Relation To otd into OTD
  Index On Upper( otd->name ) to ( cur_dir + "tmp_tab" )
  Go Top
  s1 := s2 := s3 := 0
  Do While !Eof()
    add_string( PadR( otd->name, 30 ) + put_val( tmp->lu, 10 );
      + put_val( tmp->stt_lu, 16 );
      + put_val( tmp->stt_diag, 17 ) )
    s1 += tmp->lu
    s2 += tmp->stt_lu
    s3 += tmp->stt_diag
    Skip
  Enddo
  add_string( Replicate( "─", sh ) )
  add_string( Space( 30 ) + put_val( s1, 10 );
    + put_val( s2, 16 );
    + put_val( s3, 17 ) )
  Close databases
  If s_human > 0
    add_string( Chr( 12 ) )
    tek_stroke := 0 ; n_list++
    next_list( sh )
    add_string( "" )
    add_string( Center( "Список больных с первичными (повторными) заболеваниями", sh ) )
    add_string( "" )
    //
    r_use( dir_server + "mo_otd",, "OTD" )
    r_use( dir_server + "human",, "HUMAN" )
    Use ( cur_dir + "tmp_fio" ) New Alias TMP
    Set Relation To otd into OTD, To kod into HUMAN
    Index On Upper( otd->name ) + Left( Upper( human->fio ), 12 ) to ( cur_dir + "tmp_fio" )
    Go Top
    s1 := 0
    Do While !Eof()
      verify_ff( HH - 2, .t., sh )
      If tmp->otd != s1
        add_string( "= " + Upper( AllTrim( otd->name ) ) + " =" )
        s1 := tmp->otd
      Endif
      s := Space( 3 ) + Left( human->fio, 34 ) + " " + full_date( human->k_data ) + Space( 3 )
      For i := 1 To 8
        pole := "tmp->diag" + lstr( i )
        If !Empty( &pole )
          s += "  " + &pole
        Endif
      Next
      If !Empty( tmp->vrach )
        s += "  " + AllTrim( tmp->vrach )
      Endif
      add_string( s )
      Skip
    Enddo
  Endif
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( name_file,,,, .t.,,, reg_print )

  Return Nil

// 05.01.16
Function f1_f12_o( jh )

  Local arr_d := {}, arr := {}, i, j, k, s, fl, fl_plus, arv, pole, is_talon := .t.

  If eq_any( human->ishod, 101, 102, 201, 202, 203, 204, 205, 301, 302 )
    If eq_any( human->ishod, 101, 102 )
      arr := ret_f12_pn( human->kod, 1 )
    Elseif eq_any( human->ishod, 201, 203, 204 )
      arr := ret_f12_dvn( human->kod, 1 )
    Elseif eq_any( human->ishod, 301, 302 )
      arr := ret_f12_pn( human->kod, 2 )
    Endif
    For i := 1 To Len( arr )
      arr[ i, 1 ] := PadR( arr[ i, 1 ], 5 )
      If !Empty( arr[ i, 1 ] )
        fl := fl_plus := .f.
        If arr[ i, 2 ] > 0
          fl := .t.
          fl_plus := ( arr[ i, 2 ] == 1 )
        Endif
        If fl
          AAdd( arr_d, AllTrim( arr[ i, 1 ] ) + iif( fl_plus, "+", "-" ) )
        Endif
      Endif
    Next
  Else
    AFill( adiag_talon, 0 )
    For i := 1 To 16
      adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
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
      arr[ i ] := PadR( arr[ i ], 5 )
      If !Empty( arr[ i ] )
        fl := fl_plus := .f.
        s := SubStr( human->diag_plus, i, 1 )
        If equalany( s, "+", "-" )  // старая форма
          fl := .t.
          fl_plus := ( s == "+" )
        Elseif is_talon
          s := adiag_talon[ i * 2 -1 ]   // характер заболевания
          If ( fl := equalany( s, 1, 2 ) )
            fl_plus := ( s == 1 )
          Else
            s := adiag_talon[ i * 2 ]   // диспансеризация
            If ( fl := equalany( s, 1, 2 ) )
              fl_plus := ( s == 1 )
            Endif
          Endif
        Endif
        If fl
          AAdd( arr_d, AllTrim( arr[ i ] ) + iif( fl_plus, "+", "-" ) )
        Endif
      Endif
    Next
  Endif
  Select TMP_TAB
  find ( Str( human->otd, 3 ) )
  If !Found()
    Append Blank
    tmp_tab->otd := human->otd
  Endif
  tmp_tab->lu++
  If ( j := Len( arr_d ) ) > 0
    tmp_tab->stt_lu++
    tmp_tab->stt_diag += j
    //
    Select TMP_FIO
    Append Blank
    tmp_fio->otd := human->otd
    tmp_fio->kod := human->( RecNo() )
    For i := 1 To Min( j, 8 )
      pole := "tmp_fio->diag" + lstr( i )
      &pole := arr_d[ i ]
    Next
    arv := {}
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      If hu->kod_vr > 0 .and. AScan( arv, hu->kod_vr ) == 0 .and. ;
          ( ret_f_nastr( au1, usl->shifr ) .or. ret_f_nastr( au2, usl->shifr ) )
        AAdd( arv, hu->kod_vr )
      Endif
      Skip
    Enddo
    If Len( arv ) > 0
      AEval( arv, {| x, i| perso->( dbGoto( x ) ), arv[ i ] := perso->tab_nom } )
      ASort( arv )
      s := "["
      AEval( arv, {| x| s += lstr( x ) + "," } )
      s := SubStr( s, 1, Len( s ) -1 ) + "]"
      tmp_fio->vrach := s
    Endif
    If tmp_fio->( LastRec() ) % 5000 == 0
      Commit
    Endif
  Endif
  If j > 0
    ++jh
  Endif

  Return jh

// 05.01.17 для "исправлялки" форм 12 и 57
Function verify12rule( arr_bukva, lpol, yes_god )

  Local i, j, k, ta := {}, lb := Len( arr_bukva ), s, ta4 := {}, rec, fl

  Select TMP_RULE
  find ( "3" )
  If Found()  // т.е. работаем с правилами номер 3
    Select TMP1RULE
    find ( "1" )
    Do While tmp1rule->tip == 1 .and. !Eof()
      Select TMP_RULE
      dbSeek( "3" + Str( tmp1rule->dnum, 6 ), .t. )
      If tmp_rule->rule == 3 .and. !( tmp_rule->pol == lpol ) ;
          .and. Between( tmp1rule->dnum, tmp_rule->dnum1, tmp_rule->dnum2 )
        AAdd( ta4, tmp1rule->( RecNo() ) )
      Endif
      Select TMP1RULE
      Skip
    Enddo
  Endif
  Select TMP_RULE
  find ( "4" )
  If Found()  // т.е. работаем с правилом номер 4
    Select TMP1RULE
    find ( "1" )
    Do While tmp1rule->tip == 1 .and. !Eof()
      Select TMP_RULE
      dbSeek( "4" + Str( tmp1rule->dnum, 6 ), .t. )
      If tmp_rule->rule == 4 .and. Between( tmp1rule->dnum, tmp_rule->dnum1, tmp_rule->dnum2 )
        AAdd( ta4, tmp1rule->( RecNo() ) )
      Endif
      Select TMP1RULE
      Skip
    Enddo
  Endif
  If Len( ta4 ) > 0
    Select TMP1RULE
    For i := 1 To Len( ta4 )
      Goto ( ta4[ i ] )
      Delete  // пометить на удаление
    Next
  Endif
  Select TMP_RULE
  find ( "1" )
  If Found()  // т.е. работаем с правилами номер 1
    Select TMP1RULE
    find ( "1" )
    Do While tmp1rule->tip == 1 .and. !Eof()
      Select TMP_RULE
      dbSeek( "1" + Str( tmp1rule->dnum, 6 ), .t. )
      If tmp_rule->rule == 1 .and. Between( tmp1rule->dnum, tmp_rule->dnum1, tmp_rule->dnum2 )
        // острое заболевание
        If tmp1rule->kol2 > 0  // если указан характер ПОВТОРНОЕ
          tmp1rule->kol2 := 0  // то просто уберем это
        Endif
        If tmp1rule->kol1 == 0  // если не указан характер ПЕРВИЧНОЕ
          tmp1rule->kol1 := 1  // то поставим хотя бы раз !!!???
        Elseif tmp1rule->kol1 > 1  // характер ПЕРВИЧНОЕ указан более 1 раза
          tmp1rule->kol1 := f3_ver_rule( tmp1rule->kod, tmp_rule->dni4 )
        Endif
      Else // хроническое заболевание
        If tmp1rule->kol1 > 1
          tmp1rule->kol1 := 1
        Endif
        If tmp1rule->kol2 > 1
          tmp1rule->kol2 := 1
        Endif
        If tmp1rule->kol1 > 0
          tmp1rule->kol2 := 0
        Endif
        If yes_god .and. emptyall( tmp1rule->kol1, tmp1rule->kol2 )
          tmp1rule->kol2 := 1
        Endif
      Endif
      Select TMP1RULE
      Skip
    Enddo
    //
    Select TMP1RULE
    find ( "2" )
    Do While tmp1rule->tip == 2 .and. !Eof()
      Select TMP_RULE
      dbSeek( "1" + Str( tmp1rule->dnum, 6 ), .t. )
      If tmp_rule->rule == 1 .and. Between( tmp1rule->dnum, tmp_rule->dnum1, tmp_rule->dnum2 )
        // острое заболевание
        tmp1rule->kol1 := 0 // уберем
        tmp1rule->kol2 := 0 // уберем
        tmp1rule->dispan := 0  // !!!!!!!!!!!!!!!!!
      Else // хроническое заболевание для трехзначного диагноза
        If tmp1rule->kol1 + tmp1rule->kol2 > 1
          tmp1rule->kol1 := 0  // первичное уберем
          tmp1rule->kol2 := 1  // повторное хотя бы раз
        Endif
      Endif
      Select TMP1RULE
      Skip
    Enddo
    Select TMP1RULE
    find ( "1" )
    Do While tmp1rule->tip == 1 .and. !Eof()
      rec := RecNo()
      find ( "2" + PadR( Left( tmp1rule->shifr, 3 ), 5 ) )
      fl := ( Found() .and. tmp1rule->kol2 > 0 )
      Goto ( rec )
      If fl  // если повторный характер уже занесен по трехзначной рубрике
        tmp1rule->kol2 := 0 // уберем
      Endif
      Skip
    Enddo
  Endif

  Return Nil

// 11.12.16
Static Function f12_kod_k( mkod_k, v, v4, kol_plus, _dispans )

  Static sc := 0

  Select TMP_KART
  find ( Str( mkod_k, 7 ) )
  If !Found()
    Append Blank
    tmp_kart->kod_k := mkod_k
  Endif
  tmp_kart->voz := iif( v4 > 0, v4, v )
  If kol_plus > 0
    tmp_kart->perv := 1
  Endif
  tmp_kart->let := iif( Between( mlet, 0, 99 ), mlet, 0 )
  If eq_any( _dispans, 1, 2 )
    tmp_kart->disp := 1
    If _dispans == 2 // Взят
      tmp_kart->disp1 := 1
    Endif
  Endif
  If++sc == 5000
    Commit
    sc := 0
  Endif

  Return Nil
