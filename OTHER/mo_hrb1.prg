// mo_hrb1.prg - старые функции
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 04.09.13 Журнал регистрации новых больных
Function i_new_boln()
<<<<<<< HEAD
=======

>>>>>>> master
  Local arr_m, fl, ldate, buf := save_maxrow()

  If ( arr_m := year_month() ) != NIL
    mywait()
    //
<<<<<<< HEAD
    dbCreate( cur_dir + "tmp", { { "is", "N", 1, 0 }, ;
=======
    dbCreate( cur_dir() + "tmp", { { "is", "N", 1, 0 }, ;
>>>>>>> master
      { "kod_k", "N", 7, 0 }, ;
      { "task", "N", 1, 0 }, ;
      { "uch", "N", 3, 0 }, ;
      { "otd", "N", 3, 0 }, ;
      { "data", "D", 8, 0 }, ;
      { "KOD_P", "C", 1, 0 } } ) // код пользователя, добавившего л/у
<<<<<<< HEAD
    Use ( cur_dir + "tmp" ) new
    Index On Str( kod_k, 7 ) to ( cur_dir + "tmp" )
    If is_task( X_REGIST )
      waitstatus( "Подзадача РЕГИСТРАТУРА" )
      r_use( dir_server + "mo_regi", dir_server + "mo_regi2", "REGI" )
      // index on pdate to (dir_server+"mo_regi2") progress
=======
    Use ( cur_dir() + "tmp" ) new
    Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp" )
    If is_task( X_REGIST )
      waitstatus( "Подзадача РЕГИСТРАТУРА" )
      r_use( dir_server() + "mo_regi", dir_server() + "mo_regi2", "REGI" )
      // index on pdate to (dir_server()+"mo_regi2") progress
>>>>>>> master
      dbSeek( arr_m[ 7 ], .t. )
      Do While regi->pdate <= arr_m[ 8 ] .and. !Eof()
        updatestatus()
        fl := .f.
        Select TMP
        find ( Str( regi->kod_k, 7 ) )
        If Found()
          If c4tod( regi->pdate ) < tmp->data
            fl := .t.
          Endif
        Else
          Append Blank
          tmp->is := 1
          tmp->kod_k := regi->kod_k
          fl := .t.
        Endif
        If fl
          tmp->task := X_REGIST
          tmp->uch := regi->tip
          tmp->otd := regi->op
          tmp->data := c4tod( regi->pdate )
          tmp->KOD_P := regi->kod_p
        Endif
        Select REGI
        Skip
      Enddo
      regi->( dbCloseArea() )
    Endif
    If is_task( X_PPOKOJ )
      waitstatus( "Подзадача ПРИЁМНЫЙ ПОКОЙ" )
<<<<<<< HEAD
      r_use( dir_server + "mo_pp", dir_server + "mo_pp_d", "PP" )
      // index on dtos(n_data)+n_time to (dir_server+"mo_pp_d") progress
=======
      r_use( dir_server() + "mo_pp", dir_server() + "mo_pp_d", "PP" )
      // index on dtos(n_data)+n_time to (dir_server()+"mo_pp_d") progress
>>>>>>> master
      dbSeek( DToS( arr_m[ 5 ] ), .t. )
      Do While pp->n_data <= arr_m[ 6 ] .and. !Eof()
        updatestatus()
        fl := .f.
        Select TMP
        find ( Str( pp->kod_k, 7 ) )
        If Found()
          If pp->n_data < tmp->data
            fl := .t.
          Endif
        Else
          Append Blank
          tmp->is := 1
          tmp->kod_k := pp->kod_k
          fl := .t.
        Endif
        If fl
          tmp->task := X_PPOKOJ
          tmp->uch := pp->lpu
          tmp->otd := pp->otd
          tmp->data := pp->n_data
          tmp->KOD_P := pp->kod_p
        Endif
        Select PP
        Skip
      Enddo
      pp->( dbCloseArea() )
    Endif
    If is_task( X_PLATN )
      waitstatus( "Подзадача ПЛАТНЫЕ УСЛУГИ" )
<<<<<<< HEAD
      r_use( dir_server + "hum_p", dir_server + "hum_pd", "PLAT" )
      // index on dtos(k_data) to (dir_server+"hum_pd") progress
      dbSeek( DToS( AddMonth( arr_m[ 5 ], -6 ) ), .t. )
      Index On DToS( n_data ) to ( cur_dir + "tmp_plat" ) ;
=======
      r_use( dir_server() + "hum_p", dir_server() + "hum_pd", "PLAT" )
      // index on dtos(k_data) to (dir_server()+"hum_pd") progress
      dbSeek( DToS( AddMonth( arr_m[ 5 ], -6 ) ), .t. )
      Index On DToS( n_data ) to ( cur_dir() + "tmp_plat" ) ;
>>>>>>> master
        For Between( n_data, arr_m[ 5 ], arr_m[ 6 ] ) ;
        While k_data <= arr_m[ 6 ]
      Go Top
      Do While !Eof()
        updatestatus()
        fl := .f.
        Select TMP
        find ( Str( plat->kod_k, 7 ) )
        If Found()
          If plat->n_data < tmp->data
            fl := .t.
          Endif
        Else
          Append Blank
          tmp->is := 1
          tmp->kod_k := plat->kod_k
          fl := .t.
        Endif
        If fl
          tmp->task := X_PLATN
          tmp->uch := plat->lpu
          tmp->otd := plat->otd
          tmp->data := plat->n_data
          tmp->KOD_P := Chr( plat->KOD_OPER )
        Endif
        Select PLAT
        Skip
      Enddo
      plat->( dbCloseArea() )
      If is_task( X_KASSA )
<<<<<<< HEAD
        r_use( dir_server + "kas_pl", dir_server + "kas_pl2", "KP" )
        // index on dtos(k_data) to (dir_server+"kas_pl2") progress
=======
        r_use( dir_server() + "kas_pl", dir_server() + "kas_pl2", "KP" )
        // index on dtos(k_data) to (dir_server()+"kas_pl2") progress
>>>>>>> master
        dbSeek( DToS( arr_m[ 5 ] ), .t. )
        Do While kp->k_data <= arr_m[ 6 ] .and. !Eof()
          updatestatus()
          fl := .f.
          Select TMP
          find ( Str( kp->kod_k, 7 ) )
          If Found()
            If kp->k_data < tmp->data
              fl := .t.
            Endif
          Else
            Append Blank
            tmp->is := 1
            tmp->kod_k := kp->kod_k
            fl := .t.
          Endif
          If fl
            tmp->task := X_KASSA
            tmp->data := kp->k_data
            tmp->KOD_P := Chr( kp->KOD_OPER )
          Endif
          Select KP
          Skip
        Enddo
        kp->( dbCloseArea() )
      Endif
    Endif
    If is_task( X_ORTO )
<<<<<<< HEAD
      r_use( dir_server + "hum_ort", dir_server + "hum_ortd", "ORT" )
      // index on dtos(k_data) to (dir_server+"hum_ortd") progress
      dbSeek( DToS( AddMonth( arr_m[ 5 ], -6 ) ), .t. )
      Index On DToS( n_data ) to ( cur_dir + "tmp_ort" ) ;
=======
      r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "ORT" )
      // index on dtos(k_data) to (dir_server()+"hum_ortd") progress
      dbSeek( DToS( AddMonth( arr_m[ 5 ], -6 ) ), .t. )
      Index On DToS( n_data ) to ( cur_dir() + "tmp_ort" ) ;
>>>>>>> master
        For Between( n_data, arr_m[ 5 ], arr_m[ 6 ] ) ;
        While k_data <= arr_m[ 6 ]
      Go Top
      Do While !Eof()
        updatestatus()
        fl := .f.
        Select TMP
        find ( Str( ort->kod_k, 7 ) )
        If Found()
          If ort->n_data < tmp->data
            fl := .t.
          Endif
        Else
          Append Blank
          tmp->is := 1
          tmp->kod_k := ort->kod_k
          fl := .t.
        Endif
        If fl
          tmp->task := X_ORTO
          tmp->uch := ort->lpu
          tmp->otd := ort->otd
          tmp->data := ort->n_data
        Endif
        Select ORT
        Skip
      Enddo
      ort->( dbCloseArea() )
      If is_task( X_KASSA )
<<<<<<< HEAD
        r_use( dir_server + "kas_ort", dir_server + "kas_ort2", "KP" )
        // index on dtos(k_data) to (dir_server+"kas_ort2") progress
=======
        r_use( dir_server() + "kas_ort", dir_server() + "kas_ort2", "KP" )
        // index on dtos(k_data) to (dir_server()+"kas_ort2") progress
>>>>>>> master
        dbSeek( DToS( arr_m[ 5 ] ), .t. )
        Do While kp->k_data <= arr_m[ 6 ] .and. !Eof()
          updatestatus()
          fl := .f.
          Select TMP
          find ( Str( kp->kod_k, 7 ) )
          If Found()
            If kp->k_data < tmp->data
              fl := .t.
            Endif
          Else
            Append Blank
            tmp->is := 1
            tmp->kod_k := kp->kod_k
            fl := .t.
          Endif
          If fl
            tmp->task := X_KASSA
            tmp->data := kp->k_data
            tmp->KOD_P := Chr( kp->KOD_OPER )
          Endif
          Select KP
          Skip
        Enddo
        kp->( dbCloseArea() )
      Endif
    Endif
    waitstatus( "Подзадача ОМС" )
<<<<<<< HEAD
    r_use( dir_server + "human", dir_server + "humand", "OMS" )
    // index on dtos(k_data)+uch_doc to (dir_server+"humand") progress
    dbSeek( DToS( AddMonth( arr_m[ 5 ], -6 ) ), .t. )
    Index On DToS( n_data ) to ( cur_dir + "tmp_oms" ) ;
=======
    r_use( dir_server() + "human", dir_server() + "humand", "OMS" )
    // index on dtos(k_data)+uch_doc to (dir_server()+"humand") progress
    dbSeek( DToS( AddMonth( arr_m[ 5 ], -6 ) ), .t. )
    Index On DToS( n_data ) to ( cur_dir() + "tmp_oms" ) ;
>>>>>>> master
      For Between( n_data, arr_m[ 5 ], arr_m[ 6 ] ) ;
      While k_data <= arr_m[ 6 ]
    Go Top
    Do While !Eof()
      updatestatus()
      fl := .f.
      Select TMP
      find ( Str( oms->kod_k, 7 ) )
      If Found()
        If oms->n_data <= tmp->data
          fl := .t.
        Endif
      Else
        Append Blank
        tmp->is := 1
        tmp->kod_k := oms->kod_k
        fl := .t.
      Endif
      If fl
        tmp->task := X_OMS
        tmp->uch := oms->lpu
        tmp->otd := oms->otd
        tmp->data := oms->n_data
        tmp->KOD_P := oms->kod_p
      Endif
      Select OMS
      Skip
    Enddo
    Select OMS
<<<<<<< HEAD
    Set Index to ( dir_server + "humankk" )
=======
    Set Index to ( dir_server() + "humankk" )
>>>>>>> master
    Select TMP
    Go Top
    Do While !Eof()
      updatestatus()
      If tmp->is == 1
        Select OMS
        find ( Str( tmp->kod_k, 7 ) )
        Do While oms->kod_k == tmp->kod_k .and. !Eof()
          If oms->n_data < tmp->data
            tmp->is := 0 ; Exit
          Endif
          Select OMS
          Skip
        Enddo
      Endif
      Select TMP
      Skip
    Enddo
    oms->( dbCloseArea() )
    If is_task( X_PPOKOJ )
<<<<<<< HEAD
      r_use( dir_server + "mo_pp", dir_server + "mo_pp_r", "PP" )
=======
      r_use( dir_server() + "mo_pp", dir_server() + "mo_pp_r", "PP" )
>>>>>>> master
      Select TMP
      Go Top
      Do While !Eof()
        updatestatus()
        If tmp->is == 1
          Select PP
          find ( Str( tmp->kod_k, 7 ) )
          Do While pp->kod_k == tmp->kod_k .and. pp->n_data < arr_m[ 6 ] .and. !Eof()
            If pp->n_data < tmp->data
              tmp->is := 0 ; Exit
            Endif
            Select PP
            Skip
          Enddo
        Endif
        Select TMP
        Skip
      Enddo
      pp->( dbCloseArea() )
    Endif
    If is_task( X_PLATN )
<<<<<<< HEAD
      r_use( dir_server + "hum_p", dir_server + "hum_pkk", "PLAT" )
=======
      r_use( dir_server() + "hum_p", dir_server() + "hum_pkk", "PLAT" )
>>>>>>> master
      Select TMP
      Go Top
      Do While !Eof()
        updatestatus()
        If tmp->is == 1
          Select PLAT
          find ( Str( tmp->kod_k, 7 ) )
          Do While plat->kod_k == tmp->kod_k .and. !Eof()
            If plat->n_data < tmp->data
              tmp->is := 0 ; Exit
            Endif
            Select PLAT
            Skip
          Enddo
        Endif
        Select TMP
        Skip
      Enddo
      plat->( dbCloseArea() )
      If is_task( X_KASSA )
<<<<<<< HEAD
        r_use( dir_server + "kas_pl", dir_server + "kas_pl1", "KP" )
=======
        r_use( dir_server() + "kas_pl", dir_server() + "kas_pl1", "KP" )
>>>>>>> master
        Select TMP
        Go Top
        Do While !Eof()
          updatestatus()
          If tmp->is == 1
            Select KP
            find ( Str( tmp->kod_k, 7 ) )
            Do While kp->kod_k == tmp->kod_k .and. !Eof()
              If kp->k_data < tmp->data
                tmp->is := 0 ; Exit
              Endif
              Select KP
              Skip
            Enddo
          Endif
          Select TMP
          Skip
        Enddo
        kp->( dbCloseArea() )
      Endif
    Endif
    If is_task( X_ORTO )
<<<<<<< HEAD
      r_use( dir_server + "hum_ort", dir_server + "hum_ortk", "ORT" )
=======
      r_use( dir_server() + "hum_ort", dir_server() + "hum_ortk", "ORT" )
>>>>>>> master
      Select TMP
      Go Top
      Do While !Eof()
        updatestatus()
        If tmp->is == 1
          Select ORT
          find ( Str( tmp->kod_k, 7 ) )
          Do While ort->kod_k == tmp->kod_k .and. !Eof()
            If ort->n_data < tmp->data
              tmp->is := 0 ; Exit
            Endif
            Select ORT
            Skip
          Enddo
        Endif
        Select TMP
        Skip
      Enddo
      ort->( dbCloseArea() )
      If is_task( X_KASSA )
<<<<<<< HEAD
        r_use( dir_server + "kas_ort", dir_server + "kas_ort1", "KP" )
=======
        r_use( dir_server() + "kas_ort", dir_server() + "kas_ort1", "KP" )
>>>>>>> master
        Select TMP
        Go Top
        Do While !Eof()
          updatestatus()
          If tmp->is == 1
            Select KP
            find ( Str( tmp->kod_k, 7 ) )
            Do While kp->kod_k == tmp->kod_k .and. !Eof()
              If kp->k_data < tmp->data
                tmp->is := 0 ; Exit
              Endif
              Select KP
              Skip
            Enddo
          Endif
          Select TMP
          Skip
        Enddo
        kp->( dbCloseArea() )
      Endif
    Endif
    waitstatus( "Новые пациенты" )
<<<<<<< HEAD
    r_use( dir_server + "kartote2",, "KART2" )
    Index On pc1 to ( cur_dir + "tmpkart2" ) For !Empty( pc1 ) .and. Between( SubStr( pc1, 2, 4 ), arr_m[ 7 ], arr_m[ 8 ] )
=======
    r_use( dir_server() + "kartote2",, "KART2" )
    Index On pc1 to ( cur_dir() + "tmpkart2" ) For !Empty( pc1 ) .and. Between( SubStr( pc1, 2, 4 ), arr_m[ 7 ], arr_m[ 8 ] )
>>>>>>> master
    Go Top
    Do While !Eof()
      updatestatus()
      ldate := c4tod( SubStr( pc1, 2, 4 ) )
      Select TMP
      find ( Str( kart2->( RecNo() ), 7 ) )
      If !Found()
        Append Blank
        tmp->kod_k := kart2->( RecNo() )
        tmp->task := X_REGIST
        tmp->data := ldate
      Endif
      tmp->is := 2
      If ldate <= tmp->data
        tmp->data := ldate
        tmp->uch := 1 // т.е. печатать отделение, если есть
      Endif
      tmp->KOD_P := Left( kart2->pc1, 1 )
      Select KART2
      Skip
    Enddo
    Close databases
    //
    delfrfiles()
    dbCreate( fr_titl, { { "name", "C", 130, 0 }, ;
      { "itog", "N", 6, 0 }, ;
      { "period", "C", 50, 0 } } )
    Use ( fr_titl ) New Alias FRT
    Append Blank
    frt->name := glob_mo[ _MO_SHORT_NAME ]
    frt->period := arr_m[ 4 ]
    dbCreate( fr_data, { { "nomer", "C", 15, 0 }, ;
      { "fio", "C", 60, 0 }, ;
      { "date_r", "D", 8, 0 }, ;
      { "adres", "C", 250, 0 }, ;
      { "oper", "C", 100, 0 } } )
    Use ( fr_data ) New Alias FRD
<<<<<<< HEAD
    r_use( dir_server + "base1",, "BASE1" )
    r_use( dir_server + "kartote_",, "KART_" )
    r_use( dir_server + "kartotek",, "KART" )
    Use ( cur_dir + "tmp" ) new
    Set Relation To kod_k into KART, To kod_k into KART_
    Index On Upper( kart->fio ) to ( cur_dir + "tmp" ) For is > 0
=======
    r_use( dir_server() + "base1",, "BASE1" )
    r_use( dir_server() + "kartote_",, "KART_" )
    r_use( dir_server() + "kartotek",, "KART" )
    Use ( cur_dir() + "tmp" ) new
    Set Relation To kod_k into KART, To kod_k into KART_
    Index On Upper( kart->fio ) to ( cur_dir() + "tmp" ) For is > 0
>>>>>>> master
    Go Top
    Do While !Eof()
      frt->itog++
      s := ""
      If Asc( tmp->kod_p ) > 0
        Select BASE1
        Goto ( Asc( tmp->kod_p ) )
        If !Eof() .and. !Empty( base1->p1 )
<<<<<<< HEAD
          s += AllTrim( Crypt( base1->p1, gpasskod ) ) + eos
=======
          s += AllTrim( Crypt( base1->p1, gpasskod ) ) + hb_eol()
>>>>>>> master
        Endif
      Endif
      If tmp->task == X_REGIST
        If !Empty( tmp->otd )
          If tmp->uch == 1
<<<<<<< HEAD
            s += inieditspr( A__POPUPMENU, dir_server + "mo_otd", tmp->otd )
          Else
            s += inieditspr( A__POPUPMENU, dir_server + "p_priem", tmp->otd )
=======
            s += inieditspr( A__POPUPMENU, dir_server() + "mo_otd", tmp->otd )
          Else
            s += inieditspr( A__POPUPMENU, dir_server() + "p_priem", tmp->otd )
>>>>>>> master
          Endif
        Endif
      Else
        If !Empty( tmp->otd )
<<<<<<< HEAD
          s += inieditspr( A__POPUPMENU, dir_server + "mo_otd", tmp->otd )
          If tmp->task != X_OMS
            s += eos
=======
          s += inieditspr( A__POPUPMENU, dir_server() + "mo_otd", tmp->otd )
          If tmp->task != X_OMS
            s += hb_eol()
>>>>>>> master
          Endif
        Endif
        Do Case
        Case tmp->task == X_PPOKOJ
          s += "(пр/покой)"
        Case tmp->task == X_PLATN
          s += "(пл/услуги)"
        Case tmp->task == X_ORTO
          s += "(ортопедия)"
        Case tmp->task == X_KASSA
          s += "(касса)"
        Endcase
      Endif
      Select FRD
      Append Blank
      frd->nomer := amb_kartan()
      frd->fio := kart->fio
      frd->date_r := kart->date_r
      frd->adres := iif( emptyall( kart_->okatog, kart->adres ), "", ;
        ret_okato_ulica( kart->adres, kart_->okatog ) )
      frd->oper := s
      Select TMP
      Skip
    Enddo
    Close databases
    rest_box( buf )
    call_fr( "mo_new_b" )
  Endif

  Return Nil

// 13.03.18 Информация о количестве удалённых постоянных зубов с 2005 по 2015 годы
Function i_kol_del_zub()
<<<<<<< HEAD
  Local fl_exit := .f., hGauge

  hGauge := gaugenew(,,, "Информация о количестве удалённых зубов", .t. )
  gaugedisplay( hGauge )
  dbCreate( cur_dir + "tmp", { ;
=======

  Local fl_exit := .f., hGauge

  hGauge := gaugenew(,,, "Информация о количестве удалённых зубов", .t. )
  gaugedisplay( hGauge )
  dbCreate( cur_dir() + "tmp", { ;
>>>>>>> master
    { "god", "N", 4, 0 }, ;
    { "kod_k", "N", 7, 0 }, ;
    { "pol", "C", 1, 0 }, ;
    { "vozr", "N", 2, 0 }, ;
    { "kol", "N", 6, 0 } } )
<<<<<<< HEAD
  Use ( cur_dir + "tmp" ) new
  Index On Str( god, 4 ) + Str( kod_k, 7 ) To tmp memory
  use_base( "lusl" )
  r_use( dir_server + "uslugi",, "USL" )
  r_use( dir_server + "human_u_",, "HU_" )
  r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server + "human_2",, "HUMAN_2" )
  r_use( dir_server + "human_",, "HUMAN_" )
  r_use( dir_server + "human",, "HUMAN" )
=======
  Use ( cur_dir() + "tmp" ) new
  Index On Str( god, 4 ) + Str( kod_k, 7 ) To tmp memory
  use_base( "lusl" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "human_u_",, "HU_" )
  r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server() + "human_2",, "HUMAN_2" )
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human",, "HUMAN" )
>>>>>>> master
  Set Relation To kod into HUMAN_, To kod into HUMAN_2
  Go Top
  Do While !Eof()
    gaugeupdate( hGauge, RecNo() / LastRec() )
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If human->kod > 0 .and. human_->oplata != 9
      lgod := Year( human->k_data )
      If Between( lgod, 2005, 2015 )
        lkol := 0
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If between_shifr( lshifr, "57.3.2", "57.3.8" ) .or. between_shifr( lshifr, "57.8.72", "57.8.78" )
              lkol += hu->kol_1
            Endif
          Endif
          Select HU
          Skip
        Enddo
        If lkol > 0
          Select TMP
          find ( Str( lgod, 4 ) + Str( human->kod_k, 7 ) )
          If !Found()
            Append Blank
            tmp->god := lgod
            tmp->kod_k := human->kod_k
            tmp->pol := human->pol
            k := lgod - Year( human->date_r )
            tmp->vozr := iif( k < 100, k, 99 )
          Endif
          tmp->kol += lkol
        Endif
      Endif
    Endif
    Select HUMAN
    If RecNo() % 5000 == 0
      Commit
    Endif
    Skip
  Enddo
  closegauge( hGauge )
  k := tmp->( LastRec() )
  Close databases
  If !fl_exit .and. k > 0
    agod := {}
<<<<<<< HEAD
    Use ( cur_dir + "tmp" ) new
    Index On god To tmp Unique memory
    dbEval( {|| AAdd( agod, tmp->god ) } )
    name_file := "del_zub" + stxt
=======
    Use ( cur_dir() + "tmp" ) new
    Index On god To tmp Unique memory
    dbEval( {|| AAdd( agod, tmp->god ) } )
    name_file := cur_dir() + "del_zub.txt"
>>>>>>> master
    HH := 60
    arr_title := { ;
      "─────────────────┬───────────────┬───────────────┬───────────────", ;
      "                 │   мужчины     │    женщины    │    всего      ", ;
      "Возрастной период├───────┬───────┼───────┬───────┼───────┬───────", ;
      "                 │ зубов │человек│ зубов │человек│ зубов │человек", ;
      "─────────────────┴───────┴───────┴───────┴───────┴───────┴───────";
      }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( glob_mo[ _MO_SHORT_NAME ] )
    add_string( "" )
    add_string( Center( "Информация о количестве удалённых постоянных зубов", sh ) )
    AEval( arr_title, {| x| add_string( x ) } )
    arr := Array( 6, 6 )
    Select TMP
    For ig := 1 To Len( agod )
      Index On Str( kod_k, 7 ) To tmp For god == agod[ ig ] memory
      afillall( arr, 0 )
      Go Top
      Do While !Eof()
        If tmp->vozr < 21
          j := 1
        Elseif tmp->vozr < 36
          j := 2
        Elseif tmp->vozr < 61
          j := 3
        Elseif tmp->vozr < 76
          j := 4
        Else
          j := 5
        Endif
        k := iif( tmp->pol == "М", 1, 3 )
        ax := { j, 6 } ; ay1 := { k, 5 } ; ay2 := { k + 1, 6 }
        For ix := 1 To 2
          x := ax[ ix ]
          For iy := 1 To 2
            y := ay1[ iy ]
            arr[ x, y ] += tmp->kol
            y := ay2[ iy ]
            arr[ x, y ] ++
          Next iy
        Next ix
        Select TMP
        Skip
      Enddo
      If verify_ff( HH - 8, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( "" )
      add_string( PadC( "в " + lstr( agod[ ig ] ) + " году", sh, "_" ) )
      For i := 1 To 6
        s := { "до 20 лет", "21-35 лет", "36-60 лет", "61-75 лет", "старше 75 лет", "Итого" }[ i ]
        s := PadC( s, 17 )
        For j := 1 To 6
          s += put_val( arr[ i, j ], 8 )
        Next
        add_string( s )
      Next
    Next
    Close databases
    FClose( fp )
    viewtext( name_file,,,, .t.,,, 1 )
  Endif

  Return Nil

// 09.07.17 Телефонограмма №15 ВО КЗ
Function phonegram_15_kz()
<<<<<<< HEAD
  Local fl_exit := .f., i, j, k, v, koef, msum, ifin, ldate_r, y, m, buf := save_maxrow(), ;
    mkol, mdni, akslp, begin_date := SToD( "20170101" ), end_date := SToD( "20170630" )

=======

  Local fl_exit := .f., i, j, k, v, koef, msum, ifin, ldate_r, y, m, buf := save_maxrow(), ;
    mkol, mdni, akslp, begin_date := SToD( "20170101" ), end_date := SToD( "20170630" )
>>>>>>> master
  Private arr_m := { 2017, 1, 6, "за 1-ое полугодие 2017 года", ;
    begin_date, end_date, dtoc4( begin_date ), dtoc4( end_date ) }

  waitstatus( arr_m[ 4 ] )
<<<<<<< HEAD
  dbCreate( cur_dir + "tmp", { { "nstr", "N", 1, 0 }, ;
=======
  dbCreate( cur_dir() + "tmp", { { "nstr", "N", 1, 0 }, ;
>>>>>>> master
    { "oms", "N", 1, 0 }, ;
    { "mm", "N", 2, 0 }, ;
    { "kol", "N", 6, 0 }, ;
    { "dni", "N", 6, 0 }, ;
    { "sum", "N", 15, 2 }, ;
    { "kslp", "N", 15, 2 } } )
<<<<<<< HEAD
  Use ( cur_dir + "tmp" ) New Alias TMP
  Index On Str( oms, 1 ) + Str( nstr, 1 ) + Str( mm, 2 ) to ( cur_dir + "tmp" )
  r_use( dir_server + "mo_rak",, "RAK" )
  r_use( dir_server + "mo_raks",, "RAKS" )
  Set Relation To akt into RAK
  r_use( dir_server + "mo_raksh",, "RAKSH" )
  Set Relation To kod_raks into RAKS
  Index On Str( kod_h, 7 ) to ( cur_dir + "tmp_raksh" )
  //
  r_use( dir_server + "schet_",, "SCHET_" )
  r_use( dir_server + "schet",, "SCHET" )
  Set Relation To RecNo() into SCHET_
  //
  r_use( dir_server + "uslugi",, "USL" )
  g_use( dir_server + "human_u_",, "HU_" )
  r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
  Set Relation To RecNo() into HU_, To u_kod into USL
  //
  r_use( dir_server + "human_2",, "HUMAN_2" )
  r_use( dir_server + "human_",, "HUMAN_" )
  r_use( dir_server + "human", dir_server + "humand", "HUMAN" )
=======
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On Str( oms, 1 ) + Str( nstr, 1 ) + Str( mm, 2 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "mo_rak",, "RAK" )
  r_use( dir_server() + "mo_raks",, "RAKS" )
  Set Relation To akt into RAK
  r_use( dir_server() + "mo_raksh",, "RAKSH" )
  Set Relation To kod_raks into RAKS
  Index On Str( kod_h, 7 ) to ( cur_dir() + "tmp_raksh" )
  //
  r_use( dir_server() + "schet_",, "SCHET_" )
  r_use( dir_server() + "schet",, "SCHET" )
  Set Relation To RecNo() into SCHET_
  //
  r_use( dir_server() + "uslugi",, "USL" )
  g_use( dir_server() + "human_u_",, "HU_" )
  r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
  Set Relation To RecNo() into HU_, To u_kod into USL
  //
  r_use( dir_server() + "human_2",, "HUMAN_2" )
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
>>>>>>> master
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    @ MaxRow(), 0 Say date_8( human->k_data ) Color "W/R"
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If human_->USL_OK == 1 .and. f_starshe_trudosp( human->POL, human->DATE_R, human->n_data )
      mkol := 1 ; mdni := 0 ; akslp := {} ; fl := .t.
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
        If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
          lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
          If Left( lshifr, 1 ) == '1' .and. !( "." $ lshifr ) // это шифр КСГ (круглосуточный стационар)
            If Int( Val( Right( lshifr, 3 ) ) ) >= 900 // последние три цифры - код КСГ
              fl := .f.
              mkol := 0 // диализ не учитываем количественно
            Endif
            If fl
              akslp := f_cena_kslp( hu->stoim, lshifr, iif( human_->NOVOR == 0, human->date_r, human_->DATE_R2 ), human->n_data, human->k_data )
              If !Empty( akslp )
                fl := .f.
              Endif
            Endif
          Endif
        Endif
        Select HU
        Skip
      Enddo
      If Empty( akslp )
        akslp := { 0, 0 }
      Endif
      ifin := msum := 0 ; koef := 1
      If human->schet > 0 // попал в счет ОМС
        schet->( dbGoto( human->schet ) )
        If ( fl := ( schet_->NREGISTR == 0 ) ) // только зарегистрированные счета
          // по умолчанию оплачен, если даже нет РАКа
          k := 0
          Select RAKSH
          find ( Str( human->kod, 7 ) )
          Do While human->kod == raksh->kod_h .and. !Eof()
            k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
            Skip
          Enddo
          If !Empty( Round( k, 2 ) )
            If round_5( human->cena_1, 2 ) <= round_5( k, 2 ) // полное снятие
              koef := 0
            Else // частичное снятие
              koef := ( human->cena_1 - k ) / human->cena_1
            Endif
          Endif
          If koef > 0
            msum := Round( human->cena_1 * koef, 2 )
            ifin := 1
          Endif
        Endif
      Endif
      ldate_r := human->DATE_R
      If human_->NOVOR > 0
        ldate_r := human_->DATE_R2
      Endif
      count_ymd( ldate_r, human->n_data, @y )
      v := { 1, 0, 0 }
      If y >= 60
        v[ 2 ] := 1
      Endif
      If y >= 75
        v[ 3 ] := 1
      Endif
      m := Month( human->k_data )
      If mkol > 0 .and. ( mdni := human->k_data - human->n_data ) == 0
        mdni := 1
      Endif
      For i := 1 To 3
        If v[ i ] > 0
          Select TMP
          find ( Str( 0, 1 ) + Str( i, 1 ) + Str( m, 2 ) )
          If !Found()
            Append Blank
            tmp->nstr := i
            tmp->oms := 0
            tmp->mm := m
          Endif
          tmp->kol += mkol
          tmp->dni += mdni
          tmp->sum += human->cena_1
          If !Empty( akslp[ 2 ] )
            tmp->kslp += ( human->cena_1 - round_5( human->cena_1 / akslp[ 2 ], 1 ) )
          Endif
        Endif
      Next i
      If ifin == 1 // попал в ОМС
        For i := 1 To 3
          If v[ i ] > 0
            Select TMP
            find ( Str( 1, 1 ) + Str( i, 1 ) + Str( m, 2 ) )
            If !Found()
              Append Blank
              tmp->nstr := i
              tmp->oms := 1
              tmp->mm := m
            Endif
            tmp->kol += mkol
            tmp->dni += mdni
            tmp->sum += msum
            If !Empty( akslp[ 2 ] )
              tmp->kslp += ( msum - round_5( msum / akslp[ 2 ], 1 ) )
            Endif
          Endif
        Next i
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  If !fl_exit
    If tmp->( LastRec() ) > 0
      HH := 80
      arr_title := { ;
        "────────────────┬──────────┬────────────┬────────────┬────────────┬────────────┬────────────┬────────────┬─────────────", ;
        "  Возраст       │ значение │   январь   │   февраль  │    март    │   апрель   │    май     │    июнь    │    ИТОГО    ", ;
        "────────────────┴──────────┴────────────┴────────────┴────────────┴────────────┴────────────┴────────────┴─────────────" }
      sh := Len( arr_title[ 1 ] )
      //
<<<<<<< HEAD
      nfile := "phone_15" + stxt
=======
      nfile := cur_dir() + "phone_15.txt"
>>>>>>> master
      fp := FCreate( nfile ) ; n_list := 1 ; tek_stroke := 0
      add_string( Center( "Статистика оказания стационарной медицинской помощи лицам пожилого возраста", sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      Select TMP
      For ifin := 0 To 1
        add_string( "" )
        add_string( Center( { "Всего пролечено", "ОМС (зарегистрировано в ТФОМС)" }[ ifin + 1 ], sh ) )
        AEval( arr_title, {| x| add_string( x ) } )
        For j := 1 To 3
          s1 := { "мужчины", "", "" }[ j ]
          s2 := { " 60 лет и старше", "60 лет и старше", "75 лет и старше" }[ j ]
          s3 := { "женщины", "", "" }[ j ]
          s4 := { " 55 лет и старше", "", "" }[ j ]
          s1 := PadR( s1, 17 ) + "больных   "
          s2 := PadR( s2, 17 ) + "койко-дней"
          s3 := PadR( s3, 17 ) + "сумма     "
          s4 := PadR( s4, 17 ) + "надб(КСЛП)"
          ss := { 0, 0, 0, 0 }
          For m := 1 To 6
            find ( Str( ifin, 1 ) + Str( j, 1 ) + Str( m, 2 ) )
            If Found()
              s1 += put_val( tmp->kol, 13 )
              s2 += put_val( tmp->dni, 13 )
              s3 += Str( tmp->sum, 13, 1 )
              s4 += Str( tmp->kslp, 13, 1 )
              ss[ 1 ] += tmp->kol
              ss[ 2 ] += tmp->dni
              ss[ 3 ] += tmp->sum
              ss[ 4 ] += tmp->kslp
            Else
              s1 += Space( 13 )
              s2 += Space( 13 )
              s3 += Space( 13 )
              s4 += Space( 13 )
            Endif
          Next m
          s1 += put_val( ss[ 1 ], 14 )
          s2 += put_val( ss[ 2 ], 14 )
          s3 += Str( ss[ 3 ], 14, 1 )
          s4 += Str( ss[ 4 ], 14, 1 )
          add_string( s1 )
          add_string( s2 )
          add_string( s3 )
          add_string( s4 )
          add_string( Replicate( "─", sh ) )
        Next j
      Next ifin
      FClose( fp )
      Close databases
      rest_box( buf )
      viewtext( nfile,,,, .t.,,, 3 )
    Else
      func_error( 4, "Нет информации по стационару за 2017 год!" )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

<<<<<<< HEAD
// * 24.01.23
Function b_25_perinat_2()
  Static si := 1, sk := 1
  Local buf := SaveScreen(), arr_m, i, j, k, _arr_komit := {}, fl_exit := .f.

  If ( arr_m := year_month(,,, 4 ) ) == NIL
    Return Nil
  Endif
  If ( musl_ok := popup_prompt( T_ROW, T_COL - 5, si, { "Стационарное лечение", "Дневной стационар" } ) ) == 0
    Return Nil
  Endif
  si := musl_ok
  If ( mkomp := popup_prompt( T_ROW, T_COL - 5, sk, { "Страховые компании", "Прочие компании", "Комитеты (МО)" } ) ) == 0
    Return Nil
  Endif
  If ( sk := mkomp ) > 1
    n_file := { "", "str_komp", "komitet" }[ sk ]
    If hb_FileExists( dir_server + n_file + sdbf )
      arr := {}
      r_use( dir_server + n_file,, "_B" )
      Go Top
      Do While !Eof()
        If iif( sk == 1, !Between( _b->tfoms, 44, 47 ), .t. )
          AAdd( arr, { AllTrim( _b->name ), _b->kod } )
        Endif
        Skip
      Enddo
      _b->( dbCloseArea() )
      If Len( arr ) > 0
        If ( r := T_ROW - 3 -Len( arr ) ) < 2
          r := 2
        Endif
        If ( a := bit_popup( r, T_COL - 5, arr ) ) != NIL
          For i := 1 To Len( a )
            AAdd( _arr_komit, AClone( a[ i ] ) )
          Next
        Else
          Return func_error( 4, "Нет выбора" )
        Endif
      Else
        Return func_error( 4, "Ошибка" )
      Endif
    Else
      Return func_error( 4, "Не обнаружен файл " + dir_server + n_file + sdbf )
    Endif
  Endif
  waitstatus( arr_m[ 4 ] )
  dbCreate( cur_dir + "tmp", { ;
    { "ID_PAC",  "N", 7, 0 }, ;
    { "ID_SL",   "N", 7, 0 }, ;
    { "VID_MP",  "N", 1, 0 }, ;
    { "OSN_DIAG", "C", 6, 0 }, ;
    { "SOP_DIAG", "C", 50, 0 }, ;
    { "OSL_DIAG", "C", 20, 0 }, ;
    { "DNI",     "N", 3, 0 }, ;
    { "KOD_OTD", "C", 6, 0 }, ;
    { "PROFIL",  "C", 99, 0 }, ;
    { "POL_PAC", "N", 1, 0 }, ;
    { "DATE_ROG", "C", 10, 0 }, ;
    { "DATE_GOS", "C", 10, 0 }, ;
    { "VIDVMP",  "C", 12, 0 }, ; // вид ВМП по справочнику V018
  { "METVMP",  "C", 4, 0 }, ; // метод ВМП по справочнику V019
  { "REANIMAC", "C", 3, 0 }, ;
    { "SEBESTO", "C", 12, 0 }, ;
    { "USLUGI",  "C", 99, 0 } } )
  Use ( cur_dir + "tmp" ) new
  r_use( dir_server + "mo_otd",, "OTD" )
  r_use( dir_server + "mo_su",, "MOSU" )
  g_use( dir_server + "mo_hu", dir_server + "mo_hu", "MOHU" )
  Set Relation To u_kod into MOSU
  use_base( "lusl" )
  r_use( dir_server + "uslugi",, "USL" )
  r_use( dir_server + "human_u_",, "HU_" )
  r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server + "human_2",, "HUMAN_2" )
  r_use( dir_server + "human_",, "HUMAN_" )
  r_use( dir_server + "human", dir_server + "humand", "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    fl := .f.
    Do Case
    Case mkomp == 1
      fl := ( human->komu == 0 .or. !Empty( Val( human_->smo ) ) )
    Case mkomp == 2
      fl := ( human->komu == 1 .and. AScan( _arr_komit, {| x| x[ 2 ] == human->str_crb } ) > 0 )
    Case mkomp == 3
      fl := ( human->komu == 3 .and. AScan( _arr_komit, {| x| x[ 2 ] == human->str_crb } ) > 0 )
    Endcase
    If fl .and. human_->oplata < 9 .and. human_->usl_ok == musl_ok
      is_dializ := .f. ; arr_sl := {}
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
        If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
          lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
          If eq_any( Left( lshifr, 5 ), "1.11.", "55.1." )
            lshifr1 := AllTrim( usl->shifr )
            i := Len( arr_sl )
            If i > 0 .and. hu->otd == arr_sl[ i, 7 ] .and. hu_->profil == arr_sl[ i, 3 ] .and. lshifr1 == arr_sl[ i, 2 ]
              arr_sl[ i, 5 ] := hu_->date_u2
              arr_sl[ i, 6 ] += hu->kol_1
            Else
              AAdd( arr_sl, { lshifr, ;              // 1
              lshifr1, ;             // 2
              hu_->profil, ;         // 3
              hu->date_u, ;          // 4
              hu_->date_u2, ;        // 5
              hu->kol_1, ;           // 6
              hu->otd, ;             // 7
              lshifr } )              // 8 - услуги Минздрава
            Endif
          Elseif !is_dializ
            is_dializ := ( AScan( glob_KSG_dializ, lshifr ) > 0 ) // КСГ с диализом
          Endif
        Endif
        Select HU
        Skip
      Enddo
      If !is_dializ
        mdiagnoz := diag_for_xml(, .t.,,, .t. )
        mdiagnoz2 := ""
        For i := 2 To Len( mdiagnoz )
          If !Empty( mdiagnoz[ i ] )
            mdiagnoz2 += mdiagnoz[ i ] + ";"
          Endif
        Next
        If !Empty( mdiagnoz2 )
          mdiagnoz2 := Left( mdiagnoz2, Len( mdiagnoz2 ) -1 )
        Endif
        mdiagnoz3 := ""
        If !Empty( human_2->OSL1 )
          mdiagnoz3 += AllTrim( human_2->OSL1 ) + ";"
        Endif
        If !Empty( human_2->OSL2 )
          mdiagnoz3 += AllTrim( human_2->OSL2 ) + ";"
        Endif
        If !Empty( human_2->OSL3 )
          mdiagnoz3 += AllTrim( human_2->OSL3 ) + ";"
        Endif
        If !Empty( mdiagnoz3 )
          mdiagnoz3 := Left( mdiagnoz3, Len( mdiagnoz3 ) -1 )
        Endif
        Select MOHU
        find ( Str( human->kod, 7 ) )
        Do While mohu->kod == human->kod .and. !Eof()
          If ( i := AScan( arr_sl, {| x| mohu->DATE_U >= x[ 4 ] .and. mohu->DATE_U2 <= x[ 5 ] } ) ) > 0
            arr_sl[ i, 8 ] += ";" + AllTrim( mosu->shifr1 )
          Endif
          Select MOHU
          Skip
        Enddo
        For i := 1 To Len( arr_sl )
          Select OTD
          Goto ( arr_sl[ i, 7 ] )
          Select TMP
          Append Blank
          tmp->ID_PAC   := human->kod_k
          tmp->ID_SL    := human->kod
          tmp->VID_MP   := iif( human_2->vmp > 0, 1, 0 )
          tmp->OSN_DIAG := mdiagnoz[ 1 ]
          tmp->SOP_DIAG := mdiagnoz2
          tmp->OSL_DIAG := mdiagnoz3
          tmp->DNI      := arr_sl[ i, 6 ]
          If arr_sl[ i, 1 ] == arr_sl[ i, 2 ]
            tmp->KOD_OTD := lstr( arr_sl[ i, 7 ] )
          Else
            tmp->KOD_OTD := arr_sl[ i, 2 ]
          Endif
          tmp->PROFIL   := inieditspr( A__MENUVERT, getv002(), arr_sl[ i, 3 ] )
          tmp->POL_PAC  := iif( iif( human_->NOVOR > 0, human_->pol2, human->pol ) == "М", 1, 0 )
          tmp->DATE_ROG := full_date( iif( human_->NOVOR > 0, human_->date_r2, human->date_r ) )
          tmp->DATE_GOS := full_date( c4tod( arr_sl[ i, 4 ] ) )
          tmp->VIDVMP   := iif( human_2->vmp > 0, human_2->VIDVMP, "" )
          tmp->METVMP   := iif( human_2->vmp > 0, lstr( human_2->METVMP ), "" )
          tmp->REANIMAC := iif( arr_sl[ i, 3 ] == 5, lstr( arr_sl[ i, 6 ] ), "" )
          tmp->USLUGI   := arr_sl[ i, 8 ]
        Next
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  Close databases
  RestScreen( buf )
  If !fl_exit
    n_file := "SVED"
    Copy File ( cur_dir + "tmp" + sdbf ) to ( cur_dir + n_file + sdbf )
    n_message( { "В каталоге " + Upper( cur_dir ), ;
      "создан файл " + Upper( n_file + sdbf ), ;
      "со сведениями о случаях лечения пациентов." },, ;
      cColorStMsg, cColorStMsg,,, cColorSt2Msg )
  Endif

  Return Nil

// 22.06.17
Function forma_792_miac()
  Local fl_exit := .f., arr_f := { "str_komp",, "komitet" }, i, j, k, v, koef, msum, ifin, ;
    acomp := {}, ldate_r, y, m, d, buf := save_maxrow(), ;
    begin_date := SToD( "20160101" ), end_date := SToD( "20161231" )

=======
// 11.09.25
Function b_25_perinat_2()

  Static si := 1, sk := 1
  Local buf := SaveScreen(), arr_m, i, j, k, _arr_komit := {}, fl_exit := .f.

  If ( arr_m := year_month(,,, 4 ) ) == NIL
    Return Nil
  Endif
  If ( musl_ok := popup_prompt( T_ROW, T_COL - 5, si, { "Стационарное лечение", "Дневной стационар" } ) ) == 0
    Return Nil
  Endif
  si := musl_ok
  If ( mkomp := popup_prompt( T_ROW, T_COL - 5, sk, { "Страховые компании", "Прочие компании", "Комитеты (МО)" } ) ) == 0
    Return Nil
  Endif
  If ( sk := mkomp ) > 1
    n_file := { "", "str_komp", "komitet" }[ sk ]
    If hb_FileExists( dir_server() + n_file + sdbf() )
      arr := {}
      r_use( dir_server() + n_file,, "_B" )
      Go Top
      Do While !Eof()
        If iif( sk == 1, !Between( _b->tfoms, 44, 47 ), .t. )
          AAdd( arr, { AllTrim( _b->name ), _b->kod } )
        Endif
        Skip
      Enddo
      _b->( dbCloseArea() )
      If Len( arr ) > 0
        If ( r := T_ROW - 3 -Len( arr ) ) < 2
          r := 2
        Endif
        If ( a := bit_popup( r, T_COL - 5, arr ) ) != NIL
          For i := 1 To Len( a )
            AAdd( _arr_komit, AClone( a[ i ] ) )
          Next
        Else
          Return func_error( 4, "Нет выбора" )
        Endif
      Else
        Return func_error( 4, "Ошибка" )
      Endif
    Else
      Return func_error( 4, "Не обнаружен файл " + dir_server() + n_file + sdbf() )
    Endif
  Endif
  waitstatus( arr_m[ 4 ] )
  dbCreate( cur_dir() + "tmp", { ;
    { "ID_PAC",  "N", 7, 0 }, ;
    { "ID_SL",   "N", 7, 0 }, ;
    { "VID_MP",  "N", 1, 0 }, ;
    { "OSN_DIAG", "C", 6, 0 }, ;
    { "SOP_DIAG", "C", 50, 0 }, ;
    { "OSL_DIAG", "C", 20, 0 }, ;
    { "DNI",     "N", 3, 0 }, ;
    { "KOD_OTD", "C", 6, 0 }, ;
    { "PROFIL",  "C", 99, 0 }, ;
    { "POL_PAC", "N", 1, 0 }, ;
    { "DATE_ROG", "C", 10, 0 }, ;
    { "DATE_GOS", "C", 10, 0 }, ;
    { "VIDVMP",  "C", 12, 0 }, ; // вид ВМП по справочнику V018
  { "METVMP",  "C", 4, 0 }, ; // метод ВМП по справочнику V019
  { "REANIMAC", "C", 3, 0 }, ;
    { "SEBESTO", "C", 12, 0 }, ;
    { "USLUGI",  "C", 99, 0 } } )
  Use ( cur_dir() + "tmp" ) new
  r_use( dir_server() + "mo_otd",, "OTD" )
  r_use( dir_server() + "mo_su",, "MOSU" )
  g_use( dir_server() + "mo_hu", dir_server() + "mo_hu", "MOHU" )
  Set Relation To u_kod into MOSU
  use_base( "lusl" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "human_u_",, "HU_" )
  r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server() + "human_2",, "HUMAN_2" )
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    fl := .f.
    Do Case
    Case mkomp == 1
      fl := ( human->komu == 0 .or. !Empty( Val( human_->smo ) ) )
    Case mkomp == 2
      fl := ( human->komu == 1 .and. AScan( _arr_komit, {| x| x[ 2 ] == human->str_crb } ) > 0 )
    Case mkomp == 3
      fl := ( human->komu == 3 .and. AScan( _arr_komit, {| x| x[ 2 ] == human->str_crb } ) > 0 )
    Endcase
    If fl .and. human_->oplata < 9 .and. human_->usl_ok == musl_ok
      is_dializ := .f. ; arr_sl := {}
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
        If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
          lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
          If eq_any( Left( lshifr, 5 ), "1.11.", "55.1." )
            lshifr1 := AllTrim( usl->shifr )
            i := Len( arr_sl )
            If i > 0 .and. hu->otd == arr_sl[ i, 7 ] .and. hu_->profil == arr_sl[ i, 3 ] .and. lshifr1 == arr_sl[ i, 2 ]
              arr_sl[ i, 5 ] := hu_->date_u2
              arr_sl[ i, 6 ] += hu->kol_1
            Else
              AAdd( arr_sl, { lshifr, ;              // 1
              lshifr1, ;             // 2
              hu_->profil, ;         // 3
              hu->date_u, ;          // 4
              hu_->date_u2, ;        // 5
              hu->kol_1, ;           // 6
              hu->otd, ;             // 7
              lshifr } )              // 8 - услуги Минздрава
            Endif
          Elseif !is_dializ
            is_dializ := ( AScan( glob_KSG_dializ(), lshifr ) > 0 ) // КСГ с диализом
          Endif
        Endif
        Select HU
        Skip
      Enddo
      If !is_dializ
        mdiagnoz := diag_for_xml(, .t.,,, .t. )
        mdiagnoz2 := ""
        For i := 2 To Len( mdiagnoz )
          If !Empty( mdiagnoz[ i ] )
            mdiagnoz2 += mdiagnoz[ i ] + ";"
          Endif
        Next
        If !Empty( mdiagnoz2 )
          mdiagnoz2 := Left( mdiagnoz2, Len( mdiagnoz2 ) -1 )
        Endif
        mdiagnoz3 := ""
        If !Empty( human_2->OSL1 )
          mdiagnoz3 += AllTrim( human_2->OSL1 ) + ";"
        Endif
        If !Empty( human_2->OSL2 )
          mdiagnoz3 += AllTrim( human_2->OSL2 ) + ";"
        Endif
        If !Empty( human_2->OSL3 )
          mdiagnoz3 += AllTrim( human_2->OSL3 ) + ";"
        Endif
        If !Empty( mdiagnoz3 )
          mdiagnoz3 := Left( mdiagnoz3, Len( mdiagnoz3 ) -1 )
        Endif
        Select MOHU
        find ( Str( human->kod, 7 ) )
        Do While mohu->kod == human->kod .and. !Eof()
          If ( i := AScan( arr_sl, {| x| mohu->DATE_U >= x[ 4 ] .and. mohu->DATE_U2 <= x[ 5 ] } ) ) > 0
            arr_sl[ i, 8 ] += ";" + AllTrim( mosu->shifr1 )
          Endif
          Select MOHU
          Skip
        Enddo
        For i := 1 To Len( arr_sl )
          Select OTD
          Goto ( arr_sl[ i, 7 ] )
          Select TMP
          Append Blank
          tmp->ID_PAC   := human->kod_k
          tmp->ID_SL    := human->kod
          tmp->VID_MP   := iif( human_2->vmp > 0, 1, 0 )
          tmp->OSN_DIAG := mdiagnoz[ 1 ]
          tmp->SOP_DIAG := mdiagnoz2
          tmp->OSL_DIAG := mdiagnoz3
          tmp->DNI      := arr_sl[ i, 6 ]
          If arr_sl[ i, 1 ] == arr_sl[ i, 2 ]
            tmp->KOD_OTD := lstr( arr_sl[ i, 7 ] )
          Else
            tmp->KOD_OTD := arr_sl[ i, 2 ]
          Endif
          tmp->PROFIL   := inieditspr( A__MENUVERT, getv002(), arr_sl[ i, 3 ] )
          tmp->POL_PAC  := iif( iif( human_->NOVOR > 0, human_->pol2, human->pol ) == "М", 1, 0 )
          tmp->DATE_ROG := full_date( iif( human_->NOVOR > 0, human_->date_r2, human->date_r ) )
          tmp->DATE_GOS := full_date( c4tod( arr_sl[ i, 4 ] ) )
          tmp->VIDVMP   := iif( human_2->vmp > 0, human_2->VIDVMP, "" )
          tmp->METVMP   := iif( human_2->vmp > 0, lstr( human_2->METVMP ), "" )
          tmp->REANIMAC := iif( arr_sl[ i, 3 ] == 5, lstr( arr_sl[ i, 6 ] ), "" )
          tmp->USLUGI   := arr_sl[ i, 8 ]
        Next
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  Close databases
  RestScreen( buf )
  If !fl_exit
    n_file := "SVED"
    Copy File ( cur_dir() + "tmp" + sdbf() ) to ( cur_dir() + n_file + sdbf() )
    n_message( { "В каталоге " + Upper( cur_dir() ), ;
      "создан файл " + Upper( n_file + sdbf() ), ;
      "со сведениями о случаях лечения пациентов." },, ;
      cColorStMsg, cColorStMsg,,, cColorSt2Msg )
  Endif

  Return Nil

// 22.06.17
Function forma_792_miac()

  Local fl_exit := .f., arr_f := { "str_komp",, "komitet" }, i, j, k, v, koef, msum, ifin, ;
    acomp := {}, ldate_r, y, m, d, buf := save_maxrow(), ;
    begin_date := SToD( "20160101" ), end_date := SToD( "20161231" )
>>>>>>> master
  Private arr_m := { 2016, 1, 12, "за 2016 год", begin_date, end_date, dtoc4( begin_date ), dtoc4( end_date ) }

  waitstatus( arr_m[ 4 ] )
  For i := 1 To 3
<<<<<<< HEAD
    If i != 2 .and. hb_FileExists( dir_server + arr_f[ i ] + sdbf )
      r_use( dir_server + arr_f[ i ],, "_B" )
=======
    If i != 2 .and. hb_FileExists( dir_server() + arr_f[ i ] + sdbf() )
      r_use( dir_server() + arr_f[ i ],, "_B" )
>>>>>>> master
      Go Top
      Do While !Eof()
        If iif( i == 1, !Between( _b->tfoms, 44, 47 ), .t. ) .and. _b->ist_fin == I_FIN_BUD
          AAdd( acomp, { i, _b->kod } ) // список бюджетных компаний
        Endif
        Skip
      Enddo
      Use
    Endif
  Next
<<<<<<< HEAD
  dbCreate( cur_dir + "tmp", { { "nstr", "N", 1, 0 }, ;
=======
  dbCreate( cur_dir() + "tmp", { { "nstr", "N", 1, 0 }, ;
>>>>>>> master
    { "oms", "N", 1, 0 }, ;
    { "profil", "N", 3, 0 }, ;
    { "kol1", "N", 6, 0 }, ;
    { "sum1", "N", 15, 2 }, ;
    { "kol2", "N", 6, 0 }, ;
    { "sum2", "N", 15, 2 }, ;
    { "kol3", "N", 6, 0 }, ;
    { "sum3", "N", 15, 2 }, ;
    { "kol4", "N", 6, 0 }, ;
    { "sum4", "N", 15, 2 }, ;
    { "kol", "N", 6, 0 }, ;
    { "sum", "N", 15, 2 } } )
<<<<<<< HEAD
  Use ( cur_dir + "tmp" ) New Alias TMP
  Index On Str( oms, 1 ) + Str( nstr, 1 ) + Str( profil, 3 ) to ( cur_dir + "tmp" )
  r_use( dir_server + "mo_rak",, "RAK" )
  r_use( dir_server + "mo_raks",, "RAKS" )
  Set Relation To akt into RAK
  r_use( dir_server + "mo_raksh",, "RAKSH" )
  Set Relation To kod_raks into RAKS
  Index On Str( kod_h, 7 ) to ( cur_dir + "tmp_raksh" )
  //
  r_use( dir_server + "schet_",, "SCHET_" )
  r_use( dir_server + "schet",, "SCHET" )
  Set Relation To RecNo() into SCHET_
  //
  r_use( dir_server + "human_2",, "HUMAN_2" )
  r_use( dir_server + "human_",, "HUMAN_" )
  r_use( dir_server + "human", dir_server + "humand", "HUMAN" )
=======
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On Str( oms, 1 ) + Str( nstr, 1 ) + Str( profil, 3 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "mo_rak",, "RAK" )
  r_use( dir_server() + "mo_raks",, "RAKS" )
  Set Relation To akt into RAK
  r_use( dir_server() + "mo_raksh",, "RAKSH" )
  Set Relation To kod_raks into RAKS
  Index On Str( kod_h, 7 ) to ( cur_dir() + "tmp_raksh" )
  //
  r_use( dir_server() + "schet_",, "SCHET_" )
  r_use( dir_server() + "schet",, "SCHET" )
  Set Relation To RecNo() into SCHET_
  //
  r_use( dir_server() + "human_2",, "HUMAN_2" )
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
>>>>>>> master
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    @ MaxRow(), 0 Say date_8( human->k_data ) Color "W/R"
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If human_->USL_OK == 1 .and. ( j := f1forma_792_miac( human->kod_diag ) ) > 0 // стационар
      ifin := msum := 0 ; koef := 1 ; fl := .f.
      If human->schet > 0
        schet->( dbGoto( human->schet ) )
        If ( fl := ( schet_->NREGISTR == 0 ) ) // только зарегистрированные
          // по умолчанию оплачен, если даже нет РАКа
          k := 0
          Select RAKSH
          find ( Str( human->kod, 7 ) )
          Do While human->kod == raksh->kod_h .and. !Eof()
            k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
            Skip
          Enddo
          If !Empty( Round( k, 2 ) )
            If round_5( human->cena_1, 2 ) <= round_5( k, 2 ) // полное снятие
              koef := 0
            Else // частичное снятие
              koef := ( human->cena_1 - k ) / human->cena_1
            Endif
          Endif
          If ( fl := ( koef > 0 ) )
            msum := Round( human->cena_1 * koef, 2 )
            ifin := 1
          Endif
        Endif
      Endif
      If !fl .and. AScan( acomp, {| x| x[ 1 ] == human->komu .and. x[ 2 ] == human->str_crb } ) > 0 // бюджет
        msum := human->cena_1
        ifin := 2
      Endif
      If ifin > 0
        ldate_r := human->DATE_R
        If human_->NOVOR > 0
          ldate_r := human_->DATE_R2
        Endif
        count_ymd( ldate_r, human->n_data, @y, @m, @d )
        If y == 0 .or. ( y == 1 .and. m == 0 .and. d == 0 )
          v := 1
        Elseif y < 17
          v := 2
        Elseif y < 60
          v := 3
        Else
          v := 4
        Endif
        polek := "tmp->kol" + lstr( v )
        poles := "tmp->sum" + lstr( v )
        Select TMP
        find ( Str( ifin, 1 ) + Str( j, 1 ) + Str( 0, 3 ) )
        If !Found()
          Append Blank
          tmp->nstr := j
          tmp->oms := ifin
          tmp->profil := 0
        Endif
        &( polek ) ++
        &( poles ) += msum
        tmp->kol++
        tmp->sum += msum
        Select TMP
        find ( Str( ifin, 1 ) + Str( j, 1 ) + Str( human_->profil, 3 ) )
        If !Found()
          Append Blank
          tmp->nstr := j
          tmp->oms := ifin
          tmp->profil := human_->profil
        Endif
        &( polek ) ++
        &( poles ) += msum
        tmp->kol++
        tmp->sum += msum
        Select TMP
        find ( Str( ifin, 1 ) + Str( 0, 1 ) + Str( human_->profil, 3 ) )
        If !Found()
          Append Blank
          tmp->nstr := 0
          tmp->oms := ifin
          tmp->profil := human_->profil
        Endif
        &( polek ) ++
        &( poles ) += msum
        tmp->kol++
        tmp->sum += msum
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  If !fl_exit
    If tmp->( LastRec() ) > 0
      HH := 80
      arr_title := { ;
        "───────┬───────────────────┬───────────────────┬───────────────────┬───────────────────┬───────────────────", ;
        "       │    до 1 года      │  от 1 г. до 16 лет│   от 17 до 59 лет │ от 60 лет и старше│      всего        ", ;
        "       │───────────────────│───────────────────│───────────────────│───────────────────│───────────────────", ;
        "МКБ-10 │ кол. │   сумма    │ кол. │   сумма    │ кол. │   сумма    │ кол. │   сумма    │ кол. │   сумма    ", ;
        "───────┴──────┴────────────┴──────┴────────────┴──────┴────────────┴──────┴────────────┴──────┴────────────" }
      sh := Len( arr_title[ 1 ] )
      //
<<<<<<< HEAD
      nfile := "pr_792" + stxt
=======
      nfile := cur_dir() + "pr_792.txt"
>>>>>>> master
      fp := FCreate( nfile ) ; n_list := 1 ; tek_stroke := 0
      add_string( Center( "Фактические показатели объёма и финансового обеспечения специализированной медицинской помощи, оказанной в", sh ) )
      add_string( Center( "стационарных условиях, по отдельным профилям медицинской помощи за 2016 год (в тыс.руб.)", sh ) )
      For ifin := 1 To 2
        Select TMP
        find ( Str( ifin, 1 ) )
        If Found()
          add_string( "" )
          add_string( Center( { "ОМС", "бюджет" }[ ifin ], sh ) )
          AEval( arr_title, {| x| add_string( x ) } )
          add_string( Center( "Диагнозы + профили", sh ) )
          add_string( Replicate( "─", sh ) )
          For j := 1 To 5
            s := { "E10-E14", "C00-C97", "A00-B99", "J00-J99", "P35-P39" }[ j ]
            find ( Str( ifin, 1 ) + Str( j, 1 ) + Str( 0, 3 ) )
            If Found()
              For v := 1 To 4
                polek := "tmp->kol" + lstr( v )
                poles := "tmp->sum" + lstr( v )
                If Empty( &( polek ) )
                  s += Space( 20 )
                Else
                  s += Str( &( polek ), 7 ) + Str( &( poles ) / 1000, 13, 3 )
                Endif
              Next v
              s += Str( tmp->kol, 7 ) + Str( tmp->sum / 1000, 13, 3 )
            Endif
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( s )
            dbSeek( Str( ifin, 1 ) + Str( j, 1 ) + Str( 1, 3 ), .t. )
            Do While tmp->nstr == j .and. tmp->oms == ifin .and. !Eof()
              If verify_ff( HH - 1, .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              add_string( '- ' + inieditspr( A__MENUVERT, getv002(), tmp->PROFIL ) )
              s := Space( 7 )
              For v := 1 To 4
                polek := "tmp->kol" + lstr( v )
                poles := "tmp->sum" + lstr( v )
                If Empty( &( polek ) )
                  s += Space( 20 )
                Else
                  s += Str( &( polek ), 7 ) + Str( &( poles ) / 1000, 13, 3 )
                Endif
              Next v
              s += Str( tmp->kol, 7 ) + Str( tmp->sum / 1000, 13, 3 )
              add_string( s )
              Skip
            Enddo
            add_string( Replicate( "─", sh ) )
          Next j
          add_string( Center( "Профили", sh ) )
          add_string( Replicate( "─", sh ) )
          dbSeek( Str( ifin, 1 ) + Str( 0, 1 ), .t. )
          Do While tmp->nstr == 0 .and. tmp->oms == ifin .and. !Eof()
            If verify_ff( HH - 1, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( inieditspr( A__MENUVERT, getv002(), tmp->PROFIL ) )
            s := Space( 7 )
            For v := 1 To 4
              polek := "tmp->kol" + lstr( v )
              poles := "tmp->sum" + lstr( v )
              If Empty( &( polek ) )
                s += Space( 20 )
              Else
                s += Str( &( polek ), 7 ) + Str( &( poles ) / 1000, 13, 3 )
              Endif
            Next v
            s += Str( tmp->kol, 7 ) + Str( tmp->sum / 1000, 13, 3 )
            add_string( s )
            Skip
          Enddo
        Endif
      Next ifin
      FClose( fp )
      Close databases
      rest_box( buf )
      viewtext( nfile,,,, .t.,,, 6 )
    Else
      func_error( 4, "Нет информации по стационару за 2016 год!" )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 22.06.17
Function f1forma_792_miac( mkod_diag )
<<<<<<< HEAD
=======

>>>>>>> master
  Local k := 0, c, s

  c := Left( mkod_diag, 1 )
  s := Left( mkod_diag, 3 )
  If c == "C"
    k := 2
  Elseif c == "J"
    k := 4
  Elseif c == "A" .or. c == "B"
    k := 3
  Elseif Between( s, "E10", "E14" )
    k := 1
  Elseif Between( s, "P35", "P39" )
    k := 5
  Endif

  Return k

<<<<<<< HEAD
// 16.10.16 Мониторинг по видам медицинской помощи для Комитета здравоохранения ВО
Function monitoring_vid_pom()
  Static mm_schet := { { "все случаи", 1 }, { "в выставленных счетах", 2 }, { "в зарегистрированных счетах", 3 } }
  Local mm_tmp := {}, buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    tmp_help := help_code, hGauge, name_file := "mon_kz" + stxt, ;
    sh := 80, HH := 60, i, k, tmp_file := "tmp_mon" + sdbf, r1, r2

=======
// 11.09.25 Мониторинг по видам медицинской помощи для Комитета здравоохранения ВО
Function monitoring_vid_pom()

  Static mm_schet := { { "все случаи", 1 }, { "в выставленных счетах", 2 }, { "в зарегистрированных счетах", 3 } }
  Local mm_tmp := {}, buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    tmp_help := help_code, hGauge, name_file := cur_dir() + "mon_kz.txt", ;
    sh := 80, HH := 60, i, k, tmp_file := "tmp_mon" + sdbf(), r1, r2
>>>>>>> master
  Private pdate_lech

  //
  AAdd( mm_tmp, { "date_lech", "N", 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    iif( k == nil, nil, ( pdate_lech := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    'Дата окончания лечения (отч.период)', {|| f_valid_mon() } } )
  AAdd( mm_tmp, { "schet", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_schet, A__MENUVERT ) }, ;
    3, {| x| inieditspr( A__MENUVERT, mm_schet, x ) }, ;
    "Какие случаи учитываются", {|| f_valid_mon() } } )
  AAdd( mm_tmp, { "date_reg", "D", 8, 0,, ;
    nil, ;
    CToD( "" ), nil, ;
    "По какую дату (включительно) зарегистрирован счёт", ;
    {|| f_valid_mon() }, {|| m1schet == 3 } } )
  AAdd( mm_tmp, { "rak", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
    "Учитывать случаи, полностью снятые по актам контроля", ;
    {|| f_valid_mon() } } )
  AAdd( mm_tmp, { "date_rak", "D", 8, 0,,, CToD( "" ),, ;
    "По какую дату (включительно) проверять акты контроля",, ;
    {|| m1rak == 0 } } )
  Delete File ( tmp_file )
  init_base( tmp_file,, mm_tmp, 0 )
  r1 := 16 ; r2 := 22
  fillscrarea( r1 - 1, 0, r1 - 1, 79, "░", color1 )
  str_center( r1 - 1, " Мониторинг по видам медицинской помощи ", color8 )
  fillscrarea( r2 + 1, 0, r2 + 1, 79, "░", color1 )
<<<<<<< HEAD
  If f_edit_spr( A__APPEND, mm_tmp, "", "e_use(cur_dir+'tmp_mon')", 0, 1,,,, { r1, 0, r2, 79, -1 }, "write_mon" ) > 0
=======
  If f_edit_spr( A__APPEND, mm_tmp, "", "e_use(cur_dir()+'tmp_mon')", 0, 1,,,, { r1, 0, r2, 79, -1 }, "write_mon" ) > 0
>>>>>>> master
    RestScreen( buf )
    If Year( pdate_lech[ 5 ] ) < 2016
      Return func_error( 4, "Данный алгоритм работает с 2016 года" )
    Endif
    mywait()
    Use ( tmp_file ) New Alias MN
    arr := { ;
      { "Мед.помощь в рамках террпрограммы ОМС", "10", "", 0, 0 }, ; // 1
    { "скорая медицинская помощь", "11", "вызов", 0, 0 }, ;             // 2
      { "медицинская помощь", "12.1", "посещение с проф.целью", 0, 0 }, ;    // 3
    { "    в амбулаторных", "12.2", "посещение по неотложной помощи", 0, 0 }, ;// 4
    { "    условиях", "12.3", "обращение", 0, 0 }, ;                           // 5
      { "стационар", "13", "случай госпитализации", 0, 0 }, ;                // 6
      { "  в т.ч. реабилитация", "14", "койко-день", 0, 0 }, ;                 // 7
      { "  в т.ч. ВМП", "15", "случай госпитализации", 0, 0 }, ;               // 8
      { "дневной стационар", "16", "пациенто-день", 0, 0 } ;                // 9
      }
<<<<<<< HEAD
    r_use( dir_server + "uslugi",, "USL" )
    r_use( dir_server + "human_u_",, "HU_" )
    r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
    Set Relation To RecNo() into HU_, To u_kod into USL
    If mn->rak == 0
      r_use( dir_server + "mo_xml",, "MO_XML" )
      r_use( dir_server + "mo_rak",, "RAK" )
      Set Relation To kod_xml into MO_XML
      r_use( dir_server + "mo_raks",, "RAKS" )
      Set Relation To akt into RAK
      r_use( dir_server + "mo_raksh",, "RAKSH" )
      Set Relation To kod_raks into RAKS
      Index On Str( kod_h, 7 ) to ( cur_dir + "tmp_raksh" ) For rak->DAKT <= mn->date_rak
    Endif
    r_use( dir_server + "schet_",, "SCHET_" )
    r_use( dir_server + "schet",, "SCHET" )
    Set Relation To RecNo() into SCHET_
    //
    r_use( dir_server + "human_2",, "HUMAN_2" )
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humand", "HUMAN" )
=======
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "human_u_",, "HU_" )
    r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
    Set Relation To RecNo() into HU_, To u_kod into USL
    If mn->rak == 0
      r_use( dir_server() + "mo_xml",, "MO_XML" )
      r_use( dir_server() + "mo_rak",, "RAK" )
      Set Relation To kod_xml into MO_XML
      r_use( dir_server() + "mo_raks",, "RAKS" )
      Set Relation To akt into RAK
      r_use( dir_server() + "mo_raksh",, "RAKSH" )
      Set Relation To kod_raks into RAKS
      Index On Str( kod_h, 7 ) to ( cur_dir() + "tmp_raksh" ) For rak->DAKT <= mn->date_rak
    Endif
    r_use( dir_server() + "schet_",, "SCHET_" )
    r_use( dir_server() + "schet",, "SCHET" )
    Set Relation To RecNo() into SCHET_
    //
    r_use( dir_server() + "human_2",, "HUMAN_2" )
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
>>>>>>> master
    Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
    dbSeek( DToS( pdate_lech[ 5 ] ), .t. )
    old := pdate_lech[ 5 ] -1
    Do While human->k_data <= pdate_lech[ 6 ] .and. !Eof()
      If old != human->k_data
        old := human->k_data
        @ MaxRow(), 0 Say date_8( human->k_data ) Color cColorWait
      Endif
      fl := ( human->komu == 0 .or. !Empty( Val( human_->smo ) ) )
      If fl .and. mn->schet > 1
        fl := ( human->schet > 0 )
        If fl .and. mn->schet == 3
          schet->( dbGoto( human->schet ) )
          fl := ( date_reg_schet() <= mn->date_reg ) // дата регистрации
        Endif
      Endif
      fl_stom := .f.
      koef := 1 // по умолчанию оплачен, если даже нет РАКа
      If mn->rak == 0 // не включать полностью снятые
        k := 0
        Select RAKSH
        find ( Str( human->kod, 7 ) )
        Do While human->kod == raksh->kod_h .and. !Eof()
          k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
          Skip
        Enddo
        If !Empty( Round( k, 2 ) )
          If Empty( human->cena_1 ) // скорая помощь
            koef := 0
          Elseif round_5( human->cena_1, 2 ) == round_5( k, 2 ) // полное снятие
            koef := 0
          Else // частичное снятие
            koef := ( human->cena_1 - k ) / human->cena_1
          Endif
        Endif
      Endif
      If fl .and. koef > 0
        lsum := Round( human->cena_1 * koef, 2 )
        arr[ 1, 5 ] += lsum
        If human_->USL_OK == 4 // скорая помощь
          arr[ 2, 4 ] ++; arr[ 2, 5 ] += lsum
        Else
          vid_vp := 0 // по умолчанию профилактика
          d2_year := Year( human->k_data )
          au := {}
          kp := 0 // количество процедур
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
              lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
              ta := f14tf_nastr( @lshifr,, d2_year )
              lshifr := AllTrim( lshifr )
              AAdd( au, { lshifr, hu->kol_1, Round( hu->stoim_1 * koef, 2 ), 0, 0, hu->kol_1 } )
              If eq_any( Left( lshifr, 5 ), "2.78.", "2.89." )
                kp := 1
                vid_vp := 2 // обращения с лечебной целью
              Elseif eq_any( Left( lshifr, 5 ), "2.80.", "2.82." )
                kp += hu->kol_1
                vid_vp := 1 // в неотложной форме
              Elseif Left( lshifr, 2 ) == "2." // остальная профилактика
                If eq_any( Left( lshifr, 5 ), "2.60.", "2.90." )
                  //
                Else
                  kp += hu->kol_1
                Endif
              Elseif Left( lshifr, 2 ) == "1." // койко-дни
                kp += hu->kol_1 // если реабилитация
              Elseif Left( lshifr, 3 ) == "55."  // пациенто-дни
                kp += hu->kol_1
              Elseif Left( lshifr, 5 ) == "60.2." .or. lshifr == "4.20.702" // Р-исследование
                kp := 0  // участвует не количеством, а только суммой
              Elseif Left( lshifr, 3 ) == "57."  // стоматология
                fl_stom := .t.
              Endif
            Endif
            Select HU
            Skip
          Enddo
          If human_->USL_OK == 1 // стационар
<<<<<<< HEAD
            If AScan( glob_KSG_dializ, lshifr ) > 0 // КСГ с диализом
=======
            If AScan( glob_KSG_dializ(), lshifr ) > 0 // КСГ с диализом
>>>>>>> master
              arr[ 6, 5 ] += lsum
            Else
              arr[ 6, 4 ] ++; arr[ 6, 5 ] += lsum
              If human_->PROFIL == 158
                arr[ 7, 4 ] += kp ; arr[ 7, 5 ] += lsum
              Endif
              If human_2->VMP == 1
                arr[ 8, 4 ] ++; arr[ 8, 5 ] += lsum
              Endif
            Endif
          Elseif human_->USL_OK == 2 // дневной стационар
<<<<<<< HEAD
            If AScan( glob_KSG_dializ, lshifr ) == 0
=======
            If AScan( glob_KSG_dializ(), lshifr ) == 0
>>>>>>> master
              arr[ 9, 4 ] += kp
            Endif
            arr[ 9, 5 ] += lsum
          Else // поликлиника
            If fl_stom
              ret_tip := kp := 0
              f_vid_p_stom( au, {},,, human->k_data, @ret_tip, @kp )
              Do Case
              Case ret_tip == 1
                vid_vp := 2 // по поводу заболевания
              Case ret_tip == 2
                vid_vp := 0 // профилактика
              Case ret_tip == 3
                vid_vp := 1 // в неотложной форме
              Endcase
            Endif
            If vid_vp == 2 // по поводу заболевания
              arr[ 5, 4 ] ++; arr[ 5, 5 ] += lsum
            Elseif vid_vp == 1 // в неотложной форме
              arr[ 4, 4 ] += kp ; arr[ 4, 5 ] += lsum
            Else // профилактика
              arr[ 3, 4 ] += kp ; arr[ 3, 5 ] += lsum
            Endif
          Endif
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    Close databases
    arr_title := { ;
      "─────────────────────────────────┬────┬────────────────────┬──────┬─────────────", ;
      "Виды и условия оказания мед.пом. │№стр│ Единица измерения  │ кол. │ сумма в руб.", ;
      "─────────────────────────────────┴────┴────────────────────┴──────┴─────────────" }
    fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( "" )
    add_string( Center( "Мониторинг по видам медицинской помощи", sh ) )
    add_string( Center( pdate_lech[ 4 ], sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    For i := 1 To Len( arr )
      add_string( PadR( arr[ i, 1 ], 33 ) + " " + PadR( arr[ i, 2 ], 5 ) + PadR( arr[ i, 3 ], 20 ) + ;
        put_val( arr[ i, 4 ], 7 ) + put_kope( arr[ i, 5 ], 14 ) )
    Next
    FClose( fp )
    RestScreen( buf ) ; SetColor( tmp_color )
    viewtext( name_file,,,, ( .t. ),,, 2 )
  Endif
  Close databases
  RestScreen( buf ) ; SetColor( tmp_color )

  Return Nil

//
Function write_mon( k )
<<<<<<< HEAD
=======

>>>>>>> master
  Local fl := .t.

  If k == 1
    If Empty( mdate_lech )
      fl := func_error( 4, "Обязательно должно быть заполнено поле даты окончания лечения!" )
    Else
      If m1schet == 3
        If Empty( mdate_reg ) .or. mdate_reg < pdate_lech[ 6 ]
          fl := func_error( 4, 'Некорректное содержание поля "По какую дату (включительно) зарегистрирован счёт"' )
        Endif
      Endif
      If m1rak == 0
        If Empty( mdate_rak ) .or. mdate_rak < pdate_lech[ 6 ] .or. ;
            ( m1schet == 3 .and. mdate_rak < mdate_reg )
          fl := func_error( 4, 'Некорректное содержание поля "По какую дату (включительно) проверять акты контроля"' )
        Endif
      Endif
    Endif
  Endif

  Return fl

//
Function f_valid_mon()

  If !Empty( pdate_lech )
    If m1schet == 3
      If Empty( mdate_reg ) .or. mdate_reg < pdate_lech[ 6 ]
        mdate_reg := pdate_lech[ 6 ] + 10
      Endif
    Else
      mdate_reg := CToD( "" )
    Endif
    If m1rak == 0
      If Empty( mdate_rak ) .or. mdate_rak < pdate_lech[ 6 ] .or. ;
          ( m1schet == 3 .and. mdate_rak < mdate_reg )
        If m1schet == 3
          mdate_rak := mdate_reg
        Else
          mdate_rak := pdate_lech[ 6 ] + 10
        Endif
      Endif
    Else
      mdate_rak := CToD( "" )
    Endif
  Endif

  Return update_gets()
