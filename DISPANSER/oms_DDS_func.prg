#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 19.03.19 ������ ��� ��㣨 �����祭���� ���� ��� ��ᯠ��ਧ�樨 ��⥩-���
Function ret_shifr_zs_DDS(tip_lu)
  Local s := ""
  if m1mobilbr == 1 // ��ᯠ��ਧ��� �஢����� �����쭮� �ਣ����
    if m1lis > 0 // ��� ����⮫����᪨� ���-��
      if mvozrast < 1
        s := iif(tip_lu==TIP_LU_DDS, "70.5.21", "70.6.19")
      elseif mvozrast < 3
        s := iif(tip_lu==TIP_LU_DDS, "70.5.22", "70.6.20")
      elseif mvozrast < 5
        s := iif(tip_lu==TIP_LU_DDS, "70.5.23", "70.6.21")
      elseif mvozrast < 7
        s := iif(tip_lu==TIP_LU_DDS, "70.5.24", "70.6.22")
      elseif mvozrast < 15
        s := iif(tip_lu==TIP_LU_DDS, "70.5.25", "70.6.23")
      else
        s := iif(tip_lu==TIP_LU_DDS, "70.5.26", "70.6.24")
      endif
    else  // ����⮫����᪨� ���-�� �஢������ � ���
      if mvozrast < 1
        s := iif(tip_lu==TIP_LU_DDS, "70.5.9", "70.6.7")
      elseif mvozrast < 3
        s := iif(tip_lu==TIP_LU_DDS, "70.5.10", "70.6.8")
      elseif mvozrast < 5
        s := iif(tip_lu==TIP_LU_DDS, "70.5.11", "70.6.9")
      elseif mvozrast < 7
        s := iif(tip_lu==TIP_LU_DDS, "70.5.12", "70.6.10")
      elseif mvozrast < 15
        s := iif(tip_lu==TIP_LU_DDS, "70.5.13", "70.6.11")
      else
        s := iif(tip_lu==TIP_LU_DDS, "70.5.14", "70.6.12")
      endif
    endif
  else // ���-�� �஢����� � �� (�� �����쭮� �ਣ����)
    if m1lis > 0 // ��� ����⮫����᪨� ���-��
      if mvozrast < 1
        s := iif(tip_lu==TIP_LU_DDS, "70.5.15", "70.6.13")
      elseif mvozrast < 3
        s := iif(tip_lu==TIP_LU_DDS, "70.5.16", "70.6.14")
      elseif mvozrast < 5
        s := iif(tip_lu==TIP_LU_DDS, "70.5.17", "70.6.15")
      elseif mvozrast < 7
        s := iif(tip_lu==TIP_LU_DDS, "70.5.18", "70.6.16")
      elseif mvozrast < 15
        s := iif(tip_lu==TIP_LU_DDS, "70.5.19", "70.6.17")
      else
        s := iif(tip_lu==TIP_LU_DDS, "70.5.20", "70.6.18")
      endif
    else  // ����⮫����᪨� ���-�� �஢������ � ���
      if mvozrast < 1
        s := iif(tip_lu==TIP_LU_DDS, "70.5.3", "70.6.1")
      elseif mvozrast < 3
        s := iif(tip_lu==TIP_LU_DDS, "70.5.4", "70.6.2")
      elseif mvozrast < 5
        s := iif(tip_lu==TIP_LU_DDS, "70.5.5", "70.6.3")
      elseif mvozrast < 7
        s := iif(tip_lu==TIP_LU_DDS, "70.5.6", "70.6.4")
      elseif mvozrast < 15
        s := iif(tip_lu==TIP_LU_DDS, "70.5.7", "70.6.5")
      else
        s := iif(tip_lu==TIP_LU_DDS, "70.5.8", "70.6.6")
      endif
    endif
  endif
  return s

***** 05.09.21
Function save_arr_DDS(lkod)
  Local arr := {}, k, ta
  local aliasIsUse := aliasIsAlreadyUse('TPERS')
  local oldSelect

  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server()+"mo_pers",dir_server()+"mo_pers","TPERS") 
  endif

  Private mvar
  if type("mfio") == "C"
    aadd(arr,{"mfio",alltrim(mfio)})
  endif
  if type("mdate_r") == "D"
    aadd(arr,{"mdate_r",mdate_r})
  endif
  aadd(arr,{"0",m1mobilbr})   // "N",�����쭠� �ਣ���
  aadd(arr,{"1",m1stacionar}) // "N",��� ��樮���
  aadd(arr,{"2.3",m1kateg_uch}) // "N",��⥣��� ��� ॡ����: 0-ॡ����-���; 1-ॡ����, ��⠢訩�� ��� ����祭�� த�⥫��; 2-ॡ����, ��室�騩�� � ��㤭�� ��������� ���樨, 3-��� ��⥣�ਨ
  aadd(arr,{"2.4",m1gde_nahod}) // "N",�� ������ �஢������ ��ᯠ��ਧ�樨 ��室���� 0-� ��樮��୮� ��०�����, 1-��� ������, 2-�����⥫��⢮�, 3-��।�� � �ਥ���� ᥬ��, 4-��।�� � ���஭���� ᥬ��, 5-��뭮���� (㤮�७�), 6-��㣮�
  aadd(arr,{"4",mdate_post}) // "D",��� ����㯫���� � ��樮��୮� ��०�����
  if m1prich_vyb > 0
    aadd(arr,{"5",m1prich_vyb}) // "N",0-���. ��稭� ����� �� ��樮��୮�� ��०�����: 1-�����, 2-�����⥫��⢮, 3-��뭮������ (㤮�७��), 4-��।�� � �ਥ���� ᥬ��, 5-��।�� � ���஭���� ᥬ��, 6-��� � ��㣮� ��樮��୮� ��०�����, 7-��� �� �������, 8-ᬥ���, 9-��㣮�
    aadd(arr,{"5.1",mDATE_VYB}) // "D",��� �����
  endif
  if !empty(mPRICH_OTS)
    aadd(arr,{"6",alltrim(mPRICH_OTS)}) // "C70",��稭� ������⢨� �� ������ �஢������ ��ᯠ��ਧ�樨
  endif
  aadd(arr,{"8",m1MO_PR}) // "C6",��� �� �ਪ९�����
  aadd(arr,{"12.1",mWEIGHT})  // "N3",��� � ��
  aadd(arr,{"12.2",mHEIGHT})  // "N3",��� � �
  aadd(arr,{"12.3",mPER_HEAD})  // "N3",���㦭���� ������ � �
  aadd(arr,{"12.4",m1FIZ_RAZV})  // "N",䨧��᪮� ࠧ��⨥ 0-��ଠ�쭮�, � �⪫�����ﬨ: 1-����� ����� ⥫�, 2-����⮪ ����� ⥫�, 3-������ ���, 4-��᮪�� ���
  aadd(arr,{"12.4.1",m1FIZ_RAZV1})  // "N",䨧��᪮� ࠧ��⨥ 0-��ଠ�쭮�, � �⪫�����ﬨ: 1-����� ����� ⥫�, 2-����⮪ ����� ⥫�, 3-������ ���, 4-��᮪�� ���
  aadd(arr,{"12.4.2",m1FIZ_RAZV2})  // "N",䨧��᪮� ࠧ��⨥ 0-��ଠ�쭮�, � �⪫�����ﬨ: 1-����� ����� ⥫�, 2-����⮪ ����� ⥫�, 3-������ ���, 4-��᮪�� ���
  if mvozrast < 5
    aadd(arr,{"13.1.1",m1psih11})  // "N1",�������⥫쭠� �㭪�� (������ ࠧ����)
    aadd(arr,{"13.1.2",m1psih12})  // "N1",���ୠ� �㭪�� (������ ࠧ����)
    aadd(arr,{"13.1.3",m1psih13})  // "N1",�樮���쭠� � �樠�쭠� (���⠪� � ���㦠�騬 ��஬) �㭪樨 (������ ࠧ����)
    aadd(arr,{"13.1.4",m1psih14})  // "N1",�।�祢�� � �祢�� ࠧ��⨥ (������ ࠧ����)
  else
    aadd(arr,{"13.2.1",m1psih21})  // "N1",��宬��ୠ� ���: (��ଠ, �⪫������)
    aadd(arr,{"13.2.2",m1psih22})  // "N1",��⥫����: (��ଠ, �⪫������)
    aadd(arr,{"13.2.3",m1psih23})  // "N1",���樮���쭮-�����⨢��� ���: (��ଠ, �⪫������)
  endif
  if mpol == "�"
    aadd(arr,{"14.1.P"  ,m141p})     // "N1",������� ��㫠 ����稪�
    aadd(arr,{"14.1.Ax" ,m141ax})   // "N1",������� ��㫠 ����稪�
    aadd(arr,{"14.1.Fa" ,m141fa})   // "N1",������� ��㫠 ����稪�
  else
    aadd(arr,{"14.2.P"  ,m142p})     // "N1",������� ��㫠 ����窨
    aadd(arr,{"14.2.Ax" ,m142ax})   // "N1",������� ��㫠 ����窨
    aadd(arr,{"14.2.Ma" ,m142ma})   // "N1",������� ��㫠 ����窨
    aadd(arr,{"14.2.Me" ,m142me})   // "N1",������� ��㫠 ����窨
    aadd(arr,{"14.2.Me1",m142me1}) // "N2",������� ��㫠 ����窨 - menarhe (���)
    aadd(arr,{"14.2.Me2",m142me2}) // "N2",������� ��㫠 ����窨 - menarhe (����楢)
    aadd(arr,{"14.2.Me3",m1142me3}) // "N1",������� ��㫠 ����窨 - menses (�ࠪ���⨪�): ॣ����, ��ॣ����, ������, 㬥७��, �㤭�, ���������� � �������������
    aadd(arr,{"14.2.Me4",m1142me4}) // "N1",������� ��㫠 ����窨 - menses (�ࠪ���⨪�): ॣ����, ��ॣ����, ������, 㬥७��, �㤭�, ���������� � �������������
    aadd(arr,{"14.2.Me5",m1142me5}) // "N1",������� ��㫠 ����窨 - menses (�ࠪ���⨪�): ॣ����, ��ॣ����, ������, 㬥७��, �㤭�, ���������� � �������������
  endif
  aadd(arr,{"15.1",m1diag_15_1}) // "C6",����ﭨ� ���஢�� �� �஢������ ��ᯠ��ਧ�樨-�ࠪ��᪨ ���஢
  if m1diag_15_1 == 0 .and. !empty(mdiag_15_1_1)
    ta := {mdiag_15_1_1}
    for k := 2 to 14
      mvar := "m1diag_15_1_"+lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"15.2",ta})
  endif
  if m1diag_15_1 == 0 .and. !empty(mdiag_15_2_1)
    ta := {mdiag_15_2_1}
    for k := 2 to 14
      mvar := "m1diag_15_2_"+lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"15.3",ta})
  endif
  if m1diag_15_1 == 0 .and. !empty(mdiag_15_3_1)
    ta := {mdiag_15_3_1}
    for k := 2 to 14
      mvar := "m1diag_15_3_"+lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"15.4",ta})
  endif
  if m1diag_15_1 == 0 .and. !empty(mdiag_15_4_1)
    ta := {mdiag_15_4_1}
    for k := 2 to 14
      mvar := "m1diag_15_4_"+lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"15.5",ta})
  endif
  if m1diag_15_1 == 0 .and. !empty(mdiag_15_5_1)
    ta := {mdiag_15_5_1}
    for k := 2 to 14
      mvar := "m1diag_15_5_"+lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"15.6",ta})
  endif
  aadd(arr,{"15.9",mGRUPPA_DO}) // "N1",��㯯� ���஢�� �� ���-��
  aadd(arr,{"16.1",m1diag_16_1}) // "C6",����ﭨ� ���஢�� �� १���⠬ �஢������ ��ᯠ��ਧ�樨 (�ࠪ��᪨ ���஢)
  if m1diag_16_1 == 0 .and. !empty(mdiag_16_1_1)
    ta := {mdiag_16_1_1}
    for k := 2 to 16
      mvar := "m1diag_16_1_"+lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"16.2",ta})
  endif
  if m1diag_16_1 == 0 .and. !empty(mdiag_16_2_1)
    ta := {mdiag_16_2_1}
    for k := 2 to 16
      mvar := "m1diag_16_2_"+lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"16.3",ta})
  endif
  if m1diag_16_1 == 0 .and. !empty(mdiag_16_3_1)
    ta := {mdiag_16_3_1}
    for k := 2 to 16
      mvar := "m1diag_16_3_"+lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"16.4",ta})
  endif
  if m1diag_16_1 == 0 .and. !empty(mdiag_16_4_1)
    ta := {mdiag_16_4_1}
    for k := 2 to 16
      mvar := "m1diag_16_4_"+lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"16.5",ta})
  endif
  if m1diag_16_1 == 0 .and. !empty(mdiag_16_5_1)
    ta := {mdiag_16_5_1}
    for k := 2 to 16
      mvar := "m1diag_16_5_"+lstr(k)
      aadd(ta,&mvar)
    next
    aadd(arr,{"16.6",ta})
  endif
  if m1invalid1 == 1
    ta := {m1invalid1,m1invalid2,minvalid3,minvalid4,;
           m1invalid5,m1invalid6,minvalid7,m1invalid8}
    aadd(arr,{"16.7",ta})   // ���ᨢ �� 8
  endif
  aadd(arr,{"16.8",mGRUPPA})    // "N1",��㯯� ���஢�� ��᫥ ���-��
  if m1privivki1 > 0
    ta := {m1privivki1,m1privivki2,mprivivki3}
    aadd(arr,{"16.9",ta})  // ���ᨢ �� 4,�஢������ ��䨫����᪨� �ਢ����
  endif
  if !empty(mrek_form)
    aadd(arr,{"16.10",alltrim(mrek_form)}) // ���������樨 �� �ନ஢���� ���஢��� ��ࠧ� �����, ०��� ���, ��⠭��, 䨧��᪮�� ࠧ����, ���㭮��䨫��⨪�, ������ 䨧��᪮� �����ன
  endif
  if !empty(mrek_disp)
    aadd(arr,{"16.11",alltrim(mrek_disp)}) // ���������樨 �� ��ᯠ��୮�� �������, ��祭��, ����樭᪮� ॠ�����樨 � ᠭ��୮-����⭮�� ��祭�� � 㪠������ �������� (��� ���), ���� ����樭᪮� �࣠����樨 � ᯥ樠�쭮�� (��������) ���
  endif
  // 18.१����� �஢������ ��᫥�������
  for i := 1 to count_dds_arr_iss
    mvar := "MREZi"+lstr(i)
    if !empty(&mvar)
      aadd(arr,{"18."+lstr(i),alltrim(&mvar)})
    endif
  next
  if mk_data >= 0d20210801
    if mtab_v_dopo_na != 0
      if TPERS->(dbSeek(str(mtab_v_dopo_na,5)))
        aadd(arr,{"47",{m1dopo_na, TPERS->kod}})
      else
        aadd(arr,{"47",{m1dopo_na, 0}})
      endif
    else
      aadd(arr,{"47",{m1dopo_na, 0}})
    endif
  else
    aadd(arr,{"47",m1dopo_na})
  endif
  if mk_data >= 0d20210801
    if type("m1napr_v_mo") == "N"
      if mtab_v_mo != 0
        if TPERS->(dbSeek(str(mtab_v_mo,5)))
          aadd(arr,{"52",{m1napr_v_mo, TPERS->kod}})
        else
          aadd(arr,{"52",{m1napr_v_mo, 0}})
        endif
      else
        aadd(arr,{"52",{m1napr_v_mo, 0}})
      endif
    endif
  else
    if type("m1napr_v_mo") == "N"
      aadd(arr,{"52",m1napr_v_mo})
    endif
  endif
  if type("arr_mo_spec") == "A" .and. !empty(arr_mo_spec)
    aadd(arr,{"53",arr_mo_spec}) // ���ᨢ
  endif
  if mk_data >= 0d20210801
    if type("m1napr_stac") == "N"
      if mtab_v_stac != 0
        if TPERS->(dbSeek(str(mtab_v_stac,5)))
          aadd(arr,{"54",{m1napr_stac, TPERS->kod}})
        else
          aadd(arr,{"54",{m1napr_stac, 0}})
        endif
      else
        aadd(arr,{"54",{m1napr_stac, 0}})
      endif
    endif
  else
    if type("m1napr_stac") == "N"
      aadd(arr,{"54",m1napr_stac})
    endif
  endif
  if type("m1profil_stac") == "N"
    aadd(arr,{"55",m1profil_stac})
  endif
  if mk_data >= 0d20210801
    if type("m1napr_reab") == "N"
      if mtab_v_reab != 0
        if TPERS->(dbSeek(str(mtab_v_reab,5)))
          aadd(arr,{"56",{m1napr_reab, TPERS->kod}})
        else
          aadd(arr,{"56",{m1napr_reab, 0}})
        endif
      else
        aadd(arr,{"56",{m1napr_reab, 0}})
      endif
    endif
  else
    if type("m1napr_reab") == "N"
      aadd(arr,{"56",m1napr_reab})
    endif
  endif
  if type("m1profil_kojki") == "N"
    aadd(arr,{"57",m1profil_kojki})
  endif

  if ! aliasIsUse
    TPERS->(dbCloseArea())
    Select(oldSelect)
  endif

  save_arr_DISPANS(lkod,arr)
  return NIL
  
***** 05.09.21
Function read_arr_DDS(lkod)
  Local arr, i, k
  local aliasIsUse := aliasIsAlreadyUse('TPERS')
  local oldSelect
  Private mvar

  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server()+"mo_pers",,"TPERS") 
  endif

  arr := read_arr_DISPANS(lkod)
  for i := 1 to len(arr)
    if valtype(arr[i]) == "A" .and. valtype(arr[i,1]) == "C"
      do case
        case arr[i,1] == "0" .and. valtype(arr[i,2]) == "N"
          m1mobilbr := arr[i,2]
        case arr[i,1] == "1"
          //m1stacionar := arr[i,2]
        case arr[i,1] == "2.3" .and. valtype(arr[i,2]) == "N"
          m1kateg_uch := arr[i,2]
        case arr[i,1] == "2.4" .and. valtype(arr[i,2]) == "N"
          m1gde_nahod := arr[i,2]
        case arr[i,1] == "4" .and. valtype(arr[i,2]) == "D"
          mdate_post := arr[i,2]
        case arr[i,1] == "5" .and. valtype(arr[i,2]) == "N"
          m1prich_vyb := arr[i,2]
        case arr[i,1] == "5.1" .and. valtype(arr[i,2]) == "D"
          mDATE_VYB := arr[i,2]
        case arr[i,1] == "6" .and. valtype(arr[i,2]) == "C"
          mPRICH_OTS := padr(arr[i,2],70)
        case arr[i,1] == "8" .and. valtype(arr[i,2]) == "C"
          m1MO_PR := arr[i,2]
        case arr[i,1] == "12.1" .and. valtype(arr[i,2]) == "N"
          mWEIGHT := arr[i,2]
        case arr[i,1] == "12.2" .and. valtype(arr[i,2]) == "N"
          mHEIGHT := arr[i,2]
        case arr[i,1] == "12.3" .and. valtype(arr[i,2]) == "N"
          mPER_HEAD := arr[i,2]
        case arr[i,1] == "12.4" .and. valtype(arr[i,2]) == "N"
          m1FIZ_RAZV := arr[i,2]
        case arr[i,1] == "12.4.1" .and. valtype(arr[i,2]) == "N"
          m1FIZ_RAZV1 := arr[i,2]
        case arr[i,1] == "12.4.2" .and. valtype(arr[i,2]) == "N"
          m1FIZ_RAZV2 := arr[i,2]
        case arr[i,1] == "13.1.1" .and. valtype(arr[i,2]) == "N"
          m1psih11 := arr[i,2]
        case arr[i,1] == "13.1.2" .and. valtype(arr[i,2]) == "N"
          m1psih12 := arr[i,2]
        case arr[i,1] == "13.1.3" .and. valtype(arr[i,2]) == "N"
          m1psih13 := arr[i,2]
        case arr[i,1] == "13.1.4" .and. valtype(arr[i,2]) == "N"
          m1psih14 := arr[i,2]
        case arr[i,1] == "13.2.1" .and. valtype(arr[i,2]) == "N"
          m1psih21 := arr[i,2]
        case arr[i,1] == "13.2.2" .and. valtype(arr[i,2]) == "N"
          m1psih22 := arr[i,2]
        case arr[i,1] == "13.2.3" .and. valtype(arr[i,2]) == "N"
          m1psih23 := arr[i,2]
        case arr[i,1] == "14.1.P" .and. valtype(arr[i,2]) == "N"
          m141p := arr[i,2]
        case arr[i,1] == "14.1.Ax" .and. valtype(arr[i,2]) == "N"
          m141ax := arr[i,2]
        case arr[i,1] == "14.1.Fa" .and. valtype(arr[i,2]) == "N"
          m141fa := arr[i,2]
        case arr[i,1] == "14.2.P" .and. valtype(arr[i,2]) == "N"
          m142p := arr[i,2]
        case arr[i,1] == "14.2.Ax" .and. valtype(arr[i,2]) == "N"
          m142ax := arr[i,2]
        case arr[i,1] == "14.2.Ma" .and. valtype(arr[i,2]) == "N"
          m142ma := arr[i,2]
        case arr[i,1] == "14.2.Me" .and. valtype(arr[i,2]) == "N"
          m142me := arr[i,2]
        case arr[i,1] == "14.2.Me1" .and. valtype(arr[i,2]) == "N"
          m142me1 := arr[i,2]
        case arr[i,1] == "14.2.Me2" .and. valtype(arr[i,2]) == "N"
          m142me2 := arr[i,2]
        case arr[i,1] == "14.2.Me3" .and. valtype(arr[i,2]) == "N"
          m1142me3 := arr[i,2]
        case arr[i,1] == "14.2.Me4" .and. valtype(arr[i,2]) == "N"
          m1142me4 := arr[i,2]
        case arr[i,1] == "14.2.Me5" .and. valtype(arr[i,2]) == "N"
          m1142me5 := arr[i,2]
        case arr[i,1] == "15.1" .and. valtype(arr[i,2]) == "N"
          m1diag_15_1 := arr[i,2]
        case arr[i,1] == "15.2" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
          mdiag_15_1_1 := arr[i,2,1]
          for k := 2 to 14
            if len(arr[i,2]) >= k
              mvar := "m1diag_15_1_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "15.3" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
          mdiag_15_2_1 := arr[i,2,1]
          for k := 2 to 14
            if len(arr[i,2]) >= k
              mvar := "m1diag_15_2_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "15.4" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
          mdiag_15_3_1 := arr[i,2,1]
          for k := 2 to 14
            if len(arr[i,2]) >= k
              mvar := "m1diag_15_3_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "15.5" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
          mdiag_15_4_1 := arr[i,2,1]
          for k := 2 to 14
            if len(arr[i,2]) >= k
              mvar := "m1diag_15_4_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "15.6" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
          mdiag_15_5_1 := arr[i,2,1]
          for k := 2 to 14
            if len(arr[i,2]) >= k
              mvar := "m1diag_15_5_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "15.9" .and. valtype(arr[i,2]) == "N"
          mGRUPPA_DO := arr[i,2]
        case arr[i,1] == "16.1" .and. valtype(arr[i,2]) == "N"
          m1diag_16_1 := arr[i,2]
        case arr[i,1] == "16.2" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
          mdiag_16_1_1 := arr[i,2,1]
          for k := 2 to 16
            if len(arr[i,2]) >= k
              mvar := "m1diag_16_1_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "16.3" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
          mdiag_16_2_1 := arr[i,2,1]
          for k := 2 to 16
            if len(arr[i,2]) >= k
              mvar := "m1diag_16_2_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "16.4" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
          mdiag_16_3_1 := arr[i,2,1]
          for k := 2 to 16
            if len(arr[i,2]) >= k
              mvar := "m1diag_16_3_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "16.5" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
          mdiag_16_4_1 := arr[i,2,1]
          for k := 2 to 16
            if len(arr[i,2]) >= k
              mvar := "m1diag_16_4_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "16.6" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
          mdiag_16_5_1 := arr[i,2,1]
          for k := 2 to 16
            if len(arr[i,2]) >= k
              mvar := "m1diag_16_5_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "16.7" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 8
          m1invalid1 := arr[i,2,1]
          m1invalid2 := arr[i,2,2]
          minvalid3  := arr[i,2,3]
          minvalid4  := arr[i,2,4]
          m1invalid5 := arr[i,2,5]
          m1invalid6 := arr[i,2,6]
          minvalid7  := arr[i,2,7]
          m1invalid8 := arr[i,2,8]
        case arr[i,1] == "16.8" .and. valtype(arr[i,2]) == "N"
          //mGRUPPA := arr[i,2]
        case arr[i,1] == "16.9" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 3
          m1privivki1 := arr[i,2,1]
          m1privivki2 := arr[i,2,2]
          mprivivki3  := arr[i,2,3]
        case arr[i,1] == "16.10" .and. valtype(arr[i,2]) == "C"
          mrek_form := padr(arr[i,2],255)
        case arr[i,1] == "16.11" .and. valtype(arr[i,2]) == "C"
          mrek_disp := padr(arr[i,2],255)
        // case arr[i,1] == "47" .and. valtype(arr[i,2]) == "N"
        //   m1dopo_na  := arr[i,2]
        case arr[i,1] == "47"
          if valtype(arr[i,2]) == "N"
            m1dopo_na  := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1dopo_na  := arr[i,2][1]
            if arr[i,2][2] > 0
              TPERS->(dbGoto(arr[i,2][2]))
              mtab_v_dopo_na := TPERS->tab_nom
            endif
            // mtab_v_dopo_na := arr[i,2][2]
          endif
        // case arr[i,1] == "52" .and. valtype(arr[i,2]) == "N"
        //   m1napr_v_mo  := arr[i,2]
        case arr[i,1] == "52" 
          if valtype(arr[i,2]) == "N"
            m1napr_v_mo  := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1napr_v_mo  := arr[i,2][1]
            if arr[i,2][2] > 0
              TPERS->(dbGoto(arr[i,2][2]))
              mtab_v_mo := TPERS->tab_nom
            endif
            // mtab_v_mo := arr[i,2][2]
          endif
        case arr[i,1] == "53" .and. valtype(arr[i,2]) == "A"
          arr_mo_spec := arr[i,2]
        // case arr[i,1] == "54" .and. valtype(arr[i,2]) == "N"
        //   m1napr_stac := arr[i,2]
        case arr[i,1] == "54"
          if valtype(arr[i,2]) == "N"
            m1napr_stac := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1napr_stac := arr[i,2][1]
            if arr[i,2][2] > 0
              TPERS->(dbGoto(arr[i,2][2]))
              mtab_v_stac := TPERS->tab_nom
            endif
            // mtab_v_stac := arr[i,2][2]
          endif
        case arr[i,1] == "55" .and. valtype(arr[i,2]) == "N"
          m1profil_stac := arr[i,2]
        // case arr[i,1] == "56" .and. valtype(arr[i,2]) == "N"
        //   m1napr_reab := arr[i,2]
        case arr[i,1] == "56"
          if valtype(arr[i,2]) == "N"
            m1napr_reab := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1napr_reab := arr[i,2][1]
            if arr[i,2][2] > 0
              TPERS->(dbGoto(arr[i,2][2]))
              mtab_v_reab := TPERS->tab_nom
            endif
            // mtab_v_reab := arr[i,2][2]
          endif
        case arr[i,1] == "57" .and. valtype(arr[i,2]) == "N"
          m1profil_kojki := arr[i,2]
        otherwise
          for k := 1 to count_dds_arr_iss
            if arr[i,1] == "18."+lstr(k) .and. valtype(arr[i,2]) == "C"
              mvar := "MREZi"+lstr(k)
              &mvar := padr(arr[i,2],17)
            endif
          next
      endcase
    endif
  next

  if ! aliasIsUse
    TPERS->(dbCloseArea())
    Select(oldSelect)
  endif

  return NIL
  