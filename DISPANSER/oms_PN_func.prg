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

// 16.10.25
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
    AAdd( arr, { '13.2.4', m1psih32 } )  // 
    AAdd( arr, { '13.2.5', m1psih33 } )  // 
    AAdd( arr, { '13.2.6', m1psih34 } )  // 
    AAdd( arr, { '13.2.7', m1psih35 } )  // 
    AAdd( arr, { '13.2.8', m1psih36 } )  // 
    AAdd( arr, { '13.2.9', m1psih37 } )  // 
    AAdd( arr, { '13.2.10', m1psih38 } )  // 
    AAdd( arr, { '13.2.11', m1psih39 } )  // 
    AAdd( arr, { '13.2.12', m1psih40 } )  // 
    AAdd( arr, { '13.2.13', m1psih41 } )  // 
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

// 16.10.25
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

        Case arr[ i, 1 ] == '13.2.4' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih32 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.2.5' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih33 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.2.6' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih34 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.2.7' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih35 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.2.8' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih36 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.2.9' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih37 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.2.10' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih38 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.2.11' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih39 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.2.12' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih40 := arr[ i, 2 ]
        Case arr[ i, 1 ] == '13.2.13' .and. ValType( arr[ i, 2 ] ) == 'N'
          m1psih41 := arr[ i, 2 ]

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

// 27.10.25
Function is_issled_pn( ausl, _period, arr, _pol, mdata )

  // ausl - {lshifr,mdate,hu_->profil,hu_->PRVS}

  Local i, s := '', fl := .f., lshifr // := AllTrim( ausl[ 1 ] )
  local arr_pn_issled
  local arr_pn_zs

  if ValType( ausl ) == 'A'
    lshifr := AllTrim( ausl[ 1 ] )
  else
    lshifr := AllTrim( ausl )
  endif
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

// 27.10.25
Function is_osmotr_pn( ausl, _period, arr, _etap, _pol, mdata, mobil )

  // ausl - {lshifr,mdate,hu_->profil,hu_->PRVS}

  Local i, j, s, fl := .f., fl_profil := .f., lshifr  // := AllTrim( ausl[ 1 ] )
  Local arr_PN_osmotr
  Local arr_not_zs

  if ValType( ausl ) == 'A'
    lshifr := AllTrim( ausl[ 1 ] )
  else
    lshifr := AllTrim( ausl )
  endif

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
//    If _etap == 1 .and. ( AScan( np_arr_1_etap( mdata, mobil )[ _period, 4 ], lshifr ) == 0 )
//      AAdd( arr, 'Некорректный возрастной период пациента для ' + s )
//    Endif
    If !Empty( arr_PN_osmotr[ i, 2 ] ) .and. !( arr_PN_osmotr[ i, 2 ] == _pol )
      AAdd( arr, 'Несовместимость по полу в услуге ' + s )
    Endif
    If ValType( arr_PN_osmotr[ i, 4 ] ) == 'N'
      If ( ValType( ausl ) == 'A' ) .and. ( arr_PN_osmotr[ i, 4 ] != ausl[ 3 ] )
        AAdd( arr, 'Не тот профиль в услуге ' + s )
      Endif
    Elseif ( ValType( ausl ) == 'A' ) .and. ( ( j := AScan( arr_PN_osmotr[ i, 4 ], ausl[ 3 ] ) ) == 0 )
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

// 18.10.25
Function f2_inf_dnl_karta( Loc_kod, kod_kartotek, lvozrast )

  Static st := '     ', ub := '<u><b>', ue := '</b></u>', sh := 88
  Local adbf, s, i, j, k, y, m, d, fl, mm_danet, blk := {| s| __dbAppend(), field->stroke := s }
  local mm_invalid5 := mm_invalid5()
  local mm_gr_fiz

  mm_gr_fiz := AClone( mm_gr_fiz_do() )
  AAdd( mm_gr_fiz, { 'не допущен', 0 } )

  delfrfiles()
  r_use( dir_server() + 'mo_stdds' )
  If Type( 'm1stacionar' ) == 'N' .and. m1stacionar > 0
    Goto ( m1stacionar )
  Endif
  r_use( dir_server() + 'kartote_',, 'KART_' )
  Goto ( kod_kartotek )
  r_use( dir_server() + 'kartotek',, 'KART' )
  Goto ( kod_kartotek )
  r_use( dir_server() + 'mo_pers',, 'P2' )
  Goto ( m1vrach )
  r_use( dir_server() + 'organiz',, 'ORG' )
  adbf := { ;
    { 'name', 'C', 130, 0 }, ;
    { 'prikaz', 'C', 50, 0 }, ;
    { 'forma', 'C', 50, 0 }, ;
    { 'titul', 'C', 100, 0 }, ;
    { 'fio', 'C', 50, 0 }, ;
    { 'k_data', 'C', 40, 0 }, ;
    { 'vrach', 'C', 40, 0 }, ;
    { 'glavn', 'C', 40, 0 } ;
  }
  dbCreate( fr_titl, adbf )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->name := glob_mo[ _MO_SHORT_NAME ]
  frt->fio := mfio
  frt->k_data := date_month( mk_data )
  frt->vrach := fam_i_o( p2->fio )
  frt->glavn := fam_i_o( org->ruk )
  adbf := { { 'stroke', 'C', 2000, 0 } }
  dbCreate( fr_data, adbf )
  Use ( fr_data ) New Alias FRD
  if mk_data < 0d20250901
    frt->prikaz := 'от 10 августа 2017 г. № 514н'
    frt->forma  := '030-ПО/у-17'
  else
    frt->prikaz := 'от 14 апреля 2025 г. № 211н'
    frt->forma  := '030-ПО/у'
  endif
  frt->titul  := 'Карта профилактического осмотра несовершеннолетнего'
  s := st + '1. Фамилия, имя, отчество (при наличии) несовершеннолетнего: ' + ub + AllTrim( mfio ) + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + 'Пол: ' + f3_inf_dds_karta( { { 'муж.', 'М' }, { 'жен.', 'Ж' } }, mpol, '/', ub, ue )
  frd->( Eval( blk, s ) )
  s := st + 'Дата рождения: ' + ub + date_month( mdate_r, .t. ) + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + '2. Полис обязательного медицинского страхования: '
  s += 'серия ' + iif( Empty( mspolis ), Replicate( '_', 15 ), ub + AllTrim( mspolis ) + ue )
  s += ' № ' + ub + AllTrim( mnpolis ) + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + 'Страховая медицинская организация: ' + ub + AllTrim( mcompany ) + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + '3. Страховой номер индивидуального лицевого счета: '
//  s += iif( Empty( kart->snils ), Replicate( '_', 25 ), ub + Transform( kart->SNILS, picture_pf ) + ue ) + '.'
  s += iif( Empty( kart->snils ), Replicate( '_', 25 ), ub + Transform_SNILS( kart->SNILS ) + ue ) + '.'
  frd->( Eval( blk, s ) )
  s := st + '4. Адрес места жительства (пребывания): '
  If emptyall( kart_->okatog, kart->adres )
    s += Replicate( '_', 37 ) + ' ' + Replicate( '_', sh ) + '.'
  Else
    s += ub + ret_okato_ulica( kart->adres, kart_->okatog, 1, 2 ) + ue + '.'
  Endif
  frd->( Eval( blk, s ) )
  s := st + '5. Категория: ' + f3_inf_dds_karta( mm_kateg_uch(), m1kateg_uch, '; ', ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '6. Полное наименование медицинской организации, в которой ' + ;
    'несовершеннолетний получает первичную медико-санитарную помощь: '
  s += ub + ret_mo( m1MO_PR )[ _MO_FULL_NAME ] + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + '7. Адрес места нахождения медицинской организации, в которой ' + ;
    'несовершеннолетний получает первичную медико-санитарную помощь: '
  s += ub + ret_mo( m1MO_PR )[ _MO_ADRES ] + ue + '.'
  frd->( Eval( blk, s ) )
  madresschool := ''
  If Type( 'm1school' ) == 'N' .and. m1school > 0
    r_use( dir_server() + 'mo_schoo',, 'SCH' )
    Goto ( m1school )
    If !Empty( sch->fname )
      mschool := AllTrim( sch->fname )
      madresschool := AllTrim( sch->adres )
    Endif
  Endif
  s := st + '8. Полное наименование образовательной организации, в которой ' + ;
    'обучается несовершеннолетний: ' + ub + mschool + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + '9. Адрес места нахождения образовательной организации, в которой ' + ;
    'обучается несовершеннолетний: '
  If Empty( madresschool )
    frd->( Eval( blk, s ) )
    s := Replicate( '_', sh ) + '.'
  Else
    s += ub + madresschool + ue + '.'
  Endif
  frd->( Eval( blk, s ) )
  s := st + '10. Дата начала профилактического медицинского осмотра несовершеннолетнего (далее - профилактический осмотр): ' + ub + full_date( mn_data ) + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + '11. Полное наименование и адрес места нахождения медицинской организации, ' + ;
    'проводившей профилактический осмотр: ' + ;
    ub + glob_mo[ _MO_FULL_NAME ] + ', ' + glob_mo[ _MO_ADRES ] + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + '12. Оценка физического развития с учетом возраста на момент профилактического осмотра:'
  frd->( Eval( blk, s ) )
  count_ymd( mdate_r, mn_data, @y, @m, @d )
  s := ub + st + lstr( d ) + st + ue + ' (число дней) ' + ;
    ub + st + lstr( m ) + st + ue + ' (месяцев) ' + ;
    ub + st + lstr( y ) + st + ue + ' лет.'
  frd->( Eval( blk, s ) )
  mm_fiz_razv1 := { { 'дефицит массы тела', 1 }, { 'избыток массы тела', 2 } }
  mm_fiz_razv2 := { { 'низкий рост', 1 }, { 'высокий рост', 2 } }
  For i := 1 To 2
    s := st + '12.' + lstr( i ) + '. Для детей в возрасте ' + ;
      { '0 - 4 лет: ', '5 - 17 лет включительно: ' }[ i ]
    If i == 1
      fl := ( lvozrast < 5 )
    Else
      fl := ( lvozrast > 4 )
    Endif
    s += 'масса (кг) ' + iif( !fl, '________', ub + st + lstr( mWEIGHT ) + st + ue ) + '; '
    s += 'рост (см) ' + iif( !fl, '________', ub + st + lstr( mHEIGHT ) + st + ue ) + '; '
    If i == 1
      s += 'окружность головы (см) ' + iif( !fl .or. mPER_HEAD == 0, '________', ub + st + lstr( mPER_HEAD ) + st + ue ) + '; '
    Endif
    s += 'физическое развитие ' + f3_inf_dds_karta( mm_fiz_razv(), iif( fl, m1FIZ_RAZV, -1 ),, ub, ue, .f. )
    s += ' (' + f3_inf_dds_karta( mm_fiz_razv1, iif( fl, m1FIZ_RAZV1, -1 ),, ub, ue, .f. )
    s += ', ' + f3_inf_dds_karta( mm_fiz_razv2, iif( fl, m1FIZ_RAZV2, -1 ),, ub, ue, .f. )
    s += ' - нужное подчеркнуть).'
    frd->( Eval( blk, s ) )
  Next
  rep_psih_health_and_sex( lvozrast, mk_data, TIP_LU_PN )
/*
  fl := ( lvozrast < 5 )
  s := st + '13. Оценка психического развития (состояния):'
  frd->( Eval( blk, s ) )
  if mk_data < 0d20250901
    s := st + '13.1. Для детей в возрасте 0 - 4 лет:'
    frd->( Eval( blk, s ) )
    s := st + 'познавательная функция (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih11 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'моторная функция (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih12 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih13 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'предречевое и речевое развитие (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih14 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    fl := ( lvozrast > 4 )
    s := st + '13.2. Для детей в возрасте 5 - 17 лет:'
    frd->( Eval( blk, s ) )
    s := st + '13.2.1. Психомоторная сфера: ' + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih21, -1 ),, ub, ue )
    frd->( Eval( blk, s ) )
    s := st + '13.2.2. Интеллект: ' + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih22, -1 ),, ub, ue )
    frd->( Eval( blk, s ) )
    s := st + '13.2.3. Эмоционально-вегетативная сфера: ' + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih23, -1 ),, ub, ue )
    frd->( Eval( blk, s ) )
  else
    s := st + '13.1. Для детей в возрасте 0 - 4 лет:'
    frd->( Eval( blk, s ) )
    s := st + 'познавательная функция (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih11 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'нарушение когнитивных функций ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih24 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'нарушение учебных навыков ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih25 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'моторная функция (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih12 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'эмоциональные нарушения ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih26 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'предречевое развитие ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_activ(), m1psih27 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + 'речевое развитие (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih14 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + 'понимание речи ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_partial(), m1psih28 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + 'активная речь ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_used(), m1psih29 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + 'нарушение коммуникативных навыков ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih30 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + 'сенсорное развитие ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_sensor(), m1psih31 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    fl := ( lvozrast > 4 )
    s := st + '13.2. Для детей в возрасте 5 - 17 лет:'
    frd->( Eval( blk, s ) )
    s := st + 'внешний вид ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_view_obraz(), m1psih32 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'доступен к контакту ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_contact(), m1psih33 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'фон настроения ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_nastroenie(), m1psih34 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'обманы восприятия ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih35 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'интеллектуальная функция ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_intelect(), m1psih36 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'нарушения когнитивных функций ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih37 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'нарушение учебных навыков ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih38 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'суицидальные наклонности ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih39 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'самоповреждения ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_self_harm(), m1psih40 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'социальная сфера ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_socium(), m1psih41 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
  endif
  fl := ( mpol == 'М' .and. lvozrast > 9 )
  s := st + '14. Оценка полового развития (с 10 лет):'
  frd->( Eval( blk, s ) )
  s := st + '14.1. Половая формула мальчика: Р ' + iif( !fl .or. m141p == 0, '________', ub + st + lstr( m141p ) + st + ue )
  s += ' Ах ' + iif( !fl .or. m141ax == 0, '________', ub + st + lstr( m141ax ) + st + ue )
  s += ' Fa ' + iif( !fl .or. m141fa == 0, '________', ub + st + lstr( m141fa ) + st + ue ) + '.'
  frd->( Eval( blk, s ) )
  fl := ( mpol == 'Ж' .and. lvozrast > 9 )
  s := st + '14.2. Половая формула девочки: Р ' + iif( !fl .or. m142p == 0, '________', ub + st + lstr( m142p ) + st + ue )
  s += ' Ах ' + iif( !fl .or. m142ax == 0, '________', ub + st + lstr( m142ax ) + st + ue )
  s += ' Ma ' + iif( !fl .or. m142ma == 0, '________', ub + st + lstr( m142ma ) + st + ue )
  s += ' Me ' + iif( !fl .or. m142me == 0, '________', ub + st + lstr( m142me ) + st + ue ) + ';'
  frd->( Eval( blk, s ) )
  s := st + 'характеристика менструальной функции: menarhe ('
  s += iif( !fl .or. m142me1 == 0, '________', ub + st + lstr( m142me1 ) + st + ue ) + ' лет, '
  s += iif( !fl .or. m142me2 == 0, '________', ub + st + lstr( m142me2 ) + st + ue ) + ' месяцев); '
  If fl .and. emptyall( m142p, m142ax, m142ma, m142me, m142me1, m142me2 )
    m1142me3 := m1142me4 := m1142me5 := -1
  Endif
  s += 'menses (характеристика): ' + f3_inf_dds_karta( mm_142me3(), iif( fl, m1142me3, -1 ),, ub, ue, .f. )
  s += ', ' + f3_inf_dds_karta( mm_142me4(), iif( fl, m1142me4, -1 ),, ub, ue, .f. )
  s += ', ' + f3_inf_dds_karta( mm_142me5(), iif( fl, m1142me5, -1 ), ' и ', ub, ue )
  frd->( Eval( blk, s ) )
*/
  s := st + '15. Состояние здоровья до проведения настоящего профилактического осмотра:'
  frd->( Eval( blk, s ) )
  If lvozrast < 14
    mdef_diagnoz := 'Z00.1'
  Else
    mdef_diagnoz := 'Z00.3'
  Endif
  s := st + '15.1. Практически здоров ' + iif( m1diag_15_1 == 0, Replicate( '_', 30 ), ub + st + RTrim( mdef_diagnoz ) + st + ue ) + ' (код по МКБ).'
  frd->( Eval( blk, s ) )
  //
  mm_dispans := { { 'установлено ранее', 1 }, { 'установлено впервые', 2 }, { 'не установлено', 0 } }
  mm_danet := { { 'да', 1 }, { 'нет', 0 } }
  mm_usl := { { 'в амбулаторных условиях', 0 }, ;
    { 'в условиях дневного стационара', 1 }, ;
    { 'в стационарных условиях', 2 } }
  mm_uch := { { 'в муниципальных медицинских организациях', 1 }, ;
    { 'в государственных медицинских организациях субъекта Российской Федерации ', 0 }, ;
    { 'в федеральных медицинских организациях', 2 }, ;
    { 'частных медицинских организациях', 3 } }
  mm_uch1 := AClone( mm_uch )
  AAdd( mm_uch1, { 'санаторно-курортных организациях', 4 } )
  mm_danet1 := { { 'оказана', 1 }, { 'не оказана', 0 } }
  For i := 1 To 5
    fl := .f.
    For k := 1 To 14
      mvar := 'mdiag_15_' + lstr( i ) + '_' + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_15_1 == 0
      Else
        m1var := 'm1diag_15_' + lstr( i ) + '_' + lstr( k )
        If fl
          Do Case
          Case eq_any( k, 4, 5, 6, 7 )
            mvar := 'm1diag_15_' + lstr( i ) + '_3'
            if &mvar != 1 // если не 'да'
              &m1var := -1
            Endif
          Case eq_any( k, 9, 10, 11, 12 )
            mvar := 'm1diag_15_' + lstr( i ) + '_8'
            if &mvar != 1 // если не 'да'
              &m1var := -1
            Endif
          Case k == 14
            mvar := 'm1diag_15_' + lstr( i ) + '_13'
            if &mvar != 1 // если не 'да'
              &m1var := -1
            Endif
          Endcase
        Else
          &m1var := -1
        Endif
      Endif
    Next
  Next
  For i := 1 To 5
    fl := .f.
    s := s1 := s2 := s3 := s4 := s5 := s6 := ''
    For k := 1 To 2
      mvar := 'mdiag_15_' + lstr( i ) + '_' + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_15_1 == 0
      Else
        m1var := 'm1diag_15_' + lstr( i ) + '_' + lstr( k )
        If ( j := &m1var ) > 0
          j := 1
        Endif
      Endif
      Do Case
      Case k == 1
        s := st + '15.' + lstr( i + 1 ) + '. Диагноз ' + iif( !fl, Replicate( '_', 30 ), ub + st + RTrim( &mvar ) + st + ue ) + ' (код по МКБ).'
      Case k == 2
        s1 := st + '15.' + lstr( i + 1 ) + '.1. Диспансерное наблюдение установлено: ' + f3_inf_dds_karta( mm_danet, j,, ub, ue )
      Endcase
    Next
    frd->( Eval( blk, s ) )
    frd->( Eval( blk, s1 ) )
  Next
  mm_gruppa := { { 'I', 1 }, { 'II', 2 }, { 'III', 3 }, { 'IV', 4 }, { 'V', 5 } }
  s := st + '15.7. Группа состояния здоровья: ' + f3_inf_dds_karta( mm_gruppa, mGRUPPA_DO,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '15.8. Медицинская группа для занятий физической культурой: ' + f3_inf_dds_karta( mm_gr_fiz_do(), m1GR_FIZ_DO,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '16. Состояние здоровья по результатам проведения настоящего профилактического осмотра:'
  frd->( Eval( blk, s ) )
  s := st + '16.1. Практически здоров ' + iif( m1diag_16_1 == 0, Replicate( '_', 30 ), ub + st + RTrim( mkod_diag ) + st + ue ) + ' (код по МКБ).'
  frd->( Eval( blk, s ) )
  For i := 1 To 5
    fl := .f.
    For k := 1 To 16
      mvar := 'mdiag_16_' + lstr( i ) + '_' + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_16_1 == 0
      Else
        m1var := 'm1diag_16_' + lstr( i ) + '_' + lstr( k )
        If fl
          Do Case
          Case eq_any( k, 5, 6 )
            mvar := 'm1diag_16_' + lstr( i ) + '_4'
            if &mvar != 1 // если не 'да'
              &m1var := -1
            Endif
          Case eq_any( k, 8, 9 )
            mvar := 'm1diag_16_' + lstr( i ) + '_7'
            if &mvar != 1 // если не 'да'
              &m1var := -1
            Endif
          Case eq_any( k, 11, 12 )
            mvar := 'm1diag_16_' + lstr( i ) + '_10'
            if &mvar != 1 // если не 'да'
              &m1var := -1
            Endif
          Case eq_any( k, 14, 15 )
            mvar := 'm1diag_16_' + lstr( i ) + '_13'
            if &mvar != 1 // если не 'да'
              &m1var := -1
            Endif
          Endcase
        Else
          &m1var := -1
        Endif
      Endif
    Next
  Next
  For i := 1 To 5
    fl := .f.
    s := s1 := s2 := s3 := s4 := s5 := s6 := s7 := ''
    For k := 1 To 15
      mvar := 'mdiag_16_' + lstr( i ) + '_' + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_16_1 == 0
      Else
        m1var := 'm1diag_16_' + lstr( i ) + '_' + lstr( k )
      Endif
      Do Case
      Case k == 1
        s := st + '16.' + lstr( i + 1 ) + '. Диагноз ' + iif( !fl, Replicate( '_', 30 ), ub + st + RTrim( &mvar ) + st + ue ) + ' (код по МКБ).'
      Case k == 2
        s1 := st + '16.' + lstr( i + 1 ) + '.1. Диагноз установлен впервые: ' + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 3
        s2 := st + '16.' + lstr( i + 1 ) + '.2. Диспансерное наблюдение: ' + f3_inf_dds_karta( mm_dispans, &m1var,, ub, ue )
      Case k == 4
        s3 := st + '16.' + lstr( i + 1 ) + '.3. Дополнительные консультации и исследования назначены: ' + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 5
        s3 := Left( s3, Len( s3 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 6
        s3 := Left( s3, Len( s3 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 7
        s4 := st + '16.' + lstr( i + 1 ) + '.4. Дополнительные консультации и исследования выполнены: ' + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 8
        s4 := Left( s4, Len( s4 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 9
        s4 := Left( s4, Len( s4 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 10
        s5 := st + '16.' + lstr( i + 1 ) + '.5. Лечение назначено: ' + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 11
        s5 := Left( s5, Len( s5 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 12
        s5 := Left( s5, Len( s5 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 13
        s6 := st + '16.' + lstr( i + 1 ) + '.6. Медицинская реабилитация и (или) санаторно-курортное лечение назначены: ' + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 14
        s6 := Left( s6, Len( s6 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 15
        s6 := Left( s6, Len( s6 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch1, &m1var,, ub, ue )
      Endcase
    Next
    frd->( Eval( blk, s ) )
    frd->( Eval( blk, s1 ) )
    frd->( Eval( blk, s2 ) )
    frd->( Eval( blk, s3 ) )
    frd->( Eval( blk, s4 ) )
    frd->( Eval( blk, s5 ) )
    frd->( Eval( blk, s6 ) )
  Next
  If m1invalid1 == 0
    m1invalid2 := m1invalid5 := m1invalid6 := m1invalid8 := -1
    minvalid3 := minvalid4 := minvalid7 := CToD( '' )
  Endif
  If Empty( minvalid7 )
    m1invalid8 := -1
  Endif
  s := st + '16.7. Инвалидность: ' + f3_inf_dds_karta( mm_danet, m1invalid1,, ub, ue )
  s := Left( s, Len( s ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_invalid2(), m1invalid2,, ub, ue )
  s := Left( s, Len( s ) -1 ) + '; установлена впервые (дата) ' + iif( Empty( minvalid3 ), Replicate( '_', 15 ), ub + full_date( minvalid3 ) + ue )
  s += '; дата последнего освидетельствования ' + iif( Empty( minvalid4 ), Replicate( '_', 15 ), ub + full_date( minvalid4 ) + ue ) + '.'
  frd->( Eval( blk, s ) )
/*s := st+'16.7.1. Заболевания, обусловившие возникновение инвалидности:'
frd->(eval(blk,s))
mm_invalid5[6, 1] := 'болезни крови, кроветворных органов и отдельные нарушения, вовлекающие иммунный механизм;'
mm_invalid5[7, 1] := 'болезни эндокринной системы, расстройства питания и нарушения обмена веществ,'
atail(mm_invalid5)[1] := 'последствия травм, отравлений и других воздействий внешних причин)'
s := st+'(' + f3_inf_DDS_karta(mm_invalid5,m1invalid5,' ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.2.Виды нарушений в состоянии здоровья:'
frd->(eval(blk,s))
s := st + f3_inf_DDS_karta(mm_invalid6(),m1invalid6,'; ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.3. Индивидуальная программа реабилитации ребенка-инвалида:'
frd->(eval(blk,s))
s := st+'дата назначения: '+iif(empty(minvalid7), replicate('_', 15), ub + full_date(minvalid7)+ue)+';'
frd->(eval(blk,s))
s := st+'выполнение на момент диспансеризации: ' + f3_inf_DDS_karta(mm_invalid8(),m1invalid8,,ub,ue)
frd->(eval(blk,s))*/
  s := st + '16.8. Группа состояния здоровья: ' + f3_inf_dds_karta( mm_gruppa, mGRUPPA,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '16.9. Медицинская группа для занятий физической культурой: '
  s += f3_inf_dds_karta( mm_gr_fiz, m1GR_FIZ,, ub, ue )
  frd->( Eval( blk, s ) )
/*s := st+'16.10'+'. Проведение профилактических прививок:'
frd->(eval(blk,s))
s := st
for j := 1 to len(mm_privivki1())
  if m1privivki1 == mm_privivki1()[j, 2]
    s += ub
  endif
  s += mm_privivki1()[j, 1]
  if m1privivki1 == mm_privivki1()[j, 2]
    s += ue
  endif
  if mm_privivki1()[j, 2] == 0
    s += '; '
  else
    s += ': ' + f3_inf_DDS_karta(mm_privivki2(),iif(m1privivki1==mm_privivki1()[j, 2],m1privivki2,-1),,ub,ue,.f.)+'; '
  endif
next
s += 'нуждается в проведении вакцинации (ревакцинации) с указанием наименования прививки (нужное подчеркнуть): '
if m1privivki1 > 0 .and. !empty(mprivivki3)
  s += ub+alltrim(mprivivki3)+ue
endif
frd->(eval(blk,s))
s := replicate('_',sh)+'.'
frd->(eval(blk,s))*/
  s := st + '17. Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой: '
  k := 3
  If !Empty( mrek_form )
    k := 1
    s += ub + AllTrim( mrek_form ) + ue
  Endif
  frd->( Eval( blk, s ) )
  For i := 1 To k
    s := Replicate( '_', sh ) + iif( i == k, '.', '' )
    frd->( Eval( blk, s ) )
  Next
  s := st + '18. Рекомендации по проведению диспансерного наблюдения, ' + ;
    'лечению, медицинской реабилитации и санаторно-курортному лечению: '
  k := 5
  If !Empty( mrek_disp )
    k := 2
    s += ub + AllTrim( mrek_disp ) + ue
  Endif
  frd->( Eval( blk, s ) )
  For i := 1 To k
    s := Replicate( '_', sh ) + iif( i == k, '.', '' )
    frd->( Eval( blk, s ) )
  Next
  //
  adbf := { { 'name', 'C', 60, 0 }, ;
    { 'data', 'C', 10, 0 }, ;
    { 'rezu', 'C', 17, 0 } }
  dbCreate( fr_data + '1', adbf )
  Use ( fr_data + '1' ) New Alias FRD1
  dbCreate( fr_data + '2', adbf )
  Use ( fr_data + '2' ) New Alias FRD2
/*arr := f4_inf_DNL_karta(1)
for i := 1 to len(arr)
  select FRD1
  append blank
  frd1->name := arr[i, 1]
  frd1->data := full_date(arr[i, 2])
next
arr := f4_inf_DNL_karta(2)
for i := 1 to len(arr)
  select FRD2
  append blank
  frd2->name := arr[i, 1]
  frd2->data := full_date(arr[i, 2])
  frd2->rezu := arr[i, 3]
next*/
  //
  Close databases
  call_fr( 'mo_030pou17' )

  Return Nil

