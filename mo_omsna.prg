***** mo_omsna.prg - ��ᯠ��୮� �������
#include "inkey.ch"
#include "..\_mylib_hbt\fastreph.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch  := 1

***** 28.10.18 ��ᯠ��୮� �������
Function disp_nabludenie(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"��ࢨ�� ~����",;
                "~��ᬮ��",;
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
    inf_disp_nabl()
  case k == 13
    obmen_disp_nabl()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

***** 29.10.18 ��ࢨ�� ���� ᢥ����� � ������ �� ��ᯠ��୮� ���� � ��襩 ��
Function vvod_disp_nabl()
Local buf := savescreen(), k, s, t_arr := array(BR_LEN)
Private str_find, muslovie, file_form, mdate_r, M1VZROS_REB, diag1 := {}, len_diag := 0
if (file_form := search_file("DISP_NAB"+sfrm)) == NIL
  return func_error(4,"�� �����㦥� 䠩� DISP_NAB"+sfrm)
endif
G_Use(dir_server+"mo_dnab",,"DN")
index on str(KOD_K,7)+KOD_DIAG to (cur_dir+"tmp_dnab")
use
if input_perso(T_ROW,T_COL-5)
  k := -ret_new_spec(glob_human[7],glob_human[8])
  box_shadow(0,0,2,49,color13,,,0)
  @ 0,0 say padc("["+lstr(glob_human[5])+"] "+glob_human[2],50) color color8
  @ 1,0 say padc(ret_tmp_prvs(k),50) color color14
  do while .t. 
    @ 2,0 say padc("... �롮� ��樥�� ...",50) color color1
    k := polikl1_kart()
    close databases
    //
    R_Use(dir_server+"kartotek",,"_KART")
    if k == 0
      exit
    else
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
        G_Use(dir_server+"mo_dnab",cur_dir+"tmp_dnab","DN")
        edit_browse(t_arr)
      endif
    endif
    close databases
  enddo
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
for i := 1 to len(s) // �஢�ઠ �� ���᪨� �㪢� � ���������
  if ISRALPHA(substr(s,i,1))
    strfile(s+eos,"ttt.ttt",.t.)
    exit
  endif
next
    if "-" $ s
      d1 := token(s,"-",1)
      d2 := token(s,"-",2)
    else
      d1 := d2 := s
    endif
    aadd(diag1, {1,{{diag_to_num(d1,1),diag_to_num(d2,2)}}} )
  enddo
  fclose(lfp)
  len_diag := len(diag1)
endif  
return !(ret_f_14(ldiag) == NIL)

***** 28.10.18 ���ଠ�� �� ��ࢨ筮�� ����� ᢥ����� � ������ �� ��ᯠ��୮� ����
Function inf_disp_nabl()
ne_real()
return NIL

***** 28.10.18 ����� � ����� ���ଠ樥� �� ��ᯠ��୮�� �������
Function obmen_disp_nabl()
return func_error(4,"�㭪�� �㤥� ॠ�������� � ������� 2018 ����!")
