// распечатка различных справочников - mo_spri.prg
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 08.09.23 просмотр/печать общих справочников
Function o_sprav( k )

  Static sk := 1, sk1 := 1, sk2 := 1
  Local str_sem, mas_pmt, mas_msg, mas_fun, j

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { '~Услуги', ;
      '~Диагнозы', ;
      '~Персонал', ;
      '~Онкология', ;
      '~Другие справочники' }
    mas_msg := { 'Услуги', ;
      'Диагнозы', ;
      'Персонал', ;
      'Просмотр справочников, относящихся к Приказу ФФОМС №59 по онкологии', ;
      'Другие справочники' }
    mas_fun := { 'o_sprav(1)', ;
      'o_sprav(2)', ;
      'o_sprav(3)', ;
      'o_sprav(4)', ;
      'o_sprav(5)' }
    If mem_kodotd == 2
      AAdd( mas_pmt, 'Коды ~отделений' )
      AAdd( mas_msg, 'Коды отделений' )
      AAdd( mas_fun, 'o_sprav(6)' )
    Endif
    uch_otd := saveuchotd()
    popup_prompt( T_ROW, T_COL -5, sk, mas_pmt, mas_msg, mas_fun )
    restuchotd( uch_otd )
  Case k == 1
    fspr_uslugi()
  Case k == 2
    spr_info_diagn()
  Case k == 3
    spr_personal()
  Case k == 4
    mas_pmt := { 'Услуги диагностики при дообследовании на ~ЗНО', ;
      'Услуги по типам лечения ~ОНКОзаболеваний', ;
      'Обязательные типы услуг для методов ВМП', ;
      'Справочники N~0...' }
    mas_msg := { 'Вывод списка услуг диагностики при дообследовании в направлениях на ЗНО', ;
      'Вывод списка услуг по типам лечения ОНКОзаболеваний', ;
      'Вывод обязательных типов услуг для каждого метода ВМП в онкологических случаях', ;
      'Распечатка справочников, участвующих в заполнении контрольного листа' }
    mas_fun := { 'o_sprav(11)', ;
      'o_sprav(12)', ;
      'o_sprav(13)', ;
      'o_sprav(14)' }
    popup_prompt( T_ROW -3 - Len( mas_pmt ), T_COL -5, sk1, mas_pmt, mas_msg, mas_fun )
  Case k == 5
    spr_other()
  Case k == 6
    spr_kod_otd()
  Case k == 11 // Вывод списка услуг диагностики при дообследовании в направлениях на ЗНО
    usl_napr_ffoms()
  Case k == 12 // Вывод списка услуг по типам лечения ОНКОзаболеваний
    usl_ksg_ffoms()
  Case k == 13 // Обязательные типы услуг для методов ВМП
    pr_sprav_onk_vmp()
  Case k == 14
    mas_pmt := { 'Классификатор стадий (N00~2)', ;
      'Классификатор Tumor (N00~3)', ;
      'Классификатор Nodus (N00~4)', ;
      'Классификатор Metastasis (N00~5)' } // , ;
    // 'Справочник соответствия стадий TNM (N00~6)'}
    mas_msg := { 'Распечатка классификатора стадий (N002)', ;
      'Распечатка классификатора Tumor (N003)', ;
      'Распечатка классификатора Nodus (N004)', ;
      'Распечатка классификатора Metastasis (N005)' }  // , ;
    // 'Распечатка справочника соответствия стадий TNM (N006)'}
    mas_fun := { 'o_sprav(21)', ;
      'o_sprav(22)', ;
      'o_sprav(23)', ;
      'o_sprav(24)' }  // , ;
    // 'o_sprav(25)'}
    popup_prompt( T_ROW, T_COL -5, sk2, mas_pmt, mas_msg, mas_fun )
  Case k == 21 //
    // pr_sprav_N002(2)
    pr_sprav_onko( 2 )
  Case k == 22 //
    // pr_sprav_N002(3)
    pr_sprav_onko( 3 )
  Case k == 23 //
    // pr_sprav_N002(4)
    pr_sprav_onko( 4 )
  Case k == 24 //
    // pr_sprav_N002(5)
    pr_sprav_onko( 5 )
    // case k == 25 // Справочник соответствия стадий TNM
    // pr_sprav_N006()
  Endcase
  If k > 0
    If k > 20
      sk2 := k
    Elseif k > 10
      sk1 := k
    Else
      sk := k
    Endif
  Endif

  Return Nil

// 02.02.22
Function fspr_uslugi( k )

  Static _su := 110
  Static sk := 1, sk1 := 1, sk2 := 1
  Local str_sem, mas_pmt, mas_msg, mas_fun, j, s

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { 'Поиск по ~шифру', ;
      'Услуги по стандарту ~ТФОМС', ;
      'Услуги Минздрава РФ (~ФФОМС)', ;
      'Список услуг по ~ОМС', ;
      'Список ~платных услуг', ;
      'Список услуг по ~ДМС', ;
      'Услуги с ~нулевой ценой', ;
      'Печать ~комплексных услуг' }
    mas_msg := { 'Просмотр конкретной услуги с поиском по шифру', ;
      'Распечатка списка услуг с ценами ТФОМС по ОМС', ;
      'Распечатка номенклатуры медицинских услуг Минздрава РФ (ФФОМС)', ;
      'Распечатка списка услуг с ценами по ОМС', ;
      'Распечатка списка услуг с ценами на платные услуги', ;
      'Распечатка списка услуг с ценами по ДМС', ;
      'Распечатка услуг, для которых разрешается ввод нулевой цены', ;
      'Распечатка комплексных услуг' }
    mas_fun := { 'fspr_uslugi(1)', ;
      'fspr_uslugi(2)', ;
      'fspr_uslugi(3)', ;
      'fspr_uslugi(4)', ;
      'fspr_uslugi(5)', ;
      'fspr_uslugi(6)', ;
      'fspr_uslugi(7)', ;
      'fspr_uslugi(8)' }
    popup_prompt( T_ROW, T_COL -5, sk, mas_pmt, mas_msg, mas_fun )
  Case k == 1
    v_1usluga()
  Case k == 2
    mas_pmt := { '~Даты смены цен на услуги', ;
      '~Цены на конкретную дату', ;
      'Услуги ТФОМС -> ~наши услуги' }
    mas_msg := { 'Вывод списка изменений ТФОМС на цены услуг по конкретным датам', ;
      'Вывод списка услуг ТФОМС с ценами на указанную Вами дату', ;
      'Привязка Ваших услуг к услугам ТФОМС' }
    mas_fun := { 'fspr_uslugi(11)', ;
      'fspr_uslugi(12)', ;
      'fspr_uslugi(13)' }
    Private su := _su
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL -5, sk1, mas_pmt, mas_msg, mas_fun )
    _su := su
  Case k == 3
    mas_pmt := { 'Номенклатура медуслуг ~ФФОМС', ;
      '~Стоматологические услуги', ;
      'Услуги ~телемедицины', ;
      'Операции на ~парных органах', ;
      'Классификатор ~видов ВМП', ;
      'Классификатор ~методов ВМП', ;
      'Услуги ФФОМС -> ~наши услуги', ;
      'Список ~имплантатов' }
    mas_msg := { 'Вывод списка услуг Минздрава РФ (ФФОМС) по подразделам', ;
      'Вывод списка стоматологических услуг Минздрава РФ (ФФОМС) по группам', ;
      'Распечатка списка услуг с использованием телемедицинских технологий', ;
      'Распечатка списка операций на парных органах (частях тела)', ;
      'Распечатка классификатора видов ВМП', ;
      'Распечатка классификатора методов ВМП (с группировкой по видам ВМП)', ;
      'Привязка Ваших услуг к услугам ФФОМС', ;
      'Распечатка списка имплантатов' }
    mas_fun := { 'fspr_uslugi(21)', ;
      'fspr_uslugi(22)', ;
      'fspr_uslugi(23)', ;
      'fspr_uslugi(24)', ;
      'fspr_uslugi(25)', ;
      'fspr_uslugi(26)', ;
      'fspr_uslugi(27)', ;
      'fspr_uslugi(30)' }
    k := Len( mas_pmt )
    use_base( 'luslc' )
    Set Order To 2
    find ( glob_mo[ _MO_KOD_TFOMS ] + 'ds' )
    If Found()
      AAdd( mas_pmt, 'Услуги + КСГ (~дневной стационар)' )
      AAdd( mas_msg, 'Вывод списка разрешённых услуг ФФОМС вместе с КСГ дневного стационара' )
      AAdd( mas_fun, 'fspr_uslugi(28)' )
    Endif
    k := Len( mas_pmt )
    find ( glob_mo[ _MO_KOD_TFOMS ] + 'st' )
    If Found()
      AAdd( mas_pmt, 'Услуги + ~КСГ (стационар)' )
      AAdd( mas_msg, 'Вывод списка разрешённых услуг ФФОМС вместе с КСГ стационара' )
      AAdd( mas_fun, 'fspr_uslugi(29)' )
    Endif
    Close databases
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL -5, sk2, mas_pmt, mas_msg, mas_fun )
  Case k == 4
    f4_uslugi( 1 )
  Case k == 5
    f4_uslugi( 2 )
  Case k == 6
    f4_uslugi( 3 )
  Case k == 7
    v_nulusluga()
  Case k == 8
    v_k_uslugi()
  Case k == 11
    usl1tfoms()
  Case k == 12
    usl2tfoms()
  Case k == 13
    usl3tfoms()
  Case k == 21
    usl1ffoms()
  Case k == 22
    usl_stom_ffoms()
  Case k == 23
    usl_telemedicina()
  Case k == 24
    usl_par_organ()
  Case k == 25
    usl11ffoms()
  Case k == 26
    usl12ffoms()
  Case k == 27
    usl2ffoms()
  Case k == 28
    usl6ffoms( 2 )
  Case k == 29
    usl6ffoms( 1 )
  Case k == 30
    v_implantant()
  Endcase
  If k > 0
    If k > 20
      sk2 := k -20
    Elseif k > 10
      sk1 := k -10
    Else
      sk := k
    Endif
  Endif

  Return Nil

// 26.05.23
Function f4_uslugi( reg )

  Local i, s := 'Список услуг ', mas[ 2 ], buf := save_maxrow(), ;
    n_file := cur_dir + 'uslugi' + stxt, sh := 80, HH := 60, l, k, j, lshifr, lshifr1, lname
  Local tmpAlias

  If ( j := f_alert( { 'Необходим вывод списка отделений,', ;
      'в которых разрешается ввод услуги?', ;
      '' }, ;
      { ' ~Нет ', ' ~Да ' }, ;
      1, 'N+/BG', 'R/BG', 17, , col1menu ) ) == 0
    Return Nil
  Endif
  mywait()
  Do Case
  Case reg == 1
    s += 'с ценами по ОМС'
  Case reg == 2
    s := 'Список платных услуг'
  Case reg == 3
    s += 'с ценами по ДМС'
  Endcase
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( '' )
  add_string( Center( s, sh ) )
  add_string( '' )
  If mem_trudoem == 2
    Private arr_title := { Space( sh -15 ) + 'УЕТ ' + iif( is_oplata == 7, 'вр.', 'взр' ) + '│УЕТ ' + iif( is_oplata == 7, 'асс', 'дет' ), ;
      Space( sh -15 ) + '───────┴───────' }
    AEval( arr_title, {| x| add_string( x ) } )
    useuch_usl()
    l := sh -16
  Else
    l := sh
  Endif
  use_base( 'lusl' )
  use_base( 'luslc' )
  r_use( dir_server + 'mo_uch', , 'LPU' )
  r_use( dir_server + 'mo_otd', , 'OTD' )
  r_use( dir_server + 'usl_otd', dir_server + 'usl_otd', 'UO' )
  r_use( dir_server + 'uslugi',, 'USL' )
  Index On iif( kod > 0, '1', '0' ) + fsort_usl( shifr ) to ( cur_dir + 'tmp_usl' )
  Go Top
  Do While !Eof()
    lshifr := ''
    If !Empty( usl->shifr )
      s := usl->shifr
      lname := AllTrim( usl->name )
      lshifr += AllTrim( usl->shifr )
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod )
      If reg == 1 .and. !Empty( lshifr1 ) .and. !( usl->shifr == lshifr1 )
        s := lshifr1
        lshifr += '(' + AllTrim( lshifr1 ) + ')'
      Endif
      lshifr += '.'
      // if usl->zf == 1
      // lshifr += " [ЗФ] "
      // endif
      s := f42_uslugi( reg, s )
      If !Empty( s )
        If mem_trudoem == 2
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
        Else
          verify_ff( HH, .t., sh )
        Endif
        If Empty( lshifr1 ) .or. lshifr1 == usl->shifr
          Select LUSL
          find ( usl->shifr )
          If Found()
            lname := AllTrim( lusl->name )
          Endif
          // else
          // select LUSL19
          // find (usl->shifr)
          // if found()
          // lname := alltrim(lusl19->name)
          // else
          // select LUSL18
          // find (usl->shifr)
          // if found()
          // lname := alltrim(lusl18->name)
          // endif
          // endif
          // endif
        Endif
        k := perenos( mas, lshifr + lname + ' [' + s + ']', l, ' , ;' )
        s := PadR( mas[ 1 ], l )
        If mem_trudoem == 2
          Select UU
          find ( Str( usl->kod, 4 ) )
          If is_oplata == 7
            s += put_val_0( uu->vkoef_v, 8, 4 ) + put_val_0( uu->akoef_v, 8, 4 )
          Else
            s += put_val_0( uu->koef_v, 8, 4 ) + put_val_0( uu->koef_r, 8, 4 )
          Endif
        Endif
        add_string( s )
        For i := 2 To k
          add_string( PadL( AllTrim( mas[ i ] ), l ) )
        Next
        If j == 2
          Select UO
          find ( Str( usl->kod, 4 ) )
          If Found()
            k := 1
            Do While !( SubStr( uo->otdel, k, 1 ) == Chr( 0 ) )
              otd->( dbGoto( Asc( SubStr( uo->otdel, k, 1 ) ) ) )
              lpu->( dbGoto( otd->kod_lpu ) )
              add_string( Space( 18 ) + '= ' + AllTrim( otd->name ) + ' [' + AllTrim( lpu->name ) + ']' )
              ++k
            Enddo
          Endif
        Endif
      Endif
    Endif
    Select USL
    Skip
  Enddo
  Close databases
  FClose( fp )
  viewtext( n_file, , , , , , , 2 )

  Return Nil

//
Function f42_uslugi( reg, _shifr )

  Local s := "", v1, v2, fl1del, fl2del

  If reg == 1
    Select LUSL
    find ( _shifr )
    If Found()
      v1 := fcena_oms( lusl->shifr, .t., sys1_date, @fl1del )
      v2 := fcena_oms( lusl->shifr, .f., sys1_date, @fl2del )
      If fl1del .and. fl2del
        s += "удалена ТФОМС"
      Else
        s += "Ц=" + dellastnul( v1 ) + ";ЦД=" + dellastnul( v2 )
      Endif
    Elseif !emptyall( usl->cena, usl->cena_d )
      s += "Ц=" + dellastnul( usl->cena ) + ";ЦД=" + dellastnul( usl->cena_d )
    Endif
  Endif
  // для платных услуг
  If eq_any( reg, 2, 3, 23 )
    If eq_any( reg, 2, 23 ) .and. !emptyall( usl->pcena, usl->pcena_d )
      s += "ПлЦ=" + dellastnul( usl->pcena )
      If !Empty( usl->pnds )
        s += "(НДС=" + dellastnul( usl->pnds ) + ")"
      Endif
      s += ";ПлЦД=" + dellastnul( usl->pcena_d )
      If !Empty( usl->pnds_d )
        s += "(НДС=" + dellastnul( usl->pnds_d ) + ")"
      Endif
    Endif
    If eq_any( reg, 3, 23 ) .and. !Empty( usl->dms_cena )
      If !Empty( s )
        s += ";"
      Endif
      s += "ДМС=" + dellastnul( usl->dms_cena )
    Endif
  Endif

  Return s


// 26.05.23
Function v_1usluga()

  Local arr_usl, atf := { 0, '', '' }, i := 1, k, mas[ 2 ], sh := 80, HH := 60, j := 0, j1, ;
    sb, fl, lshifr, s, n_file := cur_dir + 'usluga_1' + stxt
  Local prefix := prefixfilerefname( WORK_YEAR )

  If ( arr_usl := input_usluga( atf ) ) != NIL
    mywait()
    fp := FCreate( n_file )
    n_list := 1
    tek_stroke := 0

    r_use( dir_exe + prefix + 'dep', cur_dir + prefix + 'dep', 'DEP' )
    use_base( 'lusl' )
    use_base( 'luslc' )
    r_use( dir_server + 'uslugi', dir_server + 'uslugi', 'USL' )
    add_string( '' )
    add_string( Center( 'ПРОСМОТР УСЛУГИ', sh ) )
    add_string( '' )
    add_string( Center( '(по нашему справочнику)', sh ) )
    add_string( '' )
    If arr_usl[ 1 ] == 0
      add_string( 'НЕ НАЙДЕНА!' )
    Else
      Select USL
      find ( Str( arr_usl[ 1 ], 4 ) )
      lshifr := ''
      If !Empty( usl->shifr )
        s := usl->shifr
        lshifr += AllTrim( usl->shifr )
        lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod )
        If !Empty( lshifr1 ) .and. !( usl->shifr == lshifr1 )
          lshifr += '(' + AllTrim( lshifr1 ) + ')'
          s := lshifr1
        Endif
        lshifr += '.'
      Endif
      k := perenos( mas, lshifr + ' ' + AllTrim( usl->name ) + ' [' + f42_uslugi( 1, s ) + ']', sh, ' , ;' )
      add_string( mas[ 1 ] )
      If k > 1
        add_string( PadL( AllTrim( mas[ 2 ] ), sh ) )
      Endif
      If !emptyall( usl->pcena, usl->pcena_d, usl->dms_cena )
        add_string( '' )
        add_string( Space( 2 ) + '* Цена платной услуги' + ' [' + f42_uslugi( 23 ) + ']' )
      Endif
      If mem_trudoem == 2
        useuch_usl()
        Select UU
        find ( Str( arr_usl[ 1 ], 4 ) )
        add_string( '' )
        If is_oplata == 7
          If !emptyall( uu->koef_v, uu->vkoef_v, uu->akoef_v )
            s := '  УЕТ для взрослых ' + str_0( uu->koef_v, 7, 4 ) + ;
              ' [врач ' + AllTrim( str_0( uu->vkoef_v, 7, 4 ) ) + ', асс. ' + AllTrim( str_0( uu->akoef_v, 7, 4 ) ) + ']'
            add_string( s )
          Endif
          If !emptyall( uu->koef_r, uu->vkoef_r, uu->akoef_r )
            s := '  УЕТ для детей    ' + str_0( uu->koef_r, 7, 4 ) + ;
              ' [врач ' + AllTrim( str_0( uu->vkoef_r, 7, 4 ) ) + ', асс. ' + AllTrim( str_0( uu->akoef_r, 7, 4 ) ) + ']'
            add_string( s )
          Endif
        Else
          If !Empty( uu->koef_v )
            add_string( '  УЕТ для взрослых ' + str_0( uu->koef_v, 7, 4 ) )
          Endif
          If !Empty( uu->koef_r )
            add_string( '  УЕТ для детей    ' + str_0( uu->koef_r, 7, 4 ) )
          Endif
        Endif
      Endif
    Endif
    add_string( '' )
    add_string( Replicate( '-', sh ) )
    add_string( '' )
    add_string( Center( '(по справочнику ТФОМС)', sh ) )
    add_string( '' )
    If atf[ 1 ] == 0
      add_string( 'НЕ НАЙДЕНА!' )
    Else
      k := perenos( mas, atf[ 2 ], sh )
      add_string( mas[ 1 ] )
      For i := 2 To k
        add_string( PadL( AllTrim( mas[ i ] ), sh ) )
      Next
      Select LUSLC
      Set Order To 1
      find ( atf[ 3 ] )
      Do While luslc->shifr == atf[ 3 ] .and. !Eof()
        s := Space( 2 ) + 'c ' + date_8( luslc->datebeg ) + ' по ' + date_8( luslc->dateend ) + ': ЦЕНА ' + ;
          iif( luslc->VZROS_REB == 0, 'взрослая=', 'детская =' ) + dellastnul( luslc->cena )
        If is_otd_dep .and. luslc->depart > 0
          Select DEP
          find ( Str( luslc->depart, 3 ) )
          If Found()
            s += '  (' + AllTrim( dep->name_short ) + ')'
          Endif
        Endif
        verify_ff( HH )
        add_string( s )
        Select LUSLC
        Skip
      Enddo
    Endif
    Close databases
    FClose( fp )
    viewtext( n_file, , , , , , , 2 )
  Endif

  Return Nil


// 08.02.23
Function v_k_uslugi()

  Local sh := 80, HH := 57, n_file := cur_dir + 'k_uslugi' + stxt

  mywait()
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( '' )
  add_string( Center( 'КОМПЛЕКСНЫЕ УСЛУГИ', sh ) )
  add_string( '' )
  r_use( dir_server + 'uslugi', dir_server + 'uslugish', 'USL' )
  r_use( dir_server + 'uslugi1k', dir_server + 'uslugi1k', 'U1K' )
  Set Relation To shifr1 into USL
  r_use( dir_server + 'uslugi_k', dir_server + 'uslugi_k', 'UK' )
  Go Top
  Do While !Eof()
    verify_ff( HH -3, .t., sh )
    add_string( '' )
    add_string( uk->shifr + ' ' + RTrim( uk->name ) )
    Select U1K
    find ( uk->shifr )
    Do While u1k->shifr == uk->shifr .and. !Eof()
      verify_ff( HH, .t., sh )
      add_string( '   ' + u1k->shifr1 + ' ' + RTrim( usl->name ) )
      Skip
    Enddo
    Select UK
    Skip
  Enddo
  Close databases
  FClose( fp )
  viewtext( n_file, , , , , , , 2 )

  Return Nil

// 31.01.23
Function v_implantant()

  Local vrem_local := '', k, l, s, i, ss, sh := 80, HH := 57, n_file := cur_dir + 'implant' + stxt
  Local mas[ 2 ]
  Local arrImplantant := get_implantant()

  mywait()
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( '' )
  add_string( Center( 'Имплантируемые материалы', sh ) )
  add_string( '' )
  l := sh
  ASort( arrImplantant, , , {| x, y| ( PadR( x[ 7 ], 75 ) + x[ 1 ] ) < ( PadR( y[ 7 ], 75 ) + y[ 1 ] ) } )
  // vrem_local := arrImplantant[1, 7]
  // if len(alltrim(vrem_local)) < 2
  // add_string(center('Без группы', sh))
  // else
  // add_string(center(vrem_local, sh))
  // endif
  For i := 1 To Len( arrImplantant )
    // if vrem_local != arrImplantant[i, 7]
    // if verify_FF(HH, .t., sh)
    // endif
    // vrem_local := arrImplantant[i, 7]
    // add_string('')
    // add_string(center(vrem_local, sh))
    // add_string('')
    // endif
    If verify_ff( HH, .t., sh )
    Endif
    k := perenos( mas, AllTrim( arrImplantant[ i, 1 ] ), l, ' , ;' )
    s := PadR( mas[ 1 ], l )
    add_string( s )
    If k > 1
      add_string( PadL( AllTrim( mas[ 2 ] ), l ) )
    Endif
  Next
  FClose( fp )
  viewtext( n_file, , , , , , , 2 )

  Return Nil



// 08.02.23
Function v_nulusluga()

  Local mas[ 2 ], k, l, s, sh := 80, HH := 57, n_file := cur_dir + 'n_uslugi' + stxt

  mywait()
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( '' )
  add_string( Center( 'УСЛУГИ, для которых разрешается ввод нулевой цены', sh ) )
  If mem_trudoem == 2
    Private arr_title := { Space( sh -15 ) + 'УЕТ ' + iif( is_oplata == 7, 'вр.', 'взр' ) + '│УЕТ ' + iif( is_oplata == 7, 'асс', 'дет' ), ;
      Space( sh -15 ) + '───────┴───────' }
    AEval( arr_title, {| x| add_string( x ) } )
    useuch_usl()
    l := sh -16
  Else
    l := sh
  Endif
  r_use( dir_server + 'uslugi', , 'USL' )
  For i := 1 To 2
    add_string( '' )
    add_string( Center( iif( i == 1, '[ ОМС ]', '[ Платные услуги ]' ), sh ) )
    add_string( '' )
    Index On iif( kod > 0, '1', '0' ) + fsort_usl( shifr ) to ( cur_dir + 'tmp_usl' ) ;
      For !Empty( shifr ) .and. iif( i == 1, is_nul, is_nulp )
    Go Top
    Do While !Eof()
      If mem_trudoem == 2
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
      Else
        verify_ff( HH, .t., sh )
      Endif
      s := RTrim( usl->shifr ) + ' '
      // if usl->zf == 1
      // s += '[ЗФ] '
      // endif
      k := perenos( mas, s + AllTrim( usl->name ), l, ' , ;' )
      s := PadR( mas[ 1 ], l )
      If mem_trudoem == 2
        Select UU
        find ( Str( usl->kod, 4 ) )
        If is_oplata == 7
          s += put_val_0( uu->vkoef_v, 8, 4 ) + put_val_0( uu->akoef_v, 8, 4 )
        Else
          s += put_val_0( uu->koef_v, 8, 4 ) + put_val_0( uu->koef_r, 8, 4 )
        Endif
      Endif
      add_string( s )
      If k > 1
        add_string( PadL( AllTrim( mas[ 2 ] ), l ) )
      Endif
      Select USL
      Skip
    Enddo
  Next
  Close databases
  FClose( fp )
  viewtext( n_file, , , , , , , 2 )

  Return Nil

// 30.05.23 даты смены цен
Function usl1tfoms()

  Local k, buf := save_maxrow(), name_file := cur_dir + 'uslugi' + stxt, sh := 80, HH := 60, ;
    i, s, fl, v1, v2, mdate, pole, nu, t_arr[ BR_LEN ], ret, ret_arr, scode, dy
  Local sbase, tmpAlias

  mywait()
  dbCreate( cur_dir + 'tmp', { { 'ibeg', 'N', 1, 0 }, { 'iend', 'N', 1, 0 }, { 'data', 'D', 8, 0 } } )
  Use ( cur_dir + 'tmp' ) new
  Index On DToS( data ) to ( cur_dir + 'tmp' )
  use_base( 'luslc' )

  For i := 2018 To WORK_YEAR
    tmpAlias := create_name_alias( 'LUSLC', i )
    If ! ( tmpAlias )->( Used() )
      Loop
    Endif
    Select ( tmpAlias )
    Index On datebeg to ( cur_dir + 'tmp_' + tmpAlias ) For !Empty( datebeg ) .and. codemo == glob_mo[ _MO_KOD_TFOMS ] unique
    Go Top
    Do While !Eof()
      Select TMP
      Append Blank
      tmp->ibeg := 1
      tmp->data := ( tmpAliAs )->datebeg
      Select ( tmpAliAs )
      Skip
    Enddo
    Select ( tmpAlias )
    Index On dateend to ( cur_dir + 'tmp_' + tmpAlias ) For !Empty( dateend ) .and. codemo == glob_mo[ _MO_KOD_TFOMS ] unique
    Go Top
    Do While !Eof()
      Select TMP
      find ( DToS( ( tmpAlias )->dateend ) )
      If !Found()
        Append Blank
        tmp->data := ( tmpAlias )->dateend
      Endif
      tmp->iend := 1
      Select ( tmpAlias )
      Skip
    Enddo
  Next
  Close databases

  rest_box( buf )
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL -5
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 26
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_COLUMN ] := { { 'Даты смены;   цен', {|| iif( tmp->ibeg == 1, full_date( tmp->data ), Space( 10 ) ) } }, ;
    { 'Окончание; действия;  услуг', {|| iif( tmp->iend == 1, full_date( tmp->data ), Space( 10 ) ) } } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор' ) }
  t_arr[ BR_ENTER ] := {|| ret := { tmp->data, tmp->ibeg, tmp->iend } }
  Use ( cur_dir + 'tmp' ) index ( cur_dir + 'tmp' ) new
  Keyboard Chr( K_END )
  edit_browse( t_arr )
  Close databases

  If ret != NIL
    mdate := ret[ 1 ]
    dy := Year( mdate )
    scode := glob_mo[ _MO_KOD_TFOMS ]
    mywait()
    dbCreate( cur_dir + 'tmp1', { { 'shifr',   'C', 10, 0 }, ;
      { 'flv',     'L', 1, 0 }, ;
      { 'fld',     'L', 1, 0 }, ;
      { 'depart',  'N', 3, 0 }, ;
      { 'cenav',   'N', 10, 2 }, ;
      { 'cenad',   'N', 10, 2 } } )

    sbase := prefixfilerefname( dy ) + 'dep'
    r_use( dir_exe + sbase, cur_dir + sbase, 'DEP' )

    Use ( cur_dir + 'tmp1' ) new
    Index On shifr + Str( depart, 3 ) to ( cur_dir + 'tmp1' )
    fp := FCreate( name_file )
    n_list := 1
    tek_stroke := 0
    add_string( glob_mo[ _MO_SHORT_NAME ] + iif( ValType( ret_arr ) == 'A', ' (' + ret_arr[ 2 ] + ' - ' + ret_arr[ 1 ] + ')', '' ) )
    If ret[ 2 ] == 1
      add_string( '' )
      add_string( Center( 'Список цен на услуги', sh ) )
      add_string( Center( '[ цены установлены ' + date_8( mdate ) + 'г. ]', sh ) )
      add_string( '' )
      use_base( 'luslc' )
      tmpAlias := create_name_alias( 'LUSLC', dy )
      Select ( tmpAlias )
      // set order to 2 // работаем с собственными ценами
      // find (scode)
      // do while (tmpAlias)->CODEMO == scode .and. !eof()
      Go Top
      Do While !Eof()
        If ( tmpAlias )->datebeg == mdate
          Select TMP1
          find ( ( tmpAlias )->shifr + Str( ( tmpAlias )->depart, 3 ) )
          If !Found()
            Append Blank
            tmp1->shifr := ( tmpAlias )->shifr
            tmp1->depart := ( tmpAlias )->depart
          Endif
          If ( tmpAlias )->VZROS_REB == 0
            tmp1->flv := .t.
            tmp1->cenav := ( tmpAlias )->CENA
          Else
            tmp1->fld := .t.
            tmp1->cenad := ( tmpAlias )->CENA
          Endif
        Endif
        Select ( tmpAlias )
        Skip
      Enddo

      use_base( 'lusl' )
      lal := 'lusl'
      Select TMP1

      lal := create_name_alias( lal, dy )
      Set Relation To shifr into ( lal )

      Index On fsort_usl( shifr ) to ( cur_dir + 'tmp1' )
      Go Top
      old := Space( 10 )
      Do While !Eof()
        n := iif( Empty( tmp1->depart ), 50, 70 )
        k := perenos( t_arr, if( Len( AllTrim( tmp1->shifr ) ) == 10, ' ', '' ) + &lal.->name, n )
        If Empty( tmp1->depart )
          s := tmp1->shifr + PadR( t_arr[ 1 ], n )
          If emptyall( tmp1->cenav, tmp1->cenad )
            s += iif( tmp1->flv, put_kop( tmp1->cenav, 10 ), Space( 10 ) )
            s += iif( tmp1->fld, put_kop( tmp1->cenad, 10 ), Space( 10 ) )
          Else
            s += put_kope( tmp1->cenav, 10 ) + put_kope( tmp1->cenad, 10 )
          Endif
          verify_ff( HH - k, .t., sh )
          add_string( s )
          For i := 2 To k
            add_string( Space( 10 ) + t_arr[ i ] )
          Next
        Endif
        If !Empty( tmp1->depart )
          If !( old == tmp1->shifr )
            verify_ff( HH - k -1, .t., sh )
            For i := 1 To k
              add_string( iif( i == 1, tmp1->shifr, Space( 10 ) ) + t_arr[ i ] )
            Next
          Endif
          Select DEP
          find ( Str( tmp1->depart, 3 ) )
          If Found()
            s := PadL( AllTrim( dep->name_short ), 60 )
            s += put_kope( tmp1->cenav, 10 ) + put_kope( tmp1->cenad, 10 )
            verify_ff( HH, .t., sh )
            add_string( s )
          Endif
        Endif
        old := tmp1->shifr
        Select TMP1
        Skip
      Enddo
    Endif
    If ret[ 3 ] == 1
      add_string( '' )
      add_string( Center( 'Список услуг, закончивших действие', sh ) )
      add_string( Center( date_month( mdate, .t. ), sh ) )
      add_string( '' )
      use_base( 'luslc' )
      tmpAlias := create_name_alias( 'LUSLC', dy )
      Select ( tmpAlias )
      // set order to 2 // работаем с собственными ценами
      // find (scode)
      // do while (tmpAlias)->CODEMO == scode .and. !eof()
      Go Top
      Do While !Eof()
        If !Empty( ( tmpAlias )->dateend ) .and. ( tmpAlias )->dateend == mdate
          Select TMP1
          find ( ( tmpAlias )->shifr + Str( ( tmpAlias )->depart, 3 ) )
          If !Found()
            Append Blank
            tmp1->shifr := ( tmpAlias )->shifr
            tmp1->depart := ( tmpAlias )->depart
          Endif
          If luslc->VZROS_REB == 0
            tmp1->flv := .t.
            tmp1->cenav := ( tmpAlias )->CENA
          Else
            tmp1->fld := .t.
            tmp1->cenad := ( tmpAlias )->CENA
          Endif
        Endif
        Select ( tmpAlias )
        Skip
      Enddo

      use_base( 'lusl' )
      lal := 'lusl'
      Select TMP1
      lal := create_name_alias( lal, dy )
      Set Relation To shifr into ( lal )

      Index On fsort_usl( shifr ) to ( cur_dir + 'tmp1' )
      Go Top
      old := Space( 10 )
      Do While !Eof()
        n := iif( Empty( tmp1->depart ), 50, 70 )
        k := perenos( t_arr, &lal.->name, n )
        If Empty( tmp1->depart )
          s := tmp1->shifr + PadR( t_arr[ 1 ], n )
          If emptyall( tmp1->cenav, tmp1->cenad )
            s += iif( tmp1->flv, put_kop( tmp1->cenav, 10 ), Space( 10 ) )
            s += iif( tmp1->fld, put_kop( tmp1->cenad, 10 ), Space( 10 ) )
          Else
            s += put_kope( tmp1->cenav, 10 ) + put_kope( tmp1->cenad, 10 )
          Endif
          verify_ff( HH - k, .t., sh )
          add_string( s )
          For i := 2 To k
            add_string( Space( 10 ) + t_arr[ i ] )
          Next
        Endif
        If !Empty( tmp1->depart )
          If !( old == tmp1->shifr )
            verify_ff( HH - k -1, .t., sh )
            For i := 1 To k
              add_string( iif( i == 1, tmp1->shifr, Space( 10 ) ) + t_arr[ i ] )
            Next
          Endif
          Select DEP
          find ( Str( tmp1->depart, 3 ) )
          If Found()
            s := PadL( AllTrim( dep->name_short ), 60 )
            s += put_kope( tmp1->cenav, 10 ) + put_kope( tmp1->cenad, 10 )
            verify_ff( HH, .t., sh )
            add_string( s )
          Endif
        Endif
        old := tmp1->shifr
        Select TMP1
        Skip
      Enddo
    Endif
    Close databases
    rest_box( buf )
    FClose( fp )
    viewtext( name_file, , , , .t., , , 2 )
  Endif

  Return Nil

// 15.01.18
Function ret_otd_dep()

  Local ret_arr

  If !( ValType( glob_otd_dep ) == "N" )
    glob_otd_dep := 0
  Endif
  popup_2array( mm_otd_dep, T_ROW, T_COL - 5, glob_otd_dep, 1, @ret_arr, "Выбор отделения стационара", "B/BG" )
  If ValType( ret_arr ) == "A"
    glob_otd_dep := ret_arr[ 2 ]
  Endif

  Return ret_arr

// 07.08.17
Function f_spr_usl_adres_podr()

  Static arr := {}
  Local i, j, ret_arr

  If ( i := AScan( glob_adres_podr, {| x| x[ 1 ] == glob_mo[ _MO_KOD_TFOMS ] } ) ) > 0
    If Empty( arr )
      For j := 1 To Len( glob_adres_podr[ i, 2 ] )
        AAdd( arr, { glob_adres_podr[ i, 2, j, 3 ], glob_adres_podr[ i, 2, j, 1 ] } )
      Next
    Endif
    popup_2array( arr, T_ROW, T_COL - 5, glob_podr, 1, @ret_arr, "Адрес удалённого подразделения", "B/BG" )
    If ValType( ret_arr ) == "A"
      glob_podr := ret_arr[ 2 ]
    Endif
  Endif
  If Empty( ret_arr )
    glob_podr := glob_mo[ _MO_KOD_TFOMS ] // по умолчанию
  Endif

  Return ret_arr

// 16.06.23
Function usl2tfoms()

  Static sdate
  Local k, buf := save_maxrow(), name_file := cur_dir + 'uslugi' + stxt, nu, ret_arr, ;
    sh := 80, HH := 60, t_arr, i, s, fl, v1, v2, mdate, fl1uslc, fl2uslc, ;
    ta[ 2 ], lyear, fl1del, fl2del, len_ksg := 10
  Local arrKSLP, rowKSLP, tmpKSLP, arrKIRO, rowKIRO, tmpKIRO
  Local sbase

  Default sdate To sys1_date
  mdate := input_value( 20, 5, 22, 73, color1, ;
    'Дата, по состоянию на которую выводятся цены на услуги', ;
    sdate )
  If mdate == NIL
    Return Nil
  Endif
  If ( lyear := Year( mdate ) ) < 2018
    Return func_error( 4, 'Вы запрашиваете слишком старую информацию' )
  Endif
  If lyear > WORK_YEAR
    Return func_error( 4, 'Информация на будуюшую дату отсутствует' )
  Endif
  sdate := mdate
  If ( k := popup_2array( usl9tfoms( mdate ), T_ROW, T_COL -5, su, 1, @t_arr, 'Выберите группу услуг', 'B/BG', color0 ) ) > 0
    glob_podr := ''
    If is_otd_dep .and. t_arr[ 2 ] == 501 .and. ! disable_podrazdelenie_tfoms( mdate )
      If ( ret_arr := ret_otd_dep() ) == NIL
        Return Nil
      Endif
    Else
      glob_otd_dep := 0
    Endif
    mywait()
    su := k
    fp := FCreate( name_file )
    n_list := 1
    tek_stroke := 0
    nu := get_uroven( mdate )
    /*if between(nu, 1, 3)
      s := "Уровень цен на мед.услуги: "+lstr(nu)
    else
      s := "Индивидуальные тарифы на мед.услуги"
    endif*/
    add_string( glob_mo[ _MO_SHORT_NAME ] + iif( ValType( ret_arr ) == 'A', ' (' + ret_arr[ 1 ] + ')', '' ) )
    add_string( '' )
    add_string( Center( 'Список услуг по группе', sh ) )
    add_string( Center( '"' + AllTrim( t_arr[ 1 ] ) + '"', sh ) )
    add_string( Center( '[ цены по состоянию на ' + date_8( mdate ) + 'г. ]', sh ) )
    add_string( '' )
    If t_arr[ 2 ] > 500
      arrKSLP := getkslptable( mdate )
      add_string( 'КСЛП:' )
      For Each rowKSLP in arrKSLP
        k := perenos( ta, AllTrim( rowKSLP[ 3 ] ), 58 )
        For i := 1 To k
          If i == 1
            tmpKSLP := Str( rowKSLP[ 1 ], 7 ) + ' - ' + ta[ i ] + ' (коеф=' + Str( rowKSLP[ 4 ], 4, 2 ) + ')'
          Else
            tmpKSLP := Space( 10 ) + ta[ i ]
          Endif
          add_string( tmpKSLP )
        Next
      Next
      arrKIRO := getkirotable( mdate )
      add_string( 'КИРО:' )
      For Each rowKIRO in arrKIRO
        If between_date( rowKIRO[ 5 ], rowKIRO[ 6 ], mdate )
          k := perenos( ta, AllTrim( rowKIRO[ 3 ] ), 58 )
          For i := 1 To k
            If i == 1
              tmpKIRO := Str( rowKIRO[ 1 ], 7 ) + ' - ' + ta[ i ] + ' (коеф=' + Str( rowKIRO[ 4 ], 4, 2 ) + ')'
            Else
              tmpKIRO := Space( 10 ) + ta[ i ]
            Endif
            add_string( tmpKIRO )
          Next
        Endif
      Next

      sbase := prefixfilerefname( lyear ) + 'k006'
      r_use( dir_exe + sbase, , 'K006' )

      Index On SHIFR + Str( ns, 6 ) to ( cur_dir + 'tmp_k006' ) unique
      Index On SHIFR + Str( ns, 6 ) + ds + sy to ( cur_dir + 'tmp_k006_' )
      Set Index to ( cur_dir + 'tmp_k006' ), ( cur_dir + 'tmp_k006_' )
    Endif
    use_base( 'luslc' )
    use_base( 'lusl' )
    lal := 'lusl'
    lal := create_name_alias( lal, lyear )

    dbSelectArea( lal )
    If t_arr[ 2 ] > 500
      Index On fsort_usl( shifr ) to ( cur_dir + 'tmplu' ) For is_ksg( shifr, t_arr[ 2 ] -500 ) .and. datebeg >= BoY( mdate )
    Else
      Index On fsort_usl( shifr ) to ( cur_dir + 'tmp' ) For usl2arr( shifr )[ 1 ] == k .and. !is_ksg( shifr )
    Endif
    Go Top
    Do While !Eof()
      v1 := fcena_oms( &lal.->shifr, .t., mdate, @fl1del, @fl1uslc )
      v2 := fcena_oms( &lal.->shifr, .f., mdate, @fl2del, @fl2uslc )
      If !( fl1del .and. fl2del )
        s := AllTrim( &lal.->name )
        If Len( AllTrim( &lal.->shifr ) ) == 10
          s := ' ' + s
        Endif
        k := perenos( ta, s, 50 )
        verify_ff( HH - k -1, .t., sh )
        If t_arr[ 2 ] > 100
          add_string( Replicate( '─', sh ) )
        Endif
        add_string( &lal.->shifr + ta[ 1 ] + ;
          iif( fl1del, '      -   ', put_kop( v1, 10 ) ) + ;
          iif( fl2del, '      -   ', put_kop( v2, 10 ) ) )
        s := Space( 10 ) + PadR( ta[ 2 ], 50 )
        If !Empty( s )
          add_string( s )
        Endif
        For i := 3 To k
          add_string( Space( 10 ) + ta[ i ] )
        Next
        If t_arr[ 2 ] > 500
          Select K006
          Set Order To 1
          find ( PadR( &lal.->shifr, len_ksg ) )
          s1 := f_ret_kz_ksg( k006->kz, &lal.->kslps, &lal.->kiros )
          add_string( Space( 10 ) + s1 )
          Do While PadR( &lal.->shifr, len_ksg ) == k006->shifr .and. !Eof()
            If between_date( k006->DATEBEG, k006->DATEEND, mdate )
              lrec := k006->( RecNo() )
              lns := k006->ns
              i := 0
              s := s1 := ''
              Set Order To 2
              find ( PadR( &lal.->shifr, len_ksg ) + Str( lns, 6 ) )
              Do While PadR( &lal.->shifr, len_ksg ) == k006->shifr .and. lns == k006->ns .and. !Eof()
                If !Empty( k006->DS )
                  s1 += AllTrim( k006->DS ) + ' '
                Endif
                If++i == 1
                  If !Empty( k006->DS1 )
                    s += 'СОПУТ.Диагноз ' + AllTrim( k006->DS1 ) + '; '
                  Endif
                  If !Empty( k006->DS2 )
                    s += 'Диагноз ОСЛОЖНЕНИЯ ' + AllTrim( k006->DS2 ) + '; '
                  Endif
                  If !Empty( k006->SY )
                    s += 'УСЛУГА ' + AllTrim( k006->sy ) + '; '
                  Endif
                  If !Empty( k006->AGE )
                    s += 'ВОЗРАСТ ' + ret_vozrast_k006( k006->AGE ) + '; '
                  Endif
                  If !Empty( k006->SEX )
                    s += 'ПОЛ ' + iif( k006->SEX == '1', 'мужской', 'женский' ) + '; '
                  Endif
                  If !Empty( k006->LOS )
                    s += ret_duration_k006( k006->LOS, iif( Left( &lal.->shifr, 1 ) == '1', 'койко', 'пациенто' ) + '-' ) + '; '
                  Endif
                  If k006->( FieldPos( 'RSLT' ) ) > 0 .and. !Empty( k006->RSLT )
                    s += 'РЕЗУЛЬТАТ ' + AllTrim( k006->RSLT ) + '; '
                  Endif
                  If k006->( FieldPos( 'AD_CR' ) ) > 0 .and. !Empty( k006->AD_CR )
                    s += 'ДОП.КРИТЕРИЙ ' + AllTrim( k006->AD_CR ) + '; '
                  Endif
                  If k006->( FieldPos( 'AD_CR1' ) ) > 0 .and. !Empty( k006->AD_CR1 )
                    s += 'ИНОЙ КРИТЕРИЙ ' + AllTrim( k006->AD_CR1 ) + '; '
                  Endif
                Endif
                Skip
              Enddo
              If !Empty( s1 )
                s1 := 'ОСН.Диагноз ' + Left( s1, Len( s1 ) -1 ) + '; '
              Endif
              s := s1 + s
              s := Left( s, Len( s ) -2 )
              k := perenos( ta, s, 70 )
              For i := 1 To k
                verify_ff( HH, .t., sh )
                add_string( iif( i == 1, Space( 8 ) + '- ', Space( 10 ) ) + ta[ i ] )
              Next
              Select K006
              Goto ( lrec )
              Set Order To 1
            Endif
            Skip
          Enddo
        Endif
      Endif
      dbSelectArea( lal )
      Skip
    Enddo
    Close databases
    rest_box( buf )
    FClose( fp )
    viewtext( name_file, , , , .t., , , 2 )
  Endif

  Return Nil

// 08.12.21
Function ret_vozrast_k006( s )

  Local ret := ""

  Do Case
  Case s == '1'
    ret := "0-28 дней"
  Case s == '2'
    ret := "29-90 дней"
  Case s == '3'
    ret := "от 91 дня до 1 года"
  Case s == '4'
    ret := "до 2 лет включительно"
  Case s == '5'
    ret := "ребёнок"
  Case s == '6'
    ret := "взрослый"
  Endcase

  Return ret

// 08.12.21
Function ret_duration_k006( s, s1 )

  Static sd := "день", sdr := "дня", sdm := "дней"
  Local arr := { "1-3 " + s1 + sdr, ;                   // 1
    "4 " + s1 + sdr + " и более", ;          // 2
    "1-6 " + s1 + sdm, ;                     // 3
    "7 " + s1 + sdm + " и более", ;          // 4
    "21 " + s1 + sd + " и более", ;          // 5
    "1-20 " + s1 + sdm, ;                    // 6
    "1 " + s1 + sd, ;                        // 7
    "4-7 " + s1 + sdm, ;                     // 8
    "8-10 " + s1 + sdm, ;                    // 9
    "11 " + s1 + sdm + " и более" }          // 10
  Local i := Int( Val( s ) )

  Return "дл-ть " + iif( Between( i, 1, 10 ), arr[ i ], "" )

// 08.02.23
Function f_ret_kz_ksg( lkz, lkslp, lkiro )

  Local s := 'коэф-т затратоёмкости ' + lstr( lkz, 5, 2 )

  If !Empty( lkslp )
    s += '; КСЛП: ' + AllTrim( lkslp )
  Endif
  If !Empty( lkiro )
    s += '; КИРО: ' + AllTrim( lkiro )
  Endif

  Return s

// 08.02.23
Function usl3tfoms()

  Local i, k, buf := save_maxrow(), name_file := cur_dir + 'uslugi' + stxt, ;
    sh := 85, HH := 80, mas1[ 5 ], mas2[ 5 ], arr[ 5 ], k1, k2, t_arr, mdate, lyear

  //
  If ( mdate := input_value( 20, 5, 22, 74, color1, ;
      "Введите дату, на которую необходимо получить информацию", ;
      sys_date ) ) == NIL
    Return Nil
  Endif
  If ( lyear := Year( mdate ) ) < 2018
    Return func_error( 4, 'Вы запрашиваете слишком старую информацию' )
  Endif
  If lyear > WORK_YEAR
    Return func_error( 4, 'Информация на будуюшую дату отсутствует' )
  Endif

  If ( k := popup_2array( usl9tfoms( mdate ), T_ROW, T_COL - 5, su, 1, @t_arr, "Выберите группу услуг", "B/BG", color0 ) ) > 0
    su := k
    mywait()
    arr_title := { ;
      "──────────────────────────────────────────┬──────────────────────────────────────────", ;
      " Справочник ТФОМС                         │ Наш справочник услуг                     ", ;
      "──────────────────────────────────────────┴──────────────────────────────────────────" }
    fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( Center( "Список услуг по группе", sh ) )
    add_string( Center( '"' + AllTrim( t_arr[ 1 ] ) + '"', sh ) )
    add_string( Center( 'по состоянию на ' + date_month( mdate, .t. ), sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    dbCreate( cur_dir + "tmp", { { "shifr", "C", 10, 0 } } )
    Use ( cur_dir + "tmp" ) new
    r_use( dir_server + 'uslugi',, 'USL' )
    Go Top
    Do While !Eof()
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, mdate )
      Select TMP
      Do While tmp->( LastRec() ) < usl->( RecNo() )
        Append Blank
      Enddo
      Goto ( usl->( RecNo() ) )
      tmp->shifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
      Select USL
      Skip
    Enddo
    Select TMP
    Set Relation To RecNo() into USL
    Index On shifr + fsort_usl( usl->shifr ) to ( cur_dir + "tmp" )
    use_base( 'lusl' )
    lal := 'lusl'
    lal := create_name_alias( lal, lyear )

    dbSelectArea( lal )
    If t_arr[ 2 ] > 500
      Index On fsort_usl( shifr ) to ( cur_dir + "tmplu" ) For is_ksg( shifr, t_arr[ 2 ] -500 ) .and. datebeg >= BoY( mdate )
    Else
      Index On fsort_usl( shifr ) to ( cur_dir + "tmplu" ) For usl2arr( shifr )[ 1 ] == k .and. !is_ksg( shifr )
    Endif
    Go Top
    Do While !Eof()
      k1 := perenos( mas1, AllTrim( &lal.->shifr ) + " " + &lal.->name, 42 )
      For i := 2 To k1
        mas1[ i ] := PadL( AllTrim( mas1[ i ] ), 42 )
      Next
      mas2 := {} ; k2 := 0
      Select TMP
      find ( &lal.->shifr )
      Do while &lal.->shifr == tmp->shifr .and. !Eof()
        k := perenos( arr, AllTrim( usl->shifr ) + " " + usl->name, 42 )
        For i := 1 To k
          If i == 1
            AAdd( mas2, arr[ 1 ] )
          Else
            AAdd( mas2, PadL( AllTrim( arr[ i ] ), 42 ) )
          Endif
        Next
        k2 += k
        Select TMP
        Skip
      Enddo
      For i := 1 To Max( k1, k2 )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        s := ""
        If i <= k1
          s := mas1[ i ]
        Endif
        If i <= k2
          s := PadR( s, 43 ) + mas2[ i ]
        Endif
        add_string( s )
      Next
      add_string( Replicate( "─", sh ) )
      dbSelectArea( lal )
      Skip
    Enddo
    Close databases
    rest_box( buf )
    FClose( fp )
    viewtext( name_file,,,, .t.,,, 5 )
  Endif

  Return Nil

// 08.11.21
Function usl9tfoms( mdate )

  Static sdate, sarr1
  Local arr := { { " 1. Койко-дни по профилям", 1 }, ;
    { " 2. Врачебные приёмы по профилям", 2 }, ;
    { " 3. Процедуры и манипуляции", 3 }, ;
    { " 4. Лабораторные исследования", 4 }, ;
    { " 7. Рентгенологические исследования", 7 }, ;
    { " 8. Ультразвуковые исследования", 8 }, ;
    { "10. Эндоскопические исследования", 10 }, ;
    { "13. Электрокардиографические исследования", 13 }, ;
    { "14. Реоэнцефалография", 14 }, ;
    { "16. Прочие исследования", 16 }, ;
    { "19. Физиотерапевтическое лечение", 19 }, ;
    { "20. Лечебная физкультура", 20 }, ;
    { "21. Массаж", 21 }, ;
    { "22. Рефлексотерапия", 22 }, ;
    { "55. Дневные стационары", 55 }, ;
    { "56. Прочие услуги", 56 }, ;
    { "60. Тарифы на отдельные медицинские услуги", 60 }, ;
    { "70. Диспансеризация", 70 }, ;
    { "71. Скорая медицинская помощь", 71 }, ;
    { "72. Профилактические медицинские осмотры", 72 } }
  Local i, ls, sShifr, arr1 := {}, lyear, fl_delete := .t., fl_yes := .f., lal := 'luslc'

  If Empty( sdate ) .or. sdate != mdate
    lal := create_name_alias( lal, mdate )

    ins_array( arr, 1, { "КСГ в ДНЕВНОМ стационаре", 502 } )
    ins_array( arr, 1, { "КСГ в СТАЦИОНАРЕ", 501 } )

    use_base( 'luslc' )
    For i := 1 To Len( arr )
      If arr[ i, 2 ] > 500
        sShifr := iif( arr[ i, 2 ] == 501, "st", "ds" )
      Else
        sShifr := lstr( arr[ i, 2 ] ) + "."
      Endif
      ls := Len( sShifr )
      dbSelectArea( lal )

      Set Order To 1
      find ( sShifr )
      Do While sShifr == Left( &lal.->shifr, ls ) .and. !Eof()
        If iif( arr[ i, 2 ] > 500, is_ksg( &lal.->shifr ), .t. )
          fl_yes := .t.
          // поиск цены по дате окончания лечения
          If between_date( &lal.->datebeg, &lal.->dateend, mdate )
            fl_delete := .f. ; Exit

          Endif
        Endif
        Skip
      Enddo
      If fl_yes .and. !fl_delete
        AAdd( arr1, arr[ i ] )
      Endif
    Next
    Close databases
  Else
    arr1 := AClone( sarr1 )
  Endif
  sdate := mdate
  sarr1 := AClone( arr1 )

  Return arr1

// 08.02.23
Function usl3ffoms()

  // A,B - класс медуслуги
  // XX - раздел медуслуги
  Local arr := { ;
    "A01 функциональное обследование без использования приспособлений и/или приборов и выполняемое непосредственно медицинскими работниками (физикальные исследования, включая сбор жалоб, анамнеза, перкуссию, пальпацию и аускультацию)", ;
    "A02 функциональное обследование с использованием простых приспособлений, приборов, не требующее специальных навыков и помощи ассистента", ;
    "A03 визуальное обследование, требующее специальных приборов, навыков и помощи ассистента", ;
    "A04 регистрация звуковых сигналов, издаваемых или отражающихся органами или тканями с их последующей расшифровкой и описанием", ;
    "A05 регистрация электромагнитных сигналов, испускаемых или потенцированных в органах и тканях с их последующей расшифровкой и описанием", ;
    "A06 рентгенологические исследования с их последующим описанием и рентгенотерапия", ;
    "A07 исследования с помощью радионуклидов и методы радиационной терапии", ;
    "A08 морфологические исследования тканей", ;
    "A09 исследования биологических жидкостей, с помощью которых исследуются концентрации веществ в жидких средах организма и активность ферментативных систем", ;
    "A10 диагностические исследования, выполняемые в процессе лечения", ;
    "A11 специальные методы получения исследуемых образцов, доступа и введения", ;
    "A12 исследования функции органов или тканей с использованием специальных процедур, приспособлений и методик, не обозначенных в других рубриках, направленных на прямое исследование функции органов или тканей, - медикаментозные и физические пробы, исследование оседания эритроцитов, иммунные реакции, в том числе определение группы крови и резус-фактора, исследование системы гемостаза (за исключением уровня факторов свертывающей системы) и др.", ;
    "A13 исследования и воздействия на сознание и психическую сферу", ;
    "A14 уход за больными или отдельными анатомо-физиологическими элементами организма (ротовая полость, верхние дыхательные пути и т.д.)", ;
    "A15 десмургия, иммобилизация, бандажи, ортопедические пособия", ;
    "A16 оперативное лечение", ;
    "A17 электромагнитное лечебное воздействие на органы и ткани", ;
    "A18 экстракорпоральное воздействие на кровь и трансфузиологические пособия", ;
    "A19 лечебная физкультура, применяемая при заболеваниях определенных органов и систем", ;
    "A20 лечение климатическими воздействиями (вода, воздух и др.)", ;
    "A21 лечение с помощью простых физических воздействий на пациента (массаж, иглорефлексотерапия, мануальная терапия)", ;
    "A22 лечение с помощью лучевого (звукового, светового, ультрафиолетового, лазерного) воздействия", ;
    "A23 диагностика и лечение, не обозначенные в других рубриках", ;
    "A24 диагностика и лечение, основанные на тепловых эффектах", ;
    "A25 назначения", ;
    "A26 микробиологические исследования основных возбудителей инфекционных заболеваний", ;
    "B01 врачебная лечебно-диагностическая услуга", ;
    "B02 сестринский уход", ;
    "B03 сложная диагностическая услуга (методы исследования: лабораторный, функциональный, инструментальный, рентгенорадиологический и др.), формирующие диагностические комплексы", ;
    "B04 медицинские услуги по профилактике, такие как диспансерное наблюдение, вакцинация, медицинские физкультурно-оздоровительные мероприятия", ;
    "B05 медицинские услуги по медико-социальной реабилитации";
    }
  Local i

  For i := 1 To Len( arr )
    arr[ i ] := { arr[ i ], Left( arr[ i ], 3 ) }
  Next

  Return arr


// 18.02.23
Function usl4ffoms()

  // A - класс медуслуги
  // XX - раздел медуслуги
  // XX - подраздел медуслуги (затем "001"-группа и м.б. ".001"-подгруппа)
  Local arr := { ;
    "01 Кожа, подкожно-жировая клетчатка, придатки кожи", ;
    "02 Мышечная система",                               ;
    "03 Костная система",                                ;
    "04 Суставы",                                        ;
    "05 Система органов кроветворения и кровь",          ;
    "06 Иммунная система",                               ;
    "07 Полость рта и зубы",                             ;
    "08 Верхние дыхательные пути",                       ;
    "09 Нижние дыхательные пути и легочная ткань",       ;
    "10 Сердце и перикард",                              ;
    "11 Средостение",                                    ;
    "12 Крупные кровеносные сосуды",                     ;
    "13 Система микроциркуляции",                        ;
    "14 Печень и желчевыводящие пути",                   ;
    "15 Поджелудочная железа",                           ;
    "16 Пищевод, желудок, двенадцатиперстная кишка",     ;
    "17 Тонкая кишка",                                   ;
    "18 Толстая кишка",                                  ;
    "19 Сигмовидная и прямая кишка",                     ;
    "20 Женские половые органы",                         ;
    "21 Мужские половые органы",                         ;
    "22 Железы внутренней секреции",                     ;
    "23 Центральная нервная система и головной мозг",    ;
    "24 Периферическая нервная система",                 ;
    "25 Орган слуха",                                    ;
    "26 Орган зрения",                                   ;
    "27 Орган обоняния",                                 ;
    "28 Почки и мочевыделительная система",              ;
    "29 Психическая сфера",                              ;
    "30 Прочие"                                          ;
    }
  Local i

  For i := 1 To Len( arr )
    arr[ i ] := { arr[ i ], Left( arr[ i ], 2 ) }
  Next

  Return arr


// 08.02.23
Function usl5ffoms()

  // B - класс медуслуги
  // XX - раздел медуслуги
  // XXX - подраздел медуслуги (затем "001"-группа и м.б. ".001"-подгруппа)
  Local arr := { ;
    "001 акушерство и гинекология", ;
    "002 аллергология и иммунология", ;
    "003 анестезиология и реаниматология", ;
    "004 гастроэнтерология", ;
    "005 гематология", ;
    "006 генетика", ;
    "007 гериатрия", ;
    "008 дерматовенерология и косметология", ;
    "009 детская онкология", ;
    "010 детская хирургия", ;
    "011 детская эндокринология", ;
    "012 диабетология", ;
    "013 диетология", ;
    "014 инфекционные болезни", ;
    "015 кардиология, детская кардиология", ;
    "016 клиническая лабораторная диагностика", ;
    "017 клиническая фармакология", ;
    "018 колопроктология", ;
    "019 лабораторная генетика", ;
    "020 лечебная физкультура и спортивная медицина", ;
    "021 социальная гигиена, санитария и эпидемиология", ;
    "022 мануальная терапия", ;
    "023 неврология", ;
    "024 нейрохирургия", ;
    "025 нефрология", ;
    "026 общая врачебная практика (семейная медицина)", ;
    "027 онкология", ;
    "028 оториноларингология", ;
    "029 офтальмология", ;
    "030 патологическая анатомия", ;
    "031 педиатрия", ;
    "032 неонатология", ;
    "033 профпатология", ;
    "034 психотерапия", ;
    "035 психиатрия и судебно-психиатрическая экспертиза", ;
    "036 психиатрия-наркология", ;
    "037 пульмонология", ;
    "038 радиология и радиотерапия", ;
    "039 рентгенология", ;
    "040 ревматология", ;
    "041 рефлексотерапия", ;
    "042 сексология", ;
    "043 сердечно-сосудистая хирургия, рентгенэндоваскулярная диагностика и лечение", ;
    "044 скорая медицинская помощь", ;
    "045 судебно-медицинская экспертиза", ;
    "046 сурдология-оториноларингология", ;
    "047 терапия", ;
    "048 токсикология", ;
    "049 торакальная хирургия", ;
    "050 травматология и ортопедия", ;
    "051 трансфузиология", ;
    "052 ультразвуковая диагностика", ;
    "053 урология, детская урология-андрология", ;
    "054 физиотерапия", ;
    "055 фтизиатрия", ;
    "056 функциональная диагностика", ;
    "057 хирургия, хиругия (трансплантация органов и тканей) и комбустиология", ;
    "058 эндокринология", ;
    "059 эндоскопия", ;
    "060 бактериология", ;
    "061 вирусология", ;
    "062 эпидемиология", ;
    "063 ортодонтия", ;
    "064 стоматология и стоматология детская", ;
    "065 стоматология терапевтическая", ;
    "066 стоматология ортопедическая", ;
    "067 стоматология хирургическая", ;
    "068 челюстно-лицевая хирургия", ;
    "069 прочие";
    }
  Local i

  For i := 1 To Len( arr )
    arr[ i ] := { arr[ i ], Left( arr[ i ], 3 ) }
  Next

  Return arr

// 08.02.23
Function usl_stom_ffoms()

  Static arr_gr := { "Общепрофильные", "Ортодонтия", "Терапевтическая стоматология", "Физиотерапия", "Хирургическая стоматология" }
  Local i, j, k, s, buf := save_maxrow(), name_file := cur_dir + "uslugiS" + stxt, sh := 80, HH := 60, t_arr[ 2 ], fl

  mywait()
  r_use_base( "luslf" )
  Index On Str( grp, 1 ) + shifr to ( cur_dir + "tmp_uslf" )
  fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
  // add_string("2020 год")
  add_string( Str( WORK_YEAR, 4, 0 ) + ' год' )
  add_string( Center( "Номенклатура стоматологических услуг Минздрава РФ (ФФОМС)", sh ) )
  add_string( "" )
  For j := 1 To Len( arr_gr )
    fl := .t.
    find ( Str( j, 1 ) )
    Do While luslf->grp == j .and. !Eof()
      s := AllTrim( luslf->shifr ) + " " + RTrim( luslf->name )
      If luslf->zf == 1
        s += " [ЗФ]"
      Endif
      k := perenos( t_arr, s, sh - 12 )
      If fl
        verify_ff( HH - k - 3, .t., sh )
        add_string( Replicate( "=", sh ) )
        add_string( Center( arr_gr[ j ], sh ) )
        add_string( Replicate( "=", sh ) )
        fl := .f.
      Endif
      verify_ff( HH - k, .t., sh )
      add_string( PadR( t_arr[ 1 ], sh - 12 ) + put_val_0( luslf->uetv, 6, 2 ) + put_val_0( luslf->uetd, 6, 2 ) )
      For i := 2 To k
        add_string( PadL( AllTrim( t_arr[ i ] ), sh - 12 ) )
      Next
      Skip
    Enddo
  Next
  Close databases
  rest_box( buf )
  FClose( fp )
  viewtext( name_file,,,, .t.,,, 2 )

  Return Nil

// 24.05.23 Распечатка списка услуг с использованием телемедицинских технологий
Function usl_telemedicina()

  Local i, j, k, buf := save_maxrow(), name_file := cur_dir + 'uslugiT' + stxt, sh := 80, HH := 60, t_arr[ 2 ], fl

  mywait()
  r_use_base( 'luslf' )
  Index On shifr to ( cur_dir + 'tmp_uslf' ) For telemed == 1
  fp := FCreate( name_file )
  n_list := 1
  tek_stroke := 0
  add_string( Str( WORK_YEAR, 4, 0 ) + ' год' )
  add_string( Center( 'Услуги с использованием телемедицинских технологий Минздрава РФ (ФФОМС)', sh ) )
  add_string( '' )
  Go Top
  Do While !Eof()
    // k := perenos(t_arr, alltrim(luslf->shifr) + ' ' + luslf->name, sh)
    k := perenos( t_arr, PadR( luslf->shifr, 15 ) + ' ' + luslf->name, sh )
    verify_ff( HH - k, .t., sh )
    add_string( t_arr[ 1 ] )
    For i := 2 To k
      add_string( PadL( AllTrim( t_arr[ i ] ), sh ) )
    Next
    Skip
  Enddo
  Close databases
  rest_box( buf )
  FClose( fp )
  viewtext( name_file, , , , .t., , , 2 )

  Return Nil

// 28.03.23 Распечатка списка операций на парных органах
Function usl_par_organ()

  Local i, j, k, buf := save_maxrow(), name_file := cur_dir + 'uslugiT' + stxt, sh := 80, HH := 60, t_arr[ 2 ], fl

  mywait()
  r_use_base( 'luslf' )
  Index On shifr to ( cur_dir + 'tmp_uslf' ) For !Empty( par_org )
  fp := FCreate( name_file )
  n_list := 1
  tek_stroke := 0
  add_string( Str( WORK_YEAR, 4, 0 ) + ' год' )
  add_string( '' )
  add_string( '=== Описание обозначения органа (части тела)' )
  For i := 1 To Len( getparorgan() )
    add_string( ' ' + getparorgan()[ i, 1 ] )
  Next
  add_string( '===' )
  add_string( Center( 'Операции на парных органах (частях тела) Минздрава РФ (ФФОМС)', sh ) )
  add_string( '' )
  Go Top
  Do While !Eof()
    k := perenos( t_arr, AllTrim( luslf->shifr ) + ' (' + AllTrim( luslf->par_org ) + ') ' + luslf->name, sh )
    verify_ff( HH - k, .t., sh )
    add_string( t_arr[ 1 ] )
    For i := 2 To k
      add_string( PadL( AllTrim( t_arr[ i ] ), sh ) )
    Next
    Skip
  Enddo
  Close databases
  rest_box( buf )
  FClose( fp )
  viewtext( name_file, , , , .t., , , 2 )

  Return Nil

// 08.02.23 Вывод списка услуг диагностики при дообследовании в направлениях на ЗНО
Function usl_napr_ffoms()

  Static arr_gr := { ;
    { '1 - лабораторная диагностика', 1 }, ;
    { '2 - инструментальная диагностика', 2 }, ;
    { '3 - методы лучевой диагностики, за исключением дорогостоящих', 3 }, ;
    { '4 - дорогостоящие методы лучевой диагностики (КТ, МРТ, ангиография)', 4 } }
  Local i, j, k, buf := save_maxrow(), name_file := cur_dir + 'uslugiON' + stxt, sh := 80, HH := 60, t_arr[ 2 ], fl, ar

  If ( t_arr := bit_popup( T_ROW, T_COL -5, arr_gr, , color0, 1, 'Метод диагностического исследования', 'B/BG' ) ) == NIL
    Return Nil
  Endif
  ar := AClone( t_arr )
  mywait()
  r_use_base( 'luslf' )
  Index On Str( onko_napr, 1 ) + shifr to ( cur_dir + 'tmp_uslf' )
  fp := FCreate( name_file )
  n_list := 1
  tek_stroke := 0
  add_string( Str( WORK_YEAR, 4, 0 ) + ' год' )
  add_string( Center( 'Номенклатура услуг диагностики при дообследовании на ЗНО МЗРФ (ФФОМС)', sh ) )
  add_string( Center( '(услуги в направлениях при подозрении на ЗНО)', sh ) )
  For j := 1 To Len( ar )
    fl := .t.
    find ( Str( ar[ j, 2 ], 1 ) )
    Do While luslf->onko_napr == ar[ j, 2 ] .and. !Eof()
      k := perenos( t_arr, AllTrim( luslf->shifr ) + ' ' + luslf->name, sh )
      If fl
        verify_ff( HH - k -3, .t., sh )
        add_string( Replicate( '=', sh ) )
        add_string( Center( ar[ j, 1 ], sh ) )
        add_string( Replicate( '=', sh ) )
        fl := .f.
      Endif
      verify_ff( HH - k, .t., sh )
      add_string( PadR( t_arr[ 1 ], sh ) )
      For i := 2 To k
        add_string( PadL( AllTrim( t_arr[ i ] ), sh ) )
      Next
      Skip
    Enddo
  Next
  Close databases
  rest_box( buf )
  FClose( fp )
  viewtext( name_file, , , , .t., , , 2 )

  Return Nil

// 08.02.23 Вывод списка услуг по типам лечения ОНКОзаболеваний
Function usl_ksg_ffoms()

  Static arr_gr := { ;
    { '1 - Хирургическое лечение', 1 }, ;
    { '2 - Лекарственная противоопухолевая терапия', 2 }, ;
    { '3 - Лучевая терапия', 3 }, ;
    { '4 - Химиолучевая терапия', 4 }, ;
    { '5 - Неспецифическое лечение (осложнения противоопухолевой терапии, установка/замена порт системы (катетера))', 5 }, ;
    { '6 - Диагностика', 6 } }
  Local i, j, k, buf := save_maxrow(), name_file := cur_dir + 'uslugiOK' + stxt, sh := 80, HH := 60, t_arr[ 2 ], fl, ar

  If ( t_arr := bit_popup( T_ROW, T_COL -5, arr_gr, , color0, 1, 'Тип лечения онкологических заболеваний', 'B/BG' ) ) == NIL
    Return Nil
  Endif
  ar := AClone( t_arr )
  mywait()
  r_use_base( 'luslf' )
  Index On Str( onko_ksg, 1 ) + shifr to ( cur_dir + 'tmp_uslf' )
  fp := FCreate( name_file )
  n_list := 1
  tek_stroke := 0
  add_string( Str( WORK_YEAR, 4, 0 ) + ' год' )
  add_string( Center( 'Номенклатура услуг по типам лечения ОНКОзаболеваний МЗРФ (ФФОМС)', sh ) )
  For j := 1 To Len( ar )
    fl := .t.
    find ( Str( ar[ j, 2 ], 1 ) )
    Do While luslf->onko_ksg == ar[ j, 2 ] .and. !Eof()
      k := perenos( t_arr, AllTrim( luslf->shifr ) + ' ' + luslf->name, sh )
      If fl
        verify_ff( HH - k -3, .t., sh )
        add_string( Replicate( '=', sh ) )
        k := perenos( t_arr, ar[ j, 1 ], sh )
        add_string( Center( AllTrim( t_arr[ 1 ] ), sh ) )
        If k > 1
          add_string( Center( AllTrim( t_arr[ 2 ] ), sh ) )
        Endif
        add_string( Replicate( '=', sh ) )
        fl := .f.
        k := perenos( t_arr, AllTrim( luslf->shifr ) + ' ' + luslf->name, sh )
      Endif
      verify_ff( HH - k, .t., sh )
      add_string( PadR( t_arr[ 1 ], sh ) )
      For i := 2 To k
        add_string( PadL( AllTrim( t_arr[ i ] ), sh ) )
      Next
      Skip
    Enddo
  Next
  Close databases
  rest_box( buf )
  FClose( fp )
  viewtext( name_file, , , , .t., , , 2 )

  Return Nil

// 08.02.23
Function usl1ffoms()

  Static su := 'A01', suA := '01', suB := '001'
  Local k, buf := save_maxrow(), name_file := cur_dir + 'uslugiF' + stxt, arr[ 2 ], ;
    sh := 80, HH := 60, t_arr[ 2 ], t_aA[ 2 ], t_aB[ 2 ], i, n, s, fl := .f.

  If !Empty( popup_2array( usl3ffoms(), T_ROW, T_COL -5, su, 1, @t_arr, ;
      'Выберите раздел номенклатуры медицинских услуг', 'B/W', color5 ) )
    su := t_arr[ 2 ]
    s := su + '.'
    n := 4
    If Left( su, 1 ) == 'A'
      If ( i := popup_prompt( T_ROW, T_COL -5, 2, ;
          { 'В целом по разделу', 'По одной анатомо-функциональной области' } ) ) == 0
        Return Nil
      Elseif i == 1
        fl := .t.
      Elseif ! Empty( popup_2array( usl4ffoms(), T_ROW, T_COL -5, suA, 1, @t_aA, ;
          'Выберите анатомо-функциональную область', 'B/BG', color0 ) )
        suA := t_aA[ 2 ]
        fl := .t.
        s += suA + '.'
        n := 7
      Endif
    Else
      If ( i := popup_prompt( T_ROW, T_COL -5, 1, ;
          { 'В целом по разделу', 'По одной медицинской специальности' } ) ) == 0
        Return Nil
      Elseif i == 1
        fl := .t.
      Elseif ! Empty( popup_2array( usl5ffoms(), T_ROW, T_COL -5, suB, 1, @t_aB, ;
          'Выберите медицинскую специальность', 'B/BG', color0 ) )
        suB := t_aB[ 2 ]
        fl := .t.
        s += suB + '.'
        n := 8
      Endif
    Endif
  Endif
  If fl
    mywait()
    fp := FCreate( name_file )
    n_list := 1
    tek_stroke := 0
    add_string( '' )
    add_string( Center( 'Раздел номенклатуры медицинских услуг ФФОМС:', sh ) )
    For i := 1 To perenos( arr, '"' + t_arr[ 1 ] + '"', sh )
      add_string( Center( AllTrim( arr[ i ] ), sh ) )
    Next
    If n > 4
      If Left( su, 1 ) == 'A'
        add_string( Center( 'Анатомо-функциональная область:', sh ) )
        For i := 1 To perenos( arr, '"' + t_aA[ 1 ] + '"', sh )
          add_string( Center( AllTrim( arr[ i ] ), sh ) )
        Next
      Else
        add_string( Center( 'Медицинская специальность', sh ) )
        For i := 1 To perenos( arr, t_aB[ 1 ], sh )
          add_string( Center( AllTrim( arr[ i ] ), sh ) )
        Next
      Endif
    Endif
    add_string( '' )
    use_base( 'luslf' )
    find ( s )
    Do While s == Left( luslf->shifr, n ) .and. !Eof()
      k := perenos( t_arr, luslf->name, 65 )
      verify_ff( HH - k + 1, .t., sh )
      add_string( luslf->shifr + t_arr[ 1 ] )
      For i := 2 To k
        add_string( Space( 20 ) + t_arr[ i ] )
      Next
      Skip
    Enddo
    Close databases
    rest_box( buf )
    FClose( fp )
    viewtext( name_file, , , , .t., , , 2 )
  Endif

  Return Nil

// 27.05.23
Function usl2ffoms()

  Local i, k, buf := save_maxrow(), name_file := cur_dir + 'uslugiF' + stxt, sh := 85, HH := 80, mas1[ 5 ]

  //
  mywait()
  arr_title := { ;
    '───────────────────┬─────────┬───────────────────────────────────────────────────────', ;
    ' Шифр ФФОМС        │ Шифр МО │ Наименование услуги                                   ', ;
    '───────────────────┴─────────┴───────────────────────────────────────────────────────' }
  fp := FCreate( name_file )
  n_list := 1
  tek_stroke := 0
  add_string( Center( 'Список услуг ФФОМС в нашем справочнике', sh ) )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  use_base( 'luslf' )
  r_use( dir_server + 'mo_su', dir_server + 'mo_sush1', 'MOSU' )
  Go Top
  Do While !Eof()
    k := 1
    AFill( mas1, '' )
    If mosu->tip == 5 .and. LUSLF18->( Used() )
      Select LUSLF18
      find ( mosu->shifr1 )
      If Found()
        k := perenos( mas1, '...удалена...' + luslf18->name, 55 )
      Endif
    Else
      Select LUSLF
      find ( mosu->shifr1 )
      If Found()
        k := perenos( mas1, luslf->name, 55 )
      Elseif  LUSLF18->( Used() )
        Select LUSLF18
        find ( mosu->shifr1 )
        If Found()
          k := perenos( mas1, '...удалена...' + luslf18->name, 55 )
        Endif
      Endif
    Endif
    If verify_ff( HH - k + 1, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( mosu->shifr1 + mosu->shifr + mas1[ 1 ] )
    For i := 2 To k
      add_string( Space( 30 ) + mas1[ i ] )
    Next
    Select MOSU
    Skip
  Enddo
  Close databases
  rest_box( buf )
  FClose( fp )
  viewtext( name_file, , , , .t., , , 5 )

  Return Nil

// 08.02.23
Function usl6ffoms( lksg )

  Local k, buf := save_maxrow(), name_file := cur_dir + 'usl_ksg' + stxt, nu, sh := 80, HH := 78, ;
    t_arr, i, s, fl, v1, v2, mdate, fl1uslc, fl2uslc, ta[ 2 ], fl1del, fl2del, ret_arr
  Local sbase

  glob_otd_dep := 0
  If is_otd_dep .and. lksg == 1 .and. ( ret_arr := ret_otd_dep() ) == NIL
    Return Nil
  Endif
  mywait()
  dbCreate( cur_dir + 'tmp', { ;
    { 'SHIFR',      'C',     10,      0 }, ;
    { 'NAME',       'C',    255,      0 }, ;
    { 'CENA_V',     'C',     10,      0 }, ;
    { 'CENA_D',     'C',     10,      0 } } )
  Use ( cur_dir + 'tmp' ) new
  dbCreate( cur_dir + "tmp1", { ;
    { 'SHIFR',      'C',     10,      0 }, ;
    { 'SHIFR1',     'C',     20,      0 } } )
  Use ( cur_dir + 'tmp1' ) new
  Index On shifr1 + shifr to ( cur_dir + 'tmp1' )
  mdate := sys_date

  sbase := prefixfilerefname( WORK_YEAR ) + 'k006'
  r_use( dir_exe + sbase, , 'K006' )
  Index On SHIFR + SY to ( cur_dir + 'tmp_t009' )
  use_base( 'luslc' )
  use_base( 'lusl' )
  Index On fsort_usl( shifr ) to ( cur_dir + 'tmp_lusl' ) For is_ksg( shifr, lksg ) .and. datebeg >= BoY( mdate )
  Go Top
  Do While !Eof()
    v1 := fcena_oms( lusl->shifr, .t., mdate, @fl1del, @fl1uslc )
    v2 := fcena_oms( lusl->shifr, .f., mdate, @fl2del, @fl2uslc )
    If !( fl1del .and. fl2del )
      Select TMP
      Append Blank
      tmp->SHIFR  := lusl->shifr
      tmp->NAME   := AllTrim( lusl->name )
      tmp->CENA_V := iif( fl1del, '      -   ', Str( v1, 10, 2 ) )
      tmp->CENA_D := iif( fl2del, '      -   ', Str( v2, 10, 2 ) )
      Select K006
      find ( PadR( lusl->shifr, 10 ) )
      Do While ( PadR( lusl->shifr, 10 ) ) == k006->shifr .and. !Eof()
        If !Empty( k006->sy )
          Select TMP1
          find ( PadR( k006->sy, 20 ) + PadR( lusl->shifr, 10 ) )
          If !Found()
            Append Blank
            tmp1->SHIFR  := lusl->shifr
            tmp1->SHIFR1 := k006->sy
          Endif
        Endif
        Select K006
        Skip
      Enddo
    Endif
    Select LUSL
    Skip
  Enddo
  delfrfiles()
  dbCreate( fr_titl, { ;
    { 'mo',    'C', 90, 0 }, ;
    { 'str1',  'C', 90, 0 }, ;
    { 'str2',  'C', 90, 0 };
    } )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->mo := glob_mo[ _MO_SHORT_NAME ] + iif( ValType( ret_arr ) == 'A', ' (' + ret_arr[ 1 ] + ')', '' )
  fp := FCreate( name_file )
  n_list := 1
  tek_stroke := 0
  add_string( glob_mo[ _MO_SHORT_NAME ] + iif( ValType( ret_arr ) == 'A', ' (' + ret_arr[ 1 ] + ')', '' ) )
  add_string( '' )
  s := 'Услуги ФФОМС + КСГ в ' + iif( lksg == 1, 'стационаре', 'дневном стационаре' )
  frt->str1 := s
  add_string( Center( s, sh ) )
  s := '[ цены по состоянию на ' + date_8( mdate ) + 'г. ]'
  frt->str2 := s
  add_string( Center( s, sh ) )
  add_string( '' )
  dbCreate( fr_data, { { 'SHIFR1',  'C', 20, 0 }, ;
    { 'NAME',    'C', 255, 0 } } )
  Use ( fr_data ) New Alias _d
  //
  dbCreate( fr_data + '1', { { 'SHIFR1', 'C', 20, 0 }, ;
    { 'SHIFR', 'C', 10, 0 }, ;
    { 'NAME',  'C', 255, 0 }, ;
    { 'CENA_V', 'C', 10, 0 }, ;
    { 'CENA_D', 'C', 10, 0 } } )
  Use ( fr_data + '1' ) New Alias _d1
  use_base( 'luslf' )
  old_shifr := Space( 20 )
  Select TMP
  Index On shifr to ( cur_dir + 'tmp' )
  Select TMP1
  Go Top
  Do While !Eof()
    If !( old_shifr == tmp1->shifr1 )
      add_string( Replicate( '─', sh ) )
      Select LUSLF
      find ( tmp1->shifr1 )
      k := perenos( ta, luslf->name, sh -15 )
      For i := 1 To k
        verify_ff( HH, .t., sh )
        add_string( iif( i == 1, tmp1->shifr1, Space( 20 ) ) + ta[ i ] )
      Next
      add_string( Replicate( '-', sh ) )
      Select _D
      Append Blank
      _d->shifr1 := tmp1->shifr1
      _d->name := luslf->name
    Endif
    old_shifr := tmp1->shifr1
    Select TMP
    find ( tmp1->shifr )
    k := perenos( ta, AllTrim( tmp->name ), 45 )
    For i := 1 To k
      verify_ff( HH, .t., sh )
      add_string( iif( i == 1, PadL( AllTrim( tmp->shifr ), 19 ) + ' ', Space( 20 ) ) + ta[ i ] + ;
        iif( i == 1, tmp->cena_v + tmp->cena_d, '' ) )
    Next
    Select _D1
    Append Blank
    _d1->shifr1 := tmp1->shifr1
    _d1->shifr := tmp->shifr
    _d1->name := tmp->name
    _d1->cena_v := tmp->cena_v
    _d1->cena_d := tmp->cena_d
    Select TMP1
    Skip
  Enddo
  Select _d1
  Index On shifr1 + shifr to ( fr_data + '1' )
  Close databases
  rest_box( buf )
  FClose( fp )
  name_fr := 'mo_v1ksg' + sfr3
  If _upr_epson() .or. ! File( dir_exe + name_fr )
    viewtext( name_file, , , , .t., , , 5 )
  Else
    call_fr( name_fr, , , {|| FrPrn:setmasterdetail( '_data', '_data1', {|| _data->shifr1 } ) } )
  Endif

  Return Nil

// 25.01.23
Function usl11ffoms()

  Local buf := save_maxrow(), name_file := cur_dir + 'vidVMP' + stxt, sh := 80, HH := 60, t_arr[ 2 ], i, j, k
  Local arrV018 := getv018( BoY() )

  mywait()

  fp := FCreate( name_file )
  n_list := 1
  tek_stroke := 0
  add_string( '' )
  add_string( Center( 'Классификатор видов ВМП', sh ) )
  add_string( '' )
  For j := 1 To Len( arrV018 )
    k := perenos( t_arr, arrV018[ j, 2 ], 67 )
    verify_ff( HH - k + 1, .t., sh )
    add_string( PadR( arrV018[ j, 1 ], 13 ) + t_arr[ 1 ] )
    For i := 2 To k
      add_string( Space( 13 ) + t_arr[ i ] )
    Next
  Next
  rest_box( buf )
  FClose( fp )
  viewtext( name_file, , , , .t., , , 2 )

  Return Nil

// 25.01.23
Function usl12ffoms()

  Static sast, sarr
  Local buf := save_maxrow(), name_file := cur_dir + 'metodVMP' + stxt, sh := 80, HH := 60, t_arr[ 2 ], a, i, j, k, n, s
  Local arrV018 := getv018( BoY() )
  Local arrV019 := getv019( BoY() )

  If sast == NIL
    sast := {}
    sarr := {}
    For j := 1 To Len( arrV018 )
      AAdd( sast, .t. )
      AAdd( sarr, { PadR( arrV018[ j, 1 ], 13 ) + Left( arrV018[ j, 2 ], 67 ), arrV018[ j, 1 ] } )
    Next
  Endif
  If ( a := bit_popup( T_ROW, T_COL -5, sarr, sast ) ) != NIL
    AFill( sast, .f. )
    For i := 1 To Len( a )
      If ( j := AScan( sarr, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
        sast[ j ] := .t.
      Endif
    Next
    mywait()
    fp := FCreate( name_file )
    n_list := 1
    tek_stroke := 0
    add_string( '' )
    add_string( Center( 'Классификатор методов ВМП', sh ) )
    add_string( '' )
    For n := 1 To Len( a )
      If ( j := AScan( arrV018, {| x| x[ 1 ] == a[ n, 2 ] } ) ) > 0
        k := perenos( t_arr, arrV018[ j, 2 ], 67 )
        verify_ff( HH - k + 3, .t., sh )
        add_string( Replicate( '-', sh ) )
        add_string( PadR( arrV018[ j, 1 ], 13 ) + t_arr[ 1 ] )
        For i := 2 To k
          add_string( Space( 13 ) + t_arr[ i ] )
        Next
        add_string( Replicate( '-', sh ) )
        For l := 1 To Len( arrV019 )
          If arrV019[ l, 4 ] == arrV018[ j, 1 ]
            s := arrV019[ l, 2 ] + ' (диагноз' + iif( Len( arrV019[ l, 3 ] ) > 1, 'ы', '' ) + ;
              ' ' + print_array( arrV019[ l, 3 ] ) + ')'
            k := perenos( t_arr, s, 66 )
            verify_ff( HH - k + 1, .t., sh )
            add_string( Str( arrV019[ l, 1 ], 13 ) + ' ' + t_arr[ 1 ] )
            For i := 2 To k
              add_string( Space( 14 ) + t_arr[ i ] )
            Next
          Endif
        Next
      Endif
    Next
    rest_box( buf )
    FClose( fp )
    viewtext( name_file, , , , .t., , , 2 )
  Endif

  Return Nil

//
Function spr_other()

  Local mas_pmt, mas_msg, mas_fun, j, r, c := T_COL - 5

  mas_pmt := { "~Прочие организации", ;
    "~Комитеты (МО)", ;
    "~Службы", ;
    "~Услуги без службы";
    }
  mas_msg := { "Прочие организации", ;
    "Комитеты по здравоохранению (МО)", ;
    "Список служб с возможностью распечатки услуг по конкретной службе", ;
    "Распечатка услуг, у которых не проставлена служба";
    }
  mas_fun := { "f1spr_other(1)", ;
    "f1spr_other(2)", ;
    "f1spr_other(3)", ;
    "f1spr_other(4)" }
  If ( r := T_ROW - Len( mas_pmt ) -3 ) < 0
    r := 2 ; c := T_COL + 10
  Endif
  popup_prompt( r, c, 1, mas_pmt, mas_msg, mas_fun )

  Return Nil

//
Function f1spr_other( k )

  Local buf := save_maxrow(), mas1 := {}, mas2

  Do Case
  Case k == 1
    popup_edit( dir_server + "str_komp", T_ROW, T_COL - 5, T_ROW + 8,, PE_VIEW,,,, {|| !Between( tfoms, 44, 47 ) } )
  Case k == 2
    popup_edit( dir_server + "komitet", T_ROW, T_COL - 5, T_ROW + 8,, PE_VIEW )
  Case k == 3
    If r_use( dir_server + "slugba", dir_server + "slugba", "SL" )
      Go Top
      Do While alpha_browse( T_ROW, T_COL - 5, MaxRow() -2, T_COL + 45, "f2spr_other", color0 )
        f3spr_other( 1 )
      Enddo
    Endif
  Case k == 4
    f3spr_other( 2 )
  Endcase
  Close databases
  rest_box( buf )

  Return Nil

//
Function f2spr_other( oBrow )

  oBrow:addcolumn( TBColumnNew( "Шифр", {|| sl->shifr } ) )
  oBrow:addcolumn( TBColumnNew( Center( "Наименование службы", 40 ), {|| sl->name } ) )
  status_key( "^<Esc>^ - выход;  ^<Enter>^ - выбор службы" )

  Return Nil

// 08.02.23
Function f3spr_other( reg )

  Local buf := save_maxrow(), n_file := cur_dir + 'uslugi' + stxt, ;
    sh := 80, HH := 60, l, k, mas[ 2 ]

  mywait()
  fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
  add_string( "" )
  If mem_trudoem == 2
    Private arr_title := { Space( sh - 15 ) + "УЕТ " + iif( is_oplata == 7, "вр.", "взр" ) + "│УЕТ " + iif( is_oplata == 7, "асс", "дет" ), ;
      Space( sh - 15 ) + "───────┴───────" }
    useuch_usl()
    l := sh - 16
  Else
    l := sh
  Endif
  use_base( 'lusl' )
  use_base( 'luslc' )
  r_use( dir_server + 'uslugi', dir_server + "uslugisl", 'USL' )
  If reg == 1
    add_string( Center( "Список услуг по службе:", 80 ) )
    add_string( Center( lstr( sl->shifr ) + ". " + AllTrim( sl->name ), 80 ) )
    find ( Str( sl->shifr, 3 ) )
    Index On fsort_usl( shifr ) to ( cur_dir + "tmp" ) For kod > 0 While slugba == sl->shifr
  Else
    add_string( Center( "Список услуг с непроставленной службой", 80 ) )
    Index On fsort_usl( shifr ) to ( cur_dir + "tmp" ) For f5spr_other()
  Endif
  add_string( "" )
  If mem_trudoem == 2
    AEval( arr_title, {| x| add_string( x ) } )
  Endif
  Go Top
  Do While !Eof()
    lshifr := ""
    If !Empty( usl->shifr )
      s := usl->shifr
      lshifr += AllTrim( usl->shifr )
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod )
      If !Empty( lshifr1 ) .and. !( usl->shifr == lshifr1 )
        s := lshifr1
        lshifr += "(" + AllTrim( lshifr1 ) + ")"
      Endif
      lshifr += "."
      s := f42_uslugi( 1, s )
      s1 := f42_uslugi( 23 )
      If !emptyall( s, s1 ) .or. usl->is_nul
        If mem_trudoem == 2
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
        Else
          verify_ff( HH, .t., sh )
        Endif
        If Empty( s )
          s := s1
        Elseif !Empty( s1 )
          s += ";" + s1
        Endif
        k := perenos( mas, lshifr + AllTrim( usl->name ) + " [" + s + "]", l, " , ;" )
        s := PadR( mas[ 1 ], l )
        If mem_trudoem == 2
          Select UU
          find ( Str( usl->kod, 4 ) )
          If is_oplata == 7
            s += put_val_0( uu->vkoef_v, 8, 4 ) + put_val_0( uu->akoef_v, 8, 4 )
          Else
            s += put_val_0( uu->koef_v, 8, 4 ) + put_val_0( uu->koef_r, 8, 4 )
          Endif
        Endif
        add_string( s )
        If k > 1
          add_string( PadL( AllTrim( mas[ 2 ] ), l ) )
        Endif
      Endif
    Endif
    Select USL
    Skip
  Enddo

  close_use_base( 'lusl' )
  close_use_base( 'luslc' )

  usl->( dbCloseArea() )
  If mem_trudoem == 2
    uu->( dbCloseArea() )
    uu1->( dbCloseArea() )
  Endif
  If reg == 1
    Select SL
  Endif
  FClose( fp )
  viewtext( n_file,,,,,,, 2 )
  rest_box( buf )

  Return Nil

//
Function f5spr_other()

  Local fl := !Empty( shifr )

  If fl
    fl := is_nul .or. !emptyall( cena, cena_d )
  Endif
  If fl
    fl := ( slugba <= 0 )
  Endif

  Return fl

// 07.03.21
// список персонала
Function spr_personal()

  Local k, sh := 80, HH := 57, fl := .t., s

  mywait()
  fp := FCreate( cur_dir + "spisok" + stxt ) ; n_list := 1 ; tek_stroke := 0
  add_string( "" )
  add_string( Center( "Списочный состав персонала с табельными номерами", sh ) )
  add_string( "" )
  add_string( Center( AllTrim( glob_uch[ 2 ] ) + " (" + AllTrim( glob_otd[ 2 ] ) + ")", sh ) )
  add_string( PadL( date_8( sys_date ) + "г.", sh ) )
  If r_use( dir_server + "mo_pers",, "PERSO" )
    Index On Upper( fio ) to ( cur_dir + "tmp_pers" ) For kod > 0
    Do While !Eof()
      If fl .or. tek_stroke > HH
        If !fl
          add_string( Chr( 12 ) )
          tek_stroke := 0
          n_list++
          next_list( sh )
        Endif
        add_string( "─────┬──────────────────────────────────────────────────┬──────────────────────" )
        add_string( "Таб.№│                       Ф.И.О.                     │ Специальность        " )
        add_string( "─────┴──────────────────────────────────────────────────┴──────────────────────" )
      Endif
      fl := .f.
      s := put_val( perso->tab_nom, 5 ) + ;
        iif( Empty( perso->svod_nom ), Space( 5 ), PadL( "(" + lstr( perso->svod_nom ) + ")", 5 ) ) + ;
        " " + PadR( AllTrim( perso->fio ), 45 )
      If !emptyall( perso->prvs, perso->prvs_new )
        s += " " + ret_tmp_prvs( perso->prvs, perso->prvs_new )
      Endif
      add_string( s )
      Select PERSO
      Skip
    Enddo
  Endif
  Close databases
  FClose( fp )
  viewtext( "spisok" + stxt,,,,,,, 2 )

  Return Nil


// список отделений с кодами
Function spr_kod_otd()

  Local sh := 64, HH := 57, buf := save_maxrow(), n_file := cur_dir + "kod_otd" + stxt

  mywait()
  Private t_arr := {}, count_uch := 0
  r_use( dir_server + 'mo_uch',, "UCH" )
  dbEval( {|| count_uch++, AAdd( t_arr, { kod, AllTrim( name ) } ) } )
  If count_uch == 0
    func_error( 4, "База учреждений пуста!" )
  Else
    r_use( dir_server + 'mo_otd',, 'OTD' )
    Index On Str( kod_lpu, 3 ) + Upper( name ) to ( cur_dir + "tmp_otd" ) For !Empty( name )
    fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( "" )
    add_string( Center( Expand( "КОДЫ ОТДЕЛЕНИЙ" ), sh ) )
    add_string( "" )
    Select UCH
    Index On Upper( name ) to ( cur_dir + "tmp_uch" ) For !Empty( name )
    Go Top
    Do While !Eof()
      add_string( "" )
      add_string( Upper( uch->name ) )
      Select OTD
      find ( Str( uch->kod, 3 ) )
      Do While otd->kod_lpu == uch->kod .and. !Eof()
        add_string( Str( otd->kod, 14 ) + "   " + otd->name )
        Select OTD
        Skip
      Enddo
      Select UCH
      Skip
    Enddo
  Endif
  Close databases
  FClose( fp )
  rest_box( buf )
  viewtext( n_file )

  Return Nil


// просмотр/печать справочника диагнозов
Function spr_info_diagn( k )

  Static sk := 1
  Local str_sem, mas_pmt, mas_msg, mas_fun, j

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { "~Болезни МКБ-10", ;
      "~Группы (классы)", ;
      "~Подгруппы", ;
      "Пе~чать по группам", ;
      "Печ~ать по подгруппам" }
    mas_msg := { "Просмотр справочника МКБ-10 (поиск по шифру или наименованию)", ;
      "Просмотр справочника групп диагнозов (классов)", ;
      "Просмотр справочника подгрупп диагнозов", ;
      "Печать справочника МКБ-10 по группам", ;
      "Печать справочника МКБ-10 по подгруппам" }
    mas_fun := { "spr_info_diagn(1)", ;
      "spr_info_diagn(2)", ;
      "spr_info_diagn(3)", ;
      "spr_info_diagn(4)", ;
      "spr_info_diagn(5)" }
    popup_prompt( T_ROW, T_COL - 5, sk, mas_pmt, mas_msg, mas_fun )
  Case k > 0
    f_10diag( k )
  Endcase
  If k > 0
    sk := k
  Endif

  Return Nil


// 26.07.23
Function f_10diag( k )

  Local buf := SaveScreen(), i := 1, c1 := 1, c2 := 77, msh_b, msh_e, arr_t, s, s1

  Private pregim := k, uregim := 1

  change_attr()
  Do Case
  Case k == 1
    mywait()
    r_use( dir_exe + '_mo_mkb', cur_dir + '_mo_mkb', 'DIAG' )
    Go Top
    alpha_browse( 2, c1, MaxRow() -2, c2, 'f1_10diag', color0, , , .t., , , , 'f2_10diag', , {, , , 'N/BG, W+/N, B/BG, BG+/B, GR/BG, BG+/GR', .t. } )
  Case k == 2
    r_use( dir_exe + '_mo_mkbk' )
    Index On sh_b + Str( ks, 1 ) to ( cur_dir + 'tmp' )
    Go Top
    alpha_browse( 2, 0, MaxRow() -2, 79, 'f1_10diag', color0, , , .t., , , , , , { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B' } )
  Case k == 3
    r_use( dir_exe + '_mo_mkbg' )
    Index On sh_b + Str( ks, 1 ) to ( cur_dir + 'tmp' )
    Go Top
    alpha_browse( 2, c1, MaxRow() -2, c2, 'f1_10diag', color0, , , .t., , , , , , { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B' } )
  Case k == 4 .or. k == 5
    r_use( dir_exe + '_mo_mkb' + iif( pregim == 4, 'k', 'g' ) )
    Index On sh_b + Str( ks, 1 ) to ( cur_dir + 'tmp_d' )
    Use
    Do While .t.
      r_use( dir_exe + '_mo_mkb' + iif( pregim == 4, 'k', 'g' ) )
      Set Index To 'tmp_d'
      Goto ( i )
      If pregim == 4
        c1 := 0
        c2 := 79
      Endif
      If alpha_browse( 2, c1, MaxRow() -2, c2, 'f1_10diag', color0, , , .t., , , , , , { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B' } )
        mywait()
        arr_t := {}
        Do While ks > 0
          Skip -1
        Enddo
        i := RecNo()
        If pregim == 4
          AAdd( arr_t, 'Класс ' + AllTrim( klass ) )
        Endif
        msh_b := sh_b
        msh_e := sh_e
        Do While sh_e == msh_e
          AAdd( arr_t, AllTrim( name ) )
          Skip
        Enddo
        Use
        If msh_b == msh_e
          AAdd( arr_t, '( ' + AllTrim( msh_b ) + ' )' )
        Else
          AAdd( arr_t, '( ' + AllTrim( msh_b ) + ' - ' + AllTrim( msh_e ) + ' )' )
        Endif
        Private sh := 76, HH := 77
        fp := FCreate( cur_dir + 'diagtmp.txt' )
        n_list := 1
        tek_stroke := 0
        add_string( '' )
        r_use( dir_exe + '_mo_mkb', cur_dir + '_mo_mkb', 'DIAG' )
        For k := 1 To Len( arr_t )
          add_string( Center( arr_t[ k ], sh ) )
        Next
        add_string( '' )
        add_string( Center( '[ знаком "-" перед шифром отмечены диагнозы, не входящие в ОМС ]', sh ) )
        add_string( '' )
        dbSeek( PadR( msh_b, 5 ), .t. )
        Do While Left( shifr, 3 ) <= msh_e .and. !Eof()
          If ks == 0
            verify_ff( HH, .t., sh )
          Endif
          If !( '.' $ shifr ) .and. ks == 0
            add_string( '' )
          Endif
          s1 := iif( ks == 0 .and. !Empty( diag->pol ), iif( diag->pol == 'М', '<муж.>', '<жен.>' ), Space( 6 ) )
          s := iif( '.' $ shifr, s1, '' )
          s += iif( ks == 0 .and. !between_date_new( diag->dbegin, diag->dend ), '-', ' ' )
          s += PadR( if( ks == 0, shifr, '' ), 6 )
          s += ' ' + RTrim( name )
          add_string( s )
          Skip
        Enddo
        Close databases
        FClose( fp )
        viewtext( 'diagtmp.txt', , , , , , , 5 )
      Else
        Exit
      Endif
    Enddo
  Endcase
  Close databases
  RestScreen( buf )

  Return Nil

// 13.04.21
Function f1_10diag( oBrow )

  Local oColumn, blk, n := 65

  If pregim == 1
    blk := {|| iif( !between_date( diag->dbegin, diag->dend,,, .t. ), { 3, 4 }, iif( !Empty( diag->pol ), { 5, 6 }, { 1, 2 } ) ) }
    oColumn := TBColumnNew( "Шифр", {|| PadR( if( ks == 0, shifr + diag->pol, "" ), 7 ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    oColumn := TBColumnNew( Center( "Наименование диагнозов заболеваний", n ), {|| name } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    If uregim > 0
      status_key( "^<Esc>^ - выход;  ^<F2>^ - поиск по шифру;  ^<F3>^ - поиск по подстроке" + ;
        iif( uregim == 1, "", ";  ^<Enter>^ - выбор" ) )
    Endif
  Else
    If equalany( pregim, 2, 4 )
      oColumn := TBColumnNew( "Класс", {|| if( ks == 0, klass, "    " ) } )
      oColumn:colorBlock := blk
      oBrow:addcolumn( oColumn )
      n := 64
    Endif
    oColumn := TBColumnNew( "", {|| if( ks == 0, sh_b, "    " ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    oColumn := TBColumnNew( "", {|| if( ks == 0, sh_e, "    " ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    oColumn := TBColumnNew( Center( "Наименование " + ;
      iif( pregim == 2 .or. pregim == 4, "", "под" ) + "группы заболеваний", n ), {|| Left( name, n ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
    If uregim > 0
      If equalany( pregim, 4, 5 )
        status_key( "^<Esc>^ - выход;  ^<Enter>^ - выбор " + iif( pregim == 4, "", "под" ) + "группы для печати" )
      Else
        status_key( "^^ - просмотр;  ^<Esc>^ - выход" + iif( uregim == 1, "", ";  ^<Enter>^ - выбор" ) )
      Endif
    Endif
  Endif

  Return Nil

//
Function f2_10diag( nKey, oBrow )

  Static sshifr := "     ", sname := ""
  Local buf, buf24, fl := .f., s, rec, k := -1, bg := {| o, k| get_mkb10( o, k ) }

  Do Case
  Case nKey == K_F2
    buf := save_box( 18, 0, 24, 79 )
    Private mshifr := sshifr
    box_shadow( 18, 20, 20, 59, color8 )
    @ 19, 32 Say "Введите шифр" Color color1 ;
      Get mshifr Picture "@K@!" ;
      reader {| o| mygetreader( o, bg ) } ;
      Valid val1_10diag( .f. ) Color color1
    status_key( "^<Esc>^ - отказ от ввода;  ^<Enter>^ - подтверждение ввода" )
    myread( { "confirm" } )
    If LastKey() != K_ESC .and. !Empty( mshifr )
      rec := RecNo()
      find ( RTrim( mshifr ) )
      If Found()
        sshifr := mshifr
        k := 0
      Else
        Goto rec
        func_error( 4, "Диагноз с таким шифром не найден!" )
      Endif
    Endif
    rest_box( buf )
    If k == 0
      oBrow:gotop()
      find ( RTrim( mshifr ) )
    Endif
  Case nKey == K_F3
    Private mname := PadR( AllTrim( sname ), 30 )
    If ( mname := input_value( 18, 4, 20, 75, color8, ;
        "Введите подстроку диагноза для поиска", ;
        mname, "@K@!" ) ) != Nil .and. !Empty( mname )
      mname := AllTrim( mname )
      rec := RecNo()
      //
      Private i := j := 0, lshifr := "", lname := "", ;
        tmp_mas := {}, tmp_kod := {}, t_len
      hGauge := gaugenew(,, { color8, color1, "G+/B" }, "Поиск подстроки <." + mname + ".>", .t. )
      gaugedisplay( hGauge )
      buf24 := save_maxrow()
      s := "^<Esc>^ - прервать поиск"
      status_key( s ) ; s += ".   Найдено диагнозов -"
      Go Top
      Do While !Eof()
        gaugeupdate( hGauge, ++j / LastRec() )
        If Inkey() == K_ESC
          Exit
        Endif
        If FIELD->ks == 0
          If !Empty( lname ) // проверить предыдущую запись
            If mname $ Upper( lname )
              If++i > 4000 ; exit ; Endif
              AAdd( tmp_mas, lshifr + " " + lname )
              AAdd( tmp_kod, lshifr )
              status_key( s + "^ " + lstr( i ) + ".^" )
            Endif
          Endif
          lshifr := FIElD->shifr ; lname := ""
        Endif
        lname += AllTrim( FIELD->name ) + " "
        Skip
      Enddo
      If !Empty( lname ) .and. mname $ Upper( lname )
        AAdd( tmp_mas, lshifr + " " + lname )
        AAdd( tmp_kod, lshifr )
      Endif
      closegauge( hGauge )
      Goto rec
      rest_box( buf24 )
      //
      If ( t_len := Len( tmp_kod ) ) = 0
        func_error( 3, "Неудачный поиск!" )
      Else
        sname := mname
        Private r1 := 2, c1 := 1, r2 := MaxRow() -2, c2 := 77
        Private k1 := r1 + 3, k2 := r2 - 1
        buf := box_shadow( r1, c1, r2, c2, color0 )
        buf24 := save_maxrow()
        @ r1 + 1, c1 + 1 Say "Подстрока: " + mname Color "B/BG"
        SetColor( color0 )
        If t_len < k2 - k1 - 1
          k2 := k1 + t_len + 2
        Endif
        @ k1, c1 + 1 Say PadC( "Кол-во найденных строк - " + lstr( t_len ), c2 - c1 - 1 )
        i := AScan( tmp_kod, sshifr )
        status_key( "^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор;  ^<F9>^ - печать" )
        If ( i := Popup( k1 + 1, c1 + 1, k2, c2 - 1, tmp_mas, i, color0, .t., "f3_10diag" ) ) > 0
          sshifr := tmp_kod[ i ]
          k := 0
        Endif
        rest_box( buf )
        rest_box( buf24 )
      Endif
      //
    Endif
    If k == 0
      oBrow:gotop()
      find ( sshifr )
    Endif
  Endcase

  Return k

//
Function f3_10diag( nKey, nInd )

  Local rec, i

  If nKey == K_F9
    rec := RecNo()
    Private sh := 76, HH := 77
    fp := FCreate( cur_dir + "diagtmp.txt" ) ; n_list := 1 ; tek_stroke := 0
    add_string( "" )
    add_string( Center( "Результат поиска по подстроке: " + mname, sh ) )
    add_string( "" )
    For i := 1 To Len( parr )
      find ( Left( parr[ i ], 6 ) )
      Do While shifr == Left( parr[ i ], 6 ) .and. !Eof()
        If ks == 0
          verify_ff( HH, .t., sh )
        Endif
        s := PadR( if( ks == 0, shifr, "" ), 7 )
        s += " " + RTrim( name )
        add_string( s )
        Skip
      Enddo
    Next
    FClose( fp )
    viewtext( "diagtmp.txt",,,,,,, 5 )
    Goto ( rec )
  Endif

  Return -1


//
Function f10_diagnoz()

  Static srec
  Local buf := SaveScreen(), c1 := 1, c2 := 77, tmp_select := Select()
  Private pregim := 1, uregim := 1

  change_attr()
  mywait()
  r_use( dir_exe + "_mo_mkb", cur_dir + "_mo_mkb", "DIAG" )
  Go Top
  If srec != NIL
    Goto ( srec )
  Endif
  alpha_browse( 2, c1, MaxRow() -2, c2, "f1_10diag", color0,,, .t.,,,, "f2_10diag",, {,,, "N/BG,W+/N,B/BG,BG+/B", .t. } )
  srec := diag->( RecNo() )
  diag->( dbCloseArea() )
  RestScreen( buf )
  If tmp_select > 0
    Select ( tmp_select )
  Endif

  Return Nil


//
Function diag_to_num( lshifr, j )

  Local s, c5, c6, i, l, lnum := 0

  lshifr := AllTrim( lshifr )
  If ( l := Len( lshifr ) ) > 0
    c5 := c6 := { "0", "9" }[ j ]  // на конце 0 - для начала интервала, 9 - для конца
    If l > 3
      If l >= 5
        c5 := SubStr( lshifr, 5, 1 )
      Endif
      If l == 6
        c6 := Right( lshifr, 1 )
      Endif
      // на всякий случай
      lshifr := PadR( lshifr, 3, "0" ) ; l := 3
    Endif
    lshifr += c5 + c6 ; l := Len( lshifr )
    // первый символ буква, остальные - цифры
    s := lstr( Asc( Left( lshifr, 1 ) ) )
    For i := 2 To l
      s += SubStr( lshifr, i, 1 )
    Next
    lnum := Int( Val( s ) )
  Endif

  Return lnum

// 09.12.18 инициализировать все mem (public) - переменные
Function init_all_mem_public()

  // настраиваемые из всех задач
  Public mem_smp_input := 0
  Public mem_smp_tel := 0
  Public mem_dom_aktiv := 0
  Public mem_beg_rees := 1
  Public mem_end_rees := 999999
  Public mem_bnn_rees := 1
  Public mem_enn_rees := 99
  Public mem_bnn13rees := -1
  Public mem_enn13rees := -1
  Public okato_umolch := "18401395000"
  Public public_date := CToD( "" ) // датa, по которую (включительно) запрещено редактировать данные
  Public mem_kart_error := 0  // 1 - разрешать администратору устанавливать статус амбулаторной карты
  Public mem_kodkrt  := 1     // 2 - если есть регистратура???
  Public mem_trudoem := 1
  Public mem_tr_plan := 2     // да
  Public mem_sound   := 2     // да
  Public mem_pol     := 1
  Public mem_diag4   := 2     // да
  Public mem_diagno  := 2     // да
  Public mem_kodotd  := 1
  Public mem_otdusl  := 1
  Public mem_ordusl  := 1
  Public mem_ordu_1  := 2     // да
  Public mem_kat_va  := 2     // да
  Public mem_vv_v_a  := 2
  Public mem_por_vr  := 1
  Public mem_por_ass := 2
  Public mem_por_kol := 3
  Public mem_date_1  := CToD( "" )
  Public mem_date_2  := CToD( "" )
  Public yes_many_uch := .f.  // выбор отделения только из "своего" учреждения
  Public mem_ff_lu := 1
  // Приёмный покой
  Public pp_NOVOR     := 1  // вводить новорожденного
  Public pp_KEM_NAPR  := "" // список наиболее часто встречающихся направляющих ЛПУ
  Public pp_POB_D_LEK := 1  // вводить побочное действие лекарств
  Public pp_KOD_VR    := 1  // вводить кода врача приёмного отделения
  Public pp_TRAVMA    := 1  // вводить вид травмы
  Public pp_NE_ZAK    := 1  // запрет ввода, если еще не закончил лечение по предыдущему случаю
  // ОМС
  Public mem_KEM_NAPR := "" // список наиболее часто встречающихся направляющих ЛПУ
  Public mem_edit_ist := 2
  Public mem_e_istbol := 1
  Public mem_op_out  := 1    // нет
  Public mem_st_kat  := 1
  Public mem_st_pov  := 1
  Public mem_st_trav := 1
  Public mem_zav_l   := 3     // запоминать предыдущий
  Public mem_pom_va   := 1    // нет
  Public mem_coplec   := 1    // нет
  Public mem_dni_vr  := 365  // для совместимости - не храним
  Public is_uchastok := 0
  Public is_oplata := 5       // способ оплаты
  Public yes_h_otd := 1
  Public yes_vypisan := B_STANDART // или B_END  при работе с "Завершением лечения"
  Public yes_num_lu := 0      // =1 - номер л/у равен номеру записи
  Public yes_d_plus := "+-"   // по умолчанию после диагноза
  Public yes_bukva := .f.     // если разрешается ввод букв
  Public is_zf_stomat := 0    // зубная формула = нет
  Public mem_ls_parakl := 0   // Включать ПАРАКЛИНИКУ в сумму ЛИЧНОГО СЧЁТА
  Public is_0_schet := 0
  Public pp_OMS := .t.    // записываем из приёмного покоя л/у в задачу ОМС
  Public pp_date_OMS      // с какой даты
  Public mem_n_V034 := 0  // вид справочника V034
  Public mem_methodinj := 0  // вид справочника ПУТИ ВВЕДЕНИЯ
  // для задачи "Платные услуги" и "ЛПУ-Касса"
  Public delta_chek := 0  // перечитать из "lpu.ini"-файла
  // для задачи "Платные услуги"
  Public mem_anonim := 0  // работать с анонимами
  Public glob_pl_reg := 0 // нет квит.книжки, 1 - есть
  Public glob_close := 0  // закрытие л/учета: платные и в/зачет вручную, ДМС по оплате
  Public glob_kassa := 0  // нет кассового аппарата, 1 - кассовый аппарат: Штрих-ФР-Ф
  Public mem_naprvr  := 2  // для платных услуг
  Public mem_plsoput := 1  // для платных услуг
  Public mem_dogovor := "_DOGOVOR.SHB"  // для платных услуг
  Public mem_pl_ms   := 0  // для платных услуг
  Public mem_pl_sn   := 0  // для платных услуг
  Public mem_dms     := 0  // для платных услуг
  Public mem_edit_s  := 2
  // для задачи "Ортопедия"
  Public mem_ort_na  := Space( 10 ) // ортопедия
  Public mem_ort_sl  := Space( 10 ) // ортопедия
  Public mem_ort_ysl := 1     // нет // ортопедия
  Public mem_ortotd  := 0            // ортопедия
  Public mem_ortot1  := 1            // ортопедия
  Public mem_ort_ms  := 2     // да  // ортопедия
  Public mem_ort_bp  := "ZAKAZ_BP.SMY"// ортопедия
  Public mem_ort_pl  := "ZAKAZ_PL.SMY"// ортопедия
  Public mem_ort_dat := 1             // ортопедия
  Public mem_ort_f8  := "LIST_U_8.SHB" // ортопедия
  Public mem_ortfflu := 1              // ортопедия
  Public mem_ort_dog := Space( 3 )   // расширение догов. ортопедии
  Public mem_ort_f39 := 0  // работать с формой 39

  Public MUSIC_ON_OFF := ( mem_sound == 2 )

  If ( j := search_file( "lpu" + sini, 2 ) ) != NIL
  /*i := GetIniVar( j, {{"kartoteka","uchastok",}} )
  if i[1] != NIL .and. eq_any(i[1],"1","2")
    is_uchastok := int(val(i[1]))
  endif
  i := GetIniVar( j, {{"diagnoz","bukva",}} )
  if i[1] != NIL
    yes_d_plus := i[1]
    for i := 1 to len(yes_d_plus)
      if asc(substr(yes_d_plus,i, 1)) > 64
        yes_bukva := .t. ; exit
      endif
    next
  endif
  i := GetIniVar( j, {{'uslugi',"oplata",}} )
  if i[1] != NIL
    is_oplata := int(val(i[1]))
    if !between(is_oplata, 5, 7)
      is_oplata := 5
    endif
  endif
  // Разрешается выписывать счета с нулевой суммой (по параклинике):
  i := GetIniVar( j, {{'uslugi',"schet_nul",}} )
  if i[1] != NIL
    is_0_schet := int(val(i[1]))
    if !between(is_0_schet, 0, 1)
      is_0_schet := 0
    endif
  endif
  i := GetIniVar( j, {{"lechenie","human_otd",}, ;
                      {"lechenie","standart",}, ;
                      {"lechenie","many_uch",}} )
  if i[1] != NIL .and. i[1] == "2"
    yes_h_otd := 2        // работаем без выбора отделений
  endif
  if i[2] != NIL .and. i[2] == "2"
    yes_vypisan := B_END  // установлена задача "Завершение лечения"
  endif
  if i[3] != NIL .and. i[3] == "2"
    yes_many_uch := .t.  // выбор отделения из всех доступных учреждений
  endif
  //
  i := GetIniVar( j, {{"list_uch","nomer",}} )
  if i[1] != NIL
    if upper(i[1]) == "RECNO"
      yes_num_lu := 1  // номер л/у равен номеру записи
    endif
  endif
  // для задачи "Платные услуги"
  i := GetIniVar( j, {{"lpu_plat","regi_plat",}, ;
                      {"lpu_plat","close",}, ;
                      {"lpu_plat","kassa",}} )
  if i[1] != NIL .and. i[1] == "1"
    glob_pl_reg := 1  // вводим квитанционную книжку в задаче "Платные услуги"
  endif
  if i[2] != NIL .and. i[1] == "1"
    glob_close := 1  // закрытие листа учета - вручную
  endif
  if i[3] != NIL .and. eq_any(i[3],"elves","fr")
    glob_kassa := 1   // кассовый аппарат: Штрих-ФР-Ф
    glob_pl_reg := 0  // убираем квитанционную книжку
  endif*/
    // для задачи "Платные услуги" и "ЛПУ-Касса"
    i := getinivar( j, { { "kassa", "delta_chek", } } )
    If i[ 1 ] != NIL
      delta_chek := Int( Val( i[ 1 ] ) )
    Endif
  Endif
  //
  If ( j := search_file( "lpu_stom" + sini ) ) != NIL
    k := getinisect( j, "Категория" )
    If !Empty( k )
      stm_kategor2 := {}
      For i := 1 To Len( k )
        AAdd( stm_kategor2, { k[ i, 1 ], Int( Val( k[ i, 2 ] ) ) } )
      Next
    Endif
    k := getinisect( j, "Повод" )
    If !Empty( k )
      stm_povod := {}
      For i := 1 To Len( k )
        AAdd( stm_povod, { k[ i, 1 ], Int( Val( k[ i, 2 ] ) ) } )
      Next
    Endif
    k := getinisect( j, "Травма" )
    If !Empty( k )
      stm_travma := {}
      For i := 1 To Len( k )
        AAdd( stm_travma, { k[ i, 1 ], Int( Val( k[ i, 2 ] ) ) } )
      Next
    Endif
  Endif
  //
  Public dlo_version := 4
  Public is_r_mu := .f.
  Public gpath_reg := "" // путь к файлам R_MU.DBF

  Return Nil

// 22.06.23 удалить счет(а) по одному реестру СП и ТК и по этим людям создать заново счета (м.б.другое кол-во счетов)
Function recreate_some_schet_from_file_sp( arr )

  Local arr_XML_info[ 8 ], cFile, arr_f, k, n, oXmlDoc, aerr := {}, t_arr[ 2 ], ;
    i, s, rec_schet, rec_schet_xml, go_to_schet := .f., arr_schet := {}

  Private name_schet, _date_schet, mXML_REESTR

  For i := 1 To Len( arr )
    Select SCHET
    Goto ( arr[ i ] )
    If emptyany( schet_->name_xml, schet_->kod_xml ) .or. schet_->IS_MODERN == 1
      Return func_error( 4, "Некорректно заполнены поля счёта " + RTrim( schet_->nschet ) + ". Операция запрещена." )
    Endif
    If i == 1
      mXML_REESTR := schet_->XML_REESTR // ссылка на реестр СП и ТК
    Elseif mXML_REESTR != schet_->XML_REESTR
      Return func_error( 4, "Счёт " + RTrim( schet_->nschet ) + " из другого реестра СП и ТК. Операция запрещена." )
    Endif
    AAdd( arr_schet, { ;
      arr[ i ], ;                  // 1 - schet->(recno())
      schet_->kod_xml, ;         // 2 - ссылка на файл "mo_xml"
      schet_->name_xml, ;        // 3 - имя XML-файла без расширения (и ZIP-архива)
      AllTrim( schet_->nschet ), ; // 4 - номер счета
    schet_->dschet ;          // 5 - дата формирования счета
      } )
  Next
  //
  mo_xml->( dbGoto( mXML_REESTR ) )
  If Empty( mo_xml->REESTR )
    Return func_error( 4, "Отсутствует ссылка на первичный реестр! Операция запрещена." )
  Endif
  Private cReadFile := AllTrim( mo_xml->FNAME ) // имя файла реестра СП и ТК
  Private cFileProtokol := cReadFile + stxt     // имя файла протокола чтения реестра СП и ТК
  Private mkod_reestr := mo_xml->REESTR       // код первичного реестра
  Private cTimeBegin := hour_min( Seconds() )
  Private name_zip := cReadFile + szip          // имя архива файла реестра СП и ТК
  cFile := cReadFile + sxml                     // имя XML-файла реестра СП и ТК
  //
  rees->( dbGoto( mkod_reestr ) )
  Private name_reestr := AllTrim( rees->name_xml ) + szip // имя архива файла первичного реестра
  // распаковываем первичный реестр
  If ( arr_f := extract_zip_xml( dir_server + dir_XML_MO + cslash, name_reestr ) ) == NIL
    Return func_error( 4, "Ошибка в распаковке архива реестра " + name_reestr )
  Endif
  // распаковываем реестр СП и ТК
  If ( arr_f := extract_zip_xml( dir_server + dir_XML_TF + cslash, name_zip ) ) == NIL
    Return func_error( 4, "Ошибка в распаковке архива реестра СП и ТК " + name_zip )
  Endif
  If ( n := AScan( arr_f, {| x| Upper( name_without_ext( x ) ) == Upper( cReadFile ) } ) ) == 0
    Return func_error( 4, "В архиве " + name_zip + " нет файла " + cReadFile + sxml )
  Endif
  Close databases

  If mo_lock_task( X_OMS ) // запрет только ОМС G_SLock1Task(sem_task,sem_vagno) // запрет доступа всем
    k := Len( arr_schet )
    s := iif( k == 1, "счёта ", lstr( k ) + " счетов " )
    If iif( arr_schet[ 1, 5 ] > SToD( "20220224" ) .and. arr_schet[ 1, 5 ] < SToD( "20220228" ), .t., involved_password( 3, arr_schet[ 1, 4 ], "пересоздания " + s + arr_schet[ 1, 4 ] ) ) ;
        .and. f_esc_enter( "пересоздания " + s ) // .and. m_copy_DB_from_end(.t.) // резервное копирование
      Private fl_open := .t.
      index_base( "schet" ) // для составления счетов
      index_base( "human" ) // для разноски счетов
      index_base( "human_3" ) // двойные случаи
      Use ( dir_server + "human_u" ) New READONLY
      Index On Str( kod, 7 ) + date_u to ( dir_server + "human_u" ) progress
      Use
      Use ( dir_server + "mo_hu" ) New READONLY
      Index On Str( kod, 7 ) + date_u to ( dir_server + "mo_hu" ) progress
      Use
      index_base( "mo_refr" )  // для записи причин отказов
      //
      mywait()
      StrFile( hb_eol() + ;
        Space( 10 ) + "Повторная обработка файла: " + cFile + ;
        hb_eol(), cFileProtokol )
      StrFile( Space( 10 ) + full_date( sys_date ) + "г. " + cTimeBegin + ;
        hb_eol(), cFileProtokol, .t. )
      mywait( "Производится анализ файла " + cFile )
      // читаем файл в память
      oXmlDoc := hxmldoc():read( _tmp_dir1 + cFile )
      If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
        AAdd( aerr, "Ошибка в чтении файла " + cFile )
      Else
        reestr_sp_tk_tmpfile( oXmlDoc, aerr, cReadFile )
      Endif
      If Empty( aerr )
        r_use( dir_server + "mo_rees",, "REES" )
        Goto ( mkod_reestr )
        If !extract_reestr( rees->( RecNo() ), rees->name_xml )
          AAdd( aerr, Center( "Не найден ZIP-архив с РЕЕСТРом № " + lstr( mnschet ) + " от " + date_8( tmp1->_DSCHET ), 80 ) )
          AAdd( aerr, "" )
          AAdd( aerr, Center( dir_server + dir_XML_MO + cslash + AllTrim( rees->name_xml ) + szip, 80 ) )
          AAdd( aerr, "" )
          AAdd( aerr, Center( "Без данного архива дальнейшая работа НЕВОЗМОЖНА!", 80 ) )
        Endif
      Endif
      Close databases
      If Empty( aerr )
        dbCreate( cur_dir + "tmpsh", { { "kod_h", "N", 7, 0 } } )
        Use ( cur_dir + "tmpsh" ) new
        r_use( dir_server + "human", dir_server + "humans", "HUMAN" )
        For i := 1 To Len( arr_schet )
          find ( Str( arr_schet[ i, 1 ], 6 ) )
          Do While human->schet == arr_schet[ i, 1 ] .and. !Eof()
            Select tmpsh
            Append Blank
            Replace kod_h With human->kod
            Select HUMAN
            Skip
          Enddo
        Next
        Select tmpsh
        Index On Str( kod_h, 7 ) to ( cur_dir + "tmpsh" )
        r_use( dir_server + "mo_rhum",, "RHUM" )
        Index On Str( REES_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For reestr == mkod_reestr
        // открыть распакованный реестр
        Use ( cur_dir + "tmp_r_t1" ) New Alias T1
        Index On Str( Val( n_zap ), 6 ) to ( cur_dir + "tmpt1" )
        Use ( cur_dir + "tmp_r_t2" ) New Alias T2
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + "tmpt2" )
        Use ( cur_dir + "tmp_r_t3" ) New Alias T3
        Index On Upper( ID_PAC ) to ( cur_dir + "tmpt3" )
        Use ( cur_dir + "tmp_r_t4" ) New Alias T4
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + "tmpt4" )
        Use ( cur_dir + "tmp_r_t5" ) New Alias T5
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + "tmpt5" )
        Use ( cur_dir + "tmp_r_t6" ) New Alias T6
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + "tmpt6" )
        Use ( cur_dir + "tmp_r_t7" ) New Alias T7
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + "tmpt7" )
        Use ( cur_dir + "tmp_r_t8" ) New Alias T8
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + "tmpt8" )
        Use ( cur_dir + "tmp_r_t9" ) New Alias T
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + "tmpt9" )
        Use ( cur_dir + "tmp_r_t10" ) New Alias T10
        Index On IDCASE + Str( sluch, 6 ) + regnum + code_sh + date_inj to ( cur_dir + "tmpt10" )
        Use ( cur_dir + "tmp_r_t11" ) New Alias T11
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + "tmpt11" )
        Use ( cur_dir + "tmp_r_t12" ) New Alias T12
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir + "tmpt12" )
        Use ( cur_dir + "tmp_r_t1_1" ) New Alias T1_1
        Index On IDCASE to ( cur_dir + "tmpt1_1" )
        Use ( cur_dir + "tmp2file" ) New Alias TMP2
        is_new_err := .f.  // ушли ли какие-либо случаи в ошибки (т.е. новые ошибки)
        Go Top
        Do While !Eof()
          If tmp2->_OPLATA == 1
            Select T1
            find ( Str( tmp2->_N_ZAP, 6 ) )
            If Found()
              t1->VPOLIS := lstr( tmp2->_VPOLIS )
              t1->SPOLIS := tmp2->_SPOLIS
              t1->NPOLIS := tmp2->_NPOLIS
              t1->ENP    := tmp2->_ENP
              t1->SMO    := tmp2->_SMO
              t1->SMO_OK := tmp2->_SMO_OK
              t1->MO_PR  := tmp2->_MO_PR
            Endif
          Endif
          Select RHUM
          find ( Str( tmp2->_N_ZAP, 6 ) )
          If Found() .and. rhum->KOD_HUM > 0
            Select tmpsh
            find ( Str( rhum->KOD_HUM, 7 ) )
            If Found()
              tmp2->kod_human := rhum->KOD_HUM
              If tmp2->_OPLATA > 1
                is_new_err := .t. // т.е. в новом реестре СП и ТК человек ушёл в ошибки (а раньше попадал в счёт)
              Endif
            Endif
          Else
            AAdd( aerr, "" )
            AAdd( aerr, " - не найден пациент с номером записи " + lstr( tmp2->_N_ZAP ) )
          Endif
          Select TMP2
          Skip
        Enddo
        Select TMP2
        Delete For kod_human == 0 // удалим тех, кто не входит в выбранные счета
        Pack
      Endif
      Close databases
      If Empty( aerr ) .and. is_new_err
        r_use( dir_server + 'mo_otd',, 'OTD' )
        g_use( dir_server + "human_",, "HUMAN_" )
        g_use( dir_server + "human", { dir_server + "humann", dir_server + "humans" }, "HUMAN" )
        Set Order To 0 // индексы открыты для реконструкции при перезаписи ФИО
        Set Relation To RecNo() into HUMAN_, To otd into OTD
        g_use( dir_server + "human_3", { dir_server + "human_3", dir_server + "human_32" }, "HUMAN_3" )
        g_use( dir_server + "mo_rhum",, "RHUM" )
        Index On Str( REES_ZAP, 6 ) to ( cur_dir + "tmp_rhum" ) For reestr == mkod_reestr
        g_use( dir_server + "mo_refr", dir_server + "mo_refr", "REFR" )
        Use ( cur_dir + "tmp3file" ) New Alias TMP3
        Index On Str( _n_zap, 8 ) to ( cur_dir + "tmp3" )
        Use ( cur_dir + "tmp2file" ) New Alias TMP2
        Go Top
        Do While !Eof()
          If tmp2->_OPLATA > 1 // удаляем из счёта, удаляем из реестра, оформляем ошибку
            Select RHUM
            find ( Str( tmp2->_N_ZAP, 6 ) )
            g_rlock( forever )
            rhum->OPLATA := tmp2->_OPLATA
            is_2 := 0
            Select HUMAN
            Goto ( rhum->KOD_HUM )
            If eq_any( human->ishod, 88, 89 )
              Select HUMAN_3
              If human->ishod == 88
                Set Order To 1
                is_2 := 1
              Else
                Set Order To 2
                is_2 := 2
              Endif
              find ( Str( rhum->KOD_HUM, 7 ) )
              If Found() // если нашли двойной случай
                Select HUMAN
                If human->ishod == 88  // если реестр составлен по 1-му листу
                  Goto ( human_3->kod2 )  // встать на 2-ой
                Else
                  Goto ( human_3->kod )   // иначе - на 1-ый
                Endif
                human->( g_rlock( forever ) )
                human->schet := 0 ; human->tip_h := B_STANDART
                //
                human_->( g_rlock( forever ) )
                human_->OPLATA := tmp2->_OPLATA
                human_->REESTR := 0 // направляется на дальнейшее редактирование
                human_->ST_VERIFY := 0 // снова ещё не проверен
                If human_->REES_NUM > 0
                  human_->REES_NUM := human_->REES_NUM - 1
                Endif
                human_->REES_ZAP := 0
                If human_->schet_zap > 0
                  If human_->SCHET_NUM > 0
                    human_->SCHET_NUM := human_->SCHET_NUM - 1
                  Endif
                  human_->schet_zap := 0
                Endif
                //
                human_3->( g_rlock( forever ) )
                human_3->OPLATA := tmp2->_OPLATA
                human_3->schet := 0
                human_3->REESTR := 0
                If human_3->REES_NUM > 0
                  human_3->REES_NUM := human_3->REES_NUM - 1
                Endif
                human_3->REES_ZAP := 0
                If human_3->SCHET_NUM > 0
                  human_3->SCHET_NUM := human_3->SCHET_NUM -1
                Endif
                human_3->schet_zap := 0
              Endif
            Endif
            Select HUMAN
            Goto ( rhum->KOD_HUM )
            g_rlock( forever )
            human->schet := 0 ; human->tip_h := B_STANDART
            human_->( g_rlock( forever ) )
            human_->OPLATA := tmp2->_OPLATA
            human_->REESTR := 0 // а направляется на дальнейшее редактирование
            human_->ST_VERIFY := 0 // снова ещё не проверен
            If human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM - 1
            Endif
            human_->REES_ZAP := 0
            If human_->SCHET_NUM > 0
              human_->SCHET_NUM := human_->SCHET_NUM - 1
            Endif
            human_->schet_zap := 0
            //
            lal := "human"
            If is_2 > 0
              lal += "_3"
            Endif
            StrFile( "!!! " + AllTrim( human->fio ) + ", " + full_date( human->date_r ) + ;
              iif( Empty( otd->SHORT_NAME ), "", " [" + AllTrim( otd->SHORT_NAME ) + "]" ) + ;
              " " + AllTrim( human->KOD_DIAG ) + ;
              " " + date_8( &lal.->n_data ) + "-" + date_8( &lal.->k_data ) + ;
              hb_eol(), cFileProtokol, .t. )
            Select REFR
            Do While .t.
              find ( Str( 1, 1 ) + Str( mkod_reestr, 6 ) + Str( 1, 1 ) + Str( rhum->KOD_HUM, 8 ) )
              If !Found() ; exit ; Endif
              deleterec( .t. )
            Enddo
            Select TMP3
            find ( Str( tmp2->_N_ZAP, 8 ) )
            Do While tmp2->_N_ZAP == tmp3->_N_ZAP .and. !Eof()
              Select REFR
              addrec( 1 )
              refr->TIPD := 1
              refr->KODD := mkod_reestr
              refr->TIPZ := 1
              refr->KODZ := rhum->KOD_HUM
              refr->IDENTITY := tmp2->_IDENTITY
              refr->REFREASON := tmp3->_REFREASON
              refr->SREFREASON := tmp3->SREFREASON
              If Empty( refr->SREFREASON )
                If Empty( s := ret_t005( refr->REFREASON ) )
                  s := lstr( refr->REFREASON ) + ' неизвестная причина отказа'
                Endif
              Else
                s := 'код ошибки = ' + tmp3->SREFREASON + ' '
                s += '"' + getcategorycheckerrorbyid_q017( Left( tmp3->SREFREASON, 4 ) )[ 2 ] + '" '
                // s += alltrim(inieditspr(A__POPUPMENU, dir_exe + "_mo_Q015", tmp3->SREFREASON))
                s += AllTrim( inieditspr( A__MENUVERT, loadq015(), tmp3->SREFREASON ) )
              Endif
              k := perenos( t_arr, s, 75 )
              For i := 1 To k
                StrFile( Space( 5 ) + t_arr[ i ] + hb_eol(), cFileProtokol, .t. )
              Next
              Select TMP3
              Skip
            Enddo
            If is_2 > 0
              StrFile( Space( 5 ) + '- разбейте двойной случай в режиме "ОМС/Двойные случаи/Разделить"' + ;
                hb_eol(), cFileProtokol, .t. )
              StrFile( Space( 5 ) + '- отредактируйте каждый из случаев в режиме "ОМС/Редактирование"' + ;
                hb_eol(), cFileProtokol, .t. )
              StrFile( Space( 5 ) + '- снова соберите случай в режиме "ОМС/Двойные случаи/Создать"' + ;
                hb_eol(), cFileProtokol, .t. )
            Endif
          Endif
          Select TMP2
          Skip
        Enddo
        Close databases
        StrFile( hb_eol(), cFileProtokol, .t. )
      Endif
      If Empty( aerr )
        arr_f := {}
        // создадим новые счета
        go_to_schet := create_schet_from_xml( arr_XML_info, aerr,, arr_f, cReadFile )
        Close databases
        If Empty( aerr ) // если нет ошибок
          use_base( "schet" )
          Set Relation To
          g_use( dir_server + "mo_xml",, "MO_XML" )
          // удалим старые счета
          For i := 1 To Len( arr_schet )
            StrFile( hb_eol() + ;
              "удалён старый счёт № " + arr_schet[ i, 4 ] + " от " + full_date( arr_schet[ i, 5 ] ) + ;
              hb_eol(), cFileProtokol, .t. )
            Select SCHET_
            Goto ( arr_schet[ i, 1 ] )
            deleterec( .t., .f. )  // без пометки на удаление
            //
            Select SCHET
            Goto ( arr_schet[ i, 1 ] )
            deleterec( .t. )
            //
            Select MO_XML
            Goto ( arr_schet[ i, 2 ] )
            deleterec( .t. )
          Next
          Close databases
        Endif
      Endif
      If Empty( aerr )
        // дозапишем предыдущий файл протокола обработки новым протоколом
        f_append_file( dir_server + dir_XML_TF + cslash + cFileProtokol, cFileProtokol )
        viewtext( devide_into_pages( dir_server + dir_XML_TF + cslash + cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
      Else
        AEval( aerr, {| x| StrFile( x + hb_eol(), cFileProtokol, .t. ) } )
        viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
      Endif
      Delete File ( cFileProtokol )
    Endif
    Close databases
    // разрешение доступа всем
    // G_SUnLock(sem_vagno)
    mo_unlock_task( X_OMS )
    Keyboard ""
    If go_to_schet // если выписаны счета
      Keyboard Chr( K_ENTER )
    Endif
  Else
    func_error( 4, "В данный момент работают другие задачи. Операция запрещена!" )
  Endif

  Return Nil

// 08.02.23 дополнить файл ofile строками из файла nfile
Function f_append_file( ofile, nfile )

  Local s

  ft_use( nfile )
  ft_gotop()
  Do While !ft_eof()
    s := ft_readln()
    StrFile( s + hb_eol(), ofile, .t. )
    ft_skip()
  Enddo
  ft_use()

  Return Nil
