#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// à®á¬®âà ¨ ¯¥ç âì ¢ë¯¨á ­­ëå áç¥â®¢/à¥¥áâà®¢ ­  ¤®¯« âã
Function print_schet_doplata( reg )

  // reg = 1 - ¤®¯« â  ’”ŽŒ‘
  // reg = 2 - ¤®¯« â  ””ŽŒ‘
  Local arr_title, arr1title, sh, HH := 57, n_file := cur_dir + 'schetd' + stxt, ;
    s, i, j, j1, a_shifr[ 10 ], k1, k2, k3, lshifr, v_doplata, rec, ;
    buf := save_maxrow(), t_arr[ 2 ], llpu, lbank, ssumma := 0, ;
    fl_numeration, is_20_11, sdate := SToD( '20121120' ) // 20.11.2012£.

  If schet_->NREGISTR == 0 // § à¥£¨áâà¨à®¢ ­­ë¥ áç¥â 
    is_20_11 := ( date_reg_schet() >= sdate )
  Else
    is_20_11 := ( schet_->DSCHET > SToD( '20121210' ) ) // 10.12.2012£.
  Endif
  s1 := iif( reg == 2, Space( 11 ), '¨ á®¯ãâáâ. ' )
  s2 := iif( reg == 2, Space( 11 ), '¤¨ £­®§    ' )
  arr_title := { ;
    'ÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ', ;
    'ü   ³ü áç¥â  ¯® ŽŒ‘ ³ü áâà å®¢®£®³„ â     ³Š®¤       ³Š®¤        ³„®¯« â  ¯®    ', ;
    '¯®§¨³               ³á«ãç ï ¢    ³áç¥â  ¯®³§ ª®­ç¥­- ³®á­®¢­®£®  ³¤ ­­®© ãá«ã£¥ ', ;
    'æ¨¨ ³               ³áç¥â¥ ¯® ŽŒ‘³ŽŒ‘     ³­®£®      ³¤¨ £­®§    ³¨§ áà¥¤áâ¢    ', ;
    'à¥¥á³               ³            ³        ³á«ãç ï    ³' + s1 +     '³¡î¤¦¥â  ' + iif( reg == 2, '””ŽŒ‘ ', '’”ŽŒ‘ ' ), ;
    'âà  ³               ³            ³        ³          ³' + s2 +     '³(àã¡«¥©)      ', ;
    'ÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄ', ;
    ' 1  ³       2       ³      3     ³   4    ³    5     ³     6     ³       7      ', ;
    'ÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ' }
  arr1title := { ;
    'ÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ', ;
    ' 1  ³       2       ³      3     ³   4    ³    5     ³     6     ³       7      ', ;
    'ÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ' }
  //
  use_base( 'lusl' )
  use_base( 'lusld' )
  use_base( 'luslf' )
  r_use( dir_server + 'uslugi', , 'USL' )
  r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
  Set Relation To u_kod into USL
  r_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', dir_server + 'humans', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  r_use( dir_server + 'organiz', , 'ORG' )
  r_use( dir_server + 'schetd', , 'SD' )
  Index On Str( kod, 6 ) to ( cur_dir + 'tmp_sd' )
  //
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( Center( '‘ç¥â ü ' + AllTrim( schet_->nschet ) + ' ®â ' + full_date( schet_->dschet ) + ' £.', sh ) )
  s := '­  ®¯« âã ¬¥¤¨æ¨­áª®© ¯®¬®é¨ §  áç¥â áà¥¤áâ¢ ¡î¤¦¥â  ' + iif( reg == 2, '”¥¤¥à «ì­®£®', '’¥àà¨â®à¨ «ì­®£®' ) + ' ä®­¤  '
  s += '®¡ï§ â¥«ì­®£® ¬¥¤¨æ¨­áª®£® áâà å®¢ ­¨ï ' + iif( reg == 2, '', '‚®«£®£à ¤áª®© ®¡« áâ¨ ' ) + '¯® à®£à ¬¬¥ ¬®¤¥à­¨§ æ¨¨ §¤à ¢®®åà ­¥­¨ï '
  s += '‚®«£®£à ¤áª®© ®¡« áâ¨ ­  2011-2012 £®¤ë ¢ ç áâ¨ à¥ «¨§ æ¨¨ ¬¥à®¯à¨ïâ¨© ¯® '
  s += '¯®íâ ¯­®¬ã ¢­¥¤à¥­¨î áâ ­¤ àâ®¢ ¬¥¤¨æ¨­áª®© ¯®¬®é¨'
  For k := 1 To perenos( t_arr, s, sh )
    add_string( Center( AllTrim( t_arr[ k ] ), sh ) )
  Next
  add_string( '' )
  sinn := org->inn
  skpp := ''
  If '/' $ sinn
    skpp := AfterAtNum( '/', sinn )
    sinn := BeforAtNum( '/', sinn )
  Endif
  sname    := org->name
  sbank    := org->bank
  sr_schet := org->r_schet
  sbik     := org->smfo
  If reg == 2
    If !Empty( org->r_schet2 )
      sbank    := org->bank2
      sr_schet := org->r_schet2
      sbik     := org->smfo2
    Endif
    If !Empty( org->name2 )
      sname := org->name2
    Endif
  Endif
  k := perenos( t_arr, sname, sh -11 )
  add_string( '®áâ ¢é¨ª: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 11 ) + t_arr[ 2 ] )
  Next
  add_string( 'ˆ: ' + PadR( sinn, 12 ) + ', Š: ' + skpp )
  add_string( '€¤à¥á: ' + RTrim( org->adres ) )
  k := perenos( t_arr, sbank, sh -17 )
  add_string( ' ­ª ¯®áâ ¢é¨ª : ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 17 ) + t_arr[ 2 ] )
  Next
  add_string( ' áç¥â­ë© áç¥â: ' + AllTrim( sr_schet ) + ', ˆŠ: ' + AllTrim( sbik ) )
  add_string( '' )
  add_string( '' )
  If ( j := AScan( get_rekv_smo(), {| x| x[ 1 ] == schet_->SMO } ) ) == 0
    j := Len( get_rekv_smo() ) // ¥á«¨ ­¥ ­ è«¨ - ¯¥ç â ¥¬ à¥ª¢¨§¨âë ’”ŽŒ‘
  Endif
  k := perenos( t_arr, get_rekv_smo()[ j, 2 ], sh -12 )
  add_string( '« â¥«ìé¨ª: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 12 ) + t_arr[ 2 ] )
  Next
  add_string( 'ˆ: ' + get_rekv_smo()[ j, 3 ] + ', Š: ' + get_rekv_smo()[ j, 4 ] )
  k := perenos( t_arr, get_rekv_smo()[ j, 6 ], sh -7 )
  add_string( '€¤à¥á: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 7 ) + t_arr[ 2 ] )
  Next
  k := perenos( t_arr, get_rekv_smo()[ j, 7 ], sh -18 )
  add_string( ' ­ª ¯« â¥«ìé¨ª : ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 18 ) + t_arr[ 2 ] )
  Next
  add_string( ' áç¥â­ë© áç¥â: ' + AllTrim( get_rekv_smo()[ j, 8 ] ) + ', ˆŠ: ' + AllTrim( get_rekv_smo()[ j, 9 ] ) )
  add_string( '' )
  add_string( '' )
  add_string( Center( '¥¥áâà áç¥â  ü ' + AllTrim( schet_->nschet ) + ' ®â ' + full_date( schet_->dschet ) + ' £.', sh ) )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  Select SCHET
  fl_numeration := emptyany( schet_->nyear, schet_->nmonth )
  rec := RecNo()
  Set Index To
  j := 0
  Select SD
  find ( Str( rec, 6 ) )
  Do While sd->kod == rec .and. !Eof()
    schet->( dbGoto( sd->kod2 ) )
    j1 := 0
    Select HUMAN
    find ( Str( sd->kod2, 6 ) )
    Do While human->schet == sd->kod2 .and. !Eof()
      lshifr := ''
      v_doplata := r_doplata := 0
      ret_zak_sl( @lshifr, @v_doplata, @r_doplata, , , iif( is_20_11, sdate, nil ) )
      If iif( reg == 1, !Empty( r_doplata ), .t. )
        a_diag := diag_for_xml(, .t., , , .t. )
        s_diag := a_diag[ 1 ]
        If reg == 1 .and. Len( a_diag ) > 1 .and. !Empty( a_diag[ 2 ] )
          s_diag += ' ' + a_diag[ 2 ]
        Endif
        s := PadR( lstr( ++j ), 5 ) + ;
          PadC( AllTrim( schet_->nschet ), 15 ) + ' ' + ;
          PadR( Str( iif( fl_numeration, ++j1, human_->SCHET_ZAP ), 7 ), 13 ) + ;
          date_8( schet_->dschet ) + ' ' + ;
          PadC( lshifr, 10 ) + ;
          PadC( AllTrim( s_diag ), 13 ) + ;
          Str( iif( reg == 2, v_doplata, r_doplata ), 11, 2 )
        ssumma += iif( reg == 2, v_doplata, r_doplata )
        If verify_ff( HH, .t., sh )
          AEval( arr1title, {| x| add_string( x ) } )
        Endif
        add_string( s )
      Endif
      //
      Select HUMAN
      Skip
    Enddo
    Select SD
    Skip
  Enddo
  If verify_ff( HH -8, .t., sh )
    AEval( arr1title, {| x| add_string( x ) } )
  Endif
  add_string( Replicate( 'Ä', sh ) )
  add_string( PadL( '‚á¥£®: ' + lstr( ssumma, 14, 2 ), sh -3 ) )
  add_string( '' )
  k := perenos( t_arr, 'Š ®¯« â¥: ' + srub_kop( ssumma, .t. ), sh )
  add_string( t_arr[ 1 ] )
  For j := 2 To k
    add_string( PadL( AllTrim( t_arr[ j ] ), sh ) )
  Next
  add_string( '' )
  add_string( '  ƒ« ¢­ë© ¢à ç ¬¥¤¨æ¨­áª®© ®à£ ­¨§ æ¨¨      _____________ / ' + AllTrim( org->ruk ) + ' /' )
  add_string( '  ƒ« ¢­ë© ¡ãå£ «â¥à ¬¥¤¨æ¨­áª®© ®à£ ­¨§ æ¨¨ _____________ / ' + AllTrim( org->bux ) + ' /' )
  add_string( '                                        Œ..' )
  FClose( fp )

  rest_box( buf )
  close_use_base( 'lusl' )
  lusld->( dbCloseArea() )
  close_use_base( 'luslf' )
  usl->( dbCloseArea() )
  hu->( dbCloseArea() )
  human_->( dbCloseArea() )
  human->( dbCloseArea() )
  org->( dbCloseArea() )
  sd->( dbCloseArea() )
  If Select( 'USL1' ) > 0
    usl1->( dbCloseArea() )
  Endif
  Select SCHET
  If !( Round( ssumma, 2 ) == Round( schet->summa, 2 ) )
    // ¥á«¨ ’”ŽŒ‘ ¯®¬¥­ï« æ¥­­¨ª - ¯¥à¥§ ¯¨è¥¬ áã¬¬ã áçñâ 
    Goto ( rec )
    g_rlock( forever )
    schet->summa := schet->summa_ost := ssumma
    Unlock
    Commit
  Endif
  Set Index to ( cur_dir + 'tmp_sch' )
  Goto ( rec )
  viewtext( n_file, , , , .t., , , 2 )

  Return Nil

