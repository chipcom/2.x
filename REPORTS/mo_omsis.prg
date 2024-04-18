** mo_omsis.prg - информация по ОМС (по счетам)
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 30.03.23
Function s3_statist(k3,k4)
// k3 = 1 - Список счетов
// k3 = 2 - С объединением по принадлежности
// k3 = 3 - С разбивкой по отделениям
// k3 = 4 - С разбивкой по службам
//   k4 = 1 - С разбивкой по отделениям (где выписан счет)
//   k4 = 2 - С разбивкой по отделениям (где оказана услуга)
Local arr_g, buf := save_maxrow(), ind_human, ind_schet, mname,;
      i, j, s, fl, sh, HH := 57, arr_title, reg_print, ;
      name_file := cur_dir + 'spisok_s' + stxt, pp[8], old_smo, old_komu, old_str_crb, ;
      arr_bukva := {}, hGauge, cur_rec := 0, fl_exit := .f.

pi4 := k3
DEFAULT k4 TO 2
Private ccount := 0, fl_opl
afill(pp,0)
Store 0 to p1sum, p1kol, p2sum, p2kol, pj, old_komu, old_str_crb
if (arr_g := year_month(,,.f.)) == NIL
  return NIL
endif
if pds==2 .and. !(arr_g[5]==bom(arr_g[5]) .and. arr_g[6]==eom(arr_g[6]))
  return func_error(4,"Запрашиваемый период должен быть кратен месяцу")
endif
mywait()
if R_Use(dir_server + "human_",,"HUMAN_") .and. ;
    R_Use(dir_server + "human",dir_server + "humans","HUMAN") .and. ;
     R_Use(dir_server + "human_u",dir_server + "human_u","HU") .and. ;
       R_Use(dir_server + "mo_otd",,"OTD") .and. ;
        R_Use(dir_server + "slugba",dir_server + "slugba","SL") .and. ;
         R_Use(dir_server + "uslugi",dir_server + "uslugi","USL") .and. ;
          R_Use(dir_server + "schet_",,"SCHET_") .and. ;
            R_Use(dir_server + "schet",dir_server + "schetd","SCHET")
  Private atmp_os[8], arr_uch[8]
  afill(atmp_os,0) ; afill(arr_uch,0)
  if k3 > 2
    s33_statist(k3,k4)
  endif
  arr_title := s31_statist(k3,k4)
  reg_print := f_reg_print(arr_title,@sh)
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  if k3 > 2
    add_string(center("Разбивка по "+;
                      if(k3==3,"отделениям","службам")+" счетов",sh))
  else
    add_string(center(expand("СПИСОК СЧЕТОВ"),sh))
  endif
  if pds == 1
    s := "дата выписки счетов"
  elseif pds == 2
    s := "отчетный период"
  else
    s := "дата регистрации счетов"
  endif
  add_string(center("[ "+s+" "+arr_g[4]+" ]",sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  //
  select HUMAN
  set relation to recno() into HUMAN_
  select SCHET
  set relation to recno() into SCHET_
  set filter to empty(schet_->IS_DOPLATA)
  if pds == 1
    dbseek(arr_g[7],.t.)
    if k3 == 2  // с объединением по принадлежности
      index on schet_->smo+iif(empty(schet_->smo),str(komu,1)+str(str_crb,2),;
                                                  str(0,1)+str(0,2))+;
                            pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir + "tmp") ;
            while pdate <= arr_g[8]
    else
      index on pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir + "tmp") ;
                                                      while pdate <= arr_g[8]
    endif
  elseif pds == 2
    if k3 == 2  // с объединением по принадлежности
      index on schet_->smo+iif(empty(schet_->smo),str(komu,1)+str(str_crb,2),;
                                                  str(0,1)+str(0,2))+;
                            pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir + "tmp") ;
            for between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_g[5],arr_g[6])
    else
      index on pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir + "tmp") ;
            for between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_g[5],arr_g[6])
    endif
  else
    if k3 == 2  // с объединением по принадлежности
      index on schet_->smo+iif(empty(schet_->smo),str(komu,1)+str(str_crb,2),;
                                                  str(0,1)+str(0,2))+;
                            pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir + "tmp") ;
        for schet_->NREGISTR==0 .and. between(date_reg_schet(),arr_g[5],arr_g[6])
    else
      index on pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir + "tmp") ;
        for schet_->NREGISTR==0 .and. between(date_reg_schet(),arr_g[5],arr_g[6])
    endif
  endif
  select SCHET
  go top
  do while !eof()
    if k3 > 2  // разноска по отделениям или службам
      s34_statist(k3,k4)
    endif
    if k3 < 3  // список счетов
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      jh := js := 0
      select HUMAN
      find (str(schet->kod,6))
      do while human->schet == schet->kod .and. !eof()
        if human_->oplata == 3
          js += human->cena_1 - human_->sump ; jh++
        elseif eq_any(human_->oplata,2,9)
          js += human->cena_1 ; jh++
        endif
        skip
      enddo
      arr_uch[3] += schet->summa
      arr_uch[4] += schet->kol
      arr_uch[5] += js
      arr_uch[6] += jh
      if !empty(schet_->BUKVA)
        if (j := ascan(arr_bukva, {|x| x[2]==schet_->BUKVA .and. empty(x[7])})) == 0
          aadd(arr_bukva, {"",schet_->BUKVA,0,0,0,0,""}) ; j := len(arr_bukva)
        endif
        arr_bukva[j,3] += schet->summa
        arr_bukva[j,4] += schet->kol
        arr_bukva[j,5] += js
        arr_bukva[j,6] += jh
      endif
      if k3 == 2
        fl := .f.
        if empty(schet_->smo)
          fl := !(schet->komu==old_komu .and. schet->str_crb==old_str_crb)
        else
          fl := !(schet_->smo==old_smo)
          if !empty(schet_->BUKVA)
            if (j := ascan(arr_bukva, {|x| x[2]==schet_->BUKVA .and. x[7]==schet_->smo})) == 0
              aadd(arr_bukva, {"",schet_->BUKVA,0,0,0,0,schet_->smo}) ; j := len(arr_bukva)
            endif
            arr_bukva[j,3] += schet->summa
            arr_bukva[j,4] += schet->kol
            arr_bukva[j,5] += js
            arr_bukva[j,6] += jh
          endif
        endif
        if fl
          if pj > 0
            add_string(space(21)+replicate("=",sh-21))
            add_string(padl("Итого:",30)+;
                       put_val(pp[4],6)+put_kopE(pp[3],13)+;
                       put_val(pp[6],6)+put_kopE(pp[5],13))
            if !empty(old_smo)
              asort(arr_bukva, , , {|x, y| x[2] < y[2] })
              fl := .t.
              for i := 1 to len(arr_bukva)
                if arr_bukva[i, 7] == old_smo
                  if fl
                    add_string(replicate('-', sh))
                  endif
                  s := padl(iif(fl, 'в т.ч. ', ''), 30) + ;
                       put_val(arr_bukva[i, 4], 6) + put_kopE(arr_bukva[i, 3], 13) + ;
                       put_val(arr_bukva[i, 6], 6) + put_kopE(arr_bukva[i, 5], 13) + ' '
                  if (j := ascan(get_bukva(), {|x| x[2] == arr_bukva[i, 2]})) > 0
                    s += get_bukva()[j, 1]
                  else
                    s += arr_bukva[i, 2]
                  endif
                  add_string(s)
                  fl := .f.
                endif
              next
            endif
            add_string('')
          endif
          pj := 0 ; afill(pp,0)
        endif
        pj++
        pp[3] += schet->summa
        pp[4] += schet->kol
        pp[5] += js
        pp[6] += jh
        old_smo := schet_->smo
        old_komu := schet->komu ; old_str_crb := schet->str_crb
      endif
      add_string(schet_->nschet+" "+date_8(schet_->dschet)+" "+;
                 put_otch_period()+;
                 put_val(schet->kol,6)+put_kopE(schet->summa,13)+;
                 put_val(jh,6)+put_kopE(js,13)+;
                 " "+f4_view_list_schet())
    endif
    select SCHET
    skip
  enddo
  if k3 == 2
    if pj > 0
      add_string(space(21)+replicate("=",sh-21))
      add_string(padl("Итого:",30)+;
                 put_val(pp[4],6)+put_kopE(pp[3],13)+;
                 put_val(pp[6],6)+put_kopE(pp[5],13))
      if !empty(old_smo)
        asort(arr_bukva, , , {|x, y| x[2] < y[2] })
        fl := .t.
        for i := 1 to len(arr_bukva)
          if arr_bukva[i, 7] == old_smo
            if fl
              add_string(replicate('-', sh))
            endif
            s := padl(iif(fl, 'в т.ч. ', ''), 30) + ;
                 put_val(arr_bukva[i, 4], 6) + put_kopE(arr_bukva[i, 3], 13) + ;
                 put_val(arr_bukva[i, 6], 6) + put_kopE(arr_bukva[i, 5], 13) + ' '
            if (j := ascan(get_bukva(), {|x| x[2] == arr_bukva[i, 2]})) > 0
              s += get_bukva()[j, 1]
            else
              s += arr_bukva[i, 2]
            endif
            add_string(s)
            fl := .f.
          endif
        next
      endif
      add_string('')
    endif
  endif
  if k3 > 2  // разбивка по отд. и службам
    s35_statist(k4,,sh,HH,arr_title)
  else
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(replicate("=",sh))
    if arr_uch[3] > 0
      add_string(padl("Итого : ",30)+;
                 put_val(arr_uch[4],6)+put_kopE(arr_uch[3],13)+;
                 put_val(arr_uch[6],6)+put_kopE(arr_uch[5],13))
      asort(arr_bukva,,,{|x,y| x[2] < y[2] })
      fl := .t.
      for i := 1 to len(arr_bukva)
        if empty(arr_bukva[i, 7])
          if fl
            add_string(replicate('-', sh))
          endif
          s := padl(iif(fl, 'в т.ч. ', ''), 30) + ;
               put_val(arr_bukva[i, 4], 6) + put_kopE(arr_bukva[i, 3], 13) + ;
               put_val(arr_bukva[i, 6], 6) + put_kopE(arr_bukva[i, 5], 13) + ' '
          if (j := ascan(get_bukva(),{|x| x[2] == arr_bukva[i, 2]})) > 0
            s += get_bukva()[j, 1]
          else
            s += arr_bukva[i, 2]
          endif
          add_string(s)
          fl := .f.
        endif
      next
    endif
  endif
  close databases
  fclose(fp)
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
close databases
rest_box(buf)
return NIL

**
Static Function add_tmp_os(_sum,_kol,_sum1,_kol1)
if !emptyall(_sum1,_kol1)
  atmp_os[5] += _sum1 ; arr_uch[5] += _sum1
  atmp_os[6] += _kol1 ; arr_uch[6] += _kol1
endif
atmp_os[3] += _sum ; arr_uch[3] += _sum
atmp_os[4] += _kol ; arr_uch[4] += _kol
return NIL

**
Static Function s31_statist(k3,k4)
Local arr_title
DEFAULT k4 TO 2
if k3 < 3
  arr_title := {;
    "───────────────┬────────┬─────╥─────┬────────────╥─────┬────────────╥─────────────────────────────────",;
    "               │ Дата   │Отчёт║ Кол.│            ║ Кол.│Сумма снятий║                                 ",;
    "  Номер счета  │ счета  │перио║больн│ Сумма счёта║снято│  по актам  ║      Принадлежность счета       ",;
    "───────────────┴────────┴─────╨─────┴────────────╨─────┴────────────╨─────────────────────────────────"}
elseif k4 == 1
  arr_title := {;
    "───────────────────╥───────────────────╥─────────────────────────────────",;
    "  Больных в счёте  ║   Снято с оплаты  ║                                 ",;
    "──────┬────────────╫──────┬────────────╢                                 ",;
    "Кол-во│ Сумма счёта║Кол-во│Сумма снятия║      Наименования отделений     ",;
    "──────┴────────────╨──────┴────────────╨─────────────────────────────────"}
else
  arr_title := {;
    "───────────────────╥───────────────────╥─────────────────────────────────",;
    "   Услуг в счёте   ║   Снято с оплаты  ║                                 ",;
    "──────┬────────────╫──────┬────────────╢                                 ",;
    "Кол-во│ Сумма счёта║Кол-во│Сумма снятия║      Наименования "+iif(k3==3,"отделений","служб"),;
    "──────┴────────────╨──────┴────────────╨─────────────────────────────────"}
endif
return arr_title

**
Static Function s33_statist(k3,k4)
Local j, arr_os := {}
dbcreate(cur_dir + "tmp_os", {{"kod","N",3,0},{"name","C",30,0},;
                    {"p3","N",17,2},{"p4","N",7,0},;
                    {"p5","N",17,2},{"p6","N",7,0}} )
use (cur_dir + "tmp_os") new
index on str(kod,3) to (cur_dir + "tmp_os")
if k3 == 3  // С разбивкой по отделениям
  otd->( dbeval({|| aadd(arr_os, {kod,name}) }))
  asort(arr_os,,,{|x,y| x[2] < y[2] } )
  aeval(arr_os, {|x| tmp_os->(__dbAppend()),;
                     tmp_os->kod := x[1],;
                     tmp_os->name := x[2] } )
else        // С разбивкой по службам
  sl->( dbeval({|| aadd(arr_os, {shifr,name} ) } ) )
  asort(arr_os,,,{|x,y| x[2] < y[2] } )
  aeval(arr_os, {|x| tmp_os->(__dbAppend()),;
                     tmp_os->kod := x[1],;
                     tmp_os->name := x[2] } )
endif
return NIL

**
Static Function s34_statist(k3,k4)
Local fl, js, k, p
DEFAULT k4 TO 2
select HUMAN
find (str(schet->kod,6))
do while human->schet == schet->kod .and. !eof()
  UpdateStatus()
  js := k := 0 ; p := 1
  if human_->oplata == 3
    js := human->cena_1 - human_->sump
    ++k
    p := js/human->cena_1
  elseif eq_any(human_->oplata,2,9)
    js := human->cena_1
    ++k
  endif
  if k4 == 1
    tmp_os->(dbSeek(str(human->otd,3)))
    if tmp_os->(found())
      if !empty(js)
        tmp_os->p5 += js            ; arr_uch[5] += js
        tmp_os->p6 ++               ; arr_uch[6] ++
      endif
        tmp_os->p3 += human->cena_1 ; arr_uch[3] += human->cena_1
        tmp_os->p4 ++               ; arr_uch[4] ++
    else
      add_tmp_os(human->cena_1,1,js,k)
    endif
  else
    select HU
    find (str(human->kod,7))
    do while hu->kod == human->kod .and. !eof()
      fl := .f.
      if k3 == 3
        tmp_os->(dbSeek(str(hu->otd,3)))
        fl := tmp_os->(found())
      elseif k3 == 4
        select USL
        find (str(hu->u_kod,4))
        if found()
          tmp_os->(dbSeek(str(usl->slugba,3)))
          fl := tmp_os->(found())
        endif
      endif
      if fl
        if !empty(js)
          tmp_os->p5 += p*hu->stoim_1 ; arr_uch[5] += p*hu->stoim_1
          tmp_os->p6 += p*hu->kol_1   ; arr_uch[6] += p*hu->kol_1
        endif
          tmp_os->p3 += hu->stoim_1   ; arr_uch[3] += hu->stoim_1
          tmp_os->p4 += hu->kol_1     ; arr_uch[4] += hu->kol_1
      else
        if empty(js)
          add_tmp_os(hu->stoim_1,hu->kol_1,0,0)
        else
          add_tmp_os(hu->stoim_1,hu->kol_1,p*hu->stoim_1,p*hu->kol_1)
        endif
      endif
      select HU
      skip
    enddo
  endif
  select HUMAN
  skip
enddo
return NIL

**
Static Function s35_statist(k4,_1,sh,HH,arr_title)
Local i, mname, n := 6
select TMP_OS
set index to
go top
do while !eof()
  if tmp_os->p3 > 0
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    mname := alltrim(tmp_os->name)
    add_string(put_val(tmp_os->p4,n)+put_kopE(tmp_os->p3,13)+" "+;
               put_val(tmp_os->p6,n)+put_kopE(tmp_os->p5,13)+" "+mname)
  endif
  select TMP_OS
  skip
enddo
if atmp_os[3] > 0
  mname := ".. расхождение из-за неудачного поиска"
  add_string(put_val(atmp_os[4],n)+put_kopE(atmp_os[3],13)+" "+;
             put_val(atmp_os[6],n)+put_kopE(atmp_os[5],13)+" "+mname)
endif
add_string(replicate("─",sh))
if arr_uch[3] > 0
  add_string(put_val(arr_uch[4],6)+put_kopE(arr_uch[3],13)+" "+;
             put_val(arr_uch[6],6)+put_kopE(arr_uch[5],13))
endif
return NIL

** информация по конкретному счету
Function s4_statist()
Local buf := savescreen(), buf24 := save_maxrow(), i, j, arr_blk,;
  sh := 108, HH := 57, reg_print := 3, name_file := cur_dir + 'infschet' + stxt
Private atmp_os[8], arr_uch[8]
if input_schet(0)
  WaitStatus()
  if R_Use(dir_server + "human_",,"HUMAN_") .and. ;
      R_Use(dir_server + "human",dir_server + "humans","HUMAN") .and. ;
       R_Use(dir_server + "human_u",dir_server + "human_u","HU") .and. ;
        R_Use(dir_server + "mo_otd",,"OTD") .and. ;
         R_Use(dir_server + "slugba",dir_server + "slugba","SL") .and. ;
          R_Use(dir_server + "uslugi",dir_server + "uslugi","USL") .and. ;
           R_Use(dir_server + "schet_",,"SCHET_") .and. ;
            R_Use(dir_server + "schet",,"SCHET")
    set relation to recno() into SCHET_
    goto (glob_schet)
    if schet->lpu > 0
      glob_uch[1] := schet->lpu
      glob_uch[2] := inieditspr(A__POPUPMENU,dir_server + "mo_uch",schet->lpu)
    endif
    Private p_number := alltrim(schet_->nschet),;
            p_date := schet_->dschet,;
            str_kriterij := func_kriterij()
    select HUMAN
    set relation to recno() into HUMAN_
    fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
    add_string("")
    add_string("Счет № "+alltrim(p_number)+" от "+dtoc(p_date)+"г.")
    if schet->lpu > 0
      add_string("ЛПУ: "+glob_uch[2])
    endif
    add_string(f4_view_list_schet())
    add_string("")
    add_string("Разноска по отделениям")
    arr_title := s31_statist(3,2)
    reg_print := f_reg_print(arr_title,@sh)
    aeval(arr_title, {|x| add_string(x) } )
    afill(atmp_os,0) ; afill(arr_uch,0)
    s33_statist(3,2)
    s34_statist(3,2)
    s35_statist(2,,sh,HH,arr_title)
    tmp_os->(dbCloseArea())
    add_string("")
    add_string("Разноска по службам")
    arr_title := s31_statist(4,2)
    aeval(arr_title, {|x| add_string(x) } )
    afill(atmp_os,0) ; afill(arr_uch,0)
    s33_statist(4,2)
    s34_statist(4,2)
    s35_statist(2,,sh,HH,arr_title)
    fclose(fp)
    //
    str_find := str(glob_schet,6)
    muslovie := "human->schet == glob_schet"
    arr_blk := {{|| FindFirst(str_find)},;
                {|| FindLast(str_find)},;
                {|n| SkipPointer(n, muslovie)},;
                str_find,muslovie;
               }
    select HUMAN
    find (str_find)
    Alpha_Browse(7,2,maxrow()-2,77,"s41_statist",color1,;
           "Список больных из счета","G+/B",.f.,.t.,arr_blk,,"s42_statist",,;
           {'═','░','═',"W+/B,N/W,GR+/B,GR+/R",.t.,300} )
  endif
  close databases
  rest_box(buf24)
endif
restscreen(buf)
return NIL

**
Function s41_statist(oBrow)
Local oColumn, n := 34, blk_color := {|| iif(eq_any(human_->oplata,2,3,9), {3,4}, {1,2}) }
oColumn := TBColumnNew(center("Ф.И.О. больного",n),{|| left(human->fio,n) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Начало;лечения",{|| date_8(human->n_data)})
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Оконч.;лечения",{|| date_8(human->k_data)})
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Сумма лечения", ;
                          {|| padl(expand_value(human->cena_1,2),14) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" ",{|| iif(eq_any(human_->oplata,2,9), "снятие", ;
                                   iif(human_->oplata==3,"частич",space(6))) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
status_key("^<Esc>^ - выход;  ^<F9>^ - информация о счете")
return NIL

**
Function s42_statist(nKey,oBrow)
Local buf, rec, k := -1
if nkey == K_F9
  viewtext("infschet"+stxt,,,,.t.,,,3)
endif
return k

** для ТФОМС (по ф.14)
Function s5_statist()
Local si := 1
Local begin_date, end_date, buf := save_maxrow(), arr_m, mstr_crb, ltip
if (ltip := popup_prompt(T_ROW,T_COL-5,si,;
               {"По ~всем больным","В том числе по ~детям"})) == 0
  return NIL
endif
si := ltip
if (arr_m := year_month()) == NIL .or. menu_schet_akt() == 0
  return NIL
endif
if pds == 2
  Private mdate_reg
  if !is_otch_period(arr_m)
    return NIL
  elseif !ret_date_reg_otch_period()
    return NIL
  endif
endif
begin_date := arr_m[7]
end_date := arr_m[8]
//
mywait()
//
adbf := {{"KOMU"     ,   "N",     1,     0},; // от 1 до 5
         {"STR_CRB"  ,   "N",     2,     0},; // код стр.компании, комитета и т.п.
         {"NKOMU"    ,   "C",    60,     0},;
         {"SMO"      ,   "C",     5,     0},; // код СМО
         {"LPU"      ,   "N",     2,     0},;
         {"NLPU"     ,   "C",    30,     0},;
         {"KOL_BOLN" ,   "N",     6,     0},;
         {"SUMMA"    ,   "N",    13,     2},;
         {"is","N",1,0}}
dbcreate(cur_dir + "tmp_smo",adbf)
use (cur_dir + "tmp_smo") new alias TMP
index on smo to (cur_dir + "tmp_smo1")
index on nkomu to (cur_dir + "tmp_smo2")
set index to (cur_dir + "tmp_smo1"),(cur_dir + "tmp_smo2")
R_Use(dir_server + "schet_",,"SCHET_")
R_Use(dir_server + "schet",dir_server + "schetd","SCHET")
set relation to recno() into SCHET_
set filter to empty(schet_->IS_DOPLATA)
if pds == 1
  dbseek(begin_date,.t.)
  index on pdate to (cur_dir + "tmp_s") while pdate <= end_date
elseif pds == 2
  if mdate_reg == NIL
    index on pdate to (cur_dir + "tmp_s") ;
          for between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_m[5],arr_m[6])
  else
    index on pdate to (cur_dir + "tmp_s") ;
          for between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_m[5],arr_m[6]) ;
                 .and. schet_->NREGISTR==0 .and. date_reg_schet() <= mdate_reg
  endif
else
  index on pdate to (cur_dir + "tmp_s") ;
        for schet_->NREGISTR==0 .and. between(date_reg_schet(),arr_m[5],arr_m[6])
endif
go top
do while !eof()
  if !empty(val(schet_->smo))
    select TMP
    find (schet_->smo)
    if !found()
      append blank
      replace tmp->smo with schet_->smo,;
              tmp->is with iif(int(val(schet_->smo))==34, 0, 1)
    endif
    tmp->kol_boln += schet->kol
    tmp->summa += schet->summa
  endif
  select SCHET
  skip
enddo
if tmp->(lastrec()) == 0
  rest_box(buf)
  func_error(4,"Нет счетов за указанный период времени!")
else
  schet->(dbCloseArea())
  select TMP
  dbeval({|| tmp->nkomu := f4_view_list_schet(0,tmp->smo,0) })
  set order to 2
  go top
  if Alpha_Browse(T_ROW,0,23,79,"s51statist",color0,;
                  "Счета "+arr_m[4],"R/BG",,,,,;
                  "s52statist",,{'═','░','═',"N/BG,W+/N,B/BG,W+/B",,0} )
    close databases
    s53statist(ltip, arr_m, begin_date, end_date)
  endif
  rest_box(buf)
endif
close databases
return NIL

**
Function s51statist(oBrow)
Local oColumn, blk := {|| iif (tmp->is==1, {1,2}, {3,4}) }
oColumn := TBColumnNew(" ", {|| if(tmp->is==1,""," ")})
oBrow:addColumn(oColumn)
oColumn:colorBlock := blk
oColumn := TBColumnNew(center("Принадлежность счета",35),{|| left(tmp->nkomu,35)})
oBrow:addColumn(oColumn)
oColumn:colorBlock := blk
oColumn := TBColumnNew(" Кол.; бол.", {|| str(tmp->kol_boln,6) })
oBrow:addColumn(oColumn)
oColumn:colorBlock := blk
oColumn := TBColumnNew(" Сумма счета", {|| put_kop(tmp->summa,13) })
oBrow:addColumn(oColumn)
oColumn:colorBlock := blk
oColumn := TBColumnNew(" ", {|| if(tmp->is==1,""," ")})
oBrow:addColumn(oColumn)
oColumn:colorBlock := blk
status_key("^<Esc>^ - выход;  ^<Enter>^ - подсчет;  ^<Ins><+><->^ - отметить СМО для подсчета")
return NIL

**
Function s52statist(nKey,oBrow)
Local ret := 0
do case
  case nKey == 45  // минус
    rec := tmp->(recno())
    tmp->( dbeval({|| tmp->is := 0 } ))
    tmp->(dbGoto(rec))
    ret := 0
  case nKey == 43  // плюс
    rec := tmp->(recno())
    tmp->( dbeval({|| tmp->is := 1 } ))
    tmp->(dbGoto(rec))
    ret := 0
  case nKey == K_INS
    tmp->is := iif(tmp->is == 1, 0, 1)
    oBrow:down()
    ret := 0
endcase
return ret

// 02.02.24
Function s53statist(ltip, arr_m, begin_date, end_date)
Local i, j, k, s, buf := save_maxrow(), arr, mstr_crb, mismo,;
      fl_exit := .f., sh := 80, HH := 59, reg_print := 2, lshifr1,;
      arr_title, name_file := cur_dir + 'tfomsf14' + stxt, flag_uet := .t., koef,;
      kol_schet := 0, lreg_lech, ta, arr_name := f14tf_array(),;
      arr_lp := {}, arr_dn_st, d2_year
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
adbf := {{"tip","N",2,0},;
         {"shifr","C",10,0},;
         {"u_name","C",120,0},;
         {"kol","N",11,3},;
         {"uet","N",11,4},;
         {"sum","N",16,2}}
dbcreate(cur_dir + "tmp",adbf)
use (cur_dir + "tmp") new alias TMP
index on str(tip,2)+shifr to (cur_dir + "tmp")
use (cur_dir + "tmp_smo") index (cur_dir + "tmp_smo1") new alias TMP_SMO
R_Use(dir_server + "uslugi",,"USL")
R_Use(dir_server + "human_u",dir_server + "human_u","HU")
set relation to u_kod into USL
R_Use(dir_server + "human_",,"HUMAN_")
R_Use(dir_server + "human",dir_server + "humans","HUMAN")
set relation to recno() into HUMAN_
R_Use(dir_server + "schet_",,"SCHET_")
R_Use(dir_server + "schet",dir_server + "schetd","SCHET")
set relation to recno() into SCHET_
set filter to empty(schet_->IS_DOPLATA) .and. !empty(val(schet_->smo))
if pds == 1
  dbseek(begin_date,.t.)
  index on pdate to (cur_dir + "tmp_s") while pdate <= end_date
elseif pds == 2
  if mdate_reg == NIL
    index on pdate to (cur_dir + "tmp_s") ;
          for between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_m[5],arr_m[6])
  else
    index on pdate to (cur_dir + "tmp_s") ;
          for between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_m[5],arr_m[6]) ;
                 .and. schet_->NREGISTR==0 .and. date_reg_schet() <= mdate_reg
  endif
else
  index on pdate to (cur_dir + "tmp_s") ;
        for schet_->NREGISTR==0 .and. between(date_reg_schet(),arr_m[5],arr_m[6])
endif
as := array(10,3) ; afillall(as,0)
s_stac := sdstac := s_amb := s_kt := s_smp := 0
go top
do while !eof()
  @ maxrow(),0 say padr("№ "+alltrim(schet_->nschet)+" от "+;
                        date_8(schet_->dschet),25) color "W/R"
  select TMP_SMO
  find (schet_->smo)
  if found() .and. tmp_smo->is == 1
    select HUMAN
    find (str(schet->kod,6))
    do while human->schet == schet->kod
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if iif(ltip == 1, .t., human->VZROS_REB > 0) ;
                                   .and. f_usl_schet_akt(human_->oplata)
        koef := 1
        if glob_schet_akt == 2 .and. human_->oplata == 3
          koef := human_->sump/human->cena_1
        endif
        d2_year := year(human->k_data)
        lreg_lech := {0,0,0,0,0}
        select HU
        find (str(human->kod,7))
        do while hu->kod == human->kod .and. !eof()
          lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          if f_paraklinika(usl->shifr,lshifr1,human->k_data)
            lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
            ta := f14tf_nastr(lshifr,,d2_year)
            for j := 1 to len(ta)
              k := ta[j,1]
              if between(k,1,10) .and. ta[j,2] >= 0
                i := 2                // остальные - амбулаторно
                if k == 2             // k := 2 - койко-дни
                  i := 1
                elseif between(k,3,5) // k := 3,4,5 - дневной стационар
                  i := 3
                elseif k == 7
                  i := 4
                elseif k == 8
                  i := 5
                endif
                ++ lreg_lech[i]
              endif
            next
          endif
          select HU
          skip
        enddo
        if lreg_lech[1] > 0
          ++s_stac
        elseif lreg_lech[3] > 0
          ++sdstac
        elseif lreg_lech[4] > 0
          ++s_kt
        elseif lreg_lech[5] > 0
          ++s_smp
        else
          ++s_amb
        endif
        arr_dn_st := {"","",0}
        select HU
        find (str(human->kod,7))
        do while hu->kod == human->kod .and. !eof()
          lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          if f_paraklinika(usl->shifr,lshifr1,human->k_data)
            s := lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
            lname := alltrim(usl->name)
            ta := f14tf_nastr(@lshifr,@lname,d2_year)
            lshifr := padr(lshifr,10)
            for j := 1 to len(ta)
              k := ta[j,1]
              if between(k,1,10)
                if ta[j,2] == 1 // законченный случай
                  mkol := human->k_data - human->n_data // койко-день
                  if between(ta[j,1],3,5) // дневной стационар до 1 апреля
                    ++mkol
                  endif
                  if (i := ascan(arr_lp, {|x| x[1] == lshifr })) == 0
                    aadd(arr_lp, {lshifr,{}}) ; i := len(arr_lp)
                  endif
                  if (i1 := ascan(arr_lp[i,2], {|x| x[1] == s })) == 0
                    aadd(arr_lp[i,2], {s,0,0}) ; i1 := len(arr_lp[i,2])
                  endif
                  arr_lp[i,2,i1,2] += mkol
                  arr_lp[i,2,i1,3] ++
                elseif ta[j,2] == 0
                  mkol := hu->kol_1
                  if between(ta[j,1],3,5) // дневной стационар после 1 апреля
                    arr_dn_st[2] := lshifr
                    arr_dn_st[3] := mkol
                  endif
                else
                  mkol := 0
                  if between(ta[j,1],3,5) // дневной стационар после 1 апреля
                    arr_dn_st[1] := lshifr
                  endif
                endif
                if year(human->k_data) > 2012 .and. hu->kol_rcp < 0 ;
                                              .and. DomUslugaTFOMS(lshifr)
                  s := iif(hu->kol_rcp==-1,"на дому","домАКТИВ")
                  if (i := ascan(arr_lp, {|x| x[1] == lshifr })) == 0
                    aadd(arr_lp, {lshifr,{}}) ; i := len(arr_lp)
                  endif
                  if (i1 := ascan(arr_lp[i,2], {|x| x[1] == s })) == 0
                    aadd(arr_lp[i,2], {s,0,0}) ; i1 := len(arr_lp[i,2])
                  endif
                  arr_lp[i,2,i1,2] += mkol
                  arr_lp[i,2,i1,3] ++
                endif
                muet := 0
                msum := hu->stoim_1*koef
                if between(k,9,10)  // УЕТ для стоматологий
                  muet := round_5(mkol * ret_tfoms_uet(usl->shifr,lshifr1,human->vzros_reb), 4)
                endif
                select TMP
                find (str(k,2)+padr(lshifr,10))
                if !found()
                  append blank
                  tmp->tip := k
                  tmp->shifr := lshifr
                  tmp->u_name := lname
                endif
                tmp->kol += mkol
                tmp->uet += muet
                tmp->sum += msum
                as[k,1] += mkol
                as[k,2] += muet
                as[k,3] += msum
              else
                k := 11
                select TMP
                find (str(k,2)+padr(lshifr,10))
                if !found()
                  append blank
                  tmp->tip := k
                  tmp->shifr := lshifr
                  tmp->u_name := lname
                endif
                tmp->kol += hu->kol_1
                tmp->sum += hu->stoim_1*koef
              endif
            next
          endif
          select HU
          skip
        enddo
        // дневной стационар с 1 апреля 2013 года
        if !emptyany(arr_dn_st[1],arr_dn_st[2],arr_dn_st[3])
          if (i := ascan(arr_lp, {|x| x[1] == arr_dn_st[1] })) == 0
            aadd(arr_lp, {arr_dn_st[1],{}}) ; i := len(arr_lp)
          endif
          if (i1 := ascan(arr_lp[i,2], {|x| x[1] == arr_dn_st[2] })) == 0
            aadd(arr_lp[i,2], {arr_dn_st[2],0,0}) ; i1 := len(arr_lp[i,2])
          endif
          arr_lp[i,2,i1,2] += arr_dn_st[3]
          arr_lp[i,2,i1,3] ++
        endif
      endif
      select HUMAN
      skip
    enddo
  endif
  select SCHET
  skip
enddo
//
arr_title := {;
"──────────────────────────────────────────────────────────┬──────┬──────────────",;
"                                                          │Кол-во│  Стоимость   ",;
"                                                          │ услуг│    услуг     ",;
"──────────────────────────────────────────────────────────┴──────┴──────────────"}
arr1title := {;
"─────────────────────────────────────────────────┬──────┬────────┬──────────────",;
"                                                 │Кол-во│        │  Стоимость   ",;
"                                                 │ услуг│ У.Е.Т. │    услуг     ",;
"─────────────────────────────────────────────────┴──────┴────────┴──────────────"}
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
if ltip == 2
  add_string(center("[ в том числе по детям ]",sh))
endif
add_string(padc("Данные для заполнения формы N 14 (в ТФОМС) [старая]",sh))
if pds == 1
  s := "дата выписки счетов"
elseif pds == 2
  s := "отчетный период"
else
  s := "дата регистрации счетов"
endif
add_string(center("[ "+s+" "+arr_m[4]+" ]",sh))
if pds == 2 .and. mdate_reg != NIL
  add_string(center("[ по счетам, зарегистрированным по "+full_date(mdate_reg)+"г. включительно ]",sh))
endif

add_string( Center( title_schet_akt( glob_schet_akt ), sh ) )

add_string("")
add_string("Всего листов учета: "+lstr(s_stac+sdstac+s_amb+s_kt+s_smp))
add_string("       в том числе стационарно: "+lstr(s_stac))
add_string("                   амбулаторно: "+lstr(s_amb))
add_string("             дневной стационар: "+lstr(sdstac))
add_string("  отдельные медицинские услуги: "+lstr(s_kt))
add_string("           вызов скорой помощи: "+lstr(s_smp))
add_string("")
aeval(arr1title, {|x| add_string(x) } )
s1 := s2 := s3 := 0
for i := 1 to 10
  if !emptyall(as[i,1],as[i,2],as[i,3])
    k := perenos(ta,arr_name[i],49)
    if i == 6
      add_string(padr(ta[1],49)+str(as[i,1],7,0))
    else
      add_string(padr(ta[1],49)+str(as[i,1],7,0)+;
                                put_val_0(as[i,2],9,1)+;
                                put_kopE(as[i,3],15))
    endif
    for j := 2 to k
      add_string(padl(alltrim(ta[j]),49))
    next
    s1 += as[i,1]
    s2 += as[i,2]
    s3 += as[i,3]
  endif
next
add_string(replicate("─",sh))
add_string("")
add_string(center("Расшифровка по услугам",sh))
select TMP
index on str(tip,2)+fsort_usl(shifr) to (cur_dir + "tmp")
for i := 1 to 11
  if i < 9 .or. i == 11
    ta := arr_title
  else
    ta := arr1title
  endif
  find (str(i,2))
  if found()
    verify_FF(HH-8,.t.,sh)
    add_string("")
    add_string(center(upper(arr_name[i]),sh))
    aeval(ta, {|x| add_string(x) } )
    do while tmp->tip == i .and. !eof()
      if verify_FF(HH,.t.,sh)
        aeval(ta, {|x| add_string(x) } )
      endif
      if i < 9 .or. i == 11
        k := perenos(as,tmp->u_name,47)
        add_string(tmp->shifr+" "+padr(as[1],47)+str(tmp->kol,7,0)+;
                                                 put_kopE(tmp->sum,15))
      else
        k := perenos(as,tmp->u_name,38)
        add_string(tmp->shifr+" "+padr(as[1],38)+str(tmp->kol,7,0)+;
                                                 " "+umest_val(tmp->uet,8,2)+;
                                                 put_kopE(tmp->sum,15))
      endif
      for j := 2 to k
        add_string(space(11)+as[j])
      next
      if (j := ascan(arr_lp, {|x| x[1] == tmp->shifr })) > 0
        for k := 1 to len(arr_lp[j,2])
          asort(arr_lp[j,2],,,{|x,y| fsort_usl(x[1]) < fsort_usl(y[1]) })
          s := padl("в т.ч."+padl(alltrim(arr_lp[j,2,k,1]),8),47+11)+;
               str(arr_lp[j,2,k,2],7)+" ("+lstr(arr_lp[j,2,k,3])+")"
          add_string(s)
        next
      endif
      skip
    enddo
  endif
next
fclose(fp)
close databases
rest_box(buf)
viewtext(name_file,,,,.t.,,,reg_print)
return NIL

**
Function uzkie_spec(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Выписка счета","Подсчет услуг"}
    mas_msg := {"Выписка счета на оплату мед.помощи за счет средств Программы модернизации здраво",;
                "Подсчет услуг с разбивкой по узким специалистам"}
    mas_fun := {"uzkie_spec(11)","uzkie_spec(12)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    uzkie1spec()
  case k == 12
    uzkie2spec()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

**
Function uzkie1spec()
Local buf := savescreen(), r1 := 15, tmp_color, j
Private mstrah := padr(glob_strah[2],30), m1strah := glob_strah[1], ;
        m1period := 0, mperiod := space(10), parr_m,;
        mnomer := space(10), mdate := sys_date,;
        msumma := 0, gl_area := {r1,0,23,79,0}
box_shadow(r1,2,22,77,color1,"Ввод реквизитов счета на оплату услуг",color8)
tmp_solor := setcolor(cDataCGet)
do while .t.
  @ r1+2,4 say "Период времени" get mperiod ;
         reader {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c),;
                      if(k==nil,nil,(parr_m:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION,,,.f.)}
  @ r1+3,4 say "Страховая компания" get mstrah ;
      reader {|x|menu_reader(x,glob_arr_smo,A__MENUVERT,,,.f.)}
  @ r1+4,4 say "Номер" get mnomer
  @ row(),col()+1 say "и дата" get mdate
  @ row(),col()+1 say "счета"
  @ r1+5,4 say "Сумма счета" get msumma pict "99999999.99"
  status_key("^<Esc>^ - выход;  ^<PgDn>^ - печать счета")
  myread()
  if lastkey() == K_ESC
    exit
  endif
  if empty(m1period)
    func_error(4,"Не введен период времени")
    loop
  endif
  if empty(m1strah)
    func_error(4,"Не введена страховая компания")
    loop
  endif
  glob_strah := {m1strah,alltrim(mstrah)}
  SchetUzkieSpec()
enddo
restscreen(buf)
setcolor(tmp_solor)
return NIL

**
Function uzkie2spec()
  Static mm_perso := {{'Персонал', 1}, {'Персонал+услуги', 2}, ;
                      {'Услуги', 3}, {'Услуги+персонал', 4}}
  Local buf := savescreen(), r1 := 13, tmp_color, j

  Private mstrah := padr(glob_strah[2], 30), m1strah := glob_strah[1], ;
        m1usl := mm_danet[1, 2], musl := mm_danet[1, 1], ;
        m1period := 0, mperiod := space(10), parr_m, ;
        mprocent := 0, mperso := mm_perso[1, 1], m1perso := mm_perso[1, 2], ;
        msumma := 0, gl_area := {r1, 0, 23, 79, 0}, arr_usl
  arr_usl := UsllugiUzkieSpec()
  box_shadow(r1, 2, 22, 77, color1, 'Подсчет услуг', color8)
  tmp_solor := setcolor(cDataCGet)
  do while .t.
    @ r1 + 2, 4 say 'Период времени' get mperiod ;
         reader {|x|menu_reader(x, ;
                 {{|k, r, c| k:=year_month(r + 1, c), ;
                      if(k == nil, nil, (parr_m := aclone(k), k := {k[1], k[4]})), ;
                      k }}, A__FUNCTION, , , .f.)}
    @ r1 + 3, 4 say 'Страховая компания' get mstrah ;
        reader {|x|menu_reader(x, glob_arr_smo, A__MENUVERT, , , .f.)}
    @ r1 + 4, 4 say 'Разрешить исключение некоторых услуг из списка ТФОМС?' get musl ;
        reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)}
    @ r1 + 5, 4 say 'Внешний вид документа' get mperso ;
        reader {|x|menu_reader(x, mm_perso, A__MENUVERT, , , .f.)}
    @ r1 + 6, 4 say 'Процент для ассистента (в случае его присутствия)' get mprocent pict '99'
    @ r1 + 7, 4 say 'Сумма для распределения' get msumma pict '99999999.99'
    status_key('^<Esc>^ - выход;  ^<PgDn>^ - просмотр результатов подсчета')
    myread()
    if lastkey() == K_ESC
      exit
    endif
    if empty(m1period)
      func_error(4, 'Не введен период времени')
      loop
    endif
    if empty(m1strah)
      func_error(4, 'Не введена страховая компания')
      loop
    endif
    glob_strah := {m1strah, alltrim(mstrah)}
    f1uzkie2spec()
  enddo
  restscreen(buf)
  setcolor(tmp_solor)
  return NIL

**
Function f1uzkie2spec()
Local fl_exit := .f., sh, HH := 60, reg_print, n_file := "_uz_spec"+stxt,;
      adbf := {}, lshifr, mkol := 0, delta, arr_fields := {}, abitusl,;
      begin_date := parr_m[7], end_date := parr_m[8]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
if m1usl == 1
  abitusl := {}
  R_Use(dir_server + "uslugi",,"USL")
  R_Use(dir_server + "human_u",dir_server + "human_u","HU")
  set relation to u_kod into USL
  R_Use(dir_server + "human",dir_server + "humans","HUMAN")
  R_Use(dir_server + "schet_",,"SCHET_")
  R_Use(dir_server + "schet",dir_server + "schetd","SCHET")
  set relation to recno() into SCHET_
  set filter to empty(schet_->IS_DOPLATA)
  dbseek(begin_date,.t.)
  do while schet->pdate <= end_date .and. !eof()
    if int(val(schet_->smo)) == glob_strah[1]
      @ maxrow(),0 say padr("№ "+alltrim(schet_->nschet)+" от "+;
                            date_8(schet_->dschet),27) color "W/R"
      select HUMAN
      find (str(schet->kod,6))
      do while human->schet == schet->kod
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        select HU
        find (str(human->kod,7))
        do while hu->kod == human->kod .and. !eof()
          if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
            lshifr := usl->shifr
          endif
          lshifr := alltrim(lshifr)
          if (iusl := ascan(arr_usl,{|x| x[1]==lshifr})) > 0 ;
                .and. ascan(abitusl,{|x| x[2]==hu->u_kod}) == 0
            aadd(abitusl, {usl->shifr+usl->name,hu->u_kod})
          endif
          select HU
          skip
        enddo
        select HUMAN
        skip
      enddo
      if fl_exit ; exit ; endif
    endif
    select SCHET
    skip
  enddo
  close databases
  if fl_exit
    return NIL
  endif
  asort(abitusl,,,{|x,y| left(fsort_usl(x[1]),10) < left(fsort_usl(y[1]),10) })
  if (abitusl := bit_popup(T_ROW,2,abitusl,,color5,,"Отмените исключаемые услуги","B/W")) == NIL
    return NIL
  endif
endif
aadd(adbf, {"kod_perso","N",4,0})
aadd(adbf, {"tab_nomer","N",5,0})
aadd(adbf, {"fio_perso","C",50,0})
aadd(adbf, {"usl_shifr","C",10,0})
aadd(adbf, {"usl_name","C",60,0})
aadd(adbf, {"kol_usl","N",12,5})
aadd(adbf, {"summa","N",15,2})
dbcreate(cur_dir + "tmp",adbf)
use (cur_dir + "tmp") new
if m1perso < 3
  index on str(kod_perso,4)+usl_shifr to (cur_dir + "tmp")
else
  index on usl_shifr+str(kod_perso,4) to (cur_dir + "tmp")
endif
R_Use(dir_server + "uslugi",,"USL")
R_Use(dir_server + "human_u",dir_server + "human_u","HU")
set relation to u_kod into USL
R_Use(dir_server + "human",dir_server + "humans","HUMAN")
R_Use(dir_server + "schet_",,"SCHET_")
R_Use(dir_server + "schet",dir_server + "schetd","SCHET")
set relation to recno() into SCHET_
set filter to empty(schet_->IS_DOPLATA)
dbseek(begin_date,.t.)
do while schet->pdate <= end_date .and. !eof()
  if int(val(schet_->smo)) == glob_strah[1]
    @ maxrow(),0 say padr("№ "+alltrim(schet_->nschet)+" от "+;
                          date_8(schet_->dschet),27) color "W/R"
    select HUMAN
    find (str(schet->kod,6))
    do while human->schet == schet->kod
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
          lshifr := usl->shifr
        endif
        lshifr := alltrim(lshifr)
        if (iusl := ascan(arr_usl,{|x| x[1]==lshifr})) > 0 .and. ;
                  iif(m1usl==0, .t., ascan(abitusl,{|x| x[2]==hu->u_kod}) > 0)
          arrp := {}
          if hu->kod_vr > 0
            aadd(arrp,{hu->kod_vr,1})
          endif
          if hu->kod_as > 0
            aadd(arrp,{hu->kod_as,1})
          endif
          if empty(arrp)
            aadd(arrp,{0,1})  // врач с кодом 0
          endif
          if len(arrp) == 2
            if mprocent > 0
              arrp[2,2] := round_5(mprocent/100,7)  // для ассистента
              arrp[1,2] := 1-arrp[2,2]  // для врача
            else
              asize(arrp,1) // т.е. ассистенту ничего не платим
            endif
          endif
          for i := 1 to len(arrp)
            if m1perso < 3
              str_find := str(arrp[i,1],4)
              if m1perso == 2
                str_find += padr(lshifr,10)
              endif
            else
              str_find := padr(lshifr,10)
              if m1perso == 4
                str_find += str(arrp[i,1],4)
              endif
            endif
            select TMP
            find (str_find)
            if !found()
              append blank
              if m1perso != 3
                tmp->kod_perso := arrp[i,1]
              endif
              if m1perso != 1
                tmp->usl_shifr := lshifr
                tmp->usl_name := arr_usl[iusl,2]
              endif
            endif
            tmp->kol_usl += hu->kol_1*arrp[i,2]
          next
          mkol += hu->kol_1
        endif
        select HU
        skip
      enddo
      select HUMAN
      skip
    enddo
    if fl_exit ; exit ; endif
  endif
  select SCHET
  skip
enddo
if !fl_exit
  if mkol > 0
    delta := msumma/mkol
  endif
  sh_usl := 55
  sh_perso := iif(m1perso==1, 50, 30)
  if m1perso != 1
    titl_usl := {;
      "────────┬"+replicate("─",sh_usl),;
      "  Шифр  │"+padr(" Наименование услуги",sh_usl),;
      "────────┴"+replicate("─",sh_usl)}
  endif
  if m1perso != 3
    titl_perso := {;
      "─────┬"+replicate("─",sh_perso),;
      "Таб.№│"+padr(" ФИО сотрудника",sh_perso),;
      "─────┴"+replicate("─",sh_perso)}
    R_Use(dir_server + "mo_pers",,"P2")
    tmp->(dbeval({|| p2->(dbgoto(tmp->kod_perso)), ;
                     tmp->tab_nomer:=p2->tab_nom, ;
                     tmp->fio_perso:=p2->fio }))
    aadd(arr_fields,"tab_nomer")
    aadd(arr_fields,"fio_perso")
  endif
  arr_title := array(3) ; afill(arr_title,"")
  select TMP
  if m1perso < 3
    index on upper(fio_perso)+usl_shifr to (cur_dir + "tmp")
    arr_title[1] += titl_perso[1]
    arr_title[2] += titl_perso[2]
    arr_title[3] += titl_perso[3]
    if m1perso == 2
      arr_title[1] += "┬"+titl_usl[1]
      arr_title[2] += "│"+titl_usl[2]
      arr_title[3] += "┴"+titl_usl[3]
      aadd(arr_fields,"usl_shifr")
      aadd(arr_fields,"usl_name")
    endif
  else
    Ins_Array(arr_fields,1,"usl_name")
    Ins_Array(arr_fields,1,"usl_shifr")
    arr_title[1] += titl_usl[1]
    arr_title[2] += titl_usl[2]
    arr_title[3] += titl_usl[3]
    if m1perso == 4
      arr_title[1] += "┬"+titl_perso[1]
      arr_title[2] += "│"+titl_perso[2]
      arr_title[3] += "┴"+titl_perso[3]
    endif
  endif
  aadd(arr_fields,"kol_usl")
  arr_title[1] += "┬────────"
  arr_title[2] += "│Кол.усл."
  arr_title[3] += "┴────────"
  if msumma > 0 .and. mkol > 0
    aadd(arr_fields,"summa")
    delta := msumma/mkol
    tmp->(dbeval({|| tmp->summa := tmp->kol_usl*delta }))
    arr_title[1] += "┬────────"
    arr_title[2] += "│ Сумма  "
    arr_title[3] += "┴────────"
  endif
  reg_print := f_reg_print(arr_title,@sh)
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("Услуги по узким специалистам",sh))
  add_string(center(alltrim(mstrah),sh))
  add_string(center(parr_m[4],sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  select TMP
  go top
  do while !eof()
    if verify_FF(HH, .t., sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if m1perso < 3
      s := str(tab_nomer,5)+" "+padr(fio_perso,sh_perso)
      if m1perso == 2
        s += " "+padr(usl_shifr,9)+padr(usl_name,sh_usl)
      endif
    else
      s := padr(usl_shifr,9)+padr(usl_name,sh_usl)
      if m1perso == 4
        s += " "+str(tab_nomer,5)+" "+padr(fio_perso,sh_perso)
      endif
    endif
    s += put_val_0(kol_usl,9,2)
    if msumma > 0 .and. mkol > 0
      s += put_kop(summa,9)
    endif
    add_string(s)
    skip
  enddo
  if mkol > 0
    add_string(replicate("─",sh))
    if msumma > 0
      add_string(put_val(mkol,sh-12)+put_kop(msumma,12))
    else
      add_string(put_val_0(mkol,sh,2))
    endif
  endif
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,reg_print)
  if mkol > 0
    ClrLine(24,color0)
    d_file := cur_dir + "UZ_SPEC"+sdbf
    if !del_dbf_file(d_file)
      return NIL
    endif
    use (cur_dir + "tmp") new
    __dbCopy(d_file,arr_fields,,,,,.F.,) // copy fields kod_perso,fio_perso,kol_usl to (d_file)
    close databases
    n_message({"Создан файл для загрузки в Excel: "+d_file},,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
  endif
endif
close databases
return NIL

// 31.03.23
Function SchetUzkieSpec()
Local sh:=84, HH:=60, reg_print:=2, i, j, k, s, t_arr[2], n_file := "_schet.txt"
//
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Счет",sh))
add_string(center("на оплату медицинской помощи за счет средств Программы",sh))
add_string(center("модернизации здравоохранения Волгоградской области на 2011-2012 годы",sh))
add_string(center("в части повышения доступности амбулаторной медицинской помощи",sh))
add_string("")
R_Use(dir_server + "organiz",,"ORG")
add_string("Поставщик:       "+alltrim(org->name))
add_string("Адрес:           "+org->adres)
add_string("Расчетный счет:  "+alltrim(org->r_schet)+" "+alltrim(org->bank))
add_string("БИК:             "+org->smfo)
add_string("Город:           "+"")
add_string("ИНН:             "+org->inn)
add_string("Код по ОКОНХ:    "+org->okonh)
add_string("Код по ОКПО:     "+org->okpo)
k := perenos(t_arr,alltrim(org->name)+", "+alltrim(org->adres),sh-17)
add_string("Грузоотправитель "+t_arr[1])
add_string("    и его адрес: "+t_arr[2])
i := 2
do while i < k
  i := i+1
  add_string(space(17)+t_arr[i])
enddo
add_string("")
add_string(center("СЧЕТ № "+alltrim(mnomer)+" от "+date_month(mdate),sh))
add_string("")
if (j := ascan(get_rekv_SMO(), {|x| int(val(x[1])) == glob_strah[1]})) == 0
  j := len(get_rekv_SMO()) // если не нашли - печатаем реквизиты ТФОМС
endif
k := perenos(t_arr, get_rekv_SMO()[j, 2], sh - 17)
add_string(padr("Плательщик:",17)+t_arr[1])
for i := 2 to k
  add_string(space(17)+t_arr[2])
next
k := perenos(t_arr, get_rekv_SMO()[j, 6], sh - 17)
add_string(padr('Адрес:', 17) + t_arr[1])
for i := 2 to k
  add_string(space(17) + t_arr[2])
next
add_string('Расчетный счет:  ' + alltrim(get_rekv_SMO()[j, 8]) + ' ' + alltrim(get_rekv_SMO()[j, 7]))
add_string('БИК:             ' + get_rekv_SMO()[j, 9])
add_string('Город:           ' + '')
add_string('ИНН:             ' + alltrim(get_rekv_SMO()[j, 3]) + iif(empty(get_rekv_SMO()[j, 4]), '', '/' + get_rekv_SMO()[j, 4]))
add_string("Код по ОКОНХ:    "+"")
add_string("Код по ОКПО:     "+"")
add_string("")
add_string("────────────────────────────────────────────────────────┬───────────────────────────")
add_string(" Наименование товара                                    │       Сумма (руб.)")
add_string("────────────────────────────────────────────────────────┼───────────────────────────")
add_string("Оплата медицинской помощи за счет целевых средств       │")
add_string("на реализацию меропиятий по повышению доступности       │")
add_string("амбулаторной медицинской помощи в рамках региональной   │"+center(lstr(msumma,11,2),27))
add_string("программы модернизации здравоохранения                  │")
add_string(padr(parr_m[4]+" без НДС",56)+                          "│")
add_string("────────────────────────────────────────────────────────┴───────────────────────────")
add_string("")
k := perenos(t_arr,"К оплате: "+srub_kop(msumma,.t.),sh)
i := 0
do while i < k
  i := i+1
  add_string(t_arr[i])
enddo
add_string("")
add_string("Главный врач медицинской организации      ________________ / "+alltrim(org->ruk)+" /")
add_string("")
add_string("Главный бухгалтер медицинской организации ________________ / "+alltrim(org->bux)+" /")
fclose(fp)
close databases
viewtext(n_file,,,,(sh > 80),,,reg_print)
return NIL

**
Function write_mn_p(k)
Local fl := .t.
if k == 1
  if emptyall(mdate_lech,mdate_schet,mdate_usl)
    fl := func_error(4,"Обязательно должно быть заполнено хотя бы одно из первых трёх полей даты!")
  elseif mvr1 > 0 .and. m1isvr > 0
    fl := func_error(4,'Недопустимое сочетание полей "Код врача"!')
  elseif mas1 > 0 .and. m1isas > 0
    fl := func_error(4,'Недопустимое сочетание полей "Код ассистента"!')
  endif
endif
return fl

**
Function diag2num(ldiagnoz)
Local i, k, c, s := ""
ldiagnoz := upper(alltrim(ldiagnoz))
for i := 1 to len(ldiagnoz)
  c := substr(ldiagnoz,i,1)
  if ISLETTER(c)
    c := lstr(asc(c))
  endif
  s += c
next
k := round(val(s),1)
if right(lstr(k,15,1)) == "0"
  k := round(k,0)
endif
return k

**
Function diap_diagn(k1,k2,arr)
Local fl := .f., i, j := 0, k
for i := 1 to len(arr)
  if !empty(arr[i])
    k := diag2num(arr[i])
    if between(k,k1,k2)
      j := i ; exit
    endif
  endif
next
return j

**
Function f_mn_tal_diag(k,r,c)
Static mm_prov := {{"не проверяем",0},;
                   {"проверяем   ",1},;
                   {"не введён   ",2}}
Local ret := {0,space(10)}, buf, buf24, tmp_color, i
if r > 12
  r -= 7
endif
buf24 := save_maxrow()
buf := box_shadow(r+1,2,r+6,77,color0,'Талон амбулаторного пациента',"W+/BG")
tmp_color := setcolor("N/BG,W+/N,,,B/BG")
Private mprov1  := inieditspr(A__MENUVERT, mm_prov, arr_tal_diag[1,3]), ;
        m1prov1 := arr_tal_diag[1,3],;
        mprov2  := inieditspr(A__MENUVERT, mm_prov, arr_tal_diag[2,3]), ;
        m1prov2 := arr_tal_diag[2,3]
@ r+3,5 say "Характер заболевания       " get mprov1 ;
        reader {|x|menu_reader(x,mm_prov,A__MENUVERT,,,.f.)}
  @ row(),col() say " :" get arr_tal_diag[1,1] pict "9" when m1prov1 == 1
  @ row(),col() say " [по " get arr_tal_diag[1,2] pict "9" when m1prov1 == 1
  @ row(),col() say "]"
@ r+4,5 say "Диспансерный учет          " get mprov2 ;
        reader {|x|menu_reader(x,mm_prov,A__MENUVERT,,,.f.)}
  @ row(),col() say " :" get arr_tal_diag[2,1] pict "9" when m1prov2 == 1
  @ row(),col() say " [по " get arr_tal_diag[2,2] pict "9" when m1prov2 == 1
  @ row(),col() say "]"
status_key("^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода")
myread()
arr_tal_diag[1,3] := m1prov1
arr_tal_diag[2,3] := m1prov2
for i := 1 to 2
  if arr_tal_diag[i,3] != 1
    arr_tal_diag[i,1] := arr_tal_diag[i,2] := 0
  endif
  if arr_tal_diag[i,1] > 0 .and. empty(arr_tal_diag[i,2])
    arr_tal_diag[i,2] := arr_tal_diag[i,1]
  endif
  if !empty(arr_tal_diag[i,1]) .or. arr_tal_diag[i,3] == 2
    ret := {1,"есть"}
  endif
next
rest_box(buf)
rest_box(buf24)
setcolor(tmp_color)
return ret


**
Function ret_date_reg_otch_period()
Static si := 1, sdate
Local i, ldate, fl := .f.
if (i := popup_prompt(T_ROW,T_COL-5,si,;
          {"По ~всем счетам","По счетам, за~регистрированным до..."})) == 0
  return fl
endif
if (si := i) == 1
  fl := .t.
else
  DEFAULT sdate TO sys_date
  if (ldate := input_value(20,2,22,77,color0,;
        "Введите дату, по которую включительно зарегистрированы счета",sdate)) != NIL
    fl := .t.
    mdate_reg := sdate := ldate
  endif
endif
return fl

** 11.10.18
Function prikaz_848_miac()
Static mm_poisk := {{"По дате врачебного приёма",0},;
                    {"По дате окончания лечения",1}}
Static mm_dolpro := {{"По специальности",0},;
                     {"По профилю      ",1}}
Static mm_mest := {{"Все пациенты     ",0},;
                   {"Волгоград+область",1},;
                   {"иногородние      ",2}}
Static sdate11, sdate12, s1mest1 := 0, s1poisk := 0, s1dolpro := 1, s1usl := 0
Local buf := savescreen(), r := 15
DEFAULT sdate11 TO boy(boq()-1),;
        sdate12 TO boq()-1
Private mdate11 := sdate11,;
        mdate12 := sdate12,;
        mpoisk, m1poisk := s1poisk,;
        mmest1, m1mest1 := s1mest1,;
        mdolpro, m1dolpro := s1dolpro,;
        musl, m1usl := s1usl
mpoisk := inieditspr(A__MENUVERT, mm_poisk, m1poisk)
mmest1 := inieditspr(A__MENUVERT, mm_mest , m1mest1)
mdolpro:= inieditspr(A__MENUVERT, mm_dolpro,m1dolpro)
musl   := inieditspr(A__MENUVERT, mm_danet, m1usl  )
setcolor(cDataCGet)
myclear(r)
Private gl_area := {r,0,maxrow()-1,maxcol(),0}
status_key("^<Esc>^ - выход;  ^<PgDn>^ - составление документа")
//
@ r,0 to r+8,maxcol() COLOR color8
str_center(r," Подготовка информации во исполнение приказа №848 ",color14)
@ r+2,2 say "Начало отчётного периода" get mdate11
@ r+3,2 say "Окончание отчётного периода" get mdate12
//@ r+4,2 say "Как подсчитывать врачебные приёмы" get mpoisk ;
//        reader {|x|menu_reader(x,mm_poisk,A__MENUVERT,,,.f.)}
@ r+4,2 say "Как считать пациентов" get mmest1 ;
        reader {|x|menu_reader(x,mm_mest,A__MENUVERT,,,.f.)}
@ r+5,2 say "Как отображать врачебные приёмы" get mdolpro ;
        reader {|x|menu_reader(x,mm_dolpro,A__MENUVERT,,,.f.)}
@ r+6,2 say "Выводить список услуг" get musl ;
        reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
myread()
if lastkey() != K_ESC
  if mdate11 > mdate12
    func_error(4,"Начальная дата больше конечной даты периода")
  elseif year(mdate11) < 2018
    func_error(4,"Данный режим переписан для 2018 года")
  else
    sdate11  := mdate11
    sdate12  := mdate12
    s1mest1  := m1mest1
    s1poisk  := m1poisk
    s1dolpro := m1dolpro
    s1usl    := m1usl
    f1_prikaz_848_miac()
  endif
endif
restscreen(buf)
return NIL

** 06.11.22
Function f1_prikaz_848_miac()
Local tfoms_pz[11], rec, vid_vp, vid1vp, lshifr1, _what_if := _init_if(), d2_year, ss[20]
mywait()
adbf := {{"nn","N",1,0},;       // 0-основная,1-старики
         {"ist_fin","N",1,0},;  // 1-ОМС,2-бюджет,3-платные,4-ДМС,5-расчеты с МО
         {"tip","N",1,0},;      // 1-стационар,2-АПУ,3,4,5-дн.стационар
         {"spec","N",9,0},;     // профиль или специальность
         {"u_kod","N",5,0},;    //  с плюсом - ТФОМС, с минусом - ФФОМС
         {"p1","N",10,0},;      //
         {"p2","N",10,0},;      //
         {"p3","N",10,0},;      //
         {"p4","N",10,0},;      //
         {"p5","N",10,0},;      //
         {"p6","N",10,0},;      //
         {"p7","N",10,0},;      //
         {"p8","N",10,0},;       //
         {"p9","N",10,0},;       //
         {"p10","N",10,0},;       //
         {"p11","N",10,0},;       //
         {"p12","N",10,0},;       //
         {"p13","N",10,0},;       //
         {"p14","N",10,0},;       //
         {"p15","N",10,0},;       //
         {"p16","N",10,0},;       //
         {"p17","N",10,0},;       //
         {"p18","N",10,0},;       //
         {"p19","N",10,0},;       //
         {"p20","N",10,0}}        //
dbcreate(cur_dir + "tmp",adbf)
use (cur_dir + "tmp") new alias TMP
index on str(nn,1)+str(ist_fin,1)+str(tip,1)+str(spec,9) to (cur_dir + "tmp")
if m1usl == 1
  dbcreate(cur_dir + "tmpu",adbf)
  use (cur_dir + "tmpu") new alias TMPU
  index on str(nn,1)+str(ist_fin,1)+str(tip,1)+str(spec,9)+str(u_kod,5) to (cur_dir + "tmpu")
endif
//
R_Use(dir_server + "mo_su",,"MOSU")
R_Use(dir_server + "mo_hu",dir_server + "mo_hu","MOHU")
set relation to u_kod into MOSU
R_Use(dir_server + "uslugi",,"USL")
R_Use(dir_server + "human_u_",,"HU_")
R_Use(dir_server + "kartote_",,"KART_")
R_Use(dir_server + "kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server + "human_u",{dir_server + "human_u",;
                            dir_server + "human_ud"},"HU")
set relation to recno() into HU_, to u_kod into USL
R_Use(dir_server + "human_",,"HUMAN_")
R_Use(dir_server + "human",dir_server + "humand","HUMAN")
set relation to recno() into HUMAN_, to kod_k into KART
stat_msg("По дате окончания лечения")
old := mdate11-1
dbseek(dtos(mdate11),.t.)
do while human->k_data <= mdate12 .and. !eof()
  if old != human->k_data
    old := human->k_data
    @ maxrow(),0 say date_8(old) color "W/R"
  endif
  fl := (human_->oplata < 9)
  if fl .and. m1mest1 > 0
    if between(human_->smo,'34001','34007') .or. empty(human_->smo)
      fl := (m1mest1 == 1)
    else
      fl := (m1mest1 == 2)
    endif
  endif
  if fl
    f2_prikaz_848_miac(1,_what_if)
  endif
  select HUMAN
  skip
enddo
k := tmp->(lastrec())
close databases
if k == 0
  return func_error(4,"Нет информации")
endif
name_file := cur_dir + 'prik_848' + stxt ; HH := 42
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
use (cur_dir + "tmp") index (cur_dir + "tmp") new
if m1usl == 1
  R_Use(dir_server + "mo_su",,"MOSU")
  R_Use(dir_server + "uslugi",,"USL")
  use (cur_dir + "tmpu") index (cur_dir + "tmpu") new
endif
for _tip := 1 to 5
  arr_title := {}
  arr2 := {}
  select TMP
  find ("10"+str(_tip,1))
  do while tmp->nn == 1 .and. tmp->tip==_tip .and. tmp->ist_fin==0 .and. !eof()
    if ascan(arr2, {|x| x[1] == tmp->spec}) == 0
      if _tip == 2 .and. m1dolpro == 0 .and. tmp->spec < 0
        aadd(arr2, {tmp->spec, inieditspr(A__MENUVERT, getV015(), abs(tmp->spec))})
      else
        aadd(arr2, {tmp->spec, inieditspr(A__MENUVERT, ;
                                        iif(_tip == 2 .and. m1dolpro == 0, getV004(), getV002()), ;
                                        tmp->spec)})
      endif
    endif
    skip
  enddo
  for _ist_fin := 1 to 5
    arr := {}
    select TMP
    find ("0"+str(_ist_fin,1)+str(_tip,1))
    do while tmp->nn == 0 .and. tmp->tip==_tip .and. tmp->ist_fin==_ist_fin .and. !eof()
      if ascan(arr, {|x| x[1] == tmp->spec}) == 0
        if _tip == 2 .and. m1dolpro == 0 .and. tmp->spec < 0
          aadd(arr, {tmp->spec, inieditspr(A__MENUVERT, getV015(), abs(tmp->spec))})
        else
          aadd(arr, {tmp->spec, inieditspr(A__MENUVERT, ;
            iif(_tip == 2 .and. m1dolpro == 0, getV004(), getV002()), ;
            tmp->spec)})
        endif
      endif
      skip
    enddo
    if len(arr) > 0
      n := 25
      do case
        case _tip == 1
          arr_title := {;
"┬─────────────────────────────────┬────────────────────",;
"│       число выбывших пациентов  │проведено койко-дней",;
"├──────────────────────┬──────────┼──────┬──────┬──────",;
"│       взрослые       │   дети   │взрос-│в т.ч.│детьми",;
"├─────┬─────┬─────┬────┼─────┬────┤лыми  │старше│      ",;
"│всего│старш│умерл│стар│выпи-│умер│      │трудос│      ",;
"│выпис│трудо│всего│труд│сано │ло  │      │возрас│      ",;
"├─────┼─────┼─────┼────┼─────┼────┼──────┼──────┼──────",;
"│  6  │ 6.1 │  7  │ 7.1│  8  │ 9  │  11  │ 11.1 │  12  ",;
"┴─────┴─────┴─────┴────┴─────┴────┴──────┴──────┴──────"}
          n := f4_prikaz_848_miac(40,"Профили коек",arr_title)
        case _tip == 2
          arr_title := {;
"┬─────────────────┬─────────────────────────────┬─────────────────────────────────────────┬───────────",;
"│ в АПУ посещений │сделано по поводу заболеваний│     число посещений врачами на дому     │обращ.п/заб",;
"├─────┬─────┬─────┼─────┬─────┬─────┬─────┬─────┼─────┬─────┬─────┬─────┬─────┬─────┬─────┼─────┬─────",;
"│всего│ село│ дети│ село│взрос│в/раз│дети │д/раз│всего│ село│п/заб│ дети│п/заб│в/раз│д/раз│взрос│дети ",;
"├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────",;
"│  3  │ 3.1 │  4  │3.1.1│  5  │ 5.1 │  6  │ 6.1 │  7  │ 7.1 │  8  │  9  │ 10  │ 10.1│ 10.2│ 20  │ 21  ",;
"┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────"}
          n := f4_prikaz_848_miac(40,"Наименование должностей",arr_title)
        case eq_any(_tip,3,4,5)
          arr_title := {;
"┬─────────────────┬────────────────────",;
"│пролечено больных│    пациенто-дней   ",;
"├─────┬───────────┼──────┬─────────────",;
"│     │в том числе│      │ в том числе ",;
"│всего├─────┬─────┤ всего├──────┬──────",;
"│     │взрос│ дети│      │взрос.│ дети ",;
"┴─────┴─────┴─────┴──────┴──────┴──────"}
          n := f4_prikaz_848_miac(40,"Профили коек",arr_title)
      endcase
      sh := 80
      if tek_stroke > 0
        tek_stroke := HH+1
        verify_FF(HH,.t.,sh)
      endif
      s := "Приказ №848 - "+;
           {"Стационар",;
            "Поликлиника",;
            "Дневной стационар при стационаре",;
            "Дневной стационар при поликлинике",;
            "Дневной стационар на дому"}[_tip]+" - "+;
           {"ОМС","Бюджет","Платные","ДМС","Расчеты с МО"}[_ist_fin]
      add_string(s)
      afill(ss,0)
      aeval(arr_title, {|x| add_string(x) } )
      asort(arr,,,{|x,y| upper(x[2]) < upper(y[2]) })
      for j := 1 to len(arr)
        s := padr(arr[j,2],n)
        select TMP
        find ("0"+str(_ist_fin,1)+str(_tip,1)+str(arr[j,1],9))
        if found()
          do case
            case _tip == 1
              s += put_val(tmp->p1,6)+;
                   put_val(tmp->p2,6)+;
                   put_val(tmp->p3,6)+;
                   put_val(tmp->p4,5)+;
                   put_val(tmp->p5,6)+;
                   put_val(tmp->p6,5)+;
                   put_val(tmp->p7,7)+;
                   put_val(tmp->p8,7)+;
                   put_val(tmp->p9,7)
            case _tip == 2
              s += put_val(tmp->p1+tmp->p2,6)+;
                   put_val(tmp->p18,6)+;
                   put_val(tmp->p2,6)+;
                   put_val(tmp->p19,6)+;
                   put_val(tmp->p3,6)+;
                   put_val(tmp->p12,6)+;
                   put_val(tmp->p4,6)+;
                   put_val(tmp->p13,6)+;
                   put_val(tmp->p5+tmp->p6,6)+;
                   put_val(tmp->p20,6)+;
                   put_val(tmp->p7+tmp->p8,6)+;
                   put_val(tmp->p6,6)+;
                   put_val(tmp->p8,6)+;
                   put_val(tmp->p14,6)+;
                   put_val(tmp->p15,6)+;
                   put_val(tmp->p16,6)+;
                   put_val(tmp->p17,6)
            case eq_any(_tip,3,4,5)
              s += put_val(tmp->p1+tmp->p2,6)+;
                   put_val(tmp->p1,6)+;
                   put_val(tmp->p2,6)+;
                   put_val(tmp->p3+tmp->p4,7)+;
                   put_val(tmp->p3,7)+;
                   put_val(tmp->p4,7)
          endcase
          for iss := 1 to 20
            ss[iss] += &("tmp->p"+lstr(iss))
          next iss
        endif
        verify_FF(HH,.t.,sh)
        add_string(s)
        if m1usl == 1
          arru := {}
          select TMPU
          find ("0"+str(_ist_fin,1)+str(_tip,1)+str(arr[j,1],9))
          do while tmpu->nn == 0 .and. tmpu->tip==_tip .and. tmpu->ist_fin==_ist_fin ;
                                 .and. tmpu->spec==arr[j,1] .and. !eof()
            if ascan(arru, {|x| x[1] == tmpu->u_kod}) == 0
              if tmpu->u_kod > 0
                usl->(dbGoto(tmpu->u_kod))
                lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,mdate12)
                if empty(lshifr := lshifr1)
                  lshifr := usl->shifr
                endif
                if !(lshifr == usl->shifr)
                  lshifr := alltrim(lshifr)+"("+alltrim(usl->shifr)+")"
                endif
                aadd(arru,{tmpu->u_kod,lshifr,usl->name})
              else
                mosu->(dbGoto(abs(tmpu->u_kod)))
                lshifr := alltrim(mosu->shifr1)
                if !empty(usl->shifr)
                  lshifr += "("+alltrim(mosu->shifr)+")"
                endif
                aadd(arru,{tmpu->u_kod,lshifr,mosu->name})
              endif
            endif
            select TMPU
            skip
          enddo
          asort(arru,,,{|x,y| fsort_usl(x[2]) < fsort_usl(y[2]) })
          for ju := 1 to len(arru)
            s := " "+padr(alltrim(arru[ju,2])+" "+alltrim(arru[ju,3]),n-1)
            select TMPU
            find ("0"+str(_ist_fin,1)+str(_tip,1)+str(arr[j,1],9)+str(arru[ju,1],5))
            if found()
              do case
                case _tip == 1
                  s += put_val(tmpu->p1,6)+;
                       put_val(tmpu->p2,6)+;
                       put_val(tmpu->p3,6)+;
                       put_val(tmpu->p4,5)+;
                       put_val(tmpu->p5,6)+;
                       put_val(tmpu->p6,5)+;
                       put_val(tmpu->p7,7)+;
                       put_val(tmpu->p8,7)+;
                       put_val(tmpu->p9,7)
                case _tip == 2
                  s += put_val(tmpu->p1+tmpu->p2,6)+;
                       put_val(tmpu->p18,6)+;
                       put_val(tmpu->p2,6)+;
                       put_val(tmpu->p19,6)+;
                       put_val(tmpu->p3,6)+;
                       put_val(tmpu->p12,6)+;
                       put_val(tmpu->p4,6)+;
                       put_val(tmpu->p13,6)+;
                       put_val(tmpu->p5+tmpu->p6,6)+;
                       put_val(tmpu->p20,6)+;
                       put_val(tmpu->p7+tmpu->p8,6)+;
                       put_val(tmpu->p6,6)+;
                       put_val(tmpu->p8,6)+;
                       put_val(tmpu->p14,6)+;
                       put_val(tmpu->p15,6)+;
                       put_val(tmpu->p16,6)+;
                       put_val(tmpu->p17,6)
                case eq_any(_tip,3,4,5)
                  s += put_val(tmpu->p1+tmp->p2,6)+;
                       put_val(tmpu->p1,6)+;
                       put_val(tmpu->p2,6)+;
                       put_val(tmpu->p3+tmp->p4,7)+;
                       put_val(tmpu->p3,7)+;
                       put_val(tmpu->p4,7)
              endcase
            endif
            verify_FF(HH,.t.,sh)
            add_string(s)
          next ju
        endif
      next j
      if m1usl == 0
        s := padr("Итого:",n)
        do case
          case _tip == 1
            s += put_val(ss[1],6)+;
                 put_val(ss[2],6)+;
                 put_val(ss[3],6)+;
                 put_val(ss[4],5)+;
                 put_val(ss[5],6)+;
                 put_val(ss[6],5)+;
                 put_val(ss[7],7)+;
                 put_val(ss[8],7)+;
                 put_val(ss[9],7)
          case _tip == 2
            s += put_val(ss[1]+ss[2],6)+;
                 put_val(ss[18],6)+;
                 put_val(ss[2],6)+;
                 put_val(ss[19],6)+;
                 put_val(ss[3],6)+;
                 put_val(ss[12],6)+;
                 put_val(ss[4],6)+;
                 put_val(ss[13],6)+;
                 put_val(ss[5]+ss[6],6)+;
                 put_val(ss[20],6)+;
                 put_val(ss[7]+ss[8],6)+;
                 put_val(ss[6],6)+;
                 put_val(ss[8],6)+;
                 put_val(ss[14],6)+;
                 put_val(ss[15],6)+;
                 put_val(ss[16],6)+;
                 put_val(ss[17],6)
          case eq_any(_tip,3,4,5)
            s += put_val(ss[1]+ss[2],6)+;
                 put_val(ss[1],6)+;
                 put_val(ss[2],6)+;
                 put_val(ss[3]+ss[4],7)+;
                 put_val(ss[3],7)+;
                 put_val(ss[4],7)
        endcase
        add_string(replicate("-",len(arr_title[1])))
        add_string(s)
      endif
    endif
  next _ist_fin
  if len(arr2) > 0
      do case
        case _tip == 1
          arr_title := {;
"┬───────────────────────┬───────────────────────┬───────────────────┬───────────────────────────",;
"│       поступило       │       выписано        │      умерло       │    проведено койко-дней   ",;
"├───────────┬───────────┼───────────┬───────────┼─────────┬─────────┼─────────────┬─────────────",;
"│   город   │    село   │   город   │    село   │  город  │   село  │    город    │     село    ",;
"├─────┬─────┼─────┬─────┼─────┬─────┼─────┬─────┼────┬────┼────┬────┼──────┬──────┼──────┬──────",;
"│всего│в т.ч│всего│в т.ч│всего│в т.ч│всего│в т.ч│все-│вт.ч│все-│вт.ч│ всего│в т.ч.│ всего│в т.ч.",;
"│     │ ОМС │     │ ОМС │     │ ОМС │     │ ОМС │го  │ ОМС│го  │ ОМС│      │ ОМС  │      │ ОМС  ",;
"├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼────┼────┼────┼────┼──────┼──────┼──────┼──────",;
"│  6  │ 6.1 │  7  │ 7.1 │ 12  │ 12.1│ 13  │ 13.1│ 15 │15.1│ 16 │16.1│  18  │ 18.1 │  19  │ 19.1 ",;
"┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴────┴────┴────┴────┴──────┴──────┴──────┴──────"}
          n := f4_prikaz_848_miac(40,"Профили коек",arr_title)
        case _tip == 2
          arr_title := {;
"┬───────────────────────┬───────────────────────┬───────────",;
"│посещений в поликлинике│   посещений на дому   │ патронаж  ",;
"├───────────┬───────────┼───────────┬───────────┼─────┬─────",;
"│   город   │    село   │   город   │    село   │город│село ",;
"├─────┬─────┼─────┬─────┼─────┬─────┼─────┬─────┼─────┼─────",;
"│всего│повод│всего│повод│всего│повод│всего│повод│     │     ",;
"│     │забол│     │забол│     │забол│     │забол│     │     ",;
"├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────",;
"│ 4.1 │ 5.1 │ 4.2 │ 5.2 │ 6.1 │ 7.1 │ 6.2 │ 7.2 │8.3.1│8.3.2",;
"┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────"}
          n := f4_prikaz_848_miac(40,"Наименования должностей",arr_title)
        case eq_any(_tip,3,4,5)
          arr_title := {;
"┬───────────────────────┬───────────────────────────",;
"│  пролечено больных    │  проведено пациенто-дней  ",;
"├───────────┬───────────┼─────────────┬─────────────",;
"│   город   │    село   │    город    │     село    ",;
"├─────┬─────┼─────┬─────┼──────┬──────┼──────┬──────",;
"│всего│в т.ч│всего│в т.ч│ всего│в т.ч.│ всего│в т.ч.",;
"│     │ ОМС │     │ ОМС │      │ ОМС  │      │ ОМС  ",;
"├─────┼─────┼─────┼─────┼──────┼──────┼──────┼──────",;
"│ 10  │10.1 │ 11  │11.1 │  13  │ 13.1 │  14  │ 14.1 ",;
"┴─────┴─────┴─────┴─────┴──────┴──────┴──────┴──────"}
          if _tip == 3
            arr_title[9] := ;
"│  4  │ 4.1 │  5  │ 5.1 │   7  │  7.1 │   8  │  8.1 "
          elseif _tip == 5
            arr_title[9] := ;
"│     │     │     │     │      │      │      │      "
          endif
          n := f4_prikaz_848_miac(40,"Профили коек",arr_title)
    endcase
    sh := 80
    if tek_stroke > 0
      tek_stroke := HH+1
      verify_FF(HH,.t.,sh)
    endif
    s := "Приказ №848 - "+;
           {"Стационар",;
            "Поликлиника",;
            "Дневной стационар при стационаре",;
            "Дневной стационар при поликлинике",;
            "Дневной стационар на дому"}[_tip]+" - СПРАВОЧНО-пожилые"
    afill(ss,0)
    add_string(s)
    aeval(arr_title, {|x| add_string(x) } )
    asort(arr2,,,{|x,y| upper(x[2]) < upper(y[2]) })
    for j := 1 to len(arr2)
      s := padr(arr2[j,2],n)
      select TMP
      find ("10"+str(_tip,1)+str(arr2[j,1],9))
      if found()
        do case
          case _tip == 1
            s += put_val(tmp->p1,6)+;
                 put_val(tmp->p2,6)+;
                 put_val(tmp->p3,6)+;
                 put_val(tmp->p4,6)+;
                 put_val(tmp->p5,6)+;
                 put_val(tmp->p6,6)+;
                 put_val(tmp->p7,6)+;
                 put_val(tmp->p8,6)+;
                 put_val(tmp->p9,5)+;
                 put_val(tmp->p10,5)+;
                 put_val(tmp->p11,5)+;
                 put_val(tmp->p12,5)+;
                 put_val(tmp->p13,7)+;
                 put_val(tmp->p14,7)+;
                 put_val(tmp->p15,7)+;
                 put_val(tmp->p16,7)
          case _tip == 2
            s += put_val(tmp->p1,6)+;
                 put_val(tmp->p2,6)+;
                 put_val(tmp->p3,6)+;
                 put_val(tmp->p4,6)+;
                 put_val(tmp->p5,6)+;
                 put_val(tmp->p6,6)+;
                 put_val(tmp->p7,6)+;
                 put_val(tmp->p8,6)+;
                 put_val(tmp->p9,6)+;
                 put_val(tmp->p10,6)
          case eq_any(_tip,3,4,5)
            s += put_val(tmp->p1,6)+;
                 put_val(tmp->p2,6)+;
                 put_val(tmp->p3,6)+;
                 put_val(tmp->p4,6)+;
                 put_val(tmp->p13,7)+;
                 put_val(tmp->p14,7)+;
                 put_val(tmp->p15,7)+;
                 put_val(tmp->p16,7)
        endcase
        for iss := 1 to 20
          ss[iss] += &("tmp->p"+lstr(iss))
        next iss
      endif
      verify_FF(HH,.t.,sh)
      add_string(s)
      if m1usl == 1
        arru := {}
        select TMPU
        find ("10"+str(_tip,1)+str(arr2[j,1],9))
        do while tmpu->nn == 1 .and. tmpu->tip==_tip .and. tmpu->ist_fin==0 ;
                               .and. tmpu->spec==arr2[j,1] .and. !eof()
          if ascan(arru, {|x| x[1] == tmpu->u_kod}) == 0
            if tmpu->u_kod > 0
              usl->(dbGoto(tmpu->u_kod))
              lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,mdate12)
              if empty(lshifr := lshifr1)
                lshifr := usl->shifr
              endif
              if !(lshifr == usl->shifr)
                lshifr := alltrim(lshifr)+"("+alltrim(usl->shifr)+")"
              endif
              aadd(arru,{tmpu->u_kod,lshifr,usl->name})
            else
              mosu->(dbGoto(abs(tmpu->u_kod)))
              lshifr := alltrim(mosu->shifr1)
              if !empty(usl->shifr)
                lshifr += "("+alltrim(mosu->shifr)+")"
              endif
              aadd(arru,{tmpu->u_kod,lshifr,mosu->name})
            endif
          endif
          select TMPU
          skip
        enddo
        asort(arru,,,{|x,y| fsort_usl(x[2]) < fsort_usl(y[2]) })
        for ju := 1 to len(arru)
          s := " "+padr(alltrim(arru[ju,2])+" "+alltrim(arru[ju,3]),n-1)
          select TMPU
          find ("10"+str(_tip,1)+str(arr2[j,1],9)+str(arru[ju,1],5))
          if found()
            do case
              case _tip == 1
                s += put_val(tmpu->p1,6)+;
                     put_val(tmpu->p2,6)+;
                     put_val(tmpu->p3,6)+;
                     put_val(tmpu->p4,6)+;
                     put_val(tmpu->p5,6)+;
                     put_val(tmpu->p6,6)+;
                     put_val(tmpu->p7,6)+;
                     put_val(tmpu->p8,6)+;
                     put_val(tmpu->p9,5)+;
                     put_val(tmpu->p10,5)+;
                     put_val(tmpu->p11,5)+;
                     put_val(tmpu->p12,5)+;
                     put_val(tmpu->p13,7)+;
                     put_val(tmpu->p14,7)+;
                     put_val(tmpu->p15,7)+;
                     put_val(tmpu->p16,7)
              case _tip == 2
                s += put_val(tmpu->p1,6)+;
                     put_val(tmpu->p2,6)+;
                     put_val(tmpu->p3,6)+;
                     put_val(tmpu->p4,6)+;
                     put_val(tmpu->p5,6)+;
                     put_val(tmpu->p6,6)+;
                     put_val(tmpu->p7,6)+;
                     put_val(tmpu->p8,6)+;
                     put_val(tmpu->p9,6)+;
                     put_val(tmpu->p10,6)
              case eq_any(_tip,3,4,5)
                s += put_val(tmpu->p1,6)+;
                     put_val(tmpu->p2,6)+;
                     put_val(tmpu->p3,6)+;
                     put_val(tmpu->p4,6)+;
                     put_val(tmpu->p13,7)+;
                     put_val(tmpu->p14,7)+;
                     put_val(tmpu->p15,7)+;
                     put_val(tmpu->p16,7)
            endcase
          endif
          verify_FF(HH,.t.,sh)
          add_string(s)
        next ju
      endif
    next j
    if m1usl == 0
      s := padr("Итого:",n)
      do case
        case _tip == 1
          s += put_val(ss[1],6)+;
               put_val(ss[2],6)+;
               put_val(ss[3],6)+;
               put_val(ss[4],6)+;
               put_val(ss[5],6)+;
               put_val(ss[6],6)+;
               put_val(ss[7],6)+;
               put_val(ss[8],6)+;
               put_val(ss[9],5)+;
               put_val(ss[10],5)+;
               put_val(ss[11],5)+;
               put_val(ss[12],5)+;
               put_val(ss[13],7)+;
               put_val(ss[14],7)+;
               put_val(ss[15],7)+;
               put_val(ss[16],7)
        case _tip == 2
          s += put_val(ss[1],6)+;
               put_val(ss[2],6)+;
               put_val(ss[3],6)+;
               put_val(ss[4],6)+;
               put_val(ss[5],6)+;
               put_val(ss[6],6)+;
               put_val(ss[7],6)+;
               put_val(ss[8],6)+;
               put_val(ss[9],6)+;
               put_val(ss[10],6)
        case eq_any(_tip,3,4,5)
          s += put_val(ss[1],6)+;
               put_val(ss[2],6)+;
               put_val(ss[3],6)+;
               put_val(ss[4],6)+;
               put_val(ss[13],7)+;
               put_val(ss[14],7)+;
               put_val(ss[15],7)+;
               put_val(ss[16],7)
      endcase
      add_string(replicate("-",len(arr_title[1])))
      add_string(s)
    endif
  endif
next _tip
fclose(fp)
close databases
Private yes_albom := .t.
viewtext(name_file,,,,.t.,,,2)
return NIL

** 28.12.17
Function f2_prikaz_848_miac(par,_what_if)
Local tfoms_pz[20], a_usl := {}, i, j, lshifr1, mkol,;
      _ist_fin := f3_prikaz_848_miac(_what_if), ;
      is_rebenok := (human->VZROS_REB > 0), d2_year := year(human->k_data),;
      is_trudosp := f_starshe_trudosp(human->POL,human->DATE_R,human->n_data),;
      fl_death := is_death(human_->RSLT_NEW), au_lu := {}, fl_stom := .f., fl_stom_new := .f.,;
      is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog), is_2_88 := .f., au_flu := {},;
      is_patronag := .f., lusl_ok := 0, vid_vp := 0, vid1vp := 0 // по умолчанию профилактика
select HU
find (str(human->kod,7))
do while hu->kod == human->kod .and. !eof()
  lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
  if f_paraklinika(usl->shifr,lshifr1,human->k_data)
    lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
    aadd(au_lu,{lshifr,;              // 1
                c4tod(hu->date_u),;   // 2
                hu_->profil,;         // 3
                hu_->PRVS,;           // 4
                alltrim(usl->shifr),; // 5
                hu->kol_1,;           // 6
                c4tod(hu->date_u),;   // 7
                hu_->kod_diag,;       // 8
                hu->(recno()),;       // 9 - номер записи
                0})                   // 10 - для возврата
    if eq_any(left(lshifr,5),"2.80.","2.82.") .and. is_2_stomat(lshifr) == 0 .and. is_2_stomat(lshifr,,.t.) == 0
      vid_vp := 1 // в неотложной форме или Посещение в приёмном покое
      exit
    elseif eq_any(left(lshifr,5),"2.78.","2.89.") .and. is_2_stomat(lshifr) == 0 .and. is_2_stomat(lshifr,,.t.) == 0
      vid_vp := 2 // по поводу заболевания
      exit
    elseif left(lshifr,5) == "2.88." .and. is_2_stomat(lshifr) == 0 .and. is_2_stomat(lshifr,,.t.) == 0
      vid_vp := 2 // разовое по поводу заболевания
      vid1vp := 1
      exit
    elseif between_shifr(alltrim(lshifr),"2.79.44","2.79.50")
      is_patronag := .t.
    elseif left(lshifr,3) == "57." // стоматология
      fl_stom := .t.
    elseif is_2_stomat(lshifr,,.t.) > 0
      fl_stom_new := .t.
      exit
    endif
  endif
  select HU
  skip
enddo
if fl_stom_new
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    aadd(au_flu,{mosu->shifr1,;         // 1
                 c4tod(mohu->date_u),;  // 2
                 mohu->profil,;         // 3
                 mohu->PRVS,;           // 4
                 mosu->shifr,;          // 5
                 mohu->kol_1,;          // 6
                 c4tod(mohu->date_u2),; // 7
                 mohu->kod_diag,;       // 8
                 mohu->(recno()),;      // 9 - номер записи
                 0})                    // 10 - для возврата
    select MOHU
    skip
  enddo
  j := 0
  f_vid_p_stom(au_lu,{},,,human->k_data,@j,,@is_2_88,au_flu)
  if is_2_88 // разовое по поводу заболевания
    vid_vp := 2 // по поводу заболевания
    vid1vp := 1
  elseif j == 1  // с лечебной целью
    vid_vp := 2 // по поводу заболевания
  elseif j == 3  // при оказании неотложной помощи
    vid_vp := 1 // в неотложной форме
  endif
  lusl_ok := 2
  is_zabol := (vid_vp > 0)
  for i := 1 to len(au_flu)
    if au_flu[i,10] == 1 // является врачебным приёмом
      mohu->(dbGoto(au_flu[i,9]))
      is_dom := .f. // на дому
      aadd(a_usl,{2,iif(m1dolpro==0, mohu->PRVS, mohu->PROFIL),-mohu->u_kod,mohu->kol_1,is_dom})
    endif
  next
elseif fl_stom
  j := 0
  f_vid_p_stom(au_lu,{},,,human->k_data,@j,,@is_2_88)
  if is_2_88 // разовое по поводу заболевания
    vid_vp := 2 // по поводу заболевания
    vid1vp := 1
  elseif j == 1  // с лечебной целью
    vid_vp := 2 // по поводу заболевания
  elseif j == 3  // при оказании неотложной помощи
    vid_vp := 1 // в неотложной форме
  endif
  lusl_ok := 2
  is_zabol := (vid_vp > 0)
  for i := 1 to len(au_lu)
    if au_lu[i,10] == 1 // является врачебным приёмом
      hu->(dbGoto(au_lu[i,9]))
      is_dom := (hu->kol_rcp < 0 .and. DomUslugaTFOMS(lshifr)) // на дому - по новому
      aadd(a_usl,{2,iif(m1dolpro==0, hu_->PRVS, hu_->PROFIL),hu->u_kod,hu->kol_1,is_dom})
    endif
  next
else
  is_zabol := (vid_vp > 0)
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    if f_paraklinika(usl->shifr,lshifr1,human->k_data)
      lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
      ta := f14tf_nastr(@lshifr,,d2_year)
      lshifr := alltrim(lshifr)
      for j := 1 to len(ta)
        k := ta[j,1]
        if between(k,1,6) .and. ta[j,2] >= 0
          if ta[j,2] == 1 // законченный случай
            mkol := human->k_data - human->n_data  // койко-день
            if between(ta[j,1],3,5) // дневной стационар до 1 апреля
              ++mkol
            endif
          elseif ta[j,2] == 0
            mkol := hu->kol_1
          else
            mkol := 0
          endif
          ii := 0 ; is_dom := .f.
          if k == 2 // стационар
            ii := 1
          elseif eq_any(k,1,6) // поликлиника
            ii := 2
            is_dom := (hu->kol_rcp < 0 .and. DomUslugaTFOMS(lshifr)) // на дому - по новому
          elseif eq_any(k,3,4,5) // дневной стационар
            ii := k
          endif
          if ii > 0
            if ii == 1 // стационар
              lusl_ok := 1
              aadd(a_usl,{ii,hu_->PROFIL,hu->u_kod,mkol,is_dom})
            elseif ii == 2 // поликлиника
              lusl_ok := 2
              aadd(a_usl,{ii,iif(m1dolpro==0, hu_->PRVS, hu_->PROFIL),hu->u_kod,mkol,is_dom})
            else // дневной стационар
              lusl_ok := 3
              aadd(a_usl,{ii,hu_->PROFIL,hu->u_kod,mkol,is_dom})
            endif
          endif
        endif
      next
    endif
    select HU
    skip
  enddo
endif
for i := 1 to len(a_usl)
  select TMP
  find ("0"+str(_ist_fin,1)+str(a_usl[i,1],1)+str(a_usl[i,2],9))
  if !found()
    append blank
    tmp->nn      := 0
    tmp->ist_fin := _ist_fin
    tmp->tip     := a_usl[i,1]
    tmp->spec    := a_usl[i,2]
  endif
  do case
    case lusl_ok == 1 // стационар
      if i == 1 // только один раз учтём человека
        if is_rebenok
          if fl_death
            tmp->p6 ++
          else
            tmp->p5 ++
          endif
        else
          if fl_death
            tmp->p3 ++
            if is_trudosp
              tmp->p4 ++
            endif
          else
            tmp->p1 ++
            if is_trudosp
              tmp->p2 ++
            endif
          endif
        endif
      endif
      if is_rebenok
        tmp->p9 += a_usl[i,4]
      else
        tmp->p7 += a_usl[i,4]
        if is_trudosp
          tmp->p8 += a_usl[i,4]
        endif
      endif
    case lusl_ok == 2 // поликлиника
      if is_selo
        if a_usl[i,5] // на дому
          tmp->p20 += a_usl[i,4]
        else
          tmp->p18 += a_usl[i,4]
          if is_zabol
            tmp->p19 += a_usl[i,4]
          endif
        endif
      endif
      if is_rebenok
        if a_usl[i,5] // на дому
          tmp->p6 += a_usl[i,4]
          if is_zabol
            tmp->p8 += a_usl[i,4]
            if vid1vp > 0
              tmp->p15 += a_usl[i,4]
            endif
          endif
        else
          tmp->p2 += a_usl[i,4]
          if is_zabol
            tmp->p4 += a_usl[i,4]
            if vid1vp > 0
              tmp->p13 += a_usl[i,4]
            endif
          endif
        endif
        if vid1vp == 0 .and. vid_vp == 2 .and. i == 1 // количество обращений за вычетом разовых по поводу заболеваний
          tmp->p17 ++
        endif
      else
        if a_usl[i,5] // на дому
          tmp->p5 += a_usl[i,4]
          if is_zabol
            tmp->p7 += a_usl[i,4]
            if vid1vp > 0
              tmp->p14 += a_usl[i,4]
            endif
          endif
        else
          tmp->p1 += a_usl[i,4]
          if is_zabol
            tmp->p3 += a_usl[i,4]
            if vid1vp > 0
              tmp->p12 += a_usl[i,4]
            endif
          endif
        endif
        if vid1vp == 0 .and. vid_vp == 2 .and. i == 1 // количество обращений за вычетом разовых по поводу заболеваний
          tmp->p16 ++
        endif
      endif
    case lusl_ok == 3 // дневной стационар
      if i == 1 // только один раз учтём человека
        if is_rebenok
          tmp->p2 ++
        else
          tmp->p1 ++
        endif
      endif
      if is_rebenok
        tmp->p4 += a_usl[i,4]
      else
        tmp->p3 += a_usl[i,4]
      endif
  endcase
  if m1usl == 1
    select TMPU
    find ("0"+str(_ist_fin,1)+str(a_usl[i,1],1)+str(a_usl[i,2],9)+str(a_usl[i,3],5))
    if !found()
      append blank
      tmpu->nn      := 0
      tmpu->ist_fin := _ist_fin
      tmpu->tip     := a_usl[i,1]
      tmpu->spec    := a_usl[i,2]
      tmpu->u_kod   := a_usl[i,3]
    endif
    do case
      case lusl_ok == 1 // стационар
        if is_rebenok
          tmpu->p9 += a_usl[i,4]
        else
          tmpu->p7 += a_usl[i,4]
          if is_trudosp
            tmpu->p8 += a_usl[i,4]
          endif
        endif
      case lusl_ok == 2 // поликлиника
        if is_selo
          if a_usl[i,5] // на дому
            tmpu->p20 += a_usl[i,4]
          else
            tmpu->p18 += a_usl[i,4]
            if is_zabol
              tmpu->p19 += a_usl[i,4]
            endif
          endif
        endif
        if is_rebenok
          if a_usl[i,5] // на дому
            tmpu->p6 += a_usl[i,4]
            if is_zabol
              tmpu->p8 += a_usl[i,4]
              if vid1vp > 0
                tmpu->p15 += a_usl[i,4]
              endif
            endif
          else
            tmpu->p2 += a_usl[i,4]
            if is_zabol
              tmpu->p4 += a_usl[i,4]
              if vid1vp > 0
                tmpu->p13 += a_usl[i,4]
              endif
            endif
          endif
        else
          if a_usl[i,5] // на дому
            tmpu->p5 += a_usl[i,4]
            if is_zabol
              tmpu->p7 += a_usl[i,4]
              if vid1vp > 0
                tmpu->p14 += a_usl[i,4]
              endif
            endif
          else
            tmpu->p1 += a_usl[i,4]
            if is_zabol
              tmpu->p3 += a_usl[i,4]
              if vid1vp > 0
                tmpu->p12 += a_usl[i,4]
              endif
            endif
          endif
        endif
      case lusl_ok == 3 // дневной стационар
        if is_rebenok
          tmpu->p4 += a_usl[i,4]
        else
          tmpu->p3 += a_usl[i,4]
        endif
    endcase
  endif
next i
if is_trudosp // СПРАВОЧНО-пожилые
  for i := 1 to len(a_usl)
    select TMP
    find ("10"+str(a_usl[i,1],1)+str(a_usl[i,2],9))
    if !found()
      append blank
      tmp->nn      := 1
      tmp->ist_fin := 0
      tmp->tip     := a_usl[i,1]
      tmp->spec    := a_usl[i,2]
    endif
    do case
      case lusl_ok == 1 // стационар
        if i == 1 // только один раз учтём человека
          if is_selo
            tmp->p3 ++
            if _ist_fin == 1 // ОМС
              tmp->p4 ++
            endif
          else
            tmp->p1 ++
            if _ist_fin == 1 // ОМС
              tmp->p2 ++
            endif
          endif
          if fl_death
            if is_selo
              tmp->p11 ++
              if _ist_fin == 1 // ОМС
                tmp->p12 ++
              endif
            else
              tmp->p9 ++
              if _ist_fin == 1 // ОМС
                tmp->p10 ++
              endif
            endif
          else
            if is_selo
              tmp->p7 ++
              if _ist_fin == 1 // ОМС
                tmp->p8 ++
              endif
            else
              tmp->p5 ++
              if _ist_fin == 1 // ОМС
                tmp->p6 ++
              endif
            endif
          endif
        endif
        if is_selo
          tmp->p15 += a_usl[i,4]
          if _ist_fin == 1 // ОМС
            tmp->p16 += a_usl[i,4]
          endif
        else
          tmp->p13 += a_usl[i,4]
          if _ist_fin == 1 // ОМС
            tmp->p14 += a_usl[i,4]
          endif
        endif
      case lusl_ok == 2 // поликлиника
        if is_selo
          if a_usl[i,5] // на дому
            tmp->p7 += a_usl[i,4]
            if is_zabol
              tmp->p8 += a_usl[i,4]
            endif
          else
            tmp->p3 += a_usl[i,4]
            if is_zabol
              tmp->p4 += a_usl[i,4]
            endif
          endif
        else
          if a_usl[i,5] // на дому
            tmp->p5 += a_usl[i,4]
            if is_zabol
              tmp->p6 += a_usl[i,4]
            endif
          else
            tmp->p1 += a_usl[i,4]
            if is_zabol
              tmp->p2 += a_usl[i,4]
            endif
          endif
        endif
        if is_patronag
          if is_selo
            tmp->p10 += a_usl[i,4]
          else
            tmp->p9 += a_usl[i,4]
          endif
        endif
      case lusl_ok == 3 // дневной стационар
        if i == 1 // только один раз учтём человека
          if is_selo
            tmp->p3 ++
            if _ist_fin == 1 // ОМС
              tmp->p4 ++
            endif
          else
            tmp->p1 ++
            if _ist_fin == 1 // ОМС
              tmp->p2 ++
            endif
          endif
        endif
        if is_selo
          tmp->p15 += a_usl[i,4]
          if _ist_fin == 1 // ОМС
            tmp->p16 += a_usl[i,4]
          endif
        else
          tmp->p13 += a_usl[i,4]
          if _ist_fin == 1 // ОМС
            tmp->p14 += a_usl[i,4]
          endif
        endif
    endcase
    if m1usl == 1
      select TMPU
      find ("10"+str(a_usl[i,1],1)+str(a_usl[i,2],9)+str(a_usl[i,3],5))
      if !found()
        append blank
        tmpu->nn      := 1
        tmpu->ist_fin := 0
        tmpu->tip     := a_usl[i,1]
        tmpu->spec    := a_usl[i,2]
        tmpu->u_kod   := a_usl[i,3]
      endif
      do case
        case lusl_ok == 1 // стационар
          if is_selo
            tmpu->p15 += a_usl[i,4]
            if _ist_fin == 1 // ОМС
              tmpu->p16 += a_usl[i,4]
            endif
          else
            tmpu->p13 += a_usl[i,4]
            if _ist_fin == 1 // ОМС
              tmpu->p14 += a_usl[i,4]
            endif
          endif
        case lusl_ok == 2 // поликлиника
          if is_selo
            if a_usl[i,5] // на дому
              tmpu->p7 += a_usl[i,4]
              if is_zabol
                tmpu->p8 += a_usl[i,4]
              endif
            else
              tmpu->p3 += a_usl[i,4]
              if is_zabol
                tmpu->p4 += a_usl[i,4]
              endif
            endif
          else
            if a_usl[i,5] // на дому
              tmpu->p5 += a_usl[i,4]
              if is_zabol
                tmpu->p6 += a_usl[i,4]
              endif
            else
              tmpu->p1 += a_usl[i,4]
              if is_zabol
                tmpu->p2 += a_usl[i,4]
              endif
            endif
          endif
          if is_patronag
            if is_selo
              tmpu->p10 += a_usl[i,4]
            else
              tmpu->p9 += a_usl[i,4]
            endif
          endif
        case lusl_ok == 3 // дневной стационар
          if is_selo
            tmpu->p15 += a_usl[i,4]
            if _ist_fin == 1 // ОМС
              tmpu->p16 += a_usl[i,4]
            endif
          else
            tmpu->p13 += a_usl[i,4]
            if _ist_fin == 1 // ОМС
              tmpu->p14 += a_usl[i,4]
            endif
          endif
      endcase
    endif
  next i
endif
return NIL

** 14.10.15
Function f3_prikaz_848_miac(_what_if)
Local list_fin := I_FIN_OMS, _ist_fin, i
if human->komu == 5
  list_fin := I_FIN_PLAT // личный счет = платные услуги
elseif eq_any(human->komu,1,3)
  if (i := ascan(_what_if[2], {|x| x[1]==human->komu .and. x[2]==human->str_crb})) > 0
    list_fin := _what_if[2,i,3]
  endif
endif
// 1-ОМС,2-бюджет,3-платные,4-ДМС,5-расчеты с МО
if list_fin == I_FIN_OMS
  _ist_fin := 1
elseif list_fin == I_FIN_PLAT
  _ist_fin := 3
elseif list_fin == I_FIN_DMS
  _ist_fin := 4
elseif list_fin == I_FIN_LPU
  _ist_fin := 5
else
  _ist_fin := 2
endif
return _ist_fin

**
Function f4_prikaz_848_miac(n,t,at)
Local i, j, s, k := len(at)
j := int(k/2)
for i := 1 to k
  if eq_any(i,1,k)
    s := replicate("─",n)
  elseif i == j
    s := padc(t,n)
  else
    s := space(n)
  endif
  at[i] := s+at[i]
next
return n
