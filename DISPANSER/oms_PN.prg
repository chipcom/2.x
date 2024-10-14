#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 01.06.24 �� - ���������� ��� ।���஢���� ���� (���� ���)
Function oms_sluch_PN(Loc_kod, kod_kartotek, f_print)
  // Loc_kod - ��� �� �� human.dbf (�᫨ = 0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  // f_print - ������������ �㭪樨 ��� ����
  Static st_N_DATA, st_K_DATA, st_mo_pr := '      '
  Local L_BEGIN_RSLT := 331
  Local bg := {|o, k| get_MKB10(o, k, .t.) }, arr_del := {}, mrec_hu := 0, ;
        buf := savescreen(), tmp_color := setcolor(), a_smert := {}, ;
        p_uch_doc := '@!', pic_diag := '@K@!', arr_usl := {}, ;
        i, j, k, n, s, s1, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
        pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod, ;
        tmp_help := chm_help_code, fl_write_sluch := .f., _y, _m, _d, t_arr[2], ;
        arr_prof := {}, is_3_5_4 := .f.
  //
  Default st_N_DATA TO sys_date, st_K_DATA TO sys_date
  Default Loc_kod TO 0, kod_kartotek TO 0, f_print TO ''
  //
  if kod_kartotek == 0 // ���������� � ����⥪�
    if (kod_kartotek := edit_kartotek(0, , , .t.)) == 0
      return NIL
    endif
  endif
  chm_help_code := 3002
  Private mfio := space(50), mpol, mdate_r, madres, mvozrast, mdvozrast, msvozrast := ' ', ;
          M1VZROS_REB, MVZROS_REB, m1novor := 0, ;
          m1company := 0, mcompany, mm_company, ;
          mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-���, 1-��������, 3-�������/���, 5-���� ���
          msmo := '34007', rec_inogSMO := 0, ;
          mokato, m1okato := '', mismo, m1ismo := '', mnameismo := space(100), ;
          mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20)
  Private mkod := Loc_kod, mtip_h, is_talon := .f., is_disp_19 := .t., ;
          mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0), ;
          M1LPU := glob_uch[1], MLPU, ;
          M1OTD := glob_otd[1], MOTD, ;
          M1FIO_KART := 1, MFIO_KART, ;
          MUCH_DOC    := space(10)         , ; // ��� � ����� ��⭮�� ���㬥��
          mmobilbr, m1mobilbr := 0, ;
          MKOD_DIAG   := space(5)          , ; // ��� 1-�� ��.�������
          MKOD_DIAG2  := space(5)          , ; // ��� 2-�� ��.�������
          MKOD_DIAG3  := space(5)          , ; // ��� 3-�� ��.�������
          MKOD_DIAG4  := space(5)          , ; // ��� 4-�� ��.�������
          MSOPUT_B1   := space(5)          , ; // ��� 1-�� ᮯ������饩 �������
          MSOPUT_B2   := space(5)          , ; // ��� 2-�� ᮯ������饩 �������
          MSOPUT_B3   := space(5)          , ; // ��� 3-�� ᮯ������饩 �������
          MSOPUT_B4   := space(5)          , ; // ��� 4-�� ᮯ������饩 �������
          MDIAG_PLUS  := space(8)          , ; // ���������� � ���������
          adiag_talon[16]                  , ; // �� ���⠫��� � ���������
          m1rslt  := L_BEGIN_RSLT+1 , ; // १���� (��᢮��� I ��㯯� ���஢��)
          m1ishod := 306      , ; // ��室 = �ᬮ��
          MN_DATA := st_N_DATA         , ; // ��� ��砫� ��祭��
          MK_DATA := st_K_DATA         , ; // ��� ����砭�� ��祭��
          MVRACH := space(10)         , ; // 䠬���� � ���樠�� ���饣� ���
          M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
          m1povod  := 4, ;   // ��䨫����᪨�
          m1travma := 0, ;
          m1USL_OK := USL_OK_POLYCLINIC, ; // �����������
          m1VIDPOM :=  1, ; // ��ࢨ筠�
          m1PROFIL := 68, ; // ��������
          m1IDSP   := 17   // �����祭�� ��砩 � �-��
  //
  Private mm_kateg_uch := {{'ॡ����-���', 0}, ;
                           {'ॡ����, ��⠢訩�� ��� ����祭�� த�⥫��', 1}, ;
                           {'ॡ����, ��室�騩�� � ��㤭�� ��������� ���樨', 2}, ;
                           {'��� ��⥣�ਨ', 3}}
  Private mm_mesto_prov := {{'����樭᪠� �࣠������', 0}, ;
                            {'��饮�ࠧ���⥫쭮� ��०�����', 1}}
  Private mm_fiz_razv := {{'��ଠ�쭮�', 0}, ;
                          {'� �⪫�����ﬨ', 1}}
  Private mm_fiz_razv1 := {{'���    ', 0}, ;
                           {'�����', 1}, ;
                           {'����⮪', 2}}
  Private mm_fiz_razv2 := {{'���    ', 0}, ;
                           {'������ ', 1}, ;
                           {'��᮪��', 2}}
  Private mm_psih2 := {{'��ଠ', 0}, {'����襭��', 1}}
  Private mm_142me3 := {{'ॣ����', 0}, ;
                        {'��ॣ����', 1}}
  Private mm_142me4 := {{'������', 0}, ;
                        {'㬥७��', 1}, ;
                        {'�㤭�', 2}}
  Private mm_142me5 := {{'����������', 0}, ;
                        {'�������������', 1}}
  Private mm_dispans := {{'࠭��', 1}, {'�����', 2}, {'�� ���.', 0}}
  Private mm_usl := {{'���.', 0}, {'��/�', 1}, {'���', 2}}
  Private mm_uch := {{'��� ', 1}, {'��� ', 0}, {'䥤.', 2}, {'���', 3}}
  Private mm_uch1 := aclone(mm_uch)
  aadd(mm_uch1, {'ᠭ.', 4})
  Private mm_gr_fiz_do := {{'I', 1}, {'II', 2}, {'III', 3}, {'IV', 4}}
  Private mm_gr_fiz := aclone(mm_gr_fiz_do)
  aadd(mm_gr_fiz_do, {'���������', 0})
  aadd(mm_gr_fiz, {'�� ����饭', 0})
  Private mm_invalid2 := {{'� ஦�����', 0}, {'�ਮ��⥭���', 1}}
  Private mm_invalid5 := {{'������� ��䥪樮��� � ��ࠧ����,', 1}, ;
                          {' �� ���: �㡥�㫥�,', 101}, ;
                          {'         �䨫��,', 201}, ;
                          {'         ���-��䥪��;', 301}, ;
                          {'������ࠧ������;', 2}, ;
                          {'������� �஢�, �஢�⢮��� �࣠��� ...', 3}, ;
                          {'������� ���ਭ��� ��⥬� ...', 4}, ;
                          {' �� ���: ���� ������;', 104}, ;
                          {'����᪨� ����ன�⢠ � ����ன�⢠ ���������,', 5}, ;
                          {' � ⮬ �᫥ ��⢥���� ���⠫����;', 105}, ;
                          {'������� ��ࢭ�� ��⥬�,', 6}, ;
                          {' �� ���: �ॡࠫ�� ��ࠫ��,', 106}, ;
                          {'         ��㣨� ��ࠫ���᪨� ᨭ�஬�;', 206}, ;
                          {'������� ����� � ��� �ਤ��筮�� ������;', 7}, ;
                          {'������� �� � ��楢������ ����⪠;', 8}, ;
                          {'������� ��⥬� �஢����饭��;', 9}, ;
                          {'������� �࣠��� ��堭��,', 10}, ;
                          {' �� ���: ��⬠,', 110}, ;
                          {'         ��⬠��᪨� �����;', 210}, ;
                          {'������� �࣠��� ��饢�७��;', 11}, ;
                          {'������� ���� � ��������� �����⪨;', 12}, ;
                          {'������� ���⭮-���筮� ��⥬� � ᮥ����⥫쭮� ⪠��;', 13}, ;
                          {'������� ��祯������ ��⥬�;', 14}, ;
                          {'�⤥��� ���ﭨ�, ��������騥 � ��ਭ�⠫쭮� ��ਮ��;', 15}, ;
                          {'�஦����� ��������,', 16}, ;
                          {' �� ���: �������� ��ࢭ�� ��⥬�,', 116}, ;
                          {'         �������� ��⥬� �஢����饭��,', 216}, ;
                          {'         �������� ���୮-�����⥫쭮�� ������;', 316}, ;
                          {'��᫥��⢨� �ࠢ�, ��ࠢ����� � ��.', 17}}
  Private mm_invalid6 := {{'��⢥���', 1}, ;
                          {'��㣨� ��宫����᪨�', 2}, ;
                          {'�몮�� � �祢�', 3}, ;
                          {'��客� � ���⨡����', 4}, ;
                          {'��⥫��', 5}, ;
                          {'����ࠫ�� � ��⠡����᪨� ����ன�⢠ ��⠭��', 6}, ;
                          {'�����⥫��', 7}, ;
                          {'�த��騥', 8}, ;
                          {'��騥 � ����ࠫ��������', 9}}
  Private mm_invalid8 := {{'���������', 1}, ;
                          {'���筮', 2}, ;
                          {'����', 3}, ;
                          {'�� �믮�����', 0}}
  Private mm_privivki1 := {{'�ਢ�� �� �������', 0}, ;
                           {'�� �ਢ�� �� ����樭᪨� ���������', 1}, ;
                           {'�� �ਢ�� �� ��㣨� ��稭��', 2}}
  Private mm_privivki2 := {{'���������', 1}, ;
                           {'���筮', 2}}
  //
  Private metap := 1, mperiod := 0, mshifr_zs := '', mnapr_onk := space(10), m1napr_onk := 0, ;
          mkateg_uch, m1kateg_uch := 3, ; // ��⥣��� ��� ॡ����:
          mmesto_prov := space(10), m1mesto_prov := 0, ; // ���� �஢������
          mMO_PR := space(10), m1MO_PR := st_mo_pr, ; // ��� �� �ਪ९�����
          mschool := space(10), m1school := 0, ; // ��� ���.��०�����
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
          mdiag_15[5, 14], ; //
          mGRUPPA_DO := 0, ; // ��㯯� ���஢�� �� ���-��
          mGR_FIZ_DO, m1GR_FIZ_DO := 1, ;
          mdiag_16_1, m1diag_16_1 := 1, ; // ����ﭨ� ���஢�� �� १���⠬ �஢������ ���ᬮ�� (�ࠪ��᪨ ���஢)
          mdiag_16[5, 16], ; //
          minvalid[8], ;  // ࠧ��� 16.7
          mGRUPPA := 0, ;    // ��㯯� ���஢�� ��᫥ ���-��
          mGR_FIZ, m1GR_FIZ := 1, ;
          mPRIVIVKI[3], ; // �஢������ ��䨫����᪨� �ਢ����
          mrek_form := space(255), ; // 'C100',���������樨 �� �ନ஢���� ���஢��� ��ࠧ� �����, ०��� ���, ��⠭��, 䨧��᪮�� ࠧ����, ���㭮��䨫��⨪�, ������ 䨧��᪮� �����ன
          mrek_disp := space(255), ; // 'C100',���������樨 �� ��ᯠ��୮�� �������, ��祭��, ����樭᪮� ॠ�����樨 � ᠭ��୮-����⭮�� ��祭�� � 㪠������ �������� (��� ���), ���� ����樭᪮� �࣠����樨 � ᯥ樠�쭮�� (��������) ���
          mhormon := '0 ��.', m1hormon := 1, not_hormon, ;
          mm_step2 := {{'���  ', 0}, {'��   ', 1}, {'�����', 2}}, ;
          mstep2, m1step2 := 0, m1p_otk := 0, musl2 := '���', m1usl2 := 0
  Private minvalid1, m1invalid1 := 0, ;
          minvalid2, m1invalid2 := 0, ;
          minvalid3 := ctod(''), minvalid4 := ctod(''), ;
          minvalid5, m1invalid5 := 0, ;
          minvalid6, m1invalid6 := 0, ;
          minvalid7 := ctod(''), ;
          minvalid8, m1invalid8 := 0
  Private mprivivki1, m1privivki1 := 0, ;
          mprivivki2, m1privivki2 := 0, ;
          mprivivki3 := space(100)
  Private mvar, m1var, m1lis := 0
  Private mDS_ONK, m1DS_ONK := 0 // �ਧ��� �����७�� �� �������⢥���� ������ࠧ������
  Private mdopo_na, m1dopo_na := 0
  Private mm_dopo_na := arr_mm_dopo_na()
  Private gl_arr := {;  // ��� ��⮢�� �����
    {'dopo_na', 'N', 10, 0, , , , {|x|inieditspr(A__MENUBIT, mm_dopo_na, x)} };
   }
  Private mnapr_v_mo, m1napr_v_mo := 0, mm_napr_v_mo := arr_mm_napr_v_mo(), ;
          arr_mo_spec := {}, ma_mo_spec, m1a_mo_spec := 1
  Private mnapr_stac, m1napr_stac := 0, mm_napr_stac := arr_mm_napr_stac(), ;
          mprofil_stac, m1profil_stac := 0
  Private mnapr_reab, m1napr_reab := 0, mprofil_kojki, m1profil_kojki := 0, arr_usl_otkaz := {}
  Private mm_otkaz := {{'�믮�.', 0}, {'����� ', 1}}, is_neonat := .f.

  private mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

  Private m1NAPR_MO, mNAPR_MO, mNAPR_DATE, mNAPR_V, m1NAPR_V, mMET_ISSL, m1MET_ISSL, ;
          mshifr, mshifr1, mname_u, mU_KOD, cur_napr := 0, count_napr := 0, tip_onko_napr := 0, ;
          mTab_Number := 0
          
  // Private mm_napr_v := {{'���', 0}, ;
  //                       {'� ��������', 1}, ;
  //                       {'�� ����᫥�������', 3}}
  // /*Private mm_napr_v := {{'���', 0}, ;
  //                       {'� ��������', 1}, ;
  //                       {'�� ������', 2}, ;
  //                       {'�� ����᫥�������', 3}, ;
  //                       {'��� ��।���� ⠪⨪� ��祭��', 4}}*/
  // Private mm_met_issl := {{'���', 0}, ;
  //                         {'������ୠ� �������⨪�', 1}, ;
  //                         {'�����㬥�⠫쭠� �������⨪�', 2}, ;
  //                         {'��⮤� ��祢�� �������⨪� (����ண����騥)', 3}, ;
  //                         {'��ண����騥 ��⮤� ��祢�� �������⨪�', 4}}
  //
  for i := 1 to 5
    for k := 1 to 14
      s := 'diag_15_' + lstr(i) + '_' + lstr(k)
      mvar := 'm' + s
      if k == 1
        Private &mvar := space(6)
      else
        m1var := 'm1' + s
        Private &m1var := 0
        Private &mvar := space(4)
      endif
    next
  next
  //
  for i := 1 to 5
    for k := 1 to 16
      s := 'diag_16_' + lstr(i) + '_' + lstr(k)
      mvar := 'm' + s
      if k == 1
        Private &mvar := space(6)
      else
        m1var := 'm1' + s
        Private &m1var := 0
        Private &mvar := space(3)
      endif
    next
  next
  for i := 1 to count_pn_arr_iss // ��᫥�������
    if eq_any(i, 8, 10)  // ����⮫�� � ���᪨� �������
      m1var := 'M1ONKO' + lstr(i)
      Private &m1var := 0
      mvar := 'MONKO' + lstr(i)
      Private &mvar := inieditspr(A__MENUVERT, mm_vokod, &m1var)
    endif
    mvar := 'MTAB_NOMiv' + lstr(i)
    Private &mvar := 0
    mvar := 'MTAB_NOMia' + lstr(i)
    Private &mvar := 0
    mvar := 'MDATEi' + lstr(i)
    Private &mvar := ctod('')
    mvar := 'MREZi' + lstr(i)
    Private &mvar := space(17)
    mvar := 'MOTKAZi' + lstr(i)
    Private &mvar := mm_otkaz[1, 1]
    mvar := 'M1OTKAZi' + lstr(i)
    Private &mvar := mm_otkaz[1, 2]
    m1var := 'M1LIS' + lstr(i)
    Private &m1var := 0
    mvar := 'MLIS' + lstr(i)
    Private &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
  next
  for i := 1 to count_pn_arr_osm // �ᬮ���
    mvar := 'MTAB_NOMov' + lstr(i)
    Private &mvar := 0
    mvar := 'MTAB_NOMoa' + lstr(i)
    Private &mvar := 0
    mvar := 'MDATEo' + lstr(i)
    Private &mvar := ctod('')
    mvar := 'MKOD_DIAGo' + lstr(i)
    Private &mvar := space(6)
    mvar := 'MOTKAZo' + lstr(i)
    Private &mvar := mm_otkaz[1, 1]
    mvar := 'M1OTKAZo' + lstr(i)
    Private &mvar := mm_otkaz[1, 2]
  next
  for i := 1 to 2                // �������(�)
    mvar := 'MTAB_NOMpv' + lstr(i)
    Private &mvar := 0
    mvar := 'MTAB_NOMpa' + lstr(i)
    Private &mvar := 0
    mvar := 'MDATEp' + lstr(i)
    Private &mvar := ctod('')
    mvar := 'MKOD_DIAGp' + lstr(i)
    Private &mvar := space(6)
    mvar := 'MOTKAZp' + lstr(i)
    Private &mvar := mm_otkaz[1, 1]
    mvar := 'M1OTKAZp' + lstr(i)
    Private &mvar := mm_otkaz[1, 2]
  next
  //
  afill(adiag_talon, 0)
  //
  dbcreate(cur_dir + 'tmp', {;
     {'U_KOD'  ,    'N',      4,      0}, ;  // ��� ��㣨
     {'U_SHIFR',    'C',     10,      0}, ;  // ��� ��㣨
     {'U_NAME',     'C',     65,      0} ;  // ������������ ��㣨
    })
  use (cur_dir + 'tmp')
  index on str(u_kod, 4) to (cur_dir + 'tmpk')
  index on fsort_usl(u_shifr) to (cur_dir + 'tmpn')
  set index to (cur_dir + 'tmpk'), (cur_dir + 'tmpn')
  R_Use(dir_server + 'human_', , 'HUMAN_')
  R_Use(dir_server + 'human', , 'HUMAN')
  set relation to recno() into HUMAN_
  if mkod_k > 0
    R_Use(dir_server + 'kartote2', , 'KART2')
    goto (mkod_k)
    R_Use(dir_server + 'kartote_', , 'KART_')
    goto (mkod_k)
    R_Use(dir_server + 'kartotek', , 'KART')
    goto (mkod_k)
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
    if kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    endif
    if eq_any(is_uchastok, 1, 3)
      MUCH_DOC := padr(amb_kartaN(), 10)
    elseif mem_kodkrt == 2
      MUCH_DOC := padr(lstr(mkod_k), 10)
    endif
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(1,, .t.) // ������ � �������
    endif
    // �஢�ઠ ��室� = ������ � ���� �।���� ��䨫��⨪
    select HUMAN
    set index to (dir_server + 'humankk')
    find (str(mkod_k, 7))
    do while human->kod_k == mkod_k .and. !eof()
      if recno() != Loc_kod .and. human_->oplata != 9 .and. human_->NOVOR == 0 .and. year(human->k_data) > 2017
        if is_death(human_->RSLT_NEW)
          a_smert := {'����� ���쭮� 㬥�!', ;
                      '��祭�� � ' + full_date(human->N_DATA) + ;
                            ' �� ' + full_date(human->K_DATA)}
        endif
        if eq_any(human->ishod, 301, 302) // �᫨ ��䨫��⨪� ��ᮢ��襭����⭨�
          read_arr_PN(human->kod, .f.) // �⠥� ��६����� 'mperiod'
          _mperiod := mperiod
          if _mperiod > 0
            aadd(arr_prof, {_mperiod, human->n_data, human->k_data})
            if eq_any(_mperiod, 1, 2)
              R_Use(dir_server + 'uslugi', , 'USL')
              R_Use(dir_server + 'human_u', dir_server + 'human_u', 'HU')
              find (str(human->kod, 7))
              do while hu->kod == human->kod .and. !eof()
                usl->(dbGoto(hu->u_kod))
                if empty(lshifr := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data))
                  lshifr := usl->shifr
                endif
                if alltrim(lshifr) == '3.5.4' // �㤨������᪨� �ਭ���
                  is_3_5_4 := .t.
                endif
                select HU
                skip
              enddo
              hu->(dbCloseArea())
              usl->(dbCloseArea())
            endif
          endif
        endif
      endif
      select HUMAN
      skip
    enddo
    set index to
  endif
  if Loc_kod > 0
    select HUMAN
    goto (Loc_kod)
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
    if human->OBRASHEN == '1'
      m1DS_ONK := 1
    endif
    if empty(val(msmo := human_->SMO))
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    else
      m1komu := m1str_crb := 0
    endif
    m1okato    := human_->OKATO  // ����� ��ꥪ� �� ����ਨ ���客����
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    mcena_1    := human->CENA_1
    metap      := human->ishod - 300
    mGRUPPA    := human_->RSLT_NEW - L_BEGIN_RSLT
    is_disp_19 := !(mk_data < 0d20191101)
    if metap == 2
      m1step2 := 1
    endif
    //
    larr_i := array(count_pn_arr_iss)
    afill(larr_i, 0)
    larr_o := array(count_pn_arr_osm)
    afill(larr_o, 0)
    larr_p := {}
    mdate1 := mdate2 := ctod('')
    R_Use(dir_server + 'uslugi', , 'USL')
    use_base('human_u')
    find (str(Loc_kod, 7))
    do while hu->kod == Loc_kod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1, usl->kod, mk_data))
        lshifr := usl->shifr
      endif
      lshifr := alltrim(lshifr)
      if left(lshifr, 5) == '72.2.'
        mshifr_zs := lshifr
      elseif hu->is_edit == -1
        select TMP
        append blank
        tmp->U_KOD := hu->u_kod
        tmp->U_SHIFR := usl->shifr
        tmp->U_NAME := usl->name
        ++m1usl2
      else
        fl := .t.
        for i := 1 to count_pn_arr_iss
          if np_arr_issled[i, 1] == lshifr
            fl := .f.
            larr_i[i] := hu->(recno())
            exit
          elseif (j := ascan(np_arr_not_zs, {|x| x[2] == lshifr })) > 0 .and. np_arr_issled[i, 1] == np_arr_not_zs[j, 1]
            fl := .f.
            larr_i[i] := hu->(recno())
            exit
          endif
        next
        if fl
          for i := 1 to count_pn_arr_osm
            if left(np_arr_osmotr[i, 1], 4) == '2.4.'
              if lshifr == np_arr_osmotr[i, 1]
                fl := .f.
                larr_o[i] := hu->(recno())
                exit
              endif
            elseif f_profil_ginek_otolar(np_arr_osmotr[i, 4], hu_->PROFIL)
              fl := .f.
              larr_o[i] := hu->(recno())
              exit
            endif
          next i
        endif
        if fl .and. eq_any(hu_->PROFIL, 68, 57)
          aadd(larr_p, {hu->(recno()), c4tod(hu->date_u)})
        endif
      endif
      aadd(arr_usl, hu->(recno()))
      select HU
      skip
    enddo
    if m1step2 == 1
      musl2 := '���-�� ��� - ' + lstr(m1usl2)
    else
      m1usl2 := 0
      select TMP
      zap
    endif
    if len(larr_p) > 1 // �᫨ �ᬮ�� ������� I �⠯� ������� ������� II �⠯�
      asort(larr_p,,, {|x, y| x[2] < y[2] } )
      if metap == 1
        asize(larr_p, 1) // ��१��� ��譨� ����
      else
        do while len(larr_p) > 2 // ����� ������� I �⠯� ����� ��� ��� ��㣨 (2.3.* � 2.91.*)
          hb_ADel(larr_p, 2, .t.) // �.�. ��⠢�塞 ���� � ��᫥���� ���
        enddo
      endif
    endif
    R_Use(dir_server + 'mo_pers', , 'P2')
    for j := 1 to 3
      if j == 1
        _arr := larr_i
        bukva := 'i'
      elseif j == 2
        _arr := larr_o
        bukva := 'o'
      else
        _arr := larr_p
        bukva := 'p'
      endif
      for i := 1 to len(_arr)
        k := iif(j == 3, _arr[i, 1], _arr[i])
        if !empty(k)
          hu->(dbGoto(k))
          if hu->kod_vr > 0
            p2->(dbGoto(hu->kod_vr))
            mvar := 'MTAB_NOM' + bukva + 'v' + lstr(i)
            &mvar := p2->tab_nom
          endif
          if hu->kod_as > 0
            p2->(dbGoto(hu->kod_as))
            mvar := 'MTAB_NOM' + bukva + 'a' + lstr(i)
            &mvar := p2->tab_nom
          endif
          mvar := 'MDATE' + bukva + lstr(i)
          &mvar := c4tod(hu->date_u)
          if j == 1
            m1var := 'm1lis' + lstr(i)
            if is_disp_19
              &m1var := 0
            elseif glob_yes_kdp2[TIP_LU_PN] .and. ascan(glob_arr_usl_LIS, np_arr_issled[i, 1]) > 0 .and. hu->is_edit > 0
              &m1var := hu->is_edit
            endif
            mvar := 'mlis' + lstr(i)
            &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
          elseif j == 2 .and. eq_any(i, 8, 10)
            m1var := 'm1onko' + lstr(i)
            if hu->is_edit > 0
              &m1var := hu->is_edit
            endif
            mvar := 'monko' + lstr(i)
            &mvar := inieditspr(A__MENUVERT, mm_vokod, &m1var)
          elseif !empty(hu_->kod_diag) .and. !(left(hu_->kod_diag, 1) == 'Z')
            mvar := 'MKOD_DIAG' + bukva + lstr(i)
            &mvar := hu_->kod_diag
          endif
          m1var := 'M1OTKAZ' + bukva + lstr(i)
          &m1var := 0 // �믮�����
          mvar := 'MOTKAZ' + bukva + lstr(i)
          &mvar := inieditspr(A__MENUVERT, mm_otkaz, &m1var)
        endif
      next
    next
    read_arr_PN(Loc_kod)
    if metap == 1 .and. m1p_otk == 1
      m1step2 := 2
    endif
    if valtype(arr_usl_otkaz) == 'A'
      for j := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[j]
        if valtype(ar) == 'A' .and. len(ar) > 9 .and. valtype(ar[5]) == 'C' .and. ;
                                                      valtype(ar[10]) == 'C' .and. ar[10] $ 'io'
          lshifr := alltrim(ar[5])
          bukva := ar[10]
          if (i := ascan(iif(bukva == 'i', np_arr_issled, np_arr_osmotr), {|x| valtype(x[1]) == 'C' .and. x[1] == lshifr})) > 0
            if valtype(ar[1]) == 'N' .and. ar[1] > 0
              p2->(dbGoto(ar[1]))
              mvar := 'MTAB_NOM' + bukva + 'v' + lstr(i)
              &mvar := p2->tab_nom
            endif
            if valtype(ar[3]) == 'N' .and. ar[3] > 0
              p2->(dbGoto(ar[3]))
              mvar := 'MTAB_NOM' + bukva + 'a' + lstr(i)
              &mvar := p2->tab_nom
            endif
            mvar := 'MDATE' + bukva + lstr(i)
            &mvar := mn_data
            if valtype(ar[9]) == 'D'
              &mvar := ar[9]
            endif
            m1var := 'M1OTKAZ' + bukva + lstr(i)
            &m1var := 1 // �⪠�
            mvar := 'MOTKAZ' + bukva + lstr(i)
            &mvar := inieditspr(A__MENUVERT, mm_otkaz, &m1var)
          endif
        endif
      next
    endif
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(2, @rec_inogSMO, .t.) // ������ � �������
    endif
  endif
  if !(left(msmo, 2) == '34') // �� ������ࠤ᪠� �������
    m1ismo := msmo
    msmo := '34'
  endif

  dbcreate(cur_dir + 'tmp_onkna', create_struct_temporary_onkna())
  cur_napr := 1 // �� ।-�� - ᭠砫� ��ࢮ� ���ࠢ����� ⥪�饥
  count_napr := collect_napr_zno(Loc_kod)
  if count_napr > 0
    mnapr_onk := '������⢮ ���ࠢ����� - ' + lstr(count_napr)
  endif

  close databases
  is_talon := .t.

  fv_date_r( iif(Loc_kod > 0, mn_data,) )
  MFIO_KART := _f_fio_kart()
  mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  mlpu      := inieditspr(A__POPUPMENU, dir_server + 'mo_uch', m1lpu)
  motd      := inieditspr(A__POPUPMENU, dir_server + 'mo_otd', m1otd)
  mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
  mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
  mismo     := init_ismo(m1ismo)
  f_valid_komu(, -1)
  if m1komu == 0
    m1company := int(val(msmo))
  elseif eq_any(m1komu, 1, 3)
    m1company := m1str_crb
  endif
  mcompany := inieditspr(A__MENUVERT, mm_company, m1company)
  if m1company == 34
    if !empty(mismo)
      mcompany := padr(mismo, 38)
    elseif !empty(mnameismo)
      mcompany := padr(mnameismo, 38)
    endif
  endif
  //
  mmesto_prov := inieditspr(A__MENUVERT, mm_mesto_prov, m1mesto_prov) // ���� �஢������
  mmobilbr := inieditspr(A__MENUVERT, mm_danet, m1mobilbr)
  mschool := inieditspr(A__POPUPMENU, dir_server + 'mo_schoo', m1school)
  mkateg_uch := inieditspr(A__MENUVERT, mm_kateg_uch, m1kateg_uch)
  if !empty(m1MO_PR)
    mMO_PR := ret_mo(m1MO_PR)[_MO_SHORT_NAME]
  endif
  mfiz_razv  := inieditspr(A__MENUVERT, mm_fiz_razv,  m1FIZ_RAZV)
  mfiz_razv1 := inieditspr(A__MENUVERT, mm_fiz_razv1, m1FIZ_RAZV1)
  mfiz_razv2 := inieditspr(A__MENUVERT, mm_fiz_razv2, m1FIZ_RAZV2)
  mpsih21 := inieditspr(A__MENUVERT, mm_psih2, m1psih21)
  mpsih22 := inieditspr(A__MENUVERT, mm_psih2, m1psih22)
  mpsih23 := inieditspr(A__MENUVERT, mm_psih2, m1psih23)
  m142me3 := inieditspr(A__MENUVERT, mm_142me3, m1142me3)
  m142me4 := inieditspr(A__MENUVERT, mm_142me4, m1142me4)
  m142me5 := inieditspr(A__MENUVERT, mm_142me5, m1142me5)
  mdiag_15_1 := inieditspr(A__MENUVERT, mm_danet, m1diag_15_1)
  mdiag_16_1 := inieditspr(A__MENUVERT, mm_danet, m1diag_16_1)
  mstep2 := inieditspr(A__MENUVERT, mm_step2, m1step2)
  minvalid1 := inieditspr(A__MENUVERT, mm_danet,    m1invalid1)
  minvalid2 := inieditspr(A__MENUVERT, mm_invalid2, m1invalid2)
  minvalid5 := inieditspr(A__MENUVERT, mm_invalid5, m1invalid5)
  minvalid6 := inieditspr(A__MENUVERT, mm_invalid6, m1invalid6)
  minvalid8 := inieditspr(A__MENUVERT, mm_invalid8, m1invalid8)
  mprivivki1 := inieditspr(A__MENUVERT, mm_privivki1, m1privivki1)
  mprivivki2 := inieditspr(A__MENUVERT, mm_privivki2, m1privivki2)
  mgr_fiz_do := inieditspr(A__MENUVERT, mm_gr_fiz_do, m1gr_fiz_do)
  mgr_fiz    := inieditspr(A__MENUVERT, mm_gr_fiz, m1gr_fiz)
  mDS_ONK    := inieditspr(A__MENUVERT, mm_danet, M1DS_ONK)
  mdopo_na   := inieditspr(A__MENUBIT,  mm_dopo_na, m1dopo_na)
  mnapr_v_mo := inieditspr(A__MENUVERT, mm_napr_v_mo, m1napr_v_mo)
  if empty(arr_mo_spec)
    ma_mo_spec := '---'
  else
    ma_mo_spec := ''
    for i := 1 to len(arr_mo_spec)
      ma_mo_spec += lstr(arr_mo_spec[i]) + ','
    next
    ma_mo_spec := left(ma_mo_spec, len(ma_mo_spec) - 1)
  endif
  mnapr_stac := inieditspr(A__MENUVERT, mm_napr_stac, m1napr_stac)
  mprofil_stac := inieditspr(A__MENUVERT, getV002(), m1profil_stac)
  mnapr_reab := inieditspr(A__MENUVERT, mm_danet, m1napr_reab)
  mprofil_kojki := inieditspr(A__MENUVERT, getV020(), m1profil_kojki)
  //
  if !empty(f_print)
    return &(f_print + '(' + lstr(Loc_kod) + ',' + lstr(kod_kartotek) + ',' + lstr(mdvozrast) + ')')
  endif
  //
  str_1 := ' ���� ��䨫��⨪� ��ᮢ��襭����⭨�'
  if Loc_kod == 0
    str_1 := '����������' + str_1
    mtip_h := yes_vypisan
  else
    str_1 := '������஢����' + str_1
  endif
  setcolor(color8)
  //
  Private gl_area
  setcolor(cDataCGet)
  make_diagP(1)  // ᤥ���� '��⨧����' ��������
  Private num_screen := 1
  do while .t.
    close databases
    DispBegin()
    if num_screen == 5
      hS := 32
      wS := 90
      if m1step2 == 2
        hS += 2
      endif
    elseif num_screen == 3
      hS := 30
      wS := 80
    else
      hS := 25
      wS := 80
    endif
    SetMode(hS, wS)
    @ 0, 0 say padc(str_1,wS) color 'B/BG*'
    gl_area := {1, 0,maxrow() - 1, maxcol(), 0}
    j := 1
    myclear(j)
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j, (wS - 30) say padl('���� ��� � ' + lstr(Loc_kod), 29) color color14
    endif
    @ j, 0 say '��࠭ ' + lstr(num_screen) color color8
    if num_screen > 1
      s1 := ' '
      is_disp_19 := !(mk_data < 0d20191101)
      mperiod := ret_period_PN(mdate_r, mn_data, mk_data, @s1)
      s := alltrim(mfio)
      if mperiod > 0
        s += s1
      endif
      @ j, wS - len(s) say s color color14
      if !between(mperiod, 1, 31)
        DispEnd()
        func_error(4, '�� 㤠���� ��।����� �����⭮� ��ਮ�!')
        if !empty(s1)
          func_error(10, s1)
        endif
        num_screen := 1
        loop
      elseif (i := ascan(arr_prof, {|x| x[1] == mperiod})) > 0
        DispEnd()
        func_error(4, '��� �뫠 �������筠� ��䨫��⨪� � ' + date_8(arr_prof[i, 2]) + ' �� ' + date_8(arr_prof[i, 3]))
        num_screen := 1
        loop
      endif
    endif
    if num_screen == 1
      @ ++j, 1 say '��०�����' get mlpu when .f. color cDataCSay
      @ row(),col() + 2 say '�⤥�����' get motd when .f. color cDataCSay
      //
      @ ++j, 1 say '���' get mfio_kart ;
           reader {|x| menu_reader(x, {{|k, r, c| get_fio_kart(k, r, c)}}, A__FUNCTION, , , .f.)} ;
           valid {|g, o| update_get('mkomu'), update_get('mcompany') }
      @ ++j, 1 say '�ਭ���������� ����' get mkomu ;
                 reader {|x|menu_reader(x, mm_komu, A__MENUVERT, , , .f.)} ;
                 valid {|g, o| f_valid_komu(g, o) } ;
                 color colget_menu
      @ row(), col() + 1 say '==>' get mcompany ;
               reader {|x|menu_reader(x, mm_company, A__MENUVERT, , , .f.)} ;
               when m1komu < 5 ;
               valid {|g| func_valid_ismo(g,m1komu, 38) }
      @ ++j, 1 say '����� ���: ���' get mspolis when m1komu == 0
      @ row(), col() + 3 say '�����'  get mnpolis when m1komu == 0
      @ row(), col() + 3 say '���'    get mvidpolis ;
                reader {|x|menu_reader(x, mm_vid_polis, A__MENUVERT, , , .f.)} ;
                when m1komu == 0 ;
                valid func_valid_polis(m1vidpolis, mspolis, mnpolis)
      @ ++j, 1 to j, 78
      @ ++j, 1 say '��⥣��� ��� ॡ����' get mkateg_uch ;
                reader {|x|menu_reader(x, mm_kateg_uch, A__MENUVERT, , , .f.)}
      ++j
      @ ++j, 1 say '�ப� ��䨫��⨪�' get mn_data ;
                valid {|g| f_k_data(g, 1), ;
                    iif(mvozrast < 18, nil, func_error(4, '�� ����� ��樥��!')), ;
                      msvozrast := padr(count_ymd(mdate_r,mn_data), 40), ;
                      .t.;
                  }
      @ row(), col() + 1 say '-' get mk_data valid {|g|f_k_data(g, 2)}
      @ row(),col()+3 get msvozrast when .f. color color14
      @ ++j, 1 say '� ���㫠�୮� �����' get much_doc picture '@!' ;
                when !(is_uchastok == 1 .and. is_task(X_REGIST)) ;
                       .or. mem_edit_ist==2
      @ ++j, 1 say '���� �஢������ ����ᬮ��' get mmesto_prov ;
                reader {|x|menu_reader(x, mm_mesto_prov, A__MENUVERT, , , .f.)}
      @ ++j, 1 say '����ᬮ�� �஢��� �����쭮� �ਣ����?' get mmobilbr ;
                reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)}
      ++j
      @ ++j, 1 say '�� �ਪ९�����' get mMO_PR ;
                reader {|x|menu_reader(x, {{|k, r, c|f_get_mo(k, r, c)}}, A__FUNCTION, , , .f.)}
      @ ++j, 1 say '��饮�ࠧ���⥫쭮� ��०�����' get mschool ;
               reader {|x|menu_reader(x, {dir_server + 'mo_schoo', , , , , , '��饮�ࠧ���⥫�� ���-��', 'B/BG'}, A__POPUPBASE, , , .f.)}
      ++j
      @ ++j, 1 say '���' get mWEIGHT pict '999' ;
                valid {|| iif(between(mWEIGHT, 2, 170), , func_error(4, '��ࠧ㬭� ���')), .t.}
      @ row(), col() + 1 say '��, ���' get mHEIGHT pict '999' ;
                valid {|| iif(between(mHEIGHT, 40, 250), , func_error(4, '��ࠧ㬭� ���')), .t.}
      @ row(), col() + 1 say '�, ���㦭���� ������' get mPER_HEAD  pict '999' ;
                valid {|| iif(mdvozrast < 5, iif(between(mPER_HEAD, 10, 100), , func_error(4, '��ࠧ㬭� ࠧ��� ���㦭��� ������')),), .t.}
      @ row(), col() + 1 say '�'
      ++j
      @ ++j, 1 say '�����᪮� ࠧ��⨥' get mfiz_razv ;
              reader {|x|menu_reader(x, mm_fiz_razv, A__MENUVERT, , , .f.)} ;
              valid {|| iif(m1FIZ_RAZV == 0, (mfiz_razv1:='���    ', m1fiz_razv1:=0, ;
                                               mfiz_razv2:='���    ', m1fiz_razv2:=0), nil), .t. }
      @ ++j, 10 say '�⪫������ ����� ⥫�' get mfiz_razv1 ;
              reader {|x|menu_reader(x, mm_fiz_razv1, A__MENUVERT, , , .f.)} ;
               when m1FIZ_RAZV == 1
      @ j, 39 say ', ���' get mfiz_razv2 ;
              reader {|x|menu_reader(x, mm_fiz_razv2, A__MENUVERT, , , .f.)} ;
              when m1FIZ_RAZV == 1
      status_key('^<Esc>^ ��室 ��� ����� ^<PgDn>^ �� 2-� ��࠭���')
      if !empty(a_smert)
        n_message(a_smert, , 'GR+/R', 'W+/R', , , 'G+/R')
      endif
    elseif num_screen == 2
      np_oftal_2_85_21(mperiod, mk_data)
      ar := np_arr_1_etap[mperiod]
      if !empty(ar[5]) // �� ���⮩ ���ᨢ ��᫥�������
        @ ++j, 1 say 'I �⠯ ������������ ��᫥�������       ��� ����.  ���     �믮������ �������' color 'RB+/B'
        if mem_por_ass == 0
          @ j, 45 say space(6)
        endif
        not_hormon := .t.
        for i := 1 to count_pn_arr_iss
          fl := .t.
          if fl .and. !empty(np_arr_issled[i, 2])
            fl := (mpol == np_arr_issled[i, 2])
          endif
          if fl
            fl := (ascan(ar[5], np_arr_issled[i, 1]) > 0)
          endif
          /*if fl .and. np_arr_issled[i, 4] == 1 // ��ମ�
            if not_hormon
         ++j; @ j, 1 say padr('��᫥������� �஢�� ��ମ��� � �஢�', 38) color color8
              @ j, 39 get mhormon ;
                 reader {|x| menu_reader(x, {{|k,r,c| get_hormon_pn(k,r,c)}},A__FUNCTION,,, .f.)}
            endif
            fl := not_hormon := .f.
          endif*/
          if fl
            fl_kdp2 := .f.
            if !is_disp_19 .and. glob_yes_kdp2[TIP_LU_PN] .and. ascan(glob_arr_usl_LIS, np_arr_issled[i, 1]) > 0
              fl_kdp2 := .t.
            endif
            mvarv := 'MTAB_NOMiv' + lstr(i)
            mvara := 'MTAB_NOMia' + lstr(i)
            mvard := 'MDATEi' + lstr(i)
            mvarr := 'MREZi' + lstr(i)
            mvaro := 'MOTKAZi' + lstr(i)
            mvarlis := 'MLIS' + lstr(i)
            if empty(&mvard)
              &mvard := mn_data
            endif
            @ ++j, 1 say padr(np_arr_issled[i, 3], 38)
            if fl_kdp2
              @ j, 34 get &mvarlis reader {|x|menu_reader(x, mm_kdp2, A__MENUVERT, , , .f.)}
            endif
            @ j, 39 get &mvarv pict '99999' valid {|g| v_kart_vrach(g) }
            if mem_por_ass > 0
              @ j, 45 get &mvara pict '99999' valid {|g| v_kart_vrach(g) }
            endif
            @ j, 51 get &mvard
            @ j, 62 get &mvaro reader {|x|menu_reader(x, mm_otkaz, A__MENUVERT, , , .f.)}
            @ j, 69 get &mvarr
          endif
        next
      endif
      @ ++j, 1 say 'I �⠯ ������������ �ᬮ�஢           ��� ����.  ���     �믮������' color 'RB+/B'
      if mem_por_ass == 0
        @ j, 45 say space(6)
      endif
      if !empty(ar[4]) // �� ���⮩ ���ᨢ �ᬮ�஢
        for i := 1 to count_pn_arr_osm
          fl := .t.
          if fl .and. !empty(np_arr_osmotr[i, 2])
            fl := (mpol == np_arr_osmotr[i, 2])
          endif
          if fl
            fl := (ascan(ar[4], np_arr_osmotr[i, 1]) > 0)
          endif
          if fl .and. mperiod == 16 .and. mk_data < 0d20191101 .and. np_arr_osmotr[i, 1] == '2.4.2' // 2 ����
            fl := .f.
          endif
          if fl .and. mperiod == 20 .and. mk_data < 0d20191101 .and. np_arr_osmotr[i, 1] == '2.85.24' // 6 ���
            fl := .f.
          endif
          if fl
            mvarv := 'MTAB_NOMov' + lstr(i)
            mvara := 'MTAB_NOMoa' + lstr(i)
            mvard := 'MDATEo' + lstr(i)
            mvaro := 'MOTKAZo' + lstr(i)
            mvarz := 'MKOD_DIAGo' + lstr(i)
            if empty(&mvard)
              &mvard := mn_data
            endif
            @ ++j, 1 say padr(np_arr_osmotr[i, 3], 38)
            @ j, 39 get &mvarv pict '99999' valid {|g| v_kart_vrach(g) }
            if mem_por_ass > 0
              @ j, 45 get &mvara pict '99999' valid {|g| v_kart_vrach(g) }
            endif
            @ j, 51 get &mvard
            @ j, 62 get &mvaro reader {|x|menu_reader(x, mm_otkaz, A__MENUVERT, , , .f.)}
          endif
        next
      endif
      if empty(MDATEp1)
        MDATEp1 := mn_data
      endif
      @ ++j, 1 say padr('������� (��� ��饩 �ࠪ⨪�)', 38) color color8
      @ j, 39 get MTAB_NOMpv1 pict '99999' valid {|g| v_kart_vrach(g) }
      if mem_por_ass > 0
        @ j, 45 get MTAB_NOMpa1 pict '99999' valid {|g| v_kart_vrach(g) }
      endif
      @ j, 51 get MDATEp1
      status_key('^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 1-� ��࠭��� ^<PgDn>^ �� 3-� ��࠭���')
    elseif num_screen == 3
      @ ++j, 1 say '���ࠢ��� �� II �⠯ ?' get mstep2 ;
                 reader {|x|menu_reader(x, mm_step2, A__MENUVERT, , , .f.)}
      if !is_disp_19
        ++j
        @ ++j, 1 say '�������⥫�� ����⮫����᪨� ��᫥������� � ���2' get musl2 ;
                   reader {|x| menu_reader(x, { { |k, r, c| ob2_v_usl(.t., r + 1) }}, A__FUNCTION, , , .f.)} ;
                   when m1step2 == 1
      endif
      ar := np_arr_1_etap[mperiod]
      @ ++j, 1 say 'II �⠯ ������������ �ᬮ�஢          ��� ����.  ���     �믮������' color 'RB+/B'
      if mem_por_ass == 0
        @ j, 45 say space(6)
      endif
      for i := 1 to count_pn_arr_osm
        fl := .t.
        if fl .and. !empty(np_arr_osmotr[i, 2])
          fl := (mpol == np_arr_osmotr[i, 2])
        endif
        if fl .and. !empty(ar[4])
          fl := (ascan(ar[4], np_arr_osmotr[i, 1]) == 0)
        endif
        if fl .and. !(np_arr_osmotr[i, 1] == '2.4.2')
          mvonk := 'MONKO' + lstr(i)
          mvarv := 'MTAB_NOMov' + lstr(i)
          mvara := 'MTAB_NOMoa' + lstr(i)
          mvard := 'MDATEo' + lstr(i)
          mvaro := 'MOTKAZo' + lstr(i)
          mvarz := 'MKOD_DIAGo' + lstr(i)
          @ ++j, 1 say padr(np_arr_osmotr[i, 3], 38)
          if eq_any(i, 8, 10)
            @ j, 32 get &mvonk reader {|x|menu_reader(x, mm_vokod, A__MENUVERT, , , .f.)} when m1step2==1
          endif
          @ j, 39 get &mvarv pict '99999' valid {|g| v_kart_vrach(g) } when m1step2 == 1
          if mem_por_ass > 0
            @ j, 45 get &mvara pict '99999' valid {|g| v_kart_vrach(g) } when m1step2 == 1
          endif
          @ j, 51 get &mvard when m1step2 == 1
          @ j, 62 get &mvaro reader {|x|menu_reader(x, mm_otkaz, A__MENUVERT, , , .f.)} when m1step2 == 1
        endif
      next
      @ ++j, 1 say padr('������� (��� ��饩 �ࠪ⨪�)', 38) color color8
      @ j, 39 get MTAB_NOMpv2 pict '99999' valid {|g| v_kart_vrach(g) } when m1step2 == 1
      if mem_por_ass > 0
        @ j, 45 get MTAB_NOMpa2 pict '99999' valid {|g| v_kart_vrach(g) } when m1step2 == 1
      endif
      @ j, 51 get MDATEp2 when m1step2 == 1
      status_key('^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 2-� ��࠭��� ^<PgDn>^ �� 4-� ��࠭���')
    elseif num_screen == 4
      if mdvozrast < 5 // �᫨ ����� 5 ���
        @ ++j, 1 say padc('�業�� ����᪮�� ࠧ���� (������ ࠧ����):', 78,'_')
        @ ++j, 1 say '�������⥫쭠� �㭪��' get m1psih11 pict '99'
        @ ++j, 1 say '���ୠ� �㭪��      ' get m1psih12 pict '99'
        @ --j, 30 say '�樮���쭠� � �樠�쭠�    ' get m1psih13 pict '99'
        @ ++j, 30 say '�।�祢�� � �祢�� ࠧ��⨥' get m1psih14 pict '99'
      else
        @ ++j, 1 say padc('�業�� ����᪮�� ࠧ����:', 78, '_')
        @ ++j, 1 say '��宬��ୠ� ���' get mpsih21 reader {|x|menu_reader(x, mm_psih2, A__MENUVERT, , , .f.)}
        @ ++j, 1 say '��⥫����          ' get mpsih22 reader {|x|menu_reader(x, mm_psih2, A__MENUVERT, , , .f.)}
        @ --j, 40 say '��.�����⨢��� ���' get mpsih23 reader {|x|menu_reader(x, mm_psih2, A__MENUVERT, , , .f.)}
        ++j
      endif
      ++j
      if mpol == '�'
        @ ++j, 1 say '������� ��㫠 ����稪�: P' get m141p pict '9'
        @ j, col() say ', Ax' get m141ax pict '9'
        @ j, col() say ', Fa' get m141fa pict '9'
      else
        @ ++j, 1 say '������� ��㫠 ����窨: P' get m142p pict '9'
        @ j, col() say ', Ax' get m142ax pict '9'
        @ j, col() say ', Ma' get m142ma pict '9'
        @ j,col() say ', Me' get m142me pict '9'
        @ ++j, 1 say '  menarhe' get m142me1 pict '99'
        @ j, col() + 1 say '���,' get m142me2 pict '99'
        @ j, col() + 1 say '����楢, menses' get m142me3 ;
                reader {|x|menu_reader(x, mm_142me3, A__MENUVERT, , , .f.)}
        @ j, 50 say ',' get m142me4 ;
                reader {|x|menu_reader(x, mm_142me4, A__MENUVERT, , , .f.)}
        @ j, 61 say ',' get m142me5 ;
                reader {|x|menu_reader(x, mm_142me5, A__MENUVERT, , , .f.)}
      endif
      ++j
      @ ++j, 1 say '�� ���������� ����������: �ࠪ��᪨ ���஢' get mdiag_15_1 ;
                  reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)}
      @ ++j, 1 say '������������������������������������������������������������������������������'
      @ ++j, 1 say ' ����-���ᯠ�᳋�祭�� �������믮����������-�� �������믮��������᮪��孮�.��'
      @ ++j, 1 say ' ���  �����-����-�������������������Ĵ�-������������������������������������'
      @ ++j, 1 say '      ���⠭����� ���.����.���.����.��� ���.����.���.����.�४������������'
      @ ++j, 1 say '������������������������������������������������������������������������������'
      for i := 1 to 5
        ++j
        fl := .f.
        for k := 1 to 14
          s := 'diag_15_' + lstr(i)+'_' + lstr(k)
          mvar := 'm' + s
          if k == 1
            fl := !empty(&mvar)
          else
            m1var := 'm1' + s
            if fl
              if eq_any(k, 2)
                mm_m := mm_dispans
              elseif eq_any(k, 4, 6, 9, 11)
                mm_m := mm_usl
              elseif eq_any(k, 5, 7, 10, 12)
                mm_m := mm_uch1
              else
                mm_m := mm_danet
              endif
              &mvar := inieditspr(A__MENUVERT, mm_m, &m1var)
            else
              &m1var := 0
              &mvar := space(4)
            endif
          endif
          do case
            case k == 1
              @ j, 1 get &mvar picture pic_diag ;
                 reader {|o|MyGetReader(o, bg)} valid val1_10diag(.t., .f., .f., mn_data, mpol) ;
                 when m1diag_15_1 == 0
            case k == 2
              @ j, 8 get &mvar ;
                 reader {|x|menu_reader(x, mm_dispans, A__MENUVERT, , , .f.)} ;
                 when m1diag_15_1 == 0
            case k == 3
              @ j, 16 get &mvar ;
                 reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
                 when m1diag_15_1 == 0
            case k == 4
              @ j, 20 get &mvar ;
                 reader {|x|menu_reader(x, mm_usl, A__MENUVERT, , , .f.)} ;
                 when m1diag_15_1 == 0
            case k == 5
              @ j, 25 get &mvar ;
                 reader {|x|menu_reader(x, mm_uch, A__MENUVERT, , , .f.)} ;
                 when m1diag_15_1 == 0
            case k == 6
              @ j, 30 get &mvar ;
                 reader {|x|menu_reader(x, mm_usl, A__MENUVERT, , , .f.)} ;
                 when m1diag_15_1 == 0
            case k == 7
              @ j, 35 get &mvar ;
                 reader {|x|menu_reader(x, mm_uch, A__MENUVERT, , , .f.)} ;
                 when m1diag_15_1 == 0
            case k == 8
              @ j, 40 get &mvar ;
                 reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
                 when m1diag_15_1 == 0
            case k == 9
              @ j, 44 get &mvar ;
                 reader {|x|menu_reader(x, mm_usl, A__MENUVERT, , , .f.)} ;
                 when m1diag_15_1 == 0
            case k == 10
              @ j, 49 get &mvar ;
                 reader {|x|menu_reader(x, mm_uch1, A__MENUVERT, , , .f.)} ;
                 when m1diag_15_1 == 0
            case k == 11
              @ j, 54 get &mvar ;
                 reader {|x|menu_reader(x, mm_usl, A__MENUVERT, , , .f.)} ;
                 when m1diag_15_1 == 0
            case k == 12
              @ j, 59 get &mvar ;
                 reader {|x|menu_reader(x, mm_uch1, A__MENUVERT, , , .f.)} ;
                 when m1diag_15_1 == 0
            case k == 13
              @ j, 66 get &mvar ;
                 reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
                 when m1diag_15_1 == 0
            case k == 14
              @ j, 74 get &mvar ;
                 reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
                 when m1diag_15_1 == 0
          endcase
        next
      next
      @ ++j, 1 to j, 78
      @ ++j, 1 say '������ ���ﭨ� �������� �� �஢������ ���ᬮ��' get mGRUPPA_DO pict '9'
      @ ++j, 1 say '        ����樭᪠� ������ ��� ������ 䨧�����ன' get mGR_FIZ_DO ;
                reader {|x|menu_reader(x, mm_gr_fiz_do, A__MENUVERT, , , .f.)}
      status_key('^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 3-� ��࠭��� ^<PgDn>^ �� 5-� ��࠭���')
    elseif num_screen == 5
      @ ++j, 1 say '�� ����������� ���������� ����������: �ࠪ��᪨ ���஢' get mdiag_16_1 ;
                  reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)}
      @ ++j, 1 say '������������������������������������������������������������������������������'
      @ ++j, 1 say ' ����-���Ⳅ�ᯠ�᳄��.����.��������.����.�믮���祭�� ����������-�� ���������'
      @ ++j, 1 say ' ���  ���������-��������������Ĵ������������Ĵ�-���������Ĵ�-���������Ĵ४'
      @ ++j, 1 say '      �����⠭����� ���.����.��� ���.����.��� ���.����.��� ���.����.����'
      @ ++j, 1 say '������������������������������������������������������������������������������'
      for i := 1 to 5
        ++j
        fl := .f.
        for k := 1 to 16
          s := 'diag_16_' + lstr(i) + '_' + lstr(k)
          mvar := 'm' + s
          if k == 1
            fl := !empty(&mvar)
          else
            m1var := 'm1' + s
            if fl
              if k == 3
                mm_m := mm_dispans
              elseif eq_any(k, 5, 8, 11, 14)
                mm_m := mm_usl
              elseif eq_any(k, 6, 9, 12, 15)
                mm_m := mm_uch1
              else
                mm_m := mm_danet
              endif
              &mvar := inieditspr(A__MENUVERT, mm_m, &m1var)
            else
              &m1var := 0
              &mvar := space(4)
            endif
          endif
          do case
            case k == 1
              @ j, 1 get &mvar picture pic_diag ;
                     reader {|o|MyGetReader(o, bg)} valid val1_10diag(.t., .f., .f., mn_data, mpol) ;
                     when m1diag_16_1 == 0
            case k == 2
              @ j, 8 get &mvar ;
                     reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 3
              @ j, 12 get &mvar ;
                     reader {|x|menu_reader(x, mm_dispans, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 4
              @ j, 20 get &mvar ;
                     reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 5
              @ j, 24 get &mvar ;
                     reader {|x|menu_reader(x, mm_usl, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 6
              @ j, 29 get &mvar ;
                     reader {|x|menu_reader(x, mm_uch, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 7
              @ j, 34 get &mvar ;
                     reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 8
              @ j, 38 get &mvar ;
                     reader {|x|menu_reader(x, mm_usl, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 9
              @ j, 43 get &mvar ;
                     reader {|x|menu_reader(x, mm_uch, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 10
              @ j, 48 get &mvar ;
                     reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 11
              @ j, 52 get &mvar ;
                     reader {|x|menu_reader(x, mm_usl, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 12
              @ j, 57 get &mvar ;
                     reader {|x|menu_reader(x, mm_uch, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 13
              @ j, 62 get &mvar ;
                     reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 14
              @ j, 66 get &mvar ;
                     reader {|x|menu_reader(x, mm_usl, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 15
              @ j, 71 get &mvar ;
                     reader {|x|menu_reader(x, mm_uch1, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
            case k == 16
              @ j, 76 get &mvar ;
                     reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)} ;
                     when m1diag_16_1 == 0
          endcase
        next
      next
      @ ++j, 1 to j, 78
      if m1step2 == 2  // ���ࠢ��� � �⪠����� �� 2-�� �⠯�
        @ ++j, 1 say '�ਧ��� �����७�� �� �������⢥���� ������ࠧ������' get mDS_ONK ;
                reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)}
        @ ++j, 1 say '���ࠢ����� �� �����७�� �� ���' get mnapr_onk ;
                reader {|x|menu_reader(x, {{|k, r, c| fget_napr_ZNO(k, r, c)}}, A__FUNCTION, , , .f.)} ;
                when m1ds_onk == 1
      endif
      dispans_napr(mk_data, @j, .f.)  // �맮� ���������� ����� ���ࠢ�����

      @ ++j, 1 to j, 78
      @ ++j, 1 say '������������' get minvalid1 ;
                reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)}
      @ j, 30 say '�᫨ "��":' get minvalid2 ;
                reader {|x|menu_reader(x, mm_invalid2, A__MENUVERT, , , .f.)} ;
                when m1invalid1 == 1
      @ ++j, 2 say '��⠭������ �����' get minvalid3 ;
                 when m1invalid1 == 1
      @ j, col() + 1 say '��� ��᫥����� �ᢨ��⥫��⢮�����' get minvalid4 ;
                 when m1invalid1 == 1
      @ ++j, 2 say '�����������/������������' get minvalid5 ;
                reader {|x|menu_reader(x, mm_invalid5, A__MENUVERT, , , .f.)} ;
                when m1invalid1 == 1
      @ ++j, 2 say '���� ����襭�� � ���ﭨ� ���஢��' get minvalid6 ;
                reader {|x|menu_reader(x, mm_invalid6, A__MENUVERT, , , .f.)} ;
                when m1invalid1 == 1
      @ ++j, 2 say '��� �����祭�� �������㠫쭮� �ணࠬ�� ॠ�����樨' get minvalid7 ;
                when m1invalid1 == 1
      @ j, col() say ' �믮������' get minvalid8 ;
                reader {|x|menu_reader(x, mm_invalid8, A__MENUVERT, , , .f.)} ;
                when m1invalid1 == 1
      @ ++j, 1 say '�ਢ����' get mprivivki1 ;
                reader {|x|menu_reader(x, mm_privivki1, A__MENUVERT, , , .f.)}
      @ j, 50 say '�� �ਢ��' get mprivivki2 ;
                reader {|x|menu_reader(x, mm_privivki2, A__MENUVERT, , , .f.)} ;
                when m1privivki1 > 0
      @ ++j, 2 say '�㦤����� � ���樭�樨' get mprivivki3 pict '@S54' ;
                when m1privivki1 > 0
      @ ++j, 1 say '���������樨 ���஢��� ��ࠧ� �����' get mrek_form pict '@S52'
      @ ++j, 1 say '���������樨 �� ��ᯠ��୮�� �������' get mrek_disp pict '@S47'
      @ ++j, 1 say '������ ���ﭨ� �������� �� १���⠬ �஢������ ���ᬮ��' get mGRUPPA pict '9'
      @ ++j, 1 say '                    ����樭᪠� ������ ��� ������ 䨧�����ன' get mGR_FIZ ;
                reader {|x|menu_reader(x, mm_gr_fiz, A__MENUVERT, , , .f.)}
      status_key('^<Esc>^ ��室 ��� �����;  ^<PgUp>^ �������� �� 4-� ��࠭���;  ^<PgDn>^ ������')
    endif
    DispEnd()
    count_edit += myread()
    if num_screen == 5
      if lastkey() == K_PGUP
        k := 3
        --num_screen
      else
        k := f_alert({padc('�롥�� ����⢨�', 60, '.')}, ;
                     {' ��室 ��� ����� ', ' ������ ', ' ������ � ।���஢���� '}, ;
                     iif(lastkey() == K_ESC, 1, 2), 'W+/N', 'N+/N', maxrow() - 2, , 'W+/N, N/BG' )
      endif
    else
      if lastkey() == K_PGUP
        k := 3
        if num_screen > 1
          --num_screen
        endif
      elseif lastkey() == K_ESC
        if (k := f_alert({padc('�롥�� ����⢨�', 60, '.')}, ;
                         {' ��室 ��� ����� ', ' ������ � ।���஢���� '}, ;
                         1, 'W+/N', 'N+/N', maxrow() - 2, , 'W+/N, N/BG' )) == 2
          k := 3
        endif
      else
        k := 3
        ++num_screen
      endif
    endif
    SetMode(25, 80)
    if k == 3
      loop
    elseif k == 2
      num_screen := 1
      if m1komu < 5 .and. empty(m1company)
        if m1komu == 0
          s := '���'
        elseif m1komu == 1
          s := '��������'
        else
          s := '������/��'
        endif
        func_error(4, '�� ��������� ������������ ' + s)
        loop
      endif
      if m1komu == 0 .and. empty(mnpolis)
        func_error(4, '�� �������� ����� �����')
        loop
      endif
      if empty(mn_data)
        func_error(4, '�� ������� ��� ��砫� ��祭��.')
        loop
      endif
      if mvozrast >= 18
        func_error(4, '���ᬮ�� ������ ���᫮�� ��樥���!')
        loop
      endif
      if !between(mperiod, 1, 31)
        func_error(4, '�� 㤠���� ��।����� �����⭮� ��ਮ�!')
        num_screen := 1
        loop
      endif
      if empty(mk_data)
        func_error(4, '�� ������� ��� ����砭�� ��祭��.')
        loop
      elseif year(mk_data) < 2018
        func_error(4, '���ᬮ��� �� ������ �ਪ��� �����ࠢ� �� �������� � 2018 ����')
        loop
      endif
      if empty(CHARREPL('0', much_doc, space(10)))
        func_error(4, '�� �������� ����� ���㫠�୮� �����')
        loop
      endif
      if empty(mmo_pr)
        func_error(4, '�� ������� ��, � ���஬� �ਪ९�� ��ᮢ��襭����⭨�.')
        loop
      endif
      if empty(mWEIGHT)
        func_error(4, '�� ����� ���.')
        loop
      endif
      if empty(mHEIGHT)
        func_error(4, '�� ����� ���.')
        loop
      endif
      if mdvozrast < 5 .and. empty(mPER_HEAD)
        func_error(4, '�� ������� ���㦭���� ������.')
        loop
      endif
      if m1FIZ_RAZV == 1 .and. emptyall(m1fiz_razv1, m1fiz_razv2)
        func_error(4, '�� ������� �⪫������ ����� ⥫� ��� ���.')
        loop
      endif
      if ! checkTabNumberDoctor(mk_data, .f.)
        loop
      endif
      if mvozrast < 1
        mdef_diagnoz := 'Z00.1 '
      elseif mvozrast < 14
        mdef_diagnoz := 'Z00.2 '
      else
        mdef_diagnoz := 'Z00.3 '
      endif
      arr_iss := array(count_pn_arr_iss, 10)
      afillall(arr_iss, 0)
      R_Use(dir_exe() + '_mo_mkb', cur_dir + '_mo_mkb', 'MKB_10')
      R_Use(dir_server + 'mo_pers', dir_server + 'mo_pers', 'P2')
      num_screen := 2
      max_date1 := max_date2 := mn_data
      d12 := mn_data - 1
      k := 0
      if metap == 2
        do while ++d12 <= mk_data
          if is_work_day(d12)
            if ++k == 20
              exit
            endif
          endif
        enddo
      endif
      fl := .t.
      is_otkaz := .f.
      is_neonat := .f.
      ar := np_arr_1_etap[mperiod]
      for i := 1 to count_pn_arr_iss
        mvart := 'MTAB_NOMiv' + lstr(i)
        mvara := 'MTAB_NOMia' + lstr(i)
        mvard := 'MDATEi' + lstr(i)
        mvarr := 'MREZi' + lstr(i)
        _fl_ := not_audio_s := .t.
        if _fl_ .and. !empty(np_arr_issled[i, 2])
          _fl_ := (mpol == np_arr_issled[i, 2])
        endif
        if _fl_
          _fl_ := (ascan(ar[5], np_arr_issled[i, 1]) > 0)
        endif
        if np_arr_issled[i, 1] == '3.5.4' .and. is_3_5_4 // �㤨�-�ਭ��� 㦥 ��
          not_audio_s := .f.
        endif
        if _fl_ .and. not_audio_s /*.and. np_arr_issled[i, 4] == 0 // �� ��ମ�*/
          m1var := 'm1lis' + lstr(i)
          if !is_disp_19 .and. glob_yes_kdp2[TIP_LU_PN] .and. &m1var > 0
            &mvart := -1
          endif
          if empty(&mvard)
            fl := func_error(4, '�� ������� ��� ���-�� "' + np_arr_issled[i, 3] + '"')
          elseif metap == 2 .and. &mvard > d12
            fl := func_error(4, '��� ���-�� "' + np_arr_issled[i, 3] + '" �� � I-�� �⠯� (> 20 ����)')
          elseif empty(&mvart)
            fl := func_error(4, '�� ������ ��� � ���-�� "' + np_arr_issled[i, 3] + '"')
          endif
        endif
        if _fl_ .and. !emptyany(&mvard, &mvart)
          if &mvart > 0
            select P2
            find (str(&mvart, 5))
            if found()
              arr_iss[i, 1] := p2->kod
              arr_iss[i, 2] := -ret_new_spec(p2->prvs, p2->prvs_new)
            endif
            if !empty(&mvara)
              select P2
              find (str(&mvara, 5))
              if found()
                arr_iss[i, 3] := p2->kod
              endif
            endif
          else
            arr_iss[i, 2] := -ret_new_spec(np_arr_issled[i, 6, 1])
            arr_iss[i, 10] := &m1var // �஢� �஢����� � ���2 ��� � ���
          endif
          if valtype(np_arr_issled[i, 5]) == 'N'
            arr_iss[i, 4] := np_arr_issled[i, 5] // ��䨫�
          elseif (j := ascan(np_arr_issled[i, 6], ret_old_prvs(arr_iss[i, 2]))) > 0
            arr_iss[i, 4] := np_arr_issled[i, 5, j] // ��䨫�
          endif
          arr_iss[i, 5] := np_arr_issled[i, 1] // ��� ��㣨
          arr_iss[i, 6] := mdef_diagnoz
          arr_iss[i, 9] := &mvard
          //
          m1var := 'M1OTKAZi' + lstr(i)
          if &m1var == 1 .and. !between(arr_iss[i, 9], mn_data, mk_data) // �᫨ �⪠� � �� � ���������
            &m1var := 0
          endif
          if &m1var == 1
            arr_iss[i, 10] := 9 // �⪠� �� ��㣨
            is_otkaz := .t.
          elseif left(arr_iss[i, 5], 5) == '4.26.'
            is_neonat := .t.
          endif
          max_date1 := max(max_date1, arr_iss[i, 9])
        endif
        if !fl
          exit
        endif
      next
      if !fl
        loop
      endif
      fl := .t.
      arr_osm1 := array(count_pn_arr_osm, 10)
      afillall(arr_osm1, 0)
      for i := 1 to count_pn_arr_osm
        _fl_ := .t.
        if _fl_ .and. !empty(np_arr_osmotr[i, 2])
          _fl_ := (mpol == np_arr_osmotr[i, 2])
        endif
        if _fl_
          _fl_ := (!empty(ar[4]) .and. ascan(ar[4], np_arr_osmotr[i, 1]) > 0)
        endif
        if _fl_ .and. mperiod == 16 .and. mk_data < 0d20191101 .and. np_arr_osmotr[i, 1] == '2.4.2' // 2 ����
          _fl_ := .f.
        endif
        if _fl_ .and. mperiod == 20 .and. mk_data < 0d20191101 .and. np_arr_osmotr[i, 1] == '2.85.24' // 6 ���
          _fl_ := .f.
        endif
        if _fl_
          mvart := 'MTAB_NOMov' + lstr(i)
          mvara := 'MTAB_NOMoa' + lstr(i)
          mvard := 'MDATEo' + lstr(i)
          mvarz := 'MKOD_DIAGo' + lstr(i)
          if empty(&mvard)
            fl := func_error(4, '�� ������� ��� �ᬮ�� I �⠯� "' + np_arr_osmotr[i, 3] + '"')
          elseif metap == 2 .and. &mvard > d12
            fl := func_error(4, '��� �ᬮ�� "' + np_arr_osmotr[i, 3] + '" �� � I-�� �⠯� (> 20 ����)')
          elseif empty(&mvart)
            fl := func_error(4, '�� ������ ��� � �ᬮ�� I �⠯� "' + np_arr_osmotr[i, 3] + '"')
          else
            select P2
            find (str(&mvart, 5))
            if found()
              arr_osm1[i, 1] := p2->kod
              arr_osm1[i, 2] := -ret_new_spec(p2->prvs, p2->prvs_new)
            endif
            if !empty(&mvara)
              select P2
              find (str(&mvara, 5))
              if found()
                arr_osm1[i, 3] := p2->kod
              endif
            endif
            if valtype(np_arr_osmotr[i, 4]) == 'N'
              arr_osm1[i, 4] := np_arr_osmotr[i, 4] // ��䨫�
            elseif (j := ascan(np_arr_osmotr[i, 5], ret_old_prvs(arr_osm1[i, 2]))) > 0
              arr_osm1[i, 4] := np_arr_osmotr[i, 4,j] // ��䨫�
            endif
            arr_osm1[i, 5] := np_arr_osmotr[i, 1] // ��� ��㣨
            if empty(&mvarz) .or. left(&mvarz, 1) == 'Z'
              arr_osm1[i, 6] := mdef_diagnoz
            else
              arr_osm1[i, 6] := &mvarz
              select MKB_10
              find (padr(arr_osm1[i, 6], 6))
              if found() .and. !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
                fl := func_error(4, '��ᮢ���⨬���� �������� �� ���� ' + arr_osm1[i, 6])
              endif
            endif
            arr_osm1[i, 9] := &mvard
            m1var := 'M1OTKAZo' + lstr(i)
            if &m1var == 1 .and. !between(arr_osm1[i, 9], mn_data, mk_data) // �᫨ �⪠� � �� � ���������
              &m1var := 0
            endif
            if &m1var == 1
              arr_osm1[i, 10] := 9 // �⪠� �� �ᬮ��
              is_otkaz := .t.
            endif
            max_date1 := max(max_date1, arr_osm1[i, 9])
          endif
        endif
        if !fl
          exit
        endif
      next
      if !fl
        loop
      endif
      if emptyany(MTAB_NOMpv1, MDATEp1)
        fl := func_error(4, '�� ����� ������� (��� ��饩 �ࠪ⨪�) � �ᬮ��� I �⠯�')
      elseif MDATEp1 < max_date1
        fl := func_error(4, '������� (��� ��饩 �ࠪ⨪�) �� I �⠯� ������ �஢����� �ᬮ�� ��᫥����!')
      elseif metap == 2 .and. MDATEp1 > d12
        fl := func_error(4, '��� �ᬮ�� ������� I �⠯� �� 㬥頥��� � 20 ࠡ��� ����')
      endif
      if !fl
        loop
      endif
      m1p_otk := 0
      metap := 1
      arr_osm2 := array(count_pn_arr_osm, 10)
      afillall(arr_osm2, 0)
      if m1step2 == 2 // ���ࠢ��� �� 2-�� �⠯, �� �⪠�����
        m1p_otk := 1   // �ਧ��� �⪠��
      elseif m1step2 == 1 // ���ࠢ��� �� 2-�� �⠯
        num_screen := 3
        fl := .t.
        if !emptyany(MTAB_NOMpv2, MDATEp2)
          metap := 2
        endif
        ku := 0
        for i := 1 to count_pn_arr_osm
          _fl_ := .t.
          if _fl_ .and. !empty(np_arr_osmotr[i, 2])
            _fl_ := (mpol == np_arr_osmotr[i, 2])
          endif
          if _fl_
            _fl_ := (ascan(ar[4], np_arr_osmotr[i, 1]) == 0)
          endif
          if _fl_
            mvonk := 'm1onko' + lstr(i)
            mvart := 'MTAB_NOMov' + lstr(i)
            mvara := 'MTAB_NOMoa' + lstr(i)
            mvard := 'MDATEo' + lstr(i)
            mvarz := 'MKOD_DIAGo' + lstr(i)
            if eq_any(i, 8, 10) .and. &mvonk == 3
              &mvart := -1
            endif
            if !empty(&mvard) .and. empty(&mvart)
              fl := func_error(4, '�� ������ ��� � �ᬮ�� II �⠯� "' + np_arr_osmotr[i, 3] + '"')
            elseif !empty(&mvart) .and. empty(&mvard)
              fl := func_error(4, '�� ������� ��� �ᬮ�� II �⠯� "' + np_arr_osmotr[i, 3] + '"')
            elseif !emptyany(&mvard, &mvart)
              ++ku
              metap := 2
              if &mvard < MDATEp1
                fl := func_error(4, '��� �ᬮ�� II �⠯� "' + np_arr_osmotr[i, 3] + '" ����� I �⠯�')
              endif
              if &mvart > 0
                select P2
                find (str(&mvart, 5))
                if found()
                  arr_osm2[i, 1] := p2->kod
                  arr_osm2[i, 2] := -ret_new_spec(p2->prvs, p2->prvs_new)
                endif
                if !empty(&mvara)
                  select P2
                  find (str(&mvara, 5))
                  if found()
                    arr_osm2[i, 3] := p2->kod
                  endif
                endif
              else // ��� � ������ᯠ���
                arr_osm2[i, 2] := -ret_new_spec(np_arr_osmotr[i, 5, 1])
                arr_osm2[i, 10] := 3
              endif
              if valtype(np_arr_osmotr[i, 4]) == 'N'
                arr_osm2[i, 4] := np_arr_osmotr[i, 4] // ��䨫�
              elseif (j := ascan(np_arr_osmotr[i, 5], ret_old_prvs(arr_osm2[i, 2]))) > 0
                arr_osm2[i, 4] := np_arr_osmotr[i, 4, j] // ��䨫�
              endif
              arr_osm2[i, 5] := np_arr_osmotr[i, 1] // ��� ��㣨
              if empty(&mvarz) .or. left(&mvarz, 1) == 'Z'
                arr_osm2[i, 6] := mdef_diagnoz
              else
                arr_osm2[i, 6] := &mvarz
                select MKB_10
                find (padr(arr_osm2[i, 6], 6))
                if found() .and. !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
                  fl := func_error(4, '��ᮢ���⨬���� �������� �� ���� ' + arr_osm2[i, 6])
                endif
              endif
              m1var := 'M1OTKAZo' + lstr(i)
              if &m1var == 1
                arr_osm2[i, 10] := 9 // �⪠� �� �ᬮ��
              endif
              arr_osm2[i, 9] := &mvard
              max_date2 := max(max_date2, arr_osm2[i, 9])
            endif
          endif
          if !fl
            exit
          endif
        next
        if fl .and. metap == 2
          if emptyany(MTAB_NOMpv2, MDATEp2)
            fl := func_error(4, '�� ����� ������� (��� ��饩 �ࠪ⨪�) � �ᬮ��� II �⠯�')
          elseif MDATEp1 == MDATEp2
            fl := func_error(4, '�������� �� I � II �⠯�� �஢��� �ᬮ��� � ���� ����!')
          elseif MDATEp2 < max_date2
            fl := func_error(4, '������� (��� ��饩 �ࠪ⨪�) �� II �⠯� ������ �஢����� �ᬮ�� ��᫥����!')
          elseif empty(ku)
            fl := func_error(4, '�� II �⠯� �஬� �ᬮ�� ������� ������ ���� ��� �����-����� �ᬮ��.')
          endif
        endif
        if !fl
          loop
        endif
      endif
      num_screen := 4
      if !between(mGRUPPA_DO, 1, 5)
        func_error(4, '������ ���ﭨ� �������� �� �஢������ ���ᬮ�� �.�. �� 1 �� 5')
        loop
      endif
      num_screen := 5
      arr_diag := {}
      for i := 1 to 5
        mvar := 'mdiag_16_' + lstr(i) + '_1'
        if !empty(&mvar)
          if left(&mvar, 1) == 'Z'
            fl := func_error(4, '������� ' + rtrim(&mvar) + '(���� ᨬ��� "Z") �� ��������. �� �� �����������!')
            exit
          endif
          pole_1pervich := 'm1diag_16_' + lstr(i) + '_2' // 0, 1
          pole_1dispans := 'm1diag_16_' + lstr(i) + '_3' // mm_dispans := {{'࠭��', 1}, {'�����', 2}, {'�� ���.', 0}}
          aadd(arr_diag, {&mvar, &pole_1pervich, &pole_1dispans})
        endif
      next
      if !fl
        loop
      endif
      afill(adiag_talon, 0)
      if empty(arr_diag) // �������� �� �������
        aadd(arr_diag, {1, mdef_diagnoz, 0, 0}) // ������� �� 㬮�砭��
        MKOD_DIAG := mdef_diagnoz
      else
        for i := 1 to len(arr_diag)
          if arr_diag[i, 2] == 0 // '࠭�� �����'
            arr_diag[i, 2] := 2  // �����塞, ��� � ���� ���� ���
          endif
        next
        for i := 1 to len(arr_diag)
          adiag_talon[i * 2 - 1] := arr_diag[i, 2]
          adiag_talon[i * 2] := arr_diag[i, 3]
          if i == 1
            MKOD_DIAG := arr_diag[i, 1]
          elseif i == 2
            MKOD_DIAG2 := arr_diag[i, 1]
          elseif i == 3
            MKOD_DIAG3 := arr_diag[i, 1]
          elseif i == 4
            MKOD_DIAG4 := arr_diag[i, 1]
          elseif i == 5
            MSOPUT_B1 := arr_diag[i, 1]
          endif
          select MKB_10
          find (padr(arr_diag[i, 1], 6))
          if found()
            if !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
              fl := func_error(4, '��ᮢ���⨬���� �������� �� ���� ' + alltrim(arr_diag[i, 1]))
            endif
          else
            fl := func_error(4, '�� ������ ������� ' + alltrim(arr_diag[i, 1]) + ' � �ࠢ�筨�� ���-10')
          endif
          if !fl
            exit
          endif
        next
        if !fl
          loop
        endif
      endif
      if m1invalid1 == 1 .and. !empty(minvalid3) .and. minvalid3 < mdate_r
        func_error(4, '��� ��⠭������� ����������� ����� ���� ஦�����')
        loop
      endif
      if between(mGRUPPA, 1, 5)
        m1rslt := L_BEGIN_RSLT + mGRUPPA
      else
        func_error(4, '������ ���ﭨ� �������� �� १���⠬ �஢������ ���ᬮ�� - �� 1 �� 5')
        loop
      endif
      //
      err_date_diap(mn_data, '��� ��砫� ��祭��')
      err_date_diap(mk_data, '��� ����砭�� ��祭��')
      //
      restscreen(buf)
      if mem_op_out == 2 .and. yes_parol
        box_shadow(19, 10, 22, 69, cColorStMsg)
        str_center(20, '������ "' + fio_polzovat + '".', cColorSt2Msg)
        str_center(21, '���� ������ �� ' + date_month(sys_date), cColorStMsg)
      endif
      mywait('����. �ந�������� ������ ���� ����...')
      m1lis := 0
      arr_lis2 := {}
      arr_usl_dop := {}
      arr_usl_otkaz := {}
      if !is_disp_19 .and. glob_yes_kdp2[TIP_LU_PN]
        for i := 1 to count_pn_arr_iss
          if valtype(arr_iss[i, 9]) == 'D' .and. arr_iss[i, 9] >= mn_data .and. len(arr_iss[i]) > 9 ;
                                          .and. valtype(arr_iss[i, 10]) == 'N' .and. eq_any(arr_iss[i, 10], 1, 2)
            m1lis := arr_iss[i, 10] // � ࠬ��� ��ᯠ��ਧ�樨
          endif
        next
      endif
      // ������� ������� I �⠯�
      aadd(arr_osm1, add_pediatr_PN(MTAB_NOMpv1, MTAB_NOMpa1, MDATEp1, MKOD_DIAGp1))
      if metap == 1 // I �⠯
        for i := 1 to len(arr_iss)
          if valtype(arr_iss[i, 5]) == 'C'
            if arr_iss[i, 10] == 9 // �⪠�
              arr_iss[i, 10] := 'i'
              aadd(arr_usl_otkaz, arr_iss[i])
            else
              aadd(arr_usl_dop, arr_iss[i])
              if is_otkaz .and. ; // � ��砥 �뫨 �⪠��
                    arr_iss[i, 10] == 0 .and. ; // ��㣠 �� � ���2
                       between(arr_iss[i, 9], mn_data, mk_data) .and. ; // 㬥頥��� � ��ਮ�
                                       (j := ascan(np_arr_not_zs, {|x| x[1] == arr_iss[i, 5]})) > 0
                arr := aclone(arr_iss[i])  // �������
                arr[5] := np_arr_not_zs[j, 2] // ��� ��᫥�������
                aadd(arr_usl_dop, arr)          // � 業��
              endif
            endif
          endif
        next
        for i := 1 to len(arr_osm1)
          if valtype(arr_osm1[i, 5]) == 'C'
            if arr_osm1[i, 10] == 9 // �⪠�
              arr_osm1[i, 10] := 'o'
              aadd(arr_usl_otkaz, arr_osm1[i])
            else
              lshifr := alltrim(arr_osm1[i, 5])
              if (j := ascan(np_arr_osmotr_KDP2, {|x| x[1] == lshifr})) > 0
                arr_osm1[i, 5] := np_arr_osmotr_KDP2[j, 3]  // ������ �� 2.3.*
              endif
              aadd(arr_usl_dop, arr_osm1[i])
              if is_otkaz .and.;// � ��砥 �뫨 �⪠��
                       between(arr_osm1[i, 9], mn_data, mk_data) ; // � 㬥頥��� � ��ਮ�
                                                      .and. j > 0  // � ������� ᮮ⢥��⢨�
                arr := aclone(arr_osm1[i])       // �������
                arr[5] := np_arr_osmotr_KDP2[j, 4]  // ������ �� 2.91.*
                aadd(arr_usl_dop, arr)             // � 業��
              endif
            endif
          endif
        next
        i := len(arr_osm1)
        m1vrach  := arr_osm1[i, 1]
        m1prvs   := arr_osm1[i, 2]
        m1assis  := arr_osm1[i, 3]
        m1PROFIL := arr_osm1[i, 4]
        //MKOD_DIAG := padr(arr_osm1[i, 6], 6)
        if !is_otkaz // ������塞 ��� ��
          aadd(arr_usl_dop, array(10))
          j := len(arr_usl_dop)
          arr_usl_dop[j, 1] := m1vrach
          arr_usl_dop[j, 2] := m1prvs
          arr_usl_dop[j, 3] := m1assis
          arr_usl_dop[j, 4] := 151 // ��� ���� �� - ���.�ᬮ�ࠬ ��䨫����᪨�
          arr_usl_dop[j, 5] := ret_shifr_zs_PN(mperiod)
          arr_usl_dop[j, 6] := MKOD_DIAG
          arr_usl_dop[j, 9] := mn_data
        endif
      else  // ��ଫ���� 2-�� �⠯� ��-������
        use (cur_dir + 'tmp') new
        go top
        do while !eof()
          if is_lab_usluga(tmp->u_shifr)
            aadd(arr_lis2, {tmp->u_kod, tmp->u_shifr})
          endif
          skip
        enddo
        use
        for i := 1 to len(arr_iss)
          if valtype(arr_iss[i, 5]) == 'C'
            if arr_iss[i, 10] == 9 // �⪠�
              arr_iss[i, 10] := 'i'
              aadd(arr_usl_otkaz, arr_iss[i])
            else
              aadd(arr_usl_dop, arr_iss[i])
              if arr_iss[i, 10] == 0 ; // �஢� �஢����� � ��� � ��
                          .and. between(arr_iss[i, 9], mn_data, mk_data) .and. ; // � � �ப� ���ᬮ��
                                       (j := ascan(np_arr_not_zs, {|x| x[1] == arr_iss[i, 5]})) > 0
                arr := aclone(arr_iss[i])  // �������
                arr[5] := np_arr_not_zs[j, 2] // ��� ��᫥�������
                aadd(arr_usl_dop, arr)          // � 業��
              endif
            endif
          endif
        next
        for i := 1 to len(arr_osm1)
          if valtype(arr_osm1[i, 5]) == 'C'
            lshifr := alltrim(arr_osm1[i, 5])
            if arr_osm1[i, 10] == 9 // �⪠� �� �ᬮ��
              arr_osm1[i, 10] := 'o'
              aadd(arr_usl_otkaz, arr_osm1[i])
            else
              lshifr := alltrim(arr_osm1[i, 5])
              if (j := ascan(np_arr_osmotr_KDP2, {|x| x[1] == lshifr})) > 0
                arr_osm1[i, 5] := np_arr_osmotr_KDP2[j, 3]  // ������ �� 2.3.*
              endif
              aadd(arr_usl_dop, arr_osm1[i])
              if between(arr_osm1[i, 9], mn_data, mk_data) ; // � 㬥頥��� � ��ਮ�
                                                      .and. j > 0  // � ������� ᮮ⢥��⢨�
                arr := aclone(arr_osm1[i])       // �������
                arr[5] := np_arr_osmotr_KDP2[j, 4]  // ������ �� 2.91.*
                aadd(arr_usl_dop, arr)             // � 業��
              endif
            endif
          endif
        next
        // ������� ������� II �⠯�
        aadd(arr_osm2, add_pediatr_PN(MTAB_NOMpv2, MTAB_NOMpa2, MDATEp2, MKOD_DIAGp2))
        i := len(arr_osm2)
        m1vrach  := arr_osm2[i, 1]
        m1prvs   := arr_osm2[i, 2]
        m1assis  := arr_osm2[i, 3]
        m1PROFIL := arr_osm2[i, 4]
        //MKOD_DIAG := padr(arr_osm2[i, 6], 6)
        for i := 1 to len(arr_osm2)
          if valtype(arr_osm2[i, 5]) == 'C'
            lshifr := alltrim(arr_osm2[i, 5])
            if arr_osm2[i, 10] == 9 // �⪠� �� �ᬮ��
              arr_osm2[i, 10] := 'o'
              aadd(arr_usl_otkaz, arr_osm2[i])
            else
              if arr_osm2[i, 10] == 3 // �᫨ ��㣠 ������� � �����
                arr_osm2[i, 5] := '2.3.1'
              endif
              if !empty(arr_lis2) .and. (j := ascan(np_arr_osmotr_KDP2, {|x| x[1] == lshifr})) > 0
                arr_osm2[i, 5] := np_arr_osmotr_KDP2[j, 2] // ��㣨 ������� �� ��������� ���� ��� ����⮫����
              endif
              aadd(arr_usl_dop, arr_osm2[i])
            endif
          endif
        next
        if !empty(arr_lis2) // �� 2-�� �⠯� �뫨 ���ࠢ����� �� ������� � ���2
          if (mdate := max_date1 + 1) > max_date2 // ᫥���騩 ���� ��᫥ ������� 1-�� �⠯�
            mdate := max_date2 // �᫨ �⮣� �����, � ����砭�� 2-�� �⠯�
          endif
          for j := 1 to len(arr_lis2)
            aadd(arr_usl_dop, array(10))
            i := len(arr_usl_dop)
            afill(arr_usl_dop[i], 0)
            arr_usl_dop[i, 4] := iif(left(arr_lis2[j, 2], 5) == '4.16.', 6, 34) // ��䨫�
            arr_usl_dop[i, 5] := arr_lis2[j, 2] // ��� ��㣨
            arr_usl_dop[i, 6] := mkod_diag
            arr_usl_dop[i, 7] := arr_lis2[j, 1] // ��� ��㣨
            arr_usl_dop[i, 9] := mdate
            arr_usl_dop[i, 10] := -1 // �.�. ���ਠ� ��ࠢ��� �� ������ � ���2
          next
        endif
      endif
      make_diagP(2)  // ᤥ���� '��⨧����' ��������
      //
      Use_base('lusl')
      Use_base('luslc')
      Use_base('uslugi')
      R_Use(dir_server + 'uslugi1', {dir_server + 'uslugi1', ;
                                  dir_server + 'uslugi1s'}, 'USL1')
      Private mu_cena
      mcena_1 := 0
      glob_podr := ''
      glob_otd_dep := 0
      for i := 1 to len(arr_usl_dop)
        if empty(arr_usl_dop[i, 7]) // �.�. ��� ���, ���ࠢ�塞�� � ���2, ��� 㦥 �����⥭ (� 業� =0)
          arr_usl_dop[i, 7] := foundOurUsluga(arr_usl_dop[i, 5], mk_data, arr_usl_dop[i, 4], M1VZROS_REB, @mu_cena)
          arr_usl_dop[i, 8] := mu_cena
          mcena_1 += mu_cena
        endif
      next
      //
      Use_base('human')
      if Loc_kod > 0
        find (str(Loc_kod, 7))
        mkod := Loc_kod
        G_RLock(forever)
      else
        Add1Rec(7)
        mkod := recno()
        replace human->kod with mkod
      endif
      select HUMAN_
      do while human_->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      //
      select HUMAN_2
      do while human_2->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      //
      st_N_DATA := MN_DATA
      st_K_DATA := MK_DATA
      st_mo_pr := m1mo_pr
      glob_perso := mkod
      if m1komu == 0
        msmo := lstr(m1company)
        m1str_crb := 0
      else
        msmo := ''
        m1str_crb := m1company
      endif
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
      human->POLIS      := make_polis(mspolis, mnpolis) // ��� � ����� ���客��� �����
      human->LPU        := M1LPU         // ��� ��०�����
      human->OTD        := M1OTD         // ��� �⤥�����
      human->UCH_DOC    := MUCH_DOC      // ��� � ����� ��⭮�� ���㬥��
      human->N_DATA     := MN_DATA       // ��� ��砫� ��祭��
      human->K_DATA     := MK_DATA       // ��� ����砭�� ��祭��
      human->CENA := human->CENA_1 := MCENA_1 // �⮨����� ��祭��
      human->ishod      := 300 + metap
      human->OBRASHEN   := iif(m1DS_ONK == 1, '1', ' ')
      human->bolnich    := 0
      human->date_b_1   := ''
      human->date_b_2   := ''
      human_->RODIT_DR  := ctod('')
      human_->RODIT_POL := ''
      s := '' ; aeval(adiag_talon, {|x| s += str(x, 1) })
      human_->DISPANS   := s
      human_->STATUS_ST := ''
      human_->POVOD     := m1povod
      human_->POVOD     := 5 // {'2.1-����樭᪨� �ᬮ��', 5,'2.1'}, ;
      //human_->TRAVMA    := m1travma
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := ltrim(mspolis)
      human_->NPOLIS    := ltrim(mnpolis)
      human_->OKATO     := '' // �� ���� ������� �� ����� � ��砥 �����த����
      human_->NOVOR     := 0
      human_->DATE_R2   := ctod('')
      human_->POL2      := ''
      human_->USL_OK    := m1USL_OK
      human_->VIDPOM    := m1VIDPOM
      human_->PROFIL    := m1PROFIL
      human_->IDSP      := iif(metap == 1, 17, 1)
      human_->NPR_MO    := ''
      human_->FORMA14   := '0000'
      human_->KOD_DIAG0 := ''
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // 㡥�� '2', �᫨ ��।���஢��� ������ �� ॥��� �� � ��
      human_->ST_VERIFY := 0 // ᭮�� ��� �� �஢�७
      if Loc_kod == 0  // �� ����������
        human_->ID_PAC    := mo_guid(1, human_->(recno()))
        human_->ID_C      := mo_guid(2, human_->(recno()))
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
      else // �� ।���஢�����
        human_->kod_p2  := kod_polzovat    // ��� ������
        human_->date_e2 := c4sys_date
      endif
      put_0_human_2()
      Private fl_nameismo := .f.
      if m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ����� ��ꥪ� �� ����ਨ ���客����
        if empty(m1ismo)
          if !empty(mnameismo)
            fl_nameismo := .t.
          endif
        else
          human_->SMO := m1ismo  // �����塞 '34' �� ��� �����த��� ���
        endif
      endif
      if fl_nameismo .or. rec_inogSMO > 0
        G_Use(dir_server + 'mo_hismo', , 'SN')
        index on str(kod, 7) to (cur_dir + 'tmp_ismo')
        find (str(mkod, 7))
        if found()
          if fl_nameismo
            G_RLock(forever)
            sn->smo_name := mnameismo
          else
            DeleteRec(.t.)
          endif
        else
          if fl_nameismo
            AddRec(7)
            sn->kod := mkod
            sn->smo_name := mnameismo
          endif
        endif
      endif
      i1 := len(arr_usl)
      i2 := len(arr_usl_dop)
      Use_base('human_u')
      for i := 1 to i2
        select HU
        if i > i1
          Add1Rec(7)
          hu->kod := human->kod
        else
          goto (arr_usl[i])
          G_RLock(forever)
        endif
        mrec_hu := hu->(recno())
        hu->kod_vr  := arr_usl_dop[i, 1]
        hu->kod_as  := arr_usl_dop[i, 3]
        hu->u_koef  := 1
        hu->u_kod   := arr_usl_dop[i, 7]
        hu->u_cena  := arr_usl_dop[i, 8]
        hu->is_edit := iif(len(arr_usl_dop[i]) > 9 .and. valtype(arr_usl_dop[i, 10]) == 'N', arr_usl_dop[i, 10], 0)
        hu->date_u  := dtoc4(arr_usl_dop[i, 9])
        hu->otd     := m1otd
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := arr_usl_dop[i, 8]
        select HU_
        do while hu_->(lastrec()) < mrec_hu
          APPEND BLANK
        enddo
        goto (mrec_hu)
        G_RLock(forever)
        if i > i1 .or. !valid_GUID(hu_->ID_U)
          hu_->ID_U := mo_guid(3, hu_->(recno()))
        endif
        hu_->PROFIL := arr_usl_dop[i, 4]
        hu_->PRVS   := arr_usl_dop[i, 2]
        hu_->kod_diag := iif(empty(arr_usl_dop[i, 6]), MKOD_DIAG, arr_usl_dop[i, 6])
        hu_->zf := ''
        UNLOCK
      next
      if i2 < i1
        for i := i2 + 1 to i1
          select HU
          goto (arr_usl[i])
          DeleteRec(.t., .f.)  // ���⪠ ����� ��� ����⪨ �� 㤠�����
        next
      endif
      save_arr_PN(mkod)

      // ���ࠢ����� �� �����७�� �� ���
      // cur_napr := 0
      // arr := {}
      // G_Use(dir_server + 'mo_onkna', dir_server + 'mo_onkna', 'NAPR') // �������ࠢ�����
      // find (str(mkod, 7))
      // do while napr->kod == mkod .and. !eof()
      //   aadd(arr,recno())
      //   skip
      // enddo
      if m1step2 == 2 ; // ���ࠢ��� � �⪠����� �� 2-�� �⠯�
               .and. m1ds_onk == 1 // �����७�� �� �������⢥���� ������ࠧ������
        save_mo_onkna(mkod)               
        
        // Use_base('mo_su')
        // use (cur_dir + 'tmp_onkna') new alias TNAPR
        // select TNAPR
        // go top
        // do while !eof()
        //   if !emptyany(tnapr->NAPR_DATE, tnapr->NAPR_V)
        //     if tnapr->U_KOD == 0 // ������塞 � ᢮� �ࠢ�筨� 䥤�ࠫ��� ����
        //       select MOSU
        //       set order to 3
        //       find (tnapr->shifr1)
        //       if found()  // ����୮�, �������� ⮫쪮 ��
        //         tnapr->U_KOD := mosu->kod
        //       else
        //         set order to 1
        //         FIND (STR(-1, 6))
        //         if found()
        //           G_RLock(forever)
        //         else
        //           AddRec(6)
        //         endif
        //         tnapr->U_KOD := mosu->kod := recno()
        //         mosu->name   := tnapr->name_u
        //         mosu->shifr1 := tnapr->shifr1
        //       endif
        //     endif
        //     select NAPR
        //     if ++cur_napr > len(arr)
        //       AddRec(7)
        //       napr->kod := mkod
        //     else
        //       goto (arr[cur_napr])
        //       G_RLock(forever)
        //     endif
        //     napr->NAPR_DATE := tnapr->NAPR_DATE
        //     napr->KOD_VR := tnapr->KOD_VR
        //     napr->NAPR_MO := tnapr->NAPR_MO
        //     napr->NAPR_V := tnapr->NAPR_V
        //     napr->MET_ISSL := iif(tnapr->NAPR_V == 3, tnapr->MET_ISSL, 0)
        //     napr->U_KOD := iif(tnapr->NAPR_V == 3, tnapr->U_KOD, 0)
        //   endif
        //   select TNAPR
        //   skip
        // enddo
      endif
      // select NAPR
      // do while ++cur_napr <= len(arr)
      //   goto (arr[cur_napr])
      //   DeleteRec(.t.)
      // enddo
      write_work_oper(glob_task, OPER_LIST, iif(Loc_kod == 0, 1, 2), 1, count_edit)
      fl_write_sluch := .t.
      close databases
      stat_msg('������ �����襭�!', .f.)
    endif
    exit
  enddo
  close databases
  setcolor(tmp_color)
  restscreen(buf)
  chm_help_code := tmp_help
  if fl_write_sluch // �᫨ ����ᠫ� - ����᪠�� �஢���
    if type('fl_edit_DDS') == 'L'
      fl_edit_DDS := .t.
    endif
    if !empty(val(msmo))
      verify_OMS_sluch(glob_perso)
    endif
  endif
  return NIL