#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 07.02.23
Function fget_spec_deti( k, r, c, a_spec )

  Local tmp_select := Select(), i, j, as := {}, s, blk, t_arr[ BR_LEN ], n_file := cur_dir() + 'tmpspecdeti'
  Local arr_conv_V015_V021 := conversion_v015_v021()

  If !hb_FileExists( n_file + sdbf() )
    If Select( 'MOSPEC' ) == 0
      r_use( dir_exe() + '_mo_spec', cur_dir() + '_mo_spec', 'MOSPEC' )
    Endif
    Select MOSPEC
    find ( '2.' )
    Do While Left( mospec->shifr, 2 ) == '2.' .and. !Eof()
      If mospec->vzros_reb == 1 // дети
        If AScan( as, mospec->prvs_new ) == 0
          AAdd( as, mospec->prvs_new )
        Endif
      Endif
      Skip
    Enddo
    If Select( 'MOSPEC' ) > 0
      mospec->( dbCloseArea() )
    Endif
    For i := 1 To Len( as )
      If ( j := AScan( arr_conv_V015_V021, {| x| x[ 2 ] == as[ i ] } ) ) > 0 // перевод из 21-го справочника
        as[ i ] := arr_conv_V015_V021[ j, 1 ]                          // в 15-ый справочник
      Endif
    Next
    dbCreate( n_file, { { 'name', 'C', 30, 0 }, ;
      { 'kod', 'C', 4, 0 }, ;
      { 'kod_up', 'C', 4, 0 }, ;
      { 'name1', 'C', 50, 0 }, ;
      { 'is', 'L', 1, 0 } } )
    Use ( n_file ) New Alias SDVN
    Use ( cur_dir() + 'tmp_v015' ) index ( cur_dir() + 'tmpkV015' ) New Alias tmp_ga
    Go Top
    Do While !Eof()
      If ( i := AScan( as, Int( Val( tmp_ga->kod ) ) ) ) > 0
        Select SDVN
        Append Blank
        sdvn->name := AfterAtNum( '.', tmp_ga->name, 1 )
        sdvn->kod := tmp_ga->kod
        s := ''
        Select TMP_GA
        rec := RecNo()
        Do While !Empty( tmp_ga->kod_up )
          find ( tmp_ga->kod_up )
          If Found()
            s += AllTrim( AfterAtNum( '.', tmp_ga->name, 1 ) ) + '/'
          Else
            Exit
          Endif
        Enddo
        Goto ( rec )
        sdvn->name1 := s
      Endif
      Skip
    Enddo
    sdvn->( dbCloseArea() )
    tmp_ga->( dbCloseArea() )
  Endif
  Use ( n_file ) New Alias tmp_ga
  Do While !Eof()
    tmp_ga->is := ( AScan( a_spec, Int( Val( tmp_ga->kod ) ) ) > 0 )
    Skip
  Enddo
  Index On Upper( name ) + kod to ( n_file )
  If r <= MaxRow() / 2
    t_arr[ BR_TOP ] := r + 1
    t_arr[ BR_BOTTOM ] := MaxRow() -2
  Else
    t_arr[ BR_BOTTOM ] := r -1
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
  Go Top
  edit_browse( t_arr )
  s := ''
  ASize( a_spec, 0 )
  Go Top
  Do While !Eof()
    If tmp_ga->is
      s += AllTrim( tmp_ga->kod ) + ','
      AAdd( a_spec, Int( Val( tmp_ga->kod ) ) )
    Endif
    Skip
  Enddo
  If Empty( s )
    s := '---'
  Else
    s := Left( s, Len( s ) -1 )
  Endif
  tmp_ga->( dbCloseArea() )
  Select ( tmp_select )
  Return { 1, s }

// 05.09.21
Function save_arr_pn( lkod )

  Local arr := {}, k, ta
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect

  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'TPERS' )
  Endif

  Private mvar
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
  Else
    AAdd( arr, { '13.2.1', m1psih21 } )  // 'N1',Психомоторная сфера: (норма, отклонение)
    AAdd( arr, { '13.2.2', m1psih22 } )  // 'N1',Интеллект: (норма, отклонение)
    AAdd( arr, { '13.2.3', m1psih23 } )  // 'N1',Эмоционально-вегетативная сфера: (норма, отклонение)
  Endif
  If mpol == 'М'
    AAdd( arr, { '14.1.P',m141p } )     // 'N1',Половая формула мальчика
    AAdd( arr, { '14.1.Ax',m141ax } )   // 'N1',Половая формула мальчика
    AAdd( arr, { '14.1.Fa',m141fa } )   // 'N1',Половая формула мальчика
  Else
    AAdd( arr, { '14.2.P',m142p } )     // 'N1',Половая формула девочки
    AAdd( arr, { '14.2.Ax',m142ax } )   // 'N1',Половая формула девочки
    AAdd( arr, { '14.2.Ma',m142ma } )   // 'N1',Половая формула девочки
    AAdd( arr, { '14.2.Me',m142me } )   // 'N1',Половая формула девочки
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
  For i := 1 To count_pn_arr_iss
    mvar := 'MREZi' + lstr( i )
    If !Empty( &mvar )
      AAdd( arr, { '18.' + lstr( i ), AllTrim( &mvar ) } )
    Endif
  Next
  If !Empty( arr_usl_otkaz )
    AAdd( arr, { '29', arr_usl_otkaz } ) // массив
  Endif
  If mk_data >= 0d20210801
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
  If mk_data >= 0d20210801
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
  If mk_data >= 0d20210801
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
  If mk_data >= 0d20210801
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

// 05.09.21
Function read_arr_pn( lkod, is_all )

  Local arr, i, k
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect

  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server() + 'mo_pers',, 'TPERS' )
  Endif

  Default is_all To .t.
  Private mvar
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
          For k := 1 To count_pn_arr_iss
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
