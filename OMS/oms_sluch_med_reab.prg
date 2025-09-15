#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 25.06.24 ���㫠�ୠ� ����樭᪠� ॠ������� - ���������� ��� ।���஢���� ���� (���� ���)
Function oms_sluch_med_reab( Loc_kod, kod_kartotek )

  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)

  Static skod_diag := '     ', st_n_data, st_k_data, ;
    st_vrach := 0, st_rslt := 0, st_ishod := 0

  Local str_1
  Local j // ���稪 ��ப �࠭�
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, ;
    buf, tmp_color := SetColor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', ;
    i, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    fl_write_sluch := .f., when_uch_doc := .t.
  Local tlist_rslt, list_rslt := {}, list_ishod, row
  Local aReab, sArr := ''

  Default st_n_data To sys_date, st_k_data To sys_date
  Default Loc_kod To 0, kod_kartotek To 0

  // /++++
  buf := SaveScreen()

  Private mm_rslt, mm_ishod, rslt_umolch := 0, ishod_umolch := 0, ;
    m1USL_OK := USL_OK_POLYCLINIC, mUSL_OK, ;    // ⮫쪮 ���㫠�୮
    m1PROFIL := 158, mPROFIL     // ����樭᪠� ॠ�������

  Private mkod := Loc_kod, ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    mtip_h, ;
    m1lpu := glob_uch[ 1 ], mlpu, ;
    m1otd := glob_otd[ 1 ], motd, ;
    mfio := Space( 50 ), mpol, mdate_r, madres, mmr_dol, ;
    m1fio_kart := 1, mfio_kart, ;
    m1vzros_reb, mvzros_reb, mpolis, m1rab_nerab, ;
    much_doc    := Space( 10 ),; // ��� � ����� ��⭮�� ���㬥��
    m1npr_mo := '', mnpr_mo := Space( 10 ), mnpr_date := CToD( '' ), ;
    mkod_diag   := skod_diag, ; // ��� 1-�� ��.�������
    mrslt, m1rslt := st_rslt, ; // १����
    mishod, m1ishod := st_ishod, ; // ��室
    m1company := 0, mcompany, mm_company, ;
    mkomu, m1komu := 0, m1str_crb := 0, ; // 0-���,1-��������,3-�������/���,5-���� ���
    m1reg_lech := 0, mreg_lech, ;
    mn_data     := st_n_data, ; // ��� ��砫� ��祭��
    mk_data     := st_k_data, ; // ��� ����砭�� ��祭��
    MCENA_1     := 0, ; // �⮨����� ��祭��
    MVRACH      := Space( 10 ), ; // 䠬���� � ���樠�� ���饣� ���
    M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
    msmo := '', rec_inogSMO := 0, ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := Space( 100 ), ;
    mvidpolis, m1vidpolis := 1, mspolis := Space( 10 ), mnpolis := Space( 20 ), ;
    mvidreab, m1vidreab := 0, ;           // ॠ������� �� �����������
    mshrm, m1shrm := 0, ;                 // ����� ��������樮���� ������⨧�樨
    mvto, m1vto := 0                      // �ᯮ�짮����� ��᮪��孮�����᪮�� ����㤮�����

  private ;                   // ��� ᮢ���⨬���
    MKOD_DIAG0  := Space( 6 ), ; // ��� ��ࢨ筮�� ��������
    MKOD_DIAG2  := Space( 5 ), ; // ��� 2-�� ��.�������
    MKOD_DIAG3  := Space( 5 ), ; // ��� 3-�� ��.�������
    MKOD_DIAG4  := Space( 5 ), ; // ��� 4-�� ��.�������
    MSOPUT_B1   := Space( 5 ), ; // ��� 1-�� ᮯ������饩 �������
    MSOPUT_B2   := Space( 5 ), ; // ��� 2-�� ᮯ������饩 �������
    MSOPUT_B3   := Space( 5 ), ; // ��� 3-�� ᮯ������饩 �������
    MSOPUT_B4   := Space( 5 ), ; // ��� 4-�� ᮯ������饩 �������
    MDIAG_PLUS  := Space( 8 ), ; // ���������� � ���������
    MOSL1       := Space( 6 ), ; // ��� 1-��� �������� �᫮������ �����������
    MOSL2       := Space( 6 ), ; // ��� 2-��� �������� �᫮������ �����������
    MOSL3       := Space( 6 )    // ��� 3-��� �������� �᫮������ �����������

  r_use( dir_server() + 'human_2', , 'HUMAN_2' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  If mkod_k > 0
    r_use( dir_server() + 'kartote2', , 'KART2' )
    Goto ( mkod_k )
    r_use( dir_server() + 'kartote_', , 'KART_' )
    Goto ( mkod_k )
    r_use( dir_server() + 'kartotek', , 'KART' )
    Goto ( mkod_k )
    M1FIO       := 1
    mfio        := kart->fio
    mpol        := kart->pol
    mdate_r     := kart->date_r
    M1VZROS_REB := kart->VZROS_REB
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    m1RAB_NERAB := kart->RAB_NERAB
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    m1okato     := kart_->KVARTAL_D    // ����� ��ꥪ� �� ����ਨ ���客����
    msmo        := kart_->SMO
    If kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    Endif
    If eq_any( is_uchastok, 1, 3 )
      much_doc := PadR( amb_kartan(), 10 )
    Elseif mem_kodkrt == 2
      much_doc := PadR( lstr( mkod_k ), 10 )
    Endif
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 1, , .t. ) // ������ � �������
    Endif

    // �஢�ઠ ��室� = ������
    Select HUMAN
    Set Index to ( dir_server() + 'humankk' )
    // find (str(mkod_k, 7))
    // do while human->kod_k == mkod_k .and. !eof()
    // if recno() != Loc_kod .and. is_death(human_->RSLT_NEW) .and. ;
    // human_->oplata != 9 .and. human_->NOVOR == 0
    // a_smert := {'����� ���쭮� 㬥�!', ;
    // '��祭�� � ' + full_date(human->N_DATA) + ' �� ' + full_date(human->K_DATA)}
    // exit
    // endif
    // skip
    // enddo
    arr_patient_died_during_treatment( mkod_k, loc_kod )
    Set Index To
  Endif

  If Loc_kod > 0
    Select HUMAN
    Goto ( Loc_kod )
    M1LPU       := human->LPU
    M1OTD       := human->OTD
    M1FIO       := 1
    mfio        := human->fio
    mpol        := human->pol
    mdate_r     := human->date_r
    MTIP_H      := human->tip_h
    M1VZROS_REB := human->VZROS_REB
    MADRES      := human->ADRES         // ���� ���쭮��
    MMR_DOL     := human->MR_DOL        // ���� ࠡ��� ��� ��稭� ���ࠡ�⭮��
    M1RAB_NERAB := human->RAB_NERAB     // 0-ࠡ���騩, 1-��ࠡ���騩
    much_doc    := human->uch_doc
    m1reg_lech  := human->reg_lech
    m1VRACH     := human_->vrach
    MKOD_DIAG   := human->KOD_DIAG
    MPOLIS      := human->POLIS         // ��� � ����� ���客��� �����

    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    If Empty( Val( msmo := human_->SMO ) )
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    Else
      m1komu := m1str_crb := 0
    Endif

    m1okato    := human_->OKATO  // ����� ��ꥪ� �� ����ਨ ���客����
    m1USL_OK   := human_->USL_OK
    m1PROFIL   := human_->PROFIL
    m1NPR_MO   := human_->NPR_MO
    mNPR_DATE  := human_2->NPR_DATE

    aReab      := list2arr( human_2->PC5 )
    m1vidreab  := aReab[ 1 ]
    m1shrm     := aReab[ 2 ]
    if len( aReab ) > 2
      m1vto     := aReab[ 3 ]
    endif
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    m1rslt     := human_->RSLT_NEW
    m1ishod    := human_->ISHOD_NEW

    mcena_1 := human->CENA_1

    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 2, @rec_inogSMO, .t. ) // ������ � �������
    Endif
  Endif

  If !( Left( msmo, 2 ) == '34' ) // �� ������ࠤ᪠� �������
    m1ismo := msmo
    msmo := '34'
  Endif

  If Loc_kod == 0
    r_use( dir_server() + 'mo_otd', , 'OTD' )
    Goto ( m1otd )
  Endif
  r_use( dir_server() + 'mo_uch', , 'UCH' )
  Goto ( m1lpu )
  mlpu := RTrim( uch->name )

  If m1vrach > 0
    r_use( dir_server() + 'mo_pers', , 'P2' )
    Goto ( m1vrach )
    MTAB_NOM := p2->tab_nom
    m1prvs := -ret_new_spec( p2->prvs, p2->prvs_new )
//    mvrach := PadR( fam_i_o( p2->fio ) + ' ' + ret_tmp_prvs( m1prvs ), 36 )
    mvrach := PadR( fam_i_o( p2->fio ) + ' ' + ret_str_spec( p2->PRVS_021 ), 36 )
  Endif

  Close databases

  tlist_rslt := getrslt_usl_date( m1USL_OK, mk_data )
  For Each row in tlist_rslt
    If Between( row[ 2 ], 301, 315 )
      AAdd( list_rslt, row )
    Endif
  Next
  list_ishod := getishod_usl_date( m1USL_OK, mk_data )

  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  mUSL_OK   := inieditspr( A__MENUVERT, getv006(), m1USL_OK )

  mPROFIL   := inieditspr( A__MENUVERT, getv002(), m1PROFIL )
  If !Empty( m1NPR_MO )
    mNPR_MO := ret_mo( m1NPR_MO )[ _MO_SHORT_NAME ]
  Endif

  mvto     := inieditspr( A__MENUVERT, arr_NO_YES(), m1vto )

  mvidreab  := inieditspr( A__MENUVERT, type_reabilitacia( m1vto ), m1vidreab )
  mshrm     := inieditspr( A__MENUVERT, type_shrm_reabilitacia( m1vto ), m1shrm )

  mrslt     := inieditspr( A__MENUVERT, list_rslt, m1rslt )
  mishod    := inieditspr( A__MENUVERT, list_ishod, m1ishod )

  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  motd      := inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', m1otd )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf(), m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
  mismo     := init_ismo( m1ismo )
  f_valid_komu(, -1 )
  If m1komu == 0
    m1company := Int( Val( msmo ) )
  Elseif eq_any( m1komu, 1, 3 )
    m1company := m1str_crb
  Endif
  mcompany  := inieditspr( A__MENUVERT, mm_company, m1company )
  If m1company == 34
    If !Empty( mismo )
      mcompany := PadR( mismo, 38 )
    Elseif !Empty( mnameismo )
      mcompany := PadR( mnameismo, 38 )
    Endif
  Endif

  // /---
  str_1 := ' ���� (���� ����)'
  If Loc_kod == 0
    str_1 := '����������' + str_1
    mtip_h := yes_vypisan
  Else
    str_1 := '������஢����' + str_1
  Endif
  pr_1_str( str_1 )
  SetColor( color8 )
  myclear( 1 )

  SetColor( cDataCGet )
  make_diagp( 1 )  // ᤥ���� '��⨧����' ��������

  Do While .t.
    pr_1_str( str_1 )
    j := 1
    myclear( j )
    If yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 Say PadL( '���� ��� � ' + lstr( Loc_kod ), 29 ) Color color14
    Endif

    diag_screen( 0 )
    pos_read := 0

    @ ++j, 1 Say '��०�����' Get mlpu When .f. Color cDataCSay
    @ Row(), Col() + 2 Say '�⤥�����' Get motd When .f. Color cDataCSay
    //
    @ ++j, 1 Say '���' Get mfio_kart ;
      reader {| x| menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
      valid {| g, o| update_get( 'mkomu' ), update_get( 'mcompany' ), ;
      update_get( 'mspolis' ), update_get( 'mnpolis' ), ;
      update_get( 'mvidpolis' ) }
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
      When m1komu == 0 ;
      Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )

    ++j
    @ ++j, 1 Say '���ࠢ�����: ���' Get mnpr_date
    @ j, Col() + 1 Say '�� ��' Get mnpr_mo ;
      reader {| x| menu_reader( x, { {| k, r, c| f_get_mo( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
      Color colget_menu

    @ ++j, 1 Say '�ப� ��祭��' Get mn_data valid {| g| f_k_data( g, 1 ) }
    @ Row(),Col() + 1 Say '-'   Get mk_data valid {| g| f_k_data( g, 2 ) }
    @ Row(), Col() + 3 Get mvzros_reb When .f. Color cDataCSay

    ++j
    @ ++j, 1 Say '� ���.����� (���ਨ)' Get much_doc Picture '@!' ;
      When when_uch_doc

    @ Row(), Col() + 1 Say '���' Get MTAB_NOM Pict '99999' ;
      valid {| g| v_kart_vrach( g, .t. ) } When diag_screen( 2 )
    @ Row(), Col() + 1 Get mvrach When .f. Color color14

    @ ++j, 1 Say '�᭮���� �������' Get mkod_diag Picture pic_diag ;
      reader {| o| mygetreader( o, bg ) } ;
      When when_diag() ;
      valid {|| val1_10diag( .t., .t., .t., mk_data, mpol, .t. ) }

    @ ++j, 1 Say '��䨫� ���.�����' Get mprofil ;
      When .f. Color cDataCSay ;
      valid {|| val1_10diag( .t., .t., .t., mk_data, mpol, .t. ) }

    if Year( mk_data ) >= 2024
      @ ++j, 1 Say '�ᯮ�짮����� ��᮪��孮����筮�� ����㤮�����' Get mvto ;
        reader {| x| menu_reader( x, arr_NO_YES(), A__MENUVERT, , , .f. ) }
    endif

    @ ++j, 1 Say '��� ॠ�����樨' Get mvidreab ;
      reader {| x| menu_reader( x, type_reabilitacia( m1vto ), A__MENUVERT, , , .f. ) }

    @ ++j, 1 Say '����� ��������樮���� ������⨧�樨' Get mshrm ;
      reader {| x| menu_reader( x, type_shrm_reabilitacia( m1vto ), A__MENUVERT, , , .f. ) } ;
      When diag_screen( 2 ) // ���⨬ ᮮ�饭�� � ��������

    @ ++j, 1 Say '������� ���饭��' Get mrslt ;
      reader {| x| menu_reader( x, list_rslt, A__MENUVERT, , , .f. ) } ;
      valid {| g, o| f_valid_rslt( g, o ) }

    @ ++j, 1 Say '��室 �����������' Get mishod ;
      reader {| x| menu_reader( x, list_ishod, A__MENUVERT, , , .f. ) }

    @ MaxRow() -1, 55 Say '�㬬� ��祭��' Color color1
    @ Row(), Col() + 1 Say lput_kop( mcena_1 ) Color color8

    If !Empty( a_smert )
      n_message( a_smert, , 'GR+/R', 'W+/R', , , 'G+/R' )
    Endif

    @ MaxRow(), 0 Say PadC( '<Esc> - ��室;  <PgDn> - ������;  <F1> - ������', MaxCol() + 1 ) Color color0
    mark_keys( { '<F1>', '<Esc>', '<PgDn>' }, 'R/BG' )

    count_edit += myread(, @pos_read )

    k := f_alert( { PadC( '�롥�� ����⢨�', 60, '.' ) }, ;
      { ' ��室 ��� ����� ', ' ������ ', ' ������ � ।���஢���� ' }, ;
      iif( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N,N/BG' )

    If k == 3
      Loop
    Elseif k == 2
      // �஢�ન � ������
      If m1vidreab == 0
        func_error( 4, '�� ��࠭ ��� ॠ�����樨.' )
        Loop
      Endif
      If m1shrm == 0
        func_error( 4, '�� ��࠭� 誠�� ॠ�����樨.' )
        Loop
      Endif
      If Empty( mn_data )
        func_error( 4, '�� ������� ��� ��砫� ��祭��.' )
        Loop
      Endif
      If Empty( mk_data )
        func_error( 4, '�� ������� ��� ����砭�� ��祭��.' )
        Loop
      Endif
      If Empty( mkod_diag )
        func_error( 4, '�� ������ ��� �᭮����� �����������.' )
        Loop
      Endif
      If Empty( CharRepl( '0', much_doc, Space( 10 ) ) )
        func_error( 4, '�� �������� ����� ���㫠�୮� ����� (���ਨ �������)' )
        Loop
      Endif
      If m1komu < 5 .and. Empty( m1company )
        If m1komu == 0     ; s := '���'
        Elseif m1komu == 1 ; s := '��������'
        else               ; s := '������/��'
        Endif
        func_error( 4, '�� ��������� ������������ ' + s )
        Loop
      Endif
      If m1komu == 0 .and. Empty( mnpolis )
        func_error( 4, '�� �������� ����� �����' )
        Loop
      Endif
      err_date_diap( mn_data, '��� ��砫� ��祭��' )
      err_date_diap( mk_data, '��� ����砭�� ��祭��' )
      RestScreen( buf )
      If mem_op_out == 2 .and. yes_parol
        box_shadow( 19, 10, 22, 69, cColorStMsg )
        str_center( 20, '������ "' + fio_polzovat + '".', cColorSt2Msg )
        str_center( 21, '���� ������ �� ' + date_month( sys_date ), cColorStMsg )
      Endif
      mywait( '����. �ந�������� ������ ���� ���� ...' )

      make_diagp( 2 )  // ᤥ���� "��⨧����" ��������
      use_base( 'human' )
      If Loc_kod > 0
        find ( Str( Loc_kod, 7 ) )
        mkod := Loc_kod
        g_rlock( forever )
      Else
        add1rec( 7 )
        mkod := RecNo()
        Replace human->kod With mkod
      Endif
      Select HUMAN_
      Do While human_->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      //
      Select HUMAN_2
      Do While human_2->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )

      If IsBit( mem_oms_pole, 1 )  // "�ப� ��祭��",;  1
        st_N_DATA := MN_DATA
        st_K_DATA := MK_DATA
      Endif
      If IsBit( mem_oms_pole, 2 )  // "���.���",;       2
        st_VRACH := m1vrach
      Endif
      If IsBit( mem_oms_pole, 3 )  // "��.�������",;    3
        SKOD_DIAG := SubStr( MKOD_DIAG, 1, 5 )
      Endif
      If IsBit( mem_oms_pole, 5 )  // "१����",;      5
        st_RSLT := m1rslt
      Endif
      If IsBit( mem_oms_pole, 6 )  // "��室",;          6
        st_ISHOD := m1ishod
      Endif

      glob_perso := mkod
      If m1komu == 0
        msmo := lstr( m1company )
        m1str_crb := 0
      Else
        msmo := ""
        m1str_crb := m1company
      Endif
      //
      human->kod_k      := glob_kartotek
      human->TIP_H      := mtip_h
      human->FIO        := MFIO          // �.�.�. ���쭮��
      human->POL        := MPOL          // ���
      human->DATE_R     := MDATE_R       // ��� ஦����� ���쭮��
      human->VZROS_REB  := M1VZROS_REB   // 0-�����, 1-ॡ����, 2-�����⮪
      human->ADRES      := MADRES        // ���� ���쭮��
      human->MR_DOL     := MMR_DOL       // ���� ࠡ��� ��� ��稭� ���ࠡ�⭮��
      human->RAB_NERAB  := M1RAB_NERAB   // 0-ࠡ���騩, 1-��ࠡ���騩
      human->KOD_DIAG   := MKOD_DIAG     // ��� 1-�� ��.�������
      human->KOMU       := M1KOMU        // �� 0 �� 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis( mspolis, mnpolis ) // ��� � ����� ���客��� �����
      human->LPU        := M1LPU         // ��� ��०�����
      human->OTD        := M1OTD         // ��� �⤥�����
      human->UCH_DOC    := MUCH_DOC      // ��� � ����� ��⭮�� ���㬥��
      human->N_DATA     := MN_DATA       // ��� ��砫� ��祭��
      human->K_DATA     := MK_DATA       // ��� ����砭�� ��祭��
      human->CENA       := MCENA_1       // �⮨����� ��祭��
      human->CENA_1     := MCENA_1       // �⮨����� ��祭��

      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := LTrim( mspolis )
      human_->NPOLIS    := LTrim( mnpolis )
      human_->OKATO     := "" // �� ���� ������� �� ����� � ��砥 �����த����
      human_->USL_OK    := m1USL_OK
      human_->PROFIL    := m1PROFIL
      human_->NPR_MO    := m1NPR_MO
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // 㡥�� "2", �᫨ ��।���஢��� ������ �� ॥��� �� � ��
      human_->ST_VERIFY := 0 // ᭮�� ��� �� �஢�७
      If Loc_kod == 0  // �� ����������
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
      Else // �� ।���஢�����
        human_->kod_p2  := kod_polzovat    // ��� ������
        human_->date_e2 := c4sys_date
      Endif
      human_2->NPR_DATE := mNPR_DATE
      human_2->PC5    := arr2list( { m1vidreab, m1shrm, m1vto }, .t. )

      Private fl_nameismo := .f.
      If m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ����� ��ꥪ� �� ����ਨ ���客����
        If Empty( m1ismo )
          If !Empty( mnameismo )
            fl_nameismo := .t.
          Endif
        Else
          human_->SMO := m1ismo  // �����塞 "34" �� ��� �����த��� ���
        Endif
      Endif
      If fl_nameismo .or. rec_inogSMO > 0
        g_use( dir_server() + 'mo_hismo', , 'SN' )
        Index On Str( kod, 7 ) to ( cur_dir() + 'tmp_ismo' )
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
      write_work_oper( glob_task, OPER_LIST, iif( Loc_kod == 0, 1, 2 ), 1, count_edit )
      fl_write_sluch := .t.
      Close databases
      stat_msg( '������ �����襭�!', .f. )
    Endif
    Exit
  Enddo
  Close databases
  diag_screen( 2 )
  SetColor( tmp_color )
  RestScreen( buf )

  If fl_write_sluch // �᫨ ����ᠫ�
    defenition_usluga_med_reab( mkod, m1vidreab, m1shrm, m1vto )
    If Type( 'fl_edit_oper' ) == 'L' // �᫨ ��室���� � ०��� ���������� ����
      fl_edit_oper := .t.  // �஢��� �����⨬ �� ��室� �� ��������� ���
    Else // ���� ����᪠�� �஢���
      If ( mcena_1 > 0 ) .and. !Empty( Val( msmo ) )
        verify_oms_sluch( glob_perso )
      Endif
    Endif
  Endif

  Return Nil
