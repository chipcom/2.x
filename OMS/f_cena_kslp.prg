#include "inkey.ch"
#include "..\..\_mylib_hbt\function.ch"
#include "..\..\_mylib_hbt\edit_spr.ch"
#include "..\chip_mo.ch"


***** 25.01.21 ��।����� ����-� ᫮����� ��祭�� ��樥�� � �������� 業�
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
  DEFAULT lad_cr TO space(10)

  _lshifr := alltrim(_lshifr) // ��७��

  if _k_data > s_20
    if empty(lkslp)
      return _akslp
    endif
    s_kslp := {;
      // {code, �����樥��, �����⍠砫�, �����⊮���}
      { 1, 1.02, 75, 999},; // ��������� ��祭�� ��樥��, �易���� � �����⮬ (��� 75 ��� � ����) (� ⮬ �᫥, ������ ��������� ���-��ਠ��)
      { 3, 1.20,  0,  18},; // �।��⠢����� ᯠ�쭮�� ���� � ��⠭�� ��������� �।�⠢�⥫� (��� �� 4 ���, ��� ���� 4 ��� �� ����稨 ����樭᪨� ���������)
      { 4, 1.20,  0,  18},; // �஢������ ��ࢮ� ���㭨��樨 ��⨢ �ᯨ��୮-ᨭ�⨠�쭮� ����᭮� ��䥪樨 � ��ਮ� ��ᯨ⠫���樨 �� ������ ��祭�� ����襭��, ���������� � ��ਭ�⠫쭮� ��ਮ��, ������ ���������� � ���㭨��樨
      { 5, 1.20, 18, 999},; // �������뢠��� �������㠫쭮�� ����
      { 6, 1.30, 18, 999},; // �஢������ ��⠭��� ���ࣨ�᪨� ����⥫���
      { 7, 1.30, 18, 999},; // �஢������ ����⨯��� ����権 �� ����� �࣠���
      { 8, 1.50, 18, 999},; // �஢������ ��⨬��஡��� �࠯�� ��䥪権, �맢����� ����१��⥭�묨 ���ம࣠�������
      { 9, 1.50, 18, 999},; // ����稥 � ��樥�� �殮��� ᮯ������饩 ��⮫����, �᫮������ �����������, ᮯ�������� �����������, ������� �� ᫮������ ��祭�� ��樥�� (���祭� 㪠������ ����������� � ���ﭨ�
      {10, 1.50, 18, 999};  // ����夫�⥫�� �ப� ��ᯨ⠫���樨, ���᫮������ ����樭᪨�� ��������ﬨ
    }

    count_ymd(_date_r,_n_data,@y)
    lkslp := list2arr(lkslp)
    for j := 1 to len(lkslp)
      if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0 // �⮨� ����� ���� � ��࠭��� ���
        if between(y,s_kslp[i,3],s_kslp[i,4])
          fl := .t.
          if lkslp[j] == 1  // ��� �� ���� 75 ���
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
  
  