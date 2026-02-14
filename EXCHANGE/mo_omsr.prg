//  mo_omsr.prg - работа с реестром в задаче ОМС
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// #define max_rec_reestr 9999

Static Sreestr_sem := 'Работа с реестрами'
Static Sreestr_err := 'В данный момент с реестрами работает другой пользователь.'
// Static sadiag1 := {}

//  25.03.22 скорректировать вид помощи для дневного стационара (в стационаре) по лицензии
Function ret_vidpom_licensia( lusl_ok, lvidpoms, lprofil )

  Static mo_licensia := { ;
    { '101004', 2, '31',   0 }, ;  // ВОУНЦ
    { '141023', 2, '31',   0 }, ;  // б-ца 15
    { '801935', 2, '31',   0 }, ;  // ЭКО-Москва
    { '391001', 2, '31',   0 }, ;  // Камышинская гор.б-ца 1
    { '101001', 2, '13',  60 }, ;  // ОКБ-1 - онкология
    { '451001', 2, '13',  60 }, ;  // Михайловская ЦРБ - онкология
    { '451001', 2, '13', 136 }, ;  // Михайловская ЦРБ - акушерству и гинекологии
    { '451001', 2, '13', 184 }, ;  // Михайловская ЦРБ - акушерству и гинекологии (искусственному прерыванию беременности)
    { '124528', 2, '13', 158 }, ;  // 28 п-ка - реабилитация
    { '805960', 2, '13',  97 } ;   // грязелечебница
  }
  Local i, fl := .f.
  For i := 1 To Len( mo_licensia )
    If mo_licensia[ i, 1 ] == glob_mo()[ _MO_KOD_TFOMS ] .and. mo_licensia[ i, 2 ] == lusl_ok
      If mo_licensia[ i, 4 ] == 0 // все профили
        lvidpoms := mo_licensia[ i, 3 ]
      Elseif mo_licensia[ i, 4 ] == lprofil // конкретный профиль
        lvidpoms := mo_licensia[ i, 3 ]
      Endif
    Endif
  Next i

  Return lvidpoms

//  24.02.21 скорректировать вид помощи для дневного стационара (в стационаре) по лицензии
Function ret_vidpom_st_dom_licensia( lusl_ok, lvidpoms, lprofil )

  Static mo_licensia := { ;
    { '591001', 2, '31', 68 };   // ЦРБ Суровикино
  }
  Local i, fl := .f.

  For i := 1 To Len( mo_licensia )
    If mo_licensia[ i, 1 ] == glob_mo()[ _MO_KOD_TFOMS ] .and. mo_licensia[ i, 2 ] == lusl_ok
      If mo_licensia[ i, 4 ] == 0 // все профили
        lvidpoms := mo_licensia[ i, 3 ]
      Elseif mo_licensia[ i, 4 ] == lprofil // конкретный профиль
        lvidpoms := mo_licensia[ i, 3 ]
      Endif
    Endif
  Next i

  Return lvidpoms


//  21.02.22 если это коммерческая скорая
Function is_komm_smp()

  Static _is
  Static a_komm_SMP := { ;
    '806501', ; // Волгоградская неотложка
    '806502', ; // Медтранс
    '806503' ;  // Волгоградская неотложка новая
    }

  If _is == Nil // т.е. определяется один раз за сеанс работы задачи
    _is := ( AScan( a_komm_SMP, glob_mo()[ _MO_KOD_TFOMS ] ) > 0 )
  Endif

  Return _is

//  14.02.14 является ли услуга 'с неотложной целью'
Function f_is_neotl_pom( lshifr )

  Static a_stom_n := { ; // при оказании неотложной помощи
  '57.1.72', '57.1.73', '57.1.74', '57.1.75', '57.1.76', '57.1.77', ;
    '57.1.78', '57.1.79', '57.1.80', '57.1.81';
    }

  lshifr := AllTrim( lshifr )

  Return eq_any( Left( lshifr, 5 ), '2.80.', '2.82.' ) .or. AScan( a_stom_n, lshifr ) > 0

//  18.11.14 зак.случай в п-ке
Function f_is_zak_sl_vr( lshifr )
  Return eq_any( Left( lshifr, 5 ), ;
    '2.78.', ; // Законченный случай обращения с лечебной целью к врачу ...
    '2.89.', ; // Законченный случай обращения с целью медицинской реабилитации
    '70.3.', ; // Законченный случай диспансеризации взрослого населения
    '70.5.', ; // Законченный случай диспансеризации детей-сирот в стационаре
    '70.6.', ; // Законченный случай диспансеризации детей-сирот под опекой
    '72.1.', ; // Законченный случай профосмотра взрослого населения
    '72.2.', ; // Законченный случай профосмотра несовершеннолетних
    '72.3.', ; // Законченный случай предварительного осмотра несовершеннолетних
    '72.4.' )  // Законченный случай периодического осмотра несовершеннолетних

//  13.02.14 является ли услуга первичным стоматологическим приёмом
Function f_is_1_stom( lshifr, ret_arr )

  Static a_1_stom := { ;
    '57.1.36', '57.1.39', '57.1.42', '57.1.45', '57.1.51', ; // 2013 год
    '57.1.57', '57.1.58', '57.1.59', '57.1.60', '57.1.61', ; // с лечебной
    '57.1.62', '57.1.64', '57.1.66', '57.1.68', '57.1.70', '57.5.1', ; // с профилактической
    '57.1.72', '57.1.74', '57.1.76', '57.1.78', '57.1.80';  // с неотложной
  }
  Local j

  lshifr := AllTrim( lshifr )
  If ValType( ret_arr ) == 'A'
    For j := 1 To Len( a_1_stom )
      AAdd( ret_arr, a_1_stom[ j ] )
    Next
  Endif

  Return AScan( a_1_stom, lshifr ) > 0

//  16.10.16 является ли услуга стоматологической с нулевой ценой
Function is_2_stomat( lshifr, /*@*/is_2_88, is_new )

  Local a_stom16_2 := { ;
    { 1, '2.78.47', '2.78.53' }, ; // с лечебной целью
    { 2, '2.79.52', '2.79.58' }, ; // с профилактической целью
    { 2, '2.88.40', '2.88.45' }, ; // -- ' -- ' -- ' -- ' -- разовое по поводу заболевания
    { 3, '2.80.29', '2.80.33' };  // при оказании неотложной помощи
  }
  Local j, ret := 0

  Default is_new To .f.
  If is_new // с 1 августа 2016 года
    a_stom16_2 := { ;
      { 1, '2.78.54', '2.78.60' }, ; // с лечебной целью
      { 2, '2.79.59', '2.79.64' }, ; // с профилактической целью
      { 2, '2.88.46', '2.88.51' }, ; // -- ' -- ' -- ' -- ' -- разовое по поводу заболевания
      { 3, '2.80.34', '2.80.38' };  // при оказании неотложной помощи
    }
  Endif
  is_2_88 := .f.
  lshifr := AllTrim( lshifr )
  For j := 1 To Len( a_stom16_2 )
    If between_shifr( lshifr, a_stom16_2[ j, 2 ], a_stom16_2[ j, 3 ] )
      ret := a_stom16_2[ j, 1 ]
      is_2_88 := ( j == 3 )
      Exit
    Endif
  Next

  Return ret

//  12.03.18 пересечение в стоматологическом случае разных видов посещений
Function f_vid_p_stom( arr_usl, ta, ret_arr, ret_tip_a, lk_data, /*@*/ret_tip, /*@*/ret_kol, /*@*/is_2_88, arrFusl )
/*
 arr_usl   - двумерный массив, шифр услуги в первом элементе
 ta        - массив с текстами ошибок
 ret_arr   - возвращаемый массив врачебных приёмов в зависимости от содержания ret_tip_a
 ret_tip_a - м.б. {1,2,3}(default), {1}, {2}, {3}
 lk_data   - дата окончания случая
 ret_tip   - 2016 год - возврат типа (от 1 до 3)
 ret_kol   - 2016 год - возврат количества врачебных приёмов в случае
 is_2_88   - является ли разовым по поводу заболевания
 arrFusl   - двумерный массив, шифр услуги ФФОМС в первом элементе
*/

  Static a_stom14 := { ; // с лечебной целью
    { ;
      '57.1.35', '57.1.37', '57.1.38', '57.1.40', '57.1.41', ;
      '57.1.43', '57.1.44', '57.1.46', '57.1.52', ;
      '57.1.57', '57.1.58', '57.1.59', '57.1.60', '57.1.61', ;
      '57.4.38', '57.4.39', '57.4.40', '57.4.41';
    }, ;
    { ; // с профилактической целью
      '57.1.62', '57.1.63', '57.1.64', '57.1.65', '57.1.66', '57.1.67', ;
      '57.1.68', '57.1.69', '57.1.70', '57.1.71', '57.5.1', '57.5.2';
    }, ;
    { ; // при оказании неотложной помощи
      '57.1.72', '57.1.73', '57.1.74', '57.1.75', '57.1.76', '57.1.77', ;
      '57.1.78', '57.1.79', '57.1.80', '57.1.81';
    };
    }
  Static a_stom15 := { ; // с лечебной целью
    { ;
      '57.1.35', '57.1.37', '57.1.38', '57.1.40', '57.1.41', ;
      '57.1.43', '57.1.44', '57.1.46', '57.1.52', ;
      '57.1.57', '57.1.58', '57.1.59', '57.1.60', '57.1.61', ;
      '57.4.38', '57.4.39', '57.4.41';
    }, ;
    { ; // с профилактической целью
      '57.4.40', '57.5.1', '57.5.2';
    }, ;
    {}; // при оказании неотложной помощи
  }
  Static a_old_stom16 := { ;
    { ;
      '57.1.57', '57.1.58', '57.1.59', '57.1.60', '57.1.61', '57.4.38', ; // с лечебной целью
      '57.1.37', '57.1.40', '57.1.43', '57.1.46', '57.1.52', '57.4.39', '57.4.40', '57.4.41' ;
    }, ;
    { ;
      '57.1.57', '57.1.58', '57.1.59', '57.1.60', '57.1.61', '57.4.38', ; // с профилактической целью
      '57.5.1', '57.5.2', '57.4.40', '57.4.41', ;
      '57.1.37', '57.1.40', '57.1.43', '57.1.46', '57.1.52', '57.4.39' ;
    }, ;
    { ;
      '57.1.57', '57.1.58', '57.1.59', '57.1.60', '57.1.61', ;           // при оказании неотложной помощи
      '57.1.37', '57.1.40', '57.1.43', '57.1.46', '57.1.52' ;
    };
  }
  Static a_old_stom16_2 := { ;
    { 1, '2.78.47', '2.78.53' }, ; // с лечебной целью
    { 2, '2.79.52', '2.79.58' }, ; // с профилактической целью
    { 2, '2.88.40', '2.88.45' }, ; // -- ' -- ' -- ' -- ' -- разовое по поводу заболевания
    { 3, '2.80.29', '2.80.33' };  // при оказании неотложной помощи
  }
  // с 1 августа 2016 года
  Static a_new_stom16 := { ;
    { 'B01.064.003', 'B01.064.004', 'B01.065.001', 'B01.065.002', 'B01.065.003', 'B01.065.004', 'B01.065.007', 'B01.065.008', 'B01.067.001', 'B01.067.002', 'B01.063.001', 'B01.063.002' }, ;
    { 'B04.064.001', 'B04.064.002', 'B04.065.001', 'B04.065.002', 'B04.065.003', 'B04.065.004', 'B04.065.005', 'B04.065.006', 'B01.065.005', 'B01.065.006', 'B04.063.001' }, ;
    { 'B01.064.003', 'B01.064.004', 'B01.065.001', 'B01.065.002', 'B01.065.003', 'B01.065.004', 'B01.065.007', 'B01.065.008', 'B01.067.001', 'B01.067.002', 'B01.063.001', 'B01.063.002' }, ;
    { 'B01.064.003', 'B01.064.004', 'B01.065.001', 'B01.065.002', 'B01.065.003', 'B01.065.004', 'B01.065.007', 'B01.065.008', 'B01.067.001', 'B01.067.002' };
  }
  Static a_new_stom16_2 := { ;
    { 1, '2.78.54', '2.78.60' }, ; // с лечебной целью
    { 2, '2.79.59', '2.79.64' }, ; // с профилактической целью
    { 2, '2.88.46', '2.88.51' }, ; // -- ' -- ' -- ' -- ' -- разовое по поводу заболевания
    { 3, '2.80.34', '2.80.38' };  // при оказании неотложной помощи
  }
  Static a_coord_stom18 := { ;
    { { '2.78.54', '2.78.55', '2.79.59', '2.88.46', '2.80.34' }, { 'B01.065.001', 'B01.065.002', 'B04.065.001', 'B04.065.002' } }, ; // терапевт
    { { '2.78.56', '2.88.51', '2.80.35' }, { 'B01.067.001', 'B01.067.002' } }, ; // хирург
    { { '2.78.57', '2.79.62', '2.88.49' }, { 'B01.063.001', 'B01.063.002', 'B04.063.001' } }, ; // ортодонт
    { { '2.78.58', '2.79.60', '2.88.47', '2.80.37' }, { 'B01.064.003', 'B01.064.004', 'B04.064.001', 'B04.064.002' } }, ; // детский
    { { '2.78.60', '2.79.63', '2.88.50', '2.80.38' }, { 'B01.065.003', 'B01.065.004', 'B04.065.003', 'B04.065.004' } }, ; // зубной врач
    { { '2.79.64' }, { 'B01.065.005', 'B01.065.006' } }, ; // гигиенист
    { { '2.78.59', '2.79.61', '2.88.48', '2.80.36' }, { 'B01.065.007', 'B01.065.008', 'B04.065.005', 'B04.065.006' } }; // общей практики
  }
  // первичные приёмы
  Static a_new_1st_stom16 := { ;
    'B01.063.001', 'B01.064.003', 'B01.065.001', 'B01.065.003', 'B01.065.005', 'B01.065.007', 'B01.067.001' ;
  }
  //
  Local a_stom, a_stom16_2, i, j, jm, k := 0, n := 0, lshifr, s := '', y, is_new, lshifr2 := ''
  
  If ValType( lk_data ) == 'D' .and. ( y := Year( lk_data ) ) > 2015 // 2016 год
    jm := 0
    ret_tip := 0
    ret_kol := 0
    is_2_88 := .f.
    is_new := ( lk_data >= 0d20160801 )
    If is_new // с 1 августа 2016 года
      a_stom16_2 := a_new_stom16_2
    Else
      a_stom16_2 := a_old_stom16_2
    Endif
    For i := 1 To Len( arr_usl )
      lshifr := AllTrim( arr_usl[ i, 1 ] )
      For j := 1 To Len( a_stom16_2 )
        If between_shifr( lshifr, a_stom16_2[ j, 2 ], a_stom16_2[ j, 3 ] )
          lshifr2 := lshifr
          k += arr_usl[ i, 6 ] // складываем количество услуг 2.*
          jm := j
          ret_tip := a_stom16_2[ j, 1 ]
          is_2_88 := ( j == 3 )
          ++n
          s += ' ' + lshifr
          Exit
        Endif
      Next
    Next
    If n == 0
      AAdd( ta, 'не введена нулевая стомат.услуга (2.78.*,2.79.*,2.80.*,2.88.*)' )
    Elseif n > 1
      AAdd( ta, 'пересечение в стомат.случае разных видов посещений -' + s )
    Elseif k != 1
      AAdd( ta, 'количество стомат.услуг должно быть =1 (2.78.*,2.79.*,2.80.*,2.88.*)' )
    Else
      If is_new // с 1 августа 2016 года
        k := 0
        For i := 1 To Len( arrFusl )
          lshifr := AllTrim( arrFusl[ i, 1 ] )
          s := lshifr + iif( Empty( arrFusl[ i, 5 ] ), '', ' (' + AllTrim( arrFusl[ i, 5 ] ) + ')' )
          If AScan( a_new_1st_stom16, lshifr ) > 0
            ++k
          Endif
          If eq_any( Left( lshifr, 3 ), 'B01', 'B04' )
            If AScan( a_new_stom16[ jm ], lshifr ) > 0
              ret_kol += arrFusl[ i, 6 ] // складываем количество услуг
              If Len( arrFusl[ i ] ) > 9
                arrFusl[ i, 10 ] := 1
              Endif
              If arrFusl[ i, 6 ] > 1
                AAdd( ta, 'в услуге ' + s + ' количество больше 1' )
              Endif
              If y > 2017 .and. !Empty( lshifr2 )
                For j := 1 To Len( a_coord_stom18 )
                  If AScan( a_coord_stom18[ j, 2 ], lshifr ) > 0 .and. AScan( a_coord_stom18[ j, 1 ], lshifr2 ) == 0
                    AAdd( ta, 'врачебный приём ' + s + ' не соответствует услуге ' + lshifr2 )
                  Endif
                Next j
              Endif
            Else
              For j := 1 To Len( a_new_stom16 )
                If j == jm
                  loop
                Endif
                If AScan( a_new_stom16[ j ], lshifr ) > 0
                  AAdd( ta, 'услуга ' + s + ' относится к другому типу листа учёта' )
                  Exit
                Endif
              Next
            Endif
          Endif
        Next
        If k > 1
          AAdd( ta, 'услуга первичного стоматологического приёма оказана более одного раза в данном случае' )
        Endif
      Else
        a_stom := a_old_stom16
        For i := 1 To Len( arr_usl )
          lshifr := AllTrim( arr_usl[ i, 1 ] )
          If AScan( a_stom[ ret_tip ], lshifr ) > 0
            ret_kol += arr_usl[ i, 6 ] // складываем количество услуг
            If Len( arr_usl[ i ] ) > 9
              arr_usl[ i, 10 ] := 1
            Endif
          Endif
        Next
      Endif
    Endif
  Else // 2015 год и ранее
    If ValType( lk_data ) == 'D' .and. lk_data > SToD( '20150630' )
      a_stom := a_stom15
    Else
      a_stom := a_stom14
    Endif
    For i := 1 To 3
      For j := 1 To Len( arr_usl )
        If ( k := AScan( a_stom[ i ], AllTrim( arr_usl[ j, 1 ] ) ) ) > 0
          ++n
          s += ' ' + a_stom[ i, k ]
          Exit
        Endif
      Next
    Next
    If n == 0
      AAdd( ta, 'не было ввода ни одного стоматологического посещения' )
    Elseif n > 1
      AAdd( ta, 'пересечение в стомат.случае разных видов посещений -' + s )
    Endif
  Endif
  If ValType( ret_arr ) == 'A'
    Default ret_tip_a TO { 1, 2, 3 }
    For i := 1 To 3
      If AScan( ret_tip_a, i ) > 0
        For j := 1 To Len( a_stom[ i ] )
          AAdd( ret_arr, a_stom[ i, j ] )
        Next
      Endif
    Next
  Endif

  Return ( n == 1 )

//  11.03.14 дневной стационар с 1 апреля 2013 года
Function f_dn_stac_01_04( lshifr )
  Return eq_any( Left( lshifr, 5 ), '55.5.', '55.6.', '55.7.', '55.8.' )

//  21.02.14 проверка, не встречаются ли в строке нецифровые значения
Function mo_nodigit( s )
  Return !Empty( CharRepl( '0123456789', s, Space( 10 ) ) )

//  13.04.14
Function correct_profil( lp )

  If lp == 2 // акушерству и гинекологии
    lp := 136 // акушерству и гинекологии (за исключением использования вспомогательных репродуктивных технологий)
  Elseif lp == 64 // оториноларингологии
    lp := 162 // оториноларингологии (за исключением кохлеарной имплантации)
  Endif

  Return lp


// 07.06.24
Function f_create_diag_srok( nameFile )

//  dbCreate( cur_dir() + 'tmp_d_srok', ;
  dbCreate( cur_dir() + alltrim( nameFile ), ;
    { ;
      { 'kod', 'N', 7, 0 }, ;
      { 'tip', 'N', 1, 0 }, ;
      { 'tips', 'C', 3, 0 }, ;
      { 'otd', 'N', 3, 0 }, ;
      { 'kod1', 'N', 7, 0 }, ;
      { 'tip1', 'N', 1, 0 }, ;
      { 'tip1s', 'C', 3, 0 }, ;
      { 'dni', 'N', 2, 0 } ;
    } )
  // Use ( cur_dir() + 'tmp_d_srok' ) New Alias D_SROK

  Return Nil

//  24.06.20
Function f_napr_mo_lis()

  human_->( dbGoto( human->( RecNo() ) ) )

  Return human_->NPR_MO


// 12.02.26 Просмотр списка реестров, запись для ТФОМС
Function view_list_reestr()

  Local buf := SaveScreen(), tmp_help := chm_help_code

  If !g_slock( Sreestr_sem )
    Return func_error( 4, Sreestr_err )
  Endif
  Private goal_dir := dir_server() + dir_XML_MO() + hb_ps()
  g_use( dir_server() + 'mo_xml',, 'MO_XML' )
  g_use( dir_server() + 'mo_rees',, 'REES' )
  Index On DToS( FIELD->dschet ) + Str( FIELD->nschet, 6 ) to ( cur_dir() + 'tmp_rees' ) DESCENDING
  Go Top
  If Eof()
    func_error( 4, 'Нет реестров' )
  Else
    chm_help_code := 113
    Private reg := 1

    box_shadow( MaxRow() -3, 0, MaxRow() -1, 79, color0 )
//    alpha_browse( T_ROW, 0, 23, 79, 'f1_view_list_reestr', color0,,,,,, 'f21_view_list_reestr', ;
    alpha_browse( T_ROW, 0, MaxRow() -4, 79, 'f1_view_list_reestr', color0,,,,,, 'f21_view_list_reestr', ;
      'f2_view_list_reestr',, { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, W+/R, G+/RB+, GR+/B', .t., 180 } )
  Endif
  Close databases
  g_sunlock( Sreestr_sem )
  chm_help_code := tmp_help
  RestScreen( buf )
  Return Nil


// 12.02.26 
Function f1_view_list_reestr( oBrow ) 

  Local oColumn, ;
    blk := {|| ;
      iif ( rees->nyear < 2026, ;
        iif( hb_FileExists( goal_dir + AllTrim( rees->NAME_XML ) + szip() ), ;
          iif( Empty( rees->date_out ), { 3, 4 }, { 1, 2 } ), ;
            { 5, 6 } ), ;
        iif( rees->res_tfoms == 0, { 1, 2 }, ;      // ответ не зачитан
          iif( rees->res_tfoms == 1, { 7, 8 }, ;    // ответ без ошибок
            iif( rees->res_tfoms == 2, { 5, 6 }, ;  // ответ с ошибками на весь файл
              { 3, 4 } ) ) ) ) }                    // ответ с ошибками в записях реестра

//{ '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, W+/R, G+/RB+, GR+/B', .t., 180 }
//        iif( rees->res_tfoms == 1, { 3, 2 }, { 1, 2 } ) ) }

//    blk := {|| iif( hb_FileExists( goal_dir + AllTrim( rees->NAME_XML ) + szip() ), ;
//    iif( Empty( rees->date_out ), { 3, 4 }, { 1, 2 } ), ;
//    { 5, 6 } ) }

//  oColumn := TBColumnNew( '', {|| Str( rees->res_tfoms, 1 ) } )
//  oColumn:colorBlock := blk
//  oBrow:addcolumn( oColumn )

  oColumn := TBColumnNew( ' Номер', {|| rees->nschet } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '  Дата', {|| date_8( rees->dschet ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Пери-;од', ;
    {|| iif( emptyany( rees->nyear, rees->nmonth ), ;
    Space( 5 ), ;
    Right( lstr( rees->nyear ), 2 ) + '/' + StrZero( rees->nmonth, 2 ) ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Сумма реестра', {|| PadL( expand_value( rees->summa, 2 ), 13 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Кол.;бол.', {|| Str( rees->kol, 4 ) } )  //  5 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
//  oColumn := TBColumnNew( ' Наименование файла', {|| PadR( rees->NAME_XML, 22 ) } )
  oColumn := TBColumnNew( ' Наименование файла', {|| Substr( rees->NAME_XML, 1, 26 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Примечание', {|| f11_view_list_reestr() } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If reg == 1
    status_key( '^<Esc>^ выход; ^<F5>^ запись для ТФОМС; ^<F3>^ информация о реестре; ^<F9>^ статистика' )
  Else
    status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор реестра для возврата' )
  Endif

  Return Nil

// 12.02.26 
Function f11_view_list_reestr()

  Local s := ''

  if rees->res_tfoms == 1
    s := 'принят'
  elseif rees->res_tfoms == 2
    s := 'отказ'
  elseif rees->res_tfoms == 3
    s := 'ошибки'
  else
    If ! hb_FileExists( goal_dir + AllTrim( rees->NAME_XML ) + szip() )
      s := 'нет файла'
    Elseif Empty( rees->date_out )
      s := 'не записан'
    Else
      s := 'зап. ' + lstr( rees->NUMB_OUT ) + 'раз'
    Endif
  endif

  Return PadR( s, 9 ) //  10 )


// 14.02.26
Function f2_view_list_reestr( nKey, oBrow )

  Local ret := -1, rec := rees->( RecNo() ), tmp_color := SetColor(), r, r1, r2, ;
    s, buf := SaveScreen(), arr, i, k, mdate, t_arr[ 2 ], arr_pmt := {}
  local nfile
  local arr_title

  Do Case
  Case nKey == K_F7
    XML_files_to_FTP( AllTrim( rees->NAME_XML ), rees->kod )
  Case nKey == K_F5
    r := Row()
    arr := {}
    k := 0
    mdate := rees->dschet
    find ( DToS( mdate ) )
    Do While rees->dschet == mdate .and. !Eof()
      If !emptyany( rees->name_xml, rees->kod_xml )
        AAdd( arr, { rees->nschet, rees->name_xml, rees->kod_xml, rees->( RecNo() ) } )
        If Empty( rees->date_out )
          ++k
        Endif
      Endif
      Skip
    Enddo
    If Len( arr ) == 0
      func_error( 4, 'Нечего записывать!' )
    Else
      If Len( arr ) > 1
        ASort( arr,,, {| x, y| x[ 1 ] < y[ 1 ] } )
        For i := 1 To Len( arr )
          rees->( dbGoto( arr[ i, 4 ] ) )
          AAdd( arr_pmt, { 'Реестр № ' + lstr( rees->nschet ) + ' (' + ;
            lstr( rees->nyear ) + '/' + StrZero( rees->nmonth, 2 ) + ;
            ') файл ' + AllTrim( rees->name_xml ), AClone( arr[ i ] ) } )
        Next
        If r + 2 + Len( arr ) > MaxRow() -2
          r2 := r - 1
          r1 := r2 - Len( arr ) -1
          If r1 < 0
            r1 := 0
          Endif
        Else
          r1 := r + 1
        Endif
        arr := {}
        If ( t_arr := bit_popup( r1, 10, arr_pmt,, color5, 1, 'Записываемые файлы реестров (' + date_8( mdate ) + ')', 'B/W' ) ) != NIL
          AEval( t_arr, {| x| AAdd( arr, AClone( x[ 2 ] ) ) } )
        Endif
        t_arr := Array( 2 )
      Endif
      If Len( arr ) > 0
        s := 'Количество реестров - ' + lstr( Len( arr ) ) + ;
          ', записываются в первый раз - ' + lstr( k ) + ':'
        For i := 1 To Len( arr )
          If i > 1
            s += ','
          Endif
          s += ' ' + lstr( arr[ i, 1 ] ) + ' (' + AllTrim( arr[ i, 2 ] ) + szip() + ')'
        Next
        If k > 0
          f_message( { 'Обращаем Ваше внимание, что после записи реестра', ;
            'НЕВОЗМОЖНО будет выполнить ВОЗВРАТ реестра' },, 'GR+/R', 'W+/R', 2 )
        Endif
        perenos( t_arr, s, 74 )
        f_message( t_arr,, color1, color8 )
        If f_esc_enter( 'записи реестров за ' + date_8( mdate ) )
          Private p_var_manager := 'copy_schet'
          s := manager( T_ROW, T_COL + 5, MaxRow() -2,, .t., 2, .f.,,, ) // 'norton' для выбора каталога
          If !Empty( s )
            If Upper( s ) == Upper( goal_dir )
              func_error( 4, 'Вы выбрали каталог, в котором уже записаны целевые файлы! Это недопустимо.' )
            Else
              cFileProtokol := cur_dir() + 'protrees.txt'
              StrFile( hb_eol() + Center( glob_mo()[ _MO_SHORT_NAME ], 80 ) + hb_eol() + hb_eol(), cFileProtokol )
              smsg := 'Реестры записаны на: ' + s + ;
                ' (' + full_date( sys_date ) + 'г. ' + hour_min( Seconds() ) + ')'
              StrFile( Center( smsg, 80 ) + hb_eol(), cFileProtokol, .t. )
              k := 0
              For i := 1 To Len( arr )
                rees->( dbGoto( arr[ i, 4 ] ) )
                smsg := lstr( i ) + '. Реестр № ' + lstr( rees->nschet ) + ;
                  ' от ' + date_8( mdate ) + 'г. (отч.период ' + ;
                  lstr( rees->nyear ) + '/' + StrZero( rees->nmonth, 2 ) + ;
                  ') ' + AllTrim( rees->name_xml ) + szip()
                StrFile( hb_eol() + smsg + hb_eol(), cFileProtokol, .t. )
                smsg := '   количество пациентов - ' + lstr( rees->kol ) + ;
                  ', сумма реестра - ' + expand_value( rees->summa, 2 )
                StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                zip_file := AllTrim( arr[ i, 2 ] ) + szip()
                If hb_FileExists( goal_dir + zip_file )
                  mywait( 'Копирование "' + zip_file + '" в каталог "' + s + '"' )
                  // copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
                  Copy File ( goal_dir + zip_file ) to ( s + zip_file )
                  // if hb_fileExists(hb_OemToAnsi(s)+zip_file)
                  If hb_FileExists( s + zip_file )
                    ++k
                    rees->( g_rlock( forever ) )
                    rees->DATE_OUT := sys_date
                    If rees->NUMB_OUT < 99
                      rees->NUMB_OUT++
                    Endif
                    //
                    mo_xml->( dbGoto( arr[ i, 3 ] ) )
                    mo_xml->( g_rlock( forever ) )
                    mo_xml->DREAD := sys_date
                    mo_xml->TREAD := hour_min( Seconds() )
                  Else
                    smsg := '! Ошибка записи файла ' + s + zip_file
                    func_error( 4, smsg )
                    StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                  Endif
                Else
                  smsg := '! Не обнаружен файл ' + goal_dir + zip_file
                  func_error( 4, smsg )
                  StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                Endif
              Next
              Unlock
              Commit
              viewtext( cFileProtokol,,,, .t.,,, 2 )
            Endif
          Endif
        Endif
      Endif
    Endif
    Select REES
    Goto ( rec )
    ret := 0
  Case nKey == K_F3
    f3_view_list_reestr( oBrow )
    ret := 0
  Case nKey == K_F9
    mywait()
    r_use( dir_server() + 'mo_rhum',, 'RHUM' )
    nfile := cur_dir() + 'reesstat.txt'
    sh := 80
    HH := 60
    fp := FCreate( nfile )
    n_list := 1
    tek_stroke := 0
    
    oldy := oldm := 0
    Select REES
    Index On Str( FIELD->NYEAR, 4 ) to ( cur_dir() + 'tmpr1' ) unique
    rees->( dbGoBottom() )  //  Go Bottom
    Private syear := rees->NYEAR
    Index On Str( FIELD->NYEAR, 4 ) + Str( FIELD->NMONTH, 2 ) + Str( FIELD->NSCHET, 6 ) to ( cur_dir() + 'tmpr1' ) For FIELD->NYEAR == syear
    rees->( dbGoTop() ) //  Go Top

    add_string( '' )
    if syear >= 2026
      add_string( Center( 'Статистика по реестрам счетов принятых ТФОМС', sh ) )
    else
      add_string( Center( 'Статистика по реестрам', sh ) )
    endif
    add_string( '' )
    arr_title := { ;
      '──────┬────────┬────────────────────┬────┬────────────┬───────┬─────────────┬───', ;
      'Номер │  Дата  │   Наименование     │Кол.│    Сумма   │Реестры│Кол-во не об-│Ста', ;
      'реестр│ реестра│   файла реестра    │боль│   реестра  │СП и ТК│работ.в ТФОМС│тус', ;
      '──────┴────────┴────────────────────┴────┴────────────┴───────┴─────────────┴───' }
    AEval( arr_title, {| x| add_string( x ) } )

    Do While ! rees->( Eof() )
      if rees->nyear >= 2026 .and. rees->RES_TFOMS != 1
        rees->( dbSkip() )
        loop
      endif
      If verify_ff( HH - 2, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If !( oldy == rees->NYEAR .and. oldm == rees->NMONTH )
        add_string( '' )
        add_string( PadC( 'Отчётный период ' + lstr( rees->nyear ) + '/' + StrZero( rees->nmonth, 2 ), sh, '_' ) )
        oldy := rees->NYEAR
        oldm := rees->NMONTH
        @ MaxRow(), 1 Say lstr( rees->nyear ) + '/' + StrZero( rees->nmonth, 2 ) Color cColorWait
      Endif
      s := Str( rees->NSCHET, 6 ) + ' ' + date_8( rees->DSCHET ) + ' ' + PadR( rees->NAME_XML, 20 ) + ;
        Str( rees->KOL, 5 ) + put_kop( rees->SUMMA, 13 )
      Select MO_XML
      Index On FIELD->FNAME to ( cur_dir() + 'tmp_x2' ) ;
        For FIELD->reestr == rees->kod .and. FIELD->TIP_OUT == 0 .and. FIELD->TIP_IN == _XML_FILE_SP
      kol_sp := 0
      dbEval( {|| ++kol_sp } )
      Select RHUM
      Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + 'tmp_r2' ) ;
        For FIELD->reestr == rees->kod .and. FIELD->OPLATA == 0
      kol_ne := 0
      dbEval( {|| ++kol_ne } )
      s += PadC( iif( kol_sp == 0, '-', lstr( kol_sp ) ), 9 )
      s += PadC( iif( kol_ne == 0, '-', lstr( kol_ne ) ), 13 )
      s += ' ' + iif( kol_ne == 0, ' =', '!!!' )
      add_string( s )
      Select REES
      Skip
    Enddo
    Close databases
    FClose( fp )
    Keyboard Chr( K_END )
    viewtext( nfile,,,,,,, 2,,, .f. )
    g_use( dir_server() + 'mo_xml',, 'MO_XML' )
    g_use( dir_server() + 'mo_rees', cur_dir() + 'tmp_rees', 'REES' )
    Goto ( rec )
    ret := 0
  Case nKey == K_CTRL_F12
    ret := delete_reestr_sp_tk( rees->( RecNo() ), AllTrim( rees->NAME_XML ) )
    Close databases
    g_use( dir_server() + 'mo_xml',, 'MO_XML' )
    g_use( dir_server() + 'mo_rees', cur_dir() + 'tmp_rees', 'REES' )
    Goto ( rec )
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret


// 14.02.26
Function f3_view_list_reestr( oBrow )

  Static si := 1
  Local i, r := Row(), r1, r2, buf := save_maxrow(), ;
    mm_func := iif( rees->nyear < 2026, { 0, -1, -2, -3 }, { 0, -1 } ), ;
    mm_menu := {}

  AAdd( mm_menu, 'Версия программы: ' + iif( Empty( rees->VER_APP ), 'до версии 5.11.1', AllTrim( rees->VER_APP ) ) )
  AAdd( mm_menu, 'Список ~всех пациентов в реестре' )
  if rees->nyear < 2026
    AAdd( mm_menu, 'Список ~обработанных в ТФОМС' )
    AAdd( mm_menu, 'Список ~не обработанных в ТФОМС' )
  endif
  mywait()
  Select MO_XML
  Index On FIELD->FNAME to ( cur_dir() + 'tmp_xml' ) ;
    For FIELD->reestr == rees->kod .and. eq_any( FIELD->TIP_IN, _XML_FILE_FLK, _XML_FILE_SP, _XML_FILE_SCHET_26, _XML_FILE_FLK_26 ) .and. Empty( FIELD->TIP_OUT )
//    For FIELD->reestr == rees->kod .and. Between( FIELD->TIP_IN, _XML_FILE_FLK, _XML_FILE_SP, _XML_FILE_SCHET_26, _XML_FILE_FLK_26 ) .and. Empty( FIELD->TIP_OUT )
  mo_xml->( dbGoTop() )   //  Go Top
  Do While ! mo_xml->( Eof() )
    AAdd( mm_func, mo_xml->kod )
    AAdd( mm_menu, 'Протокол чтения ' + RTrim( mo_xml->FNAME ) + iif( Empty( mo_xml->TWORK2 ), '-ЧТЕНИЕ НЕ ЗАВЕРШЕНО', '' ) )
    mo_xml->( dbSkip() )    //Skip
  Enddo
  Select MO_XML
  Set Index To
  If r <= 12
    r1 := r + 1
    r2 := r1 + Len( mm_menu ) + 1
  Else
    r2 := r - 1
    r1 := r2 - Len( mm_menu ) - 1
  Endif
  rest_box( buf )
  If ( i := popup_prompt( r1, 10, si, mm_menu,,, color5 ) ) > 0
    if i == 1
      Select REES
      return Nil
    endif
    si := i
    If mm_func[ i ] < 0
      f31_view_list_reestr( Abs( mm_func[ i ] ), mm_menu[ i ] )
    Else
      mo_xml->( dbGoto( mm_func[ i ] ) )
      viewtext( devide_into_pages( dir_server() + dir_XML_TF() + hb_ps() + AllTrim( mo_xml->FNAME ) + stxt(), 60, 80 ),,,, .t.,,, 2 )
    Endif
  Endif
  Select REES

  Return Nil


//  15.02.19
Function f31_view_list_reestr( reg, s )

  Local fl := .t., buf := save_maxrow(), s1, lal, n_file := cur_dir() + 'reesspis.txt'

  mywait()
  fp := FCreate( n_file )
  tek_stroke := 0
  n_list := 1
  add_string( '' )
  add_string( Center( 'Список пациентов реестра № ' + lstr( rees->nschet ) + ' от ' + date_8( rees->dschet ), 80 ) )
  add_string( Center( '( ' + CharRem( '~', s ) + ' )', 80 ) )
  add_string( '' )
  r_use( dir_server() + 'mo_otd',, 'OTD' )
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  r_use( dir_server() + 'human',, 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To FIELD->otd into OTD
  r_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
  r_use( dir_server() + 'mo_rhum',, 'RHUM' )
  Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->reestr == rees->kod
  Go Top
  Do While !Eof()
    Do Case
    Case reg == 1
      fl := .t.
    Case reg == 2
      fl := ( rhum->OPLATA > 0 )
    Case reg == 3
      fl := ( rhum->OPLATA == 0 )
    Endcase
    If fl
      Select HUMAN
      Goto ( rhum->kod_hum )
      lal := 'human'
      s1 := ''
      If human->ishod == 88
        s1 := ' 2сл'
        Select HUMAN_3
        Set Order To 1
        find ( Str( rhum->kod_hum, 7 ) )
        lal += '_3'
      Elseif human->ishod == 89
        s1 := ' 2сл'
        Select HUMAN_3
        Set Order To 2
        find ( Str( rhum->kod_hum, 7 ) )
        lal += '_3'
      Endif
      s := PadR( human->fio, 50 -Len( s1 ) ) + s1 + ' ' + otd->short_name + ;
        ' ' + date_8( &lal.->n_data ) + '-' + date_8( &lal.->k_data )
      If rhum->REES_ZAP < 10000
        s := Str( rhum->REES_ZAP, 4 ) + '. ' + s
      Else
        s := lstr( rhum->REES_ZAP ) + '.' + s
      Endif
      verify_ff( 60, .t., 80 )
      add_string( s )
    Endif
    Select RHUM
    Skip
  Enddo
  human_3->( dbCloseArea() )
  human_->( dbCloseArea() )
  human->( dbCloseArea() )
  otd->( dbCloseArea() )
  rhum->( dbCloseArea() )
  FClose( fp )
  rest_box( buf )
  viewtext( n_file,,,, .t.,,, 2 )

  Return Nil

// 12.02.26
Function f21_view_list_reestr() 

  Local s := '', fl := .t., r := Row(), c := Col()

  if rees->nyear >= 2026
    s := 'Счет № ' + AllTrim( rees->nomer_s ) + ' от ' + DToC( rees->dschet ) + '. '
    if rees->res_tfoms == 1
      s += 'Реестр - принят.'
    elseif rees->res_tfoms == 2
      s += 'Реестр - отказ на уровне файла.'
    elseif rees->res_tfoms == 3
      s += 'Реестр - отказ по причине ошибок.'
    else
      s += 'Ответ ТФОМС не получен.'
    endif
  else
    s := 'Информации по счетам отсутствует'
  endif
  @ MaxRow() -2, 1 Say PadC( s, 78 ) Color iif( fl, color0, 'R/BG' )
  SetPos( r, c )
  Return Nil
