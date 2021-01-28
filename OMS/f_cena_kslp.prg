#include "inkey.ch"
#include "..\..\_mylib_hbt\function.ch"
#include "..\..\_mylib_hbt\edit_spr.ch"
#include "..\chip_mo.ch"


***** 27.01.21 ��।����� ����-� ᫮����� ��祭�� ��樥�� � �������� 業�
Function f_cena_kslp(/*@*/_cena,_lshifr,_date_r,_n_data,_k_data,lkslp,arr_usl,lPROFIL_K,arr_diag,lpar_org,lad_cr)
  Static s_1_may := 0d20160430, s_18 := 0d20171231, s_19 := 0d20181231
  static s_20 := 0d20201231
  Static s_kslp17 := {;
    {1,1.1, 0,  3},;   // �� 4 ���
    {2,1.1,75,999};    // 75 ��� � ����
   }
  Static s_kslp16 := {;
    {1,1.1 , 0,  3},;   // �� 4 ���
    {2,1.05,75,999};    // 75 ��� � ����
   }
  Local i, j, vksg, y := 0, fl, ausl := {}, s_kslp, _akslp := {}, sop_diag
  local countDays := _k_data - _n_data // ���-�� ���� ��祭��
  
  DEFAULT lad_cr TO space(10)

  _lshifr := alltrim(_lshifr) // ��७��

  if _k_data > s_20
    if empty(lkslp)
      return _akslp
    endif
      // {code, �����樥��, �����⍠砫�, �����⊮���}
      s_kslp := {;
      { 1, 1.02, 75, 999},; // ��������� ��祭�� ��樥��, �易���� � �����⮬ (��� 75 ��� � ����) (� ⮬ �᫥, ������ ��������� ���-��ਠ��)
      { 3, 1.20,  0,  18},; // �।��⠢����� ᯠ�쭮�� ���� � ��⠭�� ��������� �।�⠢�⥫� (��� �� 4 ���, ��� ���� 4 ��� �� ����稨 ����樭᪨� ���������)
      { 4, 1.20,  0,  18},; // �஢������ ��ࢮ� ���㭨��樨 ��⨢ �ᯨ��୮-ᨭ�⨠�쭮� ����᭮� ��䥪樨 � ��ਮ� ��ᯨ⠫���樨 �� ������ ��祭�� ����襭��, ���������� � ��ਭ�⠫쭮� ��ਮ��, ������ ���������� � ���㭨��樨
      { 5, 1.20,  0, 999},; // �������뢠��� �������㠫쭮�� ����
      { 6, 1.30,  0, 999},; // �஢������ ��⠭��� ���ࣨ�᪨� ����⥫���
      { 7, 1.30,  0, 999},; // �஢������ ����⨯��� ����権 �� ����� �࣠���
      { 8, 1.50,  0, 999},; // �஢������ ��⨬��஡��� �࠯�� ��䥪権, �맢����� ����१��⥭�묨 ���ம࣠�������
      { 9, 1.50,  0, 999},; // ����稥 � ��樥�� �殮��� ᮯ������饩 ��⮫����, �᫮������ �����������, ᮯ�������� �����������, ������� �� ᫮������ ��祭�� ��樥�� (���祭� 㪠������ ����������� � ���ﭨ�
      {10, 1.50,  0, 999};  // ����夫�⥫�� �ப� ��ᯨ⠫���樨, ���᫮������ ����樭᪨�� ��������ﬨ
    }

    // �.3 ������樨
    // ������ ��樥�� ��।������ �� ������ ����㯫���� �� ��樮��୮� ��祭��.
    // �� ��砨 �ਬ������ ���� (�� �᪫�祭��� ����1) �����࣠���� �ᯥ�⭮�� ����஫�.

    count_ymd(_date_r,_n_data,@y)
    lkslp := list2arr(lkslp)

    // for j := 1 to len(lkslp)
    //   if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0 // �⮨� ����� ���� � ��࠭��� ���
    //     if between(y,s_kslp[i,3],s_kslp[i,4])
    //       fl := .t.
    //       if lkslp[j] == 1  // ��� �� ���� 75 ��� ���� = 1
    //         fl := (lprofil_k != 16 ; // ��樥�� ����� �� �� ��஭⮫����᪮� �����
    //                 .and. !(_lshifr == "st38.001"))
    //       // elseif lkslp[j] == 5
    //       //   sop_diag := aclone(arr_diag)
    //       //   del_array(sop_diag,1)
    //       //   fl := (lprofil_k == 16 .and. ; // ��樥�� ����� �� ��஭⮫����᪮� �����
    //       //           !(_lshifr == "st38.001") .and. ;//!(alltrim(arr_diag[1]) == "R54") .and. ; // � �᭮��� ��������� �� <R54-������>
    //       //           ascan(sop_diag, {|x| alltrim(x) == "R54"}) > 0 ) // � ᮯ.��������� ���� <R54-������>
    //       endif
    //       if fl
    //         aadd(_akslp,s_kslp[i,1])
    //         aadd(_akslp,s_kslp[i,2])
    //         exit
    //       endif
    //     endif
    //   endif
    // next

    // ����=1 ��樥��� ���� 75 ���
    if ascan(lkslp,1) > 0 .and. between(y,s_kslp[1,3],s_kslp[1,4])
      if (lprofil_k != 16 .and. ! (_lshifr == "st38.001"))
        // ��樥�� ����� �� �� ��஭⮫����᪮� ����� 
        aadd(_akslp,1)
        aadd(_akslp,1.02)
      endif
    endif

    // ����=3 ᯠ�쭮� ���� ��������� �।�⠢�⥫�
    // ����� ������
    if ascan(lkslp,3) > 0 .and. between(y,s_kslp[2,3],s_kslp[2,4])
      // �㭪� 3.1.1
      // �।��⠢����� ᯠ�쭮�� ���� � ��⠭�� ��������� �।�⠢�⥫�, �� ������ 
      // ॡ���� ���� 4 ���, �����⢫���� �� ����稨 ����樭᪨� ��������� � 
      // ��ଫ���� ��⮪���� ��祡��� �����ᨨ � ��易⥫�� 㪠������ � ��ࢨ筮� 
      // ����樭᪮� ���㬥��樨.
      aadd(_akslp,3)
      aadd(_akslp,1.2)
    endif

    // ����=4 ���㭨���� ���
    // ����� ������
    if ascan(lkslp,4) > 0
      // �㭪� 3.1.2
      // ���� �ਬ������ � ����� �᫨ �ப� �஢������ ��ࢮ� ���㭨��樨 ��⨢ 
      // �ᯨ��୮-ᨭ�⨠�쭮� ����᭮� (���) ��䥪樨 ᮢ������ �� �६��� � 
      // ��ᯨ⠫���樥� �� ������ ��祭�� ����襭��, ���������� � ��ਭ�⠫쭮� 
      // ��ਮ��, ������ ���������� � ���㭨��樨.
      aadd(_akslp,4)
      aadd(_akslp,1.2)
    endif

    // ����=5 ࠧ����뢠��� �������㠫쭮�� ����
    // ����� ������
    if ascan(lkslp,5) > 0
      aadd(_akslp,5)
      aadd(_akslp,1.2)
    endif

    // ����=6 ��⠭�� ���ࣨ�᪨� ����樨
    if ascan(lkslp,6) > 0
      // �㭪� 3.1.3
      // ���祭� ��⠭��� (ᨬ��⠭���) ���ࣨ�᪨� ����⥫���, �믮��塞�� �� 
      // �६� ����� ��ᯨ⠫���樨, �।�⠢��� � ⠡���:        
      aadd(_akslp,6)
      aadd(_akslp,1.3)
    endif

    // ����=7 ���� �࣠�� � ������� ���� �࣠��
    if ascan(lkslp,7) > 0 .and. lpar_org > 1
      // �㭪� 3.1.4
      // � ����� ������ 楫�ᮮ�ࠧ�� �⭮��� ����樨 �� ����� �࣠���/����� ⥫�,
      // �� �믮������ ������ ����室���, � ⮬ �᫥ ��ண����騥 ��室�� ���ਠ��.
      // ���祭� ���ࣨ�᪨� ����⥫���, �� �஢������ ������ �����६���� �� ����
      // ����� �࣠��� ����� ���� �ਬ���� ����, �।�⠢��� � ⠡���:
      aadd(_akslp,7)
      aadd(_akslp,1.3)
    endif

    // ���� = 8 ��⨬��஡��� �࠯��
    // ����� ������
    if ascan(lkslp,8) > 0
      // �㭪� 3.1.5
      // � ����� ��祭�� ��樥�⮢ � ��樮����� �᫮���� �� ������������ � �� 
      // �᫮�������, �맢����� ���ம࣠������� � ��⨡��⨪�१��⥭⭮����, � ⠪�� 
      // � ����� ��祭�� �� ������ ���������� ������� �ਬ������ ���� � ᮮ⢥��⢨� 
      // � �ᥬ� ����᫥��묨 ����ﬨ:
      //  1)�����稥 ��䥪樮����� �������� � ����� ����10, �뭥ᥭ���� � ������᪨� 
      //    ������� (�⮫��� �����஢�� ��㯯 ?�᭮���� �������? ��� ?������� �᫮������?);
      //  2)�����稥 १���⮢ ���஡�������᪮�� ��᫥������� � ��।������� 
      //    ���⢨⥫쭮�� �뤥������ ���ம࣠������ � ��⨡���ਠ��� �९��⠬ 
      //    �/��� ��⥪樨 �᭮���� ����ᮢ ��ࡠ������� (�ਭ���, ��⠫����⠫��⠬���),
      //    ���⢥ত���� ���᭮�������� �����祭�� �奬� ��⨡���ਠ�쭮� �࠯�� 
      //    (�।���������� ����稥 १���⮢ �� ������ �����襭�� ���� ��ᯨ⠫���樨, 
      //    � ⮬ �᫥ ��ࢠ�����);
      //  3)��ਬ������ ��� ������ ������ ������⢥����� �९��� � ��७�ࠫ쭮� �ଥ 
      //    �� ����� ��� � ��⠢� �奬 ��⨡���ਠ�쭮� �/��� ��⨬�����᪮� �࠯�� 
      //    � �祭�� �� ����� 祬 5 ��⮪:        
      aadd(_akslp,8)
      aadd(_akslp,1.5)
    endif

    // ����=9 �殮�� ᮯ������騥 ��⮫����
    if ascan(lkslp,9) > 0 .and. conditionKSLP_9_21(arr_diag)
      aadd(_akslp,9)
      aadd(_akslp,1.5)
    endif

    // ���� = 10 ᢥ�夫�⥫쭮� ��祭��
    if ascan(lkslp,10) > 0 .and. conditionKSLP_10_21(countDays, _lshifr)
      aadd(_akslp,10)
      aadd(_akslp,1.5)
    endif

    // ��⠭���� 業� � ��⮬ ����
    if !empty(_akslp)
      _cena := round_5(_cena*ret_koef_kslp_21(_akslp),0)  // � 2019 ���� 業� ���㣫���� �� �㡫��
    endif

  elseif _k_data > s_19  // � 2019 ����
    if !empty(lkslp)
      // _lshifr := alltrim(_lshifr)
      if _lshifr == "ds02.005" // ���, lkslp = 12,13,14
        s_kslp := {;
          {12,0.60},;
          {13,1.10},;
          {14,0.19};
        }
        for i := 1 to len(arr_usl)
          if valtype(arr_usl[i]) == "A"
            aadd(ausl,alltrim(arr_usl[i,1]))  // ���ᨢ ���������
          else
            aadd(ausl,alltrim(arr_usl[i]))    // ���ᨢ ��������
          endif
        next i
        j := 0 // ���� - 1 �奬�
        if ascan(ausl,"A11.20.031") > 0  // �ਮ
          j := 13  // 6 �奬�
          if ascan(ausl,"A11.20.028") > 0 // ��⨩ �⠯
            j := 0   // 2 �奬�
          endif
        elseif ascan(ausl,"A11.20.025.001") > 0  // ���� �⠯
          j := 12  // 3 �奬�
          if ascan(ausl,"A11.20.036") > 0  // �������騩 ��ன �⠯
            j := 12  // 4 �奬�
          elseif ascan(ausl,"A11.20.028") > 0  // �������騩 ��⨩ �⠯
            j := 12  // 5 �奬�
          endif
        elseif ascan(ausl,"A11.20.030.001") > 0  // ⮫쪮 �⢥��� �⠯
          j := 14  // 7 �奬�
        endif
        if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
          aadd(_akslp,s_kslp[i,1])
          aadd(_akslp,s_kslp[i,2])
          _cena := round_5(_cena*s_kslp[i,2],0)  // � 2019 ���� 業� ���㣫���� �� �㡫��
        endif
        if !empty(_akslp) .and. _k_data > 0d20191231 // � 2020 ����
          _akslp[1] += 3 // �.�. � 2020 ���� ���� ��� ��� 15,16,17
        endif
      else // ��⠫�� ���
        s_kslp := {;
          { 1,1.10, 0,  0},;  // �� 1 ����
          { 2,1.10, 1,  3},;  // �� 1 �� 3 ��� �����⥫쭮
          { 4,1.02,75,999},;  // 75 � ����
          { 5,1.10,60,999};   // 60 � ���� � ��⥭��
        }
        count_ymd(_date_r,_n_data,@y)
        lkslp := list2arr(lkslp)
        for j := 1 to len(lkslp)
          if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0 // �⮨� ����� ���� � ��࠭��� ���
            if between(y,s_kslp[i,3],s_kslp[i,4])
              fl := .t.
              if lkslp[j] == 4
                fl := (lprofil_k != 16 ; // ��樥�� ����� �� �� ��஭⮫����᪮� �����
                        .and. !(_lshifr == "st38.001"))
              elseif lkslp[j] == 5
                sop_diag := aclone(arr_diag)
                del_array(sop_diag,1)
                fl := (lprofil_k == 16 .and. ; // ��樥�� ����� �� ��஭⮫����᪮� �����
                        !(_lshifr == "st38.001") .and. ;//!(alltrim(arr_diag[1]) == "R54") .and. ; // � �᭮��� ��������� �� <R54-������>
                        ascan(sop_diag, {|x| alltrim(x) == "R54"}) > 0 ) // � ᮯ.��������� ���� <R54-������>
              endif
              if fl
                aadd(_akslp,s_kslp[i,1])
                aadd(_akslp,s_kslp[i,2])
                exit
              endif
            endif
          endif
        next
        if ascan(lkslp,11) > 0 .and. lpar_org > 1 // ࠧ�襭� ����=11 � ������� ���� �࣠��
          aadd(_akslp,11)
          aadd(_akslp,1.2)
        endif
        if ascan(lkslp,18) > 0 .and. "cr6" $ lad_cr // ࠧ�襭� ����=18 � ��� ᫮����� COVID-19
          aadd(_akslp,18)
          aadd(_akslp,1.2)
        endif
        if !empty(_akslp)
          _cena := round_5(_cena*ret_koef_kslp(_akslp),0)  // � 2019 ���� 業� ���㣫���� �� �㡫��
        endif
      endif
    endif
  elseif _k_data > s_18  // � 2018 ����
    if !empty(lkslp)
      // _lshifr := alltrim(_lshifr)
      if _lshifr == "2005.0" // ���, lkslp = 12,13,14
        s_kslp := {;
          {12,0.60},;
          {13,1.10},;
          {14,0.19};
        }
        for i := 1 to len(arr_usl)
          if valtype(arr_usl[i]) == "A"
            aadd(ausl,alltrim(arr_usl[i,1]))  // ���ᨢ ���������
          else
            aadd(ausl,alltrim(arr_usl[i]))    // ���ᨢ ��������
          endif
        next i
        j := 0 // ���� - 1 �奬�
        if ascan(ausl,"A11.20.031") > 0  // �ਮ
          j := 13  // 6 �奬�
          if ascan(ausl,"A11.20.028") > 0 // ��⨩ �⠯
            j := 0   // 2 �奬�
          endif
        elseif ascan(ausl,"A11.20.025.001") > 0  // ���� �⠯
          j := 12  // 3 �奬�
          if ascan(ausl,"A11.20.036") > 0  // �������騩 ��ன �⠯
            j := 12  // 4 �奬�
          elseif ascan(ausl,"A11.20.028") > 0  // �������騩 ��⨩ �⠯
            j := 12  // 5 �奬�
          endif
        elseif ascan(ausl,"A11.20.030.001") > 0  // ⮫쪮 �⢥��� �⠯
          j := 14  // 7 �奬�
        endif
        if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
          aadd(_akslp,s_kslp[i,1])
          aadd(_akslp,s_kslp[i,2])
          _cena := round_5(_cena*s_kslp[i,2],1)
        endif
      else // ��⠫�� ���
        s_kslp := {;
          { 1,1.10, 0,  0},;  // �� 1 ����
          { 2,1.10, 1,  3},;  // �� 1 �� 3 ��� �����⥫쭮
          { 4,1.05,75,999},;  // 75 � ����
          { 5,1.10,60,999};   // 60 � ���� � ��⥭��
        }
        count_ymd(_date_r,_n_data,@y)
        lkslp := list2arr(lkslp)
        for j := 1 to len(lkslp)
          if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0
            if between(i,1,5) .and. between(y,s_kslp[i,3],s_kslp[i,4])
              aadd(_akslp,s_kslp[i,1])
              aadd(_akslp,s_kslp[i,2])
              _cena := round_5(_cena*s_kslp[i,2],1)
              exit
            endif
          endif
        next
      endif
    endif
  elseif _k_data > s_1_may ;                 // � 1 ��� 2016 ����
              .and. left(_lshifr,1) == '1' ; // ��㣫������ ��樮���
              .and. !("." $ _lshifr)         // �� ��� ���
    // _lshifr := alltrim(_lshifr)
    count_ymd(_date_r,_n_data,@y)
    vksg := int(val(right(_lshifr,3))) // ��᫥���� �� ���� - ��� ���
    if (fl := vksg < 900) // �� ������
      if year(_k_data) > 2016
        s_kslp := s_kslp17
        if y < 1 .and. between(vksg,105,111) // �� 1 ���� � ����� ���� �� ஦�����
          fl := .f.
        endif
      else
        s_kslp := s_kslp16
      endif
      if fl
        for i := 1 to len(s_kslp)
          if between(y,s_kslp[i,3],s_kslp[i,4])
            aadd(_akslp,s_kslp[i,1])
            aadd(_akslp,s_kslp[i,2])
            _cena := round_5(_cena*s_kslp[i,2],1)
            exit
          endif
        next
      endif
    endif
  endif
  return _akslp
  
***** 26.01.21 ������ �⮣��� ���� ��� 2021 ����
Function ret_koef_kslp_21(akslp)
  Local k := 1  // ���� ࠢ�� 1

  if valtype(akslp) == "A" .and. len(akslp) >= 2
    for i := 1 TO len(akslp) STEP 2
      if i == 1
        k := akslp[2]
      else
        k += (akslp[i + 1] - 1)
      endif
    next
  endif
  if k > 1.8
    k := 1.8  // ᮣ��᭮ �.3 ������樨
  endif
  return k

***** 26.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=10 ��� 2021 ����
function conditionKSLP_10_21(duration, lshifr)
  // duration - �த����⥫쭮��� ��祭�� � ����
  // lshifr - ��� ��㣨 ���
  //
  // �㭪� 3.1.7
  // �ࠢ��� �⭥ᥭ�� ��砥� � ᢥ�夫�⥫�� �� �����࠭����� �� ���, 
  // ��ꥤ����騥 ��砨 �஢������ ��祢�� �࠯��, � ⮬ �᫥ � ��⠭�� 
  // � ������⢥���� �࠯��� (st19.075-st19.089, ds19.050-ds19.062), 
  // �.�. 㪠����� ��砨 �� ����� ������� ᢥ�夫�⥫�묨 � ����稢����� 
  // � �ਬ������� ����10.
  //
  // ��㣨 ��� �᪫�祭�� ��� ���� 10
  local exclKSG := {"st19.075", "st19.076", "st19.077", "st19.078", "st19.079", ;
    "st19.080", "st19.081", "st19.082", "st19.083", "st19.084", "st19.085", ;
    "st19.086", "st19.087", "st19.088", "st19.089",; 
    "ds19.050", "ds19.051", "ds19.052", "ds19.053", "ds19.054", "ds19.055", ;
    "ds19.056", "ds19.057", "ds19.058", "ds19.059", "ds19.060", "ds19.061", ;
    "ds19.062" }
  local fl := .f.

  if ( duration > 70 ) .and. ( ascan(exclKSG, lshifr) == 0 )
    fl := .t.
  endif
  return fl

  ***** 26.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=9 ��� 2021 ����
function conditionKSLP_9_21(arr_diag)
  // arr_diag - ���ᨢ ���������, 1 ����� - �᭮���� �������,
  //   ��⠫�� ᮯ������騥 � �᫮������
  //
  // �������� �����騥 �� ���� 9
  // �㭪� 3.1.6
  //  � ⠪�� ᮯ������騬 ����������� � �᫮������ ����������� �⭮�����:
  //    ? ����� ������ ⨯� 1 � 2 (E10.0-E10.9; E11.0-E11.9);
  //    ? �����������, ����祭�� � ���祭� ।��� (��䠭���) �����������, 
  //      ࠧ��饭�� �� ��樠�쭮� ᠩ� ��������⢠ ��ࠢ���࠭���� ��1;
  //    ? ����ﭭ� ᪫�஧ (G35);
  //    ? �஭��᪨� �������� ������ (C91.1);
  //    ? ����ﭨ� ��᫥ �࠭ᯫ���樨 �࣠��� � (���) ⪠��� 
  //      (Z94.0; Z94.1; Z94.4; Z94.8);
  //    ? ���᪨� �ॡࠫ�� ��ࠫ�� (G80.0-G80.9);
  //    ? ���/����, �⠤�� 4� � 4�, ����� (B20 ? B24);
  //    ? ��ਭ�⠫�� ���⠪� �� ���-��䥪樨, ��� (Z20.6).
  // �� �ਬ������ ����9 � ��易⥫쭮� ���浪� � ��ࢨ筮� ����樭᪮� 
  // ���㬥��樨 ��ࠦ����� ��ய���� �஢����� �� ������ ��祭�� 
  // ���㪠������ �殮��� ᮯ������饩 ��⮫���� (���ਬ��: �������⥫�� 
  // ��祡��-���������᪨� ��ய����, �����祭�� ������⢥���� �९��⮢, 
  // 㢥��祭�� �ப� ��ᯨ⠫���樨 � �.�.), ����� ��ࠦ��� �������⥫�� 
  // ������ ����樭᪮� �࣠����樨 �� ��祭�� ������� ��樥��. 
  local diag, i := 0, tmp
  local inclDIAG := {;
    "E10.0", "E10.1", "E10.2", "E10.3", "E10.4", "E10.5", "E10.6", "E10.7", "E10.8", "E10.9", ;
    "E11.0", "E11.1", "E11.2", "E11.3", "E11.4", "E11.5", "E11.6", "E11.7", "E11.8", "E11.9", ;
    "G35", "C91.1", "Z94.0", "Z94.1", "Z94.4", "Z94.8", ;
    "G80.0", "G80.1", "G80.2", "G80.3", "G80.4", "G80.8", "G80.9", ;
    "B20", "B21", "B22", "B23", "B24", ;
    "Z20.6";
  }
  local fl := .f.

  if len( arr_diag ) != 1 // �஬� �᭮����� ���� � ��㣨� ��������
    //  .and. ( ascan(exclKSG, lshifr) == 0 )
  endif

  for each diag in arr_diag
    i++
    if i == 1
      loop
    endif
    if upper(substr(diag,1,1)) == 'B' // ��-� � ���
      tmp := upper(substr(diag,1,3))
    else
      tmp := upper(diag)
    endif
    if ascan(inclDIAG, diag) > 0
      fl := .t.
      exit
    endif
  next

  return fl