
#include "inkey.ch"
#include "..\..\_mylib_hbt\function.ch"
#include "..\..\_mylib_hbt\edit_spr.ch"
#include "..\chip_mo.ch"

***** 29.01.21 �᫨ ����, ��१������ ���祭�� ���� � ���� � HUMAN_2
Function put_str_kslp_kiro(arr,fl)
  Local lpc1 := "", lpc2 := ""

  if len(arr) > 4 .and. !empty(arr[5])
    if year(human->k_data) != 2021  // added 29.01.2021
      lpc1 := lstr(arr[5,1])+","+lstr(arr[5,2],5,2)
      if len(arr[5]) >= 4
        lpc1 += ","+lstr(arr[5,3])+","+lstr(arr[5,4],5,2)
      endif
    endif
  endif
  if len(arr) > 5 .and. !empty(arr[6])
    lpc2 := lstr(arr[6,1])+","+lstr(arr[6,2],5,2)
  endif
  if !(padr(lpc1,20) == human_2->pc1 .and. padr(lpc2,10) == human_2->pc2)
    DEFAULT fl TO .t. // �����஢��� � ࠧ�����஢��� ������ � HUMAN_2
    select HUMAN_2
    if fl
      G_RLock(forever)
    endif
    if year(human->k_data) != 2021  // added 29.01.2021
      human_2->pc1 := lpc1
    endif
    human_2->pc2 := lpc2
    if fl
      UnLock
    endif
  endif
  return NIL
  