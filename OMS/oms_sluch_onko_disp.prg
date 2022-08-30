#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** 30.08.22 ���������� ��� ।���஢���� ���� (���� ���)
function oms_sluch_ONKO_DISP(Loc_kod, kod_kartotek)
  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  static SKOD_DIAG := '     ', st_l_z := 1, st_N_DATA, st_K_DATA, ;
    st_vrach := 0, st_profil := 0, st_profil_k := 0, st_rslt := 0, st_ishod := 0, st_povod := 9

  local bg := {|o,k| get_MKB10(o, k, .t.) }, ;
    buf, tmp_color := setcolor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', ;
    i, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    fl_write_sluch := .f., when_uch_doc := .t.
  local mm_da_net := {{'���', 0}, {'�� ', 1}}

  Default st_N_DATA TO sys_date, st_K_DATA TO sys_date
  Default Loc_kod TO 0, kod_kartotek TO 0
  if kod_kartotek == 0 // ���������� � ����⥪�
    if (kod_kartotek := edit_kartotek(0, , ,.t.)) == 0
      return NIL
    endif
  endif
  buf := savescreen()
  if is_uchastok == 1 .and. is_task(X_REGIST) // �23/12356 � ���� '����������'
    when_uch_doc := (mem_edit_ist == 2)
  endif
  //
  //
  Private tmp_V006 := create_classif_FFOMS(2, 'V006') // USL_OK
  Private tmp_V002 := create_classif_FFOMS(2, 'V002') // PROFIL
  Private tmp_V020 := create_classif_FFOMS(2, 'V020') // PROFIL_K
  Private tmp_V009 := cut_glob_array(glob_V009,sys_date) // rslt
  Private tmp_V012 := cut_glob_array(glob_V012,sys_date) // ishod

  Private mm_rslt, mm_ishod, rslt_umolch := 0, ishod_umolch := 0
  //
  Private mkod := Loc_kod, mtip_h, is_talon := .f., ;
    mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0), ;
    M1LPU := glob_uch[1], MLPU, ;
    M1OTD := glob_otd[1], MOTD, ;
    mfio := space(50),  mpol, mdate_r, madres, mmr_dol, ;
    M1FIO_KART := 1, MFIO_KART, ;
    M1VZROS_REB, MVZROS_REB, mpolis, M1RAB_NERAB, ;
    MUCH_DOC    := space(10)         , ; // ��� � ����� ��⭮�� ���㬥��
    MKOD_DIAG0  := space(6)          , ; // ��� ��ࢨ筮�� ��������
    MKOD_DIAG   := SKOD_DIAG         , ; // ��� 1-�� ��.�������
    MKOD_DIAG2  := space(5)          , ; // ��� 2-�� ��.�������
    MKOD_DIAG3  := space(5)          , ; // ��� 3-�� ��.�������
    MKOD_DIAG4  := space(5)          , ; // ��� 4-�� ��.�������
    MSOPUT_B1   := space(5)          , ; // ��� 1-�� ᮯ������饩 �������
    MSOPUT_B2   := space(5)          , ; // ��� 2-�� ᮯ������饩 �������
    MSOPUT_B3   := space(5)          , ; // ��� 3-�� ᮯ������饩 �������
    MSOPUT_B4   := space(5)          , ; // ��� 4-�� ᮯ������饩 �������
    MDIAG_PLUS  := space(8)          , ; // ���������� � ���������
    adiag_talon[16]                  , ; // �� ���⠫��� � ���������
    mrslt, m1rslt := st_rslt         , ; // १����
    mishod, m1ishod := st_ishod      , ; // ��室
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-���, 1-��������, 3-�������/���, 5-���� ���
    MN_DATA     := st_N_DATA         , ; // ��� ��砫� ��祭��
    MK_DATA     := st_K_DATA         , ; // ��� ����砭�� ��祭��
    MCENA_1     := 0                 , ; // �⮨����� ��祭��
    MVRACH      := space(10)         , ; // 䠬���� � ���樠�� ���饣� ���
    M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
    m1USL_OK := 0, mUSL_OK, ;
    m1P_PER := 0, mP_PER := space(35), ; // �ਧ��� ����㯫����/��ॢ��� 1-4
    m1PROFIL := st_profil, mPROFIL, ;
    m1PROFIL_K := st_profil_k, mPROFIL_K, ;
    mstatus_st := space(10), ;
    mpovod, m1povod := st_povod, ;
    MOSL1 := SPACE(6)     , ; // ��� 1-��� �������� �᫮������ �����������
    MOSL2 := SPACE(6)     , ; // ��� 2-��� �������� �᫮������ �����������
    MOSL3 := SPACE(6)     , ; // ��� 3-��� �������� �᫮������ �����������
    msmo := '',  rec_inogSMO := 0, ;
    mokato, m1okato := '',  mismo, m1ismo := '',  mnameismo := space(100), ;
    mvidpolis, m1vidpolis := 1, mspolis := space(10),  mnpolis := space(20), ;
    m1_l_z := st_l_z, m_l_z             // ��祭�� �����襭� ?


  if mem_zav_l == 1  // ��
    m1_l_z := 1   // ��
  elseif mem_zav_l == 2  // ���
    m1_l_z := 0   // ���
  endif

  Private mdiag_date := ctod('')

  //
  afill(adiag_talon, 0)
  R_Use(dir_server + 'human_2', , 'HUMAN_2')
  R_Use(dir_server + 'human_', , 'HUMAN_')
  R_Use(dir_server + 'human', , 'HUMAN')
  set relation to recno() into HUMAN_, to recno() into HUMAN_2
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
    m1okato     := kart_->KVARTAL_D    // ����� ��ꥪ� �� ����ਨ ���客����
    msmo        := kart_->SMO
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
      mnameismo := ret_inogSMO_name(1, ,.t.) // ������ � �������
    endif
    // �஢�ઠ ��室� = ������
    select HUMAN
    set index to (dir_server + 'humankk')
    find (str(mkod_k, 7))
    do while human->kod_k == mkod_k .and. !eof()
      if recno() != Loc_kod .and. is_death(human_->RSLT_NEW) .and. ;
                                   human_->oplata != 9 .and. human_->NOVOR == 0
        a_smert := {'����� ���쭮� 㬥�!', ;
          '��祭�� � ' +full_date(human->N_DATA)+ ' �� ' +full_date(human->K_DATA)}
        exit
      endif
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
    mstatus_st  := human_->STATUS_ST
    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    if empty(val(msmo := human_->SMO))
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    else
      m1komu := m1str_crb := 0
    endif
    m1okato    := human_->OKATO  // ����� ��ꥪ� �� ����ਨ ���客����
    m1USL_OK   := human_->USL_OK
    m1PROFIL   := human_->PROFIL
    m1PROFIL_K := human_2->PROFIL_K
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    m1povod    := human_->POVOD
    m1rslt     := human_->RSLT_NEW
    m1ishod    := human_->ISHOD_NEW
    mcena_1 := human->CENA_1
    //
    m1P_PER := human_2->P_PER
    MOSL1 := human_2->OSL1
    MOSL2 := human_2->OSL2
    MOSL3 := human_2->OSL3

    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(2,@rec_inogSMO,.t.) // ������ � �������
    endif
    if eq_any(m1usl_ok, 1, 2) .and. is_task(X_PPOKOJ) ;
                            .and. !empty(mUCH_DOC) .and. mem_e_istbol == 1
      R_Use(dir_server + 'mo_pp', dir_server + 'mo_pp_h',  'PP')
      find (str(Loc_kod, 7))
      if found()
        when_uch_doc := .f.  // ����� �������� ����� ���ਨ �������
      endif
    endif
  endif
  if !(left(msmo, 2) == '34') // �� ������ࠤ᪠� �������
    m1ismo := msmo ; msmo := '34'
  endif
  if Loc_kod == 0
    R_Use(dir_server + 'mo_otd', , 'OTD')
    goto (m1otd)
    m1USL_OK := otd->IDUMP
    if empty(m1PROFIL)
      m1PROFIL := otd->PROFIL
    endif
    if empty(m1PROFIL_K)
      m1PROFIL_K := otd->PROFIL_K
    endif
  endif
  R_Use(dir_server + 'mo_uch', , 'UCH')
  goto (m1lpu)
  is_talon := .t.
  mlpu := rtrim(uch->name)
  if m1vrach > 0
    R_Use(dir_server + 'mo_pers', , 'P2')
    goto (m1vrach)
    MTAB_NOM := p2->tab_nom
    m1prvs := -ret_new_spec(p2->prvs,p2->prvs_new)
    mvrach := padr(fam_i_o(p2->fio)+ ' ' +ret_tmp_prvs(m1prvs), 36)
  endif
  close databases
  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  if empty(m1USL_OK) ; m1USL_OK := 1 ; endif // �� ��直� ��砩
  mUSL_OK   := inieditspr(A__MENUVERT, glob_V006, m1USL_OK)
  if eq_any(m1usl_ok, 1, 2)
    if !between(m1p_per, 1, 4)
      m1p_per := 1
    endif
  endif
  mPROFIL   := inieditspr(A__MENUVERT, glob_V002, m1PROFIL)
  mPROFIL_K := inieditspr(A__MENUVERT, getV020(),  m1PROFIL_K)
  mrslt     := inieditspr(A__MENUVERT, glob_V009, m1rslt)
  mishod    := inieditspr(A__MENUVERT, glob_V012, m1ishod)
  mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  motd      := inieditspr(A__POPUPMENU, dir_server + 'mo_otd',  m1otd)
  mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
  mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
  mismo     := init_ismo(m1ismo)
  f_valid_komu(,-1)
  if m1komu == 0
    m1company := int(val(msmo))
  elseif eq_any(m1komu, 1, 3)
    m1company := m1str_crb
  endif
  mcompany  := inieditspr(A__MENUVERT, mm_company, m1company)
  if m1company == 34
    if !empty(mismo)
      mcompany := padr(mismo,38)
    elseif !empty(mnameismo)
      mcompany := padr(mnameismo,38)
    endif
  endif
  str_1 := ' ���� (���� ����)'
  if Loc_kod == 0
    str_1 := '����������' +str_1
    mtip_h := yes_vypisan
  else
    str_1 := '������஢����' +str_1
  endif
  if yes_vypisan == B_END
    if Loc_kod == 0
      mtip_h += m1_l_z
    else
      m1_l_z := mtip_h - B_END
    endif
    m_l_z := inieditspr(A__MENUVERT, mm_danet, m1_l_z)
  endif
  pr_1_str(str_1)
  setcolor(color8)
  myclear(1)

  Private gl_area := {1, 0,maxrow()-1,maxcol(), 0}

  setcolor(cDataCGet)
  make_diagP(1)  // ᤥ���� '��⨧����' ��������
  f_valid_usl_ok(,-1)

  Private rdiag := 1, rpp := 1, num_screen := 1, is_onko_VMP := .f.

  restscreen(buf)

  return nil
