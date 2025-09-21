#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 20.09.25 �� - ���������� ��� ।���஢���� ���� (���� ���)
Function oms_sluch_pn( Loc_kod, kod_kartotek, f_print )

  // Loc_kod - ��� �� �� human.dbf (�᫨ = 0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  // f_print - ������������ �㭪樨 ��� ����
  Static st_N_DATA, st_K_DATA, st_mo_pr := '      '
  Local L_BEGIN_RSLT := 331
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, arr_del := {}, mrec_hu := 0, ;
    buf := SaveScreen(), tmp_color := SetColor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', arr_usl := {}, ;
    i, j, k, n, s, s1, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod, ;
    tmp_help := chm_help_code, fl_write_sluch := .f., _y, _m, _d, t_arr[ 2 ], ;
    arr_prof := {}, is_3_5_4 := .f.

  local arr_PN_issled
  local arr_PN_osmotr
  local arr_osmotr_KDP2
  local arr_not_zs
  local mm_mesto_prov := { ;
    { '����樭᪠� �࣠������', 0 }, ;
    { '��饮�ࠧ���⥫쭮� ��०�����', 1 } ;
  }
  local mm_step2 := { ;
    { '���  ', 0 }, ;
    { '��   ', 1 }, ;
    { '�����', 2 } ;
  }
  local dir_DB
  //
  Default st_N_DATA To sys_date, st_K_DATA To sys_date
  Default Loc_kod To 0, kod_kartotek To 0, f_print To ''
  dir_DB := dir_server()
  //
  If kod_kartotek == 0 // ���������� � ����⥪�
    If ( kod_kartotek := edit_kartotek( 0, , , .t. ) ) == 0
      Return Nil
    Endif
  Endif
  chm_help_code := 3002
  Private mfio := Space( 50 ), mpol, mdate_r, madres, mvozrast, mdvozrast, msvozrast := ' ', ;
    M1VZROS_REB, MVZROS_REB, m1novor := 0, ;
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-���, 1-��������, 3-�������/���, 5-���� ���
    msmo := '34007', rec_inogSMO := 0, ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := Space( 100 ), ;
    mvidpolis, m1vidpolis := 1, mspolis := Space( 10 ), mnpolis := Space( 20 )
  Private mkod := Loc_kod, mtip_h, is_talon := .f., is_disp_19 := .t., ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    M1LPU := glob_uch[ 1 ], MLPU, ;
    M1OTD := glob_otd[ 1 ], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MUCH_DOC    := Space( 10 ), ; // ��� � ����� ��⭮�� ���㬥��
    mmobilbr, m1mobilbr := 0, ;
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
    m1rslt  := L_BEGIN_RSLT + 1, ; // १���� (��᢮��� I ��㯯� ���஢��)
    m1ishod := 306, ; // ��室 = �ᬮ��
    mn_data := st_N_DATA, ; // ��� ��砫� ��祭��
    mk_data := st_K_DATA, ; // ��� ����砭�� ��祭��
    MVRACH := Space( 10 ), ; // 䠬���� � ���樠�� ���饣� ���
    M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
    m1povod  := 4, ;   // ��䨫����᪨�
    m1travma := 0, ;
    m1USL_OK := USL_OK_POLYCLINIC, ; // �����������
    m1VIDPOM :=  1, ; // ��ࢨ筠�
    m1PROFIL := 68, ; // ��������
    m1IDSP   := 17   // �����祭�� ��砩 � �-��
  //
//  Private mm_kateg_uch := { { 'ॡ����-���', 0 }, ;
//    { 'ॡ����, ��⠢訩�� ��� ����祭�� த�⥫��', 1 }, ;
//    { 'ॡ����, ��室�騩�� � ��㤭�� ��������� ���樨', 2 }, ;
//    { '��� ��⥣�ਨ', 3 } }
/*
  Private mm_mesto_prov := { { '����樭᪠� �࣠������', 0 }, ;
    { '��饮�ࠧ���⥫쭮� ��०�����', 1 } }
*/
//  Private mm_fiz_razv := { { '��ଠ�쭮�', 0 }, ;
//    { '� �⪫�����ﬨ', 1 } }
//  Private mm_fiz_razv1 := { { '���    ', 0 }, ;
//    { '�����', 1 }, ;
//    { '����⮪', 2 } }
//  Private mm_fiz_razv2 := { { '���    ', 0 }, ;
//    { '������ ', 1 }, ;
//    { '��᮪��', 2 } }
//  Private mm_psih2 := { { '��ଠ', 0 }, { '����襭��', 1 } }
//  Private mm_142me3 := { { 'ॣ����', 0 }, ;
//    { '��ॣ����', 1 } }
//  Private mm_142me4 := { { '������', 0 }, ;
//    { '㬥७��', 1 }, ;
//    { '�㤭�', 2 } }
//  Private mm_142me5 := { { '����������', 0 }, ;
//    { '�������������', 1 } }
  Private mm_dispans := { { '࠭��', 1 }, { '�����', 2 }, { '�� ���.', 0 } }
  Private mm_usl := { { '���.', 0 }, { '��/�', 1 }, { '���', 2 } }
  Private mm_uch := { { '��� ', 1 }, { '��� ', 0 }, { '䥤.', 2 }, { '���', 3 } }
  Private mm_uch1 := AClone( mm_uch )

  AAdd( mm_uch1, { 'ᠭ.', 4 } )
  Private mm_gr_fiz_do := { { 'I', 1 }, { 'II', 2 }, { 'III', 3 }, { 'IV', 4 } }
  Private mm_gr_fiz := AClone( mm_gr_fiz_do )
  AAdd( mm_gr_fiz_do, { '���������', 0 } )
  AAdd( mm_gr_fiz, { '�� ����饭', 0 } )
//  Private mm_invalid2 := { { '� ஦�����', 0 }, { '�ਮ��⥭���', 1 } }
//  Private mm_invalid5 := { { '������� ��䥪樮��� � ��ࠧ����,', 1 }, ;
//    { ' �� ���: �㡥�㫥�,', 101 }, ;
//    { '         �䨫��,', 201 }, ;
//    { '         ���-��䥪��;', 301 }, ;
//    { '������ࠧ������;', 2 }, ;
//    { '������� �஢�, �஢�⢮��� �࣠��� ...', 3 }, ;
//    { '������� ���ਭ��� ��⥬� ...', 4 }, ;
//    { ' �� ���: ���� ������;', 104 }, ;
//    { '����᪨� ����ன�⢠ � ����ன�⢠ ���������,', 5 }, ;
//    { ' � ⮬ �᫥ ��⢥���� ���⠫����;', 105 }, ;
//    { '������� ��ࢭ�� ��⥬�,', 6 }, ;
//    { ' �� ���: �ॡࠫ�� ��ࠫ��,', 106 }, ;
//    { '         ��㣨� ��ࠫ���᪨� ᨭ�஬�;', 206 }, ;
//    { '������� ����� � ��� �ਤ��筮�� ������;', 7 }, ;
//    { '������� �� � ��楢������ ����⪠;', 8 }, ;
//    { '������� ��⥬� �஢����饭��;', 9 }, ;
//    { '������� �࣠��� ��堭��,', 10 }, ;
//    { ' �� ���: ��⬠,', 110 }, ;
//    { '         ��⬠��᪨� �����;', 210 }, ;
//    { '������� �࣠��� ��饢�७��;', 11 }, ;
//    { '������� ���� � ��������� �����⪨;', 12 }, ;
//    { '������� ���⭮-���筮� ��⥬� � ᮥ����⥫쭮� ⪠��;', 13 }, ;
//    { '������� ��祯������ ��⥬�;', 14 }, ;
//    { '�⤥��� ���ﭨ�, ��������騥 � ��ਭ�⠫쭮� ��ਮ��;', 15 }, ;
//    { '�஦����� ��������,', 16 }, ;
//    { ' �� ���: �������� ��ࢭ�� ��⥬�,', 116 }, ;
//    { '         �������� ��⥬� �஢����饭��,', 216 }, ;
//    { '         �������� ���୮-�����⥫쭮�� ������;', 316 }, ;
//    { '��᫥��⢨� �ࠢ�, ��ࠢ����� � ��.', 17 } }
//  Private mm_invalid6 := { { '��⢥���', 1 }, ;
//    { '��㣨� ��宫����᪨�', 2 }, ;
//    { '�몮�� � �祢�', 3 }, ;
//    { '��客� � ���⨡����', 4 }, ;
//    { '��⥫��', 5 }, ;
//    { '����ࠫ�� � ��⠡����᪨� ����ன�⢠ ��⠭��', 6 }, ;
//    { '�����⥫��', 7 }, ;
//    { '�த��騥', 8 }, ;
//    { '��騥 � ����ࠫ��������', 9 } }
//  Private mm_invalid8 := { { '���������', 1 }, ;
//    { '���筮', 2 }, ;
//    { '����', 3 }, ;
//    { '�� �믮�����', 0 } }
//  Private mm_privivki1 := { { '�ਢ�� �� �������', 0 }, ;
//    { '�� �ਢ�� �� ����樭᪨� ���������', 1 }, ;
//    { '�� �ਢ�� �� ��㣨� ��稭��', 2 } }
//  Private mm_privivki2 := { { '���������', 1 }, ;
//    { '���筮', 2 } }
  //
  Private metap := 1, mperiod := 0, mshifr_zs := '', mnapr_onk := Space( 10 ), m1napr_onk := 0, ;
    mkateg_uch, m1kateg_uch := 3, ; // ��⥣��� ��� ॡ����:
    mmesto_prov := Space( 10 ), m1mesto_prov := 0, ; // ���� �஢������
    mMO_PR := Space( 10 ), m1MO_PR := st_mo_pr, ; // ��� �� �ਪ९�����
    mschool := Space( 10 ), m1school := 0, ; // ��� ���.��०�����
    mWEIGHT := 0, ;   // ��� � ��
    mHEIGHT := 0, ;   // ��� � �
    mPER_HEAD := 0, ; // ���㦭���� ������ � �
    mfiz_razv, m1FIZ_RAZV := 0, ; // 䨧��᪮� ࠧ��⨥
    mfiz_razv1, m1FIZ_RAZV1 := 0, ; // �⪫������ ����� ⥫�
    mfiz_razv2, m1FIZ_RAZV2 := 0, ; // �⪫������ ���
    m1psih11 := 0, ;  // �������⥫쭠� �㭪�� (������ ࠧ����)
    m1psih12 := 0, ;  // ���ୠ� �㭪�� (������ ࠧ����)
    m1psih13 := 0, ;  // �樮���쭠� � �樠�쭠� (���⠪� � ���㦠�騬 ��஬) �㭪樨 (������ ࠧ����)
    m1psih14 := 0, ;  // �।�祢�� � �祢�� ࠧ��⨥ (������ ࠧ����)
    mpsih21, m1psih21 := 0, ;  // ��宬��ୠ� ���: (��ଠ, �⪫������)
    mpsih22, m1psih22 := 0, ;  // ��⥫����: (��ଠ, �⪫������)
    mpsih23, m1psih23 := 0, ;  // ���樮���쭮-�����⨢��� ���: (��ଠ, �⪫������)
    m141p   := 0, ; // ������� ��㫠 ����稪� P
    m141ax  := 0, ; // ������� ��㫠 ����稪� Ax
    m141fa  := 0, ; // ������� ��㫠 ����稪� Fa
    m142p   := 0, ; // ������� ��㫠 ����窨 P
    m142ax  := 0, ; // ������� ��㫠 ����窨 Ax
    m142ma  := 0, ; // ������� ��㫠 ����窨 Ma
    m142me  := 0, ; // ������� ��㫠 ����窨 Me
    m142me1 := 0, ; // ������� ��㫠 ����窨 - menarhe (���)
    m142me2 := 0, ; // ������� ��㫠 ����窨 - menarhe (����楢)
    m142me3, m1142me3 := 0, ; // ������� ��㫠 ����窨 - menses (�ࠪ���⨪�):
    m142me4, m1142me4 := 1, ; // ������� ��㫠 ����窨 - menses (�ࠪ���⨪�):
    m142me5, m1142me5 := 1, ; // ������� ��㫠 ����窨 - menses (�ࠪ���⨪�):
    mdiag_15_1, m1diag_15_1 := 1, ; // ����ﭨ� ���஢�� �� �஢������ ���ᬮ��-�ࠪ��᪨ ���஢
    mdiag_15[ 5, 14 ], ; //
    mGRUPPA_DO := 0, ; // ��㯯� ���஢�� �� ���-��
    mGR_FIZ_DO, m1GR_FIZ_DO := 1, ;
    mdiag_16_1, m1diag_16_1 := 1, ; // ����ﭨ� ���஢�� �� १���⠬ �஢������ ���ᬮ�� (�ࠪ��᪨ ���஢)
    mdiag_16[ 5, 16 ], ; //
    minvalid[ 8 ], ;  // ࠧ��� 16.7
    mGRUPPA := 0, ;    // ��㯯� ���஢�� ��᫥ ���-��
    mGR_FIZ, m1GR_FIZ := 1, ;
    mPRIVIVKI[ 3 ], ; // �஢������ ��䨫����᪨� �ਢ����
    mrek_form := Space( 255 ), ; // 'C100',���������樨 �� �ନ஢���� ���஢��� ��ࠧ� �����, ०��� ���, ��⠭��, 䨧��᪮�� ࠧ����, ���㭮��䨫��⨪�, ������ 䨧��᪮� �����ன
    mrek_disp := Space( 255 ), ; // 'C100',���������樨 �� ��ᯠ��୮�� �������, ��祭��, ����樭᪮� ॠ�����樨 � ᠭ��୮-����⭮�� ��祭�� � 㪠������ �������� (��� ���), ���� ����樭᪮� �࣠����樨 � ᯥ樠�쭮�� (��������) ���
    mhormon := '0 ��.', m1hormon := 1, not_hormon, ;
    mstep2, m1step2 := 0, m1p_otk := 0, musl2 := '���', m1usl2 := 0 //, ;
//    mm_step2 := { { '���  ', 0 }, { '��   ', 1 }, { '�����', 2 } }
  Private minvalid1, m1invalid1 := 0, ;
    minvalid2, m1invalid2 := 0, ;
    minvalid3 := CToD( '' ), minvalid4 := CToD( '' ), ;
    minvalid5, m1invalid5 := 0, ;
    minvalid6, m1invalid6 := 0, ;
    minvalid7 := CToD( '' ), ;
    minvalid8, m1invalid8 := 0
  Private mprivivki1, m1privivki1 := 0, ;
    mprivivki2, m1privivki2 := 0, ;
    mprivivki3 := Space( 100 )
  Private mvar, m1var, m1lis := 0
  Private mDS_ONK, m1DS_ONK := 0 // �ਧ��� �����७�� �� �������⢥���� ������ࠧ������
  Private mdopo_na, m1dopo_na := 0
  Private mm_dopo_na := arr_mm_dopo_na()
  Private gl_arr := { ;  // ��� ��⮢�� �����
    { 'dopo_na', 'N', 10, 0, , , , {| x| inieditspr( A__MENUBIT, mm_dopo_na, x ) } };
  }
  Private mnapr_v_mo, m1napr_v_mo := 0, mm_napr_v_mo := arr_mm_napr_v_mo(), ;
    arr_mo_spec := {}, ma_mo_spec, m1a_mo_spec := 1
  Private mnapr_stac, m1napr_stac := 0, mm_napr_stac := arr_mm_napr_stac(), ;
    mprofil_stac, m1profil_stac := 0
  Private mnapr_reab, m1napr_reab := 0, mprofil_kojki, m1profil_kojki := 0, arr_usl_otkaz := {}
  Private mm_otkaz := { { '�믮�.', 0 }, { '����� ', 1 } }, is_neonat := .f.

  Private mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

  Private m1NAPR_MO, mNAPR_MO, mNAPR_DATE, mNAPR_V, m1NAPR_V, mMET_ISSL, m1MET_ISSL, ;
    mshifr, mshifr1, mname_u, mU_KOD, cur_napr := 0, count_napr := 0, tip_onko_napr := 0, ;
    mTab_Number := 0

  arr_osmotr_KDP2 := np_arr_osmotr_KDP2()
  arr_not_zs := np_arr_not_zs() 
  For i := 1 To 5
    For k := 1 To 14
      s := 'diag_15_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := 'm1' + s
        Private &m1var := 0
        Private &mvar := Space( 4 )
      Endif
    Next
  Next
  //
  For i := 1 To 5
    For k := 1 To 16
      s := 'diag_16_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := 'm1' + s
        Private &m1var := 0
        Private &mvar := Space( 3 )
      Endif
    Next
  Next
//  For i := 1 To count_pn_arr_iss // ��᫥�������
  For i := 1 To count_pn_arr_iss( Date() ) // ��᫥�������
    If eq_any( i, 8, 10 )  // ����⮫�� � ���᪨� �������
      m1var := 'M1ONKO' + lstr( i )
      Private &m1var := 0
      mvar := 'MONKO' + lstr( i )
      Private &mvar := inieditspr( A__MENUVERT, mm_vokod(), &m1var )
    Endif
    mvar := 'MTAB_NOMiv' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMia' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATEi' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MREZi' + lstr( i )
    Private &mvar := Space( 17 )
    mvar := 'MOTKAZi' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := 'M1OTKAZi' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
    m1var := 'M1LIS' + lstr( i )
    Private &m1var := 0
    mvar := 'MLIS' + lstr( i )
    Private &mvar := inieditspr( A__MENUVERT, mm_kdp2, &m1var )
  Next
//  For i := 1 To count_pn_arr_osm // �ᬮ���
/*
  For i := 1 To count_pn_arr_osm( Date() ) // �ᬮ���
    mvar := 'MTAB_NOMov' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMoa' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATEo' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MKOD_DIAGo' + lstr( i )
    Private &mvar := Space( 6 )
    mvar := 'MOTKAZo' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := 'M1OTKAZo' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
  Next
  For i := 1 To 2                // �������(�)
    mvar := 'MTAB_NOMpv' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMpa' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATEp' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MKOD_DIAGp' + lstr( i )
    Private &mvar := Space( 6 )
    mvar := 'MOTKAZp' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := 'M1OTKAZp' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
  Next
*/
  //
  AFill( adiag_talon, 0 )
  //
  dbCreate( cur_dir() + 'tmp', { ;
    { 'U_KOD',    'N',      4,      0 }, ;  // ��� ��㣨
    { 'U_SHIFR',    'C',     10,      0 }, ;  // ��� ��㣨
    { 'U_NAME',     'C',     65,      0 } ;  // ������������ ��㣨
  } )
  Use ( cur_dir() + 'tmp' )
  Index On Str( FIELD->u_kod, 4 ) to ( cur_dir() + 'tmpk' )
  Index On fsort_usl( FIELD->u_shifr ) to ( cur_dir() + 'tmpn' )
  Set Index to ( cur_dir() + 'tmpk' ), ( cur_dir() + 'tmpn' )
  r_use( dir_DB + 'human_', , 'HUMAN_' )
  r_use( dir_DB + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  If mkod_k > 0
    r_use( dir_DB + 'kartote2', , 'KART2' )
    Goto ( mkod_k )
    r_use( dir_DB + 'kartote_', , 'KART_' )
    Goto ( mkod_k )
    r_use( dir_DB + 'kartotek', , 'KART' )
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
    m1okato     := kart_->KVARTAL_D // ����� ��ꥪ� �� ����ਨ ���客����
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
      mnameismo := ret_inogsmo_name( 1,, .t. ) // ������ � �������
    Endif
    // �஢�ઠ ��室� = ������ � ���� �।���� ��䨫��⨪
    Select HUMAN
    Set Index to ( dir_DB + 'humankk' )
    find ( Str( mkod_k, 7 ) )
    Do While human->kod_k == mkod_k .and. !Eof()
      If RecNo() != Loc_kod .and. human_->oplata != 9 .and. human_->NOVOR == 0 .and. Year( human->k_data ) > 2017
        If is_death( human_->RSLT_NEW )
          a_smert := { '����� ���쭮� 㬥�!', ;
            '��祭�� � ' + full_date( human->N_DATA ) + ;
            ' �� ' + full_date( human->K_DATA ) }
        Endif
        If eq_any( human->ishod, 301, 302 ) // �᫨ ��䨫��⨪� ��ᮢ��襭����⭨�
          read_arr_pn( human->kod, .f. ) // �⠥� ��६����� 'mperiod'
          _mperiod := mperiod
          arr_PN_issled := np_arr_issled( human->k_data )
          arr_PN_osmotr := np_arr_osmotr( human->k_data )
          If _mperiod > 0
            AAdd( arr_prof, { _mperiod, human->n_data, human->k_data } )
            If eq_any( _mperiod, 1, 2 )
              r_use( dir_DB + 'uslugi', , 'USL' )
              r_use( dir_DB + 'human_u', dir_DB + 'human_u', 'HU' )
              find ( Str( human->kod, 7 ) )
              Do While hu->kod == human->kod .and. !Eof()
                usl->( dbGoto( hu->u_kod ) )
                If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
                  lshifr := usl->shifr
                Endif
                If AllTrim( lshifr ) == '3.5.4' // �㤨������᪨� �ਭ���
                  is_3_5_4 := .t.
                Endif
                Select HU
                Skip
              Enddo
              hu->( dbCloseArea() )
              usl->( dbCloseArea() )
            Endif
          Endif
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
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
    m1VRACH     := human_->vrach
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
    metap      := human->ishod -300
    mGRUPPA    := human_->RSLT_NEW - L_BEGIN_RSLT
    is_disp_19 := !( mk_data < 0d20191101 )
    If metap == 2
      m1step2 := 1
    Endif
    arr_PN_osmotr := np_arr_osmotr( mk_data )
    //
//    larr_i := Array( count_pn_arr_iss )
    larr_i := Array( count_pn_arr_iss( mk_data ) )
    AFill( larr_i, 0 )
    larr_o := Array( Len( arr_PN_osmotr ) ) //count_pn_arr_osm( mk_data ) )
    AFill( larr_o, 0 )
    larr_p := {}
    mdate1 := mdate2 := CToD( '' )
    r_use( dir_DB + 'uslugi', , 'USL' )
    use_base( 'human_u' )
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
        lshifr := usl->shifr
      Endif
      lshifr := AllTrim( lshifr )
      If Left( lshifr, 5 ) == '72.2.'
        mshifr_zs := lshifr
      Elseif hu->is_edit == -1
        Select TMP
        Append Blank
        tmp->U_KOD := hu->u_kod
        tmp->U_SHIFR := usl->shifr
        tmp->U_NAME := usl->name
        ++m1usl2
      Else
        fl := .t.
//        For i := 1 To count_pn_arr_iss
        For i := 1 To count_pn_arr_iss( mk_data )
//          If np_arr_issled[ i, 1 ] == lshifr
          If arr_PN_issled[ i, 1 ] == lshifr
            fl := .f.
            larr_i[ i ] := hu->( RecNo() )
            Exit
//          Elseif ( j := AScan( np_arr_not_zs, {| x| x[ 2 ] == lshifr } ) ) > 0 .and. np_arr_issled[ i, 1 ] == np_arr_not_zs[ j, 1 ]
          Elseif ( j := AScan( arr_not_zs, {| x| x[ 2 ] == lshifr } ) ) > 0 .and. arr_PN_issled[ i, 1 ] == arr_not_zs[ j, 1 ]
            fl := .f.
            larr_i[ i ] := hu->( RecNo() )
            Exit
          Endif
        Next
        If fl
//          For i := 1 To count_pn_arr_osm( mk_data )
//            If Left( np_arr_osmotr[ i, 1 ], 4 ) == '2.4.'
//              If lshifr == np_arr_osmotr[ i, 1 ]
          For i := 1 To Len( arr_PN_osmotr )
            If Left( arr_PN_osmotr[ i, 1 ], 4 ) == '2.4.'
              If lshifr == arr_PN_osmotr[ i, 1 ]
                fl := .f.
                larr_o[ i ] := hu->( RecNo() )
                Exit
              Endif
//            Elseif f_profil_ginek_otolar( np_arr_osmotr[ i, 4 ], hu_->PROFIL )
            Elseif f_profil_ginek_otolar( arr_PN_osmotr[ i, 4 ], hu_->PROFIL )
              fl := .f.
              larr_o[ i ] := hu->( RecNo() )
              Exit
            Endif
          Next i
        Endif
        If fl .and. eq_any( hu_->PROFIL, 68, 57 )
          AAdd( larr_p, { hu->( RecNo() ), c4tod( hu->date_u ) } )
        Endif
      Endif
      AAdd( arr_usl, hu->( RecNo() ) )
      Select HU
      Skip
    Enddo
    If m1step2 == 1
      musl2 := '���-�� ��� - ' + lstr( m1usl2 )
    Else
      m1usl2 := 0
      Select TMP
      Zap
    Endif
    If Len( larr_p ) > 1 // �᫨ �ᬮ�� ������� I �⠯� ������� ������� II �⠯�
      ASort( larr_p,,, {| x, y| x[ 2 ] < y[ 2 ] } )
      If metap == 1
        ASize( larr_p, 1 ) // ��१��� ��譨� ����
      Else
        Do While Len( larr_p ) > 2 // ����� ������� I �⠯� ����� ��� ��� ��㣨 (2.3.* � 2.91.*)
          hb_ADel( larr_p, 2, .t. ) // �.�. ��⠢�塞 ���� � ��᫥���� ���
        Enddo
      Endif
    Endif
    r_use( dir_DB + 'mo_pers', , 'P2' )
    For j := 1 To 3
      If j == 1
        _arr := larr_i
        bukva := 'i'
      Elseif j == 2
        _arr := larr_o
        bukva := 'o'
      Else
        _arr := larr_p
        bukva := 'p'
      Endif
      For i := 1 To Len( _arr )
        k := iif( j == 3, _arr[ i, 1 ], _arr[ i ] )
        If !Empty( k )
          hu->( dbGoto( k ) )
          If hu->kod_vr > 0
            p2->( dbGoto( hu->kod_vr ) )
            mvar := 'MTAB_NOM' + bukva + 'v' + lstr( i )
            &mvar := p2->tab_nom
          Endif
          If hu->kod_as > 0
            p2->( dbGoto( hu->kod_as ) )
            mvar := 'MTAB_NOM' + bukva + 'a' + lstr( i )
            &mvar := p2->tab_nom
          Endif
          mvar := 'MDATE' + bukva + lstr( i )
          &mvar := c4tod( hu->date_u )
          If j == 1
            m1var := 'm1lis' + lstr( i )
            If is_disp_19
              &m1var := 0
//            Elseif glob_yes_kdp2()[ TIP_LU_PN ] .and. AScan( glob_arr_usl_LIS, np_arr_issled[ i, 1 ] ) > 0 .and. hu->is_edit > 0
            Elseif glob_yes_kdp2()[ TIP_LU_PN ] .and. AScan( glob_arr_usl_LIS, arr_PN_issled[ i, 1 ] ) > 0 .and. hu->is_edit > 0
              &m1var := hu->is_edit
            Endif
            mvar := 'mlis' + lstr( i )
            &mvar := inieditspr( A__MENUVERT, mm_kdp2, &m1var )
          Elseif j == 2 .and. eq_any( i, 8, 10 )
            m1var := 'm1onko' + lstr( i )
            If hu->is_edit > 0
              &m1var := hu->is_edit
            Endif
            mvar := 'monko' + lstr( i )
            &mvar := inieditspr( A__MENUVERT, mm_vokod(), &m1var )
          Elseif !Empty( hu_->kod_diag ) .and. !( Left( hu_->kod_diag, 1 ) == 'Z' )
            mvar := 'MKOD_DIAG' + bukva + lstr( i )
            &mvar := hu_->kod_diag
          Endif
          m1var := 'M1OTKAZ' + bukva + lstr( i )
          &m1var := 0 // �믮�����
          mvar := 'MOTKAZ' + bukva + lstr( i )
          &mvar := inieditspr( A__MENUVERT, mm_otkaz, &m1var )
        Endif
      Next
    Next
    read_arr_pn( Loc_kod )
    If metap == 1 .and. m1p_otk == 1
      m1step2 := 2
    Endif
    If ValType( arr_usl_otkaz ) == 'A'
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) > 9 .and. ValType( ar[ 5 ] ) == 'C' .and. ;
            ValType( ar[ 10 ] ) == 'C' .and. ar[ 10 ] $ 'io'
          lshifr := AllTrim( ar[ 5 ] )
          bukva := ar[ 10 ]
//          If ( i := AScan( iif( bukva == 'i', np_arr_issled, np_arr_osmotr ), {| x| ValType( x[ 1 ] ) == 'C' .and. x[ 1 ] == lshifr } ) ) > 0
          If ( i := AScan( iif( bukva == 'i', arr_PN_issled, arr_PN_osmotr ), {| x| ValType( x[ 1 ] ) == 'C' .and. x[ 1 ] == lshifr } ) ) > 0
            If ValType( ar[ 1 ] ) == 'N' .and. ar[ 1 ] > 0
              p2->( dbGoto( ar[ 1 ] ) )
              mvar := 'MTAB_NOM' + bukva + 'v' + lstr( i )
              &mvar := p2->tab_nom
            Endif
            If ValType( ar[ 3 ] ) == 'N' .and. ar[ 3 ] > 0
              p2->( dbGoto( ar[ 3 ] ) )
              mvar := 'MTAB_NOM' + bukva + 'a' + lstr( i )
              &mvar := p2->tab_nom
            Endif
            mvar := 'MDATE' + bukva + lstr( i )
            &mvar := mn_data
            If ValType( ar[ 9 ] ) == 'D'
              &mvar := ar[ 9 ]
            Endif
            m1var := 'M1OTKAZ' + bukva + lstr( i )
            &m1var := 1 // �⪠�
            mvar := 'MOTKAZ' + bukva + lstr( i )
            &mvar := inieditspr( A__MENUVERT, mm_otkaz, &m1var )
          Endif
        Endif
      Next
    Endif
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 2, @rec_inogSMO, .t. ) // ������ � �������
    Endif
  Endif
  If !( Left( msmo, 2 ) == '34' ) // �� ������ࠤ᪠� �������
    m1ismo := msmo
    msmo := '34'
  Endif

  dbCreate( cur_dir() + 'tmp_onkna', create_struct_temporary_onkna() )
  cur_napr := 1 // �� ।-�� - ᭠砫� ��ࢮ� ���ࠢ����� ⥪�饥
  count_napr := collect_napr_zno( Loc_kod )
  If count_napr > 0
    mnapr_onk := '������⢮ ���ࠢ����� - ' + lstr( count_napr )
  Endif

  Close databases
  is_talon := .t.

  fv_date_r( iif( Loc_kod > 0, mn_data, ) )
  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  mlpu      := inieditspr( A__POPUPMENU, dir_DB + 'mo_uch', m1lpu )
  motd      := inieditspr( A__POPUPMENU, dir_DB + 'mo_otd', m1otd )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf(), m1okato )
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
  //
  mmesto_prov := inieditspr( A__MENUVERT, mm_mesto_prov, m1mesto_prov ) // ���� �஢������
  mmobilbr := inieditspr( A__MENUVERT, mm_danet, m1mobilbr )
  mschool := inieditspr( A__POPUPMENU, dir_DB + 'mo_schoo', m1school )
  mkateg_uch := inieditspr( A__MENUVERT, mm_kateg_uch(), m1kateg_uch )
  If !Empty( m1MO_PR )
    mMO_PR := ret_mo( m1MO_PR )[ _MO_SHORT_NAME ]
  Endif
  mfiz_razv  := inieditspr( A__MENUVERT, mm_fiz_razv(),  m1FIZ_RAZV )
  mfiz_razv1 := inieditspr( A__MENUVERT, mm_fiz_razv1(), m1FIZ_RAZV1 )
  mfiz_razv2 := inieditspr( A__MENUVERT, mm_fiz_razv2(), m1FIZ_RAZV2 )
  mpsih21 := inieditspr( A__MENUVERT, mm_psih2(), m1psih21 )
  mpsih22 := inieditspr( A__MENUVERT, mm_psih2(), m1psih22 )
  mpsih23 := inieditspr( A__MENUVERT, mm_psih2(), m1psih23 )
  m142me3 := inieditspr( A__MENUVERT, mm_142me3(), m1142me3 )
  m142me4 := inieditspr( A__MENUVERT, mm_142me4(), m1142me4 )
  m142me5 := inieditspr( A__MENUVERT, mm_142me5(), m1142me5 )
  mdiag_15_1 := inieditspr( A__MENUVERT, mm_danet, m1diag_15_1 )
  mdiag_16_1 := inieditspr( A__MENUVERT, mm_danet, m1diag_16_1 )
  mstep2 := inieditspr( A__MENUVERT, mm_step2, m1step2 )
  minvalid1 := inieditspr( A__MENUVERT, mm_danet,    m1invalid1 )
  minvalid2 := inieditspr( A__MENUVERT, mm_invalid2(), m1invalid2 )
  minvalid5 := inieditspr( A__MENUVERT, mm_invalid5(), m1invalid5 )
  minvalid6 := inieditspr( A__MENUVERT, mm_invalid6(), m1invalid6 )
  minvalid8 := inieditspr( A__MENUVERT, mm_invalid8(), m1invalid8 )
  mprivivki1 := inieditspr( A__MENUVERT, mm_privivki1(), m1privivki1 )
  mprivivki2 := inieditspr( A__MENUVERT, mm_privivki2(), m1privivki2 )
  mgr_fiz_do := inieditspr( A__MENUVERT, mm_gr_fiz_do, m1gr_fiz_do )
  mgr_fiz    := inieditspr( A__MENUVERT, mm_gr_fiz, m1gr_fiz )
  mDS_ONK    := inieditspr( A__MENUVERT, mm_danet, M1DS_ONK )
  mdopo_na   := inieditspr( A__MENUBIT,  mm_dopo_na, m1dopo_na )
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
  //
  If !Empty( f_print )
    return &( f_print + '(' + lstr( Loc_kod ) + ',' + lstr( kod_kartotek ) + ',' + lstr( mdvozrast ) + ')' )
  Endif
  //
  str_1 := ' ���� ��䨫��⨪� ��ᮢ��襭����⭨�'
  If Loc_kod == 0
    str_1 := '����������' + str_1
    mtip_h := yes_vypisan
  Else
    str_1 := '������஢����' + str_1
  Endif
  SetColor( color8 )
  //
  Private gl_area
  SetColor( cDataCGet )
  make_diagp( 1 )  // ᤥ���� '��⨧����' ��������
  Private num_screen := 1
  Do While .t.
    Close databases
    DispBegin()
    If num_screen == 5
      hS := 32
      wS := 90
      If m1step2 == 2
        hS += 2
      Endif
    Elseif num_screen == 3
      hS := 30
      wS := 80
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
      s1 := ' '
      is_disp_19 := !( mk_data < 0d20191101 )
      arr_PN_issled := np_arr_issled( mk_data )
      arr_PN_osmotr := np_arr_osmotr( mk_data )
      mperiod := ret_period_pn( mdate_r, mn_data, mk_data, @s1 )
      s := AllTrim( mfio )
      If mperiod > 0
        s += s1
      Endif
      @ j, wS - Len( s ) Say s Color color14
      If !Between( mperiod, 1, 31 )
        DispEnd()
        func_error( 4, '�� 㤠���� ��।����� �����⭮� ��ਮ�!' )
        If !Empty( s1 )
          func_error( 10, s1 )
        Endif
        num_screen := 1
        Loop
      Elseif ( i := AScan( arr_prof, {| x| x[ 1 ] == mperiod } ) ) > 0
        DispEnd()
        func_error( 4, '��� �뫠 �������筠� ��䨫��⨪� � ' + date_8( arr_prof[ i, 2 ] ) + ' �� ' + date_8( arr_prof[ i, 3 ] ) )
        num_screen := 1
        Loop
      Endif
    Endif
    If num_screen == 1
      @ ++j, 1 Say '��०�����' Get mlpu When .f. Color cDataCSay
      @ Row(), Col() + 2 Say '�⤥�����' Get motd When .f. Color cDataCSay
      //
      @ ++j, 1 Say '���' Get mfio_kart ;
        reader {| x| menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
        valid {| g, o| update_get( 'mkomu' ), update_get( 'mcompany' ) }
      @ ++j, 1 Say '�ਭ���������� ����' Get mkomu ;
        reader {| x| menu_reader( x, mm_komu, A__MENUVERT, , , .f. ) } ;
        valid {| g, o| f_valid_komu( g, o ) } ;
        Color colget_menu
      @ Row(), Col() + 1 Say '==>' Get mcompany ;
        reader {| x| menu_reader( x, mm_company, A__MENUVERT, , , .f. ) } ;
        When m1komu < 5 ;
        valid {| g| func_valid_ismo( g, m1komu, 38 ) }
      @ ++j, 1 Say '����� ���: ���' Get mspolis When m1komu == 0
      @ Row(), Col() + 3 Say '�����'  Get mnpolis When m1komu == 0
      @ Row(), Col() + 3 Say '���'    Get mvidpolis ;
        reader {| x| menu_reader( x, mm_vid_polis, A__MENUVERT, , , .f. ) } ;
        When m1komu == 0 ;
        Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
      @ ++j, 1 To j, 78
      @ ++j, 1 Say '��⥣��� ��� ॡ����' Get mkateg_uch ;
        reader {| x| menu_reader( x, mm_kateg_uch(), A__MENUVERT, , , .f. ) }
      ++j
      @ ++j, 1 Say '�ப� ��䨫��⨪�' Get mn_data ;
        valid {| g| f_k_data( g, 1 ), ;
        iif( mvozrast < 18, nil, func_error( 4, '�� ����� ��樥��!' ) ), ;
        msvozrast := PadR( count_ymd( mdate_r, mn_data ), 40 ), ;
        .t. ;
        }
      @ Row(), Col() + 1 Say '-' Get mk_data valid {| g| f_k_data( g, 2 ) }
      @ Row(), Col() + 3 Get msvozrast When .f. Color color14
      @ ++j, 1 Say '� ���㫠�୮� �����' Get much_doc Picture '@!' ;
        When !( is_uchastok == 1 .and. is_task( X_REGIST ) ) ;
        .or. mem_edit_ist == 2
      @ ++j, 1 Say '���� �஢������ ����ᬮ��' Get mmesto_prov ;
        reader {| x| menu_reader( x, mm_mesto_prov, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '����ᬮ�� �஢��� �����쭮� �ਣ����?' Get mmobilbr ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      ++j
      @ ++j, 1 Say '�� �ਪ९�����' Get mMO_PR ;
        reader {| x| menu_reader( x, { {| k, r, c| f_get_mo( k, r, c ) } }, A__FUNCTION, , , .f. ) }
      @ ++j, 1 Say '��饮�ࠧ���⥫쭮� ��०�����' Get mschool ;
        reader {| x| menu_reader( x, { dir_DB + 'mo_schoo', , , , , , '��饮�ࠧ���⥫�� ���-��', 'B/BG' }, A__POPUPBASE, , , .f. ) }
      ++j
      @ ++j, 1 Say '���' Get mWEIGHT Pict '999' ;
        valid {|| iif( Between( mWEIGHT, 2, 170 ), , func_error( 4, '��ࠧ㬭� ���' ) ), .t. }
      @ Row(), Col() + 1 Say '��, ���' Get mHEIGHT Pict '999' ;
        valid {|| iif( Between( mHEIGHT, 40, 250 ), , func_error( 4, '��ࠧ㬭� ���' ) ), .t. }
      @ Row(), Col() + 1 Say '�, ���㦭���� ������' Get mPER_HEAD  Pict '999' ;
        valid {|| iif( mdvozrast < 5, iif( Between( mPER_HEAD, 10, 100 ), , func_error( 4, '��ࠧ㬭� ࠧ��� ���㦭��� ������' ) ), ), .t. }
      @ Row(), Col() + 1 Say '�'
      ++j
      @ ++j, 1 Say '�����᪮� ࠧ��⨥' Get mfiz_razv ;
        reader {| x| menu_reader( x, mm_fiz_razv(), A__MENUVERT, , , .f. ) } ;
        valid {|| iif( m1FIZ_RAZV == 0, ( mfiz_razv1 := '���    ', m1fiz_razv1 := 0, ;
        mfiz_razv2 := '���    ', m1fiz_razv2 := 0 ), nil ), .t. }
      @ ++j, 10 Say '�⪫������ ����� ⥫�' Get mfiz_razv1 ;
        reader {| x| menu_reader( x, mm_fiz_razv1(), A__MENUVERT, , , .f. ) } ;
        When m1FIZ_RAZV == 1
      @ j, 39 Say ', ���' Get mfiz_razv2 ;
        reader {| x| menu_reader( x, mm_fiz_razv2(), A__MENUVERT, , , .f. ) } ;
        When m1FIZ_RAZV == 1
      status_key( '^<Esc>^ ��室 ��� ����� ^<PgDn>^ �� 2-� ��࠭���' )
      If !Empty( a_smert )
        n_message( a_smert, , 'GR+/R', 'W+/R', , , 'G+/R' )
      Endif
    Elseif num_screen == 2
      np_oftal_2_85_21( mperiod, mk_data )
      ar := np_arr_1_etap( mk_data )[ mperiod ]

//  For i := 1 To count_pn_arr_osm // �ᬮ���
  For i := 1 To Len( arr_PN_osmotr )  //count_pn_arr_osm( mk_data ) // �ᬮ���
    mvar := 'MTAB_NOMov' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMoa' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATEo' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MKOD_DIAGo' + lstr( i )
    Private &mvar := Space( 6 )
    mvar := 'MOTKAZo' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := 'M1OTKAZo' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
  Next
  For i := 1 To 2                // �������(�)
    mvar := 'MTAB_NOMpv' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMpa' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATEp' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MKOD_DIAGp' + lstr( i )
    Private &mvar := Space( 6 )
    mvar := 'MOTKAZp' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 1 ]
    mvar := 'M1OTKAZp' + lstr( i )
    Private &mvar := mm_otkaz[ 1, 2 ]
  Next


      If !Empty( ar[ 5 ] ) // �� ���⮩ ���ᨢ ��᫥�������
        @ ++j, 1 Say 'I �⠯ ������������ ��᫥�������       ��� ����.  ���     �믮������ �������' Color 'RB+/B'
        If mem_por_ass == 0
          @ j, 45 Say Space( 6 )
        Endif
        not_hormon := .t.
//        For i := 1 To count_pn_arr_iss
        For i := 1 To count_pn_arr_iss( mk_data )
          fl := .t.
//          If fl .and. !Empty( np_arr_issled[ i, 2 ] )
          If fl .and. !Empty( arr_PN_issled[ i, 2 ] )
            fl := ( mpol == np_arr_issled[ i, 2 ] )
          Endif
          If fl
//            fl := ( AScan( ar[ 5 ], np_arr_issled[ i, 1 ] ) > 0 )
            fl := ( AScan( ar[ 5 ], arr_PN_issled[ i, 1 ] ) > 0 )
          Endif
          /*//if fl .and. np_arr_issled[i, 4] == 1 // ��ମ�
          if fl .and. arr_PN_issled[i, 4] == 1 // ��ମ�
            if not_hormon
         ++j; @ j, 1 say padr('��᫥������� �஢�� ��ମ��� � �஢�', 38) color color8
              @ j, 39 get mhormon ;
                 reader {|x| menu_reader(x, {{|k,r,c| get_hormon_pn(k,r,c)}},A__FUNCTION,,, .f.)}
            endif
            fl := not_hormon := .f.
          endif*/
          If fl
            fl_kdp2 := .f.
//            If !is_disp_19 .and. glob_yes_kdp2()[ TIP_LU_PN ] .and. AScan( glob_arr_usl_LIS, np_arr_issled[ i, 1 ] ) > 0
            If !is_disp_19 .and. glob_yes_kdp2()[ TIP_LU_PN ] .and. AScan( glob_arr_usl_LIS, arr_PN_issled[ i, 1 ] ) > 0
              fl_kdp2 := .t.
            Endif
            mvarv := 'MTAB_NOMiv' + lstr( i )
            mvara := 'MTAB_NOMia' + lstr( i )
            mvard := 'MDATEi' + lstr( i )
            mvarr := 'MREZi' + lstr( i )
            mvaro := 'MOTKAZi' + lstr( i )
            mvarlis := 'MLIS' + lstr( i )
            If Empty( &mvard )
              &mvard := mn_data
            Endif
//            @ ++j, 1 Say PadR( np_arr_issled[ i, 3 ], 38 )
            @ ++j, 1 Say PadR( arr_PN_issled[ i, 3 ], 38 )
            If fl_kdp2
              @ j, 34 get &mvarlis reader {| x| menu_reader( x, mm_kdp2, A__MENUVERT, , , .f. ) }
            Endif
            @ j, 39 get &mvarv Pict '99999' valid {| g| v_kart_vrach( g ) }
            If mem_por_ass > 0
              @ j, 45 get &mvara Pict '99999' valid {| g| v_kart_vrach( g ) }
            Endif
            @ j, 51 get &mvard
            @ j, 62 get &mvaro reader {| x| menu_reader( x, mm_otkaz, A__MENUVERT, , , .f. ) }
            @ j, 69 get &mvarr
          Endif
        Next
      Endif
      @ ++j, 1 Say 'I �⠯ ������������ �ᬮ�஢           ��� ����.  ���     �믮������' Color 'RB+/B'
      If mem_por_ass == 0
        @ j, 45 Say Space( 6 )
      Endif
      If !Empty( ar[ 4 ] ) // �� ���⮩ ���ᨢ �ᬮ�஢
        For i := 1 To Len( arr_PN_osmotr )  // count_pn_arr_osm
          fl := .t.
//          If fl .and. !Empty( np_arr_osmotr[ i, 2 ] )
//            fl := ( mpol == np_arr_osmotr[ i, 2 ] )
          If fl .and. !Empty( arr_PN_osmotr[ i, 2 ] )
            fl := ( mpol == arr_PN_osmotr[ i, 2 ] )
          Endif
          If fl
//            fl := ( AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) > 0 )
            fl := ( AScan( ar[ 4 ], arr_PN_osmotr[ i, 1 ] ) > 0 )
          Endif
/*
          If fl .and. mperiod == 16 .and. mk_data < 0d20191101 .and. np_arr_osmotr[ i, 1 ] == '2.4.2' // 2 ����
            fl := .f.
          Endif
          If fl .and. mperiod == 20 .and. mk_data < 0d20191101 .and. np_arr_osmotr[ i, 1 ] == '2.85.24' // 6 ���
            fl := .f.
          Endif
*/
          If fl .and. mperiod == 16 .and. mk_data < 0d20191101 .and. arr_PN_osmotr[ i, 1 ] == '2.4.2' // 2 ����
            fl := .f.
          Endif
          If fl .and. mperiod == 20 .and. mk_data < 0d20191101 .and. arr_PN_osmotr[ i, 1 ] == '2.85.24' // 6 ���
            fl := .f.
          Endif
          If fl
            mvarv := 'MTAB_NOMov' + lstr( i )
            mvara := 'MTAB_NOMoa' + lstr( i )
            mvard := 'MDATEo' + lstr( i )
            mvaro := 'MOTKAZo' + lstr( i )
            mvarz := 'MKOD_DIAGo' + lstr( i )
            If Empty( &mvard )
              &mvard := mn_data
            Endif
//            @ ++j, 1 Say PadR( np_arr_osmotr[ i, 3 ], 38 )
            @ ++j, 1 Say PadR( arr_PN_osmotr[ i, 3 ], 38 )
            @ j, 39 get &mvarv Pict '99999' valid {| g| v_kart_vrach( g ) }
            If mem_por_ass > 0
              @ j, 45 get &mvara Pict '99999' valid {| g| v_kart_vrach( g ) }
            Endif
            @ j, 51 get &mvard
            @ j, 62 get &mvaro reader {| x| menu_reader( x, mm_otkaz, A__MENUVERT, , , .f. ) }
          Endif
        Next
      Endif
      If Empty( MDATEp1 )
        MDATEp1 := mn_data
      Endif
      @ ++j, 1 Say PadR( '������� (��� ��饩 �ࠪ⨪�)', 38 ) Color color8
      @ j, 39 Get MTAB_NOMpv1 Pict '99999' valid {| g| v_kart_vrach( g ) }
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMpa1 Pict '99999' valid {| g| v_kart_vrach( g ) }
      Endif
      @ j, 51 Get MDATEp1
      status_key( '^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 1-� ��࠭��� ^<PgDn>^ �� 3-� ��࠭���' )
    Elseif num_screen == 3
      @ ++j, 1 Say '���ࠢ��� �� II �⠯ ?' Get mstep2 ;
        reader {| x| menu_reader( x, mm_step2, A__MENUVERT, , , .f. ) }
      If !is_disp_19
        ++j
        @ ++j, 1 Say '�������⥫�� ����⮫����᪨� ��᫥������� � ���2' Get musl2 ;
          reader {| x| menu_reader( x, { {|k, r, c| ob2_v_usl( .t., r + 1 ) } }, A__FUNCTION, , , .f. ) } ;
          When m1step2 == 1
      Endif
      ar := np_arr_1_etap( mk_data )[ mperiod ]
      @ ++j, 1 Say 'II �⠯ ������������ �ᬮ�஢          ��� ����.  ���     �믮������' Color 'RB+/B'
      If mem_por_ass == 0
        @ j, 45 Say Space( 6 )
      Endif
      For i := 1 To Len( arr_PN_osmotr )  // count_pn_arr_osm
        fl := .t.
//        If fl .and. !Empty( np_arr_osmotr[ i, 2 ] )
//          fl := ( mpol == np_arr_osmotr[ i, 2 ] )
        If fl .and. !Empty( arr_PN_osmotr[ i, 2 ] )
          fl := ( mpol == arr_PN_osmotr[ i, 2 ] )
        Endif
        If fl .and. !Empty( ar[ 4 ] )
//          fl := ( AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) == 0 )
          fl := ( AScan( ar[ 4 ], arr_PN_osmotr[ i, 1 ] ) == 0 )
        Endif
//        If fl .and. !( np_arr_osmotr[ i, 1 ] == '2.4.2' )
        If fl .and. !( arr_PN_osmotr[ i, 1 ] == '2.4.2' )
          mvonk := 'MONKO' + lstr( i )
          mvarv := 'MTAB_NOMov' + lstr( i )
          mvara := 'MTAB_NOMoa' + lstr( i )
          mvard := 'MDATEo' + lstr( i )
          mvaro := 'MOTKAZo' + lstr( i )
          mvarz := 'MKOD_DIAGo' + lstr( i )
//          @ ++j, 1 Say PadR( np_arr_osmotr[ i, 3 ], 38 )
          @ ++j, 1 Say PadR( arr_PN_osmotr[ i, 3 ], 38 )
          If eq_any( i, 8, 10 )
            @ j, 32 get &mvonk reader {| x| menu_reader( x, mm_vokod(), A__MENUVERT, , , .f. ) } When m1step2 == 1
          Endif
          @ j, 39 get &mvarv Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
          If mem_por_ass > 0
            @ j, 45 get &mvara Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
          Endif
          @ j, 51 get &mvard When m1step2 == 1
          @ j, 62 get &mvaro reader {| x| menu_reader( x, mm_otkaz, A__MENUVERT, , , .f. ) } When m1step2 == 1
        Endif
      Next
      @ ++j, 1 Say PadR( '������� (��� ��饩 �ࠪ⨪�)', 38 ) Color color8
      @ j, 39 Get MTAB_NOMpv2 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      If mem_por_ass > 0
        @ j, 45 Get MTAB_NOMpa2 Pict '99999' valid {| g| v_kart_vrach( g ) } When m1step2 == 1
      Endif
      @ j, 51 Get MDATEp2 When m1step2 == 1
      status_key( '^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 2-� ��࠭��� ^<PgDn>^ �� 4-� ��࠭���' )
    Elseif num_screen == 4
      If mdvozrast < 5 // �᫨ ����� 5 ���
        @ ++j, 1 Say PadC( '�業�� ����᪮�� ࠧ���� (������ ࠧ����):', 78, '_' )
        @ ++j, 1 Say '�������⥫쭠� �㭪��' Get m1psih11 Pict '99'
        @ ++j, 1 Say '���ୠ� �㭪��      ' Get m1psih12 Pict '99'
        @ --j, 30 Say '�樮���쭠� � �樠�쭠�    ' Get m1psih13 Pict '99'
        @ ++j, 30 Say '�।�祢�� � �祢�� ࠧ��⨥' Get m1psih14 Pict '99'
      Else
        @ ++j, 1 Say PadC( '�業�� ����᪮�� ࠧ����:', 78, '_' )
        @ ++j, 1 Say '��宬��ୠ� ���' Get mpsih21 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT, , , .f. ) }
        @ ++j, 1 Say '��⥫����          ' Get mpsih22 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT, , , .f. ) }
        @ --j, 40 Say '��.�����⨢��� ���' Get mpsih23 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT, , , .f. ) }
        ++j
      Endif
      ++j
      If mpol == '�'
        @ ++j, 1 Say '������� ��㫠 ����稪�: P' Get m141p Pict '9'
        @ j, Col() Say ', Ax' Get m141ax Pict '9'
        @ j, Col() Say ', Fa' Get m141fa Pict '9'
      Else
        @ ++j, 1 Say '������� ��㫠 ����窨: P' Get m142p Pict '9'
        @ j, Col() Say ', Ax' Get m142ax Pict '9'
        @ j, Col() Say ', Ma' Get m142ma Pict '9'
        @ j, Col() Say ', Me' Get m142me Pict '9'
        @ ++j, 1 Say '  menarhe' Get m142me1 Pict '99'
        @ j, Col() + 1 Say '���,' Get m142me2 Pict '99'
        @ j, Col() + 1 Say '����楢, menses' Get m142me3 ;
          reader {| x| menu_reader( x, mm_142me3(), A__MENUVERT, , , .f. ) }
        @ j, 50 Say ',' Get m142me4 ;
          reader {| x| menu_reader( x, mm_142me4(), A__MENUVERT, , , .f. ) }
        @ j, 61 Say ',' Get m142me5 ;
          reader {| x| menu_reader( x, mm_142me5(), A__MENUVERT, , , .f. ) }
      Endif
      ++j
      @ ++j, 1 Say '�� ���������� ����������: �ࠪ��᪨ ���஢' Get mdiag_15_1 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '������������������������������������������������������������������������������'
      @ ++j, 1 Say ' ����-���ᯠ�᳋�祭�� �������믮����������-�� �������믮��������᮪��孮�.��'
      @ ++j, 1 Say ' ���  �����-����-�������������������Ĵ�-������������������������������������'
      @ ++j, 1 Say '      ���⠭����� ���.����.���.����.��� ���.����.���.����.�४������������'
      @ ++j, 1 Say '������������������������������������������������������������������������������'
      For i := 1 To 5
        ++j
        fl := .f.
        For k := 1 To 14
          s := 'diag_15_' + lstr( i ) + '_' + lstr( k )
          mvar := 'm' + s
          If k == 1
            fl := !Empty( &mvar )
          Else
            m1var := 'm1' + s
            If fl
              If eq_any( k, 2 )
                mm_m := mm_dispans
              Elseif eq_any( k, 4, 6, 9, 11 )
                mm_m := mm_usl
              Elseif eq_any( k, 5, 7, 10, 12 )
                mm_m := mm_uch1
              Else
                mm_m := mm_danet
              Endif
              &mvar := inieditspr( A__MENUVERT, mm_m, &m1var )
            Else
              &m1var := 0
              &mvar := Space( 4 )
            Endif
          Endif
          Do Case
          Case k == 1
            @ j, 1 get &mvar Picture pic_diag ;
              reader {| o| mygetreader( o, bg ) } Valid val1_10diag( .t., .f., .f., mn_data, mpol ) ;
              When m1diag_15_1 == 0
          Case k == 2
            @ j, 8 get &mvar ;
              reader {| x| menu_reader( x, mm_dispans, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 3
            @ j, 16 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 4
            @ j, 20 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 5
            @ j, 25 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 6
            @ j, 30 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 7
            @ j, 35 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 8
            @ j, 40 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 9
            @ j, 44 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 10
            @ j, 49 get &mvar ;
              reader {| x| menu_reader( x, mm_uch1, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 11
            @ j, 54 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 12
            @ j, 59 get &mvar ;
              reader {| x| menu_reader( x, mm_uch1, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 13
            @ j, 66 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Case k == 14
            @ j, 74 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_15_1 == 0
          Endcase
        Next
      Next
      @ ++j, 1 To j, 78
      @ ++j, 1 Say '������ ���ﭨ� �������� �� �஢������ ���ᬮ��' Get mGRUPPA_DO Pict '9'
      @ ++j, 1 Say '        ����樭᪠� ������ ��� ������ 䨧�����ன' Get mGR_FIZ_DO ;
        reader {| x| menu_reader( x, mm_gr_fiz_do, A__MENUVERT, , , .f. ) }
      status_key( '^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 3-� ��࠭��� ^<PgDn>^ �� 5-� ��࠭���' )
    Elseif num_screen == 5
      @ ++j, 1 Say '�� ����������� ���������� ����������: �ࠪ��᪨ ���஢' Get mdiag_16_1 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 Say '������������������������������������������������������������������������������'
      @ ++j, 1 Say ' ����-���Ⳅ�ᯠ�᳄��.����.��������.����.�믮���祭�� ����������-�� ���������'
      @ ++j, 1 Say ' ���  ���������-��������������Ĵ������������Ĵ�-���������Ĵ�-���������Ĵ४'
      @ ++j, 1 Say '      �����⠭����� ���.����.��� ���.����.��� ���.����.��� ���.����.����'
      @ ++j, 1 Say '������������������������������������������������������������������������������'
      For i := 1 To 5
        ++j
        fl := .f.
        For k := 1 To 16
          s := 'diag_16_' + lstr( i ) + '_' + lstr( k )
          mvar := 'm' + s
          If k == 1
            fl := !Empty( &mvar )
          Else
            m1var := 'm1' + s
            If fl
              If k == 3
                mm_m := mm_dispans
              Elseif eq_any( k, 5, 8, 11, 14 )
                mm_m := mm_usl
              Elseif eq_any( k, 6, 9, 12, 15 )
                mm_m := mm_uch1
              Else
                mm_m := mm_danet
              Endif
              &mvar := inieditspr( A__MENUVERT, mm_m, &m1var )
            Else
              &m1var := 0
              &mvar := Space( 4 )
            Endif
          Endif
          Do Case
          Case k == 1
            @ j, 1 get &mvar Picture pic_diag ;
              reader {| o| mygetreader( o, bg ) } Valid val1_10diag( .t., .f., .f., mn_data, mpol ) ;
              When m1diag_16_1 == 0
          Case k == 2
            @ j, 8 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 3
            @ j, 12 get &mvar ;
              reader {| x| menu_reader( x, mm_dispans, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 4
            @ j, 20 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 5
            @ j, 24 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 6
            @ j, 29 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 7
            @ j, 34 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 8
            @ j, 38 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 9
            @ j, 43 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 10
            @ j, 48 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 11
            @ j, 52 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 12
            @ j, 57 get &mvar ;
              reader {| x| menu_reader( x, mm_uch, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 13
            @ j, 62 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 14
            @ j, 66 get &mvar ;
              reader {| x| menu_reader( x, mm_usl, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 15
            @ j, 71 get &mvar ;
              reader {| x| menu_reader( x, mm_uch1, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Case k == 16
            @ j, 76 get &mvar ;
              reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
              When m1diag_16_1 == 0
          Endcase
        Next
      Next
      @ ++j, 1 To j, 78
      If m1step2 == 2  // ���ࠢ��� � �⪠����� �� 2-�� �⠯�
        @ ++j, 1 Say '�ਧ��� �����७�� �� �������⢥���� ������ࠧ������' Get mDS_ONK ;
          reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
        @ ++j, 1 Say '���ࠢ����� �� �����७�� �� ���' Get mnapr_onk ;
          reader {| x| menu_reader( x, { {| k, r, c| fget_napr_zno( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
          When m1ds_onk == 1
      Endif
      dispans_napr( mk_data, @j, .f. )  // �맮� ���������� ����� ���ࠢ�����

      @ ++j, 1 To j, 78
      @ ++j, 1 Say '������������' Get minvalid1 ;
        reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ j, 30 Say '�᫨ "��":' Get minvalid2 ;
        reader {| x| menu_reader( x, mm_invalid2(), A__MENUVERT, , , .f. ) } ;
        When m1invalid1 == 1
      @ ++j, 2 Say '��⠭������ �����' Get minvalid3 ;
        When m1invalid1 == 1
      @ j, Col() + 1 Say '��� ��᫥����� �ᢨ��⥫��⢮�����' Get minvalid4 ;
        When m1invalid1 == 1
      @ ++j, 2 Say '�����������/������������' Get minvalid5 ;
        reader {| x| menu_reader( x, mm_invalid5(), A__MENUVERT, , , .f. ) } ;
        When m1invalid1 == 1
      @ ++j, 2 Say '���� ����襭�� � ���ﭨ� ���஢��' Get minvalid6 ;
        reader {| x| menu_reader( x, mm_invalid6(), A__MENUVERT, , , .f. ) } ;
        When m1invalid1 == 1
      @ ++j, 2 Say '��� �����祭�� �������㠫쭮� �ணࠬ�� ॠ�����樨' Get minvalid7 ;
        When m1invalid1 == 1
      @ j, Col() Say ' �믮������' Get minvalid8 ;
        reader {| x| menu_reader( x, mm_invalid8(), A__MENUVERT, , , .f. ) } ;
        When m1invalid1 == 1
      @ ++j, 1 Say '�ਢ����' Get mprivivki1 ;
        reader {| x| menu_reader( x, mm_privivki1(), A__MENUVERT, , , .f. ) }
      @ j, 50 Say '�� �ਢ��' Get mprivivki2 ;
        reader {| x| menu_reader( x, mm_privivki2(), A__MENUVERT, , , .f. ) } ;
        When m1privivki1 > 0
      @ ++j, 2 Say '�㦤����� � ���樭�樨' Get mprivivki3 Pict '@S54' ;
        When m1privivki1 > 0
      @ ++j, 1 Say '���������樨 ���஢��� ��ࠧ� �����' Get mrek_form Pict '@S52'
      @ ++j, 1 Say '���������樨 �� ��ᯠ��୮�� �������' Get mrek_disp Pict '@S47'
      @ ++j, 1 Say '������ ���ﭨ� �������� �� १���⠬ �஢������ ���ᬮ��' Get mGRUPPA Pict '9'
      @ ++j, 1 Say '                    ����樭᪠� ������ ��� ������ 䨧�����ன' Get mGR_FIZ ;
        reader {| x| menu_reader( x, mm_gr_fiz, A__MENUVERT, , , .f. ) }
      status_key( '^<Esc>^ ��室 ��� �����;  ^<PgUp>^ �������� �� 4-� ��࠭���;  ^<PgDn>^ ������' )
    Endif
    DispEnd()
    count_edit += myread()
    If num_screen == 5
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
      If mvozrast >= 18
        func_error( 4, '���ᬮ�� ������ ���᫮�� ��樥���!' )
        Loop
      Endif
      If !Between( mperiod, 1, 31 )
        func_error( 4, '�� 㤠���� ��।����� �����⭮� ��ਮ�!' )
        num_screen := 1
        Loop
      Endif
      If Empty( mk_data )
        func_error( 4, '�� ������� ��� ����砭�� ��祭��.' )
        Loop
      Elseif Year( mk_data ) < 2018
        func_error( 4, '���ᬮ��� �� ������ �ਪ��� �����ࠢ� �� �������� � 2018 ����' )
        Loop
      Endif
      If Empty( CharRepl( '0', much_doc, Space( 10 ) ) )
        func_error( 4, '�� �������� ����� ���㫠�୮� �����' )
        Loop
      Endif
      If Empty( mmo_pr )
        func_error( 4, '�� ������� ��, � ���஬� �ਪ९�� ��ᮢ��襭����⭨�.' )
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
      If mdvozrast < 5 .and. Empty( mPER_HEAD )
        func_error( 4, '�� ������� ���㦭���� ������.' )
        Loop
      Endif
      If m1FIZ_RAZV == 1 .and. emptyall( m1fiz_razv1, m1fiz_razv2 )
        func_error( 4, '�� ������� �⪫������ ����� ⥫� ��� ���.' )
        Loop
      Endif
      If ! checktabnumberdoctor( mk_data, .f. )
        Loop
      Endif
      If mvozrast < 1
        mdef_diagnoz := 'Z00.1 '
      Elseif mvozrast < 14
        mdef_diagnoz := 'Z00.2 '
      Else
        mdef_diagnoz := 'Z00.3 '
      Endif
//      arr_iss := Array( count_pn_arr_iss, 10 )
      arr_iss := Array( count_pn_arr_iss( mk_data ), 10 )
      afillall( arr_iss, 0 )
      r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'MKB_10' )
      r_use( dir_DB + 'mo_pers', dir_DB + 'mo_pers', 'P2' )
      num_screen := 2
      max_date1 := max_date2 := mn_data
      d12 := mn_data -1
      k := 0
      If metap == 2
        Do While++d12 <= mk_data
          If is_work_day( d12 )
            If++k == 20
              Exit
            Endif
          Endif
        Enddo
      Endif
      fl := .t.
      is_otkaz := .f.
      is_neonat := .f.
      ar := np_arr_1_etap( mk_data )[ mperiod ]
//      For i := 1 To count_pn_arr_iss
      For i := 1 To count_pn_arr_iss( mk_data )
        mvart := 'MTAB_NOMiv' + lstr( i )
        mvara := 'MTAB_NOMia' + lstr( i )
        mvard := 'MDATEi' + lstr( i )
        mvarr := 'MREZi' + lstr( i )
        _fl_ := not_audio_s := .t.
//        If _fl_ .and. !Empty( np_arr_issled[ i, 2 ] )
//          _fl_ := ( mpol == np_arr_issled[ i, 2 ] )
        If _fl_ .and. !Empty( arr_PN_issled[ i, 2 ] )
          _fl_ := ( mpol == arr_PN_issled[ i, 2 ] )
        Endif
        If _fl_
//          _fl_ := ( AScan( ar[ 5 ], np_arr_issled[ i, 1 ] ) > 0 )
          _fl_ := ( AScan( ar[ 5 ], arr_PN_issled[ i, 1 ] ) > 0 )
        Endif
//        If np_arr_issled[ i, 1 ] == '3.5.4' .and. is_3_5_4 // �㤨�-�ਭ��� 㦥 ��
        If arr_PN_issled[ i, 1 ] == '3.5.4' .and. is_3_5_4 // �㤨�-�ਭ��� 㦥 ��
          not_audio_s := .f.
        Endif
        If _fl_ .and. not_audio_s /*.and. arr_PN_issled[i, 4] == 0 // �� ��ମ�*/
          m1var := 'm1lis' + lstr( i )
          If !is_disp_19 .and. glob_yes_kdp2()[ TIP_LU_PN ] .and. &m1var > 0
            &mvart := -1
          Endif
          If Empty( &mvard )
//            fl := func_error( 4, '�� ������� ��� ���-�� "' + np_arr_issled[ i, 3 ] + '"' )
            fl := func_error( 4, '�� ������� ��� ���-�� "' + arr_PN_issled[ i, 3 ] + '"' )
          Elseif metap == 2 .and. &mvard > d12
//            fl := func_error( 4, '��� ���-�� "' + np_arr_issled[ i, 3 ] + '" �� � I-�� �⠯� (> 20 ����)' )
            fl := func_error( 4, '��� ���-�� "' + arr_PN_issled[ i, 3 ] + '" �� � I-�� �⠯� (> 20 ����)' )
          Elseif Empty( &mvart )
//            fl := func_error( 4, '�� ������ ��� � ���-�� "' + np_arr_issled[ i, 3 ] + '"' )
            fl := func_error( 4, '�� ������ ��� � ���-�� "' + arr_PN_issled[ i, 3 ] + '"' )
          Endif
        Endif
        If _fl_ .and. !emptyany( &mvard, &mvart )
          if &mvart > 0
            Select P2
            find ( Str( &mvart, 5 ) )
            If Found()
              arr_iss[ i, 1 ] := p2->kod
              arr_iss[ i, 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
            Endif
            If !Empty( &mvara )
              Select P2
              find ( Str( &mvara, 5 ) )
              If Found()
                arr_iss[ i, 3 ] := p2->kod
              Endif
            Endif
          Else
//            arr_iss[ i, 2 ] := -ret_new_spec( np_arr_issled[ i, 6, 1 ] )
            arr_iss[ i, 2 ] := -ret_new_spec( arr_PN_issled[ i, 6, 1 ] )
            arr_iss[ i, 10 ] := &m1var // �஢� �஢����� � ���2 ��� � ���
          Endif
/*          If ValType( np_arr_issled[ i, 5 ] ) == 'N'
            arr_iss[ i, 4 ] := np_arr_issled[ i, 5 ] // ��䨫�
          Elseif ( j := AScan( np_arr_issled[ i, 6 ], ret_old_prvs( arr_iss[ i, 2 ] ) ) ) > 0
            arr_iss[ i, 4 ] := np_arr_issled[ i, 5, j ] // ��䨫�
          Endif
          arr_iss[ i, 5 ] := np_arr_issled[ i, 1 ] // ��� ��㣨
*/
          If ValType( arr_PN_issled[ i, 5 ] ) == 'N'
            arr_iss[ i, 4 ] := arr_PN_issled[ i, 5 ] // ��䨫�
          Elseif ( j := AScan( arr_PN_issled[ i, 6 ], ret_old_prvs( arr_iss[ i, 2 ] ) ) ) > 0
            arr_iss[ i, 4 ] := arr_PN_issled[ i, 5, j ] // ��䨫�
          Endif
          arr_iss[ i, 5 ] := arr_PN_issled[ i, 1 ] // ��� ��㣨
          arr_iss[ i, 6 ] := mdef_diagnoz
          arr_iss[ i, 9 ] := &mvard
          //
          m1var := 'M1OTKAZi' + lstr( i )
          if &m1var == 1 .and. !Between( arr_iss[ i, 9 ], mn_data, mk_data ) // �᫨ �⪠� � �� � ���������
            &m1var := 0
          Endif
          if &m1var == 1
            arr_iss[ i, 10 ] := 9 // �⪠� �� ��㣨
            is_otkaz := .t.
          Elseif Left( arr_iss[ i, 5 ], 5 ) == '4.26.'
            is_neonat := .t.
          Endif
          max_date1 := Max( max_date1, arr_iss[ i, 9 ] )
        Endif
        If !fl
          Exit
        Endif
      Next
      If !fl
        Loop
      Endif
      fl := .t.
//      arr_osm1 := Array( count_pn_arr_osm, 10 )
      arr_osm1 := Array( Len( arr_PN_osmotr ), 10 )
      afillall( arr_osm1, 0 )
      For i := 1 To Len( arr_PN_osmotr )  // count_pn_arr_osm
        _fl_ := .t.
//        If _fl_ .and. !Empty( np_arr_osmotr[ i, 2 ] )
//          _fl_ := ( mpol == np_arr_osmotr[ i, 2 ] )
        If _fl_ .and. !Empty( arr_PN_osmotr[ i, 2 ] )
          _fl_ := ( mpol == arr_PN_osmotr[ i, 2 ] )
        Endif
/*
        If _fl_
          _fl_ := ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) > 0 )
        Endif
        If _fl_ .and. mperiod == 16 .and. mk_data < 0d20191101 .and. np_arr_osmotr[ i, 1 ] == '2.4.2' // 2 ����
          _fl_ := .f.
        Endif
        If _fl_ .and. mperiod == 20 .and. mk_data < 0d20191101 .and. np_arr_osmotr[ i, 1 ] == '2.85.24' // 6 ���
          _fl_ := .f.
        Endif
*/
        If _fl_
          _fl_ := ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], arr_PN_osmotr[ i, 1 ] ) > 0 )
        Endif
        If _fl_ .and. mperiod == 16 .and. mk_data < 0d20191101 .and. arr_PN_osmotr[ i, 1 ] == '2.4.2' // 2 ����
          _fl_ := .f.
        Endif
        If _fl_ .and. mperiod == 20 .and. mk_data < 0d20191101 .and. arr_PN_osmotr[ i, 1 ] == '2.85.24' // 6 ���
          _fl_ := .f.
        Endif

        If _fl_
          mvart := 'MTAB_NOMov' + lstr( i )
          mvara := 'MTAB_NOMoa' + lstr( i )
          mvard := 'MDATEo' + lstr( i )
          mvarz := 'MKOD_DIAGo' + lstr( i )
          If Empty( &mvard )
//            fl := func_error( 4, '�� ������� ��� �ᬮ�� I �⠯� "' + np_arr_osmotr[ i, 3 ] + '"' )
            fl := func_error( 4, '�� ������� ��� �ᬮ�� I �⠯� "' + arr_PN_osmotr[ i, 3 ] + '"' )
          Elseif metap == 2 .and. &mvard > d12
//            fl := func_error( 4, '��� �ᬮ�� "' + np_arr_osmotr[ i, 3 ] + '" �� � I-�� �⠯� (> 20 ����)' )
            fl := func_error( 4, '��� �ᬮ�� "' + arr_PN_osmotr[ i, 3 ] + '" �� � I-�� �⠯� (> 20 ����)' )
          Elseif Empty( &mvart )
//            fl := func_error( 4, '�� ������ ��� � �ᬮ�� I �⠯� "' + np_arr_osmotr[ i, 3 ] + '"' )
            fl := func_error( 4, '�� ������ ��� � �ᬮ�� I �⠯� "' + arr_PN_osmotr[ i, 3 ] + '"' )
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
/*
            If ValType( np_arr_osmotr[ i, 4 ] ) == 'N'
              arr_osm1[ i, 4 ] := np_arr_osmotr[ i, 4 ] // ��䨫�
            Elseif ( j := AScan( np_arr_osmotr[ i, 5 ], ret_old_prvs( arr_osm1[ i, 2 ] ) ) ) > 0
              arr_osm1[ i, 4 ] := np_arr_osmotr[ i, 4, j ] // ��䨫�
            Endif
            arr_osm1[ i, 5 ] := np_arr_osmotr[ i, 1 ] // ��� ��㣨
*/
            If ValType( arr_PN_osmotr[ i, 4 ] ) == 'N'
              arr_osm1[ i, 4 ] := arr_PN_osmotr[ i, 4 ] // ��䨫�
            Elseif ( j := AScan( arr_PN_osmotr[ i, 5 ], ret_old_prvs( arr_osm1[ i, 2 ] ) ) ) > 0
              arr_osm1[ i, 4 ] := arr_PN_osmotr[ i, 4, j ] // ��䨫�
            Endif
            arr_osm1[ i, 5 ] := arr_PN_osmotr[ i, 1 ] // ��� ��㣨

            If Empty( &mvarz ) .or. Left( &mvarz, 1 ) == 'Z'
              arr_osm1[ i, 6 ] := mdef_diagnoz
            Else
              arr_osm1[ i, 6 ] := &mvarz
              Select MKB_10
              find ( PadR( arr_osm1[ i, 6 ], 6 ) )
              If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
                fl := func_error( 4, '��ᮢ���⨬���� �������� �� ���� ' + arr_osm1[ i, 6 ] )
              Endif
            Endif
            arr_osm1[ i, 9 ] := &mvard
            m1var := 'M1OTKAZo' + lstr( i )
            if &m1var == 1 .and. !Between( arr_osm1[ i, 9 ], mn_data, mk_data ) // �᫨ �⪠� � �� � ���������
              &m1var := 0
            Endif
            if &m1var == 1
              arr_osm1[ i, 10 ] := 9 // �⪠� �� �ᬮ��
              is_otkaz := .t.
            Endif
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
      If emptyany( MTAB_NOMpv1, MDATEp1 )
        fl := func_error( 4, '�� ����� ������� (��� ��饩 �ࠪ⨪�) � �ᬮ��� I �⠯�' )
      Elseif MDATEp1 < max_date1
        fl := func_error( 4, '������� (��� ��饩 �ࠪ⨪�) �� I �⠯� ������ �஢����� �ᬮ�� ��᫥����!' )
      Elseif metap == 2 .and. MDATEp1 > d12
        fl := func_error( 4, '��� �ᬮ�� ������� I �⠯� �� 㬥頥��� � 20 ࠡ��� ����' )
      Endif
      If !fl
        Loop
      Endif
      m1p_otk := 0
      metap := 1
//      arr_osm2 := Array( count_pn_arr_osm, 10 )
      arr_osm2 := Array( Len( arr_PN_osmotr ), 10 )
      afillall( arr_osm2, 0 )
      If m1step2 == 2 // ���ࠢ��� �� 2-�� �⠯, �� �⪠�����
        m1p_otk := 1   // �ਧ��� �⪠��
      Elseif m1step2 == 1 // ���ࠢ��� �� 2-�� �⠯
        num_screen := 3
        fl := .t.
        If !emptyany( MTAB_NOMpv2, MDATEp2 )
          metap := 2
        Endif
        ku := 0
        For i := 1 To Len( arr_PN_osmotr )  // count_pn_arr_osm
          _fl_ := .t.
//          If _fl_ .and. !Empty( np_arr_osmotr[ i, 2 ] )
//            _fl_ := ( mpol == np_arr_osmotr[ i, 2 ] )
          If _fl_ .and. !Empty( arr_PN_osmotr[ i, 2 ] )
            _fl_ := ( mpol == arr_PN_osmotr[ i, 2 ] )
          Endif
          If _fl_
//            _fl_ := ( AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) == 0 )
            _fl_ := ( AScan( ar[ 4 ], arr_PN_osmotr[ i, 1 ] ) == 0 )
          Endif
          If _fl_
            mvonk := 'm1onko' + lstr( i )
            mvart := 'MTAB_NOMov' + lstr( i )
            mvara := 'MTAB_NOMoa' + lstr( i )
            mvard := 'MDATEo' + lstr( i )
            mvarz := 'MKOD_DIAGo' + lstr( i )
            If eq_any( i, 8, 10 ) .and. &mvonk == 3
              &mvart := -1
            Endif
            If !Empty( &mvard ) .and. Empty( &mvart )
//              fl := func_error( 4, '�� ������ ��� � �ᬮ�� II �⠯� "' + np_arr_osmotr[ i, 3 ] + '"' )
              fl := func_error( 4, '�� ������ ��� � �ᬮ�� II �⠯� "' + arr_PN_osmotr[ i, 3 ] + '"' )
            Elseif !Empty( &mvart ) .and. Empty( &mvard )
//              fl := func_error( 4, '�� ������� ��� �ᬮ�� II �⠯� "' + np_arr_osmotr[ i, 3 ] + '"' )
              fl := func_error( 4, '�� ������� ��� �ᬮ�� II �⠯� "' + arr_PN_osmotr[ i, 3 ] + '"' )
            Elseif !emptyany( &mvard, &mvart )
              ++ku
              metap := 2
              if &mvard < MDATEp1
//                fl := func_error( 4, '��� �ᬮ�� II �⠯� "' + np_arr_osmotr[ i, 3 ] + '" ����� I �⠯�' )
                fl := func_error( 4, '��� �ᬮ�� II �⠯� "' + arr_PN_osmotr[ i, 3 ] + '" ����� I �⠯�' )
              Endif
              if &mvart > 0
                Select P2
                find ( Str( &mvart, 5 ) )
                If Found()
                  arr_osm2[ i, 1 ] := p2->kod
                  arr_osm2[ i, 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
                Endif
                If !Empty( &mvara )
                  Select P2
                  find ( Str( &mvara, 5 ) )
                  If Found()
                    arr_osm2[ i, 3 ] := p2->kod
                  Endif
                Endif
              Else // ��� � ������ᯠ���
//                arr_osm2[ i, 2 ] := -ret_new_spec( np_arr_osmotr[ i, 5, 1 ] )
                arr_osm2[ i, 2 ] := -ret_new_spec( arr_PN_osmotr[ i, 5, 1 ] )
                arr_osm2[ i, 10 ] := 3
              Endif
/*
              If ValType( np_arr_osmotr[ i, 4 ] ) == 'N'
                arr_osm2[ i, 4 ] := np_arr_osmotr[ i, 4 ] // ��䨫�
              Elseif ( j := AScan( np_arr_osmotr[ i, 5 ], ret_old_prvs( arr_osm2[ i, 2 ] ) ) ) > 0
                arr_osm2[ i, 4 ] := np_arr_osmotr[ i, 4, j ] // ��䨫�
              Endif
              arr_osm2[ i, 5 ] := np_arr_osmotr[ i, 1 ] // ��� ��㣨
*/
              If ValType( arr_PN_osmotr[ i, 4 ] ) == 'N'
                arr_osm2[ i, 4 ] := arr_PN_osmotr[ i, 4 ] // ��䨫�
              Elseif ( j := AScan( arr_PN_osmotr[ i, 5 ], ret_old_prvs( arr_osm2[ i, 2 ] ) ) ) > 0
                arr_osm2[ i, 4 ] := arr_PN_osmotr[ i, 4, j ] // ��䨫�
              Endif
              arr_osm2[ i, 5 ] := arr_PN_osmotr[ i, 1 ] // ��� ��㣨

              If Empty( &mvarz ) .or. Left( &mvarz, 1 ) == 'Z'
                arr_osm2[ i, 6 ] := mdef_diagnoz
              Else
                arr_osm2[ i, 6 ] := &mvarz
                Select MKB_10
                find ( PadR( arr_osm2[ i, 6 ], 6 ) )
                If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
                  fl := func_error( 4, '��ᮢ���⨬���� �������� �� ���� ' + arr_osm2[ i, 6 ] )
                Endif
              Endif
              m1var := 'M1OTKAZo' + lstr( i )
              if &m1var == 1
                arr_osm2[ i, 10 ] := 9 // �⪠� �� �ᬮ��
              Endif
              arr_osm2[ i, 9 ] := &mvard
              max_date2 := Max( max_date2, arr_osm2[ i, 9 ] )
            Endif
          Endif
          If !fl
            Exit
          Endif
        Next
        If fl .and. metap == 2
          If emptyany( MTAB_NOMpv2, MDATEp2 )
            fl := func_error( 4, '�� ����� ������� (��� ��饩 �ࠪ⨪�) � �ᬮ��� II �⠯�' )
          Elseif MDATEp1 == MDATEp2
            fl := func_error( 4, '�������� �� I � II �⠯�� �஢��� �ᬮ��� � ���� ����!' )
          Elseif MDATEp2 < max_date2
            fl := func_error( 4, '������� (��� ��饩 �ࠪ⨪�) �� II �⠯� ������ �஢����� �ᬮ�� ��᫥����!' )
          Elseif Empty( ku )
            fl := func_error( 4, '�� II �⠯� �஬� �ᬮ�� ������� ������ ���� ��� �����-����� �ᬮ��.' )
          Endif
        Endif
        If !fl
          Loop
        Endif
      Endif
      num_screen := 4
      If !Between( mGRUPPA_DO, 1, 5 )
        func_error( 4, '������ ���ﭨ� �������� �� �஢������ ���ᬮ�� �.�. �� 1 �� 5' )
        Loop
      Endif
      num_screen := 5
      arr_diag := {}
      For i := 1 To 5
        mvar := 'mdiag_16_' + lstr( i ) + '_1'
        If !Empty( &mvar )
          If Left( &mvar, 1 ) == 'Z'
            fl := func_error( 4, '������� ' + RTrim( &mvar ) + '(���� ᨬ��� "Z") �� ��������. �� �� �����������!' )
            Exit
          Endif
          pole_1pervich := 'm1diag_16_' + lstr( i ) + '_2' // 0, 1
          pole_1dispans := 'm1diag_16_' + lstr( i ) + '_3' // mm_dispans := {{'࠭��', 1}, {'�����', 2}, {'�� ���.', 0}}
          AAdd( arr_diag, { &mvar, &pole_1pervich, &pole_1dispans } )
        Endif
      Next
      If !fl
        Loop
      Endif
      AFill( adiag_talon, 0 )
      If Empty( arr_diag ) // �������� �� �������
        AAdd( arr_diag, { 1, mdef_diagnoz, 0, 0 } ) // ������� �� 㬮�砭��
        MKOD_DIAG := mdef_diagnoz
      Else
        For i := 1 To Len( arr_diag )
          If arr_diag[ i, 2 ] == 0 // '࠭�� �����'
            arr_diag[ i, 2 ] := 2  // �����塞, ��� � ���� ���� ���
          Endif
        Next
        For i := 1 To Len( arr_diag )
          adiag_talon[ i * 2 -1 ] := arr_diag[ i, 2 ]
          adiag_talon[ i * 2 ] := arr_diag[ i, 3 ]
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
      If m1invalid1 == 1 .and. !Empty( minvalid3 ) .and. minvalid3 < mdate_r
        func_error( 4, '��� ��⠭������� ����������� ����� ���� ஦�����' )
        Loop
      Endif
      If Between( mGRUPPA, 1, 5 )
        m1rslt := L_BEGIN_RSLT + mGRUPPA
      Else
        func_error( 4, '������ ���ﭨ� �������� �� १���⠬ �஢������ ���ᬮ�� - �� 1 �� 5' )
        Loop
      Endif
      //
      err_date_diap( mn_data, '��� ��砫� ��祭��' )
      err_date_diap( mk_data, '��� ����砭�� ��祭��' )
      //
      RestScreen( buf )
      message_save_LU()
      mywait( '����. �ந�������� ������ ���� ����...' )
      m1lis := 0
      arr_lis2 := {}
      arr_usl_dop := {}
      arr_usl_otkaz := {}
      If !is_disp_19 .and. glob_yes_kdp2()[ TIP_LU_PN ]
//        For i := 1 To count_pn_arr_iss
        For i := 1 To count_pn_arr_iss( mk_data )
          If ValType( arr_iss[ i, 9 ] ) == 'D' .and. arr_iss[ i, 9 ] >= mn_data .and. Len( arr_iss[ i ] ) > 9 ;
              .and. ValType( arr_iss[ i, 10 ] ) == 'N' .and. eq_any( arr_iss[ i, 10 ], 1, 2 )
            m1lis := arr_iss[ i, 10 ] // � ࠬ��� ��ᯠ��ਧ�樨
          Endif
        Next
      Endif
      // ������� ������� I �⠯�
      AAdd( arr_osm1, add_pediatr_pn( MTAB_NOMpv1, MTAB_NOMpa1, MDATEp1, MKOD_DIAGp1 ) )
      If metap == 1 // I �⠯
        For i := 1 To Len( arr_iss )
          If ValType( arr_iss[ i, 5 ] ) == 'C'
            If arr_iss[ i, 10 ] == 9 // �⪠�
              arr_iss[ i, 10 ] := 'i'
              AAdd( arr_usl_otkaz, arr_iss[ i ] )
            Else
              AAdd( arr_usl_dop, arr_iss[ i ] )
              If is_otkaz .and. ; // � ��砥 �뫨 �⪠��
                arr_iss[ i, 10 ] == 0 .and. ; // ��㣠 �� � ���2
                Between( arr_iss[ i, 9 ], mn_data, mk_data ) .and. ; // 㬥頥��� � ��ਮ�
                ( j := AScan( arr_not_zs, {| x| x[ 1 ] == arr_iss[ i, 5 ] } ) ) > 0
//                ( j := AScan( np_arr_not_zs, {| x| x[ 1 ] == arr_iss[ i, 5 ] } ) ) > 0
                arr := AClone( arr_iss[ i ] )  // �������
//                arr[ 5 ] := np_arr_not_zs[ j, 2 ] // ��� ��᫥�������
                arr[ 5 ] := arr_not_zs[ j, 2 ] // ��� ��᫥�������
                AAdd( arr_usl_dop, arr )          // � 業��
              Endif
            Endif
          Endif
        Next
        For i := 1 To Len( arr_osm1 )
          If ValType( arr_osm1[ i, 5 ] ) == 'C'
            If arr_osm1[ i, 10 ] == 9 // �⪠�
              arr_osm1[ i, 10 ] := 'o'
              AAdd( arr_usl_otkaz, arr_osm1[ i ] )
            Else
              lshifr := AllTrim( arr_osm1[ i, 5 ] )
//              If ( j := AScan( np_arr_osmotr_KDP2, {| x| x[ 1 ] == lshifr } ) ) > 0
//                arr_osm1[ i, 5 ] := np_arr_osmotr_KDP2[ j, 3 ]  // ������ �� 2.3.*
              If ( j := AScan( arr_osmotr_KDP2, {| x| x[ 1 ] == lshifr } ) ) > 0
                arr_osm1[ i, 5 ] := arr_osmotr_KDP2[ j, 3 ]  // ������ �� 2.3.*
              Endif
              AAdd( arr_usl_dop, arr_osm1[ i ] )
              If is_otkaz .and. ;// � ��砥 �뫨 �⪠��
                Between( arr_osm1[ i, 9 ], mn_data, mk_data ) ; // � 㬥頥��� � ��ਮ�
                .and. j > 0  // � ������� ᮮ⢥��⢨�
                arr := AClone( arr_osm1[ i ] )       // �������
//                arr[ 5 ] := np_arr_osmotr_KDP2[ j, 4 ]  // ������ �� 2.91.*
                arr[ 5 ] := arr_osmotr_KDP2[ j, 4 ]  // ������ �� 2.91.*
                AAdd( arr_usl_dop, arr )             // � 業��
              Endif
            Endif
          Endif
        Next
        i := Len( arr_osm1 )
        m1vrach  := arr_osm1[ i, 1 ]
        m1prvs   := arr_osm1[ i, 2 ]
        m1assis  := arr_osm1[ i, 3 ]
        m1PROFIL := arr_osm1[ i, 4 ]
        // MKOD_DIAG := padr(arr_osm1[i, 6], 6)
        If !is_otkaz // ������塞 ��� ��
          AAdd( arr_usl_dop, Array( 10 ) )
          j := Len( arr_usl_dop )
          arr_usl_dop[ j, 1 ] := m1vrach
          arr_usl_dop[ j, 2 ] := m1prvs
          arr_usl_dop[ j, 3 ] := m1assis
          arr_usl_dop[ j, 4 ] := 151 // ��� ���� �� - ���.�ᬮ�ࠬ ��䨫����᪨�
          arr_usl_dop[ j, 5 ] := ret_shifr_zs_pn( mperiod, mk_data )
          arr_usl_dop[ j, 6 ] := MKOD_DIAG
          arr_usl_dop[ j, 9 ] := mn_data
        Endif
      Else  // ��ଫ���� 2-�� �⠯� ��-������
        Use ( cur_dir() + 'tmp' ) new
        Go Top
        Do While !Eof()
          If is_lab_usluga( tmp->u_shifr )
            AAdd( arr_lis2, { tmp->u_kod, tmp->u_shifr } )
          Endif
          Skip
        Enddo
        Use
        For i := 1 To Len( arr_iss )
          If ValType( arr_iss[ i, 5 ] ) == 'C'
            If arr_iss[ i, 10 ] == 9 // �⪠�
              arr_iss[ i, 10 ] := 'i'
              AAdd( arr_usl_otkaz, arr_iss[ i ] )
            Else
              AAdd( arr_usl_dop, arr_iss[ i ] )
              If arr_iss[ i, 10 ] == 0 ; // �஢� �஢����� � ��� � ��
                .and. Between( arr_iss[ i, 9 ], mn_data, mk_data ) .and. ; // � � �ப� ���ᬮ��
                ( j := AScan( arr_not_zs, {| x| x[ 1 ] == arr_iss[ i, 5 ] } ) ) > 0
//                ( j := AScan( np_arr_not_zs, {| x| x[ 1 ] == arr_iss[ i, 5 ] } ) ) > 0
                arr := AClone( arr_iss[ i ] )  // �������
//                arr[ 5 ] := np_arr_not_zs[ j, 2 ] // ��� ��᫥�������
                arr[ 5 ] := arr_not_zs[ j, 2 ] // ��� ��᫥�������
                AAdd( arr_usl_dop, arr )          // � 業��
              Endif
            Endif
          Endif
        Next
        For i := 1 To Len( arr_osm1 )
          If ValType( arr_osm1[ i, 5 ] ) == 'C'
            lshifr := AllTrim( arr_osm1[ i, 5 ] )
            If arr_osm1[ i, 10 ] == 9 // �⪠� �� �ᬮ��
              arr_osm1[ i, 10 ] := 'o'
              AAdd( arr_usl_otkaz, arr_osm1[ i ] )
            Else
              lshifr := AllTrim( arr_osm1[ i, 5 ] )
//              If ( j := AScan( np_arr_osmotr_KDP2, {| x| x[ 1 ] == lshifr } ) ) > 0
//                arr_osm1[ i, 5 ] := np_arr_osmotr_KDP2[ j, 3 ]  // ������ �� 2.3.*
//              Endif
              If ( j := AScan( arr_osmotr_KDP2, {| x| x[ 1 ] == lshifr } ) ) > 0
                arr_osm1[ i, 5 ] := arr_osmotr_KDP2[ j, 3 ]  // ������ �� 2.3.*
              Endif
              AAdd( arr_usl_dop, arr_osm1[ i ] )
              If Between( arr_osm1[ i, 9 ], mn_data, mk_data ) ; // � 㬥頥��� � ��ਮ�
                .and. j > 0  // � ������� ᮮ⢥��⢨�
                arr := AClone( arr_osm1[ i ] )       // �������
//                arr[ 5 ] := np_arr_osmotr_KDP2[ j, 4 ]  // ������ �� 2.91.*
                arr[ 5 ] := arr_osmotr_KDP2[ j, 4 ]  // ������ �� 2.91.*
                AAdd( arr_usl_dop, arr )             // � 業��
              Endif
            Endif
          Endif
        Next
        // ������� ������� II �⠯�
        AAdd( arr_osm2, add_pediatr_pn( MTAB_NOMpv2, MTAB_NOMpa2, MDATEp2, MKOD_DIAGp2 ) )
        i := Len( arr_osm2 )
        m1vrach  := arr_osm2[ i, 1 ]
        m1prvs   := arr_osm2[ i, 2 ]
        m1assis  := arr_osm2[ i, 3 ]
        m1PROFIL := arr_osm2[ i, 4 ]
        // MKOD_DIAG := padr(arr_osm2[i, 6], 6)
        For i := 1 To Len( arr_osm2 )
          If ValType( arr_osm2[ i, 5 ] ) == 'C'
            lshifr := AllTrim( arr_osm2[ i, 5 ] )
            If arr_osm2[ i, 10 ] == 9 // �⪠� �� �ᬮ��
              arr_osm2[ i, 10 ] := 'o'
              AAdd( arr_usl_otkaz, arr_osm2[ i ] )
            Else
              If arr_osm2[ i, 10 ] == 3 // �᫨ ��㣠 ������� � �����
                arr_osm2[ i, 5 ] := '2.3.1'
              Endif
//              If !Empty( arr_lis2 ) .and. ( j := AScan( np_arr_osmotr_KDP2, {| x| x[ 1 ] == lshifr } ) ) > 0
//                arr_osm2[ i, 5 ] := np_arr_osmotr_KDP2[ j, 2 ] // ��㣨 ������� �� ��������� ���� ��� ����⮫����
//              Endif
              If !Empty( arr_lis2 ) .and. ( j := AScan( arr_osmotr_KDP2, {| x| x[ 1 ] == lshifr } ) ) > 0
                arr_osm2[ i, 5 ] := arr_osmotr_KDP2[ j, 2 ] // ��㣨 ������� �� ��������� ���� ��� ����⮫����
              Endif
              AAdd( arr_usl_dop, arr_osm2[ i ] )
            Endif
          Endif
        Next
        If !Empty( arr_lis2 ) // �� 2-�� �⠯� �뫨 ���ࠢ����� �� ������� � ���2
          If ( mdate := max_date1 + 1 ) > max_date2 // ᫥���騩 ���� ��᫥ ������� 1-�� �⠯�
            mdate := max_date2 // �᫨ �⮣� �����, � ����砭�� 2-�� �⠯�
          Endif
          For j := 1 To Len( arr_lis2 )
            AAdd( arr_usl_dop, Array( 10 ) )
            i := Len( arr_usl_dop )
            AFill( arr_usl_dop[ i ], 0 )
            arr_usl_dop[ i, 4 ] := iif( Left( arr_lis2[ j, 2 ], 5 ) == '4.16.', 6, 34 ) // ��䨫�
            arr_usl_dop[ i, 5 ] := arr_lis2[ j, 2 ] // ��� ��㣨
            arr_usl_dop[ i, 6 ] := mkod_diag
            arr_usl_dop[ i, 7 ] := arr_lis2[ j, 1 ] // ��� ��㣨
            arr_usl_dop[ i, 9 ] := mdate
            arr_usl_dop[ i, 10 ] := -1 // �.�. ���ਠ� ��ࠢ��� �� ������ � ���2
          Next
        Endif
      Endif
      make_diagp( 2 )  // ᤥ���� '��⨧����' ��������
      //
      use_base( 'lusl' )
      use_base( 'luslc' )
      use_base( 'uslugi' )
      r_use( dir_DB + 'uslugi1', { dir_DB + 'uslugi1', ;
        dir_DB + 'uslugi1s' }, 'USL1' )
      Private mu_cena
      mcena_1 := 0
      glob_podr := ''
      glob_otd_dep := 0
      For i := 1 To Len( arr_usl_dop )
        If Empty( arr_usl_dop[ i, 7 ] ) // �.�. ��� ���, ���ࠢ�塞�� � ���2, ��� 㦥 �����⥭ (� 業� =0)
          arr_usl_dop[ i, 7 ] := foundourusluga( arr_usl_dop[ i, 5 ], mk_data, arr_usl_dop[ i, 4 ], M1VZROS_REB, @mu_cena )
          arr_usl_dop[ i, 8 ] := mu_cena
          mcena_1 += mu_cena
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
      st_K_DATA := MK_DATA
      st_mo_pr := m1mo_pr
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
      human->ZA_SMO     := 0
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
      human->ishod      := 300 + metap
      human->OBRASHEN   := iif( m1DS_ONK == 1, '1', ' ' )
      human->bolnich    := 0
      human->date_b_1   := ''
      human->date_b_2   := ''
      human_->RODIT_DR  := CToD( '' )
      human_->RODIT_POL := ''
      s := '' ; AEval( adiag_talon, {| x| s += Str( x, 1 ) } )
      human_->DISPANS   := s
      human_->STATUS_ST := ''
      human_->POVOD     := m1povod
      human_->POVOD     := 5 // {'2.1-����樭᪨� �ᬮ��', 5,'2.1'}, ;
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
      human_->IDSP      := iif( metap == 1, 17, 1 )
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
        g_use( dir_DB + 'mo_hismo', , 'SN' )
        Index On Str( FIELD->kod, 7 ) to ( cur_dir() + 'tmp_ismo' )
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
        hu->is_edit := iif( Len( arr_usl_dop[ i ] ) > 9 .and. ValType( arr_usl_dop[ i, 10 ] ) == 'N', arr_usl_dop[ i, 10 ], 0 )
        hu->date_u  := dtoc4( arr_usl_dop[ i, 9 ] )
        hu->otd     := m1otd
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := arr_usl_dop[ i, 8 ]
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
      save_arr_pn( mkod )
      If m1step2 == 2 ; // ���ࠢ��� � �⪠����� �� 2-�� �⠯�
        .and. m1ds_onk == 1 // �����७�� �� �������⢥���� ������ࠧ������
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
    If Type( 'fl_edit_DDS' ) == 'L'
      fl_edit_DDS := .t.
    Endif
    If !Empty( Val( msmo ) )
      verify_oms_sluch( glob_perso )
    Endif
  Endif
  Return Nil
