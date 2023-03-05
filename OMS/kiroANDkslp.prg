#include 'function.ch'

#define CODE_KSLP   1
#define NAME_KSLP   2
#define NAMEF_KSLP  3
#define COEF_KSLP   4

#include 'tbox.ch'

// 27.02.21
//
function buildStringKSLP(row)
  // row - �������� ���ᨢ ����뢠�騩 ����
  local ret

  ret := str(row[ CODE_KSLP ], 2) + '.' + row[ NAME_KSLP ]
  return ret

// 01.02.23
// �㭪�� �롮� ��⠢� ����, �����頥� { ��᪠,��ப� ������⢠ ���� }, ��� nil
function selectKSLP( lkslp, savedKSLP, dateBegin, dateEnd, DOB, mdiagnoz )
  // lkslp - ���祭�� ���� (��࠭�� ����)
  // savedKSLP - ��࠭����� � HUMAN_2 ���� ��� ����
  // dateBegin - ��� ��砫� �����祭���� ����
  // dateEnd - ��� ����砭�� �����祭���� ����
  // DOB - ��� ஦����� ��樥��
  // mdiagnoz - ᯨ᮪ ��࠭��� ���������

  Local mlen, t_mas := {}, ret, ;
    i, tmp_select := select()
  Local r1 := 0 // ���稪 ����ᥩ
  Local strArr := '', age

  Local m1var := '', s := '', countKSLP := 0
  local row, oBox
  local nLast, srok := dateEnd - dateBegin
  local recN, permissibleKSLP := {}, isPermissible
  local sAsterisk := ' * ', sBlank := '   '
  local fl := .f.

  local aKSLP := getKSLPtable( dateEnd )  // ᯨ᮪ �����⨬�� ���� ��� ��㣨
  local aa := list2arr(savedKSLP) // ����稬 ���ᨢ ��࠭��� ����

  default DOB to sys_date
  default dateBegin to sys_date
  default dateEnd to sys_date

  permissibleKSLP := list2arr(lkslp)
  
  age := count_years(DOB, dateEnd)
  
  for each row in aKSLP
    r1++

    isPermissible := ascan(permissibleKSLP, row[ CODE_KSLP ]) > 0

    if (ascan(aa, {|x| x == row[ CODE_KSLP ] }) > 0) .and. isPermissible
      strArr := sAsterisk
    else
      strArr := sBlank
    endif
    if (row[ CODE_KSLP ] == 3 .and. year(dateEnd) == 2023) ;    // ���� 75 ���
        .or. (row[ CODE_KSLP ] == 3 .and. year(dateEnd) == 2022) ;
        .or. (row[ CODE_KSLP ] == 1 .and. year(dateEnd) == 2021)
      if (age >= 75) .and. (year(dateEnd) == 2021) .and. isPermissible
        strArr := sAsterisk
        strArr += buildStringKSLP(row)
      elseif (age >= 75) .and. (year(dateEnd) == 2022) .and. isPermissible
        strArr += buildStringKSLP(row)
      else
        strArr := sBlank
        strArr += buildStringKSLP(row)
      endif
      aadd(t_mas, { strArr, (age >= 75), row[ CODE_KSLP ] })
    elseif ((row[ CODE_KSLP ] == 1 .and. year(dateEnd) == 2023) .or. ;
        (row[ CODE_KSLP ] == 2 .and. year(dateEnd) == 2023) .or. ;
        (row[ CODE_KSLP ] == 1 .and. year(dateEnd) == 2022) .or. ;
        (row[ CODE_KSLP ] == 2 .and. year(dateEnd) == 2022) .or. ;
        (row[ CODE_KSLP ] == 3 .and. year(dateEnd) == 2021)) ;
        .and. isPermissible  // ���� ��������� �।�⠢�⥫�
      if (age < 4)
        strArr := sAsterisk
        strArr += buildStringKSLP(row)
      elseif (age < 18)
        strArr += buildStringKSLP(row)
      else
        strArr := sBlank
        strArr += buildStringKSLP(row)
      endif
      aadd(t_mas, { strArr, (age < 18), row[ CODE_KSLP ] })
    elseif (row[ CODE_KSLP ] == 4 .and. year(dateEnd) == 2021) .and. isPermissible  // ���㭨���� ���
      if (age < 18)
        strArr += buildStringKSLP(row)
      else
        strArr := sBlank
        strArr += buildStringKSLP(row)
      endif
      aadd(t_mas, { strArr, (age < 18), row[ CODE_KSLP ] })
    elseif (row[ CODE_KSLP ] == 9 .and. year(dateEnd) == 2021) // ���� ᮯ������騥 �����������
      fl := conditionKSLP_9_21(, DToC(DOB), DToC(dateBegin),,,, arr2SlistN(mdiagnoz),)
      if !fl
        strArr := sBlank
      else
        // strArr := sAsterisk
      endif
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, fl, row[ CODE_KSLP ] })
    elseif (row[ CODE_KSLP ] == 10 .and. year(dateEnd) == 2021) .and. isPermissible // ��祭�� ��� 70 ���� ᮣ��᭮ ������樨
      strArr := iif(srok > 70, sAsterisk, sBlank)
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, .f., row[ CODE_KSLP ] })
    elseif (row[ CODE_KSLP ] == 19 .and. year(dateEnd) == 2023) .and. isPermissible  // �஢������ 1 �⠯� ����樭᪮� ॠ�����樨 ��樥�⮢
      strArr := sBlank
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, isPermissible, row[ CODE_KSLP ] })
    elseif (row[ CODE_KSLP ] == 20 .and. year(dateEnd) == 2023) .and. isPermissible   // �஢������ ᮯ஢���⥫쭮� ������⢥���� �࠯�� 
                                                                                      //�� �������⢥���� ������ࠧ������� � ������ � 
                                                                                      // ��樮����� �᫮���� � ᮮ⢥��⢨� � ������᪨�� ४�������ﬨ
      strArr := sBlank
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, isPermissible, row[ CODE_KSLP ] })
    else
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, isPermissible, row[ CODE_KSLP ] })
    endif
  next

  strStatus := '^<Esc>^ - �⪠�; ^<Enter>^ - ���⢥ত����; ^<Ins>^ - �⬥��� / ���� �⬥��'

  mlen := len(t_mas)

  // �ᯮ��㥬 popupN �� ������⥪� FunLib
    // if (ret := popupN(5,10,15,71,t_mas,i,color0,.t.,'fmenu_readerN',,;
  if (ret := popupN(5, 10, 5 + mlen + 1, 71, t_mas, i, color0, .t., 'fmenu_readerN', , ;
      '�⬥��� ����', col_tit_popup,, strStatus)) > 0
    for i := 1 to mlen
      if '*' == substr(t_mas[i, 1],2,1)
        m1var += alltrim(str(t_mas[i, 3])) + ','
        countKSLP += 1
      endif
    next
    if (nLast := RAt(',', m1var)) > 0
      m1var := substr(m1var, 1, nLast - 1)  // 㤠��� ��᫥���� �� �㦭�� ','
    endif
    s := m1var
  endif 

  Select(tmp_select)
  Return s

** 13.01.22 �᫨ ����, ��१������ ���祭�� ���� � ���� � HUMAN_2
Function put_str_kslp_kiro(arr,fl)
  Local lpc1 := '', lpc2 := ''

  if len(arr) > 4 .and. !empty(arr[5])
    if year(human->k_data) < 2021  // added 29.01.21
      lpc1 := lstr(arr[5, 1]) + ',' + lstr(arr[5, 2], 5, 2)
      if len(arr[5]) >= 4
        lpc1 += ',' + lstr(arr[5, 3]) + ',' + lstr(arr[5, 4], 5, 2)
      endif
    endif
  endif
  if len(arr) > 5 .and. !empty(arr[6])
    lpc2 := lstr(arr[6, 1]) + ',' + lstr(arr[6, 2], 5, 2)
  endif
  if !(padr(lpc1, 20) == human_2->pc1 .and. padr(lpc2, 10) == human_2->pc2)
    DEFAULT fl TO .t. // �����஢��� � ࠧ�����஢��� ������ � HUMAN_2
    select HUMAN_2
    if fl
      G_RLock(forever)
    endif

    // �������� ����� ����
    tmSel := select('HUMAN_2')
    if (tmSel)->(dbRlock())
      if year(human->k_data) < 2021  // added 29.01.21
        human_2->pc1 := lpc1
      endif
      human_2->pc2 := lpc2
      (tmSel)->(dbRUnlock())
    endif
    select(tmSel)
    if fl
      UnLock
    endif
  endif
  return NIL

** 04.02.21
// �����頥� �㬬� �⮣����� ���� �� ��᪥ ���� � ��� ����
function calcKSLP(cKSLP, dateSl)
  // cKSLP - ��ப� ��࠭��� ����
  // dateSl - ��� �����祭���� ����
  local summ := 1, i
  local fl := .f.
  local arrKSLP := getKSLPtable( dateSl )
  Local maxKSLP := 1.8  // �� ������樨 �� 21 ���
  local aSelected := Slist2arr(cKSLP)

  for i := 1 to len(aSelected)
    summ += (arrKSLP[val(aSelected[i]), 4] - 1)
  next
  if summ > maxKSLP
    summ := maxKSLP
  endif
  return summ

** 05.03.23
function defenition_KIRO(lkiro, ldnej, lrslt, lis_err, lksg, lDoubleSluch)
  // lkiro - ᯨ᮪ ��������� ���� ��� ���
  // ldnej - ���⥫쭮��� ���� � �����-����
  // lrslt - १���� ���饭�� (�ࠢ�筨� V009)
  // lis_err - �訡�� (�����-�)
  // lksg - ��� ���
  // lDoubleSluch - �� ���� �������� ����
  local vkiro := 0
  local cKSG := alltrim(LTrim(lksg))

  default lDoubleSluch to .f.
  if eq_any(cKSG, 'st37.002', 'st37.003', 'st37.006', 'st37.007', 'st37.024', 'st37.025', 'st37.026')
    // ��� �� ��㣠� ���. ॠ�����樨 � ��樮��� ᮣ��᭮ ��㦥���� ����᪠ �맣��� �� 13.02.23
    if (cKSG == 'st37.002' .and. ldnej < 14) .or. ;
        (cKSG == 'st37.003' .and. ldnej < 20) .or. ;
        (cKSG == 'st37.006' .and. ldnej < 12) .or. ;
        (cKSG == 'st37.007' .and. ldnej < 18) .or. ;
        ((cKSG == 'st37.024' .or. cKSG == 'st37.025' .or. cKSG == 'st37.026') .and. ldnej < 30)
      vkiro := 4
      return vkiro
    endif
  endif

  if lDoubleSluch // �� ���� �������� ����
    if ascan(lkiro, 1) > 0
      vkiro := 1
    elseif ascan(lkiro, 2) > 0
      vkiro := 2
    elseif ascan(lkiro, 3) > 0
      vkiro := 3
    elseif ascan(lkiro, 4) > 0
      vkiro := 4
    elseif  lis_err == 1 .and. ascan(lkiro, 5) > 0
      vkiro := 5
    elseif  lis_err == 1 .and. ascan(lkiro, 6) > 0
      vkiro := 6
    endif
  endif
  if ldnej > 3 // ������⢮ ���� ��祭�� 4 � ����� ����
    if ascan({102, 105, 107, 110, 202, 205, 207}, lrslt) > 0  // �஢�६ १���� ��祭��
      if ascan(lkiro, 3) > 0
        vkiro := 3
      elseif ascan(lkiro, 4) > 0
        vkiro := 4
      elseif lis_err == 1 .and. ascan(lkiro, 6) > 0 // ������塞 ��� ��ᮡ���� �奬� 娬���࠯�� (����=6)
        vkiro := 6
      endif
      return vkiro
    else
      return vkiro
    endif
  else // ������⢮ ���� ��祭�� 3 � ����� ����
    if isklichenie_KSG_KIRO(cKSG)
      return vkiro
    endif
    if ascan(lkiro, 1) > 0
      vkiro := 1
    elseif ascan(lkiro, 2) > 0
      vkiro := 2
    elseif ascan(lkiro, 4) > 0  // ����砥��� � ������� �����
      vkiro := 4
    elseif lis_err == 1 .and. ascan(lkiro, 5) > 0 // ������塞 ��� ��ᮡ���� �奬� 娬���࠯�� (����=5)
      vkiro := 5
    endif
  endif

  // // else  // �� ��㣮�
  //   if ldnej < 4  // ���⥫쭮��� ���� 3 �����-��� � �����
  //     if ascan(lkiro, 1) > 0
  //       vkiro := 1
  //     elseif ascan(lkiro, 2) > 0
  //       vkiro := 2
  //     elseif lis_err == 1 .and. ascan(lkiro, 5) > 0 // ������塞 ��� ��ᮡ���� �奬� 娬���࠯�� (����=5)
  //       vkiro := 5
  //     endif
  //   else          // ���⥫쭮��� ���� 4 �����-��� � �����
  //     if ascan({102, 105, 107, 110, 202, 205, 207}, lrslt) > 0
  //       if ascan(lkiro, 3) > 0
  //         vkiro := 3
  //       elseif ascan(lkiro, 4) > 0
  //         vkiro := 4
  //       elseif lis_err == 1 .and. ascan(lkiro, 6) > 0 // ������塞 ��� ��ᮡ���� �奬� 娬���࠯�� (����=6)
  //         vkiro := 6
  //       endif
  //     endif
  //   endif
  // // endif
  return vkiro

** 30.11.21
Function f_cena_kiro(/*@*/_cena, lkiro, dateSl )
  // _cena - �����塞�� 業�
  // lkiro - �஢��� ����
  // dateSl - ��� ����
  Local _akiro := {0, 1}
  local aKIRO, rowKIRO

  aKIRO := getKIROtable( dateSl )
  for each rowKIRO in aKIRO
    if rowKIRO[1] == lkiro
      if between_date(rowKIRO[5], rowKIRO[6], dateSl)
        _akiro := { lkiro, rowKIRO[4] }
      endif
    endif
  next

  _cena := round_5(_cena * _akiro[2], 0)  // ���㣫���� �� �㡫�� � 2019 ����
  return _akiro

** 01.02.23 ��।����� ����-� ᫮����� ��祭�� ��樥�� � �������� 業�
Function f_cena_kslp(/*@*/_cena, _lshifr, _date_r, _n_data, _k_data, lkslp, arr_usl, lPROFIL_K, arr_diag, lpar_org, lad_cr)
  Static s_1_may := 0d20160430, s_18 := 0d20171231, s_19 := 0d20181231
  static s_20 := 0d20201231
  Static s_kslp17 := { ;
    {1, 1.1, 0,  3}, ;   // �� 4 ���
    {2, 1.1, 75, 999} ;    // 75 ��� � ����
   }
  Static s_kslp16 := { ;
    {1, 1.1 , 0,  3}, ;   // �� 4 ���
    {2, 1.05, 75, 999} ;    // 75 ��� � ����
   }
  Local i, j, vksg, y := 0, fl, ausl := {}, s_kslp, _akslp := {}, sop_diag
  local countDays := _k_data - _n_data // ���-�� ���� ��祭��

  local savedKSLP, newKSLP := '', nLast
  local nameFunc := '', argc, row

  DEFAULT lad_cr TO space(10)

  _lshifr := alltrim(_lshifr) // ��७��

  if _k_data > s_20
    if empty(lkslp)
      return _akslp
    endif
    // �.3 ������樨
    // ������ ��樥�� ��।������ �� ������ ����㯫���� �� ��樮��୮� ��祭��.
    // �� ��砨 �ਬ������ ���� (�� �᪫�祭��� ����1) �����࣠���� ��ᯥ�⭮�� ����஫�.
    count_ymd( _date_r, _n_data, @y )
    lkslp := list2arr(lkslp)  // �८�ࠧ㥬 ��ப� �����⨬�� ���� � ���ᨢ

    savedKSLP := iif(empty(HUMAN_2->PC1), '"' + '"', '"' + alltrim(HUMAN_2->PC1) + '"')  // ����稬 ��࠭���� ����

    // argc := '(' + savedKSLP + ',' + ;
    // "'" + dtoc(_date_r) + "'," + "'" + dtoc(_n_data) + "'," + ;
    // lstr(lPROFIL_K) + ',' + "'" + _lshifr + "'," + lstr(lpar_org) + ',' + ;
    // "'" + arr2SlistN(arr_diag) + "'," + lstr(countDays) + ')'
    argc := '(' + savedKSLP + ',' + ;
    '"' + dtoc(_date_r) + '",' + '"' + dtoc(_k_data) + '",' + ;
    lstr(lPROFIL_K) + ',' + '"' + _lshifr + '",' + lstr(lpar_org) + ',' + ;
    '"' + arr2SlistN(arr_diag) + '",' + lstr(countDays) + ')'

    for each row in getKSLPtable( _k_data )
      // nameFunc := 'conditionKSLP_' + alltrim(str(row[1],2)) + '_' + last_digits_year(_n_data)
      nameFunc := 'conditionKSLP_' + alltrim(str(row[1],2)) + '_' + last_digits_year(_k_data)
      nameFunc := namefunc + argc

      if ascan( lkslp, row[1]) > 0 .and. &nameFunc
        newKSLP += alltrim(str(row[1], 2)) + ','
        aadd(_akslp, row[1])
        aadd(_akslp, row[4])
      endif
    next
    if (nLast := RAt(',', newKSLP)) > 0
      newKSLP := substr(newKSLP, 1, nLast - 1)  // 㤠��� ��᫥���� �� �㦭�� ','
    endif
    // ��⠭���� 業� � ��⮬ ����
    if !empty(_akslp)

      if year(_k_data) == 2021
        _cena := round_5(_cena * ret_koef_kslp_21(_akslp, year(_k_data)), 0)  // � 2019 ���� 業� ���㣫���� �� �㡫��
      elseif year(_k_data) == 2022
        // �� 2022 ������� �⠢�� ��樮��୮�� ���� 24322,6 ��
        // �� 2022 ������� �⠢�� ��� ���� �������� ��樮��� 13915,7 ��
        _cena := round_5(_cena + 24322.6 * ret_koef_kslp_21(_akslp, year(_k_data)), 0)
      elseif year(_k_data) == 2023  // ᮮ�騫 �맣�� 01.02.23
        // �� 2023 ������� �⠢�� ��樮��୮�� ���� 25986,7 ��
        // �� 2023 ������� �⠢�� ��� ���� �������� ��樮��� 15029,1 �� 
        _cena := round_5(_cena + 25986.7 * ret_koef_kslp_21(_akslp, year(_k_data)), 0)
      endif
      
      if year(_k_data) >= 2021
        // �������� ����� ����
        tmSel := select('HUMAN_2')
        if (tmSel)->(dbRlock())
          if year(human->k_data) < 2021  // added 29.01.21
            human_2->pc1 := newKSLP
          endif
          (tmSel)->(dbRUnlock())
        endif
        select(tmSel)
      endif
    endif

  elseif _k_data > s_19  // � 2019 ����
    if !empty(lkslp)
      if _lshifr == 'ds02.005' // ���, lkslp = 12,13,14
        s_kslp := { ;
          {12, 0.60}, ;
          {13, 1.10}, ;
          {14, 0.19} ;
        }
        for i := 1 to len(arr_usl)
          if valtype(arr_usl[i]) == 'A'
            aadd(ausl, alltrim(arr_usl[i, 1]))  // ���ᨢ ���������
          else
            aadd(ausl, alltrim(arr_usl[i]))    // ���ᨢ ��������
          endif
        next i
        j := 0 // ���� - 1 �奬�
        if ascan(ausl, 'A11.20.031') > 0  // �ਮ
          j := 13  // 6 �奬�
          if ascan(ausl, 'A11.20.028') > 0 // ��⨩ �⠯
            j := 0   // 2 �奬�
          endif
        elseif ascan(ausl, 'A11.20.025.001') > 0  // ���� �⠯
          j := 12  // 3 �奬�
          if ascan(ausl, 'A11.20.036') > 0  // �������騩 ��ன �⠯
            j := 12  // 4 �奬�
          elseif ascan(ausl, 'A11.20.028') > 0  // �������騩 ��⨩ �⠯
            j := 12  // 5 �奬�
          endif
        elseif ascan(ausl, 'A11.20.030.001') > 0  // ⮫쪮 �⢥��� �⠯
          j := 14  // 7 �奬�
        endif
        if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
          aadd(_akslp, s_kslp[i, 1])
          aadd(_akslp, s_kslp[i, 2])
          _cena := round_5(_cena * s_kslp[i, 2], 0)  // � 2019 ���� 業� ���㣫���� �� �㡫��
        endif
        if !empty(_akslp) .and. _k_data > 0d20191231 // � 2020 ����
          _akslp[1] += 3 // �.�. � 2020 ���� ���� ��� ��� 15,16,17
        endif
      else // ��⠫�� ���
        s_kslp := { ;
          { 1, 1.10, 0,  0}, ;  // �� 1 ����
          { 2, 1.10, 1,  3}, ;  // �� 1 �� 3 ��� �����⥫쭮
          { 4, 1.02, 75, 999}, ;  // 75 � ����
          { 5, 1.10, 60, 999} ;   // 60 � ���� � ��⥭��
        }
        count_ymd(_date_r, _n_data, @y)
        lkslp := list2arr(lkslp)
        for j := 1 to len(lkslp)
          if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0 // �⮨� ����� ���� � ��࠭��� ���
            if between(y, s_kslp[i, 3], s_kslp[i, 4])
              fl := .t.
              if lkslp[j] == 4
                fl := (lprofil_k != 16 ; // ��樥�� ����� �� �� ��஭⮫����᪮� �����
                        .and. !(_lshifr == 'st38.001'))
              elseif lkslp[j] == 5
                sop_diag := aclone(arr_diag)
                del_array(sop_diag, 1)
                fl := (lprofil_k == 16 .and. ; // ��樥�� ����� �� ��஭⮫����᪮� �����
                        !(_lshifr == 'st38.001') .and. ;//!(alltrim(arr_diag[1]) == 'R54') .and. ; // � �᭮��� ��������� �� <R54-������>
                        ascan(sop_diag, {|x| alltrim(x) == 'R54'}) > 0 ) // � ᮯ.��������� ���� <R54-������>
              endif
              if fl
                aadd(_akslp, s_kslp[i, 1])
                aadd(_akslp, s_kslp[i, 2])
                exit
              endif
            endif
          endif
        next
        if ascan(lkslp, 11) > 0 .and. lpar_org > 1 // ࠧ�襭� ����=11 � ������� ���� �࣠��
          aadd(_akslp, 11)
          aadd(_akslp, 1.2)
        endif
        if ascan(lkslp, 18) > 0 .and. 'cr6' $ lad_cr // ࠧ�襭� ����=18 � ��� ᫮����� COVID-19
          aadd(_akslp, 18)
          aadd(_akslp, 1.2)
        endif
        if !empty(_akslp)
          _cena := round_5(_cena * ret_koef_kslp(_akslp), 0)  // � 2019 ���� 業� ���㣫���� �� �㡫��
        endif
      endif
    endif
  elseif _k_data > s_18  // � 2018 ����
    if !empty(lkslp)
      if _lshifr == '2005.0' // ���, lkslp = 12,13,14
        s_kslp := { ;
          {12, 0.60}, ;
          {13, 1.10}, ;
          {14, 0.19} ;
        }
        for i := 1 to len(arr_usl)
          if valtype(arr_usl[i]) == 'A'
            aadd(ausl, alltrim(arr_usl[i, 1]))  // ���ᨢ ���������
          else
            aadd(ausl, alltrim(arr_usl[i]))    // ���ᨢ ��������
          endif
        next i
        j := 0 // ���� - 1 �奬�
        if ascan(ausl, 'A11.20.031') > 0  // �ਮ
          j := 13  // 6 �奬�
          if ascan(ausl, 'A11.20.028') > 0 // ��⨩ �⠯
            j := 0   // 2 �奬�
          endif
        elseif ascan(ausl, 'A11.20.025.001') > 0  // ���� �⠯
          j := 12  // 3 �奬�
          if ascan(ausl, 'A11.20.036') > 0  // �������騩 ��ன �⠯
            j := 12  // 4 �奬�
          elseif ascan(ausl, 'A11.20.028') > 0  // �������騩 ��⨩ �⠯
            j := 12  // 5 �奬�
          endif
        elseif ascan(ausl, 'A11.20.030.001') > 0  // ⮫쪮 �⢥��� �⠯
          j := 14  // 7 �奬�
        endif
        if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
          aadd(_akslp, s_kslp[i, 1])
          aadd(_akslp, s_kslp[i, 2])
          _cena := round_5(_cena * s_kslp[i, 2], 1)
        endif
      else // ��⠫�� ���
        s_kslp := { ;
          { 1, 1.10, 0,  0}, ;  // �� 1 ����
          { 2, 1.10, 1,  3}, ;  // �� 1 �� 3 ��� �����⥫쭮
          { 4, 1.05, 75, 999}, ;  // 75 � ����
          { 5, 1.10, 60, 999} ;   // 60 � ���� � ��⥭��
        }
        count_ymd(_date_r, _n_data, @y)
        lkslp := list2arr(lkslp)
        for j := 1 to len(lkslp)
          if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0
            if between(i, 1, 5) .and. between(y, s_kslp[i, 3], s_kslp[i, 4])
              aadd(_akslp, s_kslp[i, 1])
              aadd(_akslp, s_kslp[i, 2])
              _cena := round_5(_cena * s_kslp[i, 2], 1)
              exit
            endif
          endif
        next
      endif
    endif
  elseif _k_data > s_1_may ;                 // � 1 ��� 2016 ����
              .and. left(_lshifr,1) == '1' ; // ��㣫������ ��樮���
              .and. !('.' $ _lshifr)         // �� ��� ���
    count_ymd(_date_r, _n_data, @y)
    vksg := int(val(right(_lshifr, 3))) // ��᫥���� �� ���� - ��� ���
    if (fl := vksg < 900) // �� ������
      if year(_k_data) > 2016
        s_kslp := s_kslp17
        if y < 1 .and. between(vksg, 105, 111) // �� 1 ���� � ����� ���� �� ஦�����
          fl := .f.
        endif
      else
        s_kslp := s_kslp16
      endif
      if fl
        for i := 1 to len(s_kslp)
          if between(y, s_kslp[i, 3], s_kslp[i, 4])
            aadd(_akslp, s_kslp[i, 1])
            aadd(_akslp, s_kslp[i, 2])
            _cena := round_5(_cena * s_kslp[i, 2], 1)
            exit
          endif
        next
      endif
    endif
  endif
  return _akslp
  
** 23.01.19 ������ �⮣��� ����
Function ret_koef_kslp(akslp)
  Local k := 1
  if valtype(akslp) == 'A' .and. len(akslp) >= 2
    k := akslp[2]
    if len(akslp) >= 4
      k += akslp[4] - 1
    endif
  endif
  return k
  
  
//** 08.02.22 ������ �⮣��� ���� ��� 21 ����
** 01.02.23 ������ �⮣��� ���� ��� 21 ����
Function ret_koef_kslp_21(akslp, nYear)
  Local k := 1  // ���� ࠢ�� 1

  if valtype(akslp) == 'A' .and. len(akslp) >= 2
    if nYear == 2021
      for i := 1 TO len(akslp) STEP 2
        if i == 1
          k := akslp[2]
        else
          k += (akslp[i + 1] - 1)
        endif
      next
      if k > 1.8
        k := 1.8  // ᮣ��᭮ �.3 ������樨
      endif
    // elseif nYear == 2022
    elseif nYear >= 2022
      k := 0
      for i := 1 TO len(akslp) STEP 2
        if i == 1 // �������� ⮫쪮 ���� ����
          k += akslp[2]
        // else
        //   k += akslp[i + 1]
        endif
      next
    endif
  endif
  return k

** 01.02.23 ������ �⮣��� ���� ��� �����⭮�� ����
Function ret_koef_kslp_21_XML(akslp, tKSLP, nYear)
  Local k := 1  // ���� ࠢ�� 1
  local iAKSLP

  if valtype(akslp) == 'A'
    if nYear == 2021
      for iAKSLP := 1 to len(akslp)
        if (cKSLP := ascan(tKSLP, {|x| x[1] == akslp[ iAKSLP ] })) > 0
          k += (tKSLP[ cKSLP, 4 ] - 1)
        endif
      next
      if k > 1.8
        k := 1.8  // ᮣ��᭮ �.3 ������樨
      endif
    elseif nYear >= 2022
      k := 0
      for iAKSLP := 1 to len(akslp)
        if (cKSLP := ascan(tKSLP, {|x| x[1] == akslp[ iAKSLP ] })) > 0
          k += tKSLP[ cKSLP, 4 ]
        endif
      next
    endif
  endif
  return k

** 03.03.23
function isklichenie_KSG_KIRO(cKSG)
  local arrKSG := { ;
    'st02.001', ;
    'st02.002', ;
    'st02.003', ;
    'st02.004', ;
    'st02.010', ;
    'st02.011', ;
    'st03.002', ;
    'st05.008', ;
    'st08.001', ;
    'st08.002', ;
    'st08.003', ;
    'st12.010', ;
    'st12.011', ;
    'st14.002', ;
    'st15.008', ;
    'st15.009', ;
    'st16.005', ;
    'st19.007', ;
    'st19.038', ;
    'st19.125', ;
    'st19.126', ;
    'st19.127', ;
    'st19.128', ;
    'st19.129', ;
    'st19.130', ;
    'st19.131', ;
    'st19.132', ;
    'st19.133', ;
    'st19.134', ;
    'st19.135', ;
    'st19.136', ;
    'st19.137', ;
    'st19.138', ;
    'st19.139', ;
    'st19.140', ;
    'st19.141', ;
    'st19.142', ;
    'st19.143', ;
    'st19.082', ;
    'st19.090', ;
    'st19.094', ;
    'st19.097', ;
    'st19.100', ;
    'st20.005', ;
    'st20.006', ;
    'st20.010', ;
    'st21.001', ;
    'st21.002', ;
    'st21.003', ;
    'st21.004', ;
    'st21.005', ;
    'st21.006', ;
    'st21.009', ;
    'st25.004', ;
    'st27.012', ;
    'st30.006', ;
    'st30.010', ;
    'st30.011', ;
    'st30.012', ;
    'st30.014', ;
    'st31.017', ;
    'st32.002', ;
    'st32.012', ;
    'st32.016', ;
    'st34.002', ;
    'st36.001', ;
    'st36.007', ;
    'st36.009', ;
    'st36.010', ;
    'st36.011', ;
    'st36.024', ;
    'st36.025', ;
    'st36.026', ;
    'st36.028', ;
    'st36.029', ;
    'st36.030', ;
    'st36.031', ;
    'st36.032', ;
    'st36.033', ;
    'st36.034', ;
    'st36.035', ;
    'st36.036', ;
    'st36.037', ;
    'st36.038', ;
    'st36.039', ;
    'st36.040', ;
    'st36.041', ;
    'st36.042', ;
    'st36.043', ;
    'st36.044', ;
    'st36.045', ;
    'st36.046', ;
    'st36.047', ;
    'ds02.001', ;
    'ds02.006', ;
    'ds02.007', ;
    'ds02.008', ;
    'ds05.005', ;
    'ds08.001', ;
    'ds08.002', ;
    'ds08.003', ;
    'ds15.002', ;
    'ds15.003', ;
    'ds19.028', ;
    'ds19.033', ;
    'ds19.097', ;
    'ds19.098', ;
    'ds19.099', ;
    'ds19.100', ;
    'ds19.101', ;
    'ds19.102', ;
    'ds19.103', ;
    'ds19.104', ;
    'ds19.105', ;
    'ds19.106', ;
    'ds19.107', ;
    'ds19.108', ;
    'ds19.109', ;
    'ds19.110', ;
    'ds19.111', ;
    'ds19.112', ;
    'ds19.113', ;
    'ds19.114', ;
    'ds19.115', ;
    'ds19.057', ;
    'ds19.063', ;
    'ds19.067', ;
    'ds19.071', ;
    'ds19.075', ;
    'ds20.002', ;
    'ds20.003', ;
    'ds20.006', ;
    'ds21.002', ;
    'ds21.003', ;
    'ds21.004', ;
    'ds21.005', ;
    'ds21.006', ;
    'ds21.007', ;
    'ds25.001', ;
    'ds27.001', ;
    'ds34.002', ;
    'ds36.001', ;
    'ds36.012', ;
    'ds36.013', ;
    'ds36.015', ;
    'ds36.016', ;
    'ds36.017', ;
    'ds36.018', ;
    'ds36.019', ;
    'ds36.020', ;
    'ds36.021', ;
    'ds36.022', ;
    'ds36.023', ;
    'ds36.024', ;
    'ds36.025', ;
    'ds36.026', ;
    'ds36.027', ;
    'ds36.028', ;
    'ds36.029', ;
    'ds36.030', ;
    'ds36.031', ;
    'ds36.032', ;
    'ds36.033', ;
    'ds36.034', ;
    'ds36.035' ;   
  }

  return ascan(arrKsg, cKSG) > 0