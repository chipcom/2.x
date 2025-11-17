// mo_ppi.prg - режимы информации для задачи 'Приёмный покой'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 29.03.23
Function pr_gurnal_pp()

  Static spar := 1, spar2 := 1
  Local par, par2, arr_m, i, j, k, s, ;
    buf := save_maxrow(), fl_exit := .f., sh, HH, reg_print, ;
    arr_title, name_file := cur_dir() + 'stgurnal.txt', atime

  If ( arr_m := year_month( T_ROW, T_COL - 5,,, 2, @atime ) ) == NIL
    Return Nil
  Endif
  If ( par2 := popup_prompt( T_ROW, T_COL - 5, spar2, ;
      { '~Полная форма', ;
      '~Сокращенная форма' } ) ) == 0
    Return Nil
  Endif
  spar2 := par2
  If ( par := popup_prompt( T_ROW, T_COL - 5, spar, ;
      { 'С сортировкой по ~дате поступления', ;
      'С сортировкой по ~Ф.И.О. больного', ;
      'Начальная ~буква + дата поступления' } ) ) == 0
    Return Nil
  Endif
  spar := par
  //
  mywait()
  If par2 == 1
    arr_title := { ;
      '─────┬─────┬──────────────────┬──────────┬──────────────────┬────────────────────┬───────────────┬───────────────┬───────────────╥──────────┬──────────┬───────────────────────╥─────', ;
      ' NN  │Дата,│ Фамилия, имя,    │   Дата   │ Паспорт и полис  │ Постоянное место   │Каким учрежде- │№ ист.болезни и│Диагноз напра- ║Выписан,  │Отметка о │Если не был госпитализ.║Приме', ;
      ' пп  │время│ отчество больного│ рождения │                  │ жительства,        │нием направлен,│отделение, куда│вившего учр-ия;║переведен │сообщении ├────────────┬──────────╢чание', ;
      '     │пост.│                  │ и возраст│                  │ место работы       │кем доствлен   │помещен больной│приемного отд-я║в др.стац.│родственн.│причина/меры│отказ в пр║     ', ;
      '─────┴─────┴──────────────────┴──────────┴──────────────────┴────────────────────┴───────────────┴───────────────┴───────────────╨──────────┴──────────┴────────────┴──────────╨─────';
      }
    sh := Len( arr_title[ 1 ] ) ; HH := 54 ; reg_print := 6
    Private yes_albom := .t.
    //
    Private a01[ 10 ], a02[ 10 ], a03[ 10 ], a04[ 10 ], a05[ 10 ], a06[ 10 ], a07[ 10 ], ;
      a08[ 10 ], a09[ 10 ], a10[ 10 ], a11[ 10 ]
    Private k01, k02, k03, k04, k05, k06, k07, k08, k09, k10, k11
    Private sh01 := 5, sh02 := 5, sh03 := 18, sh04 := 10, sh05 := 18, ;
      sh06 := 20, sh07 := 15, sh08 := 15, sh09 := 15
    Private arr_center := { 2, 4, 10 }
    AFill( a01, '' ) ; k01 := 1
    AFill( a02, '' ) ; k02 := 2
    AFill( a03, '' )
    AFill( a04, '' )
    AFill( a05, '' )
    AFill( a06, '' )
    AFill( a07, '' )
    AFill( a08, '' )
    AFill( a09, '' )
    kol := 9
  Else
    arr_title := { ;
      '─────┬───────────┬─────────┬──────────────────────────┬────────────────────┬──────────', ;
      ' NN  │Дата, время│№ истории│  Фамилия, имя, отчество  │    Наименование    │   Дата   ', ;
      ' пп  │поступления│  болезни│        больного          │      отделения     │  выписки ', ;
      '─────┴───────────┴─────────┴──────────────────────────┴────────────────────┴──────────';
      }
    sh := Len( arr_title[ 1 ] ) ; HH := 80 ; reg_print := 5
    //
    Private a04[ 10 ], a05[ 10 ], k04, k05
    Private sh01 := 5, sh02 := 11, sh03 := 9, sh04 := 26, sh05 := 20
    AFill( a04, '' )
    AFill( a05, '' )
    kol := 9
  Endif
  k := 0
  //
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + 'organiz',, 'ORG' )
  add_string( PadR( org->name, sh - 15 ) + PadL( 'форма №001/у', 15 ) )
  add_string( '' )
  add_string( Center( 'Журнал учета приема больных и отказов в госпитализации ', sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  AEval( arr_title, {| x| add_string( x ) } )
  r_use( dir_server() + 'mo_kpred', dir_server() + 'mo_kpred', 'KPR' )
  r_use( dir_server() + 'mo_kinos', dir_server() + 'mo_kinos', 'KIS' )
  r_use( dir_server() + 'kartote_',, 'KART_' )
  r_use( dir_server() + 'kartotek',, 'KART' )
  Set Relation To RecNo() into KART_
  r_use( dir_server() + 'mo_ppdia', dir_server() + 'mo_ppdia', 'HUS' )
  r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_d', 'HU' )
  Set Relation To kod_k into KART
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do Case
  Case par == 1
    Index On DToS( n_data ) + n_time + Upper( SubStr( kart->fio, 1, 20 ) ) to ( cur_dir() + 'tmp_hu' ) ;
      While n_data <= arr_m[ 6 ]
  Case par == 2
    Index On Upper( kart->fio ) + DToS( n_data ) + n_time to ( cur_dir() + 'tmp_hu' ) ;
      While n_data <= arr_m[ 6 ]
  Case par == 3
    Index On Upper( Left( kart->fio, 1 ) ) + DToS( n_data ) + n_time to ( cur_dir() + 'tmp_hu' ) ;
      While n_data <= arr_m[ 6 ]
  Endcase
  waitstatus( '<Esc> - прервать операцию' )
  Go Top
  Do While !Eof()
    If ( fl_exit := ( Inkey() == K_ESC ) )
      Exit
    Endif
    updatestatus()
    If par == 1
      @ 24, 1 Say full_date( hu->n_data ) + ' ' + hu->n_time Color 'G+/R'
    Else
      @ 24, 1 Say PadR( fam_i_o( kart->fio ), 25 ) Color 'G+/R'
    Endif
    If between_time( hu->n_data, hu->n_time, arr_m[ 5 ], atime[ 1 ], arr_m[ 6 ], atime[ 2 ] )
      ++k
      If par2 == 1
        // 1 - номер по порядку
        a01[ 1 ] := Str( k, 5 )
        // 2 - дата и время поступления
        a02[ 1 ] := Left( full_date( hu->N_DATA ), 5 )
        a02[ 2 ] := hu->N_TIME
        // 3 - ФИО больного
        k03 := perenos( a03, kart->fio, sh03 )
        // 4 - дата рождения и возраст
        s := full_date( kart->date_r ) + ' ' + count_ymd( kart->date_r, hu->N_DATA )
        k04 := perenos( a04, s, sh04 )
        // 5 - паспорт и полис
        s := get_name_vid_ud( kart_->vid_ud )
        s += ' ' + AllTrim( kart_->ser_ud )
        s += ' ' + AllTrim( kart_->nom_ud ) + '; '
        If !Empty( kart->polis )
          s += 'полис: ' + make_polis( kart_->spolis, kart_->npolis ) + ' '
        Endif
        s += AllTrim( f4_view_list_schet( hu->komu, cut_code_smo( kart_->smo ), hu->str_crb ) )
        k05 := perenos( a05, s, sh05 )
        // 6 - адрес
        s := RTrim( inieditspr( A__MENUVERT, mm_gorod_selo, kart_->gorod_selo ) ) + ', '
        s += iif( emptyall( kart_->okatog, kart->adres ), '', ;
          ret_okato_ulica( kart->adres, kart_->okatog ) )
        If !Empty( kart->mr_dol )
          s += '; ' + AllTrim( kart->mr_dol )
        Endif
        k06 := perenos( a06, s, sh06 )
        // 7 - кем направлен и кем доставлен
        s := ''
        If !Empty( hu->kem_napr )
          s += ret_mo( hu->kem_napr )[ _MO_SHORT_NAME ]
        Endif
        If glob_mo[ _MO_KOD_TFOMS ] == '711001' // РЖД
          s += iif( Empty( s ), '', ', ' ) + ;
            AllTrim( inieditspr( A__MENUVERT, mmpp_kem1dost, hu->KEM_DOST ) )
        Else
          s += iif( Empty( s ), '', ', ' ) + ;
            AllTrim( inieditspr( A__MENUVERT, mmpp_kem_dost, hu->KEM_DOST ) )
        Endif
        k07 := perenos( a07, s, sh07 )
        // 8 - отделение, в которое помещен больной
        s := '№ ' + AllTrim( hu->UCH_DOC ) + '; '
        s += inieditspr( 6, dir_server() + 'mo_otd', hu->otd )
        k08 := perenos( a08, s, sh08 )
        // 9 - диагноз направившего учреждения
        MDIAG_NAPR := MDIAG_PR_P := MPOB_D_LEK := ''
        Select HUS
        find ( Str( hu->kod, 7 ) )
        Do While hus->kod == hu->kod .and. !Eof()
          Do Case
          Case hus->tip == 1
            MDIAG_NAPR := AllTrim( hus->name ) // диагноз направившего учреждения
          Case hus->tip == 2
            MDIAG_PR_P := AllTrim( hus->name ) // диагноз приемного отделения
          Case hus->tip == 3
            MPOB_D_LEK := AllTrim( hus->name ) // побочное действие лекарств
          Endcase
          Skip
        Enddo
        s := iif( Empty( mDIAG_NAPR ), '-', mDIAG_NAPR ) + '; ' + ;
          iif( Empty( mDIAG_PR_P ), '-', mDIAG_PR_P )
        k09 := perenos( a09, s, sh09 )
        //
        kk := 1
        For i := 1 To kol
          pole := 'k' + StrZero( i, 2 )
          kk := Max( kk, &pole )
        Next
        kk := Min( kk, 10 )
        If verify_ff( HH - kk, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        For j := 1 To kk
          s := ''
          For i := 1 To kol
            pole := 'a' + StrZero( i, 2 )
            ss := &pole.[ j ]
            pole := 'sh' + StrZero( i, 2 )
            If AScan( arr_center, i ) > 0
              ss := PadC( AllTrim( ss ), &pole )
            Else
              ss := PadR( AllTrim( ss ), &pole )
            Endif
            s += ss + ' '
          Next
          If j == 1  // в первой строке
            s += PadR( full_date( hu->K_DATA ), 10 ) + ' ' // Выписан, переведен в др.стацион.
            If hu->novor > 0
              s += PadC( 'новорожден', 10 ) + ' '
            Else
              Select KPR
              find ( Str( hu->kod_k, 7 ) )
              s += PadC( iif( Found() .and. kpr->is_uhod == 1, 'по уходу', '' ), 10 ) + ' ' // сообщение родственникам
            Endif
            If hu->is_gospit == 1
              s1 := 'не госпитализирован'
              s += PadR( s1, 12 + 1 + 10 + 1 )
            Else
              s += Space( 12 ) + ' '   // причина/меры
              s += Space( 10 ) + ' '   // отказ в пр
            Endif
            s += SubStr( inieditspr( 6, dir_server() + 'mo_ppst', hu->stol ), 1, 5 ) // Примечание
          Elseif j == 2  // во второй строке
            If !Empty( hu->k_data )
              s += PadC( hu->N_TIME, 11 )
            Else
              s += Space( 11 )
            Endif
            s += Space( 11 )
            s1 := ''
            If hu->is_gospit == 1 .and. hu->pr_gospit > 0
              s1 := inieditspr( A__MENUVERT, mmpp_pr_gospit, hu->pr_gospit )
            Endif
            s += PadR( s1, 12 + 1 + 10 + 1 )
            If hu->ishod2 == 6  // умер
              s += 'УМЕР'
            Else
              s += SubStr( inieditspr( 6, dir_server() + 'mo_ppst', hu->stol ), 6, 5 ) // Примечание
            Endif
          Endif
          add_string( s )
        Next
        Select KIS
        find ( Str( hu->kod_k, 7 ) )
        If Found() // иностранец
          f_gur_inostr_pp( sh )
        Endif
      Else
        // 1 - номер по порядку
        s := Str( k, 5 ) + ' '
        // 2 - дата и время поступления
        s += Left( full_date( hu->N_DATA ), 5 ) + ' ' + hu->N_TIME + ' '
        // 3 - история болезни
        s += hu->UCH_DOC
        // 3 - ФИО больного
        k04 := perenos( a04, kart->fio, sh04 )
        s += PadR( a04[ 1 ], sh04 + 1 )
        // 5 - отделение, в которое помещен больной
        k05 := perenos( a05, inieditspr( 6, dir_server() + 'mo_otd', hu->otd ), sh05 )
        s += PadR( a05[ 1 ], sh05 + 1 )
        s += full_date( hu->K_DATA )
        kk := Min( Max( k04, k05 ), 10 )
        If verify_ff( HH - kk, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s )
        For j := 2 To kk
          s := Space( sh01 + 1 + sh02 + 1 + sh03 + 1 )
          s += PadR( a04[ j ], sh04 + 1 )
          s += PadR( a05[ j ], sh05 + 1 )
          add_string( s )
        Next
        Select KIS
        find ( Str( hu->kod_k, 7 ) )
        If Found() // иностранец
          f_gur_inostr_pp( sh )
        Endif
        If kk == 1
          add_string( '' )
        Endif
      Endif
    Endif
    Select HU
    Skip
  Enddo
  Close databases
  If fl_exit
    add_string( Expand( 'ПРОЦЕСС ПРЕРВАН' ) )
  Endif
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Return Nil

//
Function pr_svod_pp( k )

  Static si1 := 1, si2 := 1
  Local mas_pmt, mas_msg, mas_fun, j, uch_otd

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { '~Общий свод', ;
      'Отделения + ~направившие ЛПУ', ;
      'Отделения + ~столы', ;
      'Отделения + "~госпитализация"', ;
      'Свод по ~возрастам', ;
      'Свод по ~детям и подросткам', ;
      'Невыписанные ~больные' }
    mas_msg := { 'Общий свод по больным, зарегистрированным в стационаре', ;
      'Вывод сводной информации по отделениям и направившим учреждениям', ;
      'Вывод сводной информации по отделениям и столам', ;
      'Вывод сводной информации по отделениям с разбивкой по типу госпитализации', ;
      'Вывод сводной информации по отделениям с разбивкой по возрастам', ;
      'Разбивка по возрастам детей и подростков до 18 лет', ;
      'Вывод текущей информации по количеству больных в отделениях' }
    mas_fun := { 'pr_svod_pp(11)', ;
      'pr_svod_pp(12)', ;
      'pr_svod_pp(13)', ;
      'pr_svod_pp(14)', ;
      'pr_svod_pp(15)', ;
      'pr_svod_pp(16)', ;
      'pr_svod_pp(17)' }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    pr_ob_svod_pp()
  Case k == 12
    pr_otd_lpu_pp()
  Case k == 13
    pr_otd_stol_pp()
  Case k == 14
    pr_otd_gosp_pp()
  Case k == 15
    pr_otd_vozr_pp()
  Case k == 16
    pr_otd_vozr_deti_pp()
  Case k == 17
    pr_otd_tek_pp()
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

// 17.11.25
Function pr_ob_svod_pp()

  Static spar := 1
  Local arr_m, i, j, k, s, buf := save_maxrow(), ;
    sh := 60, HH := 58, reg_print := 2, name_file := cur_dir() + 'pp_otd.txt', ;
    arr_otd := {}, arr_uch := {}, arr_gs := { 0, 0, 0 }, ;
    arr_prin := {}, arr_raj := {}, arr_kat := {}, arr_pol := { 0, 0 }, ;
    arr_vz_reb := { 0, 0, 0 }, arr_stol := {}, atime, ra[ 5 ], ;
    mas_pmt := { 'Все больные', 'Стационарные больные', 'Дневной стационар' }

  If ( par := popup_prompt( T_ROW, T_COL - 5, spar, mas_pmt ) ) == NIL
    Return Nil
  Endif
  spar := par
  If ( arr_m := year_month( T_ROW, T_COL - 5,,, 2, @atime ) ) == NIL
    Return Nil
  Endif
  //
  mywait()
  //
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + 'organiz',, 'ORG' )
  add_string( RTrim( org->name ) )
  add_string( '' )
  add_string( Center( 'Количество зарегистрированных стационарных больных', sh ) )
  add_string( Center( '[ ' + mas_pmt[ par ] + ' ]', sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  r_use( dir_server() + 'mo_kpred', dir_server() + 'mo_kpred', 'KPR' )
  r_use( dir_server() + 'kartote_',, 'KART_' )
  r_use( dir_server() + 'kartotek',, 'KART' )
  Set Relation To RecNo() into KART_
  r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_d', 'HU' )
  Set Relation To kod_k into KART
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  kv := k1 := kds := k1ds := 0
  Do While n_data <= arr_m[ 6 ] .and. !Eof()
    fl := .t.
    If par == 2
      fl := ( hu->reg_lech == 1 )
    Elseif par == 3
      fl := ( hu->reg_lech > 1 )
    Endif
    If fl .and. between_time( hu->n_data, hu->n_time, arr_m[ 5 ], atime[ 1 ], arr_m[ 6 ], atime[ 2 ] )
      If hu->is_gospit == 0  // только те, кто госпитализированы
        mstr_crb := iif( hu->komu == 0, Int( Val( cut_code_smo( kart_->smo ) ) ), hu->str_crb )
        If ( i := AScan( arr_prin, {| x| x[ 1 ] == hu->komu .and. x[ 2 ] == mstr_crb } ) ) == 0
          AAdd( arr_prin, { hu->komu, mstr_crb, 0, '' } ) ; i := Len( arr_prin )
        Endif
        arr_prin[ i, 3 ] ++
        If kart->pol == 'М'
          arr_pol[ 1 ] ++
        Else
          arr_pol[ 2 ] ++
        Endif
        If hu->novor > 0
          cy := 1
        Else
          cy := count_years( kart->date_r, hu->n_data )
        Endif
        If cy < 14       // ребенок
          arr_vz_reb[ 2 ] ++
        Elseif cy < 18   // подросток
          arr_vz_reb[ 3 ] ++
        Else             // взрослый
          arr_vz_reb[ 1 ] ++
        Endif
        If Empty( getcountry( kart_->strana ) )
          j := 0 ; k := 18 ; s := 'Центральный'
          If !Empty( kart_->okatog )
            If !( Left( kart_->okatog, 2 ) == '18' )
              j := 2 ; k := 0 ; s := ''
            Elseif !Empty( okato_rajon( kart_->okatog, @ra ) )
              j := ra[ 2 ] ; k := ra[ 3 ] ; s := ra[ 1 ]
            Endif
          Endif
        Else // иностранец
          j := 3 ; k := 0 ; s := ''
        Endif
        If ( i := AScan( arr_raj, {| x| x[ 1 ] == j .and. x[ 2 ] == k } ) ) == 0
          AAdd( arr_raj, { j, k, 0, 0, s, {} } ) ; i := Len( arr_raj )
        Endif
        arr_raj[ i, 3 ] ++
        If ( j := AScan( arr_raj[ i, 6 ], {| x| x[ 1 ] == hu->otd } ) ) == 0
          AAdd( arr_raj[ i, 6 ], { hu->otd, inieditspr( 6, dir_server() + 'mo_otd', hu->otd ), 0 } )
          j := Len( arr_raj[ i, 6 ] )
        Endif
        ++arr_raj[i,6,j,3 ]
        //
        If ( i := AScan( arr_otd, {| x| x[ 1 ] == hu->otd } ) ) == 0
          AAdd( arr_otd, { hu->otd, inieditspr( 6, dir_server() + 'mo_otd', hu->otd ), 0, 0, 0, 0, 0 } )
          i := Len( arr_otd )
        Endif
        ++arr_otd[i,3 ]
        ++kv
        If hu->REG_LECH > 1
          ++arr_otd[i,6 ]
          ++kds
        Endif
        Select KPR
        find ( Str( hu->kod_k, 7 ) )
        If ( Found() .and. kpr->is_uhod == 1 ) .or. hu->novor > 0
          ++arr_otd[i,4 ]
          ++k1
          If hu->REG_LECH > 1
            ++arr_otd[i,7 ]
            ++k1ds
          Endif
        Endif
        //
        If hu->stol > 0
          If ( i := AScan( arr_stol, {| x| x[ 1 ] == hu->stol } ) ) == 0
            AAdd( arr_stol, { hu->stol, inieditspr( 6, dir_server() + 'mo_ppst', hu->stol ), 0 } )
            i := Len( arr_stol )
          Endif
          ++arr_stol[i,3 ]
        Endif
        //
        If ( i := AScan( arr_uch, {| x| x[ 1 ] == hu->kem_napr } ) ) == 0
          AAdd( arr_uch, { hu->kem_napr, ret_mo( hu->kem_napr )[ _MO_SHORT_NAME ], 0, 0 } )
          i := Len( arr_uch )
        Endif
        ++arr_uch[i,3 ]
        //
        If Between( kart_->gorod_selo, 1, 3 )
          ++arr_gs[kart_->gorod_selo ]
        Endif
      Else // не госпитализированные
        If ( i := AScan( arr_otd, {| x| x[ 1 ] == hu->otd } ) ) == 0
          AAdd( arr_otd, { hu->otd, inieditspr( 6, dir_server() + 'mo_otd', hu->otd ), 0, 0, 0, 0, 0 } )
          i := Len( arr_otd )
        Endif
        ++arr_otd[i,5 ]
        //
        If ( i := AScan( arr_uch, {| x| x[ 1 ] == hu->kem_napr } ) ) == 0
          AAdd( arr_uch, { hu->kem_napr, ret_mo( hu->kem_napr )[ _MO_SHORT_NAME ], 0, 0 } )
          i := Len( arr_uch )
        Endif
        ++arr_uch[i,4 ]
      Endif
    Endif
    Select HU
    Skip
  Enddo
  Close databases
  //
  ASort( arr_otd,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
  verify_ff( HH - 3, .t., sh )
  add_string( '' )
  add_string( '  По отделениям:' )
  For i := 1 To Len( arr_otd )
    verify_ff( HH, .t., sh )
    s := PadR( AllTrim( arr_otd[ i, 2 ] ), sh - 10, '.' ) + ;
      PadL( lstr( arr_otd[ i, 3 ] ), 10, '.' )
    If !Empty( arr_otd[ i, 4 ] )
      s += '+' + lstr( arr_otd[ i, 4 ] )
    Endif
    If arr_otd[ i, 5 ] > 0
      s += ' (+ ' + lstr( arr_otd[ i, 5 ] ) + ' не госпит.)'
    Endif
    add_string( s )
  Next
  add_string( Replicate( '─', sh ) )
  s := PadR( 'Итого:', sh - 10, '.' ) + PadL( lstr( kv ), 10, '.' )
  If !Empty( k1 )
    s += '+' + lstr( k1 )
  Endif
  add_string( s )
  If par == 1 .and. !Empty( kds )
    verify_ff( HH - 3, .t., sh )
    add_string( '' )
    add_string( '  В т.ч.дневной стационар:' )
    For i := 1 To Len( arr_otd )
      If !Empty( arr_otd[ i, 6 ] )
        verify_ff( HH, .t., sh )
        s := PadR( AllTrim( arr_otd[ i, 2 ] ), sh - 10, '.' ) + ;
          PadL( lstr( arr_otd[ i, 6 ] ), 10, '.' )
        If !Empty( arr_otd[ i, 7 ] )
          s += '+' + lstr( arr_otd[ i, 7 ] )
        Endif
        add_string( s )
      Endif
    Next
    add_string( Replicate( '─', sh ) )
    s := PadR( 'Итого:', sh - 10, '.' ) + PadL( lstr( kds ), 10, '.' )
    If !Empty( k1ds )
      s += '+' + lstr( k1ds )
    Endif
    add_string( s )
  Endif
  If !Empty( arr_stol )
    ASort( arr_stol,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
    verify_ff( HH - 3, .t., sh )
    add_string( '' )
    add_string( '  По столам:' )
    For i := 1 To Len( arr_stol )
      verify_ff( HH, .t., sh )
      add_string( PadR( AllTrim( arr_stol[ i, 2 ] ), sh - 10, '.' ) + ;
        PadL( lstr( arr_stol[ i, 3 ] ), 10, '.' ) )
    Next
  Endif
  If !Empty( arr_uch )
    ASort( arr_uch,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
    verify_ff( HH - 3, .t., sh )
    add_string( '' )
    add_string( '  По учреждениям, кем направлен больной:' )
    For i := 1 To Len( arr_uch )
      verify_ff( HH, .t., sh )
      s := PadR( AllTrim( CharRem( '"', arr_uch[ i, 2 ] ) ), sh - 10, '.' ) + ;
        PadL( lstr( arr_uch[ i, 3 ] ), 10, '.' )
      If arr_uch[ i, 4 ] > 0
        s += ' (+ ' + lstr( arr_uch[ i, 4 ] ) + ' не госпит.)'
      Endif
      add_string( s )
    Next
  Endif
  If !Empty( arr_prin )
    For i := 1 To Len( arr_prin )
      If arr_prin[ i, 1 ] == 0
//        arr_prin[ i, 4 ] := AllTrim( inieditspr( A__MENUVERT, glob_arr_smo, arr_prin[ i, 2 ] ) )
        arr_prin[ i, 4 ] := AllTrim( inieditspr( A__MENUVERT, smo_volgograd(), arr_prin[ i, 2 ] ) )
      Else
        arr_prin[ i, 4 ] := ''
        If arr_prin[ i, 1 ] == 1
          arr_prin[ i, 4 ] := 'пр.компания - '
        Elseif arr_prin[ i, 1 ] == 3
          arr_prin[ i, 4 ] := 'комитет/МО - '
        Endif
        arr_prin[ i, 4 ] += f4_view_list_schet( arr_prin[ i, 1 ], '', arr_prin[ i, 2 ] )
      Endif
    Next
    ASort( arr_prin,,, {| x, y| if( x[ 1 ] == y[ 1 ], ;
      Upper( x[ 4 ] ) < Upper( y[ 4 ] ), x[ 1 ] < y[ 1 ] ) } )
    verify_ff( HH - 3, .t., sh )
    add_string( '' )
    add_string( '  По принадлежности счета:' )
    For i := 1 To Len( arr_prin )
      verify_ff( HH, .t., sh )
      add_string( PadR( arr_prin[ i, 4 ], 50 ) + Str( arr_prin[ i, 3 ], 6 ) )
    Next
  Endif
  //
  If !Empty( arr_raj )
    For i := 1 To Len( arr_raj )
      If arr_raj[ i, 1 ] < 2
        //
      Elseif arr_raj[ i, 1 ] == 2
        arr_raj[ i, 5 ] := 'иногородние'
      Else
        arr_raj[ i, 5 ] := 'иностранцы'
      Endif
    Next
    Use
    ASort( arr_raj,,, {| x, y| if( x[ 1 ] == y[ 1 ], ;
      Upper( x[ 5 ] ) < Upper( y[ 5 ] ), x[ 1 ] < y[ 1 ] ) } )
    verify_ff( HH - 3, .t., sh )
    add_string( '' )
    add_string( PadR( '  По районам:', 25 ) + PadC( 'места жительства', 20 ) )
    For i := 1 To Len( arr_raj )
      verify_ff( HH, .t., sh )
      add_string( PadR( arr_raj[ i, 5 ], 25 ) + Str( arr_raj[ i, 3 ], 12 ) )
    Next
    verify_ff( HH - 4, .t., sh )
    add_string( '' )
    add_string( '  Район места жительства + отделения' )
    For i := 1 To Len( arr_raj )
      verify_ff( HH - 2, .t., sh )
      add_string( PadR( arr_raj[ i, 5 ], 25 ) + Str( arr_raj[ i, 3 ], 12 ) )
      For j := 1 To Len( arr_raj[ i, 6 ] )
        verify_ff( HH, .t., sh )
        add_string( Space( 10 ) + PadR( AllTrim( arr_raj[ i, 6, j, 2 ] ), sh - 20, '.' ) + ;
          PadL( lstr( arr_raj[ i, 6, j, 3 ] ), 10, '.' ) )
      Next
    Next
  Endif
  If kv > 0
    verify_ff( HH - 4, .t., sh )
    add_string( '' )
    add_string( '' )
    add_string( PadR( 'Город', sh - 10, '.' ) + PadL( lstr( arr_gs[ 1 ] ), 10, '.' ) )
    add_string( PadR( 'Село', sh - 10, '.' ) + PadL( lstr( arr_gs[ 2 ] ), 10, '.' ) )
    If arr_gs[ 3 ] > 0
      add_string( PadR( 'Раб.поселок', sh - 10, '.' ) + PadL( lstr( arr_gs[ 3 ] ), 10, '.' ) )
    Endif
    verify_ff( HH - 3, .t., sh )
    add_string( '' )
    add_string( PadR( 'Мужчин', sh - 10, '.' ) + PadL( lstr( arr_pol[ 1 ] ), 10, '.' ) )
    add_string( PadR( 'Женщин', sh - 10, '.' ) + PadL( lstr( arr_pol[ 2 ] ), 10, '.' ) )
    verify_ff( HH - 4, .t., sh )
    add_string( '' )
    add_string( PadR( 'Взрослый', sh - 10, '.' ) + PadL( lstr( arr_vz_reb[ 1 ] ), 10, '.' ) )
    add_string( PadR( 'Ребенок',  sh - 10, '.' ) + PadL( lstr( arr_vz_reb[ 2 ] ), 10, '.' ) )
    add_string( PadR( 'Подросток', sh - 10, '.' ) + PadL( lstr( arr_vz_reb[ 3 ] ), 10, '.' ) )
  Endif
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, .t.,,, reg_print )
  Return Nil

//
Function pr_otd_lpu_pp()

  Local arr_m, i, j, l, k, k1, s, buf := save_maxrow(), ;
    sh, HH := 58, reg_print, name_file := cur_dir() + 'pp_otd2.txt', ;
    arr_otd := {}, arr_uch := {}, arr_title, atime

  If ( arr_m := year_month( T_ROW, T_COL - 5,,, 2, @atime ) ) == NIL
    Return Nil
  Endif
  //
  mywait()
  r_use( dir_server() + 'mo_kpred', dir_server() + 'mo_kpred', 'KPR' )
  r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_d', 'HU' )
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  k := k1 := 0
  Do While n_data <= arr_m[ 6 ] .and. !Eof()
    If between_time( hu->n_data, hu->n_time, arr_m[ 5 ], atime[ 1 ], arr_m[ 6 ], atime[ 2 ] )
      If hu->is_gospit == 0  // только те, кто госпитализированы
        If ( i := AScan( arr_otd, {| x| x[ 1 ] == hu->otd } ) ) == 0
          AAdd( arr_otd, { hu->otd, inieditspr( 6, dir_server() + 'mo_otd', hu->otd ), 0, 0, {}, 0 } )
          i := Len( arr_otd )
        Endif
        If ( j := AScan( arr_otd[ i, 5 ], {| x| x[ 1 ] == hu->kem_napr } ) ) == 0
          AAdd( arr_otd[ i, 5 ], { hu->kem_napr, 0, 0, 0, 0 } ) ; j := Len( arr_otd[ i, 5 ] )
        Endif
        If ( l := AScan( arr_uch, {| x| x[ 1 ] == hu->kem_napr } ) ) == 0
          AAdd( arr_uch, { hu->kem_napr, CharRem( '"', ret_mo( hu->kem_napr )[ _MO_SHORT_NAME ] ), 0, 0 } )
          l := Len( arr_uch )
        Endif
        ++arr_otd[i,3 ]
        ++arr_otd[i,5,j,3 ]
        ++arr_uch[l,3 ]
        ++k
        Select KPR
        find ( Str( hu->kod_k, 7 ) )
        If ( Found() .and. kpr->is_uhod == 1 ) .or. hu->novor > 0
          ++arr_otd[i,4 ]
          ++arr_otd[i,5,j,4 ]
          ++arr_uch[l,4 ]
          ++k1
        Endif
      Else  // не госпитализированные
        If ( i := AScan( arr_otd, {| x| x[ 1 ] == hu->otd } ) ) == 0
          AAdd( arr_otd, { hu->otd, inieditspr( 6, dir_server() + 'mo_otd', hu->otd ), 0, 0, {}, 0 } )
          i := Len( arr_otd )
        Endif
        If ( j := AScan( arr_otd[ i, 5 ], {| x| x[ 1 ] == hu->kem_napr } ) ) == 0
          AAdd( arr_otd[ i, 5 ], { hu->kem_napr, 0, 0, 0, 0 } ) ; j := Len( arr_otd[ i, 5 ] )
        Endif
        If AScan( arr_uch, {| x| x[ 1 ] == hu->kem_napr } ) == 0
          AAdd( arr_uch, { hu->kem_napr, CharRem( '"', ret_mo( hu->kem_napr )[ _MO_SHORT_NAME ] ), 0, 0 } )
          l := Len( arr_uch )
        Endif
        ++arr_otd[i,6 ]
        ++arr_otd[i,5,j,5 ]
        ++arr_uch[l,4 ]
      Endif
    Endif
    Select HU
    Skip
  Enddo
  Close databases
  If k == 0
    rest_box( buf )
    Return func_error( 4, 'Нет информации за указанный период времени!' )
  Endif
  //
  ASort( arr_otd,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
  ASort( arr_uch,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
  arr_title := { ;
    '──────────────────────────────', ;
    '                              ', ;
    '                              ', ;
    '         Наименование         ', ;
    '          отделения           ', ;
    '                              ', ;
    '                              ', ;
    '──────────────────────────────' }
  For i := 1 To Len( arr_uch )
    s := PadR( arr_uch[ i, 2 ], 42 )
    arr_title[ 1 ] += '┬───────'
    arr_title[ 2 ] += '│' + SubStr( s, 1, 7 )
    arr_title[ 3 ] += '│' + SubStr( s, 8, 7 )
    arr_title[ 4 ] += '│' + SubStr( s, 15, 7 )
    arr_title[ 5 ] += '│' + SubStr( s, 22, 7 )
    arr_title[ 6 ] += '│' + SubStr( s, 29, 7 )
    arr_title[ 7 ] += '│' + SubStr( s, 36, 7 )
    arr_title[ 8 ] += '┴───────'
  Next
  arr_title[ 1 ] += '╥────────┬───'
  arr_title[ 2 ] += '║        │   '
  arr_title[ 3 ] += '║        │   '
  arr_title[ 4 ] += '║ Всего  │ % '
  arr_title[ 5 ] += '║        │   '
  arr_title[ 6 ] += '║        │   '
  arr_title[ 7 ] += '║        │   '
  arr_title[ 8 ] += '╨────────┴───'
  reg_print := f_reg_print( arr_title, @sh )
  //
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + 'organiz',, 'ORG' )
  add_string( AllTrim( org->name ) )
  org->( dbCloseArea() )
  add_string( '' )
  add_string( Center( 'Количество зарегистрированных стационарных больных', sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  For i := 1 To Len( arr_otd )
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    s := PadR( AllTrim( arr_otd[ i, 2 ] ), 30, '.' )
    For l := 1 To Len( arr_uch )
      If ( j := AScan( arr_otd[ i, 5 ], {| x| x[ 1 ] == arr_uch[ l, 1 ] } ) ) == 0
        s += Replicate( '.', 8 )
      Else
        s1 := AllTrim( put_val( arr_otd[ i, 5, j, 3 ], 8 ) )
        If !Empty( arr_otd[ i, 5, j, 4 ] )
          s1 += '+' + lstr( arr_otd[ i, 5, j, 4 ] )
        Endif
        s += PadL( s1, 8, '.' )
      Endif
    Next
    s1 := lstr( arr_otd[ i, 3 ] )
    If !Empty( arr_otd[ i, 4 ] )
      s1 += '+' + lstr( arr_otd[ i, 4 ] )
    Endif
    s += PadL( s1, 9, '.' )
    s += ' ' + umest_val( arr_otd[ i, 3 ] / k * 100, 3, 1 )
    add_string( s )
    If arr_otd[ i, 6 ] > 0
      s := PadR( '    (+ не госпитализированные)', 30 )
      For l := 1 To Len( arr_uch )
        If ( j := AScan( arr_otd[ i, 5 ], {| x| x[ 1 ] == arr_uch[ l, 1 ] } ) ) == 0
          s += Space( 8 )
        Elseif Empty( arr_otd[ i, 5, j, 5 ] )
          s += Space( 8 )
        Else
          s += Str( arr_otd[ i, 5, j, 5 ], 8 )
        Endif
      Next
      s += Str( arr_otd[ i, 6 ], 9 )
      add_string( s )
    Endif
  Next
  add_string( Replicate( '═', sh ) )
  s := PadC( 'Итого:', 30 )
  For j := 1 To Len( arr_uch )
    s1 := lstr( arr_uch[ j, 3 ] )
    If !Empty( arr_uch[ j, 4 ] )
      s1 += '+' + lstr( arr_uch[ j, 4 ] )
    Endif
    s += PadL( s1, 8 )
  Next
  s1 := lstr( k )
  If !Empty( k1 )
    s1 += '+' + lstr( k1 )
  Endif
  If Len( s1 ) < 9
    s += PadL( s1, 9 )
  Else
    s += ' ' + s1
  Endif
  add_string( s )
  add_string( Replicate( '─', sh ) )
  s := PadC( '(в %):', 30 )
  For j := 1 To Len( arr_uch )
    s += umest_val( arr_uch[ j, 3 ] / k * 100, 8, 1 )
  Next
  add_string( s )
  //
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, memPPsvod )
  Return Nil

// 24.01.17
Function pr_otd_stol_pp()

  Local arr_m, i, j, l, k, k1, arr, s, buf := save_maxrow(), ;
    sh, HH := 58, reg_print, name_file := cur_dir() + 'pp_otd3.txt', fl := .f., ;
    arr_otd := {}, arr_stol := {}, arr_title, atime, is_perevod := 1

  If ( arr_m := year_month( T_ROW, T_COL - 5,,, 2, @atime ) ) == NIL
    Return Nil
  Endif
  If ( is_perevod := ;
      f_alert( { 'Выберите, каким образом формировать сводный документ:' }, ;
      { ' Поступившие больные ', ;
      ' Плюс переведенные больные ' }, ;
      1, 'N+/BG', 'R/BG', 17,, col1menu ) ) == 0
    Return Nil
  Endif
  //
  mywait()
  r_use( dir_server() + 'mo_ppst',, 'ST' )
  r_use( dir_server() + 'mo_kpred', dir_server() + 'mo_kpred', 'KPR' )
  r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_d', 'HU' )
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  k := k1 := 0
  Do While n_data <= arr_m[ 6 ] .and. !Eof()
    If between_time( hu->n_data, hu->n_time, arr_m[ 5 ], atime[ 1 ], arr_m[ 6 ], atime[ 2 ] ) ;
        .and. hu->is_gospit == 0  // только те, кто госпитализированы
      If ( i := AScan( arr_otd, {| x| x[ 1 ] == hu->otd } ) ) == 0
        AAdd( arr_otd, { hu->otd, inieditspr( 6, dir_server() + 'mo_otd', hu->otd ), 0, 0, {}, 0, 0, 0, 0 } )
        i := Len( arr_otd )
      Endif
      If ( j := AScan( arr_otd[ i, 5 ], {| x| x[ 1 ] == hu->stol } ) ) == 0
        AAdd( arr_otd[ i, 5 ], { hu->stol, 0, 0, 0, 0, 0, 0, 0, 0 } )
        j := Len( arr_otd[ i, 5 ] )
      Endif
      st->( dbGoto( hu->stol ) )
      If ( l := AScan( arr_stol, {| x| x[ 1 ] == hu->stol } ) ) == 0
        AAdd( arr_stol, { hu->stol, st->name, 0, 0, st->tip } )
        l := Len( arr_stol )
      Endif
      ++arr_otd[i,5,j,3 ]
      ++arr_stol[l,3 ]
      If st->tip == 0
        ++arr_otd[i,3 ]
        ++k
      Endif
      fl := .t.
      Select KPR
      find ( Str( hu->kod_k, 7 ) )
      If ( Found() .and. kpr->is_uhod == 1 .and. kpr->is_food == 1 ) .or. hu->novor > 0
        ++arr_otd[i,5,j,4 ]
        ++arr_stol[l,4 ]
        If st->tip == 0
          ++arr_otd[i,4 ]
          ++k1
        Endif
      Endif
    Endif
    Select HU
    Skip
  Enddo
  If is_perevod == 2
    Select HU
    Set Index To
    dbCreate( cur_dir() + 'tmp', { { 'kod',  'N', 7, 0 }, ;
      { 'otd1', 'N', 3, 0 }, ;
      { 'stol1', 'N', 3, 0 }, ;
      { 'otd2', 'N', 3, 0 }, ;
      { 'stol2', 'N', 3, 0 }, ;
      { 'rec',  'N', 7, 0 } } )
    Use ( cur_dir() + 'tmp' ) new
    r_use( dir_server() + 'mo_ppper',, 'PER' )
    Index On Str( kod, 7 ) to ( cur_dir() + 'tmp_per' ) For Between( n_data, arr_m[ 5 ], arr_m[ 6 ] )
    Go Top
    Do While !Eof()
      If between_time( per->n_data, per->n_time, arr_m[ 5 ], atime[ 1 ], arr_m[ 6 ], atime[ 2 ] )
        Select TMP
        Append Blank
        tmp->kod   := per->kod
        tmp->otd2  := per->otd
        tmp->stol2 := per->stol
        tmp->rec   := per->( RecNo() )
        fl := .t.
      Endif
      Select PER
      Skip
    Enddo
    If tmp->( LastRec() ) > 0
      Select PER
      Set Index to ( dir_server() + 'mo_ppper' )
      Select TMP
      Go Top
      Do While !Eof()
        arr := {}
        Select PER
        find ( Str( tmp->kod, 7 ) )
        Do While per->kod == tmp->kod .and. !Eof()
          AAdd( arr, { per->n_data, per->n_time, per->( RecNo() ), per->otd, per->stol } )
          Skip
        Enddo
        ASort( arr,,, {| x, y| iif( x[ 1 ] == y[ 1 ], x[ 2 ] < y[ 2 ], x[ 1 ] < y[ 1 ] ) } )
        If ( j := AScan( arr, {| x| x[ 3 ] == tmp->rec } ) ) > 1  // если переводился до этого
          tmp->otd1 := arr[ j - 1, 4 ]
          tmp->stol1 := arr[ j - 1, 5 ]
        Else  // не было ни одного перевода до этого
          hu->( dbGoto( tmp->kod ) )
          tmp->otd1 := hu->otd
          tmp->stol1 := hu->stol
        Endif
        Select TMP
        Skip
      Enddo
      //
      Select TMP
      Go Top
      Do While !Eof()
        hu->( dbGoto( tmp->kod ) )
        // вычесть стол 1
        If ( i := AScan( arr_otd, {| x| x[ 1 ] == tmp->otd1 } ) ) == 0
          AAdd( arr_otd, { tmp->otd1, inieditspr( 6, dir_server() + 'mo_otd', tmp->otd1 ), 0, 0, {}, 0, 0, 0, 0 } )
          i := Len( arr_otd )
        Endif
        If ( j := AScan( arr_otd[ i, 5 ], {| x| x[ 1 ] == tmp->stol1 } ) ) == 0
          AAdd( arr_otd[ i, 5 ], { tmp->stol1, 0, 0, 0, 0, 0, 0, 0, 0 } )
          j := Len( arr_otd[ i, 5 ] )
        Endif
        st->( dbGoto( tmp->stol1 ) )
        If ( l := AScan( arr_stol, {| x| x[ 1 ] == tmp->stol1 } ) ) == 0
          AAdd( arr_stol, { tmp->stol1, st->name, 0, 0, st->tip } )
          l := Len( arr_stol )
        Endif
        --arr_otd[i,5,j,3 ]
        --arr_otd[i,5,j,6 ]
        --arr_stol[l,3 ]
        If st->tip == 0
          --arr_otd[i,3 ]
          --arr_otd[i,6 ]
        Endif
        Select KPR
        find ( Str( hu->kod_k, 7 ) )
        If ( Found() .and. kpr->is_uhod == 1 .and. kpr->is_food == 1 ) .or. hu->novor > 0
          --arr_otd[i,5,j,4 ]
          ++arr_otd[i,5,j,7 ]
          --arr_stol[l,4 ]
          If st->tip == 0
            --arr_otd[i,4 ]
            ++arr_otd[i,7 ]
          Endif
        Endif
        // добавить стол 2
        If ( i := AScan( arr_otd, {| x| x[ 1 ] == tmp->otd2 } ) ) == 0
          AAdd( arr_otd, { tmp->otd2, inieditspr( 6, dir_server() + 'mo_otd', tmp->otd2 ), 0, 0, {}, 0, 0, 0, 0 } )
          i := Len( arr_otd )
        Endif
        If ( j := AScan( arr_otd[ i, 5 ], {| x| x[ 1 ] == tmp->stol2 } ) ) == 0
          AAdd( arr_otd[ i, 5 ], { tmp->stol2, 0, 0, 0, 0, 0, 0, 0, 0 } ) ; j := Len( arr_otd[ i, 5 ] )
        Endif
        st->( dbGoto( tmp->stol2 ) )
        If ( l := AScan( arr_stol, {| x| x[ 1 ] == tmp->stol2 } ) ) == 0
          AAdd( arr_stol, { tmp->stol2, st->name, 0, 0, st->tip } )
          l := Len( arr_stol )
        Endif
        ++arr_otd[i,5,j,3 ]
        ++arr_otd[i,5,j,8 ]
        ++arr_stol[l,3 ]
        If st->tip == 0
          ++arr_otd[i,3 ]
          ++arr_otd[i,8 ]
        Endif
        Select KPR
        find ( Str( hu->kod_k, 7 ) )
        If ( Found() .and. kpr->is_uhod == 1 .and. kpr->is_food == 1 ) .or. hu->novor > 0
          ++arr_otd[i,5,j,4 ]
          ++arr_otd[i,5,j,9 ]
          ++arr_stol[l,4 ]
          If st->tip == 0
            ++arr_otd[i,4 ]
            ++arr_otd[i,9 ]
          Endif
        Endif
        Select TMP
        Skip
      Enddo
    Endif
  Endif
  Close databases
  If !fl
    rest_box( buf )
    Return func_error( 4, 'Нет информации за указанный период времени!' )
  Endif
  //
  ASort( arr_otd,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
  ASort( arr_stol,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
  arr_title := { ;
    '──────────────────────────────', ;
    '                              ', ;
    '         Наименование         ', ;
    '          отделения           ', ;
    '──────────────────────────────' }
  For i := 1 To Len( arr_stol )
    If arr_stol[ i, 5 ] == 0
      s := PadR( arr_stol[ i, 2 ], 24 )
      arr_title[ 1 ] += '┬───────'
      arr_title[ 2 ] += '│' + SubStr( s, 1, 7 )
      arr_title[ 3 ] += '│' + SubStr( s, 8, 7 )
      arr_title[ 4 ] += '│' + SubStr( s, 15, 7 )
      arr_title[ 5 ] += '┴───────'
    Endif
  Next
  arr_title[ 1 ] += '╥────────┬───'
  arr_title[ 2 ] += '║        │   '
  arr_title[ 3 ] += '║ Всего  │ % '
  arr_title[ 4 ] += '║        │   '
  arr_title[ 5 ] += '╨────────┴───'
  For i := 1 To Len( arr_stol )
    If arr_stol[ i, 5 ] == 1
      s := PadR( arr_stol[ i, 2 ], 24 )
      arr_title[ 1 ] += '╥───────'
      arr_title[ 2 ] += '║' + SubStr( s, 1, 7 )
      arr_title[ 3 ] += '║' + SubStr( s, 8, 7 )
      arr_title[ 4 ] += '║' + SubStr( s, 15, 7 )
      arr_title[ 5 ] += '╨───────'
    Endif
  Next
  reg_print := f_reg_print( arr_title, @sh )
  //
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + 'organiz',, 'ORG' )
  add_string( AllTrim( org->name ) )
  org->( dbCloseArea() )
  add_string( '' )
  add_string( Center( 'Количество зарегистрированных стационарных больных', sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  For i := 1 To Len( arr_otd )
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    s := PadR( AllTrim( arr_otd[ i, 2 ] ), 30, '.' )
    For l := 1 To Len( arr_stol )
      If arr_stol[ l, 5 ] == 0
        If ( j := AScan( arr_otd[ i, 5 ], {| x| x[ 1 ] == arr_stol[ l, 1 ] } ) ) == 0
          s += Replicate( '.', 8 )
        Else
          s1 := lstr( arr_otd[ i, 5, j, 3 ] )
          If !Empty( arr_otd[ i, 5, j, 4 ] )
            s1 += '+' + lstr( arr_otd[ i, 5, j, 4 ] )
          Endif
          s += PadL( s1, 8, '.' )
        Endif
      Endif
    Next
    s1 := lstr( arr_otd[ i, 3 ] )
    If !Empty( arr_otd[ i, 4 ] )
      s1 += '+' + lstr( arr_otd[ i, 4 ] )
    Endif
    s += PadL( s1, 9, '.' )
    s += ' ' + umest_val( arr_otd[ i, 3 ] / k * 100, 3, 1 )
    For l := 1 To Len( arr_stol )
      If arr_stol[ l, 5 ] == 1
        If ( j := AScan( arr_otd[ i, 5 ], {| x| x[ 1 ] == arr_stol[ l, 1 ] } ) ) == 0
          s += Replicate( '.', 8 )
        Else
          s1 := lstr( arr_otd[ i, 5, j, 3 ] )
          If !Empty( arr_otd[ i, 5, j, 4 ] )
            s1 += '+' + lstr( arr_otd[ i, 5, j, 4 ] )
          Endif
          s += PadL( s1, 8, '.' )
        Endif
      Endif
    Next
    add_string( s )
    If !emptyall( arr_otd[ i, 6 ], arr_otd[ i, 8 ] )
      s := PadL( '(в т.ч. переведенные)', 30 )
      For l := 1 To Len( arr_stol )
        If arr_stol[ l, 5 ] == 0
          If ( j := AScan( arr_otd[ i, 5 ], {| x| x[ 1 ] == arr_stol[ l, 1 ] } ) ) == 0
            s += Space( 8 )
          Else
            s1 := ''
            If !Empty( arr_otd[ i, 5, j, 6 ] )
              s1 += lstr( arr_otd[ i, 5, j, 6 ] )
              If !Empty( arr_otd[ i, 5, j, 7 ] )
                s1 += '*' + lstr( arr_otd[ i, 5, j, 7 ] )
              Endif
            Endif
            If !Empty( arr_otd[ i, 5, j, 8 ] )
              s1 += '+' + lstr( arr_otd[ i, 5, j, 8 ] )
              If !Empty( arr_otd[ i, 5, j, 9 ] )
                s1 += '*' + lstr( arr_otd[ i, 5, j, 9 ] )
              Endif
            Endif
            s += PadL( s1, 8 )
          Endif
        Endif
      Next
      s1 := ''
      If !Empty( arr_otd[ i, 6 ] )
        s1 += lstr( arr_otd[ i, 6 ] )
        If !Empty( arr_otd[ i, 7 ] )
          s1 += '*' + lstr( arr_otd[ i, 7 ] )
        Endif
      Endif
      If !Empty( arr_otd[ i, 8 ] )
        s1 += '+' + lstr( arr_otd[ i, 8 ] )
        If !Empty( arr_otd[ i, 9 ] )
          s1 += '*' + lstr( arr_otd[ i, 9 ] )
        Endif
      Endif
      s += PadL( s1, 9 ) + Space( 4 )
      For l := 1 To Len( arr_stol )
        If arr_stol[ l, 5 ] == 1
          If ( j := AScan( arr_otd[ i, 5 ], {| x| x[ 1 ] == arr_stol[ l, 1 ] } ) ) == 0
            s += Space( 8 )
          Else
            s1 := ''
            If !Empty( arr_otd[ i, 5, j, 6 ] )
              s1 += lstr( arr_otd[ i, 5, j, 6 ] )
              If !Empty( arr_otd[ i, 5, j, 7 ] )
                s1 += '*' + lstr( arr_otd[ i, 5, j, 7 ] )
              Endif
            Endif
            If !Empty( arr_otd[ i, 5, j, 8 ] )
              s1 += '+' + lstr( arr_otd[ i, 5, j, 8 ] )
              If !Empty( arr_otd[ i, 5, j, 9 ] )
                s1 += '*' + lstr( arr_otd[ i, 5, j, 9 ] )
              Endif
            Endif
            s += PadL( s1, 8 )
          Endif
        Endif
      Next
      add_string( s )
    Endif
  Next
  add_string( Replicate( '═', sh ) )
  s := PadC( 'Итого:', 30 )
  For j := 1 To Len( arr_stol )
    If arr_stol[ j, 5 ] == 0
      s1 := lstr( arr_stol[ j, 3 ] )
      If !Empty( arr_stol[ j, 4 ] )
        s1 += '+' + lstr( arr_stol[ j, 4 ] )
      Endif
      s += PadL( s1, 8 )
    Endif
  Next
  s1 := lstr( k )
  If !Empty( k1 )
    s1 += '+' + lstr( k1 )
  Endif
  If Len( s1 ) < 9
    s += PadL( s1, 9 )
  Else
    s += ' ' + s1
  Endif
  s += Space( 4 )
  For j := 1 To Len( arr_stol )
    If arr_stol[ j, 5 ] == 1
      s1 := lstr( arr_stol[ j, 3 ] )
      If !Empty( arr_stol[ j, 4 ] )
        s1 += '+' + lstr( arr_stol[ j, 4 ] )
      Endif
      s += PadL( s1, 8 )
    Endif
  Next
  add_string( s )
  add_string( Replicate( '─', sh ) )
  s := PadC( '(в %):', 30 )
  For j := 1 To Len( arr_stol )
    If arr_stol[ j, 5 ] == 0
      s += umest_val( arr_stol[ j, 3 ] / k * 100, 8, 1 )
    Endif
  Next
  add_string( s )
  //
  FClose( fp )
  rest_box( buf )
  If sh > 120
    Private yes_albom := .t.
  Endif
  viewtext( name_file,,,, ( sh > 80 ),,, memPPsvod )
  Return Nil

//
Function pr_otd_gosp_pp()

  Local arr_m, i, j, k, s, buf := save_maxrow(), ;
    sh, HH := 58, reg_print, name_file := cur_dir() + 'pp_otd4.txt', ;
    arr_otd := {}, arr_stol := {}, arr_title, atime, ak[ 12 ]

  If ( arr_m := year_month( T_ROW, T_COL - 5,,, 2, @atime ) ) == NIL
    Return Nil
  Endif
  //
  mywait()
  r_use( dir_server() + 'mo_kpred', dir_server() + 'mo_kpred', 'KPR' )
  r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_d', 'HU' )
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  AFill( ak, 0 )
  Do While n_data <= arr_m[ 6 ] .and. !Eof()
    If between_time( hu->n_data, hu->n_time, arr_m[ 5 ], atime[ 1 ], arr_m[ 6 ], atime[ 2 ] ) ;
        .and. hu->is_gospit == 0   // только те, кто госпитализированы
      If ( i := AScan( arr_otd, {| x| x[ 1 ] == hu->otd } ) ) == 0
        AAdd( arr_otd, { hu->otd, ;
          inieditspr( 6, dir_server() + 'mo_otd', hu->otd ), ;
          0, 0, ;
          0, 0, ;
          0, 0, ;
          0, 0, ;
          0, 0 } )
        i := Len( arr_otd )
      Endif
      ++arr_otd[i,3 ]
      ++ak[3 ]
      Select KPR
      find ( Str( hu->kod_k, 7 ) )
      If ( Found() .and. kpr->is_uhod == 1 ) .or. hu->novor > 0
        ++arr_otd[i,4 ]
        ++ak[4 ]
      Endif
      For j := 1 To 4
        fl := .f.
        Do Case
        Case j == 1 .and. hu->gospit0 == 0 // первично
          fl := .t.
        Case j == 2 .and. hu->gospit0 == 1 // повторно
          fl := .t.
        Case j == 3 .and. hu->gospit1 == 1 // экстренно
          fl := .t.
        Case j == 4 .and. hu->gospit1 == 0 // в плановом порядке
          fl := .t.
        Endcase
        If fl
          k := 4 + j * 2
          ++arr_otd[i,k - 1 ]
          ++ak[k - 1 ]
          If ( kpr->( Found() ) .and. kpr->is_uhod == 1 ) .or. hu->novor > 0
            ++arr_otd[i,k ]
            ++ak[k ]
          Endif
        Endif
      Next
    Endif
    Select HU
    Skip
  Enddo
  Close databases
  If ak[ 3 ] == 0
    rest_box( buf )
    Return func_error( 4, 'Нет информации за указанный период времени!' )
  Endif
  //
  ASort( arr_otd,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
  ASort( arr_stol,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
  arr_title := { ;
    '──────────────────────────────╥─────────╥────────────┬────────────┬────────────┬────────────', ;
    '         Наименование         ║Поступило║  первично  │  повторно  │ экстренно  │в планов.пор', ;
    '          отделения           ║в отделе-╟────────┬───┼────────┬───┼────────┬───┼────────┬───', ;
    '                              ║ние всего║ кол-во │ % │ кол-во │ % │ кол-во │ % │ кол-во │ % ', ;
    '──────────────────────────────╨─────────╨────────┴───┴────────┴───┴────────┴───┴────────┴───' }
  reg_print := f_reg_print( arr_title, @sh )
  //
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + 'organiz',, 'ORG' )
  add_string( AllTrim( org->name ) )
  org->( dbCloseArea() )
  add_string( '' )
  add_string( Center( 'Количество зарегистрированных стационарных больных', sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  For i := 1 To Len( arr_otd )
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    s := PadR( AllTrim( arr_otd[ i, 2 ] ), 30 )
    s1 := lstr( arr_otd[ i, 3 ] )
    If !Empty( arr_otd[ i, 4 ] )
      s1 += '+' + lstr( arr_otd[ i, 4 ] )
    Endif
    s += PadL( s1, 10 )
    For j := 1 To 4
      k := 4 + j * 2
      s1 := iif( Empty( arr_otd[ i, k - 1 ] ), '', lstr( arr_otd[ i, k - 1 ] ) )
      If !Empty( arr_otd[ i, k ] )
        s1 += '+' + lstr( arr_otd[ i, k ] )
      Endif
      s += PadL( s1, 9 ) + ' ' + umest_val( arr_otd[ i, k - 1 ] / arr_otd[ i, 3 ] * 100, 3, 1 )
    Next
    add_string( s )
  Next
  add_string( Replicate( '─', sh ) )
  s := PadC( 'Итого:', 30 )
  s1 := lstr( ak[ 3 ] )
  If !Empty( ak[ 4 ] )
    s1 += '+' + lstr( ak[ 4 ] )
  Endif
  s += PadL( s1, 10 )
  For j := 1 To 4
    k := 4 + j * 2
    s1 := iif( Empty( ak[ k - 1 ] ), '', lstr( ak[ k - 1 ] ) )
    If !Empty( ak[ k ] )
      s1 += '+' + lstr( ak[ k ] )
    Endif
    s += PadL( s1, 9 ) + ' ' + umest_val( ak[ k - 1 ] / ak[ 3 ] * 100, 3, 1 )
  Next
  add_string( s )
  //
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Return Nil

//
Function pr_otd_vozr_pp()

  Static spar := 1
  Local arr_m, i, j, s, buf := save_maxrow(), ;
    sh, HH := 58, reg_print, name_file := cur_dir() + 'pp_otd5.txt', ;
    arr_otd := {}, arr_title, atime, ak, vozrast, ;
    mas_pmt := { 'Все больные', 'Стационарные больные', 'Дневной стационар' }

  If ( par := popup_prompt( T_ROW, T_COL - 5, spar, mas_pmt ) ) == NIL
    Return Nil
  Endif
  spar := par
  If ( arr_m := year_month( T_ROW, T_COL - 5,,, 2, @atime ) ) == NIL
    Return Nil
  Endif
  //
  mywait()
  r_use( dir_server() + 'mo_kpred', dir_server() + 'mo_kpred', 'KPR' )
  r_use( dir_server() + 'mo_kinos', dir_server() + 'mo_kinos', 'KIS' )
  r_use( dir_server() + 'kartote_',, 'KART_' )
  r_use( dir_server() + 'kartotek',, 'KART' )
  Set Relation To RecNo() into KART_
  r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_d', 'HU' )
  Set Relation To kod_k into KART
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While n_data <= arr_m[ 6 ] .and. !Eof()
    fl := .t.
    If par == 2
      fl := ( hu->reg_lech == 1 )
    Elseif par == 3
      fl := ( hu->reg_lech > 1 )
    Endif
    If fl .and. between_time( hu->n_data, hu->n_time, arr_m[ 5 ], atime[ 1 ], arr_m[ 6 ], atime[ 2 ] ) ;
        .and. hu->is_gospit == 0   // только те, кто госпитализированы
      If ( i := AScan( arr_otd, {| x| x[ 1 ] == hu->otd } ) ) == 0
        AAdd( arr_otd, { hu->otd, ;    // 1
        inieditspr( 6, dir_server() + 'mo_otd', hu->otd ), ;  // 2
        0, ;  // 3    до 1 года
        0, ;  // 4    до 3 лет
        0, ;  // 5    > 3 лет
        0, ;  // 6    до 18 лет
        0, ;  // 7    с 18 до 60 лет
        0, ;  // 8    свыше 60 лет
        0, ;  // 9    всего
        0, ;  // 10  село
        0, ;  // 11  рабочий поселок
        0, ;  // 12  города обл.подчинения
        0, ;  // 13  Волгоград
        0, ;  // 14  Волжский
        0 } ) // 15  иногородние
        i := Len( arr_otd )
      Endif
      If Left( kart_->okatog, 5 ) == '18401' // Волгоград
        ++arr_otd[i,13 ]
      Elseif Left( kart_->okatog, 2 ) == '18'
        If Left( kart_->okatog, 5 ) == '18410' // г.Волжский
          ++arr_otd[i,14 ]
        Elseif eq_any( Left( kart_->okatog, 5 ), '18415', '18420', '18425', '18428' ) // города обл.подч.
          ++arr_otd[i,12 ]
        Else  // село
          If kart_->GOROD_SELO == 3 // рабочий поселок
            ++arr_otd[i,11 ]
          Else
            ++arr_otd[i,10 ]
          Endif
        Endif
      Else // иногородние
        ++arr_otd[i,15 ]
      Endif
      ++arr_otd[i,9 ]
      If hu->novor > 0
        count_ymd( hu->DATE_R2, hu->N_DATA, @vozrast )
      Else
        count_ymd( kart->date_r, hu->N_DATA, @vozrast )
      Endif
      If vozrast < 18
        ++arr_otd[i,6 ]
      Elseif vozrast < 60
        ++arr_otd[i,7 ]
      Else
        ++arr_otd[i,8 ]
      Endif
      If hu->novor > 0
        ++arr_otd[i,3 ]
      Else
        Select KPR
        find ( Str( hu->kod_k, 7 ) )
        If Found() .and. kpr->is_uhod == 1
          If vozrast < 1
            ++arr_otd[i,3 ]
          Elseif vozrast < 3
            ++arr_otd[i,4 ]
          Else
            ++arr_otd[i,5 ]
          Endif
        Endif
      Endif
    Endif
    Select HU
    Skip
  Enddo
  Close databases
  If Len( arr_otd ) == 0
    rest_box( buf )
    Return func_error( 4, 'Нет информации за указанный период времени!' )
  Endif
  ak := Array( 15 )
  AFill( ak, 0 )
  For i := 1 To Len( arr_otd )
    For j := 3 To 15
      ak[ j ] += arr_otd[ i, j ]
    Next
  Next
  //
  ASort( arr_otd,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
  arr_title := { ;
    '───────────────────────────────╥─────────────────╥─────┬─────┬─────╥──────╥──────────────────────────────────', ;
    '         Наименование          ║ По уходу за реб.║ до  │от 18│свыше║      ║         Из них жители            ', ;
    '          отделения            ╟─────┬─────┬─────╢ 18  │до 60│ 60  ║ Всего╟────┬────┬───────┬─────┬────┬─────', ;
    '                               ║до 1г│1-3г.│>3лет║ лет │ лет │ лет ║      ║села│раб.│города │Волго│Волж│Иного', ;
    '                               ║     │     │     ║     │     │     ║      ║    │пос.│обл.под│град │cкий│родн. ', ;
    '───────────────────────────────╨─────┴─────┴─────╨─────┴─────┴─────╨──────╨────┴────┴───────┴─────┴────┴─────' }
  reg_print := f_reg_print( arr_title, @sh )
  //
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + 'organiz',, 'ORG' )
  add_string( AllTrim( org->name ) )
  org->( dbCloseArea() )
  add_string( '' )
  add_string( Center( 'Количество зарегистрированных стационарных больных', sh ) )
  If par > 1
    add_string( Center( '[ ' + mas_pmt[ par ] + ' ]', sh ) )
  Endif
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  For i := 1 To Len( arr_otd )
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    s := PadR( AllTrim( arr_otd[ i, 2 ] ), 30 )
    s += put_val( arr_otd[ i, 3 ], 6 )
    s += put_val( arr_otd[ i, 4 ], 6 )
    s += put_val( arr_otd[ i, 5 ], 6 )
    s += put_val( arr_otd[ i, 6 ], 6 )
    s += put_val( arr_otd[ i, 7 ], 6 )
    s += put_val( arr_otd[ i, 8 ], 6 )
    s += put_val( arr_otd[ i, 9 ], 7 )
    s += put_val( arr_otd[ i, 10 ], 6 )
    s += put_val( arr_otd[ i, 11 ], 5 )
    s += put_val( arr_otd[ i, 12 ], 6 )
    s += put_val( arr_otd[ i, 13 ], 8 )
    s += put_val( arr_otd[ i, 14 ], 5 )
    s += put_val( arr_otd[ i, 15 ], 6 )
    add_string( s )
  Next
  add_string( Replicate( '─', sh ) )
  s := PadC( 'Итого:', 30 )
  s += put_val( ak[ 3 ], 6 )
  s += put_val( ak[ 4 ], 6 )
  s += put_val( ak[ 5 ], 6 )
  s += put_val( ak[ 6 ], 6 )
  s += put_val( ak[ 7 ], 6 )
  s += put_val( ak[ 8 ], 6 )
  s += put_val( ak[ 9 ], 7 )
  s += put_val( ak[ 10 ], 6 )
  s += put_val( ak[ 11 ], 5 )
  s += put_val( ak[ 12 ], 6 )
  s += put_val( ak[ 13 ], 8 )
  s += put_val( ak[ 14 ], 5 )
  s += put_val( ak[ 15 ], 6 )
  add_string( s )
  //
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Return Nil

//
Function pr_otd_vozr_deti_pp()

  Static spar := 1
  Local arr_m, i, j, s, buf := save_maxrow(), ;
    s1, sh, HH := 58, reg_print, name_file := cur_dir() + 'pp_otd6.txt', ;
    arr_otd := {}, arr_title, atime, ak, vozrast, mmonth, ;
    mas_pmt := { 'Все больные', 'Стационарные больные', 'Дневной стационар' }

  If ( par := popup_prompt( T_ROW, T_COL - 5, spar, mas_pmt ) ) == NIL
    Return Nil
  Endif
  spar := par
  If ( arr_m := year_month( T_ROW, T_COL - 5,,, 2, @atime ) ) == NIL
    Return Nil
  Endif
  //
  mywait()
  r_use( dir_server() + 'kartote_',, 'KART_' )
  r_use( dir_server() + 'kartotek',, 'KART' )
  Set Relation To RecNo() into KART_
  r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_d', 'HU' )
  Set Relation To kod_k into KART
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While n_data <= arr_m[ 6 ] .and. !Eof()
    fl := .t.
    If par == 2
      fl := ( hu->reg_lech == 1 )
    Elseif par == 3
      fl := ( hu->reg_lech > 1 )
    Endif
    If hu->novor > 0
      count_ymd( hu->DATE_R2, hu->N_DATA, @vozrast, @mmonth )
    Else
      count_ymd( kart->date_r, hu->N_DATA, @vozrast, @mmonth )
    Endif
    fl := ( fl .and. vozrast < 18 )
    If fl .and. between_time( hu->n_data, hu->n_time, arr_m[ 5 ], atime[ 1 ], arr_m[ 6 ], atime[ 2 ] ) ;
        .and. hu->is_gospit == 0   // только те, кто госпитализированы
      If ( i := AScan( arr_otd, {| x| x[ 1 ] == hu->otd } ) ) == 0
        AAdd( arr_otd, { hu->otd, ;    // 1
        inieditspr( 6, dir_server() + 'mo_otd', hu->otd ), ;  // 2
        0, ;  // 3    в т.ч. до 6 месяцев
        0, ;  // 4    до 1 года
        0, ;  // 5    1-3 года
        0, ;  // 6    4-6 лет
        0, ;  // 7    7-10 лет
        0, ;  // 8    11-14 лет
        0, ;  // 9    15-17 лет
        0;   // 10    всего
        } )
        i := Len( arr_otd )
      Endif
      ++arr_otd[i,10 ]
      If vozrast < 1
        ++arr_otd[i,4 ]
        If mmonth < 6
          ++arr_otd[i,3 ]
        Endif
      Elseif vozrast <= 3
        ++arr_otd[i,5 ]
      Elseif vozrast <= 6
        ++arr_otd[i,6 ]
      Elseif vozrast <= 10
        ++arr_otd[i,7 ]
      Elseif vozrast <= 14
        ++arr_otd[i,8 ]
      Else
        ++arr_otd[i,9 ]
      Endif
    Endif
    Select HU
    Skip
  Enddo
  Close databases
  If Len( arr_otd ) == 0
    rest_box( buf )
    Return func_error( 4, 'Нет информации за указанный период времени!' )
  Endif
  ak := Array( 10 )
  AFill( ak, 0 )
  For i := 1 To Len( arr_otd )
    For j := 3 To 10
      ak[ j ] += arr_otd[ i, j ]
    Next
  Next
  //
  ASort( arr_otd,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
  arr_title := { ;
    '───────────────────────────────╥───────────╥─────┬─────┬─────┬─────┬─────╥──────', ;
    '         Наименование          ║ до 1 года ║ 1-3 │ 4-6 │ 7-10│11-14│15-17║      ', ;
    '          отделения            ╟─────┬─────╢ года│ лет │ лет │ лет │ лет ║ Всего', ;
    '                               ║до 6м│всего║     │     │     │     │     ║      ', ;
    '───────────────────────────────╨─────┴─────╨─────┴─────┴─────┴─────┴─────╨──────' }
  reg_print := f_reg_print( arr_title, @sh )
  //
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + 'organiz',, 'ORG' )
  add_string( AllTrim( org->name ) )
  org->( dbCloseArea() )
  add_string( '' )
  add_string( Center( 'Количество зарегистрированных стационарных больных', sh ) )
  If par > 1
    add_string( Center( '[ ' + mas_pmt[ par ] + ' ]', sh ) )
  Endif
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  For i := 1 To Len( arr_otd )
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    s := PadR( AllTrim( arr_otd[ i, 2 ] ), 30 )
    s += put_val( arr_otd[ i, 3 ], 6 )
    s += put_val( arr_otd[ i, 4 ], 6 )
    s += put_val( arr_otd[ i, 5 ], 6 )
    s += put_val( arr_otd[ i, 6 ], 6 )
    s += put_val( arr_otd[ i, 7 ], 6 )
    s += put_val( arr_otd[ i, 8 ], 6 )
    s += put_val( arr_otd[ i, 9 ], 6 )
    s += put_val( arr_otd[ i, 10 ], 7 )
    add_string( s )
  Next
  add_string( Replicate( '─', sh ) )
  s := PadC( 'Итого:', 30 )
  s += put_val( ak[ 3 ], 6 )
  s += put_val( ak[ 4 ], 6 )
  s += put_val( ak[ 5 ], 6 )
  s += put_val( ak[ 6 ], 6 )
  s += put_val( ak[ 7 ], 6 )
  s += put_val( ak[ 8 ], 6 )
  s += put_val( ak[ 9 ], 6 )
  s += put_val( ak[ 10 ], 7 )
  add_string( s )
  If ak[ 10 ] > 0
    s := Space( 37 )
    For j := 4 To 9
      If ak[ j ] == 0
        s += Space( 6 )
      Else
        s1 := lstr( ak[ j ] / ak[ 10 ] * 100, 6, 2 )
        Do While Right( s1, 1 ) == '0'
          s1 := Left( s1, Len( s1 ) -1 )
        Enddo
        Do While Len( s1 ) > 4
          s1 := Left( s1, Len( s1 ) -1 )
        Enddo
        If Right( s1, 1 ) == '.'
          s1 := Left( s1, Len( s1 ) -1 )
        Endif
        s += PadL( s1, 5 ) + '%'
      Endif
    Next
    s += Str( 100, 6 ) + '%'
    add_string( s )
  Endif
  //
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Return Nil

// 10.09.17
Function pr_otd_tek_pp()

  Static sdate, stime
  Local arr_m, i, j, l, k, k1, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    sh, HH := 58, reg_print, name_file := cur_dir() + 'pp_otd7.txt', ;
    arr_otd := {}, arr_title, tm, hGauge, fl_exit := .f.

  Default sdate To sys_date, stime To '12:00'
  Private mdate := sdate, mtime := stime
  SetColor( cDataCGet )
  buf := box_shadow( 18, 10, 20, 69 )
  fl := .f.
  @ 19, 16 Say 'Вывод информации по состоянию на' Get mdate
  @ Row(), Col() Say '/'
  @ Row(), Col() Get mtime Pict '99:99'
  myread( { 'confirm' } )
  If LastKey() != K_ESC
    sdate := mdate
    stime := mtime
    fl := .t.
  Endif
  SetColor( color0 )
  rest_box( buf )
  If !fl
    Return Nil
  Endif
  dbCreate( cur_dir() + 'tmp1', { { 'otd', 'N', 3, 0 }, ;
    { 'n_data', 'D', 8, 0 }, ;
    { 'n_time', 'C', 5, 0 } } )
  dbCreate( cur_dir() + 'tmp', { { 'kod', 'N', 7, 0 }, ;
    { 'fio', 'C', 50, 0 }, ;
    { 'n_data', 'D', 8, 0 }, ;
    { 'k_data', 'D', 8, 0 }, ;
    { 'n_time', 'C', 5, 0 }, ;
    { 'is_per', 'L', 1, 0 }, ;
    { 'otd', 'N', 3, 0 }, ;
    { 'reg_lech', 'N', 1, 0 } } )
  hGauge := gaugenew(,,, '<Esc> - выход из режима', .t. )
  gaugedisplay( hGauge )
  Use ( cur_dir() + 'tmp' ) new
  Index On Str( otd, 3 ) + DToS( n_data ) + n_time to ( cur_dir() + 'tmp' )
  Use ( cur_dir() + 'tmp1' ) new
  Index On DToS( n_data ) + n_time to ( cur_dir() + 'tmp1' )
  r_use( dir_server() + 'mo_ppper', dir_server() + 'mo_ppper', 'HUP' )
  r_use( dir_server() + 'kartote_',, 'KART_' )
  r_use( dir_server() + 'kartotek',, 'KART' )
  Set Relation To RecNo() into KART_
  r_use( dir_server() + 'mo_pp',, 'HU' )
  Set Relation To kod_k into KART
  Go Top
  Do While !Eof()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    gaugeupdate( hGauge, RecNo() / LastRec() )
    If hu->is_gospit == 0   // только те, кто госпитализированы
      mk_data := mdate + 1 ; mk_time := mtime
      If !Empty( hu->k_data )
        mk_data := hu->k_data ; mk_time := hu->k_time
      Endif
      If between_time( mdate, mtime, hu->n_data, hu->n_time, mk_data, mk_time )
        motd := hu->otd
        Select TMP
        Append Blank
        tmp->kod := hu->kod
        tmp->fio := kart->fio
        tmp->n_data := hu->n_data
        tmp->k_data := hu->k_data
        tmp->n_time := hu->n_time
        tmp->reg_lech := hu->reg_lech
        Select HUP
        find ( Str( hu->kod, 7 ) )
        If Found()
          Select TMP1
          Zap
          Select HUP
          Do While hup->kod == hu->kod .and. !Eof()
            Select TMP1
            Append Blank
            tmp1->otd    := hup->otd
            tmp1->n_data := hup->n_data
            tmp1->n_time := hup->n_time
            Select HUP
            Skip
          Enddo
          Select TMP1
          Go Top
          Do While !Eof()
            If between_time( mdate, mtime, tmp1->n_data, tmp1->n_time, mk_data, mk_time )
              motd := tmp1->otd
              tmp->is_per := .t.
            Endif
            Skip
          Enddo
        Endif
        tmp->otd := motd
        If tmp->( LastRec() ) % 2000 == 0
          Commit
        Endif
        If ( i := AScan( arr_otd, {| x| x[ 1 ] == motd } ) ) == 0
          AAdd( arr_otd, { motd, ;    // 1
          inieditspr( 6, dir_server() + 'mo_otd', motd ), ;  // 2
          0, 0 } ) // 3    всего
          i := Len( arr_otd )
        Endif
        ++arr_otd[i,3 ]
        If hu->reg_lech > 1
          ++arr_otd[i,4 ]
        Endif
      Endif
    Endif
    Select HU
    Skip
  Enddo
  Close databases
  closegauge( hGauge ) // Закроем окно отображения
  If fl_exit
    Return Nil
  Endif
  If Len( arr_otd ) == 0
    Return func_error( 4, 'Нет информации за указанный период времени!' )
  Endif
  ASort( arr_otd,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
  mas_pmt := { 'Итого количество по отделениям' }
  For i := 1 To Len( arr_otd )
    AAdd( mas_pmt, 'Список больных по "' + AllTrim( arr_otd[ i, 2 ] ) + '"' )
  Next
  mybell()
  buf := SaveScreen()
  n := 0
  AEval( mas_pmt, {| x| n := Max( n, Len( x ) ) } )
  r1 := T_ROW ; c1 := T_COL - 5
  If ( c2 := c1 + n + 3 ) > 77
    c1 := 77 -3 -n ; c2 := 77
  Endif
  If ( r2 := r1 + Len( mas_pmt ) + 1 ) > MaxRow() -2
    r2 := MaxRow() -2
  Endif
  i := 1
  Do While ( i := Popup( r1, c1, r2, c2, mas_pmt, i, color0, .t. ) ) > 0
    If i == 1
      arr_title := { ;
        '─────────────────────────────────────────────────────┬──────┬──────', ;
        '                                                     │      │в т.ч.', ;
        '    Наименование отделения                           │Кол-во│дн/ст.', ;
        '─────────────────────────────────────────────────────┴──────┴──────' }
    Else
      j := i - 1
      arr_title := { ;
        '──────────────────────────────────────────────────┬──────────┬─────┬─────', ;
        '                    Ф.И.О.                        │ Дата по- │Время│     ', ;
        '                                                  │ступления │     │дн/ст', ;
        '──────────────────────────────────────────────────┴──────────┴─────┴─────' }
    Endif
    reg_print := f_reg_print( arr_title, @sh )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    r_use( dir_server() + 'organiz',, 'ORG' )
    add_string( AllTrim( org->name ) )
    org->( dbCloseArea() )
    add_string( '' )
    add_string( Center( 'Количество стационарных больных', sh ) )
    add_string( Center( 'по состоянию на ' + full_date( mdate ) + ' ' + mtime, sh ) )
    If i > 1
      add_string( Center( 'по отделению "' + AllTrim( arr_otd[ j, 2 ] ) + '"', sh ) )
    Endif
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    ss := ssd := 0
    If i == 1
      For j := 1 To Len( arr_otd )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        s := PadR( AllTrim( arr_otd[ j, 2 ] ), 53 )
        s += put_val( arr_otd[ j, 3 ], 7 )
        s += put_val( arr_otd[ j, 4 ], 7 )
        ss += arr_otd[ j, 3 ]
        ssd += arr_otd[ j, 4 ]
        add_string( s )
      Next
      add_string( Replicate( '─', sh ) )
      s := PadC( 'Итого:', 53 )
      s += put_val( ss, 7 )
      s += put_val( ssd, 7 )
      add_string( s )
    Else
      Use ( cur_dir() + 'tmp' ) index ( cur_dir() + 'tmp' )
      find ( Str( arr_otd[ j, 1 ], 3 ) )
      Do While tmp->otd == arr_otd[ j, 1 ] .and. !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        s := lstr( ++ss ) + '. ' + LTrim( tmp->fio )
        add_string( PadR( s, 51 ) + full_date( tmp->n_data ) + ' ' + tmp->n_time + ;
          iif( tmp->reg_lech > 1, ' дн/ст', '' ) )
        Skip
      Enddo
      Use
    Endif
    FClose( fp )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Enddo
  RestScreen( buf )
  Return Nil

// 29.03.23 Просмотр/печать журнала регистрации стационарных больных по запросу
Function z_gurnal_pp()

  Static mm_forma := { { 'Полная форма', 1 }, ;
    { 'Сокращенная форма', 2 } }
  Static mm_sort := { { 'Сортировка по дате поступления', 1 }, ;
    { 'Сортировка по дате выбытия', 11 }, ;
    { 'Сортировка по Ф.И.О. больного', 2 }, ;
    { 'Начальная буква + дата поступления', 3 }, ;
    { 'Начальная буква + дата выбытия', 31 } }
  Static mm_mest := { { 'Волгоград или область', 1 }, { 'иногородние', 2 } }
  Static spar := 1, spar2 := 1
  Local mm_tmp := {}
  Local buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), fl_exit := .f., ;
    tmp_help := help_code, hGauge, name_file := cur_dir() + 'stgurnal.txt', ;
    sh, HH, i, j, k, tmp_file := 'tmp_mn_p' + sdbf(), arr_title, arr

  //
  Private arr_m, arr_mv, mm_company := {}, atime, atimev
  Private pr_arr := {}, pr_arr_otd := {}
  r_use( dir_server() + 'mo_otd',, 'OTD' )
  dbEval( {|| AAdd( pr_arr, { otd->( RecNo() ), otd->name, otd->kod_lpu, '' } ) }, ;
    {|| /*f_is_uch(st_a_uch,otd->kod_lpu) .and.*/ between_date(otd->dbegin,otd->dend,sys_date)} )
  r_use( dir_server() + 'mo_uch',, 'UCH' )
  AEval( pr_arr, {| x, i| dbGoto( x[ 3 ] ), pr_arr[ i, 4 ] := uch->name } )
  //
  ASort( pr_arr,,, {| x, y| iif( x[ 3 ] == y[ 3 ], Upper( x[ 2 ] ) < Upper( y[ 2 ] ), Upper( x[ 4 ] ) < Upper( y[ 4 ] ) ) } )
  AEval( pr_arr, {| x| AAdd( pr_arr_otd, x[ 2 ] + ' ' + x[ 4 ] ) } )
  Close databases
  //
  AAdd( mm_tmp, { 'date_lech', 'N', 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c,,, 2, @atime ), ;
    if( k == nil, nil, ( arr_m := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    'Дата поступления' } )
  AAdd( mm_tmp, { 'otd', 'N', 3, 0, NIL, ;
    {| x| menu_reader( x, { {|k, r, c| get_otd( k, r + 1, c ) } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    'Отделение, в которое госпитализировали пациента' } )
  AAdd( mm_tmp, { 'date_vyb', 'N', 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c,,, 2, @atimev ), ;
    if( k == nil, nil, ( arr_mv := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    'Дата выбытия' } )
  AAdd( mm_tmp, { 'lforma', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_forma, A__MENUVERT ) }, ;
    spar2, {|| inieditspr( A__MENUVERT, mm_forma, spar2 ) }, ;
    'Форма печати?' } )
  AAdd( mm_tmp, { 'lsort', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mm_sort, A__MENUVERT ) }, ;
    spar, {|| inieditspr( A__MENUVERT, mm_sort, spar ) }, ;
    'Вид сортировки?' } )
  AAdd( mm_tmp, { 'rab_nerab', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mmpp_rab, A__MENUBIT ) }, ;
    0, {| x| inieditspr( A__MENUBIT, mmpp_rab, x ) }, ;
    'Социальный статус' } )
  AAdd( mm_tmp, { 'mi_git', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mm_mest, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    'Место жительства:' } )
  AAdd( mm_tmp, { '_okato', 'C', 11, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {|k, r, c| get_okato_ulica( k, r, c, { k, m_okato, } ) } }, A__FUNCTION ) }, ;
    Space( 11 ), {| x| Space( 11 ) }, ;
    'Адрес регистрации (ОКАТО)' } )
  AAdd( mm_tmp, { 'adres', 'C', 20, 0, '@!', ;
    nil, ;
    Space( 20 ), nil, ;
    'Улица (подстрока или шаблон)' } )
  AAdd( mm_tmp, { 'vid_opl', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, menu_vid_opl, A__MENUBIT ) }, ;
    0, {| x| inieditspr( A__MENUBIT, menu_vid_opl, x ) }, ;
    'Вид оплаты' } )
  AAdd( mm_tmp, { 'komu', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mm_komu, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    'Принадлежность счёта', ;
    {| g, o| f_valid_komu( g, o ) } } )
  AAdd( mm_tmp, { 'company', 'N', 5, 0, NIL, ;
    {| x| menu_reader( x, mm_company, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    '  ==>',, {|| eq_any( m1komu, 0, 1, 3 ) } } )
  If glob_mo[ _MO_KOD_TFOMS ] == '711001' // РЖД
    AAdd( mm_tmp, { 'kem_dost', 'N', 2, 0, NIL, ;
      {| x| menu_reader( x, mmpp_kem_dost, A__MENUVERT ) }, ;
      -1, {|| Space( 10 ) }, ;
      'Кем направлен?' } )
  Else
    AAdd( mm_tmp, { 'kem_dost', 'N', 2, 0, NIL, ;
      {| x| menu_reader( x, mmpp_kem_dost, A__MENUVERT ) }, ;
      -1, {|| Space( 10 ) }, ;
      'Кем доставлен?' } )
  Endif
  AAdd( mm_tmp, { 'polis', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
    -1, {|| Space( 3 ) }, ;
    'Полис введен?' } )
  AAdd( mm_tmp, { 'reg_lech', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mmpp_regim, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    'Режим лечения?' } )
  AAdd( mm_tmp, { 'uch_doc', 'C', 10, 0, '@!', ;
    nil, ;
    Space( 10 ), nil, ;
    '№ истории болезни (шаблон)' } )
  AAdd( mm_tmp, { 'fio', 'C', 20, 0, '@!', ;
    nil, ;
    Space( 20 ), nil, ;
    'ФИО (начальные буквы или шаблон)' } )
  AAdd( mm_tmp, { 'mr_dol', 'C', 20, 0, '@!', ;
    nil, ;
    Space( 20 ), nil, ;
    'Место работы (подстрока или шаблон)' } )
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
  Delete File ( tmp_file )
  init_base( tmp_file,, mm_tmp, 0 )
  k := f_edit_spr( A__APPEND, mm_tmp, 'запросу для печати журнала', ;
    'g_use(cur_dir()+"tmp_mn_p",,,.t.,.t.)', 0, 1,,,,, 'wr_mn_pp' )
  Close databases
  RestScreen( buf )
  SetColor( tmp_color )
  If k > 0
    mywait()
    Use ( tmp_file ) New Alias MN
    spar := mn->lsort
    spar2 := mn->lforma
    If spar2 == 1
      arr_title := { ;
        '─────┬─────┬──────────────────┬──────────┬──────────────────┬────────────────────┬───────────────┬───────────────┬───────────────╥──────────┬──────────┬───────────────────────╥─────', ;
        ' NN  │Дата,│ Фамилия, имя,    │   Дата   │ Паспорт и полис  │ Постоянное место   │Каким учрежде- │№ ист.болезни и│Диагноз напра- ║Выписан,  │Отметка о │Если не был госпитализ.║Приме', ;
        ' пп  │время│ отчество больного│ рождения │                  │ жительства,        │нием направлен,│отделение, куда│вившего учр-ия;║переведен │сообщении ├────────────┬──────────╢чание', ;
        '     │пост.│                  │ и возраст│                  │ место работы       │кем доствлен   │помещен больной│приемного отд-я║в др.стац.│родственн.│причина/меры│отказ в пр║     ', ;
        '─────┴─────┴──────────────────┴──────────┴──────────────────┴────────────────────┴───────────────┴───────────────┴───────────────╨──────────┴──────────┴────────────┴──────────╨─────';
        }
      sh := Len( arr_title[ 1 ] ) ; HH := 54 ; reg_print := 6
      Private yes_albom := .t.
      //
      Private a01[ 10 ], a02[ 10 ], a03[ 10 ], a04[ 10 ], a05[ 10 ], a06[ 10 ], a07[ 10 ], ;
        a08[ 10 ], a09[ 10 ], a10[ 10 ], a11[ 10 ]
      Private k01, k02, k03, k04, k05, k06, k07, k08, k09, k10, k11
      Private sh01 := 5, sh02 := 5, sh03 := 18, sh04 := 10, sh05 := 18, ;
        sh06 := 20, sh07 := 15, sh08 := 15, sh09 := 15
      Private arr_center := { 2, 4, 10 }
      AFill( a01, '' ) ; k01 := 1
      AFill( a02, '' ) ; k02 := 2
      AFill( a03, '' )
      AFill( a04, '' )
      AFill( a05, '' )
      AFill( a06, '' )
      AFill( a07, '' )
      AFill( a08, '' )
      AFill( a09, '' )
      kol := 9
    Else
      arr_title := { ;
        '─────┬───────────┬─────────┬──────────────────────────┬────────────────────┬──────────', ;
        ' NN  │Дата, время│№ истории│  Фамилия, имя, отчество  │    Наименование    │   Дата   ', ;
        ' пп  │поступления│  болезни│        больного          │      отделения     │  выписки ', ;
        '─────┴───────────┴─────────┴──────────────────────────┴────────────────────┴──────────';
        }
      sh := Len( arr_title[ 1 ] ) ; HH := 80 ; reg_print := 5
      //
      Private a04[ 10 ], a05[ 10 ], k04, k05
      Private sh01 := 5, sh02 := 11, sh03 := 9, sh04 := 26, sh05 := 20
      AFill( a04, '' )
      AFill( a05, '' )
      kol := 9
    Endif
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    r_use( dir_server() + 'organiz',, 'ORG' )
    add_string( PadR( org->name, sh - 15 ) + PadL( 'форма №001/у', 15 ) )
    add_string( '' )
    add_string( Center( 'Журнал учета приема больных и отказов в госпитализации', sh ) )
    If !Empty( mn->date_lech )
      add_string( Center( 'Дата поступления: ' + arr_m[ 4 ], sh ) )
    Endif
    If mn->otd > 0
      add_string( 'Отделение, в которое госпитализировали пациента: ' + inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', mn->otd ) )
    Endif
    If !Empty( mn->date_vyb )
      add_string( Center( 'Дата выбытия: ' + arr_mv[ 4 ], sh ) )
    Endif
    //
    Private much_doc := '', mfio := '', madres := '', mmr_dol := ''
    If !Empty( mn->rab_nerab )
      add_string( '- социальный статус: ' + inieditspr( A__MENUBIT, mmpp_rab, mn->rab_nerab ) )
    Endif
    If mn->mi_git > 0
      add_string( '- место жительства: ' + inieditspr( A__MENUVERT, mm_mest, mn->mi_git ) )
    Endif
    If !Empty( mn->_okato )
      add_string( '- адрес регистрации (ОКАТО): ' + ret_okato_ulica( '', mn->_okato ) )
    Endif
    If !Empty( mn->adres )
      madres := AllTrim( mn->adres )
      If !( Left( madres, 1 ) == '*' )
        madres := '*' + madres
      Endif
      If !( Right( madres, 1 ) == '*' )
        madres += '*'
      Endif
      add_string( '- улица: ' + madres )
    Endif
    If !Empty( mn->mr_dol )
      mmr_dol := AllTrim( mn->mr_dol )
      If !( Left( mmr_dol, 1 ) == '*' )
        mmr_dol := '*' + mmr_dol
      Endif
      If !( Right( mmr_dol, 1 ) == '*' )
        mmr_dol += '*'
      Endif
      add_string( '- место работы: ' + mmr_dol )
    Endif
    If !Empty( mn->vid_opl )
      add_string( '- вид оплаты: ' + inieditspr( A__MENUBIT, menu_vid_opl, mn->vid_opl ) )
    Endif
    If mn->komu >= 0
      add_string( '- принадлежность счёта: ' + ;
        inieditspr( A__MENUVERT, mm_komu, mn->komu ) )

      If mn->company > 0
        add_string( '  ==> ' + ;
          inieditspr( A__MENUVERT, mm_company, mn->company ) )
      Endif
    Endif
    If mn->kem_dost >= 0
      If glob_mo[ _MO_KOD_TFOMS ] == '711001' // РЖД
        add_string( '- кем направлен: ' + inieditspr( A__MENUVERT, mmpp_kem1dost, mn->kem_dost ) )
      Else
        add_string( '- кем доставлен: ' + inieditspr( A__MENUVERT, mmpp_kem_dost, mn->kem_dost ) )
      Endif
    Endif
    If mn->polis >= 0
      add_string( '- полис ' + iif( mn->polis == 1, 'ВВЕДЕН', 'НЕ ВВЕДЕН' ) )
    Endif
    If mn->reg_lech > 0
      add_string( '- режим лечения: ' + inieditspr( A__MENUVERT, mmpp_regim, mn->reg_lech ) )
    Endif
    If !Empty( mn->uch_doc )
      much_doc := AllTrim( mn->uch_doc )
      If !( Right( much_doc, 1 ) == '*' )
        much_doc += '*'
      Endif
      add_string( '- № истории болезни: ' + much_doc )
    Endif
    If !Empty( mn->fio )
      mfio := AllTrim( mn->fio )
      If !( Right( mfio, 1 ) == '*' )
        mfio += '*'
      Endif
      add_string( '- ФИО: ' + mfio )
    Endif
    If !Empty( mn->pol )
      add_string( '- пол: ' + mn->pol )
    Endif
    If !Empty( mn->god_r_min ) .or. !Empty( mn->god_r_max )
      If Empty( mn->god_r_min )
        add_string( '- лица, родившиеся до ' + full_date( mn->god_r_max ) )
      Elseif Empty( mn->god_r_max )
        add_string( '- лица, родившиеся после ' + full_date( mn->god_r_min ) )
      Else
        add_string( '- лица, родившиеся с ' + ;
          full_date( mn->god_r_min ) + ' по ' + full_date( mn->god_r_max ) )
      Endif
    Endif
    AEval( arr_title, {| x| add_string( x ) } )
    Private c_view := 0, c_found := 0
    r_use( dir_server() + 'mo_kpred', dir_server() + 'mo_kpred', 'KPR' )
    r_use( dir_server() + 'mo_kinos', dir_server() + 'mo_kinos', 'KIS' )
    r_use( dir_server() + 'kartote_',, 'KART_' )
    r_use( dir_server() + 'kartotek',, 'KART' )
    Set Relation To RecNo() into KART_
    r_use( dir_server() + 'mo_ppdia', dir_server() + 'mo_ppdia', 'HUS' )
    r_use( dir_server() + 'mo_pp',, 'HU' )
    Set Relation To kod_k into KART
    If Empty( mn->date_lech )
      Select HU
      Index On DToS( k_data ) to ( cur_dir() + 'tmp_pp' ) For !Empty( k_data ) progress
      dbSeek( DToS( arr_mv[ 5 ] ), .t. )
      Do Case
      Case spar == 11
        Index On DToS( k_data ) + k_time + Upper( kart->fio ) to ( cur_dir() + 'tmp_hu' ) ;
          While k_data <= arr_mv[ 6 ]
      Case spar == 2
        Index On Upper( kart->fio ) + DToS( k_data ) + k_time to ( cur_dir() + 'tmp_hu' ) ;
          While k_data <= arr_mv[ 6 ]
      Case spar == 31
        Index On Upper( Left( kart->fio, 1 ) ) + DToS( k_data ) + k_time to ( cur_dir() + 'tmp_hu' ) ;
          While k_data <= arr_mv[ 6 ]
      Endcase
    Else
      Select HU
      Set Index to ( dir_server() + 'mo_pp_d' )
      dbSeek( DToS( arr_m[ 5 ] ), .t. )
      Do Case
      Case spar == 1
        Index On DToS( n_data ) + n_time + Upper( kart->fio ) to ( cur_dir() + 'tmp_hu' ) ;
          While n_data <= arr_m[ 6 ]
      Case spar == 2
        Index On Upper( kart->fio ) + DToS( n_data ) + n_time to ( cur_dir() + 'tmp_hu' ) ;
          While n_data <= arr_m[ 6 ]
      Case spar == 3
        Index On Upper( Left( kart->fio, 1 ) ) + DToS( n_data ) + n_time to ( cur_dir() + 'tmp_hu' ) ;
          While n_data <= arr_m[ 6 ]
      Endcase
    Endif
    k := 0
    waitstatus( '<Esc> - прервать операцию' )
    Go Top
    Do While !Eof()
      If ( fl_exit := ( Inkey() == K_ESC ) )
        add_string( Expand( 'ПРОЦЕСС ПРЕРВАН' ) )
        Exit
      Endif
      updatestatus()
      If spar == 1
        @ MaxRow(), 1 Say full_date( hu->n_data ) + ' ' + hu->n_time Color 'G+/R'
      Else
        @ MaxRow(), 1 Say PadR( fam_i_o( kart->fio ), 25 ) Color 'G+/R'
      Endif
      fl := .t.
      If fl .and. !Empty( mn->date_lech )
        fl := between_time( hu->n_data, hu->n_time, arr_m[ 5 ], atime[ 1 ], arr_m[ 6 ], atime[ 2 ] )
      Endif
      If fl .and. !Empty( mn->date_vyb )
        fl := !Empty( hu->k_data ) .and. ;
          between_time( hu->k_data, hu->k_time, arr_mv[ 5 ], atimev[ 1 ], arr_mv[ 6 ], atimev[ 2 ] )
      Endif
      If fl .and. pp_mnog_poisk()
        ++k
        If spar2 == 1
          // 1 - номер по порядку
          a01[ 1 ] := Str( k, 5 )
          // 2 - дата и время поступления
          a02[ 1 ] := Left( full_date( hu->N_DATA ), 5 )
          a02[ 2 ] := hu->N_TIME
          // 3 - ФИО больного
          k03 := perenos( a03, kart->fio, sh03 )
          // 4 - дата рождения и возраст
          s := full_date( kart->date_r ) + ' ' + count_ymd( kart->date_r, hu->N_DATA )
          k04 := perenos( a04, s, sh04 )
          // 5 - паспорт и полис
          s := get_name_vid_ud( kart_->vid_ud )
          s += ' ' + AllTrim( kart_->SER_UD )
          s += ' ' + AllTrim( kart_->NOM_UD ) + '; '
          If !Empty( kart->polis )
            s += 'полис: ' + make_polis( kart_->spolis, kart_->npolis ) + ' '
          Endif
          s += AllTrim( f4_view_list_schet( hu->komu, cut_code_smo( kart_->smo ), hu->str_crb ) )
          k05 := perenos( a05, s, sh05 )
          // 6 - адрес
          s := RTrim( inieditspr( A__MENUVERT, mm_gorod_selo, kart_->gorod_selo ) ) + ', '
          s += iif( emptyall( kart_->okatog, kart->adres ), '', ;
            ret_okato_ulica( kart->adres, kart_->okatog ) )
          If !Empty( kart->mr_dol )
            s += '; ' + AllTrim( kart->mr_dol )
          Endif
          k06 := perenos( a06, s, sh06 )
          // 7 - кем направлен и кем доставлен
          s := ''
          If !Empty( hu->kem_napr )
            s += ret_mo( hu->kem_napr )[ _MO_SHORT_NAME ]
          Endif
          If glob_mo[ _MO_KOD_TFOMS ] == '711001' // РЖД
            s += iif( Empty( s ), '', ', ' ) + ;
              AllTrim( inieditspr( A__MENUVERT, mmpp_kem1dost, hu->KEM_DOST ) )
          Else
            s += iif( Empty( s ), '', ', ' ) + ;
              AllTrim( inieditspr( A__MENUVERT, mmpp_kem_dost, hu->KEM_DOST ) )
          Endif
          k07 := perenos( a07, s, sh07 )
          // 8 - отделение, в которое помещен больной
          s := '№ ' + AllTrim( hu->UCH_DOC ) + '; '
          s += inieditspr( 6, dir_server() + 'mo_otd', hu->otd )
          k08 := perenos( a08, s, sh08 )
          // 9 - диагноз направившего учреждения
          MDIAG_NAPR := MDIAG_PR_P := MPOB_D_LEK := ''
          Select HUS
          find ( Str( hu->kod, 7 ) )
          Do While hus->kod == hu->kod .and. !Eof()
            Do Case
            Case hus->tip == 1
              MDIAG_NAPR := AllTrim( hus->name ) // диагноз направившего учреждения
            Case hus->tip == 2
              MDIAG_PR_P := AllTrim( hus->name ) // диагноз приемного отделения
            Case hus->tip == 3
              MPOB_D_LEK := AllTrim( hus->name ) // побочное действие лекарств
            Endcase
            Skip
          Enddo
          s := iif( Empty( mDIAG_NAPR ), '-', mDIAG_NAPR ) + '; ' + ;
            iif( Empty( mDIAG_PR_P ), '-', mDIAG_PR_P )
          k09 := perenos( a09, s, sh09 )
          //
          kk := 1
          For i := 1 To kol
            pole := 'k' + StrZero( i, 2 )
            kk := Max( kk, &pole )
          Next
          kk := Min( kk, 10 )
          If verify_ff( HH - kk, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          For j := 1 To kk
            s := ''
            For i := 1 To kol
              pole := 'a' + StrZero( i, 2 )
              ss := &pole.[ j ]
              pole := 'sh' + StrZero( i, 2 )
              If AScan( arr_center, i ) > 0
                ss := PadC( AllTrim( ss ), &pole )
              Else
                ss := PadR( AllTrim( ss ), &pole )
              Endif
              s += ss + ' '
            Next
            If j == 1  // в первой строке
              s += PadR( full_date( hu->K_DATA ), 10 ) + ' ' // Выписан, переведен в др.стацион.
              If hu->novor > 0
                s += PadC( 'новорожден', 10 ) + ' '
              Else
                Select KPR
                find ( Str( hu->kod_k, 7 ) )
                s += PadC( iif( Found() .and. kpr->is_uhod == 1, 'по уходу', '' ), 10 ) + ' ' // сообщение родственникам
              Endif
              If hu->is_gospit == 1
                s1 := 'не госпитализирован'
                s += PadR( s1, 12 + 1 + 10 + 1 )
              Else
                s += Space( 12 ) + ' '   // причина/меры
                s += Space( 10 ) + ' '   // отказ в пр
              Endif
              s += SubStr( inieditspr( 6, dir_server() + 'mo_ppst', hu->stol ), 1, 5 ) // Примечание
            Elseif j == 2  // во второй строке
              If !Empty( hu->k_data )
                s += PadC( hu->N_TIME, 11 )
              Else
                s += Space( 11 )
              Endif
              s += Space( 11 )
              s1 := ''
              If hu->is_gospit == 1 .and. hu->pr_gospit > 0
                s1 := inieditspr( A__MENUVERT, mmpp_pr_gospit, hu->pr_gospit )
              Endif
              s += PadR( s1, 12 + 1 + 10 + 1 )
              If hu->ishod2 == 6  // умер
                s += 'УМЕР'
              Else
                s += SubStr( inieditspr( 6, dir_server() + 'mo_ppst', hu->stol ), 6, 5 ) // Примечание
              Endif
            Endif
            add_string( s )
          Next
          Select KIS
          find ( Str( hu->kod_k, 7 ) )
          If Found() // иностранец
            f_gur_inostr_pp( sh )
          Endif
        Else
          // 1 - номер по порядку
          s := Str( k, 5 ) + ' '
          // 2 - дата и время поступления
          s += Left( full_date( hu->N_DATA ), 5 ) + ' ' + hu->N_TIME + ' '
          // 3 - история болезни
          s += hu->UCH_DOC
          // 3 - ФИО больного
          k04 := perenos( a04, kart->fio, sh04 )
          s += PadR( a04[ 1 ], sh04 + 1 )
          // 5 - отделение, в которое помещен больной
          k05 := perenos( a05, inieditspr( 6, dir_server() + 'mo_otd', hu->otd ), sh05 )
          s += PadR( a05[ 1 ], sh05 + 1 )
          s += full_date( hu->K_DATA )
          kk := Min( Max( k04, k05 ), 10 )
          If verify_ff( HH - kk, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          add_string( s )
          For j := 2 To kk
            s := Space( sh01 + 1 + sh02 + 1 + sh03 + 1 )
            s += PadR( a04[ j ], sh04 + 1 )
            s += PadR( a05[ j ], sh05 + 1 )
            add_string( s )
          Next
          Select KIS
          find ( Str( hu->kod_k, 7 ) )
          If Found() // иностранец
            f_gur_inostr_pp( sh )
          Endif
          If kk == 1
            add_string( '' )
          Endif
        Endif
      Endif
      Select HU
      Skip
    Enddo
    Close databases
    FClose( fp )
    RestScreen( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  Return Nil

// 31.08.14
Function wr_mn_pp( k )

  Local fl := .t.

  If k == 1
    If emptyall( mdate_lech, mdate_vyb )
      fl := func_error( 4, 'Обязательно должно быть заполнено хотя бы одно поле даты!' )
    Endif
    If fl .and. Empty( mdate_lech ) .and. eq_any( m1lsort, 1, 3 )
      fl := func_error( 4, 'Вид сортировки не соответствует выбранной дате!' )
    Endif
    If fl .and. Empty( mdate_vyb ) .and. eq_any( m1lsort, 11, 31 )
      fl := func_error( 4, 'Вид сортировки не соответствует выбранной дате!' )
    Endif
  Endif
  Return fl

// 02.11.20
Static Function pp_mnog_poisk()

  Local i, j, fl := .t.

  If fl .and. mn->otd > 0
    fl := ( hu->otd == mn->otd )
  Endif
  If fl .and. mn->rab_nerab > 0
    fl := .f.
    For i := 1 To Len( mmpp_rab )
      j := mmpp_rab[ i, 2 ]
      If IsBit( mn->rab_nerab, j ) .and. IsBit( hu->rab_nerab, j )
        fl := .t. ; Exit
      Endif
    Next
  Endif
  If fl .and. mn->vid_opl > 0
    fl := .f.
    For i := 1 To Len( menu_vid_opl )
      j := menu_vid_opl[ i, 2 ]
      If IsBit( mn->vid_opl, j ) .and. IsBit( hu->vid_opl, j )
        fl := .t. ; Exit
      Endif
    Next
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
  If fl .and. mn->komu >= 0
    If mn->company == 0
      fl := ( mn->komu == hu->komu )
    Elseif mn->komu == 0
      fl := ( Int( Val( cut_code_smo( kart_->smo ) ) ) == mn->company )
    Else
      fl := ( mn->komu == hu->komu .and. mn->company == hu->str_crb )
    Endif
  Endif
  If fl .and. mn->kem_dost >= 0
    fl := ( hu->KEM_DOST == mn->kem_dost )   // кем доставлен
  Endif
  If fl .and. mn->polis >= 0
    If mn->polis == 1
      fl := !Empty( kart->polis )
    Else
      fl := Empty( kart->polis )
    Endif
  Endif
  If fl .and. mn->reg_lech > 0
    fl := ( hu->reg_lech == mn->reg_lech )
  Endif
  If fl .and. !Empty( much_doc )
    fl := Like( much_doc, hu->uch_doc )
  Endif
  If fl .and. !Empty( mfio )
    fl := Like( mfio, Upper( kart->fio ) )
  Endif
  If fl .and. !Empty( madres )
    fl := Like( madres, Upper( kart->adres ) )
  Endif
  If fl .and. !Empty( mmr_dol )
    fl := Like( mmr_dol, Upper( kart->mr_dol ) )
  Endif
  If fl .and. !Empty( mn->pol )
    fl := ( kart->pol == mn->pol )
  Endif
  If fl .and. !Empty( mn->god_r_min )
    fl := ( mn->god_r_min <= kart->date_r )
  Endif
  If fl .and. !Empty( mn->god_r_max )
    fl := ( kart->date_r <= mn->god_r_max )
  Endif
  Return fl

//
Function f_gur_inostr_pp( sh )

  Local i, s, arr[ 2 ], mSTRANA := getcountry( kart_->strana )

  If !Empty( mSTRANA )
    s := 'страна: "' + AllTrim( mSTRANA ) + '"' // страна
    If !Empty( kis->ADRES_PRO )
      s += ', адрес проживания в Волг.обл.: "' + AllTrim( kis->ADRES_PRO ) + '"'
    Endif
    If !Empty( kis->MIGR_KARTA )
      s += ', миграционная карта: "' + AllTrim( kis->MIGR_KARTA ) + '"'
    Endif
    If !Empty( kis->DATE_P_G )
      s += ', дата пересечения границы: "' + full_date( kis->DATE_P_G ) + '"'
    Endif
    If !Empty( kis->DATE_R_M )
      s += ', дата регистрации в миграционной службе: "' + full_date( kis->DATE_R_M ) + '"'
    Endif
    For i := 1 To perenos( arr, s, sh - 6 )
      add_string( Space( 6 ) + arr[ i ] )
    Next
  Endif
  Return Nil

//
Function pr_perevod_pp()

  Local arr_m, i, j, l, k, k1, begin_date, end_date, s, buf := save_maxrow(), ;
    sh := 81, HH := 58, reg_print := 2, name_file := cur_dir() + 'pp_perev.txt', ;
    arr, atime

  If ( arr_m := year_month( T_ROW, T_COL - 5,,, 2, @atime ) ) == NIL
    Return Nil
  Endif
  //
  mywait()
  dbCreate( cur_dir() + 'tmp', { { 'kod', 'N', 7, 0 }, ;
    { 'otd1', 'N', 3, 0 }, ;
    { 'stol1', 'N', 3, 0 }, ;
    { 'N_DATA',   'D',     8,     0 }, ; // дата перевода
  { 'N_TIME',   'C',     5,     0 }, ; // время перевода
  { 'otd2', 'N', 3, 0 }, ;
    { 'stol2', 'N', 3, 0 }, ;
    { 'rec', 'N', 7, 0 } } )
  Use ( cur_dir() + 'tmp' ) new
  r_use( dir_server() + 'mo_pp',, 'HU' )
  r_use( dir_server() + 'mo_ppper',, 'PER' )
  Index On Str( kod, 7 ) to ( cur_dir() + 'tmp_per' ) For Between( n_data, arr_m[ 5 ], arr_m[ 6 ] )
  Go Top
  Do While !Eof()
    If between_time( per->n_data, per->n_time, arr_m[ 5 ], atime[ 1 ], arr_m[ 6 ], atime[ 2 ] )
      Select TMP
      Append Blank
      tmp->kod    := per->kod
      tmp->N_DATA := per->N_DATA
      tmp->N_TIME := per->N_TIME
      tmp->otd2   := per->otd
      tmp->stol2  := per->stol
      tmp->rec    := per->( RecNo() )
    Endif
    Select PER
    Skip
  Enddo
  If ( k := tmp->( LastRec() ) ) > 0
    Select PER
    Set Index to ( dir_server() + 'mo_ppper' )
    Select TMP
    Go Top
    Do While !Eof()
      arr := {}
      Select PER
      find ( Str( tmp->kod, 7 ) )
      Do While per->kod == tmp->kod .and. !Eof()
        AAdd( arr, { per->n_data, per->n_time, per->( RecNo() ), per->otd, per->stol } )
        Skip
      Enddo
      ASort( arr,,, {| x, y| iif( x[ 1 ] == y[ 1 ], x[ 2 ] < y[ 2 ], x[ 1 ] < y[ 1 ] ) } )
      If ( j := AScan( arr, {| x| x[ 3 ] == tmp->rec } ) ) > 1  // если переводился до этого
        tmp->otd1 := arr[ j - 1, 4 ]
        tmp->stol1 := arr[ j - 1, 5 ]
      Else  // не было ни одного перевода до этого
        hu->( dbGoto( tmp->kod ) )
        tmp->otd1 := hu->otd
        tmp->stol1 := hu->stol
      Endif
      Select TMP
      Skip
    Enddo
  Endif
  Close databases
  If k == 0
    rest_box( buf )
    Return func_error( 4, 'Нет информации за указанный период времени!' )
  Endif
  //
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + 'organiz',, 'ORG' )
  add_string( AllTrim( org->name ) )
  org->( dbCloseArea() )
  add_string( '' )
  add_string( Center( 'Список больных, переведенных в другие отделения', sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  r_use( dir_server() + 'kartote_',, 'KART_' )
  r_use( dir_server() + 'kartotek',, 'KART' )
  Set Relation To RecNo() into KART_
  r_use( dir_server() + 'mo_pp',, 'HU' )
  Set Relation To kod_k into KART
  Use ( cur_dir() + 'tmp' ) new
  Set Relation To kod into HU
  Index On DToS( n_data ) + n_time to ( cur_dir() + 'tmp' )
  j := 0
  Go Top
  Do While !Eof()
    verify_ff( HH, .t., sh )
    add_string( '' )
    add_string( lstr( ++j ) + '. ' + AllTrim( kart->fio ) + ' (№' + AllTrim( hu->uch_doc ) + ' ' + ;
      DToC( hu->n_data ) + ' ' + hu->n_time + ')' )
    s := Space( Len( lstr( j ) ) + 2 ) + ;
      'из "' + PadR( inieditspr( 6, dir_server() + 'mo_otd', tmp->otd1 ), 31 )
    If tmp->stol1 > 0
      s += '" (стол ' + AllTrim( inieditspr( A__POPUPMENU, dir_server() + 'mo_ppst', tmp->stol1 ) ) + ')'
    Endif
    add_string( s )
    s := Space( Len( lstr( j ) ) + 2 ) + ;
      ' в "' + PadR( inieditspr( 6, dir_server() + 'mo_otd', tmp->otd2 ), 31 )
    If tmp->stol2 > 0
      s += '" (стол ' + AllTrim( inieditspr( A__POPUPMENU, dir_server() + 'mo_ppst', tmp->stol2 ) ) + ')'
    Endif
    s += ' ' + DToC( tmp->n_data ) + ' ' + tmp->n_time
    add_string( s )
    Select TMP
    Skip
  Enddo
  //
  FClose( fp )
  Close databases
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Return Nil

//
Function pr_error_pp( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j, uch_otd

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { 'Дубликаты в ~историях болезни' }
    mas_msg := { 'Поиск дубликатов в историях болезни' }
    mas_fun := { 'pr_error_pp(12)' }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    dubl_ist_b_pp()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif
  Return Nil

//
Function dubl_ist_b_pp()

  Local g1, j := 0, k := 0, sh := 80, HH := 80, n_file := 'dubl_ist.txt'

  dbCreate( cur_dir() + 'tmp', { { 'N_DATA', 'D', 8, 0 }, ; // дата поступления
  { 'kol', 'N', 6, 0 } } )
  fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
  add_string( '' )
  add_string( Center( 'Дубликаты историй болезни', sh ) )
  add_string( Center( 'по состоянию на ' + full_date( sys_date ), sh ) )
  add_string( '' )
  Use ( cur_dir() + 'tmp' ) new
  Index On DToS( n_data ) to ( cur_dir() + 'tmp' )
  r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_r', 'HU' )
  r_use( dir_server() + 'kartotek', dir_server() + 'kartoten', 'KART' )
  waitstatus( '<Esc> - прервать поиск' ) ; mark_keys( { '<Esc>' } )
  hGauge := gaugenew(,,, '', .t. )
  gaugedisplay( hGauge )
  Go Top
  Do While !Eof()
    gaugeupdate( hGauge, ++j / LastRec() )
    updatestatus()
    If Inkey() == K_ESC
      Exit
    Endif
    If kart->kod > 0
      fl := .f. ; old_data := SToD( '20100101' )
      Select HU
      find ( Str( kart->kod, 7 ) )
      Do While hu->kod_k == kart->kod .and. !Eof()
        If old_data == hu->n_data
          fl := .t. ; Exit
        Endif
        old_data := hu->n_data
        Skip
      Enddo
      If fl
        Select TMP
        Zap
        Select HU
        find ( Str( kart->kod, 7 ) )
        Do While hu->kod_k == kart->kod .and. !Eof()
          Select TMP
          find ( DToS( hu->n_data ) )
          If !Found()
            Append Blank
            tmp->n_data := hu->n_data
          Endif
          tmp->kol++
          Select HU
          Skip
        Enddo
        Commit
        verify_ff( HH - 4, .t., sh )
        add_string( '' )
        add_string( lstr( ++k ) + '. ' + AllTrim( kart->fio ) )
        Select TMP
        Go Top
        Do While !Eof()
          If tmp->kol > 1
            add_string( '' )
            Select HU
            find ( Str( kart->kod, 7 ) + DToS( tmp->n_data ) )
            Do While hu->kod_k == kart->kod .and. hu->n_data == tmp->n_data .and. !Eof()
              add_string( Space( 10 ) + '№ ' + hu->UCH_DOC + ' ' + ;
                full_date( hu->n_data ) + ' ' + ;
                hu->n_time + ' ' + ;
                inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', hu->otd ) )
              Skip
            Enddo
          Endif
          Select TMP
          Skip
        Enddo
      Endif
    Endif
    @ 24, 1 Say lstr( j ) Color 'W+/R'
    @ Row(), Col() Say '/' Color 'W/R'
    @ Row(), Col() Say lstr( k ) Color 'G+/R'
    Select KART
    Skip
  Enddo
  closegauge( hGauge )
  Close databases
  If k > 0
    viewtext( n_file,,,, .f.,,, 5 )
  Endif
  Return Nil
