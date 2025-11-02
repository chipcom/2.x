#include 'function.ch'
#include 'chip_mo.ch'

// 30.12.23 определить КСГ для 1 пациента с открытием файлов
// ВНИМАНИЕ! Не менять название функции, используется в PROCNAME() другой функции
Function f_1pac_definition_ksg( lkod, is_msg )

  Local arr, i, s, buf := save_maxrow(), lshifr, lrec, lu_kod, lcena, lyear, mrec_hu, not_ksg := .t., sdial, fl
  Local lalias

  Default is_msg To .t.
  mywait( 'Определение КСГ' )
  r_use( dir_server() + 'mo_uch', , 'UCH' )
  r_use( dir_server() + 'mo_otd', , 'OTD' )
  use_base( 'lusl' )
  use_base( 'luslc' )
  use_base( 'uslugi' )
  r_use( dir_server() + 'uslugi1', { dir_server() + 'uslugi1', ;
    dir_server() + 'uslugi1s' }, 'USL1' )
  use_base( 'human_u' ) // если понадобится, удалить старый КСГ и добавить новый
  r_use( dir_server() + 'mo_su', , 'MOSU' )
  r_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU' )
  Set Relation To u_kod into MOSU
  g_use( dir_server() + 'human_2', , 'HUMAN_2' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  g_use( dir_server() + 'human', , 'HUMAN' ) // перезаписать сумму
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  Goto ( lkod )
  lyear := Year( human->K_DATA )
  If human_->USL_OK < 3
    arr := definition_ksg()
    sdial := 0
    fl := .t.
    If Len( arr ) == 7
      If ValType( arr[ 7 ] ) == 'N'
        sdial := arr[ 7 ] // для 2019 года и позже
        If emptyall( arr[ 1 ], arr[ 2 ], arr[ 3 ], arr[ 4 ] )
          fl := .f. // диализ в дневном стационаре без КСГ
        Endif
      Else
        fl := .f. // для 2018 года
      Endif
    Endif
    If fl // не диализ 2018 года
      AEval( arr[ 1 ], {| x| my_debug(, x ) } )
      If !Empty( arr[ 2 ] )
        my_debug(, 'ОШИБКА:' )
        AEval( arr[ 2 ], {| x| my_debug(, x ) } )
      Endif
      lrec := lcena := 0
      Select HU
      find ( Str( lkod, 7 ) )
      Do While hu->kod == lkod .and. !Eof()
        usl->( dbGoto( hu->u_kod ) )
        If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
          lshifr := usl->shifr
        Endif
        If !Empty( arr[ 3 ] ) .and. AllTrim( lshifr ) == arr[ 3 ] // уже стоит тот же КСГ
          not_ksg := .f.
          lcena := arr[ 4 ]
          If !( Round( hu->u_cena, 2 ) == Round( lcena, 2 ) ) // перезапишем цену
            Select HU
            g_rlock( forever )
            hu->u_cena := lcena
            hu->stoim := hu->stoim_1 := lcena
            Unlock
          Endif
          Exit
        Endif

        lalias := create_name_alias( 'lusl', lyear )
        dbSelectArea( lalias )
        find ( lshifr ) // длина lshifr 10 знаков
        If Found() .and. ( eq_any( Left( lshifr, 5 ), code_services_vmp( lyear ) ) .or. is_ksg( ( lalias )->shifr ) )
          lrec := hu->( RecNo() )
          Exit
        Endif
        Select HU
        Skip
      Enddo
      If Empty( arr[ 2 ] )
        If Empty( lcena )
          lu_kod := foundourusluga( arr[ 3 ], human->k_data, human_->profil, human->VZROS_REB, @lcena )
          If lyear > 2018  // округление до рублей с 2019 года
            If Len( arr ) > 4 .and. !Empty( arr[ 5 ] )
              If lyear >= 2023
                // if human_->USL_OK == USL_OK_HOSPITAL
                // if human->k_data < ctod('01/10/2023')  // до 01.10.2023
                // lcena := round_5(lcena + 25986.7 * ret_koef_kslp_21(arr[5], year(human->k_data)), 0)
                // else  // после 01.10.2023
                // lcena := round_5(lcena + 29995.8 * ret_koef_kslp_21(arr[5], year(human->k_data)), 0)
                // endif
                // elseif human_->USL_OK == USL_OK_DAY_HOSPITAL
                // lcena := round_5(lcena + 15029.1 * ret_koef_kslp_21(arr[5], year(human->k_data)), 0)
                // endif
                lcena := round_5( lcena + baserate( human->k_data, human_->USL_OK ) * ret_koef_kslp_21( arr[ 5 ], Year( human->k_data ) ), 0 )
              Else
                lcena := round_5( lcena * ret_koef_kslp( arr[ 5 ] ), 0 )
              Endif
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
            Select HU
            If lrec == 0
              add1rec( 7 )
              hu->kod := human->kod
            Else
              Goto ( lrec )
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
          Else
            func_error( 4, 'ОШИБКА: разница в цене услуги ' + lstr( arr[ 4 ] ) + ' != ' + lstr( lcena ) )
            not_ksg := .f.
            lcena := 0
          Endif
        Endif
      Elseif lrec > 0 // не удалось определить КСГ
        Select HU
        Goto ( lrec )
        deleterec( .t., .f. )  // очистка записи без пометки на удаление
        lcena := 0
      Endif
      If !( Round( human->CENA_1, 2 ) == Round( lcena + sdial, 2 ) )
        Select HUMAN
        g_rlock( forever )
        human->CENA := human->CENA_1 := lcena + sdial // перезапишем стоимость лечения
        Unlock
      Endif
      put_str_kslp_kiro( arr )
      Close databases
      If Empty( arr[ 2 ] )
        If not_ksg .and. is_msg
          i := Len( arr[ 1 ] )
          s := arr[ 1, i ]
          If !( 'РЕЗУЛЬТАТ' $ arr[ 1, i ] ) .and. i > 1
            s := AllTrim( arr[ 1, i - 1 ] + s )
          Endif
          stat_msg( s ) ; mybell( 2, OK )
        Endif
      Else
        func_error( 4, 'ОШИБКА: ' + arr[ 2, 1 ] )
      Endif
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil
