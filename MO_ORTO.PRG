***** mo_orto.prg
#include "set.ch"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

*****
Function begin_task_orto()
Static n_zapusk := 0
if n_zapusk == 0
  ++n_zapusk
  Public smvzros_reb
  Public menu_okb := {{"платный    ",OU_PLAT  },;
                      {"бесплатный ",OU_B_PLAT},;
                      {"ДМС        ",OU_D_SMO },;
                      {"взаимозачет",OU_PR_VZ }}
  Public menu_otip := {{"платная    ",OU_PLAT  },;
                       {"бесплатная ",OU_B_PLAT},;
                       {"ДМС        ",OU_D_SMO },;
                       {"взаимозачет",OU_PR_VZ }}
endif
if copy_Tools_Ini()
  Tools_Ini_OMS(1,0,0)
  Tools_Ini_Orto(1,0,0)
else
  return .f.
endif
if glob_kassa == 1
  //if hb_FileExists("__kassa_.log") .and. filesize("__kassa_.log") > 5000000
  //  delete file __kassa_.log
  //endif
  f5_sist_fr(1)
endif
return .t.

*

*****
Function orto_diag()
Local t_arr[BR_LEN], ;
      mtitle := "Справочник ортопедических диагнозов"
Private mm_col_f39 := {;
  {"00 -- нет привязки --",0},;
  {"54 Патология твёрдых тканей",54},;
  {"55 Патологическая стираемость",55},;
  {"56 Частичное отсутствие зубов",56},;
  {"57 Полное отсутствие зубов",57},;
  {"58 Болезни пародонта",58},;
  {"59 Аномалии и деформации",59},;
  {"60 Сложно-челюстно-лицевая патология",60};
 }
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
t_arr[BR_OPEN] := {|| f1_orto_diag(,,"open") }
t_arr[BR_CLOSE] := {|| dbCloseAll() }
t_arr[BR_SEMAPHORE] := mtitle
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := mtitle
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_ARR_BROWSE] := {,,,,.t.}
t_arr[BR_COLUMN] := {{ " Шифр", {|| dbf1->shifr } },;
                     { center("Наименование",40), {|| padr(dbf1->name,40) } },;
                     { padr("Колонка формы 39",20), {|| padr(inieditspr(A__MENUVERT,mm_col_f39,dbf1->col_f39),20) } }}
t_arr[BR_EDIT] := {|nk,ob| f1_orto_diag(nk,ob,"edit") }
edit_browse(t_arr)
return NIL

*****
Function f1_orto_diag(nKey,oBrow,regim,lrec)
Local ret := -1
Local buf, fl := .f., rec, rec1, k := 17, tmp_color
do case
  case regim == "open"
    G_Use(dir_server+"diag_ort",dir_server+"diag_ort","DBF1")
    go top
    if (ret := !eof()) .and. lrec != NIL .and. lrec > 0
      goto (lrec)
    endif
  case regim == "choice" .and. nKey == K_SPACE
    ret := 1
  case regim == "edit"
    do case
      case nKey == K_INS .or. (nKey == K_ENTER .and. !empty(dbf1->name))
        save screen to buf
        if nkey == K_INS .and. !fl_found
          colorwin(pr1+3,pc1,pr1+3,pc2,"N/N","W+/N")
        endif
        Private mshifr, mname, mcol_f39, m1col_f39, gl_area := {1,0,23,79,0}
        mshifr := if(nKey == K_INS, space(6), dbf1->shifr)
        mname := if(nKey == K_INS, space(40), dbf1->name)
        m1col_f39 := if(nKey == K_INS, 0, dbf1->col_f39)
        tmp_color := setcolor(cDataCScr)
        mcol_f39 := inieditspr(A__MENUVERT,mm_col_f39,m1col_f39)
        box_shadow(k,pc1+1,21,pc2-1,,;
                       if(nKey == K_INS,"Добавление","Редактирование"),;
                       cDataPgDn)
        setcolor(cDataCGet)
        @ k+1,pc1+3 say "Шифр" get mshifr ;
                    valid {|g| f2_orto_diag(g,nKey) }
        @ k+2,pc1+3 say "Наименование" get mname
        @ k+3,pc1+3 say "Привязка к форме 39" get mcol_f39 ;
                    reader {|x|menu_reader(x,mm_col_f39,A__MENUVERT,,,.f.)}
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. !emptyany(mshifr,mname) .and. f_Esc_Enter(1)
          if nKey == K_INS
            fl_found := .t.
            AddRecN()
          else
            G_RLock(forever)
          endif
          replace dbf1->shifr with mshifr, dbf1->name with mname,;
                  dbf1->col_f39 with m1col_f39
          UNLOCK
          COMMIT
          oBrow:goTop()
          find (mshifr)
          ret := 0
        elseif nKey == K_INS .and. !fl_found
          ret := 1
        endif
        setcolor(tmp_color)
        restore screen from buf
      case nKey == K_DEL .and. !empty(dbf1->name) .and. f_Esc_Enter(2)
        DeleteRec()
        oBrow:goTop()
        ret := 0
        if eof()
          ret := 1
        endif
    endcase
endcase
return ret

*****
Function f2_orto_diag(get,nKey)
Local fl := .t., rec := 0
if mshifr != get:original
  rec := recno()
  find (mshifr)
  if found()
    fl := func_error(4,"Данный шифр уже присутствует в справочнике!")
  endif
  goto (rec)
  if !fl
    mshifr := get:original
  endif
endif
return fl

*

*****
Function f_prich_pol()
popup_edit(dir_server+"ort_brk",T_ROW,T_COL-10,T_ROW+11,,1,,;
           "fdel_prich",,,,,,"Причины поломок протезов",col_tit_popup)
return NIL

*****
Function fdel_prich(mkod)
Local fl := .t., buf := save_row(maxrow())
stat_msg("Ждите! Производится проверка на допустимость удаления данной причины")
G_Use(dir_server+"hum_ort",,"HU")
Locate for hu->PRICH_POL == mkod progress
fl := !found()
Use
if !fl
  func_error(4,"Данная причина поломок встречается в других базах данных. Удаление запрещено!")
endif
rest_box(buf)
return fl

*

*****
Function edit_ort(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j, buf
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Согласование ~услуг",;
                "Приведенные расходуемые ~материалы",;
                "~Нормы расхода на каждую укрупненную услугу",;
                "Печать норм расходов-1",;
                "Печать норм расходов-2";
               }
    mas_fun := {"edit_ort(12)",;
                "edit_ort(13)",;
                "edit_ort(14)",;
                "edit_ort(15)",;
                "edit_ort(16)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 12
    sin_ysl()
  case k == 13
    spr_ort_mat()
  case k == 14
    spr_t_orto()
  case k == 15
    oo_spmater()
  case k == 16
    oo1spmater()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

*

*****
Function spr_t_orto()
Static mas_edit := { "~Просмотр",;
                     "~Редактирование",;
                     "~Добавление",;
                     "~Удаление"}
Local i := 1, k, buf := savescreen()
T_ROW := T_ROW - 5
do while i > 0
  // добавление
  if (i := popup_prompt(T_ROW, T_COL-5, i, mas_edit,,,,.f.)) == A__APPEND
    dop_or_menu(A__APPEND)
  elseif EQUALANY(i,1,2) .and. (k := input_t_orto(T_ROW+i+1,T_COL-10)) != NIL
    dop_or_menu(i,k[1])
  elseif i != 0 .and. (k := input_t_orto(T_ROW+i+1,T_COL-10)) != NIL
    MT_use_base('tip_orto')
    if fdel_t_orto(k[1]) .and. f_Esc_Enter(2)
      MT_use_base('ortoped1')
      index on str(kod_menu,4) to (cur_dir+"tmp1")
      find (str(k[1],4))
      do while k[1] == kod_menu .and. !eof()
        G_RLock(forever)
        delete
        UnLock
        skip
      enddo
      select TIP_ORTO
      goto k[1]
      deleterec()
    endif
    close databases
  endif
enddo
restscreen(buf)
return NIL

*****
Function dop_or_menu(tip,kod)
Local mm_tmp := {}, buf, a_default, len_orto := 0, mas_pit :={}
Local mm_tehnik := {{"ТЕХНИКОВ",0},;
                    {"ВРАЧЕЙ",1}}
DEFAULT kod TO 0
buf := save_row(maxrow()) ; mywait()
close databases
delete file tmp.dbf
aadd(mm_tmp, {"name","C",40,0,NIL,NIL,;
                  space(80),NIL,"Наименование услуги"})
aadd(mm_tmp, {"tip","N",1,0,NIL,;
             {|x|menu_reader(x,mm_tehnik,A__MENUVERT)},;
             1,{|x|inieditspr(A__MENUVERT,mm_tehnik,x)},;
            'Нормы расхода предназначены для '})
aadd(mm_tmp, {"e_1","C",1,0,NIL,;
              NIL,;
              " ",NIL,;
              " ",,;
              {||.f.} })
aadd(mm_tmp, {"e_2","C",1,0,NIL,;
              NIL,;
              " ",NIL,;
              "Нормы расхода материалов на одну услугу.",,;
              {||.f.} })
MT_use_base('ortoped')
index on name to (cur_dir+"tmp2")
go top
lOldDeleted := SET(_SET_DELETED, .F.)
do while !eof()
  aadd(mm_tmp, {"v_"+lstr(recno()),"N",7,3,NIL,;
              NIL,;
              0,NIL,;
              padr(name,65),, })
  ++len_orto
  aadd(mas_pit,recno())
  skip
enddo
SET(_SET_DELETED, lOldDeleted)
init_base(cur_dir+"tmp",,mm_tmp,0)
use (cur_dir+"tmp") new
if tip != A__APPEND
  append blank
  MT_use_base('tip_orto')
  MT_use_base('ortoped1')
  index on str(kod_menu,4)+str(kod_ort,4) to (cur_dir+"tmp1")
  select TIP_ORTO
  goto kod
  //G_RLock(forever)
  tmp->name := tip_orto->name
  tmp->tip  := tip_orto->tip
  //UnLock
  select ORTOPED1
  for i := 1 to len_orto
    find (str(kod,4)+str(mas_pit[i],4))
    s := "tmp->v_"+lstr(mas_pit[i])
    G_RLock(forever)
    &s := ortoped1->massa
    UnLock
  next
endif
close databases
if f_edit_spr(tip,mm_tmp,"настройке программы","g_use(cur_dir+'tmp',,,.t.,.t.)",0,1) > 0
  MT_use_base('ortoped')
  MT_use_base('ortoped1')
  index on str(kod_menu,4)+str(kod_ort,4) to (cur_dir+"tmp1")
  MT_use_base('tip_orto')
  use (cur_dir+"tmp") new
  select TIP_ORTO
  if tip == 3
    addrecn()
    kod := recno()
  else
    goto kod
  endif
  G_RLock(forever)
  tip_orto->name := tmp->name
  tip_orto->tip := tmp->tip
  UnLock
  select ORTOPED1
  for i := 1 to len_orto
    find (str(kod,4)+str(mas_pit[i],4))
    if !found()
      append blank
    endif
    G_RLock(forever)
    s := "tmp->v_"+lstr(mas_pit[i])
    ortoped1->massa := &s
    ortoped1->kod_ort := mas_pit[i]
    ortoped1->kod_menu := tip_orto->(recno())
    UnLock
  next
endif
close databases
rest_box(buf)
return NIL

*****
Function fdel_t_orto(k)
Local fl := .t., buf := save_row(maxrow())
return fl

*****
FUNCTION input_t_orto(r,c,mkod,top_bot)
Static st := 0
Local k, r1, r2, tmp_select
DEFAULT mkod TO st, top_bot TO .t.  // т.е. привязка сверху
if top_bot
  r1 := r ; r2 := maxrow()-2
else
  r2 := r-1 ; r1 := r2-8
endif
if (k := popup_edit(dir_server+"tip_orto",r1,c,r2,;
                    mkod,4,,,,,,,top_bot,"Услуги","B/BG")) != NIL
  st := k[1]
  if !top_bot .and. st != mkod
    tmp_select := select()
    G_Use(dir_server+"tip_orto",,"ORT")
    goto (st)
    ort->(dbCloseArea())
    if tmp_select > 0
      select (tmp_select)
    endif
    keyboard chr(K_ENTER)
  endif
endif
return k

*

***** 16.11.16
Function spr_ort_mat()
Local t_arr[BR_LEN], mtitle := "Редактирование справочника материалов ОРТОПЕДИЯ"
Local str_sem, tip_gr
Private mm_orto_mat := {;
  {"Нет привязки",0},;
  {"Бухгалтерия",1},;
  {"Руководство",2};
 }
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 17
t_arr[BR_RIGHT] := 75
t_arr[BR_OPEN] := {|| f1_orto_mat(,,"open") }
t_arr[BR_CLOSE] := {|| dbCloseAll() }
t_arr[BR_SEMAPHORE] := mtitle
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := mtitle
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_ARR_BROWSE] := {,,,,.t.}
t_arr[BR_COLUMN] := {{ center("Наименование материала",40), {|| padr(dbf1->name,40) } },;
                     { padr("  Документ",12), {|| padr(inieditspr(A__MENUVERT,mm_orto_mat,dbf1->kod),12) } }}
t_arr[BR_EDIT] := {|nk,ob| f1_orto_mat(nk,ob,"edit") }
edit_browse(t_arr)
return NIL

***** 16.11.16
Function f1_orto_mat(nKey,oBrow,regim,lrec)
Local ret := -1
Local buf, fl := .f., rec, rec1, k := 17, tmp_color
do case
  case regim == "open"
    G_Use(dir_server+"ortoped",,"DBF1")
    index on upper(name) to tmp
    go top
    if (ret := !eof()) .and. lrec != NIL .and. lrec > 0
      goto (lrec)
    endif
  case regim == "choice" .and. nKey == K_SPACE
    ret := 1
  case regim == "edit"
    do case
      case nKey == K_INS .or. (nKey == K_ENTER .and. !empty(dbf1->name))
        save screen to buf
        if nkey == K_INS .and. !fl_found
          colorwin(pr1+3,pc1,pr1+3,pc2,"N/N","W+/N")
        endif
        Private mshifr, mname, mcol_f39, m1col_f39, gl_area := {1,0,23,79,0}
        mname := if(nKey == K_INS, space(80), dbf1->name)
        m1col_mat := if(nKey == K_INS, 0, dbf1->kod)
        tmp_color := setcolor(cDataCScr)
        mcol_mat := inieditspr(A__MENUVERT,mm_orto_mat,m1col_mat)
        box_shadow(k,pc1+1,20,pc2-1,,;
                       if(nKey == K_INS,"Добавление","Редактирование"),;
                       cDataPgDn)
        setcolor(cDataCGet)
        @ k+1,pc1+3 say "Наименование" get mname pict "@S40"
        @ k+2,pc1+3 say "Отношение к отчёту" get mcol_mat ;
                    reader {|x|menu_reader(x,mm_orto_mat,A__MENUVERT,,,.f.)}
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. !emptyany(mname) .and. f_Esc_Enter(1)
          if nKey == K_INS
            fl_found := .t.
            AddRecN()
          else
            G_RLock(forever)
          endif
          replace dbf1->name with mname,;
                  dbf1->kod with m1col_mat
          UNLOCK
          COMMIT
          oBrow:goTop()
          find (upper(mname))
          ret := 0
        elseif nKey == K_INS .and. !fl_found
          ret := 1
        endif
        setcolor(tmp_color)
        restore screen from buf
      case nKey == K_DEL
        func_error(4,"Удаление запрещено!")
        ret := 0
    endcase
endcase
return ret

*****
Function f_orto_uva()
Local t_arr[BR_LEN], mtitle := "Услуги, где не вводится врач (техник/медсестра)"
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := T_COL-20
t_arr[BR_RIGHT] := t_arr[BR_LEFT] + 52
t_arr[BR_OPEN] := {|| f1_orto_uva(,,"open") }
t_arr[BR_CLOSE] := {|| dbCloseAll() }
t_arr[BR_SEMAPHORE] := mtitle
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := mtitle
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_ARR_BROWSE] := {,,,,.t.}
t_arr[BR_COLUMN] := {{ "   Шифр", {|| dbf1->shifr } },;
          { "Врача нет?",   {|| padc(if(dbf1->kod_vr==1,"**",""),10) } },;
          { "Техника нет?", {|| padc(if(dbf1->kod_as==1,"**",""),12) } },;
          { "М/с нет?",     {|| padc(if(dbf1->kod_ms==1,"**",""),8)  } }}
t_arr[BR_EDIT] := {|nk,ob| f1_orto_uva(nk,ob,"edit") }
edit_browse(t_arr)
return NIL

*****
Function f1_orto_uva(nKey,oBrow,regim,lrec)
Local ret := -1, mm_da_net := {{"да ",0},{"НЕТ",1}}
Local buf, fl := .f., rec, rec1, k := 16, tmp_color
do case
  case regim == "open"
    G_Use(dir_server+"orto_uva",dir_server+"orto_uva","DBF1")
    go top
    if (ret := !eof()) .and. lrec != NIL .and. lrec > 0
      goto (lrec)
    endif
  case regim == "edit"
    do case
      case nKey == K_INS .or. (nKey == K_ENTER .and. !empty(dbf1->shifr))
        save screen to buf
        if nkey == K_INS .and. !fl_found
          colorwin(pr1+3,pc1,pr1+3,pc2,"N/N","W+/N")
        endif
        Private gl_area := {1,0,23,79,0},;
          mshifr := if(nKey == K_INS, space(10), dbf1->shifr),;
          mkod_vr, m1kod_vr := if(nKey == K_INS, 0, dbf1->kod_vr),;
          mkod_as, m1kod_as := if(nKey == K_INS, 0, dbf1->kod_as),;
          mkod_ms, m1kod_ms := if(nKey == K_INS, 0, dbf1->kod_ms)
        tmp_color := setcolor(cDataCScr)
        mkod_vr := inieditspr(A__MENUVERT, mm_da_net, m1kod_vr)
        mkod_as := inieditspr(A__MENUVERT, mm_da_net, m1kod_as)
        mkod_ms := inieditspr(A__MENUVERT, mm_da_net, m1kod_ms)
        box_shadow(k,pc1+1,21,pc2-1,,;
                       if(nKey == K_INS,"Добавление","Редактирование"),;
                       cDataPgDn)
        setcolor(cDataCGet)
        @ k+1,pc1+3 say "Шифр услуги (шаблон)" get mshifr ;
                    valid {|g| f2_orto_diag(g,nKey) }
        @ k+2,pc1+3 say "Вводится код врача?" get mkod_vr ;
               reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
        @ k+3,pc1+3 say "Вводится код техника?" get mkod_as ;
               reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
        @ k+4,pc1+3 say "Вводится код медсестры?" get mkod_ms ;
               reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. !empty(mshifr) ;
                      .and. !emptyall(m1kod_vr,m1kod_as,m1kod_ms) .and. f_Esc_Enter(1)
          if nKey == K_INS
            fl_found := .t.
            AddRecN()
          else
            G_RLock(forever)
          endif
          replace dbf1->shifr with mshifr, dbf1->kod_vr with m1kod_vr,;
                  dbf1->kod_as with m1kod_as, dbf1->kod_ms with m1kod_ms
          UNLOCK
          COMMIT
          oBrow:goTop()
          find (mshifr)
          ret := 0
        elseif nKey == K_INS .and. !fl_found
          ret := 1
        endif
        setcolor(tmp_color)
        restore screen from buf
      case nKey == K_DEL .and. !empty(dbf1->shifr) .and. f_Esc_Enter(2)
        DeleteRec()
        oBrow:goTop()
        ret := 0
        if eof()
          ret := 1
        endif
    endcase
endcase
return ret

*
*

//05.09.18
***** Причины поломок протезов
Function O_pr_polom()
Local buf := save_row(maxrow()), sh, HH := 58, skol, arr, arr_title,;
      begin_date, end_date, name_file := "orto_pp"+stxt
arr_title := {;
"────────────────────────────────────────┬──────────────",;
"      Причины поломок протезов          │  Количество  ",;
"────────────────────────────────────────┴──────────────"}
if (arr := year_month()) == NIL
  return NIL
endif
mywait()
begin_date := arr[5]
end_date := arr[6]
dbcreate(cur_dir+"tmp", {;
   {"KOD",        "N",      3,      0},;  // код поломки
   {"KOL",        "N",     10,      0};   // кол-во услуг
  })
use (cur_dir+"tmp") new
index on str(kod,3) to (cur_dir+"tmp")
R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
select HUMAN
dbseek(dtos(begin_date),.t.)
do while human->k_data <= end_date .and. !eof()
  if human->PRICH_POL > 0
    select TMP
    find (str(human->PRICH_POL,3))
    if !found()
      append blank
      tmp->kod := human->PRICH_POL
    endif
    tmp->kol ++
  endif
  select HUMAN
  skip
enddo
if tmp->(lastrec()) == 0
  func_error(4,"Нет информации")
else
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  sh := len(arr_title[1])
  add_string("")
  add_string(center("Причины поломок протезов",sh))
  add_string(center(arr[4],sh))
  add_string(center("[ по дате окончания лечения ]",sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  G_Use(dir_server+"ort_brk",,"PP")
  select TMP
  set relation to kod into PP
  index on upper(pp->name) to (cur_dir+"tmp")
  skol := 0
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(padr(pp->name,40)+str(tmp->kol,10))
    skol += tmp->kol
    skip
  enddo
  add_string(replicate("─",sh))
  add_string(space(40)+str(skol,10))
  close databases
  fclose(fp)
  viewtext(name_file)
endif
close databases
rest_box(buf)
return NIL

*

//05.09.18
***** Список больных по поломкам
Function O_sb_pr_polom()
Static sk
Local buf := save_row(maxrow()), sh, HH := 58, skol, arr, arr_title,;
      k, begin_date, end_date, name_file := "orto_pps"+stxt
arr_title := {;
"──────────────────────────────────────────────────┬──────────────┬─────",;
"                                                  │  Наряд-заказ │Таб.№",;
"      Ф.И.О. больного                             ├─────┬────────┤врача",;
"                                                  │  №  │  дата  │     ",;
"──────────────────────────────────────────────────┴─────┴────────┴─────"}
if (k := popup_edit(dir_server+"ort_brk",;
                   T_ROW,T_COL-5,maxrow()-2,sk,PE_RETURN,,,,,,,,;
                   "Причины поломок протезов",col_tit_popup)) == NIL
  return NIL
endif
sk := k[1]
if (arr := year_month()) == NIL
  return NIL
endif
mywait()
begin_date := arr[5]
end_date := arr[6]
dbcreate(cur_dir+"tmp", {;
   {"KOD",        "N",      7,      0};  // код наряда
  })
use (cur_dir+"tmp") new
R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","HUMAN")
select HUMAN
dbseek(dtos(begin_date),.t.)
do while human->k_data <= end_date .and. !eof()
  if human->PRICH_POL == k[1]
    select TMP
    append blank
    tmp->kod := human->(recno())
  endif
  select HUMAN
  skip
enddo
if tmp->(lastrec()) == 0
  func_error(4,"Нет информации")
else
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  sh := len(arr_title[1])
  add_string("")
  add_string(center("Список больных по поломке",sh))
  add_string(center('"'+alltrim(k[2])+'"',sh))
  add_string(center(arr[4],sh))
  add_string(center("[ по дате окончания лечения ]",sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+"mo_pers",,"PERSO")
  R_Use(dir_server+"kartotek",,"KART")
  select HUMAN
  set order to 0
  set relation to kod_k into KART
  select TMP
  set relation to kod into HUMAN
  index on upper(kart->fio)+str(human->nar_z,5) to (cur_dir+"tmp")
  skol := 0
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(padr(kart->fio,50)+str(human->nar_z,6)+;
               " "+date_8(human->data)+put_val(ret_tabn(human->kod_vr),6))
    skol ++
    select TMP
    skip
  enddo
  add_string(replicate("─",sh))
  add_string(center("Итого нарядов: "+lstr(skol),sh))
  close databases
  fclose(fp)
  viewtext(name_file,,,,(sh>80),,,2)
endif
close databases
rest_box(buf)
return NIL

*

*****
Function opl_kart(mkod_human,mkod_lpu)
// mkod_human - код по БД human
Local adbf, buf := savescreen(), j := 0, tmp_color := setcolor(color1), ;
      l_color, mtitle, i, k
mywait()
G_Use(dir_server+"hum_ort",,"HUMAN")
goto (mkod_human)
//
Private fl_found, str_find, muslovie, mvu[3,2], mcena_opl := 0, flag_1 := .t.
afillall(mvu,0)
str_find := str(human->(recno()),7)
muslovie := "ho->kod == human->(recno())"
arr_blk := {{| | FindFirst(str_find)},;
            {| | FindLast(str_find)},;
            {|n| SkipPointer(n, muslovie)},;
            str_find,muslovie;
           }
R_Use(dir_server+"mo_pers",,"PERSO")
setcolor("BG/B")
l_color := "W+/B,W+/W,BG+/B,W+/BG,G+/B,W+/G,GR+/B,W+/GR"
use_base("hum_oro")
find (str_find)
if (fl_found := found())
  dbeval({|| mcena_opl += ho->cena_opl },,{|| ho->kod==human->(recno())})
  find (str_find)
  keyboard chr(K_RIGHT)
else
  keyboard chr(K_INS)
endif
setcolor(color1)
cls
@ 0,0 say padc("Оплата ортопед.услуг для < "+alltrim(glob_k_fio)+" >",80) color "W+/BG"
@ 1,1 say "Наряд-заказ № "+lstr(human->nar_z)+" от "+date_8(human->data)+"г." color "G+/B"
mtitle := f_srok_lech(human->n_data,human->k_data)
Alpha_Browse(2,0,maxrow()-2,79,"fe_o_kopl",color1,mtitle,col_tit_popup,;
             .f.,.t.,arr_blk,"f1e_o_kopl","f2e_o_kopl",,;
             {'═','░','═',l_color,.t.,180} )
// были добавлены строки оплаты
if yes_parol .and. (mvu[1,1] > 0 .or. mvu[2,1] > 0 .or. mvu[3,1] > 0) ;
             .and. hb_FileExists(dir_server+"mo_opern"+sdbf)
  k := glob_task+iif(human->tip_usl==OU_B_PLAT,100,0)
  close databases
  if G_Use(dir_server+"mo_opern",dir_server+"mo_opern","OP")
    for i := 1 to 3
      if mvu[i,1] > 0
        write_work_oper(k,OPER_USL,i,mvu[i,1],mvu[i,2],.f.)
      endif
    next
  endif
endif
close databases
setcolor(tmp_color)
restscreen(buf)
return mcena_opl

***** 19.07.14
Function fe_o_kopl(oBrow)
Local oColumn, blk_color
local tip_bank := {" бн ","МИР","VISA","MаCа"}

blk_color := {|| {{1,2},{3,4},{5,6},{7,8}}[ho->tip_usl+1] }
if glob_kassa == 1
  //oColumn := TBColumnNew("  ",{|| iif(ho->sbank > 0, "бн","  ") })
  oColumn := TBColumnNew("     ",{|| iif(ho->sbank < 1, "    ",;
  tip_bank[ho->fr_tipkart+1]+iif(ho->sbank == ho->cena_opl," ","Н")) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("    ",{|| {"    ",str(ho->kv_cia,4)," "};
                        [ho->is_kas+1]})
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
else
  oColumn := TBColumnNew("№ кв.;книжки",{|| put_val(ho->n_kvit,5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  //
  oColumn := TBColumnNew("№ кви-;танции",{|| put_val(ho->kv_cia,6) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
endif
//
oColumn := TBColumnNew("  Дата; оплаты",{|| date_8(c4tod(ho->pdate)) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" Сумма; оплаты",{|| put_kop(ho->cena_opl,9) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" ",{|| {"П"," ","з","Д"}[ho->tip_usl+1] })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("  Вид;платеж",{|| {" аванс ","ОПЛАТА ","напыл-е","."}[ho->tip_opl+1] })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" Регистратор",{|| f0e_o_kopl(ho->kod_reg) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Примечание",{|| ho->prim })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
if glob_kassa == 1
  oColumn := TBColumnNew(" Сумма;возврата",{|| put_kop(ho->sum_voz,9) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
endif
//
if glob_kassa == 1
  status_key("^<Esc>^-выход; ^<Enter>^-ред-ие; ^<Ins>^-добавление; ^<Del>^-удаление; ^<F10>^-печать чека")
else
  status_key("^<Esc>^ - выход; ^<Enter>^ - ред-ие; ^<Ins>^ - добавление; ^<Del>^ - удаление")
endif
return NIL


*****
Function f0e_o_kopl(reg)
Local ret := "", t_order

if reg > 0
  t_order := select()
  R_Use(dir_server+"base1",,"BASE1")
  goto (reg)
  if !eof() .and. !empty(base1->p1)
    ret := alltrim(crypt(base1->p1,gpasskod))
  endif
  base1->(dbCloseArea())
  select(t_order)
endif
return padr(ret,12)

*****
Function f1e_o_kopl()
LOCAL nRow := ROW(), nCol := COL()
if flag_1
  f3e_o_kopl()
  flag_1 := .f.
endif
@ nRow, nCol SAY ""
return NIL

*****
Function f3e_o_kopl()
@ 23,2 say padl("Итого: "+lstr(mcena_opl,11,2),20) color "W+/N"
return NIL

***** 05.07.18
Function f2e_o_kopl(nKey,oBrow)
Static skod_vr := 0, sn_kvit := 0
LOCAL flag := -1, buf := savescreen(), fl := .f., rec, ;
      i1, k, j := 0, s := 0, so := 0, adbf, adbf1, tmp_color := setcolor(), ;
      mrec_ho := ho->(recno()), tmp_help := help_code, ln_chek := 0, ;
      pos_read := 0, k_read := 0, count_edit := 0,;
      mi_post, mphone_m, maddress, tip_kart := 2, tip_oplatFR := 4,;
      fr_zavodnomer := "",;
      menu_opl := {{"аванс               ",0},;
                   {"окончательная оплата",1},;
                   {"напыление           ",2}}
Local err_close := "Данный лист учета ЗАКРЫТ. Доступ разрешен только администратору системы!"
Local t_hum_rec, kart_kod, hum_o_kod, t_select
//
Private r1 := 12
Private ldate_voz, lsum_voz, lfr_data, lfr_time
if equalany(nKey,K_INS,K_ENTER,K_DEL)
  if !ver_pub_date(human->k_data,.t.)
    return flag
  endif
endif
// 00.07.17 поиск номера или эл.почты
t_hum_rec := ho->(recno())
kart_kod  := human->kod_k
hum_o_kod := human->(recno())
mi_post   := space(30)
mphone_m  := space(11)
t_select := select()
select HO
do while ho->kod == hum_o_kod  .and. !eof()
  if len(alltrim(ho->i_post)) > 4
    mi_post := ho->i_post
  endif
  skip
enddo
goto (t_hum_rec)
// поиск телефона
R_Use(dir_server+"kartote_",,"KR_") //00.02.17
goto(human->kod_k)
mphone_m := kr_->phone_m
kr_->(dbCloseArea())
mphone_m := TransformPhone( mphone_m )
//выбираем приоритетом телефон
if len(alltrim(mphone_m)) < 11
  maddress := mi_post
else
  maddress := mphone_m
endif
select(t_select)
//
do case
  case nKey == K_INS .or. (nKey == K_ENTER .and. ho->kod > 0)
    if nKey == K_INS .and. !fl_found
      colorwin(6,0,6,79,"B/B","W+/W")
      colorwin(6,0,6,79,"B/B","W+/BG")
      colorwin(6,0,6,79,"B/B","W+/G")
      colorwin(6,0,6,79,"B/B","W+/GR")
    endif
    Private mtip_opl, m1tip_opl := if(nKey == K_INS, 0, ho->tip_opl),;
            mtip_usl, m1tip_usl := if(nKey == K_INS, human->tip_usl, ho->tip_usl),;
            mpr_smo, m1pr_smo := if(nKey == K_INS, human->pr_smo, ho->pr_smo),;
            mpolis := if(nKey == K_INS, space(25), ho->d_polis),;
            mGP_NOMER := if(nKey == K_INS, space(16), ho->GP_NOMER),;
            mGP_DATE := if(nKey == K_INS, ctod(""), ho->GP_DATE),;
            mn_kvit := if(nKey == K_INS, sn_kvit, ho->n_kvit),;
            mkv_cia := if(nKey == K_INS, 0, ho->kv_cia),;
            mdate_o := if(nKey == K_INS, sys_date, c4tod(ho->pdate)),;
            mkod_vr := if(nKey == K_INS, skod_vr, ho->kod_reg),;
            mtabn_vr := 0, mvrach := space(35), ;
            mkod_as := 0, mkod_ms := 0,;
            mstoim := if(nKey == K_INS, 0, ho->cena_opl),;
            mprim := if(nKey == K_INS, space(15), ho->prim),;
            mplat_fio := if(nKey == K_INS, space(40), human->plat_fio),;
            mplat_inn := if(nKey == K_INS, space(12), human->plat_inn),;
            mplat_adres  := space(50),; // адрес плательщика
            mplat_pasport :=  space(15),;  // документ плательщика
            gl_area := {1,0,23,79,0}
    mtip_opl := inieditspr(A__MENUVERT, menu_opl, m1tip_opl)
    mtip_usl := inieditspr(A__MENUVERT, menu_okb, m1tip_usl)
    if m1tip_usl == OU_D_SMO
      mpr_smo := inieditspr(A__POPUPMENU, dir_server+"p_d_smo", m1pr_smo)
    elseif m1tip_usl == OU_PR_VZ
      mpr_smo := inieditspr(A__POPUPMENU, dir_server+"p_pr_vz", m1pr_smo)
    endif
    if mkod_vr > 0
      select PERSO
      goto (mkod_vr)
      mvrach := padr(perso->fio,35)
      mtabn_vr := perso->tab_nom
    endif
    box_shadow(r1,0,23,79,color8,;
               iif(nKey == K_INS,"Добавление","Редактирование")+;
                       " строки оплаты ортопедической услуги","RB+/B")
    do while .t.
      setcolor(cDataCGet)
      @ r1+2,2 say "Категория больного" get mtip_usl ;
               reader {|x|menu_reader(x,menu_okb,A__MENUVERT,,,.f.)} ;
               valid {|g,o| val_tip_usl(g,o,r1+2) }
      @ r1+2,37 say space(11) get mpr_smo when m1tip_opl != OU_PLAT
      @ r1+3,37 say space(11) get mpolis picture "@!" when m1tip_opl != OU_PLAT
      val_tip_usl(,m1tip_usl,r1+2)
      @ r1+4,2 say "Вид платежа" get mtip_opl ;
               reader {|x|menu_reader(x,menu_opl,A__MENUVERT,,,.f.)}
      @ r1+5,2 say "Дата оплаты" get mdate_o
      @ r1+6,2 say "Сумма оплаты" get mstoim pict pict_cena
      ii := 7
      if glob_kassa == 1
        //
      else
        if mem_ort_ysl == 1
          @ r1+ii,2 say "Номер квитанционной книжки" get mn_kvit pict "99999"
          ++ii
        endif
        @ r1+ii,2 say "Номер квитанции" get mkv_cia pict "999999"
        ++ii
      endif
      if mem_ort_ysl == 1
        @ r1+ii,2 say "Таб.№ регистратора" get mtabn_vr pict "99999" ;
                  valid {|g| f0e_o_kopl(g) }
      endif
      @ r1+ii,28 get mvrach when .f. color color14
      ++ii
      @ r1+ii,2 say "Примечание" get mprim
      status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи")
      count_edit := myread(,@pos_read,++k_read)
      SetKey( K_F2, NIL )
      SetKey( K_F3, NIL )
      if lastkey() != K_ESC
        if emptyany(mdate_o,mstoim)
          func_error(4,"Введены не все данные!")
          loop
        else
          err_date_diap(mdate_o,"Дата оплаты")
          mywait()
          select HO
          if nKey == K_INS
            Add1Rec(7)
            ho->kod := human->(recno())
            ho->cena_opl := 0 // на всякий случай обнуляем сумму оплату
            mrec_ho := ho->(recno())
            if glob_kassa == 1
              ho->is_kas := 2
            endif
            fl_found := .t.
            ++mvu[1,1]  // услуга добавлена оператором
            mvu[1,2] += count_edit
          else
            goto (mrec_ho)
            G_RLock(forever)
            ++mvu[2,1]  // услуга отредактирована оператором
            mvu[2,2] += count_edit
          endif
          select HO
          if glob_kassa == 1 .and. ho->is_kas == 1 .and. ho->cena_opl > 0
            //стоит ФР и пробит чек
            func_error(4,"Пробит ЧЕК! Редактирование ЗАПРЕЩЕНО!")
          else
            ho->tip_opl  := m1tip_opl
            ho->kod_reg  := mkod_vr
            ho->cena_opl := mstoim
            ho->pdate    := dtoc4(mdate_o)
            ho->n_kvit   := mn_kvit
            ho->kv_cia   := mkv_cia
            ho->prim     := mprim
            ho->tip_usl  := m1tip_usl
            if equalany(m1tip_usl,OU_D_SMO,OU_PR_VZ)
              ho->pr_smo := m1pr_smo
              ho->d_polis := mpolis
            else
              ho->pr_smo := 0
              ho->d_polis := ""
            endif
          endif
          UNLOCK
          mcena_opl := 0
          select HO
          find (str_find)
          dbeval({|| mcena_opl += ho->cena_opl-ho->sum_voz },,{|| ho->kod==human->(recno())})
          select HUMAN
          G_RLock(forever)
          human->cena_opl := mcena_opl
          UNLOCK
          COMMIT
          skod_vr := mkod_vr
          sn_kvit := mn_kvit
        endif
      endif
      exit
    enddo
    flag := 0
    if nKey == K_INS .and. !fl_found
      flag := 1
    endif
    restscreen(buf)
    f3e_o_kopl()
    select HO
    oBrow:goTop()
    goto (mrec_ho)
    setcolor(tmp_color)
  case nKey == K_DEL .and. ho->kod > 0
    if glob_kassa == 1
      if ho->is_kas == 1 .and. ho->cena_opl > 0 // чек был пробит
        vozvrat_orto()
        mcena_opl := 0
        find (str_find)
        dbeval({|| mcena_opl += ho->cena_opl-ho->sum_voz },,{|| ho->kod==human->(recno())})
        select HUMAN
        G_RLock(forever)
        replace human->cena_opl with mcena_opl
        UNLOCK
        COMMIT
        flag := 0
        select HO
        oBrow:goTop()
        find (str_find)
        if !found()
          fl_found := .f.
          flag := 1
        endif
        restscreen(buf)
      else // чек не пробит - повторяю обычный кусок
        if f_Esc_Enter(2)
          mywait()
          ++mvu[3,1]  // услуга удалена оператором
          select HO
          DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
          mcena_opl := 0
          find (str_find)
          dbeval({|| mcena_opl += ho->cena_opl-ho->sum_voz },,{|| ho->kod==human->(recno())})
          select HUMAN
          G_RLock(forever)
          replace human->cena_opl with mcena_opl
          UNLOCK
          COMMIT
          flag := 0
          select HO
          oBrow:goTop()
          find (str_find)
          if !found()
            fl_found := .f.
            flag := 1
          endif
          restscreen(buf)
          f3e_o_kopl()
        endif
      endif
    else
      if f_Esc_Enter(2)
        mywait()
        ++mvu[3,1]  // услуга удалена оператором
        select HO
        DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
        mcena_opl := 0
        find (str_find)
        dbeval({|| mcena_opl += ho->cena_opl-ho->sum_voz },,{|| ho->kod==human->(recno())})
        select HUMAN
        G_RLock(forever)
        replace human->cena_opl with mcena_opl
        UNLOCK
        COMMIT
        flag := 0
        select HO
        oBrow:goTop()
        find (str_find)
        if !found()
          fl_found := .f.
          flag := 1
        endif
        restscreen(buf)
        f3e_o_kopl()
      endif
    endif
  case nKey == K_F10 .and. glob_kassa == 1 .and. ;
                        ho->is_kas == 2 .and. ho->cena_opl > 0
    buf := savescreen()
    ClrLine(23,color0)
    adbf := {{"name", "C",40,0},;
             {"vrach","C",40,0},;
             {"cena", "N",10,2},;
             {"kol",  "N", 5,1},;
             {"nds20","N", 1,0},; //10.08.08
             {"nds18","N", 1,0},; //10.08.08
             {"nds10","N", 1,0}}
    dbcreate(cur_dir+"tmp",adbf)
    use (cur_dir+"tmp") new
    adbf := {}
    select TMP
    append blank
    tmp->name := inieditspr(A__MENUVERT, menu_opl, ho->tip_opl)+" наряд N "+lstr(human->nar_z)
    tmp->cena := round_5(ho->cena_opl, 2)
    tmp->kol := round_5(1,0)
    // 10.08.08 - НДС
    /*if round(tmp->cena,2) == round(usl->pcena_d,2) // дети
      lnds := round_5(usl->pnds_d,0)
    else // взрослые
      lnds := round_5(usl->pnds,0)
    endif
    if lnds == 18
      tmp->nds18 := 1
    elseif lnds == 10
      tmp->nds10 := 1
    endif
    */
    //ho->(dbCloseArea())
    //  menu_opl := {{"аванс               ",0},;
    //               {"окончательная оплата",1},;
    //               {"напыление           ",2}}
    if ho->tip_opl == 0
      tip_oplatFR := 3 // аванс
    else
      tip_oplatFR := 4
    endif
    Private p_summa := round_5(ho->cena_opl,2), fl_sdacha := .f.,;
            mplat_fio := "", mplat_inn := ""
    v_summa := v_sdacha := v_bank := 0
    if yes_chek(@v_summa,@v_sdacha,@v_bank,,@maddress,@tip_kart) .and.;
      chek_fr(round_5(v_summa,2),v_sdacha,@ln_chek,round_5(v_bank,2),2,@fr_zavodnomer,maddress,tip_kart,tip_oplatFR)
      select HO
      G_RLock(forever)
      ho->is_kas  := 1
      ho->kv_cia  := ln_chek
      ho->sbank   := v_bank
      ho->fr_data := lfr_data
      ho->fr_time := lfr_time
      ho->KOD_REG := asc(kod_polzovat)
      ho->FR_zavod := fr_zavodnomer
      ho->FR_tipkart := tip_kart
      ho->fr_tip     := 2
      ho->i_post     :=  maddress //00.02.17
      UnLock
      ho->(dbCommit()) //16.04.08
      flag := 0
    endif
    tmp->(dbCloseArea())
    select HO
    restscreen(buf)
  otherwise
    keyboard ""
endcase
help_code := tmp_help
return flag

*

*****
Function vozvrat_orto()
Local buf := savescreen(), sotgr, str_sem, s, ln_chek,;
      sum_bank, sum_nal, sum_itog, tip_banka,;
      menu_opl := {{"аванс               ",0},;
                   {"окончательная оплата",1},;
                   {"напыление           ",2}}

Private  summa_oplat := 0, summa_oplat_bn := 0, p_summa := 0


if !empty(human->k_data) .and. tip_polzovat != 0
  func_error(4,err_close)
elseif ho->sum_voz > 0
  func_error(4,"По даной оплате уже производился возврат денег!")
else
  //
  summa_oplat := ho->cena_opl
  summa_oplat_bn := ho->sbank
  tip_banka := ho->fr_tipkart
  //
  adbf := {{"name_u","C",128,0},;
           {"vrach", "C", 40,0},;
           {"u_cena","N", 10,2},;
           {"kol1",  "N",  5,1},;
           {"nds20", "N",  1,0},; //10.08.08
           {"nds18", "N",  1,0},; //10.08.08
           {"nds10", "N",  1,0}}
  dbcreate(cur_dir+"tmp",adbf)
  use (cur_dir+"tmp") new
  adbf := {}
  select TMP
  append blank
  tmp->name_u := inieditspr(A__MENUVERT, menu_opl, ho->tip_opl)+" наряд N "+lstr(human->nar_z)
  tmp->u_cena := round_5(ho->cena_opl, 2)
  tmp->kol1   := round_5(1,0)
  //
  p_summa := summa_oplat

  if f_Esc_Enter("возврата",.t.)
    // вначале возвращаем наличку
    if p_summa <= (summa_oplat - summa_oplat_bn)
      sum_bank  := 0
      tip_banka := 0
      sum_nal   := p_summa
    else
      sum_nal   := summa_oplat - summa_oplat_bn
      sum_bank  := p_summa - sum_nal
    endif
    fl := vozvrat_fr(sum_nal,sum_bank,@ln_chek,2,tip_banka)
    // сам чек
    if fl
      // заносим возврат
      select HO
      G_RLock(forever)
      replace ho->date_voz    with dtoc4(ldate_voz), ;
              ho->sum_voz     with summa_oplat
             /* ,;
              ho->vzfr_data   with ,;
              ho->vzfr_time   with ,;
              ho->vzkod_oper  with ,;
              ho->vzfr_zavod   with
            */
      UnLock
      ho->(dbCommit())
      stat_msg("Сумма возврата записана!") ; mybell(1,OK)
    endif
  endif
  tmp->(dbCloseArea())
  ho->(dbCommit())
  restscreen(buf)
endif
return NIL


*

***** 12.07.18
Function kart_orto(r)
Static snar_z := 0
Local i, j, r2, ln, buf, str_sem, arr_n := {}
//
if glob_kassa == 1 .and. mek_kassa == 1  //.and. mek_nkassa == 1
  Private drvFR
  IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    FR_ZAMENA_otrezka()
  else
    return func_error(4,"Ошибка запуска драйвера КАССЫ")
  endif
endif
//
if (i := popup_prompt(T_ROW,T_COL+5,1,;
            {"Поиск по ~ФИО (полису)","Поиск по номеру ~наряда"})) == 0
  return NIL
elseif i == 2
  j := 0
  if (ln := input_value(18,10,20,69,color0,;
       "     Введите номер необходимого наряда-заказа",;
       snar_z,"99999")) != NIL .and. ln > 0
    snar_z := ln
    dbcreate(cur_dir+"tmp_kart",{{"kod","N",7,0},;
                         {"fio","C",50,0},;
                         {"data","D",8,0},;
                         {"rec_hum","N",7,0},;
                         {"bukva","C",1,0},;
                         {"uchast","N",2,0},;
                         {"kod_vu","N",5,0}} )
    use (cur_dir+"tmp_kart") alias TMP
    index on dtos(data) to (cur_dir+"tmp_kart") descending
    //
    R_Use(dir_server+"kartotek",,"KART")
    R_Use(dir_server+"hum_ort",dir_server+"hum_ortn","HUMAN")
    set relation to kod_k into KART
    find (str(ln,5))
    do while human->nar_z == ln
      select TMP
      append blank
      tmp->kod := kart->kod ; tmp->fio := kart->fio
      tmp->bukva := kart->bukva
      tmp->uchast := kart->uchast
      tmp->kod_vu := kart->kod_vu
      tmp->data := human->data
      tmp->rec_hum := human->(recno())
      //
      select HUMAN
      skip
    enddo
    j := tmp->(lastrec())
    close databases
    if j == 0
      func_error(4,"Наряд N "+lstr(ln)+" не найден!")
    else
      buf := savescreen()
      R_Use(dir_server+"kartote2",,"KART2")
      R_Use(dir_server+"kartote_",,"KART_")
      R_Use(dir_server+"kartotek",,"KART")
      use (cur_dir+"tmp_kart") index (cur_dir+"tmp_kart") new alias TMP
      set relation to kod into KART, to kod into KART_, to kod into KART2
      change_attr()
      top_frm := 14
      @ 13,0 say padc("_Просмотр картотеки_",80,"░") color "R/BG"
      r2 := iif(T_ROW+j>9,11,T_ROW+j+4)
      j := 0
      if Alpha_Browse(T_ROW,10,r2,77,"f1_k_orto",color0,;
                      "Наряд N "+lstr(ln),col_tit_popup,.f.,.t.,,;
                      "f2_v_fio",,,{"═","░","═",,,0} )
        glob_kartotek := tmp->kod
        glob_k_fio := alltrim(tmp->fio)
        j := 1
      endif
      close databases
      restscreen(buf)
    endif
  endif
  if j == 0
    return NIL
  endif
elseif i == 1 .and. polikl1_kart() <= 0
  return NIL
endif
str_sem := "ОРТ Редактирование человека "+lstr(glob_kartotek)
if !G_SLock(str_sem)
  return func_error(4,err_slock)
endif
buf := savescreen()
Private fl_found, str_find, muslovie, regim := r
str_find := str(glob_kartotek,7)
muslovie := "human->kod_k == glob_kartotek"
use_base("hum_ort")
find (str_find)
fl_found := found()
arr_blk := {{| | FindFirst(str_find)},;
            {| | FindLast(str_find,-1)},;
            {|n| SkipPointer(n, muslovie)},;
            str_find,muslovie;
           }
if !fl_found ; keyboard chr(K_INS) ; endif
mtitle := "Ортопедические услуги: "+glob_k_fio
if mem_ort_ysl == 2
  Alpha_Browse(T_ROW,0,maxrow()-2,79,"f2_k_orto",color0,mtitle,"BG+/GR",;
             .f.,.t.,arr_blk,,"f3_k_orto",,;
             {'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG",.t.,180} )
else
  Alpha_Browse(T_ROW,0,maxrow()-2,79,"f2_k_orto",color0,mtitle,"BG+/GR",;
             .f.,.t.,arr_blk,,"f3_k_orto",,;
             {,,,"N/BG,W+/N,B/BG,BG+/B,R/BG",.t.,180} )
endif
close databases
restscreen(buf)
G_SUnLock(str_sem)
return NIL

*****
Function f1_k_orto(oBrow)
oBrow:addColumn(TBColumnNew("   Дата;  наряда",{|| full_date(tmp->data) }))
oBrow:addColumn(TBColumnNew(center("Ф.И.О.",50),{|| tmp->fio }))
status_key("^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор")
return NIL

*****
Function f2_k_orto(oBrow)
//02.12.2012 Ю
Local oColumn, blk := {|| if(human->cena > 0, {1,2}, {3,4}) }
//
oColumn := TBColumnNew("Номер;наряда",{|| human->nar_z })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
//oColumn := TBColumnNew("  Дата; наряда", {|| date_8(human->data) })
oColumn := TBColumnNew("  Дата; наряда", {|| full_date(human->data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" Начало; лечения", {|| full_date(human->n_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Окончание; лечения", {|| full_date(human->k_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Стоимость; лечения", {|| put_kop(human->cena,10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Сумма;оплаты", {|| put_kop(human->cena_opl,10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
if mem_ort_ysl == 2
  oColumn := TBColumnNew("Сумма;долга", {|| put_kop(human->cena-human->cena_opl,10) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
endif
//
oColumn := TBColumnNew(" ",{|| {"П","б","з","Д"}[human->tip_usl+1] })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
@ 23,0 say padc("<Esc>-выход <Enter>-редактирование <Ins>-добавление <Del>-удаление <F2>-материал",80) color "N/W"
@ 24,0 say padc("<Ctrl>+<Enter>-ввод услуг <Ctrl>+<O>-ввод оплаты <F9/F10>-печать наряда/договора",80) color "N/W"
mark_keys({"<Esc>","<Enter>","<Ins>","<Del>","<F2>","<Ctrl>+<Enter>","<Ctrl>+<O>","<F9/F10>"},"R/W")
return NIL

*****
Function f3_k_orto(nKey,oBrow)
LOCAL j := 0, flag := -1, buf := save_row(maxrow()), buf1, fl := .f., rec, mkod,;
      tmp_color := setcolor(), r, llpu, mkod_as, mn_data, buf2 := save_row(23),;
      fll := .T.
do case
  case nKey == K_INS .or. (nKey == K_ENTER .and. human->kod_k > 0)
    if nKey == K_INS .and. !fl_found
      r := 6+regim
      colorwin(r,0,r,79,"N/N","W+/N")
      colorwin(r,0,r,79,"N/N","BG+/B")
    endif
    rec := recno()
    flag := f_ort_kart(nKey)
  case nKey == K_F2 // 15.12.13 материал по наряду
    Private mmrec
    mmrec := rec := human->(recno())
    Ort_nar_material()
    use_base("hum_ort")
    select HUMAN
    goto (rec)
    setcolor(tmp_color)
    rest_box(buf2)
    rest_box(buf) ; flag := 0
  case nKey == K_F5 // занос техника и даты начала лечения из шапки в услуги
    if f_Esc_Enter("занесения техника в услуги")
      mKOD_AS     := human->kod_as        // код зубного техника
      MN_DATA     := human->N_DATA        // дата начала лечения
      rec := human->(recno())
      use_base("hum_oru")
      find (str(rec,7))
      do while hu->kod == rec .and. !eof()
        G_RLock("forever")
        hu->kod_as := mKOD_AS
        hu->date_u := dtoc4(mn_data)
        unlock
        skip
      enddo
      hu->(dbCloseArea())
      select HUMAN
      goto (rec)
    endif
  case nKey == K_F6 // занос техника и даты начала лечения из шапки в услуги
    if f_Esc_Enter("занесения техника в услуги")
      mKOD_AS     := human->kod_as        // код зубного техника
      MN_DATA     := human->N_DATA        // дата начала лечения
      rec := human->(recno())
      use_base("hum_oru")
      find (str(rec,7))
      do while hu->kod == rec .and. !eof()
        G_RLock("forever")
        hu->date_u := dtoc4(mn_data)
        unlock
        skip
      enddo
      hu->(dbCloseArea())
      select HUMAN
      goto (rec)
    endif

  case nKey == K_F9 .or. nKey == K_F8
    Private mmrec
    mmrec := rec := human->(recno())
    Private mmtip_oplat := {"Аванс за работу",;
                            "Окончательная оплата",;
                            "Напыление"}
    use_base("hum_oro")
    Private TIP_NARAD := (nKey == K_F9)
    pr_zak_nar(1) //16.04.08
    close databases
    use_base("hum_ort")
    select HUMAN
    goto (rec)
    setcolor(tmp_color)
    rest_box(buf) ; flag := 0
  case nKey == K_F10 //16.04.08
    Private mmrec
    mmrec := rec := human->(recno())
    use_base("hum_oro")
    @ 23,0 say padc(" ",80) color "N/W"
    pr_zak_nar(2)
    close databases
    use_base("hum_ort")
    select HUMAN
    goto (rec)
    setcolor(tmp_color)
    rest_box(buf2)
    rest_box(buf) ; flag := 0
  case nKey == K_DEL .and. ;
                    human->kod_k > 0 .and. ver_pub_date(human->k_data,.t.)
    use_base("hum_oro")
    select HO
    find (str(human->(recno()),7))
    if found()
      fll := .F.
    endif
    ho->(dbCloseArea())
    //
    If fll
      if f_Esc_Enter(2,.t.)
        mywait()
        j := 0
        use_base("hum_oru")
        do while .t.
          select HU
          find (str(human->(recno()),7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
          ++j
        enddo
        hu->(dbCloseArea())
        //
        use_base("hum_oro")
        do while .t.
          select HO
          find (str(human->(recno()),7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
          ++j
        enddo
        ho->(dbCloseArea())
        write_work_oper(glob_task+iif(human->tip_usl==OU_B_PLAT,100,0),;
                        OPER_USL,;
                        3,j)
        write_work_oper(glob_task+iif(human->tip_usl==OU_B_PLAT,100,0),;
                        OPER_LIST,;
                        3)
        //
        select HUMAN
        DeleteRec()
        oBrow:goTop()
        find (str_find)
        if !found()
          fl_found := .f.
        endif
        stat_msg("Ортопедический лист учета удален!") ; mybell(1,OK)
        flag := 0
        if !fl_found
          flag := 1
        endif
        rest_box(buf)
      endif
    else
      stat_msg("Удалите оплату!") ; mybell(1,OK)
    endif
  case nKey == K_CTRL_RET .and. human->kod_k > 0 .and.;
       iif(mem_ort_ysl == 2,.t.,!emptyall(human->n_data,human->k_data))
    rec := human->(recno()) ; llpu := human->lpu
    close databases
    usl_ort_kart(rec,llpu)
    use_base("hum_ort")
    goto (rec)
    setcolor(tmp_color)
    rest_box(buf) ; flag := 0
  case nKey == K_CTRL_O .and. human->kod_k > 0
    rec := human->(recno()) ; llpu := human->lpu
    close databases
    opl_kart(rec,llpu)
    use_base("hum_ort")
    goto (rec)
    setcolor(tmp_color)
    rest_box(buf) ; flag := 0
  otherwise
    keyboard ""
endcase
return flag

*

*****
Function f_ort_kart(nKey)
Static st_tip_usl := 0
Local buf := savescreen(), tmp_color := setcolor(), str_1, fl, ;
      colget_menu := "R/W", i, k, tmp_help := help_code, s_msg, ;
      pos_read := 0, k_read := 0, count_edit := 0,;
      ret := -1, old_doc, old_k_data
Private r1 := 6
mywait()
Private ;
    mNAR_Z      := 0                 ,; // номер наряда-заказа
    mDATA       := sys_date          ,; // дата наряда-заказа
    MLPU, M1LPU := glob_uch[1]       ,; // код учреждения
    MOTD, M1OTD := glob_otd[1]       ,; // код отделения
    mUCH_DOC    := space(10)         ,; // вид и номер учетного документа
    mKOD_VR     := 0                 ,; // код врача
    mKOD_AS     := 0                 ,; // код зубного техника
    mkod_ms     := 0                 ,;
    mKOD_DIAG   := space(6)          ,; // шифр болезни
    mKOD_DIAG2  := space(6)          ,; // шифр болезни
    mKOD_DIAG3  := space(6)          ,; // шифр болезни
    mKOD_DIAG4  := space(6)          ,; // шифр болезни
    mKOD_DIAG5  := space(6)          ,; // шифр болезни
    mKOD_DIAG6  := space(6)          ,; // шифр болезни
    mKOD_DIAG7  := space(6)          ,; // шифр болезни
    MN_DATA     := ctod("")          ,; // дата начала лечения
    MK_DATA     := ctod("")          ,; // дата окончания лечения
    mKOL_POS    := 0                 ,; // количество посещений
    mn_och      := space(10)         ,; // номер очереди (для бесплатных больных)
    MPRICH, M1PRICH := 0             ,; // причина поломки протеза
    MKOL_MOSTP  := 0                 ,; // количество мостовидных протезов
    MKOL_CELNL  := 0                 ,; // в т.ч. цельнолитых
    mprim       := space(15)         ,; // примечание
    mtip_usl, m1tip_usl := st_tip_usl,;
    mpr_smo := space(10), m1pr_smo := 0,;
    mtabn_vr := 0, mtabn_as := 0,;
    mvrach := massist := space(35),;
    mcena := 0, mcena_opl := 0,;
    MKOL_PR1    := 0,;
    MKOL_PR2    := 0,;
    MKOL_PR3    := 0,;
    MKOL_PR4    := 0,;
    MKOL_PR5    := 0,;
    MKOL_PR6    := 0,;
    mplat_fio   := space(40),;
    mplat_inn   := space(12),;
    mplat_adres  := space(50),; // адрес плательщика
    mplat_pasport :=  space(15)  // документ плательщика
if nKey == K_INS
  R_Use(dir_server+"kartotek",,"KART")
  goto (glob_kartotek)
  if is_uchastok == 1
    mbukva := kart->bukva
    muchast := lstr(kart->uchast)
    mkod_vu := lstr(kart->kod_vu)
    much_doc := ""
    if !emptyall(kart->bukva,kart->uchast,kart->kod_vu)
      if !empty(kart->bukva)
        much_doc += kart->bukva
      endif
      much_doc += lstr(kart->uchast,2)
      if kart->kod_vu > 0
        much_doc += "/"+lstr(kart->kod_vu)
      endif
    endif
    MUCH_DOC := padr(much_doc,10)
    if mem_ortot1 == 2 .and. mem_kodotd == 1
      m1otd := mem_ortotd
    endif
  elseif mem_kodkrt == 2
    MUCH_DOC := padr(lstr(glob_kartotek),10)
  endif
  Use
elseif nKey == K_ENTER
  MKOD_DIAG   := human->KOD_DIAG      // шифр 1-ой осн.болезни
  MKOD_DIAG2  := human->KOD_DIAG2     // шифр 2-ой осн.болезни
  MKOD_DIAG3  := human->KOD_DIAG3     // шифр 3-ей осн.болезни
  MKOD_DIAG4  := human->KOD_DIAG4     // шифр 4-ой осн.болезни
  MKOD_DIAG5  := human->KOD_DIAG5     // шифр 5-ой осн.болезни
  MKOD_DIAG6  := human->KOD_DIAG6     // шифр 6-ой осн.болезни
  MKOD_DIAG7  := human->KOD_DIAG7     // шифр 7-ой осн.болезни
  MKOL_PR1    := human->KOL_PR1
  MKOL_PR2    := human->KOL_PR2
  MKOL_PR3    := human->KOL_PR3
  MKOL_PR4    := human->KOL_PR4
  MKOL_PR5    := human->KOL_PR5
  MKOL_PR6    := human->KOL_PR6
  mNAR_Z      := human->nar_z         // номер наряда-заказа
  mDATA       := human->data          // дата наряда-заказа
  M1LPU       := human->LPU           // код учреждения
  M1OTD       := human->OTD           // код отделения
  mUCH_DOC    := human->uch_doc       // вид и номер учетного документа
  mKOD_VR     := human->kod_vr        // код врача
  mKOD_AS     := human->kod_as        // код зубного техника
  MN_DATA     := human->N_DATA        // дата начала лечения
  MK_DATA     := human->K_DATA        // дата окончания лечения
  mKOL_POS    := human->kol_pos       // количество посещений
  M1PRICH     := human->PRICH_POL     // причина поломки протеза
  MKOL_MOSTP  := human->KOL_MOSTP     // количество мостовидных протезов
  MKOL_CELNL  := human->KOL_CELNL     // в т.ч. цельнолитых
  MCENA       := human->CENA          // стоимость лечения
  MCENA_OPL   := human->CENA_OPL      // сумма оплаты
  m1tip_usl   := human->tip_usl
  mplat_fio   := human->plat_fio
  mplat_inn   := human->plat_inn
  if m1tip_usl > 0
    m1pr_smo := human->pr_smo
  endif
  mn_och      := human->n_och
  mprim       := human->prim
endif
//
R_Use(dir_server+"hum_orpl",dir_server+"hum_orpl","KPLAT")
find (str(human->(recno()),7))
if found()
  mplat_adres   := KPLAT->ADRES
  mplat_pasport := KPLAT->PASPORT
endif
KPLAT->(dbCloseArea())
mtip_usl := inieditspr(A__MENUVERT, menu_okb, m1tip_usl)
mlpu := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
motd := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
mprich := inieditspr(A__POPUPMENU, dir_server+"ort_brk", m1prich)
if m1tip_usl == OU_D_SMO
  mpr_smo := inieditspr(A__POPUPMENU, dir_server+"p_d_smo", m1pr_smo)
elseif m1tip_usl == OU_PR_VZ
  mpr_smo := inieditspr(A__POPUPMENU, dir_server+"p_pr_vz", m1pr_smo)
endif
R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
str_1 := " карточки лечения ортопедического больного"
if nKey == K_INS
  str_1 := "Добавление"+str_1
else
  str_1 := "Редактирование"+str_1
  select PERSO
  goto (mkod_vr)
  mvrach := padr(perso->fio,35)
  mtabn_vr := perso->tab_nom
  goto (mkod_as)
  massist := padr(perso->fio,35)
  mtabn_as := perso->tab_nom
endif
old_doc := much_doc ; old_k_data := mk_data
Private gl_area := {r1,0,23,79,0}
box_shadow(r1,0,23,79,color1,str_1,color8)
status_key("^<Esc>^ - выход;  ^<PgDn>^ - запись")
help_code := -1
setcolor(cDataCGet)
*
do while .t.
  if nKey == K_INS .or. mnar_z == 0
    @ 23,37 say " <F2> - поиск свободного номера наряда " color "BG/B"
    mark_keys({"<F2>"},"G+/B")
  endif
  @ r1+1,2 say "Вид и номер учетного документа" get much_doc picture "@!"
  @ r1+2,2 say "Учреждение" get mlpu ;
     reader {|x|menu_reader(x,{{|k,r,c|ret_uch_otd(k,r,c,sys_date,,X_ORTO)}},A__FUNCTION,,,.f.)}
  @ r1+3,2 say "Отделение" get motd when .f.
  @ r1+3,45 say "Категория больного" get mtip_usl ;
            reader {|x|menu_reader(x,menu_okb,A__MENUVERT,,,.f.)} ;
            valid {|g,o| val_tip_usl(g,o,r1+4) }
  @ r1+4,37 say space(11) get mpr_smo
  val_tip_usl(,m1tip_usl,r1+4)
  @ r1+5,2 say "Диагнозы" get mkod_diag picture "@!" valid v_ort_diag()
  @ row(),col() say "," get mkod_diag2 picture "@!" valid v_ort_diag()
  @ row(),col() say "," get mkod_diag3 picture "@!" valid v_ort_diag()
  IF mem_ort_f39 == 1
    @ row(),col() say "," get mkod_diag4 picture "@!" valid v_ort_diag()
    @ row(),col() say "," get mkod_diag5 picture "@!" valid v_ort_diag()
    @ row(),col() say "," get mkod_diag6 picture "@!" valid v_ort_diag()
    @ row(),col() say "," get mkod_diag7 picture "@!" valid v_ort_diag()
  ENDIF
  @ r1+6,2 say "Номер наряда-заказа" get mnar_z pict "99999"
  @ row(),col()+5 say "Дата наряда-заказа" get mdata ;
      valid {|g| if(regim==2.and.empty(mn_data), (mn_data := mdata), nil), ;
                 update_get("mn_data") }
  @ r1+7,2 say "Таб.№ врача" get mtabn_vr pict "99999" ;
           valid {|g| f5e_o_kusl(g,2,3) }
  @ row(),col()+3 get mvrach when .f. color color14
  @ r1+8,2 say "Таб.№ зуб/техника" get mtabn_as pict "99999" ;
           valid {|g| f5e_o_kusl(g,2,4) }
  @ row(),col()+3 get massist when .f. color color14
  @ r1+9,2 say "Номер очереди" get mn_och
  @ row(),col()+10 say "Примечание" get mprim
  @ r1+10,2 say "Причины поломок протезов" get mprich reader ;
          {|x| menu_reader(x,;
               {dir_server+"ort_brk",,,,,color5,"Причины поломок","B/W"},;
               A__POPUPBASE1,,,.f.);
          }
  IF mem_ort_f39 == 0
    @ r1+11,2 say "Количество мостовидных протезов, всего:" get MKOL_MOSTP pict "9"
    @ row(),col() say ", в т.ч. цельнолитых" get MKOL_CELNL pict "9"
  else
    @ r1+11,2 say "Протезов пласт:" get MKOL_PR1 pict "9"
    @ row(),col() say " мет-кер:"     get MKOL_Pr2 pict "9"
    @ row(),col() say " на штифт:"    get MKOL_Pr3 pict "9"
    @ row(),col() say " мет-акр:"     get MKOL_Pr4 pict "9"
    @ row(),col() say " штампов:"     get MKOL_Pr5 pict "9"
    @ row(),col() say " цельнол:"     get MKOL_Pr6 pict "9"
  endif
  // Добавка Плательщика 01.04.13
  //Кроме бесплатных
    @ r1+12,2 say "Плательщик: ФИО" get mplat_fio when m1tip_usl != OU_B_PLAT
    @ row(),col() say ", ИНН" get mplat_inn when m1tip_usl != OU_B_PLAT
    @ r1+13,2 say "АДРЕС" get mplat_adres pict "@S45" when m1tip_usl != OU_B_PLAT
    @ row(),col() say ", N Док." get mplat_pasport when m1tip_usl != OU_B_PLAT
  // конец Плательщик
  if regim == 2
    @ r1+14,2 say "Дата начала лечения" get mn_data valid {|g|f_k_data(g,1)}
    @ row(),col()+2 say "Дата окончания лечения" get mk_data valid {|g|f_k_data(g,2)}
    @ r1+15,2 say "Количество посещений" get mkol_pos pict "99"
    @ r1+16,10 say "Стоимость лечения "+lstr(mcena,11,2) color "GR+/B"
  endif
  @ r1+16,50 say "Сумма оплаты "+lstr(mcena_opl,11,2) color "GR+/B"
  if nKey == K_INS .or. mnar_z == 0
    set key K_F2 to poisk_svob
  endif
  if nKey == K_ENTER .and. !ver_pub_date(mk_data,.t.)
    keyboard chr(K_ESC)
  endif
  count_edit := myread(,@pos_read,++k_read)
  if nKey == K_INS .or. mnar_z == 0
    set key K_F2 to
  endif
  if lastkey() != K_ESC .and. f_Esc_Enter(1)
    if m1lpu == 0
      func_error(4,"Не введено лечебное учреждение!")
      loop
    endif
    if empty(mdata)
      func_error(4,"Не введена дата наряда-заказа.")
      loop
    endif
    if regim == 2
      err_date_diap(mn_data,"Дата начала лечения")
      err_date_diap(mk_data,"Дата окончания лечения")
    endif
    mywait()
    if !(old_doc == much_doc) .and. is_uchastok == 1
      much_doc := ltrim(much_doc)
      mbukva := " "
      muchast := 0
      mkod_vu := 0
      if !empty(much_doc)
        i := 1
        do while !(substr(much_doc,i,1) $ "0123456789" .and. i <= len(much_doc))
          if i == 1
            mbukva := left(much_doc,1)
          endif
          ++i
        enddo
        if (muchast := int(val(substr(much_doc,i)))) > 99
          muchast := 0
        endif
        if (i := at("/",much_doc)) > 0
          if (mkod_vu := int(val(substr(much_doc,i+1)))) > 99999
            mkod_vu := 0
          endif
        endif
      endif
      G_Use(dir_server+"kartotek",dir_server+"kartoteu","KART")
      goto (glob_kartotek)
      G_RLock(forever)
      kart->bukva := mbukva
      kart->uchast := muchast
      kart->kod_vu := mkod_vu
      Use
    endif
    select HUMAN
    if nKey == K_INS
      AddRec(7)
      human->kod_k := glob_kartotek
    else
      G_RLock(forever)
    endif
    replace ;
       human->NAR_Z     with mNAR_Z,;
       human->DATA      with mDATA,;
       human->LPU       with m1LPU,;
       human->OTD       with m1OTD,;
       human->UCH_DOC   with mUCH_DOC,;
       human->KOD_VR    with mKOD_VR,;
       human->KOD_AS    with mKOD_AS,;
       human->N_DATA    with mN_DATA,;
       human->K_DATA    with mK_DATA,;
       human->KOL_POS   with mKOL_POS,;
       human->tip_usl   with m1tip_usl,;
       human->n_och     with mn_och,;
       human->PRICH_POL with M1PRICH,;
       human->KOL_MOSTP with MKOL_MOSTP,;
       human->KOL_CELNL with MKOL_CELNL,;
       human->prim      with mprim
       human->KOD_DIAG  := mKOD_DIAG
       human->KOD_DIAG2 := mKOD_DIAG2
       human->KOD_DIAG3 := mKOD_DIAG3
       human->KOD_DIAG4 := mKOD_DIAG4
       human->KOD_DIAG5 := mKOD_DIAG5
       human->KOD_DIAG6 := mKOD_DIAG6
       human->KOD_DIAG7 := mKOD_DIAG7
       human->plat_fio  := mplat_fio
       human->plat_inn  := mplat_inn
       if mem_ort_f39 == 1
         human->KOL_PR1 := MKOL_PR1
         human->KOL_PR2 := MKOL_PR2
         human->KOL_PR3 := MKOL_PR3
         human->KOL_PR4 := MKOL_PR4
         human->KOL_PR5 := MKOL_PR5
         human->KOL_PR6 := MKOL_PR6
       endif
       if equalany(m1tip_usl,OU_D_SMO,OU_PR_VZ)
         human->pr_smo := m1pr_smo
       else
         human->pr_smo := 0
       endif
       if mem_ort_dat == 2 .and. empty(human->n_data)
         human->N_DATA := mDATA
       endif
    if regim == 1
      st_tip_usl := m1tip_usl
    endif
    UnLock
    Commit
    G_Use(dir_server+"hum_orpl",dir_server+"hum_orpl","KPLAT")
    if len(alltrim(mplat_adres)) > 2 .or. len(alltrim(mplat_pasport)) > 2
      find (str(human->(recno()),7))
      if !found()
        append blank
      else
        G_RLock(forever)
      endif
      KPLAT->kod     := human->(recno())
      KPLAT->ADRES   := mplat_adres
      KPLAT->PASPORT := mplat_pasport
    else
      find (str(human->(recno()),7))
      if found()
        deleterec(.t.)
      endif
    endif
    KPLAT->(dbCloseArea())
    select HUMAN
    write_work_oper(glob_task+iif(m1tip_usl==OU_B_PLAT,100,0),;
                    OPER_LIST,;
                    iif(nKey==K_INS,1,2),;
                    1,;
                    count_edit)
    ret := 0
  elseif nKey == K_INS .and. !fl_found
    ret := 1
  endif
  exit
enddo
perso->(dbCloseArea())
select HUMAN
setcolor(tmp_color)
restscreen(buf)
help_code := tmp_help
return ret

*

*****
Function v_ort_diag()
Local n := 6, fl := .t., mshifr, tmp_select := select()
Private mvar := readvar()
mshifr := alltrim(&mvar)
mshifr := padr(mshifr,6)
if !empty(mshifr)
  R_Use(dir_server+"diag_ort",dir_server+"diag_ort","DBF1")
  find (mshifr)
  if !found()
    &mvar := space(n)
    fl := func_error(4,"Ортопедический диагноз с таким шифром не найден!")
  endif
  Use
  if tmp_select > 0
    select (tmp_select)
  endif
endif
if fl
  &mvar := padr(mshifr,n)
endif
return fl

*

*****
Static Function val_tip_usl(get,old,r)
Local fl := .t., s := ""
if !equalany(m1tip_usl,OU_D_SMO,OU_PR_VZ)
  m1pr_smo := 0 ; mpr_smo := space(30)
endif
if old != NIL .and. old != m1tip_usl
  m1pr_smo := 0 ; mpr_smo := space(30)
endif
get := get_pointer("mpr_smo")
if m1tip_usl == OU_D_SMO
  s := "СМО"
  if get != NIL
    get:reader := {|x| menu_reader(x,;
                   {dir_server+"p_d_smo",,,,,color0,"Добровольные СМО","B/BG"},;
                   A__POPUPBASE1,,,.f.);
                  }
    get:PreBlock := {|| .t. }
  endif
elseif m1tip_usl == OU_PR_VZ
  s := "Предприятие"
  if get != NIL
    get:reader := {|x| menu_reader(x,;
                   {dir_server+"p_pr_vz",,,,,color0,"Предприятия по взаимозачету","B/BG"},;
                   A__POPUPBASE1,,,.f.);
                  }
    get:PreBlock := {|| .t. }
  endif
else
  get:reader := NIL
  get:PreBlock := {|| .f. }
endif
@ r,37 say padl(s,11)
update_get("mpr_smo")
return fl

*

*****
Function usl_ort_kart(mkod_human,mkod_lpu)
// mkod_human - код по БД human
Local adbf, buf := savescreen(), j := 0, tmp_color := setcolor(color1), ;
      k, l_color
Private fl_found, mcena := 0, ;
        last_date := ctod("01.01.1990"), mvu[3,2], mvp[3,2], pr1otd, ;
        pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}
Private Glob_kod_ms := 0
afillall(mvu,0) ; afillall(mvp,0)
mywait()
R_Use(dir_server+"kartotek",,"KART")
goto (glob_kartotek)
smvzros_reb := kart->vzros_reb
kart->(dbCloseArea())
//
R_Use(dir_server+"mo_otd",,"OTD")
dbeval({|| aadd(pr_arr,{otd->(recno()),otd->name,otd->kod_lpu,""}) },;
       {|| otd->kod_lpu == mkod_lpu .and. between_date(otd->dbegino,otd->dendo,sys_date)} )
if yes_many_uch
  R_Use(dir_server+"mo_uch",,"UCH")
  aeval(pr_arr, {|x,i| dbGoto(x[3]), pr_arr[i,4] := uch->name } )
//  aeval(pr1arr_otd, {|x,i| dbGoto(x[3]), pr1arr_otd[i,4] := uch->name } )
  uch->(dbCloseArea())
  //
  asort(pr_arr,,,{|x,y| iif(x[3] == y[3], upper(x[2]) < upper(y[2]), ;
                                          upper(x[4]) < upper(y[4])) } )
  aeval(pr_arr, {|x| aadd(pr_arr_otd,x[4]+" "+x[2]) } )
else
  asort(pr_arr,,,{|x,y| upper(x[2]) < upper(y[2]) } )
  aeval(pr_arr, {|x| aadd(pr_arr_otd,x[2]) } )
endif
//
R_Use(dir_server+"uslugi",,"USL")
G_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
adbf := dbstruct()
aadd(adbf, {"date_u1","D", 8,0} )
aadd(adbf, {"shifr_u","C",10,0} )
aadd(adbf, {"name_u", "C",65,0} )
aadd(adbf, {"number", "N", 3,0} )
aadd(adbf, {"is_nul", "L", 1,0} )
aadd(adbf, {"rec_hu", "N", 7,0} )
dbcreate(cur_dir+"tmp_usl",adbf)
use (cur_dir+"tmp_usl") new alias tmp
if mem_ordusl == 1
  index on dtos(date_u1)+fsort_usl(shifr_u) to (cur_dir+"tmp_usl")
else
  index on fsort_usl(shifr_u)+dtos(date_u1) to (cur_dir+"tmp_usl")
endif
select HU
set relation to u_kod into USL
find (str(mkod_human,7))
if (fl_found := found())
  adbf := array(fcount())
  do while hu->kod == mkod_human .and. !eof()
    aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
    select TMP
    append blank
    aeval(adbf, {|x,i| fieldput(i,x) } )
    tmp->date_u1 := c4tod(hu->date_u)
    tmp->shifr_u := usl->shifr
    tmp->name_u := usl->name
    tmp->is_nul := usl->is_nulp
    tmp->rec_hu := hu->(recno())
    last_date := max(tmp->date_u1,last_date)
    mcena += tmp->stoim
    select HU
    skip
  enddo
endif
tmp->(dbeval({|| tmp->number := ++j } ) )
close databases
//
Private flag_1 := .t., arr_uva := {}
G_Use(dir_server+"orto_uva",,"OU")
dbeval({|| aadd(arr_uva, {alltrim(ou->shifr),ou->kod_vr,ou->kod_as,ou->kod_ms} ) } )
ou->(dbCloseArea())
if G_Use(dir_server+"hum_ort",,"HUMAN") .and. ;
                    use_base("hum_oru") .and. ;
   R_Use(dir_server+"uslugi",dir_server+"uslugish","USL") .and. ;
   R_Use(dir_server+"mo_otd",,"OTD") .and. ;
   R_Use(dir_server+"usl_otd",dir_server+"usl_otd","UO") .and. ;
   R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
  select HUMAN
  goto (mkod_human)
  last_date := max(human->n_data,last_date)
  pr1otd := human->otd
  Use (cur_dir+"tmp_usl") index (cur_dir+"tmp_usl") new alias TMP
  set relation to otd into OTD
  go top
  cls
  pr_1_str("Ортопед.услуги для больного < "+alltrim(glob_k_fio)+" >")
  @ 1,1 say "Наряд-заказ N "+lstr(human->nar_z)+" от "+date_8(human->data)+"г." color "G+/B"
  setcolor("BG/B")
  if yes_color
    setcolor("BG/B")
    l_color := "W+/B,W+/W,BG+/B,W+/BG,G+/B,W+/G,GR+/B,W+/GR"
  else
    setcolor("W/N")
    l_color := "W+/N,N/W,W/N,N+/W,W/N,W+/N,W/N,W+/N"
  endif
  @ maxrow()-3,0 say "╒═══════════════════ Полное наименование услуги ═══════════════════╤══ Цена ═══╕"
  @ maxrow()-2,0 say "│                                                                  │           │"
  @ maxrow()-1,0 say "╘══════════════════════════════════════════════════════════════════╧═══════════╛"
  if fl_found
    keyboard chr(K_RIGHT)
  else
    keyboard chr(K_INS)
  endif
  setcolor(color1)
  Alpha_Browse(2,0,maxrow()-5,79,"fe_o_kusl",color1,;
               "Срок лечения с "+full_date(human->n_data)+"г. по "+full_date(human->k_data)+"г.",col_tit_popup,;
               .f.,.t.,,"f1e_o_kusl","f2e_o_kusl",,;
               {"═","░","═",l_color,.t.,180} )
  if yes_parol .and. (mvu[1,1] > 0 .or. mvu[2,1] > 0 .or. mvu[3,1] > 0 .or. ;
                      mvp[1,1] > 0 .or. mvp[2,1] > 0 .or. mvp[3,1] > 0) ;
               .and. hb_FileExists(dir_server+"mo_opern"+sdbf)
    close databases
    if G_Use(dir_server+"mo_opern",dir_server+"mo_opern","OP")
      for i := 1 to 3
        if mvu[i,1] > 0
          write_work_oper(glob_task,OPER_USL,i,mvu[i,1],mvu[i,2],.f.)
        endif
      next
      for i := 1 to 3
        if mvp[i,1] > 0
          write_work_oper(glob_task+100,OPER_USL,i,mvp[i,1],mvp[i,2],.f.)
        endif
      next
    endif
  endif
  close databases
endif
close databases
setcolor(tmp_color)
restscreen(buf)
return mcena

*****
Function fe_o_kusl(oBrow)
Local oColumn, blk_color := {|| if(tmp->t_edit > 1, {3,4}, {1,2}) }
blk_color := {|| {{1,2},{3,4},{5,6},{7,8}}[tmp->tip_usl+1] }
oColumn := TBColumnNew(" NN; пп",{|| tmp->number })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
if mem_ordusl == 1
  oColumn := TBColumnNew("Дата;оказ.; усл.",{|| left(dtoc(tmp->date_u1),5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew("   Шифр;  услуги",{|| tmp->shifr_u })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
if mem_ordusl == 2
  oColumn := TBColumnNew("Дата;оказ.; усл.",{|| left(dtoc(tmp->date_u1),5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew("Отде-;ление",{|| otd->short_name })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Наименование;услуги",;
                        {|| left(tmp->name_u,12) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Врач",{|| put_val(ret_tabn(tmp->kod_vr),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Зуб.Т",{|| put_val(ret_tabn(tmp->kod_as),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Ко-;лич.;усл.",{|| umest_val(tmp->kol,4,3) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Общая; стоимость; услуги",{|| put_kop(tmp->stoim,10) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" ",{|| {"П","б","з","Д"}[tmp->tip_usl+1] })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
status_key("^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление; ^<F5>^ дублирование")
return NIL

*****
Function f1e_o_kusl()
Local nRow := ROW(), nCol := COL()
@ maxrow()-2,2 say tmp->name_u color cDataCSay
@ maxrow()-2,68 say if(empty(tmp->u_cena),space(11),;
        padc(alltrim(dellastnul(tmp->u_cena,10,2)),11)) color cDataCSay
if flag_1
  f3e_o_kusl()
  flag_1 := .f.
endif
@ nRow, nCol SAY ""
return NIL

*****
Function f3e_o_kusl()
@ maxrow()-4,55 say padl("Итого: "+lstr(mcena,11,2),20) color "W+/N"
return NIL

*****
Function f2e_o_kusl(nKey,oBrow)
Static st_tip_usl := 0
Local flag := -1, buf := savescreen(), fl := .f., rec, ;
      i1, k, j := 0, s := 0, so := 0, adbf, adbf1, tmp_color := setcolor(), ;
      rec_tmp := tmp->(recno()), mrec_hu := tmp->rec_hu, ;
      pos_read := 0, k_read := 0, count_edit := 0,;
      tmp_help := help_code, uch_otd := saveuchotd()
Private r1 := 11
if equalany(nKey,K_F5,K_INS,K_ENTER,K_DEL)
  if !ver_pub_date(human->k_data,.t.)
    return flag
  endif
endif
do case
  case nKey == K_F5 .and. tmp->kod > 0
    if (i1 := input_value(18,5,20,74,color0,;
         "Введите, сколько еще копий необходимо сделать из текущей строки",;
         1,"99")) != NIL .and. i1 > 0 .and. f_Esc_Enter("дублирования строки")
      mywait()
      // услуги добавлены оператором
      if tmp->tip_usl == OU_B_PLAT
        mvp[1,1] += i1
      else
        mvu[1,1] += i1
      endif
      select HU
      goto (mrec_hu)
      adbf := array(fcount())
      aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
      select TMP
      adbf1 := array(fcount())
      aeval(adbf1, {|x,i| adbf1[i] := fieldget(i) } )
      Private mdate_u1 := tmp->date_u1
      for k := 1 to i1
        mdate_u1++
        select HU
        Add1Rec(7)
        aeval(adbf, {|x,i| fieldput(i,x) } )
        hu->date_u := dtoc4(mdate_u1)
        mrec_hu := hu->(recno())
        UNLOCK
        select TMP
        append blank
        aeval(adbf1, {|x,i| fieldput(i,x) } )
        tmp->date_u1 := mdate_u1
        tmp->rec_hu := mrec_hu
      next
      summa_usl(@mcena)
      select HUMAN
      G_RLock(forever)
      replace human->cena with mcena
      UNLOCK
      COMMIT
      restscreen(buf)
      f3e_o_kusl()
      select TMP
      oBrow:goTop()
      goto (rec_tmp)
      setcolor(tmp_color)
      flag := 0
    endif
  case nKey == K_INS .or. (nKey == K_ENTER .and. tmp->kod > 0)
//    help_code := HM_Edit1_kart
    if nKey == K_INS .and. !fl_found
      colorwin(7,0,7,79,"B/B","W+/RB")
    endif
    if nKey == K_INS .and. tmp->(lastrec()) == 0
      st_tip_usl := human->tip_usl
    endif
    Private motd, m1otd := if(nKey == K_INS, ;
                      if(pr1otd == NIL, 0, pr1otd), tmp->otd),;
            mtip_usl, m1tip_usl := if(nKey == K_INS, st_tip_usl, tmp->tip_usl),;
            mu_kod := if(nKey == K_INS, 0, tmp->u_kod),;
            mdate_u1 := if(nKey == K_INS, last_date, tmp->date_u1),;
            mu_cena := if(nKey == K_INS, 0, tmp->u_cena),;
            mis_nul := if(nKey == K_INS, .f., tmp->is_nul),;
            mkod_vr := if(nKey == K_INS, human->kod_vr, tmp->kod_vr),;
            mkod_as := if(nKey == K_INS, human->kod_as, tmp->kod_as),;
            mkod_ms := if(nKey == K_INS, glob_kod_ms, tmp->kod_ms),;
            mtabn_vr := 0, mtabn_as := 0, mtabn_ms := 0,;
            mkol := if(nKey == K_INS, 0, tmp->kol),;
            mu_koef := if(nKey == K_INS, 1, tmp->u_koef),;
            mstoim := if(nKey == K_INS, 0, tmp->stoim),;
            mt_edit := if(nKey == K_INS, 0, tmp->t_edit),;
            mshifr := if(nKey == K_INS, space(10), tmp->shifr_u),;
            mname_u := if(nKey == K_INS, space(65), tmp->name_u),;
            mvrach := massist := mmedses := space(35),;
            vr_uva := as_uva := ms_uva :=.t., ;
            gl_area := {1,0,23,79,0}
    mtip_usl := inieditspr(A__MENUVERT, menu_otip, m1tip_usl)
    if nKey == K_INS .and. mem_ortot1 == 2 .and. mem_kodotd == 1
      m1otd := mem_ortotd
    endif
    motd := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
    if !empty(mshifr)
      verify_o_uva()
    endif
    if !emptyall(mkod_vr,mkod_as,mkod_ms)
      select PERSO
      if mkod_vr > 0
        goto (mkod_vr)
        mvrach := padr(perso->fio,35)
        mtabn_vr := perso->tab_nom
      endif
      if mkod_as > 0
        goto (mkod_as)
        massist := padr(perso->fio,35)
        mtabn_as := perso->tab_nom
      endif
      if mkod_ms > 0
        goto (mkod_ms)
        mmedses := padr(perso->fio,35)
        mtabn_ms := perso->tab_nom
      endif
    endif
    box_shadow(r1-1,0,23,79,color8,;
             if(nKey == K_INS,"Добавление новой",;
                              "Редактирование")+" ортопедической услуги","RB+/B")
    do while .t.
      setcolor(cDataCGet)
      if mem_kodotd == 1
        if mem_ortot1 == 1
          @ r1+1,2 say "Отделение, в котором оказана услуга" get motd ;
                   reader {|x|menu_reader(x, ;
                        { { |k,r,c| get_otd(k,r+1,c,.t.) }},A__FUNCTION,,,.f.)}
        else
          @ r1+1,2 say "Отделение, в котором оказана услуга"
          @ row(),col()+2 get motd color color14 when .f.
        endif
      else
        @ r1+1,2 say "Отделение, в котором оказана услуга"
        if mem_ortot1 == 1
          @ row(),col() get m1otd pict "99" ;
                   when {|g| f5e_o_kusl(g,1,10) } ;
                   valid {|g| f5e_o_kusl(g,2,10) }
        endif
        @ row(),col()+2 get motd color color14 when .f.
      endif
      @ r1+2,2 say "Тип услуги" get mtip_usl ;
               reader {|x|menu_reader(x,menu_otip,A__MENUVERT,,,.f.)}
               //when empty(mshifr)
      @ row(),col()+7 say "Дата оказания услуги" get mdate_u1 ;
               valid {|g| f5e_o_kusl(g,2,1) }
      @ r1+3,2 say "Шифр услуги" get mshifr pict "@!" ;
               when {|g| f5e_o_kusl(g,1,2) } ;
               valid {|g| f5e_o_kusl(g,2,2) }
      @ row(),40 say "Цена услуги" get mu_cena pict pict_cena ;
                when .f. color color14
      @ r1+4,2 say "Услуга" get mname_u when .f. color color14
      ix := 4
      for x := 1 to 3
        if mem_por_vr == x
          ++ix
          @ r1+ix,2 say "Таб.N врача" get mtabn_vr pict "99999" ;
                    when {|g| f5e_o_kusl(g,1,3) } ;
                    valid {|g| f5e_o_kusl(g,2,3) }
          @ row(),col()+3 get mvrach when .f. color color14
        endif
        if mem_por_ass == x
          ++ix
          @ r1+ix,2 say "Таб.N зуб/техника" get mtabn_as pict "99999" ;
                    when {|g| f5e_o_kusl(g,1,4) } ;
                    valid {|g| f5e_o_kusl(g,2,4) }
          @ row(),col()+3 get massist when .f. color color14
          if mem_ort_ms == 2
            ++ix
            @ r1+ix,2 say "Таб.N медсестры" get mtabn_ms pict "99999" ;
                      when {|g| f5e_o_kusl(g,1,41) } ;
                      valid {|g| f5e_o_kusl(g,2,41) }
            @ row(),col()+3 get mmedses when .f. color color14
          endif
        endif
        if mem_por_kol == x
          ++ix
          if mem_ort_ysl == 1
            @ r1+ix,2 say "Количество услуг" get mkol pict "999.999" ;
                      when {|g| f5e_o_kusl(g,1,5) } ;
                      valid {|g| f5e_o_kusl(g,2,5) }
          else
            @ r1+ix,2 say "Количество услуг" get mkol pict "999.9" ;
                      when {|g| f5e_o_kusl(g,1,5) } ;
                      valid {|g| f5e_o_kusl(g,2,5) }
          endif
        endif
      next
      @ r1+10,2 say "Общая стоимость услуги" get mstoim pict pict_cena ;
               when {|g| mem_edit_s==2 .and. f5e_o_kusl(g,1,7) } ;
               valid {|g| f5e_o_kusl(g,2,7) }
      if mt_edit > 1
        @ r1+10,37 say "[ редактировалась стоимость услуги ]" color color13
      endif
      status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи")
      count_edit := myread(,@pos_read,++k_read)
      SetKey( K_F2, NIL )
      SetKey( K_F3, NIL )
      if lastkey() != K_ESC
        if emptyany(mu_kod,mdate_u1)
          func_error(4,"Введены не все данные!")
          loop
        elseif !mis_nul .and. empty(mstoim) //20.03.13
          func_error(4,"Не введена цена услуги!")
          loop
        elseif mem_vv_v_a == 1 .and. emptyall(mkod_vr,mkod_as)
          func_error(4,"Не введены врач и зубной техник!")
          loop
        else
          err_date_diap(mdate_u1,"Дата оказания услуги")
          mywait()
          select HU
          if nKey == K_INS
            Add1Rec(7)
            mrec_hu := hu->(recno())
            fl_found := .t.
            select TMP
            append blank
            rec_tmp := tmp->(recno())
            k := 1 // услуга добавлена оператором
          else
            goto (mrec_hu)
            G_RLock(forever)
            select TMP
            goto (rec_tmp)
            k := 2
          endif
          if m1tip_usl == OU_B_PLAT
            mvp[k,1]++
            mvp[k,2] += count_edit
          else
            mvu[k,1]++
            mvu[k,2] += count_edit
          endif
          glob_kod_ms := mkod_ms
          select HU
          replace hu->kod     with human->(recno()),;
                  hu->tip_usl with m1tip_usl,;
                  hu->kod_vr  with mkod_vr,;
                  hu->kod_as  with mkod_as,;
                  hu->kod_ms  with mkod_ms,;
                  hu->u_koef  with 1,;
                  hu->stoim   with mstoim,;
                  hu->u_kod   with mu_kod,;
                  hu->u_cena  with mu_cena,;
                  hu->t_edit  with mt_edit,;
                  hu->kol     with mkol,;
                  hu->date_u  with dtoc4(mdate_u1),;
                  hu->otd     with m1otd
          UNLOCK
          st_tip_usl := m1tip_usl
          pr1otd := m1otd
          adbf := array(fcount())
          aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
          select TMP
          aeval(adbf, {|x,i| fieldput(i,x) } )
          tmp->date_u1 := mdate_u1
          tmp->shifr_u := mshifr
          tmp->name_u := mname_u
          tmp->rec_hu := mrec_hu
          tmp->is_nul := mis_nul //15.12.13
        //last_date := max(tmp->date_u1,last_date) - так было
          last_date := tmp->date_u1  // - так стало
          summa_usl(@mcena)
          select HUMAN
          G_RLock(forever)
          human->cena := mcena
          UNLOCK
          COMMIT
        endif
      endif
      exit
    enddo
    flag := 0
    if nKey == K_INS .and. !fl_found
      flag := 1
    endif
    restscreen(buf)
    f3e_o_kusl()
    select TMP
    oBrow:goTop()
    goto (rec_tmp)
    setcolor(tmp_color)
  case nKey == K_DEL .and. tmp->kod > 0
    if f_Esc_Enter(2)
      mywait()
      // услуги удалены оператором
      if tmp->tip_usl == OU_B_PLAT
        mvp[3,1] ++
      else
        mvu[3,1] ++
      endif
      select HU
      goto (tmp->rec_hu)
      DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
      select TMP
      DeleteRec(.t.)  // с пометкой на удаление
      summa_usl(@mcena)
      select HUMAN
      G_RLock(forever)
      replace human->cena with mcena
      UNLOCK
      COMMIT
      select TMP
      oBrow:goTop()
      go top
      if eof()
        fl_found := .f. ; keyboard chr(K_INS)
      endif
      flag := 0
      restscreen(buf)
      f3e_o_kusl()
    endif
  otherwise
    keyboard ""
endcase
help_code := tmp_help
restuchotd(uch_otd)
return flag

*****
Static Function summa_usl(s)
Local j := 0
s := 0
select TMP
go top
do while !eof()
  s += tmp->stoim
  tmp->number := ++j
  skip
enddo
s := round(s,2)
return NIL

*

*****
Function f5e_o_kusl(get,when_valid,k)
Local fl := .t., s, old_kod,;
      msg1_err := "Код врача равен коду зубного техника! Это недопустимо.",;
      msg2_err := "Человека с таким кодом нет в базе данных персонала!",;
      blk_sum := {|| mstoim := round_5(mu_cena * mkol, 2) }
if when_valid == 1    // when
  if k == 2     // Шифр услуги
    if !empty(mshifr)
      fl := .f.
    endif
  elseif k == 3 // Код врача
    fl := vr_uva
  elseif k == 4 // Код зубного техника
    fl := as_uva
  elseif k == 41 // Код медсестры
    fl := ms_uva
  elseif k == 5 // Количество услуг
    if empty(mshifr)
      fl := .f.
    elseif mt_edit > 1
      fl := .f.
    endif
  elseif k == 7 // Общая стоимость услуги
    if empty(mshifr)
      fl := .f.
    endif
  elseif k == 10  // код отделения
    SetKey( K_F3, {|p,l,v| get1_otd(p,l,v,get:Row,get:Col)} )
    @ r1,45 say "<F3> - выбор отделения из меню" color color13
  endif
else                  // valid
  if k == 1     // Дата оказания услуги
    if !emptyany(human->n_data,mdate_u1) .and. mdate_u1 < human->n_data
      fl := func_error(4,"Введенная дата меньше даты начала лечения!")
    elseif !emptyany(human->k_data,mdate_u1) .and. mdate_u1 > human->k_data
      fl := func_error(4,"Введенная дата больше даты окончания лечения!")
    endif
  elseif k == 2 // Шифр услуги
    if !empty(mshifr) .and. !(mshifr == get:original)
      mshifr := transform_shifr(mshifr)
      select USL
      set order to 1
      find (mshifr)
      if found()
        mu_kod := usl->kod
        mname_u := usl->name
        mis_nul := usl->is_nulp
        mu_cena := 0
        mu_koef := 1
        if mis_nul  // услуга с нулевой ценой
          mu_cena := 0
        else
          if m1tip_usl != OU_B_PLAT
            // сначала берем цену для платных услуг
            mu_cena := if(smvzros_reb==0, usl->pcena, usl->pcena_d)
            if m1tip_usl==OU_D_SMO .and. usl->dms_cena > 0
              mu_cena := usl->dms_cena
            endif
          endif
        endif
        if empty(mu_cena)  // если не найдена, то берем обычную цену
          mu_cena := if(smvzros_reb==0, usl->cena, usl->cena_d)
        endif
        mkol := 1
        eval(blk_sum)
        verify_o_uva()
        update_gets()
      else
        fl := func_error(4,"Такого шифра нет в базе данных услуг.")
      endif
    endif
  elseif k == 3 // Код врача
    old_kod := mkod_vr
    if empty(mtabn_vr)
      mkod_vr := 0
      mvrach := space(35)
    else
      select PERSO
      find (str(mtabn_vr,5))
      if found()
        if perso->kod == mkod_as
          fl := func_error(4,msg1_err)
        elseif perso->kod == mkod_ms
          fl := func_error(4,msg1_err)
        else
          mkod_vr := perso->kod
          mvrach := padr(perso->fio,35)
        endif
      else
        fl := func_error(4,msg2_err)
      endif
    endif
    if old_kod != mkod_vr
      update_get("mvrach")
    endif
  elseif k == 4 // Код зубного техника
    old_kod := mkod_as
    if empty(mtabn_as)
      mkod_as := 0
      massist := space(35)
    else
      select PERSO
      find (str(mtabn_as,5))
      if found()
        if perso->kod == mkod_vr
          fl := func_error(4,msg1_err)
        elseif perso->kod == mkod_ms
          fl := func_error(4,msg1_err)
        else
          mkod_as := perso->kod
          massist := padr(perso->fio,35)
        endif
      else
        fl := func_error(4,msg2_err)
      endif
    endif
    if old_kod != mkod_as
      update_get("massist")
    endif
  elseif k == 41 // Код медсестры
    old_kod := mkod_ms
    if empty(mtabn_ms)
      mkod_ms := 0
      mmedses := space(35)
    else
      select PERSO
      find (str(mtabn_ms,5))
      if found()
        if perso->kod == mkod_vr
          fl := func_error(4,msg1_err)
        elseif perso->kod == mkod_as
          fl := func_error(4,msg1_err)
        else
          mkod_ms := perso->kod
          mmedses := padr(perso->fio,35)
        endif
      else
        fl := func_error(4,msg2_err)
      endif
    endif
    if old_kod != mkod_ms
      update_get("mmedses")
    endif
  elseif k == 5 // Количество услуг
    if !(round(mkol,3) == round(get:original,3))
      eval(blk_sum)
      update_gets()
    endif
  elseif k == 7 // Общая стоимость услуги
    if !(round(mstoim,2) == round_5(mu_cena * mkol, 2))
      if mt_edit == 0
        mt_edit := 2
      elseif mt_edit == 1
        mt_edit := 3
      endif
      @ r1+9,37 say "[ редактировалась стоимость услуги ]" color "W/B"
    endif
  elseif k == 10  // код отделения
    if (i := ascan(pr_arr, {|x| x[1] == m1otd } )) > 0
      motd := pr_arr[i,2] ; update_get("motd")
      SetKey( K_F3, NIL )
      @ r1,45 say space(30) color color13
    else
      fl := func_error(4,"Данный код отделения не найден!")
    endif
  endif
  if !fl
    &(readvar()) := get:original
  endif
endif
return fl

*

*****
Function pr_zak_nar(tip_print) //21.05.08
Static st_tip_usl := 0
Local i := 1, j, k, s, fl, buf := save_row(maxrow())
Local luchast := "", arr, mfam1, mima1, mots1, m1vid_ud,;
      m1kategor := atail(stm_kategor)[2]  // т.е. прочие (последнее значение)
Private file_sh1
if human->tip_usl == OU_B_PLAT  // бесплатно
  file_sh1 := mem_ort_bp
else
  file_sh1 := mem_ort_pl
endif
Private ;
  muchast     := 0                 ,; // участок
  mkod_kart   := 0                 ,; // код человека в картотеке
  mNAR_Z      := 0                 ,; // номер наряда-заказа
  mDATA       := sys_date          ,; // дата наряда-заказа
  MLPU, M1LPU := glob_uch[1]       ,; // код учреждения
  MOTD, M1OTD := glob_otd[1]       ,; // код отделения
  mUCH_DOC    := space(10)         ,; // вид и номер учетного документа
  mKOD_VR     := 0                 ,; // код врача
  mKOD_AS     := 0                 ,; // код зубного техника
  mkod_ms     := 0                 ,;
  mKOD_DIAG   := space(6)          ,; // шифр болезни
  mKOD_DIAG2  := space(6)          ,; // шифр болезни
  mKOD_DIAG3  := space(6)          ,; // шифр болезни
  MN_DATA     := ctod("")          ,; // дата начала лечения
  MK_DATA     := ctod("")          ,; // дата окончания лечения
  mKOL_POS    := 0                 ,; // количество посещений
  mn_och      := space(10)         ,; // номер очереди (для бесплатных больных)
  MPRICH, M1PRICH := 0             ,; // причина поломки протеза
  MKOL_MOSTP  := 0                 ,; // количество мостовидных протезов
  MKOL_CELNL  := 0                 ,; // в т.ч. цельнолитых
  mprim       := space(15)         ,; // примечание
  mfio        := space(50)         ,; // фио
  madres      := space(50)         ,; // адрес
  mmr_dol     := space(50)         ,; // место работы должность
  mdate_r     := ctod("")          ,; // дата рождения
  mst_summa   := ""                ,; // сумма наряда          //16.04.08
  mkod_human                       ,;
  mvid_ud                          ,; // вид удостоверения
  mnom                             ,;
  mser                             ,;                          //к16.04.08
  mtip_usl, m1tip_usl := st_tip_usl,;
  mtabn_vr := 0, mtabn_as := 0,;
  mvrach := massist := space(35),;
  mcena := 0, mcena_opl := 0,;
  mplat_fio, mplat_inn ,;
  mplat_adres, mplat_pasport
  //
  MKOD_DIAG   := human->KOD_DIAG      // шифр 1-ой осн.болезни
  MKOD_DIAG2  := human->KOD_DIAG2     // шифр 2-ой осн.болезни
  MKOD_DIAG3  := human->KOD_DIAG3     // шифр 3-ой осн.болезни
  mNAR_Z      := human->nar_z         // номер наряда-заказа
  mDATA       := human->data          // дата наряда-заказа
  M1LPU       := human->LPU           // код учреждения
  M1OTD       := human->OTD           // код отделения
  mUCH_DOC    := human->uch_doc       // вид и номер учетного документа
  mKOD_VR     := human->kod_vr        // код врача
  mKOD_AS     := human->kod_as        // код зубного техника
  MN_DATA     := human->N_DATA        // дата начала лечения
  MK_DATA     := human->K_DATA        // дата окончания лечения
  mKOL_POS    := human->kol_pos       // количество посещений
  M1PRICH     := human->PRICH_POL     // причина поломки протеза
  MKOL_MOSTP  := human->KOL_MOSTP     // количество мостовидных протезов
  MKOL_CELNL  := human->KOL_CELNL     // в т.ч. цельнолитых
  MCENA       := human->CENA          // стоимость лечения
  MCENA_OPL   := human->CENA_OPL      // сумма оплаты
  mkod_kart   := human->kod_k         // код в картотеке
  m1tip_usl   := human->tip_usl
  mn_och      := human->n_och
  mprim       := human->prim
  mkod_human  := human->(recno())
  mst_summa   := srub_kop(MCENA,.t.)  //16.04.08
  mplat_fio   := human->plat_fio
  mplat_inn   := human->plat_inn
//
R_Use(dir_server+"hum_orpl",dir_server+"hum_orpl","KPLAT")
find (str(human->(recno()),7))
if found()
  mplat_adres   := KPLAT->ADRES
  mplat_pasport := KPLAT->PASPORT
endif
KPLAT->(dbCloseArea())
//
R_Use(dir_server+"kartotek",,"KART")
goto (mkod_kart)
muchast     := kart->uchast
mfio        := kart->fio           // фио
madres      := kart->adres         // адрес
mmr_dol     := kart->mr_dol        // место работы должность
mdate_r     := kart->date_r        // дата рождения
kart->(dbclosearea())
R_Use(dir_server+"kartote_",,"KART_")
goto (mkod_kart)
m1vid_ud := kart_->vid_ud
mnom     := kart_->nom_ud
mser     := kart_->ser_ud
kart_->(dbCloseArea())
//
R_Use(dir_server+"mo_pers",,"PERSO")
goto (mkod_vr)
mvrach := padr(perso->fio,35)
mtabn_vr := perso->tab_nom
goto (mkod_as)
massist := padr(perso->fio,35)
mtabn_as := perso->tab_nom
perso->(dbclosearea())
//
mtip_usl := inieditspr(A__MENUVERT, menu_okb, m1tip_usl)
mlpu := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
motd := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
mprich := inieditspr(A__POPUPMENU, dir_server+"ort_brk", m1prich)
mvid_ud := ""
if (j := ascan(menu_vidud, {|x| x[2] == m1vid_ud})) > 0
  mvid_ud := menu_vidud[j,4]
endif
if empty(mser) ; mser := space(10) ; endif
if empty(mnom) ; mnom := space(10) ; endif
//mkod_kart := lstr(mkod_kart)
//mNAR_Z    := lstr(mNAR_Z)
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
adbf := dbstruct()
aadd(adbf, {"date_u1","D", 8,0} )
aadd(adbf, {"shifr_u","C",10,0} )
aadd(adbf, {"name_u", "C",65,0} )
aadd(adbf, {"number", "N", 3,0} )
aadd(adbf, {"rec_hu", "N", 7,0} )
dbcreate(cur_dir+"tmp_usl",adbf)
use (cur_dir+"tmp_usl") new alias tmp
if mem_ordusl == 1
  index on dtos(date_u1)+fsort_usl(shifr_u) to (cur_dir+"tmp_usl")
else
  index on fsort_usl(shifr_u)+dtos(date_u1) to (cur_dir+"tmp_usl")
endif
select HU
set relation to u_kod into USL
find (str(mkod_human,7))
if (fl_found := found())
  adbf := array(fcount())
  do while hu->kod == mkod_human .and. !eof()
    aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
    select TMP
    append blank
    aeval(adbf, {|x,i| fieldput(i,x) } )
    tmp->date_u1 := c4tod(hu->date_u)
    tmp->shifr_u := usl->shifr
    tmp->name_u := usl->name
    tmp->rec_hu := hu->(recno())
    select HU
    skip
  enddo
endif
usl->(dbclosearea())
//
// МАТЕРИАЛЫ
//
//Local arr, sh, HH := 58, s, s1, s2, s3, fl,;
//      begin_date, end_date, fl_exit := .f., name_file := "orto_mt"+stxt,;
//      tip_tit, s4
//Local reg, reg1, mperso, musluga, mkod
//Local msl1usluga, msl2usluga, l_delen, mslusluga

dbcreate(cur_dir+"tmp11", {;
   {"KOD",        "N",      4,      0},;  // код (услуги)
   {"KOL",        "N",     10,      3},;  // кол-во услуг
   {"STOIM",      "N",     14,      2} ;  // стоимость лечения
  })
dbcreate(cur_dir+"tmp12", {;
   {"KOL",        "N",     10,      3},;  // кол-во услуг
   {"tname",      "C",     80,      0} ;  // стоимость лечения
  })
use (cur_dir+"tmp12") new
use (cur_dir+"tmp11") new
index on str(kod,4) to (cur_dir+"tmp11")
R_Use(dir_server+"tip_orto",,"ORT")
R_Use(dir_server+"ortoped",,"OR")
R_Use(dir_server+"ortoped1",,"OR1")
R_Use(dir_server+"ortoped2",,"OR2")
//
select HU
find (str(mkod_human,7))
do while hu->kod == mkod_human .and. !eof()
  select TMP11
  find (str(hu->u_kod,4))
  if !found()
    append blank
    tmp11->kod := hu->u_kod
  endif
  tmp11->kol += hu->kol
  select HU
  skip
enddo
// пересчет в материал
arr_mt := {}
select TMP11
go top
do while !eof()
  select OR2
  go top
  locate for or2->kod_usl == tmp11->kod
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
            aadd(arr_mt, {or1->kod_ort,0,0,""} ) ; k := len(arr_mt)
          endif
          arr_mt[k,2] += tmp11->kol
          arr_mt[k,3] += or1->massa*tmp11->kol
        endif
        select OR1
        skip
      enddo
    endif
  endif
  select TMP11
  skip
enddo
// присваиваем наименование
if len(arr_mt) > 0
  select OR
  for i := 1 to len(arr_mt)
    goto (arr_mt[i,1])
    arr_mt[i,4] := or->name
  next
  select TMP12
  append blank
  tmp12->tname := "   ТЕХНИК"
  select OR
  for i := 1 to len(arr_mt)
    if arr_mt[i,3] > 0
      select TMP12
      append blank
      tmp12->tname := arr_mt[i,4]
      tmp12->kol   := arr_mt[i,3]
      select OR
    endif
  next
endif
//
// Итого по техникам
// пересчет в материал
select HU
find (str(mkod_human,7))
do while hu->kod == mkod_human .and. !eof()
  select TMP11
  find (str(hu->u_kod,4))
  if !found()
    append blank
    tmp11->kod := hu->u_kod
  endif
  tmp11->kol += hu->kol
  select HU
  skip
enddo

// пересчет в материал
arr_mt := {}
select TMP11
go top
do while !eof()
  select OR2
  go top
  locate for or2->kod_usl == tmp11->kod
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
            aadd(arr_mt, {or1->kod_ort,0,0,""} ) ; k := len(arr_mt)
          endif
          arr_mt[k,2] += tmp11->kol
          arr_mt[k,3] += or1->massa*tmp11->kol
        endif
        select OR1
        skip
      enddo
    endif
  endif
  select TMP11
  skip
enddo
// присваиваем наименование
if len(arr_mt) > 0
  select OR
  for i := 1 to len(arr_mt)
    goto (arr_mt[i,1])
    arr_mt[i,4] := or->name
  next
  select TMP12
  append blank
  tmp12->tname := "   ВРАЧ"
  select OR
  for i := 1 to len(arr_mt)
    if arr_mt[i,3] > 0
      select TMP12
      append blank
      tmp12->tname := arr_mt[i,4]
      tmp12->kol   := arr_mt[i,3]
      select OR
    endif
  next
  add_string("")
endif
//
tmp11->(dbclosearea())
//
orto_list_uch(tip_print)
rest_box(buf)
close databases
return NIL

*

*****
Function orto_list_uch(tip_print)
Local sh := 80, HH := 55, buf := save_row(maxrow()), regim_print := 2
Local i := 1, j, k, tmp[2], tmp1, w1 := 65, s, fl, rec
Local n_file := "narad"+stxt, arr, mfam1, mima1, mots1, m1vid_ud
if tip_print == 1
  if !empty(file_sh1)
    f1_pr_shab(file_sh1)
  endif
else
  Private file_sh
  if !empty(mem_ort_dog) .and. ;
     !empty(file_sh := menu_shablon(3,3,dir_exe+"*."+alltrim(mem_ort_dog),color8,.f.))
    select TMP
    go top
    f1_pr_shab(file_sh)
  endif
endif
return NIL

*

***** поиск свободного номера наряда (на 1 больше максимального)
Function poisk_svob()
Local myear, buf := save_row(maxrow()), arr, mvar := readvar(), ;
      psvob := 0, REC, i, old_plat := mnar_z, vr_sel, rec1,;
      nrow := row(), ncol := col(), icurs := setcursor(0), index_ord
save gets to arr
if (myear := input_value(18,2,20,77,cColorStMsg,;
                space(11)+"По какому году искать свободный номер наряда",;
                year(sys_date),"9999")) != NIL
  mywait()
  rec := recno()
  vr_sel := select()
  select HUMAN
  rec1 := recno()
  index_ord := indexord()
  set order to 4
  dbseek (dtos(boy(mdata)),.t.)
  do while !eof()
    if m1tip_usl == human->tip_usl
      psvob := max(psvob,human->nar_z)
    endif
    skip
  enddo
  set order to index_ord
  goto (rec1)
  SELECT(vr_sel)
  goto (rec)
  rest_box(buf)
  if psvob == 999999
    n_message({"В "+lstr(myear)+" году максимальный номер наряда - 999999.",;
               "В принципе невозможно для одной организации за год"},;
               {"Нажмите любую клавишу"},cColorStMsg,cColorStMsg,17,,"BG+/R")
    myear := NIL
  else
    ++psvob
    if !empty(old_plat)
      n_message({"В "+lstr(myear)+" году свободный номер наряда - "+lstr(psvob)+"."},,;
                  cColorStMsg,cColorStMsg,17,,"BG+/R")
    endif
  endif
endif
restore gets from arr
if myear != NIL .and. empty(mnar_z) .and. ;
   f_message({"В "+lstr(myear)+" году свободный номер наряда - "+lstr(psvob)+".",;
              "При нажатии <Enter> это значение будет скопировано в поле ввода.",;
              "<Esc> - отказ от копирования."},"W",;
              cColorStMsg,cColorStMsg,17) == K_ENTER
  mnar_z := psvob
  update_get("mnar_z")
endif
@ nrow,ncol say ""
if icurs != 0
  setcursor()
endif
return NIL

*

*****
Function input_uchast()
Local such := 0
Local nuch, fl := .f.
if (nuch := input_value(18,10,20,69,color0,;
                        space(16)+"Введите номер участка",;
                        such,"99")) != NIL .and. nuch >= 0
  such := nuch ; fl := .t.
endif
return iif(fl, nuch, NIL)

*****
Function ret_uchast(r,c)
Static si1 := 1, such := 0
Local mas_pmt, mas_msg, j, arr := {}, luch := "", s, i, k, k1, k2
if is_uchastok > 0
  mas_pmt := {"По ~всем больным",;
              "По одному ~участку",;
              "По ~прикрепленным участкам"}
  mas_msg := {"Распечатка формы по всем больным",;
              "Распечатка формы по больным конкретного участка",;
              "Распечатка формы по прикрепленной территории"}
  arr := nil
  if (j := popup_prompt(r,c,si1,mas_pmt,mas_msg)) > 0
    si1 := j
    if j == 1
      arr := {}
    elseif j == 2
      if (luch := input_value(20,15,22,64,color1,;
                              space(10)+"Введите номер участка",;
                              such,"99")) != NIL .and. luch >= 0
        arr := {luch} ; such := luch
      endif
    elseif j == 3
      if hb_FileExists(file_uchast)
        luch := filestr(file_uchast)
      endif
      if (luch := input_value(20,2,22,77,color1,;
              "Прикрепленные участки (напр.: 1-20,23)",;
              padr(luch,100),"@S34")) != NIL .and. !empty(luch)
        arr := {}
        for i := 1 to numtoken(luch,",")
          s := token(luch,",",i)
          if "-" $ s
            k1 := int(val(token(s,"-",1)))
            k2 := int(val(token(s,"-",2)))
            for k := k1 to k2
              if k > 0
                aadd(arr,k)
              endif
            next
          else
            k := int(val(s))
            if k > 0
              aadd(arr,k)
            endif
          endif
        next
        if len(arr) == 0
          arr := nil
          func_error(4,"Некорректно введен список прикрепленных участков.")
        else
          strfile(alltrim(luch),file_uchast)
        endif
      endif
    endif
  endif
endif
return arr

*****
Function get_uchast(r,c)
// должен быть определен "Private arr_uchast := {}"
Local k := ret_uchast(r,c)
if k == NIL
  arr_uchast := {}
  r := 0
else
  arr_uchast := aclone(k)
  r := iif(len(k) == 0, 0, 1)
endif
return {r,init_uchast(arr_uchast)}

*****
Function init_uchast(arr)
Local i, s := "все пациенты"
if valtype(arr) == "A" .and. len(arr) > 0
  if len(arr) == 1
    s := "№ "+lstr(arr[1])
  else
    if hb_FileExists(file_uchast)
      s := filestr(file_uchast)
    else
      s := ""
      for i := 1 to len(arr)
        s += lstr(arr[i])+","
      next
      s := left(s,len(s)-1)
    endif
  endif
endif
return s

*****
Function f_is_uchast(st_a_uchast,luch)
Local fl := .t.
if len(st_a_uchast) > 0
  fl := (ascan(st_a_uchast,luch) > 0)
endif
return fl

*****
Function title_uchast(st_a_uchast,sh)
if st_a_uchast != NIL .and. len(st_a_uchast) > 0
  if len(st_a_uchast) == 1
    add_string(center("[ по участку номер "+lstr(st_a_uchast[1])+" ]",sh))
  else
    add_string(center("[ по прикрепленной территории ]",sh))
  endif
endif
return NIL

*
***** 05.09.18
Function Ort_nar_material()
Local arr, sh, HH := 58, s, s1, s2, s3, fl,;
      begin_date, end_date, fl_exit := .f., name_file := "orto_mt"+stxt,;
      tip_tit, s4,;
    arr_title := {;
"────────────────────────────────────────────────────────────┬──────────────",;
"                    Наименование материала                  │    Расход    ",;
"────────────────────────────────────────────────────────────┴──────────────"}
Local reg, reg1, mperso, musluga, mkod, buf := save_row(maxrow())
Local msl1usluga, msl2usluga, l_delen, mslusluga
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
sh := len(arr_title[1])
add_string("")
add_string(center("Предварительный Расход материалов",sh))
add_string("")

dbcreate(cur_dir+"tmp", {;
   {"KOD",        "N",      4,      0},;  // код (услуги)
   {"KOL",        "N",     10,      3},;  // кол-во услуг
   {"STOIM",      "N",     14,      2} ;  // стоимость лечения
  })
use (cur_dir+"tmp") new
index on str(kod,4) to (cur_dir+"tmp")
R_Use(dir_server+"tip_orto",,"ORT")
R_Use(dir_server+"ortoped",,"OR")
R_Use(dir_server+"ortoped1",,"OR1")
R_Use(dir_server+"ortoped2",,"OR2")
R_Use(dir_server+"hum_oru",dir_server+"hum_oru","HU")
//
select HU
find (str(human->(recno()),7))
do while hu->kod == human->(recno()) .and. !eof()
  select TMP
  find (str(hu->u_kod,4))
  if !found()
    append blank
    tmp->kod := hu->u_kod
  endif
  tmp->kol += hu->kol
  select HU
  skip
enddo
select HUMAN
skip
// пересчет в материал
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
            aadd(arr_mt, {or1->kod_ort,0,0,""} ) ; k := len(arr_mt)
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
  next
  add_string("   ТЕХНИК")
  aeval(arr_title, {|x| add_string(x) } )
  for i := 1 to len(arr_mt)
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if arr_mt[i,3] > 0
      add_string(padr(arr_mt[i,4],60)+" "+umest_val(arr_mt[i,3],12,3))
    endif
  next
  add_string("")
endif
//
// Итого по техникам
// пересчет в материал
select HU
find (str(human->(recno()),7))
do while hu->kod == human->(recno()) .and. !eof()
  select TMP
  find (str(hu->u_kod,4))
  if !found()
    append blank
    tmp->kod := hu->u_kod
  endif
  tmp->kol += hu->kol
  select HU
  skip
enddo
select HUMAN
skip
// пересчет в материал
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
            aadd(arr_mt, {or1->kod_ort,0,0,""} ) ; k := len(arr_mt)
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
  next
  add_string("   ВРАЧ")
  aeval(arr_title, {|x| add_string(x) } )
  for i := 1 to len(arr_mt)
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if arr_mt[i,3] > 0
      add_string(padr(arr_mt[i,4],60)+" "+umest_val(arr_mt[i,3],12,3))
    endif
  next
  add_string("")
endif
//
close databases
fclose(fp)
rest_box(buf)
if !fl_exit
  viewtext(name_file)
endif
return NIL

*

*****
Function verify_o_uva(reg)
Local i
DEFAULT reg TO 1
if len(arr_uva) > 0 .and. ;
            (i := ascan(arr_uva, {|x| like(x[1],alltrim(mshifr)) } )) > 0
  if arr_uva[i,2] == 1
    vr_uva := .f.
    mkod_vr := 0 ; mvrach := space(35)
    mtabn_vr := 0
  endif
  if arr_uva[i,3] == 1
    as_uva := .f.
    mkod_as := 0 ; massist := space(35)
    mtabn_as := 0
  endif
  if arr_uva[i,4] == 1
    ms_uva := .f.
    mkod_ms := 0 ; mmedses := space(35)
    mtabn_ms := 0
  endif
endif
return NIL
