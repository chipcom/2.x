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
  
  
***** 15.07.21 ࠡ��� �� ��㣠 (㬮�砭��) ��� � ����ᨬ��� �� �⠯�, ������ � ����
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
  // if fl
  //   if _etap == 1
  //     i := iif(_pol=="�", 4, 5)
  //   else//if _etap == 3
  //     i := iif(_pol=="�", 6, 7)
  //   endif
  //   if valtype(ar[i]) == "N"
  //     fl := (ar[i] != 0)
  //   elseif valtype(ar[i]) == "C"
  //     // "18,65" - ��� ��⪮�� ���.���.�������஢����
  //     ta := list2arr(ar[i])
  //     for i := len(ta) to 1 step -1
  //       if _vozrast >= ta[i]
  //         for j := 0 to 99
  //           if _vozrast == int(ta[i]+j*3)
  //             fl := .t.
  //             exit
  //           endif
  //         next
  //         if fl
  //           exit
  //         endif
  //       endif
  //     next
  //   else
  //     fl := between(_vozrast,ar[i,1],ar[i,2])
  //   endif
  // endif
  return fl
  
  
// ***** 15.06.19 ������ ���ᨢ �����⮢ ���-�� ��� ��ண� ��� ������ �ਪ���� �� ��
// Function ret_arr_vozrast_DVN_COVID(_data)
//   Static sp := 0, arr := {}
//   Local i, p := iif(_data < d_01_05_2019, 1, 2)

//   if p != sp
//     arr := aclone(arr_vozrast_DVN) // �� ��஬� �ਪ��� �� ��
//     if (sp := p) == 2 // �� ������ �ਪ��� �� ��
//       asize(arr,7) // 㡥�� 墮�� ��᫥ 39 ��� {21,24,27,30,33,36,39,
//       Ins_Array(arr,1,18) // ��⠢�� � ��砫� =18 ���
//       for i := 40 to 99
//         aadd(arr,i) // ������� � ����� ����� � 40 �� 99 ���
//       next
//     endif
//   endif
//   return arr
  
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
  
***** 17.07.21 ������ ��� ��㣨 �����祭���� ���� ��� ��� 㣫㡫����� COVID
Function ret_shifr_zs_DVN_COVID(_etap,_vozrast,_pol,_date)
  Local lshifr := "", fl, is_disp, n := 1
    
  if _etap == 1
    n := 1
    // if m1g_cit == 2
    //   if m1mobilbr == 1
    //     n += 600
    //   else
    //     n += 500
    //   endif
    // else
      if is_prazdnik
        n += 700
      // elseif m1mobilbr == 1
      //   n += 300
      endif
    // endif
    // lshifr := "70.7."+lstr(n)
    lshifr := '70.8.1'
  elseif _etap == 2
    // ����
    // else // �᫨ ����� ��ᯠ��ਧ�樨 ��ଫ���� ���ᬮ��
    //   //
    // endif
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
    
***** 15.07.21
Function ret_ndisp_COVID( lkod_h, lkod_k )   //,/*@*/new_etap,/*@*/msg)
  // Local i, i1, i2, i3, i4, i5, s, s1, is_disp, ar
  local fl := .t., msg
  // local dvn_COVID_arr_usl

  // dvn_COVID_arr_usl := ret_arrays_disp_COVID()
  msg := ' '
  // new_etap := metap

  // if metap == 0
  //   if is_disp
  //     new_etap := 1
  //   else
  //     new_etap := 3
  //   endif
  // elseif metap == 1
  //   new_etap := 2
  // elseif metap == 3
  //   if is_disp
  //     new_etap := 1
  //   else
  //     // ������� = 3
  //   endif
  // else
  //   if is_disp
  //     // ������� = 1 ��� 2
  //   elseif new_etap < 4
  //     new_etap := 3
  //   endif
  // endif

  ar := ret_etap_DVN_COVID(lkod_h,lkod_k)
  // if new_etap != 3
    // if empty(ar[1]) // � �⮬ ���� ��� ��祣� �� ������
      // ��⠢�塞 1
    // else
  //     i1 := i2 := i3 := i4 := i5 := 0
      // for i := 1 to len(ar[1])
      //   do case
      //     case ar[1,i,1] == 1 // ���-�� 1 �⠯
      //       i1 := i
      //     case ar[1,i,1] == 2 // ���-�� 2 �⠯
      //       i2 := i
      //     // case ar[1,i,1] == 3 // ��䨫��⨪�
      //     //   i3 := i
      //     //   msg := date_8(ar[1,i,2])+"�. 㦥 �஢��� ��䨫����᪨� ����ᬮ��!"
      //     // case ar[1,i,1] == 4 // ���-�� 1 �⠯ 1 ࠧ � 2 ����
      //     //   i4 := i
      //     //   msg := "� "+lstr(year(mn_data))+" ���� 㦥 �஢����� ��ᯠ��ਧ�樨 1 ࠧ � 2 ����"
      //     // case ar[1,i,1] == 5 // ���-�� 2 �⠯ 1 ࠧ � 2 ����
      //     //   i5 := i
      //     //   msg := "� "+lstr(year(mn_data))+" ���� 㦥 �஢����� ��ᯠ��ਧ�樨 1 ࠧ � 2 ����"
      //   endcase
      // next
  //     if eq_any(new_etap, 1, 2 ) .and. new_etap != metap
  //       if i1 == 0
  //         new_etap := 1 // ������ 1 �⠯
  //       elseif i2 == 0
  //         new_etap := 2 // ������ 2 �⠯
  //       endif
  //     endif
  //     if i1 > 0 .and. i2 > 0
  //       msg := "� "+lstr(year(mn_data))+" ���� 㦥 �஢����� ��� �⠯� 㣫㡫����� ��ᯠ��ਧ�樨!"
  //     elseif i1 > 0 .and. !empty(ar[1,i1,2]) .and. ar[1,i1,2] > mn_data
  //       msg := "���㡫����� ��ᯠ��ਧ��� I �⠯� �����稫��� " + date_8(ar[1,i1,2]) + "�.!"
  //     endif
  //     // if eq_any(new_etap,4,5) .and. new_etap != metap
  //     //   if i4 == 0
  //     //     new_etap := 4 // ������ 1 �⠯
  //     //   elseif i5 == 0
  //     //     new_etap := 5 // ������ 2 �⠯
  //     //   endif
  //     // endif
  //     // if i4 > 0 .and. i5 > 0
  //     //   msg := "� "+lstr(year(mn_data))+" ���� 㦥 �஢����� ��� �⠯� ��ᯠ��ਧ�樨 (ࠧ � 2 ����)!"
  //     // elseif i4 > 0 .and. !empty(ar[1,i4,2]) .and. ar[1,i4,2] > mn_data
  //     //   msg := "��ᯠ��ਧ��� I �⠯� (ࠧ � 2 ����) �����稫��� "+date_8(ar[1,i4,2])+"�.!"
  //     // endif
  //   endif
  // else //if new_etap == 3
  //   if empty(ar[1]) // � �⮬ ���� ��� ��祣� �� ������
  //     if empty(ar[2]) // ��ᬮ�ਬ ���� ���
  //       // ��⠢�塞 3
  //     // elseif ascan(ar[2],{|x| x[1] == 3 }) > 0 // ��䨫��⨪� �뫠 � ��諮� ����
  //       // if is_dostup_2_year
  //       //   new_etap := 4 // �ࠧ� ࠧ�蠥� ���-�� 1 ࠧ � 2 ����, �.�. � ��諮�
  //       // else
  //       //   msg := "��䨫��⨪� �஢������ 1 ࠧ � 2 ���� ("+date_8(ar[2,1,2])+"�. 㦥 �஢�����)"
  //       // endif
  //     endif
  //   else
  //     i1 := i2 := i3 := i4 := i5 := 0
  //     for i := 1 to len(ar[1])
  //       do case
  //         case ar[1,i,1] == 1 // ���-�� 1 �⠯
  //           i1 := i
  //           msg := date_8(ar[1,i,2])+"�. 㦥 �஢����� 㣫㡫����� ��ᯠ��ਧ��� I �⠯�!"
  //         case ar[1,i,1] == 2 // ���-�� 2 �⠯
  //           i2 := i
  //           msg := date_8(ar[1,i,2])+"�. 㦥 �஢����� 㣫㡫����� ��ᯠ��ਧ��� II �⠯�!"
  //         // case ar[1,i,1] == 3 // ��䨫��⨪�
  //         //   i3 := i
  //         //   msg := date_8(ar[1,i,2])+"�. 㦥 �஢��� ��䨫����᪨� ����ᬮ��!"
  //         // case ar[1,i,1] == 4 // ���-�� 1 �⠯ ࠧ � 2 ����
  //         //   i4 := i
  //         // case ar[1,i,1] == 5 // ���-�� 2 �⠯ ࠧ � 2 ����
  //         //   i5 := i
  //       endcase
  //     next
  //     // if i4 > 0
  //       // if i5 > 0
  //       //   msg := "� "+lstr(year(mn_data))+" ���� 㦥 �஢����� ��� �⠯� ��ᯠ��ਧ�樨 (ࠧ � 2 ����)!"
  //       // elseif !empty(ar[1,i4,2]) .and. ar[1,i4,2] > mn_data
  //       //   msg := "��ᯠ��ਧ��� I �⠯� (ࠧ � 2 ����) �����稫��� "+date_8(ar[1,i4,2])+"�.!"
  //       // else
  //       //   new_etap := 5 // ������ 2 �⠯
  //       // endif
  //     // endif
    // endif
  // endif
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
  // if empty(msg)
  //   metap := new_etap
  mndisp := inieditspr(A__MENUVERT, mm_ndisp, metap)
  // else
  //   metap := 0
  //   mndisp := space(23)
  //   func_error(4, fam_i_o(mfio) + " " + msg)
  // endif
  return fl

***** 15.07.21 ᪮�४�஢��� ���ᨢ� �� 㣫㡫����� ��ᯠ��ਧ�樨 COVID
Function ret_arrays_disp_COVID()
  Local blk
  local dvn_COVID_arr_usl

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
  // 3- �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1,2}
  // 4 - ������� (0 ��� 1) ����� ����?
  // 5- �������� �⪠� ��樥�� (0 - ���, 1 - ��)
  // 6 - ������ ��� ��稭 (�᫮ ���), �᫨ 1 - �� ������, �᫨ ᯨ᮪ {} � ������� ���祭�� ������
  // 7 - ������ ��� ���騭 (�᫮ ���), �᫨ 1 - �� ������, �᫨ ᯨ᮪ {} � ������� ���祭�� ������
  
  //  10- V002 - �����䨪��� ��䨫�� ��������� ����樭᪮� �����
  //  11- V004 - �����䨪��� ����樭᪨� ᯥ樠�쭮�⥩
  dvn_COVID_arr_usl := {; // ��㣨 �� �࠭ ��� �����
      { "���ᮮ�ᨬ����", "A12.09.005", 1, 0, 1,1,1,;
        1,1,111,{2021,110103,110303,110906,111006,111905,112212,112611,113418,113509,180202};
      },;
      { "�஢������ ᯨ஬��ਨ ��� ᯨண�䨨","A12.09.001",1,0,1,1,1,;
        1,1,111,{2021,110103,110303,110906,111006,111905,112212,112611,113418,113509,180202};
      },;
      { "��騩 (������᪨�) ������ �஢� ࠧ������","B03.016.003",1,0,1,1,1,;
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};
      },;
      { "������ �஢� ���娬��᪨� ����࠯����᪨�","B03.016.004",1,0,1,1,1,;
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};
      },;
      { "���⣥������ ������","A06.09.007",1,0,1,1,1,;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        78,{1118,1802,2020};
      },;
      { "�஢������ ��� � 6 ����⭮� 室졮�","70.8.2",1,0,1,1,1,;
        1,1,{42,151},{39,76,206};
      },;
      { "��।������ ���業��樨 �-����� � �஢�","70.8.3",1,0,1,1,1,;
        1,1,{34,37,38},{26,215,217};
      },;
      { "�஢������ �宪�न���䨨","70.8.50",2,0,1,1,1,;
        1,1,{106,111},{81,89,226};
      },;
      { "�஢������ �� ������","70.8.51",2,0,1,1,1,;
        1,1,78,60;
      },;
      { "�㯫��᭮� ᪠���-�� ��� ������ ����筮�⥩","70.8.52",2,0,1,1,1,;
        1,1,106,81;
      },;
      { "��� ��� �࠯���","70.8.1",{1,2},1,0,1,1,;
        1,1,{42,151},{39,76,206},;
        {57,97,42},1,1;
      };
    }
  return dvn_COVID_arr_usl

***** 16.07.21 ࠡ��� �� ��㣠 ��� � ����ᨬ��� �� �⠯�, ������ � ����
Function f_is_usl_oms_sluch_DVN_COVID( i, _etap, _vozrast, _pol, /*@*/_diag, /*@*/_otkaz) //, /*@*/_ekg)
  Local fl := .f.
  local ars := {}
  local ar := ret_arrays_disp_COVID()[i]

  if valtype(ar[3]) == "N"
    fl := (ar[3] == _etap)
  else
    fl := ascan(ar[3],_etap) > 0
  endif
  _diag := (ar[4] == 1)
  _otkaz := 0
  // _ekg := .f.
  if valtype(ar[2]) == "C"
    aadd(ars,ar[2])
  else
    ars := aclone(ar[2])
  endif
  if eq_any(_etap,1,2) .and. ar[5] == 1   // .and. ascan(ars,"4.20.1") == 0
    _otkaz := 1 // ����� ����� �⪠�
    // if valtype(ar[2]) == "C" .and. eq_ascan(ars,"7.57.3","7.61.3","4.1.12")
    //   _otkaz := 2 // ����� ����� �������������
    //   if ascan(ars,"4.1.12") > 0 // ���⨥ �����
    //     _otkaz := 3 // �������� �� ��� 䥫���-�����
    //   endif
    // endif
  endif
  // if fl .and. eq_any(_etap,1,4,5)
  //   if _etap == 1
  //     i := iif(_pol == "�", 6, 7)
  //   elseif len(ar) < 14
  //     return .f.
  //   else
  //     i := iif(_pol == "�", 13, 14)
  //   endif
  //   if valtype(ar[i]) == "N" // ᯥ樠�쭮 ��� ��㣨 "�����ப�न�����","13.1.1" ࠭�� 2018 ����
  //     fl := (ar[i] != 0)
  //     if ar[i] < 0  // ���
  //       _ekg := (_vozrast < abs(ar[i])) // ����易⥫�� ������
  //     endif
  //   else // ��� 1,4,5 �⠯� ������ 㪠��� ���ᨢ��
  //     fl := ascan(ar[i],_vozrast) > 0
  //   endif
  // endif
  // if fl .and. eq_any(_etap,2,3)
  //   i := iif(_pol=="�", 8, 9)
  //   if valtype(ar[i]) == "N"
  //     fl := (ar[i] != 0)
  //   elseif type("is_disp_19") == "L" .and. is_disp_19
  //     fl := ascan(ar[i],_vozrast) > 0
  //   else // ��� 2 �⠯� � ��䨫��⨪� ������ 㪠��� ����������
  //     fl := between(_vozrast,ar[i,1],ar[i,2])
  //   endif
  // endif
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

