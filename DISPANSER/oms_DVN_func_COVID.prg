#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

#define TERM_X_RAY  365 // срок действительности рентгенографического исследования

// 04.12.21
Function valid_strong_date( get )

  If m1strong == 5
    mDateCOVID := SToD( '  /  /    ' )
  Elseif m1strong == 5 .and. !Empty( mDateCOVID )
    mDateCOVID := sys_date
  Endif

  Return .t.

// 24.01.22
Function valid_date_uslugi_covid( get, metap, beginDate, endDate, lenArr, i )

  If CToD( get:buffer ) > endDate
    get:varput( get:original )
    func_error( 4, "Дата проведения исследования больше даты окончания углубленной диспансеризации" )
    Return .f.
  Endif

  If metap == 1 .and. Upper( get:name ) == 'MDATE5'
    If ( beginDate - CToD( get:buffer ) ) > TERM_X_RAY
      get:varput( get:original )
      func_error( 4, "После рентгенографического исследования прошло больше " + lstr( TERM_X_RAY ) + " дней" )
      Return .f.
    Else
      Return .t.
    Endif
  Endif

  If CToD( get:buffer ) < beginDate
    get:varput( get:original )
    func_error( 4, "Дата проведения исследования меньше даты начала углубленной диспансеризации" )
    Return .f.
  Endif

  If ( metap == 1 .and. Upper( get:name ) == 'MDATE8' ) .or. ( metap == 2 .and. Upper( get:name ) == 'MDATE4' ) // дата приема терапевта
    If CToD( get:buffer ) != endDate
      get:varput( get:original )
      func_error( 4, "Дата проведения осмотра терапевта не равна дате окончания углубленной диспансеризации" )
      Return .f.
    Endif
  Endif

  Return .t.

// 21.08.21
Function condition_when_uslugi_covid( get, metap, mOKSI, m1dyspnea, m1strong )

  Local i := Val( Right( get:name, 1 ) )

  If ( i == 6 )
    If ( metap == 1 ) .and. ( mOKSI >= 95 ) .and. ( m1dyspnea == 1 )
      Return .t.
    Else
      Return .f.
    Endif
  Endif
  If ( i == 7 )
    If ( metap == 1 ) .and. ( m1strong >= 2 )
      Return .t.
    Else
      Return .f.
    Endif
  Endif

  Return .t.

// 14.08.21
Function f_valid_begdata_dvn_covid( get, loc_kod )

  Local i

  If CToD( get:buffer ) < 0d20210701
    get:varput( get:original )
    func_error( 4, "Углубленная диспансеризация после COVID началась с 01 июля 2021 года" )
    Keyboard Chr( K_UP )
    Return .f.
  Endif

  If loc_kod == 0
    For i := 1 To Len( uslugietap_dvn_covid( metap ) ) -iif( metap == 1, 2, 1 )
      // на 1-этапе одна услуга не отображается в списке (70.8.1)
      mvar := "MDATE" + lstr( i )
      &mvar := CToD( get:buffer )
      update_get( mvar )
    Next
  Endif

  Return .t.

// 11.08.21
Function f_valid_enddata_dvn_covid( get, loc_kod )

  If loc_kod == 0
    // на 1-этапе одна услуга не отображается в списке (70.8.1)
    mvar := "MDATE" + lstr( Len( uslugietap_dvn_covid( metap ) ) -iif( metap == 1, 1, 0 ) )
    &mvar := CToD( get:buffer )
    update_get( mvar )
  Endif

  Return .t.

// 20.07.21 рабочая ли услуга (умолчание) ДВН в зависимости от этапа, возраста и пола
Function f_is_umolch_sluch_dvn_covid( i, _etap, _vozrast, _pol )

  Local fl := .f.
  Local j, ta, ar   // := ret_dvn_arr_COVID_umolch()[i]

  If i > Len( ret_dvn_arr_covid_umolch()[ i ] )
    Return fl
  Else
    ar := ret_dvn_arr_covid_umolch()[ i ]
  Endif
  If ValType( ar[ 3 ] ) == "N"
    fl := ( ar[ 3 ] == _etap )
  Else
    fl := AScan( ar[ 3 ], _etap ) > 0
  Endif

  Return fl

// 08.07.24
Function ret_etap_dvn_covid( lkod_h, lkod_k )

  Local ae := { {}, {} }, fl, i, k, d1 := Year( mn_data )

  r_use( dir_server + "human_",, "HUMAN_" )
  r_use( dir_server + "human", dir_server + "humankk", "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  find ( Str( lkod_k, 7 ) )
  Do While human->kod_k == lkod_k .and. !Eof()
    fl := ( lkod_h != human->( RecNo() ) )
    If fl .and. human->schet > 0 .and. human_->oplata == 9
      fl := .f. // лист учёта снят по акту и выставлен повторно
    Endif
    // If fl .and. Between( human->ishod, 401, 402 ) // ???
    If fl .and. is_sluch_dispanser_COVID( human->ishod ) // ???
      i := human->ishod - 400
      If Year( human->n_data ) == d1 // текущий год
        AAdd( ae[ 1 ], { i, human->k_data, human_->RSLT_NEW } )
      Endif
    Endif
    Skip
  Enddo
  Close databases

  Return ae

// 16.02.2020 является ли выходным (праздничным) днём проведения диспансеризации
Function f_is_prazdnik_dvn_covid( _n_data )
  Return !is_work_day( _n_data )

// 20.07.21 вернуть шифр услуги законченного случая для ДВН углубленной COVID
Function ret_shifr_zs_dvn_covid( _etap, _vozrast, _pol, _date )

  Local lshifr := "", fl, is_disp, n := 1

  If _etap == 1
    n := 1
    If is_prazdnik
      n += 700
    Endif
    lshifr := '70.8.1'
  Elseif _etap == 2
  Endif

  Return lshifr


// 16.07.21 вернуть "правильный" профиль для диспансеризации/профилактики
Function ret_profil_dispans_covid( lprofil, lprvs )

  If lprofil == 34 // если профиль по "клинической лабораторной диагностике"
    If ret_old_prvs( lprvs ) == 2013 // и спец-ть "Лабораторное дело"
      lprofil := 37 // сменим на профиль по "лабораторному делу"
    Elseif ret_old_prvs( lprvs ) == 2011 // или "Лабораторная диагностика"
      lprofil := 38 // сменим на профиль по "лабораторной диагностике"
    Endif
  Endif

  Return lprofil

// 05.09.21
Function save_arr_dvn_covid( lkod, mk_data )

  Local arr := {}, i, sk, ta
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect

  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'TPERS' )
  Endif

  If Type( "mfio" ) == "C"
    AAdd( arr, { "mfio", AllTrim( mfio ) } )
  Endif
  If Type( "mdate_r" ) == "D"
    AAdd( arr, { "mdate_r", mdate_r } )
  Endif
  AAdd( arr, { "0", m1mobilbr } )   // "N",мобильная бригада
  AAdd( arr, { "1", mDateCOVID } )     // "D",дата окончания лечения COVID
  AAdd( arr, { "2", mOKSI } )     // "N",оксиметрия
  AAdd( arr, { "3", m1strong } )     // "N",тяжесть течения болезни
  AAdd( arr, { "4", m1dyspnea } )     // "N",одышка
  AAdd( arr, { "5", m1komorbid } )     // "N",комарбидная форма
  For i := 1 To 5
    sk := lstr( i )
    pole_diag := "mdiag" + sk
    pole_1pervich := "m1pervich" + sk
    pole_1stadia := "m1stadia" + sk
    pole_1dispans := "m1dispans" + sk
    pole_1dop := "m1dop" + sk
    pole_1usl := "m1usl" + sk
    pole_1san := "m1san" + sk
    pole_d_diag := "mddiag" + sk
    pole_d_dispans := "mddispans" + sk
    pole_dn_dispans := "mdndispans" + sk
    If !Empty( &pole_diag )
      ta := { &pole_diag, ;
        &pole_1pervich, ;
        &pole_1stadia, ;
        &pole_1dispans }
      If Type( pole_1dop ) == "N" .and. Type( pole_1usl ) == "N" .and. Type( pole_1san ) == "N"
        AAdd( ta, &pole_1dop )
        AAdd( ta, &pole_1usl )
        AAdd( ta, &pole_1san )
      Else
        AAdd( ta, 0 )
        AAdd( ta, 0 )
        AAdd( ta, 0 )
      Endif
      If Type( pole_d_diag ) == "D" .and. Type( pole_d_dispans ) == "D"
        AAdd( ta, &pole_d_diag )
        AAdd( ta, &pole_d_dispans )
      Else
        AAdd( ta, CToD( "" ) )
        AAdd( ta, CToD( "" ) )
      Endif
      If Type( pole_dn_dispans ) == "D"
        AAdd( ta, &pole_dn_dispans )
      Else
        AAdd( ta, CToD( "" ) )
      Endif
      AAdd( arr, { lstr( 10 + i ), ta } )
    Endif
  Next i
  // отказы пациента
  If !Empty( arr_usl_otkaz )
    AAdd( arr, { "19", arr_usl_otkaz } ) // массив
  Endif
  AAdd( arr, { "30", m1GRUPPA } )    // "N1",группа здоровья после дисп-ии
  If Type( "m1prof_ko" ) == "N"
    AAdd( arr, { "31", m1prof_ko } )    // "N1",вид проф.консультирования
  Endif
  // if type("m1ot_nasl1") == "N"
  AAdd( arr, { "40", arr_otklon } ) // массив
  AAdd( arr, { "45", m1dispans } )
  AAdd( arr, { "46", m1nazn_l } )
  If mk_data >= 0d20210801
    If mtab_v_dopo_na != 0
      If TPERS->( dbSeek( Str( mtab_v_dopo_na, 5 ) ) )
        AAdd( arr, { "47", { m1dopo_na, TPERS->kod } } )
      Else
        AAdd( arr, { "47", { m1dopo_na, 0 } } )
      Endif
    Else
      AAdd( arr, { "47", { m1dopo_na, 0 } } )
    Endif
  Else
    AAdd( arr, { "47", m1dopo_na } )
  Endif
  AAdd( arr, { "48", m1ssh_na } )
  AAdd( arr, { "49", m1spec_na } )
  If mk_data >= 0d20210801
    If mtab_v_sanat != 0
      If TPERS->( dbSeek( Str( mtab_v_sanat, 5 ) ) )
        AAdd( arr, { "50", { m1sank_na, TPERS->kod } } )
      Else
        AAdd( arr, { "50", { m1sank_na, 0 } } )
      Endif
    Else
      AAdd( arr, { "50", { m1sank_na, 0 } } )
    Endif
  Else
    AAdd( arr, { "50", m1sank_na } )
  Endif
  // endif
  If Type( "m1p_otk" ) == "N"
    AAdd( arr, { "51", m1p_otk } )
  Endif
  If mk_data >= 0d20210801
    If Type( "m1napr_v_mo" ) == "N"
      If mtab_v_mo != 0
        If TPERS->( dbSeek( Str( mtab_v_mo, 5 ) ) )
          AAdd( arr, { "52", { m1napr_v_mo, TPERS->kod } } )
        Else
          AAdd( arr, { "52", { m1napr_v_mo, 0 } } )
        Endif
      Else
        AAdd( arr, { "52", { m1napr_v_mo, 0 } } )
      Endif
    Endif
  Else
    If Type( "m1napr_v_mo" ) == "N"
      AAdd( arr, { "52", m1napr_v_mo } )
    Endif
  Endif
  If Type( "arr_mo_spec" ) == "A"   // .and. !empty(arr_mo_spec)
    AAdd( arr, { "53", arr_mo_spec } ) // массив
  Endif
  If mk_data >= 0d20210801
    If Type( "m1napr_stac" ) == "N"
      If mtab_v_stac != 0
        If TPERS->( dbSeek( Str( mtab_v_stac, 5 ) ) )
          AAdd( arr, { "54", { m1napr_stac, TPERS->kod } } )
        Else
          AAdd( arr, { "54", { m1napr_stac, 0 } } )
        Endif
      Else
        AAdd( arr, { "54", { m1napr_stac, 0 } } )
      Endif
    Endif
  Else
    If Type( "m1napr_stac" ) == "N"
      AAdd( arr, { "54", m1napr_stac } )
    Endif
  Endif
  If Type( "m1profil_stac" ) == "N"
    AAdd( arr, { "55", m1profil_stac } )
  Endif
  If mk_data >= 0d20210801
    If Type( "m1napr_reab" ) == "N"
      If mtab_v_reab != 0
        If TPERS->( dbSeek( Str( mtab_v_reab, 5 ) ) )
          AAdd( arr, { "56", { m1napr_reab, TPERS->kod } } )
        Else
          AAdd( arr, { "56", { m1napr_reab, 0 } } )
        Endif
      Else
        AAdd( arr, { "56", { m1napr_reab, 0 } } )
      Endif
    Endif
  Else
    If Type( "m1napr_reab" ) == "N"
      AAdd( arr, { "56", m1napr_reab } )
    Endif
  Endif
  If Type( "m1profil_kojki" ) == "N"
    AAdd( arr, { "57", m1profil_kojki } )
  Endif

  If ! aliasIsUse
    TPERS->( dbCloseArea() )
    Select( oldSelect )
  Endif

  save_arr_dispans( lkod, arr )

  Return Nil

// 31.08.21
Function readdatecovid( lkod )

  Local arr, i
  Local dRet := CToD( '  /  /    ' )

  arr := read_arr_dispans( lkod )
  For i := 1 To Len( arr )
    If ValType( arr[ i ] ) == "A" .and. ValType( arr[ i, 1 ] ) == "C"
      If arr[ i, 1 ] == "1" .and. ValType( arr[ i, 2 ] ) == "D"
        mDateCOVID := arr[ i, 2 ]
        dRet := arr[ i, 2 ]
      Endif
      // do case
      // // case arr[i,1] == "0" .and. valtype(arr[i,2]) == "N"
      // //   m1mobilbr := arr[i,2]
      // case arr[i,1] == "1" .and. valtype(arr[i,2]) == "D"
      // mDateCOVID := arr[i,2]
      // endcase
    Endif
  Next

  Return dRet

// 05.09.21
Function read_arr_dvn_covid( lkod, is_all )

  Local arr, i, sk
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect

  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server + 'mo_pers', , 'TPERS' )
  Endif

  Private mvar
  arr := read_arr_dispans( lkod )
  Default is_all To .t.
  For i := 1 To Len( arr )
    If ValType( arr[ i ] ) == "A" .and. ValType( arr[ i, 1 ] ) == "C"
      Do Case
      Case arr[ i, 1 ] == "0" .and. ValType( arr[ i, 2 ] ) == "N"
        m1mobilbr := arr[ i, 2 ]
      Case arr[ i, 1 ] == "1" .and. ValType( arr[ i, 2 ] ) == "D"
        mDateCOVID := arr[ i, 2 ]
      Case arr[ i, 1 ] == "2" .and. ValType( arr[ i, 2 ] ) == "N"
        mOKSI := arr[ i, 2 ]
      Case arr[ i, 1 ] == "3" .and. ValType( arr[ i, 2 ] ) == "N"
        m1strong := arr[ i, 2 ]
      Case arr[ i, 1 ] == "4" .and. ValType( arr[ i, 2 ] ) == "N"
        m1dyspnea := arr[ i, 2 ]
      Case arr[ i, 1 ] == "5" .and. ValType( arr[ i, 2 ] ) == "N"
        m1komorbid := arr[ i, 2 ]
      Case is_all .and. eq_any( arr[ i, 1 ], "11", "12", "13", "14", "15" ) .and. ;
          ValType( arr[ i, 2 ] ) == "A" .and. Len( arr[ i, 2 ] ) >= 7
        sk := Right( arr[ i, 1 ], 1 )
        pole_diag := "mdiag" + sk
        pole_1pervich := "m1pervich" + sk
        pole_1stadia := "m1stadia" + sk
        pole_1dispans := "m1dispans" + sk
        pole_1dop := "m1dop" + sk
        pole_1usl := "m1usl" + sk
        pole_1san := "m1san" + sk
        pole_d_diag := "mddiag" + sk
        pole_d_dispans := "mddispans" + sk
        pole_dn_dispans := "mdndispans" + sk
        If ValType( arr[ i, 2, 1 ] ) == "C"
          &pole_diag := arr[ i, 2, 1 ]
        Endif
        If ValType( arr[ i, 2, 2 ] ) == "N"
          &pole_1pervich := arr[ i, 2, 2 ]
        Endif
        If ValType( arr[ i, 2, 3 ] ) == "N"
          &pole_1stadia := arr[ i, 2, 3 ]
        Endif
        If ValType( arr[ i, 2, 4 ] ) == "N"
          &pole_1dispans := arr[ i, 2, 4 ]
        Endif
        If ValType( arr[ i, 2, 5 ] ) == "N" .and. Type( pole_1dop ) == "N"
          &pole_1dop := arr[ i, 2, 5 ]
        Endif
        If ValType( arr[ i, 2, 6 ] ) == "N" .and. Type( pole_1usl ) == "N"
          &pole_1usl := arr[ i, 2, 6 ]
        Endif
        If ValType( arr[ i, 2, 7 ] ) == "N" .and. Type( pole_1san ) == "N"
          &pole_1san := arr[ i, 2, 7 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 8 .and. ValType( arr[ i, 2, 8 ] ) == "D" .and. Type( pole_d_diag ) == "D"
          &pole_d_diag := arr[ i, 2, 8 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 9 .and. ValType( arr[ i, 2, 9 ] ) == "D" .and. Type( pole_d_dispans ) == "D"
          &pole_d_dispans := arr[ i, 2, 9 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 10 .and. ValType( arr[ i, 2, 10 ] ) == "D" .and. Type( pole_dn_dispans ) == "D"
          &pole_dn_dispans := arr[ i, 2, 10 ]
        Endif
      Case is_all .and. arr[ i, 1 ] == "19" .and. ValType( arr[ i, 2 ] ) == "A"
        arr_usl_otkaz := arr[ i, 2 ]
      Case arr[ i, 1 ] == "30" .and. ValType( arr[ i, 2 ] ) == "N"
        // m1GRUPPA := arr[i,2]
      Case arr[ i, 1 ] == "31" .and. ValType( arr[ i, 2 ] ) == "N"
        m1prof_ko := arr[ i, 2 ]
      Case is_all .and. arr[ i, 1 ] == "40" .and. ValType( arr[ i, 2 ] ) == "A"
        arr_otklon := arr[ i, 2 ]
      Case arr[ i, 1 ] == "45" .and. ValType( arr[ i, 2 ] ) == "N"
        m1dispans  := arr[ i, 2 ]
      Case arr[ i, 1 ] == "46" .and. ValType( arr[ i, 2 ] ) == "N"
        m1nazn_l   := arr[ i, 2 ]
      Case arr[ i, 1 ] == "47"
        If ValType( arr[ i, 2 ] ) == "N"
          m1dopo_na  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == "A"
          m1dopo_na  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_dopo_na := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == "48" .and. ValType( arr[ i, 2 ] ) == "N"
        m1ssh_na   := arr[ i, 2 ]
      Case arr[ i, 1 ] == "49" .and. ValType( arr[ i, 2 ] ) == "N"
        m1spec_na  := arr[ i, 2 ]
      Case arr[ i, 1 ] == "50"
        If ValType( arr[ i, 2 ] ) == "N"
          m1sank_na  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == "A"
          m1sank_na  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_sanat := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == "51" .and. ValType( arr[ i, 2 ] ) == "N"
        m1p_otk  := arr[ i, 2 ]
      Case arr[ i, 1 ] == "52"
        If ValType( arr[ i, 2 ] ) == "N"
          m1napr_v_mo  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == "A"
          m1napr_v_mo  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_mo := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == "53" .and. ValType( arr[ i, 2 ] ) == "A"
        arr_mo_spec := arr[ i, 2 ]
      Case arr[ i, 1 ] == "54"
        If ValType( arr[ i, 2 ] ) == "N"
          m1napr_stac := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == "A"
          m1napr_stac := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_stac := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == "55" .and. ValType( arr[ i, 2 ] ) == "N"
        m1profil_stac := arr[ i, 2 ]
      Case arr[ i, 1 ] == "56"
        If ValType( arr[ i, 2 ] ) == "N"
          m1napr_reab := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == "A"
          m1napr_reab := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_reab := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == "57" .and. ValType( arr[ i, 2 ] ) == "N"
        m1profil_kojki := arr[ i, 2 ]
      Endcase
    Endif
  Next

  If ! aliasIsUse
    TPERS->( dbCloseArea() )
    Select( oldSelect )
  Endif

  Return Nil

// 20.07.21
Function ret_ndisp_covid( lkod_h, lkod_k )   // ,/*@*/new_etap,/*@*/msg)

  Local fl := .t., msg

  msg := ' '

  ar := ret_etap_dvn_covid( lkod_h, lkod_k )
  If ( Len( ar[ 1 ] ) == 0 ) .and. ( lkod_h == 0 )
    metap := 1
  Elseif  ( Len( ar[ 1 ] ) == 1 ) .and. ( lkod_h == 0 )
    If ! eq_any( ar[ 1, 1, 3 ], 352, 353, 357, 358 )
      msg := 'В ' + lstr( Year( mn_data ) ) + ' году проведен I этап углубленной диспансеризации без направления на II этап!'
      hb_Alert( msg )
      fl := .f.
    Endif
    metap := 2
  Endif

  mndisp := inieditspr( A__MENUVERT, mm_ndisp, metap )

  Return fl

// 20.07.21 скорректировать массивы по углубленной диспансеризации COVID
Function ret_arrays_disp_covid()

  Local dvn_COVID_arr_usl

  // 1- наименование меню
  // 2- шифр услуги
  // 3- этап или список допустимых этапов, пример: {1,2}
  // 4 - диагноз (0 или 1) может быть?
  // 5- возможен отказ пациента (0 - нет, 1 - да)
  // 6 - возраст для мужчин (число лет), если 1 - все возраста, если список {} то конкретные значения возраста
  // 7 - возраст для женщин (число лет), если 1 - все возраста, если список {} то конкретные значения возраста

  // 10- V002 - Классификатор прифилей оказанной медицинской помощи
  // 11- V004 - Классификатор медицинских специальностей
  // 12 - признак услуги ТФОМС/ФФОМС 0 - ТФОМСб 1 - ФФОМС
  // 13 - соответствующая услуга ФФОМС услуге ТФОМС
  dvn_COVID_arr_usl := { ; // Услуги на экран для ввода
  { "Пульсооксиметрия", "A12.09.005", 1, 0, 1, 1, 1, ;
    1, 1, 111, { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ;
    1, '';
    }, ;
    { "Проведение спирометрии или спирографии", "A12.09.001", 1, 0, 1, 1, 1, ;
    1, 1, 111, { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ;
    1, '';
    }, ;
    { "Общий (клинический) анализ крови развернутый", "B03.016.003", 1, 0, 1, 1, 1, ;
    1, 1, { 34, 37, 38 }, { 1107, 1301, 1402, 1702, 1801, 2011 }, ;
    1, '';
    }, ;
    { "Анализ крови биохимический общетерапевтический", "B03.016.004", 1, 0, 1, 1, 1, ;
    1, 1, { 34, 37, 38 }, { 1107, 1301, 1402, 1702, 1801, 2011 }, ;
    1, '';
    }, ;
    { "Рентгенография легких", "A06.09.007", 1, 0, 1, 1, 1, ;
    1, 1, 78, { 1118, 1802, 2020 }, ;
    1, '';
    }, ;
    { "Проведение теста с 6 минутной ходьбой", "70.8.2", 1, 0, 1, 1, 1, ;
    1, 1, { 42, 151 }, { 39, 76, 206 }, ;
    0, 'A23.30.023';
    }, ;
    { "Определение концентрации Д-димера в крови", "70.8.3", 1, 0, 1, 1, 1, ;
    1, 1, { 34, 37, 38 }, { 26, 215, 217 }, ;
    0, 'A09.05.051.001';
    }, ;
    { "Проведение Эхокардиографии", "70.8.50", 2, 0, 1, 1, 1, ;
    1, 1, { 106, 111 }, { 81, 89, 226 }, ;
    0, 'A04.10.002';
    }, ;
    { "Проведение КТ легких", "70.8.51", 2, 0, 1, 1, 1, ;
    1, 1, 78, 60, ;
    0, 'A06.09.005';
    }, ;
    { "Дуплексное сканир-ие вен нижних конечностей", "70.8.52", 2, 0, 1, 1, 1, ;
    1, 1, 106, 81, ;
    0, 'A04.12.006.002';
    }, ;
    { "Приём (осмотр) врачом-терапевтом первичный", "B01.026.001", 1, 1, 0, 1, 1, ;
    1, 1, { 42, 151 }, { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ;
    1, '';
    }, ;
    { "Приём (осмотр) врачом-терапевтом повторный", "B01.026.002", 2, 1, 0, 1, 1, ;
    1, 1, { 42, 151 }, { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ;
    1, '';
    }, ;
    { "Комплексное посещение углубленная диспансеризация I этап", "70.8.1", 1, 1, 0, 1, 1, ;
    1, 1, { 42, 151 }, { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ;
    0, '';
    };
    }
  // 1,1,{42,151},{1122,1110,2002},;

  Return dvn_COVID_arr_usl

// 22.07.21 получить услуги этапа диспансеризации COVID
Function uslugietap_dvn_covid( _etap )

  // _etap - этап диспансеризации
  Local retArray := {}
  Local i
  Local usl := ret_arrays_disp_covid()

  For i := 1 To Len( usl )
    If ValType( usl[ i, 3 ] ) == "N"
      fl := ( usl[ i, 3 ] == _etap )
    Else
      fl := AScan( usl[ i, 3 ], _etap ) > 0
    Endif
    If fl
      AAdd( retArray, usl[ i ] )
    Endif
  Next

  Return retArray

//* 26.07.21 получить индекс услуги на этапе диспансеризации COVID
Function indexuslugaetap_dvn_covid( _etap, lshifr )

  // _etap - этап диспансеризации
  // lshifr - шифр услуги
  Local index := 0
  Local i := 0
  Local usl := uslugietap_dvn_covid( _etap )

  For i := 1 To Len( usl )
    If AllTrim( usl[ i, 2 ] ) == AllTrim( lshifr )
      index := i
      Exit
    Endif
  Next

  Return Index

// 20.07.21 рабочая ли услуга по углубленной диспансеризации COVID в зависимости от этапа
Function f_is_usl_oms_sluch_dvn_covid( i, _etap, allUsl, /*@*/_diag, /*@*/_otkaz) // , /*@*/_ekg)

  Local fl := .f.
  Local ars := {}

  // local ar := ret_arrays_disp_COVID()[i]
  Local ar := uslugietap_dvn_covid( _etap )[ i ]

  If ValType( ar[ 2 ] ) == "C" .and. _etap == 1 .and. AllTrim( ar[ 2 ] ) == "70.8.1" .and. ( ! allUsl )
    Return fl
  Endif
  If ValType( ar[ 3 ] ) == "N"
    fl := ( ar[ 3 ] == _etap )
  Else
    fl := AScan( ar[ 3 ], _etap ) > 0
  Endif
  _diag := ( ar[ 4 ] == 1 )
  _otkaz := 0
  If ValType( ar[ 2 ] ) == "C"
    AAdd( ars, ar[ 2 ] )
  Else
    ars := AClone( ar[ 2 ] )
  Endif
  If eq_any( _etap, 1, 2 ) .and. ar[ 5 ] == 1
    _otkaz := 1 // можно ввести отказ
  Endif

  Return fl

// 16.07.21 массив услуг, записываемые всегда по умолчанию по углубленной диспансеризации COVID
Function ret_dvn_arr_covid_umolch()

  Local dvn_COVID_arr_umolch := {}

  // 1- наименование меню
  // 2- шифр услуги
  // 3- этап или список допустимых этапов, пример: {1,2}
  // 4 - диагноз (0 или 1) может быть?
  // 5- возможен отказ пациента (0 - нет, 1 - да)
  // 6 - возраст для мужчин (число лет), если 1 - все возраста, если список {} то конкретные значения возраста
  // 7 - возраст для женщин (число лет), если 1 - все возраста, если список {} то конкретные значения возраста

  // 10- V002 - Классификатор прифилей оказанной медицинской помощи
  // 11- V004 - Классификатор медицинских специальностей

  // count_dvn_arr_usl := len(dvn_COVID_arr_usl)
  // count_dvn_arr_umolch := len(dvn_arr_umolch)

  Return dvn_COVID_arr_umolch

// 21.07.21
Function foundffomsusluga( lshifr )

  Local kod_uslf := 0
  Local tmp_select := Select()

  If Select( "luslf" ) == 0
    use_base( "luslf" )
  Endif
  If Select( "mosu" ) == 0
    use_base( "mo_su" )
  Endif
  Select MOSU
  Set Order To 3 // по шифру ФФОМС
  find ( PadR( lshifr, 20 ) )
  If Found()
    kod_uslf := mosu->kod
  Else
    Select LUSLF
    find ( PadR( lshifr, 20 ) )
    If Found()
      Select MOSU
      Set Order To 1
      find ( Str( -1, 6 ) )
      If Found()
        g_rlock( forever )
      Else
        addrec( 6 )
      Endif
      kod_uslf := mosu->kod := RecNo()
      mosu->name := luslf->name
      mosu->shifr1 := lshifr
      mosu->PROFIL := 0
    Endif
  Endif
  Select ( tmp_select )
  MOSU->( dbCloseArea() )

  close_use_base( 'luslf' )

  Return kod_uslf

// 22.07.21
Function foundffomsuslugabyid( id )

  // id - код услуги
  Local tmp_select := Select()
  Local retArray := {}

  If Select( "mosu" ) == 0
    use_base( "mo_su" )
  Endif
  Select MOSU
  Set Order To 1 // по коду
  find ( Str( id, 6 ) )
  If Found()
    retArray := { MOSU->KOD, MOSU->NAME, MOSU->SHIFR1, MOSU->PROFIL, MOSU->TIP, MOSU->SLUGBA, MOSU->ZF }
  Endif
  Select ( tmp_select )
  MOSU->( dbCloseArea() )

  Return retArray
