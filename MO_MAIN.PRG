// mo_main.prg - ������ �����
//
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

External ust_printer, ErrorSys, ReadModal, like, flstr, prover_dbf, net_monitor, pr_view, ne_real
// ���� (।�� �ᯮ��㥬�) ������ ����᪠�� �� hrb-䠩��� (��� 㬥��襭�� �����)
Dynamic i_new_boln
Dynamic i_kol_del_zub
Dynamic phonegram_15_kz
Dynamic forma_792_MIAC
Dynamic f1forma_792_MIAC
Dynamic monitoring_vid_pom
Dynamic b_25_perinat_2

// 05.06.25
Procedure Main( ... )

  Local r, s, is_create := .f., is_copy := .f., is_index := .f.
  Local a_parol, buf, is_local_version
  Local verify_fio_polzovat := .t.
  Local cVar, i
  Local sPass, chPass
  Local nameTask := strippath( hb_argv( 0 ) ) // ��� ����饭��� �����

  For Each s IN hb_AParams() // ������ �室��� ��ࠬ��஢
    s := Lower( s )
    Do Case
    Case s == '/create'
      is_create := .t.
    Case s == '/copy'
      is_copy := .t.
    Case s == '/index'
      is_index := .t.
    Case SubStr( s, 1, 6 ) == '/pass='
      sPass := SubStr( s, 7 )
    Endcase
  Next

  app_ini()

  If isexerunning( nameTask ) // �஢����, ����饭� �� 㦥 ������ �����, �᫨ '��' - ��室 �� �����
    hb_Alert( '�ணࠬ�� "' + Upper( nameTask ) + '" 㦥 ����饭�. ����� ��ன ����� �� ࠧ���!' )
    app_finish()
  Endif

  //
//  Public Err_version := fs_version( _version() ) + ' �� ' + _date_version()
  Public kod_LIS   := { '125901', '805965' }
  //
  Public DELAY_SPRD := 0 // �६� ����প� ��� ࠧ���稢���� ��ப

  Public sdbf := '.DBF', sntx := '.NTX', stxt := '.TXT', ;
    sxml := '.XML', szip := '.ZIP', srar := '.RAR', smem := '.MEM', ;
    sini := '.INI', sfr3 := '.FR3', sfrm := '.FRM', spdf := '.PDF', ;
    scsv := '.CSV', sxls := '.xls', schip := '.CHIP', sdbt := '.dbt'

  Public public_mouse := .f., pravo_write := .t., pravo_read := .t., ;
    MenuTo_Minut := 0, sys_date := Date(), cScrMode := 'COLOR', ;
    DemoMode := .f., picture_pf := '@R 999-999-999 99', ;
    pict_cena := '9999999.99', forever := 'forever'
  Public gpasskod := ret_gpasskod()
  Public sem_task := '���� ࠡ��� ��'
  Public sem_vagno := '���� ࠡ��� �� - �⢥��⢥��� ०��'
  Public err_slock := '� ����� ������ � �⨬ ०���� ࠡ�⠥� ��㣮� ���짮��⥫�. ����� ������!'
  Public err_admin := '����� � ����� ०�� ࠧ�襭 ⮫쪮 ������������ ��⥬�!'
  Public err_sdemo := '�� ��������樮���� �����. ������ ����饭�!'
  Public fr_data := '_data', fr_titl := '_titl'

  Public dir_exe := dir_exe()
  Public cur_dir := chip_currpath()
  Public dir_server := '', p_name_comp := ''
//  Public dir_XML_MO := 'XML_MO', dir_XML_TF := 'XML_TF'
//  Public dir_NAPR_MO := 'NAPR_MO', dir_NAPR_TF := 'NAPR_TF'
//  Public _tmp_dir  := 'TMP___'
//  Public _tmp_dir1 := _tmp_dir() + hb_ps()
//  Public _tmp2dir  := 'TMP2___'
//  Public _tmp2dir1 := _tmp2dir() + hb_ps()
  //
  // ��ꥪ� ���짮��⥫� ��ॣ����஢��襣��� � ��⥬�
  Public hb_user_curUser := nil

  Public chm_help_code := 0
  // ��ꥪ� �࣠������ � ���ன ࠡ�⠥�
  Public hb_main_curOrg

  // ��७�� �� index_work_dir
  Public is_otd_dep := .f., glob_otd_dep := 0, mm_otd_dep := {}

  Public arr_12_VMP := {}
  Public is_napr_pol := .f., ; // ࠡ�� � ���ࠢ����ﬨ �� ��ᯨ⠫����� � �-��
  is_napr_stac := .f., ; // ࠡ�� � ���ࠢ����ﬨ �� ��ᯨ⠫����� � ��樮���
  glob_klin_diagn := {}  // ࠡ�� � ᯥ樠��묨 �������묨 ��᫥������ﬨ

  // ᮧ����� �������� ��६���� ��� ���
  Public is_MO_VMP := .f.
  For i := 2019 To WORK_YEAR
    cVar := 'is_' + SubStr( Str( i, 4 ), 3 ) + '_VMP'
    __mvPublic( cVar )
    __mvPut( cVar, .f. )
  Next

  // �ࠢ�筨� 業 �� ��㣨 ����� 2016-2017
  Public glob_MU_dializ := {}// 'A18.05.002.001','A18.05.002.002','A18.05.002.003', ;
  // 'A18.05.003','A18.05.003.001','A18.05.011','A18.30.001','A18.30.001.001'}
  Public glob_KSG_dializ := {}// '10000901','10000902','10000903','10000905','10000906','10000907','10000913', ;
  // '20000912','20000916','20000917','20000918','20000919','20000920'}
  // '1000901','1000902','1000903','1000905','1000906','1000907','1000913', ;
  // '2000912','2000916','2000917','2000918','2000919','2000920'}

  Public is_vr_pr_pp := .f., is_hemodializ := .f., is_per_dializ := .f., ;
    is_reabil_slux := .f., is_ksg_1300098 := .f., is_dop_ob_em := .f., glob_yes_kdp2[ 10 ], ;
    glob_menu_mz_rf := { .f., .f., .f. }

  Public is_alldializ := .f.

  Public glob_array_srf // ���ᨢ ���客�� ��������

  // ����� ��७�� �� index_work_dir

  SetClearB( ' ' )
  is_local_version := f_first( is_create )
  put_icon( full_name_version(), 'MAIN_ICON' )
  hard_err( 'create' )
  fillscreen( p_char_screen, p_color_screen ) // FillScreen('�','N+/N')
  SetColor( color1 )

  // ���樠������ ���ᨢ� ��, ����� ���� �� (�� ����室�����)
  r := init_mo()

  // ४�������� 䠩��� ����㯠 � ��⥬�
  reconstruct_security( is_local_version )

  If ! files_nsi_exists( dir_exe() )
    hard_err( 'delete' )
    app_finish()
  Endif

  If ! Empty( sPass )
    chPass := ''
    For i := 1 To Len( sPass )
      chPass += SubStr( sPass, i, 1 )
    Next
    Keyboard chPass
  Endif

  a_parol := inp_password_bay( is_local_version, is_create )

  index_work_dir( dir_exe(), cur_dir(), .f. )    // checkFilesTFOMS() ��२�������

  initpzarray()

  hb_main_curOrg := torganizationdb():getorganization()

  If ! hb_user_curUser:isadmin()  // tip_polzovat != TIP_ADM
    verify_fio_polzovat := .f.
  Endif
  If ! g_sopen( sem_task, sem_vagno, fio_polzovat, p_name_comp )
    If Type( 'verify_fio_polzovat' ) == 'L' .and. verify_fio_polzovat
      func_error( '� ����� ������ ࠡ�⠥� ��㣮� ������ ��� 䠬����� "' + fio_polzovat + '"' )
    Else
      If !hb_user_curUser:isadmin()
        hb_Alert( '� ����� ������ ��㣮� ����祩 �믮������ �⢥��⢥��� ०��. �஢���� ��⥬�� ������' )
      Else
        func_error( '����� ����饭! � ����� ������ ��㣮� ����祩 �믮������ �⢥��⢥��� ०��.' )
      Endif
    Endif
    If ! hb_user_curUser:isadmin()
      f_end()
    Endif
  Endif
  //
  checkversioninternet( r + 3, _version() )

//  illegal_stad_kod()  // �஢�ઠ �⠤�� ���������������

  init_first() // ��砫쭠� ���樠������ �ணࠬ�� (��६�����, ���ᨢ��,...)

  init_program() // ���樠������ �ணࠬ�� (��६�����, ���ᨢ��,...)

  If controlbases( 1, _version() ) // �᫨ ����室���
    If g_slock1task( sem_task, sem_vagno )  // ����� ����㯠 �ᥬ
      buf := SaveScreen()
      f_message( { '���室 �� ����� ����� �ணࠬ�� ' + fs_version( _version() ) + ' �� ' + _date_version() }, , , , 8 )
      // �஢��� ४�������� ��
      reconstruct_db( is_local_version, is_create )
      // �஢��� ४�������� �� ���� ���ࠢ����� �� ��ᯨ⠫�����
      reconstruct_263()
      // ��� ��砫� ࠡ��� _first_run() (�ࠫ � NOT_USED)
      pereindex() // ��易⥫쭮
      update_data_db( _version() )    // �஢��� ��������� � ���� �᫨ ����室���
      // ������� ���� ����� ���ᨨ
      controlbases( 3 )
      If glob_mo[ _MO_IS_UCH ]
        // correct_polis_from_sptk()  // ���४�஢�� ����ᮢ �� ॥��஢ ����
        // dubl_zap_kod_tf()          // 㤠���� �㡫����� ����ᥩ � ����⥪�
      Endif
      // ࠧ�襭�� ����㯠 �ᥬ
      g_sunlock( sem_vagno )
      RestScreen( buf )
    Else
      n_message( { '�� �����⨫� ����� ����� ����� ' + fs_version( _version() ) + ' �� ' + _date_version(), ;
        '�ॡ���� ४�������� (� ��२�����஢����) ���� ������.', ;
        '�� � ����� ������ ࠡ���� ��㣨� �����.', ;
        '����室���, �⮡� �� ���짮��⥫� ��諨 �� �����.' }, ;
        { '', '��� �����襭�� ࠡ��� ������ ���� �������' }, ;
        cColorSt2Msg, cColorStMsg, , , 'G+/R' )
      f_end( .f. )
    Endif
  Endif
  f_main( r, is_local_version, a_parol )
  f_end()
  Return

// 23.10.24 ���樠������ ���㦥��� �ਫ������
Function app_ini()

  Request HB_CODEPAGE_RU866
  hb_cdpSelect( 'RU866' )
  Request HB_LANG_RU866
  hb_langSelect( 'RU866' )
  Request DBFNTX
  rddSetDefault( 'DBFNTX' )
  Set( _SET_DELETED, .t. )
  Set Key K_F1 To f_help()
  // SET(_SET_EVENTMASK,INKEY_KEYBOARD)
  Set Scoreboard Off
  Set Exact On
  Set Date GERMAN
  Set Wrap On
  Set Century On
  Set Exclusive On
  Set Deleted On
  SetBlink( .f. )
  Set Key K_ALT_F3 To calendar
  Set Key K_ALT_F2 To calc
  Set Key K_ALT_X  To f_end
  ReadInsert( .t. ) // ०�� ।���஢���� �� 㬮�砭�� Insert
  Keyboard ''
  KSetNum( .t. )    // ������� NumLock
  SetCursor( 0 )
  Set Color To
  Return Nil

// 21.05.25
Function f_main( r0, is_local_version, a_parol )

  Static arr1 := { ;
    { '���������� �����������', X_REGIST, , .t., '������������' }, ;
    { '���� ����� ��樮���', X_PPOKOJ, , .t., '�������� �����' }, ;
    { '��易⥫쭮� ����樭᪮� ���客����', X_OMS, , .t., '���' }, ;
    { '���� ���ࠢ����� �� ��ᯨ⠫�����', X_263, , .f., '��������������' }, ;
    { '����� ��㣨', X_PLATN, , .t., '������� ������' }, ;
    { '��⮯����᪨� ��㣨 � �⮬�⮫����', X_ORTO, , .t., '���������' }, ;
    { '���� ����樭᪮� �࣠����樨', X_KASSA, , .t., '�����' } ;
    }

  // { '��� ����樭᪮� �࣠����樨', X_KEK, , .f., '���' } ;

  Static arr2 := { ;
    { '������஢���� �ࠢ�筨���', X_SPRAV, , .t. }, ;
    { '��ࢨ�� � ����ன��', X_SERVIS, , .t. }, ;
    { '����ࢭ�� ����஢���� ���� ������', X_COPY, , .t. }, ;
    { '��२�����஢���� ���� ������', X_INDEX, , .t. } ;
    }
  Local i, lens := 0, r, c, oldTfoms, arr, ar, k, fl_exit := .t.
  Local buf

  Public array_tasks := {}, sem_vagno_task[ 24 ]

  AFill( sem_vagno_task, '' )
  For i := 1 To Len( arr1 )
    AAdd( array_tasks, arr1[ i ] )
    sem_vagno_task[ arr1[ i, 2 ] ] := '����� ०�� � ����� "' + arr1[ i, 5 ] + '"'
  Next

  If glob_mo[ _MO_KOD_TFOMS ] == TF_KOD_MO_VOUNC
    AAdd( array_tasks, { '����� - �࠭ᯫ���஢����', X_MO, 'TABLET_ICON', .t. } )
  Endif

  For i := 1 To Len( arr2 )
    AAdd( array_tasks, arr2[ i ] )
  Next
  //
  arr := {}
  For i := 1 To Len( array_tasks )
    If ( k := array_tasks[ i, 2 ] ) < 10  // ��� �����
      array_tasks[ i, 4 ] := ( SubStr( glob_mo[ _MO_PROD ], k, 1 ) == '1' )
      If array_tasks[ i, 4 ]
        fl_exit := .f.
      Endif
    Endif
    // ���� ���ࠢ����� �� ��ᯨ⠫�����
    If k == X_263 .and. ( is_napr_pol .or. is_napr_stac ) // .and. ( substr( glob_mo[ _MO_PROD ], X_263, 1 ) == '1' )
      array_tasks[ i, 4 ] := .t.
      fl_exit := .f.
    Endif
    If is_local_version
      If array_tasks[ i, 4 ]
        AAdd( arr, array_tasks[ i ] )
        lens := Max( lens, Len( array_tasks[ i, 1 ] ) )
      Endif
    Else
      If array_tasks[ i, 4 ] .and. hb_user_curUser:isallowedtask( i )
        AAdd( arr, array_tasks[ i ] )
        lens := Max( lens, Len( array_tasks[ i, 1 ] ) )
      Endif
    Endif
  Next
  Public glob_task, blk_ekran, g_arr_stand := {}, ;
    main_menu, main_message, first_menu, ;
    first_message, func_menu, cmain_menu
  If fl_exit
    func_error( 4, '��� ࠧ�襭�� �� ࠡ��� �� � ����� �����!' )
  Else
    // �뢥�� ���孨� ��ப� �������� ��࠭�
    r0 := main_up_screen()
    // �뢥�� 業�ࠫ�� ��ப� �������� ��࠭�
    main_center_screen( r0, a_parol )
    If hb_user_curUser:isadmin()
      find_unfinished_reestr_sp_tk( .f., .t. )
      find_time_limit_human_reestr_sp_tk()
//      If glob_mo[ _MO_KOD_TFOMS ] == '711001' // ��-���쭨�
//      find_unfinished_r01()
      find_unfinished_r11()
//      Endif
    Endif
    //
    r := Int( ( MaxRow() - r0 - Len( arr ) ) / 2 ) -1
    c := Int( ( MaxCol() + 1 - lens ) / 2 ) -1
    ar := getinisect( tmp_ini, 'task' )
    k := i := Int( Val( a2default( ar, 'current_task', lstr( X_OMS ) ) ) )
    Do While .t.
      If ( i := popup_2array( arr, r + r0, c, i, , , '�롮� �����', 'B+/W', 'N+/W, W+/N*' ) ) == 0
        Exit
      Endif
      oldTfoms := glob_mo[ _MO_KOD_TFOMS ]
      buf := SaveScreen()
      k := i
      f1main( i )
      RestScreen( buf )
      reread_glob_mo()
      If !( oldTfoms == glob_mo[ _MO_KOD_TFOMS ] )
        // �뢥�� ���孨� ��ப� �������� ��࠭�
        r0 := main_up_screen()
        // �뢥�� 業�ࠫ�� ��ப� �������� ��࠭�
        main_center_screen( r0 )
      Endif
      change_sys_date() // ������� ��⥬��� ����
      put_icon( full_name_version(), 'MAIN_ICON' ) // ��ॢ뢥�� ��������� ����
      @ r0, 0 Say full_date( sys_date ) Color 'W+/N' // ��ॢ뢥�� ����
      @ r0, MaxCol() -4 Say hour_min( Seconds() ) Color 'W+/N' // ��ॢ뢥�� �६�
    Enddo
    setinisect( tmp_ini, 'task', { { 'current_task', lstr( k ) } } )
  Endif
  Return Nil

// �뢥�� ���孨� ��ப� �������� ��࠭�
Function main_up_screen()

  Local i, k, s, arr[ 2 ]

  fillscreen( p_char_screen, p_color_screen ) // FillScreen('�','N+/N')
  s := '��� ' + iif( glob_mo[ _MO_IS_MAIN ], '��', '���ᮡ������� ���ࠧ�������' ) + ;
    ', ��᢮���� �����: ' + glob_mo[ _MO_KOD_TFOMS ] + ;
    ' (॥��஢� � ' + glob_mo[ _MO_KOD_FFOMS ] + ')'
  @ 0, 0 Say PadC( s, MaxCol() + 1 ) Color 'W+/N'
  s := iif( glob_mo[ _MO_IS_MAIN ], '', '���ᮡ������ ���ࠧ�������: ' ) + ;
    glob_mo[ _MO_FULL_NAME ]
  k := perenos( arr, s, MaxCol() + 1 )
  For i := 1 To k
    @ i, 0 Say PadC( AllTrim( arr[ i ] ), MaxCol() + 1 ) Color 'GR+/N'
  Next
  i := get_uroven()
  If Between( i, 1, 3 )
    s := '�஢��� 業 �� ����樭᪨� ��㣨: ' + lstr( i )
  Else
    s := '�������㠫�� ���� �� ����樭᪨� ��㣨'
  Endif
  @ k + 1, 0 Say Space( MaxCol() + 1 ) Color 'G+/N'
  @ k + 1, 0 Say full_date( sys_date ) Color 'W+/N'
  @ k + 1, MaxCol() -4 Say hour_min( Seconds() ) Color 'W+/N'
  Return k + 1

// �뢥�� 業�ࠫ�� ��ப� �������� ��࠭�
Function main_center_screen( r0, a_parol )

  Static nLen := 11
  Static arr_name := { '�����', '������', '���', '���������', ;
    '���������', '梨�', 'த���� �ࠢ��', ;
    '����஦����� � ������ ���ᮩ ⥫�', ;
    '��⬠', '������', '����ॠ��' }
  Local s, i, c, k, t_arr, r1, buf, mst := ''

  g_arr_stand := {}
  If ValType( glob_mo[ _MO_STANDART ] ) == 'A'
    For k := 1 To Len( glob_mo[ _MO_STANDART ] )
      t_arr := { glob_mo[ _MO_STANDART, k, 1 ], {} }
      mst := PadR( glob_mo[ _MO_STANDART, k, 2 ], nLen )
      For i := 1 To nLen
        c := SubStr( mst, i, 1 )
        If c == '1'
          AAdd( t_arr[ 2 ], i )
        Endif
      Next
      AAdd( g_arr_stand, AClone( t_arr ) )
    Next
  Endif
  If .t.
    If ValType( a_parol ) == 'A' .and. ( k := Len( a_parol ) ) > 0
      r1 := r0 + Int( ( MaxRow() - r0 - k ) / 2 ) -1
      n_message( a_parol, , 'W+/W*', 'R/W*', r1, , 'N+/W*' )
    Endif
  Else
    s := '���������᪨� ���, �� ����� �� ������ � �믮������ �⠭���⮢:'
    For i := 1 To nLen
      c := SubStr( mst, i, 1 )
      If eq_any( c, '1', '2' )
        s += ' ' + arr_name[ i ]
        If c == '2'
          s += '[*]'
        Endif
        s += ','
      Endif
    Next
    s := Left( s, Len( s ) -1 )
    t_arr := Array( 2 )
    k := perenos( t_arr, s, 64 )
    r1 := r0 + Int( ( MaxRow() - r0 - k ) / 2 ) -1
    If ( k := Len( a_parol ) ) > 0
      If r1 - r0 < k + 4
        r1 := r0 + k + 4
      Endif
      buf := save_box( r1 - k - 4, 0, r1 - 1, MaxCol() )
      f_message( a_parol, , 'W+/W*', 'R/W*', r1 - k - 3 )
    Endif
    n_message( t_arr, , 'W/W', 'N/W', r1, , 'N+/W' )
    If buf != NIL
      rest_box( buf )
    Endif
  Endif
  Return Nil

//
Function m_help()

  Local tmp_help, pt

  tmp_help := chm_help_code
  chm_help_code := 100
  f_help()
  chm_help_code := tmp_help
  Return Nil

// 05.06.25
Function f_first( is_create )

  Local is_local_version := .t.

  Public help_code := -1
  Public yes_color := .t.
  Public color0, color1, cColorWait, cColorSt2Msg, cColorStMsg, ;
    cCalcMain, cHelpCMain, cColorText, ;
    cHelpCTitle, cHelpCStatus, cDataCScr, cDataCGet, cDataCSay, ;
    cDataCMenu, color13, color14, cColorSt1Msg, cDataPgDn, col_tit_popup, ;
    color5, color8, col1menu := '', col2menu := '', ;
    color_uch, col_tit_uch
  Public n_list := 1, tek_stroke := 0, fp // ��� ⥪�⮢�� ���⮢
  Public p_color_screen := 'W/N*', p_char_screen := ' ' // ���������� ��࠭�
  Public c__cw := 'N+/N' // 梥� ⥭��
  //

  color0 := 'N/BG, W+/N'
  color1 := 'W+/B, W+/R'
  color_uch := 'B/BG, W+/B' ; col_tit_uch := 'B+/BG'
  col1menu := color0 + ', B/BG, BG+/N'
  col2menu := color0 + ', B/BG, BG+/N'
  col_tit_popup := 'B/BG'
  //
  cColorStMsg := 'W+/R, , , , B/W'                 // Stat_msg
  cColorSt1Msg := 'W+/R, , , , B/W'                // Stat_msg
  cColorSt2Msg := 'GR+/R, , , , B/W'               // Stat_msg
  cColorWait := 'W+/R*, , , , B/W'                 // ����
  //
  cCalcMain := 'N/W, GR+/R'                     // ��������
  //
  cColorText := 'W+/N, BG+/N, , , B/W'
  //
  cHelpCMain := 'W+/RB, W+/N, , , B/W'             // ������
  cHelpCTitle := 'G+/RB'
  cHelpCStatus := 'BG+/RB'
  // ���� ������
  cDataCScr  := 'W+/B, B/BG'
  cDataCGet  := 'W+/B, W+/R, , , BG+/B'
  cDataCSay  := 'BG+/B, W+/R, , , BG+/B'
  cDataCMenu := 'N/BG, W+/N, , , B/W'
  cDataPgDn  := 'BG/B'
  color5     := 'N/W, GR+/R, , , B/W'
  color8     := 'GR+/B, W+/R'
  color13    := 'W/B, W+/R, , , BG+/B'             // �����p�� �뤥�����
  color14    := 'G+/B, W+/R'
  //

  dir_server := read_server_mem( @is_local_version )
  p_name_comp := iif( is_local_version, '', AllTrim( NetName() ) + hb_ps() + hb_UserName() )

  if ! checking_access_to_server( dir_server() )
    app_finish()
  endif

  If !is_create .and. !hb_FileExists( dir_server() + 'human' + sdbf() )
    func_error( '�� �����㦥�� 䠩�� ���� ������! ������� � ��⥬���� ������������.' )
    app_finish()
  Endif
  //
  If hb_FileExists( dir_server() + 'plat.dbf' )
    func_error( '����⭥� �ᥣ�, �� ����᪠�� �ணࠬ�� � ��⠫��� �����. �� �������⨬�!' )
    app_finish()
  Endif
//  Public flag_chip := .f.
//  Delete file ttt.ttt
  hb_vfErase( cur_dir() + 'ttt.ttt' )
  Return is_local_version

// 17.11.23
Function hard_err( p )

  // k = 1 - �஢�ઠ ��᪠ �� ����稥 �६������ 䠩�� hard_err.meh
  // �, �᫨ �� ����, �뢮� ⥪�� � ����室����� ��२�����஢����;
  // ᮧ����� �६������ 䠩�� hard_err.meh 'CREATE'
  // k = 2 - 㤠����� �६������ 䠩�� hard_err.meh 'DELETE'
  Local k := 3, arr := {}

  If ValType( p ) == 'N'
    k := p
  Elseif ValType( p ) == 'C'
    p := Upper( p )
    Do Case
    Case p == 'CREATE'
      k := 1
    Case p == 'DELETE'
      k := 2
    Endcase
  Endif
  Do Case
  Case k == 1
    If File( 'hard_err.meh' )
      fillscreen( p_char_screen, p_color_screen )
      AAdd( arr, '��᫥���� ࠧ �� ��室� �� ����� �� ᡮ� �� ��⠭��.' )
      AAdd( arr, '. . .' )
      AAdd( arr, '���⮬� ��� �����⥫쭮 ४��������� �믮�����' )
      AAdd( arr, '०�� "��२�����஢����", �.�. ������ ����⭮, ��' )
      AAdd( arr, '������� ������� 䠩�� �뫨 �ᯮ�祭� ��� ࠧ��襭�.' )
      Keyboard ''
      f_message( arr, , color1, color8, , , color1 )
      If f_alert( { PadC( '�롥�� ����⢨�', 60, '.' ) }, ;
          { ' ��室 �� ����� ', ' �த������� ࠡ��� ' }, ;
          1, 'W+/N', 'N+/N', 20, , 'W+/N, N/BG' ) != 2
        app_finish()
      Endif
      fillscreen( p_char_screen, p_color_screen )
    Endif
    StrFile( 'hard_error', 'hard_err.meh' )
  Case k == 2
    Delete file hard_err.meh
  Endcase
  Return Nil

// 03.12.13
Function f_err_sem_vagno_task( n_Task )

  Return func_error( 4, '� ����� "' + array_tasks[ ind_task( n_Task ), 5 ] + ;
    '" �믮������ ������������� ������. ����� �६���� ������!' )

// 03.12.13
Function mo_lock_task( n_Task )

  Local i, fl := .t., n := 0

  Default n_Task To glob_task
  If glob_task == n_Task // �᫨ ��뢠���� �� ����� n_Task,
    ++n                  // � ���ᨬ� 1 ���짮��⥫�
  Endif
  i := ind_task( n_Task )
  If !g_svaluenlock( f_name_task( n_Task ), n, sem_vagno_task[ n_Task ] )
    fl := func_error( '� ����� "' + array_tasks[ i, 5 ] + '" ࠡ���� ���짮��⥫�. ������ �६���� ����饭�!' )
  Endif
  Return fl

// 03.12.13
Function mo_unlock_task( n_Task )

  Return g_sunlock( sem_vagno_task[ n_Task ] )

// ������ ��� ����� �� ��஢��� ����
Function f_name_task( n_Task )

  Local it, s

  Default n_Task To glob_task
  s := lstr( n_Task )
  If ( it := AScan( array_tasks, {| x| x[ 2 ] == n_Task } ) ) > 0
    s := array_tasks[ it, 1 ]
  Endif
  Return s

// �஢����, ����㯭� �� ������� �� �����⭠� �����
Function is_task( n_Task )

  Local it

  If !( Type( 'array_tasks' ) == 'A' ) // � ��砫� �����  ��� �� ��।��� ���ᨢ
    Return .f.
  Endif
  Default n_Task To glob_task
  If ( it := AScan( array_tasks, {| x| x[ 2 ] == n_Task } ) ) == 0
    Return .f.
  Endif
  Return array_tasks[ it, 4 ]

// ������ ������ ���ᨢ� �����⭮� �����
Function ind_task( n_Task )

  Local it

  Default n_Task To glob_task
  If ( it := AScan( array_tasks, {| x| x[ 2 ] == n_Task } ) ) == 0
    it := 3 // ���
  Endif
  Return it

// 17.11.23
Function app_finish()

  Set Key K_ALT_F3 To
  Set Key K_ALT_F2 To
  Set Key K_ALT_X  To
  Set Color To
  Set Cursor On
  CLS
  Quit
  Return Nil

// 05.06.25
Function f_end( yes_copy )

  Static group_ini := 'RAB_MESTO'
  Local i, spath := '', bSaveHandler := ErrorBlock( {| x| Break( x ) } )

  Begin Sequence
    write_rest_pp() // ������� ������ᠭ�� ���ਨ �������� �� ��񬭮�� �����
    Close All
    Default yes_copy To .t.
    If yes_copy
      i := getinivar( tmp_ini, { { group_ini, 'base_copy', '1' }, ;
        { group_ini, 'path_copy', '' } } )
      If i[ 1 ] != Nil .and. i[ 1 ] == '1' .and. g_slock1task( sem_task, sem_vagno )
        If Len( i ) > 1 .and. i[ 2 ] != Nil .and. !Empty( i[ 2 ] )
          spath := i[ 2 ]
        Endif
        m_copy_db_from_end( .f., spath ) // १�ࢭ�� ����஢����
        g_sunlock( sem_vagno ) // ࠧ�襭�� ����㯠 �ᥬ
      Endif
    Endif
  RECOVER USING error
    //
  End
  //
  Begin Sequence
    g_sclose( sem_task ) // 㤠���� �� ᥬ���� ��� ������ �����
  RECOVER USING error
    //
  End
  ErrorBlock( bSaveHandler )
  //
  hard_err( 'delete' )
//  If __mvExist( 'cur_dir()' )
    FileDelete( cur_dir() + 'tmp*.dbf' )
    FileDelete( cur_dir() + 'tmp*.ntx' )
    FileDelete( _tmp_dir1() + '*.*' )
    If hb_DirExists( cur_dir() + _tmp_dir() ) .and. hb_DirDelete( cur_dir() + _tmp_dir() ) != 0
      // func_error(4, '�� ���� 㤠���� ��⠫�� ''+'cur_dir()'+'_tmp_dir())
    Endif
    FileDelete( _tmp2dir1() + '*.*' )
    If hb_DirExists( cur_dir() + _tmp2dir() ) .and. hb_DirDelete( cur_dir() + _tmp2dir() ) != 0
      // func_error(4, '�� ���� 㤠���� ��⠫�� ' + cur_dir() + _tmp2dir())
    Endif
//  Endif
  // 㤠��� 䠩�� ���⮢ � �ଠ� '*.HTML' �� �६����� ��४�ਨ
  FileDelete( hb_DirTemp() + '*.html' )
  delfrfiles()
  app_finish()
  Return Nil
