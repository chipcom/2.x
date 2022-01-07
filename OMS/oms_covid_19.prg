#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

****** 05.01.22 ������� �� HUMAN_2 ��� ��樥��
function get_weight_covid(kod_hum)
  local weight := 0.0
  local tmpSelect := select()

  select HUMAN_2
  goto (Loc_kod)
  weight := val(HUMAN_2->PC4)
  select(tmpSelect)

  return weight

****** 05.01.22 ������� � HUMAN_2 ��� ��樥��
function save_weight_covid(kod_hum, weight)
  local tmpSelect := select()

  if valtype(weight) == 'N'
    select HUMAN_2
    goto (Loc_kod)
    G_RLock(forever)
    HUMAN_2->PC4 := str(weight, 3, 1)
    UnLock
    select(tmpSelect)
  endif
  return weight

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

******* 07.01.22 ����� ������⢥���� �९��⮢
function oms_sluch_lek_pr(mkod_human,mkod_kartotek,fl_edit)
  // mkod_human - ��� �� �� human
  // mkod_kartotek - ��� �� �� kartotek
  local aDbf, buf := savescreen(), l_color, fl_found
  local mtitle, tmp_color := setcolor(color1)
  local nBegin

  private mWeight := 0.0
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

  mWeight := val(HUMAN_2->PC4)  // ����稬 ��� ��樥��
  m1Severity := val(HUMAN_2->PC5) // ����稬 �⥯��� �殮��
  mSeverity  := inieditspr(A__MENUVERT, get_severity(), m1Severity)
  
  // Local mo_lek_pr := {; // �������� � ��������� ������⢥���� �९����
  //   {"KOD_HUM",   "N",   7, 0},; // ��� ���� ���� �� 䠩�� "human"
  //   {"DATE_INJ",  "D",   8, 0},;  // ��� �������� ������⢥����� �९���
  //   {"CODE_SH",   "C",  10, 0},;   // ��� �奬� ��祭�� ��樥��/��� ��㯯� �९���
  //   {"REGNUM",    "C",   6, 0},;  // �����䨪��� ������⢥����� �९���
  //   {"ED_IZM",    "C",   3, 0},;  // ������ ����७�� ���� ������⢥����� �९���
  //   {"DOSE_INJ",  "N",   5, 2},;  // ���� �������� ������⢥����� �९���
  //   {"METHOD_I",  "C",   3, 0},;  // ���� �������� ������⢥����� �९���
  //   {"COL_INJ",   "N",   5, 0},;  // ������⢮ �������� � �祭�����, 㪠������� � DATA_INJ
  //   {"COD_MARK",  "C", 100, 0},;  // ��� ��ન஢�� ������⢥����� �९���
  // }

  adbf := {;
    {"KOD_HUM" ,   "N",    7,     0},; // ��� ���� ���� �� 䠩�� "human"
    {"DATE_INJ",   "D",    8,     0},; // ��� �������� ������⢥����� �९���
    {"SCHEME"  ,   "C",   10,     0},; // �奬� ��祭�� ��樥�� V030
    {"SCHEMECO",   "C",    3,     0},; // ��⠭�� �奬� ��祭�� � ��㯯� �९��⮢ V032
    {"REGNUM"  ,   "C",    6,     0},; // ������⢥����� �९���
    {"ED_IZM"  ,   "C",    3,     0},; // ������ ����७�� ���� ������⢥����� �९���
    {"SHORTTIT",   "C",    5,     0},; // ��⪮� ������������ ������� ����७��
    {"DOZE"    ,   "N",    5,      2},; // ���� �������� ������⢥����� �९���
    {"METHOD"  ,   "C",    3,     0},; // ���� �������� ������⢥����� �९���
    {"COL_INJ" ,   "N",    5,      0},; // ������⢮ �������� � �祭�����, 㪠������� � DATA_INJ
    {"COD_MARK",   "C",  100,      0},;  // ��� ��ન஢�� ������⢥����� �९���
    {"NUMBER"  ,   "N",    3,      0},;
    {"REC_N"   ,   "N",    8,      0};
  }
  dbcreate(cur_dir + 'tmp_lek_pr', adbf)
  use (cur_dir + 'tmp_lek_pr') new alias TMP

  number := 0
  select LEK_PR
  find (str(mkod_human, 7))
  if found()
    do while LEK_PR->kod == mkod_human .and. !eof()
      number++
      select TMP
      append blank
      tmp->NUMBER   := number
      tmp->KOD_HUM  := LEK_PR->KOD_HUM
      tmp->DATE_INJ := LEK_PR->DATE_INJ
      tmp->SCHEME   := LEK_PR->CODE_SH
      tmp->SCHEMECO := LEK_PR->SCHEMECO
      tmp->REGNUM   := LEK_PR->REGNUM
      tmp->ED_IZM   := LEK_PR->ED_IZM
      tmp->SHORTTIT := left(inieditspr(A__MENUVERT, getV034(), val(LEK_PR->ED_IZM)), 5)
      tmp->DOZE     := LEK_PR->DOZE
      tmp->METHOD   := LEK_PR->METHOD_I
      tmp->COL_INJ  := LEK_PR->COL_INJ
      tmp->COD_MARK := LEK_PR->COD_MARK
      tmp->REC_N    :=  LEK_PR->(recno())
      LEK_PR->(dbSkip())
    enddo
  endif
  fl_found := (tmp->(lastrec()) > 0)

  // mishod    := inieditspr(A__MENUVERT, glob_V012, m1ishod)
  cls
  pr_1_str("������⢥��� �९���� < " + fio_plus_novor() + " >")
  @ 1,50 say padl("���� ��� � " + lstr(mkod_human), 29) color color14
  l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"

  setcolor(color1)

  nBegin := 5
  if mWeight == 0.0
    @ 2, 2 say "��� ��樥��" get mWeight picture '999.9' //;
      // valid {|| mprofil := padr(mprofil,69), .t. }
      @ 3,2 say "�⥯��� �殮�� ���ﭨ�" get mSeverity ;
      reader {|x|menu_reader(x, get_severity(), A__MENUVERT,,,.f.)}
    myread()
  else
    @ 2, 2 say "��� ��樥��:"
    @ 2, col() + 1 say mWeight picture '999.9'
    @ 3,2 say "�⥯��� �殮�� ���ﭨ�:"
    @ 3, col() + 1 say mSeverity
  endif

  if fl_found
    keyboard chr(K_RIGHT)
  else
    keyboard chr(K_INS)
  endif

  mtitle := f_srok_lech(human->n_data,human->k_data,human_->usl_ok)  
  Alpha_Browse(nBegin, 0, maxrow() - 5, 79, 'f_oms_sluch_lek_pr', color1, mtitle, col_tit_popup,;
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

***** 06.01.22
Function f_oms_sluch_lek_pr(oBrow)
  Local oColumn, blk_color

  oColumn := TBColumnNew(" NN; ��",{|| tmp->number })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("���; ����.",{|| left(dtoc(tmp->DATE_INJ), 5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("�奬�",{|| tmp->SCHEME })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("�९���",{|| tmp->REGNUM })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("������",{|| tmp->SHORTTIT })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("����",{|| str(tmp->DOZE, 5, 2) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("���ᮡ;��������",{|| tmp->METHOD })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("���ᮡ;��������",{|| str(tmp->COL_INJ, 5, 0) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  
  // if mem_ordusl == 2
  //   oColumn := TBColumnNew("���; ��.",{|| left(dtoc(tmp->date_u1),5) })
  //   oColumn:colorBlock := blk_color
  //   oBrow:addColumn(oColumn)
  // endif
  // oColumn := TBColumnNew("�⤥-;�����",{|| otd->short_name })
  // oColumn:defColor := {6,6}
  // oColumn:colorBlock := {|| {6,6} }
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew("���10",{|| tmp->kod_diag })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew("��䨫� ��㣨",{|| padr(inieditspr(A__MENUVERT,glob_V002,tmp->PROFIL),15) })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew("���",{|| put_val(ret_tabn(tmp->kod_vr),5) })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew("���.",{|| put_val(ret_tabn(tmp->kod_as),5) })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew("���;��",{|| str(tmp->kol_1,3) })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew(" ����; ��-��",{|| put_kop(tmp->stoim_1,8) })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)
  status_key("^<Esc>^ ��室; ^<Enter>^ ।-��; ^<Ins>^ ����������; ^<Del>^ 㤠�����")
  return NIL
  
***** 06.01.22
Function f1oms_sluch_lek_pr()
  LOCAL nRow := ROW(), nCol := COL()
  // local s := tmp->name_u, lcolor := cDataCSay

  // if is_zf_stomat == 1 .and. !empty(tmp->zf)
  //   s := alltrim(tmp->zf)+" / "+s
  //   lcolor := color8
  // endif
  // @ maxrow()-2,2 say padr(s,65) color lcolor
  // if empty(tmp->u_cena)
  //   s := iif(tmp->n_base==0, "", "�����")
  // else
  //   s := alltrim(dellastnul(tmp->u_cena,10,2))
  // endif
  // @ maxrow()-2,68 say padc(s,11) color cDataCSay
  // f3oms_usl_sluch()
  // @ nRow, nCol SAY ""
  return NIL

****** 07.01.22
function f2oms_sluch_lek_pr(nKey,oBrow)

  LOCAL flag := -1, buf := savescreen(), k_read := 0, count_edit := 0
  local r1 := 10, ix
  local last_date := human->n_data

  do case
    case nKey == K_F9
    case nKey == K_F10
    case nKey == K_INS .or. (nKey == K_ENTER .and. tmp->KOD_HUM > 0)
      private mMNN := .f.
      private arr_lek_pr := {}
      private mdate_u1 := iif(nKey == K_INS, last_date, tmp->date_u1)  // ��� ᮢ���⨬��� � f5editkusl
      private m1SCHEME := iif(nKey == K_INS, '', tmp->SCHEME), mSCHEME
      private m1SCHEMECOD := iif(nKey == K_INS, '', tmp->SCHEMECO), mSCHEMECOD
      private m1UNITCODE := iif(nKey == K_INS, '', tmp->ED_IZM), mUNITCODE
      private m1METHOD := iif(nKey == K_INS, '', tmp->METHOD), mMETHOD
      private m1REGNUM := iif(nKey == K_INS, '', tmp->METHOD), mREGNUM
      private mDOZE :=  iif(nKey == K_INS, 0.0, tmp->DOZE)
      private mKOLVO :=  iif(nKey == K_INS, 0, tmp->COL_INJ)

      --r1
      box_shadow(r1-1,0,maxrow()-1,79,color8,;
                 iif(nKey == K_INS,"���������� ������ �९���",;
                                   "������஢���� �९���"),iif(yes_color,"RB+/B","W/N"))
      do while .t.
        setcolor(cDataCGet)
        ix := 1
        @ r1+ix,2 say "��� �������� �९���" get mdate_u1 ;
              valid {| g | f5editpreparat(g, 2, 1)}

        ++ix
        @ r1 + ix,2 say "�奬� ��祭��" get mSCHEME ;
            reader {|x|menu_reader(x, get_schemas_lech(m1Severity, mdate_u1), A__MENUVERT,,,.f.)} ;
            valid {| g | f5editpreparat(g, 2, 3)}

        ++ix
        @ r1 + ix,2 say "���⠭�� �奬� ��祭�� �९��⠬" get mSCHEMECOD ;
            reader {|x|menu_reader(x, get_group_by_schema_lech(m1SCHEME, mdate_u1), A__MENUVERT,,,.f.)} ;
            valid {| g | f5editpreparat(g, 2, 2)}
            
        ++ix
        @ r1 + ix,2 say "�९���" get mREGNUM ;
            reader {|x|menu_reader(x, arr_lek_pr, A__MENUVERT,,,.f.)} ;
            when mMNN
                
        ++ix
        @ r1 + ix,2 say "����" get mDOZE picture '999.99'
        
        ++ix
        @ r1 + ix,2 say "������ ����७��" get mUNITCODE ;
            reader {|x|menu_reader(x, getV034(), A__MENUVERT,,,.f.)} ;
            valid {|| mUNITCODE := padr(mUNITCODE, 69), .t. }
        
        ++ix
        @ r1 + ix,2 say "���ᮡ ��������" get mMETHOD ;
            reader {|x|menu_reader(x, getV035(), A__MENUVERT,,,.f.)} ;
            valid {|| mMETHOD := padr(mMETHOD, 69), .t. }
            
        ++ix
        @ r1 + ix,2 say "������⢮ ��������" get mKOLVO picture '99'
                
        status_key("^<Esc>^ - ��室 ��� �����;  ^<PgDn>^ - ���⢥ত���� �����")
        count_edit := myread( , ,++k_read)
        if lastkey() != K_ESC
          // ��ࠡ�⪠ � ��室
          select tmp
          append blank
          tmp->NUMBER       := tmp->(recno())
          tmp->KOD_HUM      := HUMAN->KOD
          tmp->DATE_INJ     := mdate_u1
          tmp->SCHEME       := m1SCHEME
          tmp->SCHEMECO     := m1SCHEMECOD
          tmp->REGNUM       := m1REGNUM
          tmp->ED_IZM       := str(m1UNITCODE, 3)
          tmp->SHORTTIT     := left(mUNITCODE, 5)
          tmp->DOZE         := mDOZE
          tmp->METHOD       := str(m1METHOD, 3)
          tmp->COL_INJ      := mKOLVO
          // tmp->COD_MARK     := LEK_PR->COD_MARK
          // tmp->REC_N        :=  LEK_PR->(recno())
          last_date := max(tmp->DATE_INJ, last_date)
          flag := 0
          exit
        elseif lastkey() == K_ESC
          exit
        endif
      enddo
                            
    case nKey == K_DEL .and. tmp->KOD_HUM > 0 .and. f_Esc_Enter(2)
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
    endif
  else  // valid
    if k == 1     // ��� �������� ��㣨
      if !emptyany(human->n_data, mdate_u1) .and. mdate_u1 < human->n_data
        fl := func_error(4, "��������� ��� ����� ���� ��砫� ��祭��!")
      elseif !emptyany(human->k_data, mdate_u1) .and. mdate_u1 > human->k_data
        fl := func_error(4, "��������� ��� ����� ���� ����砭�� ��祭��!")
      endif
    elseif k == 2 // ���⠭�� �奬� ��祭�� �९��⠬
      mSCHEMECOD := alltrim(mSCHEMECOD)
      if (arr := get_group_prep_by_kod(substr(m1SCHEMECOD, len(m1SCHEMECOD)), mdate_u1)) != nil
        mMNN := iif(arr[3] == 1, .t., .f.)
        if mMNN
          arrN020 := get_drugcode_by_schema_lech(m1SCHEMECOD, mdate_u1)
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
      mSCHEMECOD := alltrim(mSCHEME)
    endif
  endif
  return fl