// mo_invoice.prg - ࠡ�� � ᯨ᪮� ��⮢ � ����� ���
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'hbxlsxwriter.ch'

// 02.04.13 ��ᬮ�� ᯨ᪠ ��⮢, ������ ��� �����, ����� ��⮢
Function view_list_schet()

  Local i, k, buf := SaveScreen(), tmp_help := chm_help_code, mdate := SToD( '20130101' )

  mywait()
  Close databases
  r_use( dir_server() + 'mo_rees', , 'REES' )
  g_use( dir_server() + 'mo_xml', , 'MO_XML' )
  g_use( dir_server() + 'schet_', , 'SCHET_' )
  g_use( dir_server() + 'schet', dir_server() + 'schetd', 'SCHET' )
  Set Relation To RecNo() into SCHET_
  dbSeek( dtoc4( mdate ), .t. )
  Index On DToS( schet_->dschet ) + fsort_schet( schet_->nschet, nomer_s ) to ( cur_dir() + 'tmp_sch' ) ;
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
    fl := hb_FileExists( dir_server() + dir_XML_MO() + hb_ps() + AllTrim( schet_->name_xml ) + szip() )
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
          s += ' ' + AllTrim( arr[ i, 1 ] ) + ' (' + AllTrim( arr[ i, 2 ] ) + szip() + ')'
        Next
        perenos( t_arr, s, 74 )
        f_message( t_arr, , color1, color8 )
        If f_esc_enter( '����� ��⮢ �� ' + date_8( mdate ) + '�.' )
          Private p_var_manager := 'copy_schet'
          s := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 2, .f., , , ) // 'norton' ��� �롮� ��⠫���
          If !Empty( s )
            goal_dir := dir_server() + dir_XML_MO() + hb_ps()
            If Upper( s ) == Upper( goal_dir )
              func_error( 4, '�� ��ࠫ� ��⠫��, � ���஬ 㦥 ����ᠭ� 楫��� 䠩��! �� �������⨬�.' )
            Else
              cFileProtokol := 'prot_sch.txt'
              StrFile( hb_eol() + Center( glob_mo[ _MO_SHORT_NAME ], 80 ) + hb_eol() + hb_eol(), cFileProtokol )
              smsg := '��� ����ᠭ� ��: ' + s + ;
                ' (' + full_date( sys_date ) + '�. ' + hour_min( Seconds() ) + ')'
              StrFile( Center( smsg, 80 ) + hb_eol(), cFileProtokol, .t. )
              k := 0
              For i := 1 To Len( arr )
                zip_file := AllTrim( arr[ i, 2 ] ) + szip()
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
                      ') ' + AllTrim( schet_->name_xml ) + szip()
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
        r_use( dir_server() + 'mo_rees', , 'REES' )
        g_use( dir_server() + 'mo_xml', , 'MO_XML' )
        g_use( dir_server() + 'schet_', , 'SCHET_' )
        g_use( dir_server() + 'schet', dir_server() + 'schetd', 'SCHET' )
        Set Relation To RecNo() into SCHET_
        Go Top
        ret := 1
      Endif
    Endif
  Case nKey == K_CTRL_F12 .and. !Empty( schet_->NAME_XML ) .and. schet_->XML_REESTR > 0
    recreate_some_schet_from_file_sp( { schet->( RecNo() ) } )
    Close databases
    r_use( dir_server() + 'mo_rees', , 'REES' )
    g_use( dir_server() + 'mo_xml', , 'MO_XML' )
    g_use( dir_server() + 'schet_', , 'SCHET_' )
    g_use( dir_server() + 'schet', dir_server() + 'schetd', 'SCHET' )
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
      s := inieditspr( A__POPUPMENU, dir_server() + 'str_komp', lstr_crb )
      If Empty( s )
        s := lsmo
      Endif
    Endif
  Elseif lkomu == 1
    s := inieditspr( A__POPUPMENU, dir_server() + 'str_komp', lstr_crb )
  Elseif lkomu == 3
    s := inieditspr( A__POPUPMENU, dir_server() + 'komitet', lstr_crb )
  Endif
  Return s

// 15.10.24 㤠���� ���(�) �� ������ ॥���� �� � �� � �� �⨬ ��� ᮧ���� ������ ��� (�.�.��㣮� ���-�� ��⮢)
Function recreate_some_schet_from_file_sp( arr )

  Local arr_XML_info[ 8 ], cFile, arr_f, k, n, oXmlDoc, aerr := {}, t_arr[ 2 ], ;
    i, s, rec_schet, rec_schet_xml, go_to_schet := .f., arr_schet := {}

  Private name_schet, _date_schet, mXML_REESTR

  For i := 1 To Len( arr )
    Select SCHET
    Goto ( arr[ i ] )
    If emptyany( schet_->name_xml, schet_->kod_xml ) .or. schet_->IS_MODERN == 1
      Return func_error( 4, "�����४⭮ ��������� ���� ���� " + RTrim( schet_->nschet ) + ". ������ ����饭�." )
    Endif
    If i == 1
      mXML_REESTR := schet_->XML_REESTR // ��뫪� �� ॥��� �� � ��
    Elseif mXML_REESTR != schet_->XML_REESTR
      Return func_error( 4, "���� " + RTrim( schet_->nschet ) + " �� ��㣮�� ॥��� �� � ��. ������ ����饭�." )
    Endif
    AAdd( arr_schet, { ;
      arr[ i ], ;                  // 1 - schet->(recno())
      schet_->kod_xml, ;         // 2 - ��뫪� �� 䠩� "mo_xml"
      schet_->name_xml, ;        // 3 - ��� XML-䠩�� ��� ���७�� (� ZIP-��娢�)
      AllTrim( schet_->nschet ), ; // 4 - ����� ���
    schet_->dschet ;          // 5 - ��� �ନ஢���� ���
      } )
  Next
  //
  mo_xml->( dbGoto( mXML_REESTR ) )
  If Empty( mo_xml->REESTR )
    Return func_error( 4, "��������� ��뫪� �� ��ࢨ�� ॥���! ������ ����饭�." )
  Endif
  Private cReadFile := AllTrim( mo_xml->FNAME ) // ��� 䠩�� ॥��� �� � ��
  Private cFileProtokol := cReadFile + stxt()     // ��� 䠩�� ��⮪��� �⥭�� ॥��� �� � ��
  Private mkod_reestr := mo_xml->REESTR       // ��� ��ࢨ筮�� ॥���
  Private cTimeBegin := hour_min( Seconds() )
  Private name_zip := cReadFile + szip()          // ��� ��娢� 䠩�� ॥��� �� � ��
  cFile := cReadFile + sxml()                     // ��� XML-䠩�� ॥��� �� � ��
  //
  rees->( dbGoto( mkod_reestr ) )
  Private name_reestr := AllTrim( rees->name_xml ) + szip() // ��� ��娢� 䠩�� ��ࢨ筮�� ॥���
  // �ᯠ���뢠�� ��ࢨ�� ॥���
  If ( arr_f := extract_zip_xml( dir_server() + dir_XML_MO() + hb_ps(), name_reestr ) ) == NIL
    Return func_error( 4, "�訡�� � �ᯠ����� ��娢� ॥��� " + name_reestr )
  Endif
  // �ᯠ���뢠�� ॥��� �� � ��
  If ( arr_f := extract_zip_xml( dir_server() + dir_XML_TF() + hb_ps(), name_zip ) ) == NIL
    Return func_error( 4, "�訡�� � �ᯠ����� ��娢� ॥��� �� � �� " + name_zip )
  Endif
  If ( n := AScan( arr_f, {| x| Upper( name_without_ext( x ) ) == Upper( cReadFile ) } ) ) == 0
    Return func_error( 4, "� ��娢� " + name_zip + " ��� 䠩�� " + cReadFile + sxml() )
  Endif
  Close databases

  If mo_lock_task( X_OMS ) // ����� ⮫쪮 ��� G_SLock1Task(sem_task,sem_vagno) // ����� ����㯠 �ᥬ
    k := Len( arr_schet )
    s := iif( k == 1, "���� ", lstr( k ) + " ��⮢ " )
    If iif( arr_schet[ 1, 5 ] > SToD( "20220224" ) .and. arr_schet[ 1, 5 ] < SToD( "20220228" ), .t., involved_password( 3, arr_schet[ 1, 4 ], "���ᮧ����� " + s + arr_schet[ 1, 4 ] ) ) ;
        .and. f_esc_enter( "���ᮧ����� " + s ) // .and. m_copy_DB_from_end(.t.) // १�ࢭ�� ����஢����
      Private fl_open := .t.
      index_base( "schet" ) // ��� ��⠢����� ��⮢
      index_base( "human" ) // ��� ࠧ��᪨ ��⮢
      index_base( "human_3" ) // ������ ��砨
      Use ( dir_server() + "human_u" ) New READONLY
      Index On Str( kod, 7 ) + date_u to ( dir_server() + "human_u" ) progress
      Use
      Use ( dir_server() + "mo_hu" ) New READONLY
      Index On Str( kod, 7 ) + date_u to ( dir_server() + "mo_hu" ) progress
      Use
      index_base( "mo_refr" )  // ��� ����� ��稭 �⪠���
      //
      mywait()
      StrFile( hb_eol() + ;
        Space( 10 ) + "����ୠ� ��ࠡ�⪠ 䠩��: " + cFile + ;
        hb_eol(), cFileProtokol )
      StrFile( Space( 10 ) + full_date( sys_date ) + "�. " + cTimeBegin + ;
        hb_eol(), cFileProtokol, .t. )
      mywait( "�ந�������� ������ 䠩�� " + cFile )
      // �⠥� 䠩� � ������
      oXmlDoc := hxmldoc():read( _tmp_dir1() + cFile )
      If oXmlDoc == Nil .or. Empty( oXmlDoc:aItems )
        AAdd( aerr, "�訡�� � �⥭�� 䠩�� " + cFile )
      Else
        reestr_sp_tk_tmpfile( oXmlDoc, aerr, cReadFile )
      Endif
      If Empty( aerr )
        r_use( dir_server() + "mo_rees",, "REES" )
        Goto ( mkod_reestr )
        If !extract_reestr( rees->( RecNo() ), rees->name_xml )
          AAdd( aerr, Center( "�� ������ ZIP-��娢 � �������� � " + lstr( mnschet ) + " �� " + date_8( tmp1->_DSCHET ), 80 ) )
          AAdd( aerr, "" )
          AAdd( aerr, Center( dir_server() + dir_XML_MO() + hb_ps() + AllTrim( rees->name_xml ) + szip(), 80 ) )
          AAdd( aerr, "" )
          AAdd( aerr, Center( "��� ������� ��娢� ���쭥��� ࠡ�� ����������!", 80 ) )
        Endif
      Endif
      Close databases
      If Empty( aerr )
        dbCreate( cur_dir() + "tmpsh", { { "kod_h", "N", 7, 0 } } )
        Use ( cur_dir() + "tmpsh" ) new
        r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
        For i := 1 To Len( arr_schet )
          find ( Str( arr_schet[ i, 1 ], 6 ) )
          Do While human->schet == arr_schet[ i, 1 ] .and. !Eof()
            Select tmpsh
            Append Blank
            Replace kod_h With human->kod
            Select HUMAN
            Skip
          Enddo
        Next
        Select tmpsh
        Index On Str( kod_h, 7 ) to ( cur_dir() + "tmpsh" )
        r_use( dir_server() + "mo_rhum",, "RHUM" )
        Index On Str( REES_ZAP, 6 ) to ( cur_dir() + "tmp_rhum" ) For reestr == mkod_reestr
        // ������ �ᯠ������� ॥���
        Use ( cur_dir() + "tmp_r_t1" ) New Alias T1
        Index On Str( Val( n_zap ), 6 ) to ( cur_dir() + "tmpt1" )
        Use ( cur_dir() + "tmp_r_t2" ) New Alias T2
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + "tmpt2" )
        Use ( cur_dir() + "tmp_r_t3" ) New Alias T3
        Index On Upper( ID_PAC ) to ( cur_dir() + "tmpt3" )
        Use ( cur_dir() + "tmp_r_t4" ) New Alias T4
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + "tmpt4" )
        Use ( cur_dir() + "tmp_r_t5" ) New Alias T5
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + "tmpt5" )
        Use ( cur_dir() + "tmp_r_t6" ) New Alias T6
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + "tmpt6" )
        Use ( cur_dir() + "tmp_r_t7" ) New Alias T7
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + "tmpt7" )
        Use ( cur_dir() + "tmp_r_t8" ) New Alias T8
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + "tmpt8" )
        Use ( cur_dir() + "tmp_r_t9" ) New Alias T
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + "tmpt9" )
        Use ( cur_dir() + "tmp_r_t10" ) New Alias T10
        Index On IDCASE + Str( sluch, 6 ) + regnum + code_sh + date_inj to ( cur_dir() + "tmpt10" )
        Use ( cur_dir() + "tmp_r_t11" ) New Alias T11
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + "tmpt11" )
        Use ( cur_dir() + "tmp_r_t12" ) New Alias T12
        Index On IDCASE + Str( sluch, 6 ) to ( cur_dir() + "tmpt12" )
        Use ( cur_dir() + "tmp_r_t1_1" ) New Alias T1_1
        Index On IDCASE to ( cur_dir() + "tmpt1_1" )
        Use ( cur_dir() + "tmp2file" ) New Alias TMP2
        is_new_err := .f.  // �諨 �� �����-���� ��砨 � �訡�� (�.�. ���� �訡��)
        Go Top
        Do While !Eof()
          If tmp2->_OPLATA == 1
            Select T1
            find ( Str( tmp2->_N_ZAP, 6 ) )
            If Found()
              t1->VPOLIS := lstr( tmp2->_VPOLIS )
              t1->SPOLIS := tmp2->_SPOLIS
              t1->NPOLIS := tmp2->_NPOLIS
              t1->ENP    := tmp2->_ENP
              t1->SMO    := tmp2->_SMO
              t1->SMO_OK := tmp2->_SMO_OK
              t1->MO_PR  := tmp2->_MO_PR
            Endif
          Endif
          Select RHUM
          find ( Str( tmp2->_N_ZAP, 6 ) )
          If Found() .and. rhum->KOD_HUM > 0
            Select tmpsh
            find ( Str( rhum->KOD_HUM, 7 ) )
            If Found()
              tmp2->kod_human := rhum->KOD_HUM
              If tmp2->_OPLATA > 1
                is_new_err := .t. // �.�. � ����� ॥��� �� � �� 祫���� ��� � �訡�� (� ࠭�� ������� � ����)
              Endif
            Endif
          Else
            AAdd( aerr, "" )
            AAdd( aerr, " - �� ������ ��樥�� � ����஬ ����� " + lstr( tmp2->_N_ZAP ) )
          Endif
          Select TMP2
          Skip
        Enddo
        Select TMP2
        Delete For kod_human == 0 // 㤠��� ��, �� �� �室�� � ��࠭�� ���
        Pack
      Endif
      Close databases
      If Empty( aerr ) .and. is_new_err
        r_use( dir_server() + 'mo_otd',, 'OTD' )
        g_use( dir_server() + "human_",, "HUMAN_" )
        g_use( dir_server() + "human", { dir_server() + "humann", dir_server() + "humans" }, "HUMAN" )
        Set Order To 0 // ������� ������ ��� ४������樨 �� ��१���� ���
        Set Relation To RecNo() into HUMAN_, To otd into OTD
        g_use( dir_server() + "human_3", { dir_server() + "human_3", dir_server() + "human_32" }, "HUMAN_3" )
        g_use( dir_server() + "mo_rhum",, "RHUM" )
        Index On Str( REES_ZAP, 6 ) to ( cur_dir() + "tmp_rhum" ) For reestr == mkod_reestr
        g_use( dir_server() + "mo_refr", dir_server() + "mo_refr", "REFR" )
        Use ( cur_dir() + "tmp3file" ) New Alias TMP3
        Index On Str( _n_zap, 8 ) to ( cur_dir() + "tmp3" )
        Use ( cur_dir() + "tmp2file" ) New Alias TMP2
        Go Top
        Do While !Eof()
          If tmp2->_OPLATA > 1 // 㤠�塞 �� ����, 㤠�塞 �� ॥���, ��ଫ塞 �訡��
            Select RHUM
            find ( Str( tmp2->_N_ZAP, 6 ) )
            g_rlock( forever )
            rhum->OPLATA := tmp2->_OPLATA
            is_2 := 0
            Select HUMAN
            Goto ( rhum->KOD_HUM )
            If eq_any( human->ishod, 88, 89 )
              Select HUMAN_3
              If human->ishod == 88
                Set Order To 1
                is_2 := 1
              Else
                Set Order To 2
                is_2 := 2
              Endif
              find ( Str( rhum->KOD_HUM, 7 ) )
              If Found() // �᫨ ��諨 ������� ��砩
                Select HUMAN
                If human->ishod == 88  // �᫨ ॥��� ��⠢��� �� 1-�� �����
                  Goto ( human_3->kod2 )  // ����� �� 2-��
                Else
                  Goto ( human_3->kod )   // ���� - �� 1-�
                Endif
                human->( g_rlock( forever ) )
                human->schet := 0 ; human->tip_h := B_STANDART
                //
                human_->( g_rlock( forever ) )
                human_->OPLATA := tmp2->_OPLATA
                human_->REESTR := 0 // ���ࠢ����� �� ���쭥�襥 ।���஢����
                human_->ST_VERIFY := 0 // ᭮�� ��� �� �஢�७
                If human_->REES_NUM > 0
                  human_->REES_NUM := human_->REES_NUM - 1
                Endif
                human_->REES_ZAP := 0
                If human_->schet_zap > 0
                  If human_->SCHET_NUM > 0
                    human_->SCHET_NUM := human_->SCHET_NUM - 1
                  Endif
                  human_->schet_zap := 0
                Endif
                //
                human_3->( g_rlock( forever ) )
                human_3->OPLATA := tmp2->_OPLATA
                human_3->schet := 0
                human_3->REESTR := 0
                If human_3->REES_NUM > 0
                  human_3->REES_NUM := human_3->REES_NUM - 1
                Endif
                human_3->REES_ZAP := 0
                If human_3->SCHET_NUM > 0
                  human_3->SCHET_NUM := human_3->SCHET_NUM -1
                Endif
                human_3->schet_zap := 0
              Endif
            Endif
            Select HUMAN
            Goto ( rhum->KOD_HUM )
            g_rlock( forever )
            human->schet := 0 ; human->tip_h := B_STANDART
            human_->( g_rlock( forever ) )
            human_->OPLATA := tmp2->_OPLATA
            human_->REESTR := 0 // � ���ࠢ����� �� ���쭥�襥 ।���஢����
            human_->ST_VERIFY := 0 // ᭮�� ��� �� �஢�७
            If human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM - 1
            Endif
            human_->REES_ZAP := 0
            If human_->SCHET_NUM > 0
              human_->SCHET_NUM := human_->SCHET_NUM - 1
            Endif
            human_->schet_zap := 0
            //
            lal := "human"
            If is_2 > 0
              lal += "_3"
            Endif
            StrFile( "!!! " + AllTrim( human->fio ) + ", " + full_date( human->date_r ) + ;
              iif( Empty( otd->SHORT_NAME ), "", " [" + AllTrim( otd->SHORT_NAME ) + "]" ) + ;
              " " + AllTrim( human->KOD_DIAG ) + ;
              " " + date_8( &lal.->n_data ) + "-" + date_8( &lal.->k_data ) + ;
              hb_eol(), cFileProtokol, .t. )
            Select REFR
            Do While .t.
              find ( Str( 1, 1 ) + Str( mkod_reestr, 6 ) + Str( 1, 1 ) + Str( rhum->KOD_HUM, 8 ) )
              If !Found() ; exit ; Endif
              deleterec( .t. )
            Enddo
            Select TMP3
            find ( Str( tmp2->_N_ZAP, 8 ) )
            Do While tmp2->_N_ZAP == tmp3->_N_ZAP .and. !Eof()
              Select REFR
              addrec( 1 )
              refr->TIPD := 1
              refr->KODD := mkod_reestr
              refr->TIPZ := 1
              refr->KODZ := rhum->KOD_HUM
              refr->IDENTITY := tmp2->_IDENTITY
              refr->REFREASON := tmp3->_REFREASON
              refr->SREFREASON := tmp3->SREFREASON
              If Empty( refr->SREFREASON )
                If Empty( s := ret_t005( refr->REFREASON ) )
                  s := lstr( refr->REFREASON ) + ' �������⭠� ��稭� �⪠��'
                Endif
              Else
                s := '��� �訡�� = ' + tmp3->SREFREASON + ' '
                s += '"' + getcategorycheckerrorbyid_q017( Left( tmp3->SREFREASON, 4 ) )[ 2 ] + '" '
                // s += alltrim(inieditspr(A__POPUPMENU, dir_exe() + "_mo_Q015", tmp3->SREFREASON))
                s += AllTrim( inieditspr( A__MENUVERT, loadq015(), tmp3->SREFREASON ) )
              Endif
              k := perenos( t_arr, s, 75 )
              For i := 1 To k
                StrFile( Space( 5 ) + t_arr[ i ] + hb_eol(), cFileProtokol, .t. )
              Next
              Select TMP3
              Skip
            Enddo
            If is_2 > 0
              StrFile( Space( 5 ) + '- ࠧ���� ������� ��砩 � ०��� "���/������ ��砨/���������"' + ;
                hb_eol(), cFileProtokol, .t. )
              StrFile( Space( 5 ) + '- ��।������ ����� �� ��砥� � ०��� "���/������஢����"' + ;
                hb_eol(), cFileProtokol, .t. )
              StrFile( Space( 5 ) + '- ᭮�� ᮡ��� ��砩 � ०��� "���/������ ��砨/�������"' + ;
                hb_eol(), cFileProtokol, .t. )
            Endif
          Endif
          Select TMP2
          Skip
        Enddo
        Close databases
        StrFile( hb_eol(), cFileProtokol, .t. )
      Endif
      If Empty( aerr )
        arr_f := {}
        // ᮧ����� ���� ���
        go_to_schet := create_schet_from_xml( arr_XML_info, aerr,, arr_f, cReadFile )
        Close databases
        If Empty( aerr ) // �᫨ ��� �訡��
          use_base( "schet" )
          Set Relation To
          g_use( dir_server() + "mo_xml",, "MO_XML" )
          // 㤠��� ���� ���
          For i := 1 To Len( arr_schet )
            StrFile( hb_eol() + ;
              "㤠�� ���� ���� � " + arr_schet[ i, 4 ] + " �� " + full_date( arr_schet[ i, 5 ] ) + ;
              hb_eol(), cFileProtokol, .t. )
            Select SCHET_
            Goto ( arr_schet[ i, 1 ] )
            deleterec( .t., .f. )  // ��� ����⪨ �� 㤠�����
            //
            Select SCHET
            Goto ( arr_schet[ i, 1 ] )
            deleterec( .t. )
            //
            Select MO_XML
            Goto ( arr_schet[ i, 2 ] )
            deleterec( .t. )
          Next
          Close databases
        Endif
      Endif
      If Empty( aerr )
        // ������襬 �।��騩 䠩� ��⮪��� ��ࠡ�⪨ ���� ��⮪����
        f_append_file( dir_server() + dir_XML_TF() + hb_ps() + cFileProtokol, cFileProtokol )
        viewtext( devide_into_pages( dir_server() + dir_XML_TF() + hb_ps() + cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
      Else
        AEval( aerr, {| x| StrFile( x + hb_eol(), cFileProtokol, .t. ) } )
        viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 2 )
      Endif
      Delete File ( cFileProtokol )
    Endif
    Close databases
    // ࠧ�襭�� ����㯠 �ᥬ
    // G_SUnLock(sem_vagno)
    mo_unlock_task( X_OMS )
    Keyboard ""
    If go_to_schet // �᫨ �믨ᠭ� ���
      Keyboard Chr( K_ENTER )
    Endif
  Else
    func_error( 4, "� ����� ������ ࠡ���� ��㣨� �����. ������ ����饭�!" )
  Endif
  Return Nil

// 08.02.23 ��������� 䠩� ofile ��ப��� �� 䠩�� nfile
Function f_append_file( ofile, nfile )

  Local s

  ft_use( nfile )
  ft_gotop()
  Do While !ft_eof()
    s := ft_readln()
    StrFile( s + hb_eol(), ofile, .t. )
    ft_skip()
  Enddo
  ft_use()
  Return Nil