#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** ᮣ��᭮ ����� ����� 09-30-276 �� 29.08.22 ���� - �⬥����
** ᮣ��᭮ ����� ����� 09-30-376/1 �� 09.11.22 ����
#define CHILD_EXIST .f. // ���뢠�� ��ᮢ��襭����⭨� ��� ���

** 21.01.23 ���������� ��� ।���஢���� ���� (���� ���)
function oms_sluch_ONKO_DISP(Loc_kod, kod_kartotek)
  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  static SKOD_DIAG := '     ', st_N_DATA, st_K_DATA, ;
    st_vrach := 0, st_profil := 0, st_profil_k := 0, ;
    st_rslt := 314, ; // �������᪮� �������
    st_ishod := 304 // ��� ��६��

  local bg := {|o, k| get_MKB10(o, k, .t.) }, ;
    buf, tmp_color := setcolor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', ;
    i, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    fl_write_sluch := .f., when_uch_doc := .t., ;
    arr_del := {}, mrec_hu := 0
  local mm_da_net := {{'���', 0}, {'�� ', 1}}
  local caption_window
  local top2, s
  local mtip_h
  local vozrast
  local lshifr := padr('2.5.2', 10)

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
  // ��� �������� �� ���������
  Private mkod := Loc_kod,  ;
    mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0), ;
    mfio := space(50),  mpol, mdate_r, madres, mmr_dol, ;
    M1FIO_KART := 1, MFIO_KART, ;
    M1VZROS_REB, MVZROS_REB, mpolis, M1RAB_NERAB, ;
    MUCH_DOC    := space(10)         , ; // ��� � ����� ��⭮�� ���㬥��
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-���, 1-��������, 3-�������/���, 5-���� ���
    msmo := '34007',  rec_inogSMO := 0, ;
    mokato, m1okato := '',  mismo, m1ismo := '',  mnameismo := space(100), ;
    mvidpolis, m1vidpolis := 1, mspolis := space(10),  mnpolis := space(20)

  //
  Private tmp_V006 := create_classif_FFOMS(2, 'V006') // USL_OK
  Private tmp_V002 := create_classif_FFOMS(2, 'V002') // PROFIL
  Private tmp_V020 := create_classif_FFOMS(2, 'V020') // PROFIL_K
  // Private tmp_V009 := cut_glob_array(getV009(), sys_date) // rslt
  // Private tmp_V012 := cut_glob_array(getV012(),sys_date) // ishod
  Private tmp_V009 := getV009(sys_date) // rslt
  Private tmp_V012 := getV012(sys_date) // ishod
  private mm_N002
  Private mm_rslt, mm_ishod, rslt_umolch := 0, ishod_umolch := 0
  //
  Private ;
    M1LPU := glob_uch[1], MLPU, ;
    M1OTD := glob_otd[1], MOTD, ;
    MKOD_DIAG   := SKOD_DIAG         , ; // ��� 1-�� ��.�������
    MKOD_DIAG0  := space(6)          , ; // ��� ��ࢨ筮�� ��������
    MKOD_DIAG2  := space(5)          , ; // ��� 2-�� ��.�������
    MKOD_DIAG3  := space(5)          , ; // ��� 3-�� ��.�������
    MKOD_DIAG4  := space(5)          , ; // ��� 4-�� ��.�������
    MSOPUT_B1   := space(5)          , ; // ��� 1-�� ᮯ������饩 �������
    MSOPUT_B2   := space(5)          , ; // ��� 2-�� ᮯ������饩 �������
    MSOPUT_B3   := space(5)          , ; // ��� 3-�� ᮯ������饩 �������
    MSOPUT_B4   := space(5)          , ; // ��� 4-�� ᮯ������饩 �������
    MDIAG_PLUS  := space(8)          , ; // ���������� � ���������
    MOSL1 := SPACE(6)     , ; // ��� 1-��� �������� �᫮������ �����������
    MOSL2 := SPACE(6)     , ; // ��� 2-��� �������� �᫮������ �����������
    MOSL3 := SPACE(6)     , ; // ��� 3-��� �������� �᫮������ �����������
    mrslt, m1rslt := st_rslt         , ; // १����
    mishod, m1ishod := st_ishod      , ; // ��室
    MN_DATA     := st_N_DATA         , ; // ��� ��砫� ��祭��
    MK_DATA     := st_K_DATA         , ; // ��� ����砭�� ��祭��
    MCENA_1     := 0                 , ; // �⮨����� ��祭��
    MVRACH      := space(10)         , ; // 䠬���� � ���樠�� ���饣� ���
    M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
    m1USL_OK := 3, mUSL_OK, ;             // ���㫠�୮
    m1PROFIL := st_profil, mPROFIL, ;
    m1PROFIL_K := st_profil_k, mPROFIL_K, ;
    m1IDSP   := 29, ;                     // �� ���饭��
    mdate_next := sys_date, ;  // ctod('')                // ��� ᫥���饣� ���饭��
    mSTAD, m1STAD := 0 // �⠤�� �����������      ���������� � ᮮ⢥��⢨� � �ࠢ�筨��� N002

  Private mm_profil := {{'��������', 68}, ;
    {'����⮫����', 12}, ;
    {'���᪠� ���������', 18}, ;
    {'���������', 60}, ;
    {'��饩 ��祡��� �ࠪ⨪�', 57}}

  //
  R_Use(dir_server + 'mo_onksl', dir_server + 'mo_onksl', 'SL')
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
    MTIP_H      := human->tip_h
    M1LPU       := human->LPU
    M1OTD       := human->OTD
    M1FIO       := 1
    // �㤥� ���� �� ����⥪�
    // mfio        := human->fio
    // mpol        := human->pol
    // mdate_r     := human->date_r
    // M1VZROS_REB := human->VZROS_REB
    // MADRES      := human->ADRES         // ���� ���쭮��
    // MMR_DOL     := human->MR_DOL        // ���� ࠡ��� ��� ��稭� ���ࠡ�⭮��
    // M1RAB_NERAB := human->RAB_NERAB     // 0-ࠡ���騩, 1-��ࠡ���騩
    //
    mUCH_DOC    := human->uch_doc
    m1VRACH     := human_->vrach
    MKOD_DIAG   := human->KOD_DIAG
    MPOLIS      := human->POLIS         // ��� � ����� ���客��� �����
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
    // m1rslt     := human_->RSLT_NEW
    m1ishod    := human_->ISHOD_NEW
    mcena_1    := human->CENA_1
    mdate_next := c4tod(human->DATE_OPL)
      //
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(2,@rec_inogSMO,.t.) // ������ � �������
    endif

    select SL
    find (str(Loc_kod, 7))
    if found()
      m1STAD := sl->STAD
    endif
    mm_N002 := f_define_tnm(2, mkod_diag)
    mSTAD  := padr(inieditspr(A__MENUVERT, mm_N002, m1STAD), 5)

    // �롥६ ��㣨
    R_Use(dir_server + 'uslugi', , 'USL')
    use_base('human_u')
    find (str(Loc_kod, 7))
    do while hu->kod == Loc_kod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1, usl->kod, mk_data))
        lshifr := usl->shifr
      endif
      if mrec_hu == 0
        mrec_hu := hu->(recno())
      else
        aadd(arr_del, hu->(recno()))
      endif
      select HU
      skip
    enddo
    for i := 1 to len(arr_del)
      select HU
      goto (arr_del[i])
      DeleteRec(.t., .f.)  // ���⪠ ����� ��� ����⪨ �� 㤠�����
    next
  endif

  // ��⮢�� ᯨ᮪ ��䨫�� �� �������  
  vozrast := count_years(mdate_r, mk_data)
  if vozrast < 18 .and. CHILD_EXIST
    hb_ADel(mm_profil, 5, .t.)
    hb_ADel(mm_profil, 4, .t.)
  elseif vozrast < 18 .and. ! CHILD_EXIST
    func_error(4, '����� ���� ��� �����⨬ ⮫쪮 ��� ᮢ��襭���⭨� ��樥�⮢')
    close databases
    return nil
  else
    hb_ADel(mm_profil, 5, .t.)
    hb_ADel(mm_profil, 3, .t.)
    // hb_ADel(mm_profil, 2, .t.)
    hb_ADel(mm_profil, 1, .t.)
  endif

  if m1PROFIL == 0
    if vozrast < 18 .and. CHILD_EXIST
      m1PROFIL := 18  // ���᪠� ���������
    else
      m1PROFIL := 60  // ���������
    endif
  endif
  mPROFIL := inieditspr(A__MENUVERT, mm_profil, m1PROFIL)

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

  if m1vrach > 0
    R_Use(dir_server + 'mo_pers', , 'P2')
    goto (m1vrach)
    MTAB_NOM := p2->tab_nom
    m1prvs := -ret_new_spec(p2->prvs, p2->prvs_new)
    mvrach := padr(fam_i_o(p2->fio) + ' ' + ret_tmp_prvs(m1prvs), 36)
  endif

  close databases
  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  if empty(m1USL_OK)
    m1USL_OK := 3
  endif // �� ��直� ��砩
  mishod    := inieditspr(A__MENUVERT, getV012(), m1ishod)
  mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  motd      := inieditspr(A__POPUPMENU, dir_server + 'mo_otd',  m1otd)
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
  caption_window := ' ���� ���⠭���� �� ��ᯠ���� ��� ���������᪮�� ��樥��'
  if Loc_kod == 0
    caption_window := '����������' + caption_window
    mtip_h := yes_vypisan
  else
    caption_window := '������஢����' + caption_window
  endif

  setcolor(color8)
  top2 := 10
  myclear(top2)
  @ top2 - 1,0 say padc(caption_window, 80) color "B/BG*"
  Private gl_area := {1, 0, maxrow() - 1, maxcol(), 0}
  @ maxrow(), 0 say padc('<Esc> - ��室;  <PgDn> - ������', maxcol() + 1) color color0
  mark_keys({'<F1>', '<Esc>', '<PgDn>'}, 'R/BG')
  setcolor(cDataCGet)
  make_diagP(1)  // ᤥ���� "��⨧����" ��������
  diag_screen(0)

  Private rdiag := 1, rpp := 1

  do while .t.
    j := top2
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 say padl('���� ��� � ' + lstr(Loc_kod), 29) color color14
    endif
    pos_read := 0
    //
    @ ++j, 1 say '��०�����' get mlpu when .f. color cDataCSay
    @ row(), col() + 2 say '�⤥�����' get motd when .f. color cDataCSay
    //
    //
    ++j
    @ ++j, 1 say '���' get mfio_kart ;
        reader {|x| menu_reader(x, {{|k, r, c| get_fio_kart(k, r, c)}}, A__FUNCTION, , ,.f.)} ;
        valid {|g, o| update_get('mkomu'), update_get('mcompany'), ;
          update_get('mspolis'), update_get('mnpolis'), ;
          update_get('mvidpolis') }
    //
    //
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
    @ row(), col()+3 say '�����' get mnpolis when m1komu == 0
    @ row(), col()+3 say '���'   get mvidpolis ;
        reader {|x|menu_reader(x, mm_vid_polis, A__MENUVERT, , , .f.)} ;
        when m1komu == 0 ;
        valid func_valid_polis(m1vidpolis, mspolis, mnpolis)
    //
    ++j
    //
    //
    @ ++j, 1 say '� ���.����� (���ਨ)' get much_doc picture '@!' when when_uch_doc
    //
    @ ++j, 1 say '��䨫�' get mPROFIL ;
      reader {|x|menu_reader(x, mm_profil, A__MENUVERT, , ,.f.)} //; color colget_menu
    //
    @ ++j, 1 say '��� ���⠭���� �� ��ᯠ���� ���' get mn_data valid {|g|f_k_data(g, 1)}
    //
    //
    ++j
    @ j, 1 say '��� ᫥���饩 � ��� ��ᯠ��୮�� �������' get mdate_next valid (mdate_next > MN_DATA)
    //
    ++j
    @ j, 1 say '�᭮���� �������' get mkod_diag picture pic_diag ;
      reader {|o| MyGetReader(o, bg)} ;
      when when_diag() ;
      valid {|| val1_10diag(.t., .t., .t., mn_data, mpol),  f_valid_onko_diag(mkod_diag, mdate_r, MN_DATA, CHILD_EXIST) }

    @ row(), col() + 1 say '�⠤�� �����������:' get mSTAD ;
      reader {|x|menu_reader(x, mm_N002, A__MENUVERT, , ,.f.)} ;
      valid {|g| f_valid_tnm(g),  mSTAD:=padr(mSTAD, 5),  .t.} ;
      color colget_menu

    // @ row(), col() + 1 say '���' get MTAB_NOM pict '99999' ;
    @ ++j, 1 say '���' get MTAB_NOM pict '99999' ;
      valid {|g| v_kart_vrach(g, .t.), f_valid_onko_vrach(MTAB_NOM, mdate_r, MN_DATA, CHILD_EXIST) } when diag_screen(2)
    @ row(), col() + 1 get mvrach when .f. color color14
    //

    count_edit += myread(, @pos_read)

    k := f_alert({padc('�롥�� ����⢨�', 60, '.')}, ;
                   {' ��室 ��� ����� ',  ' ������ ',  ' ������ � ।���஢���� '}, ;
                   iif(lastkey() == K_ESC, 1, 2),  'W+/N',  'N+/N', maxrow() - 2, , 'W+/N,N/BG' )
    if k == 3
      loop
    elseif k == 2 // ������ ���ଠ樨
      if empty(mn_data)
        func_error(4, '�� ������� ��� ���⠭���� �� ���')
        loop
      endif
      MK_DATA := MN_DATA  // ���� ������ ᮢ������
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
        func_error(4,'�� �������� ����� �����')
        loop
      endif
      if empty(mfio)
        func_error(4, '�� ������� �.�.�. ��� �����!')
        loop
      endif
      if empty(mdate_r)
        func_error(4, '�� ��������� ��� ஦�����')
        loop
      endif
      if empty(mdate_next)
        func_error(4, '�� ��������� ��� ᫥���饣� ���饭��')
        loop
      endif
      if mdate_next <= MK_DATA
        func_error(4, '�� ��ୠ� ��� ᫥���饣� ���饭��')
        loop
      endif
      // if eq_any(m1vid_ud,3,14) .and. !empty(mser_ud) .and. empty(del_spec_symbol(mmesto_r))
      //   func_error(4,iif(m1vid_ud == 3, '��� ᢨ�-�� � ஦�����', '��� ��ᯮ�� ��') + ;
      //                ' ��易⥫쭮 ���������� ���� "���� ஦�����"')
      //   loop
      // endif
      if empty(mkod_diag)
        func_error(4, '�� ������ ��� �᭮����� �����������.')
        loop
      endif

      mywait('����. �ந�������� ������ ���� ���� ...')
      // ����� �஢�ન � ������

      make_diagP(2)  // ᤥ���� '��⨧����' ��������
      //
      Use_base('lusl')
      Use_base('luslc')
      Use_base('uslugi')
      R_Use(dir_server + 'uslugi1', {dir_server + 'uslugi1', ;
                                dir_server + 'uslugi1s'}, 'USL1')
      Private mu_kod, mu_cena
      mu_kod := foundOurUsluga(lshifr, mk_data, m1PROFIL, M1VZROS_REB, @mu_cena)

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
      human->TIP_H      := B_STANDART
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
      human->POLIS      := make_polis(mspolis, mnpolis) // ��� � ����� ���客��� �����
      human->LPU        := M1LPU         // ��� ��०�����
      human->OTD        := M1OTD         // ��� �⤥�����
      human->UCH_DOC    := MUCH_DOC      // ��� � ����� ��⭮�� ���㬥��
      human->N_DATA     := MN_DATA       // ��� ��砫� ��祭��
      human->K_DATA     := MK_DATA       // ��� ����砭�� ��祭��
      human->CENA       := MCENA_1       // �⮨����� ��祭��
      human->CENA_1     := MCENA_1       // �⮨����� ��祭��
      human->DATE_OPL := dtoc4(mdate_next)  // ��� ᫥���饣� ���饭��
      human_->DISPANS   := '2000000000000000'  // ���⠢��� �� ��ᯠ���� ���
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := ltrim(mspolis)
      human_->NPOLIS    := ltrim(mnpolis)
      human_->OKATO     := '' // �� ���� ������� �� ����� � ��砥 �����த����
      human_->USL_OK    := m1USL_OK
      human_->PROFIL    := m1PROFIL
      human_->IDSP      := m1IDSP   // 29
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // 㡥�� '2',  �᫨ ��।���஢��� ������ �� ॥��� �� � ��
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
      human_2->PROFIL_K := m1PROFIL_K
      human_2->p_per  := iif(eq_any(m1USL_OK, 1, 2),  m1p_per, 0)

      use_base('human_u')
      select HU
      if mrec_hu == 0
        Add1Rec(7)
        mrec_hu := hu->(recno())
      else
        goto (mrec_hu)
        G_RLock(forever)
      endif
      replace hu->kod     with human->kod, ;
              hu->kod_vr  with m1vrach, ;
              hu->kod_as  with 0, ;
              hu->u_koef  with 1, ;
              hu->u_kod   with mu_kod, ;
              hu->u_cena  with mu_cena, ;
              hu->is_edit with 0, ;
              hu->date_u  with dtoc4(MK_DATA), ;
              hu->otd     with m1otd, ;
              hu->kol     with 1, ;
              hu->stoim   with mu_cena, ;
              hu->kol_1   with 1, ;
              hu->stoim_1 with mu_cena, ;
              hu->KOL_RCP with 0
      select HU_
      do while hu_->(lastrec()) < mrec_hu
        APPEND BLANK
      enddo
      goto (mrec_hu)
      G_RLock(forever)
      if Loc_kod == 0 .or. !valid_GUID(hu_->ID_U)
        hu_->ID_U := mo_guid(3, hu_->(recno()))
      endif
      hu_->PROFIL   := m1PROFIL
      hu_->PRVS     := m1PRVS
      hu_->kod_diag := mkod_diag
      hu_->zf       := ''

      G_Use(dir_server + 'mo_onksl', dir_server + 'mo_onksl',  'SL')
      find (str(mkod, 7))
      if found()
        G_RLock(forever)
      else
        AddRec(7)
        sl->kod := mkod
      endif
      sl->DS1_T := 4  // ᮣ��᭮ ���쬠 �����
      sl->STAD := m1STAD

      G_Use(dir_server + 'mo_onkco', dir_server + 'mo_onkco',  'CO')
      find (str(mkod, 7))
      if found()
        G_RLock(forever)
      else
        AddRec(7)
        co->kod := mkod
      endif
      co->PR_CONS := 0  // ��������� ����室������ �஢������ ���ᨫ�㬠

      write_work_oper(glob_task, OPER_LIST, iif(Loc_kod == 0, 1, 2), 1, count_edit)
      fl_write_sluch := .t.
      close databases
      stat_msg('������ �����襭�!', .f.)
    endif
    exit
  enddo
  close databases
  diag_screen(2)
  setcolor(tmp_color)
  restscreen(buf)
  if fl_write_sluch // �᫨ ����ᠫ� - ����᪠�� �஢���
    if !empty(val(msmo))
      verify_OMS_sluch(glob_perso)
    endif
  endif

  return nil

** 23.11.22
function f_valid_onko_diag(diag, dob, date_post, children_acceptable)
  // diag - ���������᪨� �������
  // dob - ��� ஦�����
  // date_post - ��� ���⠭���� �� ���

  // ��� ������ ���� �� ��ਪ C00-D09
  // ��� ��⥩ ���� �� ��ਪ C00-D89
  local vozrast, fl := .f., diagBeg := 'C00', diagAdult := 'D09', diagChild := 'D89'
  local mshifr
  local aDiag

  private mvar := upper(readvar())

  mshifr := alltrim(&mvar)
  vozrast := count_years(dob, date_post)
  if vozrast < 18 .and. ! children_acceptable
    fl := .f.
    func_error(4, '�����⨬� ⮫쪮 ��� ᮢ��襭����⭨� ��樥�⮢!')
    return fl
  endif
  aDiag := { ;
            {'C00', 'C97'}, ;
            {'D00', iif(vozrast < 18, diagChild, diagAdult)} ;
          }
  fl := between_diag_array(mshifr, aDiag)

  if ! fl
    func_error(4, '�������⨬� �������, �����⨬� �������� � ' + diagBeg + ' �� ' + iif(vozrast < 18, diagChild, diagAdult) + '!')
    return fl
  endif
  mm_N002 := f_define_tnm(2, diag)

  return fl

** 09.09.22
function f_valid_onko_vrach(tabnom, dob, date_post, children_acceptable)
  // tab_nom - ⠡���� ����� ���
  // dob - ��� ஦�����
  // date_post - ��� ���⠭���� �� ���
  local vozrast, fl := .f.
  local med_spec_child_V021 := {9, 19, 49, 102} // �����⨬� ᯥ樠�쭮�� ��� ��⥩
  local med_spec_adult_V021 := {9, 41}  // �����⨬� ᯥ樠�쭮�� ��� ������ ⮫쪮 "����⮫����" � "���������"

  vozrast := count_years(dob, date_post)
  if vozrast < 18 .and. ! children_acceptable
    fl := .f.
    func_error(4, '�����⨬� ⮫쪮 ��� ᮢ��襭����⭨� ��樥�⮢!')
    return fl
  endif
  if ascan(iif(vozrast < 18, med_spec_child_V021, med_spec_adult_V021), get_spec_vrach_V021_by_tabnom(tabnom)) > 0
    fl := .t.
  endif
  if ! fl
    func_error(4, '�������⨬�� ᯥ樠�쭮��� ���!')
  endif
  return fl
