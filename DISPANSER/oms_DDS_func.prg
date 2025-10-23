#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
 
// 25.09.25 является врачебным осмотром детей-сирот на первом этапе
Function is_osmotr_dds_1_etap( ausl, _vozrast, _etap, _pol, tip_lu, mdata )

  // ausl - { lshifr,mdate,hu_->profil,hu_->PRVS }

  Local i, fl := .f., lshifr := AllTrim( ausl[ 1 ] )
  Local arr_DDS_osm1

  arr_DDS_osm1 := dds_arr_osm1( mdata )
  // вместо услуг "2.87.*" сделаем "2.83.*"
  If tip_lu == TIP_LU_DDSOP .and. Left( lshifr, 5 ) == '2.87.'
    lshifr := '2.83.' + SubStr( lshifr, 6 )
  Endif
  For i := 1 To Len( arr_DDS_osm1 )
    If iif( Empty( arr_DDS_osm1[ i, 2 ] ), .t., arr_DDS_osm1[ i, 2 ] == _pol ) .and. ;
        Between( _vozrast, arr_DDS_osm1[ i, 3 ], arr_DDS_osm1[ i, 4 ] )
      If _etap == 1
        If AScan( arr_DDS_osm1[ i, 5 ], ausl[ 3 ] ) > 0
          fl := .t.
          Exit
        Endif
      Else
        If AScan( arr_DDS_osm1[ i, 7 ], lshifr ) > 0
          fl := .t.
          Exit
        Endif
      Endif
    Endif
  Next
  Return fl


// 13.10.25 является врачебным осмотром детей-сирот
Function is_osmotr_dds( ausl, _vozrast, arr, _etap, _pol, tip_lu, mdata, mobil )

  // ausl - { lshifr,mdate,hu_->profil,hu_->PRVS }

  Local i, j, s, fl := .f., lshifr := AllTrim( ausl[ 1 ] )
  Local arr_DDS_osm1, arr_DDS_osm1_new
  Local arr_DDS_osm2, arr_DDS_osm2_new

  default mobil to 0  // обычный ДДС ( 1 - мобильная бригада )

  arr_DDS_osm1 := dds_arr_osm1( mdata )
  arr_DDS_osm1_new := dds_arr_osm1_new(  mdata, mobil, tip_lu, 2 )  // выбираем I этап
  arr_DDS_osm2 := dds_arr_osm2( mdata )
  arr_DDS_osm2_new := dds_arr_osm1_new(  mdata, mobil, tip_lu, 3 )  // выбираем II этап

  // вместо услуг "2.87.*" сделаем "2.83.*"
  If tip_lu == TIP_LU_DDSOP .and. Left( lshifr, 5 ) == '2.87.'
    lshifr := '2.83.' + SubStr( lshifr, 6 )
  Endif
  For i := 1 To Len( arr_DDS_osm1 )
    If _etap == 1
      If AScan( arr_DDS_osm1[ i, 5 ], ausl[ 3 ] ) > 0
        fl := .t.
        Exit
      Endif
    Else
      If AScan( arr_DDS_osm1[ i, 7 ], lshifr ) > 0
        fl := .t.
        Exit
      Endif
    Endif
  Next
  If fl
    s := '"' + lshifr + '.' + arr_DDS_osm1[ i, 1 ] + '"'
    If !Empty( arr_DDS_osm1[ i, 2 ] ) .and. !( arr_DDS_osm1[ i, 2 ] == _pol )
      AAdd( arr, 'Несовместимость по полу в услуге ' + s )
    Endif
    If AScan( arr_DDS_osm1[ i, 5 ], ausl[ 3 ] ) == 0
      AAdd( arr, 'Не тот профиль в услуге ' + s )
    Endif
  Endif
  If !fl .and. _etap == 2
    For i := 1 To Len( arr_DDS_osm2 )
      If AScan( arr_DDS_osm2[ i, 7 ], lshifr ) > 0 .and. AScan( arr_DDS_osm2[ i, 5 ], ausl[ 3 ] ) > 0
        fl := .t.
        Exit
      Endif
    Next
    If fl
      s := '"' + lshifr + '.' + arr_DDS_osm2[ i, 1 ] + '"'
      If !Between( _vozrast, arr_DDS_osm2[ i, 3 ], arr_DDS_osm2[ i, 4 ] )
        AAdd( arr, 'Некорректный возраст пациента для услуги ' + s )
      Endif
      If AScan( arr_DDS_osm2[ i, 5 ], ausl[ 3 ] ) == 0
        AAdd( arr, 'Не тот профиль в услуге ' + s )
      Endif
    Endif
  Endif
  Return fl


// 25.09.25 является исследованием детей-сирот
Function is_issl_dds( ausl, _vozrast, arr, mdata )

  // ausl - { lshifr,mdate,hu_->profil,hu_->PRVS }

  Local i, s, fl := .f., lshifr := AllTrim( ausl[ 1 ] )
  Local arr_DDS_iss

  arr_DDS_iss := dds_arr_iss( mdata )
  For i := 1 To Len( arr_DDS_iss )
    If AScan( arr_DDS_iss[ i, 7 ], lshifr ) > 0
      fl := .t.
      Exit
    Endif
  Next
  If fl .and. ValType( _vozrast ) == 'N'
    s := '"' + lshifr + '.' + arr_DDS_iss[ i, 1 ] + '"'
    If !Between( _vozrast, arr_DDS_iss[ i, 3 ], arr_DDS_iss[ i, 4 ] )
      AAdd( arr, 'Некорректный возраст пациента для услуги ' + s )
    Endif
    If AScan( arr_DDS_iss[ i, 5 ], ausl[ 3 ] ) == 0
      AAdd( arr, 'Не тот профиль в услуге ' + s )
    Endif
  Endif
  Return fl

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

// 19.10.25
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
  AAdd( arr, { '1', mperiod } ) // 'N',номер диапазона (от 1 до 33)
  // AAdd( arr, { '1', m1stacionar } ) // 'N',код стационара
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
  For i := 1 To Len( DDS_arr_issled( mk_data ) )
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

// 19.10.25
Function read_arr_dds( lkod, mdata )

  Local arr, i, k
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect
  Private mvar

  Default mdata To Date()
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
        // m1stacionar := arr[ i, 2 ]
        mperiod := arr[ i, 2 ]
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
        For k := 1 To Len( DDS_arr_issled( mdata ) )
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

// 30.09.25 вернуть возрастной период для профилактики несовершеннолетних
Function ret_period_dds( ldate_r, ln_data, lk_data, /*@*/ls, /*@*/ret_i)

  Local i, _m, _d, _y, _m2, _d2, _y2, lperiod, sm, sm_, sm1, sm2, yn_data, yk_data
  Local arr_DDS_etap

  Store 0 To _m, _d, _y, _m2, _d2, _y2, lperiod
  yn_data := Year( ln_data )
  yk_data := Year( lk_data )
  arr_DDS_etap := dds_arr_etap( lk_data )
  ls := ''
  count_ymd( ldate_r, ln_data, @_y, @_m, @_d ) // реальный возраст на начало
  count_ymd( ldate_r, lk_data, @_y2, @_m2, @_d2 ) // реальный возраст на окончание
  ret_i := 31
  For i := Len( arr_DDS_etap ) To 1 Step -1
    If i > 17 // 4 года и старше
      If mdvozrast == arr_DDS_etap[ i, 2, 1 ]
        ret_i := lperiod := i
        ls := ' (' + lstr( mdvozrast ) + ' ' + s_let( mdvozrast ) + ')'
        If yn_data != yk_data
          lperiod := 0
          ls := 'Ошибка! Начало и окончание профилактики должны быть в одном календарном году'
        Endif
        Exit
      Endif
    Elseif mdvozrast < 4 // до 3 лет (включительно)
      sm1 := Round( Val( lstr( arr_DDS_etap[ i, 2, 1 ] ) + '.' + StrZero( arr_DDS_etap[ i, 2, 2 ], 2 ) ), 4 )
      sm2 := Round( Val( lstr( arr_DDS_etap[ i, 3, 1 ] ) + '.' + StrZero( arr_DDS_etap[ i, 3, 2 ], 2 ) ), 4 )
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
          If arr_DDS_etap[ i, 2, 1 ] > 0
            ls += lstr( arr_DDS_etap[ i, 2, 1 ] ) + ' ' + s_let( arr_DDS_etap[ i, 2, 1 ] ) + ' '
          Endif
          If arr_DDS_etap[ i, 2, 2 ] > 0
            ls += lstr( arr_DDS_etap[ i, 2, 2 ] ) + ' ' + mes_cev( arr_DDS_etap[ i, 2, 2 ] )
          Endif
          ls := RTrim( ls ) + ')'
        Else
          // ls := 'Должен быть период ' + ;
          // iif( np_arr_1_etap()[ i, 2, 1 ] == 0, '', lstr( np_arr_1_etap()[ i, 2, 1 ] ) + 'г.' ) + ;
          // iif( np_arr_1_etap()[ i, 2, 2 ] == 0, '', lstr( np_arr_1_etap()[ i, 2, 2 ] ) + 'мес.' ) + '-' + ;
          // iif( np_arr_1_etap()[ i, 3, 1 ] == 0, '', lstr( np_arr_1_etap()[ i, 3, 1 ] ) + 'г.' ) + ;
          // iif( np_arr_1_etap()[ i, 3, 2 ] == 0, '', lstr( np_arr_1_etap()[ i, 3, 2 ] ) + 'мес.' ) + ', а у Вас ' + ;
          ls := 'Должен быть период ' + ;
            iif( arr_DDS_etap[ i, 2, 1 ] == 0, '', lstr( arr_DDS_etap[ i, 2, 1 ] ) + 'г.' ) + ;
            iif( arr_DDS_etap[ i, 2, 2 ] == 0, '', lstr( arr_DDS_etap[ i, 2, 2 ] ) + 'мес.' ) + '-' + ;
            iif( arr_DDS_etap[ i, 3, 1 ] == 0, '', lstr( arr_DDS_etap[ i, 3, 1 ] ) + 'г.' ) + ;
            iif( arr_DDS_etap[ i, 3, 2 ] == 0, '', lstr( arr_DDS_etap[ i, 3, 2 ] ) + 'мес.' ) + ', а у Вас ' + ;
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

// 05.10.25
Function add_pediatr_DDS( _pv, _pa, _date, _diag, mpol, mdef_diagnoz, mobil, tip_lu )

  Local arr[ 10 ]

  Default mobil To 0
  default tip_lu to TIP_LU_DDSOP

  AFill( arr, 0 )
  p2->( dbSeek( Str( _pv, 5 ) ) )
  If p2->( Found() )
    arr[ 1 ] := p2->kod
    arr[ 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
  Endif
  If !Empty( _pa )
    p2->( dbSeek( Str( _pa, 5 ) ) ) // find ( Str( _pa, 5 ) )
    If p2->( Found() )
      arr[ 3 ] := p2->kod
    Endif
  Endif
  arr[ 4 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), 57, 68 ) // профиль
  If _date >= 0d20250901
    If mobil == 0
      if tip_lu == TIP_LU_DDSOP
        arr[ 5 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), '70.6.100', '70.6.100' ) // шифр услуги
      else
        arr[ 5 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), '70.5.100', '70.5.100' ) // шифр услуги
      endif
    Else
      if tip_lu == TIP_LU_DDSOP
        arr[ 5 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), '70.6.110', '70.6.110' ) // шифр услуги
      else
        arr[ 5 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), '70.5.110', '70.5.110' ) // шифр услуги
      endif
    Endif
  Else
    arr[ 5 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), '2.85.15', '2.85.14' ) // шифр услуги
  Endif
  If Empty( _diag ) .or. Left( _diag, 1 ) == 'Z'
    arr[ 6 ] := mdef_diagnoz
  Else
    arr[ 6 ] := _diag
    // Select MKB_10
    mkb_10->( dbSeek( PadR( arr[ 6 ], 6 ) ) )  // find ( PadR( arr[ 6 ], 6 ) )
    If mkb_10->( Found() ) .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
      func_error( 4, 'Несовместимость диагноза по полу ' + arr[ 6 ] )
    Endif
  Endif
  arr[ 9 ] := _date
  Return arr

// 18.10.25
Function f2_inf_dds_karta( Loc_kod, kod_kartotek, lvozrast )

  Static st := '     ', ub := '<u><b>', ue := '</b></u>', sh := 88
  Local adbf, i, j, k, y, m, d, fl, mm_danet, blk := {| s| __dbAppend(), field->stroke := s }
  local mm_invalid5 := mm_invalid5()
  local mm_gr_fiz, arr
  local s, s1, s2, s3, s4, s5, s6
  local mm_gruppa, mm_vedom

  mm_vedom := { ;
    { 'органы здравоохранения', 0 }, ;
    { 'образования', 1 }, ;
    { 'социальной защиты', 2 }, ;
    { 'другое', 3 } ;
  }
  mm_gruppa := { { 'I', 1 }, { 'II', 2 }, { 'III', 3 }, { 'IV', 4 }, { 'V', 5 } }
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
  adbf := { { 'name', 'C', 130, 0 }, ;
    { 'prikaz', 'C', 50, 0 }, ;
    { 'forma', 'C', 50, 0 }, ;
    { 'titul', 'C', 100, 0 }, ;
    { 'fio', 'C', 50, 0 }, ;
    { 'k_data', 'C', 40, 0 }, ;
    { 'vrach', 'C', 40, 0 }, ;
    { 'glavn', 'C', 40, 0 } }
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
  // заполним данные для формы
  if mk_data < 0d20250901
    frt->prikaz := 'от 15.02.2013г. № 72н'
    frt->forma  := '030-Д/с/у-13'
  else
    frt->prikaz := 'от 14.04.2025г. № 212н'
    frt->forma  := '030/у-Д/с'
  endif
  frt->titul  := 'Карта диспансеризации несовершеннолетнего'
  s := st + '1. Полное наименование стационарного учреждения: '
  If p_tip_lu == TIP_LU_DDS
    s += ub + AllTrim( mstacionar ) + ue + '.'
    frd->( Eval( blk, s ) )
  Else
    frd->( Eval( blk, s ) )
    s := Replicate( '_', sh ) + '.'
    frd->( Eval( blk, s ) )
  Endif
  s := st + '1.1. Прежнее наименование (в случае его изменения):'
  frd->( Eval( blk, s ) )
  s := Replicate( '_', sh ) + '.'
  frd->( Eval( blk, s ) )
  s := st + '1.2. Ведомственная принадлежность: '
  If p_tip_lu == TIP_LU_DDS
    i := mo_stdds->vedom
    If !Between( i, 0, 3 )
      i := 3
    Endif
  Else
    i := -1
  Endif
  s += f3_inf_dds_karta( mm_vedom, i,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '1.3. Юридический адрес стационарного учреждения: '
  If p_tip_lu == TIP_LU_DDS .and. !Empty( mo_stdds->adres )
    s += ub + AllTrim( mo_stdds->adres ) + ue + '.'
  Endif
  frd->( Eval( blk, s ) )
  If p_tip_lu == TIP_LU_DDSOP .or. Empty( mo_stdds->adres )
    s := Replicate( '_', sh ) + '.'
    frd->( Eval( blk, s ) )
  Endif
  s := st + '2. Фамилия, имя, отчество несовершеннолетнего: ' + ub + AllTrim( mfio ) + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + '2.1. Пол: '
  s += f3_inf_dds_karta( { { 'муж.', 'М' }, { 'жен.', 'Ж' } }, mpol, '/', ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '2.2. Дата рождения: ' + ub + date_month( mdate_r, .t. ) + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + '2.3. Категория учета ребенка, находящегося в тяжелой жизненной ситуации: '
  s += f3_inf_dds_karta( mm_kateg_uch(), m1kateg_uch, '; ', ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '2.4. На момент проведения диспансеризации находится '
  mm_gde_nahod1[ 3, 1 ] := 'попечительством'
  s += f3_inf_dds_karta( mm_gde_nahod1, m1gde_nahod,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '3. Полис обязательного медицинского страхования:'
  s += '№ ' + ub + AllTrim( mnpolis ) + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + 'Страховая медицинская организация: ' + ub + AllTrim( mcompany ) + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + '4. Страховой номер индивидуального лицевого счета: '
  s += iif( Empty( kart->snils ), Replicate( '_', 25 ), ub + Transform_SNILS( kart->SNILS ) + ue ) + '.'
  frd->( Eval( blk, s ) )
  s := st + '5. Дата поступления в стационарное учреждение: '
  s += iif( p_tip_lu == TIP_LU_DDSOP .or. Empty( mdate_post ), Replicate( '_', 15 ), ub + full_date( mdate_post ) + ue ) + '.'
  frd->( Eval( blk, s ) )
  s := st + '6. Причина выбытия из стационарного учреждения: '
// НЕ ЗНАЮ ЗАЧЕМ    del_array( mm_prich_vyb(), 1 ) // удалить 1-ый элемент '{'не выбыл', 0}'
  s += f3_inf_dds_karta( mm_prich_vyb(), m1prich_vyb,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '6.1. Дата выбытия: ' + iif( Empty( mDATE_VYB ), Replicate( '_', 15 ), ub + full_date( mDATE_VYB ) + ue ) + '.'
  frd->( Eval( blk, s ) )
  s := st + '7. Отсутствует на момент проведения диспансеризации:'
  frd->( Eval( blk, s ) )
  s := Replicate( '_', 73 ) + ' (указать причину).'
  frd->( Eval( blk, s ) )
  s := st + '8. Адрес места жительства: '
  If emptyall( kart_->okatog, kart->adres )
    s += Replicate( '_', 50 ) + ' ' + Replicate( '_', sh ) + '.'
  Else
    s += ub + ret_okato_ulica( kart->adres, kart_->okatog, 1, 2 ) + ue + '.'
  Endif
  frd->( Eval( blk, s ) )
  s := st + '9. Полное наименование медицинской организации, выбранной ' + ;
    'несовершеннолетним (его родителем или иным законным представителем) ' + ;
    'для получения первичной медико-санитарной помощи: '
  s += ub + ret_mo( m1MO_PR )[ _MO_FULL_NAME ] + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + '10. Юридический адрес медицинской организации, выбранной ' + ;
    'несовершеннолетним (его родителем или иным законным представителем) ' + ;
    'для получения первичной медико-санитарной помощи: '
  s += ub + ret_mo( m1MO_PR )[ _MO_ADRES ] + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + '11. Дата начала диспансеризации: ' + ub + full_date( mn_data ) + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + '12. Полное наименование и юридический адрес медицинской организации, ' + ;
    'проводившей ' + iif( p_tip_lu == TIP_LU_PN, 'профилактический медицинский осмотр: ', 'диспансеризацию: ' ) + ;
    ub + glob_mo[ _MO_FULL_NAME ] + ', ' + glob_mo[ _MO_ADRES ] + ue + '.'
  frd->( Eval( blk, s ) )
  s := st + '13. Оценка физического развития с учетом возраста на момент ' + ;
    iif( p_tip_lu == TIP_LU_PN, 'медицинского осмотра:', 'диспансеризации:' )
  frd->( Eval( blk, s ) )
  count_ymd( mdate_r, mn_data, @y, @m, @d )
  s := ub + st + lstr( d ) + st + ue + ' (число дней) ' + ;
    ub + st + lstr( m ) + st + ue + ' (месяцев) ' + ;
    ub + st + lstr( y ) + st + ue + ' лет.'
  frd->( Eval( blk, s ) )
  mm_fiz_razv1 := { { 'дефицит массы тела', 1 }, { 'избыток массы тела', 2 } }
  mm_fiz_razv2 := { { 'низкий рост', 1 }, { 'высокий рост', 2 } }
  For i := 1 To 2
    s := st + '13.' + lstr( i ) + '. Для детей в возрасте ' + ;
      { '0 - 4 лет: ', '5 - 17 лет включительно: ' }[ i ]
    If i == 1
      fl := ( lvozrast < 5 )
    Else
      fl := ( lvozrast > 4 )
    Endif
    s += 'масса (кг) ' + iif( !fl, '________', ub + st + lstr( mWEIGHT ) + st + ue ) + '; '
    s += 'рост (см) ' + iif( !fl, '________', ub + st + lstr( mHEIGHT ) + st + ue ) + '; '
    s += 'окружность головы (см) ' + iif( !fl .or. mPER_HEAD == 0, '________', ub + st + lstr( mPER_HEAD ) + st + ue ) + '; '
    s += 'физическое развитие ' + f3_inf_dds_karta( mm_fiz_razv(), iif( fl, m1FIZ_RAZV, -1 ),, ub, ue, .f. )
    s += ' (' + f3_inf_dds_karta( mm_fiz_razv1, iif( fl, m1FIZ_RAZV1, -1 ),, ub, ue, .f. )
    s += ', ' + f3_inf_dds_karta( mm_fiz_razv2, iif( fl, m1FIZ_RAZV2, -1 ),, ub, ue, .f. )
    s += ' - нужное подчеркнуть).'
    frd->( Eval( blk, s ) )
  Next

  rep_psih_health_and_sex( lvozrast, mk_data, TIP_LU_DDS )
/*
  fl := ( lvozrast < 5 ) 
  s := st + '13. Оценка психического развития (состояния):'
  frd->( Eval( blk, s ) )
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
  s := st + '15. Состояние здоровья до проведения ' + ;
    iif( p_tip_lu == TIP_LU_PN, 'настоящего профилактического медицинского осмотра:', 'диспансеризации:' )
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
    For k := 1 To 14
      mvar := 'mdiag_15_' + lstr( i ) + '_' + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_15_1 == 0
      Else
        m1var := 'm1diag_15_' + lstr( i ) + '_' + lstr( k )
      Endif
      Do Case
      Case k == 1
        s := st + '15.' + lstr( i + 1 ) + '. Диагноз ' + iif( !fl, Replicate( '_', 30 ), ub + st + RTrim( &mvar ) + st + ue ) + ' (код по МКБ).'
      Case k == 2
        s1 := st + '15.' + lstr( i + 1 ) + '.1. Диспансерное наблюдение: ' + f3_inf_dds_karta( mm_dispans, &m1var,, ub, ue )
      Case k == 3
        s2 := st + '15.' + lstr( i + 1 ) + '.2. Лечение было назначено: ' + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 4
        s2 := Left( s2, Len( s2 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 5
        s2 := Left( s2, Len( s2 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 6
        s3 := st + '15.' + lstr( i + 1 ) + '.3. Лечение было выполнено: ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 7
        s3 := Left( s3, Len( s3 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 8
        s4 := st + '15.' + lstr( i + 1 ) + '.4. Медицинская реабилитация и (или) санаторно-курортное лечение были назначены: ' + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 9
        s4 := Left( s4, Len( s4 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 10
        s4 := Left( s4, Len( s4 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch1, &m1var,, ub, ue )
      Case k == 11
        s5 := st + '15.' + lstr( i + 1 ) + '.5. Медицинская реабилитация и (или) санаторно-курортное лечение были выполнены: ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 12
        s5 := Left( s5, Len( s5 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch1, &m1var,, ub, ue )
      Case k == 13
        s6 := st + '15.' + lstr( i + 1 ) + '.6. Высокотехнологичная медицинская помощь была рекомендована: ' + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 14
        s6 := Left( s6, Len( s6 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_danet1, &m1var,, ub, ue )
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
  s := st + '15.9. Группа состояния здоровья: ' + f3_inf_dds_karta( mm_gruppa, mGRUPPA_DO,, ub, ue )
  frd->( Eval( blk, s ) )
  If p_tip_lu == TIP_LU_PN
    s := st + '15.10. Медицинская группа для занятий физической культурой: '
    s += f3_inf_dds_karta( mm_gr_fiz_do(), m1GR_FIZ_DO,, ub, ue )
    frd->( Eval( blk, s ) )
  Endif
  s := st + '16. Состояние здоровья по результатам проведения ' + ;
    iif( p_tip_lu == TIP_LU_PN, 'настоящего профилактического медицинского осмотра:', 'диспансеризации:' )
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
    For k := 1 To 16
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
      Case k == 16
        s7 := st + '16.' + lstr( i + 1 ) + '.7. Высокотехнологичная медицинская помощь была рекомендована: ' + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Endcase
    Next
    frd->( Eval( blk, s ) )
    frd->( Eval( blk, s1 ) )
    frd->( Eval( blk, s2 ) )
    frd->( Eval( blk, s3 ) )
    frd->( Eval( blk, s4 ) )
    frd->( Eval( blk, s5 ) )
    frd->( Eval( blk, s6 ) )
    frd->( Eval( blk, s7 ) )
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
  s := st + '16.7.1. Заболевания, обусловившие возникновение инвалидности:'
  frd->( Eval( blk, s ) )
  mm_invalid5[ 6, 1 ] := 'болезни крови, кроветворных органов и отдельные нарушения, вовлекающие иммунный механизм;'
  mm_invalid5[ 7, 1 ] := 'болезни эндокринной системы, расстройства питания и нарушения обмена веществ,'
  ATail( mm_invalid5 )[ 1 ] := 'последствия травм, отравлений и других воздействий внешних причин)'
  s := st + '(' + f3_inf_dds_karta( mm_invalid5, m1invalid5, ' ', ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '16.7.2.Виды нарушений в состоянии здоровья:'
  frd->( Eval( blk, s ) )
  s := st + f3_inf_dds_karta( mm_invalid6(), m1invalid6, '; ', ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '16.7.3. Индивидуальная программа реабилитации ребенка-инвалида:'
  frd->( Eval( blk, s ) )
  s := st + 'дата назначения: ' + iif( Empty( minvalid7 ), Replicate( '_', 15 ), ub + full_date( minvalid7 ) + ue ) + ';'
  frd->( Eval( blk, s ) )
  s := st + 'выполнение на момент диспансеризации: ' + f3_inf_dds_karta( mm_invalid8(), m1invalid8,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '16.8. Группа состояния здоровья: ' + f3_inf_dds_karta( mm_gruppa, mGRUPPA,, ub, ue )
  frd->( Eval( blk, s ) )
  If p_tip_lu == TIP_LU_PN
    s := st + '16.9. Медицинская группа для занятий физической культурой: '
    s += f3_inf_dds_karta( mm_gr_fiz, m1GR_FIZ,, ub, ue )
    frd->( Eval( blk, s ) )
  Endif
  s := st + iif( p_tip_lu == TIP_LU_PN, '16.10', '16.9' ) + ;
    '. Проведение профилактических прививок:'
  frd->( Eval( blk, s ) )
  s := st
  For j := 1 To Len( mm_privivki1() )
    If m1privivki1 == mm_privivki1()[ j, 2 ]
      s += ub
    Endif
    s += mm_privivki1()[ j, 1 ]
    If m1privivki1 == mm_privivki1()[ j, 2 ]
      s += ue
    Endif
    If mm_privivki1()[ j, 2 ] == 0
      s += '; '
    Else
      s += ': ' + f3_inf_dds_karta( mm_privivki2(), iif( m1privivki1 == mm_privivki1()[ j, 2 ], m1privivki2, -1 ),, ub, ue, .f. ) + '; '
    Endif
  Next
  s += 'нуждается в проведении вакцинации (ревакцинации) с указанием наименования прививки (нужное подчеркнуть): '
  If m1privivki1 > 0 .and. !Empty( mprivivki3 )
    s += ub + AllTrim( mprivivki3 ) + ue
  Endif
  frd->( Eval( blk, s ) )
  s := Replicate( '_', sh ) + '.'
  frd->( Eval( blk, s ) )
  s := st + iif( p_tip_lu == TIP_LU_PN, '16.11', '16.10' ) + ;
    '. Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой: '
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
  If p_tip_lu == TIP_LU_PN
    s := st + '16.12. Рекомендации о необходимости установления или продолжения ' + ;
      'диспансерного наблюдения, включая диагноз заболевания (состояния) ' + ;
      'и код МКБ, по лечению, медицинской реабилитации и ' + ;
      'санаторно-курортному лечению с указанием вида медицинской ' + ;
      'организации (санаторно-курортной организации) и специальности ' + ;
      '(должности) врача: '
  Else
    s := st + '16.11. Рекомендации по диспансерному наблюдению, лечению, ' + ;
      'медицинской реабилитации и санаторно-курортному лечению с указанием ' + ;
      'диагноза (код МКБ), вида медицинской организации и специальности ' + ;
      '(должности) врача: '
  Endif
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
  adbf := { ;
    { 'name', 'C', 60, 0 }, ;
    { 'data', 'C', 10, 0 }, ;
    { 'rezu', 'C', 17, 0 } ;
  }
  dbCreate( fr_data + '1', adbf )
  Use ( fr_data + '1' ) New Alias FRD1
  dbCreate( fr_data + '2', adbf )
  Use ( fr_data + '2' ) New Alias FRD2
//  arr := iif( p_tip_lu == TIP_LU_PN, f4_inf_dnl_karta( 1 ), f4_inf_dds_karta( 1 ) )
  arr := f4_inf_dds_karta( 1 )
  For i := 1 To Len( arr )
    frd1->( dbAppend() )
    frd1->name := arr[ i, 1 ]
    frd1->data := full_date( arr[ i, 2 ] )
  Next
//  arr := iif( p_tip_lu == TIP_LU_PN, f4_inf_dnl_karta( 2 ), f4_inf_dds_karta( 2 ) )
  arr := f4_inf_dds_karta( 2 )
  For i := 1 To Len( arr )
    frd2->( dbAppend() )
    frd2->name := arr[ i, 1 ]
    frd2->data := full_date( arr[ i, 2 ] )
    frd2->rezu := arr[ i, 3 ]
  Next
  //
  dbCloseAll()
  call_fr( 'mo_030dcu13' )
  Return Nil

// 19.10.25
Function f4_inf_dds_karta( par, _etap, et2 )

  Local i, k, arr := {}
  local arr_DDS_iss, arr_DDS_osm1, arr_DDS_osm2

  arr_DDS_iss := iif( mk_data < 0d20250901, dds_arr_iss( mk_data ), DDS_arr_issled( mk_data ) )
  arr_DDS_osm1 := iif( mk_data < 0d20250901, dds_arr_osm1( mk_data ), dds_arr_osm1_new( mk_data, 0, TIP_LU_DDS, 2 ) )
//  arr_DDS_osm2 := iif( mk_data < 0d20250901, dds_arr_osm2( mk_data ), dds_arr_osm1_new( mk_data, 0, TIP_LU_DDS, 3 ) )
  arr_DDS_osm2 := dds_arr_osm2( mk_data, p_tip_lu )
  If par == 1
    If iif( _etap == nil, .t., _etap == 1 )
      For i := 1 To Len( arr_DDS_osm1 )
        k := 0
        Do Case
        Case i ==  1 // {'офтальмолог','', 0, 17,{65},{1112},{'2.83.21'}}, ;
          k := 3
        Case i ==  2 // {'оториноларинголог','', 0, 17,{64},{1111, 111101},{'2.83.22'}}, ;
          k := 5
        Case i ==  3 // {'детский хирург','', 0, 17,{20},{1135},{'2.83.18'}}, ;
          k := 4
        Case i ==  4 // {'травматолог-ортопед','', 0, 17,{100},{1123},{'2.83.19'}}, ;
          k := 6
        Case i ==  5 // {'акушер-гинеколог (девочки)','Ж', 0, 17,{2},{1101},{'2.83.16'}}, ;
          k := 11
        Case i ==  6 // {'детский уролог-андролог (мальчики)','М', 0, 17,{19},{112603, 113502},{'2.83.17'}}, ;
          k := 10
        Case i ==  7 // {'детский стоматолог (с 3 лет)','', 3, 17,{86},{140102},{'2.83.23'}}, ;
          k := 8
        Case i ==  8 // {'детский эндокринолог (с 5 лет)','', 5, 17,{21},{1127, 112702, 113402},{'2.83.24'}}, ;
          k := 9
        Case i ==  9 // {'невролог','', 0, 17,{53},{1109},{'2.83.20'}}, ;
          k := 2
        Case i == 10 // {'психиатр','', 0, 17,{72},{1115},{'2.4.1'}}, ;
          k := 7
        Case i == 11 // {'педиатр','', 0, 17,{68, 57},{1134, 1110},{'2.83.14','2.83.15'}};
          k := 1
        Endcase
        mvart := 'MTAB_NOMov' + lstr( i )
        mvard := 'MDATEo' + lstr( i )
        if mk_data < 0d20250901
          If Between( mvozrast, arr_DDS_osm1[ i, 3 ], arr_DDS_osm1[ i, 4 ] ) .and. ;
              iif( Empty( arr_DDS_osm1[ i, 2 ] ), .t., arr_DDS_osm1[ i, 2 ] == mpol )
            If !emptyany( &mvard, &mvart )
              AAdd( arr, { arr_DDS_osm1[ i, 1 ], &mvard, '', i, k } )
            Endif
          Endif
        else
          If iif( Empty( arr_DDS_osm1[ i, 2 ] ), .t., arr_DDS_osm1[ i, 2 ] == mpol )
            If !emptyany( &mvard, &mvart )
              AAdd( arr, { arr_DDS_osm1[ i, 1 ], &mvard, '', i, k } )
            Endif
          Endif
        endif
      Next
    Endif
    If metap == 2 .and. iif( _etap == nil, .t., _etap == 2 )
      Default et2 To 0
      If eq_any( et2, 0, 1 )
        For i := 7 To 8 // стоматолог и эндокринолог на 2 этапе
          k := 0
          mvart := 'MTAB_NOMov' + lstr( i )
          mvard := 'MDATEo' + lstr( i )
          if mk_data < 0d20250901
            If !Between( mvozrast, arr_DDS_osm1[ i, 3 ], arr_DDS_osm1[ i, 4 ] )
              If !emptyany( &mvard, &mvart )
                AAdd( arr, { arr_DDS_osm1[ i, 1 ], &mvard, '', i, k } )
              Endif
            Endif
          else
            If !emptyany( &mvard, &mvart )
              AAdd( arr, { arr_DDS_osm1[ i, 1 ], &mvard, '', i, k } )
            Endif
          endif
        Next
      Endif
      If eq_any( et2, 0, 2 )

        For i := 1 To Len( arr_DDS_osm2 )
          k := 0
          mvart := 'MTAB_NOMov' + lstr( i )
          mvard := 'MDATEo' + lstr( i )
          If &mvart != 0
            if mk_data < 0d20250901
              AAdd( arr, { arr_DDS_osm2[ i, 7, 1 ] + ' ' + arr_DDS_osm2[ i, 1 ], &mvard, '', i, k } )
            else
              AAdd( arr, { arr_DDS_osm2[ i, 7 ] + ' ' + arr_DDS_osm2[ i, 1 ], &mvard, '', i, k } )
            endif
          Endif
        Next

      Endif
    Endif
  Else
    For i := 1 To Len( arr_DDS_iss )
      k := 0
      Do Case
      Case i ==  1 // {'Клинический анализ мочи','', 0, 17,{34},{1107, 1301, 1402, 1702},{'4.2.153'}}, ;
        k := 2
      Case i ==  2 // {'Клинический анализ крови','', 0, 17,{34},{1107, 1301, 1402, 1702},{'4.11.136'}}, ;
        k := 1
      Case i ==  3 // {'Исследование уровня глюкозы в крови','', 0, 17,{34},{1107, 1301, 1402, 1702},{'4.12.169'}}, ;
        k := 4
      Case i ==  4 // {'Электрокардиография','', 0, 17,{111},{110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202},{'13.1.1'}}, ;
        k := 13
      Case i ==  5 // {'Флюорография легких (с 15 лет)','', 15, 17,{78},{1118, 1802},{'7.61.3'}}, ;
        k := 12
      Case i ==  6 // {'УЗИ головного мозга (нейросонография) (до 1 года)','', 0, 0,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{'8.1.1'}}, ;
        k := 11
      Case i ==  7 // {'УЗИ щитовидной железы (с 7 лет)','', 7, 17,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{'8.1.2'}}, ;
        k := 8
      Case i ==  8 // {'УЗИ сердца','', 0, 17,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{'8.1.3'}}, ;
        k := 7
      Case i ==  9 // {'УЗИ тазобедренных суставов (до 1 года)','', 0, 0,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{'8.1.4'}}, ;
        k := 10
      Case i == 10 // {'УЗИ органов брюшной полости комплексное профилактическое','', 0, 17,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{'8.2.1'}}, ;
        k := 6
      Case i == 11 // {'УЗИ органов репродуктивной системы','', 7, 17,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{'8.2.2','8.2.3'}};
        k := 9
      Endcase
      mvart := 'MTAB_NOMiv' + lstr( i )
      mvard := 'MDATEi' + lstr( i )
      mvarr := 'MREZi' + lstr( i )
      if mk_data < 0d20250901
        If Between( mvozrast, arr_DDS_iss[ i, 3 ], arr_DDS_iss[ i, 4 ] )
          If !emptyany( &mvard, &mvart )
            AAdd( arr, { arr_DDS_iss[ i, 7, 1 ] + ' ' + arr_DDS_iss[ i, 1 ], &mvard, &mvarr, i, k } )
          Endif
        Endif
      else
        If !emptyany( &mvard, &mvart )
          AAdd( arr, { arr_DDS_iss[ i, 1 ] + ' ' + arr_DDS_iss[ i, 3 ], &mvard, &mvarr, i, k } )
        Endif
      endif
    Next
  Endif
  Return arr