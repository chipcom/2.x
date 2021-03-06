***** mo_func2.prg
#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 14.02.17 ������ ��� ��� �� ������������ 䠩�� ��� (�.�. 祩 ���)
Function ret_owner_rak(fname)
return padr(BeforAtNum("M",substr(fname,3),1),5)

***** 09.02.15 �饬 � ���ᨢ� (1-� ��ࠬ���) �� �宦����� � 2-�� ��ࠬ��� � �.�.
Function eq_ascan( ... )
Local fl := .f., i, arr := hb_aParams()
if len(arr) > 1 .and. valtype(arr[1]) == "A"
  for i := 2 to len(arr) // ��稭�� � ��ண� ��ࠬ���
    if ascan(arr[1],arr[i]) > 0 // �஢��塞 �宦����� � ���ᨢ
      fl := .t. ; exit
    endif
  next
endif
return fl

***** 06.04.15 ᤥ���� ���񭭮� ����, �᫨ ��⨩ ��ࠬ��� ����� 0
Function mo_cut_menu(old_menu)
Local i, new_menu := {}
for i := 1 to len(old_menu)
  if old_menu[i,3] > 0
    aadd(new_menu, aclone(old_menu[i]))
  endif
next
return new_menu

***** 22.09.15 ������ ����-� ������ ���� �� ���-��
Function ret_koef_from_RAK(lkod)
Local koef := 1, k := 0 // �� 㬮�砭�� ����祭, �᫨ ���� ��� ����
if select("RAKSH") == 0
  R_Use(dir_server+"mo_raksh",,"RAKSH")
  index on str(kod_h,7) to (cur_dir+"tmp_raksh")
endif
select RAKSH
find (str(lkod,7))
do while lkod == raksh->kod_h .and. !eof()
  k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
  skip
enddo
if !empty(round(k,2))
  k := human->cena_1 - k
  if human->cena_1 > 0
    koef := k/human->cena_1
  endif
endif
return koef

***** 24.04.13 ������ ���������� ���
Function ret_actual_smo(r,c)
Static si := 34007
Local i, arr := {}, ret, ret_arr
DEFAULT r TO T_ROW, c TO T_COL-5
for i := 1 to len(glob_arr_smo)
  if glob_arr_smo[i,3] == 1
    aadd(arr,glob_arr_smo[i])
  endif
next
if popup_2array(arr,r,c,si,1,@ret_arr) > 0 .and. valtype(ret_arr) == "A"
  ret := array(2)
  si := ret_arr[2]
  ret[1] := padr(lstr(ret_arr[2]),5)
  ret[2] := ret_arr[1]
endif
return ret

***** ������ 㭨���쭮� ���祭�� CODE (N8) ��� XML-䠩���
Function ret_unique_code(_kod,nlen)
Static strValid := "0123456789"
Local i, n, s := ""
DEFAULT nlen TO 8
for i := 1 To nlen
  n := random()+mem_beg_rees // ���ࠢ�� �� ��砫�� ����� ॥���
  s += substr(strValid, n%10 + 1, 1) // �� ����ਨ�� GUID
next
s += lstr(_kod) // ������� � ��ப� ��� �����
do while len(s) > nlen
  s := substr(s,2)  // �� ��直� ��砩 ᤥ���� �� ����� nlen ᨬ�����
enddo
return val(s)

***** 12.07.20 ��।����� ��� ���� ��㤮ᯮᮡ���� ������
Function f_starshe_trudosp(_pol,_date_r,_data,par)
Local v
DEFAULT par TO 1
if par == 1
  v := iif(_pol=="�", 60, 55) // ��� ����
else
  v := iif(_pol=="�", 65, 60) // ��� �����
endif
return count_years(_date_r,_data) >= v

***** 02.01.21
Function arr_plan_zakaz(ly)
Local i, apz := {}
DEFAULT ly TO 2021
if ly > 2020
  for i := 1 to len(glob_array_PZ_21)
    aadd(apz,{glob_array_PZ_21[i,3],;
              glob_array_PZ_21[i,1],;
              0,;
              glob_array_PZ_21[i,6],;
              glob_array_PZ_21[i,5],;
              {};
             } )
  next
elseif ly == 2020
  for i := 1 to len(glob_array_PZ_20)
    aadd(apz,{glob_array_PZ_20[i,3],;
              glob_array_PZ_20[i,1],;
              0,;
              glob_array_PZ_20[i,6],;
              glob_array_PZ_20[i,5],;
              {};
             } )
  next
elseif ly == 2019
  for i := 1 to len(glob_array_PZ_19)
    aadd(apz,{glob_array_PZ_19[i,3],;
              glob_array_PZ_19[i,1],;
              0,;
              glob_array_PZ_19[i,6],;
              glob_array_PZ_19[i,5],;
              {};
             } )
  next
else
  for i := 1 to len(glob_array_PZ_18)
    aadd(apz,{glob_array_PZ_18[i,3],;
              glob_array_PZ_18[i,1],;
              0,;
              glob_array_PZ_18[i,6],;
              glob_array_PZ_18[i,5],;
              {};
             } )
  next
endif
return apz

***** 02.01.21 �� ���� ��㣨 ������ ����� ������� ���ᨢ� "arr_plan_zakaz" ��� 2020 ����
Function f_arr_plan_zakaz_21(lshifr)
Local i, j, c, k := 0, shb, i16 := 0
if select("LUSL") == 0
  Use_base("lusl")
endif
select LUSL
find (padr(lshifr,10))
if found() .and. !empty(lusl->unit_code)
  if select("MOUNIT") == 0
    R_Use(dir_exe+"_mo1unit",cur_dir+"_mo1unit","MOUNIT")
  endif
  select MOUNIT
  set order to 1
  find (str(lusl->unit_code,3))
  if found() .and. mounit->pz > 0
    k := mounit->pz
    i16 := mounit->ii
  endif
endif
if k > 0 .and. empty(i16)
  i16 := ascan(glob_array_PZ_21, {|x| x[1] == k })
endif
return i16

***** 02.01.21 �� ���� ��㣨 ������ ����� ������� ���ᨢ� "arr_plan_zakaz" ��� 2020 ����
Function f_arr_plan_zakaz_20(lshifr)
Local i, j, c, k := 0, shb, i16 := 0
if select("LUSL") == 0
  Use_base("lusl")
endif
select LUSL20
find (padr(lshifr,10))
if found() .and. !empty(lusl20->unit_code)
  if select("MOUNIT20") == 0
    R_Use(dir_exe+"_mo0unit",cur_dir+"_mo0unit","MOUNIT20")
  endif
  select MOUNIT20
  set order to 1
  find (str(lusl20->unit_code,3))
  if found() .and. mounit20->pz > 0
    k := mounit20->pz
    i16 := mounit20->ii
  endif
endif
if k > 0 .and. empty(i16)
  i16 := ascan(glob_array_PZ_20, {|x| x[1] == k })
endif
return i16

***** 02.01.19 �� ���� ��㣨 ������ ����� ������� ���ᨢ� "arr_plan_zakaz" ��� 2019 ����
Function f_arr_plan_zakaz_19(lshifr)
Local i, j, c, k := 0, shb, i16 := 0
if select("LUSL") == 0
  Use_base("lusl")
endif
select LUSL19
find (padr(lshifr,10))
if found() .and. !empty(lusl19->unit_code)
  if select("MOUNIT19") == 0
    R_Use(dir_exe+"_mo9unit",cur_dir+"_mo9unit","MOUNIT19")
  endif
  select MOUNIT19
  set order to 1
  find (str(lusl19->unit_code,3))
  if found() .and. mounit19->pz > 0
    k := mounit19->pz
    i16 := mounit19->ii
  endif
endif
if k > 0 .and. empty(i16)
  i16 := ascan(glob_array_PZ_19, {|x| x[1] == k })
endif
return i16

***** 04.02.18 �� ���� ��㣨 ������ ����� ������� ���ᨢ� "arr_plan_zakaz" ��� 2018 ����
Function f_arr_plan_zakaz_18(lshifr)
Local i, j, c, k := 0, shb, i16 := 0
if select("LUSL") == 0
  Use_base("lusl")
endif
select LUSL18
find (padr(lshifr,10))
if found() .and. !empty(lusl18->unit_code)
  if select("MOUNIT18") == 0
    R_Use(dir_exe+"_mo8unit",cur_dir+"_mo8unit","MOUNIT18")
  endif
  select MOUNIT18
  set order to 1
  find (str(lusl18->unit_code,3))
  if found() .and. mounit18->pz > 0
    k := mounit18->pz
    i16 := mounit18->ii
  endif
endif
if k > 0 .and. empty(i16)
  i16 := ascan(glob_array_PZ_18, {|x| x[1] == k })
endif
return i16

/***** 19.04.15
Function arr_plan_zakaz(fl)
Local i, apz := {}
DEFAULT fl TO .f.
aadd(apz,{"���砩 ��ᯨ⠫���樨",         0,0,{}})
aadd(apz,{"���饭��",                    32,0,{"2.78.*","2.89.*"}})
aadd(apz,{"���饭�� ���⫮����",         31,0,{"2.80.*","2.82.*"}})
aadd(apz,{"���饭�� ��䨫����᪮�",   30,0,{"2.76.*","2.79.*","2.81.*","2.88.*"}})
if fl // ��뢠�� �� ����-������, �⮡� �뤥���� 業��� ���஢��
  i := len(apz)
  del_array(apz[i,4],1) // 㤠�塞 2.76.*
  aadd(apz,{"���饭�� ����� ���஢��",  35,0,{"2.76.*"}})
endif
aadd(apz,{"���饭�� �� ��ᯠ��ਧ�樨",34,0,{"2.3.*","2.83.*","2.84.*","2.85.*","2.86.*","2.87.*"}})
aadd(apz,{"��� �⮬�⮫����",              5,0,{"57.*"}})
aadd(apz,{"��樥��-����",                 2,0,{"55.1.*","55.2.*","55.3.*","55.4.*"}})
aadd(apz,{"����������",                   28,0,{"60.2.9"}})
aadd(apz,{"�-��᫥�������",               33,0,{"4.20.702","4.15.746","60.2.1","60.2.2","60.2.3","60.2.4","60.2.6","60.2.7","60.2.8"}})
if fl // ��뢠�� �� ����-������, �⮡� �뤥���� ��������� �⮫����
  i := len(apz)
  del_array(apz[i,4],1) // 㤠�塞 "4.20.702"
  del_array(apz[i,4],1) // 㤠�塞 "4.15.746"
  aadd(apz,{"�������� ��᫥�������",  36,0,{"4.20.702","4.15.746"}})
endif
aadd(apz,{"�맮� ���",                    26,0,{"71.*"}})
//aadd(apz,{"���砩 � ������� ��樮���",  99,0,{}})
return apz*/

***** 26.02.13
Function f14tf_array()
Static arr_name := {;
  "������⢮ ���㫠�୮-����������᪨� ���饭��",; // 1
  "������⢮ �����-����",;                            // 2
  "������⢮ ���� ��祭�� � ������� ��樮��� �� ��樮���",;  // 3
  "������⢮ ���� ��祭�� � ������� ��樮��� �� �����������",; // 4
  "������⢮ ���� ��祭�� � ��樮��� �� ����",;                 // 5
  "������⢮ �⮬�⮫����᪨� ���饭��",; // 6
  "������⢮ �⤥���� ����樭᪨� ���",; // 7
  "������⢮ �맮��� ᪮ன ����樭᪮� �����",; // 8
  "������⢮ ��祡��� ���",;        // 9
  "������⢮ ��⮤����᪨� ���",; // 10
  "��㣨, �� ��襤訥 � 14-� ���"}
return arr_name

***** 24.02.21
Function f14tf_nastr(/*@*/lshifr,/*@*/lname,lyear)
Static a_usl, a_zak_sl, syear
Local ta := {}, i, j, k, i14 := 0, arr, shb, fl := .f., fl1 := .f., ret := {}
if type("apz2016") == "A" .and. !empty(apz2016)
  if type("is_2021") == "L" .and. is_2021
    i14 := f_arr_plan_zakaz_21(lshifr)
  elseif type("is_2020") == "L" .and. is_2020
    i14 := f_arr_plan_zakaz_20(lshifr)
  elseif type("is_2019") == "L" .and. is_2019
    i14 := f_arr_plan_zakaz_19(lshifr)
  else
    i14 := f_arr_plan_zakaz_18(lshifr)
  endif
endif
if a_usl == NIL .or. syear != lyear
  a_usl := array(10,2)
  // ��祡�� �ਥ��
  a_usl[1,1] := {"2.*","70.*","72.*"}
  a_usl[1,2] := {"2.4.*",;
                 "2.78.47","2.78.48","2.78.49","2.78.50","2.78.51","2.78.52","2.78.53",;
                 "2.79.52","2.79.53","2.79.54","2.79.55","2.79.56","2.79.57","2.79.58",;
                 "2.88.40","2.88.41","2.88.42","2.88.43","2.88.44","2.88.45",;
                 "2.80.29","2.80.30","2.80.31","2.80.32","2.80.33"}
  // �����-���
  a_usl[2,1] := {"1.*"} // ����砥�� ��㣨
  // a_usl[2,2] := {"1.12.*","1.13.*","1.14.*","1.15.*","1.16.*","1.17.*","1.18.*"} // �᪫�砥�� ��㣨 07.02.21
  a_usl[2,2] := {"1.12.*","1.13.*","1.14.*","1.15.*","1.16.*","1.17.*","1.18.*","1.20.*"} // �᪫�砥�� ��㣨 07.02.21
  // ������� ��樮��� �� ��樮���
  a_usl[3,1] := {"55.1.1","55.1.4","55.1.5","55.2.*","55.5.*","55.8.*","60.2.9"}
  a_usl[3,2] := {}
  // ������� ��樮��� �� �����������
  a_usl[4,1] := {"55.1.2","55.3.*","55.6.*"}
  a_usl[4,2] := {}
  // ������� ��樮��� �� ����
  a_usl[5,1] := {"55.1.3","55.4.*","55.7.*"}
  a_usl[5,2] := {}
  // �⮬��.��祡�� �ਥ��
  a_usl[6,1] := {}
  f_vid_p_stom({},{},a_usl[6,1]) // ������� �� ���� �⮬�⮫����᪨� ����
  a_usl[6,2] := {}
  // �⤥��� ����樭᪨� ��㣨
  a_usl[7,1] := {"4.20.702","4.15.746","4.17.777","4.11.738","4.11.739","4.11.740","4.8.804",;
                 "4.12.7*","4.12.8*","4.12.9*","4.13.7*","4.15.7*","4.16.7*","4.17.7*","4.27.1",;
                 "60.*"}
  a_usl[7,2] := {"60.2.9"}
  // ���
  a_usl[8,1] := {"71.*"}
  a_usl[8,2] := {}
  // ��祡�� ���
  a_usl[9,1] := {"57.1.*","57.2.*","57.3.*","57.5.*"}
  a_usl[9,2] := {"57.1.4","57.1.32","57.1.33"}
  // ��⮤����᪨� ���
  a_usl[10,1] := {"57.1.4","57.1.32","57.1.33","57.4.*"}
  a_usl[10,2] := {}
endif
lshifr := alltrim(lshifr)
if select("LUSL") == 0
  Use_base("lusl")
endif
select LUSL
find (padr(lshifr,10))
if found()
  lname := lusl->name  // ������������ ��㣨 �� �ࠢ�筨�� �����
endif
if lyear == 2021
  if is_ksg(lshifr,1) .or. left(lshifr,5) == "1.20."  // 07.02.21
    return {{2,-1,i14}}
  elseif is_ksg(lshifr,2) // ��� �������� ��樮���
    return {{3,-1,i14}}
  endif
else
  if is_ksg(lshifr,1) .or. left(lshifr,5) == "1.12."
    return {{2,-1,i14}}
  elseif is_ksg(lshifr,2) // ��� �������� ��樮���
    return {{3,-1,i14}}
  endif
endif
// ����砥�� ��㣨
for j := 1 to len(a_usl)
  for i := 1 to len(a_usl[j,1])
    if !empty(shb := a_usl[j,1,i])
      if "*" $ shb .or. "?" $ shb
        fl := like(alltrim(shb),lshifr)
      else
        fl := (shb == lshifr)
      endif
      if fl
        if f_is_zak_sl_vr(lshifr) .or. f_dn_stac_01_04(lshifr)
          k := -1 // ���.��砩 � �-�� ��� ������� ��樮���
        else
          k := 0
        endif
        aadd(ta,{j,k,i14})
      endif
    endif
  next
next
for k := 1 to len(ta)  // �᪫�砥�� ��㣨
  j := ta[k,1]
  for i := 1 to len(a_usl[j,2])
    if !empty(shb := a_usl[j,2,i])
      if "*" $ shb .or. "?" $ shb
        fl := !like(alltrim(shb),lshifr)
      else
        fl := !(shb == lshifr)
      endif
      if !fl ; ta[k,1] := 0 ; endif
    endif
  next
next
for k := 1 to len(ta)
  if ta[k,1] > 0
    aadd(ret,ta[k])
  endif
next
if len(ret) == 0
  aadd(ret,{len(a_usl)+1,0,i14})
endif
return ret

***** ��������� ��㣨 �� �� �����祭�� ���� �� ����� �����-���
Function ChangeUslugiZakSluch()
Local arr := {}
aadd(arr,{"1.7.1","1.2.1"})
aadd(arr,{"1.7.2","1.2.6"})
aadd(arr,{"1.7.3","1.2.6"})
aadd(arr,{"1.7.4","1.2.6"})
aadd(arr,{"1.7.5","1.2.6"})
aadd(arr,{"1.7.6","1.2.6"})
aadd(arr,{"1.7.7","1.2.14"})
aadd(arr,{"1.7.8","1.2.14"})
aadd(arr,{"1.7.9","1.2.6"})
aadd(arr,{"1.7.10","1.2.6"})
aadd(arr,{"1.7.11","1.2.14"})
aadd(arr,{"1.7.12","1.2.3"})
aadd(arr,{"1.7.13","1.2.19"})
aadd(arr,{"1.7.14","1.2.19"})
aadd(arr,{"1.7.15","1.2.19"})
aadd(arr,{"1.7.16","1.2.19"})
aadd(arr,{"1.7.17","1.2.19"})
aadd(arr,{"1.7.18","1.2.19"})
aadd(arr,{"1.7.19","1.1.5"})
aadd(arr,{"1.7.20","1.1.9"})
aadd(arr,{"1.7.21","1.1.52"})
aadd(arr,{"1.7.22","1.1.5"})
aadd(arr,{"1.7.23","1.1.9"})
aadd(arr,{"1.7.24","1.1.52"})
aadd(arr,{"1.7.25","1.4.2"})
aadd(arr,{"1.7.26","1.1.7"})
aadd(arr,{"1.7.27","1.1.5"})
aadd(arr,{"1.7.28","1.1.5"})
aadd(arr,{"1.7.29","1.1.5"})
aadd(arr,{"1.7.30","1.1.3"})  // (���஫����)
aadd(arr,{"1.7.31","1.1.3"})  // (���஫����)
aadd(arr,{"1.7.32","1.2.3"})  // (�������ࣨ�)
aadd(arr,{"1.7.33","1.2.1"})
aadd(arr,{"1.7.34","1.2.5"})
aadd(arr,{"1.7.35","1.1.5"})
aadd(arr,{"1.7.36","1.1.11"})
aadd(arr,{"1.7.37","1.2.1"})
aadd(arr,{"1.7.38","1.2.25"})
aadd(arr,{"1.7.39","1.2.25"})
aadd(arr,{"1.7.40","1.1.36"}) // ��⮫���� ����஦������
aadd(arr,{"1.7.41","1.2.25"})
aadd(arr,{"1.7.42","1.2.25"})
aadd(arr,{"1.7.43","1.1.36"}) // ��⮫���� ����஦������
aadd(arr,{"1.7.44","1.1.19"})
aadd(arr,{"1.7.45","1.1.19"})
aadd(arr,{"1.7.46","1.1.7"})
aadd(arr,{"1.7.47","1.1.5"})
aadd(arr,{"1.7.48","1.4.2"})
aadd(arr,{"1.7.49","1.1.7"})
aadd(arr,{"1.7.50","1.2.15"})
aadd(arr,{"1.7.51","1.2.3"})
aadd(arr,{"1.7.52","1.2.3"})
aadd(arr,{"1.7.53","1.1.1"})  // �����ਭ������
aadd(arr,{"1.7.54","1.2.3"})
aadd(arr,{"1.7.55","1.2.7"})
aadd(arr,{"1.7.56","1.1.3"})
aadd(arr,{"1.7.57","1.1.8"})
aadd(arr,{"1.7.58","1.1.19"})  // (��������)
aadd(arr,{"1.7.59","1.1.5"})   // (�࠯��)
aadd(arr,{"1.7.60","1.1.11"})  // (��������஫����)
aadd(arr,{"1.7.61","1.2.1"})   // (���ࣨ�)
aadd(arr,{"1.7.62","1.1.19"})  // (��������)
aadd(arr,{"1.7.63","1.1.5"})   // (�࠯��)
aadd(arr,{"1.7.64","1.1.11"})  // (��������஫����)
aadd(arr,{"1.7.65","1.2.1"})   // (���ࣨ�)
aadd(arr,{"1.7.66","1.1.19"})  // (��������)
aadd(arr,{"1.7.67","1.1.5"})   // (�࠯��)
aadd(arr,{"1.7.68","1.1.9"})   // (��쬮�������)
aadd(arr,{"1.7.69","1.1.19"})  // (��������)
aadd(arr,{"1.7.70","1.1.53"})  // (����࣮�����)
aadd(arr,{"1.7.71","1.1.5"})   // (�࠯��)
aadd(arr,{"1.7.72","1.1.1"})   // �����ਭ������
aadd(arr,{"1.7.73","1.1.19"})  // (��������)
aadd(arr,{"1.7.74","1.2.1"})   // (���ࣨ�)
aadd(arr,{"1.7.75","1.1.5"})   // (�࠯��)
aadd(arr,{"1.7.77","1.1.11"})  // (��������஫����)
aadd(arr,{"1.7.78","1.1.36"})  // ��⮫���� ����஦������
aadd(arr,{"1.7.79","1.1.7"})   // (��न������)
aadd(arr,{"1.7.80","1.1.5"})   // (�࠯��)
//
aadd(arr,{"1.10.1","1.1.5"})   // (�࠯��)
aadd(arr,{"1.10.2","1.1.9"})   // (��쬮�������)
aadd(arr,{"1.10.3","1.1.52"})  // (��䥪樮���� ��)
aadd(arr,{"1.10.4","1.1.19"})  // (��������)
aadd(arr,{"1.10.5","1.1.19"})  // (��������)
aadd(arr,{"1.10.6","1.1.5"})   // (�࠯��)
aadd(arr,{"1.10.7","1.1.9"})   // (��쬮�������)
aadd(arr,{"1.10.8","1.1.52"})  // (��䥪樮���� ��)
aadd(arr,{"1.10.9","1.1.7"})   // (��न������)
aadd(arr,{"1.10.10","1.1.5"})  // (�࠯��)
aadd(arr,{"1.10.11","1.1.7"})  // (��न������ )
aadd(arr,{"1.10.12","1.1.5"})  // (�࠯��)
aadd(arr,{"1.10.13","1.2.3"})  // (�������ࣨ�)
aadd(arr,{"1.10.14","1.2.3"})  // (�������ࣨ�)
aadd(arr,{"1.10.15","1.1.5"})  // (�࠯��)
aadd(arr,{"1.10.16","1.1.5"})  // (�࠯��)
aadd(arr,{"1.10.17","1.1.3"})  // (���஫����)
aadd(arr,{"1.10.18","1.1.3"})  // (���஫����)
aadd(arr,{"1.10.19","1.2.3"})  // (�������ࣨ�)
aadd(arr,{"1.10.20","1.2.1"})  // (���ࣨ�)
aadd(arr,{"1.10.21","1.2.5"})  // (�ࠢ��⮫����)
aadd(arr,{"1.10.22","1.1.5"})  // (�࠯��)
aadd(arr,{"1.10.23","1.1.11"}) // (��������஫����)
aadd(arr,{"1.10.24","1.2.1"})  // (���ࣨ�)
aadd(arr,{"1.10.25","1.1.19"}) // (��������)
aadd(arr,{"1.10.26","1.2.19"}) // (���������)
aadd(arr,{"1.10.27","1.2.19"}) // (���������)
aadd(arr,{"1.10.28","1.2.19"}) // (���������)
aadd(arr,{"1.10.29","1.2.19"}) // (���������)
aadd(arr,{"1.10.30","1.2.19"}) // (���������)
aadd(arr,{"1.10.31","1.2.19"}) // (���������)
aadd(arr,{"1.10.32","1.2.25"}) //
aadd(arr,{"1.10.33","1.1.36"}) // ��⮫���� ����஦������
aadd(arr,{"1.10.34","1.2.25"}) //
aadd(arr,{"1.10.35","1.1.36"}) //
aadd(arr,{"1.10.36","1.2.15"}) // (�ࠪ��쭮� ���ࣨ�)
aadd(arr,{"1.10.37","1.1.5"})  // (�࠯��)
aadd(arr,{"1.10.38","1.1.11"}) // (��������஫����)
aadd(arr,{"1.10.39","1.2.1"})  // (���ࣨ�)
aadd(arr,{"1.10.40","1.1.19"}) // (��������)
aadd(arr,{"1.10.41","1.1.5"})  // (�࠯��)
aadd(arr,{"1.10.42","1.1.11"}) // (��������஫����)
aadd(arr,{"1.10.43","1.2.1"})  // (���ࣨ�)
aadd(arr,{"1.10.44","1.1.19"}) // (��������)
aadd(arr,{"1.10.45","1.1.5"})  // (�࠯��)
aadd(arr,{"1.10.46","1.1.9"})  // (��쬮�������)
aadd(arr,{"1.10.47","1.1.19"}) // (��������)
aadd(arr,{"1.10.48","1.1.53"}) // (����࣮�����)
aadd(arr,{"1.10.49","1.1.5"})  // (�࠯��)
aadd(arr,{"1.10.50","1.1.1"})  // �����ਭ������
aadd(arr,{"1.10.51","1.1.19"}) // (��������)
aadd(arr,{"1.10.52","1.2.1"})  // (���ࣨ�)
aadd(arr,{"1.10.53","1.1.5"})  // (�࠯��)
aadd(arr,{"1.10.55","1.1.11"}) // (��������஫����)
aadd(arr,{"1.10.56","1.1.36"}) // ��⮫���� ����஦������
aadd(arr,{"1.10.57","1.1.7"})  // (��न������)
aadd(arr,{"1.10.58","1.1.5"})  // (�࠯��)
return arr

*

***** ���祭� ����� ���.���, �ᯮ��㥬�� �� ��।������ ࠧ��� 䨭���஢����
***** ����樭᪨� �࣠����権, �������� � ��ய����� �� ����襭�� ����㯭���
***** ���㫠�୮� ����樭᪮� �����, �஢������ � ࠬ��� �ணࠬ�� ����୨��樨
***** ��ࠢ���࠭���� ������ࠤ᪮� ������ �� 2011-2012 ����
Function UsllugiUzkieSpec()
Local arr := {}
//2.  ��������� ����� �� ��������
aadd(arr,{"2.1.1"  ,"��祡�� �ਥ� �࠯����᪨�"})  // !!!
aadd(arr,{"2.2.1"  ,"��祡�� �ਥ� ��쬮�������᪨�"})
aadd(arr,{"2.9.1"  ,"��祡�� �ਥ� ��ଠ⮫����᪨�"})
aadd(arr,{"2.11.1" ,"��祡�� �ਥ� ॢ��⮫����᪨�"})
aadd(arr,{"2.14.1" ,"��祡�� �ਥ� �ࠢ��⮫���-��⮯���"})
aadd(arr,{"2.15.1" ,"��祡�� �ਥ� �஫����᪨�"})
aadd(arr,{"2.16.1" ,"��祡�� �ਥ� �����-����������"})
aadd(arr,{"2.18.1" ,"��祡�� �ਥ� �⮫�ਭ�������᪨�"})
aadd(arr,{"2.19.1" ,"��祡�� �ਥ� ����࣮����-���㭮����"})
aadd(arr,{"2.20.1" ,"��祡�� �ਥ� ���ࣨ�᪨�"})
aadd(arr,{"2.21.1" ,"��祡�� �ਥ� ��न������᪨�"})
aadd(arr,{"2.22.1" ,"��祡�� �ਥ� ���������᪨�"})
aadd(arr,{"2.22.3" ,"��祡�� �ਥ� ��������-���������"})
aadd(arr,{"2.22.4" ,"��祡�� �ਥ� ��������-�����ப⮫���"})
aadd(arr,{"2.22.5" ,"��祡�� �ਥ� �ࠪ��쭮�� ��������"})
aadd(arr,{"2.22.6" ,"��祡�� �ਥ� ��������-����������"})
aadd(arr,{"2.22.7" ,"��祡�� �ਥ� ��������-�⮫�ਭ������"})
aadd(arr,{"2.22.8" ,"��祡�� �ਥ� ��������-�஫���"})
aadd(arr,{"2.22.9" ,"��祡�� �ਥ� ��������-�⮬�⮫���"})
aadd(arr,{"2.22.10","��祡�� �ਥ� ��������-����⮫���"})
aadd(arr,{"2.22.11","��祡�� �ਥ� ��������-娬���࠯���"})
aadd(arr,{"2.22.12","��祡�� �ਥ� ࠤ������"})
aadd(arr,{"2.24.1" ,"��祡�� �ਥ� �䫥���࠯����᪨�"})
aadd(arr,{"2.27.1" ,"��祡�� �ਥ� �����ਭ������᪨�"})
aadd(arr,{"2.29.1" ,"��祡�� �ਥ� ��⠫쬮�����᪨�"})
aadd(arr,{"2.30.1" ,"��祡�� �ਥ� ���஫����᪨�"})
aadd(arr,{"2.31.1" ,"��祡�� �ਥ� ��������஫����᪨�"})
aadd(arr,{"2.32.1" ,"��祡�� �ਥ� ��������᪨�"})   // !!!
aadd(arr,{"2.34.1" ,"��祡�� �ਥ� 䨧���࠯����᪨�"})
aadd(arr,{"2.34.3" ,"�ਥ� ��� 䨧���࠯����᪮� �����������"})
aadd(arr,{"2.35.1" ,"��祡�� �ਥ� ��� �� ��祡��� 䨧������"})
aadd(arr,{"2.41.1" ,"��祡�� �ਥ� ��䥪樮���"})
aadd(arr,{"2.56.4" ,"���饭�� ���஫���� �� ����"})
aadd(arr,{"2.56.5" ,"���饭�� ��न������ �� ����"})
aadd(arr,{"2.56.6" ,"���饭�� ॢ��⮫���� �� ����"})
aadd(arr,{"2.56.7" ,"���饭�� ���࣮� �� ����"})
aadd(arr,{"2.56.8" ,"���饭�� �஫���� �� ����"})
aadd(arr,{"2.56.9" ,"���饭�� ��������� �� ����"})
aadd(arr,{"2.56.10","���饭�� ����஬-����������� �� ����"})
aadd(arr,{"2.56.11","���饭�� ��ଠ⮫���� �� ����"})
aadd(arr,{"2.56.12","���饭�� ��⠫쬮����� �� ����"})
aadd(arr,{"2.56.13","���饭�� �⮫�ਭ������� �� ����"})
aadd(arr,{"2.56.14","���饭�� �ࠢ��⮫���� �� ����"})
aadd(arr,{"2.57.2" ,"��祡�� �ਥ� �������࣠"})
aadd(arr,{"2.57.3" ,"��祡�� �ਥ� �����ப⮫���"})
aadd(arr,{"2.57.4" ,"��祡�� �ਥ� �थ筮-��㤨�⮣� ���࣠"})
//2.70. ��������� ������ ���������������
aadd(arr,{"2.70.1" ,"�������⨢�� �ਥ� ��न�����"})
aadd(arr,{"2.70.2" ,"�������⨢�� �ਥ� ॢ��⮫���"})
aadd(arr,{"2.70.3" ,"�������⨢�� �ਥ� ��������஫���"})
aadd(arr,{"2.70.4" ,"�������⨢�� �ਥ� ��쬮������"})
aadd(arr,{"2.70.5" ,"�������⨢�� �ਥ� �����ਭ�����"})
aadd(arr,{"2.70.6" ,"�������⨢�� �ਥ� ���஫���"})
aadd(arr,{"2.70.7" ,"�������⨢�� �ਥ� ����⮫���"})
aadd(arr,{"2.70.8" ,"�������⨢�� �ਥ� ����࣮����-���㭮����"})
aadd(arr,{"2.70.11","�������⨢�� �ਥ� ��䥪樮����"})
aadd(arr,{"2.70.12","�������⨢�� �ਥ� �ࠢ��⮫���-��⮯���"})
aadd(arr,{"2.70.13","�������⨢�� �ਥ� �஫���"})
aadd(arr,{"2.70.14","�������⨢�� �ਥ� �������࣠"})
aadd(arr,{"2.70.16","�������⨢�� �ਥ� �����ப⮫���"})
aadd(arr,{"2.70.18","�������⨢�� �ਥ� ��������"})
aadd(arr,{"2.70.19","�������⨢�� �ਥ� �����-����������"})
aadd(arr,{"2.70.20","�������⨢�� �ਥ� �⮫�ਭ������"})
aadd(arr,{"2.70.21","�������⨢�� �ਥ� ��⠫쬮����"})
aadd(arr,{"2.70.22","�������⨢�� �ਥ� ���஫���"})
aadd(arr,{"2.70.23","�������⨢�� �ਥ� ��ଠ⮫���"})
aadd(arr,{"2.70.24","�������⨢�� �ਥ� �थ筮-��㤨�⮣� ���࣠"})
aadd(arr,{"2.70.27","�������⨢�� �ਥ� ���࣠"})
aadd(arr,{"2.70.29","�������⨢�� �ਥ� ��म����"})
aadd(arr,{"2.70.30","�������⨢�� �ਥ� ��������-���������"})
aadd(arr,{"2.70.31","�������⨢�� �ਥ� ��������-�����ப⮫���"})
aadd(arr,{"2.70.32","�������⨢�� �ਥ� �ࠪ��쭮�� ��������"})
aadd(arr,{"2.70.33","�������⨢�� �ਥ� ��������-����������"})
aadd(arr,{"2.70.34","�������⨢�� �ਥ� ��������-�⮫�ਭ������"})
aadd(arr,{"2.70.35","�������⨢�� �ਥ� ��������-�஫���"})
aadd(arr,{"2.70.36","�������⨢�� �ਥ� ��������-�⮬�⮫���"})
aadd(arr,{"2.70.37","�������⨢�� �ਥ� ��������-����⮫���"})
aadd(arr,{"2.70.38","�������⨢�� �ਥ� ��������-娬���࠯���"})
aadd(arr,{"2.70.39","�������⨢�� �ਥ� ��⠫쬮���� ���㪮����� �������"})
aadd(arr,{"2.81.1", "��������� ��� �������"})
aadd(arr,{"2.81.2", "��������� ��� ��न�����"})
aadd(arr,{"2.81.3", "��������� ��� ��䥪樮����"})
aadd(arr,{"2.81.4", "��������� ��� ॢ��⮫���"})
aadd(arr,{"2.81.5", "��������� ��� ���஫���"})
aadd(arr,{"2.81.6", "��������� ��� ��ଠ⮫���"})
aadd(arr,{"2.81.7", "��������� ��� ����⨪�"})
aadd(arr,{"2.81.8", "��������� ��� ��म����"})
aadd(arr,{"2.81.9", "��������� ��� ��������஫���"})
aadd(arr,{"2.81.10","��������� ��� ��쬮������"})
aadd(arr,{"2.81.11","��������� ��� �����ਭ�����"})
aadd(arr,{"2.81.12","��������� ��� ���஫���"})
aadd(arr,{"2.81.13","��������� ��� ����⮫���"})
aadd(arr,{"2.81.14","��������� ��� ����࣮����-���㭮����"})
aadd(arr,{"2.81.15","��������� ��� ���࣠"})
aadd(arr,{"2.81.16","��������� ��� �थ筮-��㤨�⮣� ���࣠"})
aadd(arr,{"2.81.17","��������� ��� �⮫�ਭ������"})
aadd(arr,{"2.81.18","��������� ��� ��⠫쬮����"})
aadd(arr,{"2.81.19","��������� ��� ��⠫쬮���� ���㪮����� �������"})
aadd(arr,{"2.81.20","��������� ��� �ࠢ��⮫���-��⮯���"})
aadd(arr,{"2.81.21","��������� ��� �஫���"})
aadd(arr,{"2.81.22","��������� ��� �������࣠"})
aadd(arr,{"2.81.23","��������� ��� �����-����������"})
aadd(arr,{"2.81.24","��������� ��� ��������"})
aadd(arr,{"2.81.25","��������� ��� ��������-���������"})
aadd(arr,{"2.81.26","��������� ��� ��������-�����ப⮫���"})
aadd(arr,{"2.81.27","��������� ��� �ࠪ��쭮�� ��������"})
aadd(arr,{"2.81.28","��������� ��� ��������-����������"})
aadd(arr,{"2.81.29","��������� ��� ��������-�⮫�ਭ������"})
aadd(arr,{"2.81.30","��������� ��� ��������-�஫���"})
aadd(arr,{"2.81.31","��������� ��� ��������-�⮬�⮫���"})
aadd(arr,{"2.81.32","��������� ��� ��������-����⮫���"})
aadd(arr,{"2.81.33","��������� ��� ��������-娬���࠯���"})
aadd(arr,{"2.81.34","��������� ��� 祫��⭮-��楢��� ���࣠"})
aadd(arr,{"2.81.35","��������� ��� �����ப⮫���"})
aadd(arr,{"57.1.1" ,"�ਥ� ���-�⮬�⮫��� (�㡭��� ���) ��ࢨ��"})
aadd(arr,{"57.1.2" ,"�ਥ� ���-�⮬�⮫��� (�㡭��� ���) ������"})
aadd(arr,{"57.1.3" ,"��祡�� �ਥ� �⮬�⮫����᪨� �������⨢��"})
aadd(arr,{"57.1.4" ,"��祡�� �ਥ� ��⮤��� �������⨢��"})
aadd(arr,{"57.1.5" ,"���饭�� �⮬�⮫���� �� ����"})
aadd(arr,{"57.1.32","��祡�� �ਥ� ��⮤��� ��ࢨ��"})
aadd(arr,{"57.1.33","��祡�� �ਥ� ��⮤��� ������"})
aadd(arr,{"57.1.36","�ਥ� �⮬�⮫���-�࠯��� ��ࢨ��"})
aadd(arr,{"57.1.37","�ਥ� �⮬�⮫���-�࠯��� ������"})
aadd(arr,{"57.1.38","�ਥ� �⮬�⮫���-�࠯��� �������⨢��"})
aadd(arr,{"57.1.39","�ਥ� �⮬�⮫���-���࣠ ��ࢨ��"})
aadd(arr,{"57.1.40","�ਥ� �⮬�⮫���-���࣠ ������"})
aadd(arr,{"57.1.41","�ਥ� �⮬�⮫���-���࣠ �������⨢��"})
aadd(arr,{"57.1.42","�ਥ� ���᪮�� �⮬�⮫��� ��ࢨ��"})
aadd(arr,{"57.1.43","�ਥ� ���᪮�� �⮬�⮫��� ������"})
aadd(arr,{"57.1.44","�ਥ� ���᪮�� �⮬�⮫��� �������⨢��"})
aadd(arr,{"57.1.45","�ਥ� �㡭��� ��� ��ࢨ��"})
aadd(arr,{"57.1.46","�ਥ� �㡭��� ��� ������"})
aadd(arr,{"57.1.47","���饭�� �⮬�⮫����-�࠯��⮬ �� ����"})
aadd(arr,{"57.1.48","���饭�� ���᪨� �⮬�⮫���� �� ����"})
aadd(arr,{"57.1.49","���饭�� �⮬�⮫����-���࣮� �� ����"})
aadd(arr,{"57.1.50","���饭�� �㡭� ��箬 �� ����"})
return arr

*


***** 16.07.17 ��������� ⠡���� Excel'�
Function fill_in_Excel_Book(inFile,outFile,fillArray,smsg)
Local buf := save_maxrow(), bSaveHandler, msgArray := {}
local oSheet, oBook, oExcel, is_open_or_create, iS, jC, a, v, s
keyboard ""
if !hb_FileExists(inFile)
  return func_error(4,"�� �����㦥� 䠩� 蠡���� "+inFile)
elseif valtype(smsg) == "C"
  aadd(msgArray,"������� ����������� ���㧨�� ���ଠ�� � 䠩�/蠡��� Excel,")
  aadd(msgArray,smsg+".")
  aadd(msgArray,"���� "+upper(outFile)+" �� ������ ���� �����")
  aadd(msgArray,"(�, �����, ���� ������� �ணࠬ�� Excel, �᫨ ��� �����).")
  aadd(msgArray,"")
  aadd(msgArray,"�롥�� ����⢨�:")
  if f_alert(msgArray,{" �⪠� "," ���㧪� � 䠩� Excel "},1,"GR+/R","W+/R",,,"GR+/R,N/BG") != 2
    return NIL
  endif
endif
stat_msg("����! �ந�������� ����� Excel")
if Start_Excel(@oExcel,@is_open_or_create)
  oExcel:Visible := .f.
  oExcel:DisplayAlerts:=.f.
  oBook := oExcel:WorkBooks:Open(inFile)
  FOR EACH oSheet IN oBook:WorkSheets
    stat_msg('��ࠡ��뢠���� ���� "'+oSheet:Name+'"')
    if (iS := ascan(fillArray, {|x| x[1] == oSheet:Name })) > 0
      a := fillArray[iS,2]
      for jC := 1 to len(a) // 横� �� �祩��� �����⭮�� ����
        s := ""
        if (v := valtype(a[jC,3])) == "N"
          s := lstr(a[jC,3])
        elseif v == "C"
          s := a[jC,3]
        elseif v == "D"
          s := full_date(a[jC,3])
        endif
        oSheet:Cells(a[jC,1],a[jC,2]):Value := s
      next
    endif
  next
  bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
  BEGIN SEQUENCE
    if int(val(oExcel:get("Version"))) < 12
      oBook:SaveAs(outFile,43)  // xlExcel9795
    else
      oBook:SaveAs(outFile,56)  // xlExcel8
    endif
    if is_open_or_create == 2 // �᫨ Excel �� �� �����, � �� ��� ���뫨
      oBook:close(.f.,,.f.)   // ������� �����
      oExcel:Quit()           // ����뢠�� Excel
      oBook  := nil
      oSheet := nil
      oExcel := nil
      millisec(1000)  // pause
      WAPI_SHELLEXECUTE(0,"OPEN",outFile) // ᭮�� ����᪠�� Excel
    else
      oBook:Activate()        // ᤥ���� ����� ��⨢���
      oExcel:Visible := .t.   // ᤥ���� Excel ������
    endif
  RECOVER USING error
    oBook:close(.f.,,.f.)   // ������� �����
    oExcel:Quit()           // ����뢠�� Excel
    oBook  := nil
    oSheet := nil
    oExcel := nil
    func_error(4,"�訡�� ��࠭���� 䠩�� "+upper(outFile))
  END
  ERRORBLOCK(bSaveHandler)
else
  func_error(4,"��㤠筠� ����⪠ ����᪠ Excel")
endif
rest_box(buf)
return NIL

***** 10.11.13 ����� Excel'�
Function Start_Excel(/*@*/oExcel,/*@*/is_open_or_create)
Static sExcel := "Excel.Application"
Local ret := .f., bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
is_open_or_create := 0
BEGIN SEQUENCE
  oExcel := GetActiveObject(sExcel) // �஢�ਬ, �� ����� �� 㦥 Excel
  oExcel:DisplayAlerts:=.f.
  is_open_or_create := 1
  ret := .t.
RECOVER USING error
  ret := .f.
  BEGIN SEQUENCE
    oExcel := CreateObject(sExcel)  // ���� ���뢠�� ᠬ�
    is_open_or_create := 2
    ret := .t.
  RECOVER USING error
    ret := .f.
  END
END
ERRORBLOCK(bSaveHandler)
Return ret

***** 12.07.17
Function func_f14_stom(s,ltip,lkol,is_2_88,is_rebenok,is_trudosp,is_inogoro,is_sred)
Local i, k, al := "TMP_STOM"
if select(al) == 0
  dbcreate(al,{{"name","C",27,0},;
               {"k2","N",6,0},;
               {"k3","N",6,0},;
               {"k4","N",13,2},;
               {"k5","N",6,0},;
               {"k6","N",6,0},;
               {"k7","N",13,2},;
               {"k8","N",6,0},;
               {"k9","N",6,0},;
               {"k10","N",13,2},;
               {"k11","N",6,0},;
               {"k12","N",6,0},;
               {"k13","N",13,2}})
  use (al) new
  append blank
  &al.->name := "���饭�� � ��祡��� 楫��"
  append blank
  &al.->name := " � �.�. � �㡭��� ����"
  append blank
  &al.->name := "���饭�� � ��䨫����᪮� 楫��"
  append blank
  &al.->name := " � �.�. � �।���� ������ᮭ���"
  append blank
  &al.->name := "������� ���饭�� �� �����������"
  append blank
  &al.->name := " � �.�. � �।���� ������ᮭ���"
  append blank
  &al.->name := "���饭�� �� �������� ���⫮���� �����"
  append blank
  &al.->name := " � �.�. � �।���� ������ᮭ���"
  append blank
  &al.->name := "��稥"
  append blank
  &al.->name := "��騩 �⮣"
endif
au := {} ; k := 0
do case
  case ltip == 1 // �� ������ �����������
    k := 1
  case ltip == 2 // ��䨫��⨪�
    k := iif(is_2_88, 5, 3)
  case ltip == 3 // � ���⫮���� �ଥ
    k := 7
endcase
if k == 0
  aadd(au,9)
else
  aadd(au,k)
  if is_sred
    aadd(au,k+1)
  endif
endif
aadd(au,10)
dbSelectArea(al)
for i := 1 to len(au)
  goto (au[i])
  &al.->k2 ++
  &al.->k3 += lkol
  &al.->k4 += s
  if is_rebenok
    &al.->k5 ++
    &al.->k6 += lkol
    &al.->k7 += s
  endif
  if is_trudosp
    &al.->k8 ++
    &al.->k9 += lkol
    &al.->k10+= s
  endif
  if is_inogoro
    &al.->k11 ++
    &al.->k12 += lkol
    &al.->k13 += s
  endif
next
return NIL
