***** mo_kek.prg - режимы ввода данных для задачи "КЭК"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 26.06.13
Function begin_task_kek()
Static n_zapusk := 0
Local i, ar, fl := .t.
if n_zapusk == 0
  ++n_zapusk
  Public mem_ball_kek := 0, mem_ocen_kek := 0, kek_otd := {0,""}, kek_vrach := {0,""}
  init_menus_kek()
endif
if G_SIsLock(sem_vagno_task[X_KEK])
  fl := f_err_sem_vagno_task(X_KEK)
elseif copy_Tools_Ini()
  Tools_Ini_OMS(1,0,0)
  ar := GetIniSect(local_tools_ini,"КЭК")
  mem_ball_kek := int(val(a2default(ar,"ball_kek","0")))
  mem_ocen_kek := int(val(a2default(ar,"ocen_kek","0")))
else
  fl := .f.
endif
return fl

*****
Function is_admin_kek()
return tip_polzovat == TIP_ADM .or. grup_polzovat == 3

*

***** 26.06.13
Function kek_nastr()
Static mm_ball := {{'от 0 до 1',0},{'от 0 до 5',1}}
Static mm_prik := {{'до 0.7 - "2", до 0.8 - "3", до 0.9 - "4", до 1 - "5"',0},;
                   {'до 0.86 - "2", до 0.928 - "3", до 0.964 - "4", до 1 - "5"',1}}
Local mm_tmp := {}, buf, old_ball, old_ocen, name_section := "КЭК"
if !is_admin_kek()
  return func_error(4,"Доступ запрещён!")
endif
buf := save_maxrow() ; mywait()
close databases
delete file tmp.dbf
aadd(mm_tmp, {"ball","N",1,0,NIL,;
              {|x|menu_reader(x,mm_ball,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_ball,x)},;
              'Балльная система'})
aadd(mm_tmp, {"prik","N",1,0,NIL,;
              {|x|menu_reader(x,mm_prik,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_prik,x)},;
              'Правило подсчета оценки'})
init_base(cur_dir+"tmp",,mm_tmp,0)
use (cur_dir+"tmp") new
append blank
old_ball := tmp->ball := mem_ball_kek
old_ocen := tmp->prik := mem_ocen_kek
close databases
if f_edit_spr(A__EDIT,mm_tmp,"настройке КЭК","g_use(cur_dir+'tmp',,,.t.,.t.)",0,1) > 0
  use (cur_dir+"tmp") new
  mem_ball_kek := tmp->ball
  mem_ocen_kek := tmp->prik
  use
  if !(old_ocen == mem_ocen_kek .and. old_ball == mem_ball_kek)
    if Semaphor_Tools_Ini(1)
      // запись секции в ini.файл
      SetIniSect(tools_ini, name_section, {{"ocen_kek",mem_ocen_kek},;
                                           {"ball_kek",mem_ball_kek}})
      Semaphor_Tools_Ini(2)
      /*
      n_message({'Вы сменили признак',;
                 '"По какому приказу подсчитывать оценки"',;
                 'Изменения вступят в силу только',;
                 'после ПЕРЕИНДЕКСИРОВАНИЯ'},,cColorStMsg,cColorSt2Msg,,,"G+/R")
      */
    else
      func_error(4,"Не удалось записать настройки!")
    endif
  endif
endif
close databases
rest_box(buf)
return NIL

*

*****
Function ret_kek_otd(k,r,c,am,par)
Local ret, d1, d2
DEFAULT k TO kek_otd[1], par TO 1
if par == 1
  d1 := am[5] ; d2 := am[6]
else
  d1 := am[2,1] ; d2 := am[1,2]
endif
dbcreate(cur_dir+"tmp_kek",{{"kod","N",4,0},;
                            {"name","C",30,0}})
use (cur_dir+"tmp_kek") new
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"mo_kekh",,"HU")
set relation to otd into OTD
index on otd to (cur_dir+"tmp") for between(k_data,d1,d2) UNIQUE
dbeval({|| tmp_kek->(__dbAppend()), ;
           tmp_kek->kod := hu->otd, ;
           tmp_kek->name := otd->name })
close databases
if (ret := popup_edit("tmp_kek",r,c,22,k,PE_RETURN,,,,,,,,"Выбор отделения","B/BG")) != NIL
  kek_otd := {ret[1],alltrim(ret[2])}
endif
return ret

*

*****
Function ret_kek_vr(k,r,c,am,par)
Local ret, d1, d2
DEFAULT k TO kek_vrach[1], par TO 1
if par == 1
  d1 := am[5] ; d2 := am[6]
else
  d1 := am[2,1] ; d2 := am[1,2]
endif
dbcreate(cur_dir+"tmp_kek",{{"kod","N",4,0},;
                            {"name","C",50,0}})
use (cur_dir+"tmp_kek") new
R_Use(dir_server+"mo_pers",,"PERS")
R_Use(dir_server+"mo_kekh",,"HU")
set relation to vrach into PERS
index on vrach to (cur_dir+"tmp") for between(k_data,d1,d2) UNIQUE
dbeval({|| tmp_kek->(__dbAppend()), ;
           tmp_kek->kod := hu->vrach, ;
           tmp_kek->name := alltrim(pers->fio)+iif(empty(pers->tab_nom),""," ["+lstr(pers->tab_nom)+"]") })
close databases
if (ret := popup_edit("tmp_kek",r,c,22,k,PE_RETURN,,,,,,,,"Выбор врача","B/BG")) != NIL
  kek_vrach := {ret[1],alltrim(ret[2])}
endif
return ret

*

*****
Function kek_vvod(k)
Static si1 := 2, si2 := 1, si3 := 1
Local mas_pmt, mas_msg, mas_fun, j, ao
DEFAULT k TO 1
do case
  case k == 1  // добавление
    mas_pmt := {"Выбор по ~ФИО больного",;
                "Выбор по ~отделению"}
    mas_msg := {"Выбор больного по ФИО и добавление экспертизы",;
                "Выбор больного по отделению и добавление экспертизы"}
    mas_fun := {"kek_vvod(11)",;
                "kek_vvod(12)"}
    popup_prompt(T_ROW,T_COL+5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 2  // редактирование
    if is_admin_kek()
      if (j := _work_eks(,,@ao,.t.)) != NIL
        f3_kek_vvod(1,j,ao)
      endif
    else
      f3_kek_vvod(1,,_work_otd())
    endif
  case k == 3  // удаление
    if is_admin_kek()
      if (j := _work_eks(,,@ao,.t.)) != NIL
        f3_kek_vvod(2,j,ao)
      endif
    else
      f3_kek_vvod(2,,_work_otd())
    endif
  case k == 11  // выбор по ФИО больного
    if polikl1_kart() > 0
      f1_kek_vvod()
    endif
  case k == 12  // выбор по отделению
    Private arr_m
    if (arr_m := year_month(T_ROW,T_COL+5)) != NIL .and. ;
             input_uch(T_ROW,T_COL+5,arr_m[5],arr_m[6]) != NIL .and. ;
                 input_otd(T_ROW,T_COL+5,arr_m[5],arr_m[6]) != NIL
      f2_kek_vvod()
    endif
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

*

***** 24.02.17
Function for_f1_kek_vvod()
Local fl := (schet > 0 .and. human_->oplata < 9)
if fl
  if year(k_data) < 2017 
    fl := (human_->USL_OK == 1)
  else
    fl := between(human_->USL_OK,1,3)
  endif
endif
return fl

***** 24.02.17
Function f1_kek_vvod()
Local buf := save_maxrow(), blk, t_arr[BR_LEN]
Private rec_h := 0, rec_k := 0, _art[5]
mywait()
R_Use(dir_server+"mo_kekh",dir_server+"mo_kekh","KH")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2, to otd into OTD,;
             to schet   into SCHET_, to str(human->kod,7) into KH
find (str(glob_kartotek,7))
index on dtos(k_data) to (cur_dir+"tmp_h") ;
      for for_f1_kek_vvod() ;
      while kod_k == glob_kartotek ;
      DESCENDING
go top
if eof()
  func_error(4,"Не найдено закрытых листов учета по данному пациенту!")
else
  go top
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := 22
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_TITUL] := glob_k_fio
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
  blk := {|| iif(empty(kh->kol_eks), {1,2}, {3,4}) }
  t_arr[BR_COLUMN] := {{" Отд.", {|| otd->short_name  }, blk },;
                       {"усл.", {|| {"стац","дн.с","пол."}[iif(between(human_->usl_ok,1,3),human_->usl_ok,1)] }, blk },;
                       {"№ ист.бол;амб.карты", {|| left(human->uch_doc,9) }, blk },;
                       {" Сроки лечения", {|| left(date_8(human->n_data),5)+"-"+date_8(human->k_data) }, blk },;
                       {"МКБ10", {|| human->kod_diag }, blk },;
                       {" Стоимость", {|| put_kop(human->cena_1,10) }, blk },;
                       {" № счета", {|| left(schet_->nschet,12) }, blk },;
                       {"  Дата", {|| date_8(schet_->dschet) }, blk },;
                       {"Экс", {|| kh->kol_eks }, blk }}
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор истории болезни/мед.карты для экспертизы") }
  t_arr[BR_EDIT] := {|nk,ob| f1_s_kek_vvod(nk,ob,"edit") }
  edit_browse(t_arr)
endif
close databases
rest_box(buf)
if rec_h > 0
  add_eks(rec_h,rec_k,_art)
endif
return NIL

***** 26.02.17
Function f1_s_kek_vvod(nKey,oBrow,regim)
Local ret := -1
if regim == "edit" .and. nKey == K_ENTER
  if f11_s_kek_vvod(kh->kol_eks)
    _art[1] := alltrim(human->fio)
    _art[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)+" ["+;
               {"стационар","днев.стационар","поликлиника"}[iif(between(human_->usl_ok,1,3),human_->usl_ok,1)]+"]"
    _art[3] := "Период лечения: "+date_8(human->n_data)+"-"+date_8(human->k_data)
    _art[4] := "Основной диагноз: "+human->kod_diag
    _art[5] := "Стоимость лечения: "+lput_kop(human->cena_1)
    rec_h := human->kod
    if !kh->(eof())
      rec_k := kh->(recno())
    endif
    ret := 1
  endif
endif
return ret

*****
Function f11_s_kek_vvod(s)
Local fl := .t., i
for i := 1 to 3
  if lstr(i) $ s
    //if i >= grup_polzovat
    if i == grup_polzovat
      fl := func_error(4,"Группа экспертизы: "+lstr(i)+" уже проводилась по данной истории болезни")
    endif
  endif
next
return fl

***** 24.02.17
Function for_f2_kek_vvod()
Local fl := (schet > 0 .and. otd == glob_otd[1] .and. human_->oplata < 9)
if fl
  if year(k_data) < 2017 
    fl := (human_->USL_OK == 1)
  else
    fl := between(human_->USL_OK,1,3)
  endif
endif
return fl

***** 24.02.17
Function f2_kek_vvod()
Local buf := save_maxrow(), blk, t_arr[BR_LEN]
Private rec_h := 0, rec_k := 0, _art[5]
mywait()
R_Use(dir_server+"mo_kekh",dir_server+"mo_kekh","KH")
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2, ;
             to kod_k   into KART,   to schet   into SCHET_, ;
             to str(human->kod,7) into KH
dbseek(arr_m[5],.t.)
index on upper(kart->fio)+str(descend(k_data)) to (cur_dir+"tmp_h") ;
      for for_f2_kek_vvod() ;
      while k_data <= arr_m[6]
go top
if eof()
  func_error(4,"Не найдено закрытых листов учета по данному отделению!")
else
  go top
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow()-4
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_TITUL] := glob_otd[2]+" / "+arr_m[4]
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
  blk := {|| iif(empty(kh->kol_eks), {1,2}, {3,4}) }
  t_arr[BR_COLUMN] := {{" Ф.И.О.", {|| padr(fam_i_o(human->fio),10)  }, blk },;
                       {"№ ист.бол;амб.карты", {|| left(human->uch_doc,9) }, blk },;
                       {" Сроки лечения", {|| left(date_8(human->n_data),5)+"-"+date_8(human->k_data) }, blk },;
                       {"МКБ10", {|| human->kod_diag }, blk },;
                       {" Стоимость", {|| put_kop(human->cena_1,10) }, blk },;
                       {" № счета", {|| left(schet_->nschet,12) }, blk },;
                       {"  Дата", {|| date_8(schet_->dschet) }, blk },;
                       {"Экс", {|| kh->kol_eks }, blk }}
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор истории болезни для экспертизы") }
  t_arr[BR_EDIT] := {|nk,ob| f1_s_kek_vvod(nk,ob,"edit") }
  t_arr[BR_STEP_FUNC] := {|| step_f2_kek_vvod(1) }
  step_f2_kek_vvod(0)
  edit_browse(t_arr)
  step_f2_kek_vvod(2)
endif
close databases
rest_box(buf)
if rec_h > 0
  add_eks(rec_h,rec_k,_art)
endif
return NIL

***** 26.08.14
Function step_f2_kek_vvod(k)
Static buf
Local s
if k == 0
  buf := box_shadow(maxrow()-3,0,maxrow()-1,79,color1,"ФИО, дата рождения пациента, условия оказания медпомощи","B+/B")
elseif k == 1
  s := alltrim(human->fio)+", "+full_date(human->date_r)+" "+;
       {"стационар","днев.стационар","поликлиника"}[iif(between(human_->usl_ok,1,3),human_->usl_ok,1)]
  @ maxrow()-2,1 say padc(s,78) color color14
elseif k == 2
  rest_box(buf)
endif
return NIL

*

***** 24.02.17
Function f3_kek_vvod(k,at,ao)
Static srec := 0
Local buf := save_maxrow(), blk, n, t_arr[BR_LEN]
DEFAULT at TO {alltrim(fio_polzovat)+" (гр."+lstr(grup_polzovat)+") "+;
               alltrim(dolj_polzovat), asc(kod_polzovat)}
Private rec_e := 0, rec_k := 0, _art[5], _pregim := k, is_own := (asc(kod_polzovat) == at[2])
mywait()
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to kod_k into KART, to recno() into HUMAN_, to otd into OTD
R_Use(dir_server+"mo_kekh",,"KH")
set relation to kod_lu into HUMAN
R_Use(dir_server+"mo_keke",dir_server+"mo_kekee","KE")
set relation to kod into KH
find (str(at[2],3))
if ao == NIL
  index on str(descend(date_eks))+upper(kart->fio) to (cur_dir+"tmp_ke") ;
        while kod_eks == at[2]
else
  index on str(descend(date_eks))+upper(kart->fio) to (cur_dir+"tmp_ke") ;
        for human->otd == ao[1] ;
        while kod_eks == at[2]
endif
go top
if eof()
  func_error(4,"Не найдено добавленных Вами экспертиз!")
else
  go top
  if srec > 0
    Locate for recno() == srec
    if !found()
      go top
    endif
  endif
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := 22
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_TITUL] := charone(" ",at[1])
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N, R/BG,W+/R, B/BG,W+/B, GR/BG,W+/GR, RB/BG,W+/RB",.t.}
  blk := {|| iif(ke->p_zapol==100, ;
                 iif(ke->o_all==5,{1,2},;
                     iif(ke->o_all==4,{5,6},;
                         iif(ke->o_all==3,{7,8},{9,10}))), {3,4}) }
  n := iif(mem_ball_kek == 0, 17, 20)+4
  t_arr[BR_COLUMN] := {{" Ф.И.О.", {|| padr(fam_i_o(kart->fio),n) }, blk },;
                       {" Отд.", {|| otd->short_name  }, blk },;
                       {"усл.;оказ", {|| {"стац","дн.с","пол."}[iif(between(human_->usl_ok,1,3),human_->usl_ok,1)] }, blk },;
                       {" Сроки лечения", {|| left(date_8(human->n_data),5)+"-"+date_8(human->k_data) }, blk },;
                       {" МКБ ", {|| kh->kod_diag }, blk },;
                       {"Дата эк-;спертизы", {|| date_8(ke->date_eks) }, blk },;
                       {" % ;зап", {|| str(ke->p_zapol,3) }, blk },;
                       {"Экс", {|| kh->kol_eks }, blk }}
  if mem_ball_kek == 0
    aadd(t_arr[BR_COLUMN], {"Балл", {|| str_0(ke->o_e,5,3) }, blk })
    aadd(t_arr[BR_COLUMN], {"О", {|| str(ke->o_all,1) }, blk })
  else
    aadd(t_arr[BR_COLUMN], {"Балл", {|| str_0(ke->o_e*5,4,2) }, blk })
  endif
  do case
    case _pregim == 1
      t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - редактирование") }
    case _pregim == 2
      t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Del>^ - удаление") }
    case _pregim == 3
      t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - печать экспертной карты") }
  endcase
  t_arr[BR_EDIT] := {|nk,ob| f3_s_kek_vvod(nk,ob,"edit") }
  edit_browse(t_arr)
endif
close databases
rest_box(buf)
if rec_k > 0
  srec := rec_e
  do case
    case _pregim == 1  // редактирование
      e_eks(2,rec_k,rec_e,_art)
    case _pregim == 2  // удаление
      del_eks(rec_k,rec_e,_art)
    case _pregim == 3  // печать
      kek_prn_karta(rec_k,rec_e,_art)
  endcase
endif
return NIL

***** 26.02.17
Function f3_s_kek_vvod(nKey,oBrow,regim)
Local ret := -1
if regim == "edit" .and. iif(_pregim == 2, nKey == K_DEL, nKey == K_ENTER)
  _art[1] := alltrim(kart->fio)
  _art[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", kh->otd)+" ["+;
             {"стационар","днев.стационар","поликлиника"}[iif(between(kh->usl_ok,1,3),kh->usl_ok,1)]+"]"
  _art[3] := "Период лечения: "+date_8(human->n_data)+"-"+date_8(human->k_data)
  _art[4] := "Основной диагноз: "+kh->kod_diag
  _art[5] := "заполнение "+lstr(ke->p_zapol)+"%; балл "+alltrim(str_0(ke->o_e,5,3))+"; оценка "+str(ke->o_all,1)
  rec_k := ke->kod
  rec_e := ke->(recno())
  ret := 1
endif
return ret

*

***** 24.02.17
Function add_eks(rec_human,kek_human,art)
Local i, c, arr, fl := .f.
Private is_own := .t.
if kek_human == 0
  fl := .t.
  R_Use(dir_server+"human_2",,"HUMAN_2")
  goto (rec_human)
  R_Use(dir_server+"human_",,"HUMAN_")
  goto (rec_human)
  R_Use(dir_server+"human",,"HUMAN")
  goto (rec_human)
  R_Use(dir_server+"kartote_",,"KART_")
  goto (human->kod_k)
  R_Use(dir_server+"kartotek",,"KART")
  goto (human->kod_k)
  mist_dohod := iif(kart->RAB_NERAB==0, 1, 3)
  //
  mdiag := ""
  arr := {human->KOD_DIAG2,human->KOD_DIAG3,human->KOD_DIAG4,;
          human->SOPUT_B1,human->SOPUT_B2,human->SOPUT_B3,human->SOPUT_B4}
  for i := 1 to len(arr)
    if !empty(arr[i])
      if !empty(mdiag)
        mdiag += ","
      endif
      mdiag += alltrim(arr[i])
    endif
  next
  mdiago := ""
  arr := {human_2->OSL1,human_2->OSL2,human_2->OSL3}
  for i := 1 to len(arr)
    if !empty(arr[i])
      if !empty(mdiago)
        mdiago += ","
      endif
      mdiago += alltrim(arr[i])
    endif
  next
  //
  mishod := 1
  do case
    case eq_any(human_->rslt_new,105,106,205,206,313,405,406,411)
      mishod := 5 // летальный исход
    case eq_any(human_->ishod_new,101,201,301)
      mishod := 1 // выздоровление (выраженное улучшение)
    case eq_any(human_->ishod_new,102,202,302,303,401)
      mishod := 2 // улучшение
    case eq_any(human_->ishod_new,104,204,305,403)
      mishod := 4 // ухудшение
    otherwise 
      mishod := 3 // без изменений
  endcase
  //
  mvrach := human_->vrach
  //
  mdni := 0
  if eq_any(human_->usl_ok,1,2) .or. empty(mvrach)
    R_Use(dir_server+"uslugi",,"USL")
    R_Use(dir_server+"human_u",dir_server+"human_u","H_USL")
    find (str(human->kod,7))
    do while h_usl->kod == human->kod .and. !eof()
      if empty(mvrach)
        mvrach := h_usl->kod_vr
      endif
      usl->(dbGoto(h_usl->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
        lshifr := usl->shifr
      endif
      if left(lshifr,4) == "1.7." .or. left(lshifr,5) == "1.10."
        mdni := human->k_data - human->n_data
        if empty(mvrach)
          mvrach := h_usl->kod_vr
        endif
        exit
      elseif eq_any(left(lshifr,5),"1.11.","55.1.")
        mdni += h_usl->kol
      endif
      select H_USL
      skip
    enddo
  endif
  kek_otd[1] := motd := human->otd
  //
  mgitel := 6
  s := left(kart_->okatog,8)
  if left(s,2) == '18'
    if left(s,5) == '18401'
      mgitel := 1  // Волгоград
    else
      mgitel := 4
      if s == '18410000'  // ВОЛЖСКИЙ
        mgitel := 2
      elseif s == '18415000' // КАМЫШИН
        mgitel := 3
      endif
    endif
  endif
  //
  Use_base("mo_kekh")
  AddRec(7)
  hu->KOD_LU := rec_human
  hu->OTD := motd
  hu->usl_ok := human_->usl_ok
  hu->VRACH := mvrach
  hu->IST_BOL := human->UCH_DOC
  hu->K_DATA := human->K_DATA
  hu->KOJKO_DNI := mdni
  hu->IST_DOHOD := mist_dohod
  hu->GITEL := mgitel
  hu->DIAG_POST := ""
  hu->DIAG_PRED := human_->KOD_DIAG0
  hu->KOD_DIAG := human->KOD_DIAG
  hu->DIAG_OSN := ""
  hu->DIAG_OSL := mdiago
  hu->DIAG_SOP := mdiag
  hu->DIAG_KON := ""
  hu->PLAN_EKS := val(left(human_->FORMA14,1))+1
  hu->SOGLASIE := 1
  if !empty(human_->NPR_MO)
    hu->PUTI_POS := 1  // направление
  elseif substr(human_->FORMA14,2,1) == '1'
    hu->PUTI_POS := 2  // доставлен скорой помощью
  else
    hu->PUTI_POS := 3  // самообращение
  endif
  hu->POST_ST := 1
  hu->GOSPIT := 1
  hu->ISHOD := mishod
  hu->POVOD_EKS := iif(mishod==5, 1, 0)
  hu->KOL_EKS := f_kol_eks(space(3))
  kek_human := hu->(recno())
  //
else
  Use_base("mo_kekh")
  goto (kek_human)
  kek_otd[1] := hu->OTD
  G_RLock(forever)
  hu->KOL_EKS := f_kol_eks(hu->KOL_EKS)
endif
Use_base("mo_keke")
AddRec(7)
eks->KOD := kek_human
eks->TIP_EKS := grup_polzovat
eks->KOD_EKS := asc(kod_polzovat)
eks->DATE_EKS := sys_date
rec_eks := eks->(recno())
close databases
if fl
  keyboard chr(K_ENTER)
endif
e_eks(1,kek_human,rec_eks,art)
return NIL

*

*****
Function del_eks(kek_human,rec_eks,art)
Local buf, i, r := 11
buf := box_shadow(r,13,r+len(art)+1,65,color1)
for i := 1 to len(art)
  @ r+i,14 say center(alltrim(art[i]),76-25) color "G+/B"
next
if f_Esc_Enter(2,.t.) .and. f_Esc_Enter(2,.t.)
  use_base("mo_kekh")
  goto (kek_human)
  Use_base("mo_keke")
  goto (rec_eks)
  Use_base("mo_kekez")
  do while .t.
    find (str(eks->(recno()),7))
    if !found() ; exit ; endif
    DeleteRec(.t.)
  enddo
  select HU
  G_RLock(forever)
  hu->KOL_EKS := d_kol_eks(hu->KOL_EKS,eks->TIP_EKS)
  UnLock
  select EKS
  DeleteRec(.t.)
  if empty(hu->kol_eks)
    select HU
    DeleteRec(.t.)
  endif
  Close Databases
  stat_msg("Экспертиза удалена!") ; mybell(2,OK)
endif
rest_box(buf)
return NIL

*

*****
Function e_eks(regim,kek_human,rec_eks,art)
Local buf, i, mas_pmt := {"~Паспортная часть","~Экспертная оценка"}
buf := box_shadow(16,25,22,77,color1)
for i := 1 to len(art)
  @ 16+i,26 say center(alltrim(art[i]),76-25) color "G+/B"
next
i := regim
do while (i := popup_prompt(T_ROW,T_COL+5,i,mas_pmt)) > 0
  if i == 1
    edit_pasp_kek(regim,kek_human)
  else
    edit_eks(regim,kek_human,rec_eks,art)
  endif
enddo
rest_box(buf)
return NIL

*

***** 26.02.17
Function edit_pasp_kek(regim,kek_human)
Local buf := savescreen(), lcolor := "G+/B", lusl_ok := 1
R_Use(dir_server+"mo_kekh",,"HU")
goto (kek_human)
R_Use(dir_server+"human_",,"human_")
goto (hu->kod_lu)
R_Use(dir_server+"human",,"human")
goto (hu->kod_lu)
R_Use(dir_server+"kartote_",,"KART_")
goto (human->kod_k)
R_Use(dir_server+"kartotek",,"KART")
goto (human->kod_k)
Private mVRACH := space(10),;
   mOTD       := inieditspr(A__POPUPMENU, dir_server+"mo_otd", hu->OTD),;
   m1VRACH    := hu->VRACH,;
   mIST_BOL   := hu->IST_BOL,;
   mN_DATA    := human->N_DATA,;
   mK_DATA    := human->K_DATA,;
   mFIO       := kart->FIO,;
   mPOL       := kart->POL,;
   mDATE_R    := kart->DATE_R,;
   mADRES     := iif(emptyall(kart_->okatog,kart->adres),"",ret_okato_ulica(kart->adres,kart_->okatog)),;
   mRABOTA    := kart->mr_dol,;
   mKOJKO_DNI := hu->KOJKO_DNI,;
   m1IST_DOHOD:= hu->IST_DOHOD,;
   mIST_DOHOD := inieditspr(A__MENUVERT, mm_7_kek, hu->IST_DOHOD),;
   m1GITEL    := hu->GITEL,;
   mGITEL     := inieditspr(A__MENUVERT, mm_9_kek, hu->GITEL),;
   mDIAG_POST := hu->DIAG_POST,;
   mDIAG_PRED := hu->DIAG_PRED,;
   mKOD_DIAG  := hu->KOD_DIAG,;
   mDIAG_OSN  := hu->DIAG_OSN,;
   mDIAG_OSL  := hu->DIAG_OSL,;
   mDIAG_SOP  := hu->DIAG_SOP,;
   mDIAG_KON  := hu->DIAG_KON,;
   m1PLAN_EKS  := hu->PLAN_EKS,;
   mPLAN_EKS  := inieditspr(A__MENUVERT, mm_13_kek, hu->PLAN_EKS),;
   m1SOGLASIE  := hu->SOGLASIE,;
   mSOGLASIE  := inieditspr(A__MENUVERT, mm_14_kek, hu->SOGLASIE),;
   m1PUTI_POS  := hu->PUTI_POS,;
   mPUTI_POS  := inieditspr(A__MENUVERT, mm_15_kek, hu->PUTI_POS),;
   m1POST_ST   := hu->POST_ST,;
   mPOST_ST   := inieditspr(A__MENUVERT, mm_16_kek, hu->POST_ST),;
   m1GOSPIT    := hu->GOSPIT,;
   mGOSPIT    := inieditspr(A__MENUVERT, mm_17_kek, hu->GOSPIT),;
   m1ISHOD     := hu->ISHOD,;
   mISHOD     := inieditspr(A__MENUVERT, mm_18_kek, hu->ISHOD),;
   m1POVOD_EKS := hu->POVOD_EKS,;
   mPOVOD_EKS := inieditspr(A__MENUVERT, menu_povod_kek, hu->POVOD_EKS)
if between(human_->usl_ok,1,3)
  lusl_ok := human_->usl_ok 
endif  
motd += " ["+{"стационар","днев.стационар","поликлиника"}[lusl_ok]+"]"
if m1vrach > 0
  R_Use(dir_server+"mo_pers",,"P2")
  goto (m1vrach)
  mvrach := alltrim(p2->fio)
  if !empty(p2->tab_nom)
    mvrach += " ["+lstr(p2->tab_nom)+"]"
  endif
endif
close databases
setcolor(cDataCGet)
myclear(0)
Private gl_area := {1,0,23,79,0}
if lusl_ok == 3
  pr_1_str("Паспортная часть")
  @  3,1 say "Отделение" get motd when .f. color lcolor
  @  4,1 say "Ф.И.О. лечащего врача" get mvrach when .f. color lcolor
  @  5,1 say "№ амб.карты" get mist_bol
  @  row(),col()+2 say "Дата начала" get mn_data when .f. color lcolor
  @  row(),col() say ", окончания лечения" get mk_data when .f. color lcolor
  @  6,1 say "Ф.И.О. пациента" get mfio when .f. color lcolor
  @  7,1 say "Пол" get mpol when .f. color lcolor
  @  8,1 say " Работа" get mrabota when .f. color lcolor
  @  9,1 say "Источник средств существования" get mist_dohod ;
         reader {|x|menu_reader(x,mm_7_kek,A__MENUVERT,,,.f.)}
  @ 10,1 say "Возраст (дата рождения)" get mdate_r when .f. color lcolor
  @ 11,1 say " Адрес" get madres when .f. color lcolor
  @ 12,1 say "Житель" get mgitel ;
         reader {|x|menu_reader(x,mm_9_kek,A__MENUVERT,,,.f.)}
  @ 13,1 say "Первичный диагноз" get mDIAG_PRED pict "@S56"
  @ 14,1 say "Диагноз заключительный клинический"
  @ 15,1 say "  - основной" get mkod_diag when .f. color lcolor
  @  row(),col()+2 get mDIAG_OSN pict "@S58"
  @ 16,1 say "  - осложнение основного" get mDIAG_OSL pict "@S53"
  @ 17,1 say "  - сопутствующий" get mDIAG_SOP pict "@S60"
  @ 18,1 say '"Согласие" больного на проведение леч.-диаг.мероприятий' get mSOGLASIE ;
         reader {|x|menu_reader(x,mm_14_kek,A__MENUVERT,,,.f.)}
  @ 20,1 say "Исход заболевания" get mISHOD ;
         reader {|x|menu_reader(x,mm_18_kek,A__MENUVERT,,,.f.)}
  @ 22,1 say "Повод экспертизы" get mpovod_eks ;
         reader {|x|menu_reader(x,menu_povod_kek,A__MENUVERT,,,.f.)}
else
  @  0,62 say "│Паспортная часть│" color color0
  @  1,62 say "└────────────────┘" color color0
  @  0,1 say "Отделение" get motd when .f. color lcolor
  @  1,1 say "Ф.И.О. лечащего врача" get mvrach when .f. color lcolor
  @  2,1 say "№ ист.болезни" get mist_bol
  @  row(),col()+2 say "Дата поступления" get mn_data when .f. color lcolor
  @  row(),col() say ", выписки" get mk_data when .f. color lcolor
  @  3,1 say "Ф.И.О. пациента" get mfio when .f. color lcolor
  @  4,1 say "Пол" get mpol when .f. color lcolor
  @  row(),col()+5 say "Проведено "+iif(lusl_ok==1,"койко","пациенто")+"-дней" get mkojko_dni pict "999"
  @  5,1 say " Работа" get mrabota when .f. color lcolor
  @  6,1 say "Источник средств существования" get mist_dohod ;
         reader {|x|menu_reader(x,mm_7_kek,A__MENUVERT,,,.f.)}
  @  7,1 say "Возраст (дата рождения)" get mdate_r when .f. color lcolor
  @  8,1 say " Адрес" get madres when .f. color lcolor
  @  9,1 say "Житель" get mgitel ;
         reader {|x|menu_reader(x,mm_9_kek,A__MENUVERT,,,.f.)}
  @ 10,1 say "Диагноз при поступлении" get mDIAG_POST pict "@S51"
  @ 11,1 say "Диагноз предварительный" get mDIAG_PRED pict "@S50"
  @ 12,1 say "Диагноз заключительный клинический"
  @ 13,1 say "  - основной" get mkod_diag when .f. color lcolor
  @  row(),col()+2 get mDIAG_OSN pict "@S58"
  @ 14,1 say "  - осложнение основного" get mDIAG_OSL pict "@S53"
  @ 15,1 say "  - сопутствующий" get mDIAG_SOP pict "@S60"
  @ 16,1 say "  - конкурирующий" get mDIAG_KON pict "@S60"
  @ 17,1 say "Госпитализация больного в стационар" get mPLAN_EKS ;
         reader {|x|menu_reader(x,mm_13_kek,A__MENUVERT,,,.f.)}
  @ 18,1 say '"Согласие" больного на проведение леч.-диаг.мероприятий' get mSOGLASIE ;
         reader {|x|menu_reader(x,mm_14_kek,A__MENUVERT,,,.f.)}
  @ 19,1 say "Пути поступления" get mPUTI_POS ;
         reader {|x|menu_reader(x,mm_15_kek,A__MENUVERT,,,.f.)}
  @ 20,1 say "Поступление в данный стационар" get mPOST_ST ;
         reader {|x|menu_reader(x,mm_16_kek,A__MENUVERT,,,.f.)}
  @ 21,1 say "Госпитализирован по данному заболеванию" get mGOSPIT ;
         reader {|x|menu_reader(x,mm_17_kek,A__MENUVERT,,,.f.)}
  @ 22,1 say "Исход заболевания" get mISHOD ;
         reader {|x|menu_reader(x,mm_18_kek,A__MENUVERT,,,.f.)}
  @ 23,1 say "Повод экспертизы" get mpovod_eks ;
         reader {|x|menu_reader(x,menu_povod_kek,A__MENUVERT,,,.f.)}
endif       
status_key("^<Esc>^ - выход;  ^<PgDn>^ - запись")
myread()
if lastkey() != K_ESC .and. f_Esc_Enter(1)
  mywait()
  use_base("mo_kekh")
  goto (kek_human)
  G_RLock(forever)
  if !between(hu->USL_OK,1,3)
    hu->USL_OK := lusl_ok
  endif
  hu->IST_BOL   := mIST_BOL
  hu->KOJKO_DNI := mKOJKO_DNI
  hu->IST_DOHOD := m1IST_DOHOD
  hu->GITEL     := m1GITEL
  hu->DIAG_POST := mDIAG_POST
  hu->DIAG_PRED := mDIAG_PRED
  hu->DIAG_OSN  := mDIAG_OSN
  hu->DIAG_OSL  := mDIAG_OSL
  hu->DIAG_SOP  := mDIAG_SOP
  hu->DIAG_KON  := mDIAG_KON
  hu->PLAN_EKS  := m1PLAN_EKS
  hu->SOGLASIE  := m1SOGLASIE
  hu->PUTI_POS  := m1PUTI_POS
  hu->POST_ST   := m1POST_ST
  hu->GOSPIT    := m1GOSPIT
  hu->ISHOD     := m1ISHOD
  hu->POVOD_EKS := m1POVOD_EKS
  Use
  stat_msg("Запись завершена!") ; mybell(1,OK)
endif
restscreen(buf)
return NIL

***** 28.02.17
Function ret_f_kek(lshifr,diag1)
Local fl := .f., i, d := diag_to_num(lshifr,1), len_diag := len(diag1)
for i := 1 to len_diag
  if between(d,diag1[i,1],diag1[i,2])
    fl := .t. ; exit
  endif
next
return fl

***** 12.06.17
Function edit_eks(regim,kek_human,rec_eks,art)
Local adbf, t_arr[BR_LEN], blk, lpole, i, j, k, fl, buf, s, ab, lshifr
//
use_base("mo_kekh")
goto (kek_human)
Private mishod := hu->ISHOD, musl_ok := hu->usl_ok, sh := 117, is_2017 := (year(hu->K_DATA) > 2016)
//
adbf := {;
  {"name",   "C",630,0},;
  {"menu",   "C", 20,0},;
  {"tip",    "N",  1,0},;
  {"tip_val","C",  1,0},;
  {"pole",   "C", 10,0},;
  {"nn",     "N",  3,0},;
  {"valuen", "N",  1,0},;
  {"valuec", "C", 60,0}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
if is_2017
  R_Use(dir_exe+"_mo_kek",,"MK")
  index on fsort_usl(shifr) to (cur_dir+"tmp_mk") ;
        for left(shifr,4) == iif(musl_ok == 3, "2.1.", "2.2.")
  go top
  do while !eof()
    select TMP 
    append blank
    tmp->name := mk->name
    if !empty(mk->nn)
      tmp->menu := "mm_danet"
      tmp->tip := 1
      tmp->tip_val := "N"
      tmp->nn := mk->nn
    endif
    select MK
    skip
  enddo
  if musl_ok < 3 // стационар
    lshifr := kek_ret_shifr3() // пока так, т.к. шифры групп заболеваний изменились в новом приказе МЗ РФ
    if !(hu->shifr3 == lshifr)
      select HU
      G_RLock(forever)
      hu->shifr3 := lshifr
      UnLock
      Commit
    endif
    if !empty(hu->shifr3)
      select MK
      index on fsort_usl(shifr) to (cur_dir+"tmp_mk") for shifr == hu->shifr3
      go top
      do while !eof()
        if mk->nn > 0
          s := "- "+alltrim(mk->name)+";"
        else
          s := alltrim(mk->name)+":"
        endif
        select TMP 
        append blank
        tmp->name := s
        if !empty(mk->nn)
          tmp->menu := "mm_danet"
          tmp->tip := 1
          tmp->tip_val := "N"
          tmp->nn := mk->nn
        endif
        select MK
        skip
      enddo
    endif
  endif
else
  append blank
  tmp->name := "1. Состояние больного при поступлении в стационар"
  tmp->menu := "menu_1_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_1"
  //
  append blank
  tmp->name := "2. Объем описания состояния больного при поступлении в стационар"
  tmp->menu := "menu_2_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_2"
  //
  append blank
  tmp->name := "3. Соответствие диагноза при поступлении рубрификации МКБ-10"
  tmp->menu := "menu_3_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_3_POST"
  //
  append blank
  tmp->name := "   Соответствие предварительного диагноза рубрификации МКБ-10"
  tmp->menu := "menu_3_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_3_PRED"
  //
  append blank
  tmp->name := "   Соответствие заключительного клинического диагноза рубрификации МКБ-10"
  tmp->menu := "menu_3_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_3_OSN"
  //
  append blank
  tmp->name := "4. План обследования и лечения больного"
  tmp->menu := "menu_4_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_4"
  //
  append blank
  tmp->name := "  4.2.1 Своевременность плана"
  tmp->menu := "menu_4_2_1_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_4_2_1"
  //
  append blank
  tmp->name := "  4.2.2 Обоснованность плана"
  tmp->menu := "menu_4_2_2_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_4_2_2"
  //
  append blank
  tmp->name := "5. Наличие ежедневных дневниковых записей"
  tmp->menu := "menu_5_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_5"
  //
  append blank
  tmp->name := "6. Отражают ли дневниковые записи эффект от проводимой терапии"
  tmp->menu := "menu_6_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_6"
  //
  append blank
  tmp->name := "7. Оформление медицинской документации"
  tmp->menu := "menu_7_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_7"
  //
  append blank
  tmp->name := "8. Наличие дневников динамического круглосуточного наблюдения тяжелого больного"
  tmp->menu := "menu_8_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_8"
  //
  append blank
  tmp->name := "9. Наличие записей заведующего отделением в истории болезни (в случае, если зав.отделением не был лечащим врачом)"
  tmp->menu := "menu_9_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_9"
  //
  append blank
  tmp->name := "10. Своевременность и объем диагностических мероприятий"
  tmp->menu := "menu_10_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_10"
  //
  append blank
  tmp->name := "11. Оценка результатов диагностических исследований"
  //
  append blank
  tmp->name := "    Лабораторные методы исследования"
  //
  append blank
  tmp->name := "    - общий анализ крови"
  tmp->menu := "menu_11_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_11_L_1"
  //
  append blank
  tmp->name := "    - общий анализ мочи"
  tmp->menu := "menu_11_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_11_L_2"
  //
  append blank
  tmp->name := "    - биохимический анализ крови"
  tmp->menu := "menu_11_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_11_L_3"
  //
  append blank
  tmp->name := "    - анализ крови на глюкозу"
  tmp->menu := "menu_11_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_11_L_4"
  //
  append blank
  tmp->name := "    - прочие"
  tmp->menu := "menu_11_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_11_L_5"
  //
  append blank
  tmp->name := "    Инструментальные методы исследования"
  //
  append blank
  tmp->name := "    - ЭКГ"
  tmp->menu := "menu_11_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_11_I_1"
  //
  append blank
  tmp->name := "    - УЗИ"
  tmp->menu := "menu_11_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_11_I_2"
  //
  append blank
  tmp->name := "    - ФГС"
  tmp->menu := "menu_11_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_11_I_3"
  //
  append blank
  tmp->name := "    - прочие"
  tmp->menu := "menu_11_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_11_I_4"
  //
  append blank
  tmp->name := "    Рентгенографические методы исследования"
  //
  append blank
  tmp->name := "    - рентгенография"
  tmp->menu := "menu_11_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_11_R_1"
  //
  append blank
  tmp->name := "    - КТ"
  tmp->menu := "menu_11_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_11_R_2"
  //
  append blank
  tmp->name := "    - ЯМР"
  tmp->menu := "menu_11_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_11_R_3"
  //
  append blank
  tmp->name := "    - прочие"
  tmp->menu := "menu_11_kek"
  tmp->tip := 1
  tmp->tip_val := "C"
  tmp->pole := "EO_11_R_4"
  //
  append blank
  tmp->name := "12. Клинический заключительный диагноз"
  tmp->menu := "menu_12_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_12"
  //
  append blank
  tmp->name := "13. Соответствие проводимого лечения выставленному диагнозу"
  tmp->menu := "menu_13_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_13"
  //
  append blank
  tmp->name := "14. Лечение начато"
  tmp->menu := "menu_14_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_14"
  //
  append blank
  tmp->name := "15. Комбинации лекарственных средств, используемых при лечении"
  tmp->menu := "menu_15_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_15"
  //
  append blank
  tmp->name := "16. Дозировка лекарственных препаратов в листах назначения"
  tmp->menu := "menu_16_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_16"
  //
  append blank
  tmp->name := "17. Соответствие сроков лечения стандартам, принятым по данному заболеванию при выписке больного из стационара"
  tmp->menu := "menu_17_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_17"
  //
  append blank
  tmp->name := "18. Реанимационные мероприятия в случае их необходимости, проведены"
  tmp->menu := "menu_18_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_18"
  //
  append blank
  tmp->name := "19. Консилиум и осмотр специалистами в данном случае"
  tmp->menu := "menu_19_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_19"
  //
  append blank
  tmp->name := "20. Обращение за консультацией к главным внештатным специалистам"
  tmp->menu := "menu_20_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_20"
  //
  append blank
  tmp->name := "21. Выполнение рекомендации консультантов"
  tmp->menu := "menu_21_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_21"
  //
  append blank
  tmp->name := "22. Существовала необходимость в переводе больного в специализированное отделение, учреждение"
  tmp->menu := "menu_22_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_22"
  //
  append blank
  tmp->name := "23. В случае необходимости перевод больного в специализированное отделение, учреждение произведен"
  tmp->menu := "menu_23_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_23"
  //
  append blank
  tmp->name := "24. Этапные эпикризы при пребывании в стационаре более трех недель"
  tmp->menu := "menu_24_kek"
  tmp->tip := 1
  tmp->tip_val := "N"
  tmp->pole := "EO_24"
  //
  if mishod == 5 // летальный исход
    append blank
    tmp->name := "25. В случае летального исхода вскрытие"
    tmp->menu := "menu_25_kek"
    tmp->tip := 1
    tmp->tip_val := "N"
    tmp->pole := "EO_25"
    //
    append blank
    tmp->name := "26. Карта разбора летального исхода на КИЛИ"
    tmp->menu := "menu_26_kek"
    tmp->tip := 1
    tmp->tip_val := "N"
    tmp->pole := "EO_26"
    //
    append blank
    tmp->name := "27. Замечания к карте разбора летального исхода на КИЛИ"
    tmp->menu := "menu_27_kek"
    tmp->tip := 1
    tmp->tip_val := "N"
    tmp->pole := "EO_27"
    //
    append blank
    tmp->name := "28. Патологоанатомический диагноз"
    tmp->tip := 2
    tmp->tip_val := "C"
    tmp->pole := "EO_28"
    //
    append blank
    tmp->name := "29. Оценка расхождения заключительного клинического и патологоанатомического диагнозов"
    tmp->menu := "menu_29_kek"
    tmp->tip := 1
    tmp->tip_val := "N"
    tmp->pole := "EO_29"
    //
    append blank
    tmp->name := "30. Оформление посмертного эпикриза"
    tmp->menu := "menu_30_kek"
    tmp->tip := 1
    tmp->tip_val := "N"
    tmp->pole := "EO_30"
  endif
endif
select TMP
append blank
tmp->name := "Заключение"
tmp->tip := 3
tmp->tip_val := "C"
tmp->pole := "N_ZAKLUCH"
//
Use_base("mo_keke")
goto (rec_eks)
Use_base("mo_kekez")
find (str(eks->(recno()),7))
if is_2017
  buf := savescreen()
  SetMode(35,130)
  FillScreen(p_char_screen,p_color_screen)
  box_shadow(26,75,32,127,color1)
  for i := 1 to len(art)
    @ 26+i,76 say center(alltrim(art[i]),76-25) color "G+/B"
  next
  Private p_ar := array(70) ; afill(p_ar,0)
  Private p2ar := array(70) ; afill(p2ar,0)
  select TMP
  go top
  do while !eof()
    if tmp->tip == 1 .and. tmp->tip_val == "N" .and. !empty(tmp->nn)
      if tmp->nn > 0
        if empty(p_ar[tmp->nn])
          p_ar[tmp->nn] := 2 // по умолчанию ответы на все вопросы "да"
        endif
      else
        i := abs(tmp->nn)
        p2ar[i] := 1 // на предварительный вопрос ответ "нет"
        p_ar[i] := 3 // следовательно следующий пункт невыбираемый 
      endif
    endif
    skip
  enddo
  if musl_ok < 3 // стационар
    if mishod == 5 // если летальный исход, и входим первый раз
      p2ar[21] := 2 // на предварительный вопрос ответ "да"
      p_ar[21] := p_ar[22] := 2 // на вопрос экспертизы ответ по умолчанию "да"
    else
      p2ar[21] := 1 // на предварительный вопрос ответ "нет"
      p_ar[21] := p_ar[22] := 3 // следовательно следующие пункты невыбираемые
    endif
  endif
  for i := 1 to min(70,len(eks->EO_28))
    j := int(val(substr(eks->EO_28,i,1)))
    if between(j,1,3)
      if j == 3 // в базе стоит невыбираемый пункт
        if i == 22
          // вторая строка для летального исхода
        elseif empty(p2ar[i]) // а нет соответствующего вопроса перед данным пунктом
          j := 1 // исправляем на "нет"
        else
          p2ar[i] := 1 // ставим "нет" для соответствующего вопроса перед данным пунктом
        endif 
      else  // стоит "да" или "нет"
        if i == 22 // вторая строка для летального исхода ()
          if p_ar[21] == 3 // первая строка для летального исхода = 3 (т.е. нет летального исхода)
            j := 3 // исправляем (огрехи перехода на один вопрос по летальному исходу)
          endif
        else
          p2ar[i] := 2 // ставим "да" для соответствующего вопроса перед данным пунктом
        endif
      endif
      p_ar[i] := j
    endif
  next
  select TMP
  go top
  do while !eof()
    if tmp->tip == 1 .and. tmp->tip_val == "N" .and. !empty(tmp->nn)
      if tmp->nn > 0
        tmp->valuen := p_ar[tmp->nn] - 1
      else
        tmp->valuen := p2ar[-tmp->nn] - 1
      endif
    elseif tmp->tip == 3
      tmp->valuec := eksz->name
    endif
    select TMP
    skip
  enddo
  s := ""
  for i := 1 to len(p_ar)
    s += lstr(p_ar[i])
  next
  if !(eks->EO_28 == s)
    select EKS
    G_RLock(forever)
    eks->EO_28 := s
    ab := f_ball_kek(mishod)
    eks->O_E     := ab[1,8]
    eks->O_ALL   := ab[1,9]
    eks->p_zapol := f_p_zapol_kek(mishod,is_2017)
    UnLock
    Commit
  endif
  update_p_zapol(eks->p_zapol,eks->O_E,eks->O_ALL)
  select TMP
  go top
  t_arr[BR_TOP] := 0
  t_arr[BR_BOTTOM] := 24
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 129
  t_arr[BR_TITUL] := "Экспертная оценка"
  t_arr[BR_TITUL_COLOR] := "G+/B"
  t_arr[BR_COLOR] := color1
  t_arr[BR_ARR_BROWSE] := {'═','░','═',"W+/B,W+/RB,BG+/B,BG+/RB,R+/B,W+/R,G+/B,G+/RB,W/B,W/RB",.t.}
  Private blk_rr := {|| f1_br_edit_eks() }, nAddrLine := 1 // Номер рассматриваемой адресной строки
  t_arr[BR_ARR_BLOCK] := {{|| goFirst(@nAddrLine,blk_rr) },;
                          {|| goLast(@nAddrLine,blk_rr) },;
                          {|x| goNext(x,@nAddrLine,blk_rr) },;
                          "",".t.";
                         }
  blk := {|| f3_br_edit_eks() }
  t_arr[BR_COLUMN] := {{"  Наименование экспертизы", {|| f2_br_edit_eks(nAddrLine,1)  }, blk },;
                       {" Значение ", {|| f2_br_edit_eks(nAddrLine,2) }, blk }}
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - редактирование") }
  t_arr[BR_EDIT] := {|nk,ob| f1_e_eks(nk,ob,"edit") }
  edit_browse(t_arr)
  SetMode(25,80)
  restscreen(buf)
  update_p_zapol(eks->p_zapol,eks->O_E,eks->O_ALL)
  close databases
else
  select TMP
  go top
  do while !eof()
    if !empty(tmp->pole)
      lpole := "eks->"+alltrim(tmp->pole)
      if tmp->tip_val == "N"
        tmp->valuen := &lpole
      else
        if tmp->tip == 3
          tmp->valuec := eksz->name
        else
          tmp->valuec := &lpole
        endif
      endif
    endif
    select TMP
    skip
  enddo
  go top
  t_arr[BR_TOP] := 0
  t_arr[BR_BOTTOM] := 14
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_TITUL] := "Экспертная оценка"
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
  blk := {|| iif(emptyall(tmp->valuen,tmp->valuec), {3,4}, {1,2}) }
  t_arr[BR_COLUMN] := {{" Наименование экспертизы", {|| padr(tmp->name,67)  }, blk },;
                       {" Значение ", {|| iif(tmp->tip_val=="N",padc(lstr(tmp->valuen),10),padc(alltrim(tmp->valuec),10)) }, blk }}
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - редактирование") }
  t_arr[BR_EDIT] := {|nk,ob| f1_e_eks(nk,ob,"edit") }
  edit_browse(t_arr)
  close databases
endif  
return NIL

***** 27.03.17 подсчет количества выводимых строк
Function f1_br_edit_eks()
Local ar[10]
return perenos(ar,tmp->name,sh-2)

***** 27.03.17 возврат выводимой строки по номеру 
Function f2_br_edit_eks(line,reg)
Local ar[10], k, s := ""
if reg == 1
  k := perenos(ar,tmp->name,sh-2)
  if line == 1
    s := ar[1]
  elseif line <= k  
    s := space(2)+ar[line]
  endif
  s := padr(s,sh)
elseif reg == 2
  if line == 1    
    if tmp->tip_val == "N"
      s := iif(tmp->valuen==1,"да","нет")
    else
      s := alltrim(tmp->valuec)
    endif
  endif
  s := padc(s,10)
endif    
return s

***** 27.03.17
Function f3_br_edit_eks()
Local acolor
if empty(tmp->nn)
  if empty(tmp->tip)
    acolor := {7,8}
  else
    acolor := iif(empty(tmp->valuec),{3,4},{1,2})
  endif
elseif tmp->nn < 0
  acolor := {5,6}
elseif empty(tmp->valuen)
  acolor := {3,4}
elseif tmp->valuen == 2
  acolor := {9,10}
else  
  acolor := {1,2}
endif
return acolor  

***** 11.06.17
Function f1_e_eks(nKey,oBrow,regim)
Local ret := -1, v, lmenu, k, lpole, buf, s, ab, rec, is_edit := .f.
if regim == "edit" .and. nKey == K_ENTER
  if tmp->tip == 1
    if is_2017
      if tmp->valuen == 2 // "нет" в невыбираемом пункте
        return ret
      endif
      lmenu := alltrim(tmp->menu)
      k := tmp->valuen
      v := popup_2array(&lmenu,row()+1,maxcol()-5,k,,,,,color5)
      if valtype(v) == valtype(k) .and. !(v == k)
        tmp->valuen := v
        if tmp->nn > 0
          p_ar[tmp->nn] := v + 1
        else
          k := abs(tmp->nn)
          p2ar[k] := v + 1
          if v == 0 // "нет"
            p_ar[k] := 3 // невыбираемый пункт
            rec := tmp->(recno())
            go top
            Locate for tmp->nn == k
            if found()
              tmp->valuen := 2
            endif
            if k == 21 // летальный исход
              p_ar[22] := 3 // невыбираемый пункт
              go top
              Locate for tmp->nn == 22
              if found()
                tmp->valuen := 2
              endif
            endif 
            goto (rec)
          elseif v == 1 // "да"
            p_ar[k] := 2 // следующий пункт "да"
            rec := tmp->(recno())
            go top
            Locate for tmp->nn == k
            if found()
              tmp->valuen := 1
            endif 
            if k == 21 // летальный исход
              p_ar[22] := 2 // следующий пункт "да"
              go top
              Locate for tmp->nn == 22
              if found()
                tmp->valuen := 1
              endif
            endif 
            goto (rec)
          endif
        endif
        s := ""
        for i := 1 to len(p_ar)
          s += lstr(p_ar[i])
        next
        select EKS
        G_RLock(forever)
        eks->EO_28 := s
        UnLock
        is_edit := .t.
      endif
    else
      lmenu := alltrim(tmp->menu)
      k := iif(tmp->tip_val=="N",tmp->valuen,left(tmp->valuec,1))
      v := popup_2array(&lmenu,row()+1,75,k,,,,,color5)
      if valtype(v) == valtype(k) .and. !(v == k)
        if tmp->tip_val=="N"
          tmp->valuen := v
        else
          tmp->valuec := v
        endif
        if !empty(tmp->pole)
          lpole := "eks->"+alltrim(tmp->pole)
          select EKS
          G_RLock(forever)
          &lpole := v
          UnLock
          is_edit := .t.
        endif
      endif
    endif
  elseif tmp->tip == 2
    Private mvar := tmp->valuec
    k := row()+1
    buf := box_shadow(k,14,k+2,77,color5)
    @ k+1,16 get mvar color color5
    myread()
    rest_box(buf)
    if lastkey() != K_ESC .and. !(mvar == tmp->valuec)
      tmp->valuec := mvar
      lpole := "eks->"+alltrim(tmp->pole)
      select EKS
      G_RLock(forever)
      &lpole := mvar
      UnLock
      is_edit := .t.
    endif
  elseif tmp->tip == 3
    s := ""
    select EKSZ
    find (str(eks->(recno()),7))
    do while eksz->kod == eks->(recno()) .and. !eof()
      s += rtrim(eksz->name) + eos
      skip
    enddo
    Private updt_s := .f.
    s := f_zakluch_kek(row()+1,s)
    if updt_s
      k := 0
      select EKSZ
      do while .t.
        find (str(eks->(recno()),7))
        if !found() ; exit ; endif
        DeleteRec(.t.)
      enddo
      if !empty(s)
        for i := 1 to mlcount(s,60)
          AddRec(7)
          eksz->kod := eks->(recno())
          eksz->stroke := if(i < 100, i, 99)
          eksz->name := rtrim(memoline(s,60,i))
          UnLock
          k := eksz->stroke
        next
      endif
      select EKS
      G_RLock(forever)
      eks->N_ZAKLUCH := k
      UnLock
      is_edit := .t.
    endif
    tmp->valuec := memoline(s,60,1)
  endif
  select EKS
  ab := f_ball_kek(mishod)
  G_RLock(forever)
  eks->p_zapol := f_p_zapol_kek(mishod,is_2017)
  eks->O_A     := ab[1,1]
  eks->O_B     := ab[1,2]
  eks->O_C     := ab[1,3]
  eks->O_D     := ab[1,4]
  eks->O_K     := ab[1,5]
  eks->O_P     := ab[1,6]
  eks->O_R     := ab[1,7]
  eks->O_E     := ab[1,8]
  eks->O_ALL   := ab[1,9]
  if is_edit .and. is_own
    eks->DATE_EKS := sys_date
  endif
  UnLock
  Commit
  update_p_zapol(eks->p_zapol,eks->O_E,eks->O_ALL)
  select TMP
  ret := 0
  oBrow:down()
endif
return ret

***** 28.02.17
Function update_p_zapol(lp,le,lo)
Local s := "заполнение "+lstr(lp)+"%; балл "+alltrim(str_0(le,5,3))+"; оценка "+str(lo,1)
if maxcol() > 80
  @ 26+5,76 say center(s,76-25) color iif(lp==100, "G+/B", "RB+/B")
else
  @ 16+5,26 say center(s,76-25) color iif(lp==100, "G+/B", "RB+/B")
endif  
return NIL

*

*****
Function f_kol_eks(s)
Local sg := lstr(grup_polzovat)
do case
  case grup_polzovat == 1
    s := sg+substr(s,2)
  case grup_polzovat == 2
    s := left(s,1)+sg+right(s,1)
  case grup_polzovat == 3
    s := left(s,2)+sg
endcase
return s

*****
Function d_kol_eks(s,gr_p)
Static sg := " "
do case
  case gr_p == 1
    s := sg+substr(s,2)
  case gr_p == 2
    s := left(s,1)+sg+right(s,1)
  case gr_p == 3
    s := left(s,2)+sg
endcase
return s

*

***** 28.02.17
Function f_zakluch_kek(r,s_prim1)
Local r1 := r, i, j, mas, tmp, s1, buf, tmp_color, tmp_help := chm_help_code,;
      c1, r2, c2, fl, tmp_keys, bSaveHandler
r2 := maxrow() - 2
c2 := maxcol() - 3
c1 := c2 - 61      
buf := savescreen()
tmp_keys := my_savekey()
change_attr()
setkey(K_ESC, {|| __keyboard(CHR(23)) } )  // KS_CTRL_W
bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
BEGIN SEQUENCE
  chm_help_code := 10 // H_MemoEdit
  tmp_color := setcolor("N/W")
  box_shadow(r1,c1,r2,c2,"N/W","Текст заключения","N+/W")
  status_key("^<Esc>^ - окончание редактирования;  ^<F1>^ - помощь")
  SETCURSOR()
  if (s1 := memoedit(s_prim1,r1+1,c1+1,r2-1,c2-1,.t.,)) != s_prim1
    updt_s := .t.
    tmp := strtran(s1,Hos,eos)
  endif
RECOVER USING error
  func_error(4,"Ошибка запуска внутреннего редактора")
END
// Восстановление начальной программы обработки ошибок
ERRORBLOCK(bSaveHandler)
if updt_s
  tmp := strtran(s1,Hos,eos)
  mas := {} ; fl := .f.
  for i := 1 to mlcount(tmp,60)
    aadd(mas, rtrim(memoline(s1,60,i)))
    if !fl
      fl := !empty(mas[i])
    endif
  next
  s_prim1 := ""
  if fl
    for i := 1 to len(mas)
      if !empty(mas[i])
        s_prim1 += mas[i]+eos
      endif
    next
  endif
endif
chm_help_code := tmp_help
setcolor(tmp_color)
setkey(K_ESC, NIL)
my_restkey(tmp_keys)
restscreen(buf)
setcursor(0)
return s_prim1

*

***** 28.02.17
Function f_p_zapol_kek(_lishod,is_2017)
Local _kp := 0, _ke := 0, _pr
if is_2017
  _kp := 100 ; _ke := 99
  if eks->N_ZAKLUCH > 0
    _ke := _fke(_ke)
  endif
else
  _kp := _kp+1
  if eks->EO_1 > 0
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_2 > 0
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if !empty(eks->EO_3_POST)
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if !empty(eks->EO_3_PRED)
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if !empty(eks->EO_3_OSN)
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_4 > 0
    _ke := _fke(_ke)
  endif
  if eks->EO_4 == 2  // 4.2 - план обследования и лечения больного "имеется"
    _kp := _kp+1
    if !empty(eks->EO_4_2_1)
      _ke := _fke(_ke)
    endif
    _kp := _kp+1
    if !empty(eks->EO_4_2_2)
      _ke := _fke(_ke)
    endif
  endif
  _kp := _kp+1
  if eks->EO_5 > 0
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_6 > 0
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_7 > 0
    _ke := _fke(_ke)
  endif
  if eks->EO_8 > 0
    _kp := _kp+1
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_9 > 0
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_10 > 0
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_12 > 0
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_13 > 0
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_14 > 0
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_15 > 0
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_16 > 0
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_17 > 0
    _ke := _fke(_ke)
  endif
  if eks->EO_18 > 0
    _kp := _kp+1
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_19 > 0
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_20 > 0
    _ke := _fke(_ke)
  endif
  if eks->EO_21 > 0
    _kp := _kp+1
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->EO_22 > 0
    _ke := _fke(_ke)
  endif
  if eks->EO_22 == 1
    _kp := _kp+1
    if eks->EO_23 > 0
      _ke := _fke(_ke)
    endif
  endif
  _kp := _kp+1
  if eks->EO_24 > 0
    _ke := _fke(_ke)
  endif
  _kp := _kp+1
  if eks->N_ZAKLUCH > 0
    _ke := _fke(_ke)
  endif
  if _lishod == 5 // летальный исход
    _kp := _kp+6
    if eks->EO_25 > 0
      _ke := _fke(_ke)
    endif
    if eks->EO_26 > 0
      _ke := _fke(_ke)
    endif
    if eks->EO_27 > 0
      _ke := _fke(_ke)
    endif
    if !empty(eks->EO_28)
      _ke := _fke(_ke)
    endif
    if eks->EO_29 > 0
      _ke := _fke(_ke)
    endif
    if eks->EO_30 > 0
      _ke := _fke(_ke)
    endif
  endif
endif  
_pr := round_5(_ke/_kp*100,0)
if _pr == 100 .and. _ke < _kp
  _pr := 99
endif
return _pr

*****
Static Function _fke(k)
return k+1

*

*****
Function _work_eks(r,c,arr_otd,fl_otd,b_date,e_date)
Local i, ret, ret_arr := {}, arr := {}
DEFAULT r TO T_ROW, c TO T_COL+5, fl_otd TO .t.
if b_date == NIL .and. e_date == NIL
  R_Use(dir_server+"mo_keke",,"KE")
  index on str(kod_eks,3) TO (cur_dir+"tmp_ke") UNIQUE
else
  R_Use(dir_server+"human",,"HUMAN")
  R_Use(dir_server+"mo_kekh",,"HU")
  set relation to kod_lu into HUMAN
  R_Use(dir_server+"mo_keke",,"KE")
  set relation to kod into HU
  index on str(kod_eks,3) TO (cur_dir+"tmp_ke") UNIQUE FOR between(human->k_data,b_date,e_date)
endif
dbeval({|| aadd(arr, {space(41),ke->kod_eks}) })
close databases
if empty(arr)
  func_error(4,"Не было ввода экспертиз!")
  return ret
endif
R_Use(dir_server+"base1",,"B1")
for i := 1 to len(arr)
  if arr[i,2] > 0
    goto(arr[i,2])
    if !eof()
      arr[i,1] := padr(crypt(b1->p1,gpasskod),21)+; // ФИО
                  crypt(b1->p5,gpasskod)+;          // должность
                  " (гр."+lstr(b1->p6)+")"          // группа экспертизы
    endif
  endif
next
Use
popup_2array(arr,r,c,asc(kod_polzovat),1,@ret_arr)
if valtype(ret_arr) == "A" .and. len(ret_arr) == 2
  ret := ret_arr
  if fl_otd
    arr_otd := _work_otd(r,c,ret[2])
  endif
endif
return ret

*

*****
Function _work_otd(r,c,_ke)
Local i, arr_otd := {}, ret_arr := {}
DEFAULT r TO T_ROW, c TO T_COL+5, _ke TO asc(kod_polzovat)
R_Use(dir_server+"mo_kekh",,"KH")
R_Use(dir_server+"mo_keke",dir_server+"mo_kekee","KE")
set relation to kod into KH
find (str(_ke,3))
index on str(kh->otd,4) TO (cur_dir+"tmp_ke") while kod_eks==_ke UNIQUE
dbeval({|| aadd(arr_otd, {space(30),kh->otd}) })
ke->(dbCloseArea())
kh->(dbCloseArea())
if len(arr_otd) > 1
  R_Use(dir_server+"mo_otd",,"OTD")
  for i := 1 to len(arr_otd)
    goto (arr_otd[i,2])
    arr_otd[i,1] := otd->name
  next
  Use
  asort(arr_otd,,,{|x,y| upper(x[1]) < upper(y[1]) })
  popup_2array(arr_otd,r,c,kek_otd[1],1,@ret_arr)
  if valtype(ret_arr) == "A" .and. len(ret_arr) == 2
    kek_otd := {ret_arr[2],ret_arr[1]}
    arr_otd := aclone(kek_otd)
  else
    arr_otd := nil
  endif
else
  arr_otd := nil
endif
return arr_otd

*

***** 11.06.17
Function init_menus_kek()
Local i, j, d1, d2, s2, s3, diapazon
Public menu_stac17_kek := {} // Критерии качества по группам заболеваний (состояний)
R_Use(dir_exe+"_mo_kekd",,"KD")
go top
do while !eof()
  aadd(menu_stac17_kek,{alltrim(kd->shifr),kd->vzr,kd->reb,nil})
  j := len(menu_stac17_kek)
  s2 := alltrim(kd->name)
  diapazon := {}
  for i := 1 to numtoken(s2,";")
    s3 := token(s2,";",i)
    if "-" $ s3
      d1 := token(s3,"-",1)
      d2 := token(s3,"-",2)
    else
      d1 := d2 := s3
    endif
    aadd(diapazon, {diag_to_num(d1,1),diag_to_num(d2,2)} )
  next
  menu_stac17_kek[j,4] := aclone(diapazon)
  skip
enddo
Use  
Public menu_povod_kek := {; // повод экспертизы
  {"летальный исход",1},;
  {"расхождение диагноза",2},;
  {"внутрибольничная инфекция",3},;
  {"первичный выход на инвалидность в труд.возрасте",4},;
  {"повторная госпитализация в течение года",5},;
  {"удлинненный (укороченный) срок лечения",6},;
  {"жалобы",7},;
  {"случайный выбор",0}}
Public menu_1_kek := {; // Состояние больного при поступлении в стационар
  {"1 удовлетворительное",1},;
  {"2 средней тяжести"   ,2},;
  {"3 тяжелое"           ,3},;
  {"4 крайне тяжелое"    ,4}}
Public menu_2_kek := {; // Объем описания состояния больного при поступлении в стационар
  {"1 достаточный, замечаний нет"               ,1},;
  {"2 достаточный с незначительными замечаниями",2},;
  {"3 недостаточный"                            ,3},;
  {"4 описание состояния больного отсутствует"  ,4}}
Public menu_3_kek := {; // Соответствие диагнозов рубрификации МКБ-10
  {"А Не выставлен"               ,"А"},;
  {"Б Выставлен, соответствует"   ,"Б"},;
  {"В Выставлен, не соответствует","В"}}
Public menu_4_kek := {; // План обследования и лечения больного
  {"1 Отсутствует",1},;
  {"2 Имеется"    ,2}}
Public menu_4_2_1_kek := {; // Своевременность
  {"А Замечаний нет"                                                           ,"А"},;
  {"Б С незначительной задержкой, не повлиявшей на течение и исход заболевания","Б"},;
  {"В Составлен несвоевременно, с большой задержкой"                           ,"В"}}
Public menu_4_2_2_kek := {; // Обоснованность
  {"А Замечаний нет"                           ,"А"},;
  {"Б Обоснован, с незначительными замечаниями","Б"},;
  {"В Имеются существенные замечания"          ,"В"}}
Public menu_5_kek := {; // Наличие ежедневных дневниковых записей
  {"1 имеются, замечаний нет"                ,1},;
  {"2 имеются, с незначительными замечаниями",2},;
  {"3 имеются, нерегулярные, эпизодические"  ,3},;
  {"4 отсутствуют"                           ,4}}
Public menu_6_kek := {; // Отражают ли дневниковые записи эффект от проводимой терапии
  {"1 отражают полностью, замечаний нет"      ,1},;
  {"2 отражают, с незначительными замечаниями",2},;
  {"3 отражают частично"                      ,3},;
  {"4 не отражают"                            ,4}}
Public menu_7_kek := {; // Оформление медицинской документации
  {"1 четкое"             ,1},;
  {"2 нечеткое, небрежное",2}}
Public menu_8_kek := {; // Наличие дневников динамического круглосуточного наблюдения тяжелого больного
  {"1 имеются, замечаний нет"                ,1},;
  {"2 имеются, с незначительными замечаниями",2},;
  {"3 имеются, неполные, нечеткие"           ,3},;
  {"4 отсутствуют, но были необходимы"       ,4}}
Public menu_9_kek := {; // Наличие записей заведующего отделением в истории болезни (в случае, если зав. отделением не был лечащим врачом)
  {"1 не было необходимости"                 ,1},;
  {"2 имеются, замечаний нет"                ,2},;
  {"3 имеются, с незначительными замечаниями",3},;
  {"4 имеются, неполные, нечеткие"           ,4},;
  {"5 отсутствуют, но были необходимы"       ,5}}
Public menu_10_kek := {; // Своевременность и объем диагностических мероприятий
  {"1 своевременно и в полном объеме"      ,1},;
  {"2 не своевременно, но в полном объеме" ,2},;
  {"3 своевременно, но не в полном объеме" ,3},;
  {"4 не своевременно и не в полном объеме",4},;
  {"5 показаны, но не проведены"           ,5},;
  {"6 проведены, но не показаны"           ,6}}
Public menu_11_kek := {; // Оценка результатов диагностических исследований
  {"А Правильно полностью интерпретированы леч.врачом","А"},;
  {"Б Правильно частично интерпретированы леч.врачом" ,"Б"},;
  {"В Неверно интерпретированы леч.врачом"            ,"В"},;
  {"Г Не интерпретированы леч.врачом"                 ,"Г"},;
  {"Д Показаны, но не проведены"                      ,"Д"},;
  {"Е Проведены, но не показаны"                      ,"Е"},;
  {"  -"                                              ," "}}
Public menu_12_kek := {; // Клинический заключительный диагноз
  {"1 выставлен, соответствует результатам клинического исследования"     ,1},;
  {"2 выставлен, но не соответствует результатам клинических исследований",2},;
  {"3 не выставлен"                                                       ,3}}
Public menu_13_kek := {; // Соответствие проводимого лечения выставленному диагнозу
  {"1 соответствует полностью, замечаний нет"      ,1},;
  {"2 соответствует, с незначительными замечаниями",2},;
  {"3 соответствует частично"                      ,3},;
  {"4 не соответствует"                            ,4}}
Public menu_14_kek := {; // Лечение начато
  {"1 своевременно"                       ,1},;
  {"2 с задержкой по объективным причинам",2},;
  {"3 не своевременно"                    ,3}}
Public menu_15_kek := {; // Комбинации лекарственных средств, используемых при лечении
  {"1 рациональны, замечаний нет"                ,1},;
  {"2 рациональны, с незначительными замечаниями",2},;
  {"3 не рациональны"                            ,3}}
Public menu_16_kek := {; // Дозировка лекарственных препаратов в листах назначения
  {"1 отражена полностью" ,1},;
  {"2 отражена с ошибками",2},;
  {"3 не отражена"        ,3}}
Public menu_17_kek := {; // Соответствие сроков лечения стандартам, принятым по данному заболеванию при выписке больного из стационара
  {"1 соответствуют стандартам"                        ,1},;
  {"2 превышают стандарты (грамотно обосновано)"       ,2},;
  {"3 превышают стандарты (без обоснования)"           ,3},;
  {"4 меньше принятых стандартов (грамотно обосновано)",4},;
  {"5 меньше принятых стандартов (без обоснования)"    ,5}}
Public menu_18_kek := {; // Реанимационные мероприятия в случае их необходимости, проведены
  {"1 в полном объеме",1},;
  {"2 частично"       ,2},;
  {"3 не проведены"   ,3}}
Public menu_19_kek := {; // Консилиум и осмотр специалистами в данном случае
  {"1 не было необходимости",1},;
  {"2 проведен"             ,2},;
  {"3 не проведен"          ,3}}
Public menu_20_kek := {; // Обращение за консультацией к главным внештатным специалистам
  {"1 не было необходимости"          ,1},;
  {"2 своевременно и обосновано"      ,2},;
  {"3 не своевременно и не обосновано",3},;
  {"4 не обращались, но необходимо"   ,4}}
Public menu_21_kek := {; // Выполнение рекомендации консультантов
  {"1 выполнялись полностью"                                               ,1},;
  {"2 не выполнялись или выполнялись частично по усмотрению лечащего врача",2},;
  {"3 не выполнялись без обоснований"                                      ,3}}
Public menu_22_kek := {; // Существовала необходимость в переводе больного в специализированное отделение, учреждение
  {"1 да" ,1},;
  {"2 нет",2}}
Public menu_23_kek := {; // В случае необходимости перевод больного в специализированное отделение, учреждение произведен
  {"1 своевременно и обосновано"          ,1},;
  {"2 не своевременно и/или не обосновано",2},;
  {"3 не произведен"                      ,3}}
Public menu_24_kek := {; // Этапные эпикризы при пребывании в стационаре более трех недель
  {"1 не было необходимости"                 ,1},;
  {"2 имеются, замечаний нет"                ,2},;
  {"3 имеются, с незначительными замечаниями",3},;
  {"4 имеются, неполные, нечеткие"           ,4},;
  {"5 отсутствуют, но были необходимы"       ,5}}
Public menu_25_kek := {; // В случае летального исхода вскрытие
  {"1 произведено"                                                                  ,1},;
  {"2 не произведено, имеется письменное указание главного врача об отмене вскрытия",2},;
  {"3 не произведено, без обоснования"                                              ,3}}
Public menu_26_kek := {; // Карта разбора летального исхода на КИЛИ
  {"1 имеется"    ,1},;
  {"2 отсутствует",2}}
Public menu_27_kek := {; // Замечания к карте разбора летального исхода на КИЛИ
  {"1 имеются"    ,1},;
  {"2 отсутствуют",2}}
Public menu_29_kek := {; // Оценка расхождения заключительного клинического и патологоанатомического диагнозов
  {"1 совпадают"              ,1},;
  {"2 расхождение 1 категории",2},;
  {"3 расхождение 2 категории",3},;
  {"4 расхождение 3 категории",4}}
Public menu_30_kek := {; // Оформление посмертного эпикриза
  {"1 оформлен полностью",1},;
  {"2 оформлен частично" ,2},;
  {"3 не оформлен"       ,3}}
Public mm_7_kek := {;
  {"рабочий"                    , 1},;
  {"служащий"                   , 2},;
  {"пенсия по возрасту"         , 3},;
  {"работающий пенсионер"       , 4},;
  {"соц.пособие по инвалидности", 5},;
  {"соц.пособие по безработице" , 6},;
  {"стипендия"                  , 7},;
  {"др.виды гос.обеспечения"    , 8},;
  {"на иждивении у отд.лиц"     , 9},;
  {"прочие"                     ,10}}
Public mm_9_kek := {;
  {"г.Волгоград"                 ,1},;
  {"г.Волжский"                  ,2},;
  {"г.Камышин"                   ,3},;
  {"муниц.обр-ние Волгоград.обл.",4},;
  {"поселение Волгоградской обл.",5},;
  {"другое"                      ,6}}
Public mm_13_kek := {{"плановая",1},{"экстренная",2}}
Public mm_14_kek := {;
  {"имеется"               , 1},;
  {"отсутствует"           , 2},;
  {"согласие родственников", 3},;
  {"решение консилиума"    , 4}}
Public mm_15_kek := {;
  {"направление"             , 1},;
  {"доставлен скорой помощью", 2},;
  {"самообращение"           , 3}}
Public mm_16_kek := {{"первичное",1},{"повторное",2}}
Public mm_17_kek := {;
  {"впервые в жизни"       , 1},;
  {"повторно"              , 2},;
  {"повторно в данном году", 3}}
Public mm_18_kek := {;
  {"выздоровление (выраженное улучшение)",1},;
  {"улучшение"                           ,2},;
  {"без изменений"                       ,3},;
  {"ухудшение"                           ,4},;
  {"летальный исход"                     ,5}}
Public menu_mi_kek := {;
  {"город",0},;
  {"область",1},;
  {"иногородний",2}}
Public mm_ocenka_kek := {;
  {"отлично"            , 5},;
  {"хорошо"             , 4},;
  {"удовлетворительно"  , 3},;
  {"неудовлетворительно", 2}}
return NIL

*

***** 01.07.13
Function kek_oblzdrav(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"Таблица  ~1",;
                "Таблица  ~3 - E",;
                "Таблица  ~6",;
                "Таблица  ~7 - A",;
                "Таблица  ~9 - B",;
                "Таблица 1~1 - C",;
                "Таблица 1~3 - D",;
                "Таблица 1~5 - K",;
                "Таблица 1~7 - P",;
                "Таблица 1~9 - R",;
                "Таблица ~21",;
                "Таблица 2~4"}
    mas_msg := {"Оценка профилей индикаторов и интегрированного показателя качества мед.помощи",;
                "Структурное распределение итоговых оценок качества медицинской помощи",;
                "Динамика оценок профилей индикаторов и интегрированного показателя качества мед.помощи",;
                "Блок A. Оценка качества ведения медицинской документации",;
                "Блок B. Оценка качества проведения диагностических мероприятий",;
                "Блок C. Оценка качества постановки диагноза",;
                "Блок D. Оценка качества проведения лечебно-профилактических мероприятий",;
                "Блок K. Оценка качества проведения консультаций",;
                "Блок P. Оценка качества преемственности лечебно-диагностических мероприятий",;
                "Блок R. Оценка качества экспертного заключения при летальном исходе",;
                "Оценка профилей индикаторов в зависимости от повода проведения экспертизы",;
                "Оценка профилей индикаторов в зависимости от уровня экспертизы"}
    mas_fun := {"kek_oblzdrav(1)",;
                "kek_oblzdrav(2)",;
                "kek_oblzdrav(3)",;
                "kek_oblzdrav(4)",;
                "kek_oblzdrav(5)",;
                "kek_oblzdrav(6)",;
                "kek_oblzdrav(7)",;
                "kek_oblzdrav(8)",;
                "kek_oblzdrav(9)",;
                "kek_oblzdrav(10)",;
                "kek_oblzdrav(11)",;
                "kek_oblzdrav(12)"}
    Private arr_m
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 3
    if (arr_m := ret_2_diap()) != NIL
      kek_oblzdrav6(6)
    endif
  otherwise
    if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
      do case
        case k == 1
          kek_oblzdrav1(1)
        case k == 2
          kek_oblzdrav3(3) // "E"
        case k == 4
          kek_oblzdrav3(7) // "A"
        case k == 5
          kek_oblzdrav3(9) // "B"
        case k == 6
          kek_oblzdrav3(11) // "C"
        case k == 7
          kek_oblzdrav3(13) // "D"
        case k == 8
          kek_oblzdrav3(15) // "K"
        case k == 9
          kek_oblzdrav3(17) // "P"
        case k == 10
          kek_oblzdrav3(19) // "R"
        case k == 11
          kek_oblzdrav1(21)
        case k == 12
          kek_oblzdrav24(24)
      endcase
    endif
endcase
if k > 10
  if between(k,1,12)
    si1 := k
  endif
endif
return NIL

*

***** 03.07.13
Function kek_oblzdrav1(par)
Local sb := {"a","b","c","d","k","p","r","e"}
Local adbf, ab, ar, i, poleK, poleO, pole, aitog[8], kitog[8]
afill(aitog,0) ; afill(kitog,0) ; skol := 0
mywait()
delFRfiles()
adbf := {{"name","C",130,0},;
         {"title_end","C",70,0},;
         {"table1","C",12,0},;
         {"namet1","C",50,0},;
         {"kol_itog","N",10,0},;
         {"kol_i1","C",10,0},;
         {"kol_i2","C",10,0},;
         {"kol_i3","C",10,0},;
         {"kol_i4","C",10,0},;
         {"kol_i5","C",10,0},;
         {"kol_i6","C",10,0},;
         {"kol_i7","C",10,0},;
         {"kol_i8","C",10,0},;
         {"oce_i1","C",10,0},;
         {"oce_i2","C",10,0},;
         {"oce_i3","C",10,0},;
         {"oce_i4","C",10,0},;
         {"oce_i5","C",10,0},;
         {"oce_i6","C",10,0},;
         {"oce_i7","C",10,0},;
         {"oce_i8","C",10,0},;
         {"period","C",100,0}}
dbcreate(fr_titl, adbf)
use (fr_titl) new alias FRT
append blank
frt->name := glob_mo[_MO_SHORT_NAME]
frt->period := arr_m[4]
adbf := {{"name","C",50,0},;
         {"kol","N",10,0},;
         {"k1","C",10,0},;
         {"k2","C",10,0},;
         {"k3","C",10,0},;
         {"k4","C",10,0},;
         {"k5","C",10,0},;
         {"k6","C",10,0},;
         {"k7","C",10,0},;
         {"k8","C",10,0},;
         {"o1","C",10,0},;
         {"o2","C",10,0},;
         {"o3","C",10,0},;
         {"o4","C",10,0},;
         {"o5","C",10,0},;
         {"o6","C",10,0},;
         {"o7","C",10,0},;
         {"o8","C",10,0}}
dbcreate(fr_data,adbf)
use (fr_data) new alias FRD
//
adbf := {;
  {"kod",  "N", 7, 0},;
  {"kol",  "N", 6, 0},;
  {"K_A",  "N", 1, 0},;   // коэф-т A
  {"K_B",  "N", 1, 0},;   // коэф-т B
  {"K_C",  "N", 1, 0},;   // коэф-т C
  {"K_D",  "N", 1, 0},;   // коэф-т D
  {"K_K",  "N", 1, 0},;   // коэф-т K
  {"K_P",  "N", 1, 0},;   // коэф-т P
  {"K_R",  "N", 1, 0},;   // коэф-т R
  {"K_E",  "N", 1, 0},;   // коэф-т E
  {"O_A",  "N", 5, 3},;   // оценка A
  {"O_B",  "N", 5, 3},;   // оценка B
  {"O_C",  "N", 5, 3},;   // оценка C
  {"O_D",  "N", 5, 3},;   // оценка D
  {"O_K",  "N", 5, 3},;   // оценка K
  {"O_P",  "N", 5, 3},;   // оценка P
  {"O_R",  "N", 5, 3},;   // оценка R
  {"O_E",  "N", 5, 3}}    // оценка E
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
R_Use(dir_server+"base1",,"B1")
R_Use(dir_server+"mo_keke",dir_server+"mo_keket","EKS")
R_Use(dir_server+"human",,"HUMAN")
R_Use(dir_server+"mo_kekh",,"HU")
set relation to kod_lu into HUMAN
go top
do while !eof()
  if between(human->k_data,arr_m[5],arr_m[6])
    select EKS
    find (str(hu->(recno()),7))
    do while eks->kod == hu->(recno())
      ab := f_ball_kek(hu->ishod)
      select TMP
      append blank
      if par == 1
        tmp->kod := hu->otd
      elseif par == 21
        tmp->kod := hu->POVOD_EKS
      endif
      for i := 1 to 8
        poleK := "tmp->k_"+sb[i]
        poleO := "tmp->o_"+sb[i]
        &poleK := ab[2,i]
        &poleO := ab[1,i]
        if &poleK > 0
          aitog[i] += &poleO
          kitog[i] ++
        endif
      next
      select EKS
      skip
    enddo
  endif
  select HU
  skip
enddo
//
dbcreate(cur_dir+"tmp2",adbf)
use (cur_dir+"tmp2") new
index on str(kod,7) to (cur_dir+"tmp2")
select TMP
go top
do while !eof()
  select TMP2
  find (str(tmp->kod,7))
  if !found()
    append blank
    tmp2->kod := tmp->kod
  endif
  ++ tmp2->kol
  select TMP
  skip
enddo
select TMP
index on str(kod,7) to (cur_dir+"tmp")
select TMP2
go top
do while !eof()
  skol += tmp2->kol
  select TMP
  for i := 1 to 8
    poleK := "tmp->k_"+sb[i]
    poleO := "tmp->o_"+sb[i]
    b := k := 0
    find (str(tmp2->kod,7))
    do while tmp->kod == tmp2->kod
      if &poleK > 0
        ++k ; b += &poleO
      endif
      skip
    enddo
    poleK := "tmp2->k_"+sb[i]
    poleO := "tmp2->o_"+sb[i]
    if k > 0
      &poleK := 1
      &poleO := b/k
    endif
  next
  select TMP2
  skip
enddo
close databases
use (fr_titl) new alias FRT
if par == 1
  frt->table1 := "Таблица 1"
  frt->namet1 := "Структурные подразделения"
elseif par == 21
  frt->table1 := "Таблица 21"
  frt->title_end := "в зависимости от повода проведения экспертизы"
  frt->namet1 := "Повод проведения экспертизы"
endif
use (fr_data) new alias FRD
R_Use(dir_server+"mo_otd",,"OV")
use (cur_dir+"tmp2") new
if par == 1
  set relation to kod into OV
  index on upper(ov->name) to (cur_dir+"tmp2")
elseif par == 21
  index on kod to (cur_dir+"tmp2")
endif
go top
do while !eof()
  select FRD
  append blank
  if par == 1
    frd->name := ov->name
  elseif par == 21
    frd->name := inieditspr(A__MENUVERT, menu_povod_kek, tmp2->kod)
  endif
  frd->kol := tmp2->kol
  for i := 1 to 8
    poleK := "tmp2->k_"+sb[i]
    poleO := "tmp2->o_"+sb[i]
    ar := _put_ocen_mz(&poleO,&poleK)
    pole := "frd->k"+lstr(i) ; &pole := ar[1]
    pole := "frd->o"+lstr(i) ; &pole := ar[2]
  next
  select TMP2
  skip
enddo
frt->kol_itog := skol
for i := 1 to 8
  ar := _put_ocen_mz(aitog[i]/kitog[i],kitog[i])
  pole := "frt->kol_i"+lstr(i) ; &pole := ar[1]
  pole := "frt->oce_i"+lstr(i) ; &pole := ar[2]
next
close databases
call_fr("mo_kek1")
return NIL

***** 01.07.13
Static Function _put_ocen_mz(v,k)
Local ret, s1, s2
if empty(k)
  ret := {"Не оценено","Не оценено"}
else
  s1 := alltrim(str_0(v,11,3))
  s2 := alltrim(str_0(v*5,11,2))
  if !("." $ s1)
    s1 += ".0"
  endif
  if !("." $ s2)
    s2 += ".0"
  endif
  ret := {s1,s2}
endif
return ret

*

***** 04.07.13
Function kek_oblzdrav3(par)
Local sb := {"a","b","c","d","k","p","r","e"}
Local adbf, ab, ar, i, ii, poleK, poleO, pole, aitog[8], kitog[8], kocenka[5],;
      ocenka, ar1, ar2, aitog1[8], kitog1[8], kk := 1, kp := 5
afill(aitog,0) ; afill(kitog,0) ; afill(kocenka,0) ; skol := 0
afill(aitog1,0) ; afill(kitog1,0) ; skol1 := 0
mywait()
do case
  case par == 7
    ii := 1 // "A"
  case par == 9
    ii := 2 // "B"
  case par == 11
    ii := 3 // "C"
    kp := 2
  case par == 13
    ii := 4 // "D"
    kp := 7
  case par == 15
    ii := 5 // "K"
    kp := 4
  case par == 17
    ii := 6 // "P"
    kp := 1 ; kk := 0
  case par == 19
    ii := 7 // "R"
  case par == 3
    ii := 8 // "E"
endcase
delFRfiles()
adbf := {{"name","C",130,0},;
         {"title_end","C",70,0},;
         {"table1","C",12,0},;
         {"namet1","C",50,0},;
         {"kol_itog","N",10,0},;
         {"kol_i1","C",10,0},;
         {"kol_i2","C",10,0},;
         {"kol_i3","C",10,0},;
         {"kol_i4","C",10,0},;
         {"kol_i5","C",10,0},;
         {"kol_i6","C",10,0},;
         {"kol_i7","C",10,0},;
         {"kol_i8","C",10,0},;
         {"oce_i1","C",10,0},;
         {"oce_i2","C",10,0},;
         {"oce_i3","C",10,0},;
         {"oce_i4","C",10,0},;
         {"oce_i5","C",10,0},;
         {"oce_i6","C",10,0},;
         {"oce_i7","C",10,0},;
         {"oce_i8","C",10,0},;
         {"period","C",100,0},;
         {"O_K","C",10,0},;
         {"O_1","C",10,0},;
         {"O_2","C",10,0},;
         {"O_3","C",10,0},;
         {"O_4","C",10,0},;
         {"O_5","C",10,0},;
         {"O_6","C",10,0},;
         {"O_7","C",10,0},;
         {"e5","N",10,0},;
         {"p5","C",10,0},;
         {"e4","N",10,0},;
         {"p4","C",10,0},;
         {"e3","N",10,0},;
         {"p3","C",10,0},;
         {"e2","N",10,0},;
         {"p2","C",10,0}}
dbcreate(fr_titl, adbf)
use (fr_titl) new alias FRT
append blank
frt->name := glob_mo[_MO_SHORT_NAME]
frt->period := arr_m[4]
adbf := {{"name","C",50,0},;
         {"kol","N",10,0},;
         {"k1","C",10,0},;
         {"k2","C",10,0},;
         {"k3","C",10,0},;
         {"k4","C",10,0},;
         {"k5","C",10,0},;
         {"k6","C",10,0},;
         {"k7","C",10,0},;
         {"k8","C",10,0},;
         {"o1","C",10,0},;
         {"o2","C",10,0},;
         {"o3","C",10,0},;
         {"o4","C",10,0},;
         {"o5","C",10,0},;
         {"o6","C",10,0},;
         {"o7","C",10,0},;
         {"o8","C",10,0},;
         {"O_K","C",10,0},;
         {"O_1","C",10,0},;
         {"O_2","C",10,0},;
         {"O_3","C",10,0},;
         {"O_4","C",10,0},;
         {"O_5","C",10,0},;
         {"O_6","C",10,0},;
         {"O_7","C",10,0},;
         {"e5","N",10,0},;
         {"p5","C",10,0},;
         {"e4","N",10,0},;
         {"p4","C",10,0},;
         {"e3","N",10,0},;
         {"p3","C",10,0},;
         {"e2","N",10,0},;
         {"p2","C",10,0}}
dbcreate(fr_data,adbf)
use (fr_data) new alias FRD
//
adbf := {;
  {"kod",  "N", 7, 0},;
  {"kol",  "N", 6, 0},;
  {"kol1", "N", 6, 0},;
  {"K_A",  "N", 1, 0},;   // коэф-т A
  {"K_B",  "N", 1, 0},;   // коэф-т B
  {"K_C",  "N", 1, 0},;   // коэф-т C
  {"K_D",  "N", 1, 0},;   // коэф-т D
  {"K_K",  "N", 1, 0},;   // коэф-т K
  {"K_P",  "N", 1, 0},;   // коэф-т P
  {"K_R",  "N", 1, 0},;   // коэф-т R
  {"K_E",  "N", 1, 0},;   // коэф-т E
  {"O_A",  "N", 5, 3},;   // оценка A
  {"O_B",  "N", 5, 3},;   // оценка B
  {"O_C",  "N", 5, 3},;   // оценка C
  {"O_D",  "N", 5, 3},;   // оценка D
  {"O_K",  "N", 5, 3},;   // оценка K
  {"O_P",  "N", 5, 3},;   // оценка P
  {"O_R",  "N", 5, 3},;   // оценка R
  {"O_E",  "N", 5, 3},;   // оценка E
  {"KK",   "N", 1, 0},;
  {"K1",   "N", 1, 0},;
  {"K2",   "N", 1, 0},;
  {"K3",   "N", 1, 0},;
  {"K4",   "N", 1, 0},;
  {"K5",   "N", 1, 0},;
  {"K6",   "N", 1, 0},;
  {"K7",   "N", 1, 0},;
  {"OK",   "N", 5, 3},;
  {"O1",   "N", 5, 3},;
  {"O2",   "N", 5, 3},;
  {"O3",   "N", 5, 3},;
  {"O4",   "N", 5, 3},;
  {"O5",   "N", 5, 3},;
  {"O6",   "N", 5, 3},;
  {"O7",   "N", 5, 3},;
  {"e5",   "N",10, 0},;
  {"p5",   "C",10, 0},;
  {"e4",   "N",10, 0},;
  {"p4",   "C",10, 0},;
  {"e3",   "N",10, 0},;
  {"p3",   "C",10, 0},;
  {"e2",   "N",10, 0},;
  {"p2",   "C",10, 0}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
R_Use(dir_server+"base1",,"B1")
R_Use(dir_server+"mo_keke",dir_server+"mo_keket","EKS")
R_Use(dir_server+"human",,"HUMAN")
R_Use(dir_server+"mo_kekh",,"HU")
set relation to kod_lu into HUMAN
go top
do while !eof()
  if between(human->k_data,arr_m[5],arr_m[6])
    select EKS
    find (str(hu->(recno()),7))
    do while eks->kod == hu->(recno()) .and. !eof()
      ab := f_ball_kek(hu->ishod,ii,@ar1,@ar2)
      select TMP
      append blank
      tmp->kod := hu->otd
      for i := 1 to 8
        poleK := "tmp->k_"+sb[i]
        poleO := "tmp->o_"+sb[i]
        &poleK := ab[2,i]
        &poleO := ab[1,i]
        if &poleK > 0
          aitog[i] += &poleO
          kitog[i] ++
          if i == ii
            ocenka := ret_ocenka_kek(ab[1,i])
            pole := "tmp->e"+lstr(ocenka)
            &pole := 1
            kocenka[ocenka] ++
          endif
        endif
      next
      if ii < 8
        tmp->ok := ar2[1]
        tmp->kk := ar2[2]
        for i := 1 to 7
          poleK := "tmp->k"+lstr(i)
          poleO := "tmp->o"+lstr(i)
          &poleO := ar1[i,1]
          &poleK := ar1[i,2]
          if &poleK > 0
            aitog1[i] += &poleO
            kitog1[i] ++
          endif
        next
      endif
      select EKS
      skip
    enddo
  endif
  select HU
  skip
enddo
//
dbcreate(cur_dir+"tmp2",adbf)
use (cur_dir+"tmp2") new
index on str(kod,7) to (cur_dir+"tmp2")
select TMP
go top
do while !eof()
  select TMP2
  find (str(tmp->kod,7))
  if !found()
    append blank
    tmp2->kod := tmp->kod
  endif
  ++ tmp2->kol
  if ii < 8
    poleK := "tmp->k_"+sb[ii]
    if &poleK > 0
      ++ tmp2->kol1
    endif
  endif
  tmp2->e5 += tmp->e5
  tmp2->e4 += tmp->e4
  tmp2->e3 += tmp->e3
  tmp2->e2 += tmp->e2
  select TMP
  skip
enddo
select TMP
index on str(kod,7) to (cur_dir+"tmp")
select TMP2
go top
do while !eof()
  skol += tmp2->kol
  skol1 += tmp2->kol1
  select TMP
  for i := 1 to 8
    poleK := "tmp->k_"+sb[i]
    poleO := "tmp->o_"+sb[i]
    b := k := 0
    find (str(tmp2->kod,7))
    do while tmp->kod == tmp2->kod .and. !eof()
      if &poleK > 0
        ++k ; b += &poleO
      endif
      skip
    enddo
    poleK := "tmp2->k_"+sb[i]
    poleO := "tmp2->o_"+sb[i]
    if k > 0
      &poleK := 1
      &poleO := b/k
    endif
  next
  select TMP
  for i := 1 to 8
    if i == 8
      poleK := "tmp->kk"
      poleO := "tmp->ok"
    else
      poleK := "tmp->k"+lstr(i)
      poleO := "tmp->o"+lstr(i)
    endif
    b := k := 0
    find (str(tmp2->kod,7))
    do while tmp->kod == tmp2->kod .and. !eof()
      if &poleK > 0
        ++k ; b += &poleO
      endif
      skip
    enddo
    if i == 8
      poleK := "tmp2->kk"
      poleO := "tmp2->ok"
    else
      poleK := "tmp2->k"+lstr(i)
      poleO := "tmp2->o"+lstr(i)
    endif
    if k > 0
      &poleK := 1
      &poleO := b/k
    endif
  next
  select TMP2
  skip
enddo
close databases
use (fr_titl) new alias FRT
frt->table1 := "Таблица "+lstr(par)
frt->namet1 := "Структурные подразделения"
use (fr_data) new alias FRD
R_Use(dir_server+"mo_otd",,"OV")
use (cur_dir+"tmp2") new
set relation to kod into OV
index on upper(ov->name) to (cur_dir+"tmp2")
go top
do while !eof()
  select FRD
  append blank
  frd->name := ov->name
  frd->kol := tmp2->kol
  for i := 1 to 8
    poleK := "tmp2->k_"+sb[i]
    poleO := "tmp2->o_"+sb[i]
    ar := _put_ocen_mz(&poleO,&poleK)
    pole := "frd->k"+lstr(i) ; &pole := ar[1]
    pole := "frd->o"+lstr(i) ; &pole := ar[2]
  next
  for i := 1 to kp
    poleK := "tmp2->k"+lstr(i)
    poleO := "tmp2->o"+lstr(i)
    pole := "frd->o_"+lstr(i)
    &pole := _put_ocen_mz(&poleO,&poleK)[1]
  next
  if ii < 8
    frd->o_k := lstr(tmp2->kol1)+" ("+lstr(round(tmp2->kol1/tmp2->kol*100,0))+"%)"
  endif
  frd->e5 := tmp2->e5
  frd->e4 := tmp2->e4
  frd->e3 := tmp2->e3
  frd->e2 := tmp2->e2
  ar := kek_ocenka_to_procent({0,tmp2->e2,tmp2->e3,tmp2->e4,tmp2->e5})
  frd->p5 := ar[5]
  frd->p4 := ar[4]
  frd->p3 := ar[3]
  frd->p2 := ar[2]
  select TMP2
  skip
enddo
frt->kol_itog := skol
for i := 1 to 8
  ar := _put_ocen_mz(aitog[i]/kitog[i],kitog[i])
  pole := "frt->kol_i"+lstr(i) ; &pole := ar[1]
  pole := "frt->oce_i"+lstr(i) ; &pole := ar[2]
next
for i := 1 to kp
  pole := "frt->o_"+lstr(i)
  &pole := _put_ocen_mz(aitog1[i]/kitog1[i],kitog1[i])[1]
next
if ii < 8
  frt->o_k := lstr(skol1)+" ("+lstr(round(skol1/skol*100,0))+"%)"
endif
frt->e5 := kocenka[5]
frt->e4 := kocenka[4]
frt->e3 := kocenka[3]
frt->e2 := kocenka[2]
ar := kek_ocenka_to_procent(kocenka)
frt->p5 := ar[5]
frt->p4 := ar[4]
frt->p3 := ar[3]
frt->p2 := ar[2]
close databases
call_fr("mo_kek"+lstr(par))
return NIL

***** 04.07.13
Static Function kek_ocenka_to_procent(ar1)
Local ar2[5], i, k := 0, k1 := 0, kol_max := 0, i_max := 5
aeval(ar1, {|x| k += x }) // итого количество оценок
for i := 1 to 5
  ar2[i] := 0
  if ar1[i] > 0 // если если экспертизы с соответствующей оценкой
    ar2[i] := round(ar1[i] / k * 100, 0) // подсчёт %
    if empty(ar2[i]) // если получается менее 1 %
      ar2[i] := 1    // всё равно установить 1 %
    endif
  endif
  k1 += ar2[i]
  if kol_max < ar2[i]
    kol_max := ar2[i] ; i_max := i // запомнить индекс максимального значения
  endif
next
ar2[i_max] += (100 - k1) // добавить погрешность в максимальный элемент
for i := 1 to 5
  ar2[i] := lstr(ar2[i])+"%"
next
return ar2

*

***** 02.07.13
Function kek_oblzdrav6()
Local ar1[3], ar2[3], v1, v2, v, fl1, fl2, pole
Local sb := {"a","b","c","d","k","p","r","e"}
Local adbf, ab, i, poleK, poleO, aitog[2,8], kitog[2,8]
afillall(aitog,0) ; afillall(kitog,0)
mywait()
adbf := {;
  {"kod",  "N", 1, 0},;
  {"kol",  "N", 6, 0},;
  {"K_A",  "N", 1, 0},;   // коэф-т A
  {"K_B",  "N", 1, 0},;   // коэф-т B
  {"K_C",  "N", 1, 0},;   // коэф-т C
  {"K_D",  "N", 1, 0},;   // коэф-т D
  {"K_K",  "N", 1, 0},;   // коэф-т K
  {"K_P",  "N", 1, 0},;   // коэф-т P
  {"K_R",  "N", 1, 0},;   // коэф-т R
  {"K_E",  "N", 1, 0},;   // коэф-т E
  {"O_A",  "N", 5, 3},;   // оценка A
  {"O_B",  "N", 5, 3},;   // оценка B
  {"O_C",  "N", 5, 3},;   // оценка C
  {"O_D",  "N", 5, 3},;   // оценка D
  {"O_K",  "N", 5, 3},;   // оценка K
  {"O_P",  "N", 5, 3},;   // оценка P
  {"O_R",  "N", 5, 3},;   // оценка R
  {"O_E",  "N", 5, 3}}    // оценка E
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
R_Use(dir_server+"mo_keke",dir_server+"mo_keket","EKS")
R_Use(dir_server+"human",,"HUMAN")
R_Use(dir_server+"mo_kekh",,"HU")
set relation to kod_lu into HUMAN
skol1 := skol2 := 0
go top
do while !eof()
  fl1 := between(human->k_data,arr_m[1,1],arr_m[1,2])
  fl2 := between(human->k_data,arr_m[2,1],arr_m[2,2])
  if fl1 .or. fl2
    if fl1 ; skol1++ ; endif
    if fl2 ; skol2++ ; endif
    select EKS
    find (str(hu->(recno()),7))
    do while eks->kod == hu->(recno())
      ab := f_ball_kek(hu->ishod)
      select TMP
      append blank
      tmp->kod := iif(fl1, 1, 2)
      for i := 1 to 8
        poleK := "tmp->k_"+sb[i]
        poleO := "tmp->o_"+sb[i]
        &poleK := ab[2,i]
        &poleO := ab[1,i]
        if &poleK > 0
          aitog[tmp->kod,i] += &poleO
          kitog[tmp->kod,i] ++
        endif
      next
      select EKS
      skip
    enddo
  endif
  select HU
  skip
enddo
//
dbcreate(cur_dir+"tmp2",adbf)
use (cur_dir+"tmp2") new
index on str(kod,1) to (cur_dir+"tmp2")
select TMP
go top
do while !eof()
  select TMP2
  find (str(tmp->kod,1))
  if !found()
    append blank
    tmp2->kod := tmp->kod
  endif
  ++ tmp2->kol
  select TMP
  skip
enddo
select TMP
index on str(kod,1) to (cur_dir+"tmp")
select TMP2
go top
do while !eof()
  select TMP
  for i := 1 to 8
    poleK := "tmp->k_"+sb[i]
    poleO := "tmp->o_"+sb[i]
    b := k := 0
    find (str(tmp2->kod,1))
    do while tmp->kod == tmp2->kod
      if &poleK > 0
        ++k ; b += &poleO
      endif
      skip
    enddo
    poleK := "tmp2->k_"+sb[i]
    poleO := "tmp2->o_"+sb[i]
    if k > 0
      &poleK := 1
      &poleO := b/k
    endif
  next
  select TMP2
  skip
enddo
delFRfiles()
adbf := {{"name","C",130,0},;
         {"kol1","N", 6,0},;
         {"k1_1","C",10,0},;
         {"k1_2","C",10,0},;
         {"k1_3","C",10,0},;
         {"k1_4","C",10,0},;
         {"k1_5","C",10,0},;
         {"k1_6","C",10,0},;
         {"k1_7","C",10,0},;
         {"k1_8","C",10,0},;
         {"o1_1","C",10,0},;
         {"o1_2","C",10,0},;
         {"o1_3","C",10,0},;
         {"o1_4","C",10,0},;
         {"o1_5","C",10,0},;
         {"o1_6","C",10,0},;
         {"o1_7","C",10,0},;
         {"o1_8","C",10,0},;
         {"kol2","N", 6,0},;
         {"k2_1","C",10,0},;
         {"k2_2","C",10,0},;
         {"k2_3","C",10,0},;
         {"k2_4","C",10,0},;
         {"k2_5","C",10,0},;
         {"k2_6","C",10,0},;
         {"k2_7","C",10,0},;
         {"k2_8","C",10,0},;
         {"o2_1","C",10,0},;
         {"o2_2","C",10,0},;
         {"o2_3","C",10,0},;
         {"o2_4","C",10,0},;
         {"o2_5","C",10,0},;
         {"o2_6","C",10,0},;
         {"o2_7","C",10,0},;
         {"o2_8","C",10,0},;
         {"kold","C",10,0},;
         {"kd_1","C",10,0},;
         {"kd_2","C",10,0},;
         {"kd_3","C",10,0},;
         {"kd_4","C",10,0},;
         {"kd_5","C",10,0},;
         {"kd_6","C",10,0},;
         {"kd_7","C",10,0},;
         {"kd_8","C",10,0},;
         {"od_1","C",10,0},;
         {"od_2","C",10,0},;
         {"od_3","C",10,0},;
         {"od_4","C",10,0},;
         {"od_5","C",10,0},;
         {"od_6","C",10,0},;
         {"od_7","C",10,0},;
         {"od_8","C",10,0},;
         {"period1","C",40,0},;
         {"period2","C",40,0}}
dbcreate(fr_titl, adbf)
use (fr_titl) new alias FRT
append blank
frt->name := glob_mo[_MO_SHORT_NAME]
frt->period1 := arr_m[2,3]
frt->period2 := arr_m[1,3]
frt->kol1 := skol2
frt->kol2 := skol1
v := frt->kol2 - frt->kol1
if v < 0
  s := lstr(v)
elseif v > 0
  s := "+"+lstr(v)
else
  s := "="
endif
frt->kold := s
//
for i := 1 to 8
  v1 := v2 := 0 ; fl1 := fl2 := .f.
  ar := _put_ocen_mz(aitog[2,i]/kitog[2,i],kitog[2,i])
  pole := "frt->k1_"+lstr(i) ; &pole := ar[1]
  pole := "frt->o1_"+lstr(i) ; &pole := ar[2]
  if kitog[2,i] > 0
    v2 := round_5(aitog[2,i]/kitog[2,i],3)
    fl1 := .t.
  endif
  ar := _put_ocen_mz(aitog[1,i]/kitog[1,i],kitog[1,i])
  pole := "frt->k2_"+lstr(i) ; &pole := ar[1]
  pole := "frt->o2_"+lstr(i) ; &pole := ar[2]
  if kitog[1,i] > 0
    v1 := round_5(aitog[1,i]/kitog[1,i],3)
    fl2 := .t.
  endif
  if fl1 .and. fl2
    v := round_5(v1-v2,3)
    if v < 0
      ar := _put_ocen_mz(abs(v),1)
      ar[1] := "-"+ar[1]
      ar[2] := "-"+ar[2]
    elseif v > 0
      ar := _put_ocen_mz(v,1)
      ar[1] := "+"+ar[1]
      ar[2] := "+"+ar[2]
    else
      ar := {"=","="}
    endif
    pole := "frt->kd_"+lstr(i) ; &pole := ar[1]
    pole := "frt->od_"+lstr(i) ; &pole := ar[2]
  endif
next
close databases
call_fr("mo_kek6")
return NIL

*

***** 03.07.13
Function kek_oblzdrav24(par)
Local sb := {"a","b","c","d","k","p","r","e"}
Local adbf, ab, ar, i, poleK, poleO, pole, aitog[8], kitog[8]
afill(aitog,0) ; afill(kitog,0) ; skol := 0
mywait()
delFRfiles()
adbf := {{"name","C",130,0},;
         {"title_end","C",70,0},;
         {"table1","C",12,0},;
         {"namet1","C",50,0},;
         {"kol_itog","N",10,0},;
         {"kol_i1","C",10,0},;
         {"kol_i2","C",10,0},;
         {"kol_i3","C",10,0},;
         {"kol_i4","C",10,0},;
         {"kol_i5","C",10,0},;
         {"kol_i6","C",10,0},;
         {"kol_i7","C",10,0},;
         {"kol_i8","C",10,0},;
         {"oce_i1","C",10,0},;
         {"oce_i2","C",10,0},;
         {"oce_i3","C",10,0},;
         {"oce_i4","C",10,0},;
         {"oce_i5","C",10,0},;
         {"oce_i6","C",10,0},;
         {"oce_i7","C",10,0},;
         {"oce_i8","C",10,0},;
         {"period","C",100,0}}
dbcreate(fr_titl, adbf)
use (fr_titl) new alias FRT
append blank
frt->name := glob_mo[_MO_SHORT_NAME]
frt->period := arr_m[4]
adbf := {{"name","C",50,0},;
         {"uroven","N",1,0},;
         {"kol","N",10,0},;
         {"k1","C",10,0},;
         {"k2","C",10,0},;
         {"k3","C",10,0},;
         {"k4","C",10,0},;
         {"k5","C",10,0},;
         {"k6","C",10,0},;
         {"k7","C",10,0},;
         {"k8","C",10,0},;
         {"o1","C",10,0},;
         {"o2","C",10,0},;
         {"o3","C",10,0},;
         {"o4","C",10,0},;
         {"o5","C",10,0},;
         {"o6","C",10,0},;
         {"o7","C",10,0},;
         {"o8","C",10,0}}
dbcreate(fr_data,adbf)
use (fr_data) new alias FRD
//
adbf := {;
  {"kod",  "N", 7, 0},;
  {"uroven","N",1, 0},;
  {"kol",  "N", 6, 0},;
  {"K_A",  "N", 1, 0},;   // коэф-т A
  {"K_B",  "N", 1, 0},;   // коэф-т B
  {"K_C",  "N", 1, 0},;   // коэф-т C
  {"K_D",  "N", 1, 0},;   // коэф-т D
  {"K_K",  "N", 1, 0},;   // коэф-т K
  {"K_P",  "N", 1, 0},;   // коэф-т P
  {"K_R",  "N", 1, 0},;   // коэф-т R
  {"K_E",  "N", 1, 0},;   // коэф-т E
  {"O_A",  "N", 5, 3},;   // оценка A
  {"O_B",  "N", 5, 3},;   // оценка B
  {"O_C",  "N", 5, 3},;   // оценка C
  {"O_D",  "N", 5, 3},;   // оценка D
  {"O_K",  "N", 5, 3},;   // оценка K
  {"O_P",  "N", 5, 3},;   // оценка P
  {"O_R",  "N", 5, 3},;   // оценка R
  {"O_E",  "N", 5, 3}}    // оценка E
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
R_Use(dir_server+"base1",,"B1")
R_Use(dir_server+"mo_keke",dir_server+"mo_keket","EKS")
R_Use(dir_server+"human",,"HUMAN")
R_Use(dir_server+"mo_kekh",,"HU")
set relation to kod_lu into HUMAN
go top
do while !eof()
  if between(human->k_data,arr_m[5],arr_m[6])
    select EKS
    find (str(hu->(recno()),7))
    do while eks->kod == hu->(recno())
      b1->(dbGoto(eks->kod_eks))
      ab := f_ball_kek(hu->ishod)
      select TMP
      append blank
      tmp->kod := hu->otd
      tmp->uroven := b1->p6
      for i := 1 to 8
        poleK := "tmp->k_"+sb[i]
        poleO := "tmp->o_"+sb[i]
        &poleK := ab[2,i]
        &poleO := ab[1,i]
        if &poleK > 0
          aitog[i] += &poleO
          kitog[i] ++
        endif
      next
      select EKS
      skip
    enddo
  endif
  select HU
  skip
enddo
//
dbcreate(cur_dir+"tmp2",adbf)
use (cur_dir+"tmp2") new
index on str(kod,7)+str(uroven,1) to (cur_dir+"tmp2")
select TMP
go top
do while !eof()
  select TMP2
  find (str(tmp->kod,7)+str(tmp->uroven,1))
  if !found()
    append blank
    tmp2->kod := tmp->kod
    tmp2->uroven := tmp->uroven
  endif
  ++ tmp2->kol
  select TMP
  skip
enddo
select TMP
index on str(kod,7)+str(uroven,1) to (cur_dir+"tmp")
select TMP2
go top
do while !eof()
  skol += tmp2->kol
  select TMP
  for i := 1 to 8
    poleK := "tmp->k_"+sb[i]
    poleO := "tmp->o_"+sb[i]
    b := k := 0
    find (str(tmp2->kod,7)+str(tmp2->uroven,1))
    do while tmp->kod == tmp2->kod .and. tmp->uroven == tmp2->uroven .and. !eof()
      if &poleK > 0
        ++k ; b += &poleO
      endif
      skip
    enddo
    poleK := "tmp2->k_"+sb[i]
    poleO := "tmp2->o_"+sb[i]
    if k > 0
      &poleK := 1
      &poleO := b/k
    endif
  next
  select TMP2
  skip
enddo
close databases
use (fr_titl) new alias FRT
frt->table1 := "Таблица 24"
frt->title_end := "в зависимости от уровня экспертизы"
frt->namet1 := "Структурные подразделения"
use (fr_data) new alias FRD
R_Use(dir_server+"mo_otd",,"OV")
use (cur_dir+"tmp2") new
set relation to kod into OV
index on upper(ov->name)+str(uroven,1) to (cur_dir+"tmp2")
go top
do while !eof()
  select FRD
  append blank
  frd->name := ov->name
  frd->uroven := tmp2->uroven
  frd->kol := tmp2->kol
  for i := 1 to 8
    poleK := "tmp2->k_"+sb[i]
    poleO := "tmp2->o_"+sb[i]
    ar := _put_ocen_mz(&poleO,&poleK)
    pole := "frd->k"+lstr(i) ; &pole := ar[1]
    pole := "frd->o"+lstr(i) ; &pole := ar[2]
  next
  select TMP2
  skip
enddo
frt->kol_itog := skol
for i := 1 to 8
  ar := _put_ocen_mz(aitog[i]/kitog[i],kitog[i])
  pole := "frt->kol_i"+lstr(i) ; &pole := ar[1]
  pole := "frt->oce_i"+lstr(i) ; &pole := ar[2]
next
close databases
call_fr("mo_kek24")
return NIL

*

***** 29.06.17 Распечатка отчётов по контролю качества и безопасности медицинской деятельности
Function kek_k_and_b(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"~Отчёт о работе уровней контроля качества",;
                "~Журнал внутреннего контроля качества"}
    mas_msg := {"Отчёт о работе 1-2-3 уровней контроля качества и безопасности медицинской деят-и",;
                "Журнал внутреннего контроля качества и безопасности медицинской деятельности"}
    mas_fun := {"kek_k_and_b(11)",;
                "kek_k_and_b(12)"}
    Private arr_m, ke
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
      kek_k_and_b1()
    endif
  case k == 12
    if (arr_m := year_month(T_ROW,T_COL-5)) != NIL .and. (ke := _work_eks(T_ROW,T_COL-5,,.f.)) != NIL
      kek_k_and_b2()
    endif
endcase
if k > 10
  if between(k,11,19)
    si1 := k
  endif
endif
return NIL

*

***** 31.03.15 Отчёт о работе уровней контроля качества
Function kek_k_and_b1()
Static mm_povod_kek := {; // повод экспертизы
  {"Случаи смерти в структуре стационарного отделения",1},;
  {"Ятрогении и внутрибольничные инфицирования",3},;
  {"Расхождения заключительных клинических паталогоанатомичсеких и судебно-медицинских диагнозов",2},;
  {"Повторная госпитализация по поводу одного и того же заболевания в течение года, если госпитализация не была ранее запланирована",5},;
  {"Жалобы",7},;
  {"Прочие",-1}}
Local adbf, ab, i, j, k, sh, HH := 80, reg_print := 5, n_file := "kek_kb_s"+stxt,;
      skol := 0, skols := 0, lurov, lpovod, t_arr[2], buf := save_maxrow()
mywait()
adbf := {;
  {"urov", "N", 1, 0},;
  {"povod","N", 1, 0},;
  {"kol1", "N", 6, 0},;
  {"kol2", "N", 6, 0}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
index on str(urov,1)+str(povod,1) to (cur_dir+"tmp")
R_Use(dir_server+"base1",,"B1")
R_Use(dir_server+"mo_keke",dir_server+"mo_keket","EKS")
R_Use(dir_server+"mo_kekh",dir_server+"mo_kekh","HU")
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2
i := 0
dbseek(dtos(arr_m[5]),.t.)
do while human->k_data <= arr_m[6] .and. !eof()
  @ maxrow(),1 say lstr(++i) color cColorWait
  if human_->USL_OK == 1 .and. human->schet > 0
    skol++
    if is_death(human_->RSLT_NEW) .and. human_->NOVOR == 0
      skols++
    endif
    select HU
    find (str(human->kod,7))
    if found()
      select EKS
      find (str(hu->(recno()),7))
      do while eks->kod == hu->(recno())
        ab := f_ball_kek(hu->ishod)
        if (lpovod := ascan(mm_povod_kek, {|x| x[2] == hu->POVOD_EKS })) == 0
          lpovod := 6
        endif
        b1->(dbGoto(eks->kod_eks))
        lurov := b1->p6
        if !between(lurov,1,3)
          lurov := 1
        endif
        select TMP
        find ("0"+str(lpovod,1))
        if !found()
          append blank
          tmp->urov := 0
          tmp->povod := lpovod
        endif
        if ab[1,9] == 5  // если оценка "5"
          tmp->kol2++    // то попадает в колонку "без дефектов"
        else
          tmp->kol1++
        endif
        select TMP
        find (str(lurov,1)+str(lpovod,1))
        if !found()
          append blank
          tmp->urov := lurov
          tmp->povod := lpovod
        endif
        if ab[1,9] == 5  // если оценка "5"
          tmp->kol2++    // то попадает в колонку "без дефектов"
        else
          tmp->kol1++
        endif
        select EKS
        skip
      enddo
    endif
  endif
  select HUMAN
  skip
enddo
if tmp->(lastrec()) == 0
  func_error(4,"Нет информации "+arr_m[4])
else
  arr_title := {;
"──────────────────────────────────────────────────────┬─────────────────────────────",;
"                                                      │     Количество случаев      ",;
"                                                      ├─────────┬───────────────────",;
"     Причина назначения экспертного разбора           │         │прошедш. экспертизу",;
"                                                      │  Всего  ├─────────┬─────────",;
"                                                      │         │с дефект.│без дефек",;
"──────────────────────────────────────────────────────┴─────────┴─────────┴─────────"}
  f_reg_print(arr_title,@sh)
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  for j := 0 to 3
    s := "Схема отчёта о работе "
    s += iif(j == 0, "1-2-3 уровней", lstr(j)+" уровня")
    s += " контроля качества и безопасности"
    if j == 3
      verify_FF(30,.t.,sh)
    else
      add_string("")
    endif
    add_string(center(s,sh))
    add_string(center("медицинской деятельности "+arr_m[4],sh))
    aeval(arr_title, {|x| add_string(x) } )
    skol1 := skol2 := 0
    for is := 1 to len(mm_povod_kek)
      select TMP
      find (str(j,1)+str(is,1))
      if is > 1
        add_string("")
      endif
      k := perenos(t_arr,mm_povod_kek[is,1],54)
      add_string(padr(t_arr[1],54)+iif(is==1,put_val(skols,10),space(10))+;
                 put_val(tmp->kol1,10)+put_val(tmp->kol2,10))
      for i := 2 to k
        add_string(t_arr[i])
      next
      skol1 += tmp->kol1
      skol2 += tmp->kol2
    next
    add_string(replicate("─",sh))
    add_string(padr("Всего",54)+put_val(skol,10)+put_val(skol1,10)+put_val(skol2,10))
  next
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
close databases
return NIL

***** 02.12.17 Журнал внутреннего контроля качества
Function kek_k_and_b2()
Local i, adbf, ab, k, o, ocenka
mywait()
delFRfiles()
adbf := {{"name","C",255,0},;
         {"name1","C",50,0},;
         {"period","C",100,0}}
dbcreate(fr_titl, adbf)
use (fr_titl) new alias FRT
append blank
frt->name := glob_mo[_MO_FULL_NAME]
frt->period := arr_m[4]
frt->name1 := charone(" ",ke[1])
adbf := {;
  {"nn",       "N", 6, 0},;
  {"date_eks", "D", 8, 0},;
  {"vrach",    "C",50, 0},;
  {"otd",      "C", 5, 0},;
  {"fio",      "C",50, 0},;
  {"uch_doc",  "C",99, 0},;
  {"diagnoz",  "C",99, 0},;
  {"v1",       "C", 3, 0},;
  {"v2",       "C", 3, 0},;
  {"v3",       "C", 3, 0},;
  {"v4",       "C", 3, 0},;
  {"v5",       "C", 3, 0},;
  {"v6",       "C", 3, 0},;
  {"v7",       "C", 3, 0},;
  {"O_I",      "N", 1, 0},;
  {"O_S",      "C", 4, 0},;
  {"O_E",      "C", 3, 0}}    // суммарная оценка
dbcreate(fr_data,adbf)
use (fr_data) new alias TMP
Private is_2017 := .t.
R_Use(dir_server+"mo_keke",dir_server+"mo_keket","EKS")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"mo_pers",,"P2")
R_Use(dir_server+"human",,"HUMAN")
R_Use(dir_server+"mo_kekh",,"HU")
set relation to kod_lu into HUMAN
go top
do while !eof()
  if between(human->k_data,arr_m[5],arr_m[6])
    is_2017 := (year(hu->K_DATA) > 2016)
    select EKS
    find (str(hu->(recno()),7))
    do while eks->kod == hu->(recno()) .and. !eof()
      if eks->kod_eks == ke[2]
        if is_2017
          ab := f_ball_kek(hu->ishod)
        else
          ab := f2_ball_kek(hu->ishod)
        endif
        select TMP
        append blank
        tmp->date_eks := eks->date_eks
        p2->(dbGoto(hu->vrach))
        otd->(dbGoto(hu->otd))
        tmp->vrach := fam_i_o(p2->fio)
        tmp->otd := otd->short_name
        tmp->fio := fam_i_o(human->fio)
        tmp->uch_doc := hu->IST_BOL
        tmp->diagnoz := alltrim(hu->KOD_DIAG)+" "+alltrim(hu->DIAG_OSN)
        if is_2017
          n := 6
          for k := 1 to 6
            if emptyall(ab[1,k],ab[2,k])
              --n
            else
              &("tmp->v"+lstr(k)) := str_0(ab[1,k],3,1)
            endif
          next
          if n == 0
            ocenka := 0
          else
            ocenka := round((ab[1,1]+ab[1,2]+ab[1,3]+ab[1,4]+ab[1,5]+ab[1,6])/n,1)
          endif
          if ocenka > 0.7
            o := 1
          elseif ocenka > 0.5
            o := 2
          else
            o := 3
          endif
          tmp->O_E := str(ocenka,3,1)
          tmp->O_I := o
          tmp->O_S := {"КМП","ДМП","НКМП"}[o]
        else
          tmp->v1  := str_0(ab[1],3,1)
          tmp->v2  := str_0(ab[2],3,1)
          tmp->v3  := str_0(ab[3],3,1)
          tmp->v4  := str_0(ab[4],3,1)
          tmp->v5  := str_0(ab[5],3,1)
          tmp->v6  := str_0(ab[6],3,1)
          tmp->v7  := str_0(ab[7],3,1)
          tmp->O_E := str(ab[8],3,1)
          tmp->O_I := ab[9]
          tmp->O_S := ab[10]
        endif
      endif
      select EKS
      skip
    enddo
  endif
  select HU
  skip
enddo
i := 0
select TMP
index on dtos(date_eks)+otd+upper(left(vrach,20))+upper(fio) to (fr_data)
dbeval({|| tmp->nn := ++i })
close databases
if arr_m[1] > 2016
  call_fr("mo_kek17gvkk")
else
  call_fr("mo_kek_gvkk")
endif  
return NIL

***** 30.02.17
Function f_ball_kek(_lishod,_par,_arr,_va)
Local i, ka, ke := 7, e, ocenka, _KOL_DEF := 0, ret, lusl_ok := 1, arr1[9], arr2[9]
DEFAULT _par TO 0
if !(type("is_2017") == "L")
  Private is_2017 := .t.
endif
if select("hu") > 0
  is_2017 := (year(hu->K_DATA) > 2016)
  lusl_ok := hu->usl_ok
endif
if is_2017
  ka := ke := 0
  for i := 1 to len(eks->EO_28)
    if substr(eks->EO_28,i,1) $ "12"
      ++ke
      if substr(eks->EO_28,i,1) == "2"
        ++ka
      endif
    endif
  next
  e := 0
  if ke > 0
    e := round_5(ka/ke, 3)
    _KOL_DEF := ke - ka
  endif
  ocenka := ret_ocenka_kek(e)
  f17_ball_kek(lusl_ok,arr1,arr2)
  arr1[8] := e
  arr1[9] := ocenka
  arr2[8] := ke
  arr2[9] := 1 
  ret := {arr1,arr2,_KOL_DEF}
  //ret := {{a,b,c,d,k,p,r,e,ocenka},{ka,kb,kc,kd,kk,kp,kr,ke,1},_KOL_DEF}
else // до 2017 года
  if between(_par,1,7)
    _arr := array(7,2) ; afillall(_arr,1) ; _va := {0,1}
  endif
  ka := 5
  Store 0 to a, a01, a02, a03, a04, a05
  * А - качество ведения документации
  do case  // А01 - объем описания состояния больного при поступлении в стационар - 2
    case eks->EO_2 == 1  // достаточный (замечаний нет)
      a01 := 1.0
    case eks->EO_2 == 2  // достаточный с незначительными замечаниями
      a01 := 0.75
    case eks->EO_2 == 3  // недостаточный
      a01 := 0.25
    case eks->EO_2 == 4  // описание состояния больного отсутствует
      a01 := 0
      ++_KOL_DEF
  endcase
  do case  // А02 - наличие ежедневных дневниковых записей - 5
    case eks->EO_5 == 1  // имеются (замечаний нет)
      a02 := 1.0
    case eks->EO_5 == 2  // имеются, с незначительными замечаниями
      a02 := 0.75
    case eks->EO_5 == 3  // имеются, нерегулярные, эпизодические
      a02 := 0.25
    case eks->EO_5 == 4  // отсутствуют
      a02 := 0
      ++_KOL_DEF
  endcase
  do case  // А03 - оформление медицинской документации - 7
    case eks->EO_7 == 1  // четкое
      a03 := 1.0
    case eks->EO_7 == 2  // нечеткое, небрежное
      a03 := 0.25
  endcase
  do case  // А04 - наличие дневников динамического круглосуточного наблюдения тяжелого больного - 8
    case eks->EO_8 == 0  // НЕ ВВЕДЕНО
      --ka
      if _par == 1
        _arr[4,2] := 0
      endif
    case eks->EO_8 == 1  // имеются, замечаний нет
      a04 := 1.0
    case eks->EO_8 == 2  // имеются, с незначительными замечаниями
      a04 := 0.75
    case eks->EO_8 == 3  // имеются, неполные, нечеткие
      a04 := 0.25
    case eks->EO_8 == 4  // отсутствуют, но были необходимы
      a04 := 0
      ++_KOL_DEF
  endcase
  do case  // А05 - этапные эпикризы при пребывании в стационаре более трех недель - 24
    case eks->EO_24 == 1  // не было необходимости
      --ka
      if _par == 1
        _arr[5,2] := 0
      endif
    case eks->EO_24 == 2  // имеются (замечаний нет)
      a05 := 1.0
    case eks->EO_24 == 3  // имеются (с незначительными замечаниями)
      a05 := 0.75
    case eks->EO_24 == 4  // имеются неполные, нечеткие
      a05 := 0.25
    case eks->EO_24 == 5  // отсутствуют, но были необходимы
      a05 := 0
      ++_KOL_DEF
  endcase
  a := round_5((a01+a02+a03+a04+a05)/ka, 3)
  if _par == 1
    _arr[1,1] := a01
    _arr[2,1] := a02
    _arr[3,1] := a03
    _arr[4,1] := a04
    _arr[5,1] := a05
    _va := {a,1}
  endif
  * В - диагностические мероприятия
  kb := 3
  Store 0 to b,b01,b01a,b01b,b02,b03
  do case  // В01 - план обследования и лечения больного - 4
    case eks->EO_4 == 1  // отсутствует 4.1
      b01 := 0
      ++_KOL_DEF
    case eks->EO_4 == 2  // имеется (комбинация из полусуммы В01а и В01б) 4.2
      do case  // В01а - своевременность плана обследования и лечения больного 4.2.1
        case eks->EO_4_2_1 == "А"  // имеется (замечаний нет)
          b01a := 1.0
        case eks->EO_4_2_1 == "Б"  // имеется (с незначительной задержкой, не повлиявшей на течение и исход заболевания)
          b01a := 0.75
        case eks->EO_4_2_1 == "В"  // составлен несвоевременно, с большой задержкой
          b01a := 0
          ++_KOL_DEF
      endcase
      do case  // В01б - обоснованность плана обследования и лечения больного 4.2.2
        case eks->EO_4_2_2 == "А"  // обоснован (замечаний нет)
          b01b := 1.0
        case eks->EO_4_2_2 == "Б"  // имеется (с незначительными замечаниями)
          b01b := 0.75
        case eks->EO_4_2_2 == "В"  // имеются существенные замечания
          b01b := 0.25
      endcase
      b01 := (b01a+b01b)/2
  endcase
  do case // В02 - своевременность и объем диагностических мероприятий - 10
    case eks->EO_10 == 1  // своевременно и в полном объеме
      b02 := 1.0
    case eks->EO_10 == 2  // несвоевременно, но в полном объеме
      b02 := 0.5
    case eks->EO_10 == 3  // своевременно, но не в полном объеме
      b02 := 0.5
    case eks->EO_10 == 4  // несвоевременно и не в полном объеме
      b02 := 0.25
    case eks->EO_10 == 5  // показаны, но не проведены
      b02 := 0
      ++_KOL_DEF
    case eks->EO_10 == 6  // проведены, но не показаны
      b02 := 0
      ++_KOL_DEF
  endcase
   // В03 - оценка результатов диагностических методов исследования - 11
  b03a := array(5) ; afill(b03a,0) ; k03a := 5
  for i := 1 to 5
    v := {eks->EO_11_L_1,eks->EO_11_L_2,eks->EO_11_L_3,eks->EO_11_L_4,eks->EO_11_L_5}[i]
    do case // В03а - оценка результатов лабораторных методов исследования - 11
      case empty(v)
        --k03a
      case v == "А"  // интерпретированы правильно, полностью
        b03a[i] := 1.0
      case v == "Б"  // интерпретированы правильно, частично
        b03a[i] := 0.75
      otherwise
        b03a[i] := 0
        ++_KOL_DEF
    endcase
  next
  b03b := array(4) ; afill(b03b,0) ; k03b := 4
  for i := 1 to 4
    v := {eks->EO_11_I_1,eks->EO_11_I_2,eks->EO_11_I_3,eks->EO_11_I_4}[i]
    do case // В03б - оценка результатов инструментальных методов исследования - 11
      case empty(v)
        --k03b
      case v == "А"  // интерпретированы правильно, полностью
        b03b[i] := 1.0
      case v == "Б"  // интерпретированы правильно, частично
        b03b[i] := 0.75
      otherwise
        b03b[i] := 0
        ++_KOL_DEF
    endcase
  next
  b03v := array(4) ; afill(b03v,0) ; k03v := 4
  for i := 1 to 4
    v := {eks->EO_11_R_1,eks->EO_11_R_2,eks->EO_11_R_3,eks->EO_11_R_4}[i]
    do case // В03в - оценка результатов рентгенографических методов исследования - 11
      case empty(v)
        --k03v
      case v == "А"  // интерпретированы правильно, полностью
        b03v[i] := 1.0
      case v == "Б"  // интерпретированы правильно, частично
        b03v[i] := 0.75
      otherwise
        b03v[i] := 0
        ++_KOL_DEF
    endcase
  next
  if emptyall(k03a,k03b,k03v)
    --kb
  else
    b03 := (b03a[1]+b03a[2]+b03a[3]+b03a[4]+b03a[5]+;
            b03b[1]+b03b[2]+b03b[3]+b03b[4]+;
            b03v[1]+b03v[2]+b03v[3]+b03v[4]) / (k03a+k03b+k03v)
  endif
  b := round_5((b01+b02+b03)/kb, 3)
  if _par == 2
    _arr[1,1] := b01
    _arr[2,1] := b02
    if empty(k03a)
      _arr[3,1] := _arr[3,2] := 0
    else
      _arr[3,1] := round_5((b03a[1]+b03a[2]+b03a[3]+b03a[4]+b03a[5])/k03a, 3)
    endif
    if empty(k03b)
      _arr[4,1] := _arr[4,2] := 0
    else
      _arr[4,1] := round_5((b03b[1]+b03b[2]+b03b[3]+b03b[4])/k03b, 3)
    endif
    if empty(k03v)
      _arr[5,1] := _arr[5,2] := 0
    else
      _arr[5,1] := round_5((b03v[1]+b03v[2]+b03v[3]+b03v[4])/k03v, 3)
    endif
    _va := {b,1}
  endif
  * С - постановка диагноза
  kc := 4
  Store 0 TO c,c01a,c01b,c01v,c02
  // С01 - соответствие диагнозов рубрификации МКБ 10 - 3
  do case  // С01а - соответствие диагноза при поступлении рубрификации МКБ 10 - 3
    case eks->EO_3_POST == "Б" // выставлен, соответствует
      c01a := 1.0
    case eks->EO_3_POST == "В" // выставлен, не соответствует
      c01a := 0.25
    case eks->EO_3_POST == "А" // не выставлен
      c01a := 0
      ++_KOL_DEF
  endcase
  do case  // С01б - соответствие предварительного диагноза рубрификации МКБ 10 - 3
    case eks->EO_3_PRED == "Б" // выставлен, соответствует
      c01b := 1.0
    case eks->EO_3_PRED == "В" // выставлен, не соответствует
      c01b := 0.25
    case eks->EO_3_PRED == "А" // не выставлен
      c01b := 0
      ++_KOL_DEF
  endcase
  do case  // С01в - соответствие клинического заключительного диагноза рубрификации МКБ 10 - 3
    case eks->EO_3_OSN == "Б" // выставлен, соответствует
      c01v := 1.0
    case eks->EO_3_OSN == "В" // выставлен, не соответствует
      c01v := 0.25
    case eks->EO_3_OSN == "А" // не выставлен
      c01v := 0
      ++_KOL_DEF
  endcase
  do case  // С02 - клинический заключительный диагноз - 12
    case eks->EO_12 == 1 // выставлен, соответствует результатам клинического исследования
      c02 := 1.0
    case eks->EO_12 == 2 // выставлен, но не соответствует результатам клинических исследований
      c02 := 0.5
    case eks->EO_12 == 3 // не выставлен
      c02 := 0
      ++_KOL_DEF
  endcase
  c := round_5((c01a+c01b+c01v+c02)/kc, 3)
  if _par == 3
    _arr[1,1] := round_5((c01a+c01b+c01v)/3, 3)
    _arr[2,1] := c02
    _va := {c,1}
  endif
  * D - лечебно-профилактические мероприятия
  kd := 7
  Store 0 To d,d01,d02,d03,d04,d05,d06,d07
  do case  // D01 - отражают ли дневниковые записи эффект от проводимой терапии - 6
    case eks->EO_6 == 1 // отражают полностью (замечаний нет)
      d01 := 1.0
    case eks->EO_6 == 2 // отражают полностью (с незначительными замечаниями)
      d01 := 0.75
    case eks->EO_6 == 3 // отражают частично
      d01 := 0.5
    case eks->EO_6 == 4 // не отражают
      d01 := 0
      ++_KOL_DEF
  endcase
  do case  // D02 - соответствие проводимого лечения выставленному диагнозу - 13
    case eks->EO_13 == 1 // соответствует полностью, замечаний нет
      d02 := 1.0
    case eks->EO_13 == 2 // соответствует, с незначительными замечаниями
      d02 := 0.75
    case eks->EO_13 == 3 // соответствует частично
      d02 := 0.25
    case eks->EO_13 == 4 // не соответствует
      d02 := 0
      ++_KOL_DEF
  endcase
  do case  // D03 - лечение начато - 14
    case eks->EO_14 == 1 // своевременно
      d03 := 1.0
    case eks->EO_14 == 2 // с задержкой по объективным причинам
      d03 := 0.75
    case eks->EO_14 == 3 // не своевременно
      d03 := 0
      ++_KOL_DEF
  endcase
  do case  // D04 - комбинации лекарственных средств, используемых при лечении - 15
    case eks->EO_15 == 1 // рациональны, замечаний нет
      d04 := 1.0
    case eks->EO_15 == 2 // рациональны, с незначительными замечаниями
      d04 := 0.75
    case eks->EO_15 == 3 // не рациональны
      d04 := 0
      ++_KOL_DEF
  endcase
  do case  // D05 - дозировка лекарственных препаратов в листах назначения - 16
    case eks->EO_16 == 1 // отражена полностью
      d05 := 1.0
    case eks->EO_16 == 2 // отражена с ошибками
      d05 := 0.75
    case eks->EO_16 == 3 // не отражена
      d05 := 0
      ++_KOL_DEF
  endcase
  do case  // D06 - соответствие сроков лечения стандартам, принятым по данному заболеванию при выписке больного из стационара - 17
    case eks->EO_17 == 1 // соответствуют стандартам
      d06 := 1.0
    case eks->EO_17 == 2 // превышают стандарты (грамотно обосновано)
      d06 := 1.0
    case eks->EO_17 == 3 // превышают стандарты (без обоснования)
      d06 := 0.25
    case eks->EO_17 == 4 // меньше принятых стандартов (грамотно обосновано)
      d06 := 1.0
    case eks->EO_17 == 5 // меньше принятых стандартов (без обоснования)
      d06 := 0.25
  endcase
  do case  // D07 - реанимационные мероприятия - 18
    case eks->EO_18 == 0 // НЕ ВВЕДЕНО
      --kd
      if _par == 4
        _arr[7,2] := 0
      endif
    case eks->EO_18 == 1 // проведены в полном объеме
      d07 := 1.0
    case eks->EO_18 == 2 // проведены частично
      d07 := 0.5
    case eks->EO_18 == 3 // не проведены
      d07 := 0
      ++_KOL_DEF
  endcase
  d := round_5((d01+d02+d03+d04+d05+d06+d07)/kd, 3)
  if _par == 4
    _arr[1,1] := d01
    _arr[2,1] := d02
    _arr[3,1] := d03
    _arr[4,1] := d04
    _arr[5,1] := d05
    _arr[6,1] := d06
    _arr[7,1] := d07
    _va := {d,1}
  endif
  * К - Консультации
  kk := 4
  Store 0 TO k,k01,k02,k03,k04
  do case // К01 - наличие записей заведующего отделением в истории болезни - 9
    case eks->EO_9 == 1 // не было необходимости
      --kk
      if _par == 5
        _arr[1,2] := 0
      endif
    case eks->EO_9 == 2 // имеются, замечаний нет
      k01 := 1.0
    case eks->EO_9 == 3 // имеются, с незначительными замечаниями
      k01 := 0.75
    case eks->EO_9 == 4 // имеются, неполные, нечеткие
      k01 := 0.25
    case eks->EO_9 == 5 // отсутствуют, но были необходимы
      k01 := 0
      ++_KOL_DEF
  endcase
  do case // К02 - консилиум и осмотр специалистами - 19
    case eks->EO_19 == 1 // не было необходимости
      --kk
      if _par == 5
        _arr[2,2] := 0
      endif
    case eks->EO_19 == 2 // проведен
      k02 := 1.0
    case eks->EO_19 == 3 // не проведен
      k02 := 0
      ++_KOL_DEF
  endcase
  do case // К03 - обращение за консультацией к главным внештатным специалистам - 20
    case eks->EO_20 == 1 // не было необходимости
      --kk
      if _par == 5
        _arr[3,2] := 0
      endif
    case eks->EO_20 == 2 // своевременно и обоснованно
      k03 := 1.0
    case eks->EO_20 == 3 // не своевременно и не обоснованно
      k03 := 0.25
    case eks->EO_20 == 4 // не обращались, но необходимо
      k03 := 0
      ++_KOL_DEF
  endcase
  do case // К04 - выполнение рекомендаций консультантов - 21
    case eks->EO_21 == 0 // НЕ ВВОДИЛИ
      --kk
      if _par == 5
        _arr[4,2] := 0
      endif
    case eks->EO_21 == 1 // выполнялись полностью
      k04 := 1.0
    case eks->EO_21 == 2 // выполнялись частично или не выполнялись по усмотрению лечащего врача
      k04 := 1.0
    case eks->EO_21 == 3 // не выполнялись без обоснований
      k04 := 0
      ++_KOL_DEF
  endcase
  if kk = 0
    --ke
    if _par == 5
      afillall(_arr,0) ; afill(_va,0)
    endif
  else
    k := round_5((k01+k02+k03+k04)/kk, 3)
    if _par == 5
      _arr[1,1] := k01
      _arr[2,1] := k02
      _arr[3,1] := k03
      _arr[4,1] := k04
      _va := {k,1}
    endif
  endif
  * Р - Преемственность (=P01)
  kp := 1
  Store 0 TO p
  if eks->EO_22 == 1  // необходимость перевода
    do case // Р01 - в случае необходимости перевод больного в специализированное отделение, учреждение произведен - 23
      case eks->EO_23 == 1 // своевременно и обоснованно
        p := 1.0
      case eks->EO_23 == 2 // не своевременно и/или не обоснованно
        p := 0.25
      case eks->EO_23 == 3 // не произведен
        p := 0
        ++_KOL_DEF
    endcase
    if _par == 6
      _arr[1,1] := p
      _va := {p,1}
    endif
  else
    --kp
    --ke
    if _par == 6
      afillall(_arr,0) ; afill(_va,0)
    endif
  endif
  * R - экспертное заключение при летальном исходе
  kr := 5
  Store 0 To r,r01,r02,r03,r04,r05
  if _lishod == 5 // летальный исход
    do case // R01 - в случае летального исхода вскрытие - 25
      case eks->EO_25 == 1 // произведено
        r01 := 1.0
      case eks->EO_25 == 2 // не произведено, имеется письменное указание главного врача об отмене вскрытия
        r01 := 1.0
      case eks->EO_25 == 3 // не произведено, без обоснования
        r01 := 0
        ++_KOL_DEF
    endcase
    do case // R02 - карта разбора летального исхода на КИЛИ - 26
      case eks->EO_26 == 1 // имеется
        r02 := 1.0
      case eks->EO_26 == 2 // отсутствует
        r02 := 0
        ++_KOL_DEF
    endcase
    do case // R03 - замечания к карте разбора летального исхода на КИЛИ - 27
      case eks->EO_27 == 2 // отсутствуют
        r03 := 1.0
      case eks->EO_27 == 1 // имеются
        r03 := 0.5
    endcase
    do case // R04 - оценка расхождения заключительного клинического и патологоанатомического диагнозов - 29
      case eks->EO_29 == 1 // совпадают
        r04 := 1.0
      case eks->EO_29 == 2 // расхождение 1 степени
        r04 := 0.75
      case eks->EO_29 == 3 // расхождение 2 степени
        r04 := 0.25
      case eks->EO_29 == 4 // расхождение 3 степени
        r04 := 0
        ++_KOL_DEF
    endcase
    do case // R05 - оформление посмертного эпикриза - 30
      case eks->EO_30 == 1 // оформлен полностью
        r05 := 1.0
      case eks->EO_30 == 2 // оформлен частично
        r05 := 0.5
      case eks->EO_30 == 3 // не оформлен
        r05 := 0
        ++_KOL_DEF
    endcase
    r := round_5((r01+r02+r03+r04+r05)/kr, 3)
    if _par == 7
      _arr[1,1] := r01
      _arr[2,1] := r02
      _arr[3,1] := r03
      _arr[4,1] := r04
      _arr[5,1] := r05
      _va := {r,1}
    endif
  else
    kr := 0
    --ke
    if _par == 7
      afillall(_arr,0) ; afill(_va,0)
    endif
  endif
  e := round_5((a+b+c+d+k+p+r)/ke, 3)
  ocenka := ret_ocenka_kek(e)
  ret := {{a,b,c,d,k,p,r,e,ocenka},{ka,kb,kc,kd,kk,kp,kr,ke,1},_KOL_DEF}
endif  
return ret

***** 30.11.17
Function f17_ball_kek(lusl_ok,ao,ad)
/* поликлиника
1 - а); 2 - б) - д) и и) - з); 3 - е) и и) - к); 4 - л); 5 - м) - н).
1 - Оформление документации: 1,2 // а
2 - Диагностика: - критерии 3,4,5,6,8,9,10,11 // б-д, ж-з
3 - Лечение: 7,12,13,14 // е, и-к 
4 - экспертиза: 15 // л
5 - диспансерное наблюдение: 16,17 // м-н */
Static arr_pol := {;
 {1,{1,2}},;
 {2,{3,4,5,6,8,9,10,11}},;
 {3,{7,12,13,14}},;
 {4,{15}},;
 {5,{16,17}};
}
/* стационар
1 - а); 2 - б) - д) и ж) - и); 3 - е) и к) - н); 4 - о) - с)
1 - Оформление документации: 1,2 // а 
2 - Диагностика: 3,4,5,6,8,9,10,11,12,13 // б-д, ж-и  
3 - Лечение: 7,14,15,16,17,18,19  // е, к-н 
4 - экспертиза: 20,21,22,23 // о-с
6 - дополнительные критерии: 31-70 */
Static arr_stac := {;
 {1,{1,2}},;
 {2,{3,4,5,6,8,9,10,11,12,13}},;
 {3,{7,14,15,16,17,18,19}},;
 {4,{20,21,22,23}},;
 {6,{31,70}};
}
Local i, j, k, e
afill(ao,0)
afill(ad,0)
for i := 1 to len(eks->EO_28)
  if substr(eks->EO_28,i,1) $ "12"
    if lusl_ok == 3 // поликлиника
      k := 1
      for j := 2 to 5
        if ascan(arr_pol[j,2],i) > 0
          k := arr_pol[j,1] ; exit
        endif
      next
    else // стационар
      k := 6
      for j := 1 to 4
        if ascan(arr_stac[j,2],i) > 0
          k := arr_stac[j,1] ; exit
        endif
      next
    endif
    ++ao[k]
    if substr(eks->EO_28,i,1) == "2"
      ++ad[k]
    endif
  endif
next
for k := 1 to 6
  e := 0
  if ao[k] > 0
    e := round_5(ad[k]/ao[k], 3)
    ad[k] := ao[k] - ad[k]  // кол-во дефектов
  endif
  ao[k] := e // оценка, приведённая к единице (за вычетом дефектов)
next
return NIL

***** 28.11.17 возврат оценок для журнала внутреннего контроля качества
Function f2_ball_kek(_lishod)
Local ke := 7, _KOL_DEF := 0
Store 0 to v1, v2, v3, v4, v5, v6, v7
ka := 5
Store 0 to a, a01, a02, a03, a04, a05
* А - качество ведения документации
do case  // А01 - объем описания состояния больного при поступлении в стационар - 2
  case eks->EO_2 == 1  // достаточный (замечаний нет)
    a01 := 1.0 ; v1 := 1
  case eks->EO_2 == 2  // достаточный с незначительными замечаниями
    a01 := 0.75 ; v1 := 0.5
  case eks->EO_2 == 3  // недостаточный
    a01 := 0.25
  case eks->EO_2 == 4  // описание состояния больного отсутствует
    a01 := 0
    ++_KOL_DEF
endcase
do case  // А02 - наличие ежедневных дневниковых записей - 5
  case eks->EO_5 == 1  // имеются (замечаний нет)
    a02 := 1.0
  case eks->EO_5 == 2  // имеются, с незначительными замечаниями
    a02 := 0.75
  case eks->EO_5 == 3  // имеются, нерегулярные, эпизодические
    a02 := 0.25
  case eks->EO_5 == 4  // отсутствуют
    a02 := 0
    ++_KOL_DEF
endcase
do case  // А03 - оформление медицинской документации - 7
  case eks->EO_7 == 1  // четкое
    a03 := 1.0
  case eks->EO_7 == 2  // нечеткое, небрежное
    a03 := 0.25
endcase
do case  // А04 - наличие дневников динамического круглосуточного наблюдения тяжелого больного - 8
  case eks->EO_8 == 0  // НЕ ВВЕДЕНО
    --ka
  case eks->EO_8 == 1  // имеются, замечаний нет
    a04 := 1.0
  case eks->EO_8 == 2  // имеются, с незначительными замечаниями
    a04 := 0.75
  case eks->EO_8 == 3  // имеются, неполные, нечеткие
    a04 := 0.25
  case eks->EO_8 == 4  // отсутствуют, но были необходимы
    a04 := 0
    ++_KOL_DEF
endcase
do case  // А05 - этапные эпикризы при пребывании в стационаре более трех недель - 24
  case eks->EO_24 == 1  // не было необходимости
    --ka
  case eks->EO_24 == 2  // имеются (замечаний нет)
    a05 := 1.0
  case eks->EO_24 == 3  // имеются (с незначительными замечаниями)
    a05 := 0.75
  case eks->EO_24 == 4  // имеются неполные, нечеткие
    a05 := 0.25
  case eks->EO_24 == 5  // отсутствуют, но были необходимы
    a05 := 0
    ++_KOL_DEF
endcase
a := round_5((a01+a02+a03+a04+a05)/ka, 3)
if (o := ret_ocenka_kek(a)) == 2
  v7 := 0
elseif o == 5
  v7 := 1
else
  v7 := 0.5
endif
* В - диагностические мероприятия
kb := 3
Store 0 to b,b01,b01a,b01b,b02,b03
do case  // В01 - план обследования и лечения больного - 4
  case eks->EO_4 == 1  // отсутствует 4.1
    b01 := 0
    ++_KOL_DEF
  case eks->EO_4 == 2  // имеется (комбинация из полусуммы В01а и В01б) 4.2
    do case  // В01а - своевременность плана обследования и лечения больного 4.2.1
      case eks->EO_4_2_1 == "А"  // имеется (замечаний нет)
        b01a := 1.0
      case eks->EO_4_2_1 == "Б"  // имеется (с незначительной задержкой, не повлиявшей на течение и исход заболевания)
        b01a := 0.75
      case eks->EO_4_2_1 == "В"  // составлен несвоевременно, с большой задержкой
        b01a := 0
        ++_KOL_DEF
    endcase
    do case  // В01б - обоснованность плана обследования и лечения больного 4.2.2
      case eks->EO_4_2_2 == "А"  // обоснован (замечаний нет)
        b01b := 1.0
      case eks->EO_4_2_2 == "Б"  // имеется (с незначительными замечаниями)
        b01b := 0.75
      case eks->EO_4_2_2 == "В"  // имеются существенные замечания
        b01b := 0.25
    endcase
    b01 := (b01a+b01b)/2
endcase
do case // В02 - своевременность и объем диагностических мероприятий - 10
  case eks->EO_10 == 1  // своевременно и в полном объеме
    b02 := 1.0
  case eks->EO_10 == 2  // несвоевременно, но в полном объеме
    b02 := 0.5
  case eks->EO_10 == 3  // своевременно, но не в полном объеме
    b02 := 0.5
  case eks->EO_10 == 4  // несвоевременно и не в полном объеме
    b02 := 0.25
  case eks->EO_10 == 5  // показаны, но не проведены
    b02 := 0
    ++_KOL_DEF
  case eks->EO_10 == 6  // проведены, но не показаны
    b02 := 0
    ++_KOL_DEF
endcase
 // В03 - оценка результатов диагностических методов исследования - 11
b03a := array(5) ; afill(b03a,0) ; k03a := 5
for i := 1 to 5
  v := {eks->EO_11_L_1,eks->EO_11_L_2,eks->EO_11_L_3,eks->EO_11_L_4,eks->EO_11_L_5}[i]
  do case // В03а - оценка результатов лабораторных методов исследования - 11
    case empty(v)
      --k03a
    case v == "А"  // интерпретированы правильно, полностью
      b03a[i] := 1.0
    case v == "Б"  // интерпретированы правильно, частично
      b03a[i] := 0.75
    otherwise
      b03a[i] := 0
      ++_KOL_DEF
  endcase
next
b03b := array(4) ; afill(b03b,0) ; k03b := 4
for i := 1 to 4
  v := {eks->EO_11_I_1,eks->EO_11_I_2,eks->EO_11_I_3,eks->EO_11_I_4}[i]
  do case // В03б - оценка результатов инструментальных методов исследования - 11
    case empty(v)
      --k03b
    case v == "А"  // интерпретированы правильно, полностью
      b03b[i] := 1.0
    case v == "Б"  // интерпретированы правильно, частично
      b03b[i] := 0.75
    otherwise
      b03b[i] := 0
      ++_KOL_DEF
  endcase
next
b03v := array(4) ; afill(b03v,0) ; k03v := 4
for i := 1 to 4
  v := {eks->EO_11_R_1,eks->EO_11_R_2,eks->EO_11_R_3,eks->EO_11_R_4}[i]
  do case // В03в - оценка результатов рентгенографических методов исследования - 11
    case empty(v)
      --k03v
    case v == "А"  // интерпретированы правильно, полностью
      b03v[i] := 1.0
    case v == "Б"  // интерпретированы правильно, частично
      b03v[i] := 0.75
    otherwise
      b03v[i] := 0
      ++_KOL_DEF
  endcase
next
if emptyall(k03a,k03b,k03v)
  --kb
else
  b03 := (b03a[1]+b03a[2]+b03a[3]+b03a[4]+b03a[5]+;
          b03b[1]+b03b[2]+b03b[3]+b03b[4]+;
          b03v[1]+b03v[2]+b03v[3]+b03v[4]) / (k03a+k03b+k03v)
endif
b := round_5((b01+b02+b03)/kb, 3)
if (o := ret_ocenka_kek(b)) == 2
  v2 := 0
elseif o == 5
  v2 := 1
else
  v2 := 0.5
endif
* С - постановка диагноза
kc := 4
Store 0 TO c,c01a,c01b,c01v,c02
// С01 - соответствие диагнозов рубрификации МКБ 10 - 3
do case  // С01а - соответствие диагноза при поступлении рубрификации МКБ 10 - 3
  case eks->EO_3_POST == "Б" // выставлен, соответствует
    c01a := 1.0
  case eks->EO_3_POST == "В" // выставлен, не соответствует
    c01a := 0.25
  case eks->EO_3_POST == "А" // не выставлен
    c01a := 0
    ++_KOL_DEF
endcase
do case  // С01б - соответствие предварительного диагноза рубрификации МКБ 10 - 3
  case eks->EO_3_PRED == "Б" // выставлен, соответствует
    c01b := 1.0
  case eks->EO_3_PRED == "В" // выставлен, не соответствует
    c01b := 0.25
  case eks->EO_3_PRED == "А" // не выставлен
    c01b := 0
    ++_KOL_DEF
endcase
do case  // С01в - соответствие клинического заключительного диагноза рубрификации МКБ 10 - 3
  case eks->EO_3_OSN == "Б" // выставлен, соответствует
    c01v := 1.0
  case eks->EO_3_OSN == "В" // выставлен, не соответствует
    c01v := 0.25
  case eks->EO_3_OSN == "А" // не выставлен
    c01v := 0
    ++_KOL_DEF
endcase
do case  // С02 - клинический заключительный диагноз - 12
  case eks->EO_12 == 1 // выставлен, соответствует результатам клинического исследования
    c02 := 1.0
  case eks->EO_12 == 2 // выставлен, но не соответствует результатам клинических исследований
    c02 := 0.5
  case eks->EO_12 == 3 // не выставлен
    c02 := 0
    ++_KOL_DEF
endcase
c := round_5((c01a+c01b+c01v+c02)/kc, 3)
if (o := ret_ocenka_kek(c)) == 2
  v3 := 0
elseif o == 5
  v3 := 1
else
  v3 := 0.5
endif
* D - лечебно-профилактические мероприятия
kd := 7
Store 0 To d,d01,d02,d03,d04,d05,d06,d07
do case  // D01 - отражают ли дневниковые записи эффект от проводимой терапии - 6
  case eks->EO_6 == 1 // отражают полностью (замечаний нет)
    d01 := 1.0
  case eks->EO_6 == 2 // отражают полностью (с незначительными замечаниями)
    d01 := 0.75
  case eks->EO_6 == 3 // отражают частично
    d01 := 0.5
  case eks->EO_6 == 4 // не отражают
    d01 := 0
    ++_KOL_DEF
endcase
do case  // D02 - соответствие проводимого лечения выставленному диагнозу - 13
  case eks->EO_13 == 1 // соответствует полностью, замечаний нет
    d02 := 1.0
  case eks->EO_13 == 2 // соответствует, с незначительными замечаниями
    d02 := 0.75
  case eks->EO_13 == 3 // соответствует частично
    d02 := 0.25
  case eks->EO_13 == 4 // не соответствует
    d02 := 0
    ++_KOL_DEF
endcase
do case  // D03 - лечение начато - 14
  case eks->EO_14 == 1 // своевременно
    d03 := 1.0
  case eks->EO_14 == 2 // с задержкой по объективным причинам
    d03 := 0.75
  case eks->EO_14 == 3 // не своевременно
    d03 := 0
    ++_KOL_DEF
endcase
do case  // D04 - комбинации лекарственных средств, используемых при лечении - 15
  case eks->EO_15 == 1 // рациональны, замечаний нет
    d04 := 1.0
  case eks->EO_15 == 2 // рациональны, с незначительными замечаниями
    d04 := 0.75
  case eks->EO_15 == 3 // не рациональны
    d04 := 0
    ++_KOL_DEF
endcase
do case  // D05 - дозировка лекарственных препаратов в листах назначения - 16
  case eks->EO_16 == 1 // отражена полностью
    d05 := 1.0
  case eks->EO_16 == 2 // отражена с ошибками
    d05 := 0.75
  case eks->EO_16 == 3 // не отражена
    d05 := 0
    ++_KOL_DEF
endcase
do case  // D06 - соответствие сроков лечения стандартам, принятым по данному заболеванию при выписке больного из стационара - 17
  case eks->EO_17 == 1 // соответствуют стандартам
    d06 := 1.0
  case eks->EO_17 == 2 // превышают стандарты (грамотно обосновано)
    d06 := 1.0
  case eks->EO_17 == 3 // превышают стандарты (без обоснования)
    d06 := 0.25
  case eks->EO_17 == 4 // меньше принятых стандартов (грамотно обосновано)
    d06 := 1.0
  case eks->EO_17 == 5 // меньше принятых стандартов (без обоснования)
    d06 := 0.25
endcase
do case  // D07 - реанимационные мероприятия - 18
  case eks->EO_18 == 0 // НЕ ВВЕДЕНО
    --kd
  case eks->EO_18 == 1 // проведены в полном объеме
    d07 := 1.0
  case eks->EO_18 == 2 // проведены частично
    d07 := 0.5
  case eks->EO_18 == 3 // не проведены
    d07 := 0
    ++_KOL_DEF
endcase
d := round_5((d01+d02+d03+d04+d05+d06+d07)/kd, 3)
if (o := ret_ocenka_kek(d)) == 2
  v4 := 0
elseif o == 5
  v4 := 2
else
  v4 := 1
endif
* К - Консультации
kk := 4
Store 0 TO k,k01,k02,k03,k04
do case // К01 - наличие записей заведующего отделением в истории болезни - 9
  case eks->EO_9 == 1 // не было необходимости
    --kk
  case eks->EO_9 == 2 // имеются, замечаний нет
    k01 := 1.0
  case eks->EO_9 == 3 // имеются, с незначительными замечаниями
    k01 := 0.75
  case eks->EO_9 == 4 // имеются, неполные, нечеткие
    k01 := 0.25
  case eks->EO_9 == 5 // отсутствуют, но были необходимы
    k01 := 0
    ++_KOL_DEF
endcase
do case // К02 - консилиум и осмотр специалистами - 19
  case eks->EO_19 == 1 // не было необходимости
    --kk
  case eks->EO_19 == 2 // проведен
    k02 := 1.0
  case eks->EO_19 == 3 // не проведен
    k02 := 0
    ++_KOL_DEF
endcase
do case // К03 - обращение за консультацией к главным внештатным специалистам - 20
  case eks->EO_20 == 1 // не было необходимости
    --kk
  case eks->EO_20 == 2 // своевременно и обоснованно
    k03 := 1.0
  case eks->EO_20 == 3 // не своевременно и не обоснованно
    k03 := 0.25
  case eks->EO_20 == 4 // не обращались, но необходимо
    k03 := 0
    ++_KOL_DEF
endcase
do case // К04 - выполнение рекомендаций консультантов - 21
  case eks->EO_21 == 0 // НЕ ВВОДИЛИ
    --kk
  case eks->EO_21 == 1 // выполнялись полностью
    k04 := 1.0
  case eks->EO_21 == 2 // выполнялись частично или не выполнялись по усмотрению лечащего врача
    k04 := 1.0
  case eks->EO_21 == 3 // не выполнялись без обоснований
    k04 := 0
    ++_KOL_DEF
endcase
if kk = 0
  --ke
  v5 := 2
else
  k := round_5((k01+k02+k03+k04)/kk, 3)
  if (o := ret_ocenka_kek(k)) == 2
    v5 := 0
  elseif o == 5
    v5 := 2
  else
    v5 := 1
  endif
endif
* Р - Преемственность (=P01)
kp := 1
Store 0 TO p
if eks->EO_22 == 1  // необходимость перевода
  do case // Р01 - в случае необходимости перевод больного в специализированное отделение, учреждение произведен - 23
    case eks->EO_23 == 1 // своевременно и обоснованно
      p := 1.0
    case eks->EO_23 == 2 // не своевременно и/или не обоснованно
      p := 0.25
    case eks->EO_23 == 3 // не произведен
      p := 0
      ++_KOL_DEF
  endcase
else
  --kp
  --ke
endif
* R - экспертное заключение при летальном исходе
kr := 5
Store 0 To r,r01,r02,r03,r04,r05
if _lishod == 5 // летальный исход
  do case // R01 - в случае летального исхода вскрытие - 25
    case eks->EO_25 == 1 // произведено
      r01 := 1.0
    case eks->EO_25 == 2 // не произведено, имеется письменное указание главного врача об отмене вскрытия
      r01 := 1.0
    case eks->EO_25 == 3 // не произведено, без обоснования
      r01 := 0
      ++_KOL_DEF
  endcase
  do case // R02 - карта разбора летального исхода на КИЛИ - 26
    case eks->EO_26 == 1 // имеется
      r02 := 1.0
    case eks->EO_26 == 2 // отсутствует
      r02 := 0
      ++_KOL_DEF
  endcase
  do case // R03 - замечания к карте разбора летального исхода на КИЛИ - 27
    case eks->EO_27 == 2 // отсутствуют
      r03 := 1.0
    case eks->EO_27 == 1 // имеются
      r03 := 0.5
  endcase
  do case // R04 - оценка расхождения заключительного клинического и патологоанатомического диагнозов - 29
    case eks->EO_29 == 1 // совпадают
      r04 := 1.0
    case eks->EO_29 == 2 // расхождение 1 степени
      r04 := 0.75
    case eks->EO_29 == 3 // расхождение 2 степени
      r04 := 0.25
    case eks->EO_29 == 4 // расхождение 3 степени
      r04 := 0
      ++_KOL_DEF
  endcase
  do case // R05 - оформление посмертного эпикриза - 30
    case eks->EO_30 == 1 // оформлен полностью
      r05 := 1.0
    case eks->EO_30 == 2 // оформлен частично
      r05 := 0.5
    case eks->EO_30 == 3 // не оформлен
      r05 := 0
      ++_KOL_DEF
  endcase
  r := round_5((r01+r02+r03+r04+r05)/kr, 3)
  if (o := ret_ocenka_kek(r)) == 2
    v6 := 0
  elseif o == 5
    v6 := 1
  else
    v6 := 0.5
  endif
else
  v6 := 1
  kr := 0
  --ke
endif
e := round_5((a+b+c+d+k+p+r)/ke, 3)
ocenka := round_5((v1+v2+v3+v4+v5+v6+v7)/10,1)
if ocenka > 0.7
  o := 1
elseif ocenka > 0.5
  o := 2
else
  o := 3
endif
return {v1,v2,v3,v4,v5,v6,v7,ocenka,o,{"КМП","ДМП","НКМП"}[o]}

***** вернуть оценку по КЭК
Function ret_ocenka_kek(e)
Local ocenka := 5
if mem_ocen_kek == 0  // 'до 0.7 - "2", до 0.8 - "3", до 0.9 - "4", до 1 - "5"'
  if e < 0.7
    ocenka := 2
  elseif e < 0.8
    ocenka := 3
  elseif e < 0.9
    ocenka := 4
  endif
else  // 'до 0.86 - "2", до 0.928 - "3", до 0.964 - "4", до 1 - "5"'
  if e < 0.86
    ocenka := 2
  elseif e < 0.928
    ocenka := 3
  elseif e < 0.964
    ocenka := 4
  endif
endif
return ocenka
