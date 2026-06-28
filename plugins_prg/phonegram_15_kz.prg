#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 00.06.26 í•´•‰Æ≠Æ£‡†¨¨† ¸15 Çé äá
Function phonegram_15_kz()
  Local fl_exit := .f., i, j, k, v, koef, msum, ifin, ldate_r, y, m, buf := save_maxrow(), ;
    mkol, mdni, akslp, begin_date := SToD( '20170101' ), end_date := SToD( '20170630' )

  Private arr_m := { 2017, 1, 6, 'ß† 1-Æ• ØÆ´„£Æ§®• 2017 £Æ§†', ;
    begin_date, end_date, dtoc4( begin_date ), dtoc4( end_date ) }

  waitstatus( arr_m[ 4 ] )
  dbCreate( cur_dir() + 'tmp', { { 'nstr', 'N', 1, 0 }, ;
    { 'oms', 'N', 1, 0 }, ;
    { 'mm', 'N', 2, 0 }, ;
    { 'kol', 'N', 6, 0 }, ;
    { 'dni', 'N', 6, 0 }, ;
    { 'sum', 'N', 15, 2 }, ;
    { 'kslp', 'N', 15, 2 } } )
  Use ( cur_dir() + 'tmp' ) New Alias TMP
  Index On Str( oms, 1 ) + Str( nstr, 1 ) + Str( mm, 2 ) to ( cur_dir() + 'tmp' )
  r_use( dir_server() + 'mo_rak',, 'RAK' )
  r_use( dir_server() + 'mo_raks',, 'RAKS' )
  Set Relation To akt into RAK
  r_use( dir_server() + 'mo_raksh',, 'RAKSH' )
  Set Relation To kod_raks into RAKS
  Index On Str( kod_h, 7 ) to ( cur_dir() + 'tmp_raksh' )
  //
  r_use( dir_server() + 'schet_',, 'SCHET_' )
  r_use( dir_server() + 'schet',, 'SCHET' )
  Set Relation To RecNo() into SCHET_
  //
  r_use( dir_server() + 'uslugi',, 'USL' )
  g_use( dir_server() + 'human_u_',, 'HU_' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  Set Relation To RecNo() into HU_, To u_kod into USL
  //
  r_use( dir_server() + 'human_2',, 'HUMAN_2' )
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    @ MaxRow(), 0 Say date_8( human->k_data ) Color 'W/R'
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If human_->USL_OK == 1 .and. f_starshe_trudosp( human->POL, human->DATE_R, human->n_data )
      mkol := 1 ; mdni := 0 ; akslp := {} ; fl := .t.
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
        If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
          lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
          If Left( lshifr, 1 ) == '1' .and. !( '.' $ lshifr ) // Ì‚Æ Ë®‰‡ äëÉ (™‡„£´Æ·„‚ÆÁ≠Î© ·‚†Ê®Æ≠†‡)
            If Int( Val( Right( lshifr, 3 ) ) ) >= 900 // ØÆ·´•§≠®• ‚‡® Ê®‰‡Î - ™Æ§ äëÉ
              fl := .f.
              mkol := 0 // §®†´®ß ≠• „Á®‚Î¢†•¨ ™Æ´®Á•·‚¢•≠≠Æ
            Endif
            If fl
              akslp := f_cena_kslp( iif( hu->usl_repl == 1, 0, hu->stoim ), lshifr, iif( human_->NOVOR == 0, human->date_r, human_->DATE_R2 ), human->n_data, human->k_data )
              If !Empty( akslp )
                fl := .f.
              Endif
            Endif
          Endif
        Endif
        Select HU
        Skip
      Enddo
      If Empty( akslp )
        akslp := { 0, 0 }
      Endif
      ifin := msum := 0 ; koef := 1
      If human->schet > 0 // ØÆØ†´ ¢ ·Á•‚ éåë
        schet->( dbGoto( human->schet ) )
        If ( fl := ( schet_->NREGISTR == 0 ) ) // ‚Æ´Ï™Æ ß†‡•£®·‚‡®‡Æ¢†≠≠Î• ·Á•‚†
          // ØÆ „¨Æ´Á†≠®Ó ÆØ´†Á•≠, •·´® §†¶• ≠•‚ êÄä†
          k := 0
          Select RAKSH
          find ( Str( human->kod, 7 ) )
          Do While human->kod == raksh->kod_h .and. !Eof()
            k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
            Skip
          Enddo
          If !Empty( Round( k, 2 ) )
            If round_5( human->cena_1, 2 ) <= round_5( k, 2 ) // ØÆ´≠Æ• ·≠Ô‚®•
              koef := 0
            Else // Á†·‚®Á≠Æ• ·≠Ô‚®•
              koef := ( human->cena_1 - k ) / human->cena_1
            Endif
          Endif
          If koef > 0
            msum := Round( human->cena_1 * koef, 2 )
            ifin := 1
          Endif
        Endif
      Endif
      ldate_r := human->DATE_R
      If human_->NOVOR > 0
        ldate_r := human_->DATE_R2
      Endif
      count_ymd( ldate_r, human->n_data, @y )
      v := { 1, 0, 0 }
      If y >= 60
        v[ 2 ] := 1
      Endif
      If y >= 75
        v[ 3 ] := 1
      Endif
      m := Month( human->k_data )
      If mkol > 0 .and. ( mdni := human->k_data - human->n_data ) == 0
        mdni := 1
      Endif
      For i := 1 To 3
        If v[ i ] > 0
          Select TMP
          find ( Str( 0, 1 ) + Str( i, 1 ) + Str( m, 2 ) )
          If !Found()
            Append Blank
            tmp->nstr := i
            tmp->oms := 0
            tmp->mm := m
          Endif
          tmp->kol += mkol
          tmp->dni += mdni
          tmp->sum += human->cena_1
          If !Empty( akslp[ 2 ] )
            tmp->kslp += ( human->cena_1 - round_5( human->cena_1 / akslp[ 2 ], 1 ) )
          Endif
        Endif
      Next i
      If ifin == 1 // ØÆØ†´ ¢ éåë
        For i := 1 To 3
          If v[ i ] > 0
            Select TMP
            find ( Str( 1, 1 ) + Str( i, 1 ) + Str( m, 2 ) )
            If !Found()
              Append Blank
              tmp->nstr := i
              tmp->oms := 1
              tmp->mm := m
            Endif
            tmp->kol += mkol
            tmp->dni += mdni
            tmp->sum += msum
            If !Empty( akslp[ 2 ] )
              tmp->kslp += ( msum - round_5( msum / akslp[ 2 ], 1 ) )
            Endif
          Endif
        Next i
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  If !fl_exit
    If tmp->( LastRec() ) > 0
      HH := 80
      arr_title := { ;
        'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ', ;
        '  ÇÆß‡†·‚       ≥ ß≠†Á•≠®• ≥   Ô≠¢†‡Ï   ≥   ‰•¢‡†´Ï  ≥    ¨†‡‚    ≥   †Ø‡•´Ï   ≥    ¨†©     ≥    ®Ó≠Ï    ≥    àíéÉé    ', ;
        'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒ' }
      sh := Len( arr_title[ 1 ] )
      //
      nfile := 'phone_15.txt'
      fp := FCreate( nfile ) ; n_list := 1 ; tek_stroke := 0
      add_string( Center( 'ë‚†‚®·‚®™† Æ™†ß†≠®Ô ·‚†Ê®Æ≠†‡≠Æ© ¨•§®Ê®≠·™Æ© ØÆ¨ÆÈ® ´®Ê†¨ ØÆ¶®´Æ£Æ ¢Æß‡†·‚†', sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      Select TMP
      For ifin := 0 To 1
        add_string( '' )
        add_string( Center( { 'Ç·•£Æ Ø‡Æ´•Á•≠Æ', 'éåë (ß†‡•£®·‚‡®‡Æ¢†≠Æ ¢ íîéåë)' }[ ifin + 1 ], sh ) )
        AEval( arr_title, {| x| add_string( x ) } )
        For j := 1 To 3
          s1 := { '¨„¶Á®≠Î', '', '' }[ j ]
          s2 := { ' 60 ´•‚ ® ·‚†‡Ë•', '60 ´•‚ ® ·‚†‡Ë•', '75 ´•‚ ® ·‚†‡Ë•' }[ j ]
          s3 := { '¶•≠È®≠Î', '', '' }[ j ]
          s4 := { ' 55 ´•‚ ® ·‚†‡Ë•', '', '' }[ j ]
          s1 := PadR( s1, 17 ) + '°Æ´Ï≠ÎÂ   '
          s2 := PadR( s2, 17 ) + '™Æ©™Æ-§≠•©'
          s3 := PadR( s3, 17 ) + '·„¨¨†     '
          s4 := PadR( s4, 17 ) + '≠†§°(äëãè)'
          ss := { 0, 0, 0, 0 }
          For m := 1 To 6
            find ( Str( ifin, 1 ) + Str( j, 1 ) + Str( m, 2 ) )
            If Found()
              s1 += put_val( tmp->kol, 13 )
              s2 += put_val( tmp->dni, 13 )
              s3 += Str( tmp->sum, 13, 1 )
              s4 += Str( tmp->kslp, 13, 1 )
              ss[ 1 ] += tmp->kol
              ss[ 2 ] += tmp->dni
              ss[ 3 ] += tmp->sum
              ss[ 4 ] += tmp->kslp
            Else
              s1 += Space( 13 )
              s2 += Space( 13 )
              s3 += Space( 13 )
              s4 += Space( 13 )
            Endif
          Next m
          s1 += put_val( ss[ 1 ], 14 )
          s2 += put_val( ss[ 2 ], 14 )
          s3 += Str( ss[ 3 ], 14, 1 )
          s4 += Str( ss[ 4 ], 14, 1 )
          add_string( s1 )
          add_string( s2 )
          add_string( s3 )
          add_string( s4 )
          add_string( Replicate( 'ƒ', sh ) )
        Next j
      Next ifin
      FClose( fp )
      Close databases
      rest_box( buf )
      viewtext( nfile,,,, .t.,,, 3 )
    Else
      func_error( 4, 'ç•‚ ®≠‰Æ‡¨†Ê®® ØÆ ·‚†Ê®Æ≠†‡„ ß† 2017 £Æ§!' )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil