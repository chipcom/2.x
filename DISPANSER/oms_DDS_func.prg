#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 25.09.25 является врачебным осмотром детей-сирот на первом этапе
Function is_osmotr_DDS_1_etap( ausl, _vozrast, _etap, _pol, tip_lu, mdata )
  
  // ausl - { lshifr,mdate,hu_->profil,hu_->PRVS }

  Local i, fl := .f., lshifr := alltrim(ausl[1])
  local arr_DDS_osm1

  arr_DDS_osm1 := dds_arr_osm1( mdata )
  // вместо услуг "2.87.*" сделаем "2.83.*"
  if tip_lu == TIP_LU_DDSOP .and. left(lshifr, 5) == '2.87.'
    lshifr := '2.83.' + substr(lshifr, 6)
  endif
  for i := 1 to Len( arr_DDS_osm1 )
    if iif( empty( arr_DDS_osm1[ i, 2 ] ), .t., arr_DDS_osm1[ i, 2 ] == _pol ) .and. ;
                           between(_vozrast, arr_DDS_osm1[ i, 3 ], arr_DDS_osm1[ i, 4 ] )
      if _etap == 1
        if ascan( arr_DDS_osm1[ i, 5 ], ausl[ 3 ] ) > 0
          fl := .t.
          exit
        endif
      else
        if ascan( arr_DDS_osm1[ i, 7 ], lshifr ) > 0
          fl := .t.
          exit
        endif
      endif
    endif
  next
  return fl

// 25.09.25 является врачебным осмотром детей-сирот
Function is_osmotr_DDS( ausl, _vozrast, arr, _etap, _pol, tip_lu, mdata )
  
  // ausl - { lshifr,mdate,hu_->profil,hu_->PRVS }

  Local i, j, s, fl := .f., lshifr := alltrim(ausl[1])
  local arr_DDS_osm1
  local arr_DDS_osm2

  arr_DDS_osm1 := dds_arr_osm1( mdata )
  arr_DDS_osm2 := dds_arr_osm2( mdata )

  // вместо услуг "2.87.*" сделаем "2.83.*"
  if tip_lu == TIP_LU_DDSOP .and. left(lshifr, 5) == '2.87.'
    lshifr := '2.83.' + substr(lshifr, 6)
  endif
  if _etap == 2 .and. (j := ascan(dds_arr_osmotr_KDP2(), {|x| x[2] == lshifr})) > 0
    lshifr := dds_arr_osmotr_KDP2()[j, 1]
  endif
  for i := 1 to Len( arr_DDS_osm1 )
    if _etap == 1
      if ascan( arr_DDS_osm1[ i, 5 ], ausl[ 3 ] ) > 0
        fl := .t.
        exit
      endif
    else
      if ascan( arr_DDS_osm1[ i, 7 ], lshifr ) > 0
        fl := .t.
        exit
      endif
    endif
  next
  if fl
    s := '"' + lshifr + '.' + arr_DDS_osm1[i, 1] + '"'
    /*
    if !between( _vozrast, dds_arr_osm1( mdata )[ i, 3 ], dds_arr_osm1( mdata )[ i, 4 ] )
      aadd( arr, 'Некорректный возраст пациента для услуги ' + s )
    endif
    */
    if !empty( arr_DDS_osm1[ i, 2 ] ) .and. !( arr_DDS_osm1[ i, 2 ] == _pol)
      aadd( arr, 'Несовместимость по полу в услуге ' + s)
    endif
    if ascan( arr_DDS_osm1[ i, 5 ], ausl[ 3 ] ) == 0
      aadd( arr, 'Не тот профиль в услуге ' + s)
    endif
    /*
    if ascan( dds_arr_osm1( mdata )[ i, 6 ], ausl[ 4 ] ) == 0
      aadd( arr, 'Не та специальность врача в услуге ' + s )
      aadd(arr,' у Вас: ' + lstr( ausl[ 4 ] ) + ', разрешено: ' + print_array( dds_arr_osm1( mdata )[ i, 6 ] ) )
    endif
    */
  endif
  if !fl .and. _etap == 2
    for i := 1 to Len( arr_DDS_osm2 )
      if ascan( arr_DDS_osm2[ i, 7 ], lshifr ) > 0 .and. ascan( arr_DDS_osm2[ i, 5 ], ausl[ 3 ] ) > 0
        fl := .t.
        exit
      endif
    next
    if fl
      s := '"' + lshifr + '.' + arr_DDS_osm2[ i, 1 ] + '"'
      if !between( _vozrast, arr_DDS_osm2[ i, 3 ], arr_DDS_osm2[ i, 4 ] )
        aadd( arr, 'Некорректный возраст пациента для услуги ' + s )
      endif
      if ascan( arr_DDS_osm2[ i, 5 ], ausl[ 3 ] ) == 0
        aadd( arr, 'Не тот профиль в услуге ' + s )
      endif
      /*
      if ascan( arr_DDS_osm2[ i, 6 ], ausl[ 4 ]) == 0
        aadd( arr, 'Не та специальность врача в услуге ' + s )
        aadd( arr, ' у Вас: ' + lstr( ausl[ 4 ] ) + ', разрешено: ' + print_array( arr_DDS_osm2[ i, 6 ] ) )
      endif
      */
    endif
  endif
  return fl

// 25.09.25 является исследованием детей-сирот
Function is_issl_DDS( ausl, _vozrast, arr, mdata )

  // ausl - { lshifr,mdate,hu_->profil,hu_->PRVS }

  Local i, s, fl := .f., lshifr := alltrim(ausl[1])
  local arr_DDS_iss

  arr_DDS_iss := dds_arr_iss( mdata )
  for i := 1 to Len( arr_DDS_iss )
    if ascan( arr_DDS_iss[ i, 7 ], lshifr ) > 0
      fl := .t.
      exit
    endif
  next
  if fl .and. valtype( _vozrast ) == 'N'
    s := '"' + lshifr + '.' + arr_DDS_iss[ i, 1 ] + '"'
    if !between( _vozrast, arr_DDS_iss[ i, 3 ], arr_DDS_iss[ i, 4 ] )
      aadd( arr, 'Некорректный возраст пациента для услуги ' + s )
    endif
    if ascan( arr_DDS_iss[ i, 5 ], ausl[ 3 ] ) == 0
      aadd( arr, 'Не тот профиль в услуге ' + s )
    endif
  endif
  return fl

// 19.03.19 вернуть шифр услуги законченного случая для диспансеризации детей-сирот
Function ret_shifr_zs_dds( tip_lu )

  Local s := ''

  If m1mobilbr == 1 // диспансеризация проведена мобильной бригадой
    If m1lis > 0 // без гематологических иссл-ий
      If mvozrast < 1
        s := iif( tip_lu == TIP_LU_DDS, '70.5.21', '70.6.19' )
      Elseif mvozrast < 3
        s := iif( tip_lu == TIP_LU_DDS, '70.5.22', '70.6.20' )
      Elseif mvozrast < 5
        s := iif( tip_lu == TIP_LU_DDS, '70.5.23', '70.6.21' )
      Elseif mvozrast < 7
        s := iif( tip_lu == TIP_LU_DDS, '70.5.24', '70.6.22' )
      Elseif mvozrast < 15
        s := iif( tip_lu == TIP_LU_DDS, '70.5.25', '70.6.23' )
      Else
        s := iif( tip_lu == TIP_LU_DDS, '70.5.26', '70.6.24' )
      Endif
    Else  // гематологические иссл-ия проводятся в ЛПУ
      If mvozrast < 1
        s := iif( tip_lu == TIP_LU_DDS, '70.5.9', '70.6.7' )
      Elseif mvozrast < 3
        s := iif( tip_lu == TIP_LU_DDS, '70.5.10', '70.6.8' )
      Elseif mvozrast < 5
        s := iif( tip_lu == TIP_LU_DDS, '70.5.11', '70.6.9' )
      Elseif mvozrast < 7
        s := iif( tip_lu == TIP_LU_DDS, '70.5.12', '70.6.10' )
      Elseif mvozrast < 15
        s := iif( tip_lu == TIP_LU_DDS, '70.5.13', '70.6.11' )
      Else
        s := iif( tip_lu == TIP_LU_DDS, '70.5.14', '70.6.12' )
      Endif
    Endif
  Else // дисп-ия проведена в МО (не мобильной бригадой)
    If m1lis > 0 // без гематологических иссл-ий
      If mvozrast < 1
        s := iif( tip_lu == TIP_LU_DDS, '70.5.15', '70.6.13' )
      Elseif mvozrast < 3
        s := iif( tip_lu == TIP_LU_DDS, '70.5.16', '70.6.14' )
      Elseif mvozrast < 5
        s := iif( tip_lu == TIP_LU_DDS, '70.5.17', '70.6.15' )
      Elseif mvozrast < 7
        s := iif( tip_lu == TIP_LU_DDS, '70.5.18', '70.6.16' )
      Elseif mvozrast < 15
        s := iif( tip_lu == TIP_LU_DDS, '70.5.19', '70.6.17' )
      Else
        s := iif( tip_lu == TIP_LU_DDS, '70.5.20', '70.6.18' )
      Endif
    Else  // гематологические иссл-ия проводятся в ЛПУ
      If mvozrast < 1
        s := iif( tip_lu == TIP_LU_DDS, '70.5.3', '70.6.1' )
      Elseif mvozrast < 3
        s := iif( tip_lu == TIP_LU_DDS, '70.5.4', '70.6.2' )
      Elseif mvozrast < 5
        s := iif( tip_lu == TIP_LU_DDS, '70.5.5', '70.6.3' )
      Elseif mvozrast < 7
        s := iif( tip_lu == TIP_LU_DDS, '70.5.6', '70.6.4' )
      Elseif mvozrast < 15
        s := iif( tip_lu == TIP_LU_DDS, '70.5.7', '70.6.5' )
      Else
        s := iif( tip_lu == TIP_LU_DDS, '70.5.8', '70.6.6' )
      Endif
    Endif
  Endif
  Return s

// 25.09.25
Function save_arr_dds( lkod )

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
  AAdd( arr, { '1', m1stacionar } ) // 'N',код стационара
  AAdd( arr, { '2.3', m1kateg_uch } ) // 'N',Категория учета ребенка: 0-ребенок-сирота; 1-ребенок, оставшийся без попечения родителей; 2-ребенок, находящийся в трудной жизненной ситуации, 3-нет категории
  AAdd( arr, { '2.4', m1gde_nahod } ) // 'N',На момент проведения диспансеризации находится 0-в стационарном учреждении, 1-под опекой, 2-попечительством, 3-передан в приемную семью, 4-передан в патронатную семью, 5-усыновлен (удочерена), 6-другое
  AAdd( arr, { '4', mdate_post } ) // 'D',Дата поступления в стационарное учреждение
  If m1prich_vyb > 0
    AAdd( arr, { '5', m1prich_vyb } ) // 'N',0-нет. Причина выбытия из стационарного учреждения: 1-опека, 2-попечительство, 3-усыновление (удочерение), 4-передан в приемную семью, 5-передан в патронатную семью, 6-выбыл в другое стационарное учреждение, 7-выбыл по возрасту, 8-смерть, 9-другое
    AAdd( arr, { '5.1', mDATE_VYB } ) // 'D',Дата выбытия
  Endif
  If !Empty( mPRICH_OTS )
    AAdd( arr, { '6', AllTrim( mPRICH_OTS ) } ) // 'C70',причина отсутствия на момент проведения диспансеризации
  Endif
  AAdd( arr, { '8', m1MO_PR } ) // 'C6',код МО прикрепления
  AAdd( arr, { '12.1', mWEIGHT } )  // 'N3',вес в кг
  AAdd( arr, { '12.2', mHEIGHT } )  // 'N3',рост в см
  AAdd( arr, { '12.3', mPER_HEAD } )  // 'N3',окружность головы в см
  AAdd( arr, { '12.4', m1FIZ_RAZV } )  // 'N',физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
  AAdd( arr, { '12.4.1', m1FIZ_RAZV1 } )  // 'N',физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
  AAdd( arr, { '12.4.2', m1FIZ_RAZV2 } )  // 'N',физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
  If mvozrast < 5
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
  AAdd( arr, { '15.1', m1diag_15_1 } ) // 'C6',Состояние здоровья до проведения диспансеризации-Практически здоров
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
  AAdd( arr, { '16.1', m1diag_16_1 } ) // 'C6',Состояние здоровья по результатам проведения диспансеризации (Практически здоров)
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
    ta := { m1invalid1, m1invalid2, minvalid3, minvalid4, ;
      m1invalid5, m1invalid6, minvalid7, m1invalid8 }
    AAdd( arr, { '16.7', ta } )   // массив из 8
  Endif
  AAdd( arr, { '16.8', mGRUPPA } )    // 'N1',группа здоровья после дисп-ии
  If m1privivki1 > 0
    ta := { m1privivki1, m1privivki2, mprivivki3 }
    AAdd( arr, { '16.9', ta } )  // массив из 4,Проведение профилактических прививок
  Endif
  If !Empty( mrek_form )
    AAdd( arr, { '16.10', AllTrim( mrek_form ) } ) // Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой
  Endif
  If !Empty( mrek_disp )
    AAdd( arr, { '16.11', AllTrim( mrek_disp ) } ) // Рекомендации по диспансерному наблюдению, лечению, медицинской реабилитации и санаторно-курортному лечению с указанием диагноза (код МКБ), вида медицинской организации и специальности (должности) врача
  Endif
  // 18.результаты проведения исследований
  For i := 1 To Len( dds_arr_iss( mk_data ) )
    mvar := 'MREZi' + lstr( i )
    If !Empty( &mvar )
      AAdd( arr, { '18.' + lstr( i ), AllTrim( &mvar ) } )
    Endif
  Next
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

// 25.09.25
Function read_arr_dds( lkod )

  Local arr, i, k
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect
  Private mvar

  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server() + 'mo_pers',, 'TPERS' )
  Endif

  arr := read_arr_dispans( lkod )
  For i := 1 To Len( arr )
    If ValType( arr[ i ] ) == 'A' .and. ValType( arr[ i, 1 ] ) == 'C'
      Do Case
      Case arr[ i, 1 ] == '0' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1mobilbr := arr[ i, 2 ]
      Case arr[ i, 1 ] == '1'
        // m1stacionar := arr[i,2]
      Case arr[ i, 1 ] == '2.3' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1kateg_uch := arr[ i, 2 ]
      Case arr[ i, 1 ] == '2.4' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1gde_nahod := arr[ i, 2 ]
      Case arr[ i, 1 ] == '4' .and. ValType( arr[ i, 2 ] ) == 'D'
        mdate_post := arr[ i, 2 ]
      Case arr[ i, 1 ] == '5' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1prich_vyb := arr[ i, 2 ]
      Case arr[ i, 1 ] == '5.1' .and. ValType( arr[ i, 2 ] ) == 'D'
        mDATE_VYB := arr[ i, 2 ]
      Case arr[ i, 1 ] == '6' .and. ValType( arr[ i, 2 ] ) == 'C'
        mPRICH_OTS := PadR( arr[ i, 2 ], 70 )
      Case arr[ i, 1 ] == '8' .and. ValType( arr[ i, 2 ] ) == 'C'
        m1MO_PR := arr[ i, 2 ]
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
        // mGRUPPA := arr[i,2]
      Case arr[ i, 1 ] == '16.9' .and. ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 3
        m1privivki1 := arr[ i, 2, 1 ]
        m1privivki2 := arr[ i, 2, 2 ]
        mprivivki3  := arr[ i, 2, 3 ]
      Case arr[ i, 1 ] == '16.10' .and. ValType( arr[ i, 2 ] ) == 'C'
        mrek_form := PadR( arr[ i, 2 ], 255 )
      Case arr[ i, 1 ] == '16.11' .and. ValType( arr[ i, 2 ] ) == 'C'
        mrek_disp := PadR( arr[ i, 2 ], 255 )
        // case arr[i,1] == '47' .and. valtype(arr[i,2]) == 'N'
        // m1dopo_na  := arr[i,2]
      Case arr[ i, 1 ] == '47'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1dopo_na  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1dopo_na  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_dopo_na := TPERS->tab_nom
          Endif
          // mtab_v_dopo_na := arr[i,2][2]
        Endif
        // case arr[i,1] == '52' .and. valtype(arr[i,2]) == 'N'
        // m1napr_v_mo  := arr[i,2]
      Case arr[ i, 1 ] == '52'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_v_mo  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_v_mo  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_mo := TPERS->tab_nom
          Endif
          // mtab_v_mo := arr[i,2][2]
        Endif
      Case arr[ i, 1 ] == '53' .and. ValType( arr[ i, 2 ] ) == 'A'
        arr_mo_spec := arr[ i, 2 ]
        // case arr[i,1] == '54' .and. valtype(arr[i,2]) == 'N'
        // m1napr_stac := arr[i,2]
      Case arr[ i, 1 ] == '54'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_stac := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_stac := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_stac := TPERS->tab_nom
          Endif
          // mtab_v_stac := arr[i,2][2]
        Endif
      Case arr[ i, 1 ] == '55' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1profil_stac := arr[ i, 2 ]
        // case arr[i,1] == '56' .and. valtype(arr[i,2]) == 'N'
        // m1napr_reab := arr[i,2]
      Case arr[ i, 1 ] == '56'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_reab := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_reab := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_reab := TPERS->tab_nom
          Endif
          // mtab_v_reab := arr[i,2][2]
        Endif
      Case arr[ i, 1 ] == '57' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1profil_kojki := arr[ i, 2 ]
      Otherwise
        For k := 1 To Len( dds_arr_iss( mk_data ) )
          If arr[ i, 1 ] == '18.' + lstr( k ) .and. ValType( arr[ i, 2 ] ) == 'C'
            mvar := 'MREZi' + lstr( k )
            &mvar := PadR( arr[ i, 2 ], 17 )
          Endif
        Next
      Endcase
    Endif
  Next
  If ! aliasIsUse
    TPERS->( dbCloseArea() )
    Select( oldSelect )
  Endif
  Return Nil
