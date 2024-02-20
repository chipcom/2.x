#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 20.02.24 �।� - ���������� ��� ।���஢���� ���� (���� ���)
Function oms_sluch_PREDN(Loc_kod, kod_kartotek, f_print)
  // Loc_kod - ��� �� �� human.dbf (�᫨ = 0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  // f_print - ������������ �㭪樨 ��� ����
  Static st_N_DATA, st_K_DATA, st_mo_pr := '      ', st_school := 0
  Local L_BEGIN_RSLT := 336
  Local bg := {|o,k| get_MKB10(o, k, .t.) }, arr_del := {}, mrec_hu := 0, ;
        buf := savescreen(), tmp_color := setcolor(), a_smert := {}, ;
        p_uch_doc := '@!', pic_diag := '@K@!', arr_usl := {}, ;
        i, j, k, n, s, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
        pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod, ;
        tmp_help := chm_help_code, fl_write_sluch := .f., _y, _m, _d, t_arr[2]
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
  Private mkod := Loc_kod, mtip_h, is_talon := .f., ;
          mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0), ;
    M1LPU := glob_uch[1], MLPU, ;
    M1OTD := glob_otd[1], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MUCH_DOC    := space(10)         , ; // ��� � ����� ��⭮�� ���㬥��
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
    m1rslt  := L_BEGIN_RSLT + 1 , ; // १���� (��᢮��� I ��㯯� ���஢��)
    m1ishod := 306      , ; // ��室 = �ᬮ��
    MN_DATA := st_N_DATA         , ; // ��� ��砫� ��祭��
    MK_DATA := st_K_DATA         , ; // ��� ����砭�� ��祭��
    MVRACH := space(10)         , ; // 䠬���� � ���樠�� ���饣� ���
    M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
    m1povod  := 4, ;   // ��䨫����᪨�
    m1travma := 0, ;
    m1USL_OK :=  USL_OK_POLYCLINIC, ; // �����������
    m1VIDPOM :=  1, ; // ��ࢨ筠�
    m1PROFIL := 68, ; // ��������
    m1IDSP   := 17   // �����祭�� ��砩 � �-��
  //
  Private mm_gr_fiz := {{'I', 1}, {'II', 2}, {'III', 3}, {'IV', 4}, {'�� ����饭', 0}}
  //
  Private metap := 1, mperiod := 0, mshifr_zs := '', ;
          mMO_PR := space(10), m1MO_PR := st_mo_pr, ; // ��� �� �ਪ९�����
          mschool := space(10), m1school := st_school, ; // ��� ���.��०�����
          mtip_school := space(10), m1tip_school := 0, ; // ⨯ ���.��०�����
          mGRUPPA := 0, ;    // ��㯯� ���஢�� ��᫥ ���-��
          mGR_FIZ, m1GR_FIZ := 1, ;
          mstep2, m1step2 := 0
  Private mvar, m1var, m1lis := 0
  //
  for i := 1 to count_predn_arr_iss // ��᫥�������
    mvar := 'MTAB_NOMiv' + lstr(i)
    Private &mvar := 0
    mvar := 'MTAB_NOMia' + lstr(i)
    Private &mvar := 0
    mvar := 'MDATEi' + lstr(i)
    Private &mvar := ctod('')
    mvar := 'MREZi' + lstr(i)
    Private &mvar := space(17)
    m1var := 'M1LIS' + lstr(i)
    Private &m1var := 0
    mvar := 'MLIS' + lstr(i)
    Private &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
  next
  for i := 1 to count_predn_arr_osm // �ᬮ���
    mvar := 'MTAB_NOMov' + lstr(i)
    Private &mvar := 0
    mvar := 'MTAB_NOMoa' + lstr(i)
    Private &mvar := 0
    mvar := 'MDATEo' + lstr(i)
    Private &mvar := ctod('')
    mvar := 'MKOD_DIAGo' + lstr(i)
    Private &mvar := space(6)
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
  next
  //
  afill(adiag_talon, 0)
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
      mnameismo := ret_inogSMO_name( 1, , .t.) // ������ � �������
    endif
    // �஢�ઠ ��室� = ������
    select HUMAN
    set index to (dir_server + 'humankk')
    arr_patient_died_during_treatment( mkod_k, loc_kod )
    set index to
//    a_smert := result_is_death(mkod_k, Loc_kod)
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
    for i := 1 to 16
      adiag_talon[i] := int(val(substr(human_->DISPANS, i, 1)))
    next
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
    metap      := human->ishod - 302
    mGRUPPA    := human_->RSLT_NEW - L_BEGIN_RSLT
    if metap == 2
      m1step2 := 1
    endif
    //
    larr_i := array(count_predn_arr_iss)
    afill(larr_i, 0)
    larr_o := array(count_predn_arr_osm)
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
      if left(lshifr, 5) == '72.3.'
        mshifr_zs := lshifr
      else
        fl := .t.
        for i := 1 to count_predn_arr_iss
          if npred_arr_issled[i, 1] == lshifr
            fl := .f.
            larr_i[i] := hu->(recno())
            exit
          endif
        next
        if fl
          for i := 1 to count_predn_arr_osm
            if f_profil_ginek_otolar(npred_arr_osmotr[i, 4], hu_->PROFIL)
              fl := .f.
              larr_o[i] := hu->(recno())
              exit
            endif
          next
        endif
        if fl .and. eq_any(hu_->PROFIL, 68, 57)
          aadd(larr_p, {hu->(recno()), c4tod(hu->date_u)})
        endif
      endif
      aadd(arr_usl, hu->(recno()))
      select HU
      skip
    enddo
    if len(larr_p) > 1 // �᫨ �ᬮ�� ������� I �⠯� ������� ������� II �⠯�
      asort(larr_p, , , {|x,y| x[2] < y[2]})
      asize(larr_p, 2) // ��१��� ��譨� ����
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
            if glob_yes_kdp2[TIP_LU_PREDN] .and. ascan(glob_arr_usl_LIS, npred_arr_issled[i, 1]) > 0 ;
                                           .and. hu->is_edit == 1
              &m1var := 1
            endif
            mvar := 'mlis' + lstr(i)
            &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
          elseif !empty(hu_->kod_diag) .and. !(left(hu_->kod_diag, 1) == 'Z')
            mvar := 'MKOD_DIAG' + bukva + lstr(i)
            &mvar := hu_->kod_diag
          endif
        endif
      next
    next
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name( 2, @rec_inogSMO, .t.) // ������ � �������
    endif
    read_arr_PredN(Loc_kod)
  endif
  if !(left(msmo, 2) == '34') // �� ������ࠤ᪠� �������
    m1ismo := msmo
    msmo := '34'
  endif
  close databases
  is_talon := .t.
  fv_date_r( iif(Loc_kod>0, mn_data,) )
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
  if !empty(m1MO_PR)
    mMO_PR := ret_mo(m1MO_PR)[_MO_SHORT_NAME]
  endif
  mschool := inieditspr(A__POPUPMENU, dir_server + 'mo_schoo', m1school)
  mtip_school := inieditspr(A__MENUVERT, mm_tip_school, m1tip_school)
  mstep2  := inieditspr(A__MENUVERT, mm_danet, m1step2)
  mgr_fiz := inieditspr(A__MENUVERT, mm_gr_fiz, m1gr_fiz)
  //
  if !empty(f_print)
    return &(f_print + '(' + lstr(Loc_kod) + ',' + lstr(kod_kartotek) + ',' + lstr(mvozrast) + ')')
  endif
  //
  str_1 := ' ���� �।���⥫쭮�� �ᬮ�� ��ᮢ��襭����⭨�'
  if Loc_kod == 0
    str_1 := '����������' + str_1
    mtip_h := yes_vypisan
  else
    str_1 := '������஢����' + str_1
  endif
  setcolor(color8)
  Private gl_area := {1, 0, maxrow() - 1, maxcol(), 0}
  setcolor(cDataCGet)
  make_diagP(1)  // ᤥ���� '��⨧����' ��������
  Private num_screen := 1
  do while .t.
    close databases
    @ 0, 0 say padc(str_1, 80) color 'B/BG*'
    j := 1
    myclear(j)
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 say padl('���� ��� � ' + lstr(Loc_kod), 29) color color14
    endif
    @ j, 0 say '��࠭ ' + lstr(num_screen) color color8
    if num_screen > 1
      mperiod := 0
      s := alltrim(mfio)
      for i := 1 to len(npred_arr_1_etap)
        if npred_arr_1_etap[i, 1] == m1tip_school .and. ;
              between(mvozrast, npred_arr_1_etap[i, 2], npred_arr_1_etap[i, 3])
          mperiod := i
          s += ' (' + npred_arr_1_etap[i, 6] + ')'
          exit
        endif
      next
      @ j, 80 - len(s) say s color color14
      if !between(mperiod, 1, 4)
        func_error(4, '�� 㤠���� ��।����� �����⭮� ��ਮ�!')
        num_screen := 1
        loop
      endif
    endif
    if num_screen == 1 //
      @ ++j, 1 say '��०�����' get mlpu when .f. color cDataCSay
      @ row(),col()+2 say '�⤥�����' get motd when .f. color cDataCSay
      //
      ++j
      @ ++j, 1 say '���' get mfio_kart ;
          reader {|x| menu_reader(x, {{|k, r, c| get_fio_kart(k, r, c)}}, A__FUNCTION, , , .f.)} ;
          valid {|g,o| update_get('mdate_r'), ;
                      update_get('mkomu'), update_get('mcompany') }
      @ row(), col() + 5 say '�.�.' get mdate_r when .f. color color14
      ++j
      @ ++j, 1 say '�ਭ���������� ����' get mkomu ;
          reader {|x|menu_reader(x, mm_komu, A__MENUVERT, , , .f.)} ;
          valid {|g, o| f_valid_komu(g, o) } ;
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
      ++j
      @ ++j, 1 to j, 78
      ++j
      @ ++j, 1 say '�ப� �ᬮ��' get mn_data ;
          valid {|g| f_k_data(g, 1), ;
                    iif(mvozrast < 18, nil, func_error(4, '�� ����� ��樥��!')), ;
                        msvozrast := padr(count_ymd(mdate_r, mn_data), 40), ;
                    .t.;
                 }
      @ row(), col() + 1 say '-' get mk_data valid {|g|f_k_data(g, 2)}
      @ row(), col() + 3 get msvozrast when .f. color color14
      @ ++j, 1 say '� ���㫠�୮� �����' get much_doc picture '@!' ;
          when !(is_uchastok == 1 .and. is_task(X_REGIST)) ;
                    .or. mem_edit_ist == 2
      ++j
      @ ++j, 1 say '�� �ਪ९�����' get mMO_PR ;
          reader {|x|menu_reader(x, {{|k, r, c|f_get_mo(k, r, c)}}, A__FUNCTION, , , .f.)}
      ++j
      @ ++j, 1 say '��饮�ࠧ���⥫쭮� ��०�����' get mschool ;
          reader {|x|menu_reader(x, {dir_server + 'mo_schoo', , , , , ,'��饮�ࠧ���⥫�� ���-��','B/BG'},A__POPUPBASE1, , , .f.)}
      @ ++j, 1 say '��� ��饮�ࠧ���⥫쭮�� ��०�����' get mtip_school ;
          reader {|x|menu_reader(x,mm_tip_school, A__MENUVERT, , , .f.)}
      status_key('^<Esc>^ ��室 ��� ����� ^<PgDn>^ �� 2-� ��࠭���')
      if !empty(a_smert)
        n_message(a_smert, , 'GR+/R', 'W+/R', , , 'G+/R')
      endif
    elseif num_screen == 2 //
      ar := npred_arr_1_etap[mperiod]
      @ ++j, 1 say 'I �⠯ ������������ ��᫥�������       ��� ����.  ���     �������' color 'RB+/B'
      if mem_por_ass == 0
        @ j, 45 say space(6)
      endif
      for i := 1 to count_predn_arr_iss
        fl := .t.
        if fl .and. !empty(npred_arr_issled[i, 2])
          fl := (mpol == npred_arr_issled[i, 2])
        endif
        if fl
          fl := (ascan(ar[5], npred_arr_issled[i, 1]) > 0)
        endif
        if fl
          mvarv := 'MTAB_NOMiv' + lstr(i)
          mvara := 'MTAB_NOMia' + lstr(i)
          mvard := 'MDATEi' + lstr(i)
          mvarr := 'MREZi' + lstr(i)
          mvarlis := 'MLIS' + lstr(i)
          if empty(&mvard)
            &mvard := mn_data
          endif
          fl_kdp2 := .f.
          if glob_yes_kdp2[TIP_LU_PREDN] .and. ascan(glob_arr_usl_LIS, npred_arr_issled[i, 1]) > 0
            fl_kdp2 := .t.
          endif
          @ ++j, 1 say padr(npred_arr_issled[i, 3], 38)
          if fl_kdp2
            @ j, 34 get &mvarlis reader {|x|menu_reader(x, mm_kdp2, A__MENUVERT, , , .f.)}
          endif
          @ j, 39 get &mvarv pict '99999' valid {|g| v_kart_vrach(g) }
        if mem_por_ass > 0
          @ j, 45 get &mvara pict '99999' valid {|g| v_kart_vrach(g) }
        endif
          @ j, 51 get &mvard
          @ j, 62 get &mvarr
        endif
      next
      @ ++j, 1 say 'I �⠯ ������������ �ᬮ�஢           ��� ����.  ���     �������' color 'RB+/B'
      if mem_por_ass == 0
        @ j, 45 say space(6)
      endif
      for i := 1 to count_predn_arr_osm
        fl := .t.
        if fl .and. !empty(npred_arr_osmotr[i, 2])
          fl := (mpol == npred_arr_osmotr[i, 2])
        endif
        if fl
          fl := (ascan(ar[4], npred_arr_osmotr[i, 1]) > 0)
        endif
        if fl
          mvarv := 'MTAB_NOMov' + lstr(i)
          mvara := 'MTAB_NOMoa' + lstr(i)
          mvard := 'MDATEo' + lstr(i)
          mvarz := 'MKOD_DIAGo' + lstr(i)
          if empty(&mvard)
            &mvard := mn_data
          endif
          @ ++j, 1 say padr(npred_arr_osmotr[i, 3], 38)
          @ j, 39 get &mvarv pict '99999' valid {|g| v_kart_vrach(g) }
          if mem_por_ass > 0
            @ j, 45 get &mvara pict '99999' valid {|g| v_kart_vrach(g) }
          endif
          @ j, 51 get &mvard
          @ j, 62 get &mvarz picture pic_diag ;
                reader {|o|MyGetReader(o, bg)} valid val1_10diag(.t., .f., .f., mn_data, mpol)
        endif
      next
      if empty(MDATEp1)
        MDATEp1 := mn_data
      endif
      @ ++j, 1 say padr('������� (��� ��饩 �ࠪ⨪�)', 38) color color8
      @ j, 39 get MTAB_NOMpv1 pict '99999' valid {|g| v_kart_vrach(g) }
      if mem_por_ass > 0
        @ j, 45 get MTAB_NOMpa1 pict '99999' valid {|g| v_kart_vrach(g) }
      endif
      @ j, 51 get MDATEp1
      @ j, 62 get MKOD_DIAGp1 picture pic_diag ;
            reader {|o|MyGetReader(o, bg)} valid val1_10diag(.t., .f., .f., mn_data, mpol)
      //
      status_key('^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 1-� ��࠭��� ^<PgDn>^ �� 3-� ��࠭���')
    elseif num_screen == 3 //
      @ ++j, 1 say '���������� ��祡�� �ᬮ��� II �⠯� ?' get mstep2 ;
                 reader {|x|menu_reader(x,mm_danet, A__MENUVERT, , , .f.)}
      ++j
      ar := npred_arr_1_etap[mperiod]
      @ ++j, 1 say 'II �⠯ ������������ �ᬮ�஢          ��� ����.  ���     �������' color 'RB+/B'
      if mem_por_ass == 0
        @ j, 45 say space(6)
      endif
      for i := 1 to count_predn_arr_osm
        fl := .t.
        if fl .and. !empty(npred_arr_osmotr[i, 2])
          fl := (mpol == npred_arr_osmotr[i, 2])
        endif
        if fl
          fl := (ascan(ar[4], npred_arr_osmotr[i, 1]) == 0)
        endif
        if fl
          mvarv := 'MTAB_NOMov' + lstr(i)
          mvara := 'MTAB_NOMoa' + lstr(i)
          mvard := 'MDATEo' + lstr(i)
          mvarz := 'MKOD_DIAGo' + lstr(i)
          @ ++j, 1 say padr(npred_arr_osmotr[i, 3], 38)
          @ j, 39 get &mvarv pict '99999' valid {|g| v_kart_vrach(g) } when m1step2 == 1
          if mem_por_ass > 0
            @ j, 45 get &mvara pict '99999' valid {|g| v_kart_vrach(g) } when m1step2 == 1
          endif
          @ j, 51 get &mvard when m1step2 == 1
          @ j, 62 get &mvarz picture pic_diag ;
                 reader {|o|MyGetReader(o, bg)} valid val1_10diag(.t., .f., .f., mn_data, mpol) ;
                 when m1step2 == 1
        endif
      next
      @ ++j, 1 say padr('������� (��� ��饩 �ࠪ⨪�)', 38) color color8
      @ j, 39 get MTAB_NOMpv2 pict '99999' valid {|g| v_kart_vrach(g) } when m1step2 == 1
      if mem_por_ass > 0
        @ j, 45 get MTAB_NOMpa2 pict '99999' valid {|g| v_kart_vrach(g) } when m1step2 == 1
      endif
      @ j, 51 get MDATEp2 when m1step2 == 1
      @ j, 62 get MKOD_DIAGp2 picture pic_diag ;
             reader {|o|MyGetReader(o, bg)} valid val1_10diag(.t., .f., .f., mn_data, mpol) ;
             when m1step2 == 1
      ++j
      @ ++j, 1 say '������ ���ﭨ� �������� �� १���⠬ �஢������ �ᬮ��' get mGRUPPA pict '9'
      @ ++j, 1 say '                ����樭᪠� ������ ��� ������ 䨧�����ன' get mGR_FIZ ;
              reader {|x|menu_reader(x, mm_gr_fiz, A__MENUVERT, , , .f.)}
      status_key('^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 2-� ��࠭��� ^<PgDn>^ ������')
    endif
    count_edit += myread()
    if num_screen == 3
      if lastkey() == K_PGUP
        k := 3
        --num_screen
      else
        k := f_alert({padc('�롥�� ����⢨�', 60,'.')}, ;
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
        if (k := f_alert({padc('�롥�� ����⢨�', 60,'.')}, ;
                         {' ��室 ��� ����� ', ' ������ � ।���஢���� '}, ;
                         1, 'W+/N', 'N+/N', maxrow() - 2, , 'W+/N, N/BG' )) == 2
          k := 3
        endif
      else
        k := 3
        ++num_screen
      endif
    endif
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
        func_error(4, '�� ��������� ������������ '+s)
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
        func_error(4, '�।���⥫�� �ᬮ�� ������ ���᫮�� ��樥���!')
        loop
      endif
      if !between(mperiod, 1, 4)
        func_error(4, '�� 㤠���� ��।����� �����⭮� ��ਮ�!')
        num_screen := 1
        loop
      endif
      if empty(mk_data)
        func_error(4, '�� ������� ��� ����砭�� ��祭��.')
        loop
      elseif year(mk_data) == 2018
        func_error(4, '�।���⥫�� �ᬮ��� � 2018 ���� ����� �� �஢������')
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
      if empty(m1school)
        func_error(4, '�� ������� ��饮�ࠧ���⥫쭮� ��०�����.')
        loop
      endif
      if mvozrast < 1
        mdef_diagnoz := 'Z00.1 '
      elseif mvozrast < 14
        mdef_diagnoz := 'Z00.2 '
      else
        mdef_diagnoz := 'Z00.3 '
      endif
      arr_iss := array(count_predn_arr_iss, 10)
      afillall(arr_iss, 0)
      R_Use(dir_exe + '_mo_mkb', cur_dir + '_mo_mkb', 'MKB_10')
      R_Use(dir_server + 'mo_pers', dir_server + 'mo_pers', 'P2')
      num_screen := 2
      max_date1 := max_date2 := mn_data
      d12 := mn_data - 1
      k := 0
      if metap == 2
        do while ++d12 <= mk_data
          if is_work_day(d12)
            if ++k == 10
              exit
            endif
          endif
        enddo
      endif
      fl := .t.
      ar := npred_arr_1_etap[mperiod]
      for i := 1 to count_predn_arr_iss
        mvart := 'MTAB_NOMiv' + lstr(i)
        mvara := 'MTAB_NOMia' + lstr(i)
        mvard := 'MDATEi' + lstr(i)
        mvarr := 'MREZi' + lstr(i)
        _fl_ := .t.
        if _fl_ .and. !empty(npred_arr_issled[i, 2])
          _fl_ := (mpol == npred_arr_issled[i, 2])
        endif
        if _fl_
          _fl_ := (ascan(ar[5], npred_arr_issled[i, 1]) > 0)
        endif
        if _fl_
          if empty(&mvard)
            fl := func_error(4, '�� ������� ��� ���-�� "' + npred_arr_issled[i, 3] + '"')
          elseif metap == 2 .and. &mvard > d12
            fl := func_error(4, '��� ���-�� "' + npred_arr_issled[i, 3] + '" �� � I-�� �⠯� (> 10 ����)')
          elseif empty(&mvart)
            fl := func_error(4, '�� ������ ��� � ���-�� "' + npred_arr_issled[i, 3] + '"')
          endif
        endif
        if _fl_ .and. !emptyany(&mvard, &mvart)
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
          arr_iss[i, 4] := npred_arr_issled[i, 5] // ��䨫�
          arr_iss[i, 5] := npred_arr_issled[i, 1] // ��� ��㣨
          arr_iss[i, 6] := mdef_diagnoz
          arr_iss[i, 9] := &mvard
          m1var := 'm1lis' + lstr(i)
          if glob_yes_kdp2[TIP_LU_PREDN] .and. &m1var == 1
            arr_iss[i, 10] := 1 // �஢� �஢����� � ���2
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
      arr_osm1 := array(count_predn_arr_osm, 9)
      afillall(arr_osm1, 0)
      for i := 1 to count_predn_arr_osm
        _fl_ := .t.
        if _fl_ .and. !empty(npred_arr_osmotr[i, 2])
          _fl_ := (mpol == npred_arr_osmotr[i, 2])
        endif
        if _fl_
          _fl_ := (ascan(ar[4], npred_arr_osmotr[i, 1]) > 0)
        endif
        if _fl_
          mvart := 'MTAB_NOMov' + lstr(i)
          mvara := 'MTAB_NOMoa' + lstr(i)
          mvard := 'MDATEo' + lstr(i)
          mvarz := 'MKOD_DIAGo' + lstr(i)
          if empty(&mvard)
            fl := func_error(4, '�� ������� ��� �ᬮ�� I �⠯� "' + npred_arr_osmotr[i, 3] + '"')
          elseif metap == 2 .and. &mvard > d12
            fl := func_error(4, '��� �ᬮ�� "' + npred_arr_osmotr[i, 3] + '" �� � I-�� �⠯� (> 10 ����)')
          elseif empty(&mvart)
            fl := func_error(4, '�� ������ ��� � �ᬮ�� I �⠯� "' + npred_arr_osmotr[i, 3] + '"')
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
            arr_osm1[i, 4] := npred_arr_osmotr[i, 4] // ��䨫�
            arr_osm1[i, 5] := npred_arr_osmotr[i, 1] // ��� ��㣨
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
        fl := func_error(4, '��� �ᬮ�� ������� I �⠯� �� 㬥頥��� � 10 ࠡ��� ����')
      endif
      if !fl
        loop
      endif
      metap := 1
      arr_osm2 := array(count_predn_arr_osm, 9)
      afillall(arr_osm2, 0)
      if m1step2 == 1
        num_screen := 3
        fl := .t.
        if !emptyany(MTAB_NOMpv2, MDATEp2)
          metap := 2
        endif
        ku := 0
        for i := 1 to count_predn_arr_osm
          _fl_ := .t.
          if _fl_ .and. !empty(npred_arr_osmotr[i, 2])
            _fl_ := (mpol == npred_arr_osmotr[i, 2])
          endif
          if _fl_
            _fl_ := (ascan(ar[4], npred_arr_osmotr[i, 1]) == 0)
          endif
          if _fl_
            mvart := 'MTAB_NOMov' + lstr(i)
            mvara := 'MTAB_NOMoa' + lstr(i)
            mvard := 'MDATEo' + lstr(i)
            mvarz := 'MKOD_DIAGo' + lstr(i)
            if !empty(&mvard) .and. empty(&mvart)
              fl := func_error(4, '�� ������ ��� � �ᬮ�� II �⠯� "' + npred_arr_osmotr[i, 3] + '"')
            elseif !empty(&mvart) .and. empty(&mvard)
              fl := func_error(4, '�� ������� ��� �ᬮ�� II �⠯� "' + npred_arr_osmotr[i, 3] + '"')
            elseif !emptyany(&mvard, &mvart)
              ++ku
              metap := 2
              if &mvard < MDATEp1
                fl := func_error(4, '��� �ᬮ�� II �⠯� "' + npred_arr_osmotr[i, 3] + '" ����� I �⠯�')
              endif
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
              arr_osm2[i, 4] := npred_arr_osmotr[i, 4] // ��䨫�
              arr_osm2[i, 5] := npred_arr_osmotr[i, 1] // ��� ��㣨
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
              arr_osm2[i, 9] := &mvard
              max_date2 := max(max_date2, arr_osm2[i, 9])
            endif
          endif
          if !fl
            exit
          endif
        next
        if fl .and. metap == 2
          if emptyany(MTAB_NOMpv2,MDATEp2)
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
      num_screen := 3
      if between(mGRUPPA, 1, 5)
        m1rslt := L_BEGIN_RSLT + mGRUPPA
      else
        func_error(4, '������ ���ﭨ� �������� �� १���⠬ �஢������ ����ᬮ�� - �� 1 �� 5')
        loop
      endif
      //
      err_date_diap(mn_data, '��� ��砫� ��祭��')
      err_date_diap(mk_data, '��� ����砭�� ��祭��')
      //
      if mem_op_out == 2 .and. yes_parol
        box_shadow(19, 10, 22, 69, cColorStMsg)
        str_center(20, '������ "' + fio_polzovat + '".', cColorSt2Msg)
        str_center(21, '���� ������ �� ' + date_month(sys_date), cColorStMsg)
      endif
      mywait('����. �ந�������� ������ ���� ����...')
      m1lis := 0
      if glob_yes_kdp2[TIP_LU_PREDN]
        for i := 1 to count_predn_arr_iss
          if valtype(arr_iss[i, 9]) == 'D' .and. arr_iss[i, 9] >= mn_data .and. len(arr_iss[i]) > 9 ;
                                          .and. valtype(arr_iss[i, 10]) == 'N' .and. arr_iss[i, 10] == 1
            m1lis := 1 // � ࠬ��� ��ᯠ��ਧ�樨
          endif
        next
      endif
      // ������� ������� I �⠯�
      aadd(arr_osm1, add_pediatr_PredN(MTAB_NOMpv1, MTAB_NOMpa1, MDATEp1, MKOD_DIAGp1))
      if metap == 1
        for i := 1 to len(arr_osm1)
          if valtype(arr_osm1[i, 5])=='C' .and. left(arr_osm1[i, 5], 5)=='2.86.'
            if eq_any(alltrim(arr_osm1[i, 5]),'2.86.14','2.86.15') // �������, ��� ��饩 �ࠪ⨪�
              arr_osm1[i, 5] := '2.3.2'
            else
              arr_osm1[i, 5] := '2.3.1'
            endif
          endif
        next
        i := len(arr_osm1)
        m1vrach  := arr_osm1[i, 1]
        m1prvs   := arr_osm1[i, 2]
        m1assis  := arr_osm1[i, 3]
        m1PROFIL := arr_osm1[i, 4]
        MKOD_DIAG := padr(arr_osm1[i, 6], 6)
        aadd(arr_osm1, array(9))
        i := len(arr_osm1)
        arr_osm1[i, 1] := arr_osm1[i - 1, 1]
        arr_osm1[i, 2] := arr_osm1[i - 1, 2]
        arr_osm1[i, 3] := arr_osm1[i - 1, 3]
        arr_osm1[i, 4] := 48 // ����樭᪨� �ᬮ�ࠬ (�।���⥫��, ��ਮ���᪨�)
        arr_osm1[i, 5] := ret_shifr_zs_PredN(mperiod)
        arr_osm1[i, 6] := arr_osm1[i - 1, 6]
        arr_osm1[i, 9] := mn_data
      else  // metap := 2
        // ������� ������� II �⠯�
        aadd(arr_osm2, add_pediatr_PredN(MTAB_NOMpv2, MTAB_NOMpa2, MDATEp2, MKOD_DIAGp2))
        i := len(arr_osm2)
        m1vrach  := arr_osm2[i, 1]
        m1prvs   := arr_osm2[i, 2]
        m1assis  := arr_osm2[i, 3]
        m1PROFIL := arr_osm2[i, 4]
        MKOD_DIAG := padr(arr_osm2[i, 6], 6)
        for i := 1 to len(arr_osm1)
          if valtype(arr_osm1[i, 5]) == 'C' .and. (j := ascan(npred_arr_osmotr_KDP2, {|x| x[1] == arr_osm1[i, 5]})) > 0
            arr_osm1[i, 5] := npred_arr_osmotr_KDP2[j, 2]
          endif
        next
        for i := 1 to len(arr_osm2)
          if valtype(arr_osm2[i, 5]) == 'C' .and. (j := ascan(npred_arr_osmotr_KDP2, {|x| x[1] == arr_osm2[i, 5]})) > 0
            arr_osm2[i, 5] := npred_arr_osmotr_KDP2[j, 2]
          endif
        next
      endif
      select MKB_10
      find (MKOD_DIAG)
      if found() .and. !between_date(mkb_10->dbegin, mkb_10->dend, mk_data)
        MKOD_DIAG := mdef_diagnoz // �᫨ ������� �� �室�� � ���, � 㬮�砭��
      endif
      for i := 1 to count_predn_arr_iss
        if npred_arr_issled[i, 4] == 2 .and. ascan(npred_arr_issled[i, 6], metap) > 0
          aadd(arr_iss,array(9))
          j := len(arr_iss)
          arr_iss[j, 1] := m1vrach
          arr_iss[j, 2] := m1prvs
          arr_iss[j, 3] := m1assis
          arr_iss[j, 4] := m1PROFIL
          arr_iss[j, 5] := npred_arr_issled[i, 1] // ��� ��㣨
          arr_iss[j, 6] := mdef_diagnoz
          arr_iss[j, 9] := mk_data
        endif
      next
      make_diagP(2)  // ᤥ���� '��⨧����' ��������
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
          arr_iss[i, 7] := foundOurUsluga(arr_iss[i, 5], mk_data, arr_iss[i, 4], M1VZROS_REB, @mu_cena)
          arr_iss[i, 8] := mu_cena
          mcena_1 += mu_cena
          aadd(arr_usl_dop, arr_iss[i])
        endif
      next
      for i := 1 to len(arr_osm1)
        if valtype(arr_osm1[i, 5]) == 'C'
          arr_osm1[i, 7] := foundOurUsluga(arr_osm1[i, 5], mk_data, arr_osm1[i, 4], M1VZROS_REB, @mu_cena)
          arr_osm1[i, 8] := mu_cena
          mcena_1 += mu_cena
          aadd(arr_usl_dop, arr_osm1[i])
        endif
      next
      if metap == 2
        for i := 1 to len(arr_osm2)
          if valtype(arr_osm2[i, 5]) == 'C'
            arr_osm2[i, 7] := foundOurUsluga(arr_osm2[i, 5], mk_data, arr_osm2[i, 4], M1VZROS_REB, @mu_cena)
            arr_osm2[i, 8] := mu_cena
            mcena_1 += mu_cena
            aadd(arr_usl_dop, arr_osm2[i])
          endif
        next
      endif
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
      st_school := m1school
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
      human->KOD_DIAG   := mkod_diag     // ��� 1-�� ��.�������
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
      human->ishod      := 302+metap
      human->bolnich    := 0
      human->date_b_1   := ''
      human->date_b_2   := ''
      human_->RODIT_DR  := ctod('')
      human_->RODIT_POL := ''
      s := '' ; aeval(adiag_talon, {|x| s += str(x, 1) })
      human_->DISPANS   := s
      human_->STATUS_ST := ''
      //human_->POVOD     := m1povod
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
        hu_->kod_diag := arr_usl_dop[i, 6]
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
      save_arr_PredN(mkod)
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