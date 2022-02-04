
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 04.02.22
Function ret_arr_shema(k, k_data) 
  // возвращает схемы лекарственных терапий для онкологии на дату
  Static ashema := {{}, {}, {}}
  Local i
  local _data := 0d20210101 // 21 год

  Default k_data TO sys_date
  _data := k_data

  if empty(ashema[1])
    R_Use(exe_dir + prefixFileRefName(_data) + 'shema', , 'IT')
    aadd(ashema[1], {"-----     без схемы лекарственной терапии", padr("нет", 10)})
    index on kod to (cur_dir + "tmp_schema") for left(kod, 2) == "sh" .and. between_date(it->datebeg, it->dateend, _data)
    dbeval({|| aadd(ashema[1], {it->kod + left(it->name, 68), it->kod}) })
    index on kod to (cur_dir + "tmp_schema") for left(kod, 2) == "mt" .and. between_date(it->datebeg, it->dateend, _data)
    dbeval({|| aadd(ashema[2], {it->kod + left(it->name, 68), it->kod}) })
    index on kod to (cur_dir + "tmp_schema") for left(kod, 2) == "fr" .and. between_date(it->datebeg, it->dateend, _data)
    dbeval({|| aadd(ashema[3], {it->kod + left(it->name, 68), it->kod, 0, 0}) })
    use
    for i := 1 to len(ashema[3])
      ashema[3,i,3] := int(val(substr(ashema[3,i,1],3,2)))
      ashema[3,i,4] := int(val(substr(ashema[3,i,1],6,2)))
    next
  endif
  return ashema[k]

***** 15.02.20
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
    mdiagnoz := diag_to_array(" ")
    lprofil := m1profil
    lzno := m1ds_onk
  endif
  if empty(mdiagnoz)
    aadd(mdiagnoz, space(6))
  endif
  k := lzno
  if lyear >= 2021 .and. (left(mdiagnoz[1],1) == "C" .or. between(left(mdiagnoz[1], 3), "D00", "D09") ;
          .or. between(left(mdiagnoz[1], 3), "D45", "D47")) // согласно письму 04-18-05 от 12.02.21
    k := 2
  elseif lyear >= 2019 .and. (left(mdiagnoz[1], 1) == "C" .or. between(left(mdiagnoz[1], 3), "D00", "D09"))
    k := 2
  elseif lyear == 2018 .and. left(mdiagnoz[1], 1) == "C"
    k := 2
  elseif left(mdiagnoz[1], 3) == "D70" .and. lk_data < 0d20200401 // только до 1 апреля 2020 года
    for i := 2 to len(mdiagnoz)
      if left(mdiagnoz[i],1) == "C"
        if between(left(mdiagnoz[i], 3), "C00", "C80") .or. left(mdiagnoz[i], 3) == "C97"
          k := 2
        endif
      endif
    next
  endif
  if k == 2
    yes_oncology := .t.
    m1ds_onk := 0 ; mds_onk := inieditspr(A__MENUVERT, mm_danet, m1ds_onk)
    if lprofil == 158
      _onk_smp := k := 1
    endif
  endif
  if lusl_ok == 4 // скорая помощь
    _onk_smp := k
    k := 0
  endif
  return k

***** 19.08.18
Function when_ds_onk()
  Private yes_oncology := .f.
  f_is_oncology(2)
  return !yes_oncology
  
***** 29.01.19
Function is_lymphoid(_diag) // ЗНО кроветворной или лимфоидной тканей
  return !empty(_diag) .and. between(left(_diag, 3), "C81", "C96")
  
  