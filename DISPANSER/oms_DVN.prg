#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 28.09.24 ��� - ���������� ��� ।���஢���� ���� (���� ���)
Function oms_sluch_dvn( Loc_kod, kod_kartotek, f_print )

  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  // f_print - ������������ �㭪樨 ��� ����
  Static sadiag1  // := {}
  Static st_N_DATA, st_K_DATA, s1dispans := 1
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, arr_del := {}, mrec_hu := 0, ;
    buf := SaveScreen(), tmp_color := SetColor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', arr_usl := {}, ah, ;
    i, j, k, s, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, ar, larr, lu_kod, ;
    fl, tmp_help := chm_help_code, fl_write_sluch := .f., mu_cena, lrslt_1_etap := 0, ;
    sk
  //
  Default st_N_DATA To sys_date, st_K_DATA To sys_date
  Default Loc_kod To 0, kod_kartotek To 0
  //
  Private oms_sluch_DVN := .t., ps1dispans := s1dispans, is_prazdnik
  Private mfio := Space( 50 ), mpol, mdate_r, madres, mvozrast, mdvozrast, ;
    M1VZROS_REB, MVZROS_REB, m1novor := 0, ;
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-���, 1-��������, 3-�������/���, 5-���� ���
    msmo := '34007', rec_inogSMO := 0, ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := Space( 100 ), ;
    mvidpolis, m1vidpolis := 1, mspolis := Space( 10 ), mnpolis := Space( 20 )
  Private mkod := Loc_kod, mtip_h, is_talon := .f., mshifr_zs := '', ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    M1LPU := glob_uch[ 1 ], MLPU, ;
    M1OTD := glob_otd[ 1 ], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MRAB_NERAB, M1RAB_NERAB := 0, ; // 0-ࠡ���騩, 1 -��ࠡ���騩
    mveteran, m1veteran := 0, ;
    mmobilbr, m1mobilbr := 0, ;
    MUCH_DOC    := Space( 10 ), ; // ��� � ����� ��⭮�� ���㬥��
    MKOD_DIAG   := Space( 5 ), ; // ��� 1-�� ��.�������
    MKOD_DIAG2  := Space( 5 ), ; // ��� 2-�� ��.�������
    MKOD_DIAG3  := Space( 5 ), ; // ��� 3-�� ��.�������
    MKOD_DIAG4  := Space( 5 ), ; // ��� 4-�� ��.�������
    MSOPUT_B1   := Space( 5 ), ; // ��� 1-�� ᮯ������饩 �������
    MSOPUT_B2   := Space( 5 ), ; // ��� 2-�� ᮯ������饩 �������
    MSOPUT_B3   := Space( 5 ), ; // ��� 3-�� ᮯ������饩 �������
    MSOPUT_B4   := Space( 5 ), ; // ��� 4-�� ᮯ������饩 �������
    MDIAG_PLUS  := Space( 8 ), ; // ���������� � ���������
    adiag_talon[ 16 ], ; // �� ���⠫��� � ���������
    m1rslt  := 317, ; // १���� (��᢮��� I ��㯯� ���஢��)
    m1ishod := 306, ; // ��室 = �ᬮ��
    MN_DATA := st_N_DATA, ; // ��� ��砫� ��祭��
    MK_DATA := st_K_DATA, ; // ��� ����砭�� ��祭��
    MVRACH := Space( 10 ), ; // 䠬���� � ���樠�� ���饣� ���
    M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
    m1povod  := 4, ;   // ��䨫����᪨�
    m1travma := 0, ;
    m1USL_OK := USL_OK_POLYCLINIC, ; // �����������
    m1VIDPOM :=  1, ; // ��ࢨ筠�
    m1PROFIL := 97, ; // 97-�࠯��, 57-���� ���.�ࠪ⨪� (ᥬ���.���-�), 42-��祡��� ����
    m1IDSP   := 11, ; // ���.��ᯠ��ਧ���
    mcena_1 := 0
  //
  Private arr_usl_dop := {}, arr_usl_otkaz := {}, arr_otklon := {}, m1p_otk := 0
  Private metap := 0, ;  // 1-���� �⠯, 2-��ன �⠯, 3-��䨫��⨪�
    m1ndisp := 3, mndisp, is_dostup_2_year := .f., mnapr_onk := Space( 10 ), m1napr_onk := 0, ;
    mWEIGHT := 0, ;   // ��� � ��
    mHEIGHT := 0, ;   // ��� � �
    mOKR_TALII := 0, ; // ���㦭���� ⠫�� � �
    mtip_mas, m1tip_mas := 0, ;
    mkurenie, m1kurenie := 0, ; //
    mriskalk, m1riskalk := 0, ; //
    mpod_alk, m1pod_alk := 0, ; //
    mpsih_na, m1psih_na := 0, ; //
    mfiz_akt, m1fiz_akt := 0, ; //
    mner_pit, m1ner_pit := 0, ; //
    maddn, m1addn := 0, mad1 := 120, mad2 := 80, ; // ��������
    mholestdn, m1holestdn := 0, mholest := 0, ; // '99.99'
    mglukozadn, m1glukozadn := 0, mglukoza := 0, ; // '99.99'
    mssr := 0, ; // '99'
    mgruppa, m1gruppa := 9      // ��㯯� ���஢��
  Private mot_nasl1, m1ot_nasl1 := 0, mot_nasl2, m1ot_nasl2 := 0, ;
    mot_nasl3, m1ot_nasl3 := 0, mot_nasl4, m1ot_nasl4 := 0
  Private mdispans, m1dispans := 0, mnazn_l, m1nazn_l  := 0, ;
    mdopo_na, m1dopo_na := 0, mssh_na, m1ssh_na  := 0, ;
    mspec_na, m1spec_na := 0, msank_na, m1sank_na := 0
  Private mvar, m1var
  Private mm_ndisp := { ;
    { '��ᯠ��ਧ��� I  �⠯', 1 }, ;
    { '��ᯠ��ਧ��� II �⠯', 2 }, ;
    { '��䨫����᪨� �ᬮ��', 3 }, ;
    { '���.1�⠯(ࠧ � 2����)', 4 }, ;
    { '���.2�⠯(ࠧ � 2����)', 5 } }
  Private mm_gruppa, mm_ndisp1, is_disp_19 := .t., ;
    is_disp_21 := .t., is_disp_nabl := .f.
//      is_disp_24 := .t.

  Private mnapr_v_mo, m1napr_v_mo := 0, mm_napr_v_mo := arr_mm_napr_v_mo(), ;
    arr_mo_spec := {}, ma_mo_spec, m1a_mo_spec := 1
  Private mnapr_stac, m1napr_stac := 0, ;
    mm_napr_stac := arr_mm_napr_stac(), ;
    mprofil_stac, m1profil_stac := 0
  Private mnapr_reab, m1napr_reab := 0, mprofil_kojki, m1profil_kojki := 0
  
  Private mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0
  
  Private m1NAPR_MO, mNAPR_MO, mNAPR_DATE, mNAPR_V, m1NAPR_V, mMET_ISSL, m1MET_ISSL, ;
    mshifr, mshifr1, mname_u, mU_KOD, cur_napr := 0, count_napr := 0, tip_onko_napr := 0, ;
    mTab_Number := 0
  
  Private mm_napr_v := { { '���', 0 }, ;
    { '� ��������', 1 }, ;
    { '�� ����᫥�������', 3 } }
    /*Private mm_napr_v := {{'���', 0}, ;
                          {'� ��������', 1}, ;
                          {'�� ������', 2}, ;
                          {'�� ����᫥�������', 3}, ;
                          {'��� ��।���� ⠪⨪� ��祭��', 4}}*/
  Private mm_met_issl := { { '���', 0 }, ;
    { '������ୠ� �������⨪�', 1 }, ;
    { '�����㬥�⠫쭠� �������⨪�', 2 }, ;
    { '��⮤� ��祢�� �������⨪� (����ண����騥)', 3 }, ;
    { '��ண����騥 ��⮤� ��祢�� �������⨪�', 4 } }
  //
  Private pole_diag, pole_pervich, pole_1pervich, pole_d_diag, ;
    pole_stadia, pole_dispans, pole_1dispans, pole_d_dispans, pole_dn_dispans
      
  Private mm_pervich := arr_mm_pervich()
  Private mm_dispans := arr_mm_dispans()
  Private mDS_ONK, m1DS_ONK := 0 // �ਧ��� �����७�� �� �������⢥���� ������ࠧ������
  Private mm_dopo_na := arr_mm_dopo_na()
  Private gl_arr := { ;  // ��� ��⮢�� �����
    { 'dopo_na', 'N', 10, 0, , , , {| x | inieditspr( A__MENUBIT, mm_dopo_na, x ) } };
  }

  Private mm_gruppaP := arr_mm_gruppap()
  Private mm_gruppaP_old := AClone( mm_gruppaP )
  ASize( mm_gruppaP_old, 3 )
  Private mm_gruppaP_new := AClone( mm_gruppaP )
  hb_ADel( mm_gruppaP_new, 3, .t. )
  Private mm_gruppaD1 := { ;
    { '�஢����� ��ᯠ��ਧ��� - ��᢮��� I ��㯯� ���஢��', 1, 317 }, ;
    { '�஢����� ��ᯠ��ਧ��� - ��᢮��� II ��㯯� ���஢��', 2, 318 }, ;
    { '�஢����� ��ᯠ��ਧ��� - ��᢮��� III� ��㯯� ���஢��', 3, 355 }, ;
    { '�஢����� ��ᯠ��ਧ��� - ��᢮��� III� ��㯯� ���஢��', 4, 356 }, ;
    { '���ࠢ��� �� 2 �⠯, �।���⥫쭮 ��᢮��� I ��㯯� ���஢��', 11, 352 }, ;
    { '���ࠢ��� �� 2 �⠯, �।���⥫쭮 ��᢮��� II ��㯯� ���஢��', 12, 353 }, ;
    { '���ࠢ��� �� 2 �⠯, �।���⥫쭮 ��᢮��� III� ��㯯� ���஢��', 13, 357 }, ;
    { '���ࠢ��� �� 2 �⠯, �।���⥫쭮 ��᢮��� III� ��㯯� ���஢��', 14, 358 }, ;
    { '���ࠢ��� �� 2 �⠯ � ���������, ��᢮��� I ��㯯� ���஢��', 21, 352 }, ;
    { '���ࠢ��� �� 2 �⠯ � ���������, ��᢮��� II ��㯯� ���஢��', 22, 353 }, ;
    { '���ࠢ��� �� 2 �⠯ � ���������, ��᢮��� III� ��㯯� ���஢��', 23, 357 }, ;
    { '���ࠢ��� �� 2 �⠯ � ���������, ��᢮��� III� ��㯯� ���஢��', 24, 358 } }
  Private mm_gruppaD2 := AClone( mm_gruppaD1 )
  ASize( mm_gruppaD2, 4 )
  Private mm_gruppaD4 := AClone( mm_gruppaD1 )
  ASize( mm_gruppaD4, 8 )
  Private mm_otkaz := arr_mm_otkaz()
  Private mm_otkaz1 := AClone( mm_otkaz )
  ASize( mm_otkaz1, 3 )
  Private mm_otkaz0 := AClone( mm_otkaz )
  ASize( mm_otkaz0, 2 )
      
//  If kod_kartotek == 0 // ���������� � ����⥪�
  If kod_kartotek >= 0 // ࠡ�⠥� �� ����⥪�
    If kod_kartotek == 0 // ���������� � ����⥪�
      If ( kod_kartotek := edit_kartotek( 0, , , .t. ) ) == 0
        Return Nil
      Endif
    endif
    mkod_k := kod_kartotek
    r_use( dir_server + 'kartotek', , 'KART' )
    Goto ( mkod_k )
    mpol        := kart->pol
    mdate_r     := kart->date_r
    kart->( dbCloseArea() )
  Elseif Loc_kod > 0
    r_use( dir_server + 'human', , 'HUMAN' )
    Goto ( Loc_kod )
    mpol    := human->pol
    mdate_r := human->date_r
    MN_DATA := human->N_DATA
    fl := ( Year( human->k_data ) < 2018 )
    Use
    If fl
      Return func_error( 4, '�� ��砩 ��ᯠ��ਧ�樨 ࠭�� 2018 ����' )
    Endif
  Endif

  fv_date_r( iif( Loc_kod > 0, MN_DATA, ) )

  // if empty(sadiag1)
  // Private file_form, diag1 := {}, len_diag := 0
  // if (file_form := search_file('DISP_NAB' + sfrm)) == NIL
  // func_error(4, '�� �����㦥� 䠩� DISP_NAB' + sfrm)
  // endif
  // f2_vvod_disp_nabl('A00')
  // sadiag1 := diag1
  // endif
  If ISNIL( sadiag1 )
    sadiag1 := load_diagnoze_disp_nabl_from_file()
  Endif

  chm_help_code := 3002

  mm_ndisp1 := AClone( mm_ndisp )
    // ��⠢�塞 3-�� � 4-� �⠯�
  ASize( mm_ndisp1, 4 )
  hb_ADel( mm_ndisp1, 1, .t. )
  hb_ADel( mm_ndisp1, 1, .t. )

  arr := {} // ���ᨢ ��� ���ࠢ�����

  For i := 1 To 5
    sk := lstr( i )
    pole_diag := 'mdiag' + sk
    pole_d_diag := 'mddiag' + sk
    pole_pervich := 'mpervich' + sk
    pole_1pervich := 'm1pervich' + sk
    pole_stadia := 'm1stadia' + sk
    pole_dispans := 'mdispans' + sk
    pole_1dispans := 'm1dispans' + sk
    pole_d_dispans := 'mddispans' + sk
    pole_dn_dispans := 'mdndispans' + sk
    Private &pole_diag := Space( 6 )
    Private &pole_d_diag := CToD( '' )
    Private &pole_pervich := Space( 7 )
    Private &pole_1pervich := 0
    Private &pole_stadia := 1
    Private &pole_dispans := Space( 10 )
    Private &pole_1dispans := 0
    Private &pole_d_dispans := CToD( '' )
    Private &pole_dn_dispans := CToD( '' )
  Next
  Private mg_cit := '', m1g_cit := 0, m1lis := 0, mm_g_cit := { ;
    { '� ��-���筮� ���-� �⮫�����.���ਠ��', 1 }, ;
    { '� �����-������⭮� ���-�� ��.���ਠ��', 2 } }
  // for i := 1 to 33 //count_dvn_arr_usl 19.10.21
  For i := 1 To 34 // count_dvn_arr_usl 08.09.24
    mvar := 'MTAB_NOMv' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMa' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATE' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MKOD_DIAG' + lstr( i )
    Private &mvar := Space( 6 )
    mvar := 'MOTKAZ' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := 'M1OTKAZ' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
    m1var := 'M1LIS' + lstr( i )
    Private &m1var := 0
    mvar := 'MLIS' + lstr( i )
    Private &mvar := inieditspr( A__MENUVERT, mm_kdp2, &m1var )
  Next
  //
  AFill( adiag_talon, 0 )
  r_use( dir_server + 'human_2', , 'HUMAN_2' )
  r_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  If mkod_k > 0
    r_use( dir_server + 'kartote2', , 'KART2' )
    Goto ( mkod_k )
    r_use( dir_server + 'kartote_', , 'KART_' )
    Goto ( mkod_k )
    r_use( dir_server + 'kartotek', , 'KART' )
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
    m1MO_PR     := kart2->MO_PR
    If kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    Endif
    If eq_any( is_uchastok, 1, 3 )
      MUCH_DOC := PadR( amb_kartan(), 10 )
    Elseif mem_kodkrt == 2
      MUCH_DOC := PadR( lstr( mkod_k ), 10 )
    Endif
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 1, , .t. ) // ������ � �������
    Endif
    // �஢�ઠ ��室� = ������
    ah := {}
    Select HUMAN
    Set Index to ( dir_server + 'humankk' )
    find ( Str( mkod_k, 7 ) )
    Do While human->kod_k == mkod_k .and. !Eof()
      If human_->oplata != 9 .and. human_->NOVOR == 0 .and. RecNo() != Loc_kod
        If is_death( human_->RSLT_NEW ) .and. Empty( a_smert )
          a_smert := { '����� ���쭮� 㬥�!', ;
            '��祭�� � ' + full_date( human->N_DATA ) + ' �� ' + full_date( human->K_DATA ) }
        Endif
        If Between( human->ishod, 201, 205 )
          AAdd( ah, { human->( RecNo() ), human->K_DATA } )
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    Set Index To
    If Len( ah ) > 0
      ASort( ah, , , {| x, y | x[ 2 ] < y[ 2 ] } )
      Select HUMAN
      Goto ( ATail( ah )[ 1 ] )
      M1RAB_NERAB := human->RAB_NERAB // 0-ࠡ���騩, 1-��ࠡ���騩, 2-������.����
      letap := human->ishod -200
      If eq_any( letap, 1, 4 )
        lrslt_1_etap := human_->RSLT_NEW
      Endif
      read_arr_dvn( human->kod, .f. )
    Endif
  Endif
  If Empty( mWEIGHT )
    mWEIGHT := iif( mpol == '�', 70, 55 )   // ��� � ��
  Endif
  If Empty( mHEIGHT )
    mHEIGHT := iif( mpol == '�', 170, 160 )  // ��� � �
  Endif
  If Empty( mOKR_TALII )
    mOKR_TALII := iif( mpol == '�', 94, 80 ) // ���㦭���� ⠫�� � �
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
    M1RAB_NERAB := human->RAB_NERAB     // 0-ࠡ���騩, 1-��ࠡ���騩, 2-������.����
    mUCH_DOC    := human->uch_doc
    m1VRACH     := human_->vrach
    /*MKOD_DIAG0  := human_->KOD_DIAG0
    MKOD_DIAG   := human->KOD_DIAG
    MKOD_DIAG2  := human->KOD_DIAG2
    MKOD_DIAG3  := human->KOD_DIAG3
    MKOD_DIAG4  := human->KOD_DIAG4
    MSOPUT_B1   := human->SOPUT_B1
    MSOPUT_B2   := human->SOPUT_B2
    MSOPUT_B3   := human->SOPUT_B3
    MSOPUT_B4   := human->SOPUT_B4
    MDIAG_PLUS  := human->DIAG_PLUS
    for i := 1 to 16
      adiag_talon[i] := int(val(substr(human_->DISPANS,i, 1)))
    next*/
    MPOLIS      := human->POLIS         // ��� � ����� ���客��� �����
    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    If human->OBRASHEN == '1'
      m1DS_ONK := 1
    Endif
    If Empty( Val( msmo := human_->SMO ) )
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    Else
      m1komu := m1str_crb := 0
    Endif
    m1okato    := human_->OKATO  // ����� ��ꥪ� �� ����ਨ ���客����
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    mcena_1    := human->CENA_1
    m1rslt     := human_->RSLT_NEW
    //
    is_prazdnik := f_is_prazdnik_dvn( mn_data )
    is_disp_19 := !( mk_data < 0d20190501 )
    //
    is_disp_21 := !( mk_data < 0d20210101 )
    //
//    is_disp_24 := !( mk_data < 0d20240901 )
    //
    ret_arr_vozrast_dvn( mk_data )
    // / !!!!
//    ret_arrays_disp( is_disp_19, is_disp_21, is_disp_24 )
    ret_arrays_disp( mk_data )
    metap := human->ishod - 200
    If is_disp_19
      mdvozrast := Year( mn_data ) - Year( mdate_r )
      // �᫨ �� ���ᬮ��
      If metap == 3 .and. AScan( ret_arr_vozrast_dvn( mk_data ), mdvozrast ) > 0 // � ������ ��ᯠ��ਧ�樨
        metap := 1 // �ॢ�頥� � ��ᯠ��ਧ���
        If mk_data < 0d20191101 .and. m1rslt == 345
          m1rslt := 355
        Elseif mk_data >= 0d20191101 .and. m1rslt == 373
          m1rslt := 355
        Elseif mk_data >= 0d20191101 .and. m1rslt == 374
          m1rslt := 356
        Elseif m1rslt == 344
          m1rslt := 318
        Else
          m1rslt := 317
        Endif
      Endif
      If metap == 4
        func_error( 4, '�� ��ᯠ��ਧ��� ࠧ � 2 ���� - �८�ࠧ㥬 � ������ ��ᯠ��ਧ���' )
        metap := 1
      Elseif metap == 5
        func_error( 4, '�� ��ன �⠯ ��ᯠ��ਧ�樨 ࠧ � 2 ���� - 㤠��� ��� ��砩!' )
        Close databases
        Return Nil
      Endif
    Endif
    If Between( metap, 1, 5 )
      mm_gruppa := { mm_gruppaD1, mm_gruppaD2, mm_gruppaP, mm_gruppaD4, mm_gruppaD2 }[ metap ]
      If ( i := AScan( mm_gruppa, {| x | x[ 3 ] == m1rslt } ) ) > 0
        m1GRUPPA := mm_gruppa[ i, 2 ]
      Endif
    Endif
    //
    fl_4_1_12 := .f.
    larr := Array( 2, count_dvn_arr_usl )
    afillall( larr, 0 )
    r_use( dir_server + 'uslugi', , 'USL' )
    use_base( 'human_u' )
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
        lshifr := usl->shifr
      Endif
      lshifr := AllTrim( lshifr )
      If eq_any( Left( lshifr, 5 ), '70.3.', '70.7.', '72.1.', '72.5.', '72.6.', '72.7.' )
        mshifr_zs := lshifr
      Else
        fl := .t.
        If is_disp_19
          //
        Else
          If lshifr == '2.3.3' .and. hu_->PROFIL == 3  ; // �����᪮�� ����
            .and. ( i := AScan( dvn_arr_usl, {| x | ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == '4.1.12' } ) ) > 0
            fl_4_1_12 := .t.
            fl := .f.
            larr[ 1, i ] := hu->( RecNo() )
          Endif
        Endif
        If fl
          For i := 1 To count_dvn_arr_umolch
            If Empty( larr[ 2, i ] ) .and. dvn_arr_umolch[ i, 2 ] == lshifr
              fl := .f.
              larr[ 2, i ] := hu->( RecNo() )
              Exit
            Endif
          Next
        Endif
        If fl
          For i := 1 To count_dvn_arr_usl
            If Empty( larr[ 1, i ] )
              If ValType( dvn_arr_usl[ i, 2 ] ) == 'C'
                If dvn_arr_usl[ i, 2 ] == '4.20.1'
                  If lshifr == '4.20.1'
                    m1g_cit := 1
                  Elseif lshifr == '4.20.2'
                    m1g_cit := 2
                    fl := .f.
                  Endif
                Endif
                If dvn_arr_usl[ i, 2 ] == lshifr
                  fl := .f.
                  m1var := 'm1lis' + lstr( i )
                  If is_disp_19
                    &m1var := 0
                  Elseif glob_yes_kdp2[ TIP_LU_DVN ] .and. AScan( glob_arr_usl_LIS, dvn_arr_usl[ i, 2 ] ) > 0 .and. hu->is_edit > 0
                    &m1var := hu->is_edit
                  Endif
                  mvar := 'mlis' + lstr( i )
                  &mvar := inieditspr( A__MENUVERT, mm_kdp2, &m1var )
                Endif
              Endif
              If fl .and. Len( dvn_arr_usl[ i ] ) > 11 .and. ValType( dvn_arr_usl[ i, 12 ] ) == 'A'
                If AScan( dvn_arr_usl[ i, 12 ], {| x | x[ 1 ] == lshifr .and. x[ 2 ] == hu_->PROFIL } ) > 0
                  fl := .f.
                Endif
              Endif
              If !fl
                larr[ 1, i ] := hu->( RecNo() )
                Exit
              Endif
            Endif
          Next
        Endif
        If fl .and. AScan( dvn_700, {| x | x[ 2 ] == lshifr } ) > 0
          fl := .f. // � �㫥��� ��㣥 ��������� ��㣠 � 業�� �� '700'
        Endif
        If fl
          n_message( { '�����४⭠� ����ன�� � �ࠢ�筨�� ���:', ;
            AllTrim( usl->name ), ;
            '��� ��㣨 � �ࠢ�筨�� ' + usl->shifr, ;
            '��� ����� - ' + opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) }, , ;
            'GR+/R', 'W+/R', , , 'G+/R' )
        Endif
      Endif
      AAdd( arr_usl, hu->( RecNo() ) )
      Select HU
      Skip
    Enddo
    r_use( dir_server + 'mo_pers', , 'P2' )
    read_arr_dvn( Loc_kod )
    If metap == 1 .and. Between( m1GRUPPA, 11, 14 ) .and. m1p_otk == 1
      m1GRUPPA += 10
    Endif
    // R_Use(dir_server + 'mo_pers',,'P2')
    For i := 1 To count_dvn_arr_usl
      If !Empty( larr[ 1, i ] )
        hu->( dbGoto( larr[ 1, i ] ) )
        If hu->kod_vr > 0
          p2->( dbGoto( hu->kod_vr ) )
          mvar := 'MTAB_NOMv' + lstr( i )
          &mvar := p2->tab_nom
        Endif
        If hu->kod_as > 0
          p2->( dbGoto( hu->kod_as ) )
          mvar := 'MTAB_NOMa' + lstr( i )
          &mvar := p2->tab_nom
        Endif
        mvar := 'MDATE' + lstr( i )
        &mvar := c4tod( hu->date_u )
        If !Empty( hu_->kod_diag ) .and. !( Left( hu_->kod_diag, 1 ) == 'Z' )
          mvar := 'MKOD_DIAG' + lstr( i )
          &mvar := hu_->kod_diag
        Endif
        m1var := 'M1OTKAZ' + lstr( i )
        &m1var := 0 // �믮�����
        If ValType( dvn_arr_usl[ i, 2 ] ) == 'C'
          If AScan( arr_otklon, dvn_arr_usl[ i, 2 ] ) > 0
            &m1var := 3 // �믮�����, �����㦥�� �⪫������
          Elseif dvn_arr_usl[ i, 2 ] == '2.3.1' .and. AScan( arr_otklon, '2.3.3' ) > 0
            &m1var := 3 // �믮�����, �����㦥�� �⪫������
          Elseif dvn_arr_usl[ i, 2 ] == '4.20.1' .and. m1g_cit == 2 .and. AScan( arr_otklon, '4.20.2' ) > 0
            &m1var := 3 // �믮�����, �����㦥�� �⪫������
          Elseif fl_4_1_12 .and. dvn_arr_usl[ i, 2 ] == '4.1.12'
            &m1var := 2 // �������������
          Endif
        Endif
        mvar := 'MOTKAZ' + lstr( i )
        &mvar := inieditspr( A__MENUVERT, mm_otkaz, &m1var )
      Endif
    Next
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 2, @rec_inogSMO, .t. ) // ������ � �������
    Endif
    If ValType( arr_usl_otkaz ) == 'A'
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) >= 5 .and. ValType( ar[ 5 ] ) == 'C'
          lshifr := AllTrim( ar[ 5 ] )
          For i := 1 To count_dvn_arr_usl
            If ValType( dvn_arr_usl[ i, 2 ] ) == 'C' .and. ;
                ( dvn_arr_usl[ i, 2 ] == lshifr .or. ( Len( dvn_arr_usl[ i ] ) > 11 .and. ValType( dvn_arr_usl[ i, 12 ] ) == 'A' ;
                .and. AScan( dvn_arr_usl[ i, 12 ], {| x | x[ 1 ] == lshifr } ) > 0 ) )
              If ValType( ar[ 1 ] ) == 'N' .and. ar[ 1 ] > 0
                p2->( dbGoto( ar[ 1 ] ) )
                mvar := 'MTAB_NOMv' + lstr( i )
                &mvar := p2->tab_nom
              Endif
              If ValType( ar[ 3 ] ) == 'N' .and. ar[ 3 ] > 0
                p2->( dbGoto( ar[ 3 ] ) )
                mvar := 'MTAB_NOMa' + lstr( i )
                &mvar := p2->tab_nom
              Endif
              mvar := 'MDATE' + lstr( i )
              &mvar := mn_data
              If Len( ar ) >= 9 .and. ValType( ar[ 9 ] ) == 'D'
                &mvar := ar[ 9 ]
              Endif
              m1var := 'M1OTKAZ' + lstr( i )
              &m1var := 1
              If Len( ar ) >= 10 .and. ValType( ar[ 10 ] ) == 'N' .and. Between( ar[ 10 ], 1, 2 )
                &m1var := ar[ 10 ]
              Endif
              mvar := 'MOTKAZ' + lstr( i )
              &mvar := inieditspr( A__MENUVERT, mm_otkaz, &m1var )
            Endif
          Next i
        Endif
      Next j
    Endif
    // ᮡ�ࠥ� ���������᪨� ���ࠢ�����
    dbCreate( cur_dir + 'tmp_onkna', create_struct_temporary_onkna() )
    cur_napr := 1 // �� ।-�� - ᭠砫� ��ࢮ� ���ࠢ����� ⥪�饥
    count_napr := collect_napr_zno( Loc_kod )
    If count_napr > 0
      mnapr_onk := '������⢮ ���ࠢ����� - ' + lstr( count_napr )
    Endif
    For i := 1 To 5
      f_valid_diag_oms_sluch_dvn( , i )
    Next i
  Endif
  If !( Left( msmo, 2 ) == '34' ) // �� ������ࠤ᪠� �������
    m1ismo := msmo
    msmo := '34'
  Endif
  is_talon := .t.
  Close databases
  fv_date_r( iif( Loc_kod > 0, mn_data, ) )
  MFIO_KART := _f_fio_kart()
  mndisp    := inieditspr( A__MENUVERT, mm_ndisp, metap )
  mrab_nerab := inieditspr( A__MENUVERT, menu_rab, m1rab_nerab )
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  mlpu      := inieditspr( A__POPUPMENU, dir_server + 'mo_uch', m1lpu )
  motd      := inieditspr( A__POPUPMENU, dir_server + 'mo_otd', m1otd )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
  mismo     := init_ismo( m1ismo )
  f_valid_komu(, -1 )
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
  mveteran := inieditspr( A__MENUVERT, mm_danet, m1veteran )
  mmobilbr := inieditspr( A__MENUVERT, mm_danet, m1mobilbr )
  mkurenie := inieditspr( A__MENUVERT, mm_danet, m1kurenie )
  mriskalk := inieditspr( A__MENUVERT, mm_danet, m1riskalk )
  mpod_alk := inieditspr( A__MENUVERT, mm_danet, m1pod_alk )
  If emptyall( m1riskalk, m1pod_alk )
    m1psih_na := 0
  Endif
  mpsih_na := inieditspr( A__MENUVERT, mm_danet, m1psih_na )
  mfiz_akt := inieditspr( A__MENUVERT, mm_danet, m1fiz_akt )
  mner_pit := inieditspr( A__MENUVERT, mm_danet, m1ner_pit )
  maddn    := inieditspr( A__MENUVERT, mm_danet, m1addn )
  mholestdn := inieditspr( A__MENUVERT, mm_danet, m1holestdn )
  mglukozadn := inieditspr( A__MENUVERT, mm_danet, m1glukozadn )
  mot_nasl1 := inieditspr( A__MENUVERT, mm_danet, m1ot_nasl1 )
  mot_nasl2 := inieditspr( A__MENUVERT, mm_danet, m1ot_nasl2 )
  mot_nasl3 := inieditspr( A__MENUVERT, mm_danet, m1ot_nasl3 )
  mot_nasl4 := inieditspr( A__MENUVERT, mm_danet, m1ot_nasl4 )
  mdispans  := inieditspr( A__MENUVERT, mm_dispans, m1dispans )
  mDS_ONK   := inieditspr( A__MENUVERT, mm_danet, M1DS_ONK )
  mnazn_l   := inieditspr( A__MENUVERT, mm_danet, m1nazn_l )
  mdopo_na  := inieditspr( A__MENUBIT, mm_dopo_na, m1dopo_na )
  mnapr_v_mo := inieditspr( A__MENUVERT, mm_napr_v_mo, m1napr_v_mo )
  If Empty( arr_mo_spec )
    ma_mo_spec := '---'
  Else
    ma_mo_spec := ''
    For i := 1 To Len( arr_mo_spec )
      ma_mo_spec += lstr( arr_mo_spec[ i ] ) + ','
    Next
    ma_mo_spec := Left( ma_mo_spec, Len( ma_mo_spec ) -1 )
  Endif
  mnapr_stac := inieditspr( A__MENUVERT, mm_napr_stac, m1napr_stac )
  mprofil_stac := inieditspr( A__MENUVERT, getv002(), m1profil_stac )
  mnapr_reab := inieditspr( A__MENUVERT, mm_danet, m1napr_reab )
  mprofil_kojki := inieditspr( A__MENUVERT, getv020(), m1profil_kojki )
  mssh_na   := inieditspr( A__MENUVERT, mm_danet, m1ssh_na )
  mspec_na  := inieditspr( A__MENUVERT, mm_danet, m1spec_na )
  msank_na  := inieditspr( A__MENUVERT, mm_danet, m1sank_na )
  mtip_mas := ret_tip_mas( mWEIGHT, mHEIGHT, @m1tip_mas )
  ret_ndisp( Loc_kod, kod_kartotek )
  //
  If !Empty( f_print )
    return &( f_print + '(' + lstr( Loc_kod ) + ',' + lstr( kod_kartotek ) + ')' )
  Endif
  //
  str_1 := ' ���� ��ᯠ��ਧ�樨/���ᬮ�� ���᫮�� ��ᥫ����'
  If Loc_kod == 0
    str_1 := '����������' + str_1
    mtip_h := yes_vypisan
  Else
    str_1 := '������஢����' + str_1
  Endif
  SetColor( color8 )
  Private gl_area
  SetColor( cDataCGet )
  make_diagp( 1 )  // ᤥ���� '��⨧����' ��������
  Private num_screen := 1
  Do While .t.
    Close databases
    DispBegin()
    If metap == 2 .and. num_screen == 2
      hS := 30
      wS := 80
    Elseif num_screen == 3
      hS := 26
      wS := 85
    Else
      hS := 25
      wS := 80
    Endif
    SetMode( hS, wS )
    @ 0, 0 Say PadC( str_1, wS ) Color 'B/BG*'
    gl_area := { 1, 0, MaxRow() -1, MaxCol(), 0 }
    j := 1
    myclear( j )
    If yes_num_lu == 1 .and. Loc_kod > 0
      @ j, ( wS -30 ) Say PadL( '���� ��� � ' + lstr( Loc_kod ), 29 ) Color color14
    Endif
    @ j, 0 Say '��࠭ ' + lstr( num_screen ) Color color8
    If num_screen > 1
      s := AllTrim( mfio ) + ' (' + lstr( mvozrast ) + ' ' + s_let( mvozrast ) + ')'
      @ j, wS - Len( s ) Say s Color color14
    Endif
    If num_screen == 1 // 
      @ ++j, 1 Say '���' Get mfio_kart ;
        reader {| x | menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
        valid {| g, o | update_get( 'mdate_r' ), ;
        update_get( 'mkomu' ), update_get( 'mcompany' ) }
      @ Row(), Col() + 5 Say '�.�.' Get mdate_r When .f. Color color14
      @ ++j, 1 Say ' ������騩?' Get mrab_nerab ;
        reader {| x | menu_reader( x, menu_rab, A__MENUVERT, , , .f. ) }
      @ j, 40 Say '���࠭ ��� (���������)?' Get mveteran ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say ' �ਭ���������� ����' Get mkomu ;
        reader {| x | menu_reader( x, mm_komu, A__MENUVERT, , , .f. ) } ;
        valid {| g, o | f_valid_komu( g, o ) } ;
        Color colget_menu
      @ Row(), Col() + 1 Say '==>' Get mcompany ;
        reader {| x | menu_reader( x, mm_company, A__MENUVERT, , , .f. ) } ;
        When m1komu < 5 ;
        valid {| g | func_valid_ismo( g, m1komu, 38 ) }
      @ ++j, 1 Say ' ����� ���: ���' Get mspolis When m1komu == 0
      @ Row(), Col() + 3 Say '�����'  Get mnpolis When m1komu == 0
      @ Row(), Col() + 3 Say '���'    Get mvidpolis ;
        reader {| x | menu_reader( x, mm_vid_polis, A__MENUVERT, , , .f. ) } ;
        When m1komu == 0 ;
        Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
      //
      @ ++j, 1 Say '�ப�' Get mn_data ;
        valid {| g | f_k_data( g, 1 ), ;
        iif( mvozrast < 18, func_error( 4, '�� �� ����� ��樥��!' ), nil ), ;
        ret_ndisp( Loc_kod, kod_kartotek ) ;
        }
      @ Row(), Col() + 1 Say '-' Get mk_data ;
        valid {| g | f_k_data( g, 2 ), ;
        ret_ndisp( Loc_kod, kod_kartotek ) ;
        }
      If eq_any( metap, 3, 4 ) .and. is_dostup_2_year
        @ Row(), Col() + 7 Get mndisp /*color color14*/ reader { | x | menu_reader(x, mm_ndisp1, A__MENUVERT, , , .f. ) } ;
        valid {|| metap := m1ndisp, .t. }
      Else
        @ Row(), Col() + 7 Get mndisp When .f. Color color14
      Endif
      @ ++j, 1 Say '� ���㫠�୮� �����' Get much_doc Picture '@!' ;
        When !( is_uchastok == 1 .and. is_task( X_REGIST ) ) .or. mem_edit_ist == 2
      @ j,Col() + 5 Say '�����쭠� �ਣ���?' Get mmobilbr ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      ++j
      @ ++j, 1 Say '��७��/㯮�ॡ����� ⠡���' Get mkurenie ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '��� ���㡭��� ���ॡ����� �������� (㯮�ॡ����� ��������)' Get mriskalk ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '��� ���ॡ����� ��મ��᪨�/����ய��� ����� ��� �����祭�� ���' Get mpod_alk ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '������ 䨧��᪠� ��⨢����� (������⮪ 䨧��᪮� ��⨢����)' Get mfiz_akt ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '���樮���쭮� ��⠭�� (���ਥ������ ����/�।�� �ਢ�窨 ��⠭��)' Get mner_pit ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '���񭭠� ��᫥��⢥������: �� �������⢥��� ������ࠧ������' Get mot_nasl1 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '                            - �� �थ筮-��㤨��� �����������' Get mot_nasl2 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '               - �� �஭��᪨� ������� ������ ���⥫��� ��⥩' Get mot_nasl3 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '                                           - �� ��୮�� �������' Get mot_nasl4 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      ++j
      @ ++j, 1 Say '���' Get mWEIGHT Pict '999' ;
        valid {|| iif( Between( mWEIGHT, 30, 200 ), , func_error( 4, '��ࠧ㬭� ���' ) ), ;
        mtip_mas := ret_tip_mas( mWEIGHT, mHEIGHT ), ;
        update_get( 'mtip_mas' ) }
      @ Row(), Col() + 1 Say '��, ���' Get mHEIGHT Pict '999' ;
        valid {|| iif( Between( mHEIGHT, 40, 250 ), , func_error( 4, '��ࠧ㬭� ���' ) ), ;
        mtip_mas := ret_tip_mas( mWEIGHT, mHEIGHT ), ;
        update_get( 'mtip_mas' ) }
      @ Row(), Col() + 1 Say '�, ���㦭���� ⠫��' Get mOKR_TALII  Pict '999' ;
        valid {|| iif( Between( mOKR_TALII, 40, 200 ), , func_error( 4, '��ࠧ㬭�� ���祭�� ���㦭��� ⠫��' ) ), .t. }
      @ Row(), Col() + 1 Say '�'
      @ Row(), Col() + 5 Get mtip_mas Color color14 When .f.
      @ ++j, 1 Say ' ���ਠ�쭮� ��������' Get mad1 Pict '999' ;
        valid {|| iif( Between( mad1, 60, 220 ), , func_error( 4, '��ࠧ㬭�� ��������' ) ), .t. }
      @ Row(), Col() Say '/' Get mad2 Pict '999';
        valid {|| iif( Between( mad1, 40, 180 ), , func_error( 4, '��ࠧ㬭�� ��������' ) ), ;
        iif( mad1 > mad2, , func_error( 4, '��ࠧ㬭�� ��������' ) ), ;
        .t. }
      @ Row(), Col() + 1 Say '�� ��.��.    ����⥭������ �࠯��' Get maddn ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say ' ��騩 宫���ਭ' Get mholest Pict '99.99' ;
        valid {|| iif( Empty( mholest ) .or. Between( mholest, 3, 8 ), , func_error( 4, '��ࠧ㬭�� ���祭�� 宫���ਭ�' ) ), .t. }
      @ Row(), Col() + 1 Say '�����/�     �������������᪠� �࠯��' Get mholestdn ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say ' ����' Get mglukoza Pict '99.99' ;
        valid {|| iif( Empty( mglukoza ) .or. Between( mglukoza, 2.2, 25 ), , func_error( 4, '����᪮� ���祭�� ����' ) ), .t. }
      @ Row(), Col() + 1 Say '�����/�     ������������᪠� �࠯��' Get mglukozadn ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      status_key( '^<Esc>^ ��室 ��� ����� ^<PgDn>^ �� 2-� ��࠭���' )
      If !Empty( a_smert )
        n_message( a_smert, , 'GR+/R', 'W+/R', , , 'G+/R' )
      Endif
    Elseif num_screen == 2 // 
      ret_ndisp( Loc_kod, kod_kartotek )
      @ ++j, 8 Get mndisp When .f. Color color14
      If mvozrast != mdvozrast
        If m1veteran == 1
          s := '(��� ���࠭� �஢������ �� ������� ' + lstr( mdvozrast ) + ' ' + s_let( mdvozrast ) + ')'
        Else
          s := '(� ' + lstr( Year( mn_data ) ) + ' ���� �ᯮ������ ' + lstr( mdvozrast ) + ' ' + s_let( mdvozrast ) + ')'
        Endif
        @ j, 80 - Len( s ) Say s Color color14
      Endif
      @ ++j, 1 Say '������������������������������������������������������������������������������' Color color8
      @ ++j, 1 Say '������������ ��᫥�������                   ���� ����᳤�� ��㣳�믮������' Color color8
      @ ++j, 1 Say '������������������������������������������������������������������������������' Color color8
      // ++j; @ j, 0 say replicate('�', 80) color color8
      // ++j; @ j, 0 say '_������������ ��᫥�������____________________���__����_��� ���_�믮������_' color color8
      If mem_por_ass == 0
        @ j -1, 52 Say Space( 5 )
      Endif
      fl_vrach := .t.
      For i := 1 To count_dvn_arr_usl
        fl_diag := .f.
        i_otkaz := 0
        If f_is_usl_oms_sluch_dvn( i, metap, iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast ), mpol, @fl_diag, @i_otkaz )
          If fl_diag .and. fl_vrach
            @ ++j, 1 Say '��������������������������������������������������������������������' Color color8
            @ ++j, 1 Say '������������ �ᬮ�஢                       ���� ����᳤�� ��㣨' Color color8
            @ ++j, 1 Say '��������������������������������������������������������������������' Color color8
            // ++j; @ j, 0 say replicate('�', 80) color color8
            // ++j; @ j, 0 say '_������������ �ᬮ�஢________________________���__����_��� ���_�������____' color color8
            If mem_por_ass == 0
              @ j -1, 52 Say Space( 5 )
            Endif
            fl_vrach := .f.
          Endif
          fl_g_cit := fl_kdp2 := .f.
          If ValType( dvn_arr_usl[ i, 2 ] ) == 'C'
            If ( fl_g_cit := ( dvn_arr_usl[ i, 2 ] == '4.20.1' ) )
              If m1g_cit == 0
                m1g_cit := 1 // ��砫쭮� ��᢮����
              Endif
              mg_cit := inieditspr( A__MENUVERT, mm_g_cit, m1g_cit )
              If mk_data > 0d20190831
                fl_g_cit := .f.
                m1g_cit := 1 // � ��
              Endif
            Elseif !is_disp_19 .and. glob_yes_kdp2[ TIP_LU_DVN ] .and. AScan( glob_arr_usl_LIS, dvn_arr_usl[ i, 2 ] ) > 0
              fl_kdp2 := .t.
            Endif
          Endif
          mvarv := 'MTAB_NOMv' + lstr( i )
          mvara := 'MTAB_NOMa' + lstr( i )
          mvard := 'MDATE' + lstr( i )
          If Empty( &mvard )
            &mvard := mn_data
          Endif
          mvarz := 'MKOD_DIAG' + lstr( i )
          mvaro := 'MOTKAZ' + lstr( i )
          mvarlis := 'MLIS' + lstr( i )
          ++j
          If fl_g_cit
            @ j, 1 Get mg_cit reader {| x | menu_reader( x, mm_g_cit, A__MENUVERT, , , .f. ) }
          Else
            @ j, 1 Say dvn_arr_usl[ i, 1 ]
          Endif
          If fl_kdp2
            @ j, 41 get &mvarlis reader {| x | menu_reader( x, mm_kdp2, A__MENUVERT, , , .f. ) }
          Endif
          @ j, 46 get &mvarv Pict '99999' valid {| g | v_kart_vrach( g ) }
          If mem_por_ass > 0
            @ j, 52 get &mvara Pict '99999' valid {| g | v_kart_vrach( g ) }
          Endif
          @ j, 58 get &mvard
          If fl_diag
            // @ j, 69 get &mvarz picture pic_diag ;
            // reader {| o |MyGetReader( o, bg ) } valid val1_10diag(.t., .f., .f., mn_data, mpol)
          Elseif i_otkaz == 0
            @ j, 69 get &mvaro ;
              reader {| x | menu_reader( x, mm_otkaz0, A__MENUVERT, , , .f. ) }
          Elseif i_otkaz == 1
            @ j, 69 get &mvaro ;
              reader {| x | menu_reader( x, mm_otkaz1, A__MENUVERT, , , .f. ) }
          Elseif eq_any( i_otkaz, 2, 3 )
            @ j, 69 get &mvaro ;
              reader {| x | menu_reader( x, mm_otkaz, A__MENUVERT, , , .f. ) }
          Endif
        Endif
      Next
      @ ++j, 1 Say Replicate( '�', 68 ) Color color8
      status_key( '^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 1-� ��࠭��� ^<PgDn>^ �� 3-� ��࠭���' )
    Elseif num_screen == 3 // 
      mm_gruppa := { mm_gruppaD1, mm_gruppaD2, mm_gruppaP, mm_gruppaD4, mm_gruppaD2 }[ metap ]
      If metap == 3
        If mk_data < 0d20191101
          mm_gruppa := mm_gruppaP_old
        Else
          mm_gruppa := mm_gruppaP_new
        Endif
      Endif
      mgruppa := inieditspr( A__MENUVERT, mm_gruppa, m1gruppa )
      ret_ndisp( Loc_kod, kod_kartotek )
      @ ++j, 8 Get mndisp When .f. Color color14
      If mvozrast != mdvozrast
        If m1veteran == 1
          s := '(��� ���࠭� �஢������ �� ������� ' + lstr( mdvozrast ) + ' ' + s_let( mdvozrast ) + ')'
        Else
          s := '(� ' + lstr( Year( mn_data ) ) + ' ���� �ᯮ������ ' + lstr( mdvozrast ) + ' ' + s_let( mdvozrast ) + ')'
        Endif
        @ j, 80 - Len( s ) Say s Color color14
      Endif
      @ ++j, 1  Say '������������������������������������������������������������������������������'
      @ ++j, 1  Say '       �  �����  �   ���   ��⠤����⠭������ ��ᯠ��୮� ��� ᫥���饣�'
      @ ++j, 1  Say '������������������� ������� ������.��������     (�����)     �����'
      @ ++j, 1  Say '������������������������������������������������������������������������������'
      //             2      9            22         35     44        54
      @ ++j, 2  Get mdiag1 Picture pic_diag ;
        reader {| o | mygetreader( o, bg ) } ;
        valid  {| g | iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn( g, 1 ), ;
        .f. ) }
      @ j, 9  Get mpervich1 ;
        reader {| x | menu_reader( x, mm_pervich, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag1 )
      @ j, 22 Get mddiag1 When !Empty( mdiag1 )
      @ j, 35 Get m1stadia1 Pict '9' Range 1, 4 ;
        When !Empty( mdiag1 )
      @ j, 44 Get mdispans1 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag1 )
      @ j, 54 Get mddispans1 When m1dispans1 == 1
      @ j, 67 Get mdndispans1 When m1dispans1 == 1
      //
      @ ++j, 2  Get mdiag2 Picture pic_diag ;
        reader {| o | mygetreader( o, bg ) } ;
        valid  {| g | iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn( g, 2 ), ;
        .f. ) }
      @ j, 9  Get mpervich2 ;
        reader {| x | menu_reader( x, mm_pervich, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag2 )
      @ j, 22 Get mddiag2 When !Empty( mdiag2 )
      @ j, 35 Get m1stadia2 Pict '9' Range 1, 4 ;
        When !Empty( mdiag2 )
      @ j, 44 Get mdispans2 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag2 )
      @ j, 54 Get mddispans2 When m1dispans2 == 1
      @ j, 67 Get mdndispans2 When m1dispans2 == 1
      //
      @ ++j, 2  Get mdiag3 Picture pic_diag ;
        reader {| o | mygetreader( o, bg ) } ;
        valid  {| g | iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn( g, 3 ), ;
        .f. ) }
      @ j, 9  Get mpervich3 ;
        reader {| x | menu_reader( x, mm_pervich, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag3 )
      @ j, 22 Get mddiag3 When !Empty( mdiag3 )
      @ j, 35 Get m1stadia3 Pict '9' Range 1, 4 ;
        When !Empty( mdiag3 )
      @ j, 44 Get mdispans3 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag3 )
      @ j, 54 Get mddispans3 When m1dispans3 == 1
      @ j, 67 Get mdndispans3 When m1dispans3 == 1
      //
      @ ++j, 2  Get mdiag4 Picture pic_diag ;
        reader {| o | mygetreader( o, bg ) } ;
        valid  {| g | iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn( g, 4 ), ;
        .f. ) }
      @ j, 9  Get mpervich4 ;
        reader {| x | menu_reader( x, mm_pervich, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag4 )
      @ j, 22 Get mddiag4 When !Empty( mdiag4 )
      @ j, 35 Get m1stadia4 Pict '9' Range 1, 4 ;
        When !Empty( mdiag4 )
      @ j, 44 Get mdispans4 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag4 )
      @ j, 54 Get mddispans4 When m1dispans4 == 1
      @ j, 67 Get mdndispans4 When m1dispans4 == 1
      //
      @ ++j, 2  Get mdiag5 Picture pic_diag ;
        reader {| o | mygetreader( o, bg ) } ;
        valid  {| g | iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
        f_valid_diag_oms_sluch_dvn( g, 5 ), ;
        .f. ) }
      @ j, 9  Get mpervich5 ;
        reader {| x | menu_reader( x, mm_pervich, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag5 )
      @ j, 22 Get mddiag5 When !Empty( mdiag5 )
      @ j, 35 Get m1stadia5 Pict '9' Range 1, 4 ;
        When !Empty( mdiag5 )
      @ j, 44 Get mdispans5 ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        When !Empty( mdiag5 )
      @ j, 54 Get mddispans5 When m1dispans5 == 1
      @ j, 67 Get mdndispans5 When m1dispans5 == 1
      //
      @ ++j, 1 Say Replicate( '�', 78 ) Color color1
      @ ++j, 1 Say '��ᯠ��୮� ������� ��⠭������' Get mdispans ;
        reader {| x | menu_reader( x, mm_dispans, A__MENUVERT, , , .f. ) } ;
        When !emptyall( mdispans1, mdispans2, mdispans3, mdispans4, mdispans5 )
      If is_disp_19
        If eq_any( metap, 1, 3 ) .and. mdvozrast < 65
          @ ++j, 1 Say iif( mdvozrast < 40, '�⭮�⥫��', '��᮫���' ) + ' �㬬��� �थ筮-��㤨��� ��' Get mssr Pict '99' ;
            valid {|| iif( Between( mssr, 0, 47 ), , func_error( 4, '��ࠧ㬭�� ���祭�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠' ) ), .t. }
          @ Row(), Col() Say '%'
        Else
          // ++j
        Endif
      Else
        If metap == 1 .and. mdvozrast < 66
          @ ++j, 1 Say iif( mdvozrast < 40, '�⭮�⥫��', '��᮫���' ) + ' �㬬��� �थ筮-��㤨��� ��' Get mssr Pict '99' ;
            valid {|| iif( Between( mssr, 0, 47 ), , func_error( 4, '��ࠧ㬭�� ���祭�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠' ) ), .t. }
          @ Row(), Col() Say '%'
        Elseif metap == 3 .and. mvozrast < 66
          @ ++j, 1 Say '�㬬��� �थ筮-��㤨��� ��' Get mssr Pict '99' ;
            valid {|| iif( Between( mssr, 0, 47 ), , func_error( 4, '��ࠧ㬭�� ���祭�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠' ) ), .t. }
          @ Row(), Col() Say '%'
        Else
          // ++j
        Endif
      Endif
      @ ++j, 1 Say '�ਧ��� �����७�� �� �������⢥���� ������ࠧ������' Get mDS_ONK ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '���ࠢ����� �� �����७�� �� ���' Get mnapr_onk ;
        reader {| x | menu_reader( x, { {| k, r, c| fget_napr_zno( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
        When m1ds_onk == 1
      @ ++j, 1 Say '�����祭� ��祭�� (��� �.131)' Get mnazn_l ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }

      dispans_napr( mk_data, @j, .t. )  // �맮� ���������� ����� ���ࠢ�����

      @ ++j, 1 Say '������ ���ﭨ� ��������'
      @ j, Col() + 1 Get mGRUPPA ;
        reader {| x | menu_reader( x, mm_gruppa, A__MENUVERT, , , .f. ) }
      status_key( '^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 2-� ��࠭��� ^<PgDn>^ ������' )
    Endif
    DispEnd()
    count_edit += myread()
    If num_screen == 3
      If LastKey() == K_PGUP
        k := 3
        --num_screen
      Else
        k := f_alert( { PadC( '�롥�� ����⢨�', 60, '.' ) }, ;
          { ' ��室 ��� ����� ', ' ������ ', ' ������ � ।���஢���� ' }, ;
          iif( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N, N/BG' )
      Endif
    Else
      If LastKey() == K_PGUP
        k := 3
        If num_screen > 1
          --num_screen
        Endif
      Elseif LastKey() == K_ESC
        If ( k := f_alert( { PadC( '�롥�� ����⢨�', 60, '.' ) }, ;
            { ' ��室 ��� ����� ', ' ������ � ।���஢���� ' }, ;
            1, 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N, N/BG' ) ) == 2
          k := 3
        Endif
      Else
        k := 3
        ++num_screen
        If mvozrast < 18
          num_screen := 1
          func_error( 4, '�� �� ����� ��樥��!' )
        Elseif metap == 0
          num_screen := 1
          func_error( 4, '�஢���� �ப� ��祭��!' )
        Endif
      Endif
    Endif
    SetMode( 25, 80 )
    If k == 3
      Loop
    Elseif k == 2
      num_screen := 1
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
      If Empty( mn_data )
        func_error( 4, '�� ������� ��� ��砫� ��祭��.' )
        Loop
      Endif
      If mvozrast < 18
        func_error( 4, '��䨫��⨪� ������� �� ���᫮�� ��樥���!' )
        Loop
      Endif
      If Empty( mk_data )
        func_error( 4, '�� ������� ��� ����砭�� ��祭��.' )
        Loop
      Endif
      If Empty( CharRepl( '0', much_doc, Space( 10 ) ) )
        func_error( 4, '�� �������� ����� ���㫠�୮� �����' )
        Loop
      Endif
      // if eq_any(m1gruppa, 3, 4, 13, 14, 23, 24) ;
      // .and. m1DS_ONK != 1 .and. len(arr) == 0 ;
      // .and. (m1dopo_na == 0) ;
      // .and. (m1napr_v_mo == 0) .and. (m1napr_stac == 0) .and. (m1napr_reab == 0)
      // func_error(4, '��� ��࠭��� ������ �������� �롥�� �����祭�� (���ࠢ�����) ��� ��樥��!')
      If check_group_nazn( '1', 3, 4, 13, 14, 23, 24 ) .and. m1DS_ONK != 1 .and. Len( arr ) == 0
        Loop
      Endif
      If ! checktabnumberdoctor( mk_data, .t. )
        Loop
      Endif
      If Empty( mWEIGHT )
        func_error( 4, '�� ����� ���.' )
        Loop
      Endif
      If Empty( mHEIGHT )
        func_error( 4, '�� ����� ���.' )
        Loop
      Endif
      If Empty( mOKR_TALII )
        func_error( 4, '�� ������� ���㦭���� ⠫��.' )
        Loop
      Endif
      If m1veteran == 1
        If metap == 3
          func_error( 4, '��䨫��⨪� ������ �� �஢���� ���࠭�� ��� (�����������)' )
          Loop
        Endif
      Endif
      If ! checktabnumberdoctor( mk_data )
        Loop
      Endif
      //
      mdef_diagnoz := iif( metap == 2, 'Z01.8 ', 'Z00.8 ' )
      r_use( dir_exe() + '_mo_mkb', cur_dir + '_mo_mkb', 'MKB_10' )
      r_use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'P2' )
      num_screen := 2
      max_date1 := mn_data
      fl := .t.
      not_4_20_1 := .f.
      date_4_1_12 := CToD( '' )
      k := ku := kol_d_usl := 0
      arr_osm1 := Array( count_dvn_arr_usl, 11 )
      afillall( arr_osm1, 0 )
      For i := 1 To count_dvn_arr_usl
        fl_diag := fl_ekg := .f.
        i_otkaz := 0
        If f_is_usl_oms_sluch_dvn( i, metap, iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast ), mpol, @fl_diag, @i_otkaz, @fl_ekg )
          mvart := 'MTAB_NOMv' + lstr( i )
          If Empty( &mvart ) .and. ( eq_any( metap, 2, 5 ) .or. fl_ekg ) // ���, �� ����� ���
            Loop                                                 // � ����易⥫�� ������
          Endif
          ar := dvn_arr_usl[ i ]
          mvara := 'MTAB_NOMa' + lstr( i )
          mvard := 'MDATE' + lstr( i )
          mvarz := 'MKOD_DIAG' + lstr( i )
          mvaro := 'M1OTKAZ' + lstr( i )
          if &mvard == mn_data
            k := i
          Endif
          If ValType( ar[ 2 ] ) == 'C' .and. ar[ 2 ] == '4.20.1'
            If not_4_20_1 // �� ������� ����
              Loop
            Endif
            If m1g_cit == 2
              If Empty( &mvard )
                fl := func_error( 4, '�� ������� ��� ��㣨 "' + mg_cit + '"' )
              Endif
              arr_osm1[ i, 1 ]  := 0        // ���
              arr_osm1[ i, 2 ]  := -13 // 1107     // ᯥ樠�쭮���
              arr_osm1[ i, 3 ]  := 0        // ����⥭�
              arr_osm1[ i, 4 ]  := 34       // ��䨫�
              arr_osm1[ i, 5 ]  := '4.20.2' // ��� ��㣨
              arr_osm1[ i, 6 ]  := mdef_diagnoz
              arr_osm1[ i, 9 ]  := &mvard
              arr_osm1[ i, 10 ] := &mvaro
              // if date_4_1_12 < mn_data ; // �᫨ 4.1.12 ������� ࠭�� ���-��
              // .or. arr_osm1[i, 9] < date_4_1_12 // ��� 4.20.1 ࠭�� 4.1.12
              // arr_osm1[i, 9] := date_4_1_12 // ��ࠢ�塞 ����
              // endif
              max_date1 := Max( max_date1, arr_osm1[ i, 9 ] )
              ++ku
              Loop
            Endif
          Else
            ++kol_d_usl
          Endif
          If i_otkaz == 2 .and. &mvaro == 2 // �᫨ ��᫥������� ����������
            Select P2
            find ( Str( &mvart, 5 ) )
            If Found()
              arr_osm1[ i, 1 ] := p2->kod
            Endif
            If ValType( ar[ 11 ] ) == 'A' // ᯥ樠�쭮���
              arr_osm1[ i, 2 ] := ar[ 11, 1 ]
            Endif
            If ValType( ar[ 10 ] ) == 'N' // ��䨫�
              arr_osm1[ i, 4 ] := ar[ 10 ]
            Endif
            arr_osm1[ i, 5 ] := ar[ 2 ] // ��� ��㣨
            arr_osm1[ i, 9 ] := iif( Empty( &mvard ), mn_data, &mvard )
            arr_osm1[ i, 10 ] := &mvaro
            --kol_d_usl
          Elseif Empty( &mvard )
            fl := func_error( 4, '�� ������� ��� ��㣨 "' + LTrim( ar[ 1 ] ) + '"' )
          Elseif Empty( &mvart ) .and. ! is_lab_usluga( ar[ 2 ] ) // ��� ��� ���� ����᪠���� ���⮥ ���祭�� ���
            fl := func_error( 4, '�� ������ ��� � ��㣥 "' + LTrim( ar[ 1 ] ) + '"' )
          Else
            Select P2
            find ( Str( &mvart, 5 ) )
            If Found()
              arr_osm1[ i, 1 ] := p2->kod
              arr_osm1[ i, 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
            Endif
            If !Empty( &mvara )
              Select P2
              find ( Str( &mvara, 5 ) )
              If Found()
                arr_osm1[ i, 3 ] := p2->kod
              Endif
            Endif
            If ValType( ar[ 10 ] ) == 'N' // ��䨫�
              arr_osm1[ i, 4 ] := ret_profil_dispans( ar[ 10 ], arr_osm1[ i, 2 ] )
            Else
              If Len( ar[ 10 ] ) == Len( ar[ 11 ] ) ; // ���-�� ��䨫�� = ���-�� ᯥ�-⥩
                .and. arr_osm1[ i, 2 ] < 0 ; // � ��諨 ᯥ樠�쭮��� �� V015
                .and. ( j := AScan( ar[ 11 ], ret_old_prvs( arr_osm1[ i, 2 ] ) ) ) > 0
                // ���� ��䨫�, ᮮ⢥�����騩 ᯥ樠�쭮��
              Else
                j := 1 // �᫨ ���, ���� ���� ��䨫� �� ᯨ᪠
              Endif
              arr_osm1[ i, 4 ] := ar[ 10, j ] // ��䨫�
            Endif
            ++ku
            If ValType( ar[ 2 ] ) == 'C'
              arr_osm1[ i, 5 ] := ar[ 2 ] // ��� ��㣨
              m1var := 'm1lis' + lstr( i )
              If !is_disp_19 .and. glob_yes_kdp2[ TIP_LU_DVN ] .and. &m1var > 0
                arr_osm1[ i, 11 ] := &m1var // �஢� �஢����� � ���2
              Endif
              If ar[ 2 ] == '2.3.1'
                If eq_any( arr_osm1[ i, 2 ], 2002, -206 ) // ᯥ樠�쭮���-䥫���
                  arr_osm1[ i, 5 ] := '2.3.3' // ��� ��㣨
                  arr_osm1[ i, 4 ] := 42 // ��䨫� - ��祡���� ����
                Elseif eq_any( arr_osm1[ i, 2 ], 2003, -207 ) // �����᪮� ����
                  arr_osm1[ i, 5 ] := '2.3.3' // ��� ��㣨
                  arr_osm1[ i, 4 ] := 3 // ��䨫� - �����᪮�� ����
                Endif
              Endif
            Else
              If Len( ar[ 2 ] ) >= metap
                j := metap
              Else
                j := 1
              Endif
              arr_osm1[ i, 5 ] := ar[ 2, j ] // ��� ��㣨
              If i == count_dvn_arr_usl // ��᫥���� ��㣠 �� ���ᨢ� - �࠯���
                If eq_any( metap, 2, 5 )
                  If eq_any( arr_osm1[ i, 2 ], 2002, -206 ) // ᯥ樠�쭮���-䥫���
                    fl := func_error( 4, '������ �� ����� �������� �࠯��� �� II �⠯� ��ᯠ��ਧ�樨' )
                  Endif
                Else // 1 � 3 �⠯
                  If eq_any( arr_osm1[ i, 2 ], 2002, -206 ) // ᯥ樠�쭮���-䥫���
                    arr_osm1[ i, 5 ] := iif( is_disp_19, '2.3.4', '2.3.3' ) // ��� ��㣨
                    arr_osm1[ i, 4 ] := 42 // ��䨫� - ��祡���� ����
                  Endif
                Endif
              Endif
            Endif
            If !fl_diag .or. Empty( &mvarz ) .or. Left( &mvarz, 1 ) == 'Z'
              arr_osm1[ i, 6 ] := mdef_diagnoz
            Else
              arr_osm1[ i, 6 ] := &mvarz
              Select MKB_10
              find ( PadR( arr_osm1[ i, 6 ], 6 ) )
              If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
                fl := func_error( 4, '��ᮢ���⨬���� �������� �� ���� ' + arr_osm1[ i, 6 ] )
              Endif
            Endif
            If ( arr_osm1[ i, 10 ] := &mvaro ) == 1 // �⪠�
              If arr_osm1[ i, 5 ] == '4.1.12' // �ᬮ�� ����મ�, ���⨥ ����� (�᪮��)
                not_4_20_1 := .t. // �� ������� ����
              Endif
            Endif
            If i_otkaz == 3 .and. &mvaro == 2 // ������������� ��� ��㣨 4.1.12
              If is_disp_19
                not_4_20_1 := .t. // �� ������� ����
              Else
                If arr_osm1[ i, 2 ] == 1101 // �᫨ 㪠���� ᯥ�-�� ���
                  arr_osm1[ i, 5 ] := '2.3.1' // ��� ��� �����-����������
                  arr_osm1[ i, 4 ] := 136 // ��䨫� - �������� � ����������� (�� �᪫�祭��� �ᯮ�짮����� �ᯮ����⥫��� ९த�⨢��� �孮�����)
                Else
                  arr_osm1[ i, 5 ] := '2.3.3' // ��� 䥫���-�����
                  arr_osm1[ i, 4 ] := 3 // ��䨫� - �����᪮�� ����
                Endif
                arr_osm1[ i, 10 ] := 0 // ��� �⪠�� (? ����� ���⠢��� 3-�⪫������?)
                not_4_20_1 := .t. // �� ������� ����
              Endif
            Endif
            arr_osm1[ i, 9 ] := &mvard
            // ��९�襬 ���� �� '�易���' ��㣠�
            Do Case
            Case arr_osm1[ i, 5 ] == '4.1.12' // ���⨥ ����� (�᪮��)
              date_4_1_12 := arr_osm1[ i, 9 ]
            Case arr_osm1[ i, 5 ] == '4.20.1' // ���-� ���⮣� �⮫����᪮�� ���ਠ��
              // if date_4_1_12 < mn_data ; // �᫨ 4.1.12 ������� ࠭�� ���-��
              // .or. arr_osm1[i, 9] < date_4_1_12 // ��� 4.20.1 ࠭�� 4.1.12
              // arr_osm1[i, 9] := date_4_1_12 // ��ࠢ�塞 ����
              // endif
            Endcase
            max_date1 := Max( max_date1, arr_osm1[ i, 9 ] )
          Endif
        Endif
        If !fl
          Exit
        Endif
      Next
      If !fl
        Loop
      Endif
      i_56_1_723 := 0
      If eq_any( metap, 2, 5 )
        If ku < 2
          If !is_disp_19 .and. ( i_56_1_723 := AScan( arr_osm1, {| x | ValType( x[ 5 ] ) == 'C' .and. x[ 5 ] == '56.1.723' } ) ) > 0
            // ���� �������㠫쭮� ��� ��㯯���� 㣫㡫����� ��䨫����᪮� �������஢���� - '56.1.723'
          Else
            func_error( 4, '�� II �⠯� ��易⥫�� �ᬮ�� �࠯��� � ��� �����-���� ��㣨.' )
            Loop
          Endif
        Endif
        If k == 0
          func_error( 4, '��� ��ࢮ�� �ᬮ�� (��᫥�������) ������ ࠢ������ ��� ��砫� ��祭��.' )
          Loop
        Endif
      Endif
      fl := .t.
      If emptyany( arr_osm1[ count_dvn_arr_usl, 1 ], arr_osm1[ count_dvn_arr_usl, 9 ] )
        If metap == 2 .and. i_56_1_723 > 0
          If !( arr_osm1[ i_56_1_723, 9 ] == mn_data .and. arr_osm1[ i_56_1_723, 9 ] == mk_data )
            fl := func_error( 4, '��砫� � ����砭�� ������ ࠢ������ ��� 㣫㡫������ ��䨫����.�������஢����' )
          Elseif lrslt_1_etap == 353 // ���ࠢ��� �� 2 �⠯, �।���⥫쭮 ��᢮��� II ��㯯� ���஢��
            If m1gruppa != 2
              fl := func_error( 4, '������⮬ 2-�� �⠯� ������ ���� II ��㯯� ���஢�� (��� � �� 1-�� �⠯�)' )
              num_screen := 3
            Endif
          Else // ��㣮� १����
            fl := func_error( 4, '������⮬ 1-�� �⠯� ������ ���� II ��㯯� (� ���ࠢ��� �� 2-�� �⠯)' )
            num_screen := 3
          Endif
        Else
          fl := func_error( 4, '�� ����� ��� �࠯��� (��� ��饩 �ࠪ⨪�)' )
        Endif
      Elseif arr_osm1[ count_dvn_arr_usl, 9 ] < mk_data
        fl := func_error( 4, '��࠯��� (��� ��饩 �ࠪ⨪�) ������ �஢����� �ᬮ�� ��᫥����!' )
      Endif
      If !fl
        Loop
      Endif
      num_screen := 3
      arr_diag := {}
      For i := 1 To 5
        sk := lstr( i )
        pole_diag := 'mdiag' + sk
        pole_d_diag := 'mddiag' + sk
        pole_1pervich := 'm1pervich' + sk
        pole_1dispans := 'm1dispans' + sk
        pole_d_dispans := 'mddispans' + sk
        pole_dn_dispans := 'mdndispans' + sk
        If !Empty( &pole_diag )
          If Left( &pole_diag, 1 ) == 'Z'
            fl := func_error( 4, '������� ' + RTrim( &pole_diag ) + '(���� ᨬ��� "Z") �� ��������. �� �� �����������!' )
          elseif &pole_1pervich == 0
            If Empty( &pole_d_diag )
              fl := func_error( 4, '�� ������� ��� ������ �������� ' + &pole_diag )
            elseif &pole_1dispans == 1 .and. Empty( &pole_d_dispans )
              fl := func_error( 4, '�� ������� ��� ��⠭������� ��ᯠ��୮�� ������� ��� �������� ' + &pole_diag )
            Endif
          Endif
          If fl .and. Between( &pole_1pervich, 0, 1 ) // �।���⥫�� �������� �� ����
            AAdd( arr_diag, { &pole_diag, &pole_1pervich, &pole_1dispans, &pole_dn_dispans } )
          Endif
        Endif
        If !fl
          Exit
        Endif
      Next
      If !fl
        Loop
      Endif
      is_disp_nabl := .f.
      AFill( adiag_talon, 0 )
      If Empty( arr_diag ) // �������� �� �������
        AAdd( arr_diag, { mdef_diagnoz, 0, 0, CToD( '' ) } ) // ������� �� 㬮�砭��
        MKOD_DIAG := mdef_diagnoz
      Else
        For i := 1 To Len( arr_diag )
          If arr_diag[ i, 2 ] == 0 // '࠭�� �����'
            arr_diag[ i, 2 ] := 2  // �����塞, ��� � ���� ���� ���
          Endif
          If arr_diag[ i, 3 ] > 0 // '���.������� ��⠭������' � '࠭�� �����'
            If arr_diag[ i, 2 ] == 2 // '࠭�� �����'
              arr_diag[ i, 3 ] := 1 // � '���⮨�'
            Else
              arr_diag[ i, 3 ] := 2 // � '����'
            Endif
          Endif
        Next
        For i := 1 To Len( arr_diag )
          If AScan( sadiag1, AllTrim( arr_diag[ i, 1 ] ) ) > 0 .and. ;
              arr_diag[ i, 3 ] == 1 .and. !Empty( arr_diag[ i, 4 ] ) .and. arr_diag[ i, 4 ] > mk_data
            is_disp_nabl := .t.
          Endif
          adiag_talon[ i * 2 -1 ] := arr_diag[ i, 2 ]
          adiag_talon[ i * 2    ] := arr_diag[ i, 3 ]
          If i == 1
            MKOD_DIAG := arr_diag[ i, 1 ]
          Elseif i == 2
            MKOD_DIAG2 := arr_diag[ i, 1 ]
          Elseif i == 3
            MKOD_DIAG3 := arr_diag[ i, 1 ]
          Elseif i == 4
            MKOD_DIAG4 := arr_diag[ i, 1 ]
          Elseif i == 5
            MSOPUT_B1 := arr_diag[ i, 1 ]
          Endif
          Select MKB_10
          find ( PadR( arr_diag[ i, 1 ], 6 ) )
          If Found()
            If !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
              fl := func_error( 4, '��ᮢ���⨬���� �������� �� ���� ' + AllTrim( arr_diag[ i, 1 ] ) )
            Endif
          Else
            fl := func_error( 4, '�� ������ ������� ' + AllTrim( arr_diag[ i, 1 ] ) + ' � �ࠢ�筨�� ���-10' )
          Endif
          If !fl
            Exit
          Endif
        Next
        If !fl
          Loop
        Endif
      Endif
      mm_gruppa := { mm_gruppaD1, mm_gruppaD2, mm_gruppaP, mm_gruppaD4, mm_gruppaD2 }[ metap ]
      If metap == 3
        If mk_data < 0d20191101
          mm_gruppa := mm_gruppaP_old
        Else
          mm_gruppa := mm_gruppaP_new
        Endif
      Endif
      m1p_otk := 0
      If ( i := AScan( mm_gruppa, {| x | x[ 2 ] == m1GRUPPA } ) ) > 0
        If ( m1rslt := mm_gruppa[ i, 3 ] ) == 352
          m1rslt := 353 // �� ����� ����� �� 06.07.18 �09-30-96
        Endif
        If eq_any( m1GRUPPA, 11, 21 )
          m1GRUPPA++ // �� ����� ����� �� 06.07.18 �09 -30 -96
        Endif
        If m1GRUPPA > 20
          m1p_otk := 1 // �⪠� �� ��室� �� 2-� �⠯
        Endif
      Else
        func_error( 4, '�� ������� ������ ���ﭨ� ��������' )
        Loop
      Endif
      m1ssh_na := m1psih_na := m1spec_na := 0
      If m1napr_v_mo > 0
        If eq_ascan( arr_mo_spec, 45, 141 ) // ���ࠢ��� � ����-�थ筮-��㤨�⮬� �����
          m1ssh_na := 1
        Endif
        If eq_ascan( arr_mo_spec, 23, 97 ) // ���ࠢ��� � ����-��娠��� (����-��娠���-��મ����)
          m1psih_na := 1
        Endif
      Endif
      If m1napr_stac > 0 .and. m1profil_stac > 0
        m1spec_na := 1 // ���ࠢ��� ��� ����祭�� ᯥ樠����஢����� ����樭᪮� ����� (� �.�. ���)
      Endif
      //
      err_date_diap( mn_data, '��� ��砫� ��祭��' )
      err_date_diap( mk_data, '��� ����砭�� ��祭��' )
      //
      If mem_op_out == 2 .and. yes_parol
        box_shadow( 19, 10, 22, 69, cColorStMsg )
        str_center( 20, '������ "' + fio_polzovat + '".', cColorSt2Msg )
        str_center( 21, '���� ������ �� ' + date_month( sys_date ), cColorStMsg )
      Endif
      mywait()
      //
      m1lis := 0
      For i := 1 To count_dvn_arr_usl
        If ValType( arr_osm1[ i, 9 ] ) == 'D'
          If arr_osm1[ i, 5 ] == '4.20.2' .and. arr_osm1[ i, 9 ] < mn_data // �� � ࠬ��� ��ᯠ��ਧ�樨
            m1g_cit := 1 // �᫨ � �뫮 =2, 㡨ࠥ�
          Elseif !is_disp_19 .and. glob_yes_kdp2[ TIP_LU_DVN ] .and. arr_osm1[ i, 9 ] >= mn_data .and. Len( arr_osm1[ i ] ) > 10 ;
              .and. ValType( arr_osm1[ i, 11 ] ) == 'N' .and. arr_osm1[ i, 11 ] > 0
            m1lis := arr_osm1[ i, 11 ] // � ࠬ��� ��ᯠ��ਧ�樨
          Endif
        Endif
      Next
      is_prazdnik := f_is_prazdnik_dvn( mn_data )
      If eq_any( metap, 2, 5 )
        i := count_dvn_arr_usl
        m1vrach  := arr_osm1[ i, 1 ]
        m1prvs   := arr_osm1[ i, 2 ]
        m1assis  := arr_osm1[ i, 3 ]
        m1PROFIL := arr_osm1[ i, 4 ]
        // MKOD_DIAG := padr(arr_osm1[i, 6], 6)
      Else  // metap := 1, 3, 4
        i := Len( arr_osm1 )
        m1vrach  := arr_osm1[ i, 1 ]
        m1prvs   := arr_osm1[ i, 2 ]
        m1assis  := arr_osm1[ i, 3 ]
        m1PROFIL := arr_osm1[ i, 4 ]
        // MKOD_DIAG := padr(arr_osm1[i, 6], 6)
        AAdd( arr_osm1, Array( 11 ) )
        i := i_zs := Len( arr_osm1 )
        arr_osm1[ i, 1 ] := arr_osm1[ i - 1, 1 ]
        arr_osm1[ i, 2 ] := arr_osm1[ i -1, 2 ]
        arr_osm1[ i, 3 ] := arr_osm1[ i -1, 3 ]
        arr_osm1[ i, 4 ] := 151 // ��� ���� �� - ���.�ᬮ�ࠬ ��䨫����᪨�
        arr_osm1[ i, 5 ] := ret_shifr_zs_dvn( metap, iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast ), mpol, mk_data )
        arr_osm1[ i, 6 ] := arr_osm1[ i -1, 6 ]
        arr_osm1[ i, 9 ] := mn_data
        arr_osm1[ i, 10 ] := 0
      Endif
      For i := 1 To count_dvn_arr_umolch
        If f_is_umolch_sluch_dvn( i, metap, iif( metap == 3 .and. !is_disp_19, mvozrast, mdvozrast ), mpol )
          ++kol_d_usl
          AAdd( arr_osm1, Array( 11 ) )
          j := Len( arr_osm1 )
          arr_osm1[ j, 1 ] := m1vrach
          arr_osm1[ j, 2 ] := m1prvs
          arr_osm1[ j, 3 ] := m1assis
          arr_osm1[ j, 4 ] := m1PROFIL
          arr_osm1[ j, 5 ] := dvn_arr_umolch[ i, 2 ]
          arr_osm1[ j, 6 ] := mdef_diagnoz
          arr_osm1[ j, 9 ] := iif( dvn_arr_umolch[ i, 8 ] == 0, mn_data, mk_data )
          arr_osm1[ j, 10 ] := 0
        Endif
      Next
      If eq_any( metap, 1, 3, 4 ) // �᫨ ���� �⠯, �஢�ਬ �� 85%
        not_zs := .f.
        kol := kol_otkaz := kol_n_date := kol_ob_otkaz := 0
        For i := 1 To Len( arr_osm1 )
          If i == i_zs
            Loop // �ய��⨬ ��� �����祭���� ����
          Endif
          If ValType( arr_osm1[ i, 5 ] ) == 'C' .and. !eq_any( arr_osm1[ i, 5 ], '4.20.1', '4.20.2' )
            ++kol // ���-�� ॠ�쭮 ������� ���
            If eq_any( arr_osm1[ i, 10 ], 0, 3 )
              If is_disp_19
                If arr_osm1[ i, 9 ] < mn_data .and. Year( arr_osm1[ i, 9 ] ) < Year( mn_data ) // ���-�� ��� ��� �⪠�� �믮����� ࠭��
                  ++kol_n_date                 // ��砫� �஢������ ��ᯠ��ਧ�樨 � �� �ਭ������� ⥪�饬� �������୮�� ����
                Endif
              Else
                If arr_osm1[ i, 9 ] < mn_data
                  ++kol_n_date // ���-�� ��� ��� �⪠�� �� ��ਮ�� ��ᯠ��ਧ�樨
                Endif
              Endif
            Elseif arr_osm1[ i, 10 ] == 1
              ++kol_otkaz // ���-�� �⪠���
  /* �� �஢������ ��ᯠ��ਧ�樨 ��易⥫�� ��� ��� �ࠦ��� ����:
  - '7.57.3' �஢������ �������䨨,
  - '4.8.4' ��᫥������� ���� �� ������ �஢� ���㭮娬��᪨� ����⢥��� ��� ������⢥��� ��⮤��,
  - '2.3.1','2.3.3' �ᬮ�� 䥫��஬ (����મ�) ��� ��箬 ����஬-�����������,
  - '4.1.12' ���⨥ ����� � 襩�� ��⪨,
  - '4.20.1','4.20.2' �⮫����᪮� ��᫥������� ����� � 襩�� ��⪨,
  - '4.14.66' ��।������ �����-ᯥ���᪮�� ��⨣��� � �஢� */
              If is_disp_19 .and. eq_any( arr_osm1[ i, 5 ], '4.8.4', '4.14.66', '7.57.3', '2.3.1', '2.3.3', '4.1.12', '4.20.1', '4.20.2' )
                ++kol_ob_otkaz // ���-�� �⪠��� �� ��易⥫��� ���
              Endif
            Else// if arr_osm1[i, 10] == 2 �᫨ ������������� �஢������ - ���� ���⠥� ��饥 ���-��
              --kol
            Endif
          Endif
        Next
        // kol_d_usl = 100% (������ ࠢ������ 'kol')
        If kol_d_usl != kol
          // func_error(4, 'kol_d_usl (' + lstr(kol_d_usl)+') != kol ' + lstr(kol))
        Endif
        If metap == 4
          If kol_n_date == 1
            not_zs := .t. // ���⠢�塞 �� �⤥��� ��䠬
          Endif
        Elseif ( i := AScan( dvn_85, {| x | x[ 1 ] == kol } ) ) > 0 // ��।����� 85%
          k := dvn_85[ i, 1 ] - dvn_85[ i, 2 ] // 15%
          If is_disp_19
            If kol_n_date + kol_otkaz <= k // �⪠�� + ࠭�� ������� ����� 15%
              // ���⠢�塞 �� �����祭���� ����
              If kol_ob_otkaz > 0 .and. metap == 1 // ���� ��।����� � ���ᬮ�� !!!!!
                If ( i := AScan( arr_osm1, {| x | ValType( x[ 5 ] ) == 'C' .and. x[ 5 ] == '2.3.7' } ) ) > 0
                  arr_osm1[ i, 5 ] := '2.3.2' // ��� ��㣨 ��� �࠯��� ��� ���ᬮ��
                Endif
                metap := 3
                If eq_any( m1rslt, 355, 356, 357, 358 ) .and. mk_data < 0d20191101 // III ��㯯�
                  m1rslt := 345
                  m1gruppa := 3
                Elseif eq_any( m1rslt, 355, 357 ) // III� ��㯯�
                  m1rslt := 373
                  m1gruppa := 3
                Elseif eq_any( m1rslt, 356, 358 ) // III� ��㯯�
                  m1rslt := 374
                  m1gruppa := 4
                Elseif eq_any( m1rslt, 318, 353 )
                  m1rslt := 344
                  m1gruppa := 2
                Else
                  m1rslt := 343
                  m1gruppa := 1
                Endif
                arr_osm1[ i_zs, 5 ] := ret_shifr_zs_dvn( metap, mdvozrast, mpol, mk_data )
                func_error( 4, '�⪠� �� ��易⥫쭮�� ��᫥������� - ��ଫ塞 ��䨫����᪨� �ᬮ�� ' + arr_osm1[ i_zs, 5 ] )
              Endif
            Else
              // �᫨ < 85%, ����� � �஢�થ
            Endif
          Else
            If kol_otkaz <= k // ������� 85% � �����
              If kol_n_date + kol_otkaz <= k // �⪠�� + ࠭�� ������� ����� 15%
                // ���⠢�塞 �� �����祭���� ����
              Else
                not_zs := .t. // ���⠢�塞 �� �⤥��� ��䠬
              Endif
            Else
              // �᫨ 'kol - kol_otkaz' < 85%, ����� � �஢�થ
            Endif
          Endif
        Else
          // �᫨ ⠪��� ���-�� ��� ��� � ���ᨢ� 'dvn_85', ����� � �஢�થ
        Endif
        If not_zs // ���⠢�塞 �� �⤥��� ��䠬
          del_array( arr_osm1, i_zs ) // 㤠�塞 �����祭�� ��砩
          larr := {}
          For i := 1 To Len( arr_osm1 )
            If ValType( arr_osm1[ i, 5 ] ) == 'C' ;
                .and. !( Len( arr_osm1[ i ] ) > 10 .and. ValType( arr_osm1[ i, 11 ] ) == 'N' .and. arr_osm1[ i, 11 ] > 0 ) ; // �� � ���2
              .and. eq_any( arr_osm1[ i, 10 ], 0, 3 ) ; // �� �⪠�
              .and. arr_osm1[ i, 9 ] >= mn_data ; // ������� �� �६� ���-��
              .and. ( k := AScan( dvn_700, {| x | x[ 1 ] == arr_osm1[ i, 5 ] } ) ) > 0
              AAdd( larr, AClone( arr_osm1[ i ] ) )
              j := Len( larr )
              larr[ j, 5 ] := dvn_700[ k, 2 ]
            Endif
          Next
          For i := 1 To Len( larr )
            AAdd( arr_osm1, AClone( larr[ i ] ) ) // ������� � ���ᨢ ��㣨 �� '700'
          Next
        Endif
      Endif
      make_diagp( 2 )  // ᤥ���� '��⨧����' ��������
      If m1dispans > 0
        s1dispans := m1dispans
      Endif
      //
      use_base( 'lusl' )
      use_base( 'luslc' )
      use_base( 'uslugi' )
      r_use( dir_server + 'uslugi1', { dir_server + 'uslugi1', ;
        dir_server + 'uslugi1s' }, 'USL1' )
      mcena_1 := mu_cena := 0
      arr_usl_dop := {}
      arr_usl_otkaz := {}
      arr_otklon := {}
      glob_podr := ''
      glob_otd_dep := 0
      For i := 1 To Len( arr_osm1 )
        If ValType( arr_osm1[ i, 5 ] ) == 'C'
          arr_osm1[ i, 7 ] := foundourusluga( arr_osm1[ i, 5 ], mk_data, arr_osm1[ i, 4 ], M1VZROS_REB, @mu_cena )
          arr_osm1[ i, 8 ] := mu_cena
          mcena_1 += mu_cena
          If eq_any( arr_osm1[ i, 10 ], 0, 3 ) // �믮�����
            AAdd( arr_usl_dop, arr_osm1[ i ] )
            If arr_osm1[ i, 10 ] == 3 // �����㦥�� �⪫������
              AAdd( arr_otklon, arr_osm1[ i, 5 ] )
            Endif
          Else // �⪠� � �������������
            AAdd( arr_usl_otkaz, arr_osm1[ i ] )
          Endif
        Endif
      Next
      //
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
      //
      st_N_DATA := MN_DATA
      glob_perso := mkod
      If m1komu == 0
        msmo := lstr( m1company )
        m1str_crb := 0
      Else
        msmo := ''
        m1str_crb := m1company
      Endif
      //
      human->kod_k      := glob_kartotek
      human->TIP_H      := B_STANDART // 3-��祭�� �����襭�
      human->FIO        := MFIO          // �.�.�. ���쭮��
      human->POL        := MPOL          // ���
      human->DATE_R     := MDATE_R       // ��� ஦����� ���쭮��
      human->VZROS_REB  := M1VZROS_REB   // 0-�����, 1-ॡ����, 2-�����⮪
      human->ADRES      := MADRES        // ���� ���쭮��
      human->MR_DOL     := MMR_DOL       // ���� ࠡ��� ��� ��稭� ���ࠡ�⭮��
      human->RAB_NERAB  := M1RAB_NERAB   // 0-ࠡ���騩, 1-��ࠡ���騩, 2-��㤥��
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
      human->UCH_DOC    := MUCH_DOC      // ��� � ����� ��⭮�� ���㬥��
      human->N_DATA     := MN_DATA       // ��� ��砫� ��祭��
      human->K_DATA     := MK_DATA       // ��� ����砭�� ��祭��
      human->CENA := human->CENA_1 := MCENA_1 // �⮨����� ��祭��
      human->ishod      := 200 + metap
      human->OBRASHEN   := iif( m1DS_ONK == 1, '1', ' ' )
      human->bolnich    := 0
      human->date_b_1   := ''
      human->date_b_2   := ''
      human_->RODIT_DR  := CToD( '' )
      human_->RODIT_POL := ''
      s := ''
      AEval( adiag_talon, {| x | s += Str( x, 1 ) } )
      human_->DISPANS   := s
      human_->STATUS_ST := ''
      human_->POVOD     := iif( metap == 3, 5, 6 )
      // human_->TRAVMA    := m1travma
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := LTrim( mspolis )
      human_->NPOLIS    := LTrim( mnpolis )
      human_->OKATO     := '' // �� ���� ������� �� ����� � ��砥 �����த����
      human_->NOVOR     := 0
      human_->DATE_R2   := CToD( '' )
      human_->POL2      := ''
      human_->USL_OK    := m1USL_OK
      human_->VIDPOM    := m1VIDPOM
      human_->PROFIL    := m1PROFIL
      human_->IDSP      := iif( metap == 3, 17, 11 )
      human_->NPR_MO    := ''
      human_->FORMA14   := '0000'
      human_->KOD_DIAG0 := ''
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // 㡥�� '2', �᫨ ��।���஢��� ������ �� ॥��� �� � ��
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
      put_0_human_2()
      Private fl_nameismo := .f.
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
        g_use( dir_server + 'mo_hismo', , 'SN' )
        Index On Str( kod, 7 ) to ( cur_dir + 'tmp_ismo' )
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
      i1 := Len( arr_usl )
      i2 := Len( arr_usl_dop )
      use_base( 'human_u' )
      For i := 1 To i2
        Select HU
        If i > i1
          add1rec( 7 )
          hu->kod := human->kod
        Else
          Goto ( arr_usl[ i ] )
          g_rlock( forever )
        Endif
        mrec_hu := hu->( RecNo() )
        hu->kod_vr  := arr_usl_dop[ i, 1 ]
        hu->kod_as  := arr_usl_dop[ i, 3 ]
        hu->u_koef  := 1
        hu->u_kod   := arr_usl_dop[ i, 7 ]
        hu->u_cena  := arr_usl_dop[ i, 8 ]
        hu->is_edit := iif( Len( arr_usl_dop[ i ] ) > 10 .and. ValType( arr_usl_dop[ i, 11 ] ) == 'N', arr_usl_dop[ i, 11 ], 0 )
        hu->date_u  := dtoc4( arr_usl_dop[ i, 9 ] )
        hu->otd     := m1otd
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := arr_usl_dop[ i, 8 ]
        hu->KOL_RCP := 0
        Select HU_
        Do While hu_->( LastRec() ) < mrec_hu
          Append Blank
        Enddo
        Goto ( mrec_hu )
        g_rlock( forever )
        If i > i1 .or. !valid_guid( hu_->ID_U )
          hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
        Endif
        hu_->PROFIL := arr_usl_dop[ i, 4 ]
        hu_->PRVS   := arr_usl_dop[ i, 2 ]
        hu_->kod_diag := iif( Empty( arr_usl_dop[ i, 6 ] ), MKOD_DIAG, arr_usl_dop[ i, 6 ] )
        hu_->zf := ''
        Unlock
      Next
      If i2 < i1
        For i := i2 + 1 To i1
          Select HU
          Goto ( arr_usl[ i ] )
          deleterec( .t., .f. )  // ���⪠ ����� ��� ����⪨ �� 㤠�����
        Next
      Endif
      save_arr_dvn( mkod )
      If m1ds_onk == 1 // �����७�� �� �������⢥���� ������ࠧ������
        save_mo_onkna( mkod )
      Endif
      write_work_oper( glob_task, OPER_LIST, iif( Loc_kod == 0, 1, 2 ), 1, count_edit )
      fl_write_sluch := .t.
      Close databases
      stat_msg( '������ �����襭�!', .f. )
    Endif
    Exit
  Enddo
  Close databases
  SetColor( tmp_color )
  RestScreen( buf )
  chm_help_code := tmp_help
  If fl_write_sluch // �᫨ ����ᠫ� - ����᪠�� �஢���
    If Type( 'fl_edit_DVN' ) == 'L'
      fl_edit_DVN := .t.
    Endif
    If !Empty( Val( msmo ) )
      verify_oms_sluch( glob_perso )
    Endif
  Endif

  Return Nil
