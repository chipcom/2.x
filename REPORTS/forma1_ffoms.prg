// * ¨­ä®à¬ æ¨ï ¯® ä®à¬  1 ””ŽŒ‘ (¯® áç¥â ¬)
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// * 01.03.23 à á¯¥ç âª  ä®à¬ë ü1 ¨§ ¯à¨ª §  ”ŽŒ‘ ü146
FUNCTION forma1_ffoms()

  LOCAL mdate, i, j, k, d1, d2, arr_smo := {}, at1, at2, ta, fl_month, tmp, b1_1, a1_1, ;
    _bd, fl, b1, b2, a1, a2, lsmo, name_file := cur_dir + 'forma1', HH := 80, sh := 84

  PRIVATE arr_m

  IF ( arr_m := year_month(,,, 3 ) ) == NIL
    RETURN NIL
  ELSEIF arr_m[ 1 ] < 2018
    RETURN func_error( 4, '®¢ë©  «£®à¨â¬ á®§¤ ­¨ï ¤ ­­®© ä®à¬ë ¢¢¥¤¥­ á 2018 £®¤ !' )
  ENDIF
  WaitStatus( '‘¡®à ¨­ä®à¬ æ¨¨' )
  adbf := { { 'smo', 'N', 5, 0 }, ;
    { 's1', 'N', 1, 0 }, ;
    { 's2', 'N', 1, 0 }, ;
    { 'schet', 'N', 6, 0 }, ;
    { 'summa1', 'N', 15, 2 }, ; // §  ¬¥áïæ
  { 'summa2', 'N', 15, 2 } } // á­£
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
    { 'kol1', 'N', 15, 2 }, ; // §  ¬¥áïæ
  { 'kol2', 'N', 15, 2 }, ; // á­£
  { 'kol3', 'N', 6, 0 }, ; // §  ¬¥áïæ
  { 'kol4', 'N', 6, 0 }, ; // á­£
  { 'summa1', 'N', 15, 2 }, ; // §  ¬¥áïæ
  { 'summa2', 'N', 15, 2 } } // á­£
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
    { 'kol3', 'N', 6, 0 }, ; // §  ¬¥áïæ
  { 'kol4', 'N', 6, 0 } }  // á­£
  dbCreate( cur_dir + 'tmp3', adbf )
  USE ( cur_dir + 'tmp3' ) new
  // index on str(smo, 5) + str(vid, 1) + str(pz, 1) + str(kod_k, 7) to (cur_dir + 'tmp3')
  INDEX ON Str( smo, 5 ) + Str( vid, 1 ) + Str( pz, 1 ) + enp to ( cur_dir + 'tmp3' )
  //
  tmp := AClone( arr_m )
  tmp[ 5 ] := 1 // ï­¢ àì
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
    IF !Empty( lsmo ) .AND. schet_->NREGISTR == 0 // â®«ìª® § à¥£¨áâà¨à®¢ ­­ë¥
      @ MaxRow(), 0 SAY PadR( 'ü ' + AllTrim( schet_->NSCHET ) + ' ®â ' + date_8( schet_->DSCHET ), 28 ) COLOR 'W/R'
      mdate := date_reg_schet() // ¤ â  à¥£¨áâà æ¨¨
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
      fl_month := Between( mdate1, arr_m[ 5 ], arr_m[ 6 ] ) // ®âç.¯¥à¨®¤ â¥ªãé¨© ¬¥áïæ
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
      // my_debug(,'date1_mes='+dtos(arr_m[5]))
      // my_debug(,'date2_mes='+dtos(arr_m[6]))
      // my_debug(,'d1='+ str(d1))
      // my_debug(,'d2='+ str(d2))
      // my_debug(,'date1='+dtos(boy(arr_m[5])))
      // my_debug(,'date2='+dtos(arr_m[6] +d2))
      // my_debug(,'a1='+ str(a1))
      // my_debug(,'a2='+ str(a2))

      msmo := Int( Val( schet_->smo ) )
      fl := Between( mdate, BoY( arr_m[ 5 ] ), arr_m[ 6 ] + d2 ) ;// ¤ â  à¥£¨áâà æ¨¨ ¯® 10 ç¨á«  á«¥¤.¬¥áïæ 
      .AND. Between( mdate1, BoY( arr_m[ 5 ] ), arr_m[ 6 ] ) // !!®âç.¯¥à¨®¤ íâ®â £®¤

      IF fl
        IF !fl_month
          // áç¥â  §  ¯à¥¤.®âç.¯¥à¨®¤ë á ¤ â®© ®â 11 â¥ª.¬¥áïæ  ¯® 10 á«¥¤.¬¥áïæ 
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
  @ MaxRow(), 0 SAY PadR( '¯®¤áçñâ á­ïâ¨©', 28 ) COLOR 'W/R'
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
    // my_debug(,mo_xml->dfile)
    UpdateStatus()
    IF AScan( arr_h, raksh->kod_h ) == 0
      human->( dbGoto( raksh->kod_h ) )
      IF human->schet > 0 .AND. raksh->oplata > 1
        schet->( dbGoto( human->schet ) )
        IF schet_->NREGISTR == 0 // â®«ìª® § à¥£¨áâà¨à®¢ ­­ë¥
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
  @ MaxRow(), 0 SAY PadR( '¯®¤áçñâ ª®«¨ç¥áâ¢  ç¥«®¢¥ª', 28 ) COLOR 'W/R'
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
        arr_smo[ i, 1 ] := '‘ŒŽ á ª®¤®¬ ' + lstr( arr_smo[ i, 2 ] )
      ENDIF
    NEXT
  ENDIF
  ClrLine( MaxRow(), color0 ) ; mybell() ; mybell()
  ireg := popup_prompt( T_ROW, T_COL -5, 1, { ' á¯¥ç âª  ä®à¬ë ü1', 'à®â®ª®« á®§¤ ­¨ï ä®à¬ë ü1' } )
  arr_title1 := { ;
    '      §¤¥« I. ˆá¯®«ì§®¢ ­¨¥ áà¥¤áâ¢ ®¡ï§ â¥«ì­®£® ¬¥¤¨æ¨­áª®£® áâà å®¢ ­¨ï     ', ;
    'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ', ;
    '                                                 ³üü ³  Žâç¥â­ë©  ³   à áâ îé¨¬', ;
    ' ¨¬¥­®¢ ­¨¥ ¯®ª § â¥«ï                          ³áâà³  ¬¥áïæ     ³  ¨â®£®¬     ', ;
    'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ' }
  at1 := {}
  at2 := {}
  AAdd( at1, { '‘ã¬¬  áà¥¤áâ¢ ¯® áç¥â ¬, ¯à¥¤®áâ ¢«¥­­ë¬ ‘ŒŽ', '', 0, 0 } )
  AAdd( at1, { 'ª ®¯« â¥ ¢ ®âç¥â­®¬ ¬¥áïæ¥ (áâà.06 +06¡)', '06', 6, 0 } )
  AAdd( at1, { '  ¨§ ­¨å: §  ¯à¥¤ë¤ãé¨© ¬¥áïæ', '06 ', 6, 1 } )
  AAdd( at1, { '          §  ®âç¥â­ë© ¬¥áïæ', '06¡', 6, 2 } )
  AAdd( at1, { ' ¢ â.ç. áã¬¬  áà¥¤áâ¢, ­¥ ¯à¨­ïâëå (ã¤¥à¦ ­­ëå)', '', 0, 0 } )
  AAdd( at1, { ' ¯® à¥§ã«ìâ â ¬ ª®­âà®«ï ®¡ê¥¬®¢, áà®ª®¢,ª ç¥áâ¢ ', '', 0, 0 } )
  AAdd( at1, { ' ¨ ãá«®¢¨© ¯à¥¤®áâ ¢«¥­¨ï ¬¥¤.¯®¬®é¨ (07 +07¡)', '07', 7, 0 } )
  AAdd( at1, { '  ¨§ ­¨å: §  ¯à¥¤ë¤ãé¨¥ ¬¥áïæë', '07 ', 7, 1 } )
  AAdd( at1, { '          §  ®âç¥â­ë© ¬¥áïæ', '07¡', 7, 2 } )
  AAdd( at2, { '‘ã¬¬  áà¥¤áâ¢ ¯® áç¥â ¬, ¯à¥¤®áâ ¢«¥­­ë¬ ’”ŽŒ‘ ª', '', 0, 0 } )
  AAdd( at2, { '®¯« â¥ ¢ ®âç¥â­®¬ ¬¥áïæ¥', '08', 8, 0 } )
  AAdd( at2, { ' ¢ â.ç. áã¬¬  áà¥¤áâ¢, ­¥ ¯à¨­ïâëå (ã¤¥à¦ ­­ëå)', '', 0, 0 } )
  AAdd( at2, { ' ¯® à¥§ã«ìâ â ¬ ª®­âà®«ï ®¡ê¥¬®¢,áà®ª®¢,ª ç¥áâ¢ ', '', 0, 0 } )
  AAdd( at2, { ' ¨ ãá«®¢¨© ¯à¥¤®áâ ¢«¥­¨ï ¬¥¤¨æ¨­áª®© ¯®¬®é¨', '09', 9, 0 } )
  //
  arr_title2 := { ;
    '      §¤¥« II. ‘¢¥¤¥­¨ï ®¡ ®ª § ­­®© § áâà å®¢ ­­®¬ã «¨æã ¬¥¤¨æ¨­áª®© ¯®¬®é¨       ', ;
    'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ', ;
    '       ‚¨¤          ³ ü ³ãç.³   §  ®âç¥â­ë© ¬¥áïæ       ³     á ­ ç «  £®¤          ', ;
    '   ¬¥¤¨æ¨­áª®©      ³áâà³¥¤¨ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ', ;
    '      ¯®¬®é¨        ³®ª¨³­¨æ³ ª®«-¢®³ç¨á«¥­³  áâ®¨¬®áâì ³ ª®«-¢®³ç¨á«¥­³  áâ®¨¬®áâì ', ;
    'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ', ;
    '         3          ³   ³ 4 ³   6   ³  7   ³     8      ³   9   ³  10  ³     11     ', ;
    'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ' }
  at_r2 := {}
  AAdd( at_r2, { '¥à¢¨ç­ ï ¬¥¤¨ª®-    ', '', '', 0, 0 } )
  AAdd( at_r2, { '   á ­¨â à­ ï ¯®¬®éì ', '10', '', 1, 0 } )
  AAdd( at_r2, { '   ¬¡ã« â à.¯®¬®éì   ', '11', '¯®á', 1, 1 } )
  AAdd( at_r2, { '  ¤­¥¢­®© áâ æ¨®­ à  ', '12', '¯/¤', 1, 3 } )
  AAdd( at_r2, { '  áâ®¬ â®«®£¨ç¥áª ï  ', '13', '“…’', 1, 4 } )
  AAdd( at_r2, { '‘ª®à ï ¬¥¤¨æ¨­áª ï   ', '', '', 0, 0 } )
  AAdd( at_r2, { '              ¯®¬®éì ', '14', '‘Œ', 2, 6 } )
  AAdd( at_r2, { '‘¯¥æ¨ «¨§¨à®¢ ­­ ï   ', '', '', 0, 0 } )
  AAdd( at_r2, { ' ¬¥¤¯®¬®éì,¢ â.ç.‚Œ ', '15', '', 3, 0 } )
  AAdd( at_r2, { '   ¬¡ã« â®à.¯®¬®éì   ', '16', '¯®á', 3, 1 } )
  AAdd( at_r2, { '  áâ æ¨®­ à          ', '17', 'ª/¤', 3, 2 } )
  AAdd( at_r2, { '  ¤­¥¢­®© áâ æ¨®­ à  ', '18', '¯/¤', 3, 3 } )
  AAdd( at_r2, { '  ¤¨ £­®áâ¨ç.ãá«ã£¨  ', '19', 'ãá«', 3, 5 } )
  //
  IF ireg == 2
    name_file += 'p'
  ENDIF
  fp := FCreate( name_file + stxt ) ; n_list := 1 ; tek_stroke := 0
  USE ( cur_dir + 'tmp1' ) index ( cur_dir + 'tmp1' ) new
  USE ( cur_dir + 'tmp2' ) index ( cur_dir + 'tmp2' ) new
  IF ireg == 2 // ¯à®â®ª®« á®§¤ ­¨ïï ä®à¬ë 1
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
    add_string( 'à®â®ª®« á®§¤ ­¨ï ä®à¬ë ü1 ¤«ï ””ŽŒ‘ ' + arr_m[ 4 ] )
    add_string( ' [ § à¥£¨áâà¨à®¢ ­­ë¥ áç¥â  ¯® ¤ â¥ …ƒˆ‘’€–ˆˆ ]' )
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
            add_string( Replicate( 'Ä', 53 ) )
            add_string( PadR( at1[ j, 1 ], 50 ) + PadR( at1[ j, 2 ], 3 ) )
            add_string( Replicate( 'Ä', 53 ) )
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
            add_string( Replicate( 'Ä', 63 ) )
            IF at_r2[ j, 5 ] == 0
              add_string( PadR( at_r2[ j -1, 1 ], 21 ) + PadR( at_r2[ j -1, 2 ], 4 ) + PadR( at_r2[ j -1, 3 ], 4 ) )
            ENDIF
            au := {}
            add_string( PadR( at_r2[ j, 1 ], 21 ) + PadR( at_r2[ j, 2 ], 4 ) + PadR( at_r2[ j, 3 ], 4 ) )
            add_string( Replicate( 'Ä', 63 ) )
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
              s := '¯® ¢á¥¬ áç¥â ¬: '
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
    add_string( '”®à¬  ü1 ¤«ï ””ŽŒ‘ ' + arr_m[ 4 ] + ' (¯® ¯à¨ª §ã ”ŽŒ‘ ü146 ®â 16.08.11)' )
    add_string( ' [ § à¥£¨áâà¨à®¢ ­­ë¥ áç¥â  ¯® ¤ â¥ …ƒˆ‘’€–ˆˆ ]' )
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
    add_string( 'ˆ ’ Ž ƒ Ž' )
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
  arr_title2[ 1 ] := '              ¤àã£¨å áã¡ê¥ªâ®¢ ®áá¨©áª®© ”¥¤¥à æ¨¨, ¬¥¤¨æ¨­áª®© ¯®¬®é¨'
  Ins_Array( arr_title2, 1, '   §¤¥« III. ‘¢¥¤¥­¨ï ®¡ ®ª § ­­®© «¨æ ¬, § áâà å®¢ ­­ë¬ ­  â¥àà¨â®à¨¨' )
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
    AAdd( arr_smo, { '’”ŽŒ‘ (¨­®£®à®¤­¨¥)', 34 } )
    i := Len( arr_smo ) // ¤«ï ’”ŽŒ‘
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
          add_string( Replicate( 'Ä', 53 ) )
          add_string( PadR( at2[ j, 1 ], 50 ) + PadR( at2[ j, 2 ], 3 ) )
          add_string( Replicate( 'Ä', 53 ) )
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
          add_string( Replicate( 'Ä', 63 ) )
          IF at_r2[ j, 5 ] == 0
            add_string( PadR( at_r2[ j -1, 1 ], 21 ) + PadR( at_r2[ j -1, 2 ], 4 ) + PadR( at_r2[ j -1, 3 ], 4 ) )
          ENDIF
          au := {}
          add_string( PadR( at_r2[ j, 1 ], 21 ) + PadR( at_r2[ j, 2 ], 4 ) + PadR( at_r2[ j, 3 ], 4 ) )
          add_string( Replicate( 'Ä', 63 ) )
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
            s := '¯® ¢á¥¬ áç¥â ¬: '
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
