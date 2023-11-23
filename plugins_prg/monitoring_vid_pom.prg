#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 16.10.16 �����ਭ� �� ����� ����樭᪮� ����� ��� ������ ��ࠢ���࠭���� ��
Function monitoring_vid_pom()
  Static mm_schet := { { '�� ��砨', 1 }, { '� ���⠢������ ����', 2 }, { '� ��ॣ����஢����� ����', 3 } }
  Local mm_tmp := {}, buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    tmp_help := help_code, hGauge, name_file := 'mon_kz' + stxt, ;
    sh := 80, HH := 60, i, k, tmp_file := 'tmp_mon' + sdbf, r1, r2

  Private pdate_lech

  //
  AAdd( mm_tmp, { 'date_lech', 'N', 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    iif( k == nil, nil, ( pdate_lech := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    '��� ����砭�� ��祭�� (���.��ਮ�)', {|| f_valid_mon() } } )
  AAdd( mm_tmp, { 'schet', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_schet, A__MENUVERT ) }, ;
    3, {| x| inieditspr( A__MENUVERT, mm_schet, x ) }, ;
    '����� ��砨 ���뢠����', {|| f_valid_mon() } } )
  AAdd( mm_tmp, { 'date_reg', 'D', 8, 0,, ;
    nil, ;
    CToD( '' ), nil, ;
    '�� ����� ���� (�����⥫쭮) ��ॣ����஢�� ����', ;
    {|| f_valid_mon() }, {|| m1schet == 3 } } )
  AAdd( mm_tmp, { 'rak', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_danet, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_danet, x ) }, ;
    '���뢠�� ��砨, ��������� ���� �� ��⠬ ����஫�', ;
    {|| f_valid_mon() } } )
  AAdd( mm_tmp, { 'date_rak', 'D', 8, 0,,, CToD( '' ),, ;
    '�� ����� ���� (�����⥫쭮) �஢����� ���� ����஫�',, ;
    {|| m1rak == 0 } } )
  Delete File ( tmp_file )
  init_base( tmp_file,, mm_tmp, 0 )
  r1 := 16 ; r2 := 22
  fillscrarea( r1 - 1, 0, r1 - 1, 79, '�', color1 )
  str_center( r1 - 1, ' �����ਭ� �� ����� ����樭᪮� ����� ', color8 )
  fillscrarea( r2 + 1, 0, r2 + 1, 79, '�', color1 )
  If f_edit_spr( A__APPEND, mm_tmp, '', 'e_use(cur_dir+"tmp_mon")', 0, 1,,,, { r1, 0, r2, 79, -1 }, 'write_mon' ) > 0
    RestScreen( buf )
    If Year( pdate_lech[ 5 ] ) < 2016
      Return func_error( 4, '����� ������ ࠡ�⠥� � 2016 ����' )
    Endif
    mywait()
    Use ( tmp_file ) New Alias MN
    arr := { ;
      { '���.������ � ࠬ��� ���ணࠬ�� ���', '10', '', 0, 0 }, ; // 1
    { '᪮�� ����樭᪠� ������', '11', '�맮�', 0, 0 }, ;             // 2
      { '����樭᪠� ������', '12.1', '���饭�� � ���.楫��', 0, 0 }, ;    // 3
    { '    � ���㫠����', '12.2', '���饭�� �� ���⫮���� �����', 0, 0 }, ;// 4
    { '    �᫮����', '12.3', '���饭��', 0, 0 }, ;                           // 5
      { '��樮���', '13', '��砩 ��ᯨ⠫���樨', 0, 0 }, ;                // 6
      { '  � �.�. ॠ�������', '14', '�����-����', 0, 0 }, ;                 // 7
      { '  � �.�. ���', '15', '��砩 ��ᯨ⠫���樨', 0, 0 }, ;               // 8
      { '������� ��樮���', '16', '��樥��-����', 0, 0 } ;                // 9
      }
    r_use( dir_server + 'uslugi',, 'USL' )
    r_use( dir_server + 'human_u_',, 'HU_' )
    r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
    Set Relation To RecNo() into HU_, To u_kod into USL
    If mn->rak == 0
      r_use( dir_server + 'mo_xml',, 'MO_XML' )
      r_use( dir_server + 'mo_rak',, 'RAK' )
      Set Relation To kod_xml into MO_XML
      r_use( dir_server + 'mo_raks',, 'RAKS' )
      Set Relation To akt into RAK
      r_use( dir_server + 'mo_raksh',, 'RAKSH' )
      Set Relation To kod_raks into RAKS
      Index On Str( kod_h, 7 ) to ( cur_dir + 'tmp_raksh' ) For rak->DAKT <= mn->date_rak
    Endif
    r_use( dir_server + 'schet_',, 'SCHET_' )
    r_use( dir_server + 'schet',, 'SCHET' )
    Set Relation To RecNo() into SCHET_
    //
    r_use( dir_server + 'human_2',, 'HUMAN_2' )
    r_use( dir_server + 'human_',, 'HUMAN_' )
    r_use( dir_server + 'human', dir_server + 'humand', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
    dbSeek( DToS( pdate_lech[ 5 ] ), .t. )
    old := pdate_lech[ 5 ] -1
    Do While human->k_data <= pdate_lech[ 6 ] .and. !Eof()
      If old != human->k_data
        old := human->k_data
        @ MaxRow(), 0 Say date_8( human->k_data ) Color cColorWait
      Endif
      fl := ( human->komu == 0 .or. !Empty( Val( human_->smo ) ) )
      If fl .and. mn->schet > 1
        fl := ( human->schet > 0 )
        If fl .and. mn->schet == 3
          schet->( dbGoto( human->schet ) )
          fl := ( date_reg_schet() <= mn->date_reg ) // ��� ॣ����樨
        Endif
      Endif
      fl_stom := .f.
      koef := 1 // �� 㬮�砭�� ����祭, �᫨ ���� ��� ����
      If mn->rak == 0 // �� ������� ��������� ����
        k := 0
        Select RAKSH
        find ( Str( human->kod, 7 ) )
        Do While human->kod == raksh->kod_h .and. !Eof()
          k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
          Skip
        Enddo
        If !Empty( Round( k, 2 ) )
          If Empty( human->cena_1 ) // ᪮�� ������
            koef := 0
          Elseif round_5( human->cena_1, 2 ) == round_5( k, 2 ) // ������ ��⨥
            koef := 0
          Else // ���筮� ��⨥
            koef := ( human->cena_1 - k ) / human->cena_1
          Endif
        Endif
      Endif
      If fl .and. koef > 0
        lsum := Round( human->cena_1 * koef, 2 )
        arr[ 1, 5 ] += lsum
        If human_->USL_OK == 4 // ᪮�� ������
          arr[ 2, 4 ] ++; arr[ 2, 5 ] += lsum
        Else
          vid_vp := 0 // �� 㬮�砭�� ��䨫��⨪�
          d2_year := Year( human->k_data )
          au := {}
          kp := 0 // ������⢮ ��楤��
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
              lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
              ta := f14tf_nastr( @lshifr,, d2_year )
              lshifr := AllTrim( lshifr )
              AAdd( au, { lshifr, hu->kol_1, Round( hu->stoim_1 * koef, 2 ), 0, 0, hu->kol_1 } )
              If eq_any( Left( lshifr, 5 ), '2.78.', '2.89.' )
                kp := 1
                vid_vp := 2 // ���饭�� � ��祡��� 楫��
              Elseif eq_any( Left( lshifr, 5 ), '2.80.', '2.82.' )
                kp += hu->kol_1
                vid_vp := 1 // � ���⫮���� �ଥ
              Elseif Left( lshifr, 2 ) == '2.' // ��⠫쭠� ��䨫��⨪�
                If eq_any( Left( lshifr, 5 ), '2.60.', '2.90.' )
                  //
                Else
                  kp += hu->kol_1
                Endif
              Elseif Left( lshifr, 2 ) == '1.' // �����-���
                kp += hu->kol_1 // �᫨ ॠ�������
              Elseif Left( lshifr, 3 ) == '55.'  // ��樥��-���
                kp += hu->kol_1
              Elseif Left( lshifr, 5 ) == '60.2.' .or. lshifr == '4.20.702' // �-��᫥�������
                kp := 0  // ������ �� ������⢮�, � ⮫쪮 �㬬��
              Elseif Left( lshifr, 3 ) == '57.'  // �⮬�⮫����
                fl_stom := .t.
              Endif
            Endif
            Select HU
            Skip
          Enddo
          If human_->USL_OK == 1 // ��樮���
            If AScan( glob_KSG_dializ, lshifr ) > 0 // ��� � ��������
              arr[ 6, 5 ] += lsum
            Else
              arr[ 6, 4 ] ++; arr[ 6, 5 ] += lsum
              If human_->PROFIL == 158
                arr[ 7, 4 ] += kp ; arr[ 7, 5 ] += lsum
              Endif
              If human_2->VMP == 1
                arr[ 8, 4 ] ++; arr[ 8, 5 ] += lsum
              Endif
            Endif
          Elseif human_->USL_OK == 2 // ������� ��樮���
            If AScan( glob_KSG_dializ, lshifr ) == 0
              arr[ 9, 4 ] += kp
            Endif
            arr[ 9, 5 ] += lsum
          Else // �����������
            If fl_stom
              ret_tip := kp := 0
              f_vid_p_stom( au, {},,, human->k_data, @ret_tip, @kp )
              Do Case
              Case ret_tip == 1
                vid_vp := 2 // �� ������ �����������
              Case ret_tip == 2
                vid_vp := 0 // ��䨫��⨪�
              Case ret_tip == 3
                vid_vp := 1 // � ���⫮���� �ଥ
              Endcase
            Endif
            If vid_vp == 2 // �� ������ �����������
              arr[ 5, 4 ] ++; arr[ 5, 5 ] += lsum
            Elseif vid_vp == 1 // � ���⫮���� �ଥ
              arr[ 4, 4 ] += kp ; arr[ 4, 5 ] += lsum
            Else // ��䨫��⨪�
              arr[ 3, 4 ] += kp ; arr[ 3, 5 ] += lsum
            Endif
          Endif
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    Close databases
    arr_title := { ;
      '��������������������������������������������������������������������������������', ;
      '���� � �᫮��� �������� ���.���. ����� ������ ����७��  � ���. � �㬬� � ��.', ;
      '��������������������������������������������������������������������������������' }
    fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( '' )
    add_string( Center( '�����ਭ� �� ����� ����樭᪮� �����', sh ) )
    add_string( Center( pdate_lech[ 4 ], sh ) )
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    For i := 1 To Len( arr )
      add_string( PadR( arr[ i, 1 ], 33 ) + ' ' + PadR( arr[ i, 2 ], 5 ) + PadR( arr[ i, 3 ], 20 ) + ;
        put_val( arr[ i, 4 ], 7 ) + put_kope( arr[ i, 5 ], 14 ) )
    Next
    FClose( fp )
    RestScreen( buf ) ; SetColor( tmp_color )
    viewtext( name_file,,,, ( .t. ),,, 2 )
  Endif
  Close databases
  RestScreen( buf ) ; SetColor( tmp_color )

  Return Nil

//
Function write_mon( k )
  Local fl := .t.

  If k == 1
    If Empty( mdate_lech )
      fl := func_error( 4, '��易⥫쭮 ������ ���� ��������� ���� ���� ����砭�� ��祭��!' )
    Else
      If m1schet == 3
        If Empty( mdate_reg ) .or. mdate_reg < pdate_lech[ 6 ]
          fl := func_error( 4, '�����४⭮� ᮤ�ঠ��� ���� "�� ����� ���� (�����⥫쭮) ��ॣ����஢�� ����"' )
        Endif
      Endif
      If m1rak == 0
        If Empty( mdate_rak ) .or. mdate_rak < pdate_lech[ 6 ] .or. ;
            ( m1schet == 3 .and. mdate_rak < mdate_reg )
          fl := func_error( 4, '�����४⭮� ᮤ�ঠ��� ���� "�� ����� ���� (�����⥫쭮) �஢����� ���� ����஫�"' )
        Endif
      Endif
    Endif
  Endif

  Return fl

//
Function f_valid_mon()

  If !Empty( pdate_lech )
    If m1schet == 3
      If Empty( mdate_reg ) .or. mdate_reg < pdate_lech[ 6 ]
        mdate_reg := pdate_lech[ 6 ] + 10
      Endif
    Else
      mdate_reg := CToD( '' )
    Endif
    If m1rak == 0
      If Empty( mdate_rak ) .or. mdate_rak < pdate_lech[ 6 ] .or. ;
          ( m1schet == 3 .and. mdate_rak < mdate_reg )
        If m1schet == 3
          mdate_rak := mdate_reg
        Else
          mdate_rak := pdate_lech[ 6 ] + 10
        Endif
      Endif
    Else
      mdate_rak := CToD( '' )
    Endif
  Endif

  Return update_gets()
