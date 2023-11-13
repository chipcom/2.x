#include 'inkey.ch'
#include 'common.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'


// 11.09.23 �஢�ઠ �ࠢ��쭮�� ᮮ⢥�����饩 �⠤�� �� ᮮ⢥�����饬� �ࠢ�筨�� 
Function f_verify_tnm(n, lkod, ldiag, ar)
  Local sn := lstr(n)
  local sd
  Local fl := .t., lal := 'n' + sn
  local s := {'', 'ST', 'T', 'N', 'M'}[n]
  local s1 := {' ��⨢���������� � �⪠���', '�⠤�� �����������', 'Tumor', 'Nodus', 'Metastasis'}[n]
  Local smsg := '���������: � �ࠢ�筨�� N00' + sn + ' �� ������� �⠤�� ����������� ' + s + '=' + lstr(lkod) + ' ��� �������� ' + ldiag
  local aTmp, it, aTmpDS
  local nameFunc := 'getN00' + lstr(n) + '()'
  local nameFuncDS := 'getDS_N00' + lstr(n) + '()'

  aTmp := &nameFunc
  if (it := ascan(aTmp, {|x| x[2] == lkod})) > 0
    if empty(aTmp[it, 3])
      aTmpDS := &nameFuncDS
      sd := padr(ldiag, 5)
      if (it := ascan(aTmpDS, {|x| padr(x[1], 5) == sd})) > 0
        fl := .f.
        aadd(ar, smsg)
      else
        sd := padr(ldiag, 3)
        if (it := ascan(aTmpDS, {|x| padr(x[1], 5) == sd})) > 0
          fl := .f.
          aadd(ar, smsg)
        endif
  
      endif
    elseif len(alltrim(aTmp[it, 3])) == 5
      if !(left(ldiag, 5) == aTmp[it, 3])
        fl := .f.
        aadd(ar, smsg)
      endif
    else
      if !(left(ldiag, 3) == alltrim(aTmp[it, 3]))
        fl := .f.
        aadd(ar, smsg)
      endif
    endif

  elseif  (it := ascan(aTmp, {|x| empty(x[2])})) > 0
    if empty(aTmp[it, 3])
      aTmpDS := &nameFuncDS
      sd := padr(ldiag, 5)
      if (it := ascan(aTmpDS, {|x| padr(x[1], 5) == sd})) > 0
        fl := .f.
        aadd(ar, smsg)
      else
        sd := padr(ldiag, 3)
        if (it := ascan(aTmpDS, {|x| padr(x[1], 5) == sd})) > 0
          fl := .f.
          aadd(ar, smsg)
        endif
  
      endif
    elseif len(alltrim(aTmp[it, 3])) == 5
      if !(left(ldiag, 5) == aTmp[it, 3])
        fl := .f.
        aadd(ar, smsg)
      endif
    else
      if !(left(ldiag, 3) == alltrim(aTmp[it, 3]))
        fl := .f.
        aadd(ar, smsg)
      endif
    endif

  else
    fl := .f.
    aadd(ar, smsg)
  endif

  return fl

// 02.11.23 �㭪�� ��।������ ���ᨢ� � �-�� ।���஢���� ���� ����
function f_define_tnm(n, ldiag)
  Local aRet := {}, sd, fl := .f.
  local aTmp, it
  local nameFunc := 'getDS_N00' + lstr(n) + '()'

  aTmp := &nameFunc
  sd := padr(ldiag, 5)
  if (it := ascan(aTmp, {|x| padr(x[1], 5) == sd})) > 0
    aRet := aclone(aTmp[it, 2])
    fl := .t.
  endif
  if ! fl
    sd := padr(ldiag, 3)
    if ((it := ascan(aTmp, {|x| padr(x[1], 3) == sd})) > 0) .and. len(aTmp[it, 1]) == 3
      aRet := aclone(aTmp[it, 2])
      fl := .t.
    endif
  endif
  if ! fl
    sd := space(5)
    if (it := ascan(aTmp, {|x| padr(x[1], 5) == sd})) > 0
      aRet := aclone(aTmp[it, 2])
    endif
  endif
  return aRet

// // 22.10.19 �஢�ઠ �ࠢ��쭮�� ᮮ⢥�����饩 �⠤�� �� ᮮ⢥�����饬� �ࠢ�筨��
// Function f_verify_tnm_old(n, lkod, ldiag, ar)
//   Local sn := lstr(n), sd
//   Local fl := .t., lal := 'n' + sn, polek, poled, s := {'', 'ST', 'T', 'N', 'M'}[n]
//   Local smsg := '���������: � �ࠢ�筨�� N00' + sn + ' �� ������� �⠤�� ����������� ' + s + '=' + lstr(lkod) + ' ��� �������� ' + ldiag

//   polek := lal + '->kod_' + s
//   poled := lal + '->ds_' + s
//   if select(lal) == 0
//     R_Use(dir_exe + '_mo_N00' + sn, {cur_dir + '_mo_N00' + sn, cur_dir + '_mo_N00' + sn + 'd'}, lal)
//   endif
//   dbSelectArea(lal) // ����� �� �ࠢ�筨� N0...
//   set order to 1    // ��४������� �� ������ �� ����
//   find (str(lkod, 6))
//   if found()
//     if empty(&poled) // �᫨ �� ��������� ���� ��������
//       sd := padr(ldiag, 5)
//       set order to 2 // ��४������� �� ������ �� ��������
//       find (sd)      // ���� ��⨧��筮�� ��������
//       if found()     // �᫨ ��諨 - �訡��
//         fl := .f.
//         aadd(ar, smsg)
//       else
//         sd := padr(ldiag, 3)
//         find (sd)    // ���� ���姭�筮�� ��������
//         if found() .and. sd == alltrim(&poled)  // �᫨ ��諨 - �訡��
//           fl := .f.
//           aadd(ar,smsg)
//         endif
//       endif
//     elseif len(alltrim(&poled)) == 5
//       if !(left(ldiag, 5) == &poled)
//         fl := .f.
//         aadd(ar,smsg)
//       endif
//     else
//       if !(left(ldiag, 3) == alltrim(&poled))
//         fl := .f.
//         aadd(ar,smsg)
//       endif
//     endif
//   else
//     fl := .f.
//     aadd(ar, smsg)
//   endif
//   return fl

// 14.01.19 �஢�ઠ �ࠢ��쭮�� ������� �⠤�� �� �ࠢ�筨�� N006 � get'e
Function f_valid_tnm(g)
  Local buf, fl_found, s := padr(mkod_diag, 5)

  /*if !emptyany(m1ONK_T,m1ONK_N,m1ONK_M)
    select N6
    find (s)
    if !(fl_found := found())
      s := padr(mkod_diag, 3)
      find (s)
      fl_found := (found() .and. s == alltrim(n6->ds_gr))
    endif
    if fl_found
      find (padr(s, 5)+str(m1ONK_T, 6)+str(m1ONK_N, 6)+str(m1ONK_M, 6))
      if found()
        if m1stad != n6->id_st
          m1stad := n6->id_st
          mSTAD  := padr(inieditspr(A__MENUVERT, mm_N002, m1STAD), 5)
          buf := save_maxrow()
          stat_msg('��ࠢ�筨� N006: �� ��⠭�� �⠤�� TNM ��ࠢ���� ���� '�⠤��'') ; mybell(1,OK)
          rest_box(buf)
          update_get('mstad')
        endif
      else
        func_error(2,'��ࠢ�筨� N006: �����४⭮� ��⠭�� �⠤�� TNM')
      endif
    endif
  endif*/
  return .t.

// 25.09.23
Function ret_arr_shema(k, dk) 
  // �����頥� �奬� ������⢥���� �࠯�� ��� ��������� �� ����
  Static ashema := {{}, {}, {}}
  static stYear
  Local i, db, aTable, row, arr := {}
  local year_dk, dBeg, dEnd

  if ValType(dk) == 'N'
    year_dk := dk
  elseif ValType(dk) == 'D'
    year_dk := year(dk)
  endif

  if isnil(stYear) .or. empty(ashema[1]) .or. year_dk != stYear
    ashema := {{}, {}, {}}
    arr := getV024(dk)
    aadd(ashema[1], {'-----     ��� �奬� ������⢥���� �࠯��', padr('���', 10)})
    aeval(arr, {|x, j| iif(left(x[1], 2) == 'sh', aadd(ashema[1], {padr(x[1], 10) + left(x[2], 68), padr(x[1], 10)}), '')})
    aeval(arr, {|x, j| iif(left(x[1], 2) == 'mt', aadd(ashema[2], {padr(x[1], 10) + left(x[2], 68), padr(x[1], 10)}), '')})
    aeval(arr, {|x, j| iif(left(x[1], 2) == 'fr', aadd(ashema[3], {padr(x[1], 10) + left(x[2], 68), padr(x[1], 10), 0, 0}), '')})
    for i := 1 to len(ashema[3])
      ashema[3, i, 3] := int(val(substr(ashema[3, i, 1], 3, 2)))
      ashema[3, i, 4] := int(val(substr(ashema[3, i, 1], 6, 2)))
    next
    stYear := year_dk
  endif
  return ashema[k]

// 04.02.22
Function ret_arr_shema_old(k, k_data) 
  // �����頥� �奬� ������⢥���� �࠯�� ��� ��������� �� ����
  Static ashema := {{}, {}, {}}
  Local i
  local _data := 0d20210101 // 21 ���

  Default k_data TO sys_date
  _data := k_data

  if empty(ashema[1])
    R_Use(dir_exe + prefixFileRefName(_data) + 'shema', , 'IT')
    aadd(ashema[1], {'-----     ��� �奬� ������⢥���� �࠯��', padr('���', 10)})
    index on kod to (cur_dir + 'tmp_schema') for left(kod, 2) == 'sh' .and. between_date(it->datebeg, it->dateend, _data)
    dbeval({|| aadd(ashema[1], {it->kod + left(it->name, 68), it->kod}) })
    index on kod to (cur_dir + 'tmp_schema') for left(kod, 2) == 'mt' .and. between_date(it->datebeg, it->dateend, _data)
    dbeval({|| aadd(ashema[2], {it->kod + left(it->name, 68), it->kod}) })
    index on kod to (cur_dir + 'tmp_schema') for left(kod, 2) == 'fr' .and. between_date(it->datebeg, it->dateend, _data)
    dbeval({|| aadd(ashema[3], {it->kod + left(it->name, 68), it->kod, 0, 0}) })
    use
    for i := 1 to len(ashema[3])
      ashema[3, i, 3] := int(val(substr(ashema[3, i, 1], 3, 2)))
      ashema[3, i, 4] := int(val(substr(ashema[3, i, 1], 6, 2)))
    next
  endif
  return ashema[k]

// 15.02.20
Function f_is_oncology(r, /*@*/_onk_smp)
  Local i, k, mdiagnoz, lusl_ok, lprofil, lzno := 0, lyear, lk_data
  
  if r == 1
    lk_data := human->k_data
    lyear := year(human->k_data)
    lusl_ok := human_->USL_OK
    mdiagnoz := diag_to_array()
    lprofil := human_->profil
    if human->OBRASHEN == '1'
      lzno := 1
    endif
  else
    lk_data := mk_data
    lyear := year(mk_data)
    lusl_ok := m1USL_OK
    mdiagnoz := diag_to_array(' ')
    lprofil := m1profil
    lzno := m1ds_onk
  endif
  if empty(mdiagnoz)
    aadd(mdiagnoz, space(6))
  endif
  k := lzno
  if lyear >= 2021 .and. (left(mdiagnoz[1], 1) == 'C' .or. between(left(mdiagnoz[1], 3), 'D00', 'D09') ;
          .or. between(left(mdiagnoz[1], 3), 'D45', 'D47')) // ᮣ��᭮ ����� 04-18-05 �� 12.02.21
    k := 2
  elseif lyear >= 2019 .and. (left(mdiagnoz[1], 1) == 'C' .or. between(left(mdiagnoz[1], 3), 'D00', 'D09'))
    k := 2
  elseif lyear == 2018 .and. left(mdiagnoz[1], 1) == 'C'
    k := 2
  elseif left(mdiagnoz[1], 3) == 'D70' .and. lk_data < 0d20200401 // ⮫쪮 �� 1 ��५� 2020 ����
    for i := 2 to len(mdiagnoz)
      if left(mdiagnoz[i], 1) == 'C'
        if between(left(mdiagnoz[i], 3), 'C00', 'C80') .or. left(mdiagnoz[i], 3) == 'C97'
          k := 2
        endif
      endif
    next
  endif
  if k == 2
    yes_oncology := .t.
    m1ds_onk := 0
    mds_onk := inieditspr(A__MENUVERT, mm_danet, m1ds_onk)
    if lprofil == 158
      _onk_smp := k := 1
    endif
  endif
  if lusl_ok == 4 // ᪮�� ������
    _onk_smp := k
    k := 0
  endif
  return k

// 19.08.18
Function when_ds_onk()

  Private yes_oncology := .f.
  f_is_oncology(2)
  return !yes_oncology
  
// 29.01.19
Function is_lymphoid(_diag) // ��� �஢�⢮୮� ��� ���䮨���� ⪠���
  
  return !empty(_diag) .and. between(left(_diag, 3), 'C81', 'C96')
  
// 02.02.19
Function ret_str_onc(k, par)
  Static arr := { ;
    '�㬬�ୠ� �砣���� ���� (� ����)', ;  // 1 lstr_sod
    '���-�� �ࠪ権', ;                     // 2 lstr_fr
    '���� ⥫� (� ��.)', ;                 // 3 lstr_wei
    '���� (� �)', ;                        // 4 lstr_hei
    '���頤� ���-� ⥫� (� ��.�)', ;       // 5 lstr_bsa
    '����� �������� ������⢥����� �९��� (���� ��������)', ; // 6 lstr_err
    '�奬� ������⢥���� �࠯��', ;        // 7 lstr_she
    '���᮪ ������⢥���� �९��⮢', ;    // 8 lstr_lek
    '�஢������� �� ��䨫��⨪� �譮�� � ࢮ⭮�� �䫥��'}     // 9 lstr_ptr
  Local s := arr[k]

  DEFAULT par TO 1
  return iif(par == 1, s, space(len(s)))
  
  