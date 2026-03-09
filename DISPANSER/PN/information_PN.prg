// information_PN.prg - Информация по профилактике и медосмотрам несовершеннолетних
#include 'inkey.ch'
#include 'fastreph.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

// 19.02.18 Информация по профилактике и медосмотрам несовершеннолетних
Function inf_dnl( k )

  Static si1 := 1, si2 := 1, sj1 := 1, sj2 := 1
  Local mas_pmt, mas_msg, mas_fun, j, j1, j2
  Local mas2pmt := { ;
    'Про~филактические осмотры', ;
    'Пре~дварительные осмотры', ;
    'Пе~риодические осмотры' }

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { ;
      '~Карта проф.медосмотра', ;
      '~Список пациентов', ;
      '~Многовариантный запрос', ;
      'Своды для Обл~здрава', ;
      'Форма № 030-ПО/~о-17', ;
      'XML-файл для ~портала МЗРФ' }
    mas_msg := { ;
      'Карта профилактического медосмотра несовершеннолетнего (форма № 030-ПО/у-17)', ;
      'Просмотр спика пациентов, прошедших медосмотры', ;
      'Многовариантный запрос по диспансеризации/медосмотрам несовершеннолетних', ;
      'Распечатка сводов для Волгоградского областного Комитета здравоохранения', ;
      'Сведения о профилактических осмотрах несовершеннолетних (форма № 030-ПО/о-17)', ;
      'Создание XML-файла для загрузки на портал Минздрава РФ' }
    mas_fun := { ;
      'inf_DNL(11)', ;
      'inf_DNL(12)', ;
      'inf_DNL(13)', ;
      'inf_DNL(14)', ;
      'inf_DNL(15)', ;
      'inf_DNL(16)' }
    Private p_tip_lu := TIP_LU_PN
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    inf_dnl_karta()
  Case k == 12
    ne_real()
  Case k == 13
    mnog_poisk_dnl()
  Case k == 14
    mas_pmt := { '~Сведения о профосмотрах детей по состоянию на ...' }
    mas_msg := { 'Приложение к Приказу ВОМИАЦ №1025 от 08.07.2019г.' }
    mas_fun := { 'inf_DNL(21)' }
    popup_prompt( T_ROW, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 15
    If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt() ) ) > 0
      inf_dnl_030poo( j1 )
    Endif
  Case k == 16
    // if (j2 := popup_prompt(T_ROW,T_COL-5,sj2,mas2pmt,,,'N/W,GR+/R,B/W,W+/R')) > 0
    // sj2 := j2
    // p_tip_lu := {TIP_LU_PN,TIP_LU_PREDN,TIP_LU_PERN}[j2]
    p_tip_lu := TIP_LU_PN
    If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt() ) ) > 0
      // inf_DNL_XMLfile(j1,charrem('~',mas2pmt[j2]))
      inf_dnl_xmlfile( j1, 'Профилактические осмотры' )
    Endif
    // endif
  Case k == 21
    If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt() ) ) > 0
      f21_inf_dnl( j1 )
    Endif
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Endif
  Endif

  Return Nil

// 25.03.18 Распечатка карты проф.мед.осмотра (учётная форма № 030-ПО/у...)
Function inf_dnl_karta()

  Local arr_m, buf := save_maxrow(), blk, t_arr[ BR_LEN ]

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dnl( arr_m, .f. )
      Copy File ( cur_dir() + 'tmp' + sdbf() ) to ( cur_dir() + 'tmpDNL' + sdbf() ) // т.к. внутри тоже есть TMP-файл
      r_use( dir_server() + 'human',, 'HUMAN' )
      Use ( cur_dir() + 'tmpDNL' ) new
      Set Relation To FIELD->kod into HUMAN
      Index On Upper( human->fio ) to ( cur_dir() + 'tmpDNL' )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + 'human_',, 'HUMAN_' ), ;
        r_use( dir_server() + 'human',, 'HUMAN' ), ;
        dbSetRelation( 'HUMAN_', {|| RecNo() }, 'recno()' ), ;
        r_use( cur_dir() + 'tmpDNL', cur_dir() + 'tmpDNL', 'TMP' ), ;
        dbSetRelation( 'HUMAN', {|| kod }, 'kod' );
        }
      Eval( blk_open )
      Go Top
      t_arr[ BR_TOP ] := T_ROW
      t_arr[ BR_BOTTOM ] := 23
      t_arr[ BR_LEFT ] := 0
      t_arr[ BR_RIGHT ] := 79
      t_arr[ BR_TITUL ] := 'Профосмотры несовершеннолетних ' + arr_m[ 4 ]
      t_arr[ BR_TITUL_COLOR ] := 'B/BG'
      t_arr[ BR_COLOR ] := color0
      t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t. }
      blk := {|| iif( human->schet > 0, { 1, 2 }, { 3, 4 } ) }
      t_arr[ BR_COLUMN ] := { { ' Ф.И.О.', {|| PadR( human->fio, 39 ) }, blk }, ;
        { 'Дата рожд.', {|| full_date( human->date_r ) }, blk }, ;
        { '№ ам.карты', {|| human->uch_doc }, blk }, ;
        { 'Сроки леч-я', {|| Left( date_8( human->n_data ), 5 ) + '-' + Left( date_8( human->k_data ), 5 ) }, blk }, ;
        { 'Этап', {|| iif( human->ishod == 301, ' I  ', 'I-II' ) }, blk } }
      t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - распечатать карту профилактического мед.осмотра' ) }
      t_arr[ BR_EDIT ] := {| nk, ob| f1_inf_dnl_karta( nk, ob, 'edit' ) }
      edit_browse( t_arr )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 11.03.19
Function f0_inf_dnl( arr_m, is_schet, is_reg, arr_ishod, is_snils )

  Local fl := .t.

  Default is_schet To .t., is_reg To .f., is_snils To .f., arr_ishod TO { 301, 302 } // профилактика 1 и 2 этап
  If !del_dbf_file( cur_dir() + 'tmp' + sdbf() )
    Return .f.
  Endif
  dbCreate( cur_dir() + 'tmp', { ;
    { 'kod', 'N', 7, 0 }, ;
    { 'kod_k', 'N', 7, 0 }, ;
    { 'is', 'N', 1, 0 }, ;
    { 'ishod', 'N', 6, 0 } } )
  Use ( cur_dir() + 'tmp' ) new
  r_use( dir_server() + 'schet_',, 'SCHET_' )
  r_use( dir_server() + 'kartotek',, 'KART' )
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To FIELD->kod_k into KART
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Index On FIELD->kod to ( cur_dir() + 'tmp_h' ) ;
    For AScan( arr_ishod, FIELD->ishod ) > 0 .and. iif( is_schet, FIELD->schet > 0, .t. ) ;
    While human->k_data <= arr_m[ 6 ] ;
    PROGRESS
  Go Top
  Do While !Eof()
    fl := .t.
    If is_reg
      fl := .f.
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        fl := .t.
      Endif
    Endif
    If fl .and. ret_koef_from_rak( human->kod ) > 0
      Select TMP
      Append Blank
      tmp->kod := human->kod
      tmp->kod_k := human->kod_k
      tmp->ishod := human->ishod
      tmp->is := iif( is_snils .and. Empty( kart->snils ), 0, 1 )
    Endif
    Select HUMAN
    Skip
  Enddo
  fl := .t.
  If tmp->( LastRec() ) == 0
    fl := func_error( 4, 'Не найдено л/у по медосмотрам несовершеннолетних ' + arr_m[ 4 ] )
  Endif
  Close databases

  Return fl

// 07.08.13
Function f1_inf_dnl_karta( nKey, oBrow, regim )

  Local ret := -1, lkod_h, lkod_k, rec := tmp->( RecNo() ), buf := save_maxrow()

  If regim == 'edit' .and. nKey == K_ENTER
    mywait()
    lkod_h := human->kod
    lkod_k := human->kod_k
    Close databases
    oms_sluch_pn( lkod_h, lkod_k, 'f2_inf_DNL_karta' )
    Eval( blk_open )
    Goto ( rec )
    rest_box( buf )
  Endif

  Return ret

// 21.09.25
Function f4_inf_dnl_karta( par, _etap )

  Local i, k := 0, fl, arr := {}, ar
  local arr_PN_osmotr

  If Type( 'mperiod' ) == 'N' .and. Between( mperiod, 1, 31 )
    //
  Else
    mperiod := ret_period_pn( mdate_r, mn_data, mk_data,, @k )
  Endif
  arr_PN_osmotr := np_arr_osmotr( mk_data )
  If !Between( mperiod, 1, 31 )
    mperiod := k
  Endif
  If !Between( mperiod, 1, 31 )
    mperiod := 31
  Endif
  np_oftal_2_85_21( mperiod, mk_data )
  ar := np_arr_1_etap( mk_data )[ mperiod ]
  If par == 1
    If iif( _etap == nil, .t., _etap == 1 )
//      For i := 1 To count_pn_arr_osm - 1
      For i := 1 To Len( arr_PN_osmotr ) - 1
        mvart := 'MTAB_NOMov' + lstr( i )
        mvard := 'MDATEo' + lstr( i )
        fl := .t.
//        If fl .and. !Empty( np_arr_osmotr[ i, 2 ] )
//          fl := ( mpol == np_arr_osmotr[ i, 2 ] )
        If fl .and. !Empty( arr_PN_osmotr[ i, 2 ] )
          fl := ( mpol == arr_PN_osmotr[ i, 2 ] )
        Endif
        If fl
//          fl := ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) > 0 )
          fl := ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], arr_PN_osmotr[ i, 1 ] ) > 0 )
        Endif
        If fl .and. !emptyany( &mvard, &mvart )
//          AAdd( arr, { np_arr_osmotr[ i, 3 ], &mvard, '', i, f5_inf_dnl_karta( i ) } )
          AAdd( arr, { arr_PN_osmotr[ i, 3 ], &mvard, '', i, f5_inf_dnl_karta( i ) } )
        Endif
      Next
    Endif
    AAdd( arr, { 'педиатр (врач общей практики)', MDATEp1, '', -1, 1 } )
    If metap == 2 .and. iif( _etap == nil, .t., _etap == 2 )
//      For i := 1 To count_pn_arr_osm -1
      For i := 1 To Len( arr_PN_osmotr )
        mvart := 'MTAB_NOMov' + lstr( i )
        mvard := 'MDATEo' + lstr( i )
        fl := .t.
//        If fl .and. !Empty( np_arr_osmotr[ i, 2 ] )
//          fl := ( mpol == np_arr_osmotr[ i, 2 ] )
        If fl .and. !Empty( arr_PN_osmotr[ i, 2 ] )
          fl := ( mpol == arr_PN_osmotr[ i, 2 ] )
        Endif
        If fl
//          fl := ( AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) == 0 )
          fl := ( AScan( ar[ 4 ], arr_PN_osmotr[ i, 1 ] ) == 0 )
        Endif
        If fl .and. !emptyany( &mvard, &mvart )
//          AAdd( arr, { np_arr_osmotr[ i, 3 ], &mvard, '', i, f5_inf_dnl_karta( i ) } )
          AAdd( arr, { arr_PN_osmotr[ i, 3 ], &mvard, '', i, f5_inf_dnl_karta( i ) } )
        Endif
      Next
      AAdd( arr, { 'педиатр (врач общей практики)', MDATEp2, '', -2, 1 } )
    Endif
  Else
    For i := 1 To count_pn_arr_iss( mk_data ) // исследования
      mvart := 'MTAB_NOMiv' + lstr( i )
      mvard := 'MDATEi' + lstr( i )
      mvarr := 'MREZi' + lstr( i )
      fl := .t.
      If fl .and. !Empty( np_arr_issled( mk_data )[ i, 2 ] )
        fl := ( mpol == np_arr_issled( mk_data )[ i, 2 ] )
      Endif
      If fl
        fl := ( AScan( ar[ 5 ], np_arr_issled( mk_data )[ i, 1 ] ) > 0 )
      Endif
      If fl .and. !emptyany( &mvard, &mvart )
        k := 0
        Do Case
        Case i == 1 // {'3.5.4'   ,   , 'Аудиологический скрининг', 0, 64,{1111, 111101} }, ;
          k := 15
        Case i == 2 // {'4.2.153' ,   , 'Общий анализ мочи', 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 2
          // case i == 3 // {'4.8.1'   ,   , 'Общий анализ кала', 0, 34,{1107, 1301, 1402, 1702} }, ;
          // k := 3
          // case i == 4 // {'4.11.136',   , 'Клинический анализ крови', 0, 34,{1107, 1301, 1402, 1702} }, ;
        Case i == 3 // {'4.11.136',   , 'Клинический анализ крови', 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 1
          // case i == 5 // {'4.12.169',   , 'Исследование уровня глюкозы в крови', 0, 34,{1107, 1301, 1402, 1702} }, ;
          // k := 4
          // case between(i, 6, 16) // {'4.14.67' ,   , 'пролактин (гормон)', 1, 34,{1107, 1301, 1402, 1702} }, ;
          // k := 5
          // case between(i, 17, 21) // {'4.26.1'  ,   , 'Неонатальный скрининг на гипотиреоз', 0, 34,{1107, 1301, 1402, 1702} }, ;
        Case Between( i, 4, 8 ) // {'4.26.1'  ,   , 'Неонатальный скрининг на гипотиреоз', 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 14
          // case i == 22 // {'7.61.3'  ,   , 'Флюорография легких в 1-й проекции', 0, 78,{1118, 1802} }, ;
          // k := 12
          // case i == 23 // {'8.1.1'   ,   , 'УЗИ головного мозга (нейросонография)', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
        Case i == 9 // {'8.1.1'   ,   , 'УЗИ головного мозга (нейросонография)', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 11
          // case i == 24 // {'8.1.2'   ,   , 'УЗИ щитовидной железы', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          // k := 8
        Case i == 12 // {'8.1.6'   , 12, 'УЗИ почек', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 18
          // case i == 25 // {'8.1.3'   ,   , 'УЗИ сердца', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
        Case i == 10 // {'8.1.3'   ,   , 'УЗИ сердца', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 7
          // case i == 26 // {'8.1.4'   ,   , 'УЗИ тазобедренных суставов', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
        Case i == 11 // {'8.1.4'   ,   , 'УЗИ тазобедренных суставов', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 10
          // case i == 27 // {'8.2.1'   ,   , 'УЗИ органов брюшной полости', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
        Case i == 13 // {'8.2.1'   ,   , 'УЗИ органов брюшной полости', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 6
          // case between(i, 28, 29) // {'8.2.2'   ,'М', 'УЗИ органов репродуктивной системы', 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          // k := 9
          // case i == 30 // {'13.1.1'  ,   , 'Электрокардиография', 0, 111,{110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202} }, ;
        Case i == 14 // {'13.1.1'  ,   , 'Электрокардиография', 0, 111,{110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202} }, ;
          k := 13
        Endcase
        AAdd( arr, { np_arr_issled( mk_data )[ i, 3 ], &mvard, &mvarr, i, k } )
      Endif
    Next
    // добавим '2.4.2' 'скрининг на выявление психич.развития'
//    i := count_pn_arr_osm  // последний элемент массива
    i := Len( arr_PN_osmotr )  // последний элемент массива
    mvart := 'MTAB_NOMov' + lstr( i )
    mvard := 'MDATEo' + lstr( i )
//    If ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) > 0 ) .and. !emptyany( &mvard, &mvart )
//      AAdd( arr, { np_arr_osmotr[ i, 3 ], &mvard, '', i, 21 } )
    If ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], arr_PN_osmotr[ i, 1 ] ) > 0 ) .and. !emptyany( &mvard, &mvart )
      AAdd( arr, { arr_PN_osmotr[ i, 3 ], &mvard, '', i, 21 } )
    Endif
  Endif
  Return arr

// 25.11.13
Function f5_inf_dnl_karta( i )

  Local k := 0

  Do Case
  Case i == 14 // {'2.85.16','Ж', 'акушер-гинеколог', 2, {1101} }, ;
    k := 11
  Case i == 15 // {'2.85.17','М', 'детский уролог-андролог', 19, {112603, 113502} }, ;
    k := 10
  Case i == 16 // {'2.85.18',   , 'детский хирург', 20, {1135} }, ;
    k := 4
  Case i == 17 // {'2.85.19',   , 'травматолог-ортопед', 100, {1123} }, ;
    k := 6
  Case i == 18 // {'2.85.20',   , 'невролог', 53, {1109} }, ;
    k := 2
  Case i == 19 // {'2.85.21',   , 'офтальмолог', 65, {1112} }, ;
    k := 3
  Case i == 20 // {'2.85.22',   , 'отоларинголог', 64, {1111, 111101} }, ;
    k := 5
  Case i == 21 // {'2.85.23',   , 'детский стоматолог', 86, {140102} }, ;
    k := 8
  Case i == 22 // {'2.85.24',   , 'детский эндокринолог', 21, {1127, 112702, 113402} }, ;
    k := 9
  Case i == 23 // {'2.4.1'  ,   , 'психиатр', 72, {1115} };
    k := 7
  Endcase

  Return k

// 09.06.20 Приложение к письму ГБУЗ 'ВОМИАЦ' №1025 от 08.07.2019г.
Function f21_inf_dnl( par )

  Local arr_m, buf := save_maxrow(), lkod_h, lkod_k, rec, s, adbf, as, i, j, k, sh, HH := 40, n, n_file := cur_dir() + 'svod_dnl.txt'

  If ( arr_m := year_month(,,, 5 ) ) != NIL
    If arr_m[ 1 ] < 2020
      Return func_error( 4, 'Данная форма утверждена с 2020 года' )
    Endif
    mywait()
    If f0_inf_dnl( arr_m, par > 1, par == 3, { 301, 302 } )
      r_use( dir_server() + 'mo_rpdsh',, 'RPDSH' )
      Index On Str( FIELD->KOD_H, 7 ) to ( cur_dir() + 'tmprpdsh' )
      adbf := { ;
        { 'ti', 'N', 1, 0 }, ;
        { 'stroke', 'C', 8, 0 }, ;
        { 'mm', 'N', 2, 0 }, ;
        { 'mm1', 'N', 1, 0 }, ;
        { 'vsego', 'N', 6, 0 }, ;
        { 'vsego1', 'N', 6, 0 }, ;
        { 'vsegoM', 'N', 6, 0 }, ;
        { 'g1', 'N', 6, 0 }, ;
        { 'g2', 'N', 6, 0 }, ;
        { 'g3', 'N', 6, 0 }, ;
        { 'g4', 'N', 6, 0 }, ;
        { 'g4inv', 'N', 6, 0 }, ;
        { 'g5', 'N', 6, 0 }, ;
        { 'g5inv', 'N', 6, 0 }, ;
        { 'mg1', 'N', 6, 0 }, ;
        { 'mg2', 'N', 6, 0 }, ;
        { 'mg3', 'N', 6, 0 }, ;
        { 'mg4', 'N', 6, 0 }, ;
        { 'sv', 'N', 6, 0 }, ;
        { 'so', 'N', 6, 0 }, ;
        { 'v2', 'N', 6, 0 }, ;
        { 'm15', 'N', 6, 0 }, ;
        { 'm15s', 'N', 6, 0 }, ;
        { 'm15pos', 'N', 6, 0 }, ;
        { 'm15poss', 'N', 6, 0 }, ;
        { 'm15a', 'N', 6, 0 }, ;
        { 'm15p', 'N', 6, 0 }, ;
        { 'm15ps', 'N', 6, 0 }, ;
        { 'm15p1', 'N', 6, 0 }, ;
        { 'm15p1s', 'N', 6, 0 }, ;
        { 'm15e', 'N', 6, 0 }, ;
        { 'g15', 'N', 6, 0 }, ;
        { 'g15s', 'N', 6, 0 }, ;
        { 'g15pos', 'N', 6, 0 }, ;
        { 'g15poss', 'N', 6, 0 }, ;
        { 'g15g', 'N', 6, 0 }, ;
        { 'g15p', 'N', 6, 0 }, ;
        { 'g15ps', 'N', 6, 0 }, ;
        { 'g15p1', 'N', 6, 0 }, ;
        { 'g15p1s', 'N', 6, 0 }, ;
        { 'g15e', 'N', 6, 0 }, ;
        { 'g18', 'N', 6, 0 }, ;
        { 'g18s', 'N', 6, 0 }, ;
        { 'm18', 'N', 6, 0 }, ;
        { 'm18s', 'N', 6, 0 } }

      dbCreate( cur_dir() + 'tmp1', adbf )
      Use ( cur_dir() + 'tmp1' ) new
      Index On Str( FIELD->mm, 2 ) to ( cur_dir() + 'tmp1' )
      Append Blank
      tmp1->mm := 0 ; tmp1->stroke := 'Всего'
      Append Blank
      tmp1->mm := 1 ; tmp1->stroke := '0-14 лет'
      Append Blank
      tmp1->mm := 2 ; tmp1->stroke := 'до 1 г.'
      Append Blank
      tmp1->mm := 3 ; tmp1->stroke := '15-17 л.'
      Append Blank
      tmp1->mm := 4 ; tmp1->stroke := '15-17 юн'
      Append Blank
      tmp1->mm := 5 ; tmp1->stroke := 'школьники'
      adbf := { ;
        { 'ti', 'N', 1, 0 }, ;
        { 'g1', 'N', 6, 0 }, ;
        { 'g2', 'N', 6, 0 }, ;
        { 'g3', 'N', 6, 0 }, ;
        { 'g31', 'N', 6, 0 }, ;
        { 'g32', 'N', 6, 0 }, ;
        { 'g4', 'N', 6, 0 }, ;
        { 'g5', 'N', 6, 0 }, ;
        { 'g6', 'N', 6, 0 }, ;
        { 'g7', 'N', 6, 0 }, ;
        { 'g8', 'N', 6, 0 }, ;
        { 'g9', 'N', 6, 0 }, ;
        { 'g10', 'N', 6, 0 }, ;
        { 'g11', 'N', 6, 0 }, ;
        { 'g12', 'N', 6, 0 }, ;
        { 'g13', 'N', 6, 0 }, ;
        { 'g14', 'N', 6, 0 }, ;
        { 'g15', 'N', 6, 0 }, ;
        { 'g7n', 'N', 6, 0 }, ;
        { 'g8n', 'N', 6, 0 }, ;
        { 'g12n', 'N', 6, 0 }, ;
        { 'g13n', 'N', 6, 0 }, ;
        { 'g14n', 'N', 6, 0 }, ;
        { 'g16n', 'N', 6, 0 } }
      dbCreate( cur_dir() + 'tmp2', adbf )
      Use ( cur_dir() + 'tmp2' ) new
      Index On Str( FIELD->ti, 1 ) to ( cur_dir() + 'tmp2' )
      r_use( dir_server() + 'mo_schoo',, 'SCH' )
      r_use( dir_server() + 'schet_',, 'SCHET_' )
      r_use( dir_server() + 'uslugi',, 'USL' )
      r_use_base( 'human_u' )
      r_use( dir_server() + 'kartote_',, 'KART_' )
      r_use( dir_server() + 'human_',, 'HUMAN_' )
      r_use( dir_server() + 'human',, 'HUMAN' )
      Set Relation To RecNo() into HUMAN_, To FIELD->kod_k into KART_
      Use ( cur_dir() + 'tmp' ) new
      Set Relation To FIELD->kod into HUMAN
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say Str( RecNo() / LastRec() * 100, 6, 2 ) + '%' Color cColorWait
        f1_f21_inf_dnl( tmp->kod, tmp->kod_k )
        Select TMP
        Skip
      Enddo
      Close databases
      arr_title := { ;
        '────────┬─────────────────┬─────────────────────────────────────────┬───────────────────────┬───────────┬─────┬─────', ;
        'катего- │Число детей Iэтап│распределение по группам здоровья I этап │распр-ие по мед.группам│Случаев Iэт│напр.│завер', ;
        'рии     ├─────┬─────┬─────┼─────┬─────┬─────┬─────┬─────┬─────┬─────┼─────┬─────┬─────┬─────┼─────┬─────┤на   │шило ', ;
        'детей   │всего│ село│моб/к│  1  │  2  │  3  │  4  │4инв.│  5  │5инв.│основ│подго│спецА│спецБ│зарег│оплач│2 эт.│2 эт.', ;
        '────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────', ;
        '        │  5  │ 5.1 │  6  │  7  │  8  │  9  │  10 │ 10.1│  11 │ 11.1│  12 │  13 │  14 │  15 │  16 │  17 │  18 │  19 ', ;
        '────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────' }
      sh := Len( arr_title[ 1 ] )
      fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( glob_mo()[ _MO_SHORT_NAME ] )
      add_string( PadL( 'Приложение к письму ГБУЗ "ВОМИАЦ"', sh ) )
      add_string( PadL( '№1025 от 08.07.2019г.', sh ) )
      add_string( '' )
      add_string( Center( '[ ' + CharRem( '~', mas1pmt()[ par ] ) + ' ]', sh ) )
      add_string( Center( '(' + arr_m[ 4 ] + ')', sh ) )
      Use ( cur_dir() + 'tmp1' ) index ( cur_dir() + 'tmp1' ) new
      add_string( '' )
      add_string( Center( 'Сведения о профилактических осмотрах несовершеннолетних', sh ) )
      add_string( '' )
      AEval( arr_title, {| x| add_string( x ) } )
      Go Top
      Do While !Eof()
        s := tmp1->stroke + put_val( tmp1->vsego, 6 ) + ;
          put_val( tmp1->vsego1, 6 ) + ;
          put_val( tmp1->vsegoM, 6 ) + ;
          put_val( tmp1->g1, 6 ) + ;
          put_val( tmp1->g2, 6 ) + ;
          put_val( tmp1->g3, 6 ) + ;
          put_val( tmp1->g4, 6 ) + ;
          put_val( tmp1->g4inv, 6 ) + ;
          put_val( tmp1->g5, 6 ) + ;
          put_val( tmp1->g5inv, 6 ) + ;
          put_val( tmp1->mg1, 6 ) + ;
          put_val( tmp1->mg2, 6 ) + ;
          put_val( tmp1->mg3, 6 ) + ;
          put_val( tmp1->mg4, 6 ) + ;
          put_val( tmp1->sv, 6 ) + ;
          put_val( tmp1->so, 6 ) + ;
          put_val( tmp1->v2, 6 ) + ;
          put_val( tmp1->v2, 6 )
        // put_val(tmp1->g31, 6)+;
        // put_val(tmp1->g32, 6)+;
        If verify_ff( HH -1, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s )
        add_string( Replicate( '─', sh ) )
        Skip
      Enddo
      //
      verify_ff( HH -12, .t., sh )
/*    arr_title := {;
'────────┬───────────────────────────────────┬───────────────────────────────────', ;
'        │      Юноши (15-17 лет)            │        Девушки (15-17 лет)        ', ;
'        ├─────────────────┬─────┬─────┬─────┼─────────────────┬─────┬─────┬─────', ;
'        │факт осмот.(чел.)│патол│ из  │напр.│факт осмот.(чел.)│патол│ из  │напр.', ;
'        ├─────┬─────┬─────┤репр.│ гр.6│на II├─────┬─────┬─────┤репр.│ гр.6│на II', ;
'        │всего│ село│андро│сист.│ село│этап │всего│ село│гинек│сист.│ село│этап ', ;
'────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────', ;
'        │  3  │  4  │  5  │  6  │  7  │  8  │  3  │  4  │  5  │  6  │  7  │  8  ', ;
'────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────'}*/
      arr_title := { ;
        '───────────────────────────────────────────────────────────────────────┬───────────────────────────────────────────────────────────────────────', ;
        '            Юноши (15-17 лет)                                          │                         Девушки (15-17 лет)                           ', ;
        '─────────────────────────────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┼─────────────────────────────┬─────┬─────┬─────┬─────┬─────┬─────┬─────', ;
        '     факт осмот.(чел.)       │патол│ из  │из 7 │ из  │напр.│напр.│ из  │      факт осмот.(чел.)      │патол│ из  │из 14│ из  │напр.│напр.│ из  ', ;
        '─────┬─────┬─────┬─────┬─────┤репр.│ гр.7│впер-│ 7.2 │на II│на л.│  9  ├─────┬─────┬─────┬─────┬─────┤репр.│гр.14│впер-│14.2 │на II│на л.│ 18  ', ;
        'всего│ село│посещ│ село│андро│сист.│ село│вые  │ село│этап │из 7 │ село│всего│ село│посещ│ село│гинек│сист.│ село│вые  │ село│этап │из 16│ село', ;
        '─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────', ;
        '  3  │  4  │  5  │ 5.1 │  6  │  7  │ 7.1 │ 7.2 │ 7.3 │  8  │  9  │ 9.1 │  13 │ 13.1│  14 │ 14.1│  15 │  16 │ 16.1│ 16.2│ 16.3│ 17  │ 18  │ 18.1', ;
        '─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────' }
      sh := Len( arr_title[ 1 ] )
      i := 1
      add_string( '' )
      add_string( 'Несовершеннолетние в возрасте 15-17 лет' )
      AEval( arr_title, {| x| add_string( x ) } )
      Go Top
      s :=   put_val( tmp1->m15, 5 ) + ;
        put_val( tmp1->m15s, 6 ) + ;
        put_val( tmp1->m15pos, 6 ) + ;
        put_val( tmp1->m15poss, 6 ) + ;
        put_val( tmp1->m15a, 6 ) + ;
        put_val( tmp1->m15p, 6 ) + ;
        put_val( tmp1->m15ps, 6 ) + ;
        put_val( tmp1->m15p1, 6 ) + ;
        put_val( tmp1->m15p1s, 6 ) + ;
        put_val( tmp1->m15e, 6 ) + ;
        put_val( tmp1->m18, 6 ) + ;
        put_val( tmp1->m18s, 6 ) + ;
        put_val( tmp1->g15, 6 ) + ;
        put_val( tmp1->g15s, 6 ) + ;
        put_val( tmp1->g15pos, 6 ) + ;
        put_val( tmp1->g15poss, 6 ) + ;
        put_val( tmp1->g15g, 6 ) + ;
        put_val( tmp1->g15p, 6 ) + ;
        put_val( tmp1->g15ps, 6 ) + ;
        put_val( tmp1->g15p1, 6 ) + ;
        put_val( tmp1->g15p1s, 6 ) + ;
        put_val( tmp1->g15e, 6 ) + ;
        put_val( tmp1->g18, 6 ) + ;
        put_val( tmp1->g18s, 6 )
      If verify_ff( HH -1, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( s )
      add_string( Replicate( '─', sh ) )
      //
      verify_ff( HH -12, .t., sh )
      arr_title := { ;
        '─────────┬─────────────────┬─────────────────┬─────┬─────┬─────┬────────────────────────────────────────────────┬─────┬─────┬─────┬─────', ;
        '         │    Осмотрено    │из них сельских ж│осмо-│осмо-│впер-│                  из них                        │факт-│из г9│из г9│из   ', ;
        'Контин-  ├─────┬─────┬─────┼─────┬─────┬─────┤трено│трено│вые  ├─────┬─────┬──────┬─────┬─────┬─────┬─────┬─────┤ оры │взяты│нача-│гр.20', ;
        'гент     │     │после│в суб│     │после│в суб│урол-│гине-│неинф│болез│     │  1и2 │болез│болез│болез│болез│болез│риска│на   │то   │сель-', ;
        '         │всего│18:00│боту │всего│18:00│боту │андро│коло-│екцио│крово│ ЗНО │ стад.│к-мыш│глаз │эндок│орган│орган│впер-│дисп.│лече-│ских ', ;
        '         │     │     │     │     │     │     │логом│гом  │нные │обращ│     │из г11│соед.│прид.│сист.│дыхан│пищев│вые  │набл.│ние  │жител', ;
        '─────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼──────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────', ;
        '         │  1  │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │ 10  │  11 │  12  │  13 │  14 │  15 │  16 │  17 │  18 │  19 │  20 │  21 ', ;
        '─────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴──────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────' }
      // 1     2     3     4     5     6     7n    8n    7     8     9     0                        11    12          13    14    15
      sh := Len( arr_title[ 1 ] )
      add_string( '' )
      add_string( 'В рамках национального проекта "Здравоохранение"' )
      AEval( arr_title, {| x| add_string( x ) } )
      Use ( cur_dir() + 'tmp2' ) index ( cur_dir() + 'tmp2' ) new
      Go Top
      Do While !Eof()
        s := PadR( { '0-14 лет', '15-17 лет', 'Всего' }[ tmp2->ti ], 9 ) + ;
          put_val( tmp2->g1, 6 ) + ;
          put_val( tmp2->g2, 6 ) + ;
          put_val( tmp2->g3, 6 ) + ;
          put_val( tmp2->g4, 6 ) + ;
          put_val( tmp2->g5, 6 ) + ;
          put_val( tmp2->g6, 6 ) + ;
          put_val( tmp2->g7n, 6 ) + ;
          put_val( tmp2->g8n, 6 ) + ;
          put_val( tmp2->g7, 6 ) + ;
          put_val( tmp2->g8, 6 ) + ;
          put_val( tmp2->g9, 6 ) + ;
          put_val( 0, 7 ) + ;
          put_val( tmp2->g12n, 6 ) + ;
          put_val( tmp2->g13n, 6 ) + ;
          put_val( tmp2->g14n, 6 ) + ;
          put_val( tmp2->g11, 6 ) + ;
          put_val( tmp2->g12, 6 ) + ;
          put_val( tmp2->g16n, 6 ) + ;
          put_val( tmp2->g13, 6 ) + ;
          put_val( tmp2->g14, 6 ) + ;
          put_val( tmp2->g15, 6 )
        If verify_ff( HH -1, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s )
        add_string( Replicate( '─', sh ) )
        Skip
      Enddo
      //
      FClose( fp )
      Close databases
      Private yes_albom := .t.
      viewtext( n_file,,,, ( .t. ),,, 3 )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 28.09.25
Function f1_f21_inf_dnl( Loc_kod, kod_kartotek ) // сводная информация

  Local ii, im, i, j, k, s, sumr := 0, ar := { 0 }, ltip_school := -1, ar15[ 26 ], ;
    is_2 := .f., ad := {}, arr, a3 := {}, fl_ves := .t.
  Private m1tip_school := -1, m1school := 0, mvozrast, mdvozrast, mgruppa := 0, m1GR_FIZ := 1, m1invalid1 := 0
  Private mvar, m1var, m1FIZ_RAZV1, m1napr_stac := 0

  AFill( ar15, 0 )
  mvozrast := count_years( human->date_r, human->n_data )
  mdvozrast := Year( human->n_data ) - Year( human->date_r )
  For i := 1 To 5
    For k := 1 To 16
      s := 'diag_16_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := 'm1' + s
        Private &m1var := 0
        Private &mvar := Space( 3 )
      Endif
    Next
  Next
  ii := 1
  is_2 := ( human->ishod == 302 ) // это второй этап
  read_arr_pn( Loc_kod, .t., human->K_DATA )
  If human->pol == 'М'
    If m1napr_stac > 0
      ar15[ 23 ] ++
      If f_is_selo()
        ar15[ 24 ] ++
      Endif
    Endif
  Else
    If m1napr_stac > 0
      ar15[ 25 ] ++
      If f_is_selo()
        ar15[ 26 ] ++
      Endif
    Endif
  Endif
  //
  mGRUPPA := human_->RSLT_NEW - 331// L_BEGIN_RSLT
  If mvozrast == 0
    AAdd( ar, 2 )
  Endif
  If mdvozrast < 15
    AAdd( ar, 1 )
  Else
    AAdd( ar, 3 )
    If human->pol == 'М'
      AAdd( ar, 4 )
    Endif
  Endif
  If mdvozrast > 6 // школьники ?
    AAdd( ar, 5 )
  Endif
  If m1school > 0
    Select SCH
    Goto ( m1school )
    ltip_school := sch->tip
  Endif
  For i := 1 To 5
    j := 0
    For k := 1 To 16
      s := 'diag_16_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 16 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := 'm1' + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  //
  arr := Array( 24 ) ; AFill( arr, 0 ) ; arr[ 16 ] := 3
  arr[ 1 ] := 1
  If ( is_selo := f_is_selo() )
    arr[ 4 ] := 1
  Endif
  If DoW( human->k_data ) == 7 // суббота
    arr[ 3 ] := 1
    If is_selo
      arr[ 6 ] := 1
    Endif
  Endif

  For i := 1 To Len( ad )
    If !( Left( ad[ i, 1 ], 1 ) == 'A' .or. Left( ad[ i, 1 ], 1 ) == 'B' ) .and. ad[ i, 2 ] > 0 // неинфекционные заболевания уст.впервые
      arr[ 7 ] ++
      If Left( ad[ i, 1 ], 1 ) == 'I' // болезни системы кровообращения
        arr[ 8 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == 'J' // болезни органов дыхания
        arr[ 11 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == 'K' // болезни органов пищеварения
        arr[ 12 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == 'M' // болезни костно-мышечной системы
        arr[ 19 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == 'H' // болезни глаз
        arr[ 20 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == 'E' // болезни эндокринология
        arr[ 21 ] ++
      Endif
      If Left( ad[ i, 1 ], 3 ) == 'E78'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'R73.9'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.0'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.4'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'R63.5'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.3'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.1'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.2'
        arr[ 22 ] ++
        fl_ves := .f.
      Endif
      // надо деффицит массы тела
      If Left( ad[ i, 1 ], 1 ) == 'C' .or. Between( Left( ad[ i, 1 ], 3 ), 'D00', 'D09' ) // ЗНО может быть добавить  .or. between(left(ad[i, 1], 3),'D45','D47')
        arr[ 9 ] ++
      Endif
      // добавить
      If ad[ i, 3 ] == 2 // дисп.набл.установлено впервые
        arr[ 13 ] ++
      Endif
      If ad[ i, 10 ] == 1 // 1-лечение назначено
        arr[ 14 ] ++    // ?? было начато лечение
        If is_selo
          arr[ 15 ] ++
        Endif
      Endif
    Endif
  Next
  AAdd( a3, AClone( arr ) )
  If Between( mdvozrast, 15, 17 )
    arr[ 16 ] := 2
    j := iif( human->pol == 'М', 1, 7 )
    ar15[ j ] ++
    If is_selo
      ar15[ j + 1 ] ++
    Endif
    If ( i := AScan( ad, {| x| Left( x[ 1 ], 1 ) == 'N' } ) ) > 0 // патология органов репродуктивной системы
      ar15[ j + 3 ] ++
      If is_selo
        ar15[ j + 4 ] ++
      Endif
      If ad[ i, 2 ] > 0 // заболевания уст.впервые
        If is_2
          ar15[ j + 5 ] ++
        Endif
        If j == 1
          ar15[ 13 ] ++
          If is_selo
            ar15[ 14 ] ++
          Endif
        Else
          ar15[ 15 ] ++
          If is_selo
            ar15[ 16 ] ++
          Endif
        Endif
      Endif
    Endif

    fl := .f.
    Select HU
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. !Eof()
      If eq_any( hu_->PROFIL, 19, 136 )
        fl := .t.
      Endif
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
        lshifr := usl->shifr
      Endif
      If Left( lshifr, 2 ) == '2.'  // врачебный приём
        If Left( lshifr, 4 ) != '2.91'  // не полноценные игнорируем
          If j == 1
            ar15[ 17 ] ++
            If is_selo
              ar15[ 18 ] ++
            Endif
          Else
            ar15[ 19 ] ++
            If is_selo
              ar15[ 20 ] ++
            Endif
          Endif
          // mydebug(,human->fio)
          If hu_->PROFIL == 19
            arr[ 17 ] ++
          Endif
          If hu_->PROFIL == 136
            arr[ 18 ] ++
            // mydebug(,'2------------------------------------------')
          Endif
        Endif
      Endif
      Select HU
      Skip
    Enddo
    If fl
      ar15[ j + 2 ] ++
    Endif
  Else
    arr[ 16 ] := 1
  Endif
  AAdd( a3, AClone( arr ) )
  //
  // aadd(arr,{'12.4.1',m1FIZ_RAZV1})  // 'N',физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
  If m1fiz_razv1 == 1
    If fl_ves
      arr[ 22 ] ++
    Endif
  Endif
  //
  For j := 1 To Len( a3 )
    Select TMP2
    find ( Str( a3[ j, 16 ], 1 ) )
    If !Found()
      Append Blank
      tmp2->ti := a3[ j, 16 ]
    Endif
    For i := 1 To 15
      pole := 'tmp2->g' + lstr( i )
      &pole := &pole + a3[ j, i ]
    Next
    tmp2->g7n  := tmp2->g7n  + arr[ 17 ]
    tmp2->g8n  := tmp2->g8n  + arr[ 18 ]
    tmp2->g12n := tmp2->g12n + arr[ 19 ]
    tmp2->g13n := tmp2->g13n + arr[ 20 ]
    tmp2->g14n := tmp2->g14n + arr[ 21 ]
    tmp2->g16n := tmp2->g16n + arr[ 22 ]
  Next
  //
  For j := 1 To Len( ar )
    im := ar[ j ]
    Select TMP1
    find ( Str( im, 2 ) )
    tmp1->vsego++
    If is_selo
      tmp1->vsego1++
    Endif
    tmp1->m15  += ar15[ 1 ]
    tmp1->m15s += ar15[ 2 ]
    tmp1->m15pos += ar15[ 17 ]
    tmp1->m15poss += ar15[ 18 ]
    tmp1->m15a += ar15[ 3 ]
    tmp1->m15p += ar15[ 4 ]
    tmp1->m15ps += ar15[ 5 ]
    tmp1->m15p1 += ar15[ 13 ]
    tmp1->m15p1s += ar15[ 14 ]
    tmp1->m15e += ar15[ 6 ] // 2-й этап
    tmp1->g15  += ar15[ 7 ]
    tmp1->g15s += ar15[ 8 ]
    tmp1->g15pos += ar15[ 19 ]
    tmp1->g15poss += ar15[ 20 ]
    tmp1->g15g += ar15[ 9 ]
    tmp1->g15p += ar15[ 10 ]
    tmp1->g15ps += ar15[ 11 ]
    tmp1->g15p1 += ar15[ 15 ]
    tmp1->g15p1s += ar15[ 16 ]
    tmp1->g15e += ar15[ 12 ] // 2-й этап
    tmp1->g18 += ar15[ 23 ]
    tmp1->g18s += ar15[ 24 ]
    tmp1->m18 += ar15[ 25 ]
    tmp1->m18s += ar15[ 26 ]
    If Between( mgruppa, 1, 5 )
      pole := 'tmp1->g' + lstr( mgruppa )
      &pole := &pole + 1
      If Between( mgruppa, 4, 5 ) .and. m1invalid1 == 1 // инвалидность-да
        pole += 'inv'
        &pole := &pole + 1
      Endif
      If /*ltip_school == 0 .and.*/ between(m1GR_FIZ, 1, 4)
        pole := 'tmp1->mg' + lstr( m1GR_FIZ )
        &pole := &pole + 1
      Endif
      If is_2 // I и II этап
        tmp1->v2++
      Endif
    Endif
    If human->schet > 0
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        tmp1->sv++
        sumr := 0
        Select RPDSH
        find ( Str( Loc_kod, 7 ) )
        Do While rpdsh->KOD_H == Loc_kod .and. !Eof()
          sumr += rpdsh->S_SL
          Skip
        Enddo
        If Round( human->cena_1, 2 ) == Round( sumr, 2 ) // полностью оплачен
          tmp1->so++
        Endif
      Endif
    Endif
  Next

  Return Nil

// 25.03.18
Function inf_dnl_030poo( is_schet )

  Local arr_m, i, n, buf := save_maxrow(), lkod_h, lkod_k, rec, sh := 80, HH := 80, n_file := cur_dir() + 'f_030poo.txt', d1, d2

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    If arr_m[ 1 ] < 2018
      Return func_error( 4, 'Данная форма утверждена с 2018 года' )
    Endif
    mywait()
    If f0_inf_dnl( arr_m, is_schet > 1, is_schet == 3 )
      Private arr_deti[ 6 ] ; AFill( arr_deti, 0 )
      Private s12_1 := 0, s12_1m := 0, s12_2 := 0, s12_2m := 0
      Private arr_vozrast := { ;
        { 3, 0, 17 };
        }
      Private arr1vozrast := { ;
        { 0, 17 }, ;
        { 0, 4 }, ;
        { 0, 14 }, ;
        { 5, 9 }, ;
        { 10, 14 }, ;
        { 15, 17 };
        }
      Private arr_4 := { ;
        { '1', 'Некоторые инфекционные и паразит...', 'A00-B99',, }, ;
        { '1.1', 'туберкулез', 'A15-A19',, }, ;
        { '1.2', 'ВИЧ-инфекция, СПИД', 'B20-B24',, }, ;
        { '2', 'Новообразования', 'C00-D48',, }, ;
        { '3', 'Болезни крови и кроветворных органов ...', 'D50-D89',, }, ;
        { '3.1', 'анемии', 'D50-D53',, }, ;
        { '4', 'Болезни эндокринной системы, расстройства...', 'E00-E90',, }, ;
        { '4.1', 'сахарный диабет', 'E10-E14',, }, ;
        { '4.2', 'недостаточность питания', 'E40-E46',, }, ;
        { '4.3', 'ожирение', 'E66',, }, ;
        { '4.4', 'задержка полового развития', 'E30.0',, }, ;
        { '4.5', 'преждевременное половое развитие', 'E30.1',, }, ;
        { '5', 'Психические расстройства и расстро...', 'F00-F99',, }, ;
        { '5.1', 'умственная отсталость', 'F70-F79',, }, ;
        { '6', 'Болезни нервной системы, из них:', 'G00-G98',, }, ;
        { '6.1', 'церебральный паралич и другие ...', 'G80-G83',, }, ;
        { '7', 'Болезни глаза и его придаточного аппарата', 'H00-H59',, }, ;
        { '8', 'Болезни уха и сосцевидного отростка', 'H60-H95',, }, ;
        { '9', 'Болезни системы кровообращения', 'I00-I99',, }, ;
        { '10', 'Болезни органов дыхания, из них:', 'J00-J99',, }, ;
        { '10.1', 'астма, астматический статус', 'J45-J46',, }, ;
        { '11', 'Болезни органов пищеварения', 'K00-K93',, }, ;
        { '12', 'Болезни кожи и подкожной клетчатки', 'L00-L99',, }, ;
        { '13', 'Болезни костно-мышечной ...', 'M00-M99',, }, ;
        { '13.1', 'кифоз, лордоз, сколиоз', 'M40-M41',, }, ;
        { '14', 'Болезни мочеполовой системы, из них:', 'N00-N99',, }, ;
        { '14.1', 'болезни мужских половых органов', 'N40-N51',, }, ;
        { '14.2', 'нарушения ритма и характера менструаций', 'N91-N94.5',, }, ;
        { '14.3', 'воспалительные заболевания ...', 'N70-N77',, }, ;
        { '14.4', 'невоспалительные болезни ...', 'N83',, }, ;
        { '14.5', 'болезни молочной железы', 'N60-N64',, }, ;
        { '15', 'Отдельные состояния, возника...', 'P00-P96',, }, ;
        { '16', 'Врожденные аномалии (пороки ...', 'Q00-Q99',, }, ;
        { '16.1', 'развития нервной системы', 'Q00-Q07',, }, ;
        { '16.2', 'системы кровообращения', 'Q20-Q28',, }, ;
        { '16.3', 'женских половых органов', 'Q50-Q52',, }, ;
        { '16.4', 'мужских половых органов', 'Q53-Q55',, }, ;
        { '16.5', 'костно-мышечной системы', 'Q65-Q79',, }, ;
        { '17', 'Травмы, отравления и некоторые...', 'S00-T98',, }, ;
        { '18', 'Прочие', '',, }, ;
        { '19', 'ВСЕГО ЗАБОЛЕВАНИЙ', 'A00-T98',, };
        }
      For n := 1 To Len( arr_4 )
        If '-' $ arr_4[ n, 3 ]
          d1 := Token( arr_4[ n, 3 ], '-', 1 )
          d2 := Token( arr_4[ n, 3 ], '-', 2 )
        Else
          d1 := d2 := arr_4[ n, 3 ]
        Endif
        arr_4[ n, 4 ] := diag_to_num( d1, 1 )
        arr_4[ n, 5 ] := diag_to_num( d2, 2 )
      Next
      dbCreate( cur_dir() + 'tmp4', { ;
        { 'name', 'C', 100, 0 }, ;
        { 'diagnoz', 'C', 20, 0 }, ;
        { 'stroke', 'C', 4, 0 }, ;
        { 'ns', 'N', 2, 0 }, ;
        { 'diapazon1', 'N', 10, 0 }, ;
        { 'diapazon2', 'N', 10, 0 }, ;
        { 'tbl', 'N', 1, 0 }, ;
        { 'k04', 'N', 8, 0 }, ;
        { 'k05', 'N', 8, 0 }, ;
        { 'k06', 'N', 8, 0 }, ;
        { 'k07', 'N', 8, 0 }, ;
        { 'k08', 'N', 8, 0 }, ;
        { 'k09', 'N', 8, 0 }, ;
        { 'k10', 'N', 8, 0 }, ;
        { 'k11', 'N', 8, 0 } } )
      Use ( cur_dir() + 'tmp4' ) New Alias TMP
      For i := 1 To Len( arr_vozrast )
        For n := 1 To Len( arr_4 )
          Append Blank
          tmp->tbl := arr_vozrast[ i, 1 ]
          tmp->stroke := arr_4[ n, 1 ]
          tmp->name := arr_4[ n, 2 ]
          tmp->ns := n
          tmp->diagnoz := arr_4[ n, 3 ]
          tmp->diapazon1 := arr_4[ n, 4 ]
          tmp->diapazon2 := arr_4[ n, 5 ]
        Next
      Next
      Index On Str( FIELD->tbl, 1 ) + Str( FIELD->ns, 2 ) to ( cur_dir() + 'tmp4' )
      Use
      dbCreate( cur_dir() + 'tmp10', { ;
        { 'voz', 'N', 1, 0 }, ;
        { 'tbl', 'N', 2, 0 }, ;
        { 'tip', 'N', 2, 0 }, ;
        { 'kol', 'N', 6, 0 } } )
      Use ( cur_dir() + 'tmp10' ) New Alias TMP10
      Index On Str( FIELD->voz, 1 ) + Str( FIELD->tbl, 1 ) + Str( FIELD->tip, 2 ) to ( cur_dir() + 'tmp10' )
      Use
      Copy File ( cur_dir() + 'tmp10' + sdbf() ) to ( cur_dir() + 'tmp11' + sdbf() )
      Use ( cur_dir() + 'tmp11' ) New Alias TMP11
      Index On Str( FIELD->voz, 1 ) + Str( FIELD->tbl, 2 ) + Str( FIELD->tip, 2 ) to ( cur_dir() + 'tmp11' )
      Use
      dbCreate( cur_dir() + 'tmp13', { ;
        { 'voz', 'N', 1, 0 }, ;
        { 'tip', 'N', 2, 0 }, ;
        { 'kol', 'N', 6, 0 } } )
      Use ( cur_dir() + 'tmp13' ) New Alias TMP13
      Index On Str( FIELD->voz, 1 ) + Str( FIELD->tip, 2 ) to ( cur_dir() + 'tmp13' )
      Use
      dbCreate( cur_dir() + 'tmp16', { ;
        { 'voz', 'N', 1, 0 }, ;
        { 'man', 'N', 1, 0 }, ;
        { 'tip', 'N', 2, 0 }, ;
        { 'kol', 'N', 6, 0 } } )
      Use ( cur_dir() + 'tmp16' ) New Alias TMP16
      Index On Str( FIELD->voz, 1 ) + Str( FIELD->man, 1 ) + Str( FIELD->tip, 2 ) to ( cur_dir() + 'tmp16' )
      Use
      dbCloseAll()
      Use ( cur_dir() + 'tmp4' )  index ( cur_dir() + 'tmp4' )  new
      Use ( cur_dir() + 'tmp10' ) index ( cur_dir() + 'tmp10' ) new
      Use ( cur_dir() + 'tmp11' ) index ( cur_dir() + 'tmp11' ) new
      Use ( cur_dir() + 'tmp13' ) index ( cur_dir() + 'tmp13' ) new
      Use ( cur_dir() + 'tmp16' ) index ( cur_dir() + 'tmp16' ) new
      r_use( dir_server() + 'human_',, 'HUMAN_' )
      r_use( dir_server() + 'human',, 'HUMAN' )
      Set Relation To RecNo() into HUMAN_
      r_use( cur_dir() + 'tmp' )
      Set Relation To FIELD->kod into HUMAN
      ii := 0
      mywait( ' ' )
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say PadR( Str( ++ii / tmp->( LastRec() ) * 100, 6, 2 ) + '%  ' + AllTrim( human->fio ) + '  ' + full_date( human->date_r ), 80 ) Color cColorWait
        f2_inf_dnl_030poo( human->kod, human->kod_k )
        Select TMP
        Skip
      Enddo
      Close databases
      //
      fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( glob_mo()[ _MO_SHORT_NAME ] )
      add_string( PadL( 'Приложение 3', sh ) )
      add_string( PadL( 'к Приказу МЗРФ', sh ) )
      add_string( PadL( '№514н от 10.08.2017г.', sh ) )
      add_string( '' )
      add_string( PadL( 'Форма статистической отчетности № 030-ПО/о-17', sh ) )
      add_string( '' )
      add_string( Center( 'Сведения о профилактических медицинских осмотрах несовершеннолетних', sh ) )
      add_string( Center( '[ ' + CharRem( '~', mas1pmt()[ is_schet ] ) + ' ]', sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( '' )
      add_string( '2. Число детей, прошедших профосмотры в отчетном периоде:' )
      add_string( '  2.1. всего в возрасте от 0 до 17 лет включительно:' + Str( arr_deti[ 1 ], 6 ) + ' (человек), из них:' )
      add_string( '  2.1.1. в возрасте от 0 до 4 лет включительно      ' + Str( arr_deti[ 2 ], 6 ) + ' (человек),' )
      add_string( '  2.1.2. в возрасте от 0 до 14 лет включительно     ' + Str( arr_deti[ 2 ] + arr_deti[ 3 ] + arr_deti[ 4 ], 6 ) + ' (человек),' )
      add_string( '  2.1.3. в возрасте от 5 до 9 лет включительно      ' + Str( arr_deti[ 3 ], 6 ) + ' (человек),' )
      add_string( '  2.1.4. в возрасте от 10 до 14 лет включительно    ' + Str( arr_deti[ 4 ], 6 ) + ' (человек),' )
      add_string( '  2.1.5. в возрасте от 15 до 17 лет включительно    ' + Str( arr_deti[ 5 ], 6 ) + ' (человек),' )
      add_string( '  2.1.6. детей-инвалидов от 0 до 17 лет включительно' + Str( arr_deti[ 6 ], 6 ) + ' (человек).' )
      For i := 1 To Len( arr_vozrast )
        verify_ff( HH -50, .t., sh )
        add_string( '' )
        add_string( Center( lstr( arr_vozrast[ i, 1 ] ) + ;
          '. Структура выявленных заболеваниях (состояний) у детей в возрасте от ' + ;
          lstr( arr_vozrast[ i, 2 ] ) + ' до ' + lstr( arr_vozrast[ i, 3 ] ) + ' лет включительно', sh ) )
        add_string( '────┬───────────────────┬───────┬─────┬─────┬─────┬─────┬───────────────────────' )
        add_string( ' №№ │    Наименование   │ Код по│Всего│в т.ч│выяв-│в т.ч│Состоит под дисп.наблюд' )
        add_string( ' пп │    заболеваний    │ МКБ-10│зарег│маль-│лено │маль-├─────┬─────┬─────┬─────' )
        add_string( '    │                   │       │забол│чики │вперв│чики │всего│мальч│взято│мальч' )
        add_string( '────┼───────────────────┼───────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────' )
        add_string( ' 1  │          2        │   3   │  4  │  5  │  6  │  7  │  8  │  9  │ 10  │ 11  ' )
        add_string( '────┴───────────────────┴───────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────' )
        Use ( cur_dir() + 'tmp4' ) index ( cur_dir() + 'tmp4' ) New Alias TMP
        find ( Str( arr_vozrast[ i, 1 ], 1 ) )
        Do While tmp->tbl == arr_vozrast[ i, 1 ] .and. !Eof()
          s := tmp->stroke + ' ' + PadR( tmp->name, 19 ) + ' ' + PadC( AllTrim( tmp->diagnoz ), 7 )
          For n := 4 To 11
            s += put_val( tmp->&( 'k' + StrZero( n, 2 ) ), 6 )
          Next
          add_string( s )
          Skip
        Enddo
        Use
        add_string( Replicate( '─', sh ) )
      Next
      arr1title := { ;
        '────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────', ;
        '                    │   Всего   │   в МО    │   в ГУЗ   │в федераль-│ в частных ', ;
        '  Возраст детей     │           │           │субъекта РФ│  ных ГУЗ  │    МО     ', ;
        '                    │           │           │           │           │           ', ;
        '────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────', ;
        '          1         │     2     │     3     │     4     │     5     │     6     ', ;
        '────────────────────┴───────────┴───────────┴───────────┴───────────┴───────────' }
      arr2title := { ;
        '────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────', ;
        '                    │   Всего   │в муниц.МО │   в ГУЗ   │в федераль-│ в частных ', ;
        '  Возраст детей     ├─────┬─────┼─────┬─────┤субъекта РФ├──ных ГУЗ──┼────МО─────', ;
        '                    │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  ', ;
        '────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────', ;
        '          1         │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 ', ;
        '────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────' }
      arr3title := { ;
        '────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────', ;
        ' Возраст│   Всего   │   в МО    │   в ГУЗ   │в федераль-│ в частных │в санаторно', ;
        ' детей  │           │           │субъекта РФ│  ных ГУЗ  │    МО     │-курортных ', ;
        '        │           │           │           │           │           │организ-ях ', ;
        '────────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────', ;
        '    1   │     2     │     3     │     4     │     5     │     6     │     7     ', ;
        '────────┴───────────┴───────────┴───────────┴───────────┴───────────┴───────────' }
      arr4title := { ;
        '────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────', ;
        ' Возраст│   Всего   │в муниц.МО │   в ГУЗ   │в федераль-│ в частных │в сан.-кур.', ;
        ' детей  ├─────┬─────┼─────┬─────┤субъекта РФ├──ных ГУЗ──┼────МО─────┼──орг-иях──', ;
        '        │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  ', ;
        '────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────', ;
        '    1   │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 │  12 │  13 ', ;
        '────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────' }
      verify_ff( HH -50, .t., sh )
      add_string( '4. Результаты дополнительных консультаций, исследований, лечения, медицинской' )
      add_string( '   реабилитации детей по результатам проведения профилактических осмотров:' )
      Use ( cur_dir() + 'tmp10' ) index ( cur_dir() + 'tmp10' ) New Alias TMP10
      For i := 1 To 2
        verify_ff( HH -16, .t., sh )
        add_string( '' )
        s := Space( 5 )
        If i == 1
          add_string( s + '4.1. Дополнительные консультации и (или) исследования' )
        Else
          add_string( s + '4.2. Лечение, медицинская реабилитация и санаторно-курортное лечение' )
        Endif
        n := 20
        If eq_any( i, 1, 3, 5, 6, 7 )
          AEval( arr1title, {| x| add_string( x ) } )
        Elseif eq_any( i, 2, 4 )
          AEval( arr2title, {| x| add_string( x ) } )
        Else
          AEval( arr3title, {| x| add_string( x ) } )
          n := 8
        Endif
        For j := 1 To Len( arr1vozrast )
          s := PadC( lstr( arr1vozrast[ j, 1 ] ) + ' - ' + lstr( arr1vozrast[ j, 2 ] ), n )
          skol := oldkol := 0
          s1 := ''
          For k := 1 To iif( i == 8, 5, 4 )
            find ( Str( j, 1 ) + Str( i, 1 ) + Str( k, 1 ) )
            If Found() .and. ( v := tmp10->kol ) > 0
              skol += v
              If eq_any( i, 2, 4 )
                s1 += Str( v, 6 )
                find ( Str( j, 1 ) + Str( i -1, 1 ) + Str( k, 1 ) )
                If Found() .and. tmp10->kol > 0
                  s1 += ' ' + umest_val( v / tmp10->kol * 100, 5, 2 )
                  oldkol += tmp10->kol
                Else
                  s1 += Space( 6 )
                Endif
              Else
                s1 += ' ' + PadC( lstr( v ), 11 )
              Endif
            Else
              s1 += Space( 12 )
            Endif
          Next
          If skol > 0
            If eq_any( i, 2, 4 )
              s += Str( skol, 6 ) + ' ' + umest_val( skol / oldkol * 100, 5, 2 )
            Else
              s += ' ' + PadC( lstr( skol ), 11 )
            Endif
            add_string( s + s1 )
          Else
            add_string( s )
          Endif
        Next
        add_string( Replicate( '─', sh ) )
      Next
      Use
      //
      // verify_FF(HH-50, .t., sh)
      // add_string('11. Результаты лечения, медицинской реабилитации и (или) санаторно-курортного')
      // add_string('    лечения детей до проведения настоящего профилактического осмотра:')
      vkol := 0
      Use ( cur_dir() + 'tmp11' ) index ( cur_dir() + 'tmp11' ) New Alias TMP11
      For i := 1 To 0// 12
        If i % 3 > 0
          verify_ff( HH -16, .t., sh )
          add_string( '' )
        Endif
        s := Space( 5 )
        If i == 1
          add_string( s + '11.1. Рекомендовано лечение в амбулаторных условиях и в условиях' )
          add_string( s + '      дневного стационара' )
        Elseif i == 2
          add_string( s + '11.2. Проведено лечение в амбулаторных условиях и в условиях' )
          add_string( s + '      дневного стационара' )
        Elseif i == 3
          add_string( s + '11.3. Причины невыполнения рекомендаций по лечению в амбулаторных условиях' )
          add_string( s + '      и в условиях дневного стационара:' )
          add_string( s + '        11.3.1. не прошли всего ' + lstr( vkol ) + ' (человек)' )
        Elseif i == 4
          add_string( s + '11.4. Рекомендовано лечение в стационарных условиях' )
        Elseif i == 5
          add_string( s + '11.5. Проведено лечение в стационарных условиях' )
        Elseif i == 6
          add_string( s + '11.6. Причины невыполнения рекомендаций по лечению в стационарных условиях:' )
          add_string( s + '        11.6.1. не прошли всего ' + lstr( vkol ) + ' (человек)' )
        Elseif i == 7
          add_string( s + '11.7. Рекомендована медицинская реабилитация' )
          add_string( s + '      в амбулаторных условиях и в условиях дневного стационара' )
        Elseif i == 8
          add_string( s + '11.8. Проведена медицинская реабилитация' )
          add_string( s + '      в амбулаторных условиях и в условиях дневного стационара' )
        Elseif i == 9
          add_string( s + '11.9. Причины невыполнения рекомендаций по медицинской реабилитации' )
          add_string( s + '      в амбулаторных условиях и в условиях дневного стационара:' )
          add_string( s + '        11.9.1. не прошли всего ' + lstr( vkol ) + ' (человек)' )
        Elseif i == 10
          add_string( s + '11.10. Рекомендованы медицинская реабилитация и (или)' )
          add_string( s + '       санаторно-курортное лечение в стационарных условиях' )
        Elseif i == 11
          add_string( s + '11.11. Проведена медицинская реабилитация и (или)' )
          add_string( s + '       санаторно-курортное лечение в стационарных условиях' )
        Else
          add_string( s + '11.12. Причины невыполнения рекомендаций по медицинской реабилитации' )
          add_string( s + '       и (или) санаторно-курортному лечению в стационарных условиях:' )
          add_string( s + '         11.12.1. не прошли всего ' + lstr( vkol ) + ' (человек)' )
        Endif
        If i % 3 > 0
          n := 20
          If eq_any( i, 1, 4, 7 )
            AEval( arr1title, {| x| add_string( x ) } )
          Elseif eq_any( i, 2, 5, 8 )
            AEval( arr2title, {| x| add_string( x ) } )
          Elseif i == 10
            AEval( arr3title, {| x| add_string( x ) } )
            n := 8
          Elseif i == 11
            AEval( arr4title, {| x| add_string( x ) } )
            n := 8
          Endif
          For j := 1 To Len( arr1vozrast )
            s := PadC( lstr( arr1vozrast[ j, 1 ] ) + ' - ' + lstr( arr1vozrast[ j, 2 ] ), n )
            skol := oldkol := 0
            s1 := ''
            For k := 1 To iif( i > 10, 5, 4 )
              find ( Str( j, 1 ) + Str( i, 2 ) + Str( k, 1 ) )
              If Found() .and. ( v := tmp11->kol ) > 0
                skol += v
                If eq_any( i, 2, 5, 8, 11 )
                  s1 += Str( v, 6 )
                  find ( Str( j, 1 ) + Str( i -1, 2 ) + Str( k, 1 ) )
                  If Found() .and. tmp11->kol > 0
                    s1 += ' ' + umest_val( v / tmp11->kol * 100, 5, 2 )
                    oldkol += tmp11->kol
                  Else
                    s1 += Space( 6 )
                  Endif
                Else
                  s1 += ' ' + PadC( lstr( v ), 11 )
                Endif
              Else
                s1 += Space( 12 )
              Endif
            Next
            If eq_any( i, 2, 5, 8, 11 )
              vkol := oldkol - skol
            Endif
            If skol > 0
              If eq_any( i, 2, 5, 8, 11 )
                s += Str( skol, 6 ) + ' ' + umest_val( skol / oldkol * 100, 5, 2 )
              Else
                s += ' ' + PadC( lstr( skol ), 11 )
              Endif
              add_string( s + s1 )
            Else
              add_string( s )
            Endif
          Next
          add_string( Replicate( '─', sh ) )
        Endif
      Next
      Use
      Use ( cur_dir() + 'tmp16' ) index ( cur_dir() + 'tmp16' ) New Alias TMP16
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( '' )
      add_string( '5. Число детей по уровню физического развития' )
      add_string( '────────────────────┬─────────┬─────────┬───────────────────────────────────────' )
      add_string( '                    │Число про│Норм.физ.│ Нарушения физического развития (чел.) ' )
      add_string( '    Возраст детей   │шедших   │развитие ├─────────┬─────────┬─────────┬─────────' )
      add_string( '                    │проф.осм.│   чел.  │дефиц.мас│избыт.мас│низк.рост│высо.рост' )
      add_string( '────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────' )
      add_string( '          1         │    2    │    3    │    4    │    5    │    6    │    7    ' )
      add_string( '────────────────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────' )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( ' ' + lstr( arr1vozrast[ j, 1 ] ) + ' - ' + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, '', ' (мальчики)' ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += ' ' + PadC( lstr( tmp16->kol ), 9 )
          Else
            s += Space( 10 )
          Endif
          For i := 1 To 5
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            If Found()
              s += ' ' + PadC( lstr( tmp16->kol ), 9 )
            Else
              s += Space( 10 )
            Endif
          Next
          add_string( s )
        Next
      Next
      add_string( Replicate( '─', sh ) )
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( '' )
      add_string( '6. Число детей по медицинским группам для занятий физической культурой' )
      add_string( '────────────────────┬─────────┬────────────────────────┬────────────────────────' )
      add_string( '                    │Число про│    до проф.осмотра     │ по результатам проф.осм' )
      add_string( '    Возраст детей   │шедших   ├────┬────┬────┬────┬────┼────┬────┬────┬────┬────' )
      add_string( '                    │проф.осм.│ I  │ II │ III│ IV │не д│ I  │ II │ III│ IV │не д' )
      add_string( '────────────────────┼─────────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────' )
      add_string( '          1         │    2    │ 3  │ 4  │ 5  │ 6  │ 7  │ 8  │ 9  │ 10 │ 11 │ 12 ' )
      add_string( '────────────────────┴─────────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────' )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( ' ' + lstr( arr1vozrast[ j, 1 ] ) + ' - ' + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, '', ' (мальчики)' ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += ' ' + PadC( lstr( tmp16->kol ), 9 )
          Else
            s += Space( 10 )
          Endif
          For i := 31 To 35
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          For i := 41 To 45
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          add_string( s )
        Next
      Next
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( '' )
      add_string( '7. Число детей по группам здоровья' )
      add_string( '────────────────────┬─────────┬────────────────────────┬────────────────────────' )
      add_string( '                    │Число про│    до проф.осмотра     │ по результатам проф.осм' )
      add_string( '    Возраст детей   │шедших   ├────┬────┬────┬────┬────┼────┬────┬────┬────┬────' )
      add_string( '                    │проф.осм.│ I  │ II │ III│ IV │ V  │ I  │ II │ III│ IV │ V  ' )
      add_string( '────────────────────┼─────────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────' )
      add_string( '          1         │    2    │ 3  │ 4  │ 5  │ 6  │ 7  │ 8  │ 9  │ 10 │ 11 │ 12 ' )
      add_string( '────────────────────┴─────────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────' )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( ' ' + lstr( arr1vozrast[ j, 1 ] ) + ' - ' + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, '', ' (мальчики)' ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += ' ' + PadC( lstr( tmp16->kol ), 9 )
          Else
            s += Space( 10 )
          Endif
          For i := 11 To 15
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          For i := 21 To 25
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          add_string( s )
        Next
      Next
      add_string( Replicate( '─', sh ) )
      FClose( fp )
      viewtext( n_file,,,, .t.,,, 5 )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 28.09.25
Function f2_inf_dnl_030poo( Loc_kod, kod_kartotek ) // сводная информация

  Local i, j, k, av := {}, av1 := {}, ad := {}, arr, s, fl, ;
    is_man := ( human->pol == 'М' ), blk_tbl, blk_tip, blk_put_tip, a10[ 9 ], a11[ 13 ]

  blk_tbl := {| _k| iif( _k < 2, 1, 2 ) }
  blk_tip := {| _k| iif( _k == 0, 2, iif( _k > 1, _k + 1, _k ) ) }
  blk_put_tip := {| _e, _k| iif( _k > _e, _k, _e ) }
  Private metap := 1, mperiod := 0, mshifr_zs := '', m1lis := 0, ;
    mkateg_uch, m1kateg_uch := 3, ; // Категория учета ребенка:
    mMO_PR := Space( 10 ), m1MO_PR := Space( 6 ), ; // код МО прикрепления
    mschool := Space( 10 ), m1school := 0, ; // код обр.учреждения
    mWEIGHT := 0, ;   // вес в кг
    mHEIGHT := 0, ;   // рост в см
    mPER_HEAD := 0, ; // окружность головы в см
    mfiz_razv, m1FIZ_RAZV := 0, ; // физическое развитие
    mfiz_razv1, m1FIZ_RAZV1 := 0, ; // отклонение массы тела
    mfiz_razv2, m1FIZ_RAZV2 := 0, ; // отклонение роста
    m1psih11 := 0, ;  // познавательная функция (возраст развития)
    m1psih12 := 0, ;  // моторная функция (возраст развития)
    m1psih13 := 0, ;  // эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития)
    m1psih14 := 0, ;  // предречевое и речевое развитие (возраст развития)
    mpsih21, m1psih21 := 0, ;  // Психомоторная сфера: (норма, отклонение)
    mpsih22, m1psih22 := 0, ;  // Интеллект: (норма, отклонение)
    mpsih23, m1psih23 := 0, ;  // Эмоционально-вегетативная сфера: (норма, отклонение)
    m141p   := 0, ; // Половая формула мальчика P
    m141ax  := 0, ; // Половая формула мальчика Ax
    m141fa  := 0, ; // Половая формула мальчика Fa
    m142p   := 0, ; // Половая формула девочки P
    m142ax  := 0, ; // Половая формула девочки Ax
    m142ma  := 0, ; // Половая формула девочки Ma
    m142me  := 0, ; // Половая формула девочки Me
    m142me1 := 0, ; // Половая формула девочки - menarhe (лет)
    m142me2 := 0, ; // Половая формула девочки - menarhe (месяцев)
    m142me3, m1142me3 := 0, ; // Половая формула девочки - menses (характеристика):
    m142me4, m1142me4 := 1, ; // Половая формула девочки - menses (характеристика):
    m142me5, m1142me5 := 1, ; // Половая формула девочки - menses (характеристика):
    mdiag_15_1, m1diag_15_1 := 1, ; // Состояние здоровья до проведения профосмотра-Практически здоров
    mdiag_15[ 5, 14 ], ; //
    mGRUPPA_DO := 0, ; // группа здоровья до дисп-ии
    mGR_FIZ_DO, m1GR_FIZ_DO := 1, ;
    mdiag_16_1, m1diag_16_1 := 1, ; // Состояние здоровья по результатам проведения профосмотра (Практически здоров)
    mdiag_16[ 5, 16 ], ; //
    minvalid[ 8 ], ;  // раздел 16.7
    mGRUPPA := 0, ;    // группа здоровья после дисп-ии
    mGR_FIZ, m1GR_FIZ := 1, ;
    mPRIVIVKI[ 3 ], ; // Проведение профилактических прививок
    mrek_form := Space( 255 ), ; // 'C100',Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой
    mrek_disp := Space( 255 ), ; // 'C100',Рекомендации по диспансерному наблюдению, лечению, медицинской реабилитации и санаторно-курортному лечению с указанием диагноза (код МКБ), вида медицинской организации и специальности (должности) врача
    mhormon := '0 шт.', m1hormon := 1, not_hormon, ;
    mstep2, m1step2 := 0
  Private minvalid1, m1invalid1 := 0, ;
    minvalid2, m1invalid2 := 0, ;
    minvalid3 := CToD( '' ), minvalid4 := CToD( '' ), ;
    minvalid5, m1invalid5 := 0, ;
    minvalid6, m1invalid6 := 0, ;
    minvalid7 := CToD( '' ), ;
    minvalid8, m1invalid8 := 0
  Private mprivivki1, m1privivki1 := 0, ;
    mprivivki2, m1privivki2 := 0, ;
    mprivivki3 := Space( 100 )
  Private mvar, m1var, m1lis := 0
  //
  For i := 1 To 5
    For k := 1 To 14
      s := 'diag_15_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := 'm1' + s
        Private &m1var := 0
        Private &mvar := Space( 4 )
      Endif
    Next
  Next
  //
  For i := 1 To 5
    For k := 1 To 16
      s := 'diag_16_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := 'm1' + s
        Private &m1var := 0
        Private &mvar := Space( 3 )
      Endif
    Next
  Next
  mvozrast := count_years( human->date_r, human->n_data )
  If !Between( mvozrast, 0, 17 )
    mvozrast := 17
  Endif
  mdvozrast := Year( human->n_data ) - Year( human->date_r )
  If !Between( mdvozrast, 0, 17 )
    mdvozrast := 17
  Endif
  read_arr_pn( Loc_kod, .t., human->K_DATA )
  arr_deti[ 1 ] ++
  If mdvozrast < 5
    arr_deti[ 2 ] ++
  Elseif mdvozrast < 10
    arr_deti[ 3 ] ++
  Elseif mdvozrast < 15
    arr_deti[ 4 ] ++
  Else
    arr_deti[ 5 ] ++
  Endif
  For i := 1 To Len( arr_vozrast )
    If Between( mdvozrast, arr_vozrast[ i, 2 ], arr_vozrast[ i, 3 ] )
      AAdd( av, arr_vozrast[ i, 1 ] ) // список таблиц с 4 по 9
    Endif
  Next
  For i := 1 To Len( arr1vozrast )
    If Between( mdvozrast, arr1vozrast[ i, 1 ], arr1vozrast[ i, 2 ] )
      AAdd( av1, i )
    Endif
  Next
  For i := 1 To 5
    j := 0
    For k := 1 To 16
      s := 'diag_16_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 16 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := 'm1' + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  AFill( a10, 0 )
  For i := 1 To Len( ad ) // цикл по диагнозам
    au := {}
    d := diag_to_num( ad[ i, 1 ], 1 )
    For n := 1 To Len( arr_4 )
      If !Empty( arr_4[ n, 3 ] ) .and. Between( d, arr_4[ n, 4 ], arr_4[ n, 5 ] )
        AAdd( au, n )
      Endif
    Next
    If Len( au ) == 1
      AAdd( au, Len( arr_4 ) -1 )  // {'18','Прочие','',,}, ;
    Endif
    Select TMP4
    For n := 1 To Len( av ) // цикл по списку таблиц с 4 по 9
      For j := 1 To Len( au )
        find ( Str( av[ n ], 1 ) + Str( au[ j ], 2 ) )
        If Found()
          tmp4->k04++
          If is_man
            tmp4->k05++
          Endif
          If ad[ i, 2 ] > 0 // уст.впервые
            tmp4->k06++
            If is_man
              tmp4->k07++
            Endif
          Endif
          If ad[ i, 3 ] > 0 // дисп.набл.установлено
            tmp4->k08++
            If is_man
              tmp4->k09++
            Endif
            If ad[ i, 3 ] == 2 // дисп.набл.установлено впервые
              tmp4->k10++
              If is_man
                tmp4->k11++
              Endif
            Endif
          Endif
        Endif
      Next
    Next
    If ad[ i, 4 ] == 1 // 1-доп.конс.назначены
      ntbl := Eval( blk_tbl, ad[ i, 5 ] )
      ntip := Eval( blk_tip, ad[ i, 6 ] )
      If ntbl == 1 .and. a10[ 3 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2
        a10[ 1 ] := 0
        a10[ 3 ] := Eval( blk_put_tip, a10[ 3 ], ntip )
      Else
        a10[ 1 ] := Eval( blk_put_tip, a10[ 1 ], ntip )
        a10[ 3 ] := 0
      Endif
    Endif
    If ad[ i, 7 ] == 1 // 1-доп.конс.выполнены
      ntbl := Eval( blk_tbl, ad[ i, 8 ] )
      ntip := Eval( blk_tip, ad[ i, 9 ] )
      If ntbl == 1 .and. a10[ 4 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2
        a10[ 2 ] := 0
        a10[ 4 ] := Eval( blk_put_tip, a10[ 4 ], ntip )
      Else
        a10[ 2 ] := Eval( blk_put_tip, a10[ 2 ], ntip )
        a10[ 4 ] := 0
      Endif
    Endif
    If ad[ i, 10 ] == 1 // 1-лечение назначено
      ntbl := Eval( blk_tbl, ad[ i, 11 ] )
      ntip := Eval( blk_tip, ad[ i, 12 ] )
      If ntbl == 1 .and. a10[ 6 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2
        a10[ 5 ] := 0
        a10[ 6 ] := Eval( blk_put_tip, a10[ 6 ], ntip )
      Else
        a10[ 5 ] := Eval( blk_put_tip, a10[ 5 ], ntip )
        a10[ 6 ] := 0
      Endif
    Endif
    If ad[ i, 13 ] == 1 // 1-реабил.назначена
      ntbl := Eval( blk_tbl, ad[ i, 14 ] )
      ntip := Eval( blk_tip, ad[ i, 15 ] )
      If ntbl == 1 .and. a10[ 8 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2 .or. ntip == 5 // или санаторий
        a10[ 7 ] := 0
        a10[ 8 ] := Eval( blk_put_tip, a10[ 8 ], ntip )
      Else
        a10[ 7 ] := Eval( blk_put_tip, a10[ 7 ], ntip )
        a10[ 8 ] := 0
      Endif
    Endif
    If ad[ i, 16 ] == 1 // 1-ВМП назначена
      a10[ 9 ] := 1
    Endif
  Next
  Select TMP10
  For n := 1 To Len( av1 ) // цикл по возрастам таблиц 10
    For j := 1 To Len( a10 ) -1
      If a10[ j ] > 0
        find ( Str( av1[ n ], 1 ) + Str( j, 1 ) + Str( a10[ j ], 2 ) )
        If !Found()
          Append Blank
          tmp10->voz := av1[ n ]
          tmp10->tbl := j
          tmp10->tip := a10[ j ]
        Endif
        tmp10->kol++
      Endif
    Next
  Next
  ad := {}
  For i := 1 To 5
    j := 0
    For k := 1 To 14
      s := 'diag_15_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 14 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := 'm1' + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  AFill( a11, 0 )
  For i := 1 To Len( ad ) // цикл по диагнозам
    If ad[ i, 3 ] == 1 // 1-лечение назначено
      ntbl := Eval( blk_tbl, ad[ i, 4 ] )
      ntip := Eval( blk_tip, ad[ i, 5 ] )
      If ntbl == 1 .and. a11[ 4 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2
        a11[ 1 ] := 0
        a11[ 4 ] := Eval( blk_put_tip, a11[ 4 ], ntip )
      Else
        a11[ 1 ] := Eval( blk_put_tip, a11[ 1 ], ntip )
        a11[ 4 ] := 0
      Endif
      // лечение выполнено
      ntbl := Eval( blk_tbl, ad[ i, 6 ] )
      ntip := Eval( blk_tip, ad[ i, 7 ] )
      If ntbl == 1 .and. a11[ 5 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2
        a11[ 2 ] := 0
        a11[ 5 ] := Eval( blk_put_tip, a11[ 5 ], ntip )
      Else
        a11[ 2 ] := Eval( blk_put_tip, a11[ 2 ], ntip )
        a11[ 5 ] := 0
      Endif
    Endif
    If ad[ i, 8 ] == 1 // 1-реабил.назначена
      ntbl := Eval( blk_tbl, ad[ i, 9 ] )
      ntip := Eval( blk_tip, ad[ i, 10 ] )
      If ntbl == 1 .and. a11[ 10 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2
        a11[ 7 ] := 0
        a11[ 10 ] := Eval( blk_put_tip, a11[ 10 ], ntip )
      Else
        a11[ 7 ] := Eval( blk_put_tip, a11[ 7 ], ntip )
        a11[ 10 ] := 0
      Endif
      // 1-реабил.выполнена
      ntbl := Eval( blk_tbl, ad[ i, 11 ] )
      ntip := Eval( blk_tip, ad[ i, 12 ] )
      If ntbl == 1 .and. a11[ 11 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2 .or. ntip == 5 // или санаторий
        a11[ 8 ] := 0
        a11[ 11 ] := Eval( blk_put_tip, a11[ 11 ], ntip )
      Else
        a11[ 8 ] := Eval( blk_put_tip, a11[ 8 ], ntip )
        a11[ 11 ] := 0
      Endif
    Endif
    If ad[ i, 14 ] == 1 // 1-ВМП проведена
      a11[ 13 ] := 1
    Endif
  Next
  Select TMP11
  For n := 1 To Len( av1 ) // цикл по возрастам таблиц 10
    For j := 1 To Len( a11 ) -1
      If a11[ j ] > 0
        find ( Str( av1[ n ], 1 ) + Str( j, 2 ) + Str( a11[ j ], 2 ) )
        If !Found()
          Append Blank
          tmp11->voz := av1[ n ]
          tmp11->tbl := j
          tmp11->tip := a11[ j ]
        Endif
        tmp11->kol++
      Endif
    Next
  Next
  If a10[ 9 ] > 0
    s12_1++
    If is_man
      s12_1m++
    Endif
  Endif
  If a11[ 13 ] > 0
    s12_2++
    If is_man
      s12_2m++
    Endif
  Endif
  ad := { 0 }
  If m1invalid1 == 1 // инвалидность-да
    arr_deti[ 6 ] ++
    AAdd( ad, 4 )
    If m1invalid2 == 0 // с рождения
      AAdd( ad, 1 )
    Else               // приобретенная
      AAdd( ad, 2 )
      If !Empty( minvalid3 ) .and. minvalid3 >= human->n_data
        AAdd( ad, 3 )
      Endif
    Endif
    If !Empty( minvalid7 ) // Дата назначения инд.программы реабилитации
      AAdd( ad, 10 )
      Do Case // выполнение
      Case m1invalid8 == 1 // полностью, 1
        AAdd( ad, 11 )
      Case m1invalid8 == 2 // частично, 2
        AAdd( ad, 12 )
      Case m1invalid8 == 3 // начата, 3
        AAdd( ad, 13 )
      Otherwise            // не выполнена, 0
        AAdd( ad, 14 )
      Endcase
    Endif
  Endif
  If m1privivki1 == 1     // не привит по медицинским показаниям', 1}, ;
    If m1privivki2 == 1
      AAdd( ad, 21 )
    Else
      AAdd( ad, 22 )
    Endif
  Elseif m1privivki1 == 2 // не привит по другим причинам', 2}}
    If m1privivki2 == 1
      AAdd( ad, 23 )
    Else
      AAdd( ad, 24 )
    Endif
  Else                    // привит по возрасту', 0}, ;
    AAdd( ad, 20 )
  Endif
  Select TMP13
  For n := 1 To Len( av1 ) // цикл по возрастам таблицы
    For j := 1 To Len( ad )
      find ( Str( av1[ n ], 1 ) + Str( ad[ j ], 2 ) )
      If !Found()
        Append Blank
        tmp13->voz := av1[ n ]
        tmp13->tip := ad[ j ]
      Endif
      tmp13->kol++
    Next
  Next
  ad := { 0 }
  If m1fiz_razv == 0
    AAdd( ad, 1 )
  Else
    If m1fiz_razv1 == 1
      AAdd( ad, 2 )
    Elseif m1fiz_razv1 == 2
      AAdd( ad, 3 )
    Endif
    If m1fiz_razv2 == 1
      AAdd( ad, 4 )
    Elseif m1fiz_razv2 == 2
      AAdd( ad, 5 )
    Endif
  Endif
  mGRUPPA := human_->RSLT_NEW - 331 // L_BEGIN_RSLT
  If !Between( mgruppa, 1, 5 )
    mgruppa := 1
  Endif
  If !Between( mgruppa_do, 1, 5 )
    mgruppa_do := 1
  Endif
  If !Between( m1GR_FIZ, 0, 4 )
    m1GR_FIZ := 1
  Endif
  If !Between( m1GR_FIZ_DO, 0, 4 )
    m1GR_FIZ_DO := 1
  Endif
  AAdd( ad, mGRUPPA_DO + 10 )
  AAdd( ad, mGRUPPA + 20 )
  AAdd( ad, iif( m1GR_FIZ_DO == 0, 35, m1GR_FIZ_DO + 30 ) )
  AAdd( ad, iif( m1GR_FIZ == 0, 45, m1GR_FIZ + 40 ) )
  Select TMP16
  For n := 1 To Len( av1 ) // цикл по возрастам таблицы
    For j := 1 To Len( ad )
      find ( Str( av1[ n ], 1 ) + '0' + Str( ad[ j ], 2 ) )
      If !Found()
        Append Blank
        tmp16->voz := av1[ n ]
        tmp16->tip := ad[ j ]
      Endif
      tmp16->kol++
      If is_man
        find ( Str( av1[ n ], 1 ) + '1' + Str( ad[ j ], 2 ) )
        If !Found()
          Append Blank
          tmp16->voz := av1[ n ]
          tmp16->man := 1
          tmp16->tip := ad[ j ]
        Endif
        tmp16->kol++
      Endif
    Next
  Next

  Return Nil

// 11.03.19
Function inf_dnl_xmlfile( is_schet, stitle )

  Local arr_m, n, buf := save_maxrow(), lkod_h, lkod_k, rec, blk, t_arr[ BR_LEN ], arr, n_func

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    Do Case
    Case p_tip_lu == TIP_LU_PN
      arr := { 301, 302 } // профилактика 1 и 2 этап
    Case p_tip_lu == TIP_LU_PREDN
      arr := { 303, 304 } // пред.осмотры 1 и 2 этап
    Case p_tip_lu == TIP_LU_PERN
      arr := { 305 } // период.осмотры
    Endcase
    If f0_inf_dnl( arr_m, is_schet > 1, is_schet == 3, arr, .t. )
      Copy File ( cur_dir() + 'tmp' + sdbf() ) to ( cur_dir() + 'tmpDNL' + sdbf() ) // т.к. внутри тоже есть TMP-файл
      r_use( dir_server() + 'human',, 'HUMAN' )
      Use ( cur_dir() + 'tmpDNL' ) new
      Set Relation To FIELD->kod into HUMAN
      Index On Upper( human->fio ) to ( cur_dir() + 'tmpDNL' )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + 'human_',, 'HUMAN_' ), ;
        r_use( dir_server() + 'human',, 'HUMAN' ), ;
        dbSetRelation( 'HUMAN_', {|| RecNo() }, 'recno()' ), ;
        e_use( cur_dir() + 'tmpDNL', cur_dir() + 'tmpDNL', 'TMP' ), ;
        dbSetRelation( 'HUMAN', {|| kod }, 'kod' );
        }
      Eval( blk_open )
      Go Top
      t_arr[ BR_TOP ] := 2
      t_arr[ BR_BOTTOM ] := 23
      t_arr[ BR_LEFT ] := 0
      t_arr[ BR_RIGHT ] := 79
      stitle := 'XML-портал: ' + stitle + ' несовершеннолетних '
      t_arr[ BR_TITUL ] := stitle + arr_m[ 4 ]
      t_arr[ BR_TITUL_COLOR ] := 'B/BG'
      t_arr[ BR_COLOR ] := color0
      t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t. }
      blk := {|| iif( tmp->is == 1, { 1, 2 }, { 3, 4 } ) }
      t_arr[ BR_COLUMN ] := { ;
        { ' ', {|| iif( tmp->is == 1, '', ' ' ) }, blk }, ;
        { ' Ф.И.О.', {|| PadR( human->fio, 37 ) }, blk }, ;
        { 'Дата рожд.', {|| full_date( human->date_r ) }, blk }, ;
        { '№ ам.карты', {|| human->uch_doc }, blk }, ;
        { 'Сроки леч-я', {|| Left( date_8( human->n_data ), 5 ) + '-' + Left( date_8( human->k_data ), 5 ) }, blk }, ;
        { 'Этап', {|| iif( eq_any( human->ishod, 301, 303, 305 ), ' I  ', 'I-II' ) }, blk } }
      t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход для создания файла;  ^<+,-,Ins>^ - отметить/снять отметку с пациента' ) }
      t_arr[ BR_EDIT ] := {| nk, ob| f1_inf_n_xmlfile( nk, ob, 'edit' ) }
      edit_browse( t_arr )
      Select TMP
      Delete For is == 0
      Pack
      n := LastRec()
      Close databases
      rest_box( buf )
      If n == 0 .or. !f_esc_enter( 'составления XML-файла' )
        Return Nil
      Endif
      mywait()
      r_use( dir_server() + 'mo_rpdsh',, 'RPDSH' )
      Index On Str( FIELD->KOD_H, 7 ) to ( cur_dir() + 'tmprpdsh' )
      Use
      r_use( dir_server() + 'mo_raksh',, 'RAKSH' )
      Index On Str( FIELD->KOD_H, 7 ) to ( cur_dir() + 'tmpraksh' )
      Use
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + 'human_',, 'HUMAN_' ), ;
        r_use( dir_server() + 'human',, 'HUMAN' ), ;
        dbSetRelation( 'HUMAN_', {|| RecNo() }, 'recno()' ), ;
        e_use( cur_dir() + 'tmpDNL', cur_dir() + 'tmpDNL', 'TMP' ), ;
        dbSetRelation( 'HUMAN', {|| kod }, 'kod' );
        }
      mo_mzxml_n( 1 )
      n := 0
      Do While .t.
        ++n
        Eval( blk_open )
        If rec == NIL
          Go Top
        Else
          Goto ( rec )
          Skip
          If Eof()
            Exit
          Endif
        Endif
        rec := tmp->( RecNo() )
        @ MaxRow(), 0 Say PadR( Str( n / tmp->( LastRec() ) * 100, 6, 2 ) + '%' + ' ' + ;
          RTrim( human->fio ) + ' ' + date_8( human->n_data ) + '-' + ;
          date_8( human->k_data ), 80 ) Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        n_func := 'f2_inf_N_XMLfile'
        Do Case
        Case p_tip_lu == TIP_LU_PN
          oms_sluch_pn( lkod_h, lkod_k, n_func ) // профилактика 1 и 2 этап
        Case p_tip_lu == TIP_LU_PREDN
          oms_sluch_predn( lkod_h, lkod_k, n_func ) // пред.осмотры 1 и 2 этап
        Case p_tip_lu == TIP_LU_PERN
          oms_sluch_pern( lkod_h, lkod_k, n_func ) // период.осмотры
        Endcase
      Enddo
      Close databases
      rest_box( buf )
      mo_mzxml_n( 3, 'tmp', stitle )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 22.11.13
Function f1_inf_n_xmlfile( nKey, oBrow, regim )

  Local ret := -1, rec := tmp->( RecNo() )

  If regim == 'edit'
    Do Case
    Case nkey == K_INS
      tmp->is := iif( tmp->is == 1, 0, 1 )
      ret := 0
      Keyboard Chr( K_TAB )
    Case nkey == 43  // +
      tmp->( dbEval( {|| tmp->is := 1 } ) )
      Goto ( rec )
      ret := 0
    Case nkey == 45  // -
      tmp->( dbEval( {|| tmp->is := 0 } ) )
      Goto ( rec )
      ret := 0
    Endcase
  Endif

  Return ret

// 22.11.13 по листу учёта несовершеннолетнего создать часть XML-файла
Function f2_inf_n_xmlfile( Loc_kod, kod_kartotek, lvozrast )

  Local adbf, s, i, j, k, y, m, d, fl

  r_use( dir_server() + 'kartote_',, 'KART_' )
  Goto ( kod_kartotek )
  r_use( dir_server() + 'kartotek',, 'KART' )
  Goto ( kod_kartotek )
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  Goto ( Loc_kod )
  r_use( dir_server() + 'human',, 'HUMAN' )
  Goto ( Loc_kod )
  r_use( dir_server() + 'mo_pers',, 'P2' )
  Goto ( m1vrach )
  r_use( dir_server() + 'organiz',, 'ORG' )
  r_use( dir_server() + 'mo_rpdsh', cur_dir() + 'tmprpdsh', 'RPDSH' )
  r_use( dir_server() + 'mo_raksh', cur_dir() + 'tmpraksh', 'RAKSH' )
  mo_mzxml_n( 2,,, lvozrast )

  Return Nil

// 17.11.25 Запрос несовершеннолетних, подлежащих медосмотрам, методом многовариантного поиска
Function mnog_poisk_dnl()

  Local mm_tmp := {}, mm_sort
  Local buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    tmp_help := help_code, hGauge, name_file := cur_dir() + '_kartDNL.txt', ;
    sh := 80, HH := 77, i, a_diagnoz[ 10 ], ta, name_dbf := cur_dir() + '_kartDNL' + sdbf(), ;
    mm_da_net := { { 'нет', 1 }, { 'да ', 2 } }, ;
    mm_mest := { { 'Волгоград или область', 1 }, { 'иногородние', 2 } }, ;
    mm_disp := { { 'неважно', 0 }, { 'не проходили', 1 }, { 'прошли', 2 } }, ;
    mm_death := { ;
      { 'выводить всех', 0 }, ;
      { 'не выводить умерших', 1 }, ;
      { 'выводить только умерших', 2 } }, ;
    mm_prik := { ;
      { 'неважно', 0 }, ;
      { 'прикреплён к нашей МО', 1 }, ;
      { 'прикреплён к другим МО', 2 }, ;
      { 'прикрепление неизвестно', 3 } }, ;
    tmp_file := cur_dir() + 'tmp_mn_p' + sdbf(), ;
    k_fio, k_adr, tt_fio[ 10 ], tt_adr[ 10 ], fl_exit := .f.
  Local adbf := { ;
    { 'UCHAST',   'N',  2, 0 }, ; // номер участка
    { 'KOD_VU',   'N',  6, 0 }, ; // код в участке
    { 'FIO',   'C', 50, 0 }, ; // Ф.И.О. больного
    { 'PHONE',   'C', 40, 0 }, ; // телефон больного
    { 'POL',   'C',  1, 0 }, ; // пол
    { 'DATE_R', 'C', 10, 0 }, ; // дата рождения больного
    { 'LET',   'N',  2, 0 }, ; // сколько лет в этом году
    { 'ADRESR',  'C', 50, 0 }, ; // адрес больного
    { 'ADRESP',  'C', 50, 0 }, ; // адрес больного
    { 'POLIS',     'C', 17, 0 }, ; // полис
    { 'KOD_SMO',   'C',  5, 0 }, ; //
    { 'SMO',       'C', 80, 0 }, ; // реестровый номер СМО;;преобразовать из старых кодов в новые, иногродние = 34
    { 'SNILS',   'C', 14, 0 }, ;
    { 'MO_PR',     'C',  6, 0 }, ; // код МО приписки
    { 'MONAME_PR', 'C', 60, 0 }, ; // наименование МО приписки
    { 'DATE_PR', 'C', 10, 0 }, ; // дата приписки
    { 'LAST_L_U', 'C', 10, 0 };  // дата последнего листа учёта
  }
  If !myfiledeleted( name_dbf )
    Return Nil
  Endif
  Private mm_smo := {}, pyear, mstr_crb := 0, is_kategor2 := .f., is_talon := ret_is_talon()
  If is_talon
    is_kategor2 := !Empty( stm_kategor2 )
  Endif
//  For i := 1 To Len( glob_arr_smo )
//    If glob_arr_smo[ i, 3 ] == 1
//      AAdd( mm_smo, { glob_arr_smo[ i, 1 ], PadR( lstr( glob_arr_smo[ i, 2 ] ), 5 ) } )
//    Endif
//  Next
  For i := 1 To Len( smo_volgograd() )
    If smo_volgograd()[ i, 3 ] == 1
      AAdd( mm_smo, { smo_volgograd()[ i, 1 ], PadR( lstr( smo_volgograd()[ i, 2 ] ), 5 ) } )
    Endif
  Next
  ta := f2_mnog_poisk_dnl(,,, 1 )
  AAdd( mm_tmp, { 'god', 'N', 4, 0, '9999', ;
    nil, ;
    Year( sys_date ), nil, ;
    'В каком году не было медомотра/диспансеризации' } )
  AAdd( mm_tmp, { 'v_period', 'C', 100, 0, NIL, ;
    {| x| menu_reader( x, { {| k, r, c| f2_mnog_poisk_dnl( k, r, c ) } }, A__FUNCTION ) }, ;
    ta[ 1 ], {| x| ta[ 2 ] }, ;
    'Возрастные периоды медомотра/диспансеризации' } )
  AAdd( mm_tmp, { 'o_prik', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_prik, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_prik, x ) }, ;
    'Отношение к прикреплению' } )
  AAdd( mm_tmp, { 'o_death', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_death, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_death, x ) }, ;
    'Сведения о смерти по сведениям ТФОМС' } )
  Private arr_uchast := {}
  If is_uchastok > 0
    AAdd( mm_tmp, { 'bukva', 'C', 1, 0, '@!', ;
      nil, ;
      ' ', nil, ;
      'Буква (перед участком)' } )
    AAdd( mm_tmp, { 'uchast', 'N', 1, 0,, ;
      {| x| menu_reader( x, { {| k, r, c| get_uchast( r + 1, c ) } }, A__FUNCTION ) }, ;
      0, {|| init_uchast( arr_uchast ) }, ;
      'Участок (участки)' } )
    mm_sort := { ;
      { '№ участка + Лет + ФИО', 1 }, ;
      { '№ участка + Лет + Адрес', 2 }, ;
      { '№ участка + Адрес + Лет', 4 };
      }
    If is_uchastok == 1
      AAdd( mm_sort, { '№ участка + № в участке', 3 } )
    Elseif is_uchastok == 2
      AAdd( mm_sort, { '№ участка + Код по картотеке', 3 } )
    Elseif is_uchastok == 3
      AAdd( mm_sort, { '№ участка + номер АК МИС', 3 } )
    Endif
  Else
    mm_sort := { ;
      { 'Лет + ФИО', 1 }, ;
      { 'Лет + Адрес', 2 }, ;
      { 'Код по картотеке', 3 };
      }
    del_array( adbf, 1 ) // убираем участок
    del_array( adbf, 1 ) // убираем участок
  Endif
  AAdd( mm_tmp, { 'fio', 'C', 20, 0, '@!', ;
    nil, ;
    Space( 20 ), nil, ;
    'ФИО (начальные буквы или шаблон)' } )
  AAdd( mm_tmp, { 'mi_git', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mm_mest, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    'Место жительства:' } )
  AAdd( mm_tmp, { '_okato', 'C', 11, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| get_okato_ulica( k, r, c, { k, m_okato, } ) } }, A__FUNCTION ) }, ;
    Space( 11 ), {| x| Space( 11 ) }, ;
    'Адрес регистрации (ОКАТО)' } )
  AAdd( mm_tmp, { 'adres', 'C', 20, 0, '@!', ;
    nil, ;
    Space( 20 ), nil, ;
    'Улица (подстрока или шаблон)' } )
  If is_talon
    AAdd( mm_tmp, { 'kategor', 'N', 2, 0, NIL, ;
      {| x| menu_reader( x, mo_cut_menu( stm_kategor() ), A__MENUVERT ) }, ;
      0, {|| Space( 10 ) }, ;
      'Код категории льготы' } )
    If is_kategor2
      AAdd( mm_tmp, { 'kategor2', 'N', 4, 0, NIL, ;
        {| x| menu_reader( x, stm_kategor2, A__MENUVERT ) }, ;
        0, {|| Space( 10 ) }, ;
        'Категория МО' } )
    Endif
  Endif
  AAdd( mm_tmp, { 'pol', 'C', 1, 0, '!', ;
    nil, ;
    ' ', nil, ;
    'Пол', {|| mpol $ ' МЖ' } } )
  AAdd( mm_tmp, { 'god_r_min', 'D', 8, 0,, ;
    nil, ;
    CToD( '' ), nil, ;
    'Дата рождения (минимальная)' } )
  AAdd( mm_tmp, { 'god_r_max', 'D', 8, 0,, ;
    nil, ;
    CToD( '' ), nil, ;
    'Дата рождения (максимальная)' } )
  AAdd( mm_tmp, { 'smo', 'C', 5, 0, NIL, ;
    {| x| menu_reader( x, mm_smo, A__MENUVERT ) }, ;
    Space( 5 ), {|| Space( 10 ) }, ;
    'Страховая компания' } )
  AAdd( mm_tmp, { 'i_sort', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_sort, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_sort, x ) }, ;
    'Сортировка выходного документа' } )
  Delete File ( tmp_file )
  init_base( tmp_file,, mm_tmp, 0 )
  //
  k := f_edit_spr( A__APPEND, mm_tmp, 'множественному запросу', ;
    'e_use(cur_dir()+"tmp_mn_p")', 0, 1,,,,, 'write_mn_p_DNL' )
  If k > 0
    mywait()
    Use ( tmp_file ) New Alias MN
    If is_talon .and. mn->kategor == 0
      is_talon := ( is_kategor2 .and. mn->kategor2 > 0 )
    Endif
    Private mfio := '', madres := '', arr_vozr := list2arr( mn->v_period )
    If !Empty( mn->fio )
      mfio := AllTrim( mn->fio )
      If !( Right( mfio, 1 ) == '*' )
        mfio += '*'
      Endif
    Endif
    If !Empty( mn->adres )
      madres := AllTrim( mn->adres )
      If !( Left( madres, 1 ) == '*' )
        madres := '*' + madres
      Endif
      If !( Right( madres, 1 ) == '*' )
        madres += '*'
      Endif
    Endif
    Private c_view := 0, c_found := 0
    status_key( '^<Esc>^ - прервать поиск' )
    hGauge := gaugenew(,,, 'Поиск в картотеке', .t. )
    gaugedisplay( hGauge )
    //
    dbCreate( cur_dir() + 'tmp', { { 'kod', 'N', 7, 0 } },, .t., 'TMP' )
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human', dir_server() + 'humankk', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server() + 'kartote2',, 'KART2' )
    r_use( dir_server() + 'kartote_',, 'KART_' )
    r_use( dir_server() + 'kartotek',, 'KART' )
    Set Relation To RecNo() into KART_, RecNo() into KART2
    Go Top
    Do While !Eof()
      gaugeupdate( hGauge, RecNo() / LastRec() )
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      f1_mnog_poisk_dnl( @c_view, @c_found )
      Select KART
      Skip
    Enddo
    closegauge( hGauge )
    j := tmp->( LastRec() )
    Close databases
    If j == 0
      If !fl_exit
        func_error( 4, 'Нет сведений!' )
      Endif
    Else
      stat_msg( 'Составление текстового и DBF-файлов' )
      Use ( tmp_file ) New Alias MN
      arr_title := { ;
        '─────┬', ;
        ' №№  │', ;
        ' пп  │', ;
        '─────┴' }
      If is_uchastok > 0 .or. mn->i_sort == 3 // Код по картотеке
        arr_title[ 1 ] += '─────────┬'
        arr_title[ 2 ] += ' Участок │'
        arr_title[ 3 ] += '   код   │'
        arr_title[ 4 ] += '─────────┴'
      Endif
      arr_title[ 1 ] += '───────────────────────────────────────────┬──┬──────────┬───────────────────────────────────┬─────┬──────────'
      arr_title[ 2 ] += '             Ф.И.О. пациента               │Ле│   дата   │              Адрес                │при- │последний '
      arr_title[ 3 ] += '                (телефон)                  │т │ рождения │                                   │креп.│л/у по ОМС'
      arr_title[ 4 ] += '───────────────────────────────────────────┴──┴──────────┴───────────────────────────────────┴─────┴──────────'
      reg_print := f_reg_print( arr_title, @sh, 2 )
      dbCreate( name_dbf, adbf,, .t., 'DVN' )
      r_use( dir_server() + 'human', dir_server() + 'humankk', 'HUMAN' )
      r_use( dir_server() + 'kartote2',, 'KART2' )
      r_use( dir_server() + 'kartote_',, 'KART_' )
      r_use( dir_server() + 'kartotek',, 'KART' )
      Set Relation To RecNo() into KART_, To RecNo() into KART2
      Use ( cur_dir() + 'tmp' ) new
      Set Relation To FIELD->kod into KART
      If is_uchastok > 0
        If mn->i_sort == 1 // № участка + Год рождения + ФИО
          Index On Str( kart->uchast, 2 ) + Str( mn->god - Year( kart->date_r ), 4 ) + Upper( kart->fio ) to ( cur_dir() + 'tmp' )
        Elseif mn->i_sort == 2 // № участка + Год рождения + Адрес
          Index On Str( kart->uchast, 2 ) + Str( mn->god - Year( kart->date_r ), 4 ) + Upper( kart->adres ) to ( cur_dir() + 'tmp' )
        Elseif mn->i_sort == 4 // № участка + Адрес + Год рождения
          Index On Str( kart->uchast, 2 ) + Upper( kart->adres ) + Str( mn->god - Year( kart->date_r ), 4 ) to ( cur_dir() + 'tmp' )
        Elseif mn->i_sort == 3 // № участка + Код
          If is_uchastok == 1 // № участка + № в участке
            Index On Str( kart->uchast, 2 ) + Str( kart->kod_vu, 5 ) + Upper( kart->fio ) to ( cur_dir() + 'tmp' )
          Elseif is_uchastok == 2 // № участка + Код по картотеке
            Index On Str( kart->uchast, 2 ) + Str( kart->kod, 7 ) to ( cur_dir() + 'tmp' )
          Elseif is_uchastok == 3 // № участка + номер АК МИС
            Index On Str( kart->uchast, 2 ) + kart2->kod_AK + Upper( kart->fio ) to ( cur_dir() + 'tmp' )
          Endif
        Endif
      Else
        If mn->i_sort == 1 // Год рождения + ФИО
          Index On Str( mn->god - Year( kart->date_r ), 4 ) + Upper( kart->fio ) to ( cur_dir() + 'tmp' )
        Elseif mn->i_sort == 2 // Год рождения + Адрес
          Index On Str( mn->god - Year( kart->date_r ), 4 ) + Upper( kart->adres ) to ( cur_dir() + 'tmp' )
        Elseif mn->i_sort == 3 // Код по картотеке
          Index On Str( FIELD->kod, 7 ) to ( cur_dir() + 'tmp' )
        Endif
      Endif
      fp := FCreate( name_file )
      n_list := 1
      tek_stroke := 0
      add_string( '' )
      add_string( Center( Expand( 'РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА' ), sh ) )
      add_string( '' )
      add_string( ' == ПАРАМЕТРЫ ПОИСКА ==' )
      add_string( 'В каком году не было медосмотра/диспансеризации несовершеннолетних: ' + lstr( mn->god ) )
      If !Empty( mn->v_period )
        add_string( 'Возрастные периоды медосмотра/диспансеризации: ' + AllTrim( mn->v_period ) )
      Endif
      If mn->o_death == 1
        add_string( 'За исключением умерших (по сведению ТФОМС)' )
      Elseif mn->o_death == 2
        add_string( 'Список умерших (по сведению ТФОМС)' )
      Endif
      If !Empty( mn->o_prik )
        add_string( 'Отношение к прикреплению: ' + inieditspr( A__MENUVERT, mm_prik, mn->o_prik ) )
      Endif
      If is_uchastok > 0
        If !Empty( mn->bukva )
          add_string( 'Буква: ' + mn->bukva )
        Endif
        If !Empty( mn->uchast )
          add_string( 'Участок: ' + init_uchast( arr_uchast ) )
        Endif
      Endif
      If !Empty( mfio )
        add_string( 'ФИО: ' + mfio )
      Endif
      If mn->mi_git > 0
        add_string( 'Место жительства: ' + inieditspr( A__MENUVERT, mm_mest, mn->mi_git ) )
      Endif
      If !Empty( mn->_okato )
        add_string( 'Адрес регистрации (ОКАТО): ' + ret_okato_ulica( '', mn->_okato ) )
      Endif
      If !Empty( madres )
        add_string( 'Улица: ' + madres )
      Endif
      If is_talon .and. mn->kategor > 0
        add_string( 'Код категории льготы: ' + inieditspr( A__MENUVERT, stm_kategor(), mn->kategor ) )
      Endif
      If is_talon .and. is_kategor2 .and. mn->kategor2 > 0
        add_string( 'Категория МО: ' + inieditspr( A__MENUVERT, stm_kategor2, mn->kategor2 ) )
      Endif
      If !Empty( mn->pol )
        add_string( 'Пол: ' + mn->pol )
      Endif
      If !Empty( mn->god_r_min ) .or. !Empty( mn->god_r_max )
        If Empty( mn->god_r_min )
          add_string( 'Лица, родившиеся до ' + full_date( mn->god_r_max ) )
        Elseif Empty( mn->god_r_max )
          add_string( 'Лица, родившиеся после ' + full_date( mn->god_r_min ) )
        Else
          add_string( 'Лица, родившиеся с ' + full_date( mn->god_r_min ) + ' по ' + full_date( mn->god_r_max ) )
        Endif
      Endif
      If !Empty( mn->smo )
        add_string( 'СМО: ' + inieditspr( A__MENUVERT, mm_smo, mn->smo ) )
      Endif
      add_string( '' )
      add_string( 'Найдено пациентов: ' + lstr( tmp->( LastRec() ) ) + ' чел.' )
      AEval( arr_title, {| x| add_string( x ) } )
      ii := 0
      Select TMP
      Go Top
      Do While !Eof()
        ++ii
        @ 24, 1 Say Str( ii / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorSt2Msg
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        mdate := CToD( '' )
        Select HUMAN
        find ( Str( tmp->kod, 7 ) )
        Do While human->kod_k == tmp->kod .and. !Eof()
          If Empty( mdate )
            mdate := human->k_data
          Else
            mdate := Max( mdate, human->k_data )
          Endif
          Skip
        Enddo
        Select DVN
        Append Blank
        s1 := PadR( lstr( ii ), 6 )
        If is_uchastok > 0 .or. mn->i_sort == 3
          If is_uchastok > 0
            s := ''
            If !Empty( kart->uchast )
              dvn->UCHAST := kart->uchast
              s += lstr( kart->uchast )
            Endif
            If is_uchastok == 1 .and. !Empty( kart->kod_vu ) // № участка + № в участке
              s += '/' + lstr( kart->kod_vu )
              dvn->KOD_VU := kart->kod_vu
            Elseif is_uchastok == 2 // № участка + Код по картотеке
              s += '/' + lstr( kart->kod )
              dvn->KOD_VU := kart->kod
            Elseif is_uchastok == 3 .and. !Empty( kart2->kod_AK ) // № участка + номер АК МИС
              s += '/' + LTrim( kart2->kod_AK )
              dvn->KOD_VU := Val( kart2->kod_AK )
            Endif
          Else
            s := PadL( lstr( tmp->kod ), 9 )
          Endif
          s1 += PadR( s, 10 )
        Endif
        s := ''
        If !Empty( kart_->PHONE_H )
          s += 'д.' + AllTrim( kart_->PHONE_H ) + ' '
        Endif
        If !Empty( kart_->PHONE_M )
          s += 'м.' + AllTrim( kart_->PHONE_M ) + ' '
        Endif
        If !Empty( kart_->PHONE_W )
          s += 'р.' + AllTrim( kart_->PHONE_W )
        Endif
        dvn->FIO := kart->fio
        dvn->PHONE := s
        s := AllTrim( kart->fio ) + ' ' + s
        k_fio := perenos( tt_fio, s, 43 )
        s1 += PadR( tt_fio[ 1 ], 44 )
        s1 += Str( mn->god - Year( kart->date_r ), 2 ) + ' '
        s1 += full_date( kart->date_r ) + ' '
        dvn->POL := kart->pol
        dvn->DATE_R := full_date( kart->date_r )
        dvn->LET := mn->god - Year( kart->date_r )
        k_adr := perenos( tt_adr, kart->adres, 35 )
        s1 += PadR( tt_adr[ 1 ], 36 )
        dvn->ADRESR := kart->adres
        dvn->ADRESP := kart_->adresp
        dvn->POLIS := LTrim( kart_->NPOLIS )
        dvn->KOD_SMO := kart_->smo
        dvn->SMO := smo_to_screen( 1 )
//        dvn->SNILS := iif( Empty( kart->SNILS ), '', Transform( kart->SNILS, picture_pf ) )
        dvn->SNILS := iif( Empty( kart->SNILS ), '', Transform_SNILS( kart->SNILS ) )
        If !Empty( dvn->mo_pr := kart2->mo_pr )
          dvn->MONAME_PR := ret_mo( kart2->mo_pr )[ _MO_SHORT_NAME ]
          If !Empty( kart2->pc4 )
            dvn->DATE_PR := Left( kart2->pc4, 6 ) + '20' + SubStr( kart2->pc4, 7 )
          Else
            dvn->DATE_PR := full_date( kart2->DATE_PR )
          Endif
        Endif
        If Empty( kart2->MO_PR )
          s := ''
        Elseif kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ]
          s := 'наш'
        Else
          s := 'чужой'
        Endif
        s1 += PadR( s, 6 )
        s1 += full_date( mdate )
        dvn->last_l_u := full_date( mdate )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s1 )
        For i := 2 To Max( k_fio, k_adr )
          s1 := Space( 6 )
          If is_uchastok > 0 .or. mn->i_sort == 3
            s1 += Space( 10 )
          Endif
          s1 += PadR( tt_fio[ i ], 44 )
          s1 += Space( 14 )
          s1 += tt_adr[ i ]
          add_string( s1 )
        Next
        add_string( Replicate( '-', sh ) )
        Select TMP
        Skip
      Enddo
      If fl_exit
        add_string( '//* ' + Expand( 'ОПЕРАЦИЯ ПРЕРВАНА' ) )
      Else
        add_string( 'Итого количество пациентов: ' + lstr( tmp->( LastRec() ) ) + ' чел.' )
      Endif
      FClose( fp )
      Close databases
      RestScreen( buf )
      viewtext( name_file,,,, .t.,,, reg_print )
      n_message( { 'Создан файл для загрузки в Excel: ' + name_dbf },, cColorStMsg, cColorStMsg,,, cColorSt2Msg )
    Endif
  Endif
  Close databases
  RestScreen( buf ) ; SetColor( tmp_color )

  Return Nil

// 31.10.16
Function write_mn_p_dnl( k )

  Local fl := .t.

  If k == 1
    If Empty( mgod )
      fl := func_error( 4, 'Должно быть заполнено поле "Год проведения медосмотра/диспансеризации"' )
    Elseif Empty( mv_period )
      fl := func_error( 4, 'Должен быть введён хотя бы один возрастной период медосмотра/диспансеризации' )
    Endif
  Endif

  Return fl

// 21.11.19
Static Function f1_mnog_poisk_dnl( cv, cf )

  Local i, j, k, n, s, arr, fl, god_r, arr1, vozr

  ++cv
  vozr := mn->god - Year( kart->date_r )
  If ( fl := ( vozr < 18 ) )
    fl := ( AScan( arr_vozr, vozr ) > 0 )
  Endif
  If fl
    Select HUMAN
    find ( Str( kart->kod, 7 ) )
    Do While human->kod_k == kart->kod .and. !Eof()
      If Year( human->k_data ) == mn->god .and. eq_any( human->ishod, 101, 102, 301, 302, 303, 304, 305 )
        fl := .f. ; Exit
      Endif
      Skip
    Enddo
  Endif
  If fl .and. !Empty( mn->o_prik )
    If mn->o_prik == 1 // к нашей МО
      fl := ( kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] )
    Elseif mn->o_prik == 2 // к другим МО
      fl := !( kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] )
    Else // прикрепление неизвестно
      fl := Empty( kart2->MO_PR )
    Endif
  Endif
  If fl .and. mn->o_death > 0
    If mn->o_death == 1 // За исключением умерших (по сведению ТФОМС)
      fl := !( Left( kart2->PC2, 1 ) == '1' )
    Elseif mn->o_death == 2 // Список умерших (по сведению ТФОМС)
      fl := ( Left( kart2->PC2, 1 ) == '1' )
    Endif
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->bukva )
    fl := ( mn->bukva == kart->bukva )
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->uchast )
    fl := f_is_uchast( arr_uchast, kart->uchast )
  Endif
  If fl .and. !Empty( mfio )
    fl := Like( mfio, Upper( kart->fio ) )
  Endif
  If fl .and. !Empty( madres )
    fl := Like( madres, Upper( kart->adres ) )
  Endif
  If fl .and. is_talon .and. mn->kategor > 0
    fl := ( mn->kategor == kart_->kategor )
  Endif
  If fl .and. is_kategor2 .and. mn->kategor2 > 0
    fl := ( mn->kategor2 == kart_->kategor2 )
  Endif
  If fl .and. !Empty( mn->pol )
    fl := ( kart->pol == mn->pol )
  Endif
  If fl .and. !Empty( mn->god_r_min )
    fl := ( mn->god_r_min <= kart->date_r )
  Endif
  If fl .and. !Empty( mn->god_r_max )
    fl := ( human->date_r <= mn->god_r_max )
  Endif
  If fl .and. mn->mi_git > 0
    If mn->mi_git == 1
      fl := ( Left( kart_->okatog, 2 ) == '18' )
    Else
      fl := !( Left( kart_->okatog, 2 ) == '18' )
    Endif
  Endif
  If fl .and. !Empty( mn->_okato )
    s := mn->_okato
    For i := 1 To 3
      If Right( s, 3 ) == '000'
        s := Left( s, Len( s ) -3 )
      Else
        Exit
      Endif
    Next
    fl := ( Left( kart_->okatog, Len( s ) ) == s )
  Endif
  If fl .and. !Empty( mn->smo )
    fl := ( kart_->smo == mn->smo )
  Endif
  If fl
    Select TMP
    Append Blank
    tmp->kod := kart->kod
    If++cf % 5000 == 0
      tmp->( dbCommit() )
    Endif
  Endif
  @ 24, 1 Say lstr( cv ) Color cColorSt2Msg
  @ Row(), Col() Say '/' Color 'W/R'
  @ Row(), Col() Say lstr( cf ) Color cColorStMsg

  Return Nil

// 31.10.16 запрос в GET-е возрастных периодов медомотров несовершеннолетних
Function f2_mnog_poisk_dnl( k, r, c, par )

  Static sast, sarr
  Local buf := save_maxrow(), a, i, j, s, s1

  Default par To 2
  If sast == NIL
    sast := {} ; sarr := {}
    For j := 0 To 17
      AAdd( sast, .t. )
      s := lstr( j )
      If j == 1
        s += ' год'
      Elseif Between( j, 2, 4 )
        s += ' года'
      Else
        s += ' лет'
      Endif
      AAdd( sarr, { s, j } )
    Next
  Endif
  s := s1 := ''
  If par == 1
    sast := {}
    For i := 1 To Len( sarr )
      AAdd( sast, .t. )
      s += lstr( sarr[ i, 2 ] ) + iif( i < Len( sarr ), ',', '' )
    Next
    s1 := 'все'
  Elseif ( a := bit_popup( r, c, sarr, sast ) ) != NIL
    AFill( sast, .f. )
    For i := 1 To Len( a )
      If ( j := AScan( sarr, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
        sast[ j ] := .t.
        s += lstr( a[ i, 2 ] ) + iif( i < Len( a ), ',', '' )
      Endif
    Next
    If Len( a ) == Len( sast )
      s1 := 'все'
    Endif
  Endif
  If Empty( s )
    s := Space( 10 )
  Endif
  If Empty( s1 )
    s1 := s
  Endif

  Return { s, s1 }
