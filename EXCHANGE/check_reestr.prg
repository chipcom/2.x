// check_reestr.prg - проверки в файлах реестра
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static lcount_uch := 1
Static lcount_otd := 1

// 22.03.26
Function o_proverka( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { ;
      'Общая проверка по ~запросу', ;
      'Не введен код ~врача', ;
      'Не введен код ~ассистента', ;
      'Врач + ~больные за день', ;
      '~Рассогласования в базах данных',;
      '~Рассогласования в реестрах/счетах в базе данных',;
      '~Подбор иногородних'   }
      //   'Одинаковые сочетания - № карты + ~дата вызова', ;
    mas_msg := { ;
      'Общие проверки (многовариантный запрос)', ;
      'Проверка листов учета на отсутствие кода врача', ;
      'Проверка листов учета на отсутствие кода ассистента', ;
      'Вывод списка принятых больных конкретным врачом за день', ;
      'Поиск рассогласований в базах данных (не заполнены или неверно заполнены поля)', ;
      'Поиск рассогласований рассогласования в реестрах/счетах в базе данных',;
      'Поиск пациантов, выставленных ранее в другие области'   }
      //      'Поиск одинаковых сочетаний номера карты вызова + даты вызова', ;
    mas_fun := { ;
      'o_proverka(11)', ;
      'o_proverka(12)', ;
      'o_proverka(13)', ;
      'o_proverka(14)', ;
      'o_proverka(16)', ;
      'o_proverka(17)', ;
      'o_proverka(18)'}
   //'o_proverka(15)', ;
    uch_otd := saveuchotd()
    Private p_net_otd := .t.
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
    restuchotd( uch_otd )
  Case k == 11
    proch_proverka()
  Case k == 12
    o_pr_vr_as( 1 )
  Case k == 13
    o_pr_vr_as( 2 )
  Case k == 14
    i_vr_boln()
  //Case k == 15
  //  posik_smp_n_d()
  Case k == 16
    poisk_rassogl()
  Case k == 17
    poisk_rassogl_schet_reestr()
  Case k == 18
    podbor_inogorodnie()  
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// 02.04.26
Function proch_proverka()

  Static sd, sl := 2
  Static mm_schet := { ;
    { 'по счетам         ', 1 }, ;
    { 'по реестрам       ', 2 }, ;
    { 'по невыписанным...', 3 } }
  Static mm_logical := { ;
    { 'логическое И  ', 1 }, ;
    { 'логическое ИЛИ', 2 } }
  Local buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    name_file := 'proverka.txt', i, j, arr_usl, ;
    sh := 64, HH := 57, reg_print := 2, r1 := 9, cdate, mdiagnoz, ;
    mm_da_net := { { 'нет', 1 }, { 'да ', 2 } }, lcount_uch

  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
    Return Nil
  Endif
  Default sd To sys_date
  Private pdate_schet, m1schet := 1, mschet, ;
    m1logic := sl, mlogic, ;
    m1mkb := 0, mmkb := Space( 3 ), ;
    m1usl_dn := 0, musl_dn := Space( 3 ), ;
    m1ns_usl := 0, mns_usl := Space( 3 ), ;
    m1ns1usl := 1, mns1usl, ;
    m1pervich := 0, mpervich := Space( 3 ), ;
    mkol := 0, msrok1 := 0, msrok2 := 0, ;
    m1date_schet := 0, mdate_schet := Space( 10 ), ;
    mm_ns1usl := { ;
                    { 'только по этому случаю  ', 1 }, ;
                    { 'по всем случаям больного', 2 } }, ;
    gl_area := { r1, 2, MaxRow() -2, MaxCol() -2, 0 }
  mns1usl := inieditspr( A__MENUVERT, mm_ns1usl, m1ns1usl )
  mschet := inieditspr( A__MENUVERT, mm_schet, m1schet )
  mlogic := inieditspr( A__MENUVERT, mm_logical, m1logic )
  r1 := MaxRow() -14
  box_shadow( r1, 2, MaxRow() -2, MaxCol() -2,, 'Ввод данных для поиска информации', color8 )
  Do While .t.
    j := r1 + 1
    @ ++j, 4 Say 'Где искать' Get mschet ;
      reader {| x| menu_reader( x, mm_schet, A__MENUVERT,,, .f. ) } ;
      valid {|| iif( m1schet > 1, mdate_schet := CToD( '' ), ), .t. }
    @ Row(), Col() + 3 Say 'Дата счёта' Get mdate_schet ;
      reader {| x| menu_reader( x, ;
      { {| k, r, c| k := year_month( r + 1, c ), ;
      if( k == nil, nil, ( pdate_schet := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
      k } }, A__FUNCTION,,, .f. ) } ;
      When m1schet == 1
    @ ++j, 4 Say 'Метод поиска' Get mlogic ;
      reader {| x| menu_reader( x, mm_logical, A__MENUVERT,,, .f. ) }
    @ ++j, 4 Say 'Максимальное количество оказанных услуг' Get mkol Pict '999'
    @ ++j, 4 Say 'Срок лечения (в днях): минимальный' Get msrok1 Pict '999'
    @ Row(), Col() Say ', максимальный' Get msrok2 Pict '999'
    @ ++j, 4 Say 'Количество одноименных услуг <= количества дней лечения?' Get musl_dn ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
    @ ++j, 4 Say 'Проверять все диагнозы на соответствие МКБ-10 (по ОМС)?' Get mmkb ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
    @ ++j, 4 Say 'Проверять несовместимость услуг по дате оказания?' Get mns_usl ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
    @ ++j, 4 Say '- как выполнять данную проверку' Get mns1usl ;
      reader {| x| menu_reader( x, mm_ns1usl, A__MENUVERT,,, .f. ) }
    @ ++j, 4 Say 'Проверять наличие более 1 стом. первичного приема в году?' Get mpervich ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
    status_key( '^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода' )
    myread()
    If LastKey() == K_ESC
      Exit
    Elseif m1schet == 1
      If Empty( m1date_schet )
        func_error( 4, 'Обязательно должно быть заполнено поле ДАТА СЧЕТА!' )
        Loop
      Elseif pdate_schet[ 1 ] < 2016
        func_error( 4, 'Проверяется только после 2016 года!' )
        Loop
      Endif
    Endif
    If f_esc_enter( 'начала проверки' )
      sd := mdate_schet ; sl := m1logic
      mywait()
      dbCreate( cur_dir() + 'tmp', { ;
        { 'schet', 'N', 6, 0 }, ;
        { 'kod', 'N', 7, 0 } } )
      dbCreate( cur_dir() + 'tmpk', { ;
        { 'rec', 'N', 7, 0 }, ;
        { 'name', 'C', 100, 0 } } )
      Use ( cur_dir() + 'tmp' ) new
      Index On Str( FIELD->schet, 6 ) + Str( FIELD->kod, 7 ) to ( cur_dir() + 'tmp' )
      Use ( cur_dir() + 'tmpk' ) new
      Index On Str( FIELD->rec, 7 ) to ( cur_dir() + 'tmpk' )
      fl_exit := .f.
      fl_srok := ( msrok1 > 0 .or. msrok2 > 0 )
      r_use( dir_server() + 'kartotek',, 'KART' )
      r_use( dir_server() + 'ns_usl_k', dir_server() + 'ns_usl_k', 'NSK' )
      g_use( dir_server() + 'ns_usl',, 'NS' )
      If m1ns_usl == 2
        js := 0
        Go Top
        Do While !Eof()
          j := 0
          Select NSK
          find ( Str( ns->( RecNo() ), 6 ) )
          Do While nsk->kod == ns->( RecNo() ) .and. !Eof()
            ++j
            Skip
          Enddo
          Select NS
          g_rlock( forever )
          ns->kol := j
          js += j
          Unlock
          Skip
        Enddo
        If Empty( js )
          m1ns_usl := 0 ; mns_usl := Space( 3 )
        Endif
      Endif
      r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'MKB_10' )
      r_use( dir_server() + 'mo_uch',, 'UCH' )
      r_use( dir_server() + 'mo_otd',, 'OTD' )
      use_base( 'lusl' )
      use_base( 'luslc' )
      use_base( 'uslugi' )
      r_use( dir_server() + 'uslugi1', { dir_server() + 'uslugi1', ;
        dir_server() + 'uslugi1s' }, 'USL1' )
      r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
      r_use( dir_server() + 'mo_su',, 'MOSU' )
      r_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU' )
      Set Relation To u_kod into MOSU
      js := jh := jt := 0
      waitstatus( '<Esc> - прервать поиск' ) ; mark_keys( { '<Esc>' } )
      If m1schet == 1
        r_use( dir_server() + 'human_2',, 'HUMAN_2' )
        r_use( dir_server() + 'human_',, 'HUMAN_' )
        r_use( dir_server() + 'human', { dir_server() + 'humans', ;
          dir_server() + 'humankk' }, 'HUMAN' )
        Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
        r_use( dir_server() + 'schet_',, 'SCHET_' )
        r_use( dir_server() + 'schet', dir_server() + 'schetd', 'SCHET' )
        Set Relation To RecNo() into SCHET_
        Set Filter To Empty( schet_->IS_DOPLATA )
        dbSeek( pdate_schet[ 7 ], .t. )
        Do While schet->pdate <= pdate_schet[ 8 ] .and. !Eof()
          ++js
          Select HUMAN
          find ( Str( schet->kod, 6 ) )
          Do While human->schet == schet->kod .and. !Eof()
            ++jh
            @ MaxRow(), 1 Say lstr( js ) Color cColorSt2Msg
            @ Row(), Col() Say '/' Color 'W/R'
            @ Row(), Col() Say lstr( jh ) Color cColorStMsg
            If jt > 0
              @ Row(), Col() Say '/' Color 'W/R'
              @ Row(), Col() Say lstr( jt ) Color 'G+/R'
            Endif
            updatestatus()
            If Inkey() == K_ESC
              fl_exit := .t. ; Exit
            Endif
            jt := f1proch_proverka( jt )
            Select HUMAN
            Skip
          Enddo
          If fl_exit ; exit ; Endif
          Select SCHET
          Skip
        Enddo
      Else
        r_use( dir_server() + 'human_2',, 'HUMAN_2' )
        r_use( dir_server() + 'human_',, 'HUMAN_' )
        r_use( dir_server() + 'human', { dir_server() + 'humann', ;
          dir_server() + 'humankk' }, 'HUMAN' )
        Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
        dbSeek( '1', .t. )
        Do While human->tip_h < B_SCHET .and. !Eof()
          If iif( m1schet == 3, Empty( human_->reestr ), !Empty( human_->reestr ) ) .and. Year( human->k_data ) > 2017
            ++jh
            @ MaxRow(), 1 Say lstr( jh ) Color cColorStMsg
            If jt > 0
              @ Row(), Col() Say '/' Color 'W/R'
              @ Row(), Col() Say lstr( jt ) Color 'G+/R'
            Endif
            updatestatus()
            If Inkey() == K_ESC
              fl_exit := .t. ; Exit
            Endif
            jt := f1proch_proverka( jt )
          Endif
          Select HUMAN
          Skip
        Enddo
      Endif
      j := tmp->( LastRec() )
      Close databases
      If fl_exit
        // ничего - просто выход
      Elseif j == 0
        func_error( 4, 'Проверка проведена успешно! Нарушений нет.' )
      Else
        mywait()
        r_use( dir_server() + 'mo_otd',, 'OTD' )
        r_use( dir_server() + 'schet_',, 'SCHET_' )
        r_use( dir_server() + 'schet',, 'SCHET' )
        Set Relation To RecNo() into SCHET_
        r_use( dir_server() + 'human_',, 'HUMAN_' )
        r_use( dir_server() + 'human', dir_server() + 'humank', 'HUMAN' )
        Set Relation To RecNo() into HUMAN_, To otd into OTD
        Use ( cur_dir() + 'tmp' ) new
        Set Relation To Str( kod, 7 ) into HUMAN, To schet into SCHET
        Index On schet->nomer_s + Str( tmp->schet, 6 ) + Upper( Left( human->fio, 20 ) ) to ( cur_dir() + 'tmp' )
        Use ( cur_dir() + 'tmpk' ) new
        Index On Str( FIELD->rec, 7 ) to ( cur_dir() + 'tmpk' )
        fp := FCreate( name_file )
        n_list := 1
        tek_stroke := 0
        add_string( '' )
        If m1schet == 1
          add_string( Center( Expand( 'РЕЗУЛЬТАТ ПРОВЕРКИ СЧЕТОВ' ), sh ) )
          add_string( Center( pdate_schet[ 4 ], sh ) )
        Else
          add_string( Center( 'РЕЗУЛЬТАТ ПРОВЕРКИ ПО НЕВЫПИСАННЫМ СЧЕТАМ' + ;
            iif( m1schet == 2, ' (по реестрам)', '' ), sh ) )
        Endif
        titlen_uch( st_a_uch, sh )
        add_string( '' )
        old_s := 0
        Select TMP
        Go Top
        Do While !Eof()
          verify_ff( HH, .t., sh )
          If !( old_s == tmp->schet )
            add_string( '' )
            add_string( 'СЧЕТ № ' + RTrim( schet_->nschet ) )
            add_string( Replicate( '=', 22 ) )
          Endif
          add_string( '' )
          add_string( iif( m1schet == 1, lstr( human_->schet_zap ) + '. ', '' ) + ;
            AllTrim( human->fio ) + ', ' + full_date( human->date_r ) + ;
            iif( Empty( otd->SHORT_NAME ), '', ' [' + AllTrim( otd->SHORT_NAME ) + ']' ) + ;
            ' ' + date_8( human->n_data ) + '-' + date_8( human->k_data ) )
          Select TMPK
          find ( Str( tmp->( RecNo() ), 7 ) )
          Do While tmpk->rec == tmp->( RecNo() ) .and. !Eof()
            add_string( Space( 10 ) + RTrim( tmpk->name ) )
            Skip
          Enddo
          old_s := tmp->schet
          Select TMP
          Skip
        Enddo
        FClose( fp )
        Close databases
        viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
      Endif
    Endif
    Exit
  Enddo
  Close databases
  RestScreen( buf ) ; SetColor( tmp_color )

  Return Nil

//  
Function o_pr_vr_as( reg )

  Static sj := 1
  Local mas_pmt := { ;
    'Проверка по ~невыписанным счетам', ;
    'Проверка по дате ~выписки счета' }
  Local mas_msg := { ;
    'Проверка на отсутствие кода по невыписанным счетам', ;
    'Проверка на отсутствие кода по дате выписки счета' }
  Local i, j, k, arr, fl, fl_exit := .f., buf := save_maxrow(), ;
    s, sh, HH := 57, arr_title, name_file := 'proverka.txt', ;
    arr_usl := {}, lcount_uch

  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5,,, @lcount_uch ) ) == NIL
    Return Nil
  Endif
  If ( j := popup_prompt( T_ROW, T_COL - 5, sj, mas_pmt, mas_msg ) ) == 0
    Return Nil
  Endif
  sj := j
  If j == 2 .and. ( arr := year_month() ) == NIL
    Return Nil
  Endif
  If ( k := f_alert( { 'Каким образом производить проверку на отсутствие кодов персонала.', ;
      'Выберите действие:' }, ;
      { ' По ~всем услугам ', ;
      ' ~Исключая некоторые услуги ' }, ;
      1, 'N+/BG', 'R/BG',,, col1menu ) ) == 0
    Return Nil
  Elseif k == 2
    dbCreate( cur_dir() + 'tmp', { ;
      { 'U_KOD',    'N',      4,      0 }, ;  // код услуги
      { 'U_SHIFR',    'C',     10,      0 }, ;  // шифр услуги
      { 'U_NAME',     'C',     65,      0 } } )  // наименование услуги
    Use ( cur_dir() + 'tmp' )
    Index On Str( FIELD->u_kod, 4 ) to ( cur_dir() + 'tmpk' )
    Index On fsort_usl( FIELD->u_shifr ) to ( cur_dir() + 'tmpn' )
    Close databases
    ob2_v_usl()
    Use ( cur_dir() + 'tmp' )
    dbEval( {|| AAdd( arr_usl, tmp->u_kod ) } )
    Use
  Endif
  waitstatus( '<Esc> - прервать поиск' ) ; mark_keys( { '<Esc>' } )
  dbCreate( cur_dir() + 'tmp', { { 'rec', 'N', 7, 0 } } )
  Use ( cur_dir() + 'tmp' ) new
  If j == 1
    r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human', dir_server() + 'humann', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    dbSeek( '1', .t. )
    Do While human->tip_h < B_SCHET .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If human_->oplata < 9 .and. f_is_uch( st_a_uch, human->lpu )
        fl := .f.
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          If AScan( arr_usl, hu->u_kod ) == 0
            If reg == 1
              If hu->kod_vr == 0
                fl := .t. ; Exit
              Endif
            Else
              If hu->kod_as == 0
                fl := .t. ; Exit
              Endif
            Endif
          Endif
          Select HU
          Skip
        Enddo
        If fl
          Select TMP
          Append Blank
          tmp->rec := human->( RecNo() )
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
  Elseif j == 2
    r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human', dir_server() + 'humans', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server() + 'schet_',, 'SCHET_' )
    r_use( dir_server() + 'schet', dir_server() + 'schetd', 'SCHET' )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( arr[ 7 ], .t. )
    Do While schet->pdate <= arr[ 8 ] .and. !Eof()
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human_->oplata < 9 .and. f_is_uch( st_a_uch, human->lpu )
          fl := .f.
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            If AScan( arr_usl, hu->u_kod ) == 0
              If reg == 1
                If hu->kod_vr == 0
                  fl := .t. ; Exit
                Endif
              Else
                If hu->kod_as == 0
                  fl := .t. ; Exit
                Endif
              Endif
            Endif
            Select HU
            Skip
          Enddo
          If fl
            Select TMP
            Append Blank
            tmp->rec := human->( RecNo() )
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
      If fl_exit ; exit ; Endif
      Select SCHET
      Skip
    Enddo
    Select SCHET
    Set Index To
  Endif
  If tmp->( LastRec() ) > 0
    mywait()
    s := { 'Отделение', 'Номер и дата счета' }[ j ]
    arr_title := { ;
      '─────────────────────────────────────────────────┬───────────────────┬──────────', ;
      '              Ф.И.О. больного                    │'   + PadC( s, 19 ) +  '│  Сумма   ', ;
      '─────────────────────────────────────────────────┴───────────────────┴──────────' }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( '' )
    add_string( Center( 'Список больных, у которых в оказанных услугах', sh ) )
    add_string( Center( 'отсутствует код ' + { 'врача', 'ассистента' }[ reg ], sh ) )
    add_string( '' )
    If j == 1
      add_string( Center( '[ по невыписанным счетам ]', sh ) )
    Else
      add_string( Center( '[ по дате выписки счета ]', sh ) )
      add_string( Center( arr[ 4 ], sh ) )
    Endif
    titlen_uch( st_a_uch, sh, lcount_uch )
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    //
    Select HUMAN
    Set Index To
    r_use( dir_server() + 'mo_otd',, 'OTD' )
    Select TMP
    Set Relation To rec into HUMAN
    Index On Upper( human->fio ) to ( cur_dir() + 'tmp' )
    Go Top
    i := 0
    Do While !Eof()
      s := Str( ++i, 4 ) + '. ' + Left( human->fio, 43 ) + ' '
      If j == 1
        Select OTD
        Goto ( human->otd )
        s += otd->short_name
      Else
        Select SCHET
        Goto ( human->schet )
        s += schet_->NSCHET + ' ' + date_8( schet_->DSCHET )
      Endif
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( s + put_kope( human->cena_1, 11 ) )
      Select TMP
      Skip
    Enddo
    Close databases
    FClose( fp )
    viewtext( name_file,,,, .f.,,, 2 )
  Else
    func_error( 4, 'Не обнаружено услуг с незанесенным персоналом!' )
  Endif
  Close databases
  rest_box( buf )

  Return Nil

//   Вывод списка принятых больных конкретным врачом за день
Function i_vr_boln()

  Local sh := 80, HH := 60, old_d := '', begin_date, end_date, arr_m, ;
    name_file := 'lech_vr.txt', i, j, s, skol := 0, ab := {}

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If !input_perso( T_ROW, T_COL - 5 )
    Return Nil
  Endif
  begin_date := arr_m[ 7 ]
  end_date   := arr_m[ 8 ]
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  s := ' Ф.И.О. и должность врача: ' + AllTrim( glob_human[ 2 ] ) + ' [' + lstr( glob_human[ 5 ] ) + ']'
  If Len( glob_human ) > 5 .and. !Empty( glob_human[ 6 ] )
    s += ' (' + glob_human[ 6 ] + ')'       // должность
  Endif
  add_string( Center( s, sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( '' )
  r_use( dir_server() + 'uslugi',, 'USL' )
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  r_use( dir_server() + 'human',, 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  r_use( dir_server() + 'human_u', dir_server() + 'human_uv', 'HU' )
  dbSeek( Str( glob_human[ 1 ], 4 ) + begin_date, .t. )
  Do While hu->kod_vr == glob_human[ 1 ] .and. hu->date_u <= end_date .and. !Eof()
    human->( dbGoto( hu->kod ) )
    If human_->oplata < 9
      If !( old_d == hu->date_u )
        If !Empty( old_d )
          For i := 1 To Len( ab )
            s := Str( i, 5 ) + '. ' + AllTrim( ab[ i, 2 ] ) + ' ('
            For j := 1 To Len( ab[ i, 3 ] )
              usl->( dbGoto( ab[ i, 3, j ] ) )
              s += AllTrim( usl->shifr ) + ','
            Next
            s := Left( s, Len( s ) -1 ) + ')'
            verify_ff( HH, .t., sh )
            add_string( s )
            ++skol
          Next
        Endif
        verify_ff( HH - 1, .t., sh )
        old_d := hu->date_u ; ab := {}
        add_string( full_date( c4tod( old_d ) ) )
      Endif
      If ( i := AScan( ab, {| x| x[ 1 ] == human->kod_k } ) ) == 0
        AAdd( ab, { human->kod_k, human->fio, {} } ) ; i := Len( ab )
      Endif
      If ( j := AScan( ab[ i, 3 ], hu->u_kod ) ) == 0
        AAdd( ab[ i, 3 ], hu->u_kod )
      Endif
    Endif
    Select HU
    Skip
  Enddo
  If !Empty( old_d )
    For i := 1 To Len( ab )
      s := Str( i, 5 ) + '. ' + AllTrim( ab[ i, 2 ] ) + ' ('
      For j := 1 To Len( ab[ i, 3 ] )
        usl->( dbGoto( ab[ i, 3, j ] ) )
        s += AllTrim( usl->shifr ) + ','
      Next
      s := Left( s, Len( s ) -1 ) + ')'
      verify_ff( HH, .t., sh )
      add_string( s )
      ++skol
    Next
  Endif
  If skol > 0
    add_string( 'Всего больных: ' + lstr( skol ) )
  Endif
  FClose( fp )
  Close databases
  viewtext( name_file,,,, .t.,,, 2 )

  Return Nil

//   27.10.13
Function poisk_rassogl()

  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., sh := 80, HH := 80, reg_print := 5, pi1, fl_parakl, ;
    name_file := 'rassogl.txt', lcount_uch, sschet

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If ( pi1 := popup_prompt( T_ROW, T_COL - 5, 2, ;
      { 'По дате ~окончания лечения', 'По дате ~выписки счета' } ) ) == 0
    Return Nil
  Endif
  mywait()
  Private kol_err := 0
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( '' )
  add_string( Center( 'Обнаруженные рассогласования в базах данных', sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  r_use( dir_server() + 'mo_uch',, 'UCH' )
  r_use( dir_server() + 'mo_otd',, 'OTD' )
  r_use( dir_server() + 'uslugi',, 'USL' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  Set Relation To u_kod into USL
  If pi1 == 1 // по дате окончания лечения
    begin_date := arr_m[ 5 ]
    end_date := arr_m[ 6 ]
    r_use( dir_server() + 'schet_',, 'SCHET_' )
    r_use( dir_server() + 'schet',, 'SCHET' )
    Set Relation To RecNo() into SCHET_
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
    Set Relation To schet into SCHET, To RecNo() into HUMAN_
    dbSeek( DToS( begin_date ), .t. )
    Do While human->k_data <= end_date .and. !Eof()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If human_->oplata < 9
        f1_poisk_rassogl()
      Endif
      Select HUMAN
      Skip
    Enddo
  Else
    begin_date := arr_m[ 7 ]
    end_date := arr_m[ 8 ]
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human', dir_server() + 'humans', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server() + 'schet_',, 'SCHET_' )
    r_use( dir_server() + 'schet', dir_server() + 'schetd', 'SCHET' )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    dbSeek( begin_date, .t. )
    Do While schet->pdate <= end_date .and. !Eof()
      sschet := 0
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod .and. !Eof()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If human_->oplata < 9
          f1_poisk_rassogl()
        Endif
        sschet += human->cena_1
        Select HUMAN
        Skip
      Enddo
      If fl_exit ; exit ; Endif
      If !( Round( sschet, 2 ) == Round( schet->summa, 2 ) )
        ++kol_err
        add_string( 'Счет № ' + AllTrim( schet_->NSCHET ) + ;
          ' от ' + full_date( schet_->DSCHET ) + 'г.' )
        add_string( Space( 2 ) + 'сумма случаев не равна сумме счёта ' + lstr( sschet, 2 ) + '!=' + lstr( schet->summa, 2 ) )
      Endif
      Select SCHET
      Skip
    Enddo
  Endif
  Close databases
  If fl_exit
    add_string( Expand( 'ПРОЦЕСС ПРЕРВАН' ) )
  Endif
  FClose( fp )
  rest_box( buf )
  If kol_err > 0
    viewtext( devide_into_pages( name_file, 80, 80 ),,,, ( sh > 80 ),,, reg_print )
  Else
    n_message( { '', 'Рассогласований не обнаружено!' } )
  Endif

  Return Nil

// 02.04.26
Function  poisk_rassogl_schet_reestr()

  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
    fl_exit := .f., sh := 80, HH := 80, reg_print := 5, pi1, fl_parakl, ;
    name_file := 'rassoglr.txt', lcount_uch, sschet

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  //If ( pi1 := popup_prompt( T_ROW, T_COL - 5, 2, ;
  //    { 'По дате ~окончания лечения', 'По дате ~выписки счета' } ) ) == 0
  //  Return Nil
  //Endif
  mywait()
  Private kol_err := 0
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( '' )
  add_string( Center( 'Обнаруженные рассогласования в базах данных', sh ) )
  //r_use( dir_server() + 'mo_regi', , 'MO_REGI' )
  r_use( dir_server() + 'mo_rees', , 'MO_REES')  // список реестров счедений с 2026-реестров-счетов
  index on str( FIELD->nschet, 6 ) to tmp_rees for nyear == 2026
  r_use( dir_server() + 'mo_rhum', , 'MO_RHUM')  // список пациентов в реестре
  index on str( FIELD->reestr, 6 )+str( FIELD->rees_zap, 6 ) to tmp_rhum
  r_use( dir_server() + 'human', , 'HUMAN' )     // случаи
  index on str( FIELD->schet, 6 ) to tmp_humn
  r_use( dir_server() + 'human_', , 'HUMAN_' )   // вторая часть - несер ссылки на реестр и счет
  index on str( FIELD->reestr, 6 )+str( FIELD->rees_zap, 6 ) to tmp_hum_
  r_use( dir_server() + 'schet_',, 'SCHET_' )    // счет
  index on str( FIELD->kod_xml, 6 ) to tmp_sche_
  r_use( dir_server() + 'schet',, 'SCHET' )      // вторая часть счета    
  r_use( dir_server() + 'mo_xml',, 'MO_XML' )    // список файлов обмена
  index on str( FIELD->reestr, 6 ) + str( FIELD->tip_in, 2 ) to tmp_XML
  //
  begin_date := arr_m[ 5 ]
  end_date := arr_m[ 6 ]
  select MO_REES
  Do While !Eof()
    // цикл по реестрам
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    if mo_rees->dschet >= begin_date .and. mo_rees->dschet <= end_date
      mo_rees_kod       := mo_rees->kod       // код реестра, номер записи
      mo_rees_nschet    := mo_rees->nschet    // номер реестра сведений;уникален для отчетных периодов, принадлежащих одному календарному году;
      mo_rees_kod_xml   := mo_rees->kod_xml   // ссылка на файл 'mo_xml'
      mo_rees_numb_out  := mo_rees->numb_out  // номер отправки в ТФОМС, сколько раз всего записывали файл на носитель 
      mo_rees_kol       := mo_rees->kol       // количество пациентов в реестре
      mo_rees_nomer_s   := mo_rees->nomer_s   // если реестр счета, то номер счета
      mo_rees_res_tfoms := mo_rees->res_tfoms // результат проверки реестра сета в ТФОМС ( 1-счет принят, 2-ошибка всего реестра, 3-ошибка в записях реестра)
      mo_rees_NAME_XML  := mo_rees->NAME_XML  // имя XML-файла без расширения (и ZIP-архива)
      add_string( '' )
      // идем проверять по файлу  MO_RHUM
      if mo_rees_res_tfoms == 1 // счет принят
        add_string( 'Реестр счетов ' +lstr(mo_rees_kod ) +' ' + alltrim(mo_rees_NAME_XML) + ' счет ' + alltrim(mo_rees_nomer_s) + ' ПРИНЯТ')
        // проверим в файл SCHET
        select MO_XML
        goto mo_rees_kod_xml
        if mo_xml->reestr != mo_rees_kod
          kol_err++
          add_string('(4) MO_XML->reestr ' + lstr(MO_XML->reestr) + ' mo_rees->kod ' + lstr(mo_rees->kod) )
        endif
        // ищим ответ на reestr в xml  
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! выбираем от реестра
        select MO_RHUM
        find(str(mo_rees_kod,6)) 
        t_num := 0
        do while mo_rhum->reestr == mo_rees_kod .and. !eof()
          ++t_num
          /*if  mo_rhum->oplata != 1 //- в счет
            kol_err++
            add_string( 'Признак НЕ в СЧЕТЕ ' + 'Запись MO_RHUM ' + lstr(mo_rhum->(recno())) )
          endif*/  
          if t_num == mo_rhum->rees_zap
            // ОК - переходим по прямой ссылке в HUMAN и сверяем реестр
            select HUMAN_
            goto mo_rhum->KOD_HUM
            // проверяем данные Реестра
            if mo_rhum->rees_zap == human_->rees_zap .and. mo_rhum->reestr == human_->reestr
              // ОК
            else  
              kol_err++
              add_string('(1) REESTR в базе HUMAN_ ' + lstr(human_->reestr) + ' REESTR в базе MO_RHUM '+lstr(mo_rhum->reestr) )
              add_string('   REES_ZAP в базе HUMAN_ ' + lstr(human_->rees_zap) + ' REES_ZAP в базе MO_RHUM '+lstr(mo_rhum->rees_zap) + ;
                         ' Запись в базе HUMAN_ '+lstr(mo_rhum->KOD_HUM) )
              add_string('   Schet_ZAP в базе HUMAN_ ' + lstr(human_->schet_zap)) 
            Endif
            select HUMAN
            goto mo_rhum->KOD_HUM
            if human->tip_H != 4 // в счете 
              kol_err++
              add_string('(2) Запись в базе HUMAN ' + lstr(mo_rhum->KOD_HUM) + 'НЕ в СЧЕТЕ - поле TIP_H' + lstr(mo_rhum->KOD_HUM))
            endif   
            if HUMAN_->rees_zap != human_->schet_zap
              kol_err++
              add_string( '(3) HUMAN_->rees_zap ' + lstr( HUMAN_->rees_zap ) + ' HUMAN_->schet_zap ' + lstr( HUMAN_->schet_zap ) + ' Запись в базе HUMAN_ '+lstr( mo_rhum->KOD_HUM ) )
            endif
          else
            kol_err++
            add_string( '(5) Номер порядковый ' + lstr(t_num) + 'Номер в базе MO_RHUM '+lstr(mo_rhum->rees_zap) + 'Запись MO_RHUM ' + lstr(mo_rhum->(recno())))
          endif  
          select MO_RHUM
          skip 
        enddo  
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   Выбираем от HUMAN
        select HUMAN_
        find(str(mo_rees_kod,6)) 
        t_num := 0
        do while human_->reestr == mo_rees_kod .and. !eof()
          ++t_num
         if t_num == human_->rees_zap
            // ОК -
            if HUMAN_->rees_zap != human_->schet_zap
              kol_err++
              add_string('(00-1) HUMAN_->rees_zap ' + lstr(HUMAN_->rees_zap) + ' HUMAN_->schet_zap ' + lstr(HUMAN_->schet_zap) + ' Запись в базе HUMAN_ '+lstr(mo_rhum->KOD_HUM))
            endif
         else
           kol_err++
           add_string( '(00-2) REESTR в базе HUMAN_ ' + lstr(human_->reestr) )
           add_string( '     Номер порядковый ' + lstr(t_num) + ' REES_ZAP в базе HUMAN_ ' + lstr(human_->rees_zap) + ' Запись в базе HUMAN_ '+lstr(human_->(recno())) )
           add_string('   Schet_ZAP в базе HUMAN_ ' + lstr(human_->schet_zap)) 
         endif
          select HUMAN_
          skip 
        enddo  
        // Другой вариант прохода - начинаем со счетов 
        // нужно найти файл счет - он через ответ в  XML
        select MO_XML
        find(str(mo_rees_kod,6)+str(8,2)) //ФЛК 
        // нужно найти файл счет - он через ответ в  XML
        if alltrim(mo_rees_NAME_XML) != substr(alltrim(mo_xml->FNAME),2)
          kol_err++
          add_string( '(XX-2)  ' + alltrim(mo_rees_NAME_XML) + '!= ' + alltrim(mo_xml->FNAME) + ' ' +lstr(mo_xml->kod))
        else  
          select schet_
          find(str(mo_xml->kod,6)) 
          if found()   
            NN_schet := schet_->(recno())  
            // human->schet и human_->schet_zap
            select HUMAN
            find(str(nn_schet,6))
            do while human->schet == nn_schet .and. !eof()
               select HUMAN_
               goto human->kod
               if human_->schet_zap != human_->rees_zap
                 add_string( '(XX-3)  ' + lstr(human_->schet_zap) + '!= ' + lstr(human_->rees_zap) + ' ' +lstr(human->kod))
               endif    
               select HUMAN
               skip
            enddo


          else
            add_string( '(XX-1)  не найден' +lstr(mo_xml->kod))
          endif  
        endif  
      elseif mo_rees_res_tfoms == 2 .or. mo_rees_res_tfoms == 3 // ОШИБКА - людей в реестре не должно быть
        add_string( 'Реестр счетов ' +lstr(mo_rees_kod ) + ' ' + alltrim(mo_rees_NAME_XML) + ' НЕ ПРИНЯТ ТФОМС')
        //
        select MO_RHUM
        find(str(mo_rees_kod,6)) 
        t_num := 0
        do while mo_rhum->reestr == mo_rees_kod .and. !eof()
          ++t_num
           if  mo_rhum->oplata == 1 //- в счет
            kol_err++
            add_string( 'Признак СЧЕТ ' + 'Запись MO_RHUM ' + lstr(mo_rhum->(recno())) )
          endif  
          if t_num == mo_rhum->rees_zap
            // ОК - переходим по прямой ссылке в HUMAN и сверяем реестр
            select HUMAN_
            goto mo_rhum->KOD_HUM
            // проверяем данные Реестра
            if mo_rhum->rees_zap == human_->rees_zap .and. mo_rhum->reestr == human_->reestr
              // ОК
            else  
              kol_err++
              add_string('(10) REESTR в базе HUMAN_ ' + lstr(human_->reestr) + ' REESTR в базе MO_RHUM '+lstr(mo_rhum->reestr) )
              add_string('   REES_ZAP в базе HUMAN_ ' + lstr(human_->rees_zap) + ' REES_ZAP в базе MO_RHUM '+lstr(mo_rhum->rees_zap) + ;
                         ' Запись в базе HUMAN_ '+lstr(mo_rhum->KOD_HUM) )
            Endif
            select HUMAN
            goto mo_rhum->KOD_HUM
            if human->tip_H == 4 // в счете 
              kol_err++
              add_string('(8) Запись в базе HUMAN ' + lstr(mo_rhum->KOD_HUM) + 'в СЧЕТЕ - поле TIP_H' + lstr(mo_rhum->KOD_HUM))
            endif   
            if human_->schet_zap > 0
              kol_err++
              add_string('(7) HUMAN_->schet_zap ' + lstr(HUMAN_->schet_zap) + ' Запись в базе HUMAN_ '+lstr(mo_rhum->KOD_HUM))
            endif
          else
            kol_err++
            add_string( '(9) Номер порядковый ' + lstr(t_num) + 'Номер в базе MO_RHUM '+lstr(mo_rhum->rees_zap) + 'Запись MO_RHUM ' + lstr(mo_rhum->(recno())) )
          endif  
          select MO_RHUM
          skip 
        enddo  
      else
        add_string( 'Реестр счетов ' +lstr(mo_rees_kod ) + ' '  + alltrim(mo_rees_NAME_XML) + ' ЗАПИСАН - НЕТ ОТВЕТА ТФОМС !!!!!!!!!!!!!!!!!!!!!!')
           //
        select MO_RHUM
        find(str(mo_rees_kod,6)) 
        t_num := 0
        do while mo_rhum->reestr == mo_rees_kod .and. !eof()
          ++t_num
          if  mo_rhum->oplata == 1 //- в счет
            kol_err++
            add_string( 'Признак СЧЕТ ' + 'Запись MO_RHUM ' + lstr(mo_rhum->(recno())) )
          endif  
          if t_num == mo_rhum->rees_zap
            // ОК - переходим по прямой ссылке в HUMAN и сверяем реестр
            select HUMAN_
            goto mo_rhum->KOD_HUM
            // проверяем данные Реестра
            if mo_rhum->rees_zap == human_->rees_zap .and. mo_rhum->reestr == human_->reestr
              // ОК
            else  
              kol_err++
              add_string('(11) REESTR в базе HUMAN_ ' + lstr(human_->reestr) + ' REESTR в базе MO_RHUM '+lstr(mo_rhum->reestr) )
              add_string('   REES_ZAP в базе HUMAN_ ' + lstr(human_->rees_zap) + ' REES_ZAP в базе MO_RHUM '+lstr(mo_rhum->rees_zap) + ;
                         ' Запись в базе HUMAN_ '+lstr(mo_rhum->KOD_HUM) )
            Endif
            select HUMAN
            goto mo_rhum->KOD_HUM
            if human->tip_H == 4 // в счете 
              kol_err++
              add_string('(12) Запись в базе HUMAN ' + lstr(mo_rhum->KOD_HUM) + ' в СЧЕТЕ - поле TIP_H ' + lstr(mo_rhum->KOD_HUM))
            endif   
            if human_->schet_zap > 0
              kol_err++
              add_string('(13) HUMAN_->schet_zap ' + lstr(HUMAN_->schet_zap) + ' Запись в базе HUMAN_ '+lstr(mo_rhum->KOD_HUM))
            endif
          else
            kol_err++
            add_string( '(14) Номер порядковый ' + lstr(t_num) + 'Номер в базе MO_RHUM '+lstr(mo_rhum->rees_zap) + ' Запись MO_RHUM ' + lstr(mo_rhum->(recno()))+;
              ' Запись в базе HUMAN_ '+lstr(mo_rhum->KOD_HUM) )
            // заглянем в HUMAN_
             add_string('   REES_ZAP в базе HUMAN_ ' + lstr(human_->rees_zap) + ' REES_ZAP в базе MO_RHUM '+lstr(mo_rhum->rees_zap))
             add_string('   Schet_ZAP в базе HUMAN_ ' + lstr(human_->schet_zap)) 
         endif  
          select MO_RHUM
          skip 
        enddo  
      endif  
    endif
    Select MO_REES
    Skip
  Enddo
  Close databases
  If fl_exit
    add_string( Expand( 'ПРОЦЕСС ПРЕРВАН' ) )
  Endif
  FClose( fp )
  rest_box( buf )
  If kol_err > 0
    viewtext( devide_into_pages( name_file, 80, 80 ),,,, ( sh > 80 ),,, reg_print )
  Else
    n_message( { '', 'Рассогласований не обнаружено!' } )
  Endif

  Return Nil

//15.03.26
function podbor_inogorodnie()  

  local t_smo, t_okato, t_kod_k,  t_max_data 
  
  local buf := save_maxrow(), sh := 80, HH := 80, reg_print := 5,  ;
    name_file := 'inogorod.txt' 
  Local arr_title := { ;
      '─────────────────────────────────────────────────┬──────────┬──────────', ;
      '                                                 │   Дата   | Вероятное', ;    
      '              Ф.И.О. пациента                    │ рождения │   СМО    ', ;
      '─────────────────────────────────────────────────┴──────────┴──────────' }
  sh := Len( arr_title[ 1 ] )
  
  stat_msg( 'Поиск иногородиних по счетам 2023-2025г.' )
  dbCreate( cur_dir() + 'tmp_inog', { ;
        { 'kod_k', 'N', 7,  0 }, ;
        { 'smo',   'C', 5,  0 }, ;  
        { 'okato', 'C', 5,  0 }, ;
        { 'IN_NO', 'N', 1,  0 }, ;  // 1 - иногород в картотеке
        { 'FIO',   'C', 50, 0 }, ;
        { 'DR',    'D',  8, 0 } })  

  Use ( cur_dir() + 'tmp_inog' ) new
  index on FIELD->kod_k to tmp_kk 
  r_use( dir_server() + 'schet_', , 'SCHET_' )
  r_use( dir_server() + 'human', dir_server() + 'humans'  , 'HUMAN' )
  //Index On Str( FIELD->schet, 6 ) + Str( FIELD->tip_h, 1 ) + Upper( SubStr( FIELD->fio, 1, 20 ) ) to ( dir_server() + 'humans' ) progress
  r_use( dir_server() + 'human_',  , 'HUMAN_' )
  r_use( dir_server() + 'kartote_', , 'KARTOTE_' )
  select SCHET_
  go Top
  do while !eof()
    if schet_->nyear == 2023 .or. schet_->nyear == 2024 .or. schet_->nyear == 2025 
    // берем 25 24 23 года  
      if alltrim(schet_->smo) == '34'
        // берем иногородние счета  
        select HUMAN 
        find (str(schet_->(recno()),6))
        do while schet_->(recno()) == human->schet .and. !eof()
          select human_
          goto (human->kod)
         // СОЗДАЕМ СПИСОВ ВОЗМОЖНЫХ ИНОГОРОДНИХ
          SELECT tmp_inog
          find (human->kod_k )
          if !found()
            APPEND Blank
            tmp_inog->smo   := human_->smo
            tmp_inog->okato := human_->okato
            tmp_inog->kod_k := human->kod_k 
          endif  
           //
          select HUMAN  
          skip
        enddo 
      endif 
    endif  
    select SCHET_ 
    skip
  enddo  
  // выборка закончена - вторичная проверка - может они в картотеке и есть иногородние
  select tmp_inog
  go top
  do while !eof()
    select KARTOTE_
    goto tmp_inog->kod_k 
    if tmp_inog->smo == kartote_->smo .and. tmp_inog->okato == kartote_->kvartal_d 
      select tmp_inog
      g_rlock( forever )
      tmp_inog->IN_NO := 1  
      Unlock
    endif
    select tmp_inog
    skip
  enddo
  // 3-я проверка - может они потом были наши ? (до 2026 года)
  // Index On Str( if( FIELD->kod > 0, FIELD->kod_k, 0 ), 7 ) + Str( FIELD->tip_h, 1 ) to ( dir_server() + 'humankk' ) progress
  human->(dbCloseArea())
  r_use( dir_server() + 'human', dir_server() + 'humankk'  , 'HUMAN' )
  select tmp_inog
  go top
  do while !eof()
    if tmp_inog->IN_NO < 1 
      t_max_data := stod('20220101')
      t_smo      := ''
      t_okato    := ''
      select HUMAN
      find (str(tmp_inog->kod_k,7))
      do while tmp_inog->kod_k == human->kod_k .and. !eof()
        if human->k_data > stod('20221231') .and. year(human->k_data) != 2026 .and. human->schet > 0
          if human->k_data > t_max_data
            t_max_data := human->k_data  
            select human_
            goto (human->kod)
            t_smo   := human_->smo
            t_okato := human_->okato 
          endif 
        endif  
        select HUMAN
        skip
      enddo
      select tmp_inog
      if tmp_inog->smo == t_smo .and. tmp_inog->okato == t_okato
        // последний точно иногородний
      else  
        if padr(alltrim(t_smo),2) == '34' .and.(t_okato == '18000' .or. empty(t_okato))
          // местный счет
          g_rlock( forever )
          tmp_inog->IN_NO := 2  
          Unlock
        endif
      endif  
    endif
    select tmp_inog
    skip
  enddo
  // открыть картотеку
  /*KARTOTE_->(dbCloseArea())
  g_use( dir_server() + 'kartote_', , 'KARTOTE_' )
  select tmp_inog
  go top
  do while !eof()
    if tmp_inog->IN_NO == 0
      select KARTOTE_
      goto tmp_inog->kod_k 
      g_rlock( forever )
      if padr(alltrim(t_smo),2) == '34'
        kartote_->smo := '34'
      else  
        kartote_->smo :=  tmp_inog->smo
      endif
      kartote_->kvartal_d := tmp_inog->okato
      Unlock
    endif 
    select tmp_inog
    skip
  enddo*/
  KARTOTE_->(dbCloseArea())
  g_use( dir_server() + 'kartotek', , 'KARTOTEK' )
  select tmp_inog
  go top
  do while !eof()
    if tmp_inog->IN_NO == 0 .or. tmp_inog->IN_NO == 1
      select KARTOTEK
      goto tmp_inog->kod_k 
      select tmp_inog
      g_rlock( forever )
      tmp_inog->fio := alltrim(KARTOTEK->fio)  
      tmp_inog->dr  := KARTOTEK->date_r
      Unlock
    endif 
    select tmp_inog
    skip
  enddo
  //
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  ttmp_inogor := ''
  select tmp_inog
  index on  FIELD->okato + FIELD->fio to ( cur_dir() + 'tmp_inog' ) for IN_NO == 0 .or. IN_NO == 1
  go top
  do while !eof()
    if ttmp_inogor != tmp_inog->okato
      ttmp_inogor := tmp_inog->okato
      add_string( tmp_inog->okato )
      add_string('------' + oktadretss( tmp_inog->okato))
    endif  
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( padr(tmp_inog->fio, 49) +' '+ full_date(tmp_inog->dr)+' '+tmp_inog->smo) 
    skip
  enddo
  FClose( fp )
  Close databases
  viewtext( name_file,,,, .t.,,, 2 )

  return nil
