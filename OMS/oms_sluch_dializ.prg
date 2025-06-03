#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 03.02.15
Function f_d_dializ()

  If !( Left( DToS( mn_data ), 6 ) == Left( DToS( mk_data ), 6 ) )
    func_error( 4, '���� ��砫� � ����砭�� ��楤�� �� � ����� ����⭮� �����.' )
  Endif

  Return .t.

// 25.06.24 ���������� (1) � ���⮭����� ������ (2)
Function oms_sluch_dializ( par, Loc_kod, kod_kartotek )

  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  Static SKOD_DIAG := 'N18.5', st_N_DATA, st_K_DATA, st_vrach := 0
  // Local top2 := {2, 11}[par]
  // Local top2 := {1, 11}[par]
  Local top2 := { 1, 7 }[ par ]
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, ;
    buf := SaveScreen(), tmp_color := SetColor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', ;
    i, d, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, arr_usl, fl, ss, ;
    tmp_help := chm_help_code, fl_write_sluch := .f.
  Static kod_ksg := 'ds18.002', arr_lek := { ;
    { 'A25.28.001.001', '�९���� ������' }, ;
    { 'A25.28.001.002', '��⨠�����᪨� �९���� (�⨬����� ���ய��)' }, ;
    { 'A25.28.001.003', '��⨯���८���� �९����' }, ;
    { 'A25.28.001.004', '�९���� ��⠬��� D � ��� ��������' }, ;
    { 'A25.28.001.005', '�९���� �������᫮�, ������ �������樨 � �������⨤���' }, ;
    { 'A25.28.001.006', '�९���� ��� ��祭�� ����ઠ��樥���, ����ઠ������ � ��������⥬��' } }
  //
  Default st_N_DATA To BoM( sys_date ), st_K_DATA To EoM( sys_date )
  Private ;
    mkol_proc := 0, mkol_proc1 := 0, mkol_proc2 := 0, mkol_proc3 := 0, ; // ���-�� ��楤�� ������� ࠧ���� ����
  mkol_proc4 := 0, mkol_proc5 := 0, mkol_proc6 := 0, ;
    MFIO        := Space( 50 ), ; // �.�.�. ���쭮��
  mfam := Space( 40 ), mim := Space( 40 ), mot := Space( 40 ), ;
    mpol        := '�', ;
    mdate_r     := BoY( AddMonth( sys_date, -12 * 30 ) ), ;
    MVZROS_REB, M1VZROS_REB := 0, ;
    MADRES      := Space( 50 ), ; // ���� ���쭮��
  m1MEST_INOG := 0, newMEST_INOG := 0, ;
    MVID_UD, ; // ��� 㤮�⮢�७��
  M1VID_UD    := 14, ; // 1-18
  mser_ud := Space( 10 ), mnom_ud := Space( 20 ), ;
    mspolis := Space( 10 ), mnpolis := Space( 20 ), msmo := '34007', ;
    mnamesmo, m1namesmo, ;
    m1company := 0, mcompany, mm_company, ;
    m1KOMU := 0, MKOMU, M1STR_CRB := 0, ;
    mvidpolis, m1vidpolis := 1, ;
    msnils := Space( 11 ), ;
    mokatog := PadR( AllTrim( okato_umolch ), 11, '0' ), ;
    m1adres_reg := 1, madres_reg, ;
    rec_inogSMO := 0, ;
    mkol[ 6 ], musl_lek[ 6 ], ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := Space( 100 )
  AFill( mkol, 0 )
  AFill( musl_lek, 0 )
  //
  Private mkod := Loc_kod, mtip_h, is_talon := .f., ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    M1LPU := glob_uch[ 1 ], MLPU, ;
    M1OTD := glob_otd[ 1 ], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MUCH_DOC    := Space( 10 ), ; // ��� � ����� ��⭮�� ���㬥��
    MKOD_DIAG   := SKOD_DIAG, ; // ��� 1-�� ��.�������
    MKOD_DIAG2  := Space( 5 ), ; // ��� 2-�� ��.�������
    MKOD_DIAG3  := Space( 5 ), ; // ��� 3-�� ��.�������
    MKOD_DIAG4  := Space( 5 ), ; // ��� 4-�� ��.�������
    MSOPUT_B1   := Space( 5 ), ; // ��� 1-�� ᮯ������饩 �������
    MSOPUT_B2   := Space( 5 ), ; // ��� 2-�� ᮯ������饩 �������
    MSOPUT_B3   := Space( 5 ), ; // ��� 3-�� ᮯ������饩 �������
    MSOPUT_B4   := Space( 5 ), ; // ��� 4-�� ᮯ������饩 �������
    MDIAG_PLUS  := Space( 8 ), ; // ���������� � ���������
    mrslt, m1rslt := 0, ; // १����
    mishod, m1ishod := 0, ; // ��室
    MN_DATA     := st_N_DATA, ; // ��� ��砫� ��祭��
    MK_DATA     := st_K_DATA, ; // ��� ����砭�� ��祭��
    MVRACH      := Space( 10 ), ; // 䠬���� � ���樠�� ���饣� ���
    M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
    m1novor := 0, mnovor, mcount_reb := 0, ldnej := 0, ;
    mDATE_R2 := CToD( '' ), mpol2 := ' ', ;
    m1USL_OK, m1PROFIL := 56, m1PROFIL_K := 41 // ����������
  //
  Private mm_rslt := {}, mm_ishod := {}
  If par == 1 // ���������� (1)
    if glob_otd[ 3 ] == USL_OK_DAY_HOSPITAL
      m1USL_OK := USL_OK_DAY_HOSPITAL
      AEval( getv009(), {| x| iif( x[ 5 ] == m1usl_ok, AAdd( mm_rslt, x ), nil ) } )
      m1rslt := 201
      m1ishod := 203
    elseif glob_otd[ 3 ] == USL_OK_POLYCLINIC
      m1USL_OK := USL_OK_POLYCLINIC
      AEval( getv009(), {| x| iif( x[ 5 ] == m1usl_ok .and. x[ 2 ] < 316, AAdd( mm_rslt, x ), nil ) } )
      m1rslt := 314
      m1ishod := 304
    endif
  Else // ���⮭����� ������ (2)
    m1USL_OK := USL_OK_POLYCLINIC
    AEval( getv009(), {| x| iif( x[ 5 ] == m1usl_ok .and. x[ 2 ] < 316, AAdd( mm_rslt, x ), nil ) } )
    m1rslt := 314
    m1ishod := 304
  Endif
  AEval( getv012(), {| x| iif( x[ 5 ] == m1usl_ok, AAdd( mm_ishod, x ), nil ) } )
  //
  r_use( dir_server() + 'kartote_', , 'KART_' )
  Goto ( kod_kartotek )
  r_use( dir_server() + 'kartotek', , 'KART' )
  Goto ( kod_kartotek )
  mFIO        := kart->FIO
  mpol        := kart->pol
  mDATE_R     := kart->DATE_R
  m1VZROS_REB := kart->VZROS_REB
  mADRES      := kart->ADRES
  msnils      := kart->snils
  If kart->MI_GIT == 9
    m1KOMU    := kart->KOMU
    M1STR_CRB := kart->STR_CRB
  Endif
  If kart->MEST_INOG == 9 // �.�. �⤥�쭮 ����ᥭ� �.�.�.
    m1MEST_INOG := kart->MEST_INOG
  Endif
  m1vidpolis  := kart_->VPOLIS // ��� ����� (�� 1 �� 3);1-����, 2-�६., 3-����
  mspolis     := kart_->SPOLIS // ��� �����
  mnpolis     := kart_->NPOLIS // ����� �����
  msmo        := kart_->SMO    // ॥��஢� ����� ���
  m1vid_ud    := kart_->vid_ud   // ��� 㤮�⮢�७�� ��筮��
  mser_ud     := kart_->ser_ud   // ��� 㤮�⮢�७�� ��筮��
  mnom_ud     := kart_->nom_ud   // ����� 㤮�⮢�७�� ��筮��
  mokatog     := kart_->okatog       // ��� ���� ��⥫��⢠ �� �����
  m1okato     := kart_->KVARTAL_D    // ����� ��ꥪ� �� ����ਨ ���客����
  //
  arr := retfamimot( 1, .f. )
  mfam := PadR( arr[ 1 ], 40 )
  mim  := PadR( arr[ 2 ], 40 )
  mot  := PadR( arr[ 3 ], 40 )
  If AllTrim( msmo ) == '34'
    mnameismo := ret_inogsmo_name( 1, @rec_inogSMO )
  Elseif Left( msmo, 2 ) == '34'
    // ������ࠤ᪠� �������
  Elseif !Empty( msmo )
    m1ismo := msmo ; msmo := '34'
  Endif
  If eq_any( is_uchastok, 1, 3 )
    MUCH_DOC := PadR( amb_kartan(), 10 )
  Elseif mem_kodkrt == 2
    MUCH_DOC := PadR( lstr( mkod_k ), 10 )
  Endif
  Close databases
  chm_help_code := 3002
  //
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humankk', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  // �஢�ઠ ��室� = ������
  // find ( Str( mkod_k, 7 ) )
  // Do While human->kod_k == mkod_k .and. !Eof()
  //  If RecNo() != Loc_kod .and. is_death( human_->RSLT_NEW ) .and. ;
  //      human_->oplata != 9 .and. human_->NOVOR == 0
  //    a_smert := { '����� ���쭮� 㬥�!', ;
  //      '��祭�� � ' + full_date( human->N_DATA ) + ;
  //      ' �� ' + full_date( human->K_DATA ) }
  //    Exit
  //  Endif
  //  Skip
  // Enddo
  arr_patient_died_during_treatment( mkod_k, loc_kod )
  If !( Left( msmo, 2 ) == '34' ) // �� ������ࠤ᪠� �������
    m1ismo := msmo
    msmo := '34'
  Endif
  If m1vrach > 0
    r_use( dir_server() + 'mo_pers', , 'P2' )
    Goto ( m1vrach )
    MTAB_NOM := p2->tab_nom
    m1prvs := -ret_new_spec( p2->prvs, p2->prvs_new )
//    mvrach := PadR( fam_i_o( p2->fio ) + ' ' + ret_tmp_prvs( m1prvs ), 36 )
    mvrach := PadR( fam_i_o( p2->fio ) + ' ' + ret_str_spec( p2->PRVS_021 ), 36 )
  Endif
  Close databases
  fv_date_r( iif( Loc_kod > 0, mn_data, ) )
  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  mrslt     := inieditspr( A__MENUVERT, mm_rslt, m1rslt )
  mishod    := inieditspr( A__MENUVERT, mm_ishod, m1ishod )
  mlpu      := inieditspr( A__POPUPMENU, dir_server() + 'mo_uch', m1lpu )
  motd      := inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', m1otd )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
  mismo     := init_ismo( m1ismo )
  f_valid_komu( , -1 )
  If m1komu == 0
    m1company := Int( Val( msmo ) )
  Elseif eq_any( m1komu, 1, 3 )
    m1company := m1str_crb
  Endif
  mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
  If m1company == 34
    If !Empty( mismo )
      mcompany := PadR( mismo, 38 )
    Elseif !Empty( mnameismo )
      mcompany := PadR( mnameismo, 38 )
    Endif
  Endif
  str_1 := iif( par == 1, '�����������', '���⮭���쭮�� �������' ) + ' �� �����'
  If Loc_kod == 0
    str_1 := '���������� ' + str_1
    mtip_h := yes_vypisan
  Else
    str_1 := '������஢���� ' + str_1
  Endif
  SetColor( color8 )
  myclear( top2 )

  // SetMode(26, 80)

  @ top2 -1, 0 Say PadC( str_1, 80 ) Color 'B/BG*'
  Private gl_area := { 1, 0, MaxRow() -1, MaxCol(), 0 }
  status_key( '^<Esc>^ - ��室  ^<PgDn>^ - ������ ���⮢ ����' )
  SetColor( cDataCGet )
  make_diagp( 1 )  // ᤥ���� '��⨧����' ��������
  Private row_diag_screen := 9
  diag_screen( 0 )
  Do While .t.
    j := top2
    If yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 Say PadL( '���� ��� � ' + lstr( Loc_kod ), 29 ) Color color14
    Endif
    //
    @ ++j, 1 Say '��०�����' Get mlpu When .f. Color cDataCSay
    @ Row(), Col() + 2 Say '�⤥�����' Get motd When .f. Color cDataCSay
    //
    @ ++j, 1 Say '���' Get mfio_kart ;
      reader {| x| menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
      valid {| g, o| update_get( 'mkomu' ), update_get( 'mcompany' ) }
    //
    @ ++j, 1 Say '�ਭ���������� ����' Get mkomu ;
      reader {| x| menu_reader( x, mm_komu, A__MENUVERT, , , .f. ) } ;
      valid {| g, o| f_valid_komu( g, o ) } ;
      Color colget_menu
    @ Row(), Col() + 1 Say '==>' Get mcompany ;
      reader {| x| menu_reader( x, mm_company, A__MENUVERT, , , .f. ) } ;
      When diag_screen( 2 ) .and. m1komu < 5 ;
      valid {| g| func_valid_ismo( g, m1komu, 38 ) }
    //
    @ ++j, 1 Say '����� ���: ���' Get mspolis When m1komu == 0
    @ Row(), Col() + 3 Say '�����'  Get mnpolis When m1komu == 0
    @ Row(), Col() + 3 Say '���'    Get mvidpolis ;
      reader {| x| menu_reader( x, mm_vid_polis, A__MENUVERT, , , .f. ) } ;
      When diag_screen( 2 ) .and. m1komu == 0 ;
      Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
    //
    @ ++j, 1 Say '�᭮���� �������' Get mkod_diag Picture pic_diag When .f. // reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t., mn_data,iif(m1novor==0, mpol, mpol2))
    @ Row(), Col() Say ', ᮯ.�������' Get mkod_diag2 Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .t., .t., mn_data, iif( m1novor == 0, mpol, mpol2 ) )
    //
    @ ++j, 1 Say '� ���.�����' Get much_doc Picture '@!' ;
      When !( is_uchastok == 1 .and. is_task( X_REGIST ) ) ;
      .or. mem_edit_ist == 2
    // !(    �23/12356     � ���� '����������')
    @ Row(), Col() + 1 Say '���' Get MTAB_NOM Pict '99999' ;
      valid {| g| v_kart_vrach( g, .t. ) } When diag_screen( 2 )
    @ Row(), Col() + 1 Get mvrach When .f. Color color14
    //
    @ ++j, 1 Say '������ �஢������ �' Get mn_data valid {| g| f_d_dializ() }
    @ Row(), Col() + 1 Say '��' Get mk_data valid {| g| f_d_dializ() }
    //
    If par == 1
      @ ++j, 1 Say '������⢮ ��楤�� ������⢥���� �࠯��:'
      For i := 1 To 6
        @ ++j, 2 Say arr_lek[ i, 1 ] Get mkol[ i ] Pict '99'
        @ j, Col() + 1 Say arr_lek[ i, 2 ]
      Next
      @ ++j, 1 Say '������⢮ ����������� ��楤��' Get mkol_proc Pict '99'
      @ ++j, 1 Say '������⢮ ������������ ��楤��' Get mkol_proc1 Pict '99'

      If m1USL_OK == USL_OK_DAY_HOSPITAL .or. m1USL_OK == USL_OK_POLYCLINIC
        @ ++j, 1 Say '�������䨫����� (A18.05.011)' Get mkol_proc2 Pict '99'
      Endif
      // @ ++j, 1 say '������⢮ �������� �� ����襭�� ����䨫���樨 (�18.30.001.003)' get mkol_proc3 pict '99'
      If m1USL_OK == USL_OK_HOSPITAL
        @ ++j, 1 Say '������⢮ ���� ������ ���⮭���쭮�� ������� (A18.30.001)' Get mkol_proc4 Pict '99'
        @ ++j, 1 Say '������⢮ �������� � ��⮬�⨧�஢���묨 �孮����ﬨ (�18.30.001.002)' Get mkol_proc5 Pict '99'
        @ ++j, 1 Say '������⢮ �������� �� ����襭�� ����䨫���樨 (�18.30.001.003)' Get mkol_proc6 Pict '99'
      Endif
    Elseif par == 2
      @ ++j, 1 Say '������⢮ ���� ������ ���⮭���쭮�� ������� (A18.30.001)' Get mkol_proc4 Pict '99'
      @ ++j, 1 Say '������⢮ �������� � ��⮬�⨧�஢���묨 �孮����ﬨ (�18.30.001.002)' Get mkol_proc5 Pict '99'
      @ ++j, 1 Say '������⢮ �������� �� ����襭�� ����䨫���樨 (�18.30.001.003)' Get mkol_proc6 Pict '99'
    Endif
    @ ++j, 1 Say '������� ���饭��' Get mrslt ;
      reader {| x| menu_reader( x, mm_rslt, A__MENUVERT, , , .f. ) } ;
      valid {| g, o| f_valid_rslt( g, o ) }
    //
    @ ++j, 1 Say '��室 �����������' Get mishod ;
      reader {| x| menu_reader( x, mm_ishod, A__MENUVERT, , , .f. ) }
    If !Empty( a_smert )
      n_message( a_smert, , 'GR+/R', 'W+/R', , , 'G+/R' )
    Endif
    If pos_read > 0 .and. Lower( GetList[ pos_read ]:name ) == 'mishod'
      --pos_read
    Endif
    count_edit := myread(, @pos_read, ++k_read )
    diag_screen( 2 )
    k := f_alert( { PadC( '�롥�� ����⢨�', 60, '.' ) }, ;
      { ' ��室 ��� ����� ', ' ������ ', ' ������ � ।���஢���� ' }, ;
      iif( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N,N/BG' )
    If k == 3
      Loop
    Elseif k == 2
      If Empty( mn_data )
        func_error( 4, '�� ������� ��� ��砫� ��楤��.' )
        Loop
      Endif
      If Empty( mk_data )
        func_error( 4, '�� ������� ��� ����砭�� ��楤��.' )
        Loop
      Elseif Year( mk_data ) < 2018
        func_error( 4, '����� ०�� ࠡ�⠥� ⮫쪮 � 2018 ����.' )
        Loop
      Endif
      If mk_data < mn_data
        func_error( 4, '��� ����砭�� ����� ���� ��砫� ��楤��.' )
        Loop
      Endif
      If !( Left( DToS( mn_data ), 6 ) == Left( DToS( mk_data ), 6 ) )
        func_error( 4, '���� ��砫� � ����砭�� ��楤�� �� � ����� ����⭮� �����.' )
        Loop
      Endif
      ldnej := mk_data - mn_data + 1
      vlek := vdial := 0
      If par == 1
        If Empty( vdial := mkol_proc + mkol_proc1 + mkol_proc2 + mkol_proc3 + mkol_proc4 + mkol_proc5 + mkol_proc6 )
          func_error( 4, '������⢮ ��楤�� ����������� ࠢ�� ���' )
          Loop
        Elseif mkol_proc + mkol_proc1 + mkol_proc2 + mkol_proc3 + mkol_proc4 + mkol_proc5 + mkol_proc6 > ldnej
          func_error( 4, '������⢮ ��楤�� ����������� ����� ���⥫쭮�� ��祭��' )
          Loop
        Endif
        vlek := 0
        For i := 1 To 6
          vlek += mkol[ i ]
        Next
        If vlek > 0
          If Year( mk_data ) == 2018
            func_error( 4, '����� � ������⢥��묨 �९��⠬� ࠧ�襭� ⮫쪮 � 2019 ����.' )
            Loop
          Elseif !( AllTrim( mkod_diag ) == 'N18.5' )
            func_error( 4, '��� ��� ������⢥���� �࠯�� �᭮���� ������� ������ ���� N18.5' )
            Loop
          Endif
        Endif
      Endif
      If Empty( CharRepl( '0', much_doc, Space( 10 ) ) )
        func_error( 4, '�� �������� ����� ���㫠�୮� �����' )
        Loop
      Endif
      If m1vrach == 0
        func_error( 4, '�� �������� ⠡���� ����� ���饣� ���' )
        Loop
      Endif
      If m1komu < 5 .and. Empty( m1company )
        If m1komu == 0
          s := '���'
        Elseif m1komu == 1
          s := '��������'
        Else
          s := '������/��'
        Endif
        func_error( 4, '�� ��������� ������������ ' + s )
        Loop
      Endif
      If m1komu == 0 .and. Empty( mnpolis )
        func_error( 4, '�� �������� ����� �����' )
        Loop
      Endif
      If Empty( mkod_diag )
        func_error( 4, '�� ������ ��� �᭮����� �����������.' )
        Loop
      Endif
      err_date_diap( mn_data, '��� ��砫� ��楤��' )
      err_date_diap( mk_data, '��� ����砭�� ��楤��' )
      arr_usl := {}
      If par == 1
        If vlek > 0
          AAdd( arr_usl, { '55.1.1', 0, 0, iif( vlek > vdial, vlek, vdial ) } )
        Endif
        If mkol_proc > 0
          If mk_data >= 0d20240101
            AAdd( arr_usl, { '60.3.19', 0, 0, mkol_proc } )
          Else
            AAdd( arr_usl, { '60.3.9', 0, 0, mkol_proc } )
          Endif
        Endif
        If mkol_proc1 > 0
          If mk_data >= 0d20240101
            AAdd( arr_usl, { '60.3.20', 0, 0, mkol_proc1 } )
          Else
            AAdd( arr_usl, { '60.3.10', 0, 0, mkol_proc } )
          Endif
        Endif
        If mkol_proc2 > 0
          If mk_data >= 0d20240101
            AAdd( arr_usl, { '60.3.21', 0, 0, mkol_proc2 } )
          Else
            AAdd( arr_usl, { '60.3.11', 0, 0, mkol_proc2 } )
          Endif
        Endif
        If mkol_proc3 > 0
          AAdd( arr_usl, { '60.3.13', 0, 0, mkol_proc3 } )
        Endif
        If mkol_proc4 > 0
          AAdd( arr_usl, { '60.3.14', 0, 0, mkol_proc4 } )
        Endif
        If mkol_proc5 > 0
          AAdd( arr_usl, { '60.3.15', 0, 0, mkol_proc5 } )
        Endif
        If mkol_proc6 > 0
          AAdd( arr_usl, { '60.3.16', 0, 0, mkol_proc6 } )
        Endif
      Else
        // aadd(arr_usl, {'60.3.1', 0, 0, ldnej})
        If mkol_proc4 > 0
          AAdd( arr_usl, { '60.3.1', 0, 0, mkol_proc4 } )
        Endif
        If mkol_proc5 > 0
          AAdd( arr_usl, { '60.3.12', 0, 0, mkol_proc5 } )
        Endif
        If mkol_proc6 > 0
          AAdd( arr_usl, { '60.3.13', 0, 0, mkol_proc6 } )
        Endif
      Endif
      fv_date_r( mn_data ) // ��८�।������ M1VZROS_REB
      use_base( 'lusl' )
      use_base( 'luslc' )
      use_base( 'uslugi' )
      r_use( dir_server() + 'uslugi1', { dir_server() + 'uslugi1', ;
        dir_server() + 'uslugi1s' }, 'USL1' )
      glob_podr := ''
      glob_otd_dep := 0
      fl := .t.
      For i := 1 To Len( arr_usl )
        arr_usl[ i, 2 ] := foundourusluga( arr_usl[ i, 1 ], mk_data, m1PROFIL, m1VZROS_REB, @arr_usl[ i, 3 ] )
        If Empty( arr_usl[ i, 2 ] )
          fl := func_error( 4, '���� �� ���� ' + arr_usl[ i, 1 ] + ' ��������� � �ࠢ�筨�� �����' )
        Endif
      Next
      Close databases
      If !fl
        Loop
      Endif
      k := f_alert( { PadC( '����� �㤥� ����ᠭ ���� ����. �롥�� ����⢨�', 60, '.' ) }, ;
        { ' ��室 ��� ����� ', ' ������ ', ' ������ � ।���஢���� ' }, ;
        iif( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N,N/BG' )
      If k == 3
        Loop
      Elseif k == 1
        Exit
      Endif
      If mem_op_out == 2 .and. yes_parol
        box_shadow( 19, 10, 22, 69, cColorStMsg )
        str_center( 20, '������ "' + fio_polzovat + '".', cColorSt2Msg )
        str_center( 21, '���� ������ �� ' + date_month( sys_date ), cColorStMsg )
      Endif
      mywait()
      make_diagp( 2 )  // ᤥ���� '��⨧����' ��������
      If m1komu == 0
        msmo := lstr( m1company )
        m1str_crb := 0
      Else
        msmo := ''
        m1str_crb := m1company
      Endif
      st_N_DATA := MN_DATA
      st_K_DATA := MK_DATA
      st_VRACH := m1vrach
      SKOD_DIAG := SubStr( MKOD_DIAG, 1, 5 )
      Private mu_kod, mu_cena, fl_nameismo
      use_base( 'lusl' )
      use_base( 'luslc' )
      use_base( 'luslf' )
      use_base( 'mo_su' )
      use_base( 'uslugi' )
      r_use( dir_server() + 'uslugi1', { dir_server() + 'uslugi1', ;
        dir_server() + 'uslugi1s' }, 'USL1' )
      g_use( dir_server() + 'mo_hismo', , 'SN' )
      Index On Str( kod, 7 ) to ( cur_dir() + 'tmp_ismo' )
      use_base( 'mo_hu' )
      use_base( 'human_u' )
      use_base( 'human' )
      add1rec( 7 )
      mkod := RecNo()
      Replace human->kod With mkod
      Select HUMAN_
      Do While human_->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      Select HUMAN_2
      Do While human_2->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      glob_perso := mkod
      //
      human->kod_k      := mkod_k
      human->TIP_H      := B_STANDART
      human->FIO        := MFIO          // �.�.�. ���쭮��
      human->POL        := MPOL          // ���
      human->DATE_R     := MDATE_R       // ��� ஦����� ���쭮��
      human->VZROS_REB  := M1VZROS_REB   // 0-�����, 1-ॡ����, 2-�����⮪
      human->ADRES      := MADRES        // ���� ���쭮��
      human->KOD_DIAG   := MKOD_DIAG     // ��� 1-�� ��.�������
      human->KOD_DIAG2  := MKOD_DIAG2    // ��� 2-�� ��.�������
      human->KOD_DIAG3  := MKOD_DIAG3    // ��� 3-�� ��.�������
      human->KOD_DIAG4  := MKOD_DIAG4    // ��� 4-�� ��.�������
      human->SOPUT_B1   := MSOPUT_B1     // ��� 1-�� ᮯ������饩 �������
      human->SOPUT_B2   := MSOPUT_B2     // ��� 2-�� ᮯ������饩 �������
      human->SOPUT_B3   := MSOPUT_B3     // ��� 3-�� ᮯ������饩 �������
      human->SOPUT_B4   := MSOPUT_B4     // ��� 4-�� ᮯ������饩 �������
      human->diag_plus  := mdiag_plus    //
      human->KOMU       := M1KOMU        // �� 0 �� 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis( mspolis, mnpolis ) // ��� � ����� ���客��� �����
      human->LPU        := M1LPU         // ��� ��०�����
      human->OTD        := M1OTD         // ��� �⤥�����
      human->UCH_DOC    := MUCH_DOC // ��� � ����� ��⭮�� ���㬥��
      human->N_DATA     := MN_DATA // ��� ��砫� ��祭��
      human->K_DATA     := MK_DATA // ��� ����砭�� ��祭��
      human->CENA := human->CENA_1 := 0 // �⮨����� ��祭��
      human_->DISPANS   := Replicate( '0', 16 )
      human_->POVOD     := 1
      // human_->TRAVMA    := m1travma
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := LTrim( mspolis )
      human_->NPOLIS    := LTrim( mnpolis )
      human_->OKATO     := '' // �� ���� ������� �� ����� � ��砥 �����த����
      human_->NOVOR     := iif( m1novor == 0, 0, mcount_reb )
      human_->DATE_R2   := iif( m1novor == 0, CToD( '' ), mDATE_R2  )
      human_->POL2      := iif( m1novor == 0, '', mpol2     )
      human_->USL_OK    := m1USL_OK //
      human_->PROFIL    := m1PROFIL // 56
      human_->FORMA14   := '0000'
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // 㡥�� '2', �᫨ ��।���஢��� ������ �� ॥��� �� � ��
      human_->ST_VERIFY := 0 // ᭮�� ��� �� �஢�७
      human_->ID_PAC    := mo_guid( 1, human_->( RecNo() ) )
      human_->ID_C      := mo_guid( 2, human_->( RecNo() ) )
      human_->SUMP      := 0
      human_->SANK_MEK  := 0
      human_->SANK_MEE  := 0
      human_->SANK_EKMP := 0
      human_->REESTR    := 0
      human_->REES_ZAP  := 0
      human->schet      := 0
      human_->SCHET_ZAP := 0
      human->kod_p   := kod_polzovat    // ��� ������
      human->date_e  := c4sys_date
      put_0_human_2()
      human_2->PROFIL_K := m1PROFIL_K // 41
      fl_nameismo := .f.
      If m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ����� ��ꥪ� �� ����ਨ ���客����
        If Empty( m1ismo )
          If !Empty( mnameismo )
            fl_nameismo := .t.
          Endif
        Else
          human_->SMO := m1ismo  // �����塞 '34' �� ��� �����த��� ���
        Endif
      Endif
      If fl_nameismo .or. rec_inogSMO > 0
        Select SN
        find ( Str( mkod, 7 ) )
        If Found()
          If fl_nameismo
            g_rlock( forever )
            sn->smo_name := mnameismo
          Else
            deleterec( .t. )
          Endif
        Else
          If fl_nameismo
            addrec( 7 )
            sn->kod := mkod
            sn->smo_name := mnameismo
          Endif
        Endif
      Endif
      ss := 0
      // �����뢠�� ��㣨
      For i := 1 To Len( arr_usl )
        Select HU
        add1rec( 7 )
        mrec_hu := hu->( RecNo() )
        Replace hu->kod     With mkod, ;
          hu->kod_vr  With m1vrach, ;
          hu->kod_as  With 0, ;
          hu->u_koef  With 1, ;
          hu->u_kod   With arr_usl[ i, 2 ], ;
          hu->u_cena  With arr_usl[ i, 3 ], ;
          hu->is_edit With 0, ;
          hu->date_u  With dtoc4( MN_DATA ), ;
          hu->otd     With m1otd, ;
          hu->kol     With arr_usl[ i, 4 ], ;
          hu->stoim   With arr_usl[ i, 3 ] * arr_usl[ i, 4 ], ;
          hu->kol_1   With arr_usl[ i, 4 ], ;
          hu->stoim_1 With arr_usl[ i, 3 ] * arr_usl[ i, 4 ], ;
          hu->KOL_RCP With 0
        ss += arr_usl[ i, 3 ] * arr_usl[ i, 4 ]
        Select HU_
        Do While hu_->( LastRec() ) < mrec_hu
          Append Blank
        Enddo
        Goto ( mrec_hu )
        g_rlock( forever )
        If Loc_kod == 0 .or. !valid_guid( hu_->ID_U )
          hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
        Endif
        hu_->PROFIL   := m1PROFIL
        hu_->PRVS     := m1PRVS
        hu_->kod_diag := mkod_diag
        hu_->zf       := ''
      Next i
      If par == 1 .and. vlek > 0
        For i := 1 To Len( arr_lek )
          If mkol[ i ] > 0
            mu_kod := append_shifr_mo_su( arr_lek[ i, 1 ] )
            Select MOHU
            add1rec( 7 )
            mohu->kod     := mkod
            mohu->kod_vr  := m1vrach
            mohu->kod_as  := 0
            mohu->u_kod   := mu_kod
            mohu->u_cena  := 0
            mohu->date_u  := dtoc4( MN_DATA )
            mohu->otd     := m1otd
            mohu->kol_1   := mkol[ i ]
            mohu->stoim_1 := 0
            mohu->ID_U    := mo_guid( 4, mohu->( RecNo() ) )
            mohu->PROFIL  := m1PROFIL
            mohu->PRVS    := m1PRVS
            mohu->kod_diag := mkod_diag
          Endif
        Next
      Endif
      human->CENA := human->CENA_1 := ss // �⮨����� ��祭��
      write_work_oper( glob_task, OPER_LIST, iif( Loc_kod == 0, 1, 2 ), 1, count_edit )
      fl_write_sluch := .t.
      Close databases
      stat_msg( '������ �����襭�!', .f. )
      If par == 1 .and. vlek > 0
        f_1pac_definition_ksg( mkod )
      Endif
    Endif
    Exit
  Enddo
  Close databases
  diag_screen( 2 )
  SetColor( tmp_color )
  RestScreen( buf )
  chm_help_code := tmp_help
  // SetMode(25, 80)
  If fl_write_sluch // �᫨ ����ᠫ� - ����᪠�� �஢���
    verify_oms_sluch( mkod )
  Endif

  Return Nil
