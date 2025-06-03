#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 22.06.17
Function forma_792_miac()
  Local fl_exit := .f., arr_f := { 'str_komp',, 'komitet' }, i, j, k, v, koef, msum, ifin, ;
    acomp := {}, ldate_r, y, m, d, buf := save_maxrow(), ;
    begin_date := SToD( '20160101' ), end_date := SToD( '20161231' )

  Private arr_m := { 2016, 1, 12, 'ß† 2016 £Æ§', begin_date, end_date, dtoc4( begin_date ), dtoc4( end_date ) }

  waitstatus( arr_m[ 4 ] )
  For i := 1 To 3
    If i != 2 .and. hb_FileExists( dir_server() + arr_f[ i ] + sdbf() )
      r_use( dir_server() + arr_f[ i ],, '_B' )
      Go Top
      Do While !Eof()
        If iif( i == 1, !Between( _b->tfoms, 44, 47 ), .t. ) .and. _b->ist_fin == I_FIN_BUD
          AAdd( acomp, { i, _b->kod } ) // ·Ø®·Æ™ °Ó§¶•‚≠ÎÂ ™Æ¨Ø†≠®©
        Endif
        Skip
      Enddo
      Use
    Endif
  Next
  dbCreate( cur_dir() + 'tmp', { { 'nstr', 'N', 1, 0 }, ;
    { 'oms', 'N', 1, 0 }, ;
    { 'profil', 'N', 3, 0 }, ;
    { 'kol1', 'N', 6, 0 }, ;
    { 'sum1', 'N', 15, 2 }, ;
    { 'kol2', 'N', 6, 0 }, ;
    { 'sum2', 'N', 15, 2 }, ;
    { 'kol3', 'N', 6, 0 }, ;
    { 'sum3', 'N', 15, 2 }, ;
    { 'kol4', 'N', 6, 0 }, ;
    { 'sum4', 'N', 15, 2 }, ;
    { 'kol', 'N', 6, 0 }, ;
    { 'sum', 'N', 15, 2 } } )
  Use ( cur_dir() + 'tmp' ) New Alias TMP
  Index On Str( oms, 1 ) + Str( nstr, 1 ) + Str( profil, 3 ) to ( cur_dir() + 'tmp' )
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
    If human_->USL_OK == 1 .and. ( j := f1forma_792_miac( human->kod_diag ) ) > 0 // ·‚†Ê®Æ≠†‡
      ifin := msum := 0 ; koef := 1 ; fl := .f.
      If human->schet > 0
        schet->( dbGoto( human->schet ) )
        If ( fl := ( schet_->NREGISTR == 0 ) ) // ‚Æ´Ï™Æ ß†‡•£®·‚‡®‡Æ¢†≠≠Î•
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
          If ( fl := ( koef > 0 ) )
            msum := Round( human->cena_1 * koef, 2 )
            ifin := 1
          Endif
        Endif
      Endif
      If !fl .and. AScan( acomp, {| x| x[ 1 ] == human->komu .and. x[ 2 ] == human->str_crb } ) > 0 // °Ó§¶•‚
        msum := human->cena_1
        ifin := 2
      Endif
      If ifin > 0
        ldate_r := human->DATE_R
        If human_->NOVOR > 0
          ldate_r := human_->DATE_R2
        Endif
        count_ymd( ldate_r, human->n_data, @y, @m, @d )
        If y == 0 .or. ( y == 1 .and. m == 0 .and. d == 0 )
          v := 1
        Elseif y < 17
          v := 2
        Elseif y < 60
          v := 3
        Else
          v := 4
        Endif
        polek := 'tmp->kol' + lstr( v )
        poles := 'tmp->sum' + lstr( v )
        Select TMP
        find ( Str( ifin, 1 ) + Str( j, 1 ) + Str( 0, 3 ) )
        If !Found()
          Append Blank
          tmp->nstr := j
          tmp->oms := ifin
          tmp->profil := 0
        Endif
        &( polek ) ++
        &( poles ) += msum
        tmp->kol++
        tmp->sum += msum
        Select TMP
        find ( Str( ifin, 1 ) + Str( j, 1 ) + Str( human_->profil, 3 ) )
        If !Found()
          Append Blank
          tmp->nstr := j
          tmp->oms := ifin
          tmp->profil := human_->profil
        Endif
        &( polek ) ++
        &( poles ) += msum
        tmp->kol++
        tmp->sum += msum
        Select TMP
        find ( Str( ifin, 1 ) + Str( 0, 1 ) + Str( human_->profil, 3 ) )
        If !Found()
          Append Blank
          tmp->nstr := 0
          tmp->oms := ifin
          tmp->profil := human_->profil
        Endif
        &( polek ) ++
        &( poles ) += msum
        tmp->kol++
        tmp->sum += msum
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  If !fl_exit
    If tmp->( LastRec() ) > 0
      HH := 80
      arr_title := { ;
        'ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ', ;
        '       ≥    §Æ 1 £Æ§†      ≥  Æ‚ 1 £. §Æ 16 ´•‚≥   Æ‚ 17 §Æ 59 ´•‚ ≥ Æ‚ 60 ´•‚ ® ·‚†‡Ë•≥      ¢·•£Æ        ', ;
        '       ≥ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≥ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≥ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≥ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≥ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ', ;
        'åäÅ-10 ≥ ™Æ´. ≥   ·„¨¨†    ≥ ™Æ´. ≥   ·„¨¨†    ≥ ™Æ´. ≥   ·„¨¨†    ≥ ™Æ´. ≥   ·„¨¨†    ≥ ™Æ´. ≥   ·„¨¨†    ', ;
        'ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ' }
      sh := Len( arr_title[ 1 ] )
      //
      nfile := 'pr_792.txt'
      fp := FCreate( nfile ) ; n_list := 1 ; tek_stroke := 0
      add_string( Center( 'î†™‚®Á•·™®• ØÆ™†ß†‚•´® Æ°ÍÒ¨† ® ‰®≠†≠·Æ¢Æ£Æ Æ°•·Ø•Á•≠®Ô ·Ø•Ê®†´®ß®‡Æ¢†≠≠Æ© ¨•§®Ê®≠·™Æ© ØÆ¨ÆÈ®, Æ™†ß†≠≠Æ© ¢', sh ) )
      add_string( Center( '·‚†Ê®Æ≠†‡≠ÎÂ „·´Æ¢®ÔÂ, ØÆ Æ‚§•´Ï≠Î¨ Ø‡Æ‰®´Ô¨ ¨•§®Ê®≠·™Æ© ØÆ¨ÆÈ® ß† 2016 £Æ§ (¢ ‚Î·.‡„°.)', sh ) )
      For ifin := 1 To 2
        Select TMP
        find ( Str( ifin, 1 ) )
        If Found()
          add_string( '' )
          add_string( Center( { 'éåë', '°Ó§¶•‚' }[ ifin ], sh ) )
          AEval( arr_title, {| x| add_string( x ) } )
          add_string( Center( 'Ñ®†£≠ÆßÎ + Ø‡Æ‰®´®', sh ) )
          add_string( Replicate( 'ƒ', sh ) )
          For j := 1 To 5
            s := { 'E10-E14', 'C00-C97', 'A00-B99', 'J00-J99', 'P35-P39' }[ j ]
            find ( Str( ifin, 1 ) + Str( j, 1 ) + Str( 0, 3 ) )
            If Found()
              For v := 1 To 4
                polek := 'tmp->kol' + lstr( v )
                poles := 'tmp->sum' + lstr( v )
                If Empty( &( polek ) )
                  s += Space( 20 )
                Else
                  s += Str( &( polek ), 7 ) + Str( &( poles ) / 1000, 13, 3 )
                Endif
              Next v
              s += Str( tmp->kol, 7 ) + Str( tmp->sum / 1000, 13, 3 )
            Endif
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( s )
            dbSeek( Str( ifin, 1 ) + Str( j, 1 ) + Str( 1, 3 ), .t. )
            Do While tmp->nstr == j .and. tmp->oms == ifin .and. !Eof()
              If verify_ff( HH - 1, .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              add_string( '- ' + inieditspr( A__MENUVERT, getv002(), tmp->PROFIL ) )
              s := Space( 7 )
              For v := 1 To 4
                polek := 'tmp->kol' + lstr( v )
                poles := 'tmp->sum' + lstr( v )
                If Empty( &( polek ) )
                  s += Space( 20 )
                Else
                  s += Str( &( polek ), 7 ) + Str( &( poles ) / 1000, 13, 3 )
                Endif
              Next v
              s += Str( tmp->kol, 7 ) + Str( tmp->sum / 1000, 13, 3 )
              add_string( s )
              Skip
            Enddo
            add_string( Replicate( 'ƒ', sh ) )
          Next j
          add_string( Center( 'è‡Æ‰®´®', sh ) )
          add_string( Replicate( 'ƒ', sh ) )
          dbSeek( Str( ifin, 1 ) + Str( 0, 1 ), .t. )
          Do While tmp->nstr == 0 .and. tmp->oms == ifin .and. !Eof()
            If verify_ff( HH - 1, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( inieditspr( A__MENUVERT, getv002(), tmp->PROFIL ) )
            s := Space( 7 )
            For v := 1 To 4
              polek := 'tmp->kol' + lstr( v )
              poles := 'tmp->sum' + lstr( v )
              If Empty( &( polek ) )
                s += Space( 20 )
              Else
                s += Str( &( polek ), 7 ) + Str( &( poles ) / 1000, 13, 3 )
              Endif
            Next v
            s += Str( tmp->kol, 7 ) + Str( tmp->sum / 1000, 13, 3 )
            add_string( s )
            Skip
          Enddo
        Endif
      Next ifin
      FClose( fp )
      Close databases
      rest_box( buf )
      viewtext( nfile,,,, .t.,,, 6 )
    Else
      func_error( 4, 'ç•‚ ®≠‰Æ‡¨†Ê®® ØÆ ·‚†Ê®Æ≠†‡„ ß† 2016 £Æ§!' )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 22.06.17
Function f1forma_792_miac( mkod_diag )
  Local k := 0, c, s

  c := Left( mkod_diag, 1 )
  s := Left( mkod_diag, 3 )
  If c == 'C'
    k := 2
  Elseif c == 'J'
    k := 4
  Elseif c == 'A' .or. c == 'B'
    k := 3
  Elseif Between( s, 'E10', 'E14' )
    k := 1
  Elseif Between( s, 'P35', 'P39' )
    k := 5
  Endif

  Return k