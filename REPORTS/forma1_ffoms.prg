// информация по форма 1 ФФОМС (по счетам)
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 01.03.23 распечатка формы №1 из приказа ФОМС №146
FUNCTION forma1_ffoms()

  LOCAL mdate, i, j, k, d1, d2, arr_smo := {}, at1, at2, ta, fl_month, tmp, b1_1, a1_1, ;
    _bd, fl, b1, b2, a1, a2, lsmo, name_file := cur_dir + 'forma1', HH := 80, sh := 84

  PRIVATE arr_m

  IF ( arr_m := year_month(,,, 3 ) ) == NIL
    RETURN NIL
  ELSEIF arr_m[ 1 ] < 2018
    RETURN func_error( 4, 'Новый алгоритм создания данной формы введен с 2018 года!' )
  ENDIF
  WaitStatus( 'Сбор информации' )
  adbf := { { 'smo', 'N', 5, 0 }, ;
    { 's1', 'N', 1, 0 }, ;
    { 's2', 'N', 1, 0 }, ;
    { 'schet', 'N', 6, 0 }, ;
    { 'summa1', 'N', 15, 2 }, ; // за месяц
    { 'summa2', 'N', 15, 2 } } // снг
  dbCreate( cur_dir + 'tmp1', adbf )
  USE ( cur_dir + 'tmp1' ) new
  INDEX ON Str( smo, 5 ) + Str( s1, 1 ) + Str( s2, 1 ) to ( cur_dir + 'tmp1' )
  dbCreate( cur_dir + 'tmp1prot', adbf )
  USE ( cur_dir + 'tmp1prot' ) new
  INDEX ON Str( smo, 5 ) + Str( s1, 1 ) + Str( s2, 1 ) + Str( schet, 6 ) to ( cur_dir + 'tmp1prot' )
  //
  adbf := { { 'smo', 'N', 5, 0 }, ;
    { 'pz', 'N', 1, 0 }, ;
    { 'vid', 'N', 1, 0 }, ;
    { 'schet', 'N', 6, 0 }, ;
    { 'kol1', 'N', 15, 2 }, ; // за месяц
    { 'kol2', 'N', 15, 2 }, ; // снг
    { 'kol3', 'N', 6, 0 }, ; // за месяц
    { 'kol4', 'N', 6, 0 }, ; // снг
    { 'summa1', 'N', 15, 2 }, ; // за месяц
    { 'summa2', 'N', 15, 2 } } // снг
  dbCreate( cur_dir + 'tmp2', adbf )
  USE ( cur_dir + 'tmp2' ) new
  INDEX ON Str( smo, 5 ) + Str( vid, 1 ) + Str( pz, 1 ) to ( cur_dir + 'tmp2' )
  dbCreate( cur_dir + 'tmp2prot', adbf )
  USE ( cur_dir + 'tmp2prot' ) new
  INDEX ON Str( smo, 5 ) + Str( vid, 1 ) + Str( pz, 1 ) + Str( schet, 6 ) to ( cur_dir + 'tmp2prot' )
  dbCreate( cur_dir + 'tmp2pr_u', { { 'kod', 'N', 6, 0 }, ;
    { 'shifr', 'C', 20, 0 }, ;
    { 'kol', 'N', 15, 2 } } )
  USE ( cur_dir + 'tmp2pr_u' ) new
  INDEX ON Str( kod, 6 ) + shifr to ( cur_dir + 'tmp2pr_u' )
  adbf := { { 'smo', 'N', 5, 0 }, ;
    { 'kod_k', 'N', 7, 0 }, ;
    { 'enp', 'C', 16, 0 }, ;
    { 'pz', 'N', 1, 0 }, ;
    { 'vid', 'N', 1, 0 }, ;
    { 'kol3', 'N', 6, 0 }, ; // за месяц
    { 'kol4', 'N', 6, 0 } }  // снг
  dbCreate( cur_dir + 'tmp3', adbf )
  USE ( cur_dir + 'tmp3' ) new
  // index on str(smo, 5) + str(vid, 1) + str(pz, 1) + str(kod_k, 7) to (cur_dir + 'tmp3')
  INDEX ON Str( smo, 5 ) + Str( vid, 1 ) + Str( pz, 1 ) + enp to ( cur_dir + 'tmp3' )
  //
  tmp := AClone( arr_m )
  tmp[ 5 ] := 1 // январь
  ret_days_for_akt_sverki( tmp, @b1_1, , @a1_1, )
  //
  d1 := 10

  d2 := 10

  ret_days_for_akt_sverki( arr_m, @b1, @b2, @a1, @a2 )
  Use_base( 'lusl' )
  Use_base( 'luslf' )

  R_Use( dir_server + 'mo_su', , 'MOSU' )
  R_Use( dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU' )
  SET RELATION TO u_kod into MOSU
  R_Use( dir_server + 'uslugi', , 'USL' )
  R_Use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
  SET RELATION TO u_kod into USL
  R_Use( dir_server + 'kartote2', , 'KART2' )
  R_Use( dir_server + 'human_', , 'HUMAN_' )
  R_Use( dir_server + 'human', dir_server + 'humans', 'HUMAN' )
  SET RELATION TO RecNo() into HUMAN_, TO kod_k into KART2
  R_Use( dir_server + 'schet_', , 'SCHET_' )
  R_Use( dir_server + 'schet', , 'SCHET' )
  SET RELATION TO RecNo() into SCHET_
  GO TOP
  DO WHILE !Eof()
    lsmo := Int( Val( schet_->smo ) )
    IF !Empty( lsmo ) .AND. schet_->NREGISTR == 0 // только зарегистрированные
      @ MaxRow(), 0 SAY PadR( '№ ' + AllTrim( schet_->NSCHET ) + ' от ' + date_8( schet_->DSCHET ), 28 ) COLOR 'W/R'
      mdate := date_reg_schet() // дата регистрации
      IF lsmo == 34
        IF Between( mdate, BoY( arr_m[ 5 ] ), arr_m[ 6 ] )
          fl_month := Between( mdate, arr_m[ 5 ], arr_m[ 6 ] )
          f1forma1_ffoms( 0, arr_m, arr_smo, fl_month, schet->summa, 0, 0 )
        ENDIF
      ELSE
        IF Between( mdate, BoY( arr_m[ 5 ] ) + b1_1, arr_m[ 6 ] + b2 )
          fl_month := Between( mdate, arr_m[ 5 ] + b1, arr_m[ 6 ] + b2 )
          f1forma1_ffoms( 0, arr_m, arr_smo, fl_month, schet->summa, b1, b2 )
        ENDIF
      ENDIF
      mdate1 := SToD( StrZero( schet_->nyear, 4 ) + StrZero( schet_->nmonth, 2 ) + '15' )
      fl_month := Between( mdate1, arr_m[ 5 ], arr_m[ 6 ] ) // отч.период текущий месяц
      IF arr_m[ 1 ] == 2022 .AND. arr_m[ 3 ] > 4
        d1 := 20
      ENDIF
      IF arr_m[ 1 ] == 2023 // .and. arr_m[3] > 1
        d1 := 20
      ENDIF
      IF arr_m[ 1 ] == 2018 .AND. arr_m[ 3 ] == 12
        d2 := 21
        IF glob_mo[ _MO_KOD_TFOMS ] == '134505'
          d2 := 23
        ENDIF
      ELSEIF arr_m[ 1 ] == 2019 .AND. arr_m[ 3 ] == 12
        d2 := 17
      ELSEIF arr_m[ 1 ] == 2020 .AND. arr_m[ 3 ] == 12
        d2 := 18
      ELSEIF arr_m[ 1 ] == 2021 .AND. arr_m[ 3 ] == 12
        d2 := 14
      ELSEIF arr_m[ 1 ] == 2022 .AND. arr_m[ 3 ] == 1
        d2 := 15
      ELSEIF arr_m[ 1 ] == 2022 .AND. arr_m[ 3 ] == 2
        d1 := 15
      ELSEIF arr_m[ 1 ] == 2022 .AND. arr_m[ 3 ] == 4
        d2 := 12
      ELSEIF arr_m[ 1 ] == 2022 .AND. arr_m[ 3 ] == 12
        d2 := 19
      ELSEIF arr_m[ 1 ] == 2023 .AND. arr_m[ 3 ] == 1
        d2 := 19
      ENDIF

      msmo := Int( Val( schet_->smo ) )
      fl := Between( mdate, BoY( arr_m[ 5 ] ), arr_m[ 6 ] + d2 ) ;// дата регистрации по 10 числа след.месяца
      .AND. Between( mdate1, BoY( arr_m[ 5 ] ), arr_m[ 6 ] ) // !!отч.период этот год

      IF fl
        IF !fl_month
          // счета за пред.отч.периоды с датой от 11 тек.месяца по 10 след.месяца
          fl_month := Between( mdate, arr_m[ 5 ] + d1, arr_m[ 6 ] + d2 )
        ENDIF
        IF msmo != 34 .AND. AScan( arr_smo, {| x| x[ 2 ] == msmo } ) == 0
          AAdd( arr_smo, { '', msmo } )
        ENDIF

        SELECT HUMAN
        find ( Str( schet->kod, 6 ) )
        DO WHILE human->schet == schet->kod .AND. !Eof()
          UpdateStatus()
          f2forma1_ffoms( msmo, fl_month )
          SELECT HUMAN
          SKIP
        ENDDO
      ENDIF
    ENDIF
    SELECT SCHET
    SKIP
  ENDDO
  @ MaxRow(), 0 SAY PadR( 'подсчёт снятий', 28 ) COLOR 'W/R'
  arr_h := {}
  R_Use( dir_server + 'mo_xml',, 'MO_XML' )
  R_Use( dir_server + 'mo_rak',, 'RAK' )
  SET RELATION TO KOD_XML into MO_XML
  R_Use( dir_server + 'mo_raks',, 'RAKS' )
  SET RELATION TO akt into RAK
  R_Use( dir_server + 'mo_raksh',, 'RAKSH' )
  SET RELATION TO kod_raks into RAKS
  INDEX ON Str( kod_h, 7 ) to ( cur_dir + 'tmp_raksh' ) FOR Between( mo_xml->dfile, BoY( arr_m[ 5 ] ), arr_m[ 6 ] + a2 )
  // for between(rak->DAKT,boy(arr_m[5]),arr_m[6])
  GO TOP
  DO WHILE !Eof()
    UpdateStatus()
    IF AScan( arr_h, raksh->kod_h ) == 0
      human->( dbGoto( raksh->kod_h ) )
      IF human->schet > 0 .AND. raksh->oplata > 1
        schet->( dbGoto( human->schet ) )
        IF schet_->NREGISTR == 0 // только зарегистрированные
          IF Int( Val( schet_->smo ) ) == 34
            fl_month := Between( mo_xml->dfile, arr_m[ 5 ], arr_m[ 6 ] )
            fl := ( mo_xml->dfile <= arr_m[ 6 ] )
          ELSE
            fl_month := Between( mo_xml->dfile, arr_m[ 5 ] + a1, arr_m[ 6 ] + a2 )
            fl := ( mo_xml->dfile >= BoY( arr_m[ 5 ] ) + a1_1 )
          ENDIF
          IF fl
            f1forma1_ffoms( 1, arr_m, arr_smo, fl_month, raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP )
          ENDIF
        ENDIF
      ENDIF
    ENDIF
    SELECT RAKSH
    SKIP
  ENDDO
  @ MaxRow(), 0 SAY PadR( 'подсчёт количества человек', 28 ) COLOR 'W/R'
  SELECT TMP2
  GO TOP
  DO WHILE !Eof()
    UpdateStatus()
    SELECT TMP3
    find ( Str( tmp2->smo, 5 ) + Str( tmp2->vid, 1 ) + Str( tmp2->pz, 1 ) )
    DO WHILE tmp3->smo == tmp2->smo .AND. tmp3->pz  == tmp2->pz .AND. tmp3->vid == tmp2->vid .AND. !Eof()
      UpdateStatus()
      IF tmp3->kol3 > 0
        tmp2->kol3++
      ENDIF
      IF tmp3->kol4 > 0
        tmp2->kol4++
      ENDIF
      SELECT TMP3
      SKIP
    ENDDO
    SELECT TMP2
    SKIP
  ENDDO
  CLOSE databases
  IF Len( arr_smo ) > 0
    ASort( arr_smo,,, {| x, y| x[ 2 ] < y[ 2 ] } )
    FOR i := 1 TO Len( arr_smo )
      IF ( j := AScan( glob_arr_smo, {| x| x[ 2 ] == arr_smo[ i, 2 ] } ) ) > 0
        arr_smo[ i, 1 ] := glob_arr_smo[ j, 1 ]
      ELSE
        arr_smo[ i, 1 ] := 'СМО с кодом ' + lstr( arr_smo[ i, 2 ] )
      ENDIF
    NEXT
  ENDIF
  ClrLine( MaxRow(), color0 ) ; mybell() ; mybell()
  ireg := popup_prompt( T_ROW, T_COL -5, 1, { 'Распечатка формы №1', 'Протокол создания формы №1' } )
  arr_title1 := { ;
    '     Раздел I. Использование средств обязательного медицинского страхования     ', ;
    '─────────────────────────────────────────────────┬───┬────────────┬─────────────', ;
    '                                                 │№№ │  Отчетный  │  Нарастающим', ;
    'Наименование показателя                          │стр│  месяц     │  итогом     ', ;
    '─────────────────────────────────────────────────┴───┴────────────┴─────────────' }
  at1 := {}
  at2 := {}
  AAdd( at1, { 'Сумма средств по счетам, предоставленным СМО', '', 0, 0 } )
  AAdd( at1, { 'к оплате в отчетном месяце (стр.06а+06б)', '06', 6, 0 } )
  AAdd( at1, { '  из них: за предыдущий месяц', '06а', 6, 1 } )
  AAdd( at1, { '          за отчетный месяц', '06б', 6, 2 } )
  AAdd( at1, { ' в т.ч. сумма средств, не принятых (удержанных)', '', 0, 0 } )
  AAdd( at1, { ' по результатам контроля объемов, сроков,качества', '', 0, 0 } )
  AAdd( at1, { ' и условий предоставления мед.помощи (07а+07б)', '07', 7, 0 } )
  AAdd( at1, { '  из них: за предыдущие месяцы', '07а', 7, 1 } )
  AAdd( at1, { '          за отчетный месяц', '07б', 7, 2 } )
  AAdd( at2, { 'Сумма средств по счетам, предоставленным ТФОМС к', '', 0, 0 } )
  AAdd( at2, { 'оплате в отчетном месяце', '08', 8, 0 } )
  AAdd( at2, { ' в т.ч. сумма средств, не принятых (удержанных)', '', 0, 0 } )
  AAdd( at2, { ' по результатам контроля объемов,сроков,качества', '', 0, 0 } )
  AAdd( at2, { ' и условий предоставления медицинской помощи', '09', 9, 0 } )
  //
  arr_title2 := { ;
    '     Раздел II. Сведения об оказанной застрахованному лицу медицинской помощи       ', ;
    '────────────────────┬───┬───┬───────────────────────────┬───────────────────────────', ;
    '       Вид          │ № │уч.│   за отчетный месяц       │     с начала года         ', ;
    '   медицинской      │стр│еди├───────┬──────┬────────────┼───────┬──────┬────────────', ;
    '      помощи        │оки│ниц│ кол-во│числен│  стоимость │ кол-во│числен│  стоимость ', ;
    '────────────────────┼───┼───┼───────┼──────┼────────────┼───────┼──────┼────────────', ;
    '         3          │   │ 4 │   6   │  7   │     8      │   9   │  10  │     11     ', ;
    '────────────────────┴───┴───┴───────┴──────┴────────────┴───────┴──────┴────────────' }
  at_r2 := {}
  AAdd( at_r2, { 'Первичная медико-    ', '', '', 0, 0 } )
  AAdd( at_r2, { '   санитарная помощь ', '10', '', 1, 0 } )
  AAdd( at_r2, { '  амбулатар.помощь   ', '11', 'пос', 1, 1 } )
  AAdd( at_r2, { '  дневной стационар  ', '12', 'п/д', 1, 3 } )
  AAdd( at_r2, { '  стоматологическая  ', '13', 'УЕТ', 1, 4 } )
  AAdd( at_r2, { 'Скорая медицинская   ', '', '', 0, 0 } )
  AAdd( at_r2, { '              помощь ', '14', 'СМП', 2, 6 } )
  AAdd( at_r2, { 'Специализированная   ', '', '', 0, 0 } )
  AAdd( at_r2, { ' медпомощь,в т.ч.ВМП ', '15', '', 3, 0 } )
  AAdd( at_r2, { '  амбулатор.помощь   ', '16', 'пос', 3, 1 } )
  AAdd( at_r2, { '  стационар          ', '17', 'к/д', 3, 2 } )
  AAdd( at_r2, { '  дневной стационар  ', '18', 'п/д', 3, 3 } )
  AAdd( at_r2, { '  диагностич.услуги  ', '19', 'усл', 3, 5 } )
  //
  IF ireg == 2
    name_file += 'p'
  ENDIF
  fp := FCreate( name_file + stxt ) ; n_list := 1 ; tek_stroke := 0
  USE ( cur_dir + 'tmp1' ) index ( cur_dir + 'tmp1' ) new
  USE ( cur_dir + 'tmp2' ) index ( cur_dir + 'tmp2' ) new
  IF ireg == 2 // протокол созданияя формы 1
    R_Use( dir_server + 'schet_',, 'SCHET_' )
    R_Use( dir_server + 'schet',, 'SCHET' )
    SET RELATION TO RecNo() into SCHET_
    USE ( cur_dir + 'tmp1prot' ) new
    SET RELATION TO schet into SCHET
    INDEX ON Str( smo, 5 ) + Str( s1, 1 ) + Str( s2, 1 ) + DToS( date_reg_schet() ) + schet_->nschet to ( cur_dir + 'tmp1prot' )
    USE ( cur_dir + 'tmp2pr_u' ) new
    INDEX ON Str( kod, 6 ) + fsort_usl( shifr ) to ( cur_dir + 'tmp2pr_u' )
    USE ( cur_dir + 'tmp2prot' ) new
    SET RELATION TO schet into SCHET
    INDEX ON Str( smo, 5 ) + Str( vid, 1 ) + Str( pz, 1 ) + DToS( date_reg_schet() ) + schet_->nschet to ( cur_dir + 'tmp2prot' )
    add_string( 'Протокол создания формы №1 для ФФОМС ' + arr_m[ 4 ] )
    add_string( ' [ зарегистрированные счета по дате РЕГИСТРАЦИИ ]' )
    FOR i := 1 TO Len( arr_smo )
      verify_FF( HH - 6, .T., sh )
      add_string( '' )
      add_string( arr_smo[ i, 1 ] )
      FOR j := 1 TO Len( at1 )
        SELECT TMP1
        find ( Str( arr_smo[ i, 2 ], 5 ) + Str( at1[ j, 3 ], 1 ) + Str( at1[ j, 4 ], 1 ) )
        IF Found() .AND. tmp1->summa1 > 0
          SELECT TMP1prot
          find ( Str( arr_smo[ i, 2 ], 5 ) + Str( at1[ j, 3 ], 1 ) + Str( at1[ j, 4 ], 1 ) )
          IF Found()
            verify_FF( HH - 4, .T., sh )
            add_string( Replicate( '─', 53 ) )
            add_string( PadR( at1[ j, 1 ], 50 ) + PadR( at1[ j, 2 ], 3 ) )
            add_string( Replicate( '─', 53 ) )
            DO WHILE arr_smo[ i, 2 ] == tmp1prot->smo .AND. at1[ j, 3 ] == tmp1prot->s1 ;
                .AND. at1[ j, 4 ] == tmp1prot->s2 .AND. !Eof()
              verify_FF( HH, .T., sh )
              add_string( Space( 6 ) + put_otch_period() + ' ' + ;
                schet_->nschet + ' ' + date_8( date_reg_schet() ) + Str( tmp1prot->summa1, 13, 2 ) )
              SKIP
            ENDDO
          ENDIF
        ENDIF
      NEXT
      FOR j := 1 TO Len( at_r2 )
        SELECT TMP2
        find ( Str( arr_smo[ i, 2 ], 5 ) + Str( at_r2[ j, 4 ], 1 ) + Str( at_r2[ j, 5 ], 1 ) )
        IF Found() .AND. tmp2->kol1 > 0
          SELECT TMP2prot
          find ( Str( arr_smo[ i, 2 ], 5 ) + Str( at_r2[ j, 4 ], 1 ) + Str( at_r2[ j, 5 ], 1 ) )
          IF Found()
            verify_FF( HH - 5, .T., sh )
            add_string( Replicate( '─', 63 ) )
            IF at_r2[ j, 5 ] == 0
              add_string( PadR( at_r2[ j -1, 1 ], 21 ) + PadR( at_r2[ j -1, 2 ], 4 ) + PadR( at_r2[ j -1, 3 ], 4 ) )
            ENDIF
            au := {}
            add_string( PadR( at_r2[ j, 1 ], 21 ) + PadR( at_r2[ j, 2 ], 4 ) + PadR( at_r2[ j, 3 ], 4 ) )
            add_string( Replicate( '─', 63 ) )
            DO WHILE arr_smo[ i, 2 ] == tmp2prot->smo .AND. at_r2[ j, 4 ] == tmp2prot->vid ;
                .AND. at_r2[ j, 5 ] == tmp2prot->pz .AND. !Eof()
              verify_FF( HH, .T., sh )
              s := Space( 6 ) + put_otch_period() + ' ' + schet_->nschet + ' ' + date_8( date_reg_schet() )
              IF at_r2[ j, 5 ] > 0
                s += umest_val( tmp2prot->kol1, 10, 2 )
              ELSE
                s += Space( 10 )
              ENDIF
              s += put_val( tmp2prot->summa1, 13, 2 )
              SELECT TMP2pr_u
              find ( Str( tmp2prot->( RecNo() ), 6 ) )
              IF Found()
                s += ' ('
                DO WHILE tmp2pr_u->kod == tmp2prot->( RecNo() ) .AND. !Eof()
                  s += AllTrim( tmp2pr_u->shifr ) + '-' + AllTrim( str_0( tmp2pr_u->kol, 12, 2 ) ) + ','
                  IF ( k := AScan( au, {| x| x[ 1 ] == tmp2pr_u->shifr } ) ) == 0
                    AAdd( au, { tmp2pr_u->shifr, 0 } ) ; k := Len( au )
                  ENDIF
                  au[ k, 2 ] += tmp2pr_u->kol
                  SKIP
                ENDDO
                s := Left( s, Len( s ) -1 )
                s += ')'
              ENDIF
              SELECT TMP2prot
              add_string( s )
              SKIP
            ENDDO
            IF !Empty( au )
              ASort( au,,, {| x, y| iif( x[ 2 ] == y[ 2 ], fsort_usl( x[ 1 ] ) < fsort_usl( y[ 1 ] ), x[ 2 ] > y[ 2 ] ) } )
              s := 'по всем счетам: '
              FOR k := 1 TO Len( au )
                s += AllTrim( au[ k, 1 ] ) + '-' + AllTrim( str_0( au[ k, 2 ], 12, 2 ) ) + ','
              NEXT
              s := Left( s, Len( s ) -1 )
              add_string( s )
            ENDIF
          ENDIF
        ENDIF
      NEXT
    NEXT
  ELSE
    add_string( 'Форма №1 для ФФОМС ' + arr_m[ 4 ] + ' (по приказу ФОМС №146 от 16.08.11)' )
    add_string( ' [ зарегистрированные счета по дате РЕГИСТРАЦИИ ]' )
    FOR i := 1 TO Len( arr_smo )
      verify_FF( HH - 17, .T., sh )
      add_string( '' )
      add_string( arr_smo[ i, 1 ] )
      add_string( Replicate( '=', 20 ) )
      AEval( arr_title1, {| x| add_string( x ) } )
      FOR j := 1 TO Len( at1 )
        s := PadR( at1[ j, 1 ], 50 ) + PadR( at1[ j, 2 ], 3 )
        IF at1[ j, 3 ] > 0
          SELECT TMP1
          find ( Str( arr_smo[ i, 2 ], 5 ) + Str( at1[ j, 3 ], 1 ) + Str( at1[ j, 4 ], 1 ) )
          IF Found()
            s += Str( tmp1->summa1, 13, 2 )
            IF !Empty( tmp1->summa2 )
              s += Str( tmp1->summa2, 14, 2 )
            ENDIF
          ENDIF
        ENDIF
        add_string( s )
      NEXT
      add_string( '' )
      verify_FF( HH - 25, .T., sh )
      AEval( arr_title2, {| x| add_string( x ) } )
      FOR j := 1 TO Len( at_r2 )
        s := PadR( at_r2[ j, 1 ], 21 ) + PadR( at_r2[ j, 2 ], 4 ) + PadR( at_r2[ j, 3 ], 4 )
        IF at_r2[ j, 4 ] > 0
          SELECT TMP2
          find ( Str( arr_smo[ i, 2 ], 5 ) + Str( at_r2[ j, 4 ], 1 ) + Str( at_r2[ j, 5 ], 1 ) )
          IF Found()
            IF at_r2[ j, 5 ] > 0
              s += umest_val( tmp2->kol1, 7, 2 ) + ' '
            ELSE
              s += Space( 8 )
            ENDIF
            s += put_val( tmp2->kol3, 6 ) + put_val( tmp2->summa1, 13, 2 ) + ' '
            IF at_r2[ j, 5 ] > 0
              s += umest_val( tmp2->kol2, 7, 2 ) + ' '
            ELSE
              s += Space( 8 )
            ENDIF
            s += put_val( tmp2->kol4, 6 ) + put_val( tmp2->summa2, 13, 2 )
          ENDIF
        ENDIF
        add_string( s )
      NEXT
    NEXT
    verify_FF( HH - 22, .T., sh )
    add_string( '' )
    add_string( 'И Т О Г О' )
    add_string( Replicate( '=', 20 ) )
    AEval( arr_title1, {| x| add_string( x ) } )
    FOR j := 1 TO Len( at1 )
      s := PadR( at1[ j, 1 ], 50 ) + PadR( at1[ j, 2 ], 3 ) ; ss1 := ss2 := 0
      IF at1[ j, 3 ] > 0
        FOR i := 1 TO Len( arr_smo )
          SELECT TMP1
          find ( Str( arr_smo[ i, 2 ], 5 ) + Str( at1[ j, 3 ], 1 ) + Str( at1[ j, 4 ], 1 ) )
          IF Found()
            ss1 += tmp1->summa1
            ss2 += tmp1->summa2
          ENDIF
        NEXT
        IF !Empty( ss1 )
          s += Str( ss1, 13, 2 )
          IF !Empty( ss2 )
            s += Str( ss2, 14, 2 )
          ENDIF
        ENDIF
      ENDIF
      add_string( s )
    NEXT
    FOR j := 1 TO Len( at2 )
      s := PadR( at2[ j, 1 ], 50 ) + PadR( at2[ j, 2 ], 3 )
      IF at2[ j, 3 ] > 0
        SELECT TMP1
        find ( Str( 34, 5 ) + Str( at2[ j, 3 ], 1 ) + Str( at2[ j, 4 ], 1 ) )
        IF Found()
          s += Str( tmp1->summa1, 13, 2 )
          IF !Empty( tmp1->summa2 )
            s += Str( tmp1->summa2, 14, 2 )
          ENDIF
        ENDIF
      ENDIF
      add_string( s )
    NEXT
    add_string( '' )
    verify_FF( HH - 25, .T., sh )
    AEval( arr_title2, {| x| add_string( x ) } )
    FOR j := 1 TO Len( at_r2 )
      s := PadR( at_r2[ j, 1 ], 21 ) + PadR( at_r2[ j, 2 ], 4 ) + PadR( at_r2[ j, 3 ], 4 )
      IF at_r2[ j, 4 ] > 0
        ss1 := ss2 := ss3 := ss4 := ss5 := ss6 := 0
        FOR i := 1 TO Len( arr_smo )
          SELECT TMP2
          find ( Str( arr_smo[ i, 2 ], 5 ) + Str( at_r2[ j, 4 ], 1 ) + Str( at_r2[ j, 5 ], 1 ) )
          IF Found()
            IF at_r2[ j, 5 ] > 0
              ss1 += tmp2->kol1
              ss2 += tmp2->kol2
            ENDIF
            ss3 += tmp2->kol3
            ss4 += tmp2->kol4
            ss5 += tmp2->summa1
            ss6 += tmp2->summa2
          ENDIF
        NEXT
        IF at_r2[ j, 5 ] > 0
          s += umest_val( ss1, 7, 2 ) + ' '
        ELSE
          s += Space( 8 )
        ENDIF
        s += put_val( ss3, 6 ) + put_val( ss5, 13, 2 ) + ' '
        IF at_r2[ j, 5 ] > 0
          s += umest_val( ss2, 7, 2 ) + ' '
        ELSE
          s += Space( 8 )
        ENDIF
        s += put_val( ss4, 6 ) + put_val( ss6, 13, 2 )
      ENDIF
      add_string( s )
    NEXT
  ENDIF
  arr_title2[ 1 ] := '              других субъектов Российской Федерации, медицинской помощи'
  Ins_Array( arr_title2, 1, '  Раздел III. Сведения об оказанной лицам, застрахованным на территории' )
  at_r2[ 2, 2 ] := '20'
  at_r2[ 3, 2 ] := '21'
  at_r2[ 4, 2 ] := '22'
  at_r2[ 5, 2 ] := '23'
  at_r2[ 7, 2 ] := '24'
  at_r2[ 9, 2 ] := '25'
  at_r2[ 10, 2 ] := '26'
  at_r2[ 11, 2 ] := '27'
  at_r2[ 12, 2 ] := '28'
  at_r2[ 13, 2 ] := '39'
  IF ireg == 2
    AAdd( arr_smo, { 'ТФОМС (иногородние)', 34 } )
    i := Len( arr_smo ) // для ТФОМС
    verify_FF( HH - 6, .T., sh )
    add_string( '' )
    add_string( arr_smo[ i, 1 ] )
    FOR j := 1 TO Len( at2 )
      SELECT TMP1
      find ( Str( arr_smo[ i, 2 ], 5 ) + Str( at2[ j, 3 ], 1 ) + Str( at2[ j, 4 ], 1 ) )
      IF Found() .AND. tmp1->summa1 > 0
        SELECT TMP1prot
        find ( Str( arr_smo[ i, 2 ], 5 ) + Str( at2[ j, 3 ], 1 ) + Str( at2[ j, 4 ], 1 ) )
        IF Found()
          verify_FF( HH - 4, .T., sh )
          add_string( Replicate( '─', 53 ) )
          add_string( PadR( at2[ j, 1 ], 50 ) + PadR( at2[ j, 2 ], 3 ) )
          add_string( Replicate( '─', 53 ) )
          DO WHILE arr_smo[ i, 2 ] == tmp1prot->smo .AND. at2[ j, 3 ] == tmp1prot->s1 ;
              .AND. at2[ j, 4 ] == tmp1prot->s2 .AND. !Eof()
            verify_FF( HH, .T., sh )
            add_string( Space( 6 ) + put_otch_period() + ' ' + ;
              schet_->nschet + ' ' + date_8( date_reg_schet() ) + Str( tmp1prot->summa1, 13, 2 ) )
            SKIP
          ENDDO
        ENDIF
      ENDIF
    NEXT
    FOR j := 1 TO Len( at_r2 )
      SELECT TMP2
      find ( Str( arr_smo[ i, 2 ], 5 ) + Str( at_r2[ j, 4 ], 1 ) + Str( at_r2[ j, 5 ], 1 ) )
      IF Found() .AND. tmp2->kol1 > 0
        SELECT TMP2prot
        find ( Str( arr_smo[ i, 2 ], 5 ) + Str( at_r2[ j, 4 ], 1 ) + Str( at_r2[ j, 5 ], 1 ) )
        IF Found()
          verify_FF( HH - 5, .T., sh )
          add_string( Replicate( '─', 63 ) )
          IF at_r2[ j, 5 ] == 0
            add_string( PadR( at_r2[ j -1, 1 ], 21 ) + PadR( at_r2[ j -1, 2 ], 4 ) + PadR( at_r2[ j -1, 3 ], 4 ) )
          ENDIF
          au := {}
          add_string( PadR( at_r2[ j, 1 ], 21 ) + PadR( at_r2[ j, 2 ], 4 ) + PadR( at_r2[ j, 3 ], 4 ) )
          add_string( Replicate( '─', 63 ) )
          DO WHILE arr_smo[ i, 2 ] == tmp2prot->smo .AND. at_r2[ j, 4 ] == tmp2prot->vid ;
              .AND. at_r2[ j, 5 ] == tmp2prot->pz .AND. !Eof()
            verify_FF( HH, .T., sh )
            s := Space( 6 ) + put_otch_period() + ' ' + schet_->nschet + ' ' + date_8( date_reg_schet() )
            IF at_r2[ j, 5 ] > 0
              s += umest_val( tmp2prot->kol1, 10, 2 )
            ELSE
              s += Space( 10 )
            ENDIF
            s += put_val( tmp2prot->summa1, 13, 2 )
            SELECT TMP2pr_u
            find ( Str( tmp2prot->( RecNo() ), 6 ) )
            IF Found()
              s += ' ('
              DO WHILE tmp2pr_u->kod == tmp2prot->( RecNo() ) .AND. !Eof()
                s += AllTrim( tmp2pr_u->shifr ) + '-' + AllTrim( str_0( tmp2pr_u->kol, 12, 2 ) ) + ','
                IF ( k := AScan( au, {| x| x[ 1 ] == tmp2pr_u->shifr } ) ) == 0
                  AAdd( au, { tmp2pr_u->shifr, 0 } ) ; k := Len( au )
                ENDIF
                au[ k, 2 ] += tmp2pr_u->kol
                SKIP
              ENDDO
              s := Left( s, Len( s ) -1 )
              s += ')'
            ENDIF
            SELECT TMP2prot
            add_string( s )
            SKIP
          ENDDO
          IF !Empty( au )
            ASort( au,,, {| x, y| iif( x[ 2 ] == y[ 2 ], fsort_usl( x[ 1 ] ) < fsort_usl( y[ 1 ] ), x[ 2 ] > y[ 2 ] ) } )
            s := 'по всем счетам: '
            FOR k := 1 TO Len( au )
              s += AllTrim( au[ k, 1 ] ) + '-' + AllTrim( str_0( au[ k, 2 ], 12, 2 ) ) + ','
            NEXT
            s := Left( s, Len( s ) -1 )
            add_string( s )
          ENDIF
        ENDIF
      ENDIF
    NEXT
  ELSE
    add_string( '' )
    verify_FF( HH - 25, .T., sh )
    AEval( arr_title2, {| x| add_string( x ) } )
    FOR j := 1 TO Len( at_r2 )
      s := PadR( at_r2[ j, 1 ], 21 ) + PadR( at_r2[ j, 2 ], 4 ) + PadR( at_r2[ j, 3 ], 4 )
      IF at_r2[ j, 4 ] > 0
        SELECT TMP2
        find ( Str( 34, 5 ) + Str( at_r2[ j, 4 ], 1 ) + Str( at_r2[ j, 5 ], 1 ) )
        IF Found()
          IF at_r2[ j, 5 ] > 0
            s += umest_val( tmp2->kol1, 7, 2 ) + ' '
          ELSE
            s += Space( 8 )
          ENDIF
          s += put_val( tmp2->kol3, 6 ) + put_val( tmp2->summa1, 13, 2 ) + ' '
          IF at_r2[ j, 5 ] > 0
            s += umest_val( tmp2->kol2, 7, 2 ) + ' '
          ELSE
            s += Space( 8 )
          ENDIF
          s += put_val( tmp2->kol4, 6 ) + put_val( tmp2->summa2, 13, 2 )
        ENDIF
      ENDIF
      add_string( s )
    NEXT
  ENDIF
  CLOSE databases
  FClose( fp )
  viewtext( name_file + stxt,,,, .T.,,, 5 )

  RETURN NIL

** 26.02.20
Function f1forma1_ffoms(delta, arr_m, arr_smo, fl_month, _summa, _b1, _b2)
  Local msmo, ns, ns1, mdate

  DEFAULT _b1 TO 0, _b2 TO 0
  if (msmo := int(val(schet_->smo))) == 34
    ns := 8 + delta
  else
    ns := 6 + delta
    if ascan(arr_smo, {|x| x[2] == msmo }) == 0
      aadd(arr_smo, {'', msmo})
    endif
  endif
  select TMP1
  find (str(msmo, 5) + str(ns, 1) + str(0, 1))
  if !found()
    append blank
    tmp1->smo := msmo
    tmp1->s1  := ns
    tmp1->s2  := 0
  endif
  if fl_month
    tmp1->summa1 += _summa
    select TMP1prot
    find (str(msmo, 5) + str(ns, 1) + str(0, 1) + str(schet->kod, 6))
    if !found()
      append blank
      tmp1prot->smo := msmo
      tmp1prot->s1  := ns
      tmp1prot->s2  := 0
      tmp1prot->schet := schet->kod
    endif
    tmp1prot->summa1 += _summa
  endif
  tmp1->summa2 += _summa
  if ns == 6 + delta .and. fl_month
    if schet_->nyear == arr_m[1] .and. schet_->nmonth == arr_m[3]
      ns1 := 2
    else
      ns1 := 1
    endif
    select TMP1
    find (str(msmo, 5) + str(ns, 1) + str(ns1, 1))
    if !found()
      append blank
      tmp1->smo := msmo
      tmp1->s1  := ns
      tmp1->s2  := ns1
    endif
    tmp1->summa1 += _summa
    select TMP1prot
    find (str(msmo, 5) + str(ns, 1) + str(ns1, 1) + str(schet->kod, 6))
    if !found()
      append blank
      tmp1prot->smo := msmo
      tmp1prot->s1  := ns
      tmp1prot->s2  := ns1
      tmp1prot->schet := schet->kod
    endif
    tmp1prot->summa1 += _summa
  endif
  return NIL
  
** 24.11.21
Function f2forma1_ffoms(msmo, fl_month)
  Local tfoms_pz[6, 3], mkol, ta, i, ii, j, k, lshifr, lvidpom := 1, lshifr1, j1, fl, ;
        arr := {}, mkol_k := 0, mkol_1 := 0, mkol_2 := 0, mkol_55 := 0, lenp, ;
        fl_T := (schet_->bukva == 'T'), fl_K := (schet_->bukva == 'K'), lalf := 'luslf'
  
  lalf := create_name_alias(lalf, arr_m[1])
  
  select HU
  find (str(human->kod, 7))
  do while hu->kod == human->kod .and. !eof()
    lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
    if is_usluga_TFOMS(usl->shifr, lshifr1, human->k_data)
      lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
      if human_->USL_OK == 3 .and. hu->stoim_1 > 0 .and. ;  // только для п-ки
                                    (i := ret_vid_pom(1, lshifr, human->k_data)) > 0
        lvidpom := iif(eq_any(i, 1, 11, 12), 1, 3)
      endif
      fl := .f.
      if left(lshifr, 5) == '1.11.'
        mkol_1 += hu->kol_1
        fl := .t.
      elseif left(lshifr, 2) == '2.'
        if eq_any(left(lshifr, 4), '2.4.', '2.78', '2.89', '2.90', '2.91') .or. fl_T
          //
        else
          fl := .t.
          mkol_2 += hu->kol_1
        endif
      elseif left(lshifr, 5) == '55.1.'
        if lshifr == '55.1.3'
          lvidpom := 1
        else
          lvidpom := 3
        endif
        mkol_55 += hu->kol_1
        fl := .t.
      elseif fl_K
        mkol_k += hu->kol_1
        fl := .t.
      endif
      if fl_month .and. fl
        if (i := ascan(arr, {|x| x[1] == lshifr})) == 0
          aadd(arr, {lshifr, 0})
          i := len(arr)
        endif
        arr[i, 2] += hu->kol_1
      endif
    endif
    select HU
    skip
  enddo
  afillall(tfoms_pz, 0)
  if human_->USL_OK == 1 // стационар
    ii := 2
    lvidpom := 3
    tfoms_pz[ii, 1] := mkol_1
  elseif human_->USL_OK == 2 // дневной стационар
    ii := 3
    if empty(mkol_55)
      lvidpom := 3
    else
      tfoms_pz[ii, 1] := mkol_55
    endif
  elseif human_->USL_OK == 3 // поликлиника
    if fl_T // стоматология
      lvidpom := 1
      ii := 4
      select MOHU
      find (str(human->kod, 7))
      do while mohu->kod == human->kod .and. !eof()
        dbSelectArea(lalf)
        find (mosu->shifr1)
        mkol := round_5(mohu->kol_1 * iif(human->vzros_reb==0, &lalf.->uetv, &lalf.->uetd), 2)
        tfoms_pz[ii, 1] += mkol // кол-во УЕТ
        if fl_month
          if valtype(tfoms_pz[ii, 3]) == 'N'
            tfoms_pz[ii, 3] := {}
          endif
          if (i := ascan(tfoms_pz[ii, 3], {|x| x[1] == mosu->shifr1})) == 0
            aadd(tfoms_pz[ii, 3], {mosu->shifr1, 0})
            i := len(tfoms_pz[ii, 3])
          endif
          tfoms_pz[ii, 3, i, 2] += mkol
        endif
        select MOHU
        skip
      enddo
    elseif fl_K // отдельные услуги
      ii := 5
      lvidpom := 3
      tfoms_pz[ii, 1] := mkol_k
    else
      ii := 1
      tfoms_pz[ii, 1] := mkol_2 // кол-во врачебных приёмов
    endif
  elseif human_->USL_OK == 4 // скорая помощь
    lvidpom := 2
    ii := 6
    tfoms_pz[ii, 1] := 1 // один вызов СМП
  endif
  tfoms_pz[ii, 2] := human->cena_1 // сумма всего случая по-новому
  if valtype(tfoms_pz[ii, 3]) == 'N'
    tfoms_pz[ii, 3] := aclone(arr)
  endif
  for ii := 1 to 6
    if !emptyall(tfoms_pz[ii, 1], tfoms_pz[ii, 2])
      select TMP2
      find (str(msmo, 5) + str(lvidpom, 1) + str(ii, 1))
      if !found()
        append blank
        tmp2->smo := msmo
        tmp2->pz  := ii
        tmp2->vid := lvidpom
      endif
      if fl_month
        tmp2->kol1   += tfoms_pz[ii, 1]
        tmp2->summa1 += tfoms_pz[ii, 2]
        select TMP2prot
        find (str(msmo, 5) + str(lvidpom, 1) + str(ii, 1) + str(schet->kod, 6))
        if !found()
          append blank
          tmp2prot->smo := msmo
          tmp2prot->pz  := ii
          tmp2prot->vid := lvidpom
          tmp2prot->schet := schet->kod
        endif
        tmp2prot->kol1   += tfoms_pz[ii, 1]
        tmp2prot->summa1 += tfoms_pz[ii, 2]
        for i := 1 to len(tfoms_pz[ii, 3])
          if tfoms_pz[ii, 3, i, 2] > 0
            select TMP2pr_u
            find (str(tmp2prot->(recno()), 6) + padr(tfoms_pz[ii, 3, i, 1], 20))
            if !found()
              append blank
              TMP2pr_u->kod := tmp2prot->(recno())
              TMP2pr_u->shifr := tfoms_pz[ii, 3, i, 1]
            endif
            TMP2pr_u->kol += tfoms_pz[ii, 3, i, 2]
          endif
        next
      endif
      tmp2->kol2   += tfoms_pz[ii, 1]
      tmp2->summa2 += tfoms_pz[ii, 2]
      select TMP2
      find (str(msmo, 5) + str(lvidpom, 1) + str(0, 1))
      if !found()
        append blank
        tmp2->smo := msmo
        tmp2->pz  := 0
        tmp2->vid := lvidpom
      endif
      if fl_month
        tmp2->kol1   += tfoms_pz[ii, 1]
        tmp2->summa1 += tfoms_pz[ii, 2]
        select TMP2prot
        find (str(msmo, 5) + str(lvidpom, 1) + str(0, 1) + str(schet->kod, 6))
        if !found()
          append blank
          tmp2prot->smo := msmo
          tmp2prot->pz  := 0
          tmp2prot->vid := lvidpom
          tmp2prot->schet := schet->kod
        endif
        tmp2prot->kol1   += tfoms_pz[ii, 1]
        tmp2prot->summa1 += tfoms_pz[ii, 2]
      endif
      tmp2->kol2   += tfoms_pz[ii, 1]
      tmp2->summa2 += tfoms_pz[ii, 2]
      //
      if len(lenp := alltrim(kart2->kod_mis)) != 16
        lenp := lstr(human->kod_k)
      endif
      select TMP3
      //find (str(msmo,5)+str(lvidpom,1)+str(ii,1)+str(human->kod_k,7))
      find (str(msmo, 5) + str(lvidpom, 1) + str(ii, 1) + padr(lenp, 16))
      if !found()
        append blank
        tmp3->smo := msmo
        tmp3->kod_k := human->kod_k
        tmp3->enp := lenp
        tmp3->pz  := ii
        tmp3->vid := lvidpom
      endif
      if fl_month
        tmp3->kol3++
      endif
      tmp3->kol4++
      select TMP3
      //find (str(msmo,5)+str(lvidpom,1)+str(0,1)+str(human->kod_k,7))
      find (str(msmo, 5) + str(lvidpom, 1) + str(0, 1) + padr(lenp, 16))
      if !found()
        append blank
        tmp3->smo := msmo
        tmp3->kod_k := human->kod_k
        tmp3->enp := lenp
        tmp3->pz  := 0
        tmp3->vid := lvidpom
      endif
      if fl_month
        tmp3->kol3++
      endif
      tmp3->kol4++
    endif
  next
  return NIL
