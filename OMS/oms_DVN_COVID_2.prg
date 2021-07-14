#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"


***** 07.07.21 ��� - ���������� ��� ।���஢���� ���� (���� ���)
Function oms_sluch_DVN_COVID_2(Loc_kod,kod_kartotek,f_print)
// Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
// kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
// f_print - ������������ �㭪樨 ��� ����
Static sadiag1 := {}
Static st_N_DATA, st_K_DATA, s1dispans := 1
Local bg := {|o,k| get_MKB10(o,k,.t.) }, arr_del := {}, mrec_hu := 0,;
      buf := savescreen(), tmp_color := setcolor(), a_smert := {},;
      p_uch_doc := "@!", pic_diag := "@K@!", arr_usl := {}, ah,;
      i, j, k, s, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0, ar, larr, lu_kod,;
      fl, tmp_help := chm_help_code, fl_write_sluch := .f., mu_cena, lrslt_1_etap := 0
//
Default st_N_DATA TO sys_date, st_K_DATA TO sys_date
Default Loc_kod TO 0, kod_kartotek TO 0
//
Private oms_sluch_DVN := .t., ps1dispans := s1dispans, is_prazdnik

alertx(.t.,'���� 2')
if kod_kartotek == 0 // ���������� � ����⥪�
  if (kod_kartotek := edit_kartotek(0,,,.t.)) == 0
    return NIL
  endif
elseif Loc_kod > 0
  R_Use(dir_server+"human",,"HUMAN")
  goto (Loc_kod)
  fl := (year(human->k_data) < 2018)
  Use
  if fl
    return func_error(4,"�� ��砩 ��ᯠ��ਧ�樨 ��諮�� ����")
    //return oms_sluch_DVN13(Loc_kod,kod_kartotek,f_print)
  endif
endif
if empty(sadiag1)
  Private file_form, diag1 := {}, len_diag := 0
  if (file_form := search_file("DISP_NAB"+sfrm)) == NIL
    func_error(4,"�� �����㦥� 䠩� DISP_NAB"+sfrm)
  endif
  f2_vvod_disp_nabl("A00")
  sadiag1 := diag1
endif
chm_help_code := 3002
Private mfio := space(50), mpol, mdate_r, madres, mvozrast, mdvozrast,;
  M1VZROS_REB, MVZROS_REB, m1novor := 0,;
  m1company := 0, mcompany, mm_company,;
  mkomu, M1KOMU := 0, M1STR_CRB := 0,; // 0-���,1-��������,3-�������/���,5-���� ���
  msmo := "34007", rec_inogSMO := 0,;
  mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100),;
  mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20)
Private mkod := Loc_kod, mtip_h, is_talon := .f., mshifr_zs := "",;
        mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
  M1LPU := glob_uch[1], MLPU,;
  M1OTD := glob_otd[1], MOTD,;
  M1FIO_KART := 1, MFIO_KART,;
  MRAB_NERAB, M1RAB_NERAB := 0,; // 0-ࠡ���騩, 1 -��ࠡ���騩
  mveteran, m1veteran := 0,;
  mmobilbr, m1mobilbr := 0,;
  MUCH_DOC    := space(10)         ,; // ��� � ����� ��⭮�� ���㬥��
  MKOD_DIAG   := space(5)          ,; // ��� 1-�� ��.�������
  MKOD_DIAG2  := space(5)          ,; // ��� 2-�� ��.�������
  MKOD_DIAG3  := space(5)          ,; // ��� 3-�� ��.�������
  MKOD_DIAG4  := space(5)          ,; // ��� 4-�� ��.�������
  MSOPUT_B1   := space(5)          ,; // ��� 1-�� ᮯ������饩 �������
  MSOPUT_B2   := space(5)          ,; // ��� 2-�� ᮯ������饩 �������
  MSOPUT_B3   := space(5)          ,; // ��� 3-�� ᮯ������饩 �������
  MSOPUT_B4   := space(5)          ,; // ��� 4-�� ᮯ������饩 �������
  MDIAG_PLUS  := space(8)          ,; // ���������� � ���������
  adiag_talon[16]                  ,; // �� ���⠫��� � ���������
  m1rslt  := 317      ,; // १���� (��᢮��� I ��㯯� ���஢��)
  m1ishod := 306      ,; // ��室 = �ᬮ��
  MN_DATA := st_N_DATA         ,; // ��� ��砫� ��祭��
  MK_DATA := st_K_DATA         ,; // ��� ����砭�� ��祭��
  MVRACH := space(10)         ,; // 䠬���� � ���樠�� ���饣� ���
  M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0,; // ���, ⠡.� � ᯥ�-�� ���饣� ���
  m1povod  := 4,;   // ��䨫����᪨�
  m1travma := 0, ;
  m1USL_OK :=  3,; // �����������
  m1VIDPOM :=  1,; // ��ࢨ筠�
  m1PROFIL := 97,; // 97-�࠯��,57-���� ���.�ࠪ⨪� (ᥬ���.���-�),42-��祡��� ����
  m1IDSP   := 11,; // ���.��ᯠ��ਧ���
  mcena_1 := 0
//
Private arr_usl_dop := {}, arr_usl_otkaz := {}, arr_otklon := {}, m1p_otk := 0
Private metap := 0,;  // 1-���� �⠯, 2-��ன �⠯, 3-��䨫��⨪�
        m1ndisp := 3, mndisp, is_dostup_2_year := .f., mnapr_onk := space(10), m1napr_onk := 0,;
        mWEIGHT := 0,;   // ��� � ��
        mHEIGHT := 0,;   // ��� � �
        mOKR_TALII := 0,; // ���㦭���� ⠫�� � �
        mtip_mas, m1tip_mas := 0,;
        mkurenie, m1kurenie := 0,; //
        mriskalk, m1riskalk := 0,; //
        mpod_alk, m1pod_alk := 0,; //
        mpsih_na, m1psih_na := 0,; //
        mfiz_akt, m1fiz_akt := 0,; //
        mner_pit, m1ner_pit := 0,; //
        maddn, m1addn := 0, mad1 := 120, mad2 := 80,; // ��������
        mholestdn, m1holestdn := 0, mholest := 0,; //"99.99"
        mglukozadn, m1glukozadn := 0, mglukoza := 0,; //"99.99"
        mssr := 0,; // "99"
        mgruppa, m1gruppa := 9      // ��㯯� ���஢��
Private mot_nasl1, m1ot_nasl1 := 0, mot_nasl2, m1ot_nasl2 := 0,;
        mot_nasl3, m1ot_nasl3 := 0, mot_nasl4, m1ot_nasl4 := 0
Private mdispans, m1dispans := 0, mnazn_l , m1nazn_l  := 0,;
        mdopo_na, m1dopo_na := 0, mssh_na , m1ssh_na  := 0,;
        mspec_na, m1spec_na := 0, msank_na, m1sank_na := 0
Private mvar, m1var
Private mm_ndisp := {{"��ᯠ��ਧ��� I  �⠯",1},;
                     {"��ᯠ��ਧ��� II �⠯",2}}
Private mm_gruppa, mm_ndisp1, is_disp_19 := .t.,;
        is_disp_21 := .t., is_disp_nabl := .f.
mm_ndisp1 := aclone(mm_ndisp)
// ��⠢�塞 3-�� � 4-� �⠯�
asize(mm_ndisp1,4) ; hb_ADel(mm_ndisp1, 1, .t.) ; hb_ADel(mm_ndisp1, 1, .t.)
Private mm_gruppaP := {{"��᢮��� I ��㯯� ���஢��"   ,1,343},;
                       {"��᢮��� II ��㯯� ���஢��"  ,2,344},;
                       {"��᢮��� III ��㯯� ���஢��" ,3,345},;
                       {"��᢮��� III� ��㯯� ���஢��",3,373},;
                       {"��᢮��� III� ��㯯� ���஢��",4,374}}
Private mm_gruppaP_old := aclone(mm_gruppaP)
asize(mm_gruppaP_old,3)
Private mm_gruppaP_new := aclone(mm_gruppaP)
hb_ADel(mm_gruppaP_new,3,.t.)
Private mm_gruppaD1 := {;
  {"�஢����� ��ᯠ��ਧ��� - ��᢮��� I ��㯯� ���஢��"   ,1,317},;
  {"�஢����� ��ᯠ��ਧ��� - ��᢮��� II ��㯯� ���஢��"  ,2,318},;
  {"�஢����� ��ᯠ��ਧ��� - ��᢮��� III� ��㯯� ���஢��",3,355},;
  {"�஢����� ��ᯠ��ਧ��� - ��᢮��� III� ��㯯� ���஢��",4,356},;
  {"���ࠢ��� �� 2 �⠯, �।���⥫쭮 ��᢮��� I ��㯯� ���஢��"   ,11,352},;
  {"���ࠢ��� �� 2 �⠯, �।���⥫쭮 ��᢮��� II ��㯯� ���஢��"  ,12,353},;
  {"���ࠢ��� �� 2 �⠯, �।���⥫쭮 ��᢮��� III� ��㯯� ���஢��",13,357},;
  {"���ࠢ��� �� 2 �⠯, �।���⥫쭮 ��᢮��� III� ��㯯� ���஢��",14,358},;
  {"���ࠢ��� �� 2 �⠯ � ���������, ��᢮��� I ��㯯� ���஢��"   ,21,352},;
  {"���ࠢ��� �� 2 �⠯ � ���������, ��᢮��� II ��㯯� ���஢��"  ,22,353},;
  {"���ࠢ��� �� 2 �⠯ � ���������, ��᢮��� III� ��㯯� ���஢��",23,357},;
  {"���ࠢ��� �� 2 �⠯ � ���������, ��᢮��� III� ��㯯� ���஢��",24,358}}
Private mm_gruppaD2 := aclone(mm_gruppaD1)
asize(mm_gruppaD2,4)
Private mm_gruppaD4 := aclone(mm_gruppaD1)
asize(mm_gruppaD4,8)
Private mm_otkaz := {{"_�믮�����",0},;
                     {"�⪫������",3},;
                     {"����� ���.",1},;
                     {"����������",2}}
Private mm_otkaz1 := aclone(mm_otkaz)
asize(mm_otkaz1,3)
Private mm_otkaz0 := aclone(mm_otkaz)
asize(mm_otkaz0,2)
Private mm_pervich := {{"�����     ",1},;
                       {"࠭�� ��.",0},;
                       {"�।.�������",2}}
Private mm_dispans := {{"�� ��⠭������             ",0},;
                       {"���⪮�� �࠯��⮬      ",3},;
                       {"��箬 ��.���.��䨫��⨪�",1},;
                       {"��箬 業�� ���஢��     ",2}}
Private mDS_ONK, m1DS_ONK := 0 // �ਧ��� �����७�� �� �������⢥���� ������ࠧ������
Private mm_dopo_na := {{"���.�������⨪�",1},{"�����.�������⨪�",2},{"��祢�� �������⨪�",3},{"��, ���, ���������",4}}
Private gl_arr := {;  // ��� ��⮢�� �����
  {"dopo_na","N",10,0,,,,{|x|inieditspr(A__MENUBIT,mm_dopo_na,x)} };
 }
Private mnapr_v_mo, m1napr_v_mo := 0, ;
        mm_napr_v_mo := {{"-- ��� --",0},{"� ���� ��",1},{"� ���� ��",2}}, ;
        arr_mo_spec := {}, ma_mo_spec, m1a_mo_spec := 1
Private mnapr_stac, m1napr_stac := 0, ;
        mm_napr_stac := {{"--- ��� ---",0},{"� ��樮���",1},{"� ��. ���.",2}}, ;
        mprofil_stac, m1profil_stac := 0
Private mnapr_reab, m1napr_reab := 0, mprofil_kojki, m1profil_kojki := 0
//
dbcreate(cur_dir+"tmp_onkna", {; // �������ࠢ�����
   {"KOD"      ,   "N",     7,     0},; // ��� ���쭮��
   {"NAPR_DATE",   "D",     8,     0},; // ��� ���ࠢ�����
   {"NAPR_MO",     "C",     6,     0},; // ��� ��㣮�� ��, �㤠 �믨ᠭ� ���ࠢ�����
   {"NAPR_V"  ,    "N",     1,     0},; // ��� ���ࠢ�����:1-� ��������,2-�� ������,3-�� ����᫥�������,4-��� ���.⠪⨪� ��祭��
   {"MET_ISSL" ,   "N",     1,     0},; // ��⮤ ���������᪮�� ��᫥�������(�� NAPR_V=3):1-���.�������⨪�;2-�����.�������⨪�;3-���.�������⨪�;4-��, ���, ���������
   {"shifr"  ,     "C",    20,     0},;
   {"shifr_u"  ,   "C",    20,     0},;
   {"shifr1"   ,   "C",    20,     0},;
   {"name_u"   ,   "C",    65,     0},;
   {"U_KOD"    ,   "N",     6,     0};  // ��� ��㣨
  })
Private m1NAPR_MO, mNAPR_MO, mNAPR_DATE, mNAPR_V, m1NAPR_V, mMET_ISSL, m1MET_ISSL, ;
        mshifr, mshifr1, mname_u, mU_KOD, cur_napr := 0, count_napr := 0, tip_onko_napr := 0
Private mm_napr_v := {{"���",0},;
                      {"� ��������",1},;
                      {"�� ����᫥�������",3}}
Private mm_met_issl := {{"���",0},;
                        {"������ୠ� �������⨪�",1},;
                        {"�����㬥�⠫쭠� �������⨪�",2},;
                        {"��⮤� ��祢�� �������⨪� (����ண����騥)",3},;
                        {"��ண����騥 ��⮤� ��祢�� �������⨪�",4}}
//
Private pole_diag, pole_pervich, pole_1pervich, pole_d_diag, ;
        pole_stadia, pole_dispans, pole_1dispans, pole_d_dispans, pole_dn_dispans
for i := 1 to 5
  sk := lstr(i)
  pole_diag := "mdiag"+sk
  pole_d_diag := "mddiag"+sk
  pole_pervich := "mpervich"+sk
  pole_1pervich := "m1pervich"+sk
  pole_stadia := "m1stadia"+sk
  pole_dispans := "mdispans"+sk
  pole_1dispans := "m1dispans"+sk
  pole_d_dispans := "mddispans"+sk
  pole_dn_dispans := "mdndispans"+sk
  Private &pole_diag := space(6)
  Private &pole_d_diag := ctod("")
  Private &pole_pervich := space(7)
  Private &pole_1pervich := 0
  Private &pole_stadia := 1
  Private &pole_dispans := space(10)
  Private &pole_1dispans := 0
  Private &pole_d_dispans := ctod("")
  Private &pole_dn_dispans := ctod("")
next
Private mg_cit := "", m1g_cit := 0, m1lis := 0, mm_g_cit := {;
  {"� ��-���筮� ���-� �⮫�����.���ਠ��",1},;
  {"� �����-������⭮� ���-�� ��.���ਠ��",2}}
for i := 1 to 33 //count_dvn_arr_usl 19.10.21
  mvar := "MTAB_NOMv"+lstr(i)
  Private &mvar := 0
  mvar := "MTAB_NOMa"+lstr(i)
  Private &mvar := 0
  mvar := "MDATE"+lstr(i)
  Private &mvar := ctod("")
  mvar := "MKOD_DIAG"+lstr(i)
  Private &mvar := space(6)
  mvar := "MOTKAZ"+lstr(i)
  Private &mvar := mm_otkaz[1,1]
  mvar := "M1OTKAZ"+lstr(i)
  Private &mvar := mm_otkaz[1,2]
  m1var := "M1LIS"+lstr(i)
  Private &m1var := 0
  mvar := "MLIS"+lstr(i)
  Private &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
next
//
afill(adiag_talon,0)
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2
if mkod_k > 0
  R_Use(dir_server+"kartote2",,"KART2")
  goto (mkod_k)
  R_Use(dir_server+"kartote_",,"KART_")
  goto (mkod_k)
  R_Use(dir_server+"kartotek",,"KART")
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
  m1MO_PR     := kart2->MO_PR
  if kart->MI_GIT == 9
    m1komu    := kart->KOMU
    m1str_crb := kart->STR_CRB
  endif
  if eq_any(is_uchastok,1,3)
    MUCH_DOC := padr(amb_kartaN(),10)
  elseif mem_kodkrt == 2
    MUCH_DOC := padr(lstr(mkod_k),10)
  endif
  if alltrim(msmo) == '34'
    mnameismo := ret_inogSMO_name(1,,.t.) // ������ � �������
  endif
  // �஢�ઠ ��室� = ������
  ah := {}
  select HUMAN
  set index to (dir_server+"humankk")
  find (str(mkod_k,7))
  do while human->kod_k == mkod_k .and. !eof()
    if human_->oplata != 9 .and. human_->NOVOR == 0 .and. recno() != Loc_kod
      if is_death(human_->RSLT_NEW) .and. empty(a_smert)
        a_smert := {"����� ���쭮� 㬥�!",;
                    "��祭�� � "+full_date(human->N_DATA)+" �� "+full_date(human->K_DATA)}
      endif
      if between(human->ishod,201,205)
        aadd(ah,{human->(recno()),human->K_DATA})
      endif
    endif
    select HUMAN
    skip
  enddo
  set index to
  if len(ah) > 0
    asort(ah,,,{|x,y| x[2] < y[2] })
    select HUMAN
    goto (atail(ah)[1])
    M1RAB_NERAB := human->RAB_NERAB // 0-ࠡ���騩, 1-��ࠡ���騩, 2-������.����
    letap := human->ishod - 200
    if eq_any(letap,1,4)
      lrslt_1_etap := human_->RSLT_NEW
    endif
    read_arr_DVN(human->kod,.f.)
  endif
endif
if empty(mWEIGHT)
  mWEIGHT := iif(mpol == "�", 70, 55)   // ��� � ��
endif
if empty(mHEIGHT)
  mHEIGHT := iif(mpol == "�", 170, 160)  // ��� � �
endif
if empty(mOKR_TALII)
  mOKR_TALII := iif(mpol == "�", 94, 80) // ���㦭���� ⠫�� � �
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
  M1RAB_NERAB := human->RAB_NERAB     // 0-ࠡ���騩, 1-��ࠡ���騩, 2-������.����
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
    adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
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
  m1rslt     := human_->RSLT_NEW
  //
  is_prazdnik := f_is_prazdnik_DVN(mn_data)
  is_disp_19 := !(mk_data < d_01_05_2019)
  //
  is_disp_21 := !(mk_data < d_01_01_2021)
  //
  ret_arr_vozrast_DVN(mk_data)
  /// !!!!
  ret_arrays_disp(is_disp_19,is_disp_21)

  metap := human->ishod-200
  if is_disp_19
    mdvozrast := year(mn_data) - year(mdate_r)
    // �᫨ �� ���ᬮ��
    if metap == 3 .and. ascan(ret_arr_vozrast_DVN(mk_data),mdvozrast) > 0 // � ������ ��ᯠ��ਧ�樨
      metap := 1 // �ॢ�頥� � ��ᯠ��ਧ���
      if mk_data < d_01_11_2019 .and. m1rslt == 345
        m1rslt := 355
      elseif mk_data >= d_01_11_2019 .and. m1rslt == 373
        m1rslt := 355
      elseif mk_data >= d_01_11_2019 .and. m1rslt == 374
        m1rslt := 356
      elseif m1rslt == 344
        m1rslt := 318
      else
        m1rslt := 317
      endif
    endif
    if metap == 4
      func_error(4,"�� ��ᯠ��ਧ��� ࠧ � 2 ���� - �८�ࠧ㥬 � ������ ��ᯠ��ਧ���")
      metap := 1
    elseif metap == 5
      func_error(4,"�� ��ன �⠯ ��ᯠ��ਧ�樨 ࠧ � 2 ���� - 㤠��� ��� ��砩!")
      close databases
      return NIL
    endif
  endif
  if between(metap,1,5)
    mm_gruppa := {mm_gruppaD1,mm_gruppaD2,mm_gruppaP,mm_gruppaD4,mm_gruppaD2}[metap]
    if (i := ascan(mm_gruppa, {|x| x[3] == m1rslt })) > 0
      m1GRUPPA := mm_gruppa[i,2]
    endif
  endif
  //
  fl_4_1_12 := .f.
  larr := array(2,count_dvn_arr_usl) ; afillall(larr,0)
  R_Use(dir_server+"uslugi",,"USL")
  use_base("human_u")
  find (str(Loc_kod,7))
  do while hu->kod == Loc_kod .and. !eof()
    usl->(dbGoto(hu->u_kod))
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
      lshifr := usl->shifr
    endif
    lshifr := alltrim(lshifr)
    if eq_any(left(lshifr,5),"70.3.","70.7.","72.1.","72.5.","72.6.","72.7.")
      mshifr_zs := lshifr
    else
      fl := .t.
      if is_disp_19
        //
      else
        if lshifr == "2.3.3" .and. hu_->PROFIL == 3  ; // �����᪮�� ����
                             .and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.1.12"})) > 0
          fl_4_1_12 := .t.
          fl := .f. ; larr[1,i] := hu->(recno())
        endif
      endif
      if fl
        for i := 1 to count_dvn_arr_umolch
          if empty(larr[2,i]) .and. dvn_arr_umolch[i,2] == lshifr
            fl := .f. ; larr[2,i] := hu->(recno()) ; exit
          endif
        next
      endif
      if fl
        for i := 1 to count_dvn_arr_usl
          if empty(larr[1,i])
            if valtype(dvn_arr_usl[i,2]) == "C"
              if dvn_arr_usl[i,2] == "4.20.1"
                if lshifr == "4.20.1"
                  m1g_cit := 1
                elseif lshifr == "4.20.2"
                  m1g_cit := 2 ; fl := .f.
                endif
              endif
              if dvn_arr_usl[i,2] == lshifr
                fl := .f.
                m1var := "m1lis"+lstr(i)
                if is_disp_19
                  &m1var := 0
                elseif glob_yes_kdp2[TIP_LU_DVN] .and. ascan(glob_arr_usl_LIS,dvn_arr_usl[i,2]) > 0 .and. hu->is_edit > 0
                  &m1var := hu->is_edit
                endif
                mvar := "mlis"+lstr(i)
                &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
              endif
            endif
            if fl .and. len(dvn_arr_usl[i]) > 11 .and. valtype(dvn_arr_usl[i,12]) == "A"
              if ascan(dvn_arr_usl[i,12],{|x| x[1] == lshifr .and. x[2] == hu_->PROFIL}) > 0
                fl := .f.
              endif
            endif
            if !fl
              larr[1,i] := hu->(recno()) ; exit
            endif
          endif
        next
      endif
      if fl .and. ascan(dvn_700,{|x| x[2] == lshifr}) > 0
        fl := .f. // � �㫥��� ��㣥 ��������� ��㣠 � 業�� �� "700"
      endif
      if fl
        n_message({"�����४⭠� ����ன�� � �ࠢ�筨�� ���:",;
                   alltrim(usl->name),;
                   "��� ��㣨 � �ࠢ�筨�� "+usl->shifr,;
                   "��� ����� - "+opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data)},,;
                  "GR+/R","W+/R",,,"G+/R")
      endif
    endif
    aadd(arr_usl,hu->(recno()))
    select HU
    skip
  enddo
  read_arr_DVN(Loc_kod)
  if metap == 1 .and. between(m1GRUPPA,11,14) .and. m1p_otk == 1
    m1GRUPPA += 10
  endif
  R_Use(dir_server+"mo_pers",,"P2")
  for i := 1 to count_dvn_arr_usl
    if !empty(larr[1,i])
      hu->(dbGoto(larr[1,i]))
      if hu->kod_vr > 0
        p2->(dbGoto(hu->kod_vr))
        mvar := "MTAB_NOMv"+lstr(i)
        &mvar := p2->tab_nom
      endif
      if hu->kod_as > 0
        p2->(dbGoto(hu->kod_as))
        mvar := "MTAB_NOMa"+lstr(i)
        &mvar := p2->tab_nom
      endif
      mvar := "MDATE"+lstr(i)
      &mvar := c4tod(hu->date_u)
      if !empty(hu_->kod_diag) .and. !(left(hu_->kod_diag,1)=="Z")
        mvar := "MKOD_DIAG"+lstr(i)
        &mvar := hu_->kod_diag
      endif
      m1var := "M1OTKAZ"+lstr(i)
      &m1var := 0 // �믮�����
      if valtype(dvn_arr_usl[i,2]) == "C"
        if ascan(arr_otklon,dvn_arr_usl[i,2]) > 0
          &m1var := 3 // �믮�����, �����㦥�� �⪫������
        elseif dvn_arr_usl[i,2] == "2.3.1" .and. ascan(arr_otklon,"2.3.3") > 0
          &m1var := 3 // �믮�����, �����㦥�� �⪫������
        elseif dvn_arr_usl[i,2] == "4.20.1" .and. m1g_cit == 2 .and. ascan(arr_otklon,"4.20.2") > 0
          &m1var := 3 // �믮�����, �����㦥�� �⪫������
        elseif fl_4_1_12 .and. dvn_arr_usl[i,2] == "4.1.12"
          &m1var := 2 // �������������
        endif
      endif
      mvar := "MOTKAZ"+lstr(i)
      &mvar := inieditspr(A__MENUVERT, mm_otkaz, &m1var)
    endif
  next
  if alltrim(msmo) == '34'
    mnameismo := ret_inogSMO_name(2,@rec_inogSMO,.t.) // ������ � �������
  endif
  if valtype(arr_usl_otkaz) == "A"
    for j := 1 to len(arr_usl_otkaz)
      ar := arr_usl_otkaz[j]
      if valtype(ar) == "A" .and. len(ar) >= 5 .and. valtype(ar[5]) == "C"
        lshifr := alltrim(ar[5])
        for i := 1 to count_dvn_arr_usl
          if valtype(dvn_arr_usl[i,2]) == "C" .and. ;
                (dvn_arr_usl[i,2] == lshifr .or. (len(dvn_arr_usl[i]) > 11 .and. valtype(dvn_arr_usl[i,12]) == "A" ;
                                                               .and. ascan(dvn_arr_usl[i,12],{|x| x[1] == lshifr}) > 0))
            if valtype(ar[1]) == "N" .and. ar[1] > 0
              p2->(dbGoto(ar[1]))
              mvar := "MTAB_NOMv"+lstr(i)
              &mvar := p2->tab_nom
            endif
            if valtype(ar[3]) == "N" .and. ar[3] > 0
              p2->(dbGoto(ar[3]))
              mvar := "MTAB_NOMa"+lstr(i)
              &mvar := p2->tab_nom
            endif
            mvar := "MDATE"+lstr(i)
            &mvar := mn_data
            if len(ar) >= 9 .and. valtype(ar[9]) == "D"
              &mvar := ar[9]
            endif
            m1var := "M1OTKAZ"+lstr(i)
            &m1var := 1
            if len(ar) >= 10 .and. valtype(ar[10]) == "N" .and. between(ar[10],1,2)
              &m1var := ar[10]
            endif
            mvar := "MOTKAZ"+lstr(i)
            &mvar := inieditspr(A__MENUVERT, mm_otkaz, &m1var)
          endif
        next i
      endif
    next j
  endif
  if .t.
    use (cur_dir+"tmp_onkna") new alias TNAPR
    R_Use(dir_server+"mo_su",,"MOSU")
    R_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","NAPR") // �������ࠢ�����
    set relation to u_kod into MOSU
    find (str(Loc_kod,7))
    do while napr->kod == Loc_kod .and. !eof()
      cur_napr := 1 // �� ।-�� - ᭠砫� ��ࢮ� ���ࠢ����� ⥪�饥
      ++count_napr
      select TNAPR
      append blank
      tnapr->NAPR_DATE := napr->NAPR_DATE
      tnapr->NAPR_MO   := napr->NAPR_MO
      tnapr->NAPR_V    := napr->NAPR_V
      tnapr->MET_ISSL  := napr->MET_ISSL
      tnapr->U_KOD     := napr->U_KOD
      tnapr->shifr_u   := iif(empty(mosu->shifr),mosu->shifr1,mosu->shifr)
      tnapr->shifr1    := mosu->shifr1
      tnapr->name_u    := mosu->name
      select NAPR
      skip
    enddo
    if count_napr > 0
      mnapr_onk := "������⢮ ���ࠢ����� - "+lstr(count_napr)
    endif
  endif
  for i := 1 to 5
    f_valid_diag_oms_sluch_DVN_COVID_2(,i)
  next i
endif
if !(left(msmo,2) == '34') // �� ������ࠤ᪠� �������
  m1ismo := msmo ; msmo := '34'
endif
is_talon := .t.
close databases
fv_date_r( iif(Loc_kod > 0, mn_data, ) )
MFIO_KART := _f_fio_kart()
mndisp    := inieditspr(A__MENUVERT, mm_ndisp, metap)
mrab_nerab:= inieditspr(A__MENUVERT, menu_rab, m1rab_nerab)
mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
mlpu      := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
motd      := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
mismo     := init_ismo(m1ismo)
f_valid_komu(,-1)
if m1komu == 0
  m1company := int(val(msmo))
elseif eq_any(m1komu,1,3)
  m1company := m1str_crb
endif
mcompany := inieditspr(A__MENUVERT, mm_company, m1company)
if m1company == 34
  if !empty(mismo)
    mcompany := padr(mismo,38)
  elseif !empty(mnameismo)
    mcompany := padr(mnameismo,38)
  endif
endif
mveteran := inieditspr(A__MENUVERT, mm_danet, m1veteran)
mmobilbr := inieditspr(A__MENUVERT, mm_danet, m1mobilbr)
mkurenie := inieditspr(A__MENUVERT, mm_danet, m1kurenie)
mriskalk := inieditspr(A__MENUVERT, mm_danet, m1riskalk)
mpod_alk := inieditspr(A__MENUVERT, mm_danet, m1pod_alk)
if emptyall(m1riskalk,m1pod_alk) ; m1psih_na := 0 ; endif
mpsih_na := inieditspr(A__MENUVERT, mm_danet, m1psih_na)
mfiz_akt := inieditspr(A__MENUVERT, mm_danet, m1fiz_akt)
mner_pit := inieditspr(A__MENUVERT, mm_danet, m1ner_pit)
maddn    := inieditspr(A__MENUVERT, mm_danet, m1addn)
mholestdn := inieditspr(A__MENUVERT, mm_danet, m1holestdn)
mglukozadn := inieditspr(A__MENUVERT, mm_danet, m1glukozadn)
mot_nasl1 := inieditspr(A__MENUVERT, mm_danet, m1ot_nasl1)
mot_nasl2 := inieditspr(A__MENUVERT, mm_danet, m1ot_nasl2)
mot_nasl3 := inieditspr(A__MENUVERT, mm_danet, m1ot_nasl3)
mot_nasl4 := inieditspr(A__MENUVERT, mm_danet, m1ot_nasl4)
mdispans  := inieditspr(A__MENUVERT, mm_dispans, m1dispans)
mDS_ONK   := inieditspr(A__MENUVERT, mm_danet, M1DS_ONK)
mnazn_l   := inieditspr(A__MENUVERT, mm_danet, m1nazn_l)
mdopo_na  := inieditspr(A__MENUBIT, mm_dopo_na, m1dopo_na)
mnapr_v_mo := inieditspr(A__MENUVERT, mm_napr_v_mo, m1napr_v_mo)
if empty(arr_mo_spec)
  ma_mo_spec := "---"
else
  ma_mo_spec := ""
  for i := 1 to len(arr_mo_spec)
    ma_mo_spec += lstr(arr_mo_spec[i])+","
  next
  ma_mo_spec := left(ma_mo_spec,len(ma_mo_spec)-1)
endif
mnapr_stac := inieditspr(A__MENUVERT, mm_napr_stac, m1napr_stac)
mprofil_stac := inieditspr(A__MENUVERT, glob_V002, m1profil_stac)
mnapr_reab := inieditspr(A__MENUVERT, mm_danet, m1napr_reab)
mprofil_kojki := inieditspr(A__MENUVERT, glob_V020, m1profil_kojki)
mssh_na   := inieditspr(A__MENUVERT, mm_danet, m1ssh_na)
mspec_na  := inieditspr(A__MENUVERT, mm_danet, m1spec_na)
msank_na  := inieditspr(A__MENUVERT, mm_danet, m1sank_na)
mtip_mas := ret_tip_mas(mWEIGHT,mHEIGHT,@m1tip_mas)
ret_ndisp(Loc_kod,kod_kartotek)
//
if !empty(f_print)
  return &(f_print+"("+lstr(Loc_kod)+","+lstr(kod_kartotek)+")")
endif
//
str_1 := " ���� ��ᯠ��ਧ�樨/���ᬮ�� ���᫮�� ��ᥫ����"
if Loc_kod == 0
  str_1 := "����������"+str_1
  mtip_h := yes_vypisan
else
  str_1 := "������஢����"+str_1
endif
setcolor(color8)
Private gl_area
setcolor(cDataCGet)
make_diagP(1)  // ᤥ���� "��⨧����" ��������
Private num_screen := 1
do while .t.
  close databases
  DispBegin()
  if metap == 2 .and. num_screen == 2
    hS := 30 ; wS := 80
  elseif num_screen == 3
    hS := 26 ; wS := 85
  else
    hS := 25 ; wS := 80
  endif
  SetMode(hS,wS)
  @ 0,0 say padc(str_1,wS) color "B/BG*"
  gl_area := {1,0,maxrow()-1,maxcol(),0}
  j := 1
  myclear(j)
  if yes_num_lu == 1 .and. Loc_kod > 0
    @ j,(wS-30) say padl("���� ��� � "+lstr(Loc_kod),29) color color14
  endif
  @ j,0 say "��࠭ "+lstr(num_screen) color color8
  if num_screen > 1
    s := alltrim(mfio)+" ("+lstr(mvozrast)+" "+s_let(mvozrast)+")"
    @ j,wS-len(s) say s color color14
  endif
  if num_screen == 1 //
    ++j; @ j,1 say "���" get mfio_kart ;
         reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
         valid {|g,o| update_get("mdate_r"),;
                      update_get("mkomu"),update_get("mcompany") }
         @ row(),col()+5 say "�.�." get mdate_r when .f. color color14
    ++j; @ j,1 say " ������騩?" get mrab_nerab ;
         reader {|x|menu_reader(x,menu_rab,A__MENUVERT,,,.f.)}
         @ j,40 say "���࠭ ��� (���������)?" get mveteran ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say " �ਭ���������� ����" get mkomu ;
               reader {|x|menu_reader(x,mm_komu,A__MENUVERT,,,.f.)} ;
               valid {|g,o| f_valid_komu(g,o) } ;
               color colget_menu
         @ row(),col()+1 say "==>" get mcompany ;
             reader {|x|menu_reader(x,mm_company,A__MENUVERT,,,.f.)} ;
             when m1komu < 5 ;
             valid {|g| func_valid_ismo(g,m1komu,38) }
    ++j; @ j,1 say " ����� ���: ���" get mspolis when m1komu == 0
         @ row(),col()+3 say "�����"  get mnpolis when m1komu == 0
         @ row(),col()+3 say "���"    get mvidpolis ;
                      reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT,,,.f.)} ;
                      when m1komu == 0 ;
                      valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
    //
    ++j; @ j,1 say "�ப�" get mn_data ;
               valid {|g| f_k_data(g,1),;
                          iif(mvozrast < 18, func_error(4,"�� �� ����� ��樥��!"), nil),;
                          ret_ndisp(Loc_kod,kod_kartotek) ;
                     }
         @ row(),col()+1 say "-" get mk_data ;
               valid {|g| f_k_data(g,2),;
                          ret_ndisp(Loc_kod,kod_kartotek) ;
                     }
    if eq_any(metap,3,4) .and. is_dostup_2_year
         @ row(),col()+7 get mndisp /*color color14*/ reader {|x|menu_reader(x,mm_ndisp1,A__MENUVERT,,,.f.)} ;
                         valid {|| metap := m1ndisp, .t. }
    else
         @ row(),col()+7 get mndisp when .f. color color14
    endif
    ++j; @ j,1 say "� ���㫠�୮� �����" get much_doc picture "@!" ;
               when !(is_uchastok == 1 .and. is_task(X_REGIST)) .or. mem_edit_ist==2
         @ j,col()+5 say "�����쭠� �ਣ���?" get mmobilbr ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j
    // ++j; @ j,1 say "��७��/㯮�ॡ����� ⠡���" get mkurenie ;
    //            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    // ++j; @ j,1 say "��� ���㡭��� ���ॡ����� �������� (㯮�ॡ����� ��������)" get mriskalk ;
    //            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    // ++j; @ j,1 say "��� ���ॡ����� ��મ��᪨�/����ய��� ����� ��� �����祭�� ���" get mpod_alk ;
    //            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    // ++j; @ j,1 say "������ 䨧��᪠� ��⨢����� (������⮪ 䨧��᪮� ��⨢����)" get mfiz_akt ;
    //            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    // ++j; @ j,1 say "���樮���쭮� ��⠭�� (���ਥ������ ����/�।�� �ਢ�窨 ��⠭��)" get mner_pit ;
    //            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    // ++j; @ j,1 say "���񭭠� ��᫥��⢥������: �� �������⢥��� ������ࠧ������" get mot_nasl1 ;
    //            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    // ++j; @ j,1 say "                            - �� �थ筮-��㤨��� �����������" get mot_nasl2 ;
    //            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    // ++j; @ j,1 say "               - �� �஭��᪨� ������� ������ ���⥫��� ��⥩" get mot_nasl3 ;
    //            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    // ++j; @ j,1 say "                                           - �� ��୮�� �������" get mot_nasl4 ;
    //            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    // ++j
    // ++j; @ j,1 say "���" get mWEIGHT pict "999" ;
    //            valid {|| iif(between(mWEIGHT,30,200),,func_error(4,"��ࠧ㬭� ���")),;
    //                      mtip_mas := ret_tip_mas(mWEIGHT,mHEIGHT),;
    //                      update_get("mtip_mas") }
    //      @ row(),col()+1 say "��, ���" get mHEIGHT pict "999" ;
    //            valid {|| iif(between(mHEIGHT,40,250),,func_error(4,"��ࠧ㬭� ���")),;
    //                      mtip_mas := ret_tip_mas(mWEIGHT,mHEIGHT),;
    //                      update_get("mtip_mas") }
    //      @ row(),col()+1 say "�, ���㦭���� ⠫��" get mOKR_TALII  pict "999" ;
    //            valid {|| iif(between(mOKR_TALII,40,200),,func_error(4,"��ࠧ㬭�� ���祭�� ���㦭��� ⠫��")), .t.}
    //      @ row(),col()+1 say "�"
    //      @ row(),col()+5 get mtip_mas color color14 when .f.
    // ++j; @ j,1 say " ���ਠ�쭮� ��������" get mad1 pict "999" ;
    //            valid {|| iif(between(mad1,60,220),,func_error(4,"��ࠧ㬭�� ��������")), .t.}
    //      @ row(),col() say "/" get mad2 pict "999";
    //            valid {|| iif(between(mad1,40,180),,func_error(4,"��ࠧ㬭�� ��������")),;
    //                      iif(mad1 > mad2,,func_error(4,"��ࠧ㬭�� ��������")),;
    //                      .t.}
    //      @ row(),col()+1 say "�� ��.��.    ����⥭������ �࠯��" get maddn ;
    //            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    // ++j; @ j,1 say " ��騩 宫���ਭ" get mholest pict "99.99" ;
    //            valid {|| iif(empty(mholest) .or. between(mholest,3,8),,func_error(4,"��ࠧ㬭�� ���祭�� 宫���ਭ�")), .t.}
    //      @ row(),col()+1 say "�����/�     �������������᪠� �࠯��" get mholestdn ;
    //            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    // ++j; @ j,1 say " ����" get mglukoza pict "99.99" ;
    //            valid {|| iif(empty(mglukoza) .or. between(mglukoza,2.2,25),,func_error(4,"����᪮� ���祭�� ����")), .t.}
    //      @ row(),col()+1 say "�����/�     ������������᪠� �࠯��" get mglukozadn ;
    //            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
  //   status_key("^<Esc>^ ��室 ��� ����� ^<PgDn>^ �� 2-� ��࠭���")
  //   if !empty(a_smert)
  //     n_message(a_smert,,"GR+/R","W+/R",,,"G+/R")
  //   endif
  // elseif num_screen == 2 //
  //   ret_ndisp(Loc_kod,kod_kartotek)
    ++j; @ j,8 get mndisp when .f. color color14
    if mvozrast != mdvozrast
      if m1veteran == 1
        s := "(��� ���࠭� �஢������ �� ������� "+lstr(mdvozrast)+" "+s_let(mdvozrast)+")"
      else
        s := "(� "+lstr(year(mn_data))+" ���� �ᯮ������ "+lstr(mdvozrast)+" "+s_let(mdvozrast)+")"
      endif
      @ j,80-len(s) say s color color14
    endif
    ++j; @ j,1 say "������������������������������������������������������������������������������" color color8
    ++j; @ j,1 say "������������ ��᫥�������                   ���� ����᳤�� ��㣳�믮������ " color color8
    ++j; @ j,1 say "������������������������������������������������������������������������������" color color8
    //++j; @ j,0 say replicate("�",80) color color8
    //++j; @ j,0 say "_������������ ��᫥�������____________________���__����_��� ���_�믮������_" color color8
    if mem_por_ass == 0
      @ j-1,52 say space(5)
    endif
    fl_vrach := .t.
    for i := 1 to count_dvn_arr_usl
      fl_diag := .f.
      i_otkaz := 0
      if f_is_usl_oms_sluch_DVN(i,metap,iif(metap==3.and.!is_disp_19,mvozrast,mdvozrast),mpol,@fl_diag,@i_otkaz)
        if fl_diag .and. fl_vrach
          ++j; @ j,1 say "��������������������������������������������������������������������" color color8
          ++j; @ j,1 say "������������ �ᬮ�஢                       ���� ����᳤�� ��㣨" color color8
          ++j; @ j,1 say "��������������������������������������������������������������������" color color8
          //++j; @ j,0 say replicate("�",80) color color8
          //++j; @ j,0 say "_������������ �ᬮ�஢________________________���__����_��� ���_�������____" color color8
          if mem_por_ass == 0
            @ j-1,52 say space(5)
          endif
          fl_vrach := .f.
        endif
        fl_g_cit := fl_kdp2 := .f.
        if valtype(dvn_arr_usl[i,2]) == "C"
          if (fl_g_cit := (dvn_arr_usl[i,2] == "4.20.1"))
            if m1g_cit == 0
              m1g_cit := 1 // ��砫쭮� ��᢮����
            endif
            mg_cit := inieditspr(A__MENUVERT, mm_g_cit, m1g_cit)
            if mk_data > 0d20190831
              fl_g_cit := .f.
              m1g_cit := 1 // � ��
            endif
          elseif !is_disp_19 .and. glob_yes_kdp2[TIP_LU_DVN] .and. ascan(glob_arr_usl_LIS,dvn_arr_usl[i,2]) > 0
            fl_kdp2 := .t.
          endif
        endif
        mvarv := "MTAB_NOMv"+lstr(i)
        mvara := "MTAB_NOMa"+lstr(i)
        mvard := "MDATE"+lstr(i)
        if empty(&mvard)
          &mvard := mn_data
        endif
        mvarz := "MKOD_DIAG"+lstr(i)
        mvaro := "MOTKAZ"+lstr(i)
        mvarlis := "MLIS"+lstr(i)
        ++j
        if fl_g_cit
          @ j,1 get mg_cit reader {|x|menu_reader(x,mm_g_cit,A__MENUVERT,,,.f.)}
        else
          @ j,1 say dvn_arr_usl[i,1]
        endif
        if fl_kdp2
          @ j,41 get &mvarlis reader {|x|menu_reader(x,mm_kdp2,A__MENUVERT,,,.f.)}
        endif
        @ j,46 get &mvarv pict "99999" valid {|g| v_kart_vrach(g) }
      if mem_por_ass > 0
        @ j,52 get &mvara pict "99999" valid {|g| v_kart_vrach(g) }
      endif
        @ j,58 get &mvard
        if fl_diag
          //@ j,69 get &mvarz picture pic_diag ;
          //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
        elseif i_otkaz == 0
          @ j,69 get &mvaro ;
                 reader {|x|menu_reader(x,mm_otkaz0,A__MENUVERT,,,.f.)}
        elseif i_otkaz == 1
          @ j,69 get &mvaro ;
                 reader {|x|menu_reader(x,mm_otkaz1,A__MENUVERT,,,.f.)}
        elseif eq_any(i_otkaz,2,3)
          @ j,69 get &mvaro ;
                 reader {|x|menu_reader(x,mm_otkaz,A__MENUVERT,,,.f.)}
        endif
      endif
    next
    ++j; @ j,1 say replicate("�",68) color color8
    status_key("^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 1-� ��࠭��� ^<PgDn>^ �� 3-� ��࠭���")
  elseif num_screen == 3 //
    mm_gruppa := {mm_gruppaD1,mm_gruppaD2,mm_gruppaP,mm_gruppaD4,mm_gruppaD2}[metap]
    if metap == 3
      if mk_data < d_01_11_2019
        mm_gruppa := mm_gruppaP_old
      else
        mm_gruppa := mm_gruppaP_new
      endif
    endif
    mgruppa := inieditspr(A__MENUVERT, mm_gruppa, m1gruppa)
    ret_ndisp(Loc_kod,kod_kartotek)
    ++j; @ j,8 get mndisp when .f. color color14
    if mvozrast != mdvozrast
      if m1veteran == 1
        s := "(��� ���࠭� �஢������ �� ������� "+lstr(mdvozrast)+" "+s_let(mdvozrast)+")"
      else
        s := "(� "+lstr(year(mn_data))+" ���� �ᯮ������ "+lstr(mdvozrast)+" "+s_let(mdvozrast)+")"
      endif
      @ j,80-len(s) say s color color14
    endif
    ++j; @ j,1  say "������������������������������������������������������������������������������"
    ++j; @ j,1  say "       �  �����  �   ���   ��⠤����⠭������ ��ᯠ��୮� ��� ᫥���饣�"
    ++j; @ j,1  say "������������������� ������� ������.��������     (�����)     �����"
    ++j; @ j,1  say "������������������������������������������������������������������������������"
    //                2      9            22           35       44        54
    ++j; @ j,2  get mdiag1 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN(g,1),;
                                .f.) }
         @ j,9  get mpervich1 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag1)
         @ j,22 get mddiag1 when !empty(mdiag1)
         @ j,35 get m1stadia1 pict "9" range 1,4 ;
                when !empty(mdiag1)
         @ j,44 get mdispans1 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag1)
         @ j,54 get mddispans1 when m1dispans1==1
         @ j,67 get mdndispans1 when m1dispans1==1
    //
    ++j; @ j,2  get mdiag2 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN(g,2),;
                                .f.) }
         @ j,9  get mpervich2 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag2)
         @ j,22 get mddiag2 when !empty(mdiag2)
         @ j,35 get m1stadia2 pict "9" range 1,4 ;
                when !empty(mdiag2)
         @ j,44 get mdispans2 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag2)
         @ j,54 get mddispans2 when m1dispans2==1
         @ j,67 get mdndispans2 when m1dispans2==1
    //
    ++j; @ j,2  get mdiag3 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN(g,3),;
                                .f.) }
         @ j,9  get mpervich3 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag3)
         @ j,22 get mddiag3 when !empty(mdiag3)
         @ j,35 get m1stadia3 pict "9" range 1,4 ;
                when !empty(mdiag3)
         @ j,44 get mdispans3 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag3)
         @ j,54 get mddispans3 when m1dispans3==1
         @ j,67 get mdndispans3 when m1dispans3==1
    //
    ++j; @ j,2  get mdiag4 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN(g,4),;
                                .f.) }
         @ j,9  get mpervich4 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag4)
         @ j,22 get mddiag4 when !empty(mdiag4)
         @ j,35 get m1stadia4 pict "9" range 1,4 ;
                when !empty(mdiag4)
         @ j,44 get mdispans4 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag4)
         @ j,54 get mddispans4 when m1dispans4==1
         @ j,67 get mdndispans4 when m1dispans4==1
    //
    ++j; @ j,2  get mdiag5 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN(g,5),;
                                .f.) }
         @ j,9  get mpervich5 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag5)
         @ j,22 get mddiag5 when !empty(mdiag5)
         @ j,35 get m1stadia5 pict "9" range 1,4 ;
                when !empty(mdiag5)
         @ j,44 get mdispans5 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag5)
         @ j,54 get mddispans5 when m1dispans5==1
         @ j,67 get mdndispans5 when m1dispans5==1
    //
    ++j; @ j,1 say replicate("�",78) color color1
    ++j; @ j,1 say "��ᯠ��୮� ������� ��⠭������" get mdispans ;
               reader {|x|menu_reader(x,mm_dispans,A__MENUVERT,,,.f.)} ;
               when !emptyall(mdispans1,mdispans2,mdispans3,mdispans4,mdispans5)
  if is_disp_19
    if eq_any(metap,1,3) .and. mdvozrast < 65
      ++j; @ j,1 say iif(mdvozrast<40,"�⭮�⥫��","��᮫���")+" �㬬��� �थ筮-��㤨��� ��" get mssr pict "99" ;
                 valid {|| iif(between(mssr,0,47),,func_error(4,"��ࠧ㬭�� ���祭�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠")), .t.}
           @ row(),col() say "%"
    else
      ++j
    endif
  else
    if metap == 1 .and. mdvozrast < 66
      ++j; @ j,1 say iif(mdvozrast<40,"�⭮�⥫��","��᮫���")+" �㬬��� �थ筮-��㤨��� ��" get mssr pict "99" ;
                 valid {|| iif(between(mssr,0,47),,func_error(4,"��ࠧ㬭�� ���祭�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠")), .t.}
           @ row(),col() say "%"
    elseif metap == 3 .and. mvozrast < 66
      ++j; @ j,1 say "�㬬��� �थ筮-��㤨��� ��" get mssr pict "99" ;
                 valid {|| iif(between(mssr,0,47),,func_error(4,"��ࠧ㬭�� ���祭�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠")), .t.}
           @ row(),col() say "%"
    else
      ++j
    endif
  endif
    ++j; @ j,1 say "�ਧ��� �����७�� �� �������⢥���� ������ࠧ������" get mDS_ONK ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "���ࠢ����� �� �����७�� �� ���" get mnapr_onk ;
               reader {|x|menu_reader(x,{{|k,r,c| fget_napr_PN(k,r,c)}},A__FUNCTION,,,.f.)} ;
               when m1ds_onk == 1
    ++j; @ j,1 say "�����祭� ��祭�� (��� �.131)" get mnazn_l ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "���ࠢ��� �� �������⥫쭮� ��᫥�������" get mdopo_na ;
               reader {|x|menu_reader(x,mm_dopo_na,A__MENUBIT,,,.f.)}
    ++j; @ j,1 say "���ࠢ���" get mnapr_v_mo ;
               reader {|x|menu_reader(x,mm_napr_v_mo,A__MENUVERT,,,.f.)} ;
               valid {|| iif(m1napr_v_mo==0, (arr_mo_spec:={},ma_mo_spec:=padr("---",42)), ), update_get("ma_mo_spec")}
         @ j,col()+1 say "� ᯥ樠���⠬" get ma_mo_spec ;
               reader {|x|menu_reader(x,{{|k,r,c| fget_spec_DVN(k,r,c,arr_mo_spec)}},A__FUNCTION,,,.f.)} ;
               when m1napr_v_mo > 0
    ++j; @ j,1 say "���ࠢ��� �� ��祭��" get mnapr_stac ;
               reader {|x|menu_reader(x,mm_napr_stac,A__MENUVERT,,,.f.)} ;
               valid {|| iif(m1napr_stac==0, (m1profil_stac:=0,mprofil_stac:=space(32)), ), update_get("mprofil_stac")}
         @ j,col()+1 say "�� ��䨫�" get mprofil_stac ;
               reader {|x|menu_reader(x,glob_V002,A__MENUVERT,,,.f.)} ;
               when m1napr_stac > 0
    ++j; @ j,1 say "���ࠢ��� �� ॠ�������" get mnapr_reab ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
               valid {|| iif(m1napr_reab==0, (m1profil_kojki:=0,mprofil_kojki:=space(30)), ), update_get("mprofil_kojki")}
         @ j,col()+1 say ", ��䨫� �����" get mprofil_kojki ;
               reader {|x|menu_reader(x,glob_V020,A__MENUVERT,,,.f.)} ;
               when m1napr_reab > 0
    ++j; @ j,1 say "���ࠢ��� �� ᠭ��୮-����⭮� ��祭��" get msank_na ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "������ ���ﭨ� ��������"
         @ j,col()+1 get mGRUPPA ;
                reader {|x|menu_reader(x,mm_gruppa,A__MENUVERT,,,.f.)}
    status_key("^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 2-� ��࠭��� ^<PgDn>^ ������")
  endif
  DispEnd()
  count_edit += myread()
  if num_screen == 3
    if lastkey() == K_PGUP
      k := 3
      --num_screen
    else
      k := f_alert({padc("�롥�� ����⢨�",60,".")},;
                   {" ��室 ��� ����� "," ������ "," ������ � ।���஢���� "},;
                   iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
    endif
  else
    if lastkey() == K_PGUP
      k := 3
      if num_screen > 1
        --num_screen
      endif
    elseif lastkey() == K_ESC
      if (k := f_alert({padc("�롥�� ����⢨�",60,".")},;
                       {" ��室 ��� ����� "," ������ � ।���஢���� "},;
                       1,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )) == 2
        k := 3
      endif
    else
      k := 3
      ++num_screen
      if mvozrast < 18
        num_screen := 1
        func_error(4,"�� �� ����� ��樥��!")
      elseif metap == 0
        num_screen := 1
        func_error(4,"�஢���� �ப� ��祭��!")
      endif
    endif
  endif
  SetMode(25,80)
  if k == 3
    loop
  elseif k == 2
    num_screen := 1
    if m1komu < 5 .and. empty(m1company)
      if m1komu == 0     ; s := "���"
      elseif m1komu == 1 ; s := "��������"
      else               ; s := "������/��"
      endif
      func_error(4,'�� ��������� ������������ '+s)
      loop
    endif
    if m1komu == 0 .and. empty(mnpolis)
      func_error(4,'�� �������� ����� �����')
      loop
    endif
    if empty(mn_data)
      func_error(4,"�� ������� ��� ��砫� ��祭��.")
      loop
    endif
    if mvozrast < 18
      func_error(4,"��䨫��⨪� ������� �� ���᫮�� ��樥���!")
      loop
    endif
    if empty(mk_data)
      func_error(4,"�� ������� ��� ����砭�� ��祭��.")
      loop
    endif
    if empty(CHARREPL("0",much_doc,space(10)))
      func_error(4,'�� �������� ����� ���㫠�୮� �����')
      loop
    endif
    if empty(mWEIGHT)
      func_error(4,"�� ����� ���.")
      loop
    endif
    if empty(mHEIGHT)
      func_error(4,"�� ����� ���.")
      loop
    endif
    if empty(mOKR_TALII)
      func_error(4,"�� ������� ���㦭���� ⠫��.")
      loop
    endif
    if m1veteran == 1
      if metap == 3
        func_error(4,"��䨫��⨪� ������ �� �஢���� ���࠭�� ��� (�����������)")
        loop
      endif
    endif
    //
    mdef_diagnoz := iif(metap==2, "Z01.8 ", "Z00.8 ")
    R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","P2")
    num_screen := 2
    max_date1 := mn_data
    fl := .t.
    not_4_20_1 := .f.
    date_4_1_12 := ctod("")
    k := ku := kol_d_usl := 0
    arr_osm1 := array(count_dvn_arr_usl,11) ; afillall(arr_osm1,0)
    for i := 1 to count_dvn_arr_usl
      fl_diag := fl_ekg := .f.
      i_otkaz := 0
      if f_is_usl_oms_sluch_DVN(i,metap,iif(metap==3.and.!is_disp_19,mvozrast,mdvozrast),mpol,@fl_diag,@i_otkaz,@fl_ekg)
        mvart := "MTAB_NOMv"+lstr(i)
        if empty(&mvart) .and. (eq_any(metap,2,5) .or. fl_ekg) // ���, �� ����� ���
          loop                                                 // � ����易⥫�� ������
        endif
        ar := dvn_arr_usl[i]
        mvara := "MTAB_NOMa"+lstr(i)
        mvard := "MDATE"+lstr(i)
        mvarz := "MKOD_DIAG"+lstr(i)
        mvaro := "M1OTKAZ"+lstr(i)
        if &mvard == mn_data
          k := i
        endif
        if valtype(ar[2]) == "C" .and. ar[2] == "4.20.1"
          if not_4_20_1 // �� ������� ����
            loop
          endif
          if m1g_cit == 2
            if empty(&mvard)
              fl := func_error(4,'�� ������� ��� ��㣨 "'+mg_cit+'"')
            endif
            arr_osm1[i,1]  := 0        // ���
            arr_osm1[i,2]  := -13 //1107     // ᯥ樠�쭮���
            arr_osm1[i,3]  := 0        // ����⥭�
            arr_osm1[i,4]  := 34       // ��䨫�
            arr_osm1[i,5]  := "4.20.2" // ��� ��㣨
            arr_osm1[i,6]  := mdef_diagnoz
            arr_osm1[i,9]  := &mvard
            arr_osm1[i,10] := &mvaro
            //if date_4_1_12 < mn_data ; // �᫨ 4.1.12 ������� ࠭�� ���-��
            //      .or. arr_osm1[i,9] < date_4_1_12 // ��� 4.20.1 ࠭�� 4.1.12
            //  arr_osm1[i,9] := date_4_1_12 // ��ࠢ�塞 ����
            //endif
            max_date1 := max(max_date1,arr_osm1[i,9])
            ++ku
            loop
          endif
        else
          ++kol_d_usl
        endif
        if i_otkaz == 2 .and. &mvaro == 2 // �᫨ ��᫥������� ����������
          select P2
          find (str(&mvart,5))
          if found()
            arr_osm1[i,1] := p2->kod
          endif
          if valtype(ar[11]) == "A" // ᯥ樠�쭮���
            arr_osm1[i,2] := ar[11,1]
          endif
          if valtype(ar[10]) == "N" // ��䨫�
            arr_osm1[i,4] := ar[10]
          endif
          arr_osm1[i,5] := ar[2] // ��� ��㣨
          arr_osm1[i,9] := iif(empty(&mvard), mn_data, &mvard)
          arr_osm1[i,10] := &mvaro
          --kol_d_usl
        elseif empty(&mvard)
          fl := func_error(4,'�� ������� ��� ��㣨 "'+ltrim(ar[1])+'"')
        elseif empty(&mvart)
          fl := func_error(4,'�� ������ ��� � ��㣥 "'+ltrim(ar[1])+'"')
        else
          select P2
          find (str(&mvart,5))
          if found()
            arr_osm1[i,1] := p2->kod
            arr_osm1[i,2] := -ret_new_spec(p2->prvs,p2->prvs_new)
          endif
          if !empty(&mvara)
            select P2
            find (str(&mvara,5))
            if found()
              arr_osm1[i,3] := p2->kod
            endif
          endif
          if valtype(ar[10]) == "N" // ��䨫�
            arr_osm1[i,4] := ret_profil_dispans(ar[10],arr_osm1[i,2])
          else
            if len(ar[10]) == len(ar[11]) ; // ���-�� ��䨫�� = ���-�� ᯥ�-⥩
                       .and. arr_osm1[i,2] < 0 ; // � ��諨 ᯥ樠�쭮��� �� V015
                       .and. (j := ascan(ar[11],ret_old_prvs(arr_osm1[i,2]))) > 0
              // ���� ��䨫�, ᮮ⢥�����騩 ᯥ樠�쭮��
            else
              j := 1 // �᫨ ���, ���� ���� ��䨫� �� ᯨ᪠
            endif
            arr_osm1[i,4] := ar[10,j] // ��䨫�
          endif
          ++ku
          if valtype(ar[2]) == "C"
            arr_osm1[i,5] := ar[2] // ��� ��㣨
            m1var := "m1lis"+lstr(i)
            if !is_disp_19 .and. glob_yes_kdp2[TIP_LU_DVN] .and. &m1var > 0
              arr_osm1[i,11] := &m1var // �஢� �஢����� � ���2
            endif
            if ar[2] == "2.3.1"
              if eq_any(arr_osm1[i,2],2002,-206) // ᯥ樠�쭮���-䥫���
                arr_osm1[i,5] := "2.3.3" // ��� ��㣨
                arr_osm1[i,4] := 42 // ��䨫� - ��祡���� ����
              elseif eq_any(arr_osm1[i,2],2003,-207) // �����᪮� ����
                arr_osm1[i,5] := "2.3.3" // ��� ��㣨
                arr_osm1[i,4] := 3 // ��䨫� - �����᪮�� ����
              endif
            endif
          else
            if len(ar[2]) >= metap
              j := metap
            else
              j := 1
            endif
            arr_osm1[i,5] := ar[2,j] // ��� ��㣨
            if i == count_dvn_arr_usl // ��᫥���� ��㣠 �� ���ᨢ� - �࠯���
              if eq_any(metap,2,5)
                if eq_any(arr_osm1[i,2],2002,-206) // ᯥ樠�쭮���-䥫���
                  fl := func_error(4,"������ �� ����� �������� �࠯��� �� II �⠯� ��ᯠ��ਧ�樨")
                endif
              else // 1 � 3 �⠯
                if eq_any(arr_osm1[i,2],2002,-206) // ᯥ樠�쭮���-䥫���
                  arr_osm1[i,5] := iif(is_disp_19,"2.3.4","2.3.3") // ��� ��㣨
                  arr_osm1[i,4] := 42 // ��䨫� - ��祡���� ����
                endif
              endif
            endif
          endif
          if !fl_diag .or. empty(&mvarz) .or. left(&mvarz,1) == "Z"
            arr_osm1[i,6] := mdef_diagnoz
          else
            arr_osm1[i,6] := &mvarz
            select MKB_10
            find (padr(arr_osm1[i,6],6))
            if found() .and. !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
              fl := func_error(4,"��ᮢ���⨬���� �������� �� ���� "+arr_osm1[i,6])
            endif
          endif
          if (arr_osm1[i,10] := &mvaro) == 1 // �⪠�
            if arr_osm1[i,5] == "4.1.12" // �ᬮ�� ����મ�, ���⨥ ����� (�᪮��)
              not_4_20_1 := .t. // �� ������� ����
            endif
          endif
          if i_otkaz == 3 .and. &mvaro == 2 // ������������� ��� ��㣨 4.1.12
            if is_disp_19
              not_4_20_1 := .t. // �� ������� ����
            else
              if arr_osm1[i,2] == 1101 // �᫨ 㪠���� ᯥ�-�� ���
                arr_osm1[i,5] := "2.3.1" // ��� ��� �����-����������
                arr_osm1[i,4] := 136 // ��䨫� - �������� � ����������� (�� �᪫�祭��� �ᯮ�짮����� �ᯮ����⥫��� ९த�⨢��� �孮�����)
              else
                arr_osm1[i,5] := "2.3.3" // ��� 䥫���-�����
                arr_osm1[i,4] := 3 // ��䨫� - �����᪮�� ����
              endif
              arr_osm1[i,10] := 0 // ��� �⪠�� (? ����� ���⠢��� 3-�⪫������?)
              not_4_20_1 := .t. // �� ������� ����
            endif
          endif
          arr_osm1[i,9] := &mvard
          // ��९�襬 ���� �� "�易���" ��㣠�
          do case
            case arr_osm1[i,5] == "4.1.12" // ���⨥ ����� (�᪮��)
              date_4_1_12 := arr_osm1[i,9]
            case arr_osm1[i,5] == "4.20.1" // ���-� ���⮣� �⮫����᪮�� ���ਠ��
              //if date_4_1_12 < mn_data ; // �᫨ 4.1.12 ������� ࠭�� ���-��
              //      .or. arr_osm1[i,9] < date_4_1_12 // ��� 4.20.1 ࠭�� 4.1.12
              //  arr_osm1[i,9] := date_4_1_12 // ��ࠢ�塞 ����
              //endif
          endcase
          max_date1 := max(max_date1,arr_osm1[i,9])
        endif
      endif
      if !fl ; exit ; endif
    next
    if !fl
      loop
    endif
    i_56_1_723 := 0
    if eq_any(metap,2,5)
      if ku < 2
        if !is_disp_19 .and. (i_56_1_723 := ascan(arr_osm1,{|x| valtype(x[5]) == "C" .and. x[5] == "56.1.723"})) > 0
          // ���� �������㠫쭮� ��� ��㯯���� 㣫㡫����� ��䨫����᪮� �������஢���� - "56.1.723"
        else
          func_error(4,"�� II �⠯� ��易⥫�� �ᬮ�� �࠯��� � ��� �����-���� ��㣨.")
          loop
        endif
      endif
      if k == 0
        func_error(4,"��� ��ࢮ�� �ᬮ�� (��᫥�������) ������ ࠢ������ ��� ��砫� ��祭��.")
        loop
      endif
    endif
    fl := .t.
    if emptyany(arr_osm1[count_dvn_arr_usl,1],arr_osm1[count_dvn_arr_usl,9])
      if metap == 2 .and. i_56_1_723 > 0
        if !(arr_osm1[i_56_1_723,9] == mn_data .and. arr_osm1[i_56_1_723,9] == mk_data)
          fl := func_error(4,'��砫� � ����砭�� ������ ࠢ������ ��� 㣫㡫������ ��䨫����.�������஢����')
        elseif lrslt_1_etap == 353 // ���ࠢ��� �� 2 �⠯, �।���⥫쭮 ��᢮��� II ��㯯� ���஢��
          if m1gruppa != 2
            fl := func_error(4,'������⮬ 2-�� �⠯� ������ ���� II ��㯯� ���஢�� (��� � �� 1-�� �⠯�)')
            num_screen := 3
          endif
        else // ��㣮� १����
          fl := func_error(4,'������⮬ 1-�� �⠯� ������ ���� II ��㯯� (� ���ࠢ��� �� 2-�� �⠯)')
          num_screen := 3
        endif
      else
        fl := func_error(4,'�� ����� ��� �࠯��� (��� ��饩 �ࠪ⨪�)')
      endif
    elseif arr_osm1[count_dvn_arr_usl,9] < mk_data
      fl := func_error(4,'��࠯��� (��� ��饩 �ࠪ⨪�) ������ �஢����� �ᬮ�� ��᫥����!')
    endif
    if !fl
      loop
    endif
    num_screen := 3
    arr_diag := {}
    for i := 1 to 5
      sk := lstr(i)
      pole_diag := "mdiag"+sk
      pole_d_diag := "mddiag"+sk
      pole_1pervich := "m1pervich"+sk
      pole_1dispans := "m1dispans"+sk
      pole_d_dispans := "mddispans"+sk
      pole_dn_dispans := "mdndispans"+sk
      if !empty(&pole_diag)
        if left(&pole_diag,1) == "Z"
          fl := func_error(4,'������� '+rtrim(&pole_diag)+'(���� ᨬ��� "Z") �� ��������. �� �� �����������!')
        elseif &pole_1pervich == 0
          if empty(&pole_d_diag)
            fl := func_error(4,"�� ������� ��� ������ �������� "+&pole_diag)
          elseif &pole_1dispans == 1 .and. empty(&pole_d_dispans)
            fl := func_error(4,"�� ������� ��� ��⠭������� ��ᯠ��୮�� ������� ��� �������� "+&pole_diag)
          endif
        endif
        if fl .and. between(&pole_1pervich,0,1) // �।���⥫�� �������� �� ����
          aadd(arr_diag, {&pole_diag,&pole_1pervich,&pole_1dispans,&pole_dn_dispans})
        endif
      endif
      if !fl ; exit ; endif
    next
    if !fl
      loop
    endif
    is_disp_nabl := .f.
    afill(adiag_talon,0)
    if empty(arr_diag) // �������� �� �������
      aadd(arr_diag, {mdef_diagnoz,0,0,ctod("")}) // ������� �� 㬮�砭��
      MKOD_DIAG := mdef_diagnoz
    else
      for i := 1 to len(arr_diag)
        if arr_diag[i,2] == 0 // "࠭�� �����"
          arr_diag[i,2] := 2  // �����塞, ��� � ���� ���� ���
        endif
        if arr_diag[i,3] > 0 // "���.������� ��⠭������" � "࠭�� �����"
          if arr_diag[i,2] == 2 // "࠭�� �����"
            arr_diag[i,3] := 1 // � "���⮨�"
          else
            arr_diag[i,3] := 2 // � "����"
          endif
        endif
      next
      for i := 1 to len(arr_diag)
        if ascan(sadiag1,alltrim(arr_diag[i,1])) > 0 .and. ;
                                  arr_diag[i,3] == 1 .and. !empty(arr_diag[i,4]) .and. arr_diag[i,4] > mk_data
          is_disp_nabl := .t.
        endif
        adiag_talon[i*2-1] := arr_diag[i,2]
        adiag_talon[i*2  ] := arr_diag[i,3]
        if i == 1
          MKOD_DIAG := arr_diag[i,1]
        elseif i == 2
          MKOD_DIAG2 := arr_diag[i,1]
        elseif i == 3
          MKOD_DIAG3 := arr_diag[i,1]
        elseif i == 4
          MKOD_DIAG4 := arr_diag[i,1]
        elseif i == 5
          MSOPUT_B1 := arr_diag[i,1]
        endif
        select MKB_10
        find (padr(arr_diag[i,1],6))
        if found()
          if !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
            fl := func_error(4,"��ᮢ���⨬���� �������� �� ���� "+alltrim(arr_diag[i,1]))
          endif
        else
          fl := func_error(4,"�� ������ ������� "+alltrim(arr_diag[i,1])+" � �ࠢ�筨�� ���-10")
        endif
        if !fl ; exit ; endif
      next
      if !fl
        loop
      endif
    endif
    mm_gruppa := {mm_gruppaD1,mm_gruppaD2,mm_gruppaP,mm_gruppaD4,mm_gruppaD2}[metap]
    if metap == 3
      if mk_data < d_01_11_2019
        mm_gruppa := mm_gruppaP_old
      else
        mm_gruppa := mm_gruppaP_new
      endif
    endif
    m1p_otk := 0
    if (i := ascan(mm_gruppa,{|x| x[2] == m1GRUPPA })) > 0
      if (m1rslt := mm_gruppa[i,3]) == 352
        m1rslt := 353 // �� ����� ����� �� 06.07.2018 �09-30-96
      endif
      if eq_any(m1GRUPPA,11,21)
        m1GRUPPA++  // �� ����� ����� �� 06.07.2018 �09-30-96
      endif
      if m1GRUPPA > 20
        m1p_otk := 1 // �⪠� �� ��室� �� 2-� �⠯
      endif
    else
      func_error(4,"�� ������� ������ ���ﭨ� ��������")
      loop
    endif
    m1ssh_na := m1psih_na := m1spec_na := 0
    if m1napr_v_mo > 0
      if eq_ascan(arr_mo_spec,45,141) // ���ࠢ��� � ����-�थ筮-��㤨�⮬� �����
        m1ssh_na := 1
      endif
      if eq_ascan(arr_mo_spec,23,97) // ���ࠢ��� � ����-��娠��� (����-��娠���-��મ����)
        m1psih_na := 1
      endif
    endif
    if m1napr_stac > 0 .and. m1profil_stac > 0
      m1spec_na := 1 // ���ࠢ��� ��� ����祭�� ᯥ樠����஢����� ����樭᪮� ����� (� �.�. ���)
    endif
    //
    err_date_diap(mn_data,"��� ��砫� ��祭��")
    err_date_diap(mk_data,"��� ����砭�� ��祭��")
    //
    if mem_op_out == 2 .and. yes_parol
      box_shadow(19,10,22,69,cColorStMsg)
      str_center(20,'������ "'+fio_polzovat+'".',cColorSt2Msg)
      str_center(21,'���� ������ �� '+date_month(sys_date),cColorStMsg)
    endif
    mywait()
    //
    m1lis := 0
    for i := 1 to count_dvn_arr_usl
      if valtype(arr_osm1[i,9]) == "D"
        if arr_osm1[i,5] == "4.20.2" .and. arr_osm1[i,9] < mn_data // �� � ࠬ��� ��ᯠ��ਧ�樨
          m1g_cit := 1 // �᫨ � �뫮 =2, 㡨ࠥ�
        elseif !is_disp_19 .and. glob_yes_kdp2[TIP_LU_DVN] .and. arr_osm1[i,9] >= mn_data .and. len(arr_osm1[i]) > 10 ;
                                                           .and. valtype(arr_osm1[i,11]) == "N" .and. arr_osm1[i,11] > 0
          m1lis := arr_osm1[i,11] // � ࠬ��� ��ᯠ��ਧ�樨
        endif
      endif
    next
    is_prazdnik := f_is_prazdnik_DVN(mn_data)
    if eq_any(metap,2,5)
      i := count_dvn_arr_usl
      m1vrach  := arr_osm1[i,1]
      m1prvs   := arr_osm1[i,2]
      m1assis  := arr_osm1[i,3]
      m1PROFIL := arr_osm1[i,4]
      //MKOD_DIAG := padr(arr_osm1[i,6],6)
    else  // metap := 1,3,4
      i := len(arr_osm1)
      m1vrach  := arr_osm1[i,1]
      m1prvs   := arr_osm1[i,2]
      m1assis  := arr_osm1[i,3]
      m1PROFIL := arr_osm1[i,4]
      //MKOD_DIAG := padr(arr_osm1[i,6],6)
      aadd(arr_osm1,array(11)) ; i := i_zs := len(arr_osm1)
      arr_osm1[i,1] := arr_osm1[i-1,1]
      arr_osm1[i,2] := arr_osm1[i-1,2]
      arr_osm1[i,3] := arr_osm1[i-1,3]
      arr_osm1[i,4] := 151 // ��� ���� �� - ���.�ᬮ�ࠬ ��䨫����᪨�
      arr_osm1[i,5] := ret_shifr_zs_DVN(metap,iif(metap==3.and.!is_disp_19,mvozrast,mdvozrast),mpol,mk_data)
      arr_osm1[i,6] := arr_osm1[i-1,6]
      arr_osm1[i,9] := mn_data
      arr_osm1[i,10] := 0
    endif
    for i := 1 to count_dvn_arr_umolch
      if f_is_umolch_sluch_DVN(i,metap,iif(metap==3.and.!is_disp_19,mvozrast,mdvozrast),mpol)
        ++kol_d_usl
        aadd(arr_osm1,array(11)) ; j := len(arr_osm1)
        arr_osm1[j,1] := m1vrach
        arr_osm1[j,2] := m1prvs
        arr_osm1[j,3] := m1assis
        arr_osm1[j,4] := m1PROFIL
        arr_osm1[j,5] := dvn_arr_umolch[i,2]
        arr_osm1[j,6] := mdef_diagnoz
        arr_osm1[j,9] := iif(dvn_arr_umolch[i,8]==0, mn_data, mk_data)
        arr_osm1[j,10] := 0
      endif
    next
    if eq_any(metap,1,3,4) // �᫨ ���� �⠯, �஢�ਬ �� 85%
      not_zs := .f.
      kol := kol_otkaz := kol_n_date := kol_ob_otkaz := 0
      for i := 1 to len(arr_osm1)
        if i == i_zs
          loop // �ய��⨬ ��� �����祭���� ����
        endif
        if valtype(arr_osm1[i,5]) == "C" .and. !eq_any(arr_osm1[i,5],"4.20.1","4.20.2")
          ++kol // ���-�� ॠ�쭮 ������� ���
          if eq_any(arr_osm1[i,10],0,3)
            if is_disp_19
              if arr_osm1[i,9] < mn_data .and. year(arr_osm1[i,9]) < year(mn_data) // ���-�� ��� ��� �⪠�� �믮����� ࠭��
                ++kol_n_date                 // ��砫� �஢������ ��ᯠ��ਧ�樨 � �� �ਭ������� ⥪�饬� �������୮�� ����
              endif
            else
              if arr_osm1[i,9] < mn_data
                ++kol_n_date // ���-�� ��� ��� �⪠�� �� ��ਮ�� ��ᯠ��ਧ�樨
              endif
            endif
          elseif arr_osm1[i,10] == 1
            ++kol_otkaz // ���-�� �⪠���
/* �� �஢������ ��ᯠ��ਧ�樨 ��易⥫�� ��� ��� �ࠦ��� ����:
- "7.57.3" �஢������ �������䨨,
- "4.8.4" ��᫥������� ���� �� ������ �஢� ���㭮娬��᪨� ����⢥��� ��� ������⢥��� ��⮤��,
- "2.3.1","2.3.3" �ᬮ�� 䥫��஬ (����મ�) ��� ��箬 ����஬-�����������,
- "4.1.12" ���⨥ ����� � 襩�� ��⪨,
- "4.20.1","4.20.2" �⮫����᪮� ��᫥������� ����� � 襩�� ��⪨,
- "4.14.66" ��।������ �����-ᯥ���᪮�� ��⨣��� � �஢� */
            if is_disp_19 .and. eq_any(arr_osm1[i,5],"4.8.4","4.14.66","7.57.3","2.3.1","2.3.3","4.1.12","4.20.1","4.20.2")
              ++kol_ob_otkaz // ���-�� �⪠��� �� ��易⥫��� ���
            endif
          else//if arr_osm1[i,10] == 2 �᫨ ������������� �஢������ - ���� ���⠥� ��饥 ���-��
            --kol
          endif
        endif
      next
      // kol_d_usl = 100% (������ ࠢ������ "kol")
      if kol_d_usl != kol
        //func_error(4,"kol_d_usl ("+lstr(kol_d_usl)+") != kol "+lstr(kol))
      endif
      if metap == 4
        if kol_n_date == 1
          not_zs := .t. // ���⠢�塞 �� �⤥��� ��䠬
        endif
      elseif (i := ascan(dvn_85, {|x| x[1] == kol })) > 0 // ��।����� 85%
        k := dvn_85[i,1] - dvn_85[i,2] // 15%
        if is_disp_19
          if kol_n_date+kol_otkaz <= k // �⪠�� + ࠭�� ������� ����� 15%
            // ���⠢�塞 �� �����祭���� ����
            if kol_ob_otkaz > 0 .and. metap == 1 // ���� ��।����� � ���ᬮ�� !!!!!
              if (i := ascan(arr_osm1, {|x| valtype(x[5]) == "C" .and. x[5] == "2.3.7" })) > 0
                arr_osm1[i,5] := "2.3.2" // ��� ��㣨 ��� �࠯��� ��� ���ᬮ��
              endif
              metap := 3
              if eq_any(m1rslt,355,356,357,358) .and. mk_data < d_01_11_2019 // III ��㯯�
                m1rslt := 345
                m1gruppa := 3
              elseif eq_any(m1rslt,355,357) // III� ��㯯�
                m1rslt := 373
                m1gruppa := 3
              elseif eq_any(m1rslt,356,358) // III� ��㯯�
                m1rslt := 374
                m1gruppa := 4
              elseif eq_any(m1rslt,318,353)
                m1rslt := 344
                m1gruppa := 2
              else
                m1rslt := 343
                m1gruppa := 1
              endif
              arr_osm1[i_zs,5] := ret_shifr_zs_DVN(metap,mdvozrast,mpol,mk_data)
              func_error(4,"�⪠� �� ��易⥫쭮�� ��᫥������� - ��ଫ塞 ��䨫����᪨� �ᬮ�� "+arr_osm1[i_zs,5])
            endif
          else
            // �᫨ < 85%, ����� � �஢�થ
          endif
        else
          if kol_otkaz <= k // ������� 85% � �����
            if kol_n_date+kol_otkaz <= k // �⪠�� + ࠭�� ������� ����� 15%
              // ���⠢�塞 �� �����祭���� ����
            else
              not_zs := .t. // ���⠢�塞 �� �⤥��� ��䠬
            endif
          else
            // �᫨ "kol - kol_otkaz" < 85%, ����� � �஢�થ
          endif
        endif
      else
        // �᫨ ⠪��� ���-�� ��� ��� � ���ᨢ� "dvn_85", ����� � �஢�થ
      endif
      if not_zs // ���⠢�塞 �� �⤥��� ��䠬
        Del_Array(arr_osm1,i_zs) // 㤠�塞 �����祭�� ��砩
        larr := {}
        for i := 1 to len(arr_osm1)
          if valtype(arr_osm1[i,5]) == "C" ;
                 .and. !(len(arr_osm1[i]) > 10 .and. valtype(arr_osm1[i,11]) == "N" .and. arr_osm1[i,11] > 0) ; // �� � ���2
                 .and. eq_any(arr_osm1[i,10],0,3) ; // �� �⪠�
                 .and. arr_osm1[i,9] >= mn_data ; // ������� �� �६� ���-��
                 .and. (k := ascan(dvn_700, {|x| x[1] == arr_osm1[i,5] })) > 0
            aadd(larr,aclone(arr_osm1[i])) ; j := len(larr)
            larr[j,5] := dvn_700[k,2]
          endif
        next
        for i := 1 to len(larr)
          aadd(arr_osm1,aclone(larr[i])) // ������� � ���ᨢ ��㣨 �� "700"
        next
      endif
    endif
    make_diagP(2)  // ᤥ���� "��⨧����" ��������
    if m1dispans > 0
      s1dispans := m1dispans
    endif
    //
    Use_base("lusl")
    Use_base("luslc")
    Use_base("uslugi")
    R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                                dir_server+"uslugi1s"},"USL1")
    mcena_1 := mu_cena := 0
    arr_usl_dop := {}
    arr_usl_otkaz := {}
    arr_otklon := {}
    glob_podr := "" ; glob_otd_dep := 0
    for i := 1 to len(arr_osm1)
      if valtype(arr_osm1[i,5]) == "C"
        arr_osm1[i,7] := foundOurUsluga(arr_osm1[i,5],mk_data,arr_osm1[i,4],M1VZROS_REB,@mu_cena)
        arr_osm1[i,8] := mu_cena
        mcena_1 += mu_cena
        if eq_any(arr_osm1[i,10],0,3) // �믮�����
          aadd(arr_usl_dop,arr_osm1[i])
          if arr_osm1[i,10] == 3 // �����㦥�� �⪫������
            aadd(arr_otklon,arr_osm1[i,5])
          endif
        else // �⪠� � �������������
          aadd(arr_usl_otkaz,arr_osm1[i])
        endif
      endif
    next
    //
    Use_base("human")
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
    //
    st_N_DATA := MN_DATA
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
    human->TIP_H      := B_STANDART // 3-��祭�� �����襭�
    human->FIO        := MFIO          // �.�.�. ���쭮��
    human->POL        := MPOL          // ���
    human->DATE_R     := MDATE_R       // ��� ஦����� ���쭮��
    human->VZROS_REB  := M1VZROS_REB   // 0-�����, 1-ॡ����, 2-�����⮪
    human->ADRES      := MADRES        // ���� ���쭮��
    human->MR_DOL     := MMR_DOL       // ���� ࠡ��� ��� ��稭� ���ࠡ�⭮��
    human->RAB_NERAB  := M1RAB_NERAB   // 0-ࠡ���騩, 1-��ࠡ���騩, 2-��㤥��
    human->KOD_DIAG   := MKOD_DIAG     // ��� 1-�� ��.�������
    human->KOD_DIAG2  := MKOD_DIAG2    // ��� 2-�� ��.�������
    human->KOD_DIAG3  := MKOD_DIAG3    // ��� 3-�� ��.�������
    human->KOD_DIAG4  := MKOD_DIAG4    // ��� 4-�� ��.�������
    human->SOPUT_B1   := MSOPUT_B1     // ��� 1-�� ᮯ������饩 �������
    human->SOPUT_B2   := MSOPUT_B2     // ��� 2-�� ᮯ������饩 �������
    human->SOPUT_B3   := MSOPUT_B3     // ��� 3-�� ᮯ������饩 �������
    human->SOPUT_B4   := MSOPUT_B4     // ��� 4-�� ᮯ������饩 �������
    human->diag_plus  := mdiag_plus    //
    human->KOMU       := M1KOMU        // �� 0 �� 5
    human_->SMO       := msmo
    human->STR_CRB    := m1str_crb
    human->POLIS      := make_polis(mspolis,mnpolis) // ��� � ����� ���客��� �����
    human->LPU        := M1LPU         // ��� ��०�����
    human->OTD        := M1OTD         // ��� �⤥�����
    human->UCH_DOC    := MUCH_DOC      // ��� � ����� ��⭮�� ���㬥��
    human->N_DATA     := MN_DATA       // ��� ��砫� ��祭��
    human->K_DATA     := MK_DATA       // ��� ����砭�� ��祭��
    human->CENA := human->CENA_1 := MCENA_1 // �⮨����� ��祭��
    human->ishod      := 200+metap
    human->OBRASHEN   := iif(m1DS_ONK == 1, '1', " ")
    human->bolnich    := 0
    human->date_b_1   := ""
    human->date_b_2   := ""
    human_->RODIT_DR  := ctod("")
    human_->RODIT_POL := ""
    s := "" ; aeval(adiag_talon, {|x| s += str(x,1) })
    human_->DISPANS   := s
    human_->STATUS_ST := ""
    human_->POVOD     := iif(metap == 3, 5, 6)
    //human_->TRAVMA    := m1travma
    human_->VPOLIS    := m1vidpolis
    human_->SPOLIS    := ltrim(mspolis)
    human_->NPOLIS    := ltrim(mnpolis)
    human_->OKATO     := "" // �� ���� ������� �� ����� � ��砥 �����த����
    human_->NOVOR     := 0
    human_->DATE_R2   := ctod("")
    human_->POL2      := ""
    human_->USL_OK    := m1USL_OK
    human_->VIDPOM    := m1VIDPOM
    human_->PROFIL    := m1PROFIL
    human_->IDSP      := iif(metap == 3, 17, 11)
    human_->NPR_MO    := ''
    human_->FORMA14   := '0000'
    human_->KOD_DIAG0 := ''
    human_->RSLT_NEW  := m1rslt
    human_->ISHOD_NEW := m1ishod
    human_->VRACH     := m1vrach
    human_->PRVS      := m1prvs
    human_->OPLATA    := 0 // 㡥�� "2", �᫨ ��।���஢��� ������ �� ॥��� �� � ��
    human_->ST_VERIFY := 0 // ᭮�� ��� �� �஢�७
    if Loc_kod == 0  // �� ����������
      human_->ID_PAC    := mo_guid(1,human_->(recno()))
      human_->ID_C      := mo_guid(2,human_->(recno()))
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
        human_->SMO := m1ismo  // �����塞 "34" �� ��� �����த��� ���
      endif
    endif
    if fl_nameismo .or. rec_inogSMO > 0
      G_Use(dir_server+"mo_hismo",,"SN")
      index on str(kod,7) to (cur_dir+"tmp_ismo")
      find (str(mkod,7))
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
    Use_base("human_u")
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
      hu->kod_vr  := arr_usl_dop[i,1]
      hu->kod_as  := arr_usl_dop[i,3]
      hu->u_koef  := 1
      hu->u_kod   := arr_usl_dop[i,7]
      hu->u_cena  := arr_usl_dop[i,8]
      hu->is_edit := iif(len(arr_usl_dop[i]) > 10 .and. valtype(arr_usl_dop[i,11]) == "N", arr_usl_dop[i,11], 0)
      hu->date_u  := dtoc4(arr_usl_dop[i,9])
      hu->otd     := m1otd
      hu->kol := hu->kol_1 := 1
      hu->stoim := hu->stoim_1 := arr_usl_dop[i,8]
      hu->KOL_RCP := 0
      select HU_
      do while hu_->(lastrec()) < mrec_hu
        APPEND BLANK
      enddo
      goto (mrec_hu)
      G_RLock(forever)
      if i > i1 .or. !valid_GUID(hu_->ID_U)
        hu_->ID_U := mo_guid(3,hu_->(recno()))
      endif
      hu_->PROFIL := arr_usl_dop[i,4]
      hu_->PRVS   := arr_usl_dop[i,2]
      hu_->kod_diag := iif(empty(arr_usl_dop[i,6]), MKOD_DIAG, arr_usl_dop[i,6])
      hu_->zf := ""
      UNLOCK
    next
    if i2 < i1
      for i := i2+1 to i1
        select HU
        goto (arr_usl[i])
        DeleteRec(.t.,.f.)  // ���⪠ ����� ��� ����⪨ �� 㤠�����
      next
    endif
    save_arr_DVN(mkod)
    // ���ࠢ����� �� �����७�� �� ���
    cur_napr := 0
    arr := {}
    G_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","NAPR") // �������ࠢ�����
    find (str(mkod,7))
    do while napr->kod == mkod .and. !eof()
      aadd(arr,recno())
      skip
    enddo
    if m1ds_onk == 1 // �����७�� �� �������⢥���� ������ࠧ������
      Use_base("mo_su")
      use (cur_dir+"tmp_onkna") new alias TNAPR
      select TNAPR
      go top
      do while !eof()
        if !emptyany(tnapr->NAPR_DATE,tnapr->NAPR_V)
          if tnapr->U_KOD == 0 // ������塞 � ᢮� �ࠢ�筨� 䥤�ࠫ��� ����
            select MOSU
            set order to 3
            find (tnapr->shifr1)
            if found()  // ����୮�, �������� ⮫쪮 ��
              tnapr->U_KOD := mosu->kod
            else
              set order to 1
              FIND (STR(-1,6))
              if found()
                G_RLock(forever)
              else
                AddRec(6)
              endif
              tnapr->U_KOD := mosu->kod := recno()
              mosu->name   := tnapr->name_u
              mosu->shifr1 := tnapr->shifr1
            endif
          endif
          select NAPR
          if ++cur_napr > len(arr)
            AddRec(7)
            napr->kod := mkod
          else
            goto (arr[cur_napr])
            G_RLock(forever)
          endif
          napr->NAPR_DATE := tnapr->NAPR_DATE
          napr->NAPR_MO := tnapr->NAPR_MO
          napr->NAPR_V := tnapr->NAPR_V
          napr->MET_ISSL := iif(tnapr->NAPR_V == 3, tnapr->MET_ISSL, 0)
          napr->U_KOD := iif(tnapr->NAPR_V == 3, tnapr->U_KOD, 0)
        endif
        select TNAPR
        skip
      enddo
    endif
    select NAPR
    do while ++cur_napr <= len(arr)
      goto (arr[cur_napr])
      DeleteRec(.t.)
    enddo
    write_work_oper(glob_task,OPER_LIST,iif(Loc_kod==0,1,2),1,count_edit)
    fl_write_sluch := .t.
    close databases
    stat_msg("������ �����襭�!",.f.)
  endif
  exit
enddo
close databases
setcolor(tmp_color)
restscreen(buf)
chm_help_code := tmp_help
if fl_write_sluch // �᫨ ����ᠫ� - ����᪠�� �஢���
  if type("fl_edit_DVN") == "L"
    fl_edit_DVN := .t.
  endif
  if !empty(val(msmo))
    verify_OMS_sluch(glob_perso)
  endif
endif
return NIL


*

***** 23.01.17
Function f_valid_diag_oms_sluch_DVN_COVID_2(get,k)
Local sk := lstr(k)
Private pole_diag := "mdiag"+sk,;
        pole_d_diag := "mddiag"+sk,;
        pole_pervich := "mpervich"+sk,;
        pole_1pervich := "m1pervich"+sk,;
        pole_stadia := "m1stadia"+sk,;
        pole_dispans := "mdispans"+sk,;
        pole_1dispans := "m1dispans"+sk,;
        pole_d_dispans := "mddispans"+sk
if get == NIL .or. !(&pole_diag == get:original)
  if empty(&pole_diag)
    &pole_pervich := space(12)
    &pole_1pervich := 0
    &pole_d_diag := ctod("")
    &pole_stadia := 1
    &pole_dispans := space(3)
    &pole_1dispans := 0
    &pole_d_dispans := ctod("")
  else
    &pole_pervich := inieditspr(A__MENUVERT, mm_pervich, &pole_1pervich)
    &pole_dispans := inieditspr(A__MENUVERT, mm_danet, &pole_1dispans)
  endif
endif
if emptyall(m1dispans1,m1dispans2,m1dispans3,m1dispans4,m1dispans5)
  m1dispans := 0
elseif m1dispans == 0
  m1dispans := ps1dispans
endif
mdispans := inieditspr(A__MENUVERT, mm_dispans, m1dispans)
update_get(pole_pervich)
update_get(pole_d_diag)
update_get(pole_stadia)
update_get(pole_dispans)
update_get(pole_d_dispans)
update_get("mdispans")
return .t.

***** 19.06.19 ࠡ��� �� ��㣠 ��� � ����ᨬ��� �� �⠯�, ������ � ����
Function f_is_usl_oms_sluch_DVN_COVID_2(i,_etap,_vozrast,_pol,/*@*/_diag,/*@*/_otkaz,/*@*/_ekg)
Local fl := .f., ars := {}, ar := dvn_arr_usl[i]
if valtype(ar[3]) == "N"
  fl := (ar[3] == _etap)
else
  fl := ascan(ar[3],_etap) > 0
endif
_diag := (ar[4] == 1)
_otkaz := 0
_ekg := .f.
if valtype(ar[2]) == "C"
  aadd(ars,ar[2])
else
  ars := aclone(ar[2])
endif
if eq_any(_etap,1,3) .and. ar[5] == 1 .and. ascan(ars,"4.20.1") == 0
  _otkaz := 1 // ����� ����� �⪠�
  if valtype(ar[2]) == "C" .and. eq_ascan(ars,"7.57.3","7.61.3","4.1.12")
    _otkaz := 2 // ����� ����� �������������
    if ascan(ars,"4.1.12") > 0 // ���⨥ �����
      _otkaz := 3 // �������� �� ��� 䥫���-�����
    endif
  endif
endif
if fl .and. eq_any(_etap,1,4,5)
  if _etap == 1
    i := iif(_pol == "�", 6, 7)
  elseif len(ar) < 14
    return .f.
  else
    i := iif(_pol == "�", 13, 14)
  endif
  if valtype(ar[i]) == "N" // ᯥ樠�쭮 ��� ��㣨 "�����ப�न�����","13.1.1" ࠭�� 2018 ����
    fl := (ar[i] != 0)
    if ar[i] < 0  // ���
      _ekg := (_vozrast < abs(ar[i])) // ����易⥫�� ������
    endif
  else // ��� 1,4,5 �⠯� ������ 㪠��� ���ᨢ��
    fl := ascan(ar[i],_vozrast) > 0
  endif
endif
if fl .and. eq_any(_etap,2,3)
  i := iif(_pol=="�", 8, 9)
  if valtype(ar[i]) == "N"
    fl := (ar[i] != 0)
  elseif type("is_disp_19") == "L" .and. is_disp_19
    fl := ascan(ar[i],_vozrast) > 0
  else // ��� 2 �⠯� � ��䨫��⨪� ������ 㪠��� ����������
    fl := between(_vozrast,ar[i,1],ar[i,2])
  endif
endif
return fl

***** 16.06.19 ࠡ��� �� ��㣠 (㬮�砭��) ��� � ����ᨬ��� �� �⠯�, ������ � ����
Function f_is_umolch_sluch_DVN_COVID_2(i,_etap,_vozrast,_pol)
Local fl := .f., j, ta, ar := dvn_arr_umolch[i]
if _etap > 3
  return fl
endif
if valtype(ar[3]) == "N"
  fl := (ar[3] == _etap)
else
  fl := ascan(ar[3],_etap) > 0
endif
if fl
  if _etap == 1
    i := iif(_pol=="�", 4, 5)
  else//if _etap == 3
    i := iif(_pol=="�", 6, 7)
  endif
  if valtype(ar[i]) == "N"
    fl := (ar[i] != 0)
  elseif valtype(ar[i]) == "C"
    // "18,65" - ��� ��⪮�� ���.���.�������஢����
    ta := list2arr(ar[i])
    for i := len(ta) to 1 step -1
      if _vozrast >= ta[i]
        for j := 0 to 99
          if _vozrast == int(ta[i]+j*3)
            fl := .t. ; exit
          endif
        next
        if fl ; exit ; endif
      endif
    next
  else
    fl := between(_vozrast,ar[i,1],ar[i,2])
  endif
endif
return fl

*

***** 04.02.21 ᪮�४�஢��� ���ᨢ� �� ��ᯠ��ਧ�樨
Function ret_arrays_disp_COVID_2(is_disp_19,tis_disp_21)
Static sp := 0
Local p := iif(is_disp_19, 2, 1), blk
DEFAULT tis_disp_21 TO .t.

if p != sp
  if (sp := p) == 1
    dvn_arr_usl := aclone(dvn_arr_usl18)
    dvn_arr_umolch := aclone(dvn_arr_umolch18)
  else
    blk := {|d1,d2,d|
                      Local i, arr := {}
                      DEFAULT d TO 1
                      for i := d1 to d2 step d
                        aadd(arr,i)
                      next
                      return arr
           }
    // 1- ������������ ����
    // 2- ��� ��㣨
    // 3- �⠯ (1,2,3,4,5)
    // 4- ��-� �易�� � ���������



    //  10- V002 - �����䨪��� ��䨫�� ��������� ����樭᪮� �����
    //  11- V004 - �����䨪��� ����樭᪨� ᯥ樠�쭮�⥩
   if tis_disp_21
     dvn_arr_usl := {; // ��㣨 �� ��࠭ ��� �����
      {"����७�� ����ਣ������� ��������","3.4.9",1,0,1,;
        eval(blk,40,99),;
        eval(blk,40,99),;
        1,1,65,{1112};
       },;
      {"��᫥������� �஢� �� ��騩 宫���ਭ","4.12.174",{1,3},0,1,;
        1,1,1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"��᫥������� �஢�� ���� � �஢�","4.12.169",{1,3},0,1,;
        1,1,1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"��᫥������� �஢� �� �����஢���� ����-��","4.12.775",2,0,1,;
        1,1,1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"������᪨� ������ �஢� (3 ������⥫�)","4.11.137",1,0,1,;
        eval(blk,40,99),;
        eval(blk,40,99),;
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"��᫥������� ���� �� ������ �஢�","4.8.4",1,0,1,;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,65,66,67,68,69,70,71,72,73,74,75},;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,65,66,67,68,69,70,71,72,73,74,75},;
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"�஢� �� �����-ᯥ���᪨� ��⨣��","4.14.66",1,0,1,;
        {45,50,55,60,64},;
        0,;
        1,0,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"�ᬮ�� ����મ� ��� ����஬-�����������","2.3.1",{1,3},0,1,; // ���騭�
        0,1,0,1,{3,42,136},{2003,2002,1101},;
        {{"2.3.1",136},{"2.3.3",3},{"2.3.3",42}},1,1;
       },;
      {"���⨥ ����� (�᪮��) � ���-� 襩�� ��⪨","4.1.12",1,0,1,; // ���騭�
        0,;
        {18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63},;
        1,1,{3,42,136},{2003,2002,1101};
       },;
      {"���-� ���⮣� �⮫����᪮�� ���ਠ��","4.20.1",1,0,1,; // �᫨ ���������� 4.1.12
        0,;
        {18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63},;     // � ������
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};               // ��� ����
       },;
      {"��������� ����� ������� �����","7.57.3",1,0,1,; // ���騭�
        0,;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74},;
        0,1,78,{1118,1802,2020};
       },;
      {"���ண��� �񣪨� ��䨫����᪠�","7.61.3",{1,3},0,1,;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        78,{1118,1802,2020};
       },;
      {"�����ப�न����� (� �����)","13.1.1",{1,3},0,1,;
        eval(blk,35,99),;
        eval(blk,35,99),;
        eval(blk,35,99),;
        eval(blk,35,99),;
        111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202,2021};
       },;
      {"�������䠣�����த㮤���᪮���","10.3.13",1,0,1,;
        {45},;
        {45},;
        1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"�������䠣�����த㮤���᪮���","10.3.713",2,0,1,;
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"���஬����","16.1.717",2,0,1,; // "2.84.11"
        1,1,1,1,111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202,2021};
       },;
      {"�㯫��᭮� ᪠���-�� ��娮�䠫��� ���਩","8.23.706",2,0,1,; // "2.84.1"
        1,1,1,1,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203};
       },;
      {"���⣥������ �࣠��� ��㤭�� ���⪨","7.2.702",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"�� �࣠��� ��㤭�� ������","7.2.701",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"���ࠫ쭠� �� ������","7.2.703",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"�� �࣠��� ��㤭�� ������ (� ��������-���)","7.2.704",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"�����⮭��� ����ᨮ���� �� ������","7.2.705",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"����ᨣ��������᪮��� ���������᪠�","10.6.710",2,0,1,; // "2.84.6"
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"����஬���᪮���","10.4.701",2,0,1,;                      // "2.84.6"
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"���㡫����� ��䨫����᪮� �������஢����","56.1.723",2,0,1,;
        1,1,1,1,{97,57,42},{1122,1110,2002};
       },;
      {"��� ��� ���஫���","2.84.1",2,1,0,;
        1,1,1,1,53,{1109};
       },;
      {"��� ��� ��⠫쬮����","2.84.3",2,1,0,;
        1,1,1,1,65,{1112};
       },;
      {"��� ��� ��ਭ���ਭ������","2.84.8",2,1,0,;
        1,1,1,1,162,{1111};
       },;
      {"��� ��� �஫��� (���࣠)","2.84.10",2,1,0,;
        1,1,1,0,{108,112},{112603,1126};
       },;
      {"��� ��� �����-����������","2.84.5",2,1,0,;
        1,1,0,1,136,{1101};
       },;
      {"��� ��� �����ப⮫��� (���࣠)","2.84.6",2,1,0,;
        1,1,1,1,{30,30,112},{112601,113503,1126};
       },;
      {"��� ��� ��ଠ⮢���஫��","2.84.14",2,1,0,;
        1,1,1,1,16,{1104};
       },;
      {"��� ��� �࠯���",{"2.3.7","2.84.11","2.3.2"},{1,2,3},1,0,;
        1,1,1,1,{97,57,42},{1122,1110,2002},;
        {{"2.3.7",57},{"2.3.7",97},{"2.3.2",57},{"2.3.2",97},{"2.3.4",42},{"2.84.11",57},{"2.84.11",97}},1,1;
       };
     }
    else
     dvn_arr_usl := {; // ��㣨 �� ��࠭ ��� �����
      {"����७�� ����ਣ������� ��������","3.4.9",1,0,1,;
        eval(blk,40,99),;
        eval(blk,40,99),;
        1,1,65,{1112};
       },;
      {"��᫥������� �஢� �� ��騩 宫���ਭ","4.12.174",{1,3},0,1,;
        1,1,1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"��᫥������� �஢�� ���� � �஢�","4.12.169",{1,3},0,1,;
        1,1,1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"������᪨� ������ �஢� (3 ������⥫�)","4.11.137",1,0,1,;
        eval(blk,40,99),;
        eval(blk,40,99),;
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"��᫥������� ���� �� ������ �஢�","4.8.4",1,0,1,;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,65,66,67,68,69,70,71,72,73,74,75},;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,65,66,67,68,69,70,71,72,73,74,75},;
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"�஢� �� �����-ᯥ���᪨� ��⨣��","4.14.66",1,0,1,;
        {45,50,55,60,64},;
        0,;
        1,0,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"�ᬮ�� ����મ� ��� ����஬-�����������","2.3.1",{1,3},0,1,; // ���騭�
        0,1,0,1,{3,42,136},{2003,2002,1101},;
        {{"2.3.1",136},{"2.3.3",3},{"2.3.3",42}},1,1;
       },;
      {"���⨥ ����� (�᪮��) � ���-� 襩�� ��⪨","4.1.12",1,0,1,; // ���騭�
        0,;
        {18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63},;
        1,1,{3,42,136},{2003,2002,1101};
       },;
      {"���-� ���⮣� �⮫����᪮�� ���ਠ��","4.20.1",1,0,1,; // �᫨ ���������� 4.1.12
        0,;
        {18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63},;     // � ������
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};               // ��� ����
       },;
      {"��������� ����� ������� �����","7.57.3",1,0,1,; // ���騭�
        0,;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74},;
        0,1,78,{1118,1802,2020};
       },;
      {"���ண��� �񣪨� ��䨫����᪠�","7.61.3",{1,3},0,1,;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        78,{1118,1802,2020};
       },;
      {"�����ப�न����� (� �����)","13.1.1",{1,3},0,1,;
        eval(blk,35,99),;
        eval(blk,35,99),;
        eval(blk,35,99),;
        eval(blk,35,99),;
        111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202,2021};
       },;
      {"�������䠣�����த㮤���᪮���","10.3.13",1,0,1,;
        {45},;
        {45},;
        1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"�������䠣�����த㮤���᪮���","10.3.713",2,0,1,;
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"���஬����","16.1.717",2,0,1,; // "2.84.11"
        1,1,1,1,111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202,2021};
       },;
      {"�㯫��᭮� ᪠���-�� ��娮�䠫��� ���਩","8.23.706",2,0,1,; // "2.84.1"
        1,1,1,1,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203};
       },;
      {"���⣥������ �࣠��� ��㤭�� ���⪨","7.2.702",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"�� �࣠��� ��㤭�� ������","7.2.701",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"���ࠫ쭠� �� ������","7.2.703",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"�� �࣠��� ��㤭�� ������ (� ��������-���)","7.2.704",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"�����⮭��� ����ᨮ���� �� ������","7.2.705",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"����ᨣ��������᪮��� ���������᪠�","10.6.710",2,0,1,; // "2.84.6"
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"����஬���᪮���","10.4.701",2,0,1,;                      // "2.84.6"
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"���㡫����� ��䨫����᪮� �������஢����","56.1.723",2,0,1,;
        1,1,1,1,{97,57,42},{1122,1110,2002};
       },;
      {"��� ��� ���஫���","2.84.1",2,1,0,;
        1,1,1,1,53,{1109};
       },;
      {"��� ��� ��⠫쬮����","2.84.3",2,1,0,;
        1,1,1,1,65,{1112};
       },;
      {"��� ��� ��ਭ���ਭ������","2.84.8",2,1,0,;
        1,1,1,1,162,{1111};
       },;
      {"��� ��� �஫��� (���࣠)","2.84.10",2,1,0,;
        1,1,1,0,{108,112},{112603,1126};
       },;
      {"��� ��� �����-����������","2.84.5",2,1,0,;
        1,1,0,1,136,{1101};
       },;
      {"��� ��� �����ப⮫��� (���࣠)","2.84.6",2,1,0,;
        1,1,1,1,{30,30,112},{112601,113503,1126};
       },;
      {"��� ��� �࠯���",{"2.3.7","2.84.11","2.3.2"},{1,2,3},1,0,;
        1,1,1,1,{97,57,42},{1122,1110,2002},;
        {{"2.3.7",57},{"2.3.7",97},{"2.3.2",57},{"2.3.2",97},{"2.3.4",42},{"2.84.11",57},{"2.84.11",97}},1,1;
       };
     }
    endif
    //
    dvn_arr_umolch := {; // ��㣨, �����뢠��� �ᥣ�� �� 㬮�砭��
      {"���� (�����஢����)","56.1.16",{1,3},1,1,1,1,0},;
      {"����७�� ���ਠ�쭮�� ��������","3.1.5",{1,3},1,1,1,1,0},;
      {"���ய������, ����� ������ ����� ⥫�","3.1.19",{1,3},1,1,1,1,0},;
      {"��।������ �⭮�⥫쭮�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠","56.1.18",{1,3},{18,39},{18,39},{18,39},{18,39},1},;
      {"��।������ ��᮫�⭮�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠","56.1.19",1,{40,64},{40,64},1,1,1},;
      {"��⪮� �������㠫쭮� ��䨫����᪮� �������஢����","56.1.14",1,"18,65","18,65",1,1,1};
    }
  endif
  count_dvn_arr_usl := len(dvn_arr_usl)
  count_dvn_arr_umolch := len(dvn_arr_umolch)
endif
return NIL

***** 15.06.18 ᪮�४�஢��� ������ ��ᯠ��ਧ�樨 ��� ���࠭��
/*Function ret_vozr_DVN_veteran(_dvozrast,_data)
Local i, _arr_vozrast_DVN := ret_arr_vozrast_DVN(_data)
if ascan(_arr_vozrast_DVN,_dvozrast) == 0
  if _dvozrast < _arr_vozrast_DVN[1]
    _dvozrast := _arr_vozrast_DVN[1]
  elseif _dvozrast > atail(_arr_vozrast_DVN)
    _dvozrast := atail(_arr_vozrast_DVN)
  else
    for i := 2 to len(_arr_vozrast_DVN)
      if between(_dvozrast,_arr_vozrast_DVN[i-1],_arr_vozrast_DVN[i])
        if _dvozrast == _arr_vozrast_DVN[i-1] + 1
          _dvozrast := _arr_vozrast_DVN[i-1]
        else
          _dvozrast := _arr_vozrast_DVN[i]
        endif
        exit
      endif
    next
  endif
endif
return _dvozrast
*/

***** 15.06.19 ������ ���ᨢ �����⮢ ���-�� ��� ��ண� ��� ������ �ਪ���� �� ��
Function ret_arr_vozrast_DVN_COVID_2(_data)
Static sp := 0, arr := {}
Local i, p := iif(_data < d_01_05_2019, 1, 2)
if p != sp
  arr := aclone(arr_vozrast_DVN) // �� ��஬� �ਪ��� �� ��
  if (sp := p) == 2 // �� ������ �ਪ��� �� ��
    asize(arr,7) // 㡥�� 墮�� ��᫥ 39 ��� {21,24,27,30,33,36,39,
    Ins_Array(arr,1,18) // ��⠢�� � ��砫� =18 ���
    for i := 40 to 99
      aadd(arr,i) // ������� � ����� ����� � 40 �� 99 ���
    next
  endif
endif
return arr


***** 02.07.19
Function ret_ndisp_COVID_2(lkod_h,lkod_k,/*@*/new_etap,/*@*/msg)
Local i, i1, i2, i3, i4, i5, s, s1, is_disp, ar, fl := .t.
is_disp_19 := !(mk_data < d_01_05_2019)
is_disp_21 := !(mk_data < d_01_01_2021)
ret_arrays_disp(is_disp_19,is_disp_21)
msg := " "
new_etap := metap
is_dostup_2_year := .f.
if m1veteran == 1
  mdvozrast := ret_vozr_DVN_veteran(mdvozrast,mk_data)
endif
if !(is_disp := ascan(ret_arr_vozrast_DVN(mk_data),mdvozrast) > 0)
  if !is_disp_19 // �� ��஬� �ਪ��� �� ��
    is_dostup_2_year := ascan(arr2m_vozrast_DVN,mdvozrast) > 0
    if !is_dostup_2_year .and. mpol == "�"
      is_dostup_2_year := ascan(arr2g_vozrast_DVN,mdvozrast) > 0
    endif
  endif
endif
if metap == 0
  if is_disp
    new_etap := 1
  else
    new_etap := 3
  endif
elseif metap == 3
  if is_disp
    new_etap := 1
  else
    // ������� = 3
  endif
else
  if is_disp
    // ������� = 1 ��� 2
  elseif new_etap < 4
    new_etap := 3
  endif
endif
ar := ret_etap_DVN_COVID_2(lkod_h,lkod_k)
if new_etap != 3
  if empty(ar[1]) // � �⮬ ���� ��� ��祣� �� ������
    // ��⠢�塞 1
  else
    i1 := i2 := i3 := i4 := i5 := 0
    for i := 1 to len(ar[1])
      do case
        case ar[1,i,1] == 1 // ���-�� 1 �⠯
          i1 := i
        case ar[1,i,1] == 2 // ���-�� 2 �⠯
          i2 := i
        case ar[1,i,1] == 3 // ��䨫��⨪�
          i3 := i
          msg := date_8(ar[1,i,2])+"�. 㦥 �஢��� ��䨫����᪨� ����ᬮ��!"
        case ar[1,i,1] == 4 // ���-�� 1 �⠯ 1 ࠧ � 2 ����
          i4 := i
          msg := "� "+lstr(year(mn_data))+" ���� 㦥 �஢����� ��ᯠ��ਧ�樨 1 ࠧ � 2 ����"
        case ar[1,i,1] == 5 // ���-�� 2 �⠯ 1 ࠧ � 2 ����
          i5 := i
          msg := "� "+lstr(year(mn_data))+" ���� 㦥 �஢����� ��ᯠ��ਧ�樨 1 ࠧ � 2 ����"
      endcase
    next
    if eq_any(new_etap,1,2) .and. new_etap != metap
      if i1 == 0
        new_etap := 1 // ������ 1 �⠯
      elseif i2 == 0
        new_etap := 2 // ������ 2 �⠯
      endif
    endif
    if i1 > 0 .and. i2 > 0
      msg := "� "+lstr(year(mn_data))+" ���� 㦥 �஢����� ��� �⠯� ��ᯠ��ਧ�樨!"
    elseif i1 > 0 .and. !empty(ar[1,i1,2]) .and. ar[1,i1,2] > mn_data
      msg := "��ᯠ��ਧ��� I �⠯� �����稫��� "+date_8(ar[1,i1,2])+"�.!"
    endif
    if eq_any(new_etap,4,5) .and. new_etap != metap
      if i4 == 0
        new_etap := 4 // ������ 1 �⠯
      elseif i5 == 0
        new_etap := 5 // ������ 2 �⠯
      endif
    endif
    if i4 > 0 .and. i5 > 0
      msg := "� "+lstr(year(mn_data))+" ���� 㦥 �஢����� ��� �⠯� ��ᯠ��ਧ�樨 (ࠧ � 2 ����)!"
    elseif i4 > 0 .and. !empty(ar[1,i4,2]) .and. ar[1,i4,2] > mn_data
      msg := "��ᯠ��ਧ��� I �⠯� (ࠧ � 2 ����) �����稫��� "+date_8(ar[1,i4,2])+"�.!"
    endif
  endif
else //if new_etap == 3
  if empty(ar[1]) // � �⮬ ���� ��� ��祣� �� ������
    if empty(ar[2]) // ��ᬮ�ਬ ���� ���
      // ��⠢�塞 3
    elseif ascan(ar[2],{|x| x[1] == 3 }) > 0 // ��䨫��⨪� �뫠 � ��諮� ����
      if is_dostup_2_year
        new_etap := 4 // �ࠧ� ࠧ�蠥� ���-�� 1 ࠧ � 2 ����, �.�. � ��諮�
      else
        msg := "��䨫��⨪� �஢������ 1 ࠧ � 2 ���� ("+date_8(ar[2,1,2])+"�. 㦥 �஢�����)"
      endif
    endif
  else
    i1 := i2 := i3 := i4 := i5 := 0
    for i := 1 to len(ar[1])
      do case
        case ar[1,i,1] == 1 // ���-�� 1 �⠯
          i1 := i
          msg := date_8(ar[1,i,2])+"�. 㦥 �஢����� ��ᯠ��ਧ��� I �⠯�!"
        case ar[1,i,1] == 2 // ���-�� 2 �⠯
          i2 := i
          msg := date_8(ar[1,i,2])+"�. 㦥 �஢����� ��ᯠ��ਧ��� II �⠯�!"
        case ar[1,i,1] == 3 // ��䨫��⨪�
          i3 := i
          msg := date_8(ar[1,i,2])+"�. 㦥 �஢��� ��䨫����᪨� ����ᬮ��!"
        case ar[1,i,1] == 4 // ���-�� 1 �⠯ ࠧ � 2 ����
          i4 := i
        case ar[1,i,1] == 5 // ���-�� 2 �⠯ ࠧ � 2 ����
          i5 := i
      endcase
    next
    if i4 > 0
      if i5 > 0
        msg := "� "+lstr(year(mn_data))+" ���� 㦥 �஢����� ��� �⠯� ��ᯠ��ਧ�樨 (ࠧ � 2 ����)!"
      elseif !empty(ar[1,i4,2]) .and. ar[1,i4,2] > mn_data
        msg := "��ᯠ��ਧ��� I �⠯� (ࠧ � 2 ����) �����稫��� "+date_8(ar[1,i4,2])+"�.!"
      else
        new_etap := 5 // ������ 2 �⠯
      endif
    endif
  endif
endif
if empty(msg)
  metap := new_etap
  mndisp := inieditspr(A__MENUVERT, mm_ndisp, metap)
else
  metap := 0
  mndisp := space(23)
  func_error(4,fam_i_o(mfio)+" "+msg)
endif
return fl

***** 15.06.19
Function ret_etap_DVN_COVID_2(lkod_h,lkod_k)
Local ae := {{},{}}, fl, i, k, d1 := year(mn_data)
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
set relation to recno() into HUMAN_
find (str(lkod_k,7))
do while human->kod_k == lkod_k .and. !eof()
  fl := (lkod_h != human->(recno()))
  if fl .and. human->schet > 0 .and. human_->oplata == 9
    fl := .f. // ���� ���� ��� �� ���� � ���⠢��� ����୮
  endif
  if fl .and. between(human->ishod,201,205) // ???
    i := human->ishod-200
    if year(human->n_data) == d1 // ⥪�騩 ���
      aadd(ae[1],{i,human->k_data,human_->RSLT_NEW})
    //elseif i >= 3 .and. mk_data < d_01_05_2019 .and. year(human->n_data) == d1-1 // ��䨫��⨪� ���� ��� ???
      //aadd(ae[2],{i,human->k_data,human_->RSLT_NEW})
    endif
  endif
  skip
enddo
close databases
return ae

***** 08.08.13 ������ ⨯ ����� � ��ப�
Function ret_tip_mas_COVID_2(_WEIGHT,_HEIGHT,/*@*/ret)
Static mm_tip_mas := {{"����� ����� ⥫�",0,18.4},;
                      {"��ଠ�쭠� ���� ⥫�",18.5,24.9},;
                      {"�����筠� ���� ⥫�",25.0,29.9},;
                      {"���७�� I �⥯���",30.0,34.9},;
                      {"���७�� II �⥯���",35.0,39.9},;
                      {"���७�� III �⥯���",40.0,9999}}
Local i, k, s := ""
ret := 2
if !emptyany(_WEIGHT,_HEIGHT)
  _HEIGHT /= 100  // ��� �� ᠭ⨬��஢ � �����
  k := round(_WEIGHT/_HEIGHT/_HEIGHT,1) // ������ ��⫥
  if (i := ascan(mm_tip_mas,{|x| between(k,x[2],x[3]) })) > 0
    ret := i
    s := mm_tip_mas[i,1]
  endif
endif
return padr(s,21)

***** 16.02.2020 ���� �� ��室�� (�ࠧ�����) ��� �஢������ ��ᯠ��ਧ�樨
Function f_is_prazdnik_DVN_COVID_2(_n_data)
return !is_work_day(_n_data)

/*
70.7.1	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (��稭� 18,24,30)
70.7.2	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (��稭� 21,27,33)
70.7.3	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (��稭� 40,44,46,52,56,58,62)
70.7.4	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (��稭� 42,48,54)
70.7.5	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (��稭� 41,43,47,49,53,59)
70.7.6	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (��稭� 50,64)
70.7.7	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (��稭� 51,57,63)
70.7.8	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (��稭� 55)
70.7.9	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (��稭� 60)
70.7.10	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (��稭� 61)
70.7.11	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (��稭� 36)
70.7.12	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (��稭� 39)
70.7.13	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (��稭� 45)
70.7.14	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (���騭� 18,24,30)
70.7.15	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (���騭� 21,27,33)
70.7.16	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (���騭� 42,48,54,60)
70.7.17	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (���騭� 40,44,46,50,52,56,58,62,64)
70.7.18	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (���騭� 41,43,47,49)
70.7.19	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (���騭� 51,57,63)
70.7.20	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (���騭� 53,55,59,61)
70.7.21	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (���騭� 36)
70.7.22	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (���騭� 39)
70.7.23	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (���騭� 45)
70.7.24	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (65,71)
70.7.25	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (66,70,72)
70.7.26	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (67,69,73,75)
70.7.27	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (68,74)
70.7.28	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (76,78,82,84,88,90,94,96)
70.7.29	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (80,86,92,98)
70.7.30	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (77,83,89,95)
70.7.31	�����祭�� ��砩 ��ᯠ��ਧ�樨 ������ 1 �⠯ (79,81,85,87,91,93,97,99)
*/
***** 16.02.20 ������ ��� ��㣨 �����祭���� ���� ��� ���
Function ret_shifr_zs_DVN_COVID_2(_etap,_vozrast,_pol,_date)
Local lshifr := "", fl, is_disp, n := 1
if _date >= 0d20190501 // � 1 ���
  if _etap == 1
    if _pol == "�" // ��稭�
      if eq_any(_vozrast,18,24,30)
        n := 1
      elseif eq_any(_vozrast,21,27,33)
        n := 2
      elseif eq_any(_vozrast,40,44,46,52,56,58,62)
        n := 3
      elseif eq_any(_vozrast,42,48,54)
        n := 4
      elseif eq_any(_vozrast,41,43,47,49,53,59)
        n := 5
      elseif eq_any(_vozrast,50,64)
        n := 6
      elseif eq_any(_vozrast,51,57,63)
        n := 7
      elseif _vozrast == 55
        n := 8
      elseif _vozrast == 60
        n := 9
      elseif _vozrast == 61
        n := 10
      elseif _vozrast == 36
        n := 11
      elseif _vozrast == 39
        n := 12
      elseif _vozrast == 45
        n := 13
      elseif eq_any(_vozrast,65,71)
        n := 24
      elseif eq_any(_vozrast,66,70,72)
        n := 25
      elseif eq_any(_vozrast,67,69,73,75)
        n := 26
      elseif eq_any(_vozrast,68,74)
        n := 27
      elseif eq_any(_vozrast,76,78,82,84,88,90,94,96)
        n := 28
      elseif eq_any(_vozrast,80,86,92,98)
        n := 29
      elseif eq_any(_vozrast,77,83,89,95)
        n := 30
      elseif eq_any(_vozrast,79,81,85,87,91,93,97,99)
        n := 31
      endif
    else // ���騭�
      if eq_any(_vozrast,18,24,30)
        n := 14
      elseif eq_any(_vozrast,21,27,33)
        n := 15
      elseif eq_any(_vozrast,42,48,54,60)
        n := 16
      elseif eq_any(_vozrast,40,44,46,50,52,56,58,62,64)
        n := 17
      elseif eq_any(_vozrast,41,43,47,49)
        n := 18
      elseif eq_any(_vozrast,51,57,63)
        n := 19
      elseif eq_any(_vozrast,53,55,59,61)
        n := 20
      elseif _vozrast == 36
        n := 21
      elseif _vozrast == 39
        n := 22
      elseif _vozrast == 45
        n := 23
      elseif eq_any(_vozrast,65,71)
        n := 32
      elseif eq_any(_vozrast,66,70,72)
        n := 33
      elseif eq_any(_vozrast,67,69,73,75)
        n := 34
      elseif eq_any(_vozrast,68,74)
        n := 35
      elseif eq_any(_vozrast,76,78,82,84,88,90,94,96)
        n := 36
      elseif eq_any(_vozrast,77,83,89,95)
        n := 37
      elseif eq_any(_vozrast,79,81,85,87,91,93,97,99)
        n := 38
      elseif eq_any(_vozrast,80,86,92,98)
        n := 39
      endif
    endif
    if m1g_cit == 2
      if m1mobilbr == 1
        n += 600
      else
        n += 500
      endif
    else
      if is_prazdnik
        n += 700
      elseif m1mobilbr == 1
        n += 300
      endif
    endif
    lshifr := "70.7."+lstr(n)
  elseif _etap == 3
    is_disp := (ascan(ret_arr_vozrast_DVN(_date),_vozrast) > 0)
/*
72.5.1	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ (��稭� 19,23,25,29,31)
72.5.2	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ (��稭� 20,22,26,28,32,34)
72.5.3	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ (��稭� 35,37)
72.5.4	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ (��稭� 38)
72.5.5	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ (���騭� 19,23,25,29,31)
72.5.6	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ (���騭� 20,22,26,28,32,34)
72.5.7	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ (���騭� 35,37)
72.5.8	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ (���騭� 38)
*/
    if !is_disp // ���ᬮ�� ��ଫ�� ��� ���筮
      if _pol == "�" // ��稭�
        if eq_any(_vozrast,19,23,25,29,31)
          n := 1
        elseif eq_any(_vozrast,20,22,26,28,32,34)
          n := 2
        elseif eq_any(_vozrast,35,37)
          n := 3
        else // _vozrast == 38
          n := 4
        endif
      else // ���騭�
        if eq_any(_vozrast,19,23,25,29,31)
          n := 5
        elseif eq_any(_vozrast,20,22,26,28,32,34)
          n := 6
        elseif eq_any(_vozrast,35,37)
          n := 7
        else // _vozrast == 38
          n := 8
        endif
      endif
      if is_prazdnik
        n += 700
      elseif m1mobilbr == 1
        n += 300
      endif
      // "6" - � ࠬ��� ��ᯠ��୮�� �������
      fl := .t.
      if type("is_disp_nabl") == "L" .and. is_disp_nabl
        fl := .f.
      endif
      lshifr := "72."+iif(fl,"5","6")+"."+lstr(n)
    else // �᫨ ����� ��ᯠ��ਧ�樨 ��ଫ���� ���ᬮ��
/*
72.7.1	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (��稭� 18,24,30)
72.7.2	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (��稭� 21,27,33)
72.7.3	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (��稭� 40,42,44,46,48,50,52,54,56,58,60,62,64)
72.7.4	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (��稭� 41,43,45,47,49,51,53,55,57,59,61,63)
72.7.5	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (��稭� 36)
72.7.6	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (��稭� 39)
72.7.7	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (���騭� 18,24,30)
72.7.8	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (���騭� 21,27,33)
72.7.9	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (���騭� 40,42,44,46,48,50,52,54,56,58,60,62,64)
72.7.10	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (���騭� 41,43,45,47,49,51,53,55,57,59,61,63)
72.7.11	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (���騭� 36)
72.7.12	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (���騭� 39)
72.7.13	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (��稭� 65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99)
72.7.14	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (��稭� 66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98)
72.7.15	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (���騭� 65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99)
72.7.16	�����祭�� ��砩 ��䨫����᪮�� ����樭᪮�� �ᬮ�� ������ � ��� ��ᯠ��ਧ�樨 (���騭� 66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98)
*/
      if _pol == "�" // ��稭�
        if eq_any(_vozrast,18,24,30)
          n := 1
        elseif eq_any(_vozrast,21,27,33)
          n := 2
        elseif eq_any(_vozrast,40,42,44,46,48,50,52,54,56,58,60,62,64)
          n := 3
        elseif eq_any(_vozrast,41,43,45,47,49,51,53,55,57,59,61,63)
          n := 4
        elseif _vozrast == 36
          n := 5
        elseif _vozrast == 39
          n := 6
        elseif eq_any(_vozrast,65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99)
          n := 13
        elseif eq_any(_vozrast,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98)
          n := 14
        endif
      else // ���騭�
        if eq_any(_vozrast,18,24,30)
          n := 7
        elseif eq_any(_vozrast,21,27,33)
          n := 8
        elseif eq_any(_vozrast,40,42,44,46,48,50,52,54,56,58,60,62,64)
          n := 9
        elseif eq_any(_vozrast,41,43,45,47,49,51,53,55,57,59,61,63)
          n := 10
        elseif _vozrast == 36
          n := 11
        elseif _vozrast == 39
          n := 12
        elseif eq_any(_vozrast,65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99)
          n := 15
        elseif eq_any(_vozrast,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98)
          n := 16
        endif
      endif
      if is_prazdnik
        n += 700
      elseif m1mobilbr == 1
        n += 300
      endif
      lshifr := "72.7."+lstr(n)
    endif
  endif
elseif _etap == 1 // �� 1 ���
  if _pol == "�" // ��稭�
    if eq_any(_vozrast,21,24,27,30,33)
      lshifr := iif(m1lis > 0, "70.3.98", "70.3.97")
//70.3.97 �� ���-�� ��稭 (21,24,27,30,33 ���), 1 �⠯
//70.3.98 �� ���-�� ��稭 (21,24,27,30,33 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
    elseif eq_any(_vozrast,36,39,42,48,54)
      lshifr := iif(m1lis > 0, "70.3.100", "70.3.99")
//70.3.99 �� ���-�� ��稭 (36,39,42,48,54 ���), 1 �⠯
//70.3.100 �� ���-�� ��稭 (36,39,42,48,54 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
    elseif _vozrast == 45
      lshifr := iif(m1lis > 0, "70.3.199", "70.3.198")
//70.3.198 �� ���-�� ��稭 (45 ���), 1 �⠯
//70.3.199 �� ���-�� ��稭 (45 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
    elseif _vozrast == 51
      lshifr := iif(m1lis > 0, "70.3.105", "70.3.104")
//70.3.104 �� ���-�� ��稭 (51 ����), 1 �⠯
//70.3.105 �� ���-�� ��稭 (51 ����) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
    elseif _vozrast == 57
      lshifr := iif(m1lis > 0, "70.3.109", "70.3.108")
//70.3.108 �� ���-�� ��稭 (57 ���), 1 �⠯
//70.3.109 �� ���-�� ��稭 (57 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
    elseif _vozrast == 60
      lshifr := iif(m1lis > 0, "70.3.113", "70.3.112")
//70.3.112 �� ���-�� ��稭 (60 ���), 1 �⠯
//70.3.113 �� ���-�� ��稭 (60 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
    elseif _vozrast == 63
      lshifr := iif(m1lis > 0, "70.3.115", "70.3.114")
//70.3.114 �� ���-�� ��稭 (63 ���), 1 �⠯
//70.3.115 �� ���-�� ��稭 (63 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
    elseif eq_any(_vozrast,66,72)
      lshifr := iif(m1lis > 0, "70.3.103", "70.3.102")
//70.3.102 �� ���-�� ��稭 (66,72 ���), 1 �⠯
//70.3.103 �� ���-�� ��稭 (66,72 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
    elseif _vozrast == 69
      lshifr := iif(m1lis > 0, "70.3.119", "70.3.118")
//70.3.118 �� ���-�� ��稭 (69 ���), 1 �⠯
//70.3.119 �� ���-�� ��稭 (69 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
    elseif eq_any(_vozrast,75,78,81,84)
      lshifr := iif(m1lis > 0, "70.3.165", "70.3.164")
//70.3.164 �� ���-�� ��稭 (75,78,81,84 ���), 1 �⠯
//70.3.165 �� ���-�� ��稭 (75,78,81,84 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
    else//if eq_any(_vozrast,87,90,93,96,99)
      lshifr := iif(m1lis > 0, "70.3.167", "70.3.166")
//70.3.166 �� ���-�� ��稭 (87,90,93,96,99 ���), 1 �⠯
//70.3.167 �� ���-�� ��稭 (87,90,93,96,99 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
    endif
  else // ���騭�
    if m1lis > 0 // ��� ����⮫����᪨� ���-��
      if eq_any(_vozrast,21,24,27)
        lshifr := "70.3.123"
//70.3.123 �� ���-�� ���騭 (21,24,27 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
      elseif eq_any(_vozrast,30,33,36)
        lshifr := iif(m1g_cit == 2, "70.3.173", "70.3.125")
//70.3.125 �� ���-�� ���騭 (30,33,36 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
//70.3.173 �� ���-�� ���騭 (30,33,36 ���) ��� ����⮫����᪨� ��᫥�������, ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif _vozrast == 39
        lshifr := iif(m1g_cit == 2, "70.3.175", "70.3.127")
//70.3.127 �� ���-�� ���騭 (39 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
//70.3.175 �� ���-�� ���騭 (39 ���) ��� ����⮫����᪨� ��᫥�������, ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif _vozrast == 42
        lshifr := iif(m1g_cit == 2, "70.3.179", "70.3.131")
//70.3.131 �� ���-�� ���騭 (42 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
//70.3.179 �� ���-�� ���騭 (42 ���) ��� ����⮫����᪨� ��᫥�������, ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif eq_any(_vozrast,45,48)
        lshifr := iif(m1g_cit == 2, "70.3.183", "70.3.135")
//70.3.135 �� ���-�� ���騭 (45,48 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
//70.3.183 �� ���-�� ���騭 (45,48 ���) ��� ����⮫����᪨� ��᫥�������, ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif eq_any(_vozrast,51,57)
        lshifr := iif(m1g_cit == 2, "70.3.187", "70.3.149")
//70.3.149 �� ���-�� ���騭 (51,57 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
//70.3.187 �� ���-�� ���騭 (51,57 ���) ��� ����⮫����᪨� ��᫥�������, ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif _vozrast == 54
        lshifr := iif(m1g_cit == 2, "70.3.191", "70.3.153")
//70.3.153 �� ���-�� ���騭 (54 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
//70.3.191 �� ���-�� ���騭 (54 ���) ��� ����⮫����᪨� ��᫥�������, ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif _vozrast == 60
        lshifr := iif(m1g_cit == 2, "70.3.195", "70.3.157")
//70.3.157 �� ���-�� ���騭 (60 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
//70.3.195 �� ���-�� ���騭 (60 ���) ��� ����⮫����᪨� ��᫥�������, ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif _vozrast == 63
        lshifr := "70.3.161"
//70.3.161 �� ���-�� ���騭 (63 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
      elseif _vozrast == 66
        lshifr := "70.3.202"
//70.3.202 �� ���-�� ���騭 (66 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
      elseif _vozrast == 69
        lshifr := "70.3.143"
//70.3.143 �� ���-�� ���騭 (69 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
      elseif _vozrast == 72
        lshifr := "70.3.147"
//70.3.147 �� ���-�� ���騭 (72 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
      elseif eq_any(_vozrast,75,78,81,84)
        lshifr := "70.3.169"
//70.3.169 �� ���-�� ���騭 (75,78,81,84 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
      else//if eq_any(_vozrast,87,90,93,96,99)
        lshifr := "70.3.171"
//70.3.171 �� ���-�� ���騭 (87,90,93,96,99 ���) ��� ����⮫����᪨� ��᫥�������, 1 �⠯
      endif
    else // ����⮫����᪨� ���-�� �஢������ � ���
      if eq_any(_vozrast,21,24,27)
        lshifr := "70.3.122"
//70.3.122 �� ���-�� ���騭 (21,24,27 ���), 1 �⠯
      elseif eq_any(_vozrast,30,33,36)
        lshifr := iif(m1g_cit == 2, "70.3.172", "70.3.124")
//70.3.124 �� ���-�� ���騭 (30,33,36 ���), 1 �⠯
//70.3.172 �� ���-�� ���騭 (30,33,36 ���) ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif _vozrast == 39
        lshifr := iif(m1g_cit == 2, "70.3.174", "70.3.126")
//70.3.126 �� ���-�� ���騭 (39 ���), 1 �⠯
//70.3.174 �� ���-�� ���騭 (39 ���) ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif _vozrast == 42
        lshifr := iif(m1g_cit == 2, "70.3.178", "70.3.130")
//70.3.130 �� ���-�� ���騭 (42 ���), 1 �⠯
//70.3.178 �� ���-�� ���騭 (42 ���) ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif eq_any(_vozrast,45,48)
        lshifr := iif(m1g_cit == 2, "70.3.182", "70.3.134")
//70.3.134 �� ���-�� ���騭 (45,48 ���), 1 �⠯
//70.3.182 �� ���-�� ���騭 (45,48 ���) ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif eq_any(_vozrast,51,57)
        lshifr := iif(m1g_cit == 2, "70.3.186", "70.3.148")
//70.3.148 �� ���-�� ���騭 (51,57 ���), 1 �⠯
//70.3.186 �� ���-�� ���騭 (51,57 ���) ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif _vozrast == 54
        lshifr := iif(m1g_cit == 2, "70.3.190", "70.3.152")
//70.3.152 �� ���-�� ���騭 (54 ���), 1 �⠯
//70.3.190 �� ���-�� ���騭 (54 ���) ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif _vozrast == 60
        lshifr := iif(m1g_cit == 2, "70.3.194", "70.3.156")
//70.3.156 �� ���-�� ���騭 (60 ���), 1 �⠯
//70.3.194 �� ���-�� ���騭 (60 ���) ��� �⮫����᪮�� ��᫥�������, 1 �⠯
      elseif _vozrast == 63
        lshifr := "70.3.160"
//70.3.160 �� ���-�� ���騭 (63 ���), 1 �⠯
      elseif _vozrast == 66
        lshifr := "70.3.140"
//70.3.140 �� ���-�� ���騭 (66 ���), 1 �⠯
      elseif _vozrast == 69
        lshifr := "70.3.142"
//70.3.142 �� ���-�� ���騭 (69 ���), 1 �⠯
      elseif _vozrast == 72
        lshifr := "70.3.146"
//70.3.146 �� ���-�� ���騭 (72 ���), 1 �⠯
      elseif eq_any(_vozrast,75,78,81,84)
        lshifr := "70.3.168"
//70.3.168 �� ���-�� ���騭 (75,78,81,84 ���), 1 �⠯
      else//if eq_any(_vozrast,87,90,93,96,99)
        lshifr := "70.3.170"
//70.3.170 �� ���-�� ���騭 (87,90,93,96,99 ���), 1 �⠯
      endif
    endif
  endif
elseif _etap == 3
  if _pol == "�"
    if _vozrast < 45
      lshifr := iif(m1lis > 0, "72.1.14", "72.1.4")
    else
      lshifr := iif(m1lis > 0, "72.1.15", "72.1.5")
    endif
  else
    if _vozrast < 39
      lshifr := iif(m1lis > 0, "72.1.11", "72.1.1")
    elseif _vozrast < 45
      lshifr := iif(m1lis > 0, "72.1.12", "72.1.2")
    else
      lshifr := iif(m1lis > 0, "72.1.13", "72.1.3")
    endif
  endif
elseif _etap == 4
  if _pol == "�"
    lshifr := "70.3.101"
//70.3.101 �� ���-�� ��稭 (49,53,55,59,61,65,67,71,73), 1 �⠯ (���.1 ࠧ � 2 ����)
  else
    if eq_any(_vozrast,49,53,55,59,61,65,67,71,73)
      lshifr := "70.3.138"
//70.3.138 �� ���-�� ���騭 (49,53,55,59,61,65,67,71,73), 1 �⠯ (���.1 ࠧ � 2 ����)
    else
      lshifr := "70.3.139"
//70.3.139 �� ���-�� ���騭 (50,52,56,58,62,64,68,70), 1 �⠯ (���.1 ࠧ � 2 ����)
    endif
  endif
endif
return lshifr


***** 06.05.15 ������ "�ࠢ����" ��䨫� ��� ��ᯠ��ਧ�樨/��䨫��⨪�
Function ret_profil_dispans_COVID_2(lprofil,lprvs)
if lprofil == 34 // �᫨ ��䨫� �� "������᪮� ������୮� �������⨪�"
  if ret_old_prvs(lprvs) == 2013 // � ᯥ�-�� "������୮� ����"
    lprofil := 37 // ᬥ��� �� ��䨫� �� "������୮�� ����"
  elseif ret_old_prvs(lprvs) == 2011 // ��� "������ୠ� �������⨪�"
    lprofil := 38 // ᬥ��� �� ��䨫� �� "������୮� �������⨪�"
  endif
endif
return lprofil

***** 01.02.20
Function fget_spec_deti_COVID_2(k,r,c,a_spec)
Local tmp_select := select(), i, j, as := {}, s, blk, t_arr[BR_LEN], n_file := cur_dir+"tmpspecdeti"
if !hb_fileExists(n_file+sdbf)
  if select("MOSPEC") == 0
    R_Use(dir_exe+"_mo_spec",cur_dir+"_mo_spec","MOSPEC")
    //index on shifr+str(vzros_reb,1)+str(prvs_new,4) to (sbase)
  endif
  select MOSPEC
  find ("2.")
  do while left(mospec->shifr,2) == "2." .and. !eof()
    if mospec->vzros_reb == 1 // ���
      if ascan(as,mospec->prvs_new) == 0
        aadd(as,mospec->prvs_new)
      endif
    endif
    skip
  enddo
  if select("MOSPEC") > 0
    mospec->(dbCloseArea())
  endif
  for i := 1 to len(as)
    if (j := ascan(glob_arr_V015_V021,{|x| x[2] == as[i]})) > 0 // ��ॢ�� �� 21-�� �ࠢ�筨��
      as[i] := glob_arr_V015_V021[j,1]                          // � 15-� �ࠢ�筨�
    endif
  next
  dbcreate(n_file,{{"name","C",30,0},;
                   {"kod","C",4,0},;
                   {"kod_up","C",4,0},;
                   {"name1","C",50,0},;
                   {"is","L",1,0}})
  use (n_file) new alias SDVN
  use (cur_dir+"tmp_v015") index (cur_dir+"tmpkV015") new alias tmp_ga
  go top
  do while !eof()
    if (i := ascan(as,int(val(tmp_ga->kod)))) > 0
      select SDVN
      append blank
      sdvn->name := afteratnum(".",tmp_ga->name,1)
      sdvn->kod := tmp_ga->kod
      s := ""
      select TMP_GA
      rec := recno()
      do while !empty(tmp_ga->kod_up)
        find (tmp_ga->kod_up)
        if found()
          s += alltrim(afteratnum(".",tmp_ga->name,1))+"/"
        else
          exit
        endif
      enddo
      goto (rec)
      sdvn->name1 := s
    endif
    skip
  enddo
  sdvn->(dbCloseArea())
  tmp_ga->(dbCloseArea())
endif
use (n_file) new alias tmp_ga
do while !eof()
  tmp_ga->is := (ascan(a_spec,int(val(tmp_ga->kod))) > 0)
  skip
enddo
index on upper(name)+kod to (n_file)
if r <= maxrow()/2
  t_arr[BR_TOP] := r+1
  t_arr[BR_BOTTOM] := maxrow()-2
else
  t_arr[BR_BOTTOM] := r-1
  t_arr[BR_TOP] := 2
endif
blk := {|| iif(tmp_ga->is, {1,2}, {3,4}) }
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {"�","�","�","N/BG,W+/N,B/BG,W+/B",.f.}
t_arr[BR_COLUMN] := {;
  { " ", {|| iif(tmp_ga->is,""," ") }, blk },;
  { "���", {|| left(tmp_ga->kod,3) },blk },;
  { center("����樭᪠� ᯥ樠�쭮���",26), {|| padr(tmp_ga->name,26) },blk },;
  { center("���稭����",45), {|| left(tmp_ga->name1,45) },blk };
}
t_arr[BR_EDIT] := {|nk,ob| f1get_spec_DVN(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - ��室;  ^<Ins>^ - �⬥��� ᯥ樠�쭮���/���� �⬥�� � ᯥ樠�쭮��") }
go top
edit_browse(t_arr)
s := ""
asize(a_spec,0)
go top
do while !eof()
  if tmp_ga->is
    s += alltrim(tmp_ga->kod)+","
    aadd(a_spec,int(val(tmp_ga->kod)))
  endif
  skip
enddo
if empty(s)
  s := "---"
else
  s := left(s,len(s)-1)
endif
tmp_ga->(dbCloseArea())
select (tmp_select)
return {1,s}

***** 01.02.17
Function fget_spec_DVN_COVID_2(k,r,c,a_spec)
Static as := {;
  {8,2},;
  {255,1},;
  {112,1},;
  {58,1},;
  {65,1},;
  {113,1},;
  {133,1},;
  {257,1},;
  {114,1},;
  {258,1},;
  {115,1},;
  {66,1},;
  {116,1},;
  {10,1},;
  {32,1},;
  {260,1},;
  {118,1},;
  {139,2},;
  {59,1},;
  {67,1},;
  {120,1},;
  {134,1},;
  {14,2},;
  {140,1},;
  {261,1},;
  {123,1},;
  {17,1},;
  {19,2},;
  {20,2},;
  {23,1},;
  {262,1},;
  {125,1},;
  {138,1},;
  {263,1},;
  {126,1},;
  {141,1},;
  {75,1},;
  {28,1},;
  {145,2},;
  {29,1},;
  {30,2},;
  {31,1},;
  {97,1};
}
Local tmp_select := select(), s, blk, t_arr[BR_LEN], n_file := cur_dir+"tmpspecdvn"
if !hb_fileExists(n_file+sdbf)
  dbcreate(n_file,{{"name","C",30,0},;
                   {"kod","C",4,0},;
                   {"kod_up","C",4,0},;
                   {"name1","C",50,0},;
                   {"isn","N",1,0},;
                   {"is","L",1,0}})
  use (n_file) new alias SDVN
  use (cur_dir+"tmp_v015") index (cur_dir+"tmpkV015") new alias tmp_ga
  go top
  do while !eof()
    if (i := ascan(as,{|x| lstr(x[1]) == rtrim(tmp_ga->kod)})) > 0
      select SDVN
      append blank
      sdvn->name := afteratnum(".",tmp_ga->name,1)
      sdvn->kod := tmp_ga->kod
      sdvn->isn := as[i,2]
      s := ""
      select TMP_GA
      rec := recno()
      do while !empty(tmp_ga->kod_up)
        find (tmp_ga->kod_up)
        if found()
          s += alltrim(afteratnum(".",tmp_ga->name,1))+"/"
        else
          exit
        endif
      enddo
      goto (rec)
      sdvn->name1 := s
    endif
    skip
  enddo
  sdvn->(dbCloseArea())
  tmp_ga->(dbCloseArea())
endif
use (n_file) new alias tmp_ga
do while !eof()
  tmp_ga->is := (ascan(a_spec,int(val(tmp_ga->kod))) > 0)
  skip
enddo
if metap == 3
  index on upper(name)+kod to (n_file)
else
  index on upper(name)+kod to (n_file) for isn == 1
endif
if r <= maxrow()/2
  t_arr[BR_TOP] := r+1
  t_arr[BR_BOTTOM] := maxrow()-2
else
  t_arr[BR_BOTTOM] := r-1
  t_arr[BR_TOP] := 2
endif
blk := {|| iif(tmp_ga->is, {1,2}, {3,4}) }
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {"�","�","�","N/BG,W+/N,B/BG,W+/B",.f.}
t_arr[BR_COLUMN] := {;
  { " ", {|| iif(tmp_ga->is,""," ") }, blk },;
  { "���", {|| left(tmp_ga->kod,3) },blk },;
  { center("����樭᪠� ᯥ樠�쭮���",26), {|| padr(tmp_ga->name,26) },blk },;
  { center("���稭����",45), {|| left(tmp_ga->name1,45) },blk };
}
t_arr[BR_EDIT] := {|nk,ob| f1get_spec_DVN(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - ��室;  ^<Ins>^ - �⬥��� ᯥ樠�쭮���/���� �⬥�� � ᯥ樠�쭮��") }
go top
edit_browse(t_arr)
s := ""
asize(a_spec,0)
go top
do while !eof()
  if iif(metap == 3, .t., tmp_ga->isn==1) .and. tmp_ga->is
    s += alltrim(tmp_ga->kod)+","
    aadd(a_spec,int(val(tmp_ga->kod)))
  endif
  skip
enddo
if empty(s)
  s := "---"
else
  s := left(s,len(s)-1)
endif
tmp_ga->(dbCloseArea())
select (tmp_select)
return {1,s}

***** 11.11.17
Function f1get_spec_DVN_COVID_2(nKey,oBrow,regim)
if regim == "edit" .and. nkey == K_INS
  tmp_ga->is := !tmp_ga->is
  keyboard chr(K_TAB)
endif
return 0
