#include 'inkey.ch'
#include 'common.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 25.09.23
Function ret_arr_shema_new(k, dk) 
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
    stYear := _data
  endif
  return ashema[k]

// 04.02.22
Function ret_arr_shema(k, k_data) 
  // �����頥� �奬� ������⢥���� �࠯�� ��� ��������� �� ����
  Static ashema := {{}, {}, {}}
  Local i
  local _data := 0d20210101 // 21 ���

  Default k_data TO sys_date
  _data := k_data

  if empty(ashema[1])
    R_Use(exe_dir + prefixFileRefName(_data) + 'shema', , 'IT')
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
  
  