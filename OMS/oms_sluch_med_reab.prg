#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** 17.05.22 ���㫠�ୠ� ����樭᪠� ॠ������� - ���������� ��� ।���஢���� ���� (���� ���)
function oms_sluch_MED_REAB(Loc_kod, kod_kartotek, f_print)
  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  // f_print - ������������ �㭪樨 ��� ����

  Static skod_diag := '     ', st_l_z := 1, st_N_DATA, st_K_DATA, st_rez_gist,;
    st_vrach := 0, st_profil := 0, st_profil_k := 0, st_rslt := 0, st_ishod := 0, st_povod := 9

  local str_1
  local j // ���稪 ��ப �࠭�
  Local bg := {|o, k| get_MKB10(o, k, .t.) }, ;
    buf, tmp_color := setcolor(), a_smert := {},;
    p_uch_doc := '@!', pic_diag := '@K@!', ;
    i, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    fl_write_sluch := .f., when_uch_doc := .t.

  Default st_N_DATA TO sys_date, st_K_DATA TO sys_date
  Default Loc_kod TO 0, kod_kartotek TO 0

  // Private mkod := Loc_kod, mtip_h, ;
  //   m1company := 0, mcompany, mm_company, ;
  //   mkomu, m1komu := 0, m1str_crb := 0, ; // 0-���,1-��������,3-�������/���,5-���� ���
  //   mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20), ;
  //   MN_DATA     := st_N_DATA         ,; // ��� ��砫� ��祭��
  //   MK_DATA     := st_K_DATA         ,; // ��� ����砭�� ��祭��
  //   M1VZROS_REB, MVZROS_REB, mpolis, M1RAB_NERAB, ;


///++++
  buf := savescreen()

  Private tmp_V006 := create_classif_FFOMS(2,'V006') // USL_OK
  Private tmp_V002 := create_classif_FFOMS(2,'V002') // PROFIL
  Private tmp_V020 := create_classif_FFOMS(2,'V020') // PROFIL_K
  Private tmp_V009 := cut_glob_array(glob_V009, sys_date) // rslt
  Private tmp_V012 := cut_glob_array(glob_V012, sys_date) // ishod
  Private mm_rslt, mm_ishod, rslt_umolch := 0, ishod_umolch := 0

  Private mkod := Loc_kod, ;
    mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0), ;
    m1lpu := glob_uch[1], mlpu, ;
    m1otd := glob_otd[1], motd, ;
    mfio := space(50), mpol, mdate_r, madres, mmr_dol, ;
    m1fio_kart := 1, mfio_kart, ;
    m1vzros_reb, mvzros_reb, mpolis, m1rab_nerab, ;
    much_doc    := space(10)         ,; // ��� � ����� ��⭮�� ���㬥��
    m1npr_mo := '', mnpr_mo := space(10), mnpr_date := ctod(''), ;
    mkod_diag   := skod_diag         , ; // ��� 1-�� ��.�������
    adiag_talon[16]                  , ; // �� ���⠫��� � ���������
    mprer_b := space(28), m1prer_b := 0, ; // ���뢠��� ��६������
    mrslt, m1rslt := st_rslt         , ; // १����
    mishod, m1ishod := st_ishod      , ; // ��室
    m1company := 0, mcompany, mm_company, ;
    mkomu, m1komu := 0, m1str_crb := 0, ; // 0-���,1-��������,3-�������/���,5-���� ���
    m1npr_mo := '', mnpro_mo := space(10), mnpr_date := ctod(''), ;
    m1reg_lech := 0, mreg_lech, ;
    mn_data     := st_N_DATA         , ; // ��� ��砫� ��祭��
    mk_data     := st_K_DATA         , ; // ��� ����砭�� ��祭��
    MCENA_1     := 0                 , ; // �⮨����� ��祭��
    MVRACH      := space(10)         , ; // 䠬���� � ���樠�� ���饣� ���
    M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
    m1USL_OK := 0, mUSL_OK, ;
    m1P_PER := 0, mP_PER := space(35), ; // �ਧ��� ����㯫����/��ॢ��� 1-4
    m1PROFIL := st_profil, mPROFIL, ;
    m1PROFIL_K := st_profil_k, mPROFIL_K, ;
    m1vid_reab := 0, mvid_reab, ;
    mstatus_st := space(10), ;
    mpovod, m1povod := st_povod, ;
    mtravma, m1travma := 0, ;
    msmo := '', rec_inogSMO := 0, ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := space(100), ;
    mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20), ;
    m1_l_z := st_l_z, m_l_z             // ��祭�� �����襭� ?

  private ;                   // ��� ᮢ���⨬���
    MKOD_DIAG2  := space(5), ; // ��� 2-�� ��.�������
    MKOD_DIAG3  := space(5), ; // ��� 3-�� ��.�������
    MKOD_DIAG4  := space(5), ; // ��� 4-�� ��.�������
    MSOPUT_B1   := space(5), ; // ��� 1-�� ᮯ������饩 �������
    MSOPUT_B2   := space(5), ; // ��� 2-�� ᮯ������饩 �������
    MSOPUT_B3   := space(5), ; // ��� 3-�� ᮯ������饩 �������
    MSOPUT_B4   := space(5), ; // ��� 4-�� ᮯ������饩 �������
    MDIAG_PLUS  := space(8)    // ���������� � ���������
    // MKOD_DIAG0  := space(6)          , ; // ��� ��ࢨ筮�� ��������
    // MOSL1 := SPACE(6)     , ; // ��� 1-��� �������� �᫮������ �����������
    // MOSL2 := SPACE(6)     , ; // ��� 2-��� �������� �᫮������ �����������
    // MOSL3 := SPACE(6)     , ; // ��� 3-��� �������� �᫮������ �����������

///----    

  ///++++  
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
      much_doc := padr(amb_kartaN(), 10)
    elseif mem_kodkrt == 2
      much_doc := padr(lstr(mkod_k), 10)
    endif
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(1, , .t.) // ������ � �������
    endif

    // �஢�ઠ ��室� = ������
    select HUMAN
    set index to (dir_server + 'humankk')
    find (str(mkod_k, 7))
    do while human->kod_k == mkod_k .and. !eof()
      if recno() != Loc_kod .and. is_death(human_->RSLT_NEW) .and. ;
                                 human_->oplata != 9 .and. human_->NOVOR == 0
        a_smert := {'����� ���쭮� 㬥�!', ;
          '��祭�� � ' + full_date(human->N_DATA) + ' �� ' + full_date(human->K_DATA)}
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
    much_doc    := human->uch_doc
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

    for i := 1 to 16
      adiag_talon[i] := int(val(substr(human_->DISPANS, i, 1)))
    next
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
    m1NPR_MO   := human_->NPR_MO
    mNPR_DATE  := human_2->NPR_DATE
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    m1povod    := human_->POVOD
    m1travma   := human_->TRAVMA
    m1rslt     := human_->RSLT_NEW
    m1ishod    := human_->ISHOD_NEW

    mcena_1 := human->CENA_1
    //
    m1ad_cr := human_2->PC3
    m1P_PER := human_2->P_PER
    MOSL1 := human_2->OSL1
    MOSL2 := human_2->OSL2
    MOSL3 := human_2->OSL3
    m1vid_reab := human_2->PN1

    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(2, @rec_inogSMO, .t.) // ������ � �������
    endif
  endif

  if !(left(msmo, 2) == '34') // �� ������ࠤ᪠� �������
    m1ismo := msmo
    msmo := '34'
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
  mlpu := rtrim(uch->name)

  close databases

  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  if empty(m1USL_OK) ; m1USL_OK := 1 ; endif // �� ��直� ��砩
  mUSL_OK   := inieditspr(A__MENUVERT, glob_V006, m1USL_OK)
  if eq_any(m1usl_ok, 1, 2)
    if !between(m1p_per, 1, 4)
      m1p_per := 1
    endif
    mp_per := inieditspr(A__MENUVERT, mm_p_per, m1p_per)
  endif
  mPROFIL   := inieditspr(A__MENUVERT, glob_V002, m1PROFIL)
  mPROFIL_K := inieditspr(A__MENUVERT, getV020(), m1PROFIL_K)
  mvid_reab := inieditspr(A__MENUVERT, mm_vid_reab, m1vid_reab)
  if !empty(m1NPR_MO)
    mNPR_MO := ret_mo(m1NPR_MO)[_MO_SHORT_NAME]
  endif
  mrslt     := inieditspr(A__MENUVERT, glob_V009, m1rslt)
  mishod    := inieditspr(A__MENUVERT, glob_V012, m1ishod)
  mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  //mpovod    := inieditspr(A__MENUVERT, stm_povod, m1povod)
  //mtravma   := inieditspr(A__MENUVERT, stm_travma, m1travma)
  motd      := inieditspr(A__POPUPMENU, dir_server + 'mo_otd', m1otd)
  mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
  mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
  mismo     := init_ismo(m1ismo)
  f_valid_komu(, -1)
  if m1komu == 0
    m1company := int(val(msmo))
  elseif eq_any(m1komu, 1, 3)
    m1company := m1str_crb
  endif
  mcompany  := inieditspr(A__MENUVERT, mm_company, m1company)
  if m1company == 34
    if !empty(mismo)
      mcompany := padr(mismo, 38)
    elseif !empty(mnameismo)
      mcompany := padr(mnameismo, 38)
    endif
  endif

///---
  str_1 := ' ���� (���� ����)'
  if Loc_kod == 0
    str_1 := '����������'+str_1
  else
    str_1 := '������஢����'+str_1
  endif
  pr_1_str(str_1)
  setcolor(color8)
  myclear(1)

  setcolor(cDataCGet)
  make_diagP(1)  // ᤥ���� '��⨧����' ��������

  do while .t.
    pr_1_str(str_1)
    j := 1
    myclear(j)
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 say padl('���� ��� � ' + lstr(Loc_kod), 29) color color14
    endif
    // diag_screen(0)
    pos_read := 0
    // put_dop_diag(0)
    @ ++j, 1 say '��०�����' get mlpu when .f. color cDataCSay
    @ row(),col()+2 say '�⤥�����' get motd when .f. color cDataCSay
    //
    @ ++j, 1 say '���' get mfio_kart ;
        reader {|x| menu_reader(x, {{|k, r, c| get_fio_kart(k, r, c)}}, A__FUNCTION, , , .f.)} ;
        valid {|g, o| update_get('mkomu'),update_get('mcompany'),;
          update_get('mspolis'),update_get('mnpolis'),;
          update_get('mvidpolis') }
    //
    @ ++j, 1 say '���ࠢ�����: ���' get mnpr_date
    @ j, col() + 1 say '�� ��' get mnpr_mo ;
        reader {|x|menu_reader(x, {{|k, r, c| f_get_mo(k, r, c)}}, A__FUNCTION, , , .f.)} ;
        color colget_menu

    @ ++j, 1 say '�ப� ��祭��' get mn_data valid {|g| f_k_data(g, 1)}
    @ row() ,col() + 1 say '-'   get mk_data valid {|g| f_k_data(g, 2)}
    @ row(),col()+3 get mvzros_reb when .f. color cDataCSay

    @ ++j,1 say '� ���.����� (���ਨ)' get much_doc picture '@!' ;
        when when_uch_doc

    // ++j
    // rdiag := j
    @ ++j, 1 say '�᭮���� �������' get mkod_diag picture pic_diag ;
        reader {|o| MyGetReader(o, bg)} ;
        when when_diag() ;
        valid {|| val1_10diag(.t., .t., .t., mk_data, mpol), f_valid_beremenn(mkod_diag) }

    @ ++j, 1 say '�ਭ���������� ����' get mkomu ;
        reader {|x|menu_reader(x, mm_komu, A__MENUVERT, , , .f.)} ;
        valid {|g, o| f_valid_komu(g, o) } ;
        color colget_menu
    @ row(), col() + 1 say '==>' get mcompany ;
        reader {|x|menu_reader(x, mm_company, A__MENUVERT, , , .f.)} ;
        when diag_screen(2) .and. m1komu < 5 ;
        valid {|g| func_valid_ismo(g, m1komu, 38) }
    //
    @ ++j, 1 say '����� ���: ���' get mspolis when m1komu == 0
    @ row(), col() + 3 say '�����'  get mnpolis when m1komu == 0
    @ row(), col() + 3 say '���'    get mvidpolis ;
        reader {|x|menu_reader(x, mm_vid_polis, A__MENUVERT, , , .f.)} ;
        when m1komu == 0 ;
        valid func_valid_polis(m1vidpolis, mspolis, mnpolis)

    // ++j
    // rpp := j
    @ ++j, 1 say '���.������: �᫮��� ��������' get MUSL_OK ;
        reader {|x|menu_reader(x, tmp_V006, A__MENUVERT, , , .f.)} ;
        when diag_screen(2) ;
        valid {|g, o| iif(eq_any(m1usl_ok, 1, 2),;
          (SetPos(rpp, 40), DispOut('�ਧ���', cDataCGet)),;
          (mp_per := space(25), m1p_per := 0)),;
          update_get('mp_per'), f_valid_usl_ok(g, o)  }
    if eq_any(m1usl_ok, 1, 2)
      @ j, 40 say '�ਧ���'
    endif

    @ ++j, 3 say '��䨫� ���.�����' get mprofil ;
        reader {|x|menu_reader(x, tmp_V002, A__MENUVERT, , , .f.)} ;
        valid f_valid2ad_cr(mk_data)
    @ ++j, 3 say '��䨫� �����' get mprofil_k ;
        reader {|x|menu_reader(x,tmp_V020, A__MENUVERT, , , .f.)} ;
        when eq_any(m1usl_ok, 1, 2)

    // @ ++j, 1 say '������� ���饭��' get mrslt ;
    //     reader {|x|menu_reader(x, mm_rslt, A__MENUVERT, , , .f.)} ;
    //     valid {|g,o| f_valid_rslt(g, o) }

    // @ ++j, 1 say '��室 �����������' get mishod ;
    //     reader {|x|menu_reader(x, mm_ishod, A__MENUVERT, , , .f.)}

    @ maxrow() - 1, 55 say '�㬬� ��祭��' color color1
    @ row(), col() + 1 say lput_kop(mcena_1) color color8

    if !empty(a_smert)
      n_message(a_smert, , 'GR+/R', 'W+/R', , , 'G+/R')
    endif

    @ maxrow(), 0 say padc('<Esc> - ��室;  <PgDn> - ������;  <F1> - ������', maxcol() + 1) color color0
    mark_keys({'<F1>', '<Esc>', '<PgDn>'}, 'R/BG')

    count_edit += myread(, @pos_read)

    k := f_alert({padc('�롥�� ����⢨�', 60, '.')}, ;
      {' ��室 ��� ����� ', ' ������ ', ' ������ � ।���஢���� '}, ;
      iif(lastkey() == K_ESC, 1, 2), 'W+/N', 'N+/N', maxrow() - 2, , 'W+/N,N/BG')

    if k == 3
      loop
    elseif k == 2
      // �஢�ન � ������
    endif

    exit
  enddo

  setcolor(tmp_color)
  restscreen(buf)

  // if !empty(f_print)
  //   return &(f_print + '(' + lstr(Loc_kod) + ',' + lstr(kod_kartotek) + ')')
  // endif
  return nil