// mo_omsfo.prg - информация по ОМС (объём работ по номенклатуре ФФОМС)
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static lcount_uch := 1
Static lcount_otd := 1

// 11.09.25 вернуть вид помощи (bit-овый вариант)
Function fbp_mz_rf( r, c )

  Static sast := {}
  Local fl := .t., i, j, a, arr := {}

  If glob_menu_mz_rf()[ 1 ]
    AAdd( arr, { 'стационар', 1 } )
  Endif
  If glob_menu_mz_rf()[ 2 ]
    AAdd( arr, { 'дневной стационар', 2 } )
  Endif
  AAdd( arr, { 'поликлиника' + iif( glob_menu_mz_rf()[ 3 ], '/стоматология', '' ), 3 } )
  If ( j := Len( arr ) ) == 1
    Return arr
  Elseif j > 1
    If Len( sast ) != j
      sast := Array( j )
      AFill( sast, .t. )
    Endif
    If ( a := bit_popup( r, c, arr, sast ) ) != NIL
      AFill( sast, .f. )
      fl := .t.
      For i := 1 To Len( a )
        If ( j := AScan( arr, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
          sast[ j ] := .t.
        Endif
      Next
    Endif
  Endif
  Return a

// 27.05.23
Function obf2_statist( k, serv_arr )

  Local i, j, arr[ 2 ], begin_date, end_date, bk := 1, ek := 99, ;
    fl_exit := .f., sh := 80, HH := 57, regim := 2, s, fl_1_list := .t., ;
    len_n, pkol, pkol1, ptrud, old_perso, old_vr_as, old_usl, ;
    old_fio, arr_otd := {}, mkol, arr_kd := {}, len_kd := 0, ;
    xx, yy, pole_va, lrec, t_date1, t_date2, arr_title, ;
    musluga, mperso := {}, mkod_perso, arr_usl := {}, adbf1, adbf2, ;
    arr_svod_nom := {}, arr_m

  Private is_all := .t., ret_mz_rf
  Private skol := { 0, 0 }, skol1 := { 0, 0 }, strud := { 0, 0 }

  If eq_any( k, 2, 3, 4, 8, 9 )  // по отделению
    If ( st_a_otd := inputn_otd( T_ROW, T_COL -5, .f., .f., , @lcount_otd ) ) == NIL
      Return Nil
    Endif
    AEval( st_a_otd, {| x| AAdd( arr_otd, x ) } )
    If k == 8 .and. ( musluga := input_fusluga() ) == NIL
      Return Nil
    Endif
    If k == 9 .and. !input_perso( T_ROW, T_COL -5, .f. )
      Return Nil
    Endif
  Else  // по учреждению(ям)
    If ( st_a_uch := inputn_uch( T_ROW, T_COL -5, , , @lcount_uch ) ) == NIL
      Return Nil
    Endif
    r_use( dir_server() + 'mo_otd', , 'OTD' )
    dbEval( {|| AAdd( arr_otd, { otd->( RecNo() ), otd->name, otd->kod_lpu } ) }, ;
      {|| f_is_uch( st_a_uch, otd->kod_lpu ) } )
    otd->( dbCloseArea() )
    If ( ( k == 5 .and. serv_arr == NIL ) .or. k == 13 ) .and. !input_perso( T_ROW, T_COL -5, .f. )
      Return Nil
    Endif
  Endif
  //
  If eq_any( k, 3, 31, 4, 13 )
    If ( xx := popup_prompt( T_ROW, T_COL -5, 1, { 'Все ~услуги', '~Список услуг' } ) ) == 0
      Return Nil
    Endif
    is_all := ( xx == 1 )
  Endif
  //
  Private ym_kol_mes := 1
  arr_m := { Year( sys_date ), Month( sys_date ), , , sys_date, sys_date, , }
  If pi1 != 4
    If ( arr := year_month() ) == NIL
      Return Nil
    Endif
    begin_date := arr[ 7 ]
    end_date := arr[ 8 ]
    arr_m := AClone( arr )
  Endif
  If k == 5 .and. serv_arr != NIL
    If serv_arr[ 1 ] == 1  // N человек
      If ( mperso := input_kperso() ) == NIL
        Return Nil
      Endif
    Elseif serv_arr[ 1 ] == 2  // весь персонал
      mywait()
      mperso := {}
      r_use( dir_server() + 'mo_hu', { dir_server() + 'mo_huv', ;
        dir_server() + 'mo_hua' }, 'HU' )
      r_use( dir_server() + 'mo_pers', , 'P2' )
      Go Top
      Do While !Eof()
        If p2->kod > 0
          fl := .f.
          Select HU
          Set Order To 1
          find ( Str( p2->kod, 4 ) )
          If !( fl := Found() )
            Set Order To 2
            find ( Str( p2->kod, 4 ) )
            fl := Found()
          Endif
          If fl
            AAdd( mperso, { p2->kod, '' } )
          Endif
        Endif
        Select P2
        Skip
      Enddo
      hu->( dbCloseArea() )
      p2->( dbCloseArea() )
    Endif
  Endif
  If !fbp_ist_fin( T_ROW, T_COL -5 )
    Return Nil
  Endif
  If ( ret_mz_rf := fbp_mz_rf( T_ROW, T_COL -5 ) ) == NIL
    Return Nil
  Endif
  adbf1 := { ;
    { 'U_KOD',    'N',      6,      0 }, ;  // код услуги
    { 'U_SHIFR',    'C',     20,      0 }, ;  // шифр услуги
    { 'U_NAME',     'C',    255,      0 }, ;  // наименование услуги
    { 'FIO',        'C',     25,      0 }, ;  // ФИО больного
    { 'KOD',        'N',      7,      0 }, ;  // код больного
    { 'K_DATA',     'D',      8,      0 }, ;  // дата окончания лечения
    { 'TRUDOEM',    'N',     13,      2 }, ;  // количество УЕТ
    { 'KOL',    'N',      5,      0 }, ;  // количество услуг
    { 'KOL1',    'N',      5,      0 } ;  // количество услуг
  }
  adbf2 := { ;
    { 'otd',        'N',      3,      0 }, ;  // отделение, где оказана услуга
    { 'U_KOD',    'N',      6,      0 }, ;  // код услуги
    { 'U_SHIFR',    'C',     20,      0 }, ;  // шифр услуги
    { 'U_NAME',     'C',    255,      0 }, ;  // наименование услуги
    { 'VR_AS',      'N',      1,      0 }, ;  // врач - 1 ; ассистент - 2
    { 'TAB_NOM',    'N',      5,      0 }, ;  // таб.номер врача (ассистента)
    { 'SVOD_NOM',   'N',      5,      0 }, ;  // сводный таб.номер
    { 'KOD_VR_AS',  'N',      4,      0 }, ;  // код врача (ассистента)
    { 'FIO',        'C',     60,      0 }, ;  // Ф.И.О. врача (ассистента)
    { 'KOD_AS',    'N',      4,      0 }, ;  // код ассистента
    { 'TRUDOEM',    'N',     13,      2 }, ;  // количество УЕТ
    { 'KOL',    'N',      6,      0 }, ;  // количество услуг
    { 'KOL1',    'N',      6,      0 } ;  // количество услуг
  }
  If !is_all
    dbCreate( cur_dir() + 'tmp', adbf2 )
    Use ( cur_dir() + 'tmp' ) new
    Index On Str( u_kod, 6 ) to ( cur_dir() + 'tmpk' )
    Index On fsort_usl( u_shifr ) to ( cur_dir() + 'tmpn' )
    Close databases
    obf2_v_usl()
    Use ( cur_dir() + 'tmp' ) new
    dbEval( {|| AAdd( arr_usl, tmp->u_kod ) } )
    Use
    If Len( arr_usl ) == 0
      Return Nil
    Endif
  Endif
  If eq_any( k, 8, 9, 13, 14 )  // вывод списка больных
    dbCreate( cur_dir() + 'tmp', adbf1 )
  Else
    dbCreate( cur_dir() + 'tmp', adbf2 )
  Endif
  waitstatus( '<Esc> - прервать поиск' )
  mark_keys( { '<Esc>' } )
  Use ( cur_dir() + 'tmp' )
  Do Case
  Case k == 1  // Количество услуг и сумма лечения по отделениям
    Index On Str( otd, 3 ) to ( cur_dir() + 'tmpk' )
    Index On Str( u_kod, 6 ) + Upper( fio ) to ( cur_dir() + 'tmpn' )
  Case k == 2  // Статистика по работе персонала в конкретном отделении
    Index On Str( vr_as, 1 ) + Str( kod_vr_as, 4 ) to ( cur_dir() + 'tmpk' )
    Index On Upper( Left( fio, 30 ) ) + Str( kod_vr_as, 4 ) + Str( vr_as, 1 ) to ( cur_dir() + 'tmpn' )
  Case k == 3  // Статистика по услугам, оказанным в конкретном отделении
    Index On Str( u_kod, 6 ) to ( cur_dir() + 'tmpk' )
    Index On fsort_usl( u_shifr ) to ( cur_dir() + 'tmpn' )
  Case k == 31  // Статистика по услугам, оказанным в конкретных отделениях
    Index On Str( otd, 3 ) + Str( u_kod, 6 ) to ( cur_dir() + 'tmpk' )
    Index On Upper( fio ) + Str( otd, 3 ) + fsort_usl( u_shifr ) to ( cur_dir() + 'tmpn' )
  Case k == 4  // Статистика по работе персонала (плюс оказанные услуги) в конкретном отделении
    Index On Str( vr_as, 1 ) + Str( kod_vr_as, 4 ) + Str( u_kod, 6 ) to ( cur_dir() + 'tmpk' )
    Index On Upper( Left( fio, 30 ) ) + Str( kod_vr_as, 4 ) + Str( vr_as, 1 ) + fsort_usl( u_shifr ) to ( cur_dir() + 'tmpn' )
  Case k == 5  // Статистика по работе конкретного человека (плюс оказанные услуги)
    Index On Str( vr_as, 1 ) + Str( kod_vr_as, 4 ) + Str( u_kod, 6 ) to ( cur_dir() + 'tmpk' )
    If serv_arr == NIL
      Index On Str( vr_as, 1 ) + fsort_usl( u_shifr ) to ( cur_dir() + 'tmpn' )
    Else
      Index On Upper( Left( fio, 30 ) ) + Str( kod_vr_as, 4 ) + Str( vr_as, 1 ) + fsort_usl( u_shifr ) to ( cur_dir() + 'tmpn' )
    Endif
  Case k == 6  // Статистика по конкретным услугам
    Index On Str( u_kod, 6 ) to ( cur_dir() + 'tmpk' )
    Index On fsort_usl( u_shifr ) to ( cur_dir() + 'tmpn' )
    Close databases
    obf2_v_usl()
  Case k == 7  // Статистика по работе всего персонала
    Index On Str( vr_as, 1 ) + Str( kod_vr_as, 4 ) to ( cur_dir() + 'tmpk' )
    Index On Upper( Left( fio, 30 ) ) + Str( kod_vr_as, 4 ) + Str( vr_as, 1 ) to ( cur_dir() + 'tmpn' )
  Case eq_any( k, 8, 9 )  // вывод списка больных
    Index On Str( kod, 7 ) to ( cur_dir() + 'tmpk' )
    Index On DToS( k_data ) + Upper( Left( fio, 30 ) ) to ( cur_dir() + 'tmpn' )
  Case k == 12 // Статистика по всем услугам
    Index On Str( u_kod, 6 ) to ( cur_dir() + 'tmpk' )
    Index On fsort_usl( u_shifr ) to ( cur_dir() + 'tmpn' )
  Case k == 13  // вывод услуг + списка больных
    Index On Str( u_kod, 6 ) + Str( kod, 7 ) to ( cur_dir() + 'tmpk' )
    Index On fsort_usl( u_shifr ) + Str( u_kod, 6 ) + DToS( k_data ) + Upper( Left( fio, 30 ) ) to ( cur_dir() + 'tmpn' )
  Case k == 14  // Статистика по конкретным услугам + список больных
    Index On Str( u_kod, 6 ) + Str( kod, 7 ) to ( cur_dir() + 'tmpk' )
    Index On fsort_usl( u_shifr ) + Str( u_kod, 6 ) + DToS( k_data ) + Upper( Left( fio, 30 ) ) to ( cur_dir() + 'tmpn' )
    Close databases
    obf2_v_usl()
  Endcase
  Use ( cur_dir() + 'tmp' ) index ( cur_dir() + 'tmpk' ), ( cur_dir() + 'tmpn' ) Alias TMP
  r_use( dir_server() + 'mo_su', , 'USL' )
  Private is_1_usluga := ( Len( arr_usl ) == 1 )
  use_base( 'luslf' )
  r_use( dir_server() + 'mo_pers', , 'PERSO' )
  If eq_any( k, 5, 9, 13 )  // Статистика по работе конкретного человека
    If serv_arr == NIL
      mperso := { glob_human }
    Endif
    If pi1 == 4  // по невыписанным счетам
      pole_kol := 'hu->kol_1'
      r_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'HU' )
      r_use( dir_server() + 'human_', , 'HUMAN_' )
      r_use( dir_server() + 'human', dir_server() + 'humann', 'HUMAN' )
      Set Relation To RecNo() into HUMAN_
      dbSeek( '1', .t. )
      Do While human->tip_h < B_SCHET .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t.
          Exit
        Endif
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          If iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
            mkod_perso := 0
            If hu->kod_vr > 0 .and. AScan( mperso, {| x| x[ 1 ] == hu->kod_vr } ) > 0
              mkod_perso := hu->kod_vr
            Elseif hu->kod_as > 0 .and. AScan( mperso, {| x| x[ 1 ] == hu->kod_as } ) > 0
              mkod_perso := hu->kod_as
            Endif
            If mkod_perso > 0
              If k == 5
                obf3_statist( k, arr_otd, serv_arr, mkod_perso )
              Elseif eq_any( k, 9, 13 )
                obf5_statist( k, arr_otd, serv_arr )
              Endif
            Endif
          Endif
          Select HU
          Skip
        Enddo
        Select HUMAN
        Skip
      Enddo
    Else   // between(pi1, 1, 3)
      r_use( dir_server() + 'schet', , 'SCHET' )
      r_use( dir_server() + 'human_', , 'HUMAN_' )
      r_use( dir_server() + 'human', dir_server() + 'humank', 'HUMAN' )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server() + 'mo_hu', { dir_server() + 'mo_huv', ;
        dir_server() + 'mo_hua', ;
        dir_server() + 'mo_hu' }, 'HU' )
      For yy := 1 To Len( mperso )
        mkod_perso := mperso[ yy, 1 ]
        For xx := 1 To 2
          pole_va := { 'hu->kod_vr', 'hu->kod_as' }[ xx ]
          Select HU
          If xx == 1
            Set Order To 1
          Elseif xx == 2
            Set Order To 2
          Endif
          Do Case
          Case pi1 == 1  // по дате оказания услуги
            pole_kol := 'hu->kol_1'
            Select HU
            dbSeek( Str( mkod_perso, 4 ) + begin_date, .t. )
            Do while &pole_va == mkod_perso .and. hu->date_u <= end_date .and. !Eof()
              updatestatus()
              If Inkey() == K_ESC
                fl_exit := .t.
                Exit
              Endif
              If iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
                human->( dbSeek( Str( hu->kod, 7 ) ) )
                If human_->oplata < 9
                  If k == 5
                    obf3_statist( k, arr_otd, serv_arr, mkod_perso )
                  Elseif eq_any( k, 9, 13 ) .and. iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
                    obf5_statist( k, arr_otd, serv_arr )
                  Endif
                Endif
              Endif
              Select HU
              Skip
            Enddo
          Case Between( pi1, 2, 3 )  // по дате выписки счета и окончания лечения
            pole_kol := 'hu->kol_1'
            Select HU
            dni_vr := Max( 366, mem_dni_vr ) // отнимем min год
            dbSeek( Str( mkod_perso, 4 ) + dtoc4( arr[ 5 ] - dni_vr ), .t. )
            Do while &pole_va == mkod_perso .and. hu->date_u <= end_date .and. !Eof()
              updatestatus()
              If Inkey() == K_ESC
                fl_exit := .t.
                Exit
              Endif
              If iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
                Select HUMAN
                find ( Str( hu->kod, 7 ) )
                fl := .f.
                If human_->oplata < 9
                  If pi1 == 2
                    If human->schet > 0 // .and. human->cena_1 > 0
                      Select SCHET
                      Goto ( human->schet )
                      fl := Between( schet->pdate, begin_date, end_date )
                    Endif
                  Else // pi1 == 3
                    fl := Between( human->k_data, arr_m[ 5 ], arr_m[ 6 ] )
                    fl := func_pi_schet( fl )
                  Endif
                Endif
                If fl
                  If k == 5
                    obf3_statist( k, arr_otd, serv_arr, mkod_perso )
                  Elseif eq_any( k, 9, 13 )
                    obf5_statist( k, arr_otd, serv_arr )
                  Endif
                Endif
              Endif
              Select HU
              Skip
            Enddo
          Endcase
        Next
        If fl_exit
          Exit
        Endif
      Next
    Endif
  Elseif eq_any( k, 6, 8, 14 )  // Статистика по конкретным(ой) услугам(е)
    If eq_any( k, 6, 14 )
      Select TMP  // в базе данных уже занесены необходимые нам услуги
      // переносим их в массив arr_usl
      dbEval( {|| AAdd( arr_usl, { tmp->u_kod, tmp->( RecNo() ) } ) } )
      If k == 14
        Zap
      Endif
    Elseif k == 8
      arr_usl := { { musluga[ 1 ], 0 } }
    Endif
    is_1_usluga := ( Len( arr_usl ) == 1 )
    If pi1 == 4  // по невыписанным счетам
      pole_kol := 'hu->kol_1'
      r_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'HU' )
      r_use( dir_server() + 'human_', , 'HUMAN_' )
      r_use( dir_server() + 'human', dir_server() + 'humann', 'HUMAN' )
      Set Relation To RecNo() into HUMAN_
      dbSeek( '1', .t. )
      Do While human->tip_h < B_SCHET .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t.
          Exit
        Endif
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          If ( i := AScan( arr_usl, {| x| x[ 1 ] == hu->u_kod } ) ) > 0
            If k == 6
              tmp->( dbGoto( arr_usl[ i, 2 ] ) )
              lrec := tmp->( RecNo() )
              obf3_statist( k, arr_otd, serv_arr )
            Elseif eq_any( k, 8, 14 )
              obf5_statist( k, arr_otd, serv_arr )
            Endif
          Endif
          Select HU
          Skip
        Enddo
        Select HUMAN
        Skip
      Enddo
    Else   // between(pi1, 1, 3)
      t_date1 := dtoc4( arr[ 5 ] -180 )
      t_date2 := dtoc4( arr[ 5 ] -1 )
      r_use( dir_server() + 'schet', , 'SCHET' )
      r_use( dir_server() + 'human_', , 'HUMAN_' )
      r_use( dir_server() + 'human', dir_server() + 'humank', 'HUMAN' )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server() + 'mo_hu', { dir_server() + 'mo_huk', ;
        dir_server() + 'mo_hu' }, 'HU' )
      For xx := 1 To Len( arr_usl )
        If k == 6
          tmp->( dbGoto( arr_usl[ xx, 2 ] ) )
          lrec := tmp->( RecNo() )
        Endif
        Do Case
        Case pi1 == 1  // по дате оказания услуги
          pole_kol := 'hu->kol_1'
          Select HU
          find ( Str( arr_usl[ xx, 1 ], 6 ) )
          Do While hu->u_kod == arr_usl[ xx, 1 ] .and. !Eof()
            updatestatus()
            If Inkey() == K_ESC
              fl_exit := .t.
              Exit
            Endif
            Select HUMAN
            find ( Str( hu->kod, 7 ) )
            If human_->oplata < 9 .and. Between( hu->date_u, begin_date, end_date )
              If k == 6
                obf3_statist( k, arr_otd, serv_arr )
              Elseif eq_any( k, 8, 14 )
                obf5_statist( k, arr_otd, serv_arr )
              Endif
            Endif
            Select HU
            Skip
          Enddo
        Case Between( pi1, 2, 3 )  // по дате выписки счета и окончания лечения
          pole_kol := 'hu->kol_1'
          Select HU
          find ( Str( arr_usl[ xx, 1 ], 6 ) )
          Do While hu->u_kod == arr_usl[ xx, 1 ] .and. !Eof()
            updatestatus()
            If Inkey() == K_ESC
              fl_exit := .t.
              Exit
            Endif
            Select HUMAN
            find ( Str( hu->kod, 7 ) )
            fl := .f.
            If human_->oplata < 9
              If pi1 == 2
                If human->schet > 0 // .and. human->cena_1 > 0
                  Select SCHET
                  Goto ( human->schet )
                  fl := Between( schet->pdate, begin_date, end_date )
                Endif
              Else // pi1 == 3
                fl := Between( human->k_data, arr_m[ 5 ], arr_m[ 6 ] )
                fl := func_pi_schet( fl )
              Endif
            Endif
            If fl
              If k == 6
                obf3_statist( k, arr_otd, serv_arr )
              Elseif eq_any( k, 8, 14 )
                obf5_statist( k, arr_otd, serv_arr )
              Endif
            Endif
            Select HU
            Skip
          Enddo
        Endcase
        If fl_exit
          Exit
        Endif
      Next
    Endif
  Else
    Do Case
    Case pi1 == 1  // по дате оказания услуги
      pole_kol := 'hu->kol_1'
      r_use( dir_server() + 'human_', , 'HUMAN_' )
      r_use( dir_server() + 'human', , 'HUMAN' )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server() + 'mo_hu', dir_server() + 'mo_hud', 'HU' )
      Set Relation To kod into HUMAN
      Select HU
      dbSeek( begin_date, .t. )
      Do While hu->date_u <= end_date .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t.
          Exit
        Endif
        If human_->oplata < 9 .and. iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
          obf3_statist( k, arr_otd, serv_arr )
        Endif
        Select HU
        Skip
      Enddo
      Select HU
      Set Relation To
    Case pi1 == 2  // по дате выписки счета
      pole_kol := 'hu->kol_1'
      r_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'HU' )
      r_use( dir_server() + 'human_', , 'HUMAN_' )
      r_use( dir_server() + 'human', dir_server() + 'humans', 'HUMAN' )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server() + 'schet', dir_server() + 'schetd', 'SCHET' )
      Set Filter To !eq_any( mest_inog, 6, 7 )
      dbSeek( begin_date, .t. )
      Do While schet->pdate <= end_date .and. !Eof()
        Select HUMAN
        find ( Str( schet->kod, 6 ) )
        Do While human->schet == schet->kod .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t.
            Exit
          Endif
          If human_->oplata < 9
            Select HU
            find ( Str( human->kod, 7 ) )
            Do While hu->kod == human->kod .and. !Eof()
              If iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
                obf3_statist( k, arr_otd, serv_arr )
              Endif
              Select HU
              Skip
            Enddo
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
    Case pi1 == 3  // по дате окончания лечения
      pole_kol := 'hu->kol_1'
      r_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'HU' )
      r_use( dir_server() + 'human_', , 'HUMAN_' )
      r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
      Set Relation To RecNo() into HUMAN_
      dbSeek( DToS( arr_m[ 5 ] ), .t. )
      Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t.
          Exit
        Endif
        If human_->oplata < 9 .and. func_pi_schet( .t. )
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            If iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
              obf3_statist( k, arr_otd, serv_arr )
            Endif
            Select HU
            Skip
          Enddo
        Endif
        Select HUMAN
        Skip
      Enddo
    Case pi1 == 4  // по невыписанным счетам
      pole_kol := 'hu->kol_1'
      r_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'HU' )
      r_use( dir_server() + 'human_', , 'HUMAN_' )
      r_use( dir_server() + 'human', dir_server() + 'humann', 'HUMAN' )
      Set Relation To RecNo() into HUMAN_
      dbSeek( '1', .t. )
      Do While human->tip_h < B_SCHET .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t.
          Exit
        Endif
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          If iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
            obf3_statist( k, arr_otd, serv_arr )
          Endif
          Select HU
          Skip
        Enddo
        Select HUMAN
        Skip
      Enddo
    Endcase
  Endif
  j := tmp->( LastRec() )
  Close databases
  If fl_exit
    Return Nil
  Endif
  If j == 0
    func_error( 4, 'Нет сведений!' )
  Else
    mywait()
    fl_kol1 := .f.
    If eq_any( k, 8, 9, 13, 14 )
      arr_title := { ;
        '─────────────────────────┬─────┬────────╥───────────────┬────────╥──────────', ;
        '                         │ Кол.│  Дата  ║               │  Дата  ║          ', ;
        '         Ф.И.О.          │услуг│окон.леч║  Номер счета  │  счета ║Примечание', ;
        '─────────────────────────┴─────┴────────╨───────────────┴────────╨──────────' }
      r_use( dir_server() + 'human_', , 'HUMAN_' )
      r_use( dir_server() + 'human', dir_server() + 'humank', 'HUMAN' )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server() + 'schet_', , 'SCHET_' )
      r_use( dir_server() + 'schet', , 'SCHET' )
      Set Relation To RecNo() into SCHET_
    Else
      len_n := sh -8
      If ( fl_kol1 := eq_any( k, 2, 4, 5, 7 ) )
        len_n -= 8
      Endif
      fl_uet := .f.
      If AScan( ret_mz_rf, {| x| x[ 2 ] == 3 } ) > 0
        fl_uet := .t.
        len_n -= 9
      Endif
      arr_title := Array( 4 )
      arr_title[ 1 ] := Replicate( '─', len_n )
      arr_title[ 2 ] := Space( len_n )
      arr_title[ 3 ] := Space( len_n )
      arr_title[ 4 ] := Replicate( '─', len_n )
      If fl_uet
        arr_title[ 1 ] += '┬────────'
        arr_title[ 2 ] += '│        '
        arr_title[ 3 ] += '│ У.Е.Т. '
        arr_title[ 4 ] += '┴────────'
      Endif
      If fl_kol1
        arr_title[ 1 ] += '┬───────┬───────'
        arr_title[ 2 ] += '│ Кол-во│ Кол-во'
        arr_title[ 3 ] += '│  врач │ ассис.'
        arr_title[ 4 ] += '┴───────┴───────'
      Else
        arr_title[ 1 ] += '┬───────'
        arr_title[ 2 ] += '│ Кол-во'
        arr_title[ 3 ] += '│ услуг '
        arr_title[ 4 ] += '┴───────'
      Endif
    Endif
    sh := Len( arr_title[ 1 ] )
    Set( _SET_DELETED, .f. )
    use_base( 'luslf' )
    r_use( dir_server() + 'mo_su', , 'USL' )
    Use ( cur_dir() + 'tmp' ) index ( cur_dir() + 'tmpk' ), ( cur_dir() + 'tmpn' ) New Alias TMP
    If !eq_any( k, 1, 8, 9 )
      r_use( dir_server() + 'mo_pers', , 'PERSO' )
      Select TMP
      Set Order To 0
      Go Top
      Do While !Eof()
        If eq_any( k, 3, 31, 4, 5, 6, 12, 13, 14 )
          Select USL
          Goto ( tmp->u_kod )
          If usl->kod <= 0 .or. Deleted() .or. Eof()
            Select TMP
            Delete
          Else
            lname := usl->name
            Select LUSLF
            find ( usl->shifr1 )
            If Found()
              lname := luslf->name
            Endif
            // else
            // select LUSLF18
            // find (usl->shifr1)
            // if found()
            // lname := luslf18->name
            // endif
            // endif
            tmp->u_shifr := usl->shifr1
            s := ''
            If !Empty( usl->shifr )
              s += '(' + AllTrim( usl->shifr ) + ')'
            Endif
            tmp->u_name := s + lname
          Endif
        Endif
        If fl_kol1
          Select PERSO
          Goto ( tmp->kod_vr_as )
          If Deleted() .or. Eof()
            Select TMP
            Delete
          Else
            tmp->fio := perso->fio
            tmp->tab_nom := perso->tab_nom
            tmp->svod_nom := perso->svod_nom
            If k == 7 .and. !Empty( perso->tab_nom ) .and. !Empty( perso->svod_nom )
              If ( i := AScan( arr_svod_nom, {| x| x[ 1 ] == perso->svod_nom .and. x[ 2 ] == tmp->vr_as } ) ) == 0
                AAdd( arr_svod_nom, { perso->svod_nom, tmp->vr_as, {} } )
                i := Len( arr_svod_nom )
              Endif
              AAdd( arr_svod_nom[ i, 3 ], tmp->( RecNo() ) )
              tmp->u_shifr := lstr( perso->svod_nom )
            Endif
          Endif
        Endif
        Select TMP
        Skip
      Enddo
      If k == 7 .and. Len( arr_svod_nom ) > 0
        Select TMP
        For i := 1 To Len( arr_svod_nom )
          pkol := pkol1 := ptrud := 0
          For j := 2 To Len( arr_svod_nom[ i, 3 ] )
            Goto ( arr_svod_nom[ i, 3, j ] )
            pkol   += tmp->KOL
            pkol1  += tmp->KOL1
            ptrud  += tmp->trudoem
            Delete
          Next
          Goto ( arr_svod_nom[ i, 3, 1 ] )
          tmp->KOL  += pkol
          tmp->KOL1 += pkol1
          ptrud  += tmp->trudoem
        Next
      Endif
    Endif
    Set( _SET_DELETED, .t. )
    fp := FCreate( cur_dir() + 'obF_stat.txt' )
    tek_stroke := 0
    n_list := 1
    add_string( PadL( 'дата печати ' + date_8( sys_date ), sh ) )
    If k == 1
      add_string( Center( 'Статистика по отделениям', sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
    Elseif k == 5
      add_string( Center( 'Статистика по оказанным услугам', sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
      If serv_arr == Nil  // по одному человеку
        add_string( Center( '"' + Upper( glob_human[ 2 ] ) + ;
          ' [' + lstr( glob_human[ 5 ] ) + ']"', sh ) )
      Endif
    Elseif eq_any( k, 6, 14 )
      add_string( Center( 'Статистика по услугам', sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
    Elseif k == 7
      add_string( Center( 'Статистика по работе персонала', sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
    Elseif k == 12
      add_string( Center( 'Статистика по всем оказанным услугам', sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
    Elseif k == 13
      add_string( Center( 'Список больных, которым были оказаны услуги врачом (ассистентом):', sh ) )
      add_string( Center( '"' + Upper( glob_human[ 2 ] ) + ;
        ' [' + lstr( glob_human[ 5 ] ) + ']"', sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
    Else
      add_string( Center( 'Статистика по отделению', sh ) )
      titlen_otd( st_a_otd, sh, lcount_otd )
      add_string( Center( '< ' + AllTrim( glob_uch[ 2 ] ) + ' >', sh ) )
      If eq_any( k, 8, 9 )
        add_string( '' )
        If k == 8
          add_string( Center( 'Список больных, которым была оказана услуга:', sh ) )
          For i := 1 To perenos( arr, '"' + musluga[ 2 ] + '"', sh )
            add_string( Center( AllTrim( arr[ i ] ), sh ) )
          Next
        Else
          add_string( Center( 'Список больных, которым были оказаны услуги врачом (ассистентом):', sh ) )
          add_string( Center( '"' + Upper( glob_human[ 2 ] ) + ' [' + lstr( glob_human[ 5 ] ) + ']"', sh ) )
        Endif
      Endif
    Endif
    s := '['
    For i := 1 To Len( ret_mz_rf )
      s += ret_mz_rf[ i, 1 ] + ', '
    Next
    s := Left( s, Len( s ) -2 ) + ']'
    add_string( Center( s, sh ) )
    add_string( '' )
    _tit_ist_fin( sh )
    If pi1 != 4
      add_string( Center( arr[ 4 ], sh ) )
      add_string( '' )
    Endif
    Do Case
    Case pi1 == 1
      s := '[ по дате оказания услуги ]'
    Case pi1 == 2
      s := '[ по дате выписки счета ]'
    Case pi1 == 3
      s := str_pi_schet()
    Case pi1 == 4
      s := '[ по больным, ещё не включенным в счет ]'
    Endcase
    add_string( Center( s, sh ) )
    add_string( '' )
    Select TMP
    Set Order To 2
    Go Top
    If eq_any( k, 8, 9, 13, 14 )
      mb := mkol := old_usl := 0
      AEval( arr_title, {| x| add_string( x ) } )
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        If eq_any( k, 13, 14 ) .and. tmp->u_kod != old_usl
          If old_usl > 0
            add_string( Replicate( '─', sh ) )
            add_string( 'Кол-во больных - ' + lstr( mb ) + ',  кол-во услуг - ' + lstr( mkol ) )
            mb := mkol := 0
          Endif
          add_string( '' )
          For i := 1 To perenos( arr, RTrim( tmp->u_shifr ) + '. ' + tmp->u_name, sh -2 )
            add_string( '│ ' + arr[ i ] )
          Next
          add_string( '└' + Replicate( '─', sh -1 ) )
        Endif
        old_usl := tmp->u_kod
        Select HUMAN
        find ( Str( tmp->kod, 7 ) )
        Select SCHET
        Goto ( human->schet )
        s := tmp->fio + put_val( tmp->kol, 6 ) + ' ' + date_8( tmp->k_data )
        If human->tip_h >= B_SCHET
          s += PadC( AllTrim( schet_->nschet ), 17 ) + date_8( c4tod( schet->pdate ) )
        Endif
        add_string( s )
        mkol += tmp->kol
        ++mb
        Select TMP
        Skip
      Enddo
      add_string( Replicate( '─', sh ) )
      add_string( 'Кол-во больных - ' + lstr( mb ) + ',  кол-во услуг - ' + lstr( mkol ) )
    Else
      pkol := pkol1 := ptrud := 0
      old_perso := tmp->kod_vr_as ; old_vr_as := tmp->vr_as
      old_fio := '[' + put_tab_nom( tmp->tab_nom, tmp->svod_nom ) + '] '
      old_fio += tmp->fio
      old_slugba := tmp->fio
      old_shifr := iif( k == 31, tmp->otd, tmp->kod_vr_as )
      If eq_any( k, 2, 5, 7 )
        old_perso := -1  // для печати Ф.И.О. в начале
      Endif
      Select TMP
      Do While !Eof()
        If k == 31 .and. old_shifr != tmp->otd
          add_string( Space( 4 ) + Replicate( '.', sh -4 ) )
          s := PadR( Space( 4 ) + old_slugba, len_n )
          If fl_uet
            s += umest_val( ptrud, 9, 2 )
          Endif
          add_string( s + put_val( pkol, 8, 0 ) )
          add_string( Replicate( '─', sh ) )
          pkol := pkol1 := ptrud := 0
        Endif
        If k == 4 .and. !( old_perso == tmp->kod_vr_as .and. old_vr_as == tmp->vr_as )
          add_string( Space( 4 ) + Replicate( '.', sh -4 ) )
          s := PadR( Space( 4 ) + old_fio, len_n )
          If fl_uet
            s += umest_val( ptrud, 9, 2 )
          Endif
          add_string( s + put_val( pkol, 8, 0 ) + put_val( pkol1, 8, 0 ) )
          add_string( Replicate( '─', sh ) )
          pkol := pkol1 := ptrud := 0
        Endif
        If fl_1_list .or. verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
          fl_1_list := .f.
        Endif
        If k == 4
          pkol += tmp->kol
          pkol1 += tmp->kol1
          ptrud += tmp->trudoem
          skol[ tmp->vr_as ] += tmp->kol
          skol1[ tmp->vr_as ] += tmp->kol1
          strud[ tmp->vr_as ] += tmp->trudoem
          s := RTrim( tmp->u_shifr ) + ' ' + AllTrim( tmp->u_name )
          If Len( s ) > len_n
            j := perenos( arr, s, len_n )
            s := PadR( arr[ 1 ], len_n )
            If fl_uet
              s += umest_val( tmp->trudoem, 9, 2 )
            Endif
            add_string( s + put_val( tmp->kol, 8, 0 ) + put_val( tmp->kol1, 8, 0 ) )
            For i := 2 To j
              add_string( PadL( AllTrim( arr[ i ] ), len_n + 1 ) )
            Next
          Else
            s := PadR( s, len_n )
            If fl_uet
              s += umest_val( tmp->trudoem, 9, 2 )
            Endif
            add_string( s + put_val( tmp->kol, 8, 0 ) + put_val( tmp->kol1, 8, 0 ) )
          Endif
          old_perso := tmp->kod_vr_as
          old_vr_as := tmp->vr_as
          old_fio := '[' + put_tab_nom( tmp->tab_nom, tmp->svod_nom ) + '] ' + tmp->fio
        Else
          Do Case
          Case k == 31
            skol[ 1 ] += tmp->kol
            skol1[ 1 ] += tmp->kol1
            strud[ 1 ] += tmp->trudoem
            pkol += tmp->kol
            pkol1 += tmp->kol1
            ptrud += tmp->trudoem
            old_slugba := tmp->fio
            old_shifr := tmp->otd
            j := perenos( arr, RTrim( tmp->u_shifr ) + ' ' + AllTrim( tmp->u_name ), len_n )
            s := PadR( arr[ 1 ], len_n )
          Case k == 1
            s := PadR( tmp->fio, len_n )
            skol[ 1 ] += tmp->kol
            skol1[ 1 ] += tmp->kol1
            strud[ 1 ] += tmp->trudoem
          Case eq_any( k, 2, 7 )
            If Empty( tmp->u_shifr )
              s := '[' + put_tab_nom( tmp->tab_nom, tmp->svod_nom ) + ']'
              If Len( s ) < 8
                s := PadR( s, 8 )
              Endif
            Else
              s := PadR( '[+' + AllTrim( tmp->u_shifr ) + ']', 8 )
            Endif
            If old_perso == tmp->kod_vr_as
              s := ''
            Else
              s += tmp->fio
            Endif
            s := PadR( s, len_n )
            skol[ tmp->vr_as ] += tmp->kol
            skol1[ tmp->vr_as ] += tmp->kol1
            strud[ 1 ] += tmp->trudoem
            old_perso := tmp->kod_vr_as
          Case eq_any( k, 3, 6, 12 )
            j := perenos( arr, RTrim( tmp->u_shifr ) + ' ' + AllTrim( tmp->u_name ), len_n )
            s := PadR( arr[ 1 ], len_n )
            skol[ 1 ] += tmp->kol
            skol1[ 1 ] += tmp->kol1
            strud[ 1 ] += tmp->trudoem
          Case k == 5
            If serv_arr != Nil .and. old_perso != tmp->kod_vr_as
              If old_perso > 0
                add_string( Replicate( '─', sh ) )
                fl := .f.
                If !emptyall( skol[ 1 ], skol1[ 1 ] )
                  fl := .t.
                  s := PadL( 'И Т О Г О :  ', len_n )
                  If fl_uet
                    s += umest_val( strud[ 1 ], 9, 2 )
                  Endif
                  add_string( s + put_val( skol[ 1 ], 8, 0 ) + put_val( skol1[ 1 ], 8, 0 ) )
                Endif
                AFill( skol, 0 )
                AFill( skol1, 0 )
                AFill( strud, 0 )
              Endif
              add_string( '' )
              add_string( Space( 5 ) + put_tab_nom( tmp->tab_nom, tmp->svod_nom ) + '. ' + Upper( RTrim( tmp->fio ) ) )
            Endif
            j := perenos( arr, RTrim( tmp->u_shifr ) + ' ' + AllTrim( tmp->u_name ), len_n )
            s := PadR( arr[ 1 ], len_n )
            skol[ tmp->vr_as ] += tmp->kol
            skol1[ tmp->vr_as ] += tmp->kol1
            strud[ 1 ] += tmp->trudoem
            old_perso := tmp->kod_vr_as
          Endcase
          If fl_uet
            s += umest_val( tmp->trudoem, 9, 2 )
          Endif
          add_string( s + put_val( tmp->kol, 8, 0 ) + iif( fl_kol1, put_val( tmp->kol1, 8, 0 ), '' ) )
          If eq_any( k, 3, 31, 5, 6, 12 ) .and. j > 1
            For i := 2 To j
              add_string( PadL( AllTrim( arr[ i ] ), len_n + 1 ) )
            Next
          Endif
        Endif
        Select TMP
        Skip
      Enddo
      If k == 31
        add_string( Space( 4 ) + Replicate( '.', sh -4 ) )
        s := PadR( Space( 4 ) + old_slugba, len_n )
        If fl_uet
          s += umest_val( ptrud, 9, 2 )
        Endif
        add_string( s + put_val( pkol, 8, 0 ) )
        add_string( '' )
      Endif
      If k == 4
        add_string( Space( 4 ) + Replicate( '.', sh -4 ) )
        s := PadR( Space( 4 ) + old_fio, len_n )
        If fl_uet
          s += umest_val( ptrud, 9, 2 )
        Endif
        add_string( s + put_val( pkol, 8, 0 ) + put_val( pkol1, 8, 0 ) )
        add_string( '' )
      Endif
      add_string( Replicate( '─', sh ) )
      fl := .f.
      If !emptyall( skol[ 1 ], skol1[ 1 ] )
        fl := .t.
        s := PadL( 'И Т О Г О :  ', len_n )
        If fl_uet
          s += umest_val( strud[ 1 ], 9, 2 )
        Endif
        add_string( s + put_val( skol[ 1 ], 8, 0 ) + iif( fl_kol1, put_val( skol1[ 1 ], 8, 0 ), '' ) )
      Endif
    Endif
    FClose( fp )
    Close databases
    viewtext( cur_dir() + 'obF_stat.txt', , , , ( sh > 80 ), , , regim )
  Endif
  Return Nil

// 27.05.23
Function _f_trud_f( lu_kod, lkol, lvzros_reb, lkod_vr, lkod_as )

  Local mtrud := { 0, 0, 0 }

  Select USL
  Goto ( lu_kod )
  If !Eof() .and. !Empty( usl->shifr1 )
    If Year( human->k_data ) > 2018
      Select LUSLF
      find ( usl->shifr1 )
      mtrud[ 1 ] := mtrud[ 2 ] := mtrud[ 3 ] := round_5( lkol * iif( lvzros_reb == 0, luslf->uetv, luslf->uetd ), 2 )
    Endif
    // else
    // select LUSLF18
    // find (usl->shifr1)
    // mtrud[1] := mtrud[2] := mtrud[3] := round_5(lkol * iif(lvzros_reb == 0, luslf18->uetv, luslf18->uetd), 2)
    // endif
    If lkod_vr > 0 .and. lkod_as == 0
      mtrud[ 3 ] := 0
      mtrud[ 2 ] := mtrud[ 1 ]
    Elseif lkod_vr == 0 .and. lkod_as > 0
      mtrud[ 2 ] := 0
      mtrud[ 3 ] := mtrud[ 1 ]
    Endif
  Endif
  Return mtrud

// 30.08.16
Static Function obf3_statist( k, arr_otd, serv_arr, mkod_perso )

  Local i, j, k1 := 1, s1 := '1', mtrud := { 0, 0, 0 }

  If !_f_ist_fin()
    Return Nil
  Endif
  If AScan( ret_mz_rf, {| x| x[ 2 ] == human_->USL_OK } ) == 0
    Return Nil
  Endif
  If hu->u_kod > 0 .and. &pole_kol > 0 .and. ( i := AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) ) > 0
    mtrud := _f_trud_f( hu->u_kod, &pole_kol, human->vzros_reb, hu->kod_vr, hu->kod_as )
    Select TMP
    Do Case
    Case k == 1
      find ( Str( hu->otd, 3 ) )
      If !Found()
        Append Blank
        tmp->otd := arr_otd[ i, 1 ]
        tmp->fio := arr_otd[ i, 2 ]
        If ( j := AScan( st_a_uch, {| x| x[ 1 ] == arr_otd[ i, 3 ] } ) ) > 0
          tmp->u_kod := arr_otd[ i, 3 ]   // код ЛПУ
          tmp->fio := PadR( arr_otd[ i, 2 ], 31 ) + st_a_uch[ j, 2 ]
        Endif
      Endif
      tmp->kol += &pole_kol
      tmp->trudoem += mtrud[ 1 ]
    Case eq_any( k, 2, 7 )
      If hu->kod_vr > 0
        find ( '1' + Str( hu->kod_vr, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := 1
          tmp->kod_vr_as := hu->kod_vr
        Endif
        tmp->kol += &pole_kol
        tmp->trudoem += mtrud[ 2 ]
      Endif
      If hu->kod_as > 0
        find ( s1 + Str( hu->kod_as, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := k1
          tmp->kod_vr_as := hu->kod_as
        Endif
        tmp->kol1 += &pole_kol
        tmp->trudoem += mtrud[ 3 ]
      Endif
    Case eq_any( k, 3, 31, 6 )
      If k == 31
        find ( Str( hu->otd, 3 ) + Str( hu->u_kod, 6 ) )
      Else
        find ( Str( hu->u_kod, 6 ) )
      Endif
      If !Found()
        Append Blank
        If k == 31
          tmp->otd := arr_otd[ i, 1 ]
          tmp->fio := arr_otd[ i, 2 ]
          If ( j := AScan( st_a_uch, {| x| x[ 1 ] == arr_otd[ i, 3 ] } ) ) > 0
            tmp->fio := AllTrim( tmp->fio ) + ' [' + AllTrim( st_a_uch[ j, 2 ] ) + ']'
          Endif
        Endif
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol += &pole_kol
      tmp->trudoem += mtrud[ 1 ]
    Case k == 4
      If hu->kod_vr > 0
        find ( '1' + Str( hu->kod_vr, 4 ) + Str( hu->u_kod, 6 ) )
        If !Found()
          Append Blank
          tmp->vr_as := 1
          tmp->kod_vr_as := hu->kod_vr
          tmp->u_kod := hu->u_kod
        Endif
        tmp->kol += &pole_kol
        tmp->trudoem += mtrud[ 2 ]
      Endif
      If hu->kod_as > 0
        find ( s1 + Str( hu->kod_as, 4 ) + Str( hu->u_kod, 6 ) )
        If !Found()
          Append Blank
          tmp->vr_as := k1
          tmp->kod_vr_as := hu->kod_as
          tmp->u_kod := hu->u_kod
        Endif
        tmp->kol1 += &pole_kol
        tmp->trudoem += mtrud[ 3 ]
      Endif
    Case k == 5
      If hu->kod_vr == mkod_perso
        find ( '1' + Str( mkod_perso, 4 ) + Str( hu->u_kod, 6 ) )
        If !Found()
          Append Blank
          tmp->vr_as := 1
          tmp->kod_vr_as := mkod_perso
          tmp->u_kod := hu->u_kod
        Endif
        tmp->kol += &pole_kol
        tmp->trudoem += mtrud[ 2 ]
      Endif
      If hu->kod_as == mkod_perso
        find ( s1 + Str( mkod_perso, 4 ) + Str( hu->u_kod, 6 ) )
        If !Found()
          Append Blank
          tmp->vr_as := k1
          tmp->kod_vr_as := mkod_perso
          tmp->u_kod := hu->u_kod
        Endif
        tmp->kol1 += &pole_kol
        tmp->trudoem += mtrud[ 3 ]
      Endif
    Case k == 12  // все услуги
      Select USL
      Goto ( hu->u_kod )
      If !Eof()
        Select TMP
        find ( Str( hu->u_kod, 6 ) )
        If !Found()
          Append Blank
          tmp->u_kod := usl->kod
        Endif
        tmp->kol += &pole_kol
        tmp->trudoem += mtrud[ 1 ]
      Endif
    Endcase
  Endif
  Return Nil

// 30.08.16
Static Function obf4_statist( k, arr_otd, i, mkol, serv_arr, mkod_perso )

  Local j, k1 := 1, s1 := '1', mtrud := { 0, 0, 0 }

  If !_f_ist_fin()
    Return Nil
  Endif
  If AScan( ret_mz_rf, {| x| x[ 2 ] == human_->USL_OK } ) == 0
    Return Nil
  Endif
  mtrud := _f_trud_f( hu->u_kod, mkol, human->vzros_reb, hu->kod_vr, hu->kod_as )
  Select TMP
  Do Case
  Case k == 1
    find ( Str( hu->otd, 3 ) )
    If !Found()
      Append Blank
      tmp->otd := arr_otd[ i, 1 ]
      tmp->fio := arr_otd[ i, 2 ]
      If ( j := AScan( st_a_uch, {| x| x[ 1 ] == arr_otd[ i, 3 ] } ) ) > 0
        tmp->u_kod := arr_otd[ i, 3 ]  // код ЛПУ
        tmp->fio := PadR( arr_otd[ i, 2 ], 31 ) + st_a_uch[ j, 2 ]
      Endif
    Endif
    tmp->kol += mkol
    tmp->trudoem += mtrud[ 1 ]
  Case eq_any( k, 2, 7 )
    If hu->kod_vr > 0
      find ( '1' + Str( hu->kod_vr, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := 1
        tmp->kod_vr_as := hu->kod_vr
      Endif
      tmp->kol += mkol
      tmp->trudoem += mtrud[ 2 ]
    Endif
    If hu->kod_as > 0
      find ( s1 + Str( hu->kod_as, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := k1
        tmp->kod_vr_as := hu->kod_as
      Endif
      tmp->kol1 += mkol
      tmp->trudoem += mtrud[ 3 ]
    Endif
  Case eq_any( k, 3, 6 )
    find ( Str( hu->u_kod, 6 ) )
    If !Found()
      Append Blank
      tmp->u_kod := hu->u_kod
    Endif
    tmp->kol += mkol
    tmp->trudoem += mtrud[ 1 ]
  Case k == 4
    If hu->kod_vr > 0
      find ( '1' + Str( hu->kod_vr, 4 ) + Str( hu->u_kod, 6 ) )
      If !Found()
        Append Blank
        tmp->vr_as := 1
        tmp->kod_vr_as := hu->kod_vr
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol += mkol
      tmp->trudoem += mtrud[ 2 ]
    Endif
    If hu->kod_as > 0
      find ( s1 + Str( hu->kod_as, 4 ) + Str( hu->u_kod, 6 ) )
      If !Found()
        Append Blank
        tmp->vr_as := k1
        tmp->kod_vr_as := hu->kod_as
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol1 += mkol
      tmp->trudoem += mtrud[ 3 ]
    Endif
  Case k == 5
    If hu->kod_vr == mkod_perso
      find ( '1' + Str( mkod_perso, 4 ) + Str( hu->u_kod, 6 ) )
      If !Found()
        Append Blank
        tmp->vr_as := 1
        tmp->kod_vr_as := mkod_perso
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol += mkol
      tmp->trudoem += mtrud[ 2 ]
    Endif
    If hu->kod_as == mkod_perso
      find ( s1 + Str( mkod_perso, 4 ) + Str( hu->u_kod, 6 ) )
      If !Found()
        Append Blank
        tmp->vr_as := k1
        tmp->kod_vr_as := mkod_perso
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol1 += mkol
      tmp->trudoem += mtrud[ 3 ]
    Endif
  Case k == 12  // все услуги
    Select USL
    Goto ( hu->u_kod )
    If !Eof()
      Select TMP
      find ( Str( hu->u_kod, 6 ) )
      If !Found()
        Append Blank
        tmp->u_kod := usl->kod
      Endif
      tmp->kol += mkol
      tmp->trudoem += mtrud[ 1 ]
    Endif
  Endcase
  Return Nil

// 30.08.16
Static Function obf5_statist( k, arr_otd, serv_arr, mkol )

  If !_f_ist_fin()
    Return Nil
  Endif
  If AScan( ret_mz_rf, {| x| x[ 2 ] == human_->USL_OK } ) == 0
    Return Nil
  Endif
  If arr_otd != Nil .and. AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) == 0
    Return Nil
  Endif
  Select TMP
  If eq_any( k, 13, 14 )
    find ( Str( hu->u_kod, 6 ) + Str( human->kod, 7 ) )
  Else
    find ( Str( human->kod, 7 ) )
  Endif
  If !Found()
    Append Blank
    If eq_any( k, 13, 14 )
      tmp->u_kod := hu->u_kod
    Endif
    tmp->kod := human->kod
    tmp->fio := fam_i_o( human->fio )
    tmp->k_data := human->k_data
  Endif
  Default mkol TO &pole_kol
  tmp->kol += mkol
  Return Nil

// 27.03.18
Function obf2_v_usl( is_get, r1, mtitul, name_tmp )

  Local t_arr[ BR_LEN ], buf := SaveScreen(), k, ret

  Default is_get To .f., r1 To T_ROW, name_tmp To 'tmp'
  If r1 > 14
    r1 := 14
  Endif
  r_use( dir_server() + 'mo_su', { dir_server() + 'mo_sush', ;
    dir_server() + 'mo_sush1' }, 'USL' )
  Use ( cur_dir() + name_tmp ) index ( cur_dir() + name_tmp + 'k' ), ( cur_dir() + name_tmp + 'n' ) New Alias TMP
  Set Order To 2
  t_arr[ BR_TOP ] := r1
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitul
  t_arr[ BR_TITUL_COLOR ] := 'B/BG'
  t_arr[ BR_OPEN ] := {|| !Eof() }
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', , .t. }
  t_arr[ BR_COLUMN ] := { { PadC(  'Шифр', 20 ), {|| tmp->u_shifr } }, ;
    { Center( 'Наименование услуги', 57 ), {|| Left( tmp->u_name, 57 ) } } }
  t_arr[ BR_STAT_MSG ] := {|| ;
    status_key( '^<Esc>^ выход;  ^<Ins>^ добавление;  ^<Del>^ удаление услуги;  ^<F9>^ печать списка' ) }
  t_arr[ BR_EDIT ] := {| nk, ob| obf21v_usl( nk, ob, 'edit', mtitul ) }
  edit_browse( t_arr )
  If is_get
    Go Top
    k := 0
    dbEval( {|| iif( tmp->u_kod > 0, ++k, nil ) } )
    ret := { k, 'Кол-во услуг - ' + lstr( k ) }
  Endif
  tmp->( dbCloseArea() )
  usl->( dbCloseArea() )
  RestScreen( buf )
  If !is_get
    waitstatus( '<Esc> - прервать поиск' )
    mark_keys( { '<Esc>' } )
  Endif
  Return ret

// 12.03.14
Function obf21v_usl( nKey, oBrow, regim, mtitul )

  Local ret := -1, s
  Local buf, fl := .f., rec, rec1, k := 19, tmp_color, n_file, sh := 81, HH := 60

  Do Case
  Case regim == 'edit'
    Do Case
    Case nKey == K_F9
      Default mtitul To 'Список выбранных услуг'
      buf := save_row( MaxRow() )
      mywait()
      rec := RecNo()
      Private reg_print := 2
      n_file := cur_dir() + 'obF2v_us.txt'
      fp := FCreate( n_file )
      n_list := 1
      tek_stroke := 0
      add_string( '' )
      add_string( Center( mtitul, sh ) )
      add_string( '' )
      Go Top
      Do While !Eof()
        verify_ff( HH, .t., sh )
        add_string( RTrim( tmp->u_shifr ) + ' ' + AllTrim( tmp->u_name ) )
        Skip
      Enddo
      Goto ( rec )
      FClose( fp )
      rest_box( buf )
      viewtext( n_file, , , , ( .t. ), , , reg_print )
    Case nKey == K_INS
      Save Screen To buf
      Private mshifr := Space( 20 )
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, pc1 + 1, 21, pc2 -1, , 'Добавление услуги', cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 25 Say 'Шифр услуги' Get mshifr Picture '@!' Valid valid_shifr()
      status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
      myread()
      If LastKey() != K_ESC .and. !Empty( mshifr )
        If '*' == AllTrim( mshifr )
          func_error( 4, 'Воспользуйтесь режимом "Все услуги"!' )
        Elseif '*' $ mshifr .or. '?' $ mshifr
          mshifr := AllTrim( mshifr )
          mywait()
          Select USL
          Set Order To 1
          Go Top
          Do While !Eof()
            If Like( mshifr, usl->shifr ) .or. Like( mshifr, usl->shifr1 )
              Select TMP
              Set Order To 1
              fl_found := fl := .t.
              addrec( 6 )
              ret := 0
              s := iif( Empty( usl->shifr ), '', '(' + AllTrim( usl->shifr ) + ') ' )
              Replace tmp->u_shifr With usl->shifr1, ;
                tmp->u_name With s + usl->name, ;
                tmp->u_kod With usl->kod
            Endif
            Select USL
            Skip
          Enddo
          Select TMP
          Set Order To 2
          If fl
            oBrow:gotop()
          Else
            func_error( 4, 'Не найдено услуг по шаблону <' + mshifr + '>.' )
          Endif
        Else
          fl := .f.
          Select USL
          If Len( AllTrim( mshifr ) ) <= 10
            Set Order To 1
            find ( PadR( mshifr, 10 ) )
            fl := Found()
          Endif
          If !fl
            Set Order To 2
            find ( PadR( mshifr, 20 ) )
            fl := Found()
          Endif
          Select TMP
          If fl
            Set Order To 1
            fl_found := .t.
            addrec( 6 )
            rec := RecNo()
            s := iif( Empty( usl->shifr ), '', '(' + AllTrim( usl->shifr ) + ') ' )
            Replace tmp->u_shifr With usl->shifr1, ;
              tmp->u_name With s + usl->name, ;
              tmp->u_kod With usl->kod
            Set Order To 2
            oBrow:gotop()
            Goto ( rec )
            ret := 0
          Else
            func_error( 4, 'Услуги с данным шифром нет в справочнике!' )
          Endif
        Endif
      Endif
      If !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. !Empty( tmp->u_kod )
      rec1 := 0
      rec := RecNo()
      Skip
      If !Eof()
        rec1 := RecNo()
      Endif
      Goto ( rec )
      deleterec()
      If rec1 == 0
        oBrow:gobottom()
      Else
        Goto ( rec1 )
      Endif
      ret := 0
      If Eof()
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

// 14.10.24
Function input_fusluga()

  Local ar, musl, arr_usl, buf, fl, s
  Local sbase

  ar := getinisect( tmp_ini, 'Fuslugi' )
  musl := PadR( a2default( ar, 'shifr' ), 20 )
  If ( musl := input_value( 18, 6, 20, 73, color1, Space( 13 ) + 'Введите шифр услуги', musl, '@K@!' ) ) != Nil .and. !Empty( musl )
    buf := save_maxrow()
    mywait()
    musl := transform_shifr( musl )
    setinisect( tmp_ini, 'Fuslugi', { { 'shifr', musl } } )
    r_use( dir_server() + 'mo_su', { dir_server() + 'mo_sush', ;
      dir_server() + 'mo_sush1' }, 'USL' )
    fl := .f.
    Select USL
    If Len( AllTrim( musl ) ) <= 10
      Set Order To 1
      find ( PadR( musl, 10 ) )
      fl := Found()
    Endif
    If !fl
      Set Order To 2
      find ( PadR( musl, 20 ) )
      fl := Found()
    Endif
    If fl
      s := iif( Empty( usl->shifr ), '', '(' + AllTrim( usl->shifr ) + ') ' )
      sbase := prefixfilerefname( WORK_YEAR ) + 'uslf'
      r_use( dir_exe() + sbase, cur_dir() + sbase, 'luslf' )
      find ( usl->shifr1 )
      arr_usl := { usl->kod, AllTrim( usl->shifr1 ) + '. ' + s + AllTrim( luslf->name ), usl->shifr1 }
      luslf->( dbCloseArea() )
    Else
      func_error( 4, 'Услуга с шифром ' + AllTrim( musl ) + ' не найдена в нашем справочнике!' )
    Endif
    usl->( dbCloseArea() )
    rest_box( buf )
  Endif
  Return arr_usl
