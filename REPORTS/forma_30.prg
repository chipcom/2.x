#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 06.11.22
Function forma_30()

  Local buf := save_maxrow(), fl_exit := .f., ;
    reg_print, name_file := cur_dir() + "_form_30.txt", ;
    jh := 0, jh1 := 0, arr_m

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  Private sh, HH := 78, arr_title
  adbf := { { "tip",   "N", 1, 0 }, ;  // 1-4
  { "kod",   "N", 9, 0 }, ;  // врач,профиль,специальность,услуга
  { "p3",    "N", 7, 0 }, ;
    { "p4",    "N", 7, 0 }, ;
    { "p5",    "N", 7, 0 }, ;
    { "p6",    "N", 7, 0 }, ;
    { "p7",    "N", 7, 0 }, ;
    { "p8",    "N", 7, 0 }, ;
    { "p9",    "N", 7, 0 }, ;
    { "p10",   "N", 7, 0 }, ;
    { "p11",   "N", 7, 0 }, ;
    { "p12",   "N", 7, 0 }, ;
    { "p13",   "N", 7, 0 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( tip, 1 ) + Str( kod, 9 ) to ( cur_dir() + "tmp" )
  //
  adbf := { { "tip",   "N", 1, 0 }, ;  // 1-4
  { "kod",   "N", 9, 0 }, ;  // врач,профиль,специальность,услуга
  { "p5",    "N", 7, 0 }, ;
    { "p6",    "N", 7, 0 }, ;
    { "p7",    "N", 7, 0 }, ;
    { "p8",    "N", 7, 0 }, ;
    { "p9",    "N", 7, 0 }, ;
    { "p10",   "N", 7, 0 }, ;
    { "p11",   "N", 7, 0 }, ;
    { "p12",   "N", 7, 0 }, ;
    { "p13",   "N", 7, 0 }, ;
    { "p14",   "N", 7, 0 }, ;
    { "p15",   "N", 7, 0 } }
  dbCreate( cur_dir() + "tmp1", adbf )
  Use ( cur_dir() + "tmp1" ) new
  Index On Str( tip, 1 ) + Str( kod, 9 ) to ( cur_dir() + "tmp1" )
  //
  adbf := { { "tip",   "N", 1, 0 }, ;  // 1-4
  { "kod",   "N", 9, 0 }, ;  // врач,профиль,специальность,услуга
  { "p2",    "N", 7, 0 }, ;
    { "p3",    "N", 7, 0 }, ;
    { "p4",    "N", 7, 0 }, ;
    { "p5",    "N", 7, 0 }, ;
    { "p6",    "N", 7, 0 }, ;
    { "p7",    "N", 7, 0 }, ;
    { "p8",    "N", 7, 0 }, ;
    { "p9",    "N", 7, 0 }, ;
    { "p10",   "N", 7, 0 }, ;
    { "p11",   "N", 7, 0 }, ;
    { "p12",   "N", 7, 0 }, ;
    { "p13",   "N", 7, 0 }, ;
    { "p14",   "N", 7, 0 }, ;
    { "p15",   "N", 7, 0 } }
  dbCreate( cur_dir() + "tmp2", adbf )
  Use ( cur_dir() + "tmp2" ) new
  Index On Str( tip, 1 ) + Str( kod, 9 ) to ( cur_dir() + "tmp2" )
  //
  r_use( dir_server + "mo_su",, "MOSU" )
  r_use( dir_server + "mo_hu", dir_server + "mo_hu", "MOHU" )
  Set Relation To u_kod into MOSU
  r_use( dir_server + "uslugi",, "USL" )
  r_use( dir_server + "human_u_",, "HU_" )
  r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server + "kartote_",, "KART_" )
  r_use( dir_server + "kartotek",, "KART" )
  Set Relation To RecNo() into KART_
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  If pi1 == 1 // по дате окончания лечения
    begin_date := arr_m[ 5 ]
    end_date := arr_m[ 6 ]
    r_use( dir_server + "human_2",, "HUMAN_2" )
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humand", "HUMAN" )
    Set Relation To kod_k into KART, To RecNo() into HUMAN_, RecNo() into HUMAN_2
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If human_->oplata < 9 .and. func_pi_schet()
        jh := f1_f30_dop( jh, jh1 )
        jh := f1_f30( jh - 1, @jh1 )
        @ MaxRow(), 1 Say lstr( jh ) Color cColorSt2Msg
        @ Row(), Col() Say "/" Color "W/R"
        @ Row(), Col() Say lstr( jh1 ) Color cColorStMsg
      Endif
      date_24( human->k_data )
      Select HUMAN
      Skip
    Enddo
  Else
    r_use( dir_server + "human_2",, "HUMAN_2" )
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
    Set Relation To kod_k into KART, To RecNo() into HUMAN_, RecNo() into HUMAN_2
    r_use( dir_server + "schet_",, "SCHET_" )
    r_use( dir_server + "schet", dir_server + "schetd", "SCHET" )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( arr_m[ 7 ], .t. )
    Do While schet->pdate <= arr_m[ 8 ] .and. !Eof()
      date_24( c4tod( schet->pdate ) )
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human_->oplata < 9
          jh := f1_f30_dop( jh, jh1 )
          jh := f1_f30( jh - 1, @jh1 )
        Endif
        @ MaxRow(), 1 Say lstr( jh ) Color cColorSt2Msg
        @ Row(), Col() Say "/" Color "W/R"
        @ Row(), Col() Say lstr( jh1 ) Color cColorStMsg
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
  arr_title := { ;
    "───────────────────────┬──┬────────────────────┬────────────────────┬──────────────────────────────────", ;
    "                       │№ │   Число посещений  │из общего числа по  │ число посещений врачами на дому  ", ;
    "                       │ст├──────┬──────┬──────┤ поводу заболеваний ├──────┬──────┬──────┬──────┬──────", ;
    "Наименование должностей│ро│      │в т.ч.│детьми├──────┬──────┬──────┤всего │из них│из гр9│из гр9│из г12", ;
    "                       │ки│всего │сельск│ 0-17 │сельс.│18 лет│ дети │      │сельск│по пов│ дети │по пов", ;
    "                       │  │      │жителя│ лет  │жител.│и стар│0-17л.│      │жителе│заболе│0-17л.│заболе", ;
    "───────────────────────┼──┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────", ;
    "           1           │2 │  3   │  4   │  5   │  6   │  7   │  8   │  9   │  10  │  11  │  12  │  13  ", ;
    "───────────────────────┴──┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────";
    }
  sh := Len( arr_title[ 1 ] )
  reg_print := 6
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server + "organiz",, "ORG" )
  add_string( PadR( org->name, 108 ) )
  add_string( PadL( "Форма № 30", sh ) )
  add_string( PadL( "Утверждена Приказом", sh ) )
  add_string( PadL( "Росстата России", sh ) )
  add_string( PadL( "от 27.12.2016г. № 866", sh ) )
  add_string( Center( "СВЕДЕНИЯ ОБ УЧРЕЖДЕНИИ ЗДРАВООХРАНЕНИЯ", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  If pi1 == 1
    add_string( Center( str_pi_schet(), sh ) )
  Else
    add_string( Center( "[ по дате выписки счета ]", sh ) )
  Endif
  add_string( "" )
  add_string( Center( "Раздел III. ДЕЯТЕЛЬНОСТЬ МО ПО ОКАЗАНИЮ МЕД.ПОМОЩИ В АМБУЛАТОРНЫХ УСЛОВИЯХ", sh ) )
  add_string( "" )
  add_string( Center( "1. Работа врачей медицинской организации в амбулаторных условиях", sh ) )
  add_string( "(2100)" + PadL( "Код по ОКЕИ: посещение в смену - 545", sh - 6 ) )
  AEval( arr_title, {| x| add_string( x ) } )
  Use ( cur_dir() + "tmp" ) New index ( cur_dir() + "tmp" )
  find ( Str( 0, 1 ) )
  If Found()
    f2_f30( "Врачи всего", "01" )
    add_string( Replicate( "-", sh ) )
    add_string( "в т.ч. по врачам" )
    r_use( dir_server + "mo_pers",, "PERS" )
    Select TMP
    Set Relation To kod into PERS
    Index On Upper( pers->fio ) to ( cur_dir() + "tmp" ) For tip == 1
    Go Top
    Do While !Eof()
      f2_f30( lstr( pers->tab_nom ) + " " + fam_i_o( pers->fio ) )
      Skip
    Enddo
    add_string( Replicate( "-", sh ) )
    add_string( "в т.ч. по профилям" )
    Select TMP
    Set Relation To
    Index On Str( kod, 9 ) to ( cur_dir() + "tmp" ) For tip == 2
    Go Top
    Do While !Eof()
      f2_f30( inieditspr( A__MENUVERT, getv002(), tmp->kod ) )
      Skip
    Enddo
    add_string( Replicate( "-", sh ) )
    add_string( "в т.ч. по специальностям" )
    Select TMP
    Set Relation To
    Index On PadR( lstr( kod ), 9 ) to ( cur_dir() + "tmp" ) For tip == 3
    Go Top
    Do While !Eof()
      f2_f30( inieditspr( A__MENUVERT, getv015(), tmp->kod ) )
      Skip
    Enddo
    r_use( dir_server + "uslugi",, "USL" )
    add_string( Replicate( "-", sh ) )
    add_string( "в т.ч. по услугам" )
    Select TMP
    Set Relation To kod into USL
    Index On fsort_usl( usl->shifr ) to ( cur_dir() + "tmp" ) For tip == 4
    Go Top
    Do While !Eof()
      f2_f30( AllTrim( usl->shifr ) + " " + usl->name )
      Skip
    Enddo
    r_use( dir_server + "mo_su",, "MOSU" )
    Select TMP
    Set Relation To kod into MOSU
    Index On fsort_usl( mosu->shifr ) to ( cur_dir() + "tmp" ) For tip == 5
    Go Top
    Do While !Eof()
      lshifr := AllTrim( mosu->shifr1 )
      If !Empty( mosu->shifr )
        lshifr += "(" + AllTrim( mosu->shifr ) + ")"
      Endif
      f2_f30( lshifr + " " + mosu->name )
      Skip
    Enddo
  Endif
  arr_title := { ;
    "──────────────────────────┬───────────────────────────┬────────────────────┬─────────────┬─────────────", ;
    "                          │   Поступило больных       │  выписано больных  │   умерло    │ койко-дней  ", ;
    "                          ├──────┬──────┬──────┬──────┼──────┬──────┬──────┼──────┬──────┼──────┬──────", ;
    "      Профиль коек        │      │в т.ч.│детей │старше│      │старше│в     │всего │старше│всего │старше", ;
    "                          │всего │сельск│ 0-17 │трудос│ всего│трудос│дневны│      │трудос│      │трудос", ;
    "                          │      │жителе│ лет  │возвра│      │возвра│стацио│      │возвра│      │возвра", ;
    "──────────────────────────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────", ;
    "           2              │  6   │  7   │  8   │  9   │  10  │  11  │  12  │  13  │  14  │  15  │  16  ", ;
    "──────────────────────────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────";
    }
  sh := Len( arr_title[ 1 ] )
  tek_stroke := HH + 10
  verify_ff( HH, .t., sh )
  add_string( "" )
  add_string( Center( "Раздел IV. ДЕЯТЕЛЬНОСТЬ МО ПО ОКАЗАНИЮ МЕД.ПОМОЩИ В СТАЦИОНАРНЫХ УСЛОВИЯХ", sh ) )
  add_string( "" )
  add_string( Center( "1. Коечный фонд и его использование", sh ) )
  add_string( "(3100)" + PadL( "Коды по ОКЕИ: койка - 911, человек - 792", sh - 6 ) )
  AEval( arr_title, {| x| add_string( x ) } )
  Use ( cur_dir() + "tmp1" ) New index ( cur_dir() + "tmp1" )
  find ( Str( 0, 1 ) )
  If Found()
    f2_f30( "Коек всего",, 2 ) // !!!!!!!
    add_string( Replicate( "-", sh ) )
    add_string( "в т.ч. по профилям" )
    Index On Str( kod, 9 ) to ( cur_dir() + "tmp1" ) For tip == 1
    Go Top
    Do While !Eof()
      f2_f30( inieditspr( A__MENUVERT, getv002(), tmp1->kod ),, 2 )
      Skip
    Enddo
  Endif
  If fl_exit ; Return NIL ; Endif
  //
  mywait()
  arr_title := { ;
    "───────────────────────┬─────────────────────────────────────────┬─────────────────────────────────────────", ;
    "                       │                 Число посещений         │из общего числа посещений по поводу забол", ;
    "                       ├─────┬─────┬─────┬─────┬─────┬─────┬─────┼─────┬─────┬─────┬─────┬─────┬─────┬─────", ;
    "Наименование должностей│     │в т.ч│из 2 │из 4 │дети │из 6 │из 6 │     │в т.ч│18лет│старш│дети │из 13│из 13", ;
    "                       │всего│сельс│старш│сельс│ 0-17│в т.ч│сельс│всего│сельс│  и  │труд │0-17л│в т.ч│сельс", ;
    "                       │     │ ких │труд.│ ких │ лет │дети │ ких │     │ ких │стар │оспос│     │ 0-14│ ких ", ;
    "                       │     │жител│возр.│жител│     │0-14 │жител│     │жител│ ше  │возр │     │     │жител", ;
    "───────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────", ;
    "           1           │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 │  12 │  13 │  14 │  15 ", ;
    "───────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────";
    }
  sh := Len( arr_title[ 1 ] )
  tek_stroke := HH + 10
  verify_ff( HH, .t., sh )
  add_string( "" )
  add_string( Center( "Раздел III. ДЕЯТЕЛЬНОСТЬ МО ПО ОКАЗАНИЮ МЕД.ПОМОЩИ В АМБУЛАТОРНЫХ УСЛОВИЯХ", sh ) )
  add_string( Center( "дополнение", sh ) )
  add_string( Center( "1. Работа врачей медицинской организации в амбулаторных условиях", sh ) )
  add_string( "(2100)" + PadL( "Код по ОКЕИ: посещение в смену - 545", sh - 6 ) )
  AEval( arr_title, {| x| add_string( x ) } )
  Use ( cur_dir() + "tmp2" ) New index ( cur_dir() + "tmp2" )
  find ( Str( 0, 1 ) )
  If Found()  // в tmp уже должны входить
    f2_f30_dop( "Врачи всего", "01" )
    add_string( Replicate( "-", sh ) )
    add_string( "в т.ч. по врачам" )
    // R_Use(dir_server+"mo_pers",,"PERS")
    Select TMP2
    Set Relation To kod into PERS
    Index On Upper( pers->fio ) to ( cur_dir() + "tmp2" ) For tip == 1
    Go Top
    Do While !Eof()
      f2_f30_dop( lstr( pers->tab_nom ) + " " + fam_i_o( pers->fio ) )
      Skip
    Enddo
    add_string( Replicate( "-", sh ) )
    add_string( "в т.ч. по профилям" )
    Select TMP2
    Set Relation To
    Index On Str( kod, 9 ) to ( cur_dir() + "tmp2" ) For tip == 2
    Go Top
    Do While !Eof()
      f2_f30_dop( inieditspr( A__MENUVERT, getv002(), tmp2->kod ) )
      Skip
    Enddo
    add_string( Replicate( "-", sh ) )
    add_string( "в т.ч. по специальностям" )
    Select TMP2
    Set Relation To
    Index On PadR( lstr( kod ), 9 ) to ( cur_dir() + "tmp2" ) For tip == 3
    Go Top
    Do While !Eof()
      f2_f30_dop( inieditspr( A__MENUVERT, getv015(), tmp2->kod ) )
      Skip
    Enddo
    // R_Use(dir_server+"uslugi",,"USL")
    add_string( Replicate( "-", sh ) )
    add_string( "в т.ч. по услугам" )
    Select TMP2
    Set Relation To kod into USL
    Index On fsort_usl( usl->shifr ) to ( cur_dir() + "tmp2" ) For tip == 4
    Go Top
    Do While !Eof()
      f2_f30_dop( AllTrim( usl->shifr ) + " " + usl->name )
      Skip
    Enddo
    // R_Use(dir_server+"mo_su",,"MOSU")
    Select TMP2
    Set Relation To kod into MOSU
    Index On fsort_usl( mosu->shifr ) to ( cur_dir() + "tmp2" ) For tip == 5
    Go Top
    Do While !Eof()
      lshifr := AllTrim( mosu->shifr1 )
      If !Empty( mosu->shifr )
        lshifr += "(" + AllTrim( mosu->shifr ) + ")"
      Endif
      f2_f30_dop( lshifr + " " + mosu->name )
      Skip
    Enddo
  Endif
  //
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( name_file,,,, .t.,,, reg_print )

  Return Nil

// 19.10.16
Function f1_f30( jh, jh1 )

  Local i, j, k, n, mvozrast, is_selo, is_dom, is_zabol, fl_stom_new := .f., au_lu := {}, au_flu := {}, ;
    lshifr, lshifr1, yes_30 := .f., fl_pensioner := .f., fl_death := .f., ;
    d2_year := Year( human->k_data ), au_su1 := {}, vid_vp := 0 // по умолчанию профилактика

  If human_->NOVOR > 0
    mvozrast := count_years( human_->DATE_R2, human->n_data )
  Else
    mvozrast := count_years( human->date_r, human->n_data )
  Endif
  is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog )  // признак села
  If ( human->pol == "Ж" .and. mvozrast >= 55 ) .or. ;
      ( human->pol == "М" .and. mvozrast >= 60 )
    fl_pensioner := .t.
  Endif
  If is_death( human_->RSLT_NEW ) // смерть
    fl_death := .t.
  Endif
  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    If f_paraklinika( usl->shifr, lshifr1, human->k_data )
      lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
      If is_2_stomat( lshifr,, .t. ) > 0
        fl_stom_new := .t.
        AAdd( au_lu, { lshifr, ;              // 1
          c4tod( hu->date_u ), ;   // 2
        hu_->profil, ;         // 3
          hu_->PRVS, ;           // 4
          AllTrim( usl->shifr ), ; // 5
        hu->kol_1, ;           // 6
          c4tod( hu->date_u ), ;   // 7
        hu_->kod_diag, ;       // 8
        hu->( RecNo() ), ;       // 9 - номер записи
        0 } )                   // 10 - для возврата
      Endif
      If eq_any( Left( lshifr, 5 ), "2.80.", "2.82." )
        vid_vp := 1 // в неотложной форме или Посещение в приёмном покое
        Exit
      Elseif eq_any( Left( lshifr, 5 ), "2.78.", "2.89." )
        vid_vp := 2 // по поводу заболевания
        Exit
      Elseif Left( lshifr, 5 ) == "2.88."
        vid_vp := 2 // разовое по поводу заболевания
        Exit
      Elseif d2_year < 2016 .and. Left( lshifr, 3 ) == "57." // стоматология
        For i := 1 To 3
          ar := {}
          f_vid_p_stom( {}, {}, ar, { i } )
          If AScan( ar, lshifr ) > 0
            If i == 1 // с лечебной целью
              vid_vp := 3 // по поводу заболевания
            Elseif i == 2 // // с профилактической целью
              vid_vp := 1 // профилактика
            Else // // при оказании неотложной помощи
              vid_vp := 2 // в неотложной форме
            Endif
            Exit
          Endif
        Next
        If vid_vp > 0
          --vid_vp
          Exit
        Endif
      Endif
    Endif
    Select HU
    Skip
  Enddo
  is_zabol := ( vid_vp > 0 )
  If fl_stom_new
    Select MOHU
    find ( Str( human->kod, 7 ) )
    Do While mohu->kod == human->kod .and. !Eof()
      AAdd( au_flu, { mosu->shifr1, ;         // 1
        c4tod( mohu->date_u ), ;  // 2
      mohu->profil, ;         // 3
        mohu->PRVS, ;           // 4
        mosu->shifr, ;          // 5
        mohu->kol_1, ;          // 6
        c4tod( mohu->date_u2 ), ; // 7
      mohu->kod_diag, ;       // 8
        mohu->( RecNo() ), ;      // 9 - номер записи
      0 } )                    // 10 - для возврата
      Select MOHU
      Skip
    Enddo
    f_vid_p_stom( au_lu, {},,, human->k_data,,,, au_flu )
    For j := 1 To Len( au_flu )
      If au_flu[ j, 10 ] == 1 // является врачебным приёмом
        mohu->( dbGoto( au_flu[ j, 9 ] ) )
        is_dom := .f. // на дому
        yes_30 := .t.
        mkol := au_flu[ j, 6 ]
        Select TMP
        For i := 0 To 4
          lkod := { 0, mohu->kod_vr, mohu->PROFIL, ret_new_prvs( mohu->PRVS ), mohu->u_kod }[ i + 1 ]
          If i == 4 ; i := 5 ; Endif
          find ( Str( i, 1 ) + Str( lkod, 9 ) )
          If !Found()
            Append Blank
            tmp->tip := i
            tmp->kod := lkod
          Endif
          If is_dom
            tmp->p9 += mkol
            If is_selo
              tmp->p10 += mkol
            Endif
            If is_zabol
              tmp->p11 += mkol
            Endif
            If mvozrast < 18
              tmp->p12 += mkol
              If is_zabol
                tmp->p13 += mkol
              Endif
            Endif
          Else
            tmp->p3 += mkol
            If is_selo
              tmp->p4 += mkol
            Endif
            If mvozrast < 18
              tmp->p5 += mkol
            Endif
            If is_zabol
              If is_selo
                tmp->p6 += mkol
              Endif
              If mvozrast >= 18
                tmp->p7 += mkol
              Else
                tmp->p8 += mkol
              Endif
            Endif
          Endif
        Next
      Endif
    Next
  Else
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
      If f_paraklinika( usl->shifr, lshifr1, human->k_data )
        lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
        ta := f14tf_nastr( @lshifr,, d2_year )
        lshifr := AllTrim( lshifr )
        For j := 1 To Len( ta )
          k := ta[ j, 1 ]
          If Between( k, 1, 6 ) .and. ta[ j, 2 ] >= 0
            If ta[ j, 2 ] == 1 // законченный случай
              mkol := human->k_data - human->n_data  // койко-день
              If Between( ta[ j, 1 ], 3, 5 ) // дневной стационар до 1 апреля
                ++mkol
              Endif
            Elseif ta[ j, 2 ] == 0
              mkol := hu->kol_1
            Else
              mkol := 0
            Endif
            ii := 0 ; is_dom := .f.
            If k == 2 // стационар
              ii := 1
            Elseif eq_any( k, 1, 6 ) // поликлиника
              ii := 2
              If Year( human->k_data ) > 2012
                is_dom := ( hu->kol_rcp < 0 .and. domuslugatfoms( lshifr ) ) // на дому - по новому
              Else
                is_dom := priem_na_domu( lshifr ) // на дому - по старому
                is_zabol := !priem_profilak( lshifr ) // по поводу заболевания
                If is_zabol .and. Left( human->KOD_DIAG, 1 ) == "Z" // профилактический приём
                  is_zabol := .f.
                Endif
              Endif
            Elseif eq_any( k, 3, 4, 5 ) // дневной стационар
              ii := k
            Endif
            If ii == 1 // стационар
              yes_30 := .t.
              AAdd( au_su1, { hu_->PROFIL, mkol } )
              // aadd(au_su1,{human_2->PROFIL_K,mkol})
            Elseif ii == 2  // поликлиника
              yes_30 := .t.
              Select TMP
              For i := 0 To 4
                lkod := { 0, hu->kod_vr, hu_->PROFIL, ret_new_prvs( hu_->PRVS ), hu->u_kod }[ i + 1 ]
                find ( Str( i, 1 ) + Str( lkod, 9 ) )
                If !Found()
                  Append Blank
                  tmp->tip := i
                  tmp->kod := lkod
                Endif
                If is_dom
                  tmp->p9 += mkol
                  If is_selo
                    tmp->p10 += mkol
                  Endif
                  If is_zabol
                    tmp->p11 += mkol
                  Endif
                  If mvozrast < 18
                    tmp->p12 += mkol
                    If is_zabol
                      tmp->p13 += mkol
                    Endif
                  Endif
                Else
                  tmp->p3 += mkol
                  If is_selo
                    tmp->p4 += mkol
                  Endif
                  If mvozrast < 18
                    tmp->p5 += mkol
                  Endif
                  If is_zabol
                    If is_selo
                      tmp->p6 += mkol
                    Endif
                    If mvozrast >= 18
                      tmp->p7 += mkol
                    Else
                      tmp->p8 += mkol
                    Endif
                  Endif
                Endif
              Next
            Endif
          Endif
        Next
      Endif
      Select HU
      Skip
    Enddo
  Endif
  If yes_30
    ++jh1
    For j := 1 To Len( au_su1 ) // стационар
      Select TMP1
      For i := 0 To 1
        lkod := iif( i == 0, 0, au_su1[ j, 1 ] )
        find ( Str( i, 1 ) + Str( lkod, 9 ) )
        If !Found()
          Append Blank
          tmp1->tip := i
          tmp1->kod := lkod
        Endif
        tmp1->p14 += au_su1[ j, 2 ]
        If fl_pensioner
          tmp1->p15 += au_su1[ j, 2 ]
        Endif
        If j == Len( au_su1 )
          tmp1->p5++
          If is_selo
            tmp1->p6++
          Endif
          If mvozrast < 18
            tmp1->p7++
          Endif
          If fl_pensioner
            tmp1->p8++
          Endif
          If fl_death
            tmp1->p12++
            If fl_pensioner
              tmp1->p13++
            Endif
          Else
            tmp1->p9++
            If fl_pensioner
              tmp1->p10++
            Endif
            If human_->RSLT_NEW == 103 // Переведён в дневной стационар
              tmp1->p11++
            Endif
          Endif
        Endif
      Next
    Next
  Endif

  Return jh + 1

// 03.12.15
Function f2_f30( s1, s2, par )

  Local i, s, lal := "tmp->p", n1 := 3, n2 := 13

  If s2 == NIL
    s := PadR( s1, 26 )
  Else
    s := PadR( s1, 23 ) + " " + s2
  Endif
  If par != Nil .and. par == 2
    n1 := 5 ; n2 := 15 ; lal := "tmp1->p"
  Endif
  For i := n1 To n2
    s += put_val( &( lal + lstr( i ) ), 7 )
  Next
  If verify_ff( HH, .t., sh )
    AEval( arr_title, {| x| add_string( x ) } )
  Endif
  add_string( s )

  Return Nil

// 08.01.19
Function f1_f30_dop( jh, jh1 )

  Local i, j, k, n, mvozrast, is_selo, is_dom, is_zabol, fl_stom_new := .f., au_lu := {}, au_flu := {}, ;
    lshifr, lshifr1, yes_30 := .f., fl_pensioner := .f., fl_death := .f., ;
    d2_year := Year( human->k_data ), au_su1 := {}, vid_vp := 0 // по умолчанию профилактика

  If human_->NOVOR > 0
    mvozrast := count_years( human_->DATE_R2, human->n_data )
  Else
    mvozrast := count_years( human->date_r, human->n_data )
  Endif
  is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog )  // признак села
  If ( human->pol == "Ж" .and. mvozrast >= 55 ) .or. ;
      ( human->pol == "М" .and. mvozrast >= 60 )
    fl_pensioner := .t.
  Endif
  If is_death( human_->RSLT_NEW ) // смерть
    fl_death := .t.
  Endif
  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    If f_paraklinika( usl->shifr, lshifr1, human->k_data )
      lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
      If is_2_stomat( lshifr,, .t. ) > 0
        fl_stom_new := .t.
        AAdd( au_lu, { lshifr, ;              // 1
          c4tod( hu->date_u ), ;   // 2
        hu_->profil, ;         // 3
          hu_->PRVS, ;           // 4
          AllTrim( usl->shifr ), ; // 5
        hu->kol_1, ;           // 6
          c4tod( hu->date_u ), ;   // 7
        hu_->kod_diag, ;       // 8
        hu->( RecNo() ), ;       // 9 - номер записи
        0 } )                   // 10 - для возврата
      Endif
      If eq_any( Left( lshifr, 5 ), "2.80.", "2.82." )
        vid_vp := 1 // в неотложной форме или Посещение в приёмном покое
        Exit
      Elseif eq_any( Left( lshifr, 5 ), "2.78.", "2.89." )
        vid_vp := 2 // по поводу заболевания
        Exit
      Elseif Left( lshifr, 5 ) == "2.88."
        vid_vp := 2 // разовое по поводу заболевания
        Exit
      Elseif d2_year < 2016 .and. Left( lshifr, 3 ) == "57." // стоматология
        For i := 1 To 3
          ar := {}
          f_vid_p_stom( {}, {}, ar, { i } )
          If AScan( ar, lshifr ) > 0
            If i == 1 // с лечебной целью
              vid_vp := 3 // по поводу заболевания
            Elseif i == 2 // // с профилактической целью
              vid_vp := 1 // профилактика
            Else // // при оказании неотложной помощи
              vid_vp := 2 // в неотложной форме
            Endif
            Exit
          Endif
        Next
        If vid_vp > 0
          --vid_vp
          Exit
        Endif
      Endif
    Endif
    Select HU
    Skip
  Enddo
  is_zabol := ( vid_vp > 0 )
  If fl_stom_new
    Select MOHU
    find ( Str( human->kod, 7 ) )
    Do While mohu->kod == human->kod .and. !Eof()
      AAdd( au_flu, { mosu->shifr1, ;         // 1
        c4tod( mohu->date_u ), ;  // 2
      mohu->profil, ;         // 3
        mohu->PRVS, ;           // 4
        mosu->shifr, ;          // 5
        mohu->kol_1, ;          // 6
        c4tod( mohu->date_u2 ), ; // 7
      mohu->kod_diag, ;       // 8
        mohu->( RecNo() ), ;      // 9 - номер записи
      0 } )                    // 10 - для возврата
      Select MOHU
      Skip
    Enddo
    f_vid_p_stom( au_lu, {},,, human->k_data,,,, au_flu )
    For j := 1 To Len( au_flu )
      If au_flu[ j, 10 ] == 1 // является врачебным приёмом
        mohu->( dbGoto( au_flu[ j, 9 ] ) )
        is_dom := .f. // на дому
        yes_30 := .t.
        mkol := au_flu[ j, 6 ]
        Select TMP2
        For i := 0 To 4
          lkod := { 0, mohu->kod_vr, mohu->PROFIL, ret_new_prvs( mohu->PRVS ), mohu->u_kod }[ i + 1 ]
          If i == 4 ; i := 5 ; Endif
          find ( Str( i, 1 ) + Str( lkod, 9 ) )
          If !Found()
            Append Blank
            tmp2->tip := i
            tmp2->kod := lkod
          Endif
          tmp2->p2 += mkol
          If is_selo             // село
            tmp2->p3 += mkol
          Endif
          If fl_pensioner        // старше трудоспособного
            tmp2->p4 += mkol
            If is_selo
              tmp2->p5 += mkol    // страше трудосп+село
            Endif
          Endif
          If mvozrast < 18       // дети до 18 лет
            tmp2->p6 += mkol
            If mvozrast < 15
              tmp2->p7 += mkol    // дети до 15 лет
            Endif
            If is_selo
              tmp2->p8 += mkol    // дети до 18 лет +село
            Endif
          Endif
          If is_zabol
            tmp2->p9 += mkol      // всего по заболеванию
            If is_selo
              tmp2->p10 += mkol   // село
            Endif
            If mvozrast >= 18
              tmp2->p11 += mkol   // старше 18 лет
              If fl_pensioner
                tmp2->p12 += mkol // старше трудоспособного
              Endif
            Else
              tmp2->p13 += mkol   // дети до 18 лет
              If mvozrast < 15
                tmp2->p14 += mkol // дети до 15 лет
              Endif
              If is_selo
                tmp2->p15 += mkol // дети до 18 лет + село
              Endif
            Endif
          Endif
        Next
      Endif
    Next
  Else
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
      If f_paraklinika( usl->shifr, lshifr1, human->k_data )
        lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
        ta := f14tf_nastr( @lshifr,, d2_year )
        lshifr := AllTrim( lshifr )
        For j := 1 To Len( ta )
          k := ta[ j, 1 ]
          If Between( k, 1, 6 ) .and. ta[ j, 2 ] >= 0
            If ta[ j, 2 ] == 1 // законченный случай
              mkol := human->k_data - human->n_data  // койко-день
              If Between( ta[ j, 1 ], 3, 5 ) // дневной стационар до 1 апреля
                ++mkol
              Endif
            Elseif ta[ j, 2 ] == 0
              mkol := hu->kol_1
            Else
              mkol := 0
            Endif
            ii := 0 ; is_dom := .f.
            If k == 2 // стационар
              ii := 1
            Elseif eq_any( k, 1, 6 ) // поликлиника
              ii := 2
              If Year( human->k_data ) > 2012
                is_dom := ( hu->kol_rcp < 0 .and. domuslugatfoms( lshifr ) ) // на дому - по новому
              Else
                is_dom := priem_na_domu( lshifr ) // на дому - по старому
                is_zabol := !priem_profilak( lshifr ) // по поводу заболевания
                If is_zabol .and. Left( human->KOD_DIAG, 1 ) == "Z" // профилактический приём
                  is_zabol := .f.
                Endif
              Endif
            Elseif eq_any( k, 3, 4, 5 ) // дневной стационар
              ii := k
            Endif
            If ii == 1 // стационар
              // yes_30 := .t.
              // aadd(au_su1,{hu_->PROFIL,mkol})
            Elseif ii == 2  // поликлиника
              yes_30 := .t.
              Select TMP2
              For i := 0 To 4
                lkod := { 0, hu->kod_vr, hu_->PROFIL, ret_new_prvs( hu_->PRVS ), hu->u_kod }[ i + 1 ]
                find ( Str( i, 1 ) + Str( lkod, 9 ) )
                If !Found()
                  Append Blank
                  tmp2->tip := i
                  tmp2->kod := lkod
                Endif
                tmp2->p2 += mkol
                If is_selo             // село
                  tmp2->p3 += mkol
                Endif
                If fl_pensioner        // старше трудоспособного
                  tmp2->p4 += mkol
                  If is_selo
                    tmp2->p5 += mkol    // страше трудосп+село
                  Endif
                Endif
                If mvozrast < 18       // дети до 18 лет
                  tmp2->p6 += mkol
                  If mvozrast < 15
                    tmp2->p7 += mkol    // дети до 15 лет
                  Endif
                  If is_selo
                    tmp2->p8 += mkol    // дети до 18 лет +село
                  Endif
                Endif
                If is_zabol
                  tmp2->p9 += mkol      // всего по заболеванию
                  If is_selo
                    tmp2->p10 += mkol   // село
                  Endif
                  If mvozrast >= 18
                    tmp2->p11 += mkol   // старше 18 лет
                    If fl_pensioner
                      tmp2->p12 += mkol // старше трудоспособного
                    Endif
                  Else
                    tmp2->p13 += mkol   // дети до 18 лет
                    If mvozrast < 15
                      tmp2->p14 += mkol // дети до 15 лет
                    Endif
                    If is_selo
                      tmp2->p15 += mkol // дети до 18 лет + село
                    Endif
                  Endif
                Endif
              Next
            Endif
          Endif
        Next
      Endif
      Select HU
      Skip
    Enddo
  Endif

  Return jh + 1

// 08.01.19
Function f2_f30_dop( s1, s2, par )

  Local i, s, lal := "tmp2->p", n1 := 2, n2 := 15

  s := PadR( s1, 23 ) // +s2
  For i := n1 To n2
    s += put_val( &( lal + lstr( i ) ), 6 )
  Next
  If verify_ff( HH, .t., sh )
    AEval( arr_title, {| x| add_string( x ) } )
  Endif
  add_string( s )

  Return Nil
