#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 18.02.20
Function year_month(rr,cc,za_v,kmp,ch_mm,ret_time)
  // kmp = �� 1 �� 4(5) ��� ���ᨢ {3,4}
  // za_v = .t. - ��ப� � �����.������
  // za_v = .f. - ��ப� � ⢮��.������
  Local mas2_pmt := {"�� ~����","� �����~���� ���","�� ~�����","�� ~��ਮ�"}
  Local ky, km, kp, ret_arr, buf, s_mes_god, ret_year, dekad_date, blk,;
        begin_date, end_date, old_set, fl, ar, r1, c1, r2, c2
  Local i, sy, smp, sm, mbeg, mend, sdate, sdek, s1date, s1time, s2time

  ar := GetIniSect(tmp_ini,"ymonth")
  sy     := int(val(a2default(ar,"sy",lstr(year(sys_date)))))
  sm     := int(val(a2default(ar,"sm",lstr(month(sys_date)))))
  smp    := int(val(a2default(ar,"smp","3")))
  mbeg   := int(val(a2default(ar,"mbeg","1")))
  mend   := int(val(a2default(ar,"mend",lstr(sm))))
  sdate  := stod(a2default(ar,"sdate",dtos(sys_date)))
  s1date := stod(a2default(ar,"s1date",dtos(sys_date)))
  sdek   := int(val(a2default(ar,"sdek","1")))
  s1time := a2default(ar,"s1time","00:00")
  s2time := a2default(ar,"s2time","24:00")
  DEFAULT za_v TO .t., rr TO T_ROW, cc TO T_COL-5, ch_mm TO 1
  ret_time := {,}
  Private k1, k2
  ym_kol_mes := 0  // ��।����� ������⢮ ����楢
  if kmp == NIL .and. (kmp := popup_prompt(rr,cc,smp,mas2_pmt)) == 0
    return NIL
  elseif valtype(kmp) == "A" // ᯥ樠�쭮 ⮫쪮 ����� � ������ ��ப� ����
    if (i := popup_prompt(rr,cc,smp-2,{"�� ~�����","�� ~��ਮ�"})) == 0
      return NIL
    endif
    kmp := i+2
  endif
  Store 0 TO r1, c1, r2, c2
  if eq_any(kmp,3,4)
    get_row_col_max(20,15,@r1,@c1,@r2,@c2)
    if (ky := input_value(r1,c1,r2,c2,color1,"�� ����� ��� ������ ������� ���ଠ��",sy,"9999")) == NIL
      return NIL
    endif
    ret_year := sy := ky
  endif
  smp := iif(kmp == 5, 2, kmp)
  if kmp == 1
    get_row_col_max(18,5,@r1,@c1,@r2,@c2)
    if (dekad_date := input_value(r1,c1,r2,c2,color1,;
                                  "������ ����, �� ������ ����室��� ������� ���ଠ��",;
                                  ctod(left(dtoc(sdate),6)+lstr(sy)))) == NIL
      return NIL
    endif
    sdate := dekad_date
    sy := ret_year := year(sdate)
    begin_date := end_date := dtoc4(sdate)
  elseif eq_any(kmp,2,5) .and. ch_mm == 1
    begin_date := if(s1date>sdate,sdate,s1date)
    if kmp == 5
      begin_date := boy(begin_date)
      kmp := 2
      if type("b_year_month")=="D" .and. type("e_year_month")=="D"
        begin_date := b_year_month ; sdate := e_year_month
      endif
      keyboard chr(K_ENTER)
    endif
    blk := {|x,y| if(x > y, func_error(4,"��砫쭠� ��� ����� ����筮�!"),.t.) }
    get_row_col_max(18,0,@r1,@c1,@r2,@c2)
    km := input_diapazon(r1,c1,r2,c2,cDataCGet,;
             {"������ ��砫���","� �������","���� ��� ����祭�� ���-��"},;
             {begin_date,sdate},, blk )
    if km == NIL
      return NIL
    endif
    s1date := km[1] ; sdate := km[2]
    sy := ret_year := year(sdate)
    begin_date := dtoc4(s1date) ; end_date := dtoc4(sdate)
  elseif kmp == 2 .and. ch_mm == 2
    Private m1date := s1date, m2date := sdate, m1time := s1time, m2time := s2time
    setcolor(cDataCGet)
    get_row_col_max(18,12,@r1,@c1,@r2,@c2)
    buf := box_shadow(r1,c1,r2,c2)
    fl := .f.
    do while .t.
      @ r1+1,c1+1 say "��ਮ� �६���: �" get m1date
      @ row(),col() say "/"
      @ row(),col() get m1time pict "99:99"
      @ row(),col() say " ��" get m2date
      @ row(),col() say "/"
      @ row(),col() get m2time pict "99:99"
      myread({"confirm"})
      if lastkey() != K_ESC
        if !v_date_time(m1date,m1time,m2date,m2time)
          loop
        endif
        s1date := m1date ; sdate := m2date
        sy := ret_year := year(sdate)
        begin_date := dtoc4(s1date) ; end_date := dtoc4(sdate)
        s1time := m1time ; s2time := m2time
        ret_time := {s1time,s2time}
        fl := .t.
      endif
      exit
    enddo
    setcolor(color0)
    rest_box(buf)
    if !fl
      return NIL
    endif
  elseif kmp == 3
    if rr+12+1 > maxrow()-2
      rr := maxrow()-12-3
    endif
    if (km := popup_prompt(rr,cc,sm,mm_month)) == 0
      return NIL
    endif
    sm := km
    k1 := k2 := km
    ym_kol_mes := 1
  elseif kmp == 4
    setcolor(color1)
    get_row_col_max(20,10,@r1,@c1,@r2,@c2)
    buf := box_shadow(r1,c1,r2,c2)
    k1 := mbeg;  k2 := mend
    if k1 > k2
      k1 := k2
    endif
    @ r1+1,c1+2 say "������ ��砫�� � ������ ������ ��� ��ਮ��" get k1 picture "99" valid {|| k1 >= 0}
    @ row(),col()+1 say "-" get k2 picture "99" valid {|| k1 <= k2 .and. k2 <= 12}
    myread({"confirm"})
    rest_box(buf)
    if lastkey() == K_ESC
      setcolor(color0)
      return NIL
    endif
    mbeg := k1;  mend := k2
    ym_kol_mes := k2-k1+1
  endif
  if za_v
    if kmp == 1
      s_mes_god := "�� "+date_month(dekad_date,.t.)
    elseif kmp == 2 .and. ch_mm == 1
      s_mes_god := "� ��������� ��� �� "+date_8(s1date)+"�. �� "+date_8(sdate)+"�."
    elseif kmp == 2 .and. ch_mm == 2
      s_mes_god := "� "+date_8(s1date)+"("+s1time+") �� "+date_8(sdate)+"("+s2time+")"
    else
      do case
        case k1 == k2
          s_mes_god := "�� "+mm_month[k1]+" �����"
        case k1 == 1 .and. k2 == 3
          s_mes_god := "�� I ����⠫"
        case k1 == 4 .and. k2 == 6
          s_mes_god := "�� II ����⠫"
        case k1 == 7 .and. k2 == 9
          s_mes_god := "�� III ����⠫"
        case k1 == 10 .and. k2 == 12
          s_mes_god := "�� IV ����⠫"
        case k1 == 1 .and. k2 == 6
          s_mes_god := "�� 1-�� ���㣮���"
        case k1 == 7 .and. k2 == 12
          s_mes_god := "�� 2-�� ���㣮���"
        case k1 == 1 .and. k2 == 12
          s_mes_god := ""
        otherwise
          s_mes_god := "�� ��ਮ� � "+lstr(k1)+"-�� �� "+lstr(k2)+"-� ������"
      endcase
      if k1 == 1 .and. k2 == 12
        s_mes_god := "��"+str(ret_year,5)+" ���"
      else
        s_mes_god += str(ret_year,5)+" ����"
      endif
    endif
  else
    if kmp == 1
      s_mes_god := date_month(dekad_date,.t.)
    elseif kmp == 2 .and. ch_mm == 1
      s_mes_god := "� ��������� ��� �� "+date_8(s1date)+"�. �� "+date_8(sdate)+"�."
    elseif kmp == 2 .and. ch_mm == 2
      s_mes_god := "� "+date_8(s1date)+"("+s1time+") �� "+date_8(sdate)+"("+s2time+")"
    else
      do case
        case k1 == k2
          s_mes_god := "� "+mm_monthR[k1]+" �����"
        case k1 == 1 .and. k2 == 3
          s_mes_god := "� I ����⠫�"
        case k1 == 4 .and. k2 == 6
          s_mes_god := "�� II ����⠫�"
        case k1 == 7 .and. k2 == 9
          s_mes_god := "� III ����⠫�"
        case k1 == 10 .and. k2 == 12
          s_mes_god := "� IV ����⠫�"
        case k1 == 1 .and. k2 == 6
          s_mes_god := "� 1-�� ���㣮���"
        case k1 == 7 .and. k2 == 12
          s_mes_god := "�� 2-�� ���㣮���"
        case k1 == 1 .and. k2 == 12
          s_mes_god := ""
        otherwise
          s_mes_god := "� ��ਮ� � "+lstr(k1)+"-�� �� "+lstr(k2)+"-� ������"
      endcase
      if k1 == 1 .and. k2 == 12
        s_mes_god := "�"+str(ret_year,5)+" ����"
      else
        s_mes_god += str(ret_year,5)+" ����"
      endif
    endif
  endif
  if kmp > 2
    begin_date := end_date := chr(int(val(left(str(ret_year,4),2))))+chr(int(val(substr(str(ret_year,4),3))))
    begin_date += chr(k1)+chr(1)
    end_date += chr(k2)+chr(1)
    end_date := dtoc4(eom(c4tod(end_date)))
  endif
  SetIniSect(tmp_ini,"ymonth",;
             {{"sy",lstr(sy)},{"sm",lstr(sm)},{"smp",lstr(smp)},;
              {"mbeg",lstr(mbeg)},{"mend",lstr(mend)},{"sdate",dtos(sdate)},;
              {"s1date",dtos(s1date)},{"sdek",lstr(sdek)},;
              {"s1time",s1time},{"s2time",s2time}})
  return {ret_year, k1, k2, s_mes_god, c4tod(begin_date), c4tod(end_date), begin_date, end_date}
  
***** 26.09.13 ����� ����
Function input_year()
  Local ky, begin_date, end_date, r1, c1, r2, c2
  
  Store 0 TO r1, c1, r2, c2
  get_row_col_max(20,15,@r1,@c1,@r2,@c2)
  if (ky := input_value(r1,c1,r2,c2,color1,"�� ����� ��� ������ ������� ���ଠ��",year(sys_date),"9999")) == NIL
    return NIL
  endif
  begin_date := end_date := chr(int(val(left(str(ky,4),2))))+chr(int(val(substr(str(ky,4),3))))
  begin_date += chr(1)+chr(1)
  end_date += chr(12)+chr(1)
  end_date := dtoc4(eom(c4tod(end_date)))
  return {ky, 1, 12, "��"+str(ky,5)+" ���", c4tod(begin_date), c4tod(end_date), begin_date, end_date}
  
  