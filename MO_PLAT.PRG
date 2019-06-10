***** mo_plat.prg
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

*****
Function begin_task_plat()
Static n_zapusk := 0
if n_zapusk == 0
  ++n_zapusk
  Public menu_kb := {{"платный",PU_PLAT },;
                     {"ДМС    ",PU_D_SMO},;
                     {"в/зачет",PU_PR_VZ}}
  Public arr_opl_7, len_arr_7
  Public count_otd := 1
  Public count_uch := 1
  Public is_all_uch := .T.
  Public gmenu_kateg := {{"врач",1},;
                         {"средний мед.персонал",2},;
                         {"младший мед.персонал",3},;
                         {"прочие",4}}
endif
if copy_Tools_Ini()
  Tools_Ini_OMS(1,0,0)
  Tools_Ini_Platn(1,0,0)
else
  return .f.
endif
if glob_kassa == 1
  if hb_FileExists("__kassa_.log") .and. filesize("__kassa_.log") > 5000000
    delete file __kassa_.log
  endif
  f5_sist_fr(1)
endif
return .t.

*

*****
Function s_pl_meds(reg)
Local t_arr[BR_LEN], mtitle := "Справочник "+{"медсестер","санитарок"}[reg]
Private str_find := str(reg,1), muslovie := "dbf1->tip=="+lstr(reg)
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := T_COL-10
t_arr[BR_RIGHT] := t_arr[BR_LEFT] + 29
t_arr[BR_OPEN] := {|| f1_dbf1(,,"open",reg) }
t_arr[BR_CLOSE] := {|| dbCloseAll() }
t_arr[BR_ARR_BLOCK] := {{| | FindFirst(str_find)},;
                        {| | FindLast(str_find)},;
                        {|n| SkipPointer(n, muslovie)},;
                        str_find,muslovie;
                       }
t_arr[BR_SEMAPHORE] := mtitle
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := mtitle
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_ARR_BROWSE] := {,,,,.t.}
t_arr[BR_COLUMN] := {{ " Код", {|| dbf1->tab_nom } },;
                     { center("Ф.И.О.",20), {|| padr(dbf1->fio,20) } }}
t_arr[BR_EDIT] := {|nk,ob| f1_dbf1(nk,ob,"edit",reg) }
edit_browse(t_arr)
return NIL

*****
Function f1_dbf1(nKey,oBrow,regim,lregim)
Local ret := -1
Local buf, fl := .f., rec, rec1, k := 17, tmp_color
do case
  case regim == "open"
    G_Use(dir_server+"plat_ms",dir_server+"plat_ms","DBF1")
    find (str_find)
    ret := found()
  case regim == "choice" .and. nKey == K_SPACE
    ret := 1
  case regim == "edit"
    do case
      case nKey == K_INS .or. (nKey == K_ENTER .and. !empty(dbf1->tab_nom))
        save screen to buf
        if nkey == K_INS .and. !fl_found
          colorwin(pr1+3,pc1,pr1+3,pc2,"N/N","W+/N")
        endif
        Private mshifr, mname, gl_area := {1,0,23,79,0}
        mtab_nom := if(nKey == K_INS, 0, dbf1->tab_nom)
        mfio := if(nKey == K_INS, space(20), dbf1->fio)
        tmp_color := setcolor(cDataCScr)
        box_shadow(k,pc1+1,21,pc2-1,,;
                       if(nKey == K_INS,"Добавление","Редактирование"),;
                       cDataPgDn)
        setcolor(cDataCGet)
        @ k+1,pc1+3 say "Код" get mtab_nom pict "99999"
        @ k+2,pc1+3 say "Ф.И.О."
        @ k+3,pc1+8 get mfio
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. updated() .and. ;
                                !emptyany(mtab_nom,mfio) .and. f_Esc_Enter(1)
          if nKey == K_INS
            fl_found := .t.
            AddRec(1)
            replace dbf1->tip with lregim
          else
            G_RLock(forever)
          endif
          replace dbf1->tab_nom with mtab_nom, dbf1->fio with mfio
          UNLOCK
          COMMIT
          oBrow:goTop()
          find (str_find+str(mtab_nom,5))
          ret := 0
        elseif nKey == K_INS .and. !fl_found
          ret := 1
        endif
        setcolor(tmp_color)
        restore screen from buf
      case nKey == K_DEL .and. !empty(dbf1->tab_nom) .and. f_Esc_Enter(2)
        buf := save_row(maxrow())
        stat_msg("Ждите! Производится проверка на допустимость удаления")
        rec := dbf1->(recno())
        G_Use(dir_server+"hum_p_u",,"HU")
        if lregim == 1
          Locate for equalany(rec,hu->med1,hu->med2,hu->med3) progress
        else
          Locate for equalany(rec,hu->san1,hu->san2,hu->san3) progress
        endif
        fl := found()
        Use
        if fl
          func_error(4,"Данный человек встречается в других базах данных. Удаление запрещено!")
        endif
        rest_box(buf)
        select DBF1
        if !fl
          DeleteRec()
          oBrow:goTop()
          find (str_find)
          ret := 0
          if !found()
            ret := 1
          endif
        endif
    endcase
endcase
return ret

*

*****
Function oplata_vz()
Static spar := 1
Local i, j, k, fl, s, buf := savescreen(), t_arr[BR_LEN], blk, mtitle
Private par, muslovie, str_find, ;
        menu_opl := {{"безналичн.",0},;
                     {"наличными ",1},;
                     {"в/зачет   ",2}}
if (par := popup_prompt(T_ROW,T_COL+5,spar,;
              {"Предприятия по взаимо~зачету",;
               "~Добровольное страхование"})) == 0
  return NIL
endif
spar := par
do case
  case par == 1
    if !input_pr_vz(T_ROW,T_COL+5)
      return NIL
    endif
  case par == 2
    if !input_d_smo(T_ROW,T_COL+5)
      return NIL
    endif
    if polikl1_kart() <= 0
      return NIL
    endif
endcase
if par == 1
  str_find := "2"+str(glob_pr_vz[1],6)+str(0,7)
  muslovie := "opl->tip==2 .and. opl->pr_smo==glob_pr_vz[1] .and. opl->kod_k==0"
  mtitle := glob_pr_vz[2]
elseif par == 2
  str_find := "1"+str(glob_d_smo[1],6)+str(glob_kartotek,7)
  muslovie := "opl->tip==1 .and. opl->pr_smo==glob_d_smo[1] .and. opl->kod_k==glob_kartotek"
  mtitle := glob_d_smo[2]
  box_shadow(0,41,2,77,color13)
  @ 1,42 say padc(fam_i_o(glob_k_fio),35) color color8
endif
if !G_SLock(str_find)
  return func_error(4,err_slock)
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := T_COL+5
t_arr[BR_RIGHT] := t_arr[BR_LEFT]+51
t_arr[BR_OPEN] := {|| fi_opl_vz(,,"open") }
t_arr[BR_CLOSE] := {|| dbCloseAll() }
t_arr[BR_ARR_BLOCK] := {{| | FindFirst(str_find)},;
                        {| | FindLast(str_find,-1)},;
                        {|n| SkipPointer(n, muslovie)},;
                        str_find,muslovie;
                       }
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := mtitle
t_arr[BR_TITUL_COLOR] := "W+/GR"
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.t.,300}
t_arr[BR_COLUMN] := {}
aadd(t_arr[BR_COLUMN], { padc("Дата",10),{|| full_date(opl->date_opl) }, blk })
aadd(t_arr[BR_COLUMN], { "Тип оплаты",{|| inieditspr(A__MENUVERT, menu_opl, opl->tip_opl) }, blk })
aadd(t_arr[BR_COLUMN], { "  Сумма",{|| put_kop(opl->summa_opl,10) }, blk })
aadd(t_arr[BR_COLUMN], { "  Примечание",{|| opl->prim }, blk })
s := "^<Esc>^ выход ^<Enter>^ редактирование ^<Ins>^ добавление ^<Del>^ удаление"
if is_task(X_ORTO) .and. par == 2
  s += " ^<F3>^ортопедия"
endif
t_arr[BR_STAT_MSG] := {|| status_key(s) }
t_arr[BR_EDIT] := {|nk,ob| fi_opl_vz(nk,ob,"edit") }
edit_browse(t_arr)
restscreen(buf)
G_SUnLock(str_find)
return NIL

*****  10.03.19
Function fi_opl_vz(nKey,oBrow,regim,lregim)
Local ret := -1
Local buf, fl := .f., rec, rec1, k := 14, tmp_color, arr, mdate, nfile, sh := 60
do case
  case regim == "open"
    G_Use(dir_server+"plat_vz",dir_server+"plat_vz","OPL")
    find (str_find)
    ret := found()
  case regim == "edit"
    do case
      case is_task(X_ORTO) .and. par == 2 .and. nKey == K_F3
        arr := {}
        use_base("hum_oro")
        r_use_base("hum_ort")
        find (str(glob_kartotek,7))
        do while human->kod_k == glob_kartotek
          select HO
          find (str(human->(recno()),7))
          do while ho->kod == human->(recno())
            if ho->tip_usl == OU_D_SMO ; // ДМС
                .and. (mdate := c4tod(ho->pdate)) > sys_date-366 // на год назад
              aadd(arr, {mdate,ho->cena_opl,ho->prim})
            endif
            skip
          enddo
          select HUMAN
          skip
        enddo
        ho->(dbCloseArea())
        human->(dbCloseArea())
        select OPL
        if empty(arr)
          func_error(4,"Нет информации по оплате ДМС ортопедических услуг за последний год!")
        else
          asort(arr,,,{|x,y| x[1] < y[1]})
          nfile := "_dms_ort"+stxt
          strfile(center("Оплата по ДМС ортопедических услуг за последний год",sh)+eos,nfile)
          strfile(center(glob_k_fio,sh)+eos+eos,nfile,.t.)
          strfile("─────────────┬─────────────────────┬────────────────────────"+eos,nfile,.t.)
          strfile(" Дата оплаты │ Сумма оплаты по ДМС │      Примечание        "+eos,nfile,.t.)
          strfile("─────────────┼─────────────────────┼────────────────────────"+eos,nfile,.t.)
          ss := 0
          for k := 1 to len(arr)
            strfile(padc(full_date(arr[k,1]),13)+"│"+;
                    str(arr[k,2],14,2)+"       │  "+;
                    arr[k,3]+eos,nfile,.t.)
            ss += arr[k,2]
          next
          strfile("─────────────┴─────────────────────┴────────────────────────"+eos,nfile,.t.)
          strfile(padc("Итого:",13)+str(ss,15,2)+eos,nfile,.t.)
          viewtext(nfile)
        endif
      case nKey == K_INS .or. (nKey == K_ENTER .and. opl->tip > 0)
        if nKey == K_ENTER .and. !ver_pub_date(opl->date_opl,.t.)
          return ret
        endif
        save screen to buf
        if nkey == K_INS .and. !fl_found
          colorwin(pr1+3,pc1,pr1+3,pc2,"N/N","W+/N")
          colorwin(pr1+3,pc1,pr1+3,pc2,"N/N","W+/B")
        endif
        rec := recno()
        Private mtip_opl, m1tip_opl := if(nkey==K_INS, 0, opl->tip_opl),;
                mdate_opl := if(nKey == K_INS, sys_date, opl->date_opl),;
                msumma_opl := if(nKey == K_INS, 0, opl->summa_opl),;
                mprim := if(nKey == K_INS, space(15), opl->prim),;
                gl_area := {1,0,23,79,0}
        mtip_opl := inieditspr(A__MENUVERT, menu_opl, m1tip_opl)
        tmp_color := setcolor(cDataCScr)
        box_shadow(k,pc1+1,21,pc2-1,,;
                       if(nKey == K_INS,"Добавление","Редактирование"),;
                       cDataPgDn)
        setcolor(cDataCGet)
        @ k+2,pc1+3 say "Тип оплаты" get mtip_opl ;
                    reader {|x|menu_reader(x,menu_opl,A__MENUVERT,,,.f.)}
        @ k+3,pc1+3 say "Дата оплаты" get mdate_opl
        @ k+4,pc1+3 say "Сумма оплаты" get msumma_opl pict pict_cena
        @ k+5,pc1+3 say "Примечание" get mprim
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. !empty(msumma_opl) .and. f_Esc_Enter(1)
          if nKey == K_INS
            fl_found := .t.
            AddRec(1)
            if par == 1
              opl->tip := 2
              opl->pr_smo := glob_pr_vz[1]
            else
              opl->tip := 1
              opl->pr_smo := glob_d_smo[1]
              opl->kod_k := glob_kartotek
            endif
            rec := recno()
          else
            G_RLock(forever)
          endif
          opl->tip_opl   := m1tip_opl
          opl->date_opl  := mdate_opl
          opl->summa_opl := msumma_opl
          opl->prim      := mprim
          UNLOCK
          COMMIT
          oBrow:goTop()
          goto (rec)
          ret := 0
        elseif nKey == K_INS .and. !fl_found
          ret := 1
        endif
        setcolor(tmp_color)
        restore screen from buf
      case nKey == K_DEL .and. opl->tip > 0
        if ver_pub_date(opl->date_opl,.t.) .and. f_Esc_Enter(2)
          DeleteRec()
          oBrow:goTop()
          find (str_find)
          ret := 0
          if !found()
            ret := 1
          endif
        endif
    endcase
endcase
return ret

*

***** 03.10.17
Function edit_pr_vz()
Static mas_edit := { "~Просмотр",;
                     "~Редактирование",;
                     "~Добавление",;
                     "~Удаление"}
Local i := 1, k, buf := savescreen(), str_sem := "Редактирование предприятий по взаимозачету"
if !G_SLock(str_sem)
  return func_error(4,err_slock)
endif
do while i > 0
  if (i := popup_prompt(T_ROW, T_COL-5, i, mas_edit,,,,.f.)) == A__APPEND
    if (k := f_edit_spr(A__APPEND,gmenu_pl_d_smo,"предприятию по взаимозачету",;
                        "G_Use(dir_server+'p_pr_vz')",0,,,,,,"f_emp_strah")) > 0
      glob_pr_vz[1] := k
    endif
  elseif i != 0 .and. input_pr_vz(T_ROW+i+1,T_COL-10)
    f_edit_spr(i,gmenu_pl_d_smo,"предприятию по взаимозачету",;
               "G_Use(dir_server+'p_pr_vz')",0,glob_pr_vz[1],,"fdel_pr_vz",,,"f_emp_strah")
  endif
enddo
G_SUnLock(str_sem)
restscreen(buf)
return NIL

*****
Function input_pr_vz(r,c)
Local fl := .f., k
if (k := popup_edit(dir_server+"p_pr_vz",r,c,r+10,glob_pr_vz[1],4)) != NIL
  glob_pr_vz := {k[1],alltrim(k[2])} ; fl := .t.
endif
return fl

*****
Function fdel_pr_vz(mkod)
Local fl := .t., buf := save_row(maxrow())
stat_msg("Ждите! Производится проверка на допустимость удаления данного предприятия")
R_Use(dir_server+"hum_p",,"HP")
Locate for tip_usl == PU_PR_VZ .and. pr_smo == mkod progress
fl := !found()
hp->(dbCloseArea())
//
R_Use(dir_server+"hum_oro",,"HP")
Locate for tip_usl == 2 .and. pr_smo == mkod progress
fl := !found()
hp->(dbCloseArea())
if !fl
  func_error(4,"Данное предприятие встречается в других базах данных. Удаление запрещено!")
endif
rest_box(buf)
return fl

*

***** 03.10.17
Function edit_d_smo()
Static mas_edit := { "~Просмотр",;
                     "~Редактирование",;
                     "~Добавление",;
                     "~Удаление"}
Local i := 1, k, buf := savescreen(), str_sem := "Редактирование добровольных СМО"
if !G_SLock(str_sem)
  return func_error(4,err_slock)
endif
do while i > 0
  if (i := popup_prompt(T_ROW, T_COL-5, i, mas_edit,,,,.f.)) == A__APPEND
    if (k := f_edit_spr(A__APPEND,gmenu_pl_d_smo,"добровольному СМО",;
                        "G_Use(dir_server+'p_d_smo')",0,,,,,,"f_emp_strah")) > 0
      glob_d_smo[1] := k
    endif
  elseif i != 0 .and. input_d_smo(T_ROW+i+1,T_COL-10)
    f_edit_spr(i,gmenu_pl_d_smo,"добровольному СМО",;
               "G_Use(dir_server+'p_d_smo')",0,glob_d_smo[1],,"fdel_d_smo",,,"f_emp_strah")
  endif
enddo
G_SUnLock(str_sem)
restscreen(buf)
return NIL

*****
Function input_d_smo(r,c)
Local fl := .f., k
if (k := popup_edit(dir_server+"p_d_smo",r,c,r+10,glob_d_smo[1],4)) != NIL
  glob_d_smo := {k[1],alltrim(k[2])} ; fl := .t.
endif
return fl

*****
Function fdel_d_smo(mkod)
Local fl := .t., buf := save_row(maxrow())
stat_msg("Ждите! Производится проверка на допустимость удаления данной компании")
R_Use(dir_server+"hum_p",,"HP")
Locate for tip_usl == PU_D_SMO .and. pr_smo == mkod progress
fl := !found()
hp->(dbCloseArea())
//
R_Use(dir_server+"hum_oro",,"HP")
Locate for tip_usl == 3 .and. pr_smo == mkod progress
fl := !found()
hp->(dbCloseArea())
if !fl
  func_error(4,"Данная компания встречается в других базах данных. Удаление запрещено!")
endif
rest_box(buf)
return fl

*

***** проверить дату, по которую (включительно) запрещено редактировать данные
Function ver_pub_date(ldate,is_msg)
DEFAULT is_msg TO .f.
is_public_date := .t.
if type("public_date") == "D" .and. !empty(public_date) ;
                              .and. !empty(ldate) .and. public_date >= ldate
  is_public_date := .f.
  if is_msg
    func_error(2,"По "+full_date(public_date)+"г. включительно данные закрыты для редактирования!")
  endif
endif
return is_public_date
