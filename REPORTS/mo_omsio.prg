// mo_omsio.prg - информация по ОМС (объём работ)
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch := 1
Static lcount_otd := 1

//
Function func_pi_schet( fl, al )

  Default fl To .t., al To "human"
  If fl .and. pi_schet > 1
    If pi_schet == 2
      fl := &al.->schet > 0
    Elseif pi_schet == 3
      fl := &al.->schet <= 0
    Endif
  Endif

  Return fl

//  
Function str_pi_schet()

  Local s := "[ по дате окончания лечения"

  If pi_schet == 2
    s += ", попавшие в счета"
  Elseif pi_schet == 3
    s += ", не попавшие в счета"
  Endif
  s += " ]"
  Return s

// 13.03.14
Function ob2_statist( k, serv_arr )

  Local i, j, arr[ 2 ], begin_date, end_date, bk := 1, ek := 99, al, ;
    fl_exit := .f., sh := 80, HH := 57, regim := 2, s, fl_1_list := .t., ;
    len_n, pkol, ptrud, pstoim, old_perso, old_vr_as, old_usl, ;
    old_fio, arr_otd := {}, md, mkol, mstoim, arr_kd := {}, len_kd := 0, ;
    xx, yy, pole_va, lrec, t_date1, t_date2, arr_title, msum, msum_opl, ;
    musluga, mperso := {}, mkod_perso, arr_usl := {}, adbf1, adbf2, ;
    arr_svod_nom := {}, arr_m, lshifr1
  Private is_all := .t.
  Private skol := { 0, 0 }, strud := { 0, 0 }, sstoim := { 0, 0 }

  If eq_any( k, 2, 3, 4, 8, 9, 110, 111 )  // по отделению
    If ( st_a_otd := inputn_otd( T_ROW, T_COL - 5, .f., .f.,, @lcount_otd ) ) == NIL
      Return Nil
    Endif
    AEval( st_a_otd, {| x| AAdd( arr_otd, x ) } )
    If k == 8 .and. ( musluga := input_usluga() ) == NIL
      Return Nil
    Endif
    If k == 9 .and. !input_perso( T_ROW, T_COL - 5, .f. )
      Return Nil
    Endif
  Else  // по учреждению(ям)
    If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
      Return Nil
    Endif
    r_use( dir_server + "mo_otd",, "OTD" )
    dbEval( {|| AAdd( arr_otd, { otd->( RecNo() ), otd->name, otd->kod_lpu } ) }, ;
      {|| f_is_uch( st_a_uch, otd->kod_lpu ) } )
    OTD->( dbCloseArea() )
    If ( ( k == 5 .and. serv_arr == NIL ) .or. k == 13 ) .and. !input_perso( T_ROW, T_COL - 5, .f. )
      Return Nil
    Endif
  Endif
  //
  If eq_any( k, 3, 31, 4, 13 )
    If ( xx := popup_prompt( T_ROW, T_COL - 5, 1, { "Все ~услуги", "~Список услуг" } ) ) == 0
      Return Nil
    Endif
    is_all := ( xx == 1 )
  Endif
  //
  Private fl_plan := .f., fl7_plan := .f., fl5_plan := .f., ym_kol_mes := 1
  arr_m := { Year( sys_date ), Month( sys_date ),,, sys_date, sys_date,, }
  If pi1 != 4
    If ( arr := year_month() ) == NIL
      Return Nil
    Endif
    begin_date := arr[ 7 ]
    end_date := arr[ 8 ]
    arr_m := AClone( arr )
  Endif
  If mem_trudoem == 2 .and. mem_tr_plan == 2 .and. eq_any( k, 5, 7 ) .and. ym_kol_mes > 0
    fl_plan := .t.
    If k == 5
      fl5_plan := .t.
    Endif
    If k == 7
      fl7_plan := .t.
    Endif
  Endif
  If k == 5 .and. serv_arr != NIL
    If serv_arr[ 1 ] == 1  // N человек
      If ( mperso := input_kperso() ) == NIL
        Return Nil
      Endif
    Elseif serv_arr[ 1 ] == 2  // весь персонал
      mywait()
      mperso := {}
      r_use( dir_server + "human_u", { dir_server + "human_uv", ;
        dir_server + "human_ua" }, "HU" )
      r_use( dir_server + "mo_pers",, "P2" )
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
            AAdd( mperso, { p2->kod, "" } )
          Endif
        Endif
        Select P2
        Skip
      Enddo
      hu->( dbCloseArea() )
      p2->( dbCloseArea() )
    Endif
  Endif
  If !fbp_ist_fin( T_ROW, T_COL - 5 )
    Return Nil
  Endif
  adbf1 := { ;
    { "U_KOD",    "N",      4,      0 }, ;  // код услуги
    { "U_SHIFR",    "C",     10,      0 }, ;  // шифр услуги
    { "U_NAME",     "C",    255,      0 }, ;  // наименование услуги
    { "FIO",        "C",     25,      0 }, ;  // ФИО больного
    { "KOD",        "N",      7,      0 }, ;  // код больного
    { "K_DATA",     "D",      8,      0 }, ;  // дата окончания лечения
    { "KOL",    "N",      5,      0 }, ;  // количество услуг
    { "STOIM",      "N",     20,      4 };   // стоимость услуг
  }
  adbf2 := { ;
    { "otd",        "N",      3,      0 }, ;  // отделение, где оказана услуга
    { "U_KOD",    "N",      4,      0 }, ;  // код услуги
    { "U_SHIFR",    "C",     10,      0 }, ;  // шифр услуги
    { "U_NAME",     "C",    255,      0 }, ;  // наименование услуги
    { "VR_AS",      "N",      1,      0 }, ;  // врач - 1 ; ассистент - 2
    { "TAB_NOM",    "N",      5,      0 }, ;  // таб.номер врача (ассистента)
    { "SVOD_NOM",   "N",      5,      0 }, ;  // сводный таб.номер
    { "KOD_VR_AS",  "N",      4,      0 }, ;  // код врача (ассистента)
    { "FIO",        "C",     60,      0 }, ;  // Ф.И.О. врача (ассистента)
    { "KOD_AS",    "N",      4,      0 }, ;  // код ассистента
    { "TRUDOEM",    "N",     13,      4 }, ;  // трудоемкость услуг УЕТ
    { "KOL",    "N",      6,      0 }, ;  // количество услуг
    { "STOIM",    "N",     16,      4 };   // итоговая стоимость услуги
  }
  If !is_all
    dbCreate( cur_dir + "tmp", adbf2 )
    Use ( cur_dir + "tmp" ) new
    Index On Str( u_kod, 4 ) to ( cur_dir + "tmpk" )
    Index On fsort_usl( u_shifr ) to ( cur_dir + "tmpn" )
    Close databases
    ob2_v_usl()
    Use ( cur_dir + "tmp" ) new
    dbEval( {|| AAdd( arr_usl, tmp->u_kod ) } )
    Use
    If Len( arr_usl ) == 0
      Return Nil
    Endif
  Endif
  If eq_any( k, 8, 9, 13, 14 )  // вывод списка больных
    dbCreate( cur_dir + "tmp", adbf1 )
  Else
    dbCreate( cur_dir + "tmp", adbf2 )
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  Use ( cur_dir + "tmp" )
  Do Case
  Case k == 0  // Количество услуг и сумма лечения по службам (с разбивкой по отделениям)
    Index On Str( kod_vr_as, 4 ) + Str( otd, 3 ) to ( cur_dir + "tmpk" )
    Index On Str( kod_vr_as, 4 ) + Str( u_kod, 4 ) + Upper( Left( u_name, 20 ) ) to ( cur_dir + "tmpn" )
  Case k == 100  // Количество услуг и сумма лечения по отделениям (с разбивкой по службам)
    Index On Str( kod_vr_as, 4 ) + Str( otd, 3 ) to ( cur_dir + "tmpk" )
    Index On Str( u_kod, 4 ) + Str( otd, 3 ) + Upper( Left( u_name, 20 ) ) to ( cur_dir + "tmpn" )
  Case k == 1  // Количество услуг и сумма лечения по отделениям
    Index On Str( otd, 3 ) to ( cur_dir + "tmpk" )
    Index On Str( u_kod, 4 ) + Upper( fio ) to ( cur_dir + "tmpn" )
  Case k == 2  // Статистика по работе персонала в конкретном отделении
    Index On Str( vr_as, 1 ) + Str( kod_vr_as, 4 ) to ( cur_dir + "tmpk" )
    Index On Upper( Left( fio, 30 ) ) + Str( kod_vr_as, 4 ) + Str( vr_as, 1 ) to ( cur_dir + "tmpn" )
  Case k == 3  // Статистика по услугам, оказанным в конкретном отделении
    Index On Str( u_kod, 4 ) to ( cur_dir + "tmpk" )
    Index On fsort_usl( u_shifr ) to ( cur_dir + "tmpn" )
  Case k == 31  // Статистика по услугам, оказанным в конкретных отделениях
    Index On Str( otd, 3 ) + Str( u_kod, 4 ) to ( cur_dir + "tmpk" )
    Index On Upper( fio ) + Str( otd, 3 ) + fsort_usl( u_shifr ) to ( cur_dir + "tmpn" )
  Case k == 4  // Статистика по работе персонала (плюс оказанные услуги) в конкретном отделении
    Index On Str( vr_as, 1 ) + Str( kod_vr_as, 4 ) + Str( u_kod, 4 ) to ( cur_dir + "tmpk" )
    Index On Upper( Left( fio, 30 ) ) + Str( kod_vr_as, 4 ) + Str( vr_as, 1 ) + fsort_usl( u_shifr ) to ( cur_dir + "tmpn" )
  Case k == 5  // Статистика по работе конкретного человека (плюс оказанные услуги)
    Index On Str( vr_as, 1 ) + Str( kod_vr_as, 4 ) + Str( u_kod, 4 ) to ( cur_dir + "tmpk" )
    If serv_arr == NIL
      Index On Str( vr_as, 1 ) + fsort_usl( u_shifr ) to ( cur_dir + "tmpn" )
    Else
      Index On Upper( Left( fio, 30 ) ) + Str( kod_vr_as, 4 ) + Str( vr_as, 1 ) + fsort_usl( u_shifr ) to ( cur_dir + "tmpn" )
    Endif
  Case k == 6  // Статистика по конкретным услугам
    Index On Str( u_kod, 4 ) to ( cur_dir + "tmpk" )
    Index On fsort_usl( u_shifr ) to ( cur_dir + "tmpn" )
    Close databases
    ob2_v_usl()
  Case k == 7  // Статистика по работе всего персонала
    Index On Str( vr_as, 1 ) + Str( kod_vr_as, 4 ) to ( cur_dir + "tmpk" )
    Index On Upper( Left( fio, 30 ) ) + Str( kod_vr_as, 4 ) + Str( vr_as, 1 ) to ( cur_dir + "tmpn" )
  Case eq_any( k, 8, 9 )  // вывод списка больных
    Index On Str( kod, 7 ) to ( cur_dir + "tmpk" )
    Index On DToS( k_data ) + Upper( Left( fio, 30 ) ) to ( cur_dir + "tmpn" )
  Case eq_any( k, 10, 110 ) // Статистика по услугам по всем службам
    Index On Str( u_kod, 4 ) to ( cur_dir + "tmpk" )
    Index On Str( kod_vr_as, 4 ) + fsort_usl( u_shifr ) to ( cur_dir + "tmpn" )
  Case eq_any( k, 11, 111 ) // Статистика по услугам конкретной службы
    Index On Str( u_kod, 4 ) to ( cur_dir + "tmpk" )
    Index On fsort_usl( u_shifr ) to ( cur_dir + "tmpn" )
  Case k == 12 // Статистика по всем услугам
    Index On Str( u_kod, 4 ) to ( cur_dir + "tmpk" )
    Index On fsort_usl( u_shifr ) to ( cur_dir + "tmpn" )
  Case k == 13  // вывод услуг + списка больных
    Index On Str( u_kod, 4 ) + Str( kod, 7 ) to ( cur_dir + "tmpk" )
    Index On fsort_usl( u_shifr ) + Str( u_kod, 4 ) + DToS( k_data ) + Upper( Left( fio, 30 ) ) to ( cur_dir + "tmpn" )
  Case k == 14  // Статистика по конкретным услугам + список больных
    Index On Str( u_kod, 4 ) + Str( kod, 7 ) to ( cur_dir + "tmpk" )
    Index On fsort_usl( u_shifr ) + Str( u_kod, 4 ) + DToS( k_data ) + Upper( Left( fio, 30 ) ) to ( cur_dir + "tmpn" )
    Close databases
    ob2_v_usl()
  Endcase
  Use ( cur_dir + "tmp" ) index ( cur_dir + "tmpk" ), ( cur_dir + "tmpn" ) Alias TMP
  If mem_trudoem == 2
    useuch_usl()
  Endif
  If hb_FileExists( dir_server + "usl_del" + sdbf )
    r_use( dir_server + "usl_del",, "UD" )
    Index On Str( kod, 4 ) to ( cur_dir + "tmp_ud" )
  Endif
  r_use( dir_server + "uslugi",, "USL" )
  Private is_1_usluga := ( Len( arr_usl ) == 1 )
  If psz == 2 .and. eq_any( is_oplata, 5, 6, 7 )
    open_opl_5()
    If is_oplata == 7
      cre_tmp7()
    Endif
  Endif
  r_use( dir_server + "mo_pers",, "PERSO" )
  If eq_any( k, 5, 9, 13 )  // Статистика по работе конкретного человека
    If serv_arr == NIL
      mperso := { glob_human }
    Endif
    If pi1 == 4  // по невыписанным счетам
      pole_kol := "hu->kol_1"
      pole_stoim := "hu->stoim_1"
      r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human", dir_server + "humann", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      dbSeek( "1", .t. )
      Do While human->tip_h < B_SCHET .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          If iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
            mkod_perso := 0
            If hu->kod_vr > 0 .and. ;
                AScan( mperso, {| x| x[ 1 ] == hu->kod_vr } ) > 0
              mkod_perso := hu->kod_vr
            Elseif hu->kod_as > 0 .and. ;
                AScan( mperso, {| x| x[ 1 ] == hu->kod_as } ) > 0
              mkod_perso := hu->kod_as
            Endif
            If mkod_perso > 0
              If k == 5
                ob3_statist( k, arr_otd, serv_arr, mkod_perso )
              Elseif eq_any( k, 9, 13 )
                ob5_statist( k, arr_otd, serv_arr )
              Endif
            Endif
          Endif
          Select HU
          Skip
        Enddo
        Select HUMAN
        Skip
      Enddo
    Else   // between(pi1,1,3)
      r_use( dir_server + "schet",, "SCHET" )
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human", dir_server + "humank", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server + "human_u", { dir_server + "human_uv", ;
        dir_server + "human_ua", ;
        dir_server + "human_u" }, "HU" )
      For yy := 1 To Len( mperso )
        mkod_perso := mperso[ yy, 1 ]
        For xx := 1 To 2
          pole_va := { "hu->kod_vr", "hu->kod_as" }[ xx ]
          Select HU
          If xx == 1
            Set Order To 1
          Elseif xx == 2
            Set Order To 2
          Endif
          Do Case
          Case pi1 == 1  // по дате оказания услуги
            pole_kol := "hu->kol"
            pole_stoim := "hu->stoim"
            Select HU
            dbSeek( Str( mkod_perso, 4 ) + begin_date, .t. )
            Do while &pole_va == mkod_perso .and. hu->date_u <= end_date .and. !Eof()
              updatestatus()
              If Inkey() == K_ESC
                fl_exit := .t. ; Exit
              Endif
              If iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
                human->( dbSeek( Str( hu->kod, 7 ) ) )
                If human_->oplata < 9
                  If k == 5
                    ob3_statist( k, arr_otd, serv_arr, mkod_perso )
                  Elseif eq_any( k, 9, 13 ) .and. ;
                      if( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
                    ob5_statist( k, arr_otd, serv_arr )
                  Endif
                Endif
              Endif
              Select HU
              Skip
            Enddo
          Case Between( pi1, 2, 3 )  // по дате выписки счета и окончания лечения
            pole_kol := "hu->kol_1"
            pole_stoim := "hu->stoim_1"
            Select HU
            dni_vr := Max( 366, mem_dni_vr ) // отнимем min год
            dbSeek( Str( mkod_perso, 4 ) + dtoc4( arr[ 5 ] -dni_vr ), .t. )
            Do while &pole_va == mkod_perso .and. hu->date_u <= end_date .and. !Eof()
              updatestatus()
              If Inkey() == K_ESC
                fl_exit := .t. ; Exit
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
                    ob3_statist( k, arr_otd, serv_arr, mkod_perso )
                  Elseif eq_any( k, 9, 13 )
                    ob5_statist( k, arr_otd, serv_arr )
                  Endif
                Endif
              Endif
              Select HU
              Skip
            Enddo
          Endcase
        Next
        If fl_exit ; exit ; Endif
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
      pole_kol := "hu->kol_1"
      pole_stoim := "hu->stoim_1"
      r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human", dir_server + "humann", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      dbSeek( "1", .t. )
      Do While human->tip_h < B_SCHET .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          If ( i := AScan( arr_usl, {| x| x[ 1 ] == hu->u_kod } ) ) > 0
            If k == 6
              tmp->( dbGoto( arr_usl[ i, 2 ] ) )
              lrec := tmp->( RecNo() )
              ob3_statist( k, arr_otd, serv_arr )
            Elseif eq_any( k, 8, 14 )
              ob5_statist( k, arr_otd, serv_arr )
            Endif
          Endif
          Select HU
          Skip
        Enddo
        Select HUMAN
        Skip
      Enddo
    Else   // between(pi1,1,3)
      t_date1 := dtoc4( arr[ 5 ] -180 )
      t_date2 := dtoc4( arr[ 5 ] -1 )
      r_use( dir_server + "schet",, "SCHET" )
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human", dir_server + "humank", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server + "human_u", { dir_server + "human_uk", ;
        dir_server + "human_u" }, "HU" )
      For xx := 1 To Len( arr_usl )
        If k == 6
          tmp->( dbGoto( arr_usl[ xx, 2 ] ) )
          lrec := tmp->( RecNo() )
        Endif
        Do Case
        Case pi1 == 1  // по дате оказания услуги
          pole_kol := "hu->kol"
          pole_stoim := "hu->stoim"
          Select HU
          find ( Str( arr_usl[ xx, 1 ], 4 ) )
          Do While hu->u_kod == arr_usl[ xx, 1 ] .and. !Eof()
            updatestatus()
            If Inkey() == K_ESC
              fl_exit := .t. ; Exit
            Endif
            Select HUMAN
            find ( Str( hu->kod, 7 ) )
            If human_->oplata < 9 .and. Between( hu->date_u, begin_date, end_date )
              If k == 6
                ob3_statist( k, arr_otd, serv_arr )
              Elseif eq_any( k, 8, 14 )
                ob5_statist( k, arr_otd, serv_arr )
              Endif
            Endif
            Select HU
            Skip
          Enddo
        Case Between( pi1, 2, 3 )  // по дате выписки счета и окончания лечения
          pole_kol := "hu->kol_1"
          pole_stoim := "hu->stoim_1"
          Select HU
          find ( Str( arr_usl[ xx, 1 ], 4 ) )
          Do While hu->u_kod == arr_usl[ xx, 1 ] .and. !Eof()
            updatestatus()
            If Inkey() == K_ESC
              fl_exit := .t. ; Exit
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
                ob3_statist( k, arr_otd, serv_arr )
              Elseif eq_any( k, 8, 14 )
                ob5_statist( k, arr_otd, serv_arr )
              Endif
            Endif
            Select HU
            Skip
          Enddo
        Endcase
        If fl_exit ; exit ; Endif
      Next
    Endif
  Else
    Do Case
    Case pi1 == 1  // по дате оказания услуги
      pole_kol := "hu->kol"
      pole_stoim := "hu->stoim"
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human",, "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server + "human_u", dir_server + "human_ud", "HU" )
      Set Relation To kod into HUMAN
      Select HU
      dbSeek( begin_date, .t. )
      Do While hu->date_u <= end_date .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human_->oplata < 9 .and. iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
          ob3_statist( k, arr_otd, serv_arr )
        Endif
        Select HU
        Skip
      Enddo
      Select HU
      Set Relation To
    Case pi1 == 2  // по дате выписки счета
      pole_kol := "hu->kol_1"
      pole_stoim := "hu->stoim_1"
      r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server + "schet", dir_server + "schetd", "SCHET" )
      Set Filter To !eq_any( mest_inog, 6, 7 )
      dbSeek( begin_date, .t. )
      Do While schet->pdate <= end_date .and. !Eof()
        Select HUMAN
        find ( Str( schet->kod, 6 ) )
        Do While human->schet == schet->kod .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          If human_->oplata < 9
            Select HU
            find ( Str( human->kod, 7 ) )
            Do While hu->kod == human->kod .and. !Eof()
              If iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
                ob3_statist( k, arr_otd, serv_arr )
              Endif
              Select HU
              Skip
            Enddo
          Endif
          Select HUMAN
          Skip
        Enddo
        If fl_exit ; exit ; Endif
        Select SCHET
        Skip
      Enddo
    Case pi1 == 3  // по дате окончания лечения
      pole_kol := "hu->kol_1"
      pole_stoim := "hu->stoim_1"
      r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human", dir_server + "humand", "HUMAN" )
      If glob_mo[ _MO_KOD_TFOMS ] == '154602' // П2
        //
      Else
        Set Relation To RecNo() into HUMAN_
      Endif
      dbSeek( DToS( arr_m[ 5 ] ), .t. )
      Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If glob_mo[ _MO_KOD_TFOMS ] == '154602' // П2
          HUMAN_->( dbGoto( HUMAN->kod ) )
        Endif
        If human_->oplata < 9 .and. func_pi_schet( .t. )
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            If iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
              ob3_statist( k, arr_otd, serv_arr )
            Endif
            Select HU
            Skip
          Enddo
        Endif
        Select HUMAN
        Skip
      Enddo
    Case pi1 == 4  // по невыписанным счетам
      pole_kol := "hu->kol_1"
      pole_stoim := "hu->stoim_1"
      r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human", dir_server + "humann", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      dbSeek( "1", .t. )
      Do While human->tip_h < B_SCHET .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          If iif( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
            ob3_statist( k, arr_otd, serv_arr )
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
  If fl_exit ; Return NIL ; Endif
  If j == 0
    func_error( 4, "Нет сведений!" )
  Else
    mywait()
    If eq_any( k, 8, 9, 13, 14 )
      arr_title := { ;
        "─────────────────────────┬─────┬──────────┬────────╥───────────────┬────────╥──────────", ;
        "                         │ Кол.│Стоимость │  Дата  ║               │  Дата  ║          ", ;
        "         Ф.И.О.          │услуг│оказ.услуг│окон.леч║  Номер счета  │  счета ║Примечание", ;
        "─────────────────────────┴─────┴──────────┴────────╨───────────────┴────────╨──────────" }
      r_use( dir_server + "human_",, "HUMAN_" )
      r_use( dir_server + "human", dir_server + "humank", "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server + "schet_",, "SCHET_" )
      r_use( dir_server + "schet",, "SCHET" )
      Set Relation To RecNo() into SCHET_
    Else
      len_n := 58
      If mem_trudoem == 2
        len_n := 49
      Endif
      arr_title := Array( 4 )
      arr_title[ 1 ] := Replicate( "─", len_n )
      arr_title[ 2 ] := Space( len_n )
      arr_title[ 3 ] := Space( len_n )
      arr_title[ 4 ] := Replicate( "─", len_n )
      If !fl7_plan
        arr_title[ 1 ] += "┬──────"
        arr_title[ 2 ] += "│Кол-во"
        arr_title[ 3 ] += "│ услуг"
        arr_title[ 4 ] += "┴──────"
      Endif
      If mem_trudoem == 2
        arr_title[ 1 ] += "┬────────"
        arr_title[ 2 ] += "│        "
        arr_title[ 3 ] += "│ У.Е.Т. "
        arr_title[ 4 ] += "┴────────"
      Endif
      If fl7_plan
        arr_title[ 1 ] += "┬──────"
        arr_title[ 2 ] += "│  %%  "
        arr_title[ 3 ] += "│выпол."
        arr_title[ 4 ] += "┴──────"
      Endif
      arr_title[ 1 ] += "┬──────────────"
      arr_title[ 2 ] += "│" + PadC( if( psz == 1, "Стоимость", "Заработная" ), 14 )
      arr_title[ 3 ] += "│" + PadC( if( psz == 1, "услуг", "плата" ), 14 )
      arr_title[ 4 ] += "┴──────────────"
    Endif
    sh := Len( arr_title[ 1 ] )
    Set( _SET_DELETED, .f. )
    Use ( cur_dir + "tmp" ) index ( cur_dir + "tmpk" ), ( cur_dir + "tmpn" ) New Alias TMP
    If !eq_any( k, 1, 8, 9 )
      If eq_any( k, 0, 10, 100, 110 )
        r_use( dir_server + "slugba", dir_server + "slugba", "SL" )
      Endif
      If eq_any( k, 3, 31, 4, 5, 6, 10, 11, 12, 13, 14, 110, 111 )
        use_base( "lusl" )
        r_use( dir_server + "uslugi",, "USL" )
      Endif
      r_use( dir_server + "mo_pers",, "PERSO" )
      Select TMP
      Set Order To 0
      Go Top
      Do While !Eof()
        If eq_any( k, 0, 10, 100, 110 )
          Select SL
          find ( Str( tmp->kod_vr_as, 3 ) )
          If Found() .and. !Deleted()
            If k == 100
              tmp->u_name := Str( sl->shifr, 3 ) + ". " + sl->name
            Else
              tmp->fio := Str( sl->shifr, 3 ) + ". " + sl->name
            Endif
          Else
            Select TMP
            Delete
          Endif
        Endif
        If eq_any( k, 3, 31, 4, 5, 6, 10, 11, 12, 13, 14, 110, 111 )
          Select USL
          Goto ( tmp->u_kod )
          If usl->kod <= 0 .or. Deleted() .or. Eof()
            Select TMP
            Delete
          Else
            tmp->u_shifr := usl->shifr
            s := ""
            If !Empty( lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, arr_m[ 6 ] ) ) .and. !( usl->shifr == lshifr1 )
              s += "(" + AllTrim( lshifr1 ) + ")"
            Endif
            If Empty( lshifr1 ) .or. lshifr1 == usl->shifr
              Select LUSL
              find ( usl->shifr )
              If Found()
                tmp->u_name := s + lusl->name
              Else
                tmp->u_name := s + usl->name
              Endif
            Else
              tmp->u_name := s + usl->name
            Endif
          Endif
        Endif
        If eq_any( k, 2, 4, 5, 7 )
          Select PERSO
          Goto ( tmp->kod_vr_as )
          If Deleted() .or. Eof()
            Select TMP
            Delete
          Else
            tmp->fio := perso->fio
            tmp->tab_nom := perso->tab_nom
            tmp->svod_nom := perso->svod_nom
            If k == 7 .and. !fl7_plan ;
                .and. !Empty( perso->tab_nom ) ;
                .and. !Empty( perso->svod_nom )
              If ( i := AScan( arr_svod_nom, ;
                  {| x| x[ 1 ] == perso->svod_nom .and. x[ 2 ] == tmp->vr_as } ) ) == 0
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
          pkol := ptrud := pstoim := 0
          For j := 2 To Len( arr_svod_nom[ i, 3 ] )
            Goto ( arr_svod_nom[ i, 3, j ] )
            ptrud  += tmp->TRUDOEM
            pkol   += tmp->KOL
            pstoim += tmp->STOIM
            Delete
          Next
          Goto ( arr_svod_nom[ i, 3, 1 ] )
          tmp->TRUDOEM += ptrud
          tmp->KOL     += pkol
          tmp->STOIM   += pstoim
        Next
      Endif
    Endif
    Set( _SET_DELETED, .t. )
    fp := FCreate( "ob_stat" + stxt ) ; tek_stroke := 0 ; n_list := 1
    add_string( PadL( "дата печати " + date_8( sys_date ), sh ) )
    If k == 0
      ob6_statist()
      add_string( Center( "Статистика по службам (с разбивкой по отделениям)", sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
    Elseif k == 100
      ob7_statist()
      add_string( Center( "Статистика по отделениям (с разбивкой по службам)", sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
    Elseif k == 1
      add_string( Center( "Статистика по отделениям", sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
    Elseif k == 5
      add_string( Center( "Статистика по оказанным услугам", sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
      If serv_arr == Nil  // по одному человеку
        add_string( Center( '"' + Upper( glob_human[ 2 ] ) + ;
          ' [' + lstr( glob_human[ 5 ] ) + ']"', sh ) )
      Endif
    Elseif eq_any( k, 6, 14 )
      add_string( Center( "Статистика по услугам", sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
    Elseif k == 7
      add_string( Center( "Статистика по работе персонала", sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
    Elseif eq_any( k, 10, 110 )
      add_string( Center( "Статистика по услугам (с объединением по службам)", sh ) )
      If k == 10
        titlen_uch( st_a_uch, sh, lcount_uch )
      Else
        titlen_otd( st_a_otd, sh, lcount_otd )
        add_string( Center( "< " + AllTrim( glob_uch[ 2 ] ) + " >", sh ) )
      Endif
    Elseif eq_any( k, 11, 111 )
      add_string( Center( "Статистика по службе", sh ) )
      add_string( Center( serv_arr[ 2 ], sh ) )
      If k == 11
        titlen_uch( st_a_uch, sh, lcount_uch )
      Else
        titlen_otd( st_a_otd, sh, lcount_otd )
        add_string( Center( "< " + AllTrim( glob_uch[ 2 ] ) + " >", sh ) )
      Endif
    Elseif k == 12
      add_string( Center( "Статистика по всем оказанным услугам", sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
    Elseif k == 13
      add_string( Center( "Список больных, которым были оказаны услуги врачом (ассистентом):", sh ) )
      add_string( Center( '"' + Upper( glob_human[ 2 ] ) + ;
        ' [' + lstr( glob_human[ 5 ] ) + ']"', sh ) )
      titlen_uch( st_a_uch, sh, lcount_uch )
    Else
      add_string( Center( "Статистика по отделению", sh ) )
      titlen_otd( st_a_otd, sh, lcount_otd )
      add_string( Center( "< " + AllTrim( glob_uch[ 2 ] ) + " >", sh ) )
      If eq_any( k, 8, 9 )
        add_string( "" )
        If k == 8
          add_string( Center( "Список больных, которым была оказана услуга:", sh ) )
          add_string( Center( '"' + musluga[ 2 ] + '"', sh ) )
        Else
          add_string( Center( "Список больных, которым были оказаны услуги врачом (ассистентом):", sh ) )
          add_string( Center( '"' + Upper( glob_human[ 2 ] ) + ;
            ' [' + lstr( glob_human[ 5 ] ) + ']"', sh ) )
        Endif
      Endif
    Endif
    add_string( "" )
    _tit_ist_fin( sh )
    If pi1 != 4
      add_string( Center( arr[ 4 ], sh ) )
      add_string( "" )
    Endif
    Do Case
    Case pi1 == 1
      s := "[ по дате оказания услуги ]"
    Case pi1 == 2
      s := "[ по дате выписки счета ]"
    Case pi1 == 3
      s := str_pi_schet()
    Case pi1 == 4
      s := "[ по больным, еще не включенным в счет ]"
    Endcase
    add_string( Center( s, sh ) )
    add_string( "" )
    If fl_plan
      r_use( dir_server + "uch_pers", dir_server + "uch_pers", "UCHP" )
    Endif
    Select TMP
    Set Order To 2
    Go Top
    If eq_any( k, 8, 9, 13, 14 )
      mb := mkol := msum := old_usl := 0
      AEval( arr_title, {| x| add_string( x ) } )
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        If eq_any( k, 13, 14 ) .and. tmp->u_kod != old_usl
          If old_usl > 0
            add_string( Replicate( "─", sh ) )
            add_string( PadR( "Кол-во больных - " + lstr( mb ), 28 ) + ;
              PadL( expand_value( msum, 2 ), 13 ) + " руб." )
            add_string( PadL( "Кол-во услуг - " + lstr( mkol ), 30 ) )
            mb := mkol := msum := 0
          Endif
          add_string( "" )
          For i := 1 To perenos( arr, RTrim( tmp->u_shifr ) + ". " + tmp->u_name, sh - 2 )
            add_string( "│ " + arr[ i ] )
          Next
          add_string( "└" + Replicate( "─", sh - 1 ) )
        Endif
        old_usl := tmp->u_kod
        Select HUMAN
        find ( Str( tmp->kod, 7 ) )
        Select SCHET
        Goto ( human->schet )
        s := tmp->fio + ;
          put_val( tmp->kol, 5 ) + ;
          put_kope( tmp->stoim, 11 ) + "  " + ;
          date_8( tmp->k_data )
        If human->tip_h >= B_SCHET
          s += PadC( AllTrim( schet_->nschet ), 17 ) + date_8( c4tod( schet->pdate ) )
        Endif
        add_string( s )
        mkol += tmp->kol ; msum += tmp->stoim ; ++mb
        Select TMP
        Skip
      Enddo
      add_string( Replicate( "─", sh ) )
      add_string( PadR( "Кол-во больных - " + lstr( mb ), 28 ) + ;
        PadL( expand_value( msum, 2 ), 13 ) + " руб." )
      add_string( PadL( "Кол-во услуг - " + lstr( mkol ), 30 ) )
    Else
      pkol := ptrud := pstoim := 0
      old_perso := tmp->kod_vr_as ; old_vr_as := tmp->vr_as
      old_fio := "[" + put_tab_nom( tmp->tab_nom, tmp->svod_nom ) + "] "
      old_fio += tmp->fio
      old_slugba := tmp->fio
      old_shifr := iif( eq_any( k, 31, 100 ), tmp->otd, tmp->kod_vr_as )
      If eq_any( k, 2, 5, 7 )
        old_perso := -1  // для печати Ф.И.О. в начале
      Endif
      Select TMP
      Do While !Eof()
        If eq_any( k, 0, 10, 31, 100, 110 ) .and. ;
            old_shifr != iif( eq_any( k, 31, 100 ), tmp->otd, tmp->kod_vr_as )
          add_string( Space( 4 ) + Replicate( ".", sh - 4 ) )
          add_string( PadR( Space( 4 ) + old_slugba, len_n ) + ;
            put_val( pkol, 7, 0 ) + ;
            if( mem_trudoem == 2, umest_val( ptrud, 9, 2 ), "" ) + ;
            put_kope( pstoim, 15 ) )
          add_string( Replicate( "─", sh ) )
          pkol := ptrud := pstoim := 0
        Endif
        If k == 4 .and. !( old_perso == tmp->kod_vr_as .and. old_vr_as == tmp->vr_as )
          add_string( Space( 4 ) + Replicate( ".", sh - 4 ) )
          add_string( PadR( Space( 4 ) + old_fio, len_n - 4 ) + ;
            if( psz == 1, if( old_vr_as == 1, "врач", "асс." ), Space( 4 ) ) + ;
            put_val( pkol, 7, 0 ) + ;
            if( mem_trudoem == 2, umest_val( ptrud, 9, 2 ), "" ) + ;
            put_kope( pstoim, 15 ) )
          add_string( Replicate( "─", sh ) )
          pkol := ptrud := pstoim := 0
        Endif
        If fl_1_list .or. verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
          fl_1_list := .f.
        Endif
        If k == 4
          pkol += tmp->kol
          ptrud += tmp->trudoem
          pstoim += tmp->stoim
          skol[ tmp->vr_as ] += tmp->kol
          strud[ tmp->vr_as ] += tmp->trudoem
          sstoim[ tmp->vr_as ] += tmp->stoim
          j := perenos( arr, tmp->u_shifr + " " + tmp->u_name, len_n )
          add_string( PadR( arr[ 1 ], len_n ) + ;
            put_val( tmp->kol, 7, 0 ) + ;
            if( mem_trudoem == 2, umest_val( tmp->trudoem, 9, 2 ), "" ) + ;
            put_kope( tmp->stoim, 15 ) )
          For i := 2 To j
            add_string( Space( 11 ) + arr[ i ] )
          Next
          old_perso := tmp->kod_vr_as
          old_vr_as := tmp->vr_as
          old_fio := "[" + put_tab_nom( tmp->tab_nom, tmp->svod_nom ) + "] "
          old_fio += tmp->fio
        Else
          Do Case
          Case eq_any( k, 0, 31, 100 )
            s := PadR( tmp->u_name, len_n - 7 ) + Left( tmp->u_shifr, 7 )
            skol[ 1 ] += tmp->kol
            strud[ 1 ] += tmp->trudoem
            sstoim[ 1 ] += tmp->stoim
            pkol += tmp->kol
            ptrud += tmp->trudoem
            pstoim += tmp->stoim
            If k == 0
              old_slugba := tmp->fio ; old_shifr := tmp->kod_vr_as
            Elseif eq_any( k, 31, 100 )
              old_slugba := tmp->fio ; old_shifr := tmp->otd
              j := perenos( arr, tmp->u_shifr + " " + tmp->u_name, len_n )
              s := PadR( arr[ 1 ], len_n )
            Endif
          Case k == 1
            s := PadR( tmp->fio, len_n )
            skol[ 1 ] += tmp->kol
            strud[ 1 ] += tmp->trudoem
            sstoim[ 1 ] += tmp->stoim
          Case eq_any( k, 2, 7 )
            If Empty( tmp->u_shifr )
              s := "[" + put_tab_nom( tmp->tab_nom, tmp->svod_nom ) + "]"
              If Len( s ) < 8
                s := PadR( s, 8 )
              Endif
            Else
              s := PadR( "[+" + AllTrim( tmp->u_shifr ) + "]", 8 )
            Endif
            If fl7_plan
              s += tmp->fio
              s := PadR( s, len_n ) + umest_val( tmp->trudoem, 9, 2 )
              j := ret_trudoem( tmp->kod_vr_as, tmp->trudoem, ym_kol_mes, arr_m )
              s += "  " + put_val_0( j, 5, 1 )
              add_string( s + put_kope( tmp->stoim, 15 ) )
            Else
              If old_perso == tmp->kod_vr_as
                s := ""
              Else
                s += tmp->fio
              Endif
              s := PadR( s, len_n - 5 ) + " " + ;
                if( psz == 1, if( tmp->vr_as == 1, "врач", "асс." ), Space( 4 ) )
              skol[ tmp->vr_as ] += tmp->kol
              strud[ tmp->vr_as ] += tmp->trudoem
              sstoim[ tmp->vr_as ] += tmp->stoim
              old_perso := tmp->kod_vr_as
            Endif
          Case eq_any( k, 3, 6, 10, 11, 12, 110, 111 )
            j := perenos( arr, tmp->u_shifr + " " + tmp->u_name, len_n )
            s := PadR( arr[ 1 ], len_n )
            skol[ 1 ] += tmp->kol
            strud[ 1 ] += tmp->trudoem
            sstoim[ 1 ] += tmp->stoim
            If eq_any( k, 10, 110 )
              pkol += tmp->kol
              ptrud += tmp->trudoem
              pstoim += tmp->stoim
              old_slugba := tmp->fio ; old_shifr := tmp->kod_vr_as
            Endif
          Case k == 5
            If serv_arr != Nil .and. old_perso != tmp->kod_vr_as
              If old_perso > 0
                add_string( Replicate( "─", sh ) )
                fl := .f.
                If !emptyall( skol[ 1 ], strud[ 1 ], sstoim[ 1 ] )
                  fl := .t.
                  s := PadL( "И Т О Г О :  ", len_n - 4 )
                  If psz == 1 ; s += "врач"
                  else        ; s += Space( 4 )
                  Endif
                  add_string( s + ;
                    put_val( skol[ 1 ], 7, 0 ) + ;
                    if( mem_trudoem == 2, umest_val( strud[ 1 ], 9, 2 ), "" ) + ;
                    put_kope( sstoim[ 1 ], 15 ) )
                Endif
                If !emptyall( skol[ 2 ], strud[ 2 ], sstoim[ 2 ] )
                  s := if( fl, "", "И Т О Г О :  " )
                  add_string( PadL( s, len_n - 4 ) + "асс." + ;
                    put_val( skol[ 2 ], 7, 0 ) + ;
                    if( mem_trudoem == 2, umest_val( strud[ 2 ], 9, 2 ), "" ) + ;
                    put_kope( sstoim[ 2 ], 15 ) )
                Endif
                If fl5_plan
                  j := ret_trudoem( old_perso, strud[ 1 ] + strud[ 2 ], ym_kol_mes, arr_m )
                  add_string( Space( 31 ) + ;
                    PadL( " " + AllTrim( str_0( j, 7, 1 ) ) + " % выполнения", sh - 31, "─" ) )
                  Select TMP
                Endif
                AFill( skol, 0 ) ; AFill( strud, 0 ) ; AFill( sstoim, 0 )
              Endif
              add_string( "" )
              add_string( Space( 5 ) + put_tab_nom( tmp->tab_nom, tmp->svod_nom ) + ;
                ". " + Upper( RTrim( tmp->fio ) ) )
            Endif
            j := perenos( arr, tmp->u_shifr + " " + tmp->u_name, len_n - 6 )
            s := PadR( arr[ 1 ], len_n - 4 ) + ;
              if( psz == 1, if( tmp->vr_as == 1, "врач", "асс." ), Space( 4 ) )
            skol[ tmp->vr_as ] += tmp->kol
            strud[ tmp->vr_as ] += tmp->trudoem
            sstoim[ tmp->vr_as ] += tmp->stoim
            old_perso := tmp->kod_vr_as
          Endcase
          If !fl7_plan
            add_string( s + ;
              put_val( tmp->kol, 7, 0 ) + ;
              if( mem_trudoem == 2, umest_val( tmp->trudoem, 9, 2 ), "" ) + ;
              put_kope( tmp->stoim, 15 ) )
          Endif
          If eq_any( k, 3, 31, 5, 6, 10, 11, 12, 110, 111 ) .and. j > 1
            For i := 2 To j
              add_string( Space( 11 ) + arr[ i ] )
            Next
          Endif
        Endif
        Select TMP
        Skip
      Enddo
      If eq_any( k, 0, 10, 31, 100, 110 )
        add_string( Space( 4 ) + Replicate( ".", sh - 4 ) )
        add_string( PadR( Space( 4 ) + old_slugba, len_n ) + ;
          put_val( pkol, 7, 0 ) + ;
          if( mem_trudoem == 2, umest_val( ptrud, 9, 2 ), "" ) + ;
          put_kope( pstoim, 15 ) )
        add_string( "" )
      Endif
      If k == 4
        add_string( Space( 4 ) + Replicate( ".", sh - 4 ) )
        add_string( PadR( Space( 4 ) + old_fio, len_n - 4 ) + ;
          if( psz == 1, if( old_vr_as == 1, "врач", "асс." ), Space( 4 ) ) + ;
          put_val( pkol, 7, 0 ) + ;
          if( mem_trudoem == 2, umest_val( ptrud, 9, 2 ), "" ) + ;
          put_kope( pstoim, 15 ) )
        add_string( "" )
      Endif
      add_string( Replicate( "─", sh ) )
      fl := .f.
      If !emptyall( skol[ 1 ], strud[ 1 ], sstoim[ 1 ] )
        fl := .t.
        s := PadL( "И Т О Г О :  ", len_n - 4 )
        If eq_any( k, 2, 4, 5, 7 ) .and. psz == 1
          s += "врач"
        Else
          s += Space( 4 )
        Endif
        If fl7_plan
          add_string( s + str_0( strud[ 1 ], 9, 1 ) + put_kope( sstoim[ 1 ], 22 ) )
        Else
          add_string( s + ;
            Str( skol[ 1 ], 7, 0 ) + ;
            if( mem_trudoem == 2, umest_val( strud[ 1 ], 9, 2 ), "" ) + ;
            put_kope( sstoim[ 1 ], 15 ) )
        Endif
      Endif
      If ( eq_any( k, 2, 4, 5, 7 ) ) .and. !emptyall( skol[ 2 ], strud[ 2 ], sstoim[ 2 ] )
        s := if( fl, "", "И Т О Г О :  " )
        s := PadL( s, len_n - 4 ) + "асс."
        If fl7_plan
          add_string( s + str_0( strud[ 2 ], 9, 1 ) + put_kope( sstoim[ 2 ], 22 ) )
        Else
          add_string( s + ;
            Str( skol[ 2 ], 7, 0 ) + ;
            if( mem_trudoem == 2, umest_val( strud[ 2 ], 9, 2 ), "" ) + ;
            put_kope( sstoim[ 2 ], 15 ) )
        Endif
      Endif
      If fl5_plan
        j := ret_trudoem( old_perso, strud[ 1 ] + strud[ 2 ], ym_kol_mes, arr_m )
        add_string( Space( 31 ) + ;
          PadL( " " + AllTrim( str_0( j, 7, 1 ) ) + " % выполнения", sh - 31, "─" ) )
      Endif
    Endif
    If psz == 2 .and. is_oplata == 7 .and. is_1_usluga
      file_tmp7( arr_usl[ 1 ], sh, HH )
    Endif
    FClose( fp )
    Close databases
    viewtext( "ob_stat" + stxt,,,, ( sh > 80 ),,, regim )
  Endif
  Return Nil

//
Static Function ob3_statist( k, arr_otd, serv_arr, mkod_perso )

  Local i, j, mtrud := { 0, 0, 0 }, koef_z := { 1, 1, 1 }, k1 := 2, s1 := "2", lstoim

  If !_f_ist_fin()
    Return Nil
  Endif
  If hu->u_kod > 0 .and. ( &pole_kol > 0 .or. &pole_stoim > 0 ) .and. ;
      ( i := AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) ) > 0
    lstoim := _f_stoim( 1 )
    If mem_trudoem == 2
      mtrud := _f_trud( &pole_kol, human->vzros_reb, hu->kod_vr, hu->kod_as )
    Endif
    If psz == 2 .and. eq_any( is_oplata, 5, 6, 7 )
      koef_z := ret_p3_z( hu->u_kod, hu->kod_vr, hu->kod_as )
      If is_oplata == 7 .and. is_1_usluga
        put_tmp7( &pole_kol, hu->kod_vr, hu->kod_as, mtrud, koef_z, 1 )
      Endif
      k1 := 1 ; s1 := "1"
    Endif
    If fl7_plan
      k1 := 1 ; s1 := "1"
    Endif
    Select TMP
    Do Case
    Case eq_any( k, 0, 100 )
      Select USL
      Goto ( hu->u_kod )
      If !usl->( Eof() ) .and. usl->slugba >= 0
        Select TMP
        find ( Str( usl->slugba, 4 ) + Str( hu->otd, 3 ) )
        If !Found()
          Append Blank
          tmp->otd := arr_otd[ i, 1 ]
          If k == 0
            tmp->u_name := arr_otd[ i, 2 ]
          Elseif k == 100
            tmp->fio := arr_otd[ i, 2 ]
          Endif
          tmp->kod_vr_as := usl->slugba
          If ( j := AScan( st_a_uch, {| x| x[ 1 ] == arr_otd[ i, 3 ] } ) ) > 0
            tmp->u_kod := arr_otd[ i, 3 ]  // код ЛПУ
            If Len( st_a_uch ) > 1
              If k == 0
                tmp->u_name := PadR( arr_otd[ i, 2 ], 31 ) + st_a_uch[ j, 2 ]
              Elseif k == 100
                tmp->fio := AllTrim( tmp->fio ) + " [" + AllTrim( st_a_uch[ j, 2 ] ) + "]"
              Endif
            Endif
          Endif
        Endif
        tmp->kol += &pole_kol
        If mem_trudoem == 2 .and. psz == 2 .and. is_oplata == 6
          tmp->stoim += lstoim * koef_z[ 1 ]
        Else
          tmp->stoim += _f_koef_z( lstoim, &pole_kol, koef_z )
        Endif
        tmp->trudoem += mtrud[ 1 ]
      Endif
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
      tmp->stoim += _f_koef_z( lstoim, &pole_kol, koef_z )
      tmp->trudoem += mtrud[ 1 ]
    Case eq_any( k, 2, 7 )
      If hu->kod_vr > 0
        find ( "1" + Str( hu->kod_vr, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := 1
          tmp->kod_vr_as := hu->kod_vr
        Endif
        j := _f_koef_z( lstoim, &pole_kol, koef_z, 2 )
        tmp->kol += &pole_kol
        tmp->stoim += j
        tmp->trudoem += mtrud[ 2 ]
        If fl7_plan
          strud[ 1 ] += mtrud[ 2 ]
          sstoim[ 1 ] += j
        Endif
      Endif
      If hu->kod_as > 0
        find ( s1 + Str( hu->kod_as, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := k1
          tmp->kod_vr_as := hu->kod_as
        Endif
        j := _f_koef_z( lstoim, &pole_kol, koef_z, 3 )
        tmp->kol += &pole_kol
        tmp->stoim += j
        tmp->trudoem += mtrud[ 3 ]
        If fl7_plan
          strud[ 2 ] += mtrud[ 3 ]
          sstoim[ 2 ] += j
        Endif
      Endif
    Case eq_any( k, 3, 31, 6 )
      If k == 31
        find ( Str( hu->otd, 3 ) + Str( hu->u_kod, 4 ) )
      Else
        find ( Str( hu->u_kod, 4 ) )
      Endif
      If !Found()
        Append Blank
        If k == 31
          tmp->otd := arr_otd[ i, 1 ]
          tmp->fio := arr_otd[ i, 2 ]
          If ( j := AScan( st_a_uch, {| x| x[ 1 ] == arr_otd[ i, 3 ] } ) ) > 0
            tmp->fio := AllTrim( tmp->fio ) + " [" + AllTrim( st_a_uch[ j, 2 ] ) + "]"
          Endif
        Endif
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol += &pole_kol
      tmp->stoim += _f_koef_z( lstoim, &pole_kol, koef_z )
      tmp->trudoem += mtrud[ 1 ]
    Case k == 4
      If hu->kod_vr > 0
        find ( "1" + Str( hu->kod_vr, 4 ) + Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := 1
          tmp->kod_vr_as := hu->kod_vr
          tmp->u_kod := hu->u_kod
        Endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z( lstoim, &pole_kol, koef_z, 2 )
        tmp->trudoem += mtrud[ 2 ]
      Endif
      If hu->kod_as > 0
        find ( s1 + Str( hu->kod_as, 4 ) + Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := k1
          tmp->kod_vr_as := hu->kod_as
          tmp->u_kod := hu->u_kod
        Endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z( lstoim, &pole_kol, koef_z, 3 )
        tmp->trudoem += mtrud[ 3 ]
      Endif
    Case k == 5
      If hu->kod_vr == mkod_perso
        find ( "1" + Str( mkod_perso, 4 ) + Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := 1
          tmp->kod_vr_as := mkod_perso
          tmp->u_kod := hu->u_kod
        Endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z( lstoim, &pole_kol, koef_z, 2 )
        tmp->trudoem += mtrud[ 2 ]
      Endif
      If hu->kod_as == mkod_perso
        find ( s1 + Str( mkod_perso, 4 ) + Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := k1
          tmp->kod_vr_as := mkod_perso
          tmp->u_kod := hu->u_kod
        Endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z( lstoim, &pole_kol, koef_z, 3 )
        tmp->trudoem += mtrud[ 3 ]
      Endif
    Case eq_any( k, 10, 110 )  // службы + услуги
      Select USL
      Goto ( hu->u_kod )
      If !Eof() .and. usl->slugba >= 0
        Select TMP
        find ( Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->kod_vr_as := usl->slugba
          tmp->u_kod := usl->kod
        Endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z( lstoim, &pole_kol, koef_z )
        tmp->trudoem += mtrud[ 1 ]
      Endif
    Case eq_any( k, 11, 111 )  // служба + услуги
      Select USL
      Goto ( hu->u_kod )
      If !Eof() .and. usl->slugba == serv_arr[ 1 ]
        Select TMP
        find ( Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->u_kod := usl->kod
        Endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z( lstoim, &pole_kol, koef_z )
        tmp->trudoem += mtrud[ 1 ]
      Endif
    Case k == 12  // все услуги
      Select USL
      Goto ( hu->u_kod )
      If !Eof()
        Select TMP
        find ( Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->u_kod := usl->kod
        Endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z( lstoim, &pole_kol, koef_z )
        tmp->trudoem += mtrud[ 1 ]
      Endif
    Endcase
  Endif
  Return Nil

//
Static Function ob4_statist( k, arr_otd, i, mkol, mstoim, serv_arr, mkod_perso )

  Local j, mtrud := { 0, 0, 0 }, koef_z := { 1, 1, 1 }, k1 := 2, s1 := "2"

  If !_f_ist_fin()
    Return Nil
  Endif
  If mem_trudoem == 2
    mtrud := _f_trud( mkol, human->vzros_reb, hu->kod_vr, hu->kod_as )
  Endif
  If psz == 2 .and. eq_any( is_oplata, 5, 6, 7 )
    koef_z := ret_p3_z( hu->u_kod, hu->kod_vr, hu->kod_as )
    If is_oplata == 7 .and. is_1_usluga
      put_tmp7( mkol, hu->kod_vr, hu->kod_as, mtrud, koef_z, 1 )
    Endif
    k1 := 1 ; s1 := "1"
  Endif
  If fl7_plan
    k1 := 1 ; s1 := "1"
  Endif
  Select TMP
  Do Case
  Case eq_any( k, 0, 100 )
    Select USL
    Goto ( hu->u_kod )
    If !usl->( Eof() ) .and. usl->slugba >= 0
      Select TMP
      find ( Str( usl->slugba, 4 ) + Str( hu->otd, 3 ) )
      If !Found()
        Append Blank
        tmp->otd := arr_otd[ i, 1 ]
        If k == 0
          tmp->u_name := arr_otd[ i, 2 ]
        Elseif k == 100
          tmp->fio := arr_otd[ i, 2 ]
        Endif
        tmp->kod_vr_as := usl->slugba
        If ( j := AScan( st_a_uch, {| x| x[ 1 ] == arr_otd[ i, 3 ] } ) ) > 0
          tmp->u_kod := arr_otd[ i, 3 ]   // код ЛПУ
          If Len( st_a_uch ) > 1
            If k == 0
              tmp->u_name := PadR( arr_otd[ i, 2 ], 31 ) + st_a_uch[ j, 2 ]
            Elseif k == 100
              tmp->fio := AllTrim( tmp->fio ) + " [" + AllTrim( st_a_uch[ j, 2 ] ) + "]"
            Endif
          Endif
        Endif
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z )
      tmp->trudoem += mtrud[ 1 ]
    Endif
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
    tmp->stoim += _f_koef_z( mstoim, mkol, koef_z )
    tmp->trudoem += mtrud[ 1 ]
  Case eq_any( k, 2, 7 )
    If hu->kod_vr > 0
      find ( "1" + Str( hu->kod_vr, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := 1
        tmp->kod_vr_as := hu->kod_vr
      Endif
      j := _f_koef_z( mstoim, mkol, koef_z, 2 )
      tmp->kol += mkol
      tmp->stoim += j
      tmp->trudoem += mtrud[ 2 ]
      If fl7_plan
        strud[ 1 ] += mtrud[ 2 ]
        sstoim[ 1 ] += j
      Endif
    Endif
    If hu->kod_as > 0
      find ( s1 + Str( hu->kod_as, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := k1
        tmp->kod_vr_as := hu->kod_as
      Endif
      j := _f_koef_z( mstoim, mkol, koef_z, 3 )
      tmp->kol += mkol
      tmp->stoim += j
      tmp->trudoem += mtrud[ 3 ]
      If fl7_plan
        strud[ 2 ] += mtrud[ 3 ]
        sstoim[ 2 ] += j
      Endif
    Endif
  Case eq_any( k, 3, 6 )
    find ( Str( hu->u_kod, 4 ) )
    If !Found()
      Append Blank
      tmp->u_kod := hu->u_kod
    Endif
    tmp->kol += mkol
    tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 1 )
    tmp->trudoem += mtrud[ 1 ]
  Case k == 4
    If hu->kod_vr > 0
      find ( "1" + Str( hu->kod_vr, 4 ) + Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := 1
        tmp->kod_vr_as := hu->kod_vr
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 2 )
      tmp->trudoem += mtrud[ 2 ]
    Endif
    If hu->kod_as > 0
      find ( s1 + Str( hu->kod_as, 4 ) + Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := k1
        tmp->kod_vr_as := hu->kod_as
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 3 )
      tmp->trudoem += mtrud[ 3 ]
    Endif
  Case k == 5
    If hu->kod_vr == mkod_perso
      find ( "1" + Str( mkod_perso, 4 ) + Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := 1
        tmp->kod_vr_as := mkod_perso
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 2 )
      tmp->trudoem += mtrud[ 2 ]
    Endif
    If hu->kod_as == mkod_perso
      find ( s1 + Str( mkod_perso, 4 ) + Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := k1
        tmp->kod_vr_as := mkod_perso
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 3 )
      tmp->trudoem += mtrud[ 3 ]
    Endif
  Case eq_any( k, 10, 110 )  // службы + услуги
    Select USL
    Goto ( hu->u_kod )
    If !Eof() .and. usl->slugba >= 0
      Select TMP
      find ( Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->kod_vr_as := usl->slugba
        tmp->u_kod := usl->kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 1 )
      tmp->trudoem += mtrud[ 1 ]
    Endif
  Case eq_any( k, 11, 111 )  // служба + услуги
    Select USL
    Goto ( hu->u_kod )
    If !Eof() .and. usl->slugba == serv_arr[ 1 ]
      Select TMP
      find ( Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->u_kod := usl->kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 1 )
      tmp->trudoem += mtrud[ 1 ]
    Endif
  Case k == 12  // все услуги
    Select USL
    Goto ( hu->u_kod )
    If !Eof()
      Select TMP
      find ( Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->u_kod := usl->kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 1 )
      tmp->trudoem += mtrud[ 1 ]
    Endif
  Endcase
  Return Nil

//
Static Function ob5_statist( k, arr_otd, serv_arr, mkol, mstoim )

  If !_f_ist_fin()
    Return Nil
  Endif
  If arr_otd != Nil .and. AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) == 0
    Return Nil
  Endif
  Select TMP
  If eq_any( k, 13, 14 )
    find ( Str( hu->u_kod, 4 ) + Str( human->kod, 7 ) )
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
  Default mkol TO &pole_kol, mstoim TO &pole_stoim
  tmp->kol += mkol
  tmp->stoim += mstoim
  Return Nil

// подсчитать процент по отделениям (для службы)
Static Function ob6_statist()

  Local arr := {}, i

  Select TMP
  Go Top
  Do While !Eof()
    If ( i := AScan( arr, {| x| x[ 1 ] == tmp->kod_vr_as } ) ) == 0
      AAdd( arr, { tmp->kod_vr_as, 0 } ) ; i := Len( arr )
    Endif
    arr[ i, 2 ] += tmp->stoim
    Skip
  Enddo
  Go Top
  Do While !Eof()
    If ( i := AScan( arr, {| x| x[ 1 ] == tmp->kod_vr_as } ) ) >  0 .and. arr[ i, 2 ] > 0
      tmp->u_shifr := Str( tmp->stoim / arr[ i, 2 ] * 100, 6, 2 ) + "%"
    Endif
    Skip
  Enddo
  Return Nil

// подсчитать процент по службам (для отделения)
Static Function ob7_statist()

  Local arr := {}, i

  Select TMP
  Go Top
  Do While !Eof()
    If ( i := AScan( arr, {| x| x[ 1 ] == tmp->otd } ) ) == 0
      AAdd( arr, { tmp->otd, 0 } ) ; i := Len( arr )
    Endif
    arr[ i, 2 ] += tmp->stoim
    Skip
  Enddo
  Go Top
  Do While !Eof()
    If ( i := AScan( arr, {| x| x[ 1 ] == tmp->otd } ) ) > 0 .and. arr[ i, 2 ] > 0
      tmp->u_shifr := Str( tmp->stoim / arr[ i, 2 ] * 100, 6, 2 ) + "%"
    Endif
    Skip
  Enddo

  Return Nil

//  
Static Function _f_stoim( k )

  Local sstoim, skol, scena

  If k == 1
    skol := &pole_kol
    sstoim := &pole_stoim
  Else
    skol := hu->kol
    sstoim := hu->stoim
  Endif
  If Empty( sstoim ) .and. Select( "UD" ) > 0
    Select UD
    find ( Str( hu->u_kod, 4 ) )
    If Found()
      scena := iif( human->vzros_reb == 0, ud->cena, ud->cena_d )
      sstoim := round_5( scena * skol, 2 )
    Endif
  Endif
  Return sstoim

// инициализация источников финансирования
Function _init_if()

  Local i, arr_f := { "str_komp",, "komitet" }, arr := { I_FIN_OMS }, arr2 := {}

  For i := 1 To 3
    If i != 2 .and. hb_FileExists( dir_server + arr_f[ i ] + sdbf )
      r_use( dir_server + arr_f[ i ],, "_B" )
      Go Top
      Do While !Eof()
        If iif( i == 1, !Between( _b->tfoms, 44, 47 ), .t. )
          AAdd( arr2, { i, _b->kod, _b->ist_fin } )
          If AScan( arr, _b->ist_fin ) == 0
            AAdd( arr, _b->ist_fin )
          Endif
        Endif
        Skip
      Enddo
      Use
    Endif
  Next

  Return { arr, arr2 }

//   вернуть источник фин-ия (bit-овый вариант)
Function fbp_ist_fin( r, c )

  Static sast := {}
  Local fl := .t., i, j, a, arr := {}

  _arr_if := {}
  _arr_komit := {}
  If Len( _what_if[ 1 ] ) > 1
    For i := 1 To Len( mm_ist_fin )
      If AScan( _what_if[ 1 ], mm_ist_fin[ i, 2 ] ) > 0
        AAdd( arr, mm_ist_fin[ i ] )
      Endif
    Next
    If ( j := Len( arr ) ) > 0
      If Len( sast ) != j
        sast := Array( j ) ; AFill( sast, .t. )
      Endif
      If ( a := bit_popup( r, c, arr, sast ) ) != NIL
        AFill( sast, .f. ) ; fl := .t.
        For i := 1 To Len( a )
          AAdd( _arr_if, a[ i, 2 ] )
          If ( j := AScan( arr, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
            sast[ j ] := .t.
          Endif
        Next
      Endif
      If Len( _arr_if ) == Len( arr )
        _arr_if := {}
      Endif
      If Len( _arr_if ) == 1 .and. _arr_if[ 1 ] == I_FIN_BUD
        arr := {}
        r_use( dir_server + "komitet",, "KOM" )
        Go Top
        Do While !Eof()
          If kom->ist_fin == I_FIN_BUD
            AAdd( arr, { AllTrim( kom->name ), kom->kod } )
          Endif
          Skip
        Enddo
        kom->( dbCloseArea() )
        _arr_komit := AClone( arr )
        If Len( arr ) > 1
          If ( a := bit_popup( r, c, arr ) ) != NIL
            _arr_komit := {}
            For i := 1 To Len( a )
              AAdd( _arr_komit, AClone( a[ i ] ) )
            Next
          Endif
        Endif
      Endif
    Endif
  Endif

  Return fl

//   проверить источник финансирования
Function _f_ist_fin()

  Local fl := .t., k

  If Len( _arr_if ) > 0
    If ( human->komu == 0 .or. !Empty( Val( human_->smo ) ) ) .and. AScan( _arr_if, I_FIN_OMS ) > 0
      Return fl // ТФОМС
    Endif
    If human->komu == 5 .and. AScan( _arr_if, I_FIN_PLAT ) > 0
      Return fl // личный счет = платные услуги
    Endif
    fl := .f.
    If ( k := AScan( _what_if[ 2 ], {| x| x[ 1 ] == human->komu .and. x[ 2 ] == human->str_crb } ) ) > 0
      If ( fl := ( AScan( _arr_if, _what_if[ 2, k, 3 ] ) > 0 ) )
        If Len( _arr_if ) == 1 .and. _arr_if[ 1 ] == I_FIN_BUD .and. Len( _arr_komit ) > 0
          fl := ( AScan( _arr_komit, {| x| x[ 2 ] == _what_if[ 2, k, 2 ] } ) > 0 )
        Endif
      Endif
    Endif
  Endif

  Return fl

//   17.03.13
Function _tit_ist_fin( sh )

  Local i, s := "[ "

  If ValType( _arr_if ) == "A" .and. Len( _arr_if ) > 0
    If Len( _arr_if ) == 1 .and. _arr_if[ 1 ] == I_FIN_BUD .and. Len( _arr_komit ) == 1
      s += _arr_komit[ 1, 1 ]
    Else
      For i := 1 To Len( _arr_if )
        s += AllTrim( inieditspr( A__MENUVERT, mm_ist_fin, _arr_if[ i ] ) ) + ", "
      Next
    Endif
    s := SubStr( s, 1, Len( s ) -2 ) + " ]"
    add_string( Center( s, sh ) )
  Endif

  Return Nil

//
Function ret_p3_z( mkod_usl, mkod_vr, mkod_as )

  Local mk[ 8 ], tmp_select := Select(), i := 0, lgruppa, ;
    lshifr, lrazryad, lotdal, lprocent := { 0, 0 }, lkod, ltip, ap2 := { 0, 0 }, ;
    luet := { 0, 0, 0, 0, 0 }

  AFill( mk, 0 )
  If mkod_vr > 0 .or. mkod_as > 0
    Select USL
    Goto ( mkod_usl )
    If !Eof()  // удачное перемещение по БД услуг
      If eq_any( is_oplata, 5, 6, 7 )
        lshifr := fsort_usl( usl->shifr )
        If glob_task == X_PLATN  // для задачи "Платные услуги"
          For i := 1 To 2
            lrazryad := lotdal := 0
            If ( lkod := { mkod_vr, mkod_as }[ i ] ) > 0
              perso->( dbGoto( lkod ) )
              lrazryad := perso->uroven
              lotdal := perso->otdal
            Endif
            If i == 1
              ltip := O5_VR_PLAT  // врач(пл.)
              If is_oplata == 7 .and. human->tip_usl == PU_D_SMO
                ltip := O5_VR_DMS  // врач(ДМС)
              Endif
            Else
              ltip := O5_AS_PLAT  // асс.(пл.)
              If is_oplata == 7 .and. human->tip_usl == PU_D_SMO
                ltip := O5_AS_DMS  // асс.(ДМС)
              Endif
            Endif
            lprocent := ret_opl_5( lshifr, ltip, lrazryad, lotdal )
            mk[ i + 1 ] := lprocent[ 1 ]
            ap2[ i ] := lprocent[ 2 ]
            If is_oplata == 7 .and. emptyall( lprocent[ 1 ], lprocent[ 2 ] )
              luet := ret_opl_7( lshifr, iif( human->tip_usl == PU_D_SMO, 3, 2 ), kart->vzros_reb )
            Endif
          Next
        Else  // для задачи ОМС
          For i := 1 To 2
            lrazryad := lotdal := 0
            If ( lkod := { mkod_vr, mkod_as }[ i ] ) > 0
              perso->( dbGoto( lkod ) )
              lrazryad := perso->uroven
              lotdal := perso->otdal
            Endif
            If i == 1
              ltip := O5_VR_OMS  // врач(ОМС)
            Else
              ltip := O5_AS_OMS  // асс.(ОМС)
            Endif
            lprocent := ret_opl_5( lshifr, ltip, lrazryad, lotdal )
            mk[ i + 1 ] := lprocent[ 1 ]
            ap2[ i ] := lprocent[ 2 ]
            If is_oplata == 7 .and. emptyall( lprocent[ 1 ], lprocent[ 2 ] )
              luet := ret_opl_7( lshifr, 1, human->vzros_reb )
            Endif
          Next
        Endif
        If mkod_vr > 0 .and. mkod_as == 0
          If ap2[ 1 ] > 0
            mk[ 2 ] := ap2[ 1 ]  // заменяем на значение % оплаты при отсутствии ассистента
          Else
            mk[ 2 ] += mk[ 3 ]   // прибавляем долю отсутствующего ассистента
          Endif
          mk[ 3 ] := 0
        Endif
        If mkod_vr == 0 .and. mkod_as > 0
          If ap2[ 2 ] > 0
            mk[ 3 ] := ap2[ 2 ]  // заменяем на значение % оплаты при отсутствии врача
          Else
            mk[ 3 ] += mk[ 2 ]   // прибавляем долю отсутствующего врача
          Endif
          mk[ 2 ] := 0
        Endif
        mk[ 1 ] := mk[ 2 ] + mk[ 3 ]
        If is_oplata == 7 .and. Empty( mk[ 1 ] )
          For i := 1 To 5
            mk[ 3 + i ] := luet[ i ]
          Next
          If luet[ 5 ] == 0 // вариант 2
            If mkod_vr > 0 .and. mkod_as == 0
              mk[ 6 ] += mk[ 7 ]   // прибавляем ст-ть УЕТ отсутствующего ассистента
              mk[ 5 ] := mk[ 7 ] := 0
            Endif
            If mkod_vr == 0 .and. mkod_as > 0
              mk[ 4 ] := mk[ 6 ] := 0 // берем только зарплату ассистента
            Endif
          Else // вариант 1
            If mkod_vr > 0 .and. mkod_as == 0
              mk[ 4 ] += mk[ 5 ]   // прибавляем кол-во УЕТ отсутствующего ассистента
              mk[ 5 ] := 0
            Endif
            If mkod_vr == 0 .and. mkod_as > 0
              mk[ 5 ] += mk[ 4 ]   // прибавляем кол-во УЕТ отсутствующего врача
              mk[ 4 ] := 0
            Endif
          Endif
        Else
          AEval( mk, {| x, i| mk[ i ] := x / 100 } )
        Endif
      Endif
    Endif
  Endif
  Select ( tmp_select )

  Return mk

//
Function open_opl_5()

  If is_oplata == 7
    arr_opl_7 := {}
    r_use( dir_server + "u_usl_7",, "U7" )
    Go Top
    Do While !Eof()
      If !Empty( u7->name )
        AAdd( arr_opl_7, { u7->v_uet_oms, ;
          u7->a_uet_oms, ;
          u7->v_uet_pl,;
          u7->a_uet_pl,;
          u7->v_uet_dms, ;
          u7->a_uet_dms, ;
          { slist2arr( u7->usl_ins ), slist2arr( u7->usl_del ) }, ;
          u7->variant } )
      Endif
      Skip
    Enddo
    u7->( dbCloseArea() )
    len_arr_7 := Len( arr_opl_7 )
  Endif
  g_use( dir_server + "u_usl_5",, "U5" )
  Index On Str( tip, 2 ) + fsort_usl( iif( Empty( usl_2 ), usl_1, usl_2 ) ) + ;
    Str( razryad, 2 ) + Str( otdal, 1 ) to ( cur_dir + "tmp_u5" )

  Return Nil

//  
Function ret_opl_5( lshifr, i, lrazryad, lotdal )

  Local musl_1, musl_2, lprocent := 0, lprocent2 := 0, fl1 := .f., fl2 := .f.

  Select U5
  dbSeek( Str( i, 2 ) + lshifr, .t. )
  Do While u5->tip == i .and. !Eof()
    musl_1 := musl_2 := fsort_usl( u5->usl_1 )
    If !Empty( u5->usl_2 )
      musl_2 := fsort_usl( u5->usl_2 )
    Endif
    If Between( lshifr, musl_1, musl_2 )
      If u5->razryad == 0 .and. !fl1 .and. !fl2
        fl1 := .t.
        lprocent := u5->procent
        lprocent2 := u5->procent2
      Endif
      If lrazryad > 0 .and. lrazryad == u5->razryad .and. u5->otdal == 0 .and. !fl2
        fl2 := .t.
        lprocent := u5->procent
        lprocent2 := u5->procent2
      Endif
      If lotdal > 0 .and. lrazryad > 0 .and. ;
          lrazryad == u5->razryad .and. lotdal == u5->otdal
        lprocent := u5->procent
        lprocent2 := u5->procent2
        Exit
      Endif
    Elseif fl1 .or. fl2
      Exit
    Endif
    Select U5
    Skip
  Enddo
  Return { lprocent, lprocent2 }

//
Function ret_opl_7( lshifr, k, lvzros_reb )

  Local luet[ 5 ], i, luetv, lueta, lstv, lsta

  AFill( luet, 0 )
  For i := 1 To len_arr_7
    If ret_f_nastr( arr_opl_7[ i, 7 ], usl->shifr )
      luetv := opr_uet( lvzros_reb, 1 )
      lueta := opr_uet( lvzros_reb, 2 )
      Do Case
      Case k == 1  // ОМС
        lstv := arr_opl_7[ i, 1 ]
        lsta := arr_opl_7[ i, 2 ]
      Case k == 2  // платные
        lstv := arr_opl_7[ i, 3 ]
        lsta := arr_opl_7[ i, 4 ]
      Case k == 3  // ДМС
        lstv := arr_opl_7[ i, 5 ]
        lsta := arr_opl_7[ i, 6 ]
      Endcase
      luet := { luetv, lueta, lstv, lsta, arr_opl_7[ i, 8 ] }
      Exit
    Endif
  Next

  Return luet

//  
Function _f_koef_z( lstoim, lkol, lkoef, k )

  Local vv := 0, va := 0, v := 0, fl := .f.

  Default k To 1
  If psz == 2 .and. is_oplata == 7 .and. emptyany( lstoim, lkoef[ 1 ] )
    If k == 1 .or. k == 2
      vv := lkoef[ 4 ] * lkoef[ 6 ]
    Endif
    If k == 1 .or. k == 3
      va := lkoef[ 5 ] * lkoef[ 7 ]
    Endif
    fl := .t.
  Endif
  If fl
    v := ( vv + va ) * lkol
  Else
    v := lstoim * lkoef[ k ]
  Endif

  Return v

//  
Function _f_trud( lkol, lvzros_reb, lkod_vr, lkod_as )

  Local mtrud := { 0, 0, 0 }

  mtrud[ 1 ] := round_5( lkol * opr_uet( lvzros_reb ), 4 )
  If is_oplata == 7
    mtrud[ 2 ] := round_5( lkol * opr_uet( lvzros_reb, 1 ), 4 )
    mtrud[ 3 ] := round_5( lkol * opr_uet( lvzros_reb, 2 ), 4 )
  Else
    // mtrud[3] := round_5(mtrud[1]/2,4)
    // mtrud[2] := mtrud[1] - mtrud[3]
    mtrud[ 2 ] := mtrud[ 3 ] := mtrud[ 1 ]
  Endif
  If lkod_vr > 0 .and. lkod_as == 0
    mtrud[ 3 ] := 0
    mtrud[ 2 ] := mtrud[ 1 ]
  Elseif lkod_vr == 0 .and. lkod_as > 0
    mtrud[ 2 ] := 0
    mtrud[ 3 ] := mtrud[ 1 ]
  Endif
  Return mtrud

//
Function cre_tmp7()

  dbCreate( cur_dir + "tmp7", { { "kod_vr", "N", 4, 0 }, ;
    { "kod_as", "N", 4, 0 }, ;
    { "tip", "N", 1, 0 }, ;
    { "kol", "N", 4, 0 }, ;
    { "uet_vr", "N", 11, 4 }, ;
    { "uet_as", "N", 11, 4 }, ;
    { "zrp_vr", "N", 11, 2 }, ;
    { "zrp_as", "N", 11, 2 } } )
  Use ( cur_dir + "tmp7" ) new
  Index On Str( tip, 1 ) + Str( kod_vr, 4 ) + Str( kod_as, 4 ) to ( cur_dir + "tmp7" )

  Return Nil

//  
Function put_tmp7( lkol, lkod_vr, lkod_as, atrud, akoef_z, k )

  Select TMP7
  find ( Str( k, 1 ) + Str( lkod_vr, 4 ) + Str( lkod_as, 4 ) )
  If !Found()
    Append Blank
    tmp7->tip    := k
    tmp7->kod_vr := lkod_vr
    tmp7->kod_as := lkod_as
  Endif
  tmp7->kol += lkol
  tmp7->uet_vr += akoef_z[ 4 ]
  tmp7->uet_as += akoef_z[ 5 ]
  tmp7->zrp_vr += _f_koef_z( 0, lkol, akoef_z, 2 )
  tmp7->zrp_as += _f_koef_z( 0, lkol, akoef_z, 3 )

  Return Nil

//  
Function file_tmp7( ausl, sh, HH, k )

  Local arr_title, i, s, lkod_usl, skol := 0, svuet := 0, sauet := 0, ;
    svzrp := 0, sazrp := 0

  Default k To 1  // ОМС
  If ValType( ausl ) == "A"
    lkod_usl := ausl[ 1 ]
  Else
    Return Nil
  Endif
  arr_title := { ;
    "───┬──────────╥─────┬─────╥───────────────╥─────────────────────", ;
    "   │Количество║ Врач│ Асс.║     У Е Т     ║   Заработная плата  ", ;
    "   │  услуг   ║     │     ╟───────┬───────╫──────────┬──────────", ;
    "   │          ║     │     ║  врач │  асс. ║   Врач   │ Ассистент", ;
    "───┴──────────╨─────┴─────╨───────┴───────╨──────────┴──────────" }
  sh := Len( arr_title[ 1 ] )
  If Select( "PERSO" ) == 0
    r_use( dir_server + "mo_pers",, "PERSO" )
  Endif
  If Select( "TMP7" ) == 0
    Use ( cur_dir + "tmp7" ) index ( cur_dir + "tmp7" ) new
  Endif
  If Select( "UU" ) == 0
    useuch_usl()
  Endif
  Select UU
  find ( Str( lkod_usl, 4 ) )
  If Select( "USL" ) == 0
    r_use( dir_server + "uslugi",, "USL" )
  Endif
  usl->( dbGoto( lkod_usl ) )
  //
  verify_ff( HH - 16, .t., sh )
  add_string( "" )
  add_string( Center( "Алгоритм определения заработной платы по услуге", sh ) )
  add_string( Center( '"' + AllTrim( usl->shifr ) + '"', sh ) )
  add_string( Center( '"' + AllTrim( usl->name ) + '"', sh ) )
  add_string( "" )
  s := "УЕТ для взрослого - врач: " + AllTrim( str_0( uu->vkoef_v, 7, 4 ) ) + ;
    ", асс.: " + AllTrim( str_0( uu->akoef_v, 7, 4 ) )
  add_string( Center( s, sh ) )
  s := "УЕТ для ребенка - врач: " + AllTrim( str_0( uu->vkoef_r, 7, 4 ) ) + ;
    ", асс.: " + AllTrim( str_0( uu->akoef_r, 7, 4 ) )
  add_string( Center( s, sh ) )
  For i := 1 To len_arr_7
    If ret_f_nastr( arr_opl_7[ i, 7 ], usl->shifr )
      add_string( "" )
      If k == 1  // ОМС
        s := "ст-ть ОМС УЕТ для врача: " + lstr( arr_opl_7[ i, 1 ], 12, 2 ) + ;
          ", для асс.: " + lstr( arr_opl_7[ i, 2 ], 12, 2 )
        add_string( Center( s, sh ) )
      Else
        s := "ст-ть платных УЕТ для врача: " + lstr( arr_opl_7[ i, 3 ], 12, 2 ) + ;
          ", для асс.: " + lstr( arr_opl_7[ i, 4 ], 12, 2 )
        add_string( Center( s, sh ) )
        s := "ст-ть ДМС УЕТ для врача: " + lstr( arr_opl_7[ i, 5 ], 12, 2 ) + ;
          ", для асс.: " + lstr( arr_opl_7[ i, 6 ], 12, 2 )
        add_string( Center( s, sh ) )
      Endif
      Exit
    Endif
  Next
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  Select TMP7
  Go Top
  Do While !Eof()
    s := { "ОМС", "пл.", "ДМС" }[ tmp7->tip ] + Str( tmp7->kol, 7 )
    skol += tmp7->kol
    If tmp7->kod_vr == 0
      s += Space( 10 )
    Else
      s += Str( ret_tabn( tmp7->kod_vr ), 10 )
    Endif
    If tmp7->kod_as == 0
      s += Space( 6 )
    Else
      s += Str( ret_tabn( tmp7->kod_as ), 6 )
    Endif
    s += " " + umest_val( tmp7->uet_vr, 7, 4 ) + " " + umest_val( tmp7->uet_as, 7, 4 )
    svuet += tmp7->uet_vr
    sauet += tmp7->uet_as
    s += Str( tmp7->zrp_vr, 11, 2 ) + Str( tmp7->zrp_as, 11, 2 )
    svzrp += tmp7->zrp_vr
    sazrp += tmp7->zrp_as
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( s )
    Select TMP7
    Skip
  Enddo
  add_string( Replicate( "─", sh ) )
  s := Str( skol, 10 ) + Space( 10 + 6 )
  s += " " + umest_val( svuet, 7, 4 ) + " " + umest_val( sauet, 7, 4 ) + ;
    Str( svzrp, 11, 2 ) + Str( sazrp, 11, 2 )
  add_string( s )
  add_string( Center( "Итого УЕТ: " + LTrim( umest_val( svuet + sauet, 11, 4 ) ) + ;
    ", зар.плата: " + lstr( svzrp + sazrp, 12, 2 ), sh ) )

  Return Nil

//
Function o_proverka( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "Общая проверка по ~запросу", ;
      "Не введен код ~врача", ;
      "Не введен код ~ассистента", ;
      "Врач + ~больные за день", ;
      "Одинаковые сочетания - № карты + ~дата вызова", ;
      "~Рассогласования в базах данных" }
    mas_msg := { "Общие проверки (многовариантный запрос)", ;
      "Проверка листов учета на отсутствие кода врача", ;
      "Проверка листов учета на отсутствие кода ассистента", ;
      "Вывод списка принятых больных конкретным врачом за день", ;
      "Поиск одинаковых сочетаний номера карты вызова + даты вызова", ;
      "Поиск рассогласований в базах данных (не заполнены или неверно заполнены поля)" }
    mas_fun := { "o_proverka(11)", ;
      "o_proverka(12)", ;
      "o_proverka(13)", ;
      "o_proverka(14)", ;
      "o_proverka(15)", ;
      "o_proverka(16)" }
    uch_otd := saveuchotd()
    Private p_net_otd := .t.
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
    restuchotd( uch_otd )
  Case k == 11
    proch_proverka()
  Case k == 12
    o_pr_vr_as( 1 )
  Case k == 13
    o_pr_vr_as( 2 )
  Case k == 14
    i_vr_boln()
  Case k == 15
    posik_smp_n_d()
  Case k == 16
    poisk_rassogl()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// 14.10.24
Function proch_proverka()

  Static sd, sl := 2
  Static mm_schet := { { "по счетам         ", 1 }, ;
    { "по реестрам       ", 2 }, ;
    { "по невыписанным...", 3 } }
  Static mm_logical := { { "логическое И  ", 1 }, ;
    { "логическое ИЛИ", 2 } }
  Local buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    name_file := "proverka" + stxt, i, j, arr_usl, ;
    sh := 64, HH := 57, reg_print := 2, r1 := 9, cdate, mdiagnoz, ;
    mm_da_net := { { "нет", 1 }, { "да ", 2 } }, lcount_uch

  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
    Return Nil
  Endif
  Default sd To sys_date
  Private pdate_schet, m1schet := 1, mschet, ;
    m1logic := sl, mlogic, ;
    m1mkb := 0, mmkb := Space( 3 ), ;
    m1usl_dn := 0, musl_dn := Space( 3 ), ;
    m1ns_usl := 0, mns_usl := Space( 3 ), ;
    m1ns1usl := 1, mns1usl, ;
    m1pervich := 0, mpervich := Space( 3 ), ;
    mkol := 0, msrok1 := 0, msrok2 := 0, ;
    m1date_schet := 0, mdate_schet := Space( 10 ), ;
    mm_ns1usl := { { "только по этому случаю  ", 1 }, ;
                    { "по всем случаям больного", 2 } }, ;
    gl_area := { r1, 2, MaxRow() -2, MaxCol() -2, 0 }
  mns1usl := inieditspr( A__MENUVERT, mm_ns1usl, m1ns1usl )
  mschet := inieditspr( A__MENUVERT, mm_schet, m1schet )
  mlogic := inieditspr( A__MENUVERT, mm_logical, m1logic )
  r1 := MaxRow() -14
  box_shadow( r1, 2, MaxRow() -2, MaxCol() -2,, "Ввод данных для поиска информации", color8 )
  Do While .t.
    j := r1 + 1
    ++j
    @ j, 4 Say "Где искать" Get mschet ;
      reader {| x| menu_reader( x, mm_schet, A__MENUVERT,,, .f. ) } ;
      valid {|| iif( m1schet > 1, mdate_schet := CToD( "" ), ), .t. }
    @ Row(), Col() + 3 Say "Дата счёта" Get mdate_schet ;
      reader {| x| menu_reader( x, ;
      { {| k, r, c| k := year_month( r + 1, c ), ;
      if( k == nil, nil, ( pdate_schet := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
      k } }, A__FUNCTION,,, .f. ) } ;
      When m1schet == 1
    ++j
    @ j, 4 Say "Метод поиска" Get mlogic ;
      reader {| x| menu_reader( x, mm_logical, A__MENUVERT,,, .f. ) }
    ++j
    @ j, 4 Say "Максимальное количество оказанных услуг" Get mkol Pict "999"
    ++j
    @ j, 4 Say "Срок лечения (в днях): минимальный" Get msrok1 Pict "999"
    @ Row(), Col() Say ", максимальный" Get msrok2 Pict "999"
    ++j
    @ j, 4 Say "Количество одноименных услуг <= количества дней лечения?" Get musl_dn ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
    ++j
    @ j, 4 Say "Проверять все диагнозы на соответствие МКБ-10 (по ОМС)?" Get mmkb ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
    ++j
    @ j, 4 Say "Проверять несовместимость услуг по дате оказания?" Get mns_usl ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
    ++j
    @ j, 4 Say "- как выполнять данную проверку" Get mns1usl ;
      reader {| x| menu_reader( x, mm_ns1usl, A__MENUVERT,,, .f. ) }
    ++j
    @ j, 4 Say "Проверять наличие более 1 стом. первичного приема в году?" Get mpervich ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
    status_key( "^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода" )
    myread()
    If LastKey() == K_ESC
      Exit
    Elseif m1schet == 1
      If Empty( m1date_schet )
        func_error( 4, "Обязательно должно быть заполнено поле ДАТА СЧЕТА!" )
        Loop
      Elseif pdate_schet[ 1 ] < 2016
        func_error( 4, "Проверяется только после 2016 года!" )
        Loop
      Endif
    Endif
    If f_esc_enter( "начала проверки" )
      sd := mdate_schet ; sl := m1logic
      mywait()
      dbCreate( cur_dir + "tmp", { { "schet", "N", 6, 0 }, ;
        { "kod", "N", 7, 0 } } )
      dbCreate( cur_dir + "tmpk", { { "rec", "N", 7, 0 }, ;
        { "name", "C", 100, 0 } } )
      Use ( cur_dir + "tmp" ) new
      Index On Str( schet, 6 ) + Str( kod, 7 ) to ( cur_dir + "tmp" )
      Use ( cur_dir + "tmpk" ) new
      Index On Str( rec, 7 ) to ( cur_dir + "tmpk" )
      fl_exit := .f.
      fl_srok := ( msrok1 > 0 .or. msrok2 > 0 )
      r_use( dir_server + "kartotek",, "KART" )
      r_use( dir_server + "ns_usl_k", dir_server + "ns_usl_k", "NSK" )
      g_use( dir_server + "ns_usl",, "NS" )
      If m1ns_usl == 2
        js := 0
        Go Top
        Do While !Eof()
          j := 0
          Select NSK
          find ( Str( ns->( RecNo() ), 6 ) )
          Do While nsk->kod == ns->( RecNo() ) .and. !Eof()
            ++j
            Skip
          Enddo
          Select NS
          g_rlock( forever )
          ns->kol := j
          js += j
          Unlock
          Skip
        Enddo
        If Empty( js )
          m1ns_usl := 0 ; mns_usl := Space( 3 )
        Endif
      Endif
      r_use( dir_exe() + "_mo_mkb", cur_dir + "_mo_mkb", "MKB_10" )
      r_use( dir_server + "mo_uch",, "UCH" )
      r_use( dir_server + "mo_otd",, "OTD" )
      use_base( "lusl" )
      use_base( "luslc" )
      use_base( "uslugi" )
      r_use( dir_server + "uslugi1", { dir_server + "uslugi1", ;
        dir_server + "uslugi1s" }, "USL1" )
      r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
      r_use( dir_server + "mo_su",, "MOSU" )
      r_use( dir_server + "mo_hu", dir_server + "mo_hu", "MOHU" )
      Set Relation To u_kod into MOSU
      js := jh := jt := 0
      waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
      If m1schet == 1
        r_use( dir_server + "human_2",, "HUMAN_2" )
        r_use( dir_server + "human_",, "HUMAN_" )
        r_use( dir_server + "human", { dir_server + "humans", ;
          dir_server + "humankk" }, "HUMAN" )
        Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
        r_use( dir_server + "schet_",, "SCHET_" )
        r_use( dir_server + "schet", dir_server + "schetd", "SCHET" )
        Set Relation To RecNo() into SCHET_
        Set Filter To Empty( schet_->IS_DOPLATA )
        dbSeek( pdate_schet[ 7 ], .t. )
        Do While schet->pdate <= pdate_schet[ 8 ] .and. !Eof()
          ++js
          Select HUMAN
          find ( Str( schet->kod, 6 ) )
          Do While human->schet == schet->kod .and. !Eof()
            ++jh
            @ MaxRow(), 1 Say lstr( js ) Color cColorSt2Msg
            @ Row(), Col() Say "/" Color "W/R"
            @ Row(), Col() Say lstr( jh ) Color cColorStMsg
            If jt > 0
              @ Row(), Col() Say "/" Color "W/R"
              @ Row(), Col() Say lstr( jt ) Color "G+/R"
            Endif
            updatestatus()
            If Inkey() == K_ESC
              fl_exit := .t. ; Exit
            Endif
            jt := f1proch_proverka( jt )
            Select HUMAN
            Skip
          Enddo
          If fl_exit ; exit ; Endif
          Select SCHET
          Skip
        Enddo
      Else
        r_use( dir_server + "human_2",, "HUMAN_2" )
        r_use( dir_server + "human_",, "HUMAN_" )
        r_use( dir_server + "human", { dir_server + "humann", ;
          dir_server + "humankk" }, "HUMAN" )
        Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
        dbSeek( "1", .t. )
        Do While human->tip_h < B_SCHET .and. !Eof()
          If iif( m1schet == 3, Empty( human_->reestr ), !Empty( human_->reestr ) ) .and. Year( human->k_data ) > 2017
            ++jh
            @ MaxRow(), 1 Say lstr( jh ) Color cColorStMsg
            If jt > 0
              @ Row(), Col() Say "/" Color "W/R"
              @ Row(), Col() Say lstr( jt ) Color "G+/R"
            Endif
            updatestatus()
            If Inkey() == K_ESC
              fl_exit := .t. ; Exit
            Endif
            jt := f1proch_proverka( jt )
          Endif
          Select HUMAN
          Skip
        Enddo
      Endif
      j := tmp->( LastRec() )
      Close databases
      If fl_exit
        // ничего - просто выход
      Elseif j == 0
        func_error( 4, "Проверка проведена успешно! Нарушений нет." )
      Else
        mywait()
        r_use( dir_server + "mo_otd",, "OTD" )
        r_use( dir_server + "schet_",, "SCHET_" )
        r_use( dir_server + "schet",, "SCHET" )
        Set Relation To RecNo() into SCHET_
        r_use( dir_server + "human_",, "HUMAN_" )
        r_use( dir_server + "human", dir_server + "humank", "HUMAN" )
        Set Relation To RecNo() into HUMAN_, To otd into OTD
        Use ( cur_dir + "tmp" ) new
        Set Relation To Str( kod, 7 ) into HUMAN, To schet into SCHET
        Index On schet->nomer_s + Str( tmp->schet, 6 ) + Upper( Left( human->fio, 20 ) ) to ( cur_dir + "tmp" )
        Use ( cur_dir + "tmpk" ) new
        Index On Str( rec, 7 ) to ( cur_dir + "tmpk" )
        fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
        add_string( "" )
        If m1schet == 1
          add_string( Center( Expand( "РЕЗУЛЬТАТ ПРОВЕРКИ СЧЕТОВ" ), sh ) )
          add_string( Center( pdate_schet[ 4 ], sh ) )
        Else
          add_string( Center( "РЕЗУЛЬТАТ ПРОВЕРКИ ПО НЕВЫПИСАННЫМ СЧЕТАМ" + ;
            iif( m1schet == 2, " (по реестрам)", "" ), sh ) )
        Endif
        titlen_uch( st_a_uch, sh )
        add_string( "" )
        old_s := 0
        Select TMP
        Go Top
        Do While !Eof()
          verify_ff( HH, .t., sh )
          If !( old_s == tmp->schet )
            add_string( "" )
            add_string( "СЧЕТ № " + RTrim( schet_->nschet ) )
            add_string( Replicate( "=", 22 ) )
          Endif
          add_string( "" )
          add_string( iif( m1schet == 1, lstr( human_->schet_zap ) + ". ", "" ) + ;
            AllTrim( human->fio ) + ", " + full_date( human->date_r ) + ;
            iif( Empty( otd->SHORT_NAME ), "", " [" + AllTrim( otd->SHORT_NAME ) + "]" ) + ;
            " " + date_8( human->n_data ) + "-" + date_8( human->k_data ) )
          Select TMPK
          find ( Str( tmp->( RecNo() ), 7 ) )
          Do While tmpk->rec == tmp->( RecNo() ) .and. !Eof()
            add_string( Space( 10 ) + RTrim( tmpk->name ) )
            Skip
          Enddo
          old_s := tmp->schet
          Select TMP
          Skip
        Enddo
        FClose( fp )
        Close databases
        viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
      Endif
    Endif
    Exit
  Enddo
  Close databases
  RestScreen( buf ) ; SetColor( tmp_color )

  Return Nil

// 22.08.23
Function f1proch_proverka( jt )

  Local i, j, k, k1, ju, fl_tmp, fl_next, arr_usl := {}, srok_l, mvid_ud, ;
    arr, s, arr_date, bd1, bd2, y, lshifr, u_1_stom := "", not_ksg := .t.

  If human_->oplata < 9 .and. f_is_uch( st_a_uch, human->lpu )
    srok_l := human->k_data - human->n_data + 1
    fl_tmp := .f. ; fl_next := .t.
    // проверим правильность определения КСГ
    If human_->USL_OK < 3
      If ( y := Year( human->K_DATA ) ) > 2018
        arr := definition_ksg()
      Else
        arr := definition_ksg()   // definition_KSG_18() просто подменил
      Endif
      If Select( "K006" ) > 0
        k006->( dbCloseArea() )
      Endif
      If Len( arr ) == 7 // диализ
        //
      Elseif !Empty( arr[ 2 ] )
        If !fl_tmp
          Select TMP
          addrec( 6 )
          If m1schet == 1
            tmp->schet := schet->( RecNo() )
          Endif
          tmp->kod := human->( RecNo() )
          fl_tmp := .t.
        Endif
        For i := 1 To Len( arr[ 2 ] )
          Select TMPK
          addrec( 7 )
          tmpk->rec := tmp->( RecNo() )
          tmpk->name := arr[ 2, i ]
        Next
      Elseif !Empty( arr[ 3 ] )
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          usl->( dbGoto( hu->u_kod ) )
          If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
            lshifr := usl->shifr
          Endif
          If AllTrim( lshifr ) == arr[ 3 ] // уже стоит тот же КСГ
            If !( Round( hu->u_cena, 2 ) == Round( arr[ 4 ], 2 ) ) // не та цена
              If !fl_tmp
                Select TMP
                addrec( 6 )
                If m1schet == 1
                  tmp->schet := schet->( RecNo() )
                Endif
                tmp->kod := human->( RecNo() )
                fl_tmp := .t.
              Endif
              Select TMPK
              addrec( 7 )
              tmpk->rec := tmp->( RecNo() )
              tmpk->name := "в л/у для КСГ=" + arr[ 3 ] + " стоит цена " + lstr( hu->u_cena, 10, 2 ) + ", а должна быть " + lstr( arr[ 4 ], 10, 2 )
            Endif
            Exit
          Endif
          Select LUSL
          find ( lshifr ) // длина lshifr 10 знаков
          If Found() .and. ( Left( lshifr, 5 ) == "1.12." .or. is_ksg( lusl->shifr ) ) // стоит другой КСГ
            If !fl_tmp
              Select TMP
              addrec( 6 )
              If m1schet == 1
                tmp->schet := schet->( RecNo() )
              Endif
              tmp->kod := human->( RecNo() )
              fl_tmp := .t.
            Endif
            Select TMPK
            addrec( 7 )
            tmpk->rec := tmp->( RecNo() )
            tmpk->name := "в л/у стоит КСГ=" + AllTrim( lshifr ) + "(" + lstr( hu->u_cena, 10, 2 ) + ;
              "), а должна быть " + arr[ 3 ] + "(" + lstr( arr[ 4 ], 10, 2 ) + ")"
            Exit
          Endif
          Select HU
          Skip
        Enddo
      Endif
    Endif
    //
    If ( mkol > 0 .or. m1usl_dn == 2 ) .and. fl_next
      arr_usl := {}
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        usl->( dbGoto( hu->u_kod ) )
        If ( i := AScan( arr_usl, {| x| x[ 1 ] == usl->shifr } ) ) == 0
          AAdd( arr_usl, { usl->shifr, 0 } ) ; i := Len( arr_usl )
        Endif
        arr_usl[ i, 2 ] += hu->kol_1
        Skip
      Enddo
      _ju := 0
      For i := 1 To Len( arr_usl )
        If mkol > 0 .and. arr_usl[ i, 2 ] > mkol
          ++_ju
          If !fl_tmp
            Select TMP
            addrec( 6 )
            If m1schet == 1
              tmp->schet := schet->( RecNo() )
            Endif
            tmp->kod := human->( RecNo() )
            fl_tmp := .t.
          Endif
          Select TMPK
          addrec( 7 )
          tmpk->rec := tmp->( RecNo() )
          tmpk->name := "кол-во услуг " + AllTrim( arr_usl[ i, 1 ] ) + " - " + lstr( arr_usl[ i, 2 ] )
        Endif
        If m1usl_dn == 2 .and. arr_usl[ i, 2 ] > srok_l
          ++_ju
          If !fl_tmp
            Select TMP
            addrec( 6 )
            If m1schet == 1
              tmp->schet := schet->( RecNo() )
            Endif
            tmp->kod := human->( RecNo() )
            fl_tmp := .t.
          Endif
          Select TMPK
          addrec( 7 )
          tmpk->rec := tmp->( RecNo() )
          tmpk->name := "кол-во услуг " + AllTrim( arr_usl[ i, 1 ] ) + ":  " + ;
            lstr( arr_usl[ i, 2 ] ) + " > " + lstr( srok_l ) + " (срока лечения)"
        Endif
      Next
      If _ju == 0 ; fl_next := .f. ; Endif
    Endif
    If m1logic == 2 ; fl_next := .t. ; Endif
    //
    If fl_srok .and. fl_next
      fl := .f.
      If msrok1 > 0 .and. msrok2 == 0
        fl := ( msrok1 <= srok_l )
      Elseif msrok1 == 0 .and. msrok2 > 0
        fl := ( srok_l <= msrok2 )
      Elseif msrok1 > 0 .and. msrok2 > 0
        fl := Between( srok_l, msrok1, msrok2 )
      Endif
      If fl
        If !fl_tmp
          Select TMP
          addrec( 6 )
          If m1schet == 1
            tmp->schet := schet->( RecNo() )
          Endif
          tmp->kod := human->( RecNo() )
          fl_tmp := .t.
        Endif
        Select TMPK
        addrec( 7 )
        tmpk->rec := tmp->( RecNo() )
        tmpk->name := "срок лечения (в днях) - " + lstr( srok_l )
      Else
        fl_next := .f.
      Endif
    Endif
    If m1logic == 2 ; fl_next := .t. ; Endif
    //
    If m1mkb == 2 .and. fl_next
      mdiagnoz := diag_to_array()
      s := ""
      For i := 1 To Len( mdiagnoz )
        Select MKB_10
        find ( PadR( mdiagnoz[ i ], 6 ) )
        If !between_date( mkb_10->dbegin, mkb_10->dend, human->k_data )
          s += AllTrim( mdiagnoz[ i ] ) + " "
        Endif
      Next
      If !Empty( s )
        If !fl_tmp
          Select TMP
          addrec( 6 )
          If m1schet == 1
            tmp->schet := schet->( RecNo() )
          Endif
          tmp->kod := human->( RecNo() )
          fl_tmp := .t.
        Endif
        Select TMPK
        addrec( 7 )
        tmpk->rec := tmp->( RecNo() )
        tmpk->name := "диагноз не входит в ОМС: " + s
      Else
        fl_next := .f.
      Endif
    Endif
    If m1logic == 2 ; fl_next := .t. ; Endif
    //
    If m1ns_usl == 2 .and. fl_next
      // сначала проверим данный случай
      arr_usl := {} ; arr_date := {}
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        usl->( dbGoto( hu->u_kod ) )
        If ( i := AScan( arr_usl, {| x| x[ 1 ] == usl->shifr .and. x[ 2 ] == hu->date_u } ) ) == 0
          AAdd( arr_usl, { usl->shifr, hu->date_u, 0 } ) ; i := Len( arr_usl )
        Endif
        arr_usl[ i, 3 ] += hu->kol_1
        If AScan( arr_date, hu->date_u ) == 0
          AAdd( arr_date, hu->date_u )
        Endif
        Skip
      Enddo
      If m1ns1usl == 2  // теперь проверим остальные случаи
        Select HUMAN
        rec_human := human->( RecNo() )
        bd1 := human->n_data ; bd2 := human->k_data
        mkod_k := human->kod_k
        Set Order To 2
        //
        find ( Str( mkod_k, 7 ) )
        Do While human->kod_k == mkod_k .and. !Eof()
          If rec_human != human->( RecNo() ) ; // текущий случай пропускаем
            .and. human->n_data <= bd2 .and. bd1 <= human->k_data // и диапазон лечения частично перекрывается
            Select HU
            find ( Str( human->kod, 7 ) )
            Do While hu->kod == human->kod .and. !Eof()
              usl->( dbGoto( hu->u_kod ) )
              If ( i := AScan( arr_usl, {| x| x[ 1 ] == usl->shifr .and. x[ 2 ] == hu->date_u } ) ) > 0
                arr_usl[ i, 3 ] += hu->kol_1
              Endif
              Skip
            Enddo
          Endif
          Select HUMAN
          Skip
        Enddo
        Select HUMAN
        Set Order To 1
        Goto ( rec_human )
      Endif
      k1 := 0
      Select NS
      Go Top
      Do While !Eof()
        For i := 1 To Len( arr_date )
          k := 0
          If ns->kol == 1
            Select NSK
            find ( Str( ns->( RecNo() ), 6 ) )
            If ( j := AScan( arr_usl, {| x| x[ 1 ] == nsk->shifr .and. x[ 2 ] == arr_date[ i ] } ) ) > 0
              k := arr_usl[ j, 3 ]
            Endif
          Else
            Select NSK
            find ( Str( ns->( RecNo() ), 6 ) )
            Do While nsk->kod == ns->( RecNo() ) .and. !Eof()
              If AScan( arr_usl, {| x| x[ 1 ] == nsk->shifr .and. x[ 2 ] == arr_date[ i ] } ) > 0
                ++k
              Endif
              Skip
            Enddo
          Endif
          If k > 1
            ++k1
            If !fl_tmp
              Select TMP
              addrec( 6 )
              If m1schet == 1
                tmp->schet := schet->( RecNo() )
              Endif
              tmp->kod := human->( RecNo() )
              fl_tmp := .t.
            Endif
            Select TMPK
            addrec( 7 )
            tmpk->rec := tmp->( RecNo() )
            tmpk->name := "несовместимость услуг по дате: " + DToC( c4tod( arr_date[ i ] ) ) + " " + AllTrim( ns->name )
          Endif
        Next
        Select NS
        Skip
      Enddo
      If k1 == 0
        fl_next := .f.
      Endif
    Endif
    If m1logic == 2 ; fl_next := .t. ; Endif
    //
    If m1pervich == 2 .and. fl_next
      k1 := 0
      // сначала проверим данный случай
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        usl->( dbGoto( hu->u_kod ) )
        lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
        If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
          lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
          If f_is_1_stom( lshifr )
            u_1_stom := lshifr ; Exit
          Endif
        Endif
        Select HU
        Skip
      Enddo
      If !Empty( u_1_stom )  // теперь проверим остальные случаи
        Select HUMAN
        rec_human := human->( RecNo() )
        d2_year := Year( human->k_data )
        m1novor := human_->NOVOR
        mkod_k := human->kod_k
        Set Order To 2
        //
        find ( Str( mkod_k, 7 ) )
        Do While human->kod_k == mkod_k .and. !Eof()
          If ( fl := ( d2_year == Year( human->k_data ) .and. rec_human != human->( RecNo() ) ) )
            //
          Endif
          If fl .and. human->schet > 0 .and. eq_any( human_->oplata, 2, 9 )
            fl := .f. // лист учёта снят по акту или выставлен повторно
          Endif
          If fl .and. m1novor != human_->NOVOR
            fl := .f. // лист учёта на новорожденного (или наоборот)
          Endif
          If fl .and. human_->idsp == 4 // лечебно-диагностическая процедура
            Select HU
            find ( Str( human->kod, 7 ) )
            Do While hu->kod == human->kod .and. !Eof()
              usl->( dbGoto( hu->u_kod ) )
              lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
              If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
                lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
                If f_is_1_stom( lshifr )
                  ++k1
                  If !fl_tmp
                    Select TMP
                    addrec( 6 )
                    If m1schet == 1
                      tmp->schet := schet->( RecNo() )
                    Endif
                    tmp->kod := human->( RecNo() )
                    fl_tmp := .t.
                  Endif
                  Select TMPK
                  addrec( 7 )
                  tmpk->rec := tmp->( RecNo() )
                  tmpk->name := 'перв.стом.приём ' + u_1_stom + ', и в случае ' + date_8( human->n_data ) + '-' + date_8( human->k_data ) + ': ' + lshifr
                Endif
              Endif
              Select HU
              Skip
            Enddo
          Endif
          Select HUMAN
          Skip
        Enddo
        Select HUMAN
        Set Order To 1
        Goto ( rec_human )
      Endif
      If k1 == 0
        fl_next := .f.
      Endif
    Endif
    //
    If fl_tmp
      If m1logic == 1 .and. !fl_next
        If m1schet == 1
          k := schet->( RecNo() )
        Else
          k := 0
        Endif
        Select TMP
        find ( Str( k, 6 ) + Str( human->( RecNo() ), 7 ) )
        If Found()
          Select TMPK
          Do While .t.
            find ( Str( tmp->( RecNo() ), 7 ) )
            If !Found() ; exit ; Endif
            deleterec( .t. )
          Enddo
          Select TMP
          deleterec()
        Endif
      Else
        If++jt % 2000 == 0
          Commit
        Endif
      Endif
    Endif
  Endif

  Return jt

//  
Function o_pr_vr_as( reg )

  Static sj := 1
  Local mas_pmt := { "Проверка по ~невыписанным счетам", ;
    "Проверка по дате ~выписки счета" }
  Local mas_msg := { "Проверка на отсутствие кода по невыписанным счетам", ;
    "Проверка на отсутствие кода по дате выписки счета" }
  Local i, j, k, arr, fl, fl_exit := .f., buf := save_maxrow(), ;
    s, sh, HH := 57, arr_title, name_file := "proverka" + stxt, ;
    arr_usl := {}, lcount_uch

  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
    Return Nil
  Endif
  If ( j := popup_prompt( T_ROW, T_COL - 5, sj, mas_pmt, mas_msg ) ) == 0
    Return Nil
  Endif
  sj := j
  If j == 2 .and. ( arr := year_month() ) == NIL
    Return Nil
  Endif
  If ( k := f_alert( { 'Каким образом производить проверку на отсутствие кодов персонала.', ;
      "Выберите действие:" }, ;
      { " По ~всем услугам ", ;
      " ~Исключая некоторые услуги " }, ;
      1, "N+/BG", "R/BG",,, col1menu ) ) == 0
    Return Nil
  Elseif k == 2
    dbCreate( cur_dir + "tmp", { ;
      { "U_KOD",    "N",      4,      0 }, ;  // код услуги
      { "U_SHIFR",    "C",     10,      0 }, ;  // шифр услуги
      { "U_NAME",     "C",     65,      0 } } )  // наименование услуги
    Use ( cur_dir + "tmp" )
    Index On Str( u_kod, 4 ) to ( cur_dir + "tmpk" )
    Index On fsort_usl( u_shifr ) to ( cur_dir + "tmpn" )
    Close databases
    ob2_v_usl()
    Use ( cur_dir + "tmp" )
    dbEval( {|| AAdd( arr_usl, tmp->u_kod ) } )
    Use
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  dbCreate( cur_dir + "tmp", { { "rec", "N", 7, 0 } } )
  Use ( cur_dir + "tmp" ) new
  If j == 1
    r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humann", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    dbSeek( "1", .t. )
    Do While human->tip_h < B_SCHET .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If human_->oplata < 9 .and. f_is_uch( st_a_uch, human->lpu )
        fl := .f.
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          If AScan( arr_usl, hu->u_kod ) == 0
            If reg == 1
              If hu->kod_vr == 0
                fl := .t. ; Exit
              Endif
            Else
              If hu->kod_as == 0
                fl := .t. ; Exit
              Endif
            Endif
          Endif
          Select HU
          Skip
        Enddo
        If fl
          Select TMP
          Append Blank
          tmp->rec := human->( RecNo() )
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
  Elseif j == 2
    r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server + "schet_",, "SCHET_" )
    r_use( dir_server + "schet", dir_server + "schetd", "SCHET" )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( arr[ 7 ], .t. )
    Do While schet->pdate <= arr[ 8 ] .and. !Eof()
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human_->oplata < 9 .and. f_is_uch( st_a_uch, human->lpu )
          fl := .f.
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            If AScan( arr_usl, hu->u_kod ) == 0
              If reg == 1
                If hu->kod_vr == 0
                  fl := .t. ; Exit
                Endif
              Else
                If hu->kod_as == 0
                  fl := .t. ; Exit
                Endif
              Endif
            Endif
            Select HU
            Skip
          Enddo
          If fl
            Select TMP
            Append Blank
            tmp->rec := human->( RecNo() )
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
      If fl_exit ; exit ; Endif
      Select SCHET
      Skip
    Enddo
    Select SCHET
    Set Index To
  Endif
  If tmp->( LastRec() ) > 0
    mywait()
    s := { "Отделение", "Номер и дата счета" }[ j ]
    arr_title := { ;
      "─────────────────────────────────────────────────┬───────────────────┬──────────", ;
      "              Ф.И.О. больного                    │"   + PadC( s, 19 ) +  "│  Сумма   ", ;
      "─────────────────────────────────────────────────┴───────────────────┴──────────" }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "Список больных, у которых в оказанных услугах", sh ) )
    add_string( Center( "отсутствует код " + { "врача", "ассистента" }[ reg ], sh ) )
    add_string( "" )
    If j == 1
      add_string( Center( "[ по невыписанным счетам ]", sh ) )
    Else
      add_string( Center( "[ по дате выписки счета ]", sh ) )
      add_string( Center( arr[ 4 ], sh ) )
    Endif
    titlen_uch( st_a_uch, sh, lcount_uch )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    //
    Select HUMAN
    Set Index To
    r_use( dir_server + "mo_otd",, "OTD" )
    Select TMP
    Set Relation To rec into HUMAN
    Index On Upper( human->fio ) to ( cur_dir + "tmp" )
    Go Top
    i := 0
    Do While !Eof()
      s := Str( ++i, 4 ) + ". " + Left( human->fio, 43 ) + " "
      If j == 1
        Select OTD
        Goto ( human->otd )
        s += otd->short_name
      Else
        Select SCHET
        Goto ( human->schet )
        s += schet_->NSCHET + " " + date_8( schet_->DSCHET )
      Endif
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( s + put_kope( human->cena_1, 11 ) )
      Select TMP
      Skip
    Enddo
    Close databases
    FClose( fp )
    viewtext( name_file,,,, .f.,,, 2 )
  Else
    func_error( 4, "Не обнаружено услуг с незанесенным персоналом!" )
  Endif
  Close databases
  rest_box( buf )

  Return Nil

//   Вывод списка принятых больных конкретным врачом за день
Function i_vr_boln()

  Local sh := 80, HH := 60, old_d := "", begin_date, end_date, arr_m, ;
    name_file := "lech_vr" + stxt, i, j, s, skol := 0, ab := {}

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If !input_perso( T_ROW, T_COL - 5 )
    Return Nil
  Endif
  begin_date := arr_m[ 7 ]
  end_date   := arr_m[ 8 ]
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  s := " Ф.И.О. и должность врача: " + AllTrim( glob_human[ 2 ] ) + " [" + lstr( glob_human[ 5 ] ) + "]"
  If Len( glob_human ) > 5 .and. !Empty( glob_human[ 6 ] )
    s += " (" + glob_human[ 6 ] + ")"       // должность
  Endif
  add_string( Center( s, sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( "" )
  r_use( dir_server + "uslugi",, "USL" )
  r_use( dir_server + "human_",, "HUMAN_" )
  r_use( dir_server + "human",, "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  r_use( dir_server + "human_u", dir_server + "human_uv", "HU" )
  dbSeek( Str( glob_human[ 1 ], 4 ) + begin_date, .t. )
  Do While hu->kod_vr == glob_human[ 1 ] .and. hu->date_u <= end_date .and. !Eof()
    human->( dbGoto( hu->kod ) )
    If human_->oplata < 9
      If !( old_d == hu->date_u )
        If !Empty( old_d )
          For i := 1 To Len( ab )
            s := Str( i, 5 ) + ". " + AllTrim( ab[ i, 2 ] ) + " ("
            For j := 1 To Len( ab[ i, 3 ] )
              usl->( dbGoto( ab[ i, 3, j ] ) )
              s += AllTrim( usl->shifr ) + ","
            Next
            s := Left( s, Len( s ) -1 ) + ")"
            verify_ff( HH, .t., sh )
            add_string( s )
            ++skol
          Next
        Endif
        verify_ff( HH - 1, .t., sh )
        old_d := hu->date_u ; ab := {}
        add_string( full_date( c4tod( old_d ) ) )
      Endif
      If ( i := AScan( ab, {| x| x[ 1 ] == human->kod_k } ) ) == 0
        AAdd( ab, { human->kod_k, human->fio, {} } ) ; i := Len( ab )
      Endif
      If ( j := AScan( ab[ i, 3 ], hu->u_kod ) ) == 0
        AAdd( ab[ i, 3 ], hu->u_kod )
      Endif
    Endif
    Select HU
    Skip
  Enddo
  If !Empty( old_d )
    For i := 1 To Len( ab )
      s := Str( i, 5 ) + ". " + AllTrim( ab[ i, 2 ] ) + " ("
      For j := 1 To Len( ab[ i, 3 ] )
        usl->( dbGoto( ab[ i, 3, j ] ) )
        s += AllTrim( usl->shifr ) + ","
      Next
      s := Left( s, Len( s ) -1 ) + ")"
      verify_ff( HH, .t., sh )
      add_string( s )
      ++skol
    Next
  Endif
  If skol > 0
    add_string( "Всего больных: " + lstr( skol ) )
  Endif
  FClose( fp )
  Close databases
  viewtext( name_file,,,, .t.,,, 2 )

  Return Nil

//   14.05.13 Поиск одинаковых сочетаний номера карты вызова + даты вызова
Function posik_smp_n_d()

  ne_real()
/*
Local i, j, k, arr, s, buf := save_maxrow(), fl_exit := .f., sh := 65, ;
      old_f, old_n, old_d, HH := 80, reg_print := 1, ;
      name_file := "smp_n_d"+stxt
if (arr_m := year_month()) == NIL
  return NIL
endif
mywait()
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Поиск повторов номера карты вызова (за день)",sh))
add_string(center(arr_m[4],sh))
add_string("")
dbcreate(cur_dir+"tmp",{{"uch_doc","C",10,0}})
use (cur_dir+"tmp") new
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_
old_f := replicate("-",50)
old_n := replicate("-",10)
old_d := arr_m[5] - 1
dbseek(dtos(arr_m[5]),.t.)
do while human->k_data <= arr_m[6] .and. !eof()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if human_->usl_ok == 4
    if old_d == human->k_data .and. old_n == human->uch_doc
      add_string('"'+alltrim(old_n)+'" от '+date_8(old_d)+" "+alltrim(old_f))
    endif
      add_string('"'+alltrim(cuch_doc)+'" от '+date_8(old_d)+" "+alltrim(human->fio))
d1 := human->n_data ; d2 := human->k_data ; cuch_doc := human->uch_doc
d2_year := year(d2)
cd1 := dtoc4(d1) ; cd2 := dtoc4(d2)
//
if human_->usl_ok == 4 // если "скорая помощь"
  select HUMAN
  set order to 3
  find (dtos(d2)+cuch_doc)
  do while human->k_data == d2 .and. cuch_doc == human->uch_doc .and. !eof()
    if human_->usl_ok == 4 .and. glob_kartotek == human->kod_k ;
                           .and. rec_human != human->(recno())
    endif
    skip
  enddo
endif
    select HUMAN
    skip
  enddo
else
close databases
if fl_exit
  add_string(expand("ПРОЦЕСС ПРЕРВАН"))
endif
fclose(fp)
rest_box(buf)
if kol_err > 0
  viewtext(Devide_Into_Pages(name_file,80,80),,,,(sh>80),,,reg_print)
else
  n_message({"","Повторов не обнаружено!"})
endif*/

  Return Nil

//   27.10.13
Function poisk_rassogl()

  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., sh := 80, HH := 80, reg_print := 5, pi1, fl_parakl, ;
    name_file := "rassogl" + stxt, lcount_uch, sschet

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If ( pi1 := popup_prompt( T_ROW, T_COL - 5, 2, ;
      { "По дате ~окончания лечения", "По дате ~выписки счета" } ) ) == 0
    Return Nil
  Endif
  mywait()
  Private kol_err := 0
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Обнаруженные рассогласования в базах данных", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  r_use( dir_server + "mo_uch",, "UCH" )
  r_use( dir_server + "mo_otd",, "OTD" )
  r_use( dir_server + "uslugi",, "USL" )
  r_use( dir_server + "human_u", dir_server + "human_u", "HU" )
  Set Relation To u_kod into USL
  If pi1 == 1 // по дате окончания лечения
    begin_date := arr_m[ 5 ]
    end_date := arr_m[ 6 ]
    r_use( dir_server + "schet_",, "SCHET_" )
    r_use( dir_server + "schet",, "SCHET" )
    Set Relation To RecNo() into SCHET_
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humand", "HUMAN" )
    Set Relation To schet into SCHET, To RecNo() into HUMAN_
    dbSeek( DToS( begin_date ), .t. )
    Do While human->k_data <= end_date .and. !Eof()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If human_->oplata < 9
        f1_poisk_rassogl()
      Endif
      Select HUMAN
      Skip
    Enddo
  Else
    begin_date := arr_m[ 7 ]
    end_date := arr_m[ 8 ]
    r_use( dir_server + "human_",, "HUMAN_" )
    r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server + "schet_",, "SCHET_" )
    r_use( dir_server + "schet", dir_server + "schetd", "SCHET" )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( begin_date, .t. )
    Do While schet->pdate <= end_date .and. !Eof()
      sschet := 0
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod .and. !Eof()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human_->oplata < 9
          f1_poisk_rassogl()
        Endif
        sschet += human->cena_1
        Select HUMAN
        Skip
      Enddo
      If fl_exit ; exit ; Endif
      If !( Round( sschet, 2 ) == Round( schet->summa, 2 ) )
        ++kol_err
        add_string( "Счет № " + AllTrim( schet_->NSCHET ) + ;
          " от " + full_date( schet_->DSCHET ) + "г." )
        add_string( Space( 2 ) + "сумма случаев не равна сумме счёта " + lstr( sschet, 2 ) + "!=" + lstr( schet->summa, 2 ) )
      Endif
      Select SCHET
      Skip
    Enddo
  Endif
  Close databases
  If fl_exit
    add_string( Expand( "ПРОЦЕСС ПРЕРВАН" ) )
  Endif
  FClose( fp )
  rest_box( buf )
  If kol_err > 0
    viewtext( devide_into_pages( name_file, 80, 80 ),,,, ( sh > 80 ),,, reg_print )
  Else
    n_message( { "", "Рассогласований не обнаружено!" } )
  Endif

  Return Nil

//  
Function f1_poisk_rassogl()

  Static sd20120301
  Local i := 0, ss := 0, fl
  Local aerr := { ;
    { "не проставлено учреждение в случае", 0, 0 }, ;
    { "не найдено учреждение с кодом", 0, 0 }, ;
    { "не проставлено отделение в случае", 0, 0 }, ;
    { "не найдено отделение с кодом", 0, 0 }, ;
    { "в случае стоит не то учреждение для отделения с кодом", 0, 0 }, ;
    { "не проставлено отделение в услугах", 0, 0 }, ;
    { "учреждение в случае не равно учреждению в услуге", 0, 0 }, ;
    { "услуга не попадает в сроки лечения", 0, 0 }, ;
    { "сумма услуг не равна сумма случая", 0, 0 };
  }

  Default sd20120301 To SToD( "20120301" )
  If human->lpu <= 0
    aerr[ 1, 2 ] := 1
  Else
    Select UCH
    dbGoto( human->lpu )
    If Eof() .or. uch->kod != human->lpu
      aerr[ 2, 2 ] := 1
      aerr[ 2, 3 ] := human->lpu
    Endif
  Endif
  If human->otd <= 0
    aerr[ 3, 2 ] := 1
  Else
    Select OTD
    dbGoto( human->otd )
    If Eof() .or. otd->kod != human->otd
      aerr[ 4, 2 ] := 1
      aerr[ 4, 3 ] := human->otd
    Elseif otd->kod_lpu != human->lpu
      aerr[ 5, 2 ] := 1
      aerr[ 5, 3 ] := human->otd
    Endif
  Endif
  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    If hu->otd <= 0
      aerr[ 6, 2 ] := 1
    Endif
    If human->ishod < 100 .and. !Between( c4tod( hu->date_u ), human->n_data, human->k_data )
      aerr[ 8, 2 ] := 1 ; aerr[ 8, 3 ] := c4tod( hu->date_u )
    Endif
  /*otd->(dbGoto(hu->otd))
  if otd->kod_lpu != human->lpu
    aerr[7,2] := human->lpu ; aerr[7,3] := otd->kod_lpu ; exit
  endif*/
    If human->k_data < sd20120301
      fl := f_paraklinika( usl->shifr, usl->shifr1, c4tod( hu->date_u ) )
    Else
      fl := f_paraklinika( usl->shifr, usl->shifr1, human->k_data )
    Endif
    If fl
      ss += hu->stoim_1
    Endif
    Select HU
    Skip
  Enddo
  If !( Round( ss, 2 ) == Round( human->cena_1, 2 ) )
    If Round( ss, 2 ) == 1280.30 .and. Round( human->cena_1, 2 ) == 771.40
      //
    Elseif Round( ss, 2 ) == 1280.30 .and. Round( human->cena_1, 2 ) == 1216.60
      //
    Else
      aerr[ 9, 2 ] := human->cena_1
      aerr[ 9, 3 ] := ss
    Endif
  Endif
  AEval( aerr, {| x| i += x[ 2 ] } )

  If i > 0
    ++kol_err
    add_string( "" )
    If human->schet > 0
      add_string( "Счет № " + AllTrim( schet_->NSCHET ) + ;
        " от " + full_date( schet_->DSCHET ) + "г." )
    Endif
    add_string( lstr( human->kod ) + " " + AllTrim( human->fio ) + ", " + ;
      Left( DToC( human->n_data ), 5 ) + "-" + date_8( human->k_data ) + "г." )
    For i := 1 To Len( aerr )
      If !Empty( aerr[ i, 2 ] )
        s := Space( 2 ) + aerr[ i, 1 ] + " "
        Do Case
        Case i == 1  // не проставлено учреждение в случае",0,0},;
          //
        Case i == 2  // не найдено учреждение с кодом",0,0},;
          s += lstr( aerr[ i, 3 ] )
        Case i == 3  // не проставлено отделение в случае",0,0},;
          //
        Case i == 4  // не найдено отделение с кодом",0,0},;
          s += lstr( aerr[ i, 3 ] )
        Case i == 5  // в случае стоит не то учреждение для отделения с кодом",0,0},;
          s += lstr( aerr[ i, 3 ] )
        Case i == 6  // не проставлено отделение в услугах",0,0},;
          //
        Case i == 7  // учреждение в случае не равно учреждению в услуге",0,0},;
          s += lstr( aerr[ i, 2 ] ) + "=" + lstr( aerr[ i, 3 ] )
        Case i == 8  // услуга не попадает в сроки лечения",0,0},;
          s += full_date( aerr[ i, 3 ] )
        Case i == 9  // сумма услуг не равна сумма случая",0,0};
          s += lstr( aerr[ i, 2 ] ) + "=" + lstr( aerr[ i, 3 ] )
        Endcase
        add_string( s )
      Endif
    Next
  Endif

  Return Nil
