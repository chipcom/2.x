// mo_invoice.prg - ࠡ�� � ᯨ᪮� ��⮢ � ����� ���
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 02.04.13 ��ᬮ�� ᯨ᪠ ��⮢, ������ ��� �����, ����� ��⮢
Function view_list_schet()

  Local i, k, buf := SaveScreen(), tmp_help := chm_help_code, mdate := SToD( '20130101' )

  mywait()
  Close databases
  r_use( dir_server + 'mo_rees', , 'REES' )
  g_use( dir_server + 'mo_xml', , 'MO_XML' )
  g_use( dir_server + 'schet_', , 'SCHET_' )
  g_use( dir_server + 'schet', dir_server + 'schetd', 'SCHET' )
  Set Relation To RecNo() into SCHET_
  dbSeek( dtoc4( mdate ), .t. )
  Index On DToS( schet_->dschet ) + fsort_schet( schet_->nschet, nomer_s ) to ( cur_dir + 'tmp_sch' ) ;
    For schet_->dschet >= mdate .and. !Empty( pdate ) .and. ;
    ( schet_->IS_DOPLATA == 1 .or. !Empty( Val( schet_->smo ) ) ) ;
    DESCENDING
  Go Top
  If Eof()
    RestScreen( buf )
    Close databases
    Return func_error( 4, '��� �믨ᠭ��� ��⮢ c ' + date_month( mdate ) )
  Endif
  chm_help_code := 122
  box_shadow( MaxRow() -3, 0, MaxRow() -1, 79, color0 )
  alpha_browse( T_ROW, 0, MaxRow() -4, 79, 'f1_view_list_schet', color0, , , , , , 'f21_view_list_schet', ;
    'f2_view_list_schet', , { '�', '�', '�', 'N/BG, W+/N, B/BG, BG+/B, R/BG, RB/BG, GR/BG', .t., 60 } )
  Close databases
  chm_help_code := tmp_help
  RestScreen( buf )
  Return Nil

// 24.04.25
Function f1_view_list_schet( oBrow )

  Local oColumn, ;
    blk := {|| iif( !Empty( schet_->NAME_XML ) .and. Empty( schet_->date_out ), { 3, 4 }, { 1, 2 } ) }

  oColumn := TBColumnNew( '����� ���', {|| schet_->nschet } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '  ���', {|| date_8( schet_->dschet ) } )
  oColumn:colorBlock := {|| f23_view_list_schet() }
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '��-;ਮ�', ;
    {|| iif( emptyany( schet_->nyear, schet_->nmonth ), ;
    Space( 5 ), ;
    Right( Str( schet_->nyear, 4 ), 2 ) + '/' + StrZero( schet_->nmonth, 2 ) ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' �㬬� ���', {|| put_kop( schet->summa, 13 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '���.;���.', {|| Str( schet->kol, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '���਩', {|| PadR( f3_view_list_schet(), 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '�ਭ����������;���', {|| PadR( f4_view_list_schet(), 14 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '  ', {|| f22_view_list_schet() } )
  oColumn:colorBlock := {|| f23_view_list_schet() }
  oBrow:addcolumn( oColumn )
//  status_key( '^<Esc>^ - ��室;  ^<F5>^ - ������ ��⮢ �� ����;  ^<F9>^ - ����� ����/॥���' )
  status_key( '^<Esc>^-��室 ^<F5>^-������ ��⮢ �� ���� ^<F6>^-���㬥��� �� ���� ^<F9>^-����� ����/॥���' )
  Return Nil

//
Function f21_view_list_schet()

  Local s := '', fl := .t., r := Row(), c := Col()

  If !emptyany( schet_->name_xml, schet_->kod_xml )
    fl := hb_FileExists( dir_server + dir_XML_MO + cslash + AllTrim( schet_->name_xml ) + szip )
    s := iif( fl, 'XML-䠩�: ', '��� XML-䠩��: ' ) + AllTrim( schet_->name_xml )
    mo_xml->( dbGoto( schet_->XML_REESTR ) )
    If mo_xml->REESTR > 0
      rees->( dbGoto( mo_xml->REESTR ) )
      s += ', �� ॥���� � ' + lstr( rees->NSCHET ) + ' �� ' + ;
        date_8( rees->DSCHET ) + '�. (' + lstr( rees->KOL ) + ' 祫.)'
    Endif
  Endif
  @ MaxRow() -2, 1 Say PadC( s, 78 ) Color iif( fl, color0, 'R/BG' )
  SetPos( r, c )
  Return Nil

//
Function f22_view_list_schet()

  Local s := '  '

  If schet_->NREGISTR == 1 // ��� �� ��ॣ����஢��
    s := ''
  Elseif schet_->NREGISTR == 2 // �� �㤥� ��ॣ����஢��
    s := '��'
  Elseif schet_->NREGISTR == 3 // 㤠��
    s := '--'
  Endif
  Return s

//
Function f23_view_list_schet()

  Local arr := iif( !Empty( schet_->NAME_XML ) .and. Empty( schet_->date_out ), { 3, 4 }, { 1, 2 } )

  If schet_->NREGISTR == 1 // ��� �� ��ॣ����஢��
    arr[ 1 ] := 5
  Elseif schet_->NREGISTR == 2 // �� �㤥� ��ॣ����஢��
    arr[ 1 ] := 6
  Elseif schet_->NREGISTR == 3 // 㤠��
    arr[ 1 ] := 7
  Endif
  Return arr

// 27.04.25
Function f2_view_list_schet( nKey, oBrow )

  Static si := 1

  Local ret := -1, rec := schet->( RecNo() ), tmp_color := SetColor(), r, r1, r2, ;
    s, buf := SaveScreen(), arr, i, k, mdate, t_arr[ 2 ], arr_pmt := {}
  local destination, row, print_arr := {}
  Local mm_menu := {}

  For i := 1 To 2
    AAdd( mm_menu, '����� ' + iif( i == 1, '', '॥��� ' ) + '���� �� ������ ����樭᪮� �����' )
  Next

  r := Row()
  arr := {}
  Do Case
  Case nKey == K_F9
    if ! Empty( Val( schet_->smo ) )
      If r <= MaxRow() / 2
        r1 := r + 1
        r2 := r1 + 3
      Else
        r2 := r -1
        r1 := r2 -3
      Endif
      If ( i := popup_prompt( r1, 10, si, mm_menu, , , color5 ) ) > 0
        si := i
//        print_schet_s( i )
        AAdd( print_arr, schet->( RecNo() ) )
        schet_reestr( print_arr, cur_dir(), .t., i )
      Endif
    Else
      print_other_schet( 1 )
    Endif
  
//    print_schet( oBrow )
    
    Select SCHET
    Goto ( rec )
    ret := 0
  Case nKey == K_F6
    k := 0
    mdate := schet_->dschet
    find ( DToS( mdate ) )
    Do While schet_->dschet == mdate .and. !Eof()
      If !emptyany( schet_->name_xml, schet_->kod_xml )
        AAdd( arr, { schet_->nschet, schet_->name_xml, schet_->kod_xml, schet->( RecNo() ) } )
      Endif
      Skip
    Enddo
    If Len( arr ) == 0
      func_error( 4, '��祣� �����뢠��!' )
    Else
      If Len( arr ) > 1
        ASort( arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
        For i := 1 To Len( arr )
          schet->( dbGoto( arr[ i, 4 ] ) )
          AAdd( arr_pmt, { '���� � ' + AllTrim( schet_->nschet ) + ' (' + ;
            lstr( schet_->nyear ) + '/' + StrZero( schet_->nmonth, 2 ) + ')', ;
            AClone( arr[ i ] ) } )
        Next
        If r + 2 + Len( arr ) > MaxRow() - 2
          r2 := r - 1
          r1 := r2 - Len( arr ) - 1
          If r1 < 0
            r1 := 0
          Endif
        Else
          r1 := r + 1
        Endif
        arr := {} // ���ᨢ ���⠥��� ��⮢
        If ( t_arr := bit_popup( r1, 10, arr_pmt, , color5, 1, '������ ���㬥�⮢ (' + date_8( mdate ) + ')', 'B/W' ) ) != nil
          AEval( t_arr, {| x | AAdd( arr, AClone( x[ 2 ] ) ) } )
        Endif
        t_arr := Array( 2 )
      Endif
      If Len( arr ) > 0
        for each row in arr // �롨ࠥ� ⮫쪮 ����� ����ᥩ ��⮢ ��� ����
          AAdd( print_arr , row[ 4 ] )
        next
        If f_esc_enter( '����� �� ' + date_8( mdate ) + '�.' )
          Private p_var_manager := 'copy_schet'
          destination := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 2, .f., , , ) // 'norton' ��� �롮� ��⠫���
          If ! Empty( destination )
            schet_reestr( print_arr, destination, .f., 0 )
          Endif
        Endif
      Endif
    Endif
    Select SCHET
    Goto ( rec )
    ret := 0
  Case nKey == K_F5
    r := Row()
    arr := {}
    k := 0
    mdate := schet_->dschet
    find ( DToS( mdate ) )
    Do While schet_->dschet == mdate .and. !Eof()
      If !emptyany( schet_->name_xml, schet_->kod_xml )
        AAdd( arr, { schet_->nschet, schet_->name_xml, schet_->kod_xml, schet->( RecNo() ) } )
        If Empty( schet_->date_out )
          ++k
        Endif
      Endif
      Skip
    Enddo
    If Len( arr ) == 0
      func_error( 4, '��祣� �����뢠��!' )
    Else
      If Len( arr ) > 1
        ASort( arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
        For i := 1 To Len( arr )
          schet->( dbGoto( arr[ i, 4 ] ) )
          AAdd( arr_pmt, { '���� � ' + AllTrim( schet_->nschet ) + ' (' + ;
            lstr( schet_->nyear ) + '/' + StrZero( schet_->nmonth, 2 ) + ;
            ') 䠩� ' + AllTrim( schet_->name_xml ), AClone( arr[ i ] ) } )
        Next
        If r + 2 + Len( arr ) > MaxRow() -2
          r2 := r -1
          r1 := r2 - Len( arr ) -1
          If r1 < 0
            r1 := 0
          Endif
        Else
          r1 := r + 1
        Endif
        arr := {}
        If ( t_arr := bit_popup( r1, 10, arr_pmt, , color5, 1, '�����뢠��� 䠩�� ��⮢ (' + date_8( mdate ) + ')', 'B/W' ) ) != NIL
          AEval( t_arr, {| x| AAdd( arr, AClone( x[ 2 ] ) ) } )
        Endif
        t_arr := Array( 2 )
      Endif
      If Len( arr ) > 0
        s := '������⢮ ��⮢ - ' + lstr( Len( arr ) ) + ;
          ', �����뢠���� � ���� ࠧ - ' + lstr( k ) + ':'
        For i := 1 To Len( arr )
          If i > 1
            s += ','
          Endif
          s += ' ' + AllTrim( arr[ i, 1 ] ) + ' (' + AllTrim( arr[ i, 2 ] ) + szip + ')'
        Next
        perenos( t_arr, s, 74 )
        f_message( t_arr, , color1, color8 )
        If f_esc_enter( '����� ��⮢ �� ' + date_8( mdate ) + '�.' )
          Private p_var_manager := 'copy_schet'
          s := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 2, .f., , , ) // 'norton' ��� �롮� ��⠫���
          If !Empty( s )
            goal_dir := dir_server + dir_XML_MO + cslash
            If Upper( s ) == Upper( goal_dir )
              func_error( 4, '�� ��ࠫ� ��⠫��, � ���஬ 㦥 ����ᠭ� 楫��� 䠩��! �� �������⨬�.' )
            Else
              cFileProtokol := 'prot_sch' + stxt
              StrFile( hb_eol() + Center( glob_mo[ _MO_SHORT_NAME ], 80 ) + hb_eol() + hb_eol(), cFileProtokol )
              smsg := '��� ����ᠭ� ��: ' + s + ;
                ' (' + full_date( sys_date ) + '�. ' + hour_min( Seconds() ) + ')'
              StrFile( Center( smsg, 80 ) + hb_eol(), cFileProtokol, .t. )
              k := 0
              For i := 1 To Len( arr )
                zip_file := AllTrim( arr[ i, 2 ] ) + szip
                If hb_FileExists( goal_dir + zip_file )
                  mywait( '����஢���� "' + zip_file + '" � ��⠫�� "' + s + '"' )
                  // copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
                  Copy File ( goal_dir + zip_file ) to ( s + zip_file )
                  // if hb_fileExists(hb_OemToAnsi(s)+zip_file)
                  If hb_FileExists( s + zip_file )
                    ++k
                    schet->( dbGoto( arr[ i, 4 ] ) )
                    smsg := lstr( i ) + '. ���� � ' + AllTrim( schet_->nschet ) + ;
                      ' �� ' + date_8( mdate ) + '�. (���.��ਮ� ' + ;
                      lstr( schet_->nyear ) + '/' + StrZero( schet_->nmonth, 2 ) + ;
                      ') ' + AllTrim( schet_->name_xml ) + szip
                    StrFile( hb_eol() + smsg + hb_eol(), cFileProtokol, .t. )
                    smsg := '   ������⢮ ��樥�⮢ - ' + lstr( schet->kol ) + ;
                      ', �㬬� ���� - ' + expand_value( schet->summa, 2 )
                    StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                    schet_->( g_rlock( forever ) )
                    schet_->DATE_OUT := sys_date
                    If schet_->NUMB_OUT < 99
                      schet_->NUMB_OUT++
                    Endif
                    //
                    mo_xml->( dbGoto( arr[ i, 3 ] ) )
                    mo_xml->( g_rlock( forever ) )
                    mo_xml->DREAD := sys_date
                    mo_xml->TREAD := hour_min( Seconds() )
                  Else
                    smsg := '! �訡�� ����� 䠩�� ' + s + zip_file
                    func_error( 4, smsg )
                    StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                  Endif
                Else
                  smsg := '! �� �����㦥� 䠩� ' + goal_dir + zip_file
                  func_error( 4, smsg )
                  StrFile( smsg + hb_eol(), cFileProtokol, .t. )
                Endif
              Next
              Unlock
              Commit
              viewtext( cFileProtokol, , , , .t., , , 2 )
                /*asize(t_arr, 1)
                perenos(t_arr,'����ᠭ� ��⮢ - ' + lstr(k) + ' � ��⠫�� '+s+;
                     iif(k == len(arr), '', ', �� ����ᠭ� ��⮢ - ' + lstr(len(arr)-k)), 60)
                stat_msg('������ �����襭�!')
                n_message(t_arr,,'GR+/B','W+/B', 18,,'G+/B')*/
            Endif
          Endif
        Endif
      Endif
    Endif
    Select SCHET
    Goto ( rec )
    ret := 0
  Case nKey == K_CTRL_F11 .and. !Empty( schet_->NAME_XML ) .and. schet_->XML_REESTR > 0
    k := schet_->XML_REESTR // ��뫪� �� ॥��� �� � ��
    arr := {}
    Go Top
    Do While !Eof()
      If !emptyany( schet_->name_xml, schet_->kod_xml ) .and. k == schet_->XML_REESTR
        AAdd( arr, schet->( RecNo() ) )
      Endif
      Skip
    Enddo
    If Len( arr ) == 0
      func_error( 4, '��㤠�� ����!' )
    Else
      If Len( arr ) > 1
        For i := 1 To Len( arr )
          schet->( dbGoto( arr[ i ] ) )
          AAdd( arr_pmt, { '���� � ' + AllTrim( schet_->nschet ) + ' (' + ;
            lstr( schet_->nyear ) + '/' + StrZero( schet_->nmonth, 2 ) + ;
            ') 䠩� ' + AllTrim( schet_->name_xml ), arr[ i ] } )
        Next
        r := Row()
        If r + 2 + Len( arr ) > MaxRow() -2
          r2 := r -1
          r1 := r2 - Len( arr ) -1
          If r1 < 0
            r1 := 0
          Endif
        Else
          r1 := r + 1
        Endif
        arr := {}
        If ( t_arr := bit_popup( r1, 10, arr_pmt, , 'N/W*, GR+/R', 1, '���ᮧ������� 䠩�� ��⮢', 'B/W*' ) ) != NIL
          AEval( t_arr, {| x| AAdd( arr, x[ 2 ] ) } )
        Endif
      Endif
      If Len( arr ) > 0
        recreate_some_schet_from_file_sp( arr )
        Close databases
        r_use( dir_server + 'mo_rees', , 'REES' )
        g_use( dir_server + 'mo_xml', , 'MO_XML' )
        g_use( dir_server + 'schet_', , 'SCHET_' )
        g_use( dir_server + 'schet', dir_server + 'schetd', 'SCHET' )
        Set Relation To RecNo() into SCHET_
        Go Top
        ret := 1
      Endif
    Endif
  Case nKey == K_CTRL_F12 .and. !Empty( schet_->NAME_XML ) .and. schet_->XML_REESTR > 0
    recreate_some_schet_from_file_sp( { schet->( RecNo() ) } )
    Close databases
    r_use( dir_server + 'mo_rees', , 'REES' )
    g_use( dir_server + 'mo_xml', , 'MO_XML' )
    g_use( dir_server + 'schet_', , 'SCHET_' )
    g_use( dir_server + 'schet', dir_server + 'schetd', 'SCHET' )
    Set Relation To RecNo() into SCHET_
    Go Top
    ret := 1
  Endcase
  SetColor( tmp_color )
  RestScreen( buf )
  Return ret

// 25.04.25
Function f3_view_list_schet()

//  Local s := ''
  Local s

  // If schet_->nyear < 2013 .and. schet_->IS_MODERN == 1 // ���� ����୨��樥�?;0-���, 1-�� ��� IFIN=1
  //   s := '����୨����'
  // Endif
  // If schet_->IS_DOPLATA == 1 // ���� �����⮩?;0-���, 1-�� ��� IFIN=1 ��� 2
  //   s := '����.'
  //   If schet_->IFIN == 1
  //     s += '�����'
  //   Elseif schet_->IFIN == 2
  //     s += '�����'
  //   Endif
  // Endif
//  If Empty( s ) .and. schet_->IFIN > 0
  If schet_->IFIN > 0
    s := '��� '
    If schet_->bukva     == 'A'
      s += '�-��'
    Elseif schet_->bukva == 'D'
      s += '���'
    Elseif schet_->bukva == 'E'
      s += '���'
    Elseif schet_->bukva == 'F'
      s += '����.'
    Elseif schet_->bukva == 'G'
      s += '��ଠ�'
    Elseif schet_->bukva == 'H'
      s += '���'
    Elseif schet_->bukva == 'I'
      s += '���ਮ'
    Elseif schet_->bukva == 'J'
      s += '�-��'
    Elseif schet_->bukva == 'K'
      s += '�/�/�'
    Elseif schet_->bukva == 'M'
      s += '���/�'
    Elseif schet_->bukva == 'O'
      s += '�����'
    Elseif schet_->bukva == 'R'
      s += '�����'
    Elseif schet_->bukva == 'S'
      s += '���.'
    Elseif schet_->bukva == 'T'
      s += '�⮬��'
    Elseif schet_->bukva == 'U'
      s += '�����'
    Elseif schet_->bukva == 'V'
      s += '��।.'
    Elseif schet_->bukva == 'Z'
      s += '��/��.'
    Elseif schet_->IFIN == 1
      s += '�����'
    Elseif schet_->IFIN == 2
      s += '�����'
    Endif
  Endif
  Return s

//
Function f4_view_list_schet( lkomu, lsmo, lstr_crb )

  Local s := ''

  Default lkomu To schet->komu, lsmo To schet_->smo, lstr_crb To schet->str_crb
  If lkomu == 5
    s := '���� ����'
  Elseif !Empty( lsmo )
    s := inieditspr( A__MENUVERT, glob_arr_smo, Int( Val( lsmo ) ) )
    If Empty( s )
      s := inieditspr( A__POPUPMENU, dir_server + 'str_komp', lstr_crb )
      If Empty( s )
        s := lsmo
      Endif
    Endif
  Elseif lkomu == 1
    s := inieditspr( A__POPUPMENU, dir_server + 'str_komp', lstr_crb )
  Elseif lkomu == 3
    s := inieditspr( A__POPUPMENU, dir_server + 'komitet', lstr_crb )
  Endif
  Return s
