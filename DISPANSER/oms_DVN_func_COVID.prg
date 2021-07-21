#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 23.01.17
Function f_valid_diag_oms_sluch_DVN_COVID(get,k)
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
  // mdispans := inieditspr(A__MENUVERT, mm_dispans, m1dispans)
  update_get(pole_pervich)
  update_get(pole_d_diag)
  update_get(pole_stadia)
  update_get(pole_dispans)
  update_get(pole_d_dispans)
  update_get("mdispans")
  return .t.
  
  
***** 20.07.21 ࠡ��� �� ��㣠 (㬮�砭��) ��� � ����ᨬ��� �� �⠯�, ������ � ����
Function f_is_umolch_sluch_DVN_COVID(i, _etap, _vozrast, _pol)
  Local fl := .f.
  local j, ta, ar   // := ret_dvn_arr_COVID_umolch()[i]

  if i > len(ret_dvn_arr_COVID_umolch()[i])
    return fl
  else
    ar := ret_dvn_arr_COVID_umolch()[i]
  endif
  if valtype(ar[3]) == "N"
    fl := (ar[3] == _etap)
  else
    fl := ascan(ar[3],_etap) > 0
  endif
  return fl
  
***** 15.06.19
Function ret_etap_DVN_COVID(lkod_h,lkod_k)
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
    if fl .and. between(human->ishod,401,402) // ???
      i := human->ishod-400
      if year(human->n_data) == d1 // ⥪�騩 ���
        aadd( ae[1], { i, human->k_data, human_->RSLT_NEW } )
      endif
    endif
    skip
  enddo
  close databases
  return ae
  
***** 16.02.2020 ���� �� ��室�� (�ࠧ�����) ��� �஢������ ��ᯠ��ਧ�樨
Function f_is_prazdnik_DVN_COVID(_n_data)
  return !is_work_day(_n_data)
  
***** 20.07.21 ������ ��� ��㣨 �����祭���� ���� ��� ��� 㣫㡫����� COVID
Function ret_shifr_zs_DVN_COVID(_etap,_vozrast,_pol,_date)
  Local lshifr := "", fl, is_disp, n := 1
    
  if _etap == 1
    n := 1
      if is_prazdnik
        n += 700
      endif
    lshifr := '70.8.1'
  elseif _etap == 2
  endif
  return lshifr
  
  
***** 16.07.21 ������ "�ࠢ����" ��䨫� ��� ��ᯠ��ਧ�樨/��䨫��⨪�
Function ret_profil_dispans_COVID(lprofil,lprvs)

  if lprofil == 34 // �᫨ ��䨫� �� "������᪮� ������୮� �������⨪�"
    if ret_old_prvs(lprvs) == 2013 // � ᯥ�-�� "������୮� ����"
      lprofil := 37 // ᬥ��� �� ��䨫� �� "������୮�� ����"
    elseif ret_old_prvs(lprvs) == 2011 // ��� "������ୠ� �������⨪�"
      lprofil := 38 // ᬥ��� �� ��䨫� �� "������୮� �������⨪�"
    endif
  endif
  return lprofil
  
***** 19.07.21
Function save_arr_DVN_COVID(lkod)
  Local arr := {}, i, sk, ta

  if type("mfio") == "C"
    aadd(arr,{"mfio",alltrim(mfio)})
  endif
  if type("mdate_r") == "D"
    aadd(arr,{"mdate_r",mdate_r})
  endif
  aadd(arr,{ "0",m1mobilbr})   // "N",�����쭠� �ਣ���
  aadd(arr,{ "1",mDateCOVID})     // "D",��� ����砭�� ��祭�� COVID
  aadd(arr,{ "2",mOKSI})     // "N",��ᨬ����
  for i := 1 to 5
    sk := lstr(i)
    pole_diag := "mdiag"+sk
    pole_1pervich := "m1pervich"+sk
    pole_1stadia := "m1stadia"+sk
    pole_1dispans := "m1dispans"+sk
    pole_1dop := "m1dop"+sk
    pole_1usl := "m1usl"+sk
    pole_1san := "m1san"+sk
    pole_d_diag := "mddiag"+sk
    pole_d_dispans := "mddispans"+sk
    pole_dn_dispans := "mdndispans"+sk
    if !empty(&pole_diag)
      ta := {&pole_diag,;
              &pole_1pervich,;
              &pole_1stadia,;
              &pole_1dispans}
      if type(pole_1dop)=="N" .and. type(pole_1usl)=="N" .and. type(pole_1san)=="N"
        aadd(ta, &pole_1dop)
        aadd(ta, &pole_1usl)
        aadd(ta, &pole_1san)
      else
        aadd(ta,0)
        aadd(ta,0)
        aadd(ta,0)
      endif
      if type(pole_d_diag)=="D" .and. type(pole_d_dispans)=="D"
        aadd(ta, &pole_d_diag)
        aadd(ta, &pole_d_dispans)
      else
        aadd(ta,ctod(""))
        aadd(ta,ctod(""))
      endif
      if type(pole_dn_dispans)=="D"
        aadd(ta, &pole_dn_dispans)
      else
        aadd(ta,ctod(""))
      endif
      aadd(arr,{lstr(10+i),ta})
    endif
  next i
  // �⪠�� ��樥��
  if !empty(arr_usl_otkaz)
    aadd(arr,{"19",arr_usl_otkaz}) // ���ᨢ
  endif
  aadd(arr,{"20",m1GRUPPA})    // "N1",��㯯� ���஢�� ��᫥ ���-��
  // if type("m1ot_nasl1") == "N"
    aadd(arr,{"30",arr_otklon}) // ���ᨢ
    aadd(arr,{"31",m1dispans})
    aadd(arr,{"32",m1nazn_l})
  // endif
  if type("m1p_otk") == "N"
    aadd(arr,{"33",m1p_otk})
  endif
  save_arr_DISPANS(lkod,arr)
  return NIL

***** 19.01.21
Function read_arr_DVN_COVID(lkod,is_all)
  Local arr, i, sk
  
  Private mvar
  arr := read_arr_DISPANS(lkod)
  DEFAULT is_all TO .t.
  for i := 1 to len(arr)
    if valtype(arr[i]) == "A" .and. valtype(arr[i,1]) == "C"
      do case
        case arr[i,1] == "0" .and. valtype(arr[i,2]) == "N"
          m1mobilbr := arr[i,2]
        case arr[i,1] == "1" .and. valtype(arr[i,2]) == "D"
          mDateCOVID := arr[i,2]
        case arr[i,1] == "2" .and. valtype(arr[i,2]) == "N"
          mOKSI := arr[i,2]
        case is_all .and. eq_any(arr[i,1],"11","12","13","14","15") .and. ;
                    valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 7
          sk := right(arr[i,1],1)
          pole_diag := "mdiag"+sk
          pole_1pervich := "m1pervich"+sk
          pole_1stadia := "m1stadia"+sk
          pole_1dispans := "m1dispans"+sk
          pole_1dop := "m1dop"+sk
          pole_1usl := "m1usl"+sk
          pole_1san := "m1san"+sk
          pole_d_diag := "mddiag"+sk
          pole_d_dispans := "mddispans"+sk
          pole_dn_dispans := "mdndispans"+sk
          if valtype(arr[i,2,1]) == "C"
            &pole_diag := arr[i,2,1]
          endif
          if valtype(arr[i,2,2]) == "N"
            &pole_1pervich := arr[i,2,2]
          endif
          if valtype(arr[i,2,3]) == "N"
            &pole_1stadia := arr[i,2,3]
          endif
          if valtype(arr[i,2,4]) == "N"
            &pole_1dispans := arr[i,2,4]
          endif
          if valtype(arr[i,2,5]) == "N" .and. type(pole_1dop) == "N"
            &pole_1dop := arr[i,2,5]
          endif
          if valtype(arr[i,2,6]) == "N" .and. type(pole_1usl) == "N"
            &pole_1usl := arr[i,2,6]
          endif
          if valtype(arr[i,2,7]) == "N" .and. type(pole_1san) == "N"
            &pole_1san := arr[i,2,7]
          endif
          if len(arr[i,2]) >= 8 .and. valtype(arr[i,2,8]) == "D" .and. type(pole_d_diag) == "D"
            &pole_d_diag := arr[i,2,8]
          endif
          if len(arr[i,2]) >= 9 .and. valtype(arr[i,2,9]) == "D" .and. type(pole_d_dispans) == "D"
            &pole_d_dispans := arr[i,2,9]
          endif
          if len(arr[i,2]) >= 10 .and. valtype(arr[i,2,10]) == "D" .and. type(pole_dn_dispans) == "D"
            &pole_dn_dispans := arr[i,2,10]
          endif
        case is_all .and. arr[i,1] == "19" .and. valtype(arr[i,2]) == "A"
            arr_usl_otkaz := arr[i,2]
        case arr[i,1] == "20" .and. valtype(arr[i,2]) == "N"
          //m1GRUPPA := arr[i,2]
        case is_all .and. arr[i,1] == "30" .and. valtype(arr[i,2]) == "A"
          arr_otklon := arr[i,2]
        case arr[i,1] == "31" .and. valtype(arr[i,2]) == "N"
          m1dispans  := arr[i,2]
        case arr[i,1] == "32" .and. valtype(arr[i,2]) == "N"
          m1nazn_l   := arr[i,2]
        case arr[i,1] == "33" .and. valtype(arr[i,2]) == "N"
          m1p_otk  := arr[i,2]
      endcase
    endif
  next
  return NIL
    
***** 20.07.21
Function ret_ndisp_COVID( lkod_h, lkod_k )   //,/*@*/new_etap,/*@*/msg)
  local fl := .t., msg

  msg := ' '

  ar := ret_etap_DVN_COVID(lkod_h,lkod_k)
  if (len(ar[1]) == 0) .and. (lkod_h == 0)
    metap := 1
  elseif  (len(ar[1]) == 1) .and. (lkod_h == 0)
    if ! eq_any(ar[1,1,3], 352, 353, 357, 358)
      msg := '� ' + lstr(year(mn_data)) + ' ���� �஢���� I �⠯ 㣫㡫����� ��ᯠ��ਧ�樨 ��� ���ࠢ����� �� II �⠯!'
      hb_Alert(msg)
      fl := .f.
    endif
    metap := 2
  endif

  mndisp := inieditspr(A__MENUVERT, mm_ndisp, metap)
  return fl

***** 20.07.21 ᪮�४�஢��� ���ᨢ� �� 㣫㡫����� ��ᯠ��ਧ�樨 COVID
Function ret_arrays_disp_COVID()
  local dvn_COVID_arr_usl

  // 1- ������������ ����
  // 2- ��� ��㣨
  // 3- �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1,2}
  // 4 - ������� (0 ��� 1) ����� ����?
  // 5- �������� �⪠� ��樥�� (0 - ���, 1 - ��)
  // 6 - ������ ��� ��稭 (�᫮ ���), �᫨ 1 - �� ������, �᫨ ᯨ᮪ {} � ������� ���祭�� ������
  // 7 - ������ ��� ���騭 (�᫮ ���), �᫨ 1 - �� ������, �᫨ ᯨ᮪ {} � ������� ���祭�� ������
  
  //  10- V002 - �����䨪��� ��䨫�� ��������� ����樭᪮� �����
  //  11- V004 - �����䨪��� ����樭᪨� ᯥ樠�쭮�⥩
  //  12 - �ਧ��� ��㣨 �����/����� 0 - ������ 1 - �����
  dvn_COVID_arr_usl := {; // ��㣨 �� �࠭ ��� �����
      { "���ᮮ�ᨬ����", "A12.09.005", 1, 0, 1,1,1,;
        1,1,111,{2021,110103,110303,110906,111006,111905,112212,112611,113418,113509,180202},;
        1;
      },;
      { "�஢������ ᯨ஬��ਨ ��� ᯨண�䨨","A12.09.001",1,0,1,1,1,;
        1,1,111,{2021,110103,110303,110906,111006,111905,112212,112611,113418,113509,180202},;
        1;
      },;
      { "��騩 (������᪨�) ������ �஢� ࠧ������","B03.016.003",1,0,1,1,1,;
        1,1,{34,37,38},{1107,1301,1402,1702,1801,2011},;
        1;
      },;
      { "������ �஢� ���娬��᪨� ����࠯����᪨�","B03.016.004",1,0,1,1,1,;
        1,1,{34,37,38},{1107,1301,1402,1702,1801,2011},;
        1;
      },;
      { "���⣥������ ������","A06.09.007",1,0,1,1,1,;
        1,1,78,{1118,1802,2020},;
        1;
      },;
      { "�஢������ ��� � 6 ����⭮� 室졮�","70.8.2",1,0,1,1,1,;
        1,1,{42,151},{39,76,206},;
        0;
      },;
      { "��।������ ���業��樨 �-����� � �஢�","70.8.3",1,0,1,1,1,;
        1,1,{34,37,38},{26,215,217},;
        0;
      },;
      { "�஢������ �宪�न���䨨","70.8.50",2,0,1,1,1,;
        1,1,{106,111},{81,89,226},;
        0;
      },;
      { "�஢������ �� ������","70.8.51",2,0,1,1,1,;
        1,1,78,60,;
        0;
      },;
      { "�㯫��᭮� ᪠���-�� ��� ������ ����筮�⥩","70.8.52",2,0,1,1,1,;
        1,1,106,81,;
        0;
      },;
      { "��� (�ᬮ��) ��箬-�࠯��⮬ ��ࢨ��","B01.026.001",1,1,0,1,1,;
        1,1,{42,151},{2021,110103,110303,110906,111006,111905,112212,112611,113418,113509,180202},;
        1;
      },;
      { "��� (�ᬮ��) ��箬-�࠯��⮬ ������","B01.026.002",2,1,0,1,1,;
        1,1,{42,151},{2021,110103,110303,110906,111006,111905,112212,112611,113418,113509,180202},;
        1;
      },;
      { "�������᭮� ���饭�� 㣫㡫����� ��ᯠ��ਧ��� I �⠯","70.8.1",1,1,0,1,1,;
        1,1,{42,151},{2021,110103,110303,110906,111006,111905,112212,112611,113418,113509,180202},;
        0;
      };
    }
    // { "��騩 (������᪨�) ������ �஢� ࠧ������","B03.016.003",1,0,1,1,1,;
    // 1,1,{34,37,38},{26,215,217};
    // },;
    // { "������ �஢� ���娬��᪨� ����࠯����᪨�","B03.016.004",1,0,1,1,1,;
    // 1,1,{34,37,38},{26,215,217};
    // },;
    // { "��� (�ᬮ��) ��箬-�࠯��⮬ ��ࢨ��","B01.026.001",1,1,0,1,1,;
    // 1,1,{42,151},{39,76,206},;
    // {57,97,42},1,1;
    // },;
    // { "��� (�ᬮ��) ��箬-�࠯��⮬ ������","B01.026.002",2,1,0,1,1,;
    // 1,1,{42,151},{39,76,206},;
    // {57,97,42},1,1;
    // },;
    // { "�������᭮� ���饭�� 㣫㡫����� ��ᯠ��ਧ��� I �⠯","70.8.1",1,1,0,1,1,;
    // 1,1,{42,151},{39,76,206},;
    // {57,97,42},1,1;
    // };
return dvn_COVID_arr_usl

***** 20.07.21 ࠡ��� �� ��㣠 �� 㣫㡫����� ��ᯠ��ਧ�樨 COVID � ����ᨬ��� �� �⠯�
Function f_is_usl_oms_sluch_DVN_COVID( i, _etap, allUsl, /*@*/_diag, /*@*/_otkaz) //, /*@*/_ekg)
  Local fl := .f.
  local ars := {}
  local ar := ret_arrays_disp_COVID()[i]

  if valtype(ar[2]) == "C" .and. _etap == 1 .and. alltrim(ar[2]) == "70.8.1" .and. ( ! allUsl )
    return fl
  endif
  if valtype(ar[3]) == "N"
    fl := (ar[3] == _etap)
  else
    fl := ascan(ar[3],_etap) > 0
  endif
  _diag := (ar[4] == 1)
  _otkaz := 0
  if valtype(ar[2]) == "C"
    aadd(ars,ar[2])
  else
    ars := aclone(ar[2])
  endif
  if eq_any(_etap,1,2) .and. ar[5] == 1
    _otkaz := 1 // ����� ����� �⪠�
  endif
  return fl

***** 16.07.21 ���ᨢ ���, �����뢠��� �ᥣ�� �� 㬮�砭�� �� 㣫㡫����� ��ᯠ��ਧ�樨 COVID
Function ret_dvn_arr_COVID_umolch()
  local dvn_COVID_arr_umolch := {}

  // 1- ������������ ����
  // 2- ��� ��㣨
  // 3- �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1,2}
  // 4 - ������� (0 ��� 1) ����� ����?
  // 5- �������� �⪠� ��樥�� (0 - ���, 1 - ��)
  // 6 - ������ ��� ��稭 (�᫮ ���), �᫨ 1 - �� ������, �᫨ ᯨ᮪ {} � ������� ���祭�� ������
  // 7 - ������ ��� ���騭 (�᫮ ���), �᫨ 1 - �� ������, �᫨ ᯨ᮪ {} � ������� ���祭�� ������
  
  //  10- V002 - �����䨪��� ��䨫�� ��������� ����樭᪮� �����
  //  11- V004 - �����䨪��� ����樭᪨� ᯥ樠�쭮�⥩

    // count_dvn_arr_usl := len(dvn_COVID_arr_usl)
    // count_dvn_arr_umolch := len(dvn_arr_umolch)
  return dvn_COVID_arr_umolch

