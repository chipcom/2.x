#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** 07.09.22 ���㫠�ୠ� ����樭᪠� ॠ������� - ���������� ��� ।���஢���� ���� (���� ���)
function oms_sluch_MED_REAB(Loc_kod, kod_kartotek, f_print)
  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  // f_print - ������������ �㭪樨 ��� ����

  Static skod_diag := '     ', st_n_data, st_k_data, ;
    st_vrach := 0, st_rslt := 0, st_ishod := 0

  local str_1
  local j // ���稪 ��ப �࠭�
  Local bg := {|o, k| get_MKB10(o, k, .t.) }, ;
    buf, tmp_color := setcolor(), a_smert := {},;
    p_uch_doc := '@!', pic_diag := '@K@!', ;
    i, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    fl_write_sluch := .f., when_uch_doc := .t.
  local tlist_rslt, list_rslt := {}, list_ishod, row
  local aReab, sArr := ''

  Default st_n_data TO sys_date, st_k_data TO sys_date
  Default Loc_kod TO 0, kod_kartotek TO 0

///++++ 
  buf := savescreen()

  Private mm_rslt, mm_ishod, rslt_umolch := 0, ishod_umolch := 0, ;
    m1USL_OK := 3, mUSL_OK, ;    // ⮫쪮 ���㫠�୮
    m1PROFIL := 158, mPROFIL     // ����樭᪠� ॠ�������

  Private mkod := Loc_kod, ;
    mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0), ;
    mtip_h, ;
    m1lpu := glob_uch[1], mlpu, ;
    m1otd := glob_otd[1], motd, ;
    mfio := space(50), mpol, mdate_r, madres, mmr_dol, ;
    m1fio_kart := 1, mfio_kart, ;
    m1vzros_reb, mvzros_reb, mpolis, m1rab_nerab, ;
    much_doc    := space(10)         ,; // ��� � ����� ��⭮�� ���㬥��
    m1npr_mo := '', mnpr_mo := space(10), mnpr_date := ctod(''), ;
    mkod_diag   := skod_diag         , ; // ��� 1-�� ��.�������
    mrslt, m1rslt := st_rslt         , ; // १����
    mishod, m1ishod := st_ishod      , ; // ��室
    m1company := 0, mcompany, mm_company, ;
    mkomu, m1komu := 0, m1str_crb := 0, ; // 0-���,1-��������,3-�������/���,5-���� ���
    m1reg_lech := 0, mreg_lech, ;
    mn_data     := st_n_data         , ; // ��� ��砫� ��祭��
    mk_data     := st_k_data         , ; // ��� ����砭�� ��祭��
    MCENA_1     := 0                 , ; // �⮨����� ��祭��
    MVRACH      := space(10)         , ; // 䠬���� � ���樠�� ���饣� ���
    M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
    msmo := '', rec_inogSMO := 0, ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := space(100), ;
    mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20), ;
    mvidreab, m1vidreab := 0, ;           // ॠ������� �� �����������
    mshrm, m1shrm := 0                    // ����� ��������樮���� ������⨧�樨

  private ;                   // ��� ᮢ���⨬���
    MKOD_DIAG0  := space(6), ; // ��� ��ࢨ筮�� ��������
    MKOD_DIAG2  := space(5), ; // ��� 2-�� ��.�������
    MKOD_DIAG3  := space(5), ; // ��� 3-�� ��.�������
    MKOD_DIAG4  := space(5), ; // ��� 4-�� ��.�������
    MSOPUT_B1   := space(5), ; // ��� 1-�� ᮯ������饩 �������
    MSOPUT_B2   := space(5), ; // ��� 2-�� ᮯ������饩 �������
    MSOPUT_B3   := space(5), ; // ��� 3-�� ᮯ������饩 �������
    MSOPUT_B4   := space(5), ; // ��� 4-�� ᮯ������饩 �������
    MDIAG_PLUS  := space(8), ; // ���������� � ���������
    MOSL1       := SPACE(6), ; // ��� 1-��� �������� �᫮������ �����������
    MOSL2       := SPACE(6), ; // ��� 2-��� �������� �᫮������ �����������
    MOSL3       := SPACE(6)    // ��� 3-��� �������� �᫮������ �����������

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
    m1NPR_MO   := human_->NPR_MO
    mNPR_DATE  := human_2->NPR_DATE
    
    aReab      := list2arr(human_2->PC5)
    m1vidreab  := aReab[1]
    m1shrm     := aReab[2]
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    m1rslt     := human_->RSLT_NEW
    m1ishod    := human_->ISHOD_NEW

    mcena_1 := human->CENA_1

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

  tlist_rslt := getRSLT_usl_date(m1USL_OK, mk_data)
  for each row in tlist_rslt
    if between(row[2], 301, 315)
      aadd(list_rslt, row)
    endif
  next
  list_ishod := getISHOD_usl_date(m1USL_OK, mk_data)

  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  mUSL_OK   := inieditspr(A__MENUVERT, getV006(), m1USL_OK)

  mPROFIL   := inieditspr(A__MENUVERT, getV002(), m1PROFIL)
  if !empty(m1NPR_MO)
    mNPR_MO := ret_mo(m1NPR_MO)[_MO_SHORT_NAME]
  endif

  mvidreab  := inieditspr(A__MENUVERT, type_reabilitacia(), m1vidreab)
  mshrm     := inieditspr(A__MENUVERT, type_shrm_reabilitacia(), m1shrm)

  mrslt     := inieditspr(A__MENUVERT, list_rslt, m1rslt)
  mishod    := inieditspr(A__MENUVERT, list_ishod, m1ishod)

  mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
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
    mtip_h := yes_vypisan
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

    diag_screen(0)
    pos_read := 0

    @ ++j, 1 say '��०�����' get mlpu when .f. color cDataCSay
    @ row(),col()+2 say '�⤥�����' get motd when .f. color cDataCSay
    //
    @ ++j, 1 say '���' get mfio_kart ;
        reader {|x| menu_reader(x, {{|k, r, c| get_fio_kart(k, r, c)}}, A__FUNCTION, , , .f.)} ;
        valid {|g, o| update_get('mkomu'),update_get('mcompany'), ;
          update_get('mspolis'),update_get('mnpolis'), ;
          update_get('mvidpolis') }
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
    @ row(), col() + 3 say '�����'  get mnpolis when m1komu == 0
    @ row(), col() + 3 say '���'    get mvidpolis ;
      reader {|x|menu_reader(x, mm_vid_polis, A__MENUVERT, , , .f.)} ;
      when m1komu == 0 ;
      valid func_valid_polis(m1vidpolis, mspolis, mnpolis)

    ++j
    @ ++j, 1 say '���ࠢ�����: ���' get mnpr_date
    @ j, col() + 1 say '�� ��' get mnpr_mo ;
        reader {|x|menu_reader(x, {{|k, r, c| f_get_mo(k, r, c)}}, A__FUNCTION, , , .f.)} ;
        color colget_menu

    @ ++j, 1 say '�ப� ��祭��' get mn_data valid {|g| f_k_data(g, 1)}
    @ row() ,col() + 1 say '-'   get mk_data valid {|g| f_k_data(g, 2)}
    @ row(), col() + 3 get mvzros_reb when .f. color cDataCSay

    ++j
    @ ++j,1 say '� ���.����� (���ਨ)' get much_doc picture '@!' ;
        when when_uch_doc

    @ row(), col() + 1 say '���' get MTAB_NOM pict '99999' ;
        valid {|g| v_kart_vrach(g, .t.) } when diag_screen(2)
    @ row(), col() + 1 get mvrach when .f. color color14

    @ ++j, 1 say '�᭮���� �������' get mkod_diag picture pic_diag ;
        reader {|o| MyGetReader(o, bg)} ;
        when when_diag() ;
        valid {|| val1_10diag(.t., .t., .t., mk_data, mpol, .t.) }

    @ ++j, 1 say '��䨫� ���.�����' get mprofil ;
        when .f. color cDataCSay ;
        valid {|| val1_10diag(.t., .t., .t., mk_data, mpol, .t.) }

    @ ++j, 1 say '��� ॠ����樨' get mvidreab ;
        reader {|x|menu_reader(x, type_reabilitacia(), A__MENUVERT, , , .f.)}

    @ ++j, 1 say '����� ��������樮���� ������⨧�樨' get mshrm ;
        reader {|x|menu_reader(x, type_shrm_reabilitacia(), A__MENUVERT, , , .f.)} ;
        when diag_screen(2) // ���⨬ ᮮ�饭�� � ��������

    @ ++j, 1 say '������� ���饭��' get mrslt ;
        reader {|x|menu_reader(x, list_rslt, A__MENUVERT, , , .f.)} ;
        valid {|g, o| f_valid_rslt(g, o) }

    @ ++j, 1 say '��室 �����������' get mishod ;
        reader {|x|menu_reader(x, list_ishod, A__MENUVERT, , , .f.)}

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
      if m1vidreab == 0
        func_error(4, '�� ��࠭ ��� ॠ�����樨.')
        loop
      endif
      if m1shrm == 0
        func_error(4, '�� ��࠭� 誠�� ॠ�����樨.')
        loop
      endif
      if empty(mn_data)
        func_error(4, '�� ������� ��� ��砫� ��祭��.')
        loop
      endif
      if empty(mk_data)
        func_error(4, '�� ������� ��� ����砭�� ��祭��.')
        loop
      endif
      if empty(mkod_diag)
        func_error(4, '�� ������ ��� �᭮����� �����������.')
        loop
      endif
      if empty(CHARREPL('0', much_doc, space(10)))
        func_error(4, '�� �������� ����� ���㫠�୮� ����� (���ਨ �������)')
        loop
      endif
      if m1komu < 5 .and. empty(m1company)
        if m1komu == 0     ; s := '���'
        elseif m1komu == 1 ; s := '��������'
        else               ; s := '������/��'
        endif
        func_error(4, '�� ��������� ������������ '+s)
        loop
      endif
      if m1komu == 0 .and. empty(mnpolis)
        func_error(4, '�� �������� ����� �����')
        loop
      endif
      err_date_diap(mn_data, '��� ��砫� ��祭��')
      err_date_diap(mk_data, '��� ����砭�� ��祭��')
      restscreen(buf)
      if mem_op_out == 2 .and. yes_parol
        box_shadow(19, 10, 22, 69, cColorStMsg)
        str_center(20, '������ "' + fio_polzovat + '".', cColorSt2Msg)
        str_center(21, '���� ������ �� ' + date_month(sys_date), cColorStMsg)
      endif
      mywait('����. �ந�������� ������ ���� ���� ...')

      make_diagP(2)  // ᤥ���� "��⨧����" ��������
      Use_base('human')
      if Loc_kod > 0
        find (str(Loc_kod,7))
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

      if isbit(mem_oms_pole,1)  //  "�ப� ��祭��",;  1
        st_N_DATA := MN_DATA
        st_K_DATA := MK_DATA
      endif
      if isbit(mem_oms_pole,2)  //  "���.���",;       2
        st_VRACH := m1vrach
      endif
      if isbit(mem_oms_pole,3)  //  "��.�������",;    3
        SKOD_DIAG := substr(MKOD_DIAG,1,5)
      endif
      if isbit(mem_oms_pole,5)  //  "१����",;      5
        st_RSLT := m1rslt
      endif
      if isbit(mem_oms_pole,6)  //  "��室",;          6
        st_ISHOD := m1ishod
      endif

      glob_perso := mkod
      if m1komu == 0
        msmo := lstr(m1company)
        m1str_crb := 0
      else
        msmo := ""
        m1str_crb := m1company
      endif
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
      human->POLIS      := make_polis(mspolis,mnpolis) // ��� � ����� ���客��� �����
      human->LPU        := M1LPU         // ��� ��०�����
      human->OTD        := M1OTD         // ��� �⤥�����
      human->UCH_DOC    := MUCH_DOC      // ��� � ����� ��⭮�� ���㬥��
      human->N_DATA     := MN_DATA       // ��� ��砫� ��祭��
      human->K_DATA     := MK_DATA       // ��� ����砭�� ��祭��
      human->CENA       := MCENA_1       // �⮨����� ��祭��
      human->CENA_1     := MCENA_1       // �⮨����� ��祭��

      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := ltrim(mspolis)
      human_->NPOLIS    := ltrim(mnpolis)
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
      human_2->NPR_DATE := mNPR_DATE
      human_2->PC5    := arr2list({m1vidreab, m1shrm}, .t.)

      Private fl_nameismo := .f.
      if m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ����� ��ꥪ� �� ����ਨ ���客����
        if empty(m1ismo)
          if !empty(mnameismo)
            fl_nameismo := .t.
          endif
        else
          human_->SMO := m1ismo  // �����塞 "34" �� ��� �����த��� ���
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
      write_work_oper(glob_task, OPER_LIST, iif(Loc_kod==0, 1, 2), 1, count_edit)
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

  if fl_write_sluch // �᫨ ����ᠫ�
    defenition_usluga_med_reab(mkod, m1vidreab, m1shrm)
    if type('fl_edit_oper') == 'L' // �᫨ ��室���� � ०��� ���������� ����
      fl_edit_oper := .t.  // �஢��� �����⨬ �� ��室� �� ��������� ���
    else // ���� ����᪠�� �஢���
      if (mcena_1 > 0) .and. !empty(val(msmo))
        verify_OMS_sluch(glob_perso)
      endif
    endif
  endif

  // if !empty(f_print)
  //   return &(f_print + '(' + lstr(Loc_kod) + ',' + lstr(kod_kartotek) + ')')
  // endif
  return nil

