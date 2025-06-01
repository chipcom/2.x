#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 05.09.21
Function read_arr_dvn( lkod, is_all )

  Local arr, i, sk
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect

  Private mvar

  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server + 'mo_pers',, 'TPERS' )
  Endif

  arr := read_arr_dispans( lkod )
  Default is_all To .t.
  For i := 1 To Len( arr )
    If ValType( arr[ i ] ) == 'A' .and. ValType( arr[ i, 1 ] ) == 'C'
      Do Case
      Case arr[ i, 1 ] == 'VB' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1veteran := arr[ i, 2 ]
      Case arr[ i, 1 ] == '0' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1mobilbr := arr[ i, 2 ]
      Case arr[ i, 1 ] == '1' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1kurenie := arr[ i, 2 ]
      Case arr[ i, 1 ] == '2' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1riskalk := arr[ i, 2 ]
      Case arr[ i, 1 ] == '3' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1pod_alk := arr[ i, 2 ]
      Case arr[ i, 1 ] == '3.1' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1psih_na := arr[ i, 2 ]
      Case arr[ i, 1 ] == '4' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1fiz_akt := arr[ i, 2 ]
      Case arr[ i, 1 ] == '5' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ner_pit := arr[ i, 2 ]
      Case arr[ i, 1 ] == '6' .and. ValType( arr[ i, 2 ] ) == 'N'
        mWEIGHT := arr[ i, 2 ]
      Case arr[ i, 1 ] == '7' .and. ValType( arr[ i, 2 ] ) == 'N'
        mHEIGHT := arr[ i, 2 ]
      Case arr[ i, 1 ] == '8' .and. ValType( arr[ i, 2 ] ) == 'N'
        mOKR_TALII := arr[ i, 2 ]
      Case arr[ i, 1 ] == '9' .and. ValType( arr[ i, 2 ] ) == 'N'
        mad1 := arr[ i, 2 ]
      Case arr[ i, 1 ] == '10' .and. ValType( arr[ i, 2 ] ) == 'N'
        mad2 := arr[ i, 2 ]
      Case arr[ i, 1 ] == '11' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1addn := arr[ i, 2 ]
      Case arr[ i, 1 ] == '12' .and. ValType( arr[ i, 2 ] ) == 'N'
        mholest := arr[ i, 2 ]
      Case arr[ i, 1 ] == '13' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1holestdn := arr[ i, 2 ]
      Case arr[ i, 1 ] == '14' .and. ValType( arr[ i, 2 ] ) == 'N'
        mglukoza := arr[ i, 2 ]
      Case arr[ i, 1 ] == '15' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1glukozadn := arr[ i, 2 ]
      Case arr[ i, 1 ] == '16' .and. ValType( arr[ i, 2 ] ) == 'N'
        mssr := arr[ i, 2 ]
      Case is_all .and. eq_any( arr[ i, 1 ], '21', '22', '23', '24', '25' ) .and. ;
          ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 7
        sk := Right( arr[ i, 1 ], 1 )
        pole_diag := 'mdiag' + sk
        pole_1pervich := 'm1pervich' + sk
        pole_1stadia := 'm1stadia' + sk
        pole_1dispans := 'm1dispans' + sk
        pole_1dop := 'm1dop' + sk
        pole_1usl := 'm1usl' + sk
        pole_1san := 'm1san' + sk
        pole_d_diag := 'mddiag' + sk
        pole_d_dispans := 'mddispans' + sk
        pole_dn_dispans := 'mdndispans' + sk
        If ValType( arr[ i, 2, 1 ] ) == 'C'
          &pole_diag := arr[ i, 2, 1 ]
        Endif
        If ValType( arr[ i, 2, 2 ] ) == 'N'
          &pole_1pervich := arr[ i, 2, 2 ]
        Endif
        If ValType( arr[ i, 2, 3 ] ) == 'N'
          &pole_1stadia := arr[ i, 2, 3 ]
        Endif
        If ValType( arr[ i, 2, 4 ] ) == 'N'
          &pole_1dispans := arr[ i, 2, 4 ]
        Endif
        If ValType( arr[ i, 2, 5 ] ) == 'N' .and. Type( pole_1dop ) == 'N'
          &pole_1dop := arr[ i, 2, 5 ]
        Endif
        If ValType( arr[ i, 2, 6 ] ) == 'N' .and. Type( pole_1usl ) == 'N'
          &pole_1usl := arr[ i, 2, 6 ]
        Endif
        If ValType( arr[ i, 2, 7 ] ) == 'N' .and. Type( pole_1san ) == 'N'
          &pole_1san := arr[ i, 2, 7 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 8 .and. ValType( arr[ i, 2, 8 ] ) == 'D' .and. Type( pole_d_diag ) == 'D'
          &pole_d_diag := arr[ i, 2, 8 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 9 .and. ValType( arr[ i, 2, 9 ] ) == 'D' .and. Type( pole_d_dispans ) == 'D'
          &pole_d_dispans := arr[ i, 2, 9 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 10 .and. ValType( arr[ i, 2, 10 ] ) == 'D' .and. Type( pole_dn_dispans ) == 'D'
          &pole_dn_dispans := arr[ i, 2, 10 ]
        Endif
      Case is_all .and. arr[ i, 1 ] == '29' .and. ValType( arr[ i, 2 ] ) == 'A'
        arr_usl_otkaz := arr[ i, 2 ]
      Case arr[ i, 1 ] == '30' .and. ValType( arr[ i, 2 ] ) == 'N'
        // m1GRUPPA := arr[i,2]
      Case arr[ i, 1 ] == '31' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1prof_ko := arr[ i, 2 ]
      Case is_all .and. arr[ i, 1 ] == '40' .and. ValType( arr[ i, 2 ] ) == 'A'
        arr_otklon := arr[ i, 2 ]
      Case arr[ i, 1 ] == '41' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ot_nasl1 := arr[ i, 2 ]
      Case arr[ i, 1 ] == '42' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ot_nasl2 := arr[ i, 2 ]
      Case arr[ i, 1 ] == '43' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ot_nasl3 := arr[ i, 2 ]
      Case arr[ i, 1 ] == '44' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ot_nasl4 := arr[ i, 2 ]
      Case arr[ i, 1 ] == '45' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1dispans  := arr[ i, 2 ]
      Case arr[ i, 1 ] == '46' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1nazn_l   := arr[ i, 2 ]
      Case arr[ i, 1 ] == '47'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1dopo_na  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1dopo_na  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_dopo_na := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '48' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ssh_na   := arr[ i, 2 ]
      Case arr[ i, 1 ] == '49' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1spec_na  := arr[ i, 2 ]
      Case arr[ i, 1 ] == '50'   // .and. valtype(arr[i,2]) == 'N'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1sank_na  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1sank_na  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_sanat := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '51' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1p_otk  := arr[ i, 2 ]
      Case arr[ i, 1 ] == '52'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_v_mo  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_v_mo  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_mo := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '53' .and. ValType( arr[ i, 2 ] ) == 'A'
        arr_mo_spec := arr[ i, 2 ]
      Case arr[ i, 1 ] == '54'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_stac := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_stac := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_stac := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '55' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1profil_stac := arr[ i, 2 ]
      Case arr[ i, 1 ] == '56'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_reab := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_reab := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_reab := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '57' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1profil_kojki := arr[ i, 2 ]
      Endcase
    Endif
  Next

  If ! aliasIsUse
    TPERS->( dbCloseArea() )
    Select( oldSelect )
  Endif

  Return Nil

// 05.09.21
Function save_arr_dvn( lkod )

  Local arr := {}, i, sk, ta
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect

  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'TPERS' )
  Endif

  If Type( 'mfio' ) == 'C'
    AAdd( arr, { 'mfio', AllTrim( mfio ) } )
  Endif
  If Type( 'mdate_r' ) == 'D'
    AAdd( arr, { 'mdate_r', mdate_r } )
  Endif
  AAdd( arr, { 'VB', m1veteran } )  // 'N',ветеран ВОВ (блокадник)
  AAdd( arr, { '0', m1mobilbr } )   // 'N',мобильная бригада
  AAdd( arr, { '1', m1kurenie } )   // 'N',Курение
  AAdd( arr, { '2', m1riskalk } )   // 'N',Алкоголь
  AAdd( arr, { '3', m1pod_alk } )   // 'N',наркотики
  AAdd( arr, { '3.1', m1psih_na } )   // 'N',        направлен к психиатру-наркологу
  AAdd( arr, { '4', m1fiz_akt } )   // 'N',Низкая физическая активность
  AAdd( arr, { '5', m1ner_pit } )   // 'N',Нерациональное питание
  AAdd( arr, { '6', mWEIGHT } )     // 'N',Вес
  AAdd( arr, { '7', mHEIGHT } )     // 'N',рост
  AAdd( arr, { '8', mOKR_TALII } )  // 'N',окружность талии
  AAdd( arr, { '9', mad1 } )        // 'N',Артериальное давление
  AAdd( arr, { '10', mad2 } )        // 'N',Артериальное давление
  AAdd( arr, { '11', m1addn } )      // 'N',Гипотензивная терапия
  AAdd( arr, { '12', mholest } )     // 'N',Общий холестерин
  AAdd( arr, { '13', m1holestdn } )  // 'N',Гиполипидемическая терапия
  AAdd( arr, { '14', mglukoza } )    // 'N',Глюкоза
  AAdd( arr, { '15', m1glukozadn } ) // 'N',Гипогликемическая терапия
  AAdd( arr, { '16', mssr } )        // 'N',Суммарный сердечно-сосудистый риск
  For i := 1 To 5
    sk := lstr( i )
    pole_diag := 'mdiag' + sk
    pole_1pervich := 'm1pervich' + sk
    pole_1stadia := 'm1stadia' + sk
    pole_1dispans := 'm1dispans' + sk
    pole_1dop := 'm1dop' + sk
    pole_1usl := 'm1usl' + sk
    pole_1san := 'm1san' + sk
    pole_d_diag := 'mddiag' + sk
    pole_d_dispans := 'mddispans' + sk
    pole_dn_dispans := 'mdndispans' + sk
    If !Empty( &pole_diag )
      ta := { &pole_diag, ;
        &pole_1pervich, ;
        &pole_1stadia, ;
        &pole_1dispans }
      If Type( pole_1dop ) == 'N' .and. Type( pole_1usl ) == 'N' .and. Type( pole_1san ) == 'N'
        AAdd( ta, &pole_1dop )
        AAdd( ta, &pole_1usl )
        AAdd( ta, &pole_1san )
      Else
        AAdd( ta, 0 )
        AAdd( ta, 0 )
        AAdd( ta, 0 )
      Endif
      If Type( pole_d_diag ) == 'D' .and. Type( pole_d_dispans ) == 'D'
        AAdd( ta, &pole_d_diag )
        AAdd( ta, &pole_d_dispans )
      Else
        AAdd( ta, CToD( '' ) )
        AAdd( ta, CToD( '' ) )
      Endif
      If Type( pole_dn_dispans ) == 'D'
        AAdd( ta, &pole_dn_dispans )
      Else
        AAdd( ta, CToD( '' ) )
      Endif
      AAdd( arr, { lstr( 20 + i ), ta } )
    Endif
  Next i
  If !Empty( arr_usl_otkaz )
    AAdd( arr, { '29', arr_usl_otkaz } ) // массив
  Endif
  AAdd( arr, { '30', m1GRUPPA } )    // 'N1',группа здоровья после дисп-ии
  If Type( 'm1prof_ko' ) == 'N'
    AAdd( arr, { '31', m1prof_ko } )    // 'N1',вид проф.консультирования
  Endif
  // if type('m1ot_nasl1') == 'N'
  AAdd( arr, { '40', arr_otklon } ) // массив
  AAdd( arr, { '41', m1ot_nasl1 } )
  AAdd( arr, { '42', m1ot_nasl2 } )
  AAdd( arr, { '43', m1ot_nasl3 } )
  AAdd( arr, { '44', m1ot_nasl4 } )
  AAdd( arr, { '45', m1dispans } )
  AAdd( arr, { '46', m1nazn_l } )
  If mk_data >= 0d20210801
    If mtab_v_dopo_na != 0
      If TPERS->( dbSeek( Str( mtab_v_dopo_na, 5 ) ) )
        AAdd( arr, { '47', { m1dopo_na, TPERS->kod } } )
      Else
        AAdd( arr, { '47', { m1dopo_na, 0 } } )
      Endif
    Else
      AAdd( arr, { '47', { m1dopo_na, 0 } } )
    Endif
  Else
    AAdd( arr, { '47', m1dopo_na } )
  Endif
  AAdd( arr, { '48', m1ssh_na } )
  AAdd( arr, { '49', m1spec_na } )
  If mk_data >= 0d20210801
    If mtab_v_sanat != 0
      If TPERS->( dbSeek( Str( mtab_v_sanat, 5 ) ) )
        AAdd( arr, { '50', { m1sank_na, TPERS->kod } } )
      Else
        AAdd( arr, { '50', { m1sank_na, 0 } } )
      Endif
    Else
      AAdd( arr, { '50', { m1sank_na, 0 } } )
    Endif
  Else
    AAdd( arr, { '50', m1sank_na } )
  Endif
  // endif
  If Type( 'm1p_otk' ) == 'N'
    AAdd( arr, { '51', m1p_otk } )
  Endif
  If mk_data >= 0d20210801
    If Type( 'm1napr_v_mo' ) == 'N'
      If mtab_v_mo != 0
        If TPERS->( dbSeek( Str( mtab_v_mo, 5 ) ) )
          AAdd( arr, { '52', { m1napr_v_mo, TPERS->kod } } )
        Else
          AAdd( arr, { '52', { m1napr_v_mo, 0 } } )
        Endif
      Else
        AAdd( arr, { '52', { m1napr_v_mo, 0 } } )
      Endif
    Endif
  Else
    If Type( 'm1napr_v_mo' ) == 'N'
      AAdd( arr, { '52', m1napr_v_mo } )
    Endif
  Endif
  If Type( 'arr_mo_spec' ) == 'A'   // .and. !empty(arr_mo_spec)
    AAdd( arr, { '53', arr_mo_spec } ) // массив
  Endif
  If mk_data >= 0d20210801
    If Type( 'm1napr_stac' ) == 'N'
      If mtab_v_stac != 0
        If TPERS->( dbSeek( Str( mtab_v_stac, 5 ) ) )
          AAdd( arr, { '54', { m1napr_stac, TPERS->kod } } )
        Else
          AAdd( arr, { '54', { m1napr_stac, 0 } } )
        Endif
      Else
        AAdd( arr, { '54', { m1napr_stac, 0 } } )
      Endif
    Endif
  Else
    If Type( 'm1napr_stac' ) == 'N'
      AAdd( arr, { '54', m1napr_stac } )
    Endif
  Endif
  If Type( 'm1profil_stac' ) == 'N'
    AAdd( arr, { '55', m1profil_stac } )
  Endif
  If mk_data >= 0d20210801
    If Type( 'm1napr_reab' ) == 'N'
      If mtab_v_reab != 0
        If TPERS->( dbSeek( Str( mtab_v_reab, 5 ) ) )
          AAdd( arr, { '56', { m1napr_reab, TPERS->kod } } )
        Else
          AAdd( arr, { '56', { m1napr_reab, 0 } } )
        Endif
      Else
        AAdd( arr, { '56', { m1napr_reab, 0 } } )
      Endif
    Endif
  Else
    If Type( 'm1napr_reab' ) == 'N'
      AAdd( arr, { '56', m1napr_reab } )
    Endif
  Endif
  If Type( 'm1profil_kojki' ) == 'N'
    AAdd( arr, { '57', m1profil_kojki } )
  Endif

  If ! aliasIsUse
    TPERS->( dbCloseArea() )
    Select( oldSelect )
  Endif

  save_arr_dispans( lkod, arr )

  Return Nil

// 11.06.24
Function fget_spec_dvn( k, r, c, a_spec, lFull )

  Static as := { ;
    { 8, 2 }, ;
    { 255, 1 }, ;
    { 112, 1 }, ;
    { 58, 1 }, ;
    { 65, 1 }, ;
    { 113, 1 }, ;
    { 133, 1 }, ;
    { 257, 1 }, ;
    { 114, 1 }, ;
    { 258, 1 }, ;
    { 115, 1 }, ;
    { 66, 1 }, ;
    { 116, 1 }, ;
    { 10, 1 }, ;
    { 32, 1 }, ;
    { 260, 1 }, ;
    { 118, 1 }, ;
    { 139, 2 }, ;
    { 59, 1 }, ;
    { 67, 1 }, ;
    { 120, 1 }, ;
    { 134, 1 }, ;
    { 14, 2 }, ;
    { 140, 1 }, ;
    { 261, 1 }, ;
    { 123, 1 }, ;
    { 17, 1 }, ;
    { 19, 2 }, ;
    { 20, 2 }, ;
    { 23, 1 }, ;
    { 262, 1 }, ;
    { 125, 1 }, ;
    { 138, 1 }, ;
    { 263, 1 }, ;
    { 126, 1 }, ;
    { 141, 1 }, ;
    { 75, 1 }, ;
    { 28, 1 }, ;
    { 145, 2 }, ;
    { 29, 1 }, ;
    { 30, 2 }, ;
    { 31, 1 }, ;
    { 97, 1 };
    }
  local s, blk, t_arr[ BR_LEN ], n_file := cur_dir() + 'tmpspecdvn', i
  Local tmp_select := Select()

  default lFull to .f.

  If !hb_FileExists( n_file + sdbf )
    dbCreate( n_file, { ;
      { 'name', 'C', 30, 0 }, ;
      { 'kod', 'C', 4, 0 }, ;
      { 'kod_up', 'C', 4, 0 }, ;
      { 'name1', 'C', 50, 0 }, ;
      { 'isn', 'N', 1, 0 }, ;
      { 'is', 'L', 1, 0 } ;
    } )
    Use ( n_file ) New Alias SDVN
    Use ( cur_dir() + 'tmp_v015' ) index ( cur_dir() + 'tmpkV015' ) New Alias tmp_ga
    Go Top
    Do While !Eof()
      if lFull
        Select SDVN
        Append Blank
        sdvn->name := AfterAtNum( '.', tmp_ga->name, 1 )
        sdvn->kod := tmp_ga->kod
//        sdvn->isn := as[ i, 2 ]
        s := ''
        Select TMP_GA
        rec := RecNo()
        Do While !Empty( tmp_ga->kod_up )
          find ( tmp_ga->kod_up )
          If Found()
            s += AllTrim( AfterAtNum( '.', tmp_ga->name, 1 ) ) + '/'
          Else
            Exit
          Endif
        Enddo
        Goto ( rec )
        sdvn->name1 := s
      else
        If ( i := AScan( as, { | x | lstr( x[ 1 ] ) == RTrim( tmp_ga->kod ) } ) ) > 0
          Select SDVN
          Append Blank
          sdvn->name := AfterAtNum( '.', tmp_ga->name, 1 )
          sdvn->kod := tmp_ga->kod
          sdvn->isn := as[ i, 2 ]
          s := ''
          Select TMP_GA
          rec := RecNo()
          Do While !Empty( tmp_ga->kod_up )
            find ( tmp_ga->kod_up )
            If Found()
              s += AllTrim( AfterAtNum( '.', tmp_ga->name, 1 ) ) + '/'
            Else
              Exit
            Endif
          Enddo
          Goto ( rec )
          sdvn->name1 := s
        Endif
      endif
      Skip
    Enddo
    sdvn->( dbCloseArea() )
    tmp_ga->( dbCloseArea() )
  Endif
  Use ( n_file ) New Alias tmp_ga
  Do While !Eof()
    tmp_ga->is := ( AScan( a_spec, Int( Val( tmp_ga->kod ) ) ) > 0 )
    Skip
  Enddo
  if lFull
    Index On Upper( name ) + kod to ( n_file )
  else
    If metap == 3
      Index On Upper( name ) + kod to ( n_file )
    Else
      Index On Upper( name ) + kod to ( n_file ) For isn == 1
    Endif
  endif
  If r <= MaxRow() / 2
    t_arr[ BR_TOP ] := r + 1
    t_arr[ BR_BOTTOM ] := MaxRow() -2
  Else
    t_arr[ BR_BOTTOM ] := r - 1
    t_arr[ BR_TOP ] := 2
  Endif
  blk := {|| iif( tmp_ga->is, { 1, 2 }, { 3, 4 } ) }
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .f. }
  t_arr[ BR_COLUMN ] := { ;
    { ' ', {|| iif( tmp_ga->is, '', ' ' ) }, blk }, ;
    { 'Код', {|| Left( tmp_ga->kod, 3 ) }, blk }, ;
    { Center( 'Медицинская специальность', 26 ), {|| PadR( tmp_ga->name, 26 ) }, blk }, ;
    { Center( 'подчинение', 45 ), {|| Left( tmp_ga->name1, 45 ) }, blk };
    }
  t_arr[ BR_EDIT ] := { | nk, ob | f1get_spec_dvn( nk, ob, 'edit' ) }
  t_arr[ BR_STAT_MSG ] := { || status_key( '^<Esc>^ - выход;  ^<Ins>^ - отметить специальность/снять отметку со специальности' ) }
  Go Top
  edit_browse( t_arr )
  s := ''
  ASize( a_spec, 0 )
  Go Top
  Do While !Eof()
    if lFull
      If tmp_ga->is
        s += AllTrim( tmp_ga->kod ) + ','
        AAdd( a_spec, Int( Val( tmp_ga->kod ) ) )
      Endif
    else
      If iif( metap == 3, .t., tmp_ga->isn == 1 ) .and. tmp_ga->is
        s += AllTrim( tmp_ga->kod ) + ','
        AAdd( a_spec, Int( Val( tmp_ga->kod ) ) )
      Endif
    endif
    Skip
  Enddo
  If Empty( s )
    s := '---'
  Else
    s := Left( s, Len( s ) -1 )
  Endif
  tmp_ga->( dbCloseArea() )
  Select ( tmp_select )

  Return { 1, s }

// 11.11.17
Function f1get_spec_dvn( nKey, oBrow, regim )

  If regim == 'edit' .and. nkey == K_INS
    tmp_ga->is := !tmp_ga->is
    Keyboard Chr( K_TAB )
  Endif

  Return 0

// 19.06.19 рабочая ли услуга ДВН в зависимости от этапа, возраста и пола
Function f_is_usl_oms_sluch_dvn( i, _etap, _vozrast, _pol, /*@*/_diag,/*@*/_otkaz,/*@*/_ekg)

  Local fl := .f., ars := {}, ar := dvn_arr_usl[ i ]

  If ValType( ar[ 3 ] ) == 'N'
    fl := ( ar[ 3 ] == _etap )
  Else
    fl := AScan( ar[ 3 ], _etap ) > 0
  Endif
  _diag := ( ar[ 4 ] == 1 )
  _otkaz := 0
  _ekg := .f.
  If ValType( ar[ 2 ] ) == 'C'
    AAdd( ars, ar[ 2 ] )
  Else
    ars := AClone( ar[ 2 ] )
  Endif
  If eq_any( _etap, 1, 3 ) .and. ar[ 5 ] == 1 .and. AScan( ars, '4.20.1' ) == 0
    _otkaz := 1 // можно ввести отказ
    If ValType( ar[ 2 ] ) == 'C' .and. eq_ascan( ars, '7.57.3', '7.61.3', '4.1.12' )
      _otkaz := 2 // можно ввести невозможность
      If AScan( ars, '4.1.12' ) > 0 // взятие мазка
        _otkaz := 3 // заменить на приём фельдшера-акушера
      Endif
    Endif
  Endif
  If fl .and. eq_any( _etap, 1, 4, 5 )
    If _etap == 1
      i := iif( _pol == 'М', 6, 7 )
    Elseif Len( ar ) < 14
      Return .f.
    Else
      i := iif( _pol == 'М', 13, 14 )
    Endif
    If ValType( ar[ i ] ) == 'N' // специально для услуги 'Электрокардиография','13.1.1' ранее 18 года
      fl := ( ar[ i ] != 0 )
      If ar[ i ] < 0  // ЭКГ
        _ekg := ( _vozrast < Abs( ar[ i ] ) ) // необязательный возраст
      Endif
    Else // для 1,4,5 этапа возраст указан массивом
      fl := AScan( ar[ i ], _vozrast ) > 0
    Endif
  Endif
  If fl .and. eq_any( _etap, 2, 3 )
    i := iif( _pol == 'М', 8, 9 )
    If ValType( ar[ i ] ) == 'N'
      fl := ( ar[ i ] != 0 )
    Elseif Type( 'is_disp_19' ) == 'L' .and. is_disp_19
      fl := AScan( ar[ i ], _vozrast ) > 0
    Else // для 2 этапа и профилактики возраст указан диапазоном
      fl := Between( _vozrast, ar[ i, 1 ], ar[ i, 2 ] )
    Endif
  Endif

  Return fl
