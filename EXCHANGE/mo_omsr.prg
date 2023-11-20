***** mo_omsr.prg - ࠡ�� � ॥��஬ � ����� ���
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// #define max_rec_reestr 9999

Static Sreestr_sem := "����� � ॥��ࠬ�"
Static Sreestr_err := "� ����� ������ � ॥��ࠬ� ࠡ�⠥� ��㣮� ���짮��⥫�."
// Static sadiag1 := {}

***** 25.03.22 ᪮�४�஢��� ��� ����� ��� �������� ��樮��� (� ��樮���) �� ��業���
Function ret_vidpom_licensia(lusl_ok,lvidpoms,lprofil)
Static mo_licensia := {;
  {'101004',2,'31',0},;  // �����
  {'141023',2,'31',0},;  // �-� 15
  {'801935',2,'31',0},;  // ���-��᪢�
  {'391001',2,'31',0},;  // ����設᪠� ���.�-� 1
  {'101001',2,'13',60},;   // ���-1 - ���������
  {'451001',2,'13',60},;   // ��堩���᪠� ��� - ���������
  {'451001',2,'13',136},;   // ��堩���᪠� ��� - �������� � �����������
  {'451001',2,'13',184},;   // ��堩���᪠� ��� - �������� � ����������� (�����⢥����� ���뢠��� ��६������)
  {'124528',2,'13',158},;   // 28 �-�� - ॠ�������
  {'805960',2,'13',97};   // ��痢��祡���
 }
Local i, fl := .f.
for i := 1 to len(mo_licensia)
  if mo_licensia[i,1] == glob_mo[_MO_KOD_TFOMS] .and. mo_licensia[i,2] == lusl_ok
    if mo_licensia[i,4] == 0 // �� ��䨫�
      lvidpoms := mo_licensia[i,3]
    elseif mo_licensia[i,4] == lprofil // ������� ��䨫�
      lvidpoms := mo_licensia[i,3]
    endif
  endif
next i
return lvidpoms

***** 24.02.21 ᪮�४�஢��� ��� ����� ��� �������� ��樮��� (� ��樮���) �� ��業���
Function ret_vidpom_st_dom_licensia(lusl_ok,lvidpoms,lprofil)
Static mo_licensia := {;
  {'591001',2,'31',68};   // ��� ��஢�����
 }
Local i, fl := .f.

for i := 1 to len(mo_licensia)
  if mo_licensia[i,1] == glob_mo[_MO_KOD_TFOMS] .and. mo_licensia[i,2] == lusl_ok
    if mo_licensia[i,4] == 0 // �� ��䨫�
      lvidpoms := mo_licensia[i,3]
    elseif mo_licensia[i,4] == lprofil // ������� ��䨫�
      lvidpoms := mo_licensia[i,3]
    endif
  endif
next i

return lvidpoms


***** 21.02.22 �᫨ �� �������᪠� ᪮��
Function is_komm_SMP()
Static _is
Static a_komm_SMP := {;
  "806501",; // ������ࠤ᪠� ���⫮���
  "806502",; // ����࠭�
  "806503";   // ������ࠤ᪠� ���⫮��� ����� 
 }
if _is == NIL // �.�. ��।������ ���� ࠧ �� ᥠ�� ࠡ��� �����
  _is := (ascan(a_komm_SMP,glob_mo[_MO_KOD_TFOMS]) > 0)
endif
return _is

***** 14.02.14 ���� �� ��㣠 "� ���⫮���� 楫��"
Function f_is_neotl_pom(lshifr)
Static a_stom_n := {; // �� �������� ���⫮���� �����
  "57.1.72","57.1.73","57.1.74","57.1.75","57.1.76","57.1.77",;
  "57.1.78","57.1.79","57.1.80","57.1.81";
 }
lshifr := alltrim(lshifr)
return eq_any(left(lshifr,5),"2.80.","2.82.") .or. ascan(a_stom_n,lshifr) > 0

***** 18.11.14 ���.��砩 � �-��
Function f_is_zak_sl_vr(lshifr)
return eq_any(left(lshifr,5),;
       "2.78.",; // �����祭�� ��砩 ���饭�� � ��祡��� 楫�� � ���� ...
       "2.89.",; // �����祭�� ��砩 ���饭�� � 楫�� ����樭᪮� ॠ�����樨
       "70.3.",; // �����祭�� ��砩 ��ᯠ��ਧ�樨 ���᫮�� ��ᥫ����
       "70.5.",; // �����祭�� ��砩 ��ᯠ��ਧ�樨 ��⥩-��� � ��樮���
       "70.6.",; // �����祭�� ��砩 ��ᯠ��ਧ�樨 ��⥩-��� ��� ������
       "72.1.",; // �����祭�� ��砩 ���ᬮ�� ���᫮�� ��ᥫ����
       "72.2.",; // �����祭�� ��砩 ���ᬮ�� ��ᮢ��襭����⭨�
       "72.3.",; // �����祭�� ��砩 �।���⥫쭮�� �ᬮ�� ��ᮢ��襭����⭨�
       "72.4.")  // �����祭�� ��砩 ��ਮ���᪮�� �ᬮ�� ��ᮢ��襭����⭨�

***** 13.02.14 ���� �� ��㣠 ��ࢨ�� �⮬�⮫����᪨� ��񬮬
Function f_is_1_stom(lshifr,ret_arr)
Static a_1_stom := {;
  "57.1.36","57.1.39","57.1.42","57.1.45","57.1.51",; // 2013 ���
  "57.1.57","57.1.58","57.1.59","57.1.60","57.1.61",; // � ��祡���
  "57.1.62","57.1.64","57.1.66","57.1.68","57.1.70","57.5.1",; // � ��䨫����᪮�
  "57.1.72","57.1.74","57.1.76","57.1.78","57.1.80";  // � ���⫮����
 }
Local i
lshifr := alltrim(lshifr)
if valtype(ret_arr) == "A"
  for j := 1 to len(a_1_stom)
    aadd(ret_arr, a_1_stom[j])
  next
endif
return ascan(a_1_stom,lshifr) > 0

***** 16.10.16 ���� �� ��㣠 �⮬�⮫����᪮� � �㫥��� 業��
Function is_2_stomat(lshifr,/*@*/is_2_88,is_new)
Local a_stom16_2 := {;
  {1,"2.78.47","2.78.53"},; // � ��祡��� 楫��
  {2,"2.79.52","2.79.58"},; // � ��䨫����᪮� 楫��
  {2,"2.88.40","2.88.45"},; //  -- " -- " -- " -- " -- ࠧ���� �� ������ �����������
  {3,"2.80.29","2.80.33"};  // �� �������� ���⫮���� �����
}
Local j, ret := 0
DEFAULT is_new TO .f.
if is_new // � 1 ������ 2016 ����
  a_stom16_2 := {;
    {1,"2.78.54","2.78.60"},; // � ��祡��� 楫��
    {2,"2.79.59","2.79.64"},; // � ��䨫����᪮� 楫��
    {2,"2.88.46","2.88.51"},; //  -- " -- " -- " -- " -- ࠧ���� �� ������ �����������
    {3,"2.80.34","2.80.38"};  // �� �������� ���⫮���� �����
  }
endif
is_2_88 := .f.
lshifr := alltrim(lshifr)
for j := 1 to len(a_stom16_2)
  if between_shifr(lshifr,a_stom16_2[j,2],a_stom16_2[j,3])
    ret := a_stom16_2[j,1]
    is_2_88 := (j == 3)
    exit
  endif
next
return ret

***** 12.03.18 ����祭�� � �⮬�⮫����᪮� ��砥 ࠧ��� ����� ���饭��
Function f_vid_p_stom(arr_usl,ta,ret_arr,ret_tip_a,lk_data,/*@*/ret_tip,/*@*/ret_kol,/*@*/is_2_88,arrFusl)
/*
 arr_usl   - ��㬥�� ���ᨢ, ��� ��㣨 � ��ࢮ� �����
 ta        - ���ᨢ � ⥪�⠬� �訡��
 ret_arr   - �����頥�� ���ᨢ ��祡��� ��񬮢 � ����ᨬ��� �� ᮤ�ঠ��� ret_tip_a
 ret_tip_a - �.�. {1,2,3}(default), {1}, {2}, {3}
 lk_data   - ��� ����砭�� ����
 ret_tip   - 2016 ��� - ������ ⨯� (�� 1 �� 3)
 ret_kol   - 2016 ��� - ������ ������⢠ ��祡��� ��񬮢 � ��砥
 is_2_88   - ���� �� ࠧ��� �� ������ �����������
 arrFusl   - ��㬥�� ���ᨢ, ��� ��㣨 ����� � ��ࢮ� �����
*/
Static a_stom14 := {; // � ��祡��� 楫��
  {"57.1.35","57.1.37","57.1.38","57.1.40","57.1.41",;
   "57.1.43","57.1.44","57.1.46","57.1.52",;
   "57.1.57","57.1.58","57.1.59","57.1.60","57.1.61",;
   "57.4.38","57.4.39","57.4.40","57.4.41";
  },;
  {; // � ��䨫����᪮� 楫��
   "57.1.62","57.1.63","57.1.64","57.1.65","57.1.66","57.1.67",;
   "57.1.68","57.1.69","57.1.70","57.1.71","57.5.1","57.5.2";
  },;
  {; // �� �������� ���⫮���� �����
   "57.1.72","57.1.73","57.1.74","57.1.75","57.1.76","57.1.77",;
   "57.1.78","57.1.79","57.1.80","57.1.81";
  };
}
Static a_stom15 := {; // � ��祡��� 楫��
  {"57.1.35","57.1.37","57.1.38","57.1.40","57.1.41",;
   "57.1.43","57.1.44","57.1.46","57.1.52",;
   "57.1.57","57.1.58","57.1.59","57.1.60","57.1.61",;
   "57.4.38","57.4.39","57.4.41";
  },;
  {; // � ��䨫����᪮� 楫��
   "57.4.40","57.5.1","57.5.2";
  },;
  {}; // �� �������� ���⫮���� �����
}
Static a_old_stom16 := {;
  {"57.1.57","57.1.58","57.1.59","57.1.60","57.1.61","57.4.38",; // � ��祡��� 楫��
   "57.1.37","57.1.40","57.1.43","57.1.46","57.1.52","57.4.39","57.4.40","57.4.41"},;
  {"57.1.57","57.1.58","57.1.59","57.1.60","57.1.61","57.4.38",; // � ��䨫����᪮� 楫��
   "57.5.1","57.5.2","57.4.40","57.4.41",;
   "57.1.37","57.1.40","57.1.43","57.1.46","57.1.52","57.4.39"},;
  {"57.1.57","57.1.58","57.1.59","57.1.60","57.1.61",;           // �� �������� ���⫮���� �����
   "57.1.37","57.1.40","57.1.43","57.1.46","57.1.52"};
}
Static a_old_stom16_2 := {;
  {1,"2.78.47","2.78.53"},; // � ��祡��� 楫��
  {2,"2.79.52","2.79.58"},; // � ��䨫����᪮� 楫��
  {2,"2.88.40","2.88.45"},; //  -- " -- " -- " -- " -- ࠧ���� �� ������ �����������
  {3,"2.80.29","2.80.33"};  // �� �������� ���⫮���� �����
}
// � 1 ������ 2016 ����
Static a_new_stom16 := {;
  {"B01.064.003","B01.064.004","B01.065.001","B01.065.002","B01.065.003","B01.065.004","B01.065.007","B01.065.008","B01.067.001","B01.067.002","B01.063.001","B01.063.002"},;
  {"B04.064.001","B04.064.002","B04.065.001","B04.065.002","B04.065.003","B04.065.004","B04.065.005","B04.065.006","B01.065.005","B01.065.006","B04.063.001"},;
  {"B01.064.003","B01.064.004","B01.065.001","B01.065.002","B01.065.003","B01.065.004","B01.065.007","B01.065.008","B01.067.001","B01.067.002","B01.063.001","B01.063.002"},;
  {"B01.064.003","B01.064.004","B01.065.001","B01.065.002","B01.065.003","B01.065.004","B01.065.007","B01.065.008","B01.067.001","B01.067.002"};
}
Static a_new_stom16_2 := {;
  {1,"2.78.54","2.78.60"},; // � ��祡��� 楫��
  {2,"2.79.59","2.79.64"},; // � ��䨫����᪮� 楫��
  {2,"2.88.46","2.88.51"},; //  -- " -- " -- " -- " -- ࠧ���� �� ������ �����������
  {3,"2.80.34","2.80.38"};  // �� �������� ���⫮���� �����
}
Static a_coord_stom18 := {;
 {{"2.78.54","2.78.55","2.79.59","2.88.46","2.80.34"},{"B01.065.001","B01.065.002","B04.065.001","B04.065.002"}},; // �࠯���
 {{"2.78.56","2.88.51","2.80.35"},{"B01.067.001","B01.067.002"}},; // ����
 {{"2.78.57","2.79.62","2.88.49"},{"B01.063.001","B01.063.002","B04.063.001"}},; // ��⮤���
 {{"2.78.58","2.79.60","2.88.47","2.80.37"},{"B01.064.003","B01.064.004","B04.064.001","B04.064.002"}},; // ���᪨�
 {{"2.78.60","2.79.63","2.88.50","2.80.38"},{"B01.065.003","B01.065.004","B04.065.003","B04.065.004"}},; // �㡭�� ���
 {{"2.79.64"},{"B01.065.005","B01.065.006"}},; // ���������
 {{"2.78.59","2.79.61","2.88.48","2.80.36"},{"B01.065.007","B01.065.008","B04.065.005","B04.065.006"}}; // ��饩 �ࠪ⨪�
}
// ��ࢨ�� ����
Static a_new_1st_stom16 := {"B01.063.001","B01.064.003","B01.065.001","B01.065.003","B01.065.005","B01.065.007","B01.067.001"}
//
Local a_stom, a_stom16_2, i, j, jm, k := 0, n := 0, lshifr, s := "", y, is_new, lshifr2 := ""
if valtype(lk_data) == "D" .and. (y := year(lk_data)) > 2015 // 2016 ���
  jm := 0 ; ret_tip := 0 ; ret_kol := 0 ; is_2_88 := .f.
  is_new := (lk_data >= 0d20160801)
  if is_new // � 1 ������ 2016 ����
    a_stom16_2 := a_new_stom16_2
  else
    a_stom16_2 := a_old_stom16_2
  endif
  for i := 1 to len(arr_usl)
    lshifr := alltrim(arr_usl[i,1])
    for j := 1 to len(a_stom16_2)
      if between_shifr(lshifr,a_stom16_2[j,2],a_stom16_2[j,3])
        lshifr2 := lshifr
        k += arr_usl[i,6] // ᪫��뢠�� ������⢮ ��� 2.*
        jm := j
        ret_tip := a_stom16_2[j,1]
        is_2_88 := (j == 3)
        ++n ; s += ' '+lshifr ; exit
      endif
    next
  next
  if n == 0
    aadd(ta,'�� ������� �㫥��� �⮬��.��㣠 (2.78.*,2.79.*,2.80.*,2.88.*)')
  elseif n > 1
    aadd(ta,'����祭�� � �⮬��.��砥 ࠧ��� ����� ���饭�� -'+s)
  elseif k != 1
    aadd(ta,'������⢮ �⮬��.��� ������ ���� =1 (2.78.*,2.79.*,2.80.*,2.88.*)')
  else
    if is_new // � 1 ������ 2016 ����
      k := 0
      for i := 1 to len(arrFusl)
        lshifr := alltrim(arrFusl[i,1])
        s := lshifr+iif(empty(arrFusl[i,5]), '', ' ('+alltrim(arrFusl[i,5])+')')
        if ascan(a_new_1st_stom16,lshifr) > 0
          ++k
        endif
        if eq_any(left(lshifr,3),"B01","B04")
          if ascan(a_new_stom16[jm],lshifr) > 0
            ret_kol += arrFusl[i,6] // ᪫��뢠�� ������⢮ ���
            if len(arrFusl[i]) > 9
              arrFusl[i,10] := 1
            endif
            if arrFusl[i,6] > 1
              aadd(ta,'� ��㣥 '+s+' ������⢮ ����� 1')
            endif
            if y > 2017 .and. !empty(lshifr2)
              for j := 1 to len(a_coord_stom18)
                if ascan(a_coord_stom18[j,2],lshifr) > 0 .and. ascan(a_coord_stom18[j,1],lshifr2) == 0
                  aadd(ta,'��祡�� ��� '+s+' �� ᮮ⢥����� ��㣥 '+lshifr2)
                endif
              next j
            endif
          else
            for j := 1 to len(a_new_stom16)
              if j == jm ; loop ; endif
              if ascan(a_new_stom16[j],lshifr) > 0
                aadd(ta,'��㣠 '+s+' �⭮���� � ��㣮�� ⨯� ���� ����')
                exit
              endif
            next
          endif
        endif
      next
      if k > 1
        aadd(ta,'��㣠 ��ࢨ筮�� �⮬�⮫����᪮�� ��� ������� ����� ������ ࠧ� � ������ ��砥')
      endif
    else
      a_stom := a_old_stom16
      for i := 1 to len(arr_usl)
        lshifr := alltrim(arr_usl[i,1])
        if ascan(a_stom[ret_tip],lshifr) > 0
          ret_kol += arr_usl[i,6] // ᪫��뢠�� ������⢮ ���
          if len(arr_usl[i]) > 9
            arr_usl[i,10] := 1
          endif
        endif
      next
    endif
  endif
else // 2015 ��� � ࠭��
  if valtype(lk_data) == "D" .and. lk_data > stod("20150630")
    a_stom := a_stom15
  else
    a_stom := a_stom14
  endif
  for i := 1 to 3
    for j := 1 to len(arr_usl)
      if (k := ascan(a_stom[i],alltrim(arr_usl[j,1]))) > 0
        ++n ; s += ' '+a_stom[i,k] ; exit
      endif
    next
  next
  if n == 0
    aadd(ta,'�� �뫮 ����� �� ������ �⮬�⮫����᪮�� ���饭��')
  elseif n > 1
    aadd(ta,'����祭�� � �⮬��.��砥 ࠧ��� ����� ���饭�� -'+s)
  endif
endif
if valtype(ret_arr) == "A"
  DEFAULT ret_tip_a TO {1,2,3}
  for i := 1 to 3
    if ascan(ret_tip_a,i) > 0
      for j := 1 to len(a_stom[i])
        aadd(ret_arr, a_stom[i,j])
      next
    endif
  next
endif
return (n == 1)

***** 11.03.14 ������� ��樮��� � 1 ��५� 2013 ����
Function f_dn_stac_01_04(lshifr)
return eq_any(left(lshifr,5),"55.5.","55.6.","55.7.","55.8.")

***** 21.02.14 �஢�ઠ, �� ��������� �� � ��ப� ����஢� ���祭��
Function mo_nodigit(s)
return !empty(CHARREPL("0123456789", s, SPACE(10)))

***** 13.04.14
Function correct_profil(lp)
if lp == 2 // �������� � �����������
  lp := 136 // �������� � ����������� (�� �᪫�祭��� �ᯮ�짮����� �ᯮ����⥫��� ९த�⨢��� �孮�����)
elseif lp == 64 // ��ਭ���ਭ�������
  lp := 162 // ��ਭ���ਭ������� (�� �᪫�祭��� ��嫥�୮� �������樨)
endif
return lp


***** 04.03.19
Function f_create_diag_srok()
dbcreate(cur_dir+"tmp_d_srok",{{"kod","N",7,0},;
                               {"tip","N",1,0},;
                               {"tips","C",3,0},;
                               {"otd","N",3,0},;
                               {"kod1","N",7,0},;
                               {"tip1","N",1,0},;
                               {"tip1s","C",3,0},;
                               {"dni","N",2,0}})
use (cur_dir+"tmp_d_srok") new alias D_SROK
return NIL

***** 24.06.20
Function f_napr_mo_lis()
  human_->(dbGoto(human->(recno())))
  return human_->NPR_MO


***** ��ᬮ�� ᯨ᪠ ॥��஢, ������ ��� �����
Function view_list_reestr()
Local i, k, buf := savescreen(), tmp_help := chm_help_code
if !G_SLock(Sreestr_sem)
  return func_error(4,Sreestr_err)
endif
Private goal_dir := dir_server+dir_XML_MO+cslash
G_Use(dir_server+"mo_xml",,"MO_XML")
G_Use(dir_server+"mo_rees",,"REES")
index on dtos(dschet)+str(nschet,6) to (cur_dir+"tmp_rees") DESCENDING
go top
if eof()
  func_error(4,"��� ॥��஢")
else
  chm_help_code := 113
  Private reg := 1
  Alpha_Browse(T_ROW,0,23,79,"f1_view_list_reestr",color0,,,,,,,;
               "f2_view_list_reestr",,{'�','�','�',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
endif
close databases
G_SUnLock(Sreestr_sem)
chm_help_code := tmp_help
restscreen(buf)
return NIL


*****
Function f1_view_list_reestr(oBrow)
Local oColumn, ;
      blk := {|| iif(hb_fileExists(goal_dir+alltrim(rees->NAME_XML)+szip), ;
                     iif(empty(rees->date_out), {3,4}, {1,2}),;
                     {5,6}) }
oColumn := TBColumnNew(" �����",{|| rees->nschet })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  ���",{|| date_8(rees->dschet) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("���-;��",;
          {|| iif(emptyany(rees->nyear,rees->nmonth), ;
                  space(5), ;
                  right(lstr(rees->nyear),2)+"/"+strzero(rees->nmonth,2)) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" �㬬� ॥���",{|| padl(expand_value(rees->summa,2),15) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" ���.; ���.", {|| str(rees->kol,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" ������������ 䠩��",{|| padr(rees->NAME_XML,22) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("�ਬ�砭��",{|| f11_view_list_reestr() })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if reg == 1
  status_key("^<Esc>^ ��室; ^<F5>^ ������ ��� �����; ^<F3>^ ���ଠ�� � ॥���; ^<F9>^ ����⨪�")
else
  status_key("^<Esc>^ - ��室;  ^<Enter>^ - �롮� ॥��� ��� ������")
endif
return NIL


*****
Static Function f11_view_list_reestr()
Local s := ""
if !hb_fileExists(goal_dir+alltrim(rees->NAME_XML)+szip)
  s := "��� 䠩��"
elseif empty(rees->date_out)
  s := "�� ����ᠭ"
else
  s := "���. "+lstr(rees->NUMB_OUT)+" ࠧ"
endif
return padr(s,10)


*****
Function f2_view_list_reestr(nKey,oBrow)
Local ret := -1, rec := rees->(recno()), tmp_color := setcolor(), r, r1, r2,;
      s, buf := savescreen(), arr, i, k, mdate, t_arr[2], arr_pmt := {}
do case
  case nKey == K_F5
    r := row()
    arr := {} ; k := 0 ; mdate := rees->dschet
    find (dtos(mdate))
    do while rees->dschet == mdate .and. !eof()
      if !emptyany(rees->name_xml,rees->kod_xml)
        aadd(arr, {rees->nschet,rees->name_xml,rees->kod_xml,rees->(recno())})
        if empty(rees->date_out)
          ++k
        endif
      endif
      skip
    enddo
    if len(arr) == 0
      func_error(4,"��祣� �����뢠��!")
    else
      if len(arr) > 1
        asort(arr,,,{|x,y| x[1] < y[1]})
        for i := 1 to len(arr)
          rees->(dbGoto(arr[i,4]))
          aadd(arr_pmt, {"������ � "+lstr(rees->nschet)+" ("+;
                         lstr(rees->nyear)+"/"+strzero(rees->nmonth,2)+;
                         ") 䠩� "+alltrim(rees->name_xml),aclone(arr[i])})
        next
        if r+2+len(arr) > maxrow()-2
          r2 := r-1
          r1 := r2-len(arr)-1
          if r1 < 0 ; r1 := 0 ; endif
        else
          r1 := r+1
        endif
        arr := {}
        if (t_arr := bit_popup(r1,10,arr_pmt,,color5,1,"�����뢠��� 䠩�� ॥��஢ ("+date_8(mdate)+")","B/W")) != NIL
          aeval(t_arr, {|x| aadd(arr,aclone(x[2])) })
        endif
        t_arr := array(2)
      endif
      if len(arr) > 0
        s := "������⢮ ॥��஢ - "+lstr(len(arr))+;
             ", �����뢠���� � ���� ࠧ - "+lstr(k)+":"
        for i := 1 to len(arr)
          if i > 1
            s += ","
          endif
          s += " "+lstr(arr[i,1])+" ("+alltrim(arr[i,2])+szip+")"
        next
        if k > 0
          f_message({"���頥� ��� ��������, �� ��᫥ ����� ॥���",;
                     "���������� �㤥� �믮����� ������� ॥���"},,"GR+/R","W+/R",2)
        endif
        perenos(t_arr,s,74)
        f_message(t_arr,,color1,color8)
        if f_Esc_Enter("����� ॥��஢ �� "+date_8(mdate))
          Private p_var_manager := "copy_schet"
          s := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,2,.f.,,,) // "norton" ��� �롮� ��⠫���
          if !empty(s)
            if upper(s) == upper(goal_dir)
              func_error(4,"�� ��ࠫ� ��⠫��, � ���஬ 㦥 ����ᠭ� 楫��� 䠩��! �� �������⨬�.")
            else
              cFileProtokol := "protrees"+stxt
              strfile(hb_eol()+center(glob_mo[_MO_SHORT_NAME],80)+hb_eol()+hb_eol(),cFileProtokol)
              smsg := "������� ����ᠭ� ��: "+s+;
                      " ("+full_date(sys_date)+"�. "+hour_min(seconds())+")"
              strfile(center(smsg,80)+hb_eol(),cFileProtokol,.t.)
              k := 0
              for i := 1 to len(arr)
                rees->(dbGoto(arr[i,4]))
                smsg := lstr(i)+". ������ � "+lstr(rees->nschet)+;
                        " �� "+date_8(mdate)+"�. (���.��ਮ� "+;
                         lstr(rees->nyear)+"/"+strzero(rees->nmonth,2)+;
                         ") "+alltrim(rees->name_xml)+szip
                strfile(hb_eol()+smsg+hb_eol(),cFileProtokol,.t.)
                smsg := "   ������⢮ ��樥�⮢ - "+lstr(rees->kol)+;
                        ", �㬬� ॥��� - "+expand_value(rees->summa,2)
                strfile(smsg+hb_eol(),cFileProtokol,.t.)
                zip_file := alltrim(arr[i,2])+szip
                if hb_fileExists(goal_dir+zip_file)
                  mywait('����஢���� "'+zip_file+'" � ��⠫�� "'+s+'"')
                  //copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
                  copy file (goal_dir+zip_file) to (s+zip_file)
                  //if hb_fileExists(hb_OemToAnsi(s)+zip_file)
                  if hb_fileExists(s+zip_file)
                    ++k
                    rees->(G_RLock(forever))
                    rees->DATE_OUT := sys_date
                    if rees->NUMB_OUT < 99
                      rees->NUMB_OUT ++
                    endif
                    //
                    mo_xml->(dbGoto(arr[i,3]))
                    mo_xml->(G_RLock(forever))
                    mo_xml->DREAD := sys_date
                    mo_xml->TREAD := hour_min(seconds())
                  else
                    smsg := "! �訡�� ����� 䠩�� "+s+zip_file
                    func_error(4,smsg)
                    strfile(smsg+hb_eol(),cFileProtokol,.t.)
                  endif
                else
                  smsg := "! �� �����㦥� 䠩� "+goal_dir+zip_file
                  func_error(4,smsg)
                  strfile(smsg+hb_eol(),cFileProtokol,.t.)
                endif
              next
              UnLock
              Commit
              viewtext(cFileProtokol,,,,.t.,,,2)
              /*asize(t_arr,1)
              perenos(t_arr,"����ᠭ� ॥��஢ - "+lstr(k)+" � ��⠫�� "+s+;
                     iif(k == len(arr), "", ", �� ����ᠭ� ॥��஢ - "+lstr(len(arr)-k)),60)
              stat_msg("������ �����襭�!")
              n_message(t_arr,,"GR+/B","W+/B",18,,"G+/B")*/
            endif
          endif
        endif
      endif
    endif
    select REES
    goto (rec)
    ret := 0
  case nKey == K_F3
    f3_view_list_reestr(oBrow)
    ret := 0
  case nKey == K_F9
    mywait()
    R_Use(dir_server+"mo_rhum",,"RHUM")
    nfile := "reesstat"+stxt ; sh := 80 ; HH := 60
    fp := fcreate(nfile) ; n_list := 1 ; tek_stroke := 0
    add_string("")
    add_string(center("����⨪� �� ॥��ࠬ",sh))
    add_string("")
    arr_title := {;
      "��������������������������������������������������������������������������������",;
      "����� �  ���  �   ������������     ����.�    �㬬�   �������볊��-�� �� ��-���",;
      "॥��� ॥��࠳   䠩�� ॥���    �����   ॥���  ��� � ���ࠡ��.� ���������",;
      "��������������������������������������������������������������������������������"}
    aeval(arr_title, {|x| add_string(x) } )
    oldy := oldm := 0
    select REES
    index on str(NYEAR,4) to (cur_dir+"tmpr1") unique
    go bottom
    Private syear := rees->NYEAR
    index on str(NYEAR,4)+str(NMONTH,2)+str(NSCHET,6) to (cur_dir+"tmpr1") for NYEAR == syear
    go top
    do while !eof()
      if verify_FF(HH-2, .t., sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      if !(oldy == rees->NYEAR .and. oldm == rees->NMONTH)
        add_string("")
        add_string(padc("������ ��ਮ� "+lstr(rees->nyear)+"/"+strzero(rees->nmonth,2),sh,"_"))
        oldy := rees->NYEAR ; oldm := rees->NMONTH
        @ maxrow(),1 say lstr(rees->nyear)+"/"+strzero(rees->nmonth,2) color cColorWait
      endif
      s := str(rees->NSCHET,6)+" "+date_8(rees->DSCHET)+" "+padr(rees->NAME_XML,20)+;
           str(rees->KOL,5)+put_kop(rees->SUMMA,13)
      select MO_XML
      index on FNAME to (cur_dir+"tmp_x2") ;
            for reestr == rees->kod .and. TIP_OUT == 0 .and. TIP_IN == _XML_FILE_SP
      kol_sp := 0 ; dbeval({|| ++kol_sp })
      select RHUM
      index on str(REES_ZAP,6) to (cur_dir+"tmp_r2") ;
            for reestr == rees->kod .and. OPLATA == 0
      kol_ne := 0 ; dbeval({|| ++kol_ne })
      s += padc(iif(kol_sp==0,"-",lstr(kol_sp)),9)
      s += padc(iif(kol_ne==0,"-",lstr(kol_ne)),13)
      s += " "+iif(kol_ne==0," =","!!!")
      add_string(s)
      select REES
      skip
    enddo
    close databases
    fclose(fp)
    keyboard chr(K_END)
    viewtext(nfile,,,,,,,2,,,.f.)
    G_Use(dir_server+"mo_xml",,"MO_XML")
    G_Use(dir_server+"mo_rees",cur_dir+"tmp_rees","REES")
    goto (rec)
    ret := 0
  case nKey == K_CTRL_F12
    ret := delete_reestr_sp_tk(rees->(recno()),alltrim(rees->NAME_XML))
    close databases
    G_Use(dir_server+"mo_xml",,"MO_XML")
    G_Use(dir_server+"mo_rees",cur_dir+"tmp_rees","REES")
    goto (rec)
endcase
setcolor(tmp_color)
restscreen(buf)
return ret


*****
Function f3_view_list_reestr(oBrow)
Static si := 1
Local i, r := row(), r1, r2, buf := save_maxrow(), ;
      mm_func := {-1,-2,-3},;
      mm_menu := {"���᮪ ~��� ��樥�⮢ � ॥���",;
                  "���᮪ ~��ࠡ�⠭��� � �����",;
                  "���᮪ ~�� ��ࠡ�⠭��� � �����"}
mywait()
select MO_XML
index on FNAME to (cur_dir+"tmp_xml") ;
      for reestr==rees->kod .and. between(TIP_IN,_XML_FILE_FLK,_XML_FILE_SP) .and. empty(TIP_OUT)
go top
do while !eof()
  aadd(mm_func, mo_xml->kod)
  aadd(mm_menu, "��⮪�� �⥭�� "+rtrim(mo_xml->FNAME)+iif(empty(mo_xml->TWORK2),"-������ �� ���������",""))
  skip
enddo
select MO_XML
set index to
if r <= 12
  r1 := r+1 ; r2 := r1+len(mm_menu)+1
else
  r2 := r-1 ; r1 := r2-len(mm_menu)-1
endif
rest_box(buf)
if (i := popup_prompt(r1,10,si,mm_menu,,,color5)) > 0
  si := i
  if mm_func[i] < 0
    f31_view_list_reestr(abs(mm_func[i]),mm_menu[i])
  else
    mo_xml->(dbGoto(mm_func[i]))
    viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+alltrim(mo_xml->FNAME)+stxt,60,80),,,,.t.,,,2)
  endif
endif
select REES
return NIL


***** 15.02.19
Function f31_view_list_reestr(reg,s)
Local fl := .t., buf := save_maxrow(), s1, lal, n_file := "reesspis"+stxt
mywait()
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("���᮪ ��樥�⮢ ॥��� � "+lstr(rees->nschet)+" �� "+date_8(rees->dschet),80))
add_string(center("( "+charrem("~",s)+" )",80))
add_string("")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, to otd into OTD
R_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
R_Use(dir_server+"mo_rhum",,"RHUM")
index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == rees->kod
go top
do while !eof()
  do case
    case reg == 1
      fl := .t.
    case reg == 2
      fl := (rhum->OPLATA > 0)
    case reg == 3
      fl := (rhum->OPLATA == 0)
  endcase
  if fl
    select HUMAN
    goto (rhum->kod_hum)
    lal := "human"
    s1 := ""
    if human->ishod == 88
      s1 := " 2�"
      select HUMAN_3
      set order to 1
      find (str(rhum->kod_hum,7))
      lal += "_3"
    elseif human->ishod == 89
      s1 := " 2�"
      select HUMAN_3
      set order to 2
      find (str(rhum->kod_hum,7))
      lal += "_3"
    endif
    s := padr(human->fio,50-len(s1))+s1+" "+otd->short_name+;
         " "+date_8(&lal.->n_data)+"-"+date_8(&lal.->k_data)
    if rhum->REES_ZAP < 10000
      s := str(rhum->REES_ZAP,4)+". "+s
    else
      s := lstr(rhum->REES_ZAP)+"."+s
    endif
    verify_FF(60,.t.,80)
    add_string(s)
  endif
  select RHUM
  skip
enddo
human_3->(dbCloseArea())
human_->(dbCloseArea())
human->(dbCloseArea())
otd->(dbCloseArea())
rhum->(dbCloseArea())
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.t.,,,2)
return NIL

***** ������ ��� �� ����ᠭ�� �� ��᪥�� ॥���
Function vozvrat_reestr()
Local i, k, buf := savescreen(), arr, tmp_help := chm_help_code, mkod_reestr

if ! hb_user_curUser:IsAdmin()
  return func_error(4,err_admin)
endif
if !G_SLock(Sreestr_sem)
  return func_error(4,Sreestr_err)
endif
Private goal_dir := dir_server+dir_XML_MO+cslash
G_Use(dir_server+"mo_rees",,"REES")
index on dtos(dschet)+str(nschet,6) to (cur_dir+"tmp_rees") DESCENDING for empty(date_out)
go top
if eof()
  func_error(4,"�� �����㦥�� ॥��஢, �� ��ࠢ������ � �����")
else
  chm_help_code := 114
  Private reg := 2
  if Alpha_Browse(T_ROW,0,23,79,"f1_view_list_reestr",color0,,,,.t.,,,,,;
                  {'�','�','�',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",,60} )
    mkod_reestr := rees->KOD
    mywait()
    G_Use(dir_server+"mo_xml",,"MO_XML")
    index on FNAME to (cur_dir+"tmp_xml") for reestr==mkod_reestr .and. TIP_OUT==0
    k := kol_err := 0
    go top
    do while !eof()
      if mo_xml->TIP_IN == _XML_FILE_SP
        ++k
      elseif mo_xml->TIP_IN == _XML_FILE_FLK
        kol_err += mo_xml->kol2
      endif
      skip
    enddo
    if k > 0
      func_error(4,"�� ������� ॥���� 㦥 �뫨 ���⠭� ॥���� �� � ��. ������ ��������!")
    elseif kol_err > 0
      func_error(4,"�� ������� ॥���� �� ���⠭ ��⮪�� ��� � �訡����. ������ ��������!")
    else
      f1vozvrat_reestr(mkod_reestr)
    endif
  endif
endif
close databases
G_SUnLock(Sreestr_sem)
chm_help_code := tmp_help
restscreen(buf)
return NIL


***** 15.02.19
Static Function f1vozvrat_reestr(mkod_reestr)
Local buf := savescreen()
close databases
G_Use(dir_server+"mo_rees",,"REES")
goto (mkod_reestr)
stat_msg("")
arr := {}
aadd(arr,"�������� ॥��� � "+lstr(rees->nschet)+" �� "+full_date(rees->dschet)+"�.")
aadd(arr,'�� ��ਮ� "'+iif(between(rees->nmonth,1,12), mm_month[rees->nmonth], lstr(rees->nmonth)+" �����")+;
         str(rees->nyear,5)+' ����".')
aadd(arr,"�㬬� ॥��� "+lput_kop(rees->summa,.t.)+;
         " ��., ������⢮ ��樥�⮢ "+lstr(rees->kol)+" 祫.")
aadd(arr,"������������ 䠩�� "+alltrim(rees->NAME_XML))
aadd(arr,"")
aadd(arr,"��᫥ ���⢥ত���� 㤠����� ��樥��� ���� ���ભ���")
aadd(arr,"�� ������� ॥���, � ॥��� �㤥� 㤠���.")
f_message(arr,,color1,color8)
if f_Esc_Enter("㤠����� ॥��� � "+lstr(rees->nschet),.t.)
  stat_msg("���⢥न� 㤠����� ��� ࠧ.") ; mybell(2)
  if f_Esc_Enter("㤠����� ॥��� � "+lstr(rees->nschet),.t.)
    mywait("����. �ந�������� 㤠����� ॥���.")
    G_Use(dir_server+"human_u_",,"HU_")
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    set relation to recno() into HU_
    G_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
    G_Use(dir_server+"human",,"HUMAN")
    G_Use(dir_server+"human_",,"HUMAN_")
    G_Use(dir_server+"mo_rhum",,"RHUM")
    index on str(reestr,6) to (cur_dir+"tmp_rhum")
    do while .t.
      select RHUM
      find (str(mkod_reestr,6))
      if !found() ; exit ; endif
      //
      select HUMAN_
      goto (rhum->KOD_HUM)
      if human_->REESTR == mkod_reestr // �� ��直� ��砩
        select HUMAN
        goto (rhum->KOD_HUM)
        if human->ishod == 88 // ᭠砫� �஢�ਬ, �� ������� �� �� ��砩 (��-��஬�)
          select HUMAN_3
          set order to 1
          find (str(human->kod,7))
          if found()
            select HUMAN_
            goto (human_3->kod2) // ����� �� 2-�� ���� ����
            select HU
            find (str(human_3->kod2,7))
            do while human_3->kod2 == hu->kod .and. !eof()
              hu_->(G_RLock(forever))
              hu_->REES_ZAP := 0
              hu_->(dbUnLock())
              select HU
              skip
            enddo
            human_->(G_RLock(forever))
            if human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM-1
            endif
            human_->REES_ZAP := 0
            human_->REESTR := 0
            human_->(dbUnLock())
            // ��ࠡ�⪠ ��������� �������� ����
            human_3->(G_RLock(forever))
            if human_3->REES_NUM > 0
              human_3->REES_NUM := human_3->REES_NUM-1
            endif
            human_3->REES_ZAP := 0
            human_3->REESTR := 0
            human_3->(dbUnLock())
          endif
          // �����頥��� � 1-�� ����� ����
          select HUMAN_
          goto (rhum->KOD_HUM)
          select HU
          find (str(rhum->KOD_HUM,7))
          do while rhum->KOD_HUM == hu->kod .and. !eof()
            hu_->(G_RLock(forever))
            hu_->REES_ZAP := 0
            hu_->(dbUnLock())
            select HU
            skip
          enddo
          human_->(G_RLock(forever))
          if human_->REES_NUM > 0
            human_->REES_NUM := human_->REES_NUM-1
          endif
          human_->REES_ZAP := 0
          human_->REESTR := 0
          human_->(dbUnLock())
        elseif human->ishod == 89 // ⥯��� �஢�ਬ, �� ������� �� �� ��砩 (��-������)
          // ᭠砫� ��ࠡ�⠥� 2-�� ��砩
          select HU
          find (str(rhum->KOD_HUM,7))
          do while rhum->KOD_HUM == hu->kod .and. !eof()
            hu_->(G_RLock(forever))
            hu_->REES_ZAP := 0
            hu_->(dbUnLock())
            select HU
            skip
          enddo
          human_->(G_RLock(forever))
          if human_->REES_NUM > 0
            human_->REES_NUM := human_->REES_NUM-1
          endif
          human_->REES_ZAP := 0
          human_->REESTR := 0
          human_->(dbUnLock())
          // ���饬 1-� ��砩
          select HUMAN_3
          set order to 2
          find (str(human->kod,7))
          if found()
            select HUMAN_
            goto (human_3->kod) // ����� �� 1-� ���� ����
            select HU
            find (str(human_3->kod2,7))
            do while human_3->kod2 == hu->kod .and. !eof()
              hu_->(G_RLock(forever))
              hu_->REES_ZAP := 0
              hu_->(dbUnLock())
              select HU
              skip
            enddo
            human_->(G_RLock(forever))
            if human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM-1
            endif
            human_->REES_ZAP := 0
            human_->REESTR := 0
            human_->(dbUnLock())
            // ��ࠡ�⪠ ��������� �������� ����
            human_3->(G_RLock(forever))
            if human_3->REES_NUM > 0
              human_3->REES_NUM := human_3->REES_NUM-1
            endif
            human_3->REES_ZAP := 0
            human_3->REESTR := 0
            human_3->(dbUnLock())
          endif
        else
          // ��ࠡ�⪠ �����୮�� ����
          select HUMAN_
          goto (rhum->KOD_HUM)
          select HU
          find (str(rhum->KOD_HUM,7))
          do while rhum->KOD_HUM == hu->kod .and. !eof()
            hu_->(G_RLock(forever))
            hu_->REES_ZAP := 0
            hu_->(dbUnLock())
            select HU
            skip
          enddo
          human_->(G_RLock(forever))
          if human_->REES_NUM > 0
            human_->REES_NUM := human_->REES_NUM-1
          endif
          human_->REES_ZAP := 0
          human_->REESTR := 0
          human_->(dbUnLock())
        endif
      endif
      //
      select RHUM
      DeleteRec(.t.)
    enddo
    zip_file := alltrim(rees->name_xml)+szip
    if hb_fileExists(goal_dir+zip_file)
      delete file (goal_dir+zip_file)
    endif
    G_Use(dir_server+"mo_xml",,"MO_XML")
    goto (rees->KOD_XML)
    if !eof() .and. !deleted()
      DeleteRec(.t.)
    endif
    select REES
    DeleteRec(.t.)
    stat_msg("������ 㤠��!") ; mybell(2,OK)
  endif
endif
close databases
restscreen(buf)
return NIL


***** 15.02.19 ���㫨஢��� �⥭�� ॥��� �� � �� �� ॥���� � ����� mkod_reestr
Function delete_reestr_sp_tk(mkod_reestr,mname_reestr)
Local i, s, r := row(), r1, r2, buf := save_maxrow(), ;
      mm_menu := {}, mm_func := {}, mm_flag := {}, mreestr_sp_tk, ;
      arr_f, cFile, oXmlDoc, aerr := {}, is_allow_delete, ;
      cFileProtokol := "tmp"+stxt, is_other_reestr, bSaveHandler,;
      arr_schet, rees_nschet := rees->nschet, mtip_in
mywait()
select MO_XML
index on FNAME to (cur_dir+"tmp_xml") for reestr==mkod_reestr .and. TIP_OUT==0
go top
do while !eof()
  if mo_xml->TIP_IN == _XML_FILE_SP
    aadd(mm_func, mo_xml->kod)
    s := "������ �� � �� "+rtrim(mo_xml->FNAME)+" ���⠭ "+date_8(mo_xml->DWORK)
    if empty(mo_xml->TWORK2)
      aadd(mm_flag,.t.)
      s += "-������� �� ��������"
    else
      aadd(mm_flag,.f.)
      s += " � "+mo_xml->TWORK1
    endif
    aadd(mm_menu,s)
  elseif mo_xml->TIP_IN == _XML_FILE_FLK
    if mo_xml->kol2 > 0
      aadd(mm_func, mo_xml->kod)
      aadd(mm_flag,.f.)
      s := "��⮪�� ��� "+rtrim(mo_xml->FNAME)+" ���⠭ "+date_8(mo_xml->DWORK)+" � "+mo_xml->TWORK1
      aadd(mm_menu,s)
    endif
  endif
  skip
enddo
select MO_XML
set index to
rest_box(buf)
if len(mm_menu) == 0
  if involved_password(1,rees_nschet,"���⢥ত���� ������ (㤠�����) ॥���")
    f1vozvrat_reestr(mkod_reestr)
  endif
  return 1
endif
if r <= 18
  r1 := r+1 ; r2 := r1+len(mm_menu)+1
else
  r2 := r-1 ; r1 := r2-len(mm_menu)-1
endif
if (i := popup_prompt(r1,10,1,mm_menu,,,color5)) > 0
  is_allow_delete := mm_flag[i]
  mreestr_sp_tk := mm_func[i]
  mywait()
  select MO_XML
  goto (mreestr_sp_tk)
  cFile := alltrim(mo_xml->FNAME)
  mtip_in := mo_xml->TIP_IN
  close databases
  if mtip_in == _XML_FILE_SP // ������ ॥��� �� � ��
    if (arr_f := Extract_Zip_XML(dir_server+dir_XML_TF,cFile+szip)) != NIL .and. mo_Lock_Task(X_OMS)
      cFile += sxml
      // �⠥� 䠩� � ������
      oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
      if oXmlDoc == NIL .or. Empty( oXmlDoc:aItems )
        func_error(4,"�訡�� � �⥭�� 䠩�� "+cFile)
      else // �⠥� � �����뢠�� XML-䠩� �� �६���� TMP-䠩��
        reestr_sp_tk_tmpfile(oXmlDoc,aerr,cFile)
        if !empty(aerr)
          Ins_Array(aerr,1,"")
          Ins_Array(aerr,1,center("�訡�� � �⥭�� 䠩�� "+cFile,80))
          aeval(aerr,{|x| strfile(x+hb_eol(),cFileProtokol,.t.) })
          viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,2)
          delete file (cFileProtokol)
        else
          // �᫨ �筮 ����� � ��㣮� ॥���
          is_other_reestr := is_delete_human := .f.
          R_Use(dir_server+"human",,"HUMAN")
          R_Use(dir_server+"human_",,"HUMAN_")
          R_Use(dir_server+"mo_rhum",,"RHUM")
          index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
          select TMP2
          go top
          do while !eof()
            select RHUM
            find (str(tmp2->_N_ZAP,6))
            if found()
              tmp2->kod_human := rhum->KOD_HUM
              select HUMAN
              goto (rhum->KOD_HUM)
              if emptyany(human->kod,human->fio)
                is_delete_human := .t. ; exit
              endif
              select HUMAN_
              goto (rhum->KOD_HUM)
              if human_->REESTR > 0 .and. human_->REESTR != mkod_reestr
                is_other_reestr := .t. ; exit
              endif
            endif
            select TMP2
            skip
          enddo
          if !is_other_reestr .and. !is_delete_human
            // �᫨ ����� � ��㣮� ॥���, ������ � �訡���, � ��।���஢��
            R_Use(dir_server+"mo_rees",,"REES")
            select RHUM
            set relation to reestr into REES
            // ����㥬 ��樥�⮢ �� ��� ��������� � ॥����
            index on str(kod_hum,7)+dtos(rees->DSCHET) to (cur_dir+"tmp_rhum")
            select TMP2
            go top
            do while !eof()
              r := r1 := 0
              select RHUM
              find (str(tmp2->kod_human,7))
              do while tmp2->kod_human == rhum->KOD_HUM
                ++r // �� ᪮�쪮 ॥��஢ �����
                if rhum->reestr == mkod_reestr
                  r1 := r // ����� �� ������ ⥪�騩 ॥���
                endif
                skip
              enddo
              if r1 > 0 .and. r > r1  // �᫨ ⥪�騩 ॥��� �� ��᫥����
                is_other_reestr := .t. ; exit
              endif
              select TMP2
              skip
            enddo
          endif
          if is_delete_human
            func_error(10,"������� ��樥��� �� ������� ॥��� 㦥 �������. ������ ����饭�!")
          elseif is_other_reestr
            func_error(10,"��樥��� �� ������� ॥��� 㦥 ������ � ������ ������. ������ ����饭�!")
          else
            if !is_allow_delete .and. involved_password(1,rees_nschet,"���㫨஢���� �⥭�� ॥��� �� � ��")
              is_allow_delete := .t.
            endif
            if is_allow_delete
              close databases
              arr_schet := {}
              R_Use(dir_server+"schet_",,"SCH")
              index on nschet to (cur_dir+"tmp_sch") for XML_REESTR == mreestr_sp_tk
              dbeval({|| aadd(arr_schet,{alltrim(nschet),recno(),KOD_XML}) })
              sch->(dbCloseArea())
              is_allow_delete := .f.
              G_Use(dir_server+"mo_rees",,"REES")
              goto (mkod_reestr)
              use (cur_dir+"tmp1file") new alias TMP1
              use (cur_dir+"tmp2file") new alias TMP2
              arr := {}
              aadd(arr,"������ � "+lstr(rees->nschet)+" �� "+full_date(rees->dschet)+"�.")
              aadd(arr,'��ਮ� "'+lstr(rees->nmonth)+"/"+lstr(rees->nyear)+;
                       '", �㬬� '+lput_kop(rees->summa,.t.)+;
                       " ��., ���-�� ��樥�⮢ "+lstr(rees->kol)+" 祫.")
              aadd(arr,"")
              aadd(arr,"���㫨����� ॥��� �� � �� � "+alltrim(tmp1->_NSCHET)+" �� "+full_date(tmp1->_dschet)+"�.")
              aadd(arr,"���-�� ��樥�⮢ "+lstr(tmp2->(lastrec()))+" 祫. (䠩� "+Name_Without_Ext(cFile)+")")
              if len(arr_schet) > 0
                aadd(arr,"������⢮ 㤠�塞�� ��⮢ - "+lstr(len(arr_schet))+" ��.")
              endif
              aadd(arr,"��᫥ ���⢥ত���� ���㫨஢���� �� ��᫥��⢨� �⥭�� �������")
              aadd(arr,"॥��� �� � ��, � ⠪�� ᠬ ॥��� �� � ��, ���� 㤠����.")
              f_message(arr,,cColorSt2Msg,cColorSt1Msg)
              s := "���⢥न� ���㫨஢���� ॥��� �� � ��"
              stat_msg(s) ; mybell(1)
              if f_Esc_Enter("���㫨஢����",.t.)
                stat_msg(s+" ��� ࠧ.") ; mybell(3)
                if f_Esc_Enter("���㫨஢����",.t.)
                  mywait()
                  is_allow_delete := .t.
                endif
              endif
            endif
            // ��२������㥬 ������� 䠩��
            if is_allow_delete
              Private fl_open := .t.
              bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
              BEGIN SEQUENCE
                index_base("schet") // ��� ��⠢����� ��⮢
                index_base("human") // ��� ࠧ��᪨ ��⮢
                index_base("mo_refr")  // ��� ����� ��稭 �⪠���
                index_base("human_3")  // ��� ������� ��砥�
              RECOVER USING error
                is_allow_delete := func_error(10,"�������� ���।�������� �訡�� �� ��२�����஢����!")
              END
              ERRORBLOCK(bSaveHandler)
            endif
            // ���㫨�㥬 ��᫥��⢨� �⥭�� ॥��� �� � ��
            if is_allow_delete
              close databases
              use_base("schet")
              set relation to
              G_Use(dir_server+"schetd",,"SD")
              index on str(kod,6) to (cur_dir+"tmp_sd")
              G_Use(dir_server+"mo_xml",,"MO_XML")
              G_Use(dir_server+"mo_refr",dir_server+"mo_refr","REFR")
              G_Use(dir_server+"mo_rhum",,"RHUM")
              index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
              G_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
              use_base("human")
              set order to 0
              use (cur_dir+"tmp2file") new alias TMP2
              go top
              do while !eof()
                select RHUM
                find (str(tmp2->_N_ZAP,6))
                G_RLock(forever)
                rhum->OPLATA := 0
                select HUMAN
                goto (tmp2->kod_human)
                if human->ishod == 88  // ᭠砫� �஢�ਬ, �� ������� �� �� ��砩 (��-��஬�)
                  select HUMAN_3
                  set order to 1
                  find (str(tmp2->kod_human,7))
                  if found()
                    select HUMAN
                    goto (human_3->kod2)  // ��⠫� �� 2-�� ���� ����
                    human->(G_RLock(forever))
                    human->schet := 0 ; human->tip_h := B_STANDART
                    human_->(G_RLock(forever))
                    if human_->schet_zap > 0
                      if human_->SCHET_NUM > 0
                        human_->SCHET_NUM := human_->SCHET_NUM-1
                      endif
                      human_->schet_zap := 0
                    endif
                    human_->OPLATA := 0
                    human_->REESTR := mkod_reestr
                    UnLock
                    // ���⪠ ��������� �������� ����
                    human_3->(G_RLock(forever))
                    human_3->schet := 0
                    if human_3->schet_zap > 0
                      if human_3->SCHET_NUM > 0
                        human_3->SCHET_NUM := human_3->SCHET_NUM - 1
                      endif
                      human_3->schet_zap := 0
                    endif
                    human_3->OPLATA := 0
                    human_3->REESTR := mkod_reestr
                  endif
                  // �����頥��� � 1-�� ����� ����
                  select HUMAN
                  goto (tmp2->kod_human)
                  human->(G_RLock(forever))
                  human->schet := 0 ; human->tip_h := B_STANDART
                  human_->(G_RLock(forever))
                  if human_->schet_zap > 0
                    if human_->SCHET_NUM > 0
                      human_->SCHET_NUM := human_->SCHET_NUM-1
                    endif
                    human_->schet_zap := 0
                  endif
                  human_->OPLATA := 0
                  human_->REESTR := mkod_reestr
                  UnLock
                elseif human->ishod == 89 // ⥯��� �஢�ਬ, �� ������� �� �� ��砩 (��-������)
                  // ᭠砫� ��ࠡ�⠥� 2-�� ��砩
                  human->(G_RLock(forever))
                  human->schet := 0 ; human->tip_h := B_STANDART
                  human_->(G_RLock(forever))
                  if human_->schet_zap > 0
                    if human_->SCHET_NUM > 0
                      human_->SCHET_NUM := human_->SCHET_NUM-1
                    endif
                    human_->schet_zap := 0
                  endif
                  human_->OPLATA := 0
                  human_->REESTR := mkod_reestr
                  UnLock
                  // ���饬 1-� ��砩
                  select HUMAN_3
                  set order to 2
                  find (str(human->kod,7))
                  if found() // ��諨 ������� ��砩
                    select HUMAN
                    goto (human_3->kod) // ����� �� 1-� ���� ����
                    human->(G_RLock(forever))
                    human->schet := 0 ; human->tip_h := B_STANDART
                    human_->(G_RLock(forever))
                    if human_->schet_zap > 0
                      if human_->SCHET_NUM > 0
                        human_->SCHET_NUM := human_->SCHET_NUM-1
                      endif
                      human_->schet_zap := 0
                    endif
                    human_->OPLATA := 0
                    human_->REESTR := mkod_reestr
                    UnLock
                    // ���⪠ ��������� �������� ����
                    human_3->(G_RLock(forever))
                    human_3->schet := 0
                    if human_3->schet_zap > 0
                      if human_3->SCHET_NUM > 0
                        human_3->SCHET_NUM := human_3->SCHET_NUM - 1
                      endif
                      human_3->schet_zap := 0
                    endif
                    human_3->OPLATA := 0
                    human_3->REESTR := mkod_reestr
                  endif
                else
                  // ��ࠡ�⪠ �����୮�� ����
                  select HUMAN
                  goto (tmp2->kod_human)
                  human->(G_RLock(forever))
                  human->schet := 0 ; human->tip_h := B_STANDART
                  human_->(G_RLock(forever))
                  if human_->schet_zap > 0
                    if human_->SCHET_NUM > 0
                      human_->SCHET_NUM := human_->SCHET_NUM-1
                    endif
                    human_->schet_zap := 0
                  endif
                  human_->OPLATA := 0
                  human_->REESTR := mkod_reestr
                  UnLock
                endif
                select REFR
                do while .t.
                  find (str(1,1)+str(mkod_reestr,6)+str(1,1)+str(tmp2->kod_human,8))
                  if !found() ; exit ; endif
                  DeleteRec(.t.)
                enddo
                select TMP2
                skip
              enddo
              for i := 1 to len(arr_schet)
                //
                select SD
                find (str(arr_schet[i,2],6))
                if found()
                  DeleteRec(.t.)
                endif
                //
                select SCHET_
                goto (arr_schet[i,2])
                DeleteRec(.t.,.f.)  // ��� ����⪨ �� 㤠�����
                //
                select SCHET
                goto (arr_schet[i,2])
                DeleteRec(.t.)
                //
                if arr_schet[i,3] > 0
                  select MO_XML
                  goto (arr_schet[i,3])
                  if !empty(mo_xml->FNAME)
                    s := dir_server+dir_XML_MO+cslash+alltrim(mo_xml->FNAME)+szip
                    if hb_fileExists(s)
                      delete file (s)
                    endif
                  endif
                  DeleteRec(.t.)
                endif
              next
              select MO_XML
              goto (mreestr_sp_tk)
              DeleteRec()
              close databases
              stat_msg("������ �� � �� �ᯥ譮 ���㫨஢��. ����� ������ ��� ࠧ.") ; mybell(5)
            endif
          endif
        endif
      endif
      mo_UnLock_Task(X_OMS)
    endif
  elseif mTIP_IN == _XML_FILE_FLK // ������ ��⮪��� ���
    if (arr_f := Extract_Zip_XML(dir_server+dir_XML_TF,cFile+szip)) != NIL .and. mo_Lock_Task(X_OMS)
      cFile += sxml
      // �⠥� 䠩� � ������
      oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
      if oXmlDoc == NIL .or. Empty( oXmlDoc:aItems )
        func_error(4,"�訡�� � �⥭�� 䠩�� "+cFile)
      else // �⠥� � �����뢠�� XML-䠩� �� �६���� TMP-䠩��
        is_err_FLK := protokol_flk_tmpfile(arr_f,aerr)
        close databases
        if empty(aerr) .and. !extract_reestr(mkod_reestr,mname_reestr)
          aadd(aerr,"�� ������ ZIP-��娢 � �������� "+mname_reestr)
          aadd(aerr,"��� ������� ��娢� ���쭥��� ࠡ�� ����������!")
        endif
        if !empty(aerr)
          Ins_Array(aerr,1,"")
          Ins_Array(aerr,1,center("�訡�� � �⥭�� 䠩�� "+cFile,80))
          aeval(aerr,{|x| strfile(x+hb_eol(),cFileProtokol,.t.) })
          viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,2)
          delete file (cFileProtokol)
        else
          // �᫨ �筮 ����� � ��㣮� ॥���
          is_other_reestr := is_delete_human := .f.
          use (cur_dir+"tmp1file") new alias TMP1
          use (cur_dir+"tmp2file") new alias TMP2
          index on str(tip,1)+str(oshib,3)+soshib to (cur_dir+"tmp2")
          use (cur_dir+"tmp_r_t1") new alias T1
          index on upper(ID_PAC) to (cur_dir+"tmp_r_t1")
          use (cur_dir+"tmp_r_t2") new alias T2
          use (cur_dir+"tmp_r_t3") new alias T3
          use (cur_dir+"tmp_r_t4") new alias T4
          // ��������� ���� "N_ZAP" � 䠩�� "tmp2"
          fill_tmp2_file_flk()
          R_Use(dir_server+"human",,"HUMAN")
          R_Use(dir_server+"human_",,"HUMAN_")
          R_Use(dir_server+"mo_rhum",,"RHUM")
          index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
          select TMP2
          go top
          do while !eof()
            if !empty(tmp2->BAS_EL) .and. !empty(tmp2->ID_BAS) .and. !empty(tmp2->N_ZAP)
              select RHUM
              find (str(tmp2->N_ZAP,6))
              if found()
                tmp2->kod_human := rhum->KOD_HUM
                select HUMAN
                goto (rhum->KOD_HUM)
                if emptyany(human->kod,human->fio)
                  is_delete_human := .t. ; exit
                endif
                select HUMAN_
                goto (rhum->KOD_HUM)
                if human_->REESTR > 0 .and. human_->REESTR != mkod_reestr
                  is_other_reestr := .t. ; exit
                endif
              endif
            endif
            select TMP2
            skip
          enddo
          if !is_other_reestr .and. !is_delete_human
            // �᫨ ����� � ��㣮� ॥���, ������ � �訡���, � ��।���஢��
            R_Use(dir_server+"mo_rees",,"REES")
            select RHUM
            set relation to reestr into REES
            // ����㥬 ��樥�⮢ �� ��� ��������� � ॥����
            index on str(kod_hum,7)+dtos(rees->DSCHET) to (cur_dir+"tmp_rhum")
            select TMP2
            go top
            do while !eof()
              r := r1 := 0
              select RHUM
              find (str(tmp2->kod_human,7))
              do while tmp2->kod_human == rhum->KOD_HUM
                ++r // �� ᪮�쪮 ॥��஢ �����
                if rhum->reestr == mkod_reestr
                  r1 := r // ����� �� ������ ⥪�騩 ॥���
                endif
                skip
              enddo
              if r1 > 0 .and. r > r1  // �᫨ ⥪�騩 ॥��� �� ��᫥����
                is_other_reestr := .t. ; exit
              endif
              select TMP2
              skip
            enddo
          endif
          if is_delete_human
            func_error(10,"������� ��樥��� �� ������� ॥��� 㦥 �������. ������ ����饭�!")
          elseif is_other_reestr
            func_error(10,"��樥��� �� ������� ॥��� 㦥 ������ � ������ ������. ������ ����饭�!")
          else
            if !is_allow_delete .and. involved_password(1,rees_nschet,"���㫨஢���� �⥭�� ��⮪��� ���")
              is_allow_delete := .t.
            endif
            if is_allow_delete
              close databases
              is_allow_delete := .f.
              R_Use(dir_server+"mo_rees",,"REES")
              goto (mkod_reestr)
              use (cur_dir+"tmp1file") new alias TMP1
              use (cur_dir+"tmp2file") new alias TMP2
              arr := {}
              aadd(arr,"������ � "+lstr(rees->nschet)+" �� "+full_date(rees->dschet)+"�.")
              aadd(arr,'��ਮ� "'+lstr(rees->nmonth)+"/"+lstr(rees->nyear)+;
                       '", �㬬� '+lput_kop(rees->summa,.t.)+;
                       " ��., ���-�� ��樥�⮢ "+lstr(rees->kol)+" 祫.")
              aadd(arr,"")
              aadd(arr,"���㫨����� �⥭�� ��⮪��� ��� � "+alltrim(tmp1->FNAME))
              aadd(arr,"���-�� ��樥�⮢ � �訡��� "+lstr(tmp2->(lastrec()))+" 祫.")
              aadd(arr,"��᫥ ���⢥ত���� ���㫨஢���� �� ��᫥��⢨� �⥭��")
              aadd(arr,"������� ��⮪��� ���, � ⠪�� ᠬ ��⮪��, ���� 㤠����.")
              f_message(arr,,cColorSt2Msg,cColorSt1Msg)
              s := "���⢥न� ���㫨஢���� �⥭�� ��⮪��� ���"
              stat_msg(s) ; mybell(1)
              if f_Esc_Enter("���㫨஢����",.t.)
                stat_msg(s+" ��� ࠧ.") ; mybell(3)
                if f_Esc_Enter("���㫨஢����",.t.)
                  mywait()
                  is_allow_delete := .t.
                endif
              endif
            endif
            // ���㫨�㥬 ��᫥��⢨� �⥭�� ॥��� ���
            if is_allow_delete
              close databases
              G_Use(dir_server+"mo_xml",,"MO_XML")
              G_Use(dir_server+"mo_rhum",,"RHUM")
              index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
              G_Use(dir_server+"human_",,"HUMAN_")
              use (cur_dir+"tmp2file") new alias TMP2
              set relation to kod_human into HUMAN_
              go top
              do while !eof()
                select RHUM
                find (str(tmp2->N_ZAP,6))
                G_RLock(forever)
                rhum->OPLATA := 0
                select HUMAN_
                G_RLock(forever)
                human_->OPLATA := 0
                human_->REESTR := mkod_reestr
                UnLock
                select TMP2
                skip
              enddo
              select MO_XML
              goto (mreestr_sp_tk)
              DeleteRec()
              close databases
              stat_msg("��⮪�� ��� �ᯥ譮 ���㫨஢��.") ; mybell(5)
            endif
          endif
        endif
      endif
      mo_UnLock_Task(X_OMS)
    endif
  endif
endif
rest_box(buf)
return 0
