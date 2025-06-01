#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 23.11.23 ˆ­ä®à¬ æ¨ï ® ª®«¨ç¥áâ¢¥ ã¤ «ñ­­ëå ¯®áâ®ï­­ëå §ã¡®¢ á 2005 ¯® 2015 £®¤ë
Function i_kol_del_zub( par )
  Local fl_exit := .f., hGauge

  hGauge := gaugenew(,,, 'ˆ­ä®à¬ æ¨ï ® ª®«¨ç¥áâ¢¥ ã¤ «ñ­­ëå §ã¡®¢', .t. )
  gaugedisplay( hGauge )
  dbCreate( cur_dir() + 'tmp', { ;
    { 'god', 'N', 4, 0 }, ;
    { 'kod_k', 'N', 7, 0 }, ;
    { 'pol', 'C', 1, 0 }, ;
    { 'vozr', 'N', 2, 0 }, ;
    { 'kol', 'N', 6, 0 } } )
  Use ( cur_dir() + 'tmp' ) new
  Index On Str( god, 4 ) + Str( kod_k, 7 ) To tmp memory
  use_base( 'lusl' )
  r_use( dir_server + 'uslugi',, 'USL' )
  r_use( dir_server + 'human_u_',, 'HU_' )
  r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server + 'human_2',, 'HUMAN_2' )
  r_use( dir_server + 'human_',, 'HUMAN_' )
  r_use( dir_server + 'human',, 'HUMAN' )
  Set Relation To kod into HUMAN_, To kod into HUMAN_2
  Go Top
  Do While !Eof()
    gaugeupdate( hGauge, RecNo() / LastRec() )
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If human->kod > 0 .and. human_->oplata != 9
      lgod := Year( human->k_data )
      If Between( lgod, 2005, 2015 )
        lkol := 0
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If between_shifr( lshifr, '57.3.2', '57.3.8' ) .or. between_shifr( lshifr, '57.8.72', '57.8.78' )
              lkol += hu->kol_1
            Endif
          Endif
          Select HU
          Skip
        Enddo
        If lkol > 0
          Select TMP
          find ( Str( lgod, 4 ) + Str( human->kod_k, 7 ) )
          If !Found()
            Append Blank
            tmp->god := lgod
            tmp->kod_k := human->kod_k
            tmp->pol := human->pol
            k := lgod - Year( human->date_r )
            tmp->vozr := iif( k < 100, k, 99 )
          Endif
          tmp->kol += lkol
        Endif
      Endif
    Endif
    Select HUMAN
    If RecNo() % 5000 == 0
      Commit
    Endif
    Skip
  Enddo
  closegauge( hGauge )
  k := tmp->( LastRec() )
  Close databases
  If !fl_exit .and. k > 0
    agod := {}
    Use ( cur_dir() + 'tmp' ) new
    Index On god To tmp Unique memory
    dbEval( {|| AAdd( agod, tmp->god ) } )
    name_file := 'del_zub.txt'
    HH := 60
    arr_title := { ;
      'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ', ;
      '                 ³   ¬ã¦ç¨­ë     ³    ¦¥­é¨­ë    ³    ¢á¥£®      ', ;
      '‚®§à áâ­®© ¯¥à¨®¤ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ', ;
      '                 ³ §ã¡®¢ ³ç¥«®¢¥ª³ §ã¡®¢ ³ç¥«®¢¥ª³ §ã¡®¢ ³ç¥«®¢¥ª', ;
      'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ';
      }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( glob_mo[ _MO_SHORT_NAME ] )
    add_string( '' )
    add_string( Center( 'ˆ­ä®à¬ æ¨ï ® ª®«¨ç¥áâ¢¥ ã¤ «ñ­­ëå ¯®áâ®ï­­ëå §ã¡®¢', sh ) )
    AEval( arr_title, {| x| add_string( x ) } )
    arr := Array( 6, 6 )
    Select TMP
    For ig := 1 To Len( agod )
      Index On Str( kod_k, 7 ) To tmp For god == agod[ ig ] memory
      afillall( arr, 0 )
      Go Top
      Do While !Eof()
        If tmp->vozr < 21
          j := 1
        Elseif tmp->vozr < 36
          j := 2
        Elseif tmp->vozr < 61
          j := 3
        Elseif tmp->vozr < 76
          j := 4
        Else
          j := 5
        Endif
        k := iif( tmp->pol == 'Œ', 1, 3 )
        ax := { j, 6 } ; ay1 := { k, 5 } ; ay2 := { k + 1, 6 }
        For ix := 1 To 2
          x := ax[ ix ]
          For iy := 1 To 2
            y := ay1[ iy ]
            arr[ x, y ] += tmp->kol
            y := ay2[ iy ]
            arr[ x, y ] ++
          Next iy
        Next ix
        Select TMP
        Skip
      Enddo
      If verify_ff( HH - 8, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( '' )
      add_string( PadC( '¢ ' + lstr( agod[ ig ] ) + ' £®¤ã', sh, '_' ) )
      For i := 1 To 6
        s := { '¤® 20 «¥â', '21-35 «¥â', '36-60 «¥â', '61-75 «¥â', 'áâ àè¥ 75 «¥â', 'ˆâ®£®' }[ i ]
        s := PadC( s, 17 )
        For j := 1 To 6
          s += put_val( arr[ i, j ], 8 )
        Next
        add_string( s )
      Next
    Next
    Close databases
    FClose( fp )
    viewtext( name_file,,,, .t.,,, 1 )
  Endif

  Return Nil
