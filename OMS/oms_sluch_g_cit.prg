#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
  
// 09.08.16 ������⭠� �⮫���� ࠪ� 襩�� ��⪨
Function oms_sluch_g_cit(Loc_kod, kod_kartotek)
  // Loc_kod - ��� �� �� human.dbf (�᫨ = 0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  Static st_N_DATA, sv1 := 0
  Local arr_del := {}, mrec_hu := 0, buf := savescreen(), tmp_color := setcolor(), ;
          a_smert := {}, p_uch_doc := '@!', pic_diag := '@K@!', arr_usl := {}, ;
          i, j, k, n, s, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
          pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod, ;
          tmp_help := chm_help_code, fl_write_sluch := .f., t_arr[2], ;
          bg := {|o,k| get_MKB10(o,k, .t.) }
  Local top2 := 11
  
  if empty(glob_klin_diagn)
    return func_error(4, '� ��襬 ��०����� �� ࠧ�襭� ᯥ樠��� �������� ��᫥�������')
  endif
  //
  Default st_N_DATA TO sys_date
  Default Loc_kod TO 0, kod_kartotek TO 0
  //
  if kod_kartotek == 0 // ���������� � ����⥪�
    if (kod_kartotek := edit_kartotek(0, , , .t.)) == 0
      return NIL
    endif
  endif
  chm_help_code := 3002
  Private mfio := space(50), mpol, mdate_r, madres, mvozrast, ;
      M1VZROS_REB, MVZROS_REB, m1novor := 0, ;
      m1company := 0, mcompany, mm_company, ;
      mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-���, 1-��������, 3-�������/���, 5-���� ���
      msmo := '34007', rec_inogSMO := 0, ;
      mokato, m1okato := '', mismo, m1ismo := '', mnameismo := space(100), ;
      mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20)
  Private mkod := Loc_kod, mtip_h, is_talon := .f., ;
            mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0), ;
      M1LPU := glob_uch[1], MLPU, ;
      M1OTD := glob_otd[1], MOTD, ;
      M1FIO_KART := 1, MFIO_KART, ;
      MUCH_DOC    := space(10)         , ; // ��� � ����� ��⭮�� ���㬥��
      MKOD_DIAG   := 'Z01.7'           , ; // ��� 1-�� ��.�������
      m1rslt  := 314                   , ; // १���� ��祭��
      m1ishod := 304                   , ; // ��室 = ��� ��६��
      m1NPR_MO := '', mNPR_MO := space(10), mNPR_DATE := ctod(''), ;
      MN_DATA := st_N_DATA         , ; // ��� ��砫� ��祭��
      MK_DATA, ;
      MVRACH := space(10)         , ; // 䠬���� � ���樠�� ���饣� ���
      M1VRACH := 0, MTAB_NOM := sv1, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
      m1povod  := 1, ;   // ��祡��-���������᪨�
      m1travma := 0
    //
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
                      '��祭�� � ' + full_date(human->N_DATA) + ;
                            ' �� ' + full_date(human->K_DATA)}
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
    m1NPR_MO    := human_->NPR_MO
    mNPR_DATE   := human_2->NPR_DATE
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
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    mcena_1    := human->CENA_1
    //
    use_base('human_u')
    find (str(Loc_kod, 7))
    do while hu->kod == Loc_kod .and. !eof()
      aadd(arr_usl, hu->(recno()))
      select HU
      skip
    enddo
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(2, @rec_inogSMO, .t.) // ������ � �������
    endif
  endif
  if !(left(msmo, 2) == '34') // �� ������ࠤ᪠� �������
    m1ismo := msmo
    msmo := '34'
  endif
  if m1vrach > 0
    R_Use(dir_server + 'mo_pers', , 'P2')
    goto (m1vrach)
    MTAB_NOM := p2->tab_nom
    m1prvs := -ret_new_spec(p2->prvs, p2->prvs_new)
    mvrach := padr(fam_i_o(p2->fio) + ' ' + ret_tmp_prvs(m1prvs), 36)
  endif
  close databases
  is_talon := .t.
  fv_date_r( iif(Loc_kod > 0, mn_data, ))
  MFIO_KART := _f_fio_kart()
  if !empty(m1NPR_MO)
    mNPR_MO := ret_mo(m1NPR_MO)[_MO_SHORT_NAME]
  endif
  MKOD_DIAG := padr(MKOD_DIAG, 6)
  mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  mlpu      := inieditspr(A__POPUPMENU, dir_server + 'mo_uch', m1lpu)
  motd      := inieditspr(A__POPUPMENU, dir_server + 'mo_otd', m1otd)
  mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
  mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
  mismo     := init_ismo(m1ismo)
  f_valid_komu( , -1)
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
  str_1 := ' ���� ���.-�����.��楤��� �� �஢������ '
  if ascan(glob_klin_diagn, 1) > 0
    str_1 += '������⭮� �⮫����'
  elseif ascan(glob_klin_diagn, 2) > 0
    str_1 += '�७�⠫쭮�� �ਭ����'
  endif
  if Loc_kod == 0
    str_1 := '����������' + str_1
    mtip_h := yes_vypisan
  else
    str_1 := '������஢����' + str_1
  endif
  setcolor(color8)
  myclear(top2)
  @ top2 - 1, 0 say padc(str_1, 80) color 'B/BG*'
  Private gl_area := {1, 0, maxrow() - 1, maxcol(), 0}
  setcolor(cDataCGet)
  diag_screen(0)
  do while .t.
    close databases
    j := top2
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 say padl('���� ��� � ' + lstr(Loc_kod), 29) color color14
    endif
    @ ++j, 1 say '��०�����' get mlpu when .f. color cDataCSay
    @ row(), col() + 2 say '�⤥�����' get motd when .f. color cDataCSay
    //
    @ ++j, 1 say '���' get mfio_kart ;
          reader {|x| menu_reader(x, {{|k, r, c| get_fio_kart(k, r, c)}}, A__FUNCTION, , , .f.)} ;
          valid {|g, o| update_get('mkomu'), update_get('mcompany'), ;
                      update_get('mspolis'), update_get('mnpolis'), ;
                      update_get('mvidpolis') }
    @ row(), col() + 5 say '�.�.' get mdate_r when .f. color color14
    //
    @ ++j, 1 say '���ࠢ�����: ���' get mNPR_DATE
    @ j, col() + 1 say '�� ��' get mNPR_MO ;
              reader {|x|menu_reader(x, {{|k, r, c|f_get_mo(k, r, c)}}, A__FUNCTION, , , .f.)} ;
              color colget_menu
    @ ++j, 1 say '�ਭ���������� ����' get mkomu ;
              reader {|x|menu_reader(x, mm_komu, A__MENUVERT, , , .f.)} ;
              valid {|g, o| f_valid_komu(g, o)} ;
              color colget_menu
    @ row(), col() + 1 say '==>' get mcompany ;
              reader {|x|menu_reader(x, mm_company, A__MENUVERT, , , .f.)} ;
              when m1komu < 5 ;
              valid {|g| func_valid_ismo(g, m1komu, 38) }
    @ ++j, 1 say '����� ���: ���' get mspolis when m1komu == 0
    @ row(), col() + 3 say '�����'  get mnpolis when m1komu == 0
    @ row(), col() + 3 say '���'    get mvidpolis ;
              reader {|x|menu_reader(x, mm_vid_polis, A__MENUVERT, , , .f.)} ;
              when m1komu == 0 ;
              valid func_valid_polis(m1vidpolis, mspolis, mnpolis)
    @ ++j, 1 to j, 78
    @ ++j, 1 say '��� ��楤���' get mn_data ;
              valid {|g| f_k_data(g, 1), mk_data := mn_data, f_k_data(g, 2) }
    @ ++j, 1 say '� ���㫠�୮� �����' get much_doc picture '@!' ;
              when diag_screen(2) .and. ;
                    (!(is_uchastok == 1 .and. is_task(X_REGIST)) .or. mem_edit_ist == 2)
    @ ++j, 1 say '�᭮���� �������' get mkod_diag picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t., .t., .t., mn_data, mpol)
    @ ++j, 1 say '������� ����� ���饣� ���' ;
              get MTAB_NOM pict '99999' valid {|g| v_kart_vrach(g, .t.) } ;
              when diag_screen(2)
    @ row(), col() + 1 get mvrach when .f. color color14
    status_key('^<Esc>^ - ��室 ��� �����; ^<PgDn>^ - ������')
    if !empty(a_smert)
      n_message(a_smert, , 'GR+/R', 'W+/R', , , 'G+/R')
    endif
    count_edit += myread( , , ++k_read)
    diag_screen(2)
    k := f_alert({padc('�롥�� ����⢨�', 60,'.')}, ;
                   {' ��室 ��� ����� ', ' ������ ', ' ������ � ।���஢���� '}, ;
                   iif(lastkey() == K_ESC, 1, 2), 'W+/N', 'N+/N', maxrow() - 2, , 'W+/N, N/BG')
    if k == 3
      loop
    elseif k == 2
      if m1komu < 5 .and. empty(m1company)
        if m1komu == 0
          s := '���'
        elseif m1komu == 1
          s := '��������'
        else
          s := '������/��'
        endif
        func_error(4, '�� ��������� ������������ '+s)
        loop
      elseif m1komu == 0 .and. empty(mnpolis)
        func_error(4, '�� �������� ����� �����')
        loop
      elseif mpol == '�'
        func_error(4, '������ ��楤�� �믮������ ⮫쪮 ��� ���騭.')
        loop
      elseif empty(mn_data)
        func_error(4, '�� ������� ��� ��楤���.')
        loop
      elseif empty(MTAB_NOM)
        func_error(4, '�� ������ ⠡���� ����� ���')
        loop
      elseif empty(m1NPR_MO)
        func_error(4, '�� ������� ���ࠢ���� ����樭᪠� �࣠������')
        loop
      elseif left(mkod_diag, 1) == 'Z' .and. !(alltrim(mkod_diag) == 'Z01.7')
        func_error(4, '�᭮���� ������� �� Z ����� ���� ⮫쪮 Z01.7')
        loop
      endif
      if empty(mkod_diag)
        mkod_diag := 'Z01.7 '
      endif
      arr_iss := array(1, 9)
      afillall(arr_iss, 0)
      R_Use(dir_server + 'mo_pers', dir_server + 'mo_pers', 'P2')
      find (str(MTAB_NOM, 5))
      if found()
        arr_iss[1, 1] := p2->kod
        arr_iss[1, 2] := -ret_new_spec(p2->prvs, p2->prvs_new)
      endif
      arr_iss[1, 4] := 34 // ��䨫� - ������᪠� ������ୠ� �������⨪�
      if ascan(glob_klin_diagn, 1) > 0 // ������⭮� �⮫����
        arr_iss[1, 5] := '4.20.702' // ��� ��㣨
      elseif ascan(glob_klin_diagn, 2) > 0 // �७�⠫쭮�� �ਭ����
        arr_iss[1, 5] := '4.15.746' // ��� ��㣨
      endif
      err_date_diap(mn_data, '��� �������⨪�')
      //
      if mem_op_out == 2 .and. yes_parol
        box_shadow(19, 10, 22, 69, cColorStMsg)
        str_center(20, '������ "' + fio_polzovat + '".', cColorSt2Msg)
        str_center(21, '���� ������ �� ' + date_month(sys_date), cColorStMsg)
      endif
      mywait()
      //
      sv1 := MTAB_NOM
      //
      Use_base('lusl')
      Use_base('luslc')
      Use_base('uslugi')
      R_Use(dir_server + 'uslugi1', {dir_server + 'uslugi1', ;
                                    dir_server + 'uslugi1s'}, 'USL1')
      Private mu_cena
      mcena_1 := 0
      arr_usl_dop := {}
      glob_podr := ''
      glob_otd_dep := 0
      for i := 1 to len(arr_iss)
        if valtype(arr_iss[i, 5]) == 'C'
          arr_iss[i, 7] := foundOurUsluga(arr_iss[i, 5], mn_data, arr_iss[i, 4], M1VZROS_REB, @mu_cena)
          arr_iss[i, 8] := mu_cena
          mcena_1 += mu_cena
          aadd(arr_usl_dop, arr_iss[i])
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
      human_->KOD_DIAG0 := ''
      human->KOD_DIAG   := MKOD_DIAG     // ��� 1-�� ��.�������
      human->KOD_DIAG2  := ''
      human->KOD_DIAG3  := ''
      human->KOD_DIAG4  := ''
      human->SOPUT_B1   := ''
      human->SOPUT_B2   := ''
      human->SOPUT_B3   := ''
      human->SOPUT_B4   := ''
      human->diag_plus  := ''            //
      human->ZA_SMO     := 0
      human->KOMU       := M1KOMU        // �� 0 �� 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis(mspolis, mnpolis) // ��� � ����� ���客��� �����
      human->LPU        := M1LPU         // ��� ��०�����
      human->OTD        := M1OTD         // ��� �⤥�����
      human->UCH_DOC    := MUCH_DOC      // ��� � ����� ��⭮�� ���㬥��
      human->N_DATA     := MN_DATA       // ��� ��砫� ��祭��
      human->K_DATA     := MN_DATA       // ��� ����砭�� ��祭��
      human->CENA := human->CENA_1 := MCENA_1 // �⮨����� ��祭��
      human->ishod      := 98 // ������⭠� �⮫���� ࠪ� 襩�� ��⪨
      human->bolnich    := 0
      human->date_b_1   := ''
      human->date_b_2   := ''
      human_->RODIT_DR  := ctod('')
      human_->RODIT_POL := ''
      human_->DISPANS   := replicate('0', 16)
      human_->STATUS_ST := ''
      human_->POVOD     := 9 // {'2.6-���饭�� �� ��㣨� �����⥫��⢠�', 9,'2.6'}, ;
      //human_->TRAVMA    := m1travma
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := ltrim(mspolis)
      human_->NPOLIS    := ltrim(mnpolis)
      human_->OKATO     := '' // �� ���� ������� �� ����� � ��砥 �����த����
      human_->NOVOR     := 0
      human_->DATE_R2   := ctod('')
      human_->POL2      := ''
      human_->USL_OK    := 3
      human_->VIDPOM    := 13
      human_->PROFIL    := 34 // ������᪮� ������୮� �������⨪�
      human_->IDSP      := 4 // ��祡��-���������᪠� ��楤��
      human_->NPR_MO    := m1NPR_MO
      human_->FORMA14   := '0000'
      human_->KOD_DIAG0 := ''
      human_->RSLT_NEW  := 314 // �������᪮� �������
      human_->ISHOD_NEW := 304 // ��室 = ��� ��६��
      human_->VRACH     := arr_iss[1, 1]
      human_->PRVS      := arr_iss[1, 2]
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
      human_2->NPR_DATE := mNPR_DATE
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
        hu->kod_as  := 0
        hu->u_koef  := 1
        hu->u_kod   := arr_usl_dop[i, 7]
        hu->u_cena  := arr_usl_dop[i, 8]
        hu->is_edit := 0
        hu->date_u  := dtoc4(mn_data)
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
          hu_->ID_U := mo_guid(3,hu_->(recno()))
        endif
        hu_->PROFIL := arr_usl_dop[i, 4]
        hu_->PRVS   := arr_usl_dop[i, 2]
        hu_->kod_diag := mkod_diag
        hu_->zf := ''
        UNLOCK
      next
      if i2 < i1
        for i := i2+1 to i1
          select HU
          goto (arr_usl[i])
          DeleteRec(.t., .f.)  // ���⪠ ����� ��� ����⪨ �� 㤠�����
        next
      endif
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