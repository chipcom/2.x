***** mo_pp.prg - режимы ввода данных для задачи "Приёмный покой"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

*****
Function begin_task_ppokoj()
Static n_zapusk := 0
Local i, ar, fl := .t.
if n_zapusk == 0
  ++n_zapusk
  _pp_nastr(0)
  ar := GetIniSect(tmp_ini,"PP_RAB_MESTO")
  Public memPPsvod     := int(val(a2default(ar,"PRN_SVOD",  "3")))
  Public memPPdos_fast := int(val(a2default(ar,"dos_fast",  "0")))
endif
if G_SIsLock(sem_vagno_task[X_PPOKOJ])
  fl := f_err_sem_vagno_task(X_PPOKOJ)
elseif copy_Tools_Ini()
  Tools_Ini_OMS(1,0,0)
  Tools_Ini_PP(1,0,0)
  _pp_nastr(1)
  if n_zapusk == 1 // только для первого запуска
    f_find_pp_OMS() // поиск историй болезни, по которым не создан л/учёта (по каким-либо причинам)
  endif
else
  fl := .f.
endif
return fl

*****
Function pp_nastr(k)
Static sk := 1, mas_pmt
Local str_sem, mas_msg, mas_fun, j, n
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"Экран ввода карточки пациента",;
                "Экран ввода истории болезни",;
                "Общие настройки",;
                "Рабочее место"}
    mas_msg := {'Настройка экрана ввода карточки пациента в картотеке (в задаче "Приёмный покой")',;
                'Настройка экрана ввода истории болезни',;
                'Общие настройки работы с задачей "Приёмный покой"',;
                'Настройка рабочего места оператора в задаче "Приёмный покой"'}
    mas_fun := {"pp_nastr(1)",;
                "pp_nastr(2)",;
                "pp_nastr(3)",;
                "pp_nastr(4)"}
    popup_prompt(T_ROW, T_COL+5, sk, mas_pmt, mas_msg, mas_fun)
  case k == 1
    if hb_user_curUser:IsAdmin()
      ne_real()
    else
      func_error(4,err_admin)
    endif
  case k == 2
    if hb_user_curUser:IsAdmin()
      pp_nastr_ist_bol()
    else
      func_error(4,err_admin)
    endif
  case k == 3
    if hb_user_curUser:IsAdmin()
      f1nastr_all(mas_pmt[k],X_PPOKOJ)
    else
      func_error(4,err_admin)
    endif
  case k == 4
    pp_nastr_rab_mesto()
endcase
if k > 0
  sk := k
endif
return NIL

***** 25.03.18
Function _pp_nastr(k)
Static file_mem := "pp_nastr"
Local mm_tmp, smsg
if k == 0 // инициализация файла и переменных
  mm_tmp := {;  // справочник настроек приемного покоя
   {"IST_BOL",     "N",     1,     0},; // нумерация истории болезни
   {"N_IST_BOL",   "N",     6,     0},; // последний номер истории болезни
   {"FILE_6"   ,   "C",    12,     0},; // шаблон согласия на обработку перс.данных
   {"FILE_7"   ,   "C",    12,     0},; // шаблон листа учета
   {"FILE_8"   ,   "C",    12,     0},; // шаблон истории болезни
   {"FILE_9"   ,   "C",    12,     0},; // шаблон стат.карты
   {"FILE_12"  ,   "C",    12,     0},; // шаблон титул истоии болезни
   {"FILE_XX"  ,   "C",     3,     0};  // маска личных шаблонов приёмного покоя
  }
  reconstruct(dir_server+file_mem,mm_tmp,,,.t.)
  if type("pp_IST_BOL") == "N"
    // второй раз зашли
  else
    Public pp_IST_BOL    := 1,;
           pp_N_IST_BOL  := 0,;
           pp_FILE_6     := "",;
           pp_FILE_7     := "LU_STAC",;
           pp_FILE_8     := "IST_BOL",;
           pp_FILE_9     := "F066",;
           pp_FILE_12    := "MO_025uA5_2",;
           pp_FILE_XX    := "SMO"
  endif
  G_Use(dir_server+file_mem,,"MV")
  if lastrec() == 0
    AddRecN()
    mv->IST_BOL := pp_IST_BOL // да
  else
    G_RLock(forever)
  endif
  if empty(mv->file_7)
    mv->file_7 := pp_FILE_7
  endif
  if empty(mv->file_8)
    mv->file_8 := pp_FILE_8
  endif
  if empty(mv->file_9)
    mv->file_9 := pp_FILE_9
  endif
  if empty(mv->file_XX)
    mv->file_XX := pp_FILE_XX
  endif
  if empty(mv->file_12)
    mv->file_12 := pp_FILE_12
  endif
  Use
elseif k == 1
  R_Use(dir_server+file_mem,,"MV")
  pp_IST_BOL    := mv->IST_BOL
  pp_N_IST_BOL  := mv->N_IST_BOL
  pp_FILE_6     := alltrim(mv->FILE_6)
  pp_FILE_7     := alltrim(mv->FILE_7)
  pp_FILE_8     := alltrim(mv->FILE_8)
  pp_FILE_9     := alltrim(mv->FILE_9)
  pp_FILE_12    := alltrim(mv->FILE_12)
  pp_FILE_XX    := alltrim(mv->FILE_XX)
  Use
endif
return NIL

***** настройка экрана ввода истории болезни
Function pp_nastr_ist_bol()
Local ar, mm_tmp := {}, smsg, buf
if Tools_Ini_PP(1,0,0,.t.)
  smsg := "настройкам экрана ввода истории болезни"
  buf := save_maxrow()
  mywait()
  close databases
  delete file tmp.dbf
  aadd(mm_tmp, {"NOVOR","N",1,0,NIL,;
                {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                'Вводить новорожденного'})
  aadd(mm_tmp, {"e_01","C",1,0,NIL,;
                NIL,;
                "",NIL,;
                'Список наиболее часто встречающихся направляющих МО',,;
                {||.f.} })
  aadd(mm_tmp, {"KEM_NAPR","C",1500,0,NIL,;
                {|x|menu_reader(x,{{|k,r,c| inp_bit_mo(k,r,c) }},A__FUNCTION)},;
                '',{|x| ini_ed_mo(x) },;
                '==>'})
  aadd(mm_tmp, {"POB_D_LEK","N",1,0,NIL,;
                {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                'Вводить побочное действие лекарств'})
  aadd(mm_tmp, {"KOD_VR","N",1,0,NIL,;
                {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                'Вводить табельный номер врача приёмного отделения'})
  aadd(mm_tmp, {"TRAVMA","N",1,0,NIL,;
                {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                'Вводить вид травмы'})
  aadd(mm_tmp, {"NE_ZAK","N",1,0,NIL,;
                {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
                0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
                'Запрещать ввод, если не закончено лечение по предыдущему случаю'})
  init_base(cur_dir+"tmp",,mm_tmp,0)
  use (cur_dir+"tmp") new
  append blank
  tmp->NOVOR     := pp_NOVOR
  tmp->KEM_NAPR  := pp_KEM_NAPR
  tmp->POB_D_LEK := pp_POB_D_LEK
  tmp->KOD_VR    := pp_KOD_VR
  tmp->TRAVMA    := pp_TRAVMA
  tmp->NE_ZAK    := pp_NE_ZAK
  close databases
  if f_edit_spr(A__EDIT,mm_tmp,smsg,"g_use(cur_dir+'tmp',,,.t.,.t.)",0,1) > 0
    use (cur_dir+"tmp") new
    pp_NOVOR     := tmp->NOVOR
    pp_KEM_NAPR  := rtrim(tmp->KEM_NAPR)
    pp_POB_D_LEK := tmp->POB_D_LEK
    pp_KOD_VR    := tmp->KOD_VR
    pp_TRAVMA    := tmp->TRAVMA
    pp_NE_ZAK    := tmp->NE_ZAK
    Tools_Ini_PP(2,0,0)
  endif
  close databases
  rest_box(buf)
endif
return NIL

*****
Function pp_nastr_rab_mesto()
Static group_ini := "PP_RAB_MESTO"
Static mm_prn_svod := {{"Elita 12cpi",2},;
                       {"Condensed 17cpi",3}},;
       mm_list_066 := {{"на обеих сторонах листа",0},;
                       {"на одной стороне листа ",1}},;
       mm_dos_fast := {{"через шаблоны DOS      ",0},;
                       {"через отчёты FastReport",1}}
Local ar, mm_tmp := {}, smsg, buf, old_ib
smsg := "настройкам рабочего места приёмного покоя"
buf := save_maxrow()
mywait()
close databases
delete file tmp.dbf
ar := GetIniSect(tmp_ini,group_ini)
if pp_IST_BOL == 1 // да
  aadd(mm_tmp, {"n_ist_bol","N",6,0,NIL,;
                NIL,;
                0,NIL,;
                "Номер последней введенной истории болезни (мед.карты)"})
  aadd(mm_tmp, {"e_date_01","C",1,0,NIL,;
                NIL,;
                " ",NIL,;
                replicate("-",78),,;
                {||.f.} })
endif
aadd(mm_tmp, {"prn_svod","N",1,0,NIL,;
              {|x|menu_reader(x,mm_prn_svod,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_prn_svod,x)},;
              'Режим печати сводов по направившим ЛПУ и по столам'})
aadd(mm_tmp, {"dos_fast","N",1,0,NIL,;
              {|x|menu_reader(x,mm_dos_fast,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_dos_fast,x)},;
              'Каким образом печатать документы'})
init_base(cur_dir+"tmp",,mm_tmp,0)
use (cur_dir+"tmp") new
append blank
if pp_IST_BOL == 1 // да
  R_Use(dir_server+"pp_nastr",,"MV")
  old_ib := tmp->N_IST_BOL := mv->N_IST_BOL
endif
tmp->PRN_SVOD   := int(val(a2default(ar,"PRN_SVOD",  "3")))
tmp->dos_fast   := int(val(a2default(ar,"dos_fast",  "0")))
close databases
if f_edit_spr(A__EDIT,mm_tmp,smsg,"g_use(cur_dir+'tmp',,,.t.,.t.)",0,1) > 0
  use (cur_dir+"tmp") new
  if pp_IST_BOL == 1 .and. old_ib != tmp->N_IST_BOL
    G_Use(dir_server+"pp_nastr",,"MV")
    G_RLock(forever)
    pp_N_IST_BOL := mv->N_IST_BOL := tmp->N_IST_BOL
  endif
  memPPsvod     := tmp->PRN_SVOD
  memPPdos_fast := tmp->dos_fast
  SetIniVar(tmp_ini,{;
             {group_ini,"PRN_SVOD",  tmp->PRN_SVOD  },;
             {group_ini,"dos_fast",  tmp->dos_fast  };
            })
endif
close databases
rest_box(buf)
return NIL

*****
Function f_pp_stol()
Local blk, arr[US_LEN]
blk := {|| iif(tip==0, {1,2}, {3,4}) }
arr[US_TOP      ] := T_ROW
arr[US_BOTTOM   ] := 22
arr[US_LEFT     ] := T_COL-5
arr[US_RIGHT    ] := T_COL-5+23
arr[US_BASE     ] := dir_server+"mo_ppst"
arr[US_ARR_BROWSE]:= {"═","░","═","N/BG,W+/N,B/BG,W+/B",.t.}
arr[US_COLUMN   ] := {{" Стол",{|| name},blk},;
                      {" Тип",{|| inieditspr(A__MENUVERT,menu_stdnst,tip) },blk}}
arr[US_BLK_DEL  ] := {|_k| fdel_pp_stol(_k) }
arr[US_IM_PADEG ] := arr[US_SEMAPHORE] := "столы"
arr[US_ROD_PADEG] := "столов"
arr[US_EDIT_SPR ] := {{"name","C",10,0,,,space(10),,"Стол"},;
                      {"tip","N",1,0,,;
                       {|x|menu_reader(x,menu_stdnst,A__MENUVERT,,,.f.)},;
                       1,{|x|inieditspr(A__MENUVERT,menu_stdnst,x)},;
                       "Тип"};
                     }
edit_u_spr(1,arr)
return NIL

*****
Function fdel_pp_stol(mkod)
Local fl := .t., buf := save_maxrow()
stat_msg("Ждите! Производится проверка на допустимость удаления данного стола")
R_Use(dir_server+"mo_pp",,"HU")
Locate for hu->stol == mkod progress
fl := !found()
Use
if !fl
  func_error(4,"Данный стол встречается в других базах данных. Удаление запрещено!")
endif
rest_box(buf)
return fl

***** Добавление истории болезни
Function add_ppokoj()
Private pr_kod_pp
ppokoj_kart(1)
if pr_kod_pp != NIL
  view_human_pp(1,pr_kod_pp)
endif
return NIL

***** Редактирование истории болезни и печать медицинской и стат.карты
Function edit_ppokoj()
Private pr_kod_pp
do while .t.
  view_human_pp(1,pr_kod_pp)
  if pr_kod_pp == NIL
    exit
  endif
enddo
return NIL

***** Перевод больного из одного отделения в другое
Function ppokoj_perevod()
if view_human_pp(3)
  f1pp_perevod()
endif
return NIL

*****
Function f1pp_perevod()
Local buf := savescreen(), blk, t_arr[BR_LEN]
Private last_rec, last_lpu, last_n_data, last_n_time, last_otd, last_stol
R_Use(dir_server+"mo_pp",,"HU")
goto (glob_perso_pp)
box_shadow(1,10,4,69,color1,glob_k_fio)
@ 2,11 say padc("поступил "+full_date(hu->n_data)+" в "+hu->n_time,58) color "G+/B"
@ 3,11 say padc('в "'+;
 alltrim(inieditspr(A__POPUPMENU, dir_server+"mo_otd", hu->otd))+'" ('+;
 alltrim(inieditspr(A__POPUPMENU, dir_server+"mo_uch", hu->lpu))+')',58) color color8
//
dbcreate(cur_dir+"tmp",{;
                {"rec_per"  ,   "N",     7,     0},;
                {"N_DATA"   ,   "D",     8,     0},; // дата перевода
                {"N_TIME"   ,   "C",     5,     0},; // время перевода
                {"LPU"      ,   "N",     3,     0},; // код учреждения
                {"OTD"      ,   "N",     3,     0},; // код отделения
                {"STOL"     ,   "N",     3,     0},; // стол
                {"DATE_VVOD",   "D",     8,     0},; // дата ввода данных
                {"KOD_P"    ,   "C",     1,     0};  // код пользователя
               })
use (cur_dir+"tmp") new
index on dtos(n_data)+n_time to (cur_dir+"tmp") descending
append blank
tmp->rec_per   := 0
tmp->N_DATA    := hu->N_DATA
tmp->N_TIME    := hu->N_TIME
tmp->LPU       := hu->LPU
tmp->OTD       := hu->OTD
tmp->STOL      := hu->STOL
tmp->DATE_VVOD := hu->DATE_VVOD
tmp->KOD_P     := hu->KOD_P
hu->(dbCloseArea())
//
if yes_parol
  R_Use(dir_server+"base1",,"BASE1")
endif
G_Use(dir_server+"mo_ppper",dir_server+"mo_ppper","PER")
find (str(glob_perso_pp,7))
do while per->kod == glob_perso_pp .and. !eof()
  select TMP
  append blank
  tmp->rec_per   := per->(recno())
  tmp->N_DATA    := per->N_DATA
  tmp->N_TIME    := per->N_TIME
  tmp->LPU       := per->LPU
  tmp->OTD       := per->OTD
  tmp->STOL      := per->STOL
  tmp->DATE_VVOD := per->DATE_VVOD
  tmp->KOD_P     := per->KOD_P
  select PER
  skip
enddo
select TMP
go top
f4pp_perevod()
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-5
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "Перевод из отделения в отделение"
t_arr[BR_TITUL_COLOR] := "W+/GR"
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.t.,300}
t_arr[BR_STEP_FUNC] := {|| f3pp_perevod()}
blk := {|| if(empty(tmp->rec_per), {3,4}, {1,2}) }
t_arr[BR_COLUMN] := {}
aadd(t_arr[BR_COLUMN], { "  Дата и время",{|| full_date(tmp->n_data)+" "+tmp->n_time }, blk })
aadd(t_arr[BR_COLUMN], { " ",{|| iif(tmp->rec_per==0,"поступление",padc("перевод",11)) }, blk })
aadd(t_arr[BR_COLUMN], { center("в отделение",30),{|| padr(inieditspr(A__POPUPMENU, dir_server+"mo_otd", tmp->otd),30) }, blk })
aadd(t_arr[BR_COLUMN], { center("Стол",10),{|| padr(inieditspr(A__POPUPMENU, dir_server+"mo_ppst", tmp->stol),10) }, blk })
t_arr[BR_STAT_MSG] := {|| ;
  status_key("^<Esc>^ выход; ^<Enter>^ редактирование; ^<Ins>^ добавление; ^<Del>^ удаление") }
t_arr[BR_EDIT] := {|nk,ob| f2pp_perevod(nk,ob,"edit") }
box_shadow(maxrow()-4,2,maxrow()-2,77,"W/B")
edit_browse(t_arr)
close databases
restscreen(buf)
return NIL

***** 14.03.18
Function f2pp_perevod(nKey,oBrow,regim)
Local ret := -1
Local buf, fl := .f., rec, rec1, k := maxrow()-10, tmp_color, ;
      old_n_data, old_n_time, old_otd
do case
  case regim == "edit"
    do case
      case nKey == K_INS .or. (nKey == K_ENTER .and. tmp->rec_per > 0 .and. ;
                                                   tmp->(recno())==last_rec)
        save screen to buf
        rec := tmp->(recno())
        if nKey == K_ENTER
          old_n_data := tmp->N_DATA
          old_n_time := tmp->N_TIME
          old_otd    := tmp->otd
          skip  // встать на предпоследнюю запись
          if !eof()
            old_n_data := tmp->N_DATA
            old_n_time := tmp->N_TIME
            old_otd    := tmp->otd
          endif
          goto (rec)
        endif
        Private much, m1uch := if(nkey==K_INS, last_lpu, tmp->lpu),;
                motd, m1otd := if(nkey==K_INS, 0, tmp->otd),;
                mn_data := if(nkey==K_INS, sys_date, tmp->n_data),;
                mn_time := if(nkey==K_INS, hour_min(seconds()), tmp->n_time),;
                mstol, m1stol := if(nkey==K_INS, last_stol, tmp->stol),;
                gl_area := {1,0,23,79,0}
        much := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1uch)
        motd := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
        mstol := inieditspr(A__POPUPMENU, dir_server+"mo_ppst", m1stol)
        tmp_color := setcolor(cDataCScr)
        box_shadow(k,pc1+1,maxrow()-3,pc2-1,,;
                       iif(nKey == K_INS,"Добавление","Редактирование"),;
                       cDataPgDn)
        do while .t.
          setcolor(cDataCGet)
          @ k+1,pc1+4 say "Дата перевода" get mn_data
          @ row(),col() say ", время" get mn_time pict pict_time
          @ k+2,pc1+4 say "в ЛПУ" get much ;
             reader {|x|menu_reader(x,{{|k,r,c| ret_uch_otd(k,r,c)}},A__FUNCTION,,,.f.)}
          @ k+3,pc1+4 say " в отделение" get motd when .f.
          @ k+4,pc1+4 say "Стол" get mstol ;
             reader {|x|menu_reader(x,{dir_server+"mo_ppst"},A__POPUPEDIT,,,.f.)}
          status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
          myread()
          if lastkey() != K_ESC
            if nKey == K_ENTER
              if !v_date_time(old_n_data,old_n_time,mn_data,mn_time)
                loop
              endif
              if old_n_data == mn_data .and. old_n_time == mn_time
                func_error(4,"Вы не сменили дату и время!")
                loop
              endif
              if old_otd == m1otd
                func_error(4,"Вы повторно выбрали то же самое отделение. Это недопустимо!")
                loop
              endif
            else
              if !v_date_time(last_n_data,last_n_time,mn_data,mn_time)
                loop
              endif
              if last_n_data == mn_data .and. last_n_time == mn_time
                func_error(4,"Вы не сменили дату и время!")
                loop
              endif
              if last_otd == m1otd
                func_error(4,"Вы повторно выбрали то же самое отделение. Это недопустимо!")
                loop
              endif
            endif
            if f_Esc_Enter(1)
              select PER
              if nKey == K_INS
                AddRec(7)
                per->kod := glob_perso_pp
              else
                goto (rec)
                G_RLock(forever)
              endif
              per->N_DATA    := mn_data
              per->N_TIME    := mn_time
              per->LPU       := m1uch
              per->OTD       := m1otd
              per->STOL      := m1stol
              per->DATE_VVOD := sys_date
              per->KOD_P     := kod_polzovat
              select TMP
              if nKey == K_INS
                append blank
                tmp->rec_per := per->(recno())
              endif
              tmp->N_DATA    := per->N_DATA
              tmp->N_TIME    := per->N_TIME
              tmp->LPU       := per->LPU
              tmp->OTD       := per->OTD
              tmp->STOL      := per->STOL
              tmp->DATE_VVOD := per->DATE_VVOD
              tmp->KOD_P     := per->KOD_P
              UNLOCK
              COMMIT
              oBrow:goTop()
              f4pp_perevod()
              ret := 0
            endif
          endif
          exit
        enddo
        setcolor(tmp_color)
        restore screen from buf
      case nKey == K_DEL .and. tmp->rec_per > 0 .and. ;
                   tmp->(recno()) == last_rec .and. f_Esc_Enter(2)
        select PER
        goto (tmp->rec_per)
        DeleteRec()
        select TMP
        DeleteRec()
        oBrow:goTop()
        f4pp_perevod()
        ret := 0
    endcase
endcase
return ret

*****
Function f3pp_perevod()
Local s1 := "", s2 := "", k, tmp_select := select()
if yes_parol .and. (k := asc(tmp->kod_p)) > 0
  select BASE1
  goto (k)
  s1 := "Оператор: "+crypt(base1->p1,gpasskod)
endif
if !empty(tmp->DATE_VVOD)
  s2 := "Дата ввода: "+full_date(tmp->DATE_VVOD)
endif
@ maxrow()-3, 4 say padr(s1,30) color color1
@ maxrow()-3,41 say padl(s2,35) color color8
select (tmp_select)
return NIL

*****
Function f4pp_perevod()
last_rec    := tmp->(recno())
last_lpu    := tmp->LPU
last_n_data := tmp->N_DATA
last_n_time := tmp->N_TIME
last_otd    := tmp->OTD
last_stol   := tmp->STOL
return NIL

***** Удаление истории болезни
Function del_ppokoj()
view_human_pp(2)
return NIL

***** 02.02.17
Function f_kart_pp(Loc_kod,kod_kartotek)
Static mm_gospit := {{"да ",0},{"нет",1}}
Static menu_bolnich := {{"нет",0},{"да ",1},{"РОД",2}}
Static st_rab_nerab := 0, st_reg_lech := 1, st_vrach := 0
Local bg := {|o,k| get_MKB10(o,k,.t.) }, is_mkb10 := .f., str_sem
Local buf := savescreen(), tmp_color := setcolor(), str_1, fl, i, j, k, arr_rec := {}, ;
      tmp_help := chm_help_code, s_msg, arr, c, pict_vr := "99999", pos_read := 0, ;
      k_read := 0, count_edit := 0, lapp_edit, llen, ldec, fl_ppdia := .f.
Default Loc_kod TO 0, kod_kartotek TO 0
if kod_kartotek == 0 // добавление в картотеку
  if (kod_kartotek := edit_kartotek(0,,,.t.)) == 0
    return NIL
  endif
endif
mywait()
change_sys_date() // перечитать системную дату (для ПП, работающих ночами)
if pp_ne_zak == 1 .and. Loc_kod == 0 .and. kod_kartotek > 0
  fl := 0
  R_Use(dir_server+"mo_pp",dir_server+"mo_pp_r","HU")
  find (str(kod_kartotek,7))
  do while hu->kod_k == kod_kartotek .and. !eof()
    if empty(hu->k_data) .and. hu->is_gospit == 0
      fl := 1 ; exit
    endif
    if hu->ishod2 == 6
      fl := 2 ; exit
    endif
    skip
  enddo
  hu->(dbCloseArea())
  if fl == 1
    return func_error(4,"Данный больной еще не закончил лечение по предыдущему случаю!")
  elseif fl == 2
    return func_error(4,"Данный больной умер!")
  endif
endif
Private mdate_r, m1vzros_reb
Private ;
   MKOD := Loc_kod                  ,; // код (номер записи)
   MKOD_K := kod_kartotek           ,; // код по картотеке
   MKOD_H := 0                      ,; // код по БД human
   MREG_LECH                        ,; // 1-стационарно, 2,3,4-дневной стационар
   M1REG_LECH := st_reg_lech        ,; // 1-стационарно, 2,3,4-дневной стационар
   MUCH_DOC := space(10)            ,; // номер медицинской карты
   M1FIO_KART := 1, MFIO_KART := space(50),;
   mfio, mpol,;
   m1novor := 0, mnovor, mcount_reb := 0,;
   mDATE_R2 := ctod(""), mpol2 := " ",;
   MPPRAB_NERAB, M1PPRAB_NERAB := 0 ,; // социальный статус 5-работающий, 6-неработающий
   MKATEGOR, M1KATEGOR := 11        ,; // от 1 до ...
   m1company := 0, mcompany, mm_company,;
   msmo := "", rec_inogSMO := 0,;
   mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100),;
   mkomu, M1KOMU := 0, M1STR_CRB := 0,; // 0-ОМС,1-компании,3-комитеты/МО,5-личный счет
   MVID_OPL, M1VID_OPL := 1         ,; // вид оплаты (1-ОМС,2-бюджет,3-платные,4-ДМС,5-другое)
   MKEM_NAPR := space(10)           ,; // кем направлен (справочник ЛПУ)
   M1KEM_NAPR := ""                 ,; // кем направлен (справочник ЛПУ)
   MKEM_DOST, M1KEM_DOST := 0       ,; // кем доставлен
   MPOB_D_LEK := space(100)         ,; // побочное действие лекарств
   MDIAG_NAPR := space(100)         ,; // диагноз направившего учреждения
   MDIAG_PR_P := space(100)         ,; // диагноз приемного отделения
   MVRACH := space(30)              ,; // фамилия и инициалы врача приёмного покоя
   M1VRACH := st_vrach, MTAB_NOM := 0,; // код, таб.№ врача приёмного покоя
   MSOST_OP, M1SOST_OP := 0         ,; // 0-нет,1-алкогольное,2-наркотическое
   MGOSPIT0, M1GOSPIT0 := 0         ,; // 0-первичн.,1-повторн.
   MGOSPIT1, M1GOSPIT1 := 0         ,; // 0-плановое,1-экстренное
   MGOSPIT2, M1GOSPIT2 := 0         ,; // 1-6часов,2-7\24часа,0-24часа\и\более
   MTRAVMA, M1TRAVMA := 0           ,; // тип травмы
   Much, M1uch := glob_uch[1]       ,; // код учреждения
   MOTD, M1OTD := glob_otd[1]       ,; // код отделения
   MN_DATA := sys_date              ,; // дата поступления
   MN_TIME := hour_min(seconds())   ,; // время поступления
   MIS_GOSPIT, M1IS_GOSPIT := 0     ,; // госпитализирован?
   MPR_GOSPIT, M1PR_GOSPIT := 0     ,; // почему не госпитализирован?
   MSTOL, M1STOL := 0               ,; // стол
   MG_DATA := sys_date              ,; // дата госпитализации
   MG_TIME := hour_min(seconds())   ,; // время госпитализации
   MK_DATA := ctod("")              ,; // дата окончания лечения
   MK_TIME := space(5)              ,; // время выписки
   MKOJKO_DNI := 0                  ,; // продолжительность госпитализации
   MISHOD1, M1ISHOD1 := 0           ,;
   MISHOD2, M1ISHOD2 := 0           ,;
   MBOLNICH, M1BOLNICH := 0         ,; // больничный (0-нет,1-да,2-по уходу)
   MDATE_B_1   := ctod("")          ,; // дата начала больничного
   MDATE_B_2   := ctod("")          ,; // дата окончания больничного
   mrodit_dr   := ctod("")          ,; // дата рождения родителя
   mrodit_pol  := " "               ,; // пол родителя
   arr_perevod := {}
_pp_nastr(1) // перечитать номер последней истории болезни
if pp_ist_bol == 1
  MUCH_DOC := padr(lstr(pp_n_ist_bol+1),10) // номер медицинской карты
endif
if Loc_kod > 0   // режим редактирования
  R_Use(dir_server+"mo_pp",dir_server+"mo_pp_k","HU")
  find (str(Loc_kod,7))
  MKOD_K      := hu->KOD_K       // код по картотеке
  MKOD_H      := hu->kod_h       // код по БД human
  M1REG_LECH  := hu->REG_LECH    // 1-стационарно, 2,3,4-дневной стационар
  MUCH_DOC    := hu->UCH_DOC     // номер медицинской карты
  if hu->NOVOR > 0
    m1novor := 1
    mcount_reb := hu->NOVOR
    mDATE_R2 := hu->DATE_R2
    mpol2 := hu->POL2
  endif
  M1PPRAB_NERAB := hu->RAB_NERAB   // битовое поле
  M1KATEGOR   := hu->KATEGOR     // от 1 до ...
  M1KOMU      := hu->KOMU        // от 0 до 5
  M1STR_CRB   := hu->STR_CRB     // код стр.компании, комитета и т.п.
  M1VID_OPL   := hu->VID_OPL     // вид оплаты (1-ОМС,2-ДМС,3-бюджет,4-платные,5-другое)
  M1KEM_NAPR  := hu->KEM_NAPR    // кем направлен (справочник ЛПУ)
  M1KEM_DOST  := hu->KEM_DOST    // кем доставлен
  M1VRACH     := hu->KOD_VR      // код врача
  M1SOST_OP   := hu->SOST_OP     // 0-нет,1-алкогольное,2-наркотическое
  M1GOSPIT0   := hu->GOSPIT0     //
  M1GOSPIT1   := hu->GOSPIT1     //
  M1GOSPIT2   := hu->GOSPIT2     //
  M1TRAVMA    := hu->TRAVMA      // тип травмы
  M1uch       := hu->LPU         // код учреждения
  M1OTD       := hu->OTD         // код отделения
  MN_DATA     := hu->N_DATA      // дата поступления
  MN_TIME     := hu->N_TIME      // время поступления
  M1IS_GOSPIT := hu->IS_GOSPIT   // госпитализирован?
  M1PR_GOSPIT := hu->PR_GOSPIT   // почему не госпитализирован?
  M1STOL      := hu->STOL        // стол
  MG_DATA     := hu->G_DATA      // дата госпитализации
  MG_TIME     := hu->G_TIME      // время госпитализации
  MK_DATA     := hu->K_DATA      // дата окончания лечения
  MK_TIME     := hu->K_TIME      // время выписки
  MKOJKO_DNI  := hu->KOJKO_DNI   // продолжительность госпитализации
  M1ISHOD1    := hu->ISHOD1      // исход лечения
  M1ISHOD2    := hu->ISHOD2      // исход лечения
  M1BOLNICH   := hu->BOLNICH     // больничный (0-нет,1-да,2-по уходу)
  if m1bolnich > 0
    MDATE_B_1 := hu->DATE_B_1    // дата начала больничного
    MDATE_B_2 := hu->DATE_B_2    // дата окончания больничного
    if m1bolnich == 2
      mrodit_dr  := hu->DATE_RODIT  // дата рождения родителя
      mrodit_pol := hu->POL_RODIT   // пол родителя
    endif
  endif
  R_Use(dir_server+"mo_ppdia",dir_server+"mo_ppdia","HUS")
  find (str(Loc_kod,7))
  do while hus->kod == Loc_kod .and. !eof()
    fl_ppdia := .t.
    do case
      case hus->tip == 1
        MDIAG_NAPR := hus->name // диагноз направившего учреждения
      case hus->tip == 2
        MDIAG_PR_P := hus->name // диагноз приемного отделения
      case hus->tip == 3
        MPOB_D_LEK := hus->name // побочное действие лекарств
    endcase
    skip
  enddo
  R_Use(dir_server+"mo_ppper",dir_server+"mo_ppper","HUP")
  find (str(Loc_kod,7))
  do while Loc_kod == hup->kod .and. !eof()
    aadd(arr_perevod, {"",hup->otd,hup->n_data,n_time,dtos(hup->n_data)+n_time})
    skip
  enddo
  asort(arr_perevod,,,{|x,y| x[5] < y[5] } )
  for i := 1 to len(arr_perevod)
    arr_perevod[i,1] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", arr_perevod[i,2])
  next
endif
if kod_kartotek > 0   // ФИО из картотеки
  R_Use(dir_server+"kartotek",,"KART")
  goto (kod_kartotek)
  R_Use(dir_server+"kartote_",,"KART_")
  goto (kod_kartotek)
  mfio := kart->FIO
  mpol := kart->pol
  mdate_r := kart->date_r
  MFIO_KART := _f_fio_kart()  
  m1vzros_reb := kart->vzros_reb
  msmo := kart_->SMO
  if alltrim(msmo) == '34'
    mnameismo := ret_inogSMO_name(1,,.t.) // открыть и закрыть
  endif
  if Loc_kod == 0
    if kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    endif
    if kart->RAB_NERAB == 0
      m1PPRAB_NERAB := setbit(m1PPRAB_NERAB,5)
    else
      m1PPRAB_NERAB := setbit(m1PPRAB_NERAB,6)
    endif
    if kart_->PENSIONER == 1
      m1PPRAB_NERAB := setbit(m1PPRAB_NERAB,8)
    endif
    M1VID_OPL := 0
    do case
      case m1komu == 0
        M1VID_OPL := setbit(M1VID_OPL,1) // ОМС
      case eq_any(m1komu,1,3) .and. m1str_crb > 0
        R_Use(dir_server+iif(m1komu==1,"str_komp","komitet"),,"_SK")
        goto (m1str_crb)
        if eq_any(_sk->ist_fin,I_FIN_LPU,I_FIN_PLAT,I_FIN_DMS)
          M1VID_OPL := setbit(M1VID_OPL,3) // платные услуги
        else
          M1VID_OPL := setbit(M1VID_OPL,2) // бюджет
        endif
        _sk->(dbCloseArea())
      case m1komu == 5
        M1VID_OPL := setbit(M1VID_OPL,3) // платные услуги
    endcase
  endif
endif
if !(left(msmo,2) == '34') // не Волгоградская область
  m1ismo := msmo ; msmo := '34'
endif
if m1vrach > 0
  R_Use(dir_server+"mo_pers",,"P2")
  goto (m1vrach)
  mvrach := fam_i_o(p2->fio)
  MTAB_NOM := p2->tab_nom
endif
close databases
Private gl_arr := {;  // для битовых полей
  {"vid_opl","N",3,0,,,,{|x|inieditspr(A__MENUBIT,menu_vid_opl,x)} },;
  {"pprab_nerab","N",10,0,,,,{|x|inieditspr(A__MENUBIT,mmpp_rab,x)} };
 }
much := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1uch)
motd := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
MNOVOR := inieditspr(A__MENUVERT, mm_danet, M1NOVOR)
if !empty(M1KEM_NAPR)
  mKEM_NAPR := ret_mo(M1KEM_NAPR)[_MO_SHORT_NAME]
endif
if m1is_gospit == 0
  m1pr_gospit := 0
endif
Private OLD_IS_GOSPIT := M1IS_GOSPIT
mvid_opl   := inieditspr(A__MENUBIT, menu_vid_opl, m1vid_opl)
mpprab_nerab := inieditspr(A__MENUBIT, mmpp_rab, m1pprab_nerab)
mreg_lech  := inieditspr(A__MENUVERT, mmpp_regim, m1reg_lech)
mkategor   := inieditspr(A__MENUVERT, mmpp_kategor, m1kategor)
MKEM_DOST  := inieditspr(A__MENUVERT, mmpp_kem_dost, M1KEM_DOST)
mis_gospit := inieditspr(A__MENUVERT, mm_gospit, m1is_gospit)
mpr_gospit := inieditspr(A__MENUVERT, mmpp_pr_gospit, m1pr_gospit)
msost_op   := inieditspr(A__MENUVERT, menu_sost_op, m1sost_op)
mgospit0   := inieditspr(A__MENUVERT, menu0gospit, m1gospit0)
mgospit1   := inieditspr(A__MENUVERT, mm_ekst    , m1gospit1)
mgospit2   := inieditspr(A__MENUVERT, menu2gospit, m1gospit2)
mishod1    := inieditspr(A__MENUVERT, mmpp1ishod, m1ishod1)
mishod2    := inieditspr(A__MENUVERT, mmpp2ishod, m1ishod2)
mtravma    := inieditspr(A__MENUVERT, mmpp_travma, m1travma)
mbolnich   := inieditspr(A__MENUVERT, menu_bolnich, m1bolnich)
mstol      := inieditspr(A__POPUPMENU, dir_server+"mo_ppst", m1stol)
if !eq_any(m1komu,0,1,3,5) ; m1komu := 0 ; endif
mkomu      := inieditspr(A__MENUVERT, mm_komu, m1komu)
mismo      := init_ismo(m1ismo)
Private old_name_smo := padr(inieditspr(A__MENUVERT,glob_arr_smo,int(val(msmo))),38)
f_valid_komu(,-1)
if m1komu == 0
  m1company := int(val(msmo))
elseif eq_any(m1komu,1,3)
  m1company := m1str_crb
endif
mcompany := inieditspr(A__MENUVERT, mm_company, m1company)
if m1komu == 0 .and. m1company == 34
  if !empty(mismo)
    old_name_smo := mcompany := padr(mismo,38)
  elseif !empty(mnameismo)
    old_name_smo := mcompany := padr(mnameismo,38)
  endif
endif
chm_help_code := 2002
str_1 := " медицинской карты стационарного больного"
if Loc_kod == 0
  str_1 := "Добавление"+str_1
else
  str_1 := "Редактирование"+str_1
endif
pr_1_str(str_1)
setcolor(color8)
myclear(1)
Private gl_area := {1,0,maxrow()-1,maxcol(),0}
status_key("^<Esc>^ - выход;  ^<PgDn>^ - запись;  ^<F1>^ - помощь")
setcolor(cDataCGet)
do while .t.
  j := 0
  //
  ++j; @ j,1 say "ФИО" get mfio_kart ;
       reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
       valid {|g,o| update_get("mkomu"),update_get("mcompany") }
  ++j
  if pp_NOVOR == 1
         @ j,1 say "Новорожденный?" get mnovor ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
               valid {|g,o| f_valid_novor(g,o) }
         @ j,col()+3 say "№/пп ребёнка" get mcount_reb pict "99" range 1,99 ;
               when (m1novor == 1)
         @ j,col()+3 say "Д.р. ребёнка" get mdate_r2 when (m1novor == 1)
    if mem_pol == 1
       @ j,col()+3 say "Пол ребёнка" get mpol2 ;
           reader {|x|menu_reader(x,menupol,A__MENUVERT,,,.f.)} ;
           when (m1novor == 1)
    else
       @ j,col()+3 say "Пол ребёнка" get mpol2 pict "@!" ;
           valid {|g| mpol2 $ "МЖ" } ;
           when (m1novor == 1)
    endif
  endif
  //
  ++j ; @ j,1 SAY "Режим лечения" GET mreg_lech ;
             reader {|x|menu_reader(x,mmpp_regim,A__MENUVERT,,,.f.)}
  //
  ++j ; @ j,1 say "№ истории болезни" get much_doc picture "@!"
  if pp_kod_vr == 1
       @ j,col()+1 say "Врач приёмного отд-ия" get MTAB_NOM pict "99999" ;
             valid {|g| v_kart_vrach(g) }
       @ j,col()+1 get mvrach when .f. color color14
  endif
  ++j ; @ j,1 SAY "Категория льготности" GET mkategor ;
             reader {|x|menu_reader(x,mmpp_kategor,A__MENUVERT,,,.f.)}
  //
  ++j ; @ j,1 SAY "Вид оплаты" GET mvid_opl ;
             reader {|x|menu_reader(x,menu_vid_opl,A__MENUBIT,,,.f.)}
        @ j,40 SAY "Статус" GET mpprab_nerab ;
               reader {|x|menu_reader(x,mmpp_rab,A__MENUBIT,,,.f.)}
  //
  ++j ; @ j,1 SAY "Принадлежность счета" GET mkomu ;
             reader {|x|menu_reader(x,mm_komu,A__MENUVERT,,,.f.)} ;
             valid {|g,o| f_valid_komu(g,o), ;
                          iif(m1komu==0, mcompany:=old_name_smo, nil),;
                          update_get("mcompany") }
       @ row(),col()+1 say "==>" get mcompany ;
           reader {|x|menu_reader(x,mm_company,A__MENUVERT,,,.f.)} ;
           when eq_any(m1komu,1,3)
  //
  ++j ; @ j,1 SAY "Кем доставлен" GET mkem_dost ;
             reader {|x|menu_reader(x,mmpp_kem_dost,A__MENUVERT,,,.f.)}
  ++j ; @ j,1 say "Направившая МО" get mkem_napr ;
            reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c)}},A__FUNCTION,,,.f.)}
  ++j ; @ j,1 SAY "Диагноз направившей МО :" GET MDIAG_NAPR pict "@S52"
  ++j ; @ j,1 SAY "Диагноз приёмного отд. :" GET MDIAG_PR_P pict "@S52"
 ++j
 if pp_POB_D_LEK == 1
        @ j,1 SAY "Побочное дейст.лекарств:" GET MPOB_D_LEK pict "@S52"
 endif
  ++j ; @ j,1 SAY "Доставлен в сост.опьянения" GET MSOST_OP ;
             reader {|x|menu_reader(x,menu_sost_op,A__MENUVERT,,,.f.)}
        @ j,col() SAY "," GET MGOSPIT2 ;
             reader {|x|menu_reader(x,menu2gospit,A__MENUVERT,,,.f.)}
        @ j,col()+1 SAY "от нач.заболевания"
 ++j
 if pp_TRAVMA == 1
        @ j,1 SAY "Вид травмы" GET mtravma ;
             reader {|x|menu_reader(x,mmpp_travma,A__MENUVERT,,,.f.)}
 endif
  ++j ; @ j,1 SAY "ЛПУ" GET much ;
             reader {|x|menu_reader(x,{{|k,r,c| ret_uch_otd(k,r,c)}},A__FUNCTION,,,.f.)}
        @ j,37 SAY "Отделение" GET motd when .f.
  ++j ; @ j,1 SAY "Дата поступления" GET mn_data valid valid_date_postup()
        @ j,col() SAY ", время" GET mn_time pict pict_time valid valid_date_postup()
  ++j ; @ j,1 SAY "Госпитализирован" GET mis_gospit ;
             reader {|x|menu_reader(x,mm_gospit,A__MENUVERT,,,.f.)} ;
             valid {|g,o| pp_valid_gospit(g,o)}
     @ j,col()+3 say "?" get mpr_gospit ;
             reader {|x|menu_reader(x,mmpp_pr_gospit,A__MENUVERT,,,.f.)} ;
             when m1is_gospit == 1
  ++j ; @ j,1 SAY "Госпит. по поводу дан.забол. в тек.году" get mgospit0 ;
             reader {|x|menu_reader(x,menu0gospit,A__MENUVERT,,,.f.)} ;
             when m1is_gospit == 0
     @ j,col() say "," get mgospit1 ;
             reader {|x|menu_reader(x,mm_ekst,A__MENUVERT,,,.f.)} ;
             when m1is_gospit == 0
  ++j ; @ j,1 SAY "Дата госпитализации" GET mg_data ;
             when m1is_gospit == 0
      @ j,col() SAY ", время" GET mg_time pict pict_time ;
             when m1is_gospit == 0
      @ j,50 SAY "Стол" GET mstol ;
             reader {|x|menu_reader(x,{dir_server+"mo_ppst"},A__POPUPEDIT,,,.f.)} ;
             when m1is_gospit == 0
  if Loc_kod > 0 .and. m1is_gospit == 0  // режим редактирования
    ++j ; @ j,1 SAY "Дата выписки (смерти)" color color8 GET mk_data ;
               valid {|g| pp_val_k_data(g) }
      @ j,col() SAY ", время" color color8  GET mk_time pict pict_time ;
               when !empty(mk_data)
    ++j ; @ j,1 SAY "Исход" color color8  GET mishod1 ;
               reader {|x|menu_reader(x,mmpp1ishod,A__MENUVERT,,,.f.)}
          @ j,40 SAY "Результат" color color8  GET mishod2 ;
               reader {|x|menu_reader(x,mmpp2ishod,A__MENUVERT,,,.f.)}
    //
    ++j; @ j,1 say "Больничный" color color8  get mbolnich ;
            reader {|x|menu_reader(x,menu_bolnich,A__MENUVERT,,,.f.)} ;
            valid {|g,o| f_valid_bolnich(g,o) }
         @ j,col()+1 say "==> с" color color8  get mdate_b_1 when m1bolnich > 0
         @ j,col()+1 say "по" color color8  get mdate_b_2 when m1bolnich > 0
         @ j,col()+1 say "Д.р.родителя" color color8  get mrodit_dr when m1bolnich == 2
    if mem_pol == 1
         @ j,col()+1 say "Пол" color color8  get mrodit_pol ;
                reader {|x|menu_reader(x,menupol,A__MENUVERT,,,.f.)} ;
                when m1bolnich == 2
    else
         @ j,col()+1 say "Пол" color color8  get mrodit_pol pict "@!" ;
                valid {|g| mrodit_pol $ "МЖ" } ;
                when m1bolnich == 2
    endif
    ++j ; @ j,1 SAY "Продолжительность госпитализации (койко-дней)" color color8 ;
                GET MKOJKO_DNI picture "999"
  endif
  count_edit := myread(,@pos_read,++k_read)
  k := f_alert({padc("Выберите действие",60,".")},;
               {" Выход без записи "," Запись "," Возврат в редактирование "},;
               iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
  if k == 3
    loop
  elseif k == 2
    if !empty(s_msg := pp_getmsg())
      func_error(4,s_msg+"!")
      loop
    endif
    if Loc_kod == 0 .and. kod_kartotek > 0
      fl := .f.
      R_Use(dir_server+"mo_pp",dir_server+"mo_pp_r","HU")
      find (str(kod_kartotek,7))
      do while hu->kod_k == kod_kartotek .and. !eof()
        if mn_data == hu->n_data .and. hu->is_gospit == 0
          fl := .t.
        endif
        skip
      enddo
      hu->(dbCloseArea())
      if fl
        func_error(4,"По данному больному уже был ввод с датой поступления "+full_date(mn_data)+"г.")
        loop
      endif
    endif
    if empty(CHARREPL("0",much_doc,space(10)))
      func_error(4,'Не заполнен номер истории болезни')
      loop
    endif
    err_date_diap(mn_data,"Дата начала лечения")
    err_date_diap(mk_data,"Дата окончания лечения")
    if !emptyany(mn_data,mk_data) .and. mk_data-mn_data > 182
      func_error(4,'Диапазон времени лечения данного больного превышает полгода!')
    endif
    mywait()
    use_base("mo_pp")
    if Loc_kod == 0 .and. pp_ist_bol == 1
      str_sem := "Приёмный покой - номер истории болезни"
      i := 0 ; fl := .t.
      do while ++i < 20 // столько попыток
        if G_SLock(str_sem)
          G_Use(dir_server+"pp_nastr",,"MV")
          k := mv->n_ist_bol+1
          select HU
          set order to 4
          do while .t.
            find (str(year(mn_data),4)+padr(lstr(k),10))
            if !found() ; exit ; endif
            ++k
          enddo
          select MV
          G_RLock(forever)
          mv->n_ist_bol := k
          mv->(dbCloseArea())
          MUCH_DOC := lstr(k)
          G_SUnLock(str_sem)
          fl := .f. ; exit
        endif
      enddo
      if fl
        close databases
        func_error(4,"Не удалось определить следующий номер истории болезни! Попытайтесь снова.")
        loop
      endif
    endif
    select HU
    set order to 1
    if Loc_kod > 0
      find (str(Loc_kod,7))
      G_RLock(forever)
    else
      Add1Rec(7)
      mkod := recno()
      replace hu->kod with mkod
    endif
    pr_kod_pp      := mkod
    st_rab_nerab   := M1PPRAB_NERAB
    st_reg_lech    := M1REG_LECH
    st_vrach       := m1vrach
    //
    hu->KOD_K      := MKOD_K         // код по картотеке
    hu->REG_LECH   := M1REG_LECH     // 1-стационарно, 2,3,4-дневной стационар
    hu->UCH_DOC    := MUCH_DOC       // номер медицинской карты
    hu->NOVOR      := iif(m1novor==0, 0       , mcount_reb)
    hu->DATE_R2    := iif(m1novor==0, ctod(""), mDATE_R2  )
    hu->POL2       := iif(m1novor==0, ""      , mpol2     )
    hu->RAB_NERAB  := M1PPRAB_NERAB
    hu->KATEGOR    := M1KATEGOR       // от 1 до ...
    hu->KOMU       := M1KOMU          // от 1 до 5
    hu->STR_CRB    := iif(eq_any(M1KOMU,1,3), m1company, 0) // код стр.компании, комитета и т.п.
    hu->VID_OPL    := M1VID_OPL       // вид оплаты (1-ОМС,2--бюджет,3-платные,4-ДМС,5-другое)
    hu->KEM_NAPR   := M1KEM_NAPR      // кем направлен (справочник ЛПУ)
    hu->KEM_DOST   := M1KEM_DOST      // кем доставлен
    hu->kod_vr     := m1vrach         // код врача приемного отделения
    hu->SOST_OP    := M1SOST_OP       // 0-нет,1-алкогольное,2-наркотическое
    hu->GOSPIT0    := M1GOSPIT0       // 1-первичн.,2-повторн.
    hu->GOSPIT1    := M1GOSPIT1       // 0-в плановом порядке,1-по экстренн.показаниям
    hu->GOSPIT2    := M1GOSPIT2       // 1-6часов,2-7\24часа,3-24часа\и\более
    hu->TRAVMA     := M1TRAVMA        // тип травмы
    hu->LPU        := m1uch           // код учреждения
    hu->OTD        := m1otd           // код отделения
    hu->N_DATA     := MN_DATA        // дата поступления
    hu->N_TIME     := MN_TIME        // время поступления
    hu->IS_GOSPIT  := M1IS_GOSPIT    // 0-госпитализирован, 1-нет
    hu->PR_GOSPIT  := M1PR_GOSPIT    // почему не ГОСПИТАЛИЗИРОВАН?
    hu->STOL       := M1STOL         // стол
    hu->G_DATA     := MG_DATA        // дата госпитализации
    hu->G_TIME     := MG_TIME        // время госпитализации
    hu->K_DATA     := MK_DATA        // дата окончания лечения
    hu->K_TIME     := MK_TIME        // время выписки
    hu->KOJKO_DNI  := MKOJKO_DNI     // продолжительность госпитализации
    hu->ISHOD1     := M1ISHOD1       // исход
    hu->ISHOD2     := M1ISHOD2       // исход
    hu->BOLNICH    := M1BOLNICH      // больничный (0-нет,1-да,2-по уходу)
    hu->bolnich    := m1bolnich
    hu->date_b_1   := iif(m1bolnich==0, ctod(""), mdate_b_1)
    hu->date_b_2   := iif(m1bolnich==0, ctod(""), mdate_b_2)
    hu->DATE_RODIT := iif(m1bolnich<2 , ctod(""), mrodit_dr)
    hu->POL_RODIT  := iif(m1bolnich<2 , ""      , mrodit_pol)
    if Loc_kod == 0  // только при добавлении записывать дату ввода
      hu->kod_p     := kod_polzovat
      hu->DATE_VVOD := sys_date
    endif
    Private flag_OMS := (hu->KOD_H > 0)
    hu->(dbUnLock())
    if fl_ppdia .or. !emptyall(MDIAG_NAPR,MDIAG_PR_P,MPOB_D_LEK)
      G_Use(dir_server+"mo_ppdia",dir_server+"mo_ppdia","HUS")
      do while .t.
        find (str(mkod,7))
        if !found() ; exit ; endif
        DeleteRec(.t.)
      enddo
      arr := {MDIAG_NAPR,MDIAG_PR_P,MPOB_D_LEK}
      for i := 1 to len(arr)
        if !empty(arr[i])
          AddRec(7)
          hus->kod := mkod
          hus->tip := i
          hus->name := arr[i]
        endif
      next
    endif
    if Loc_kod == 0 .and.;
       pp_OMS .and. (isbit(M1VID_OPL,1) .or. isbit(M1VID_OPL,2)) ; // ОМС,бюджет
              .and. (M1IS_GOSPIT == 0 ;  // ГОСПИТАЛИЗИРОВАН
                     .or. (M1IS_GOSPIT == 1 .and. M1PR_GOSPIT == 99)) // оказана амб.помощь в пр.покое
      G_SPlus(f_name_task(X_OMS)) // плюс 1 пользователь зашёл в задачу ОМС
      // если в задаче ОМС не выполняется ОТВЕТСТВЕННАЯ операция
      if !G_SIsLock(sem_vagno_task[X_OMS])
        R_Use(dir_server+"kartote_",,"KART_")
        R_Use(dir_server+"kartotek",,"KART")
        set relation to recno() into KART_
        R_Use(dir_server+"mo_kismo",,"KSN")
        G_Use(dir_server+"mo_hismo",,"HSN")
        Use_base("human")
        f_write_pp_OMS(mkod)
      else // иначе запишем код истории болезни в промежуточный файл
        G_Use(dir_server+"mo_ppadd",,"PPA")
        index on str(kod,7) to (cur_dir+"tmp_ppad")
        find (str(mkod,7))
        if !found()
          AddRec(7)
          ppa->kod := mkod
        endif
      endif
      G_SMinus(f_name_task(X_OMS))  // минус 1 пользователь (вышел из задачи ОМС)
    endif
    if Loc_kod == 0 // для контроля в регистратуре
      G_Use(dir_server+"mo_regi",{dir_server+"mo_regi1",;
                                  dir_server+"mo_regi2",;
                                  dir_server+"mo_regi3"},"RU")
      AddRec(1)
      ru->kod_k := MKOD_K // код по картотеке
      ru->tip := 1 // т.е. заносим код отделения
      ru->uch := m1uch
      ru->op  := m1otd
      ru->pdate := dtoc4(iif(empty(MG_DATA),sys_date,MG_DATA))
      ru->CTIME := iif(empty(MG_TIME),hour_min(seconds()),MG_TIME)
      ru->kod_p := kod_polzovat // код оператора
      ru->(dbCloseArea())
    endif
    write_work_oper(glob_task,OPER_LIST,iif(Loc_kod==0,1,2),1,count_edit)
    close databases
    if Loc_kod > 0 .and. flag_OMS .and. OLD_IS_GOSPIT == 0 .and. OLD_IS_GOSPIT != M1IS_GOSPIT
      stat_msg("Т.к. пациент более не госпитализирован, удалите лист учёта в подзадаче ОМС") ; mybell(10,OK)
    endif
    a_h := {}
    // проверка по датам
    if year(mdate_r) < 1900
      aadd(a_h, "дата рождения: "+full_date(mdate_r)+" ( < 1900г.)")
    endif
    if mdate_r > mn_data
      aadd(a_h, "дата рождения: "+full_date(mdate_r)+;
                " > даты поступления: "+full_date(mn_data))
    endif
    if !empty(mk_data) .and. mn_data > mk_data
      aadd(a_h, "дата начала лечения: "+full_date(mn_data)+;
                " > даты окончания лечения: "+full_date(mk_data))
    endif
    if empty(a_h)
      stat_msg("Запись завершена!",.f.)
      mybell(0.5,OK)
    else
      stat_msg("",.f.)
      ta := {"Запись завершена, но обнаружены неточности:",""}
      for i := 1 to len(a_h)
        aadd(ta, "- "+a_h[i])
      next
      n_message(ta,,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
    endif
  endif
  exit
enddo
close databases
setcolor(tmp_color)
restscreen(buf)
chm_help_code := tmp_help
return NIL

***** 12.11.17 поиск историй болезни, по которым не создан л/учёта (по каким-либо причинам)
Function f_find_pp_OMS()
Static nday := 7 // поиск на 7 дней назад
Local i, k, arr := {}, buf := save_maxrow()
WaitStatus("Поиск историй болезни, по которым в подзадаче ОМС не созданы листы учёта")
R_use_base("mo_pp")
set order to 2 // index on dtos(n_data)+n_time to (dir_server+"mo_pp_d") progress
dbseek(dtos(sys_date-nday),.t.)
do while !eof()
  UpdateStatus()
  if pp_OMS .and. (isbit(hu->VID_OPL,1) .or. isbit(hu->VID_OPL,2)) ; // ОМС,бюджет
              .and. (hu->IS_GOSPIT == 0 ;  // ГОСПИТАЛИЗИРОВАН
                     .or. (hu->IS_GOSPIT == 1 .and. hu->PR_GOSPIT == 99)) // оказана амб.помощь в пр.покое
    if emptyall(hu->TIP_H,hu->KOD_H) .and. hu->n_data >= sys_date-nday
      aadd(arr,hu->kod)
    endif
  endif
  skip
enddo  
if len(arr) > 0 // запишем коды истории болезни в промежуточный файл
  G_Use(dir_server+"mo_ppadd",,"PPA")
  index on str(kod,7) to (cur_dir+"tmp_ppad")
  for i := 1 to len(arr)
    find (str(arr[i],7))
    if !found()
      AddRec(7)
      ppa->kod := arr[i]
    endif
    if i % 50 == 0
      commit
    endif
  next
endif
close databases
rest_box(buf)  
return NIL

***** 11.11.17 записать заголовок листа учёта
Function f_write_pp_OMS(mkod)
Local fl, ldata, lUSL_OK, ret_kod_h := 0
if mkod <= 0
  return 0
endif
select HU
if mkod != hu->kod   // если не стоим на записи в БД ПП
  find (str(mkod,7)) // ищем
endif
if mkod != hu->kod   // не нашли
  return 0 // что-то не так с поиском (индексами)
endif
//
ldata := iif(hu->IS_GOSPIT == 0 .and. !empty(hu->G_DATA), hu->G_DATA, hu->N_DATA)
if ldata + 14 < sys_date
  return 1 // не записывать л/у двухнедельной давности (и более поздние)
endif
if hu->IS_GOSPIT == 0 // ГОСПИТАЛИЗИРОВАН
  lUSL_OK := pp_reg_lech_usl_ok(hu->reg_lech)
else // (M1IS_GOSPIT == 1 .and. M1PR_GOSPIT == 99)) // оказана амб.помощь в пр.покое
  lUSL_OK := 3 // поликлиника
endif
if empty(hu->kod_h) // проверить, если ещё не записано (по данным в БД приёмного покоя)
  select HUMAN
  set order to 2
  find (str(hu->kod_k,7))
  do while human->kod_k == hu->kod_k .and. !eof()
    if lUSL_OK == human_->USL_OK .and. human->n_data == ldata // этот л/у введён ручками
      ret_kod_h := human->(recno())
      exit
    endif  
    skip
  enddo  
  if ret_kod_h > 0 // запишем ссылку на лист учёта в БД приёмного покоя
    select HU
    G_RLock(forever)
    hu->TIP_H := 1      // 1-human,2-hum_p,3-...
    hu->KOD_H := ret_kod_h // код по БД human
    if hu->IS_GOSPIT == 0 .and. empty(hu->G_DATA) // 0-госпитализирован и не заполнена дата госпитализации
      hu->G_DATA := hu->N_DATA   // дата госпитализации
      hu->G_TIME := hu->N_TIME   // время госпитализации
    endif
    dbUnLock()
    return ret_kod_h
  endif
endif
m1novor := hu->NOVOR
select KART
goto (hu->kod_k)
mdate_r := kart->date_r
if hu->IS_GOSPIT == 0
  fv_date_r(hu->g_data,.f.) // переопределяем m1vzros_reb
else
  fv_date_r(hu->n_data,.f.) // переопределяем m1vzros_reb
endif
if !(type("M1VZROS_REB") == "N")
  M1VZROS_REB := 0 // на всякий случай (т.к. до этого были сбои в определении)
endif
select HUMAN
set order to 1
if empty(ret_kod_h := hu->kod_h) // проверить, если ещё не записано
  Add1Rec(7)
  human->kod := recno()
  human->TIP_H := yes_vypisan
  ret_kod_h := human->kod
  // запишем ссылку на лист учёта в БД приёмного покоя
  select HU
  G_RLock(forever)
  hu->TIP_H := 1      // 1-human,2-hum_p,3-...
  hu->KOD_H := human->kod // код по БД human
  if hu->IS_GOSPIT == 0 .and. empty(hu->G_DATA) // 0-госпитализирован и не заполнена дата госпитализации
    hu->G_DATA := hu->N_DATA   // дата госпитализации
    hu->G_TIME := hu->N_TIME   // время госпитализации
  endif
else // иначе допишем запись, т.к., скорее всего, она недозаписалась
  fl := .t.
  goto (ret_kod_h)
  if human->kod_k != hu->KOD_K // уже не тот человек
    fl := .f.
  endif
  if fl .and. human_->REESTR > 0 // попал в реестр
    fl := .f.
  endif
  if fl .and. !empty(human->K_DATA) // заполнены даты
    fl := .f.
  endif
  if fl
    select HUMAN
    G_RLock(forever)
  else
    return ret_kod_h
  endif 
endif
select HUMAN_
do while human_->(lastrec()) < human->kod
  APPEND BLANK
enddo
goto (human->kod)
G_RLock(forever)
//
select HUMAN_2
do while human_2->(lastrec()) < human->kod
  APPEND BLANK
enddo
goto (human->kod)
G_RLock(forever)
//
human->kod_k     := hu->KOD_K
human->FIO       := kart->fio       // Ф.И.О. больного
human->POL       := kart->pol       // пол
human->DATE_R    := kart->date_r    // дата рождения больного
human->VZROS_REB := M1VZROS_REB     // 0-взрослый, 1-ребенок, 2-подросток
human->ADRES     := kart->ADRES     // адрес больного
human->RAB_NERAB := kart->RAB_NERAB // 0-работающий, 1 -неработающий
human->MR_DOL    := kart->MR_DOL    // место работы или причина безработности
human->KOMU      := hu->KOMU        // от 0 до 5
human_->SMO      := iif(hu->KOMU==0, kart_->smo, "")
human->STR_CRB   := hu->STR_CRB // код прочей компании, комитета
human->POLIS     := make_polis(kart_->spolis,kart_->npolis) // серия и номер страхового полиса
human->LPU       := hu->lpu           // код учреждения
human->OTD       := hu->OTD           // код отделения
human->UCH_DOC   := hu->UCH_DOC        // вид и номер учетного документа
human->N_DATA    := iif(hu->IS_GOSPIT==0 .and. !empty(hu->G_DATA), hu->G_DATA, hu->N_DATA) // дата начала лечения
human->K_DATA    := iif(hu->IS_GOSPIT==0 .and. !empty(hu->G_DATA), hu->G_DATA, hu->N_DATA) // дата начала лечения
human->bolnich   := hu->bolnich
human->date_b_1  := iif(hu->bolnich==0,"",dtoc4(hu->date_b_1))
human->date_b_2  := iif(hu->bolnich==0,"",dtoc4(hu->date_b_2))
human_->RODIT_DR := iif(hu->bolnich<2,ctod(""),hu->rodit_dr)
human_->RODIT_POL:= iif(hu->bolnich<2,"",hu->rodit_pol)
human_->TRAVMA   := pp_travma_travma(hu->travma)
human_->VPOLIS   := kart_->VPOLIS
human_->SPOLIS   := kart_->SPOLIS
human_->NPOLIS   := kart_->NPOLIS
human_->OKATO    := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
human_->NOVOR    := hu->NOVOR
human_->DATE_R2  := hu->DATE_R2
human_->POL2     := hu->POL2
human_->USL_OK   := lUSL_OK
//human_->idsp     := pp_reg_lech_idsp(hu->reg_lech)
human_->NPR_MO   := hu->KEM_NAPR
human_->FORMA14  := iif(hu->GOSPIT1==1, "1", "0")+;
                    iif(hu->GOSPIT1==1 .and. hu->KEM_DOST==1, "1", "0")+"00"
human->CENA := human->CENA_1 := 0 // стоимость лечения
human_->OPLATA    := 0
human_->ST_VERIFY := 0
human_->ID_PAC    := mo_guid(1,human_->(recno()))
human_->ID_C      := mo_guid(2,human_->(recno()))
human_->SUMP      := 0
human_->SANK_MEK  := 0
human_->SANK_MEE  := 0
human_->SANK_EKMP := 0
human_->REESTR    := 0
human_->REES_ZAP  := 0
human->schet      := 0
human_->SCHET_ZAP := 0
human->kod_p      := hu->kod_p    // код оператора из приёмного покоя
human->date_e     := dtoc4(hu->DATE_VVOD) // дата добавления истории болезни в приёмном покое
//
put_0_human_2()
human_2->P_PER := iif(eq_any(hu->KEM_DOST,1,2),2,1) // {"Поступил самостоятельно",1},{"Доставлен СМП",2},; 
if alltrim(human_->SMO) == "34"
  select KSN
  index on str(kod,7) to (cur_dir+"tmpkismo")
  find (str(human->kod_k,7))
  if found()
    select HSN
    append blank
    hsn->kod := human->kod
    hsn->smo_name := ksn->smo_name
  endif
endif
dbUnLockAll()
return ret_kod_h

***** 30.10.17 записать незаписанные истории болезней из приёмного покоя
FUNCTION write_rest_pp()
Local i, k, arr := {}, bSaveHandler, buf := save_maxrow()
bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
BEGIN SEQUENCE
  if G_Use(dir_server+"mo_ppadd",,"PPA")
    dbeval({|| aadd(arr,{ppa->kod,ppa->(recno())}) },{|| empty(ppa->kod_h) })
    if !empty(arr)
      G_SPlus(f_name_task(X_OMS)) // плюс 1 пользователь зашёл в задачу ОМС
      // если в задаче ОМС не выполняется ОТВЕТСТВЕННАЯ операция
      if !G_SIsLock(sem_vagno_task[X_OMS])
        R_Use(dir_server+"kartote_",,"KART_")
        R_Use(dir_server+"kartotek",,"KART")
        set relation to recno() into KART_
        R_Use(dir_server+"mo_kismo",,"KSN")
        G_Use(dir_server+"mo_hismo",,"HSN")
        Use_base("human")
        use_base("mo_pp")
        WaitStatus("Запись незаписанных историй болезни из ПРИЁМНОГО ПОКОЯ в ОМС")
        Private mdate_r, m1vzros_reb, m1novor
        for i := 1 to len(arr)
          UpdateStatus()
          if (k := f_write_pp_OMS(arr[i,1])) > 0
            select PPA
            goto (arr[i,2])
            if ppa->kod_h != k
              G_RLock(forever)
              ppa->kod_h := k // записать на всякий случай
              UnLock
            endif
            DeleteRec(.t.) // а теперь очистим и пометим на удаление
          endif
          if i % 20 == 0
            Commit
          endif
        next
        close databases
      endif
      G_SMinus(f_name_task(X_OMS))  // минус 1 пользователь (вышел из задачи ОМС)
    endif
  endif
RECOVER USING error
  //
END
ERRORBLOCK(bSaveHandler)
close databases
rest_box(buf)
return NIL

*****
Function pp_getmsg()
Local s_msg := ""
//
if m1uch == 0
  s_msg := "Не введено лечебное учреждение"
elseif m1otd == 0
  s_msg := "Не введено отделение"
elseif !empty(s := pp_ver_data(MN_DATA,"Дата поступления"))
  s_msg := s
elseif !empty(s := pp_ver_data(MG_DATA,"Дата госпитализации"))
  s_msg := s
elseif !empty(s := pp_ver_data(MK_DATA,"Дата окончания лечения"))
  s_msg := s
elseif empty(m1pprab_nerab)
  s_msg := "Не введен социальный статус"
elseif empty(m1vid_opl)
  s_msg := "Не введен вид оплаты"
elseif m1bolnich > 0 .and. mdate_b_1 > mdate_b_2
  s_msg := "Некорректные даты начала и окончания больничного"
elseif m1is_gospit == 1 .and. m1pr_gospit == 0
  s_msg := 'не заполнено поле "Почему не госпитализирован?"'
elseif m1is_gospit == 0
  if M1STOL == 0
    s_msg := 'не заполнено поле "Стол"'
  else
    R_Use(dir_server+"mo_ppst",,"STOL")
    goto (m1stol)
    if M1REG_LECH == 1
      if stol->tip == 1
        s_msg := 'режим лечения "Стационар", а СТОЛ введен для "Дневного стационара"'
      endif
    else
      if stol->tip == 0
        s_msg := 'режим лечения "Дневной стационар", а СТОЛ введен для "стационара"'
      endif
    endif
    Use
  endif
endif
return s_msg

***** замена травмы для БД ОМС
Function pp_travma_travma(ltravma)
Local k := 0
do case
  case ltravma == 1  ; k := 1
  case ltravma == 2  ; k := 4
  case ltravma == 3  ; k := 4
  case ltravma == 4  ; k := 2
  case ltravma == 5  ; k := 5
  case ltravma == 6  ; k := 6
  case ltravma == 7  ; k := 7
  case ltravma == 8  ; k := 8
  case ltravma == 9  ; k := 8
  case ltravma == 10 ; k := 9
  case ltravma == 11 ; k := 10
  case ltravma == 12 ; k := 11
  case ltravma == 13 ; k := 11
endcase
return k

***** замена условия оказания мед.помощи для БД ОМС
Function pp_reg_lech_usl_ok(lreg_lech)
return iif(lreg_lech > 1, 2, 1)

***** замена способа оплаты для БД ОМС
Function pp_reg_lech_idsp(lreg_lech)
Local k := 5
do case
  case k == lreg_lech // стационар круглосуточного пребывания
    k := 5
  case k == lreg_lech // дневной стационар при больнице
    k := 6
  case k == lreg_lech // дневной стационар при поликлинике
    k := 7
  case k == lreg_lech // дневной стационар на дому
    k := 8
endcase
return k

*****
Function pp_ver_data(ldata,s)
Local s1 := ""
if !empty(ldata)
  if ldata > sys_date
    s1 := '"'+s+'" превышает системную дату'
  elseif ldata < sys_date-365*5  // 5 лет назад
    s1 := 'Некорректное значение поля "'+s+'"'
  endif
endif
return s1

*****
Function valid_date_postup()
if mn_data > mg_data .and. m1is_gospit == 0
  mg_data := mn_data
  mg_time := mn_time
  update_gets("mg_data")
  update_gets("mg_time")
endif
return .t.

*****
Function pp_val_k_data(get)
if !empty(mk_data)
  if mn_data > mk_data
    mk_data := get:original
    return func_error(4,"Дата начала лечения больше даты окончания лечения. Ошибка!")
  endif
  if mk_data != get:original
    mk_time := "11:00"
  endif
endif
return .t.

***** 07.11.17
Function pp_valid_gospit(get,old)
if m1is_gospit != old .and. old != NIL
  if m1is_gospit == 0
    m1pr_gospit := 0 ; mpr_gospit := space(35) ; update_get("mpr_gospit")
    if empty(mg_data)
      mg_data := mn_data
      mg_time := mn_time
      update_gets("mg_data")
      update_gets("mg_time")
    endif
  else
    m1gospit0 := 0 ; mgospit0 := padr("",len(menu0gospit[1,1]))
    m1gospit1 := 0 ; mgospit1 := padr("",len(mm_ekst[1,1]))
    m1stol    := 0 ; mstol := space(10)
    mg_data := ctod("")
    mg_time := space(5)
    update_gets()
  endif
endif
return .t.

***** 14.03.16 выбрать карточку пациента из картотеки
Function ppokoj_kart(k)
// k = 1 - начало лечения -> ввод карточки
// k = 2 - возврат кода по картотеке
Static sesc := "^<Esc>^ выход  "
Static senter := "^<Enter>^ ввод  "
Static sF10f := "^<F10>^ поиск по ФИО  "
Static sF10p := "^<F10>^ поиск по полису  "
Static sF10s := "^<F10>^ поиск по СНИЛС  "
Static sF11 := "^<F11>^ читать электронный полис"
Static _err_slock := "В данный момент со стат.картой этого пациента работает другой пользователь."
Static s_regim := 1, s_shablon := "", s_polis := "", s_snils := ""
Local tmp1, mkod := -1, i, fl_number := .t., s, append_or_edit := 0,;
      k1 := 0, k2 := 1, str_sem, mbukva := "", tmp_color, buf, buf24, ar
// обмен информацией с программой Smart Delta Systems
import_kart_from_sds()
/////////////////////////////////////////////////////
Private tmp, name_reader := ""
ar := GetIniVar(tmp_ini,{{"polikl1"  ,"s_regim"  ,"1"},;
                         {"polikl1"  ,"s_shablon","" },;
                         {"polikl1"  ,"s_polis"  ,"" },;
                         {"polikl1"  ,"s_snils"  ,"" },;
                         {"RAB_MESTO","sc_reader","" }} )
if !eq_any(s_regim := int(val(ar[1])),1,2,3)
  s_regim := 1
endif
s_shablon := ar[2]
s_polis   := ar[3]
s_snils   := ar[4]
name_reader := ar[5]
do while .t.
  buf24 := save_maxrow()
  if s_regim == 1
    if empty(s_shablon)
      s_shablon := "*"
    endif
    tmp := padr(s_shablon,20)
    tmp_color := setcolor(color1)
    buf := box_shadow(18,9,20,70)
    @ 19,11 say "Введите шаблон для поиска в картотеке" get tmp pict "@K@!"
    s := sesc+senter+sF10p
    if !empty(name_reader)
      s += sF11
    endif
    status_key(alltrim(s))
  elseif s_regim == 2
    tmp := padr(s_polis,17)
    tmp_color := setcolor(color8)
    buf := box_shadow(18,9,20,70)
    @ 19,13 say "Введите ПОЛИС для поиска в картотеке" get tmp pict "@K@!"
    s := sesc+senter+sF10s
    if !empty(name_reader)
      s += sF11
    endif
    status_key(alltrim(s))
  else
    tmp := padr(s_snils,11)
    tmp_color := setcolor(color14)
    buf := box_shadow(18,9,20,70)
    @ 19,14 say "Введите СНИЛС для поиска в картотеке" get tmp pict "@K"+picture_pf valid val_snils(tmp,1)
    s := sesc+senter+sF10f
    if !empty(name_reader)
      s += sF11
    endif
    status_key(alltrim(s))
  endif
  set key K_F10 TO clear_gets
  if !empty(name_reader)
    set key K_F11 TO clear_gets
  endif
  myread({"confirm"})
  set key K_F11 TO
  set key K_F10 TO
  setcolor(tmp_color)
  rest_box(buf24)
  rest_box(buf)
  if lastkey() == K_F10
    s_regim := iif(++s_regim == 4, 1, s_regim)
  elseif lastkey() == K_F11 .and. !empty(name_reader)
    if mo_read_el_polis(@append_or_edit)
      mkod := glob_kartotek
      exit
    endif
  else
    if lastkey() == K_ESC
      tmp := NIL
    else
      if s_regim == 1
        s_shablon := alltrim(tmp)
      elseif s_regim == 2
        s_polis := tmp
      else
        s_snils := tmp
      endif
    endif
    exit
  endif
enddo
if tmp == NIL
  //
elseif mkod > 0
  str_sem := "ПП - Редактирование человека "+lstr(glob_kartotek)
  if G_SLock(str_sem)
    f_kart_pp(,glob_kartotek)
    G_SUnLock(str_sem)
  else
    func_error(4,_err_slock)
  endif
elseif s_regim == 1
  s_shablon := alltrim(tmp)
  if empty(tmp := alltrim(tmp))
    mkod := 0
    if k == 1  // режим "Добавление"
      f_kart_pp()
    endif
  elseif tmp == "*"
    if oms_view_kart(T_ROW)
      mkod := glob_kartotek
      if k == 1
        str_sem := "ПП - Редактирование человека "+lstr(glob_kartotek)
        if G_SLock(str_sem)
          f_kart_pp(,glob_kartotek)
          G_SUnLock(str_sem)
        else
          func_error(4,_err_slock)
        endif
      endif
    endif
  else
    if is_uchastok == 1
      tmp1 := tmp
      if !(left(tmp,1) $ "0123456789")
        mbukva := left(tmp1,1)
        tmp1 := substr(tmp1,2)  // отбросить первую букву
      endif
      for i := 1 to len(tmp1)
        if !(substr(tmp1,i,1) $ "0123456789/")
          fl_number := .f. ; exit
        endif
      next
      if fl_number
        if (i := at("/",tmp1)) == 0
          fl_number := .f.
        else
          tmp := padl(alltrim(substr(tmp1,1,i-1)),2,"0") + ;
                 padl(alltrim(substr(tmp1,i+1)),5,"0")
        endif
      endif
    else
      for i := 1 to len(tmp)
        if !(substr(tmp,i,1) $ "0123456789")
          fl_number := .f. ; exit
        endif
      next
    endif
    if !fl_number
      if !("*" $ tmp) ; tmp += "*" ; endif
    endif
    if k == 1
      if fvalid_fio(1,tmp,fl_number,mbukva)
        str_sem := "ПП - Редактирование человека "+lstr(glob_kartotek)
        if G_SLock(str_sem)
          f_kart_pp(,glob_kartotek)
          G_SUnLock(str_sem)
        else
          func_error(4,_err_slock)
        endif
      else
        keyboard chr(K_ENTER)  // "нажать" кнопку "Добавление"
      endif
    elseif k == 2
      if fvalid_fio(1,tmp,fl_number,mbukva)
        mkod := glob_kartotek
      else
        fl_bad_shablon := .t.
      endif
    endif
  endif
elseif eq_any(s_regim,2,3)  // поиск по полису/по СНИЛС
  if empty(tmp)
    mkod := 0
    if k == 1  // режим "Добавление" в задаче LPU
      f_kart_pp()
    endif
  elseif k == 1
    if fvalid_fio(s_regim,tmp,fl_number,mbukva)
      str_sem := "ПП - Редактирование человека "+lstr(glob_kartotek)
      if G_SLock(str_sem)
        f_kart_pp(,glob_kartotek)
        G_SUnLock(str_sem)
      else
        func_error(4,_err_slock)
      endif
    else
      keyboard chr(K_ENTER)  // "нажать" кнопку "Добавление"
    endif
  elseif k == 2
    if fvalid_fio(s_regim,tmp,fl_number,mbukva)
      mkod := glob_kartotek
    else
      fl_bad_shablon := .t.
    endif
  endif
endif
SetIniSect(tmp_ini,"polikl1",{{"s_regim"  ,lstr(s_regim)},;
                              {"s_shablon",s_shablon    },;
                              {"s_polis"  ,s_polis      },;
                              {"s_snils"  ,s_snils      }})
return mkod

***** 19.03.18
Function view_human_pp(regim,lkod)
// regim = 1 - редактирование
// regim = 2 - удаление
// regim = 3 - перевод из отделения в отделение
Local buf := savescreen(), i, mkod := 0, k, l_color, t_arr[BR_LEN],;
      fl := .f., mtitul, ind2, arr_blk, fl_schet := .f., str_sem, ;
      fl_ret := .f., tmp_help, fl_perevod, fl_human
DEFAULT lkod TO glob_perso_pp
Private mr1 := T_ROW, pp_regim := regim, blk_open
pr_kod_pp := NIL
blk_open := {|| dbCloseAll(),;
                iif(yes_parol, R_Use(dir_server+"base1",,"BASE1"), nil),;
                R_Use(dir_server+"mo_otd",,"OTD"),;
                R_Use(dir_server+"kartote2",,"KART2"),;
                R_Use(dir_server+"kartote_",,"KART_"),;
                R_Use(dir_server+"kartotek",,"KART"),;
                dbSetRelation( "KART_", {|| recno()}, "recno()" ),;
                R_Use(dir_server+"mo_ppper",dir_server+"mo_ppper","HUP"),;
                R_Use(dir_server+"mo_pp",dir_server+"mo_pp_d","HU"),;
                dbSetRelation( "KART", {|| kod_k}, "kod_k" ),;
                dbGoTop();
            }
eval(blk_open)
if eof()
  func_error(4,"База данных приемного покоя пуста!")
else
  if lkod == 0
    go bottom
  else
    goto (lkod)
  endif
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_STEP_FUNC] := {|| f4_v_human_pp()}
  t_arr[BR_BOTTOM] := maxrow()-5
  t_arr[BR_LEFT]   := 0
  t_arr[BR_RIGHT]  := 79
  t_arr[BR_COLOR]  := color0
  //t_arr[BR_TITUL]  := "Выбор больного"
  //t_arr[BR_TITUL_COLOR] := "BG+/GR"
  t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,"+;
                                       "B/BG,W+/B,"+;
                                       "N+/BG,W/N,"+;
                                       "R/BG,W+/R,"+;
                                       "W+/BG,N/W,"+;
                                       "GR+/R,R/GR*",.f.,60}
  Private nAddrLine := 1 // Номер рассматриваемой адресной строки
  blk := {|| f1_v_human_pp() }
  Private blk_rr := {|| 2 }
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F1>^ - помощь") }
  t_arr[BR_ARR_BLOCK] := {{|| goFirst(@nAddrLine,blk_rr) },;
                          {|| goLast(@nAddrLine,blk_rr) },;
                          {|x| goNext(x,@nAddrLine,blk_rr) },;
                          "",".t.";
                         }
  t_arr[BR_COLUMN] := {}
  aadd(t_arr[BR_COLUMN], { "№ ист.болезни,;время поступл.", ;
                         {|| f3_v_human_pp(1,nAddrLine)}, blk })
  aadd(t_arr[BR_COLUMN], { "Дн/ст", ;
                         {|| f3_v_human_pp(3,nAddrLine)}, {|| iif(hu->REG_LECH > 1, {11,11}, {1,1})} })
  aadd(t_arr[BR_COLUMN], { " Фамилия, имя, отчество больного,; отделение, СМО", ;
                         {|| f3_v_human_pp(2,nAddrLine)}, blk })
  t_arr[BR_EDIT] := {|nk,ob| f2_v_human_pp(nk,ob) }
  t_arr[BR_ENTER] := {|| glob_perso_pp := hu->kod, fl_ret := .t.}
  box_shadow(maxrow()-4,2,maxrow()-2,77,"W/B")
  tmp_help := chm_help_code
  chm_help_code := 202
  edit_browse(t_arr)
  chm_help_code := tmp_help
  restscreen(buf)
  if fl_ret
    if (glob_perso_pp := hu->kod) == 0
      func_error(4,"Не найдено нужных записей!")
    else
      mkod := pr_kod_pp := glob_perso_pp
      glob_kartotek := hu->kod_k
      glob_k_fio := alltrim(kart->fio)
      if eq_any(regim,2,3)
        fl := .t.
        str_sem := "ПП - Редактирование человека "+lstr(glob_kartotek)
        if !G_SLock(str_sem)
          fl := func_error(4,"В данный момент со стат.картой этого пациента работает другой пользователь.")
        endif
        if fl .and. !empty(hu->K_DATA)
          fl := func_error(4,"Данный пациент уже выписан из больницы. Операция запрещена!")
        endif
        if fl .and. regim == 2  // удаление
          if (fl_human := (hu->kod_h > 0))
            R_Use(dir_server+"human",dir_server+"humank","HUMAN")
            find (str(hu->kod_h,7))
            if found() .and. human->cena > 0
              fl := func_error(4,"С данным пациентом уже работали в программе ОМС. Удаление запрещено!")
            endif
            human->(dbCloseArea())
          endif
          select HUP
          find (str(hu->kod,7))
          if ( fl_perevod := found() )
            n_message({"","Данный больной уже переводился из отделения в отделение!"},,;
                      color1,cDataCSay,,,color8)
          endif
          if fl .and. f_Esc_Enter(2,.t.) .and. f_Esc_Enter(2,.t.) // удаление
            mywait()
            mkod := hu->(recno())
            close databases
            // переоткрыть для удаления
            use_base("mo_pp")
            set order to 0
            goto (mkod)
            G_Use(dir_server+"mo_ppadd",,"PPA")
            index on str(kod,7) to (cur_dir+"tmp_ppad")
            find (str(hu->kod,7))
            if found()
              DeleteRec(.t.)
            endif
            G_Use(dir_server+"mo_ppdia",dir_server+"mo_ppdia","HUD")
            do while .t.
              find (str(hu->kod,7))
              if !found() ; exit ; endif
              DeleteRec(.t.)
            enddo
            if fl_perevod
              G_Use(dir_server+"mo_ppper",dir_server+"mo_ppper","HUP")
              do while .t.
                find (str(hu->kod,7))
                if !found() ; exit ; endif
                DeleteRec(.t.)
              enddo
            endif
            if fl_human
              Use_base("human")
              find (str(hu->kod_h,7))
              if found()
                DeleteRec(.t.)
              endif
              human->(dbCloseArea())
            endif
            select HU
            DeleteRec(.t.)
            glob_perso_pp := 0
            write_work_oper(glob_task,OPER_LIST,3)
            stat_msg("Удаление завершено!") ; mybell(2,OK)
          endif
        endif
        G_SUnLock(str_sem)
      endif
    endif
  endif
endif
close databases
restscreen(buf)
if mkod > 0 .and. regim == 1
  str_sem := "ПП - Редактирование человека "+lstr(glob_kartotek)
  if G_SLock(str_sem)
    f_kart_pp(mkod,glob_kartotek)
    G_SUnLock(str_sem)
  else
    return func_error(4,"В данный момент со стат.картой этого пациента работает другой пользователь.")
  endif
endif
return (mkod > 0)

*****
Function f1_v_human_pp()
Local ret := {5,6}
if nAddrLine == 1
  if hu->ishod2 == 6
    ret := {7,8}
  elseif hu->is_gospit == 1 .or. !empty(hu->k_data)
    ret := {3,4}
  else
    ret := {1,2}
    hup->(dbSeek(str(hu->kod,7)))
    if hup->(found())
      ret := {9,10}
    endif
  endif
endif
return ret

*****
Function f3_v_human_pp(k,line)
Local s := "", s1, s2, n2 := 52, lotd, ltime
if k == 1
  if line == 1
    s := padc(alltrim(hu->uch_doc),16)
  else
    s := full_date(hu->n_data)+" "+hu->n_time
  endif
elseif k == 2
  if line == 1
    s := " "+padr(kart->fio,n2)
  else
    s2 := alltrim(f4_view_list_schet(hu->komu,cut_code_smo(kart_->smo),hu->str_crb))
    lotd := hu->otd
    hup->(dbSeek(str(hu->kod,7)))
    if hup->(found())
      lotd := hup->otd ; ltime := dtos(hup->n_data)+n_time
      do while hu->kod == hup->kod
        if ltime < dtos(hup->n_data)+n_time
          lotd := hup->otd ; ltime := dtos(hup->n_data)+n_time
        endif
        hup->(dbSkip())
      enddo
    endif
    otd->(dbGoto(lotd))
    s1 := " "+alltrim(otd->name)
    if len(s1)+len(s2)+1 <= n2
      s := padr(s1,n2-len(s2))+s2
    else
      s := padr(s1+" "+s2,n2)
    endif
  endif
else
  s := space(5)
  if hu->REG_LECH > 1
    s := iif(line == 1, "днев.", "стац.")
  endif
endif
return s

*****
Function f4_v_human_pp()
Local s1 := "", s2 := "", k, tmp_select := select(), lc2 := color8
if yes_parol .and. (k := asc(hu->kod_p)) > 0
  select BASE1
  goto (k)
  s1 := "Оператор: "+crypt(base1->p1,gpasskod)
endif
if !empty(hu->k_data)
  s2 := iif(hu->ishod2==6,"Дата смерти: ","Дата выписки: ")+full_date(hu->k_data)
elseif !empty(hu->date_vvod)
  s2 := "дата ввода: "+full_date(hu->date_vvod)
  lc2 := color14
endif
@ maxrow()-3, 4 say padr(s1,35) color color1
@ maxrow()-3,41 say padl(s2,35) color lc2
select (tmp_select)
return NIL

***** 02.05.18
Function f2_v_human_pp(nkey,oBrow)
// наименования файлов шаблонов
Static sb1 := "<b><u>", sb2 := "</u></b>"
Static stmp2 := "", stmp3 := ""
Local buf := savescreen(), buf1, rec1 := recno(), ret := -1, fl, ch, ;
      arr, ap, i, j, k, s, lfio, sExt, mmo_pr, s1
Local lnomer , l1nomer, muchastok, mdate_r, luchast
if pp_regim == 1 .and. eq_any(nkey,K_F5,K_F6,K_F7,K_F8,K_F9,K_F10,K_F12)
  _pp_nastr(1) // перечитать имена шаблонов
  delFRfiles()
  dbcreate(fr_data,{;
    {"n_data",     "D",  8, 0},;
    {"n_time",     "C",  5, 0},;
    {"g_data",     "D",  8, 0},;
    {"g_time",     "C",  5, 0},;
    {"kod_k",      "N",  7, 0},;
    {"uch_doc",    "C", 10, 0},;
    {"org_name",   "C",255, 0},;
    {"name_uch",   "C", 30, 0},;
    {"name_otd",   "C", 30, 0},;
    {"reg_lech",   "N",  1, 0},;
    {"regim_lu",   "C", 80, 0},;
    {"regim_66",   "C", 80, 0},;
    {"regim_ib",   "C", 80, 0},;
    {"vidpolis",   "C", 12, 0},;
    {"mesto_rog",  "C",100, 0},;
    {"gorod_selo", "C", 20, 0},;
    {"fio",        "C",130, 0},;
    {"fio1",       "C",130, 0},;
    {"polis",      "C", 25, 0},;
    {"beg_polis",  "C", 10, 0},;
    {"srok_polis", "C", 10, 0},;
    {"snils",      "C", 14, 0},;
    {"pol",        "C",  1, 0},;     //ВНИМАНИЕ 50
    {"date_r",     "D",  8, 0},;     //c10
    {"count_ymd",  "C", 90, 0},;
    {"kategor",    "C", 40, 0},;
    {"vid_ud",     "C", 30, 0},;
    {"ser",        "C", 10, 0},;
    {"nom",        "C", 10, 0},;
    {"kogdavyd",   "D",  8, 0},;     //c10
    {"kemvyd",     "C",150, 0},;
    {"adres",      "C",200, 0},;     //120
    {"adresp",     "C",200, 0},;     //120
    {"mr_dol",     "C", 50, 0},;
    {"phone",      "C", 90, 0},;
    {"rab_nerab",  "C", 20, 0},;
    {"vzros_reb",  "C", 20, 0},;
    {"mi_git",     "C", 90, 0},;
    {"rajon_git",  "C", 90, 0},;
    {"mest_inog",  "C", 90, 0},;
    {"rajon_fin",  "C", 90, 0},;
    {"novor",      "C", 90, 0},;
    {"gospit0",    "C", 30, 0},;
    {"gospit1",    "C", 30, 0},;
    {"gospit2",    "C", 30, 0},;
    {"dost_skor",  "C",  3, 0},;
    {"sost_op",    "C", 40, 0},;
    {"kem_dost",   "C",100, 0},;
    {"kem_napr",   "C",150, 0},;
    {"DIAG_NAPR",  "C",100, 0},;
    {"DIAG_PR_P",  "C",100, 0},;
    {"POB_D_LEK",  "C",100, 0},;
    {"HEIGHT",     "C",  7, 0},;
    {"WEIGHT",     "C",  7, 0},;
    {"kol_pred",   "N",  1, 0},;
    {"DATE_ROD",   "D",  8, 0},;
    {"DATE_ROD2",  "D",  8, 0},;
    {"FIO_ROD",    "C", 65, 0},;
    {"FIO_ROD2",   "C", 65, 0},;
    {"uhod_rod",   "C", 50, 0},;
    {"ADRES_ROD",  "C", 50, 0},;
    {"ADRES_ROD2", "C", 50, 0},;
    {"MR_ROD",     "C", 50, 0},;
    {"MR_ROD2",    "C", 50, 0},;
    {"phone_rod",  "C", 90, 0},;
    {"phone_rod2", "C", 90, 0},;
    {"travma",     "C", 90, 0},;
    {"vid_opl",    "C", 60, 0},;
    {"pp_status",  "C", 60, 0},;
    {"pp_kategor", "C", 60, 0},;
    {"vrach",      "C", 60, 0},;
    {"komu1",      "N",  1, 0},;
    {"komu",       "C", 90, 0},;
    {"pr_date",    "D",  8, 0},;
    {"pr_mo",      "C",  6, 0},;
    {"pr_nam_mo",  "C",150, 0},;
    {"pr_kod_tf",  "C", 10, 0},;  // заплатка для шаблона карты
    {"name_org",   "C",255, 0},;
    {"adres_org",  "C",255, 0},;
    {"ogrn",       "C", 15, 0},;
    {"okpo",       "C", 12, 0},;
    {"date_sys",   "C", 10, 0},;
    {"d_sys",      "C",  2, 0},;
    {"m_sys",      "C",  2, 0},;
    {"y_sys",      "C",  4, 0},;
    {"nomer_kart", "C", 25, 0},;
    {"fam",        "C", 50, 0},;
    {"ima",        "C", 50, 0},;
    {"ots",        "C", 50, 0},;
    {"d_dr",       "C",  2, 0},;
    {"m_dr",       "C",  2, 0},;
    {"y_dr",       "C",  4, 0},;
    {"subekt",     "C", 50, 0},;
    {"rajon",      "C", 50, 0},;
    {"gorod",      "C", 50, 0},;
    {"nas_p",      "C", 50, 0},;
    {"subektp",    "C", 50, 0},;
    {"rajonp",     "C", 50, 0},;
    {"gorodp",     "C", 50, 0},;
    {"nas_pp",     "C", 50, 0},;
    {"adresL",     "C",200, 0},; //{"phone",      "C", 15, 0},;
    {"phones",     "C", 50, 0},; //{"gorod_selo", "C", 50, 0},;
    {"ser_polis",  "C", 10, 0},;
    {"nom_polis",  "C", 20, 0},;
    {"smo",        "C",100, 0},;
    {"kod_lgot",   "C",  2, 0},;
    {"name_doc",   "C", 20, 0},;
    {"ser_doc",    "C", 20, 0},;
    {"nom_doc",    "C", 20, 0},;
    {"zanyat",     "C",255, 0},;
    {"invalid",    "C",100, 0},; // пусто  {"mr_dol",     "C", 50, 0},;
    {"perv_priem", "C", 50, 0},; // пусто
    {"registrato", "C", 50, 0},;
    {"time_regi",  "C", 50, 0},; // пусто
    {"adrespL",    "C",200, 0},;
    {"platel",     "C",100, 0},;
    {"platel1",    "C",100, 0},;
    {"bukva",      "C",  1, 0},;
    {"uchast",     "C",  2, 0},;
    {"kod_vu",     "C",  5, 0},;
    {"kod_kart",   "C",  7, 0};
    })

  //
  select KART2
  goto (kart->(recno()))
  //
  use (fr_data) new alias FRD
  append blank
  //
  frd->name_org := frd->org_name
  s1 := full_date(sys_date)
  frd->date_sys := s1
  frd->d_sys := substr(s1,1,2)
  frd->m_sys := substr(s1,4,2)
  frd->y_sys := substr(s1,7,4)
  mdate_r := full_date(kart->date_r)
  frd->d_dr := substr(mdate_r,1,2)
  frd->m_dr := substr(mdate_r,4,2)
  frd->y_dr := substr(mdate_r,7,4)

  //
  lnomer := l1nomer := lstr(kart->kod)
  muchastok := put_val(kart->uchast,2)
  luchast := ""
  if is_uchastok == 1
    if !emptyall(kart->bukva,kart->uchast,kart->kod_vu)
      lnomer := ""
      if !empty(kart->bukva)
        lnomer += kart->bukva
      endif
      lnomer += lstr(kart->uchast,2)
      if kart->kod_vu > 0
        lnomer += "/"+lstr(kart->kod_vu)
      endif
      l1nomer := lnomer
    endif
  elseif eq_any(is_uchastok,2,3)
    if !emptyall(kart->bukva,kart->uchast)
      luchast := " [уч-к "
      if !empty(kart->bukva)
        luchast += kart->bukva
      endif
      luchast += lstr(kart->uchast,2)
      luchast += "] "
    endif
    if is_uchastok == 3
      luchast += alltrim(kart2->kod_AK)
    endif
  endif
  lnomer := expand(lnomer)+luchast
  frd->nomer_kart := lnomer
  arr := retFamImOt(1,.f.)
  frd->fam := arr[1]
  frd->ima := arr[2]
  frd->ots := arr[3]
  arr := ret_okato_Array(kart_->okatop)
  frd->subektp := arr[1]
  frd->rajonp  := arr[2]
  frd->gorodp  := arr[3]
  frd->nas_pp  := arr[4]
  arr := ret_okato_Array(kart_->okatog)
  frd->subekt := arr[1]
  frd->rajon  := arr[2]
  frd->gorod  := arr[3]
  frd->nas_p  := arr[4]
  if f_is_selo()
    frd->gorod_selo := "городская - 1, "+sb1+"сельская - 2"+sb2
  else
    frd->gorod_selo := sb1+"городская - 1"+sb2+", сельская - 2"
  endif
  if empty(kart->adres)
    s := "улица"+space(30)+" дом"+space(5)+" квартира"+space(5)
  else
    s := padr(kart->adres,60)
  endif
  frd->adresL := s //+"   тел. "+frt->phones
  if !emptyall(kart_->PHONE_H,kart_->PHONE_M,kart_->PHONE_W)
    s := ""
    if !empty(kart_->PHONE_M)
      s += "моб."+kart_->PHONE_M+" "
    endif
    if !empty(kart_->PHONE_H)
      s += "дом."+kart_->PHONE_H+" "
    endif
    if !empty(kart_->PHONE_W)
      s += "раб."+kart_->PHONE_W
    endif
//    frd->phone := s
    frd->phones := s
  endif
  if f_is_selo()
    frd->gorod_selo := "городская - 1, "+sb1+"сельская - 2"+sb2
  else
    frd->gorod_selo := sb1+"городская - 1"+sb2+", сельская - 2"
  endif
  frd->ser_polis := kart_->SPOLIS
  frd->nom_polis := kart_->NPOLIS
  frd->polis := ltrim(alltrim(kart_->SPOLIS)+" "+kart_->NPOLIS)
  if alltrim(kart_->SMO) == '34'
    if empty(s := ret_inogSMO_name(1))
      s := "иногородние"
    endif
    frd->smo := "("+alltrim(kart_->KVARTAL_D)+") "+s
  elseif left(kart_->SMO,2) == '34'
    frd->smo := alltrim(inieditspr(A__MENUVERT, glob_arr_smo, int(val(kart_->smo))))
  elseif !empty(kart_->SMO)
    frd->smo := "("+alltrim(kart_->KVARTAL_D)+") "+init_ismo(kart_->SMO)
  endif
  if (i := ascan(stm_kategor, {|x| x[2] == kart_->kategor })) > 0 ;
                                         .and. between(stm_kategor[i,3],1,9)
    frd->kod_lgot := lstr(stm_kategor[i,3])
  endif
  if (j := ascan(menu_vidud, {|x| x[2] == kart_->vid_ud})) > 0
    frd->name_doc := menu_vidud[j,4]
  endif
  frd->ser_doc := kart_->ser_ud
  frd->nom_doc := kart_->nom_ud
  s := iif(kart->rab_nerab==0,sb1,"")+"работает - 1"+iif(kart->rab_nerab==0,sb2,"")+",    "+;
       "проходит военную службу и приравненную к ней службу - 2;    "+;
       iif(kart_->PENSIONER==1,sb1,"")+"пенсионер(ка) - 3"+iif(kart_->PENSIONER==1,sb2,"")+",    "+;
       iif(kart->rab_nerab==2,sb1,"")+"студент(ка) - 4"+iif(kart->rab_nerab==2,sb2,"")+",    "+;
       iif(kart->rab_nerab==1,sb1,"")+"не работает - 5"+iif(kart->rab_nerab==1,sb2,"")+",    "+;
       "прочие - 6"
  frd->zanyat := s
  if emptyall(kart_->okatop,kart_->adresp)
    if empty(kart->adres)
      s := "улица"+space(30)+" дом"+space(5)+" квартира"+space(5)
    else
      s := padr(kart->adres,60)
    endif
  else
    s := padr(kart_->adresp,60)
  endif
  frd->adrespL := s //+"   тел. "+frd->phones
  Private m1company := 0, mcompany := " ", mm_company := {}
  Private m1KOMU := 0, MKOMU, M1STR_CRB := 0
  if kart->MI_GIT == 9
    m1KOMU    := kart->KOMU
    M1STR_CRB := kart->STR_CRB
  endif
  mkomu := inieditspr(A__MENUVERT, mm_komu, m1komu)
  if m1komu == 0
    m1company := int(val(kart_->SMO))
  elseif eq_any(m1komu,1,3)
    m1company := m1str_crb
  endif
  if m1komu == 0 // ОМС
    mm_company := aclone(glob_arr_smo)
  elseif m1komu == 1 // Прочие компании
    R_Use(dir_server+"str_komp")
    index on upper(name) to tmp_comp for !between(tfoms,44,47)
    dbeval({|| aadd(mm_company,{alltrim(name),kod}) } )
    str_komp->(dbCloseArea())
  elseif m1komu == 3 // Комитеты/МО
    R_Use(dir_server+"komitet")
    index on upper(name) to tmp_comp
    dbeval({|| aadd(mm_company,{alltrim(name),kod}) } )
    komitet->(dbCloseArea())
  endif
  mcompany := inieditspr(A__MENUVERT, mm_company, m1company)
  frd->platel  := mkomu
  if m1komu == 0  // ОМС
    frd->platel1 := frd->smo
  else
    frd->platel1 := mcompany
  endif
  frd->bukva    := kart->bukva
  frd->kod_kart := lstr(kart->kod)
  if kart->uchast > 0
    frd->uchast := lstr(kart->uchast)
  endif
  if kart->kod_vu > 0
    frd->kod_vu := lstr(kart->kod_vu)
  endif
  // конец ДОБАВКИ
  //
  frd->UCH_DOC := hu->UCH_DOC
  frd->kod_k := hu->kod_k
  frd->n_data := hu->n_data
  frd->n_time := hu->n_time
  frd->g_data := hu->g_data
  frd->g_time := hu->g_time
  if !empty(hu->travma)
    frd->travma := inieditspr(A__MENUVERT, mmpp_travma, hu->travma)
  endif
  frd->vid_opl    := inieditspr(2, menu_vid_opl, hu->vid_opl)
  frd->pp_status  := inieditspr(2, mmpp_rab,     hu->rab_nerab)
  frd->pp_kategor := inieditspr(1, mmpp_kategor, hu->kategor)
  frd->kem_dost   := inieditspr(1, mmpp_kem_dost, hu->kem_dost)
  frd->sost_op    := inieditspr(1, menu_sost_op, hu->sost_op)
  frd->reg_lech := hu->reg_lech
  do case
    case hu->reg_lech == 1
      frd->regim_lu := "СТАЦИОНАРНОГО БОЛЬНОГО"
      frd->regim_66 := "ВЫБЫВШЕГО ИЗ СТАЦИОНАРА КРУГЛОСУТОЧНОГО ПРЕБЫВАНИЯ"
      frd->regim_ib := "СТАЦИОНАРНОГО БОЛЬНОГО"
    case hu->reg_lech == 2
      frd->regim_lu := "БОЛЬНОГО ДНЕВНОГО СТАЦИОНАРА ПРИ БОЛЬНИЧНОМ УЧРЕЖДЕНИИ"
      frd->regim_66 := "ВЫБЫВШЕГО ИЗ ДНЕВНОГО СТАЦИОНАРА ПРИ БОЛЬНИЧНОМ УЧРЕЖДЕНИИ"
      frd->regim_ib := "БОЛЬНОГО ДНЕВНОГО СТАЦИОНАРА"
    case hu->reg_lech == 3
      frd->regim_lu := "БОЛЬНОГО ДНЕВНОГО СТАЦИОНАРА ПРИ ПОЛИКЛИНИКЕ"
      frd->regim_66 := "ВЫБЫВШЕГО ИЗ ДНЕВНОГО СТАЦИОНАРА ПРИ АМБУЛАТОРНО-ПОЛИКЛИНИЧЕСКОМ УЧРЕЖДЕНИИ"
      frd->regim_ib := "БОЛЬНОГО ДНЕВНОГО СТАЦИОНАРА"
    case hu->reg_lech == 4
      frd->regim_lu := "БОЛЬНОГО СТАЦИОНАРА НА ДОМУ"
      frd->regim_66 := "ВЫБЫВШЕГО ИЗ СТАЦИОНАРА НА ДОМУ"
      frd->regim_ib := "БОЛЬНОГО ДНЕВНОГО СТАЦИОНАРА"
  endcase
  // не госпитализирован и оказана амбулаторная помощь в приёмном покое
  if hu->IS_GOSPIT == 1 .and. hu->PR_GOSPIT == 99
    frd->regim_lu := "АМБУЛАТОРНОГО БОЛЬНОГО"
  endif
  frd->vidpolis := " ("+alltrim(inieditspr(A__MENUVERT,mm_vid_polis,kart_->vpolis))+")"
  frd->mesto_rog := alltrim(kart_->mesto_r)
  frd->gorod_selo := inieditspr(A__MENUVERT, mm_gorod_selo, kart_->gorod_selo)
  frd->fio := upper(kart->fio)
  frd->fio1 := fam_i_o(kart->fio)
  frd->polis := make_polis(kart_->spolis,kart_->npolis)
  frd->beg_polis := full_date(c4tod(kart_->beg_polis))
  frd->srok_polis := full_date(c4tod(kart->srok_polis))
  if !empty(kart->SNILS)
    frd->snils := transform(kart->SNILS,picture_pf)
  endif
  frd->pol := kart->pol
  frd->date_r := kart->date_r
  frd->count_ymd := count_ymd(kart->date_r,hu->N_DATA)
  frd->HEIGHT := iif(empty(kart_->HEIGHT), "_______", lstr(kart_->HEIGHT)+" см")
  frd->WEIGHT := iif(empty(kart_->WEIGHT), "_______", lstr(kart_->WEIGHT)+" кг")
  if empty(stm_kategor2)
    frd->kategor := inieditspr(A__MENUVERT, stm_kategor, kart_->kategor)
  else
    frd->kategor := inieditspr(A__MENUVERT, stm_kategor2, kart_->kategor2)
  endif
  if (j := ascan(menu_vidud, {|x| x[2] == kart_->vid_ud})) > 0
    frd->vid_ud := menu_vidud[j,4]
  endif
  frd->ser := alltrim(kart_->ser_ud)
  frd->nom := alltrim(kart_->nom_ud)
  frd->kogdavyd := kart_->kogdavyd
  R_Use(dir_server+"s_kemvyd",,"KVYD")
  dbGoto(kart_->kemvyd)
  frd->kemvyd  :=  alltrim(kvyd->name)
  kvyd->(dbCloseArea())
  select FRD
  frd->adres := iif(emptyall(kart_->okatog,kart->adres), "",;
                    ret_okato_ulica(kart->adres,kart_->okatog))
  frd->adresp := iif(emptyall(kart_->okatop,kart_->adresp), "",;
                     ret_okato_ulica(kart_->adresp,kart_->okatop))
  frd->mr_dol := kart->mr_dol
  s := ""
  if !emptyall(kart_->PHONE_H,kart_->PHONE_M,kart_->PHONE_W)
    if !empty(kart_->PHONE_H)
      s += alltrim(kart_->PHONE_H)+"(дом.) "
    endif
    if !empty(kart_->PHONE_M)
      s += alltrim(kart_->PHONE_M)+"(моб.) "
    endif
    if !empty(kart_->PHONE_W)
      s += alltrim(kart_->PHONE_W)+"(раб.) "
    endif
  endif
  frd->phone := s
  frd->rab_nerab := upper(inieditspr(A__MENUVERT, menu_rab, kart->rab_nerab))
  frd->vzros_reb := upper(inieditspr(A__MENUVERT, menu_vzros, kart->vzros_reb))
  frd->mi_git    := okato_mi_git(kart_->okatog)
  frd->rajon_git := okato_rajon(kart_->okatog)
  frd->pr_date   := kart2->date_pr
  frd->pr_mo     := kart2->mo_pr
  frd->pr_kod_tf := lstr(kart2->kod_tf)
 // if glob_mo[_MO_IS_UCH]
  mmo_pr := ""
  if left(kart2->PC2,1) == "1"
    mmo_pr := "По информации из ТФОМС пациент У_М_Е_Р"
  elseif kart2->MO_PR == glob_mo[_MO_KOD_TFOMS]
    mmo_pr := "Прикреплён "
    if !empty(kart2->pc4)
      mmo_pr += "с "+alltrim(kart2->pc4)+" "
    elseif !empty(kart2->DATE_PR)
      mmo_pr += "с "+date_8(kart2->DATE_PR)+" "
    endif
    mmo_pr += "к нашей МО"
  else
    s := alltrim(inieditspr(A__MENUVERT,glob_arr_mo,kart2->mo_pr))
    if empty(s)
      mmo_pr := "Прикрепление --- неизвестно ---"
    else
      if !empty(kart2->pc4)
        mmo_pr += "с "+alltrim(kart2->pc4)+" "
      elseif !empty(kart2->DATE_PR)
        mmo_pr += "с "+date_8(kart2->DATE_PR)+" "
      endif
      mmo_pr += "прикреплён к " + s
    endif
  endif
  //endif
  frd->pr_nam_mo := mmo_pr
  if hu->NOVOR > 0
    frd->novor := "(Новорожденный: "+lstr(hu->NOVOR)+"-й ребёнок, д.р. "+;
                  date_8(hu->DATE_R2)+", пол "+hu->POL2+")"
  endif
  frd->gospit0   := inieditspr(A__MENUVERT, menu0gospit, hu->gospit0)
  frd->gospit1   := inieditspr(A__MENUVERT, mm_ekst, hu->GOSPIT1)
  if hu->IS_GOSPIT == 1 //не госпитализирован 02.05.18
    frd->gospit0 := ""
    frd->gospit1 := "НЕТ"
  endif
  //
  frd->gospit2   := inieditspr(A__MENUVERT, menu2gospit, hu->gospit2)
  frd->name_uch := inieditspr(6,dir_server+"mo_uch",hu->LPU)
  frd->name_otd := inieditspr(6,dir_server+"mo_otd",hu->OTD)
  //02.05.18
  //frd->dost_skor := iif(hu->GOSPIT1==1 .and. hu->KEM_DOST==1, "ДА", "НЕТ")
  frd->dost_skor := iif(hu->KEM_DOST==1, "ДА", "НЕТ")
  if !empty(hu->kem_napr)
    arr := ret_mo(hu->kem_napr)
    frd->kem_napr := alltrim(arr[_MO_SHORT_NAME])+" ("+arr[_MO_KOD_TFOMS]+" / "+arr[_MO_KOD_FFOMS]+")"
  endif
  if hu->kod_vr > 0
    R_Use(dir_server+"mo_pers",,"PERSO")
    dbGoto(hu->kod_vr)
    frd->vrach := flstr(perso->tab_nom)+" ("+fam_i_o(perso->fio)+")"
  endif
  R_Use(dir_server+"organiz",,"ORG")
  frd->org_name  := org->name
  frd->adres_org := org->adres
  frd->ogrn      := org->ogrn
  frd->okpo      := org->okpo
  R_Use(dir_server+"mo_ppdia",dir_server+"mo_ppdia","HUS")
  find (str(hu->kod,7))
  do while hus->kod == hu->kod .and. !eof()
    do case
      case hus->tip == 1
        frd->DIAG_NAPR := alltrim(hus->name) // диагноз направившего учреждения
      case hus->tip == 2
        frd->DIAG_PR_P := alltrim(hus->name) // диагноз приемного отделения
      case hus->tip == 3
        frd->POB_D_LEK := alltrim(hus->name) // побочное действие лекарств
    endcase
    skip
  enddo
  R_Use(dir_server+"mo_kpred",dir_server+"mo_kpred","KPR")
  find (str(hu->kod_k,7))
  do while hu->kod_k == kpr->kod .and. !eof()
    if kpr->nn == 1
      ++ frd->kol_pred
      frd->DATE_ROD := kpr->DATE_R
      frd->FIO_ROD := alltrim(kpr->fio)
      if kpr->STATUS > 0
        frd->FIO_ROD := alltrim(kpr->fio)+" ("+alltrim(inieditspr(A__MENUVERT,menu_predst,kpr->STATUS))+")"
      endif
      if kpr->is_uhod == 1
        frd->uhod_rod := "ГОСПИТАЛИЗИРОВАН ("+iif(kpr->is_food==1,"с питанием","без питания")+")"
      endif
      frd->ADRES_ROD := kpr->ADRES
      frd->MR_ROD := kpr->MR_DOL
      s := ""
      if !empty(kpr->PHONE)
        s += "Телефон: "+alltrim(kpr->PHONE)+space(3)
      endif
      if !empty(kpr->PASPORT)
        s += "Паспорт: "+alltrim(kpr->PASPORT)+space(3)
      endif
      if !empty(kpr->POLIS)
        s += "Полис: "+alltrim(kpr->POLIS)+space(3)
      endif
      frd->phone_rod := s
    elseif kpr->nn == 2
      ++ frd->kol_pred
      frd->DATE_ROD2 := kpr->DATE_R
      frd->FIO_ROD2 := alltrim(kpr->fio)
      if kpr->STATUS > 0
        frd->FIO_ROD2 := alltrim(kpr->fio)+" ("+alltrim(inieditspr(A__MENUVERT,menu_predst,kpr->STATUS))+")"
      endif
      frd->ADRES_ROD2 := kpr->ADRES
      frd->MR_ROD2 := kpr->MR_DOL
      s := ""
      if !empty(kpr->PHONE)
        s += "Телефон: "+alltrim(kpr->PHONE)+space(3)
      endif
      if !empty(kpr->PASPORT)
        s += "Паспорт: "+alltrim(kpr->PASPORT)+space(3)
      endif
      if !empty(kpr->POLIS)
        s += "Полис: "+alltrim(kpr->POLIS)+space(3)
      endif
      frd->phone_rod2 := s
    endif
    skip
  enddo
  Private m1komu := hu->komu, mkomu := ""
  if m1komu == 0
    mkomu := "СМО - "
    if alltrim(kart_->SMO) == '34'
      s := ret_inogSMO_name(1)
      mkomu += iif(empty(s), "ТФОМС (иногородние)", s)
      frd->mest_inog := "Регион финансирования: "+inieditspr(A__MENUVERT,glob_array_srf,kart_->KVARTAL_D) // ОКАТО субъекта РФ территории страхования
    elseif left(kart_->SMO,2) == '34'
      mkomu += alltrim(inieditspr(A__MENUVERT, glob_arr_smo, int(val(kart_->smo))))
      //frd->mest_inog := "Регион финансирования: "+'Волгоградская область'
    elseif !empty(kart_->SMO)
      mkomu += init_ismo(kart_->SMO)
      frd->mest_inog := "Регион финансирования: "+inieditspr(A__MENUVERT,glob_array_srf,kart_->KVARTAL_D) // ОКАТО субъекта РФ территории страхования
    endif
  else
    mkomu := ""
    if m1komu == 1
      mkomu := "пр.компания - "
    elseif m1komu == 3
      mkomu := "комитет/МО - "
    endif
    mkomu += f4_view_list_schet(m1komu,"",hu->str_crb)
  endif
  frd->komu := mkomu
  frd->komu1 := m1komu
  //
  fill_FR_ist_bol()
  //
  sExt := iif(memPPdos_fast==0, ".shb", ".fr3")
  arr := {}
  do case
    case nKey == K_F6
      arr := {pp_FILE_6}
    case nKey == K_F7
      arr := {pp_FILE_7}
    case nKey == K_F8
      if hu->IS_GOSPIT == 1 .and. hu->PR_GOSPIT == 99
        func_error(4,"Пациент не госпитализирован. Нет смысла печатать историю болезни.")
      else
        arr := {pp_FILE_8}
      endif
    case nKey == K_F9
      if hu->IS_GOSPIT == 1 .and. hu->PR_GOSPIT == 99
        func_error(4,"Пациент не госпитализирован. Нет смысла печатать стат.карту.")
      else
        arr := {pp_FILE_9}
      endif
    case nKey == K_F5
      arr := {pp_FILE_XX}
    case nKey == K_F10
      if hu->IS_GOSPIT == 1 .and. hu->PR_GOSPIT == 99
        arr := {pp_FILE_7}
      else
        arr := {pp_FILE_7,pp_FILE_8,pp_FILE_9}
      endif
      if !empty(pp_FILE_6)
        Ins_Array(arr,1,pp_FILE_6)
      endif
    case nKey == K_F12
      //frd->pol := iif(kart->pol=="М",sb1+"муж. - 1"+sb2+", жен. - 2","муж. - 1, "+sb1+"жен. - 2"+sb2)
      if !empty(pp_FILE_12)
        Ins_Array(arr,1,pp_FILE_12)
      endif
      // теперь меняем файл данных для сохранения шаблона.
  endcase
  //
  if (k := len(arr)) == 0
    //
  elseif k == 1
    if nKey == K_F5
      Private file_sh
      if !empty(file_sh := menu_shablon(3,3,dir_exe+"*."+alltrim(arr[1]),color8,.f.))
        print_shablon(file_sh)
      endif
    else
      if hb_FileExists(dir_exe+arr[1]+sExt)
        if memPPdos_fast == 0
          print_shablon(arr[1]+sExt)
        else
          close databases
          copy file (cur_dir+fr_data+".dbf") to (cur_dir+fr_titl+".dbf")
          call_fr(arr[1])
        endif
      else
        func_error(4,"Не обнаружен файл "+upper(arr[1]+sExt))
      endif
    endif
  elseif f_Esc_Enter("печати "+lstr(k)+"-х документов")
    if memPPdos_fast == 0 .and. !_upr_windows() // печать не через Windows
      for i := 1 to len(arr)
        if !hb_FileExists(dir_exe+arr[i]+sExt)
          func_error(4,"Не обнаружен файл "+upper(arr[i]+sExt))
          loop
        endif
        if i > 1
          close databases
          use (fr_data) new alias FRD
        endif
        ap := print_shablon(arr[i],,,.f.)  // без отображения
        // для справки: ap := {width,height,regim,_out_file}
        if valtype(ap) == "A"
          ft_use(ap[4])
          pr_view(K_F9,ap[3],,,,.f.)  // без запроса на печать
          ft_use()
        endif
      next
    else // через FastReport
      sExt := ".fr3"
      for i := len(arr) to 1 step -1
        if !hb_FileExists(dir_exe+arr[i]+sExt)
          func_error(4,"Не обнаружен файл "+upper(arr[i]+sExt))
          Del_Array(arr,i)
        endif
      next
      if len(arr) > 0
        close databases
        call_fr(arr)  // несколько отчётов через FastReport
      endif
    endif
  endif
  close databases
  eval(blk_open)
  goto (rec1)
  return -1
endif
if nkey != K_F2
  return -1
endif
buf1 := savescreen(13,4,19,77)
Private pdate, m1date, mdate, tmp2, tmp3
do while .t.
  m1date := 0 ; mdate := space(10)
  tmp2 := padr(stmp2,10)
  tmp3 := padr(stmp3,40)
  box_shadow(13,14,17,67,cDataPgDn,"Поиск по ключу",cDataCSay)
  keyboard chr(K_TAB)+chr(K_TAB)  // встать на ФИО
  status_key("^<Esc>^ - отказ;  ^<PgDn>^ - поиск;  ^<F1>^ - помощь")
  setcolor(cDataCGet)
  @ 14,16 say "Дата поступления" get mdate ;
          reader {|x|menu_reader(x,;
                  {{|k,r,c| k:=year_month(r+1,c),;
                      if(k==nil,nil,(pdate:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION,,,.f.)}
  @ 15,16 say "Номер медицинской карты" get tmp2 picture "@K@!"
  @ 16,16 say "Шаблон ФИО" get tmp3 picture "@K@!"
  myread()
  setcolor(color0)
  if lastkey() == K_ESC .or. emptyall(mdate,tmp2,tmp3)
    exit
  endif
  mywait()
  stmp2 := tmp2
  stmp3 := tmp3 := alltrim(tmp3)
  Private is_date  := (m1date > 0)
  Private is_nomer := !empty(tmp2)
  Private is_fio   := !empty(tmp3)
  if is_fio .and. right(tmp3,1) != "*"
    tmp3 += "*"
  endif
  Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := mr1+3, ;
          k2 := 21, tmp3_ := upper(tmp3)
  i := 0
  if is_fio  // поиск по ФИО
    go top
    do while !eof()
      f1f2_v_human(@i)
      skip
    enddo
  elseif is_date  // поиск по дате начала лечения
    dbseek(dtos(pdate[5]),.t.)
    do while hu->n_data <= pdate[6] .and. !eof()
      f1f2_v_human(@i)
      skip
    enddo
  elseif is_nomer  // поиск по номеру истории болезни
    set index to ((dir_server+"mo_pp_i"))
    k := year(sys_date)
    for j := k-10 to k  // просмотр на 10 лет назад
      find (str(j,4)+tmp2)
      do while year(n_data)==j .and. hu->uch_doc==tmp2
        f1f2_v_human(@i)
        skip
      enddo
    next
    set index to ((dir_server+"mo_pp_d"))
  endif
  if (t_len := len(tmp_kod)) = 0
    stat_msg("Не найдено ни одной записи, удовлетворяющей данному шаблону!")
    mybell(2,ERR)
    restscreen(13,4,19,77,buf1)
    loop
  elseif t_len == 1
    rec1 := glob_perso_pp := tmp_kod[1]
    ret := 0
  else
    box_shadow(mr1,2,22,77)
    SETCOLOR(col_tit_popup)
    skey := mdate
    if !empty(tmp2)
      skey += iif(empty(skey), "", " / ")+alltrim(tmp2)
    endif
    if !empty(tmp3)
      skey += iif(empty(skey), "", " / ")+tmp3
    endif
    @ k1-2,15 say "Ключ: "+alltrim(skey)
    SETCOLOR(color0)
    if k1+t_len+2 < maxrow()-3
      k2 := k1 + t_len + 2
    endif
    @ k1,3 say center(" Количество найденных фамилий - "+lstr(t_len),74)
    i := ascan(tmp_kod, glob_perso_pp)
    status_key("^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор")
    if (i := popup(k1+1,7,k2,72,tmp_mas,i,color0)) > 0
      rec1 := glob_perso_pp := tmp_kod[i]
      ret := 0
    endif
  endif
  exit
enddo
oBrow:gotop()
goto rec1
restscreen(buf)
return ret

*****
Static Function f1f2_v_human(i)
Local fl := .t.
if fl .and. is_date
  fl := between(hu->n_data,pdate[5],pdate[6])
endif
if fl .and. is_nomer
  fl := (tmp2 == hu->uch_doc)
endif
if fl .and. is_fio
  fl := like(tmp3_,upper(kart->fio))
endif
if fl .and. ++i < 4000
  aadd(tmp_mas,full_date(hu->n_data)+" "+hu->n_time+" "+hu->uch_doc+" "+kart->fio)
  aadd(tmp_kod,hu->kod)
endif
return NIL

*****
Static Function fill_FR_ist_bol()
Local sh := 83, i, k, arr[2]
Private sb1 := "<b>", sb2 := "</b>"
dbcreate(fr_data+"9",{;
  {"text1","C",130,0};
 })
use (fr_data+"9") new alias FRD1
//
if !empty(frd->adresp)
  f1_fill_FR_ist_bol('Постоянное место жительства: ',frd->adresp,sh)
endif
if !empty(frd->phone)
  append blank
  frd1->text1 := 'Телефон: '+sb1+alltrim(frd->phone)+sb1
endif
if frd->kol_pred > 0
  append blank
  append blank
  frd1->text1 := 'Сведения о представителях:'
  append blank
  frd1->text1 := 'Ф.И.О. '+sb1+alltrim(frd->FIO_ROD)+sb2+space(20)+'Дата р.: '+sb1+full_date(frd->DATE_ROD)+sb2
  if !empty(frd->uhod_rod)
    append blank
    frd1->text1 := space(12)+sb1+alltrim(frd->uhod_rod)+sb2
  endif
  if !empty(frd->ADRES_ROD)
    append blank
    frd1->text1 := space(12)+'Адрес: '+sb1+alltrim(frd->ADRES_ROD)+sb2
  endif
  if !empty(frd->MR_ROD)
    append blank
    frd1->text1 := space(12)+'Место работы: '+sb1+alltrim(frd->MR_ROD)+sb2
  endif
  if !empty(frd->phone_rod)
    append blank
    frd1->text1 := space(12)+sb1+alltrim(frd->phone_rod)+sb2
  endif
  if frd->kol_pred > 1
    append blank
    frd1->text1 := 'Ф.И.О. '+sb1+alltrim(frd->FIO_ROD2,50)+sb2+space(20)+'Дата р.: '+sb1+full_date(frd->DATE_ROD2)+sb2
    if !empty(frd->ADRES_ROD2)
      append blank
      frd1->text1 := space(12)+'Адрес: '+sb1+alltrim(frd->ADRES_ROD2)+sb2
    endif
    if !empty(frd->MR_ROD2)
      append blank
      frd1->text1 := space(12)+'Место работы: '+sb1+alltrim(frd->MR_ROD2)+sb2
    endif
    if !empty(frd->phone_rod2)
      append blank
      frd1->text1 := space(12)+sb1+alltrim(frd->phone_rod2)+sb2
    endif
  endif
  append blank
endif
return NIL

*****
Static Function f1_fill_FR_ist_bol(s1,s2,sh)
Local i, j, k, arr[2]
k := perenos(arr,s1+alltrim(s2),sh)
j := len(s1)
append blank
frd1->text1 := left(arr[1],j)+sb1+substr(arr[1],j+1)+sb2
if k > 1
  for i := 2 to k
    append blank
    frd1->text1 := sb1+arr[i]+sb2
  next
endif
return NIL
