***** mo_omsna.prg - ��ᯠ��୮� �������
#include "inkey.ch"
#include "..\_mylib_hbt\fastreph.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch  := 1

***** 28.10.18 ��ᯠ��୮� �������
Function disp_nabludenie(k)
Static si1 := 1, si2 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    Private file_form, mdate_r, M1VZROS_REB, diag1 := {}, len_diag := 0
    if (file_form := search_file("DISP_NAB"+sfrm)) == NIL
      return func_error(4,"�� �����㦥� 䠩� DISP_NAB"+sfrm)
    endif
    mas_pmt := {"��ࢨ�� ~����",;
                "~���ଠ��",;
                "~����� � �����"}
    mas_msg := {"��ࢨ�� ���� ᢥ����� � ������ �� ��ᯠ��୮� ���� � ��襩 ��",;
                "���ଠ�� �� ��ࢨ筮�� ����� ᢥ����� � ������ �� ��ᯠ��୮� ����",;
                "����� � ����� ���ଠ樥� �� ��ᯠ��୮�� �������"}
    mas_fun := {"disp_nabludenie(11)",;
                "disp_nabludenie(12)",;
                "disp_nabludenie(13)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    vvod_disp_nabl()
  case k == 12
    mas_pmt := {"~���ଠ�� �� ��ࢨ筮�� �����",;
                "���᮪ ��易⥫��� ~���������",;
                "~��樥��� � ���������� ��� ��ᯠ��୮�� ����"}
    mas_msg := {"���ଠ�� �� ��ࢨ筮�� ����� ᢥ����� � ������ �� ��ᯠ��୮� ����",;
                "���᮪ ���������, ��易⥫��� ��� ��ᯠ��୮�� �������",;
                "���᮪ ��樥�⮢ � ����������, ��易⥫�묨 ��� ��ᯠ��୮�� ���� (�� 2 ����)"}
    mas_fun := {"disp_nabludenie(21)",;
                "disp_nabludenie(22)",;
                "disp_nabludenie(23)"}
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 13
    obmen_disp_nabl()
  case k == 21
    inf_disp_nabl()
  case k == 22
    spr_disp_nabl()
  case k == 23
    pac_disp_nabl()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  endif
endif
return NIL

***** 08.11.18 ��ࢨ�� ���� ᢥ����� � ������ �� ��ᯠ��୮� ���� � ��襩 ��
Function vvod_disp_nabl()
Local buf := savescreen(), k, s, t_arr := array(BR_LEN), str_sem, str_sem1
Private str_find, muslovie
if !hb_fileExists(dir_server+"mo_dnab"+sntx)
  G_Use(dir_server+"mo_dnab")
  index on str(KOD_K,7)+KOD_DIAG to (dir_server+"mo_dnab")
  use
endif  
if input_perso(T_ROW,T_COL-5)
  str_sem := lstr(glob_human[1])
  if !G_SLock(str_sem)
    return func_error(4,"�� �⮬� ���� � ����� ������ ������ ���ଠ�� ��㣮� ���짮��⥫�")
  endif
  k := -ret_new_spec(glob_human[7],glob_human[8])
  box_shadow(0,0,2,49,color13,,,0)
  @ 0,0 say padc("["+lstr(glob_human[5])+"] "+glob_human[2],50) color color8
  @ 1,0 say padc(ret_tmp_prvs(k),50) color color14
  do while .t. 
    @ 2,0 say padc("... �롮� ��樥�� ...",50) color color1
    k := polikl1_kart()
    close databases
    //
    str_sem1 := lstr(glob_kartotek)
    if k == 0
      exit
    elseif G_SLock(str_sem1)
      R_Use(dir_server+"kartotek",,"_KART")
      goto (glob_kartotek)
      s := alltrim(padr(_kart->fio,37))+" ("+full_date(_kart->date_r)+")"
      @ 2,0 say padc(s,50) color color1
      mdate_r := _kart->date_r ; M1VZROS_REB := _kart->VZROS_REB
      fv_date_r(sys_date) // ��८�।������ M1VZROS_REB
      if M1VZROS_REB > 0
        func_error(4,"����� ०�� ⮫쪮 ��� ������, � ��࠭�� ��樥�� ���� �������!")
      else
        str_find := str(glob_kartotek,7) ; muslovie := "dn->kod_k == glob_kartotek"
        t_arr[BR_TOP] := T_ROW
        t_arr[BR_BOTTOM] := maxrow()-2
        t_arr[BR_LEFT] := 2
        t_arr[BR_RIGHT] := maxcol()-2
        t_arr[BR_COLOR] := color0
        t_arr[BR_ARR_BROWSE] := {,,,,.t.}
        t_arr[BR_OPEN] := {|nk,ob| f1_vvod_disp_nabl(nk,ob,"open") }
        t_arr[BR_ARR_BLOCK] := {{| | FindFirst(str_find)},;
                                {| | FindLast(str_find)},;
                                {|n| SkipPointer(n, muslovie)},;
                                str_find,muslovie;
                               }
        t_arr[BR_COLUMN] := {{"�������;�����������",{|| dn->kod_diag }}}
        aadd(t_arr[BR_COLUMN],{"   ���;���⠭����; �� ����",{|| full_date(dn->n_data) }})
        aadd(t_arr[BR_COLUMN],{"   ���;᫥���饣�;���饭��",{|| full_date(dn->next_data) }})
        aadd(t_arr[BR_COLUMN],{"���� �஢������;��ᯠ��୮��;�������",{|| iif(empty(dn->kod_diag),space(7),iif(dn->mesto==0," � ��  ","�� ����")) }})
        t_arr[BR_EDIT] := {|nk,ob| f1_vvod_disp_nabl(nk,ob,"edit") }
        Use_base("mo_dnab")
        edit_browse(t_arr)
      endif
      G_SUnLock(str_sem1)
    else
      func_error(4,"�� �⮬� ��樥��� � ����� ������ ������ ���ଠ�� ��㣮� ���짮��⥫�")
    endif
    close databases
  enddo
  G_SUnLock(str_sem)
endif
close databases
restscreen(buf)
return NIL

***** 29.10.18
Function f1_vvod_disp_nabl(nKey,oBrow,regim)
Local ret := -1
Local buf, fl := .f., rec := 0, rec1, r1, r2, tmp_color
Local bg := {|o,k| get_MKB10(o,k,.t.) }
Local mm_dom := {{"� ��   ",0},;
                 {"�� ����",1}}
do case
  case regim == "open"
    find (str_find)
    ret := found()
  case regim == "edit"
    do case
      case nKey == K_INS .or. (nKey == K_ENTER .and. dn->kod_k > 0)
        if nKey == K_ENTER .and. dn->vrach != glob_human[1]
          func_error(4,"������ ��ப� ������� ��㣨� ��箬!")
          return ret
        endif
        if nKey == K_ENTER
          rec := recno()
        endif
        save screen to buf
        if nkey == K_INS .and. !fl_found
          colorwin(pr1+5,pc1,pr1+5,pc2,"N/N","W+/N")
        endif
        Private gl_area := {1,0,maxrow()-1,79,0}, ;
                mKOD_DIAG := iif(nKey == K_INS, space(5), dn->kod_diag),;
                mN_DATA := iif(nKey == K_INS, sys_date-1, dn->n_data),;
                mNEXT_DATA := iif(nKey == K_INS, 0d20181202, dn->next_data),;
                mMESTO, m1mesto := iif(nKey == K_INS, 0, dn->mesto)
        mmesto := inieditspr(A__MENUVERT, mm_dom, m1mesto)
        r1 := pr2-6 ; r2 := pr2-1
        tmp_color := setcolor(cDataCScr)
        box_shadow(r1,pc1+1,r2,pc2-1,,iif(nKey == K_INS,"����������","������஢����"),cDataPgDn)
        setcolor(cDataCGet)
        do while .t.               
          @ r1+1,pc1+3 say "�������, �� ������ ���ண� ��樥�� �������� ���.�������" get mkod_diag ;
                       pict "@K@!" reader {|o|MyGetReader(o,bg)} ;
                       valid val1_10diag(.t.,.f.,.f.,0d20181201,_kart->pol)
          @ r1+2,pc1+3 say "��� ��砫� ��ᯠ��୮�� �������" get mn_data
          @ r1+3,pc1+3 say "��� ᫥���饩 � � 楫�� ��ᯠ��୮�� �������" get mnext_data
          @ r1+4,pc1+3 say "���� �஢������ ��ᯠ��୮�� �������" get mmesto ;
                       reader {|x|menu_reader(x,mm_dom,A__MENUVERT,,,.f.)} 
          status_key("^<Esc>^ - ��室 ��� �����;  ^<Enter>^ - ���⢥ত���� �����")
          myread()
          if lastkey() != K_ESC .and. f_Esc_Enter(1)
            mKOD_DIAG := padr(mKOD_DIAG,5)
            fl := .t.
            if empty(mKOD_DIAG)
              fl := func_error(4,"�� ����� �������")
            elseif !f2_vvod_disp_nabl(mKOD_DIAG)
              fl := func_error(4,"������� �� �室�� � ᯨ᮪ �����⨬�� �� �ਪ��� �� � �����")
            else
              select DN
              find (str(glob_kartotek,7))
              do while dn->kod_k == glob_kartotek .and. !eof()
                if rec != recno() .and. mKOD_DIAG == dn->kod_diag
                  fl := func_error(4,"����� ������� 㦥 ����� ��� ������� ��樥��")
                  exit
                endif
                skip
              enddo
            endif
            if empty(mN_DATA)
              fl := func_error(4,"�� ������� ��� ��砫� ��ᯠ��୮�� �������")
            elseif mN_DATA >= 0d20181201
              fl := func_error(4,"��� ��砫� ��ᯠ��୮�� ������� ᫨誮� ������")
            endif
            if empty(mNEXT_DATA)
              fl := func_error(4,"�� ������� ��� ᫥���饩 �")
            elseif mN_DATA >= mNEXT_DATA
              fl := func_error(4,"��� ᫥���饩 � ����� ���� ��砫� ��ᯠ��୮�� �������")
            elseif mNEXT_DATA <= 0d20181201
              fl := func_error(4,"��� ᫥���饩 � ������ ���� �� ࠭�� 1 �������")
            endif
            if !fl
              loop
            endif
            select DN
            if nKey == K_INS
              fl_found := .t.
              AddRec(7)
              dn->kod_k := glob_kartotek
              rec := recno()
            else
              goto (rec)
              G_RLock(forever)
            endif
            dn->vrach := glob_human[1]
            dn->prvs  := iif(empty(glob_human[8]), glob_human[7], -glob_human[8])
            dn->kod_diag := mKOD_DIAG
            dn->n_data := mN_DATA
            dn->next_data := mNEXT_DATA
            dn->mesto := m1mesto
            UnLock
            COMMIT
            oBrow:goTop()
            goto (rec)
            ret := 0
          elseif nKey == K_INS .and. !fl_found
            ret := 1
          endif
          exit
        enddo
        select DN
        setcolor(tmp_color)
        restore screen from buf
      case nKey == K_DEL .and. dn->kod_k == glob_kartotek .and. f_Esc_Enter(2)
        DeleteRec()
        oBrow:goTop()
        ret := 0
        if eof() .or. !&muslovie
          ret := 1
        endif
    endcase
endcase
return ret

***** 29.10.18 ���ଠ�� �� ��ࢨ筮�� ����� ᢥ����� � ������ �� ��ᯠ��୮� ����
Function f2_vvod_disp_nabl(ldiag)
Local fl := .f., lfp, i, s, d1, d2
if len_diag == 0
  lfp := fopen(file_form)
  do while !feof(lfp)
    UpdateStatus()
    s := fReadLn(lfp)
/*for i := 1 to len(s) // �஢�ઠ �� ���᪨� �㪢� � ���������
  if ISRALPHA(substr(s,i,1))
    strfile(s+eos,"ttt.ttt",.t.)
    exit
  endif
next*/
    if "-" $ s
      d1 := token(s,"-",1)
      d2 := token(s,"-",2)
    else
      d1 := d2 := s
    endif
    aadd(diag1, {1,{{diag_to_num(d1,1),diag_to_num(d2,2)}},s} )
  enddo
  fclose(lfp)
  len_diag := len(diag1)
endif  
return !(ret_f_14(ldiag) == NIL)

***** 08.11.18 ���ଠ�� �� ��ࢨ筮�� ����� ᢥ����� � ������ �� ��ᯠ��୮� ����
Function inf_disp_nabl()
Static suchast := 0, svrach := 0, sdiag := ''
Local bg := {|o,k| get_MKB10(o,k,.f.) }
Local buf := savescreen(), r := 15, sh, HH := 60, name_file := "info_dn"+stxt
if !hb_fileExists(dir_server+"mo_dnab"+sntx)
  G_Use(dir_server+"mo_dnab")
  index on str(KOD_K,7)+KOD_DIAG to (dir_server+"mo_dnab")
  use
endif  
f2_vvod_disp_nabl("A00")
setcolor(cDataCGet)
myclear(r)
Private muchast := suchast,;
        mvrach := svrach,; 
        mkod_diag := padr(sdiag,5),;
        gl_area := {r,0,maxrow()-1,maxcol(),0}
status_key("^<Esc>^ - ��室;  ^<PgDn>^ - ��⠢����� ���㬥��")
//
@ r,0 to r+8,maxcol() COLOR color8
str_center(r," ����� ���ଠ樨 �� ���񭭮�� ��ᯠ��୮�� ������� ",color14)
@ r+2,2 say "����� ���⪠ (0 - �� �ᥬ ���⪠�)" get muchast pict "99999"
@ r+3,2 say "������� ����� ��� (0 - �� �ᥬ ��砬)" get mvrach pict "99999"
@ r+4,2 say "������� (��� ��砫�� ᨬ����, ��� ����� ��ப�)" get mkod_diag ;
        pict "@K@!" reader {|o|MyGetReader(o,bg)} 
myread()
if lastkey() != K_ESC
  if mvrach > 0
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
    find (str(mvrach,5))
    if found()
      glob_human := {perso->kod,;
                     alltrim(perso->fio),;
                     perso->uch,;
                     perso->otd,;
                     mvrach,;
                     alltrim(perso->name_dolj),;
                     perso->prvs,;
                     perso->prvs_new }
      fl1 := .t.
    else
      func_error(4,"����㤭��� � ⠡���� ����஬ "+lstr(i)+" ��� � ���� ������ ���ᮭ���!")
      mvrach := 0
    endif
    close databases
  endif
  if !empty(mkod_diag)
    mkod_diag := alltrim(mkod_diag) ; l := len(mkod_diag)
    if ascan(diag1, {|x| padr(x[3],l) == mkod_diag }) == 0
      func_error(4,"������� �� �室�� � ᯨ᮪ �����⨬�� �� �ਪ��� �� � �����")
      mkod_diag := ""
    endif
  endif
  //
  suchast := muchast 
  svrach := mvrach 
  sdiag := mkod_diag
  //
  arr_title := {;
    "�����������������������������������������������������������������������������������������",;
    "                                             �   ���   ��� ���.�����-����⠭����������.",;
    "  ��� ��樥��                               � ஦����� ��᳭���೭��  ��� ���� ������   ",;
    "�����������������������������������������������������������������������������������������"}
  sh := len(arr_title[1])
  mywait()
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("���᮪ ��樥�⮢, ������ �� ��ᯠ��୮� ����",sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+"mo_pers",,"PERS")
  R_Use(dir_server+"kartotek",,"KART")
  R_Use_base("mo_dnab")
  set relation to kod_k into KART, to vrach into PERS
  index on upper(kart->fio)+dtos(kart->date_r)+str(dn->kod_k,7)+dn->kod_diag to (cur_dir+"tmp_dn")
  old := r := rs := 0
  go top
  do while !eof()
    fl := .t.
    if muchast > 0
      fl := (kart->uchast == muchast)
    endif
    if fl .and. mvrach > 0
      fl := (glob_human[1] == dn->vrach)
    endif
    if fl .and. !empty(mkod_diag)
      fl := (padr(dn->kod_diag,l) == mkod_diag)
    endif
    if fl
      if old == dn->kod_k
        s := space(45)+space(1+10+3)
      else
        s := padr(kart->fio,45)+" "+full_date(kart->date_r)+str(kart->uchast,3)
        ++r
      endif  
      s += str(pers->tab_nom,6)+" "+dn->kod_diag+" "+date_8(dn->n_data)+" "+date_8(dn->next_data)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s)
      old := dn->kod_k
      ++rs
    endif
    select DN
    skip
  enddo
  if empty(r)
    add_string("�� ������� ��樥�⮢ �� ��������� �᫮���")
  else 
    add_string("=== �⮣� ��樥�⮢ - "+lstr(r)+" 祫., �⮣� ��砥� - "+lstr(rs)+" ===")
  endif
  close databases
  fclose(fp)
  viewtext(name_file,,,,(sh>80),,,2)
endif
restscreen(buf)
return NIL

***** 07.11.18 ���᮪ ���������, ��易⥫��� ��� ��ᯠ��୮�� �������
Function spr_disp_nabl()
Local i, j, s := "", c := "  ", sh := 80, HH := 60, buf := save_maxrow(), name_file := "diagn_dn"+stxt
f2_vvod_disp_nabl("A00")
fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
add_string(center("���᮪ ���������, ��易⥫��� ��� ��ᯠ��୮�� �������",sh))
for i := 1 to len(diag1)
  if c == substr(diag1[i,3],2,2)
    s += diag1[i,3]+" "
  else
    verify_FF(HH,.t.,sh)
    add_string(s)
    s := diag1[i,3]+" "
    c := substr(diag1[i,3],2,2)
  endif
next
add_string(s)
fclose(fp)
viewtext(name_file,,,,.t.,,,2)
rest_box(buf)  
return NIL

***** 07.11.18 ���᮪ ��樥�⮢ � ����������, ��易⥫�묨 ��� ��ᯠ��୮�� ���� (�� 2 ����)
Function pac_disp_nabl()
Static su := 0
Local ku, i, adiagnoz, ar, sh := 80, HH := 60, buf := save_maxrow(), name_file := "disp_nabl"+stxt,;
      s, c1, cv := 0, cf := 0, fl_exit := .f.
if (ku := input_value(20,20,22,59,color1,space(6)+"������ ����� ���⪠",su,"99")) == NIL
  return NIL
endif
su := ku
stat_msg("���� ���ଠ樨...")
fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("���᮪ ��樥�⮢ � ����������, ��易⥫�묨 ��� ��ᯠ��୮�� ���� (�� 2 ����)",sh))
add_string(center("���⮪ � "+lstr(ku),sh))
add_string("")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
R_Use_base("kartotek")
set order to 4
find (strzero(ku,2))
index on upper(fio) to (cur_dir+"tmp_kart") ;
      for kart->kod > 0 .and. kart2->MO_PR == glob_mo[_MO_KOD_TFOMS] .and. !(left(kart2->PC2,1) == "1") ;
      while ku == uchast
go top      
do while !eof()
  @ maxrow(),1 say lstr(++cv) color cColorSt2Msg
  @ row(),col() say "/" color "W/R"
  c1 := col()
  @ row(),c1 say lstr(cf) color cColorStMsg
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if kart->kod > 0 .and. kart2->MO_PR == glob_mo[_MO_KOD_TFOMS] .and. !(left(kart2->PC2,1) == "1")
    mdate_r := kart->date_r ; M1VZROS_REB := kart->VZROS_REB
    fv_date_r(sys_date) // ��८�।������ M1VZROS_REB
    if M1VZROS_REB == 0
      ar := {} 
      select HUMAN
      find (str(kart->kod,7))
      do while human->kod_k == kart->kod .and. !eof()
        if human->k_data > 0d20161231 // �.�. ��᫥���� ��� ���� � �� ᪮�� ������
          human_->(dbGoto(human->(recno())))
          if human_->USL_OK < 4
            adiagnoz := diag_to_array()
            for i := 1 to len(adiagnoz)
              if !empty(adiagnoz[i]) .and. f2_vvod_disp_nabl(adiagnoz[i])
                s := padr(adiagnoz[i],5)
                if ascan(ar,s) == 0
                  aadd(ar,s)
                endif
              endif
            next i
          endif
        endif 
        select HUMAN
        skip
      enddo
      if len(ar) > 0
        s2 := "" 
        if mem_kodkrt == 2
          s2 := "["
          if is_uchastok > 0
            s2 += alltrim(kart->bukva)
            s2 += lstr(kart->uchast,2)+"/"
          endif
          if is_uchastok == 1
            s2 += lstr(kart->kod_vu)
          elseif is_uchastok == 3
            s2 += alltrim(kart2->kod_AK)
          else
            s2 += lstr(kart->kod)
          endif
          s2 += "] "
        endif
        verify_FF(HH,.t.,sh)
        add_string(left(s2+alltrim(kart->fio)+" �.�."+full_date(kart->date_r),99))
        add_string(left("  "+arr2Slist(ar),99))
        if empty(kart_->okatop)
          add_string(left("  "+ret_okato_ulica(kart->adres,kart_->okatog,0,2),99))
        else
          add_string(left("  "+ret_okato_ulica(kart_->adresp,kart_->okatop,0,2),99))
        endif
        @ row(),c1 say lstr(++cf) color cColorStMsg
      endif
    endif
  endif
  select KART
  skip
enddo
if fl_exit
  add_string("*** "+expand("�������� ��������"))
elseif empty(cf)
  add_string("�� �����㦥�� ����訢����� ��樥�⮢ �� ������� �����.")
else  
  add_string("=== �⮣� ��樥�⮢ - "+lstr(cf)+" 祫. ===")
endif
close databases
fclose(fp)
viewtext(name_file,,,,.t.,,,2)
rest_box(buf)  
return NIL

***** 28.10.18 ����� � ����� ���ଠ樥� �� ��ᯠ��୮�� �������
Function obmen_disp_nabl()
return func_error(4,"�㭪�� �㤥� ॠ�������� � ������� 2018 ����!")