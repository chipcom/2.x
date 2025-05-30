#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch  := 1

// 10.03.19
Function forma_14( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j, uch_otd

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "Распечатка ~формы 14", ;
      "Форма 14 + ~диагнозы", ;
      "~Отделение + форма 14", ;
      "~Переведённые в другие ЛПУ" }
    mas_msg := { "Распечатка формы № 14", ;
      "Распечатка аналога формы 14 с уточнением диагнозов", ;
      "Распечатка аналога формы 14 с диагнозами по конкретному отделению", ;
      "Распечатка аналога формы 14 с уточнением диагнозов по переведённым в другие ЛПУ" }
    mas_fun := { "forma_14(11)", ;
      "forma_14(12)", ;
      "forma_14(13)", ;
      "forma_14(14)" }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    forma_14_( .f., .f. )
  Case k == 12
    forma_14_( .t., .f. )
  Case k == 13
    forma_14_( .t., .t. )
  Case k == 14
    forma_14_( .t., .f., .t. )
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil


// 14.10.24
Function forma_14_( is_diag, is_otd, is_pereved )

  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., sh, HH := 80, reg_print, speriod, ;
    arr_title, name_file, jh := 0, jh1 := 0, arr_m, nf, file_form

  Default is_pereved To .f.
  name_file := cur_dir() + iif( is_diag, '_frm_14d', '_form_14' ) + stxt()
  If ( file_form := search_file( 'forma_14' + sfrm() ) ) == NIL
    Return func_error( 4, 'Не обнаружен файл FORMA_14' + sfrm() )
  Endif

  Private len_name := 28, arr_usl, yes_vmp := .f., yes_perevod := is_pereved
  st_a_uchast := {}
  If is_otd
    If input_uch( T_ROW, T_COL - 5, sys_date ) == Nil .or. ;
        input_otd( T_ROW, T_COL - 5, sys_date ) == NIL
      Return Nil
    Endif
  Else
    If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
      Return Nil
    Endif
    If !is_pereved .and. ( st_a_uchast := ret_uchast( T_ROW, T_COL - 5 ) ) == NIL
      Return Nil
    Endif
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  speriod := arr_m[ 4 ]
  //
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  Private arr_perevod[ 11 ] ; AFill( arr_perevod, 0 )
  //
  adbf := { { "stroke", "C", 9, 0 }, ;
    { "tip","N", 1, 0 }, ;
    { "p_boln", "N", 7, 0 }, ;
    { "p_ekst", "N", 7, 0 }, ;
    { "p_skor", "N", 7, 0 }, ;
    { "p_bdo1", "N", 7, 0 }, ;
    { "p_kd","N", 9, 0 }, ;
    { "p_kd1","N", 9, 0 }, ;
    { "p_umer", "N", 7, 0 }, ;
    { "p_vskr", "N", 7, 0 }, ;
    { "p_rash", "N", 7, 0 }, ;
    { "p_udo1", "N", 7, 0 } }
  //

  dbCreate( cur_dir() + "tmp_tab", adbf )
  Use ( cur_dir() + "tmp_tab" ) New Alias TMP_TAB
  Index On Str( tip, 1 ) + stroke to ( cur_dir() + "tmp_tab" )
  //
  Private diag1 := {}, len_diag
  lfp := FOpen( file_form )
  Do While !feof( lfp )
    updatestatus()
    s := freadln( lfp )
    s1 := AllTrim( Left( s, 9 ) )     // номер строки
    If iif( is_diag, ( Right( s1, 2 ) == ".0" ), .t. ) // только группы типа 1.0, 2.0, ..., 10.0
      s2 := AllTrim( Token( s, " ", 2 ) )
  /*for i := 1 to len(s2) // проверка на русские буквы в диагнозах
    if ISRALPHA(substr(s2,i,1))
      strfile(s2+eos,"ttt.ttt",.t.)
      exit
    endif
  next*/
      s3 := Token( s, " ", 3 )
      s3 := SubStr( s, AtNum( s3, s, 1 ) )
      //
      k := st_nom_stroke( s1 )
      For i := 1 To NumToken( s3, hb_ps() )
        s4 := k + AllTrim( Token( s3, hb_ps(), i ) )
        len_name := Max( len_name, Len( s4 ) )
      Next
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
      Select TMP_TAB
      For i := 1 To 3
        Append Blank
        tmp_tab->tip := i
        tmp_tab->stroke := s1
      Next
      AAdd( diag1, { s1, diapazon } )
    Endif
  Enddo
  FClose( lfp )
  len_diag := Len( diag1 )
  If is_diag
    AAdd( adbf, { "diagnoz", "C", 6, 0 } )
    dbCreate( cur_dir() + "tmp_dia", adbf )
    Use ( cur_dir() + "tmp_dia" ) New Alias TMP_D
    Index On Str( tip, 1 ) + diagnoz to ( cur_dir() + "tmp_dia" )
  Endif
  //
  adbf := { { "stroke", "C", 9, 0 }, ;
    { "p_boln", "N", 7, 0 }, ;
    { "p_umer", "N", 7, 0 }, ;
    { "p_umer6", "N", 7, 0 }, ;
    { "p1boln", "N", 7, 0 }, ;
    { "p1umer", "N", 7, 0 }, ;
    { "p1umer6", "N", 7, 0 } }
  //
  dbCreate( cur_dir() + "tmp_3000", adbf )
  Use ( cur_dir() + "tmp_3000" ) new
  Index On stroke to ( cur_dir() + "tmp_3000" )
  //
  Private arr_3000 := f14_arr_3000(), diag1_3000 := {}, len_diag_3000
  For j := 1 To Len( arr_3000 )
    s1 := arr_3000[ j, 2 ]  // номер строки
    s2 := arr_3000[ j, 3 ]  // диагнозы
    If iif( is_diag, !( "." $ s1 ), .t. ) // только группы типа 1, 2, ..., 7
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
      Select TMP_3000
      Append Blank
      tmp_3000->stroke := s1
      AAdd( diag1_3000, { s1, diapazon } )
    Endif
  Next
  len_diag_3000 := Len( diag1_3000 )
  If is_diag
    AAdd( adbf, { "diagnoz", "C", 6, 0 } )
    dbCreate( cur_dir() + "tmp_d3", adbf )
    Use ( cur_dir() + "tmp_d3" ) new
    Index On diagnoz to ( cur_dir() + "tmp_d3" )
  Endif
  //
  adbf := { { "stroke", "C", 9, 0 }, ;
    { "p_boln", "N", 7, 0 }, ;
    { "p_boln1", "N", 7, 0 }, ;
    { "p_boln2", "N", 7, 0 }, ;
    { "p_boln3", "N", 7, 0 }, ;
    { "p_boln4", "N", 7, 0 }, ;
    { "_p_boln", "N", 7, 0 }, ;
    { "_p_boln1", "N", 7, 0 }, ;
    { "_p_boln2", "N", 7, 0 }, ;
    { "_p_boln3", "N", 7, 0 }, ;
    { "_p_boln4", "N", 7, 0 }, ;
    { "p_umer", "N", 7, 0 }, ;
    { "p_umer1", "N", 7, 0 }, ;
    { "p_umer2", "N", 7, 0 }, ;
    { "p_umer3", "N", 7, 0 }, ;
    { "p_umer4", "N", 7, 0 }, ;
    { "_p_umer", "N", 7, 0 }, ;
    { "_p_umer1", "N", 7, 0 }, ;
    { "_p_umer2", "N", 7, 0 }, ;
    { "_p_umer3", "N", 7, 0 }, ;
    { "_p_umer4", "N", 7, 0 }, ;
    { "p_onko", "N", 7, 0 } }
  //
  dbCreate( cur_dir() + "tmp_4000", adbf )
  Use ( cur_dir() + "tmp_4000" ) new
  Index On stroke to ( cur_dir() + "tmp_4000" )
  //
  Private arr_4000 := f14_arr_4000(), usl1_4000 := {}, len_usl_4000
  For j := 1 To Len( arr_4000 )
    s1 := arr_4000[ j, 2 ]  // номер строки
    s2 := arr_4000[ j, 3 ]  // включающие услуги
    If iif( is_diag, !( "." $ s1 ), .t. ) // только группы типа 1, 2, ...
      diapazon := {} ; diapazon1 := {}
      For i := 1 To NumToken( s2, "," )
        s3 := Token( s2, ",", i )
        If "-" $ s3
          d1 := Token( s3, "-", 1 )
          d2 := Token( s3, "-", 2 )
        Else
          d1 := d2 := s3
        Endif
        AAdd( diapazon, { usl_to_ffoms( d1, 1 ), usl_to_ffoms( d2, 2 ) } )
      Next
      If Len( arr_4000[ j ] ) > 3
        s2 := arr_4000[ j, 4 ]  // исключающие услуги
        For i := 1 To NumToken( s2, "," )
          s3 := Token( s2, ",", i )
          If "-" $ s3
            d1 := Token( s3, "-", 1 )
            d2 := Token( s3, "-", 2 )
          Else
            d1 := d2 := s3
          Endif
          AAdd( diapazon1, { usl_to_ffoms( d1, 1 ), usl_to_ffoms( d2, 2 ) } )
        Next
      Endif
      Select TMP_4000
      Append Blank
      tmp_4000->stroke := s1
      AAdd( usl1_4000, { s1, diapazon, diapazon1 } )
    Endif
  Next
  len_usl_4000 := Len( usl1_4000 )
  If is_diag
    AAdd( adbf, { "shifr", "C", 14, 0 } )
    dbCreate( cur_dir() + "tmp_d4", adbf )
    Use ( cur_dir() + "tmp_d4" ) new
    Index On shifr to ( cur_dir() + "tmp_d4" )
  Endif
  //
  adbf := { { "stroke", "C", 9, 0 }, ;
    { "vip_0_14", "N", 7, 0 }, ;
    { "vip_15_19", "N", 7, 0 }, ;
    { "vip_20_24", "N", 7, 0 }, ;
    { "vip_25_29", "N", 7, 0 }, ;
    { "vip_30_34", "N", 7, 0 }, ;
    { "vip_35_39", "N", 7, 0 }, ;
    { "vip_40_44", "N", 7, 0 }, ;
    { "vip_45_49", "N", 7, 0 }, ;
    { "vip_50_54", "N", 7, 0 }, ;
    { "vip_55_59", "N", 7, 0 }, ;
    { "vip_60_64", "N", 7, 0 }, ;
    { "vip_65_69", "N", 7, 0 }, ;
    { "vip_70_74", "N", 7, 0 }, ;
    { "vip_75_79", "N", 7, 0 }, ;
    { "vip_80_84", "N", 7, 0 }, ;
    { "vip_85_99", "N", 7, 0 }, ;
    { "umer_0_14", "N", 7, 0 }, ;
    { "umer_15_19", "N", 7, 0 }, ;
    { "umer_20_24", "N", 7, 0 }, ;
    { "umer_25_29", "N", 7, 0 }, ;
    { "umer_30_34", "N", 7, 0 }, ;
    { "umer_35_39", "N", 7, 0 }, ;
    { "umer_40_44", "N", 7, 0 }, ;
    { "umer_45_49", "N", 7, 0 }, ;
    { "umer_50_54", "N", 7, 0 }, ;
    { "umer_55_59", "N", 7, 0 }, ;
    { "umer_60_64", "N", 7, 0 }, ;
    { "umer_65_69", "N", 7, 0 }, ;
    { "umer_70_74", "N", 7, 0 }, ;
    { "umer_75_79", "N", 7, 0 }, ;
    { "umer_80_84", "N", 7, 0 }, ;
    { "umer_85_99", "N", 7, 0 } }
  //
  dbCreate( cur_dir() + "tmp_2910", adbf )
  Use ( cur_dir() + "tmp_2910" ) new
  Index On stroke to ( cur_dir() + "tmp_2910" )
  //
  Private arr_2910 := f14_arr_2910(), diag1_2910 := {}, len_diag_2910
  For j := 1 To Len( arr_2910 )
    s1 := arr_2910[ j, 2 ]  // номер строки
    s2 := arr_2910[ j, 3 ]  // диагнозы
    If iif( is_diag, !( "." $ s1 ), .t. ) // только группы типа 1, 2, ..., 7
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
      Select TMP_2910
      Append Blank
      tmp_2910->stroke := s1
      AAdd( diag1_2910, { s1, diapazon } )
    Endif
  Next
  len_diag_2910 := Len( diag1_2910 )
  If is_diag
    AAdd( adbf, { "diagnoz", "C", 6, 0 } )
    dbCreate( cur_dir() + "tmp_d5", adbf )
    Use ( cur_dir() + "tmp_d5" ) new
    Index On diagnoz to ( cur_dir() + "tmp_d5" )
  Endif
  //
  r_use( dir_server + "uslugi",, "USL" )
  r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
  Set Relation To u_kod into USL
  r_use( dir_server + "kartotek",, "KART" )
  If pi1 == 1 // по дате окончания лечения
    begin_date := arr_m[ 5 ]
    end_date := arr_m[ 6 ]
    r_use( dir_server + "human_2",, "HUMAN_2" )
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humand", "HUMAN" )
    Set Relation To kod_k into KART, To RecNo() into HUMAN_, To RecNo() into HUMAN_2
    dbSeek( DToS( begin_date ), .t. )
    Do While human->k_data <= end_date .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If human_->usl_ok == 1 .and. human_->oplata < 9 .and. ;
          iif( is_otd, ( human->otd == glob_otd[ 1 ] ), f_is_uch( st_a_uch, human->lpu ) ) ;
          .and. func_pi_schet() .and. f_is_uchast( st_a_uchast, kart->uchast ) ;
          .and. iif( is_pereved, human_->RSLT_NEW == 102, .t. )
        jh := f1_f14( jh, @jh1, is_diag )
        @ MaxRow(), 1 Say lstr( jh ) Color cColorSt2Msg
        @ Row(), Col() Say "/" Color "W/R"
        @ Row(), Col() Say lstr( jh1 ) Color cColorStMsg
        date_24( human->k_data )
      Endif
      Select HUMAN
      Skip
    Enddo
  Else
    begin_date := arr_m[ 7 ]
    end_date := arr_m[ 8 ]
    r_use( dir_server + "human_2",, "HUMAN_2" )
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
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
        If human_->usl_ok == 1 .and. human_->oplata < 9 .and. ;
            iif( is_otd, ( human->otd == glob_otd[ 1 ] ), f_is_uch( st_a_uch, human->lpu ) ) ;
            .and. f_is_uchast( st_a_uchast, kart->uchast ) ;
            .and. iif( is_pereved, human_->RSLT_NEW == 102, .t. )
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          jh := f1_f14( jh, @jh1, is_diag )
          @ MaxRow(), 1 Say lstr( jh ) Color cColorSt2Msg
          @ Row(), Col() Say "/" Color "W/R"
          @ Row(), Col() Say lstr( jh1 ) Color cColorStMsg
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
  //
  //
  Close databases
  rest_box( buf )
  If fl_exit ; Return NIL ; Endif
  //
  mywait()
  reg_print := 6
  Private x := 3
  arr_title := f14_title()
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server + "organiz",, "ORG" )
  add_string( Replicate( "-", sh ) )
  x := 1
  arr_title := f14_title()
  sh := Len( arr_title[ 1 ] )
  add_string( PadR( org->name, sh ) )
  add_string( Space( 60 ) + PadL( "Форма № 14", sh - 60 ) )
  add_string( PadL( "Утверждена", sh ) )
  add_string( PadL( "Приказом Росстата", sh ) )
  add_string( PadL( "от 25.12.2023г. № 681", sh ) )
  add_string( Center( "СВЕДЕНИЯ О ДЕЯТЕЛЬНОСТИ ПОДРАЗДЕЛЕНИЙ МЕДИЦИНСКОЙ ОРГАНИЗАЦИИ,", sh ) )
  add_string( Center( "ОКАЗЫВАЮЩИХ МЕДИЦИНСКУЮ ПОМОЩЬ В СТАЦИОНАРНЫХ УСЛОВИЯХ", sh ) )
  If is_otd
    add_string( Center( AllTrim( glob_otd[ 2 ] ), sh ) )
  Else
    titlen_uch( st_a_uch, sh, lcount_uch )
    title_uchast( st_a_uchast, sh )
  Endif
  If is_pereved
    add_string( Center( "[ переведённые в другие ЛПУ ]", sh ) )
  Endif
  add_string( "" )
  add_string( Center( speriod, sh ) )
  If pi1 == 1
    add_string( Center( str_pi_schet(), sh ) )
  Else
    add_string( Center( "[ по дате выписки счета ]", sh ) )
  Endif
  add_string( "" )
  //
  If is_diag
    r_use( dir_exe() + "_mo_mkb", cur_dir() + "_mo_mkb", "MKB10" )
    Use ( cur_dir() + "tmp_dia" ) New Alias TMP_D
    Index On Str( tip, 1 ) + stroke + diagnoz to ( cur_dir() + "tmp_dia" )
    Use ( cur_dir() + "tmp_d3" ) new
    Index On stroke + diagnoz to ( cur_dir() + "tmp_d3" )
    Use ( cur_dir() + "tmp_d4" ) new
    Index On stroke + shifr to ( cur_dir() + "tmp_d4" )
    Use ( cur_dir() + "tmp_d5" ) new
    Index On stroke + diagnoz to ( cur_dir() + "tmp_d5" )
  Endif
  Use ( cur_dir() + "tmp_2910" ) index ( cur_dir() + "tmp_2910" ) new
  Use ( cur_dir() + "tmp_3000" ) index ( cur_dir() + "tmp_3000" ) new
  Use ( cur_dir() + "tmp_4000" ) index ( cur_dir() + "tmp_4000" ) new
  Use ( cur_dir() + "tmp_tab" ) index ( cur_dir() + "tmp_tab" ) New Alias TMP
  ft_use( file_form )
  add_string( Center( "1. СОСТАВ ПАЦИЕНТОВ В СТАЦИОНАРЕ, СРОКИ И ИСХОДЫ ЛЕЧЕНИЯ", sh ) )
  add_string( " (2000)" + PadL( "Код по ОКЕИ: человек - 792", sh - 8 ) )
  For x := 1 To 3
    arr_title := f14_title()
    sh := Len( arr_title[ 1 ] )
    If x > 1  // искусственный перевод страницы
      tek_stroke := HH + 10
      verify_ff( HH, .t., sh )
    Endif
    AEval( arr_title, {| x| add_string( x ) } )
    ft_gotop()
    Do While !ft_eof() .and. !Empty( s := ft_readln() )
      s1 := Left( s, 9 ) ; s1_ := AllTrim( s1 )
      If iif( is_diag, ( Right( s1_, 2 ) == ".0" ), .t. )
        s2 := Token( s, " ", 2 )
        s3 := Token( s, " ", 3 )
        s3 := SubStr( s, AtNum( s3, s, 1 ) )
        Select TMP
        find ( Str( x, 1 ) + s1 )
        If Found() .and. iif( is_diag, !emptyall( tmp->p_boln, tmp->p_umer ), .t. )
          k := st_nom_stroke( s1 )
          //
          j1 := 0 ; t_arr1 := {} ; t_arr2 := Array( 12 )
          For i := 1 To NumToken( s3, hb_ps() )
            s := AllTrim( Token( s3, hb_ps(), i ) )
            ++j1 ; AAdd( t_arr1, k + s )
          Next
          j2 := perenos( t_arr2, s2, 12, "," )
          For i := j1 + 1 To j2
            ++j1 ; AAdd( t_arr1, "" )
          Next
          If verify_ff( HH - Max( j1, j2 ), .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          ls1 := PadR( t_arr1[ 1 ], len_name ) + ;
            PadC( AllTrim( s1 ), 11 ) + ;
            PadC( AllTrim( t_arr2[ 1 ] ), 12 )
          ls1 += put_val( tmp->p_boln, 7 ) + ;
            put_val( tmp->p_ekst, 7 ) + ;
            put_val( tmp->p_skor, 7 )
          If x == 3
            ls1 += put_val( tmp->p_bdo1, 7 )
          Endif
          ls1 += put_val( tmp->p_kd,8 )
          If x == 3
            ls1 += put_val( tmp->p_kd1,7 )
          Endif
          ls1 += put_val( tmp->p_umer, 4 ) + ;
            put_val( tmp->p_vskr, 4 ) + ;
            put_val( tmp->p_rash, 4 )
          If x == 3
            ls1 += Space( 6 ) + put_val( tmp->p_udo1, 4 )
          Endif
          If is_diag .and. !( s1_ == "1.0" )
            add_string( Replicate( "-", sh ) )
          Endif
          add_string( ls1 )
          For i := 2 To Max( j1, j2 )
            ls2 := PadR( t_arr1[ i ], len_name ) + ;
              Space( 11 ) + ;
              PadC( AllTrim( t_arr2[ i ] ), 12 )
            add_string( ls2 )
          Next
          If iif( is_diag, !( s1_ == "1.0" ), .t. )
            add_string( Replicate( "-", sh ) )
          Endif
          If is_diag
            Select TMP_D
            find ( Str( x, 1 ) + s1 )
            Do While tmp_d->tip == x .and. tmp_d->stroke == s1 .and. !Eof()
              Select MKB10
              find ( tmp_d->diagnoz )
              s := AllTrim( mkb10->name ) + " "
              Skip
              Do While mkb10->shifr == tmp_d->diagnoz .and. mkb10->ks > 0 ;
                  .and. !Eof()
                s += AllTrim( mkb10->name ) + " "
                Skip
              Enddo
              j1 := perenos( t_arr1, s, len_name + 11 )
              If verify_ff( HH - j1, .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              ls1 := PadR( t_arr1[ 1 ], len_name + 11 ) + ;
                PadC( AllTrim( tmp_d->diagnoz ), 12 )
              ls1 += put_val( tmp_d->p_boln, 7 ) + ;
                put_val( tmp_d->p_ekst, 7 ) + ;
                put_val( tmp_d->p_skor, 7 )
              If x == 3
                ls1 += put_val( tmp_d->p_bdo1, 7 )
              Endif
              ls1 += put_val( tmp_d->p_kd,8 )
              If x == 3
                ls1 += put_val( tmp_d->p_kd1,7 )
              Endif
              ls1 += put_val( tmp_d->p_umer, 4 ) + ;
                put_val( tmp_d->p_vskr, 4 ) + ;
                put_val( tmp_d->p_rash, 4 )
              If x == 3
                ls1 += Space( 6 ) + put_val( tmp_d->p_udo1, 4 )
              Endif
              add_string( ls1 )
              For i := 2 To j1
                add_string( PadL( AllTrim( t_arr1[ i ] ), len_name + 11 ) )
              Next
              Select TMP_D
              Skip
            Enddo
          Endif
        Endif
      Endif
      ft_skip()
    Enddo
  Next
  ft_use()
  //
  arr_title := { ;
    "_____________________________________________________________________________________________________", ;
    "                                        │     │            │_____до_1000_г______│_____1000_г_и_более_", ;
    "                                        │  №  │            │Посту-│из них умерло│Посту-│из них умерло", ;
    "    Наименование заболеваний            │стро-│   Код по   │пило  ├──────┬──────│пило  ├──────┬──────", ;
    "                                        │ ки  │   МКБ-10   │пациен│ всего│0-6дн.│пациен│ всего│0-6дн.", ;
    "────────────────────────────────────────┴─────┴────────────┴──────┴──────┴──────┴──────┴──────┴──────" }
  sh := Len( arr_title[ 1 ] )
  len_name := 40
  tek_stroke := HH + 10
  verify_ff( HH, .t., sh )
  add_string( Center( "2. СОСТАВ НОВОРОЖДЕННЫХ С ЗАБОЛЕВАНИЯМИ, ПОСТУПИВШИХ В ВОЗРАСТЕ 0-6 ДНЕЙ ЖИЗНИ,", sh ) )
  add_string( Center( "И ИСХОДЫ ИХ ЛЕЧЕНИЯ", sh ) )
  add_string( "" )
  add_string( "(3000)" + PadL( "Код по ОКЕИ: человек - 792", sh - 6 ) )
  AEval( arr_title, {| x| add_string( x ) } )
  For k := 1 To Len( arr_3000 )
    s1_ := arr_3000[ k, 2 ] ; s1 := PadR( s1_, 9 )
    If iif( is_diag, !( "." $ s1_ ), .t. )
      Select TMP_3000
      find ( s1 )
      If Found() .and. iif( is_diag, !emptyall( tmp_3000->p_boln, tmp_3000->p1boln ), .t. )
        t_arr1 := Array( 12 ) ; t_arr2 := Array( 12 )
        AFill( t_arr1, "" )    ; AFill( t_arr2, "" )
        j1 := perenos( t_arr1, arr_3000[ k, 1 ], len_name )
        j2 := perenos( t_arr2, arr_3000[ k, 3 ], 12, "," )
        If verify_ff( HH - Max( j1, j2 ), .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        ls1 := PadR( t_arr1[ 1 ], len_name ) + ;
          PadC( s1_, 7 ) + ;
          PadC( AllTrim( t_arr2[ 1 ] ), 12 )
        ls1 += put_val( tmp_3000->p_boln, 7 ) + ;
          put_val( tmp_3000->p_umer, 7 ) + ;
          put_val( tmp_3000->p_umer6, 7 )
        ls1 += put_val( tmp_3000->p1boln, 7 ) + ;
          put_val( tmp_3000->p1umer, 7 ) + ;
          put_val( tmp_3000->p1umer6, 7 )
        If is_diag .and. !( s1_ == "1" )
          add_string( Replicate( "-", sh ) )
        Endif
        add_string( ls1 )
        For i := 2 To Max( j1, j2 )
          ls2 := PadL( AllTrim( t_arr1[ i ] ), len_name ) + ;
            Space( 7 ) + ;
            PadC( AllTrim( t_arr2[ i ] ), 12 )
          add_string( ls2 )
        Next
        If iif( is_diag, !( s1_ == "1" ), .t. )
          add_string( Replicate( "-", sh ) )
        Endif
        If is_diag
          Select TMP_D3
          find ( s1 )
          Do While tmp_d3->stroke == s1 .and. !Eof()
            Select MKB10
            find ( tmp_d3->diagnoz )
            s := AllTrim( mkb10->name ) + " "
            Skip
            Do While mkb10->shifr == tmp_d3->diagnoz .and. mkb10->ks > 0 ;
                .and. !Eof()
              s += AllTrim( mkb10->name ) + " "
              Skip
            Enddo
            j1 := perenos( t_arr1, s, len_name + 7 )
            If verify_ff( HH - j1, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            ls1 := PadR( t_arr1[ 1 ], len_name + 7 ) + ;
              PadC( AllTrim( tmp_d3->diagnoz ), 12 )
            ls1 += put_val( tmp_d3->p_boln, 7 ) + ;
              put_val( tmp_d3->p_umer, 7 ) + ;
              put_val( tmp_d3->p_umer6, 7 )
            ls1 += put_val( tmp_d3->p1boln, 7 ) + ;
              put_val( tmp_d3->p1umer, 7 ) + ;
              put_val( tmp_d3->p1umer6, 7 )
            add_string( ls1 )
            For i := 2 To j1
              add_string( PadL( AllTrim( t_arr1[ i ] ), len_name + 7 ) )
            Next
            Select TMP_D3
            Skip
          Enddo
        Endif
      Endif
    Endif
  Next
  //
  use_base( "luslf" )
  arr_title := { ;
    "────────────────────────────────────────┬─────────┬──────┬───────────────────────────┬──────┬───────────────────────────┬──────", ;
    "                                        │         │Число │          из них     старше│Умерло│          из них     старше│Злока-", ;
    "    Наименование операции               │ № строки│опера-├──────┬──────┬──────┐труд. │опери-├──────┬──────┬──────┐труд. │честв.", ;
    "                                        │         │ций   │0-14л.│до1год│15-17л│возрас│рован.│0-14л.│до1год│15-17л│возрас│образ.", ;
    "────────────────────────────────────────┼─────────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────", ;
    "                 1                      │    2    │  3   │  4   │  5   │  6   │3/4001│  19  │  20  │  21  │  22  │7/4001│  27  ", ;
    "────────────────────────────────────────┴─────────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────" }
  sh := Len( arr_title[ 1 ] )
  len_name := 40
  tek_stroke := HH + 10
  verify_ff( HH, .t., sh )
  add_string( Center( "3. ХИРУРГИЧЕСКАЯ РАБОТА ОРГАНИЗАЦИИ", sh ) )
  add_string( "" )
  add_string( "(4000)" + PadL( "Код по ОКЕИ: единица - 642", sh - 6 ) )
  AEval( arr_title, {| x| add_string( x ) } )
  For k := 1 To Len( arr_4000 )
    s1_ := arr_4000[ k, 2 ] ; s1 := PadR( s1_, 9 )
    If iif( is_diag, !( "." $ s1_ ), .t. )
      Select TMP_4000
      find ( s1 )
      If Found() .and. iif( is_diag, !Empty( tmp_4000->p_boln ), .t. )
        t_arr1 := Array( 12 )
        AFill( t_arr1, "" )
        j1 := perenos( t_arr1, arr_4000[ k, 1 ], len_name )
        If verify_ff( HH - j1, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        ls1 := PadR( t_arr1[ 1 ], len_name ) + ;
          PadC( s1_, 11 )
        ls1 += put_val( tmp_4000->p_boln, 6 ) + ;
          put_val( tmp_4000->p_boln1, 7 ) + ;
          put_val( tmp_4000->p_boln2, 7 ) + ;
          put_val( tmp_4000->p_boln3, 7 ) + ;
          put_val( tmp_4000->p_boln4, 7 ) + ;
          put_val( tmp_4000->p_umer, 7 ) + ;
          put_val( tmp_4000->p_umer1, 7 ) + ;
          put_val( tmp_4000->p_umer2, 7 ) + ;
          put_val( tmp_4000->p_umer3, 7 ) + ;
          put_val( tmp_4000->p_umer4, 7 ) + ;
          put_val( tmp_4000->p_onko, 7 )
        If is_diag .and. !( s1_ == "1" )
          add_string( Replicate( "-", sh ) )
        Endif
        add_string( ls1 )
        For i := 2 To j1
          ls2 := PadL( AllTrim( t_arr1[ i ] ), len_name )
          add_string( ls2 )
        Next
        If iif( is_diag, !( s1_ == "1" ), .t. )
          add_string( Replicate( "-", sh ) )
        Endif
        If is_diag
          Select TMP_D4
          find ( s1 )
          Do While tmp_d4->stroke == s1 .and. !Eof()
            If arr_m[ 1 ] > 2018
              Select luslf
              find ( tmp_d4->shifr )
              s := AllTrim( tmp_d4->shifr ) + ' ' + AllTrim( luslf->name )
            Elseif LUSLF18->( Used() )
              Select luslf18
              find ( tmp_d4->shifr )
              s := AllTrim( tmp_d4->shifr ) + ' ' + AllTrim( luslf18->name )
            Endif
            j1 := perenos( t_arr1, s, len_name + 11 )
            If verify_ff( HH - j1, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            ls1 := PadR( t_arr1[ 1 ], len_name + 11 )
            ls1 += put_val( tmp_d4->p_boln, 6 ) + ;
              put_val( tmp_d4->p_boln1, 7 ) + ;
              put_val( tmp_d4->p_boln2, 7 ) + ;
              put_val( tmp_d4->p_boln3, 7 ) + ;
              put_val( tmp_d4->p_boln4, 7 ) + ;
              put_val( tmp_d4->p_umer, 7 ) + ;
              put_val( tmp_d4->p_umer1, 7 ) + ;
              put_val( tmp_d4->p_umer2, 7 ) + ;
              put_val( tmp_d4->p_umer3, 7 ) + ;
              put_val( tmp_d4->p_umer4, 7 ) + ;
              put_val( tmp_d4->p_onko, 7 )
            add_string( ls1 )
            For i := 2 To j1
              add_string( PadL( AllTrim( t_arr1[ i ] ), len_name + 11 ) )
            Next
            Select TMP_D4
            Skip
          Enddo
        Endif
      Endif
    Endif
  Next
  //
  If yes_vmp
    arr_title := { ;
      "────────────────────────────────────────┬─────────┬──────┬───────────────────────────┬──────┬───────────────────────────", ;
      "                                        │         │Число │          из них     старше│Умерло│          из них     старше", ;
      "    Наименование операции               │ № строки│операц├──────┬──────┬──────┐труд. │опери-├──────┬──────┬──────┐труд. ", ;
      "                                        │         │ий ВМТ│0-14л.│до1год│15-17л│возрас│рован.│0-14л.│до1год│15-17л│возрас", ;
      "────────────────────────────────────────┼─────────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────", ;
      "                 1                      │    2    │   7  │   8  │   9  │  10  │4/4001│  23  │  24  │  25  │  26  │8/4001", ;
      "────────────────────────────────────────┴─────────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────" }
    sh := Len( arr_title[ 1 ] )
    len_name := 40
    tek_stroke := HH + 10
    verify_ff( HH, .t., sh )
    add_string( Center( "3. ХИРУРГИЧЕСКАЯ РАБОТА ОРГАНИЗАЦИИ - с применением ВМТ", sh ) )
    add_string( "" )
    add_string( "(4000)" + PadL( "Код по ОКЕИ: единица - 642", sh - 6 ) )
    AEval( arr_title, {| x| add_string( x ) } )
    For k := 1 To Len( arr_4000 )
      s1_ := arr_4000[ k, 2 ] ; s1 := PadR( s1_, 9 )
      If iif( is_diag, !( "." $ s1_ ), .t. )
        Select TMP_4000
        find ( s1 )
        If Found() .and. !Empty( tmp_4000->_p_boln )
          t_arr1 := Array( 12 )
          AFill( t_arr1, "" )
          j1 := perenos( t_arr1, arr_4000[ k, 1 ], len_name )
          If verify_ff( HH - j1, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          ls1 := PadR( t_arr1[ 1 ], len_name ) + ;
            PadC( s1_, 11 )
          ls1 += put_val( tmp_4000->_p_boln, 6 ) + ;
            put_val( tmp_4000->_p_boln1, 7 ) + ;
            put_val( tmp_4000->_p_boln2, 7 ) + ;
            put_val( tmp_4000->_p_boln3, 7 ) + ;
            put_val( tmp_4000->_p_boln4, 7 ) + ;
            put_val( tmp_4000->_p_umer, 7 ) + ;
            put_val( tmp_4000->_p_umer1, 7 ) + ;
            put_val( tmp_4000->_p_umer2, 7 ) + ;
            put_val( tmp_4000->_p_umer3, 7 ) + ;
            put_val( tmp_4000->_p_umer4, 7 )
          If is_diag .and. !( s1_ == "1" )
            add_string( Replicate( "-", sh ) )
          Endif
          add_string( ls1 )
          For i := 2 To Max( j1, j2 )
            ls2 := PadL( AllTrim( t_arr1[ i ] ), len_name )
            add_string( ls2 )
          Next
          If iif( is_diag, !( s1_ == "1" ), .t. )
            add_string( Replicate( "-", sh ) )
          Endif
          If is_diag
            Select TMP_D4
            find ( s1 )
            Do While tmp_d4->stroke == s1 .and. !Eof()
              If !Empty( tmp_d4->_p_boln )
                If arr_m[ 1 ] > 2018
                  Select luslf
                  find ( tmp_d4->shifr )
                  s := AllTrim( tmp_d4->shifr ) + " " + AllTrim( luslf->name )
                Elseif LUSLF18->( Used() )
                  Select luslf18
                  find ( tmp_d4->shifr )
                  s := AllTrim( tmp_d4->shifr ) + " " + AllTrim( luslf18->name )
                Endif
                j1 := perenos( t_arr1, s, len_name + 11 )
                If verify_ff( HH - j1, .t., sh )
                  AEval( arr_title, {| x| add_string( x ) } )
                Endif
                ls1 := PadR( t_arr1[ 1 ], len_name + 11 )
                ls1 += put_val( tmp_d4->_p_boln, 6 ) + ;
                  put_val( tmp_d4->_p_boln1, 7 ) + ;
                  put_val( tmp_d4->_p_boln2, 7 ) + ;
                  put_val( tmp_d4->_p_boln3, 7 ) + ;
                  put_val( tmp_d4->_p_boln4, 7 ) + ;
                  put_val( tmp_d4->_p_umer, 7 ) + ;
                  put_val( tmp_d4->_p_umer1, 7 ) + ;
                  put_val( tmp_d4->_p_umer2, 7 ) + ;
                  put_val( tmp_d4->_p_umer3, 7 ) + ;
                  put_val( tmp_d4->_p_umer4, 7 )
                add_string( ls1 )
                For i := 2 To j1
                  add_string( PadL( AllTrim( t_arr1[ i ] ), len_name + 11 ) )
                Next
              Endif
              Select TMP_D4
              Skip
            Enddo
          Endif
        Endif
      Endif
    Next
  Endif
  //
  arr_title := { ;
    "___________________________________________________________________________________________________________________________", ;
    "                                        │     │            │_____Выписано_пациентов_(из_таб.2000_гр.4_и_гр.22)_в_возрасте__", ;
    "                                        │  №  │            │ 0 │ 15│ 20│ 25│ 30│ 35│ 40│ 45│ 50│ 55│ 60│ 65│ 70│ 75│ 80│ 85", ;
    "    Наименование заболеваний            │стро-│   Код по   │ 14│ 19│ 24│ 29│ 34│ 39│ 44│ 49│ 54│ 59│ 64│ 69│ 74│ 79│ 84│...", ;
    "                                        │ ки  │   МКБ-10   │лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет", ;
    "────────────────────────────────────────┴─────┴────────────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───" }
  sh := Len( arr_title[ 1 ] )
  len_name := 40
  tek_stroke := HH + 10
  verify_ff( HH, .t., sh )
  add_string( Center( "2. СВЕДЕНИЯ О ЧИСЛЕ ВЫБЫВШИХ ИЗ СТАЦИОНАРА ПО ВОЗРАСТУ ПАЦИЕНТА, человек", sh ) )
  add_string( "" )
  add_string( "(2910)" + PadL( "Код по ОКЕИ: человек - 792", sh - 6 ) )
  AEval( arr_title, {| x| add_string( x ) } )
  For k := 1 To Len( arr_2910 )
    s1_ := arr_2910[ k, 2 ] ; s1 := PadR( s1_, 9 )
    If iif( is_diag, !( "." $ s1_ ), .t. )
      Select TMP_2910
      find ( s1 )
      If Found() // .and. iif(is_diag, !emptyall(tmp_2910->p_boln,tmp_2910->p1boln), .t.)
        t_arr1 := Array( 12 ) ; t_arr2 := Array( 12 )
        AFill( t_arr1, "" )    ; AFill( t_arr2, "" )
        j1 := perenos( t_arr1, arr_2910[ k, 1 ], len_name )
        j2 := perenos( t_arr2, arr_2910[ k, 3 ], 12, "," )
        If verify_ff( HH - Max( j1, j2 ), .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        ls1 := PadR( t_arr1[ 1 ], len_name ) + ;
          PadC( s1_, 7 ) + ;
          PadC( AllTrim( t_arr2[ 1 ] ), 12 )
        ls1 += put_val( tmp_2910->vip_0_14, 4 ) + ;
          put_val( tmp_2910->vip_15_19, 4 ) + ;
          put_val( tmp_2910->vip_20_24, 4 )
        ls1 += put_val( tmp_2910->vip_25_29, 4 ) + ;
          put_val( tmp_2910->vip_30_34, 4 ) + ;
          put_val( tmp_2910->vip_35_39, 4 )
        ls1 += put_val( tmp_2910->vip_40_44, 4 ) + ;
          put_val( tmp_2910->vip_45_49, 4 ) + ;
          put_val( tmp_2910->vip_50_54, 4 )
        ls1 += put_val( tmp_2910->vip_55_59, 4 ) + ;
          put_val( tmp_2910->vip_60_64, 4 ) + ;
          put_val( tmp_2910->vip_65_69, 4 )
        ls1 += put_val( tmp_2910->vip_70_74, 4 ) + ;
          put_val( tmp_2910->vip_75_79, 4 ) + ;
          put_val( tmp_2910->vip_80_84, 4 ) + ;
          put_val( tmp_2910->vip_85_99, 4 )
        If is_diag .and. !( s1_ == "1" )
          add_string( Replicate( "-", sh ) )
        Endif
        add_string( ls1 )
        For i := 2 To Max( j1, j2 )
          ls2 := PadL( AllTrim( t_arr1[ i ] ), len_name ) + ;
            Space( 7 ) + ;
            PadC( AllTrim( t_arr2[ i ] ), 12 )
          add_string( ls2 )
        Next
        If iif( is_diag, !( s1_ == "1" ), .t. )
          add_string( Replicate( "-", sh ) )
        Endif
        If is_diag
          Select TMP_D5
          find ( s1 )
          Do While tmp_d5->stroke == s1 .and. !Eof()
            Select MKB10
            find ( tmp_d5->diagnoz )
            s := AllTrim( mkb10->name ) + " "
            Skip
            Do While mkb10->shifr == tmp_d5->diagnoz .and. mkb10->ks > 0 ;
                .and. !Eof()
              s += AllTrim( mkb10->name ) + " "
              Skip
            Enddo
            j1 := perenos( t_arr1, s, len_name + 7 )
            If verify_ff( HH - j1, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            ls1 := PadR( t_arr1[ 1 ], len_name + 7 ) + ;
              PadC( AllTrim( tmp_d5->diagnoz ), 12 )
            ls1 += put_val( tmp_d5->vip_0_14, 4 ) + ;
              put_val( tmp_d5->vip_15_19, 4 ) + ;
              put_val( tmp_d5->vip_20_24, 4 )
            ls1 += put_val( tmp_d5->vip_25_29, 4 ) + ;
              put_val( tmp_d5->vip_30_34, 4 ) + ;
              put_val( tmp_d5->vip_35_39, 4 )
            ls1 += put_val( tmp_d5->vip_40_44, 4 ) + ;
              put_val( tmp_d5->vip_45_49, 4 ) + ;
              put_val( tmp_d5->vip_50_54, 4 )
            ls1 += put_val( tmp_d5->vip_55_59, 4 ) + ;
              put_val( tmp_d5->vip_60_64, 4 ) + ;
              put_val( tmp_d5->vip_65_69, 4 )
            ls1 += put_val( tmp_d5->vip_70_74, 4 ) + ;
              put_val( tmp_d5->vip_75_79, 4 ) + ;
              put_val( tmp_d5->vip_80_84, 4 ) + ;
              put_val( tmp_d5->vip_85_99, 4 )
            add_string( ls1 )
            For i := 2 To j1
              add_string( PadL( AllTrim( t_arr1[ i ] ), len_name + 7 ) )
            Next
            Select TMP_D5
            Skip
          Enddo
        Endif
      Endif
    Endif
  Next
  //
  arr_title := { ;
    "___________________________________________________________________________________________________________________________", ;
    "                                        │     │            │_____Умерло_пациентов_(из_таб.2000_гр.4_и_гр.22)_в_возрасте____", ;
    "                                        │  №  │            │ 0 │ 15│ 20│ 25│ 30│ 35│ 40│ 45│ 50│ 55│ 60│ 65│ 70│ 75│ 80│ 85", ;
    "    Наименование заболеваний            │стро-│   Код по   │ 14│ 19│ 24│ 29│ 34│ 39│ 44│ 49│ 54│ 59│ 64│ 69│ 74│ 79│ 84│...", ;
    "                                        │ ки  │   МКБ-10   │лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет", ;
    "────────────────────────────────────────┴─────┴────────────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───" }
  sh := Len( arr_title[ 1 ] )
  len_name := 40
  tek_stroke := HH + 10
  verify_ff( HH, .t., sh )
  // add_string(center("2. СВЕДЕНИЯ О ЧИСЛЕ ВЫБЫВШИХ ИЗ СТАЦИОНАРА ПО ВОЗРАСТУ ПАЦИЕНТА, человек",sh))
  add_string( "" )
  // add_string("(2910)"+padl("Код по ОКЕИ: человек - 792",sh-6))
  AEval( arr_title, {| x| add_string( x ) } )
  For k := 1 To Len( arr_2910 )
    s1_ := arr_2910[ k, 2 ] ; s1 := PadR( s1_, 9 )
    If iif( is_diag, !( "." $ s1_ ), .t. )
      Select TMP_2910
      find ( s1 )
      If Found() // .and. iif(is_diag, !emptyall(tmp_2910->p_boln,tmp_2910->p1boln), .t.)
        t_arr1 := Array( 12 ) ; t_arr2 := Array( 12 )
        AFill( t_arr1, "" )    ; AFill( t_arr2, "" )
        j1 := perenos( t_arr1, arr_2910[ k, 1 ], len_name )
        j2 := perenos( t_arr2, arr_2910[ k, 3 ], 12, "," )
        If verify_ff( HH - Max( j1, j2 ), .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        ls1 := PadR( t_arr1[ 1 ], len_name ) + ;
          PadC( s1_, 7 ) + ;
          PadC( AllTrim( t_arr2[ 1 ] ), 12 )
        ls1 += put_val( tmp_2910->umer_0_14, 4 ) + ;
          put_val( tmp_2910->umer_15_19, 4 ) + ;
          put_val( tmp_2910->umer_20_24, 4 )
        ls1 += put_val( tmp_2910->umer_25_29, 4 ) + ;
          put_val( tmp_2910->umer_30_34, 4 ) + ;
          put_val( tmp_2910->umer_35_39, 4 )
        ls1 += put_val( tmp_2910->umer_40_44, 4 ) + ;
          put_val( tmp_2910->umer_45_49, 4 ) + ;
          put_val( tmp_2910->umer_50_54, 4 )
        ls1 += put_val( tmp_2910->umer_55_59, 4 ) + ;
          put_val( tmp_2910->umer_60_64, 4 ) + ;
          put_val( tmp_2910->umer_65_69, 4 )
        ls1 += put_val( tmp_2910->umer_70_74, 4 ) + ;
          put_val( tmp_2910->umer_75_79, 4 ) + ;
          put_val( tmp_2910->umer_80_84, 4 ) + ;
          put_val( tmp_2910->umer_85_99, 4 )

        If is_diag .and. !( s1_ == "1" )
          add_string( Replicate( "-", sh ) )
        Endif
        add_string( ls1 )
        For i := 2 To Max( j1, j2 )
          ls2 := PadL( AllTrim( t_arr1[ i ] ), len_name ) + ;
            Space( 7 ) + ;
            PadC( AllTrim( t_arr2[ i ] ), 12 )
          add_string( ls2 )
        Next
        If iif( is_diag, !( s1_ == "1" ), .t. )
          add_string( Replicate( "-", sh ) )
        Endif
        If is_diag
          Select TMP_D5
          find ( s1 )
          Do While tmp_d5->stroke == s1 .and. !Eof()
            Select MKB10
            find ( tmp_d5->diagnoz )
            s := AllTrim( mkb10->name ) + " "
            Skip
            Do While mkb10->shifr == tmp_d5->diagnoz .and. mkb10->ks > 0 ;
                .and. !Eof()
              s += AllTrim( mkb10->name ) + " "
              Skip
            Enddo
            j1 := perenos( t_arr1, s, len_name + 7 )
            If verify_ff( HH - j1, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            ls1 := PadR( t_arr1[ 1 ], len_name + 7 ) + ;
              PadC( AllTrim( tmp_d5->diagnoz ), 12 )
            ls1 += put_val( tmp_d5->umer_0_14, 4 ) + ;
              put_val( tmp_d5->umer_15_19, 4 ) + ;
              put_val( tmp_d5->umer_20_24, 4 )
            ls1 += put_val( tmp_d5->umer_25_29, 4 ) + ;
              put_val( tmp_d5->umer_30_34, 4 ) + ;
              put_val( tmp_d5->umer_35_39, 4 )
            ls1 += put_val( tmp_d5->umer_40_44, 4 ) + ;
              put_val( tmp_d5->umer_45_49, 4 ) + ;
              put_val( tmp_d5->umer_50_54, 4 )
            ls1 += put_val( tmp_d5->umer_55_59, 4 ) + ;
              put_val( tmp_d5->umer_60_64, 4 ) + ;
              put_val( tmp_d5->umer_65_69, 4 )
            ls1 += put_val( tmp_d5->umer_70_74, 4 ) + ;
              put_val( tmp_d5->umer_75_79, 4 ) + ;
              put_val( tmp_d5->umer_80_84, 4 ) + ;
              put_val( tmp_d5->umer_85_99, 4 )

            add_string( ls1 )
            For i := 2 To j1
              add_string( PadL( AllTrim( t_arr1[ i ] ), len_name + 7 ) )
            Next
            Select TMP_D5
            Skip
          Enddo
        Endif
      Endif
    Endif
  Next
  /*if arr_perevod[5]+arr_perevod[6]+arr_perevod[9]+arr_perevod[10] > 0
    add_string(replicate("=",sh))
    ls1 := padr("Кроме того, больные переведенные в другие стационары:",len_name+22)
    ls1 += put_val(arr_perevod[4],6)+space(2)+;
           put_val(arr_perevod[5],8)+;
           put_val(arr_perevod[6],6)+space(2)+space(2)+;
           put_val(arr_perevod[7],6)+;
           put_val(arr_perevod[8],6)+;
           put_val(arr_perevod[9],8)+;
           put_val(arr_perevod[10],6)+space(3)+space(3)+;
           put_val(arr_perevod[11],6)
    add_string(ls1)
  endif*/
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( name_file,,,, .t.,,, reg_print )

  Return Nil

// 16.01.23
Function f14_arr_2910()

  Static arr := { ;
    { "сахарный диабет (из стр. 5.4)", "1", "E10-E11,E13-E14" }, ;
    { "болезни, характеризующиеся\повышенным кровяным давлением (из стр.10.3)", "2", "I10,I11.9,I12.9,I13.9" }, ;
    { "хроническая ишемическая\болезнь сердца (стр. 10.4.5)", "3", "I25" }, ;
    { "бронхит хронический и\неуточненный, эмфизема (стр. 11.7)", "4", "J40-J43" }, ;
    { "другая хроническая\обструктивная легочная\болезнь (стр.11.8)", "5", "J44" }, ;
    { "бронхоэктатическая болезнь (стр. 11.9)", "6", "J47" }, ;
    { "астма, астматический статус (стр. 11.10)", "7", "J45,J46" };
    }

  Return arr

// 02.01.16
Function f14_arr_3000()

  Static arr := { ;
    { "Всего новорожденных, в том числе с заболеваниями:", "1", "" }, ;
    { "острые респираторные инфекции верхних дыхательных путей, грипп", "2", "J00-J06,J10-J11" }, ;
    { "пневмонии", "3", "J12-J18" }, ;
    { "инфекции кожи и подкожной клетчатки", "4", "L00-L08" }, ;
    { "отдельные состояния, возникающие в перинатальном периоде", "5", "P00-P96" }, ;
    { "из них: замедленный рост и недостаточность питания", "5.1", "P05" }, ;
    { "родовая травма - всего", "5.2", "P10-P15" }, ;
    { "в т.ч. разрыв внутричерепных тканей и кровоизлияние вследствие родовой травмы", "5.2.1", "P10" }, ;
    { "дыхательные нарушения, характерные для перинатального периода, - всего", "5.3", "P20-P28" }, ;
    { "из них: внутриутробная гипоксия, асфиксия при родах", "5.3.1", "P20,P21" }, ;
    { "дыхательное расстройство у новорожденных", "5.3.2", "P22" }, ;
    { "врожденная пневмония", "5.3.3", "P23" }, ;
    { "неонатальные аспирационные синдромы", "5.3.4", "P24" }, ;
    { "инфекционные болезни, специфичные для перинатального периода, - всего", "5.4", "P35-P39" }, ;
    { "из них бактериальный сепсис новорожденного", "5.4.1", "P36" }, ;
    { "гемолитическая болезнь плода и новорожденного, водянка плода, обусловленная гемолитической болезнью, ядерная желтуха", "5.5", "P55-P57" }, ;
    { "неонатальная желтуха, обусловленная чрезмерным гемолизом, другими и неуточненными причинами", "5.6", "P58-P59" }, ;
    { "геморрагическая болезнь, диссеминированное внутрисосудистое свертывание у плода и новорожденного, другие перинатальные гематологические нарушения", "5.7", "P53,P60,P61" }, ;
    { "врожденные аномалии (пороки развития), деформации и хромосомные нарушения", "6", "Q00-Q99" }, ;
    { "прочие болезни", "7", "U07.1,U07.2" }, ;
    { "прочие болезни", "8", "" };
    }

  Return arr

// 20.01.23
Function f14_arr_4000()

  Static arr := { ;
    { "Всего операций", "1", "" }, ;
    { "в том числе: операции на нервной системе", "2", "23,24" }, ;
    { "удаление травматической внутричерепной гематомы,очага ушиба, вдавленного перелома черепа, устранение дефекта черепа и лицевого скилета", "2.1", "" }, ;
    { "операции при сосудистых пороках мозга", "2.2", "" }, ;
    { "из них: на аневризмах", "2.2.1", "" }, ;
    { "  из них: эндоваскулярное выключение", "2.2.1.1", "" }, ;
    { "на мальформациях", "2.2.2", "" }, ;
    { "  из них: эндоваскулярное выключение", "2.2.2.1", "" }, ;
    { "операции при церебральном инсульте", "2.3", "" }, ;
    { "из них: при геморрагическом инсульте", "2.3.1", "" }, ;
    { "  из них: открытое удаление гематомы", "2.3.1.1", "" }, ;
    { "при инфаркте мозга", "2.3.2", "" }, ;
    { "  из них: краниотомия", "2.3.2.1", "" }, ;
    { "  эндоваскулярная тромбоэкстракция", "2.3.2.2", "" }, ;
    { "операции при окклюзионно-стенотических поражениях сосудов мозга", "2.4", "" }, ;
    { "из них: на экстрацеребральных отделах сонных и позвоночных артерий", "2.4.1", "" }, ;
    { "  из них: эндартерэктомия, редрессация, реимплантация", "2.4.1.1", "" }, ;
    { "  стентирование", "2.4.1.2", "" }, ;
    { "на внутричерепных артериях", "2.4.2", "" }, ;
    { "  из них: экстраинтракраниальные анастомозы", "2.4.2.1", "" }, ;
    { "  стентирование", "2.4.2.2", "" }, ;
    { "удаление опухолей головного, спинного мозга", "2.5", "" }, ;
    { "операции при функциональных расстройствах", "2.6", "" }, ;
    { "из них: при болевых синдромах", "2.6.1", "" }, ;
    { "  из них васкулярная декомпрессия", "2.6.1.1", "" }, ;
    { "при эпилепсии, паркинсонизме, мышечно-тонических расстройствах", "2.6.2", "" }, ;
    { "  из них: резекционные и деструктивные операции", "2.6.2.1", "" }, ;
    { "  установка стимуляторов", "2.6.2.2", "" }, ;
    { "декомпрессивные, стабилизирующие операции при позвоночно-спинальной травме", "2.7", "" }, ;
    { "декомпрессивные, стабилизирующие операции при дегенеративных заболеваниях позвоничника", "2.8", "" }, ;
    { "операции на периферических нервах", "2.9", "" }, ;
    { "ликворошунтирующие операции", "2.10", "" }, ;
    { "операции при врожденных аномалиях развития центральной нервной системы", "2.11", "" }, ;
    { "операции на эндокринной системе", "3", "22" }, ;
    { "из них тиреотомии", "3.1", "22.001-22.003" }, ;
    { "операции на органе зрения", "4", "26" }, ;
    { "из них: кератопластика", "4.1", "26.049" }, ;
    { "задняя витреоэктомия", "4.2", "26.089" }, ;
    { "транпупиллярная термотерапия", "4.3", "" }, ;
    { "брахитерапия", "4.4", "" }, ;
    { "операции по поводу: глаукомы", "4.5", "26.112,26.118" }, ;
    { "из них: с применением шунтов и дренажей", "4.5.1", "" }, ;
    { "энуклеации", "4.6", "26.098" }, ;
    { "катаракты", "4.7", "26.092-26.096" }, ;
    { "из них: методом факоэмульсификации", "4.7.1", "26.093" }, ;
    { "интравитреальное введение ингибитора ангиогенеза", "4.8", "26.086" }, ;
    { "операции на органах уха, горла, носа", "5", "08,25,27" }, ;
    { "из них: на ухе", "5.1", "25" }, ;
    { "на миндалинах и аденоидах", "5.2", "08.016,08.002" }, ;
    { "операции на органах дыхания", "6", "09" }, ;
    { "из них: на трахее", "6.1", "09.009.005,09.014.003,09.023" }, ;
    { "пневмонэктомия", "6.2", "09.009.003,09.014,09.015.002,09.016.003,09.025" }, ;
    { "эксплоративная торакотомия", "6.3", "09.006" }, ;
    { "операции на сердце", "7", "10,12.004.008-12.004.009" }, ;
    { "из них на открытом сердце", "7.1", "10.002,10.018" }, ;
    { "из них с искусственным кровообращением", "7.1.2", "" }, ;
    { "коррекция врожденных пороков сердца", "7.2", "" }, ;
    { "коррекция приобретенных поражений клапанов сердца", "7.3", "" }, ;
    { "из них с искусственным кровообращением", "7.3.1", "" }, ; 
    { "'эндоваскулярно", "7.3.2", "" }, ; 
    { "при нарушении ритма - всего", "7.4", "10.014" }, ;
    { "из них: имплантация кардиостимулятора", "7.4.1", "10.014" }, ;
    { "из них: трехкамерных", "7.4.1.1", "" }, ;
    { "коррекция тахиаритмий", "7.4.2", "" }, ;
    { "из них: катетерных аблаций", "7.4.2.1", "" }, ;
    { "имплантированных кардиовертеров-дефибриляторов (ИКД)", "7.4.3", "" }, ;
    { "из них: трехкамерных ИКД", "7.4.3.1", "" }, ; 
    { "по поводу ишемических болезней сердца", "7.5", "10.031-10.032" }, ;
    { "из них: аортокоронарное шунтирование", "7.5.1", "10.031.008" }, ;
    { "из них с искусственным кровообращением", "7.5.1.1", "" }, ;  
    { "малоинвазивная реваскуляризация миокарда (МИРМ)", "7.5.1.2", "" }, ; 
    { "ангиопластика коронарных артерий", "7.5.2", "12.004.008-12.004.009" }, ;
    { "из них со стентированием", "7.5.2.1", "12.004.009" }, ;
    { "операции на сосудах", "8", "12", "12.004.008-12.004.009" }, ;
    { "из них: операции на артериях", "8.1", "12.001,12.003-12.005,12.008,12.026,12.048,12.049" }, ;
    { "из них на питающих головной мозг", "8.1.1", "12.026,12.048,12.049,12.008.001,12.008.002" }, ;
    { "из них: каротидные эндартерэктомии", "8.1.1.1", "12.008.001,12.008.002" }, ;
    { "экстраинтракраниальные анастемозы", "8.1.1.2", "12.048,12.049" }, ;
    { "рентгенэндоваскулярные дилятации", "8.1.1.3", "12.026" }, ;
    { "из них со стентированием", "8.1.1.3.1", "12.026.003-12.026.007" }, ;
    { "на почечных артериях", "8.1.2", "12.008.006,12.011.003,12.011.007,12.054.002" }, ;
    { "на аорте", "8.1.3", "12.008.005,12.011.002,12.011.004,12.025,12.044,12.055.001,12.056" }, ;
    { "из них: при аневризмах и расслоениях восходященго отдела аорты", "8.1.3.1", "" }, ;
    { "операции на венах", "8.2", "12.002,12.006,12.012,12.015,12.016,12.027,12.035,12.036,12.039,12.040" }, ;
    { "операции на органах брюшной полости", "9", "14,15,16,17,18,19,30.001-30.013", "16.001-16.009,16.012" }, ;
    { "из них: на желудке по поводу язвенной болезни", "9.1", "16.013,16.021" }, ;
    { "аппендэктомии при хроническом аппендиците", "9.2", "18.009-18.010" }, ;
    { "грыжеиссечение при неущемленной грыже", "9.3", "30.001-30.005" }, ;
    { "холецистэктомия при хроническом холецистите", "9.4", "14.006" }, ;
    { "лапаротомия диагностическая", "9.5", "30.006.002" }, ;
    { "на кишечнике", "9.6", "17,18,19,30.013" }, ;
    { "из них: на прямой кишке", "9.6.1", "19", "19.013,19.016" }, ;
    { "по поводу геморроя", "9.7", "19.013,19.016" }, ;
    { "операции на почках и мочеточниках", "10", "28" }, ;
    { "операции на мужских половых органах", "11", "21", "21.026" }, ;
    { "из них операции на предстательной железе", "11.1", "21.001-21.006" }, ;
    { "операции по поводу стерилизации мужчин", "12", "21.026" }, ;
    { "операции на женских половых органах", "13", "20.001-20.069", "20.031,20.032,20.037" }, ;
    { "из них: экстирпация и надвлагалищная ампутация матки", "13.1", "20.010-20.014,20.063" }, ;
    { "на придатках матки по поводу бесплодия", "13.2", "20.038" }, ;
    { "на яичниках по поводу новообразований", "13.3", "20.001" }, ;
    { "по поводу стерилизации женщин", "13.4", "20.041" }, ;
    { "выскабливание матки (кроме аборта)", "13.5", "" }, ;
    { "акушерские операции", "14", "20.070-20.083,20.037" }, ;
    { "из них: по поводу внематочной беременности", "14.1", "" }, ;
    { "наложение щипцов", "14.2", "20.070" }, ;
    { "вакуум-экстракция", "14.3", "20.071" }, ;
    { "кесарево сечение в сроке 22 недель беременности и более", "14.4", "" }, ;
    { "кесарево сечение в сроке менее 22 недель беременности", "14.5", "" }, ;
    { "аборт", "14.6", "20.037" }, ;
    { "плодоразрушающие", "14.7", "20.072" }, ;
    { "экстирпация и надвлагалищная ампутация матки в сроке 22 недель беременности и более, в родах и после родов", "14.8", "" }, ;
    { "экстирпация и надвлагалищная ампутация матки при прерывании беременности в сроке менее 22 недель беременности или после прерывания", "14.9", "" }, ;
    { "операции на костно-мышечной системе", "15", "02,03,04" }, ;
    { "из них: корригирующие остеотомии", "15.1", "03.024.001" }, ;
    { "на челюстно-лицевой области", "15.2", "03.053-03.057" }, ;
    { "при травмах костей таза", "15.3", "03.024.002,03.068,03.070,03.071" }, ;
    { "при около- и внутрисуставных переломах", "15.4", "03.026.001,04.004.001" }, ;
    { "на позвоночнике", "15.5", "04.007,04.010,04.029-04.032" }, ;
    { "при врожденном вывихе бедра", "15.6", "" }, ;
    { "ампутации и экзартикуляции", "15.7", "03.071,03.078,03.082,04.023" }, ;
    { "эндопротезирование, всего", "15.8", "03.063.003-03.063.006,03.064.003-03.064.005,04.021,04.026,04.027" }, ;
    { "из него: тазобедренного сустава", "15.8.1", "03.063.003-03.063.004" }, ;
    { "коленного сустава", "15.8.2", "03.063.005-03.063.006" }, ;
    { "на грудной стенке", "15.9", "03.044" }, ;
    { "из них: торакомиопластика", "15.9.1", "03.044" }, ;
    { "торакостомия", "15.9.2", "" }, ;
    { "операции на молочной железе", "16", "20.031,20.032" }, ;
    { "операции на коже и подкожной клетчатке", "17", "01" }, ;
    { "из них: операции на челюстно-лицевой области", "17.1", "01.031.002,01.031.003" }, ;
    { "операции на средостении", "18", "11" }, ;
    { "из них операции на вилочковой железе", "18.1", "" }, ;
    { "операции на пищеводе", "19", "16.001-16.009,16.012" }, ;
    { "операции на лимфатической системе", "20", "13" }, ;
    { "прочие операции", "21", "30" };
    }

  Return arr

//
Function f14_title()

  Local arr := Array( 10 )

  arr[ 1 ] := Replicate( "─", len_name )
  arr[ 2 ] := PadC( "", len_name )
  arr[ 3 ] := PadC( "", len_name )
  arr[ 4 ] := PadC( "", len_name )
  arr[ 5 ] := PadC( "Наименование болезни", len_name )
  arr[ 6 ] := PadC( "", len_name )
  arr[ 7 ] := PadC( "", len_name )
  arr[ 8 ] := Replicate( "─", len_name )
  arr[ 9 ] := PadC( "1", len_name )
  arr[ 10 ] := Replicate( "─", len_name )
  arr[ 1 ] := arr[ 1 ] + "┬─────────┬────────────┬"
  arr[ 2 ] := arr[ 2 ] + "│         │            │"
  arr[ 3 ] := arr[ 3 ] + "│    №    │   Код по   ├"
  arr[ 4 ] := arr[ 4 ] + "│  строки │   МКБ-10   │"
  arr[ 5 ] := arr[ 5 ] + "│         │ пересмотра ├"
  arr[ 6 ] := arr[ 6 ] + "│         │            │"
  arr[ 7 ] := arr[ 7 ] + "│         │            │"
  arr[ 8 ] := arr[ 8 ] + "┼─────────┼────────────┼"
  arr[ 9 ] := arr[ 9 ] + "│    2    │      3     │"
  arr[ 10 ] := arr[ 10 ] + "┴─────────┴────────────┴"
  If x == 1
    arr[ 1 ] := arr[ 1 ] + "──────────────────────────────────────────────"
    arr[ 2 ] := arr[ 2 ] + "          А.Взрослые (18 лет и старше)"
    arr[ 3 ] := arr[ 3 ] + "────────────────────┬───────┬─────────────────"
    arr[ 4 ] := arr[ 4 ] + "  Выписано больных  │Провед.│ Умерло больных"
    arr[ 5 ] := arr[ 5 ] + "──────┬──────┬──────┤выписан├───┬───┬───┬──┬──"
    arr[ 6 ] := arr[ 6 ] + "Всего │достав│достав│койко- │все│пат│уст│см│ус"
    arr[ 7 ] := arr[ 7 ] + "      │экстре│скорой│дней   │го │вск│рас│вс│ра"
    arr[ 8 ] := arr[ 8 ] + "──────┼──────┼──────┼───────┼───┼───┼───┼──┼──"
    arr[ 9 ] := arr[ 9 ] + "  4   │  5   │  6   │   7   │ 8 │ 9 │10 │11│12"
    arr[ 10 ] := arr[ 10 ] + "──────┴──────┴──────┴───────┴───┴───┴───┴──┴──"
  Elseif x == 2
    arr[ 1 ] := arr[ 1 ] + "──────────────────────────────────────────────"
    arr[ 2 ] := arr[ 2 ] + "Б.Взрослые старше трудоспособного возрста     "
    arr[ 3 ] := arr[ 3 ] + "────────────────────┬───────┬─────────────────"
    arr[ 4 ] := arr[ 4 ] + "  Выписано больных  │Провед.│ Умерло больных"
    arr[ 5 ] := arr[ 5 ] + "──────┬──────┬──────┤выписан├───┬───┬───┬──┬──"
    arr[ 6 ] := arr[ 6 ] + "Всего │достав│достав│койко- │все│пат│уст│см│ус"
    arr[ 7 ] := arr[ 7 ] + "      │экстре│скорой│дней   │го │вск│рас│вс│ра"
    arr[ 8 ] := arr[ 8 ] + "──────┼──────┼──────┼───────┼───┼───┼───┼──┼──"
    arr[ 9 ] := arr[ 9 ] + "  13  │  14  │  15  │   16  │17 │18 │19 │20│21"
    arr[ 10 ] := arr[ 10 ] + "──────┴──────┴──────┴───────┴───┴───┴───┴──┴──"
  Elseif x == 3
    arr[ 1 ] := arr[ 1 ] + "────────────────────────────────────────────────────────────────"
    arr[ 2 ] := arr[ 2 ] + "            В.Дети (в возрасте 0-17 лет включительно)"
    arr[ 3 ] := arr[ 3 ] + "───────────────────────────┬───────┬──────┬─────────────────────"
    arr[ 4 ] := arr[ 4 ] + "      Выписано больных     │Провед.│из них│   Умерло больных    "
    arr[ 5 ] := arr[ 5 ] + "──────┬──────┬──────┬──────┤выписан┤в воз-├───┬───┬───┬──┬──┬───"
    arr[ 6 ] := arr[ 6 ] + "Всего │достав│достав│из них│койко- │расте │все│пат│уст│см│ус│до "
    arr[ 7 ] := arr[ 7 ] + "      │экстре│скорой│до 1г.│дней   │до 1 г│го │вск│рас│вс│ра│1г."
    arr[ 8 ] := arr[ 8 ] + "──────┼──────┼──────┼──────┼───────┼──────┼───┼───┼───┼──┼──┼───"
    arr[ 9 ] := arr[ 9 ] + "  22  │  23  │  24  │  25  │   26  │  27  │28 │29 │30 │31│32│33 "
    arr[ 10 ] := arr[ 10 ] + "──────┴──────┴──────┴──────┴───────┴──────┴───┴───┴───┴──┴──┴───"
  Endif

  Return arr

// 14.03.23
Function ret_kd_f14()

  Local lshifr, mkol := 0, i
  Local arrShifr := { '1.12.', '1.13.', '1.14.', '1.15.', '1.16.', '1.17.', '1.18.' }

  For i := 2020 To WORK_YEAR
    AAdd( arrShifr, code_services_vmp( i ) )
  Next

  If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
    lshifr := usl->shifr
  Endif
  If eq_any( Left( lshifr, 4 ), '1.7.', '1.9.' ) .or. Left( lshifr, 5 ) == '1.10.' // законченный случай
    mkol := human->k_data - human->n_data
  Elseif Left( lshifr, 2 ) == '1.'  // остальные койко-дни
    // if !eq_any(left(lshifr, 5), '1.12.', '1.13.', '1.14.', '1.15.', '1.16.*', '1.17.*', '1.18.*', '1.20.*', '1.21.*', '1.22.*')  // 11.02.22
    If AScan( arrShifr, Left( lshifr, 5 ) ) == 0
      mkol := hu->kol
    Endif
  Endif

  Return mkol

// 14.04.21
Function f1_f14( jh, jh1, is_diag )

  Local arr := {}, arr_d := {}, i, j, k, n, lkd := 0, lum, _kd, arr_tip, ;
    M1F14_EKST := 0, M1F14_SKOR := 0, M1F14_VSKR := 0, M1F14_RASH := 0, ;
    mdiag, nkd, mvozrast, mmonth, mday, arr_oper := {}, fl_death := .f., ;
    fl_pensioner := .f., flag_vmp := .f.

  If human_->NOVOR > 0
    count_ymd( human_->DATE_R2, human->n_data, @mvozrast, @mmonth, @mday )
  Else
    count_ymd( human->date_r, human->n_data, @mvozrast, @mmonth, @mday )
  Endif
  If mvozrast < 18
    arr_tip := { 3 }
  Else
    arr_tip := { 1 }
    If human->n_data < SToD( '20200101' )
      If ( human->pol == "Ж" .and. mvozrast >= 55 ) .or. ;
          ( human->pol == "М" .and. mvozrast >= 60 )
        fl_pensioner := .t.
        AAdd( arr_tip, 2 )
      Endif
    Elseif human->n_data < SToD( '20220101' )
      If ( human->pol == "Ж" .and. mvozrast >= 56 ) .or. ;
          ( human->pol == "М" .and. mvozrast >= 61 )
        fl_pensioner := .t.
        AAdd( arr_tip, 2 )
      Endif
    Elseif human->n_data < SToD( '20240101' )
      If ( human->pol == "Ж" .and. mvozrast >= 57 ) .or. ;
          ( human->pol == "М" .and. mvozrast >= 62 )
        fl_pensioner := .t.
        AAdd( arr_tip, 2 )
      Endif
    Elseif human->n_data < SToD( '20260101' )
      If ( human->pol == "Ж" .and. mvozrast >= 58 ) .or. ;
          ( human->pol == "М" .and. mvozrast >= 63 )
        fl_pensioner := .t.
        AAdd( arr_tip, 2 )
      Endif
    Else
      If ( human->pol == "Ж" .and. mvozrast >= 59 ) .or. ;
          ( human->pol == "М" .and. mvozrast >= 64 )
        fl_pensioner := .t.
        AAdd( arr_tip, 2 )
      Endif
    Endif
  Endif
  M1F14_EKST := Int( Val( SubStr( human_->FORMA14, 1, 1 ) ) )
  M1F14_SKOR := Int( Val( SubStr( human_->FORMA14, 2, 1 ) ) )
  M1F14_VSKR := Int( Val( SubStr( human_->FORMA14, 3, 1 ) ) )
  M1F14_RASH := Int( Val( SubStr( human_->FORMA14, 4, 1 ) ) )
  arr := diag_to_array(,,,, .t. )
  If Len( arr ) == 0
    Return jh
  Endif
  mdiag := PadR( arr[ 1 ], 6 ) // только основной диагноз
  If human_2->VMP == 1 // если установили ВМП
    flag_vmp := .t.
  Endif
  lkd := 0
  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    If ( _kd := ret_kd_f14() ) > 0  // проверим все койко-дни
      lkd += _kd
    Endif
    Skip
  Enddo
  If ( nkd := lkd ) > 0
    If Select( "MOHU" ) == 0
      r_use( dir_server + "mo_su",, "MOSU" )
      r_use( dir_server + "mo_hu", dir_server + "mo_hu", "MOHU" )
      Set Relation To u_kod into MOSU
    Endif
    Select MOHU
    find ( Str( human->kod, 7 ) )
    Do While mohu->kod == human->kod .and. !Eof()
      If Left( mosu->shifr1, 4 ) == "A16."
        AAdd( arr_oper, { AllTrim( mosu->shifr1 ), mohu->kol_1, Left( mohu->kod_diag, 1 ) } )
      Endif
      Skip
    Enddo
  Endif
  If nkd > 0 .and. ( k := ret_f_14( mdiag ) ) != NIL
    AAdd( arr_d, mdiag )
    If Len( k ) > 0
      fl_perevod := .f. ; lv := 1 ; lum := 0 ; ++jh1
      If eq_any( human_->RSLT_NEW, 102, 202 ) // исход - перевод в другое ЛПУ
        fl_perevod := .t.
      Elseif is_death( human_->RSLT_NEW ) // смерть
        fl_death := .t.
        lum := 1 ; lv := 0 ; lkd := 0 // если умер, то койко-дни не учитывать
      Endif
      If fl_perevod .and. !yes_perevod
        If mvozrast >= 18
          arr_perevod[ 4 ] += lv
          arr_perevod[ 5 ] += lkd
          arr_perevod[ 6 ] += lum
        Else
          arr_perevod[ 7 ]  += lv
          arr_perevod[ 9 ]  += lkd
          arr_perevod[ 10 ] += lum
          If mvozrast < 1
            arr_perevod[ 8 ]  += lv
            arr_perevod[ 11 ] += lum
          Endif
        Endif
      Else
        For x := 1 To Len( arr_tip )
          For j := 1 To Len( k )
            Select TMP_TAB
            find ( Str( arr_tip[ x ], 1 ) + PadR( k[ j, 1 ], 9 ) )
            tmp_tab->p_boln += lv
            If M1F14_EKST == 1
              tmp_tab->p_ekst += lv
              If M1F14_SKOR == 1
                tmp_tab->p_skor += lv
              Endif
            Endif
            tmp_tab->p_kd   += lkd
            tmp_tab->p_umer += lum
            If M1F14_VSKR == 1
              tmp_tab->p_vskr += lum
              If M1F14_RASH == 1
                tmp_tab->p_rash += lum
              Endif
            Endif
            If mvozrast < 1 // до 1 года
              tmp_tab->p_bdo1 += lv
              tmp_tab->p_kd1  += lkd
              tmp_tab->p_udo1 += lum
            Endif
          Next
        Next
        If is_diag
          For x := 1 To Len( arr_tip )
            Select TMP_D
            find ( Str( arr_tip[ x ], 1 ) + mdiag )
            If !Found()
              Append Blank
              tmp_d->tip := arr_tip[ x ]
              tmp_d->diagnoz := mdiag
              If ( j := AScan( k, {| y| n := AllTrim( y[ 1 ] ), ( !( n == "1.0" ) .and. Right( n, 2 ) == ".0" ) } ) ) > 0
                tmp_d->stroke := PadR( k[ j, 1 ], 9 )
              Endif
            Endif
            tmp_d->p_boln += lv
            If M1F14_EKST == 1
              tmp_d->p_ekst += lv
              If M1F14_SKOR == 1
                tmp_d->p_skor += lv
              Endif
            Endif
            tmp_d->p_kd   += lkd
            tmp_d->p_umer += lum
            If M1F14_VSKR == 1
              tmp_d->p_vskr += lum
              If M1F14_RASH == 1
                tmp_d->p_rash += lum
              Endif
            Endif
            If mvozrast < 1
              tmp_d->p_bdo1 += lv
              tmp_d->p_kd1  += lkd
              tmp_d->p_udo1 += lum
            Endif
          Next
        Endif
      Endif
    Endif
  Endif
  // врезка таблица 2910
  If nkd > 0
    k := ret_f_14_2910( mdiag )
    For j := 1 To Len( k )
      Select TMP_2910
      find ( PadR( k[ j, 1 ], 9 ) )
      If Found()
        If is_death( human_->RSLT_NEW ) // смерть
          lum := 1
          lvip := 0
        Else
          lum := 0
          lvip := 1
        Endif
        If mvozrast <= 14
          tmp_2910->umer_0_14 += lum
          tmp_2910->vip_0_14  += lvip
        Elseif 15 <= mvozrast .and. mvozrast <= 19
          tmp_2910->umer_15_19 += lum
          tmp_2910->vip_15_19  += lvip
        Elseif 20 <= mvozrast .and. mvozrast <= 24
          tmp_2910->umer_20_24 += lum
          tmp_2910->vip_20_24  += lvip
        Elseif 25 <= mvozrast .and. mvozrast <= 29
          tmp_2910->umer_25_29 += lum
          tmp_2910->vip_25_29  += lvip
        Elseif 30 <= mvozrast .and. mvozrast <= 34
          tmp_2910->umer_30_34 += lum
          tmp_2910->vip_30_34  += lvip
        Elseif 35 <= mvozrast .and. mvozrast <= 39
          tmp_2910->umer_35_39 += lum
          tmp_2910->vip_35_39  += lvip
        Elseif 40 <= mvozrast .and. mvozrast <= 44
          tmp_2910->umer_40_44 += lum
          tmp_2910->vip_40_44  += lvip
        Elseif 45 <= mvozrast .and. mvozrast <= 29
          tmp_2910->umer_45_49 += lum
          tmp_2910->vip_45_49  += lvip
        Elseif 50 <= mvozrast .and. mvozrast <= 54
          tmp_2910->umer_50_54 += lum
          tmp_2910->vip_50_54  += lvip
        Elseif 55 <= mvozrast .and. mvozrast <= 59
          tmp_2910->umer_55_59 += lum
          tmp_2910->vip_55_59  += lvip
        Elseif 60 <= mvozrast .and. mvozrast <= 64
          tmp_2910->umer_60_64 += lum
          tmp_2910->vip_60_64  += lvip
        Elseif 65 <= mvozrast .and. mvozrast <= 69
          tmp_2910->umer_65_69 += lum
          tmp_2910->vip_65_69  += lvip
        Elseif 70 <= mvozrast .and. mvozrast <= 74
          tmp_2910->umer_70_74 += lum
          tmp_2910->vip_70_74  += lvip
        Elseif 75 <= mvozrast .and. mvozrast <= 79
          tmp_2910->umer_75_79 += lum
          tmp_2910->vip_75_79  += lvip
        Elseif 80 <= mvozrast .and. mvozrast <= 84
          tmp_2910->umer_80_84 += lum
          tmp_2910->vip_80_84  += lvip
        Else // if 20 <= mvozrast .and. mvozrast <= 24
          tmp_2910->umer_85_99 += lum
          tmp_2910->vip_85_99  += lvip
        Endif
      Endif
    Next
    If is_diag
      Select TMP_D3
      find ( mdiag )
      If !Found()
        Append Blank
        tmp_d5->diagnoz := mdiag
        If ( j := AScan( k, {| y| eq_any( AllTrim( y[ 1 ] ), '2', '3', '4', '5', '6', '7' ) } ) ) > 0
          tmp_d5->stroke := PadR( k[ j, 1 ], 9 )
        Endif
      Endif
      //
      //
      //
      If is_death( human_->RSLT_NEW ) // смерть
        lum := 1
        lvip := 0
      Else
        lum := 0
        lvip := 1
      Endif
      If mvozrast <= 14
        tmp_d5->umer_0_14 += lum
        tmp_d5->vip_0_14  += lvip
      Elseif 15 <= mvozrast .and. mvozrast <= 19
        tmp_d5->umer_15_19 += lum
        tmp_d5->vip_15_19  += lvip
      Elseif 20 <= mvozrast .and. mvozrast <= 24
        tmp_d5->umer_20_24 += lum
        tmp_d5->vip_20_24  += lvip
      Elseif 25 <= mvozrast .and. mvozrast <= 29
        tmp_d5->umer_25_29 += lum
        tmp_2910->vip_25_29  += lvip
      Elseif 30 <= mvozrast .and. mvozrast <= 34
        tmp_d5->umer_30_34 += lum
        tmp_d5->vip_30_34  += lvip
      Elseif 35 <= mvozrast .and. mvozrast <= 39
        tmp_d5->umer_35_39 += lum
        tmp_d5->vip_35_39  += lvip
      Elseif 40 <= mvozrast .and. mvozrast <= 44
        tmp_d5->umer_40_44 += lum
        tmp_d5->vip_40_44  += lvip
      Elseif 45 <= mvozrast .and. mvozrast <= 29
        tmp_d5->umer_45_49 += lum
        tmp_d5->vip_45_49  += lvip
      Elseif 50 <= mvozrast .and. mvozrast <= 54
        tmp_d5->umer_50_54 += lum
        tmp_d5->vip_50_54  += lvip
      Elseif 55 <= mvozrast .and. mvozrast <= 59
        tmp_d5->umer_55_59 += lum
        tmp_d5->vip_55_59  += lvip
      Elseif 60 <= mvozrast .and. mvozrast <= 64
        tmp_d5->umer_60_64 += lum
        tmp_d5->vip_60_64  += lvip
      Elseif 65 <= mvozrast .and. mvozrast <= 69
        tmp_d5->umer_65_69 += lum
        tmp_d5->vip_65_69  += lvip
      Elseif 70 <= mvozrast .and. mvozrast <= 74
        tmp_d5->umer_70_74 += lum
        tmp_d5->vip_70_74  += lvip
      Elseif 75 <= mvozrast .and. mvozrast <= 79
        tmp_d5->umer_75_79 += lum
        tmp_d5->vip_75_79  += lvip
      Elseif 80 <= mvozrast .and. mvozrast <= 84
        tmp_d5->umer_80_84 += lum
        tmp_d5->vip_80_84  += lvip
      Else // if 20 <= mvozrast .and. mvozrast <= 24
        tmp_d5->umer_85_99 += lum
        tmp_d5->vip_85_99  += lvip
      Endif
    Endif
    AAdd( arr_d, mdiag )
  Endif
  //
  // конец врезки 2910
  // проверяем таблицу 3000 (новорожденных)
  If nkd > 0 .and. human_->NOVOR > 0 .and. mvozrast == 0 .and. mmonth == 0 .and. mday <= 6
    k := ret_f_14_3000( mdiag )
    For j := 1 To Len( k )
      Select TMP_3000
      find ( PadR( k[ j, 1 ], 9 ) )
      If human_2->VNR < 1000
        tmp_3000->p_boln++
        If fl_death
          tmp_3000->p_umer++
          If nkd <= 6
            tmp_3000->p_umer6++
          Endif
        Endif
      Else
        tmp_3000->p1boln++
        If fl_death
          tmp_3000->p1umer++
          If nkd <= 6
            tmp_3000->p1umer6++
          Endif
        Endif
      Endif
    Next
    If is_diag
      Select TMP_D3
      find ( mdiag )
      If !Found()
        Append Blank
        tmp_d3->diagnoz := mdiag
        If ( j := AScan( k, {| y| eq_any( AllTrim( y[ 1 ] ), '2', '3', '4', '5', '6', '7' ) } ) ) > 0
          tmp_d3->stroke := PadR( k[ j, 1 ], 9 )
        Endif
      Endif
      If human_2->VNR < 1000
        tmp_d3->p_boln++
        If fl_death
          tmp_d3->p_umer++
          If nkd <= 6
            tmp_d3->p_umer6++
          Endif
        Endif
      Else
        tmp_d3->p1boln++
        If fl_death
          tmp_d3->p1umer++
          If nkd <= 6
            tmp_d3->p1umer6++
          Endif
        Endif
      Endif
    Endif
    AAdd( arr_d, mdiag )
  Endif
  // проверяем таблицу 4000 (операции)
  If Len( arr_oper ) > 0
    For i := 1 To Len( arr_oper )
      k := ret_f_14_4000( arr_oper[ i, 1 ] )
      For j := 1 To Len( k )
        Select TMP_4000
        find ( PadR( k[ j, 1 ], 9 ) )
        tmp_4000->p_boln += arr_oper[ i, 2 ]
        If mvozrast <= 14
          tmp_4000->p_boln1 += arr_oper[ i, 2 ]
          If mvozrast < 1
            tmp_4000->p_boln2 += arr_oper[ i, 2 ]
          Endif
        Elseif mvozrast < 18
          tmp_4000->p_boln3 += arr_oper[ i, 2 ]
        Elseif fl_pensioner
          tmp_4000->p_boln4 += arr_oper[ i, 2 ]
        Endif
        If fl_death .and. i == 1
          tmp_4000->p_umer += arr_oper[ i, 2 ]
          If mvozrast <= 14
            tmp_4000->p_umer1 += arr_oper[ i, 2 ]
            If mvozrast < 1
              tmp_4000->p_umer2 += arr_oper[ i, 2 ]
            Endif
          Elseif mvozrast < 18
            tmp_4000->p_umer3 += arr_oper[ i, 2 ]
          Elseif fl_pensioner
            tmp_4000->p_umer4 += arr_oper[ i, 2 ]
          Endif
        Endif
        If arr_oper[ i, 3 ] == "C"
          tmp_4000->p_onko += arr_oper[ i, 2 ]
        Endif
        If flag_vmp
          yes_vmp := .t.
          tmp_4000->_p_boln += arr_oper[ i, 2 ]
          If mvozrast <= 14
            tmp_4000->_p_boln1 += arr_oper[ i, 2 ]
            If mvozrast < 1
              tmp_4000->_p_boln2 += arr_oper[ i, 2 ]
            Endif
          Elseif mvozrast < 18
            tmp_4000->_p_boln3 += arr_oper[ i, 2 ]
          Elseif fl_pensioner
            tmp_4000->_p_boln4 += arr_oper[ i, 2 ]
          Endif
          If fl_death .and. i == 1
            tmp_4000->_p_umer += arr_oper[ i, 2 ]
            If mvozrast <= 14
              tmp_4000->_p_umer1 += arr_oper[ i, 2 ]
              If mvozrast < 1
                tmp_4000->_p_umer2 += arr_oper[ i, 2 ]
              Endif
            Elseif mvozrast < 18
              tmp_4000->_p_umer3 += arr_oper[ i, 2 ]
            Elseif fl_pensioner
              tmp_4000->_p_umer4 += arr_oper[ i, 2 ]
            Endif
          Endif
        Endif
      Next
      If is_diag
        Select TMP_D4
        find ( PadR( arr_oper[ i, 1 ], 14 ) )
        If !Found()
          Append Blank
          tmp_d4->shifr := arr_oper[ i, 1 ]
          If ( j := AScan( k, {| y| n := AllTrim( y[ 1 ] ), !( n == "1" .or. "." $ n ) } ) ) > 0
            tmp_d4->stroke := PadR( k[ j, 1 ], 9 )
          Endif
        Endif
        tmp_d4->p_boln += arr_oper[ i, 2 ]
        If mvozrast <= 14
          tmp_d4->p_boln1 += arr_oper[ i, 2 ]
          If mvozrast < 1
            tmp_d4->p_boln2 += arr_oper[ i, 2 ]
          Endif
        Elseif mvozrast < 18
          tmp_d4->p_boln3 += arr_oper[ i, 2 ]
        Elseif fl_pensioner
          tmp_d4->p_boln4 += arr_oper[ i, 2 ]
        Endif
        If fl_death .and. i == 1
          tmp_d4->p_umer += arr_oper[ i, 2 ]
          If mvozrast <= 14
            tmp_d4->p_umer1 += arr_oper[ i, 2 ]
            If mvozrast < 1
              tmp_d4->p_umer2 += arr_oper[ i, 2 ]
            Endif
          Elseif mvozrast < 18
            tmp_d4->p_umer3 += arr_oper[ i, 2 ]
          Elseif fl_pensioner
            tmp_d4->p_umer4 += arr_oper[ i, 2 ]
          Endif
        Endif
        If arr_oper[ i, 3 ] == "C"
          tmp_d4->p_onko += arr_oper[ i, 2 ]
        Endif
        If flag_vmp
          tmp_d4->_p_boln += arr_oper[ i, 2 ]
          If mvozrast <= 14
            tmp_d4->_p_boln1 += arr_oper[ i, 2 ]
            If mvozrast < 1
              tmp_d4->_p_boln2 += arr_oper[ i, 2 ]
            Endif
          Elseif mvozrast < 18
            tmp_d4->_p_boln3 += arr_oper[ i, 2 ]
          Elseif fl_pensioner
            tmp_d4->_p_boln4 += arr_oper[ i, 2 ]
          Endif
          If fl_death .and. i == 1
            tmp_d4->_p_umer += arr_oper[ i, 2 ]
            If mvozrast <= 14
              tmp_d4->_p_umer1 += arr_oper[ i, 2 ]
              If mvozrast < 1
                tmp_d4->_p_umer2 += arr_oper[ i, 2 ]
              Endif
            Elseif mvozrast < 18
              tmp_d4->_p_umer3 += arr_oper[ i, 2 ]
            Elseif fl_pensioner
              tmp_d4->_p_umer4 += arr_oper[ i, 2 ]
            Endif
          Endif
        Endif
      Endif
    Next
    AAdd( arr_d, mdiag )
  Endif
  If Len( arr_d ) > 0
    ++jh
  Endif

  Return jh

//
Function ret_f_14( lshifr )

  Local ret := {}, i, j, d, r

  d := diag_to_num( lshifr, 1 )
  For i := 1 To len_diag
    r := diag1[ i, 2 ]
    For j := 1 To Len( r )
      If Between( d, r[ j, 1 ], r[ j, 2 ] )
        AAdd( ret, { diag1[ i, 1 ], diag1[ i, 2 ] } )
        Exit
      Endif
    Next
  Next
  If Len( ret ) == 0 ; ret := NIL ; Endif

  Return ret

// 16.01.23
Function ret_f_14_2910( lshifr )

  Local ret := {}, i, j, d, r

  // aadd(ret,{'1',{}})
  d := diag_to_num( lshifr, 1 )
  For i := 1 To len_diag_2910
    r := diag1_2910[ i, 2 ]
    For j := 1 To Len( r )
      If Between( d, r[ j, 1 ], r[ j, 2 ] )
        AAdd( ret, { diag1_2910[ i, 1 ], diag1_2910[ i, 2 ] } )
        Exit
      Endif
    Next
  Next
  // if len(ret) == 1
  // aadd(ret,{'7',{}})
  // endif

  Return ret

// 08.01.13
Function ret_f_14_3000( lshifr )

  Local ret := {}, i, j, d, r

  AAdd( ret, { '1', {} } )
  d := diag_to_num( lshifr, 1 )
  For i := 1 To len_diag_3000
    r := diag1_3000[ i, 2 ]
    For j := 1 To Len( r )
      If Between( d, r[ j, 1 ], r[ j, 2 ] )
        AAdd( ret, { diag1_3000[ i, 1 ], diag1_3000[ i, 2 ] } )
        Exit
      Endif
    Next
  Next
  If Len( ret ) == 1
    AAdd( ret, { '8', {} } )
  Endif

  Return ret

// 11.01.14
Function ret_f_14_4000( lshifr )

  Local ret := {}, i, j, d, r, fl

  AAdd( ret, { '1', {} } )
  If Len( lshifr ) == 10
    lshifr += ".000"
  Endif
  For i := 1 To len_usl_4000
    fl := .t.
    If !Empty( r := usl1_4000[ i, 3 ] ) // сначала проверим исключающие диапазоны
      For j := 1 To Len( r )
        If Between( lshifr, r[ j, 1 ], r[ j, 2 ] )
          fl := .f.
          Exit
        Endif
      Next
    Endif
    If fl
      r := usl1_4000[ i, 2 ] // а теперь - включающие диапазоны
      For j := 1 To Len( r )
        If Between( lshifr, r[ j, 1 ], r[ j, 2 ] )
          AAdd( ret, { usl1_4000[ i, 1 ], usl1_4000[ i, 2 ] } )
          Exit
        Endif
      Next
    Endif
  Next
  If Len( ret ) == 1
    AAdd( ret, { '20', {} } )
  Endif

  Return ret

// 12.02.13
Function forma_14ds( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j, uch_otd

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "Распечатка ~формы 14дс", ;
      "Форма 14дс + ~диагнозы", ;
      "~Отделение + форма 14дс" }
    mas_msg := { "Распечатка формы № 14дс", ;
      "Распечатка аналога формы 14дс с уточнением диагнозов", ;
      "Распечатка аналога формы 14дс с диагнозами по конкретному отделению" }
    mas_fun := { "forma_14ds(11)", ;
      "forma_14ds(12)", ;
      "forma_14ds(13)" }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    f1_frm14ds( .f., .f. )
  Case k == 12
    f1_frm14ds( .t., .f. )
  Case k == 13
    f1_frm14ds( .t., .t. )
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

//
Function f1_frm14ds( is_diag, is_otd )

  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., sh, HH := 80, reg_print, speriod, ;
    arr_title, name_file, t_arr1[ 2 ], ;
    jh := 0, jh1 := 0, arr_m, nf, file_form

  name_file := iif( is_diag, "_fr14dsd", "_frm14ds" ) + stxt()
  Private len_name := 28
  If is_otd
    st_a_uchast := {}
    If input_uch( T_ROW, T_COL - 5, sys_date ) == Nil .or. ;
        input_otd( T_ROW, T_COL - 5, sys_date ) == NIL
      Return Nil
    Endif
  Else
    If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
      Return Nil
    Endif
    If ( st_a_uchast := ret_uchast( T_ROW, T_COL - 5 ) ) == NIL
      Return Nil
    Endif
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  speriod := arr_m[ 4 ]
  //
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  adbf := { { "stroke", "N", 2, 0 }, ;
    { "tip","N", 1, 0 }, ;
    { "p1boln", "N", 7, 0 }, ;
    { "p1stac", "N", 7, 0 }, ;
    { "p1kd","N", 9, 0 }, ;
    { "p1umer", "N", 7, 0 }, ;
    { "p2boln", "N", 7, 0 }, ;
    { "p2stac", "N", 7, 0 }, ;
    { "p2kd","N", 9, 0 }, ;
    { "p2umer", "N", 7, 0 }, ;
    { "p3boln", "N", 7, 0 }, ;
    { "p3stac", "N", 7, 0 }, ;
    { "p3kd","N", 9, 0 }, ;
    { "p3umer", "N", 7, 0 } }
  //
  dbCreate( cur_dir() + "tmp_tab", adbf )
  Use ( cur_dir() + "tmp_tab" ) New Alias TMP_TAB
  Index On Str( tip, 1 ) + Str( stroke, 2 ) to ( cur_dir() + "tmp_tab" )
  //
  Private diag1 := {}, len_diag, arr_frm14 := f14ds_arr()
  For s1 := 1 To Len( arr_frm14 )
    If iif( is_diag, ( "-" $ arr_frm14[ s1, 1 ] ), .t. )
      s2 := arr_frm14[ s1, 1 ]
  /*for i := 1 to len(s2) // проверка на русские буквы в диагнозах
    if ISRALPHA(substr(s2,i,1))
      strfile(s2+eos,"ttt.ttt",.t.)
      exit
    endif
  next*/
      diapazon := {}
      If "-" $ s2
        d1 := Token( s2, "-", 1 )
        d2 := Token( s2, "-", 2 )
      Else
        d1 := d2 := s2
      Endif
      AAdd( diapazon, { diag_to_num( d1, 1 ), diag_to_num( d2, 2 ) } )
      Select TMP_TAB
      For i := 1 To 2
        Append Blank
        tmp_tab->tip := i
        tmp_tab->stroke := s1
      Next
      AAdd( diag1, { s1, diapazon } )
    Endif
  Next
  len_diag := Len( diag1 )
  //
  If is_diag
    AAdd( adbf, { "diagnoz", "C", 5, 0 } )
    dbCreate( cur_dir() + "tmp_dia", adbf )
    Use ( cur_dir() + "tmp_dia" ) New Alias TMP_D
    Index On Str( tip, 1 ) + diagnoz to ( cur_dir() + "tmp_dia" )
  Endif
  // по дате окончания лечения
  r_use( dir_server + "uslugi",, "USL" )
  r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
  Set Relation To u_kod into USL
  r_use( dir_server + "kartotek",, "KART" )
  If pi1 == 1 // по дате окончания лечения
    begin_date := arr_m[ 5 ]
    end_date := arr_m[ 6 ]
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humand", "HUMAN" )
    Set Relation To kod_k into KART, To RecNo() into HUMAN_
    dbSeek( DToS( begin_date ), .t. )
    Do While human->k_data <= end_date .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If human_->usl_ok == 2 .and. human_->oplata < 9 .and. ;
          iif( is_otd, ( human->otd == glob_otd[ 1 ] ), f_is_uch( st_a_uch, human->lpu ) ) ;
          .and. func_pi_schet() .and. f_is_uchast( st_a_uchast, kart->uchast )
        jh := f1_f14ds( jh, @jh1, is_diag )
        @ MaxRow(), 1 Say lstr( jh ) Color cColorSt2Msg
        @ Row(), Col() Say "/" Color "W/R"
        @ Row(), Col() Say lstr( jh1 ) Color cColorStMsg
        date_24( human->k_data )
      Endif
      Select HUMAN
      Skip
    Enddo
  Else
    begin_date := arr_m[ 7 ]
    end_date := arr_m[ 8 ]
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
    Set Relation To kod_k into KART, To RecNo() into HUMAN_
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
        If human_->usl_ok == 2 .and. human_->oplata < 9 .and. ;
            iif( is_otd, ( human->otd == glob_otd[ 1 ] ), f_is_uch( st_a_uch, human->lpu ) ) ;
            .and. f_is_uchast( st_a_uchast, kart->uchast )
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          jh := f1_f14ds( jh, @jh1, is_diag )
          @ MaxRow(), 1 Say lstr( jh ) Color cColorSt2Msg
          @ Row(), Col() Say "/" Color "W/R"
          @ Row(), Col() Say lstr( jh1 ) Color cColorStMsg
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
  Close databases
  rest_box( buf )
  If fl_exit ; Return NIL ; Endif
  //
  mywait()
  reg_print := 6
  Private x := 1
  arr_title := f14dstitle()
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server + "organiz",, "ORG" )
  add_string( PadR( org->name, 60 ) + PadL( "Форма № 14дс", sh - 60 ) )
  add_string( PadL( "Утверждена Приказом", sh ) )
  add_string( PadL( "Минздрава России", sh ) )
  add_string( PadL( "от 30.12.2002 № 413", sh ) )
  add_string( Center( "СВЕДЕНИЯ О ДЕЯТЕЛЬНОСТИ ДНЕВНЫХ СТАЦИОНАРОВ ЛЕЧЕБНО-ПРОФИЛАКТИЧЕСКОГО УЧРЕЖДЕНИЯ", sh ) )
  If is_otd
    add_string( Center( AllTrim( glob_otd[ 2 ] ), sh ) )
  Else
    titlen_uch( st_a_uch, sh, lcount_uch )
    title_uchast( st_a_uchast, sh )
  Endif
  add_string( "" )
  add_string( Center( speriod, sh ) )
  If pi1 == 1
    add_string( Center( str_pi_schet(), sh ) )
  Else
    add_string( Center( "[ по дате выписки счета ]", sh ) )
  Endif
  add_string( "" )
  //
  If is_diag
    r_use( dir_exe() + "_mo_mkb", cur_dir() + "_mo_mkb", "MKB10" )
    Use ( cur_dir() + "tmp_dia" ) New Alias TMP_D
    Index On Str( tip, 1 ) + Str( stroke, 2 ) + diagnoz to ( cur_dir() + "tmp_dia" )
  Endif
  Use ( cur_dir() + "tmp_tab" ) index ( cur_dir() + "tmp_tab" ) New Alias TMP
  For x := 1 To 2
    s2 := "СОСТАВ БОЛЬНЫХ В ДНЕВНОМ СТАЦИОНАРЕ, СРОКИ И ИСХОДЫ ЛЕЧЕНИЯ"
    If x == 1
      add_string( Center( "РАЗДЕЛ II. " + s2, sh ) )
      add_string( " (2000)" + PadL( "(18 лет и старше)", sh - 8 ) )
    Else // искусственный перевод страницы
      tek_stroke := HH + 10
      verify_ff( HH, .t., sh )
      add_string( Center( s2, sh ) )
      add_string( " (2003)" + PadL( "(дети 0-17 лет включительно)", sh - 8 ) )
    Endif
    AEval( arr_title, {| x| add_string( x ) } )
    For s1 := 1 To Len( arr_frm14 )
      If iif( is_diag, ( "-" $ arr_frm14[ s1, 1 ] ), .t. )
        s2 := arr_frm14[ s1, 1 ]  // диагнозы
        s3 := arr_frm14[ s1, 2 ]
        Select TMP
        find ( Str( x, 1 ) + Str( s1, 2 ) )
        If Found() .and. iif( is_diag, ( !emptyall( tmp->p1boln, tmp->p1umer, tmp->p2boln, tmp->p2umer, tmp->p3boln, tmp->p3umer ) ), .t. )
          j1 := perenos( t_arr1, s3, len_name )
          If verify_ff( HH - j1, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          ls1 := PadR( t_arr1[ 1 ], len_name ) + ;
            Str( s1, 3 ) + " " + ;
            PadC( AllTrim( s2 ), 7 )
          ls1 += put_val( tmp->p1boln, 7 ) + ;
            put_val( tmp->p1stac, 7 ) + ;
            put_val( tmp->p1kd,8 ) + ;
            put_val( tmp->p1umer, 5 )
          ls1 += put_val( tmp->p2boln, 7 ) + ;
            put_val( tmp->p2stac, 7 ) + ;
            put_val( tmp->p2kd,8 ) + ;
            put_val( tmp->p2umer, 5 )
          ls1 += put_val( tmp->p3boln, 7 ) + ;
            put_val( tmp->p3stac, 7 ) + ;
            put_val( tmp->p3kd,8 ) + ;
            put_val( tmp->p3umer, 5 )
          add_string( ls1 )
          For i := 2 To j1
            add_string( t_arr1[ i ] )
          Next
          add_string( Replicate( "-", sh ) )
          If is_diag
            Select TMP_D
            find ( Str( x, 1 ) + Str( s1, 2 ) )
            Do While tmp_d->tip == x .and. tmp_d->stroke == s1 .and. !Eof()
              Select MKB10
              find ( tmp_d->diagnoz )
              s := AllTrim( mkb10->name ) + " "
              Skip
              Do While Left( mkb10->shifr, 5 ) == tmp_d->diagnoz .and. mkb10->ks > 0 ;
                  .and. !Eof()
                s += AllTrim( mkb10->name ) + " "
                Skip
              Enddo
              j1 := perenos( t_arr1, s, len_name + 4 )
              If verify_ff( HH - j1, .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              ls1 := PadR( t_arr1[ 1 ], len_name + 4 ) + ;
                PadC( AllTrim( tmp_d->diagnoz ), 7 )
              ls1 += put_val( tmp_d->p1boln, 7 ) + ;
                put_val( tmp_d->p1stac, 7 ) + ;
                put_val( tmp_d->p1kd,8 ) + ;
                put_val( tmp_d->p1umer, 5 )
              ls1 += put_val( tmp_d->p2boln, 7 ) + ;
                put_val( tmp_d->p2stac, 7 ) + ;
                put_val( tmp_d->p2kd,8 ) + ;
                put_val( tmp_d->p2umer, 5 )
              ls1 += put_val( tmp_d->p3boln, 7 ) + ;
                put_val( tmp_d->p3stac, 7 ) + ;
                put_val( tmp_d->p3kd,8 ) + ;
                put_val( tmp_d->p3umer, 5 )
              add_string( ls1 )
              For i := 2 To j1
                add_string( PadL( AllTrim( t_arr1[ i ] ), len_name + 4 ) )
              Next
              Select TMP_D
              Skip
            Enddo
            add_string( Replicate( "-", sh ) )
          Endif
        Endif
      Endif
    Next
  Next
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( name_file,,,, .t.,,, reg_print )

  Return Nil

// 04.01.16
Function f14ds_arr()

  Local arr := {}

  AAdd( arr, { "A00-T98", "Всего" } )
  AAdd( arr, { "A00-B99", "некоторые инфекционные и паразитарные болезни" } )
  AAdd( arr, { "C00-D48", "новообразования" } )
  AAdd( arr, { "D50-D89", "болезни крови, кроветворных органов и отдельные нарушения, вовлекающие иммунный механизм" } )
  AAdd( arr, { "E00-E90", "болезни эндокринной системы, расстройства питания и нарушения обмена веществ" } )
  AAdd( arr, { "F00-F99", "психические расстройства и расстройства поведения" } )
  AAdd( arr, { "G00-G99", "болезни нервной системы" } )
  AAdd( arr, { "H00-H59", "болезни глаза и его придаточного аппарата" } )
  AAdd( arr, { "H60-H95", "болезни уха и сосцевидного отростка" } )
  AAdd( arr, { "I00-I99", "болезни системы кровообращения" } )
  AAdd( arr, { "J00-J99", "болезни органов дыхания" } )
  AAdd( arr, { "K00-K93", "болезни органов пищеварения" } )
  AAdd( arr, { "L00-L99", "болезни кожи и подкожной клетчатки" } )
  AAdd( arr, { "M00-M99", "болезни костно-мышечной системы и соединительной ткани" } )
  AAdd( arr, { "N00-N99", "болезни мочеполовой системы" } )
  AAdd( arr, { "O00-O99", "беременность, роды и послеродовой период" } )
  AAdd( arr, { "P00-P99", "отдельные состояния, взникающие в перинатальном периоде" } )
  AAdd( arr, { "Q00-Q99", "врожденные аномалии, пороки развития, деформации и хромосомные нарушения" } )
  AAdd( arr, { "R00-R99", "симптомы, признаки и отклонения от нормы, выявленные при клинических и лабораторных исследованиях, не классифицированные в других рубриках" } )
  AAdd( arr, { "S00-T98", "травмы, отравления и некоторые другие последствия воздействия внешних причин" } )
  AAdd( arr, { "Z00-Z99", "Кроме того: факторы, влияющие на состояние здоровья и обращения в учреждения здравоохранения" } )
  AAdd( arr, { "X","Оперировано больных (числа выписанных и переведенных)" } )
  AAdd( arr, { "X","Число проведенных операций" } )

  Return arr

//
Function f14dstitle()

  Local arr := Array( 10 )

  arr[ 1 ] := Replicate( "─", len_name )
  arr[ 2 ] := PadC( "", len_name )
  arr[ 3 ] := PadC( "", len_name )
  arr[ 4 ] := PadC( "", len_name )
  arr[ 5 ] := PadC( "Наименование болезни", len_name )
  arr[ 6 ] := PadC( "", len_name )
  arr[ 7 ] := PadC( "", len_name )
  arr[ 8 ] := Replicate( "─", len_name )
  arr[ 9 ] := PadC( "1", len_name )
  arr[ 10 ] := Replicate( "─", len_name )
  arr[ 1 ] := arr[ 1 ] + "┬──┬───────┬──────────────────────────┬──────────────────────────┬──────────────────────────"
  arr[ 2 ] := arr[ 2 ] + "│  │       │Дн.стац.больничных учрежд.│Дн.стац.амб.-поликл.учрежд│     Стационар на дому    "
  arr[ 3 ] := arr[ 3 ] + "│  │ Код по├──────┬──────┬───────┬────┼──────┬──────┬───────┬────┼──────┬──────┬───────┬────"
  arr[ 4 ] := arr[ 4 ] + "│NN│ МКБ Х │ Выпи-│из них│провед.│умер│ Выпи-│из них│провед.│умер│ Выпи-│из них│провед.│умер"
  arr[ 5 ] := arr[ 5 ] + "│ст│ пере- │ сано │напр.в│вып.бол│ло  │ сано │напр.в│вып.бол│ло  │ сано │напр.в│вып.бол│ло  "
  arr[ 6 ] := arr[ 6 ] + "│ро│ смотра│ боль-│кругл.│дней   │    │ боль-│кругл.│дней   │    │ боль-│кругл.│дней   │    "
  arr[ 7 ] := arr[ 7 ] + "│ки│       │ ных  │стац-р│лечения│    │ ных  │стац-р│лечения│    │ ных  │стац-р│лечения│    "
  arr[ 8 ] := arr[ 8 ] + "┼──┼───────┼──────┼──────┼───────┼────┼──────┼──────┼───────┼────┼──────┼──────┼───────┼────"
  arr[ 9 ] := arr[ 9 ] + "│ 2│   3   │   4  │   5  │   6   │  7 │   8  │   9  │   10  │ 11 │  12  │  13  │   14  │ 15 "
  arr[ 10 ] := arr[ 10 ] + "┴──┴───────┴──────┴──────┴───────┴────┴──────┴──────┴───────┴────┴──────┴──────┴───────┴────"

  Return arr

// 04.01.16
Function f1_f14ds( jh, jh1, is_diag )

  Local arr := {}, arr_d := {}, i, j, k, n, mvozrast, lkd, lum, _kd

  If human_->NOVOR > 0
    mvozrast := count_years( human_->DATE_R2, human->n_data )
  Else
    mvozrast := count_years( human->date_r, human->n_data )
  Endif
  arr := diag_to_array()
  If Len( arr ) == 0
    Return jh
  Endif
  ASize( arr, 1 )  // только основной диагноз
  For i := 1 To Len( arr )
    arr[ i ] := PadR( arr[ i ], 5 )
    If AScan( arr_d, arr[ i ] ) == 0 .and. ( k := ret_f_14( arr[ i ] ) ) != NIL
      AAdd( arr_d, arr[ i ] )
      If Len( k ) > 0
        lkd := { 0, 0, 0 }
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
            lshifr := usl->shifr
          Endif
          If AllTrim( lshifr ) == "60.2.9" // Проведение гемодиализа
            lkd[ 1 ] += hu->kol
          Elseif Left( lshifr, 3 ) == "55."
            If human->k_data < 0d20130401 // дневной стационар до 1 апреля 2013
              j := Int( Val( SubStr( lshifr, 4, 1 ) ) )
              n := j - 4 // 1 квартал 2013 года
              If Between( n, 1, 3 )
                lkd[ n ] += human->k_data - human->n_data + 1
                Exit
              Endif
              n := j - 1 // по 2012 год
              If Between( n, 1, 3 )
                lkd[ n ] += hu->kol
              Endif
            Elseif Year( human->k_data ) > 2013 .and. eq_any( Left( lshifr, 5 ), "55.2.", "55.3.", "55.4." )
              // от 1 до 4 пациенто-дней с 2014 года
              n := Int( Val( SubStr( lshifr, 4, 1 ) ) ) -1
              If Between( n, 1, 3 )
                lkd[ n ] += hu->kol
              Endif
            Elseif Left( lshifr, 5 ) == "55.1." // с 1 апреля 2013 года
              n := Int( Val( SubStr( lshifr, 6, 1 ) ) )
              If n > 3     // 55.1.4 - Пациенто-дни для учета в законченном случае реабилитации
                n := 1     // 55.1.5 - Пациенто-день для учета ЭКО ВМП
              Endif
              If Between( n, 1, 3 )
                lkd[ n ] += hu->kol
              Endif
            Endif
          Endif
          Select HU
          Skip
        Enddo
        If !emptyall( lkd[ 1 ], lkd[ 2 ], lkd[ 3 ] )   // если была услуга ПАЦИЕНТО-ДЕНЬ
          fl_perevod := .f. ; lv := 1 ; lum := 0 ; ++jh1
          If eq_any( human_->RSLT_NEW, 202, 203 ) // исход - направлен на госпитализацию/перевод в другое ЛПУ
            fl_perevod := .t.
          Elseif is_death( human_->RSLT_NEW ) // смерть
            lum := 1 ; lv := 0 // если умер, то койко-дни не учитывать
          Endif
          x := iif( mvozrast >= 18, 1, 2 )
          For j := 1 To Len( k )
            Select TMP_TAB
            find ( Str( x, 1 ) + Str( k[ j, 1 ], 2 ) )
            If !Empty( lkd[ 1 ] )   // если была услуга КОЙКО-ДЕНЬ
              If lum == 1
                tmp_tab->p1umer++
              Else
                tmp_tab->p1boln++
                If fl_perevod
                  tmp_tab->p1stac++
                Endif
                tmp_tab->p1kd += lkd[ 1 ]
              Endif
            Elseif !Empty( lkd[ 2 ] )   // если была услуга КОЙКО-ДЕНЬ
              If lum == 1
                tmp_tab->p2umer++
              Else
                tmp_tab->p2boln++
                If fl_perevod
                  tmp_tab->p2stac++
                Endif
                tmp_tab->p2kd += lkd[ 2 ]
              Endif
            Elseif !Empty( lkd[ 3 ] )   // если была услуга КОЙКО-ДЕНЬ
              If lum == 1
                tmp_tab->p3umer++
              Else
                tmp_tab->p3boln++
                If fl_perevod
                  tmp_tab->p3stac++
                Endif
                tmp_tab->p3kd += lkd[ 3 ]
              Endif
            Endif
          Next
          If is_diag
            Select TMP_D
            find ( Str( x, 1 ) + PadR( arr[ i ], 5 ) )
            If !Found()
              Append Blank
              tmp_d->tip := x
              tmp_d->diagnoz := arr[ i ]
              If ( j := AScan( k, {| y| y[ 1 ] > 1 } ) ) > 0
                tmp_d->stroke := k[ j, 1 ]
              Endif
            Endif
            If !Empty( lkd[ 1 ] )   // если была услуга КОЙКО-ДЕНЬ
              If lum == 1
                tmp_d->p1umer++
              Else
                tmp_d->p1boln++
                If fl_perevod
                  tmp_d->p1stac++
                Endif
                tmp_d->p1kd += lkd[ 1 ]
              Endif
            Elseif !Empty( lkd[ 2 ] )   // если была услуга КОЙКО-ДЕНЬ
              If lum == 1
                tmp_d->p2umer++
              Else
                tmp_d->p2boln++
                If fl_perevod
                  tmp_d->p2stac++
                Endif
                tmp_d->p2kd += lkd[ 2 ]
              Endif
            Elseif !Empty( lkd[ 3 ] )   // если была услуга КОЙКО-ДЕНЬ
              If lum == 1
                tmp_d->p3umer++
              Else
                tmp_d->p3boln++
                If fl_perevod
                  tmp_d->p3stac++
                Endif
                tmp_d->p3kd += lkd[ 3 ]
              Endif
            Endif
          Endif
        Endif
      Endif
    Endif
  Next
  If Len( arr_d ) > 0
    ++jh
  Endif

  Return jh

  //
Function usl_to_ffoms( lshifr, k )
  
  Local l := len(lshifr)
  
  if !eq_any( l, 2, 6, 10 )
    func_error( 4, "Неверный шифр услуги " + lshifr )
  endif
  do while l < 10
    if k == 1
      lshifr += ".000"
    else
      lshifr += ".999"
    endif
    l := len( lshifr )
  enddo
  return "A16." + lshifr
