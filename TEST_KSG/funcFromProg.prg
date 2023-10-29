#include 'chip_mo.ch'
#include 'function.ch'

////* 23.12.18 ������⢮ ���, ����楢 � ���� � ��ப�
Function count_ymd(_mdate, _sys_date, /*@*/y, /*@*/m, /*@*/d)
  // _mdate    - ��� ��� ��।������ ������⢠ ���, ����楢 � ����
  // _sys_date - "��⥬���" ���
  Local ret_s := "", md := _mdate
  y := m := d := 0
  if !empty(_sys_date) .and. !empty(_mdate) .and. _sys_date > _mdate
    do while (md := addmonth(md,12)) <= _sys_date
      ++y
    enddo
    if y > 0 .and. correct_count_ym(_mdate,_sys_date)
      --y
    endif
    md := addmonth(_mdate,12*y)
    do while (md := addmonth(md,1)) <= _sys_date
      ++m
    enddo
    if m > 0 .and. correct_count_ym(_mdate,_sys_date,2)
      --m
    endif
    md := addmonth(_mdate,12*y+m)
    do while (md := md+1) <= _sys_date
      ++d
    enddo
    if !emptyall(y,m) .and. d > 0 // ⮫쪮 �� ��� ����஦�������
      --d
    endif
  endif
  if y > 0
    ret_s := lstr(y)+" "+s_let(y)+" "
  endif
  if m > 0
    ret_s += lstr(m)+" "+mes_cev(m)+" "
  endif
  if d > 0
    ret_s += lstr(d)+" "+dnej(d)
  endif
  return rtrim(ret_s)

////* 23.12.18 ��� ��⠥��� ���⨣訬 ��।��񭭮�� ������ �� � ���� ஦�����, � ��稭�� � ᫥����� ��⮪
Function correct_count_ym(_mdate,_sys_date,y_m)
  Local s1 := right(dtos(_mdate),4), s2 := right(dtos(_sys_date),4), fl := .f.
  DEFAULT y_m TO 1
  if s1 == s2 // �஢��塞 ࠢ���⢮ ��� � �����
    fl := .t.
  elseif s1 == "0229" .and. s2 == "0228" .and. !IsLeap(_sys_date) //_mdate - ��᮪��� ���, � _sys_date - ���
    fl := .t.
  elseif y_m == 2 .and. right(s1,2) == right(s2,2) // �஢��塞 ࠢ���⢮ ��� (��� ���-�� ���-�� ����楢)
    fl := .t.
  endif
  return fl
