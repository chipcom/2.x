// mo_omsis.prg - информация по ОМС (по счетам)
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 30.03.23
Function s3_statist( k3, k4 )

  // k3 = 1 - Список счетов
  // k3 = 2 - С объединением по принадлежности
  // k3 = 3 - С разбивкой по отделениям
  // k3 = 4 - С разбивкой по службам
  // k4 = 1 - С разбивкой по отделениям (где выписан счет)
  // k4 = 2 - С разбивкой по отделениям (где оказана услуга)
  Local arr_g, buf := save_maxrow(), ;
    i, j, s, fl, sh, HH := 57, arr_title, reg_print, ;
    name_file := cur_dir() + 'spisok_s.txt', pp[ 8 ], old_smo, old_komu, old_str_crb, ;
    arr_bukva := {}, cur_rec := 0, fl_exit := .f.

  pi4 := k3
  Default k4 To 2
  Private ccount := 0, fl_opl
  AFill( pp, 0 )
  Store 0 To p1sum, p1kol, p2sum, p2kol, pj, old_komu, old_str_crb
  If ( arr_g := year_month(,, .f. ) ) == NIL
    Return Nil
  Endif
  If pds == 2 .and. !( arr_g[ 5 ] == BoM( arr_g[ 5 ] ) .and. arr_g[ 6 ] == EoM( arr_g[ 6 ] ) )
    Return func_error( 4, "Запрашиваемый период должен быть кратен месяцу" )
  Endif
  mywait()
  If r_use( dir_server() + "human_",, "HUMAN_" ) .and. ;
      r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" ) .and. ;
      r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" ) .and. ;
      r_use( dir_server() + "mo_otd",, "OTD" ) .and. ;
      r_use( dir_server() + "slugba", dir_server() + "slugba", "SL" ) .and. ;
      r_use( dir_server() + "uslugi", dir_server() + "uslugi", "USL" ) .and. ;
      r_use( dir_server() + "schet_",, "SCHET_" ) .and. ;
      r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
    Private atmp_os[ 8 ], arr_uch[ 8 ]
    AFill( atmp_os, 0 ) ; AFill( arr_uch, 0 )
    If k3 > 2
      s33_statist( k3, k4 )
    Endif
    arr_title := s31_statist( k3, k4 )
    reg_print := f_reg_print( arr_title, @sh )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    If k3 > 2
      add_string( Center( "Разбивка по " + ;
        if( k3 == 3, "отделениям", "службам" ) + " счетов", sh ) )
    Else
      add_string( Center( Expand( "СПИСОК СЧЕТОВ" ), sh ) )
    Endif
    If pds == 1
      s := "дата выписки счетов"
    Elseif pds == 2
      s := "отчетный период"
    Else
      s := "дата регистрации счетов"
    Endif
    add_string( Center( "[ " + s + " " + arr_g[ 4 ] + " ]", sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    //
    Select HUMAN
    Set Relation To RecNo() into HUMAN_
    Select SCHET
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    If pds == 1
      dbSeek( arr_g[ 7 ], .t. )
      If k3 == 2  // с объединением по принадлежности
        Index On schet_->smo + iif( Empty( schet_->smo ), Str( komu, 1 ) + Str( str_crb, 2 ), ;
          Str( 0, 1 ) + Str( 0, 2 ) ) + ;
          pdate + fsort_schet( schet_->nschet, nomer_s ) to ( cur_dir() + "tmp" ) ;
          While pdate <= arr_g[ 8 ]
      Else
        Index On pdate + fsort_schet( schet_->nschet, nomer_s ) to ( cur_dir() + "tmp" ) ;
          While pdate <= arr_g[ 8 ]
      Endif
    Elseif pds == 2
      If k3 == 2  // с объединением по принадлежности
        Index On schet_->smo + iif( Empty( schet_->smo ), Str( komu, 1 ) + Str( str_crb, 2 ), ;
          Str( 0, 1 ) + Str( 0, 2 ) ) + ;
          pdate + fsort_schet( schet_->nschet, nomer_s ) to ( cur_dir() + "tmp" ) ;
          For between_otch_period( schet_->dschet, schet_->NYEAR, schet_->NMONTH, arr_g[ 5 ], arr_g[ 6 ] )
      Else
        Index On pdate + fsort_schet( schet_->nschet, nomer_s ) to ( cur_dir() + "tmp" ) ;
          For between_otch_period( schet_->dschet, schet_->NYEAR, schet_->NMONTH, arr_g[ 5 ], arr_g[ 6 ] )
      Endif
    Else
      If k3 == 2  // с объединением по принадлежности
        Index On schet_->smo + iif( Empty( schet_->smo ), Str( komu, 1 ) + Str( str_crb, 2 ), ;
          Str( 0, 1 ) + Str( 0, 2 ) ) + ;
          pdate + fsort_schet( schet_->nschet, nomer_s ) to ( cur_dir() + "tmp" ) ;
          For schet_->NREGISTR == 0 .and. Between( date_reg_schet(), arr_g[ 5 ], arr_g[ 6 ] )
      Else
        Index On pdate + fsort_schet( schet_->nschet, nomer_s ) to ( cur_dir() + "tmp" ) ;
          For schet_->NREGISTR == 0 .and. Between( date_reg_schet(), arr_g[ 5 ], arr_g[ 6 ] )
      Endif
    Endif
    Select SCHET
    Go Top
    Do While !Eof()
      If k3 > 2  // разноска по отделениям или службам
        s34_statist( k3, k4 )
      Endif
      If k3 < 3  // список счетов
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        jh := js := 0
        Select HUMAN
        find ( Str( schet->kod, 6 ) )
        Do While human->schet == schet->kod .and. !Eof()
          If human_->oplata == 3
            js += human->cena_1 - human_->sump ; jh++
          Elseif eq_any( human_->oplata, 2, 9 )
            js += human->cena_1 ; jh++
          Endif
          Skip
        Enddo
        arr_uch[ 3 ] += schet->summa
        arr_uch[ 4 ] += schet->kol
        arr_uch[ 5 ] += js
        arr_uch[ 6 ] += jh
        If !Empty( schet_->BUKVA )
          If ( j := AScan( arr_bukva, {| x| x[ 2 ] == schet_->BUKVA .and. Empty( x[ 7 ] ) } ) ) == 0
            AAdd( arr_bukva, { "", schet_->BUKVA, 0, 0, 0, 0, "" } ) ; j := Len( arr_bukva )
          Endif
          arr_bukva[ j, 3 ] += schet->summa
          arr_bukva[ j, 4 ] += schet->kol
          arr_bukva[ j, 5 ] += js
          arr_bukva[ j, 6 ] += jh
        Endif
        If k3 == 2
          fl := .f.
          If Empty( schet_->smo )
            fl := !( schet->komu == old_komu .and. schet->str_crb == old_str_crb )
          Else
            fl := !( schet_->smo == old_smo )
            If !Empty( schet_->BUKVA )
              If ( j := AScan( arr_bukva, {| x| x[ 2 ] == schet_->BUKVA .and. x[ 7 ] == schet_->smo } ) ) == 0
                AAdd( arr_bukva, { "", schet_->BUKVA, 0, 0, 0, 0, schet_->smo } ) ; j := Len( arr_bukva )
              Endif
              arr_bukva[ j, 3 ] += schet->summa
              arr_bukva[ j, 4 ] += schet->kol
              arr_bukva[ j, 5 ] += js
              arr_bukva[ j, 6 ] += jh
            Endif
          Endif
          If fl
            If pj > 0
              add_string( Space( 21 ) + Replicate( "=", sh - 21 ) )
              add_string( PadL( "Итого:", 30 ) + ;
                put_val( pp[ 4 ], 6 ) + put_kope( pp[ 3 ], 13 ) + ;
                put_val( pp[ 6 ], 6 ) + put_kope( pp[ 5 ], 13 ) )
              If !Empty( old_smo )
                ASort( arr_bukva, , , {| x, y| x[ 2 ] < y[ 2 ] } )
                fl := .t.
                For i := 1 To Len( arr_bukva )
                  If arr_bukva[ i, 7 ] == old_smo
                    If fl
                      add_string( Replicate( '-', sh ) )
                    Endif
                    s := PadL( iif( fl, 'в т.ч. ', '' ), 30 ) + ;
                      put_val( arr_bukva[ i, 4 ], 6 ) + put_kope( arr_bukva[ i, 3 ], 13 ) + ;
                      put_val( arr_bukva[ i, 6 ], 6 ) + put_kope( arr_bukva[ i, 5 ], 13 ) + ' '
                    If ( j := AScan( get_bukva(), {| x| x[ 2 ] == arr_bukva[ i, 2 ] } ) ) > 0
                      s += get_bukva()[ j, 1 ]
                    Else
                      s += arr_bukva[ i, 2 ]
                    Endif
                    add_string( s )
                    fl := .f.
                  Endif
                Next
              Endif
              add_string( '' )
            Endif
            pj := 0 ; AFill( pp, 0 )
          Endif
          pj++
          pp[ 3 ] += schet->summa
          pp[ 4 ] += schet->kol
          pp[ 5 ] += js
          pp[ 6 ] += jh
          old_smo := schet_->smo
          old_komu := schet->komu ; old_str_crb := schet->str_crb
        Endif
        add_string( schet_->nschet + " " + date_8( schet_->dschet ) + " " + ;
          put_otch_period() + ;
          put_val( schet->kol, 6 ) + put_kope( schet->summa, 13 ) + ;
          put_val( jh, 6 ) + put_kope( js, 13 ) + ;
          " " + f4_view_list_schet() )
      Endif
      Select SCHET
      Skip
    Enddo
    If k3 == 2
      If pj > 0
        add_string( Space( 21 ) + Replicate( "=", sh - 21 ) )
        add_string( PadL( "Итого:", 30 ) + ;
          put_val( pp[ 4 ], 6 ) + put_kope( pp[ 3 ], 13 ) + ;
          put_val( pp[ 6 ], 6 ) + put_kope( pp[ 5 ], 13 ) )
        If !Empty( old_smo )
          ASort( arr_bukva, , , {| x, y| x[ 2 ] < y[ 2 ] } )
          fl := .t.
          For i := 1 To Len( arr_bukva )
            If arr_bukva[ i, 7 ] == old_smo
              If fl
                add_string( Replicate( '-', sh ) )
              Endif
              s := PadL( iif( fl, 'в т.ч. ', '' ), 30 ) + ;
                put_val( arr_bukva[ i, 4 ], 6 ) + put_kope( arr_bukva[ i, 3 ], 13 ) + ;
                put_val( arr_bukva[ i, 6 ], 6 ) + put_kope( arr_bukva[ i, 5 ], 13 ) + ' '
              If ( j := AScan( get_bukva(), {| x| x[ 2 ] == arr_bukva[ i, 2 ] } ) ) > 0
                s += get_bukva()[ j, 1 ]
              Else
                s += arr_bukva[ i, 2 ]
              Endif
              add_string( s )
              fl := .f.
            Endif
          Next
        Endif
        add_string( '' )
      Endif
    Endif
    If k3 > 2  // разбивка по отд. и службам
      s35_statist( k4,, sh, HH, arr_title )
    Else
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( Replicate( "=", sh ) )
      If arr_uch[ 3 ] > 0
        add_string( PadL( "Итого : ", 30 ) + ;
          put_val( arr_uch[ 4 ], 6 ) + put_kope( arr_uch[ 3 ], 13 ) + ;
          put_val( arr_uch[ 6 ], 6 ) + put_kope( arr_uch[ 5 ], 13 ) )
        ASort( arr_bukva,,, {| x, y| x[ 2 ] < y[ 2 ] } )
        fl := .t.
        For i := 1 To Len( arr_bukva )
          If Empty( arr_bukva[ i, 7 ] )
            If fl
              add_string( Replicate( '-', sh ) )
            Endif
            s := PadL( iif( fl, 'в т.ч. ', '' ), 30 ) + ;
              put_val( arr_bukva[ i, 4 ], 6 ) + put_kope( arr_bukva[ i, 3 ], 13 ) + ;
              put_val( arr_bukva[ i, 6 ], 6 ) + put_kope( arr_bukva[ i, 5 ], 13 ) + ' '
            If ( j := AScan( get_bukva(), {| x| x[ 2 ] == arr_bukva[ i, 2 ] } ) ) > 0
              s += get_bukva()[ j, 1 ]
            Else
              s += arr_bukva[ i, 2 ]
            Endif
            add_string( s )
            fl := .f.
          Endif
        Next
      Endif
    Endif
    Close databases
    FClose( fp )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  Close databases
  rest_box( buf )
  Return Nil

//
Static Function add_tmp_os( _sum, _kol, _sum1, _kol1 )

  If !emptyall( _sum1, _kol1 )
    atmp_os[ 5 ] += _sum1 ; arr_uch[ 5 ] += _sum1
    atmp_os[ 6 ] += _kol1 ; arr_uch[ 6 ] += _kol1
  Endif
  atmp_os[ 3 ] += _sum ; arr_uch[ 3 ] += _sum
  atmp_os[ 4 ] += _kol ; arr_uch[ 4 ] += _kol
  Return Nil

//
Static Function s31_statist( k3, k4 )

  Local arr_title

  Default k4 To 2
  If k3 < 3
    arr_title := { ;
      "───────────────┬────────┬─────╥─────┬────────────╥─────┬────────────╥─────────────────────────────────", ;
      "               │ Дата   │Отчёт║ Кол.│            ║ Кол.│Сумма снятий║                                 ", ;
      "  Номер счета  │ счета  │перио║больн│ Сумма счёта║снято│  по актам  ║      Принадлежность счета       ", ;
      "───────────────┴────────┴─────╨─────┴────────────╨─────┴────────────╨─────────────────────────────────" }
  Elseif k4 == 1
    arr_title := { ;
      "───────────────────╥───────────────────╥─────────────────────────────────", ;
      "  Больных в счёте  ║   Снято с оплаты  ║                                 ", ;
      "──────┬────────────╫──────┬────────────╢                                 ", ;
      "Кол-во│ Сумма счёта║Кол-во│Сумма снятия║      Наименования отделений     ", ;
      "──────┴────────────╨──────┴────────────╨─────────────────────────────────" }
  Else
    arr_title := { ;
      "───────────────────╥───────────────────╥─────────────────────────────────", ;
      "   Услуг в счёте   ║   Снято с оплаты  ║                                 ", ;
      "──────┬────────────╫──────┬────────────╢                                 ", ;
      "Кол-во│ Сумма счёта║Кол-во│Сумма снятия║      Наименования " + iif( k3 == 3, "отделений", "служб" ), ;
      "──────┴────────────╨──────┴────────────╨─────────────────────────────────" }
  Endif
  Return arr_title

//
Static Function s33_statist( k3, k4 )

  Local arr_os := {}

  dbCreate( cur_dir() + "tmp_os", { { "kod", "N", 3, 0 }, { "name", "C", 30, 0 }, ;
    { "p3", "N", 17, 2 }, { "p4", "N", 7, 0 }, ;
    { "p5", "N", 17, 2 }, { "p6", "N", 7, 0 } } )
  Use ( cur_dir() + "tmp_os" ) new
  Index On Str( kod, 3 ) to ( cur_dir() + "tmp_os" )
  If k3 == 3  // С разбивкой по отделениям
    otd->( dbEval( {|| AAdd( arr_os, { kod, name } ) } ) )
    ASort( arr_os,,, {| x, y| x[ 2 ] < y[ 2 ] } )
    AEval( arr_os, {| x| tmp_os->( __dbAppend() ), ;
      tmp_os->kod := x[ 1 ], ;
      tmp_os->name := x[ 2 ] } )
  Else        // С разбивкой по службам
    sl->( dbEval( {|| AAdd( arr_os, { shifr, name } ) } ) )
    ASort( arr_os,,, {| x, y| x[ 2 ] < y[ 2 ] } )
    AEval( arr_os, {| x| tmp_os->( __dbAppend() ), ;
      tmp_os->kod := x[ 1 ], ;
      tmp_os->name := x[ 2 ] } )
  Endif
  Return Nil

//
Static Function s34_statist( k3, k4 )

  Local fl, js, k, p

  Default k4 To 2
  Select HUMAN
  find ( Str( schet->kod, 6 ) )
  Do While human->schet == schet->kod .and. !Eof()
    updatestatus()
    js := k := 0 ; p := 1
    If human_->oplata == 3
      js := human->cena_1 - human_->sump
      ++k
      p := js / human->cena_1
    Elseif eq_any( human_->oplata, 2, 9 )
      js := human->cena_1
      ++k
    Endif
    If k4 == 1
      tmp_os->( dbSeek( Str( human->otd, 3 ) ) )
      If tmp_os->( Found() )
        If !Empty( js )
          tmp_os->p5 += js            ; arr_uch[ 5 ] += js
          tmp_os->p6++               ; arr_uch[ 6 ] ++
        Endif
        tmp_os->p3 += human->cena_1 ; arr_uch[ 3 ] += human->cena_1
        tmp_os->p4++               ; arr_uch[ 4 ] ++
      Else
        add_tmp_os( human->cena_1, 1, js, k )
      Endif
    Else
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        fl := .f.
        If k3 == 3
          tmp_os->( dbSeek( Str( hu->otd, 3 ) ) )
          fl := tmp_os->( Found() )
        Elseif k3 == 4
          Select USL
          find ( Str( hu->u_kod, 4 ) )
          If Found()
            tmp_os->( dbSeek( Str( usl->slugba, 3 ) ) )
            fl := tmp_os->( Found() )
          Endif
        Endif
        If fl
          If !Empty( js )
            tmp_os->p5 += p * hu->stoim_1 ; arr_uch[ 5 ] += p * hu->stoim_1
            tmp_os->p6 += p * hu->kol_1   ; arr_uch[ 6 ] += p * hu->kol_1
          Endif
          tmp_os->p3 += hu->stoim_1   ; arr_uch[ 3 ] += hu->stoim_1
          tmp_os->p4 += hu->kol_1     ; arr_uch[ 4 ] += hu->kol_1
        Else
          If Empty( js )
            add_tmp_os( hu->stoim_1, hu->kol_1, 0, 0 )
          Else
            add_tmp_os( hu->stoim_1, hu->kol_1, p * hu->stoim_1, p * hu->kol_1 )
          Endif
        Endif
        Select HU
        Skip
      Enddo
    Endif
    Select HUMAN
    Skip
  Enddo
  Return Nil

//
Static Function s35_statist( k4, _1, sh, HH, arr_title )

  Local mname, n := 6

  Select TMP_OS
  Set Index To
  Go Top
  Do While !Eof()
    If tmp_os->p3 > 0
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      mname := AllTrim( tmp_os->name )
      add_string( put_val( tmp_os->p4, n ) + put_kope( tmp_os->p3, 13 ) + " " + ;
        put_val( tmp_os->p6, n ) + put_kope( tmp_os->p5, 13 ) + " " + mname )
    Endif
    Select TMP_OS
    Skip
  Enddo
  If atmp_os[ 3 ] > 0
    mname := ".. расхождение из-за неудачного поиска"
    add_string( put_val( atmp_os[ 4 ], n ) + put_kope( atmp_os[ 3 ], 13 ) + " " + ;
      put_val( atmp_os[ 6 ], n ) + put_kope( atmp_os[ 5 ], 13 ) + " " + mname )
  Endif
  add_string( Replicate( "─", sh ) )
  If arr_uch[ 3 ] > 0
    add_string( put_val( arr_uch[ 4 ], 6 ) + put_kope( arr_uch[ 3 ], 13 ) + " " + ;
      put_val( arr_uch[ 6 ], 6 ) + put_kope( arr_uch[ 5 ], 13 ) )
  Endif
  Return Nil

// информация по конкретному счету
Function s4_statist()

  Local buf := SaveScreen(), buf24 := save_maxrow(), arr_blk, ;
    sh := 108, HH := 57, reg_print := 3, name_file := cur_dir() + 'infschet.txt'
  Private atmp_os[ 8 ], arr_uch[ 8 ]

  If input_schet( 0 )
    waitstatus()
    If r_use( dir_server() + "human_",, "HUMAN_" ) .and. ;
        r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" ) .and. ;
        r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" ) .and. ;
        r_use( dir_server() + "mo_otd",, "OTD" ) .and. ;
        r_use( dir_server() + "slugba", dir_server() + "slugba", "SL" ) .and. ;
        r_use( dir_server() + "uslugi", dir_server() + "uslugi", "USL" ) .and. ;
        r_use( dir_server() + "schet_",, "SCHET_" ) .and. ;
        r_use( dir_server() + "schet",, "SCHET" )
      Set Relation To RecNo() into SCHET_
      Goto ( glob_schet )
      If schet->lpu > 0
        glob_uch[ 1 ] := schet->lpu
        glob_uch[ 2 ] := inieditspr( A__POPUPMENU, dir_server() + "mo_uch", schet->lpu )
      Endif
      Private p_number := AllTrim( schet_->nschet ), ;
        p_date := schet_->dschet, ;
        str_kriterij := func_kriterij()
      Select HUMAN
      Set Relation To RecNo() into HUMAN_
      fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
      add_string( "" )
      add_string( "Счет № " + AllTrim( p_number ) + " от " + DToC( p_date ) + "г." )
      If schet->lpu > 0
        add_string( "ЛПУ: " + glob_uch[ 2 ] )
      Endif
      add_string( f4_view_list_schet() )
      add_string( "" )
      add_string( "Разноска по отделениям" )
      arr_title := s31_statist( 3, 2 )
      reg_print := f_reg_print( arr_title, @sh )
      AEval( arr_title, {| x| add_string( x ) } )
      AFill( atmp_os, 0 ) ; AFill( arr_uch, 0 )
      s33_statist( 3, 2 )
      s34_statist( 3, 2 )
      s35_statist( 2,, sh, HH, arr_title )
      tmp_os->( dbCloseArea() )
      add_string( "" )
      add_string( "Разноска по службам" )
      arr_title := s31_statist( 4, 2 )
      AEval( arr_title, {| x| add_string( x ) } )
      AFill( atmp_os, 0 ) ; AFill( arr_uch, 0 )
      s33_statist( 4, 2 )
      s34_statist( 4, 2 )
      s35_statist( 2,, sh, HH, arr_title )
      FClose( fp )
      //
      str_find := Str( glob_schet, 6 )
      muslovie := "human->schet == glob_schet"
      arr_blk := { {|| findfirst( str_find ) }, ;
        {|| findlast( str_find ) }, ;
        {| n| skippointer( n, muslovie ) }, ;
        str_find, muslovie;
        }
      Select HUMAN
      find ( str_find )
      alpha_browse( 7, 2, MaxRow() -2, 77, "s41_statist", color1, ;
        "Список больных из счета", "G+/B", .f., .t., arr_blk,, "s42_statist",, ;
        { '═', '░', '═', "W+/B,N/W,GR+/B,GR+/R", .t., 300 } )
    Endif
    Close databases
    rest_box( buf24 )
  Endif
  RestScreen( buf )
  Return Nil

//
Function s41_statist( oBrow )

  Local oColumn, n := 34, blk_color := {|| iif( eq_any( human_->oplata, 2, 3, 9 ), { 3, 4 }, { 1, 2 } ) }

  oColumn := TBColumnNew( Center( "Ф.И.О. больного", n ), {|| Left( human->fio, n ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Начало;лечения", {|| date_8( human->n_data ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Оконч.;лечения", {|| date_8( human->k_data ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Сумма лечения", ;
    {|| PadL( expand_value( human->cena_1, 2 ), 14 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " ", {|| iif( eq_any( human_->oplata, 2, 9 ), "снятие", ;
    iif( human_->oplata == 3, "частич", Space( 6 ) ) ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ - выход;  ^<F9>^ - информация о счете" )
  Return Nil

//
Function s42_statist( nKey, oBrow )

  Local k := -1

  If nkey == K_F9
    viewtext( cur_dir() + "infschet.txt", , , , .t., , , 3 )
  Endif
  Return k

// для ТФОМС (по ф.14)
Function s5_statist()

  Local si := 1
  Local begin_date, end_date, buf := save_maxrow(), arr_m, ltip
  Local adbf

  If ( ltip := popup_prompt( T_ROW, T_COL - 5, si, ;
      { "По ~всем больным", "В том числе по ~детям" } ) ) == 0
    Return Nil
  Endif
  si := ltip
  If ( arr_m := year_month() ) == Nil .or. menu_schet_akt() == 0
    Return Nil
  Endif
  If pds == 2
    Private mdate_reg
    If !is_otch_period( arr_m )
      Return Nil
    Elseif !ret_date_reg_otch_period()
      Return Nil
    Endif
  Endif
  begin_date := arr_m[ 7 ]
  end_date := arr_m[ 8 ]
  //
  mywait()
  //
  adbf := { { "KOMU",   "N",     1,     0 }, ; // от 1 до 5
    { "STR_CRB",   "N",     2,     0 }, ; // код стр.компании, комитета и т.п.
    { "NKOMU",   "C",    60,     0 }, ;
    { "SMO",   "C",     5,     0 }, ; // код СМО
    { "LPU",   "N",     2,     0 }, ;
    { "NLPU",   "C",    30,     0 }, ;
    { "KOL_BOLN",   "N",     6,     0 }, ;
    { "SUMMA",   "N",    13,     2 }, ;
    { "is", "N", 1, 0 } }
  dbCreate( cur_dir() + "tmp_smo", adbf )
  Use ( cur_dir() + "tmp_smo" ) New Alias TMP
  Index On smo to ( cur_dir() + "tmp_smo1" )
  Index On nkomu to ( cur_dir() + "tmp_smo2" )
  Set Index to ( cur_dir() + "tmp_smo1" ), ( cur_dir() + "tmp_smo2" )
  r_use( dir_server() + "schet_",, "SCHET_" )
  r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
  Set Relation To RecNo() into SCHET_
  Set Filter To Empty( schet_->IS_DOPLATA )
  If pds == 1
    dbSeek( begin_date, .t. )
    Index On pdate to ( cur_dir() + "tmp_s" ) While pdate <= end_date
  Elseif pds == 2
    If mdate_reg == NIL
      Index On pdate to ( cur_dir() + "tmp_s" ) ;
        For between_otch_period( schet_->dschet, schet_->NYEAR, schet_->NMONTH, arr_m[ 5 ], arr_m[ 6 ] )
    Else
      Index On pdate to ( cur_dir() + "tmp_s" ) ;
        For between_otch_period( schet_->dschet, schet_->NYEAR, schet_->NMONTH, arr_m[ 5 ], arr_m[ 6 ] ) ;
        .and. schet_->NREGISTR == 0 .and. date_reg_schet() <= mdate_reg
    Endif
  Else
    Index On pdate to ( cur_dir() + "tmp_s" ) ;
      For schet_->NREGISTR == 0 .and. Between( date_reg_schet(), arr_m[ 5 ], arr_m[ 6 ] )
  Endif
  Go Top
  Do While !Eof()
    If !Empty( Val( schet_->smo ) )
      Select TMP
      find ( schet_->smo )
      If !Found()
        Append Blank
        Replace tmp->smo With schet_->smo, ;
          tmp->is With iif( Int( Val( schet_->smo ) ) == 34, 0, 1 )
      Endif
      tmp->kol_boln += schet->kol
      tmp->summa += schet->summa
    Endif
    Select SCHET
    Skip
  Enddo
  If tmp->( LastRec() ) == 0
    rest_box( buf )
    func_error( 4, "Нет счетов за указанный период времени!" )
  Else
    schet->( dbCloseArea() )
    Select TMP
    dbEval( {|| tmp->nkomu := f4_view_list_schet( 0, tmp->smo, 0 ) } )
    Set Order To 2
    Go Top
    If alpha_browse( T_ROW, 0, 23, 79, "s51statist", color0, ;
        "Счета " + arr_m[ 4 ], "R/BG",,,,, ;
        "s52statist",, { '═', '░', '═', "N/BG,W+/N,B/BG,W+/B",, 0 } )
      Close databases
      s53statist( ltip, arr_m, begin_date, end_date )
    Endif
    rest_box( buf )
  Endif
  Close databases
  Return Nil

//
Function s51statist( oBrow )

  Local oColumn, blk := {|| iif ( tmp->is == 1, { 1, 2 }, { 3, 4 } ) }

  oColumn := TBColumnNew( " ", {|| if( tmp->is == 1, "", " " ) } )
  oBrow:addcolumn( oColumn )
  oColumn:colorBlock := blk
  oColumn := TBColumnNew( Center( "Принадлежность счета", 35 ), {|| Left( tmp->nkomu, 35 ) } )
  oBrow:addcolumn( oColumn )
  oColumn:colorBlock := blk
  oColumn := TBColumnNew( " Кол.; бол.", {|| Str( tmp->kol_boln, 6 ) } )
  oBrow:addcolumn( oColumn )
  oColumn:colorBlock := blk
  oColumn := TBColumnNew( " Сумма счета", {|| put_kop( tmp->summa, 13 ) } )
  oBrow:addcolumn( oColumn )
  oColumn:colorBlock := blk
  oColumn := TBColumnNew( " ", {|| if( tmp->is == 1, "", " " ) } )
  oBrow:addcolumn( oColumn )
  oColumn:colorBlock := blk
  status_key( "^<Esc>^ - выход;  ^<Enter>^ - подсчет;  ^<Ins><+><->^ - отметить СМО для подсчета" )
  Return Nil

//
Function s52statist( nKey, oBrow )

  Local ret := 0

  Do Case
  Case nKey == 45  // минус
    rec := tmp->( RecNo() )
    tmp->( dbEval( {|| tmp->is := 0 } ) )
    tmp->( dbGoto( rec ) )
    ret := 0
  Case nKey == 43  // плюс
    rec := tmp->( RecNo() )
    tmp->( dbEval( {|| tmp->is := 1 } ) )
    tmp->( dbGoto( rec ) )
    ret := 0
  Case nKey == K_INS
    tmp->is := iif( tmp->is == 1, 0, 1 )
    oBrow:down()
    ret := 0
  Endcase
  Return ret

// 02.02.24
Function s53statist( ltip, arr_m, begin_date, end_date )

  Local i, j, k, s, buf := save_maxrow(), ;
    fl_exit := .f., sh := 80, HH := 59, reg_print := 2, lshifr1, ;
    arr_title, name_file := cur_dir() + 'tfomsf14.txt', flag_uet := .t., koef, ;
    kol_schet := 0, lreg_lech, ta, arr_name := f14tf_array(), ;
    arr_lp := {}, arr_dn_st, d2_year, adbf

  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  adbf := { { "tip", "N", 2, 0 }, ;
    { "shifr", "C", 10, 0 }, ;
    { "u_name", "C", 120, 0 }, ;
    { "kol", "N", 11, 3 }, ;
    { "uet", "N", 11, 4 }, ;
    { "sum", "N", 16, 2 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On Str( tip, 2 ) + shifr to ( cur_dir() + "tmp" )
  Use ( cur_dir() + "tmp_smo" ) index ( cur_dir() + "tmp_smo1" ) New Alias TMP_SMO
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
  Set Relation To u_kod into USL
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  r_use( dir_server() + "schet_",, "SCHET_" )
  r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
  Set Relation To RecNo() into SCHET_
  Set Filter To Empty( schet_->IS_DOPLATA ) .and. !Empty( Val( schet_->smo ) )
  If pds == 1
    dbSeek( begin_date, .t. )
    Index On pdate to ( cur_dir() + "tmp_s" ) While pdate <= end_date
  Elseif pds == 2
    If mdate_reg == NIL
      Index On pdate to ( cur_dir() + "tmp_s" ) ;
        For between_otch_period( schet_->dschet, schet_->NYEAR, schet_->NMONTH, arr_m[ 5 ], arr_m[ 6 ] )
    Else
      Index On pdate to ( cur_dir() + "tmp_s" ) ;
        For between_otch_period( schet_->dschet, schet_->NYEAR, schet_->NMONTH, arr_m[ 5 ], arr_m[ 6 ] ) ;
        .and. schet_->NREGISTR == 0 .and. date_reg_schet() <= mdate_reg
    Endif
  Else
    Index On pdate to ( cur_dir() + "tmp_s" ) ;
      For schet_->NREGISTR == 0 .and. Between( date_reg_schet(), arr_m[ 5 ], arr_m[ 6 ] )
  Endif
  as := Array( 10, 3 ) ; afillall( as, 0 )
  s_stac := sdstac := s_amb := s_kt := s_smp := 0
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say PadR( "№ " + AllTrim( schet_->nschet ) + " от " + ;
      date_8( schet_->dschet ), 25 ) Color "W/R"
    Select TMP_SMO
    find ( schet_->smo )
    If Found() .and. tmp_smo->is == 1
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If iif( ltip == 1, .t., human->VZROS_REB > 0 ) ;
            .and. f_usl_schet_akt( human_->oplata )
          koef := 1
          If glob_schet_akt == 2 .and. human_->oplata == 3
            koef := human_->sump / human->cena_1
          Endif
          d2_year := Year( human->k_data )
          lreg_lech := { 0, 0, 0, 0, 0 }
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            If f_paraklinika( usl->shifr, lshifr1, human->k_data )
              lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
              ta := f14tf_nastr( lshifr,, d2_year )
              For j := 1 To Len( ta )
                k := ta[ j, 1 ]
                If Between( k, 1, 10 ) .and. ta[ j, 2 ] >= 0
                  i := 2                // остальные - амбулаторно
                  If k == 2             // k := 2 - койко-дни
                    i := 1
                  Elseif Between( k, 3, 5 ) // k := 3,4,5 - дневной стационар
                    i := 3
                  Elseif k == 7
                    i := 4
                  Elseif k == 8
                    i := 5
                  Endif
                  ++lreg_lech[i ]
                Endif
              Next
            Endif
            Select HU
            Skip
          Enddo
          If lreg_lech[ 1 ] > 0
            ++s_stac
          Elseif lreg_lech[ 3 ] > 0
            ++sdstac
          Elseif lreg_lech[ 4 ] > 0
            ++s_kt
          Elseif lreg_lech[ 5 ] > 0
            ++s_smp
          Else
            ++s_amb
          Endif
          arr_dn_st := { "", "", 0 }
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            If f_paraklinika( usl->shifr, lshifr1, human->k_data )
              s := lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
              lname := AllTrim( usl->name )
              ta := f14tf_nastr( @lshifr, @lname, d2_year )
              lshifr := PadR( lshifr, 10 )
              For j := 1 To Len( ta )
                k := ta[ j, 1 ]
                If Between( k, 1, 10 )
                  If ta[ j, 2 ] == 1 // законченный случай
                    mkol := human->k_data - human->n_data // койко-день
                    If Between( ta[ j, 1 ], 3, 5 ) // дневной стационар до 1 апреля
                      ++mkol
                    Endif
                    If ( i := AScan( arr_lp, {| x| x[ 1 ] == lshifr } ) ) == 0
                      AAdd( arr_lp, { lshifr, {} } ) ; i := Len( arr_lp )
                    Endif
                    If ( i1 := AScan( arr_lp[ i, 2 ], {| x| x[ 1 ] == s } ) ) == 0
                      AAdd( arr_lp[ i, 2 ], { s, 0, 0 } ) ; i1 := Len( arr_lp[ i, 2 ] )
                    Endif
                    arr_lp[ i, 2, i1, 2 ] += mkol
                    arr_lp[ i, 2, i1, 3 ] ++
                  Elseif ta[ j, 2 ] == 0
                    mkol := hu->kol_1
                    If Between( ta[ j, 1 ], 3, 5 ) // дневной стационар после 1 апреля
                      arr_dn_st[ 2 ] := lshifr
                      arr_dn_st[ 3 ] := mkol
                    Endif
                  Else
                    mkol := 0
                    If Between( ta[ j, 1 ], 3, 5 ) // дневной стационар после 1 апреля
                      arr_dn_st[ 1 ] := lshifr
                    Endif
                  Endif
                  If Year( human->k_data ) > 2012 .and. hu->kol_rcp < 0 ;
                      .and. domuslugatfoms( lshifr )
                    s := iif( hu->kol_rcp == -1, "на дому", "домАКТИВ" )
                    If ( i := AScan( arr_lp, {| x| x[ 1 ] == lshifr } ) ) == 0
                      AAdd( arr_lp, { lshifr, {} } ) ; i := Len( arr_lp )
                    Endif
                    If ( i1 := AScan( arr_lp[ i, 2 ], {| x| x[ 1 ] == s } ) ) == 0
                      AAdd( arr_lp[ i, 2 ], { s, 0, 0 } ) ; i1 := Len( arr_lp[ i, 2 ] )
                    Endif
                    arr_lp[ i, 2, i1, 2 ] += mkol
                    arr_lp[ i, 2, i1, 3 ] ++
                  Endif
                  muet := 0
                  msum := hu->stoim_1 * koef
                  If Between( k, 9, 10 )  // УЕТ для стоматологий
                    muet := round_5( mkol * ret_tfoms_uet( usl->shifr, lshifr1, human->vzros_reb ), 4 )
                  Endif
                  Select TMP
                  find ( Str( k, 2 ) + PadR( lshifr, 10 ) )
                  If !Found()
                    Append Blank
                    tmp->tip := k
                    tmp->shifr := lshifr
                    tmp->u_name := lname
                  Endif
                  tmp->kol += mkol
                  tmp->uet += muet
                  tmp->sum += msum
                  as[ k, 1 ] += mkol
                  as[ k, 2 ] += muet
                  as[ k, 3 ] += msum
                Else
                  k := 11
                  Select TMP
                  find ( Str( k, 2 ) + PadR( lshifr, 10 ) )
                  If !Found()
                    Append Blank
                    tmp->tip := k
                    tmp->shifr := lshifr
                    tmp->u_name := lname
                  Endif
                  tmp->kol += hu->kol_1
                  tmp->sum += hu->stoim_1 * koef
                Endif
              Next
            Endif
            Select HU
            Skip
          Enddo
          // дневной стационар с 1 апреля 2013 года
          If !emptyany( arr_dn_st[ 1 ], arr_dn_st[ 2 ], arr_dn_st[ 3 ] )
            If ( i := AScan( arr_lp, {| x| x[ 1 ] == arr_dn_st[ 1 ] } ) ) == 0
              AAdd( arr_lp, { arr_dn_st[ 1 ], {} } ) ; i := Len( arr_lp )
            Endif
            If ( i1 := AScan( arr_lp[ i, 2 ], {| x| x[ 1 ] == arr_dn_st[ 2 ] } ) ) == 0
              AAdd( arr_lp[ i, 2 ], { arr_dn_st[ 2 ], 0, 0 } ) ; i1 := Len( arr_lp[ i, 2 ] )
            Endif
            arr_lp[ i, 2, i1, 2 ] += arr_dn_st[ 3 ]
            arr_lp[ i, 2, i1, 3 ] ++
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
    Endif
    Select SCHET
    Skip
  Enddo
  //
  arr_title := { ;
    "──────────────────────────────────────────────────────────┬──────┬──────────────", ;
    "                                                          │Кол-во│  Стоимость   ", ;
    "                                                          │ услуг│    услуг     ", ;
    "──────────────────────────────────────────────────────────┴──────┴──────────────" }
  arr1title := { ;
    "─────────────────────────────────────────────────┬──────┬────────┬──────────────", ;
    "                                                 │Кол-во│        │  Стоимость   ", ;
    "                                                 │ услуг│ У.Е.Т. │    услуг     ", ;
    "─────────────────────────────────────────────────┴──────┴────────┴──────────────" }
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  If ltip == 2
    add_string( Center( "[ в том числе по детям ]", sh ) )
  Endif
  add_string( PadC( "Данные для заполнения формы N 14 (в ТФОМС) [старая]", sh ) )
  If pds == 1
    s := "дата выписки счетов"
  Elseif pds == 2
    s := "отчетный период"
  Else
    s := "дата регистрации счетов"
  Endif
  add_string( Center( "[ " + s + " " + arr_m[ 4 ] + " ]", sh ) )
  If pds == 2 .and. mdate_reg != NIL
    add_string( Center( "[ по счетам, зарегистрированным по " + full_date( mdate_reg ) + "г. включительно ]", sh ) )
  Endif

  add_string( Center( title_schet_akt( glob_schet_akt ), sh ) )

  add_string( "" )
  add_string( "Всего листов учета: " + lstr( s_stac + sdstac + s_amb + s_kt + s_smp ) )
  add_string( "       в том числе стационарно: " + lstr( s_stac ) )
  add_string( "                   амбулаторно: " + lstr( s_amb ) )
  add_string( "             дневной стационар: " + lstr( sdstac ) )
  add_string( "  отдельные медицинские услуги: " + lstr( s_kt ) )
  add_string( "           вызов скорой помощи: " + lstr( s_smp ) )
  add_string( "" )
  AEval( arr1title, {| x| add_string( x ) } )
  s1 := s2 := s3 := 0
  For i := 1 To 10
    If !emptyall( as[ i, 1 ], as[ i, 2 ], as[ i, 3 ] )
      k := perenos( ta, arr_name[ i ], 49 )
      If i == 6
        add_string( PadR( ta[ 1 ], 49 ) + Str( as[ i, 1 ], 7, 0 ) )
      Else
        add_string( PadR( ta[ 1 ], 49 ) + Str( as[ i, 1 ], 7, 0 ) + ;
          put_val_0( as[ i, 2 ], 9, 1 ) + ;
          put_kope( as[ i, 3 ], 15 ) )
      Endif
      For j := 2 To k
        add_string( PadL( AllTrim( ta[ j ] ), 49 ) )
      Next
      s1 += as[ i, 1 ]
      s2 += as[ i, 2 ]
      s3 += as[ i, 3 ]
    Endif
  Next
  add_string( Replicate( "─", sh ) )
  add_string( "" )
  add_string( Center( "Расшифровка по услугам", sh ) )
  Select TMP
  Index On Str( tip, 2 ) + fsort_usl( shifr ) to ( cur_dir() + "tmp" )
  For i := 1 To 11
    If i < 9 .or. i == 11
      ta := arr_title
    Else
      ta := arr1title
    Endif
    find ( Str( i, 2 ) )
    If Found()
      verify_ff( HH - 8, .t., sh )
      add_string( "" )
      add_string( Center( Upper( arr_name[ i ] ), sh ) )
      AEval( ta, {| x| add_string( x ) } )
      Do While tmp->tip == i .and. !Eof()
        If verify_ff( HH, .t., sh )
          AEval( ta, {| x| add_string( x ) } )
        Endif
        If i < 9 .or. i == 11
          k := perenos( as, tmp->u_name, 47 )
          add_string( tmp->shifr + " " + PadR( as[ 1 ], 47 ) + Str( tmp->kol, 7, 0 ) + ;
            put_kope( tmp->sum, 15 ) )
        Else
          k := perenos( as, tmp->u_name, 38 )
          add_string( tmp->shifr + " " + PadR( as[ 1 ], 38 ) + Str( tmp->kol, 7, 0 ) + ;
            " " + umest_val( tmp->uet, 8, 2 ) + ;
            put_kope( tmp->sum, 15 ) )
        Endif
        For j := 2 To k
          add_string( Space( 11 ) + as[ j ] )
        Next
        If ( j := AScan( arr_lp, {| x| x[ 1 ] == tmp->shifr } ) ) > 0
          For k := 1 To Len( arr_lp[ j, 2 ] )
            ASort( arr_lp[ j, 2 ],,, {| x, y| fsort_usl( x[ 1 ] ) < fsort_usl( y[ 1 ] ) } )
            s := PadL( "в т.ч." + PadL( AllTrim( arr_lp[ j, 2, k, 1 ] ), 8 ), 47 + 11 ) + ;
              Str( arr_lp[ j, 2, k, 2 ], 7 ) + " (" + lstr( arr_lp[ j, 2, k, 3 ] ) + ")"
            add_string( s )
          Next
        Endif
        Skip
      Enddo
    Endif
  Next
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( name_file,,,, .t.,,, reg_print )
  Return Nil

//
Function uzkie_spec( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "Выписка счета", "Подсчет услуг" }
    mas_msg := { "Выписка счета на оплату мед.помощи за счет средств Программы модернизации здраво", ;
      "Подсчет услуг с разбивкой по узким специалистам" }
    mas_fun := { "uzkie_spec(11)", "uzkie_spec(12)" }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    uzkie1spec()
  Case k == 12
    uzkie2spec()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif
  Return Nil

//
Function uzkie1spec()

  Local buf := SaveScreen(), r1 := 15
  Private mstrah := PadR( glob_strah[ 2 ], 30 ), m1strah := glob_strah[ 1 ], ;
    m1period := 0, mperiod := Space( 10 ), parr_m, ;
    mnomer := Space( 10 ), mdate := sys_date, ;
    msumma := 0, gl_area := { r1, 0, 23, 79, 0 }

  box_shadow( r1, 2, 22, 77, color1, "Ввод реквизитов счета на оплату услуг", color8 )
  tmp_solor := SetColor( cDataCGet )
  Do While .t.
    @ r1 + 2, 4 Say "Период времени" Get mperiod ;
      reader {| x| menu_reader( x, ;
      { {| k, r, c| k := year_month( r + 1, c ), ;
      if( k == nil, nil, ( parr_m := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
      k } }, A__FUNCTION,,, .f. ) }
//    @ r1 + 3, 4 Say "Страховая компания" Get mstrah ;
//      reader {| x| menu_reader( x, glob_arr_smo, A__MENUVERT,,, .f. ) }
    @ r1 + 3, 4 Say "Страховая компания" Get mstrah ;
      reader {| x| menu_reader( x, smo_volgograd(), A__MENUVERT,,, .f. ) }
    @ r1 + 4, 4 Say "Номер" Get mnomer
    @ Row(), Col() + 1 Say "и дата" Get mdate
    @ Row(), Col() + 1 Say "счета"
    @ r1 + 5, 4 Say "Сумма счета" Get msumma Pict "99999999.99"
    status_key( "^<Esc>^ - выход;  ^<PgDn>^ - печать счета" )
    myread()
    If LastKey() == K_ESC
      Exit
    Endif
    If Empty( m1period )
      func_error( 4, "Не введен период времени" )
      Loop
    Endif
    If Empty( m1strah )
      func_error( 4, "Не введена страховая компания" )
      Loop
    Endif
    glob_strah := { m1strah, AllTrim( mstrah ) }
    schetuzkiespec()
  Enddo
  RestScreen( buf )
  SetColor( tmp_solor )
  Return Nil

//
Function uzkie2spec()

  Static mm_perso := { { 'Персонал', 1 }, { 'Персонал+услуги', 2 }, ;
    { 'Услуги', 3 }, { 'Услуги+персонал', 4 } }
  Local buf := SaveScreen(), r1 := 13

  Private mstrah := PadR( glob_strah[ 2 ], 30 ), m1strah := glob_strah[ 1 ], ;
    m1usl := mm_danet[ 1, 2 ], musl := mm_danet[ 1, 1 ], ;
    m1period := 0, mperiod := Space( 10 ), parr_m, ;
    mprocent := 0, mperso := mm_perso[ 1, 1 ], m1perso := mm_perso[ 1, 2 ], ;
    msumma := 0, gl_area := { r1, 0, 23, 79, 0 }, arr_usl

  arr_usl := usllugiuzkiespec()
  box_shadow( r1, 2, 22, 77, color1, 'Подсчет услуг', color8 )
  tmp_solor := SetColor( cDataCGet )
  Do While .t.
    @ r1 + 2, 4 Say 'Период времени' Get mperiod ;
      reader {| x| menu_reader( x, ;
      { {| k, r, c| k := year_month( r + 1, c ), ;
      if( k == nil, nil, ( parr_m := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
      k } }, A__FUNCTION, , , .f. ) }
//    @ r1 + 3, 4 Say 'Страховая компания' Get mstrah ;
//      reader {| x| menu_reader( x, glob_arr_smo, A__MENUVERT, , , .f. ) }
    @ r1 + 3, 4 Say 'Страховая компания' Get mstrah ;
      reader {| x| menu_reader( x, smo_volgograd(), A__MENUVERT, , , .f. ) }
    @ r1 + 4, 4 Say 'Разрешить исключение некоторых услуг из списка ТФОМС?' Get musl ;
      reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
    @ r1 + 5, 4 Say 'Внешний вид документа' Get mperso ;
      reader {| x| menu_reader( x, mm_perso, A__MENUVERT, , , .f. ) }
    @ r1 + 6, 4 Say 'Процент для ассистента (в случае его присутствия)' Get mprocent Pict '99'
    @ r1 + 7, 4 Say 'Сумма для распределения' Get msumma Pict '99999999.99'
    status_key( '^<Esc>^ - выход;  ^<PgDn>^ - просмотр результатов подсчета' )
    myread()
    If LastKey() == K_ESC
      Exit
    Endif
    If Empty( m1period )
      func_error( 4, 'Не введен период времени' )
      Loop
    Endif
    If Empty( m1strah )
      func_error( 4, 'Не введена страховая компания' )
      Loop
    Endif
    glob_strah := { m1strah, AllTrim( mstrah ) }
    f1uzkie2spec()
  Enddo
  RestScreen( buf )
  SetColor( tmp_solor )
  Return Nil

//
Function f1uzkie2spec()

  Local fl_exit := .f., sh, HH := 60, reg_print, n_file := cur_dir() + "_uz_spec.txt", ;
    adbf := {}, lshifr, mkol := 0, delta, arr_fields := {}, abitusl, ;
    begin_date := parr_m[ 7 ], end_date := parr_m[ 8 ]

  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  If m1usl == 1
    abitusl := {}
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
    Set Relation To u_kod into USL
    r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
    r_use( dir_server() + "schet_",, "SCHET_" )
    r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( begin_date, .t. )
    Do While schet->pdate <= end_date .and. !Eof()
      If Int( Val( schet_->smo ) ) == glob_strah[ 1 ]
        @ MaxRow(), 0 Say PadR( "№ " + AllTrim( schet_->nschet ) + " от " + ;
          date_8( schet_->dschet ), 27 ) Color "W/R"
        Select HUMAN
        find ( Str( schet->kod, 6 ) )
        Do While human->schet == schet->kod
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
              lshifr := usl->shifr
            Endif
            lshifr := AllTrim( lshifr )
            If ( iusl := AScan( arr_usl, {| x| x[ 1 ] == lshifr } ) ) > 0 ;
                .and. AScan( abitusl, {| x| x[ 2 ] == hu->u_kod } ) == 0
              AAdd( abitusl, { usl->shifr + usl->name, hu->u_kod } )
            Endif
            Select HU
            Skip
          Enddo
          Select HUMAN
          Skip
        Enddo
        If fl_exit ; exit ; Endif
      Endif
      Select SCHET
      Skip
    Enddo
    Close databases
    If fl_exit
      Return Nil
    Endif
    ASort( abitusl,,, {| x, y| Left( fsort_usl( x[ 1 ] ), 10 ) < Left( fsort_usl( y[ 1 ] ), 10 ) } )
    If ( abitusl := bit_popup( T_ROW, 2, abitusl,, color5,, "Отмените исключаемые услуги", "B/W" ) ) == NIL
      Return Nil
    Endif
  Endif
  AAdd( adbf, { "kod_perso", "N", 4, 0 } )
  AAdd( adbf, { "tab_nomer", "N", 5, 0 } )
  AAdd( adbf, { "fio_perso", "C", 50, 0 } )
  AAdd( adbf, { "usl_shifr", "C", 10, 0 } )
  AAdd( adbf, { "usl_name", "C", 60, 0 } )
  AAdd( adbf, { "kol_usl", "N", 12, 5 } )
  AAdd( adbf, { "summa", "N", 15, 2 } )
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) new
  If m1perso < 3
    Index On Str( kod_perso, 4 ) + usl_shifr to ( cur_dir() + "tmp" )
  Else
    Index On usl_shifr + Str( kod_perso, 4 ) to ( cur_dir() + "tmp" )
  Endif
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
  Set Relation To u_kod into USL
  r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
  r_use( dir_server() + "schet_",, "SCHET_" )
  r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
  Set Relation To RecNo() into SCHET_
  Set Filter To Empty( schet_->IS_DOPLATA )
  dbSeek( begin_date, .t. )
  Do While schet->pdate <= end_date .and. !Eof()
    If Int( Val( schet_->smo ) ) == glob_strah[ 1 ]
      @ MaxRow(), 0 Say PadR( "№ " + AllTrim( schet_->nschet ) + " от " + ;
        date_8( schet_->dschet ), 27 ) Color "W/R"
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
            lshifr := usl->shifr
          Endif
          lshifr := AllTrim( lshifr )
          If ( iusl := AScan( arr_usl, {| x| x[ 1 ] == lshifr } ) ) > 0 .and. ;
              iif( m1usl == 0, .t., AScan( abitusl, {| x| x[ 2 ] == hu->u_kod } ) > 0 )
            arrp := {}
            If hu->kod_vr > 0
              AAdd( arrp, { hu->kod_vr, 1 } )
            Endif
            If hu->kod_as > 0
              AAdd( arrp, { hu->kod_as, 1 } )
            Endif
            If Empty( arrp )
              AAdd( arrp, { 0, 1 } )  // врач с кодом 0
            Endif
            If Len( arrp ) == 2
              If mprocent > 0
                arrp[ 2, 2 ] := round_5( mprocent / 100, 7 )  // для ассистента
                arrp[ 1, 2 ] := 1 -arrp[ 2, 2 ]  // для врача
              Else
                ASize( arrp, 1 ) // т.е. ассистенту ничего не платим
              Endif
            Endif
            For i := 1 To Len( arrp )
              If m1perso < 3
                str_find := Str( arrp[ i, 1 ], 4 )
                If m1perso == 2
                  str_find += PadR( lshifr, 10 )
                Endif
              Else
                str_find := PadR( lshifr, 10 )
                If m1perso == 4
                  str_find += Str( arrp[ i, 1 ], 4 )
                Endif
              Endif
              Select TMP
              find ( str_find )
              If !Found()
                Append Blank
                If m1perso != 3
                  tmp->kod_perso := arrp[ i, 1 ]
                Endif
                If m1perso != 1
                  tmp->usl_shifr := lshifr
                  tmp->usl_name := arr_usl[ iusl, 2 ]
                Endif
              Endif
              tmp->kol_usl += hu->kol_1 * arrp[ i, 2 ]
            Next
            mkol += hu->kol_1
          Endif
          Select HU
          Skip
        Enddo
        Select HUMAN
        Skip
      Enddo
      If fl_exit ; exit ; Endif
    Endif
    Select SCHET
    Skip
  Enddo
  If !fl_exit
    If mkol > 0
      delta := msumma / mkol
    Endif
    sh_usl := 55
    sh_perso := iif( m1perso == 1, 50, 30 )
    If m1perso != 1
      titl_usl := { ;
        "────────┬" + Replicate( "─", sh_usl ), ;
        "  Шифр  │" + PadR( " Наименование услуги", sh_usl ), ;
        "────────┴" + Replicate( "─", sh_usl ) }
    Endif
    If m1perso != 3
      titl_perso := { ;
        "─────┬" + Replicate( "─", sh_perso ), ;
        "Таб.№│" + PadR( " ФИО сотрудника", sh_perso ), ;
        "─────┴" + Replicate( "─", sh_perso ) }
      r_use( dir_server() + "mo_pers",, "P2" )
      tmp->( dbEval( {|| p2->( dbGoto( tmp->kod_perso ) ), ;
        tmp->tab_nomer := p2->tab_nom, ;
        tmp->fio_perso := p2->fio } ) )
      AAdd( arr_fields, "tab_nomer" )
      AAdd( arr_fields, "fio_perso" )
    Endif
    arr_title := Array( 3 ) ; AFill( arr_title, "" )
    Select TMP
    If m1perso < 3
      Index On Upper( fio_perso ) + usl_shifr to ( cur_dir() + "tmp" )
      arr_title[ 1 ] += titl_perso[ 1 ]
      arr_title[ 2 ] += titl_perso[ 2 ]
      arr_title[ 3 ] += titl_perso[ 3 ]
      If m1perso == 2
        arr_title[ 1 ] += "┬" + titl_usl[ 1 ]
        arr_title[ 2 ] += "│" + titl_usl[ 2 ]
        arr_title[ 3 ] += "┴" + titl_usl[ 3 ]
        AAdd( arr_fields, "usl_shifr" )
        AAdd( arr_fields, "usl_name" )
      Endif
    Else
      ins_array( arr_fields, 1, "usl_name" )
      ins_array( arr_fields, 1, "usl_shifr" )
      arr_title[ 1 ] += titl_usl[ 1 ]
      arr_title[ 2 ] += titl_usl[ 2 ]
      arr_title[ 3 ] += titl_usl[ 3 ]
      If m1perso == 4
        arr_title[ 1 ] += "┬" + titl_perso[ 1 ]
        arr_title[ 2 ] += "│" + titl_perso[ 2 ]
        arr_title[ 3 ] += "┴" + titl_perso[ 3 ]
      Endif
    Endif
    AAdd( arr_fields, "kol_usl" )
    arr_title[ 1 ] += "┬────────"
    arr_title[ 2 ] += "│Кол.усл."
    arr_title[ 3 ] += "┴────────"
    If msumma > 0 .and. mkol > 0
      AAdd( arr_fields, "summa" )
      delta := msumma / mkol
      tmp->( dbEval( {|| tmp->summa := tmp->kol_usl * delta } ) )
      arr_title[ 1 ] += "┬────────"
      arr_title[ 2 ] += "│ Сумма  "
      arr_title[ 3 ] += "┴────────"
    Endif
    reg_print := f_reg_print( arr_title, @sh )
    fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "Услуги по узким специалистам", sh ) )
    add_string( Center( AllTrim( mstrah ), sh ) )
    add_string( Center( parr_m[ 4 ], sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    Select TMP
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If m1perso < 3
        s := Str( tab_nomer, 5 ) + " " + PadR( fio_perso, sh_perso )
        If m1perso == 2
          s += " " + PadR( usl_shifr, 9 ) + PadR( usl_name, sh_usl )
        Endif
      Else
        s := PadR( usl_shifr, 9 ) + PadR( usl_name, sh_usl )
        If m1perso == 4
          s += " " + Str( tab_nomer, 5 ) + " " + PadR( fio_perso, sh_perso )
        Endif
      Endif
      s += put_val_0( kol_usl, 9, 2 )
      If msumma > 0 .and. mkol > 0
        s += put_kop( summa, 9 )
      Endif
      add_string( s )
      Skip
    Enddo
    If mkol > 0
      add_string( Replicate( "─", sh ) )
      If msumma > 0
        add_string( put_val( mkol, sh - 12 ) + put_kop( msumma, 12 ) )
      Else
        add_string( put_val_0( mkol, sh, 2 ) )
      Endif
    Endif
    FClose( fp )
    Close databases
    viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
    If mkol > 0
      clrline( 24, color0 )
      d_file := cur_dir() + "UZ_SPEC" + sdbf()
      If !del_dbf_file( d_file )
        Return Nil
      Endif
      Use ( cur_dir() + "tmp" ) new
      __dbCopy( d_file, arr_fields,,,,, .f., ) // copy fields kod_perso,fio_perso,kol_usl to (d_file)
      Close databases
      n_message( { "Создан файл для загрузки в Excel: " + d_file },, cColorStMsg, cColorStMsg,,, cColorSt2Msg )
    Endif
  Endif
  Close databases
  Return Nil

// 31.03.23
Function schetuzkiespec()

  Local sh := 84, HH := 60, reg_print := 2, i, j, k, s, t_arr[ 2 ], n_file := cur_dir() + "_schet.txt"

  //
  fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Счет", sh ) )
  add_string( Center( "на оплату медицинской помощи за счет средств Программы", sh ) )
  add_string( Center( "модернизации здравоохранения Волгоградской области на 2011-2012 годы", sh ) )
  add_string( Center( "в части повышения доступности амбулаторной медицинской помощи", sh ) )
  add_string( "" )
  r_use( dir_server() + "organiz",, "ORG" )
  add_string( "Поставщик:       " + AllTrim( org->name ) )
  add_string( "Адрес:           " + org->adres )
  add_string( "Расчетный счет:  " + AllTrim( org->r_schet ) + " " + AllTrim( org->bank ) )
  add_string( "БИК:             " + org->smfo )
  add_string( "Город:           " + "" )
  add_string( "ИНН:             " + org->inn )
  add_string( "Код по ОКОНХ:    " + org->okonh )
  add_string( "Код по ОКПО:     " + org->okpo )
  k := perenos( t_arr, AllTrim( org->name ) + ", " + AllTrim( org->adres ), sh - 17 )
  add_string( "Грузоотправитель " + t_arr[ 1 ] )
  add_string( "    и его адрес: " + t_arr[ 2 ] )
  i := 2
  Do While i < k
    i := i + 1
    add_string( Space( 17 ) + t_arr[ i ] )
  Enddo
  add_string( "" )
  add_string( Center( "СЧЕТ № " + AllTrim( mnomer ) + " от " + date_month( mdate ), sh ) )
  add_string( "" )
  If ( j := AScan( get_rekv_smo(), {| x| Int( Val( x[ 1 ] ) ) == glob_strah[ 1 ] } ) ) == 0
    j := Len( get_rekv_smo() ) // если не нашли - печатаем реквизиты ТФОМС
  Endif
  k := perenos( t_arr, get_rekv_smo()[ j, 2 ], sh -17 )
  add_string( PadR( "Плательщик:", 17 ) + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 17 ) + t_arr[ 2 ] )
  Next
  k := perenos( t_arr, get_rekv_smo()[ j, 6 ], sh -17 )
  add_string( PadR( 'Адрес:', 17 ) + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 17 ) + t_arr[ 2 ] )
  Next
  add_string( 'Расчетный счет:  ' + AllTrim( get_rekv_smo()[ j, 8 ] ) + ' ' + AllTrim( get_rekv_smo()[ j, 7 ] ) )
  add_string( 'БИК:             ' + get_rekv_smo()[ j, 9 ] )
  add_string( 'Город:           ' + '' )
  add_string( 'ИНН:             ' + AllTrim( get_rekv_smo()[ j, 3 ] ) + iif( Empty( get_rekv_smo()[ j, 4 ] ), '', '/' + get_rekv_smo()[ j, 4 ] ) )
  add_string( "Код по ОКОНХ:    " + "" )
  add_string( "Код по ОКПО:     " + "" )
  add_string( "" )
  add_string( "────────────────────────────────────────────────────────┬───────────────────────────" )
  add_string( " Наименование товара                                    │       Сумма (руб.)" )
  add_string( "────────────────────────────────────────────────────────┼───────────────────────────" )
  add_string( "Оплата медицинской помощи за счет целевых средств       │" )
  add_string( "на реализацию меропиятий по повышению доступности       │" )
  add_string( "амбулаторной медицинской помощи в рамках региональной   │" + Center( lstr( msumma, 11, 2 ), 27 ) )
  add_string( "программы модернизации здравоохранения                  │" )
  add_string( PadR( parr_m[ 4 ] + " без НДС", 56 ) +                          "│" )
  add_string( "────────────────────────────────────────────────────────┴───────────────────────────" )
  add_string( "" )
  k := perenos( t_arr, "К оплате: " + srub_kop( msumma, .t. ), sh )
  i := 0
  Do While i < k
    i := i + 1
    add_string( t_arr[ i ] )
  Enddo
  add_string( "" )
  add_string( "Главный врач медицинской организации      ________________ / " + AllTrim( org->ruk ) + " /" )
  add_string( "" )
  add_string( "Главный бухгалтер медицинской организации ________________ / " + AllTrim( org->bux ) + " /" )
  FClose( fp )
  Close databases
  viewtext( n_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

//
Function write_mn_p( k )

  Local fl := .t.

  If k == 1
    If emptyall( mdate_lech, mdate_schet, mdate_usl )
      fl := func_error( 4, "Обязательно должно быть заполнено хотя бы одно из первых трёх полей даты!" )
    Elseif mvr1 > 0 .and. m1isvr > 0
      fl := func_error( 4, 'Недопустимое сочетание полей "Код врача"!' )
    Elseif mas1 > 0 .and. m1isas > 0
      fl := func_error( 4, 'Недопустимое сочетание полей "Код ассистента"!' )
    Endif
  Endif
  Return fl

//
Function diag2num( ldiagnoz )

  Local i, k, c, s := ""

  ldiagnoz := Upper( AllTrim( ldiagnoz ) )
  For i := 1 To Len( ldiagnoz )
    c := SubStr( ldiagnoz, i, 1 )
    If isletter( c )
      c := lstr( Asc( c ) )
    Endif
    s += c
  Next
  k := Round( Val( s ), 1 )
  If Right( lstr( k, 15, 1 ) ) == "0"
    k := Round( k, 0 )
  Endif

  Return k

//
Function diap_diagn( k1, k2, arr )

  Local fl := .f., i, j := 0, k

  For i := 1 To Len( arr )
    If !Empty( arr[ i ] )
      k := diag2num( arr[ i ] )
      If Between( k, k1, k2 )
        j := i ; Exit
      Endif
    Endif
  Next
  Return j

//
Function f_mn_tal_diag( k, r, c )

  Static mm_prov := { { "не проверяем", 0 }, ;
    { "проверяем   ", 1 }, ;
    { "не введён   ", 2 } }
  Local ret := { 0, Space( 10 ) }, buf, buf24, tmp_color, i

  If r > 12
    r -= 7
  Endif
  buf24 := save_maxrow()
  buf := box_shadow( r + 1, 2, r + 6, 77, color0, 'Талон амбулаторного пациента', "W+/BG" )
  tmp_color := SetColor( "N/BG,W+/N,,,B/BG" )
  Private mprov1  := inieditspr( A__MENUVERT, mm_prov, arr_tal_diag[ 1, 3 ] ), ;
    m1prov1 := arr_tal_diag[ 1, 3 ], ;
    mprov2  := inieditspr( A__MENUVERT, mm_prov, arr_tal_diag[ 2, 3 ] ), ;
    m1prov2 := arr_tal_diag[ 2, 3 ]
  @ r + 3, 5 Say "Характер заболевания       " Get mprov1 ;
    reader {| x| menu_reader( x, mm_prov, A__MENUVERT,,, .f. ) }
  @ Row(), Col() Say " :" Get arr_tal_diag[ 1, 1 ] Pict "9" When m1prov1 == 1
  @ Row(), Col() Say " [по " Get arr_tal_diag[ 1, 2 ] Pict "9" When m1prov1 == 1
  @ Row(), Col() Say "]"
  @ r + 4, 5 Say "Диспансерный учет          " Get mprov2 ;
    reader {| x| menu_reader( x, mm_prov, A__MENUVERT,,, .f. ) }
  @ Row(), Col() Say " :" Get arr_tal_diag[ 2, 1 ] Pict "9" When m1prov2 == 1
  @ Row(), Col() Say " [по " Get arr_tal_diag[ 2, 2 ] Pict "9" When m1prov2 == 1
  @ Row(), Col() Say "]"
  status_key( "^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода" )
  myread()
  arr_tal_diag[ 1, 3 ] := m1prov1
  arr_tal_diag[ 2, 3 ] := m1prov2
  For i := 1 To 2
    If arr_tal_diag[ i, 3 ] != 1
      arr_tal_diag[ i, 1 ] := arr_tal_diag[ i, 2 ] := 0
    Endif
    If arr_tal_diag[ i, 1 ] > 0 .and. Empty( arr_tal_diag[ i, 2 ] )
      arr_tal_diag[ i, 2 ] := arr_tal_diag[ i, 1 ]
    Endif
    If !Empty( arr_tal_diag[ i, 1 ] ) .or. arr_tal_diag[ i, 3 ] == 2
      ret := { 1, "есть" }
    Endif
  Next
  rest_box( buf )
  rest_box( buf24 )
  SetColor( tmp_color )
  Return ret

// 14.05.24
Function ret_date_reg_otch_period()

  Static si := 1, sdate, sdate1
  Local i, ldate, fl := .f.
  Local r1, c1, r2, c2, blk

  If glob_mo[ _MO_KOD_TFOMS ] == '805965' // РДЛ
    If ( i := popup_prompt( T_ROW, T_COL - 5, si, ;
        { "По ~всем счетам", "По счетам, за~регистрированным до...", "По счетам, за промежуток дат" } ) ) == 0
      Return fl
    Endif
  Else
    If ( i := popup_prompt( T_ROW, T_COL - 5, si, ;
        { "По ~всем счетам", "По счетам, за~регистрированным до..." } ) ) == 0
      Return fl
    Endif
  Endif
  If ( si := i ) == 1
    fl := .t.
  Elseif ( si := i ) == 2
    Default sdate To sys_date
    If ( ldate := input_value( 20, 2, 22, 77, color0, ;
        "Введите дату, по которую включительно зарегистрированы счета", sdate ) ) != NIL
      fl := .t.
      mdate_reg := sdate := ldate
    Endif
  Else
    Default sdate To sys_date
    Default sdate1 To sys_date
    Store 0 To r1, c1, r2, c2
    blk := {| x, y| if( x > y, func_error( 4, 'Начальная дата больше конечной!' ), .t. ) }
    get_row_col_max( 18, 0, @r1, @c1, @r2, @c2 )
    km := input_diapazon( r1, c1, r2, c2, cDataCGet, ;
      { 'Введите начальную', 'и конечную', 'даты регистрации счетов' }, ;
      { sdate1, sdate },, blk )
    If km == NIL
      fl := .f.
    Else
      sdate1 := km[ 1 ] ; sdate := km[ 2 ]
      // sy := ret_year := Year( sdate )
      begin_date := dtoc4( sdate1 ) ; end_date := dtoc4( sdate )
      fl := .t.
      mdate_reg_begin := sdate1
      mdate_reg := sdate
    Endif
  Endif
  Return fl

// 11.10.18
Function prikaz_848_miac()

  Static mm_poisk := { { "По дате врачебного приёма", 0 }, ;
    { "По дате окончания лечения", 1 } }
  Static mm_dolpro := { { "По специальности", 0 }, ;
    { "По профилю      ", 1 } }
  Static mm_mest := { { "Все пациенты     ", 0 }, ;
    { "Волгоград+область", 1 }, ;
    { "иногородние      ", 2 } }
  Static sdate11, sdate12, s1mest1 := 0, s1poisk := 0, s1dolpro := 1, s1usl := 0
  Local buf := SaveScreen(), r := 15

  Default sdate11 To BoY( BoQ() -1 ), ;
    sdate12 To BoQ() -1
  Private mdate11 := sdate11, ;
    mdate12 := sdate12, ;
    mpoisk, m1poisk := s1poisk, ;
    mmest1, m1mest1 := s1mest1, ;
    mdolpro, m1dolpro := s1dolpro, ;
    musl, m1usl := s1usl
  mpoisk := inieditspr( A__MENUVERT, mm_poisk, m1poisk )
  mmest1 := inieditspr( A__MENUVERT, mm_mest, m1mest1 )
  mdolpro := inieditspr( A__MENUVERT, mm_dolpro, m1dolpro )
  musl   := inieditspr( A__MENUVERT, mm_danet, m1usl  )
  SetColor( cDataCGet )
  myclear( r )
  Private gl_area := { r, 0, MaxRow() -1, MaxCol(), 0 }
  status_key( "^<Esc>^ - выход;  ^<PgDn>^ - составление документа" )
  //
  @ r, 0 To r + 8, MaxCol() Color color8
  str_center( r, " Подготовка информации во исполнение приказа №848 ", color14 )
  @ r + 2, 2 Say "Начало отчётного периода" Get mdate11
  @ r + 3, 2 Say "Окончание отчётного периода" Get mdate12
  // @ r+4,2 say "Как подсчитывать врачебные приёмы" get mpoisk ;
  // reader {|x|menu_reader(x,mm_poisk,A__MENUVERT,,,.f.)}
  @ r + 4, 2 Say "Как считать пациентов" Get mmest1 ;
    reader {| x| menu_reader( x, mm_mest, A__MENUVERT,,, .f. ) }
  @ r + 5, 2 Say "Как отображать врачебные приёмы" Get mdolpro ;
    reader {| x| menu_reader( x, mm_dolpro, A__MENUVERT,,, .f. ) }
  @ r + 6, 2 Say "Выводить список услуг" Get musl ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }
  myread()
  If LastKey() != K_ESC
    If mdate11 > mdate12
      func_error( 4, "Начальная дата больше конечной даты периода" )
    Elseif Year( mdate11 ) < 2018
      func_error( 4, "Данный режим переписан для 2018 года" )
    Else
      sdate11  := mdate11
      sdate12  := mdate12
      s1mest1  := m1mest1
      s1poisk  := m1poisk
      s1dolpro := m1dolpro
      s1usl    := m1usl
      f1_prikaz_848_miac()
    Endif
  Endif
  RestScreen( buf )
  Return Nil

// 06.11.22
Function f1_prikaz_848_miac()

  Local tfoms_pz[ 11 ], rec, vid_vp, vid1vp, lshifr1, _what_if := _init_if(), d2_year, ss[ 20 ]

  mywait()
  adbf := { { "nn", "N", 1, 0 }, ;       // 0-основная,1-старики
  { "ist_fin", "N", 1, 0 }, ;  // 1-ОМС,2-бюджет,3-платные,4-ДМС,5-расчеты с МО
  { "tip", "N", 1, 0 }, ;      // 1-стационар,2-АПУ,3,4,5-дн.стационар
  { "spec", "N", 9, 0 }, ;     // профиль или специальность
  { "u_kod", "N", 5, 0 }, ;    // с плюсом - ТФОМС, с минусом - ФФОМС
  { "p1", "N", 10, 0 }, ;      //
  { "p2", "N", 10, 0 }, ;      //
  { "p3", "N", 10, 0 }, ;      //
  { "p4", "N", 10, 0 }, ;      //
  { "p5", "N", 10, 0 }, ;      //
  { "p6", "N", 10, 0 }, ;      //
  { "p7", "N", 10, 0 }, ;      //
  { "p8", "N", 10, 0 }, ;       //
  { "p9", "N", 10, 0 }, ;       //
  { "p10", "N", 10, 0 }, ;       //
  { "p11", "N", 10, 0 }, ;       //
  { "p12", "N", 10, 0 }, ;       //
  { "p13", "N", 10, 0 }, ;       //
  { "p14", "N", 10, 0 }, ;       //
  { "p15", "N", 10, 0 }, ;       //
  { "p16", "N", 10, 0 }, ;       //
  { "p17", "N", 10, 0 }, ;       //
  { "p18", "N", 10, 0 }, ;       //
  { "p19", "N", 10, 0 }, ;       //
  { "p20", "N", 10, 0 } }        //
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On Str( nn, 1 ) + Str( ist_fin, 1 ) + Str( tip, 1 ) + Str( spec, 9 ) to ( cur_dir() + "tmp" )
  If m1usl == 1
    dbCreate( cur_dir() + "tmpu", adbf )
    Use ( cur_dir() + "tmpu" ) New Alias TMPU
    Index On Str( nn, 1 ) + Str( ist_fin, 1 ) + Str( tip, 1 ) + Str( spec, 9 ) + Str( u_kod, 5 ) to ( cur_dir() + "tmpu" )
  Endif
  //
  r_use( dir_server() + "mo_su",, "MOSU" )
  r_use( dir_server() + "mo_hu", dir_server() + "mo_hu", "MOHU" )
  Set Relation To u_kod into MOSU
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "human_u_",, "HU_" )
  r_use( dir_server() + "kartote_",, "KART_" )
  r_use( dir_server() + "kartotek",, "KART" )
  Set Relation To RecNo() into KART_
  r_use( dir_server() + "human_u", { dir_server() + "human_u", ;
    dir_server() + "human_ud" }, "HU" )
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To kod_k into KART
  stat_msg( "По дате окончания лечения" )
  old := mdate11 - 1
  dbSeek( DToS( mdate11 ), .t. )
  Do While human->k_data <= mdate12 .and. !Eof()
    If old != human->k_data
      old := human->k_data
      @ MaxRow(), 0 Say date_8( old ) Color "W/R"
    Endif
    fl := ( human_->oplata < 9 )
    If fl .and. m1mest1 > 0
      If Between( human_->smo, '34001', '34007' ) .or. Empty( human_->smo )
        fl := ( m1mest1 == 1 )
      Else
        fl := ( m1mest1 == 2 )
      Endif
    Endif
    If fl
      f2_prikaz_848_miac( 1, _what_if )
    Endif
    Select HUMAN
    Skip
  Enddo
  k := tmp->( LastRec() )
  Close databases
  If k == 0
    Return func_error( 4, "Нет информации" )
  Endif
  name_file := cur_dir() + 'prik_848.txt' ; HH := 42
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
  If m1usl == 1
    r_use( dir_server() + "mo_su",, "MOSU" )
    r_use( dir_server() + "uslugi",, "USL" )
    Use ( cur_dir() + "tmpu" ) index ( cur_dir() + "tmpu" ) new
  Endif
  For _tip := 1 To 5
    arr_title := {}
    arr2 := {}
    Select TMP
    find ( "10" + Str( _tip, 1 ) )
    Do While tmp->nn == 1 .and. tmp->tip == _tip .and. tmp->ist_fin == 0 .and. !Eof()
      If AScan( arr2, {| x| x[ 1 ] == tmp->spec } ) == 0
        If _tip == 2 .and. m1dolpro == 0 .and. tmp->spec < 0
          AAdd( arr2, { tmp->spec, inieditspr( A__MENUVERT, getv015(), Abs( tmp->spec ) ) } )
        Else
          AAdd( arr2, { tmp->spec, inieditspr( A__MENUVERT, ;
            iif( _tip == 2 .and. m1dolpro == 0, getv004(), getv002() ), ;
            tmp->spec ) } )
        Endif
      Endif
      Skip
    Enddo
    For _ist_fin := 1 To 5
      arr := {}
      Select TMP
      find ( "0" + Str( _ist_fin, 1 ) + Str( _tip, 1 ) )
      Do While tmp->nn == 0 .and. tmp->tip == _tip .and. tmp->ist_fin == _ist_fin .and. !Eof()
        If AScan( arr, {| x| x[ 1 ] == tmp->spec } ) == 0
          If _tip == 2 .and. m1dolpro == 0 .and. tmp->spec < 0
            AAdd( arr, { tmp->spec, inieditspr( A__MENUVERT, getv015(), Abs( tmp->spec ) ) } )
          Else
            AAdd( arr, { tmp->spec, inieditspr( A__MENUVERT, ;
              iif( _tip == 2 .and. m1dolpro == 0, getv004(), getv002() ), ;
              tmp->spec ) } )
          Endif
        Endif
        Skip
      Enddo
      If Len( arr ) > 0
        n := 25
        Do Case
        Case _tip == 1
          arr_title := { ;
            "┬─────────────────────────────────┬────────────────────", ;
            "│       число выбывших пациентов  │проведено койко-дней", ;
            "├──────────────────────┬──────────┼──────┬──────┬──────", ;
            "│       взрослые       │   дети   │взрос-│в т.ч.│детьми", ;
            "├─────┬─────┬─────┬────┼─────┬────┤лыми  │старше│      ", ;
            "│всего│старш│умерл│стар│выпи-│умер│      │трудос│      ", ;
            "│выпис│трудо│всего│труд│сано │ло  │      │возрас│      ", ;
            "├─────┼─────┼─────┼────┼─────┼────┼──────┼──────┼──────", ;
            "│  6  │ 6.1 │  7  │ 7.1│  8  │ 9  │  11  │ 11.1 │  12  ", ;
            "┴─────┴─────┴─────┴────┴─────┴────┴──────┴──────┴──────" }
          n := f4_prikaz_848_miac( 40, "Профили коек", arr_title )
        Case _tip == 2
          arr_title := { ;
            "┬─────────────────┬─────────────────────────────┬─────────────────────────────────────────┬───────────", ;
            "│ в АПУ посещений │сделано по поводу заболеваний│     число посещений врачами на дому     │обращ.п/заб", ;
            "├─────┬─────┬─────┼─────┬─────┬─────┬─────┬─────┼─────┬─────┬─────┬─────┬─────┬─────┬─────┼─────┬─────", ;
            "│всего│ село│ дети│ село│взрос│в/раз│дети │д/раз│всего│ село│п/заб│ дети│п/заб│в/раз│д/раз│взрос│дети ", ;
            "├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────", ;
            "│  3  │ 3.1 │  4  │3.1.1│  5  │ 5.1 │  6  │ 6.1 │  7  │ 7.1 │  8  │  9  │ 10  │ 10.1│ 10.2│ 20  │ 21  ", ;
            "┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" }
          n := f4_prikaz_848_miac( 40, "Наименование должностей", arr_title )
        Case eq_any( _tip, 3, 4, 5 )
          arr_title := { ;
            "┬─────────────────┬────────────────────", ;
            "│пролечено больных│    пациенто-дней   ", ;
            "├─────┬───────────┼──────┬─────────────", ;
            "│     │в том числе│      │ в том числе ", ;
            "│всего├─────┬─────┤ всего├──────┬──────", ;
            "│     │взрос│ дети│      │взрос.│ дети ", ;
            "┴─────┴─────┴─────┴──────┴──────┴──────" }
          n := f4_prikaz_848_miac( 40, "Профили коек", arr_title )
        Endcase
        sh := 80
        If tek_stroke > 0
          tek_stroke := HH + 1
          verify_ff( HH, .t., sh )
        Endif
        s := "Приказ №848 - " + ;
          { "Стационар", ;
          "Поликлиника", ;
          "Дневной стационар при стационаре", ;
          "Дневной стационар при поликлинике", ;
          "Дневной стационар на дому" }[ _tip ] + " - " + ;
          { "ОМС", "Бюджет", "Платные", "ДМС", "Расчеты с МО" }[ _ist_fin ]
        add_string( s )
        AFill( ss, 0 )
        AEval( arr_title, {| x| add_string( x ) } )
        ASort( arr,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
        For j := 1 To Len( arr )
          s := PadR( arr[ j, 2 ], n )
          Select TMP
          find ( "0" + Str( _ist_fin, 1 ) + Str( _tip, 1 ) + Str( arr[ j, 1 ], 9 ) )
          If Found()
            Do Case
            Case _tip == 1
              s += put_val( tmp->p1, 6 ) + ;
                put_val( tmp->p2, 6 ) + ;
                put_val( tmp->p3, 6 ) + ;
                put_val( tmp->p4, 5 ) + ;
                put_val( tmp->p5, 6 ) + ;
                put_val( tmp->p6, 5 ) + ;
                put_val( tmp->p7, 7 ) + ;
                put_val( tmp->p8, 7 ) + ;
                put_val( tmp->p9, 7 )
            Case _tip == 2
              s += put_val( tmp->p1 + tmp->p2, 6 ) + ;
                put_val( tmp->p18, 6 ) + ;
                put_val( tmp->p2, 6 ) + ;
                put_val( tmp->p19, 6 ) + ;
                put_val( tmp->p3, 6 ) + ;
                put_val( tmp->p12, 6 ) + ;
                put_val( tmp->p4, 6 ) + ;
                put_val( tmp->p13, 6 ) + ;
                put_val( tmp->p5 + tmp->p6, 6 ) + ;
                put_val( tmp->p20, 6 ) + ;
                put_val( tmp->p7 + tmp->p8, 6 ) + ;
                put_val( tmp->p6, 6 ) + ;
                put_val( tmp->p8, 6 ) + ;
                put_val( tmp->p14, 6 ) + ;
                put_val( tmp->p15, 6 ) + ;
                put_val( tmp->p16, 6 ) + ;
                put_val( tmp->p17, 6 )
            Case eq_any( _tip, 3, 4, 5 )
              s += put_val( tmp->p1 + tmp->p2, 6 ) + ;
                put_val( tmp->p1, 6 ) + ;
                put_val( tmp->p2, 6 ) + ;
                put_val( tmp->p3 + tmp->p4, 7 ) + ;
                put_val( tmp->p3, 7 ) + ;
                put_val( tmp->p4, 7 )
            Endcase
            For iss := 1 To 20
              ss[ iss ] += &( "tmp->p" + lstr( iss ) )
            Next iss
          Endif
          verify_ff( HH, .t., sh )
          add_string( s )
          If m1usl == 1
            arru := {}
            Select TMPU
            find ( "0" + Str( _ist_fin, 1 ) + Str( _tip, 1 ) + Str( arr[ j, 1 ], 9 ) )
            Do While tmpu->nn == 0 .and. tmpu->tip == _tip .and. tmpu->ist_fin == _ist_fin ;
                .and. tmpu->spec == arr[ j, 1 ] .and. !Eof()
              If AScan( arru, {| x| x[ 1 ] == tmpu->u_kod } ) == 0
                If tmpu->u_kod > 0
                  usl->( dbGoto( tmpu->u_kod ) )
                  lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, mdate12 )
                  If Empty( lshifr := lshifr1 )
                    lshifr := usl->shifr
                  Endif
                  If !( lshifr == usl->shifr )
                    lshifr := AllTrim( lshifr ) + "(" + AllTrim( usl->shifr ) + ")"
                  Endif
                  AAdd( arru, { tmpu->u_kod, lshifr, usl->name } )
                Else
                  mosu->( dbGoto( Abs( tmpu->u_kod ) ) )
                  lshifr := AllTrim( mosu->shifr1 )
                  If !Empty( usl->shifr )
                    lshifr += "(" + AllTrim( mosu->shifr ) + ")"
                  Endif
                  AAdd( arru, { tmpu->u_kod, lshifr, mosu->name } )
                Endif
              Endif
              Select TMPU
              Skip
            Enddo
            ASort( arru,,, {| x, y| fsort_usl( x[ 2 ] ) < fsort_usl( y[ 2 ] ) } )
            For ju := 1 To Len( arru )
              s := " " + PadR( AllTrim( arru[ ju, 2 ] ) + " " + AllTrim( arru[ ju, 3 ] ), n - 1 )
              Select TMPU
              find ( "0" + Str( _ist_fin, 1 ) + Str( _tip, 1 ) + Str( arr[ j, 1 ], 9 ) + Str( arru[ ju, 1 ], 5 ) )
              If Found()
                Do Case
                Case _tip == 1
                  s += put_val( tmpu->p1, 6 ) + ;
                    put_val( tmpu->p2, 6 ) + ;
                    put_val( tmpu->p3, 6 ) + ;
                    put_val( tmpu->p4, 5 ) + ;
                    put_val( tmpu->p5, 6 ) + ;
                    put_val( tmpu->p6, 5 ) + ;
                    put_val( tmpu->p7, 7 ) + ;
                    put_val( tmpu->p8, 7 ) + ;
                    put_val( tmpu->p9, 7 )
                Case _tip == 2
                  s += put_val( tmpu->p1 + tmpu->p2, 6 ) + ;
                    put_val( tmpu->p18, 6 ) + ;
                    put_val( tmpu->p2, 6 ) + ;
                    put_val( tmpu->p19, 6 ) + ;
                    put_val( tmpu->p3, 6 ) + ;
                    put_val( tmpu->p12, 6 ) + ;
                    put_val( tmpu->p4, 6 ) + ;
                    put_val( tmpu->p13, 6 ) + ;
                    put_val( tmpu->p5 + tmpu->p6, 6 ) + ;
                    put_val( tmpu->p20, 6 ) + ;
                    put_val( tmpu->p7 + tmpu->p8, 6 ) + ;
                    put_val( tmpu->p6, 6 ) + ;
                    put_val( tmpu->p8, 6 ) + ;
                    put_val( tmpu->p14, 6 ) + ;
                    put_val( tmpu->p15, 6 ) + ;
                    put_val( tmpu->p16, 6 ) + ;
                    put_val( tmpu->p17, 6 )
                Case eq_any( _tip, 3, 4, 5 )
                  s += put_val( tmpu->p1 + tmp->p2, 6 ) + ;
                    put_val( tmpu->p1, 6 ) + ;
                    put_val( tmpu->p2, 6 ) + ;
                    put_val( tmpu->p3 + tmp->p4, 7 ) + ;
                    put_val( tmpu->p3, 7 ) + ;
                    put_val( tmpu->p4, 7 )
                Endcase
              Endif
              verify_ff( HH, .t., sh )
              add_string( s )
            Next ju
          Endif
        Next j
        If m1usl == 0
          s := PadR( "Итого:", n )
          Do Case
          Case _tip == 1
            s += put_val( ss[ 1 ], 6 ) + ;
              put_val( ss[ 2 ], 6 ) + ;
              put_val( ss[ 3 ], 6 ) + ;
              put_val( ss[ 4 ], 5 ) + ;
              put_val( ss[ 5 ], 6 ) + ;
              put_val( ss[ 6 ], 5 ) + ;
              put_val( ss[ 7 ], 7 ) + ;
              put_val( ss[ 8 ], 7 ) + ;
              put_val( ss[ 9 ], 7 )
          Case _tip == 2
            s += put_val( ss[ 1 ] + ss[ 2 ], 6 ) + ;
              put_val( ss[ 18 ], 6 ) + ;
              put_val( ss[ 2 ], 6 ) + ;
              put_val( ss[ 19 ], 6 ) + ;
              put_val( ss[ 3 ], 6 ) + ;
              put_val( ss[ 12 ], 6 ) + ;
              put_val( ss[ 4 ], 6 ) + ;
              put_val( ss[ 13 ], 6 ) + ;
              put_val( ss[ 5 ] + ss[ 6 ], 6 ) + ;
              put_val( ss[ 20 ], 6 ) + ;
              put_val( ss[ 7 ] + ss[ 8 ], 6 ) + ;
              put_val( ss[ 6 ], 6 ) + ;
              put_val( ss[ 8 ], 6 ) + ;
              put_val( ss[ 14 ], 6 ) + ;
              put_val( ss[ 15 ], 6 ) + ;
              put_val( ss[ 16 ], 6 ) + ;
              put_val( ss[ 17 ], 6 )
          Case eq_any( _tip, 3, 4, 5 )
            s += put_val( ss[ 1 ] + ss[ 2 ], 6 ) + ;
              put_val( ss[ 1 ], 6 ) + ;
              put_val( ss[ 2 ], 6 ) + ;
              put_val( ss[ 3 ] + ss[ 4 ], 7 ) + ;
              put_val( ss[ 3 ], 7 ) + ;
              put_val( ss[ 4 ], 7 )
          Endcase
          add_string( Replicate( "-", Len( arr_title[ 1 ] ) ) )
          add_string( s )
        Endif
      Endif
    Next _ist_fin
    If Len( arr2 ) > 0
      Do Case
      Case _tip == 1
        arr_title := { ;
          "┬───────────────────────┬───────────────────────┬───────────────────┬───────────────────────────", ;
          "│       поступило       │       выписано        │      умерло       │    проведено койко-дней   ", ;
          "├───────────┬───────────┼───────────┬───────────┼─────────┬─────────┼─────────────┬─────────────", ;
          "│   город   │    село   │   город   │    село   │  город  │   село  │    город    │     село    ", ;
          "├─────┬─────┼─────┬─────┼─────┬─────┼─────┬─────┼────┬────┼────┬────┼──────┬──────┼──────┬──────", ;
          "│всего│в т.ч│всего│в т.ч│всего│в т.ч│всего│в т.ч│все-│вт.ч│все-│вт.ч│ всего│в т.ч.│ всего│в т.ч.", ;
          "│     │ ОМС │     │ ОМС │     │ ОМС │     │ ОМС │го  │ ОМС│го  │ ОМС│      │ ОМС  │      │ ОМС  ", ;
          "├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼────┼────┼────┼────┼──────┼──────┼──────┼──────", ;
          "│  6  │ 6.1 │  7  │ 7.1 │ 12  │ 12.1│ 13  │ 13.1│ 15 │15.1│ 16 │16.1│  18  │ 18.1 │  19  │ 19.1 ", ;
          "┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴────┴────┴────┴────┴──────┴──────┴──────┴──────" }
        n := f4_prikaz_848_miac( 40, "Профили коек", arr_title )
      Case _tip == 2
        arr_title := { ;
          "┬───────────────────────┬───────────────────────┬───────────", ;
          "│посещений в поликлинике│   посещений на дому   │ патронаж  ", ;
          "├───────────┬───────────┼───────────┬───────────┼─────┬─────", ;
          "│   город   │    село   │   город   │    село   │город│село ", ;
          "├─────┬─────┼─────┬─────┼─────┬─────┼─────┬─────┼─────┼─────", ;
          "│всего│повод│всего│повод│всего│повод│всего│повод│     │     ", ;
          "│     │забол│     │забол│     │забол│     │забол│     │     ", ;
          "├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────", ;
          "│ 4.1 │ 5.1 │ 4.2 │ 5.2 │ 6.1 │ 7.1 │ 6.2 │ 7.2 │8.3.1│8.3.2", ;
          "┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" }
        n := f4_prikaz_848_miac( 40, "Наименования должностей", arr_title )
      Case eq_any( _tip, 3, 4, 5 )
        arr_title := { ;
          "┬───────────────────────┬───────────────────────────", ;
          "│  пролечено больных    │  проведено пациенто-дней  ", ;
          "├───────────┬───────────┼─────────────┬─────────────", ;
          "│   город   │    село   │    город    │     село    ", ;
          "├─────┬─────┼─────┬─────┼──────┬──────┼──────┬──────", ;
          "│всего│в т.ч│всего│в т.ч│ всего│в т.ч.│ всего│в т.ч.", ;
          "│     │ ОМС │     │ ОМС │      │ ОМС  │      │ ОМС  ", ;
          "├─────┼─────┼─────┼─────┼──────┼──────┼──────┼──────", ;
          "│ 10  │10.1 │ 11  │11.1 │  13  │ 13.1 │  14  │ 14.1 ", ;
          "┴─────┴─────┴─────┴─────┴──────┴──────┴──────┴──────" }
        If _tip == 3
          arr_title[ 9 ] := ;
            "│  4  │ 4.1 │  5  │ 5.1 │   7  │  7.1 │   8  │  8.1 "
        Elseif _tip == 5
          arr_title[ 9 ] := ;
            "│     │     │     │     │      │      │      │      "
        Endif
        n := f4_prikaz_848_miac( 40, "Профили коек", arr_title )
      Endcase
      sh := 80
      If tek_stroke > 0
        tek_stroke := HH + 1
        verify_ff( HH, .t., sh )
      Endif
      s := "Приказ №848 - " + ;
        { "Стационар", ;
        "Поликлиника", ;
        "Дневной стационар при стационаре", ;
        "Дневной стационар при поликлинике", ;
        "Дневной стационар на дому" }[ _tip ] + " - СПРАВОЧНО-пожилые"
      AFill( ss, 0 )
      add_string( s )
      AEval( arr_title, {| x| add_string( x ) } )
      ASort( arr2,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
      For j := 1 To Len( arr2 )
        s := PadR( arr2[ j, 2 ], n )
        Select TMP
        find ( "10" + Str( _tip, 1 ) + Str( arr2[ j, 1 ], 9 ) )
        If Found()
          Do Case
          Case _tip == 1
            s += put_val( tmp->p1, 6 ) + ;
              put_val( tmp->p2, 6 ) + ;
              put_val( tmp->p3, 6 ) + ;
              put_val( tmp->p4, 6 ) + ;
              put_val( tmp->p5, 6 ) + ;
              put_val( tmp->p6, 6 ) + ;
              put_val( tmp->p7, 6 ) + ;
              put_val( tmp->p8, 6 ) + ;
              put_val( tmp->p9, 5 ) + ;
              put_val( tmp->p10, 5 ) + ;
              put_val( tmp->p11, 5 ) + ;
              put_val( tmp->p12, 5 ) + ;
              put_val( tmp->p13, 7 ) + ;
              put_val( tmp->p14, 7 ) + ;
              put_val( tmp->p15, 7 ) + ;
              put_val( tmp->p16, 7 )
          Case _tip == 2
            s += put_val( tmp->p1, 6 ) + ;
              put_val( tmp->p2, 6 ) + ;
              put_val( tmp->p3, 6 ) + ;
              put_val( tmp->p4, 6 ) + ;
              put_val( tmp->p5, 6 ) + ;
              put_val( tmp->p6, 6 ) + ;
              put_val( tmp->p7, 6 ) + ;
              put_val( tmp->p8, 6 ) + ;
              put_val( tmp->p9, 6 ) + ;
              put_val( tmp->p10, 6 )
          Case eq_any( _tip, 3, 4, 5 )
            s += put_val( tmp->p1, 6 ) + ;
              put_val( tmp->p2, 6 ) + ;
              put_val( tmp->p3, 6 ) + ;
              put_val( tmp->p4, 6 ) + ;
              put_val( tmp->p13, 7 ) + ;
              put_val( tmp->p14, 7 ) + ;
              put_val( tmp->p15, 7 ) + ;
              put_val( tmp->p16, 7 )
          Endcase
          For iss := 1 To 20
            ss[ iss ] += &( "tmp->p" + lstr( iss ) )
          Next iss
        Endif
        verify_ff( HH, .t., sh )
        add_string( s )
        If m1usl == 1
          arru := {}
          Select TMPU
          find ( "10" + Str( _tip, 1 ) + Str( arr2[ j, 1 ], 9 ) )
          Do While tmpu->nn == 1 .and. tmpu->tip == _tip .and. tmpu->ist_fin == 0 ;
              .and. tmpu->spec == arr2[ j, 1 ] .and. !Eof()
            If AScan( arru, {| x| x[ 1 ] == tmpu->u_kod } ) == 0
              If tmpu->u_kod > 0
                usl->( dbGoto( tmpu->u_kod ) )
                lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, mdate12 )
                If Empty( lshifr := lshifr1 )
                  lshifr := usl->shifr
                Endif
                If !( lshifr == usl->shifr )
                  lshifr := AllTrim( lshifr ) + "(" + AllTrim( usl->shifr ) + ")"
                Endif
                AAdd( arru, { tmpu->u_kod, lshifr, usl->name } )
              Else
                mosu->( dbGoto( Abs( tmpu->u_kod ) ) )
                lshifr := AllTrim( mosu->shifr1 )
                If !Empty( usl->shifr )
                  lshifr += "(" + AllTrim( mosu->shifr ) + ")"
                Endif
                AAdd( arru, { tmpu->u_kod, lshifr, mosu->name } )
              Endif
            Endif
            Select TMPU
            Skip
          Enddo
          ASort( arru,,, {| x, y| fsort_usl( x[ 2 ] ) < fsort_usl( y[ 2 ] ) } )
          For ju := 1 To Len( arru )
            s := " " + PadR( AllTrim( arru[ ju, 2 ] ) + " " + AllTrim( arru[ ju, 3 ] ), n - 1 )
            Select TMPU
            find ( "10" + Str( _tip, 1 ) + Str( arr2[ j, 1 ], 9 ) + Str( arru[ ju, 1 ], 5 ) )
            If Found()
              Do Case
              Case _tip == 1
                s += put_val( tmpu->p1, 6 ) + ;
                  put_val( tmpu->p2, 6 ) + ;
                  put_val( tmpu->p3, 6 ) + ;
                  put_val( tmpu->p4, 6 ) + ;
                  put_val( tmpu->p5, 6 ) + ;
                  put_val( tmpu->p6, 6 ) + ;
                  put_val( tmpu->p7, 6 ) + ;
                  put_val( tmpu->p8, 6 ) + ;
                  put_val( tmpu->p9, 5 ) + ;
                  put_val( tmpu->p10, 5 ) + ;
                  put_val( tmpu->p11, 5 ) + ;
                  put_val( tmpu->p12, 5 ) + ;
                  put_val( tmpu->p13, 7 ) + ;
                  put_val( tmpu->p14, 7 ) + ;
                  put_val( tmpu->p15, 7 ) + ;
                  put_val( tmpu->p16, 7 )
              Case _tip == 2
                s += put_val( tmpu->p1, 6 ) + ;
                  put_val( tmpu->p2, 6 ) + ;
                  put_val( tmpu->p3, 6 ) + ;
                  put_val( tmpu->p4, 6 ) + ;
                  put_val( tmpu->p5, 6 ) + ;
                  put_val( tmpu->p6, 6 ) + ;
                  put_val( tmpu->p7, 6 ) + ;
                  put_val( tmpu->p8, 6 ) + ;
                  put_val( tmpu->p9, 6 ) + ;
                  put_val( tmpu->p10, 6 )
              Case eq_any( _tip, 3, 4, 5 )
                s += put_val( tmpu->p1, 6 ) + ;
                  put_val( tmpu->p2, 6 ) + ;
                  put_val( tmpu->p3, 6 ) + ;
                  put_val( tmpu->p4, 6 ) + ;
                  put_val( tmpu->p13, 7 ) + ;
                  put_val( tmpu->p14, 7 ) + ;
                  put_val( tmpu->p15, 7 ) + ;
                  put_val( tmpu->p16, 7 )
              Endcase
            Endif
            verify_ff( HH, .t., sh )
            add_string( s )
          Next ju
        Endif
      Next j
      If m1usl == 0
        s := PadR( "Итого:", n )
        Do Case
        Case _tip == 1
          s += put_val( ss[ 1 ], 6 ) + ;
            put_val( ss[ 2 ], 6 ) + ;
            put_val( ss[ 3 ], 6 ) + ;
            put_val( ss[ 4 ], 6 ) + ;
            put_val( ss[ 5 ], 6 ) + ;
            put_val( ss[ 6 ], 6 ) + ;
            put_val( ss[ 7 ], 6 ) + ;
            put_val( ss[ 8 ], 6 ) + ;
            put_val( ss[ 9 ], 5 ) + ;
            put_val( ss[ 10 ], 5 ) + ;
            put_val( ss[ 11 ], 5 ) + ;
            put_val( ss[ 12 ], 5 ) + ;
            put_val( ss[ 13 ], 7 ) + ;
            put_val( ss[ 14 ], 7 ) + ;
            put_val( ss[ 15 ], 7 ) + ;
            put_val( ss[ 16 ], 7 )
        Case _tip == 2
          s += put_val( ss[ 1 ], 6 ) + ;
            put_val( ss[ 2 ], 6 ) + ;
            put_val( ss[ 3 ], 6 ) + ;
            put_val( ss[ 4 ], 6 ) + ;
            put_val( ss[ 5 ], 6 ) + ;
            put_val( ss[ 6 ], 6 ) + ;
            put_val( ss[ 7 ], 6 ) + ;
            put_val( ss[ 8 ], 6 ) + ;
            put_val( ss[ 9 ], 6 ) + ;
            put_val( ss[ 10 ], 6 )
        Case eq_any( _tip, 3, 4, 5 )
          s += put_val( ss[ 1 ], 6 ) + ;
            put_val( ss[ 2 ], 6 ) + ;
            put_val( ss[ 3 ], 6 ) + ;
            put_val( ss[ 4 ], 6 ) + ;
            put_val( ss[ 13 ], 7 ) + ;
            put_val( ss[ 14 ], 7 ) + ;
            put_val( ss[ 15 ], 7 ) + ;
            put_val( ss[ 16 ], 7 )
        Endcase
        add_string( Replicate( "-", Len( arr_title[ 1 ] ) ) )
        add_string( s )
      Endif
    Endif
  Next _tip
  FClose( fp )
  Close databases
  Private yes_albom := .t.
  viewtext( name_file,,,, .t.,,, 2 )
  Return Nil

// 28.12.17
Function f2_prikaz_848_miac( par, _what_if )

  Local tfoms_pz[ 20 ], a_usl := {}, i, j, lshifr1, mkol, ;
    _ist_fin := f3_prikaz_848_miac( _what_if ), ;
    is_rebenok := ( human->VZROS_REB > 0 ), d2_year := Year( human->k_data ), ;
    is_trudosp := f_starshe_trudosp( human->POL, human->DATE_R, human->n_data ), ;
    fl_death := is_death( human_->RSLT_NEW ), au_lu := {}, fl_stom := .f., fl_stom_new := .f., ;
    is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog ), is_2_88 := .f., au_flu := {}, ;
    is_patronag := .f., lusl_ok := 0, vid_vp := 0, vid1vp := 0 // по умолчанию профилактика

  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    If f_paraklinika( usl->shifr, lshifr1, human->k_data )
      lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
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
      If eq_any( Left( lshifr, 5 ), "2.80.", "2.82." ) .and. is_2_stomat( lshifr ) == 0 .and. is_2_stomat( lshifr,, .t. ) == 0
        vid_vp := 1 // в неотложной форме или Посещение в приёмном покое
        Exit
      Elseif eq_any( Left( lshifr, 5 ), "2.78.", "2.89." ) .and. is_2_stomat( lshifr ) == 0 .and. is_2_stomat( lshifr,, .t. ) == 0
        vid_vp := 2 // по поводу заболевания
        Exit
      Elseif Left( lshifr, 5 ) == "2.88." .and. is_2_stomat( lshifr ) == 0 .and. is_2_stomat( lshifr,, .t. ) == 0
        vid_vp := 2 // разовое по поводу заболевания
        vid1vp := 1
        Exit
      Elseif between_shifr( AllTrim( lshifr ), "2.79.44", "2.79.50" )
        is_patronag := .t.
      Elseif Left( lshifr, 3 ) == "57." // стоматология
        fl_stom := .t.
      Elseif is_2_stomat( lshifr,, .t. ) > 0
        fl_stom_new := .t.
        Exit
      Endif
    Endif
    Select HU
    Skip
  Enddo
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
    j := 0
    f_vid_p_stom( au_lu, {},,, human->k_data, @j,, @is_2_88, au_flu )
    If is_2_88 // разовое по поводу заболевания
      vid_vp := 2 // по поводу заболевания
      vid1vp := 1
    Elseif j == 1  // с лечебной целью
      vid_vp := 2 // по поводу заболевания
    Elseif j == 3  // при оказании неотложной помощи
      vid_vp := 1 // в неотложной форме
    Endif
    lusl_ok := 2
    is_zabol := ( vid_vp > 0 )
    For i := 1 To Len( au_flu )
      If au_flu[ i, 10 ] == 1 // является врачебным приёмом
        mohu->( dbGoto( au_flu[ i, 9 ] ) )
        is_dom := .f. // на дому
        AAdd( a_usl, { 2, iif( m1dolpro == 0, mohu->PRVS, mohu->PROFIL ), -mohu->u_kod, mohu->kol_1, is_dom } )
      Endif
    Next
  Elseif fl_stom
    j := 0
    f_vid_p_stom( au_lu, {},,, human->k_data, @j,, @is_2_88 )
    If is_2_88 // разовое по поводу заболевания
      vid_vp := 2 // по поводу заболевания
      vid1vp := 1
    Elseif j == 1  // с лечебной целью
      vid_vp := 2 // по поводу заболевания
    Elseif j == 3  // при оказании неотложной помощи
      vid_vp := 1 // в неотложной форме
    Endif
    lusl_ok := 2
    is_zabol := ( vid_vp > 0 )
    For i := 1 To Len( au_lu )
      If au_lu[ i, 10 ] == 1 // является врачебным приёмом
        hu->( dbGoto( au_lu[ i, 9 ] ) )
        is_dom := ( hu->kol_rcp < 0 .and. domuslugatfoms( lshifr ) ) // на дому - по новому
        AAdd( a_usl, { 2, iif( m1dolpro == 0, hu_->PRVS, hu_->PROFIL ), hu->u_kod, hu->kol_1, is_dom } )
      Endif
    Next
  Else
    is_zabol := ( vid_vp > 0 )
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
              is_dom := ( hu->kol_rcp < 0 .and. domuslugatfoms( lshifr ) ) // на дому - по новому
            Elseif eq_any( k, 3, 4, 5 ) // дневной стационар
              ii := k
            Endif
            If ii > 0
              If ii == 1 // стационар
                lusl_ok := 1
                AAdd( a_usl, { ii, hu_->PROFIL, hu->u_kod, mkol, is_dom } )
              Elseif ii == 2 // поликлиника
                lusl_ok := 2
                AAdd( a_usl, { ii, iif( m1dolpro == 0, hu_->PRVS, hu_->PROFIL ), hu->u_kod, mkol, is_dom } )
              Else // дневной стационар
                lusl_ok := 3
                AAdd( a_usl, { ii, hu_->PROFIL, hu->u_kod, mkol, is_dom } )
              Endif
            Endif
          Endif
        Next
      Endif
      Select HU
      Skip
    Enddo
  Endif
  For i := 1 To Len( a_usl )
    Select TMP
    find ( "0" + Str( _ist_fin, 1 ) + Str( a_usl[ i, 1 ], 1 ) + Str( a_usl[ i, 2 ], 9 ) )
    If !Found()
      Append Blank
      tmp->nn      := 0
      tmp->ist_fin := _ist_fin
      tmp->tip     := a_usl[ i, 1 ]
      tmp->spec    := a_usl[ i, 2 ]
    Endif
    Do Case
    Case lusl_ok == 1 // стационар
      If i == 1 // только один раз учтём человека
        If is_rebenok
          If fl_death
            tmp->p6++
          Else
            tmp->p5++
          Endif
        Else
          If fl_death
            tmp->p3++
            If is_trudosp
              tmp->p4++
            Endif
          Else
            tmp->p1++
            If is_trudosp
              tmp->p2++
            Endif
          Endif
        Endif
      Endif
      If is_rebenok
        tmp->p9 += a_usl[ i, 4 ]
      Else
        tmp->p7 += a_usl[ i, 4 ]
        If is_trudosp
          tmp->p8 += a_usl[ i, 4 ]
        Endif
      Endif
    Case lusl_ok == 2 // поликлиника
      If is_selo
        If a_usl[ i, 5 ] // на дому
          tmp->p20 += a_usl[ i, 4 ]
        Else
          tmp->p18 += a_usl[ i, 4 ]
          If is_zabol
            tmp->p19 += a_usl[ i, 4 ]
          Endif
        Endif
      Endif
      If is_rebenok
        If a_usl[ i, 5 ] // на дому
          tmp->p6 += a_usl[ i, 4 ]
          If is_zabol
            tmp->p8 += a_usl[ i, 4 ]
            If vid1vp > 0
              tmp->p15 += a_usl[ i, 4 ]
            Endif
          Endif
        Else
          tmp->p2 += a_usl[ i, 4 ]
          If is_zabol
            tmp->p4 += a_usl[ i, 4 ]
            If vid1vp > 0
              tmp->p13 += a_usl[ i, 4 ]
            Endif
          Endif
        Endif
        If vid1vp == 0 .and. vid_vp == 2 .and. i == 1 // количество обращений за вычетом разовых по поводу заболеваний
          tmp->p17++
        Endif
      Else
        If a_usl[ i, 5 ] // на дому
          tmp->p5 += a_usl[ i, 4 ]
          If is_zabol
            tmp->p7 += a_usl[ i, 4 ]
            If vid1vp > 0
              tmp->p14 += a_usl[ i, 4 ]
            Endif
          Endif
        Else
          tmp->p1 += a_usl[ i, 4 ]
          If is_zabol
            tmp->p3 += a_usl[ i, 4 ]
            If vid1vp > 0
              tmp->p12 += a_usl[ i, 4 ]
            Endif
          Endif
        Endif
        If vid1vp == 0 .and. vid_vp == 2 .and. i == 1 // количество обращений за вычетом разовых по поводу заболеваний
          tmp->p16++
        Endif
      Endif
    Case lusl_ok == 3 // дневной стационар
      If i == 1 // только один раз учтём человека
        If is_rebenok
          tmp->p2++
        Else
          tmp->p1++
        Endif
      Endif
      If is_rebenok
        tmp->p4 += a_usl[ i, 4 ]
      Else
        tmp->p3 += a_usl[ i, 4 ]
      Endif
    Endcase
    If m1usl == 1
      Select TMPU
      find ( "0" + Str( _ist_fin, 1 ) + Str( a_usl[ i, 1 ], 1 ) + Str( a_usl[ i, 2 ], 9 ) + Str( a_usl[ i, 3 ], 5 ) )
      If !Found()
        Append Blank
        tmpu->nn      := 0
        tmpu->ist_fin := _ist_fin
        tmpu->tip     := a_usl[ i, 1 ]
        tmpu->spec    := a_usl[ i, 2 ]
        tmpu->u_kod   := a_usl[ i, 3 ]
      Endif
      Do Case
      Case lusl_ok == 1 // стационар
        If is_rebenok
          tmpu->p9 += a_usl[ i, 4 ]
        Else
          tmpu->p7 += a_usl[ i, 4 ]
          If is_trudosp
            tmpu->p8 += a_usl[ i, 4 ]
          Endif
        Endif
      Case lusl_ok == 2 // поликлиника
        If is_selo
          If a_usl[ i, 5 ] // на дому
            tmpu->p20 += a_usl[ i, 4 ]
          Else
            tmpu->p18 += a_usl[ i, 4 ]
            If is_zabol
              tmpu->p19 += a_usl[ i, 4 ]
            Endif
          Endif
        Endif
        If is_rebenok
          If a_usl[ i, 5 ] // на дому
            tmpu->p6 += a_usl[ i, 4 ]
            If is_zabol
              tmpu->p8 += a_usl[ i, 4 ]
              If vid1vp > 0
                tmpu->p15 += a_usl[ i, 4 ]
              Endif
            Endif
          Else
            tmpu->p2 += a_usl[ i, 4 ]
            If is_zabol
              tmpu->p4 += a_usl[ i, 4 ]
              If vid1vp > 0
                tmpu->p13 += a_usl[ i, 4 ]
              Endif
            Endif
          Endif
        Else
          If a_usl[ i, 5 ] // на дому
            tmpu->p5 += a_usl[ i, 4 ]
            If is_zabol
              tmpu->p7 += a_usl[ i, 4 ]
              If vid1vp > 0
                tmpu->p14 += a_usl[ i, 4 ]
              Endif
            Endif
          Else
            tmpu->p1 += a_usl[ i, 4 ]
            If is_zabol
              tmpu->p3 += a_usl[ i, 4 ]
              If vid1vp > 0
                tmpu->p12 += a_usl[ i, 4 ]
              Endif
            Endif
          Endif
        Endif
      Case lusl_ok == 3 // дневной стационар
        If is_rebenok
          tmpu->p4 += a_usl[ i, 4 ]
        Else
          tmpu->p3 += a_usl[ i, 4 ]
        Endif
      Endcase
    Endif
  Next i
  If is_trudosp // СПРАВОЧНО-пожилые
    For i := 1 To Len( a_usl )
      Select TMP
      find ( "10" + Str( a_usl[ i, 1 ], 1 ) + Str( a_usl[ i, 2 ], 9 ) )
      If !Found()
        Append Blank
        tmp->nn      := 1
        tmp->ist_fin := 0
        tmp->tip     := a_usl[ i, 1 ]
        tmp->spec    := a_usl[ i, 2 ]
      Endif
      Do Case
      Case lusl_ok == 1 // стационар
        If i == 1 // только один раз учтём человека
          If is_selo
            tmp->p3++
            If _ist_fin == 1 // ОМС
              tmp->p4++
            Endif
          Else
            tmp->p1++
            If _ist_fin == 1 // ОМС
              tmp->p2++
            Endif
          Endif
          If fl_death
            If is_selo
              tmp->p11++
              If _ist_fin == 1 // ОМС
                tmp->p12++
              Endif
            Else
              tmp->p9++
              If _ist_fin == 1 // ОМС
                tmp->p10++
              Endif
            Endif
          Else
            If is_selo
              tmp->p7++
              If _ist_fin == 1 // ОМС
                tmp->p8++
              Endif
            Else
              tmp->p5++
              If _ist_fin == 1 // ОМС
                tmp->p6++
              Endif
            Endif
          Endif
        Endif
        If is_selo
          tmp->p15 += a_usl[ i, 4 ]
          If _ist_fin == 1 // ОМС
            tmp->p16 += a_usl[ i, 4 ]
          Endif
        Else
          tmp->p13 += a_usl[ i, 4 ]
          If _ist_fin == 1 // ОМС
            tmp->p14 += a_usl[ i, 4 ]
          Endif
        Endif
      Case lusl_ok == 2 // поликлиника
        If is_selo
          If a_usl[ i, 5 ] // на дому
            tmp->p7 += a_usl[ i, 4 ]
            If is_zabol
              tmp->p8 += a_usl[ i, 4 ]
            Endif
          Else
            tmp->p3 += a_usl[ i, 4 ]
            If is_zabol
              tmp->p4 += a_usl[ i, 4 ]
            Endif
          Endif
        Else
          If a_usl[ i, 5 ] // на дому
            tmp->p5 += a_usl[ i, 4 ]
            If is_zabol
              tmp->p6 += a_usl[ i, 4 ]
            Endif
          Else
            tmp->p1 += a_usl[ i, 4 ]
            If is_zabol
              tmp->p2 += a_usl[ i, 4 ]
            Endif
          Endif
        Endif
        If is_patronag
          If is_selo
            tmp->p10 += a_usl[ i, 4 ]
          Else
            tmp->p9 += a_usl[ i, 4 ]
          Endif
        Endif
      Case lusl_ok == 3 // дневной стационар
        If i == 1 // только один раз учтём человека
          If is_selo
            tmp->p3++
            If _ist_fin == 1 // ОМС
              tmp->p4++
            Endif
          Else
            tmp->p1++
            If _ist_fin == 1 // ОМС
              tmp->p2++
            Endif
          Endif
        Endif
        If is_selo
          tmp->p15 += a_usl[ i, 4 ]
          If _ist_fin == 1 // ОМС
            tmp->p16 += a_usl[ i, 4 ]
          Endif
        Else
          tmp->p13 += a_usl[ i, 4 ]
          If _ist_fin == 1 // ОМС
            tmp->p14 += a_usl[ i, 4 ]
          Endif
        Endif
      Endcase
      If m1usl == 1
        Select TMPU
        find ( "10" + Str( a_usl[ i, 1 ], 1 ) + Str( a_usl[ i, 2 ], 9 ) + Str( a_usl[ i, 3 ], 5 ) )
        If !Found()
          Append Blank
          tmpu->nn      := 1
          tmpu->ist_fin := 0
          tmpu->tip     := a_usl[ i, 1 ]
          tmpu->spec    := a_usl[ i, 2 ]
          tmpu->u_kod   := a_usl[ i, 3 ]
        Endif
        Do Case
        Case lusl_ok == 1 // стационар
          If is_selo
            tmpu->p15 += a_usl[ i, 4 ]
            If _ist_fin == 1 // ОМС
              tmpu->p16 += a_usl[ i, 4 ]
            Endif
          Else
            tmpu->p13 += a_usl[ i, 4 ]
            If _ist_fin == 1 // ОМС
              tmpu->p14 += a_usl[ i, 4 ]
            Endif
          Endif
        Case lusl_ok == 2 // поликлиника
          If is_selo
            If a_usl[ i, 5 ] // на дому
              tmpu->p7 += a_usl[ i, 4 ]
              If is_zabol
                tmpu->p8 += a_usl[ i, 4 ]
              Endif
            Else
              tmpu->p3 += a_usl[ i, 4 ]
              If is_zabol
                tmpu->p4 += a_usl[ i, 4 ]
              Endif
            Endif
          Else
            If a_usl[ i, 5 ] // на дому
              tmpu->p5 += a_usl[ i, 4 ]
              If is_zabol
                tmpu->p6 += a_usl[ i, 4 ]
              Endif
            Else
              tmpu->p1 += a_usl[ i, 4 ]
              If is_zabol
                tmpu->p2 += a_usl[ i, 4 ]
              Endif
            Endif
          Endif
          If is_patronag
            If is_selo
              tmpu->p10 += a_usl[ i, 4 ]
            Else
              tmpu->p9 += a_usl[ i, 4 ]
            Endif
          Endif
        Case lusl_ok == 3 // дневной стационар
          If is_selo
            tmpu->p15 += a_usl[ i, 4 ]
            If _ist_fin == 1 // ОМС
              tmpu->p16 += a_usl[ i, 4 ]
            Endif
          Else
            tmpu->p13 += a_usl[ i, 4 ]
            If _ist_fin == 1 // ОМС
              tmpu->p14 += a_usl[ i, 4 ]
            Endif
          Endif
        Endcase
      Endif
    Next i
  Endif
  Return Nil

// 14.10.15
Function f3_prikaz_848_miac( _what_if )

  Local list_fin := I_FIN_OMS, _ist_fin, i

  If human->komu == 5
    list_fin := I_FIN_PLAT // личный счет = платные услуги
  Elseif eq_any( human->komu, 1, 3 )
    If ( i := AScan( _what_if[ 2 ], {| x| x[ 1 ] == human->komu .and. x[ 2 ] == human->str_crb } ) ) > 0
      list_fin := _what_if[ 2, i, 3 ]
    Endif
  Endif
  // 1-ОМС,2-бюджет,3-платные,4-ДМС,5-расчеты с МО
  If list_fin == I_FIN_OMS
    _ist_fin := 1
  Elseif list_fin == I_FIN_PLAT
    _ist_fin := 3
  Elseif list_fin == I_FIN_DMS
    _ist_fin := 4
  Elseif list_fin == I_FIN_LPU
    _ist_fin := 5
  Else
    _ist_fin := 2
  Endif
  Return _ist_fin

//
Function f4_prikaz_848_miac( n, t, at )

  Local i, j, s, k := Len( at )

  j := Int( k / 2 )
  For i := 1 To k
    If eq_any( i, 1, k )
      s := Replicate( "─", n )
    Elseif i == j
      s := PadC( t, n )
    Else
      s := Space( n )
    Endif
    at[ i ] := s + at[ i ]
  Next
  Return n
