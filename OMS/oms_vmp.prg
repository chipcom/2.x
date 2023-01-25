#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** 25.01.23 в GET-е вернуть строку из справочника V018
Function f_get_vidvmp(k, r, c, diagnoze) 
  // Static sy := 0, 
  local arr, svidvmp := ''
  Local ret, ret_arr
  local sTmp := ''
  local y := year(mk_data)
  local row, arr_vid := {}, kk

  local arrV019 := getV019(mk_data)
  local arrV018 := getV018(mk_data)

  diagnoze := alltrim(diagnoze)
  if y < 2018
    y := 2018
  endif

  for each row in arrV019   // только с нужным диагнозом
    if (kk := ascan(row[3], {|x| x == alltrim(diagnoze) })) > 0
      aadd(arr_vid, row[4])
    endif
  next

  arr := {}
  for i := 1 to len(arrV018)
    if (kk := ascan(arr_vid, {|x| x == alltrim(arrV018[i, 1]) })) > 0
      sTmp := padl(arrV018[i, 1], 5) + '.'
      aadd(arr, {padr(sTmp + arrV018[i, 2], 76), arrV018[i, 1]})
    endif
  next
  if empty(k)
    k := svidvmp
  endif
  popup_2array(arr, -r, c, k, 1, @ret_arr, 'Выбор вида ВМП', 'GR+/RB', 'BG+/RB,N/BG')
  if valtype(ret_arr) == 'A'
    ret := array(2)
    svidvmp := ret_arr[2]
    ret[1] := ret_arr[2]
    ret[2] := ret_arr[1]
  endif
  return ret

** 25.01.23 в GET-е вернуть строку из справочника V019
Function f_get_metvmp(k, r, c, lvidvmp, modpac)
  Local arr := {}, i, ret, ret_arr

  local arrV019 := getV019(mk_data)
  // local arrV018 := getV018(mk_data)

  if empty(lvidvmp) .or. empty(modpac)
    return NIL
  endif

  for i := 1 to len(arrV019)
    if arrV019[i, 4] == alltrim(lvidvmp) .and. arrV019[i, 8] == modpac
      aadd(arr, {padr(str(arrV019[i, 1], 4) + '.' + arrV019[i, 2], 76), arrV019[i, 1]})
    endif
  next
  if empty(arr)
    func_error(4, 'В справочнике V019 не найдено методов для вида ВМП ' + lvidvmp)
    return NIL
  endif
  popup_2array(arr,-r,c,k,1,@ret_arr, 'Выбор метода ВМП для '+lvidvmp, 'GR+/RB*', 'N/RB*,W+/N')
  if valtype(ret_arr) == 'A'
    ret := array(2)
    ret[1] := ret_arr[2]
    ret[2] := ret_arr[1]
  endif
  return ret

** 25.01.23 в GET-е вернуть строку из getV022()
Function f_get_mmodpac(k, r, c, lvidvmp, sDiag)
  Local arr := {}, i, ret, ret_arr
  local diag := alltrim(sDiag)
  local model := getV022()
  local row

  local arrV019 := getV019(mk_data)
  // local arrV018 := getV018(mk_data)

  if empty(lvidvmp) .or. empty(diag)
    return NIL
  endif

  for i := 1 to len(arrV019)
    if arrV019[i, 4] == alltrim(lvidvmp) .and. ( ascan(arrV019[i, 3], diag) > 0 )
      for each row in model
        if row[1] == arrV019[i, 8]
          if ascan(arr, {|x| x[2] == row[1]}) == 0
            aadd(arr, {padr(alltrim(row[2]), 76), row[1]})
            exit
          endif
        endif
      next
    endif
  next
  if empty(arr)
    func_error(4, 'В справочнике V022 не найдено моделей пациентов для вида ВМП ' + lvidvmp)
    return NIL
  endif
  popup_2array(arr,-r,c,k,1,@ret_arr, 'Выбор модели пациента для '+lvidvmp, 'GR+/RB*', 'N/RB*,W+/N')
  if valtype(ret_arr) == 'A'
    ret := array(2)
    ret[1] := ret_arr[2]
    ret[2] := ret_arr[1]
  endif
  return ret

** 17.01.14 действия в ответ на выбор в меню 'Вид ВМП'
Function f_valid_vidvmp(get,old)
  if empty(m1vidvmp)
    MMETVMP := space(67) ; M1METVMP := 0
    update_get('MMETVMP')
  elseif !(m1vidvmp == old) .and. old != NIL .and. get != NIL
    MMETVMP := space(67) ; M1METVMP := 0
    update_get('MMETVMP')
  endif
  return .t.

** 25.01.23 вернуть строку вида ВМП
Function ret_V018(lVIDVMP, lk_data)
  Local i, s := space(10)
  local arrV018 := getV018(lk_data)

  if !empty(lVIDVMP) .and. (i := ascan(arrV018, {|x| x[1] == alltrim(lVIDVMP) })) > 0
    s := arrV018[i, 1] + '.' + arrV018[i, 2]
  endif
  return s
  
** 25.01.23 вернуть строку метода ВМП
Function ret_V019(lMETVMP, lVIDVMP, lk_data)
  Local i, s := space(10)
  local arrV019 := getV019(lk_data)

  if !emptyany(lMETVMP, lVIDVMP) ;
              .and. (i := ascan(arrV019, {|x| x[1] == lMETVMP })) > 0 ;
              .and. arrV019[i, 4] == alltrim(lVIDVMP)
    s := alltrim(str(arrV019[i, 1], 6)) + '.' + arrV019[i, 2]
  endif
  return s
  
  