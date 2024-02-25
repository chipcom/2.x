// mo_oms1.prg - режимы ввода данных для задачи ОМС (продолжение)
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 28.09.18 добавить или удалить офтальмолога в массив для несовершеннолетних для 12 месяцев
Function np_oftal_2_85_21( _period, _k_data )

  Static lshifr := '2.85.21'
  Local i

  If _period == 13 // 12 месяцев с 1 сентября
    i := AScan( np_arr_1_etap[ _period, 4 ], lshifr )
    If _k_data > 0d20180831 // с 1 сентября
      If i == 0
        ins_array( np_arr_1_etap[ _period, 4 ], 4, lshifr ) // добавить пере ЛОРом 4-ым элементом
      Endif
    Else
      If i > 0
        del_array( np_arr_1_etap[ _period, 4 ], i )
      Endif
    Endif
  Endif

  Return Nil

// 19.03.19 вернуть шифр услуги законченного случая для ПН
Function ret_shifr_zs_pn( _period )

  Local lshifr := ''

  Do Case
  Case _period == 1
    lshifr := iif( is_neonat, '72.2.37', '72.2.38' ) // 0 месяцев
  Case _period == 2
    lshifr := '72.2.39' // 1 месяц
  Case _period == 3
    lshifr := iif( m1lis > 0, '72.2.41', '72.2.40' ) // 2 мес
  Case _period == 4
    lshifr := '72.2.43' // 3 месяца
  Case eq_any( _period, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15 )
    lshifr := '72.2.42' // 4мес, 5мес, 6мес, 7мес, 8мес, 9мес, 10мес, 11мес, 1год3мес, 1год6мес
  Case _period == 13
    If AScan( np_arr_1_etap[ _period, 4 ], '2.85.21' ) > 0  // если есть офтальмолог
      lshifr := iif( m1lis > 0, '72.2.65', '72.2.64' ) // 12 месяцев с 1 сентября
    Else
      lshifr := iif( m1lis > 0, '72.2.45', '72.2.44' ) // 12 месяцев
    Endif
  Case _period == 16
    lshifr := '72.2.46' // 2 года
  Case _period == 17
    lshifr := iif( m1lis > 0, '72.2.48', '72.2.47' ) // 3 года
  Case eq_any( _period, 18, 19, 22, 23, 25, 26 )
    lshifr := '72.2.49' // 4 года, 5 лет, 8 лет, 9 лет, 11 лет, 12лет
  Case _period == 20
    lshifr := iif( m1lis > 0, '72.2.51', '72.2.50' ) // 6 лет
  Case _period == 21
    lshifr := iif( m1lis > 0, '72.2.53', '72.2.52' ) // 7 лет
  Case _period == 24
    lshifr := iif( m1lis > 0, '72.2.55', '72.2.54' ) // 10 лет
  Case _period == 27
    lshifr := '72.2.56' // 13 лет
  Case _period == 28
    lshifr := '72.2.57' // 14 лет
  Case _period == 29
    lshifr := iif( m1lis > 0, '72.2.59', '72.2.58' ) // 15 лет
  Case _period == 30
    lshifr := iif( m1lis > 0, '72.2.61', '72.2.60' ) // 16 лет
  Case _period == 31
    lshifr := iif( m1lis > 0, '72.2.63', '72.2.62' ) // 17 лет
  Endcase

  Return lshifr

// 28.01.18
Function add_pediatr_pn( _pv, _pa, _date, _diag )

  Local arr[ 10 ]

  AFill( arr, 0 )
  Select P2
  find ( Str( _pv, 5 ) )
  If Found()
    arr[ 1 ] := p2->kod
    arr[ 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
  Endif
  If !Empty( _pa )
    Select P2
    find ( Str( _pa, 5 ) )
    If Found()
      arr[ 3 ] := p2->kod
    Endif
  Endif
  arr[ 4 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), 57, 68 ) // профиль
  arr[ 5 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), '2.85.15', '2.85.14' ) // шифр услуги
  If Empty( _diag ) .or. Left( _diag, 1 ) == 'Z'
    arr[ 6 ] := mdef_diagnoz
  Else
    arr[ 6 ] := _diag
    Select MKB_10
    find ( PadR( arr[ 6 ], 6 ) )
    If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
      func_error( 4, 'Несовместимость диагноза по полу ' + arr[ 6 ] )
    Endif
  Endif
  arr[ 9 ] := _date

  Return arr

// 28.01.18 вернуть возрастной период для профилактики несовершеннолетних
Function ret_period_pn( ldate_r, ln_data, lk_data, /*@*/ls, /*@*/ret_i)

  Local i, _m, _d, _y, _m2, _d2, _y2, lperiod, sm, sm_, sm1, sm2, yn_data, yk_data

  Store 0 To _m, _d, _y, _m2, _d2, _y2, lperiod
  yn_data := Year( ln_data )
  yk_data := Year( lk_data )
  ls := ''
  count_ymd( ldate_r, ln_data, @_y, @_m, @_d ) // реальный возраст на начало
  count_ymd( ldate_r, lk_data, @_y2, @_m2, @_d2 ) // реальный возраст на окончание
  ret_i := 31
  For i := Len( np_arr_1_etap ) To 1 Step -1
    If i > 17 // 4 года и старше
      If mdvozrast == np_arr_1_etap[ i, 2, 1 ]
        ret_i := lperiod := i
        ls := ' (' + lstr( mdvozrast ) + ' ' + s_let( mdvozrast ) + ')'
        If yn_data != yk_data
          lperiod := 0
          ls := 'Ошибка! Начало и окончание профилактики должны быть в одном календарном году'
        Endif
        Exit
      Endif
    Elseif mdvozrast < 4 // до 3 лет (включительно)
      sm1 := Round( Val( lstr( np_arr_1_etap[ i, 2, 1 ] ) + '.' + StrZero( np_arr_1_etap[ i, 2, 2 ], 2 ) ), 4 )
      sm2 := Round( Val( lstr( np_arr_1_etap[ i, 3, 1 ] ) + '.' + StrZero( np_arr_1_etap[ i, 3, 2 ], 2 ) ), 4 )
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
          If np_arr_1_etap[ i, 2, 1 ] > 0
            ls += lstr( np_arr_1_etap[ i, 2, 1 ] ) + ' ' + s_let( np_arr_1_etap[ i, 2, 1 ] ) + ' '
          Endif
          If np_arr_1_etap[ i, 2, 2 ] > 0
            ls += lstr( np_arr_1_etap[ i, 2, 2 ] ) + ' ' + mes_cev( np_arr_1_etap[ i, 2, 2 ] )
          Endif
          ls := RTrim( ls ) + ')'
        Else
          ls := 'Должен быть период ' + ;
            iif( np_arr_1_etap[ i, 2, 1 ] == 0, '', lstr( np_arr_1_etap[ i, 2, 1 ] ) + 'г.' ) + ;
            iif( np_arr_1_etap[ i, 2, 2 ] == 0, '', lstr( np_arr_1_etap[ i, 2, 2 ] ) + 'мес.' ) + '-' + ;
            iif( np_arr_1_etap[ i, 3, 1 ] == 0, '', lstr( np_arr_1_etap[ i, 3, 1 ] ) + 'г.' ) + ;
            iif( np_arr_1_etap[ i, 3, 2 ] == 0, '', lstr( np_arr_1_etap[ i, 3, 2 ] ) + 'мес.' ) + ', а у Вас ' + ;
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

// 04.02.16 вернуть шифр услуги законченного случая для ПредН
Function ret_shifr_zs_predn( _period )

  Local lshifr := ''

  Do Case
  Case _period == 1
    lshifr := iif( m1lis == 1, '72.3.5', '72.3.1' )// 'Законченный случай предварительного осмотра несовершеннолетних при поступлении в ДОУ 1 этап'
  Case _period == 2
    lshifr := iif( m1lis == 1, '72.3.6', '72.3.2' )// 'Законченный случай предварительного осмотра несовершеннолетних при поступлении в ООУ 1 этап'
  Case _period == 3
    lshifr := iif( m1lis == 1, '72.3.7', '72.3.3' )// 'Законченный случай предварительного осмотра несовершеннолетних при поступлении в ОУ НПО, ВПО, СОУ, ОУ для детей-сирот от 0 до 14 лет 1 этап'
  Case _period == 4
    lshifr := iif( m1lis == 1, '72.3.8', '72.3.4' )// 'Законченный случай предварительного осмотра несовершеннолетних при поступлении в ОУ НПО, ВПО, СОУ, ОУ для детей-сирот с 15 лет 1 этап'
  Endcase

  Return lshifr

// 14.08.13
Function add_pediatr_predn( _pv, _pa, _date, _diag )

  Local arr[ 9 ]

  AFill( arr, 0 )

  Select P2
  find ( Str( _pv, 5 ) )
  If Found()
    arr[ 1 ] := p2->kod
    arr[ 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
  Endif
  If !Empty( _pa )
    Select P2
    find ( Str( _pa, 5 ) )
    If Found()
      arr[ 3 ] := p2->kod
    Endif
  Endif
  arr[ 4 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), 57, 68 ) // профиль
  arr[ 5 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), '2.86.15', '2.86.14' ) // шифр услуги
  If Empty( _diag ) .or. Left( _diag, 1 ) == 'Z'
    arr[ 6 ] := mdef_diagnoz
  Else
    arr[ 6 ] := _diag
    Select MKB_10
    find ( PadR( arr[ 6 ], 6 ) )
    If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
      func_error( 4, 'Несовместимость диагноза по полу ' + arr[ 6 ] )
    Endif
  Endif
  arr[ 9 ] := _date

  Return arr

// 25.08.13 вернуть шифр услуги законченного случая для ПерН
Function ret_shifr_zs_pern( _period )

  Local lshifr := ''

  Do Case
  Case _period == 1
    lshifr := iif( m1lis == 1, '72.4.3', '72.4.1' ) // 'Законченный случай периодического осмотра несовершеннолетних, обучающихся в ДОУ
  Case _period == 2
    lshifr := iif( m1lis == 1, '72.4.4', '72.4.2' ) // 'Законченный случай периодического осмотра несовершеннолетних, обучающихся в ООУ, ОУ НПО, ВПО, СОУ, ОУ для детей-сирот
  Endcase

  Return lshifr

// 25.08.13
Function add_pediatr_pern( _pv, _pa, _date, _diag )

  Local arr[ 9 ]

  AFill( arr,  0 )
  Select P2
  find ( Str( _pv, 5 ) )
  If Found()
    arr[ 1 ] := p2->kod
    arr[ 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
  Endif
  If !Empty( _pa )
    Select P2
    find ( Str( _pa, 5 ) )
    If Found()
      arr[ 3 ] := p2->kod
    Endif
  Endif
  arr[ 4 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), 57, 68 ) // профиль
  // arr[5] := iif(eq_any(arr[2], 1110,-16), '2.3.2', '2.3.1') // шифр услуги
  arr[ 5 ] := '2.3.2' // шифр услуги
  If Empty( _diag ) .or. Left( _diag, 1 ) == 'Z'
    arr[ 6 ] := mdef_diagnoz
  Else
    arr[ 6 ] := _diag
    Select MKB_10
    find ( PadR( arr[ 6 ], 6 ) )
    If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
      func_error( 4, 'Несовместимость диагноза по полу ' + arr[ 6 ] )
    Endif
  Endif
  arr[ 9 ] := _date

  Return arr

// 18.10.22 вернуть тип вводимого листа учёта
Function ret_tip_lu( /*@*/stip)

  Local k := 0, tmp_select

  stip := '   '
  If Between( human->ishod, 101, 102 )
    k := iif( !Empty( human->ZA_SMO ), TIP_LU_DDS, TIP_LU_DDSOP )
    If human->ishod == 101
      stip := iif( !Empty( human->ZA_SMO ), 'ДС1', 'ДУ1' )
    Else // 102
      stip := iif( !Empty( human->ZA_SMO ), 'ДС2', 'ДУ2' )
    Endif
  Elseif Between( human->ishod, 201, 205 )
    k := TIP_LU_DVN
    If human->ishod == 201
      stip := 'ДВ1'
    Elseif eq_any( human->ishod, 202, 205 )
      stip := 'ДВ2'
    Elseif human->ishod == 204
      stip := 'ДВ3'
    Else // 203
      stip := 'ОПВ'
    Endif
  Elseif Between( human->ishod, 301, 302 )
    k := TIP_LU_PN
    If human->ishod == 301
      stip := 'ОН1'
    Else // 302
      stip := 'ОН2'
    Endif
  Elseif Between( human->ishod, 303, 304 )
    k := TIP_LU_PREDN
    If human->ishod == 303
      stip := 'ПО1'
    Else // 304
      stip := 'ПО2'
    Endif
  Elseif human->ishod == 305
    k := TIP_LU_PERN
    stip := 'ОПН'
  Elseif Between( human->ishod, 401, 402 )  // при углубленной диспансеризации после COVID
    k := TIP_LU_DVN_COVID
    If human->ishod == 401
      stip := 'УД1'             // для 1-го этапа
    Else // 402
      stip := 'УД2'             // для 2-го этапа
    Endif
  Elseif human->ishod == 98
    k := TIP_LU_G_CIT
  Elseif human->ishod == 99
    k := TIP_LU_PREND
  Endif

  If k == 0
    tmp_select := Select()
    r_use( dir_server + 'mo_otd', , '__OTD' )
    __otd->( dbGoto( glob_otd[ 1 ] ) )
    k := __otd->TIPLU
    __otd->( dbCloseArea() )
    If tmp_select > 0
      Select( tmp_select )
    Endif
  Endif

  Return k

// 06.11.19 сравнение профилей с учётом изменения правил в 2014 году
Function f_profil_ginek_otolar( lp1, lp2 )

  Static arr_ginek := { 2, 136 } // акушерству и гинекологии
  Static arr_otolar := { 64, 162 } // отоларингологии
  Local i, fl := .f.

  If ValType( lp1 ) == 'N'
    lp1 := { lp1 }
  Endif
  For i := 1 To Len( lp1 )
    If lp1[ i ] == lp2
      fl := .t.
    Elseif AScan( arr_ginek, lp1[ i ] ) > 0
      fl := ( AScan( arr_ginek, lp2 ) > 0 )
    Elseif AScan( arr_otolar, lp1[ i ] ) > 0
      fl := ( AScan( arr_otolar, lp2 ) > 0 )
    Endif
    If fl
      Exit
    Endif
  Next i

  Return fl
