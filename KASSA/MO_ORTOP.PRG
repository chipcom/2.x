*******************************************************************************
* mo_ortop.prg
*******************************************************************************
*  sin_ysl()
*  f1edit_ort(oBrow)
*  f2edit_ort(nKey,oBrow)
*  vvod_tor_ysl()
*  ff1edit_ysl(oBrow)
*  ff2edit_ysl(nKey,oBrow)
*  fore_o_kusl(get,when_valid,k)
*  MT_use_base(k)
*  Ort_boln(par1)
*  add_orto_usl(larr,lkod)
*  Ort_oborot()
*  Ort_diagnoz()
*  O_dms_reestr()
*  f1_Ort_vzaim(nKey,oBrow,regim)
*  f2_Ort_vzaim(nKey,oBrow,regim)
*  Orees2_vzaim(name_file)
*  Oo_proverka(k)
*  Oo_1_proverka()
*  Oo_2_proverka()
*  Ort_den_sr(par)
*  Oo_statist(k)
*  Oob_statist(par1,par2,par3)
*  Oob1_statist(par1)
*  Ort_material()
*  Ort_dolgi(tip)
*  Ort_otkr_nar(par1,par2)
*  Ort_mnog_poisk()
*  s1_mnog_poisk(cv,cf)
*  writeOmn_p(k)
*  O_ret_pl_b()
*  O_ved_narabot()
*  O_vr_kol_nar() - врачи/техники + количество нарядов
*  inputNorpozic(r,c,fl_max)
*  pl_ordogovor()
*  pl_or2dogovor(tip_jurn)
*  oo_spmater()
*  oo1spmater()
*  f1_forma_30_prn_na(par,title)
*  cre_tmp_30(adbf)
*  get_nastr_orto_f30()
*  f1_forma_30_na(par,title)
*  forma_30_na(tip)
*  write_f30(ar)
*  ___f_30(k)
*  yes_f_30(par1)
*  forma_30all(tip_f30)
*  or_vozvrat()
*******************************************************************************
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static f30_nastr := "f30_nast.ini"
Static f30_sect := "Форма 30 - "

*

***** 13.11.18
Function sin_ysl()
Local buf := save_row(maxrow()), fl := .f.
Private rr := T_ROW, fl_found := .f., reg_klient := 1
mywait()
if R_Use(dir_server+"tip_orto",,"TO")
  go top
  Alpha_Browse(rr,27,maxrow()-2,70,"f1edit_ort",color0,,,,,,,"f2edit_ort",,{,,,"N/BG,W+/N",.t.,200})
  to->(dbclosearea())
endif
rest_box(buf)
return NIL

*****
Function f1edit_ort(oBrow)
Local blk := { {1,2} }
oBrow:addColumn(TBColumnNew(center("Услуга",40),{||to->name}))
//
status_key("^<Esc>^ - выход; ^<Ctrl+Enter>^ - редактирование")
return NIL

*****
Function f2edit_ort(nKey,oBrow)
LOCAL j := 0, flag := -1, buf := save_row(maxrow()), buf1, fl := .f., rec, ;
      mkod, t_arr
do case
  case nKey == K_CTRL_RET
    mkod := recno()
    Private big_kod := mkod
    vvod_tor_ysl()
    select to
    oBrow:goTop()
    goto (mkod)
    flag := 0
  otherwise
    keyboard ""
endcase
return flag

*

***** 13.03.19
Function vvod_tor_ysl()
Local buf := save_row(maxrow()), fl := .f.
Private rr := T_ROW, fl_found := .f., reg_klient := 1
//if glob_mo[_MO_KOD_TFOMS] == '395301' // Камышин СТОМ
//  str_find := STR(big_kod,6)
//else
  str_find := STR(big_kod,4)
//endif
muslovie := "kod_tip==big_kod"
arr_blk := {{|| FindFirst(str_find)},;
            {|| FindLast(str_find)},;
            {|n| SkipPointer(n, muslovie)},;
            str_find, muslovie;
           }
if glob_mo[_MO_KOD_TFOMS] == '395301' // Камышин СТОМ
  R_Use(dir_server+"mo_su",{dir_server+"mo_su",;
                                   dir_server+"mo_sush"},"USL")
  G_Use(dir_server+"ortoped2",dir_server+"ortoped2","ORTO2") //19.04
  set relation to str(kod_usl,6) into USL
else
  R_Use(dir_server+"uslugi",{dir_server+"uslugi",;
                                   dir_server+"uslugish"},"USL")
  G_Use(dir_server+"ortoped2",dir_server+"ortoped2","ORTO2") //19.04
  set relation to str(kod_usl,4) into USL
endif
find (str_find)
if !(fl_found := found())
  keyboard chr(K_INS)
endif
Alpha_Browse(5,5,maxrow()-2,73,"ff1edit_ysl",color0,,,,,arr_blk,,"ff2edit_ysl",,{,,,"N/BG,W+/N",.t.,200})
usl->(dbclosearea())
orto2->(dbclosearea())
rest_box(buf)
return NIL

*****
Function ff1edit_ysl(oBrow)
Local blk := { {1,2} }
oBrow:addColumn(TBColumnNew(center(to->name,65),{||usl->shifr+" "+padr(usl->name,56)}))
//
status_key("^<Esc>^ - выход;  ^<Enter>^ - редактирование;  ^<Ins>^ - добавление;  ^<Del>^ - удаление")
return NIL

*****
Function ff2edit_ysl(nKey,oBrow)
LOCAL j := 0, flag := -1, buf := save_row(maxrow()), buf1, fl := .f., rec, ;
      mkod, t_arr
do case
  case nKey == K_INS .or. nKey == K_ENTER
    if nKey == K_INS
      colorwin(8,6,8,72,"N/N","W+/N")
      colorwin(8,6,8,72,"N/N","W+/B")
    endif
    mkod := recno()
    str_sem := "Редактирование состава услуги"
    if !G_SLock(str_sem)
      return func_error(4,err_slock)
    endif
    buf1 := box_shadow(9,5,14,75,color8,;
             if(nKey == K_INS,"Добавление новой услуги",;
              "Редактирование услуги"),cDataPgDn)
    Private mu_kod := if(nKey == K_INS, 0, orto2->kod_usl),;
            mshifr := if(nKey == K_INS, space(10), usl->shifr),;
            mname_u := if(nKey == K_INS, space(65), usl->name)
    setcolor(cDataCGet)
    @ 11,7 say "Шифр услуги из ОРТОПЕДИИ / ОМС" get mshifr pict "@!" ;
               when {|g| fore_o_kusl(g,1,2) } ;
               valid {|g| fore_o_kusl(g,2,2) }
    @ 12,7 say "Услуга" get mname_u pict "@S55" when .f.
    myread()
    select orto2
    goto (mkod)
    if lastkey() != K_ESC .and. f_Esc_Enter(1)
      if nKey == K_INS
        append blank
        orto2->kod_tip := big_kod
      else
        G_RLock(forever)
      endif
      orto2->kod_usl := mu_kod
      unlock
      commit
    endif
    G_SUnLock(str_sem)
    if nKey == K_INS
      go top
      oBrow:goTop()
      goto (mkod)
    endif
    select orto2
    rest_box(buf) ; rest_box(buf1) ; flag := 0
  case nKey == K_DEL .and. f_Esc_Enter(2)
    select ORTO2
    G_RLock(forever)
    DeleteRec()
    oBrow:goTop()
    flag := 0
  otherwise
    keyboard ""
endcase
return flag

*

*****
Function fore_o_kusl(get,when_valid,k)
Local fl := .t., s, old_kod
if when_valid == 1    // when
  if k == 2     // Шифр услуги
    if !empty(mshifr)
      fl := .f.
    endif
  endif
else                  // valid
  if k == 2 // Шифр услуги
    if !empty(mshifr) .and. !(mshifr == get:original)
      mshifr := transform_shifr(mshifr)
      select USL
      set order to 2
      find (mshifr)
      if found()
        mu_kod := usl->kod
        mname_u := usl->name
        update_gets()
      else
        fl := func_error(4,"Такого шифра нет в базе данных услуг.")
      endif
      set order to 1
    endif
  endif
  if !fl
    &(readvar()) := get:original
  endif
endif
return fl

*

*****
Function MT_use_base(k)
Local fl := .t.
k := lower(k)
do case
  case k == "ortoped"
    fl := G_use(dir_server+"ortoped")
  case k == "ortoped1"
    fl := G_use(dir_server+"ortoped1")
  case k == "tip_orto"
    fl := G_Use(dir_server+"tip_orto")
endcase
return fl

*

***** 13.11.18
Function MT_R_use_base(k)
Local fl := .t.
k := lower(k)
do case
  case k == "ortoped"
    fl := R_use(dir_server+"ortoped")
  case k == "ortoped1"
    fl := R_use(dir_server+"ortoped1")
  case k == "tip_orto"
    fl := R_Use(dir_server+"tip_orto")
endcase
return fl

*

*****
Function Ort_boln(par1)
Local arr, arr_title, reg_print, sh, HH := 58, buf, s, s1, s2, fl, j,;
      begin_date, end_date, fl_exit := .f., name_file := "orto_b1"+stxt,;
      mperso, i, k
DEFAULT par1 TO ""
if (pr_pl_bes := O_ret_pl_b()) == 0
  return NIL
endif
if (arr := year_month()) == NIL
  return NIL
endif
begin_date := arr[5]
end_date := arr[6]
buf := save_row(maxrow())
if eq_any(par1,"vr","tehn")
  if (mperso := input_kperso()) == NIL  // ==> весь персонал
    mywait()
    mperso := {}
    R_Use(dir_server+"mo_pers",,"perso")
    go top
    do while !eof()
      if perso->kod > 0
        aadd(mperso, {perso->kod,""} )
      endif
      skip
    enddo
    perso->(dbCloseArea())
  endif
  dbcreate(cur_dir+"tmp1", {;
     {"KOD",        "N",      4,      0},;  // код персонала
     {"FIO",        "C",     50,      0},;  // Ф.И.О.
     {"STOIM_B",    "N",     12,      2},;  // бесплатная стоимость лечения
     {"STOIM_P",    "N",     12,      2},;  // платная стоимость лечения
     {"STOIM_N",    "N",     12,      2} ;  // стоимость напыления
    })
  use (cur_dir+"tmp1") new
  index on str(kod,4) to (cur_dir+"tmp1")
endif
musluga := alltrim(mem_ort_na)
if empty(musluga) .or. musluga == "*"
  musluga := "9999999999"
endif
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
dbcreate(cur_dir+"tmp", {;
   {"KOD",        "N",      4,      0},;  // код по БД tmp1
   {"KOD_H",      "N",      7,      0},;  // код по БД hum_ort
   {"FIO",        "C",     50,      0},;  // Ф.И.О. больного
   {"ADRES",      "C",     50,      0},;  // адрес больного
   {"N_NAR",      "N",      5,      0},;  // номер наряда
   {"N_DATA",     "D",      8,      0},;  // дата начала лечения
   {"K_DATA",     "D",      8,      0},;  // дата окончания лечения
   {"STOIM_B",    "N",     12,      2},;  // бесплатная стоимость лечения
   {"STOIM_P",    "N",     12,      2},;  // платная стоимость лечения
   {"STOIM_N",    "N",     12,      2},;  // стоимость напыления
   {"KOL_POS",    "N",      2,      0};   // количество посещений
  })
use (cur_dir+"tmp") new
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"mo_pers",,"PERSO")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
set relation to u_kod into USL
R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
set relation to kod_k into KART
dbseek(dtos(begin_date),.t.)
do while human->k_data <= end_date .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  s1 := s2 := s3 := 0
  select HU
  find (str(human->(recno()),7))
  do while hu->kod == human->(recno()) .and. !eof()
    if hu->tip_usl != OU_B_PLAT  // платная услуга
      s2 += hu->stoim
    else
      s1 += hu->stoim
    endif
    if like(musluga,usl->shifr)
      s3 += hu->stoim  // напыление
    endif
    skip
  enddo
  fl := .f. ; s1 := round(s1,2) ; s2 := round(s2,2) ; s3 := round(s3,2)
  do case
    case pr_pl_bes == 1  // платные
      //fl := empty(s1) .and. !empty(s2)
      fl := !empty(s2)
    case pr_pl_bes == 2  // бесплатные
      fl := !empty(s1)
    case pr_pl_bes == 3  // все
      fl := !emptyall(s1,s2)
  endcase
  if fl
    if eq_any(par1,"vr","tehn")
      mkod := if(par1 == "vr", human->kod_vr, human->kod_as)
      if (fl := (mkod > 0 .and. ascan(mperso,{|x| x[1]==mkod }) > 0))
        select TMP1
        find (str(mkod,4))
        if !found()
          append blank
          tmp1->kod := mkod
          select PERSO
          goto (mkod)
          tmp1->fio := perso->fio
        endif
        tmp1->STOIM_B += s1
        tmp1->STOIM_P += s2
        tmp1->STOIM_N += s3
      endif
    endif
    if fl
      select TMP
      append blank
      if eq_any(par1,"vr","tehn")
        tmp->kod := tmp1->kod
      endif
      tmp->FIO := kart->fio
      tmp->ADRES := kart->adres
      tmp->KOD_H := human->(recno())
      tmp->N_NAR := human->nar_z
      tmp->N_DATA := human->n_data
      tmp->K_DATA := human->k_data
      tmp->STOIM_B := s1
      tmp->STOIM_P := s2
      tmp->STOIM_N := s3
      tmp->KOL_POS := human->kol_pos
      if tmp->(lastrec()) % 5000 == 0
        tmp->(dbCommit())
      endif
    endif
  endif
  select HUMAN
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  return NIL
endif
if j == 0
  return func_error(4,"Нет сведений!")
endif
mywait()
//
arr_title := {;
"──────────────────────────────┬─────┬────────┬────────┬──────",;
"                              │Наряд│  Дата  │  Дата  │Кол-во",;
"           Ф.И.О.             │заказ│нач.леч.│ ок.леч.│посещ.",;
"──────────────────────────────┴─────┴────────┴────────┴──────"}
reg_print := 3
if pr_pl_bes == 1
  arr_title[1] += "┬───────────"
  arr_title[2] += "│   Сумма   "
  arr_title[3] += "│  лечения  "
  arr_title[4] += "┴───────────"
else
  arr_title[1] += "┬────────┬──────────┬────────"
  arr_title[2] += "│Бесплат.│ Платная  │ в т.ч. "
  arr_title[3] += "│сумма л.│сумма леч.│напыл-ие"
  arr_title[4] += "┴────────┴──────────┴────────"
endif
arr_title[1] += "┬──────────────────────────────"
arr_title[2] += "│                              "
arr_title[3] += "│        Список услуг          "
arr_title[4] += "┴──────────────────────────────"
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Статистика по пролеченным больным",sh))
if par1 == "vr"
  add_string(center("[ по лечащим врачам ]",sh))
elseif par1 == "tehn"
  add_string(center("[ по зубным техникам ]",sh))
endif
add_string(center(arr[4],sh))
add_string(center(pr_titul,sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
set relation to u_kod into USL
if eq_any(par1,"vr","tehn")
  use (cur_dir+"tmp") new
  index on str(kod,4)+upper(fio) to (cur_dir+"tmp")
  use (cur_dir+"tmp1") new
  index on upper(fio) to (cur_dir+"tmp1")
  go top
  do while !eof()
    s := padr(space(4)+"["+lstr(tmp1->kod)+"]  "+upper(tmp1->fio),61)
    if pr_pl_bes == 1
      s += put_kopE(tmp1->stoim_p,12)
    else
      s += put_kopE(tmp1->stoim_b,9)+;
           put_kopE(tmp1->stoim_p,11)+;
           put_kopE(tmp1->stoim_n,9)
    endif
    if verify_FF(HH-3,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(s)
    add_string(space(4)+replicate(".",sh-4))
    select TMP
    find (str(tmp1->kod,4))
    do while tmp->kod == tmp1->kod
      s := left(tmp->fio,30)+padc(lstr(tmp->n_nar),7)+;
           date_8(tmp->n_data)+" "+date_8(tmp->k_data)+;
           padc(lstr(tmp->kol_pos),7)
      if pr_pl_bes == 1
        s += put_kopE(tmp->stoim_p,12)
      else
        s += put_kopE(tmp->stoim_b,9)+;
             put_kopE(tmp->stoim_p,11)+;
             put_kopE(tmp->stoim_n,9)
      endif
      k := add_orto_usl(arr,tmp->kod_h)
      s += " "+arr[1]
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s)
      for i := 2 to k
        add_string(space(sh-30)+arr[i])
      next
      skip
    enddo
    add_string(replicate("─",sh))
    select TMP1
    skip
  enddo
  close databases
  if fl_exit
    add_string(replicate("*",sh))
    add_string(expand("ПРОЦЕСС ПРЕРВАН"))
  endif
else
  s1 := s2 := s3 := 0
  use (cur_dir+"tmp") new
  index on upper(fio) to (cur_dir+"tmp")
  go top
  do while !eof()
    s := left(tmp->fio,30)+padc(lstr(tmp->n_nar),7)+;
         date_8(tmp->n_data)+" "+date_8(tmp->k_data)+;
         padc(lstr(tmp->kol_pos),7)
    if pr_pl_bes == 1
      s += put_kopE(tmp->stoim_p,12)
    else
      s += put_kopE(tmp->stoim_b,9)+;
           put_kopE(tmp->stoim_p,11)+;
           put_kopE(tmp->stoim_n,9)
      s1 += tmp->stoim_b
      s3 += tmp->stoim_n
    endif
    k := add_orto_usl(arr,tmp->kod_h)
    s += " "+arr[1]
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(s)
    s2 += tmp->stoim_p
    add_string(padr(space(4)+tmp->adres,sh-30)+arr[2])
    for i := 3 to k
      add_string(space(sh-30)+arr[i])
    next
    skip
  enddo
  close databases
  if fl_exit
    add_string(replicate("*",sh))
    add_string(expand("ПРОЦЕСС ПРЕРВАН"))
  endif
  add_string(replicate("─",sh))
  if pr_pl_bes == 1
    s := put_kopE(s2,12)
  else
    s := put_kopE(s1,9)+put_kopE(s2,11)+put_kopE(s3,9)
  endif
  add_string(padr("Кол-во больных - "+lstr(j),25)+padl(s,sh-25-31))
endif
fclose(fp)
close databases
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*****
Function add_orto_usl(larr,lkod)
Local i, k, s := "", arr := {}, tmp_select := select()
select HU
find (str(lkod,7))
do while hu->kod==lkod
  aadd(arr,alltrim(usl->shifr))
  skip
enddo
asort(arr,,,{|x,y| fsort_usl(x) < fsort_usl(y) } )
aeval(arr, {|x| s += x+"," } )
if len(s) > 0
  s := left(s,len(s)-1)
endif
k := perenos(larr,s,30)
aeval(larr, {|x,i| larr[i] := center(alltrim(x),30) } )
select (tmp_select)
return k

*

*****
Function Ort_oborot()
Local arr, arr_title, reg_print, sh, HH := 38, buf, s, s1, s2, s3, fl, j,;
      begin_date, end_date, fl_exit := .f., name_file := "orto_OB"+stxt,;
      mperso, i, k, s4, s5, s11, s21, s31, s41, s51
if (pr_pl_bes := O_ret_pl_b()) == 0
  return NIL
endif
if (arr := year_month()) == NIL
  return NIL
endif
begin_date := arr[5]
end_date := arr[6]
buf := save_row(maxrow())
musluga := alltrim(mem_ort_na)
if empty(musluga) .or. musluga == "*"
  musluga := "9999999999"
endif
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
dbcreate(cur_dir+"tmp", {;
   {"KOD",        "N",      4,      0},;  // код по БД tmp1
   {"KOD_H",      "N",      7,      0},;  // код по БД hum_ort
   {"FIO",        "C",     50,      0},;  // Ф.И.О. больного
   {"N_NAR",      "N",      5,      0},;  // номер наряда
   {"N_DATA",     "D",      8,      0},;  // дата начала лечения
   {"K_DATA",     "D",      8,      0},;  // дата окончания лечения
   {"STOIM_P",    "N",     12,      2},;  // платная стоимость лечения
   {"STOIM_N",    "N",     12,      2},;  // стоимость напыления
   {"OPLATA",     "N",     12,      2},;  // оплаченая сумма
   {"OPLATA_N",   "N",     12,      2},;   // оплаченая сумма напыление
   {"D_STOIM_P",  "N",     12,      2},;  // платная стоимость лечения
   {"D_STOIM_N",  "N",     12,      2},;  // стоимость напыления
   {"D_OPLATA",   "N",     12,      2},;  // оплаченая сумма
   {"D_OPLATA_N", "N",     12,      2};   // оплаченая сумма напыление
  })
use (cur_dir+"tmp") new
R_Use(dir_server+"hum_oro",dir_server+"hum_oro","HO")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"mo_pers",,"PERSO")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
set relation to u_kod into USL
R_Use(dir_server+"hum_ort",,"HUMAN")
set relation to kod_k into KART
go top
do while !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  fl := .t.
  do case
    case pr_pl_bes == 1  // платные
      fl := (human->tip_usl == 0)
    case pr_pl_bes == 2  // бесплатные
      fl := (human->tip_usl == 1)
  endcase
  if fl
    s1 := s2 := s3 := s4 := s5 := 0
    s11 := s21 := s31 := s41 := s51 := 0
    // Дебет - оказанные услуги попадают только при закрытии
    // т.к. наряд может быть откорректирован
    if between(human->k_data,begin_date,end_date)
       // услуги в диапазоне закрытия
      select HU
      find (str(human->(recno()),7))
      do while hu->kod == human->(recno()) .and. !eof()
        if like(musluga,usl->shifr)
          s31 += hu->stoim  // напыление
        elseif eq_any(hu->tip_usl,0,2)  // платная услуга
          s21 += hu->stoim
        endif
        skip
      enddo
    elseif !empty(human->k_data) .and. human->k_data < begin_date
      // закрыт до текущего периода
      select HU
      find (str(human->(recno()),7))
      do while hu->kod == human->(recno()) .and. !eof()
        if like(musluga,usl->shifr)
          s3 += hu->stoim  // напыление
        elseif eq_any(hu->tip_usl,0,2)  // платная услуга
          s2 += hu->stoim
        endif
        skip
      enddo
    endif
    // оплата всегда
    select HO
    find (str(human->(recno()),7))
    do while ho->kod == human->(recno()) .and. !eof()
      if empty(ho->kv_cia)
        //s3 += ho->cena_opl  // бесплатно
      else
        if ho->tip_opl == 2
          if between(c4tod(ho->pdate),begin_date,end_date)
            s51 += (ho->cena_opl-ho->sum_voz)  // напыление
          elseif c4tod(ho->pdate) < begin_date
            s5 += ho->cena_opl  // напыление
          endif
        else
          if between(c4tod(ho->pdate),begin_date,end_date)
            s41 += (ho->cena_opl-ho->sum_voz)  // платно
          elseif c4tod(ho->pdate) < begin_date
            s4 += (ho->cena_opl-ho->sum_voz)  // платно
          endif
        endif
      endif
      skip
    enddo
    s2 := round(s2,2) ; s3 := round(s3,2)
    s4 := round(s4,2) ; s5 := round(s5,2)
    if human->k_data >= begin_date .or. ((s2+s3)!=(s4+s5) .and. human->k_data < begin_date);
      .or. s21 != 0 .or. s31 != 0 .or. s41 != 0 .or. s51 != 0
      select TMP
      append blank
      tmp->FIO := kart->fio
      tmp->KOD_H := human->(recno())
      tmp->N_NAR := human->nar_z
      tmp->N_DATA := human->n_data
      tmp->K_DATA := human->k_data
      tmp->STOIM_P  := s2
      tmp->STOIM_N  := s3
      tmp->OPLATA   := s4
      tmp->OPLATA_N := s5
      tmp->D_STOIM_P  := s21
      tmp->D_STOIM_N  := s31
      tmp->D_OPLATA   := s41
      tmp->D_OPLATA_N := s51
      if tmp->(lastrec()) % 5000 == 0
        tmp->(dbCommit())
      endif
    endif
  endif
  select HUMAN
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  return NIL
endif
if j == 0
  return func_error(4,"Нет сведений!")
endif
mywait()
//
arr_title := {;
"─────┬──────────────────────────────┬─────────────────────────────────┬─────────────────────────────────┬─────────────────────────────────",;
"Наряд│                              │__________Входное сальдо_________│____________Движение_____________│________Выходное сальдо__________",;
"заказ│           Ф.И.О.             │ Сделано│Напылен│Оплачено│Напылен│ Сделано│Напылен│Оплачено│Напылен│ Сделано│Напылен│Оплачено│Напылен",;
"─────┴──────────────────────────────┴────────┴───────┴────────┴───────┴────────┴───────┴────────┴───────┴────────┴───────┴────────┴───────"}
reg_print := 3
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Оборотная ведомость по пролеченным больным",sh))
add_string(center(arr[4],sh))
add_string(center(pr_titul,sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
s1 := s2 := s3 := s4 := s5 := 0
s11 := s21 := s31 := s41 := s51 := 0
s6 := s7 := s8 := s9 := 0
use (cur_dir+"tmp") new
index on n_nar to (cur_dir+"tmp")
go top
j := 1
do while !eof()
  s := padc(lstr(tmp->n_nar),6)+left(tmp->fio,30)
  s += put_kope(tmp->stoim_p,9)+;
       put_kope(tmp->stoim_n,8)+;
       put_kope(tmp->oplata,9)+;
       put_kope(tmp->oplata_n,8)
  s += put_kope(tmp->d_stoim_p,9)+;
       put_kope(tmp->d_stoim_n,8)+;
       put_kope(tmp->d_oplata,9)+;
       put_kope(tmp->d_oplata_n,8)
  t1 := t2 := t3 := t4 := 0
  z := tmp->stoim_p+tmp->d_stoim_p-tmp->oplata-tmp->d_oplata
  if z > 0
    t1 := z
  else
    t3 := z*(-1)
  endif
  z := tmp->stoim_n+tmp->d_stoim_n-tmp->oplata_n-tmp->d_oplata_n
  if z > 0
    t2 := z
  else
    t4 := z*(-1)
  endif
  s += put_kope(t1,9)+;
       put_kope(t2,8)+;
       put_kope(t3,9)+;
       put_kope(t4,8)
  if !empty(substr(s,38))
    add_string(s)
    ++j
  endif
  s2 += tmp->stoim_p
  s3 += tmp->stoim_n
  s4 += tmp->oplata
  s5 += tmp->oplata_n
  s21 += tmp->d_stoim_p
  s31 += tmp->d_stoim_n
  s41 += tmp->d_oplata
  s51 += tmp->d_oplata_n
  s6 += t1
  s7 += t2
  s8 += t3
  s9 += t4
  if verify_FF(HH-3,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  skip
enddo
close databases
if fl_exit
  add_string(replicate("*",sh))
  add_string(expand("ПРОЦЕСС ПРЕРВАН"))
endif
add_string(replicate("─",sh))
add_string(padr("Кол-во больных - "+lstr(j),30+5)+;
           put_kop(s2,10)+;
           space(7)+;
           put_kop(s4,10)+;
           space(7)+;
           put_kop(s21,10)+;
           space(7)+;
           put_kop(s41,10)+;
           space(7)+;
           put_kop(s6,10)+;
           space(7)+;
           put_kop(s8,10))
add_string(space(30+6)+;
           space(8)+;
           put_kop(s3,9)+;
           space(8)+;
           put_kop(s5,9)+;
           space(8)+;
           put_kop(s31,9)+;
           space(8)+;
           put_kop(s51,9)+;
           space(8)+;
           put_kop(s7,9)+;
           space(8)+;
           put_kop(s9,9))
fclose(fp)
close databases
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

*****
Function Ort_diagnoz()
Local arr, arr_title, reg_print := 2, sh, HH := 58, i, s, s1, s2, fl,;
      begin_date, end_date, fl_exit := .f., name_file := "ort_diag"+stxt,;
      adbf, arr_diag := {}, ob_kol := 0, t_arr[4], kol_bez := 0
Local buf := save_row(maxrow())
if (arr := year_month()) == NIL
  return NIL
endif
begin_date := arr[5]
end_date := arr[6]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
R_Use(dir_server+"diag_ort",dir_server+"diag_ort","DIAG")
dbeval({|| aadd(arr_diag, {recno(),0,shifr,name}) } )
adbf := {;
   {"KOD",        "N",      4,      0},;  // код персонала
   {"FIO",        "C",     50,      0};  // Ф.И.О.
  }
for i := 1 to len(arr_diag)
  aadd(adbf, {"diag"+lstr(arr_diag[i,1]),"N",5,0} )
next
aadd(adbf, {"diag999999","N",5,0} )
dbcreate(cur_dir+"tmp", adbf)
use (cur_dir+"tmp") new
index on str(kod,4) to (cur_dir+"tmp")
R_Use(dir_server+"mo_pers",,"PERSO")
R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
dbseek(dtos(begin_date),.t.)
do while human->k_data <= end_date .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if !empty(human->kod_vr)
    if emptyall(human->kod_diag,human->kod_diag2,human->kod_diag3)
      ++ob_kol
      select TMP
      find (str(human->kod_vr,4))
      if !found()
        append blank
        tmp->kod := human->kod_vr
        perso->(dbGoto(human->kod_vr))
        tmp->fio := perso->fio
      endif
      tmp->diag999999 ++
      //arr_diag[k,2] ++
      ++kol_bez
    else
      fl := .f.
      for i := 1 to 3
        do case
          case i == 1
            pole := "human->kod_diag"
          case i == 2
            pole := "human->kod_diag2"
          case i == 3
            pole := "human->kod_diag3"
        endcase
        if !empty(&pole)
          select DIAG
          find (&pole)
          if found() .and. (k := ascan(arr_diag,{|x| x[1]==diag->(recno())})) > 0
            if !fl
              ++ob_kol ; fl := .t.
            endif
            select TMP
            find (str(human->kod_vr,4))
            if !found()
              append blank
              tmp->kod := human->kod_vr
              perso->(dbGoto(human->kod_vr))
              tmp->fio := perso->fio
            endif
            pole1 := "tmp->diag"+lstr(diag->(recno()))
            &pole1 := &pole1+1
            arr_diag[k,2] ++
          endif
        endif
      next
    endif
  endif
  select HUMAN
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  return NIL
endif
if j == 0
  return func_error(4,"Нет сведений!")
endif
mywait()
asort(arr_diag,,,{|x,y| x[3] < y[3] } )
if kol_bez > 0
  aadd(arr_diag, {999999,kol_bez,"","без указания диагноза"})
endif
//
arr_title := {;
"──────────────────────────────",;
"                              ",;
"                              ",;
"        Ф.И.О. врача          ",;
"                              ",;
"                              ",;
"──────────────────────────────"}
for i := 1 to len(arr_diag)
  if arr_diag[i,2] > 0
    perenos(t_arr,arr_diag[i,4],10)
    arr_title[1] += "┬──────────"
    arr_title[2] += "│"+padc(alltrim(arr_diag[i,3]),10)
    arr_title[3] += "│"+padr(t_arr[1],10)
    arr_title[4] += "│"+padr(t_arr[2],10)
    arr_title[5] += "│"+padr(t_arr[3],10)
    arr_title[6] += "│"+padr(t_arr[4],10)
    arr_title[7] += "┴──────────"
  endif
next
sh := len(arr_title[1])
if sh <= 64
  sh := 64
  reg_print := 1
elseif sh <= 84
  reg_print := 2
elseif sh <= 120
  reg_print := 3
elseif sh <= 160
  reg_print := 2
else
  reg_print := 3
endif
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Статистика по диагнозам",sh))
add_string(center(arr[4],sh))
use (cur_dir+"tmp") new
index on upper(fio) to (cur_dir+"tmp")
add_string("")
aeval(arr_title, {|x| add_string(x) } )
go top
do while !eof()
  s := padr(tmp->fio,30)
  for i := 1 to len(arr_diag)
    if arr_diag[i,2] > 0
      pole := "tmp->diag"+lstr(arr_diag[i,1])
      s += put_val(&pole,7)+space(4)
    endif
  next
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(s)
  skip
enddo
close databases
if fl_exit
  add_string(replicate("*",sh))
  add_string(expand("ПРОЦЕСС ПРЕРВАН"))
endif
add_string(replicate("═",sh))
s := padr("Кол-во случаев: "+lstr(ob_kol),30)
for i := 1 to len(arr_diag)
  if arr_diag[i,2] > 0
    s += put_val(arr_diag[i,2],7)+space(4)
  endif
next
add_string(s)
fclose(fp)
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

***** 11.02.13 Распечатка реестра по ДМС
Function O_dms_reestr()
Local i, j, k, fl, fl_exit := .f., buf := save_row(maxrow()),;
      t_arr[BR_LEN], blk, fl1 := .f., fl2 := .f., arr
Private arr_m
if (arr_m := year_month()) == NIL
  return NIL
endif
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
dbcreate(cur_dir+"tmp", {{"kod_k"  ,"N", 7,0},; // код больного по картотеке
                         {"tip_usl","N", 1,0},; // взаимозачет или добр.СМО
                         {"pr_smo" ,"N", 6,0},; // код предприятия / СМО
                         {"nar_z"  ,"N", 5,0},; // наряд-заказ
                         {"D_POLIS","C",25,0},; // полис
                         {"N_DATA" ,"D", 8,0},; // дата начала лечения
                         {"K_DATA" ,"D", 8,0},; // дата окончания лечения
                         {"STOIM"  ,"N",10,2}}) // итоговая стоимость услуг
use (cur_dir+"tmp") new
index on str(tip_usl,1)+str(pr_smo,6)+str(kod_k,7) to (cur_dir+"tmp")
dbcreate(cur_dir+"tmp2", {{"rec_tmp","N", 6,0},;
                          {"rec_hp" ,"N", 7,0},;
                          {"D_POLIS","C",25,0}}) // полис
use (cur_dir+"tmp2") new
R_Use(dir_server+"hum_oro",dir_server+"hum_oro","HO")
R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
dbseek(dtos(arr_m[5]),.t.)
do while human->k_data <= arr_m[6] .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  arr := {} ; mpolis := ""
  select HO
  find (str(human->(recno()),7))
  do while ho->kod == human->(recno()) .and. !eof()
    if eq_any(ho->tip_usl,OU_PR_VZ,OU_D_SMO)
      mpolis := ho->d_polis
      if (j := ascan(arr, {|x| x[1]==ho->tip_usl.and.x[2]==ho->pr_smo})) == 0
        aadd(arr, {ho->tip_usl,ho->pr_smo,0}) ; j := len(arr)
      endif
      arr[j,3] += ho->cena_opl
    endif
    skip
  enddo
  for j := 1 to len(arr)
    select TMP
    find (str(arr[j,1],1)+str(arr[j,2],3)+str(human->kod_k,7))
    if !found()
      append blank
      tmp->tip_usl := arr[j,1]
      tmp->pr_smo  := arr[j,2]
      tmp->kod_k   := human->kod_k
      tmp->n_data  := human->n_data
      tmp->k_data  := human->k_data
      tmp->d_polis := mpolis
    endif
    if tmp->n_data > human->n_data
      tmp->n_data := human->n_data
    endif
    if tmp->k_data < human->k_data
      tmp->k_data := human->k_data
    endif
    tmp->nar_z := human->nar_z
    tmp->stoim += arr[j,3]
    //
    select TMP2
    append blank
    tmp2->rec_tmp := tmp->(recno())
    tmp2->rec_hp  := human->(recno())
    tmp2->d_polis := mpolis
    if tmp2->(lastrec()) % 5000 == 0
      Commit
    endif
  next
  select HUMAN
  skip
enddo
j := tmp->(lastrec())
if !fl_exit .and. j > 0
  dbcreate(cur_dir+"tmp1", {{"name"   ,"C",30,0},; // наименование предприятия
                            {"tip_usl","N", 1,0},; // взаимозачет или добр.СМО
                            {"pr_smo" ,"N", 6,0},; // код предприятия / СМО
                            {"KOL"    ,"N", 6,0},; // количество больных
                            {"STOIM"  ,"N",11,2}}) // итоговая стоимость лечения
  R_Use(dir_server+"p_pr_vz",,"PRED")
  R_Use(dir_server+"p_d_smo",,"SMO")
  use (cur_dir+"tmp1") new
  index on str(tip_usl,1)+str(pr_smo,6) to (cur_dir+"tmp1")
  select TMP
  go top
  do while !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    select TMP1
    find (str(tmp->tip_usl,1)+str(tmp->pr_smo,6))
    if !found()
      append blank
      tmp1->tip_usl := tmp->tip_usl
      tmp1->pr_smo  := tmp->pr_smo
      if tmp->tip_usl == OU_D_SMO
        smo->(dbGoto(tmp->pr_smo))
        tmp1->name := smo->name
        fl1 := .t.
      else
        pred->(dbGoto(tmp->pr_smo))
        tmp1->name := pred->name
        fl2 := .t.
      endif
      if tmp->pr_smo == 0
        tmp1->name := "...без выбора..."
      endif
    endif
    tmp1->kol ++
    tmp1->stoim += tmp->stoim
    select TMP
    skip
  enddo
  j := tmp1->(lastrec())
  mywait()
  select TMP2
  index on str(rec_tmp,6) to (cur_dir+"tmp2")
endif
close databases
rest_box(buf)
if fl_exit
  // ничего
elseif j == 0
  func_error(4,"Нет сведений по ДМС и взаимозачету "+arr_m[4])
else
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow()-2
  t_arr[BR_LEFT] := 11
  t_arr[BR_RIGHT] := 68
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := arr_m[4]
  if fl1
    t_arr[BR_TITUL] += " (добр/страх.)"
  endif
  if fl2
    t_arr[BR_TITUL] += " (в/зачет)"
  endif
  t_arr[BR_TITUL_COLOR] := "BG+/GR"
  t_arr[BR_ARR_BROWSE] := {,,,"N/BG,W+/N,B/BG,W+/B",.t.,0}
  blk := {|| iif(tip_usl==OU_D_SMO, {1,2}, {3,4}) }
  t_arr[BR_COLUMN] := {{ center("Наименование",30), {|| tmp1->name }, blk },;
                       { "Кол-во;больных", {|| str(kol,7) }, blk },;
                       { "   Сумма;  лечения", {|| put_kop(stoim,11) }, blk }}
  t_arr[BR_EDIT] := {|nk,ob| f1_Ort_vzaim(nk,ob,"edit") }
  t_arr[BR_STAT_MSG] := {|| ;
    status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор для печати") }
  use (cur_dir+"tmp1") new
  index on upper(name) to (cur_dir+"tmp1")
  go top
  edit_browse(t_arr)
  close databases
  rest_box(buf)
endif
return NIL

*

*****
Function f1_Ort_vzaim(nKey,oBrow,regim)
Local ret := -1, buf, fl := .f., rec, t_arr[BR_LEN]
if regim == "edit" .and. nKey == K_ENTER
  rec := tmp1->(recno())
  buf := savescreen()
  mywait()
  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := maxrow()-2
  t_arr[BR_LEFT] := 2
  t_arr[BR_RIGHT] := 77
  t_arr[BR_COLOR] := color0
  if tmp1->tip_usl == OU_D_SMO
    glob_d_smo := {tmp1->pr_smo,alltrim(tmp1->name)}
    t_arr[BR_TITUL] := glob_d_smo[2]+" (добр/страх.) "+arr_m[4]
  else
    glob_pr_vz := {tmp1->pr_smo,alltrim(tmp1->name)}
    t_arr[BR_TITUL] := glob_pr_vz[2]+" (в/зачет) "+arr_m[4]
  endif
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_ARR_BROWSE] := {,,,"N/BG,W+/N,B/BG,W+/B",.t.,0}
  n := 31
  t_arr[BR_COLUMN] := {{ center("Ф.И.О.",n), {|| padr(kart->fio,n) } },;
                       { "Наряд", {|| str(nar_z,5) } },;
                       { center("Срок лечения",17), {|| date_8(n_data)+"-"+date_8(k_data) } },;
                       { " Сумма", {|| put_kop(stoim,10) } }}
  t_arr[BR_EDIT] := {|nk,ob| f2_Ort_vzaim(nk,ob,"edit") }
  t_arr[BR_STAT_MSG] := {|| ;
    status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор для печати;  ^<F9>^ - печать реестра") }
  mywait()
  use (cur_dir+"tmp2") index (cur_dir+"tmp2") new
  R_Use(dir_server+"kartotek",,"KART")
  use (cur_dir+"tmp") new alias TMP
  set relation to kod_k into KART
  index on upper(kart->fio) to (cur_dir+"tmp") ;
        for tmp1->tip_usl == tmp->tip_usl .and. tmp1->pr_smo == tmp->pr_smo
  edit_browse(t_arr)
  close databases
  restscreen(buf)
  use (cur_dir+"tmp1") index (cur_dir+"tmp1") new
  goto (rec)
endif
return ret

*

*****
Function f2_Ort_vzaim(nKey,oBrow,regim)
Local ret := -1, buf, fl := .f., rec, tmp_color, ah, ahu, i, j, fl_one,;
      s, sh, HH := 76, reg_print, arr_title, name_file := "ortorees"+stxt,;
      d, sd, kol_usl, sk, ss, is_sokr, old
do case
  case regim == "edit"
    do case
      case nKey == K_F9
        rec := tmp->(recno())
        Orees2_vzaim(name_file)
        select TMP
        goto (rec)
      case nKey == K_ENTER
        ne_real()
    endcase
endcase
return ret

*

***** 11.02.13
Function Orees2_vzaim(name_file)
Local buf := save_row(maxrow()), sh, HH := 57, arr_title, s, i, j, k, sk, ss,;
      arr2title, reg_print := 6, afio[2], lfio := 19, kfio, lsk, lss
mywait()
arr_title := {;
"───┬───────────────────┬─────────────────┬────────┬──────────┬─────────────────────────────────────────────────────────────────┬─────┬───────┬────┬──────────┬───────────",;
"NN │       Ф.И.О.      │      Номер      │  Дата  │ Код мани-│                   Название медицинской услуги                   │Отде-│  Цена │Кол.│ Сумма за │ Примечание",;
"пп │  застрахованного  │   страхового    │оказания│ пуляции  │                                                                 │ление│ каждой│оказ│все кол-во│           ",;
"   │                   │    полиса и     │  мед.  │          │                                                                 │     │ услуги│ус- │оказ.услуг│           ",;
"   │                   │  сумма оплаты   │ услуги │          │                                                                 │     │ (руб.)│луг │  (руб.)  │           ",;
"───┴───────────────────┴─────────────────┴────────┴──────────┴─────────────────────────────────────────────────────────────────┴─────┴───────┴────┴──────────┴───────────"}
arr2title := {;
"───┬───────────────────┬─────────────────┬────────┬──────────┬─────────────────────────────────────────────────────────────────┬─────┬───────┬────┬──────────┬───────────",;
" 1 │         2         │        3        │    4   │     5    │                              6                                  │  7  │   8   │ 9  │    10    │     11    ",;
"───┴───────────────────┴─────────────────┴────────┴──────────┴─────────────────────────────────────────────────────────────────┴─────┴───────┴────┴──────────┴───────────"}
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(alltrim(org->name))
org->(dbCloseArea())
if tmp1->tip_usl == OU_D_SMO
  add_string(center("Реестр N_____ оказанных медицинских услуг",sh))
  add_string(center("по полисам ДМС "+alltrim(tmp1->name),sh))
else
  add_string(center("Реестр платных услуг (взаимозачет)",sh))
  add_string(center("по предприятию: "+upper(alltrim(tmp1->name)),sh))
endif
add_string(center(arr_m[4],sh))
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"hum_oro",dir_server+"hum_oro","HO")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HPU")
R_Use(dir_server+"hum_ort",,"HP")
aeval(arr_title, {|x| add_string(x) } )
j := sk := ss := so := 0
select TMP
go top
do while !eof()
  arr := {} ; au := {}
  select TMP2
  find (str(tmp->(recno()),6))
  do while tmp2->rec_tmp == tmp->(recno()) .and. !eof()
    select HP
    goto (tmp2->rec_hp)
    select HO
    find (str(hp->(recno()),7))
    do while ho->kod == hp->(recno()) .and. !eof()
      if tmp->tip_usl == ho->tip_usl
        if (i := ascan(arr, {|x| x[1] == ho->d_polis })) == 0
          aadd(arr, {ho->d_polis,0}) ; i := len(arr)
        endif
        arr[i,2] += ho->cena_opl
      endif
      skip
    enddo
    select HPU
    find (str(hp->(recno()),7))
    do while hpu->kod == hp->(recno())
      if tmp->tip_usl == hpu->tip_usl
        otd->(dbGoto(hpu->otd))
        usl->(dbGoto(hpu->u_kod))
        aadd(au, {c4tod(hpu->date_u),;
                  usl->shifr,;
                  usl->name,;
                  otd->short_name,;
                  hpu->kol,;
                  hpu->stoim;
                 })
      endif
      select HPU
      skip
    enddo
    select TMP2
    skip
  enddo
  lsk := lss := lso := 0
  kfio := perenos(afio,alltrim(kart->fio),lfio)
  kpolis := 0 ; apolis := {}
  for i := 1 to len(arr)
    s := alltrim(arr[i,1])
    if len(s) <= 17
      aadd(apolis, s)
      aadd(apolis, lstr(arr[i,2],10,2))
    else
      aadd(apolis, left(s,17))
      aadd(apolis, substr(s,18)+"/"+lstr(arr[i,2],10,2))
    endif
    kpolis += 2
    lso += arr[i,2]
  next
  asort(au,,,{|x,y| iif(x[1]==y[1], fsort_usl(x[2]) < fsort_usl(y[2]), x[1] < y[1]) } )
  ku := len(au)
  for k := 1 to max(kfio,kpolis,ku)
    if verify_FF(HH,.t.,sh)
      aeval(arr2title, {|x| add_string(x) } )
    endif
    if k == 1
      s := padr(lstr(++j)+". ",4)
    else
      s := space(4)
    endif
    if k <= kfio
      s += padr(afio[k],lfio)+" "
    else
      s += space(lfio+1)
    endif
    if k <= kpolis
      s += padc(alltrim(apolis[k]),17)+" "
    else
      s += space(17+1)
    endif
    if k <= ku
      s += date_8(au[k,1])+" "+;
           au[k,2]+" "+;
           au[k,3]+" "+;
           au[k,4]+;
           str(au[k,6]/au[k,5],8,2)+;
           str(au[k,5],5)+;
           str(au[k,6],11,2)
      lsk += au[k,5]
      lss += au[k,6]
    endif
    add_string(s)
  next
  sk += lsk
  ss += lss
  so += lso
  add_string(padl(replicate("-",sh-24),sh))
  add_string(space(24)+;
             padc(lstr(lso,11,2),17)+;
             space(99)+;
             str(lsk,6)+str(lss,11,2))
  add_string("")
  select TMP
  skip
enddo
ho->(dbCloseArea())
hp->(dbCloseArea())
hpu->(dbCloseArea())
usl->(dbCloseArea())
otd->(dbCloseArea())
if verify_FF(HH-5,.t.,sh)
  aeval(arr2title, {|x| add_string(x) } )
endif
add_string(replicate("─",sh))
add_string(padl("Итого : ",24)+;
           padc(lstr(so,11,2),17)+;
           space(99)+;
           str(sk,6)+str(ss,11,2))
add_string("")
add_string("")
add_string(center("Главный бухгалтер _________________",sh))
fclose(fp)
rest_box(buf)
Private yes_albom := .t.
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*
* 19.07.14
*****
Function Oo_proverka(k)
Static si1 := 1, si2 := 1, si3 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~Сравнение оплаты и услуг","Врачи+техники"}
    mas_msg := {"Сравнение суммы оплаты и услуг по типу оплаты",;
                "Сравнение врачей и техников в услугах наряда "}
    mas_fun := {"Oo_proverka(11)","Oo_proverka(12)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    Oo_1_proverka()
  case k == 12
    Oo_2_proverka()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

*

***** Сравнение суммы оплаты и услуг по типу оплаты
Function Oo_1_proverka()
Local arr, arr_title, reg_print := 1, sh := 60, HH := 58, s, ;
      begin_date, end_date, fl_exit := .f., name_file := "orto_pro"+stxt,;
      mperso, i, j := 0, k, buf := save_row(maxrow())
if (arr := year_month()) == NIL
  return NIL
endif
begin_date := arr[5]
end_date := arr[6]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Сравнение сумм оплаты и сумм услуг по типу оплаты",sh))
add_string(center(arr[4],sh))
//
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_oro",dir_server+"hum_oro","HO")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
set relation to kod_k into KART
dbseek(dtos(begin_date),.t.)
do while human->k_data <= end_date .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  su0 := su2 := su3 := so0 := so2 := so3 := 0
  select HU
  find (str(human->(recno()),7))
  do while hu->kod == human->(recno()) .and. !eof()
    do case
      case hu->tip_usl == OU_PLAT     // 0 платный больной
        su0 += hu->stoim
      case hu->tip_usl == OU_PR_VZ    // 2 взаимозачет
        su2 += hu->stoim
      case hu->tip_usl == OU_D_SMO    // 3 добровольное страхование
        su3 += hu->stoim
    endcase
    skip
  enddo
  select HO
  find (str(human->(recno()),7))
  do while ho->kod == human->(recno()) .and. !eof()
    do case
      case ho->tip_usl == OU_PLAT     // 0 платный больной
        so0 += ho->cena_opl
      case ho->tip_usl == OU_PR_VZ    // 2 взаимозачет
        so2 += ho->cena_opl
      case ho->tip_usl == OU_D_SMO    // 3 добровольное страхование
        so3 += ho->cena_opl
    endcase
    skip
  enddo
  su0 := round_5(su0,2)
  su2 := round_5(su2,2)
  su3 := round_5(su3,2)
  so0 := round_5(so0,2)
  so2 := round_5(so2,2)
  so3 := round_5(so3,2)
  if !(su0==so0 .and. su2==so2 .and. su3==so3)
    ++j
    verify_FF(HH-4,.t.,sh)
    add_string("")
    add_string("Наряд заказ N "+padr(lstr(human->nar_z),5)+" "+;
               date_8(human->n_data)+"-"+date_8(human->k_data))
    add_string(" "+alltrim(kart->fio))
    if !(su0==so0)
      verify_FF(HH,.t.,sh)
      add_string("  платные: услуги="+lstr(su0,9,2)+", оплата="+lstr(so0,9,2))
    endif
    if !(su2==so2)
      verify_FF(HH,.t.,sh)
      add_string("  в/зачет: услуги="+lstr(su2,9,2)+", оплата="+lstr(so2,9,2))
    endif
    if !(su3==so3)
      verify_FF(HH,.t.,sh)
      add_string("  ДМС    : услуги="+lstr(su3,9,2)+", оплата="+lstr(so3,9,2))
    endif
  endif
  select HUMAN
  skip
enddo
close databases
if j > 0 .and. fl_exit
  add_string(replicate("*",sh))
  add_string(expand("ПРОЦЕСС ПРЕРВАН"))
endif
rest_box(buf)
fclose(fp)
if j == 0
  stat_msg("Расхождений не найдено!") ; mybell(2,OK)
else
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL

*

// 16.04.15
***** Сравнение суммы оплаты и услуг по типу оплаты
Function Oo_2_proverka()
Local arr, arr_title, reg_print := 1, sh := 60, HH := 58, s, ;
      begin_date, end_date, fl_exit := .f., name_file := "orto_pro"+stxt,;
      mperso, i, j := 0, k, buf := save_row(maxrow()), flag_VR
if (arr := year_month()) == NIL
  return NIL
endif
begin_date := arr[5]
end_date := arr[6]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
Private flag_1 := .t., arr_uva := {}, vr_uva := .T., as_uva := .T., ms_uva := .T.,;
mshifr := space(10)
R_Use(dir_server+"orto_uva",,"OU")
dbeval({|| aadd(arr_uva, {alltrim(ou->shifr),ou->kod_vr,ou->kod_as,ou->kod_ms} ) } )
ou->(dbCloseArea())
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Сравнение врачей и техников в наряде и услугах",sh))
add_string(center(arr[4],sh))
//
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"mo_pers",,"PERS")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"hum_oro",dir_server+"hum_oro","HO")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
set relation to kod_k into KART
dbseek(dtos(begin_date),.t.)
do while human->k_data <= end_date .and. !eof()
  flag_vr := .F.
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  mm_vr  := human->kod_vr
  mm_teh := human->kod_as
  select HU
  find (str(human->(recno()),7))
  do while hu->kod == human->(recno()) .and. !eof()
    vr_uva := .T.
    as_uva := .T.
    ms_uva := .T.
    select USL
    goto (hu->u_kod)
    mshifr := usl->shifr
    verify_o_uva()
    select HU
    if vr_uva
      if hu->kod_vr != human->kod_vr
        flag_vr := .T.
      endif
    endif
    if as_uva
      if hu->kod_as != human->kod_as
        flag_vr := .T.
      endif
    endif
    if !ms_uva
      if !empty(hu->kod_ms)
        flag_vr := .T.
      endif
    else
      if empty(hu->kod_ms)
        flag_vr := .T.
      endif
    endif
    skip
  enddo
  if flag_vr
    ++j
    verify_FF(HH-4,.t.,sh)
    add_string("")
    add_string("Наряд заказ N "+padr(lstr(human->nar_z),5)+" "+;
               date_8(human->n_data)+"-"+date_8(human->k_data))
    add_string(" "+alltrim(kart->fio))
    verify_FF(HH,.t.,sh)
    select PERS
    goto human->kod_vr
    add_string("Врач в наряде   "+pers->fio)
    verify_FF(HH,.t.,sh)
    goto human->kod_as
    add_string("Техник в наряде "+pers->fio)
    select HU
    find (str(human->(recno()),7))
    do while hu->kod == human->(recno()) .and. !eof()
      verify_FF(HH,.t.,sh)
      select USL
      goto hu->u_kod
      add_string("Услуга "+alltrim(usl->shifr)+" "+usl->name)
      select PERS
      goto hu->kod_vr
      add_string("   Врач в услуге   "+pers->fio)
      verify_FF(HH,.t.,sh)
      goto hu->kod_as
      add_string("   Техник в услуге "+pers->fio)
      verify_FF(HH,.t.,sh)
      goto hu->kod_ms
      add_string("   Медсестра в наряде "+pers->fio)
      select HU
      skip
    enddo
  endif
  select HUMAN
  skip
enddo
close databases
if j > 0 .and. fl_exit
  add_string(replicate("*",sh))
  add_string(expand("ПРОЦЕСС ПРЕРВАН"))
endif
rest_box(buf)
fclose(fp)
if j == 0
  stat_msg("Расхождений не найдено!") ; mybell(2,OK)
else
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL

*

*****
Function Ort_den_sr(par)
Local arr, arr_title, reg_print, sh, HH := 77, buf, s, s1, s2, fl, j,;
      begin_date, end_date, fl_exit := .f., name_file := "orto_den"+stxt,;
      mperso, i, k, muslovie := ".t.", s3, s4, s5
if (pr_pl_bes := O_ret_pl_b()) == 0
  return NIL
endif
if (arr := year_month()) == NIL
  return NIL
endif
begin_date := arr[5]
end_date := arr[6]
buf := save_row(maxrow())
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
dbcreate(cur_dir+"tmp", {;
   {"KOD_H",      "N",      7,      0},;  // код по БД hum_ort
   {"DATA",       "D",      8,      0},;  // дата наряда
   {"N_NAR",      "N",      5,      0},;  // номер наряда
   {"STOIM",      "N",     12,      2},;   // сумма оплаты
   {"STOIM_P",    "N",     12,      2},;  // сумма оплаты платно
   {"STOIM_B",    "N",     12,      2},;  // сумма оплаты бесплатно
   {"STOIM_N",    "N",     12,      2};   // сумма оплаты напыление
  })
use (cur_dir+"tmp") new
do case
  case pr_pl_bes == 1  // платные
    muslovie := "human->tip_usl != 1"
  case pr_pl_bes == 2  // бесплатные
    muslovie := "human->tip_usl == 1"
endcase
do case
  case par == 1
    R_Use(dir_server+"hum_oro",dir_server+"hum_oro","HO")
    R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
    dbseek(dtos(begin_date),.t.)
    do while human->k_data <= end_date .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if &muslovie
        s1 := 0 ; s3 := 0 ; s4 := 0 ; s5 := 0
        select HO
        find (str(human->(recno()),7))
        do while ho->kod == human->(recno()) .and. !eof()
          s1 += ho->cena_opl
          if pr_pl_bes == 1  // платные
            if ho->tip_opl == 2
              s5 += ho->cena_opl // напыление
            else
              s4 += ho->cena_opl // платно
            endif
          elseif pr_pl_bes == 2 .or. pr_pl_bes == 3 // бесплатные
            if emptyall(ho->n_kvit,ho->kv_cia)
              s3 += ho->cena_opl  // бесплатно
            else
              if ho->tip_opl == 2
                s5 += ho->cena_opl  // напыление
              else
                s4 += ho->cena_opl  // платно
              endif
            endif
          endif
          skip
        enddo
        s1 := round(s1,2)
        if !empty(s1)
          select TMP
          append blank
          tmp->KOD_H := human->(recno())
          tmp->N_NAR := human->nar_z
          tmp->STOIM := s1
          tmp->STOIM_P := s4
          tmp->STOIM_B := s3
          tmp->STOIM_N := s5
          if tmp->(lastrec()) % 5000 == 0
            Commit
          endif
        endif
      endif
      select HUMAN
      skip
    enddo
  case par == 2
    R_Use(dir_server+"hum_oro",dir_server+"hum_oro","HO")
    R_Use(dir_server+"hum_ort",dir_server+"hum_orto","HUMAN")
    dbseek(dtos(begin_date),.t.)
    do while human->data <= end_date .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if &muslovie .and. iif(is_open, empty(human->k_data), .t.)
        s1 := 0 ; s3 := 0 ; s4 := 0 ; s5 := 0
        select HO
        find (str(human->(recno()),7))
        do while ho->kod == human->(recno()) .and. !eof()
          s1 += ho->cena_opl
          if pr_pl_bes == 1  // платные
            if ho->tip_opl == 2
              s5 += ho->cena_opl // напыление
            else
              s4 += ho->cena_opl // платно
            endif
          elseif pr_pl_bes == 2 .or. pr_pl_bes == 3 // бесплатные
            if emptyall(ho->n_kvit,ho->kv_cia)
              s3 += ho->cena_opl  // бесплатно
            else
              if ho->tip_opl == 2
                s5 += ho->cena_opl  // напыление
              else
                s4 += ho->cena_opl  // платно
              endif
            endif
          endif
          skip
        enddo
        s1 := round(s1,2)
        s3 := round(s3,2)
        s4 := round(s4,2)
        s5 := round(s5,2)
        //if !empty(s1)
          select TMP
          append blank
          tmp->KOD_H := human->(recno())
          tmp->DATA := human->data
          tmp->N_NAR := human->nar_z
          tmp->STOIM := s1
          tmp->STOIM_P := s3
          tmp->STOIM_B := s4
          tmp->STOIM_N := s5
          if tmp->(lastrec()) % 5000 == 0
            Commit
          endif
        //endif
      endif
      select HUMAN
      skip
    enddo
  case par == 3
    select TMP
    index on str(kod_h,7) to (cur_dir+"tmp")
    R_Use(dir_server+"hum_ort",,"HUMAN")
    R_Use(dir_server+"hum_oro",dir_server+"hum_orod","HO")
    set relation to kod into HUMAN
    dbseek(arr[7],.t.)
    do while ho->pdate <= arr[8] .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if &muslovie .and. iif(is_open, empty(human->k_data), .t.)
        select TMP
        find (str(ho->kod,7))
        if !found()
          append blank
          tmp->KOD_H := human->(recno())
          tmp->N_NAR := human->nar_z
          if tmp->(lastrec()) % 1000 == 0
            Commit
          endif
        endif
        tmp->STOIM += ho->cena_opl
        if pr_pl_bes == 1  // платные
          if ho->tip_opl == 2
            tmp->STOIM_N += ho->cena_opl
          else
            tmp->STOIM_P += ho->cena_opl
          endif
        elseif pr_pl_bes == 2  .or. pr_pl_bes == 3// бесплатные
          if emptyall(ho->n_kvit,ho->kv_cia)
            tmp->STOIM_B += ho->cena_opl
          else
            if ho->tip_opl == 2
              tmp->STOIM_N += ho->cena_opl
            else
              tmp->STOIM_P += ho->cena_opl
            endif
          endif
        endif
      endif
      select HO
      skip
    enddo
endcase
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  return NIL
endif
if j == 0
  return func_error(4,"Нет сведений!")
endif
mywait()
//
arr_title := {;
"─────┬───────────────────────────────────────────┬────┬─────┬──────",;
"Наряд│                                           │    │№ кв.│№ кви-",;
"заказ│         Ф.И.О. и адрес больного           │Врач│книж.│танции",;
"─────┴───────────────────────────────────────────┴────┴─────┴──────"}

if pr_pl_bes == 1  // платные
  arr_title[1] += "┬─────────┬─────────"
  arr_title[2] += "│  Сумма  │  Сумма  "
  arr_title[3] += "│ протез. │напыления"
  arr_title[4] += "┴─────────┴─────────"
elseif pr_pl_bes == 2 .or. pr_pl_bes == 3// бесплатные
  arr_title[1] += "┬─────────┬─────────┬─────────"
  arr_title[2] += "│  Сумма  │  Сумма  │  Сумма  "
  arr_title[3] += "│ч/з кассу│   РЗО   │напыления"
  arr_title[4] += "┴─────────┴─────────┴─────────"
endif
arr_title[1] += "┬─────────"
arr_title[2] += "│  Сумма  "
arr_title[3] += "│  оплаты "
arr_title[4] += "┴─────────"
if par == 2
  arr_title[1] += "┬────────"
  arr_title[2] += "│  Дата  "
  arr_title[3] += "│закрытия"
  arr_title[4] += "┴────────"
endif
sh := len(arr_title[1])
//
if pr_pl_bes == 1 .or. pr_pl_bes == 2
  reg_print := 3
else
  reg_print := 6
endif
//
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
do case
  case par == 1
    add_string(center("Реестр поступления денежных средств за протезирование",sh))
    add_string(center(arr[4],sh))
    add_string(center("[ по дате окончания лечения ]",sh))
  case par == 2
    add_string(center("Журнал регистрации нарядов-заказов",sh))
    add_string(center(arr[4],sh))
    add_string(center(iif(is_open,"[ открытые","[ все")+" наряды-заказы ]",sh))
    add_string("")
    add_string(center("по состоянию на "+date_month(sys_date,.t.),sh))
  case par == 3
    add_string(center("Реестр поступления денежных средств за протезирование",sh))
    add_string(center(arr[4],sh))
    add_string(center("[ оплата за конкретный период времени ]",sh))
    add_string(center(iif(is_open,"[ открытые","[ все")+" наряды-заказы ]",sh))
endcase
add_string("")
if pr_pl_bes != 3
  add_string(center(pr_titul,sh))
  add_string("")
endif
aeval(arr_title, {|x| add_string(x) } )
R_Use(dir_server+"mo_pers",,"PERSO")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_oro",dir_server+"hum_oro","HO")
R_Use(dir_server+"hum_ort",,"HUMAN")
set relation to kod_k into KART, to kod_vr into PERSO
use (cur_dir+"tmp") new
if par == 2
  index on dtos(data)+str(n_nar,5) to (cur_dir+"tmp")
else
  index on str(n_nar,5) to (cur_dir+"tmp")
endif
set relation to kod_h into HUMAN
j := s1  := s3 := s4 := s5:= 0 ; old_date := begin_date - 1
go top
do while !eof()
  add_string("")
  if verify_FF(HH-3,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  if par == 2 .and. old_date != tmp->data
    add_string(padr(full_date(tmp->data),12)+"│")
    add_string(                  "────────────┘")
    old_date := tmp->data
  endif
  ++j ; s1 += tmp->stoim ; s3 += tmp->stoim_b ; s4 += tmp->stoim_p
        s5 += tmp->stoim_n
  s := padc(lstr(tmp->n_nar),5)+"  "+;
       padr(alltrim(kart->fio),42,".")+;
       padl(lstr(perso->tab_nom),5,".")
  if pr_pl_bes == 1 // платные
    s += padl(put_val(tmp->stoim_p,10,2,"."),23,".")+;
         padl(put_val(tmp->stoim_n,10,2,"."),10,".")+;
         padl(lput_kop(tmp->stoim),10,".")
  elseif pr_pl_bes == 3 .or. pr_pl_bes == 2 // бесплатные
    s += padl(put_val(tmp->stoim_p,10,2,"."),23,".")+;
         padl(put_val(tmp->stoim_b,10,2,"."),10,".")+;
         padl(put_val(tmp->stoim_n,10,2,"."),10,".")+;
         padl(lput_kop(tmp->stoim),10,".")
  else
    s += padl(lput_kop(tmp->stoim),23,".")
  endif
  add_string(s)
  s := if(pr_pl_bes==3, space(2)+{"П","Б","З","Д"}[human->tip_usl+1], space(3))+;
       space(4)+alltrim(kart->adres)
  if par == 2 .and. !empty(human->k_data)
    s := padr(s,sh-8)+date_8(human->k_data)
  endif
  add_string(s)
  select HO
  find (str(tmp->kod_h,7))
  do while ho->kod == tmp->kod_h
    if iif(par==3, between(ho->pdate,arr[7],arr[8]), .t.)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      s := space(44)+full_date(c4tod(ho->pdate))+;
           str(ho->n_kvit,6)+;
           str(ho->kv_cia,7)
      if pr_pl_bes == 1 // платные
        s += iif(ho->tip_opl == 2,space(10),"")  //сдвиг для напыления
      elseif pr_pl_bes == 2 .or. pr_pl_bes == 3// бесплатные
        if emptyall(ho->n_kvit,ho->kv_cia)
          s += space(10) //сдвиг для бесплатных
        else
          s += iif(ho->tip_opl == 2,space(20),"")  //сдвиг для напыления
        endif
      endif
      add_string(s+put_kope(ho->cena_opl,10))
    endif
    skip
  enddo
  select TMP
  skip
enddo
close databases
if fl_exit
  add_string(replicate("*",sh))
  add_string(expand("ПРОЦЕСС ПРЕРВАН"))
endif
add_string(replicate("─",sh))
s := padr("Кол-во больных - "+lstr(j),25)
if pr_pl_bes == 1 //платные
  s += put_kope(s4,sh-iif(par==2,54,45)) + put_kope(s5,10) + put_kope(s1,10)
elseif pr_pl_bes == 2 .or. pr_pl_bes == 3//бесплатные
  s += put_kope(s4,sh-iif(par==2,64,55)) + put_kope(s3,10) +;
       put_kope(s5,10) + put_kope(s1,10)
else
  s += put_kope(s1,sh-iif(par==2,34,25))
endif
add_string(s)
fclose(fp)
close databases
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

***** 19.07.14
Function Oo_statist(k)
Static si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 1, si6 := 1, ;
       si7 := 1, si8 := 1, si9 := 1, si10 := 1, si11 := 1, si12 := 1
Local mas_pmt, mas_msg, mas_fun, j, mdate, arr_gr
Local uch_otd
DEFAULT k TO 1
do case
  case k == 1
    uch_otd := saveuchotd()
    Private p_net_otd := .t., pr_pl_bes := 0, pr_titul, is_open
    mas_pmt := {"~Открытые наряды-заказы",;
                "~Закрытые наряды-заказы",;
                "~Все наряды-заказы",;
                "~Многовариантный поиск",;
                "~ДМС и взаимозачет"}
    mas_msg := {"Статистика по открытым (еще не закрытым) нарядам-заказам",;
                "Статистика по закрытым нарядам-заказам",;
                "Статистика по всем (открытым и закрытым) нарядам-заказам",;
                "Получение сводной информации (многовариантный поиск)",;
                "Получение информации по ДМС и взаимозачету"}
    mas_fun := {"Oo_statist(11)",;
                "Oo_statist(12)",;
                "Oo_statist(13)",;
                "Oo_statist(14)",;
                "Oo_statist(15)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
    restuchotd(uch_otd)
*****************
  case eq_any(k,11,13)
    is_open := (k == 11)
    mas_pmt := {"Объем ~работ",;
                "Объем работ по ~врачам",;
                "Объем работ по ~больным",;
                "Поступление ~денежных средств"}
    mas_msg := {"Статистика по объему работ персонала",;
                "Статистика по лечащим врачам",;
                "Статистика по пролеченным больным [+ по лечащим врачам]",;
                "Статистика по поступлению денежных средств"}
    mas_fun := {"Oo_statist(131)",;    // 06.10.23
                "Oo_statist(21)",;
                "Oo_statist(22)",;
                "Oo_statist(23)"}
    if k == 11
      aadd(mas_pmt, "Не~закрытые наряды-заказы")
      aadd(mas_msg, "Общий список не закрытых нарядов-заказов")
      aadd(mas_fun, "Oo_statist(24)")
      //if glob_or_pol == 1
        aadd(mas_pmt, "~Долги по оплате")
        aadd(mas_msg, "Долги по оплате")
        aadd(mas_fun, "Oo_statist(25)")
      //endif
      aadd(mas_pmt, "~Расход материалов")
      aadd(mas_msg, "Ведомость по расходу материалов на протезирование")
      aadd(mas_fun, "Oo_statist(39)")     //05.03.13
      //
      aadd(mas_pmt, "~Журнал Регистрации")
      aadd(mas_msg, "Журнал регистрации договоров")
      aadd(mas_fun, "Oo_statist(26)")
      //
      aadd(mas_pmt, "~Настраиваемый журнал Регистрации")
      aadd(mas_msg, "Настраиваемый журнал Регистрации")
      aadd(mas_fun, "Oo_statist(27)")
    endif
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 12
    is_open := .f.
    mas_pmt := {"Объем ~работ",;
                "Статистика по ~больным",;
                "Статистика по ~диагнозам",;
                "О~плата",;
                "~Оборотная ведомость",;
                "Форма ~39 по ортопедии",;
                "~Расход материалов",;
                "Поломки про~тезов",;
                "~Журнал Регистрации",;
                "~Настраиваемый журнал Регистрации",;
                "Журнал ~Закрытых нарядов"}     //  24.06.08
    mas_msg := {"Статистика по объему работ персонала",;
                "Статистика по больным",;
                "Статистика по диагнозам",;
                "Статистика по оплате",;
                "Оборотная ведомость по оплате нарядов-заказов",;
                "Статистистическая форма 39 по ортопедии",;
                "Ведомость по расходу материалов на протезирование",;
                "Статистика по поломкам протезов",;
                "Журнал регистрации договоров",;
                "Настраиваемый журнал Регистрации",;
                "Журнал Закрытых нарядов"}      //  24.06.08
    mas_fun := {"Oo_statist(31)",;
                "Oo_statist(32)",;
                "Oo_statist(33)",;
                "Oo_statist(34)",;
                "Oo_statist(35)",;
                "Oo_statist(36)",;
                "Oo_statist(37)",;
                "Oo_statist(38)",;
                "Oo_statist(26)",;
                "Oo_statist(27)",;
                "Oo_statist(28)"} //  24.06.08
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)
  case k == 14
    Ort_mnog_poisk()
  case k == 15
    mas_pmt := {"~Реестр по ДМС"}
    mas_msg := {"Распечатка реестра по ДМС"}
    mas_fun := {"Oo_statist(101)"}
    popup_prompt(T_ROW,T_COL-5,si10,mas_pmt,mas_msg,mas_fun)
*****************
  case k == 21
    Ort_otkr_nar(1,2)
  case k == 22
    Ort_otkr_nar(1,1)
  case k == 23
    mas_pmt := {"По дате ~открытия наряда",;
                "За ~период времени"}
    mas_msg := {"Журнал регистрации нарядов-заказов [по дате открытия наряда]",;
                "Реестр поступления денежных средств за конкретный период времени"}
    mas_fun := {"Ort_den_sr(2)",;
                "Ort_den_sr(3)"}
    popup_prompt(T_ROW,T_COL-5,2,mas_pmt,mas_msg,mas_fun)
  case k == 24
    Ort_otkr_nar(2)
  case k == 25
    Ort_dolgi(2)
  case k == 26
    pl_ordogovor()  //  16.06.08
  case k == 27
    pl_or2dogovor(1) //  24.06.08
  case k == 28
    pl_or2dogovor(2) //  24.06.08
 
*****************
  case k == 31
    Private ptip_date := 1 // закрытые наряды - по умолчанию
    mas_pmt := {"По ~персоналу",;
                "По ~услугам"}
    mas_msg := {"Статистика по объему работ персонала",;
                "Статистика по оказанным услугам"}
    mas_fun := {"Oo_statist(41)",;
                "Oo_statist(42)"}
    popup_prompt(T_ROW,T_COL-5,si4,mas_pmt,mas_msg,mas_fun)
  case k == 32
    mas_pmt := {"Список ~больных",;
                "~Леч.врач + больные",;
                "~Зуб.техник + больные"}
    mas_msg := {"Статистика по пролеченным больным",;
                "Статистика по пролеченным больным [по лечащим врачам]",;
                "Статистика по пролеченным больным [по зубным техникам]"}
    mas_fun := {"Oo_statist(51)",;
                "Oo_statist(52)",;
                "Oo_statist(53)"}
    popup_prompt(T_ROW,T_COL-5,si5,mas_pmt,mas_msg,mas_fun)
  case k == 33
    Ort_diagnoz()
  case k == 34
    mas_pmt := {"~Поступление денежных средств",;
                "~Долги по оплате"}
    mas_msg := {"Реестр поступления денежных средств за протезирование",;
                "Долги по оплате"}
    mas_fun := {"Oo_statist(61)",;
                "Oo_statist(62)"}
    popup_prompt(T_ROW,T_COL-5,si6,mas_pmt,mas_msg,mas_fun)
  case k == 35
    Ort_oborot()
  case k == 36
    mas_pmt := {"Форма 39 по ~организации",;
                "Форма 39 по ~врачу",;
                "~Настройка формы 39",;
                "Печать настройки"}
    mas_msg := {"Распечатка формы 39 в целом по организации",;
                "Распечатка формы 39 по врачу",;
                "Настройка для составления формы 39",;
                "Печать настройки для составления формы 39"}
    mas_fun := {"Oo_statist(121)",;
                "Oo_statist(122)",;
                "Oo_statist(123)",;
                "Oo_statist(124)"}
    Private lp := array(65)
    popup_prompt(T_ROW-len(mas_pmt)-3,T_COL-5,si12,mas_pmt,mas_msg,mas_fun)
  case k == 37
    Ort_material(1) // 05.03.13
  case k == 38
    mas_pmt := {"~Причины поломок протезов",;
                "~Список больных по поломкам"}
    mas_msg := {"Причины поломок протезов",;
                "Список больных по поломкам"}
    mas_fun := {"Oo_statist(111)",;
                "Oo_statist(112)"}
    popup_prompt(T_ROW-len(mas_pmt)-3,T_COL-5,si11,mas_pmt,mas_msg,mas_fun)
  case k == 39      // 05.03.13
    Ort_material(2)
*****************
  case k == 41
    mas_pmt := {"По ~врачам",;
                "По ~зубным техникам",;
                "По ~медсестрам"}
    mas_msg := {"врачи",;
                "зуб.техники",;
                "медсестры"}
    aeval(mas_msg, {|x,i| mas_msg[i] := "Статистика по персоналу ["+x+"]" })
    mas_fun := {"Oo_statist(71)",;
                "Oo_statist(72)",;
                "Oo_statist(73)"}
    popup_prompt(T_ROW,T_COL-5,si7,mas_pmt,mas_msg,mas_fun)
  case k == 42
    mas_pmt := {"Список ~услуг",;
                "~Врачи + услуги",;
                "~Зуб.техники + услуги",;
                "~Медсестры + услуги"}
    mas_msg := {"Статистика по оказанным услугам",;
                "Статистика по услугам + врачи",;
                "Статистика по услугам + зубные техники",;
                "Статистика по услугам + медсестры"}
    mas_fun := {"Oo_statist(81)",;
                "Oo_statist(82)",;
                "Oo_statist(83)",;
                "Oo_statist(84)"}
    popup_prompt(T_ROW,T_COL-5,si8,mas_pmt,mas_msg,mas_fun)
*****************
  case k == 51
    Ort_boln()
  case k == 52
    Ort_boln("vr")
  case k == 53
    Ort_boln("tehn")
*****************
  case k == 61
    Ort_den_sr(1)
  case k == 62
    Ort_dolgi(1)
*****************
  case between(k,71,73)
    Private ptip_pers := {"vr","tehn","meds"}[k-70]
    mas_pmt := {"Персонал + ~больные (сокр.)",;
                "Персонал + больные (полна~я)",;
                "~Персонал",;
                "Персонал + суммы ~услуг"}
    mas_msg := {"персонал + больные (сокр.форма)",;
                "персонал + больные (полная форма)",;
                "персонал",;
                "персонал + суммы услуг"}
    aeval(mas_msg, {|x,i| mas_msg[i] := "Статистика по персоналу ["+x+"]" })
    mas_fun := {"Oo_statist(91)",;
                "Oo_statist(92)",;
                "Oo_statist(93)",;
                "Oo_statist(94)"}
    if eq_any(k,71,72)  // врачи или техники
      aadd(mas_pmt, "~Ведомость наработки")
      aadd(mas_msg, "Ведомость наработки персонала за период времени")
      aadd(mas_fun, "Oo_statist(95)")
      //if k == 71   19.07.14
        aadd(mas_pmt, "Персонал + количество ~нарядов")
        aadd(mas_msg, "Подсчёт количества закрытых нарядов-заказов по врачам за период")
        aadd(mas_fun, "Oo_statist(96)")
      //endif
    endif
    popup_prompt(T_ROW,T_COL-5,si9,mas_pmt,mas_msg,mas_fun)
*****************
  case k == 81
    Oob_statist("usl")
  case k == 82
    Oob_statist("pers","vr","usl")
  case k == 83
    Oob_statist("pers","tehn","usl")
  case k == 84
    Oob_statist("pers","meds","usl")
*****************
  case k == 91
    Oob_statist("pers",ptip_pers,"boln")
  case k == 92
    Oob1_statist(ptip_pers)   // "pers","boln"
  case k == 93
    Oob_statist("pers",ptip_pers)
  case k == 94
    Oob_statist("pers",ptip_pers,"summa")
  case k == 95
    O_ved_narabot()
  case k == 96
    O_vr_kol_nar()
  case k == 101
    O_dms_reestr()
  case k == 111
    O_pr_polom()
  case k == 112
    O_sb_pr_polom()
  case k == 121
    forma_30all(3)
  case k == 122
    forma_30all(1)
  case k == 123
    forma_30_na(1)
  case k == 124
    forma_30_na(2)
    *****************
  case k == 131
      Private ptip_date := 2 //не закрытые наряды
      mas_pmt := {"По ~персоналу",;
                  "По ~услугам"}
      mas_msg := {"Предварительная Статистика по объему работ персонала",;
                  "Предварительная Статистика по оказанным услугам"}
      mas_fun := {"Oo_statist(132)",;
                  "Oo_statist(133)"}
      popup_prompt(T_ROW,T_COL-5,si7,mas_pmt,mas_msg,mas_fun)
  case k == 132
    mas_pmt := {"По ~врачам",;
                "По ~зубным техникам",;
                "По ~медсестрам"}
    mas_msg := {"врачи",;
                "зуб.техники",;
                "медсестры"}
    aeval(mas_msg, {|x,i| mas_msg[i] := "Статистика по персоналу ["+x+"]" })
    mas_fun := {"Oo_statist(71)",;
                "Oo_statist(72)",;
                "Oo_statist(73)"}
    popup_prompt(T_ROW,T_COL-5,si7,mas_pmt,mas_msg,mas_fun)
  case k == 133
    mas_pmt := {"Список ~услуг",;
                "~Врачи + услуги",;
                "~Зуб.техники + услуги",;
                "~Медсестры + услуги"}
    mas_msg := {"Статистика по оказанным услугам",;
                "Статистика по услугам + врачи",;
                "Статистика по услугам + зубные техники",;
                "Статистика по услугам + медсестры"}
    mas_fun := {"Oo_statist(81)",;
                "Oo_statist(82)",;
                "Oo_statist(83)",;
                "Oo_statist(84)"}
    popup_prompt(T_ROW,T_COL-5,si8,mas_pmt,mas_msg,mas_fun)
*****************
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29) .or. k == 131
    si2 := j
  elseif between(k,31,39)
    si3 := j
  elseif between(k,41,49)
    si4 := j
  elseif between(k,51,59)
    si5 := j
  elseif between(k,61,69)
    si6 := j
  elseif between(k,71,79)
    si7 := j
  elseif between(k,91,99)
    si8 := j
  elseif between(k,91,99)
    si9 := j
  elseif between(k,101,109)
    si10 := j
  elseif between(k,111,119)
    si11 := j
  elseif between(k,121,129)
    si12 := j
  elseif between(k,131,139)
    si13 := j
  endif
endif
return NIL

*

*****
Function Oob_statist(par1,par2,par3)
Local arr, arr_title, reg_print := 2, sh, HH := 58, s, s1, s2, s3, fl,;
      begin_date, end_date, fl_exit := .f., name_file := "orto_st"+stxt,;
      tip_tit, s4, parametr4 := 1 // по умолчанию 
Local reg, reg1, mperso, musluga, mkod, buf := save_row(maxrow())
Local msl1usluga, msl2usluga, l_delen, mslusluga
DEFAULT par1 TO "", par2 TO "", par3 TO ""
parametr4 := ptip_date // по дате окончания или без оной
if !(par3 == "summa") .and. (pr_pl_bes := O_ret_pl_b()) == 0
  return NIL
endif
if (arr := year_month()) == NIL
  return NIL
endif
do case
  case par1 == "pers"
    reg := 1 ; reg1 := if(par2 == "vr", 1, if(par2 == "tehn", 2, 3))
    if (mperso := input_kperso()) == NIL  // ==> весь персонал
      mywait()
      mperso := {}
      R_Use(dir_server+"mo_pers",,"PERSO")
      go top
      do while !eof()
        if perso->kod > 0
          aadd(mperso, {perso->kod,""} )
        endif
        skip
      enddo
      perso->(dbCloseArea())
    endif
  case par1 == "usl"
    reg := 2
    if (musluga := input_value(18,9,20,70,color1,;
        "Введите шаблон для поиска необходимых услуг",;
        padr("*",10))) == NIL
      return NIL
    endif
    musluga := alltrim(musluga)
endcase
begin_date := arr[5]
end_date := arr[6]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
if par3 == "summa"
  pr_pl_bes := 0
  mslusluga := alltrim(mem_ort_sl)
  l_delen := at(",",mem_ort_sl)
  if empty(mslusluga) .or. mslusluga == "*"
    msl1usluga := "9999999999"
    msl2usluga := "9999999999"
  else
    msl1usluga := alltrim(substr(mslusluga,1,l_delen-1))
    msl2usluga := alltrim(substr(mslusluga,l_delen+1,40))
  endif
  musluga := alltrim(mem_ort_na)
  if empty(musluga) .or. musluga == "*"
    musluga := "9999999999"
  endif
  dbcreate(cur_dir+"tmp", {;
     {"KOD",        "N",      4,      0},;  // код персонала (услуги)
     {"FIO",        "C",     50,      0},;  // Ф.И.О. (шифр услуги)
     {"KOL",        "N",     10,      3},;  // кол-во услуг
     {"TRUDOEM",    "N",     11,      4},;  // трудоемкость услуг УЕТ
     {"STOIM_P",    "N",     14,      2},;  // стоимость пл.услуг
     {"STOIM_B",    "N",     14,      2},;  // стоимость беспл.услуг
     {"STOIM_N",    "N",     14,      2},;  // стоимость напыления
     {"STOIM_S",    "N",     14,      2},;  // стоимость слепков
     {"STOIM",      "N",     14,      2} ;  // общая стоимость
    })
else
  dbcreate(cur_dir+"tmp", {;
     {"KOD",        "N",      4,      0},;  // код персонала (услуги)
     {"FIO",        "C",     50,      0},;  // Ф.И.О. (шифр услуги)
     {"KOL",        "N",     10,      3},;  // кол-во услуг
     {"TRUDOEM",    "N",     11,      4},;  // трудоемкость услуг УЕТ
     {"STOIM",      "N",     14,      2} ;  // стоимость лечения
    })
  if !empty(par3)
    dbcreate(cur_dir+"tmp1", {;
       {"KOD",        "N",      4,      0},;  // код персонала
       {"KOD_H",      "N",      7,      0},;  // код больного по картотеке
       {"KOL",        "N",     10,      3},;  // кол-во услуг
       {"TRUDOEM",    "N",     11,      4},;  // трудоемкость услуг УЕТ
       {"STOIM",      "N",     14,      2} ;  // стоимость лечения
      })
    use (cur_dir+"tmp1") new
    index on str(kod,4)+str(kod_h,7) to (cur_dir+"tmp1")
  endif
endif
use (cur_dir+"tmp") new
index on str(kod,4) to (cur_dir+"tmp")
if mem_trudoem == 2
  useUch_Usl()
endif
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"mo_pers",,"PERSO")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
if reg == 2 .or. par3 == "summa"
  set relation to u_kod into USL
endif
R_Use(dir_server+"kartotek",,"KART")
if parametr4 == 1
  R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
  dbseek(dtos(begin_date),.t.)
else
  R_Use(dir_server+"hum_ort",dir_server+"hum_orto","HUMAN")
  dbseek(dtos(begin_date),.t.)
endif   
do while iif(parametr4 == 1,human->k_data,human->data) <= end_date .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  select HU
  find (str(human->(recno()),7))
  do while hu->kod == human->(recno()) .and. !eof()
    fl := .f.
    if reg == 1
      do case
        case reg1 == 1
          mkod := hu->kod_vr
        case reg1 == 2
          mkod := hu->kod_as
        case reg1 == 3
          mkod := hu->kod_ms
      endcase
      if (fl := (mkod > 0 .and. ascan(mperso,{|x| x[1]==mkod }) > 0))
        select PERSO
        goto (mkod)
      endif
    else
      if (fl := like(musluga,usl->shifr))
        mkod := hu->u_kod
      endif
    endif
    if fl
      if pr_pl_bes == 1  // платные
        fl := (hu->tip_usl != OU_B_PLAT)
      elseif pr_pl_bes == 2  // бесплатные
        fl := (hu->tip_usl == OU_B_PLAT)
      endif
      if fl
        mtrud := 0
        if mem_trudoem == 2
          kart->(dbGoto(human->kod_k))
          mtrud := round_5(hu->kol * opr_uet(kart->vzros_reb), 4)
        endif
        select TMP
        find (str(mkod,4))
        if !found()
          append blank
          tmp->kod := mkod
          if reg == 1
            tmp->fio := perso->fio
          else
            tmp->fio := usl->shifr
          endif
        endif
        if reg == 2 .or. par3 == "usl"
          tmp->kol += hu->kol
          tmp->trudoem += mtrud
        endif
        tmp->stoim += hu->stoim
        if par3 == "boln"
          select TMP1
          find (str(mkod,4)+str(human->kod_k,7))
          if !found()
            append blank
            tmp1->kod := mkod
            tmp1->kod_h := human->kod_k
          endif
          tmp1->stoim += hu->stoim
        elseif par3 == "usl"
          select TMP1
          find (str(mkod,4)+str(hu->u_kod,7))
          if !found()
            append blank
            tmp1->kod := mkod
            tmp1->kod_h := hu->u_kod
          endif
          tmp1->kol += hu->kol
          tmp1->trudoem += mtrud
          tmp1->stoim += hu->stoim
        elseif par3 == "summa"
          s := s1 := s2 := s3 := s4 := 0
          if hu->tip_usl != OU_B_PLAT  // платные
            if like(musluga,usl->shifr)
              s := hu->stoim  // напыление
            else
              s1 := hu->stoim
            endif
            if like(msl2usluga,usl->shifr).or.like(msl1usluga,usl->shifr)
              s3 := hu->stoim  // слепки
            endif
          else
            s2 := hu->stoim
          endif
          tmp->stoim_p += s1
          tmp->stoim_b += s2
          tmp->stoim_n += s
          tmp->stoim_s += s3
        endif
      endif
    endif
    select HU
    skip
  enddo
  select HUMAN
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  return NIL
endif
if j == 0
  return func_error(4,"Нет сведений!")
endif
mywait()
//
len_n := 60
if mem_trudoem == 2
  len_n := 51
endif
tip_tit := if(reg == 1, 1, 2)
if par3 == "usl"
  tip_tit := 2
elseif par3 == "summa"
  tip_tit := 3
endif
if tip_tit == 1
  if empty(par3)  // общий список
    len_n := 50
    arr_title := {;
    "──────────────────────────────────────────────────┬─────────────",;
    "                     Ф.И.О.                       │Сумма лечения",;
    "──────────────────────────────────────────────────┴─────────────"}
  else
    len_n := 54
    arr_title := {;
    "──────────────────────────────────────────────────────┬─────────────",;
    "                Ф.И.О. и адрес больного               │Сумма лечения",;
    "──────────────────────────────────────────────────────┴─────────────"}
  endif
elseif tip_tit == 2
  arr_title := array(4)
  arr_title[1] := replicate("─",len_n)
  arr_title[2] := space(len_n)
  arr_title[3] := padc("Наименование услуг",len_n)
  arr_title[4] := replicate("─",len_n)
  arr_title[1] += "┬─────"
  arr_title[2] += "│ Кол."
  arr_title[3] += "│услуг"
  arr_title[4] += "┴─────"
  if mem_trudoem == 2
    arr_title[1] += "┬────────"
    arr_title[2] += "│        "
    arr_title[3] += "│ У.Е.Т. "
    arr_title[4] += "┴────────"
  endif
  arr_title[1] += "┬─────────────"
  arr_title[2] += "│             "
  arr_title[3] += "│Сумма лечения"
  arr_title[4] += "┴─────────────"
else
  arr_title := {;
  "────────────────────────────────╥───────────┬───────────┬───────────┬───────────╥───────────",;
  "              Ф.И.О.            ║  Платные  │ Бесплатные│  Слепки   │ Напыление ║   Всего   ",;
  "────────────────────────────────╨───────────┴───────────┴───────────┴───────────╨───────────"}
endif
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Объем работ",sh))
add_string(center(arr[4],sh))
if !(par3 == "summa")
  add_string(center(pr_titul,sh))
endif
R_Use(dir_server+"mo_pers",,"PERSO")
use (cur_dir+"tmp") new
if reg == 1
  index on upper(fio) to (cur_dir+"tmp")
  add_string(center({"[ По врачам ]",;
                     "[ По зубным техникам ]",;
                     "[ По медсестрам ]"}[reg1],sh))
  if par3 == "boln"
    R_Use(dir_server+"kartotek",,"KART")
    use (cur_dir+"tmp1") new
    set relation to kod_h into KART
    index on str(kod,4)+upper(left(kart->fio,20)) to (cur_dir+"tmp1")
    select TMP
  elseif par3 == "usl"
    R_Use(dir_server+"uslugi",,"USL")
    use (cur_dir+"tmp1") new
    set relation to kod_h into USL
    index on str(kod,4)+fsort_usl(usl->shifr) to (cur_dir+"tmp1")
    select TMP
  endif
else
  index on fsort_usl(left(fio,10)) to (cur_dir+"tmp")
  R_Use(dir_server+"uslugi",,"USL")
  select TMP
  set relation to kod into USL
  if !(musluga == "*")
    add_string(center("Услуги: "+musluga,sh))
  endif
endif
add_string("")
aeval(arr_title, {|x| add_string(x) } )
s := s1 := s2 := s3 := s4 := 0
go top
do while !eof()
  if par3 == "summa"
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    perso->(dbGoto(tmp->kod))
    add_string(padr(fam_i_o(tmp->fio)+"  ["+lstr(perso->tab_nom)+"]",32)+;
               put_kopE(tmp->stoim_p,12)+;
               put_kopE(tmp->stoim_b,12)+;
               put_kopE(tmp->stoim_s,12)+;
               put_kopE(tmp->stoim_n,12)+;
               put_kopE(tmp->stoim,12))
    s1 += tmp->stoim_p
    s2 += tmp->stoim_b
    s3 += tmp->stoim_s
    s  += tmp->stoim_n
  else
    if reg == 1
      j := 1
      if empty(par3)
        s := padr(alltrim(tmp->fio)+"  ["+lstr(tmp->kod)+"]",50)
      else
        s := padr(space(4)+"["+lstr(tmp->kod)+"]  "+upper(tmp->fio),len_n)
        if par3 == "usl"
          s += umest_val(tmp->kol,6,3)
          if mem_trudoem == 2
            s += put_val_0(tmp->trudoem,9,1)
          endif
        endif
      endif
    else
      j := perenos(arr,usl->name,len_n-11)
      s := usl->shifr+" "+padr(arr[1],len_n-11)+umest_val(tmp->kol,6,3)
      if mem_trudoem == 2
        s += put_val_0(tmp->trudoem,9,1)
      endif
    endif
    s += put_kopE(tmp->stoim,14)
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(s)
    for i := 2 to j
      add_string(space(11)+padl(alltrim(arr[i]),len_n-11))
    next
    s1 += tmp->kol
    s2 += tmp->stoim
    s4 += tmp->trudoem
    if reg == 1 .and. !empty(par3)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(space(4)+replicate(".",sh-4))
      j := 0
      select TMP1
      find (str(tmp->kod,4))
      do while tmp1->kod == tmp->kod .and. !eof()
        if verify_FF(HH,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        if par3 == "boln"
          ++j
          add_string(padr(lstr(j)+". "+kart->fio,54)+put_kopE(tmp1->stoim,14))
          add_string(space(len(lstr(j))+3)+kart->adres)
        elseif par3 == "usl"
          j := perenos(arr,usl->name,len_n-11)
          s := usl->shifr+" "+padr(arr[1],len_n-11)+umest_val(tmp1->kol,6,3)+;
               if(mem_trudoem==2,put_val_0(tmp1->trudoem,9,1),"")+;
               put_kopE(tmp1->stoim,14)
          add_string(s)
          for i := 2 to j
            add_string(space(11)+padl(alltrim(arr[i]),len_n-11))
          next
        endif
        select TMP1
        skip
      enddo
      add_string(replicate("─",sh))
    endif
  endif
  select TMP
  skip
enddo
close databases
if fl_exit
  add_string(replicate("*",sh))
  add_string(expand("ПРОЦЕСС ПРЕРВАН"))
endif
add_string(replicate("═",sh))
if par3 == "summa"
  add_string(padc("Итого:",32)+put_kopE(s1,12)+;
               put_kopE(s2,12)+put_kopE(s3,12)+put_kopE(s,12)+;
               put_kopE(s1+s2+s,12))
else
  s := ""
  if mem_trudoem==2
    s += put_val_0(s4,9,1)
  endif
  s += put_kopE(s2,14)
    //s := umest_val(s1,14,3)
  add_string(padl(s,sh))
endif
fclose(fp)
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

*****
Function Oob1_statist(par1)
Local arr, arr_title, reg_print := 2, sh, HH := 58, s, s1, s2, fl,;
      begin_date, end_date, fl_exit := .f., name_file := "orto_st1"+stxt,;
      tip_tit
Local reg, reg1, mperso, mkod, buf := save_row(maxrow())
DEFAULT par1 TO ""
if (pr_pl_bes := O_ret_pl_b()) == 0
  return NIL
endif
if (arr := year_month()) == NIL
  return NIL
endif
reg1 := if(par1 == "vr", 1, if(par1 == "tehn", 2, 3))
if (mperso := input_kperso()) == NIL  // ==> весь персонал
  mywait()
  mperso := {}
  R_Use(dir_server+"mo_pers",,"PERSO")
  go top
  do while !eof()
    if perso->kod > 0
      aadd(mperso, {perso->kod,""} )
    endif
    skip
  enddo
  perso->(dbCloseArea())
endif
begin_date := arr[5]
end_date := arr[6]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
dbcreate(cur_dir+"tmp", {;
   {"KOD",        "N",      4,      0},;  // код персонала
   {"FIO",        "C",     50,      0},;  // Ф.И.О. персонала
   {"KOL",        "N",      4,      0},;  // количество нарядов по врачу
   {"STOIM_B",    "N",     12,      2},;  // бесплатная стоимость лечения
   {"STOIM_P",    "N",     12,      2},;  // платная стоимость лечения
   {"STOIM_N",    "N",     12,      2} ;  // стоимость напыления
  })
dbcreate(cur_dir+"tmp1", {;
   {"KOD",        "N",      4,      0},;  // код персонала
   {"KOD_H",      "N",      7,      0},;  // код больного по hum_ort
   {"FIO",        "C",     50,      0},;  // Ф.И.О. больного
   {"ADRES",      "C",     50,      0},;  // адрес больного
   {"N_NAR",      "N",      5,      0},;  // номер наряда
   {"STOIM_B",    "N",     12,      2},;  // бесплатная стоимость лечения
   {"STOIM_P",    "N",     12,      2},;  // платная стоимость лечения
   {"STOIM_N",    "N",     12,      2} ;  // стоимость напыления
  })
use (cur_dir+"tmp1") new
index on str(kod,4)+str(kod_h,7) to (cur_dir+"tmp1")
use (cur_dir+"tmp") new
index on str(kod,4) to (cur_dir+"tmp")
musluga := alltrim(mem_ort_na)
if empty(musluga) .or. musluga == "*"
  musluga := "9999999999"
endif
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"mo_pers",,"PERSO")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
set relation to u_kod into USL
R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
set relation to kod_k into KART
dbseek(dtos(begin_date),.t.)
do while human->k_data <= end_date .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  select HU
  find (str(human->(recno()),7))
  do while hu->kod == human->(recno()) .and. !eof()
    do case
      case reg1 == 1
        mkod := hu->kod_vr
      case reg1 == 2
        mkod := hu->kod_as
      case reg1 == 3
        mkod := hu->kod_ms
    endcase
    if (fl := (mkod > 0 .and. ascan(mperso,{|x| x[1]==mkod }) > 0))
      select PERSO
      goto (mkod)
    endif
    if fl
      s1 := s2 := s3 := s4 := 0
      if hu->tip_usl != OU_B_PLAT  // платные
        s2 += hu->stoim
      else
        s1 += hu->stoim
      endif
      if like(musluga,usl->shifr)
        s3 += hu->stoim  // напыление
      endif
      fl := .f. ; s1 := round(s1,2) ; s2 := round(s2,2) ; s3 := round(s3,2)
      do case
        case pr_pl_bes == 1  // платные
          //fl := empty(s1) .and. !empty(s2)
          fl := !empty(s2)
        case pr_pl_bes == 2  // бесплатные
          fl := !empty(s1)
        case pr_pl_bes == 3  // все
          fl := !emptyall(s1,s2)
      endcase
      if fl
        select TMP
        find (str(mkod,4))
        if !found()
          append blank
          tmp->kod := mkod
          tmp->fio := perso->fio
        endif
        tmp->STOIM_B += s1
        tmp->STOIM_P += s2
        tmp->STOIM_N += s3
        select TMP1
        find (str(mkod,4)+str(human->(recno()),7))
        if !found()
          append blank
          tmp1->kod   := mkod
          tmp1->FIO   := kart->fio
          tmp1->ADRES := kart->adres
          tmp1->KOD_H := human->(recno())
          tmp1->N_NAR := human->nar_z
          //
          tmp->kol ++
        endif
        tmp1->STOIM_B += s1
        tmp1->STOIM_P += s2
        tmp1->STOIM_N += s3
      endif
    endif
    select HU
    skip
  enddo
  select HUMAN
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  return NIL
endif
if j == 0
  return func_error(4,"Нет сведений!")
endif
mywait()
//
arr_title := {;
  "────────────────────────────────────────┬─────┬────────┬──────────┬────────╥──────────",;
  "                                        │Наряд│Бесплат.│ Платная  │ в т.ч. ║          ",;
  "                Ф.И.О.                  │заказ│сумма л.│сумма леч.│напыл-ие║  ИТОГО   ",;
  "────────────────────────────────────────┴─────┴────────┴──────────┴────────╨──────────"}
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Объем работ",sh))
add_string(center(arr[4],sh))
add_string(center(pr_titul,sh))
add_string(center({"[ По врачам ]",;
                   "[ По зубным техникам ]",;
                   "[ По медсестрам ]"}[reg1],sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
//
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"mo_pers",,"PERSO")
use (cur_dir+"tmp1") new
index on str(kod,4)+upper(fio) to (cur_dir+"tmp1")
use (cur_dir+"tmp") new
set relation to kod into PERSO
index on upper(fio) to (cur_dir+"tmp")
go top
do while !eof()
  if verify_FF(HH-3,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  s := padr(space(4)+"["+lstr(perso->tab_nom)+"]  "+upper(tmp->fio),41)
  s += put_val(tmp->kol,5)
  s += put_kopE(tmp->stoim_b,9)+;
       put_kopE(tmp->stoim_p,11)+;
       put_kopE(tmp->stoim_n,9)+;
       put_kopE(tmp->stoim_b+tmp->stoim_p,11)
  add_string(s)
  add_string(space(4)+replicate(".",sh-4))
  select TMP1
  find (str(tmp->kod,4))
  do while tmp1->kod == tmp->kod
    s := left(tmp1->fio,40)+put_val(tmp1->n_nar,6)
    s += put_kopE(tmp1->stoim_b,9)+;
         put_kopE(tmp1->stoim_p,11)+;
         put_kopE(tmp1->stoim_n,9)+;
         put_kopE(tmp1->stoim_b+tmp1->stoim_p,11)
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(s)
    add_string(space(4)+alltrim(tmp1->adres))
    select TMP1
    skip
  enddo
  add_string(replicate("─",sh))
  select TMP
  skip
enddo
close databases
if fl_exit
  add_string(replicate("*",sh))
  add_string(expand("ПРОЦЕСС ПРЕРВАН"))
endif
fclose(fp)
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

*****  16.08.21
Function Ort_material(Tip_data)
Local reg, reg1, mperso, musluga, mkod, buf := save_row(maxrow()),;
      msl1usluga, msl2usluga, l_delen, mslusluga, arr, sh, HH := 76,;
      s, s1, s2, s3, fl, begin_date, end_date, fl_exit := .f.,;
      name_file := "orto_mt"+stxt, tip_tit, s4, arr_title := {;
"────────────────────────────────────────────────────────────────────────────────┬──────────────",;
"                           Наименование материала                               │              ",;
"------------------------------------------------------------------------------- │    Расход    ",;
" № наряда │     ФИО пациента                                                    │              ",;
"──────────┴─────────────────────────────────────────────────────────────────────┴──────────────"}

Private mm_orto_mat := {;
  {"Нет привязки",0},;
  {"Бухгалтерия",1},;
  {"Руководство",2};
 }
if (pr_pl_bes := O_ret_pl_b()) == 0
  return NIL
endif
if (arr := year_month()) == NIL
  return NIL
endif
if (glob_mas_pr := inputNist_pr(T_ROW,T_COL-5)) == NIL
  return NIL
endif
reg := 2 //техники
if (mperso := input_kperso()) == NIL  // ==> весь персонал
  mywait()
  mperso := {}
  R_Use(dir_server+"mo_pers",,"PERSO")
  go top
  do while !eof()
    if perso->kod > 0
      aadd(mperso, {perso->kod,""} )
    endif
    skip
  enddo
  perso->(dbCloseArea())
endif
begin_date := arr[5]
end_date := arr[6]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
sh := len(arr_title[1])
add_string("")
if Tip_data == 1
  if  f_is_ist_pr(glob_mas_pr,3) .and. !f_is_ist_pr(glob_mas_pr,1) .and. !f_is_ist_pr(glob_mas_pr,2)
    add_string(center("Ведомость расходования жидкости, содержащей прекурсор метилметакрила",sh))
    if empty(arr[3])
      add_string(center("Ведомость № _____ , от  '____' ___________ 202  г.",sh)) //full_date(date())
    else  
      add_string(center("Ведомость № "+lstr(arr[3]) +" , от "+full_date(date()),sh))
    endif
    add_string(center(arr[4],sh))
  else  
    add_string(center("Расход материалов",sh))
    add_string(center(arr[4],sh))
    add_string(center("[ по дате окончания лечения ]",sh))
  endif
else
  add_string(center("Предварительный Расход материалов",sh))
  add_string(center(arr[4],sh))
  add_string(center("[ по дате начала лечения ]",sh))
endif
add_string("")
dbcreate(cur_dir+"tmp_it", {;
   {"KOD",        "N",      4,      0},;  // код (услуги)
   {"KOL",        "N",     12,      3},;  // кол-во услуг
   {"STOIM",      "N",     14,      2} ;  // стоимость лечения
  })

dbcreate(cur_dir+"tmp", {;
   {"KOD",        "N",      4,      0},;  // код (услуги)
   {"KOL",        "N",     10,      3},;  // кол-во услуг
   {"STOIM",      "N",     14,      2} ;  // стоимость лечения
  })

dbcreate(cur_dir+"tmp_vah", {;
   {"KOD",        "N",      4,      0},;  // код (услуги)
   {"human",      "N",     10,      0},;  // код human
   {"FIO",        "C",     50,      0},;  //
   {"Narad",      "N",     10,      0},;  //
   {"KOL",        "N",     10,      3},;  // кол-во услуг
   {"STOIM",      "N",     14,      2} ;  // стоимость лечения
  })
use (cur_dir+"tmp_vah") new

use (cur_dir+"tmp_it") new
index on str(kod,4) to (cur_dir+"tmp_it")
use (cur_dir+"tmp") new
index on str(kod,4) to (cur_dir+"tmp")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"tip_orto",,"ORT")
R_Use(dir_server+"ortoped",,"OR")
R_Use(dir_server+"ortoped1",,"OR1")
R_Use(dir_server+"ortoped2",,"OR2")
R_Use(dir_server+"mo_pers",,"PERSO")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
if Tip_data == 1
  R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
else
  R_Use(dir_server+"hum_ort",dir_server+"hum_orto","HUMAN")
endif
for prr := 1 to len(mm_orto_mat)
  if f_is_ist_pr(glob_mas_pr,prr)
    if f_is_ist_pr(glob_mas_pr,3) .and. !f_is_ist_pr(glob_mas_pr,1) .and. !f_is_ist_pr(glob_mas_pr,2)
      //
    else  
      add_string(padr("─",sh,"─"))
      add_string(center(mm_orto_mat[prr,1],sh))
      add_string(padr("─",sh,"─"))
      add_string("")
    endif  
    for pr := 1 to len(mperso)
      select TMP
      zap
      select TMP_VAH
      zap
      T_PERSO := mperso[pr,1]
      select HUMAN
      dbseek(dtos(begin_date),.t.)
      do while iif(Tip_data == 1,human->k_data,human->data) <= end_date .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        select HU
        find (str(human->(recno()),7))
        do while hu->kod == human->(recno()) .and. !eof()
          if hu->kod_as == t_perso
            fl := .F.
            if pr_pl_bes == 1  // платные
              fl := (hu->tip_usl != OU_B_PLAT)
            elseif pr_pl_bes == 2  // бесплатные
              fl := (hu->tip_usl == OU_B_PLAT)
            elseif pr_pl_bes == 3  // ВСЕ
              FL := .t.
            endif
            if fl
              select TMP
              find (str(hu->u_kod,4))
              if !found()
                append blank
                tmp->kod := hu->u_kod
              endif
              tmp->kol += hu->kol
              //
              select tmp_vah
              append blank
              tmp_vah->KOD   := hu->u_kod
              tmp_vah->human := hu->kod
              tmp_vah->kOL   := hu->kol
              tmp_vah->Narad := human->nar_z
              select KART
              goto human->kod_k
              tmp_vah->fio   := kart->fio
            endif
          endif
          select HU
          skip
        enddo
        select HUMAN
        skip
      enddo
      // пересчет в материал
      j := tmp->(lastrec())
      if j > 0
        arr_mt := {}
        select TMP
        go top
        do while !eof()
          select OR2
          go top
          locate for or2->kod_usl == tmp->kod
          if found()
            t := or2->kod_tip
            select ORT
            goto t
            if ort->tip == 0 //техники
              select OR1
              go top
              do while !eof()

                if or1->kod_menu == t
                  if (k := ascan(arr_mt, {|x| x[1] == or1->kod_ort } )) == 0
                    aadd(arr_mt, {or1->kod_ort,0,0,"",0,0} ) ; k := len(arr_mt)
                  endif
                  arr_mt[k,2] += tmp->kol
                  arr_mt[k,3] += or1->massa*tmp->kol
                endif
                select OR1
                skip
              enddo
            endif
          endif
          select TMP
          skip
        enddo
        // пересчет в материал 2-й раз
        arr_mt_vah := {}
        select TMP_VAH
        go top
        do while !eof()
          select OR2
          go top
          locate for or2->kod_usl == tmp_vah->kod
          if found()
            t := or2->kod_tip
            select ORT
            goto t
            if ort->tip == 0 //техники
              select OR1
              go top
              do while !eof()

                if or1->kod_menu == t
                  if (k := ascan(arr_mt_vah, {|x| x[1] == or1->kod_ort .and.;
                                          x[6] == tmp_vah->narad  } )) == 0
                    aadd(arr_mt_vah, {or1->kod_ort,0,0,"",0,tmp_vah->narad,tmp_vah->fio} )
                    k := len(arr_mt_vah)
                  endif
                  arr_mt_vah[k,2] += tmp_vah->kol
                  arr_mt_vah[k,3] += or1->massa*tmp_vah->kol
                endif
                select OR1
                skip
              enddo
            endif
          endif
          select TMP_VAH
          skip
        enddo
        // присваиваем наименование и ключ важности
        if len(arr_mt) > 0
          select OR
          for i := 1 to len(arr_mt)
            goto (arr_mt[i,1])
            arr_mt[i,4] := or->name
            arr_mt[i,5] := or->kod
            arr_mt[i,6] := or->kod1
          next
          select perso
          goto (mperso[pr,1])
          xxx := 0
          for i := 1 to len(arr_mt)
            if verify_FF(HH,.t.,sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            if arr_mt[i,3] > 0 .and. arr_mt[i,5] == prr-1
              if xxx == 0
                add_string("   "+alltrim(perso->fio))
                add_string("   ТЕХНИК")
                aeval(arr_title, {|x| add_string(x) } )
                ++xxx
              endif
              add_string(padr(arr_mt[i,4],80)+" "+umest_val(arr_mt[i,3],12,3))
              if arr_mt[i,6] > 0
                // разворачиваем материал как важный
                for jj := 1 to len(arr_mt_vah)
                  if verify_FF(HH,.t.,sh)
                    aeval(arr_title, {|x| add_string(x) } )
                  endif
                  //
                  if arr_mt_vah[jj,1] == arr_mt[i,1] .and. arr_mt_vah[jj,3] > 0
                    add_string(space(5)+padr(lstr(arr_mt_vah[jj,6]),5)+" "+;
                                       padr(arr_mt_vah[jj,7],69)+" "+umest_val(arr_mt_vah[jj,3],12,3))
                  endif
                next
              endif
            endif
          next
          if xxx > 0
            add_string("")
            add_string("")
          endif
        endif
      endif
      //
      select TMP
      go top
      do while !eof()
        select TMP_IT
        find (str(tmp->kod,4))
        if !found()
          append blank
          tmp_it->kod := tmp->kod
        endif
        tmp_it->kol += tmp->kol
        select TMP
        skip
      enddo
    next
    // Итого по техникам
    // пересчет в материал
    j := tmp_it->(lastrec())
    if j > 0
      arr_mt := {}
      select TMP_IT
      go top
      do while !eof()
        select OR2
        go top
        locate for or2->kod_usl == tmp_it->kod
        if found()
          t := or2->kod_tip
          select ORT
          goto t
          if ort->tip == 0 //техники
            select OR1
            go top
            do while !eof()

              if or1->kod_menu == t
                if (k := ascan(arr_mt, {|x| x[1] == or1->kod_ort } )) == 0
                  aadd(arr_mt, {or1->kod_ort,0,0,"",0} ) ; k := len(arr_mt)
                endif
                arr_mt[k,2] += tmp_it->kol
                arr_mt[k,3] += or1->massa*tmp_it->kol
              endif
              select OR1
              skip
            enddo
          endif
        endif
        select TMP_IT
        skip
      enddo
      // присваиваем наименование
      if len(arr_mt) > 0
        select OR
        for i := 1 to len(arr_mt)
          goto (arr_mt[i,1])
          arr_mt[i,4] := or->name
          arr_mt[i,5] := or->kod
        next
        add_string("   ИТОГО по ТЕХНИКАМ")
        aeval(arr_title, {|x| add_string(x) } )
        for i := 1 to len(arr_mt)
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          if arr_mt[i,3] > 0 .and. arr_mt[i,5] == prr-1
            add_string(padr(arr_mt[i,4],80)+" "+umest_val(arr_mt[i,3],12,3))
          endif
        next
        add_string("")
        add_string("")
      endif
    endif
  endif
  //
  select TMP_IT
  zap
next
//
for prr := 1 to len(mm_orto_mat)
  if f_is_ist_pr(glob_mas_pr,prr)
    if f_is_ist_pr(glob_mas_pr,3) .and. !f_is_ist_pr(glob_mas_pr,1) .and. !f_is_ist_pr(glob_mas_pr,2)
      //
    else  
      add_string(padr("─",sh,"─"))
      add_string(center(mm_orto_mat[prr,1],sh))
      add_string(padr("─",sh,"─"))
      add_string("")
    endif  
    for pr := 1 to len(mperso)
      select TMP
      zap
      select TMP_VAH
      zap
      T_PERSO := mperso[pr,1]
      select HUMAN
      dbseek(dtos(begin_date),.t.)
      do while iif(Tip_data == 1,human->k_data,human->data) <= end_date .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        select HU
        find (str(human->(recno()),7))
        do while hu->kod == human->(recno()) .and. !eof()
          if hu->kod_vr == t_perso
            fl := .F.
            if pr_pl_bes == 1  // платные
              fl := (hu->tip_usl != OU_B_PLAT)
            elseif pr_pl_bes == 2  // бесплатные
              fl := (hu->tip_usl == OU_B_PLAT)
            elseif pr_pl_bes == 3  // ВСЕ
              FL := .t.
            endif
            if fl
              select TMP
              find (str(hu->u_kod,4))
              if !found()
                append blank
                tmp->kod := hu->u_kod
              endif
              tmp->kol += hu->kol
            endif
          endif
          select HU
          skip
        enddo
        select HUMAN
        skip
      enddo
      // пересчет в материал
      j := tmp->(lastrec())
      if j > 0
        arr_mt := {}
        select TMP
        go top
        do while !eof()
          select OR2
          go top
          locate for or2->kod_usl == tmp->kod
          if found()
            t := or2->kod_tip
            select ORT
            goto t
            if ort->tip == 1 //врачи
              select OR1
              go top
              do while !eof()
                if or1->kod_menu == t
                  if (k := ascan(arr_mt, {|x| x[1] == or1->kod_ort } )) == 0
                    aadd(arr_mt, {or1->kod_ort,0,0,"",0} ) ; k := len(arr_mt)
                  endif
                  arr_mt[k,2] += tmp->kol
                  arr_mt[k,3] += or1->massa*tmp->kol
                endif
                select OR1
                skip
              enddo
            endif
          endif
          select TMP
          skip
        enddo
        // присваиваем наименование
        if len(arr_mt) > 0
          select OR
          for i := 1 to len(arr_mt)
            goto (arr_mt[i,1])
            arr_mt[i,4] := or->name
            arr_mt[i,5] := or->kod
          next
          select perso
          goto (mperso[pr,1])
          xxx := 0
          for i := 1 to len(arr_mt)
            if verify_FF(HH,.t.,sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            if arr_mt[i,3] > 0 .and. arr_mt[i,5] == prr-1
              if xxx == 0
                add_string("   "+alltrim(perso->fio))
                add_string("   ВРАЧ")
                aeval(arr_title, {|x| add_string(x) } )
                ++xxx
              endif
              add_string(padr(arr_mt[i,4],80)+" "+umest_val(arr_mt[i,3],12,3))
            endif
          next
          if xxx > 0
            add_string("")
            add_string("")
          endif
        endif
      endif
      //
      select TMP
      go top
      do while !eof()
        select TMP_IT
        find (str(tmp->kod,4))
        if !found()
          append blank
          tmp_it->kod := tmp->kod
        endif
        tmp_it->kol += tmp->kol
        select TMP
        skip
      enddo
    next

    // пересчет в материал
    j := tmp_it->(lastrec())
    if j > 0
      arr_mt := {}
      select TMP_IT
      go top
      do while !eof()
        select OR2
        go top
        locate for or2->kod_usl == tmp_it->kod
        if found()
          t := or2->kod_tip
          select ORT
          goto t
          if ort->tip == 1 //техники
            select OR1
            go top
            do while !eof()

              if or1->kod_menu == t
                if (k := ascan(arr_mt, {|x| x[1] == or1->kod_ort } )) == 0
                  aadd(arr_mt, {or1->kod_ort,0,0,"",0} ) ; k := len(arr_mt)
                endif
                arr_mt[k,2] += tmp_it->kol
                arr_mt[k,3] += or1->massa*tmp_it->kol
              endif
              select OR1
              skip
            enddo
          endif
        endif
        select TMP_IT
        skip
      enddo
      //
      // присваиваем наименование
      if len(arr_mt) > 0
        select OR
        for i := 1 to len(arr_mt)
          goto (arr_mt[i,1])
          arr_mt[i,4] := or->name
          arr_mt[i,5] := or->kod
        next
        add_string("   ИТОГО по ВРАЧАМ")
        aeval(arr_title, {|x| add_string(x) } )
        for i := 1 to len(arr_mt)
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          if arr_mt[i,3] > 0 .and. arr_mt[i,5] == prr-1
            add_string(padr(arr_mt[i,4],80)+" "+umest_val(arr_mt[i,3],12,3))
          endif
        next
        add_string("")
        add_string("")
      endif
    endif
  endif
  select TMP_IT
  zap
next
if f_is_ist_pr(glob_mas_pr,3) .and. !f_is_ist_pr(glob_mas_pr,1) .and. !f_is_ist_pr(glob_mas_pr,2)
  add_string(center("________________ (должность) _________________ (подпись) ________________ (расшифровка)    М.П.",sh))
endif  
close databases
fclose(fp)
rest_box(buf)
if !fl_exit
  viewtext(name_file,,,,(sh>80),,,6)
endif
return NIL

*

*****  13.11.16
Function Ort_OMS_material()
Local reg, reg1, mperso, musluga, mkod, buf := save_row(maxrow()),;
      msl1usluga, msl2usluga, l_delen, mslusluga, arr, sh, HH := 76,;
      s, s1, s2, s3, fl, begin_date, end_date, fl_exit := .f.,;
      name_file := "orto_mt"+stxt, tip_tit, s4, arr_title := {;
"────────────────────────────────────────────────────────────────────────────────┬──────────────",;
"                           Наименование материала                               │    Расход    ",;
"────────────────────────────────────────────────────────────────────────────────┴──────────────"}
Private mm_orto_mat := {;
  {"Нет привязки",0},;
  {"Бухгалтерия",1},;
  {"Руководство",2};
 }
//if (pr_pl_bes := O_ret_pl_b()) == 0
//  return NIL
//endif
if (arr := year_month()) == NIL
  return NIL
endif
if (glob_mas_pr := inputNist_pr(T_ROW,T_COL-5)) == NIL
  return NIL
endif
reg := 2 //техники
if (mperso := input_kperso()) == NIL  // ==> весь персонал
  mywait()
  mperso := {}
  R_Use(dir_server+"mo_pers",,"PERSO")
  go top
  do while !eof()
    if perso->kod > 0
      aadd(mperso, {perso->kod,""} )
    endif
    skip
  enddo
  perso->(dbCloseArea())
endif
begin_date := arr[5]
end_date := arr[6]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
sh := len(arr_title[1])
add_string("")
add_string(center("Расход материалов",sh))
add_string(center(arr[4],sh))
add_string(center("[ по дате окончания лечения ]",sh))
add_string("")
dbcreate(cur_dir+"tmp_it", {;
   {"KOD",        "N",      4,      0},;  // код (услуги)
   {"KOL",        "N",     12,      3},;  // кол-во услуг
   {"STOIM",      "N",     14,      2} ;  // стоимость лечения
  })

dbcreate(cur_dir+"tmp", {;
   {"KOD",        "N",      4,      0},;  // код (услуги)
   {"KOL",        "N",     10,      3},;  // кол-во услуг
   {"STOIM",      "N",     14,      2} ;  // стоимость лечения
  })
use (cur_dir+"tmp_it") new
index on str(kod,4) to (cur_dir+"tmp_it")
use (cur_dir+"tmp") new
index on str(kod,4) to (cur_dir+"tmp")
R_Use(dir_server+"tip_orto",,"ORT")
R_Use(dir_server+"ortoped",,"OR")
R_Use(dir_server+"ortoped1",,"OR1")
R_Use(dir_server+"ortoped2",,"OR2")
R_Use(dir_server+"mo_pers",,"PERSO")
R_Use(dir_server+"mo_hu",dir_server+"mo_hu","HU")
//
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
//
for prr := 1 to len(mm_orto_mat)
//  prr := 2
  if f_is_ist_pr(glob_mas_pr,prr)
    add_string(padr("─",sh,"─"))
    add_string(center(mm_orto_mat[prr,1],sh))
    add_string(padr("─",sh,"─"))
    add_string("")
    for pr := 1 to len(mperso)
      select TMP
      zap
      T_PERSO := mperso[pr,1]
      select HUMAN
      dbseek(dtos(begin_date),.t.)
      do while human->k_data <= end_date .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        select HU
        find (str(human->(recno()),7))
        do while hu->kod == human->(recno()) .and. !eof()
          if hu->kod_as == t_perso
            select TMP
            find (str(hu->u_kod,4))
            if !found()
              append blank
              tmp->kod := hu->u_kod
            endif
            tmp->kol += hu->kol_1
          endif
          select HU
          skip
        enddo
        select HUMAN
        skip
      enddo
      // пересчет в материал
      j := tmp->(lastrec())
      if j > 0
        arr_mt := {}
        select TMP
        go top
        do while !eof()
          select OR2
          go top
          locate for or2->kod_usl == tmp->kod
          if found()
            t := or2->kod_tip
            select ORT
            goto t
            if ort->tip == 0 //техники
              select OR1
              go top
              do while !eof()

                if or1->kod_menu == t
                  if (k := ascan(arr_mt, {|x| x[1] == or1->kod_ort } )) == 0
                    aadd(arr_mt, {or1->kod_ort,0,0,"",0} ) ; k := len(arr_mt)
                  endif
                  arr_mt[k,2] += tmp->kol
                  arr_mt[k,3] += or1->massa*tmp->kol
                endif
                select OR1
                skip
              enddo
            endif
          endif
          select TMP
          skip
        enddo
        // присваиваем наименование
        if len(arr_mt) > 0
          select OR
          for i := 1 to len(arr_mt)
            goto (arr_mt[i,1])
            arr_mt[i,4] := or->name
            arr_mt[i,5] := or->kod
          next
          select perso
          goto (mperso[pr,1])
          xxx := 0
          for i := 1 to len(arr_mt)
            if verify_FF(HH,.t.,sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            if arr_mt[i,3] > 0 .and. arr_mt[i,5] == prr-1
              if xxx == 0
                add_string("   "+alltrim(perso->fio))
                add_string("   ТЕХНИК")
                aeval(arr_title, {|x| add_string(x) } )
                ++xxx
              endif
              add_string(padr(arr_mt[i,4],80)+" "+umest_val(arr_mt[i,3],12,3))
            endif
          next
          if xxx > 0
            add_string("")
            add_string("")
          endif
        endif
      endif
      //
      select TMP
      go top
      do while !eof()
        select TMP_IT
        find (str(tmp->kod,4))
        if !found()
          append blank
          tmp_it->kod := tmp->kod
        endif
        tmp_it->kol += tmp->kol
        select TMP
        skip
      enddo
    next
    // Итого по техникам
    // пересчет в материал
    j := tmp_it->(lastrec())
    if j > 0
      arr_mt := {}
      select TMP_IT
      go top
      do while !eof()
        select OR2
        go top
        locate for or2->kod_usl == tmp_it->kod
        if found()
          t := or2->kod_tip
          select ORT
          goto t
          if ort->tip == 0 //техники
            select OR1
            go top
            do while !eof()

              if or1->kod_menu == t
                if (k := ascan(arr_mt, {|x| x[1] == or1->kod_ort } )) == 0
                  aadd(arr_mt, {or1->kod_ort,0,0,"",0} ) ; k := len(arr_mt)
                endif
                arr_mt[k,2] += tmp_it->kol
                arr_mt[k,3] += or1->massa*tmp_it->kol
              endif
              select OR1
              skip
            enddo
          endif
        endif
        select TMP_IT
        skip
      enddo
      // присваиваем наименование
      if len(arr_mt) > 0
        select OR
        for i := 1 to len(arr_mt)
          goto (arr_mt[i,1])
          arr_mt[i,4] := or->name
          arr_mt[i,5] := or->kod
        next
        add_string("   ИТОГО по ТЕХНИКАМ")
        aeval(arr_title, {|x| add_string(x) } )
        for i := 1 to len(arr_mt)
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          if arr_mt[i,3] > 0 .and. arr_mt[i,5] == prr-1
            add_string(padr(arr_mt[i,4],80)+" "+umest_val(arr_mt[i,3],12,3))
          endif
        next
        add_string("")
        add_string("")
      endif
    endif
  endif
  //
  select TMP_IT
  zap
next
//
for prr := 1 to len(mm_orto_mat)
//prr := 2
  if f_is_ist_pr(glob_mas_pr,prr)
    add_string(padr("─",sh,"─"))
    add_string(center(mm_orto_mat[prr,1],sh))
    add_string(padr("─",sh,"─"))
    add_string("")
    for pr := 1 to len(mperso)
      select TMP
      zap
      T_PERSO := mperso[pr,1]
      select HUMAN
      dbseek(dtos(begin_date),.t.)
      do while human->k_data <= end_date .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        select HU
        find (str(human->(recno()),7))
        do while hu->kod == human->(recno()) .and. !eof()
          if hu->kod_vr == t_perso
            select TMP
            find (str(hu->u_kod,4))
            if !found()
              append blank
              tmp->kod := hu->u_kod
            endif
            tmp->kol += hu->kol_1
          endif
          select HU
          skip
        enddo
        select HUMAN
        skip
      enddo
      // пересчет в материал
      j := tmp->(lastrec())
      if j > 0
        arr_mt := {}
        select TMP
        go top
        do while !eof()
          select OR2
          go top
          locate for or2->kod_usl == tmp->kod
          if found()
            t := or2->kod_tip
            select ORT
            goto t
            if ort->tip == 1 //врачи
              select OR1
              go top
              do while !eof()
                if or1->kod_menu == t
                  if (k := ascan(arr_mt, {|x| x[1] == or1->kod_ort } )) == 0
                    aadd(arr_mt, {or1->kod_ort,0,0,"",0} ) ; k := len(arr_mt)
                  endif
                  arr_mt[k,2] += tmp->kol
                  arr_mt[k,3] += or1->massa*tmp->kol
                endif
                select OR1
                skip
              enddo
            endif
          endif
          select TMP
          skip
        enddo
        // присваиваем наименование
        if len(arr_mt) > 0
          select OR
          for i := 1 to len(arr_mt)
            goto (arr_mt[i,1])
            arr_mt[i,4] := or->name
            arr_mt[i,5] := or->kod
          next
          select perso
          goto (mperso[pr,1])
          xxx := 0
          for i := 1 to len(arr_mt)
            if verify_FF(HH,.t.,sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            if arr_mt[i,3] > 0 .and. arr_mt[i,5] == prr-1
              if xxx == 0
                add_string("   "+alltrim(perso->fio))
                add_string("   ВРАЧ")
                aeval(arr_title, {|x| add_string(x) } )
                ++xxx
              endif
              add_string(padr(arr_mt[i,4],80)+" "+umest_val(arr_mt[i,3],12,3))
            endif
          next
          if xxx > 0
            add_string("")
            add_string("")
          endif
        endif
      endif
      //
      select TMP
      go top
      do while !eof()
        select TMP_IT
        find (str(tmp->kod,4))
        if !found()
          append blank
          tmp_it->kod := tmp->kod
        endif
        tmp_it->kol += tmp->kol
        select TMP
        skip
      enddo
    next

    // пересчет в материал
    j := tmp_it->(lastrec())
    if j > 0
      arr_mt := {}
      select TMP_IT
      go top
      do while !eof()
        select OR2
        go top
        locate for or2->kod_usl == tmp_it->kod
        if found()
          t := or2->kod_tip
          select ORT
          goto t
          if ort->tip == 1 //техники
            select OR1
            go top
            do while !eof()

              if or1->kod_menu == t
                if (k := ascan(arr_mt, {|x| x[1] == or1->kod_ort } )) == 0
                  aadd(arr_mt, {or1->kod_ort,0,0,"",0} ) ; k := len(arr_mt)
                endif
                arr_mt[k,2] += tmp_it->kol
                arr_mt[k,3] += or1->massa*tmp_it->kol
              endif
              select OR1
              skip
            enddo
          endif
        endif
        select TMP_IT
        skip
      enddo
      //
      // присваиваем наименование
      if len(arr_mt) > 0
        select OR
        for i := 1 to len(arr_mt)
          goto (arr_mt[i,1])
          arr_mt[i,4] := or->name
          arr_mt[i,5] := or->kod
        next
        add_string("   ИТОГО по ВРАЧАМ")
        aeval(arr_title, {|x| add_string(x) } )
        for i := 1 to len(arr_mt)
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          if arr_mt[i,3] > 0 .and. arr_mt[i,5] == prr-1
            add_string(padr(arr_mt[i,4],80)+" "+umest_val(arr_mt[i,3],12,3))
          endif
        next
        add_string("")
        add_string("")
      endif
    endif
  endif
  select TMP_IT
  zap
next
close databases
fclose(fp)
rest_box(buf)
if !fl_exit
  viewtext(name_file,,,,(sh>80),,,6)
endif
return NIL


***** 13.11.16
Function inputNist_pr(r,c,fl_max)
Static st_ist_fin := {}
Local i, k, t_mas, buf := savescreen(), l_a_ist_fin, mas_s := {}, mas := {0,1,2}
DEFAULT fl_max TO .f.
Private mm_orto_mat := {;
  {"Нет привязки",0},;
  {"Бухгалтерия",1},;
  {"Руководство",2}}
for i := 1 to len(mm_orto_mat)
  aadd(mas_s,mm_orto_mat[i,1])
next
if (k := r + 4) > 22
  k := 22
endif
if c+21 > 77
  c := 77-25
endif
t_mas := aclone(mas_s)
if fl_max  // принудительное полное заполнение
  aeval(mas, {|x| aadd(st_ist_fin,x) } )
endif
aeval(t_mas, {|x,i| ;
         t_mas[i] := iif(ascan(st_ist_fin,mas[i]) > 0, " * ", "   ")+t_mas[i]})
status_key("^<Esc>^ - отказ ^<Enter>^ - подтверждение ^<Ins>^ - смена признака выбора ист.финансир.")
do while .t.
  l_a_ist_fin := NIL
  if popup(r,c,k,c+21,t_mas,i,color5,.t.,"fmenu_reader",,"Привязка","W+/W") > 0
    l_a_ist_fin := {} ; st_ist_fin := {}
    for i := 1 TO 3
      if "*" == substr(t_mas[i],2,1)
        aadd(l_a_ist_fin, {i,alltrim(mas_s[i])})
        aadd(st_ist_fin, mas[i])
      endif
    next
    if empty(l_a_ist_fin)
      func_error(4,"Необходимо отметить хотя бы одну привязку!")
      loop
    else
      exit
    endif
  else
    exit
  endif
enddo
restscreen(buf)
return l_a_ist_fin

***** 13.11.16
Function f_is_ist_pr(arr_s,ist_pr)
return ( ascan(arr_s,{|x| ist_pr==x[1] }) > 0 )

*

*****
Function Ort_dolgi(tip)
Local arr, arr_title, reg_print, sh, HH := 77, buf, s, s1, s2, fl, j,;
      begin_date, fl_exit := .f., name_file := "ort_dolg"+stxt,;
      mperso, i, k
if (arr := year_month()) == NIL
  return NIL
endif
begin_date := arr[5]
Private end_date := arr[6], uslovie
buf := save_row(maxrow())
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
dbcreate(cur_dir+"tmp", {;
   {"KOD_H",      "N",      7,      0},;  // код по БД hum_ort
   {"N_NAR",      "N",      5,      0},;  // номер наряда
   {"STOIM",      "N",     12,      2};   // сумма оплаты
  })
use (cur_dir+"tmp") new
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
R_Use(dir_server+"hum_oro",dir_server+"hum_oro","HO")
if tip == 1
  R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
  uslovie := "human->k_data <= end_date"
else
  R_Use(dir_server+"hum_ort",dir_server+"hum_orto","HUMAN")
  uslovie := "human->n_data <= end_date"
endif
dbseek(dtos(begin_date),.t.)
do while &uslovie .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if tip == 1 .or. (tip == 2 .and. empty(human->k_data))
    s1 := 0
    select HO
    find (str(human->(recno()),7))
    do while ho->kod == human->(recno()) .and. !eof()
      s1 += ho->cena_opl
      skip
    enddo
    s1 := round(s1,2)
    s2 := 0
    select HU
    find (str(human->(recno()),7))
    do while hu->kod == human->(recno()) .and. !eof()
      if hu->tip_usl != OU_B_PLAT  // платные
        s2 += hu->stoim
      endif
      select HU
      skip
    enddo
    s2 := round(s2,2)
    if !(s1 == s2)
      select TMP
      append blank
      tmp->KOD_H := human->(recno())
      tmp->N_NAR := human->nar_z
      tmp->STOIM := s2 - s1
      if tmp->(lastrec()) % 5000 == 0
        Commit
      endif
    endif
  endif
  select HUMAN
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  return NIL
endif
if j == 0
  return func_error(4,"Нет сведений!")
endif
mywait()
//
arr_title := {;
"─────┬────────────────────────────────────────────────┬─────┬─────┬───────────",;
"Наряд│                                                │ Код │ Код │   Сумма   ",;
"заказ│         Ф.И.О. и адрес больного                │врача│техн.│   долга   ",;
"─────┴────────────────────────────────────────────────┴─────┴─────┴───────────"}
sh := len(arr_title[1])
reg_print := 5
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Долги по больным",sh))
add_string(center(arr[4],sh))
if tip == 1
  add_string(center("[ по дате окончания лечения ]",sh))
else
  add_string(center("[ по дате начала лечения ]",sh))
  add_string(center("незакрытые наряды-заказы",sh))
endif
add_string("")
aeval(arr_title, {|x| add_string(x) } )
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_oro",dir_server+"hum_oro","HO")
R_Use(dir_server+"hum_ort",,"HUMAN")
set relation to kod_k into KART
use (cur_dir+"tmp") new
index on str(n_nar,5) to (cur_dir+"tmp")
set relation to kod_h into HUMAN
j := s1 := 0
go top
do while !eof()
  add_string("")
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  ++j ; s1 += tmp->stoim
  add_string(padc(lstr(tmp->n_nar),5)+"  "+;
             padr(alltrim(kart->fio),47)+;
             put_val(human->kod_vr,6)+;
             put_val(human->kod_as,6)+;
             put_kopE(tmp->stoim,12))
  add_string(space(7)+alltrim(kart->adres))
  select TMP
  skip
enddo
close databases
if fl_exit
  add_string(replicate("*",sh))
  add_string(expand("ПРОЦЕСС ПРЕРВАН"))
endif
add_string(replicate("─",sh))
add_string(padr("Кол-во больных - "+lstr(j),25)+padl(put_kop(s1,15),sh-25))
fclose(fp)
close databases
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

***** 09.03.14
Function Ort_otkr_nar(par1,par2)
Local arr, arr_title, reg_print, sh, HH := 58, buf, s, s1, s2, fl, j,;
      begin_date, end_date, fl_exit := .f., name_file := "orto_o1"+stxt,;
      mperso, i, k, is_fio := 1
DEFAULT par2 TO 1
if (pr_pl_bes := O_ret_pl_b()) == 0
  return NIL
endif
if par1 == 1
  if (arr := year_month()) == NIL
    return NIL
  endif
  begin_date := arr[5]
  end_date := arr[6]
endif
if par2 == 1
  if (is_fio := f_alert({'Каким образом производить сортировку документа.',;
                  "Выберите действие:"},;
                 {" По ~Ф.И.О. ",;
                  " По ~номеру наряда "},;
                 1,"N+/BG","R/BG",17,,col1menu )) == 0
    return NIL
  endif
endif
buf := save_row(maxrow())
mywait()
dbcreate(cur_dir+"tmp", {;
   {"KOD",        "N",      4,      0},;  // код по БД tmp1
   {"KOD_H",      "N",      7,      0},;  // код по БД hum_ort
   {"FIO",        "C",     50,      0},;  // Ф.И.О. больного
   {"ADRES",      "C",     50,      0},;  // адрес больного
   {"KOD_VR",     "N",      4,      0},;  // код врача
   {"N_NAR",      "N",      5,      0},;  // номер наряда
   {"DATA",       "D",      8,      0},;  // дата наряда
   {"STOIM_B",    "N",     12,      2},;  // бесплатные больные
   {"STOIM_P",    "N",     12,      2} ;  // платные больные
  })
use (cur_dir+"tmp") new
dbcreate(cur_dir+"tmpvr", {;
   {"KOD_VR",     "N",      4,      0},;  // код врача
   {"STOIM_B",    "N",     12,      2},;  // бесплатные больные
   {"STOIM_P",    "N",     12,      2} ;  // платные больные
  })
use (cur_dir+"tmpvr") new
index on str(kod_vr,4) to (cur_dir+"tmpvr")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_ort",,"HUMAN")
set relation to kod_k into KART
if par1 == 1
  set index to (dir_server+"hum_orto")
  dbseek(dtos(begin_date),.t.)
  if is_open
    index on dtos(data) to (cur_dir+"tmp_hum") while data <= end_date for empty(k_data)
  else
    index on dtos(data) to (cur_dir+"tmp_hum") while data <= end_date
  endif
else
  index on dtos(data) to (cur_dir+"tmp_hum") for empty(k_data)
endif
go top
do while !eof()
  s1 := s2 := 0 ; fl := .f.
  do case
    case pr_pl_bes == 1  // платные
      fl := (human->tip_usl != OU_B_PLAT)
      s1 := human->cena_opl
    case pr_pl_bes == 2  // бесплатные
      fl := (human->tip_usl == OU_B_PLAT)
      s1 := human->cena_opl
    case pr_pl_bes == 3  // все
      fl := .t.
      if human->tip_usl != OU_B_PLAT  // платные
        s2 := human->cena_opl
      else
        s1 := human->cena_opl
      endif
  endcase
  if fl
    if fl
      select TMP
      append blank
      tmp->FIO := kart->fio
      tmp->ADRES := kart->adres
      tmp->KOD_H := human->(recno())
      tmp->KOD_VR := human->kod_vr
      tmp->N_NAR := human->nar_z
      tmp->DATA := human->data
      tmp->STOIM_B := s1
      tmp->STOIM_P := s2
      //
      select TMPVR
      find (str(human->kod_vr,4))
      if !found()
        append blank
        tmpvr->KOD_VR := human->kod_vr
      endif
      tmpvr->STOIM_B += s1
      tmpvr->STOIM_P += s2
      if tmp->(lastrec()) % 5000 == 0
        Commit
      endif
    endif
  endif
  select HUMAN
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if j == 0
  return func_error(4,"Нет сведений!")
endif
mywait()
//
arr_title := {;
"─────┬────────",;
"Наряд│  Дата  ",;
"номер│ наряда ",;
"─────┴────────"}
if par2 == 1
  arr_title[1] += "┬─────"
  arr_title[2] += "│     "
  arr_title[3] += "│ Врач"
  arr_title[4] += "┴─────"
endif
arr_title[1] += "┬────────────────────────────────────────"
arr_title[2] += "│                                        "
arr_title[3] += "│              Ф.И.О., адрес             "
arr_title[4] += "┴────────────────────────────────────────"
reg_print := 2
if pr_pl_bes < 3
  arr_title[1] += "┬───────────"
  arr_title[2] += "│   Сумма   "
  arr_title[3] += "│  лечения  "
  arr_title[4] += "┴───────────"
else
  arr_title[1] += "┬────────┬──────────"
  arr_title[2] += "│Бесплат.│ Платная  "
  arr_title[3] += "│сумма л.│сумма леч."
  arr_title[4] += "┴────────┴──────────"
endif
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
if par1 == 1
  add_string(center("Статистика по "+iif(is_open,"открытым ","")+"нарядам-заказам",sh))
  add_string(center(arr[4],sh))
else
  add_string(center("Незакрытые наряды-заказы",sh))
endif
add_string(center(pr_titul,sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
s1 := s2 := 0
R_Use(dir_server+"mo_pers",,"PERSO")
use (cur_dir+"tmpvr") index (cur_dir+"tmpvr") new
use (cur_dir+"tmp") new
if par2 == 1
  if is_fio == 1
    index on upper(fio) to (cur_dir+"tmp")
  else
    index on str(n_nar,6) to (cur_dir+"tmp")
  endif
else
  set relation to kod_vr into perso
  index on upper(perso->fio)+upper(fio) to (cur_dir+"tmp")
  old_vr := 0
endif
go top
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  if par2 == 2 .and. old_vr != tmp->kod_vr
    select TMPVR
    find (str(tmp->kod_vr,4))
    s := "    ["+lstr(perso->tab_nom)+"] "+alltrim(upper(perso->fio))
    if pr_pl_bes < 3
      s := padr(s,sh-12)+put_kopE(tmpvr->stoim_b,12)
    else
      s := padr(s,sh-20)+put_kopE(tmpvr->stoim_b,9)+put_kopE(tmpvr->stoim_p,11)
    endif
    add_string(charrepl(" ",s,"."))
  endif
  s := padc(lstr(tmp->n_nar),5)+" "+date_8(tmp->data)
  if par2 == 1
    s += put_val(perso->tab_nom,6)
  endif
  s += " "+left(tmp->fio,40)
  s1 += tmp->stoim_b
  if pr_pl_bes < 3
    s += put_kopE(tmp->stoim_b,12)
  else
    s += put_kopE(tmp->stoim_b,9)+;
         put_kopE(tmp->stoim_p,11)
    s2 += tmp->stoim_p
  endif
  add_string(s)
  add_string(space({21,15}[par2])+tmp->adres)
  if par2 == 2
    old_vr := tmp->kod_vr
  endif
  select TMP
  skip
enddo
close databases
if fl_exit
  add_string(replicate("*",sh))
  add_string(expand("ПРОЦЕСС ПРЕРВАН"))
endif
add_string(replicate("─",sh))
if pr_pl_bes < 3
  s := put_kopE(s1,12)
else
  s := put_kopE(s1,9)+put_kopE(s2,11)
endif
add_string(padr("Кол-во нарядов - "+lstr(j),sh-20)+padl(s,20))
fclose(fp)
close databases
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

***** 22.03.17
Function Ort_mnog_poisk()
Local mm_tmp := {}, k
Local buf := savescreen(), tmp_color := setcolor(cDataCGet),;
      tmp_help := help_code, hGauge, name_file := "ort_mnog"+stxt,;
      sh := 80, HH := 77, r1 := 1, a_diagnoz[3], fl_stom := .f.,;
      mm_da_net := {{"нет",1},{"да ",2}}, lvid_doc := 0,;
      menu_plat := {{"платные    ",0},;
                    {"бесплатные ",1},;
                    {"взаимозачет",2},;
                    {"ДМС        ",3}},;
      menu_kb := {{"платный    ",0},;
                  {"бесплатный ",1},;
                  {"взаимозачет",2},;
                  {"ДМС        ",3}},;
      tmp_file := "tmp_mn_p"+sdbf
Private arr_doc := {"Дата рожд.",;
                    "Адрес",;
                    "Вид,N уч/док",;
                    "Наряд-заказ",;
                    "Диагноз",;
                    "Врач/Техник",;
                    "Услуги",;
                    "Номер очереди",;
                    "Примечание"}
if input_uch(T_ROW,T_COL-5) == NIL
  return NIL
endif
Private pr_arr := {}, pr_arr_otd := {}, is_talon := ret_is_talon(),;
        pdata, pk_data
//
R_Use(dir_server+"mo_otd",,"OTD")
dbeval({|| aadd(pr_arr,{otd->(recno()),otd->name,otd->kod_lpu,""}) },;
       {|| otd->kod_lpu == glob_uch[1] .and. between_date(otd->dbegino,otd->dendo,sys_date)} )
R_Use(dir_server+"mo_uch",,"UCH")
aeval(pr_arr, {|x,i| dbGoto(x[3]), pr_arr[i,4] := uch->name } )
//
asort(pr_arr,,,{|x,y| iif(x[3] == y[3], upper(x[2]) < upper(y[2]), ;
                                        upper(x[4]) < upper(y[4])) } )
aeval(pr_arr, {|x| aadd(pr_arr_otd,x[2]+" "+x[4]) } )
close databases
//
lvid_doc := setbit(lvid_doc,1)
lvid_doc := setbit(lvid_doc,4)
//
dbcreate(cur_dir+"tmp", {;
   {"U_KOD"  ,    "N",      4,      0},;  // код услуги
   {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
   {"U_NAME",     "C",     65,      0} ;  // наименование услуги
  })
use (cur_dir+"tmp")
index on str(u_kod,4) to (cur_dir+"tmpk")
index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
tmp->(dbCloseArea())
aadd(mm_tmp, {"data","N",4,0,NIL,;
              {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c),;
                      if(k==nil,nil,(pdata:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION)},;
              0,{|| space(10) },;
              'Дата наряда-заказа'})
aadd(mm_tmp, {"k_data","N",4,0,NIL,;
              {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c),;
                      if(k==nil,nil,(pk_data:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION)},;
              0,{|| space(10) },;
              'Дата окончания лечения'})
aadd(mm_tmp, {"nar_z","N",5,0,,;
              nil,;
              0,nil,;
              "Номер наряда-заказа [с]"})
aadd(mm_tmp, {"nar_z2","N",5,0,,;
              nil,;
              0,nil,;
              "                    [по]"})
aadd(mm_tmp, {"tip_nar","N",2,0,NIL,;
              {|x|menu_reader(x,menu_kb,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Категория больного (наряда)"})
if is_talon
  aadd(mm_tmp, {"kategor","N",2,0,NIL,;
                {|x|menu_reader(x,mo_cut_menu(stm_kategor),A__MENUVERT)},;
                0,{|| space(10) },;
                "Код категории льготы"})
endif
aadd(mm_tmp, {"uch_doc","C",10,0,"@!",;
              nil,;
              space(10),nil,;
              "Вид и номер учетного документа (шаблон)"})
Private arr_uchast := {}
if is_uchastok > 0
  aadd(mm_tmp, {"bukva","C",1,0,"@!",;
                nil,;
                " ",nil,;
                "Буква (перед участком)"})
  aadd(mm_tmp, {"uchast","N",1,0,,;
                {|x|menu_reader(x,;
                      {{ |k,r,c| get_uchast(r+1,c) }},A__FUNCTION)},;
                0,{|| init_uchast(arr_uchast) },;
                "Участок (участки)"})
endif
aadd(mm_tmp, {"fio","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "ФИО (начальные буквы или шаблон)"})
aadd(mm_tmp, {"inostran","N",1,0,NIL,;
              {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
              0,{|| space(10) },;
              "Документы иностранных граждан:"})
aadd(mm_tmp, {"adres","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "Адрес (подстрока или шаблон)"})
aadd(mm_tmp, {"mr_dol","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "Место работы (подстрока или шаблон)"})
aadd(mm_tmp, {"pol","C",1,0,"!",;
              nil,;
              " ",nil,;
              "Пол", {|| mpol $ " МЖ" } })
aadd(mm_tmp, {"vzros_reb","N",2,0,NIL,;
              {|x|menu_reader(x,menu_vzros,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Возрастная принадлежность"})
aadd(mm_tmp, {"god_r_min","D",8,0,,;
              nil,;
              ctod(""),nil,;
              "Дата рождения (минимальная)"})
aadd(mm_tmp, {"god_r_max","D",8,0,,;
              nil,;
              ctod(""),nil,;
              "Дата рождения (максимальная)"})
aadd(mm_tmp, {"rab_nerab","N",2,0,NIL,;
              {|x|menu_reader(x,menu_rab,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Работающий/неработающий"})
/*aadd(mm_tmp, {"mi_git","N",2,0,NIL,;
              {|x|menu_reader(x,menu_mest,A__MENUVERT)},;
              -1,{|| space(10) },;
              "МЕСТО ЖИТЕЛЬСТВА: г/о/и",;
              {|g,o|valid_mest_inog(g,o,2)} })
aadd(mm_tmp, {"rajon_git","N",2,0,NIL,;
              {|x|menu_reader(x,{dir_server+"rajon",,;
                      {||FIELD->tip==m1mi_git}},A__POPUPMENU)},;
              0,{|| space(10) },;
              "   район",,;
              {|| equalany(m1mi_git,0,1) } })
aadd(mm_tmp, {"mest_inog","N",2,0,NIL,;
              {|x|menu_reader(x,menu_mest,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Финансирование: г/о/и",;
              {|g,o|valid_mest_inog(g,o)} })
aadd(mm_tmp, {"rajon","N",2,0,NIL,;
              {|x|menu_reader(x,{dir_server+"rajon",,;
                      {||FIELD->tip==m1mest_inog}},A__POPUPMENU)},;
              0,{|| space(10) },;
              "   район",,;
              {|| equalany(m1mest_inog,0,1) } })
              */
aadd(mm_tmp, {"kod_vr1","N",5,0,NIL,;
              nil,;
              0,nil,;
              "Лечащий врач",;
              {|g| st_v_vrach(g,"mkod_vr") } })
aadd(mm_tmp, {"kod_vr","C",50,0,NIL,;
              nil,;
              space(50),nil,;
              "            ",,;
              {|| .f. } })
aadd(mm_tmp, {"kod_as1","N",5,0,NIL,;
              nil,;
              0,nil,;
              "Зубной техник",;
              {|g| st_v_vrach(g,"mkod_as") } })
aadd(mm_tmp, {"kod_as","C",50,0,NIL,;
              nil,;
              space(50),nil,;
              "            ",,;
              {|| .f. } })
aadd(mm_tmp, {"diag1","C",6,0,"@!",;
              nil,;
              space(6),nil,;
              "Шифры заболеваний [ включаемые ]: 1)",;
              {|g| v_ort_diag() } })
aadd(mm_tmp, {"diag2","C",6,0,"@!",;
              nil,;
              space(6),nil,;
              "                                  2)",;
              {|g| v_ort_diag() } })
aadd(mm_tmp, {"diag3","C",6,0,"@!",;
              nil,;
              space(6),nil,;
              "                                  3)",;
              {|g| v_ort_diag() } })
aadd(mm_tmp, {"diag4","C",6,0,"@!",;
              nil,;
              space(6),nil,;
              "                                  4)",;
              {|g| v_ort_diag() } })
aadd(mm_tmp, {"idiag1","C",6,0,"@!",;
              nil,;
              space(6),nil,;
              "Шифры заболеваний [ исключаемые ]: 1)",;
              {|g| v_ort_diag() } })
aadd(mm_tmp, {"idiag2","C",6,0,"@!",;
              nil,;
              space(6),nil,;
              "                                   2)",;
              {|g| v_ort_diag() } })
aadd(mm_tmp, {"idiag3","C",6,0,"@!",;
              nil,;
              space(6),nil,;
              "                                   3)",;
              {|g| v_ort_diag() } })
aadd(mm_tmp, {"idiag4","C",6,0,"@!",;
              nil,;
              space(6),nil,;
              "                                   4)",;
              {|g| v_ort_diag() } })
if yes_h_otd == 1
  aadd(mm_tmp, {"otd","N",3,0,NIL,;
                {|x|menu_reader(x, ;
                  { { |k,r,c| get_otd(k,r+1,c) }},A__FUNCTION)},;
                0,{|| space(10) },;
                "Отделение" })
endif
aadd(mm_tmp, {"tip_usl","N",2,0,NIL,;
              {|x|menu_reader(x,menu_plat,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Тип (оплаты) услуг"})
aadd(mm_tmp, {"uslugi","N",4,0,NIL,;
              {|x|menu_reader(x, ;
               { { |k,r,c| ob2_v_usl(.t.,r+1) }},A__FUNCTION)},;
              0,{|| space(10) },;
              "Оказанные услуги" })
aadd(mm_tmp, {"otd_usl","N",3,0,NIL,;
              {|x|menu_reader(x, ;
                { { |k,r,c| get_otd(k,r+1,c) }},A__FUNCTION)},;
              0,{|| space(10) },;
              "Отделение, в котором оказана услуга" })
aadd(mm_tmp, {"ukod_vr1","N",5,0,NIL,;
              nil,;
              0,nil,;
              "Врач, оказавший услугу(и)",;
              {|g| st_v_vrach(g,"mukod_vr") } })
aadd(mm_tmp, {"ukod_vr","C",50,0,NIL,;
              nil,;
              space(50),nil,;
              "                         ",,;
              {|| .f. } })
aadd(mm_tmp, {"isvr","N",1,0,NIL,;
              {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
              0,{|| space(10) },;
              "Проставлен код врача, оказавшего услугу(и)",,;
              {|| mukod_vr1==0 } })
aadd(mm_tmp, {"ukod_as1","N",5,0,NIL,;
              nil,;
              0,nil,;
              "Техник, оказавший услугу(и)",;
              {|g| st_v_vrach(g,"mukod_as") } })
aadd(mm_tmp, {"ukod_as","C",50,0,NIL,;
              nil,;
              space(50),nil,;
              "                         ",,;
              {|| .f. } })
aadd(mm_tmp, {"ukod_ms1","N",5,0,NIL,;
              nil,;
              0,nil,;
              "Медсестра, оказавшая услугу(и)",;
              {|g| st_v_vrach(g,"mukod_ms") } })
aadd(mm_tmp, {"ukod_ms","C",50,0,NIL,;
              nil,;
              space(50),nil,;
              "                         ",,;
              {|| .f. } })
aadd(mm_tmp, {"PRICH_POL","N",3,0,NIL,;
              {|x|menu_reader(x,{dir_server+"ort_brk"},A__POPUPEDIT)},;
              0,{|| space(10) },;
              "Причина поломки протеза"})
aadd(mm_tmp, {"summa_min","N",10,2,,;
              nil,;
              0,nil,;
              "Сумма лечения (минимальная)"})
aadd(mm_tmp, {"summa_max","N",10,2,,;
              nil,;
              0,nil,;
              "Сумма лечения (максимальная)"})
aadd(mm_tmp, {"vid_doc","N",17,0,NIL,;
              {|x|menu_reader(x,arr_doc,A__MENUBIT)},;
              lvid_doc,{|x|inieditspr(A__MENUBIT,arr_doc,x)},;
              "Вид документа",NIL})
delete file (tmp_file)
init_base(tmp_file,,mm_tmp,0)
//
R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
pict_vr := "99999"
k := f_edit_spr(A__APPEND,mm_tmp,"множественному запросу",;
                "g_use(cur_dir+'tmp_mn_p',,,.t.,.t.)",0,1,,,,,"writeOmn_p")
if k > 0
  use (tmp_file) new alias MN
  if is_talon .and. mn->kategor == 0
    is_talon := .f.
  endif
  // заменить таб.номер на код
  R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERS")
  if mn->kod_vr1 > 0
    find (str(mn->kod_vr1,5))
    if found()
      mn->kod_vr1 := pers->kod
    endif
  endif
  if mn->kod_as1 > 0
    find (str(mn->kod_as1,5))
    if found()
      mn->kod_as1 := pers->kod
    endif
  endif
  if mn->ukod_vr1 > 0
    find (str(mn->ukod_vr1,5))
    if found()
      mn->ukod_vr1 := pers->kod
    endif
  endif
  if mn->ukod_as1 > 0
    find (str(mn->ukod_as1,5))
    if found()
      mn->ukod_as1 := pers->kod
    endif
  endif
  pers->(dbCloseArea())
  //
  Private much_doc := "", mfio := "", madres := "", mmr_dol := ""
  if !empty(mn->uch_doc)
    much_doc := alltrim(mn->uch_doc)
    if !(right(much_doc,1) == "*")
      much_doc += "*"
    endif
  endif
  if !empty(mn->fio)
    mfio := alltrim(mn->fio)
    if !(right(mfio,1) == "*")
      mfio += "*"
    endif
  endif
  if !empty(mn->adres)
    madres := alltrim(mn->adres)
    if !(left(madres,1) == "*")
      madres := "*"+madres
    endif
    if !(right(madres,1) == "*")
      madres += "*"
    endif
  endif
  if !empty(mn->mr_dol)
    mmr_dol := alltrim(mn->mr_dol)
    if !(left(mmr_dol,1) == "*")
      mmr_dol := "*"+mmr_dol
    endif
    if !(right(mmr_dol,1) == "*")
      mmr_dol += "*"
    endif
  endif
  Private mvkl_diag := ""
  if !empty(mn->diag1)
    mvkl_diag += mn->diag1+","
  endif
  if !empty(mn->diag2)
    mvkl_diag += mn->diag2+","
  endif
  if !empty(mn->diag3)
    mvkl_diag += mn->diag3+","
  endif
  if !empty(mn->diag4)
    mvkl_diag += mn->diag4+","
  endif
  if !empty(mvkl_diag)
    mvkl_diag := substr(mvkl_diag,1,len(mvkl_diag)-1)
  endif
  Private misk_diag := ""
  if !empty(mn->idiag1)
    misk_diag += mn->idiag1+","
  endif
  if !empty(mn->idiag2)
    misk_diag += mn->idiag2+","
  endif
  if !empty(mn->idiag3)
    misk_diag += mn->idiag3+","
  endif
  if !empty(mn->idiag4)
    misk_diag += mn->idiag4+","
  endif
  if !empty(misk_diag)
    misk_diag := substr(misk_diag,1,len(misk_diag)-1)
  endif
  Private arr_usl := {}, fl_summa := .t., flag_hu := .f.
  if mn->otd_usl > 0 .or. mn->isvr > 0 .or. mn->ukod_vr1 > 0 .or. ;
                 mn->ukod_as1 > 0 .or. mn->ukod_ms1 > 0 .or. ;
                 mn->uslugi > 0 .or. mn->tip_usl >= 0 .or. isbit(mn->vid_doc,7)
    fl_summa := .f.
    flag_hu := .t.
  endif
  if mn->uslugi > 0
    use (cur_dir+"tmp") index (cur_dir+"tmpn") new
    go top
    dbeval({|| aadd(arr_usl, {tmp->u_kod,tmp->u_shifr,tmp->u_name,0,0}) })
    tmp->(dbCloseArea())
  endif
  dbcreate(cur_dir+"tmp",{{"kod","N",7,0},;
                          {"stoim","N",10,2}})
  use (cur_dir+"tmp") new
  dbcreate(cur_dir+"tmp1",{{"kod","N",7,0},;
                           {"shifr","C",15,0}})
  use (cur_dir+"tmp1") new
  fl_exit := .f.
  Status_Key("^<Esc>^ - прервать поиск")
  Private c_view := 0, c_found := 0
  if is_talon
    AB_open()
  endif
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART_, recno() into KART2
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
  set relation to u_kod into USL
  if pk_data != NIL
    R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
    set relation to kod_k into KART
    dbseek(dtos(pk_data[5]),.t.)
    do while human->k_data <= pk_data[6] .and. !eof()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if human->lpu == glob_uch[1]
        s1_mnog_poisk(@c_view,@c_found)
      endif
      select HUMAN
      skip
    enddo
  else
    R_Use(dir_server+"hum_ort",dir_server+"hum_orto","HUMAN")
    set relation to kod_k into KART
    dbseek(dtos(pdata[5]),.t.)
    do while human->data <= pdata[6] .and. !eof()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if human->lpu == glob_uch[1]
        s1_mnog_poisk(@c_view,@c_found)
      endif
      select HUMAN
      skip
    enddo
  endif
  j := tmp->(lastrec())
  close databases
  if fl_exit
    // ничего - просто выход
  elseif j == 0
    func_error(4,"Нет сведений!")
  else
    mywait()
    s1 := if(fl_summa, "  Сумма  ", "Стоимость")
    s2 := if(fl_summa, " лечения ", "  услуг  ")
    arr_title := {;
     "────────────────────────────────────────┬─────────",;
     "             Ф.И.О. больного            │"+ s1     ,;
     "                                        │"+ s2     ,;
     "────────────────────────────────────────┴─────────"}
    use (tmp_file) new alias MN
    if isbit(mn->vid_doc,1)
      arr_title[1] += "┬────────"
      arr_title[2] += "│  Дата  "
      arr_title[3] += "│рождения"
      arr_title[4] += "┴────────"
    endif
    if isbit(mn->vid_doc,2)
      arr_title[1] += "┬────────────────────────"
      arr_title[2] += "│         Адрес          "
      arr_title[3] += "│                        "
      arr_title[4] += "┴────────────────────────"
    endif
    if isbit(mn->vid_doc,3)
      arr_title[1] += "┬──────────"
      arr_title[2] += "│ Вид и N  "
      arr_title[3] += "│ уч.док-та"
      arr_title[4] += "┴──────────"
    endif
    if isbit(mn->vid_doc,4)
      arr_title[1] += "┬────────"
      arr_title[2] += "│ Наряд  "
      arr_title[3] += "│N, дата "
      arr_title[4] += "┴────────"
    endif
    if isbit(mn->vid_doc,5)
      arr_title[1] += "┬─────────────"
      arr_title[2] += "│   Диагноз   "
      arr_title[3] += "│             "
      arr_title[4] += "┴─────────────"
    endif
    if isbit(mn->vid_doc,6)
      arr_title[1] += "┬─────"
      arr_title[2] += "│Врач/"
      arr_title[3] += "│техн."
      arr_title[4] += "┴─────"
    endif
    if isbit(mn->vid_doc,7)
      arr_title[1] += "┬───────────────────────"
      arr_title[2] += "│                       "
      arr_title[3] += "│     Список услуг      "
      arr_title[4] += "┴───────────────────────"
    endif
    if isbit(mn->vid_doc,8)
      arr_title[1] += "┬──────────"
      arr_title[2] += "│  Номер   "
      arr_title[3] += "│ очереди  "
      arr_title[4] += "┴──────────"
    endif
    if isbit(mn->vid_doc,9)
      arr_title[1] += "┬───────────────"
      arr_title[2] += "│               "
      arr_title[3] += "│  Примечание   "
      arr_title[4] += "┴───────────────"
    endif
    sh := len(arr_title[1])
    if sh <= 65
      sh := 65
      reg_print := 4
    elseif sh <= 84
      reg_print := 5
    elseif sh <= 120
      reg_print := 6
    elseif sh <= 160
      reg_print := 5
    else
      reg_print := 6
    endif
    R_Use(dir_server+"mo_pers",,"PERSO")
    R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
    R_Use(dir_server+"kartote2",,"KART2")
    R_Use(dir_server+"kartote_",,"KART_")
    R_Use(dir_server+"kartotek",,"KART")
    set relation to recno() into KART_, recno() into KART2
    R_Use(dir_server+"hum_ort",,"HUMAN")
    set relation to kod_k into KART
    use (cur_dir+"tmp1") new
    index on str(kod,7)+fsort_usl(shifr) to (cur_dir+"tmp1")
    use (cur_dir+"tmp") new
    set relation to kod into HUMAN
    if pk_data != NIL
      index on upper(kart->fio)+dtos(human->k_data) to (cur_dir+"tmp")
    else
      index on upper(kart->fio)+dtos(human->data) to (cur_dir+"tmp")
    endif
    fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
    add_string("")
    add_string(center(expand("РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА"),sh))
    add_string("")
    add_string(" == ПАРАМЕТРЫ ПОИСКА ==")
    if mn->nar_z > 0
      if mn->nar_z2 > mn->nar_z
        add_string("Наряды-заказы с "+lstr(mn->nar_z)+" по "+lstr(mn->nar_z2))
      else
        add_string("Наряд-заказ номер: "+lstr(mn->nar_z))
      endif
    endif
    if pdata != NIL
      add_string("Дата открытия наряда-заказа: "+pdata[4])
    elseif pk_data != NIL
      add_string("Дата окончания лечения: "+pk_data[4])
    endif
    if mn->tip_nar >= 0
      add_string("Категория больного: "+;
                 inieditspr(A__MENUVERT, menu_kb, mn->tip_nar))
    endif
    if !empty(much_doc)
      add_string("Вид и номер учетного документа: "+much_doc)
    endif
    if !empty(mfio)
      add_string("ФИО: "+mfio)
    endif
    if mn->inostran > 0
      add_string("Документы иностранных граждан: "+;
                 inieditspr(A__MENUVERT, mm_da_net, mn->inostran))
    endif
    if !empty(madres)
      add_string("Адрес: "+madres)
    endif
    if !empty(mmr_dol)
      add_string("Место работы: "+mmr_dol)
    endif
    if is_talon .and. mn->kategor > 0
      add_string("Код категории льготы: "+;
                 inieditspr(A__MENUVERT, stm_kategor, mn->kategor))
    endif
    if is_uchastok > 0
      if !empty(mn->bukva)
        add_string("Буква: "+mn->bukva)
      endif
      if !empty(mn->uchast)
        add_string("Участок: "+init_uchast(arr_uchast))
      endif
    endif
    if !empty(mn->pol)
      add_string("Пол: "+mn->pol)
    endif
    if mn->vzros_reb >= 0
      add_string("Возрастная принадлежность: "+;
                 inieditspr(A__MENUVERT, menu_vzros, mn->vzros_reb))
    endif
    if !empty(mn->god_r_min) .or. !empty(mn->god_r_max)
      if empty(mn->god_r_min)
        add_string("Лица, родившиеся до "+full_date(mn->god_r_max))
      elseif empty(mn->god_r_max)
        add_string("Лица, родившиеся после "+full_date(mn->god_r_min))
      else
        add_string("Лица, родившиеся с "+;
                   full_date(mn->god_r_min)+" по "+full_date(mn->god_r_max))
      endif
    endif
    if mn->rab_nerab >= 0
      add_string(upper(inieditspr(A__MENUVERT, menu_rab, mn->rab_nerab)))
    endif
/*    if mn->mi_git >= 0
      add_string("Место жительства: "+;
                 inieditspr(A__MENUVERT, menu_mest, mn->mi_git))
    endif
    if mn->rajon_git > 0
      add_string("  Район: "+inieditspr(A__POPUPMENU, dir_server+"rajon", mn->rajon_git))
    endif
    if mn->mest_inog >= 0
      add_string("Финансирование: "+;
                 inieditspr(A__MENUVERT, menu_mest, mn->mest_inog))
    endif
    if mn->rajon > 0
      add_string("  Район: "+inieditspr(A__POPUPMENU, dir_server+"rajon", mn->rajon))
    endif   */
    if mn->kod_vr1 > 0
      add_string("Лечащий врач: "+mn->kod_vr)
    endif
    if mn->kod_as1 > 0
      add_string("Зубной техник: "+mn->kod_as)
    endif
    if !empty(mvkl_diag)
      add_string("Шифры включаемых заболеваний: "+mvkl_diag)
    endif
    if !empty(misk_diag)
      add_string("Шифры исключаемых заболеваний: "+misk_diag)
    endif
    if yes_h_otd == 1 .and. mn->otd > 0
      add_string("Отделение: "+;
                 inieditspr(A__POPUPMENU, dir_server+"mo_otd", mn->otd))
    endif
    if mn->PRICH_POL > 0
      add_string("Причина поломки протеза: "+;
                 inieditspr(A__POPUPMENU, dir_server+"ort_brk", mn->PRICH_POL))
    endif
    if mn->summa_min > 0 .or. mn->summa_max > 0
      if empty(mn->summa_min)
        add_string("Стоимость лечения менее "+lstr(mn->summa_max,10,2))
      elseif empty(mn->summa_max)
        add_string("Стоимость лечения более "+lstr(mn->summa_min,10,2))
      else
        add_string("Стоимость лечения в диапазоне от "+;
                   lstr(mn->summa_min,10,2)+" до "+lstr(mn->summa_max,10,2))
      endif
    endif
    if mn->otd_usl > 0
      add_string("Отделение, в котором оказана услуга: "+;
                 inieditspr(A__POPUPMENU, dir_server+"mo_otd", mn->otd_usl))
    endif
    if mn->ukod_vr1 > 0
      add_string("Врач, оказавший услугу(и): "+alltrim(mn->ukod_vr))
    endif
    if mn->isvr > 0
      add_string("Код врача, оказавшего услугу, "+if(mn->isvr==1,"не ","")+"проставлен")
    endif
    if mn->ukod_as1 > 0
      add_string("Ассистент, оказавший услугу(и): "+alltrim(mn->ukod_as))
    endif
    if mn->ukod_ms1 > 0
      add_string("Медсестра, оказавшая услугу(и): "+alltrim(mn->ukod_ms))
    endif
    if mn->tip_usl >= 0
      add_string("Тип услуг: "+;
                 inieditspr(A__MENUVERT, menu_plat, mn->tip_usl))
    endif
    if mn->uslugi > 0
      l := 0
      aeval(arr_usl, {|x| l := max(l,len(rtrim(x[3]))) } )
      add_string(padr("Оказанные услуги:",l+16)+"|Кол-во| Ст-ть")
      aeval(arr_usl, {|x| add_string(space(5)+x[2]+" "+;
                   padr(x[3],l)+"|"+umest_val(x[4],5,3)+" |"+put_kop(x[5],8)) } )
    endif
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    ss := 0
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      s1 := left(kart->fio,40)
      s3 := ""
      //
      s1 += put_kopE(tmp->stoim,10)
      ss += tmp->stoim
      if mem_kodkrt == 2 .or. is_uchastok > 0
        s2 := " ["
        if is_uchastok > 0
          s2 += alltrim(kart->bukva)
          s2 += lstr(kart->uchast,2)+"/"
        endif
        if is_uchastok == 1
          s2 += lstr(kart->kod_vu)
        else
          s2 += lstr(kart->kod)
        endif
        s2 += "] "
      else
        s2 := " "
      endif
      if !empty(mmr_dol)
        s2 += ltrim(kart->mr_dol)
      endif
      s2 := padr(s2,50)
      s3 := padr(s3,50)
      //
      if isbit(mn->vid_doc,1)
        s1 += " "+date_8(kart->date_r)
        s2 += space(9)
        s3 += space(9)
      endif
      //
      if isbit(mn->vid_doc,2)
        perenos(a_diagnoz,kart->adres,24)
        s1 += " "+padr(alltrim(a_diagnoz[1]),24)
        s2 += " "+padr(alltrim(a_diagnoz[2]),24)
        s3 += " "+padr(alltrim(a_diagnoz[3]),24)
      endif
      //
      if isbit(mn->vid_doc,3)
        s1 += " "+padc(alltrim(human->uch_doc),10)
        s2 += space(11)
        s3 += space(11)
      endif
      //
      if isbit(mn->vid_doc,4)
        s1 += " "+padc(lstr(human->nar_z),8)
        s2 += " "+date_8(human->k_data)
        if empty(human->k_data)
          s3 += " "+date_8(human->data)
        else
          s3 += space(9)
        endif
      endif
      //
      if isbit(mn->vid_doc,5)
        tmp1 := "" ; arr_d := {}
        for i := 1 to 3
          do case
            case i == 1
              pole := "human->kod_diag"
            case i == 2
              pole := "human->kod_diag2"
            case i == 3
              pole := "human->kod_diag3"
          endcase
          if !empty(&pole)
            if ascan(arr_d, &pole) == 0
              aadd(arr_d, &pole)
              tmp1 += " "+alltrim(&pole)
            endif
          endif
        next
        perenos(a_diagnoz,tmp1,13)
        s1 += " "+padc(alltrim(a_diagnoz[1]),13)
        s2 += " "+padc(alltrim(a_diagnoz[2]),13)
        s3 += " "+padc(alltrim(a_diagnoz[3]),13)
      endif
      //
      if isbit(mn->vid_doc,6)
        s1 += put_val(ret_tabn(human->kod_vr),6)
        s2 += put_val(ret_tabn(human->kod_as),6)
        s3 += space(6)
      endif
      //
      if isbit(mn->vid_doc,7)
        tmp1 := ""
        Select TMP1
        find (str(human->(recno()),7))
        do while tmp1->kod == human->(recno()) .and. !eof()
          tmp1 += alltrim(tmp1->shifr)+","
          Skip
        enddo
        tmp1 := left(tmp1,len(tmp1)-1)
        perenos(a_diagnoz,tmp1,23,",")
        s1 += " "+padc(alltrim(a_diagnoz[1]),23)
        s2 += " "+padc(alltrim(a_diagnoz[2]),23)
        s3 += " "+padc(alltrim(a_diagnoz[3]),23)
      endif
      //
      if isbit(mn->vid_doc,8)
        s1 += " "+padc(alltrim(human->n_och),10)
        s2 += space(11)
        s3 += space(11)
      endif
      //
      if isbit(mn->vid_doc,9)
        s1 += " "+padc(alltrim(human->prim),15)
        s2 += space(16)
        s3 += space(16)
      endif
      //
      add_string(s1)
      add_string(s2)
      add_string(s3)
      select TMP
      skip
    enddo
    add_string(replicate("─",sh))
    add_string("  Итого количество больных : "+lstr(tmp->(lastrec()))+;
               " чел.  на сумму  "+lput_kop(ss,.t.)+" руб.")
    fclose(fp)
    close databases
    viewtext(name_file,,,,(sh>80),,,reg_print)
  endif
endif
close databases
restscreen(buf) ; setcolor(tmp_color)
return NIL

*

***** 22.03.17
Static Function s1_mnog_poisk(cv,cf)
Local i, fl := .t., flu := .f., mkol, mstoim := 0, luch_doc := "", arr, lshifr1
++cv
if fl
  if pdata != NIL
    fl := between(human->data,pdata[5],pdata[6])
  elseif pk_data != NIL
    fl := between(human->k_data,pk_data[5],pk_data[6])
  endif
endif
if fl .and. mn->nar_z > 0
  if mn->nar_z2 > mn->nar_z
    fl := between(human->nar_z,mn->nar_z,mn->nar_z2)
  else
    fl := (human->nar_z == mn->nar_z)
  endif
endif
if fl .and. mn->tip_nar >= 0
  fl := (human->tip_usl == mn->tip_nar)
endif
if fl .and. !empty(much_doc)
  fl := like(much_doc,human->uch_doc)
endif
if fl .and. is_uchastok > 0 .and. !empty(mn->bukva)
  kart->(dbGoto(human->kod_k))
  fl := (mn->bukva == kart->bukva)
endif
if fl .and. is_uchastok > 0 .and. !empty(mn->uchast)
  kart->(dbGoto(human->kod_k))
  fl := f_is_uchast(arr_uchast,kart->uchast)
endif
if fl .and. !empty(mfio)
  fl := like(mfio,upper(kart->fio))
endif
if fl .and. mn->inostran > 0
  if mn->inostran == 1 //нет
    //9,21,22,23,24
    fl := !equalany(kart_->vid_ud,9,21,22,23,24)
  else
    fl := equalany(kart_->vid_ud,9,21,22,23,24)
  endif
endif
if fl .and. !empty(madres)
  fl := like(madres,upper(kart->adres))
endif
if fl .and. !empty(mmr_dol)
  fl := like(mmr_dol,upper(kart->mr_dol))
endif
if fl .and. is_talon .and. mn->kategor > 0
  fl := (mn->kategor == kart_->kategor)
endif
if fl .and. !empty(mn->pol)
  fl := (kart->pol == mn->pol)
endif
if fl .and. mn->vzros_reb >= 0
  fl := (kart->vzros_reb == mn->vzros_reb)
endif
if fl .and. !empty(mn->god_r_min)
  fl := (mn->god_r_min <= kart->date_r)
endif
if fl .and. !empty(mn->god_r_max)
  fl := (kart->date_r <= mn->god_r_max)
endif
if fl .and. mn->rab_nerab >= 0
  fl := (kart->rab_nerab == mn->rab_nerab)
endif
/*if fl .and. mn->mi_git >= 0
  fl := (kart->mi_git == mn->mi_git)
endif
if fl .and. mn->rajon_git > 0
  fl := (kart->rajon_git == mn->rajon_git)
endif
if fl .and. mn->mest_inog >= 0
  fl := (kart->mest_inog == mn->mest_inog)
endif
if fl .and. mn->rajon > 0
  fl := (kart->rajon == mn->rajon)
endif*/
if fl .and. !empty(mvkl_diag)
  fl := (human->KOD_DIAG $ mvkl_diag .or. ;
         human->KOD_DIAG2 $ mvkl_diag .or. ;
         human->KOD_DIAG3 $ mvkl_diag)
endif
if fl .and. !empty(misk_diag)
  fl := !(human->KOD_DIAG $ misk_diag .or. ;
          human->KOD_DIAG2 $ misk_diag .or. ;
          human->KOD_DIAG3 $ misk_diag)
endif
if fl .and. yes_h_otd == 1 .and. mn->otd > 0
  fl := (human->otd == mn->otd)
endif
if fl .and. mn->kod_vr1 > 0
  fl := (human->kod_vr == mn->kod_vr1)
endif
if fl .and. mn->kod_as1 > 0
  fl := (human->kod_as == mn->kod_as1)
endif
if fl .and. mn->PRICH_POL > 0
  fl := (mn->PRICH_POL == human->PRICH_POL)
endif
if fl .and. mn->summa_min > 0
  fl := (mn->summa_min <= human->cena)
endif
if fl .and. mn->summa_max > 0
  fl := (human->cena <= mn->summa_max)
endif
if fl
  if flag_hu
    mkol := 0
    select HU
    find (str(human->(recno()),7))
    do while hu->kod == human->(recno())
      flu := .t.
      if flu .and. mn->otd_usl > 0
        flu := (hu->otd == mn->otd_usl)
      endif
      if flu .and. mn->isvr > 0
        if mn->isvr == 1  // нет
          flu := (hu->kod_vr == 0)
        else
          flu := (hu->kod_vr > 0)
        endif
      endif
      if flu .and. mn->ukod_vr1 > 0
        flu := (hu->kod_vr == mn->ukod_vr1)
      endif
      if flu .and. mn->ukod_as1 > 0
        flu := (hu->kod_as == mn->ukod_as1)
      endif
      if flu .and. mn->ukod_ms1 > 0
        flu := (hu->kod_ms == mn->ukod_ms1)
      endif
      if flu .and. mn->uslugi > 0
        i := ascan(arr_usl,{|x| x[1] == hu->u_kod})
        if (flu := (i > 0))
          arr_usl[i,4] += hu->kol
          arr_usl[i,5] += hu->stoim
        endif
      endif
      if flu .and. mn->tip_usl >= 0
        flu := (hu->tip_usl == mn->tip_usl)
      endif
      if flu
        mkol += hu->kol
        mstoim += hu->stoim
        if isbit(mn->vid_doc,7)
          lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          select TMP1
          append blank
          tmp1->kod := human->(recno())
          tmp1->shifr := alltrim(if(empty(lshifr1),usl->shifr,lshifr1))+;
                         "("+alltrim(str_0(hu->kol,7,3))+")"
        endif
      endif
      select HU
      skip
    enddo
    if emptyall(mkol,mstoim)
      fl := .f.
    endif
  else
    mstoim := human->cena
  endif
endif
if fl
  select TMP
  append blank
  tmp->kod := human->(recno())
  tmp->stoim := mstoim
  if ++cf % 2000 == 0
    Commit
  endif
endif
@ 24,1 say lstr(cv) color cColorSt2Msg
@ row(),col() say "/" color "W/R"
@ row(),col() say lstr(cf) color cColorStMsg
return NIL

*****
Function writeOmn_p(k)
Local fl := .t.
if k == 1
  if emptyall(mdata,mk_data)
    fl := func_error(4,"Обязательно должно быть заполнено хотя бы одно поле даты!")
  endif
endif
return fl

*

***** 28.10.14
Function O_ret_pl_b()
Static si := 1
Local mas_pmt := {"~Платные больные",;
                  "~Бесплатные больные",;
                  "~Общие больные"}
Local mas_msg := {"Статистика для платных больных (все услуги платные)",;
                  "Статистика для бесплатных больных (хотя бы одна услуга бесплатная)",;
                  "Статистика для всех больных"}
Local i := len(mas_pmt), k := T_ROW
if k + i + 2 > maxrow()-1
  k := T_ROW - i - 3
endif
if (i := popup_prompt(k,T_COL-5,si,mas_pmt,mas_msg)) > 0
  si := i ; pr_titul := "-= "+charrem("~",mas_pmt[i])+" =-"
endif
return i

*

*****  13.11.18
Function O_ved_narabot()
Static sname1 := "", s1d1, s1d2,;
       sname2 := "", s2d1, s2d2,;
       sname3 := "", s3d1, s3d2
Local arr, arr_title, reg_print := 6, sh, HH := 80, s, s1, s2, fl,;
      begin_date, end_date, fl_exit := .f., name_file := "orto_ved"+stxt,;
      tip_tit, i, sitogo
Local par, mperso, mkod, buf := save_row(maxrow()), ;
      arr_diag := {}, a_diag, all_diag := .f.
DEFAULT s1d1 TO ctod(""), s1d2 TO ctod(""),;
        s2d1 TO ctod(""), s2d2 TO ctod(""),;
        s3d1 TO ctod(""), s3d2 TO ctod("")
R_Use(dir_server+"diag_ort",dir_server+"diag_ort")
dbeval({|| aadd(arr_diag, {shifr+" "+name,shifr}) } )
diag_ort->(dbCloseArea())
if (a_diag := bit_popup(T_ROW,T_COL-5,arr_diag)) == NIL
  return NIL
endif
if len(a_diag) == len(arr_diag)
  all_diag := .t.
endif
Private ym_kol_mes := 0
Private mname1 := padr(sname1,15), m1d1 := s1d1, m1d2 := s1d2,;
        mname2 := padr(sname2,15), m2d1 := s2d1, m2d2 := s2d2,;
        mname3 := padr(sname3,15), m3d1 := s3d1, m3d2 := s3d2
DisplBox(;
" \"+;
" Введите наименования и диапазоны времени для отображения периодов\"+;
"       1-ый период @              , с @          по @           \"+;
"       2-ой период @              , с @          по @           \"+;
"       3-ий период @              , с @          по @           \"+;
" \", ;               // текст в окне, ( \ - перевод строки, @ - Get'ы )
, ;                   // цвет окна (умолч. - cDataCGet)
{"mname1","m1d1","m1d2","mname2","m2d1","m2d2","mname3","m3d1","m3d2"},; // массив Private-переменных для редактирования
{,,,,,,,,},; // массив Picture для редактирования
16, ;                 // row - левый верхний угол окна (по умолч. - центрирование)
, ;                   // col - левый верхний угол окна (по умолч. - центрирование)
, ;                   // массив влоков кода условий WHEN
)           // массив блоков кода условий VALID
arr := {{alltrim(mname1),m1d1,m1d2,1},;
        {alltrim(mname2),m2d1,m2d2,2},;
        {alltrim(mname3),m3d1,m3d2,3}}
do while .t.
  k := len(arr) ; fl := .f.
  for i := 1 to k
    if emptyany(arr[i,2],arr[i,3])
      adel(arr,i)
      asize(arr,k-1)
      fl := .t.
      exit
    endif
  next
  if !fl ; exit ; endif
enddo
if (ym_kol_mes := len(arr)) == 0
  return NIL
elseif ym_kol_mes == 1
  reg_print := 5
endif
sitogo := array(ym_kol_mes,9)
afillall(sitogo,0)
//
sname1 := mname1 ; s1d1 := m1d1 ; s1d2 := m1d2
sname2 := mname2 ; s2d1 := m2d1 ; s2d2 := m2d2
sname3 := mname3 ; s3d1 := m3d1 ; s3d2 := m3d2
asort(arr,,,{|x,y| x[2] < y[2] } )
aeval(arr,{|x,i| arr[i,4] := i } )
begin_date := arr[1,2]
end_date := arr[ym_kol_mes,3]
//
par := if(ptip_pers == "vr", 1, 2)
if (mperso := input_kperso()) == NIL  // ==> весь персонал
  mywait()
  mperso := {}
  R_Use(dir_server+"mo_pers",,"PERSO")
  go top
  do while !eof()
    if perso->kod > 0
      aadd(mperso, {perso->kod,perso->fio} )
    endif
    skip
  enddo
  perso->(dbCloseArea())
endif
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
adbf := {{"KOD","N",4,0},;  // код персонала
         {"MES","N",2,0},;  // номер месяца
         {"KOL_P","N",4,0},;  // количество платных нарядов по врачу
         {"KOL_PS","N",4,0},;  // количество посещений в платных нарядах
         {"STOIM_P","N",12,2},;  // платная стоимость лечения
         {"KOL_B","N",4,0},;  // количество бесплатных нарядов по врачу
         {"KOL_BS","N",4,0},;  // количество посещений в бесплатных нарядах
         {"STOIM_B","N",12,2},;  // бесплатная стоимость лечения
         {"STOIM_BP","N",12,2}}   // платные услуги (для бесплатных больных)
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
index on str(kod,4)+str(mes,2) to (cur_dir+"tmp")
musluga := alltrim(mem_ort_na)
if empty(musluga) .or. musluga == "*"
  musluga := "9999999999"
endif
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
set relation to u_kod into USL
R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
dbseek(dtos(begin_date),.t.)
do while human->k_data <= end_date .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  fl := .f.
  if all_diag
    fl := .t.
  else
    fl := (ascan(a_diag,{|x| x[2] == human->kod_diag}) > 0)
  endif
  if fl .and. (lmes := ascan(arr, {|x| between(human->k_data,x[2],x[3]) } )) > 0
    a_p := {}
    select HU
    find (str(human->(recno()),7))
    do while hu->kod == human->(recno()) .and. !eof()
      do case
        case par == 1
          mkod := hu->kod_vr
        case par == 2
          mkod := hu->kod_as
      endcase
      if (fl := (mkod > 0 .and. ascan(mperso,{|x| x[1]==mkod }) > 0))
        fl_boln := .t.
        if ascan(a_p,mkod) == 0
          aadd(a_p,mkod)
        else
          fl_boln := .f.
        endif
        s1 := s2 := 0
        if hu->tip_usl != OU_B_PLAT  // платные
          s2 += hu->stoim
        else
          s1 += hu->stoim
        endif
        if like(musluga,usl->shifr)
          sitogo[lmes,4] += hu->stoim  // напыление
        endif
        select TMP
        find (str(mkod,4)+str(lmes,2))
        if !found()
          append blank
          tmp->kod := mkod
          tmp->mes := lmes
        endif
        if human->tip_usl != OU_B_PLAT  // платный больной
          if fl_boln
            tmp->KOL_P ++
            tmp->KOL_PS += human->kol_pos
          endif
          tmp->STOIM_P += s2
        else
          if fl_boln
            tmp->KOL_B ++
            tmp->KOL_BS += human->kol_pos
          endif
          tmp->STOIM_B += s1
          tmp->STOIM_BP += s2
        endif
      endif
      select HU
      skip
    enddo
    if len(a_p) > 0
      sitogo[lmes,1] ++
      sitogo[lmes,7] += human->kol_pos
      if human->tip_usl != OU_B_PLAT
        sitogo[lmes,5] ++
        sitogo[lmes,8] += human->kol_pos
      else
        sitogo[lmes,6] ++
        sitogo[lmes,9] += human->kol_pos
      endif
    endif
  endif
  select HUMAN
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  return NIL
endif
if j == 0
  return func_error(4,"Нет сведений!")
endif
mywait()
//
arr_title := array(8)
nf := 16
arr_title[1] := replicate("─",nf)
arr_title[2] := space(nf)
arr_title[3] := space(nf)
arr_title[4] := padc("Ф.И.О.",nf)
arr_title[5] := space(nf)
arr_title[6] := space(nf)
arr_title[7] := space(nf)
arr_title[8] := replicate("─",nf)
//
kb := ym_kol_mes
ar := array(kb)
for i := 1 to ym_kol_mes
  ar[i] := ltrim(arr[i,1]+" [ с "+full_date(arr[i,2])+"г. по "+;
                                  full_date(arr[i,3])+"г.]")
next
if ym_kol_mes > 1
  ++kb
  aadd(ar,"И_Т_О_Г_О")
endif
nk := 68
for i := 1 to kb
  arr_title[1] += "┬────────────────────────────────────────────────────────────────────"
  arr_title[2] += "│"+padc(ar[i],nk)
  arr_title[3] += "├───────────────────┬────────────────────────────┬───────────────────"
  arr_title[4] += "│  платные больные  │     бесплатные больные     │   общие больные   "
  arr_title[5] += "├─────────┬────┬────┼─────────┬────────┬────┬────┼─────────┬────┬────"
  arr_title[6] += "│платные  │кол.│кол.│бесплатн.│платные │кол.│кол.│стоимость│кол.│кол."
  arr_title[7] += "│услуги   │нар.│пос.│услуги   │услуги  │нар.│пос.│услуг    │нар.│пос."
  arr_title[8] += "┴─────────┴────┴────┴─────────┴────────┴────┴────┴─────────┴────┴────"
next
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string(center("Ведомость наработки "+{"врачей","зубных техников"}[par],sh))
if all_diag
  add_string(center("[ по всем нозологиям ]",sh))
else
  s := "[ "
  aeval(a_diag,{|x| s += alltrim(x[2])+","})
  s := substr(s,1,len(s)-1)+" ]"
  add_string(center(s,sh))
endif
add_string("")
aeval(arr_title, {|x| add_string(x) } )
//
R_Use(dir_server+"mo_pers",,"PERSO")
use (cur_dir+"tmp") index (cur_dir+"tmp") new
asort(mperso,,,{|x,y| upper(x[2]) < upper(y[2]) } )
for p := 1 to len(mperso)
  find (str(mperso[p,1],4))
  if found()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    perso->(dbGoto(tmp->kod))
    s := padr(lstr(perso->tab_nom)+"/"+fam_i_o(mperso[p,2]),nf)
    msp := mkp := mkps := msb := msbp := mkb := mkbs := 0
    for i := 1 to ym_kol_mes
      find (str(mperso[p,1],4)+str(arr[i,4],2))
      s += put_kopE(tmp->stoim_p,10)+;
           put_val(tmp->kol_p,5)+;
           put_val(tmp->kol_ps,5)+;
           put_kopE(tmp->stoim_b,10)+;
           put_kopE(tmp->stoim_bp,9)+;
           put_val(tmp->kol_b,5)+;
           put_val(tmp->kol_bs,5)+;
           put_kopE(tmp->stoim_p+tmp->stoim_b+tmp->stoim_bp,10)+;
           put_val(tmp->kol_p+tmp->kol_b,5)+;
           put_val(tmp->kol_ps+tmp->kol_bs,5)
      msp += tmp->stoim_p
      mkp += tmp->kol_p
      mkps += tmp->kol_ps
      msb += tmp->stoim_b
      msbp+= tmp->stoim_bp
      mkb += tmp->kol_b
      mkbs += tmp->kol_bs
      //
      sitogo[i,2] += (tmp->stoim_p + tmp->stoim_bp)
      sitogo[i,3] += (tmp->stoim_b)
    next
    if ym_kol_mes > 1
      s += put_kopE(msp ,10)+;
           put_val(mkp ,5)+;
           put_val(mkps,5)+;
           put_kopE(msb ,10)+;
           put_kopE(msbp,9)+;
           put_val(mkb ,5)+;
           put_val(mkbs,5)+;
           put_kopE(msp+msb+msbp,10)+;
           put_val(mkp+mkb,5)+;
           put_val(mkps+mkbs,5)
    endif
    add_string(s)
    add_string(replicate("-",sh))
  endif
next
close databases
if fl_exit
  add_string(replicate("*",sh))
  add_string(expand("ПРОЦЕСС ПРЕРВАН"))
else
  if verify_FF(HH-5,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  y := array(3)
  s := array(5)
  afill(s,space(nf+1))
  for i := 1 to ym_kol_mes
    s[1] += padr("Итого: кол.нарядов - "+lstr(sitogo[i,1])+;
             " [пл.-"+lstr(sitogo[i,5])+",бес.-"+lstr(sitogo[i,6])+"]",nk+1)
    s[2] += padr(" кол.посещений - "+lstr(sitogo[i,7])+;
             " [пл.-"+lstr(sitogo[i,8])+",бес.-"+lstr(sitogo[i,9])+"]",nk+1)
    s[3] += padr(" сумма платных услуг (без напыления) - "+lput_kop(sitogo[i,2]),nk+1)
    s[4] += padr(" сумма бесплатных услуг - "+lput_kop(sitogo[i,3]),nk+1)
    s[5] += padr(" сумма напыления - "+lput_kop(sitogo[i,4]),nk+1)
  next
  if ym_kol_mes > 1
    afill(y,0) ; aeval(sitogo,{|x| y[1] += x[1], y[2] += x[5], y[3] += x[6] } )
    s[1] += padr("ИТОГО: кол.нарядов - "+lstr(y[1])+" [пл.-"+lstr(y[2])+",бес.-"+lstr(y[3])+"]",nk+1)
    afill(y,0) ; aeval(sitogo,{|x| y[1] += x[7], y[2] += x[8], y[3] += x[9] } )
    s[2] += padr(" кол.посещений - "+lstr(y[1])+" [пл.-"+lstr(y[2])+",бес.-"+lstr(y[3])+"]",nk+1)
    y := 0 ; aeval(sitogo,{|x| y += x[2] } )
    s[3] += padr(" сумма платных услуг (без напыления) - "+lput_kop(y),nk+1)
    y := 0 ; aeval(sitogo,{|x| y += x[3] } )
    s[4] += padr(" сумма бесплатных услуг - "+lput_kop(y),nk+1)
    y := 0 ; aeval(sitogo,{|x| y += x[4] } )
    s[5] += padr(" сумма напыления - "+lput_kop(y),nk+1)
  endif
  aeval(s, {|x| add_string(x) } )
endif
fclose(fp)
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

***** 28.10.14 врачи/техники + количество нарядов
Function O_vr_kol_nar()
Local buf := save_maxrow(), sh, HH := 51, arr_title, s, reg_print := 5,;
      j, arr_m, name_file := "o_kolnar"+stxt, fl_exit := .f.,;
      arr_sm := {0,0,0,0,0,0,0,0}, pr_pl_bes := 0, fl := .F.
if (pr_pl_bes := O_ret_pl_b()) == 0
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
adbf := {{"KOD",   "N", 4,0},;  // код персонала
         {"KOL_N1","N", 4,0},;  // количество открытых нарядов на начало
         {"KOL_N2","N", 4,0},;  // количество закрытых нарядов за период
         {"KOL_N3","N", 4,0},;  // количество открытых нарядов на конец
         {"AVANS1","N",12,2},;  //
         {"AVANS3","N",12,2},;  //
         {"STOIM1","N",12,2},;  //
         {"STOIM2","N",12,2},;  //
         {"STOIM3","N",12,2}}   //
dbcreate(cur_dir+"tmp", adbf)
use (cur_dir+"tmp") new
index on str(kod,4) to (cur_dir+"tmp")
R_Use(dir_server+"hum_oro",dir_server+"hum_oro","HO")
// наряды, ещё не закрытые на начало (конец) периода
R_Use(dir_server+"hum_ort",dir_server+"hum_orto","HUMAN")
go top
do while !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  do case
    case pr_pl_bes == 1  // платные
      fl := (human->tip_usl != OU_B_PLAT)
    case pr_pl_bes == 2  // бесплатные
      fl := (human->tip_usl == OU_B_PLAT)
    case pr_pl_bes == 3  // все
      fl := .T.
  endcase
  if (empty(human->k_data) .and. human->data < arr_m[5]) .or. human->k_data >= arr_m[5]
    if FL
      select TMP
      if ptip_pers == "vr"
        find (str(human->kod_vr,4))
        if !found()
          append blank
          tmp->kod := human->kod_vr
        endif
      else
        find (str(human->kod_as,4))
        if !found()
          append blank
          tmp->kod := human->kod_as
        endif
      endif
      tmp->kol_n1 ++
      tmp->stoim1 += human->cena
      //
      s := 0
      select HO
      find (str(human->(recno()),7))
      do while ho->kod == human->(recno()) .and. !eof()
        if ho->pdate < arr_m[7]
          s += ho->cena_opl
        endif
        if ho->sum_voz > 0 .and. ho->date_voz < arr_m[7]
          s -= ho->sum_voz
        endif
        skip
      enddo
      if !empty(round(s,2))
        tmp->avans1 += s
      endif
    endif
  endif
  if (empty(human->k_data) .and. human->data <= arr_m[6]) .or. human->k_data > arr_m[6]
    if FL
      select TMP
      if ptip_pers == "vr"
        find (str(human->kod_vr,4))
        if !found()
          append blank
          tmp->kod := human->kod_vr
        endif
      else
        find (str(human->kod_as,4))
        if !found()
          append blank
          tmp->kod := human->kod_as
        endif
      endif
      tmp->kol_n3 ++
      tmp->stoim3 += human->cena
      //
      s := 0
      select HO
      find (str(human->(recno()),7))
      do while ho->kod == human->(recno()) .and. !eof()
        if ho->pdate <= arr_m[8]
          s += ho->cena_opl
        endif
        if ho->sum_voz > 0 .and. ho->date_voz <= arr_m[8]
          s -= ho->sum_voz
        endif
        skip
      enddo
      if !empty(round(s,2))
        tmp->avans3 += s
      endif
    endif
  endif
  select HUMAN
  skip
enddo
if !fl_exit // наряды, закрытые за период
  select HUMAN
  set index to (dir_server+"hum_ortd")
  dbseek(dtos(arr_m[5]),.t.)
  do while human->k_data <= arr_m[6] .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    do case
      case pr_pl_bes == 1  // платные
        fl := (human->tip_usl != OU_B_PLAT)
      case pr_pl_bes == 2  // бесплатные
        fl := (human->tip_usl == OU_B_PLAT)
      case pr_pl_bes == 3  // все
        fl := .T.
    endcase
    if FL
      select TMP
      if ptip_pers == "vr"
        find (str(human->kod_vr,4))
        if !found()
          append blank
          tmp->kod := human->kod_vr
        endif
      else
        find (str(human->kod_as,4))
        if !found()
          append blank
          tmp->kod := human->kod_as
        endif
      endif
      tmp->kol_n2 ++
      tmp->stoim2 += human->cena
    endif
    select HUMAN
    skip
  enddo
endif
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  return NIL
endif
if j == 0
  return func_error(4,"Нет сведений!")
endif
mywait()
s1 := date_8(arr_m[5])
s2 := date_8(arr_m[6])
if ptip_pers == "vr"
  s3 := "врача  "
else
  s3 := "техника"
endif
arr_title := {;
  "─────────────────────────────────────────┬──────────────────────┬────────────────┬──────────────────────",;
  "                                         │ наряды, ещё открытые │наряды, закрытые│ наряды, ещё открытые ",;
  "                                         │ на утро "+ s1 +"     │   за период    │ на вечер "+s2,;
  "                                         ├────┬───────┬─────────┼────┬───────────┼────┬───────┬─────────",;
  "            Ф.И.О. "+s3 +"               │кол.│ аванс │к доплате│кол.│   сумма   │кол.│ аванс │к доплате",;
  "─────────────────────────────────────────┴────┴───────┴─────────┴────┴───────────┴────┴───────┴─────────"}
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
R_Use(dir_server+"mo_pers",,"PERSO")
add_string(org->name)
add_string("")
add_string(center("Количество нарядов-заказов",sh))
add_string(center(arr_m[4],sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
use (cur_dir+"TMP") new
set relation to kod into PERSO
index on upper(perso->fio) to (cur_dir+"tmp")
go top
do while !eof()
  s := padr("["+lstr(perso->tab_nom)+"] "+perso->fio,41)+;
       put_val(tmp->KOL_N1,5)+" "+umest_val(tmp->AVANS1,7,1)+" "+umest_val(tmp->STOIM1-tmp->AVANS1,9,2)+;
       put_val(tmp->KOL_N2,5)+" "+umest_val(tmp->STOIM2,11,2)+;
       put_val(tmp->KOL_N3,5)+" "+umest_val(tmp->AVANS3,7,2)+" "+umest_val(tmp->STOIM3-tmp->AVANS3,9,2)
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(s)
  arr_sm[1] += tmp->KOL_N1
  arr_sm[2] += tmp->AVANS1
  arr_sm[3] += (tmp->STOIM1-tmp->AVANS1)
  arr_sm[4] += tmp->KOL_N2
  arr_sm[5] += tmp->STOIM2
  arr_sm[6] += tmp->KOL_N3
  arr_sm[7] += tmp->AVANS3
  arr_sm[8] += (tmp->STOIM3-tmp->AVANS3)
  skip
enddo
add_string(replicate("─",sh))
s := padr("  ИТОГО: ",41)+;
     put_val(arr_sm[1],5)+" "+umest_val(arr_sm[2],7,1)+" "+umest_val(arr_sm[3],9,2)+;
     put_val(arr_sm[4],5)+" "+umest_val(arr_sm[5],11,2)+;
     put_val(arr_sm[6],5)+" "+umest_val(arr_sm[7],7,2)+" "+umest_val(arr_sm[8],9,2)
add_string(s)
fclose(fp)
close databases
rest_box(buf)
Private yes_albom := .t.
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

*****
Function inputNorpozic(r,c,fl_max)
Static st_pozic := {}
Local r1, r2, i, k, t_mas, ;
      buf := savescreen(), l_a_pozic
Local mas_s := {"Номер карты",;
                "Номер чека",;
                "Дата оплаты мед.услуги",;
                "Дата оказания мед.услуги",;
                "Шифр мед.услуги",;
                "Наименование мед.услуги",;
                "Код Врача",;
                "Код Техника",;
                "ФИО врача+техника",;
                "Цена услуги",;
                "Количество услуг"}

Local mas := {1,2,3,4,5,6,7,8,9,10,11}
DEFAULT fl_max TO .f.
r2 := r-2
r1 := r2-len(mas_s)-1
if r1 < 0
  r1 := r
  if (r2 := r1+len(mas_s)+1) > maxrow()-2
    r2 := maxrow()-2
  endif
endif
if c+35 > 77
  c := 77-35
endif
t_mas := aclone(mas_s)
if fl_max  // принудительное полное заполнение
  aeval(mas, {|x| aadd(st_pozic,x) } )
endif
aeval(t_mas, {|x,i| ;
       t_mas[i] := if(ascan(st_pozic,mas[i]) > 0, " * ", "   ")+t_mas[i]})
status_key("^<Esc>^ - отказ ^<Enter>^ - подтверждение ^<Ins>^ - смена признака выбора")
do while .t.
  l_a_pozic := NIL
  if popup(r1,c,r2,c+35,t_mas,i,color0,.t.,"fmenu_reader",,"Колонки информации","B/BG") > 0
    l_a_pozic := {} ; st_pozic := {}
    for i := 1 TO 11
      if "*" == substr(t_mas[i],2,1)
        aadd(l_a_pozic, { (i-1),alltrim(mas_s[i]),})
        aadd(st_pozic, mas[i])
      endif
    next
    if empty(l_a_pozic)
      //func_error(4,"Необходимо отметить хотя бы один источник финансирования!")
      //loop
      exit
    else
      exit
    endif
  else
    exit
  endif
enddo
restscreen(buf)
return l_a_pozic

*

//*****
//Function f_is_pozic(arr_s,pozic)
//Local fl := .t.
//fl := ( ascan(arr_s,{|x| pozic==x[1] }) > 0 )
//return fl

*

***** 02.12.12
Function pl_ordogovor()
Local buf := save_maxrow(), sh, HH := 51, arr_title, s, i, j, k, sk, ss,;
      arr2title, reg_print := 6, afio[10], lfio := 19, kfio, lsk, lss, adbf,;
      aadres[2], kadres, apolis[10], kpolis, name_file := "jurnal.txt"
arr_title := {;
"─────────────────────────────┬───────┬─────────────────────────────────────────────────────────────────┬───────┬────┬──────────┬───────────────┬──────────┬──────────",;
"        Ф.И.О., адрес        │ НОМЕР │                   Вид медицинской услуги                        │ Стоим-│Кол.│ Сумма за │Ф.И.О специали-│   Дата   │   Срок   ",;
"        застрахованного      │медицин│                                                                 │  сть  │оказ│все кол-во│ ста оказавшего│  приема  │ оказания ",;
"                             │ карты │                                                                 │ услуги│ус- │оказ.услуг│  мед. услугу  │          │   мед.   ",;
"                             │       │                                                                 │ (руб.)│луг │  (руб.)  │               │          │  услуги  ",;
"─────────────────────────────┴───────┴─────────────────────────────────────────────────────────────────┴───────┴────┴──────────┴───────────────┴──────────┴──────────"}
if (arr_m := year_month()) == NIL
  return NIL
endif
mywait()
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"mo_pers",,"perso")
R_Use(dir_server+"organiz",,"ORG")
add_string(center("Ж У Р Н А Л",sh))
add_string(center("учета заказов граждан на предоставление им платных медицинских услуг(помощи)",sh))
add_string(center("по "+iif(is_open,"открытым ","закрытым ")+"нарядам-заказам",sh))
add_string(center(arr_m[4],sh))
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HPU")
R_Use(dir_server+"hum_ort",,"HU")
aeval(arr_title, {|x| add_string(x) } )
j := sk := ss := 0
select HU
go top
do while !eof()
  if arr_m[5] <= hu->data .and. hu->data <= arr_m[6] .and.;
     if(is_open,.T.,!empty(hu->k_data))
     //  if(is_open,empty(hu->k_data),!empty(hu->k_data))
    ss += hu->cena
    select KART
    goto hu->kod_k
    kfio := perenos(afio,alltrim(kart->fio)+" "+alltrim(kart->adres),29)
    fl_hu := .T. ; i := 0
    select HPU
    t_kod := hu->(recno())
    find (str(t_kod,7))
    do while t_kod==hpu->kod .and. !eof()
      if verify_FF(HH,.t.,sh)
       aeval(arr_title, {|x| add_string(x) } )
      endif
      usl->(dbGoto(hpu->u_kod))
      select PERSO
      goto (hpu->kod_vr)
      t_vr := perso->tab_nom
      t_nvr := fam_i_o(perso->fio)
      if fl_hu
        fl_hu := .F.
        add_string(afio[1]+" "+;
                   padr(lstr(hu->kod_k),7)+" "+;
                   padr(usl->name,65)+" "+put_kop(hpu->u_cena,7)+" "+;
                   padr(lstr(hpu->kol),4)+" "+put_kop(hpu->stoim,10)+" "+;
                   padr(t_nvr,15)+" "+;
                   full_date(c4tod(hpu->date_u))+" "+;
                   full_date(iif(empty(hu->k_data),sys_date,hu->k_data)))
        i := 1
      else
        ++i
        add_string(iif(i<=kfio,afio[i],space(29))+" "+;
                   space(7)+" "+;
                   padr(usl->name,65)+" "+put_kop(hpu->u_cena,7)+" "+;
                   padr(lstr(hpu->kol),4)+" "+put_kop(hpu->stoim,10)+" "+;
                   padr(t_nvr,15)+" "+;
                   full_date(c4tod(hpu->date_u))+" "+;
                   full_date(iif(empty(hu->k_data),sys_date,hu->k_data)))
      endif
      select HPU
      skip
    enddo
    if i == 1
      add_string(iif(1<kfio,afio[2],space(29)))
    endif
    // подбивка итого
    add_string(space(29)+" "+;
               space(7)+" "+;
               space(65)+space(7)+;
               "Итого: "+put_kop(hu->cena,10))
  endif
  select HU
  skip
enddo
close databases
add_string(replicate("─",sh))
add_string(padl("Итого : "+str(ss,11,2),sh-12))
add_string("")
add_string("")
add_string(center("Главный врач _________________                         Главный бухгалтер _________________",sh))
fclose(fp)
rest_box(buf)
Private yes_albom := .t.
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

*****
Function pl_or2dogovor(tip_jurn)
Local buf := save_row(maxrow()), sh, HH := 51, arr_title, s, i, k, sk, ss,;
      arr2title, reg_print := 6, afio[10], lfio := 19, kfio, lsk, lss, adbf,;
      aadres[2], kadres, apolis[10], kpolis, name_file := "jurnal1.txt",;
      op_sm[10], op_date[10], op_kvit[10], op_tip[10], mas_tip := {"П"," ","з","Д"},;
      kol_opl :=0 ,sm_b := {0,0,0}, sm_pl := {0,0,0}, sm_dms := {0,0,0},sm_vz :={0,0,0},;
      t_vr, t_as, t_nvr, t_nas
arr_title := {;
"─────────────────────────────┬────────",;
"        Ф.И.О., адрес        │  Дата  ",;
"        застрахованного      │рождения",;
"                             │        ",;
"                             │        ",;
"─────────────────────────────┴────────"}
// номер карты
arr_1 := {;
 "┬───────",;
 "│ НОМЕР ",;
 "│медицин",;
 "│ карты ",;
 "│Nнаряда",;
 "┴───────"}
//номер чека
arr_2 := {;
 "┬───────────────",;
 "│    Оплата     ",;
 "├──────┬────────",;
 "│ Номер│ Сумма  ",;
 "│ чека │        ",;
 "┴──────┴────────"}
// дата оплаты услуги
arr_3 := {;
 "┬────────",;
 "│  Дата  ",;
 "│ оплаты ",;
 "│  мед.  ",;
 "│ услуги ",;
 "┴────────"}
// дата оказания услуги
arr_4 := {;
 "┬─────────────────",;
 "│      Лечение    ",;
 "├────────┬────────",;
 "│  Дата  │  Дата  ",;
 "│ начала │ окон-ия",;
 "┴────────┴────────"}
// шифр услуги
arr_5 := {;
 "┬──────────",;
 "│ Код мани-",;
 "│ пуляции  ",;
 "│          ",;
 "│          ",;
 "┴──────────"}
// наименование услуги
arr_6 := {;
 "┬──────────────────────────────────────────────────",;
 "│                                                  ",;
 "│       Вид (наименование) медицинской услуги      ",;
 "│                                                  ",;
 "│                                                  ",;
 "┴──────────────────────────────────────────────────"}
// код врач
arr_7 := {;
 "┬─────",;
 "│     ",;
 "│     ",;
 "│Врач ",;
 "│     ",;
 "┴─────"}
// код м/c
arr_8 := {;
 "┬─────",;
 "│     ",;
 "│ Тех ",;
 "│ ник ",;
 "│     ",;
 "┴─────"}
// фио врача+м/с
arr_9  := {;
 "┬───────────────",;
 "│               ",;
 "│     Врач      ",;
 "├───────────────",;
 "│               ",;
 "┴───────────────"}
// цена услуги
arr_10 := {;
 "┬───────",;
 "│  Цена ",;
 "│ каждой",;
 "│ услуги",;
 "│ (руб.)",;
 "┴───────"}
// количество услуг
arr_11 := {;
 "┬────",;
 "│Кол.",;
 "│оказ",;
 "│ус- ",;
 "│луг ",;
 "┴────"}
// сумма услуг
arr_00 := {;
 "┬──────────",;
 "│ Сумма за ",;
 "│все кол-во",;
 "│оказ.услуг",;
 "│  (руб.)  ",;
 "┴──────────"}
Private glob_pozic
if (glob_pozic := inputNorpozic(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
mywait()
// создаем заголовок
for i := 0 to 10
  if f_is_pozic(glob_pozic,i)
    for j := 1 to 6
      arr_title[j] += &("arr_"+lstr(i+1)+"[j]")
    next
  endif
next
for j := 1 to 6
  arr_title[j] += arr_00[j]
next
//
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"mo_pers",,"PERSO")
R_Use(dir_server+"organiz",,"ORG")
add_string(center("Ж У Р Н А Л",sh))
if tip_jurn==1
  add_string(center("учета заказов граждан на оказание им платных медицинских услуг(помощи)",sh))
else
  add_string(center("оказания ортопедических услуг по закрытым нарядам",sh))
endif
add_string(center(arr_m[4],sh))
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HPU")
R_Use(dir_server+"hum_oro",dir_server+"hum_oro","HPO")
R_Use(dir_server+"hum_ort",,"HU")
if tip_jurn==1
  index on N_data to (cur_dir+"tmp_hum") for between(N_data,arr_m[5],arr_m[6])
ELSE
  index on k_data to (cur_dir+"tmp_hum") for between(k_data,arr_m[5],arr_m[6])
ENDIF
aeval(arr_title, {|x| add_string(x) } )
j := sk := ss := 0
select HU
go top
do while !eof()
  if hu->tip_usl == 0
    ++sm_pl[1]
    sm_pl[2] += hu->cena
  elseif hu->tip_usl == 1
    ++sm_b[1]
    sm_b[2] += hu->cena
  elseif hu->tip_usl == 2
    ++sm_vz[1]
    sm_vz[2] += hu->cena
  else
    ++sm_dms[1]
    sm_dms[2] += hu->cena
  endif
  ss += hu->cena
  select KART
  goto hu->kod_k
  kfio := perenos(afio,alltrim(kart->fio)+" "+alltrim(kart->adres),29)
  kol_opl := 0
  select HPO
  find (str(hu->(recno()),7))
  do while hu->(recno()) == hpo->kod .and. !eof()
    ++kol_opl
    op_sm[kol_opl]   := hpo->cena_opl
    op_date[kol_opl] := hpo->PDATE
    op_kvit[kol_opl] := hpo->KV_CIA
    op_tip[kol_opl]  := mas_tip[hpo->tip_usl+1]
    if hpo->tip_usl == 0
      sm_pl[3] += hpo->cena_opl
    elseif hpo->tip_usl == 1
      sm_b[3] += hpo->cena_opl
    elseif hpo->tip_usl == 2
      sm_vz[3] += hpo->cena_opl
    else
      sm_dms[3] += hpo->cena_opl
    endif
    skip
  enddo
  fl_hu := .T.
  select HPU
  t_kod := hu->(recno())
  find (str(t_kod,7))
  do while t_kod==hpu->kod .and. !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    usl->(dbGoto(hpu->u_kod))
    t_vr := ret_tabn(hpu->kod_vr)
    t_as := ret_tabn(hpu->kod_as)
    if fl_hu
      fl_hu := .F.
      select PERSO
      goto (hpu->kod_vr)
      t_nvr := fam_i_o(perso->fio)
      add_string(afio[1]+" "+;
                 date_8(kart->date_r)+" "+; //
                 iif(f_is_pozic(glob_pozic,0),padr(lstr(hu->kod_k),7)+" ","")+;
                 iif(f_is_pozic(glob_pozic,1),padl(lstr(op_kvit[1])+op_tip[1],6)+" "+put_kop(op_sm[1],8)+" ","")+;
                 iif(f_is_pozic(glob_pozic,2),date_8(c4tod(op_date[1]))+" ","")+;
                 iif(f_is_pozic(glob_pozic,3),date_8(hu->n_data)+" "+date_8(hu->k_data)+" ","")+;
                 iif(f_is_pozic(glob_pozic,4),usl->shifr+" ","")+;
                 iif(f_is_pozic(glob_pozic,5),padr(usl->name,50)+" ","")+;
                 iif(f_is_pozic(glob_pozic,6),iif(t_vr>0,padl(lstr(t_vr),5),space(5))+" ","")+;
                 iif(f_is_pozic(glob_pozic,7),iif(t_as>0,padl(lstr(t_as),5),space(5))+" ","")+;
                 iif(f_is_pozic(glob_pozic,8),padr(t_nvr,15)+" ","")+;
                 iif(f_is_pozic(glob_pozic,9),put_kop(hpu->u_cena,7)+" ","")+;
                 iif(f_is_pozic(glob_pozic,10),padr(lstr(hpu->kol),4)+" ","")+;
                 put_kop(hpu->stoim,10))
      i := 1
    else
      ++i
      add_string(iif(i<=kfio,afio[i],space(29))+" "+;
                 space(8)+" "+;
                 iif(f_is_pozic(glob_pozic,0),iif(i!=2,      space(7), "N "+padl(lstr(hu->NAR_Z),5))+" ","")+;
                 iif(f_is_pozic(glob_pozic,1),iif(i>kol_opl, iif(i==(kol_opl+1),"Итого: "+put_kop(hu->CENA,8) ,space(15)),;
                                                     padl(lstr(op_kvit[i])+op_tip[i],6)+" "+;
                                                     put_kop(op_sm[i],8))+" ","")+;
                 iif(f_is_pozic(glob_pozic,2),iif(i>kol_opl, space(8), date_8(c4tod(op_date[kol_opl])))+" ","")+;
                 iif(f_is_pozic(glob_pozic,3),space(18),"")+;
                 iif(f_is_pozic(glob_pozic,4),usl->shifr+" ","")+;
                 iif(f_is_pozic(glob_pozic,5),padr(usl->name,50)+" ","")+;
                 iif(f_is_pozic(glob_pozic,6),iif(t_vr>0,padl(lstr(t_vr),5),space(5))+" ","")+;
                 iif(f_is_pozic(glob_pozic,7),iif(t_as>0,padl(lstr(t_as),5),space(5))+" ","")+;
                 iif(f_is_pozic(glob_pozic,8),padr(t_nvr,15)+" ","")+;
                 iif(f_is_pozic(glob_pozic,9),put_kop(hpu->u_cena,7)+" ","")+;
                 iif(f_is_pozic(glob_pozic,10),padr(lstr(hpu->kol),4)+" ","")+;
                 put_kop(hpu->stoim,10))
    endif
    select HPU
    skip
  enddo
  if i == 1 .and. 1<kfio
    add_string(afio[2])
  endif
//  if mem_dop_st == 2
  add_string("")
//  endif
  select HU
  skip
enddo
close databases
add_string(replicate("─",sh))
add_string(padl("Итого : "+lstr(ss,14,2),sh))
add_string(" Вид оплаты      Кол-во      Сумма нар-ов   Сумма оплаты")
add_string("   Платные     "+str(sm_pl[1],11) +"   "+put_kop(sm_pl[2],11) +"   "+put_kop(sm_pl[3],11))
add_string("   Бюджетный   "+str(sm_b[1],11)  +"   "+put_kop(sm_b[2],11)  +"   "+put_kop(sm_b[3],11))
add_string("   Взаимозачет "+str(sm_vz[1],11) +"   "+put_kop(sm_vz[2],11) +"   "+put_kop(sm_vz[3],11))
add_string("   ДМС         "+str(sm_dms[1],11)+"   "+put_kop(sm_dms[2],11)+"   "+put_kop(sm_dms[3],11))
if tip_jurn==1
  add_string("")
  add_string(center("Главный врач _________________                         Главный бухгалтер _________________",sh))
endif
fclose(fp)
rest_box(buf)
Private yes_albom := .t.
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

***** 13.11.18
Function oo_spmater()
Local arr, sh, HH := 58, s, s1, s2, s3, fl,;
      begin_date, end_date, fl_exit := .f., name_file := "orto_mt"+stxt,;
      tip_tit, s4,;
    arr_title := {;
"───────────────────────────────────────────────────────────────────────────────────┬───────────",;
"                  Наименование Услуги (входящие материалы)                         │   Расход  ",;
"───────────────────────────────────────────────────────────────────────────────────┴───────────"}
Local reg, reg1, mperso, musluga, mkod, buf := save_row(maxrow())
Local msl1usluga, msl2usluga, l_delen, mslusluga
mywait()
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
sh := len(arr_title[1])
add_string("")
add_string(center("Настройка расхода материалов",sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
R_Use(dir_server+"tip_orto",,"OR0")
index on str(tip,1)+name to (cur_dir+"tmp1")
R_Use(dir_server+"uslugi",dir_server+"uslugi","USL")
R_Use(dir_server+"ortoped",,"OR")
R_Use(dir_server+"ortoped1",,"OR1")
index on str(kod_menu,4) to (cur_dir+"tmp2")
set relation to kod_ort into OR
R_Use(dir_server+"ortoped2",,"OR2")
set relation to str(kod_usl,4) into USL
//
select OR0
go top
do while !eof()
   if verify_FF(HH,.t.,sh)
     aeval(arr_title, {|x| add_string(x) } )
   endif
   add_string("")
   add_string(or0->name)
   add_string("  - исполнитель "+alltrim(inieditspr(A__MENUVERT,mm_ortispol,or0->tip)))
   select OR2
   index on usl->shifr to (cur_dir+"tmp4") for kod_tip == or0->(recno())
   go top
   do while !eof()
     if verify_FF(HH,.t.,sh)
       aeval(arr_title, {|x| add_string(x) } )
     endif
     add_string("  -"+padr(padl(alltrim(usl->shifr),9)+" "+usl->name,82))
     skip
   enddo
   add_string("")
   select OR1
   find(str(or0->(recno()),4))
   do while or0->(recno()) == or1->kod_menu .and. !eof()
     if verify_FF(HH,.t.,sh)
       aeval(arr_title, {|x| add_string(x) } )
     endif
     if round_5(or1->massa,3) > 0
       add_string("  -"+padr(alltrim(or->name),83)+" "+str(or1->massa,8,3))
     endif
     skip
   enddo
  select OR0
  skip
enddo
close databases
fclose(fp)
rest_box(buf)
if !fl_exit
  viewtext(name_file,,,,(sh>80),,,3)
endif
return NIL

*

***** 13.11.18
Function oo1spmater()
Local arr, sh, HH := 58, s, s1, s2, s3, fl,;
      begin_date, end_date, fl_exit := .f., name_file := "orto1mt"+stxt,;
      tip_tit, s4,;
    arr_title := {;
"───────────────────────────────────────────────────────────────────────────────────┬───────────",;
"                   Наименование Услуги (входящие материалы)                        │   Расход  ",;
"───────────────────────────────────────────────────────────────────────────────────┴───────────"}
Local reg, reg1, mperso, musluga, mkod, buf := save_row(maxrow())
Local msl1usluga, msl2usluga, l_delen, mslusluga
mywait()
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
sh := len(arr_title[1])
add_string("")
add_string(center("Настройка расхода материалов",sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
R_Use(dir_server+"uslugi",dir_server+"uslugi","USL")
R_Use(dir_server+"ortoped",,"OR")
//
R_Use(dir_server+"ortoped1",,"OR1")
index on str(kod_menu,4) to (cur_dir+"tmp2")
set relation to kod_ort into OR
//
R_Use(dir_server+"ortoped2",,"OR2")
set relation to str(kod_usl,4) into USL
index on usl->shifr to (cur_dir+"tmp1")
//
select OR2
go top
do while !eof()
   if verify_FF(HH,.t.,sh)
     aeval(arr_title, {|x| add_string(x) } )
   endif
   add_string("")
   add_string(padr(padl(alltrim(usl->shifr),9)+" "+usl->name,82))
   select OR1
   find(str(or2->kod_tip,4))
   do while or2->kod_tip == or1->kod_menu .and. !eof()
     if verify_FF(HH,.t.,sh)
       aeval(arr_title, {|x| add_string(x) } )
     endif
     if round_5(or1->massa,3) > 0
       add_string("    -"+padr(alltrim(or->name),83)+" "+str(or1->massa,8,3))
     endif
     select OR1
     skip
   enddo
   //
  select OR2
  skip
enddo
close databases
fclose(fp)
rest_box(buf)
if !fl_exit
  viewtext(name_file,,,,(sh>80),,,3)
endif
return NIL

*

*****
Function forma_30all(tip_f30)
Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(),;
      fl_exit := .f., tm, t, t1, t2, s_lu := 0, s_human := 0,;
      kh := 0, jh := 0, arr_m, arr_pl, fl_per
for j := 1 to 48
  t := "au"+lstr(j)
  Private &t
next
if !get_nastr_orto_f30()
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
if tip_f30 == 1 .and. !input_perso(T_ROW,T_COL-5,.f.)
  return NIL
endif
Private speriod := arr_m[4]
begin_date := arr_m[7]
end_date := arr_m[8]
//
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
delFRfiles()
cre_tmp_30({{"p_kod","C",4,0},;
            {"ddd","D",8,0},;
            {"sr_it","N",1,0},;
            {"tip","N",1,0},;   // 1-весь персонал, 2-перс.в отделении, 3-отделение
            {"otd","N",3,0},;
            {"tab_nom","N",5,0},;
            {"name","C",25,0},;
            {"kol_pos","N",4,0},;
            {"kol_ppos","N",4,0},;
            {"summa","N",12,2},;
            {"yet","N",10,2},;
            {"bud_hum","N",4,0},;
            {"bud_prot","N",4,0};
           })
use (fr_data) new alias TMP
index on str(tip,1)+p_kod to (cur_dir+"tmp")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"diag_ort",dir_server+"diag_ort","DBF1")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
dbseek(arr_m[5],.t.)
do while human->k_data <= arr_m[6] .and. !eof()
  if iif(tip_f30== 1,glob_human[1] == human->kod_vr,.T.)
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    select TMP
    find ("1"+dtoc4(human->k_data))  // поиск по коду врача
    if !found()
      append blank
      tmp->p_kod := dtoc4(human->k_data)
      tmp->ddd   := human->k_data
      tmp->tip   := 1
    endif
    // блок по случаю
    // протезы
    k := human->KOL_PR1+human->KOL_PR2+human->KOL_PR3+;
         human->KOL_PR4+human->KOL_PR5+human->KOL_PR6
    if empty(k)
      tmp->p22 += human->KOL_CELNL
      tmp->p16 += human->KOL_MOSTP
    else
      tmp->p17 += human->KOL_PR1
      tmp->p18 += human->KOL_PR2
      tmp->p19 += human->KOL_PR3
      tmp->p20 += human->KOL_PR4
      tmp->p21 += human->KOL_PR5
      tmp->p22 += human->KOL_PR6
      tmp->p16 += k
    endif
    tmp->p53 ++
    // диагнозы
    for i := 1 to 7
      pole := "human->kod_diag"+iif(i==1,"",lstr(i))
      select DBF1
      find (&pole)
      if found() .and. between(dbf1->col_f39,54,60)
        pole := "tmp->p"+lstr(dbf1->col_f39)
        &pole := &pole + 1
      endif
    next
    //прочие
    tmp->kol_pos += human->kol_pos
    //проверяем на первичность
    select HUMAN
    t := human->(recno())
    t1 := year(human->k_data)
    t2 := human->kod_k
    skip -1
    fl_per := .T.
    do while t1 == year(human->k_data) .and. !bof()
      if t2 == human->kod_k
        fl_per := .F.
      endif
      skip -1
    enddo
    if fl_per
      tmp->kol_ppos ++
    endif
    human->(dbgoto(t))
    tmp->summa += human->cena
    if human->tip_usl == 1 //бесплатные
      tmp->bud_hum ++
      tmp->bud_prot := human->KOL_PR1 + human->KOL_PR2 + human->KOL_PR3+;
                       human->KOL_PR4 + human->KOL_PR5 + human->KOL_PR6
    endif
    if (arr := yes_f_30(0)) != NIL
      ++jh
      for i := 1 to len(arr)
        write_f30(arr[i])
      next
    endif
    @ 24,1 say lstr(++kh) color cColorSt2Msg
    if jh > 0
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jh) color cColorStMsg
    endif
  endif
  select HUMAN
  skip
enddo
close databases
rest_box(buf)
mybell()
//
use (fr_data) new
index on p_kod to (fr_data)
//
dbcreate(fr_titl, {{"god","N",4,0},;
                   {"tit1name","C",130,0},;
                   {"tit2name","C",130,0},;
                   {"tit3name","C",130,0}})
R_Use(dir_server+"organiz",,"ORG")
add_string(alltrim(org->name))
use (fr_titl) new
append blank
replace tit1name with alltrim(org->name)
replace tit2name with alltrim(arr_m[4])
if tip_f30 == 1 //по врачу
  replace tit3name with alltrim(glob_human[2])
endif
close databases
call_fr("mo_ort39.fr3")
return NIL

*

***** проверить больного по БД human и вернуть результат в виде массива
Static Function yes_f_30(par1)
Local i, j, k, s, arr, ret
Private t_mas := array(45)
arr := {}
select HU
find (str(human->(recno()),7))
do while hu->kod == human->(recno()) .and. !eof()
  otd->(dbGoto(hu->otd))
  k := hu->kol
  afill(lp,0)
  ___f_30(k)
  //УЕТ
  lp[63] := opr_uet(0)*k
  if lp[64]
    aadd(arr,aclone(lp))
  endif
  select HU
  skip
enddo
if len(arr) > 0
  do case
    case par1 == 0  // по учреждению
      ret := arr
  endcase
endif
return ret

*

*****
Function ___f_30(k)
Local _1
  lp[64] := .F.
  for j := 1 to 48
    t := "au"+lstr(j)
    t1 := &t
    _1 := (ascan(&t,{|x| x[2] == hu->u_kod}) > 0)
    if _1
      lp[64] := .T.
      lp[j+4]  := k
      if (j+4) == 41   //15.12.13
        lp[j+1] := k*(-1)   //38
      endif
      if (j+4) == 39   //15.12.13
        lp[j+2] := k*(-1)   //3
      endif
    endif
  next
return NIL

*

***** записать одну строку из массива в TMP-файл
Function write_f30(ar)
Local i, pole
for i := 1 to 52 //16
  // поля 16-22 не записывать
  if between(i,16,22)
   //
  else
    pole := "tmp->p"+lstr(i)
    &pole := &pole + ar[i]
  endif
next
tmp->yet := tmp->yet+ar[63]
return NIL

*

***** 02.12.12
Function forma_30_na(tip)
Static arr := {'Штифтово-культевая конструкция',;                        // 1
               'Коронки металлические штампованные',;                    // 2
               'Коронки цельнолитые',;                                   // 3
               'Коронки пластмассовые',;                                 // 4
               'Коронки металло-керамические',;                          // 5
               'Коронки "безметалловая керамика прессованная"',;         // 6
               'Коронки оксид-циркониевые',;                             // 7
               'Коронки одиночные на имплантах',;                        // 8
               'Коронки металло-акриловае',;                             // 9
               'Коронки комбинированные',;                               // 10
               'Коронки бюгельные',;   // РАЗРЫВ 6                       // 11
               'Мостовидные протезы - "коронки "',;          // 12
               'Мостовидные протезы - "коронки титановые"',;             // 13
               'Мостовидные протезы - "коронки металло-керамические"',;  // 14
               'Мостовидные протезы - "коронки оксид-циркониевые"',;     // 15
               'Мостовидные протезы - "коронки металло-акриловые"',;     // 16
               'Мостовидные протезы - "коронки штампованные"',;          // 17
               'Мостовидные протезы - "коронки цельнолитые"',;           // 18
               'Мостовидные протезы - "зубы литые"',;                    // 19
               'Мостовидные протезы - "зубы фасеток"',;                  // 20
               'Мостовидные протезы - "зубы металло-керамические"',;     // 21
               'Мостовидные протезы - "зубы металло-акриловые"',;        // 22
               'РЕЗЕРВ',;                                                // 23
               'Мостовидные протезы - "зубы пластмассовые"',;            // 24
               'Мостовидные протезы - "зубы цельнолитые"',;              // 25
               'Съёмные протезы полные',;                                // 26
               'Съёмные протезы полные с армированием',;                 // 27
               'Съёмные протезы "частично съёмные"',;                    // 28
               'Съёмные протезы "условно-съёмные"',;                     // 29
               'Съёмные протезы с метал.базисом',;                       // 30
               'Съёмные протезы паяные',;                                // 31
               'Съёмные протезы цельнолитые',;                           // 32
               'Съёмные протезы на замках',;                             // 33
               'Иммедиат протезы',;                                      // 34
               'Индивидуальные ложки',;                                  // 35
               'Избирательное шлифование зубов',;                        // 36
               'Снятие коронок',;                                        // 37
               'Консультации',;                                          // 38
               'Коррекции',;                                             // 39
               'РЕЗЕРВ',;                                                // 40
               'Починки протезов'}                                       // 41
Local l, sh := 0, f39_scr := savescreen(), i
Local HH := 58, name_file := "orto_ns"+stxt,;
arr_title := {;
"──────────┬──────────────────────────────────────────────────────────────────",;
"   Шифр   │                                                                  ",;
"  услуги  │                  Наименование услуги                             ",;
"──────────┴──────────────────────────────────────────────────────────────────"}
if tip == 1
  aeval(arr, {|x| sh := max(sh,len(x)) })
  do while (l := popup(T_ROW,T_COL-5,22,T_COL+sh-2,arr,l)) > 0
    restscreen(f39_scr)
    f1_forma_30_na(l,arr[l])
  enddo
  restscreen(f39_scr)
else
  sh := len(arr_title[1])
  WaitStatus("<Esc> - прервать формирование") ; mark_keys({"<Esc>"})
  reg_print := 2
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("Настройка Форма 39-ОРТОПЕДИЯ",sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  add_string("")
  for i := 1 to 41
    add_string("")
    add_string("==>> "+arr[i])
    add_string("")
    f1_forma_30_prn_na(i,arr[i])
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(tmp->u_shifr+"  "+tmp->u_name)
      skip
    enddo
    close databases
  next
  fclose(fp)
  restscreen(f39_scr)
  viewtext(name_file)
  restscreen(f39_scr)
endif
return NIL

*

*****
Function f1_forma_30_na(par,title)
Local nfile := dir_server+f30_nastr, name_sect
Local adbf, arr_usl, i
//
name_sect := f30_sect+lstr(iif(par>11,par+7,par))
arr_usl := GetIniSect(nFile, name_sect)
adbf := {;
     {"U_KOD"  ,    "N",      4,      0},;  // код услуги
     {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"U_NAME",     "C",     65,      0};   // наименование услуги
    }
dbcreate(cur_dir+"tmp", adbf)
R_Use(dir_server+"uslugi",,"USL")
use (cur_dir+"tmp") new
for i := 1 to len(arr_usl)
  select USL
  goto (val(arr_usl[i,2]))
  if !eof() .and. usl->kod > 0
    select TMP
    append blank
    tmp->u_kod := usl->kod
    tmp->u_shifr := usl->shifr
    tmp->u_name := usl->name
  endif
next
select TMP
index on str(u_kod,4) to (cur_dir+"tmpk")
index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
close databases
ob2_v_usl(,2,"Настройка формы 39: колонка "+title)
if f_Esc_Enter(1)
  arr_usl := {}
  use (cur_dir+"tmp") index (cur_dir+"tmpn") new alias TMP
  go top
  do while !eof()
    aadd(arr_usl, {tmp->u_shifr,lstr(tmp->u_kod)})
    skip
  enddo
  close databases
  SetIniSect(nFile, name_sect, arr_usl)
endif
return NIL

*

*****
Function get_nastr_orto_f30()
Local nf := dir_server+f30_nastr, fl, i
if (fl := file(nf))
  for j := 1 to 48
    t := "au"+lstr(j)
    &t := GetIniSect(nf,f30_sect+lstr(j))
  next
  fl := .f.
  for j := 1 to 48
    t := "au"+lstr(j)
    for i := 1 to len(&t)
      fl := .t.
      &t[i,2] := int(val(&t[i,2]))
    next
  next
endif
if !fl
  func_error(4,"Не произведена настройка формы 39-ОРТ")
endif
return fl

*

*****
Static Function cre_tmp_30(adbf)
Local i
for i := 1 to 60
  aadd(adbf,{ "p"+lstr(i),"N",7,0})
next
dbcreate(fr_data,adbf)
return NIL


*

*****
Function f1_forma_30_prn_na(par,title)
Local nfile := dir_server+f30_nastr, name_sect
Local adbf, arr_usl, i
//
name_sect := f30_sect+lstr(iif(par>11,par+7,par))
arr_usl := GetIniSect(nFile, name_sect)
adbf := {;
     {"U_KOD"  ,    "N",      4,      0},;  // код услуги
     {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"U_NAME",     "C",     65,      0};   // наименование услуги
    }
dbcreate(cur_dir+"tmp", adbf)
R_Use(dir_server+"uslugi",,"USL")
use (cur_dir+"tmp") new
for i := 1 to len(arr_usl)
  select USL
  goto (val(arr_usl[i,2]))
  if !eof() .and. usl->kod > 0
    select TMP
    append blank
    tmp->u_kod := usl->kod
    tmp->u_shifr := usl->shifr
    tmp->u_name := usl->name
  endif
next
select TMP
index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
return NIL

*

***** 18.11.14
Function or_vozvrat()
Local fl := .t., buf := save_row(maxrow()), sm := 0, HH := 52,;
      n_file := "platn.txt", arr_m, sh, sm_sn := 0, krvz, arr_dms,;
      sm_usl := 0
Local arr_title := {;
  "────────────────────────────────────────────────────────────┬───────────",;
  "                           Пациент                          │   Сумма   ",;
  "────────────────────────────────────────────────────────────┴───────────";
  }
sh := len(arr_title[1])
//if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
//  return NIL
//endif
if (arr_m := year_month()) == NIL
  return NIL
endif
//
mywait()
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string(center("ВОЗВРАТ оплаты нарядов",sh))
add_string(center("(по дате возврата)",sh))
add_string(center(arr_m[4],sh))
//tit_tip_usl(krvz,arr_dms,sh)
add_string("")
aeval(arr_title, {|x| add_string(x) })
//
R_Use(dir_server+"mo_pers",,"P2")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_ort",,"HUM_T")
R_Use(dir_server+"hum_oro",,"HUM_O")
go top
do while !eof()
  if between(hum_o->date_voz,arr_m[7],arr_m[8]) .and.;
                                 hum_o->SUM_VOZ > 0
                    // ascan(krvz,hum_o->tip_usl) > 0 .and.
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    select HUM_T
    goto (hum_o->kod)
    select KART
    goto (hum_t->kod_k)
    add_string(padr("--"+alltrim(kart->fio)+"  ВОЗВРАТ",59)+put_kope(hum_o->SUM_VOZ,12))
    sm_sn += hum_o->SUM_VOZ
    select P2
    goto (hum_t->kod_vr)
    add_string(padr("Врач "+p2->fio,50))
    add_string("")
  endif
  select HUM_O
  skip
enddo
add_string(replicate("─",sh))
add_string(padr("ИТОГО возврат: "    ,59)+put_kope(sm_sn ,12))
close databases
fclose(fp)
viewtext(n_file,,,,(sh>80),,,1)
rest_box(buf)
return NIL


***** 28.12.21
Function ort_priemshk()
Local fl := .t., buf := save_row(maxrow()), sm2 := 0, HH := 52,;
      n_file := "platn.txt", arr_m, sh, krvz, arr_dms,;
      sm_1 := 0, sm_2 := 0, sm_3 := 0, sm_bn := 0,;
      mas_op1 := {}, mas_op2 := {}, i, arr[2]
Local  arr_title := {;
  "───┬──────────────────────────────────────┬──────┬─────┬──────┬──────────┬───┬─────┬──────────────",;
  " N │           Ф.И.О. пациента            │Время │ Чек │Код П │  Сумма   │Тип│Наряд│      Врач    ",;
  "───┴──────────────────────────────────────┴──────┴─────┴──────┴──────────┴───┴─────┴──────────────"}
Local menu_opl := {{"ава",0},;
                   {"опл",1},;
                   {"нап",2}}
sh := len(arr_title[1])
//if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
//  return NIL
//endif
if (arr_m := year_month()) == NIL
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp"+sdbf)
  return NIL
endif
//
mywait()
dbcreate(cur_dir+"tmp", {{"kod",     "N",  4,  0},;
                 {"fio",     "C", 60,  0},;
                 {"chek",    "N", 10,  0},;
                 {"kod_hum", "N", 10,  0},;
                 {"operat",  "N", 10,  0},;
                 {"operatf", "C", 40,  0},;
                 {"FR_DATA", "D",  8,  0},;
                 {"fr_time", "N",  5,  0},;
                 {"t_flag",  "N",  1,  0},;
                 {"kod_vr",  "N",  4,  0},;
                 {"fio_vr",  "C", 60,  0},;
                 {"tip_op",  "N",  1,  0},;
                 {"nar_z",   "N",  5,  0},;
                 {"summa_bn","N", 12,  2},;
                 {"summaN",  "N", 12,  2},;
                 {"summa",   "N", 12,  2}})
use (cur_dir+"tmp") new
if yes_parol
  R_Use(dir_server+"base1",,"BASE1")
endif
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_ort",,"HUMAN")
R_Use(dir_server+"mo_pers",,"PERS")
R_Use_base("hum_oro")
go top
do while !eof()
  if !empty(ho->fr_data) .and. between(ho->fr_data,arr_m[7],arr_m[8])
    select HUMAN
    goto (ho->kod)
    select KART
    goto (human->kod_k)
    select TMP
    if ho->kod_reg == asc(kod_polzovat) .or. hb_user_curUser:IsAdmin() .or. hb_user_curUser:IsKontroler()
      append blank
      tmp->fio      := kart->fio
      tmp->chek     := ho->kv_cia
      tmp->kod_hum  := human->kod_k
      tmp->fr_data  := c4tod(ho->fr_data)
      tmp->fr_time  := ho->fr_time
      tmp->summa    := ho->cena_opl
      tmp->kod_vr   := human->kod_vr
      tmp->tip_op   := ho->tip_opl
      tmp->nar_z    := human->nar_z
      tmp->summa_bn := ho->sbank
      select PERS
      goto (human->kod_vr)
      tmp->fio_vr  := pers->fio
      tmp->operat  := ho->kod_reg
      tmp->t_flag := 0
      if yes_parol .and. ho->kod_reg > 0
        select BASE1
        goto (ho->kod_reg)
        if !eof() .and. !empty(base1->p1)
          tmp->operatf := alltrim(crypt(base1->p1,gpasskod))
        endif
      endif
    endif
  endif
  select HO
  skip
enddo
close databases
use (cur_dir+"tmp") new
index on operat to (cur_dir+"tmp_u") unique
go top
do while !eof()
  aadd(mas_op1,tmp->operat)
  aadd(mas_op2,tmp->operatf)
  skip
enddo
close databases
rest_box(buf)
// запрос по операторам
if len(mas_op1) == 0
  bkol_oper := 0
  func_error(4,"Нет информации "+arr_m[4])
elseif len(mas_op1) == 1
  bkol_oper := 1
else
  bkol_oper := popup_prompt(T_ROW,T_COL+5,1,mas_op2)
endif
if bkol_oper > 0
  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string(center("Р Е Е С Т Р",sh))
  add_string(center("регистрации чеков на оплату оказанных медицинских платных услуг населению",sh))
  R_Use(dir_server+"organiz",,"ORG")
  for i := 1 to perenos(arr,alltrim(org->name),sh)
    add_string(center(alltrim(arr[i]),sh))
  next
  add_string(center(arr_m[4],sh))
//  tit_tip_usl(krvz,arr_dms,sh)
  add_string("")
  aeval(arr_title, {|x| add_string(x) })
  sm2 := ii := 0
  use (cur_dir+"tmp") new
  index on fr_time to (cur_dir+"tmp_u") for operat == mas_op1[bkol_oper]
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    tt1 := inieditspr(A__MENUVERT, menu_opl, tmp->tip_op)
    add_string(str(++ii,3)+" "+;
               padr(tmp->fio,38)+;
               iif(tmp->summa_bn > 0,"БН","  ")+;
               padr(sectotime(tmp->fr_time),5)+" "+;
               padl(lstr(tmp->chek),5)+" "+;
               padl(lstr(tmp->kod_hum),6)+" "+;
               iif(tmp->summa_bn > 0,put_kope(tmp->summa_bn,10),put_kope(tmp->summa,10))+" "+;
               padr(alltrim(tt1),3)+" "+;
               padl(lstr(tmp->nar_z),5)+" "+;
               fam_i_o(tmp->fio_vr)+;
               iif(tmp->t_flag==1,"*"," "))
    if tmp->summa > tmp->summa_bn .and. tmp->summa_bn > 0
      add_string(str(++ii,3)+" "+;
                 padr(tmp->fio,38)+"  "+;
                 padr(sectotime(tmp->fr_time),5)+" "+;
                 padl(lstr(tmp->chek),5)+" "+;
                 padl(lstr(tmp->kod_hum),6)+" "+;
                 put_kope(tmp->summa-tmp->summa_bn,10)+" "+;
                 padr(alltrim(tt1),3)+" "+;
                 padl(lstr(tmp->nar_z),5)+" "+;
                 fam_i_o(tmp->fio_vr)+;
                 iif(tmp->t_flag==1,"*"," "))
    endif
    if tmp->tip_op == 0
      sm_1 += tmp->summa
    elseif tmp->tip_op == 1
      sm_2 += tmp->summa
    else
      sm_3 += tmp->summa
    endif
    sm2 += tmp->summa
    sm_bn += tmp->summa_bn
    select TMP
    skip
  enddo
  add_string(replicate("─",sh))
  add_string(padR("Итого: ",61)+put_kope(sm2,12))
  add_string(replicate("─",sh))
  for i := 1 to perenos(arr,"Всего на сумму: "+srub_kop(sm2,.t.),sh)
    add_string(arr[i])
  next
  if meK_bank == 1
    for i := 1 to perenos(arr,"из них в кассу: "+srub_kop(sm2-sm_bn,.t.),sh)
      add_string(arr[i])
    next
  endif
  //add_string(padR("Аванс:    ",61)+put_kope(sm_1,12))
  //add_string(padR("Оплата:   ",61)+put_kope(sm_2,12))
  //add_string(padR("Напылене: ",61)+put_kope(sm_3,12))
  add_string("")
  add_string("            Сдал мед.регистратор:              /"+alltrim(mas_op2[bkol_oper])+"/")
  add_string("")
  add_string("            Принял кассир:                                /"+alltrim(mek_kassir)+"/")
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,3)
endif
return NIL


*

***** 18.11.14 вызывается в "Ортопедия/Информация/Работа с кассой"
Function inf_fr_orto(k)
Static si1 := 1, si2 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Информация по ~кассе",;
                "Реестр",;
                "Возвраты"}
    mas_msg := {"Получение информации по состоянию кассового аппарата",;
                "Реестр регистрации чеков на оплату",;
                "Информация по возвратам"}
    mas_fun := {"inf_fr_orto(11)",;
                "inf_fr_orto(12)",;
                "inf_fr_orto(13)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    f1_inf_fr(2)
  case k == 12
    ort_priemshk()
  case k == 13
    or_vozvrat()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL
