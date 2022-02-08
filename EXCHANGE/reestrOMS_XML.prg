***** ॥����/��� � 2019 ����
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static sadiag1 := {}

  
***** 04.02.22 ᮧ����� XML-䠩��� ॥���
Function create2reestr19(_recno,_nyear,_nmonth,reg_sort)
  Local mnn, mnschet := 1, fl, mkod_reestr, name_zip, arr_zip := {}, lst, lshifr1, code_reestr, mb, me, nsh
  //
  local iAKSLP, tKSLP, cKSLP // ���稪 ��� 横�� �� ����
  local reserveKSG_ID_C := '' // GUID ��� ��������� ������� ��砥�
  local aImpl, arrLP, row
  local ser_num
  local controlVer
  local endDateZK
  local diagnoz_replace := ''

  //
  close databases
  if empty(sadiag1)
    Private file_form, diag1 := {}, len_diag := 0
    if (file_form := search_file("DISP_NAB"+sfrm)) == NIL
      return func_error(4,"�� �����㦥� 䠩� DISP_NAB"+sfrm)
    endif
    f2_vvod_disp_nabl("A00")
    sadiag1 := diag1
  endif
  for i := 1 to 5
    sk := lstr(i)
    pole_diag := "mdiag"+sk
    pole_1dispans := "m1dispans"+sk
    pole_dn_dispans := "mdndispans"+sk
    Private &pole_diag := space(6)
    Private &pole_1dispans := 0
    Private &pole_dn_dispans := ctod("")
  next
  stat_msg("���⠢����� ॥��� ��砥�")
  nsh := f_mb_me_nsh(_nyear,@mb,@me)
  R_Use(dir_exe+"_mo_mkb",,"MKB_10")
  index on shifr+str(ks,1) to (cur_dir+"_mo_mkb")
  G_Use(dir_server+"mo_rees",,"REES")
  index on str(nn,nsh) to (cur_dir+"tmp_rees") for nyear == _nyear .and. nmonth == _nmonth
  fl := .f.
  for mnn := mb to me
    find (str(mnn,nsh))
    if !found() // ��諨 ᢮����� �����
      fl := .t. ; exit
    endif
  next
  if !fl
    close databases
    return func_error(10,"�� 㤠���� ���� ᢮����� ����� ����� � �����. �஢���� ����ன��!")
  endif
  index on str(nschet,6) to (cur_dir+"tmp_rees") for nyear == _nyear
  if !eof()
    go bottom
    mnschet := rees->nschet+1
  endif
  if !between(mnschet,mem_beg_rees,mem_end_rees)
    fl := .f.
    for mnschet := mem_beg_rees to mem_end_rees
      find (str(mnschet,6))
      if !found() // ��諨 ᢮����� �����
        fl := .t. ; exit
      endif
    next
    if !fl
      close databases
      return func_error(10,"�� 㤠���� ���� ᢮����� ����� ॥���. �஢���� ����ன��!")
    endif
  endif
  set index to
  AddRecN()
  rees->KOD    := recno()
  rees->NSCHET := mnschet
  rees->DSCHET := sys_date
  rees->NYEAR  := _NYEAR
  rees->NMONTH := _NMONTH
  rees->NN     := mnn
  s := "RM"+CODE_LPU+"T34"+"_"+right(strzero(_NYEAR,4),2)+strzero(_NMONTH,2)+strzero(mnn,nsh)
  rees->NAME_XML := {"H","F"}[p_tip_reestr]+s
  mkod_reestr := rees->KOD
  rees->CODE  := ret_unique_code(mkod_reestr)
  code_reestr := rees->CODE
  //
  G_Use(dir_server+"mo_xml",,"MO_XML")
  AddRecN()
  mo_xml->KOD    := recno()
  mo_xml->FNAME  := rees->NAME_XML
  mo_xml->FNAME2 := "L"+s
  mo_xml->DFILE  := rees->DSCHET
  mo_xml->TFILE  := hour_min(seconds())
  mo_xml->TIP_OUT := _XML_FILE_REESTR // ⨯ ���뫠����� 䠩��;1-॥���
  mo_xml->REESTR := mkod_reestr
  //
  rees->KOD_XML := mo_xml->KOD
  UnLock
  Commit
  //
  use_base("lusl")
  use_base("luslc")
  use_base("luslf")
  Use_base("human_im")
  R_Use(dir_server + 'human_lek_pr', dir_server + 'human_lek_pr', 'LEK_PR')

  // laluslf := "luslf"+iif(_nyear==2019,"19","")
  laluslf := create_name_alias('luslf', _nyear)
  R_Use(dir_server+"mo_uch",,"UCH")
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"mo_pers",,"P2")
  R_Use(dir_server+"mo_pers",dir_server+"mo_pers","P2TABN")
  R_Use(dir_server+"uslugi",,"USL")
  G_Use(dir_server+"mo_rhum",,"RHUM")
  index on str(REESTR,6) to (cur_dir+"tmp_rhum")
  G_Use(dir_server+"human_u_",,"HU_")
  R_Use(dir_server+"human_u",dir_server+"human_u","HU")
  set relation to recno() into HU_, to u_kod into USL
  R_Use(dir_server+"mo_su",,"MOSU")
  G_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
  set relation to u_kod into MOSU
  if p_tip_reestr == 1
    R_Use(dir_server+"kart_inv",,"INV")
    index on str(kod,7) to (cur_dir+"tmp_inv")
  endif
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART_, to recno() into KART2
  R_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","ONKNA") // �������ࠢ�����
  R_Use(dir_server+"mo_onkco",dir_server+"mo_onkco","ONKCO")
  R_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","ONKSL") // �������� � ��砥 ��祭�� ���������᪮�� �����������
  R_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","ONKDI") // ���������᪨� ����
  R_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","ONKPR") // �������� �� �������� ��⨢�����������
  G_Use(dir_server+"mo_onkus",dir_server+"mo_onkus","ONKUS")
  G_Use(dir_server+"mo_onkle",dir_server+"mo_onkle","ONKLE")
  G_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
  set order to 2 // ������ �� 2-�� ����
  G_Use(dir_server+"human_2",,"HUMAN_2")
  G_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
  R_Use(exe_dir+"_mo_t2_v1",,"T21")
  index on shifr to (cur_dir+"tmp_t21")
  use (cur_dir+"tmpb") new
  if reg_sort == 1
    index on upper(fio) to (cur_dir+"tmpb") for kod_tmp==_recno .and. plus
  else
    index on str(pz,2)+str(10000000-cena_1,11,2) to (cur_dir+"tmpb") for kod_tmp==_recno .and. plus
  endif
  pkol := psumma := iusl := 0
  go top
  do while !eof()
    arrLP := {}
    @ maxrow(),1 say lstr(pkol) color cColorSt2Msg
    select HUMAN
    goto (tmpb->kod_human)
    pkol++ ; psumma += human->cena_1
    select RHUM
    AddRec(6)
    rhum->REESTR := mkod_reestr
    rhum->KOD_HUM := human->kod
    rhum->REES_ZAP := pkol
    human_->(G_RLock(forever))
    if human_->REES_NUM < 99
      human_->REES_NUM := human_->REES_NUM+1
    endif
    human_->REESTR := mkod_reestr
    human_->REES_ZAP := pkol
    if tmpb->ishod == 89  // 2-� ��砩
      select HUMAN_3
      find (str(tmpb->kod_human,7))
      if found()
        G_RLock(forever)
        if human_3->REES_NUM < 99
          human_3->REES_NUM := human_3->REES_NUM+1
        endif
        human_3->REESTR := mkod_reestr
        human_3->REES_ZAP := pkol
        //
        select HUMAN
        goto (human_3->kod)  // ����� �� 1-� ��砩
        human_->(G_RLock(forever))
        psumma += human->cena_1
        if human_->REES_NUM < 99
          human_->REES_NUM := human_->REES_NUM+1
        endif
        human_->REESTR := mkod_reestr
        human_->REES_ZAP := pkol
      endif
    endif
    if pkol % 2000 == 0
      dbUnlockAll()
      dbCommitAll()
    endif
    select TMPB
    skip
  enddo
  select REES
  G_RLock(forever)
  rees->KOL := pkol
  rees->SUMMA := psumma
  dbUnlockAll()
  dbCommitAll()
  //
  //
  Private arr_usl_otkaz, adiag_talon[16]
  //
  // ᮧ����� ���� XML-���㬥��
  oXmlDoc := HXMLDoc():New()

  // �������� ��୥��� ����� XML-���㬥��
  oXmlDoc:Add( HXMLNode():New( "ZL_LIST") )
  oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )

  // �������� ��������� XML-���㬥��
  s := '3.11'
  controlVer := _nyear * 100 + _nmonth
  if (controlVer >= 202201) .and. (p_tip_reestr == 1) // � ﭢ��� 2022 ����
    // fl_ver := 32
    s := '3.2'
  endif
  mo_add_xml_stroke(oXmlNode,"VERSION" ,s)
  mo_add_xml_stroke(oXmlNode,"DATA"    ,date2xml(rees->DSCHET))
  mo_add_xml_stroke(oXmlNode,"FILENAME",mo_xml->FNAME)
  mo_add_xml_stroke(oXmlNode,"SD_Z"    ,lstr(pkol))

  // �������� ॥��� ��砥� ��� XML-���㬥��
  oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "SCHET" ) )
  mo_add_xml_stroke(oXmlNode,"CODE"   ,lstr(code_reestr))
  mo_add_xml_stroke(oXmlNode,"CODE_MO",CODE_MO)
  mo_add_xml_stroke(oXmlNode,"YEAR"   ,lstr(_NYEAR))
  mo_add_xml_stroke(oXmlNode,"MONTH"  ,lstr(_NMONTH))
  mo_add_xml_stroke(oXmlNode,"NSCHET" ,lstr(rees->NSCHET))
  mo_add_xml_stroke(oXmlNode,"DSCHET" ,date2xml(rees->DSCHET))
  mo_add_xml_stroke(oXmlNode,"SUMMAV" ,str(psumma,15,2))
  //mo_add_xml_stroke(oXmlNode,"COMENTS","")
  //
  //
  select RHUM
  index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR==mkod_reestr
  go top
  do while !eof()
    @ maxrow(),0 say str(rhum->REES_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
    //
    fl_DISABILITY := is_zak_sl := is_zak_sl_vr := .f.
    lshifr_zak_sl := lvidpoms := cSMOname := ""
    a_usl := {} ; a_fusl := {} ; lvidpom := 1 ; lfor_pom := 3
    atmpusl := {} ; akslp := {} ; akiro := {} ; mdiagnoz := {} ; mdiagnoz3 := {}
    is_KSG := is_mgi := .f.
    kol_kd := v_reabil_slux := m1veteran := m1mobilbr := 0  // �����쭠� �ਣ���
    tarif_zak_sl := m1mesto_prov := m1p_otk := 0    // �ਧ��� �⪠��
    m1dopo_na := m1napr_v_mo := 0 // {{"-- ��� --",0},{"� ���� ��",1},{"� ���� ��",2}}, ;
    arr_mo_spec := {}
    m1napr_stac := 0 // {{"--- ��� ---",0},{"� ��樮���",1},{"� ��. ���.",2}}, ;
    m1profil_stac := m1napr_reab := m1profil_kojki := 0
    pr_amb_reab := fl_disp_nabl := is_disp_DVN := is_disp_DVN_COVID := .f.
    ldate_next := ctod("")
    ar_dn := {}
    is_oncology_smp := is_oncology := 0
    arr_onkna := {}
    arr_onkdi := {}
    arr_onkpr := {}
    arr_onk_usl := {}
    a_otkaz := {}
    arr_nazn := {}

    mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

    //
    select HUMAN
    goto (rhum->kod_hum)  // ��⠫� �� 2-�� ���� ����
    kol_sl := iif(human->ishod == 89, 2, 1)
    for isl := 1 to kol_sl
      if isl == 1 .and. kol_sl == 2
        select HUMAN_3
        find (str(rhum->kod_hum,7))
        reserveKSG_ID_C := human_3->ID_C
        select HUMAN
        goto (human_3->kod)  // ��⠫� �� 1-� ���� ����
      endif
      if isl == 2
        select HUMAN
        goto (human_3->kod2)  // ��⠫� �� 2-�� ���� ����
      endif
      f1_create2reestr19(_nyear,_nmonth)

      // �������� ॥��� �����ﬨ ��� XML-���㬥��
      if isl == 1
        oZAP := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZAP" ) )
        mo_add_xml_stroke(oZAP,"N_ZAP" ,lstr(rhum->REES_ZAP))
        mo_add_xml_stroke(oZAP,"PR_NOV",iif(human_->SCHET_NUM > 0, '1', '0')) // �᫨ ����� � ���� 2-� ࠧ � �.�.
        
        // �������� ᢥ����� � ��樥�� ��� XML-���㬥�� 
        oPAC := oZAP:Add( HXMLNode():New( "PACIENT" ) )
        mo_add_xml_stroke(oPAC,"ID_PAC",human_->ID_PAC)
        mo_add_xml_stroke(oPAC,"VPOLIS",lstr(human_->VPOLIS))
        if !empty(human_->SPOLIS)
          mo_add_xml_stroke(oPAC,"SPOLIS",human_->SPOLIS)
        endif
        mo_add_xml_stroke(oPAC,"NPOLIS",human_->NPOLIS)
        if len(alltrim(kart2->kod_mis)) == 16
          mo_add_xml_stroke(oPAC,"ENP",kart2->kod_mis) // ����� ����� ����� ������� ��ࠧ�
        endif
        //mo_add_xml_stroke(oPAC,"ST_OKATO" ,...) // ������ ���客����
        if empty(cSMOname)
          mo_add_xml_stroke(oPAC,"SMO" ,human_->smo)
        endif
        mo_add_xml_stroke(oPAC,"SMO_OK",iif(empty(human_->OKATO),"18000",human_->OKATO))
        if !empty(cSMOname)
          mo_add_xml_stroke(oPAC,"SMO_NAM",cSMOname)
        endif
        if human_->NOVOR == 0
          mo_add_xml_stroke(oPAC,"NOVOR",'0')
        else
          mnovor := iif(human_->pol2=="�",'1','2')+;
                  strzero(day(human_->DATE_R2),2)+;
                  strzero(month(human_->DATE_R2),2)+;
                  right(lstr(year(human_->DATE_R2)),2)+;
                  strzero(human_->NOVOR,2)
          mo_add_xml_stroke(oPAC,"NOVOR",mnovor)
        endif
        //mo_add_xml_stroke(oPAC,"MO_PR",???)
        if human_->USL_OK == 1 .and. human_2->VNR > 0
          // ��樮��� + �/� �� ������襭���� ॡ񭪠
          mo_add_xml_stroke(oPAC,"VNOV_D",lstr(human_2->VNR))
        endif
        if fl_DISABILITY // �������� � ��ࢨ筮� �ਧ����� �����客������ ��� ���������
          // �������� ᢥ����� �� ����������� ��樥�� ��� XML-���㬥�� 
          oDISAB := oPAC:Add( HXMLNode():New( "DISABILITY" ) )
          // ��㯯� ����������� �� ��ࢨ筮� �ਧ����� �����客������ ��� ���������
          mo_add_xml_stroke(oDISAB,"INV",lstr(kart_->invalid))
          // ��� ��ࢨ筮�� ��⠭������� �����������
          mo_add_xml_stroke(oDISAB,"DATA_INV",date2xml(inv->DATE_INV))
          // ��� ��稭� ��⠭�������  �����������
          mo_add_xml_stroke(oDISAB,"REASON_INV",lstr(inv->PRICH_INV))
          if !empty(inv->DIAG_INV) // ��� �᭮����� ����������� �� ���-10
            mo_add_xml_stroke(oDISAB,"DS_INV",inv->DIAG_INV)
          endif
        endif
        // �������� ᢥ����� � �����祭��� ��砥 �������� ����樭᪮� ����� ��� XML-���㬥��
        oSLUCH := oZAP:Add( HXMLNode():New( "Z_SL" ) )
        mo_add_xml_stroke(oSLUCH,"IDCASE"  ,lstr(rhum->REES_ZAP))

        if ! empty(reserveKSG_ID_C) // �஢�ਬ GUID ��� ���������� �������� ����
          mo_add_xml_stroke(oSLUCH,"ID_C"    ,reserveKSG_ID_C)
          reserveKSG_ID_C := ''
        else
          mo_add_xml_stroke(oSLUCH,"ID_C"    ,human_->ID_C)
        endif
        
        if p_tip_reestr == 2  // ��� ॥��஢ �� ��ᯠ��ਧ�樨
          s := space(3) 
          ret_tip_lu(@s)
          if !empty(s)
            mo_add_xml_stroke(oSLUCH,"DISP",s) // ��� ��ᯠ��ਧ�樨
          endif
        endif
        mo_add_xml_stroke(oSLUCH,"USL_OK"  ,lstr(human_->USL_OK))
        mo_add_xml_stroke(oSLUCH,"VIDPOM"  ,lstr(lvidpom))
        if p_tip_reestr == 1
          lal := iif(kol_sl == 2, "human_3", "human_")
          mo_add_xml_stroke(oSLUCH,"ISHOD"   ,lstr(&lal.->ISHOD_NEW))
          if kol_sl == 2
            mo_add_xml_stroke(oSLUCH,"VB_P"  ,'1') // �ਧ��� ����ਡ��쭨筮�� ��ॢ��� �� ����� �����祭���� ���� ��� �㬬� �⮨���⥩ �ॡ뢠��� ��樥�� � ࠧ��� ��䨫��� �⤥������, ������ �� ������ ����稢����� �� ���
          endif
          mo_add_xml_stroke(oSLUCH,"IDSP"    ,lstr(human_->IDSP))
          lal := iif(kol_sl == 2, "human_3", "human")
          mo_add_xml_stroke(oSLUCH,"SUMV"    ,lstr(&lal.->cena_1,10,2))
          do case
            case human_->USL_OK == 1 // ��樮���
              i := iif(left(human_->FORMA14,1)=='1', 1, 3)
            case human_->USL_OK == 2 // ������� ��樮���
              i := iif(left(human_->FORMA14,1)=='2', 2, 3)
            case human_->USL_OK == 4 // ᪮�� ������
              i := iif(left(human_->FORMA14,1)=='1', 1, 2)
            otherwise
              i := lfor_pom
          endcase
          mo_add_xml_stroke(oSLUCH,"FOR_POM",lstr(i)) // 1 - ���७���, 2 - ���⫮����, 3 - ��������
          if !empty(human_->NPR_MO) .and. !empty(mNPR_MO := ret_mo(human_->NPR_MO)[_MO_KOD_FFOMS])
            mo_add_xml_stroke(oSLUCH,"NPR_MO",mNPR_MO)
            s := iif(empty(human_2->NPR_DATE),human->N_DATA, human_2->NPR_DATE)
            mo_add_xml_stroke(oSLUCH,"NPR_DATE",date2xml(s))
          endif
          mo_add_xml_stroke(oSLUCH,"LPU",CODE_LPU)
        else  // ��� ॥��஢ �� ��ᯠ��ਧ�樨
          mo_add_xml_stroke(oSLUCH,"FOR_POM",'3') // 3 - ��������
          mo_add_xml_stroke(oSLUCH,"LPU",CODE_LPU)
          mo_add_xml_stroke(oSLUCH,"VBR",iif(m1mobilbr==0,'0','1'))
          if eq_any(human->ishod,301,302,203)
            s := "2.1" // ����樭᪨� �ᬮ��
          else
            s := "2.2" // ��ᯠ��ਧ���
          endif
          mo_add_xml_stroke(oSLUCH,"P_CEL",s)
          mo_add_xml_stroke(oSLUCH,"P_OTK",iif(m1p_otk==0,'0','1')) // �ਧ��� �⪠��
        endif
        lal := iif(kol_sl == 2, "human_3", "human")
        mo_add_xml_stroke(oSLUCH,"DATE_Z_1",date2xml(&lal.->N_DATA))
        mo_add_xml_stroke(oSLUCH,"DATE_Z_2",date2xml(&lal.->K_DATA))

        endDateZK := &lal.->K_DATA

        if p_tip_reestr == 1
          if kol_sl == 2
            mo_add_xml_stroke(oSLUCH,"KD_Z",lstr(human_3->k_data-human_3->n_data)) // ����뢠���� ������⢮ �����-���� ��� ��樮���, ������⢮ ��樥��-���� ��� �������� ��樮���
          elseif kol_kd > 0
            mo_add_xml_stroke(oSLUCH,"KD_Z",lstr(kol_kd)) // ����뢠���� ������⢮ �����-���� ��� ��樮���, ������⢮ ��樥��-���� ��� �������� ��樮���
          endif
        endif
        if human_->USL_OK == 1 // ��樮���
          // ��� ������襭��� ��⥩ ��� �/� ����
          lal := iif(kol_sl == 2, "human_3", "human_2")
          if &lal.->VNR1 > 0
            mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(&lal.->VNR1))
          endif
          if &lal.->VNR2 > 0
            mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(&lal.->VNR2))
          endif
          if &lal.->VNR3 > 0
            mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(&lal.->VNR3))
          endif
        endif
        lal := iif(kol_sl == 2, "human_3", "human_")
        mo_add_xml_stroke(oSLUCH,"RSLT",lstr(&lal.->RSLT_NEW))
        if p_tip_reestr == 1
          //mo_add_xml_stroke(oSLUCH,"MSE",'1')
        else    // ��� ॥��஢ �� ��ᯠ��ਧ�樨
          mo_add_xml_stroke(oSLUCH,"ISHOD",lstr(human_->ISHOD_NEW))
          mo_add_xml_stroke(oSLUCH,"IDSP" ,lstr(human_->IDSP))
          mo_add_xml_stroke(oSLUCH,"SUMV" ,lstr(human->cena_1,10,2))
        endif
      endif // ����砭�� ⥣�� ZAP + PACIENT + Z_SL

      // �������� ᢥ����� � ��砥 �������� ����樭᪮� ����� ��� XML-���㬥��
      oSL := oSLUCH:Add( HXMLNode():New( "SL" ) )
      mo_add_xml_stroke(oSL,"SL_ID",human_->ID_C)
      if (is_vmp := human_->USL_OK == 1 .and. human_2->VMP == 1 ;// ���
                            .and. !emptyany(human_2->VIDVMP,human_2->METVMP))
        mo_add_xml_stroke(oSL,"VID_HMP",human_2->VIDVMP)
        mo_add_xml_stroke(oSL,"METOD_HMP",lstr(human_2->METVMP))
      endif
      otd->(dbGoto(human->OTD))
      if human_->USL_OK == 1 .and. is_otd_dep
        f_put_glob_podr(human_->USL_OK,human->K_DATA) // ��������� ��� ���ࠧ�������
        if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
          i := 1
        endif
        mo_add_xml_stroke(oSL,"LPU_1",lstr(mm_otd_dep[i,3]))
        mo_add_xml_stroke(oSL,"PODR" ,lstr(glob_otd_dep))
      endif
      mo_add_xml_stroke(oSL,"PROFIL",lstr(human_->PROFIL))
      if p_tip_reestr == 1
        if human_->USL_OK < 3
          mo_add_xml_stroke(oSL,"PROFIL_K",lstr(human_2->PROFIL_K))
        endif
        mo_add_xml_stroke(oSL,"DET",iif(human->VZROS_REB==0,'0','1'))
        if human_->USL_OK == 3
          // s := "2.6"
          // if (i := ascan(glob_V025, {|x| x[2] == human_->povod})) > 0
          //   s := glob_V025[i,3]
          // endif
          if (s := get_IDPC_from_V025_by_number(human_->povod)) == ''
            s := '2.6'
          endif
          mo_add_xml_stroke(oSL,"P_CEL",s)
        endif
      endif
      if is_vmp
        mo_add_xml_stroke(oSL,"TAL_D" ,date2xml(human_2->TAL_D)) // ��� �뤠� ⠫��� �� ���
        mo_add_xml_stroke(oSL,"TAL_P" ,date2xml(human_2->TAL_P)) // ��� ������㥬�� ��ᯨ⠫���樨 � ᮮ⢥��⢨� � ⠫���� �� ���
        mo_add_xml_stroke(oSL,"TAL_NUM",human_2->TAL_NUM) // ����� ⠫��� �� ���
      endif
      mo_add_xml_stroke(oSL,"NHISTORY",iif(empty(human->UCH_DOC),lstr(human->kod),human->UCH_DOC))
      
      if !is_vmp .and. eq_any(human_->USL_OK,1,2)
        mo_add_xml_stroke(oSL,"P_PER",lstr(human_2->P_PER)) // �ਧ��� ����㯫����/��ॢ���
      endif
      mo_add_xml_stroke(oSL,"DATE_1",date2xml(human->N_DATA))
      mo_add_xml_stroke(oSL,"DATE_2",date2xml(human->K_DATA))
      if p_tip_reestr == 1
        if kol_kd > 0
          mo_add_xml_stroke(oSL,"KD",lstr(kol_kd)) // ����뢠���� ������⢮ �����-���� ��� ��樮���, ������⢮ ��樥��-���� ��� �������� ��樮���
        endif

        if ! empty(human_2->PC4)
          mo_add_xml_stroke(oSL,"WEI", alltrim(human_2->PC4))
        endif

        if !empty(human_->kod_diag0)
          mo_add_xml_stroke(oSL,"DS0",human_->kod_diag0)
        endif
      endif
      // �������� ������� �᫨ ����室��� ��� �����-��������� �९��⮢
      if endDateZK >= 0d20220101 .and. alltrim(mdiagnoz[1]) == 'Z92.2'
        mdiagnoz[1] := mdiagnoz[2]
        diagnoz_replace := mdiagnoz[2]
        mdiagnoz[2] := ''
      endif
      mo_add_xml_stroke(oSL,"DS1",rtrim(mdiagnoz[1]))
      if p_tip_reestr == 2  // ��� ॥��஢ �� ��ᯠ��ਧ�樨
        s := 3 // �� �������� ��ᯠ��୮�� �������
        if adiag_talon[1] == 1 // �����
          mo_add_xml_stroke(oSL,"DS1_PR",'1') // �ਧ��� ��ࢨ筮�� ��⠭�������  ��������
          if adiag_talon[2] == 2
            s := 2 // ���� �� ��ᯠ��୮� �������
          endif
        elseif adiag_talon[1] == 2 // ࠭��
          if adiag_talon[2] == 1
            s := 1 // ��⮨� �� ��ᯠ��୮� �������
          elseif adiag_talon[2] == 2
            s := 2 // ���� �� ��ᯠ��୮� �������
          endif
        endif
        mo_add_xml_stroke(oSL,"PR_D_N",lstr(s))
        if (is_disp_DVN .or. is_disp_DVN_COVID) .and. s == 2 // ���� �� ��ᯠ��୮� �������
          aadd(ar_dn, {'2',rtrim(mdiagnoz[1]),"",""})
        endif
      endif
      if p_tip_reestr == 1
        for i := 2 to len(mdiagnoz)
          if !empty(mdiagnoz[i])
            mo_add_xml_stroke(oSL,"DS2" ,rtrim(mdiagnoz[i]))
          endif
        next
        for i := 1 to len(mdiagnoz3) // ��� �������� ���������� �����������
          if !empty(mdiagnoz3[i])
            mo_add_xml_stroke(oSL,"DS3",rtrim(mdiagnoz3[i]))
          endif
        next
        if need_reestr_c_zab(human_->USL_OK,mdiagnoz[1]) .or. is_oncology_smp > 0
          if human_->USL_OK == 3 .and. human_->povod == 4 // �᫨ P_CEL=1.3
            mo_add_xml_stroke(oSL,"C_ZAB",'2') // �� ��ᯠ��୮� ������� �ࠪ�� ����������� �� ����� ���� <���஥>
          else
            mo_add_xml_stroke(oSL,"C_ZAB",'1') // ��ࠪ�� �᭮����� �����������
          endif
        endif
        if human_->USL_OK < 4
          i := 0
          if human->OBRASHEN == '1' .and. is_oncology < 2
            i := 1
          endif
          mo_add_xml_stroke(oSL,"DS_ONK",lstr(i))
        else
          mo_add_xml_stroke(oSL,"DS_ONK",'0')
        endif
        if human_->USL_OK == 3 .and. human_->povod == 4 // ��易⥫쭮, �᫨ P_CEL=1.3
          s := 2 // ����
          if adiag_talon[1] == 2 // ࠭��
            if adiag_talon[2] == 1
              s := 1 // ��⮨�
            elseif adiag_talon[2] == 2
              s := 2 // ����
            elseif adiag_talon[2] == 3 // ���
              s := 4 // ��� �� ��稭� �매�஢�����
            elseif adiag_talon[2] == 4
              s := 6 // ��� �� ��㣨� ��稭��
            endif
          endif
          mo_add_xml_stroke(oSL,"DN",lstr(s))
        endif
      else   // ��� ॥��஢ �� ��ᯠ��ਧ�樨
        for i := 2 to len(mdiagnoz)
          if !empty(mdiagnoz[i])
            oDiag := oSL:Add( HXMLNode():New( "DS2_N" ) )
            mo_add_xml_stroke(oDiag,"DS2",rtrim(mdiagnoz[i]))
            s := 3 // �� �������� ��ᯠ��୮�� �������
            if adiag_talon[i*2-1] == 1 // �����
              mo_add_xml_stroke(oDiag,"DS2_PR",'1')
              if adiag_talon[i*2] == 2
                s := 2 // ���� �� ��ᯠ��୮� �������
              endif
            elseif adiag_talon[i*2-1] == 2 // ࠭��
              if adiag_talon[i*2] == 1
                s := 1 // ��⮨� �� ��ᯠ��୮� �������
              elseif adiag_talon[i*2] == 2
                s := 2 // ���� �� ��ᯠ��୮� �������
              endif
            endif
            mo_add_xml_stroke(oDiag,"PR_D",lstr(s))
            if (is_disp_DVN .or. is_disp_DVN_COVID) .and. s == 2 // ���� �� ��ᯠ��୮� �������
              aadd(ar_dn, {'2',rtrim(mdiagnoz[i]),"",""})
            endif
          endif
        next
        i := iif(human->OBRASHEN == '1', 1, 0)
        mo_add_xml_stroke(oSL,"DS_ONK",lstr(i))
        if len(arr_nazn) > 0 .or. (human->OBRASHEN == '1' .and. len(arr_onkna) > 0)
          // �������� ᢥ����� � �����祭��� �� १���⠬ ��ᯠ��ਧ�樨 ��� XML-���㬥��
          oPRESCRIPTION := oSL:Add( HXMLNode():New( "PRESCRIPTION" ) )
          for j := 1 to len(arr_nazn)
            oPRESCRIPTIONS := oPRESCRIPTION:Add( HXMLNode():New( "PRESCRIPTIONS" ) )
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_N",lstr(j))
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_R",lstr(arr_nazn[j,1]))

            if !empty(arr_nazn[j,3])   // �� ������ ���� � 01.08.21
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_IDDOKT", arr_nazn[j,3])
            endif

            if !empty(arr_nazn[j,4])   // �� ������ ���� � 01.08.21
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SPDOCT", arr_nazn[j,4])
            endif
            
            if eq_any(arr_nazn[j,1],1,2) // {"� ���� ��",1},{"� ���� ��",2}}
              // � ������ ᯥ樠����� ���ࠢ���
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SP",arr_nazn[j,2]) // १���� �-�� put_prvs_to_reestr(human_->PRVS,_NYEAR)
            elseif arr_nazn[j,1] == 3
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_V",lstr(arr_nazn[j,2]))
              //if human->OBRASHEN == '1'
                //mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_USL",arr_nazn[j,3]) // ���.��㣠 (���), 㪠������ � ���ࠢ�����
              //endif
            elseif eq_any(arr_nazn[j,1],4,5)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PMP",lstr(arr_nazn[j,2]))
            elseif arr_nazn[j,1] == 6
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PK",lstr(arr_nazn[j,2]))
            endif
          next j
          if human->OBRASHEN == '1' // �����७�� �� ���
            for j := 1 to len(arr_onkna)
            // �������� ᢥ����� � �����祭��� �� १���⠬ ��ᯠ��ਧ�樨 ��� XML-���㬥��
            oPRESCRIPTIONS := oPRESCRIPTION:Add( HXMLNode():New( "PRESCRIPTIONS" ) )
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_N",lstr(j+len(arr_nazn)))
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_R",lstr(iif(arr_onkna[j,2]==1, 2, arr_onkna[j,2])))

            if !empty(arr_onkna[j,6])   // �� ������ ���� � 01.08.21
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_IDDOKT", arr_onkna[j,6])
            endif

            if !empty(arr_onkna[j,7])   // �� ������ ���� � 01.08.21
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SPDOCT", arr_onkna[j,7])
            endif

            if arr_onkna[j,2] == 1 // ���ࠢ����� � ��������
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SP",iif(human->VZROS_REB==0,'41','19')) // ᯥ�-�� ��������� ��� ���᪠� ���������
            else // == 3 �� ����᫥�������
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_V",lstr(arr_onkna[j,3]))
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_USL",arr_onkna[j,4])
            endif
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAPR_DATE",date2xml(arr_onkna[j,1]))
            if !empty(arr_onkna[j,5]) .and. !empty(mNPR_MO := ret_mo(arr_onkna[j,5])[_MO_KOD_FFOMS])
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAPR_MO",mNPR_MO)
            endif
            next j
          endif
        endif
      endif
      if is_KSG
        // �������� ᢥ����� � ��� ��� XML-���㬥��
        oKSG := oSL:Add( HXMLNode():New( "KSG_KPG" ) )
        mo_add_xml_stroke(oKSG,"N_KSG",lshifr_zak_sl)
        if !empty(human_2->pc3) .and. !left(human_2->pc3,1) == '6' // �஬� "�����"
          mo_add_xml_stroke(oKSG,"CRIT",human_2->pc3)
        elseif is_oncology  == 2
          if !empty(onksl->crit) .and. !(alltrim(onksl->crit) == "���")
            mo_add_xml_stroke(oKSG,"CRIT",onksl->crit)
          endif
          if !empty(onksl->crit2)
            mo_add_xml_stroke(oKSG,"CRIT",onksl->crit2)  // ��ன ���਩
          endif
        endif
        mo_add_xml_stroke(oKSG,"SL_K",iif(empty(akslp),'0','1'))
        if !empty(akslp)
          // �������� ᢥ����� � ��� ��� XML-���㬥��
          if year(human->K_DATA) >= 2021     // 02.02.21 ������ 
            tKSLP := getKSLPtable(human->K_DATA)

            mo_add_xml_stroke(oKSG, "IT_SL", lstr(ret_koef_kslp_21_XML(akslp, tKSLP, year(human->K_DATA)), 7, 5))

            for iAKSLP := 1 to len(akslp)
              if (cKSLP := ascan(tKSLP, {|x| x[1] == akslp[ iAKSLP ] })) > 0
                oSLk := oKSG:Add( HXMLNode():New( "SL_KOEF" ) )
                mo_add_xml_stroke( oSLk, "ID_SL", lstr(akslp[ iAKSLP ] ) )
                mo_add_xml_stroke( oSLk, "VAL_C", lstr( tKSLP[ cKSLP, 4 ], 7, 5 ) )
              endif
            next
          else
            mo_add_xml_stroke(oKSG,"IT_SL",lstr(ret_koef_kslp(akslp),7,5))
            oSLk := oKSG:Add( HXMLNode():New( "SL_KOEF" ) )
            mo_add_xml_stroke(oSLk,"ID_SL",lstr(akslp[1]))
            mo_add_xml_stroke(oSLk,"VAL_C",lstr(akslp[2],7,5))
            if len(akslp) >= 4
              oSLk := oKSG:Add( HXMLNode():New( "SL_KOEF" ) )
              mo_add_xml_stroke(oSLk,"ID_SL",lstr(akslp[3]))
              mo_add_xml_stroke(oSLk,"VAL_C",lstr(akslp[4],7,5))
            endif
          endif
        endif
        if !empty(akiro)
          // �������� ᢥ����� � ���� ��� XML-���㬥��
          oSLk := oKSG:Add( HXMLNode():New( "S_KIRO" ) )
          mo_add_xml_stroke(oSLk,"CODE_KIRO",lstr(akiro[1]))
          mo_add_xml_stroke(oSLk,"VAL_K",lstr(akiro[2],4,2))
        endif
      elseif is_zak_sl .or. is_zak_sl_vr
        mo_add_xml_stroke(oSL,"CODE_MES1",lshifr_zak_sl)
      endif
      if human_->USL_OK < 4 .and. is_oncology > 0
        for j := 1 to len(arr_onkna)
          // �������� ᢥ����� � ���ࠢ������ ��� XML-���㬥��
          oNAPR := oSL:Add( HXMLNode():New( "NAPR" ) )
          mo_add_xml_stroke(oNAPR,"NAPR_DATE",date2xml(arr_onkna[j,1]))
          if !empty(arr_onkna[j,5]) .and. !empty(mNPR_MO := ret_mo(arr_onkna[j,5])[_MO_KOD_FFOMS])
            mo_add_xml_stroke(oNAPR,"NAPR_MO",mNPR_MO)
          endif
          mo_add_xml_stroke(oNAPR,"NAPR_V",lstr(arr_onkna[j,2]))
          if arr_onkna[j,2] == 3
            mo_add_xml_stroke(oNAPR,"MET_ISSL",lstr(arr_onkna[j,3]))
            mo_add_xml_stroke(oNAPR,"NAPR_USL",arr_onkna[j,4])
          endif
        next j
      endif
      if is_oncology > 0 .or. is_oncology_smp > 0
        // �������� ᢥ����� � ���ᨫ�㬠� ��� XML-���㬥��
        oCONS := oSL:Add( HXMLNode():New( "CONS" ) ) // ���ᨫ�㬮� �.�.��᪮�쪮 (�� � ��� ����)
        mo_add_xml_stroke(oCONS,"PR_CONS",lstr(onkco->PR_CONS)) // N019
        if !empty(onkco->DT_CONS)
          mo_add_xml_stroke(oCONS,"DT_CONS",date2xml(onkco->DT_CONS))
        endif
      endif
      if human_->USL_OK < 4 .and. is_oncology == 2
        // �������� ᢥ����� �� ��������� ��� XML-���㬥��
        oONK_SL := oSL:Add( HXMLNode():New( "ONK_SL" ) )
        mo_add_xml_stroke(oONK_SL,"DS1_T",lstr(onksl->DS1_T))
        if between(onksl->DS1_T,0,4)
          mo_add_xml_stroke(oONK_SL,"STAD",lstr(onksl->STAD))
          if onksl->DS1_T == 0 .and. human->vzros_reb == 0
            mo_add_xml_stroke(oONK_SL,"ONK_T",lstr(onksl->ONK_T))
            mo_add_xml_stroke(oONK_SL,"ONK_N",lstr(onksl->ONK_N))
            mo_add_xml_stroke(oONK_SL,"ONK_M",lstr(onksl->ONK_M))
          endif
          if between(onksl->DS1_T,1,2) .and. onksl->MTSTZ == 1
            mo_add_xml_stroke(oONK_SL,"MTSTZ",lstr(onksl->MTSTZ))
          endif
        endif
        if eq_ascan(arr_onk_usl,3,4)
          mo_add_xml_stroke(oONK_SL,"SOD",lstr(onksl->sod,6,2))
          mo_add_xml_stroke(oONK_SL,"K_FR",lstr(onksl->k_fr))
        endif
        if eq_ascan(arr_onk_usl,2,4)
          mo_add_xml_stroke(oONK_SL,"WEI",lstr(onksl->WEI,5,1))
          mo_add_xml_stroke(oONK_SL,"HEI",lstr(onksl->HEI))
          mo_add_xml_stroke(oONK_SL,"BSA",lstr(onksl->BSA,5,2))
        endif
        for j := 1 to len(arr_onkdi)
          // �������� ᢥ����� � ���������᪨� ��㣠� ��� XML-���㬥��
          oDIAG := oONK_SL:Add( HXMLNode():New( "B_DIAG" ) )
          mo_add_xml_stroke(oDIAG,"DIAG_DATE",date2xml(arr_onkdi[j,1]))
          mo_add_xml_stroke(oDIAG,"DIAG_TIP", lstr(arr_onkdi[j,2]))
          mo_add_xml_stroke(oDIAG,"DIAG_CODE",lstr(arr_onkdi[j,3]))
          if arr_onkdi[j,4] > 0
            mo_add_xml_stroke(oDIAG,"DIAG_RSLT",lstr(arr_onkdi[j,4]))
            mo_add_xml_stroke(oDIAG,"REC_RSLT",'1')
          endif
        next j
        for j := 1 to len(arr_onkpr)
          // �������� ᢥ����� � ��⨢��������� � �⪠��� ��� XML-���㬥��
          oPROT := oONK_SL:Add( HXMLNode():New( "B_PROT" ) )
          mo_add_xml_stroke(oPROT,"PROT",lstr(arr_onkpr[j,1]))
          mo_add_xml_stroke(oPROT,"D_PROT",date2xml(arr_onkpr[j,2]))
        next j
        if human_->USL_OK < 3 .and. iif(human_2->VMP == 1, .t., between(onksl->DS1_T,0,2)) .and. len(arr_onk_usl) > 0
          select ONKUS
          find (str(human->kod,7))
          do while onkus->kod == human->kod .and. !eof()
            if between(onkus->USL_TIP,1,5)
              // �������� ᢥ����� �� ��㣥 �ਫ�祭�� ���������᪮�� ���쭮�� ��� XML-���㬥��
              oONK := oONK_SL:Add( HXMLNode():New( "ONK_USL" ) )
              mo_add_xml_stroke(oONK,"USL_TIP",lstr(onkus->USL_TIP))
              if onkus->USL_TIP == 1
                mo_add_xml_stroke(oONK,"HIR_TIP",lstr(onkus->HIR_TIP))
              endif
              if onkus->USL_TIP == 2
                mo_add_xml_stroke(oONK,"LEK_TIP_L",lstr(onkus->LEK_TIP_L))
                mo_add_xml_stroke(oONK,"LEK_TIP_V",lstr(onkus->LEK_TIP_V))
              endif
              if eq_any(onkus->USL_TIP,3,4)
                mo_add_xml_stroke(oONK,"LUCH_TIP",lstr(onkus->LUCH_TIP))
              endif
              if eq_any(onkus->USL_TIP,2,4)
                old_lek := space(6) ; old_sh := space(10)
                select ONKLE  //  横� �� �� �������
                find (str(human->kod,7))
                do while onkle->kod == human->kod .and. !eof()
                  if !(old_lek == onkle->REGNUM .and. old_sh == onkle->CODE_SH)
                    // �������� ᢥ����� � �ਬ������� ������⢥���� �९���� �� ��祭�� ���������᪮�� ���쭮�� ��� XML-���㬥��
                    oLEK := oONK:Add( HXMLNode():New( "LEK_PR" ) )
                    mo_add_xml_stroke(oLEK,"REGNUM",onkle->REGNUM)
                    mo_add_xml_stroke(oLEK,"CODE_SH",onkle->CODE_SH)
                  endif
                  // 横� �� ��⠬ ��� ������� ������⢠
                  mo_add_xml_stroke(oLEK,"DATE_INJ",date2xml(onkle->DATE_INJ))
                  old_lek := onkle->REGNUM ; old_sh := onkle->CODE_SH
                  select ONKLE
                  skip
                enddo
                if onkus->PPTR > 0
                  mo_add_xml_stroke(oONK,"PPTR",'1')
                endif
              endif
            endif
            select ONKUS
            skip
          enddo
        endif
      endif
      sCOMENTSL := ""
      if p_tip_reestr == 1
        mo_add_xml_stroke(oSL,"PRVS",put_prvs_to_reestr(human_->PRVS,_NYEAR))
        if (!is_mgi .and. ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)) .or. human_->profil == 15 //���⮫����
          mo_add_xml_stroke(oSL,"IDDOKT","0")
        else
          p2->(dbGoto(human_->vrach))
          mo_add_xml_stroke(oSL,"IDDOKT",p2->snils)
        endif
        if is_zak_sl .or. is_zak_sl_vr
          mo_add_xml_stroke(oSL,"ED_COL",'1')
          mo_add_xml_stroke(oSL,"TARIF" ,lstr(tarif_zak_sl,10,2))
        endif
        mo_add_xml_stroke(oSL,"SUM_M",lstr(human->cena_1,10,2))

        if (human->k_data >= d_01_01_2022) .and. ((rtrim(mdiagnoz[1]) == 'U07.1') ;
              .or. ((rtrim(mdiagnoz[1]) == 'U07.2'))) .and. (human_->USL_OK == 1) .and. (human_->PROFIL != 158) ;
              .and. (human_->VIDPOM != 32) .and. (lower(alltrim(human_2->PC3)) != 'stt5')

          arrLP := collect_lek_pr(human->(recno()))
          if len(arrLP) != 0
            for each row in arrLP
              oLEK := oSL:Add( HXMLNode():New( 'LEK_PR' ) )
              mo_add_xml_stroke(oLEK, "DATA_INJ", date2xml(row[1]))
              mo_add_xml_stroke(oLEK, "CODE_SH", row[2])
              if ! empty(row[3])
                mo_add_xml_stroke(oLEK, "REGNUM", row[3])
                // mo_add_xml_stroke(oLEK, "CODE_MARK", '')  // ��� ���쭥�襣� �ᯮ�짮�����
                oDOSE := oLEK:Add( HXMLNode():New( 'LEK_DOSE' ) )
                mo_add_xml_stroke(oDOSE, "ED_IZM", str(row[4], 3, 0))
                mo_add_xml_stroke(oDOSE, "DOSE_INJ", str(row[5], 8, 2))
                mo_add_xml_stroke(oDOSE, "METHOD_INJ", str(row[6], 3, 0))
                mo_add_xml_stroke(oDOSE, "COL_INJ", str(row[7], 5, 0))
              endif
            next
          endif
          
        endif

        if !empty(ldate_next)
          mo_add_xml_stroke(oSL,"NEXT_VISIT",date2xml(bom(ldate_next)))
        endif
        //
        j := 0
        if (ibrm := f_oms_beremenn(mdiagnoz[1])) == 1 .and. eq_any(human_->profil,136,137) // �������� � �����������
          j := iif(human_2->pn2 == 1, 4, 3)
        elseif ibrm == 2 .and. human_->USL_OK == 3 // �����������
          j := iif(human_2->pn2 == 1, 5, 6)
          if j == 5 .and. !eq_any(human_->profil,136,137)
            j := 6  // �.�. ⮫쪮 �����-��������� ����� ���⠢��� �� ���� �� ��६������
          endif
        endif
        if j > 0
          sCOMENTSL += lstr(j)
        endif
        if human_->USL_OK == 3 .and. eq_any(lvidpom,1,11,12,13)
          sCOMENTSL += ":;" // ���� ⠪ (��⮬ ������� ���.�������)
        endif
      else   // ��� ॥��஢ �� ��ᯠ��ਧ�樨
        if is_zak_sl .or. is_zak_sl_vr
          mo_add_xml_stroke(oSL,"ED_COL",'1')
        endif
        mo_add_xml_stroke(oSL,"PRVS",put_prvs_to_reestr(human_->PRVS,_NYEAR))
        if is_zak_sl .or. is_zak_sl_vr
          mo_add_xml_stroke(oSL,"TARIF" ,lstr(tarif_zak_sl,10,2))
        endif
        mo_add_xml_stroke(oSL,"SUM_M",lstr(human->cena_1,10,2))
        //
        if between(human->ishod,201,205) // ���
          j := iif(human->RAB_NERAB==0,20,iif(human->RAB_NERAB==1,10,14))
          if human->ishod != 203 .and. m1veteran == 1
            j := iif(human->RAB_NERAB==0, 21, 11)
          endif
          sCOMENTSL := lstr(j)
        elseif between(human->ishod,301,302)
          j := iif(between(m1mesto_prov,0,1), m1mesto_prov, 0)
          sCOMENTSL := lstr(j)
        endif
      endif
      if p_tip_reestr == 1 .and. !empty(sCOMENTSL)
        mo_add_xml_stroke(oSL,"COMENTSL",sCOMENTSL)
      endif
      if !is_zak_sl
        for j := 1 to len(a_usl)
          select HU
          goto (a_usl[j])
          if hu->kod_vr == 0
            loop
          endif
          hu_->(G_RLock(forever))
          hu_->REES_ZAP := ++iusl
          lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          // �������� ᢥ����� �� ��㣠� ��� XML-���㬥��
          oUSL := oSL:Add( HXMLNode():New( "USL" ) )
          mo_add_xml_stroke(oUSL,"IDSERV",lstr(hu_->REES_ZAP))
          mo_add_xml_stroke(oUSL,"ID_U",hu_->ID_U)
          fl := .f.
          if eq_any(hu->is_edit,1,2) // ����⮫����᪨� ��᫥�������
            mo_add_xml_stroke(oUSL,"LPU",kod_LIS[hu->is_edit]) // ���-�� �஢������ � ���2 ��� ���
          elseif lshifr == "4.20.2" .or. hu->is_edit == 3 // ������⭠� �⮫���� ��� ��� � �����
            mo_add_xml_stroke(oUSL,"LPU",'103001') // �.�. ���-�� �஢������ � ���������
          elseif hu->is_edit == 4
            mo_add_xml_stroke(oUSL,"LPU",'000000') // �.�. ���-�� �஢������ � ��襬 ���.����.���
          elseif hu->is_edit == 5
            mo_add_xml_stroke(oUSL,"LPU",'999999') // �.�. ���-�� �஢������ � ���.����.��� � ��㣮� ������
          else
            if pr_amb_reab .and. left(lshifr,2)=='4.' .and. left(hu_->zf,6) == '999999'
              fl := .t.
              mo_add_xml_stroke(oUSL,"LPU",'999999')
            elseif pr_amb_reab .and. left(lshifr,2)=='4.' .and. !empty(left(hu_->zf,6)) .and. left(hu_->zf,6)!=glob_mo[_MO_KOD_TFOMS]
              fl := .t.
              mo_add_xml_stroke(oUSL,"LPU",left(hu_->zf,6))
            else
              mo_add_xml_stroke(oUSL,"LPU",CODE_LPU)
            endif
          endif
          if p_tip_reestr == 1
            if human_->USL_OK == 1 .and. is_otd_dep
              otd->(dbGoto(hu->OTD))
              f_put_glob_podr(human_->USL_OK,human->K_DATA) // ��������� ��� ���ࠧ�������
              if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
                i := 1
              endif
              mo_add_xml_stroke(oUSL,"LPU_1",lstr(mm_otd_dep[i,3]))
              mo_add_xml_stroke(oUSL,"PODR" ,lstr(glob_otd_dep))
            elseif hu->KOL_RCP < 0 .and. DomUslugaTFOMS(lshifr)
              mo_add_xml_stroke(oUSL,"PODR",'0')
            endif
          endif
          mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(hu_->PROFIL))
          select T21
          find (padr(lshifr,10))
          if found()
            mo_add_xml_stroke(oUSL,"VID_VME",alltrim(t21->shifr_mz))
          endif
          if p_tip_reestr == 1
            mo_add_xml_stroke(oUSL,"DET"   ,iif(human->VZROS_REB==0,'0','1'))
          endif
          mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(c4tod(hu->DATE_U)))
          mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(c4tod(hu_->DATE_U2)))
          if p_tip_reestr == 1
            // �������� ������� �᫨ ����室��� ��� �����-��������� �९��⮢
            if endDateZK >= 0d20220101 .and. alltrim(hu_->kod_diag) == 'Z92.2'
              mo_add_xml_stroke(oUSL,"DS"    , diagnoz_replace)
            else
              mo_add_xml_stroke(oUSL,"DS"    , hu_->kod_diag)
            endif
          else
            mo_add_xml_stroke(oUSL,"P_OTK" ,'0')
          endif
          mo_add_xml_stroke(oUSL,"CODE_USL",lshifr)
          mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(hu->KOL_1,6,2))
          mo_add_xml_stroke(oUSL,"TARIF"   ,lstr(hu->U_CENA,10,2))
          mo_add_xml_stroke(oUSL,"SUMV_USL",lstr(hu->STOIM_1,10,2))

          if (human->k_data >= 0d20210801 .and. p_tip_reestr == 2) ;      // �ࠢ��� ���������� � 01.08.21 ���쬮 � 04-18-13 �� 20.07.21
              .or. (endDateZK >= d_01_01_2022 .and. p_tip_reestr == 1)  // �ࠢ��� ���������� � 01.01.22 ���쬮 � 04-18?17 �� 28.12.2021
              // .or. (human->k_data >= d_01_01_2022 .and. p_tip_reestr == 1)  // �ࠢ��� ���������� � 01.01.22 ���쬮 � 04-18?17 �� 28.12.2021
              
            if between_date(human->n_data, human->k_data, c4tod(hu->DATE_U))
              oMR_USL_N := oUSL:Add( HXMLNode():New( "MR_USL_N" ) )
              mo_add_xml_stroke(oMR_USL_N,"MR_N",lstr(1))   // ���� �⠢�� 1 �ᯮ���⥫�
              mo_add_xml_stroke(oMR_USL_N,"PRVS",put_prvs_to_reestr(hu_->PRVS,_NYEAR))
              p2->(dbGoto(hu->kod_vr))
              mo_add_xml_stroke(oMR_USL_N,"CODE_MD",p2->snils)
            endif
          else  // if (human->k_data < 0d20210801 .and. p_tip_reestr == 2)
            mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(hu_->PRVS,_NYEAR))
            if c4tod(hu->DATE_U) < human->n_data ; // �᫨ ᤥ���� ࠭��
                .or. eq_any(hu->is_edit,-1,1,2,3) .or. lshifr == "4.20.2" .or. left(lshifr,5) == "60.8." .or. fl
              mo_add_xml_stroke(oUSL,"CODE_MD",'0') // �� ���������� ��� ���
            else
              p2->(dbGoto(hu->kod_vr))
              mo_add_xml_stroke(oUSL,"CODE_MD",p2->snils)
            endif
          endif
        next
      endif
      if p_tip_reestr == 2 .and. len(a_otkaz) > 0 // �⪠�� (��ᯠ��ਧ��� ��� ���ᬮ�� ��ᮢ�襭����⭨�)
        // �������� ᢥ����� �� ��㣠� ��� XML-���㬥��
        for j := 1 to len(a_otkaz)
          oUSL := oSL:Add( HXMLNode():New( "USL" ) )
          mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(++iusl))
          mo_add_xml_stroke(oUSL,"ID_U"    ,mo_guid(3,iusl))
          mo_add_xml_stroke(oUSL,"LPU"     ,CODE_LPU)
          mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(a_otkaz[j,4]))
          select T21
          find (padr(a_otkaz[j,1],10))
          if found()
            mo_add_xml_stroke(oUSL,"VID_VME",alltrim(t21->shifr_mz))
          endif
          mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(a_otkaz[j,3]))
          mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(a_otkaz[j,3]))
          mo_add_xml_stroke(oUSL,"P_OTK"   ,lstr(a_otkaz[j,7]))
          mo_add_xml_stroke(oUSL,"CODE_USL",a_otkaz[j,1])
          mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(1,6,2))
          mo_add_xml_stroke(oUSL,"TARIF"   ,lstr(a_otkaz[j,6],10,2))
          mo_add_xml_stroke(oUSL,"SUMV_USL",lstr(a_otkaz[j,6],10,2))

          if human->k_data >= 0d20210801 .and. p_tip_reestr == 2 ; // ���� �ࠢ��� ���������� � 01.08.21 ���쬮 � 04-18-13 �� 20.07.21
              .or. (endDateZK >= d_01_01_2022 .and. p_tip_reestr == 1)  // �ࠢ��� ���������� � 01.01.22 ���쬮 � 04-18?17 �� 28.12.2021
            // ���������஢�� ��᫥ ࠧ��᭥��� �.�.��⮭���� 18.08.21
            // oMR_USL_N := oUSL:Add( HXMLNode():New( "MR_USL_N" ) )
            // mo_add_xml_stroke(oMR_USL_N,"MR_N",lstr(1))   // ��筨��
            // mo_add_xml_stroke(oMR_USL_N,"PRVS",put_prvs_to_reestr(a_otkaz[j,5],_NYEAR))
            // mo_add_xml_stroke(oMR_USL_N,"CODE_MD",'0') // �� ���������� ��� ���
          else  //if human->k_data < 0d20210801 .and. p_tip_reestr == 2
            mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(a_otkaz[j,5],_NYEAR))
            mo_add_xml_stroke(oUSL,"CODE_MD" ,'0') // �⪠� => 0
          endif

        next
      endif
      // if p_tip_reestr == 1 .and. len(a_fusl) > 0 // ������塞 ����樨
      if len(a_fusl) > 0 // ������塞 ����樨 // ��ࠢ�� �⮡� �ࠫ� 㣫㡫����� ��ᯠ��ਧ��� COVID
        for j := 1 to len(a_fusl)
          select MOHU
          goto (a_fusl[j])
          if mohu->kod_vr == 0
            loop
          endif
          mohu->(G_RLock(forever))
          mohu->REES_ZAP := ++iusl
          lshifr := alltrim(mosu->shifr1)
          // �������� ᢥ����� �� ��㣠� ��� XML-���㬥��
          oUSL := oSL:Add( HXMLNode():New( "USL" ) )
          mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(mohu->REES_ZAP))
          mo_add_xml_stroke(oUSL,"ID_U"    ,mohu->ID_U)
          mo_add_xml_stroke(oUSL,"LPU"     ,CODE_LPU)
          if human_->USL_OK == 1 .and. is_otd_dep
            otd->(dbGoto(mohu->OTD))
            f_put_glob_podr(human_->USL_OK,human->K_DATA) // ��������� ��� ���ࠧ�������
            if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
              i := 1
            endif
            mo_add_xml_stroke(oUSL,"LPU_1",lstr(mm_otd_dep[i,3]))
            mo_add_xml_stroke(oUSL,"PODR" ,lstr(glob_otd_dep))
          endif
          mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(mohu->PROFIL))
          if p_tip_reestr == 1
            mo_add_xml_stroke(oUSL,"VID_VME",lshifr)
            mo_add_xml_stroke(oUSL,"DET"     ,iif(human->VZROS_REB==0,'0','1'))
          endif
          mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(c4tod(mohu->DATE_U)))
          mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(c4tod(mohu->DATE_U2)))
          if p_tip_reestr == 1
            // �������� ������� �᫨ ����室��� ��� �����-��������� �९��⮢
            if endDateZK >= 0d20220101 .and. alltrim(mohu->kod_diag) == 'Z92.2'
              mo_add_xml_stroke(oUSL,"DS"    , diagnoz_replace)
            else
              mo_add_xml_stroke(oUSL,"DS"      ,mohu->kod_diag)
            endif
          endif
          if p_tip_reestr == 2
// ࠧ������� � �⪠���� ��㣠�� �����
            mo_add_xml_stroke(oUSL,"P_OTK" ,'0')
          endif
          mo_add_xml_stroke(oUSL,"CODE_USL",lshifr)
          mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(mohu->KOL_1,6,2))
          if p_tip_reestr == 1
            mo_add_xml_stroke(oUSL,"TARIF"   ,lstr(mohu->U_CENA,10,2))//lstr(mohu->U_CENA,10,2))
            mo_add_xml_stroke(oUSL,"SUMV_USL",lstr(mohu->STOIM_1,10,2))//lstr(mohu->STOIM_1,10,2))
          elseif p_tip_reestr == 2
            mo_add_xml_stroke(oUSL,"TARIF"   ,'0')//lstr(mohu->U_CENA,10,2))
            mo_add_xml_stroke(oUSL,"SUMV_USL",'0')//lstr(mohu->STOIM_1,10,2))
          endif
          // mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(mohu->PRVS,_NYEAR))  // ��������஢�� 04.08.21
          fl := .f.
          if is_telemedicina(lshifr,@fl) // �� ���������� ��� ���
            mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(mohu->PRVS,_NYEAR))  // ������� 04.08.21
            mo_add_xml_stroke(oUSL,"CODE_MD",'0')
          else
            if (human->k_data >= 0d20210801 .and. p_tip_reestr == 2) ;      // �ࠢ��� ���������� � 01.08.21 ���쬮 � 04-18-13 �� 20.07.21
                .or. (human->k_data >= d_01_01_2022 .and. p_tip_reestr == 1)  // �ࠢ��� ���������� � 01.01.22 ���쬮 � 04-18?17 �� 28.12.2021
              if (p_tip_reestr == 1) .and. ((aImpl := ret_impl_V036(lshifr, c4tod(hu_->DATE_U2))) != NIL)
                // �஢�ਬ ����稥 ������⠭⮢
                IMPL->(dbSeek(str(human->kod, 7), .t.))
                if IMPL->(found())
                  oMED_DEV := oUSL:Add( HXMLNode():New( "MED_DEV" ) )
                  mo_add_xml_stroke(oMED_DEV,"DATE_MED", date2xml(IMPL->DATE_UST))   // ���� �⠢�� 1 �ᯮ���⥫�
                  mo_add_xml_stroke(oMED_DEV,"CODE_MEDDEV", lstr(IMPL->RZN))

                  if (ser_num := chek_implantant_ser_number(IMPL->(recno()))) != nil
                    mo_add_xml_stroke(oMED_DEV,"NUMBER_SER", alltrim(ser_num))
                  endif
                endif
                aImpl := nil
                ser_num := nil
              endif
              if between_date(human->n_data, human->k_data, c4tod(mohu->DATE_U))
                oMR_USL_N := oUSL:Add( HXMLNode():New( "MR_USL_N" ) )
                mo_add_xml_stroke(oMR_USL_N,"MR_N",lstr(1))   // ���� �⠢�� 1 �ᯮ���⥫�
                mo_add_xml_stroke(oMR_USL_N,"PRVS",put_prvs_to_reestr(mohu->PRVS,_NYEAR))
                p2->(dbGoto(mohu->kod_vr))
                mo_add_xml_stroke(oMR_USL_N,"CODE_MD",p2->snils)
              endif
            else  //if human->k_data < d_01_01_2022 .and. p_tip_reestr == 1
              mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(mohu->PRVS,_NYEAR))  // ������� 04.08.21
              p2->(dbGoto(mohu->kod_vr))                                            // ������� 04.08.21
              mo_add_xml_stroke(oUSL,"CODE_MD" ,p2->snils)                          // ������� 04.08.21
            endif
          endif
          if !empty(mohu->zf)
            dbSelectArea(laluslf)
            find (padr(lshifr,20))
            if found()
              if fl // ⥫�����樭� + ����
                mo_add_xml_stroke(oUSL,"COMENTU",mohu->zf) // ��� ����:䠪� ����祭�� १����
              elseif STisZF(human_->USL_OK,human_->PROFIL) .and. &laluslf.->zf == 1  // ��易⥫�� ���� �㡭�� ����
                mo_add_xml_stroke(oUSL,"COMENTU",arr2list(STretArrZF(mohu->zf))) // ��㫠 �㡠
              elseif !empty(&laluslf.->par_org) // �஢�ਬ �� ���� ����樨
                mo_add_xml_stroke(oUSL,"COMENTU",mohu->zf) // ���� �࣠��
              endif
            endif
          endif
        next j
      endif
      if p_tip_reestr == 2 .and. !empty(sCOMENTSL)   // ��� ॥��஢ �� ��ᯠ��ਧ�樨
        if (is_disp_DVN .or. is_disp_DVN_COVID)
          sCOMENTSL += ":"
          if !empty(ar_dn) // ���� �� ��ᯠ��୮� �������
            for i := 1 to 5
              sk := lstr(i)
              pole_diag := "mdiag"+sk
              pole_1dispans := "m1dispans"+sk
              pole_dn_dispans := "mdndispans"+sk
              if !empty(&pole_diag) .and. &pole_1dispans == 1 .and. ascan(sadiag1,alltrim(&pole_diag)) > 0 ;
                              .and. !empty(&pole_dn_dispans) ;
                              .and. (j := ascan(ar_dn,{|x| alltrim(x[2]) == alltrim(&pole_diag) })) > 0
                ar_dn[j,4] := date2xml(bom(&pole_dn_dispans))
              endif
            next
            for j := 1 to len(ar_dn)
              if !empty(ar_dn[j,4])
                sCOMENTSL += "2,"+alltrim(ar_dn[j,2])+",,"+ar_dn[j,4]+"/"
              endif
            next
            if right(sCOMENTSL,1) == "/"
              sCOMENTSL := left(sCOMENTSL,len(sCOMENTSL)-1)
            endif
          endif
          sCOMENTSL += ";"
        endif
        mo_add_xml_stroke(oSL,"COMENTSL",sCOMENTSL)
      endif
    next isl
    select RHUM
    if rhum->REES_ZAP % 2000 == 0
      dbUnlockAll()
      dbCommitAll()
    endif
    skip
  enddo
  dbUnlockAll()
  dbCommitAll()

  stat_msg("������ XML-���㬥�� � 䠩� ॥��� ��砥�")

  oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
  name_zip := alltrim(mo_xml->FNAME)+szip
  aadd(arr_zip, alltrim(mo_xml->FNAME)+sxml)
  //
  //
  fl_ver := 311
  stat_msg("���⠢����� ॥��� ��樥�⮢")
  oXmlDoc := HXMLDoc():New()
  // �������� ��୥��� ����� ॥��� ��樥�⮢ ��� XML-���㬥��
  oXmlDoc:Add( HXMLNode():New( "PERS_LIST") )
  // �������� ��������� 䠩�� ॥��� ��樥�⮢ ��� XML-���㬥��
  oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
  s := '3.11'
  if strzero(_nyear,4)+strzero(_nmonth,2) > "201910" // � ����� 2019 ����
    fl_ver := 32
    s := '3.2'
  endif
  mo_add_xml_stroke(oXmlNode,"VERSION"  ,s)
  mo_add_xml_stroke(oXmlNode,"DATA"     ,date2xml(rees->DSCHET))
  mo_add_xml_stroke(oXmlNode,"FILENAME" ,mo_xml->FNAME2)
  mo_add_xml_stroke(oXmlNode,"FILENAME1",mo_xml->FNAME)
  select RHUM
  go top
  do while !eof()
    @ maxrow(),0 say str(rhum->REES_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
    select HUMAN
    goto (rhum->kod_hum)  // ��⠫� �� 1-� ���� ����
    if human->ishod == 89  // � �� �� 1-�, � 2-�� �/�
      select HUMAN_3
      set order to 2
      find (str(rhum->kod_hum,7))
      select HUMAN
      goto (human_3->kod)  // ��⠫� �� 1-� ���� ����
    endif
    arr_fio := retFamImOt(2,.f.)
    // �������� ᢥ����� � ��樥�� ��� XML-���㬥��
    oPAC := oXmlDoc:aItems[1]:Add( HXMLNode():New( "PERS" ) )
    mo_add_xml_stroke(oPAC,"ID_PAC" ,human_->ID_PAC)
    if human_->NOVOR == 0
      mo_add_xml_stroke(oPAC,"FAM"  ,arr_fio[1])
      if !empty(arr_fio[2])
        mo_add_xml_stroke(oPAC,"IM"   ,arr_fio[2])
      endif
      if !empty(arr_fio[3])
        mo_add_xml_stroke(oPAC,"OT" ,arr_fio[3])
      endif
      mo_add_xml_stroke(oPAC,"W"    ,iif(human->pol=="�",'1','2'))
      mo_add_xml_stroke(oPAC,"DR"   ,date2xml(human->date_r))
      if empty(arr_fio[3])
        mo_add_xml_stroke(oPAC,"DOST",'1') // ��������� ����⢮
      endif
      if empty(arr_fio[2])
        mo_add_xml_stroke(oPAC,"DOST",'3') // ��������� ���
      endif
      if p_tip_reestr == 2 // ����뢠���� ⮫쪮 ��� ��ᯠ��ਧ�樨 �� �।��⠢����� ᢥ�����
        if     len(alltrim(kart_->PHONE_H)) == 11
          mo_add_xml_stroke(oPAC,"TEL",substr(kart_->PHONE_H,2))
        elseif len(alltrim(kart_->PHONE_M)) == 11
          mo_add_xml_stroke(oPAC,"TEL",substr(kart_->PHONE_M,2))
        elseif len(alltrim(kart_->PHONE_W)) == 11
          mo_add_xml_stroke(oPAC,"TEL",substr(kart_->PHONE_W,2))
        endif
      endif
    else
      mo_add_xml_stroke(oPAC,"W"    ,iif(human_->pol2=="�",'1','2'))
      mo_add_xml_stroke(oPAC,"DR"   ,date2xml(human_->date_r2))
      mo_add_xml_stroke(oPAC,"FAM_P",arr_fio[1])
      if !empty(arr_fio[2])
        mo_add_xml_stroke(oPAC,"IM_P" ,arr_fio[2])
      endif
      if !empty(arr_fio[3])
        mo_add_xml_stroke(oPAC,"OT_P",arr_fio[3])
      endif
      mo_add_xml_stroke(oPAC,"W_P"  ,iif(human->pol=="�",'1','2'))
      mo_add_xml_stroke(oPAC,"DR_P" ,date2xml(human->date_r))
      if empty(arr_fio[3])
        mo_add_xml_stroke(oPAC,"DOST_P",'1') // ��������� ����⢮
      endif
      if empty(arr_fio[2])
        mo_add_xml_stroke(oPAC,"DOST_P",'3') // ��������� ���
      endif
    endif
    if !empty(smr := del_spec_symbol(kart_->mesto_r))
      mo_add_xml_stroke(oPAC,"MR",smr)
    endif
    if human_->vpolis == 3 .and. emptyany(kart_->nom_ud,kart_->nom_ud)
      // ��� ������ ����� ��ᯮ�� ����易⥫��
    else
      mo_add_xml_stroke(oPAC,"DOCTYPE",lstr(kart_->vid_ud))
      if !empty(kart_->ser_ud)
        mo_add_xml_stroke(oPAC,"DOCSER",kart_->ser_ud)
      endif
      mo_add_xml_stroke(oPAC,"DOCNUM",kart_->nom_ud)
    endif
    if fl_ver == 32 .and. human_->vpolis < 3 .and. !eq_any(left(human_->OKATO,2),"  ","18") // �����த���
      if !empty(kart_->kogdavyd)
        mo_add_xml_stroke(oPAC,"DOCDATE",date2xml(kart_->kogdavyd))
      endif
      if !empty(kart_->kemvyd) .and. ;
         !empty(smr := del_spec_symbol(inieditspr(A__POPUPMENU, dir_server+"s_kemvyd", kart_->kemvyd)))
        mo_add_xml_stroke(oPAC,"DOCORG",smr)
      endif
    endif
    if !empty(kart->snils)
      mo_add_xml_stroke(oPAC,"SNILS",transform(kart->SNILS,picture_pf))
    endif
    if human_->vpolis == 3 .and. empty(kart_->okatog)
      // ��� ������ ����� ���� ॣ����樨 ����易⥫쭮
    else
      mo_add_xml_stroke(oPAC,"OKATOG" ,kart_->okatog)
    endif
    if len(alltrim(kart_->okatop)) == 11
      mo_add_xml_stroke(oPAC,"OKATOP",kart_->okatop)
    endif
    select RHUM
    skip
  enddo
  stat_msg("������ XML-���㬥�� � 䠩� ॥��� ��樥�⮢")
  oXmlDoc:Save(alltrim(mo_xml->FNAME2)+sxml)
  aadd(arr_zip, alltrim(mo_xml->FNAME2)+sxml)
  //
  close databases
  if chip_create_zipXML(name_zip,arr_zip,.t.)
    keyboard chr(K_TAB)+chr(K_ENTER)
  endif
  return NIL
  
  
***** 05.01.21 ࠡ�⠥� �� ⥪�饩 �����
Function f1_create2reestr19(_nyear,_nmonth)
  Local i, j, lst, s

  fl_DISABILITY := is_zak_sl := is_zak_sl_vr := .f.
  lshifr_zak_sl := lvidpoms := ""
  a_usl := {} ; a_fusl := {} ; lvidpom := 1 ; lfor_pom := 3
  atmpusl := {} ; akslp := {} ; akiro := {} ; tarif_zak_sl := human->cena_1
  kol_kd := 0
  is_KSG := is_mgi := .f.
  v_reabil_slux := 0
  m1veteran := 0
  m1mobilbr := 0  // �����쭠� �ਣ���
  m1mesto_prov := 0
  m1p_otk := 0    // �ਧ��� �⪠��
  m1dopo_na := 0
  m1napr_v_mo := 0 // {{"-- ��� --",0},{"� ���� ��",1},{"� ���� ��",2}}, ;
  arr_mo_spec := {}
  m1napr_stac := 0 // {{"--- ��� ---",0},{"� ��樮���",1},{"� ��. ���.",2}}, ;
  m1profil_stac := 0
  m1napr_reab := 0
  m1profil_kojki := 0
  pr_amb_reab := .f.
  fl_disp_nabl := .f.
  is_disp_DVN := .f.
  is_disp_DVN_COVID := .f.
  ldate_next := ctod("")
  ar_dn := {}
  //
  is_oncology_smp := 0
  is_oncology := f_is_oncology(1,@is_oncology_smp)
  if p_tip_reestr == 2
    is_oncology := 0
  endif
  arr_onkna := {}
  select ONKNA
  find (str(human->kod,7))
  do while onkna->kod == human->kod .and. !eof()
    P2TABN->(dbGoto(onkna->KOD_VR))
    if !(P2TABN->(eof())) .and. !(P2TABN->(bof()))
      // aadd(arr_nazn,{3, i, P2TABN->snils, lstr(ret_prvs_V015toV021(P2TABN->PRVS_NEW))}) // ⥯��� ������ �����祭�� � �⤥�쭮� PRESCRIPTIONS
      mosu->(dbGoto(onkna->U_KOD))
      aadd(arr_onkna, {onkna->NAPR_DATE,onkna->NAPR_V,onkna->MET_ISSL,mosu->shifr1,onkna->NAPR_MO, P2TABN->snils, lstr(ret_prvs_V015toV021(P2TABN->PRVS_NEW))})
    else
      // aadd(arr_nazn,{3, i, '', ''}) // ⥯��� ������ �����祭�� � �⤥�쭮� PRESCRIPTIONS
      mosu->(dbGoto(onkna->U_KOD))
      aadd(arr_onkna, {onkna->NAPR_DATE,onkna->NAPR_V,onkna->MET_ISSL,mosu->shifr1,onkna->NAPR_MO, '', ''})
    endif

    // mosu->(dbGoto(onkna->U_KOD))
    // aadd(arr_onkna, {onkna->NAPR_DATE,onkna->NAPR_V,onkna->MET_ISSL,mosu->shifr1,onkna->NAPR_MO})
    skip
  enddo
  select ONKCO
  find (str(human->kod,7))
  //
  select ONKSL
  find (str(human->kod,7))
  //
  arr_onkdi := {}
  if eq_any(onksl->b_diag,98,99)
    select ONKDI
    find (str(human->kod,7))
    do while onkdi->kod == human->kod .and. !eof()
      aadd(arr_onkdi, {onkdi->DIAG_DATE,onkdi->DIAG_TIP,onkdi->DIAG_CODE,onkdi->DIAG_RSLT})
      skip
    enddo
  endif
  //
  arr_onkpr := {}
  if human_->USL_OK < 3 // ��⨢���������� �� ��祭�� ⮫쪮 � ��樮��� � ������� ��樮���
    select ONKPR
    find (str(human->kod,7))
    do while onkpr->kod == human->kod .and. !eof()
      aadd(arr_onkpr, {onkpr->PROT,onkpr->D_PROT})
      skip
    enddo
  endif
  if eq_any(onksl->b_diag,0,7,8) .and. ascan(arr_onkpr,{|x| x[1] == onksl->b_diag }) == 0
    // ������� �⪠�,�� ��������,��⨢��������� �� ���⮫����
    aadd(arr_onkpr, {onksl->b_diag,human->n_data})
  endif
  //
  arr_onk_usl := {}
  if iif(human_2->VMP == 1, .t., between(onksl->DS1_T,0,2))
    select ONKUS
    find (str(human->kod,7))
    do while onkus->kod == human->kod .and. !eof()
      if between(onkus->USL_TIP,1,5)
        aadd(arr_onk_usl,onkus->USL_TIP)
      endif
      skip
    enddo
  endif
  //
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,,@lst,,@s)
      lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
      if human_->USL_OK == 3 .and. is_usluga_disp_nabl(lshifr)
        ldate_next := c4tod(human->DATE_OPL)
        fl_disp_nabl := .t.
      endif
      aadd(atmpusl,lshifr)
      if eq_any(left(lshifr,5),"1.11.","55.1.")
        kol_kd += hu->kol_1
        is_KSG := .t.
      elseif left(lshifr,5) == "2.89."
        pr_amb_reab := .t.
      elseif left(lshifr,5) == "60.9."
        is_mgi := .t.
      endif
      if !empty(s) .and. "," $ s
        lvidpoms := s
      endif
      if (hu->stoim_1 > 0 .or. left(lshifr,3) == "71.") .and. (i := ret_vid_pom(1,lshifr,human->k_data)) > 0
        lvidpom := i
      endif
      if human_->USL_OK == 3
        if f_is_neotl_pom(lshifr)
          lfor_pom := 2 // ���⫮����
        elseif eq_any(left(lshifr,5),"60.4.","60.5.","60.6.","60.7.","60.8.")
          select OTD
          dbGoto(human->otd)
          if fieldnum("TIP_OTD") > 0 .and. otd->TIP_OTD == 1  // �⤥����� ��񬭮�� ����� ��樮���
            lfor_pom := 2 // ���⫮����
          endif
        endif
      endif
      if lst == 1
        lshifr_zak_sl := lshifr
        if f_is_zak_sl_vr(lshifr) // ���.��砩 � �-��
          is_zak_sl_vr := .t.
        else
          is_zak_sl_vr := .t. // ���
          if human_->USL_OK < 3 .and. p_tip_reestr == 1
            tarif_zak_sl := hu->STOIM_1
            if !empty(human_2->pc1)
              akslp := List2Arr(human_2->pc1)
            endif
            if !empty(human_2->pc2)
              akiro := List2Arr(human_2->pc2)
            endif
          endif
          if !empty(akslp) .or. !empty(akiro)
            otd->(dbGoto(human->OTD))
            f_put_glob_podr(human_->USL_OK,human->K_DATA) // ��������� ��� ���ࠧ�������
            tarif_zak_sl := fcena_oms(lshifr,(human->vzros_reb==0),human->k_data)
          endif
        endif
      else
        aadd(a_usl,hu->(recno()))
      endif
    endif
    select HU
    skip
  enddo
  if human_->USL_OK == 1 .and. human_2->VMP == 1 .and. !emptyany(human_2->VIDVMP,human_2->METVMP) // ���
    is_KSG := .f.
  endif
  if !empty(lvidpoms)
    if !eq_ascan(atmpusl,"55.1.2","55.1.3") .or. glob_mo[_MO_KOD_TFOMS] == '801935' // ���-��᪢�
      lvidpoms := ret_vidpom_licensia(human_->USL_OK,lvidpoms,human_->profil) // ⮫쪮 ��� ��.��樮��� �� ��樮���
    else
      if eq_ascan(atmpusl,"55.1.3")
        lvidpoms := ret_vidpom_st_dom_licensia(human_->USL_OK,lvidpoms,human_->profil)
      endif
    endif
    if !empty(lvidpoms) .and. !("," $ lvidpoms)
      lvidpom := int(val(lvidpoms))
      lvidpoms := ""
    endif
  endif
  if !empty(lvidpoms)
    if eq_ascan(atmpusl,"55.1.1","55.1.4")
      if "31" $ lvidpoms
        lvidpom := 31
      endif
    elseif eq_ascan(atmpusl,"55.1.2","55.1.3","2.76.6","2.76.7","2.81.67")
      if eq_any(human_->PROFIL,57,68,97) //�࠯��,�������,��� ���.�ࠪ⨪�
        if "12" $ lvidpoms
          lvidpom := 12
        endif
      else
        if "13" $ lvidpoms
          lvidpom := 13
        endif
      endif
    endif
  endif
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    aadd(a_fusl,mohu->(recno()))
    skip
  enddo
  a_otkaz := {}
  arr_nazn := {}
  if eq_any(human->ishod,101,102) // ���-�� ��⥩-���
    read_arr_DDS(human->kod)
  elseif eq_any(human->ishod,301,302) // ���ᬮ��� ��ᮢ��襭����⭨�
    arr_usl_otkaz := {}
    read_arr_PN(human->kod)
    if valtype(arr_usl_otkaz) == "A"
      for j := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[j]
        if valtype(ar) == "A" .and. len(ar) > 9 .and. valtype(ar[5]) == "C" .and. ;
                                                      valtype(ar[10]) == "C" .and. ar[10] $ "io"
          lshifr := alltrim(ar[5])
          ldate := human->N_DATA // ���
          if valtype(ar[9]) == "D"
            ldate := ar[9]
          endif
          if ar[10] == "i" // ��᫥�������
            if (i := ascan(np_arr_issled, {|x| valtype(x[1]) == "C" .and. x[1] == lshifr})) > 0
              aadd(a_otkaz,{lshifr,;
                            ar[6],; // �������
                            ldate,; // ���
                            correct_profil(ar[4]),; // ��䨫�
                            ar[2],; // ᯥ樠�쭮���
                            0,;     // 業�
                            1})     // 1-�⪠�,2-�������������
            endif
          elseif (i := ascan(np_arr_osmotr, {|x| valtype(x[1]) == "C" .and. x[1] == lshifr})) > 0 // �ᬮ���
            if (i := ascan(np_arr_osmotr_KDP2, {|x| x[1] == lshifr })) > 0
              lshifr := np_arr_osmotr_KDP2[i,3]  // ������ ��祡���� ��� �� 2.3.*
            endif
            aadd(a_otkaz,{lshifr,;
                          ar[6],; // �������
                          ldate,; // ���
                          correct_profil(ar[4]),; // ��䨫�
                          ar[2],; // ᯥ樠�쭮���
                          0,;     // 業�
                          1})     // 1-�⪠�,2-�������������
          endif
        endif
      next j
    endif
  elseif between(human->ishod,201,205) // ���-�� I �⠯ ��� ��䨫��⨪�
    is_disp_DVN := .t.
    arr_usl_otkaz := {}
    for i := 1 to 5
      sk := lstr(i)
      pole_diag := "mdiag"+sk
      pole_1dispans := "m1dispans"+sk
      pole_dn_dispans := "mdndispans"+sk
      &pole_diag := space(6)
      &pole_1dispans := 0
      &pole_dn_dispans := ctod("")
    next
    read_arr_DVN(human->kod)
    if valtype(arr_usl_otkaz) == "A" .and. eq_any(human->ishod,201,203) // �� II �⠯
      for j := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[j]
        if valtype(ar) == "A" .and. len(ar) >= 10 .and. valtype(ar[5]) == "C"
          lshifr := alltrim(ar[5])
          if (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]==lshifr})) > 0
            if valtype(ar[10]) == "N" .and. between(ar[10],1,2)
              aadd(a_otkaz,{lshifr,;
                            ar[6],; // �������
                            human->N_DATA,; // ���
                            correct_profil(ar[4]),; // ��䨫�
                            ar[2],; // ᯥ樠�쭮���
                            ar[8],; // 業�
                            ar[10]}) // 1-�⪠�,2-�������������
            endif
          endif
        endif
      next j
    endif
  elseif between(human->ishod,401,402) // 㣫㡫����� ��ᯠ��ਧ��� ��᫥ COVID
    is_disp_DVN_COVID := .t.
    arr_usl_otkaz := {}
    for i := 1 to 5
      sk := lstr(i)
      pole_diag := "mdiag"+sk
      pole_1dispans := "m1dispans"+sk
      pole_dn_dispans := "mdndispans"+sk
      &pole_diag := space(6)
      &pole_1dispans := 0
      &pole_dn_dispans := ctod("")
    next
    read_arr_DVN_COVID(human->kod)
    if valtype(arr_usl_otkaz) == "A"
      for j := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[j]
        if valtype(ar) == "A" .and. len(ar) >= 10 .and. valtype(ar[5]) == "C"
          lshifr := alltrim(ar[5])
          if (i := ascan(uslugiEtap_DVN_COVID(iif(human->ishod == 401, 1, 2)), {|x| valtype(x[2])=="C" .and. x[2]==lshifr})) > 0
          else   // �����뢠�� ⮫쪮 䥤�ࠫ�� ��㣨
            if valtype(ar[10]) == "N" .and. between(ar[10],1,2)
              aadd(a_otkaz,{lshifr,;
                            ar[6],; // �������
                            human->N_DATA,; // ���
                            correct_profil(ar[4]),; // ��䨫�
                            ar[2],; // ᯥ樠�쭮���
                            ar[8],; // 業�
                            ar[10]}) // 1-�⪠�,2-�������������
            endif
          endif
        endif
      next j
    endif
  endif
  if m1dopo_na > 0
    for i := 1 to 4
      if isbit(m1dopo_na,i)
        if mtab_v_dopo_na != 0
          if P2TABN->(dbSeek(str(mtab_v_dopo_na,5)))
            aadd(arr_nazn,{3, i, P2TABN->snils, lstr(ret_prvs_V015toV021(P2TABN->PRVS_NEW))}) // ⥯��� ������ �����祭�� � �⤥�쭮� PRESCRIPTIONS
          else
            aadd(arr_nazn,{3, i, '', ''}) // ⥯��� ������ �����祭�� � �⤥�쭮� PRESCRIPTIONS
          endif
        else
          aadd(arr_nazn,{3, i, '', ''}) // ⥯��� ������ �����祭�� � �⤥�쭮� PRESCRIPTIONS
        endif
      endif
    next
  endif
  if between(m1napr_v_mo,1,2) .and. !empty(arr_mo_spec) // {{"-- ��� --",0},{"� ���� ��",1},{"� ���� ��",2}}, ;
    for i := 1 to len(arr_mo_spec) // ⥯��� ������ ᯥ樠�쭮��� � �⤥�쭮� PRESCRIPTIONS
      if mtab_v_mo != 0
        if P2TABN->(dbSeek(str(mtab_v_mo,5)))
          aadd(arr_nazn,{m1napr_v_mo, put_prvs_to_reestr(-arr_mo_spec[i],_NYEAR), P2TABN->snils, lstr(ret_prvs_V015toV021(P2TABN->PRVS_NEW))})  // "-", �.�. ᯥ�-�� �뫠 � ����஢�� V015
        else
          aadd(arr_nazn,{m1napr_v_mo, put_prvs_to_reestr(-arr_mo_spec[i],_NYEAR), '', ''}) // "-", �.�. ᯥ�-�� �뫠 � ����஢�� V015
        endif
      else
        aadd(arr_nazn,{m1napr_v_mo, put_prvs_to_reestr(-arr_mo_spec[i],_NYEAR), '', ''}) // "-", �.�. ᯥ�-�� �뫠 � ����஢�� V015
      endif
    next
  endif
  if between(m1napr_stac,1,2) .and. m1profil_stac > 0 // {{"--- ��� ---",0},{"� ��樮���",1},{"� ��. ���.",2}}, ;
    if mtab_v_stac != 0
      if P2TABN->(dbSeek(str(mtab_v_stac,5)))
        aadd(arr_nazn,{iif(m1napr_stac==1,5,4), m1profil_stac, P2TABN->snils, lstr(ret_prvs_V015toV021(P2TABN->PRVS_NEW))})
      else
        aadd(arr_nazn,{iif(m1napr_stac==1,5,4), m1profil_stac, '', ''})
      endif
    else
      aadd(arr_nazn,{iif(m1napr_stac==1,5,4), m1profil_stac, '', ''})
    endif
  endif
  if m1napr_reab == 1 .and. m1profil_kojki > 0
    if mtab_v_reab != 0
      if P2TABN->(dbSeek(str(mtab_v_reab,5)))
        aadd(arr_nazn,{6, m1profil_kojki, P2TABN->snils, lstr(ret_prvs_V015toV021(P2TABN->PRVS_NEW))})
      else
        aadd(arr_nazn,{6, m1profil_kojki, '', ''})
      endif
    else
      aadd(arr_nazn,{6, m1profil_kojki, '', ''})
    endif
  endif
  cSMOname := ""
  if alltrim(human_->smo) == '34'
    cSMOname := ret_inogSMO_name(2)
  endif
  mdiagnoz := diag_for_xml(,.t.,,,.t.)
  if p_tip_reestr == 1
    if glob_mo[_MO_IS_UCH] .and. ;                    // ��� �� ����� �ਪ९�񭭮� ��ᥫ����
       human_->USL_OK == 3 .and. ;                    // �����������
       kart2->MO_PR == glob_MO[_MO_KOD_TFOMS] .and. ; // �ਪ९�� � ��襬� ��
       between(kart_->INVALID,1,4)                    // �������
      select INV
      find (str(human->kod_k,7))
      if found() .and. !emptyany(inv->DATE_INV,inv->PRICH_INV)
        // ��� ��砫� ��祭�� ���⮨� �� ���� ��ࢨ筮�� ��⠭������� ����������� �� ����� 祬 �� ���
        fl_DISABILITY := (inv->DATE_INV < human->n_data .and. human->n_data <= addmonth(inv->DATE_INV,12))
      endif
    endif
  else
    if human->OBRASHEN == '1' .and. ascan(mdiagnoz, {|x| padr(x,5) == "Z03.1" }) == 0
      aadd(mdiagnoz,"Z03.1")
    endif
    afill(adiag_talon,0)
    for i := 1 to 16
      adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
    next
  endif
  mdiagnoz3 := {}
  if !empty(human_2->OSL1)
    aadd(mdiagnoz3,human_2->OSL1)
  endif
  if !empty(human_2->OSL2)
    aadd(mdiagnoz3,human_2->OSL2)
  endif
  if !empty(human_2->OSL3)
    aadd(mdiagnoz3,human_2->OSL3)
  endif
  return NIL
  
***** 05.08.21 ������ ���祭�� ᯥ樠�쭮�� �� ����஢�� �ࠢ�筨�� V015 � ����஢�� �ࠢ�筨�� V021
Function ret_prvs_V015toV021(lkod)
  Local i, new_kod := 76 // �� 㬮�砭�� - �࠯��

  if (i := ascan(glob_arr_V015_V021, {|x| x[1] == lkod })) > 0
    new_kod := glob_arr_V015_V021[i,2]
  endif
  return new_kod
  
***** 19.01.20
Function create1reestr19(_recno,_nyear,_nmonth)
  Local buf := savescreen(), s, i, j, pole
  Private mpz[100], oldpz[100], atip[100], p_array_PZ := iif(_nyear > 2019, glob_array_PZ_20, glob_array_PZ_19)
  for j := 0 to 99
    pole := "tmp->PZ"+lstr(j)
    mpz[j+1] := oldpz[j+1] := &pole
    atip[j+1] := "-"
    if (i := ascan(p_array_PZ, {|x| x[1] == j })) > 0
      atip[j+1] := p_array_PZ[i,4]
    endif
  next
  Private pkol := tmp->kol, psumma := tmp->summa, pnyear := _nyear
  Private old_kol := pkol, old_summa := psumma, p_blk := {|mkol,msum| f_blk_create1reestr19(_nyear) }
  close databases
  R_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
  set order to 2
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_
  use (cur_dir+"tmpb") new alias TMP
  set relation to kod_human into HUMAN
  index on upper(human->fio)+dtos(tmp->k_data) to (cur_dir+"tmpb") for kod_tmp == _recno
  go top
  eval(p_blk)
  if Alpha_Browse(3,0,maxrow()-4,79,"f1create1reestr19",color0,;
                  "���⠢����� ॥��� ��砥� �� "+mm_month[_nmonth]+str(_nyear,5)+" ����","BG+/GR",;
                  .t.,.t.,,,"f2create1reestr19",,;
                  {'�','�','�',"N/BG,W+/N,B/BG,W+/B",,300} )
    if pkol > 0 .and. (j := f_alert({"",;
                    "����� ��ࠧ�� ���஢��� ॥���, ��ࠢ�塞� � �����",;
                    ""},;
                   {" �� ~��� ��樥�� "," �� ~�뢠��� �⮨���� "},;
                   1,"W/RB","G+/RB",maxrow()-6,,"BG+/RB,W+/R,W+/RB,GR+/R" )) > 0
      f_message({"���⥬��� ���: "+date_month(sys_date,.t.),;
                 "���頥� ��� ��������, ��",;
                 "॥��� �㤥� ᮧ��� � �⮩ ��⮩.",;
                 "",;
                 "�������� �� �㤥� ����������!",;
                 "",;
                 "����஢�� ॥���: "+{"�� ��� ��樥��","�� �뢠��� �⮨���� ��祭��"}[j]},,;
                 "GR+/R","W+/R")
      if f_Esc_Enter("��⠢����� ॥���")
        restscreen(buf)
        create2reestr19(_recno,_nyear,_nmonth,j)
      endif
    endif
  endif
  close databases
  restscreen(buf)
  return NIL
  
***** 21.05.17
Function f_blk_create1reestr19(_nyear)
  Local i, s, ta[2], sh := maxcol()+1
  s := "���砥� - "+expand_value(pkol)+" �� �㬬� "+expand_value(psumma,2)+" ��."
  @ 0,0 say padc(s,sh) color color1
  s := ""
  for i := 1 to len(mpz)
    if !empty(mpz[i])
      s += alltrim(str_0(mpz[i],9,2))+" "+atip[i]+", "
    endif
  next
  if !empty(s)
    s := "(�/�: "+substr(s,1,len(s)-2)+")"
  endif
  perenos(ta,s,sh)
  for i := 1 to 2
    @ i,0 say padc(alltrim(ta[i]),sh) color color1
  next
  return NIL
  
***** 19.01.20
Static Function f_p_z19(_pzkol,_pz,k)
  Local s, s2, i
  s2 := alltrim(str_0(_pzkol,9,2))
  s := atip[_PZ+1]
  if (i := ascan(p_array_PZ, {|x| x[1] == _PZ })) > 0 .and. !empty(p_array_PZ[i,5])
    s2 += p_array_PZ[i,5]
  endif
  return iif(k == 1, s, s2)
  
***** 06.02.19
Function f1create1reestr19(oBrow)
  Local oColumn, tmp_color, blk_color := {|| if(tmp->plus, {1,2}, {3,4}) }, n := 32
  oColumn := TBColumnNew(" ", {|| if(tmp->plus,""," ") })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(center("�.�.�. ���쭮��",n), {|| iif(tmp->ishod==89,padr(human->fio,n-4)+" 2�",padr(human->fio,n)) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("����-�����", {|| padc(f_p_z19(tmp->pzkol,tmp->pz,1),10) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("���-��", {|| padc(f_p_z19(tmp->pzkol,tmp->pz,2),6) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("���-; ��", {|| left(dtoc(tmp->n_data),5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("����砭.;��祭��", {|| date_8(tmp->k_data) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(" �⮨�����; ��祭��", {|| put_kopE(tmp->cena_1,10) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  tmp_color := setcolor("N/BG")
  @ maxrow()-3,0 say padr(" <Esc> - ��室     <Enter> - ���⢥ত���� ��⠢����� ॥���",80)
  @ maxrow()-2,0 say padr(" <Ins> - �⬥��� ������ ��樥�� ��� ���� �⬥�� � ������ ��樥��",80)
  @ maxrow()-1,0 say padr(" <+> - �⬥��� ��� ��樥�⮢ (��� �� ������ ���� �����-������) ",80)
  @ maxrow()-0,0 say padr(" <-> - ���� � ��� �⬥⪨ (���� �� �������� � ॥���)",80)
  mark_keys({"<Esc>","<Enter>","<Ins>","<+>","<->","<F9>"},"R/BG")
  setcolor(tmp_color)
  return NIL
  
***** 19.01.20
Function f2create1reestr19(nKey,oBrow)
  Local buf, rec, k := -1, s, i, j, mas_pmt := {}, arr, r1, r2
  do case
    case nkey == K_INS
      replace tmp->plus with !tmp->plus
      j := tmp->pz + 1
      i := ascan(p_array_PZ, {|x| x[1] == tmp->PZ })
      if tmp->plus
        psumma += tmp->cena_1 ; pkol++
        if i > 0 .and. !empty(p_array_PZ[i,5])
          mpz[j] ++
        else
          mpz[j] += tmp->PZKOL
        endif
      else
        psumma -= tmp->cena_1 ; pkol--
        if i > 0 .and. !empty(p_array_PZ[i,5])
          mpz[j] --
        else
          mpz[j] -= tmp->PZKOL
        endif
      endif
      eval(p_blk)
      k := 0
      keyboard chr(K_TAB)
    case nkey == 43  // +
      arr := {}
      aadd(mas_pmt, "�⬥��� ��� ��樥�⮢") ; aadd(arr,-1)
      if !empty(oldpz[1])
        aadd(mas_pmt, "�⬥��� ����।����� ��樥�⮢") ; aadd(arr,0)
      endif
      for j := 2 to len(oldpz)
        if !empty(oldpz[j]) .and. (i := ascan(p_array_PZ, {|x| x[1] == j-1 })) > 0
          aadd(mas_pmt, '�⬥��� "'+p_array_PZ[i,3]+'"') ; aadd(arr,j-1)
        endif
      next
      r1 := 12
      r2 := r1 + len(mas_pmt) + 1
      if r2 > maxrow()-2
        r2 := maxrow()-2
        r1 := r2 - len(mas_pmt) - 1
        if r1 < 2
          r1 := 2
        endif
      endif
      if (j := popup_SCR(r1,12,r2,67,mas_pmt,1,color5,.t.)) > 0
        j := arr[j]
        rec := recno()
        buf := save_maxrow()
        mywait()
        if j == -1
          tmp->(dbeval({|| tmp->plus := .t. }))
          psumma := old_summa ; pkol := old_kol
          aeval(mpz, {|x,i| mpz[i] := oldpz[i] })
        else
          psumma := pkol := 0
          afill(mpz,0)
          mpz[j+1] := oldpz[j+1]
          go top
          do while !eof()
            if tmp->pz == j
              tmp->plus := .t.
              psumma += tmp->cena_1
              pkol++
            else
              tmp->plus := .f.
            endif
            skip
          enddo
        endif
        goto (rec)
        rest_box(buf)
        eval(p_blk)
        k := 0
      endif
    case nkey == 45  //  -
      rec := recno()
      buf := save_maxrow()
      mywait()
      tmp->(dbeval({|| tmp->plus := .f. }))
      goto (rec)
      rest_box(buf)
      psumma := pkol := 0
      afill(mpz,0)
      eval(p_blk)
      k := 0
  endcase
  return k
  