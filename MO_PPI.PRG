***** mo_ppi.prg - режимы информации для задачи "Приёмный покой"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

*****
Function pr_gurnal_pp()
Static spar := 1, spar2 := 1
Local par, par2, arr_m, i, j, k, arr, begin_date, end_date, s, ;
      buf := save_maxrow(), fl_exit := .f., sh, HH, reg_print, ;
      arr_title, name_file := "stgurnal"+stxt, atime
if (arr_m := year_month(T_ROW,T_COL-5,,,2,@atime)) == NIL
  return NIL
endif
if (par2 := popup_prompt(T_ROW,T_COL-5,spar2,;
                  {"~Полная форма",;
                   "~Сокращенная форма"})) == 0
  return NIL
endif
spar2 := par2
if (par := popup_prompt(T_ROW,T_COL-5,spar,;
                  {"С сортировкой по ~дате поступления",;
                   "С сортировкой по ~Ф.И.О. больного",;
                   "Начальная ~буква + дата поступления"})) == 0
  return NIL
endif
spar := par
//
mywait()
if par2 == 1
  arr_title := {;
   "─────┬─────┬──────────────────┬──────────┬──────────────────┬────────────────────┬───────────────┬───────────────┬───────────────╥──────────┬──────────┬───────────────────────╥─────",;
   " NN  │Дата,│ Фамилия, имя,    │   Дата   │ Паспорт и полис  │ Постоянное место   │Каким учрежде- │№ ист.болезни и│Диагноз напра- ║Выписан,  │Отметка о │Если не был госпитализ.║Приме",;
   " пп  │время│ отчество больного│ рождения │                  │ жительства,        │нием направлен,│отделение, куда│вившего учр-ия;║переведен │сообщении ├────────────┬──────────╢чание",;
   "     │пост.│                  │ и возраст│                  │ место работы       │кем доствлен   │помещен больной│приемного отд-я║в др.стац.│родственн.│причина/меры│отказ в пр║     ",;
   "─────┴─────┴──────────────────┴──────────┴──────────────────┴────────────────────┴───────────────┴───────────────┴───────────────╨──────────┴──────────┴────────────┴──────────╨─────";
  }
  sh := len(arr_title[1]) ; HH := 54 ; reg_print := 6
  Private yes_albom := .t.
  //
  Private a01[10], a02[10], a03[10], a04[10], a05[10], a06[10], a07[10], ;
          a08[10], a09[10], a10[10], a11[10]
  Private k01, k02, k03, k04, k05, k06, k07, k08, k09, k10, k11
  Private sh01 := 5, sh02 := 5, sh03 := 18, sh04 := 10, sh05 := 18, ;
          sh06 := 20, sh07 := 15, sh08 := 15, sh09 := 15
  Private arr_center := {2,4,10}
  afill(a01,"") ; k01 := 1
  afill(a02,"") ; k02 := 2
  afill(a03,"")
  afill(a04,"")
  afill(a05,"")
  afill(a06,"")
  afill(a07,"")
  afill(a08,"")
  afill(a09,"")
  kol := 9
else
  arr_title := {;
   "─────┬───────────┬─────────┬──────────────────────────┬────────────────────┬──────────",;
   " NN  │Дата, время│№ истории│  Фамилия, имя, отчество  │    Наименование    │   Дата   ",;
   " пп  │поступления│  болезни│        больного          │      отделения     │  выписки ",;
   "─────┴───────────┴─────────┴──────────────────────────┴────────────────────┴──────────";
  }
  sh := len(arr_title[1]) ; HH := 80 ; reg_print := 5
  //
  Private a04[10], a05[10], k04, k05
  Private sh01 := 5, sh02 := 11, sh03 := 9, sh04 := 26, sh05 := 20
  afill(a04,"")
  afill(a05,"")
  kol := 9
endif
k := 0
//
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(padr(org->name,sh-15)+padl("форма №001/у",15))
add_string("")
add_string(center("Журнал учета приема больных и отказов в госпитализации ",sh))
add_string(center(arr_m[4],sh))
aeval(arr_title, {|x| add_string(x) })
R_Use(dir_server+"mo_kpred",dir_server+"mo_kpred","KPR")
R_Use(dir_server+"mo_kinos",dir_server+"mo_kinos","KIS")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"mo_ppdia",dir_server+"mo_ppdia","HUS")
R_Use(dir_server+"mo_pp",dir_server+"mo_pp_d","HU")
set relation to kod_k into KART
dbseek(dtos(arr_m[5]),.t.)
do case
  case par == 1
    index on dtos(n_data)+n_time+upper(substr(kart->fio,1,20)) to (cur_dir+"tmp_hu") ;
          while n_data <= arr_m[6]
  case par == 2
    index on upper(kart->fio)+dtos(n_data)+n_time to (cur_dir+"tmp_hu") ;
          while n_data <= arr_m[6]
  case par == 3
    index on upper(left(kart->fio,1))+dtos(n_data)+n_time to (cur_dir+"tmp_hu") ;
          while n_data <= arr_m[6]
endcase
WaitStatus("<Esc> - прервать операцию")
go top
do while !eof()
  if (fl_exit := (inkey()==K_ESC))
    exit
  endif
  UpdateStatus()
  if par == 1
    @ 24,1 say full_date(hu->n_data)+" "+hu->n_time color "G+/R"
  else
    @ 24,1 say padr(fam_i_o(kart->fio),25) color "G+/R"
  endif
  if between_time(hu->n_data,hu->n_time,arr_m[5],atime[1],arr_m[6],atime[2])
    ++k
    if par2 == 1
      // 1 - номер по порядку
      a01[1] := str(k,5)
      // 2 - дата и время поступления
      a02[1] := left(full_date(hu->N_DATA),5)
      a02[2] := hu->N_TIME
      // 3 - ФИО больного
      k03 := perenos(a03,kart->fio,sh03)
      // 4 - дата рождения и возраст
      s := full_date(kart->date_r)+" "+count_ymd(kart->date_r,hu->N_DATA)
      k04 := perenos(a04,s,sh04)
      // 5 - паспорт и полис
      s := ""
      if (i := ascan(menu_vidud, {|x| x[2] == kart_->vid_ud})) > 0
        s := menu_vidud[i,4]
      endif
      s += " " + alltrim(kart_->ser_ud)
      s += " " + alltrim(kart_->nom_ud)+"; "
      if !empty(kart->polis)
        s += "полис: "+make_polis(kart_->spolis,kart_->npolis)+" "
      endif
      s += alltrim(f4_view_list_schet(hu->komu,cut_code_smo(kart_->smo),hu->str_crb))
      k05 := perenos(a05,s,sh05)
      // 6 - адрес
      s := rtrim(inieditspr(A__MENUVERT, mm_gorod_selo, kart_->gorod_selo))+", "
      s += iif(emptyall(kart_->okatog,kart->adres), "",;
               ret_okato_ulica(kart->adres,kart_->okatog))
      if !empty(kart->mr_dol)
        s += "; "+alltrim(kart->mr_dol)
      endif
      k06 := perenos(a06,s,sh06)
      // 7 - кем направлен и кем доставлен
      s := ""
      if !empty(hu->kem_napr)
        s += ret_mo(hu->kem_napr)[_MO_SHORT_NAME]
      endif
      s += iif(empty(s), "", ", ")+;
           alltrim(inieditspr(A__MENUVERT, mmpp_kem_dost, hu->KEM_DOST))
      k07 := perenos(a07,s,sh07)
      // 8 - отделение, в которое помещен больной
      s := "№ "+alltrim(hu->UCH_DOC)+"; "
      s += inieditspr(6,dir_server+"mo_otd",hu->otd)
      k08 := perenos(a08,s,sh08)
      // 9 - диагноз направившего учреждения
      MDIAG_NAPR := MDIAG_PR_P := MPOB_D_LEK := ""
      select HUS
      find (str(hu->kod,7))
      do while hus->kod == hu->kod .and. !eof()
        do case
          case hus->tip == 1
            MDIAG_NAPR := alltrim(hus->name) // диагноз направившего учреждения
          case hus->tip == 2
            MDIAG_PR_P := alltrim(hus->name) // диагноз приемного отделения
          case hus->tip == 3
            MPOB_D_LEK := alltrim(hus->name) // побочное действие лекарств
        endcase
        skip
      enddo
      s := iif(empty(mDIAG_NAPR), "-", mDIAG_NAPR)+"; "+;
           iif(empty(mDIAG_PR_P), "-", mDIAG_PR_P)
      k09 := perenos(a09,s,sh09)
      //
      kk := 1
      for i := 1 to kol
        pole := "k"+strzero(i,2)
        kk := max(kk,&pole)
      next
      kk := min(kk,10)
      if verify_FF(HH-kk,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      for j := 1 to kk
        s := ""
        for i := 1 to kol
          pole := "a"+strzero(i,2)
          ss := &pole.[j]
          pole := "sh"+strzero(i,2)
          if ascan(arr_center,i) > 0
            ss := padc(alltrim(ss),&pole)
          else
            ss := padr(alltrim(ss),&pole)
          endif
          s += ss+" "
        next
        if j == 1  // в первой строке
          s += padr(full_date(hu->K_DATA),10)+" " // Выписан, переведен в др.стацион.
          if hu->novor > 0
            s += padc("новорожден",10)+" "
          else
            select KPR
            find (str(hu->kod_k,7))
            s += padc(iif(found().and.kpr->is_uhod==1,"по уходу",""),10)+" " //сообщение родственникам
          endif
          if hu->is_gospit == 1
            s1 := "не госпитализирован"
            s += padr(s1,12+1+10+1)
          else
            s += space(12)+" "   //причина/меры
            s += space(10)+" "   //отказ в пр
          endif
          s += substr(inieditspr(6,dir_server+"mo_ppst",hu->stol),1,5) //Примечание
        elseif j == 2  // во второй строке
          if !empty(hu->k_data)
            s += padc(hu->N_TIME,11)
          else
            s += space(11)
          endif
          s += space(11)
          s1 := ""
          if hu->is_gospit == 1 .and. hu->pr_gospit > 0
            s1 := inieditspr(A__MENUVERT, mmpp_pr_gospit, hu->pr_gospit)
          endif
          s += padr(s1,12+1+10+1)
          if hu->ishod2 == 6  // умер
            s += "УМЕР"
          else
            s += substr(inieditspr(6,dir_server+"mo_ppst",hu->stol),6,5) //Примечание
          endif
        endif
        add_string(s)
      next
      select KIS
      find (str(hu->kod_k,7))
      if found() // иностранец
        f_gur_inostr_pp(sh)
      endif
    else
      // 1 - номер по порядку
      s := str(k,5)+" "
      // 2 - дата и время поступления
      s += left(full_date(hu->N_DATA),5)+" "+hu->N_TIME+" "
      // 3 - история болезни
      s += hu->UCH_DOC
      // 3 - ФИО больного
      k04 := perenos(a04,kart->fio,sh04)
      s += padr(a04[1],sh04+1)
      // 5 - отделение, в которое помещен больной
      k05 := perenos(a05,inieditspr(6,dir_server+"mo_otd",hu->otd),sh05)
      s += padr(a05[1],sh05+1)
      s += full_date(hu->K_DATA)
      kk := min(max(k04,k05),10)
      if verify_FF(HH-kk,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s)
      for j := 2 to kk
        s := space(sh01+1+sh02+1+sh03+1)
        s += padr(a04[j],sh04+1)
        s += padr(a05[j],sh05+1)
        add_string(s)
      next
      select KIS
      find (str(hu->kod_k,7))
      if found() // иностранец
        f_gur_inostr_pp(sh)
      endif
      if kk == 1
        add_string("")
      endif
    endif
  endif
  select HU
  skip
enddo
close databases
if fl_exit
  add_string(expand("ПРОЦЕСС ПРЕРВАН"))
endif
fclose(fp)
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*****
Function pr_svod_pp(k)
Static si1 := 1, si2 := 1
Local mas_pmt, mas_msg, mas_fun, j, uch_otd
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~Общий свод",;
                "Отделения + ~направившие ЛПУ",;
                "Отделения + ~столы",;
                'Отделения + "~госпитализация"',;
                "Свод по ~возрастам",;
                "Свод по ~детям и подросткам",;
                "Невыписанные ~больные"}
    mas_msg := {"Общий свод по больным, зарегистрированным в стационаре",;
                "Вывод сводной информации по отделениям и направившим учреждениям",;
                "Вывод сводной информации по отделениям и столам",;
                "Вывод сводной информации по отделениям с разбивкой по типу госпитализации",;
                "Вывод сводной информации по отделениям с разбивкой по возрастам",;
                "Разбивка по возрастам детей и подростков до 18 лет",;
                "Вывод текущей информации по количеству больных в отделениях"}
    mas_fun := {"pr_svod_pp(11)",;
                "pr_svod_pp(12)",;
                "pr_svod_pp(13)",;
                "pr_svod_pp(14)",;
                "pr_svod_pp(15)",;
                "pr_svod_pp(16)",;
                "pr_svod_pp(17)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    pr_ob_svod_pp()
  case k == 12
    pr_otd_lpu_pp()
  case k == 13
    pr_otd_stol_pp()
  case k == 14
    pr_otd_gosp_pp()
  case k == 15
    pr_otd_vozr_pp()
  case k == 16
    pr_otd_vozr_deti_pp()
  case k == 17
    pr_otd_tek_pp()
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

***** 26.12.12
Function pr_ob_svod_pp()
Static spar := 1
Local arr_m, i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(),;
      sh := 60, HH := 58, reg_print := 2, name_file := "pp_otd"+stxt,;
      arr_otd := {}, arr_uch := {}, arr_gs := {0,0,0},;
      arr_prin := {}, arr_raj := {}, arr_kat := {}, arr_pol := {0,0},;
      arr_vz_reb := {0,0,0}, arr_stol := {}, atime, ra[5],;
      mas_pmt := {"Все больные","Стационарные больные","Дневной стационар"}
if (par := popup_prompt(T_ROW,T_COL-5,spar,mas_pmt)) == NIL
  return NIL
endif
spar := par
if (arr_m := year_month(T_ROW,T_COL-5,,,2,@atime)) == NIL
  return NIL
endif
//
mywait()
//
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(rtrim(org->name))
add_string("")
add_string(center("Количество зарегистрированных стационарных больных",sh))
add_string(center("[ "+mas_pmt[par]+" ]",sh))
add_string(center(arr_m[4],sh))
R_Use(dir_server+"mo_kpred",dir_server+"mo_kpred","KPR")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"mo_pp",dir_server+"mo_pp_d","HU")
set relation to kod_k into KART
dbseek(dtos(arr_m[5]),.t.)
kv := k1 := kds := k1ds := 0
do while n_data <= arr_m[6] .and. !eof()
  fl := .t.
  if par == 2
    fl := (hu->reg_lech == 1)
  elseif par == 3
    fl := (hu->reg_lech > 1)
  endif
  if fl .and. between_time(hu->n_data,hu->n_time,arr_m[5],atime[1],arr_m[6],atime[2])
    if hu->is_gospit == 0  // только те, кто госпитализированы
      mstr_crb := iif(hu->komu==0, int(val(cut_code_smo(kart_->smo))), hu->str_crb)
      if (i := ascan(arr_prin, {|x| x[1]==hu->komu.and.x[2]==mstr_crb}))==0
        aadd(arr_prin, {hu->komu,mstr_crb,0,""}) ; i := len(arr_prin)
      endif
      arr_prin[i,3] ++
      if kart->pol == "М"
        arr_pol[1] ++
      else
        arr_pol[2] ++
      endif
      if hu->novor > 0
        cy := 1
      else
        cy := count_years(kart->date_r,hu->n_data)
      endif
      if cy < 14       // ребенок
        arr_vz_reb[2] ++
      elseif cy < 18   // подросток
        arr_vz_reb[3] ++
      else             // взрослый
        arr_vz_reb[1] ++
      endif
      if empty(ini_strana(kart_->strana))
        j := 0 ; k := 18 ; s := "Центральный"
        if !empty(kart_->okatog)
          if !(left(kart_->okatog,2)=='18')
            j := 2 ; k := 0 ; s := ""
          elseif !empty(okato_rajon(kart_->okatog,@ra))
            j := ra[2] ; k := ra[3] ; s := ra[1]
          endif
        endif
      else // иностранец
        j := 3 ; k := 0 ; s := ""
      endif
      if (i := ascan(arr_raj, {|x| x[1]==j .and. x[2]==k}))==0
        aadd(arr_raj, {j,k,0,0,s,{}}) ; i := len(arr_raj)
      endif
      arr_raj[i,3] ++
      if (j := ascan(arr_raj[i,6], {|x| x[1] == hu->otd } )) == 0
        aadd(arr_raj[i,6], {hu->otd,inieditspr(6,dir_server+"mo_otd",hu->otd),0} )
        j := len(arr_raj[i,6])
      endif
      ++ arr_raj[i,6,j,3]
      //
      if (i := ascan(arr_otd, {|x| x[1] == hu->otd } )) == 0
        aadd(arr_otd, {hu->otd,inieditspr(6,dir_server+"mo_otd",hu->otd),0,0,0,0,0} )
        i := len(arr_otd)
      endif
      ++ arr_otd[i,3]
      ++ kv
      if hu->REG_LECH > 1
        ++ arr_otd[i,6]
        ++ kds
      endif
      select KPR
      find (str(hu->kod_k,7))
      if (found().and.kpr->is_uhod==1) .or. hu->novor>0
        ++ arr_otd[i,4]
        ++ k1
        if hu->REG_LECH > 1
          ++ arr_otd[i,7]
          ++ k1ds
        endif
      endif
      //
      if hu->stol > 0
        if (i := ascan(arr_stol, {|x| x[1] == hu->stol } )) == 0
          aadd(arr_stol, {hu->stol,inieditspr(6,dir_server+"mo_ppst",hu->stol),0} )
          i := len(arr_stol)
        endif
        ++ arr_stol[i,3]
      endif
      //
      if (i := ascan(arr_uch, {|x| x[1] == hu->kem_napr } )) == 0
        aadd(arr_uch, {hu->kem_napr,ret_mo(hu->kem_napr)[_MO_SHORT_NAME],0,0} )
        i := len(arr_uch)
      endif
      ++ arr_uch[i,3]
      //
      if between(kart_->gorod_selo,1,3)
        ++ arr_gs[kart_->gorod_selo]
      endif
    else // не госпитализированные
      if (i := ascan(arr_otd, {|x| x[1] == hu->otd } )) == 0
        aadd(arr_otd, {hu->otd,inieditspr(6,dir_server+"mo_otd",hu->otd),0,0,0,0,0} )
        i := len(arr_otd)
      endif
      ++ arr_otd[i,5]
      //
      if (i := ascan(arr_uch, {|x| x[1] == hu->kem_napr } )) == 0
        aadd(arr_uch, {hu->kem_napr,ret_mo(hu->kem_napr)[_MO_SHORT_NAME],0,0} )
        i := len(arr_uch)
      endif
      ++ arr_uch[i,4]
    endif
  endif
  select HU
  skip
enddo
close databases
//
asort(arr_otd,,,{|x,y| upper(x[2]) < upper(y[2]) } )
verify_FF(HH-3,.t.,sh)
add_string("")
add_string("  По отделениям:")
for i := 1 to len(arr_otd)
  verify_FF(HH,.t.,sh)
  s := padr(alltrim(arr_otd[i,2]),sh-10,".")+;
       padl(lstr(arr_otd[i,3]),10,".")
  if !empty(arr_otd[i,4])
    s += "+"+lstr(arr_otd[i,4])
  endif
  if arr_otd[i,5] > 0
    s += " (+ "+lstr(arr_otd[i,5])+" не госпит.)"
  endif
  add_string(s)
next
add_string(replicate("─",sh))
s := padr("Итого:",sh-10,".")+padl(lstr(kv),10,".")
if !empty(k1)
  s += "+"+lstr(k1)
endif
add_string(s)
if par == 1 .and. !empty(kds)
  verify_FF(HH-3,.t.,sh)
  add_string("")
  add_string("  В т.ч.дневной стационар:")
  for i := 1 to len(arr_otd)
    if !empty(arr_otd[i,6])
      verify_FF(HH,.t.,sh)
      s := padr(alltrim(arr_otd[i,2]),sh-10,".")+;
           padl(lstr(arr_otd[i,6]),10,".")
      if !empty(arr_otd[i,7])
        s += "+"+lstr(arr_otd[i,7])
      endif
      add_string(s)
    endif
  next
  add_string(replicate("─",sh))
  s := padr("Итого:",sh-10,".")+padl(lstr(kds),10,".")
  if !empty(k1ds)
    s += "+"+lstr(k1ds)
  endif
  add_string(s)
endif
if !empty(arr_stol)
  asort(arr_stol,,,{|x,y| upper(x[2]) < upper(y[2]) } )
  verify_FF(HH-3,.t.,sh)
  add_string("")
  add_string("  По столам:")
  for i := 1 to len(arr_stol)
    verify_FF(HH,.t.,sh)
    add_string(padr(alltrim(arr_stol[i,2]),sh-10,".")+;
               padl(lstr(arr_stol[i,3]),10,"."))
  next
endif
if !empty(arr_uch)
  asort(arr_uch,,,{|x,y| upper(x[2]) < upper(y[2]) } )
  verify_FF(HH-3,.t.,sh)
  add_string("")
  add_string("  По учреждениям, кем направлен больной:")
  for i := 1 to len(arr_uch)
    verify_FF(HH,.t.,sh)
    s := padr(alltrim(charrem('"',arr_uch[i,2])),sh-10,".")+;
         padl(lstr(arr_uch[i,3]),10,".")
    if arr_uch[i,4] > 0
      s += " (+ "+lstr(arr_uch[i,4])+" не госпит.)"
    endif
    add_string(s)
  next
endif
if !empty(arr_prin)
  for i := 1 to len(arr_prin)
    if arr_prin[i,1] == 0
      arr_prin[i,4] := alltrim(inieditspr(A__MENUVERT, glob_arr_smo, arr_prin[i,2]))
    else
      arr_prin[i,4] := ""
      if arr_prin[i,1] == 1
        arr_prin[i,4] := "пр.компания - "
      elseif arr_prin[i,1] == 3
        arr_prin[i,4] := "комитет/МО - "
      endif
      arr_prin[i,4] += f4_view_list_schet(arr_prin[i,1],"",arr_prin[i,2])
    endif
  next
  asort(arr_prin,,,{|x,y| if(x[1] == y[1], ;
                            upper(x[4]) < upper(y[4]), x[1] < y[1]) } )
  verify_FF(HH-3, .t., sh)
  add_string("")
  add_string("  По принадлежности счета:")
  for i := 1 to len(arr_prin)
    verify_FF(HH, .t., sh)
    add_string(padr(arr_prin[i,4],50)+str(arr_prin[i,3],6))
  next
endif
//
if !empty(arr_raj)
  for i := 1 to len(arr_raj)
    if arr_raj[i,1] < 2
      //
    elseif arr_raj[i,1] == 2
      arr_raj[i,5] := "иногородние"
    else
      arr_raj[i,5] := "иностранцы"
    endif
  next
  use
  asort(arr_raj,,,{|x,y| if(x[1] == y[1], ;
                            upper(x[5]) < upper(y[5]), x[1] < y[1]) } )
  verify_FF(HH-3, .t., sh)
  add_string("")
  add_string(padr("  По районам:",25)+padc("места жительства",20))
  for i := 1 to len(arr_raj)
    verify_FF(HH, .t., sh)
    add_string(padr(arr_raj[i,5],25)+str(arr_raj[i,3],12))
  next
  verify_FF(HH-4, .t., sh)
  add_string("")
  add_string("  Район места жительства + отделения")
  for i := 1 to len(arr_raj)
    verify_FF(HH-2, .t., sh)
    add_string(padr(arr_raj[i,5],25)+str(arr_raj[i,3],12))
    for j := 1 to len(arr_raj[i,6])
      verify_FF(HH, .t., sh)
      add_string(space(10)+padr(alltrim(arr_raj[i,6,j,2]),sh-20,".")+;
                 padl(lstr(arr_raj[i,6,j,3]),10,"."))
    next
  next
endif
if kv > 0
  verify_FF(HH-4,.t.,sh)
  add_string("")
  add_string("")
  add_string(padr("Город",sh-10,".")+padl(lstr(arr_gs[1]),10,"."))
  add_string(padr("Село", sh-10,".")+padl(lstr(arr_gs[2]),10,"."))
  if arr_gs[3] > 0
    add_string(padr("Раб.поселок",sh-10,".")+padl(lstr(arr_gs[3]),10,"."))
  endif
  verify_FF(HH-3,.t.,sh)
  add_string("")
  add_string(padr("Мужчин",sh-10,".")+padl(lstr(arr_pol[1]),10,"."))
  add_string(padr("Женщин",sh-10,".")+padl(lstr(arr_pol[2]),10,"."))
  verify_FF(HH-4,.t.,sh)
  add_string("")
  add_string(padr("Взрослый", sh-10,".")+padl(lstr(arr_vz_reb[1]),10,"."))
  add_string(padr("Ребенок",  sh-10,".")+padl(lstr(arr_vz_reb[2]),10,"."))
  add_string(padr("Подросток",sh-10,".")+padl(lstr(arr_vz_reb[3]),10,"."))
endif
fclose(fp)
rest_box(buf)
viewtext(name_file,,,,.t.,,,reg_print)
return NIL

*****
Function pr_otd_lpu_pp()
Local arr_m, i, j, l, k, k1, arr, begin_date, end_date, s, buf := save_maxrow(),;
      sh, HH := 58, reg_print, name_file := "pp_otd2"+stxt,;
      arr_otd := {}, arr_uch := {}, arr_title, atime
if (arr_m := year_month(T_ROW,T_COL-5,,,2,@atime)) == NIL
  return NIL
endif
//
mywait()
R_Use(dir_server+"mo_kpred",dir_server+"mo_kpred","KPR")
R_Use(dir_server+"mo_pp",dir_server+"mo_pp_d","HU")
dbseek(dtos(arr_m[5]),.t.)
k := k1 := 0
do while n_data <= arr_m[6] .and. !eof()
  if between_time(hu->n_data,hu->n_time,arr_m[5],atime[1],arr_m[6],atime[2])
    if hu->is_gospit == 0  // только те, кто госпитализированы
      if (i := ascan(arr_otd, {|x| x[1] == hu->otd } )) == 0
        aadd(arr_otd, {hu->otd,inieditspr(6,dir_server+"mo_otd",hu->otd),0,0,{},0} )
        i := len(arr_otd)
      endif
      if (j := ascan(arr_otd[i,5], {|x| x[1] == hu->kem_napr } )) == 0
        aadd(arr_otd[i,5], {hu->kem_napr,0,0,0,0} ) ; j := len(arr_otd[i,5])
      endif
      if (l := ascan(arr_uch, {|x| x[1] == hu->kem_napr } )) == 0
        aadd(arr_uch, {hu->kem_napr,charrem('"',ret_mo(hu->kem_napr)[_MO_SHORT_NAME]),0,0} )
        l := len(arr_uch)
      endif
      ++ arr_otd[i,3]
      ++ arr_otd[i,5,j,3]
      ++ arr_uch[l,3]
      ++ k
      select KPR
      find (str(hu->kod_k,7))
      if (found() .and. kpr->is_uhod == 1) .or. hu->novor > 0
        ++ arr_otd[i,4]
        ++ arr_otd[i,5,j,4]
        ++ arr_uch[l,4]
        ++ k1
      endif
    else  // не госпитализированные
      if (i := ascan(arr_otd, {|x| x[1] == hu->otd } )) == 0
        aadd(arr_otd, {hu->otd,inieditspr(6,dir_server+"mo_otd",hu->otd),0,0,{},0} )
        i := len(arr_otd)
      endif
      if (j := ascan(arr_otd[i,5], {|x| x[1] == hu->kem_napr } )) == 0
        aadd(arr_otd[i,5], {hu->kem_napr,0,0,0,0} ) ; j := len(arr_otd[i,5])
      endif
      if ascan(arr_uch, {|x| x[1] == hu->kem_napr } ) == 0
        aadd(arr_uch, {hu->kem_napr,charrem('"',ret_mo(hu->kem_napr)[_MO_SHORT_NAME]),0,0} )
        l := len(arr_uch)
      endif
      ++ arr_otd[i,6]
      ++ arr_otd[i,5,j,5]
      ++ arr_uch[l,4]
    endif
  endif
  select HU
  skip
enddo
close databases
if k == 0
  rest_box(buf)
  return func_error(4,"Нет информации за указанный период времени!")
endif
//
asort(arr_otd,,,{|x,y| upper(x[2]) < upper(y[2]) } )
asort(arr_uch,,,{|x,y| upper(x[2]) < upper(y[2]) } )
arr_title := {;
"──────────────────────────────",;
"                              ",;
"                              ",;
"         Наименование         ",;
"          отделения           ",;
"                              ",;
"                              ",;
"──────────────────────────────"}
for i := 1 to len(arr_uch)
  s := padr(arr_uch[i,2],42)
  arr_title[1] += "┬───────"
  arr_title[2] += "│"+substr(s, 1,7)
  arr_title[3] += "│"+substr(s, 8,7)
  arr_title[4] += "│"+substr(s,15,7)
  arr_title[5] += "│"+substr(s,22,7)
  arr_title[6] += "│"+substr(s,29,7)
  arr_title[7] += "│"+substr(s,36,7)
  arr_title[8] += "┴───────"
next
arr_title[1] += "╥────────┬───"
arr_title[2] += "║        │   "
arr_title[3] += "║        │   "
arr_title[4] += "║ Всего  │ % "
arr_title[5] += "║        │   "
arr_title[6] += "║        │   "
arr_title[7] += "║        │   "
arr_title[8] += "╨────────┴───"
reg_print := f_reg_print(arr_title,@sh)
//
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(alltrim(org->name))
org->(dbCloseArea())
add_string("")
add_string(center("Количество зарегистрированных стационарных больных",sh))
add_string(center(arr_m[4],sh))
add_string("")
aeval(arr_title, {|x| add_string(x) })
for i := 1 to len(arr_otd)
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  s := padr(alltrim(arr_otd[i,2]),30,".")
  for l := 1 to len(arr_uch)
    if (j := ascan(arr_otd[i,5], {|x| x[1] == arr_uch[l,1] })) == 0
      s += replicate(".",8)
    else
      s1 := alltrim(put_val(arr_otd[i,5,j,3],8))
      if !empty(arr_otd[i,5,j,4])
        s1 += "+"+lstr(arr_otd[i,5,j,4])
      endif
      s += padl(s1,8,".")
    endif
  next
  s1 := lstr(arr_otd[i,3])
  if !empty(arr_otd[i,4])
    s1 += "+"+lstr(arr_otd[i,4])
  endif
  s += padl(s1,9,".")
  s += " "+umest_val(arr_otd[i,3]/k*100,3,1)
  add_string(s)
  if arr_otd[i,6] > 0
    s := padr("    (+ не госпитализированные)",30)
    for l := 1 to len(arr_uch)
      if (j := ascan(arr_otd[i,5], {|x| x[1] == arr_uch[l,1] })) == 0
        s += space(8)
      elseif empty(arr_otd[i,5,j,5])
        s += space(8)
      else
        s += str(arr_otd[i,5,j,5],8)
      endif
    next
    s += str(arr_otd[i,6],9)
    add_string(s)
  endif
next
add_string(replicate("═",sh))
s := padc("Итого:",30)
for j := 1 to len(arr_uch)
  s1 := lstr(arr_uch[j,3])
  if !empty(arr_uch[j,4])
    s1 += "+"+lstr(arr_uch[j,4])
  endif
  s += padl(s1,8)
next
s1 := lstr(k)
if !empty(k1)
  s1 += "+"+lstr(k1)
endif
if len(s1) < 9
  s += padl(s1,9)
else
  s += " "+s1
endif
add_string(s)
add_string(replicate("─",sh))
s := padc("(в %):",30)
for j := 1 to len(arr_uch)
  s += umest_val(arr_uch[j,3]/k*100,8,1)
next
add_string(s)
//
fclose(fp)
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,memPPsvod)
return NIL

***** 24.01.17
Function pr_otd_stol_pp()
Local arr_m, i, j, l, k, k1, arr, begin_date, end_date, s, buf := save_maxrow(),;
      sh, HH := 58, reg_print, name_file := "pp_otd3"+stxt, fl := .f.,;
      arr_otd := {}, arr_stol := {}, arr_title, atime, is_perevod := 1
if (arr_m := year_month(T_ROW,T_COL-5,,,2,@atime)) == NIL
  return NIL
endif
if (is_perevod := ;
       f_alert({'Выберите, каким образом формировать сводный документ:'},;
               {" Поступившие больные ",;
                " Плюс переведенные больные "},;
               1,"N+/BG","R/BG",17,,col1menu )) == 0
  return NIL
endif
//
mywait()
R_Use(dir_server+"mo_ppst",,"ST")
R_Use(dir_server+"mo_kpred",dir_server+"mo_kpred","KPR")
R_Use(dir_server+"mo_pp",dir_server+"mo_pp_d","HU")
dbseek(dtos(arr_m[5]),.t.)
k := k1 := 0
do while n_data <= arr_m[6] .and. !eof()
  if between_time(hu->n_data,hu->n_time,arr_m[5],atime[1],arr_m[6],atime[2]) ;
    .and. hu->is_gospit == 0  // только те, кто госпитализированы
    if (i := ascan(arr_otd, {|x| x[1] == hu->otd } )) == 0
      aadd(arr_otd, {hu->otd,inieditspr(6,dir_server+"mo_otd",hu->otd),0,0,{},0,0,0,0} )
      i := len(arr_otd)
    endif
    if (j := ascan(arr_otd[i,5], {|x| x[1] == hu->stol } )) == 0
      aadd(arr_otd[i,5], {hu->stol,0,0,0,0,0,0,0,0} )
      j := len(arr_otd[i,5])
    endif
    st->(dbGoto(hu->stol))
    if (l := ascan(arr_stol, {|x| x[1] == hu->stol } )) == 0
      aadd(arr_stol, {hu->stol,st->name,0,0,st->tip} )
      l := len(arr_stol)
    endif
    ++ arr_otd[i,5,j,3]
    ++ arr_stol[l,3]
    if st->tip == 0
      ++ arr_otd[i,3]
      ++ k
    endif
    fl := .t.
    select KPR
    find (str(hu->kod_k,7))
    if (found() .and. kpr->is_uhod == 1 .and. kpr->is_food == 1) .or. hu->novor > 0
      ++ arr_otd[i,5,j,4]
      ++ arr_stol[l,4]
      if st->tip == 0
        ++ arr_otd[i,4]
        ++ k1
      endif
    endif
  endif
  select HU
  skip
enddo
if is_perevod == 2
  select HU
  set index to
  dbcreate(cur_dir+"tmp",{{"kod",  "N",7,0},;
                          {"otd1", "N",3,0},;
                          {"stol1","N",3,0},;
                          {"otd2", "N",3,0},;
                          {"stol2","N",3,0},;
                          {"rec",  "N",7,0}})
  use (cur_dir+"tmp") new
  R_Use(dir_server+"mo_ppper",,"PER")
  index on str(kod,7) to (cur_dir+"tmp_per") for between(n_data,arr_m[5],arr_m[6])
  go top
  do while !eof()
    if between_time(per->n_data,per->n_time,arr_m[5],atime[1],arr_m[6],atime[2])
      select TMP
      append blank
      tmp->kod   := per->kod
      tmp->otd2  := per->otd
      tmp->stol2 := per->stol
      tmp->rec   := per->(recno())
      fl := .t.
    endif
    select PER
    skip
  enddo
  if tmp->(lastrec()) > 0
    select PER
    set index to (dir_server+"mo_ppper")
    select TMP
    go top
    do while !eof()
      arr := {}
      select PER
      find (str(tmp->kod,7))
      do while per->kod == tmp->kod .and. !eof()
        aadd(arr, {per->n_data,per->n_time,per->(recno()),per->otd,per->stol})
        skip
      enddo
      asort(arr,,,{|x,y| iif(x[1]==y[1], x[2] < y[2], x[1] < y[1]) })
      if (j := ascan(arr, {|x| x[3] == tmp->rec })) > 1  // если переводился до этого
        tmp->otd1 := arr[j-1,4]
        tmp->stol1 := arr[j-1,5]
      else  // не было ни одного перевода до этого
        hu->(dbGoto(tmp->kod))
        tmp->otd1 := hu->otd
        tmp->stol1 := hu->stol
      endif
      select TMP
      skip
    enddo
    //
    select TMP
    go top
    do while !eof()
      hu->(dbGoto(tmp->kod))
      // вычесть стол 1
      if (i := ascan(arr_otd, {|x| x[1] == tmp->otd1 } )) == 0
        aadd(arr_otd, {tmp->otd1,inieditspr(6,dir_server+"mo_otd",tmp->otd1),0,0,{},0,0,0,0} )
        i := len(arr_otd)
      endif
      if (j := ascan(arr_otd[i,5], {|x| x[1] == tmp->stol1 } )) == 0
        aadd(arr_otd[i,5], {tmp->stol1,0,0,0,0,0,0,0,0} )
        j := len(arr_otd[i,5])
      endif
      st->(dbGoto(tmp->stol1))
      if (l := ascan(arr_stol, {|x| x[1] == tmp->stol1 } )) == 0
        aadd(arr_stol, {tmp->stol1,st->name,0,0,st->tip} )
        l := len(arr_stol)
      endif
      -- arr_otd[i,5,j,3]
      -- arr_otd[i,5,j,6]
      -- arr_stol[l,3]
      if st->tip == 0
        -- arr_otd[i,3]
        -- arr_otd[i,6]
      endif
      select KPR
      find (str(hu->kod_k,7))
      if (found() .and. kpr->is_uhod == 1 .and. kpr->is_food == 1) .or. hu->novor > 0
        -- arr_otd[i,5,j,4]
        ++ arr_otd[i,5,j,7]
        -- arr_stol[l,4]
        if st->tip == 0
          -- arr_otd[i,4]
          ++ arr_otd[i,7]
        endif
      endif
      // добавить стол 2
      if (i := ascan(arr_otd, {|x| x[1] == tmp->otd2 } )) == 0
        aadd(arr_otd, {tmp->otd2,inieditspr(6,dir_server+"mo_otd",tmp->otd2),0,0,{},0,0,0,0} )
        i := len(arr_otd)
      endif
      if (j := ascan(arr_otd[i,5], {|x| x[1] == tmp->stol2 } )) == 0
        aadd(arr_otd[i,5], {tmp->stol2,0,0,0,0,0,0,0,0} ) ; j := len(arr_otd[i,5])
      endif
      st->(dbGoto(tmp->stol2))
      if (l := ascan(arr_stol, {|x| x[1] == tmp->stol2 } )) == 0
        aadd(arr_stol, {tmp->stol2,st->name,0,0,st->tip} )
        l := len(arr_stol)
      endif
      ++ arr_otd[i,5,j,3]
      ++ arr_otd[i,5,j,8]
      ++ arr_stol[l,3]
      if st->tip == 0
        ++ arr_otd[i,3]
        ++ arr_otd[i,8]
      endif
      select KPR
      find (str(hu->kod_k,7))
      if (found() .and. kpr->is_uhod == 1 .and. kpr->is_food == 1) .or. hu->novor > 0
        ++ arr_otd[i,5,j,4]
        ++ arr_otd[i,5,j,9]
        ++ arr_stol[l,4]
        if st->tip == 0
          ++ arr_otd[i,4]
          ++ arr_otd[i,9]
        endif
      endif
      select TMP
      skip
    enddo
  endif
endif
close databases
if !fl
  rest_box(buf)
  return func_error(4,"Нет информации за указанный период времени!")
endif
//
asort(arr_otd,,,{|x,y| upper(x[2]) < upper(y[2]) } )
asort(arr_stol,,,{|x,y| upper(x[2]) < upper(y[2]) } )
arr_title := {;
"──────────────────────────────",;
"                              ",;
"         Наименование         ",;
"          отделения           ",;
"──────────────────────────────"}
for i := 1 to len(arr_stol)
  if arr_stol[i,5] == 0
    s := padr(arr_stol[i,2],24)
    arr_title[1] += "┬───────"
    arr_title[2] += "│"+substr(s, 1,7)
    arr_title[3] += "│"+substr(s, 8,7)
    arr_title[4] += "│"+substr(s,15,7)
    arr_title[5] += "┴───────"
  endif
next
arr_title[1] += "╥────────┬───"
arr_title[2] += "║        │   "
arr_title[3] += "║ Всего  │ % "
arr_title[4] += "║        │   "
arr_title[5] += "╨────────┴───"
for i := 1 to len(arr_stol)
  if arr_stol[i,5] == 1
    s := padr(arr_stol[i,2],24)
    arr_title[1] += "╥───────"
    arr_title[2] += "║"+substr(s, 1,7)
    arr_title[3] += "║"+substr(s, 8,7)
    arr_title[4] += "║"+substr(s,15,7)
    arr_title[5] += "╨───────"
  endif
next
reg_print := f_reg_print(arr_title,@sh)
//
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(alltrim(org->name))
org->(dbCloseArea())
add_string("")
add_string(center("Количество зарегистрированных стационарных больных",sh))
add_string(center(arr_m[4],sh))
add_string("")
aeval(arr_title, {|x| add_string(x) })
for i := 1 to len(arr_otd)
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  s := padr(alltrim(arr_otd[i,2]),30,".")
  for l := 1 to len(arr_stol)
    if arr_stol[l,5] == 0
      if (j := ascan(arr_otd[i,5], {|x| x[1] == arr_stol[l,1] })) == 0
        s += replicate(".",8)
      else
        s1 := lstr(arr_otd[i,5,j,3])
        if !empty(arr_otd[i,5,j,4])
          s1 += "+"+lstr(arr_otd[i,5,j,4])
        endif
        s += padl(s1,8,".")
      endif
    endif
  next
  s1 := lstr(arr_otd[i,3])
  if !empty(arr_otd[i,4])
    s1 += "+"+lstr(arr_otd[i,4])
  endif
  s += padl(s1,9,".")
  s += " "+umest_val(arr_otd[i,3]/k*100,3,1)
  for l := 1 to len(arr_stol)
    if arr_stol[l,5] == 1
      if (j := ascan(arr_otd[i,5], {|x| x[1] == arr_stol[l,1] })) == 0
        s += replicate(".",8)
      else
        s1 := lstr(arr_otd[i,5,j,3])
        if !empty(arr_otd[i,5,j,4])
          s1 += "+"+lstr(arr_otd[i,5,j,4])
        endif
        s += padl(s1,8,".")
      endif
    endif
  next
  add_string(s)
  if !emptyall(arr_otd[i,6],arr_otd[i,8])
    s := padl("(в т.ч. переведенные)",30)
    for l := 1 to len(arr_stol)
      if arr_stol[l,5] == 0
        if (j := ascan(arr_otd[i,5], {|x| x[1] == arr_stol[l,1] })) == 0
          s += space(8)
        else
          s1 := ""
          if !empty(arr_otd[i,5,j,6])
            s1 += lstr(arr_otd[i,5,j,6])
            if !empty(arr_otd[i,5,j,7])
              s1 += "*"+lstr(arr_otd[i,5,j,7])
            endif
          endif
          if !empty(arr_otd[i,5,j,8])
            s1 += "+"+lstr(arr_otd[i,5,j,8])
            if !empty(arr_otd[i,5,j,9])
              s1 += "*"+lstr(arr_otd[i,5,j,9])
            endif
          endif
          s += padl(s1,8)
        endif
      endif
    next
    s1 := ""
    if !empty(arr_otd[i,6])
      s1 += lstr(arr_otd[i,6])
      if !empty(arr_otd[i,7])
        s1 += "*"+lstr(arr_otd[i,7])
      endif
    endif
    if !empty(arr_otd[i,8])
      s1 += "+"+lstr(arr_otd[i,8])
      if !empty(arr_otd[i,9])
        s1 += "*"+lstr(arr_otd[i,9])
      endif
    endif
    s += padl(s1,9)+space(4)
    for l := 1 to len(arr_stol)
      if arr_stol[l,5] == 1
        if (j := ascan(arr_otd[i,5], {|x| x[1] == arr_stol[l,1] })) == 0
          s += space(8)
        else
          s1 := ""
          if !empty(arr_otd[i,5,j,6])
            s1 += lstr(arr_otd[i,5,j,6])
            if !empty(arr_otd[i,5,j,7])
              s1 += "*"+lstr(arr_otd[i,5,j,7])
            endif
          endif
          if !empty(arr_otd[i,5,j,8])
            s1 += "+"+lstr(arr_otd[i,5,j,8])
            if !empty(arr_otd[i,5,j,9])
              s1 += "*"+lstr(arr_otd[i,5,j,9])
            endif
          endif
          s += padl(s1,8)
        endif
      endif
    next
    add_string(s)
  endif
next
add_string(replicate("═",sh))
s := padc("Итого:",30)
for j := 1 to len(arr_stol)
  if arr_stol[j,5] == 0
    s1 := lstr(arr_stol[j,3])
    if !empty(arr_stol[j,4])
      s1 += "+"+lstr(arr_stol[j,4])
    endif
    s += padl(s1,8)
  endif
next
s1 := lstr(k)
if !empty(k1)
  s1 += "+"+lstr(k1)
endif
if len(s1) < 9
  s += padl(s1,9)
else
  s += " "+s1
endif
s += space(4)
for j := 1 to len(arr_stol)
  if arr_stol[j,5] == 1
    s1 := lstr(arr_stol[j,3])
    if !empty(arr_stol[j,4])
      s1 += "+"+lstr(arr_stol[j,4])
    endif
    s += padl(s1,8)
  endif
next
add_string(s)
add_string(replicate("─",sh))
s := padc("(в %):",30)
for j := 1 to len(arr_stol)
  if arr_stol[j,5] == 0
    s += umest_val(arr_stol[j,3]/k*100,8,1)
  endif
next
add_string(s)
//
fclose(fp)
rest_box(buf)
if sh > 120
  Private yes_albom := .t.
endif
viewtext(name_file,,,,(sh>80),,,memPPsvod)
return NIL

*****
Function pr_otd_gosp_pp()
Local arr_m, i, j, l, k, k1, arr, begin_date, end_date, s, buf := save_maxrow(),;
      sh, HH := 58, reg_print, name_file := "pp_otd4"+stxt,;
      arr_otd := {}, arr_stol := {}, arr_title, atime, ak[12]
if (arr_m := year_month(T_ROW,T_COL-5,,,2,@atime)) == NIL
  return NIL
endif
//
mywait()
R_Use(dir_server+"mo_kpred",dir_server+"mo_kpred","KPR")
R_Use(dir_server+"mo_pp",dir_server+"mo_pp_d","HU")
dbseek(dtos(arr_m[5]),.t.)
afill(ak,0)
do while n_data <= arr_m[6] .and. !eof()
  if between_time(hu->n_data,hu->n_time,arr_m[5],atime[1],arr_m[6],atime[2]) ;
    .and. hu->is_gospit == 0   // только те, кто госпитализированы
    if (i := ascan(arr_otd, {|x| x[1] == hu->otd } )) == 0
      aadd(arr_otd, {hu->otd,;
                     inieditspr(6,dir_server+"mo_otd",hu->otd),;
                     0,0,;
                     0,0,;
                     0,0,;
                     0,0,;
                     0,0} )
      i := len(arr_otd)
    endif
    ++ arr_otd[i,3]
    ++ ak[3]
    select KPR
    find (str(hu->kod_k,7))
    if (found() .and. kpr->is_uhod == 1) .or. hu->novor > 0
      ++ arr_otd[i,4]
      ++ ak[4]
    endif
    for j := 1 to 4
      fl := .f.
      do case
        case j == 1 .and. hu->gospit0 == 0 // первично
          fl := .t.
        case j == 2 .and. hu->gospit0 == 1 // повторно
          fl := .t.
        case j == 3 .and. hu->gospit1 == 1 // экстренно
          fl := .t.
        case j == 4 .and. hu->gospit1 == 0 // в плановом порядке
          fl := .t.
      endcase
      if fl
        k := 4+j*2
        ++ arr_otd[i,k-1]
        ++ ak[k-1]
        if (kpr->(found()) .and. kpr->is_uhod == 1) .or. hu->novor > 0
          ++ arr_otd[i,k]
          ++ ak[k]
        endif
      endif
    next
  endif
  select HU
  skip
enddo
close databases
if ak[3] == 0
  rest_box(buf)
  return func_error(4,"Нет информации за указанный период времени!")
endif
//
asort(arr_otd,,,{|x,y| upper(x[2]) < upper(y[2]) } )
asort(arr_stol,,,{|x,y| upper(x[2]) < upper(y[2]) } )
arr_title := {;
"──────────────────────────────╥─────────╥────────────┬────────────┬────────────┬────────────",;
"         Наименование         ║Поступило║  первично  │  повторно  │ экстренно  │в планов.пор",;
"          отделения           ║в отделе-╟────────┬───┼────────┬───┼────────┬───┼────────┬───",;
"                              ║ние всего║ кол-во │ % │ кол-во │ % │ кол-во │ % │ кол-во │ % ",;
"──────────────────────────────╨─────────╨────────┴───┴────────┴───┴────────┴───┴────────┴───"}
reg_print := f_reg_print(arr_title,@sh)
//
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(alltrim(org->name))
org->(dbCloseArea())
add_string("")
add_string(center("Количество зарегистрированных стационарных больных",sh))
add_string(center(arr_m[4],sh))
add_string("")
aeval(arr_title, {|x| add_string(x) })
for i := 1 to len(arr_otd)
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  s := padr(alltrim(arr_otd[i,2]),30)
  s1 := lstr(arr_otd[i,3])
  if !empty(arr_otd[i,4])
    s1 += "+"+lstr(arr_otd[i,4])
  endif
  s += padl(s1,10)
  for j := 1 to 4
    k := 4+j*2
    s1 := iif(empty(arr_otd[i,k-1]), "", lstr(arr_otd[i,k-1]))
    if !empty(arr_otd[i,k])
      s1 += "+"+lstr(arr_otd[i,k])
    endif
    s += padl(s1,9)+" "+umest_val(arr_otd[i,k-1]/arr_otd[i,3]*100,3,1)
  next
  add_string(s)
next
add_string(replicate("─",sh))
s := padc("Итого:",30)
s1 := lstr(ak[3])
if !empty(ak[4])
  s1 += "+"+lstr(ak[4])
endif
s += padl(s1,10)
for j := 1 to 4
  k := 4+j*2
  s1 := iif(empty(ak[k-1]), "", lstr(ak[k-1]))
  if !empty(ak[k])
    s1 += "+"+lstr(ak[k])
  endif
  s += padl(s1,9)+" "+umest_val(ak[k-1]/ak[3]*100,3,1)
next
add_string(s)
//
fclose(fp)
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*****
Function pr_otd_vozr_pp()
Static spar := 1
Local arr_m, i, j, l, k, k1, arr, begin_date, end_date, s, buf := save_maxrow(),;
      sh, HH := 58, reg_print, name_file := "pp_otd5"+stxt,;
      arr_otd := {}, arr_title, atime, ak, vozrast,;
      mas_pmt := {"Все больные","Стационарные больные","Дневной стационар"}
if (par := popup_prompt(T_ROW,T_COL-5,spar,mas_pmt)) == NIL
  return NIL
endif
spar := par
if (arr_m := year_month(T_ROW,T_COL-5,,,2,@atime)) == NIL
  return NIL
endif
//
mywait()
R_Use(dir_server+"mo_kpred",dir_server+"mo_kpred","KPR")
R_Use(dir_server+"mo_kinos",dir_server+"mo_kinos","KIS")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"mo_pp",dir_server+"mo_pp_d","HU")
set relation to kod_k into KART
dbseek(dtos(arr_m[5]),.t.)
do while n_data <= arr_m[6] .and. !eof()
  fl := .t.
  if par == 2
    fl := (hu->reg_lech == 1)
  elseif par == 3
    fl := (hu->reg_lech > 1)
  endif
  if fl .and. between_time(hu->n_data,hu->n_time,arr_m[5],atime[1],arr_m[6],atime[2]) ;
    .and. hu->is_gospit == 0   // только те, кто госпитализированы
    if (i := ascan(arr_otd, {|x| x[1] == hu->otd } )) == 0
      aadd(arr_otd, {hu->otd,;    // 1
                     inieditspr(6,dir_server+"mo_otd",hu->otd),;  // 2
                     0,;  //  3    до 1 года
                     0,;  //  4    до 3 лет
                     0,;  //  5    > 3 лет
                     0,;  //  6    до 18 лет
                     0,;  //  7    с 18 до 60 лет
                     0,;  //  8    свыше 60 лет
                     0,;  //  9    всего
                     0,;  // 10  село
                     0,;  // 11  рабочий поселок
                     0,;  // 12  города обл.подчинения
                     0,;  // 13  Волгоград
                     0,;  // 14  Волжский
                     0} ) // 15  иногородние
      i := len(arr_otd)
    endif
    if left(kart_->okatog,5) == "18401" // Волгоград
      ++ arr_otd[i,13]
    elseif left(kart_->okatog,2) == "18"
      if left(kart_->okatog,5) == "18410" // г.Волжский
        ++ arr_otd[i,14]
      elseif eq_any(left(kart_->okatog,5),"18415","18420","18425","18428") // города обл.подч.
        ++ arr_otd[i,12]
      else  // село
        if kart_->GOROD_SELO == 3 // рабочий поселок
          ++ arr_otd[i,11]
        else
          ++ arr_otd[i,10]
        endif
      endif
    else // иногородние
      ++ arr_otd[i,15]
    endif
    ++ arr_otd[i,9]
    if hu->novor > 0
      count_ymd(hu->DATE_R2,hu->N_DATA,@vozrast)
    else
      count_ymd(kart->date_r,hu->N_DATA,@vozrast)
    endif
    if vozrast < 18
      ++ arr_otd[i,6]
    elseif vozrast < 60
      ++ arr_otd[i,7]
    else
      ++ arr_otd[i,8]
    endif
    if hu->novor > 0
      ++ arr_otd[i,3]
    else
      select KPR
      find (str(hu->kod_k,7))
      if found() .and. kpr->is_uhod == 1
        if vozrast < 1
          ++ arr_otd[i,3]
        elseif vozrast < 3
          ++ arr_otd[i,4]
        else
          ++ arr_otd[i,5]
        endif
      endif
    endif
  endif
  select HU
  skip
enddo
close databases
if len(arr_otd) == 0
  rest_box(buf)
  return func_error(4,"Нет информации за указанный период времени!")
endif
ak := array(15)
afill(ak,0)
for i := 1 to len(arr_otd)
  for j := 3 to 15
    ak[j] += arr_otd[i,j]
  next
next
//
asort(arr_otd,,,{|x,y| upper(x[2]) < upper(y[2]) } )
arr_title := {;
"───────────────────────────────╥─────────────────╥─────┬─────┬─────╥──────╥──────────────────────────────────",;
"         Наименование          ║ По уходу за реб.║ до  │от 18│свыше║      ║         Из них жители            ",;
"          отделения            ╟─────┬─────┬─────╢ 18  │до 60│ 60  ║ Всего╟────┬────┬───────┬─────┬────┬─────",;
"                               ║до 1г│1-3г.│>3лет║ лет │ лет │ лет ║      ║села│раб.│города │Волго│Волж│Иного",;
"                               ║     │     │     ║     │     │     ║      ║    │пос.│обл.под│град │cкий│родн. ",;
"───────────────────────────────╨─────┴─────┴─────╨─────┴─────┴─────╨──────╨────┴────┴───────┴─────┴────┴─────"}
reg_print := f_reg_print(arr_title,@sh)
//
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(alltrim(org->name))
org->(dbCloseArea())
add_string("")
add_string(center("Количество зарегистрированных стационарных больных",sh))
if par > 1
  add_string(center("[ "+mas_pmt[par]+" ]",sh))
endif
add_string(center(arr_m[4],sh))
add_string("")
aeval(arr_title, {|x| add_string(x) })
for i := 1 to len(arr_otd)
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  s := padr(alltrim(arr_otd[i,2]),30)
  s += put_val(arr_otd[i,3],6)
  s += put_val(arr_otd[i,4],6)
  s += put_val(arr_otd[i,5],6)
  s += put_val(arr_otd[i,6],6)
  s += put_val(arr_otd[i,7],6)
  s += put_val(arr_otd[i,8],6)
  s += put_val(arr_otd[i,9],7)
  s += put_val(arr_otd[i,10],6)
  s += put_val(arr_otd[i,11],5)
  s += put_val(arr_otd[i,12],6)
  s += put_val(arr_otd[i,13],8)
  s += put_val(arr_otd[i,14],5)
  s += put_val(arr_otd[i,15],6)
  add_string(s)
next
add_string(replicate("─",sh))
s := padc("Итого:",30)
s += put_val(ak[3],6)
s += put_val(ak[4],6)
s += put_val(ak[5],6)
s += put_val(ak[6],6)
s += put_val(ak[7],6)
s += put_val(ak[8],6)
s += put_val(ak[9],7)
s += put_val(ak[10],6)
s += put_val(ak[11],5)
s += put_val(ak[12],6)
s += put_val(ak[13],8)
s += put_val(ak[14],5)
s += put_val(ak[15],6)
add_string(s)
//
fclose(fp)
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*****
Function pr_otd_vozr_deti_pp()
Static spar := 1
Local arr_m, i, j, l, k, k1, arr, begin_date, end_date, s, buf := save_maxrow(),;
      s1, sh, HH := 58, reg_print, name_file := "pp_otd6"+stxt,;
      arr_otd := {}, arr_title, atime, ak, vozrast, mmonth,;
      mas_pmt := {"Все больные","Стационарные больные","Дневной стационар"}
if (par := popup_prompt(T_ROW,T_COL-5,spar,mas_pmt)) == NIL
  return NIL
endif
spar := par
if (arr_m := year_month(T_ROW,T_COL-5,,,2,@atime)) == NIL
  return NIL
endif
//
mywait()
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"mo_pp",dir_server+"mo_pp_d","HU")
set relation to kod_k into KART
dbseek(dtos(arr_m[5]),.t.)
do while n_data <= arr_m[6] .and. !eof()
  fl := .t.
  if par == 2
    fl := (hu->reg_lech == 1)
  elseif par == 3
    fl := (hu->reg_lech > 1)
  endif
  if hu->novor > 0
    count_ymd(hu->DATE_R2,hu->N_DATA,@vozrast,@mmonth)
  else
    count_ymd(kart->date_r,hu->N_DATA,@vozrast,@mmonth)
  endif
  fl := (fl .and. vozrast < 18)
  if fl .and. between_time(hu->n_data,hu->n_time,arr_m[5],atime[1],arr_m[6],atime[2]) ;
    .and. hu->is_gospit == 0   // только те, кто госпитализированы
    if (i := ascan(arr_otd, {|x| x[1] == hu->otd } )) == 0
      aadd(arr_otd, {hu->otd,;    // 1
                     inieditspr(6,dir_server+"mo_otd",hu->otd),;  // 2
                     0,;  //  3    в т.ч. до 6 месяцев
                     0,;  //  4    до 1 года
                     0,;  //  5    1-3 года
                     0,;  //  6    4-6 лет
                     0,;  //  7    7-10 лет
                     0,;  //  8    11-14 лет
                     0,;  //  9    15-17 лет
                     0;   // 10    всего
                    } )
      i := len(arr_otd)
    endif
    ++ arr_otd[i,10]
    if vozrast < 1
      ++ arr_otd[i,4]
      if mmonth < 6
        ++ arr_otd[i,3]
      endif
    elseif vozrast <= 3
      ++ arr_otd[i,5]
    elseif vozrast <= 6
      ++ arr_otd[i,6]
    elseif vozrast <= 10
      ++ arr_otd[i,7]
    elseif vozrast <= 14
      ++ arr_otd[i,8]
    else
      ++ arr_otd[i,9]
    endif
  endif
  select HU
  skip
enddo
close databases
if len(arr_otd) == 0
  rest_box(buf)
  return func_error(4,"Нет информации за указанный период времени!")
endif
ak := array(10)
afill(ak,0)
for i := 1 to len(arr_otd)
  for j := 3 to 10
    ak[j] += arr_otd[i,j]
  next
next
//
asort(arr_otd,,,{|x,y| upper(x[2]) < upper(y[2]) } )
arr_title := {;
"───────────────────────────────╥───────────╥─────┬─────┬─────┬─────┬─────╥──────",;
"         Наименование          ║ до 1 года ║ 1-3 │ 4-6 │ 7-10│11-14│15-17║      ",;
"          отделения            ╟─────┬─────╢ года│ лет │ лет │ лет │ лет ║ Всего",;
"                               ║до 6м│всего║     │     │     │     │     ║      ",;
"───────────────────────────────╨─────┴─────╨─────┴─────┴─────┴─────┴─────╨──────"}
reg_print := f_reg_print(arr_title,@sh)
//
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(alltrim(org->name))
org->(dbCloseArea())
add_string("")
add_string(center("Количество зарегистрированных стационарных больных",sh))
if par > 1
  add_string(center("[ "+mas_pmt[par]+" ]",sh))
endif
add_string(center(arr_m[4],sh))
add_string("")
aeval(arr_title, {|x| add_string(x) })
for i := 1 to len(arr_otd)
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  s := padr(alltrim(arr_otd[i,2]),30)
  s += put_val(arr_otd[i,3],6)
  s += put_val(arr_otd[i,4],6)
  s += put_val(arr_otd[i,5],6)
  s += put_val(arr_otd[i,6],6)
  s += put_val(arr_otd[i,7],6)
  s += put_val(arr_otd[i,8],6)
  s += put_val(arr_otd[i,9],6)
  s += put_val(arr_otd[i,10],7)
  add_string(s)
next
add_string(replicate("─",sh))
s := padc("Итого:",30)
s += put_val(ak[3],6)
s += put_val(ak[4],6)
s += put_val(ak[5],6)
s += put_val(ak[6],6)
s += put_val(ak[7],6)
s += put_val(ak[8],6)
s += put_val(ak[9],6)
s += put_val(ak[10],7)
add_string(s)
if ak[10] > 0
  s := space(37)
  for j := 4 to 9
    if ak[j] == 0
      s += space(6)
    else
      s1 := lstr(ak[j]/ak[10]*100,6,2)
      do while right(s1,1) == "0"
        s1 := left(s1,len(s1)-1)
      enddo
      do while len(s1) > 4
        s1 := left(s1,len(s1)-1)
      enddo
      if right(s1,1) == "."
        s1 := left(s1,len(s1)-1)
      endif
      s += padl(s1,5)+"%"
    endif
  next
  s += str(100,6)+"%"
  add_string(s)
endif
//
fclose(fp)
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

***** 10.09.17
Function pr_otd_tek_pp()
Static sdate, stime
Local arr_m, i, j, l, k, k1, arr, begin_date, end_date, s, buf := save_maxrow(),;
      sh, HH := 58, reg_print, name_file := "pp_otd7"+stxt,;
      arr_otd := {}, arr_title, tm, hGauge, fl_exit := .f.
DEFAULT sdate TO sys_date, stime TO "12:00"
Private mdate := sdate, mtime := stime
setcolor(cDataCGet)
buf := box_shadow(18,10,20,69)
fl := .f.
@ 19,16 say "Вывод информации по состоянию на" get mdate
@ row(),col() say "/"
@ row(),col() get mtime pict "99:99"
myread({"confirm"})
if lastkey() != K_ESC
  sdate := mdate
  stime := mtime
  fl := .t.
endif
setcolor(color0)
rest_box(buf)
if !fl
  return NIL
endif
dbcreate(cur_dir+"tmp1",{{"otd","N",3,0},;
                         {"n_data","D",8,0},;
                         {"n_time","C",5,0}})
dbcreate(cur_dir+"tmp",{{"kod","N",7,0},;
                        {"fio","C",50,0},;
                        {"n_data","D",8,0},;
                        {"k_data","D",8,0},;
                        {"n_time","C",5,0},;
                        {"is_per","L",1,0},;
                        {"otd","N",3,0},;
                        {"reg_lech","N",1,0}})
hGauge := GaugeNew(,,,"<Esc> - выход из режима",.t.)
GaugeDisplay( hGauge )
use (cur_dir+"tmp") new
index on str(otd,3)+dtos(n_data)+n_time to (cur_dir+"tmp")
use (cur_dir+"tmp1") new
index on dtos(n_data)+n_time to (cur_dir+"tmp1")
R_Use(dir_server+"mo_ppper",dir_server+"mo_ppper","HUP")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"mo_pp",,"HU")
set relation to kod_k into KART
go top
do while !eof()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  GaugeUpdate( hGauge, recno()/lastrec() )
  if hu->is_gospit == 0   // только те, кто госпитализированы
    mk_data := mdate+1 ; mk_time := mtime
    if !empty(hu->k_data)
      mk_data := hu->k_data ; mk_time := hu->k_time
    endif
    if between_time(mdate,mtime,hu->n_data,hu->n_time,mk_data,mk_time)
      motd := hu->otd
      select TMP
      append blank
      tmp->kod := hu->kod
      tmp->fio := kart->fio
      tmp->n_data := hu->n_data
      tmp->k_data := hu->k_data
      tmp->n_time := hu->n_time
      tmp->reg_lech := hu->reg_lech
      select HUP
      find (str(hu->kod,7))
      if found()
        select TMP1
        zap
        select HUP
        do while hup->kod == hu->kod .and. !eof()
          select TMP1
          append blank
          tmp1->otd    := hup->otd
          tmp1->n_data := hup->n_data
          tmp1->n_time := hup->n_time
          select HUP
          skip
        enddo
        select TMP1
        go top
        do while !eof()
          if between_time(mdate,mtime,tmp1->n_data,tmp1->n_time,mk_data,mk_time)
            motd := tmp1->otd
            tmp->is_per := .t.
          endif
          skip
        enddo
      endif
      tmp->otd := motd
      if tmp->(lastrec()) % 2000 == 0
        commit
      endif
      if (i := ascan(arr_otd, {|x| x[1] == motd } )) == 0
        aadd(arr_otd, {motd,;    // 1
                       inieditspr(6,dir_server+"mo_otd",motd),;  // 2
                       0,0} ) // 3    всего
        i := len(arr_otd)
      endif
      ++ arr_otd[i,3]
      if hu->reg_lech > 1
        ++ arr_otd[i,4]
      endif
    endif
  endif
  select HU
  skip
enddo
close databases
CloseGauge(hGauge) // Закроем окно отображения
if fl_exit
  return NIL
endif
if len(arr_otd) == 0
  return func_error(4,"Нет информации за указанный период времени!")
endif
asort(arr_otd,,,{|x,y| upper(x[2]) < upper(y[2]) } )
mas_pmt := {"Итого количество по отделениям"}
for i := 1 to len(arr_otd)
  aadd(mas_pmt, 'Список больных по "'+alltrim(arr_otd[i,2])+'"')
next
mybell()
buf := savescreen()
n := 0
aeval(mas_pmt,{|x| n := max(n,len(x)) } )
r1 := T_ROW ; c1 := T_COL-5
if (c2 := c1 + n + 3) > 77
  c1 := 77-3-n ; c2 := 77
endif
if (r2 := r1+len(mas_pmt)+1) > maxrow()-2
  r2 := maxrow()-2
endif
i := 1
do while (i := popup(r1,c1,r2,c2,mas_pmt,i,color0,.t.)) > 0
  if i == 1
    arr_title := {;
"─────────────────────────────────────────────────────┬──────┬──────",;
"                                                     │      │в т.ч.",;
"    Наименование отделения                           │Кол-во│дн/ст.",;
"─────────────────────────────────────────────────────┴──────┴──────"}
  else
    j := i-1
    arr_title := {;
"──────────────────────────────────────────────────┬──────────┬─────┬─────",;
"                    Ф.И.О.                        │ Дата по- │Время│     ",;
"                                                  │ступления │     │дн/ст",;
"──────────────────────────────────────────────────┴──────────┴─────┴─────"}
  endif
  reg_print := f_reg_print(arr_title,@sh)
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  R_Use(dir_server+"organiz",,"ORG")
  add_string(alltrim(org->name))
  org->(dbCloseArea())
  add_string("")
  add_string(center("Количество стационарных больных",sh))
  add_string(center("по состоянию на "+full_date(mdate)+" "+mtime,sh))
  if i > 1
    add_string(center('по отделению "'+alltrim(arr_otd[j,2])+'"',sh))
  endif
  add_string("")
  aeval(arr_title, {|x| add_string(x) })
  ss := ssd := 0
  if i == 1
    for j := 1 to len(arr_otd)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      s := padr(alltrim(arr_otd[j,2]),53)
      s += put_val(arr_otd[j,3],7)
      s += put_val(arr_otd[j,4],7)
      ss += arr_otd[j,3]
      ssd += arr_otd[j,4]
      add_string(s)
    next
    add_string(replicate("─",sh))
    s := padc("Итого:",53)
    s += put_val(ss,7)
    s += put_val(ssd,7)
    add_string(s)
  else
    use (cur_dir+"tmp") index (cur_dir+"tmp")
    find (str(arr_otd[j,1],3))
    do while tmp->otd == arr_otd[j,1] .and. !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      s := lstr(++ss)+". "+ltrim(tmp->fio)
      add_string(padr(s,51)+full_date(tmp->n_data)+" "+tmp->n_time+;
                 iif(tmp->reg_lech > 1, " дн/ст", ""))
      skip
    enddo
    use
  endif
  fclose(fp)
  viewtext(name_file,,,,(sh>80),,,reg_print)
enddo
restscreen(buf)
return NIL

***** 01.07.18 Просмотр/печать журнала регистрации стационарных больных по запросу
Function z_gurnal_pp()
Static mm_forma := {{"Полная форма",1},;
                    {"Сокращенная форма",2}}
Static mm_sort := {{"Сортировка по дате поступления",1},;
                   {"Сортировка по дате выбытия",11},;
                   {"Сортировка по Ф.И.О. больного",2},;
                   {"Начальная буква + дата поступления",3},;
                   {"Начальная буква + дата выбытия",31}}
Static mm_mest := {{"Волгоград или область",1},{"иногородние",2}}
Static spar := 1, spar2 := 1
Local mm_tmp := {}
Local buf := savescreen(), tmp_color := setcolor(cDataCGet), fl_exit := .f.,;
      tmp_help := help_code, hGauge, name_file := "stgurnal"+stxt,;
      sh, HH, i, j, k, tmp_file := "tmp_mn_p"+sdbf, arr_title, arr
//
Private arr_m, arr_mv, mm_company := {}, atime, atimev
aadd(mm_tmp, {"date_lech","N",4,0,NIL,;
              {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c,,,2,@atime),;
                      if(k==nil,nil,(arr_m:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION)},;
              0,{|| space(10) },;
              'Дата поступления'})
aadd(mm_tmp, {"date_vyb","N",4,0,NIL,;
              {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c,,,2,@atimev),;
                      if(k==nil,nil,(arr_mv:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION)},;
              0,{|| space(10) },;
              'Дата выбытия'})
aadd(mm_tmp, {"lforma","N",1,0,NIL,;
              {|x|menu_reader(x,mm_forma,A__MENUVERT)},;
              spar2,{|| inieditspr(A__MENUVERT,mm_forma,spar2) },;
              "Форма печати?"})
aadd(mm_tmp, {"lsort","N",2,0,NIL,;
              {|x|menu_reader(x,mm_sort,A__MENUVERT)},;
              spar,{|| inieditspr(A__MENUVERT,mm_sort,spar) },;
              "Вид сортировки?"})
aadd(mm_tmp, {"rab_nerab","N",2,0,NIL,;
              {|x|menu_reader(x,mmpp_rab,A__MENUBIT)},;
              0,{|x| inieditspr(A__MENUBIT,mmpp_rab,x) },;
              "Социальный статус"})
aadd(mm_tmp, {"mi_git","N",2,0,NIL,;
              {|x|menu_reader(x,mm_mest,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Место жительства:"})
aadd(mm_tmp, {"_okato","C",11,0,NIL,;
              {|x|menu_reader(x,;
                {{ |k,r,c| get_okato_ulica(k,r,c,{k,m_okato,}) }},A__FUNCTION)},;
              space(11),{|x| space(11)},;
              'Адрес регистрации (ОКАТО)'})
aadd(mm_tmp, {"adres","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "Улица (подстрока или шаблон)"})
aadd(mm_tmp, {"vid_opl","N",2,0,NIL,;
              {|x|menu_reader(x,menu_vid_opl,A__MENUBIT)},;
              0,{|x| inieditspr(A__MENUBIT,menu_vid_opl,x) },;
              "Вид оплаты"})
aadd(mm_tmp, {"komu","N",2,0,NIL,;
              {|x|menu_reader(x,mm_komu,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Принадлежность счёта",;
              {|g,o| f_valid_komu(g,o) }})
aadd(mm_tmp, {"company","N",5,0,NIL,;
              {|x|menu_reader(x,mm_company,A__MENUVERT)},;
              0,{|| space(10) },;
              "  ==>",,{||eq_any(m1komu,0,1,3)}})
aadd(mm_tmp, {"kem_dost","N",2,0,NIL,;
              {|x|menu_reader(x,mmpp_kem_dost,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Кем доставлен?"})
aadd(mm_tmp, {"polis","N",2,0,NIL,;
              {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
              -1,{|| space(3) },;
              "Полис введен?"})
aadd(mm_tmp, {"reg_lech","N",1,0,NIL,;
              {|x|menu_reader(x,mmpp_regim,A__MENUVERT)},;
              0,{|| space(10) },;
              "Режим лечения?"})
aadd(mm_tmp, {"uch_doc","C",10,0,"@!",;
              nil,;
              space(10),nil,;
              "№ истории болезни (шаблон)"})
aadd(mm_tmp, {"fio","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "ФИО (начальные буквы или шаблон)"})
aadd(mm_tmp, {"mr_dol","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "Место работы (подстрока или шаблон)"})
aadd(mm_tmp, {"pol","C",1,0,"!",;
              nil,;
              " ",nil,;
              "Пол", {|| mpol $ " МЖ" } })
aadd(mm_tmp, {"god_r_min","D",8,0,,;
              nil,;
              ctod(""),nil,;
              "Дата рождения (минимальная)"})
aadd(mm_tmp, {"god_r_max","D",8,0,,;
              nil,;
              ctod(""),nil,;
              "Дата рождения (максимальная)"})
delete file (tmp_file)
init_base(tmp_file,,mm_tmp,0)
k := f_edit_spr(A__APPEND,mm_tmp,"запросу для печати журнала",;
                "g_use(cur_dir+'tmp_mn_p',,,.t.,.t.)",0,1,,,,,"wr_mn_pp")
close databases
restscreen(buf)
setcolor(tmp_color)
if k > 0
  mywait()
  use (tmp_file) new alias MN
  spar := mn->lsort
  spar2 := mn->lforma
  if spar2 == 1
    arr_title := {;
     "─────┬─────┬──────────────────┬──────────┬──────────────────┬────────────────────┬───────────────┬───────────────┬───────────────╥──────────┬──────────┬───────────────────────╥─────",;
     " NN  │Дата,│ Фамилия, имя,    │   Дата   │ Паспорт и полис  │ Постоянное место   │Каким учрежде- │№ ист.болезни и│Диагноз напра- ║Выписан,  │Отметка о │Если не был госпитализ.║Приме",;
     " пп  │время│ отчество больного│ рождения │                  │ жительства,        │нием направлен,│отделение, куда│вившего учр-ия;║переведен │сообщении ├────────────┬──────────╢чание",;
     "     │пост.│                  │ и возраст│                  │ место работы       │кем доствлен   │помещен больной│приемного отд-я║в др.стац.│родственн.│причина/меры│отказ в пр║     ",;
     "─────┴─────┴──────────────────┴──────────┴──────────────────┴────────────────────┴───────────────┴───────────────┴───────────────╨──────────┴──────────┴────────────┴──────────╨─────";
    }
    sh := len(arr_title[1]) ; HH := 54 ; reg_print := 6
    Private yes_albom := .t.
    //
    Private a01[10], a02[10], a03[10], a04[10], a05[10], a06[10], a07[10], ;
            a08[10], a09[10], a10[10], a11[10]
    Private k01, k02, k03, k04, k05, k06, k07, k08, k09, k10, k11
    Private sh01 := 5, sh02 := 5, sh03 := 18, sh04 := 10, sh05 := 18, ;
            sh06 := 20, sh07 := 15, sh08 := 15, sh09 := 15
    Private arr_center := {2,4,10}
    afill(a01,"") ; k01 := 1
    afill(a02,"") ; k02 := 2
    afill(a03,"")
    afill(a04,"")
    afill(a05,"")
    afill(a06,"")
    afill(a07,"")
    afill(a08,"")
    afill(a09,"")
    kol := 9
  else
    arr_title := {;
     "─────┬───────────┬─────────┬──────────────────────────┬────────────────────┬──────────",;
     " NN  │Дата, время│№ истории│  Фамилия, имя, отчество  │    Наименование    │   Дата   ",;
     " пп  │поступления│  болезни│        больного          │      отделения     │  выписки ",;
     "─────┴───────────┴─────────┴──────────────────────────┴────────────────────┴──────────";
    }
    sh := len(arr_title[1]) ; HH := 80 ; reg_print := 5
    //
    Private a04[10], a05[10], k04, k05
    Private sh01 := 5, sh02 := 11, sh03 := 9, sh04 := 26, sh05 := 20
    afill(a04,"")
    afill(a05,"")
    kol := 9
  endif
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  R_Use(dir_server+"organiz",,"ORG")
  add_string(padr(org->name,sh-15)+padl("форма №001/у",15))
  add_string("")
  add_string(center("Журнал учета приема больных и отказов в госпитализации",sh))
  if !empty(mn->date_lech)
    add_string(center("Дата поступления: "+arr_m[4],sh))
  endif
  if !empty(mn->date_vyb)
    add_string(center("Дата выбытия: "+arr_mv[4],sh))
  endif
  //
  Private much_doc := "", mfio := "", madres := "", mmr_dol := ""
  if !empty(mn->rab_nerab)
    add_string("- социальный статус: "+inieditspr(A__MENUBIT, mmpp_rab, mn->rab_nerab))
  endif
  if mn->mi_git > 0
    add_string("- место жительства: "+inieditspr(A__MENUVERT, mm_mest, mn->mi_git))
  endif
  if !empty(mn->_okato)
    add_string("- адрес регистрации (ОКАТО): "+ret_okato_ulica('',mn->_okato))
  endif
  if !empty(mn->adres)
    madres := alltrim(mn->adres)
    if !(left(madres,1) == "*")
      madres := "*"+madres
    endif
    if !(right(madres,1) == "*")
      madres += "*"
    endif
    add_string("- улица: "+madres)
  endif
  if !empty(mn->mr_dol)
    mmr_dol := alltrim(mn->mr_dol)
    if !(left(mmr_dol,1) == "*")
      mmr_dol := "*"+mmr_dol
    endif
    if !(right(mmr_dol,1) == "*")
      mmr_dol += "*"
    endif
    add_string("- место работы: "+mmr_dol)
  endif
  if !empty(mn->vid_opl)
    add_string("- вид оплаты: "+inieditspr(A__MENUBIT, menu_vid_opl, mn->vid_opl))
  endif
  if mn->komu >= 0
    add_string("- принадлежность счёта: "+;
               inieditspr(A__MENUVERT, mm_komu, mn->komu))

    if mn->company > 0
      add_string("  ==> "+;
                 inieditspr(A__MENUVERT, mm_company, mn->company))
    endif
  endif
  if mn->kem_dost >= 0
    add_string("- кем доставлен: "+inieditspr(A__MENUVERT, mmpp_kem_dost, mn->kem_dost))
  endif
  if mn->polis >= 0
    add_string("- полис "+iif(mn->polis==1,"ВВЕДЕН","НЕ ВВЕДЕН"))
  endif
  if mn->reg_lech > 0
    add_string("- режим лечения: "+inieditspr(A__MENUVERT, mmpp_regim, mn->reg_lech))
  endif
  if !empty(mn->uch_doc)
    much_doc := alltrim(mn->uch_doc)
    if !(right(much_doc,1) == "*")
      much_doc += "*"
    endif
    add_string("- № истории болезни: "+much_doc)
  endif
  if !empty(mn->fio)
    mfio := alltrim(mn->fio)
    if !(right(mfio,1) == "*")
      mfio += "*"
    endif
    add_string("- ФИО: "+mfio)
  endif
  if !empty(mn->pol)
    add_string("- пол: "+mn->pol)
  endif
  if !empty(mn->god_r_min) .or. !empty(mn->god_r_max)
    if empty(mn->god_r_min)
      add_string("- лица, родившиеся до "+full_date(mn->god_r_max))
    elseif empty(mn->god_r_max)
      add_string("- лица, родившиеся после "+full_date(mn->god_r_min))
    else
      add_string("- лица, родившиеся с "+;
                 full_date(mn->god_r_min)+" по "+full_date(mn->god_r_max))
    endif
  endif
  aeval(arr_title, {|x| add_string(x) })
  Private c_view := 0, c_found := 0
  R_Use(dir_server+"mo_kpred",dir_server+"mo_kpred","KPR")
  R_Use(dir_server+"mo_kinos",dir_server+"mo_kinos","KIS")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART_
  R_Use(dir_server+"mo_ppdia",dir_server+"mo_ppdia","HUS")
  R_Use(dir_server+"mo_pp",,"HU")
  set relation to kod_k into KART
  if empty(mn->date_lech)
    select HU
    index on dtos(k_data) to (cur_dir+"tmp_pp") for !empty(k_data) progress
    dbseek(dtos(arr_mv[5]),.t.)
    do case
      case spar == 11
        index on dtos(k_data)+k_time+upper(kart->fio) to (cur_dir+"tmp_hu") ;
              while k_data <= arr_mv[6]
      case spar == 2
        index on upper(kart->fio)+dtos(k_data)+k_time to (cur_dir+"tmp_hu") ;
              while k_data <= arr_mv[6]
      case spar == 31
        index on upper(left(kart->fio,1))+dtos(k_data)+k_time to (cur_dir+"tmp_hu") ;
              while k_data <= arr_mv[6]
    endcase
  else
    select HU
    set index to (dir_server+"mo_pp_d")
    dbseek(dtos(arr_m[5]),.t.)
    do case
      case spar == 1
        index on dtos(n_data)+n_time+upper(kart->fio) to (cur_dir+"tmp_hu") ;
              while n_data <= arr_m[6]
      case spar == 2
        index on upper(kart->fio)+dtos(n_data)+n_time to (cur_dir+"tmp_hu") ;
              while n_data <= arr_m[6]
      case spar == 3
        index on upper(left(kart->fio,1))+dtos(n_data)+n_time to (cur_dir+"tmp_hu") ;
              while n_data <= arr_m[6]
    endcase
  endif
  k := 0
  WaitStatus("<Esc> - прервать операцию")
  go top
  do while !eof()
    if (fl_exit := (inkey()==K_ESC))
      add_string(expand("ПРОЦЕСС ПРЕРВАН"))
      exit
    endif
    UpdateStatus()
    if spar == 1
      @ 24,1 say full_date(hu->n_data)+" "+hu->n_time color "G+/R"
    else
      @ 24,1 say padr(fam_i_o(kart->fio),25) color "G+/R"
    endif
    fl := .t.
    if fl .and. !empty(mn->date_lech)
      fl := between_time(hu->n_data,hu->n_time,arr_m[5],atime[1],arr_m[6],atime[2])
    endif
    if fl .and. !empty(mn->date_vyb)
      fl := !empty(hu->k_data) .and. ;
            between_time(hu->k_data,hu->k_time,arr_mv[5],atimev[1],arr_mv[6],atimev[2])
    endif
    if fl .and. pp_mnog_poisk()
      ++k
      if spar2 == 1
        // 1 - номер по порядку
        a01[1] := str(k,5)
        // 2 - дата и время поступления
        a02[1] := left(full_date(hu->N_DATA),5)
        a02[2] := hu->N_TIME
        // 3 - ФИО больного
        k03 := perenos(a03,kart->fio,sh03)
        // 4 - дата рождения и возраст
        s := full_date(kart->date_r)+" "+count_ymd(kart->date_r,hu->N_DATA)
        k04 := perenos(a04,s,sh04)
        // 5 - паспорт и полис
        s := ""
        if (i := ascan(menu_vidud, {|x| x[2] == kart_->VID_UD})) > 0
          s := menu_vidud[i,4]
        endif
        s += " " + alltrim(kart_->SER_UD)
        s += " " + alltrim(kart_->NOM_UD)+"; "
        if !empty(kart->polis)
          s += "полис: "+make_polis(kart_->spolis,kart_->npolis)+" "
        endif
        s += alltrim(f4_view_list_schet(hu->komu,cut_code_smo(kart_->smo),hu->str_crb))
        k05 := perenos(a05,s,sh05)
        // 6 - адрес
        s := rtrim(inieditspr(A__MENUVERT, mm_gorod_selo, kart_->gorod_selo))+", "
        s += iif(emptyall(kart_->okatog,kart->adres), "",;
                 ret_okato_ulica(kart->adres,kart_->okatog))
        if !empty(kart->mr_dol)
          s += "; "+alltrim(kart->mr_dol)
        endif
        k06 := perenos(a06,s,sh06)
        // 7 - кем направлен и кем доставлен
        s := ""
        if !empty(hu->kem_napr)
          s += ret_mo(hu->kem_napr)[_MO_SHORT_NAME]
        endif
        s += iif(empty(s), "", ", ")+;
             alltrim(inieditspr(A__MENUVERT, mmpp_kem_dost, hu->KEM_DOST))
        k07 := perenos(a07,s,sh07)
        // 8 - отделение, в которое помещен больной
        s := "№ "+alltrim(hu->UCH_DOC)+"; "
        s += inieditspr(6,dir_server+"mo_otd",hu->otd)
        k08 := perenos(a08,s,sh08)
        // 9 - диагноз направившего учреждения
        MDIAG_NAPR := MDIAG_PR_P := MPOB_D_LEK := ""
        select HUS
        find (str(hu->kod,7))
        do while hus->kod == hu->kod .and. !eof()
          do case
            case hus->tip == 1
              MDIAG_NAPR := alltrim(hus->name) // диагноз направившего учреждения
            case hus->tip == 2
              MDIAG_PR_P := alltrim(hus->name) // диагноз приемного отделения
            case hus->tip == 3
              MPOB_D_LEK := alltrim(hus->name) // побочное действие лекарств
          endcase
          skip
        enddo
        s := iif(empty(mDIAG_NAPR), "-", mDIAG_NAPR)+"; "+;
             iif(empty(mDIAG_PR_P), "-", mDIAG_PR_P)
        k09 := perenos(a09,s,sh09)
        //
        kk := 1
        for i := 1 to kol
          pole := "k"+strzero(i,2)
          kk := max(kk,&pole)
        next
        kk := min(kk,10)
        if verify_FF(HH-kk,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        for j := 1 to kk
          s := ""
          for i := 1 to kol
            pole := "a"+strzero(i,2)
            ss := &pole.[j]
            pole := "sh"+strzero(i,2)
            if ascan(arr_center,i) > 0
              ss := padc(alltrim(ss),&pole)
            else
              ss := padr(alltrim(ss),&pole)
            endif
            s += ss+" "
          next
          if j == 1  // в первой строке
            s += padr(full_date(hu->K_DATA),10)+" " // Выписан, переведен в др.стацион.
            if hu->novor > 0
              s += padc("новорожден",10)+" "
            else
              select KPR
              find (str(hu->kod_k,7))
              s += padc(iif(found().and.kpr->is_uhod==1,"по уходу",""),10)+" " //сообщение родственникам
            endif
            if hu->is_gospit == 1
              s1 := "не госпитализирован"
              s += padr(s1,12+1+10+1)
            else
              s += space(12)+" "   //причина/меры
              s += space(10)+" "   //отказ в пр
            endif
            s += substr(inieditspr(6,dir_server+"mo_ppst",hu->stol),1,5) //Примечание
          elseif j == 2  // во второй строке
            if !empty(hu->k_data)
              s += padc(hu->N_TIME,11)
            else
              s += space(11)
            endif
            s += space(11)
            s1 := ""
            if hu->is_gospit == 1 .and. hu->pr_gospit > 0
              s1 := inieditspr(A__MENUVERT, mmpp_pr_gospit, hu->pr_gospit)
            endif
            s += padr(s1,12+1+10+1)
            if hu->ishod2 == 6  // умер
              s += "УМЕР"
            else
              s += substr(inieditspr(6,dir_server+"mo_ppst",hu->stol),6,5) //Примечание
            endif
          endif
          add_string(s)
        next
        select KIS
        find (str(hu->kod_k,7))
        if found() // иностранец
          f_gur_inostr_pp(sh)
        endif
      else
        // 1 - номер по порядку
        s := str(k,5)+" "
        // 2 - дата и время поступления
        s += left(full_date(hu->N_DATA),5)+" "+hu->N_TIME+" "
        // 3 - история болезни
        s += hu->UCH_DOC
        // 3 - ФИО больного
        k04 := perenos(a04,kart->fio,sh04)
        s += padr(a04[1],sh04+1)
        // 5 - отделение, в которое помещен больной
        k05 := perenos(a05,inieditspr(6,dir_server+"mo_otd",hu->otd),sh05)
        s += padr(a05[1],sh05+1)
        s += full_date(hu->K_DATA)
        kk := min(max(k04,k05),10)
        if verify_FF(HH-kk,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        add_string(s)
        for j := 2 to kk
          s := space(sh01+1+sh02+1+sh03+1)
          s += padr(a04[j],sh04+1)
          s += padr(a05[j],sh05+1)
          add_string(s)
        next
        select KIS
        find (str(hu->kod_k,7))
        if found() // иностранец
          f_gur_inostr_pp(sh)
        endif
        if kk == 1
          add_string("")
        endif
      endif
    endif
    select HU
    skip
  enddo
  close databases
  fclose(fp)
  restscreen(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL

***** 31.08.14
Function wr_mn_pp(k)
Local fl := .t.
if k == 1
  if emptyall(mdate_lech,mdate_vyb)
    fl := func_error(4,"Обязательно должно быть заполнено хотя бы одно поле даты!")
  endif
  if fl .and. empty(mdate_lech) .and. eq_any(m1lsort,1,3)
    fl := func_error(4,"Вид сортировки не соответствует выбранной дате!")
  endif
  if fl .and. empty(mdate_vyb) .and. eq_any(m1lsort,11,31)
    fl := func_error(4,"Вид сортировки не соответствует выбранной дате!")
  endif
endif
return fl

***** 01.07.18
Static Function pp_mnog_poisk()
Local i, j, fl := .t.
if fl .and. mn->rab_nerab > 0
  fl := .f.
  for i := 1 to len(mmpp_rab)
    j := mmpp_rab[i,2]
    if isbit(mn->rab_nerab,j) .and. isbit(hu->rab_nerab,j)
      fl := .t. ; exit
    endif
  next
endif
if fl .and. mn->vid_opl > 0
  fl := .f.
  for i := 1 to len(menu_vid_opl)
    j := menu_vid_opl[i,2]
    if isbit(mn->vid_opl,j) .and. isbit(hu->vid_opl,j)
      fl := .t. ; exit
    endif
  next
endif
if fl .and. mn->mi_git > 0
  if mn->mi_git == 1
    fl := (left(kart_->okatog,2)=='18')
  else
    fl := !(left(kart_->okatog,2)=='18')
  endif
endif
if fl .and. !empty(mn->_okato)
  s := mn->_okato
  for i := 1 to 3
    if right(s,3)=='000'
      s := left(s,len(s)-3)
    else
      exit
    endif
  next
  fl := (left(kart_->okatog,len(s))==s)
endif
if fl .and. mn->komu >= 0
  if mn->company == 0
    fl := (mn->komu==hu->komu)
  elseif mn->komu == 0
    fl := (int(val(cut_code_smo(kart_->smo)))==mn->company)
  else
    fl := (mn->komu==hu->komu .and. mn->company==hu->str_crb)
  endif
endif
if fl .and. mn->kem_dost >= 0
  fl := (hu->KEM_DOST == mn->kem_dost)   // кем доставлен
endif
if fl .and. mn->polis >= 0
  if mn->polis == 1
    fl := !empty(kart->polis)
  else
    fl := empty(kart->polis)
  endif
endif
if fl .and. mn->reg_lech > 0
  fl := (hu->reg_lech == mn->reg_lech)
endif
if fl .and. !empty(much_doc)
  fl := like(much_doc,hu->uch_doc)
endif
if fl .and. !empty(mfio)
  fl := like(mfio,upper(kart->fio))
endif
if fl .and. !empty(madres)
  fl := like(madres,upper(kart->adres))
endif
if fl .and. !empty(mmr_dol)
  fl := like(mmr_dol,upper(kart->mr_dol))
endif
if fl .and. !empty(mn->pol)
  fl := (kart->pol == mn->pol)
endif
if fl .and. !empty(mn->god_r_min)
  fl := (mn->god_r_min <= kart->date_r)
endif
if fl .and. !empty(mn->god_r_max)
  fl := (kart->date_r <= mn->god_r_max)
endif
return fl

*****
Function f_gur_inostr_pp(sh)
Local i, s, arr[2], mSTRANA := ini_strana(kart_->strana)
if !empty(mSTRANA)
  s := 'страна: "'+alltrim(mSTRANA)+'"' // страна
  if !empty(kis->ADRES_PRO)
    s += ', адрес проживания в Волг.обл.: "'+alltrim(kis->ADRES_PRO)+'"'
  endif
  if !empty(kis->MIGR_KARTA)
    s += ', миграционная карта: "'+alltrim(kis->MIGR_KARTA)+'"'
  endif
  if !empty(kis->DATE_P_G)
    s += ', дата пересечения границы: "'+full_date(kis->DATE_P_G)+'"'
  endif
  if !empty(kis->DATE_R_M)
    s += ', дата регистрации в миграционной службе: "'+full_date(kis->DATE_R_M)+'"'
  endif
  for i := 1 to perenos(arr,s,sh-6)
    add_string(space(6)+arr[i])
  next
endif
return NIL

*****
Function pr_perevod_pp()
Local arr_m, i, j, l, k, k1, begin_date, end_date, s, buf := save_maxrow(),;
      sh := 81, HH := 58, reg_print := 2, name_file := "pp_perev"+stxt,;
      arr, atime
if (arr_m := year_month(T_ROW,T_COL-5,,,2,@atime)) == NIL
  return NIL
endif
//
mywait()
dbcreate(cur_dir+"tmp",{{"kod", "N",7,0},;
                {"otd1","N",3,0},;
                {"stol1","N",3,0},;
                {"N_DATA"   ,   "D",     8,     0},; // дата перевода
                {"N_TIME"   ,   "C",     5,     0},; // время перевода
                {"otd2","N",3,0},;
                {"stol2","N",3,0},;
                {"rec", "N",7,0}})
use (cur_dir+"tmp") new
R_Use(dir_server+"mo_pp",,"HU")
R_Use(dir_server+"mo_ppper",,"PER")
index on str(kod,7) to (cur_dir+"tmp_per") for between(n_data,arr_m[5],arr_m[6])
go top
do while !eof()
  if between_time(per->n_data,per->n_time,arr_m[5],atime[1],arr_m[6],atime[2])
    select TMP
    append blank
    tmp->kod    := per->kod
    tmp->N_DATA := per->N_DATA
    tmp->N_TIME := per->N_TIME
    tmp->otd2   := per->otd
    tmp->stol2  := per->stol
    tmp->rec    := per->(recno())
  endif
  select PER
  skip
enddo
if (k := tmp->(lastrec())) > 0
  select PER
  set index to (dir_server+"mo_ppper")
  select TMP
  go top
  do while !eof()
    arr := {}
    select PER
    find (str(tmp->kod,7))
    do while per->kod == tmp->kod .and. !eof()
      aadd(arr, {per->n_data,per->n_time,per->(recno()),per->otd,per->stol})
      skip
    enddo
    asort(arr,,,{|x,y| iif(x[1]==y[1], x[2] < y[2], x[1] < y[1]) })
    if (j := ascan(arr, {|x| x[3] == tmp->rec })) > 1  // если переводился до этого
      tmp->otd1 := arr[j-1,4]
      tmp->stol1 := arr[j-1,5]
    else  // не было ни одного перевода до этого
      hu->(dbGoto(tmp->kod))
      tmp->otd1 := hu->otd
      tmp->stol1 := hu->stol
    endif
    select TMP
    skip
  enddo
endif
close databases
if k == 0
  rest_box(buf)
  return func_error(4,"Нет информации за указанный период времени!")
endif
//
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(alltrim(org->name))
org->(dbCloseArea())
add_string("")
add_string(center("Список больных, переведенных в другие отделения",sh))
add_string(center(arr_m[4],sh))
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"mo_pp",,"HU")
set relation to kod_k into KART
use (cur_dir+"tmp") new
set relation to kod into HU
index on dtos(n_data)+n_time to (cur_dir+"tmp")
j := 0
go top
do while !eof()
  verify_FF(HH,.t.,sh)
  add_string("")
  add_string(lstr(++j)+". "+alltrim(kart->fio)+" (№"+alltrim(hu->uch_doc)+" "+;
             dtoc(hu->n_data)+" "+hu->n_time+")")
  s := space(len(lstr(j))+2)+;
       'из "'+padr(inieditspr(6,dir_server+"mo_otd",tmp->otd1),31)
  if tmp->stol1 > 0
    s += '" (стол '+alltrim(inieditspr(A__POPUPMENU,dir_server+"mo_ppst",tmp->stol1))+")"
  endif
  add_string(s)
  s := space(len(lstr(j))+2)+;
       ' в "'+padr(inieditspr(6,dir_server+"mo_otd",tmp->otd2),31)
  if tmp->stol2 > 0
    s += '" (стол '+alltrim(inieditspr(A__POPUPMENU,dir_server+"mo_ppst",tmp->stol2))+")"
  endif
  s += " "+dtoc(tmp->n_data)+" "+tmp->n_time
  add_string(s)
  select TMP
  skip
enddo
//
fclose(fp)
close databases
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*****
Function pr_error_pp(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j, uch_otd
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Дубликаты в ~историях болезни"}
    mas_msg := {"Поиск дубликатов в историях болезни"}
    mas_fun := {"pr_error_pp(12)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    dubl_ist_b_pp()
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
Function dubl_ist_b_pp()
Local g1, j := 0, k := 0, sh := 80, HH := 80, n_file := "dubl_ist"+stxt
dbcreate(cur_dir+"tmp",{{"N_DATA","D",8,0},; // дата поступления
                        {"kol","N",6,0}})
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("Дубликаты историй болезни",sh))
add_string(center("по состоянию на "+full_date(sys_date),sh))
add_string("")
use (cur_dir+"tmp") new
index on dtos(n_data) to (cur_dir+"tmp")
R_Use(dir_server+"mo_pp",dir_server+"mo_pp_r","HU")
R_Use(dir_server+"kartotek",dir_server+"kartoten","KART")
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
hGauge := GaugeNew(,,,"",.t.)
GaugeDisplay( hGauge )
go top
do while !eof()
  GaugeUpdate( hGauge, ++j/lastrec() )
  UpdateStatus()
  if inkey() == K_ESC
    exit
  endif
  if kart->kod > 0
    fl := .f. ; old_data := stod("20100101")
    select HU
    find (str(kart->kod,7))
    do while hu->kod_k == kart->kod .and. !eof()
      if old_data == hu->n_data
        fl := .t. ; exit
      endif
      old_data := hu->n_data
      skip
    enddo
    if fl
      select TMP
      zap
      select HU
      find (str(kart->kod,7))
      do while hu->kod_k == kart->kod .and. !eof()
        select TMP
        find (dtos(hu->n_data))
        if !found()
          append blank
          tmp->n_data := hu->n_data
        endif
        tmp->kol ++
        select HU
        skip
      enddo
      commit
      verify_FF(HH-4, .t., sh)
      add_string("")
      add_string(lstr(++k)+". "+alltrim(kart->fio))
      select TMP
      go top
      do while !eof()
        if tmp->kol > 1
          add_string("")
          select HU
          find (str(kart->kod,7)+dtos(tmp->n_data))
          do while hu->kod_k == kart->kod .and. hu->n_data == tmp->n_data .and. !eof()
            add_string(space(10)+"№ "+hu->UCH_DOC+" "+;
                                 full_date(hu->n_data)+" "+;
                                 hu->n_time+" "+;
                                 inieditspr(A__POPUPMENU,dir_server+"mo_otd",hu->otd))
            skip
          enddo
        endif
        select TMP
        skip
      enddo
    endif
  endif
  @ 24,1 say lstr(j) color "W+/R"
  @ row(),col() say "/" color "W/R"
  @ row(),col() say lstr(k) color "G+/R"
  select KART
  skip
enddo
CloseGauge(hGauge)
close databases
if k > 0
  viewtext(n_file,,,,.f.,,,5)
endif
return NIL
