#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 23.11.21 � GET-� ������ ��ப� �� glob_V018
Function f_get_vidvmp(k, r, c, diagnoze) 
  Static sy := 0, arr, svidvmp := ""
  Local ret, ret_arr
  local sTmp := ''
  local y := year(mk_data)
  local row, arr_vid := {}, kk

  if y < 2018
    y := 2018
  endif

  if sy != y  // �� ��ࢮ� �맮�� ��� ᬥ�� ����
    make_V018_V019(mk_data)
    for each row in glob_V019   // ⮫쪮 � �㦭� ���������
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
    sy := y
  endif
  if empty(k)
    k := svidvmp
  endif
  popup_2array(arr, -r, c, k, 1, @ret_arr, "�롮� ���� ���","GR+/RB","BG+/RB,N/BG")
  if valtype(ret_arr) == "A"
    ret := array(2)
    svidvmp := ret_arr[2]
    ret[1] := ret_arr[2]
    ret[2] := ret_arr[1]
  endif
  return ret

***** 11.02.21 � GET-� ������ ��ப� �� glob_V019
Function f_get_metvmp(k, r, c, lvidvmp, modpac)
  Local arr := {}, i, ret, ret_arr

  if empty(lvidvmp) .or. empty(modpac)
    return NIL
  endif

  make_V018_V019(mk_data)
  for i := 1 to len(glob_V019)
    if glob_V019[i,4] == alltrim(lvidvmp) .and. glob_V019[i,8] == modpac
      aadd(arr, {padr(str(glob_V019[i,1],4)+"."+glob_V019[i,2],76),glob_V019[i,1]})
    endif
  next
  if empty(arr)
    func_error(4,"� �ࠢ�筨�� V019 �� ������� ��⮤�� ��� ���� ��� "+lvidvmp)
    return NIL
  endif
  popup_2array(arr,-r,c,k,1,@ret_arr,"�롮� ��⮤� ��� ��� "+lvidvmp,"GR+/RB*","N/RB*,W+/N")
  if valtype(ret_arr) == "A"
    ret := array(2)
    ret[1] := ret_arr[2]
    ret[2] := ret_arr[1]
  endif
  return ret

***** 11.02.21 � GET-� ������ ��ப� �� glob_V022
Function f_get_mmodpac(k, r, c, lvidvmp, sDiag)
  Local arr := {}, i, ret, ret_arr
  local diag := alltrim(sDiag)
  local model := getV022table()
  local row

  if empty(lvidvmp) .or. empty(diag)
    return NIL
  endif

  make_V018_V019(mk_data)
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
    func_error(4,"� �ࠢ�筨�� V022 �� ������� ������� ��樥�⮢ ��� ���� ��� "+lvidvmp)
    return NIL
  endif
  popup_2array(arr,-r,c,k,1,@ret_arr,"�롮� ������ ��樥�� ��� "+lvidvmp,"GR+/RB*","N/RB*,W+/N")
  if valtype(ret_arr) == "A"
    ret := array(2)
    ret[1] := ret_arr[2]
    ret[2] := ret_arr[1]
  endif
  return ret

***** 17.01.14 ����⢨� � �⢥� �� �롮� � ���� "��� ���"
Function f_valid_vidvmp(get,old)
  if empty(m1vidvmp)
    MMETVMP := space(67) ; M1METVMP := 0
    update_get("MMETVMP")
  elseif !(m1vidvmp == old) .and. old != NIL .and. get != NIL
    MMETVMP := space(67) ; M1METVMP := 0
    update_get("MMETVMP")
  endif
  return .t.
  
  
