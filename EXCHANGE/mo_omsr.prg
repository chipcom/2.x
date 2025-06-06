//  mo_omsr.prg - работа с реестром в задаче ОМС
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// #define max_rec_reestr 9999

Static Sreestr_sem := "Работа с реестрами"
Static Sreestr_err := "В данный момент с реестрами работает другой пользователь."
// Static sadiag1 := {}

//  25.03.22 скорректировать вид помощи для дневного стационара (в стационаре) по лицензии
Function ret_vidpom_licensia( lusl_ok, lvidpoms, lprofil )

  Static mo_licensia := { ;
    { '101004', 2, '31', 0 }, ;  // ВОУНЦ
    { '141023', 2, '31', 0 }, ;  // б-ца 15
    { '801935', 2, '31', 0 }, ;  // ЭКО-Москва
    { '391001', 2, '31', 0 }, ;  // Камышинская гор.б-ца 1
    { '101001', 2, '13', 60 }, ;   // ОКБ-1 - онкология
    { '451001', 2, '13', 60 }, ;   // Михайловская ЦРБ - онкология
    { '451001', 2, '13', 136 }, ;   // Михайловская ЦРБ - акушерству и гинекологии
    { '451001', 2, '13', 184 }, ;   // Михайловская ЦРБ - акушерству и гинекологии (искусственному прерыванию беременности)
    { '124528', 2, '13', 158 }, ;   // 28 п-ка - реабилитация
    { '805960', 2, '13', 97 };   // грязелечебница
  }
  Local i, fl := .f.
  For i := 1 To Len( mo_licensia )
    If mo_licensia[ i, 1 ] == glob_mo[ _MO_KOD_TFOMS ] .and. mo_licensia[ i, 2 ] == lusl_ok
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
    If mo_licensia[ i, 1 ] == glob_mo[ _MO_KOD_TFOMS ] .and. mo_licensia[ i, 2 ] == lusl_ok
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
    "806501", ; // Волгоградская неотложка
    "806502", ; // Медтранс
    "806503";   // Волгоградская неотложка новая
    }
  If _is == Nil // т.е. определяется один раз за сеанс работы задачи
    _is := ( AScan( a_komm_SMP, glob_mo[ _MO_KOD_TFOMS ] ) > 0 )
  Endif

  Return _is

//  14.02.14 является ли услуга "с неотложной целью"
Function f_is_neotl_pom( lshifr )

  Static a_stom_n := { ; // при оказании неотложной помощи
  "57.1.72", "57.1.73", "57.1.74", "57.1.75", "57.1.76", "57.1.77", ;
    "57.1.78", "57.1.79", "57.1.80", "57.1.81";
    }
  lshifr := AllTrim( lshifr )

  Return eq_any( Left( lshifr, 5 ), "2.80.", "2.82." ) .or. AScan( a_stom_n, lshifr ) > 0

//  18.11.14 зак.случай в п-ке
Function f_is_zak_sl_vr( lshifr )
  Return eq_any( Left( lshifr, 5 ), ;
    "2.78.", ; // Законченный случай обращения с лечебной целью к врачу ...
"2.89.", ; // Законченный случай обращения с целью медицинской реабилитации
    "70.3.", ; // Законченный случай диспансеризации взрослого населения
"70.5.", ; // Законченный случай диспансеризации детей-сирот в стационаре
    "70.6.", ; // Законченный случай диспансеризации детей-сирот под опекой
"72.1.", ; // Законченный случай профосмотра взрослого населения
    "72.2.", ; // Законченный случай профосмотра несовершеннолетних
"72.3.", ; // Законченный случай предварительного осмотра несовершеннолетних
    "72.4." )  // Законченный случай периодического осмотра несовершеннолетних

//  13.02.14 является ли услуга первичным стоматологическим приёмом
Function f_is_1_stom( lshifr, ret_arr )

  Static a_1_stom := { ;
    "57.1.36", "57.1.39", "57.1.42", "57.1.45", "57.1.51", ; // 2013 год
    "57.1.57", "57.1.58", "57.1.59", "57.1.60", "57.1.61", ; // с лечебной
    "57.1.62", "57.1.64", "57.1.66", "57.1.68", "57.1.70", "57.5.1", ; // с профилактической
    "57.1.72", "57.1.74", "57.1.76", "57.1.78", "57.1.80";  // с неотложной
  }
  Local j
  lshifr := AllTrim( lshifr )
  If ValType( ret_arr ) == "A"
    For j := 1 To Len( a_1_stom )
      AAdd( ret_arr, a_1_stom[ j ] )
    Next
  Endif

  Return AScan( a_1_stom, lshifr ) > 0

//  16.10.16 является ли услуга стоматологической с нулевой ценой
Function is_2_stomat( lshifr, /*@*/is_2_88,is_new)

  Local a_stom16_2 := { ;
    { 1, "2.78.47", "2.78.53" }, ; // с лечебной целью
    { 2, "2.79.52", "2.79.58" }, ; // с профилактической целью
    { 2, "2.88.40", "2.88.45" }, ; // -- " -- " -- " -- " -- разовое по поводу заболевания
    { 3, "2.80.29", "2.80.33" };  // при оказании неотложной помощи
  }
  Local j, ret := 0
  Default is_new To .f.
  If is_new // с 1 августа 2016 года
    a_stom16_2 := { ;
      { 1, "2.78.54", "2.78.60" }, ; // с лечебной целью
    { 2, "2.79.59", "2.79.64" }, ; // с профилактической целью
    { 2, "2.88.46", "2.88.51" }, ; // -- " -- " -- " -- " -- разовое по поводу заболевания
    { 3, "2.80.34", "2.80.38" };  // при оказании неотложной помощи
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
Function f_vid_p_stom( arr_usl, ta, ret_arr, ret_tip_a, lk_data, /*@*/ret_tip,/*@*/ret_kol,/*@*/is_2_88,arrFusl)
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
  { "57.1.35", "57.1.37", "57.1.38", "57.1.40", "57.1.41", ;
    "57.1.43", "57.1.44", "57.1.46", "57.1.52", ;
    "57.1.57", "57.1.58", "57.1.59", "57.1.60", "57.1.61", ;
    "57.4.38", "57.4.39", "57.4.40", "57.4.41";
    }, ;
    { ; // с профилактической целью
  "57.1.62", "57.1.63", "57.1.64", "57.1.65", "57.1.66", "57.1.67", ;
    "57.1.68", "57.1.69", "57.1.70", "57.1.71", "57.5.1", "57.5.2";
    }, ;
    { ; // при оказании неотложной помощи
  "57.1.72", "57.1.73", "57.1.74", "57.1.75", "57.1.76", "57.1.77", ;
    "57.1.78", "57.1.79", "57.1.80", "57.1.81";
    };
    }
  Static a_stom15 := { ; // с лечебной целью
  { "57.1.35", "57.1.37", "57.1.38", "57.1.40", "57.1.41", ;
    "57.1.43", "57.1.44", "57.1.46", "57.1.52", ;
    "57.1.57", "57.1.58", "57.1.59", "57.1.60", "57.1.61", ;
    "57.4.38", "57.4.39", "57.4.41";
    }, ;
    { ; // с профилактической целью
  "57.4.40", "57.5.1", "57.5.2";
    }, ;
    {}; // при оказании неотложной помощи
  }
  Static a_old_stom16 := { ;
    { "57.1.57", "57.1.58", "57.1.59", "57.1.60", "57.1.61", "57.4.38", ; // с лечебной целью
  "57.1.37", "57.1.40", "57.1.43", "57.1.46", "57.1.52", "57.4.39", "57.4.40", "57.4.41" }, ;
    { "57.1.57", "57.1.58", "57.1.59", "57.1.60", "57.1.61", "57.4.38", ; // с профилактической целью
  "57.5.1", "57.5.2", "57.4.40", "57.4.41", ;
    "57.1.37", "57.1.40", "57.1.43", "57.1.46", "57.1.52", "57.4.39" }, ;
    { "57.1.57", "57.1.58", "57.1.59", "57.1.60", "57.1.61", ;           // при оказании неотложной помощи
    "57.1.37", "57.1.40", "57.1.43", "57.1.46", "57.1.52" };
    }
  Static a_old_stom16_2 := { ;
    { 1, "2.78.47", "2.78.53" }, ; // с лечебной целью
  { 2, "2.79.52", "2.79.58" }, ; // с профилактической целью
  { 2, "2.88.40", "2.88.45" }, ; // -- " -- " -- " -- " -- разовое по поводу заболевания
  { 3, "2.80.29", "2.80.33" };  // при оказании неотложной помощи
  }
  // с 1 августа 2016 года
  Static a_new_stom16 := { ;
    { "B01.064.003", "B01.064.004", "B01.065.001", "B01.065.002", "B01.065.003", "B01.065.004", "B01.065.007", "B01.065.008", "B01.067.001", "B01.067.002", "B01.063.001", "B01.063.002" }, ;
    { "B04.064.001", "B04.064.002", "B04.065.001", "B04.065.002", "B04.065.003", "B04.065.004", "B04.065.005", "B04.065.006", "B01.065.005", "B01.065.006", "B04.063.001" }, ;
    { "B01.064.003", "B01.064.004", "B01.065.001", "B01.065.002", "B01.065.003", "B01.065.004", "B01.065.007", "B01.065.008", "B01.067.001", "B01.067.002", "B01.063.001", "B01.063.002" }, ;
    { "B01.064.003", "B01.064.004", "B01.065.001", "B01.065.002", "B01.065.003", "B01.065.004", "B01.065.007", "B01.065.008", "B01.067.001", "B01.067.002" };
    }
  Static a_new_stom16_2 := { ;
    { 1, "2.78.54", "2.78.60" }, ; // с лечебной целью
  { 2, "2.79.59", "2.79.64" }, ; // с профилактической целью
  { 2, "2.88.46", "2.88.51" }, ; // -- " -- " -- " -- " -- разовое по поводу заболевания
  { 3, "2.80.34", "2.80.38" };  // при оказании неотложной помощи
  }
  Static a_coord_stom18 := { ;
    { { "2.78.54", "2.78.55", "2.79.59", "2.88.46", "2.80.34" }, { "B01.065.001", "B01.065.002", "B04.065.001", "B04.065.002" } }, ; // терапевт
  { { "2.78.56", "2.88.51", "2.80.35" }, { "B01.067.001", "B01.067.002" } }, ; // хирург
  { { "2.78.57", "2.79.62", "2.88.49" }, { "B01.063.001", "B01.063.002", "B04.063.001" } }, ; // ортодонт
  { { "2.78.58", "2.79.60", "2.88.47", "2.80.37" }, { "B01.064.003", "B01.064.004", "B04.064.001", "B04.064.002" } }, ; // детский
  { { "2.78.60", "2.79.63", "2.88.50", "2.80.38" }, { "B01.065.003", "B01.065.004", "B04.065.003", "B04.065.004" } }, ; // зубной врач
  { { "2.79.64" }, { "B01.065.005", "B01.065.006" } }, ; // гигиенист
  { { "2.78.59", "2.79.61", "2.88.48", "2.80.36" }, { "B01.065.007", "B01.065.008", "B04.065.005", "B04.065.006" } }; // общей практики
  }
  // первичные приёмы
  Static a_new_1st_stom16 := { "B01.063.001", "B01.064.003", "B01.065.001", "B01.065.003", "B01.065.005", "B01.065.007", "B01.067.001" }
  //
  Local a_stom, a_stom16_2, i, j, jm, k := 0, n := 0, lshifr, s := "", y, is_new, lshifr2 := ""
  If ValType( lk_data ) == "D" .and. ( y := Year( lk_data ) ) > 2015 // 2016 год
    jm := 0 ; ret_tip := 0 ; ret_kol := 0 ; is_2_88 := .f.
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
          ++n ; s += ' ' + lshifr ; Exit
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
          If eq_any( Left( lshifr, 3 ), "B01", "B04" )
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
                If j == jm ; loop ; Endif
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
    If ValType( lk_data ) == "D" .and. lk_data > SToD( "20150630" )
      a_stom := a_stom15
    Else
      a_stom := a_stom14
    Endif
    For i := 1 To 3
      For j := 1 To Len( arr_usl )
        If ( k := AScan( a_stom[ i ], AllTrim( arr_usl[ j, 1 ] ) ) ) > 0
          ++n ; s += ' ' + a_stom[ i, k ] ; Exit
        Endif
      Next
    Next
    If n == 0
      AAdd( ta, 'не было ввода ни одного стоматологического посещения' )
    Elseif n > 1
      AAdd( ta, 'пересечение в стомат.случае разных видов посещений -' + s )
    Endif
  Endif
  If ValType( ret_arr ) == "A"
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
  Return eq_any( Left( lshifr, 5 ), "55.5.", "55.6.", "55.7.", "55.8." )

//  21.02.14 проверка, не встречаются ли в строке нецифровые значения
Function mo_nodigit( s )
  Return !Empty( CharRepl( "0123456789", s, Space( 10 ) ) )

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

//  dbCreate( cur_dir() + "tmp_d_srok", ;
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
  // Use ( cur_dir() + "tmp_d_srok" ) New Alias D_SROK

  Return Nil

//  24.06.20
Function f_napr_mo_lis()

  human_->( dbGoto( human->( RecNo() ) ) )

  Return human_->NPR_MO


//  Просмотр списка реестров, запись для ТФОМС
Function view_list_reestr()

  Local i, k, buf := SaveScreen(), tmp_help := chm_help_code

  If !g_slock( Sreestr_sem )
    Return func_error( 4, Sreestr_err )
  Endif
  Private goal_dir := dir_server() + dir_XML_MO() + hb_ps()
  g_use( dir_server() + "mo_xml",, "MO_XML" )
  g_use( dir_server() + "mo_rees",, "REES" )
  Index On DToS( dschet ) + Str( nschet, 6 ) to ( cur_dir() + "tmp_rees" ) DESCENDING
  Go Top
  If Eof()
    func_error( 4, "Нет реестров" )
  Else
    chm_help_code := 113
    Private reg := 1
    alpha_browse( T_ROW, 0, 23, 79, "f1_view_list_reestr", color0,,,,,,, ;
      "f2_view_list_reestr",, { '═', '░', '═', "N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R", .t., 180 } )
  Endif
  Close databases
  g_sunlock( Sreestr_sem )
  chm_help_code := tmp_help
  RestScreen( buf )

  Return Nil


// 
Function f1_view_list_reestr( oBrow )

  Local oColumn, ;
    blk := {|| iif( hb_FileExists( goal_dir + AllTrim( rees->NAME_XML ) + szip() ), ;
    iif( Empty( rees->date_out ), { 3, 4 }, { 1, 2 } ), ;
    { 5, 6 } ) }

  oColumn := TBColumnNew( " Номер", {|| rees->nschet } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "  Дата", {|| date_8( rees->dschet ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Пери-;од", ;
    {|| iif( emptyany( rees->nyear, rees->nmonth ), ;
    Space( 5 ), ;
    Right( lstr( rees->nyear ), 2 ) + "/" + StrZero( rees->nmonth, 2 ) ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Сумма реестра", {|| PadL( expand_value( rees->summa, 2 ), 15 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Кол.; бол.", {|| Str( rees->kol, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Наименование файла", {|| PadR( rees->NAME_XML, 22 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Примечание", {|| f11_view_list_reestr() } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If reg == 1
    status_key( "^<Esc>^ выход; ^<F5>^ запись для ТФОМС; ^<F3>^ информация о реестре; ^<F9>^ статистика" )
  Else
    status_key( "^<Esc>^ - выход;  ^<Enter>^ - выбор реестра для возврата" )
  Endif

  Return Nil


// 
Static Function f11_view_list_reestr()

  Local s := ""

  If !hb_FileExists( goal_dir + AllTrim( rees->NAME_XML ) + szip() )
    s := "нет файла"
  Elseif Empty( rees->date_out )
    s := "не записан"
  Else
    s := "зап. " + lstr( rees->NUMB_OUT ) + " раз"
  Endif

  Return PadR( s, 10 )


// 22.03.24
Function f2_view_list_reestr( nKey, oBrow )

  Local ret := -1, rec := rees->( RecNo() ), tmp_color := SetColor(), r, r1, r2, ;
    s, buf := SaveScreen(), arr, i, k, mdate, t_arr[ 2 ], arr_pmt := {}

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
      func_error( 4, "Нечего записывать!" )
    Else
      If Len( arr ) > 1
        ASort( arr,,, {| x, y| x[ 1 ] < y[ 1 ] } )
        For i := 1 To Len( arr )
          rees->( dbGoto( arr[ i, 4 ] ) )
          AAdd( arr_pmt, { "Реестр № " + lstr( rees->nschet ) + " (" + ;
            lstr( rees->nyear ) + "/" + StrZero( rees->nmonth, 2 ) + ;
            ") файл " + AllTrim( rees->name_xml ), AClone( arr[ i ] ) } )
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
        If ( t_arr := bit_popup( r1, 10, arr_pmt,, color5, 1, "Записываемые файлы реестров (" + date_8( mdate ) + ")", "B/W" ) ) != NIL
          AEval( t_arr, {| x| AAdd( arr, AClone( x[ 2 ] ) ) } )
        Endif
        t_arr := Array( 2 )
      Endif
      If Len( arr ) > 0
        s := "Количество реестров - " + lstr( Len( arr ) ) + ;
          ", записываются в первый раз - " + lstr( k ) + ":"
        For i := 1 To Len( arr )
          If i > 1
            s += ","
          Endif
          s += " " + lstr( arr[ i, 1 ] ) + " (" + AllTrim( arr[ i, 2 ] ) + szip() + ")"
        Next
        If k > 0
          f_message( { "Обращаем Ваше внимание, что после записи реестра", ;
            "НЕВОЗМОЖНО будет выполнить ВОЗВРАТ реестра" },, "GR+/R", "W+/R", 2 )
        Endif
        perenos( t_arr, s, 74 )
        f_message( t_arr,, color1, color8 )
        If f_esc_enter( "записи реестров за " + date_8( mdate ) )
          Private p_var_manager := "copy_schet"
          s := manager( T_ROW, T_COL + 5, MaxRow() -2,, .t., 2, .f.,,, ) // "norton" для выбора каталога
          If !Empty( s )
            If Upper( s ) == Upper( goal_dir )
              func_error( 4, "Вы выбрали каталог, в котором уже записаны целевые файлы! Это недопустимо." )
            Else
              cFileProtokol := cur_dir() + "protrees.txt"
              StrFile( hb_eol() + Center( glob_mo[ _MO_SHORT_NAME ], 80 ) + hb_eol() + hb_eol(), cFileProtokol )
              smsg := "Реестры записаны на: " + s + ;
                " (" + full_date( sys_date ) + "г. " + hour_min( Seconds() ) + ")"
              StrFile( Center( smsg, 80 ) + hb_eol(), cFileProtokol, .t. )
              k := 0
              For i := 1 To Len( arr )
                rees->( dbGoto( arr[ i, 4 ] ) )
                smsg := lstr( i ) + ". Реестр № " + lstr( rees->nschet ) + ;
                  " от " + date_8( mdate ) + "г. (отч.период " + ;
                  lstr( rees->nyear ) + "/" + StrZero( rees->nmonth, 2 ) + ;
                  ") " + AllTrim( rees->name_xml ) + szip()
                StrFile( hb_eol() + smsg + hb_eol(), cFileProtokol, .t. )
                smsg := "   количество пациентов - " + lstr( rees->kol ) + ;
                  ", сумма реестра - " + expand_value( rees->summa, 2 )
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
                    smsg := "! Ошибка записи файла " + s + zip_file
                    func_error( 4, smsg )
                    StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                  Endif
                Else
                  smsg := "! Не обнаружен файл " + goal_dir + zip_file
                  func_error( 4, smsg )
                  StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                Endif
              Next
              Unlock
              Commit
              viewtext( cFileProtokol,,,, .t.,,, 2 )
              /*asize(t_arr,1)
              perenos(t_arr,"Записано реестров - "+lstr(k)+" в каталог "+s+;
                     iif(k == len(arr), "", ", не записано реестров - "+lstr(len(arr)-k)),60)
              stat_msg("Запись завершена!")
              n_message(t_arr,,"GR+/B","W+/B",18,,"G+/B")*/
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
    r_use( dir_server() + "mo_rhum",, "RHUM" )
    nfile := cur_dir() + "reesstat.txt" ; sh := 80 ; HH := 60
    fp := FCreate( nfile ) ; n_list := 1 ; tek_stroke := 0
    add_string( "" )
    add_string( Center( "Статистика по реестрам", sh ) )
    add_string( "" )
    arr_title := { ;
      "──────┬────────┬────────────────────┬────┬────────────┬───────┬─────────────┬───", ;
      "Номер │  Дата  │   Наименование     │Кол.│    Сумма   │Реестры│Кол-во не об-│Ста", ;
      "реестр│ реестра│   файла реестра    │боль│   реестра  │СП и ТК│работ.в ТФОМС│тус", ;
      "──────┴────────┴────────────────────┴────┴────────────┴───────┴─────────────┴───" }
    AEval( arr_title, {| x| add_string( x ) } )
    oldy := oldm := 0
    Select REES
    Index On Str( NYEAR, 4 ) to ( cur_dir() + "tmpr1" ) unique
    Go Bottom
    Private syear := rees->NYEAR
    Index On Str( NYEAR, 4 ) + Str( NMONTH, 2 ) + Str( NSCHET, 6 ) to ( cur_dir() + "tmpr1" ) For NYEAR == syear
    Go Top
    Do While !Eof()
      If verify_ff( HH - 2, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If !( oldy == rees->NYEAR .and. oldm == rees->NMONTH )
        add_string( "" )
        add_string( PadC( "Отчётный период " + lstr( rees->nyear ) + "/" + StrZero( rees->nmonth, 2 ), sh, "_" ) )
        oldy := rees->NYEAR ; oldm := rees->NMONTH
        @ MaxRow(), 1 Say lstr( rees->nyear ) + "/" + StrZero( rees->nmonth, 2 ) Color cColorWait
      Endif
      s := Str( rees->NSCHET, 6 ) + " " + date_8( rees->DSCHET ) + " " + PadR( rees->NAME_XML, 20 ) + ;
        Str( rees->KOL, 5 ) + put_kop( rees->SUMMA, 13 )
      Select MO_XML
      Index On FNAME to ( cur_dir() + "tmp_x2" ) ;
        For reestr == rees->kod .and. TIP_OUT == 0 .and. TIP_IN == _XML_FILE_SP
      kol_sp := 0 ; dbEval( {|| ++kol_sp } )
      Select RHUM
      Index On Str( REES_ZAP, 6 ) to ( cur_dir() + "tmp_r2" ) ;
        For reestr == rees->kod .and. OPLATA == 0
      kol_ne := 0 ; dbEval( {|| ++kol_ne } )
      s += PadC( iif( kol_sp == 0, "-", lstr( kol_sp ) ), 9 )
      s += PadC( iif( kol_ne == 0, "-", lstr( kol_ne ) ), 13 )
      s += " " + iif( kol_ne == 0, " =", "!!!" )
      add_string( s )
      Select REES
      Skip
    Enddo
    Close databases
    FClose( fp )
    Keyboard Chr( K_END )
    viewtext( nfile,,,,,,, 2,,, .f. )
    g_use( dir_server() + "mo_xml",, "MO_XML" )
    g_use( dir_server() + "mo_rees", cur_dir() + "tmp_rees", "REES" )
    Goto ( rec )
    ret := 0
  Case nKey == K_CTRL_F12
    ret := delete_reestr_sp_tk( rees->( RecNo() ), AllTrim( rees->NAME_XML ) )
    Close databases
    g_use( dir_server() + "mo_xml",, "MO_XML" )
    g_use( dir_server() + "mo_rees", cur_dir() + "tmp_rees", "REES" )
    Goto ( rec )
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )

  Return ret


// 22.03.24
Function f3_view_list_reestr( oBrow )

  Static si := 1
  Local i, r := Row(), r1, r2, buf := save_maxrow(), ;
    mm_func := { -1, -2, -3 }, ;
    mm_menu := { "Список ~всех пациентов в реестре", ;
    "Список ~обработанных в ТФОМС", ;
    "Список ~не обработанных в ТФОМС" }

  mywait()
  Select MO_XML
  Index On FNAME to ( cur_dir() + "tmp_xml" ) ;
    For reestr == rees->kod .and. Between( TIP_IN, _XML_FILE_FLK, _XML_FILE_SP ) .and. Empty( TIP_OUT )
  Go Top
  Do While !Eof()
    AAdd( mm_func, mo_xml->kod )
    AAdd( mm_menu, "Протокол чтения " + RTrim( mo_xml->FNAME ) + iif( Empty( mo_xml->TWORK2 ), "-ЧТЕНИЕ НЕ ЗАВЕРШЕНО", "" ) )
    Skip
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

  Local fl := .t., buf := save_maxrow(), s1, lal, n_file := cur_dir() + "reesspis.txt"

  mywait()
  fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Список пациентов реестра № " + lstr( rees->nschet ) + " от " + date_8( rees->dschet ), 80 ) )
  add_string( Center( "( " + CharRem( "~", s ) + " )", 80 ) )
  add_string( "" )
  r_use( dir_server() + "mo_otd",, "OTD" )
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human",, "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To otd into OTD
  r_use( dir_server() + "human_3", { dir_server() + "human_3", dir_server() + "human_32" }, "HUMAN_3" )
  r_use( dir_server() + "mo_rhum",, "RHUM" )
  Index On Str( REES_ZAP, 6 ) to ( cur_dir() + "tmp_rhum" ) For reestr == rees->kod
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
      lal := "human"
      s1 := ""
      If human->ishod == 88
        s1 := " 2сл"
        Select HUMAN_3
        Set Order To 1
        find ( Str( rhum->kod_hum, 7 ) )
        lal += "_3"
      Elseif human->ishod == 89
        s1 := " 2сл"
        Select HUMAN_3
        Set Order To 2
        find ( Str( rhum->kod_hum, 7 ) )
        lal += "_3"
      Endif
      s := PadR( human->fio, 50 -Len( s1 ) ) + s1 + " " + otd->short_name + ;
        " " + date_8( &lal.->n_data ) + "-" + date_8( &lal.->k_data )
      If rhum->REES_ZAP < 10000
        s := Str( rhum->REES_ZAP, 4 ) + ". " + s
      Else
        s := lstr( rhum->REES_ZAP ) + "." + s
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

//  вернуть ещё не записанный на дискету реестр
Function vozvrat_reestr()

  Local i, k, buf := SaveScreen(), arr, tmp_help := chm_help_code, mkod_reestr

  If ! hb_user_curUser:isadmin()
    Return func_error( 4, err_admin )
  Endif
  If !g_slock( Sreestr_sem )
    Return func_error( 4, Sreestr_err )
  Endif
  Private goal_dir := dir_server() + dir_XML_MO() + hb_ps()
  g_use( dir_server() + "mo_rees",, "REES" )
  Index On DToS( dschet ) + Str( nschet, 6 ) to ( cur_dir() + "tmp_rees" ) DESCENDING For Empty( date_out )
  Go Top
  If Eof()
    func_error( 4, "Не обнаружено реестров, не отправленных в ТФОМС" )
  Else
    chm_help_code := 114
    Private reg := 2
    If alpha_browse( T_ROW, 0, 23, 79, "f1_view_list_reestr", color0,,,, .t.,,,,, ;
        { '═', '░', '═', "N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",, 60 } )
      mkod_reestr := rees->KOD
      mywait()
      g_use( dir_server() + "mo_xml",, "MO_XML" )
      Index On FNAME to ( cur_dir() + "tmp_xml" ) For reestr == mkod_reestr .and. TIP_OUT == 0
      k := kol_err := 0
      Go Top
      Do While !Eof()
        If mo_xml->TIP_IN == _XML_FILE_SP
          ++k
        Elseif mo_xml->TIP_IN == _XML_FILE_FLK
          kol_err += mo_xml->kol2
        Endif
        Skip
      Enddo
      If k > 0
        func_error( 4, "По данному реестру уже были прочитаны реестры СП и ТК. Возврат ЗАПРЕЩЁН!" )
      Elseif kol_err > 0
        func_error( 4, "По данному реестру был прочитан протокол ФЛК с ошибками. Возврат ЗАПРЕЩЁН!" )
      Else
        f1vozvrat_reestr( mkod_reestr )
      Endif
    Endif
  Endif
  Close databases
  g_sunlock( Sreestr_sem )
  chm_help_code := tmp_help
  RestScreen( buf )

  Return Nil


//  15.02.19
Static Function f1vozvrat_reestr( mkod_reestr )

  Local buf := SaveScreen()

  Close databases
  g_use( dir_server() + "mo_rees",, "REES" )
  Goto ( mkod_reestr )
  stat_msg( "" )
  arr := {}
  AAdd( arr, "Удаляется реестр № " + lstr( rees->nschet ) + " от " + full_date( rees->dschet ) + "г." )
  AAdd( arr, 'за период "' + iif( Between( rees->nmonth, 1, 12 ), mm_month[ rees->nmonth ], lstr( rees->nmonth ) + " месяц" ) + ;
    Str( rees->nyear, 5 ) + ' года".' )
  AAdd( arr, "Сумма реестра " + lput_kop( rees->summa, .t. ) + ;
    " руб., количество пациентов " + lstr( rees->kol ) + " чел." )
  AAdd( arr, "Наименование файла " + AllTrim( rees->NAME_XML ) )
  AAdd( arr, "" )
  AAdd( arr, "После подтверждения удаления пациенты будут вычеркнуты" )
  AAdd( arr, "из данного реестра, а реестр будет удален." )
  f_message( arr,, color1, color8 )
  If f_esc_enter( "удаления реестра № " + lstr( rees->nschet ), .t. )
    stat_msg( "Подтвердите удаление ещё раз." ) ; mybell( 2 )
    If f_esc_enter( "удаления реестра № " + lstr( rees->nschet ), .t. )
      mywait( "Ждите. Производится удаление реестра." )
      g_use( dir_server() + "human_u_",, "HU_" )
      r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
      Set Relation To RecNo() into HU_
      g_use( dir_server() + "human_3", { dir_server() + "human_3", dir_server() + "human_32" }, "HUMAN_3" )
      g_use( dir_server() + "human",, "HUMAN" )
      g_use( dir_server() + "human_",, "HUMAN_" )
      g_use( dir_server() + "mo_rhum",, "RHUM" )
      Index On Str( reestr, 6 ) to ( cur_dir() + "tmp_rhum" )
      Do While .t.
        Select RHUM
        find ( Str( mkod_reestr, 6 ) )
        If !Found() ; exit ; Endif
        //
        Select HUMAN_
        Goto ( rhum->KOD_HUM )
        If human_->REESTR == mkod_reestr // на всякий случай
          Select HUMAN
          Goto ( rhum->KOD_HUM )
          If human->ishod == 88 // сначала проверим, не двойной ли это случай (по-старому)
            Select HUMAN_3
            Set Order To 1
            find ( Str( human->kod, 7 ) )
            If Found()
              Select HUMAN_
              Goto ( human_3->kod2 ) // встать на 2-ой лист учёта
              Select HU
              find ( Str( human_3->kod2, 7 ) )
              Do While human_3->kod2 == hu->kod .and. !Eof()
                hu_->( g_rlock( forever ) )
                hu_->REES_ZAP := 0
                hu_->( dbUnlock() )
                Select HU
                Skip
              Enddo
              human_->( g_rlock( forever ) )
              If human_->REES_NUM > 0
                human_->REES_NUM := human_->REES_NUM - 1
              Endif
              human_->REES_ZAP := 0
              human_->REESTR := 0
              human_->( dbUnlock() )
              // обработка заголовка двойного случая
              human_3->( g_rlock( forever ) )
              If human_3->REES_NUM > 0
                human_3->REES_NUM := human_3->REES_NUM - 1
              Endif
              human_3->REES_ZAP := 0
              human_3->REESTR := 0
              human_3->( dbUnlock() )
            Endif
            // возвращаемся к 1-му листу учёта
            Select HUMAN_
            Goto ( rhum->KOD_HUM )
            Select HU
            find ( Str( rhum->KOD_HUM, 7 ) )
            Do While rhum->KOD_HUM == hu->kod .and. !Eof()
              hu_->( g_rlock( forever ) )
              hu_->REES_ZAP := 0
              hu_->( dbUnlock() )
              Select HU
              Skip
            Enddo
            human_->( g_rlock( forever ) )
            If human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM - 1
            Endif
            human_->REES_ZAP := 0
            human_->REESTR := 0
            human_->( dbUnlock() )
          Elseif human->ishod == 89 // теперь проверим, не двойной ли это случай (по-новому)
            // сначала обработаем 2-ой случай
            Select HU
            find ( Str( rhum->KOD_HUM, 7 ) )
            Do While rhum->KOD_HUM == hu->kod .and. !Eof()
              hu_->( g_rlock( forever ) )
              hu_->REES_ZAP := 0
              hu_->( dbUnlock() )
              Select HU
              Skip
            Enddo
            human_->( g_rlock( forever ) )
            If human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM - 1
            Endif
            human_->REES_ZAP := 0
            human_->REESTR := 0
            human_->( dbUnlock() )
            // поищем 1-ый случай
            Select HUMAN_3
            Set Order To 2
            find ( Str( human->kod, 7 ) )
            If Found()
              Select HUMAN_
              Goto ( human_3->kod ) // встать на 1-ый лист учёта
              Select HU
              find ( Str( human_3->kod2, 7 ) )
              Do While human_3->kod2 == hu->kod .and. !Eof()
                hu_->( g_rlock( forever ) )
                hu_->REES_ZAP := 0
                hu_->( dbUnlock() )
                Select HU
                Skip
              Enddo
              human_->( g_rlock( forever ) )
              If human_->REES_NUM > 0
                human_->REES_NUM := human_->REES_NUM - 1
              Endif
              human_->REES_ZAP := 0
              human_->REESTR := 0
              human_->( dbUnlock() )
              // обработка заголовка двойного случая
              human_3->( g_rlock( forever ) )
              If human_3->REES_NUM > 0
                human_3->REES_NUM := human_3->REES_NUM - 1
              Endif
              human_3->REES_ZAP := 0
              human_3->REESTR := 0
              human_3->( dbUnlock() )
            Endif
          Else
            // обработка одинарного случая
            Select HUMAN_
            Goto ( rhum->KOD_HUM )
            Select HU
            find ( Str( rhum->KOD_HUM, 7 ) )
            Do While rhum->KOD_HUM == hu->kod .and. !Eof()
              hu_->( g_rlock( forever ) )
              hu_->REES_ZAP := 0
              hu_->( dbUnlock() )
              Select HU
              Skip
            Enddo
            human_->( g_rlock( forever ) )
            If human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM - 1
            Endif
            human_->REES_ZAP := 0
            human_->REESTR := 0
            human_->( dbUnlock() )
          Endif
        Endif
        //
        Select RHUM
        deleterec( .t. )
      Enddo
      zip_file := AllTrim( rees->name_xml ) + szip()
      If hb_FileExists( goal_dir + zip_file )
        Delete File ( goal_dir + zip_file )
      Endif
      g_use( dir_server() + "mo_xml",, "MO_XML" )
      Goto ( rees->KOD_XML )
      If !Eof() .and. !Deleted()
        deleterec( .t. )
      Endif
      Select REES
      deleterec( .t. )
      stat_msg( "Реестр удалён!" ) ; mybell( 2, OK )
    Endif
  Endif
  Close databases
  RestScreen( buf )

  Return Nil


//  15.10.24 аннулировать чтение реестра СП и ТК по реестру с кодом mkod_reestr
Function delete_reestr_sp_tk( mkod_reestr, mname_reestr )

  Local i, s, r := Row(), r1, r2, buf := save_maxrow(), ;
    mm_menu := {}, mm_func := {}, mm_flag := {}, mreestr_sp_tk, ;
    arr_f, cFile, oXmlDoc, aerr := {}, is_allow_delete, ;
    cFileProtokol := cur_dir() + "tmp.txt", is_other_reestr, bSaveHandler, ;
    arr_schet, rees_nschet := rees->nschet, mtip_in

  mywait()
  Select MO_XML
  Index On FNAME to ( cur_dir() + "tmp_xml" ) For reestr == mkod_reestr .and. TIP_OUT == 0
  Go Top
  Do While !Eof()
    If mo_xml->TIP_IN == _XML_FILE_SP
      AAdd( mm_func, mo_xml->kod )
      s := "Реестр СП и ТК " + RTrim( mo_xml->FNAME ) + " прочитан " + date_8( mo_xml->DWORK )
      If Empty( mo_xml->TWORK2 )
        AAdd( mm_flag, .t. )
        s += "-ПРОЦЕСС НЕ ЗАВЕРШЁН"
      Else
        AAdd( mm_flag, .f. )
        s += " в " + mo_xml->TWORK1
      Endif
      AAdd( mm_menu, s )
    Elseif mo_xml->TIP_IN == _XML_FILE_FLK
      If mo_xml->kol2 > 0
        AAdd( mm_func, mo_xml->kod )
        AAdd( mm_flag, .f. )
        s := "Протокол ФЛК " + RTrim( mo_xml->FNAME ) + " прочитан " + date_8( mo_xml->DWORK ) + " в " + mo_xml->TWORK1
        AAdd( mm_menu, s )
      Endif
    Endif
    Skip
  Enddo
  Select MO_XML
  Set Index To
  rest_box( buf )
  If Len( mm_menu ) == 0
    If involved_password( 1, rees_nschet, "подтверждения возврата (удаления) реестра" )
      f1vozvrat_reestr( mkod_reestr )
    Endif
    Return 1
  Endif
  If r <= 18
    r1 := r + 1 ; r2 := r1 + Len( mm_menu ) + 1
  Else
    r2 := r - 1 ; r1 := r2 - Len( mm_menu ) -1
  Endif
  If ( i := popup_prompt( r1, 10, 1, mm_menu,,, color5 ) ) > 0
    is_allow_delete := mm_flag[ i ]
    mreestr_sp_tk := mm_func[ i ]
    mywait()
    Select MO_XML
    Goto ( mreestr_sp_tk )
    cFile := AllTrim( mo_xml->FNAME )
    mtip_in := mo_xml->TIP_IN
    Close databases
    If mtip_in == _XML_FILE_SP // возврат реестра СП и ТК
      If ( arr_f := extract_zip_xml( dir_server() + dir_XML_TF(), cFile + szip() ) ) != Nil .and. mo_lock_task( X_OMS )
        cFile += sxml()
        // читаем файл в память
        oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile )
        If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
          func_error( 4, "Ошибка в чтении файла " + cFile )
        Else // читаем и записываем XML-файл во временные TMP-файлы
          reestr_sp_tk_tmpfile( oXmlDoc, aerr, cFile )
          If !Empty( aerr )
            ins_array( aerr, 1, "" )
            ins_array( aerr, 1, Center( "Ошибки в чтении файла " + cFile, 80 ) )
            AEval( aerr, {| x| StrFile( x + hb_eol(), cFileProtokol, .t. ) } )
            viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
            Delete File ( cFileProtokol )
          Else
            // если точно попал в другой реестр
            is_other_reestr := is_delete_human := .f.
            r_use( dir_server() + "human",, "HUMAN" )
            r_use( dir_server() + "human_",, "HUMAN_" )
            r_use( dir_server() + "mo_rhum",, "RHUM" )
            Index On Str( REES_ZAP, 6 ) to ( cur_dir() + "tmp_rhum" ) For reestr == mkod_reestr
            Select TMP2
            Go Top
            Do While !Eof()
              Select RHUM
              find ( Str( tmp2->_N_ZAP, 6 ) )
              If Found()
                tmp2->kod_human := rhum->KOD_HUM
                Select HUMAN
                Goto ( rhum->KOD_HUM )
                If emptyany( human->kod, human->fio )
                  is_delete_human := .t. ; Exit
                Endif
                Select HUMAN_
                Goto ( rhum->KOD_HUM )
                If human_->REESTR > 0 .and. human_->REESTR != mkod_reestr
                  is_other_reestr := .t. ; Exit
                Endif
              Endif
              Select TMP2
              Skip
            Enddo
            If !is_other_reestr .and. !is_delete_human
              // если попал в другой реестр, вернулся с ошибкой, и отредактирован
              r_use( dir_server() + "mo_rees",, "REES" )
              Select RHUM
              Set Relation To reestr into REES
              // сортируем пациентов по дате попадания в реестры
              Index On Str( kod_hum, 7 ) + DToS( rees->DSCHET ) to ( cur_dir() + "tmp_rhum" )
              Select TMP2
              Go Top
              Do While !Eof()
                r := r1 := 0
                Select RHUM
                find ( Str( tmp2->kod_human, 7 ) )
                Do While tmp2->kod_human == rhum->KOD_HUM
                  ++r // во сколько реестров попал
                  If rhum->reestr == mkod_reestr
                    r1 := r // какой по номеру текущий реестр
                  Endif
                  Skip
                Enddo
                If r1 > 0 .and. r > r1  // если текущий реестр не последний
                  is_other_reestr := .t. ; Exit
                Endif
                Select TMP2
                Skip
              Enddo
            Endif
            If is_delete_human
              func_error( 10, "Некоторые пациенты из данного реестра уже УДАЛЕНЫ. Операция запрещена!" )
            Elseif is_other_reestr
              func_error( 10, "Пациенты из данного реестра уже ПОПАЛИ В ДРУГОЙ РЕЕСТР. Операция запрещена!" )
            Else
              If !is_allow_delete .and. involved_password( 1, rees_nschet, "аннулирования чтения реестра СП и ТК" )
                is_allow_delete := .t.
              Endif
              If is_allow_delete
                Close databases
                arr_schet := {}
                r_use( dir_server() + "schet_",, "SCH" )
                Index On nschet to ( cur_dir() + "tmp_sch" ) For XML_REESTR == mreestr_sp_tk
                dbEval( {|| AAdd( arr_schet, { AllTrim( nschet ), RecNo(), KOD_XML } ) } )
                sch->( dbCloseArea() )
                is_allow_delete := .f.
                g_use( dir_server() + "mo_rees",, "REES" )
                Goto ( mkod_reestr )
                Use ( cur_dir() + "tmp1file" ) New Alias TMP1
                Use ( cur_dir() + "tmp2file" ) New Alias TMP2
                arr := {}
                AAdd( arr, "Реестр № " + lstr( rees->nschet ) + " от " + full_date( rees->dschet ) + "г." )
                AAdd( arr, 'период "' + lstr( rees->nmonth ) + "/" + lstr( rees->nyear ) + ;
                  '", сумма ' + lput_kop( rees->summa, .t. ) + ;
                  " руб., кол-во пациентов " + lstr( rees->kol ) + " чел." )
                AAdd( arr, "" )
                AAdd( arr, "Аннулируется реестр СП и ТК № " + AllTrim( tmp1->_NSCHET ) + " от " + full_date( tmp1->_dschet ) + "г." )
                AAdd( arr, "кол-во пациентов " + lstr( tmp2->( LastRec() ) ) + " чел. (файл " + name_without_ext( cFile ) + ")" )
                If Len( arr_schet ) > 0
                  AAdd( arr, "Количество удаляемых счетов - " + lstr( Len( arr_schet ) ) + " сч." )
                Endif
                AAdd( arr, "После подтверждения аннулирования все последствия чтения данного" )
                AAdd( arr, "реестра СП и ТК, а также сам реестр СП и ТК, будут удалены." )
                f_message( arr,, cColorSt2Msg, cColorSt1Msg )
                s := "Подтвердите аннулирование реестра СП и ТК"
                stat_msg( s ) ; mybell( 1 )
                If f_esc_enter( "аннулирования", .t. )
                  stat_msg( s + " ещё раз." ) ; mybell( 3 )
                  If f_esc_enter( "аннулирования", .t. )
                    mywait()
                    is_allow_delete := .t.
                  Endif
                Endif
              Endif
              // переиндексируем некоторые файлы
              If is_allow_delete
                Private fl_open := .t.
                bSaveHandler := ErrorBlock( {| x| Break( x ) } )
                Begin Sequence
                  index_base( "schet" ) // для составления счетов
                  index_base( "human" ) // для разноски счетов
                  index_base( "mo_refr" )  // для записи причин отказов
                  index_base( "human_3" )  // для двойных случаев
                RECOVER USING error
                  is_allow_delete := func_error( 10, "Возникла непредвиденная ошибка при переиндексировании!" )
                End
                ErrorBlock( bSaveHandler )
              Endif
              // аннулируем последствия чтения реестра СП и ТК
              If is_allow_delete
                Close databases
                use_base( "schet" )
                Set Relation To
                g_use( dir_server() + "schetd",, "SD" )
                Index On Str( kod, 6 ) to ( cur_dir() + "tmp_sd" )
                g_use( dir_server() + "mo_xml",, "MO_XML" )
                g_use( dir_server() + "mo_refr", dir_server() + "mo_refr", "REFR" )
                g_use( dir_server() + "mo_rhum",, "RHUM" )
                Index On Str( REES_ZAP, 6 ) to ( cur_dir() + "tmp_rhum" ) For reestr == mkod_reestr
                g_use( dir_server() + "human_3", { dir_server() + "human_3", dir_server() + "human_32" }, "HUMAN_3" )
                use_base( "human" )
                Set Order To 0
                Use ( cur_dir() + "tmp2file" ) New Alias TMP2
                Go Top
                Do While !Eof()
                  Select RHUM
                  find ( Str( tmp2->_N_ZAP, 6 ) )
                  g_rlock( forever )
                  rhum->OPLATA := 0
                  Select HUMAN
                  Goto ( tmp2->kod_human )
                  If human->ishod == 88  // сначала проверим, не двойной ли это случай (по-старому)
                    Select HUMAN_3
                    Set Order To 1
                    find ( Str( tmp2->kod_human, 7 ) )
                    If Found()
                      Select HUMAN
                      Goto ( human_3->kod2 )  // встали на 2-ой лист учёта
                      human->( g_rlock( forever ) )
                      human->schet := 0 ; human->tip_h := B_STANDART
                      human_->( g_rlock( forever ) )
                      If human_->schet_zap > 0
                        If human_->SCHET_NUM > 0
                          human_->SCHET_NUM := human_->SCHET_NUM - 1
                        Endif
                        human_->schet_zap := 0
                      Endif
                      human_->OPLATA := 0
                      human_->REESTR := mkod_reestr
                      Unlock
                      // очистка заголовка двойного случая
                      human_3->( g_rlock( forever ) )
                      human_3->schet := 0
                      If human_3->schet_zap > 0
                        If human_3->SCHET_NUM > 0
                          human_3->SCHET_NUM := human_3->SCHET_NUM -1
                        Endif
                        human_3->schet_zap := 0
                      Endif
                      human_3->OPLATA := 0
                      human_3->REESTR := mkod_reestr
                    Endif
                    // возвращаемся к 1-му листу учёта
                    Select HUMAN
                    Goto ( tmp2->kod_human )
                    human->( g_rlock( forever ) )
                    human->schet := 0 ; human->tip_h := B_STANDART
                    human_->( g_rlock( forever ) )
                    If human_->schet_zap > 0
                      If human_->SCHET_NUM > 0
                        human_->SCHET_NUM := human_->SCHET_NUM - 1
                      Endif
                      human_->schet_zap := 0
                    Endif
                    human_->OPLATA := 0
                    human_->REESTR := mkod_reestr
                    Unlock
                  Elseif human->ishod == 89 // теперь проверим, не двойной ли это случай (по-новому)
                    // сначала обработаем 2-ой случай
                    human->( g_rlock( forever ) )
                    human->schet := 0 ; human->tip_h := B_STANDART
                    human_->( g_rlock( forever ) )
                    If human_->schet_zap > 0
                      If human_->SCHET_NUM > 0
                        human_->SCHET_NUM := human_->SCHET_NUM - 1
                      Endif
                      human_->schet_zap := 0
                    Endif
                    human_->OPLATA := 0
                    human_->REESTR := mkod_reestr
                    Unlock
                    // поищем 1-ый случай
                    Select HUMAN_3
                    Set Order To 2
                    find ( Str( human->kod, 7 ) )
                    If Found() // нашли двойной случай
                      Select HUMAN
                      Goto ( human_3->kod ) // встать на 1-ый лист учёта
                      human->( g_rlock( forever ) )
                      human->schet := 0 ; human->tip_h := B_STANDART
                      human_->( g_rlock( forever ) )
                      If human_->schet_zap > 0
                        If human_->SCHET_NUM > 0
                          human_->SCHET_NUM := human_->SCHET_NUM - 1
                        Endif
                        human_->schet_zap := 0
                      Endif
                      human_->OPLATA := 0
                      human_->REESTR := mkod_reestr
                      Unlock
                      // очистка заголовка двойного случая
                      human_3->( g_rlock( forever ) )
                      human_3->schet := 0
                      If human_3->schet_zap > 0
                        If human_3->SCHET_NUM > 0
                          human_3->SCHET_NUM := human_3->SCHET_NUM -1
                        Endif
                        human_3->schet_zap := 0
                      Endif
                      human_3->OPLATA := 0
                      human_3->REESTR := mkod_reestr
                    Endif
                  Else
                    // обработка одинарного случая
                    Select HUMAN
                    Goto ( tmp2->kod_human )
                    human->( g_rlock( forever ) )
                    human->schet := 0 ; human->tip_h := B_STANDART
                    human_->( g_rlock( forever ) )
                    If human_->schet_zap > 0
                      If human_->SCHET_NUM > 0
                        human_->SCHET_NUM := human_->SCHET_NUM - 1
                      Endif
                      human_->schet_zap := 0
                    Endif
                    human_->OPLATA := 0
                    human_->REESTR := mkod_reestr
                    Unlock
                  Endif
                  Select REFR
                  Do While .t.
                    find ( Str( 1, 1 ) + Str( mkod_reestr, 6 ) + Str( 1, 1 ) + Str( tmp2->kod_human, 8 ) )
                    If !Found() ; exit ; Endif
                    deleterec( .t. )
                  Enddo
                  Select TMP2
                  Skip
                Enddo
                For i := 1 To Len( arr_schet )
                  //
                  Select SD
                  find ( Str( arr_schet[ i, 2 ], 6 ) )
                  If Found()
                    deleterec( .t. )
                  Endif
                  //
                  Select SCHET_
                  Goto ( arr_schet[ i, 2 ] )
                  deleterec( .t., .f. )  // без пометки на удаление
                  //
                  Select SCHET
                  Goto ( arr_schet[ i, 2 ] )
                  deleterec( .t. )
                  //
                  If arr_schet[ i, 3 ] > 0
                    Select MO_XML
                    Goto ( arr_schet[ i, 3 ] )
                    If !Empty( mo_xml->FNAME )
                      s := dir_server() + dir_XML_MO() + hb_ps() + AllTrim( mo_xml->FNAME ) + szip()
                      If hb_FileExists( s )
                        Delete File ( s )
                      Endif
                    Endif
                    deleterec( .t. )
                  Endif
                Next
                Select MO_XML
                Goto ( mreestr_sp_tk )
                deleterec()
                Close databases
                stat_msg( "Реестр СП и ТК успешно аннулирован. Можно прочитать ещё раз." ) ; mybell( 5 )
              Endif
            Endif
          Endif
        Endif
        mo_unlock_task( X_OMS )
      Endif
    Elseif mTIP_IN == _XML_FILE_FLK // возврат протокола ФЛК
      If ( arr_f := extract_zip_xml( dir_server() + dir_XML_TF(), cFile + szip() ) ) != Nil .and. mo_lock_task( X_OMS )
        cFile += sxml()
        // читаем файл в память
        oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile )
        If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
          func_error( 4, "Ошибка в чтении файла " + cFile )
        Else // читаем и записываем XML-файл во временные TMP-файлы
          is_err_FLK := protokol_flk_tmpfile( arr_f, aerr )
          Close databases
          If Empty( aerr ) .and. !extract_reestr( mkod_reestr, mname_reestr )
            AAdd( aerr, "Не найден ZIP-архив с РЕЕСТРом " + mname_reestr )
            AAdd( aerr, "Без данного архива дальнейшая работа НЕВОЗМОЖНА!" )
          Endif
          If !Empty( aerr )
            ins_array( aerr, 1, "" )
            ins_array( aerr, 1, Center( "Ошибки в чтении файла " + cFile, 80 ) )
            AEval( aerr, {| x| StrFile( x + hb_eol(), cFileProtokol, .t. ) } )
            viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
            Delete File ( cFileProtokol )
          Else
            // если точно попал в другой реестр
            is_other_reestr := is_delete_human := .f.
            Use ( cur_dir() + "tmp1file" ) New Alias TMP1
            Use ( cur_dir() + "tmp2file" ) New Alias TMP2
            Index On Str( tip, 1 ) + Str( oshib, 3 ) + soshib to ( cur_dir() + "tmp2" )
            Use ( cur_dir() + "tmp_r_t1" ) New Alias T1
            Index On Upper( ID_PAC ) to ( cur_dir() + "tmp_r_t1" )
            Use ( cur_dir() + "tmp_r_t2" ) New Alias T2
            Use ( cur_dir() + "tmp_r_t3" ) New Alias T3
            Use ( cur_dir() + "tmp_r_t4" ) New Alias T4
            // заполнить поле "N_ZAP" в файле "tmp2"
            fill_tmp2_file_flk()
            r_use( dir_server() + "human",, "HUMAN" )
            r_use( dir_server() + "human_",, "HUMAN_" )
            r_use( dir_server() + "mo_rhum",, "RHUM" )
            Index On Str( REES_ZAP, 6 ) to ( cur_dir() + "tmp_rhum" ) For reestr == mkod_reestr
            Select TMP2
            Go Top
            Do While !Eof()
              If !Empty( tmp2->BAS_EL ) .and. !Empty( tmp2->ID_BAS ) .and. !Empty( tmp2->N_ZAP )
                Select RHUM
                find ( Str( tmp2->N_ZAP, 6 ) )
                If Found()
                  tmp2->kod_human := rhum->KOD_HUM
                  Select HUMAN
                  Goto ( rhum->KOD_HUM )
                  If emptyany( human->kod, human->fio )
                    is_delete_human := .t. ; Exit
                  Endif
                  Select HUMAN_
                  Goto ( rhum->KOD_HUM )
                  If human_->REESTR > 0 .and. human_->REESTR != mkod_reestr
                    is_other_reestr := .t. ; Exit
                  Endif
                Endif
              Endif
              Select TMP2
              Skip
            Enddo
            If !is_other_reestr .and. !is_delete_human
              // если попал в другой реестр, вернулся с ошибкой, и отредактирован
              r_use( dir_server() + "mo_rees",, "REES" )
              Select RHUM
              Set Relation To reestr into REES
              // сортируем пациентов по дате попадания в реестры
              Index On Str( kod_hum, 7 ) + DToS( rees->DSCHET ) to ( cur_dir() + "tmp_rhum" )
              Select TMP2
              Go Top
              Do While !Eof()
                r := r1 := 0
                Select RHUM
                find ( Str( tmp2->kod_human, 7 ) )
                Do While tmp2->kod_human == rhum->KOD_HUM
                  ++r // во сколько реестров попал
                  If rhum->reestr == mkod_reestr
                    r1 := r // какой по номеру текущий реестр
                  Endif
                  Skip
                Enddo
                If r1 > 0 .and. r > r1  // если текущий реестр не последний
                  is_other_reestr := .t. ; Exit
                Endif
                Select TMP2
                Skip
              Enddo
            Endif
            If is_delete_human
              func_error( 10, "Некоторые пациенты из данного реестра уже УДАЛЕНЫ. Операция запрещена!" )
            Elseif is_other_reestr
              func_error( 10, "Пациенты из данного реестра уже ПОПАЛИ В ДРУГОЙ РЕЕСТР. Операция запрещена!" )
            Else
              If !is_allow_delete .and. involved_password( 1, rees_nschet, "аннулирования чтения протокола ФЛК" )
                is_allow_delete := .t.
              Endif
              If is_allow_delete
                Close databases
                is_allow_delete := .f.
                r_use( dir_server() + "mo_rees",, "REES" )
                Goto ( mkod_reestr )
                Use ( cur_dir() + "tmp1file" ) New Alias TMP1
                Use ( cur_dir() + "tmp2file" ) New Alias TMP2
                arr := {}
                AAdd( arr, "Реестр № " + lstr( rees->nschet ) + " от " + full_date( rees->dschet ) + "г." )
                AAdd( arr, 'период "' + lstr( rees->nmonth ) + "/" + lstr( rees->nyear ) + ;
                  '", сумма ' + lput_kop( rees->summa, .t. ) + ;
                  " руб., кол-во пациентов " + lstr( rees->kol ) + " чел." )
                AAdd( arr, "" )
                AAdd( arr, "Аннулируется чтение протокола ФЛК № " + AllTrim( tmp1->FNAME ) )
                AAdd( arr, "кол-во пациентов с ошибкой " + lstr( tmp2->( LastRec() ) ) + " чел." )
                AAdd( arr, "После подтверждения аннулирования все последствия чтения" )
                AAdd( arr, "данного протокола ФЛК, а также сам протокол, будут удалены." )
                f_message( arr,, cColorSt2Msg, cColorSt1Msg )
                s := "Подтвердите аннулирование чтения протокола ФЛК"
                stat_msg( s ) ; mybell( 1 )
                If f_esc_enter( "аннулирования", .t. )
                  stat_msg( s + " ещё раз." ) ; mybell( 3 )
                  If f_esc_enter( "аннулирования", .t. )
                    mywait()
                    is_allow_delete := .t.
                  Endif
                Endif
              Endif
              // аннулируем последствия чтения реестра ФЛК
              If is_allow_delete
                Close databases
                g_use( dir_server() + "mo_xml",, "MO_XML" )
                g_use( dir_server() + "mo_rhum",, "RHUM" )
                Index On Str( REES_ZAP, 6 ) to ( cur_dir() + "tmp_rhum" ) For reestr == mkod_reestr
                g_use( dir_server() + "human_",, "HUMAN_" )
                Use ( cur_dir() + "tmp2file" ) New Alias TMP2
                Set Relation To kod_human into HUMAN_
                Go Top
                Do While !Eof()
                  Select RHUM
                  find ( Str( tmp2->N_ZAP, 6 ) )
                  g_rlock( forever )
                  rhum->OPLATA := 0
                  Select HUMAN_
                  g_rlock( forever )
                  human_->OPLATA := 0
                  human_->REESTR := mkod_reestr
                  Unlock
                  Select TMP2
                  Skip
                Enddo
                Select MO_XML
                Goto ( mreestr_sp_tk )
                deleterec()
                Close databases
                stat_msg( "Протокол ФЛК успешно аннулирован." ) ; mybell( 5 )
              Endif
            Endif
          Endif
        Endif
        mo_unlock_task( X_OMS )
      Endif
    Endif
  Endif
  rest_box( buf )

  Return 0
