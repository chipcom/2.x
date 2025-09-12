// различные функции для задачи ОМС - mo_omsf.prg
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// Static Shodata_sem := 'Работа с ходатайствами'
// Static Shodata_err := 'В данный момент с ходатайствами работает другой пользователь.'

// 08.09.18 очистить запись в строке файла 'human_2'
Function put_0_human_2()

  human_2->OSL1 := human_2->OSL2 := human_2->OSL3 := human_2->TAL_NUM := human_2->VIDVMP := ''
  human_2->P_PER := human_2->PROFIL_K := human_2->VMP := human_2->METVMP := 0
  human_2->NPR_DATE := human_2->TAL_D := human_2->TAL_P := CToD( '' )
  human_2->VNR := human_2->VNR1 := human_2->VNR2 := human_2->VNR3 := 0
  human_2->PC1 := human_2->PC2 := human_2->PC3 := human_2->PC4 := human_2->PC5 := human_2->PC6 := ''
  human_2->PN1 := human_2->PN2 := human_2->PN3 := human_2->PN4 := human_2->PN5 := human_2->PN6 := 0
  Return Nil

// 12.02.24 проверка отключения подразделений
Function disable_podrazdelenie_tfoms( lkdate )

  Local ret := .f.
  Local aCodem := { ;
    '101001', ;
    '103001', ;
    '121125', ;
    '141023', ;
    '161007', ;
    '171004', ;
    '151005', ;
    '101201', ;
    '131001', ;
    '104401', ;
    '251001', ;
    '101002', ;
    '151012', ;
    '711001', ;
    '801942' ;
    }

  // В соответствии с решением Комиссии от 13.06.2023 с 01.06.2023 изменены уровни оплаты для ряда МО.
  If AScan( aCodem, hb_main_curOrg:Kod_Tfoms ) != 0 .and. lkdate >= 0d20230601
    ret := .t.
  Endif
  Return ret

// 16.06.23 заполнить код подразделения/отделения
Function f_put_glob_podr( lusl, lkdate, _arr )

  Default _arr TO {}

  glob_podr := ''
  glob_otd_dep := 0
  If lusl == 1 .and. lkdate >= 0d20170801
    If Year( lkdate ) > 2017
      If is_otd_dep
        If disable_podrazdelenie_tfoms( lkdate )
          Return .f.
        Endif
        glob_otd_dep := otd->CODE_DEP // код отделения по кодировке ТФОМС из справочника SprDep - 18 год
        If Empty( glob_otd_dep )
          // базы отделения и учреждения открыты и стоят на нужной записи
          AAdd( _arr, ' не заполнен код отделения по кодировке ТФОМС для "' + AllTrim( otd->name ) + '/' + AllTrim( uch->name ) + '"' )
        Endif
      Endif
    Else // для второй половины 2017 года
      If is_adres_podr()
        glob_podr := otd->CODE_TFOMS // код адресного подразделения
        If Empty( glob_podr )
          // базы отделения и учреждения открыты и стоят на нужной записи
          AAdd( _arr, ' не заполнен адрес удалённого подразделения для "' + AllTrim( otd->name ) + '/' + AllTrim( uch->name ) + '"' )
        Endif
      Endif
    Endif
  Endif
  Return Len( _arr ) > 0

// 09.12.23
Function f_oms_beremenn( sdiag, dateSL )

  Static arr := { 'O10', 'O11', 'O12', 'O13', 'O14', 'O15', 'O16', ;
    'O20', 'O21', 'O22', 'O23', 'O24', 'O25', 'O26', 'O28', ;
    'O30', 'O31', 'O32', 'O33', 'O36', 'O40', 'O41', ;
    'O43', 'O44', 'O45', 'O46', 'O47', 'O98', 'O99', ;
    'Z33', 'Z34', 'Z35', 'Z36' }
  Local k := 0, j, c, s
  Local pr_ds_it
  Local ad_criteria // := getAdditionalCriteria(0d20190101)

  Default dateSL To sys_date

  pr_ds_it := 0
  If ( c := Left( sdiag, 1 ) ) == 'C'
    pr_ds_it := k := 3 // онкология
  Elseif c == 'O' .or. c == 'Z'
    If ( s := Left( sdiag, 3 ) ) == 'O04'
      k := 1 // аборт
    Elseif AScan( arr, s ) > 0
      k := 2 // беременность
    Endif
  Endif
  If pr_ds_it == 0 .and. AllTrim( sdiag ) == 'R54'
    pr_ds_it := 4
  Endif

  If eq_any( Year( dateSL ), 2018, 2019 )
    ad_criteria := getadditionalcriteria( dateSL )
    If pr_ds_it == 0 .and. ( j := AScan( ad_criteria, {| x| x[ 1 ] == PadR( sdiag, 5 ) } ) ) > 0
      pr_ds_it := ad_criteria[ j, 2 ]
    Endif
  Endif

  If eq_any( k, 1, 2 ) .and. Type( 'm1USL_OK' ) == 'N' .and. m1USL_OK == USL_OK_AMBULANCE // СМП
    k := 0
  Endif
  Return k

// 27.05.23
Function f_valid_beremenn( sdiag, dateSL )

  Local k

  Default dateSL To sys_date
  If ( ibrm := f_oms_beremenn( sdiag, dateSL ) ) > 0
    SetPos( rdiag, 26 )
    mm_prer_b := iif( ibrm == 1, mm1prer_b, iif( ibrm == 2, mm2prer_b, mm3prer_b ) )
    If ibrm == 1
      DispOut( 'прерывание беременности', cDataCGet )
      If !Between( m1prer_b, 0, 2 )
        m1prer_b := 0
      Endif
    Elseif ibrm == 2
      DispOut( 'дисп.набл.за беременной', cDataCGet )
      If !Between( m1prer_b, 0, 1 )
        m1prer_b := 0
      Endif
    Elseif ibrm == 3
      DispOut( '     боли при онкологии', cDataCGet )
      k := iif( Year( mk_data ) > 2018, 4, 1 )
      If !Between( m1prer_b, 0, k )
        m1prer_b := 0
      Endif
    Endif
    If ibrm == 1 .and. m1prer_b == 0
      mprer_b := Space( 28 )
    Else
      mprer_b := inieditspr( A__MENUVERT, mm_prer_b, m1prer_b )
    Endif
  Else
    m1prer_b := 0
    mprer_b := Space( 28 )
  Endif
  Return update_get( 'mprer_b' )

// 11.09.14 составить усечённые массивы учреждений/отделений на конкретную дату
Function make_arr_uch_otd( mdate, mlpu )

  Local a_uch := {}, not_lpu := !( ValType( mlpu ) == 'N' ), tmp_select := Select()

  If Empty( mdate )
    mdate := sys_date
  Endif
  r_use( dir_server() + 'mo_uch', , 'UCH' )
  r_use( dir_server() + 'mo_otd', , 'OTD' )
  If yes_many_uch .or. not_lpu
    Select UCH
    dbEval( {|| iif( between_date( uch->dbegin, uch->dend, mdate ), AAdd( a_uch, uch->( RecNo() ) ), nil ) } )
  Else
    AAdd( a_uch, mLPU )
  Endif
  Select OTD
  dbEval( {|| iif( between_date( otd->dbegin, otd->dend, mdate ), AAdd( pr_arr, { otd->( RecNo() ), otd->name, otd->kod_lpu, '' } ), nil ), ;
    iif( mem_otdusl == 2, AAdd( pr1arr_otd, { otd->( RecNo() ), otd->name, otd->kod_lpu, '' } ), nil ) ;
    }, ;
    {|| iif( yes_many_uch .or. not_lpu, AScan( a_uch, otd->kod_lpu ) > 0, otd->kod_lpu == mLPU ) } ;
    )
  If Empty( a_uch )
    func_error( 4, 'На дату ' + full_date( mdate ) + ' нет настроенных учреждений' )
  Endif
  If Empty( pr_arr )
    func_error( 4, 'На дату ' + full_date( mdate ) + ' нет настроенных отделений' )
  Endif
  If ( yes_many_uch .or. not_lpu ) .and. Len( a_uch ) > 1
    Select UCH
    AEval( pr_arr, {| x, i| dbGoto( x[ 3 ] ), pr_arr[ i, 4 ] := uch->short_name } )
    AEval( pr1arr_otd, {| x, i| dbGoto( x[ 3 ] ), pr1arr_otd[ i, 4 ] := uch->short_name } )
    //
    ASort( pr_arr, , , {| x, y| iif( x[ 3 ] == y[ 3 ], Upper( x[ 2 ] ) < Upper( y[ 2 ] ), ;
      Upper( x[ 4 ] ) < Upper( y[ 4 ] ) ) } )
    AEval( pr_arr, {| x| AAdd( pr_arr_otd, x[ 4 ] + ' ▒ ' + x[ 2 ] ) } )
  Else
    ASort( pr_arr, , , {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
    AEval( pr_arr, {| x| AAdd( pr_arr_otd, x[ 2 ] ) } )
  Endif
  If not_lpu
    uch->( dbCloseArea() )
    otd->( dbCloseArea() )
    Select ( tmp_select )
  Endif
  Return Nil

// 23.12.12 является ли услуга приёмом на дому
Function priem_na_domu( lshifr )

  Static arr := { '2.56.1', '2.56.2', '2.56.3', '2.56.4', '2.56.5', '2.56.6', ;
    '2.56.7', '2.56.8', '2.56.9', '2.56.10', '2.56.11', '2.56.12', ;
    '2.56.13', '2.56.14', '2.72.3' }
  Local i, fl := .f.

  lshifr := AllTrim( lshifr )
  For i := 1 To Len( arr )
    If lshifr == arr[ i ]
      fl := .t.
      Exit
    Endif
  Next
  Return fl

// 31.01.13 является ли услуга профилактическим приёмом
Function priem_profilak( lshifr )

  lshifr := AllTrim( lshifr )
  Return Left( lshifr, 5 ) == '2.79.' .or. eq_any( lshifr, '2.9.3', '2.32.3', '2.1.4' )

// 24.07.13 является ли услуга приёмом врача общей практики
Function uslugaobshpraktika( lshifr, lprofil )

  Static arr := { '2.72.1', '2.72.3', '2.79.2', '2.80.2', '2.83.15', '2.85.15', '2.86.15', '2.87.15' }
  Static arrp := { '2.84.2', '2.84.7' }
  Local i, fl := .f.

  Default lprofil To 0
  lshifr := AllTrim( lshifr )
  For i := 1 To Len( arr )
    If lshifr == arr[ i ]
      fl := .t.
      Exit
    Endif
  Next
  If !fl .and. lprofil == 57
    For i := 1 To Len( arrp )
      If lshifr == arrp[ i ]
        fl := .t.
        Exit
      Endif
    Next
  Endif
  Return fl

// 09.06.19 проверить, нулевая ли цена услуги в ТФОМС
Function nuluslugatfoms( lshifr1 )

  lshifr1 := AllTrim( lshifr1 )
  Return eq_any( Left( lshifr1, 2 ), '3.', '4.', '7.' ) .or. ;
    eq_any( Left( lshifr1, 5 ), '1.11.', '1.19.', '2.60.', '55.1.', '71.1.' ) .or. ;
    eq_any( Left( lshifr1, 4 ), '2.3.', '2.4.', '2.5.', '2.6.' ) .or. ;
    eq_any( Left( lshifr1, 3 ), '13.', '14.', '19.', '20.', '21.', '22.' ) .or. ;
    between_shifr( lshifr1, '2.78.47', '2.78.53' ) .or. between_shifr( lshifr1, '2.79.52', '2.79.58' ) .or. ;
    between_shifr( lshifr1, '2.80.29', '2.80.33' ) .or. between_shifr( lshifr1, '2.88.40', '2.88.45' )

// 27.01.14 проверить, возможен ли ввод признака 'на дому' для услуги ТФОМС
Function domuslugatfoms( lshifr1 )

  Return eq_any( Left( lshifr1, 5 ), '2.60.', '2.79.', '2.80.', '2.88.' ) .or. Left( lshifr1, 4 ) == '2.3.'

// 16.01.20 является услуга для среднего медперсонала?
Function uslugafeldsher( lshifr )

  Static arr := { '2.57.1', '71.1.1', '71.2.1', '2.3.3', '2.3.4', '2.60.3', '2.60.4', ;
    '2.78.28', '2.78.29', '2.78.36', '2.78.39', '2.78.40', ;
    '2.79.19', '2.79.20', '2.79.34', '2.79.37', '2.79.38', ;
    '2.79.49', '2.79.50', ;
    '2.80.12', '2.80.13', '2.80.19', '2.80.22', '2.80.23', '2.80.27', ;
    '2.80.50', '2.80.53', '2.80.54', ;
    '2.88.35', '2.88.36', '2.88.37', ;
    '57.1.46', '57.1.60', '57.1.70', '57.1.71', '57.1.80', '57.1.81' }
  Return AScan( arr, AllTrim( lshifr ) ) > 0 .or. ;
    eq_any( Left( lshifr, 2 ), '3.', '4.', '7.' ) .or. ;
    eq_any( Left( lshifr, 3 ), '13.', '14.', '19.', '20.', '21.', '22.' )

// 14.01.13 относится ли случай к скорой помощи
Function is_smp( _USL_OK, _PROFIL )

  Return _USL_OK == 4 .or. _PROFIL == 84

// вернуть наименование иногородней СМО
Function init_ismo( lsmo )

  Local s := Space( 10 ), tmp_select

  If !Empty( lsmo )
    tmp_select := Select()
    r_use( dir_exe() + '_mo_smo', cur_dir() + '_mo_smo2', 'SMO' )
    find ( PadR( lsmo, 5 ) )
    If Found()
      s := RTrim( smo->name )
    Endif
    Use
    Select ( tmp_select )
  Endif
  Return s

// по дате окончания лечения вернуть массив групп нозологий по модернизации
Function ret_arr_stand( mdate )

  Local i, arr := {}

  For i := 1 To Len( g_arr_stand )
    If mdate >= g_arr_stand[ i, 1 ]
      arr := g_arr_stand[ i, 2 ]
    Endif
  Next
  Return arr

// проверить по листу учета, законченный случай или нет, вернуть шифр услуги
Function ret_zak_sl( /*@*/susl, /*@*/doplataF, /*@*/doplataR, /*@*/lotd, /*@*/lvrach, __date)

  Local lshifr, tmp_select := Select(), s, ret := 0

  susl := '' ; doplataF := doplataR := lotd := lvrach := 0
  If Select( 'HU' ) == 0
    r_use( dir_server() + 'uslugi', , 'USL' )
    r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
    Set Relation To u_kod into USL
  Endif
  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    If !( hu->u_kod == usl->kod ) // если нет связи по relation
      usl->( dbGoto( hu->u_kod ) )  // то перемещаемся принудительно
    Endif
    s := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    If is_usluga_tfoms( usl->shifr, s, human->k_data )
      lshifr := iif( Empty( s ), usl->shifr, s )
      // в листе учета д.б. одна услуга по ОМС = законченный случай
      If Left( lshifr, 4 ) == '1.7.' // чтобы не проверять лишнее
        susl := AllTrim( lshifr )
        lotd := hu->otd
        lvrach := hu->kod_vr
        // то ищем сумму доплат
        If Select( 'LUSLD' ) == 0
          use_base( 'lusld' )
        Endif
        Select LUSLD
        find ( lshifr )
        Do While lshifr == lusld->shifr .and. !Eof()
          // поиск цены по дате окончания лечения
          If between_date( lusld->datebeg, lusld->dateend, iif( __date == NIL, human->k_data, __date ) )
            doplataF := lusld->dopl_F // по ссылке вернем сумму фед.доплаты
            doplataR := lusld->dopl_R // по ссылке вернем сумму рег.доплаты
            Exit
          Endif
          Skip
        Enddo
        ret := 1
        Exit // в листе учета д.б. одна услуга по ОМС
      Elseif Left( lshifr, 5 ) == '70.1.' // чтобы не проверять лишнее
        ret := 2
        Exit
      Endif
    Endif
    Select HU
    Skip
  Enddo
  Select ( tmp_select )
  Return ret

// вернуть первые два диагоноза для записи в XML-файл
Function diag_for_xml( al, fl_trim, fl_dop, fl_del, fl_6, adiag_talon )

  Local mdiagnoz := diag_to_array( al, fl_trim, fl_dop, fl_del, fl_6, adiag_talon )

  AAdd( mdiagnoz, '' ) // чтобы был безусловно первый элемент
  AAdd( mdiagnoz, '' ) // чтобы был безусловно второй элемент
  If Empty( mdiagnoz[ 1 ] ) // если пустой основной диагноз, заполним его
    mdiagnoz[ 1 ] := 'Z01.8' // Другое уточнённое специальное обследование
  Endif
  Return mdiagnoz

// 26.01.17
Function add_val_2_array( arr, i, j, k1, k2 )

  // arr - двумерный массив
  // i   - элемент (первое измерение), в который добавляем
  // j   - элемент (первое измерение), который добавляем
  // k1  - с какого элемента (второе измерение) идёт суммирование
  // k2  - последний элемент (второе измерение), который суммируется
  Local k

  For k := k1 To k2
    arr[ i, k ] += arr[ j, k ]
  Next
  Return Nil

// проверка на соответствие законченного случая диагнозу
Function zaksluchaccordancediagnoz( lshifr, mdiagnoz, ta )

  Local i, fl := { .f., .f. }

  If Select( 'UZK' ) == 0
    r_use( dir_exe() + '_mo_uslz', cur_dir() + '_mo_uslz', 'UZK' )
    // index on shifr+str(type_diag, 1)+kod_diag to (sbase)
  Endif
  lshifr := PadR( lshifr, 10 )
  Select UZK
  find ( lshifr )
  If Found()
    For i := 1 To Min( 2, Len( mdiagnoz ) )
      mdiagnoz[ i ] := PadR( mdiagnoz[ i ], 6 )
      fl[ i ] := .t.
    Next
    For i := 1 To 2
      find ( lshifr + Str( i, 1 ) )
      If Found()
        If fl[ i ]
          find ( lshifr + Str( i, 1 ) + mdiagnoz[ i ] )
          If !Found()
            AAdd( ta, RTrim( lshifr ) + ' для законченного случая не соответствует ' + iif( i == 1, 'основной', 'сопутствующий' ) + ' диагноз' )
          Endif
        Else
          AAdd( ta, RTrim( lshifr ) + ' для законченного случая не введён ' + iif( i == 1, 'основной', 'сопутствующий' ) + ' диагноз' )
        Endif
      Endif
    Next
  Endif
  Return Nil

// 25.07.25 врачебных приемов не должно быть более одного в один день
Function vr_pr_1_den( par, /*@*/msg, in_arr)

  Local tmp_select := Select(), lshifr, i, k, fl, s, arr_usl := {}, ;
    ad := {}, _arr := {}, lpshifr := '', arr_pusl := {}

  Default in_arr TO {}
  msg := ''
  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    If hu->( RecNo() ) != hu_->( RecNo() )  // если не связаны по RELATION
      hu_->( dbGoto( hu->( RecNo() ) ) )
    Endif
    AAdd( _arr, { hu->u_kod, hu->date_u, hu->kol_1, hu_->profil, 0 } )
    If AScan( ad, hu->date_u ) == 0
      AAdd( ad, hu->date_u )
    Endif
    Skip
  Enddo
  Select MOHU
  find ( Str( human->kod, 7 ) )
  Do While mohu->kod == human->kod .and. !Eof()
    AAdd( _arr, { mohu->u_kod, mohu->date_u, mohu->kol_1, mohu->profil, 1 } )
    If AScan( ad, mohu->date_u ) == 0
      AAdd( ad, mohu->date_u )
    Endif
    Skip
  Enddo
  // проходим услуги по текущему листу учёта
  For k := 1 To Len( _arr )
    If !Empty( lshifr := st_pr_1_den( _arr[ k ], @lpshifr ) )
      If ( i := AScan( arr_usl, {| x| x[ 1 ] == lshifr .and. x[ 2 ] == _arr[ k, 2 ] } ) ) == 0
        AAdd( arr_usl, { lshifr, _arr[ k, 2 ], 0, 0 } )
        i := Len( arr_usl )
      Endif
      arr_usl[ i, 3 ] += _arr[ k, 3 ]
      arr_usl[ i, 4 ] += _arr[ k, 3 ]
    Elseif !Empty( lpshifr )
      If ( i := AScan( arr_pusl, {| x| x[ 1 ] == lpshifr .and. x[ 2 ] == _arr[ k, 2 ] .and. x[ 5 ] == _arr[ k, 4 ] } ) ) == 0
        AAdd( arr_pusl, { lpshifr, _arr[ k, 2 ], 0, 0, _arr[ k, 4 ] } )
        i := Len( arr_pusl )
      Endif
      arr_pusl[ i, 3 ] += _arr[ k, 3 ]
      arr_pusl[ i, 4 ] += _arr[ k, 3 ]
    Endif
  Next
  // теперь проходим услуги из других листов учёта
  For k := 1 To Len( in_arr )
    If !Empty( lshifr := st_pr_1_den( in_arr[ k ], @lpshifr ) )
      If ( i := AScan( arr_usl, {| x| x[ 1 ] == lshifr .and. x[ 2 ] == in_arr[ k, 2 ] } ) ) > 0
        arr_usl[ i, 4 ] += in_arr[ k, 3 ]
      Endif
    Elseif !Empty( lpshifr )
      If ( i := AScan( arr_pusl, {| x| x[ 1 ] == lpshifr .and. x[ 2 ] == in_arr[ k, 2 ] .and. x[ 5 ] == in_arr[ k, 4 ] } ) ) > 0
        arr_pusl[ i, 4 ] += in_arr[ k, 3 ]
      Endif
    Endif
  Next
  For i := 1 To Len( arr_usl )
    if AllTrim( arr_usl[ i, 1 ] ) != '2.93.2' // исключение для школ ХНИЗ
      s := 'Услуга "' + arr_usl[ i, 1 ] + '" ' + date_8( c4tod( arr_usl[ i, 2 ] ) ) + 'г. оказана '
      If arr_usl[ i, 3 ] > 1
        msg := s + lstr( arr_usl[ i, 3 ] ) + ' раз' + iif( arr_usl[ i, 3 ] < 5, 'а', '' )
      Elseif arr_usl[ i, 4 ] > 1
        msg := s + lstr( arr_usl[ i, 4 ] ) + ' раз' + iif( arr_usl[ i, 4 ] < 5, 'а', '' ) + ;
          ' (в другом случае)'
      Endif
    endif
  Next
  For i := 1 To Len( arr_pusl )
    s := arr_pusl[ i, 1 ] + ' (' + inieditspr( A__MENUVERT, getv002(), arr_pusl[ i, 5 ] ) + ;
      ') ' + date_8( c4tod( arr_pusl[ i, 2 ] ) ) + 'г. оказана '
    If arr_pusl[ i, 3 ] > 1
      msg := s + lstr( arr_pusl[ i, 3 ] ) + ' раз' + iif( arr_pusl[ i, 3 ] < 5, 'а', '' )
    Elseif arr_pusl[ i, 4 ] > 1
      msg := s + lstr( arr_pusl[ i, 4 ] ) + ' раз' + iif( arr_pusl[ i, 4 ] < 5, 'а', '' ) + ;
        ' (в другом случае)'
    Endif
  Next
  Select ( tmp_select )
  fl := .t.
  If !Empty( msg )
    If par == 1  // для GET-системы
      func_error( 4, msg )
    Else  // для проверки ТФОМС
      fl := .f.
    Endif
  Endif
  Return fl

// 18.02.14
Static Function st_pr_1_den( _u_a, /*@*/pshifr)

  Static a_usl := { '2.*', '57.1.1', '57.1.4', '57.1.5', '57.6.1', '60.2.*', ;
    '57.1.36', '57.1.39', '57.1.42', '57.1.45', ;
    '57.1.47', '57.1.48', '57.1.49', '57.1.50' }
  Static a_no_usl := { '2.34.1', '2.34.3', '2.56.1', '2.3.1', '2.3.2', '2.3.3', ;
    '2.6.1', '2.6.2', ;
    '2.60.1', '2.60.2', '2.60.3', '2.60.4', '2.60.5' }
  Local fl := .f., lshifr, j

  pshifr := ''
  If _u_a[ 5 ] == 0
    usl->( dbGoto( _u_a[ 1 ] ) )
    If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
      lshifr := usl->shifr
    Endif
    lshifr := AllTrim( lshifr )
  Else
    mosu->( dbGoto( _u_a[ 1 ] ) )
    lshifr := AllTrim( mosu->shifr1 )
  Endif
  For j := 1 To Len( a_usl )
    If '*' $ a_usl[ j ]
      fl := Like( a_usl[ j ], lshifr )
    Else
      fl := ( a_usl[ j ] == lshifr )
    Endif
    If fl .and. ( AScan( a_no_usl, lshifr ) > 0 .or. eq_any( Left( lshifr, 5 ), '2.80.', '2.82.' ) )
      fl := .f.
      pshifr := lshifr
    Endif
    If fl
      Exit
    Endif
  Next
  Return iif( fl, lshifr, '' )

// 03.05.23 определить сроки лечения
Function f_srok_lech( beg_data, end_data, _usl_ok )

  Local s

  Default _usl_ok To 0
  s := 'Срок лечения с ' + full_date( beg_data ) + ;
    'г. по ' + full_date( end_data ) + 'г.'
  If !emptyany( beg_data, end_data )
    s += ' [' + lstr( kol_dney_lecheniya( beg_data, end_data, _usl_ok ) ) + 'дн.]'
  Endif
  Return s

// 02.02.20
Function f_arr_usl1()

  Local i, s, arr := {}, arr1 := { '2.76.5', '2.76.7' }

  If hb_FileExists( dir_server() + 'usl1year' + smem() )
    arr := rest_arr( dir_server() + 'usl1year' + smem() )
    For i := 1 To Len( arr )
      Select USL
      Goto ( arr[ i ] )
      // заменить шифр услуги на услугу по кодировке ТФОМС
      If Empty( s := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
        s := usl->shifr
      Endif
      s := AllTrim( s )
      If AScan( arr1, s ) == 0
        AAdd( arr1, s )
      Endif
    Next
  Endif
  Return arr1

// 18.08.18
Function verify_uva( reg )

  Local i

  Default reg To 1
  If Type( 'arr_uva' ) == 'A' .and. Len( arr_uva ) > 0 ;
      .and. ( i := AScan( arr_uva, {| x| Like( x[ 1 ], AllTrim( mshifr ) ) } ) ) > 0
    If arr_uva[ i, 2 ] == 1
      vr_uva := .f.
      mkod_vr := 0
      mvrach := Space( 35 )
      mtabn_vr := 0
    Endif
    If arr_uva[ i, 3 ] == 1
      as_uva := .f.
      mkod_as := 0
      massist := Space( 35 )
      mtabn_as := 0
    Endif
  Endif
  Return Nil

// вернуть табельный номер по коду врача
Function ret_tabn( lkod_vr )

  Local ltab_nom := 0

  If lkod_vr > 0 .and. Select( 'PERSO' ) > 0
    perso->( dbGoto( lkod_vr ) )
    If perso->kod == lkod_vr // если стоим на нужной записи
      ltab_nom := perso->tab_nom
    Endif
  Endif
  Return ltab_nom

// 10.04.18 подсчитать и записать сумму случая в режиме ввода услуг в случай ОМС
Function summa_usl( fl_edit )

  Local j := 0, s := 0, ldate_next := CToD( '' )

  Default fl_edit To .t.
  If tmp->( LastRec() ) > 0
    Select TMP
    Go Top
    Do While !Eof()
      If f_paraklinika( tmp->shifr_u, tmp->shifr1, human->k_data )
        s += tmp->stoim_1
      Endif
      If !Empty( tmp->DATE_NEXT )
        ldate_next := tmp->DATE_NEXT
        fl_edit := .t.
      Endif
      tmp->number := ++j
      Skip
    Enddo
  Endif
  s := Round( s, 2 )
  If !( Round( human->cena, 2 ) == s .and. Round( human->cena_1, 2 ) == s ) .or. fl_edit
    Select HUMAN
    g_rlock( forever )
    human->cena := human->cena_1 := s
    human->DATE_OPL := dtoc4( ldate_next )
    //
    human_->( g_rlock( forever ) )
    human_->OPLATA    := 0 // уберём '2', если отредактировали запись из реестра СП и ТК
    human_->ST_VERIFY := 0 // снова ещё не проверен
    If Type( 'fl_edit_usl' ) == 'L' .and. fl_edit_usl // только при редактированиии
      human_->kod_p2  := kod_polzovat    // код оператора
      human_->date_e2 := c4sys_date
    Endif
    Unlock
    Commit
  Endif
  Return Nil

// надо ли учитывать сумму данной услуги в сумме случая
Function f_paraklinika( lshifr, lshifr1, ldate_usl )

  Local tmp_select, fl := is_usluga_tfoms( lshifr, lshifr1, ldate_usl )

  If !fl .and. Empty( Val( human_->smo ) ) // если не ОМС
    If eq_any( human->komu, 1, 3 ) .and. human->str_crb > 0 // прочие компании/комитеты (МО)
      tmp_select := Select()
      r_use( dir_server() + iif( human->komu == 1, 'str_komp', 'komitet' ), , '_SK' )
      Goto ( human->str_crb )
      fl := ( _sk->parakl == 1 )
      _sk->( dbCloseArea() )
      Select ( tmp_select )
    Elseif human->komu == 5 // личный счёт
      fl := ( mem_ls_parakl == 1 )
    Endif
  Endif
  Return fl

// 01.03.23 является ли данная услуга услугой ТФОМС
Function is_usluga_tfoms( lshifr, lshifr1, ldate_usl, ;
    /*@*/arr_uet, /*@*/lbukva, /*@*/lst, /*@*/lidsp, /*@*/lvidpoms)

  Local _shifr, tmp_select := Select(), fl := .f.
  Local lal := 'lusl', y := WORK_YEAR

  y := Year( ldate_usl )
  If Select( 'LUSL' ) == 0
    use_base( 'lusl' )
  Endif

  lal := create_name_alias( lal, y )
  lst := 0
  lvidpoms := ''
  lbukva := ' '
  _shifr := iif( Empty( lshifr1 ), lshifr, lshifr1 )
  dbSelectArea( lal )
  find ( PadR( _shifr, 10 ) )
  If Found() // .and. between_date(lusl->datebeg, lusl->dateend, ldate_usl)
    fl := .t.
    lbukva := AllTrim( &lal.->bukva )
    If Len( lbukva ) != 1 // для 18 года
      lbukva := ' '
    Endif
    lst := &lal.->st
    lidsp := Int( Val( &lal.->idsp ) )
    if &lal.->( FieldPos( 'idsps' ) ) > 0 .and. ',' $ &lal.->idsps
      lidsp := 0
    Endif
    arr_uet := { &lal.->uetv, &lal.->uetd }
    lvidpoms := AllTrim( &lal.->vmp_s )
  Endif
  If !fl
    If Select( 'LUSLF' ) == 0
      use_base( 'luslf' )
    Endif
    lal := 'luslf'
    lal := create_name_alias( lal, y )
    dbSelectArea( lal )
    find ( PadR( _shifr, 20 ) )
    If Found() // .and. between_date(luslf->datebeg, luslf->dateend, ldate_usl)
      fl := .t.
      lbukva := ' '
      arr_uet := { &lal.->uetv, &lal.->uetd }
    Endif
  Endif
  Select ( tmp_select )
  Return fl // подтверждение, что услуга - ОМС

// 15.01.19
Function ret_tfoms_uet( lshifr, lshifr1, lvzros_reb )

  Local luet := 0, adult

  lshifr := AllTrim( lshifr )
  lshifr1 := AllTrim( lshifr1 )
  adult := lvzros_reb
  Return luet

// 22.11.24 проверка на код лабораторной услуги, направляемой в ЦКДЛ
Function is_lab_usluga( lshifr )

  Static sl := '4.'
  Static arr := { '8.5', '11.5', '12.5', '12.6', '13.5', '15.5', '16.5', '17.5' }
  Local i, fl := .f.

  If Left( lshifr, 2 ) == sl
    lshifr := AllTrim( lshifr )
    if lshifr == '4.15.546' // исключение для антител к гепатиту
      return .f.
    endif
    For i := 1 To Len( arr )
      If Like( sl + arr[ i ] + '??', lshifr )
        fl := .t.
        Exit
      Endif
    Next
  Endif
  Return fl

// 10.09.18
Function ret_kod_usl_lek_ter( lVZROS_REB )

  Static skodv := 0, skodr := 0
  Local s, lkod

  lkod := iif( lVZROS_REB == 0, skodv, skodr )
  If lkod == 0
    s := iif( lVZROS_REB == 0, 'A25.30.033', 'A25.30.014' )
    use_base( 'mo_su', 'MOSU1' )
    Set Order To 3
    find ( PadR( s, 20 ) )
    If Found()
      lkod := mosu1->kod
    Else
      Set Order To 1
      find ( Str( -1, 6 ) )
      If Found()
        g_rlock( forever )
      Else
        addrec( 6 )
      Endif
      lkod := mosu1->kod := RecNo()
      mosu1->name := 'Назначение лекарственных препаратов при онкологическом заболевании у ' + ;
        iif( lVZROS_REB == 0, 'взрослых', 'детей' )
      mosu1->shifr1 := s
    Endif
    mosu1->( dbCloseArea() )
    If lVZROS_REB == 0
      skodv := lkod
    Else
      skodr := lkod
    Endif
  Endif
  Return lkod

// 03.04.20
Function get_rez_gist( k, r, c )

  Local r1, r2, c1, c2, i, kg := Len( arr_rez_gist ), sk, buf, ret[ 2 ]

  r2 := r -1
  If ( r1 := r2 - kg -1 ) < 0
    r1 := 0
    r2 := r1 + kg + 1
  Endif
  c1 := 10
  c2 := 77
  SetColor( color5 )
  buf := box_shadow( r1, c1, r2, c2, , 'Ввод результатов гистологии', 'G/W' )
  @ r2, c1 + 7 Say ' <Esc> отказ,  <PgDn> запись,  <Пробел> очистить поле ' Color 'R/W'
  Private pole_rslt, pole_1rslt, pole_menu
  For i := 1 To kg
    sk := lstr( i )
    pole_rslt := 'mrslt' + sk
    pole_1rslt := 'm1rslt' + sk
    pole_menu := 'mm_rslt' + sk
    Private &pole_1rslt := arr_rez_gist[ i, 4 ]
    Private &pole_rslt := inieditspr( A__MENUVERT, arr_rez_gist[ i, 3 ], arr_rez_gist[ i, 4 ] )
    Private &pole_menu := arr_rez_gist[ i, 3 ]
  Next
  For i := 1 To kg
    sk := lstr( i )
    pole_rslt := 'mrslt' + sk
    pole_1rslt := 'm1rslt' + sk
    pole_menu := 'mm_rslt' + sk
    @ r1 + i, c1 + 2 Say PadR( arr_rez_gist[ i, 1 ], 37 ) get &pole_rslt ;
      reader {| x| menu_reader( x, &pole_menu, A__MENUVERT_SPACE, , , .f. ) }
  Next
  myread()
  If LastKey() != K_ESC
    For i := 1 To kg
      pole_1rslt := 'm1rslt' + lstr( i )
      arr_rez_gist[ i, 4 ] := &pole_1rslt
    Next
  Endif
  kg := 0
  AEval( arr_rez_gist, {| x| iif( x[ 4 ] > 0, ++kg, ) } )
  ret[ 1 ] := iif( kg > 0, 1, 0 )
  ret[ 2 ] := 'количество гистологий - ' + lstr( kg )
  rest_box( buf )
  Return ret

// 15.01.23
Function f_valid_usl_tip( g, o )

  If o != Nil .and. o != m1usl_tip
    mm_shema_usl := {}
    lstr1 := Space( 12 ) ; m1usl_tip1 := 0 ;  musl_tip1 := Space( 69 )
    lstr2 := Space( 13 ) ; m1usl_tip2 := 0 ;  musl_tip2 := Space( 19 )
    lstr_sod := ret_str_onc( 1, 2 ) ; mvsod := 0 ; msod := Space( 6 )
    lstr_fr  := ret_str_onc( 2, 2 ) ; mk_fr := Space( 2 )
    lstr_wei := ret_str_onc( 3, 2 ) ; mwei := Space( 5 )
    lstr_hei := ret_str_onc( 4, 2 ) ; mhei := Space( 3 )
    lstr_bsa := ret_str_onc( 5, 2 ) ; mbsa := Space( 4 )
    lstr_err := ret_str_onc( 6, 2 ) ; mis_err := Space( 11 )
    lstr_she := ret_str_onc( 7, 2 ) ; mcrit := Space( 57 )
    lstr_lek := ret_str_onc( 8, 2 ) ; mlek := Space( 53 )
    lstr_ptr := ret_str_onc( 9, 2 ) ; mpptr := Space( 3 ) ; m1pptr := 0
    If Between( m1usl_tip, 1, 4 )
      lstr1 := PadR( mm_str1[ m1usl_tip + 1 ], 12 )
      If m1usl_tip == 1
        mm_usl_tip1 := mm_N014
      Elseif m1usl_tip == 2
        lstr2 := 'Линия терапии'
        mm_usl_tip1 := mm_N016
        mm_usl_tip2 := mm_N015
        musl_tip2 := PadR( mm_usl_tip2[ 1, 1 ], 19 )
        m1usl_tip2 := mm_usl_tip2[ 1, 2 ]
      Elseif Between( m1usl_tip, 3, 4 )
        mm_usl_tip1 := mm_N017
        lstr_sod := ret_str_onc( 1, 1 )
        msod := PadR( AllTrim( str_0( mvsod, 6, 2 ) ), 6 )
        lstr_fr  := ret_str_onc( 2, 1 )
      Endif
      If eq_any( m1usl_tip, 2, 4 )
        If Left( m1crit, 2 ) == 'mt' .and. m1usl_tip == 2
          m1crit := Space( 10 )
        Elseif eq_any( Left( m1crit, 2 ), 'не', 'sh' ) .and. m1usl_tip == 4
          m1crit := Space( 10 )
        Endif
        lstr_wei := ret_str_onc( 3, 1 )
        lstr_hei := ret_str_onc( 4, 1 )
        lstr_bsa := ret_str_onc( 5, 1 )
        If m1usl_tip == 2
          lstr_err := ret_str_onc( 6, 1 )
          mis_err := inieditspr( A__MENUVERT, mm_shema_err, m1is_err )
        Endif
        lstr_she := ret_str_onc( 7, 1 )
        mm_shema_usl := iif( m1usl_tip == 2, _arr_sh, _arr_mt )
        mcrit := PadR( inieditspr( A__MENUVERT, mm_shema_usl, m1crit ), 57 )
        lstr_lek := ret_str_onc( 8, 1 )
        // mlek := padr(init_lek_pr(m1usl_tip, m1crit), 53)
        mlek := PadR( init_lek_pr(), 53 )
        lstr_ptr := ret_str_onc( 9, 1 )
        mpptr := inieditspr( A__MENUVERT, mm_danet, m1pptr )
      Endif
      musl_tip1 := PadR( mm_usl_tip1[ 1, 1 ], 69 )
      m1usl_tip1 := mm_usl_tip1[ 1, 2 ]
    Endif
    update_get( 'lstr1' )
    update_get( 'musl_tip1' )
    update_get( 'lstr2' )
    update_get( 'musl_tip2' )
    update_get( 'lstr_sod' )
    update_get( 'msod' )
    update_get( 'lstr_fr' )
    update_get( 'mk_fr' )
    update_get( 'lstr_wei' )
    update_get( 'mwei' )
    update_get( 'lstr_hei' )
    update_get( 'mhei' )
    update_get( 'lstr_bsa' )
    update_get( 'mbsa' )
    update_get( 'lstr_err' )
    update_get( 'mis_err' )
    update_get( 'lstr_she' )
    update_get( 'mcrit' )
    update_get( 'lstr_lek' )
    update_get( 'mlek' )
    update_get( 'lstr_ptr' )
    update_get( 'mpptr' )
  Endif
  Return .t.

// 05.09.19 является услугой телемедицины - не заполняется код врача
Function is_telemedicina( lshifr, /*@*/fl2)

  Local fl := .f., tmp_select := Select()

  fl2 := .f.
  Select LUSLF
  find ( PadR( lshifr, 20 ) )
  If Found() .and. AllTrim( lshifr ) == AllTrim( luslf->shifr ) .and. luslf->telemed == 1
    fl := .t.
    fl2 := ( Left( luslf->shifr, 4 ) == 'B01.' )
  Endif
  Select ( tmp_select )
  Return fl

// 12.01.20 вернуть разрешённые парные органы
Function ret_par_org( lshifr, _k_data )

  Local s := '', lalf := 'LUSLF', tmp_select := Select()

  lalf := create_name_alias( lalf, _k_data )
  dbSelectArea( lalf )
  If FieldNum( 'par_org' ) > 0
    find ( PadR( lshifr, 20 ) )
    If Found() .and. AllTrim( lshifr ) == AllTrim( &lalf.->shifr )
      s := AllTrim( &lalf.->par_org )
    Endif
  Endif
  Select ( tmp_select )
  Return s

// 22.01.19 обязательна ли зубная формула
Function ret_is_zf( lshifr )

  Local n := 0, tmp_select := Select()

  Select LUSLF
  If FieldNum( 'zf' ) > 0
    find ( PadR( lshifr, 20 ) )
    If Found() .and. AllTrim( lshifr ) == AllTrim( luslf->shifr )
      n := luslf->zf
    Endif
  Endif
  Select ( tmp_select )
  Return n

// 28.03.23 вернуть строку парных органов
Function ini_par_org( val, orig )

  Local i, j, a := list2arr( orig ), a1 := list2arr( val ), ret := ''

  For i := 1 To Len( a )
    If AScan( a1, a[ i ] ) > 0 .and. ( j := AScan( getparorgan(), {| x| x[ 2 ] == a[ i ] } ) ) > 0
      ret += getparorgan()[ j, 1 ] + ','
    Endif
  Next
  Return iif( Empty( ret ), Space( 10 ), Left( ret, Len( ret ) -1 ) )

// 28.03.23 в GET'е выбор парных органов
Function get_par_org( r, c, val, orig )

  Local fl := .t., i, j, a := list2arr( orig ), a1 := list2arr( val ), arr := {}, sast, ret, rets, r1, r2

  For i := 1 To Len( a )
    If ( j := AScan( getparorgan(), {| x| x[ 2 ] == a[ i ] } ) ) > 0
      AAdd( arr, AClone( getparorgan()[ j ] ) )
    Endif
  Next
  sast := Array( Len( arr ) )
  AFill( sast, .f. )
  For i := 1 To Len( arr )
    If AScan( a1, arr[ i, 2 ] ) > 0
      sast[ i ] := .t.
    Endif
  Next
  a := NIL
  If Len( arr ) > 0
    r2 := r -1
    If ( r1 := r2 - Len( arr ) -1 ) < 0
      r1 := 0
    Endif
    a := bit_popup( r1, c, arr, sast )
  Endif
  ret := rets := Space( 10 )
  If ValType( a ) == 'A'
    ret := rets := ''
    For i := 1 To Len( a )
      rets += a[ i, 1 ] + ','
      ret += lstr( a[ i, 2 ] ) + ','
    Next
    rets := Left( rets, Len( rets ) -1 )
    ret := Left( ret, Len( ret ) -1 )
  Endif
  Return { ret, rets }

// 18.09.19
Function f_usl1year( lshifr, _mshifr, _mname )

  Local k := 0, c, s, tmp_select := Select(), buf := save_maxrow(), ;
    rec_human := human->( RecNo() ), rec_hu := hu->( RecNo() ), ;
    lyear := Year( mdate_u1 ), lshifr_

  lshifr := AllTrim( lshifr ) // на всякий случай
  If AScan( arr_usl1year, lshifr ) > 0
    mywait()
    Select HUMAN
    Set Index to ( dir_server() + 'humankk' )
    find ( Str( glob_kartotek, 7 ) )
    Do While human->kod_k == glob_kartotek .and. !Eof()
      If lyear == Year( human->n_data ) .or. lyear == Year( human->k_data )
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          usl->( dbGoto( hu->u_kod ) )
          If Empty( lshifr_ := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
            lshifr_ := usl->shifr
          Endif
          lshifr_ := AllTrim( lshifr_ )
          If lshifr == lshifr_ .and. lyear == Year( c4tod( hu->date_u ) )
            ++k
          Endif
          Skip
        Enddo
      Endif
      Select HUMAN
      Skip
    Enddo
    human->( dbGoto( rec_human ) )
    hu->( dbGoto( rec_hu ) )
    Select ( tmp_select )
    rest_box( buf )
    If k > 0
      s := 'раз'
      c := Right( Str( k ), 1 )
      If !Between( k, 11, 19 ) .and. eq_any( c, '2', '3', '4' )
        s += 'а'
      Endif
      n_message( { 'Предупреждение!', ;
        '', ;
        'Услуга ' + AllTrim( _mshifr ), ;
        '(' + AllTrim( _mname ) + ')', ;
        'должна встречаться у больного не более одного раза в году,', ;
        'а у данного больного она встречалась уже ' + lstr( k ) + ' ' + s + '!' }, , ;
        'GR+/R', 'W+/R', , , 'G+/R' )
    Endif
  Endif
  Return Nil

// 11.01.13 вернуть уровень МО в зависимости от даты
Function get_uroven( dDate )

  Local i, ret := 4 // с 2013 года у всех индивидуальные тарифы

  Default dDate To sys_date
  If Year( dDate ) < 2013
    For i := 1 To Len( glob_mo[ _MO_UROVEN ] )
      If dDate >= glob_mo[ _MO_UROVEN, i, 1 ]
        ret := glob_mo[ _MO_UROVEN, i, 2 ]
      Endif
    Next
  Endif
  Return ret

// для 1-3ур. вернуть уровень для услуг 'койко-день' или 1-й для остальных
Function get2uroven( sShifr, nU )

  Default nU To get_uroven()
  If nU < 4 .and. !( Left( sShifr, 2 ) == '1.' )
    nU := 1
  Endif
  Return nU

// 24.11.21
Function fcena_oms( sShifr, lVzReb, dDate, /*@*/fl_delete, /*@*/fl_yes, /*@*/_ifin)

  Local i, v, tmp_select := Select(), lvr, nu, lal, s := glob_mo[ _MO_KOD_TFOMS ]

  sShifr := PadR( sShifr, 10 )
  If ValType( dDate ) == 'D'
    dDate := { dDate }
  Endif
  If !Empty( glob_podr ) .and. Year( dDate[ 1 ] ) == 2017
    s := PadR( glob_podr, 6 ) // заменяем на код адреса подразделения
  Endif
  lvr := iif( lVzReb, 0, 1 )
  For i := 1 To Len( dDate )
    v := 0
    nu := get2uroven( sShifr, get_uroven( dDate[ i ] ) )
    _ifin := 0
    fl_delete := .t.
    fl_yes := .f.
    lal := 'luslc'
    lal := create_name_alias( lal, dDate[ i ] )
    dbSelectArea( lal )
    Set Order To 1
    find ( sShifr + Str( lvr, 1 ) + Str( glob_otd_dep, 3 ) ) // сначала ищем цену для конкретного отделения
    Do While sShifr == &lal.->shifr .and. &lal.->VZROS_REB == lvr .and. &lal.->depart == glob_otd_dep .and. !Eof()
      fl_yes := .t.
      If between_date( &lal.->datebeg, &lal.->dateend, dDate[ i ] ) // поиск цены по дате окончания лечения
        fl_delete := .f.
        v := &lal.->CENA
        Exit
      Endif
      Skip
    Enddo
    If !fl_yes .and. fl_delete // если не нашли
      find ( sShifr + Str( lvr, 1 ) + Str( 0, 3 ) ) // то ищем цену для depart = 0
      Do While sShifr == &lal.->shifr .and. &lal.->VZROS_REB == lvr .and. &lal.->depart == 0 .and. !Eof()
        fl_yes := .t.
        If between_date( &lal.->datebeg, &lal.->dateend, dDate[ i ] ) // поиск цены по дате окончания лечения
          fl_delete := .f.
          v := &lal.->CENA
          Exit
        Endif
        Skip
      Enddo
    Endif
    If Empty( v )
      Exit
    Endif
  Next
  Select ( tmp_select )
  Return v

// 24.02.21
Function f1cena_oms( sShifr, sShifr1, lVzReb, dDate, lis_nul, /*@*/fl_uslc, /*@*/fl_del)

  Local s, v, lu_cena

  Default lis_nul To .f.
  fl_uslc := .f.
  fl_del := .f.
  s := iif( Empty( sShifr1 ), sShifr, sShifr1 )
  v := fcena_oms( s, ;
    lVzReb, ;
    dDate, ;
    @fl_del, ;
    @fl_uslc )
  If fl_uslc  // если нашли в справочнике ТФОМС
    lu_cena := v
    If fl_del .and. !lis_nul
      func_error( 4, 'В справочнике ТФОМС услуга ' + AllTrim( s ) + ' удалена (на ' + full_date( dDate ) + ')' )
    Endif
  Elseif !lis_nul
    // func_error(4, 'В справочнике ТФОМС данная услуга отсутствует!')
  Endif
  Return lu_cena

// Группы МКБ + услуги по стандартам
Function uslugi_mkb_standart()

  Local arr

  arr := Array( 11 )
  // инфаркты миокарда
  arr[ 1 ] := {}
  AAdd( arr[ 1 ], '1.7.25' )
  AAdd( arr[ 1 ], '1.7.26' )
  AAdd( arr[ 1 ], '1.7.27' )
  AAdd( arr[ 1 ], '1.7.46' )
  AAdd( arr[ 1 ], '1.7.47' )
  AAdd( arr[ 1 ], '1.7.48' )
  AAdd( arr[ 1 ], '1.7.49' )
  // инсульты
  arr[ 2 ] := {}
  AAdd( arr[ 2 ], '1.7.28' )
  AAdd( arr[ 2 ], '1.7.29' )
  AAdd( arr[ 2 ], '1.7.30' )
  AAdd( arr[ 2 ], '1.7.31' )
  AAdd( arr[ 2 ], '1.7.51' )
  AAdd( arr[ 2 ], '1.7.52' )
  // ЧМТ
  arr[ 3 ] := {}
  AAdd( arr[ 3 ], '1.7.32' )
  AAdd( arr[ 3 ], '1.7.33' )
  AAdd( arr[ 3 ], '1.7.34' )
  // онкология
  arr[ 4 ] := {}
  AAdd( arr[ 4 ], '1.7.13' )
  AAdd( arr[ 4 ], '1.7.14' )
  AAdd( arr[ 4 ], '1.7.15' )
  AAdd( arr[ 4 ], '1.7.16' )
  AAdd( arr[ 4 ], '1.7.17' )
  AAdd( arr[ 4 ], '1.7.18' )
  // пневмонии
  arr[ 5 ] := {}
  AAdd( arr[ 5 ], '1.7.19' )
  AAdd( arr[ 5 ], '1.7.20' )
  AAdd( arr[ 5 ], '1.7.21' )
  AAdd( arr[ 5 ], '1.7.22' )
  AAdd( arr[ 5 ], '1.7.23' )
  AAdd( arr[ 5 ], '1.7.24' )
  AAdd( arr[ 5 ], '1.7.44' )
  AAdd( arr[ 5 ], '1.7.45' )
  AAdd( arr[ 5 ], '1.7.50' )
  // язвы
  arr[ 6 ] := {}
  AAdd( arr[ 6 ], '1.7.35' )
  AAdd( arr[ 6 ], '1.7.36' )
  AAdd( arr[ 6 ], '1.7.37' )
  AAdd( arr[ 6 ], '1.7.58' )
  AAdd( arr[ 6 ], '1.7.59' )
  AAdd( arr[ 6 ], '1.7.60' )
  AAdd( arr[ 6 ], '1.7.61' )
  AAdd( arr[ 6 ], '1.7.62' )
  AAdd( arr[ 6 ], '1.7.63' )
  AAdd( arr[ 6 ], '1.7.64' )
  AAdd( arr[ 6 ], '1.7.65' )
  AAdd( arr[ 6 ], '1.7.66' )
  // родовая травма
  arr[ 7 ] := {}
  AAdd( arr[ 7 ], '1.7.41' )
  AAdd( arr[ 7 ], '1.7.42' )
  AAdd( arr[ 7 ], '1.7.43' )
  // новорожденный с низкой массой тела
  arr[ 8 ] := {}
  AAdd( arr[ 8 ], '1.7.38' )
  AAdd( arr[ 8 ], '1.7.39' )
  AAdd( arr[ 8 ], '1.7.40' )
  // астма
  arr[ 9 ] := {}
  AAdd( arr[ 9 ], '1.7.67' )
  AAdd( arr[ 9 ], '1.7.68' )
  AAdd( arr[ 9 ], '1.7.69' )
  AAdd( arr[ 9 ], '1.7.70' )
  // диабет
  arr[ 10 ] := {}
  AAdd( arr[ 10 ], '1.7.71' )
  AAdd( arr[ 10 ], '1.7.72' )
  AAdd( arr[ 10 ], '1.7.73' )
  // панкреатит
  arr[ 11 ] := {}
  AAdd( arr[ 11 ], '1.7.74' )
  AAdd( arr[ 11 ], '1.7.75' )
  AAdd( arr[ 11 ], '1.7.77' )
  Return arr

// сделать единую строку полиса из полей серии и номера полиса
Function make_polis( _spolis, _npolis )

  Local s := AllTrim( _spolis )

  If !Empty( s )
    s += ' '
  Endif
  Return s + AllTrim( _npolis )

// 19.05.22 вывести наименование диагноза при вводе случая
Function diag_screen( k, arr_d, lUp )

  Static buf_d
  Local i, lc, r // := 12

  Default lUp To .f.

  r := iif( lUp, 5, 12 )
  If Type( 'row_diag_screen' ) == 'N' .and. row_diag_screen > 0
    r := row_diag_screen
  Endif
  If k == 0 // обнулить буфер
    buf_d := nil
  Elseif k == 1 // если надо, отрисовать прямоугольник, и вывести диагноз
    If buf_d == nil
      buf_d := box_shadow( r, 3, r + 5, 76, 'N/RB', 'Диагноз', 'W/RB' )
    Endif
    For i := 1 To Len( arr_d )
      lc := if( 'в ОМС' $ arr_d[ i ] .or. 'по полу' $ arr_d[ i ], 'GR+/RB', 'W+/RB' )
      @ r + i, 5 Say PadR( arr_d[ i ], 71 ) Color lc
    Next
  Elseif k == 2 // восстановить экран  и обнулить буфер
    If buf_d != nil
      rest_box( buf_d )
    Endif
    buf_d := nil
  Endif
  Return .t.


// вывести мигалки перед диагнозами, если введена доп.инф-ия по талону
Function put_dop_diag()

  // позиции get'ов диагнозов
  Static arc := { { 9, 25 }, { 10, 25 }, { 10, 33 }, { 10, 41 }, { 10, 49 }, { 10, 57 }, { 10, 65 }, { 10, 73 } }
  Local i, j, fl[ 8 ]

  If is_talon
    AFill( fl, .f. )
    j := 0
    For i := 1 To 16
      If i % 2 == 1
        ++j
      Endif
      If adiag_talon[ i ] > 0
        fl[ j ] := .t.
      Endif
    Next
    If !( Type( 'row_dop_diag' ) == 'N' )
      Private row_dop_diag := 0
    Endif
    For i := 1 To 8
      @ arc[ i, 1 ] + row_dop_diag, arc[ i, 2 ] -1 Say iif( fl[ i ], Chr( 16 ), ' ' ) Color color8
    Next
  Endif
  Return .t.

// сделать 'пяти или шести-значные' диагнозы
Function make_diagp( k )

  If k == 1  // сделать 'шестизначные' диагнозы
    MKOD_DIAG  := MKOD_DIAG  + SubStr( mdiag_plus, 1, 1 )
    MKOD_DIAG2 := MKOD_DIAG2 + SubStr( mdiag_plus, 2, 1 )
    MKOD_DIAG3 := MKOD_DIAG3 + SubStr( mdiag_plus, 3, 1 )
    MKOD_DIAG4 := MKOD_DIAG4 + SubStr( mdiag_plus, 4, 1 )
    MSOPUT_B1  := MSOPUT_B1  + SubStr( mdiag_plus, 5, 1 )
    MSOPUT_B2  := MSOPUT_B2  + SubStr( mdiag_plus, 6, 1 )
    MSOPUT_B3  := MSOPUT_B3  + SubStr( mdiag_plus, 7, 1 )
    MSOPUT_B4  := MSOPUT_B4  + SubStr( mdiag_plus, 8, 1 )
  Else       // сделать 'пятизначные' диагнозы
    mdiag_plus := Right( MKOD_DIAG, 1 ) + ;
      Right( MKOD_DIAG2, 1 ) + ;
      Right( MKOD_DIAG3, 1 ) + ;
      Right( MKOD_DIAG4, 1 ) + ;
      Right( MSOPUT_B1, 1 ) + ;
      Right( MSOPUT_B2, 1 ) + ;
      Right( MSOPUT_B3, 1 ) + ;
      Right( MSOPUT_B4, 1 )
    MKOD_DIAG  := Left( MKOD_DIAG, 5 )
    MKOD_DIAG2 := Left( MKOD_DIAG2, 5 )
    MKOD_DIAG3 := Left( MKOD_DIAG3, 5 )
    MKOD_DIAG4 := Left( MKOD_DIAG4, 5 )
    MSOPUT_B1  := Left( MSOPUT_B1, 5 )
    MSOPUT_B2  := Left( MSOPUT_B2, 5 )
    MSOPUT_B3  := Left( MSOPUT_B3, 5 )
    MSOPUT_B4  := Left( MSOPUT_B4, 5 )
  Endif
  Return Nil

// сформировать номер амбулаторной карты
Function amb_kartan( fl_0 )

  Local lnomer := lstr( kart->kod )

  If is_uchastok == 1
    lnomer := ''
    If !emptyall( kart->bukva, kart->uchast, kart->kod_vu )
      If !Empty( kart->bukva )
        lnomer += kart->bukva
      Endif
      lnomer += lstr( kart->uchast, 2 )
      Default fl_0 To .f.
      If kart->kod_vu > 0 .or. fl_0
        lnomer += '/' + lstr( kart->kod_vu )
      Endif
    Endif
  Elseif is_uchastok == 2
    If !emptyall( kart->bukva, kart->uchast )
      lnomer := ''
      If !Empty( kart->bukva )
        lnomer += kart->bukva
      Endif
      lnomer += lstr( kart->uchast, 2 )
      lnomer += '/' + lstr( kart->kod )
    Endif
  Elseif is_uchastok == 3
    lnomer := kart2->kod_AK
  Endif
  Return lnomer

// 12.09.25 выбрать карточку пациента из картотеки
Function polikl_kart( k )

  // k = 1 - начало лечения -> ввод карточки
  // k = 2 - возврат кода по картотеке
  Static sesc := '^<Esc>^ выход  '
  Static senter := '^<Enter>^ ввод  '
  Static sF10p := '^<F10>^ поиск по полису  '
  Static sF10f := '^<F10>^ поиск по ФИО  '
  Static sF10s := '^<F10>^ поиск по СНИЛС  '
  Static sF11  := '^<F11>^ читать электронный полис'
  Static _err_slock := 'В данный момент с карточкой этого пациента работает другой пользователь.'
  Static s_regim := 1, s_shablon := '', s_polis := '', s_snils := ''
  Local tmp1, mkod := -1, i, fl_number := .t., s, append_or_edit := 0, ;
    k1 := 0, k2 := 1, str_sem, mbukva := '', tmp_color, buf, buf24, ar

  Private tmp, name_reader := ''
  // обмен информацией с программой Smart Delta Systems
  import_kart_from_sds()
  // ///////////////////////////////////////////////////
  ar := getinivar( tmp_ini, { { 'polikl1','s_regim', '1' }, ;
    { 'polikl1','s_shablon', '' }, ;
    { 'polikl1','s_polis', '' }, ;
    { 'polikl1','s_snils', '' }, ;
    { 'RAB_MESTO', 'sc_reader', '' } } )
  If !eq_any( s_regim := Int( Val( ar[ 1 ] ) ), 1, 2, 3 )
    s_regim := 1
  Endif
  s_shablon := ar[ 2 ]
  s_polis   := ar[ 3 ]
  s_snils   := ar[ 4 ]
  name_reader := ar[ 5 ]
  Do While .t.
    buf24 := save_maxrow()
    If s_regim == 1
      If Empty( s_shablon )
        s_shablon := '*'
      Endif
      If mem_smp_input == 1 .and. ( ( Len( glob_otd ) > 2 .and. glob_otd[ 3 ] == 4 ) .or. ;
          ( Len( glob_otd ) > 3 .and. eq_any( glob_otd[ 4 ], TIP_LU_SMP, TIP_LU_NMP ) ) ) // скорая помощь (неотложная мед.помощь)
        s_shablon := ''
        Keyboard Chr( K_ENTER )
      Endif
      tmp := PadR( s_shablon, 20 )
      tmp_color := SetColor( color1 )
      buf := box_shadow( 18, 9, 20, 70 )
      @ 19, 11 Say 'Введите шаблон для поиска в картотеке' Get tmp Pict '@K@!'
      s := sesc + senter + sF10p
      If !Empty( name_reader )
        s += sF11
      Endif
      status_key( AllTrim( s ) )
    Elseif s_regim == 2
      tmp := PadR( s_polis, 17 )
      tmp_color := SetColor( color8 )
      buf := box_shadow( 18, 9, 20, 70 )
      @ 19, 13 Say 'Введите ПОЛИС для поиска в картотеке' Get tmp Pict '@K@!'
      s := sesc + senter + sF10s
      If !Empty( name_reader )
        s += sF11
      Endif
      status_key( AllTrim( s ) )
    Else
      tmp := PadR( s_snils, 11 )
      tmp_color := SetColor( color14 )
      buf := box_shadow( 18, 9, 20, 70 )
      @ 19, 14 Say 'Введите СНИЛС для поиска в картотеке' Get tmp Pict '@K' + picture_pf() Valid val_snils( tmp, 1 )
      s := sesc + senter + sF10f
      If !Empty( name_reader )
        s += sF11
      Endif
      status_key( AllTrim( s ) )
    Endif
    Set Key K_F10 To clear_gets
    If !Empty( name_reader )
      Set Key K_F11 To clear_gets
    Endif
    myread( { 'confirm' } )
    Set Key K_F11 To
    Set Key K_F10 To
    SetColor( tmp_color )
    rest_box( buf24 )
    rest_box( buf )
    If LastKey() == K_F10
      s_regim := iif( ++s_regim == 4, 1, s_regim )
    Elseif LastKey() == K_F11 .and. !Empty( name_reader )
      If mo_read_el_polis( @append_or_edit )
        mkod := glob_kartotek
        Exit
      Endif
    Else
      If LastKey() == K_ESC
        tmp := NIL
      Else
        If s_regim == 1
          s_shablon := AllTrim( tmp )
        Elseif s_regim == 2
          s_polis := tmp
        Else
          s_snils := tmp
        Endif
      Endif
      Exit
    Endif
  Enddo
  If tmp == NIL
    //
  Elseif mkod > 0
    If append_or_edit == 2 // добавили в картотеку
      Keyboard Chr( K_ENTER )
      oms_sluch(, glob_kartotek )
    Else // перезаписали в картотеке
      If verify_lechenie( glob_kartotek, @k1 )
        If k1 > 0
          str_sem := 'Редактирование человека ' + lstr( glob_perso )
          If !g_slock( str_sem )
            Return func_error( 4, err_slock )
          Endif
          Private fl_v_lech := .t.
        Endif
        Keyboard Chr( K_ENTER )
        oms_sluch( k1, glob_kartotek )
        If k1 > 0
          g_sunlock( str_sem )
        Endif
      Endif
    Endif
  Elseif s_regim == 1
    s_shablon := AllTrim( tmp )
    If Empty( tmp := AllTrim( tmp ) )
      mkod := 0
      If k == 1  // режим 'Добавление' в задаче ОМС
        oms_sluch()
      Endif
    Elseif tmp == '*'
      If oms_view_kart( T_ROW )
        mkod := glob_kartotek
        If k == 1 .and. verify_lechenie( glob_kartotek, @k1 )
          If k1 > 0
            str_sem := 'Редактирование человека ' + lstr( glob_perso )
            If !g_slock( str_sem )
              Return func_error( 4, err_slock )
            Endif
            Private fl_v_lech := .t.
          Endif
          oms_sluch( k1, glob_kartotek )
          If k1 > 0
            g_sunlock( str_sem )
          Endif
        Endif
      Endif
    Else
      If is_uchastok == 1
        tmp1 := tmp
        If !( Left( tmp, 1 ) $ '0123456789' )
          mbukva := Left( tmp1, 1 )
          tmp1 := SubStr( tmp1, 2 )  // отбросить первую букву
        Endif
        For i := 1 To Len( tmp1 )
          If !( SubStr( tmp1, i, 1 ) $ '0123456789/' )
            fl_number := .f.
            Exit
          Endif
        Next
        If fl_number
          If ( i := At( '/', tmp1 ) ) == 0
            fl_number := .f.
          Else
            tmp := PadL( AllTrim( SubStr( tmp1, 1, i -1 ) ), 2, '0' ) + ;
              PadL( AllTrim( SubStr( tmp1, i + 1 ) ), 5, '0' )
          Endif
        Endif
      Else
        For i := 1 To Len( tmp )
          If !( SubStr( tmp, i, 1 ) $ '0123456789' )
            fl_number := .f.
            Exit
          Endif
        Next
      Endif
      If !fl_number
        If !( '*' $ tmp )
          tmp += '*'
        Endif
      Endif
      If k == 1
        If fvalid_fio( 1, tmp, fl_number, mbukva ) .and. ;
            verify_lechenie( glob_kartotek, @k1 )
          If k1 > 0
            str_sem := 'Редактирование человека ' + lstr( glob_perso )
            If !g_slock( str_sem )
              Return func_error( 4, err_slock )
            Endif
            Private fl_v_lech := .t.
          Endif
          oms_sluch( k1, glob_kartotek )
          If k1 > 0
            g_sunlock( str_sem )
          Endif
        Else
          Keyboard Chr( K_ENTER )  // 'нажать' кнопку 'Добавление'
        Endif
      Elseif k == 2
        If fvalid_fio( 1, tmp, fl_number, mbukva )
          mkod := glob_kartotek
        Else
          fl_bad_shablon := .t.
        Endif
      Endif
    Endif
  Elseif eq_any( s_regim, 2, 3 )  // поиск по полису/по СНИЛС
    If Empty( tmp )
      mkod := 0
      If k == 1  // режим 'Добавление' в задаче LPU
        oms_sluch()
      Endif
    Elseif k == 1
      If fvalid_fio( s_regim, tmp, fl_number, mbukva ) .and. ;
          verify_lechenie( glob_kartotek, @k1 )
        If k1 > 0
          str_sem := 'Редактирование человека ' + lstr( glob_perso )
          If !g_slock( str_sem )
            Return func_error( 4, err_slock )
          Endif
          Private fl_v_lech := .t.
        Endif
        oms_sluch( k1, glob_kartotek )
        If k1 > 0
          g_sunlock( str_sem )
        Endif
      Else
        Keyboard Chr( K_ENTER )  // 'нажать' кнопку 'Добавление'
      Endif
    Elseif k == 2
      If fvalid_fio( s_regim, tmp, fl_number, mbukva )
        mkod := glob_kartotek
      Else
        fl_bad_shablon := .t.
      Endif
    Endif
  Endif
  setinisect( tmp_ini, 'polikl1', { { 's_regim', lstr( s_regim ) }, ;
    { 's_shablon', s_shablon    }, ;
    { 's_polis', s_polis      }, ;
    { 's_snils', s_snils      } } )
  Return mkod

// выбор карточки из картотеки
Function oms_view_kart( r1, r2 )

  Local buf := SaveScreen(), mkod := 0, arr_blk, fl := .f.

  Default r1 To 2, r2 To MaxRow() -2
  Private mr1 := r1, mr2 := r2, str_find := '1', muslovie := 'kart->kod > 0'
  arr_blk := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find ) }, ;
    {| n| skippointer( n, muslovie ) }, ;
    str_find, muslovie;
    }
  If use_base( 'kartotek' )
    If glob_kartotek > 0
      Set Order To 1
      find ( Str( glob_kartotek, 7 ) )
      fl := Found()
    Endif
    Set Order To 2
    If !fl
      find ( str_find )
      If !Found()
        Close databases
        Return func_error( 4, 'Не найдено нужных записей!' )
      Endif
    Endif
    If alpha_browse( mr1, 2, mr2, 77, 'f1oms_view_kart', color0, , , , ;
        .t., arr_blk, , , , ;
        { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, R/BG, W+/R', , 300 } )
      If ( glob_kartotek := kart->kod ) == 0
        func_error( 4, 'Не найдено нужных записей!' )
      Elseif eq_any( glob_task, X_OMS, X_PPOKOJ ) .and. kart->MEST_INOG == 8
        func_error( 4, 'Не разрешается работать с анонимами в данной задаче!' )
      Else
        mkod := glob_kartotek
        glob_k_fio := AllTrim( kart->fio )
      Endif
    Endif
  Endif
  Close databases
  RestScreen( buf )
  Return ( mkod > 0 )

// 20.02.14
Function f1oms_view_kart( oBrow )

  Local oColumn, blk, n := 42

  If glob_mo[ _MO_IS_UCH ]
    blk := {|| iif( kart2->mo_pr == glob_MO[ _MO_KOD_TFOMS ], { 1, 2 }, ;
      iif( Empty( kart2->mo_pr ), { 3, 4 }, { 5, 6 } ) ) }
  Endif
  If mem_kodkrt == 2
    If is_uchastok == 1
      n -= 11
    Elseif eq_any( is_uchastok, 2, 3 )
      n -= 12
    Else
      n -= 7
    Endif
  Endif
  oColumn := TBColumnNew( Center( 'Фамилия, имя, отчество', n ), {|| Left( kart->fio, n ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If mem_kodkrt == 2
    If is_uchastok > 0
      oColumn := TBColumnNew( ' ', {|| kart->bukva } )
      oColumn:defColor := { 3, 3 }
      oColumn:colorBlock := {|| { 3, 3 } }
      oBrow:addcolumn( oColumn )
      oColumn := TBColumnNew( 'Уч', {|| put_val( kart->uchast, 2 ) } )
      oColumn:defColor := { 3, 3 }
      oColumn:colorBlock := {|| { 3, 3 } }
      oBrow:addcolumn( oColumn )
    Endif
    If is_uchastok == 1
      oColumn := TBColumnNew( ' Код', {|| put_val( kart->kod_vu, 5 ) } )
      oColumn:defColor := { 3, 3 }
      oColumn:colorBlock := {|| { 3, 3 } }
      oBrow:addcolumn( oColumn )
    Elseif is_uchastok == 2
      oColumn := TBColumnNew( '  Код', {|| kart->kod } )
      oColumn:defColor := { 3, 3 }
      oColumn:colorBlock := {|| { 3, 3 } }
      oBrow:addcolumn( oColumn )
    Elseif is_uchastok == 3
      oColumn := TBColumnNew( 'Код АК', {|| Left( kart2->kod_AK, 6 ) } )
      oColumn:defColor := { 3, 3 }
      oColumn:colorBlock := {|| { 3, 3 } }
      oBrow:addcolumn( oColumn )
    Endif
  Endif
  oColumn := TBColumnNew( 'Дата рожд.', {|| full_date( kart->date_r ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Полис', 17 ), {|| ' ' + kart->polis } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  Return Nil

// 05.02.19 есть ли листы учёта по данному пациенту
Function verify_lechenie( kod_kart, /*@*/p1)

  Local buf := save_maxrow(), arr := {}, i, k, r2, mas2, mpic

  p1 := 0
  mywait()
  r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_h', 'PP' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humankk', 'HUMAN' )
  For k := 1 To B_STANDART
    // k = 1 - проверим листы, добавленные в Приёмном покое - уже так не делаем
    // k = 2(B_END) - проверим листы с незавершённым лечением
    // B_STANDART = 3 - проверим листы с завершённым лечением
    find ( Str( kod_kart, 7 ) + Str( k, 1 ) )
    Do While human->kod_k == kod_kart .and. human->tip_h == k .and. !Eof()
      human_->( dbGoto( human->( RecNo() ) ) )
      If Empty( human_->reestr ) .and. !eq_any( human->ishod, 88, 89 ) // если человек в данный момент лечится
        AAdd( arr, { '', ;
          date_8( human->n_data ), ;
          date_8( human->k_data ), ;
          human->cena_1, ;
          human->kod, ;
          human->otd, ;
          '', ;
          human->tip_h, ;
          human->lpu, ;
          '', ;
          human->k_data;
          } )
        i := Len( arr )
        Select PP
        find ( Str( human->kod, 7 ) )
        If Found()
          arr[ i, 8 ] := B_BOLEN // поэтому искусственно делаем приёмный покой
        Endif
        arr[ i, 7 ] := iif( arr[ i, 8 ] == B_STANDART, Space( 7 ), iif( arr[ i, 8 ] == B_END, 'не зав.', 'п/покой' ) )
      Endif
      Select HUMAN
      Skip
    Enddo
  Next
  pp->( dbCloseArea() )
  human_->( dbCloseArea() )
  human->( dbCloseArea() )
  If ( k := Len( arr ) ) > 0
    r_use( dir_server() + 'mo_otd', , 'OTD' )
    AEval( arr, {| x, i| otd->( dbGoto( x[ 6 ] ) ), arr[ i, 1 ] := Left( otd->name, 30 ) } )
    Use
    If k == 1
      r_use( dir_server() + 'mo_uch', , 'UCH' )
      AEval( arr, {| x, i| uch->( dbGoto( x[ 9 ] ) ), arr[ i, 10 ] := ' [' + AllTrim( uch->name ) + ']' } )
      Use
      clrline( MaxRow(), color0 )
      If f_alert( { 'На выбранного больного уже выписан лист учета в отделении', ;
          CharOne( '"', '"' + AllTrim( arr[ 1, 1 ] ) + '"' + arr[ 1, 10 ] ), ;
          iif( arr[ 1, 8 ] == B_STANDART, '', iif( arr[ 1, 8 ] == B_END, '(Лечение не завершено)', '(Добавили в приёмном покое)' ) ), ;
          '[ Период лечения с ' + arr[ 1, 2 ] + ' по ' + arr[ 1, 3 ] + ' ]', ;
          'Выберите действие:' }, ;
          { ' ~Новый лист учета ', ' ~Редактирование старого листа учета ' }, ;
          1, ;
          'N+/BG', ;
          'R/BG', 15, , col1menu ) == 2
        glob_perso := p1 := arr[ 1, 5 ]
        r_use( dir_server() + 'mo_otd', , 'OTD' )
        Goto ( arr[ 1, 6 ] )
        glob_otd := { otd->kod, AllTrim( otd->name ), otd->idump, otd->tiplu }
        Use
      Endif
    Else
      r_use( dir_server() + 'mo_uch', , 'UCH' )
      AEval( arr, {| x, i| uch->( dbGoto( x[ 9 ] ) ), arr[ i, 10 ] := uch->short_name } )
      Use
      ASort( arr, , , {| x, y| x[ 11 ] < y[ 11 ] } )
      mas2 := { { 1, Center( 'Отделение', 30 ) }, ;
        { 10, 'Учреж;дение' }, ;
        { 2, 'Начало;лечения' }, ;
        { 3, 'Окончан.;лечения' }, ;
        { 4, '   Сумма; лечения' }, ;
        { 7, 'Приме-;чание' } }
      mpic := {, , , , { 9, 2 }, }
      status_key( '^<Esc>^ - новый лист учета;  ^<Enter>^ - добавление в старый лист учета' )
      If ( r2 := T_ROW + k + 4 ) > MaxRow() -2
        r2 := MaxRow() -2
      Endif
      If ( k := arrn_browse( T_ROW, 2, r2, 77, arr, mas2, 1, , color0, ;
          'Листы учета по больному, не включенные в реестры', 'B/BG', , , mpic, , , ;
          { '═', '░', '═' } ) ) > 0
        glob_perso := p1 := arr[ k, 5 ]
        r_use( dir_server() + 'mo_otd', , 'OTD' )
        Goto ( arr[ k, 6 ] )
        glob_otd := { otd->kod, AllTrim( otd->name ), otd->idump, otd->tiplu }
        Use
      Endif
    Endif
  Endif
  rest_box( buf )
  Return .t.

// 12.09.25 поиск по шаблону в картотеке
Function fvalid_fio( lregim, input_sh, fl_number, mbukva )

  Local fl := .f., pos1, pos2, tmp_list, buf, ;
    tmp2 := '', c1, fl_bukva, s_msg, rec_tmp := 0

  Default lregim To 1, mbukva To ''
  If !myfiledeleted( cur_dir() + 'tmp_kart' + sdbf() )
    Return fl
  Endif
  Private top_frm
  If lregim == 1
    Private mfio := input_sh
    pos1 := At( '*', mfio )
    pos2 := At( '?', mfio )
  Elseif lregim == 2
    Private mpolis := input_sh
  Else
    Private msnils := input_sh
  Endif
  //
  Private tmp1, ch
  buf := SaveScreen()
  dbCreate( cur_dir() + 'tmp_kart', { { 'kod', 'N', 7, 0 }, ;
    { 'fio', 'C', 50, 0 }, ;
    { 'mest_inog', 'N', 1, 0 }, ;
    { 'bukva', 'C', 1, 0 }, ;
    { 'uchast', 'N', 2, 0 }, ;
    { 'kod_vu', 'N', 5, 0 }, ;
    { 'kod_AK', 'C', 6, 0 } } )
  Use ( cur_dir() + 'tmp_kart' ) New Alias TMP
  Index On Upper( fio ) to ( cur_dir() + 'tmp_kart' )
  If lregim == 1
    If fl_number
      If is_uchastok == 1
        r_use( dir_server() + 'kartotek', dir_server() + 'kartoteu', 'KART' )
        find ( input_sh )
        If Found()
          mywait()
          fl_bukva := ( Right( input_sh, 5 ) == '00000' .and. !Empty( mbukva ) )
          fl := .t.
          Do While input_sh == ( StrZero( kart->uchast, 2 ) + StrZero( kart->kod_vu, 5 ) )
            If if( fl_bukva, ( kart->bukva == mbukva ), .t. )
              Select TMP
              Append Blank
              tmp->kod := kart->kod
              tmp->fio := kart->fio
              tmp->mest_inog := kart->mest_inog
              tmp->bukva := kart->bukva
              tmp->uchast := kart->uchast
              tmp->kod_vu := kart->kod_vu
              If tmp->kod == glob_kartotek
                rec_tmp := tmp->( RecNo() )
              Endif
            Endif
            Select KART
            Skip
          Enddo
          tmp2 := input_sh
        Else
          func_error( 4, 'Неудачный поиск по коду ' + input_sh + ' в картотеке!' )
        Endif
      Elseif is_uchastok != 3
        r_use( dir_server() + 'kartotek', , 'KART' )
        Goto ( Int( Val( input_sh ) ) )
        If !Eof() .and. kart->kod > 0 .and. !Deleted()
          fl := .t.
          Select TMP
          Append Blank
          tmp->kod := kart->kod
          tmp->fio := kart->fio
          tmp->mest_inog := kart->mest_inog
          tmp->bukva := kart->bukva
          tmp->uchast := kart->uchast
          tmp2 := input_sh
          If tmp->kod == glob_kartotek
            rec_tmp := tmp->( RecNo() )
          Endif
        Else
          func_error( 4, 'Неудачный поиск по коду ' + input_sh + ' в картотеке!' )
        Endif
      Endif
    Elseif ( pos1 > 0 .or. pos2 > 0 )
      waitstatus( 'Ждите! Производится поиск в картотеке.  (<Esc> - прервать поиск)' )
      @ 2, 0 Say ''
      r_use( dir_server() + 'kartote2', , 'KART2' )
      r_use( dir_server() + 'kartotek', dir_server() + 'kartoten', 'KART' )
      Set Relation To RecNo() into KART2
      tmp2 := Upper( AllTrim( mfio ) )
      ch := Left( LTrim( mfio ), 1 )
      If !( ch == '*' .or. ch == '?' )
        tmp1 := tmp2
        If '*' $ tmp1
          tmp1 := BeforAtNum( '*', tmp1, 1 )
        Endif
        If '?' $ tmp1
          tmp1 := BeforAtNum( '?', tmp1, 1 )
        Endif
        If Len( tmp1 ) > 20
          tmp1 := Left( tmp1, 20 )
        Endif
        ch := Len( tmp1 )
        Select KART
        find ( '1' + tmp1 )
        Do While kart->kod > 0 .and. tmp1 == Left( Upper( fio ), ch ) .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            Exit
          Endif
          If Like( tmp2, Upper( kart->fio ) )
            Select TMP
            Append Blank
            tmp->kod := kart->kod
            tmp->fio := kart->fio
            tmp->mest_inog := kart->mest_inog
            If is_uchastok > 0
              tmp->bukva := kart->bukva
              tmp->uchast := kart->uchast
              tmp->kod_vu := kart->kod_vu
              If is_uchastok == 3
                tmp->kod_AK := kart2->kod_AK
              Endif
            Endif
            If tmp->kod == glob_kartotek
              rec_tmp := tmp->( RecNo() )
            Endif
          Endif
          Select KART
          Skip
        Enddo
      Else
        Select KART
        find ( '1' )
        Do While kart->kod > 0 .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            Exit
          Endif
          If Like( tmp2, Upper( kart->fio ) )
            Select TMP
            Append Blank
            tmp->kod := kart->kod
            tmp->fio := kart->fio
            tmp->mest_inog := kart->mest_inog
            If is_uchastok > 0
              tmp->bukva := kart->bukva
              tmp->uchast := kart->uchast
              tmp->kod_vu := kart->kod_vu
              If is_uchastok == 3
                tmp->kod_AK := kart2->kod_AK
              Endif
            Endif
            If tmp->kod == glob_kartotek
              rec_tmp := tmp->( RecNo() )
            Endif
          Endif
          Select KART
          Skip
        Enddo
      Endif
    Endif
    s_msg := 'по шаблону ' + tmp2
  Elseif lregim == 2
    waitstatus( 'Ждите! Производится поиск в картотеке.  (<Esc> - прервать поиск)' )
    @ 2, 0 Say ''
    r_use( dir_server() + 'kartote2', , 'KART2' )
    r_use( dir_server() + 'kartotek', dir_server() + 'kartotep', 'KART' )
    Set Relation To RecNo() into KART2
    find ( '1' + mpolis )
    Do While kart->polis == mpolis .and. kart->kod > 0 .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        Exit
      Endif
      Select TMP
      Append Blank
      tmp->kod := kart->kod
      tmp->fio := kart->fio
      tmp->mest_inog := kart->mest_inog
      If is_uchastok > 0
        tmp->bukva := kart->bukva
        tmp->uchast := kart->uchast
        tmp->kod_vu := kart->kod_vu
        If is_uchastok == 3
          tmp->kod_AK := kart2->kod_AK
        Endif
      Endif
      If tmp->kod == glob_kartotek
        rec_tmp := tmp->( RecNo() )
      Endif
      Select KART
      Skip
    Enddo
    s_msg := 'по полису ' + AllTrim( mpolis )
  Elseif lregim == 3
    waitstatus( 'Ждите! Производится поиск в картотеке.  (<Esc> - прервать поиск)' )
    @ 2, 0 Say ''
    r_use( dir_server() + 'kartote2', , 'KART2' )
    r_use( dir_server() + 'kartotek', dir_server() + 'kartotes', 'KART' )
    Set Relation To RecNo() into KART2
    find ( '1' + msnils )
    Do While kart->snils == msnils .and. kart->kod > 0 .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        Exit
      Endif
      Select TMP
      Append Blank
      tmp->kod := kart->kod
      tmp->fio := kart->fio
      tmp->mest_inog := kart->mest_inog
      If is_uchastok > 0
        tmp->bukva := kart->bukva
        tmp->uchast := kart->uchast
        tmp->kod_vu := kart->kod_vu
        If is_uchastok == 3
          tmp->kod_AK := kart2->kod_AK
        Endif
      Endif
      If tmp->kod == glob_kartotek
        rec_tmp := tmp->( RecNo() )
      Endif
      Select KART
      Skip
    Enddo
//    s_msg := 'по СНИЛС ' + Transform( mSNILS, picture_pf )
    s_msg := 'по СНИЛС ' + Transform_SNILS( mSNILS )
  Endif
  fl := ( tmp->( LastRec() ) > 0 )
  Close databases
  If fl
    If !( Type( 'is_r_mu' ) == 'L' )
      Public is_r_mu := .f.
    Endif
    Save gets To tmp_list
    r_use( dir_server() + 'kartote2', , 'KART2' )
    r_use( dir_server() + 'kartote_', , 'KART_' )
    r_use( dir_server() + 'kartotek', , 'KART' )
    Use ( cur_dir() + 'tmp_kart' ) index ( cur_dir() + 'tmp_kart' ) New Alias TMP
    Set Relation To kod into KART, To kod into KART_, To kod into KART2
    If rec_tmp > 0
      Goto ( rec_tmp )
    Else
      Go Top
    Endif
    change_attr()
    top_frm := 14
    @ 13, 0 Say PadC( '_Просмотр картотеки_', 80, '░' ) Color 'R/BG'
    c1 := 24
    If mem_kodkrt == 2
      If is_uchastok == 1
        c1 -= 10
      Elseif eq_any( is_uchastok, 2, 3 )
        c1 -= 12
      Else
        c1 -= 7
      Endif
    Endif
    If ( fl := alpha_browse( 0, c1, 11, 77, 'f1_v_fiotmp', color0, ;
        'Результат отбора ' + s_msg, 'B/BG', .f., .t., , ;
        'f2_v_fio', , , { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, R/BG, W+/R', , 0 } ) )
      If glob_task == X_OMS .and. tmp->MEST_INOG == 8
        fl := func_error( 4, 'Не разрешается работать с анонимами в задаче ОМС!' )
      Else
        m1kod_k := glob_kartotek := tmp->kod
        glob_k_fio := AllTrim( tmp->fio )
      Endif
    Endif
    Close databases
  Else
    func_error( 4, 'Неудачный поиск ' + s_msg + ' в картотеке!' )
  Endif
  RestScreen( buf )
  Return fl

//
Function f1_v_fiotmp( oBrow )

  Local blk

  If glob_mo[ _MO_IS_UCH ]
    blk := {|| iif( kart2->mo_pr == glob_MO[ _MO_KOD_TFOMS ], { 1, 2 }, iif( Empty( kart2->mo_pr ), { 3, 4 }, { 5, 6 } ) ) }
  Endif
  oColumn := TBColumnNew( Center( 'Ф.И.О.', 49 ), {|| PadR( tmp->fio, 49 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If mem_kodkrt == 2
    If is_uchastok > 0
      oColumn := TBColumnNew( ' ', {|| tmp->bukva } )
      oColumn:colorBlock := blk
      oBrow:addcolumn( oColumn )
      //
      oColumn := TBColumnNew( 'Уч', {|| put_val( tmp->uchast, 2 ) } )
      oColumn:colorBlock := blk
      oBrow:addcolumn( oColumn )
    Endif
    If is_uchastok == 1
      oColumn := TBColumnNew( ' Код', {|| put_val( tmp->kod_vu, 5 ) } )
      oColumn:colorBlock := blk
      oBrow:addcolumn( oColumn )
    Elseif is_uchastok == 2
      oColumn := TBColumnNew( '  Код', {|| Str( tmp->kod, 7 ) } )
      oColumn:colorBlock := blk
      oBrow:addcolumn( oColumn )
    Elseif is_uchastok == 3
      oColumn := TBColumnNew( 'Код АК', {|| tmp->kod_AK } )
      oColumn:colorBlock := blk
      oBrow:addcolumn( oColumn )
    Endif
  Endif
  status_key( '^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор' )
  Return Nil

//
Function f1_v_fio( oBrow )

  Local oColumn

  oColumn := TBColumnNew( Center( 'Ф.И.О.', 49 ), {|| PadR( tmp->fio, 49 ) } )
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор' )
  Return Nil

//
Function f2_v_fio()

  kartotek_to_screen( 14, 23 )
  If !( Type( 'dubl1_kart' ) == 'N' )
    Select TMP
  Endif
  Return Nil

//
Function input_schet( rr, r, c )

  Local mas_pmt := { 'Поиск по ~номеру счета', ;
    'Поиск по ~принадлежности счета' }
  Local i, k, recc := 0, fl := .f., buf, tmp_color := SetColor(), ar
  Local adbf_tmp := { ;
    { 'KOD',        'N',      6,      0 }, ;
    { 'NOMER_S',    'C',     15,      0 }, ;
    { 'DATE_S',     'D',      8,      0 }, ;
    { 'SUMMA',      'N',     13,      2 }, ;
    { 'KOL',        'N',      4,      0 }, ;
    { 'NAME',       'C',     40,      0 }, ;
    { 'KRIT',       'C',     10,      0 }, ;
    { 'KOMU',       'N',      1,      0 }, ;
    { 'SMO',        'C',      5,      0 }, ; // код СМО
    { 'STR_CRB',    'N',      2,      0 };
    }

  Default r To T_ROW, c To T_COL -5
  If !myfiledeleted( cur_dir() + 'tmp' + sdbf() )
    Return fl
  Endif
  ar := getinisect( tmp_ini, 'schet' )
  Private mnomer := PadR( a2default( ar, 'number' ), 15 ), ;
    p_i := Val( a2default( ar, 'i', '1' ) )
  If .t. // (i := popup_prompt(r,c,p_i,mas_pmt)) > 0
    p_i := i := 1  // !!!!
    Do Case
    Case i == 1
      buf := box_shadow( 16, 20, 20, 59, color8 )
      tmp_color := SetColor( cDataCGet )
      buf24 := save_maxrow()
      status_key( '^<Esc>^ - отказ;  ^<Enter>^ - подтверждение выбора счета' )
      @ 18, 22 Say 'Введите номер счета' Get mnomer Picture '@!@K'
      myread( { 'confirm' } )
      If LastKey() != K_ESC .and. !Empty( mnomer )
        dbCreate( cur_dir() + 'tmp', adbf_tmp )
        Use ( cur_dir() + 'tmp' ) New Alias TMP
        r_use( dir_server() + 'schet_', , 'SCHET_' )
        r_use( dir_server() + 'schet', dir_server() + 'schetn', 'SCHET' )
        Set Relation To RecNo() into SCHET_
        find ( PadR( mnomer, 10 ) )
        If Found()
          Do While schet->nomer_s == PadR( mnomer, 10 ) .and. !Eof()
            If schet_->NSCHET == mnomer
              recc++
              Select TMP
              Append Blank
              tmp->KOD     := schet->KOD
              tmp->NOMER_S := schet_->NSCHET
              tmp->DATE_S  := schet_->DSCHET
              tmp->SUMMA   := schet->SUMMA
              tmp->KOL     := schet->KOL
              tmp->KOMU    := schet->KOMU
              tmp->smo     := schet_->smo
              tmp->STR_CRB := schet->STR_CRB
              tmp->krit    := f3_view_list_schet()
            Endif
            Select SCHET
            Skip
          Enddo
        Endif
        schet_->( dbCloseArea() )
        schet->( dbCloseArea() )
        rest_box( buf )
        rest_box( buf24 )
        SetColor( tmp_color )
        If recc > 0
          Select TMP
          If recc == 1
            fl := .t.
            Go Top
            glob_schet := tmp->kod
          Else
            dbEval( {|| tmp->name := f4_view_list_schet( tmp->komu, tmp->smo, tmp->str_crb ) } )
            Index On Descend( DToS( date_s ) ) to ( cur_dir() + 'tmp' )
            Go Top
            If ( fl := alpha_browse( T_ROW, 2, MaxRow() -2, 77, 'f1inp_schet', color0, ;
                'Счета с номером ' + AllTrim( mnomer ), 'R/BG', ;
                .f., , , , , , { '═', '░', '═', , , 180 } ) )
              glob_schet := tmp->kod
            Endif
          Endif
        Else
          func_error( 4, 'Счёта с номером ' + AllTrim( mnomer ) + ' нет в базе данных!' )
        Endif
      Endif
    Case i == 2
      ne_real()
    Endcase
  Endif
  Close databases
  setinisect( tmp_ini, 'schet', { { 'number', mnomer }, { 'i', lstr( p_i ) } } )
  If fl
    r_use( dir_server() + 'schet_', , 'SCHET_' )
    r_use( dir_server() + 'schet', dir_server() + 'schetk', 'SCHET' )
    Set Relation To RecNo() into SCHET_
    find ( Str( glob_schet, 6 ) )
    box_shadow( rr, 0, rr + 7, 33, color1, 'Информация о счете', color8, 0 )
    SetColor( color8 )
    @ rr + 1, 8 Say '~~~~~~~~~~~~~~~~~~'
    SetColor( color1 )
    @ rr + 2, 1 Say '№ ' + AllTrim( schet_->NSCHET ) + ' от ' + date_8( schet_->DSCHET ) + 'г.'
    @ rr + 3, 1 Say 'Критерий: ' + f3_view_list_schet() Color 'BG+/B'
    @ rr + 4, 1 Say Left( f4_view_list_schet(), 33 ) Color 'G+/B'
    @ rr + 5, 1 Say 'Кол-во больных в счете: ' + lstr( schet->kol ) + ' чел.'
    @ rr + 6, 1 Say 'Сумма счета: ' + expand_value( schet->summa, 2 ) + ' руб.'
    schet_->( dbCloseArea() )
    schet->( dbCloseArea() )
  Endif
  SetColor( tmp_color )
  Return fl

//
Function f1inp_schet( oBrow )

  Local oColumn

  oColumn := TBColumnNew( '  Номер;  счета', {|| tmp->nomer_s } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '  Дата;  счета', {|| tmp->date_s } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Кол.;бол.', {|| tmp->kol } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Сумма счета', {|| put_kop( tmp->summa, 12 ) } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Критерий', {|| tmp->krit } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Принадлежность счета', 24 ), {|| Left( tmp->name, 24 ) } )
  oBrow:addcolumn( oColumn )
  Return Nil

//
Function fs_krit()

  Local s := ''

  If Empty( schet_->NAME_XML )
    If schet->MEST_INOG == 5 .or. schet_->IS_MODERN == 1
      s := 'законч.случай'
      If Between( schet->RAB_NERAB, 0, 2 )
        s := { 'раб', 'нер', 'н/д' }[ schet->RAB_NERAB + 1 ] + '/' + s
      Endif
    Elseif schet_->IS_DOPLATA == 1 .and. schet_->IFIN == 2
      s := 'ДОПЛАТА ФФОМС'
    Elseif schet_->IS_DOPLATA == 1 .and. schet_->IFIN == 1
      s := 'ДОПЛАТА ТФОМС'
    Else
      If Between( schet->RAB_NERAB, 0, 2 )
        s := { 'раб', 'нер', 'н/д' }[ schet->RAB_NERAB + 1 ] + '/'
      Else
        s := Space( 4 )
      Endif
      If Between( schet->MI_GIT, 0, 2 )
        s += { 'гор.', 'обл.', 'иног' }[ schet->MI_GIT + 1 ]
      Endif
      If Between( schet->vid_mp, 0, 6 )
        s += '/' + { 'амб.', 'стац', 'дс/п', 'дому', 'дс/б', 'стом', 'УДП' }[ schet->vid_mp + 1 ]
      Endif
    Endif
  Else
    If schet_->IS_MODERN == 1
      If Right( RTrim( schet_->NSCHET ), 1 ) == 'M'
        s := 'законч.случай'
      Else
        s := 'УДП'
      Endif
    Endif
    If Empty( s ) .and. schet_->IFIN > 0
      s := 'ОМС '
      If schet_->IFIN == 1
        s += 'ТФОМС'
      Elseif schet_->IFIN == 2
        s += 'ФФОМС'
      Endif
    Endif
  Endif
  Return PadR( s, 13 )

//
Function func_kriterij()

  Local s := ''

  If Empty( schet_->NAME_XML )
    If schet->MEST_INOG == 5 .or. schet_->IS_MODERN == 1
      s := 'Критерий - по зак.случаям лечения'
    Else
      If Between( schet->VZROS_REB, 0, 2 )
        s += 'Критерий - ' + { 'взрослый', 'ребенок', 'подросток' }[ schet->VZROS_REB + 1 ] + '; '
      Endif
      If Between( schet->RAB_NERAB, 0, 2 )
        s += { 'Работающие', 'Неработающие', 'Нераб.дети' }[ schet->RAB_NERAB + 1 ] + '; '
      Endif
      If Between( schet->MI_GIT, 0, 2 )
        s += { 'Город', 'Область', 'Иногородние' }[ schet->MI_GIT + 1 ] + '; '
      Elseif Between( schet->MEST_INOG, 0, 2 )
        s += 'Финан-ие: ' + { 'Город', 'Область', 'Иногородние' }[ schet->MEST_INOG + 1 ] + '; '
      Endif
      If Between( schet->VID_MP, 0, 6 )
        s += '/' + { 'амб.', 'стац', 'дс/п', 'дому', 'дс/б', 'стом', 'УДП' }[ schet->vid_mp + 1 ] + ';'
      Endif
      If !Empty( s )
        s := Left( s, Len( s ) -2 )
      Endif
    Endif
  Else
    If schet_->IS_MODERN == 1
      If Right( RTrim( schet_->NSCHET ), 1 ) == 'M'
        s := 'Критерий - по зак.случаям лечения'
      Else
        s := 'Углубленная детская диспансеризация'
      Endif
    Endif
    If Empty( s ) .and. schet_->IFIN > 0
      s := 'ОМС '
      If schet_->IFIN == 1
        s += 'ТФОМС'
      Elseif schet_->IFIN == 2
        s += 'ФФОМС'
      Endif
    Endif
  Endif
  Return s

// 21.03.14
Function save_arr_predn( lkod )

  Local arr := {}, k, ta

  Private mvar

  If Type( 'mfio' ) == 'C'
    AAdd( arr, { 'mfio', AllTrim( mfio ) } )
  Endif
  If Type( 'mdate_r' ) == 'D'
    AAdd( arr, { 'mdate_r', mdate_r } )
  Endif
  AAdd( arr, { '1', mperiod } ) // 'N',номер диапазона (от 1 до 4)
  AAdd( arr, { '6', m1MO_PR } ) // 'C6',код МО прикрепления
  AAdd( arr, { '8', m1school } ) // 'N6',код образовательного учреждения
  AAdd( arr, { '9', m1tip_school } ) // 'N1',тип образовательного учреждения
  AAdd( arr, { '16.8', mGRUPPA } )    // 'N1',группа здоровья после дисп-ии
  AAdd( arr, { '16.9', m1GR_FIZ } )    // 'N1',группа здоровья для физкультуры
  // 18.результаты проведения исследований
  For i := 1 To count_predn_arr_iss
    mvar := 'MREZi' + lstr( i )
    If !Empty( &mvar )
      AAdd( arr, { '18.' + lstr( i ), AllTrim( &mvar ) } )
    Endif
  Next
  save_arr_dispans( lkod, arr )
  Return Nil

// 14.08.13
Function read_arr_predn( lkod )

  Local arr, i, k

  Private mvar

  arr := read_arr_dispans( lkod )
  For i := 1 To Len( arr )
    If ValType( arr[ i ] ) == 'A' .and. ValType( arr[ i, 1 ] ) == 'C'
      Do Case
      Case arr[ i, 1 ] == '1' .and. ValType( arr[ i, 2 ] ) == 'N'
        mperiod := arr[ i, 2 ]
      Case arr[ i, 1 ] == '6' .and. ValType( arr[ i, 2 ] ) == 'C'
        m1MO_PR := arr[ i, 2 ]
      Case arr[ i, 1 ] == '8' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1school := arr[ i, 2 ]
      Case arr[ i, 1 ] == '9' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1tip_school := arr[ i, 2 ]
      Case arr[ i, 1 ] == '16.8' .and. ValType( arr[ i, 2 ] ) == 'N'
        // mGRUPPA := arr[i, 2]
      Case arr[ i, 1 ] == '16.9' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1GR_FIZ := arr[ i, 2 ]
      Otherwise
        For k := 1 To count_predn_arr_iss
          If arr[ i, 1 ] == '18.' + lstr( k ) .and. ValType( arr[ i, 2 ] ) == 'C'
            mvar := 'MREZi' + lstr( k )
            &mvar := PadR( arr[ i, 2 ], 17 )
          Endif
        Next
      Endcase
    Endif
  Next
  Return Nil

// 21.03.14
Function save_arr_pern( lkod )

  Local arr := {}, k, ta

  Private mvar

  If Type( 'mfio' ) == 'C'
    AAdd( arr, { 'mfio', AllTrim( mfio ) } )
  Endif
  If Type( 'mdate_r' ) == 'D'
    AAdd( arr, { 'mdate_r', mdate_r } )
  Endif
  AAdd( arr, { '1', mperiod } ) // 'N',номер диапазона (от 1 до 4)
  AAdd( arr, { '6', m1MO_PR } ) // 'C6',код МО прикрепления
  AAdd( arr, { '8', m1school } ) // 'N6',код образовательного учреждения
  AAdd( arr, { '9', m1tip_school } ) // 'N1',тип образовательного учреждения
  AAdd( arr, { '10', m1protivo } ) // 'N1',противопоказания к продолжению учёбы
  // 18.результаты проведения исследований
  For i := 1 To count_pern_arr_iss
    mvar := 'MREZi' + lstr( i )
    If !Empty( &mvar )
      AAdd( arr, { '18.' + lstr( i ), AllTrim( &mvar ) } )
    Endif
  Next
  save_arr_dispans( lkod, arr )
  Return Nil

// 25.08.13
Function read_arr_pern( lkod )

  Local arr, i, k

  Private mvar

  arr := read_arr_dispans( lkod )
  For i := 1 To Len( arr )
    If ValType( arr[ i ] ) == 'A' .and. ValType( arr[ i, 1 ] ) == 'C'
      Do Case
      Case arr[ i, 1 ] == '1' .and. ValType( arr[ i, 2 ] ) == 'N'
        mperiod := arr[ i, 2 ]
      Case arr[ i, 1 ] == '6' .and. ValType( arr[ i, 2 ] ) == 'C'
        m1MO_PR := arr[ i, 2 ]
      Case arr[ i, 1 ] == '8' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1school := arr[ i, 2 ]
      Case arr[ i, 1 ] == '9' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1tip_school := arr[ i, 2 ]
      Case arr[ i, 1 ] == '10' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1protivo := arr[ i, 2 ]
      Otherwise
        For k := 1 To count_pern_arr_iss
          If arr[ i, 1 ] == '18.' + lstr( k ) .and. ValType( arr[ i, 2 ] ) == 'C'
            mvar := 'MREZi' + lstr( k )
            &mvar := PadR( arr[ i, 2 ], 17 )
          Endif
        Next
      Endcase
    Endif
  Next
  Return Nil

// 19.09.13
Function save_arr_dispans( lkod, arr )

  Local l, s, i, i1, i2, arr_d := {}, tmp_select := Select()

  If Empty( arr )
    Return Nil
  Endif
  use_base( 'mo_hdisp' )
  find ( Str( lkod, 7 ) )
  Do While hdisp->kod == lkod .and. !Eof()
    AAdd( arr_d, hdisp->( RecNo() ) )
    Skip
  Enddo
  l := FieldLen( FieldNum( 'NAME' ) ) // берём длину поля базы данных
  s := save_arr_mem( arr ) // сохранение массива в символьной переменной
  arr := {}
  Do While Len( s ) > 0
    AAdd( arr, Left( s, l ) )
    s := SubStr( s, l + 1 )
  Enddo
  i1 := Len( arr_d )
  i2 := Len( arr )
  For i := 1 To i2
    If i > i1
      add1rec( 7 )
      hdisp->kod := lkod
    Else
      Goto ( arr_d[ i ] )
      g_rlock( forever )
    Endif
    hdisp->ks := i
    hdisp->name := arr[ i ]
  Next
  If i2 < i1
    For i := i2 + 1 To i1
      Goto ( arr_d[ i ] )
      deleterec( .t. )
    Next
  Endif
  hdisp->( dbCloseArea() )
  Select ( tmp_select )
  Return Nil

// 16.06.13
Function read_arr_dispans( lkod )

  Local s := '', tmp_select := Select()

  use_base( 'mo_hdisp' )
  find ( Str( lkod, 7 ) )
  Do While hdisp->kod == lkod .and. !Eof()
    s += hdisp->name
    Skip
  Enddo
  hdisp->( dbCloseArea() )
  Select ( tmp_select )
  Return rest_arr_mem( s ) // востановление массива из символьной переменной s
