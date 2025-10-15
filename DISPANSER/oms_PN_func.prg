#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 20.09.25 вернуть возрастной период для профилактики несовершеннолетних
Function ret_period_pn( ldate_r, ln_data, lk_data, /*@*/ls, /*@*/ret_i)

  Local i, _m, _d, _y, _m2, _d2, _y2, lperiod, sm, sm_, sm1, sm2, yn_data, yk_data
  Local arr_PN_etap

  Store 0 To _m, _d, _y, _m2, _d2, _y2, lperiod
  yn_data := Year( ln_data )
  yk_data := Year( lk_data )
  arr_PN_etap := np_arr_1_etap( lk_data )
  ls := ''
  count_ymd( ldate_r, ln_data, @_y, @_m, @_d ) // реальный возраст на начало
  count_ymd( ldate_r, lk_data, @_y2, @_m2, @_d2 ) // реальный возраст на окончание
  ret_i := 31
  For i := Len( arr_PN_etap ) To 1 Step -1 // Len( np_arr_1_etap() ) To 1 Step -1
    If i > 17 // 4 года и старше
      If mdvozrast == arr_PN_etap[ i, 2, 1 ]  // np_arr_1_etap()[ i, 2, 1 ]
        ret_i := lperiod := i
        ls := ' (' + lstr( mdvozrast ) + ' ' + s_let( mdvozrast ) + ')'
        If yn_data != yk_data
          lperiod := 0
          ls := 'Ошибка! Начало и окончание профилактики должны быть в одном календарном году'
        Endif
        Exit
      Endif
    Elseif mdvozrast < 4 // до 3 лет (включительно)
      sm1 := Round( Val( lstr( arr_PN_etap[ i, 2, 1 ] ) + '.' + StrZero( arr_PN_etap[ i, 2, 2 ], 2 ) ), 4 )
      sm2 := Round( Val( lstr( arr_PN_etap[ i, 3, 1 ] ) + '.' + StrZero( arr_PN_etap[ i, 3, 2 ], 2 ) ), 4 )
      sm := Round( Val( lstr( _y ) + '.' + StrZero( _m, 2 ) + StrZero( _d, 2 ) ), 4 )
      sm_ := Round( Val( lstr( _y2 ) + '.' + StrZero( _m2, 2 ) + StrZero( _d2, 2 ) ), 4 )
      If sm1 <= sm
        ret_i := i
        If sm_ <= sm2
          lperiod := i
          If lperiod == 1 // новорожденный
            ls := '(новорожденный)'
            If _m2 == 1 .or. _d2 > 29
              lperiod := 0
              ls := 'Ошибка! Новорожденному должно быть не более 29 дней'
            Endif
            Exit
          Elseif lperiod == 16 // 2 года
            ls := ' (2 года)'
            If mdvozrast > 2
              lperiod := 0
              ls := 'Ошибка! Ребёнку в ' + lstr( yn_data ) + ' календарном году уже исполняется 3 года'
            Endif
            Exit
          Elseif lperiod == 17 // 3 года
            ls := ' (3 года)'
            Exit
          Endif
          ls := ' ('
          If arr_PN_etap[ i, 2, 1 ] > 0
            ls += lstr( arr_PN_etap[ i, 2, 1 ] ) + ' ' + s_let( arr_PN_etap[ i, 2, 1 ] ) + ' '
          Endif
          If arr_PN_etap[ i, 2, 2 ] > 0
            ls += lstr( arr_PN_etap[ i, 2, 2 ] ) + ' ' + mes_cev( arr_PN_etap[ i, 2, 2 ] )
          Endif
          ls := RTrim( ls ) + ')'
        Else
          ls := 'Должен быть период ' + ;
            iif( arr_PN_etap[ i, 2, 1 ] == 0, '', lstr( arr_PN_etap[ i, 2, 1 ] ) + 'г.' ) + ;
            iif( arr_PN_etap[ i, 2, 2 ] == 0, '', lstr( arr_PN_etap[ i, 2, 2 ] ) + 'мес.' ) + '-' + ;
            iif( arr_PN_etap[ i, 3, 1 ] == 0, '', lstr( arr_PN_etap[ i, 3, 1 ] ) + 'г.' ) + ;
            iif( arr_PN_etap[ i, 3, 2 ] == 0, '', lstr( arr_PN_etap[ i, 3, 2 ] ) + 'мес.' ) + ', а у Вас ' + ;
            iif( _y == 0, '', lstr( _y ) + 'г.' ) + ;
            iif( _m == 0, '', lstr( _m ) + 'мес.' ) + ;
            iif( _d == 0, '', lstr( _d ) + 'дн.' ) + '-' + ;
            iif( _y2 == 0, '', lstr( _y2 ) + 'г.' ) + ;
            iif( _m2 == 0, '', lstr( _m2 ) + 'мес.' ) + ;
            iif( _d2 == 0, '', lstr( _d2 ) + 'дн.' )
        Endif
        Exit
      Endif
    Endif
  Next
  Return lperiod

// 23.09.25
Function add_pediatr_pn( _pv, _pa, _date, _diag, mpol, mdef_diagnoz, mobil )

  Local arr[ 10 ]

  Default mobil To 0

  AFill( arr, 0 )
  // Select P2
  p2->( dbSeek( Str( _pv, 5 ) ) )
  If p2->( Found() )
    arr[ 1 ] := p2->kod
    arr[ 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
  Endif
  If !Empty( _pa )
    // Select P2
    p2->( dbSeek( Str( _pa, 5 ) ) )
    If p2->( Found() )
      arr[ 3 ] := p2->kod
    Endif
  Endif
  arr[ 4 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), 57, 68 ) // профиль
  If _date >= 0d20250901
    If mobil == 0
      arr[ 5 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), '2.94.1', '2.94.1' ) // шифр услуги
    Else
      arr[ 5 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), '2.94.11', '2.94.11' ) // шифр услуги
    Endif
  Else
    arr[ 5 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), '2.85.15', '2.85.14' ) // шифр услуги
  Endif
  If Empty( _diag ) .or. Left( _diag, 1 ) == 'Z'
    arr[ 6 ] := mdef_diagnoz
  Else
    arr[ 6 ] := _diag
    // Select MKB_10
    mkb_10->( dbSeek( PadR( arr[ 6 ], 6 ) ) )
    If mkb_10->( Found() ) .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
      func_error( 4, 'Несовместимость диагноза по полу ' + arr[ 6 ] )
    Endif
  Endif
  arr[ 9 ] := _date
  Return arr

// 20.09.25 добавить или удалить офтальмолога в массив для несовершеннолетних для 12 месяцев
Function np_oftal_2_85_21( _period, _k_data )

  Static lshifr := '2.85.21'
  Local i

  If _period == 13 // 12 месяцев с 1 сентября
    i := AScan( np_arr_1_etap( _k_data )[ _period, 4 ], lshifr )
    If _k_data > 0d20180831 // с 1 сентября
      If i == 0
        ins_array( np_arr_1_etap( _k_data )[ _period, 4 ], 4, lshifr ) // добавить пере ЛОРом 4-ым элементом
      Endif
    Else
      If i > 0
        del_array( np_arr_1_etap( _k_data )[ _period, 4 ], i )
      Endif
    Endif
  Endif
  Return Nil

// 28.09.25 вернуть шифр услуги законченного случая для ПН
Function ret_shifr_zs_pn( _period, mdata )

  Local lshifr := ''

  if mdata >= 0d20250901
  else
    Do Case
    Case _period == 1
      lshifr := iif( is_neonat, '72.2.37', '72.2.38' ) // 0 месяцев
    Case _period == 2
      lshifr := '72.2.39' // 1 месяц
    Case _period == 3
//      lshifr := iif( m1lis > 0, '72.2.41', '72.2.40' ) // 2 мес
      lshifr := '72.2.40' // 2 мес
    Case _period == 4
      lshifr := '72.2.43' // 3 месяца
    Case eq_any( _period, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15 )
      lshifr := '72.2.42' // 4мес, 5мес, 6мес, 7мес, 8мес, 9мес, 10мес, 11мес, 1год3мес, 1год6мес
    Case _period == 13
      If AScan( np_arr_1_etap( mdata )[ _period, 4 ], '2.85.21' ) > 0  // если есть офтальмолог
//        lshifr := iif( m1lis > 0, '72.2.65', '72.2.64' ) // 12 месяцев с 1 сентября
        lshifr := '72.2.64' // 12 месяцев с 1 сентября
      Else
//        lshifr := iif( m1lis > 0, '72.2.45', '72.2.44' ) // 12 месяцев
        lshifr := '72.2.44' // 12 месяцев
      Endif
    Case _period == 16
      lshifr := '72.2.46' // 2 года
    Case _period == 17
//      lshifr := iif( m1lis > 0, '72.2.48', '72.2.47' ) // 3 года
      lshifr := '72.2.47' // 3 года
    Case eq_any( _period, 18, 19, 22, 23, 25, 26 )
      lshifr := '72.2.49' // 4 года, 5 лет, 8 лет, 9 лет, 11 лет, 12лет
    Case _period == 20
//      lshifr := iif( m1lis > 0, '72.2.51', '72.2.50' ) // 6 лет
      lshifr := '72.2.50' // 6 лет
    Case _period == 21
//      lshifr := iif( m1lis > 0, '72.2.53', '72.2.52' ) // 7 лет
      lshifr := '72.2.52' // 7 лет
    Case _period == 24
//      lshifr := iif( m1lis > 0, '72.2.55', '72.2.54' ) // 10 лет
      lshifr := '72.2.54' // 10 лет
    Case _period == 27
      lshifr := '72.2.56' // 13 лет
    Case _period == 28
      lshifr := '72.2.57' // 14 лет
    Case _period == 29
//      lshifr := iif( m1lis > 0, '72.2.59', '72.2.58' ) // 15 лет
      lshifr := '72.2.58' // 15 лет
    Case _period == 30
//      lshifr := iif( m1lis > 0, '72.2.61', '72.2.60' ) // 16 лет
      lshifr := '72.2.60' // 16 лет
    Case _period == 31
//      lshifr := iif( m1lis > 0, '72.2.63', '72.2.62' ) // 17 лет
      lshifr := '72.2.62' // 17 лет
    Endcase
  Endif
  Return lshifr

// 12.10.25
Function fget_spec_deti( k, r, c, a_spec )

  Local tmp_select := Select(), i, j, as := {}, s, blk, t_arr[ BR_LEN ], n_file := cur_dir() + 'tmpspecdeti'
  Local arr_conv_V015_V021 := conversion_v015_v021()
  local rec

  If !hb_FileExists( n_file + sdbf() )
    If Select( 'MOSPEC' ) == 0
      r_use( dir_exe() + '_mo_spec', cur_dir() + '_mo_spec', 'MOSPEC' )
    Endif
    Select MOSPEC
    mospec->( dbSeek( '2.' ) )    //find ( '2.' )
    Do While Left( mospec->shifr, 2 ) == '2.' .and. ! mospec->( Eof() )
      If mospec->vzros_reb == 1 // дети
        If AScan( as, mospec->prvs_new ) == 0
          AAdd( as, mospec->prvs_new )
        Endif
      Endif
      mospec->( dbSkip() )  //  Skip
    Enddo
    If Select( 'MOSPEC' ) > 0
      mospec->( dbCloseArea() )
    Endif
    For i := 1 To Len( as )
      If ( j := AScan( arr_conv_V015_V021, {| x| x[ 2 ] == as[ i ] } ) ) > 0 // перевод из 21-го справочника
        as[ i ] := arr_conv_V015_V021[ j, 1 ]                          // в 15-ый справочник
      Endif
    Next
    dbCreate( n_file, { ;
      { 'name', 'C', 30, 0 }, ;
      { 'kod', 'C', 4, 0 }, ;
      { 'kod_up', 'C', 4, 0 }, ;
      { 'name1', 'C', 50, 0 }, ;
      { 'is', 'L', 1, 0 } } )
    Use ( n_file ) New Alias SDVN
    Use ( cur_dir() + 'tmp_v015' ) index ( cur_dir() + 'tmpkV015' ) New Alias tmp_ga
    tmp_ga->( dbGoTop() )   //  Go Top
    Do While !tmp_ga->( Eof() )
      If ( i := AScan( as, Int( Val( tmp_ga->kod ) ) ) ) > 0
//        Select SDVN
//        Append Blank
        sdvn->( dbAppend() )
        sdvn->name := AfterAtNum( '.', tmp_ga->name, 1 )
        sdvn->kod := tmp_ga->kod
        s := ''
//        Select TMP_GA
//        rec := RecNo()
        rec := tmp_ga->( RecNo() )
        Do While ! Empty( tmp_ga->kod_up )
          tmp_ga->( dbSeek( tmp_ga->kod_up ) )    //  find ( tmp_ga->kod_up )
          If tmp_ga->( Found() )
            s += AllTrim( AfterAtNum( '.', tmp_ga->name, 1 ) ) + '/'
          Else
            Exit
          Endif
        Enddo
//        Goto ( rec )
        tmp_ga->( dbGoto( rec ) )
        sdvn->name1 := s
      Endif
      tmp_ga->( dbSkip() )    //Skip
    Enddo
    sdvn->( dbCloseArea() )
    tmp_ga->( dbCloseArea() )
  Endif
  Use ( n_file ) New Alias tmp_ga
  Do While ! tmp_ga->( Eof() )
    tmp_ga->is := ( AScan( a_spec, Int( Val( tmp_ga->kod ) ) ) > 0 )
    tmp_ga->( dbSkip() )    //  Skip
  Enddo
  Index On Upper( FIELD->name ) + FIELD->kod to ( n_file )
  If r <= MaxRow() / 2
    t_arr[ BR_TOP ] := r + 1
    t_arr[ BR_BOTTOM ] := MaxRow() -2
  Else
    t_arr[ BR_BOTTOM ] := r - 1
    t_arr[ BR_TOP ] := 2
  Endif
  blk := {|| iif( tmp_ga->is, { 1, 2 }, { 3, 4 } ) }
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B', .f. }
  t_arr[ BR_COLUMN ] := { ;
    { ' ', {|| iif( tmp_ga->is, '', ' ' ) }, blk }, ;
    { 'Код', {|| Left( tmp_ga->kod, 3 ) }, blk }, ;
    { Center( 'Медицинская специальность', 26 ), {|| PadR( tmp_ga->name, 26 ) }, blk }, ;
    { Center( 'подчинение', 45 ), {|| Left( tmp_ga->name1, 45 ) }, blk } ;
    }
  t_arr[ BR_EDIT ] := {| nk, ob| f1get_spec_dvn( nk, ob, 'edit' ) }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Ins>^ - отметить специальность/снять отметку со специальности' ) }
  tmp_ga->( dbGoTop() )   //  Go Top
  edit_browse( t_arr )
  s := ''
  ASize( a_spec, 0 )
  tmp_ga->( dbGoTop() )   //  Go Top
  Do While ! tmp_ga->( Eof() )
    If tmp_ga->is
      s += AllTrim( tmp_ga->kod ) + ','
      AAdd( a_spec, Int( Val( tmp_ga->kod ) ) )
    Endif
    tmp_ga->( dbSkip() )  //  Skip
  Enddo
  If Empty( s )
    s := '---'
  Else
    s := Left( s, Len( s ) -1 )
  Endif
  tmp_ga->( dbCloseArea() )
  Select ( tmp_select )
  Return { 1, s }

// 15.10.25
Function save_arr_pn( lkod, mdata )

  Local arr := {}, k, ta
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect
  local i
  local mvar

  default mdata to Date()
  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'TPERS' )
  Endif

//  Private mvar
  If Type( 'mfio' ) == 'C'
    AAdd( arr, { 'mfio', AllTrim( mfio ) } )
  Endif
  If Type( 'mdate_r' ) == 'D'
    AAdd( arr, { 'mdate_r', mdate_r } )
  Endif
  AAdd( arr, { '0', m1mobilbr } )   // 'N',мобильная бригада
  AAdd( arr, { '1', mperiod } ) // 'N',номер диапазона (от 1 до 33)
  AAdd( arr, { '2', m1mesto_prov } )   // 'N',место проведения
  AAdd( arr, { '5', m1kateg_uch } ) // 'N',Категория учета ребенка: 0-ребенок-сирота; 1-ребенок, оставшийся без попечения родителей; 2-ребенок, находящийся в трудной жизненной ситуации, 3-нет категории
  AAdd( arr, { '6', m1MO_PR } ) // 'C6',код МО прикрепления
  AAdd( arr, { '8', m1school } ) // 'N6',код образовательного учреждения
  AAdd( arr, { '12.1', mWEIGHT } )  // 'N3',вес в кг
  AAdd( arr, { '12.2', mHEIGHT } )  // 'N3',рост в см
  AAdd( arr, { '12.3', mPER_HEAD } )  // 'N3',окружность головы в см
  AAdd( arr, { '12.4', m1FIZ_RAZV } )  // 'N',физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
  AAdd( arr, { '12.4.1', m1FIZ_RAZV1 } )  // 'N',физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
  AAdd( arr, { '12.4.2', m1FIZ_RAZV2 } )  // 'N',физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
  If mdvozrast < 5
    AAdd( arr, { '13.1.1', m1psih11 } )  // 'N1',познавательная функция (возраст развития)
    AAdd( arr, { '13.1.2', m1psih12 } )  // 'N1',моторная функция (возраст развития)
    AAdd( arr, { '13.1.3', m1psih13 } )  // 'N1',эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития)
    AAdd( arr, { '13.1.4', m1psih14 } )  // 'N1',предречевое и речевое развитие (возраст развития)
    AAdd( arr, { '13.1.5', m1psih24 } )  //
    AAdd( arr, { '13.1.6', m1psih25 } )  //
    AAdd( arr, { '13.1.7', m1psih26 } )  //
    AAdd( arr, { '13.1.8', m1psih27 } )  //
    AAdd( arr, { '13.1.9', m1psih28 } )  //
    AAdd( arr, { '13.1.10', m1psih29 } )  //
    AAdd( arr, { '13.1.11', m1psih30 } )  //
    AAdd( arr, { '13.1.12', m1psih31 } )  //
  Else
    AAdd( arr, { '13.2.1', m1psih21 } )  // 'N1',Психомоторная сфера: (норма, отклонение)
    AAdd( arr, { '13.2.2', m1psih22 } )  // 'N1',Интеллект: (норма, отклонение)
    AAdd( arr, { '13.2.3', m1psih23 } )  // 'N1',Эмоционально-вегетативная сфера: (норма, отклонение)
  Endif
  If mpol == 'М'
    AAdd( arr, { '14.1.P', m141p } )     // 'N1',Половая формула мальчика
    AAdd( arr, { '14.1.Ax', m141ax } )   // 'N1',Половая формула мальчика
    AAdd( arr, { '14.1.Fa', m141fa } )   // 'N1',Половая формула мальчика
  Else
    AAdd( arr, { '14.2.P', m142p } )     // 'N1',Половая формула девочки
    AAdd( arr, { '14.2.Ax', m142ax } )   // 'N1',Половая формула девочки
    AAdd( arr, { '14.2.Ma', m142ma } )   // 'N1',Половая формула девочки
    AAdd( arr, { '14.2.Me', m142me } )   // 'N1',Половая формула девочки
    AAdd( arr, { '14.2.Me1', m142me1 } ) // 'N2',Половая формула девочки - menarhe (лет)
    AAdd( arr, { '14.2.Me2', m142me2 } ) // 'N2',Половая формула девочки - menarhe (месяцев)
    AAdd( arr, { '14.2.Me3', m1142me3 } ) // 'N1',Половая формула девочки - menses (характеристика): регулярные, нерегулярные, обильные, умеренные, скудные, болезненные и безболезненные
    AAdd( arr, { '14.2.Me4', m1142me4 } ) // 'N1',Половая формула девочки - menses (характеристика): регулярные, нерегулярные, обильные, умеренные, скудные, болезненные и безболезненные
    AAdd( arr, { '14.2.Me5', m1142me5 } ) // 'N1',Половая формула девочки - menses (характеристика): регулярные, нерегулярные, обильные, умеренные, скудные, болезненные и безболезненные
  Endif
  AAdd( arr, { '15.1', m1diag_15_1 } ) // 'N1',Состояние здоровья до проведения диспансеризации-Практически здоров
  If m1diag_15_1 == 0 .and. !Empty( mdiag_15_1_1 )
    ta := { mdiag_15_1_1 }
    For k := 2 To 14
      mvar := 'm1diag_15_1_' + lstr( k )
      AAdd( ta, &mvar )
    Next
    AAdd( arr, { '15.2', ta } )
  Endif
  If m1diag_15_1 == 0 .and. !Empty( mdiag_15_2_1 )
    ta := { mdiag_15_2_1 }
    For k := 2 To 14
      mvar := 'm1diag_15_2_' + lstr( k )
      AAdd( ta, &mvar )
    Next
    AAdd( arr, { '15.3', ta } )
  Endif
  If m1diag_15_1 == 0 .and. !Empty( mdiag_15_3_1 )
    ta := { mdiag_15_3_1 }
    For k := 2 To 14
      mvar := 'm1diag_15_3_' + lstr( k )
      AAdd( ta, &mvar )
    Next
    AAdd( arr, { '15.4', ta } )
  Endif
  If m1diag_15_1 == 0 .and. !Empty( mdiag_15_4_1 )
    ta := { mdiag_15_4_1 }
    For k := 2 To 14
      mvar := 'm1diag_15_4_' + lstr( k )
      AAdd( ta, &mvar )
    Next
    AAdd( arr, { '15.5', ta } )
  Endif
  If m1diag_15_1 == 0 .and. !Empty( mdiag_15_5_1 )
    ta := { mdiag_15_5_1 }
    For k := 2 To 14
      mvar := 'm1diag_15_5_' + lstr( k )
      AAdd( ta, &mvar )
    Next
    AAdd( arr, { '15.6', ta } )
  Endif
  AAdd( arr, { '15.9', mGRUPPA_DO } ) // 'N1',группа здоровья до дисп-ии
  AAdd( arr, { '15.10', m1GR_FIZ_DO } )  // 'N1',группа здоровья для физкультуры
  AAdd( arr, { '16.1', m1diag_16_1 } ) // 'N1',Состояние здоровья по результатам проведения диспансеризации (Практически здоров)
  If m1diag_16_1 == 0 .and. !Empty( mdiag_16_1_1 )
    ta := { mdiag_16_1_1 }
    For k := 2 To 16
      mvar := 'm1diag_16_1_' + lstr( k )
      AAdd( ta, &mvar )
    Next
    AAdd( arr, { '16.2', ta } )
  Endif
  If m1diag_16_1 == 0 .and. !Empty( mdiag_16_2_1 )
    ta := { mdiag_16_2_1 }
    For k := 2 To 16
      mvar := 'm1diag_16_2_' + lstr( k )
      AAdd( ta, &mvar )
    Next
    AAdd( arr, { '16.3', ta } )
  Endif
  If m1diag_16_1 == 0 .and. !Empty( mdiag_16_3_1 )
    ta := { mdiag_16_3_1 }
    For k := 2 To 16
      mvar := 'm1diag_16_3_' + lstr( k )
      AAdd( ta, &mvar )
    Next
    AAdd( arr, { '16.4', ta } )
  Endif
  If m1diag_16_1 == 0 .and. !Empty( mdiag_16_4_1 )
    ta := { mdiag_16_4_1 }
    For k := 2 To 16
      mvar := 'm1diag_16_4_' + lstr( k )
      AAdd( ta, &mvar )
    Next
    AAdd( arr, { '16.5', ta } )
  Endif
  If m1diag_16_1 == 0 .and. !Empty( mdiag_16_5_1 )
    ta := { mdiag_16_5_1 }
    For k := 2 To 16
      mvar := 'm1diag_16_5_' + lstr( k )
      AAdd( ta, &mvar )
    Next
    AAdd( arr, { '16.6', ta } )
  Endif
  If m1invalid1 == 1
    ta := { m1invalid1, m1invalid2, minvalid3, minvalid4, m1invalid5, m1invalid6, minvalid7, m1invalid8 }
    AAdd( arr, { '16.7', ta } )   // массив из 8
  Endif
  AAdd( arr, { '16.8', mGRUPPA } )    // 'N1',группа здоровья после дисп-ии
  AAdd( arr, { '16.9', m1GR_FIZ } )    // 'N1',группа здоровья для физкультуры
  If m1privivki1 > 0
    ta := { m1privivki1, m1privivki2, mprivivki3 }
    AAdd( arr, { '16.10', ta } )  // массив из 4,Проведение профилактических прививок
  Endif
  If !Empty( mrek_form )
    AAdd( arr, { '16.11', AllTrim( mrek_form ) } ) // Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой
  Endif
  If !Empty( mrek_disp )
    AAdd( arr, { '16.12', AllTrim( mrek_disp ) } ) // Рекомендации по диспансерному наблюдению, лечению, медицинской реабилитации и санаторно-курортному лечению с указанием диагноза (код МКБ), вида медицинской организации и специальности (должности) врача
  Endif
  // 18.результаты проведения исследований
  For i := 1 To len( np_arr_issled( mdata ) )
    mvar := 'MREZi' + lstr( i )
    If !Empty( &mvar )
      AAdd( arr, { '18.' + lstr( i ), AllTrim( &mvar ) } )
    Endif
  Next
  If !Empty( arr_usl_otkaz )
    AAdd( arr, { '29', arr_usl_otkaz } ) // массив
  Endif
  If mdata >= 0d20210801
    If mtab_v_dopo_na != 0
      If TPERS->( dbSeek( Str( mtab_v_dopo_na, 5 ) ) )
        AAdd( arr, { '47', { m1dopo_na, TPERS->kod } } )
      Else
        AAdd( arr, { '47', { m1dopo_na, 0 } } )
      Endif
    Else
      AAdd( arr, { '47', { m1dopo_na, 0 } } )
    Endif
  Else
    AAdd( arr, { '47', m1dopo_na } )
  Endif
  If Type( 'm1p_otk' ) == 'N'
    AAdd( arr, { '51', m1p_otk } )
  Endif
  If mdata >= 0d20210801
    If Type( 'm1napr_v_mo' ) == 'N'
      If mtab_v_mo != 0
        If TPERS->( dbSeek( Str( mtab_v_mo, 5 ) ) )
          AAdd( arr, { '52', { m1napr_v_mo, TPERS->kod } } )
        Else
          AAdd( arr, { '52', { m1napr_v_mo, 0 } } )
        Endif
      Else
        AAdd( arr, { '52', { m1napr_v_mo, 0 } } )
      Endif
    Endif
  Else
    If Type( 'm1napr_v_mo' ) == 'N'
      AAdd( arr, { '52', m1napr_v_mo } )
    Endif
  Endif
  If Type( 'arr_mo_spec' ) == 'A' .and. !Empty( arr_mo_spec )
    AAdd( arr, { '53', arr_mo_spec } ) // массив
  Endif
  If mdata >= 0d20210801
    If Type( 'm1napr_stac' ) == 'N'
      If mtab_v_stac != 0
        If TPERS->( dbSeek( Str( mtab_v_stac, 5 ) ) )
          AAdd( arr, { '54', { m1napr_stac, TPERS->kod } } )
        Else
          AAdd( arr, { '54', { m1napr_stac, 0 } } )
        Endif
      Else
        AAdd( arr, { '54', { m1napr_stac, 0 } } )
      Endif
    Endif
  Else
    If Type( 'm1napr_stac' ) == 'N'
      AAdd( arr, { '54', m1napr_stac } )
    Endif
  Endif
  If Type( 'm1profil_stac' ) == 'N'
    AAdd( arr, { '55', m1profil_stac } )
  Endif
  If mdata >= 0d20210801
    If Type( 'm1napr_reab' ) == 'N'
      If mtab_v_reab != 0
        If TPERS->( dbSeek( Str( mtab_v_reab, 5 ) ) )
          AAdd( arr, { '56', { m1napr_reab, TPERS->kod } } )
        Else
          AAdd( arr, { '56', { m1napr_reab, 0 } } )
        Endif
      Else
        AAdd( arr, { '56', { m1napr_reab, 0 } } )
      Endif
    Endif
  Else
    If Type( 'm1napr_reab' ) == 'N'
      AAdd( arr, { '56', m1napr_reab } )
    Endif
  Endif
  If Type( 'm1profil_kojki' ) == 'N'
    AAdd( arr, { '57', m1profil_kojki } )
  Endif

  If ! aliasIsUse
    TPERS->( dbCloseArea() )
    Select( oldSelect )
  Endif
  save_arr_dispans( lkod, arr )
  Return Nil

// 15.10.25
Function read_arr_pn( lkod, is_all, mdata )

  Local arr, i, k
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect
  Local mvar

  // Private mvar
  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server() + 'mo_pers',, 'TPERS' )
  Endif

  Default is_all To .t.
  default mdata to Date()
  arr := read_arr_dispans( lkod )
  For i := 1 To Len( arr )
    If ValType( arr[ i ] ) == 'A' .and. ValType( arr[ i, 1 ] ) == 'C'
      If arr[ i, 1 ] == '1' .and. ValType( arr[ i, 2 ] ) == 'N'
        mperiod := arr[ i, 2 ]
      Elseif is_all
        Do Case
        Case arr[ i, 1 ] == '0' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1mobilbr := arr[ i, 2 ]
        Case arr[ i, 1 ] == '2' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1mesto_prov := arr[ i, 2 ]
        Case arr[ i, 1 ] == '5' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1kateg_uch := arr[ i, 2 ]
        Case arr[ i, 1 ] == '6' .and. ValType( arr[ i, 2 ] ) == 'C'
          m1MO_PR := arr[ i, 2 ]
        Case arr[ i, 1 ] == '8' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1school := arr[ i, 2 ]
        Case arr[ i, 1 ] == '12.1' .and. ValType( arr[ i, 2 ] ) == 'N'
          mWEIGHT := arr[ i, 2 ]
        Case arr[ i, 1 ] == '12.2' .and. ValType( arr[ i, 2 ] ) == 'N'
          mHEIGHT := arr[ i, 2 ]
        Case arr[ i, 1 ] == '12.3' .and. ValType( arr[ i, 2 ] ) == 'N'
          mPER_HEAD := arr[ i, 2 ]
        Case arr[ i, 1 ] == '12.4' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1FIZ_RAZV := arr[ i, 2 ]
        Case arr[ i, 1 ] == '12.4.1' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1FIZ_RAZV1 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '12.4.2' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1FIZ_RAZV2 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.1.1' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih11 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.1.2' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih12 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.1.3' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih13 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.1.4' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih14 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.1.5' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih24 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.1.6' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih25 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.1.7' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih26 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.1.8' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih27 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.1.9' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih28 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.1.10' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih29 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.1.11' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih30 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.1.12' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih31 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.2.1' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih21 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.2.2' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih22 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.2.3' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih23 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '14.1.P' .and. ValType( arr[ i, 2 ] ) == 'N'
          m141p := arr[ i, 2 ]
        Case arr[ i, 1 ] == '14.1.Ax' .and. ValType( arr[ i, 2 ] ) == 'N'
          m141ax := arr[ i, 2 ]
        Case arr[ i, 1 ] == '14.1.Fa' .and. ValType( arr[ i, 2 ] ) == 'N'
          m141fa := arr[ i, 2 ]
        Case arr[ i, 1 ] == '14.2.P' .and. ValType( arr[ i, 2 ] ) == 'N'
          m142p := arr[ i, 2 ]
        Case arr[ i, 1 ] == '14.2.Ax' .and. ValType( arr[ i, 2 ] ) == 'N'
          m142ax := arr[ i, 2 ]
        Case arr[ i, 1 ] == '14.2.Ma' .and. ValType( arr[ i, 2 ] ) == 'N'
          m142ma := arr[ i, 2 ]
        Case arr[ i, 1 ] == '14.2.Me' .and. ValType( arr[ i, 2 ] ) == 'N'
          m142me := arr[ i, 2 ]
        Case arr[ i, 1 ] == '14.2.Me1' .and. ValType( arr[ i, 2 ] ) == 'N'
          m142me1 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '14.2.Me2' .and. ValType( arr[ i, 2 ] ) == 'N'
          m142me2 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '14.2.Me3' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1142me3 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '14.2.Me4' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1142me4 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '14.2.Me5' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1142me5 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '15.1' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1diag_15_1 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '15.2' .and. ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 14
          mdiag_15_1_1 := arr[ i, 2, 1 ]
          For k := 2 To 14
            If Len( arr[ i, 2 ] ) >= k
              mvar := 'm1diag_15_1_' + lstr( k )
              &mvar := arr[ i, 2, k ]
            Endif
          Next
        Case arr[ i, 1 ] == '15.3' .and. ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 14
          mdiag_15_2_1 := arr[ i, 2, 1 ]
          For k := 2 To 14
            If Len( arr[ i, 2 ] ) >= k
              mvar := 'm1diag_15_2_' + lstr( k )
              &mvar := arr[ i, 2, k ]
            Endif
          Next
        Case arr[ i, 1 ] == '15.4' .and. ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 14
          mdiag_15_3_1 := arr[ i, 2, 1 ]
          For k := 2 To 14
            If Len( arr[ i, 2 ] ) >= k
              mvar := 'm1diag_15_3_' + lstr( k )
              &mvar := arr[ i, 2, k ]
            Endif
          Next
        Case arr[ i, 1 ] == '15.5' .and. ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 14
          mdiag_15_4_1 := arr[ i, 2, 1 ]
          For k := 2 To 14
            If Len( arr[ i, 2 ] ) >= k
              mvar := 'm1diag_15_4_' + lstr( k )
              &mvar := arr[ i, 2, k ]
            Endif
          Next
        Case arr[ i, 1 ] == '15.6' .and. ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 14
          mdiag_15_5_1 := arr[ i, 2, 1 ]
          For k := 2 To 14
            If Len( arr[ i, 2 ] ) >= k
              mvar := 'm1diag_15_5_' + lstr( k )
              &mvar := arr[ i, 2, k ]
            Endif
          Next
        Case arr[ i, 1 ] == '15.9' .and. ValType( arr[ i, 2 ] ) == 'N'
          mGRUPPA_DO := arr[ i, 2 ]
        Case arr[ i, 1 ] == '15.10' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1GR_FIZ_DO := arr[ i, 2 ]
        Case arr[ i, 1 ] == '16.1' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1diag_16_1 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '16.2' .and. ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 16
          mdiag_16_1_1 := arr[ i, 2, 1 ]
          For k := 2 To 16
            If Len( arr[ i, 2 ] ) >= k
              mvar := 'm1diag_16_1_' + lstr( k )
              &mvar := arr[ i, 2, k ]
            Endif
          Next
        Case arr[ i, 1 ] == '16.3' .and. ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 16
          mdiag_16_2_1 := arr[ i, 2, 1 ]
          For k := 2 To 16
            If Len( arr[ i, 2 ] ) >= k
              mvar := 'm1diag_16_2_' + lstr( k )
              &mvar := arr[ i, 2, k ]
            Endif
          Next
        Case arr[ i, 1 ] == '16.4' .and. ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 16
          mdiag_16_3_1 := arr[ i, 2, 1 ]
          For k := 2 To 16
            If Len( arr[ i, 2 ] ) >= k
              mvar := 'm1diag_16_3_' + lstr( k )
              &mvar := arr[ i, 2, k ]
            Endif
          Next
        Case arr[ i, 1 ] == '16.5' .and. ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 16
          mdiag_16_4_1 := arr[ i, 2, 1 ]
          For k := 2 To 16
            If Len( arr[ i, 2 ] ) >= k
              mvar := 'm1diag_16_4_' + lstr( k )
              &mvar := arr[ i, 2, k ]
            Endif
          Next
        Case arr[ i, 1 ] == '16.6' .and. ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 16
          mdiag_16_5_1 := arr[ i, 2, 1 ]
          For k := 2 To 16
            If Len( arr[ i, 2 ] ) >= k
              mvar := 'm1diag_16_5_' + lstr( k )
              &mvar := arr[ i, 2, k ]
            Endif
          Next
        Case arr[ i, 1 ] == '16.7' .and. ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 8
          m1invalid1 := arr[ i, 2, 1 ]
          m1invalid2 := arr[ i, 2, 2 ]
          minvalid3  := arr[ i, 2, 3 ]
          minvalid4  := arr[ i, 2, 4 ]
          m1invalid5 := arr[ i, 2, 5 ]
          m1invalid6 := arr[ i, 2, 6 ]
          minvalid7  := arr[ i, 2, 7 ]
          m1invalid8 := arr[ i, 2, 8 ]
        Case arr[ i, 1 ] == '16.8' .and. ValType( arr[ i, 2 ] ) == 'N'
          // mGRUPPA := arr[i, 2]
        Case arr[ i, 1 ] == '16.9' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1GR_FIZ := arr[ i, 2 ]
        Case arr[ i, 1 ] == '16.10' .and. ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 3
          m1privivki1 := arr[ i, 2, 1 ]
          m1privivki2 := arr[ i, 2, 2 ]
          mprivivki3  := arr[ i, 2, 3 ]
        Case arr[ i, 1 ] == '16.11' .and. ValType( arr[ i, 2 ] ) == 'C'
          mrek_form := PadR( arr[ i, 2 ], 255 )
        Case arr[ i, 1 ] == '16.12' .and. ValType( arr[ i, 2 ] ) == 'C'
          mrek_disp := PadR( arr[ i, 2 ], 255 )
        Case is_all .and. arr[ i, 1 ] == '29' .and. ValType( arr[ i, 2 ] ) == 'A'
          arr_usl_otkaz := arr[ i, 2 ]
        Case arr[ i, 1 ] == '47'
          If ValType( arr[ i, 2 ] ) == 'N'
            m1dopo_na  := arr[ i, 2 ]
          Elseif ValType( arr[ i, 2 ] ) == 'A'
            m1dopo_na  := arr[ i, 2 ][ 1 ]
            If arr[ i, 2 ][ 2 ] > 0
              TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
              mtab_v_dopo_na := TPERS->tab_nom
            Endif
          Endif
        Case arr[ i, 1 ] == '51' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1p_otk  := arr[ i, 2 ]
        Case arr[ i, 1 ] == '52'
          If ValType( arr[ i, 2 ] ) == 'N'
            m1napr_v_mo  := arr[ i, 2 ]
          Elseif ValType( arr[ i, 2 ] ) == 'A'
            m1napr_v_mo  := arr[ i, 2 ][ 1 ]
            If arr[ i, 2 ][ 2 ] > 0
              TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
              mtab_v_mo := TPERS->tab_nom
            Endif
          Endif
        Case arr[ i, 1 ] == '53' .and. ValType( arr[ i, 2 ] ) == 'A'
          arr_mo_spec := arr[ i, 2 ]
        Case arr[ i, 1 ] == '54'
          If ValType( arr[ i, 2 ] ) == 'N'
            m1napr_stac := arr[ i, 2 ]
          Elseif ValType( arr[ i, 2 ] ) == 'A'
            m1napr_stac := arr[ i, 2 ][ 1 ]
            If arr[ i, 2 ][ 2 ] > 0
              TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
              mtab_v_stac := TPERS->tab_nom
            Endif
          Endif
        Case arr[ i, 1 ] == '55' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1profil_stac := arr[ i, 2 ]
        Case arr[ i, 1 ] == '56'
          If ValType( arr[ i, 2 ] ) == 'N'
            m1napr_reab := arr[ i, 2 ]
          Elseif ValType( arr[ i, 2 ] ) == 'A'
            m1napr_reab := arr[ i, 2 ][ 1 ]
            If arr[ i, 2 ][ 2 ] > 0
              TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
              mtab_v_reab := TPERS->tab_nom
            Endif
          Endif
        Case arr[ i, 1 ] == '57' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1profil_kojki := arr[ i, 2 ]
        Otherwise
          For k := 1 To Len( np_arr_issled( mdata ) )
            If arr[ i, 1 ] == '18.' + lstr( k ) .and. ValType( arr[ i, 2 ] ) == 'C'
              mvar := 'MREZi' + lstr( k )
              &mvar := PadR( arr[ i, 2 ], 17 )
            Endif
          Next
        Endcase
      Endif
    Endif
  Next
  If ! aliasIsUse
    TPERS->( dbCloseArea() )
    Select( oldSelect )
  Endif
  Return Nil

// 12.10.25
Function is_issled_pn( ausl, _period, arr, _pol, mdata )

  // ausl - {lshifr,mdate,hu_->profil,hu_->PRVS}

  Local i, s := '', fl := .f., lshifr := AllTrim( ausl[ 1 ] )
  local arr_pn_issled
  local arr_pn_zs

  arr_pn_issled := np_arr_issled( mdata )
  arr_pn_zs := np_arr_not_zs( mdata )
  If ( i := AScan( arr_pn_zs, {| x| x[ 2 ] == lshifr } ) ) > 0
    lshifr := arr_pn_zs[ i, 1 ]
  Endif
  For i := 1 To Len( arr_pn_issled )
    If arr_pn_issled[ i, 1 ] == lshifr
      s := '"' + lshifr + '.' + arr_pn_issled[ i, 3 ] + '"'
      If ValType( arr_pn_issled[ i, 2 ] ) == 'C' .and. !( arr_pn_issled[ i, 2 ] == _pol )
        AAdd( arr, 'Несовместимость по полу в услуге ' + s )
      Endif
      fl := .t.
      Exit
    Endif
  Next
  If fl .and. arr_pn_issled[ i, 4 ] < 2
    If AScan( np_arr_1_etap( mdata )[ _period, 5 ], lshifr ) == 0
      AAdd( arr, 'Некорректный возрастной период пациента для ' + s )
    Endif
    If ValType( arr_pn_issled[ i, 5 ] ) == 'N' .and. arr_pn_issled[ i, 5 ] != ausl[ 3 ]
      AAdd( arr, 'Не тот профиль в иссл-ии ' + s )
    Endif
  Endif
  Return fl

// 12.10.25
Function is_osmotr_pn( ausl, _period, arr, _etap, _pol, mdata, mobil )

  // ausl - {lshifr,mdate,hu_->profil,hu_->PRVS}

  Local i, j, s, fl := .f., fl_profil := .f., lshifr := AllTrim( ausl[ 1 ] )
  Local arr_PN_osmotr
  Local arr_not_zs

  arr_PN_osmotr := np_arr_osmotr( mdata, mobil )
  arr_not_zs := np_arr_not_zs( mdata )
  If eq_any( Left( lshifr, 4 ), '2.3.', '2.91' )
    fl_profil := .t.
  Elseif _etap == 1
    If ( i := AScan( arr_not_zs, {| x| x[ 2 ] == lshifr } ) ) > 0
      lshifr := arr_not_zs[ i, 1 ]
    Endif
  Elseif ( i := AScan( np_arr_osmotr_kdp2(), {| x| x[ 2 ] == lshifr } ) ) > 0
    lshifr := np_arr_osmotr_kdp2()[ i, 1 ]
  Endif
  For i := 1 To Len( arr_PN_osmotr )  // count_pn_arr_osm
    If _etap == 1 .or. fl_profil
      If ValType( arr_PN_osmotr[ i, 4 ] ) == 'N'
        If arr_PN_osmotr[ i, 4 ] == ausl[ 3 ]
          lshifr := arr_PN_osmotr[ i, 1 ] // искусственно
          fl := .t.
          Exit
        Endif
      Elseif ( j := AScan( arr_PN_osmotr[ i, 4 ], ausl[ 3 ] ) ) > 0
        lshifr := arr_PN_osmotr[ i, 1 ] // искусственно
        fl := .t.
        Exit
      Endif
    Else
      // if np_arr_osmotr[i, 1] == lshifr
      If arr_PN_osmotr[ i, 1 ] == lshifr
        fl := .t.
        Exit
      Endif
    Endif
  Next
  If fl
    s := '"' + lshifr + '.' + arr_PN_osmotr[ i, 3 ] + '"'
    If _etap == 1 .and. AScan( np_arr_1_etap( mdata, mobil )[ _period, 4 ], lshifr ) == 0
      AAdd( arr, 'Некорректный возрастной период пациента для ' + s )
    Endif
    If !Empty( arr_PN_osmotr[ i, 2 ] ) .and. !( arr_PN_osmotr[ i, 2 ] == _pol )
      AAdd( arr, 'Несовместимость по полу в услуге ' + s )
    Endif
    If ValType( arr_PN_osmotr[ i, 4 ] ) == 'N'
      If arr_PN_osmotr[ i, 4 ] != ausl[ 3 ]
        AAdd( arr, 'Не тот профиль в услуге ' + s )
      Endif
    Elseif ( j := AScan( arr_PN_osmotr[ i, 4 ], ausl[ 3 ] ) ) == 0
      AAdd( arr, 'Не тот профиль в услуге ' + s )
    Endif
  Endif
  Return fl

// 12.10.25 если услуга из 1 этапа
Function is_1_etap_pn( ausl, _period, _etap, mdata, mobil )

  // ausl - { lshifr,mdate,hu_->profil,hu_->PRVS }

  Local i, j, fl := .f., fl_profil := .f., lshifr := AllTrim( ausl[ 1 ] )
  Local arr_PN_osmotr
  local arr_pn_zs

  arr_PN_osmotr := np_arr_osmotr( mdata, mobil )
  arr_pn_zs := np_arr_not_zs( mdata )
  If eq_any( Left( lshifr, 4 ), '2.3.', '2.91' )
    fl_profil := .t.
  Elseif _etap == 1
    If ( i := AScan( arr_pn_zs, {| x| x[ 2 ] == lshifr } ) ) > 0
      lshifr := arr_pn_zs[ i, 1 ]
    Endif
  Elseif ( i := AScan( np_arr_osmotr_kdp2(), {| x| x[ 2 ] == lshifr } ) ) > 0
    lshifr := np_arr_osmotr_kdp2()[ i, 1 ]
  Endif
  For i := 1 To Len( arr_PN_osmotr )  // count_pn_arr_osm
    If _etap == 1 .or. fl_profil
      If ValType( arr_PN_osmotr[ i, 4 ] ) == 'N'
        If arr_PN_osmotr[ i, 4 ] == ausl[ 3 ]
          lshifr := arr_PN_osmotr[ i, 1 ] // искусственно
          fl := .t.
          Exit
        Endif
      Elseif ( j := AScan( arr_PN_osmotr[ i, 4 ], ausl[ 3 ] ) ) > 0
        lshifr := arr_PN_osmotr[ i, 1 ] // искусственно
        fl := .t.
        Exit
      Endif
    Else
      If arr_PN_osmotr[ i, 1 ] == lshifr
        fl := .t.
        Exit
      Endif
    Endif
  Next
  If fl
    fl := ( AScan( np_arr_1_etap( mData, mobil )[ _period, 4 ], lshifr ) > 0 )
  Endif
  Return fl

// 12.10.25
Function f_blank_usl_pn()

  Static arrv := { ;
    { 'Новорожденный', 1 }, ;
    { '1 месяц', 2 }, ;
    { '2 месяца', 3 }, ;
    { '3 месяца', 4 }, ;
    { '4 м., 5 м., 6 м., 7 м., 8 м., 9 м., 10 м., 11 м., 1 год 3 м., 1 год 6 м.', 5 }, ;
    { '1 год', 13 }, ;
    { '2 года', 16 }, ;
    { '3 года', 17 }, ;
    { '4 года, 5 лет, 8 лет, 9 лет, 11 лет, 12 лет', 18 }, ;
    { '6 лет', 20 }, ;
    { '7 лет', 21 }, ;
    { '10 лет', 24 }, ;
    { '13 лет', 27 }, ;
    { '14 лет', 28 }, ;
    { '15 лет', 29 }, ;
    { '16 лет', 30 }, ;
    { '17 лет', 31 };
    }
  Local i, mperiod, ar, s, buf := SaveScreen(), ret_arr[ 2 ]
  Local arr, arr_pn_issled
  local fr_data := '_data', fr_titl := '_titl'

  delfrfiles()
  arr_pn_issled := np_arr_issled( Date() )
  Do While ( mperiod := popup_2array( arrv, 3, 11, mperiod, 1, @ret_arr, ;
      'Вклыдыши услуг к л/у профилактики несовершеннолетних', 'B/W', color5 ) ) > 0
    dbCreate( fr_titl, { { 'name', 'C', 130, 0 } } )
    Use ( fr_titl ) New Alias FRT
    frt->( dbAppend() )
    frt->name := ret_arr[ 1 ]
    dbCreate( fr_data, { { 'name', 'C', 100, 0 } } )
    Use ( fr_data ) New Alias FRD
    np_oftal_2_85_21( mperiod, 0d20180901 )
    ar := np_arr_1_etap( Date() )[ mperiod ]
    If !Empty( ar[ 5 ] ) // не пустой массив исследований
      For i := 1 To Len( arr_pn_issled )
        If AScan( ar[ 5 ], arr_pn_issled[ i, 1 ] ) > 0
          s := arr_pn_issled[ i, 3 ]
          If ValType( arr_pn_issled[ i, 2 ] ) == 'C'
            s += ' (' + iif( arr_pn_issled[ i, 2 ] == 'М', 'мальчики', 'девочки' ) + ')'
          Endif
          frd->( dbAppend() )
          frd->name := s
        Endif
      Next
    Endif
    dbCreate( fr_data + '1', { { 'name', 'C', 100, 0 } } )
    Use ( fr_data + '1' ) New Alias FRD1
    arr := np_arr_osmotr( Date() )
    If !Empty( ar[ 4 ] ) // не пустой массив осмотров
      For i := 1 To Len( arr )
        If AScan( ar[ 4 ], arr[ i, 1 ] ) > 0
          s := arr[ i, 3 ]
          If ValType( arr[ i, 2 ] ) == 'C'
            s += ' (' + iif( arr[ i, 2 ] == 'М', 'мальчики', 'девочки' ) + ')'
          Endif
          frd1->( dbAppend() )
          frd1->name := s
        Endif
      Next
    Endif
    frd1->( dbAppend() )
    frd1->name := 'педиатр (врач общей практики)'
    dbCreate( fr_data + '2', { { 'name', 'C', 100, 0 } } )
    Use ( fr_data + '2' ) New Alias FRD2
    arr := np_arr_osmotr( Date() )
    For i := 1 To Len( arr )
      If AScan( ar[ 4 ], arr[ i, 1 ] ) == 0
        s := arr[ i, 3 ]
        If ValType( arr[ i, 2 ] ) == 'C'
          s += ' (' + iif( arr[ i, 2 ] == 'М', 'мальчики', 'девочки' ) + ')'
        Endif
        frd2->( dbAppend() )
        frd2->name := s
      Endif
    Next
    frd2->( dbAppend() )
    frd2->name := 'педиатр (врач общей практики)'
    dbCloseAll()
    call_fr( 'mo_b_pn1' )
  Enddo
  RestScreen( buf )
  Return Nil
