#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 01.11.25 определить КСГ для 1 пациента из режима редактирования услуг
Function f_usl_definition_ksg( lkod, k_data2, lDoubleSluch )

  Local arr, buf := save_maxrow(), lshifr, lrec, lu_kod, lcena, not_ksg := .t., ;
    mrec_hu, tmp_rec := 0, tmp_select := Select(), is_usl1 := .f., ;
    ret := {}, lyear := Year( human->K_DATA ), i, s, sdial, fl
  Local lalias

  Default lDoubleSluch To .f.
  If human_->USL_OK < 3
    mywait( 'Определение КСГ' )
    usl->( dbCloseArea() ) // переоткрыть справочник услуг
    use_base( 'uslugi' )
    If Select( 'USL1' ) == 0
      is_usl1 := .t.
      r_use( dir_server() + 'uslugi1', { dir_server() + 'uslugi1', ;
        dir_server() + 'uslugi1s' }, 'USL1' )
    Endif
    Select TMP
    If LastRec() > 0
      tmp_rec := RecNo()
    Endif
    Set Relation To
    arr := definition_ksg( 1, k_data2, lDoubleSluch )
    sdial := 0
    fl := .t.
    If Len( arr ) == 7
      If ValType( arr[ 7 ] ) == 'N'
        sdial := arr[ 7 ] // для 2019 года
        If emptyall( arr[ 1 ], arr[ 2 ], arr[ 3 ], arr[ 4 ] )
          fl := .f. // диализ в дневном стационаре без КСГ
        Endif
      Else
        fl := .f. // для 2018 года
      Endif
    Endif
    If fl // не диализ 2018 года
      AEval( arr[ 1 ], {| x| my_debug( , x ), AAdd( ret, x ) } )
      If !Empty( arr[ 2 ] )
        my_debug(, 'ОШИБКА:' )
        AEval( arr[ 2 ], {| x| my_debug( , x ), AAdd( ret, x ) } )
      Endif
      lrec := lcena := 0
      Select TMP
      Go Top
      Do While !Eof()
        If Empty( lshifr := tmp->shifr1 )
          lshifr := tmp->shifr_u
        Endif
        If !Empty( arr[ 3 ] ) .and. AllTrim( lshifr ) == arr[ 3 ] // уже стоит тот же КСГ
          not_ksg := .f.
          lcena := arr[ 4 ]
          If !( Round( tmp->u_cena, 2 ) == Round( lcena, 2 ) ) // перезапишем цену
            tmp->u_cena := lcena
            tmp->stoim_1 := lcena
            Select HU
            Goto ( tmp->rec_hu )
            g_rlock( forever )
            hu->u_cena := lcena
            hu->stoim := hu->stoim_1 := lcena
            Unlock
          Endif
          Exit
        Endif

        lalias := create_name_alias( 'lusl', lyear )
        dbSelectArea( lalias )
        find ( PadR( lshifr, 10 ) ) // длина lshifr 10 знаков
        If Found() .and. ( eq_any( Left( lshifr, 5 ), code_services_vmp( lyear ) ) .or. is_ksg( ( lalias )->shifr ) )
          lrec := tmp->( RecNo() )
          Exit
        Endif
        Select TMP
        Skip
      Enddo
      If Empty( arr[ 2 ] )
        If Empty( lcena )
          lu_kod := foundourusluga( arr[ 3 ], human->k_data, human_->profil, human->VZROS_REB, @lcena )
          If lyear >= 2023  // 23 год
            If Len( arr ) > 4 .and. !Empty( arr[ 5 ] )
              // if human_->USL_OK == USL_OK_HOSPITAL
              // if human->k_data < ctod('01/10/2023')  // до 01.10.2023
              // lcena := round_5(lcena + 25986.7 * ret_koef_kslp_21(arr[5], lyear), 0)
              // else  // после 01.10.2023
              // lcena := round_5(lcena + 29995.8 * ret_koef_kslp_21(arr[5], lyear), 0)
              // endif
              // elseif human_->USL_OK == USL_OK_DAY_HOSPITAL
              // lcena := round_5(lcena + 15029.1 * ret_koef_kslp_21(arr[5], lyear), 0)
              // endif
              lcena := round_5( lcena + baserate( human->k_data, human_->USL_OK ) * ret_koef_kslp_21( arr[ 5 ], lyear ), 0 )
            Endif
            If Len( arr ) > 5 .and. !Empty( arr[ 6 ] )
              lcena := round_5( lcena * arr[ 6, 2 ], 0 )
            Endif
          Elseif lyear == 2022  // 22 год
            If Len( arr ) > 4 .and. !Empty( arr[ 5 ] )
              // lcena := round_5(lcena + 24322.6 * ret_koef_kslp_21(arr[5], lyear), 0)
              lcena := round_5( lcena + baserate( human->k_data, human_->USL_OK ) * ret_koef_kslp_21( arr[ 5 ], lyear ), 0 )
            Endif
            If Len( arr ) > 5 .and. !Empty( arr[ 6 ] )
              lcena := round_5( lcena * arr[ 6, 2 ], 0 )
            Endif
          Elseif lyear == 2021  // 21 год
            If Len( arr ) > 4 .and. !Empty( arr[ 5 ] )
              lcena := round_5( lcena * ret_koef_kslp_21( arr[ 5 ], lyear ), 0 )
            Endif
            If Len( arr ) > 5 .and. !Empty( arr[ 6 ] )
              lcena := round_5( lcena * arr[ 6, 2 ], 0 )
            Endif
          Elseif lyear > 2018  // округление до рублей с 2019 года
            If Len( arr ) > 4 .and. !Empty( arr[ 5 ] )
              lcena := round_5( lcena * ret_koef_kslp( arr[ 5 ] ), 0 )
            Endif
            If Len( arr ) > 5 .and. !Empty( arr[ 6 ] )
              lcena := round_5( lcena * arr[ 6, 2 ], 0 )
            Endif
          Else
            If Len( arr ) > 4 .and. !Empty( arr[ 5 ] )
              lcena := round_5( lcena * arr[ 5, 2 ], 1 )
            Endif
            If Len( arr ) > 5 .and. !Empty( arr[ 6 ] )
              lcena := round_5( lcena * arr[ 6, 2 ], 1 )
            Endif
          Endif
          If Round( arr[ 4 ], 2 ) == Round( lcena, 2 ) // цена определена правильно
            usl->( dbGoto( lu_kod ) )
            Select HU
            If lrec == 0
              add1rec( 7 )
              hu->kod := human->kod
            Else
              Select TMP
              Goto ( lrec )
              Select HU
              Goto ( tmp->rec_hu )
              g_rlock( forever )
            Endif
            mrec_hu := hu->( RecNo() )
            hu->kod_vr  := human_->VRACH
            hu->kod_as  := 0
            hu->u_koef  := 1
            hu->u_kod   := lu_kod
            hu->u_cena  := lcena
            hu->is_edit := 0
            hu->date_u  := dtoc4( human->n_data )
            hu->otd     := human->otd
            hu->kol := hu->kol_1 := 1
            hu->stoim := hu->stoim_1 := lcena
            Select HU_
            Do While hu_->( LastRec() ) < mrec_hu
              Append Blank
            Enddo
            Goto ( mrec_hu )
            g_rlock( forever )
            If lrec == 0 .or. !valid_guid( hu_->ID_U )
              hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
            Endif
            hu_->PROFIL := human_->PROFIL
            hu_->PRVS   := human_->PRVS
            hu_->kod_diag := human->KOD_DIAG
            hu_->zf := ''
            Unlock
            //
            Select TMP
            If lrec == 0
              Append Blank
              hu->kod := human->kod
            Else
              Goto ( lrec )
            Endif
            tmp->KOD     := human->kod
            tmp->DATE_U  := hu->date_u
            tmp->U_KOD   := lu_kod
            tmp->U_CENA  := lcena
            tmp->KOD_VR  := human_->VRACH
            tmp->KOD_AS  := 0
            tmp->OTD     := human->otd
            tmp->KOL_1   := 1
            tmp->STOIM_1 := lcena
            tmp->kod_diag := human->KOD_DIAG
            tmp->ZF      := ''
            tmp->PROFIL  := human_->PROFIL
            tmp->PRVS    := human_->PRVS
            tmp->date_u1 := human->n_data
            tmp->shifr_u := arr[ 3 ]
            tmp->shifr1  := arr[ 3 ]
            tmp->name_u  := usl->name
            tmp->is_nul  := usl->is_nul
            tmp->is_oms  := .t.
            tmp->n_base  := 0
            tmp->dom     := 0
            tmp->rec_hu  := mrec_hu
          Else
            func_error( 4, 'ОШИБКА: разница в цене услуги ' + lstr( arr[ 4 ] ) + ' != ' + lstr( lcena ) )
            not_ksg := .f.
            lcena := 0
          Endif
        Endif
      Elseif lrec > 0 // не удалось определить КСГ
        Select TMP
        Goto ( lrec )
        Select HU
        Goto ( tmp->rec_hu )
        deleterec( .t., .f. )  // очистка записи без пометки на удаление
        Select TMP
        deleterec( .t. )  // с пометкой на удаление
        lcena := 0
      Endif
      If !( Round( human->CENA_1, 2 ) == Round( lcena + sdial, 2 ) )
        Select HUMAN
        g_rlock( forever )
        human->CENA := human->CENA_1 := lcena + sdial // перезапишем стоимость лечения
        Unlock
      Endif
      put_str_kslp_kiro( arr )
      Commit
      If Empty( arr[ 2 ] )
        If not_ksg
          i := Len( arr[ 1 ] )
          s := arr[ 1, i ]
          If !( 'РЕЗУЛЬТАТ' $ arr[ 1, i ] ) .and. i > 1
            s := AllTrim( arr[ 1, i -1 ] + s )
          Endif
          stat_msg( s )
          mybell( 2, OK )
        Endif
      Else
        func_error( 4, 'ОШИБКА: ' + arr[ 2, 1 ] )
      Endif
    Endif
    If is_usl1
      usl1->( dbCloseArea() )
    Endif
    usl->( dbCloseArea() ) // переоткрыть справочник услуг
    r_use( dir_server() + 'uslugi', dir_server() + 'uslugish', 'USL' )
    Select TMP
    Set Relation To otd into OTD
    If tmp_rec > 0
      Goto ( tmp_rec )
    Endif
    Select ( tmp_select )
    rest_box( buf )
  Endif

  Return ret
