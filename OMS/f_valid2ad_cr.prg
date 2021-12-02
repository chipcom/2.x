
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 28.01.21  //  XX.12.20
Function f_valid2ad_cr()
  Static mm_bartel := {;
    {"������ ���⥫� 60 ������ � �����","60"},;
    {"������ ���⥫� ����� 60 ������",  "61"}}
  Static mm_mgi := {;
    {"�� ���⠢����� �������⥫�� ���਩                  ","   "},;
    {"mgi-�믮������ ����ᨨ �� �����७�� ��� � �஢������ ���","mgi"}}
  Static mm_rb := {;
    {"�� �業������� ���ﭨ� �� ����� ��������樮���� ������⨧�樨","   "},;
    {"rb2 - �業�� ���ﭨ� ��樥�� 2 ����� �� ���", "rb2"},;
    {"rb3 - �業�� ���ﭨ� ��樥�� 3 ����� �� ���", "rb3"},;
    {"rb4 - �業�� ���ﭨ� ��樥�� 4 ����� �� ���", "rb4"},;
    {"rb5 - �業�� ���ﭨ� ��樥�� 5 ������ �� ���","rb5"},;
    {"rb6 - �業�� ���ﭨ� ��樥�� 6 ������ �� ���","rb6"},;
    {"rb2cov - �業�� ���ﭨ� ��樥�� ��᫥ COVID-19 2 ����� �� ���", "rb2cov"},;
    {"rb3cov - �業�� ���ﭨ� ��樥�� ��᫥ COVID-19 3 ����� �� ���", "rb3cov"},;
    {"rb4cov - �業�� ���ﭨ� ��樥�� ��᫥ COVID-19 4 ����� �� ���", "rb4cov"},;
    {"rb5cov - �業�� ���ﭨ� ��樥�� ��᫥ COVID-19 5 ����� �� ���", "rb5cov"},;
    {"rbs - ����樭᪠� ॠ������� ��⥩ � ����襭�ﬨ ���","rbs"}}
  Local i, j, arr_sop := {}, arr_osl := {}, fl

  input_ad_cr := .f. ; mm_ad_cr := {}
  if m1usl_ok < 3 .and. m1vmp == 0
    if m1profil == 158 // ॠ�������
      input_ad_cr := .t.
      aadd(mm_ad_cr,mm_rb[1])
      if m1usl_ok == 1
        aadd(mm_ad_cr,mm_rb[3])
        aadd(mm_ad_cr,mm_rb[4])
        aadd(mm_ad_cr,mm_rb[5])
        aadd(mm_ad_cr,mm_rb[6])
        aadd(mm_ad_cr,mm_rb[8])
        aadd(mm_ad_cr,mm_rb[9])
        aadd(mm_ad_cr,mm_rb[10])
        aadd(mm_ad_cr,mm_rb[11])
      else
        aadd(mm_ad_cr,mm_rb[2])
        aadd(mm_ad_cr,mm_rb[3])
        aadd(mm_ad_cr,mm_rb[7])
        aadd(mm_ad_cr,mm_rb[11])
      endif
    elseif m1usl_ok == 1 .and. !empty(MKOD_DIAG)
      if !empty(MKOD_DIAG2) ; aadd(arr_sop,padr(MKOD_DIAG2,5)) ; endif
      if !empty(MKOD_DIAG3) ; aadd(arr_sop,padr(MKOD_DIAG3,5)) ; endif
      if !empty(MKOD_DIAG4) ; aadd(arr_sop,padr(MKOD_DIAG4,5)) ; endif
      if !empty(MSOPUT_B1) ; aadd(arr_sop,padr(MSOPUT_B1,5)) ; endif
      if !empty(MSOPUT_B2) ; aadd(arr_sop,padr(MSOPUT_B2,5)) ; endif
      if !empty(MSOPUT_B3) ; aadd(arr_sop,padr(MSOPUT_B3,5)) ; endif
      if !empty(MSOPUT_B4) ; aadd(arr_sop,padr(MSOPUT_B4,5)) ; endif
      if !empty(MOSL1) ; aadd(arr_osl,padr(MOSL1,5)) ; endif
      if !empty(MOSL2) ; aadd(arr_osl,padr(MOSL2,5)) ; endif
      if !empty(MOSL3) ; aadd(arr_osl,padr(MOSL3,5)) ; endif
      for i := 1 to len(arr_ad_cr_it21) 
        if m1usl_ok == arr_ad_cr_it21[i,1] .and. ascan(mm_ad_cr,{|x| x[2] == arr_ad_cr_it21[i,2] }) == 0
          if !empty(arr_ad_cr_it21[i,3]) .and. empty(arr_ad_cr_it21[i,4]) .and. empty(arr_ad_cr_it21[i,5]) // ��.�������
            if ascan(arr_ad_cr_it21[i,3],padr(MKOD_DIAG,5)) > 0
              // aadd(mm_ad_cr,{"",arr_ad_cr_it21[i,2]})
              aadd(mm_ad_cr,{alltrim(arr_ad_cr_it21[i,2])+' '+arr_ad_cr_it21[i,6],arr_ad_cr_it21[i,2]})
            endif
          endif
          if !empty(arr_ad_cr_it21[i,3]) .and. !empty(arr_ad_cr_it21[i,4]) .and. empty(arr_ad_cr_it21[i,5]) // ��.+ᮯ��.��������
            fl := .t.
            if eq_any(left(arr_ad_cr_it21[i,2],2),"i3","i4") .and. mk_data >= 0d20200901
              fl := .f.
            endif
            if eq_any(left(arr_ad_cr_it21[i,2],2),"cr") .and. mk_data < 0d20200901
              fl := .f.
            endif
  
            if fl .and. !empty(arr_sop) .and. ascan(arr_ad_cr_it21[i,3],padr(MKOD_DIAG,5)) > 0
              for j := 1 to len(arr_sop)
                if ascan(arr_ad_cr_it21[i,4],arr_sop[j]) > 0
                  // aadd(mm_ad_cr,{"",arr_ad_cr_it21[i,2]})
                  aadd(mm_ad_cr,{alltrim(arr_ad_cr_it21[i,2])+' '+arr_ad_cr_it21[i,6],arr_ad_cr_it21[i,2]})
                  exit
                endif
              next
            endif
          endif
          if !empty(arr_ad_cr_it21[i,3]) .and. empty(arr_ad_cr_it21[i,4]) .and. !empty(arr_ad_cr_it21[i,5]) // ������� �᫮������
            if !empty(arr_osl)
              for j := 1 to len(arr_osl)
                if ascan(arr_ad_cr_it21[i,5],arr_osl[j]) > 0
                  // if ascan(arr_ad_cr_it21[i,4],arr_osl[j]) > 0
                  // aadd(mm_ad_cr,{"",arr_ad_cr_it21[i,2]})
                  aadd(mm_ad_cr,{alltrim(arr_ad_cr_it21[i,2])+' '+arr_ad_cr_it21[i,6],arr_ad_cr_it21[i,2]})
                  exit
                endif
              next
            endif
          endif
        endif
      next
    elseif m1usl_ok == 2 .and. m1profil == 137  // ��� ������� ��樮���
      for i := 1 to len(arr_ad_cr_it21) 
        if m1usl_ok == arr_ad_cr_it21[i,1] .and. lower(substr(arr_ad_cr_it21[i,2],1,3)) == 'ivf'
          aadd(mm_ad_cr,{alltrim(arr_ad_cr_it21[i,2])+' '+arr_ad_cr_it21[i,6],arr_ad_cr_it21[i,2]})
        endif
      next
    elseif m1usl_ok == 2 .and. !empty(MKOD_DIAG)
      for i := 1 to len(arr_ad_cr_it21)
        
        if m1usl_ok == arr_ad_cr_it21[i,1] .and. ascan(arr_ad_cr_it21[i,3],padr(MKOD_DIAG,5)) > 0
          // aadd(mm_ad_cr,{"",arr_ad_cr_it21[i,2]})
          aadd(mm_ad_cr,{alltrim(arr_ad_cr_it21[i,2])+' '+arr_ad_cr_it21[i,6],arr_ad_cr_it21[i,2]})
        endif
      next
    elseif eq_any(pr_ds_it,1,2) .and. m1usl_ok == 1
      aadd(mm_ad_cr,mm_it[1])
      aadd(mm_ad_cr,mm_it[pr_ds_it+1])
    elseif pr_ds_it == 4
      mm_ad_cr := mm_bartel
    endif
    if (input_ad_cr := !empty(mm_ad_cr)) .and. empty(mm_ad_cr[1,1])
      asort(mm_ad_cr,,,{|x,y| x[2] < y[2] })
      // �������� �� �ࠢ�筨�� �奬
      for i := 1 to len(mm_ad_cr)
        do case
          case mm_ad_cr[i,2] == "cr4"
            mm_ad_cr[i,1] := "cr4-�.4 �ਫ.12 �ਪ��� 198�/���᮪ᨬ����<95%, T>=38C, ���>22"
          case mm_ad_cr[i,2] == "cr5"
            mm_ad_cr[i,1] := "cr5-�.5 �ਫ.12 �ਪ��� 198�/���᮪ᨬ����<=93%, T>=39C, ���>=30"
          case mm_ad_cr[i,2] == "cr6"
            mm_ad_cr[i,1] := "cr6-�.6 �ਫ.12 �ਪ��� 198�/���᮪ᨬ����<92%, �����.ᮧ�����, ���>35"
          case mm_ad_cr[i,2] == "cr8"
            mm_ad_cr[i,1] := "cr8-��.8-9 �ਫ.12 �ਪ��� 198�/��樥���, �⭮��騥�� � ��㯯� �᪠"
          case mm_ad_cr[i,2] == "it1"
            mm_ad_cr[i,1] := "it1-�����뢭�� �஢������ ��� � �祭�� 72 �ᮢ � �����"
          case mm_ad_cr[i,2] == "it2"
            mm_ad_cr[i,1] := "it2-�����뢭�� �஢������ ��� � �祭�� 480 �ᮢ � �����"
          case mm_ad_cr[i,2] == "i3 "
            mm_ad_cr[i,1] := "i3-�����뢭�� �஢������ ��� � �祭�� ����� 120 �ᮢ"
          case mm_ad_cr[i,2] == "i4 "
            mm_ad_cr[i,1] := "i4-�����뢭�� �஢������ ��� � �祭�� 120 �ᮢ � �����"
          case mm_ad_cr[i,2] == "if "
            mm_ad_cr[i,1] := "if-�����祭�� ������஢����� �����஭�� ��� ��祭�� �஭.����᭮�� ������ �"
          case mm_ad_cr[i,2] == "nif"
            mm_ad_cr[i,1] := "nif-�����祭�� ���.�९. ��� ��祭�� �஭.����᭮�� ������ �+�������.�����஭"
          case mm_ad_cr[i,2] == "pbt"
            mm_ad_cr[i,1] := "pbt-�����祭�� ��㣨� �����-��������� �९��⮢ � ᥫ��⨢��� ���㭮�����ᠭ⮢"
          case mm_ad_cr[i,2] == "ep1"
            mm_ad_cr[i,1] := "ep1-��� 3�� ����� ���-�����ਭ� � ����祭��� ᭠ �� ����� 4 ��."
          case mm_ad_cr[i,2] == "ep2"
            mm_ad_cr[i,1] := "ep2-��� 3��, ����� ���, ᮭ �� ����� 4 ��., ��⨢�������᪠� �࠯��"
          case mm_ad_cr[i,2] == "ep3"
            mm_ad_cr[i,1] := "ep3-��� 3��, ����� ���, ᮭ �� ����� 24 ��., ��������� ���-�������࣠"
          case mm_ad_cr[i,2] == "dcl"
            mm_ad_cr[i,1] := "dcl-����稢���� ��樥�⮢ � COVID-19 �� ������ ��� ��樥�⮢ �।��� �殮��"
        endcase
      next
      Ins_Array(mm_ad_cr,1,mm_mgi[1])
    endif
    if !input_ad_cr .and. m1usl_ok == 2 // ����᫮��� ������� ��� ��� �������� ��樮���
      input_ad_cr := .t.
      aadd(mm_ad_cr,mm_mgi[1])
      aadd(mm_ad_cr,mm_mgi[2])
    endif
    if input_ad_cr
      if (i := ascan(mm_ad_cr,{|x| padr(x[2],10) == padr(m1ad_cr,10) })) > 0
        mad_cr := padr(mm_ad_cr[i,1],65)  // 66
        // mad_cr := padr(mm_ad_cr[i,1],10)
      else
        mad_cr := space(65) // 66
        m1ad_cr := space(10)
        // mad_cr := space(10)
        // m1ad_cr := space(10)
      endif
      if type("p_nstr_ad_cr") == "N"
        @ p_nstr_ad_cr,1 say p_str_ad_cr
        update_get("mad_cr")
      endif
    endif
  endif
  return .t.