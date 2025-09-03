#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 03.09.25 ���������� ��� ।���஢���� ���� (���� ���)
Function oms_sluch_main( Loc_kod, kod_kartotek )
  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)

  Static SKOD_DIAG := '     ', st_l_z := 1, st_N_DATA, st_K_DATA, st_rez_gist, ;
    st_vrach := 0, st_profil := 0, st_profil_k := 0, st_rslt := 0, st_ishod := 0, st_povod := 9
  Static menu_bolnich := { { '���', 0 }, { '�� ', 1 }, { '���', 2 } }

  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, ;
    buf, tmp_color := SetColor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', ;
    i, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    tmp_help := chm_help_code, fl_write_sluch := .f., when_uch_doc := .t.
  Local mm_reg_lech := { { '�᭮���', 0 }, { '�������⥫��', 9 } }
  Local mWeight := 0
  Local oldPictureTalon := '@S12'
  Local newPictureTalon := '@S 99.9999.99999.999'
  Local j, it
  Local i_n007, aN007 := getn007(), i_n008, aN008 := loadn008(), i_n009, aN009 := getn009()
  Local i_n012, aN012_DS := getds_n012(), ar_N012 := {}
  Local i_n010, aN010 := loadn010(), i_n011, aN011 := loadn011()
  local diag_onko_replace
  local s

  Default st_N_DATA To Date(), st_K_DATA To Date()
  Default Loc_kod To 0, kod_kartotek To 0
  If kod_kartotek == 0 // ���������� � ����⥪�
    If ( kod_kartotek := edit_kartotek( 0, , , .t. ) ) == 0
      Return Nil
    Endif
  Endif
  If Loc_kod == 0 .and. Len( glob_otd ) > 3 // ⮫쪮 �� ����������
    If is_hemodializ .and. glob_otd[ 4 ] == TIP_LU_H_DIA  // ����������
      Return oms_sluch_dializ( 1, Loc_kod, kod_kartotek )
    Elseif is_per_dializ .and. glob_otd[ 4 ] == TIP_LU_P_DIA  // ����.������
      Return oms_sluch_dializ( 2, Loc_kod, kod_kartotek )
    Endif
  Endif
  // ��।����� ���� k*80 ᨬ�����
  kscr1 := iif( is_MO_VMP, 30, 26 )
  If is_dop_ob_em
    ++kscr1
  Endif
  If is_reabil_slux
    ++kscr1
  Endif
  buf := SaveScreen()
  If is_uchastok == 1 .and. is_task( X_REGIST ) // �23/12356 � ���� '����������'
    when_uch_doc := ( mem_edit_ist == 2 )
  Endif
  //
  chm_help_code := 3002
  //
  Private tmp_V006 := create_classif_ffoms( 2, 'V006' ) // USL_OK
  Private tmp_V002 := create_classif_ffoms( 2, 'V002' ) // PROFIL
  Private tmp_V020 := create_classif_ffoms( 2, 'V020' ) // PROFIL_K
  Private tmp_V009 := getv009( sys_date ) // rslt
  Private tmp_V012 := getv012( sys_date ) // ishod
  Private mm_rslt, mm_ishod, rslt_umolch := 0, ishod_umolch := 0
  //
  Private mkod := Loc_kod, mtip_h, is_talon := .f., ibrm := 0, ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    M1LPU := glob_uch[ 1 ], MLPU, ;
    M1OTD := glob_otd[ 1 ], MOTD, ;
    mfio := Space( 50 ),  mpol, mdate_r, madres, mmr_dol, ;
    M1FIO_KART := 1, MFIO_KART, ;
    M1VZROS_REB, MVZROS_REB, mpolis, M1RAB_NERAB, ;
    MUCH_DOC    := Space( 10 ), ; // ��� � ����� ��⭮�� ���㬥��
    MKOD_DIAG0  := Space( 6 ), ; // ��� ��ࢨ筮�� ��������
    MKOD_DIAG   := SKOD_DIAG, ; // ��� 1-�� ��.�������
    MKOD_DIAG2  := Space( 5 ), ; // ��� 2-�� ��.�������
    MKOD_DIAG3  := Space( 5 ), ; // ��� 3-�� ��.�������
    MKOD_DIAG4  := Space( 5 ), ; // ��� 4-�� ��.�������
    MSOPUT_B1   := Space( 5 ), ; // ��� 1-�� ᮯ������饩 �������
    MSOPUT_B2   := Space( 5 ), ; // ��� 2-�� ᮯ������饩 �������
    MSOPUT_B3   := Space( 5 ), ; // ��� 3-�� ᮯ������饩 �������
    MSOPUT_B4   := Space( 5 ), ; // ��� 4-�� ᮯ������饩 �������
    MDIAG_PLUS  := Space( 8 ), ; // ���������� � ���������
    adiag_talon[ 16 ], ; // �� ���⠫��� � ���������
    mprer_b := Space( 28 ),  m1prer_b := 0, ; // ���뢠��� ��६������
    mrslt, m1rslt := st_rslt, ; // १����
    mishod := Space( 20 ), m1ishod := st_ishod, ; // ��室
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-���, 1-��������, 3-�������/���, 5-���� ���
    m1NPR_MO := '',  mNPR_MO := Space( 10 ),  mNPR_DATE := CToD( '' ), ;
    m1reg_lech := 0, mreg_lech, ;
    MN_DATA     := st_N_DATA, ; // ��� ��砫� ��祭��
    MK_DATA     := st_K_DATA, ; // ��� ����砭�� ��祭��
    MCENA_1     := 0, ; // �⮨����� ��祭��
    MVRACH      := Space( 10 ), ; // 䠬���� � ���樠�� ���饣� ���
    M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
    MBOLNICH, M1BOLNICH := 0, ; // ���쭨��
    MDATE_B_1   := CToD( '' ), ; // ��� ��砫� ���쭨筮��
    MDATE_B_2   := CToD( '' ), ; // ��� ����砭�� ���쭨筮��
    mrodit_dr   := CToD( '' ), ; // ��� ஦����� த�⥫�
    mrodit_pol  := ' ', ; // ��� த�⥫�
    MF14_EKST, M1F14_EKST := 0, ; //
    MF14_SKOR, M1F14_SKOR := 0, ; //
    MF14_VSKR, M1F14_VSKR := 0, ; //
    MF14_RASH, M1F14_RASH := 0, ; //
    m1novor := 0, mnovor, mcount_reb := 0, ;
    mDATE_R2 := CToD( '' ),  mpol2 := ' ', ;
    m1USL_OK := 0, mUSL_OK, ;
    m1P_PER := 0, mP_PER := Space( 35 ), ; // �ਧ��� ����㯫����/��ॢ��� 1-4
    m1PROFIL := st_profil, mPROFIL, ;
    m1PROFIL_K := st_profil_k, mPROFIL_K, ;
    m1vid_reab := 0, mvid_reab, ;
    mstatus_st := Space( 10 ), ;
    mpovod, m1povod := st_povod, ;
    mtravma, m1travma := 0, ;
    MOSL1 := Space( 6 ), ; // ��� 1-��� �������� �᫮������ �����������
    MOSL2 := Space( 6 ), ; // ��� 2-��� �������� �᫮������ �����������
    MOSL3 := Space( 6 ), ; // ��� 3-��� �������� �᫮������ �����������
    MVMP, M1VMP := 0, ; // 0-���, 1-�� ���
    mtal_num := Space( 20 ), ; // ����� ⠫��� �� ���
    MVIDVMP, M1VIDVMP := Space( 12 ), ; // ��� ��� �� �ࠢ�筨�� V018
    mmodpac := Space( 12 ), ; // ������ ��樥�� �� �ࠢ�筨�� V022
    m1modpac := 0, ; // ������ ��樥�� �� �ࠢ�筨�� V022
    MMETVMP, M1METVMP := 0, ; // ��⮤ ��� �� �ࠢ�筨�� V019 //  mstentvmp := ' ', ; // ���-�� �⥭⮢ ��� ��⮤�� ��� 498, 499
    mTAL_D := CToD( '' ), ; // ��� �뤠� ⠫��� �� ���
    mTAL_P := CToD( '' ), ; // ��� ������㥬�� ��ᯨ⠫���樨 � ᮮ⢥��⢨� � ⠫���� �� ���
    MVNR  := Space( 4 ), ; // ��� ������襭���� ॡ񭪠 (������ ॡ񭮪)
    MVNR1 := Space( 4 ), ; // ��� 1-�� ������襭���� ॡ񭪠 (������ ����)
    MVNR2 := Space( 4 ), ; // ��� 2-�� ������襭���� ॡ񭪠 (������ ����)
    MVNR3 := Space( 4 ), ; // ��� 3-�� ������襭���� ॡ񭪠 (������ ����)
    input_vnr := .f., input_vnrm := .f., ;
    msmo := '',  rec_inogSMO := 0, ;
    mokato, m1okato := '',  mismo, m1ismo := '',  mnameismo := Space( 100 ), ;
    mvidpolis, m1vidpolis := 1, mspolis := Space( 10 ),  mnpolis := Space( 20 ), ;
    m1_l_z := st_l_z, m_l_z, ;             // ��祭�� �����襭� ?
    mm1prer_b := { ;
      { '�� ����樭᪨� ���������   ', 1 }, ;
      { '�� �� ����樭᪨� ���������', 2 } }, ;
    mm2prer_b := { ;
      { '���⠭���� �� ���� �� ��६.', 1 }, ;
      { '�த������� �������      ', 0 } }, ;
    mm3prer_b := { ;
      { '������⢨� �������� ᨭ�஬�', 0 }, ;
      { '����� ����                 ', 1 }, ;
      { '����ﭭ�� ���㯨����. ���� ', 2 }, ;
      { '��㣠� ����ﭭ�� ����      ', 3 }, ;
      { '���� �����񭭠�           ', 4 } }, ;
    mm_p_per := { ;
      { '����㯨� ᠬ����⥫쭮', 1 }, ;
      { '���⠢��� ���', 2 }, ;
      { '��ॢ�� �� ��㣮� ��', 3 }, ;
      { '��ॢ�� ����� ��', 4 } }
  Private mm_prer_b := mm2prer_b

  Private mTab_Number := 0
  Private mNMSE, m1NMSE := NO  // ���ࠢ����� �� ���
  Private mnapr_onk := Space( 10 ), m1napr_onk := 0

  If mem_zav_l == 1  // ��
    m1_l_z := 1   // ��
  Elseif mem_zav_l == 2  // ���
    m1_l_z := 0   // ���
  Endif
  Private mad_cr := Space( 60 ),  m1ad_cr := Space( 60 ),  pr_ds_it := 0, input_ad_cr := .f.

  Private mm_ad_cr := {}
  // ���������
  Private is_oncology := 0, old_oncology := .f., ;
    mDS_ONK, m1DS_ONK := 0, ; // �ਧ��� �����७�� �� �������⢥���� ������ࠧ������
    mDS1_T, m1DS1_T := 0, ; // ����� ���饭��:0 - ��ࢨ筮� ��祭��;1 - �樤��;2 - �ண���஢����
    mPR_CONS, m1PR_CONS := 0, ; // �������� � �஢������ ���ᨫ�㬠:1 - ��।����� ⠪⨪� ��᫥�������;2 - ��।����� ⠪⨪� ��祭��;3 - �������� ⠪⨪� ��祭��.
    mDT_CONS := CToD( '' ), ; // ��� �஢������ ���ᨫ�㬠    ��易⥫쭮 � ���������� �� ����������� PR_CONS
    mSTAD, m1STAD := 0, ; // �⠤�� �����������      ���������� � ᮮ⢥��⢨� � �ࠢ�筨��� N002
    mONK_T, m1ONK_T := 0, ; // ���祭�� Tumor        ���������� � ᮮ⢥��⢨� � �ࠢ�筨��� N003
    mONK_N, m1ONK_N := 0, ; // ���祭�� Nodus        ���������� � ᮮ⢥��⢨� � �ࠢ�筨��� N004
    mONK_M, m1ONK_M := 0, ; // ���祭�� Metastasis   ���������� � ᮮ⢥��⢨� � �ࠢ�筨��� N005
    mMTSTZ, m1MTSTZ := 0, ;   // �ਧ��� ������ �⤠���� ����⠧��       �������� ���������� ���祭��� 1 �� ������ �⤠���� ����⠧�� ⮫쪮 �� DS1_T=1 ��� DS1_T=2
    mB_DIAG, m1B_DIAG := 98, ; // ���⮫����:99-�� ����, 98-ᤥ����, 97-��� १����, 0-�⪠�, 7-�� ��������, 8-��⨢���������
    mK_FR := Space( 2 ), ; // ���-�� �ࠪ権 �஢������ ��祢�� �࠯�� ��易⥫쭮 ��� ���������� �� �஢������ ��祢�� ��� 娬����祢�� �࠯�� (USL_TIP=3 ��� USL_TIP=4)�.�.=0
    mCRIT, m1crit := Space( 10 ), ; // ��� �奬� ���.�࠯�� V024 (sh..., mt...)
    mCRIT2, ; // ���.���਩ (fr...)
    mm_shema_err := { { 'ᮡ���', 0 }, { '�� ᮡ���', 1 } }, ;
    mm_shema_usl := {}, ;
    mWEI := Space( 5 ), ; // ���� ⥫� � �� ��易⥫쭮 ��� ���������� �� �஢������ ������⢥���� ��� 娬����祢�� �࠯�� (USL_TIP=2 ��� USL_TIP=4)
    mHEI := Space( 3 ), ; // ��� � � ��易⥫쭮 ��� ���������� �� �஢������ ������⢥���� ��� 娬����祢�� �࠯�� (USL_TIP=2 ��� USL_TIP=4)
    mBSA := Space( 4 )   // ���頤� �����孮�� ⥫� � ��.�. ��易⥫쭮 ��� ���������� �� �஢������ ������⢥���� ��� 娬����祢�� �࠯�� (USL_TIP=2 ��� USL_TIP=4)

  dbCreate( cur_dir() + 'tmp_onkna',  create_struct_temporary_onkna() )

  Private m1NAPR_MO, mNAPR_MO, mNAPR_DATE, mNAPR_V, m1NAPR_V, mMET_ISSL, m1MET_ISSL, ;
    mshifr, mshifr1, mname_u, mU_KOD, cur_napr := 0, count_napr := 0, tip_onko_napr := 0
  Private mm_DS1_T := getn018()
  Private mm_PR_CONS := getn019() // N019

  If Empty( st_rez_gist ) // ��� ���⮫���� � �����������
    st_rez_gist := {}
    For i_n007 := 1 To Len( aN007 )
      AAdd( st_rez_gist, { aN007[ i_n007, 1 ], aN007[ i_n007, 2 ], {}, 0 } )
      i := Len( st_rez_gist )
      For i_n008 := 1 To Len( aN008 )
        If aN007[ i_n007, 2 ] == aN008[ i_n008, 2 ]
          AAdd( st_rez_gist[ i, 3 ], { AllTrim( aN008[ i_n008, 3 ] ), aN008[ i_n008, 1 ] } )
        Endif
      Next
    Next
  Endif

  Private mdiag_date := CToD( '' ),  mgist1, mgist2, m1gist1 := 0, m1gist2 := 0, ;
    mmark1, mmark2, mmark3, mmark4, mmark5, mgist[ 2 ], mmark[ 5 ], ;
    m1mark1 := 0, m1mark2 := 0, m1mark3 := 0, m1mark4 := 0, m1mark5 := 0, ;
    is_gisto := .f., mrez_gist, m1rez_gist := 0, arr_rez_gist := AClone( st_rez_gist )

  AFill( mgist, 0 )
  AFill( mmark, 0 )
  dbCreate( cur_dir() + 'tmp_onkco',  { ; // �������� � �஢������ ���ᨫ�㬠
    { 'KOD',      'N',   7,  0 }, ; // ��� ���쭮��
    { 'PR_CONS',  'N',   1,  0 }, ; // �������� � �஢������ ���ᨫ�㬠(N019):0-��������� ����室������;1-��।����� ⠪⨪� ��᫥�������;2-��।����� ⠪⨪� ��祭��;3-�������� ⠪⨪� ��祭��
    { 'DT_CONS',  'D',   8,  0 };  // ��� �஢������ ���ᨫ�㬠 ��易⥫쭮 � ���������� �� PR_CONS=1, 2, 3
  } )
  dbCreate( cur_dir() + 'tmp_onkdi',  { ; // ���������᪨� ����
    { 'KOD',      'N',   7,  0 }, ; // ��� ���쭮��
    { 'DIAG_DATE','D',   8,  0 }, ; // ��� ����� ���ਠ�� ��� �஢������ �������⨪�
    { 'DIAG_TIP', 'N',   1,  0 }, ; // ��� ���������᪮�� ������⥫�: 1 - ���⮫����᪨� �ਧ���; 2 - ����� (���)
    { 'DIAG_CODE','N',   3,  0 }, ; // ��� ���������᪮�� ������⥫� �� DIAG_TIP=1 � ᮮ⢥��⢨� � �ࠢ�筨��� N007 �� DIAG_TIP=2 � ᮮ⢥��⢨� � �ࠢ�筨��� N010
    { 'DIAG_RSLT','N',   3,  0 }, ; // ��� १���� �������⨪� �� DIAG_TIP=1 � ᮮ⢥��⢨� � �ࠢ�筨��� N008 �� DIAG_TIP=2 � ᮮ⢥��⢨� � �ࠢ�筨��� N011
    { 'REC_RSLT', 'N',   1,  0 };  // �ਧ��� ����祭�� १���� �������⨪� 1 - ����祭
  } )
  dbCreate( cur_dir() + 'tmp_onkpr',  { ; // �������� �� �������� ��⨢�����������
    { 'KOD',      'N',   7,  0 }, ; // ��� ���쭮��
    { 'PROT',     'N',   1,  0 }, ; // ��� ��⨢���������� ��� �⪠�� � ᮮ⢥��⢨� � �ࠢ�筨��� N001
    { 'D_PROT',   'D',   8,  0 };  // ��� ॣ����樨 ��⨢���������� ��� �⪠��
  } )

  Private mprot1, mprot2, mprot, mprot4, mprot5, mprot6, ;
    m1prot1, m1prot2, m1prot, m1prot4, m1prot5, m1prot6, ;
    mdprot1, mdprot2, mdprot, mdprot4, mdprot5, mdprot6
  //
  dbCreate( cur_dir() + 'tmp_onkus',  { ; // �������� � �஢����� ��祭���
    { 'KOD',      'N',   7,  0 }, ; // ��� ���쭮��
    { 'USL_TIP',  'N',   1,  0 }, ; // ��� ������㣨 � ᮮ⢥��⢨� � �ࠢ�筨��� N013
    { 'HIR_TIP',  'N',   1,  0 }, ; // ��� ���ࣨ�᪮�� ��祭�� �� USL_TIP=1 � ᮮ⢥��⢨� � �ࠢ�筨��� N014
    { 'LEK_TIP_L','N',   1,  0 }, ; // ����� ������⢥���� �࠯�� �� USL_TIP=2 � ᮮ⢥��⢨� � �ࠢ�筨��� N015
    { 'LEK_TIP_V','N',   1,  0 }, ; // ���� ������⢥���� �࠯��   �� USL_TIP=2 � ᮮ⢥��⢨� � �ࠢ�筨��� N016
    { 'LUCH_TIP', 'N',   1,  0 }, ; // ��� ��祢�� �࠯��  �� USL_TIP=3, 4 � ᮮ⢥��⢨� � �ࠢ�筨��� N017
    { 'PPTR',     'N',   1,  0 }, ; // �ਧ��� �஢������ ��䨫��⨪� �譮�� � ࢮ⭮�� �䫥�� - 㪠�뢠���� '1' �� USL_TIP=2, 4
    { 'SOD',      'N',   6,  2 };  // SOD - �㬬�ୠ� �砣���� ���� - �� USL_TIP=3, 4
  } )
  dbCreate( cur_dir() + 'tmp_onkle',  { ; // �������� � �ਬ����� ������⢥���� �९����
    { 'KOD',      'N',   7,  0 }, ; // ��� ���쭮��
    { 'REGNUM',   'C',   6,  0 }, ; // IDD ���.�९��� N020
    { 'ID_ZAP',   'N',   6,  0 }, ; // IDD ���.�९��� N021
    { 'CODE_SH',  'C',  20,  0 }, ; // ��� �奬� ���.�࠯�� V024
    { 'DATE_INJ', 'D',   8,  0 };  // ��� �������� ���.�९���
  } )

  Private musl_tip, m1usl_tip, musl_tip1, m1usl_tip1, musl_tip2, m1usl_tip2, msod, ;
    musl_vmp, m1usl_vmp, musl_vmp1, m1usl_vmp1, musl_vmp2, m1usl_vmp2, msod_vmp, ;
    mpptr, m1pptr := 0, mpptr_vmp, m1pptr_vmp := 0, ;
    mIS_ERR, m1is_err := 0, ; // �ਧ��� ��ᮡ���� �奬� ������⢥���� �࠯��: 0-��ଠ�쭮, 1-�� ᮡ���
    mIS_ERR_vmp, m1is_err_vmp := 0, ;
    _arr_sh := ret_arr_shema( 1, MK_DATA ),  _arr_mt := ret_arr_shema( 2, MK_DATA ),  _arr_fr := ret_arr_shema( 3, MK_DATA ), ;
    mm_usl_tip := AClone( getn013() ) // N013

  mm_usl_tip := hb_AIns( mm_usl_tip, 1, { '�� �஢�������', 0 }, .t. )

  mm_USL_TIP_all := AClone( mm_USL_TIP )
  ASize( mm_USL_TIP, 6 ) // ��� �������⨪�
  //
  AFill( adiag_talon, 0 )
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
      MUCH_DOC := PadR( amb_kartan(), 10 )
    Elseif mem_kodkrt == 2
      MUCH_DOC := PadR( lstr( mkod_k ), 10 )
    Endif
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 1, , .t. ) // ������ � �������
    Endif
    // �஢�ઠ ��室� = ������
    Select HUMAN
    Set Index to ( dir_server() + 'humankk' )
    //
    a_smert := arr_patient_died_during_treatment( mkod_k, loc_kod )
    //
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
    mUCH_DOC    := human->uch_doc
    m1reg_lech  := human->reg_lech
    m1VRACH     := human_->vrach
    MKOD_DIAG0  := human_->KOD_DIAG0
    MKOD_DIAG   := human->KOD_DIAG
    MKOD_DIAG2  := human->KOD_DIAG2
    MKOD_DIAG3  := human->KOD_DIAG3
    MKOD_DIAG4  := human->KOD_DIAG4
    MSOPUT_B1   := human->SOPUT_B1
    MSOPUT_B2   := human->SOPUT_B2
    MSOPUT_B3   := human->SOPUT_B3
    MSOPUT_B4   := human->SOPUT_B4
    MDIAG_PLUS  := human->DIAG_PLUS
    MPOLIS      := human->POLIS         // ��� � ����� ���客��� �����
    If human->OBRASHEN == '1'
      m1DS_ONK := 1
    Endif
    For i := 1 To 16
      adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
    Next
    mstatus_st  := human_->STATUS_ST
    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    If Empty( Val( msmo := human_->SMO ) )
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    Else
      m1komu := m1str_crb := 0
    Endif
    If human_->NOVOR > 0
      m1novor := 1
      mcount_reb := human_->NOVOR
      mDATE_R2 := human_->DATE_R2
      mpol2 := human_->POL2
    Endif
    m1okato    := human_->OKATO  // ����� ��ꥪ� �� ����ਨ ���客����
    m1USL_OK   := human_->USL_OK
    m1PROFIL   := human_->PROFIL
    m1PROFIL_K := human_2->PROFIL_K
    m1NPR_MO   := human_->NPR_MO
    mNPR_DATE  := human_2->NPR_DATE
    M1F14_EKST := Int( Val( SubStr( human_->FORMA14, 1, 1 ) ) )
    M1F14_SKOR := Int( Val( SubStr( human_->FORMA14, 2, 1 ) ) )
    M1F14_VSKR := Int( Val( SubStr( human_->FORMA14, 3, 1 ) ) )
    M1F14_RASH := Int( Val( SubStr( human_->FORMA14, 4, 1 ) ) )
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    m1povod    := human_->POVOD
    m1travma   := human_->TRAVMA
    m1rslt     := human_->RSLT_NEW
    m1ishod    := human_->ISHOD_NEW
    M1BOLNICH  := human->BOLNICH
    If m1bolnich > 0
      MDATE_B_1 := c4tod( human->DATE_B_1 )
      MDATE_B_2 := c4tod( human->DATE_B_2 )
      If m1bolnich == 2
        mrodit_dr  := human_->RODIT_DR
        mrodit_pol := human_->RODIT_POL
      Endif
    Endif
    mcena_1 := human->CENA_1
    //
    m1ad_cr := human_2->PC3
    m1P_PER := human_2->P_PER
    MOSL1 := human_2->OSL1
    MOSL2 := human_2->OSL2
    MOSL3 := human_2->OSL3
    M1VMP := human_2->VMP
    M1VIDVMP := human_2->VIDVMP
    M1METVMP := human_2->METVMP
    m1modpac := human_2->PN5
    mTAL_NUM := human_2->TAL_NUM
    mTAL_D := human_2->TAL_D
    mTAL_P := human_2->TAL_P
    MVNR  := iif( human_2->VNR  > 0, PadR( lstr( human_2->VNR ), 4 ),  Space( 4 ) )
    MVNR1 := iif( human_2->VNR1 > 0, PadR( lstr( human_2->VNR1 ), 4 ),  Space( 4 ) )
    MVNR2 := iif( human_2->VNR2 > 0, PadR( lstr( human_2->VNR2 ), 4 ),  Space( 4 ) )
    MVNR3 := iif( human_2->VNR3 > 0, PadR( lstr( human_2->VNR3 ), 4 ),  Space( 4 ) )
    m1vid_reab := human_2->PN1
    m1NMSE := human_2->PN6

    mWeight := iif( Empty( human_2->PC4 ),  0, Val( human_2->PC4 ) )

    If ( ibrm := f_oms_beremenn( mkod_diag, MK_DATA ) ) > 0
      m1prer_b := human_2->PN2
    Endif
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 2, @rec_inogSMO, .t. ) // ������ � �������
    Endif
    If eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) .and. is_task( X_PPOKOJ ) ;
        .and. !Empty( mUCH_DOC ) .and. mem_e_istbol == 1
      r_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_h',  'PP' )
      find ( Str( Loc_kod, 7 ) )
      If Found()
        when_uch_doc := .f.  // ����� �������� ����� ���ਨ �������
      Endif
    Endif
    is_oncology := f_is_oncology( 2 )
    If is_oncology > 0 // ��������� - ���ࠢ�����
      count_napr := collect_napr_zno( Loc_kod )
      If count_napr > 0
        old_oncology := .t.
        cur_napr := 1 // �� ।-�� - ᭠砫� ��ࢮ� ���ࠢ����� ⥪�饥
      Endif
      mnapr_onk := '������⢮ ���ࠢ����� - ' + lstr( count_napr )

      r_use( dir_server() + 'mo_onkco', dir_server() + 'mo_onkco',  'CO' )
      find ( Str( Loc_kod, 7 ) )
      If Found()
        m1PR_CONS := co->pr_cons
        mDT_CONS := co->dt_cons
      Endif
    Endif
    If is_oncology == 2 // ���������
      r_use( dir_server() + 'mo_onksl', dir_server() + 'mo_onksl',  'SL' )
      find ( Str( Loc_kod, 7 ) )
      If Found()
        old_oncology := .t.
        m1DS1_T := sl->DS1_T
        m1STAD := sl->STAD
        m1ONK_T := sl->ONK_T
        m1ONK_N := sl->ONK_N
        m1ONK_M := sl->ONK_M
        m1MTSTZ := sl->MTSTZ
        m1B_DIAG := sl->b_diag
        If sl->k_fr > 0
          mK_FR := PadR( lstr( sl->k_fr ), 2 )
        Endif
        m1crit := sl->crit
        m1is_err := sl->is_err
        If sl->WEI > 0
          mWEI := PadR( AllTrim( str_0( sl->WEI, 5, 1 ) ), 5 )
        Endif
        If sl->HEI > 0
          mHEI := PadR( lstr( sl->HEI ), 3 )
        Endif
        If sl->BSA > 0 
          mBSA := PadR( AllTrim( str_0( sl->BSA, 4, 2 ) ), 4 )
        Endif
      Endif
      is_gisto := ( m1usl_ok == USL_OK_POLYCLINIC .and. m1profil == 15 )  // ����������� + ��䨫� = ���⮫����
      i := j := 0
      Use ( cur_dir() + 'tmp_onkdi' ) New Alias TDIAG
      r_use( dir_server() + 'mo_onkdi', dir_server() + 'mo_onkdi',  'DIAG' ) // ���������᪨� ����
      find ( Str( Loc_kod, 7 ) )
      Do While diag->kod == Loc_kod .and. !Eof()
        old_oncology := .t.
        mDIAG_DATE := diag->DIAG_DATE
        Select TDIAG
        Append Blank
        tdiag->DIAG_DATE := diag->DIAG_DATE
        tdiag->DIAG_TIP  := diag->DIAG_TIP
        tdiag->DIAG_CODE := diag->DIAG_CODE
        tdiag->DIAG_RSLT := diag->DIAG_RSLT
        If diag->DIAG_TIP == 1 // ���⮫����᪨� �ਧ���
          If is_gisto .and. ( k := AScan( arr_rez_gist, {| x| x[ 2 ] == diag->DIAG_CODE } ) ) > 0
            arr_rez_gist[ k, 4 ] := diag->DIAG_RSLT
          Endif
          If++i < 3
            mgist[ i ] := diag->DIAG_CODE
            &( 'm1gist' + lstr( i ) ) := diag->DIAG_RSLT
          Endif
        Elseif diag->DIAG_TIP == 2 // ����� (���)
          If++j < 6
            mmark[ j ] := diag->DIAG_CODE
            &( 'm1mark' + lstr( j ) ) := diag->DIAG_RSLT
          Endif
        Endif
        Select DIAG
        Skip
      Enddo
      Use ( cur_dir() + 'tmp_onkpr' ) New Alias TPR
      r_use( dir_server() + 'mo_onkpr', dir_server() + 'mo_onkpr',  'PR' ) // �������� �� �������� ��⨢�����������
      find ( Str( Loc_kod, 7 ) )
      Do While pr->kod == Loc_kod .and. !Eof()
        If Between( pr->PROT, 1, 6 )
          old_oncology := .t.
          Select TPR
          Append Blank
          tpr->PROT := pr->PROT
          tpr->D_PROT := pr->D_PROT
        Endif
        Select PR
        Skip
      Enddo
      Use ( cur_dir() + 'tmp_onkus' ) New Alias TMPOU
      r_use( dir_server() + 'mo_onkus', dir_server() + 'mo_onkus',  'OU' ) // �������� � �஢����� ��祭���
      find ( Str( Loc_kod, 7 ) )
      Do While ou->kod == Loc_kod .and. !Eof()
        Select TMPOU
        Append Blank
        tmpou->USL_TIP   := ou->USL_TIP
        tmpou->HIR_TIP   := ou->HIR_TIP
        tmpou->LEK_TIP_L := ou->LEK_TIP_L
        tmpou->LEK_TIP_V := ou->LEK_TIP_V
        tmpou->LUCH_TIP  := ou->LUCH_TIP
        tmpou->SOD       := iif( eq_any( ou->USL_TIP, 3, 4 ), sl->sod, 0 )
        tmpou->PPTR      := iif( eq_any( ou->USL_TIP, 2, 4 ), ou->PPTR, 0 )
        Select OU
        Skip
      Enddo
      Select TMPOU
      If LastRec() == 0
        Append Blank
      Endif
      Use ( cur_dir() + 'tmp_onkle' ) New Alias TMPLE
      r_use( dir_server() + 'mo_onkle', dir_server() + 'mo_onkle',  'LE' ) // �������� � �ਬ����� ������⢥���� �९����
      find ( Str( Loc_kod, 7 ) )
      Do While le->kod == Loc_kod .and. !Eof()
        Select TMPLE
        Append Blank
        tmple->REGNUM   := le->REGNUM
        tmple->CODE_SH  := le->CODE_SH
        tmple->DATE_INJ := le->DATE_INJ
        Select LE
        Skip
      Enddo
    Endif
  Endif
  If !( Left( msmo, 2 ) == '34' ) // �� ������ࠤ᪠� �������
    m1ismo := msmo ; msmo := '34'
  Endif
  If Loc_kod == 0
    r_use( dir_server() + 'mo_otd', , 'OTD' )
    Goto ( m1otd )
    m1USL_OK := otd->IDUMP
    If Empty( m1PROFIL )
      m1PROFIL := otd->PROFIL
    Endif
    If Empty( m1PROFIL_K )
      m1PROFIL_K := otd->PROFIL_K
    Endif
  Endif
  r_use( dir_server() + 'mo_uch', , 'UCH' )
  Goto ( m1lpu )
  is_talon := .t. // (uch->IS_TALON == 1)
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
  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  If Empty( m1USL_OK )
    m1USL_OK := USL_OK_HOSPITAL
  Endif // �� ��直� ��砩
  mUSL_OK   := inieditspr( A__MENUVERT, getv006(), m1USL_OK )
  If eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
    If !Between( m1p_per, 1, 4 )
      m1p_per := 1
    Endif
    mp_per := inieditspr( A__MENUVERT, mm_p_per, m1p_per )
  Endif
  mPROFIL   := inieditspr( A__MENUVERT, getv002(), m1PROFIL )
  mPROFIL_K := inieditspr( A__MENUVERT, getv020(),  m1PROFIL_K )
  mvid_reab := inieditspr( A__MENUVERT, mm_vid_reab, m1vid_reab )
  If !Empty( m1NPR_MO )
    mNPR_MO := ret_mo( m1NPR_MO )[ _MO_SHORT_NAME ]
  Endif
  mDS_ONK   := inieditspr( A__MENUVERT, mm_danet, M1DS_ONK )
  MVMP      := inieditspr( A__MENUVERT, mm_danet, M1VMP )
  MVIDVMP   := ret_v018( M1VIDVMP, mk_data )
  MMETVMP   := ret_v019( M1METVMP, M1VIDVMP, mk_data )
  mmodpac   := ret_v022( m1modpac, mk_data )
  mreg_lech := inieditspr( A__MENUVERT, mm_reg_lech, m1reg_lech )
  MNOVOR    := inieditspr( A__MENUVERT, mm_danet, M1NOVOR )
  MF14_EKST := inieditspr( A__MENUVERT, mm_ekst, M1F14_EKST )
  MF14_SKOR := inieditspr( A__MENUVERT, mm_danet, M1F14_SKOR )
  MF14_VSKR := inieditspr( A__MENUVERT, mm_vskrytie, M1F14_VSKR )
  MF14_RASH := inieditspr( A__MENUVERT, mm_danet, M1F14_RASH )
  mrslt     := inieditspr( A__MENUVERT, getv009(), m1rslt )
  mishod    := inieditspr( A__MENUVERT, getv012(), m1ishod )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mbolnich  := inieditspr( A__MENUVERT, menu_bolnich, m1bolnich )
  mNMSE     := inieditspr( A__MENUVERT, arr_NO_YES(), m1NMSE )
  // mpovod    := inieditspr(A__MENUVERT, stm_povod, m1povod)
  // mtravma   := inieditspr(A__MENUVERT, stm_travma, m1travma)
  motd      := inieditspr( A__POPUPMENU, dir_server() + 'mo_otd',  m1otd )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
  mismo     := init_ismo( m1ismo )
  If ibrm > 0
    mm_prer_b := iif( ibrm == 1, mm1prer_b, iif( ibrm == 2, mm2prer_b, mm3prer_b ) )
    If ibrm == 1 .and. m1prer_b == 0
      mprer_b := Space( 28 )
    Else
      mprer_b := inieditspr( A__MENUVERT, mm_prer_b, m1prer_b )
    Endif
  Endif
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
  str_1 := ' ���� (���� ����)'
  If Loc_kod == 0
    str_1 := '����������' + str_1
    mtip_h := yes_vypisan
  Else
    str_1 := '������஢����' + str_1
  Endif
  If yes_vypisan == B_END
    If Loc_kod == 0
      mtip_h += m1_l_z
    Else
      m1_l_z := mtip_h - B_END
    Endif
    m_l_z := inieditspr( A__MENUVERT, mm_danet, m1_l_z )
  Endif
  pr_1_str( str_1 )
  SetColor( color8 )
  myclear( 1 )

  Private gl_area := { 1, 0, MaxRow() -1, MaxCol(), 0 }, ;
    p_nstr_vnr, p_str_vnr, p_str_vnrm, p_nstr_ad_cr, p_str_ad_cr // p_nstr_stent, p_str_stent

  SetColor( cDataCGet )
  make_diagp( 1 )  // ᤥ���� '��⨧����' ��������
  f_valid_usl_ok(, -1 )
  f_valid2ad_cr( MK_DATA )  // ����稬 �������⥫�� ���ਨ �� ���� ����砭�� ��祭��

  Private rdiag := 1, rpp := 1, num_screen := 1, is_onko_VMP := .f.

  Do While .t.
    If num_screen == 1
      SetMode( kscr1, 80 )
      pr_1_str( str_1 )
      j := 1
      myclear( j )
      If yes_num_lu == 1 .and. Loc_kod > 0
        @ j, 50 Say PadL( '���� ��� � ' + lstr( Loc_kod ), 29 ) Color color14
      Endif
      diag_screen( 0 )
      pos_read := 0
      put_dop_diag( 0 )
      @ ++j, 1 Say '��०�����' Get mlpu When .f. Color cDataCSay
      @ Row(), Col() + 2 Say '�⤥�����' Get motd When .f. Color cDataCSay
      //
      @ ++j, 1 Say '���' Get mfio_kart ;
        reader {| x| menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
        valid {| g, o| update_get( 'mkomu' ), update_get( 'mcompany' ), ;
        update_get( 'mspolis' ), update_get( 'mnpolis' ), ;
        update_get( 'mvidpolis' ) }
      //
      @ ++j, 1 Say '���ࠢ�����: ���' Get mNPR_DATE
      @ j, Col() + 1 Say '�� ��' Get mNPR_MO ;
        reader {| x| menu_reader( x, { {| k, r, c| f_get_mo( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
        Color colget_menu
      //
      @ ++j, 1 Say '����஦�����?' Get mnovor ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        valid {| g, o| f_valid_novor( g, o ) } ;
        Color colget_menu
      @ Row(), Col() + 3 Say '�/�� ॡ񭪠' Get mcount_reb Pict '99' Range 1, 99 ;
        when ( m1novor == 1 )
      @ Row(), Col() + 3 Say '�.�. ॡ񭪠' Get mdate_r2 when ( m1novor == 1 )
      If mem_pol == 1
        @ Row(), Col() + 3 Say '��� ॡ񭪠' Get mpol2 ;
          reader {| x| menu_reader( x, menupol, A__MENUVERT, , , .f. ) } ;
          when ( m1novor == 1 )
      Else
        @ Row(), Col() + 3 Say '��� ॡ񭪠' Get mpol2 Pict '@!' ;
          valid {| g| mpol2 $ '��' } ;
          when ( m1novor == 1 )
      Endif
      //
      @ ++j, 1 Say '�ப� ��祭��' Get mn_data valid {| g| f_k_data( g, 1 ) }
      @ Row(), Col() + 1 Say '-'   Get mk_data valid {| g| f_k_data( g, 2 ) }
      @ Row(), Col() + 3 Get mvzros_reb When .f. Color cDataCSay
      If yes_vypisan == B_END
        @ Row(), Col() + 5 Say ' ��祭�� �����襭�?' Color 'G+/B'
        @ Row(), Col() + 1 Get m_l_z ;
          reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
          Color 'GR+/B'
      Endif
      //
      @ ++j, 1 Say '� ���.����� (���ਨ)' Get much_doc Picture '@!' ;
        When when_uch_doc
      @ Row(), Col() + 1 Say '���' Get MTAB_NOM Pict '99999' ;
        valid {| g| v_kart_vrach( g, .t. ) } When diag_screen( 2 )
      @ Row(), Col() + 1 Get mvrach When .f. Color color14
      //
      @ ++j, 1 Say '��� ��樥��' Get mWeight Picture '999.9' ;
        valid {| g | check_edit_field( g, 2, 1 ) }
      @ j, Col() + 1 Say '��.'

      @ j, Col() + 5 Say '��ࢨ�� �������' Get mkod_diag0 Picture pic_diag reader {| o| mygetreader( o, bg ) } Valid val1_10diag( .t., .f., .t., mk_data, iif( m1novor == 0, mpol, mpol2 ) ) ;
        When diag_screen( 2 ) .and. when_diag()
      ++j
      
      rdiag := j
      @ j, 1 Say '�᭮���� �������' Get mkod_diag Picture pic_diag ;
        reader {| o| mygetreader( o, bg ) } ;
        When when_diag() ;
        valid {|| val1_10diag( .t., .t., .t., mk_data, iif( m1novor == 0, mpol, mpol2 ) ),  f_valid_beremenn( mkod_diag, mk_data ) }

      If ( ibrm := f_oms_beremenn( mkod_diag, MK_DATA ) ) == 1
        @ j, 26 Say '���뢠��� ��६������'
      Elseif ibrm == 2
        @ j, 26 Say '���.����.�� ��६�����'
      Elseif ibrm == 3
        @ j, 26 Say '     ���� �� ���������'
      Endif
      @ j, 51 Get mprer_b ;
        reader {| x| menu_reader( x, mm_prer_b, A__MENUVERT, , , .f. ) } ;
        when {|| ibrm := f_oms_beremenn( mkod_diag, MK_DATA ), ;
        mm_prer_b := iif( ibrm == 1, mm1prer_b, iif( ibrm == 2, mm2prer_b, mm3prer_b ) ), ;
        ( ibrm > 0 ) }
      //
      ++j
      @ j, 1 Say '���������騥 �������� ' Get mkod_diag2 Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .t., .t., mk_data, iif( m1novor == 0, mpol, mpol2 ) )
      @ Row(), Col() Say ',' Get mkod_diag3 Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .t., .t., mk_data, iif( m1novor == 0, mpol, mpol2 ) )
      @ Row(), Col() Say ',' Get mkod_diag4 Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .t., .t., mk_data, iif( m1novor == 0, mpol, mpol2 ) )
      @ Row(), Col() Say ',' Get msoput_b1  Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .t., .t., mk_data, iif( m1novor == 0, mpol, mpol2 ) )
      @ Row(), Col() Say ',' Get msoput_b2  Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .t., .t., mk_data, iif( m1novor == 0, mpol, mpol2 ) )
      @ Row(), Col() Say ',' Get msoput_b3  Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .t., .t., mk_data, iif( m1novor == 0, mpol, mpol2 ) )
      @ Row(), Col() Say ',' Get msoput_b4  Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .t., .t., mk_data, iif( m1novor == 0, mpol, mpol2 ) )

      ++j
      @ j, 1 Say '�������� �᫮������   ' Get mosl1 Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .f., .t., mk_data, iif( m1novor == 0, mpol, mpol2 ) )
      @ Row(), Col() Say ','            Get mosl2 Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .f., .t., mk_data, iif( m1novor == 0, mpol, mpol2 ) )
      @ Row(), Col() Say ','            Get mosl3 Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .f., .t., mk_data, iif( m1novor == 0, mpol, mpol2 ) )
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
      @ Row(), Col() + 3 Say '�����' Get mnpolis When m1komu == 0
      @ Row(), Col() + 3 Say '���'   Get mvidpolis ;
        reader {| x| menu_reader( x, mm_vid_polis, A__MENUVERT, , , .f. ) } ;
        When m1komu == 0 ;
        Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
      //
      ++j
      rpp := j
      @ j, 1 Say '���.������: �᫮��� ��������' Get MUSL_OK ;
        reader {| x| menu_reader( x, tmp_V006, A__MENUVERT, , , .f. ) } ;
        When diag_screen( 2 ) ;
        valid {| g, o| iif( eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ), ;
        ( SetPos( rpp, 40 ),  DispOut( '�ਧ���', cDataCGet ) ), ;
        ( mp_per := Space( 25 ), m1p_per := 0 ) ), ;
        update_get( 'mp_per' ),  f_valid_usl_ok( g, o )  }
      If eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
        @ j, 40 Say '�ਧ���'
      Endif
      @ j, 48 Get mp_per ;
        reader {| x| menu_reader( x, mm_p_per, A__MENUVERT, , , .f. ) } ;
        When eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
      If is_dop_ob_em
        @ ++j, 3 Say '��� ���񬮢 ᯥ樠����஢����� ����樭᪮� �����' Get mreg_lech ;
          reader {| x| menu_reader( x, mm_reg_lech, A__MENUVERT, , , .f. ) } ;
          When eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
      Endif
      @ ++j, 3 Say '��䨫� ���.�����' Get MPROFIL ;
        reader {| x| menu_reader( x, tmp_V002, A__MENUVERT, , , .f. ) } ;
        Valid f_valid2ad_cr( MK_DATA )
      @ ++j, 3 Say '��䨫� �����' Get MPROFIL_K ;
        reader {| x| menu_reader( x, tmp_V020, A__MENUVERT, , , .f. ) } ;
        When eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
      If is_reabil_slux
        @ ++j, 3 Say '��� ���.ॠ�����樨' Get mvid_reab ;
          reader {| x| menu_reader( x, mm_vid_reab, A__MENUVERT, , , .f. ) } ;
          When eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) .and. m1profil == 158
      Endif
      //
      @ ++j, 1 Say '������� ���饭��' Get mrslt ;
        reader {| x| menu_reader( x, mm_rslt, A__MENUVERT, , , .f. ) } ;
        valid {| g, o| f_valid_rslt( g, o ) }
      //
      @ ++j, 1 Say '��室 �����������' Get mishod ;
        reader {| x| menu_reader( x, mm_ishod, A__MENUVERT, , , .f. ) }

      @ j, 42 Say '���ࠢ����� �� ���' Get mNMSE ;
        reader {| x| menu_reader( x, arr_NO_YES(), A__MENUVERT, , , .f. ) } ;
        Color colget_menu

      //
      @ ++j, 1 Say '��ᯨ⠫���஢��' Get MF14_EKST ;
        reader {| x| menu_reader( x, mm_ekst, A__MENUVERT, , , .f. ) } ;
        valid {| g, o| f_valid_f14_ekst( g, o ) }
      @ Row(), Col() + 3 Say '���⠢��� ᪮ன �������' Get MF14_SKOR ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        When M1F14_EKST == 1
      @ ++j, 3 Say '����⨥' Get MF14_VSKR ;
        reader {| x| menu_reader( x, mm_vskrytie, A__MENUVERT, , , .f. ) } ;
        When is_death( m1RSLT )
      @ Row(), Col() + 3 Say '��⠭������ ��宦����� ���������' Get MF14_RASH ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        When M1F14_VSKR > 0
      /*++j
      if is_talon
        if mem_st_pov == 1
          @ j, 1 say '����� ���饭��' get mpovod ;
              reader {|x|menu_reader(x,stm_povod, A__MENUVERT, , , .f.)} ;
              color colget_menu
        else
          @ j, 1 say '����� ���饭��' get m1povod pict '9' ;
              valid {|g| val_st_pov(g) }
          @ row(), col() + 1 get mpovod color color14 when .f.
        endif
        if .t.//is_travma // �᫨ � ����ன�� ��� �⤥����� - ࠡ�� � �ࠢ���
          if mem_st_trav == 1
            @ j, 43 say '��� �ࠢ��' get mtravma ;
                reader {|x|menu_reader(x,stm_travma, A__MENUVERT, , , .f.)} ;
                color colget_menu
          else
            @ j, 43 say '��� �ࠢ��' get m1travma pict '99' ;
                valid {|g| val_st_trav(g) }
            @ row(), col() + 1 get mtravma color color14 when .f.
          endif
        endif
      endif*/
      ++j
      p_nstr_vnr := j
      p_str_vnr := '��� ॡ񭪠 � �ࠬ��� (����� ���� ⥫�/������襭��)   '
      @ j, 1 Say p_str_vnr Get MVNR Pict '9999' When input_vnr
      If Empty( MVNR )
        @ j, 1
      Endif
      p_str_vnrm := '��� த������ ��⥩ � �ࠬ��� (����� ����/������襭��)   '
      @ j, 1 Say p_str_vnrm Get MVNR1 Pict '9999' When input_vnrm
      @ Row(), Col() + 1 Get MVNR2 Pict '9999' When input_vnrm
      @ Row(), Col() + 1 Get MVNR3 Pict '9999' When input_vnrm
      If emptyall( MVNR1, MVNR2, MVNR3 )
        @ j, 1
      Endif
      //
      if M1USL_OK == USL_OK_HOSPITAL .or. M1USL_OK == USL_OK_DAY_HOSPITAL
        ++j
        p_nstr_ad_cr := j
        p_str_ad_cr := '���.���਩'
        @ p_nstr_ad_cr, 1 Say p_str_ad_cr Get MAD_CR ;
          reader {| x| menu_reader( x, mm_ad_cr, A__MENUVERT_SPACE, , , .f. ) } ;
          When input_ad_cr ;
          Color colget_menu
        If !input_ad_cr
          @ j, 1
        Endif
      endif
      //
      If is_MO_VMP .and. M1USL_OK == USL_OK_HOSPITAL
        @ ++j, 1 Say '���?' Get MVMP ;
          reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
          When m1usl_ok == USL_OK_HOSPITAL ;
          valid {| g, o| f_valid_vmp( g, o ) } ;
          Color colget_menu
        @ j, Col() + 1 Say '� ⠫���' Get mTAL_NUM Picture iif( MK_DATA >= 0d20220101, newPictureTalon, oldPictureTalon ) ;
          valid {| g| valid_number_talon( g, mk_data, .t. ) } ;
          When m1vmp == 1
        @ j, Col() + 1 Say '�뤠�' Get mTAL_D When m1vmp == 1
        @ j, Col() + 1 Say '����. ���-��' Get mTAL_P When m1vmp == 1
        @ ++j, 1 Say ' ��� ���' Get mvidvmp ;
          reader {| x| menu_reader( x, { {| k, r, c| f_get_vidvmp( k, r, c, mkod_diag ) } }, A__FUNCTION, , , .f. ) } ;
          When m1vmp == 1 ;
          valid {| g, o| f_valid_vidvmp( g, o ) } ;
          Color colget_menu
        @ ++j, 1 Say ' ������' Get mmodpac ;
          reader {| x| menu_reader( x, { {| k, r, c| f_get_mmodpac( k, r, c, m1vidvmp, mkod_diag ) } }, A__FUNCTION, , , .f. ) } ;
          When m1vmp == 1 Color colget_menu
        @ ++j, 1 Say ' ��⮤ ���' Get mmetvmp ;
          reader {| x| menu_reader( x, { {| k, r, c| f_get_metvmp( k, r, c, m1vidvmp, m1modpac ) } }, A__FUNCTION, , , .f. ) } ;
          When m1vmp == 1 .and. !Empty( m1vidvmp ) Color colget_menu
      Endif
      //
      @ ++j, 1 Say '���쭨��' Get mbolnich ;
        reader {| x| menu_reader( x, menu_bolnich, A__MENUVERT, , , .f. ) } ;
        Color colget_menu ;
        valid {| g, o| f_valid_bolnich( g, o ) }
      @ Row(),  Col() + 1 Say '==> �' Get mdate_b_1 When m1bolnich > 0
      @ Row(),  Col() + 1 Say '��' Get mdate_b_2 When m1bolnich > 0
      @ Row(),  Col() + 1 Say '�.�.த�⥫�' Get mrodit_dr When m1bolnich == 2
      If mem_pol == 1
        @ Row(),  Col() + 1 Say '���' Get mrodit_pol ;
          reader {| x| menu_reader( x, menupol, A__MENUVERT, , , .f. ) } ;
          When m1bolnich == 2
      Else
        @ Row(), Col() + 1 Say '���' Get mrodit_pol Pict '@!' ;
          valid {| g| mrodit_pol $ '��' } ;
          When m1bolnich == 2
      Endif
      @ ++j, 1 Say '�ਧ��� �����७�� �� ���' Get mDS_ONK ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
        when {|| when_ds_onk() } ;
        Color colget_menu

      @ MaxRow() -1, 55 Say '�㬬� ��祭��' Color color1
      @ Row(), Col() + 1 Say lput_kop( mcena_1 ) Color color8
      If is_talon
        Set Key K_F10 To inp_dop_diag
      Endif
      If !Empty( a_smert )
        n_message( a_smert, , 'GR+/R',  'W+/R', , , 'G+/R' )
      Endif

      If pos_read > 0
        If Lower( GetList[ pos_read ]:name ) == 'mds_onk'
          --pos_read
        Endif
        If Lower( GetList[ pos_read ]:name ) == 'mrodit_pol'
          --pos_read
        Endif
        If Lower( GetList[ pos_read ]:name ) == 'mrodit_dr'
          --pos_read
        Endif
        If Lower( GetList[ pos_read ]:name ) == 'mdate_b_2'
          --pos_read
        Endif
        If Lower( GetList[ pos_read ]:name ) == 'mdate_b_1'
          --pos_read
        Endif
      Endif
      @ MaxRow(), 0 Say PadC( '<Esc> - ��室;  <PgDn> - ������;  <F1> - ������', MaxCol() + 1 ) Color color0
      mark_keys( { '<F1>',  '<Esc>',  '<PgDn>' }, 'R/BG' )
      // ///////////////////////////////////////////////////////////////////////////////
    Elseif num_screen == 2
      use_base( 'luslf' )
      use_base( 'mo_su' )
      tip_onko_napr := 0
      If is_oncology == 2 .or. is_VOLGAMEDLAB()
        is_mgi := .f.
        lshifr := ''
        If Loc_kod > 0 // ।���஢����
          r_use( dir_server() + 'uslugi', , 'USL' )
          r_use_base( 'human_u' )
          find ( Str( Loc_kod, 7 ) )
          Do While hu->kod == Loc_kod .and. !Eof()
            usl->( dbGoto( hu->u_kod ) )
            If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
              lshifr := usl->shifr
            Endif
            lshifr := AllTrim( lshifr )
            If Left( lshifr, 5 ) == '60.9.'  // ���
              is_mgi := .t.
              Exit
            Endif
            Select HU
            Skip
          Enddo
        Endif
        For i := 1 To 6
          &( 'm1prot' + lstr( i ) ) := 0
          &( 'mdprot' + lstr( i ) ) := CToD( '' )
        Next
        Use ( cur_dir() + 'tmp_onkpr' ) New Alias TPR
        Go Top
        Do While !Eof()
          &( 'm1prot' + lstr( tpr->prot ) ) := 1
          &( 'mdprot' + lstr( tpr->prot ) ) := tpr->d_prot
          Skip
        Enddo
        For i := 1 To 6
          &( 'mprot' + lstr( i ) ) := inieditspr( A__MENUVERT, mm_danet, &( 'm1prot' + lstr( i ) ) )
        Next
        mPR_CONS := inieditspr( A__MENUVERT, mm_PR_CONS, m1PR_CONS )
        //
        lmm_DS1_T := AClone( mm_DS1_T )
        If eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) // m1usl_ok < 3
          del_array( lmm_DS1_T, 5 ) // 㤠��� ��ᯠ��୮� �������
          del_array( lmm_DS1_T, 4 ) // 㤠��� �������᪮� �������
        Else
          del_array( lmm_DS1_T, 1 ) // 㤠�塞 ���� 3 ��ப� (��祭��)
          del_array( lmm_DS1_T, 1 )
          del_array( lmm_DS1_T, 1 )
        Endif
        If AScan( lmm_DS1_T, {| x| x[ 2 ] == m1DS1_T } ) == 0
          m1DS1_T := lmm_DS1_T[ 1, 2 ]
        Endif
        
        mm_N002 := f_define_tnm( 2, mkod_diag, mk_data )
//        mm_N003 := f_define_tnm( 3, mkod_diag, mk_data )
//        mm_N004 := f_define_tnm( 4, mkod_diag, mk_data )
//        mm_N005 := f_define_tnm( 5, mkod_diag, mk_data )

        mDS1_T := inieditspr( A__MENUVERT, mm_DS1_T, m1DS1_T )
        mMTSTZ := inieditspr( A__MENUVERT, mm_danet, m1MTSTZ )
        If Len( mm_N002 ) == 1
          m1STAD := mm_N002[ 1, 2 ]
        Endif
//        If Len( mm_N003 ) == 1
//          m1ONK_T := mm_N003[ 1, 2 ]
//        Endif
//        If Len( mm_N004 ) == 1
//          m1ONK_N := mm_N004[ 1, 2 ]
//        Endif
//        If Len( mm_N005 ) == 1
//          m1ONK_M := mm_N005[ 1, 2 ]
//        Endif
//        mSTAD  := PadR( inieditspr( A__MENUVERT, mm_N002, m1STAD ), 5 )
//        mONK_T := PadR( inieditspr( A__MENUVERT, mm_N003, m1ONK_T ), 5 )
//        mONK_N := PadR( inieditspr( A__MENUVERT, mm_N004, m1ONK_N ), 5 )
//        mONK_M := PadR( inieditspr( A__MENUVERT, mm_N005, m1ONK_M ), 5 )
//        If m1usl_ok == USL_OK_POLYCLINIC
//          mONK_T := mONK_N := mONK_M := Space( 5 )
//          m1ONK_T := m1ONK_N := m1ONK_M := 0
//        Endif
        //
        // ���⮫����
        mm_N009 := {}
        If !is_mgi // ��� ��� ���⮫���� �� ��������
          For i_n009 := 1 To Len( aN009 )
            If between_date( aN009[ i_n009, 4 ], aN009[ i_n009, 5 ], mk_data ) .and. Left( mkod_diag, 3 ) == Left( aN009[ i_n009, 2 ], 3 )
              AAdd( mm_N009, { '', aN009[ i_n009, 3 ], {} } )
            Endif
          Next
          ASort( mm_N009, , , {| x, y| x[ 2 ] < y[ 2 ] } )
        Endif
        If Len( mm_N009 ) > 0
          For i := 1 To Min( 2, Len( mm_N009 ) )
            If ( i_n007 := AScan( aN007, {| x| x[ 2 ] == mm_N009[ i, 2 ] } ) ) > 0
              mm_N009[ i, 1 ] := AllTrim( aN007[ i_n007, 1 ] )
            Else
              func_error( 4, '�� ������ ���⮫����᪨� �ਧ��� ID_MRF=' + lstr( mm_N009[ i, 2 ] ) + ' ��� ' + mkod_diag )
            Endif
            For i_n008 := 1 To Len( aN008 )
              If mm_N009[ i, 2 ] == aN008[ i_n008, 2 ]
                AAdd( mm_N009[ i, 3 ], { AllTrim( aN008[ i_n008, 3 ] ), aN008[ i_n008, 1 ] } )
              Endif
            Next

            If AScan( mm_N009[ i, 3 ], {| x| x[ 2 ] == &( 'm1gist' + lstr( i ) ) } ) == 0
              &( 'm1gist' + lstr( i ) ) := 0
            Endif
            &( 'mgist' + lstr( i ) ) := inieditspr( A__MENUVERT, mm_N009[ i, 3 ], &( 'm1gist' + lstr( i ) ) )
          Next
        Endif

        // ���㭮����娬��
        mm_N012 := {}
        If ( it := AScan( aN012_DS, {| x| Left( x[ 1 ], 3 ) == Left( mkod_diag, 3 ) } ) ) > 0
          ar_N012 := AClone( aN012_DS[ it, 2 ] )
          For i_n012 := 1 To Len( ar_N012 )
            AAdd( mm_N012, { '', ar_N012[ i_n012, 1 ], {} } )
          Next
        Endif
        ASort( mm_N012, , , {| x, y| x[ 2 ] < y[ 2 ] } )
        If Len( mm_N012 ) > 0 .and. is_mgi
          If ( i := AScan( glob_MGI, {| x| x[ 1 ] == lshifr } ) ) > 0 // ��㣠 �室�� � ᯨ᮪ �����
            If ( j := AScan( mm_N012, {| x| x[ 2 ] == glob_MGI[ i, 2 ] } ) ) > 0 // �� ������� �������� ��������� ����室��� ��થ�
              tmp_arr := {}
              AAdd( tmp_arr, AClone( mm_N012[ j ] ) )
              mm_N012 := AClone( tmp_arr ) // ��⠢�� � ���ᨢ� ⮫쪮 ���� �㦭� ��� ��થ�
            Else
              mm_N012 := {}
            Endif
          Else
            mm_N012 := {}
          Endif
        Endif
        If Len( mm_N012 ) > 0
          For i := 1 To Min( 5, Len( mm_N012 ) )
            For i_n010 := 1 To Len( aN010 )
              If aN010[ i_n010, 1 ] == mm_N012[ i, 2 ]
                If between_date( aN010[ i_n010, 4 ], aN010[ i_n010, 5 ], mk_data )
                  mm_N012[ i, 1 ] := AllTrim( aN010[ i_n010, 3 ] )
                Endif
              Endif
            Next
            If Empty( mm_N012[ i, 1 ] )
              func_error( 4, '�� ������ �ਧ��� ���㭮����娬�� ID_IGH=' + lstr( mm_N012[ i, 2 ] ) + ' ��� ' + mkod_diag )
            Endif
            For i_n011 := 1 To Len( aN011 )
              If aN011[ i_n011, 2 ] == mm_N012[ i, 2 ]
                If between_date( aN011[ i_n011, 5 ], aN011[ i_n011, 6 ], mk_data )
                  AAdd( mm_N012[ i, 3 ], { aN011[ i_n011, 3 ], aN011[ i_n011, 1 ] } )
                Endif
              Endif
            Next
            If AScan( mm_N012[ i, 3 ], {| x| x[ 2 ] == &( 'm1mark' + lstr( i ) ) } ) == 0
              &( 'm1mark' + lstr( i ) ) := 0
            Endif
            &( 'mmark' + lstr( i ) ) := inieditspr( A__MENUVERT, mm_N012[ i, 3 ], &( 'm1mark' + lstr( i ) ) )
          Next
        Endif
        is_onko_VMP := .f. ; musl1vmp := musl2vmp := mtipvmp := 0
        if eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) .and. m1vmp == 1 .and. m1metvmp > 0
          r_use( dir_exe() + '_mo_ovmp', cur_dir() + '_mo_ovmp',  'OVMP' )
          find ( Str( m1metvmp, 3 ) ) // ����� ��⮤� ���
          If Found()
            is_onko_VMP := .t.
            musl1vmp := ovmp->usl1  // 1-� ��㣠
            musl2vmp := ovmp->usl2  // 2-� ��㣠
            mtipvmp  := ovmp->tip   // 0-�ਬ������ ���� ��㣠, 1-�ਬ������� ��� ��㣨
          Endif
          ovmp->( dbCloseArea() )
        Endif
        //
        mm_N014 := getn014()
        mm_N015 := getn015()
        mm_N016 := getn016()
        mm_N017 := getn017()
        mm_str1 := { '',  '��� ��祭��',  '���� �࠯��',  '��� �࠯��',  '��� �࠯��',  '' }
        lstr1 := Space( 12 )
        m1usl_tip1 := 0
        musl_tip1 := Space( 69 )
        mm_usl_tip1 := {}
        lstr2 := Space( 13 )
        m1usl_tip2 := 0
        musl_tip2 := Space( 19 )
        mm_usl_tip2 := {}
        lstr_sod := ret_str_onc( 1, 2 )
        mvsod := 0
        msod := Space( 6 )
        lstr_fr  := ret_str_onc( 2, 2 )
        lstr_wei := ret_str_onc( 3, 2 )
        lstr_hei := ret_str_onc( 4, 2 )
        lstr_bsa := ret_str_onc( 5, 2 )
        lstr_err := ret_str_onc( 6, 2 )
        mis_err := Space( 11 )
        lstr_she := ret_str_onc( 7, 2 )
        mcrit := Space( 57 )
        lstr_lek := ret_str_onc( 8, 2 )
        mlek := Space( 53 )
        m1lek := Space( 53 )
        lstr_ptr := ret_str_onc( 6, 2 )
        mpptr := Space( 3 )
        //
        lstr_vmp1 := Space( 12 )
        m1usl_vmp1 := 0
        musl_vmp1 := Space( 69 )
        mm_usl_vmp1 := {}
        lstr_vmp2 := Space( 13 )
        m1usl_vmp2 := 0
        musl_vmp2 := Space( 19 )
        mm_usl_vmp2 := {}
        lstr_vmpsod := ret_str_onc( 1, 2 )
        mvsod_vmp := 0
        msod_vmp := Space( 6 )
        lstr_vmpfr  := ret_str_onc( 2, 2 )
        lstr_vmpwei := ret_str_onc( 3, 2 )
        lstr_vmphei := ret_str_onc( 4, 2 )
        lstr_vmpbsa := ret_str_onc( 5, 2 )
        lstr_vmperr := ret_str_onc( 6, 2 )
        lstr_vmpshe := ret_str_onc( 7, 2 )
        lstr_vmplek := ret_str_onc( 8, 2 )
        lstr_vmpptr := ret_str_onc( 6, 2 )
        Use ( cur_dir() + 'tmp_onkus' ) New Alias TMPOU
        Index On Str( usl_tip, 1 ) to ( cur_dir() + 'tmp_onkus' )
        Go Top
        If LastRec() == 0
          Append Blank
        Endif
        m1USL_TIP := tmpou->USL_TIP
        is_gisto := .f.
        m1rez_gist := 0
        kg := 0
        //
        k := 16
        If Len( mm_N009 ) == 0 .and. Len( mm_N012 ) == 0
          If ( is_gisto := ( m1usl_ok == USL_OK_POLYCLINIC .and. m1profil == 15 ) )  // ����������� + ��䨫� = ���⮫����
            AEval( arr_rez_gist, {| x| iif( x[ 4 ] > 0, ++kg, ) } )
            m1rez_gist := iif( kg > 0, 1, 0 )
            mrez_gist := '������⢮ ���⮫���� - ' + lstr( kg )
            mDIAG_DATE := mn_data
            m1B_DIAG := 98
          Endif
          k--
        Elseif only_control_onko( mNPR_MO, mNPR_DATE, m1rslt, m1ishod ) .and. ! is_VOLGAMEDLAB()
          m1B_DIAG := 99 // �� ����
        Else
          If Len( mm_N009 ) == 0
            k++
          Else
            k += Min( 2, Len( mm_N009 ) )
          Endif
          If Len( mm_N012 ) == 0
            k++
          Else
            k += Min( 5, Len( mm_N012 ) )
          Endif
        Endif
        fl_2_4 := fl_3_4 := .f.
        fl2_2_4 := fl2_3_4 := .f.
        If eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) // m1usl_ok < 3 // ��樮��� ��� ������� ��樮���
          If is_onko_VMP
            k += 14
            m1USL_TIP := musl1vmp
            mm_USL_TIP := {}
            If ( i := AScan( mm_USL_TIP_all, {| x| x[ 2 ] == musl1vmp } ) ) > 0
              AAdd( mm_USL_TIP, AClone( mm_USL_TIP_all[ i ] ) )
            Endif
            If mtipvmp == 0 // ���� ��㣠
              If musl2vmp > 0 .and. ( i := AScan( mm_USL_TIP_all, {| x| x[ 2 ] == musl2vmp } ) ) > 0 // ���� ��㣠 �� ����
                AAdd( mm_USL_TIP, AClone( mm_USL_TIP_all[ i ] ) )
              Endif
              If AScan( mm_USL_TIP, {| x| x[ 2 ] == 2 } ) > 0
                fl_2_4 := .t.
                k += 5
              Endif
              If AScan( mm_USL_TIP, {| x| x[ 2 ] == 3 } ) > 0
                fl_3_4 := .t.
                ++k
              Endif
            Else// if mtipvmp == 1 ��� ��㣨
              m1usl_vmp := musl2vmp
              If musl1vmp == 2  // 1-� ��㣠
                fl_2_4 := .t.
                k += 5
              Elseif musl1vmp == 3
                fl_3_4 := .t.
                ++k
              Endif
              k += 3 // ��ப� ������������ � 蠯�� ��� 2-�� ��㣨
              If musl2vmp == 2  // 2-� ��㣠
                fl2_2_4 := .t.
                k += 5
              Elseif musl2vmp == 3
                fl2_3_4 := .t.
                ++k
              Endif
            Endif
          Else // ��� ���
            k += 20
            fl_2_4 := fl_3_4 := .t.
            mm_USL_TIP := AClone( mm_USL_TIP_all )
            // if m1vzros_reb > 0 .or. is_lymphoid(mkod_diag) // �᫨ ॡ񭮪 ��� ��� �஢�⢮ୠ� ��� ���䮨����
            // Del_Array(mm_USL_TIP, 5) // 㤠��� 娬����祢��
            // Del_Array(mm_USL_TIP, 4) // 㤠��� ��祢��
            // endif
          Endif
          If is_onko_VMP .and. mtipvmp == 1 // ��� ��㣨
            mUSL_VMP := inieditspr( A__MENUVERT, mm_USL_TIP_all, m1USL_VMP )
            Select TMPOU
            find ( Str( m1usl_vmp, 1 ) )
            If m1usl_vmp == 2
              m1usl_vmp1 := iif( Found(),  tmpou->LEK_TIP_V, 0 )
              mm_usl_vmp1 := mm_N016
              m1usl_vmp2 := iif( Found(),  tmpou->LEK_TIP_L, 0 )
              mm_usl_vmp2 := mm_N015
              lstr_vmp2 := '����� �࠯��'
              musl_vmp2 := inieditspr( A__MENUVERT, mm_usl_vmp2, m1usl_vmp2 )
              lstr_vmperr := ret_str_onc( 6, 1 )
              mis_err := inieditspr( A__MENUVERT, mm_shema_err, m1is_err )
              lstr_vmpwei := ret_str_onc( 3, 1 )
              lstr_vmphei := ret_str_onc( 4, 1 )
              lstr_vmpbsa := ret_str_onc( 5, 1 )
              lstr_vmpshe := ret_str_onc( 7, 1 )
              mm_shema_usl := _arr_sh

              If !Empty( m1ad_cr ) .and. Left( Lower( m1ad_cr ), 5 ) == 'gemop' // ��᫥ ࠧ����� � �.�.��⮭���� 13.01.23
                mcrit := mad_cr
              Else
                mcrit := inieditspr( A__MENUVERT, mm_shema_usl, m1crit )
              Endif
              lstr_vmplek := ret_str_onc( 8, 1 )
              // mlek := m1lek := init_lek_pr(m1usl_vmp, m1crit)
              mlek := m1lek := init_lek_pr()
              lstr_vmpptr := ret_str_onc( 9, 1 )
              m1pptr := tmpou->pptr
              mpptr := inieditspr( A__MENUVERT, mm_danet, m1pptr )
            Elseif m1usl_vmp == 3
              m1usl_vmp1 := iif( Found(),  tmpou->LUCH_TIP, 0 )
              mm_usl_vmp1 := mm_N017
              mvsod_vmp := iif( Found(),  tmpou->sod, 0 )
              lstr_vmpsod := ret_str_onc( 1, 1 )
              msod_vmp := PadR( AllTrim( str_0( mvsod_vmp, 6, 2 ) ), 6 )
              lstr_vmpfr  := ret_str_onc( 2, 1 )
            Endif
            lstr_vmp1 := PadR( mm_str1[ m1usl_vmp + 1 ], 12 )
            musl_vmp1 := inieditspr( A__MENUVERT, mm_usl_vmp1, m1usl_vmp1 )
          Endif
        Endif
        //
        mUSL_TIP := inieditspr( A__MENUVERT, mm_USL_TIP, m1USL_TIP )
        Select TMPOU
        find ( Str( m1usl_tip, 1 ) )
        If !Found()
          Go Top
        Endif
        If m1usl_tip == 1
          m1usl_tip1 := tmpou->HIR_TIP
          mm_usl_tip1 := mm_N014
        Elseif m1usl_tip == 2
          m1usl_tip1 := tmpou->LEK_TIP_V
          mm_usl_tip1 := mm_N016
          m1usl_tip2 := tmpou->LEK_TIP_L
          mm_usl_tip2 := mm_N015
        Elseif eq_any( m1usl_tip, 3, 4 )
          m1usl_tip1 := tmpou->LUCH_TIP
          mm_usl_tip1 := mm_N017
          mvsod := tmpou->sod
        Endif
        If Between( m1usl_tip, 1, 4 )
          lstr1 := PadR( mm_str1[ m1usl_tip + 1 ], 12 )
          musl_tip1 := inieditspr( A__MENUVERT, mm_usl_tip1, m1usl_tip1 )
          If m1usl_tip == 2
            lstr2 := '����� �࠯��'
            musl_tip2 := inieditspr( A__MENUVERT, mm_usl_tip2, m1usl_tip2 )
            lstr_err := ret_str_onc( 6, 1 )
            mis_err := inieditspr( A__MENUVERT, mm_shema_err, m1is_err )
          Endif
          If eq_any( m1usl_tip, 3, 4 )
            lstr_sod := ret_str_onc( 1, 1 )
            msod := PadR( AllTrim( str_0( mvsod, 6, 2 ) ), 6 )
            lstr_fr  := ret_str_onc( 2, 1 )
          Endif
          If eq_any( m1usl_tip, 2, 4 )
            lstr_wei := ret_str_onc( 3, 1 )
            lstr_hei := ret_str_onc( 4, 1 )
            lstr_bsa := ret_str_onc( 5, 1 )
            lstr_she := ret_str_onc( 7, 1 )
            If Left( m1crit, 2 ) == 'mt' .and. m1usl_tip == 2
              m1crit := Space( 10 )
            Elseif eq_any( Left( m1crit, 2 ),  '��',  'sh' ) .and. m1usl_tip == 4
              m1crit := Space( 10 )
            Endif
            If !Empty( m1ad_cr ) .and. Left( Lower( m1ad_cr ), 5 ) == 'gemop' // ��᫥ ࠧ����� � �.�.��⮭���� 13.01.23
              mm_shema_usl := mm_ad_cr
              m1crit := AllTrim( m1ad_cr )
            Else
              mm_shema_usl := iif( m1usl_tip == 2, _arr_sh, _arr_mt )
            Endif
            mcrit := inieditspr( A__MENUVERT, mm_shema_usl, m1crit )
            lstr_lek := ret_str_onc( 8, 1 )
            // mlek := m1lek := init_lek_pr(m1usl_tip, m1crit)
            mlek := m1lek := init_lek_pr()
            lstr_ptr := ret_str_onc( 9, 1 )
            m1pptr := tmpou->pptr
            mpptr := inieditspr( A__MENUVERT, mm_danet, m1pptr )
          Endif
        Endif
//        mmb_diag := { ;
//          { '�믮����� (१���� ����祭)', 98 }, ;
//          { '�믮����� (१���� �� ����祭)', 97 }, ;
//          { '�믮����� (�� 1 ᥭ���� 2018�.)', -1 }, ;
//          { '�⪠�', 0 }, ;
//          { '�� ��������', 7 }, ;
//          { '��⨢���������', 8 }, ;  // }
//          { '�� ����', 99 } }
        mB_DIAG := inieditspr( A__MENUVERT, mmb_diag(), m1B_DIAG )
      Endif
      // ////////////////////////////////////////////////////////
      SetMode( Max( 25, k ), 80 )
      pr_1_str( '����/।���஢���� ����஫쭮�� ���� ���� ���' )
      j := 1
      myclear( j )
      pos_read := 0
      @ j, 1 Say '��.�������' Color color8 Get mkod_diag When .f.
      If yes_num_lu == 1 .and. Loc_kod > 0
        @ j, 50 Say PadL( '���� ��� � ' + lstr( Loc_kod ), 29 ) Color color14
      Endif
      @ ++j, 1 Say '���' Get mfio_kart When .f.
      @ j, 57 Get mn_data When .f.
      @ Row(), Col() + 1 Say '-' Get mk_data When .f.
      
      // ���ࠢ����� �� ���. ��᫥�������
      If ! only_control_onko( mNPR_MO, mNPR_DATE, m1rslt, m1ishod ) .and. ! is_VOLGAMEDLAB()
        @ ++j, 1 Say '���ࠢ����� �� ���. ��᫥�������' Get mnapr_onk ;
          reader {| x| menu_reader( x, { {| k, r, c| fget_napr_zno( k, r, c ) } }, A__FUNCTION, , , .f. ) }
        ++j
      else
        j++
      Endif

      If is_oncology == 2 .or. is_VOLGAMEDLAB()
        mSTAD  := PadR( inieditspr( A__MENUVERT, mm_N002, m1STAD ), 5 )
        mm_N003 := f_define_tnm( 3, mkod_diag, mk_data, mSTAD )
        mm_N004 := f_define_tnm( 4, mkod_diag, mk_data, mSTAD )
        mm_N005 := f_define_tnm( 5, mkod_diag, mk_data, mSTAD )
        If Len( mm_N003 ) == 1
          m1ONK_T := mm_N003[ 1, 2 ]
        Endif
        If Len( mm_N004 ) == 1
          m1ONK_N := mm_N004[ 1, 2 ]
        Endif
        If Len( mm_N005 ) == 1
          m1ONK_M := mm_N005[ 1, 2 ]
        Endif
        mONK_T := PadR( inieditspr( A__MENUVERT, mm_N003, m1ONK_T ), 5 )
        mONK_N := PadR( inieditspr( A__MENUVERT, mm_N004, m1ONK_N ), 5 )
        mONK_M := PadR( inieditspr( A__MENUVERT, mm_N005, m1ONK_M ), 5 )
        If m1usl_ok == USL_OK_POLYCLINIC
          mONK_T := mONK_N := mONK_M := Space( 5 )
          m1ONK_T := m1ONK_N := m1ONK_M := 0
        Endif
        // ���ᠭ�� ���ﭨ� �� ���������
        @ ++j, 1 Say iif( is_VOLGAMEDLAB(), '�������� � ���������� ����������', '�������� � ������ ������� ��������������� �����������')
        @ ++j, 3 Say '����� ���饭��' Get mDS1_T ;
          reader {| x| menu_reader( x, lmm_DS1_T, A__MENUVERT, , , .f. ) } ;
          Color colget_menu

        if ! only_control_onko( mNPR_MO, mNPR_DATE, m1rslt, m1ishod ) .and. ! is_VOLGAMEDLAB()
          @ ++j, 3 Say '�⠤�� �����������:' Get mSTAD ;
            reader {| x| menu_reader( x, mm_N002, A__MENUVERT, , , .f. ) } ;
            valid {| g| f_valid_tnm( g ),  mSTAD := PadR( mSTAD, 5 ), .t. } ;
            When Between( m1ds1_t, 0, 4 ) ;
            Color colget_menu
          @ j, Col() Say ' Tumor' Get mONK_T ;
            reader {| x| menu_reader( x, f_define_tnm( 3, mkod_diag, mk_data, mSTAD ), A__MENUVERT, , , .f. ) } ;
            valid {| g| f_valid_tnm( g ),  mONK_T := PadR( mONK_T, 5 ), .t. } ;
            When m1ds1_t == 0 .and. m1vzros_reb == 0 ;
            Color colget_menu
//            reader {| x| menu_reader( x, mm_N003, A__MENUVERT, , , .f. ) } ;
          @ j, Col() Say ' Nodus' Get mONK_N ;
            reader {| x| menu_reader( x, f_define_tnm( 4, mkod_diag, mk_data, mSTAD, m1ONK_T ), A__MENUVERT, , , .f. ) } ;
            valid {| g| f_valid_tnm( g ),  mONK_N := PadR( mONK_N, 5 ), .t. } ;
            When m1ds1_t == 0 .and. m1vzros_reb == 0 ;
            Color colget_menu
//            reader {| x| menu_reader( x, mm_N004, A__MENUVERT, , , .f. ) } ;
          @ j, Col() Say ' Metastasis' Get mONK_M ;
            reader {| x| menu_reader( x, f_define_tnm( 5, mkod_diag, mk_data, mSTAD, m1ONK_T, m1ONK_N ), A__MENUVERT, , , .f. ) } ;
            valid {| g| f_valid_tnm( g ),  mONK_M := PadR( mONK_M, 5 ), .t. } ;
            When m1ds1_t == 0 .and. m1vzros_reb == 0 ;
            Color colget_menu
//            reader {| x| menu_reader( x, mm_N005, A__MENUVERT, , , .f. ) } ;
          @ ++j, 5 Say '����稥 �⤠������ ����⠧�� (�� �樤��� ��� �ண���஢����)' Get mMTSTZ ;
            reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
            When eq_any( m1DS1_T, 1, 2 ) ;
            Color colget_menu
        endif

        // �஢������ ���⮫���� ��� ���㭮����娬��
        If ! only_control_onko( mNPR_MO, mNPR_DATE, m1rslt, m1ishod ) .or. is_VOLGAMEDLAB()
          If Len( mm_N009 ) == 0 .and. Len( mm_N012 ) == 0 .and. m1DS1_T != 5
            If is_gisto
              @ ++j, 3 Say '�������� ���⮫����' Get mrez_gist ;
                reader {| x| menu_reader( x, { {| k, r, c| get_rez_gist( k, r, c ) } }, A__FUNCTION, , , .f. ) }
            Else
              @ ++j, 3 Say '���⮫���� / ���㭮����娬��: �� �㦭� ��� ' + iif( is_mgi, '���',  mkod_diag )
            Endif
          Else
            @ ++j, 3 Say '���⮫���� / ���㭮����娬��' Get mB_DIAG ;
              reader {| x| menu_reader( x, mmb_diag(), A__MENUVERT, , , .f. ) }
            @ ++j, 3 Say '��� ����� ���ਠ��' Get mDIAG_DATE ;
              When eq_any( m1b_diag, 97, 98 ) // ;
            If Len( mm_N009 ) == 0
              @ ++j, 3 Say '���⮫����: �� �㦭� ��� ' + iif( is_mgi, '���',  mkod_diag )
            Else
              @ ++j, 3 Say mm_N009[ 1, 1 ] Get mgist1 ;
                reader {| x| menu_reader( x, mm_N009[ 1, 3 ], A__MENUVERT, , , .f. ) } ;
                When m1b_diag == 98 ;
                Color colget_menu
              If Len( mm_N009 ) >= 2
                @ ++j, 3 Say mm_N009[ 2, 1 ] Get mgist2 ;
                  reader {| x| menu_reader( x, mm_N009[ 2, 3 ], A__MENUVERT, , , .f. ) } ;
                  When m1b_diag == 98 ;
                  Color colget_menu
              Endif
            Endif
            If Len( mm_N012 ) == 0
              @ ++j, 3 Say '���㭮����娬��: �� �㦭� ��� ' + iif( is_mgi, '���',  mkod_diag )
            Else
              @ ++j, 3 Say mm_N012[ 1, 1 ] Get mmark1 ;
                reader {| x| menu_reader( x, mm_N012[ 1, 3 ], A__MENUVERT, , , .f. ) } ;
                When m1b_diag == 98 ;
                Color colget_menu
              If Len( mm_N012 ) >= 2
                @ ++j, 3 Say mm_N012[ 2, 1 ] Get mmark2 ;
                  reader {| x| menu_reader( x, mm_N012[ 2, 3 ], A__MENUVERT, , , .f. ) } ;
                  When m1b_diag == 98 ;
                  Color colget_menu
              Endif
              If Len( mm_N012 ) >= 3
                @ ++j, 3 Say mm_N012[ 3, 1 ] Get mmark3 ;
                  reader {| x| menu_reader( x, mm_N012[ 3, 3 ], A__MENUVERT, , , .f. ) } ;
                  When m1b_diag == 98 ;
                  Color colget_menu
              Endif
              If Len( mm_N012 ) >= 4
                @ ++j, 3 Say mm_N012[ 4, 1 ] Get mmark4 ;
                  reader {| x| menu_reader( x, mm_N012[ 4, 3 ], A__MENUVERT, , , .f. ) } ;
                  When m1b_diag == 98 ;
                  Color colget_menu
              Endif
              If Len( mm_N012 ) >= 5
                @ ++j, 3 Say mm_N012[ 5, 1 ] Get mmark5 ;
                  reader {| x| menu_reader( x, mm_N012[ 5, 3 ], A__MENUVERT, , , .f. ) } ;
                  When m1b_diag == 98 ;
                  Color colget_menu
              Endif
            Endif
          Endif
        Endif

        // �஢������ ���ᨫ�㬠
        If ! is_VOLGAMEDLAB()
          @ ++j, 3 Say '���ᨫ��: ���' Get mDT_CONS ;
            valid {|| iif( Empty( mDT_CONS ) .or. Between( mDT_CONS, mn_data, mk_data ), .t., ;
            func_error( 4, '��� ���ᨫ�㬠 ������ ���� ����� �ப�� ��祭��' ) ) }
          @ j, Col() + 1 Say '�஢������' Get mPR_CONS ;
            reader {| x| menu_reader( x, mm_PR_CONS, A__MENUVERT, , , .f. ) } ;
            When !Empty( mDT_CONS ) ;
            Color colget_menu
        Endif
        If only_control_onko( mNPR_MO, mNPR_DATE, m1rslt, m1ishod ) .and. ! is_VOLGAMEDLAB()
          m1B_DIAG := 7
        endif

        // �஢������ ��祭��
        If eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) // m1usl_ok < 3
          @ ++j, 3 Say '�஢��񭭮� ��祭��' Get musl_tip ;
            reader {| x| menu_reader( x, mm_usl_tip, A__MENUVERT, , , .f. ) } ;
            When Len( mm_usl_tip ) > 1 ;
            valid {| g, o| f_valid_usl_tip( g, o ) } ;
            Color colget_menu
          @ ++j, 5 Get lstr1 Color color1 When .f.
          @ j, Col() + 1 Get musl_tip1 ;
            reader {| x| menu_reader( x, mm_usl_tip1, A__MENUVERT, , , .f. ) } ;
            When Between( m1usl_tip, 1, 4 )
          @ ++j, 5 Get lstr2 Color color1 When .f.
          @ j, Col() + 1 Get musl_tip2 ;
            reader {| x| menu_reader( x, mm_usl_tip2, A__MENUVERT, , , .f. ) } ;
            When m1usl_tip == 2
          If fl_3_4
            @ ++j, 5 Get lstr_sod Color color1 When .f.
            @ j, Col() + 1 Get msod When Between( m1usl_tip, 3, 4 )
            @ j, Col() + 5 Get lstr_fr Color color1 When .f.
            @ j, Col() + 1 Get mk_fr When Between( m1usl_tip, 3, 4 )
          Endif
          If fl_2_4
            @ ++j, 5 Get lstr_wei Color color1 When .f.
            @ j, Col() + 1 Get mwei When eq_any( m1usl_tip, 2, 4 )
            @ j, Col() + 1 Get lstr_hei Color color1 When .f.
            @ j, Col() + 1 Get mhei When eq_any( m1usl_tip, 2, 4 )
            @ j, Col() + 1 Get lstr_bsa Color color1 When .f.
            @ j, Col() + 1 Get mbsa When eq_any( m1usl_tip, 2, 4 )
            @ ++j, 5 Get lstr_err Color color1 When .f.
            @ j, Col() + 1 Get mis_err ;
              reader {| x| menu_reader( x, mm_shema_err, A__MENUVERT, , , .f. ) } ;
              When m1usl_tip == 2
            @ ++j, 5 Get lstr_she Color color1 When .f.

            @ j, Col() + 1 Get mcrit ;
              reader {| x| menu_reader( x, mm_shema_usl, A__MENUVERT, , , .f. ) } ;
              When eq_any( m1usl_tip, 2, 4 )
            @ ++j, 5 Get lstr_lek Color color1 When .f.
            @ j, Col() + 1 Get mlek ;
              reader {| x| menu_reader( x, { {| k, r, c| get_lek_pr( k, r, c, m1crit ) } }, A__FUNCTION, , , .f. ) } ;
              When !Empty( m1crit ) .and. eq_any( m1usl_tip, 2, 4 )
            @ ++j, 5 Get lstr_ptr Color color1 When .f.
            @ j, Col() + 1 Get mpptr ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When eq_any( m1usl_tip, 2, 4 )
          Endif
          If is_onko_VMP .and. mtipvmp == 1 // ��� ��㣨
            @ ++j, 3 Say '���: �������⥫쭮� ��祭��' Get musl_vmp When .f. ;
              Color colget_menu
            @ ++j, 5 Get lstr_vmp1 Color color1 When .f.
            @ j, Col() + 1 Get musl_vmp1 ;
              reader {| x| menu_reader( x, mm_usl_vmp1, A__MENUVERT, , , .f. ) }
            @ ++j, 5 Get lstr_vmp2 Color color1 When .f.
            @ j, Col() + 1 Get musl_vmp2 ;
              reader {| x| menu_reader( x, mm_usl_vmp2, A__MENUVERT, , , .f. ) } ;
              When m1usl_vmp == 2
            If fl2_3_4
              @ ++j, 5 Get lstr_vmpsod Color color1 When .f.
              @ j, Col() + 1 Get msod_vmp When Between( m1usl_vmp, 3, 4 )
              @ j, Col() + 5 Get lstr_vmpfr Color color1 When .f.
              @ j, Col() + 1 Get mk_fr When Between( m1usl_vmp, 3, 4 )
            Endif
            If fl2_2_4
              @ ++j, 5 Get lstr_vmpwei Color color1 When .f.
              @ j, Col() + 1 Get mwei When eq_any( m1usl_vmp, 2, 4 )
              @ j, Col() + 1 Get lstr_vmphei Color color1 When .f.
              @ j, Col() + 1 Get mhei When eq_any( m1usl_vmp, 2, 4 )
              @ j, Col() + 1 Get lstr_vmpbsa Color color1 When .f.
              @ j, Col() + 1 Get mbsa When eq_any( m1usl_vmp, 2, 4 )
              @ ++j, 5 Get lstr_vmperr Color color1 When .f.
              @ j, Col() + 1 Get mis_err ;
                reader {| x| menu_reader( x, mm_shema_err, A__MENUVERT, , , .f. ) } ;
                When m1usl_vmp == 2
              @ ++j, 5 Get lstr_vmpshe Color color1 When .f.
              @ j, Col() + 1 Get mcrit ;
                reader {| x| menu_reader( x, mm_shema_usl, A__MENUVERT, , , .f. ) } ;
                When eq_any( m1usl_vmp, 2, 4 )
              @ ++j, 5 Get lstr_vmplek Color color1 When .f.
              @ j, Col() + 1 Get mlek ;
                reader {| x| menu_reader( x, { {| k, r, c| get_lek_pr( k, r, c, m1crit ) } }, A__FUNCTION, , , .f. ) } ;
                When !Empty( m1crit ) .and. eq_any( m1usl_vmp, 2, 4 )
              @ ++j, 5 Get lstr_vmpptr Color color1 When .f.
              @ j, Col() + 1 Get mpptr ;
                reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
                When eq_any( m1usl_vmp, 2, 4 )
            Endif
          Endif
          //
          arr := { '���ࣨ�᪮�� ��祭��',  '娬���࠯����᪮�� ��祭��',  '��祢�� �࠯��' }
          @ ++j, 3 Say '��⨢���������� � �஢������:'
          @ j, 50 Say '��� ॣ����樨:'
          For i := 1 To 3
            mval := 'mprot' + lstr( i )
            mdval := 'mdprot' + lstr( i )
            @ ++j, 5 Say arr[ i ] get &mval ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              Color colget_menu
            @ j, 53 get &mdval
          Next i
          @ ++j, 3 Say '�⪠�� �� �஢������:'
          @ j, 50 Say '��� ॣ����樨:'
          For i := 4 To 6
            mval := 'mprot' + lstr( i )
            mdval := 'mdprot' + lstr( i )
            @ ++j, 5 Say arr[ i - 3 ] get &mval ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              Color colget_menu
            @ j, 53 get &mdval
          Next i
        Endif
      Endif
      //
      status_key( '^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 1-� ��࠭��� ^<PgDn>^ ������' )
    Endif
    If num_screen == 2
      Set Key K_F5 To change_num_napr
    Endif
    //
    count_edit += myread(, @pos_read )

    // �६���� =====================================================
//    if empty( mSTAD )
//      m1STAD := 0
//    endif
//    if empty( mONK_T )
//      m1ONK_T := 0
//    endif
//    if empty( mONK_N )
//      m1ONK_N := 0
//    endif
//    if empty( mONK_M )
//      m1ONK_M := 0
//    endif
    //  =====================================================

    Close databases
    If num_screen == 2
      Set Key K_F5 To
      If !( emptyany( mNAPR_DATE, m1NAPR_V ) .and. count_napr == 0 )
        If cur_napr == 0
          cur_napr := 1
        Endif
      Endif
      If is_oncology == 2
        Use ( cur_dir() + 'tmp_onkdi' ) New Alias TDIAG
        Zap
        If eq_any( m1B_DIAG, 97, 98 ) // ���⮫����:98-ᤥ����, 97-��� १����

          if m1DS1_T == 5 .and. Len( mm_N009 ) == 0 .and. Len( mm_N012 ) == 0
            Append Blank
            tdiag->DIAG_DATE := mDIAG_DATE
            tdiag->DIAG_TIP := 1 // 1 - ���⮫����᪨� �ਧ���
            tdiag->DIAG_CODE := 0
            tdiag->DIAG_RSLT := 0
            tdiag->REC_RSLT := 1
          endif
          
          If Len( mm_N009 ) > 0
            For i := 1 To Min( 2, Len( mm_N009 ) )
              Append Blank
              tdiag->DIAG_DATE := mDIAG_DATE
              tdiag->DIAG_TIP := 1 // 1 - ���⮫����᪨� �ਧ���
              tdiag->DIAG_CODE := mm_N009[ i, 2 ]
              If m1B_DIAG == 98
                tdiag->DIAG_RSLT := &( 'm1gist' + lstr( i ) )
                tdiag->REC_RSLT := 1
              Else
                tdiag->DIAG_RSLT := 0
                tdiag->REC_RSLT := 0
              Endif
            Next
          Endif
          If Len( mm_N012 ) > 0
            For i := 1 To Min( 5, Len( mm_N012 ) )
              Append Blank
              tdiag->DIAG_DATE := mDIAG_DATE
              tdiag->DIAG_TIP := 2 // 2 - ����� (���)
              tdiag->DIAG_CODE := mm_N012[ i, 2 ]
              If m1B_DIAG == 98
                tdiag->DIAG_RSLT := &( 'm1mark' + lstr( i ) )
                tdiag->REC_RSLT := 1
              Else
                tdiag->DIAG_RSLT := 0
                tdiag->REC_RSLT := 0
              Endif
            Next
          Endif
        Endif
        Use ( cur_dir() + 'tmp_onkpr' ) New Alias TPR
        Zap
        For i := 1 To 6
          If !emptyany( &( 'm1prot' + lstr( i ) ), &( 'mdprot' + lstr( i ) ) )
            Append Blank
            tpr->prot := i
            tpr->d_prot := &( 'mdprot' + lstr( i ) )
          Endif
        Next i
        If eq_any( m1B_DIAG, 0, 7, 8 ) // ���⮫����:0-�⪠�, 7-�� ��������, 8-��⨢���������
          Append Blank
          tpr->prot := m1B_DIAG
          tpr->d_prot := mn_data
        Endif
        Use ( cur_dir() + 'tmp_onkus' ) New Alias TMPOU
        Go Top
        If LastRec() == 0
          Append Blank
        Endif
        tmpou->USL_TIP := m1USL_TIP
        tmpou->HIR_TIP := iif( m1usl_tip == 1, m1usl_tip1, 0 )
        tmpou->LEK_TIP_V := iif( m1usl_tip == 2, m1usl_tip1, 0 )
        tmpou->LEK_TIP_L := iif( m1usl_tip == 2, m1usl_tip2, 0 )
        tmpou->LUCH_TIP := iif( eq_any( m1usl_tip, 3, 4 ),  m1usl_tip1, 0 )
        tmpou->PPTR := iif( eq_any( m1usl_tip, 2, 4 ),  m1PPTR, 0 )
        If eq_any( m1usl_tip, 3, 4 )
          If Val( msod ) < 1000
            tmpou->sod := Val( CharRepl( ',  ', msod, '.' ) )
          Else
            tmpou->sod := 100
          Endif
        Else
          tmpou->sod := 0
        Endif
        If is_onko_VMP .and. mtipvmp == 1 // ��� ��㣨
          If LastRec() == 1
            Append Blank
          Endif
          Goto ( 2 )
          tmpou->USL_TIP := m1USL_VMP
          tmpou->HIR_TIP := iif( m1usl_vmp == 1, m1usl_vmp1, 0 )
          tmpou->LEK_TIP_V := iif( m1usl_vmp == 2, m1usl_vmp1, 0 )
          tmpou->LEK_TIP_L := iif( m1usl_vmp == 2, m1usl_vmp2, 0 )
          tmpou->LUCH_TIP := iif( eq_any( m1usl_vmp, 3, 4 ),  m1usl_vmp1, 0 )
          tmpou->PPTR := iif( eq_any( m1usl_vmp, 2, 4 ),  m1PPTR, 0 )
          If eq_any( m1usl_vmp, 3, 4 )
            If Val( msod_vmp ) < 1000
              tmpou->sod := Val( CharRepl( ',  ', msod_vmp, '.' ) )
            Else
              tmpou->sod := 100
            Endif
          Else
            tmpou->sod := 0
          Endif
        Else
          For i := 2 To LastRec()
            Goto ( i )
            Delete
          Next
          Pack
        Endif
      Endif
      Close databases
    Else
      If is_talon
        Set Key K_F10 To
      Endif
    Endif
    diag_screen( 2 )
    If num_screen == 2
      If LastKey() == K_PGUP
        k := 3
        num_screen := 1
      Else
        k := f_alert( { PadC( '�롥�� ����⢨�', 60, '.' ) }, ;
          { ' ��室 ��� ����� ',  ' ������ ',  ' ������ � ।���஢���� ' }, ;
          iif( LastKey() == K_ESC, 1, 2 ),  'W+/N',  'N+/N', MaxRow() -2, , 'W+/N,N/BG' )
      Endif
    Else
      is_oncology := f_is_oncology( 2 )
      If LastKey() != K_ESC .and. is_oncology > 0
        k := 3
        num_screen := 2
      Else
        k := f_alert( { PadC( '�롥�� ����⢨�', 60, '.' ) }, ;
          { ' ��室 ��� ����� ', ' ������ ', ' ������ � ।���஢���� ' }, ;
          iif( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N,N/BG' )
      Endif
    Endif
    SetMode( 25, 80 ) // ��।����� ���� 25*80 ᨬ�����
    If k == 3
      Loop
    Elseif k == 2
      num_screen := 1  // �訡�� 1-�� �࠭�
      If Empty( mn_data )
        func_error( 4, '�� ������� ��� ��砫� ��祭��.' )
        Loop
      Endif
      If Empty( mk_data )
        func_error( 4, '�� ������� ��� ����砭�� ��祭��.' )
        Loop
      Endif
      If m1_l_z == 1 .and. Empty( mkod_diag )
        func_error( 4, '�� ������ ��� �᭮����� �����������.' )
        Loop
      Endif
      If m1bolnich > 0
        If emptyany( mdate_b_1, mdate_b_2 )
          func_error( 4, '�� ��������� ��ਮ�� ���쭨筮��.' )
          Loop
        Endif
        If mdate_b_1 > mdate_b_2
          func_error( 4, '�����४�� ���� ��砫� � ����砭�� ���쭨筮��.' )
          Loop
        Endif
        If m1bolnich == 2 .and. emptyany( mrodit_dr, mrodit_pol )
          func_error( 4, '�� ��������� ४������ த�⥫�� � ���쭨筮�' )
          Loop
        Endif
      Endif
      If Empty( CharRepl( '0', much_doc, Space( 10 ) ) )
        func_error( 4, '�� �������� ����� ���㫠�୮� ����� (���ਨ �������)' )
        Loop
      Endif
      If m1komu < 5 .and. Empty( m1company )
        If m1komu == 0
          s := '���'
        Elseif m1komu == 1
          s := '��������'
        else
          s := '������/��'
        Endif
        func_error( 4, '�� ��������� ������������ ' + s )
        Loop
      Endif
      If m1komu == 0 .and. Empty( mnpolis )
        func_error( 4, '�� �������� ����� �����' )
        Loop
      Endif
      If is_MO_VMP
        If M1VMP == 1
          If Empty( M1VIDVMP )
            func_error( 4, '�� �������� ��� ���' )
            Loop
          Elseif Empty( M1METVMP )
            func_error( 4, '�� �������� ��⮤ ���' )
            Loop
          Elseif Empty( m1modpac ) .and. Year( mk_data ) >= 2021
            func_error( 4, '�� ��������� ������ ��樥�� ���' )
            Loop
          Endif
        Else
          M1VIDVMP := ''
          M1METVMP := 0
          m1modpac := 0
        Endif
      Else
        M1VMP := 0
        M1VIDVMP := ''
        M1METVMP := 0
        m1modpac := 0
      Endif
      err_date_diap( mn_data, '��� ��砫� ��祭��' )
      err_date_diap( mk_data, '��� ����砭�� ��祭��' )
      RestScreen( buf )
      If mem_op_out == 2 .and. yes_parol
        box_shadow( 19, 10, 22, 69, cColorStMsg )
        str_center( 20, '������ "' + fio_polzovat + '".',  cColorSt2Msg )
        str_center( 21, '���� ������ �� ' + date_month( sys_date ),  cColorStMsg )
      Endif
      mywait( '����. �ந�������� ������ ���� ���� ...' )
      If yes_vypisan == B_END
        mtip_h := B_END + m1_l_z
        st_l_z := m1_l_z
      Endif
      make_diagp( 2 )  // ᤥ���� '��⨧����' ��������
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
      If IsBit( mem_oms_pole, 1 )  // '�ப� ��祭��', ;  1
        st_N_DATA := MN_DATA
        st_K_DATA := MK_DATA
      Endif
      If IsBit( mem_oms_pole, 2 )  // '���.���', ;       2
        st_VRACH := m1vrach
      Endif
      If IsBit( mem_oms_pole, 3 )  // '��.�������', ;    3
        SKOD_DIAG := SubStr( MKOD_DIAG, 1, 5 )
      Endif
      If IsBit( mem_oms_pole, 4 )  // '��䨫�', ;        4
        st_PROFIL := m1PROFIL
      Endif
      If IsBit( mem_oms_pole, 5 )  // '१����', ;      5
        st_RSLT := m1rslt
      Endif
      If IsBit( mem_oms_pole, 6 )  // '��室', ;          6
        st_ISHOD := m1ishod
      Endif
      /*if isbit(mem_oms_pole, 7)  //  '����� ���饭��'  7
        st_povod := m1povod
      endif*/
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
      human->TIP_H      := mtip_h
      human->FIO        := MFIO          // �.�.�. ���쭮��
      human->POL        := MPOL          // ���
      human->DATE_R     := MDATE_R       // ��� ஦����� ���쭮��
      human->VZROS_REB  := M1VZROS_REB   // 0-�����, 1-ॡ����, 2-�����⮪
      human->ADRES      := MADRES        // ���� ���쭮��
      human->MR_DOL     := MMR_DOL       // ���� ࠡ��� ��� ��稭� ���ࠡ�⭮��
      human->RAB_NERAB  := M1RAB_NERAB   // 0-ࠡ���騩, 1-��ࠡ���騩
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
      If is_dop_ob_em
        human->reg_lech := m1reg_lech    // 0-�᭮���, 9-�������⥫�� �����
      Endif
      human->CENA       := MCENA_1       // �⮨����� ��祭��
      human->CENA_1     := MCENA_1       // �⮨����� ��祭��
      human->OBRASHEN := iif( m1DS_ONK == 1, '1',  ' ' )
      human->bolnich    := m1bolnich
      human->date_b_1   := iif( m1bolnich == 0, '',  dtoc4( mdate_b_1 ) )
      human->date_b_2   := iif( m1bolnich == 0, '',  dtoc4( mdate_b_2 ) )
      human_->RODIT_DR  := iif( m1bolnich < 2, CToD( '' ),  mrodit_dr )
      human_->RODIT_POL := iif( m1bolnich < 2, '',  mrodit_pol )
      s := ''
      AEval( adiag_talon, {| x| s += Str( x, 1 ) } )
      human_->DISPANS   := s
      human_->STATUS_ST := LTrim( MSTATUS_ST )
      // human_->POVOD     := m1povod
      // human_->TRAVMA    := m1travma
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := LTrim( mspolis )
      human_->NPOLIS    := LTrim( mnpolis )
      human_->OKATO     := '' // �� ���� ������� �� ����� � ��砥 �����த����
      human_->NOVOR     := iif( m1novor == 0, 0, mcount_reb )
      human_->DATE_R2   := iif( m1novor == 0, CToD( '' ),  mDATE_R2  )
      human_->POL2      := iif( m1novor == 0, '', mpol2     )
      human_->USL_OK    := m1USL_OK
      human_->PROFIL    := m1PROFIL
      human_->NPR_MO    := m1NPR_MO
      human_->FORMA14   := Str( M1F14_EKST, 1 ) + Str( M1F14_SKOR, 1 ) + Str( M1F14_VSKR, 1 ) + Str( M1F14_RASH, 1 )
      human_->KOD_DIAG0 := mkod_diag0
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // 㡥�� '2',  �᫨ ��।���஢��� ������ �� ॥��� �� � ��
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
      human_2->OSL1   := MOSL1
      human_2->OSL2   := MOSL2
      human_2->OSL3   := MOSL3
      human_2->NPR_DATE := mNPR_DATE
      human_2->PROFIL_K := m1PROFIL_K
      human_2->p_per  := iif( eq_any( m1USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ),  m1p_per, 0 )
      human_2->VMP    := M1VMP
      human_2->TAL_NUM  := mTAL_NUM
      human_2->TAL_D  := mTAL_D
      human_2->TAL_P  := mTAL_P
      human_2->VIDVMP := M1VIDVMP
      human_2->METVMP := M1METVMP
      human_2->PN5    := m1modpac
      human_2->PN6    := m1NMSE  // ���ࠢ����� �� ���
      human_2->VNR    := Val( MVNR )
      human_2->VNR1   := Val( MVNR1 )
      human_2->VNR2   := Val( MVNR2 )
      human_2->VNR3   := Val( MVNR3 )

      human_2->PC4    := iif( mWeight != 0, Str( mWeight, 5, 1 ),  Space( 10 ) )

      If is_reabil_slux .and. eq_any( m1usl_ok, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) .and. m1profil == 158
        human_2->PN1 := m1vid_reab
      Endif
      human_2->PN2 := iif( f_oms_beremenn( mkod_diag, MK_DATA ) > 0, m1prer_b, 0 )

      human_2->PC3 := iif( input_ad_cr, m1ad_cr, '' )
      If is_oncology == 0 // ��� ���������
        If old_oncology // �� �뫠 � ���� ����
          g_use( dir_server() + 'mo_onkna', dir_server() + 'mo_onkna',  'NAPR' ) // �������ࠢ�����
          Do While .t.
            find ( Str( mkod, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
          g_use( dir_server() + 'mo_onkco', dir_server() + 'mo_onkco',  'CO' )
          Do While .t.
            find ( Str( mkod, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
        Endif
      Endif
      If is_oncology == 1 // ⮫쪮 ���ࠢ�����
        If old_oncology // �� �뫠 ��������� � ���� ����
          g_use( dir_server() + 'mo_onksl', dir_server() + 'mo_onksl',  'SL' )
          Do While .t.
            find ( Str( mkod, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
          g_use( dir_server() + 'mo_onkdi', dir_server() + 'mo_onkdi',  'DI' )
          Do While .t.
            find ( Str( mkod, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
          g_use( dir_server() + 'mo_onkpr', dir_server() + 'mo_onkpr',  'PR' )
          Do While .t.
            find ( Str( mkod, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
          g_use( dir_server() + 'mo_onkus', dir_server() + 'mo_onkus',  'US' )
          Do While .t.
            find ( Str( mkod, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
          g_use( dir_server() + 'mo_onkle', dir_server() + 'mo_onkle',  'LE' )
          Do While .t.
            find ( Str( mkod, 7 ) )
            If !Found()
              Exit
            Endif
            deleterec( .t. )
          Enddo
          if mk_data >= 0d20250101
            g_use( dir_server() + 'human_lek_pr', dir_server() + 'human_lek_pr', 'LEK_PR' )
            Do While .t.
              find ( Str( mkod, 7 ) )
              If !Found()
                Exit
              Endif
              deleterec( .t. )
            Enddo
          Endif
        Endif
      Endif
      If is_oncology > 0 // ��������� - ���ࠢ�����
        save_mo_onkna( mkod )
        //
        g_use( dir_server() + 'mo_onkco', dir_server() + 'mo_onkco',  'CO' )
        find ( Str( mkod, 7 ) )
        If Found()
          g_rlock( forever )
        Else
          addrec( 7 )
          co->kod := mkod
        Endif
        co->PR_CONS := iif( emptyany( m1PR_CONS, mDT_CONS ),  0, m1PR_CONS )
        co->DT_CONS := iif( emptyany( m1PR_CONS, mDT_CONS ),  CToD( '' ),  mDT_CONS )
        //
        If is_oncology == 2 // ���������
          g_use( dir_server() + 'mo_onksl', dir_server() + 'mo_onksl',  'SL' )
          find ( Str( mkod, 7 ) )
          If Found()
            g_rlock( forever )
          Else
            addrec( 7 )
            sl->kod := mkod
          Endif
          sl->DS1_T := m1DS1_T

          sl->STAD := iif( empty( mSTAD ), 0, m1STAD )
          sl->ONK_T := iif( empty( mONK_T ), 0, m1ONK_T )
          sl->ONK_N := iif( empty( mONK_N ), 0, m1ONK_N )
          sl->ONK_M := iif( empty( mONK_M ), 0, m1ONK_M )

          sl->MTSTZ := m1MTSTZ
          sl->b_diag := m1b_diag
          sl->sod := 0
          sl->k_fr := iif( eq_any( m1usl_tip, 3, 4 ),  Val( mk_fr ),  0 )
          If is_onko_VMP .and. mtipvmp == 1 .and. musl2vmp == 3 // ��� ��㣨
            sl->k_fr := Val( mk_fr )
          Endif
          If eq_any( m1usl_tip, 2, 4 )
            If !Empty( m1ad_cr ) .and. Left( Lower( m1ad_cr ), 5 ) == 'gemop' // ��᫥ ࠧ����� � �.�.��⮭���� 13.01.23
              sl->crit := m1ad_cr
            Else
              sl->crit := m1crit
            Endif
          Else
            sl->crit := ''
          Endif
          If sl->k_fr == 0
            sl->crit2 := ''
          Elseif ( i := AScan( _arr_fr, {| x| Between( sl->k_fr, x[ 3 ], x[ 4 ] ) } ) ) > 0
            sl->crit2 := _arr_fr[ i, 2 ]
          Endif
          If eq_any( m1usl_tip, 2, 4 )
            sl->is_err := iif( m1usl_tip == 2, m1is_err, 0 )
            sl->WEI := iif( Val( mWEI ) < 1000, Val( CharRepl( ',  ', mWEI, '.' ) ),  70 )
            sl->HEI := Val( mHEI )
            sl->BSA := iif( Val( mBSA ) < 10, Val( CharRepl( ',  ', mBSA, '.' ) ),  2 )
          Else
            sl->is_err := sl->WEI := sl->HEI := sl->BSA := 0
          Endif
          If is_onko_VMP .and. mtipvmp == 1 .and. musl2vmp == 2 // ��� ��㣨
            sl->crit := m1crit
            sl->is_err := m1is_err
            sl->WEI := iif( Val( mWEI ) < 1000, Val( CharRepl( ',  ', mWEI, '.' ) ),  70 )
            sl->HEI := Val( mHEI )
            sl->BSA := iif( Val( mBSA ) < 10, Val( CharRepl( ',  ', mBSA, '.' ) ),  2 )
          Endif
          //
          arr := {}
          g_use( dir_server() + 'mo_onkdi', dir_server() + 'mo_onkdi',  'DIAG' ) // ���������᪨� ����
          find ( Str( mkod, 7 ) )
          Do While diag->kod == mkod .and. !Eof()
            AAdd( arr, RecNo() )
            Skip
          Enddo
          i := 0
          Use ( cur_dir() + 'tmp_onkdi' ) New Alias TDIAG
          Go Top
          Do While !Eof()
            Select DIAG
            If++i > Len( arr )
              addrec( 7 )
              diag->kod := mkod
            Else
              Goto ( arr[ i ] )
              g_rlock( forever )
            Endif
            diag->DIAG_DATE := tdiag->DIAG_DATE
            diag->DIAG_TIP  := tdiag->DIAG_TIP
            diag->DIAG_CODE := tdiag->DIAG_CODE
            diag->DIAG_RSLT := tdiag->DIAG_RSLT
            diag->REC_RSLT  := tdiag->REC_RSLT
            Select TDIAG
            Skip
          Enddo
          If is_gisto
            For j := 1 To Len( arr_rez_gist )
              If !Empty( arr_rez_gist[ j, 4 ] )
                Select DIAG
                If++i > Len( arr )
                  addrec( 7 )
                  diag->kod := mkod
                Else
                  Goto ( arr[ i ] )
                  g_rlock( forever )
                Endif
                diag->DIAG_DATE := mDIAG_DATE
                diag->DIAG_TIP  := 1
                diag->DIAG_CODE := arr_rez_gist[ j, 2 ]
                diag->DIAG_RSLT := arr_rez_gist[ j, 4 ]
                diag->REC_RSLT  := 1
              Endif
            Next
          Endif
          Select DIAG
          Do While++i <= Len( arr )
            Goto ( arr[ i ] )
            deleterec( .t. )
          Enddo
          //
          arr := {}
          g_use( dir_server() + 'mo_onkpr', dir_server() + 'mo_onkpr',  'PR' ) // �������� �� �������� ��⨢�����������
          find ( Str( mkod, 7 ) )
          Do While pr->kod == mkod .and. !Eof()
            AAdd( arr, RecNo() )
            Skip
          Enddo
          i := 0
          Use ( cur_dir() + 'tmp_onkpr' ) New Alias TPR
          Go Top
          Do While !Eof()
            Select PR
            If++i > Len( arr )
              addrec( 7 )
              pr->kod := mkod
            Else
              Goto ( arr[ i ] )
              g_rlock( forever )
            Endif
            pr->PROT := tpr->PROT
            pr->D_PROT := tpr->D_PROT
            Select TPR
            Skip
          Enddo
          Select PR
          Do While++i <= Len( arr )
            Goto ( arr[ i ] )
            deleterec( .t. )
          Enddo
          arr := {}
          g_use( dir_server() + 'mo_onkus', dir_server() + 'mo_onkus',  'US' )
          find ( Str( mkod, 7 ) )
          Do While us->kod == mkod .and. !Eof()
            AAdd( arr, RecNo() )
            Skip
          Enddo
          i := 0
          Use ( cur_dir() + 'tmp_onkus' ) New Alias TMPOU
          Go Top
          Do While !Eof()
            Select US
            If++i > Len( arr )
              addrec( 7 )
              us->kod := mkod
            Else
              Goto ( arr[ i ] )
              g_rlock( forever )
            Endif
            us->USL_TIP   := tmpou->USL_TIP
            us->HIR_TIP   := tmpou->HIR_TIP
            us->LEK_TIP_V := tmpou->LEK_TIP_V
            us->LEK_TIP_L := tmpou->LEK_TIP_L
            us->LUCH_TIP  := tmpou->LUCH_TIP
            us->PPTR      := tmpou->PPTR
            sl->sod += tmpou->sod
            Select TMPOU
            Skip
          Enddo
          Select US
          Do While++i <= Len( arr )
            Goto ( arr[ i ] )
            deleterec( .t. )
          Enddo
          //
          arr := {}
          g_use( dir_server() + 'mo_onkle', dir_server() + 'mo_onkle',  'LE' )
          find ( Str( mkod, 7 ) )
          Do While le->kod == mkod .and. !Eof()
            AAdd( arr, RecNo() )
            Skip
          Enddo
          if mk_data >= 0d20250101
            arr_lek := {}
            g_use( dir_server() + 'human_lek_pr', dir_server() + 'human_lek_pr', 'LEK_PR' )
            find ( Str( mkod, 7 ) )
            Do While lek_pr->kod_hum == mkod .and. !Eof()
              AAdd( arr_lek, RecNo() )
              Skip
            Enddo
            i_lek_pr := 0
          endif
          i := 0
          // (m1usl_tip ������⢥���� ��⨢����嫥��� �࠯�� ��� 娬����祢�� �࠯��)
          If eq_any( m1usl_tip, 2, 4 ) .or. ( is_onko_VMP .and. mtipvmp == 1 .and. musl2vmp == 2 )
            Use ( cur_dir() + 'tmp_onkle' ) New Alias TMPLE
            Go Top
            Do While !Eof()
              Select LE
              If ++i > Len( arr )
                addrec( 7 )
                le->kod := mkod
              Else
                Goto ( arr[ i ] )
                g_rlock( forever )
              Endif
              le->REGNUM   := tmple->REGNUM
              If !Empty( m1ad_cr ) .and. Left( Lower( m1ad_cr ), 5 ) == 'gemop' // ��᫥ ࠧ����� � �.�.��⮭���� 13.01.23
                le->CODE_SH  := m1ad_cr // tmple->CODE_SH
              Else
                le->CODE_SH  := m1crit // tmple->CODE_SH
              Endif
              le->DATE_INJ := tmple->DATE_INJ

              if mk_data >= 0d20250101
                select LEK_PR
                If ++i_lek_pr > Len( arr_lek )
                  addrec( 7 )
                  lek_pr->kod_hum := mkod
                Else
                  Goto ( arr_lek[ i ] )
                  g_rlock( forever )
                Endif

                lek_pr->REGNUM   := tmple->REGNUM
                lek_pr->CODE_SH  := m1crit // tmple->CODE_SH
                lek_pr->DATE_INJ := tmple->DATE_INJ
              endif

              Select TMPLE
              Skip
            Enddo
          Endif
          Select LE
          Do While ++i <= Len( arr )
            Goto ( arr[ i ] )
            deleterec( .t. )
          Enddo
          if mk_data >= 0d20250101
            Select LEK_PR
            do while ++i_lek_pr <= Len( arr_lek )
              Goto ( arr_lek[ i_lek_pr ] )
              deleterec( .t. )
            Enddo
//            g_use( dir_server() + 'human_lek_pr', dir_server() + 'human_lek_pr', 'LEK_PR' )
//            Do While .t.
//              find ( Str( mkod, 7 ) )
//              If !Found()
//                Exit
//              Endif
//              deleterec( .t. )
//            Enddo
          Endif
        Endif
      Endif
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
      //
      If pp_OMS .and. mtip_h > B_END // �ਥ��� ����� + ��祭�� �����襭�
        g_use( dir_server() + 'mo_pp', dir_server() + 'mo_pp_h',  'PP' )
        find ( Str( mkod, 7 ) )
        If Found()
          g_rlock( forever )
          If ( MKOJKO_DNI := mk_data - mn_data ) < 1
            MKOJKO_DNI := 1
          Endif
          M1ISHOD1 := M1ISHOD2 := 1
          Do Case
          Case eq_any( m1ishod, 101, 201, 301 )  // �매�஢�����
            M1ISHOD2 := 1
          Case eq_any( m1ishod, 102, 202, 303 )  // ���襭��
            M1ISHOD2 := 2
          Case eq_any( m1ishod, 103, 203, 302, 304 )  // ��� ��६��
            M1ISHOD2 := 3
          Case eq_any( m1ishod, 104, 204, 305 )  // ���襭��
            M1ISHOD2 := 4
          Endcase
          Do Case
          Case eq_any( m1rslt, 102, 202 )  // ��ॢ��� � ��. ���
            M1ISHOD1 := 4
          Case eq_any( m1rslt, 103, 204 )  // ��ॢ��� � ������� ��樮���
            M1ISHOD1 := 2
          Case eq_any( m1rslt, 104, 203 )  // ��ॢ��� � ��樮���
            M1ISHOD1 := 3
          Case eq_any( m1rslt, 105, 106, 205, 206, 313 )  // ᬥ���
            M1ISHOD2 := 6
          Endcase
          pp->ISHOD1 := M1ISHOD1     // ��室
          pp->ISHOD2 := M1ISHOD2     // ��室
          If pp->IS_GOSPIT == 0 .and. Empty( pp->G_DATA ) // 0-��ᯨ⠫���஢�� � �� ��������� ��� ��ᯨ⠫���樨
            pp->G_DATA := MN_DATA      // ��� ��ᯨ⠫���樨
            pp->G_TIME := pp->N_TIME   // �६� ��ᯨ⠫���樨
          Endif
          // ���塞 ���� ����砭��/�த����⥫쭮��� ��ᯨ⠫���樨
          pp->K_DATA    := MK_DATA      // ��� ����砭�� ��祭��
          pp->K_TIME    := '11:00'      // �६� �믨᪨
          pp->KOJKO_DNI := MKOJKO_DNI   // �த����⥫쭮��� ��ᯨ⠫���樨
          pp->BOLNICH    := M1BOLNICH    // ���쭨�� (0-���, 1-��, 2-�� �室�)
          If m1bolnich > 0
            pp->DATE_B_1 := MDATE_B_1    // ��� ��砫� ���쭨筮��
            pp->DATE_B_2 := MDATE_B_2    // ��� ����砭�� ���쭨筮��
            If m1bolnich == 2
              pp->DATE_RODIT := mrodit_dr    // ��� ஦����� த�⥫�
              pp->POL_RODIT  := mrodit_pol   // ��� த�⥫�
            Endif
          Endif
        Endif
        Close databases
      Endif
      stat_msg( '������ �����襭�!', .f. )
    Endif
    Exit
  Enddo
  Close databases
  diag_screen( 2 )
  SetColor( tmp_color )
  RestScreen( buf )
  chm_help_code := tmp_help
  If fl_write_sluch // �᫨ ����ᠫ�
    If eq_any( m1USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
      f_1pac_definition_ksg( mkod )
    Endif
    If Type( 'fl_edit_oper' ) == 'L' // �᫨ ��室���� � ०��� ���������� ����
      fl_edit_oper := .t.  // �஢��� �����⨬ �� ��室� �� ��������� ���
    Else // ���� ����᪠�� �஢���
      If ( mcena_1 > 0 .or. is_smp( m1USL_OK, m1PROFIL ) ) .and. !Empty( Val( msmo ) )
        verify_oms_sluch( glob_perso )
      Endif
    Endif
  Endif

  Return Nil
