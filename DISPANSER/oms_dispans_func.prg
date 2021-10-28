#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 23.01.17
Function f_valid_diag_oms_sluch_DVN(get,k)
  Local sk := lstr(k)
  Private pole_diag := "mdiag"+sk,;
          pole_d_diag := "mddiag"+sk,;
          pole_pervich := "mpervich"+sk,;
          pole_1pervich := "m1pervich"+sk,;
          pole_stadia := "m1stadia"+sk,;
          pole_dispans := "mdispans"+sk,;
          pole_1dispans := "m1dispans"+sk,;
          pole_d_dispans := "mddispans"+sk
  if get == NIL .or. !(&pole_diag == get:original)
    if empty(&pole_diag)
      &pole_pervich := space(12)
      &pole_1pervich := 0
      &pole_d_diag := ctod("")
      &pole_stadia := 1
      &pole_dispans := space(3)
      &pole_1dispans := 0
      &pole_d_dispans := ctod("")
    else
      &pole_pervich := inieditspr(A__MENUVERT, mm_pervich, &pole_1pervich)
      &pole_dispans := inieditspr(A__MENUVERT, mm_danet, &pole_1dispans)
    endif
  endif
  if emptyall(m1dispans1,m1dispans2,m1dispans3,m1dispans4,m1dispans5)
    m1dispans := 0
  elseif m1dispans == 0
    m1dispans := ps1dispans
  endif
  mdispans := inieditspr(A__MENUVERT, mm_dispans, m1dispans)
  update_get(pole_pervich)
  update_get(pole_d_diag)
  update_get(pole_stadia)
  update_get(pole_dispans)
  update_get(pole_d_dispans)
  update_get("mdispans")
  return .t.
  
***** 16.06.19 рабочая ли услуга (умолчание) ДВН в зависимости от этапа, возраста и пола
Function f_is_umolch_sluch_DVN(i,_etap,_vozrast,_pol)
  Local fl := .f., j, ta, ar := dvn_arr_umolch[i]
  if _etap > 3
    return fl
  endif
  if valtype(ar[3]) == "N"
    fl := (ar[3] == _etap)
  else
    fl := ascan(ar[3],_etap) > 0
  endif
  if fl
    if _etap == 1
      i := iif(_pol=="М", 4, 5)
    else//if _etap == 3
      i := iif(_pol=="М", 6, 7)
    endif
    if valtype(ar[i]) == "N"
      fl := (ar[i] != 0)
    elseif valtype(ar[i]) == "C"
      // "18,65" - для краткого инд.проф.консультирования
      ta := list2arr(ar[i])
      for i := len(ta) to 1 step -1
        if _vozrast >= ta[i]
          for j := 0 to 99
            if _vozrast == int(ta[i]+j*3)
              fl := .t. ; exit
            endif
          next
          if fl ; exit ; endif
        endif
      next
    else
      fl := between(_vozrast,ar[i,1],ar[i,2])
    endif
  endif
  return fl
  
  