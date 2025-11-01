#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 18.04.23 Создание отчётов по иногородним / иностранцам для КЗВО
Function pr_inog_inostr_new()
  Local arr_m, fl_exit := .f., buf := save_maxrow(), kh := 0, jh := 0, mm_p_per := 0

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  waitstatus( 'ОМС' )
  dbCreate( cur_dir() + 'tmp_kart', { { 'kod', 'N', 7, 0 }, ;
    { 'vozr', 'N', 2, 0 }, ;
    { 'vid', 'N', 1, 0 }, ;
    { 'profil', 'N', 3, 0 }, ;
    { 'region', 'C', 3, 0 }, ;
    { 'osnov', 'N', 2, 0 }, ;
    { 'kols', 'N', 6, 0 }, ;
    { 'ist_fin', 'N', 1, 0 }, ;
    { 'summa', 'N', 10, 2 }, ;
    { 'k_day', 'N', 5, 0 }, ;
    { 'd_begin', 'C', 10, 0 }, ;
    { 'forma', 'N', 1, 0 } } )
  Use ( cur_dir() + 'tmp_kart' ) new
  Index On Str( kod, 7 ) + Str( vid, 1 ) + Str( profil, 3 ) + region + Str( osnov, 2 ) + Str( ist_fin, 1 ) to ( cur_dir() + 'tmp_kart' )
  //
  Private _arr_if := {}, _what_if := _init_if(), _arr_komit := {}
  r_use( dir_exe() + '_okator', cur_dir() + '_okatr', 'REGION' )
  r_use( dir_server() + 'kartote_', , 'KART_' )
  r_use( dir_server() + 'kartotek', , 'KART' )
  Set Relation To RecNo() into KART_
  r_use( dir_server() + 'mo_otd', , 'OTD' )
  r_use( dir_server() + 'mo_kinos', dir_server() + 'mo_kinos', 'KIS' )
  r_use( dir_server() + 'uslugi', , 'USL' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  r_use( dir_server() + 'human_3', { dir_server() + 'human_3', ;
    dir_server() + 'human_32' }, 'HUMAN_3' )
  r_use( dir_server() + 'human_2', , 'HUMAN_2' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', { dir_server() + 'humand', ;
    dir_server() + 'humank', ;
    dir_server() + 'humankk' }, 'HUMAN' )
  Set Relation To kod_k into KART, To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  dbSeek( DToS( arr_m[ 5 ] ), .t. )

  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    @ MaxRow(), 71 Say date_8( human->k_data ) Color 'W/R'
    @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
    If jh > 0
      @ Row(), Col() Say '/' Color 'W/R'
      @ Row(), Col() Say lstr( jh ) Color cColorStMsg
    Endif
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If human_->oplata < 9 .and. human->ishod != 88
      lregion := Space( 3 ) ; losnov := 0
      If human->CENA_1 > 0 .and. f1pr_inog_inostr_new( 1, human->kod_k, @lregion, @losnov, arr_m )
        lprofil := human_->profil
        lvid := 2
        Do Case
        Case human_->USL_OK == 1
          lvid := 1
        Case human_->USL_OK == 2
          lvid := 4
        Case human_->USL_OK == 3
          lvid := 2
        Case human_->USL_OK == 4
          lvid := 3
        Endcase
        list_fin := f2pr_inog_inostr_new( _what_if )
        mn_data := human->N_DATA
        msumma := human->CENA_1
        If human->ishod == 89
          Select HUMAN_3
          Set Order To 2 // встать на индекс по 2-му случаю
          find ( Str( human->kod, 7 ) )
          If Found()
            msumma := human_3->CENA_1
            mn_data := human_3->N_DATA
            mm_p_per := human_2->p_per
          Endif
        Endif
        // добавка для КБ25
        sum_koiko_den := 0
        lshifr := ''
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While human->kod == hu->kod .and. !Eof()
          usl->( dbGoto( hu->u_kod ) )
          If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
            lshifr := usl->shifr
          Endif
          lshifr := AllTrim( lshifr )
          If lshifr == '1.11.1'
            sum_koiko_den += hu->kol
          Endif
          Select HU
          Skip
        Enddo
        //
        Select TMP_KART
        find ( Str( human->kod_k, 7 ) + Str( lvid, 1 ) + Str( lprofil, 3 ) + lregion + Str( losnov, 2 ) + Str( list_fin, 1 ) )
        If !Found()
          Append Blank
          tmp_kart->kod := human->kod_k
          tmp_kart->vid := lvid
          tmp_kart->profil := lprofil
          tmp_kart->region := lregion
          tmp_kart->osnov := losnov
          tmp_kart->ist_fin := list_fin
          tmp_kart->d_begin := full_date( human->n_data )
          tmp_kart->forma := mm_p_per
        Endif
        tmp_kart->kols++
        tmp_kart->vozr := f0pr_inog_inostr_new( human->date_r, mn_data )
        tmp_kart->summa += msumma
        tmp_kart->k_day += sum_koiko_den
        ++jh
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  If is_task( X_PLATN )
    waitstatus( 'Платные услуги' )
    r_use( dir_server() + 'hum_p', dir_server() + 'hum_pd', 'HUMP' )
    Set Relation To kod_k into KART
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While hump->k_data <= arr_m[ 6 ] .and. !Eof()
      @ MaxRow(), 71 Say date_8( hump->k_data ) Color 'W/R'
      @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
      If jh > 0
        @ Row(), Col() Say '/' Color 'W/R'
        @ Row(), Col() Say lstr( jh ) Color cColorStMsg
      Endif
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      lregion := Space( 3 ) ; losnov := 0
      If hump->CENA > 0 .and. f1pr_inog_inostr_new( 2, hump->kod_k, @lregion, @losnov, arr_m )
        lprofil := 97 // терапии
        lvid := 2     // амбулаторно
        If hump->otd > 0
          otd->( dbGoto( hump->otd ) )
          If !Empty( otd->profil )
            lprofil := otd->profil
          Endif
          If otd->IDUMP == 1
            lvid := 1
          Endif
        Endif
        list_fin := iif( hump->tip_usl == 1, 2, 1 )
        Select TMP_KART
        find ( Str( hump->kod_k, 7 ) + Str( lvid, 1 ) + Str( lprofil, 3 ) + lregion + Str( losnov, 2 ) + Str( list_fin, 1 ) )
        If !Found()
          Append Blank
          tmp_kart->kod := hump->kod_k
          tmp_kart->vid := lvid
          tmp_kart->profil := lprofil
          tmp_kart->region := lregion
          tmp_kart->osnov := losnov
          tmp_kart->ist_fin := list_fin
        Endif
        kart->( dbGoto( hump->kod_k ) )
        tmp_kart->kols++
        tmp_kart->vozr := f0pr_inog_inostr_new( kart->date_r, hump->n_data )
        tmp_kart->summa += hump->CENA
        ++jh
      Endif
      Select HUMP
      Skip
    Enddo
  Endif
  If is_task( X_ORTO )
    waitstatus( 'Ортопедия' )
    r_use( dir_server() + 'hum_ort', dir_server() + 'hum_ortd', 'HUMO' )
    Set Relation To kod_k into KART
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While humo->k_data <= arr_m[ 6 ] .and. !Eof()
      @ MaxRow(), 71 Say date_8( humo->k_data ) Color 'W/R'
      @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
      If jh > 0
        @ Row(), Col() Say '/' Color 'W/R'
        @ Row(), Col() Say lstr( jh ) Color cColorStMsg
      Endif
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      lregion := Space( 3 ) ; losnov := 0
      If humo->CENA > 0 .and. f1pr_inog_inostr_new( 2, humo->kod_k, @lregion, @losnov, arr_m )
        lprofil := 88 // стоматологии ортопедической
        lvid := 2     // амбулаторно
        If humo->tip_usl == 1
          list_fin := 4
        Elseif humo->tip_usl == 3
          list_fin := 2
        Else
          list_fin := 1
        Endif
        Select TMP_KART
        find ( Str( humo->kod_k, 7 ) + Str( lvid, 1 ) + Str( lprofil, 3 ) + lregion + Str( losnov, 2 ) + Str( list_fin, 1 ) )
        If !Found()
          Append Blank
          tmp_kart->kod := humo->kod_k
          tmp_kart->vid := lvid
          tmp_kart->profil := lprofil
          tmp_kart->region := lregion
          tmp_kart->osnov := losnov
          tmp_kart->ist_fin := list_fin
        Endif
        kart->( dbGoto( humo->kod_k ) )
        tmp_kart->kols++
        tmp_kart->vozr := f0pr_inog_inostr_new( kart->date_r, humo->n_data )
        tmp_kart->summa += humo->CENA
        ++jh
      Endif
      Select HUMO
      Skip
    Enddo
  Endif
  rest_box( buf )
  Close databases
  If jh == 0
    func_error( 4, 'Не обнаружено информации по иногородним и иностранцам за указанный период' )
  Else
    j := 0
    Do While ( j := popup_prompt( T_ROW, T_COL - 5, j, ;
        { 'Приложение ~1 - список иностранцев', ;
        'Приложение ~2 - список иногородних', ;
        'Приложение ~3 - сводная информация по иностранцам', ;
        'Приложение ~4 - сводная информация по иногородним', ;
        'Расширенный Список ~Иностранцев' } ) ) > 0
      f3pr_inog_inostr_new( j, arr_m )
    Enddo
  Endif

  Return Nil

// 08.04.23
Function f3pr_inog_inostr_new( j, arr_m )
  Static sprofil := 'терапии'
  Static mm_vid := { 'медицинская помощь, оказанная в стационарных условиях', ;
    'медицинская помощь, оказанная в амбулаторных условиях', ;
    'Экстренная медицинская помощь', ;
    'медицинская помощь в условиях дневного стационара' }
  Static mm_ist_fin := { 'Личные средства гражданина', 'ДМС', 'ОМС', 'средства фед.бюджета', 'средства МО', 'средства субъекта РФ' }
  Local name_fr := 'mo_iipr', buf := save_maxrow()

  mywait()
  delfrfiles()
  dbCreate( fr_titl, { { 'name', 'C', 255, 0 }, ;
    { 'period', 'C', 255, 0 } } )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->name := glob_mo[ _MO_FULL_NAME ]
  frt->period := arr_m[ 4 ]
  dbCreate( fr_data, { ;
    { 'vid', 'C', 60, 0 }, ;
    { 'profil', 'C', 255, 0 }, ;
    { 'region', 'C', 255, 0 }, ;
    { 'ist_fin', 'C', 30, 0 }, ;
    { 'osnov', 'C', 50, 0 }, ;
    { 'fio', 'C', 60, 0 }, ;
    { 'kol', 'N', 6, 0 }, ;
    { 'kols', 'N', 6, 0 }, ;
    { 'vozr', 'N', 2, 0 }, ;
    { 'summa', 'N', 15, 2 }, ;
    { 'k_day', 'N', 5, 0 }, ;
    { 'd_begin', 'C', 10, 0 }, ;
    { 'forma', 'C', 60, 0 } } )
  Use ( fr_data ) New Alias FRD
  r_use( dir_exe() + '_okator', cur_dir() + '_okatr', 'REGION' )
  r_use( dir_server() + 'kartotek', , 'KART' )
  Use ( cur_dir() + 'tmp_kart' ) new
  If j == 1 .or. j == 2 .or. j == 5
    Set Relation To kod into KART
    Index On Upper( kart->fio ) + Str( kart->kod, 7 ) + Str( vid, 1 ) + Str( profil, 3 ) + region + Str( osnov, 2 ) + Str( ist_fin, 1 ) to ( cur_dir() + 'tmp_kart' )
  Else
    Index On region + Str( osnov, 2 ) + Str( ist_fin, 1 ) + Str( vid, 1 ) + Str( profil, 3 ) to ( cur_dir() + 'tmp_kart' )
  Endif
  If j == 1 .or. j == 2 .or. j == 5
    Select TMP_KART
    Go Top
    Do While !Eof()
      If j == 2
        If tmp_kart->osnov < 0
          Select FRD
          Append Blank
          frd->vid := mm_vid[ tmp_kart->vid ]
          If Empty( frd->profil := inieditspr( A__MENUVERT, getv002(), tmp_kart->PROFIL ) )
            frd->profil := sprofil
          Endif
          frd->ist_fin := mm_ist_fin[ tmp_kart->ist_fin ]
          Select REGION
          find ( Left( tmp_kart->region, 2 ) )
          frd->region := CharRem( '*', name )
          frd->fio := kart->fio
          frd->kols += tmp_kart->kols
          frd->vozr := tmp_kart->vozr
          frd->summa := tmp_kart->summa
          frd->k_day := tmp_kart->k_day
          frd->d_begin := tmp_kart->d_begin
          frd->forma := iif( tmp_kart->forma == 2, 'Доставлен СП', 'Плановая' )
        Endif
      Else
        If tmp_kart->osnov >= 0
          Select FRD
          Append Blank
          frd->vid := mm_vid[ tmp_kart->vid ]
          If Empty( frd->profil := inieditspr( A__MENUVERT, getv002(), tmp_kart->PROFIL ) )
            frd->profil := sprofil
          Endif
          frd->ist_fin := mm_ist_fin[ tmp_kart->ist_fin ]
          frd->region := inieditspr( A__MENUVERT, geto001(), tmp_kart->region )
          frd->osnov := inieditspr( A__MENUVERT, get_osn_preb_rf(), tmp_kart->osnov )
          frd->fio := kart->fio
          frd->kols += tmp_kart->kols
          frd->vozr := tmp_kart->vozr
          frd->summa := tmp_kart->summa
          frd->k_day := tmp_kart->k_day
          frd->d_begin := tmp_kart->d_begin
          frd->forma := iif( tmp_kart->forma == 2, 'Доставлен СП', 'Плановая' )
        Endif
      Endif
      Select TMP_KART
      Skip
    Enddo
  Else
    dbCreate( cur_dir() + 'tmp1', { { 'vid', 'N', 1, 0 }, ;
      { 'profil', 'N', 3, 0 }, ;
      { 'region', 'C', 3, 0 }, ;
      { 'osnov', 'N', 2, 0 }, ;
      { 'ist_fin', 'N', 1, 0 }, ;
      { 'kol', 'N', 6, 0 }, ;
      { 'kols', 'N', 6, 0 }, ;
      { 'summa', 'N', 15, 2 } } )
    Use ( cur_dir() + 'tmp1' ) new
    Index On region + Str( osnov, 2 ) + Str( ist_fin, 1 ) + Str( vid, 1 ) + Str( profil, 3 ) to ( cur_dir() + 'tmp1' )
    Select TMP_KART
    Go Top
    Do While !Eof()
      fl := .f.
      If j == 4
        If tmp_kart->osnov < 0
          fl := .t.
        Endif
      Else
        If tmp_kart->osnov >= 0
          fl := .t.
        Endif
      Endif
      If fl
        Select TMP1
        find ( tmp_kart->region + Str( tmp_kart->osnov, 2 ) + Str( tmp_kart->ist_fin, 1 ) + Str( tmp_kart->vid, 1 ) + Str( tmp_kart->profil, 3 ) )
        If !Found()
          Append Blank
          tmp1->vid := tmp_kart->vid
          tmp1->profil := tmp_kart->profil
          tmp1->region := tmp_kart->region
          tmp1->osnov := tmp_kart->osnov
          tmp1->ist_fin := tmp_kart->ist_fin
        Endif
        tmp1->kol++
        tmp1->kols += tmp_kart->kols
        tmp1->summa += tmp_kart->summa
      Endif
      Select TMP_KART
      Skip
    Enddo
    Select TMP1
    Go Top
    Do While !Eof()
      Select FRD
      Append Blank
      frd->vid := mm_vid[ tmp1->vid ]
      If Empty( frd->profil := inieditspr( A__MENUVERT, getv002(), tmp1->PROFIL ) )
        frd->profil := sprofil
      Endif
      frd->ist_fin := mm_ist_fin[ tmp1->ist_fin ]
      If tmp1->osnov < 0
        Select REGION
        find ( Left( tmp1->region, 2 ) )
        frd->region := CharRem( '*', name )
      Else
        frd->region := inieditspr( A__MENUVERT, geto001(), tmp1->region )
        frd->osnov := inieditspr( A__MENUVERT, get_osn_preb_rf(), tmp1->osnov )
      Endif
      frd->kols := tmp1->kols
      frd->kol := tmp1->kol
      frd->summa := tmp1->summa
      Select TMP1
      Skip
    Enddo
  Endif
  Close databases
  rest_box( buf )
  call_fr( name_fr + lstr( j ) )

  Return Nil

// 12.08.18
Function f0pr_inog_inostr_new( ldate_r, _data )
  Local cy := count_years( ldate_r, _data )

  Return iif( cy < 100, cy, 99 )

// 28.09.20
Function f1pr_inog_inostr_new( par, lkod, /*@*/lregion, /*@*/losnov, arr_m)
  Local rec

  Select KART
  Goto ( lkod )
  If !Empty( kart_->strana ) .and. AScan( geto001(), {| x| x[ 2 ] == kart_->strana } ) > 0
    lregion := kart_->strana
    Select KIS
    find ( Str( lkod, 7 ) )
    If Found()
      losnov := kis->osn_preb
    Endif
  Endif
  If lregion == '643'
    lregion := Space( 3 ) ; losnov := 0
  Endif
  If Empty( lregion ) .and. !eq_any( Left( kart_->okatog, 2 ), '  ', '00', '18' )
    Select REGION
    find ( Left( kart_->okatog, 2 ) )
    If Found()
      lregion := Left( kart_->okatog, 2 ) + ' '
      losnov := -1
    Endif
    If par == 1 .and. !Empty( lregion ) // иногородний?
      If human->komu == 0 .and. Val( human_->smo ) > 34000 .and. Val( human_->smo ) < 35000 // полис Волгоградский
        lregion := Space( 3 ) ; losnov := 0                                               // не учитываем
      Endif
    Endif
  Endif

  Return !Empty( lregion )

// 14.11.19
Function f2pr_inog_inostr_new( _what_if )
  Local list_fin := I_FIN_OMS, _ist_fin, i

  If human->komu == 5
    list_fin := I_FIN_PLAT // личный счет = платные услуги
  Elseif eq_any( human->komu, 1, 3 )
    If ( i := AScan( _what_if[ 2 ], {| x| x[ 1 ] == human->komu .and. x[ 2 ] == human->str_crb } ) ) > 0
      list_fin := _what_if[ 2, i, 3 ]
    Endif
  Endif
  // 1-пл., 2-ДМС, 3-ОМС, 4-бюджет, 5-средства МО, 6-средства субъекта РФ
  If list_fin == I_FIN_OMS
    _ist_fin := 3
  Elseif list_fin == I_FIN_PLAT
    _ist_fin := 1
  Elseif list_fin == I_FIN_DMS
    _ist_fin := 2
  Elseif list_fin == I_FIN_LPU
    _ist_fin := 5
  Else
    _ist_fin := 6
  Endif

  Return _ist_fin
