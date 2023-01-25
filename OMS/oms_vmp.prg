#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 13.02.22 в GET-е вернуть строку из glob_V018
Function f_get_vidvmp(k, r, c, diagnoze) 
  // Static sy := 0, 
  local arr, svidvmp := ""
  Local ret, ret_arr
  local sTmp := ''
  local y := year(mk_data)
  local row, arr_vid := {}, kk

  local glob_V019 := getV019table(mk_data)
  local glob_V018 := getV018table(mk_data)

  diagnoze := alltrim(diagnoze)
  if y < 2018
    y := 2018
  endif

  for each row in glob_V019   // только с нужным диагнозом
    if (kk := ascan(row[3], {|x| x == alltrim(diagnoze) })) > 0
      aadd(arr_vid, row[4])
    endif
  next

  arr := {}
  for i := 1 to len(glob_V018)
    if (kk := ascan(arr_vid, {|x| x == alltrim(glob_V018[i, 1]) })) > 0
      sTmp := padl(glob_V018[i, 1], 5) + "."
      // aadd(arr,{padr(glob_V018[i,1]+"."+glob_V018[i,2],76),glob_V018[i,1]})
      aadd(arr, {padr(sTmp + glob_V018[i, 2], 76), glob_V018[i, 1]})
    endif
  next
  if empty(k)
    k := svidvmp
  endif
  popup_2array(arr, -r, c, k, 1, @ret_arr, "Выбор вида ВМП","GR+/RB","BG+/RB,N/BG")
  if valtype(ret_arr) == "A"
    ret := array(2)
    svidvmp := ret_arr[2]
    ret[1] := ret_arr[2]
    ret[2] := ret_arr[1]
  endif
  return ret

***** 13.02.21 в GET-е вернуть строку из glob_V019
Function f_get_metvmp(k, r, c, lvidvmp, modpac)
  Local arr := {}, i, ret, ret_arr

  local glob_V019 := getV019table(mk_data)
  local glob_V018 := getV018table(mk_data)

  if empty(lvidvmp) .or. empty(modpac)
    return NIL
  endif

  for i := 1 to len(glob_V019)
    if glob_V019[i,4] == alltrim(lvidvmp) .and. glob_V019[i,8] == modpac
      aadd(arr, {padr(str(glob_V019[i,1],4)+"."+glob_V019[i,2],76),glob_V019[i,1]})
    endif
  next
  if empty(arr)
    func_error(4,"В справочнике V019 не найдено методов для вида ВМП "+lvidvmp)
    return NIL
  endif
  popup_2array(arr,-r,c,k,1,@ret_arr,"Выбор метода ВМП для "+lvidvmp,"GR+/RB*","N/RB*,W+/N")
  if valtype(ret_arr) == "A"
    ret := array(2)
    ret[1] := ret_arr[2]
    ret[2] := ret_arr[1]
  endif
  return ret

** 17.01.23 в GET-е вернуть строку из getV022()
Function f_get_mmodpac(k, r, c, lvidvmp, sDiag)
  Local arr := {}, i, ret, ret_arr
  local diag := alltrim(sDiag)
  local model := getV022()
  local row

  local glob_V019 := getV019table(mk_data)
  local glob_V018 := getV018table(mk_data)

  if empty(lvidvmp) .or. empty(diag)
    return NIL
  endif

  for i := 1 to len(glob_V019)
    if glob_V019[i,4] == alltrim(lvidvmp) .and. ( ascan(glob_V019[i,3],diag) > 0 )
      for each row in model
        if row[1] == glob_V019[i,8]
          if ascan(arr, {|x| x[2] == row[1] }) == 0
            aadd(arr, {padr(alltrim(row[2]),76),row[1]})
            exit
          endif
        endif
      next
    endif
  next
  if empty(arr)
    func_error(4,"В справочнике V022 не найдено моделей пациентов для вида ВМП "+lvidvmp)
    return NIL
  endif
  popup_2array(arr,-r,c,k,1,@ret_arr,"Выбор модели пациента для "+lvidvmp,"GR+/RB*","N/RB*,W+/N")
  if valtype(ret_arr) == "A"
    ret := array(2)
    ret[1] := ret_arr[2]
    ret[2] := ret_arr[1]
  endif
  return ret

***** 17.01.14 действия в ответ на выбор в меню "Вид ВМП"
Function f_valid_vidvmp(get,old)
  if empty(m1vidvmp)
    MMETVMP := space(67) ; M1METVMP := 0
    update_get("MMETVMP")
  elseif !(m1vidvmp == old) .and. old != NIL .and. get != NIL
    MMETVMP := space(67) ; M1METVMP := 0
    update_get("MMETVMP")
  endif
  return .t.

***** 13.02.22 вернуть строку вида ВМП
Function ret_V018(lVIDVMP, lk_data)
  Local i, s := space(10)
  local glob_V018 := getV018table(lk_data)

  if !empty(lVIDVMP) .and. (i := ascan(glob_V018, {|x| x[1] == alltrim(lVIDVMP) })) > 0
    s := glob_V018[i, 1] + "." + glob_V018[i, 2]
  endif
  return s
  
***** 13.02.22 вернуть строку метода ВМП
Function ret_V019(lMETVMP, lVIDVMP, lk_data)
  Local i, s := space(10)
  local glob_V019 := getV019table(lk_data)

  if !emptyany(lMETVMP, lVIDVMP) ;
              .and. (i := ascan(glob_V019, {|x| x[1] == lMETVMP })) > 0 ;
              .and. glob_V019[i, 4] == alltrim(lVIDVMP)
    s := alltrim(str(glob_V019[i, 1], 6)) + "." + glob_V019[i, 2]
  endif
  return s
  
  