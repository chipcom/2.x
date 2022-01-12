#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

******* 06.01.22 �஢�ઠ �� ����室������ ����� ������⢥���� �९��⮢
function check_oms_sluch_lek_pr(mkod_human)
  // mkod_human - ��� �� �� human

  local vidPom, m1USL_OK, m1PROFIL, last_date, mdiagnoz, d1, d2, ad_cr
  local retFl := .f.

  G_Use(dir_server + "human_2", , "HUMAN_2")
  G_Use(dir_server + "human_", , "HUMAN_")
  G_Use(dir_server + "human", {dir_server + "humank", ;
                              dir_server + "humankk", ;
                              dir_server + "humano"}, "HUMAN")
  set relation to recno() into HUMAN_, to recno() into HUMAN_2

  find (str(mkod_human, 7))
  d1 := human->n_data
  d2 := human->k_data
  last_date := human->n_data
  m1USL_OK := human_->USL_OK
  m1PROFIL := human_->PROFIL
  mdiagnoz := diag_to_array(, , , , .t.)
  if len(mdiagnoz) == 0
    mdiagnoz := {space(6)}
  endif
  human_kod_diag := mdiagnoz[1]
  vidPom := human_->VIDPOM
  ad_cr := lower(alltrim(human_2->PC3))

  retFl := (d2 >= d_01_01_2022) .and. ((alltrim(human_kod_diag) == 'U07.1') ;
    .or. (alltrim(human_kod_diag) == 'U07.2')) .and. (M1USL_OK == 1) ;
    .and. (M1PROFIL != 158) .and. (vidPom != 32) .and. (ad_cr != 'stt5')

  HUMAN_2->(dbCloseArea())    
  HUMAN_->(dbCloseArea())    
  HUMAN->(dbCloseArea())    

  return retFl

******* 09.01.22 ����� ������⢥���� �९��⮢
function oms_sluch_lek_pr(mkod_human, mkod_kartotek, fl_edit)
  // mkod_human - ��� �� �� human
  // mkod_kartotek - ��� �� �� kartotek
  local aDbf, buf := savescreen(), l_color, fl_found
  local mtitle, tmp_color := setcolor(color1)
  local nBegin, count, strWeight

  private mSeverity, m1Severity := 0

  default fl_edit to .f.

  G_Use(dir_server + "human_2", , "HUMAN_2")
  G_Use(dir_server + "human_", , "HUMAN_")
  G_Use(dir_server + "human", {dir_server + "humank", ;
                              dir_server + "humankk", ;
                              dir_server + "humano"}, "HUMAN")
  set relation to recno() into HUMAN_, to recno() into HUMAN_2

  find (str(mkod_human, 7)) // ��⠭�� �� ���� ���

  G_Use(dir_server + 'human_lek_pr', dir_server + 'human_lek_pr', 'LEK_PR')

  adbf := {;
    {"KOD_HUM" ,   "N",    7,     0},; // ��� ���� ���� �� 䠩�� "human"
    {"DATE_INJ",   "D",    8,     0},; // ��� �������� ������⢥����� �९���
    {"SEVERITY",   "N",    5,     0},; // ��� �殮�� �祭�� ����������� �� �ࠢ�筨�� _mo_severity.dbf
    {"SCHEME"  ,   "C",   10,     0},; // �奬� ��祭�� ��樥�� V030
    {"SCHEDRUG",   "C",   10,     0},; // ��⠭�� �奬� ��祭�� � ��㯯� �९��⮢ V032
    {"REGNUM"  ,   "C",    6,     0},; // ������⢥����� �९���
    {"ED_IZM"  ,   "N",    3,     0},; // ������ ����७�� ���� ������⢥����� �९���
    {"DOZE"    ,   "N",    5,     2},; // ���� �������� ������⢥����� �९���
    {"METHOD"  ,   "N",    3,     0},; // ���� �������� ������⢥����� �९���
    {"COL_INJ" ,   "N",    5,     0},; // ������⢮ �������� � �祭�����, 㪠������� � DATA_INJ
    {"COD_MARK",   "C",  100,     0},;  // ��� ��ન஢�� ������⢥����� �९���
    {"NUMBER"  ,   "N",    3,     0},;
    {"REC_N"   ,   "N",    8,     0};
  }
  dbcreate(cur_dir + 'tmp_lek_pr', adbf)
  use (cur_dir + 'tmp_lek_pr') new alias TMP

  count := 0
  select LEK_PR
  find (str(mkod_human, 7))
  if found()
    do while LEK_PR->KOD_HUM == mkod_human .and. !eof()
      count++
      select TMP
      append blank
      tmp->NUMBER   := count
      tmp->KOD_HUM  := LEK_PR->KOD_HUM
      tmp->DATE_INJ := LEK_PR->DATE_INJ
      tmp->SEVERITY := LEK_PR->SEVERITY
      tmp->SCHEME   := LEK_PR->CODE_SH
      tmp->SCHEDRUG := LEK_PR->SCHEDRUG
      tmp->REGNUM   := LEK_PR->REGNUM
      tmp->ED_IZM   := LEK_PR->ED_IZM
      tmp->DOZE     := LEK_PR->DOSE_INJ
      tmp->METHOD   := LEK_PR->METHOD_I
      tmp->COL_INJ  := LEK_PR->COL_INJ
      // tmp->COD_MARK := LEK_PR->COD_MARK
      tmp->REC_N    :=  LEK_PR->(recno())
      LEK_PR->(dbSkip())
    enddo
  endif
  fl_found := (tmp->(lastrec()) > 0)

  cls
  pr_1_str("������⢥��� �९���� < " + fio_plus_novor() + " >")
  @ 1,50 say padl("���� ��� � " + lstr(mkod_human), 29) color color14
  l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"

  setcolor(color1)

  nBegin := 3

  if fl_found
    keyboard chr(K_RIGHT)
  else
    keyboard chr(K_INS)
  endif

  mtitle := f_srok_lech(human->n_data,human->k_data,human_->usl_ok)  
  Alpha_Browse(nBegin, 0, maxrow() - 2, 79, 'f_oms_sluch_lek_pr', color1, mtitle, col_tit_popup,;
               .f., .t., , "f1oms_sluch_lek_pr", "f2oms_sluch_lek_pr", , ;
               {"�", "�", "�", l_color, .t., 180} )

  LEK_PR->(dbCloseArea())
  TMP->(dbCloseArea())

  HUMAN_2->(dbCloseArea())
  HUMAN_->(dbCloseArea())
  HUMAN->(dbCloseArea())

  setcolor(tmp_color)
  restscreen(buf)
  return nil

***** 08.01.22
Function f_oms_sluch_lek_pr(oBrow)
  Local oColumn, blk_color

  // oColumn := TBColumnNew(" NN; ��",{|| tmp->(recno()) })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("���;�����", ;
      {|| left(dtoc(tmp->DATE_INJ), 5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("�殮-;���  ", ;
      {|| iif(tmp->SEVERITY == 0, space(5), left(ret_severity_name(tmp->SEVERITY), 5)) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  // oColumn := TBColumnNew("�奬�;     ", ;
  //     {|| iif(empty(tmp->SCHEME), space(10), left(ret_schema_V030(tmp->SCHEME), 10)) })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("��� �९���", ;
      {|| iif(empty(tmp->SCHEDRUG), space(15), left(ret_schema_V032(tmp->SCHEDRUG), 15)) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("�९���", ;
      {|| iif(empty(tmp->REGNUM), space(15), left(get_Lek_pr_By_ID(tmp->REGNUM), 15)) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("����",{|| str(tmp->DOZE, 5, 2) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("������", ;
      {|| iif(tmp->ED_IZM == 0, space(10), left(ret_ed_izm_V034(tmp->ED_IZM), 5)) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  
  oColumn := TBColumnNew("���ᮡ;��������", ;
      {|| iif(tmp->METHOD == 0, space(10), left(ret_meth_V035(tmp->METHOD), 10)) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("���",{|| str(tmp->COL_INJ, 3, 0) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  
  status_key("^<Esc>^ ��室; ^<Enter>^ ।-��; ^<Ins>^ ����������; ^<Del>^ 㤠�����")
  return NIL
  
***** 06.01.22
Function f1oms_sluch_lek_pr()
  LOCAL nRow := ROW(), nCol := COL()
  return NIL

****** 12.01.22
function add_lek_pr(dInj, nKey)

  select LEK_PR
  if nKey == K_INS  // �� ���������� ������⢥����� �९���
    AddRec(7)
    select tmp
    append blank
    tmp->NUMBER       := tmp->(recno())
  elseif nKey == K_ENTER    // �� ।��஢���� ������⢥����� �९���
    goto (tmp->REC_N)
    G_RLock(forever)
    select TMP
    goto (number)
  endif

  tmp->REC_N        := LEK_PR->(recno())
  tmp->KOD_HUM      := HUMAN->KOD
  tmp->DATE_INJ     := dInj
  tmp->SEVERITY     := m1SEVERITY
  tmp->SCHEME       := m1SCHEME
  tmp->SCHEDRUG     := m1SCHEDRUG
  tmp->REGNUM       := m1REGNUM
  if ! empty(m1REGNUM)
    tmp->ED_IZM       := m1UNITCODE
    tmp->DOZE         := mDOZE
    tmp->METHOD       := m1METHOD
    tmp->COL_INJ      := mKOLVO
  endif
  // tmp->COD_MARK     := LEK_PR->COD_MARK
  select LEK_PR
  LEK_PR->KOD_HUM     := HUMAN->KOD
  LEK_PR->DATE_INJ    := dInj
  LEK_PR->SEVERITY    := m1SEVERITY
  LEK_PR->CODE_SH     := m1SCHEME
  LEK_PR->SCHEDRUG    := m1SCHEDRUG
  LEK_PR->REGNUM      := m1REGNUM
  if ! empty(m1REGNUM)
    LEK_PR->ED_IZM      := m1UNITCODE
    LEK_PR->DOSE_INJ    := mDOZE
    LEK_PR->METHOD_I    := m1METHOD
    LEK_PR->COL_INJ     := mKOLVO
  endif
  UnLock
  // LEK_PR->COD_MARK
  select tmp
  return nil

****** 12.01.22
function f2oms_sluch_lek_pr(nKey,oBrow)

  LOCAL flag := -1, buf := savescreen(), k_read := 0, count_edit := 0
  local r1 := 10, ix, number
  local last_date := human->n_data
  local flMany := .f., tDate

  do case
    case nKey == K_F9
    case nKey == K_F10
    case nKey == K_INS .or. (nKey == K_ENTER .and. tmp->KOD_HUM > 0)
      private mMNN := .f.
      private arr_lek_pr := {}
      private mdate_u1 := iif(nKey == K_INS, last_date, tmp->DATE_INJ)  // ��� ᮢ���⨬��� � f5editkusl
      private m1SEVERITY := iif(nKey == K_INS, '', tmp->SEVERITY), mSEVERITY
      private m1SCHEME := iif(nKey == K_INS, '', tmp->SCHEME), mSCHEME
      private m1SCHEDRUG := iif(nKey == K_INS, '', tmp->SCHEDRUG), mSCHEDRUG
      private m1UNITCODE := iif(nKey == K_INS, '', tmp->ED_IZM), mUNITCODE
      private m1METHOD := iif(nKey == K_INS, '', tmp->METHOD), mMETHOD
      private m1REGNUM := iif(nKey == K_INS, '', tmp->REGNUM), mREGNUM
      private mDOZE :=  iif(nKey == K_INS, 0.0, tmp->DOZE)
      private mKOLVO :=  iif(nKey == K_INS, 0, tmp->COL_INJ)

      private mdate_end_per := mdate_u1      // human->k_data

      number :=  iif(nKey == K_INS, 0, tmp->NUMBER)


      if nKey == K_ENTER
        mSEVERITY := inieditspr(A__MENUVERT, get_severity(), m1SEVERITY)
        mSCHEME := ret_schema_V030(m1SCHEME)
        mSCHEDRUG := ret_schema_V032(m1SCHEDRUG)
        mREGNUM := get_Lek_pr_By_ID(m1REGNUM)
        mUNITCODE := inieditspr(A__MENUVERT, getV034(), m1UNITCODE)
        mMETHOD := inieditspr(A__MENUVERT, getV035(), m1METHOD)
      endif

      --r1
      box_shadow(r1 - 1, 0, maxrow() - 1, 79, color8, ;
                 iif(nKey == K_INS, "���������� ������ �९���", ;
                                   "������஢���� �९���"), iif(yes_color, "RB+/B", "W/N"))
      do while .t.
        setcolor(cDataCGet)
        ix := 1
        
        if nKey == K_ENTER
          @ r1+ix, 2 say "��� �������� �९���" get mdate_u1 ;
              valid {| g | f5editpreparat(g, 2, 1)}
        else
          @ r1+ix,2 say "��砫� �������� �९���" get mdate_u1 ;
              valid {| g | f5editpreparat(g, 2, 1)}
          @ r1+ix, col() say ", ����砭�� �������� �९���" get mdate_end_per ;
              valid {| g | f5editpreparat(g, 2, 4)}
        endif

        ++ix
        @ r1 + ix,2 say "�⥯��� �殮�� ���ﭨ�" get mSEVERITY ;
              reader {|x|menu_reader(x, get_severity(), A__MENUVERT,,,.f.)}
      
        ++ix
        @ r1 + ix,2 say "�奬� ��祭��" get mSCHEME ;
            reader {|x|menu_reader(x, get_schemas_lech(m1Severity, mdate_u1), A__MENUVERT,,,.f.)} ;
            valid {| g | f5editpreparat(g, 2, 3)}

        ++ix
        @ r1 + ix,2 say "���⠭�� �奬� ��祭�� �९��⠬" get mSCHEDRUG ;
            reader {|x|menu_reader(x, get_group_by_schema_lech(m1SCHEME, mdate_u1), A__MENUVERT,,,.f.)} ;
            valid {| g | f5editpreparat(g, 2, 2)}
            
        ++ix
        @ r1 + ix,2 say "�९���" get mREGNUM ;
            reader {|x|menu_reader(x, arr_lek_pr, A__MENUVERT,,,.f.)} ;
            when mMNN
                
        ++ix
        @ r1 + ix,2 say "����" get mDOZE picture '999.99' ;
            when mMNN
        
        ++ix
        @ r1 + ix,2 say "������ ����७��" get mUNITCODE ;
            reader {|x|menu_reader(x, getV034(), A__MENUVERT,,,.f.)} ;
            valid {|| mUNITCODE := padr(mUNITCODE, 69), .t. } ;
            when mMNN
        
        ++ix
        @ r1 + ix,2 say "���ᮡ ��������" get mMETHOD ;
            reader {|x|menu_reader(x, getV035(), A__MENUVERT,,,.f.)} ;
            valid {|| mMETHOD := padr(mMETHOD, 69), .t. } ;
            when mMNN
            
        ++ix
        @ r1 + ix,2 say "������⢮ ��������" get mKOLVO picture '99' ;
            when mMNN
                
        status_key("^<Esc>^ - ��室 ��� �����;  ^<PgDn>^ - ���⢥ত���� �����")
        count_edit := myread( , ,++k_read)
        if lastkey() != K_ESC
          // ��ࠡ�⪠ � ��室
          if nKey == K_INS    // ����������
            flMany := (mdate_end_per > mdate_u1)
            if flMany
              // ������� ����⮬ ������⢥��� �९����
              tDate := mdate_u1
              do while tDate <= mdate_end_per
                add_lek_pr(tDate, nKey)
                last_date := max(tmp->DATE_INJ, last_date)
                      
                tDate := tDate + 1  // 㢥��稬 ���� �� 1 ����
              enddo
            else
              add_lek_pr(mdate_u1, nKey)
              last_date := max(tmp->DATE_INJ, last_date)
            endif
          elseif nKey == K_ENTER  // ।���஢����
            add_lek_pr(mdate_u1, nKey)
            last_date := max(tmp->DATE_INJ, last_date)
          endif
          select TMP
          oBrow:goTop()
          flag := 0
          exit
        elseif lastkey() == K_ESC
          exit
        endif
      enddo
                            
    case nKey == K_DEL .and. tmp->KOD_HUM > 0 .and. f_Esc_Enter(2)
      if tmp->rec_n != 0
        select LEK_PR
        goto (tmp->rec_n)
        DeleteRec(.t.)  // ���⪠ ����� � ����⪮� �� 㤠�����
        select TMP
      endif
      DeleteRec(.t.)  // � ����⪮� �� 㤠�����
      oBrow:goTop()
      go top
      if eof()
        keyboard chr(K_INS)
      endif
      flag := 0
    otherwise
      keyboard ''
  endcase
  
  restscreen(buf)
  return flag

***** 07.01.22 �㭪�� ��� when � valid �� ����� ��� � ���� ����
Function f5editpreparat(get, when_valid, k)
  Local fl := .t., arr, row
  local arrN020 := {}, tmpSelect
  
  if when_valid == 1    // when
    if k == 1     // ��� �������� ��㣨
    elseif k == 2 // ���⠭�� �奬� ��祭�� �९��⠬
    elseif k == 3 // �奬� ��祭��
    elseif k == 4 // ��� ����砭�� ��ਮ��
    endif
  else  // valid
    if k == 1     // ��� �������� ��㣨
      if !emptyany(human->n_data, mdate_u1) .and. mdate_u1 < human->n_data
        fl := func_error(4, "��������� ��� ����� ���� ��砫� ��祭��!")
      elseif !emptyany(human->k_data, mdate_u1) .and. mdate_u1 > human->k_data
        fl := func_error(4, "��������� ��� ����� ���� ����砭�� ��祭��!")
      endif
    elseif k == 2 // ���⠭�� �奬� ��祭�� �९��⠬
      mSCHEDRUG := alltrim(mSCHEDRUG)
      if (arr := get_group_prep_by_kod(substr(m1SCHEDRUG, len(m1SCHEDRUG)), mdate_u1)) != nil
        mMNN := iif(arr[3] == 1, .t., .f.)
        if mMNN
          arrN020 := get_drugcode_by_schema_lech(m1SCHEDRUG, mdate_u1)
          if len(arrN020) != 0
            tmpSelect := select()
            R_Use(exe_dir + '_mo_N020', cur_dir + '_mo_N020', 'N20')
            for each row in arrN020
              find (row[2])
              if found()
                AAdd(arr_lek_pr, {N20->MNN, N20->ID_LEKP, N20->DATEBEG, N20->DATEEND })
              endif
            next
            N20->(dbCloseArea())
            select(tmpSelect)
            arrN020 := {}
          endif
        else
          arr_lek_pr := {}
          arrN020 := {}
        endif
      endif
    elseif k == 3 // �奬� ��祭��
      // mSCHEMECOD := alltrim(mSCHEME)
      if alltrim(get:buffer) != mSCHEME
        // ���⨬ ��
        //// m1SCHEME := ''
        //// mSCHEME := ''
        // m1SCHEDRUG := ''
        // mSCHEDRUG := ''
        // m1UNITCODE := ''
        // mUNITCODE := ''
        // m1METHOD := ''
        // mMETHOD := ''
        // m1REGNUM := ''
        // mREGNUM := ''
        // mDOZE := 0.0
        // mKOLVO := 0.0
        // update_get('mSCHEDRUG')  
        // update_get('mUNITCODE')  
        // update_get('mMETHOD')  
        // update_get('mREGNUM')  
        // update_get('mDOZE')  
        // update_get('mKOLVO')  
      endif
    elseif k == 4     // ��� ����砭�� ��ਮ��
      if !emptyany(human->n_data, mdate_end_per) .and. mdate_end_per < human->n_data
        fl := func_error(4, "��������� ��� ����� ���� ��砫� ��祭��!")
      elseif !emptyany(human->k_data, mdate_end_per) .and. mdate_end_per > human->k_data
        fl := func_error(4, "��������� ��� ����� ���� ����砭�� ��祭��!")       
      endif
    endif
  endif
  return fl

******* 09.01.22
function collect_lek_pr(mkod_human)
  local retArr := {}
  
  select LEK_PR
  find (str(mkod_human, 7))
  if found()
    do while LEK_PR->KOD_HUM == mkod_human .and. !eof()
      AAdd( retArr, {LEK_PR->DATE_INJ, LEK_PR->CODE_SH, LEK_PR->REGNUM, LEK_PR->ED_IZM, LEK_PR->DOSE_INJ, LEK_PR->METHOD_I, LEK_PR->COL_INJ})
      LEK_PR->(dbSkip())
    enddo
  endif

  return retArr

***** 10.01.22 �㭪�� ��� when � valid �� ����� ࠧ����� �����
Function check_edit_field(get, when_valid, k)
  Local fl := .t.
  local arrN020 := {}, tmpSelect
  
  if when_valid == 1    // when
    if k == 1     // ��� ��樥�� � ��
    elseif k == 2 // 
    elseif k == 3 // 
    endif
  else  // valid
    if k == 1     // ��� ��樥�� � ��
      if val(get:buffer) > 500
        get:varPut( get:original )
        fl := func_error(4, "�������� ��� �� ����� ���� ��� 500 ��!")
      elseif val(get:buffer) < 0
        get:varPut( get:original )
        fl := func_error(4, "�������� ��� �� ����� ���� ����⥫��!")
      endif
    elseif k == 2 // 
    elseif k == 3 // 
    endif
  endif
  return fl

