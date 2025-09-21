// mo_omsit.prg - информация по ОМС (правила, статистические формы)
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static lcount_uch  := 1
Static lcount_otd  := 0
Static sect_nastr  := 'НАСТРОЙКА'
Static nastr_print := 'PRINT'
Static nastr_vvod  := 'VVOD'
Static nastr_diagn := 'DIAGN'
Static nastr_f12   := 'F12'
Static nastr_f57   := 'F57'

//
Function prover_rule()

  Local i, k, hGauge, buf := save_maxrow(), arr_m, ;
    n_file := cur_dir() + 'ver_rule.txt', sh := 80, HH := 78, reg_print := 5, ;
    fl_exit := .f., taa[ 2 ], ab := {}, s, arr1, blk, jkart, jhuman, jerr, t1, t2, i1

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  mywait()
  t1 := Seconds()
  // чтение правил в память
  Private mbukva5 := "", marr5 := {}, len5
  If !read_rule( D_RULE_N_PRINT )
    Close databases
    rest_box( buf )
    Return func_error( 4, 'Зайдите в режим "Настройка правил статистики"' )
  Endif
  len5 := Len( mbukva5 )
  For i := 1 To len5
    AAdd( marr5, { SubStr( mbukva5, i, 1 ), 0 } )
  Next
  Private fl_plus := !Empty( yes_d_plus )
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Index On Str( kod_k, 7 ) + DToS( k_data ) to ( cur_dir() + "tmp_h" ) ;
    While k_data <= arr_m[ 6 ] ;
    For kod > 0
  //
  status_key( "^<Esc>^ - прервать поиск" )
  hGauge := gaugenew(,,, "Поиск " + arr_m[ 4 ], .t. )
  gaugedisplay( hGauge )
  fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
  add_string( "" )
  add_string( Center( "Проверка на соответствие правилам статистики", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( "" )
  r_use( dir_server() + "kartotek", dir_server() + "kartoten", "KART" )
  Go Top
  jkart := jhuman := jerr := 0
  blk := {|| human_->USL_OK != 1 }  // режим лечения не "стационарно"
  Do While !Eof()
    gaugeupdate( hGauge, ++jkart / LastRec() )
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If f1_prover_rule( blk, ab )
      ++jhuman
      arr1 := verify_rule( ab, kart->pol )
      If Len( arr1 ) > 0
        ++jerr
        verify_ff( HH - 3, .t., sh )
        add_string( "" )
        s := lstr( jerr ) + ". "
        add_string( s + AllTrim( kart->fio ) + " (пол: " + kart->pol + ")" )
        For i := 1 To Len( arr1 )
          verify_ff( HH, .t., sh )
          k := Len( s )
          For i1 := 1 To perenos( taa, arr1[ i ], sh - k )
            If i1 == 1
              add_string( Space( k ) + taa[ i1 ] )
            Else
              add_string( PadL( AllTrim( taa[ i1 ] ), sh ) )
            Endif
          Next
        Next
      Endif
    Endif
    @ MaxRow(), 1 Say lstr( jkart ) Color "W+/R"
    @ Row(), Col() Say "/" Color "W/R"
    @ Row(), Col() Say lstr( jhuman ) Color "GR+/R"
    @ Row(), Col() Say "/" Color "W/R"
    @ Row(), Col() Say lstr( jerr ) Color "G+/R"
    Select KART
    If RecNo() % 5000 == 0
      Commit
    Endif
    Skip
  Enddo
  Close databases
  closegauge( hGauge )
  FClose( fp )
  rest_box( buf )
  t2 := Seconds() - t1
  // n_message({"","Время проверки - "+sectotime(t2)},, ;
  // color1,cDataCSay,,,color8)
  If jerr == 0
    func_error( 4, "Ошибок не обнаружено!" )
  Else
    viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  Return Nil

// 21.09.21
Function f1_prover_rule( blk_usl, ab, n_forma )

  Static a_d_talon[ 16 ]
  Local i, j, k, arr_d, lshifr, lta, lbukva, s, rec, lnum_kol, tip_travma := {}

  Default n_forma To 12
  Private arr_all := {}
  If Len( ab ) > 0
    ASize( ab, 0 )
  Endif
  If tmp1rule->( LastRec() ) > 0
    Select TMP1RULE
    Zap
  Endif
  If tmp2rule->( LastRec() ) > 0
    Select TMP2RULE
    Zap
  Endif
  Select HUMAN
  find ( Str( kart->kod, 7 ) )
  Do While kart->kod == human->kod_k .and. !Eof()
    lnum_kol := 0
    If Eval( blk_usl )
      rec := human->( RecNo() )
      lta := {} ; lbukva := AllTrim( human_->STATUS_ST )
      If eq_any( human->ishod, 101, 102, 201, 202, 203, 204, 205, 301, 302 )
        If eq_any( human->ishod, 101, 102 )
          arr := ret_f12_pn( human->kod, 1, human->k_data )
          lnum_kol := 9 // профосмотр
        Elseif eq_any( human->ishod, 201, 202, 203, 204, 205 )
          arr := ret_f12_dvn( human->kod, 2 )
          lnum_kol := iif( human->ishod == 203, 9, 10 ) // профосмотр или диспансеризация
        Elseif eq_any( human->ishod, 301, 302 )
          arr := ret_f12_pn( human->kod, 2, human->k_data )
          lnum_kol := 9 // профосмотр
        Endif
        If Empty( arr )
          AAdd( arr, { human->KOD_DIAG, 0, 0 } )
        Endif
        For i := 1 To Len( arr )
          If !Empty( lshifr := AllTrim( arr[ i, 1 ] ) )
            If n_forma == 57 .and. eq_any( Left( lshifr, 1 ), "V", "W", "X", "Y" )
              AAdd( arr_all, PadR( lshifr, 5 ) )
            Endif
            If ( k := AScan( lta, {| x| x[ 1 ] == lshifr } ) ) == 0
              AAdd( lta, { lshifr, 0, 0, 0 } )
              k := Len( lta )
            Endif
            If lta[ k, 2 ] == 0 .and. arr[ i, 2 ] > 0
              lta[ k, 2 ] := arr[ i, 2 ]
            Endif
            lta[ k, 3 ] := arr[ i, 3 ]
          Endif
        Next
      Else
        arr_d := { human->KOD_DIAG, ;
          human->KOD_DIAG2, ;
          human->KOD_DIAG3, ;
          human->KOD_DIAG4, ;
          human->SOPUT_B1, ;
          human->SOPUT_B2, ;
          human->SOPUT_B3, ;
          human->SOPUT_B4 }
        For j := 1 To 8
          If !Empty( lshifr := AllTrim( arr_d[ j ] ) )
            If n_forma == 57 .and. eq_any( Left( lshifr, 1 ), "V", "W", "X", "Y" )
              AAdd( arr_all, PadR( lshifr, 5 ) )
            Endif
            If ( k := AScan( lta, {| x| x[ 1 ] == lshifr } ) ) == 0
              AAdd( lta, { lshifr, 0, 0, 0 } )
              k := Len( lta )
            Endif
            If lta[ k, 2 ] == 0 .and. !Empty( s := SubStr( human->diag_plus, j, 1 ) )
              If s $ "+-"
                lta[ k, 2 ] := if( s == "+", 1, 2 )
              Elseif fl_plus .and. s $ yes_d_plus .and. !( s $ lbukva )
                lbukva += s
              Endif
            Endif
            If emptyany( lta[ k, 2 ], lta[ k, 3 ], lta[ k, 4 ] )
              For i := 1 To 16
                a_d_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
              Next
              s := a_d_talon[ j * 2 -1 ]   // характер заболевания
              If eq_any( s, 1, 2 )
                lta[ k, 2 ] := s
              Endif
              s := a_d_talon[ j * 2 ]   // диспансеризация
              If Between( s, 1, 3 )
                lta[ k, 3 ] := s
                If Empty( lta[ k, 2 ] )  // если не определен характер заболевания,
                  lta[ k, 2 ] := s     // то определяем его принудительно
                Endif
              Endif
            Endif
          Endif
        Next
        If n_forma == 57
          arr := { human_2->OSL1, human_2->OSL2, human_2->OSL3 }
          For i := 1 To Len( arr )
            If !Empty( lshifr := AllTrim( arr[ i ] ) )
              If eq_any( Left( lshifr, 1 ), "V", "W", "X", "Y" )
                AAdd( arr_all, PadR( lshifr, 5 ) )
              Endif
            Endif
          Next
        Endif
      Endif
      If n_forma == 57 .and. Empty( tip_travma := ret_f_57_wide() ) // если NIL, то по-старому из меню типа травмы
        tip_travma := { 4 }
        Do Case
        Case human_->TRAVMA == 4 // {"Дорожно-транспортная пр-венная", 4}, ;
          AAdd( tip_travma, 5 )
        Case human_->TRAVMA == 8 // {"Дор.трансп., не связанная с пр-вом", 8}, ;
          AAdd( tip_travma, 5 )
          AAdd( tip_travma, 6 )
        Otherwise
          AAdd( tip_travma, 7 )
        Endcase
      Endif
      For i := 1 To Len( lta )
        lshifr := lta[ i, 1 ]
        // сначала для 5-тизначного шифра
        Select TMP1RULE
        find ( "1" + PadR( lshifr, 5 ) )
        If !Found()
          Append Blank
          tmp1rule->kod   := RecNo()
          tmp1rule->tip   := 1
          tmp1rule->shifr := lshifr
          tmp1rule->dnum  := diag_to_num( lshifr, 1 )
        Endif
        Select TMP2RULE
        Append Blank
        tmp2rule->kod    := tmp1rule->kod
        tmp2rule->n_data := human->n_data
        tmp2rule->k_data := human->k_data
        tmp2rule->harak  := lta[ i, 2 ]
        If lta[ i, 3 ] > 0
          tmp1rule->dispan := lta[ i, 3 ]
          tmp2rule->dispan := lta[ i, 3 ]
        Endif
        tmp2rule->travma := arr2list( tip_travma )
        tmp2rule->bukva  := lbukva
        If lta[ i, 2 ] == 1
          ++tmp1rule->kol1
          If lnum_kol > 0
            tmp1rule->num_kol := lnum_kol
            tmp2rule->num_kol := lnum_kol
          Endif
        Elseif lta[ i, 2 ] == 2
          ++tmp1rule->kol2
        Endif
    /*if !empty(right(lshifr, 1))  // а теперь для трехзначной подрубрики
        lshifr := padr(left(lshifr, 3), 5)
        select TMP1RULE
        find ("2"+lshifr)
        if !found()
          append blank
          tmp1rule->kod   := recno()
          tmp1rule->tip   := 2
          tmp1rule->shifr := lshifr
          tmp1rule->dnum  := diag_to_num(lshifr, 1)
        endif
        select TMP2RULE
        append blank
        tmp2rule->kod    := tmp1rule->kod
        tmp2rule->n_data := human->n_data
        tmp2rule->k_data := human->k_data
        tmp2rule->harak  := lta[i, 2]
        if lta[i, 3] > 0
          tmp1rule->dispan := lta[i, 3]
          tmp2rule->dispan := lta[i, 3]
        endif
        tmp2rule->travma := arr2list(tip_travma)
        tmp2rule->bukva  := lbukva
        if lta[i, 2] == 1
          ++ tmp1rule->kol1
        elseif lta[i, 2] == 2
          ++ tmp1rule->kol2
        endif
      endif*/
      Next
      If !Empty( lbukva )
        AAdd( ab, { human->n_data, ;   // D_RULE_N_DATA
        human->k_data, ;   // D_RULE_K_DATA
        lbukva } )          // D_RULE_BUKVA
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  If rec != NIL
    Goto ( rec )
  Endif
  Return ( tmp1rule->( LastRec() ) > 0 )

//
Function st_rule_1()

  Local arr, i, s, adbf, t_arr[ BR_LEN ], mtitle := rule_section[ 1 ]

  adbf := { { "diag1", "C", 5, 0 }, ;
    { "diag2", "C", 5, 0 }, ;
    { "dni4", "N", 3, 0 }, ;
    { "dni3", "N", 3, 0 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On diag1 + diag2 to ( cur_dir() + "tmp" )
  arr := getinisect( file_stat, rule_section[ 1 ] )
  If Empty( arr )
    If !dostup_stat
      Use
      Return func_error( 4, "Данное правило не заполнено!" )
    Endif
  Else
    Select TMP
    For i := 1 To Len( arr )
      Append Blank
      tmp->diag1 := Token( arr[ i, 1 ], "-", 1 )
      tmp->diag2 := Token( arr[ i, 1 ], "-", 2 )
      tmp->dni4  := Int( Val( Token( arr[ i, 2 ], ",", 1 ) ) )
      tmp->dni3  := Int( Val( Token( arr[ i, 2 ], ",", 2 ) ) )
    Next
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL - 10
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 35
  t_arr[ BR_OPEN ] := {|| f1_rule_1(,, "open" ) }
  t_arr[ BR_SEMAPHORE ] := mtitle
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitle
  t_arr[ BR_TITUL_COLOR ] := "B/BG"
  t_arr[ BR_ARR_BROWSE ] := {,,,, .t., 0 }
  t_arr[ BR_COLUMN ] := { { " Коды;  с", {|| tmp->diag1 } }, ;
    { "диагнозов; по", {|| tmp->diag2 } }, ;
    { "Дни; 4", {|| tmp->dni4 } }, ;
    { "Дни; 3", {|| tmp->dni3 } } }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_rule_1( nk, ob, "edit" ) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( s_msg ) }
  Go Top
  // help_code := H_stat_rule_1
  edit_browse( t_arr )
  // help_code := -1
  If dostup_stat .and. f_esc_enter( 1 )
    arr := {}
    Go Top
    Do While !Eof()
      If !Empty( tmp->diag1 )
        s := AllTrim( tmp->diag1 )
        If !Empty( tmp->diag2 )
          s += "-" + AllTrim( tmp->diag2 )
        Endif
        AAdd( arr, { s, lstr( tmp->dni4 ) + "," + lstr( tmp->dni3 ) } )
      Endif
      Skip
    Enddo
    setinisect( file_stat, rule_section[ 1 ], arr )
    stat_msg( "Запись завершена!" ) ; mybell( 2, OK )
  Endif
  Close databases
  Return Nil

//
Function f1_rule_1( nKey, oBrow, regim )

  Local ret := -1
  Local buf, fl := .f., rec, k := 16, tmp_color
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }

  Do Case
  Case regim == "open"
    ret := ( LastRec() > 0 )
  Case regim == "edit"
    Do Case
    Case nKey == K_F10
      f10_diagnoz()
    Case nKey == K_F9
      rec := tmp->( RecNo() )
      print_rule( 1 )
      Select TMP
      Goto ( rec )
    Case dostup_stat .and. ( nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( tmp->diag1 ) ) )
      rec := tmp->( RecNo() )
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 4, pc1, pr1 + 4, pc2, "N/N", "W+/N" )
      Endif
      Private mdiag1, mdiag2, mdni4, mdni3, gl_area := { 1, 0, 23, 79, 0 }
      mdiag1 := if( nKey == K_INS, Space( 5 ), tmp->diag1 )
      mdiag2 := if( nKey == K_INS, Space( 5 ), tmp->diag2 )
      mdni4 := if( nKey == K_INS, 90, tmp->dni4 )
      mdni3 := if( nKey == K_INS, 90, tmp->dni3 )
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, pc1 + 1, 21, pc2 - 1,, ;
        if( nKey == K_INS, "Добавление", "Редактирование" ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 3 Say "Диагнозы: с" Get mdiag1 Pict "@!" ;
        reader {| o| mygetreader( o, bg ) } Valid val2_10diag()
      @ Row(), Col() Say ", по" Get mdiag2 Pict "@!" ;
        reader {| o| mygetreader( o, bg ) } Valid val2_10diag()
      @ k + 2, pc1 + 3 Say "Частота заболевания в днях:"
      @ k + 3, pc1 + 3 Say "- по четырехзначной рубрике" Get mdni4 Pict "999"
      @ k + 4, pc1 + 3 Say "   - по трехзначной рубрике" Get mdni3 Pict "999"
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
      myread()
      If LastKey() != K_ESC .and. !emptyany( mdiag1, mdni4 ) .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          Append Blank
          rec := tmp->( RecNo() )
        Endif
        tmp->diag1 := mdiag1
        tmp->diag2 := mdiag2
        tmp->dni4  := mdni4
        tmp->dni3  := mdni3
        Unlock
        Commit
        oBrow:gotop()
        Goto ( rec )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case dostup_stat .and. nKey == K_DEL .and. !Empty( tmp->diag1 ) .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof()
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

//
Function st_rule_2()

  Local arr, i, s, adbf, t_arr[ BR_LEN ], mtitle := rule_section[ 2 ]

  adbf := { { "diag1", "C", 5, 0 }, ;
    { "diag2", "C", 5, 0 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On diag1 + diag2 to ( cur_dir() + "tmp" )
  arr := getinisect( file_stat, rule_section[ 2 ] )
  If Empty( arr )
    If !dostup_stat
      Use
      Return func_error( 4, "Данное правило не заполнено!" )
    Endif
  Else
    Select TMP
    For i := 1 To Len( arr )
      Append Blank
      tmp->diag1 := Token( arr[ i, 1 ], "-", 1 )
      tmp->diag2 := Token( arr[ i, 1 ], "-", 2 )
    Next
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL - 10
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 35
  t_arr[ BR_OPEN ] := {|| f1_rule_2(,, "open" ) }
  t_arr[ BR_SEMAPHORE ] := mtitle
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitle
  t_arr[ BR_TITUL_COLOR ] := "B/BG"
  t_arr[ BR_ARR_BROWSE ] := {,,,, .t., 0 }
  t_arr[ BR_COLUMN ] := { { " Коды;  с", {|| tmp->diag1 } }, ;
    { "диагнозов; по", {|| tmp->diag2 } } }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_rule_2( nk, ob, "edit" ) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( s_msg ) }
  Go Top
  // help_code := H_stat_rule_2
  edit_browse( t_arr )
  // help_code := -1
  If dostup_stat .and. f_esc_enter( 1 )
    arr := {} ; i := 0
    Go Top
    Do While !Eof()
      If !Empty( tmp->diag1 )
        s := AllTrim( tmp->diag1 )
        If !Empty( tmp->diag2 )
          s += "-" + AllTrim( tmp->diag2 )
        Endif
        AAdd( arr, { s, lstr( ++i ) } )
      Endif
      Skip
    Enddo
    setinisect( file_stat, rule_section[ 2 ], arr )
    stat_msg( "Запись завершена!" ) ; mybell( 2, OK )
  Endif
  Close databases
  Return Nil

//
Function f1_rule_2( nKey, oBrow, regim )

  Local ret := -1
  Local buf, fl := .f., rec, k := 16, tmp_color
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }

  Do Case
  Case regim == "open"
    ret := ( LastRec() > 0 )
  Case regim == "edit"
    Do Case
    Case nKey == K_F10
      f10_diagnoz()
    Case nKey == K_F9
      rec := tmp->( RecNo() )
      print_rule( 2 )
      Select TMP
      Goto ( rec )
    Case dostup_stat .and. ( nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( tmp->diag1 ) ) )
      rec := tmp->( RecNo() )
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 4, pc1, pr1 + 4, pc2, "N/N", "W+/N" )
      Endif
      Private mdiag1, mdiag2, gl_area := { 1, 0, 23, 79, 0 }
      mdiag1 := if( nKey == K_INS, Space( 5 ), tmp->diag1 )
      mdiag2 := if( nKey == K_INS, Space( 5 ), tmp->diag2 )
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, pc1 + 1, 21, pc2 - 1,, ;
        if( nKey == K_INS, "Добавление", "Редактирование" ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 3 Say "Диагнозы: с" Get mdiag1 Pict "@!" ;
        reader {| o| mygetreader( o, bg ) } Valid val2_10diag()
      @ k + 2, pc1 + 3 Say "         по" Get mdiag2 Pict "@!" ;
        reader {| o| mygetreader( o, bg ) } Valid val2_10diag()
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
      myread()
      If LastKey() != K_ESC .and. !Empty( mdiag1 ) .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          Append Blank
          rec := tmp->( RecNo() )
        Endif
        tmp->diag1 := mdiag1
        tmp->diag2 := mdiag2
        Unlock
        Commit
        oBrow:gotop()
        Goto ( rec )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case dostup_stat .and. nKey == K_DEL .and. !Empty( tmp->diag1 ) .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof()
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

//
Function st_rule_3()

  Local arr, i, s, adbf, t_arr[ BR_LEN ], mtitle := rule_section[ 3 ]

  adbf := { { "diag1", "C", 5, 0 }, ;
    { "diag2", "C", 5, 0 }, ;
    { "pol",  "C", 1, 0 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On diag1 + diag2 to ( cur_dir() + "tmp" )
  arr := getinisect( file_stat, rule_section[ 3 ] )
  If Empty( arr )
    If !dostup_stat
      Use
      Return func_error( 4, "Данное правило не заполнено!" )
    Endif
  Else
    Select TMP
    For i := 1 To Len( arr )
      Append Blank
      tmp->diag1 := Token( arr[ i, 1 ], "-", 1 )
      tmp->diag2 := Token( arr[ i, 1 ], "-", 2 )
      tmp->pol   := arr[ i, 2 ]
    Next
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL - 10
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 35
  t_arr[ BR_OPEN ] := {|| f1_rule_3(,, "open" ) }
  t_arr[ BR_SEMAPHORE ] := mtitle
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitle
  t_arr[ BR_TITUL_COLOR ] := "B/BG"
  t_arr[ BR_ARR_BROWSE ] := {,,,, .t., 0 }
  t_arr[ BR_COLUMN ] := { { " Коды;  с", {|| tmp->diag1 } }, ;
    { "диагнозов; по", {|| tmp->diag2 } }, ;
    { "Пол", {|| tmp->pol } } }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_rule_3( nk, ob, "edit" ) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( s_msg ) }
  Go Top
  // help_code := H_stat_rule_3
  edit_browse( t_arr )
  // help_code := -1
  If dostup_stat .and. f_esc_enter( 1 )
    arr := {}
    Go Top
    Do While !Eof()
      If !Empty( tmp->diag1 )
        s := AllTrim( tmp->diag1 )
        If !Empty( tmp->diag2 )
          s += "-" + AllTrim( tmp->diag2 )
        Endif
        AAdd( arr, { s, tmp->pol } )
      Endif
      Skip
    Enddo
    setinisect( file_stat, rule_section[ 3 ], arr )
    stat_msg( "Запись завершена!" ) ; mybell( 2, OK )
  Endif
  Close databases
  Return Nil

//
Function f1_rule_3( nKey, oBrow, regim )

  Local ret := -1
  Local buf, fl := .f., rec, k := 16, tmp_color
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }

  Do Case
  Case regim == "open"
    ret := ( LastRec() > 0 )
  Case regim == "edit"
    Do Case
    Case nKey == K_F10
      f10_diagnoz()
    Case nKey == K_F9
      rec := tmp->( RecNo() )
      print_rule( 3 )
      Select TMP
      Goto ( rec )
    Case dostup_stat .and. ( nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( tmp->diag1 ) ) )
      rec := tmp->( RecNo() )
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 4, pc1, pr1 + 4, pc2, "N/N", "W+/N" )
      Endif
      Private mdiag1, mdiag2, mpol, gl_area := { 1, 0, 23, 79, 0 }
      mdiag1 := if( nKey == K_INS, Space( 5 ), tmp->diag1 )
      mdiag2 := if( nKey == K_INS, Space( 5 ), tmp->diag2 )
      mpol := if( nKey == K_INS, "Ж", tmp->pol )
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, pc1 + 1, 21, pc2 - 1,, ;
        if( nKey == K_INS, "Добавление", "Редактирование" ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 3 Say "Диагнозы: с" Get mdiag1 Pict "@!" ;
        reader {| o| mygetreader( o, bg ) } Valid val2_10diag()
      @ k + 2, pc1 + 3 Say "         по" Get mdiag2 Pict "@!" ;
        reader {| o| mygetreader( o, bg ) } Valid val2_10diag()
      If mem_pol == 1
        @ k + 3, pc1 + 3 Say "Пол" Get mpol reader {| x| menu_reader( x, menupol, A__MENUVERT,,, .f. ) }
      Else
        @ k + 3, pc1 + 3 Say "Пол" Get mpol Pict "@!" valid {| g| mpol $ "МЖ" }
      Endif
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
      myread()
      If LastKey() != K_ESC .and. !emptyany( mdiag1, mpol ) .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          Append Blank
          rec := tmp->( RecNo() )
        Endif
        tmp->diag1 := mdiag1
        tmp->diag2 := mdiag2
        tmp->pol   := mpol
        Unlock
        Commit
        oBrow:gotop()
        Goto ( rec )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case dostup_stat .and. nKey == K_DEL .and. !Empty( tmp->diag1 ) .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof()
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

//
Function st_rule_4()

  Local arr, i, s, adbf, t_arr[ BR_LEN ], mtitle := rule_section[ 4 ]

  adbf := { { "diag1", "C", 5, 0 }, ;
    { "diag2", "C", 5, 0 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On diag1 + diag2 to ( cur_dir() + "tmp" )
  arr := getinisect( file_stat, rule_section[ 4 ] )
  If Empty( arr )
    If !dostup_stat
      Use
      Return func_error( 4, "Данное правило не заполнено!" )
    Endif
  Else
    Select TMP
    For i := 1 To Len( arr )
      Append Blank
      tmp->diag1 := Token( arr[ i, 1 ], "-", 1 )
      tmp->diag2 := Token( arr[ i, 1 ], "-", 2 )
    Next
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL - 10
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 35
  t_arr[ BR_OPEN ] := {|| f1_rule_4(,, "open" ) }
  t_arr[ BR_SEMAPHORE ] := mtitle
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitle
  t_arr[ BR_TITUL_COLOR ] := "B/BG"
  t_arr[ BR_ARR_BROWSE ] := {,,,, .t., 0 }
  t_arr[ BR_COLUMN ] := { { " Коды;  с", {|| tmp->diag1 } }, ;
    { "диагнозов; по", {|| tmp->diag2 } } }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_rule_4( nk, ob, "edit" ) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( s_msg ) }
  Go Top
  // help_code := H_stat_rule_4
  edit_browse( t_arr )
  // help_code := -1
  If dostup_stat .and. f_esc_enter( 1 )
    arr := {} ; i := 0
    Go Top
    Do While !Eof()
      If !Empty( tmp->diag1 )
        s := AllTrim( tmp->diag1 )
        If !Empty( tmp->diag2 )
          s += "-" + AllTrim( tmp->diag2 )
        Endif
        AAdd( arr, { s, lstr( ++i ) } )
      Endif
      Skip
    Enddo
    setinisect( file_stat, rule_section[ 4 ], arr )
    stat_msg( "Запись завершена!" ) ; mybell( 2, OK )
  Endif
  Close databases
  Return Nil

//
Function f1_rule_4( nKey, oBrow, regim )

  Local ret := -1
  Local buf, fl := .f., rec, k := 16, tmp_color
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }

  Do Case
  Case regim == "open"
    ret := ( LastRec() > 0 )
  Case regim == "edit"
    Do Case
    Case nKey == K_F10
      f10_diagnoz()
    Case nKey == K_F9
      rec := tmp->( RecNo() )
      print_rule( 4 )
      Select TMP
      Goto ( rec )
    Case dostup_stat .and. ( nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( tmp->diag1 ) ) )
      rec := tmp->( RecNo() )
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 4, pc1, pr1 + 4, pc2, "N/N", "W+/N" )
      Endif
      Private mdiag1, mdiag2, gl_area := { 1, 0, 23, 79, 0 }
      mdiag1 := if( nKey == K_INS, Space( 5 ), tmp->diag1 )
      mdiag2 := if( nKey == K_INS, Space( 5 ), tmp->diag2 )
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, pc1 + 1, 21, pc2 - 1,, ;
        if( nKey == K_INS, "Добавление", "Редактирование" ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 3 Say "Диагнозы: с" Get mdiag1 Pict "@!" ;
        reader {| o| mygetreader( o, bg ) } Valid val2_10diag()
      @ k + 2, pc1 + 3 Say "         по" Get mdiag2 Pict "@!" ;
        reader {| o| mygetreader( o, bg ) } Valid val2_10diag()
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
      myread()
      If LastKey() != K_ESC .and. !Empty( mdiag1 ) .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          Append Blank
          rec := tmp->( RecNo() )
        Endif
        tmp->diag1 := mdiag1
        tmp->diag2 := mdiag2
        Unlock
        Commit
        oBrow:gotop()
        Goto ( rec )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case dostup_stat .and. nKey == K_DEL .and. !Empty( tmp->diag1 ) .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof()
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

//
Function st_rule_5()

  Local arr, mbukva := ""

  arr := getinisect( file_stat, rule_section[ 5 ] )
  If Empty( arr )
    If !dostup_stat
      Use
      Return func_error( 4, "Данное правило не заполнено!" )
    Endif
  Else
    mbukva := arr[ 1, 2 ]
  Endif
  mbukva := PadR( mbukva, 5 )
  // help_code := H_stat_rule_5
  If ( mbukva := input_value( 20, 10, 22, 69, color1, ;
      "  Буквы, которые встречаются не более раза в году", ;
      mbukva, "@!" ) ) != NIL
    arr := {}
    If !Empty( mbukva )
      arr := { { "bukva", mbukva } }
    Endif
    setinisect( file_stat, rule_section[ 5 ], arr )
    stat_msg( "Запись завершена!" ) ; mybell( 2, OK )
  Endif
  // help_code := -1
  Return Nil

//
Function st_rule_6()

  Local arr, i, s, adbf, t_arr[ BR_LEN ], mtitle := rule_section[ 6 ]

  adbf := { { "bukva1", "C", 1, 0 }, ;
    { "bukva2", "C", 1, 0 }, ;
    { "bukva", "C", 1, 0 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On bukva1 + bukva2 to ( cur_dir() + "tmp" )
  arr := getinisect( file_stat, rule_section[ 6 ] )
  If Empty( arr )
    If !dostup_stat
      Use
      Return func_error( 4, "Данное правило не заполнено!" )
    Endif
  Else
    Select TMP
    For i := 1 To Len( arr )
      Append Blank
      tmp->bukva1 := Token( arr[ i, 1 ], "-", 1 )
      tmp->bukva2 := Token( arr[ i, 1 ], "-", 2 )
      tmp->bukva  := arr[ i, 2 ]
    Next
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL - 10
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 35
  t_arr[ BR_OPEN ] := {|| f1_rule_6(,, "open" ) }
  t_arr[ BR_SEMAPHORE ] := mtitle
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitle
  t_arr[ BR_TITUL_COLOR ] := "B/BG"
  t_arr[ BR_ARR_BROWSE ] := {,,,, .t., 0 }
  t_arr[ BR_COLUMN ] := { { "Первая;буква", {|| tmp->bukva1 } }, ;
    { "Вторая;буква", {|| tmp->bukva2 } }, ;
    { "Какую букву;оставить", {|| tmp->bukva } } }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_rule_6( nk, ob, "edit" ) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( s_msg ) }
  Go Top
  // help_code := H_stat_rule_6
  edit_browse( t_arr )
  // help_code := -1
  If dostup_stat .and. f_esc_enter( 1 )
    arr := {}
    Go Top
    Do While !Eof()
      If !emptyall( tmp->bukva1, tmp->bukva2, tmp->bukva )
        s := tmp->bukva1 + "-" + tmp->bukva2
        AAdd( arr, { s, tmp->bukva } )
      Endif
      Skip
    Enddo
    setinisect( file_stat, rule_section[ 6 ], arr )
    stat_msg( "Запись завершена!" ) ; mybell( 2, OK )
  Endif
  Close databases
  Return Nil

//
Function f1_rule_6( nKey, oBrow, regim )

  Local ret := -1
  Local buf, fl := .f., rec, k := 16, tmp_color

  Do Case
  Case regim == "open"
    ret := ( LastRec() > 0 )
  Case regim == "edit"
    Do Case
    Case nKey == K_F9
      rec := tmp->( RecNo() )
      print_rule( 6 )
      Select TMP
      Goto ( rec )
    Case dostup_stat .and. ( nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( tmp->bukva1 ) ) )
      rec := tmp->( RecNo() )
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 4, pc1, pr1 + 4, pc2, "N/N", "W+/N" )
      Endif
      Private mbukva1, mbukva2, mbukva, gl_area := { 1, 0, 23, 79, 0 }
      mbukva1 := if( nKey == K_INS, " ", tmp->bukva1 )
      mbukva2 := if( nKey == K_INS, " ", tmp->bukva2 )
      mbukva  := if( nKey == K_INS, " ", tmp->bukva )
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, pc1 + 1, 21, pc2 - 1,, ;
        if( nKey == K_INS, "Добавление", "Редактирование" ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 3 Say "Первая буква" Get mbukva1 Pict "@!"
      @ k + 2, pc1 + 3 Say "Вторая буква" Get mbukva2 Pict "@!"
      @ k + 4, pc1 + 3 Say "Какая буква остается" Get mbukva Pict "@!"
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
      myread()
      If LastKey() != K_ESC .and. !emptyall( mbukva1, mbukva2, mbukva ) .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          Append Blank
          rec := tmp->( RecNo() )
        Endif
        tmp->bukva1 := mbukva1
        tmp->bukva2 := mbukva2
        tmp->bukva  := mbukva
        Unlock
        Commit
        oBrow:gotop()
        Goto ( rec )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case dostup_stat .and. nKey == K_DEL .and. !Empty( tmp->bukva1 ) .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof()
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

//
Function print_rule( n )

  Local sh := 80, HH := 58, reg_print := 2, ;
    s, n_file := cur_dir() + 'rule' + iif( prs == 1, 'KOM', 'LPU' ) + lstr( n ) + stxt(), ;
    buf := save_maxrow()

  //
  mywait()
  fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
  add_string( Center( { "Комитет по здравоохранению", "ЛПУ" }[ prs ], sh ) )
  add_string( Center( Expand( "СТАТИСТИКА: ПРАВИЛО НОМЕР " + lstr( n ) ), sh ) )
  add_string( Center( rule_section[ n ], sh ) )
  add_string( "" )
  Select TMP
  Go Top
  Do While !Eof()
    verify_ff( HH, .t., sh )
    s := ""
    Do Case
    Case n == 1
      If !Empty( tmp->diag1 )
        s := AllTrim( tmp->diag1 )
        If !Empty( tmp->diag2 )
          s += " - " + AllTrim( tmp->diag2 )
        Endif
        s := PadR( s, 15 )
        If tmp->dni4 > 0
          s += "[ " + lstr( tmp->dni4 )
          If tmp->dni3 > 0 .and. tmp->dni3 != tmp->dni4
            s += " (" + lstr( tmp->dni3 ) + ")"
          Endif
          s += " дней ]"
        Endif
      Endif
    Case n == 2
      If !Empty( tmp->diag1 )
        s := AllTrim( tmp->diag1 )
        If !Empty( tmp->diag2 )
          s += " - " + AllTrim( tmp->diag2 )
        Endif
      Endif
    Case n == 3
      If !Empty( tmp->diag1 )
        s := AllTrim( tmp->diag1 )
        If !Empty( tmp->diag2 )
          s += " - " + AllTrim( tmp->diag2 )
        Endif
        s := PadR( s, 15 ) + "пол: " + tmp->pol
      Endif
    Case n == 4
      If !Empty( tmp->diag1 )
        s := AllTrim( tmp->diag1 )
        If !Empty( tmp->diag2 )
          s += " - " + AllTrim( tmp->diag2 )
        Endif
      Endif
    Case n == 5
      If !Empty( tmp->bukva )
        s := tmp->bukva
      Endif
    Case n == 6
      If !emptyall( tmp->bukva1, tmp->bukva2, tmp->bukva )
        s := tmp->bukva1 + "-" + tmp->bukva2 + " ===> " + tmp->bukva
      Endif
    Endcase
    If !Empty( s )
      add_string( s )
    Endif
    Select TMP
    Skip
  Enddo
  FClose( fp )
  rest_box( buf )
  viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
  Return Nil

//
Function get_nas_rule()

  Local ar := getinisect( f_stat_lpu(), sect_nastr ), ar2, i, j

  If Len( ar ) == 0
    m1print := { 11, 13 }
  Endif
  For i := 1 To Len( ar )
    ar2 := {}
    For j := 1 To NumToken( ar[ i, 2 ], "," )
      AAdd( ar2, Int( Val( Token( ar[ i, 2 ], ",", j ) ) ) )
    Next
    Do Case
    Case ar[ i, 1 ] == nastr_print
      m1print := ar2
    Case ar[ i, 1 ] == nastr_vvod
      m1vvod := ar2
    Case ar[ i, 1 ] == nastr_diagn
      m1diagn := ar2
    Case ar[ i, 1 ] == nastr_f12
      m1f12 := ar2
    Case ar[ i, 1 ] == nastr_f57
      m1f57 := ar2
    Endcase
  Next
  Return Nil

//
Function a_nastr_rule()

  Local arr := { { "КОМ-1", 11 }, ;
    { "КОМ-2", 12 }, ;
    { "КОМ-3", 13 }, ;
    { "ЛПУ-1", 21 }, ;
    { "ЛПУ-2", 22 }, ;
    { "ЛПУ-3", 23 }, ;
    { "ЛПУ-4", 24 } }

  If yes_bukva
    AAdd( arr, { "ЛПУ-5", 25 } )
    AAdd( arr, { "ЛПУ-6", 26 } )
  Endif
  Return arr

//
Function i_nastr_rule( ar )

  Local sk := "КОМ: ", sl := "ЛПУ: ", flk := .f., fll := .f., i, s := ""

  For i := 1 To Len( ar )
    If ar[ i ] <= 20
      flk := .t.
      sk += Right( lstr( ar[ i ] ), 1 ) + ","
    Else
      fll := .t.
      sl += Right( lstr( ar[ i ] ), 1 ) + ","
    Endif
  Next
  If flk
    s := Left( sk, Len( sk ) -1 )
    If fll
      s += "  "
    Endif
  Endif
  If fll
    s += Left( sl, Len( sl ) -1 )
  Endif
  Return iif( Empty( s ), "-= нет =-", s )

//
Function inp_nas_rule( k, r, c )

  Local nr, i, s, r1, r2, ret, t_mas := {}, buf, buf1

  nr := Len( arr_name_rule )
  For i := 1 To nr
    If AScan( k, arr_name_rule[ i, 2 ] ) > 0
      s := " * "
    Else
      s := Space( 3 )
    Endif
    s += arr_name_rule[ i, 1 ]
    AAdd( t_mas, s )
  Next
  r2 := r - 1
  r1 := r2 - nr -1
  buf := save_box( r1, c, r2 + 1, c + 14 )
  buf1 := save_maxrow()
  status_key( "^<Esc>^ отказ; ^<Enter>^ выбор; ^<Ins,+,->^ смена признака включения данного правила" )
  If Popup( r1, c, r2, c + 12, t_mas,, color0, .t., "fmenu_reader" ) > 0
    k := {}
    For i := 1 To nr
      If "*" == SubStr( t_mas[ i ], 2, 1 )
        AAdd( k, arr_name_rule[ i, 2 ] )
      Endif
    Next
    ret := { k, i_nastr_rule( k ) }
  Endif
  rest_box( buf )
  rest_box( buf1 )
  Return ret

//
Function nastr_rule()

  Local buf := SaveScreen()
  Local r1 := 12, c1 := 2, r2 := 22, c2 := 77, tmp_color, s, arr
  Private arr_name_rule := a_nastr_rule()

  box_shadow( r1, c1, r2, c2, color1, "Настройка работы с правилами статистики", color8 )
  Private mprint, m1print := {}, ;
    mvvod, m1vvod := {}, ;
    mdiagn, m1diagn := {}, ;
    mf12, m1f12 := {}, ;
    mf57, m1f57 := {}
  get_nas_rule()
  mprint := i_nastr_rule( m1print )
  mvvod  := i_nastr_rule( m1vvod )
  mdiagn := i_nastr_rule( m1diagn )
  mf12   := i_nastr_rule( m1f12 )
  mf57   := i_nastr_rule( m1f57 )
  str_center( r1 + 2, "В каких режимах с какими правилами работаем:", "G+/B" )
  tmp_color := SetColor( cDataCGet )
  @ r1 + 4, c1 + 2 Say "В режиме проверки                          " Get mprint reader ;
    {| x| menu_reader( x, { {| k, r, c| inp_nas_rule( k, r, c ) } }, A__FUNCTION,,, .f. ) }
  @ r1 + 5, c1 + 2 Say "При вводе листа учета    (пока не работает)" Get mvvod  reader ;
    {| x| menu_reader( x, { {| k, r, c| inp_nas_rule( k, r, c ) } }, A__FUNCTION,,, .f. ) }
  @ r1 + 6, c1 + 2 Say "В статистике по диагнозам(пока не работает)" Get mdiagn reader ;
    {| x| menu_reader( x, { {| k, r, c| inp_nas_rule( k, r, c ) } }, A__FUNCTION,,, .f. ) }
  @ r1 + 7, c1 + 2 Say "В статистической форме 12                  " Get mf12   reader ;
    {| x| menu_reader( x, { {| k, r, c| inp_nas_rule( k, r, c ) } }, A__FUNCTION,,, .f. ) }
  @ r1 + 8, c1 + 2 Say "В статистической форме 57                  " Get mf57   reader ;
    {| x| menu_reader( x, { {| k, r, c| inp_nas_rule( k, r, c ) } }, A__FUNCTION,,, .f. ) }
  status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода;  ^<F1>^ - помощь" )
  // help_code := H_nastr_rule
  myread()
  // help_code := -1
  If f_esc_enter( 1 )
    arr := {}
    s := ""
    AEval( m1print, {| x| s += lstr( x ) + "," } )
    AAdd( arr, { nastr_print, Left( s, Len( s ) -1 ) } )
    s := ""
    AEval( m1vvod, {| x| s += lstr( x ) + "," } )
    AAdd( arr, { nastr_vvod, Left( s, Len( s ) -1 ) } )
    s := ""
    AEval( m1diagn, {| x| s += lstr( x ) + "," } )
    AAdd( arr, { nastr_diagn, Left( s, Len( s ) -1 ) } )
    s := ""
    AEval( m1f12, {| x| s += lstr( x ) + "," } )
    AAdd( arr, { nastr_f12, Left( s, Len( s ) -1 ) } )
    s := ""
    AEval( m1f57, {| x| s += lstr( x ) + "," } )
    AAdd( arr, { nastr_f57, Left( s, Len( s ) -1 ) } )
    setinisect( f_stat_lpu(), sect_nastr, arr )
  Endif
  SetColor( tmp_color )
  RestScreen( buf )

  Return Nil

// 05.01.17
Function read_rule( regim )

  Local sregim := ""
  Local i, j, j1, s, arr, adbf, file_stat, val_stroke := " ", ret := .f.
  Local ar_nastr := getinisect( f_stat_lpu(), sect_nastr )

  Do Case
  Case regim == D_RULE_N_PRINT
    sregim := nastr_print
  Case regim == D_RULE_N_VVOD
    sregim := nastr_vvod
  Case regim == D_RULE_N_DIAGN
    sregim := nastr_diagn
  Case regim == D_RULE_N_F12
    sregim := nastr_f12
  Case regim == D_RULE_N_F57
    sregim := nastr_f57
  Endcase
  For i := 1 To Len( ar_nastr )
    If ar_nastr[ i, 1 ] == sregim
      val_stroke := ar_nastr[ i, 2 ]
      Exit
    Endif
  Next
  adbf := { { "kod",   "N", 6, 0 }, ;
    { "tip",   "N", 1, 0 }, ;
    { "shifr", "C", 5, 0 }, ;
    { "dnum",  "N", 6, 0 }, ;
    { "dispan", "N", 1, 0 }, ;
    { "num_kol", "N", 2, 0 }, ;
    { "kol1",  "N", 6, 0 }, ;
    { "kol2",  "N", 6, 0 } }
  dbCreate( cur_dir() + "tmp1rule", adbf )
  Use ( cur_dir() + "tmp1rule" ) new
  Index On Str( tip, 1 ) + shifr to ( cur_dir() + "tmp1rule" )
  adbf := { { "kod",   "N", 6, 0 }, ;
    { "n_data", "D", 8, 0 }, ;
    { "k_data", "D", 8, 0 }, ;
    { "harak", "N", 1, 0 }, ;
    { "dispan", "N", 1, 0 }, ;
    { "travma", "C", 20, 0 }, ;
    { "num_kol", "N", 2, 0 }, ;
    { "bukva", "C", 15, 0 } }
  dbCreate( cur_dir() + "tmp2rule", adbf )
  Use ( cur_dir() + "tmp2rule" ) new
  Index On Str( kod, 6 ) + DToS( k_data ) to ( cur_dir() + "tmp2rule" )
  adbf := { { "rule",  "N", 1, 0 }, ;
    { "tip",   "N", 1, 0 }, ;
    { "diag1", "C", 5, 0 }, ;
    { "diag2", "C", 5, 0 }, ;
    { "dnum1", "N", 6, 0 }, ;
    { "dnum2", "N", 6, 0 }, ;
    { "bukva1", "C", 1, 0 }, ;
    { "bukva2", "C", 1, 0 }, ;
    { "bukva", "C", 5, 0 }, ;
    { "pol",   "C", 1, 0 }, ;
    { "num_kol", "N", 2, 0 }, ;
    { "dni4",  "N", 3, 0 }, ;
    { "dni3",  "N", 3, 0 } }
  dbCreate( cur_dir() + "tmp_rule", adbf )
  Use ( cur_dir() + "tmp_rule" ) new
  For j1 := 1 To 2   // 1 - комитет, 2 - ЛПУ
    file_stat := { f_stat_com(), f_stat_lpu() }[ j1 ]
    For j := 1 To 6    // номер правила
      s := lstr( j1 ) + lstr( j )
      If s $ val_stroke
        arr := getinisect( file_stat, rule_section[ j ] )
        If !Empty( arr )
          For i := 1 To Len( arr )
            ret := .t.
            Append Blank
            tmp_rule->rule := j  // номер правила
            tmp_rule->tip := j1  // 1 - комитет, 2 - ЛПУ
            If j < 5
              tmp_rule->diag1 := Token( arr[ i, 1 ], "-", 1 )
              tmp_rule->diag2 := Token( arr[ i, 1 ], "-", 2 )
              If Empty( tmp_rule->diag2 )
                tmp_rule->diag2 := tmp_rule->diag1
              Endif
              If j == 1
                tmp_rule->dni4 := Int( Val( Token( arr[ i, 2 ], ",", 1 ) ) )
                tmp_rule->dni3 := Int( Val( Token( arr[ i, 2 ], ",", 2 ) ) )
              Elseif j == 3
                tmp_rule->pol := Upper( arr[ i, 2 ] )
              Endif
              tmp_rule->dnum1 := diag_to_num( tmp_rule->diag1, 1 )
              tmp_rule->dnum2 := diag_to_num( tmp_rule->diag2, 2 )
            Elseif j == 5
              mbukva5 := AllTrim( arr[ i, 2 ] )
            Elseif j == 6
              tmp_rule->bukva1 := Token( arr[ i, 1 ], "-", 1 )
              tmp_rule->bukva2 := Token( arr[ i, 1 ], "-", 2 )
              tmp_rule->bukva  := arr[ i, 2 ]
            Endif
          Next
        Endif
      Endif
    Next
  Next
  Index On Str( rule, 1 ) + Str( dnum2, 6 ) to ( cur_dir() + "tmp_rule" )
  Return ret

// для проверялки
Function verify_rule( arr_bukva, lpol )

  Local i, j, k, ta := {}, lb := Len( arr_bukva ), s, ta3 := {}

  // правило 1
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
        If tmp1rule->kol2 > 0  // указан характер ПОВТОРНОЕ
          AAdd( ta, f1_ver_rule( tmp1rule->shifr, tmp_rule->tip, 1, 2 ) )
        Elseif tmp1rule->kol1 == 0  // не указан характер ПЕРВИЧНОЕ
          AAdd( ta, f1_ver_rule( tmp1rule->shifr, tmp_rule->tip, 1, 1 ) )
        Elseif tmp1rule->kol1 > 1 ; // характер ПЕРВИЧНОЕ указан более 1 раза
          .and. f2_ver_rule( tmp1rule->kod, tmp_rule->dni4 )
          AAdd( ta, f1_ver_rule( tmp1rule->shifr, tmp_rule->tip, 1, 4 ) )
        Else
        Endif
      Else // хроническое заболевание для пятизначного диагноза
        If tmp1rule->kol1 + tmp1rule->kol2 > 1
          AAdd( ta, f1_ver_rule( tmp1rule->shifr, tmp_rule->tip, 1, 3 ) )
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
        If tmp1rule->kol1 > 1 ; // характер ПЕРВИЧНОЕ указан более 1 раза
          .and. tmp_rule->dni3 > 0 .and. f2_ver_rule( tmp1rule->kod, tmp_rule->dni3 )
          AAdd( ta, f1_ver_rule( tmp1rule->shifr, tmp_rule->tip, 1, 4 ) )
        Else
          //
        Endif
      Else // хроническое заболевание для трехзначного диагноза
        If tmp1rule->kol1 + tmp1rule->kol2 > 1
          AAdd( ta, f1_ver_rule( tmp1rule->shifr, tmp_rule->tip, 1, 3 ) )
        Endif
      Endif
      Select TMP1RULE
      Skip
    Enddo
  Endif
  // правило 2
  // пока нет такого правила
  // правило 3
  Select TMP1RULE
  find ( "1" )
  Do While tmp1rule->tip == 1 .and. !Eof()
    Select TMP_RULE
    dbSeek( "3" + Str( tmp1rule->dnum, 6 ), .t. )
    If tmp_rule->rule == 3 .and. !( tmp_rule->pol == lpol ) ;
        .and. Between( tmp1rule->dnum, tmp_rule->dnum1, tmp_rule->dnum2 )
      AAdd( ta, f1_ver_rule( tmp1rule->shifr, tmp_rule->tip, 3 ) )
    Endif
    Select TMP1RULE
    Skip
  Enddo
  // правило 4
  Select TMP1RULE
  find ( "1" )
  Do While tmp1rule->tip == 1 .and. !Eof()
    Select TMP_RULE
    dbSeek( "4" + Str( tmp1rule->dnum, 6 ), .t. )
    If tmp_rule->rule == 4 .and. Between( tmp1rule->dnum, tmp_rule->dnum1, tmp_rule->dnum2 )
      AAdd( ta, f1_ver_rule( tmp1rule->shifr, tmp_rule->tip, 4 ) )
    Endif
    Select TMP1RULE
    Skip
  Enddo
  // правило 5
  If len5 > 0 .and. lb > 0
    fl := .f.
    // обнулим второй элемент
    For i := 1 To len5
      marr5[ i, 2 ] := 0
    Next
    For i := 1 To lb
      For j := 1 To Len( arr_bukva[ i, D_RULE_BUKVA ] )
        If ( k := At( SubStr( arr_bukva[ i, D_RULE_BUKVA ], j, 1 ), mbukva5 ) ) > 0
          ++marr5[k, 2 ]
          If marr5[ k, 2 ] > 1
            fl := .t.
          Endif
        Endif
      Next
    Next
    If fl
      For k := 1 To len5
        If marr5[ k, 2 ] > 1
          s := 'Повторение буквы "' + marr5[ k, 1 ] + '"'
          For i := 1 To lb
            For j := 1 To Len( arr_bukva[ i, D_RULE_BUKVA ] )
              If SubStr( arr_bukva[ i, D_RULE_BUKVA ], j, 1 ) == marr5[ k, 1 ]
                s += ", " + Left( DToC( arr_bukva[ i, D_RULE_N_DATA ] ), 5 ) + "-";
                  + Left( DToC( arr_bukva[ i, D_RULE_K_DATA ] ), 5 )
              Endif
            Next
          Next
          AAdd( ta, f1_ver_rule( s, 2, 5 ) )
        Endif
      Next
    Endif
  Endif
  // правило 6
  Select TMP_RULE
  find ( "6" )
  Do While tmp_rule->rule == 6 .and. !Eof()
    If AScan( arr_bukva, {| x| tmp_rule->bukva1 $ x[ D_RULE_BUKVA ] } ) > 0 .and. ;
        AScan( arr_bukva, {| x| tmp_rule->bukva2 $ x[ D_RULE_BUKVA ] } ) > 0
      s := 'Сочетание букв "' + tmp_rule->bukva1 + '" и "' + tmp_rule->bukva2 + '"'
      For i := 1 To lb
        For j := 1 To Len( arr_bukva[ i, D_RULE_BUKVA ] )
          If SubStr( arr_bukva[ i, D_RULE_BUKVA ], j, 1 ) == tmp_rule->bukva1
            s += ', "' + tmp_rule->bukva1 + '": ' + ;
              Left( DToC( arr_bukva[ i, D_RULE_N_DATA ] ), 5 ) + "-";
              + Left( DToC( arr_bukva[ i, D_RULE_K_DATA ] ), 5 )
          Endif
          If SubStr( arr_bukva[ i, D_RULE_BUKVA ], j, 1 ) == tmp_rule->bukva2
            s += ', "' + tmp_rule->bukva2 + '": ' + ;
              Left( DToC( arr_bukva[ i, D_RULE_N_DATA ] ), 5 ) + "-";
              + Left( DToC( arr_bukva[ i, D_RULE_K_DATA ] ), 5 )
          Endif
        Next
      Next
      s += ', должно быть "' + AllTrim( tmp_rule->bukva ) + '"'
      AAdd( ta, f1_ver_rule( s, 2, 6 ) )
    Endif
    Skip
  Enddo

  Return ta

//
Function f1_ver_rule( _a, _n, _p, _p2 )

  Local i, s := " [правило " + iif( _n == 1, "КОМ", "ЛПУ" ) + "-" + lstr( _p ) + "]", ;
    fl_date := .f., blk := {|| .t. }

  Do Case
  Case _p == 1
    Do Case
    Case _p2 == 1
      s := _a + s + " Для острого заболевания не указан характер ПЕРВИЧНОЕ"
      fl_date := .t.
    Case _p2 == 2
      s := _a + s + " Для острого заболевания указан характер ПОВТОРНОЕ"
      blk := {| x| x == 2 }
      fl_date := .t.
    Case _p2 == 3
      s := _a + s + " Для хронического заболевания несколько раз указан характер"
      blk := {| x| x > 0 }
      fl_date := .t.
    Case _p2 == 4
      s := _a + s + " Слишком часто указан характер ПЕРВИЧНОЕ"
      blk := {| x| x == 1 }
      fl_date := .t.
    Endcase
  Case _p == 2
    //
  Case equalany( _p, 3, 4 )
    s := _a + s
    fl_date := .t.
  Case _p == 5
    s := _a + s
  Case _p == 6
    s := _a + s
  Endcase
  If fl_date
    Select TMP2RULE
    find ( Str( tmp1rule->kod, 6 ) )
    Do While tmp2rule->kod == tmp1rule->kod .and. !Eof()
      If Eval( blk, tmp2rule->harak )
        s += ", " + Left( DToC( tmp2rule->n_data ), 5 ) + "-";
          + Left( DToC( tmp2rule->k_data ), 5 )
      Endif
      Select TMP2RULE
      Skip
    Enddo
  Endif

  Return s

// Слишком часто указан характер ПЕРВИЧНОЕ - проверялка
Function f2_ver_rule( _a, _dni )

  Static sdate
  Local i, mdate1, mdate2, ret := .f.

  Default sdate To SToD( "19000101" )
  mdate1 := sdate
  Select TMP2RULE
  find ( Str( tmp1rule->kod, 6 ) )
  Do While tmp2rule->kod == tmp1rule->kod .and. !Eof()
    If tmp2rule->harak == 1
      mdate2 := tmp2rule->n_data
      If mdate2 - mdate1 < _dni
        ret := .t. ; Exit
      Endif
      mdate1 := tmp2rule->k_data
    Endif
    Select TMP2RULE
    Skip
  Enddo

  Return ret

// Слишком часто указан характер ПЕРВИЧНОЕ - исправлялка
Function f3_ver_rule( _a, _dni )

  Static sdate
  Local i, k := 0, mdate1, mdate2

  Default sdate To SToD( "19000101" )
  mdate1 := sdate
  Select TMP2RULE
  find ( Str( tmp1rule->kod, 6 ) )
  Do While tmp2rule->kod == tmp1rule->kod .and. !Eof()
    If tmp2rule->harak == 1
      ++k
      mdate2 := tmp2rule->n_data
      If mdate2 - mdate1 < _dni
        --k
      Endif
      mdate1 := tmp2rule->k_data
    Endif
    Select TMP2RULE
    Skip
  Enddo

  Return k

//
Static Function ret_f_rule( lshifr )

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

// 14.10.24
Function diag0statist()

  Static sz := 1
  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., sh, HH := 77, reg_print, speriod, fl, ;
    arr_title, name_file := cur_dir() + 's_diagn0.txt', fl_itogo := .f., ;
    jh := 0, arr_m, name_gr, j_1 := 0, j_2 := 0, a_otd := {}
  Local mas_pmt := { "по ~всем диагнозам (заболеваниям)", ;
    "по ~основному заболеванию" }
  Private is_talon := .t., adiag_talon[ 16 ], md_bukva := {}, ;
    i_lu := 0, i_human := 0, id_plus, fl_z := .f., ;
    s_lu := 0, s_human := 0, sd_plus, ;
    s_dispan := "Диспансер", fl_plus := .f., md_plus := {}, k_plus

  If ( j := popup_prompt( T_ROW, T_COL - 5, sz, mas_pmt ) ) == 0
    Return Nil
  Endif
  sz := j
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
    Return Nil
  Endif
  If Len( st_a_uch ) == 1
    glob_uch := st_a_uch[ 1 ]
    If ( st_a_otd := inputn_otd( T_ROW, T_COL - 5, .f., .f., glob_uch, @lcount_otd ) ) == NIL
      Return Nil
    Endif
    AEval( st_a_otd, {| x| AAdd( a_otd, x[ 1 ] ) } )
  Else
    r_use( dir_server() + "mo_otd",, "OTD" )
    Go Top
    Do While !Eof()
      If f_is_uch( st_a_uch, otd->kod_lpu )
        AAdd( a_otd, otd->( RecNo() ) )
      Endif
      Skip
    Enddo
    otd->( dbCloseArea() )
  Endif
  If is_talon
    AAdd( md_plus, "+" )
    AAdd( md_plus, "-" )
    AAdd( md_plus, s_dispan )
  Endif
  k_plus := Len( md_plus )
  If ( fl_plus := ( k_plus > 0 ) )
    sd_plus := Array( k_plus )
    AFill( sd_plus, 0 )
    id_plus := Array( k_plus )
    AFill( id_plus, 0 )
  Endif
  speriod := arr_m[ 4 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  arr := { ;
    { "SHIFR",      "C",      5,      0 }, ;  // диагноз
  { "SHIFR2",     "C",      5,      0 }, ;  // диагноз
  { "TIP",        "N",      1,      0 }, ;  // 0 - 3
  { "KOL",        "N",      6,      0 };   // кол-во диагнозов
  }
  If fl_plus
    For i := 1 To k_plus
      AAdd( arr, { "KOL" + lstr( i ), "N", 6, 0 } )
    Next
  Endif
  dbCreate( cur_dir() + "tmp", arr )
  Use ( cur_dir() + "tmp" ) new
  Index On shifr + Str( tip, 1 ) to ( cur_dir() + "tmp" )
  dbCreate( cur_dir() + "tmp_k", { { "kod", "N", 7, 0 }, ;
    { "kol", "N", 6, 0 } } )
  Use ( cur_dir() + "tmp_k" ) new
  Index On Str( kod, 7 ) to ( cur_dir() + "tmp_k" )
  dbCreate( cur_dir() + "tmp_i", { { "kod", "N", 7, 0 }, ;
    { "kol", "N", 6, 0 } } )
  Use ( cur_dir() + "tmp_i" ) new
  Index On Str( kod, 7 ) to ( cur_dir() + "tmp_i" )
  arr := { { "kod", "N", 7, 0 }, ;
    { "shifr", "C", 5, 0 }, ;
    { "tip", "N", 1, 0 }, ;
    { "kol", "N", 6, 0 } }
  dbCreate( cur_dir() + "tmp_b", arr )
  Use ( cur_dir() + "tmp_b" ) new
  Index On shifr + Str( tip, 1 ) + Str( kod, 7 ) to ( cur_dir() + "tmp_b" )
  f1_diag_statist_bukva()
  name_pgr := dir_exe() + "_mo_mkbg"
  name_gr := dir_exe() + "_mo_mkbk"
  r_use( name_pgr,, "PGR" )
  Index On sh_e to ( cur_dir() + "tmp_pgr" )
  r_use( name_gr,, "GR" )
  Index On sh_e to ( cur_dir() + "tmp_gr" )
  If pi1 == 1  // по дате окончания лечения
    begin_date := arr_m[ 5 ]
    end_date := arr_m[ 6 ]
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( begin_date ), .t. )
    Do While human->k_data <= end_date .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If func_pi_schet() .and. AScan( a_otd, human->otd ) > 0
        @ 24, 1 Say lstr( ++jh ) Color cColorSt2Msg
        f1diag0statist( sz )
      Endif
      Select HUMAN
      Skip
    Enddo
  Else
    begin_date := arr_m[ 7 ]
    end_date := arr_m[ 8 ]
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server() + "schet_",, "SCHET_" )
    r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( begin_date, .t. )
    Do While schet->pdate <= end_date .and. !Eof()
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If AScan( a_otd, human->otd ) > 0
          @ 24, 1 Say lstr( ++jh ) Color cColorSt2Msg
          f1diag0statist( sz )
        Endif
        Select HUMAN
        Skip
      Enddo
      Select SCHET
      Skip
    Enddo
  Endif
  j := tmp->( LastRec() )
  i_human := tmp_i->( LastRec() )
  s_human := tmp_k->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit ; Return NIL ; Endif
  If j == 0
    func_error( 4, "Нет сведений!" )
  Else
    mywait()
    reg_print := 5 ; w1 := 47
    arr_title := { ;
      "─────────────────────────────────────────────────────┬──────┬──────", ;
      "                                                     │ Боль-│ Слу- ", ;
      "                    Д и а г н о з                    │ ных  │ чаев ", ;
      "─────────────────────────────────────────────────────┴──────┴──────" }
    If fl_plus
      For i := 1 To k_plus
        If md_plus[ i ] == s_dispan
          s1 := SubStr( s_dispan, 1, 5 )
          s2 := SubStr( s_dispan, 6 )
        Else
          s1 := ""
          s2 := '"' + md_plus[ i ] + '"'
        Endif
        arr_title[ 1 ] += '╥─────'
        arr_title[ 2 ] += '║' + PadC( s1, 5 )
        arr_title[ 3 ] += '║' + PadC( s2, 5 )
        arr_title[ 4 ] += '╨─────'
      Next
    Endif
    If ( sh := Len( arr_title[ 1 ] ) ) > 85
      reg_print := 6
    Endif
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "Статистика по диагнозам", sh ) )
    titlen_uch( st_a_uch, sh, lcount_uch )
    If Len( st_a_uch ) == 1
      titlen_otd( st_a_otd, sh, lcount_otd )
    Endif
    add_string( "" )
    add_string( Center( speriod, sh ) )
    add_string( "" )
    If pi1 == 1
      add_string( Center( str_pi_schet(), sh ) )
    Else
      add_string( Center( "[ по дате выписки счета ]", sh ) )
    Endif
    If sz == 2
      add_string( Center( "{ по основному заболеванияю }", sh ) )
    Endif
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    //
    r_use( name_pgr,, "PGR" )
    Index On sh_b to ( cur_dir() + "tmp_pgr" )
    r_use( name_gr,, "GR" )
    Index On sh_b to ( cur_dir() + "tmp_gr" )
    r_use( dir_exe() + "_mo_mkb", cur_dir() + "_mo_mkb", "MKB10" )
    Use ( cur_dir() + "tmp_b" ) index ( cur_dir() + "tmp_b" ) new
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
    Go Top
    Do While !Eof()
      s := ""
      If tmp->tip == 0
        Select GR
        find ( Left( tmp->shifr, 3 ) )
        If ( fl := Found() )
          Do While gr->sh_b == Left( tmp->shifr, 3 ) .and. !Eof()
            s += AllTrim( gr->name ) + " "
            Skip
          Enddo
        Endif
        k := perenos( arr, s, w1 - 2 )
        s := Left( tmp->shifr, 3 ) + "-" + Left( tmp->shifr2, 3 ) + " " + PadR( arr[ 1 ], w1 - 2 )
        sk := 8
      Elseif tmp->tip == 1
        Select PGR
        find ( Left( tmp->shifr, 3 ) )
        If ( fl := Found() )
          Do While pgr->sh_b == Left( tmp->shifr, 3 ) .and. !Eof()
            s += AllTrim( pgr->name ) + " "
            Skip
          Enddo
        Endif
        k := perenos( arr, s, w1 - 4 )
        s := "  " + Left( tmp->shifr, 3 ) + "-" + Left( tmp->shifr2, 3 ) + " " + PadR( arr[ 1 ], w1 - 4 )
        sk := 10
      Else
        Select MKB10
        find ( tmp->shifr )
        s := AllTrim( mkb10->name ) + " "
        Skip
        Do While Left( mkb10->shifr, 5 ) == tmp->shifr .and. mkb10->ks > 0 ;
            .and. !Eof()
          s += AllTrim( mkb10->name ) + " "
          Skip
        Enddo
        If tmp->tip == 2
          k := perenos( arr, s, w1 - 2 )
          s := Space( 4 ) + Left( tmp->shifr, 3 ) + " " + PadR( arr[ 1 ], w1 - 2 )
          sk := 8
        Else
          k := perenos( arr, s, w1 - 6 )
          s := Space( 6 ) + tmp->shifr + " " + PadR( arr[ 1 ], w1 - 6 )
          sk := 12
        Endif
      Endif
      If Left( LTrim( s ), 1 ) == "Z" .and. !fl_itogo
        add_string( Replicate( "─", sh ) )
        si := PadL( "Итого: ", w1 + 6 ) + Str( i_human, 7 ) + Str( i_lu, 7 )
        If fl_plus
          For i := 1 To k_plus
            si += Str( id_plus[ i ], 6 )
          Next
        Endif
        add_string( si )
        add_string( Replicate( "─", sh ) )
        fl_itogo := .t.
      Endif
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      j := 0
      Select TMP_B
      find ( tmp->shifr + Str( tmp->tip, 1 ) )
      dbEval( {|| ++j },, {|| tmp_b->shifr == tmp->shifr .and. tmp_b->tip == tmp->tip } )
      s += Str( j, 7 )
      s += Str( tmp->kol, 7 )
      For i := 1 To k_plus
        pole := "tmp->kol" + lstr( i )
        s += put_val( &pole, 6 )
      Next
      add_string( s )
      For i := 2 To k
        add_string( Space( sk ) + arr[ i ] )
      Next
      Select TMP
      Skip
    Enddo
    If fl_z
      add_string( Replicate( "─", sh ) )
      si := PadL( "Всего: ", w1 + 6 ) + Str( s_human, 7 ) + Str( s_lu, 7 )
      If fl_plus
        For i := 1 To k_plus
          si += Str( sd_plus[ i ], 6 )
        Next
      Endif
      add_string( si )
    Endif
    f3_diag_statist_bukva( HH, sh, arr_title )
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif

  Return Nil

//
Function f1diag0statist( sz )

  Local arr_d1 := {}, arr_d2 := {}, arr_d3 := {}, arr_d4 := {}
  Local arr, i, j, mshifr, ar, pshifr, s, pole, fl_i, all_i := .f.

  f2_diag_statist_bukva()
  AFill( adiag_talon, 0 )
  For i := 1 To 16
    adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
  Next
  arr := diag_to_array(,,, .f. )
  If sz == 2
    ASize( arr, 1 )
  Endif
  For i := 1 To Len( arr )
    If !Empty( arr[ i ] )
      If Left( arr[ i ], 1 ) == "Z"
        fl_z := .t.  // private - переменная
      Else
        all_i := .t.  // не только "Z" у данного больного
      Endif
    Endif
  Next
  For i := 1 To Len( arr )
    mshifr := PadR( arr[ i ], 5 )
    If Empty( mshifr )
      Loop
    Endif
    fl_i := !( Left( arr[ i ], 1 ) == "Z" )
    ar := {}
    If "." $ mshifr  // 4-х/значный шифр
      Select TMP
      find ( mshifr + "3" )
      If !Found()
        Append Blank
        tmp->shifr := mshifr
        tmp->tip := 3
      Endif
      If AScan( arr_d1, mshifr ) == 0
        AAdd( arr_d1, mshifr )
        tmp->kol++
      Endif
      AAdd( ar, tmp->( RecNo() ) )
    Endif
    //
    pshifr := PadR( Left( mshifr, 3 ), 5 )
    Select TMP
    find ( pshifr + "2" )
    If !Found()
      Append Blank
      tmp->shifr := pshifr
      tmp->tip := 2
    Endif
    If AScan( arr_d2, pshifr ) == 0
      AAdd( arr_d2, pshifr )
      tmp->kol++
    Endif
    AAdd( ar, tmp->( RecNo() ) )
    //
    pshifr := Left( pshifr, 3 )
    Select PGR
    dbSeek( pshifr, .t. )
    Select TMP
    find ( pgr->sh_b + "  1" )
    If !Found()
      Append Blank
      tmp->shifr := pgr->sh_b
      tmp->shifr2 := pgr->sh_e
      tmp->tip := 1
    Endif
    pshifr := PadR( pgr->sh_b, 5 )
    If AScan( arr_d3, pshifr ) == 0
      AAdd( arr_d3, pshifr )
      tmp->kol++
    Endif
    AAdd( ar, tmp->( RecNo() ) )
    //
    Select GR
    dbSeek( pshifr, .t. )
    Select TMP
    find ( gr->sh_b + "  0" )
    If !Found()
      Append Blank
      tmp->shifr := gr->sh_b
      tmp->shifr2 := gr->sh_e
      tmp->tip := 0
    Endif
    pshifr := PadR( gr->sh_b, 5 )
    If AScan( arr_d4, pshifr ) == 0
      AAdd( arr_d4, pshifr )
      tmp->kol++
    Endif
    AAdd( ar, tmp->( RecNo() ) )
    //
    s := SubStr( human->diag_plus, i, 1 )
    If fl_plus .and. !Empty( s ) .and. ( j := AScan( md_plus, s ) ) > 0
      sd_plus[ j ] ++
      If fl_i
        id_plus[ j ] ++
      Endif
      pole := "tmp->kol" + lstr( j )
      For j := 1 To Len( ar )
        tmp->( dbGoto( ar[ j ] ) )
        &pole := &pole + 1
      Next
    Endif
    If !eq_any( s, "+", "-" )
      s := adiag_talon[ i * 2 -1 ]
      If eq_any( s, 1, 2 )
        s := iif( s == 1, "+", "-" )
        If ( j := AScan( md_plus, s ) ) > 0
          sd_plus[ j ] ++
          If fl_i
            id_plus[ j ] ++
          Endif
          pole := "tmp->kol" + lstr( j )
          For j := 1 To Len( ar )
            tmp->( dbGoto( ar[ j ] ) )
            &pole := &pole + 1
          Next
        Endif
      Endif
    Endif
    If eq_any( adiag_talon[ i * 2 ], 1, 2 ) .and. ( j := AScan( md_plus, s_dispan ) ) > 0
      sd_plus[ j ] ++
      If fl_i
        id_plus[ j ] ++
      Endif
      pole := "tmp->kol" + lstr( j )
      For j := 1 To Len( ar )
        tmp->( dbGoto( ar[ j ] ) )
        &pole := &pole + 1
      Next
    Endif
  Next
  If Len( arr_d1 ) > 0 .or. Len( arr_d2 ) > 0
    ++s_lu
    Select TMP_K
    find ( Str( human->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmp_k->kod := human->kod_k
    Endif
    tmp_k->kol++
    If all_i
      ++i_lu
      Select TMP_I
      find ( Str( human->kod_k, 7 ) )
      If !Found()
        Append Blank
        tmp_i->kod := human->kod_k
      Endif
      tmp_i->kol++
    Endif
  Endif
  For j := 1 To Len( arr_d1 )
    Select TMP_B
    find ( arr_d1[ j ] + "3" + Str( human->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmp_b->shifr := arr_d1[ j ]
      tmp_b->tip := 3
      tmp_b->kod := human->kod_k
      If tmp_b->( LastRec() ) % 5000 == 0
        Commit
      Endif
    Endif
    tmp_b->kol++
  Next
  For j := 1 To Len( arr_d2 )
    Select TMP_B
    find ( arr_d2[ j ] + "2" + Str( human->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmp_b->shifr := arr_d2[ j ]
      tmp_b->tip := 2
      tmp_b->kod := human->kod_k
      If tmp_b->( LastRec() ) % 5000 == 0
        Commit
      Endif
    Endif
    tmp_b->kol++
  Next
  For j := 1 To Len( arr_d3 )
    Select TMP_B
    find ( arr_d3[ j ] + "1" + Str( human->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmp_b->shifr := arr_d3[ j ]
      tmp_b->tip := 1
      tmp_b->kod := human->kod_k
      If tmp_b->( LastRec() ) % 5000 == 0
        Commit
      Endif
    Endif
    tmp_b->kol++
  Next
  For j := 1 To Len( arr_d4 )
    Select TMP_B
    find ( arr_d4[ j ] + "0" + Str( human->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmp_b->shifr := arr_d4[ j ]
      tmp_b->tip := 0
      tmp_b->kod := human->kod_k
      If tmp_b->( LastRec() ) % 5000 == 0
        Commit
      Endif
    Endif
    tmp_b->kol++
  Next

  Return Nil

// 14.10.24
Function diag_statist( reg )

  Static sz := 1
  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., sh, HH := 77, reg_print, speriod, fl, ;
    arr_title, name_file := cur_dir() + 's_diagn.txt', fl_itogo := .f., ;
    jh := 0, arr_m, name_gr, j_1 := 0, j_2 := 0, a_otd := {}
  Local mas_pmt := { "по ~всем диагнозам (заболеваниям)", ;
    "по ~основному заболеванию" }
  Private is_talon := .t., adiag_talon[ 16 ], md_bukva := {}, ;
    i_lu := 0, i_human := 0, id_plus, fl_z := .f., ;
    s_lu := 0, s_human := 0, sd_plus, ;
    s_dispan := "Диспансер", fl_plus := .f., md_plus := {}, k_plus

  If ( j := popup_prompt( T_ROW, T_COL - 5, sz, mas_pmt ) ) == 0
    Return Nil
  Endif
  sz := j
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
    Return Nil
  Endif
  If Len( st_a_uch ) == 1
    glob_uch := st_a_uch[ 1 ]
    If ( st_a_otd := inputn_otd( T_ROW, T_COL - 5, .f., .f., glob_uch, @lcount_otd ) ) == NIL
      Return Nil
    Endif
    AEval( st_a_otd, {| x| AAdd( a_otd, x[ 1 ] ) } )
  Else
    r_use( dir_server() + "mo_otd",, "OTD" )
    Go Top
    Do While !Eof()
      If f_is_uch( st_a_uch, otd->kod_lpu )
        AAdd( a_otd, otd->( RecNo() ) )
      Endif
      Skip
    Enddo
    otd->( dbCloseArea() )
  Endif
  If is_talon
    AAdd( md_plus, "+" )
    AAdd( md_plus, "-" )
    AAdd( md_plus, s_dispan )
  Endif
  k_plus := Len( md_plus )
  If ( fl_plus := ( k_plus > 0 ) )
    sd_plus := Array( k_plus )
    AFill( sd_plus, 0 )
    id_plus := Array( k_plus )
    AFill( id_plus, 0 )
  Endif
  speriod := arr_m[ 4 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  arr := { ;
    { "SHIFR",      "C",      5,      0 }, ;  // диагноз
  { "SHIFR2",     "C",      5,      0 }, ;  // диагноз
  { "KOL",        "N",      6,      0 };   // кол-во диагнозов
  }
  For i := 1 To k_plus
    AAdd( arr, { "KOL" + lstr( i ), "N", 6, 0 } )
  Next
  dbCreate( cur_dir() + "tmp", arr )
  Use ( cur_dir() + "tmp" ) new
  Index On shifr to ( cur_dir() + "tmp" )
  dbCreate( cur_dir() + "tmp_k", { { "kod", "N", 7, 0 }, ;
    { "kol", "N", 6, 0 } } )
  Use ( cur_dir() + "tmp_k" ) new
  Index On Str( kod, 7 ) to ( cur_dir() + "tmp_k" )
  dbCreate( cur_dir() + "tmp_i", { { "kod", "N", 7, 0 }, ;
    { "kol", "N", 6, 0 } } )
  Use ( cur_dir() + "tmp_i" ) new
  Index On Str( kod, 7 ) to ( cur_dir() + "tmp_i" )
  dbCreate( cur_dir() + "tmp_b", { { "kod", "N", 7, 0 }, ;
    { "shifr", "C", 5, 0 }, ;
    { "kol", "N", 6, 0 } } )
  Use ( cur_dir() + "tmp_b" ) new
  Index On shifr + Str( kod, 7 ) to ( cur_dir() + "tmp_b" )
  f1_diag_statist_bukva()
  If reg > 2
    If reg == 3
      name_gr := dir_exe() + "_mo_mkbg"
    Else
      name_gr := dir_exe() + "_mo_mkbk"
    Endif
    r_use( name_gr,, "GR" )
    Index On sh_e to ( cur_dir() + "tmp_gr" )
  Endif
  If pi1 == 1  // по дате окончания лечения
    begin_date := arr_m[ 5 ]
    end_date := arr_m[ 6 ]
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( begin_date ), .t. )
    Do While human->k_data <= end_date .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If func_pi_schet() .and. AScan( a_otd, human->otd ) > 0
        @ 24, 1 Say lstr( ++jh ) Color cColorSt2Msg
        f1diag_statist( reg, sz )
      Endif
      Select HUMAN
      Skip
    Enddo
  Else
    begin_date := arr_m[ 7 ]
    end_date := arr_m[ 8 ]
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server() + "schet_",, "SCHET_" )
    r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( begin_date, .t. )
    Do While schet->pdate <= end_date .and. !Eof()
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If AScan( a_otd, human->otd ) > 0
          @ 24, 1 Say lstr( ++jh ) Color cColorSt2Msg
          f1diag_statist( reg, sz )
        Endif
        Select HUMAN
        Skip
      Enddo
      Select SCHET
      Skip
    Enddo
  Endif
  j := tmp->( LastRec() )
  i_human := tmp_i->( LastRec() )
  s_human := tmp_k->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit ; Return NIL ; Endif
  If j == 0
    func_error( 4, "Нет сведений!" )
  Else
    mywait()
    reg_print := 5 ; w1 := 47
    arr_title := { ;
      "─────────────────────────────────────────────────────┬──────┬──────", ;
      "                                                     │ Боль-│ Слу- ", ;
      "                    Д и а г н о з                    │ ных  │ чаев ", ;
      "─────────────────────────────────────────────────────┴──────┴──────" }
    If fl_plus
      For i := 1 To k_plus
        If md_plus[ i ] == s_dispan
          s1 := SubStr( s_dispan, 1, 5 )
          s2 := SubStr( s_dispan, 6 )
        Else
          s1 := ""
          s2 := '"' + md_plus[ i ] + '"'
        Endif
        arr_title[ 1 ] += '╥─────'
        arr_title[ 2 ] += '║' + PadC( s1, 5 )
        arr_title[ 3 ] += '║' + PadC( s2, 5 )
        arr_title[ 4 ] += '╨─────'
      Next
    Endif
    If ( sh := Len( arr_title[ 1 ] ) ) > 85
      reg_print := 6
    Endif
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "Статистика по диагнозам", sh ) )
    titlen_uch( st_a_uch, sh, lcount_uch )
    If Len( st_a_uch ) == 1
      titlen_otd( st_a_otd, sh, lcount_otd )
    Endif
    add_string( "" )
    add_string( Center( speriod, sh ) )
    add_string( "" )
    If pi1 == 1
      add_string( Center( str_pi_schet(), sh ) )
    Else
      add_string( Center( "[ по дате выписки счета ]", sh ) )
    Endif
    If sz == 2
      add_string( Center( "{ по основному заболеванияю }", sh ) )
    Endif
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    //
    If reg < 3
      r_use( dir_exe() + "_mo_mkb", cur_dir() + "_mo_mkb", "MKB10" )
      Use ( cur_dir() + "tmp_b" ) index ( cur_dir() + "tmp_b" ) new
      Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
      Go Top
      Do While !Eof()
        s := ""
        Select MKB10
        find ( tmp->shifr )
        s := AllTrim( mkb10->name ) + " "
        Skip
        Do While Left( mkb10->shifr, 5 ) == tmp->shifr .and. mkb10->ks > 0 ;
            .and. !Eof()
          s += AllTrim( mkb10->name ) + " "
          Skip
        Enddo
        k := perenos( arr, s, w1 )
        s := tmp->shifr + " " + PadR( arr[ 1 ], w1 )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        j := 0
        Select TMP_B
        find ( tmp->shifr )
        dbEval( {|| ++j },, {|| tmp_b->shifr == tmp->shifr } )
        s += Str( j, 7 )
        s += Str( tmp->kol, 7 )
        If fl_plus
          For i := 1 To k_plus
            pole := "tmp->kol" + lstr( i )
            s += put_val( &pole, 6 )
            sd_plus[ i ] += &pole
            If !( Left( LTrim( s ), 1 ) == "Z" )
              id_plus[ i ] += &pole
            Endif
          Next
        Endif
        If Left( LTrim( s ), 1 ) == "Z" .and. !fl_itogo
          add_string( Replicate( "─", sh ) )
          si := PadL( "Итого: ", w1 + 6 ) + Str( i_human, 7 ) + Str( i_lu, 7 )
          If fl_plus
            For i := 1 To k_plus
              si += Str( id_plus[ i ], 6 )
            Next
          Endif
          add_string( si )
          add_string( Replicate( "─", sh ) )
          fl_itogo := .t.
        Endif
        add_string( s )
        For i := 2 To k
          add_string( Space( 6 ) + arr[ i ] )
        Next
        Select TMP
        Skip
      Enddo
    Else
      r_use( name_gr,, "GR" )
      Index On sh_b to ( cur_dir() + "tmp_gr" )
      Use ( cur_dir() + "tmp_b" ) index ( cur_dir() + "tmp_b" ) new
      Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
      Go Top
      Do While !Eof()
        s := "" ; fl := .f.
        Select GR
        find ( Left( tmp->shifr, 3 ) )
        If ( fl := Found() )
          Do While gr->sh_b == Left( tmp->shifr, 3 ) .and. !Eof()
            s += AllTrim( gr->name ) + " "
            Skip
          Enddo
        Endif
        k := perenos( arr, s, w1 - 2 )
        s := Left( tmp->shifr, 3 ) + "-" + Left( tmp->shifr2, 3 ) + " " + PadR( arr[ 1 ], w1 - 2 )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        j := 0
        Select TMP_B
        find ( tmp->shifr )
        dbEval( {|| ++j },, {|| tmp_b->shifr == tmp->shifr } )
        s += Str( j, 7 )
        s += Str( tmp->kol, 7 )
        If fl_plus
          For i := 1 To k_plus
            pole := "tmp->kol" + lstr( i )
            s += put_val( &pole, 6 )
            sd_plus[ i ] += &pole
            If !( Left( LTrim( s ), 1 ) == "Z" )
              id_plus[ i ] += &pole
            Endif
          Next
        Endif
        If Left( LTrim( s ), 1 ) == "Z" .and. !fl_itogo
          add_string( Replicate( "─", sh ) )
          si := PadL( "Итого: ", w1 + 6 ) + Str( i_human, 7 ) + Str( i_lu, 7 )
          If fl_plus
            For i := 1 To k_plus
              si += Str( id_plus[ i ], 6 )
            Next
          Endif
          add_string( si )
          add_string( Replicate( "─", sh ) )
          fl_itogo := .t.
        Endif
        add_string( s )
        For i := 2 To k
          add_string( Space( 8 ) + arr[ i ] )
        Next
        Select TMP
        Skip
      Enddo
    Endif
    If fl_z
      add_string( Replicate( "─", sh ) )
      s := PadL( "Всего: ", w1 + 6 ) + Str( s_human, 7 ) + Str( s_lu, 7 )
      If fl_plus
        For i := 1 To k_plus
          s += Str( sd_plus[ i ], 6 )
        Next
      Endif
      add_string( s )
    Endif
    f3_diag_statist_bukva( HH, sh, arr_title )
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif

  Return Nil

//
Function f1diag_statist( reg, sz )

  Local arr_d := {}, arr, i, j, mshifr, s, pole, fl_i, all_i := .f.

  f2_diag_statist_bukva()
  AFill( adiag_talon, 0 )
  For i := 1 To 16
    adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
  Next
  arr := diag_to_array(,,, .f. )
  If sz == 2
    ASize( arr, 1 )
  Endif
  For i := 1 To Len( arr )
    If !Empty( arr[ i ] )
      If Left( arr[ i ], 1 ) == "Z"
        fl_z := .t.  // private - переменная
      Else
        all_i := .t.  // не только "Z" у данного больного
      Endif
    Endif
  Next
  For i := 1 To Len( arr )
    If reg == 1  // 4-х/значный шифр
      mshifr := PadR( arr[ i ], 5 )
    Else
      mshifr := Left( arr[ i ], 3 )
    Endif
    If Empty( mshifr )
      Loop
    Endif
    fl_i := !( Left( arr[ i ], 1 ) == "Z" )
    If reg < 3
      mshifr := PadR( mshifr, 5 )
      Select TMP
      find ( mshifr )
      If !Found()
        Append Blank
        tmp->shifr := mshifr
      Endif
    Else
      Select GR
      dbSeek( mshifr, .t. )
      Select TMP
      find ( gr->sh_b )
      If !Found()
        Append Blank
        tmp->shifr := gr->sh_b
        tmp->shifr2 := gr->sh_e
      Endif
      mshifr := PadR( gr->sh_b, 5 )
    Endif
    If AScan( arr_d, mshifr ) == 0
      AAdd( arr_d, mshifr )
      tmp->kol++
    Endif
    s := SubStr( human->diag_plus, i, 1 )
    If fl_plus .and. !Empty( s ) .and. ( j := AScan( md_plus, s ) ) > 0
      pole := "tmp->kol" + lstr( j )
      &pole := &pole + 1
    Endif
    If !eq_any( s, "+", "-" )
      s := adiag_talon[ i * 2 -1 ]
      If eq_any( s, 1, 2 )
        s := iif( s == 1, "+", "-" )
        If ( j := AScan( md_plus, s ) ) > 0
          pole := "tmp->kol" + lstr( j )
          &pole := &pole + 1
        Endif
      Endif
    Endif
    If eq_any( adiag_talon[ i * 2 ], 1, 2 ) .and. ( j := AScan( md_plus, s_dispan ) ) > 0
      pole := "tmp->kol" + lstr( j )
      &pole := &pole + 1
    Endif
  Next
  If Len( arr_d ) > 0
    ++s_lu
    Select TMP_K
    find ( Str( human->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmp_k->kod := human->kod_k
    Endif
    tmp_k->kol++
    If all_i
      ++i_lu
      Select TMP_I
      find ( Str( human->kod_k, 7 ) )
      If !Found()
        Append Blank
        tmp_i->kod := human->kod_k
      Endif
      tmp_i->kol++
    Endif
    For j := 1 To Len( arr_d )
      Select TMP_B
      find ( arr_d[ j ] + Str( human->kod_k, 7 ) )
      If !Found()
        Append Blank
        tmp_b->shifr := arr_d[ j ]
        tmp_b->kod := human->kod_k
        If tmp_b->( LastRec() ) % 5000 == 0
          Commit
        Endif
      Endif
      tmp_b->kol++
    Next
  Endif

  Return Nil

// 14.10.24
Function diaglvstatist()

  Static sz := 1
  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., sh, HH := 76, reg_print, speriod, fl, ;
    arr_title, name_file := cur_dir() + 's_diag_v.txt', ;
    jh := 0, arr_m, name_gr, j_1 := 0, j_2 := 0, a_otd := {}
  Local mas_pmt := { "С ~разбивкой по врачам", ;
    "~Объединенный документ" }
  Private is_talon := .t., adiag_talon[ 16 ], s_lu := 0, s_human := 0, ;
    s_dispan := "Диспансер", fl_plus := .f., md_plus := {}, ;
    sd_plus, k_plus, mperso, regim := 1, md_bukva := {}

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
    Return Nil
  Endif
  If Len( st_a_uch ) == 1
    glob_uch := st_a_uch[ 1 ]
    If ( st_a_otd := inputn_otd( T_ROW, T_COL - 5, .f., .f., glob_uch, @lcount_otd ) ) == NIL
      Return Nil
    Endif
    AEval( st_a_otd, {| x| AAdd( a_otd, x[ 1 ] ) } )
  Else
    r_use( dir_server() + "mo_otd",, "OTD" )
    Go Top
    Do While !Eof()
      If f_is_uch( st_a_uch, otd->kod_lpu )
        AAdd( a_otd, otd->( RecNo() ) )
      Endif
      Skip
    Enddo
    otd->( dbCloseArea() )
  Endif
  If ( mperso := input_kperso() ) != NIL
    If ( j := popup_prompt( T_ROW, T_COL - 5, sz, mas_pmt ) ) == 0
      Return Nil
    Endif
    regim := sz := j
  Endif
  If is_talon
    AAdd( md_plus, "+" )
    AAdd( md_plus, "-" )
    AAdd( md_plus, s_dispan )
  Endif
  k_plus := Len( md_plus )
  If ( fl_plus := ( k_plus > 0 ) )
    sd_plus := Array( k_plus )
    AFill( sd_plus, 0 )
  Endif
  speriod := arr_m[ 4 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  arr := { ;
    { "vrach",      "N",      4,      0 }, ;
    { "SHIFR",      "C",      5,      0 }, ;  // диагноз
  { "KOL",        "N",      6,      0 };   // кол-во диагнозов
  }
  For i := 1 To k_plus
    AAdd( arr, { "KOL" + lstr( i ), "N", 6, 0 } )
  Next
  dbCreate( cur_dir() + "tmp", arr )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( vrach, 4 ) + shifr to ( cur_dir() + "tmp" )
  dbCreate( cur_dir() + "tmp_k", { { "vrach", "N", 4, 0 }, ;
    { "kod", "N", 7, 0 }, ;
    { "kol", "N", 6, 0 } } )
  Use ( cur_dir() + "tmp_k" ) new
  Index On Str( vrach, 4 ) + Str( kod, 7 ) to ( cur_dir() + "tmp_k" )
  dbCreate( cur_dir() + "tmp_b", { { "vrach", "N", 4, 0 }, ;
    { "kod", "N", 7, 0 }, ;
    { "shifr", "C", 5, 0 }, ;
    { "kol", "N", 6, 0 } } )
  Use ( cur_dir() + "tmp_b" ) new
  Index On Str( vrach, 4 ) + shifr + Str( kod, 7 ) to ( cur_dir() + "tmp_b" )
  f1_diag_statist_bukva()
  If pi1 == 1  // по дате окончания лечения
    begin_date := arr_m[ 5 ]
    end_date := arr_m[ 6 ]
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( begin_date ), .t. )
    Do While human->k_data <= end_date .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If func_pi_schet() .and. AScan( a_otd, human->otd ) > 0
        @ 24, 1 Say lstr( ++jh ) Color cColorSt2Msg
        f1diaglvstatist()
      Endif
      Select HUMAN
      Skip
    Enddo
  Else
    begin_date := arr_m[ 7 ]
    end_date := arr_m[ 8 ]
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server() + "schet_",, "SCHET_" )
    r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( begin_date, .t. )
    Do While schet->pdate <= end_date .and. !Eof()
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If AScan( a_otd, human->otd ) > 0
          @ 24, 1 Say lstr( ++jh ) Color cColorSt2Msg
          f1diaglvstatist()
        Endif
        Select HUMAN
        Skip
      Enddo
      Select SCHET
      Skip
    Enddo
  Endif
  j := tmp->( LastRec() )
  s_human := tmp_k->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit ; Return NIL ; Endif
  If j == 0
    func_error( 4, "Нет сведений!" )
  Else
    mywait()
    reg_print := 5 ; w1 := 47
    arr_title := { ;
      "─────────────────────────────────────────────────────┬──────┬──────", ;
      "                                                     │ Боль-│ Слу- ", ;
      "                    Д и а г н о з                    │ ных  │ чаев ", ;
      "─────────────────────────────────────────────────────┴──────┴──────" }
    If fl_plus
      For i := 1 To k_plus
        If md_plus[ i ] == s_dispan
          s1 := SubStr( s_dispan, 1, 5 )
          s2 := SubStr( s_dispan, 6 )
        Else
          s1 := ""
          s2 := '"' + md_plus[ i ] + '"'
        Endif
        arr_title[ 1 ] += '╥─────'
        arr_title[ 2 ] += '║' + PadC( s1, 5 )
        arr_title[ 3 ] += '║' + PadC( s2, 5 )
        arr_title[ 4 ] += '╨─────'
      Next
    Endif
    If ( sh := Len( arr_title[ 1 ] ) ) > 85
      reg_print := 6
    Endif
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "Статистика по диагнозам", sh ) )
    titlen_uch( st_a_uch, sh, lcount_uch )
    If Len( st_a_uch ) == 1
      titlen_otd( st_a_otd, sh, lcount_otd )
    Endif
    add_string( "" )
    add_string( Center( speriod, sh ) )
    add_string( "" )
    If pi1 == 1
      add_string( Center( str_pi_schet(), sh ) )
    Else
      add_string( Center( "[ по дате выписки счета ]", sh ) )
    Endif
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    //
    r_use( dir_exe() + "_mo_mkb", cur_dir() + "_mo_mkb", "MKB10" )
    Use ( cur_dir() + "tmp_k" ) index ( cur_dir() + "tmp_k" ) new
    Use ( cur_dir() + "tmp_b" ) index ( cur_dir() + "tmp_b" ) new
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
    If regim == 1
      r_use( dir_server() + "mo_pers",, "PERSO" )
      Select TMP
      Set Relation To vrach into PERSO
      Index On Upper( perso->fio ) + Str( vrach, 4 ) + shifr to ( cur_dir() + "tmp1" )
      old_vrach := 0
      AFill( sd_plus, 0 )
    Endif
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If regim == 1 .and. old_vrach != tmp->vrach
        If old_vrach > 0
          f2diaglvstatist( old_vrach, sd_plus, sh )
          f3_diag_statist_bukva( HH, sh, arr_title, old_vrach )
        Endif
        add_string( "" )
        add_string( Space( 10 ) + lstr( perso->tab_nom ) + ". " + Upper( AllTrim( perso->fio ) ) )
        old_vrach := tmp->vrach
        AFill( sd_plus, 0 )
      Endif
      s := ""
      Select MKB10
      find ( tmp->shifr )
      s := AllTrim( mkb10->name ) + " "
      Skip
      Do While Left( mkb10->shifr, 5 ) == tmp->shifr .and. mkb10->ks > 0 ;
          .and. !Eof()
        s += AllTrim( mkb10->name ) + " "
        Skip
      Enddo
      k := perenos( arr, s, w1 )
      //
      s := tmp->shifr + " " + PadR( arr[ 1 ], w1 )
      j := 0
      Select TMP_B
      If regim == 1
        find ( Str( tmp->vrach, 4 ) + tmp->shifr )
        dbEval( {|| ++j },, ;
          {|| tmp_b->vrach == tmp->vrach .and. tmp_b->shifr == tmp->shifr } )
      Else
        find ( Str( 0, 4 ) + tmp->shifr )
        dbEval( {|| ++j },, {|| tmp_b->shifr == tmp->shifr } )
      Endif
      s += Str( j, 7 )
      s += Str( tmp->kol, 7 )
      If fl_plus
        For i := 1 To k_plus
          pole := "tmp->kol" + lstr( i )
          s += put_val( &pole, 6 )
          sd_plus[ i ] += &pole
        Next
      Endif
      add_string( s )
      For i := 2 To k
        add_string( Space( 6 ) + arr[ i ] )
      Next
      Select TMP
      Skip
    Enddo
    If regim == 1
      If old_vrach > 0
        f2diaglvstatist( old_vrach, sd_plus, sh )
        f3_diag_statist_bukva( HH, sh, arr_title, old_vrach )
      Endif
    Else
      add_string( Replicate( "─", sh ) )
      s := PadL( "Итого: ", w1 + 6 ) + Str( s_human, 7 ) + Str( s_lu, 7 )
      If fl_plus
        For i := 1 To k_plus
          s += Str( sd_plus[ i ], 6 )
        Next
      Endif
      add_string( s )
      f3_diag_statist_bukva( HH, sh, arr_title )
    Endif
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif

  Return Nil

//
Function f1diaglvstatist()

  Local arr_d := {}, arr, i, j, mvrach := 0, mshifr, s, pole, fl

  If ( fl := ( human_->vrach > 0 ) )
    If regim == 1    // с разбивкой по врачам
      mvrach := human_->vrach
    Endif
    If mperso != Nil  // не все врачи
      fl := ( AScan( mperso, {| x| x[ 1 ] == human_->vrach } ) > 0 )
    Endif
  Endif
  If !fl ; Return NIL ; Endif
  f2_diag_statist_bukva( mvrach )
  //
  AFill( adiag_talon, 0 )
  For i := 1 To 16
    adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
  Next
  arr := diag_to_array(,,, .f. )
  For i := 1 To Len( arr )
    mshifr := PadR( arr[ i ], 5 )
    If Empty( mshifr )
      Loop
    Endif
    Select TMP
    find ( Str( mvrach, 4 ) + mshifr )
    If !Found()
      Append Blank
      tmp->vrach := mvrach
      tmp->shifr := mshifr
    Endif
    If AScan( arr_d, mshifr ) == 0
      AAdd( arr_d, mshifr )
      tmp->kol++
    Endif
    s := SubStr( human->diag_plus, i, 1 )
    If fl_plus .and. !Empty( s ) .and. ( j := AScan( md_plus, s ) ) > 0
      pole := "tmp->kol" + lstr( j )
      &pole := &pole + 1
    Endif
    If !eq_any( s, "+", "-" )
      s := adiag_talon[ i * 2 -1 ]
      If eq_any( s, 1, 2 )
        s := iif( s == 1, "+", "-" )
        If ( j := AScan( md_plus, s ) ) > 0
          pole := "tmp->kol" + lstr( j )
          &pole := &pole + 1
        Endif
      Endif
    Endif
    If eq_any( adiag_talon[ i * 2 ], 1, 2 ) .and. ( j := AScan( md_plus, s_dispan ) ) > 0
      pole := "tmp->kol" + lstr( j )
      &pole := &pole + 1
    Endif
  Next
  If Len( arr_d ) > 0
    s_lu++
    Select TMP_K
    find ( Str( mvrach, 4 ) + Str( human->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmp_k->vrach := mvrach
      tmp_k->kod := human->kod_k
    Endif
    tmp_k->kol++
    For j := 1 To Len( arr_d )
      Select TMP_B
      find ( Str( mvrach, 4 ) + arr_d[ j ] + Str( human->kod_k, 7 ) )
      If !Found()
        Append Blank
        tmp_b->vrach := mvrach
        tmp_b->shifr := arr_d[ j ]
        tmp_b->kod := human->kod_k
        If tmp_b->( LastRec() ) % 5000 == 0
          Commit
        Endif
      Endif
      tmp_b->kol++
    Next
  Endif

  Return Nil

//
Function f2diaglvstatist( kod_vr, sd_plus, sh )

  Local ls_lu := 0, ls_human := 0, i, s

  Select TMP_K
  find ( Str( kod_vr, 4 ) )
  dbEval( {|| ++ls_human, ls_lu += tmp_k->kol },, {|| kod_vr == tmp_k->vrach } )
  add_string( Replicate( "─", sh ) )
  s := PadL( "Итого: ", w1 + 6 ) + Str( ls_human, 7 ) + Str( ls_lu, 7 )
  If fl_plus
    For i := 1 To k_plus
      s += Str( sd_plus[ i ], 6 )
    Next
  Endif
  add_string( s )

  Return Nil

// 14.10.24
Function diaglustatist()

  Static sz := 1
  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., sh, HH := 76, reg_print, speriod, fl, ;
    arr_title, name_file := cur_dir() + 's_diag_u.txt', ;
    jh := 0, arr_m, name_gr, j_1 := 0, j_2 := 0, a_otd := {}
  Private is_talon := .t., adiag_talon[ 16 ], s_lu := 0, s_human := 0, ;
    s_dispan := "Диспансер", fl_plus := .f., md_plus := {}, ;
    sd_plus, k_plus, mperso, regim := 1, md_bukva := {}

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
    Return Nil
  Endif
  If Len( st_a_uch ) == 1
    glob_uch := st_a_uch[ 1 ]
    If ( st_a_otd := inputn_otd( T_ROW, T_COL - 5, .f., .f., glob_uch, @lcount_otd ) ) == NIL
      Return Nil
    Endif
    AEval( st_a_otd, {| x| AAdd( a_otd, x[ 1 ] ) } )
  Else
    r_use( dir_server() + "mo_otd",, "OTD" )
    Go Top
    Do While !Eof()
      If f_is_uch( st_a_uch, otd->kod_lpu )
        AAdd( a_otd, otd->( RecNo() ) )
      Endif
      Skip
    Enddo
    otd->( dbCloseArea() )
  Endif
  Private arr_uchast
  If ( arr_uchast := ret_uchast( T_ROW, T_COL - 5 ) ) == NIL
    Return Nil
  Endif
  If is_talon
    AAdd( md_plus, "+" )
    AAdd( md_plus, "-" )
    AAdd( md_plus, s_dispan )
  Endif
  k_plus := Len( md_plus )
  If ( fl_plus := ( k_plus > 0 ) )
    sd_plus := Array( k_plus )
    AFill( sd_plus, 0 )
  Endif
  speriod := arr_m[ 4 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  arr := { ;
    { "uchast",     "N",      2,      0 }, ;
    { "SHIFR",      "C",      5,      0 }, ;  // диагноз
  { "KOL",        "N",      6,      0 };   // кол-во диагнозов
  }
  For i := 1 To k_plus
    AAdd( arr, { "KOL" + lstr( i ), "N", 6, 0 } )
  Next
  dbCreate( cur_dir() + "tmp", arr )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( uchast, 2 ) + shifr to ( cur_dir() + "tmp" )
  dbCreate( cur_dir() + "tmp_k", { { "uchast", "N", 2, 0 }, ;
    { "kod", "N", 7, 0 }, ;
    { "kol", "N", 6, 0 } } )
  Use ( cur_dir() + "tmp_k" ) new
  Index On Str( uchast, 2 ) + Str( kod, 7 ) to ( cur_dir() + "tmp_k" )
  dbCreate( cur_dir() + "tmp_b", { { "uchast", "N", 2, 0 }, ;
    { "kod", "N", 7, 0 }, ;
    { "shifr", "C", 5, 0 }, ;
    { "kol", "N", 6, 0 } } )
  Use ( cur_dir() + "tmp_b" ) new
  Index On Str( uchast, 2 ) + shifr + Str( kod, 7 ) to ( cur_dir() + "tmp_b" )
  f1_diag_statist_bukva()
  r_use( dir_server() + "kartotek",, "KART" )
  If pi1 == 1  // по дате окончания лечения
    begin_date := arr_m[ 5 ]
    end_date := arr_m[ 6 ]
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( begin_date ), .t. )
    Do While human->k_data <= end_date .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If func_pi_schet() .and. AScan( a_otd, human->otd ) > 0
        @ 24, 1 Say lstr( ++jh ) Color cColorSt2Msg
        f1diaglustatist()
      Endif
      Select HUMAN
      Skip
    Enddo
  Else
    begin_date := arr_m[ 7 ]
    end_date := arr_m[ 8 ]
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server() + "schet_",, "SCHET_" )
    r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( begin_date, .t. )
    Do While schet->pdate <= end_date .and. !Eof()
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If AScan( a_otd, human->otd ) > 0
          @ 24, 1 Say lstr( ++jh ) Color cColorSt2Msg
          f1diaglustatist()
        Endif
        Select HUMAN
        Skip
      Enddo
      Select SCHET
      Skip
    Enddo
  Endif
  j := tmp->( LastRec() )
  s_human := tmp_k->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit ; Return NIL ; Endif
  If j == 0
    func_error( 4, "Нет сведений!" )
  Else
    mywait()
    reg_print := 5 ; w1 := 47
    arr_title := { ;
      "─────────────────────────────────────────────────────┬──────┬──────", ;
      "                                                     │ Боль-│ Слу- ", ;
      "                    Д и а г н о з                    │ ных  │ чаев ", ;
      "─────────────────────────────────────────────────────┴──────┴──────" }
    If fl_plus
      For i := 1 To k_plus
        If md_plus[ i ] == s_dispan
          s1 := SubStr( s_dispan, 1, 5 )
          s2 := SubStr( s_dispan, 6 )
        Else
          s1 := ""
          s2 := '"' + md_plus[ i ] + '"'
        Endif
        arr_title[ 1 ] += '╥─────'
        arr_title[ 2 ] += '║' + PadC( s1, 5 )
        arr_title[ 3 ] += '║' + PadC( s2, 5 )
        arr_title[ 4 ] += '╨─────'
      Next
    Endif
    If ( sh := Len( arr_title[ 1 ] ) ) > 85
      reg_print := 6
    Endif
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "Статистика по диагнозам", sh ) )
    titlen_uch( st_a_uch, sh, lcount_uch )
    If Len( st_a_uch ) == 1
      titlen_otd( st_a_otd, sh, lcount_otd )
    Endif
    add_string( "" )
    add_string( Center( speriod, sh ) )
    add_string( "" )
    If pi1 == 1
      add_string( Center( str_pi_schet(), sh ) )
    Else
      add_string( Center( "[ по дате выписки счета ]", sh ) )
    Endif
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    //
    r_use( dir_exe() + "_mo_mkb", cur_dir() + "_mo_mkb", "MKB10" )
    old_uchast := -1
    Use ( cur_dir() + "tmp_k" ) index ( cur_dir() + "tmp_k" ) new
    Use ( cur_dir() + "tmp_b" ) index ( cur_dir() + "tmp_b" ) new
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If regim == 1 .and. old_uchast != tmp->uchast
        If old_uchast >= 0
          f2diaglustatist( old_uchast, sd_plus, sh )
          f3_diag_statist_bukva( HH, sh, arr_title, old_uchast )
        Endif
        add_string( "" )
        add_string( Space( 10 ) + "УЧАСТОК № " + lstr( tmp->uchast ) )
        old_uchast := tmp->uchast
        AFill( sd_plus, 0 )
      Endif
      s := ""
      Select MKB10
      find ( tmp->shifr )
      s := AllTrim( mkb10->name ) + " "
      Skip
      Do While Left( mkb10->shifr, 5 ) == tmp->shifr .and. mkb10->ks > 0 ;
          .and. !Eof()
        s += AllTrim( mkb10->name ) + " "
        Skip
      Enddo
      k := perenos( arr, s, w1 )
      //
      s := tmp->shifr + " " + PadR( arr[ 1 ], w1 )
      j := 0
      Select TMP_B
      find ( Str( tmp->uchast, 2 ) + tmp->shifr )
      dbEval( {|| ++j },, ;
        {|| tmp_b->uchast == tmp->uchast .and. tmp_b->shifr == tmp->shifr } )
      s += Str( j, 7 )
      s += Str( tmp->kol, 7 )
      If fl_plus
        For i := 1 To k_plus
          pole := "tmp->kol" + lstr( i )
          s += put_val( &pole, 6 )
          sd_plus[ i ] += &pole
        Next
      Endif
      add_string( s )
      For i := 2 To k
        add_string( Space( 6 ) + arr[ i ] )
      Next
      Select TMP
      Skip
    Enddo
    If old_uchast > 0
      f2diaglustatist( old_uchast, sd_plus, sh )
      f3_diag_statist_bukva( HH, sh, arr_title, old_uchast )
    Endif
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif

  Return Nil

//
Function f1diaglustatist()

  Local arr_d := {}, arr, i, j, muchast := 0, mshifr, s, pole, fl

  If human->kod_k > 0
    Select KART
    Goto ( human->kod_k )
    If kart->uchast > 0
      muchast := kart->uchast
    Endif
  Endif
  If !f_is_uchast( arr_uchast, muchast )
    Return Nil
  Endif
  f2_diag_statist_bukva( muchast )
  AFill( adiag_talon, 0 )
  For i := 1 To 16
    adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
  Next
  arr := diag_to_array(,,, .f. )
  For i := 1 To Len( arr )
    mshifr := PadR( arr[ i ], 5 )
    If Empty( mshifr )
      Loop
    Endif
    Select TMP
    find ( Str( muchast, 2 ) + mshifr )
    If !Found()
      Append Blank
      tmp->uchast := muchast
      tmp->shifr := mshifr
    Endif
    If AScan( arr_d, mshifr ) == 0
      AAdd( arr_d, mshifr )
      tmp->kol++
    Endif
    s := SubStr( human->diag_plus, i, 1 )
    If fl_plus .and. !Empty( s ) .and. ( j := AScan( md_plus, s ) ) > 0
      pole := "tmp->kol" + lstr( j )
      &pole := &pole + 1
    Endif
    If !eq_any( s, "+", "-" )
      s := adiag_talon[ i * 2 -1 ]
      If eq_any( s, 1, 2 )
        s := iif( s == 1, "+", "-" )
        If ( j := AScan( md_plus, s ) ) > 0
          pole := "tmp->kol" + lstr( j )
          &pole := &pole + 1
        Endif
      Endif
    Endif
    If eq_any( adiag_talon[ i * 2 ], 1, 2 ) .and. ( j := AScan( md_plus, s_dispan ) ) > 0
      pole := "tmp->kol" + lstr( j )
      &pole := &pole + 1
    Endif
  Next
  If Len( arr_d ) > 0
    s_lu++
    Select TMP_K
    find ( Str( muchast, 2 ) + Str( human->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmp_k->uchast := muchast
      tmp_k->kod := human->kod_k
    Endif
    tmp_k->kol++
    For j := 1 To Len( arr_d )
      Select TMP_B
      find ( Str( muchast, 2 ) + arr_d[ j ] + Str( human->kod_k, 7 ) )
      If !Found()
        Append Blank
        tmp_b->uchast := muchast
        tmp_b->shifr := arr_d[ j ]
        tmp_b->kod := human->kod_k
        If tmp_b->( LastRec() ) % 5000 == 0
          Commit
        Endif
      Endif
      tmp_b->kol++
    Next
  Endif

  Return Nil

//
Function f2diaglustatist( kod_uch, sd_plus, sh )

  Local ls_lu := 0, ls_human := 0, i, s

  Select TMP_K
  find ( Str( kod_uch, 2 ) )
  dbEval( {|| ++ls_human, ls_lu += tmp_k->kol },, {|| kod_uch == tmp_k->uchast } )
  add_string( Replicate( "─", sh ) )
  s := PadL( "Итого: ", w1 + 6 ) + Str( ls_human, 7 ) + Str( ls_lu, 7 )
  If fl_plus
    For i := 1 To k_plus
      s += Str( sd_plus[ i ], 6 )
    Next
  Endif
  add_string( s )

  Return Nil

//
Function f1_diag_statist_bukva()

  dbCreate( cur_dir() + "tmp_buk", { { "bukva", "C", 1, 0 }, ;
    { "vu", "N", 4, 0 }, ;
    { "KOL", "N", 6, 0 } } )
  Use ( cur_dir() + "tmp_buk" ) new
  Index On Str( vu, 4 ) + bukva to ( cur_dir() + "tmp_buk" )
  dbCreate( cur_dir() + "tmp_bbuk", { { "bukva", "C", 1, 0 }, ;
    { "vu", "N", 4, 0 }, ;
    { "kod", "N", 7, 0 }, ;
    { "KOL", "N", 6, 0 } } )
  Use ( cur_dir() + "tmp_bbuk" ) new
  Index On Str( vu, 4 ) + bukva + Str( kod, 7 ) to ( cur_dir() + "tmp_bbuk" )

  Return Nil

//
Function f2_diag_statist_bukva( lvu )

  Local i, c, s := Upper( CharRem( " ", AllTrim( human_->STATUS_ST ) ) )

  Default lvu To 0
  For i := 1 To Len( s )
    c := SubStr( s, i, 1 )
    Select TMP_BUK
    find ( Str( lvu, 4 ) + c )
    If !Found()
      Append Blank
      tmp_buk->vu := lvu
      tmp_buk->bukva := c
    Endif
    tmp_buk->kol++
    //
    Select TMP_BBUK
    find ( Str( lvu, 4 ) + c + Str( human->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmp_bbuk->vu := lvu
      tmp_bbuk->bukva := c
      tmp_bbuk->kod := human->kod_k
    Endif
    tmp_bbuk->kol++
  Next

  Return Nil

//
Function f3_diag_statist_bukva( HH, sh, arr_title, lvu )

  Local j

  Default lvu To 0
  If Select( "TMP_BUK" ) == 0
    Use ( cur_dir() + "tmp_bbuk" ) index ( cur_dir() + "tmp_bbuk" ) new
    Use ( cur_dir() + "tmp_buk" ) index ( cur_dir() + "tmp_buk" ) new
  Endif
  Select TMP_BUK
  find ( Str( lvu, 4 ) )
  Do While tmp_buk->vu == lvu .and. !Eof()
    j := 0
    Select TMP_BBUK
    find ( Str( lvu, 4 ) + tmp_buk->bukva )
    dbEval( {|| ++j },, {|| tmp_bbuk->vu == lvu .and. tmp_bbuk->bukva == tmp_buk->bukva } )
    If verify_ff( HH, .t., sh ) .and. ValType( arr_title ) == "A"
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( PadL( tmp_buk->bukva, w1 + 6 ) + Str( j, 7 ) + Str( tmp_buk->kol, 7 ) )
    Select TMP_BUK
    Skip
  Enddo

  Return Nil

//
Function f_stat_boln()

  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., jh := 0, is_talon := .t., t_arr[ BR_LEN ], a_otd := {}
  Private adiag_talon[ 16 ], speriod, arr_m

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  speriod := arr_m[ 4 ]
  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
    Return Nil
  Endif
  If Len( st_a_uch ) == 1
    glob_uch := st_a_uch[ 1 ]
    If ( st_a_otd := inputn_otd( T_ROW, T_COL - 5, .f., .f., glob_uch, @lcount_otd ) ) == NIL
      Return Nil
    Endif
    AEval( st_a_otd, {| x| AAdd( a_otd, x[ 1 ] ) } )
  Else
    r_use( dir_server() + "mo_otd",, "OTD" )
    Go Top
    Do While !Eof()
      If f_is_uch( st_a_uch, otd->kod_lpu )
        AAdd( a_otd, otd->( RecNo() ) )
      Endif
      Skip
    Enddo
    otd->( dbCloseArea() )
  Endif
  //
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  adbf := { { "kod_k", "N", 7, 0 }, ;
    { "STATUS_ST", "C", 20, 0 }, ;
    { "kol_1", "N", 3, 0 }, ;
    { "kol_2", "N", 3, 0 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp" )
  //
  adbf := { { "kod_k", "N", 7, 0 }, ;
    { "kod_h", "N", 7, 0 } }
  dbCreate( cur_dir() + "tmp_h", adbf )
  Use ( cur_dir() + "tmp_h" ) new
  //
  kh := 0
  If pi1 == 1 // по дате окончания лечения
    begin_date := arr_m[ 5 ]
    end_date := arr_m[ 6 ]
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( begin_date ), .t. )
    Do While human->k_data <= end_date .and. !Eof()
      @ 24, 1 Say lstr( ++kh ) Color cColorSt2Msg
      If jh > 0
        @ Row(), Col() Say "/" Color "W/R"
        @ Row(), Col() Say lstr( jh ) Color cColorStMsg
      Endif
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If func_pi_schet() .and. AScan( a_otd, human->otd ) > 0
        jh := f1_stat_boln( jh )
      Endif
      Select HUMAN
      Skip
    Enddo
  Else
    begin_date := arr_m[ 7 ]
    end_date := arr_m[ 8 ]
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server() + "schet_",, "SCHET_" )
    r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( begin_date, .t. )
    Do While schet->pdate <= end_date .and. !Eof()
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If AScan( a_otd, human->otd ) > 0
          @ 24, 1 Say lstr( ++kh ) Color cColorSt2Msg
          If jh > 0
            @ Row(), Col() Say "/" Color "W/R"
            @ Row(), Col() Say lstr( jh ) Color cColorStMsg
          Endif
          jh := f1_stat_boln( jh )
        Endif
        Select HUMAN
        Skip
      Enddo
      Select SCHET
      Skip
    Enddo
  Endif
  Close databases
  rest_box( buf )
  If fl_exit ; Return NIL ; Endif
  If jh == 0
    Return func_error( 4, "Не вводилась информация о характере заболевания за указанный период!" )
  Endif
  mywait()
  Use ( cur_dir() + "tmp_h" ) new
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_h" )
  Use
  //
  t_arr[ BR_TOP ] := 2
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 8
  t_arr[ BR_RIGHT ] := 72
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := "Список больных с заполненным характером заболевания"
  t_arr[ BR_TITUL_COLOR ] := "BG+/GR"
  t_arr[ BR_ARR_BROWSE ] := { "═", "░", "═", "N/BG,W+/N,B/BG,W+/B", .t., 0 }
  n := 50
  blk := {|| iif( kol_1 > 1 .or. kol_2 > 1, { 3, 4 }, { 1, 2 } ) }
  t_arr[ BR_COLUMN ] := { { Center( "Ф.И.О.", n + 1 ), {|| " " + PadR( kart->fio, n ) }, blk }, ;
    { "  +  ", {|| put_val( kol_1, 3 ) + "  " }, blk }, ;
    { "  -  ", {|| put_val( kol_2, 3 ) + "  " }, blk } }
  If yes_bukva // если в настройке - работа со статусом стом.больного
    ASize( t_arr[ BR_COLUMN ], 1 )
    AAdd( t_arr[ BR_COLUMN ], { "Стом.статус", {|| Left( status_st, 11 ) }, blk } )
    t_arr[ BR_TITUL ] := "Список больных с заполненным стоматологическим статусом"
  Endif
  t_arr[ BR_EDIT ] := {| nk, ob| f2_stat_boln( nk, ob, "edit" ) }
  t_arr[ BR_STAT_MSG ] := {|| ;
    status_key( "^<Esc>^ выход;  ^<Enter>^ листы учета по больному;  ^<F9>^ печать списка" ) }
  r_use( dir_server() + "kartotek",, "KART" )
  Use ( cur_dir() + "tmp" ) new
  Set Relation To kod_k into KART
  Index On Upper( kart->fio ) to ( cur_dir() + "tmp" )
  Go Top
  edit_browse( t_arr )
  Close databases
  rest_box( buf )

  Return Nil

//
Function f1_stat_boln( jh )

  Local is_talon := .t., arr, i, j, k, s, k1 := 0, k2 := 0

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
    If !Empty( arr[ i ] )
      s := SubStr( human->diag_plus, i, 1 )
      If eq_any( s, "+", "-" )  // старая форма
        If s == "+"
          ++k1
        Else
          ++k2
        Endif
      Elseif is_talon
        s := adiag_talon[ i * 2 -1 ]
        If s == 1
          ++k1
        Elseif s == 2
          ++k2
        Endif
      Endif
    Endif
  Next
  If k1 > 0 .or. k2 > 0 .or. !Empty( human_->STATUS_ST )
    ++jh
    Select TMP
    find ( Str( human->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmp->kod_k := human->kod_k
    Endif
    If !Empty( human_->STATUS_ST )
      tmp->STATUS_ST := CharRem( " ", CharList( CharMix( tmp->STATUS_ST, human_->STATUS_ST ) ) )
    Endif
    tmp->kol_1 += k1
    tmp->kol_2 += k2
    //
    Select TMP_H
    Append Blank
    tmp_h->kod_k := human->kod_k
    tmp_h->kod_h := human->kod
    If RecNo() % 5000 == 0
      tmp->( dbCommit() )
      tmp_h->( dbCommit() )
    Endif
  Endif

  Return jh

//
Function f2_stat_boln( nKey, oBrow, regim )

  Local ret := -1, fl := .f., rec, arr := {}

  Do Case
  Case regim == "edit"
    Do Case
    Case nKey == K_F9
      rec := tmp->( RecNo() )
      f3_stat_boln()
      Select TMP
      Goto ( rec )
    Case nKey == K_ENTER
      rec := tmp->( RecNo() )
      Use ( cur_dir() + "tmp_h" ) index ( cur_dir() + "tmp_h" ) new
      find ( Str( tmp->kod_k, 7 ) )
      Do While tmp->kod_k == tmp_h->kod_k .and. !Eof()
        AAdd( arr, { 0, tmp_h->kod_h } )
        Select TMP_H
        Skip
      Enddo
      Close databases
      print_al_uch( arr, arr_m )
      //
      r_use( dir_server() + "kartotek",, "KART" )
      Use ( cur_dir() + "tmp" ) new
      Set Relation To kod_k into KART
      Set Index to ( cur_dir() + "tmp" )
      Goto ( rec )
    Endcase
  Endcase

  Return ret

//
Function f3_stat_boln()

  Local i, s, sh, HH := 80, reg_print, arr_title, name_file := cur_dir() + "stat_b.txt", ;
    buf := save_maxrow()

  mywait()
  reg_print := 4
  arr_title := { ;
    "────┬─────────────────────────────────────────────┬─────┬─────", ;
    " NN │              Ф.И.О. больного                │  +  │  -  ", ;
    "────┴─────────────────────────────────────────────┴─────┴─────";
    }
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( Center( "Список больных, по которым", sh ) )
  add_string( Center( "был проставлен характер заболевания", sh ) )
  titlen_uch( st_a_uch, sh, lcount_uch )
  If Len( st_a_uch ) == 1
    titlen_otd( st_a_otd, sh, lcount_otd )
  Endif
  add_string( Center( speriod, sh ) )
  If pi1 == 1
    add_string( Center( str_pi_schet(), sh ) )
  Else
    add_string( Center( "[ по дате выписки счета ]", sh ) )
  Endif
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  i := 0
  Go Top
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    s := PadR( lstr( ++i ) + ". " + kart->fio, 50 ) + put_val( tmp->kol_1, 4 ) + "  " + ;
      put_val( tmp->kol_2, 4 )
    add_string( s )
    Select TMP
    Skip
  Enddo
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, .t.,,, reg_print )

  Return Nil


// 14.10.24 Подсчёт стационарных случаев по профилям (по диагнозам, КСГ и операциям)
Function i_stac_sl_profil()

  Local buf := SaveScreen(), sh := 80, HH := 80, n_file := cur_dir() + 'stac_pro.txt'

  Private arr_m := { 2024, 1, 6, 'за январь - июнь 2024 года', 0d20240101, 0d20240630 }, ;
    mm_uslov := { { 'по всем случаям                      ', 2 }, ;
    { 'по счетам отч.периода (без учёта РАК)', 0 }, ;
    { 'с учётом РАК (как в форме 14-МЕД/ОМС)', 1 } }
  Private mdate := arr_m[ 4 ], m1date := arr_m[ 1 ], muslov := mm_uslov[ 3, 1 ], m1uslov := mm_uslov[ 3, 2 ]

  r1 := 17
  box_shadow( r1, 2, 22, 77, color1, ' Отчёт по профилям в стационаре (дневном стационаре) ', color8 )
  tmp_solor := SetColor( cDataCGet )

  @ r1 + 2, 4 Say 'Период времени' Get mdate ;
    reader {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c, , { 3, 4 } ), ;
    iif( k == nil, nil, ( arr_m := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION, , , .f. ) }
  @ r1 + 3, 4 Say 'Условия отбора' Get muslov ;
    reader {| x| menu_reader( x, mm_uslov, A__MENUVERT, , , .f. ) }
  status_key( '^<Esc>^ - выход;  ^<PgDn>^ - создание отчёта' )
  myread()
  RestScreen( buf )
  If LastKey() == K_ESC
    Return Nil
  Elseif !Between( arr_m[ 1 ], 2018, 2024 )
    Return func_error( 4, 'Данный отчёт работает только с 2018-24 годами' )
  Else
    begin_date := dtoc4( arr_m[ 5 ] )
    end_date := dtoc4( arr_m[ 6 ] )
    waitstatus( '<Esc> - прервать поиск' )
    mark_keys( { '<Esc>' } )
    //
    kds := kdr := 10
    If arr_m[ 1 ] == 2019 .and. arr_m[ 3 ] == 12
      kds := 17 // дата регистрации по 17.01.20
      kdr := 21 // по какую дату РАК сумма к оплате 21.01.20
    Elseif arr_m[ 1 ] == 2018 .and. arr_m[ 3 ] == 12
      kds := 21
      kdr := 22
    Elseif arr_m[ 1 ] == 2020 .and. arr_m[ 3 ] == 12
      kds := 21
      kdr := 22
    Elseif arr_m[ 1 ] == 2022 .and. arr_m[ 3 ] == 12
      kds := 21    // !!! ВНИМАНИЕ -проверить
      kdr := 22
    Elseif arr_m[ 1 ] == 2023 .and. arr_m[ 3 ] == 12
      kds := 21    // !!! ВНИМАНИЕ -проверить
      kdr := 22
    Elseif arr_m[ 1 ] == 2024 .and. arr_m[ 3 ] == 12
      kds := 21    // !!! ВНИМАНИЕ -проверить
      kdr := 22
    Endif
    // ////////////////////////////
    mdate_rak := arr_m[ 6 ] + kdr
    // ////////////////////////////
    dbCreate( cur_dir() + 'tmp', { { 'shifr', 'C', 20, 0 }, ;
      { 'usl_ok', 'N', 1, 0 }, ;
      { 'tip', 'N', 1, 0 }, ;
      { 'profil', 'N', 3, 0 }, ;
      { 'kv', 'N', 6, 0 }, ;
      { 'kd', 'N', 6, 0 } } )
    Use ( cur_dir() + 'tmp' ) new
    Index On Str( usl_ok, 1 ) + Str( tip, 1 ) + shifr + Str( profil, 3 ) to ( cur_dir() + 'tmp' )
    If m1uslov == 1
      r_use( dir_server() + "mo_xml",, "MO_XML" )
      r_use( dir_server() + "mo_rak",, "RAK" )
      Set Relation To kod_xml into MO_XML
      r_use( dir_server() + "mo_raks",, "RAKS" )
      Set Relation To akt into RAK
      r_use( dir_server() + "mo_raksh",, "RAKSH" )
      Set Relation To kod_raks into RAKS
      Index On Str( kod_h, 7 ) to ( cur_dir() + "tmp_raksh" ) For mo_xml->DFILE <= mdate_rak
    Endif
    r_use( dir_server() + "str_komp",, "SK" )
    r_use( dir_server() + "komitet",, "KM" )
    r_use( dir_server() + "mo_su",, "MOSU" )
    r_use( dir_server() + "mo_hu", dir_server() + "mo_hu", "MOHU" )
    Set Relation To u_kod into MOSU
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
    Set Relation To u_kod into USL
    r_use( dir_server() + "schet_",, "SCHET_" )
    r_use( dir_server() + "schet",, "SCHET" )
    Set Relation To RecNo() into SCHET_
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      fl := ( human_->USL_OK < 3 .and. ; // стационар
      human_->oplata != 9 .and. ; // не перевыставлен
      human->komu < 5 )            // не личный счёт
      If fl .and. human->komu == 1 .and. human->str_crb > 0
        sk->( dbGoto( human->str_crb ) )
        fl := !eq_any( sk->ist_fin, I_FIN_PLAT, I_FIN_DMS )
      Elseif fl .and. human->komu == 3 .and. human->str_crb > 0
        km->( dbGoto( human->str_crb ) )
        fl := !eq_any( km->ist_fin, I_FIN_PLAT, I_FIN_DMS )
      Endif
      If fl .and. m1uslov < 2 .and. ( fl := human->schet > 0 )
        Select SCHET
        Goto ( human->schet )
        If ( fl := schet_->IS_DOPLATA == 0 .and. !Empty( Val( schet_->smo ) ) .and. schet_->NREGISTR == 0 ) // только зарегистрированные
          // дата регистрации
          mdate := date_reg_schet()
          // дата отчетного периода
          mdate1 := SToD( StrZero( schet_->nyear, 4 ) + StrZero( schet_->nmonth, 2 ) + "15" )
          //
          fl := Between( mdate, arr_m[ 5 ], arr_m[ 6 ] + kds ) .and. Between( mdate1, arr_m[ 5 ], arr_m[ 6 ] ) // !!отч.период
          If fl .and. m1uslov == 1 // как в 14-МЕД
            koef := 1 ; k := j := 0
            Select RAKSH
            find ( Str( human->kod, 7 ) )
            Do While human->kod == raksh->kod_h .and. !Eof()
              If !Empty( raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP )
                ++j
              Endif
              k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
              Skip
            Enddo
            If !Empty( Round( k, 2 ) )
              If Empty( human->cena_1 ) // скорая помощь
                koef := 0
              Elseif round_5( human->cena_1, 2 ) <= round_5( k, 2 ) // полное снятие
                koef := 0
              Else // частичное снятие
                koef := ( human->cena_1 - k ) / human->cena_1
              Endif
            Endif
            fl := ( koef > 0 )
          Endif
        Endif
      Endif
      If fl // не платный больной
        kodKSG := ""
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If is_ksg( lshifr )
              kodKSG := lshifr ; Exit
            Endif
          Endif
          Select HU
          Skip
        Enddo
        au := {}
        Select MOHU
        find ( Str( human->kod, 7 ) )
        Do While mohu->kod == human->kod .and. !Eof()
          AAdd( au, { mosu->shifr1, mohu->kod_diag, mohu->profil } )
          Skip
        Enddo
        mprofil := human_->profil
        If Empty( au )
          s := human->kod_diag
          mtip := 1
        Else
          s := au[ 1, 1 ] // взять шифр первой операции
          mtip := 2
          If Len( au ) > 1 // если более одной операции
            ASort( au,,, {| x, y| x[ 1 ] < y[ 1 ] } )
            For i := Len( au ) To 1 Step -1
              If mprofil != au[ i, 3 ] .or. !( PadR( human->kod_diag, 5 ) == PadR( au[ i, 2 ], 5 ) )
                del_array( au, i ) // удалить не тот профиль и не тот диагноз
              Endif
            Next
            If Len( au ) > 0
              s := au[ 1, 1 ] // взять шифр первой операции из оставшихся
            Endif
          Endif
        Endif
        Select TMP
        find ( Str( human_->USL_OK, 1 ) + Str( mtip, 1 ) + PadR( s, 20 ) + Str( mprofil, 3 ) )
        If !Found()
          Append Blank
          tmp->USL_OK := human_->USL_OK
          tmp->shifr := s
          tmp->tip := mtip
          tmp->profil := mprofil
        Endif
        If human->VZROS_REB == 0
          tmp->kv++
        Else
          tmp->kd++
        Endif
        If !Empty( kodKSG )
          Select TMP
          find ( Str( human_->USL_OK, 1 ) + Str( 3, 1 ) + PadR( kodKSG, 20 ) + Str( mprofil, 3 ) )
          If !Found()
            Append Blank
            tmp->USL_OK := human_->USL_OK
            tmp->shifr := kodKSG
            tmp->tip := 3
            tmp->profil := mprofil
          Endif
          If human->VZROS_REB == 0
            tmp->kv++
          Else
            tmp->kd++
          Endif
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    Close databases
    use_base( "lusl" )
    use_base( "luslf" )
    r_use( dir_exe() + "_mo_mkb", cur_dir() + "_mo_mkb", "DIAG" )
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
    arr_title := { ;
      "───────────────────────────────────────────────────────────╥──────╥──────┬──────", ;
      "                                                           ║Случаи║в т.ч.│в т.ч.", ;
      " Профиль койки                                             ║всего ║взросл│дети  ", ;
      "───────────────────────────────────────────────────────────╨──────╨──────┴──────" }
    fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( glob_mo[ _MO_SHORT_NAME ] )
    add_string( "" )
    add_string( Center( 'случаи ' + arr_m[ 4 ], sh ) )
    If m1uslov == 0
      add_string( Center( '(по зарегистрированным счетам)', sh ) )
    Elseif m1uslov == 1
      add_string( Center( '(по зарегистрированным счетам с учётом РАК)', sh ) )
    Else
      add_string( Center( '(без учёта платных услуг и ДМС)', sh ) )
    Endif
    For iusl_ok := 1 To 2
      add_string( "" )
      add_string( Center( 'Данные об объёмах при оказании медицинской помощи', sh ) )
      add_string( Center( 'в ' + { 'круглосуточном', 'дневном' }[ iusl_ok ] + ' стационаре в разрезе профилей', sh ) )
      AEval( arr_title, {| x| add_string( x ) } )
      au := {}
      Select TMP
      find ( Str( iusl_ok, 1 ) )
      Do While tmp->usl_ok == iusl_ok .and. !Eof()
        If tmp->profil > 0 .and. tmp->tip < 3
          If ( i := AScan( au, {| x| x[ 1 ] == tmp->profil } ) ) == 0
            AAdd( au, { tmp->profil, "", 0, 0 } ) ; i := Len( au )
            If ( j := AScan( getv002(), {| x| x[ 2 ] == tmp->profil } ) ) > 0
              au[ i, 2 ] := getv002()[ j, 1 ]
            Else
              au[ i, 2 ] := "профиль " + lstr( tmp->profil )
            Endif
          Endif
          au[ i, 3 ] += tmp->kv
          au[ i, 4 ] += tmp->kd
        Endif
        Skip
      Enddo
      ASort( au,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
      sv := sd := 0
      For i := 1 To Len( au )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( PadR( au[ i, 2 ], 59 ) + put_val( au[ i, 3 ] + au[ i, 4 ], 7 ) + put_val( au[ i, 3 ], 7 ) + put_val( au[ i, 4 ], 7 ) )
        sv += au[ i, 3 ]
        sd += au[ i, 4 ]
      Next
      add_string( Replicate( "─", sh ) )
      add_string( PadR( "Всего:", 59 ) + put_val( sv + sd, 7 ) + put_val( sv, 7 ) + put_val( sd, 7 ) )
      arr_title[ 2 ] := PadR( "Наименование КСГ", 59 ) + SubStr( arr_title[ 2 ], 60 )
      lal := "lusl"
      lal := create_name_alias( lal, arr_m[ 1 ] )

      verify_ff( HH - 6, .t., sh )
      add_string( "" )
      AEval( arr_title, {| x| add_string( x ) } )
      old := Space( 20 )
      Select TMP
      find ( Str( iusl_ok, 1 ) + "3" )
      Do While tmp->usl_ok == iusl_ok .and. tmp->tip == 3 .and. !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        If !( old == PadR( tmp->shifr, 20 ) )
          dbSelectArea( lal )
          find ( PadR( tmp->shifr, 10 ) )
          add_string( AllTrim( tmp->shifr ) + " " + AllTrim( &lal.->name ) )
        Endif
        old := PadR( tmp->shifr, 20 )
        If ( j := AScan( getv002(), {| x| x[ 2 ] == tmp->profil } ) ) > 0
          s := getv002()[ j, 1 ]
        Else
          s := "профиль " + lstr( tmp->profil )
        Endif
        add_string( PadR( "- " + s, 59 ) + put_val( tmp->kv + tmp->kd, 7 ) + put_val( tmp->kv, 7 ) + put_val( tmp->kd, 7 ) )
        Select TMP
        Skip
      Enddo
      arr_title[ 2 ] := PadR( " Основной диагноз (терапевтическая группа КСГ)", 59 ) + SubStr( arr_title[ 2 ], 60 )
      verify_ff( HH - 6, .t., sh )
      add_string( "" )
      AEval( arr_title, {| x| add_string( x ) } )
      old := Space( 5 )
      Select TMP
      find ( Str( iusl_ok, 1 ) + "1" )
      Do While tmp->usl_ok == iusl_ok .and. tmp->tip == 1 .and. !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        If !( old == PadR( tmp->shifr, 5 ) )
          Select DIAG
          find ( PadR( tmp->shifr, 5 ) )
          add_string( RTrim( Left( tmp->shifr, 5 ) ) + " " + AllTrim( diag->name ) )
        Endif
        old := PadR( tmp->shifr, 5 )
        If ( j := AScan( getv002(), {| x| x[ 2 ] == tmp->profil } ) ) > 0
          s := getv002()[ j, 1 ]
        Else
          s := "профиль " + lstr( tmp->profil )
        Endif
        add_string( PadR( "- " + s, 59 ) + put_val( tmp->kv + tmp->kd, 7 ) + put_val( tmp->kv, 7 ) + put_val( tmp->kd, 7 ) )
        Select TMP
        Skip
      Enddo
      arr_title[ 2 ] := PadR( " Операция (хирургическая группа КСГ)", 59 ) + SubStr( arr_title[ 2 ], 60 )

      lal := "luslf"
      lal := create_name_alias( lal, arr_m[ 1 ] )

      verify_ff( HH - 6, .t., sh )
      add_string( "" )
      AEval( arr_title, {| x| add_string( x ) } )
      old := Space( 20 )
      Select TMP
      find ( Str( iusl_ok, 1 ) + "2" )
      Do While tmp->usl_ok == iusl_ok .and. tmp->tip == 2 .and. !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        If !( old == PadR( tmp->shifr, 20 ) )
          dbSelectArea( lal )
          find ( PadR( tmp->shifr, 20 ) )
          add_string( AllTrim( tmp->shifr ) + " " + AllTrim( &lal.->name ) )
        Endif
        old := PadR( tmp->shifr, 20 )
        If ( j := AScan( getv002(), {| x| x[ 2 ] == tmp->profil } ) ) > 0
          s := getv002()[ j, 1 ]
        Else
          s := "профиль " + lstr( tmp->profil )
        Endif
        add_string( PadR( "- " + s, 59 ) + put_val( tmp->kv + tmp->kd, 7 ) + put_val( tmp->kv, 7 ) + put_val( tmp->kd, 7 ) )
        Select TMP
        Skip
      Enddo
    Next iusl_ok
    FClose( fp )
    Close databases
    viewtext( n_file,,,, ( sh > 80 ),,, 5 )
  Endif

  Return Nil
