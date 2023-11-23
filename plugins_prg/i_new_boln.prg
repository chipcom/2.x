#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 22.11.23 Журнал регистрации новых больных
Function i_new_boln( oEdit )
  Local arr_m, fl, ldate, buf := save_maxrow()

  If ( arr_m := year_month() ) != NIL
    mywait()
    //
    dbCreate( cur_dir + 'tmp', { { 'is', 'N', 1, 0 }, ;
      { 'kod_k', 'N', 7, 0 }, ;
      { 'task', 'N', 1, 0 }, ;
      { 'uch', 'N', 3, 0 }, ;
      { 'otd', 'N', 3, 0 }, ;
      { 'data', 'D', 8, 0 }, ;
      { 'KOD_P', 'C', 1, 0 } } ) // код пользователя, добавившего л/у
    Use ( cur_dir + 'tmp' ) new
    Index On Str( kod_k, 7 ) to ( cur_dir + 'tmp' )
    If is_task( X_REGIST )
      waitstatus( 'Подзадача РЕГИСТРАТУРА' )
      r_use( dir_server + 'mo_regi', dir_server + 'mo_regi2', 'REGI' )
      // index on pdate to (dir_server+'mo_regi2') progress
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
      waitstatus( 'Подзадача ПРИЁМНЫЙ ПОКОЙ' )
      r_use( dir_server + 'mo_pp', dir_server + 'mo_pp_d', 'PP' )
      // index on dtos(n_data)+n_time to (dir_server+'mo_pp_d') progress
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
      waitstatus( 'Подзадача ПЛАТНЫЕ УСЛУГИ' )
      r_use( dir_server + 'hum_p', dir_server + 'hum_pd', 'PLAT' )
      // index on dtos(k_data) to (dir_server+'hum_pd') progress
      dbSeek( DToS( AddMonth( arr_m[ 5 ], -6 ) ), .t. )
      Index On DToS( n_data ) to ( cur_dir + 'tmp_plat' ) ;
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
        r_use( dir_server + 'kas_pl', dir_server + 'kas_pl2', 'KP' )
        // index on dtos(k_data) to (dir_server+'kas_pl2') progress
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
      r_use( dir_server + 'hum_ort', dir_server + 'hum_ortd', 'ORT' )
      // index on dtos(k_data) to (dir_server+'hum_ortd') progress
      dbSeek( DToS( AddMonth( arr_m[ 5 ], -6 ) ), .t. )
      Index On DToS( n_data ) to ( cur_dir + 'tmp_ort' ) ;
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
        r_use( dir_server + 'kas_ort', dir_server + 'kas_ort2', 'KP' )
        // index on dtos(k_data) to (dir_server+'kas_ort2') progress
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
    waitstatus( 'Подзадача ОМС' )
    r_use( dir_server + 'human', dir_server + 'humand', 'OMS' )
    // index on dtos(k_data)+uch_doc to (dir_server+'humand') progress
    dbSeek( DToS( AddMonth( arr_m[ 5 ], -6 ) ), .t. )
    Index On DToS( n_data ) to ( cur_dir + 'tmp_oms' ) ;
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
    Set Index to ( dir_server + 'humankk' )
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
      r_use( dir_server + 'mo_pp', dir_server + 'mo_pp_r', 'PP' )
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
      r_use( dir_server + 'hum_p', dir_server + 'hum_pkk', 'PLAT' )
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
        r_use( dir_server + 'kas_pl', dir_server + 'kas_pl1', 'KP' )
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
      r_use( dir_server + 'hum_ort', dir_server + 'hum_ortk', 'ORT' )
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
        r_use( dir_server + 'kas_ort', dir_server + 'kas_ort1', 'KP' )
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
    waitstatus( 'Новые пациенты' )

    r_use( dir_server + 'kartote2',, 'KART2' )
    Index On pc1 to ( cur_dir + 'tmpkart2' ) For !Empty( pc1 ) .and. Between( SubStr( pc1, 2, 4 ), arr_m[ 7 ], arr_m[ 8 ] )
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
    waitstatus( '' )
    Close databases
    //
    delfrfiles()
    dbCreate( fr_titl, { { 'name', 'C', 130, 0 }, ;
      { 'itog', 'N', 6, 0 }, ;
      { 'period', 'C', 50, 0 } } )
    Use ( fr_titl ) New Alias FRT
    Append Blank
    frt->name := glob_mo[ _MO_SHORT_NAME ]
    frt->period := arr_m[ 4 ]
    dbCreate( fr_data, { { 'nomer', 'C', 15, 0 }, ;
      { 'fio', 'C', 60, 0 }, ;
      { 'date_r', 'D', 8, 0 }, ;
      { 'adres', 'C', 250, 0 }, ;
      { 'oper', 'C', 100, 0 } } )
    Use ( fr_data ) New Alias FRD
    r_use( dir_server + 'base1',, 'BASE1' )
    r_use( dir_server + 'kartote2',, 'KART2' )
    r_use( dir_server + 'kartote_',, 'KART_' )
    r_use( dir_server + 'kartotek',, 'KART' )
    Use ( cur_dir + 'tmp' ) new
    Set Relation To kod_k into KART, To kod_k into KART_, To kod_k into KART2

    waitstatus( 'Подождите, идет обработка' )

    Index On Upper( kart->fio ) to ( cur_dir + 'tmp' ) For is > 0
    Go Top
    Do While !Eof()
      updatestatus()
      frt->itog++
      s := ''
      If Asc( tmp->kod_p ) > 0
        Select BASE1
        Goto ( Asc( tmp->kod_p ) )
        If !Eof() .and. !Empty( base1->p1 )
          s += AllTrim( Crypt( base1->p1, gpasskod ) ) + eos
        Endif
      Endif
      If tmp->task == X_REGIST
        If !Empty( tmp->otd )
          If tmp->uch == 1
            s += inieditspr( A__POPUPMENU, dir_server + 'mo_otd', tmp->otd )
          Else
            s += inieditspr( A__POPUPMENU, dir_server + 'p_priem', tmp->otd )
          Endif
        Endif
      Else
        If !Empty( tmp->otd )
          s += inieditspr( A__POPUPMENU, dir_server + 'mo_otd', tmp->otd )
          If tmp->task != X_OMS
            s += eos
          Endif
        Endif
        Do Case
        Case tmp->task == X_PPOKOJ
          s += '(пр/покой)'
        Case tmp->task == X_PLATN
          s += '(пл/услуги)'
        Case tmp->task == X_ORTO
          s += '(ортопедия)'
        Case tmp->task == X_KASSA
          s += '(касса)'
        Endcase
      Endif
      Select FRD
      Append Blank
      frd->nomer := amb_kartaN()
      frd->fio := kart->fio
      frd->date_r := kart->date_r
      frd->adres := iif( emptyall( kart_->okatog, kart->adres ), '', ;
        ret_okato_ulica( kart->adres, kart_->okatog ) )
      frd->oper := s
      Select TMP
      Skip
    Enddo
    Close databases
    rest_box( buf )
    call_fr( 'mo_new_b' )
  Endif

  Return Nil
