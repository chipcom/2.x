***** mo_oms.prg - режимы ввода данных для задачи ОМС
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

*****
Function begin_task_oms()
Static n_zapusk := 0
Local i, fl := .t.
if n_zapusk == 0
  ++n_zapusk
  Public arr_opl_7, len_arr_7, mem_oms_pole := 0
endif
if G_SIsLock(sem_vagno_task[X_OMS])
  fl := f_err_sem_vagno_task(X_OMS)
elseif copy_Tools_Ini()
  Tools_Ini_OMS(1,0,0)
  i := GetIniVar(tmp_ini, {{"RAB_MESTO","oms_pole","0"}} )
  if i[1] != NIL
    mem_oms_pole := int(val(i[1]))
  endif
else
  fl := .f.
endif
return fl

** разные функции для oms_sluch()

***** 10.02.17
Function get_fio_kart(k,r,c)
Local s := "", ret, buf, tmp_keys
Private fl_write_kartoteka := .f.
buf := savescreen()
tmp_keys := my_savekey()
edit_kartotek(mkod_k,r+1,,.t.,mkod)
my_restkey(tmp_keys)
if fl_write_kartoteka
  R_Use(dir_server+"kartote2",,"KART2")
  goto (mkod_k)
  R_Use(dir_server+"kartote_",,"KART_")
  goto (mkod_k)
  R_Use(dir_server+"kartotek",,"KART")
  goto (mkod_k)
  M1FIO := 1 ; mfio := kart->fio ; mpol := kart->pol ; mdate_r := kart->date_r
  mfio_kart := _f_fio_kart()
  if type("mn_data") == "D"
    if type("m1novor") == "N" .and. type("mdate_r2") == "D" .and. m1novor > 0
      mvozrast := count_years(mdate_r2,mn_data)
    else
      mvozrast := count_years(mdate_r,mn_data)
    endif
  endif
  if type("m1novor") == "N" .and. m1novor > 0
    M1VZROS_REB := 1 // ребенок
  else
    M1VZROS_REB := kart->VZROS_REB
  endif
  mADRES      := kart->ADRES
  mMR_DOL     := kart->MR_DOL
  m1RAB_NERAB := kart->RAB_NERAB
  m1komu      := kart->komu
  mPOLIS      := kart->POLIS
  m1VIDPOLIS  := kart_->VPOLIS
  mSPOLIS     := kart_->SPOLIS
  mNPOLIS     := kart_->NPOLIS
  msmo        := kart_->SMO
  m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
  mokato      := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
  mkomu       := inieditspr(A__MENUVERT, mm_komu, m1komu)
  mvidpolis   := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  if !empty(mn_data)
    fv_date_r(mn_data,.f.)
  endif
  f_valid_komu(,-1)
  m1company   := int(val(msmo))
  mcompany    := inieditspr(A__MENUVERT, mm_company, m1company)
  if m1company == 34
    mnameismo := ret_inogSMO_name(1,,.t.) // открыть и закрыть
  elseif !(left(msmo,2) == '34')
    m1ismo := msmo ; msmo := '34' ; m1company := 34
    mismo := init_ismo(m1ismo)
  endif
  if m1company == 34
    if !empty(mismo)
      mcompany := mismo
    elseif !empty(mnameismo)
      mcompany := mnameismo
    endif
  endif
  if !empty(mcompany)
    old_name_smo := padr(mcompany,38)
  endif
  if m1komu > 0
    m1company := 0 ; mcompany := ""
    if eq_any(m1komu,1,3)
      m1company := m1str_crb := kart->STR_CRB
      mcompany := inieditspr(A__MENUVERT, mm_company, m1company)
    endif
  endif
  mcompany := padr(mcompany,38)
  if eq_any(is_uchastok,1,3)
    s := amb_kartaN()
  elseif mem_kodkrt == 2
    s := lstr(mkod_k)
  endif
  if !empty(s) .and. valtype(MUCH_DOC) == "C"
    if empty(MUCH_DOC)
      MUCH_DOC := padr(s,10)
    elseif is_uchastok == 3 .and. !(MUCH_DOC == padr(s,10))
      MUCH_DOC := padr(s,10)
    endif
  endif
  close databases
endif
restscreen(buf)
return ret

***** 24.02.16
Function _f_fio_kart()
return padr(alltrim(mfio)+" "+iif(mpol=="М","(муж.)","(жен.)"),50)

***** проверка правильности ввода стоматологического статуса больного
Function f_valid_status_st(get)
Local i, s := "", fl := .t.
for i := 1 to len(mstatus_st)
  if !empty(c := substr(mstatus_st,i,1)) .and. !(c $ yes_d_plus)
    s += c
  endif
next
if !empty(s)
  fl := func_error(4,'Следующие символы не разрешены для ввода в данном поле: "'+s+'"')
endif
return fl

***** действия в ответ на выбор в меню "Новорожденный? (да/нет)"
Function f_valid_novor(get,old)
if m1novor != old .and. old != NIL
  if old == 0 // было "нет" - стало "да"
    mcount_reb := 1 ; mDATE_R2 := sys_date-5 ; mpol2 := "М"
  else
    mcount_reb := 0 ; mDATE_R2 := ctod("") ; mpol2 := " "
  endif
  update_get("mcount_reb")
  update_get("mDATE_R2")
  update_get("mpol2")
endif
fv_date_r(mn_data)
return .t.

***** действия в ответ на выбор в меню "Принадлежность счёта"
Function f_valid_komu(get,old)
Local tmp_select := select()
if m1komu != old .and. old != NIL
  m1company := 0 ; mcompany := space(30) ; mm_company := {}
  if m1komu == 0 // ОМС
    mm_company := aclone(glob_arr_smo)
  elseif m1komu == 1 // Прочие компании
    R_Use(dir_server+"str_komp")
    index on upper(name) to (cur_dir+"tmp_comp") for !between(tfoms,44,47)
    dbeval({|| aadd(mm_company,{alltrim(name),kod}) } )
    Use
  elseif m1komu == 3 // Комитеты/МО
    R_Use(dir_server+"komitet")
    index on upper(name) to (cur_dir+"tmp_comp")
    dbeval({|| aadd(mm_company,{alltrim(name),kod}) } )
    Use
  endif
  if eq_any(m1komu,1,3) .and. empty(mm_company)
    mm_company := {{"Пустой справочник",0}}
  endif
  update_get("mcompany")
endif
select (tmp_select)
return .t.

** 03.09.22 действия в ответ на выбор в меню "Условия оказания медицинской помощи"
Function f_valid_usl_ok(get, old, is_input)
  Local _y, _m, s
  DEFAULT is_input TO .t.

  if m1usl_ok != old .and. m1usl_ok > 0 .and. old != NIL
    mm_rslt := {}
    if m1usl_ok == 3 .and. is_input // поликлиника - убираем диспансеризацию
      aeval(tmp_V009, {|x| iif(x[5] == m1usl_ok .and. x[2] < 316, aadd(mm_rslt, x), nil)})
    else
      aeval(tmp_V009, {|x| iif(x[5] == m1usl_ok, aadd(mm_rslt, x), nil)})
    endif
    mm_ishod := {}
    aeval(tmp_V012, {|x| iif(x[5] == m1usl_ok, aadd(mm_ishod, x), nil) })
    if get != NIL
      m1rslt := 0
      mrslt := ''
      if ascan(mm_rslt, {|x| x[2] == rslt_umolch}) > 0
        m1rslt := rslt_umolch
        mrslt := inieditspr(A__MENUVERT, tmp_V009, m1rslt)
      endif
      m1ishod := 0
      mishod := ''
      if ascan(mm_ishod, {|x| x[2] == ishod_umolch}) > 0
        m1ishod := ishod_umolch
        mishod := inieditspr(A__MENUVERT, tmp_V012, m1ishod)
      endif
      mrslt  := padr(mrslt , 58)
      mishod := padr(mishod, 20)
      update_get('mrslt')
      update_get('mishod')
    endif
  endif
  if is_input .and. type('p_nstr_vnr') == 'N'
    s := ''
    input_vnr := input_vnrm := .f.
    if m1usl_ok == 1 // стационар
      count_ymd(iif(M1NOVOR == 1, mdate_r2, mdate_r), mn_data, @_y, @_m,)
      //if _y == 0 .and. _m < 7 // ребёнок не старше 6 месяцев
      if _y == 0 // ребёнок до года
        s := p_str_vnr
        input_vnr := .t.
      else
        MVNR := space(4)
      endif
      if mpol == 'Ж' .and. _y > 10 // "мамаша" старше 10 лет
        s := p_str_vnrm
        input_vnrm := .t.
      else
        MVNR1 := MVNR2 := MVNR3 := space(4)
      endif
    else // другие условия оказания мед.помощи
      MVNR := MVNR1 := MVNR2 := MVNR3 := space(4)
    endif
    @ p_nstr_vnr, 1 say padr(s, maxcol()) color cDataCGet
    if input_vnr
      update_get('MVNR')
    elseif input_vnrm
      update_get('MVNR1')
      update_get('MVNR2')
      update_get('MVNR3')
    endif
    if !((m1usl_ok == 1 .and. (is_ksg_VMP .or. is_22_VMP .or. is_21_VMP .or. is_12_VMP .or. is_14_VMP)) ;
        .or. (m1usl_ok == 2 .and. is_ds_VMP))
      mvmp := 'нет'
      m1vmp := 0
      MVIDVMP := space(70)
      M1VIDVMP := SPACE(12) // вид ВМП по справочнику V018
      MMETVMP := space(67)
      M1METVMP := 0        // метод ВМП по справочнику V019
      update_get('MVIDVMP')
      update_get('MMETVMP')
    endif
  endif
  return .t.

***** действия в ответ на выбор в меню "Результат"
Function f_valid_rslt(g,o)
if is_death(m1RSLT)
else
endif
return .t.

***** действия в ответ на выбор в меню "Госпитализация"
Function f_valid_f14_ekst(get,old)
// Static Function f_valid_f14_ekst(get,old)
if M1F14_EKST != old .and. old != NIL
endif
return .t.

***** 13.02.22 действия в ответ на выбор в меню "ВМП"
Function f_valid_vmp(get,old)
if m1vmp != old .and. old != NIL
  if m1vmp == 0
    mTAL_NUM := space(20)
    mTAL_D := mTAL_P := ctod("")
    MVIDVMP := space(70) ; M1VIDVMP := SPACE(12) // вид ВМП по справочнику V018
    MMETVMP := space(67) ; M1METVMP := 0        // метод ВМП по справочнику V019
    mmodpac := space(71) ; m1modpac := 0        // модель пациента
  else
    input_ad_cr := .f. ; mad_cr := space(66) ; m1ad_cr := space(10)
  endif
  update_get("mTAL_NUM")
  update_get("mTAL_D")
  update_get("mTAL_P")
  update_get("MVIDVMP")
  update_get("MMETVMP")
  update_get("mmodpac")
endif
return .t.

***** действия в ответ на выбор в меню "Больничный"
Function f_valid_bolnich(get,old)
if m1bolnich != old .and. old != NIL
  if m1bolnich == 0
    MDATE_B_1 := ctod("")
    MDATE_B_2 := ctod("")
  endif
  if m1bolnich != 2
    mrodit_dr  := ctod("")
    mrodit_pol := " "
  endif
  if m1bolnich > 0
    MDATE_B_1 := mn_data
    MDATE_B_2 := mk_data
    if m1bolnich == 2                         // по умолчанию больничный выдали
      mrodit_dr  := addmonth(sys_date,-25*12) // 25 летней
      mrodit_pol := "Ж"                       // матери
    endif
  endif
  update_get("MDATE_B_1")
  update_get("MDATE_B_2")
  update_get("mrodit_dr")
  update_get("mrodit_pol")
endif
return .t.

***** проверка введённого цифрами повода обращения
Function val_st_pov(get)
Local i, fl := .t.
if (i := ascan(stm_povod, {|x| x[2] == m1povod } )) > 0
  mpovod := padr(stm_povod[i,1],23) ; update_get("mpovod")
else
  fl := func_error(4,"Недопустимый шифр повода обращения")
  m1povod := get:original
endif
return fl

***** проверка введённого цифрами вида травмы
Function val_st_trav(get)
Local i, fl := .t.
if (i := ascan(stm_travma, {|x| x[2] == m1travma } )) > 0
  mtravma := padr(stm_travma[i,1],34) ; update_get("mtravma")
else
  fl := func_error(4,"Недопустимый шифр вида травмы")
  m1travma := get:original
endif
return fl

***** 11.08.20
Function inp_dop_diag()
Local arr, jt, mshifr, tmp_keys, tmp_gets, buf, tmp_color
Private mvar := upper(readvar())
if empty(mvar) .or. !(type(mvar) == "C")
  return .t.
endif
mshifr := &mvar
arr := {"MKOD_DIAG" ,;
        "MKOD_DIAG2",;
        "MKOD_DIAG3",;
        "MKOD_DIAG4",;
        "MSOPUT_B1" ,;
        "MSOPUT_B2" ,;
        "MSOPUT_B3" ,;
        "MSOPUT_B4"}
if !empty(mshifr) .and. (jt := ascan(arr,mvar)) > 0
  tmp_keys := my_savekey()
  save gets to tmp_gets
  buf := savescreen()
  change_attr()
  Private pr := 9, m1, m2
  m1 := adiag_talon[jt*2-1]
  m2 := adiag_talon[jt*2  ]
  box_shadow(pr,2,pr+4,77,color0,'Диагноз "'+alltrim(mshifr)+'"',"W+/BG")
  tmp_color := setcolor("N/BG,W+/N,,,B/BG")
  @ pr+1,5 say "Характер заболевания (1,2) " get m1 pict "9" valid {|g| v_i_d_diag(g,1) }
  @ pr+2,5 say "Диспансерный учет  (1,2,3) " get m2 pict "9" valid {|g| v_i_d_diag(g,2) }
  status_key("^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода")
  myread()
  if lastkey() != K_ESC
    adiag_talon[jt*2-1] := m1
    adiag_talon[jt*2  ] := m2
  endif
  keyboard chr(K_ENTER)
  restscreen(buf)
  restore gets from tmp_gets
  my_restkey(tmp_keys)
  setcolor(tmp_color)
  setcursor()
  put_dop_diag()
endif
return .t.

*****
Static Function v_i_d_diag(get,par)
Local fl := .t., mval, s := ""
Private mvar := upper(readvar())
mval := &mvar
if mval > 0
  do case
    case par == 1
      if (fl := between(m1,1,2))
        s := {"Выявлено впервые в жизни (или острое)",;
              "Ранее зарегистрированное заболевание"}[m1]
      endif
    case par == 2
      if (fl := between(m2,1,3))
        s := {"Состоит",;
              "Взят",;
              "Снят"}[m2]
      endif
  endcase
endif
@ pr+par,35 say padr(s,42) color "G+/BG"
if !fl
  &mvar := get:original
  mybell()
endif
return fl

*****
Function func_valid_ismo(get,lkomu,sh,name_var)
Local r1, r2, n := 4, buf, tmp_keys, tmp_list, tmp_color
DEFAULT name_var TO "company"
Private mvar := "m1"+name_var
if lkomu == 0 .and. &mvar == 34
  if get:row() > 18
    r2 := get:row()-1 ; r1 := r2-n
  else
    r1 := get:row()+1 ; r2 := r1+n
  endif
  buf := savescreen()
  change_attr()
  tmp_keys := my_savekey()
  save gets to tmp_list
  Private mm_ismo := {}
  box_shadow(r1,2,r2,77,"N+/W","Ввод иногородней СМО","GR/W")
  tmp_color := setcolor("N/W,W+/N,,,B/W")
  @ r1+1,4 say "Субъект РФ" get mokato ;
            reader {|x| menu_reader(x,;
                  {{|k,r,c| get_srf(k,r,c) },62},A__FUNCTION,,,.f.)} ;
            valid {|g,o| when_ismo(g,o) }
  @ r1+2,4 say "СМО" get mismo ;
           reader {|x|menu_reader(x,mm_ismo,A__MENUVERT,,,.f.)} ;
           when {|| len(mm_ismo) > 0 .and. empty(mnameismo) } ;
           valid {|| iif(empty(mismo),,mnameismo:=space(100)), .t. }
  @ r1+3,4 say "Наименование СМО" get mnameismo pict "@S56" ;
           when empty(m1ismo)
  myread()
  setcolor(tmp_color)
  restore gets from tmp_list
  my_restkey(tmp_keys)
  restscreen(buf)
  if !emptyall(mismo,mnameismo)
    mvar := "m"+name_var
    &mvar := padr(iif(emptyall(mismo),mnameismo,mismo),sh)
  endif
endif
return .t.

*****
Static Function get_srf(k,r,c)
Local ret, t_arr[BR_LEN], fl := .f.
Private muslovie := ".t.", str_find := ""
if r <= maxrow()/2
  t_arr[BR_TOP] := r
  t_arr[BR_BOTTOM] := maxrow()-2
else
  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := r-1
endif
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "Выбор субъекта РФ (территории страхования)"
t_arr[BR_TITUL_COLOR] := "BG+/GR"
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.f.,72}
t_arr[BR_COLUMN] := {{"ОКАТО", {|| tmp->okato }},;
                     { center("Наименование",66),{|| left(tmp->name,66)} }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке") }
t_arr[BR_EDIT] := {|nk,ob| f2_srf(nk,ob) }
t_arr[BR_ENTER] := {|| ret := {tmp->okato,tmp->name} }
//
use (cur_dir+"tmp_srf") new alias TMP
set filter to !(okato=='18000')
if !empty(k)
  Locate for okato==k
  if !found()
    go top
  endif
endif
edit_browse(t_arr)
tmp->(dbCloseArea())
return ret

*****
Static Function f2_srf(nk,ob)
Static stmp1 := ""
Local rec1 := recno(), buf := savescreen(), tmp_color, ret := -1,;
      r1 := pr2-6, r2 := pr2-1, i, j, lf, s, rec
if nk == K_F2
  box_shadow(r1,pc1+1,r2,pc2-1,cDataPgDn,"Поиск по ключу",cDataCSay)
  tmp_color := setcolor(cDataCGet)
  @ r1+2,pc1+2 say center("Введите ключевое слово",pc2-pc1-3)
  setcolor(cDataCGet)
  tmp := padr(stmp1,pc2-pc1-3)
  status_key("^<Esc>^ - отказ от ввода")
  @ r1+3,pc1+2 get tmp picture "@K@!"
  myread()
  setcolor(color0)
  if lastkey() == K_ESC .or. empty(tmp)
    goto (rec1)
  else
    tmp := alltrim(tmp)
    stmp1 := tmp
    Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := pr1+3, k2 := pr2-1
    ob:goTop()
    do while !eof()
      if tmp $ upper(tmp->name)
        aadd(tmp_mas, tmp->name)
        aadd(tmp_kod, recno())
      endif
      skip
    enddo
    if (t_len := len(tmp_kod)) == 0
      func_error(3,"Неудачный поиск!")
      goto (rec1)
    else
      box_shadow(pr1,pc1,pr2,pc2)
      SETCOLOR("B/BG")
      @ pr1+1,pc1+2 say "Ключ: "+tmp
      SETCOLOR(color0)
      if t_len < pr2-pr1-5
        k2 := k1 + t_len + 2
      endif
      @ k1,pc1+1 say padc("Найденное количество - "+lstr(t_len),pc2-pc1-1)
      status_key("^<Esc>^ - отказ от выбора")
      if (i := popup(k1+1,pc1+1,k2,pc2-1,tmp_mas,1,0)) > 0
        ob:goTop()
        goto (tmp_kod[i])
        ret := 0
      endif
    endif
  endif
endif
return ret

*****
Static Function when_ismo(get,old)
Local s
if !(m1okato == old) .and. old != NIL
  m1ismo := "" ; mismo := space(len(mismo))
endif
mm_ismo := {}
if !empty(m1okato)
  R_Use(exe_dir+"_mo_smo",cur_dir+"_mo_smo","SMO")
  find (m1okato)
  do while smo->okato == m1okato .and. !eof()
    s := alltrim(smo->name)
    if !empty(smo->d_end)
      s += " (до "+full_date(smo->d_end)+")"
    endif
    aadd(mm_ismo, {s,smo->smo})
    skip
  enddo
  smo->(dbCloseArea())
endif
return len(mm_ismo) > 0

***** 28.02.18
Function verify_OMS_sluch(mkod)
Local buf := save_maxrow(), fl := .t., name_file := "err_sl"+stxt
mywait()
f_create_diag_srok()
fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("Список обнаруженных ошибок",80))
add_string(center("в листе учёта",80))
add_string("")
//
R_Use(dir_server+"mo_pers",,"PERS")
R_Use(dir_server+"mo_uch",,"UCH")
R_Use(dir_server+"mo_otd",,"OTD")
use_base("lusl")
use_base("luslc")
use_base("luslf")
R_Use(dir_server+"uslugi",,"USL")
G_Use(dir_server+"human_u_",,"HU_")
G_Use(dir_server+"human_u",{dir_server+"human_u",;
                            dir_server+"human_uk",;
                            dir_server+"human_ud",;
                            dir_server+"human_uv",;
                            dir_server+"human_ua"},"HU")
set relation to recno() into HU_, to u_kod into USL
R_Use(dir_server+"mo_su",,"MOSU")
G_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
G_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
G_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","ONKNA") // онконаправления
G_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","ONKSL") // Сведения о случае лечения онкологического заболевания
G_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","ONKDI") // Диагностический блок
G_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","ONKPR") // Сведения об имеющихся противопоказаниях
G_Use(dir_server+"mo_onkus",dir_server+"mo_onkus","ONKUS")
G_Use(dir_server+"mo_onkco",dir_server+"mo_onkco","ONKCO")
G_Use(dir_server+"mo_onkle",dir_server+"mo_onkle","ONKLE")
G_Use(dir_server+"human_2",,"HUMAN_2")
G_Use(dir_server+"human_",,"HUMAN_")
G_Use(dir_server+"human",{dir_server+"humans",;
                          dir_server+"humankk",;
                          dir_server+"humand"},"HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
goto (mkod)
if empty(human->k_data)
  //
elseif year(human->k_data) > 2018
  fl := verify_1_sluch()
else
  fl := verify_1_sluch_18()
endif
if d_srok->(lastrec()) > 0
  am := {"78","80","88","89"}
  if fl
    uch->(dbGoto(human->LPU))
    otd->(dbGoto(human->OTD))
    add_string(alltrim(human->fio)+" "+alltrim(human->kod_diag)+" "+;
               date_8(human->n_data)+"-"+date_8(human->k_data)+;
               iif(d_srok->tip==0, "", " (2."+am[d_srok->tip]+".*)"))
    // add_string(alltrim(uch->name)+'/'+alltrim(otd->name)+'/профиль по "'+;
    //            inieditspr(A__MENUVERT, glob_V002, human_->profil)+'"')
    add_string(alltrim(uch->name) + '/' + alltrim(otd->name) + '/профиль по "' + ;
      inieditspr(A__MENUVERT, getV002(), human_->profil) + '"')
    pers->(dbGoto(human_->VRACH))
    add_string("лечащий врач ["+lstr(pers->tab_nom)+"] "+pers->fio)
  endif
  select HUMAN
  goto (d_srok->kod1)
  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  add_string("")
  add_string(center("Предупреждение!",80))
  add_string("")
  add_string("Обратите внимание, что "+lstr(d_srok->dni)+" дней назад обнаружен случай")
  add_string("с основным диагнозом "+alltrim(human->kod_diag)+" "+;
             date_8(human->n_data)+"-"+date_8(human->k_data)+;
             iif(d_srok->tip1==0, "", " (2."+am[d_srok->tip1]+".*)"))
  // add_string(alltrim(uch->name)+'/'+alltrim(otd->name)+'/профиль по "'+;
  //   inieditspr(A__MENUVERT, glob_V002, human_->profil)+'"')
  add_string(alltrim(uch->name) + '/' + alltrim(otd->name) + '/профиль по "' + ;
             inieditspr(A__MENUVERT, getV002(), human_->profil) + '"')
  pers->(dbGoto(human_->VRACH))
  add_string("лечащий врач ["+lstr(pers->tab_nom)+"] "+pers->fio)
  fl := .f.
endif
close databases
fclose(fp)
rest_box(buf)
if !fl
  viewtext(name_file,,,,.t.,,,5)
endif
return NIL

***** 06.01.22 Добавление листка учета лечения больного
Function oms_add()
  Local buf, str_sem

  change_sys_date() // перечитать системную дату (для травмпунктов, работающих ночами)
  if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. input_otd(T_ROW-1,T_COL+5,sys_date) != NIL
    buf := box_shadow(0,41,2,77,color13)
    @ 1,42 say padc(glob_otd[2],35) color color14
    Private fl_edit_oper, fl_edit_smp, fl_edit_DDS, fl_edit_DVN, fl_edit_DVN_COVID
    do while .t.
      fl_edit_oper := fl_edit_smp := fl_edit_DDS := fl_edit_DVN := fl_edit_DVN_COVID := .f.
      polikl_kart(1)
      if fl_edit_oper
        str_sem := "Редактирование человека "+lstr(glob_perso)
        if G_SLock(str_sem)
          oms_usl_sluch(glob_perso,glob_kartotek,.f.)

          if check_oms_sluch_lek_pr(glob_perso)
            oms_sluch_lek_pr(glob_perso, glob_kartotek, .f.)
          endif

          G_SUnLock(str_sem)
        else
          func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
        endif
      elseif fl_edit_smp .or. fl_edit_DDS .or. fl_edit_DVN .or. fl_edit_DVN_COVID
        // не выходим из цикла
      else
        exit
      endif
    enddo
    if buf != NIL
      rest_box(buf)
    endif
  endif
  return NIL

***** Редактирование листка учета лечения больного
Function oms_edit(k)
Static sk := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"Выбор по учреждению/отделению",;
                "Выбор по отчётному периоду",;
                "Выбор по ошибке из ТФОМС",;
                "Выбор по акту снятия из СМО"}
    mas_msg := {"Редактирование случая с выбором по учреждению/отделению",;
                "Редактирование случая с выбором по отчётному периоду",;
                "Редактирование случая с выбором по конкретной ошибке из ТФОМС",;
                "Редактирование повторно выставленных случаев (после ввода актов снятия из СМО)"}
    mas_fun := {"oms_edit(1)",;
                "oms_edit(2)",;
                "oms_edit(3)",;
                "oms_edit(4)"}
    //set key K_CTRL_F11 to my_extract_reestr()
    // set key K_CTRL_F12 to create_main_base_from_reestrs()
//test_definition_KSG()
    popup_prompt(T_ROW,T_COL+5,sk,mas_pmt,mas_msg,mas_fun)
    // set key K_CTRL_F12 to
    //set key K_CTRL_F11 to
  case k == 1
    f1oms_edit()
  case k == 2
    f2oms_edit()
  case k == 3
    if !find_unfinished_reestr_sp_tk()
      f3oms_edit()
    endif
  case k == 4
    f4oms_edit()
endcase
if k > 0
  sk := k
endif
return NIL

** 20.05.22 Редактирование случая с выбором по учреждению/отделению
Function f1oms_edit()
Static si := 1, sk := 1
Local buf, mas_pmt, arr_m, str_sem, i, buf24, buf_scr, dostup, k := 1,;
      str_error, mtitul, str_find
local lek_pr := .f.

if (arr_m := input_year()) != NIL .and. ;
      input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
          iif(yes_h_otd==1, input_otd(T_ROW-1,T_COL+5,sys_date)!=NIL, .t.)
  if yes_vypisan == B_END
    if (k := popup_prompt(T_ROW,T_COL+5,sk,;
              {"~Не закончившие лечение","~Закончившие лечение"})) > 0
      sk := k
    endif
    if k == 0
      return NIL
    endif
  endif
  dostup := yes_vypisan+k-1
  str_error := "В данный момент"
  mtitul := alltrim(glob_uch[2])
  str_find := str(dostup,1)
  if yes_h_otd == 1
    mtitul += " [ "+alltrim(glob_otd[2])+" ]"
    str_error += " в данном отделении"
    str_find += str(glob_otd[1],3)
  endif
  str_error += " нет пациентов"
  if dostup == B_STANDART
    str_error += ", закончивших лечение"
  else
    str_error += ", не закончивших лечение"
  endif
  if arr_m != NIL
    str_error += " "+arr_m[4]
    mtitul += " "+arr_m[4]
  endif
  buf24 := save_maxrow()
  mywait()
  dbcreate(cur_dir+"tmp_h",{{"kod","N",7,0}})
  use (cur_dir+"tmp_h") new
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humann","HUMAN")
  set relation to recno() into HUMAN_
  find (str_find)
  if yes_h_otd == 1
    if dostup == B_STANDART
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h == dostup .and. otd == glob_otd[1] ;
            for between(k_data,arr_m[5],arr_m[6]) .and. human_->reestr == 0
    else
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h == dostup .and. otd == glob_otd[1] ;
            for between(k_data,arr_m[5],arr_m[6])
    endif
  else
    if dostup == B_STANDART
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h == dostup ;
            for lpu == glob_uch[1] .and. between(k_data,arr_m[5],arr_m[6]) .and. human_->reestr == 0
    else
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h == dostup ;
            for lpu == glob_uch[1] .and. between(k_data,arr_m[5],arr_m[6])
    endif
  endif
  srec := 1
  go top
  do while !eof()
    select TMP_H
    append blank
    replace kod with human->kod
    if human->kod == glob_perso
      srec := tmp_h->(recno())
    endif
    select HUMAN
    skip
  enddo
  i := tmp_h->(lastrec())
  close databases
  rest_box(buf24)
  if i == 0
    func_error(4,str_error)
  else
    Private mr1 := T_ROW, regim_vyb := 2
    do while .t.
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_, to otd into OTD
      use (cur_dir+"tmp_h") new
      set relation to kod into HUMAN
      index on upper(human->fio) to (cur_dir+"tmp_h")
      goto (srec)
      mkod := 0
      buf_scr := savescreen()
      if Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1ret_oms_human",color0,mtitul,'B/BG',,;
                      .t.,,,"f2ret_oms_human",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
        if (glob_perso := tmp_h->kod) == 0
          func_error(4,"Не найдено нужных записей!")
        elseif eq_any(human->ishod,88,89)
          func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
        else
          srec := tmp_h->(recno())
          mkod := glob_perso
          glob_kartotek := human->kod_k
          glob_k_fio := fio_plus_novor()
          glob_otd[1] := human->otd
          glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
          if len(glob_otd) == 2
            aadd(glob_otd,human_->usl_ok)
          else
            glob_otd[3] := human_->usl_ok
          endif
          k := ret_tip_lu()
          if len(glob_otd) == 3
            aadd(glob_otd,k)
          else
            glob_otd[4] := k
          endif
          glob_uch[1] := human->LPU
          glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
          fl_schet := (human->schet > 0)
        endif
      else
        restscreen(buf_scr)
        exit
      endif
      restscreen(buf_scr)
      close databases
      if mkod > 0
        lek_pr := check_oms_sluch_lek_pr(glob_perso)
        if buf != NIL ; rest_box(buf) ; endif
        buf := box_shadow(0,41,3,77,color13)
        @ 1,42 say padc(glob_otd[2],35) color color14
        @ 2,42 say padc(glob_k_fio,35) color color8
        if lek_pr
          mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг", "Использованные ~лекарства"}
        else
          mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг"}
        endif
        if glob_otd[3] == 4 .or. ;
                    (glob_otd[4] > 0 .and. ;
                    glob_otd[4] != TIP_LU_MED_REAB .and. ;
                    glob_otd[4] != TIP_LU_H_DIA .and. ;
                    glob_otd[4] != TIP_LU_P_DIA)
          si := 1
          asize(mas_pmt,1)
          keyboard chr(K_ENTER)
        endif
        do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
          si := i
          str_sem := "Редактирование человека "+lstr(glob_perso)
          if G_SLock(str_sem)
            if i == 1
              oms_sluch(glob_perso,glob_kartotek)
            elseif i == 2
              oms_usl_sluch(glob_perso,glob_kartotek)
            elseif i == 3
              oms_sluch_lek_pr(glob_perso,glob_kartotek)
            endif
            G_SUnLock(str_sem)
          else
            func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
            exit
          endif
        enddo
      endif
    enddo
  endif
  if buf != NIL ; rest_box(buf) ; endif
  close databases
endif
return NIL

** 01.12.22 Редактирование случая с выбором по отчётному периоду
Function f2oms_edit()
Static si := 1
Local buf, str_sem, i, arr_m, mas_pmt, buf24, buf_scr, srec, old_yes_h_otd := yes_h_otd
local lek_pr := .f.

if !myFileDeleted(cur_dir+"tmp_h"+sdbf)
  return NIL
endif
if (arr_m := year_month(T_ROW,T_COL+5,,3)) != NIL
  buf24 := save_maxrow()
  mywait()
  dbcreate(cur_dir+"tmp_h",{{"kod","N",7,0}})
  use (cur_dir+"tmp_h") new
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(arr_m[5]),.t.)
  index on upper(fio) to (cur_dir+"tmp_h2") ;
        while human->k_data <= arr_m[6] ;
        for schet < 1 .and. human_->reestr==0
  srec := 1
  go top
  do while !eof()
    select TMP_H
    append blank
    replace kod with human->kod
    if human->kod == glob_perso
      srec := tmp_h->(recno())
    endif
    select HUMAN
    skip
  enddo
  i := tmp_h->(lastrec())
  close databases
  rest_box(buf24)
  if i == 0
    func_error(4,"В данный момент нет пациентов с датой окончания "+arr_m[4])
  else
    Private mr1 := T_ROW, regim_vyb := 2
    do while .t.
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_, to otd into OTD
      use (cur_dir+"tmp_h") new
      set relation to kod into HUMAN
      index on upper(human->fio) to (cur_dir+"tmp_h")
      goto (srec)
      mkod := 0
      yes_h_otd := 2
      buf_scr := savescreen()
      if Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1ret_oms_human",color0,'По дате окончания лечения "'+arr_m[4]+'"','B/BG',,;
                                     .t.,,,"f2ret_oms_human",,;
                                     {'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
        if (glob_perso := tmp_h->kod) == 0
          func_error(4,"Не найдено нужных записей!")
        elseif eq_any(human->ishod,88,89)
          func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
        else
          srec := tmp_h->(recno())
          mkod := glob_perso
          glob_kartotek := human->kod_k
          glob_k_fio := fio_plus_novor()
          glob_otd[1] := human->otd
          glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
          if len(glob_otd) == 2
            aadd(glob_otd,human_->usl_ok)
          else
            glob_otd[3] := human_->usl_ok
          endif
          k := ret_tip_lu()
          if len(glob_otd) == 3
            aadd(glob_otd,k)
          else
            glob_otd[4] := k
          endif
          glob_uch[1] := human->LPU
          glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
          fl_schet := (human->schet > 0)
        endif
      else
        restscreen(buf_scr)
        exit
      endif
      restscreen(buf_scr)
      close databases
      if mkod > 0
        lek_pr := check_oms_sluch_lek_pr(glob_perso)
        yes_h_otd := old_yes_h_otd
        if buf != NIL ; rest_box(buf) ; endif
        buf := box_shadow(0,41,3,77,color13)
        @ 1,42 say padc(glob_otd[2],35) color color14
        @ 2,42 say padc(glob_k_fio,35) color color8
        if lek_pr
          mas_pmt := {"Редактирование ~карточки", "Редактирование ~услуг", "Использованные ~лекарства"}
        else
          mas_pmt := {"Редактирование ~карточки", "Редактирование ~услуг"}
        endif
        if glob_otd[3] == 4 .or. ;
                (glob_otd[4] > 0 .and. ;
                glob_otd[4] != TIP_LU_MED_REAB .and. ;
                glob_otd[4] != TIP_LU_H_DIA .and. ;
                glob_otd[4] != TIP_LU_P_DIA)
          si := 1
          asize(mas_pmt, 1)
          keyboard chr(K_ENTER)
        endif
        do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
          si := i
          str_sem := "Редактирование человека "+lstr(glob_perso)
          if G_SLock(str_sem)
            if i == 1
              oms_sluch(glob_perso,glob_kartotek)
            elseif i == 2
              oms_usl_sluch(glob_perso,glob_kartotek)
            elseif i == 3
              oms_sluch_lek_pr(glob_perso,glob_kartotek)
            endif
            G_SUnLock(str_sem)
          else
            func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
            exit
          endif
        enddo
      endif
    enddo
  endif
  if buf != NIL ; rest_box(buf) ; endif
  yes_h_otd := old_yes_h_otd
  close databases
endif
return NIL

** 20.05.22 Редактирование повторно выставленных случаев (после ввода актов снятия из СМО)
Function f4oms_edit()
Static si := 1
Local buf, str_sem, i, k, arr_m, arr, old_yes_h_otd := yes_h_otd,;
      iRefr, srec, buf24, buf_scr, mas_pmt
local lek_pr := .f.

if !myFileDeleted(cur_dir+"tmp_h"+sdbf)
  return NIL
endif
if (arr_m := year_month(T_ROW,T_COL+5)) != NIL
  buf24 := save_maxrow()
  mywait()
  dbcreate(cur_dir+"tmp_h",{{"kod","N",7,0}})
  use (cur_dir+"tmp_h") new
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(arr_m[5]),.t.)
  index on upper(fio) to (cur_dir+"tmp_h2") ;
        while human->k_data <= arr_m[6] ;
        for emptyall(human_->reestr,human->schet) .and. human_->kod_up > 0
  go top
  do while !eof()
    select TMP_H
    append blank
    replace kod with human->kod
    select HUMAN
    skip
  enddo
  i := tmp_h->(lastrec())
  close databases
  rest_box(buf24)
  if i == 0
    func_error(4,"Нет повторно выставленных случаев "+arr_m[4])
  else
    Private mr1 := T_ROW, regim_vyb := 2
    srec := 1
    do while .t.
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_, to otd into OTD
      use (cur_dir+"tmp_h") new
      set relation to kod into HUMAN
      index on upper(human->fio) to (cur_dir+"tmp_h")
      goto (srec)
      mkod := 0
      yes_h_otd := 2
      buf_scr := savescreen()
      if Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1ret_oms_human",color0,"Повторно выставленные случаи "+arr_m[4],'B/BG',,;
                                     .t.,,,"f2ret_oms_human",,;
                                     {'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
        if (glob_perso := tmp_h->kod) == 0
          func_error(4,"Не найдено нужных записей!")
        elseif eq_any(human->ishod,88,89)
          func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
        else
          srec := tmp_h->(recno())
          mkod := glob_perso
          glob_kartotek := human->kod_k
          glob_k_fio := fio_plus_novor()
          glob_otd[1] := human->otd
          glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
          if len(glob_otd) == 2
            aadd(glob_otd,human_->usl_ok)
          else
            glob_otd[3] := human_->usl_ok
          endif
          k := ret_tip_lu()
          if len(glob_otd) == 3
            aadd(glob_otd,k)
          else
            glob_otd[4] := k
          endif
          glob_uch[1] := human->LPU
          glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
          fl_schet := (human->schet > 0)
        endif
      else
        restscreen(buf_scr)
        exit
      endif
      restscreen(buf_scr)
      close databases
      if mkod > 0
        lek_pr := check_oms_sluch_lek_pr(glob_perso)
        yes_h_otd := old_yes_h_otd
        if buf != NIL ; rest_box(buf) ; endif
        buf := box_shadow(0,41,3,77,color13)
        @ 1,42 say padc(glob_otd[2],35) color color14
        @ 2,42 say padc(glob_k_fio,35) color color8
        if lek_pr
          mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг", "Использованные ~лекарства"}
        else
          mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг"}
        endif
        if glob_otd[3] == 4 .or. ;
                    (glob_otd[4] > 0 .and. ;
                    glob_otd[4] != TIP_LU_MED_REAB .and. ;
                    glob_otd[4] != TIP_LU_H_DIA .and. ;
                    glob_otd[4] != TIP_LU_P_DIA)
          si := 1
          asize(mas_pmt,1)
          keyboard chr(K_ENTER)
        endif
        do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
          si := i
          str_sem := "Редактирование человека "+lstr(glob_perso)
          if G_SLock(str_sem)
            if i == 1
              oms_sluch(glob_perso,glob_kartotek)
            elseif i == 2
              oms_usl_sluch(glob_perso,glob_kartotek)
            elseif i == 3
              oms_sluch_lek_pr(glob_perso,glob_kartotek)
            endif
            G_SUnLock(str_sem)
          else
            func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
            exit
          endif
        enddo
      endif
    enddo
  endif
  if buf != NIL ; rest_box(buf) ; endif
  yes_h_otd := old_yes_h_otd
  close databases
endif
return NIL

***** 05.02.19 Редактирование листка учета лечения больного + смена отделения
Function oms_smena_otd()
Static si := 1, sk := 1
Local buf, buf1, buf2, str_sem, i, sou, old_otd, fl, fl1, mas_pmt, k := 1
if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
                            input_otd(T_ROW-1,T_COL+5,sys_date) != NIL
  if yes_vypisan == B_END
    if (k := popup_prompt(T_ROW,T_COL+5,sk,;
              {"~Не закончившие лечение","~Закончившие лечение"})) > 0
      sk := k
    endif
  endif
  buf := box_shadow(0,41,2,77,color13)
  @ 1,42 say padc(glob_otd[2],35) color color14
  if k > 0 .and. ret_oms_human(yes_vypisan+k-1)
    rest_box(buf)
    buf := box_shadow(0,41,3,77,color13)
    @ 1,42 say padc(glob_otd[2],35) color color14
    @ 2,42 say padc(glob_k_fio,35) color color8
    sou := glob_otd[2]+" ["+glob_uch[2]+"]" ; old_otd := glob_otd[1]
    buf1 := box_shadow(0,0,3,35,color5)
    @ 1,1 say padc("Теперь выберите",34) color color5
    @ 2,1 say padc("новое отделение",34) color color5
    if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
                          input_otd(T_ROW-1,T_COL+5,sys_date) != NIL
      rest_box(buf1)
      if old_otd == glob_otd[1]
        fl := func_error(4,"Выбрано то же самое отделение!")
      else
        buf2 := savescreen()
        f_message({"Старое отделение:",;
                   sou,;
                   "Новое отделение:",;
                   glob_otd[2]+" ["+glob_uch[2]+"]"},,"W+/W","N/W")
        if (fl := f_Esc_Enter("смены отделения",.t.))
          fl1 := .f.
          if input_value(maxrow()-4,10,maxrow()-2,69,color1,;
              "   Перезаписывать новое отделение в каждой услуге",0,mm_danet) == 1
            fl1 := .t.
          endif
        endif
        restscreen(buf2)
      endif
      if fl
        str_sem := "Редактирование человека "+lstr(glob_perso)
        if G_SLock(str_sem)
          use_base("human")
          set order to 0
          goto (glob_perso)
          k := human->ishod
          G_RLock(forever)
          human->LPU := glob_uch[1] // код учреждения
          human->OTD := glob_otd[1] // код отделения
          if fl1
            Use_base("mo_hu")
            find (str(glob_perso,7))
            do while mohu->kod == glob_perso .and. !eof()
              G_RLock(forever)
              mohu->otd := glob_otd[1] // код отделения
              skip
            enddo
            Use_base("human_u")
            find (str(glob_perso,7))
            do while hu->kod == glob_perso .and. !eof()
              G_RLock(forever)
              hu->otd := glob_otd[1] // код отделения
              skip
            enddo
          endif
          close databases
          func_error(2,"Смена отделения завершена!")
          if eq_any(k,88,89)
            func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
          else
            @ 1,42 say padc(glob_otd[2],35) color color14
            mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг"}
            if glob_otd[3] == 4 .or. ;
                      (glob_otd[4] > 0 .and. ;
                      glob_otd[4] != TIP_LU_MED_REAB .and. ;
                      glob_otd[4] != TIP_LU_H_DIA .and. ;
                      glob_otd[4] != TIP_LU_P_DIA)
              si := 1
              asize(mas_pmt,1)
            endif
            do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
              if (si := i) == 1
                oms_sluch(glob_perso,glob_kartotek)
              else
                oms_usl_sluch(glob_perso,glob_kartotek)
              endif
            enddo
          endif
          G_SUnLock(str_sem)
        else
          func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
        endif
      endif
    endif
    if buf1 != NIL ; rest_box(buf1) ; endif
  endif
  if buf != NIL ; rest_box(buf) ; endif
endif
return NIL

***** 16.03.22 Удаление листка учета лечения больного
Function oms_del()
Static sk := 1
Local buf, str_sem, j, k := 1, arr_m, fl := .t., lkod_k, lyear

if ! hb_user_curUser:IsAdmin()
  return func_error(4,err_admin)
endif
if (arr_m := input_year()) != NIL .and. ;
     input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
          iif(yes_h_otd==1, input_otd(T_ROW-1,T_COL+5,sys_date)!=NIL, .t.)
  if yes_vypisan == B_END
    if (k := popup_prompt(T_ROW,T_COL+5,sk,;
              {"~Не закончившие лечение","~Закончившие лечение"})) > 0
      sk := k
    endif
  endif
  if yes_h_otd == 1
    buf := box_shadow(0,41,2,77,color13)
    @ 1,42 say padc(glob_otd[2],35) color color14
  endif
  if k > 0 .and. ret_oms_human(yes_vypisan+k-1,arr_m) .and. f_Esc_Enter(2,.t.)
    str_sem := "Редактирование человека "+lstr(glob_perso)
    if G_SLock(str_sem)
      G_Use(dir_server+"mo_pp",dir_server+"mo_pp_h","PP")
      use_base("mo_hdisp")
      Use_base("mo_hu")
      Use_base("human_u")
      Use_base("human")
      find (str(glob_perso,7))
      if fl .and. eq_any(human->ishod,88,89)
        fl := func_error(10,"Данный случай - часть двойного случая. Удаление запрещено!")
      endif
      if fl .and. human_->KOD_UP > 0
        fl := func_error(10,"Данный случай выставлен повторно (по акту снятия). Удаление запрещено!")
      endif
      if fl .and. human->ishod == 201 // диспансеризация I этап
        lkod_k := human->kod_k
        lyear := year(human->k_data)
        set order to 2
        find (str(lkod_k,7))
        do while human->kod_k == lkod_k .and. !eof()
          if human->ishod == 202 .and. year(human->k_data) == lyear
            fl := func_error(10,"Это I этап диспансеризации, но присутствует II этап. Удаление запрещено!")
            exit
          endif
          skip
        enddo
        set order to 1
        find (str(glob_perso,7))
      endif
      if fl
        flag_pp := .f.
        select PP // приемный покой
        find (str(glob_perso,7))
        if found() .and. human->kod_k == pp->kod_k // тот же пациент
          G_RLock(forever)
          pp->K_DATA := ctod("")  // дата окончания лечения
          pp->K_TIME := ""        // время выписки
          flag_pp := .t.
        endif
        j := 0
        do while .t.
          select HDISP
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        do while .t.
          select MOHU
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.,.f.)  // без пометки на удаление
          ++j
        enddo
        do while .t.
          select HU
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          //
          select HU_
          DeleteRec(.t.,.f.)
          select HU
          DeleteRec(.t.,.f.)  // без пометки на удаление
          ++j
        enddo
        select HUMAN_2
        DeleteRec(.t.,.f.)
        select HUMAN_
        DeleteRec(.t.,.f.)
        select HUMAN
        DeleteRec(.t.,.f.)  // без пометки на удаление
        G_RLock(forever)
        replace human->schet with -1  // (вместо нуля)
        // удаляем онкологию
        G_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","NAPR") // онконаправления
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","SL")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","DI")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","PR")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkus",dir_server+"mo_onkus","US")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkco",dir_server+"mo_onkco","CO")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkle",dir_server+"mo_onkle","LE")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo

        // удаление имплантантов
        delete_implantants(glob_perso)

        // удаление лекарственных препаратов
        G_Use(dir_server + "human_lek_pr", dir_server + "human_lek_pr", "LEK")
        do while .t.
          find (str(glob_perso, 7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo


        close databases
        write_work_oper(glob_task,OPER_USL,3,j)
        write_work_oper(glob_task,OPER_LIST,3)
        stat_msg("Лист учёта удалён.") ; mybell(2,OK)
        if flag_pp
          stat_msg("Не забудьте удалить историю болезни в подзадаче ПРИЁМНЫЙ ПОКОЙ") ; mybell(10,OK)
        endif
      else
        close databases
      endif
      G_SUnLock(str_sem)
    else
      func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
    endif
  endif
  if buf != NIL ; rest_box(buf) ; endif
endif
return NIL

***** Режимы работы с завершением лечения
Function oms_zav_lech(k)
Static sk := 1, str_sem := "Завершение лечения"
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"Завершение лечения для ~одного больного",;
                "Завершение лечения для ~всех",;
                "~Убрать у больного отметку о завершении лечения"}
    mas_msg := {"Завершение лечения для одного больного",;
                "Завершение лечения для всех",;
                "Убрать у больного отметку о завершении лечения"}
    mas_fun := {"oms_zav_lech(1)",;
                "oms_zav_lech(2)",;
                "oms_zav_lech(3)"}
    if G_SLock(str_sem)
      popup_prompt(T_ROW-len(mas_pmt)-3,T_COL+5,sk,mas_pmt,mas_msg,mas_fun)
      G_SUnLock(str_sem)
    else
      func_error(4,err_slock)
    endif
  case k == 1
    f1oms_zav_lech(1)
  case k == 2
    f1oms_zav_lech(2)
  case k == 3
    f1oms_zav_lech(3)
endcase
if k > 0
  sk := k
endif
return NIL

*****
Function f1oms_zav_lech(k)
Local buf, str_sem, k1, k2, tmp_color, dbf_tmp, r := 8, mtitul
if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
          iif(yes_h_otd==1, input_otd(T_ROW-1,T_COL+5,sys_date)!=NIL, .t.)
  if k == 1 .or. k == 3  // один человек из отделения
    if ret_oms_human(iif(k==1,B_END,B_STANDART))
      str_sem := "Редактирование человека "+lstr(glob_perso)
      if !G_SLock(str_sem)
        return func_error(4,err_slock)
      endif
      tmp_color := setcolor(color1) ; buf := savescreen()
      box_shadow(r,10,r+7,69,color1,;
             if(k==1,"Завершение лечения",;
                     "Убираем отметку о завершении лечения"),"W/B")
      Use_base("human")
      goto (glob_perso)
      @ r+2,12 say "Ф.И.О. "
      @ row(),col() say human->fio color cDataCSay
      @ r+3,12 say "Дата начала лечения "
      @ row(),col() say full_date(human->n_data) color cDataCSay
      @ r+4,12 say "Дата окончания лечения "
      @ row(),col() say full_date(human->k_data) color cDataCSay
      @ r+5,12 say "Сумма лечения "
      @ row(),col() say lstr(human->cena_1,12,2) color cDataCSay
      if f_Esc_Enter(1) .and. G_RLock(forever)
        human->TIP_H := if(k == 3, B_END, B_STANDART)
        stat_msg(if(k == 1, "Лечение завершено", "Убрана отметка о завершении лечения")+"!")
        mybell(0.5,OK)
      endif
      close databases
      G_SUnLock(str_sem)
      restscreen(buf)
      setcolor(tmp_color)
    endif
  elseif k == 2  // целое отделение/учреждение
    dbf_tmp := {;
       {"KOD"      ,   "N",     7,     0},;
       {"N_DATA"   ,   "D",     8,     0},; // дата начала лечения
       {"K_DATA"   ,   "D",     8,     0},; // дата окончания лечения
       {"FIO"      ,   "C",    50,     0},; // Ф.И.О. больного
       {"CENA"     ,   "N",    12,     2},; // стоимость лечения
       {"PLUS"     ,   "L",     1,     0}}  // включается ли в счет
    buf := save_maxrow()
    mywait()
    dbcreate(cur_dir+"tmp",dbf_tmp)
    k1 := k2 := 0
    Use (cur_dir+"tmp") alias TMP
    R_Use(dir_server+"human",dir_server+"humann","HUMAN")
    find (str(B_END,1))
    do while human->tip_h == B_END .and. !eof()
      if iif(yes_h_otd==1, human->otd == glob_otd[1], .t.)
        k1++
        select TMP
        append blank
        replace tmp->KOD    with human->KOD ,;
                tmp->n_data with human->n_data,;
                tmp->k_data with human->k_data,;
                tmp->FIO    with human->FIO ,;
                tmp->CENA   with human->CENA_1,;
                tmp->PLUS   with .t.
        if k1 == 9999
          exit
        endif
      endif
      select HUMAN
      skip
    enddo
    close databases
    rest_box(buf)
    if k1 == 0
      func_error(4,"Нет больных, не закончивших лечение!")
    else
      buf := savescreen()
      Private old_summa := ob_summa := 0, old_kol := ob_kol := k1, regim_t := 3
      Private p_blk := {|mkol,msum| .t. }
      mtitul := alltrim(glob_uch[2])
      if yes_h_otd == 1
        mtitul += " [ "+alltrim(glob_otd[2])+" ]"
      endif
      Use (cur_dir+"tmp") alias TMP
      index on upper(fio) to (cur_dir+"tmp_hum")
      if Alpha_Browse(T_ROW,0,maxrow()-4,79,"f2oms_zav_lech",color1,;
                      mtitul,"G+/B",.t.,.t.,,,"f3oms_zav_lech",,;
                      {'═','░','═',"W+/B,BG+/R,GR+/B,GR+/R",,300} )
        if ob_kol > 0 .and. f_Esc_Enter("завершения лечения") .and. Use_base("human")
          mywait()
          select TMP
          go top
          do while !eof()
            if tmp->plus
              str_sem := "Редактирование человека "+lstr(tmp->kod)
              if G_SLock(str_sem) // если человек не заблокирован
                select HUMAN
                find (str(tmp->kod,7))
                if found() .and. G_RLock(forever)
                  human->TIP_H := B_STANDART
                  UnLock
                endif
                G_SUnLock(str_sem)
              else
                k2++
              endif
            endif
            select TMP
            skip
          enddo
          close databases
          stat_msg("Лечение завершено!" + if(k2 == 0, "", ;
                               " ("+lstr(k2)+" чел. были заблокированы)") )
          mybell(0.5,OK)
        endif
      endif
      restscreen(buf)
    endif
  endif
endif
close databases
return NIL

*****
Function f2oms_zav_lech(oBrow)
Local oColumn, tmp_color, blk_color := {|| if(tmp->plus, {3,4}, {1,2}) }, s1, s2, s3, n := 46
oColumn := TBColumnNew(" ", {|| if(tmp->plus," ","  ") })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(center("Ф.И.О. больного",n), {|| padr(tmp->fio,n) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Окончан.;лечения", {|| tmp->k_data })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("    Сумма", {|| padl(expand_value(tmp->cena,2),14) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" ", {|| if(tmp->plus," ","  ") })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
tmp_color := setcolor("N/W")
s1 := "завершения лечения"
s2 := "все завершили лечение"
s3 := "все не завершили лечение"
@ maxrow()-3,0 say padr(" <Esc> - выход без изменений;    <Enter> - подтверждение "+s1,80)
@ maxrow()-2,0 say padr(" <Ins> - отметить одного больного или снять отметку с одного больного",80)
@ maxrow()-1,0 say padr(" <+> - отметить всех больных (все завершили лечение)    <F8> - удаление по дате",80)
@ maxrow()-0,0 say padr(" <-> - снять отметку со всех больных (все не завершили лечение)   <F9> - печать",80)
mark_keys({s1},"R/W")
mark_keys({"<Esc>","<Enter>","<Ins>","<+>","<->","<F8>","<F9>"},"B/W")
setcolor(tmp_color)
return NIL

*****
Function f3oms_zav_lech(nKey,oBrow)
Local buf, rec, k := -1, sh, HH, n_file, s, mdate, j
do case
  case nkey == K_F8
    mdate := input_value(21,1,23,78,"W+/N,N/W",;
          space(7)+"Введите дату, ранее которой не завершено лечение",;
           sys_date-30)
    if mdate != NIL .and. f_Esc_Enter("удаления") .and. ;
       f_alert({'После подтверждения данного режима будут удалены',;
                "все листки учета с незавершенным лечением, у которых",;
                "проставлена дата ранее "+date_month(mdate,.t.),;
                "Выберите действие"},;
               {" ~Отказ "," Подтвердить ~удаление "},;
               1,"N+/BG","R/BG",16,,col1menu ) == 2
      buf := save_maxrow()
      mywait()
      j := 0
      Use_base("mo_hu")
      Use_base("human_u")
      Use_base("human")
      select TMP
      go top
      do while !eof()
        if tmp->k_data <= mdate
          ++j
          do while .t.
            select HU
            find (str(tmp->kod,7))
            if !found() ; exit ; endif
            //
            select HU_
            DeleteRec(.t.,.f.)
            select HU
            DeleteRec(.t.,.f.)  // без пометки на удаление
          enddo
          do while .t.
            select MOHU
            find (str(tmp->kod,7))
            if !found() ; exit ; endif
            DeleteRec(.t.,.f.)  // без пометки на удаление
          enddo
          select HUMAN
          goto (tmp->kod)
          select HUMAN_
          DeleteRec(.t.,.f.)
          select HUMAN
          DeleteRec(.t.,.f.)  // без пометки на удаление
          G_RLock(forever)
          replace human->schet with -1  // (вместо нуля)
          UnLock
        endif
        select TMP
        skip
      enddo
      close databases
      stat_msg("Всего удалено листов учета - "+lstr(j)) ; mybell(2,OK)
      Use (cur_dir+"tmp") alias TMP
      rest_box(buf)
      k := 0
      keyboard chr(K_ESC)
    endif
  case nkey == K_F9
    mdate := input_value(21,1,23,78,color1,;
          space(7)+"Введите дату, ранее которой не завершено лечение",;
           sys_date-10)
    if mdate != NIL .and. f_Esc_Enter("печати")
      buf := save_maxrow()
      mywait()
      rec := recno()
      R_Use(dir_server+"human_u",dir_server+"human_u","HU")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"uslugi",,"USL")
      R_Use(dir_server+"mo_pers",,"PERSO")
      arr_title := {;
       "────────────────────────────────────────────────┬────────────────┬──────────────",;
       "               Ф.И.О.                           │ Сроки лечения  │    Сумма     ",;
       "────────────────────────────────────────────────┴────────────────┴──────────────"}
      n_file := "z_lech"+stxt ; sh := 80 ; HH := 57
      fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
      add_string("")
      add_string(center("Больные, не завершившие лечение",sh))
      add_string(center("до "+date_month(mdate,.t.),sh))
      add_string("")
      aeval(arr_title, {|x| add_string(x) } )
      select TMP
      go top
      do while !eof()
        if tmp->k_data <= mdate
          if verify_FF(HH, .t., sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(padr(tmp->fio,49)+;
                     left(dtoc(tmp->n_data),5)+'-'+dtoc(tmp->k_data)+;
                     put_kopE(tmp->cena,13))
          select HUMAN_
          goto (tmp->kod)
          if !eof() .and. human_->vrach > 0
            select PERSO
            goto (human_->vrach)
            if !eof()
              s := space(10)+"Леч.врач: ["+lstr(perso->tab_nom)
              add_string(s+"]  "+alltrim(perso->fio))
            endif
          endif
          arr_usl := {}
          select HU
          find (str(tmp->kod,7))
          do while hu->kod == tmp->kod
            usl->(dbGoto(hu->u_kod))
            if ascan(arr_usl,usl->shifr) == 0
              aadd(arr_usl,usl->shifr)
            endif
            select HU
            skip
          enddo
          if len(arr_usl) > 0
            asort(arr_usl,,,{|x,y| fsort_usl(x) < fsort_usl(y) } )
            s := "Услуги: "
            for j := 1 to len(arr_usl)
              s += alltrim(arr_usl[j])
              if j < len(arr_usl)
                s += ", "
              endif
            next
            for j := 1 to perenos(arr_usl,s,sh-10)
              add_string(space(10)+arr_usl[j])
            next
          endif
        endif
        select TMP
        skip
      enddo
      hu->(dbCloseArea())
      usl->(dbCloseArea())
      human_->(dbCloseArea())
      perso->(dbCloseArea())
      select TMP
      goto (rec)
      fclose(fp)
      rest_box(buf)
      viewtext(n_file,,,,,,,2)
    endif
  case nkey == K_INS
    replace tmp->plus with !tmp->plus
    if tmp->plus
      ob_summa += tmp->cena ; ob_kol++
    else
      ob_summa -= tmp->cena ; ob_kol--
    endif
    eval(p_blk,ob_kol,ob_summa)
    k := 0
    keyboard chr(K_TAB)
  case nkey == 43 .or. nkey == 45  // + или -
    fl := (nkey == 43)
    rec := recno()
    buf := save_maxrow()
    mywait()
    tmp->(dbeval({|| tmp->plus := fl}))
    goto (rec)
    rest_box(buf)
    if fl
      ob_summa := old_summa ; ob_kol := tmp->(lastrec())
    else
      ob_summa := ob_kol := 0
    endif
    eval(p_blk,ob_kol,ob_summa)
    k := 0
endcase
return k

** 20.05.22 поиск больного
Function ret_oms_human(dostup,arr_m)
//  dostup = B_END      = 2 - больные выписались из данного отделения
//  dostup = B_STANDART = 3 - проверен стандарт лечения и не включен в реестр
//  dostup = B_SCHET    = 4 - выписан счет
//  dostup = B_OPL      = 5 - оплачен счет
//  dostup = B_NE_OPL   = 6 - больной по какой-то причине не оплачивается
Local buf := savescreen(), mkod := 0, k, fl := .f., mtitul := ""
mywait()
Private mr1 := T_ROW, str_find, regim_vyb := 1
str_error := "В данный момент"
if dostup == NIL
  str_find := dtos(arr_m[5])
  mtitul := 'По дате окончания лечения "'+arr_m[4]+'"'
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_, to otd into OTD
  dbseek(str_find,.t.)
  index on upper(fio) to (cur_dir+"tmp_hum") ;
        while human->k_data <= arr_m[6] ;
        for schet < 1 .and. human_->reestr==0
  str_error += " нет пациентов с датой окончания "+arr_m[4]
else
  mtitul := alltrim(glob_uch[2])
  str_find := str(dostup,1)
  if yes_h_otd == 1
    mtitul += " [ "+alltrim(glob_otd[2])+" ]"
    str_error += " в данном отделении"
    str_find += str(glob_otd[1],3)
  endif
  str_error += " нет пациентов"
  if dostup == B_STANDART
    str_error += ", закончивших лечение"
  else
    str_error += ", не закончивших лечение"
  endif
  if arr_m != NIL
    str_error += " "+arr_m[4]
    mtitul += " "+arr_m[4]
  endif
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humann","HUMAN")
  set relation to recno() into HUMAN_, to otd into OTD
  find (str_find)
  if yes_h_otd == 1
    if dostup == B_STANDART
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h==dostup .and. otd==glob_otd[1] ;
            for iif(arr_m==NIL, .t., between(k_data,arr_m[5],arr_m[6])) .and. human_->reestr==0
    else
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h==dostup .and. otd==glob_otd[1] ;
            for iif(arr_m==NIL, .t., between(k_data,arr_m[5],arr_m[6]))
    endif
  else
    if dostup == B_STANDART
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h==dostup ;
            for lpu==glob_uch[1] .and. iif(arr_m==NIL, .t., between(k_data,arr_m[5],arr_m[6])) ;
                                 .and. human_->reestr==0

    else
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h==dostup ;
            for lpu==glob_uch[1] .and. iif(arr_m==NIL, .t., between(k_data,arr_m[5],arr_m[6]))
    endif
  endif
endif
go top
if eof()
  close databases
  restscreen(buf)
  str_error += "!"
  return func_error(4,str_error)
endif
if glob_perso > 0
  Locate for human->kod == glob_perso
  if !found()
    go top
  endif
endif
if Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1ret_oms_human",color0,mtitul,'B/BG',,;
                               .t.,,,"f2ret_oms_human",,;
                               {'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
  if (glob_perso := human->kod) == 0
    func_error(4,"Не найдено нужных записей!")
  else
    mkod := glob_perso
    glob_kartotek := human->kod_k
    glob_k_fio := fio_plus_novor()
    glob_otd[1] := human->otd
    glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
    if len(glob_otd) == 2
      aadd(glob_otd,human_->usl_ok)
    else
      glob_otd[3] := human_->usl_ok
    endif
    k := ret_tip_lu()
    if len(glob_otd) == 3
      aadd(glob_otd,k)
    else
      glob_otd[4] := k
    endif
    glob_uch[1] := human->LPU
    glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
    fl_schet := (human->schet > 0)
  endif
  close databases
endif
close databases
restscreen(buf)
return (mkod > 0)

***** 28.12.21
Function f1ret_oms_human(oBrow)
Local oColumn, blk, r := 34
blk := {|| iif(human_->KOD_UP > 0, {3,4}, iif(human_->OPLATA == 2, {5,6},{1,2})) }
if yes_h_otd == 1
  r += 6
endif
oColumn := TBColumnNew(padc("ФИО пациента",r),{|| padr(fio_plus_novor(),r)})
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if yes_h_otd == 2
  oColumn := TBColumnNew("Отд-е", {|| otd->short_name })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew("Осн.;диаг.", {|| human->kod_diag })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Нача-; ло", {|| left(dtoc(human->n_data),5) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Оконч-ие;лечения", {|| date_8(human->k_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Стоимость;  лечения", {|| put_kopE(human->cena_1,10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if hb_user_curUser:IsAdmin()
  s := "^<Esc>^ выход  ^<Enter>^ выбор  ^<F2>^ поиск"
  if type("p_del_error") == "A" .and. p_del_error[2] > 0
    s += "  ^<Ctrl+F12>^ снятие флага об ошибке у всех"
  endif
  status_key(s)
else
  status_key("^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск")
endif
return NIL

** 04.09.22
Function f2ret_oms_human(nkey)
Static tmp := " "
Local buf := savescreen(), buf1, rec1 := recno(), fl := -1, ss := 0, ;
      j, n_file := "omserror"+stxt, sh := 80, HH := 60, ii
Local mas_otchet := {}
local tmpSelect

for ii := 1 to 32
   aadd(mas_otchet,{0,0})
next  
// 1 = 3+5+24+28 Всего, в том числе
// 2 = 4+15+23+32пациентам с новой коронавирусной инфекцией COVID-19
// 3 Скорая медицинская помощь, всего, в том числе
// 4 пациентам с новой коронавирусной инфекцией COVID-19
// 5 = 6+11+12 +13+14 Амбулаторно-поликлиническая помощь, всего, в том числе
// 6 = 7+8 Посещения с профилактическими целями
// 7 для проведения профилактических медицинских осмотров
// 8 для проведения диспансеризации, всего
// 9 диспансеризация
// 10 угубленная диспансеризации
// 11 Посещений с иными целями
// 12 Посещения по неотложной помощи
// 13 Обращения по заболеваниям - медицинская реабилитация
// 14 Обращения по заболеваниям, всего, из них
// 15 пациентам с новой коронавирусной инфекцией COVID-19
// 16 в том числе (из строки 14)
// 17 компьютерная томография
// 18 магнитно-резонансная томография
// 19 ультразвуковое исследование сердечно-сосудистой системы
// 20 эндоскопические диагностические исследования
// 21 молекулярно-биологическое исследования с целью выявления онкологических заболеваний
// 22 патолого-анатомическое исследование биопсийного (операционного) материала с целью диагностики онкологических заболеваний и подбора противоопухолевой лекарственной терапии
// 23 тестирование на выявление новой коронавирусной инфекции COVID-19
// 24 = 25+26+27 Дневные стационары, всего, в том числе
// 25 по профилю ?онкология?
// 26 экстракорпоральное оплодотворение
// 27 иные профили
// 28 = 29+30+31 Стационарная медицинская помощь, всего, в том числе
// 29 по профилю ?онкология?
// 30 медицинская реабилитация
// 31 Иные профили, всего, в том числе
// 32 пациентам с новой коронавирусной инфекцией COVID-19

Private tmp1
if type("p_del_error") == "A" .and. p_del_error[2] > 0
  if nkey == K_F9
    mywait()
    fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
    add_string("")
    add_string(center("Список случаев, возвращённых ТФОМС с ошибкой",sh))
    add_string(center(p_del_error[1],sh))
    add_string(center(arr_m[4],sh))
    j := 0
    go top
    do while !eof()
      verify_FF(HH-3,.f.,sh)
      add_string("")
      ++j
      add_string(padr(lstr(j)+".",6)+alltrim(human->fio)+", д.р."+full_date(human->date_r)+",")
      if otd->IDUMP == 4
        add_string(space(6)+"карта вызова № "+alltrim(human->uch_doc)+;
                            ", дата выезда "+date_8(human->k_data))
      else
        add_string(space(6)+"лечение с "+date_8(human->n_data)+" по "+date_8(human->k_data)+;
                            ", стоимость "+lstr(human->cena_1,11,2)+"р.")
      endif
      ss += human->cena_1
      skip
    enddo
    goto rec1
    add_string("")
    add_string("Итого стоимость всех случаев "+lstr(ss,15,2)+"р.")
    fclose(fp)
    restscreen(buf)
    viewtext(n_file,,,,(sh>80),,,2)
    return -1
  // elseif eq_any(nkey,K_F12,K_CTRL_F12) .and. tip_polzovat == TIP_ADM .and. f_Esc_Enter("снятия флага об ошибке",.t.)
  elseif eq_any(nkey,K_F12,K_CTRL_F12) .and. hb_user_curUser:IsAdmin() .and. f_Esc_Enter("снятия флага об ошибке",.t.)
     /*involved_password(1,p_del_error[2],"снятия со всех пациентов флага об ошибке") ;
         .and. f_alert({padc("Выберите действие",60,".")},;
                       {" Отказ "," Снять флаг об ошибке со всех пациентов "},;
                       1,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" ) == 2*/
    go top
    do while !eof()
      human_->(G_RLock(forever))
      human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      skip
    enddo
    goto rec1
    stat_msg('Флаг об ошибке '+lstr(p_del_error[2])+' снят со всех пациентов. Войдите в режим "Реестры/Проверка"')
    mybell(4,OK)
    restscreen(buf)
    return 0
  elseif nkey == K_CTRL_F5
    if glob_mo[_MO_KOD_TFOMS] == '805965' //РДЛ
      tmpSelect := select()
      // надо фильтр по коду ошибки
      adbf1 :=  {{'num_usl', 'C', 10, 0}, ;    // номер услуги по порядку
                {'shifr_usl', 'C', 10, 0}, ;  // шифр услуги 
                {'name_usl', 'C', 250, 0}, ; // наименование услуги 
                {'NUMORDER', 'N', 10, 0}, ;   // Номер заявки(ORDER Number)
                {'fio', 'C', 70, 0}, ;
                {'kol_usl', 'N', 10, 0}, ;    // кол-во услуг
                {'cena_1', 'N', 11, 2}, ;
                {'otd', 'C', 42, 0}, ;
                {'otd_kod', 'N', 3, 0}}     
      dbcreate(cur_dir + 'tmp_err', adbf1)
      // dbcreate(fr_data + '3', adbf1)
      use (cur_dir + fr_data + '2') new alias FRD2
      // use (fr_data + '3') new alias FRD3
      use (cur_dir + 'tmp_err') new alias FRD3
      Private ii_otd  
      for ii_otd:= 1 to 4
        select frd2
        index on shifr_usl + smo_kod + str(numorder, 10) to tmp_frd9  for (otd_kod == ii_otd .and. REFREASON == kod_REFREASON_menu)
        go top
        select FRD3 
        append blank
        frd3->fio := frd2->otd
        temp_1 := ' '
        temp_2 := 1
        temp_3 := 0 // кол_во
        temp_4 := 0 // сумма
   
        select FRD3 
        append blank
        // добавляем шапку
        tsmo := ''
        if frd2->smo_kod == '34007'
          tsmo := '"Капитал МС"' 
        elseif  frd2->smo_kod == '34002'
          tsmo := '"Согаз"'
        else
          tsmo := ' Иногородние ТФОМС'
        endif     
        frd3->fio :=  tsmo
        // 
        do while !eof()
          if frd2->smo_kod == '34007'
            tsmo := '"Капитал МС"' 
          elseif  frd2->smo_kod == '34002'
            tsmo := '"Согаз"'
          else
            tsmo := ' Иногородние ТФОМС'
          endif
          select FRD3 
          append blank
          if frd2->shifr_usl != temp_1
            if temp_3 == 0
            // 
            else
              frd3->name_usl   := ' ВСЕГО :'
              frd3->kol_usl    := temp_3 
              frd3->cena_1     := temp_4
              append blank
              // добавляем шапку
              frd3->fio :=  tsmo
              append blank
            endif  
            frd3->num_usl    := str(temp_2)
            frd3->shifr_usl  := frd2->shifr_usl
            frd3->name_usl   := frd2->name_usl
            temp_1 := frd2->shifr_usl
            temp_2 ++
            temp_3 := frd2->kol_usl
            temp_4 := frd2->cena_1
          else
            frd3->shifr_usl  := ' '
            frd3->name_usl   := ' '
            temp_3 += frd2->kol_usl
            temp_4 += frd2->cena_1
          endif  
          frd3->kol_usl    := frd2->kol_usl
          frd3->cena_1     := frd2->cena_1
          frd3->fio        := frd2->fio
          frd3->otd        := frd2->otd   
          frd3->NUMORDER   := frd2->NUMORDER
          select frd2
          skip
        enddo
        select FRD3 
        append blank
        frd3->fio        := ' ВСЕГО :'
        frd3->kol_usl    := temp_3 
        frd3->cena_1     := temp_4
      Next 
      frd3->(dbclosearea())
      frd2->(dbclosearea())

      select(tmpSelect)
      // Здесь запрос на запись ЭКСЕЛЯ
      create_xls_rdl('rdl_report')  //, arr_m, st_a_uch, lcount_uch, st_a_otd, lcount_otd)
      SaveTo(cur_dir + 'rdl_report.xlsx')
    
    endif 

  elseif nkey == K_CTRL_F9
    mywait()
    
    fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
    add_string("")
    add_string(center("Сведения об отклоненных от оплаты случаях и стоимости медицинской помощи",sh))
    add_string(center(p_del_error[1],sh))
    add_string(center(arr_m[4],sh))
    tmp_1 := select()
    R_Use(dir_server+"uslugi",,"USL")
    //R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human_u_",,"HU_")
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    set relation to recno() into HU_, to u_kod into USL
    select (tmp_1)
    //
    Private mas_otch := {{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},;
                         {0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}}
    //mas_otch := array(16,2)
    //afill(mas_otch,0)
    //arr_iss := array(1,9) ; afillall(arr_iss,0)
    //
    
    go top
    do while !eof()
      verify_FF(HH-3,.f.,sh)
      //
      flag_covid := .F.
      if eq_any(human->kod_diag,"U07.1","U07.2")
        flag_covid := .T.
      endif
      if !flag_covid
        if eq_any(human->kod_diag2,"U07.1","U07.2")
          flag_covid := .T.
        endif
      endif
      if !flag_covid
        if eq_any(human->kod_diag3,"U07.1","U07.2")
          flag_covid := .T.
        endif
      endif
      if !flag_covid
        if eq_any(human->kod_diag4,"U07.1","U07.2")
          flag_covid := .T.
        endif
      endif
      //
      //select HUMAN_
      goto ((tmp_1)->(recno()))
      //goto (human->(recno()))
      //
      // Диспансеризация  
      if eq_any(human->ishod,401,402) .and. HUMAN_->Usl_ok == 3 // амбулаторная// УД
        mas_otchet[10,1] += 1 
        mas_otchet[10,2] += human->cena_1
      elseif eq_any(human->ishod,201,202,101,102) .and. HUMAN_->Usl_ok == 3 // амбулаторная// Диспансеризация
        mas_otchet[9,1] += 1 
        mas_otchet[9,2] += human->cena_1
      elseif eq_any(human->ishod,203,301,302,303,304,305) .and. HUMAN_->Usl_ok == 3 // амбулаторная// Профосмотры 
        mas_otchet[7,1] += 1 
        mas_otchet[7,2] += human->cena_1
      endif  // прочее        

      select HU
      find (str(human->kod,7))
      do while human->kod == hu->kod .and. !eof()
        // ныряем в услуги - если Диагностика - должно быть 60.*
        lshifr := ""
        svp := space(5)
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,,,,@svp)
          lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
        endif
        //
        if HUMAN_->Usl_ok == 1 //стационар
          if padr(lshifr,2) == "st" // KSG
            mas_otch[1,1] += 1
            mas_otch[2,1] += human->cena_1 // hu->stoim
            if eq_any(padr(alltrim(lshifr),8),"st12.015","st12.016",;
                      "st12.017","st12.018","st12.019")
              mas_otch[1,2] += 1
              mas_otch[2,2] += human->cena_1 // hu->stoim
            endif
            if HUMAN_->profil == 60 // онкология 
              mas_otchet[29,1] += 1 
              mas_otchet[29,2] += human->cena_1
            elseif  HUMAN_->profil == 158   // медицинская реабилитация
              mas_otchet[30,1] += 1 
              mas_otchet[30,2] += human->cena_1
            else // Иные профили, всего, в том числе
              mas_otchet[31,1] += 1 
              mas_otchet[31,2] += human->cena_1
              if flag_covid // пациентам с новой коронавирусной инфекцией COVID-19
                mas_otchet[32,1] += 1 
                mas_otchet[32,2] += human->cena_1
              endif 
            endif  
            // 28 = 29+30+31 Стационарная медицинская помощь
            mas_otchet[28,1] += 1 
            mas_otchet[28,2] += human->cena_1
          endif  
        endif
        //
        if HUMAN_->Usl_ok == 2 // дневной стационар
          if padr(lshifr,2) == "ds" // KSG -дневной стационар
            mas_otch[3,1] += 1
            mas_otch[4,1] += human->cena_1
            if flag_covid
              mas_otch[3,2] += 1
              mas_otch[4,2] += human->cena_1
            endif
            if HUMAN_->profil == 60 // онкология 
              mas_otchet[25,1] += 1 
              mas_otchet[25,2] += human->cena_1
            elseif  HUMAN_->profil == 137   // ЭКО
              mas_otchet[26,1] += 1 
              mas_otchet[26,2] += human->cena_1
            else // иные профили
              mas_otchet[27,1] += 1 
              mas_otchet[27,2] += human->cena_1
            endif  
            mas_otchet[24,1] += 1  // 24 = 25+26+27 Дневные стационары, всего,
            mas_otchet[24,2] += human->cena_1
          endif  
        endif
        //
        if HUMAN_->Usl_ok == 3 // амбулаторная
          // Диспансеризация  
          if eq_any(human->ishod,401,402) // УД
            // mas_otchet[10,1] += 1 
            // mas_otchet[10,2] += human->cena_1
          elseif eq_any(human->ishod,201,202,101,102) // Диспансеризация
            //mas_otchet[9,1] += 1 
            //mas_otchet[9,2] += human->cena_1
          elseif eq_any(human->ishod,203,301,302,303,304,305) // Профосмотры 
            //mas_otchet[7,1] += 1 
            //mas_otchet[7,2] += human->cena_1
          else  // прочее        
            if padr(lshifr,3) == "60." // Диагностика
              if padr(lshifr,4) == "60.4" //КТ
                mas_otch[13,1] += 1
                mas_otch[14,1] += hu->stoim
                //
                mas_otchet[17,1] += 1 
                mas_otchet[17,2] += human->cena_1
              endif
              if padr(lshifr,4) == "60.5" //МРТ
                mas_otchet[18,1] += 1 
                mas_otchet[18,2] += human->cena_1
              endif
              if padr(lshifr,4) == "60.6" //CCC
                mas_otchet[19,1] += 1 
                mas_otchet[19,2] += human->cena_1
              endif
              if padr(lshifr,4) == "60.7" //эндоскопические диагностические исследования
                mas_otchet[20,1] += 1 
                mas_otchet[20,2] += human->cena_1
              endif
              if padr(lshifr,4) == "60.8" //патанатомия
                mas_otchet[22,1] += 1 
                mas_otchet[22,2] += human->cena_1
              endif
              if padr(lshifr,4) == "60.9" //генная
                mas_otchet[21,1] += 1 
                mas_otchet[21,2] += human->cena_1
              endif
            //
              mas_otch[11,1] += 1
              mas_otch[12,1] += hu->stoim
              if flag_covid
                mas_otch[11,2] += 1
                mas_otch[12,2] += hu->stoim
              endif
            endif
            //
            if padr(alltrim(lshifr),8) == "4.17.785" .or.;
               padr(alltrim(lshifr),8) == "4.17.786" .or.;
               padr(alltrim(lshifr),8) == "4.17.787"     //COVID
              //
              mas_otch[15,1] += 1
              mas_otch[16,1] += hu->stoim
              //
              mas_otch[11,1] += 1
              mas_otch[12,1] += hu->stoim
              if flag_covid
                mas_otch[11,2] += 1
                mas_otch[12,2] += hu->stoim
              endif
              mas_otchet[23,1] += 1 
              mas_otchet[23,2] += human->cena_1
            endif
          // профеля
            if padr(lshifr,5) == "2.80." .or. ; // Неотложка
              padr(lshifr,5) == "2.82."        //  ПРиемный покой
              mas_otch[9,1]  += 1
              mas_otch[10,1] += hu->stoim
              mas_otchet[12,1] += 1 
              mas_otchet[12,2] += human->cena_1
              if flag_covid
                mas_otch[9,2]  += 1
                mas_otch[10,2] += hu->stoim
              endif
            elseif padr(lshifr,5) == "2.78." // Обращения
            // нужен фильтр по профилям
            // Акушерство и генология == 2,136,137
            // Дерматовенерология  == 16
            // Онкология == 60
            // Травматология и ортопедия == 100
            // Стоматологии 85,86,87,88,89,90,171,
            // Медреабилитация 158
              if eq_any(human_->profil,2,136,137,16,60,100,85,86,87,89,90,171,158)
                mas_otch[7,1] += 1
                mas_otch[8,1] += hu->stoim
                if flag_covid
                  mas_otch[7,2] += 1
                  mas_otch[8,2] += hu->stoim
                endif
                if human_->profil == 158
                  mas_otchet[13,1] += 1 
                  mas_otchet[13,2] += human->cena_1
                else  
                  mas_otchet[14,1] += 1 
                  mas_otchet[14,2] += human->cena_1
                  if flag_covid
                    mas_otchet[15,1] += 1 
                    mas_otchet[15,2] += human->cena_1
                  endif  
                endif  
              endif
            else // посещения с иными целями
              mas_otchet[11,1] += 1 
              mas_otchet[11,2] += human->cena_1
            endif
          endif
          //
          if padr(lshifr,5) == "2.79." .or.; // Посещения профилактические
             padr(lshifr,5) == "2.88."       //Диспансерное наблюдение
            // нужен фильтр по профилям
            if eq_any(human_->profil,2,136,137,16,60,100,85,86,87,89,90,171,158)
              mas_otch[5,1] += 1
              mas_otch[6,1] += hu->stoim
              if flag_covid
                mas_otch[5,2] += 1
                mas_otch[6,2] += hu->stoim
              endif
            endif
          endif
         if padr(lshifr,3) == "71." // Скорая
           mas_otchet[3,1] += 1 
           mas_otchet[3,2] += human->cena_1
          if flag_covid
            mas_otchet[4,1] += 1 
            mas_otchet[4,2] += human->cena_1
          endif  
         endif 
        endif
        select HU
        skip
      enddo
      select (tmp_1)
      skip
    enddo
    // подбивка
    my_debug(,print_array(mas_otchet))
    mas_otchet[8,1] := mas_otchet[9,1] + mas_otchet[10,1] 
    mas_otchet[8,2] := mas_otchet[9,2] + mas_otchet[10,2] 
    //
    mas_otchet[6,1] := mas_otchet[7,1] + mas_otchet[8,1] 
    mas_otchet[6,2] := mas_otchet[7,2] + mas_otchet[8,2] 
    //
    mas_otchet[5,1] := mas_otchet[6,1] + mas_otchet[11,1] + mas_otchet[12,1] + mas_otchet[13,1] + mas_otchet[14,1] 
    mas_otchet[5,2] := mas_otchet[6,2] + mas_otchet[11,2] + mas_otchet[12,2] + mas_otchet[13,2] + mas_otchet[14,2] 
    //
    mas_otchet[1,1] := mas_otchet[3,1] + mas_otchet[5,1] + mas_otchet[24,1] + mas_otchet[28,1]  
    mas_otchet[1,2] := mas_otchet[3,2] + mas_otchet[5,2] + mas_otchet[24,2] + mas_otchet[28,2]  
    //
    mas_otchet[2,1] := mas_otchet[4,1] + mas_otchet[15,1] + mas_otchet[23,1] + mas_otchet[32,1]  
    mas_otchet[2,2] := mas_otchet[4,2] + mas_otchet[15,2] + mas_otchet[23,2] + mas_otchet[32,2]  
    //
    mas_otchet[14,2] += mas_otchet[17,2] + mas_otchet[18,2] + mas_otchet[19,2] + mas_otchet[20,2] + mas_otchet[21,2] +;
                        mas_otchet[22,2] + mas_otchet[23,2] 
    //
    add_string("   Старый отчет")
    add_string("    Круглосуточный стационар")
    //
    add_string("Круглосуточный стационар случай: "+lstr(mas_otch[1,1])+;
                          "  сумма:"+put_kop(mas_otch[2,1],10))
    add_string("                   в т.ч. Covid: "+lstr(mas_otch[1,2])+;
                          "  сумма:"+put_kop(mas_otch[2,2],10))
    add_string("    Дневной стационар")
    add_string("Дневной стационар случай       : "+lstr(mas_otch[3,1])+;
                          "  сумма:"+put_kop(mas_otch[4,1],10))
    add_string("                   в т.ч. Covid: "+lstr(mas_otch[3,2])+;
                          "  сумма:"+put_kop(mas_otch[4,2],10))
    add_string("    Амбулаторная помощь")
    add_string("Посещения профилактические     : "+lstr(mas_otch[5,1])+;
                          "  сумма:"+put_kop(mas_otch[6,1],10))
    add_string("                   в т.ч. Covid: "+lstr(mas_otch[5,2])+;
                          "  сумма:"+put_kop(mas_otch[6,2],10))
    add_string("Обращения (не вход. в подушевое: "+lstr(mas_otch[7,1])+;
                          "  сумма:"+put_kop(mas_otch[8,1],10))
    add_string("                   в т.ч. Covid: "+lstr(mas_otch[7,2])+;
                          "  сумма:"+put_kop(mas_otch[8,2],10))
    add_string("Неотложная МП                  : "+lstr(mas_otch[9,1])+;
                          "  сумма:"+put_kop(mas_otch[10,1],10))
    add_string("                   в т.ч. Covid: "+lstr(mas_otch[9,2])+;
                          "  сумма:"+put_kop(mas_otch[10,2],10))
    add_string("Диагностические услуги         : "+lstr(mas_otch[11,1])+;
                          "  сумма:"+put_kop(mas_otch[12,1],10))
    add_string("                   в т.ч. Covid: "+lstr(mas_otch[11,2])+;
                          "  сумма:"+put_kop(mas_otch[12,2],10))
    add_string("Их них, КТ                     : "+lstr(mas_otch[13,1])+;
                          "  сумма:"+put_kop(mas_otch[14,1],10))
    add_string("Исследования COVID             : "+lstr(mas_otch[15,1])+;
                          "  сумма:"+put_kop(mas_otch[16,1],10))
                     // 
    add_string("")
    add_string("   Новый отчет")                 
    add_string(" 1 = 3+5+24+28 Всего, в том числе                      " +lstr(mas_otchet[1,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[1,2],10)) 
    add_string(" 2 = 4+15+23+32пациентам с COVID-19                    " +lstr(mas_otchet[2,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[2,2],10)) 
    add_string(" 3 Скорая медицинская помощь, всего, в том числе       " +lstr(mas_otchet[3,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[3,2],10)) 
    add_string(" 4 пациентам с новой коронавирусной инфекцией COVID-19 " +lstr(mas_otchet[4,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[4,2],10)) 
    add_string(" 5 = 6+11+12+13+14 Амбулаторно-поликлиническая помощь, " +lstr(mas_otchet[5,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[5,2],10)) 
    add_string(" 6 = 7+8 Посещения с профилактическими целями          " +lstr(mas_otchet[6,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[6,2],10))                                               
    add_string(" 7 для проведения профилактических медицинских осмотров" +lstr(mas_otchet[7,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[7,2],10)) 
    add_string(" 8 для проведения диспансеризации, всего               " +lstr(mas_otchet[8,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[8,2],10)) 
    add_string(" 9 диспансеризация                                     " +lstr(mas_otchet[9,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[9,2],10))
    add_string(" 10 угубленная диспансеризации                         " +lstr(mas_otchet[10,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[10,2],10)) 
    add_string(" 11 Посещений с иными целями                           " +lstr(mas_otchet[11,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[11,2],10)) 
    add_string(" 12 Посещения по неотложной помощи                     " +lstr(mas_otchet[12,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[12,2],10)) 
    add_string(" 13 Обращения по заболеваниям - мед.       реабилитация" +lstr(mas_otchet[13,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[13,2],10)) 
    add_string(" 14 Обращения по заболеваниям, всего, из них           " +lstr(mas_otchet[14,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[14,2],10)) 
    add_string(" 15 пациентам с новой коронавирусной инфекцией COVID-19" +lstr(mas_otchet[15,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[15,2],10)) 
    add_string(" 16 в том числе (из строки 14)")                                                             
    add_string(" 17 компьютерная томография                            " +lstr(mas_otchet[17,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[17,2],10)) 
    add_string(" 18 магнитно-резонансная томография                    " +lstr(mas_otchet[18,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[18,2],10)) 
    add_string(" 19 ультразвуковое исследование ССС                    " +lstr(mas_otchet[19,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[19,2],10)) 
    add_string(" 20 эндоскопические диагностические исследования       " +lstr(mas_otchet[20,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[20,2],10)) 
    add_string(" 21 молекулярно-биологическое исследования             " +lstr(mas_otchet[21,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[21,2],10)) 
    add_string(" 22 патолого-анатомическое исследование материала      " +lstr(mas_otchet[22,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[22,2],10)) 
    add_string(" 23 тестирование на выявление  инфекции COVID-19       " +lstr(mas_otchet[23,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[23,2],10)) 
    add_string("    Дневной стационар")                      
    add_string(" 24 = 25+26+27 Дневные стационары, всего, в том числе: " +lstr(mas_otchet[24,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[24,2],10)) 
    add_string(" 25 по профилю Онкология                               " +lstr(mas_otchet[25,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[25,2],10)) 
    add_string(" 26 экстракорпоральное оплодотворение                  " +lstr(mas_otchet[26,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[26,2],10)) 
    add_string(" 27 иные профили                                       " +lstr(mas_otchet[27,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[27,2],10)) 
    add_string("    Стационарная медицинская помощь")                                                           
    add_string(" 28 = 29+30+31 Стационарная медицинская помощь, всего, " +lstr(mas_otchet[28,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[28,2],10)) 
    add_string(" 29 по профилю Онкология                               " +lstr(mas_otchet[29,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[29,2],10)) 
    add_string(" 30 медицинская реабилитация                           " +lstr(mas_otchet[30,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[30,2],10)) 
    add_string(" 31 Иные профили, всего, в том числе                   " +lstr(mas_otchet[31,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[31,2],10))                          
    add_string(" 32 пациентам с  инфекцией COVID-19                    " +lstr(mas_otchet[32,1])+;
                                                              "  сумма:" +put_kop(mas_otchet[32,2],10))                        
    //
    USL->(dbCloseArea())
    HU_->(dbCloseArea())
    HU->(dbCloseArea())
    select (tmp_1)
    goto rec1
    add_string("")
    fclose(fp)
    restscreen(buf)
    viewtext(n_file,,,,(sh>80),,,2)
    return -1
  // заплатка 
  // elseif eq_any(nkey,K_F10,K_CTRL_F10) .and. tip_polzovat == TIP_ADM .and. f_Esc_Enter("смена услуги",.t.)
  elseif eq_any(nkey,K_F10,K_CTRL_F10) .and. hb_user_curUser:IsAdmin() .and. f_Esc_Enter("смена услуги",.t.)
    tmp_1 := select()
    G_Use(dir_server+"human_u",dir_server+"human_u","HU")
    select (tmp_1)
    go top
    do while !eof()
      human_->(G_RLock(forever))
      human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      //
      select ("HU")
      find (str(human->kod,7))
      if(hu->u_kod == 217) //611
        hu->(G_RLock(forever))
        hu->u_kod := 220  //614
      endif
      //
      if(hu->u_kod == 219) 
        hu->(G_RLock(forever))
        hu->u_kod := 220  
      endif
      //
      select (tmp_1)
      skip
    enddo
    goto rec1
    stat_msg('Услуга заменена у всех пациентов. Войдите в режим "Реестры/Проверка"')
    mybell(4,OK)
    restscreen(buf)
    return 0

  endif
endif
if nkey != K_F2
  return -1
endif
buf1 := savescreen(13,4,19,77)
do while .t.
  tmp1 := padr(tmp,50)
  setcolor(color8)
  box_shadow(13,14,18,67)
  @ 15,15 say center(" Введите шаблон для поиска фамилий",52)
  status_key("^<Esc>^ - отказ от ввода;  ^<F1>^ - помощь")
  @ 16,16 get tmp1 picture "@K@!"
  myread()
  setcolor(color0)
  if lastkey() == K_ESC .or. empty(tmp1)
    exit
  endif
  mywait()
  tmp := alltrim(tmp1)
  Private tmp_mas := {}, tmp_kod := {}, i := 0, t_len, k1 := mr1+3, ;
          k2 := 21, tmp2 := upper(tmp), ch := left(tmp,1)
  if !("*" $ tmp2)
    tmp2 := "*"+tmp2+"*"
  endif
  ch := left(tmp2,1)
  if !(ch == "*" .or. ch == "?")
    tmp1 := tmp2
    if "*" $ tmp1 ; tmp1 := beforatnum("*",tmp1,1) ; endif
    if "?" $ tmp1 ; tmp1 := beforatnum("?",tmp1,1) ; endif
    ch := len(tmp1)
    find (tmp1)
    do while tmp1 == left(upper(human->fio),ch) .and. !eof()
      if like(tmp2,upper(human->fio))
        if ++i > 4000 ; exit ; endif
        aadd(tmp_mas,fio_plus_novor()) ; aadd(tmp_kod,human->kod)
      endif
      skip
    enddo
  else
    go top
    do while !eof()
      if like(tmp2,upper(human->fio))
        if ++i > 4000 ; exit ; endif
        aadd(tmp_mas,fio_plus_novor()) ; aadd(tmp_kod,human->kod)
      endif
      skip
    enddo
  endif
  if (t_len := len(tmp_kod)) = 0
    stat_msg("Не найдено ни одной записи, удовлетворяющей данному шаблону!")
    mybell(2,ERR)
    restscreen(13,4,19,77,buf1)
    loop
  else
    box_shadow(mr1,2,22,77)
    SETCOLOR(col_tit_popup)
    @ k1-2,15 say "Шаблон: "+tmp2
    SETCOLOR(color0)
    if k1+t_len+2 < 21
      k2 := k1 + t_len + 2
    endif
    @ k1,3 say center(" Количество найденных фамилий - "+lstr(t_len),74)
    i := ascan(tmp_kod, glob_perso)
    status_key("^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор")
    if (i := popup(k1+1,13,k2,66,tmp_mas,i,color0)) > 0
      if regim_vyb == 1
        goto (tmp_kod[i])
      else
        select TMP_H
        go top
        Locate for kod == tmp_kod[i]
      endif
      fl := 0
    endif
    exit
  endif
enddo
if fl == -1
  goto rec1
endif
restscreen(buf)
return fl

***** 05.03.13
Function f21ret_oms_human()
Local s, r := row(), c := col()
s := "Полис ОМС: "+;
     alltrim(rtrim(human_->SPOLIS)+" "+human_->NPOLIS)+" ("+;
     alltrim(inieditspr(A__MENUVERT, mm_vid_polis, human_->VPOLIS))+")"
@ maxrow()-2,3 say padc(s,74) color color0
setpos(r,c)
return NIL

***** 09.02.14 ФИО пациента + если есть, номер новорожденного ребёнка
Function fio_plus_novor()
return alltrim(human->fio)+;
       iif(human_->NOVOR==0,""," ("+lstr(human_->NOVOR)+"-й реб.)")
