***** mo_omsis.prg - информация по ОМС (по счетам)
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch  := 1

***** 19.02.13
Function s3_statist(k3,k4)
// k3 = 1 - Список счетов
// k3 = 2 - С объединением по принадлежности
// k3 = 3 - С разбивкой по отделениям
// k3 = 4 - С разбивкой по службам
//   k4 = 1 - С разбивкой по отделениям (где выписан счет)
//   k4 = 2 - С разбивкой по отделениям (где оказана услуга)
Local arr_g, buf := save_maxrow(), ind_human, ind_schet, mname,;
      i, j, s, fl, sh, HH := 57, arr_title, reg_print, ;
      name_file := "spisok_s"+stxt, pp[8], old_smo, old_komu, old_str_crb, ;
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
if R_Use(dir_server+"human_",,"HUMAN_") .and. ;
    R_Use(dir_server+"human",dir_server+"humans","HUMAN") .and. ;
     R_Use(dir_server+"human_u",dir_server+"human_u","HU") .and. ;
       R_Use(dir_server+"mo_otd",,"OTD") .and. ;
        R_Use(dir_server+"slugba",dir_server+"slugba","SL") .and. ;
         R_Use(dir_server+"uslugi",dir_server+"uslugi","USL") .and. ;
          R_Use(dir_server+"schet_",,"SCHET_") .and. ;
            R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
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
                            pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir+"tmp") ;
            while pdate <= arr_g[8]
    else
      index on pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir+"tmp") ;
                                                      while pdate <= arr_g[8]
    endif
  elseif pds == 2
    if k3 == 2  // с объединением по принадлежности
      index on schet_->smo+iif(empty(schet_->smo),str(komu,1)+str(str_crb,2),;
                                                  str(0,1)+str(0,2))+;
                            pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir+"tmp") ;
            for between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_g[5],arr_g[6])
    else
      index on pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir+"tmp") ;
            for between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_g[5],arr_g[6])
    endif
  else
    if k3 == 2  // с объединением по принадлежности
      index on schet_->smo+iif(empty(schet_->smo),str(komu,1)+str(str_crb,2),;
                                                  str(0,1)+str(0,2))+;
                            pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir+"tmp") ;
        for schet_->NREGISTR==0 .and. between(date_reg_schet(),arr_g[5],arr_g[6])
    else
      index on pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir+"tmp") ;
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
              asort(arr_bukva,,,{|x,y| x[2] < y[2] })
              fl := .t.
              for i := 1 to len(arr_bukva)
                if arr_bukva[i,7] == old_smo
                  if fl
                    add_string(replicate("-",sh))
                  endif
                  s := padl(iif(fl,"в т.ч. ",""),30)+;
                       put_val(arr_bukva[i,4],6)+put_kopE(arr_bukva[i,3],13)+;
                       put_val(arr_bukva[i,6],6)+put_kopE(arr_bukva[i,5],13)+" "
                  if (j := ascan(mm_bukva,{|x| x[2] == arr_bukva[i,2]})) > 0
                    s += mm_bukva[j,1]
                  else
                    s += arr_bukva[i,2]
                  endif
                  add_string(s)
                  fl := .f.
                endif
              next
            endif
            add_string("")
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
        asort(arr_bukva,,,{|x,y| x[2] < y[2] })
        fl := .t.
        for i := 1 to len(arr_bukva)
          if arr_bukva[i,7] == old_smo
            if fl
              add_string(replicate("-",sh))
            endif
            s := padl(iif(fl,"в т.ч. ",""),30)+;
                 put_val(arr_bukva[i,4],6)+put_kopE(arr_bukva[i,3],13)+;
                 put_val(arr_bukva[i,6],6)+put_kopE(arr_bukva[i,5],13)+" "
            if (j := ascan(mm_bukva,{|x| x[2] == arr_bukva[i,2]})) > 0
              s += mm_bukva[j,1]
            else
              s += arr_bukva[i,2]
            endif
            add_string(s)
            fl := .f.
          endif
        next
      endif
      add_string("")
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
        if empty(arr_bukva[i,7])
          if fl
            add_string(replicate("-",sh))
          endif
          s := padl(iif(fl,"в т.ч. ",""),30)+;
               put_val(arr_bukva[i,4],6)+put_kopE(arr_bukva[i,3],13)+;
               put_val(arr_bukva[i,6],6)+put_kopE(arr_bukva[i,5],13)+" "
          if (j := ascan(mm_bukva,{|x| x[2] == arr_bukva[i,2]})) > 0
            s += mm_bukva[j,1]
          else
            s += arr_bukva[i,2]
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

*****
Static Function add_tmp_os(_sum,_kol,_sum1,_kol1)
if !emptyall(_sum1,_kol1)
  atmp_os[5] += _sum1 ; arr_uch[5] += _sum1
  atmp_os[6] += _kol1 ; arr_uch[6] += _kol1
endif
atmp_os[3] += _sum ; arr_uch[3] += _sum
atmp_os[4] += _kol ; arr_uch[4] += _kol
return NIL

*****
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

*****
Static Function s33_statist(k3,k4)
Local j, arr_os := {}
dbcreate(cur_dir+"tmp_os", {{"kod","N",3,0},{"name","C",30,0},;
                    {"p3","N",17,2},{"p4","N",7,0},;
                    {"p5","N",17,2},{"p6","N",7,0}} )
use (cur_dir+"tmp_os") new
index on str(kod,3) to (cur_dir+"tmp_os")
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

*****
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

*****
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

*

***** информация по конкретному счету
Function s4_statist()
Local buf := savescreen(), buf24 := save_maxrow(), i, j, arr_blk,;
  sh := 108, HH := 57, reg_print := 3, name_file := "infschet"+stxt
Private atmp_os[8], arr_uch[8]
if input_schet(0)
  WaitStatus()
  if R_Use(dir_server+"human_",,"HUMAN_") .and. ;
      R_Use(dir_server+"human",dir_server+"humans","HUMAN") .and. ;
       R_Use(dir_server+"human_u",dir_server+"human_u","HU") .and. ;
        R_Use(dir_server+"mo_otd",,"OTD") .and. ;
         R_Use(dir_server+"slugba",dir_server+"slugba","SL") .and. ;
          R_Use(dir_server+"uslugi",dir_server+"uslugi","USL") .and. ;
           R_Use(dir_server+"schet_",,"SCHET_") .and. ;
            R_Use(dir_server+"schet",,"SCHET")
    set relation to recno() into SCHET_
    goto (glob_schet)
    if schet->lpu > 0
      glob_uch[1] := schet->lpu
      glob_uch[2] := inieditspr(A__POPUPMENU,dir_server+"mo_uch",schet->lpu)
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

*****
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

*****
Function s42_statist(nKey,oBrow)
Local buf, rec, k := -1
if nkey == K_F9
  viewtext("infschet"+stxt,,,,.t.,,,3)
endif
return k

*

***** для ТФОМС (по ф.14)
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
dbcreate(cur_dir+"tmp_smo",adbf)
use (cur_dir+"tmp_smo") new alias TMP
index on smo to (cur_dir+"tmp_smo1")
index on nkomu to (cur_dir+"tmp_smo2")
set index to (cur_dir+"tmp_smo1"),(cur_dir+"tmp_smo2")
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
set relation to recno() into SCHET_
set filter to empty(schet_->IS_DOPLATA)
if pds == 1
  dbseek(begin_date,.t.)
  index on pdate to (cur_dir+"tmp_s") while pdate <= end_date
elseif pds == 2
  if mdate_reg == NIL
    index on pdate to (cur_dir+"tmp_s") ;
          for between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_m[5],arr_m[6])
  else
    index on pdate to (cur_dir+"tmp_s") ;
          for between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_m[5],arr_m[6]) ;
                 .and. schet_->NREGISTR==0 .and. date_reg_schet() <= mdate_reg
  endif
else
  index on pdate to (cur_dir+"tmp_s") ;
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

*****
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

*****
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

*

***** 18.02.14
Function s53statist(ltip, arr_m, begin_date, end_date)
Local i, j, k, s, buf := save_maxrow(), arr, mstr_crb, mismo,;
      fl_exit := .f., sh := 80, HH := 59, reg_print := 2, lshifr1,;
      arr_title, name_file := "tfomsf14"+stxt, flag_uet := .t., koef,;
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
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new alias TMP
index on str(tip,2)+shifr to (cur_dir+"tmp")
use (cur_dir+"tmp_smo") index (cur_dir+"tmp_smo1") new alias TMP_SMO
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to u_kod into USL
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
set relation to recno() into HUMAN_
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
set relation to recno() into SCHET_
set filter to empty(schet_->IS_DOPLATA) .and. !empty(val(schet_->smo))
if pds == 1
  dbseek(begin_date,.t.)
  index on pdate to (cur_dir+"tmp_s") while pdate <= end_date
elseif pds == 2
  if mdate_reg == NIL
    index on pdate to (cur_dir+"tmp_s") ;
          for between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_m[5],arr_m[6])
  else
    index on pdate to (cur_dir+"tmp_s") ;
          for between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_m[5],arr_m[6]) ;
                 .and. schet_->NREGISTR==0 .and. date_reg_schet() <= mdate_reg
  endif
else
  index on pdate to (cur_dir+"tmp_s") ;
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
title_schet_akt(sh)
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
index on str(tip,2)+fsort_usl(shifr) to (cur_dir+"tmp")
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

*

*****
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

*****
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

*

*****
Function uzkie2spec()
Static mm_perso := {{"Персонал",1},{"Персонал+услуги",2},;
                    {"Услуги",3},{"Услуги+персонал",4}}
Local buf := savescreen(), r1 := 13, tmp_color, j
Private mstrah := padr(glob_strah[2],30), m1strah := glob_strah[1], ;
        m1usl := mm_danet[1,2], musl := mm_danet[1,1],;
        m1period := 0, mperiod := space(10), parr_m,;
        mprocent := 0, mperso := mm_perso[1,1], m1perso := mm_perso[1,2],;
        msumma := 0, gl_area := {r1,0,23,79,0}, arr_usl
arr_usl := UsllugiUzkieSpec()
box_shadow(r1,2,22,77,color1,"Подсчет услуг",color8)
tmp_solor := setcolor(cDataCGet)
do while .t.
  @ r1+2,4 say "Период времени" get mperiod ;
         reader {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c),;
                      if(k==nil,nil,(parr_m:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION,,,.f.)}
  @ r1+3,4 say "Страховая компания" get mstrah ;
      reader {|x|menu_reader(x,glob_arr_smo,A__MENUVERT,,,.f.)}
  @ r1+4,4 say "Разрешить исключение некоторых услуг из списка ТФОМС?" get musl ;
      reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
  @ r1+5,4 say "Внешний вид документа" get mperso ;
      reader {|x|menu_reader(x,mm_perso,A__MENUVERT,,,.f.)}
  @ r1+6,4 say "Процент для ассистента (в случае его присутствия)" get mprocent pict "99"
  @ r1+7,4 say "Сумма для распределения" get msumma pict "99999999.99"
  status_key("^<Esc>^ - выход;  ^<PgDn>^ - просмотр результатов подсчета")
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
  f1uzkie2spec()
enddo
restscreen(buf)
setcolor(tmp_solor)
return NIL

*****
Function f1uzkie2spec()
Local fl_exit := .f., sh, HH := 60, reg_print, n_file := "_uz_spec"+stxt,;
      adbf := {}, lshifr, mkol := 0, delta, arr_fields := {}, abitusl,;
      begin_date := parr_m[7], end_date := parr_m[8]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
if m1usl == 1
  abitusl := {}
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"human_u",dir_server+"human_u","HU")
  set relation to u_kod into USL
  R_Use(dir_server+"human",dir_server+"humans","HUMAN")
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
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
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
if m1perso < 3
  index on str(kod_perso,4)+usl_shifr to (cur_dir+"tmp")
else
  index on usl_shifr+str(kod_perso,4) to (cur_dir+"tmp")
endif
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to u_kod into USL
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
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
    R_Use(dir_server+"mo_pers",,"P2")
    tmp->(dbeval({|| p2->(dbgoto(tmp->kod_perso)), ;
                     tmp->tab_nomer:=p2->tab_nom, ;
                     tmp->fio_perso:=p2->fio }))
    aadd(arr_fields,"tab_nomer")
    aadd(arr_fields,"fio_perso")
  endif
  arr_title := array(3) ; afill(arr_title,"")
  select TMP
  if m1perso < 3
    index on upper(fio_perso)+usl_shifr to (cur_dir+"tmp")
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
    d_file := cur_dir+"UZ_SPEC"+sdbf
    if !del_dbf_file(d_file)
      return NIL
    endif
    use (cur_dir+"tmp") new
    __dbCopy(d_file,arr_fields,,,,,.F.,) // copy fields kod_perso,fio_perso,kol_usl to (d_file)
    close databases
    n_message({"Создан файл для загрузки в Excel: "+d_file},,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
  endif
endif
close databases
return NIL

*

*****
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
R_Use(dir_server+"organiz",,"ORG")
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
if (j := ascan(arr_rekv_smo,{|x| int(val(x[1]))==glob_strah[1]})) == 0
  j := len(arr_rekv_smo) // если не нашли - печатаем реквизиты ТФОМС
endif
k := perenos(t_arr,arr_rekv_smo[j,2],sh-17)
add_string(padr("Плательщик:",17)+t_arr[1])
for i := 2 to k
  add_string(space(17)+t_arr[2])
next
k := perenos(t_arr,arr_rekv_smo[j,6],sh-17)
add_string(padr("Адрес:",17)+t_arr[1])
for i := 2 to k
  add_string(space(17)+t_arr[2])
next
add_string("Расчетный счет:  "+alltrim(arr_rekv_smo[j,8])+" "+alltrim(arr_rekv_smo[j,7]))
add_string("БИК:             "+arr_rekv_smo[j,9])
add_string("Город:           "+"")
add_string("ИНН:             "+alltrim(arr_rekv_smo[j,3])+iif(empty(arr_rekv_smo[j,4]),"","/"+arr_rekv_smo[j,4]))
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

***** 26.02.20 многовариантный поиск
Function s_mnog_poisk()
Static mm_rak := {;
  {"все случаи",0},;
  {"за исключением полностью неоплачиваемых",1},;
  {"полностью неоплачиваемые и перевыставленные",2},;
  {"полностью неоплачиваемые и неперевыставленные",3},;
  {"полностью неоплачиваемые",4},;
  {"частично неоплачиваемые",5},;
  {"полностью или частично неоплачиваемые",6};
}
Static mm_d_p_m := {;  // "Диспансеризация/Профилактика/Медосмотр?"
  {"диспансеризация детей-сирот при стационаре I этап",1},;
  {"диспансеризация детей-сирот при стационаре II этап",2},;
  {"диспансеризация детей-сирот под опекой I этап",3},;
  {"диспансеризация детей-сирот под опекой II этап",4},;
  {"диспансеризация взрослого населения I этап (1 раз в 3 года)",5},;
  {"диспансеризация взрослого населения II этап (1 раз в 3 года)",6},;
  {"профилактика взрослого населения",7},;
  {"диспансеризация взрослого населения I этап (1 раз в 2 года)",8},;
  {"диспансеризация взрослого населения II этап (1 раз в 2 года)",9},;
  {"профосмотр несовершеннолетних I этап",10},;
  {"профосмотр несовершеннолетних II этап",11},;
  {"предварительный осмотр несовершеннолетних I этап",12},;
  {"предварительный осмотр несовершеннолетних II этап",13},;
  {"периодический осмотр несовершеннолетних",14};
}
Static mm_perevyst := {;
  {"все случаи",1},;
  {"без учёта случаев с отказом (перевыставленных)",0},;
  {"только случаи с отказом (которые были перевыставлены)",2};
}
Static mm_g_selo :=  {{"город",1},{"село",2}}
Static mm_regschet := {{"Не зарегистрированные счета",1},{"Зарегистрированные счета",2}}
Static mm_schet := {{"Не попавшие в счета",1},{"Попавшие в счета",2}}
Static mm_reestr := {{"Не попавшие в реестры",1},{"Попавшие в реестры",2}}
Static mm_zav_lech := {{"Незаконченный случай",1},{"законченный случай",2}}
Static mm_dvojn := {{"все случаи",1},{"только двойные случаи",2},{"все, кроме двойных случаев",3}}
Local mm_tmp := {}, k, adiag_talon[16]
Local buf := savescreen(), tmp_color := setcolor(cDataCGet),;
      tmp_help := help_code, hGauge, name_file := "in_boln"+stxt,;
      sh := 80, HH := 77, i, a_diagnoz[10], ;
      mm_da_net := {{"нет",1},{"да ",2}}, lvid_doc := 0,;
      menu_bolnich := {{"нет",1},{"да",2},{"родители",3}},;
      mm_mest := {{"Волгоград или область",1},{"иногородние",2}},;
      mm_dom := {{"-----",0},{"в поликлинике",1},{"на дому",2}},;
      mm_invalid := {{"неважно",0},{"любая группа",9},{"1 группа",1},{"2 группа",2},{"3 группа",3},{"дети-инвалиды",4}},;
      mm_prik := {{"неважно",0},;
                  {"прикреплён к нашей МО",1},;
                  {"не прикреплён к нашей МО",2}},;
      tmp_file := "tmp_mn_p"+sdbf,;
      k_diagnoz, k_usl, tt_diagnoz[10], tt_usl[10]
if mem_dom_aktiv == 1
  aadd(mm_dom,{"на дому-АКТИВ",3})
  aadd(mm_dom,{"на дому + на дому-АКТИВ",4})
endif
Private ssumma := 0, srak_s := 0, suet := 0, p_regim := 1, mm_company := {}, is_kategor2 := .f.,;
        mm_rslt := {}, mm_ishod := {}, rslt_umolch := -1, ishod_umolch := -1
Private tmp_V006 := create_classif_FFOMS(0,"V006") // USL_OK
//Private tmp_V008 := create_classif_FFOMS(0,"V008") // VIDPOM
Private tmp_V002 := create_classif_FFOMS(0,"V002") // PROFIL
//Private tmp_V010 := create_classif_FFOMS(0,"V010") // IDSP
Private tmp_V009 := cut_glob_array(glob_V009,sys_date) // rslt
Private tmp_V012 := cut_glob_array(glob_V012,sys_date) // ishod
Private arr_doc := {"Дата рожд.",;
                    "Адрес",;
                    "Сроки леч.",;
                    "Диагноз",;
                    "Счет",;
                    "РАК",;
                    "Леч.врач",;
                    "Услуги",;
                    "Доп.критерий"}
if yes_parol
  aadd(arr_doc, "Дата ввода")
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
  return NIL
endif
if yes_bukva
  Private md_plus := array(len(yes_d_plus))
  k_plus := len(md_plus)
  afill(md_plus," ")
  aeval(md_plus, {|x,i| md_plus[i] := substr(yes_d_plus,i,1) } )
  sd_plus := array(k_plus)
  afill(sd_plus,0)
endif
Private pr_arr := {}, pr_arr_otd := {}, is_talon := ret_is_talon(), arr_tal_diag[2,3], mm_pz := {}
afillall(arr_tal_diag,0)
for i := 1 to len(glob_array_PZ_19)
  aadd(mm_pz, {glob_array_PZ_19[i,3],glob_array_PZ_19[i,1]})
next
if is_talon
  is_kategor2 := !empty(stm_kategor2)
endif
//
R_Use(dir_server+"mo_otd",,"OTD")
dbeval({|| aadd(pr_arr,{otd->(recno()),otd->name,otd->kod_lpu,""}) },;
       {|| f_is_uch(st_a_uch,otd->kod_lpu) .and. between_date(otd->dbegin,otd->dend,sys_date)} )
R_Use(dir_server+"mo_uch",,"UCH")
aeval(pr_arr, {|x,i| dbGoto(x[3]), pr_arr[i,4] := uch->name } )
//
asort(pr_arr,,,{|x,y| iif(x[3] == y[3], upper(x[2]) < upper(y[2]), upper(x[4]) < upper(y[4])) } )
aeval(pr_arr, {|x| aadd(pr_arr_otd,x[2]+" "+x[4]) } )
close databases
//
lvid_doc := setbit(lvid_doc,3)
lvid_doc := setbit(lvid_doc,5)
//
Private pdate_lech, pdate_schet, pdate_usl, pdate_vvod, mstr_crb := 0, mstr_crbM := {}, mslugba
//
dbcreate(cur_dir+"tmp", {;
     {"U_KOD"  ,    "N",      4,      0},;  // код услуги
     {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"U_NAME",     "C",     65,      0};   // наименование услуги
  })
use (cur_dir+"tmp")
index on str(u_kod,4) to (cur_dir+"tmpk")
index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
tmp->(dbCloseArea())
//
dbcreate(cur_dir+"tmpF", {;
     {"U_KOD"  ,    "N",      6,      0},;  // код услуги
     {"U_SHIFR",    "C",     20,      0},;  // шифр услуги
     {"U_NAME",     "C",    255,      0};   // наименование услуги
  })
use (cur_dir+"tmpF")
index on str(u_kod,6) to (cur_dir+"tmpFk")
index on fsort_usl(u_shifr) to (cur_dir+"tmpFn")
tmpF->(dbCloseArea())
//
aadd(mm_tmp, {"date_lech","N",4,0,NIL,;
              {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c),;
                      if(k==nil,nil,(pdate_lech:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION)},;
              0,{|| space(10) },;
              'Дата окончания лечения'})
aadd(mm_tmp, {"date_schet","N",4,0,NIL,;
              {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c),;
                      if(k==nil,nil,(pdate_schet:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION)},;
              0,{|| space(10) },;
              'Дата выписки счета'})
aadd(mm_tmp, {"date_usl","N",4,0,NIL,;
              {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c),;
                      if(k==nil,nil,(pdate_usl:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION)},;
              0,{|| space(10) },;
              'Дата оказания услуг'})
aadd(mm_tmp, {"date_vvod","N",4,0,NIL,;
              {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c),;
                      if(k==nil,nil,(pdate_vvod:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION)},;
              0,{|| space(10) },;
              '  дата ввода информации'})
if yes_vypisan == B_END
  aadd(mm_tmp, {"zav_lech","N",1,0,NIL,;
                {|x|menu_reader(x,mm_zav_lech,A__MENUVERT)},;
                0,{|| space(10) },;
                "Факт завершения лечения?"})
endif
aadd(mm_tmp, {"reestr","N",1,0,NIL,;
              {|x|menu_reader(x,mm_reestr,A__MENUVERT)},;
              0,{|| space(10) },;
              "В реестре?"})
aadd(mm_tmp, {"schet","N",1,0,NIL,;
              {|x|menu_reader(x,mm_schet,A__MENUVERT)},;
              0,{|| space(10) },;
              "В счёте?"})
aadd(mm_tmp, {"regschet","N",1,0,NIL,;
              {|x|menu_reader(x,mm_regschet,A__MENUVERT)},;
              0,{|| space(10) },;
              "Счёт зарегистрирован в ТФОМС?",,;
              {|| m1schet == 2 }})
aadd(mm_tmp, {"perevyst","N",1,0,NIL,;
              {|x|menu_reader(x,mm_perevyst,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_perevyst,x)},;
              "Какие случаи учитывать?"})
aadd(mm_tmp, {"rak","N",1,0,NIL,;
              {|x|menu_reader(x,mm_rak,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_rak,x)},;
              "Оплата в актах контроля (РАК)"})
aadd(mm_tmp, {"d_p_m","N",10,0,NIL,;
              {|x|menu_reader(x,mm_d_p_m,A__MENUBIT)},;
              0,{|x|inieditspr(A__MENUBIT,mm_d_p_m,x)},;
              "Диспансеризация/Профилактика/Медосмотр?"})
aadd(mm_tmp, {"pz","N",2,0,NIL,;
              {|x|menu_reader(x,mm_pz,A__MENUVERT_SPACE)},;
              0,{|| space(10) },;
              "Вид план-заказа"})
aadd(mm_tmp, {"dvojn","N",1,0,NIL,;
              {|x|menu_reader(x,mm_dvojn,A__MENUVERT)},;
              1,{|x|inieditspr(A__MENUVERT,mm_dvojn,x)},;
              "Учитывать двойные случаи?"})
aadd(mm_tmp, {"zno","N",1,0,NIL,;
              {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
              0,{|| space(10) },;
              "Признак подозрения на ЗНО?"})
aadd(mm_tmp, {"kol_lu","N",2,0,,;
              nil,;
              0,nil,;
              "Количество листов учета по одному больному более"})
aadd(mm_tmp, {"kol_pos","N",1,0,NIL,;
              {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
              0,{|| space(10) },;
              "Подсчитывать количество амбулаторных и стоматологических посещений?"})
aadd(mm_tmp, {"uch_doc","C",10,0,"@!",;
              nil,;
              space(10),nil,;
              "№ амб.карты/истории болезни (шаблон)"})
Private arr_uchast := {}
if is_uchastok > 0
  aadd(mm_tmp, {"bukva","C",1,0,"@!",;
                nil,;
                " ",nil,;
                "Буква (перед участком)"})
  aadd(mm_tmp, {"uchast","N",1,0,,;
                {|x|menu_reader(x,{{ |k,r,c| get_uchast(r+1,c) }},A__FUNCTION)},;
                0,{|| init_uchast(arr_uchast) },;
                "Участок (участки)"})
endif
if glob_mo[_MO_IS_UCH]
  aadd(mm_tmp, {"o_prik","N",1,0,NIL,;
                {|x|menu_reader(x,mm_prik,A__MENUVERT)},;
                0,{|x|inieditspr(A__MENUVERT,mm_prik,x)},;
                "Отношение к прикреплению на начало лечения"})
endif
aadd(mm_tmp, {"fio","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "ФИО (начальные буквы или шаблон)"})
aadd(mm_tmp, {"inostran","N",1,0,NIL,;
              {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
              0,{|| space(10) },;
              "Документы иностранных граждан:"})
aadd(mm_tmp, {"gorod_selo","N",2,0,NIL,;
              {|x|menu_reader(x,mm_g_selo,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Житель:"})
aadd(mm_tmp, {"mi_git","N",2,0,NIL,;
              {|x|menu_reader(x,mm_mest,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Место жительства:"})
aadd(mm_tmp, {"_okato","C",11,0,NIL,;
              {|x|menu_reader(x,{{ |k,r,c| get_okato_ulica(k,r,c,{k,m_okato,}) }},A__FUNCTION)},;
              space(11),{|x| space(11)},;
              'Адрес регистрации (ОКАТО)'})
aadd(mm_tmp, {"adres","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "Улица (подстрока или шаблон)"})
aadd(mm_tmp, {"mr_dol","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "Место работы (подстрока или шаблон)"})
aadd(mm_tmp, {"invalid","N",1,0,NIL,;
              {|x|menu_reader(x,mm_invalid,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_invalid,x)},;
              "Наличие инвалидности"})
aadd(mm_tmp, {"kategor","N",4,0,NIL,;
              {|x|menu_reader(x,mo_cut_menu(stm_kategor),A__MENUVERT)},;
              0,{|| space(10) },;
              "Код категории льготы"})
if is_talon
  if is_kategor2
    aadd(mm_tmp, {"kategor2","N",4,0,NIL,;
                  {|x|menu_reader(x,stm_kategor2,A__MENUVERT)},;
                  0,{|| space(10) },;
                  "Категория МО"})
  endif
endif
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
aadd(mm_tmp, {"USL_OK","N",3,0,NIL,;
              {|x|menu_reader(x,tmp_V006,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Медицинская помощь: условия оказания",;
              {|g,o| f_valid_usl_ok(g,o,.f.) }})
/*aadd(mm_tmp, {"VIDPOM","N",3,0,NIL,;
              {|x|menu_reader(x,tmp_V008,A__MENUVERT)},;
              -1,{|| space(10) },;
              "  вид"})*/
aadd(mm_tmp, {"PROFIL","N",3,0,NIL,;
              {|x|menu_reader(x,tmp_V002,A__MENUVERT)},;
              -1,{|| space(10) },;
              "  профиль (в случае)"})
aadd(mm_tmp, {"PROFIL_U","N",3,0,NIL,;
              {|x|menu_reader(x,tmp_V002,A__MENUVERT)},;
              -1,{|| space(10) },;
              "  профиль (в услуге)"})
/*aadd(mm_tmp, {"IDSP","N",3,0,NIL,;
              {|x|menu_reader(x,tmp_V010,A__MENUVERT)},;
              -1,{|| space(10) },;
              "  способ оплаты"})*/
aadd(mm_tmp, {"rslt","N",3,0,NIL,;
              {|x|menu_reader(x,mm_rslt,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Результат обращения",,;
              {|| m1usl_ok > 0 }})
aadd(mm_tmp, {"ishod","N",3,0,NIL,;
              {|x|menu_reader(x,mm_ishod,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Исход заболевания",,;
              {|| m1usl_ok > 0 }})
/*if is_talon
  aadd(mm_tmp, {"povod","N",2,0,NIL,;
                {|x|menu_reader(x,stm_povod,A__MENUVERT)},;
                0,{|| space(10) },;
                "Повод обращения"})
  aadd(mm_tmp, {"travma","N",2,0,NIL,;
                {|x|menu_reader(x,stm_travma,A__MENUVERT)},;
                -1,{|| space(10) },;
                "Вид травмы"})
endif*/
aadd(mm_tmp, {"bolnich1","N",1,0,NIL,;
              {|x|menu_reader(x,menu_bolnich,A__MENUVERT)},;
              0,{|| space(10) },;
              "Больничный?"})
aadd(mm_tmp, {"bolnich","N",3,0,,;
              nil,;
              0,nil,;
              "Кол-во дней на больничном более"})
aadd(mm_tmp, {"vrach1","N",5,0,NIL,;
              nil,;
              0,nil,;
              "Лечащий врач",;
              {|g| st_v_vrach(g,"mvrach") } })
aadd(mm_tmp, {"vrach","C",50,0,NIL,;
              nil,;
              space(50),nil,;
              "            ",,;
              {|| .f. } })
if yes_bukva
  aadd(mm_tmp, {"status_st","C",5,0,"@!",;
                nil,;
                space(5),nil,;
                "Статус стоматологического больного"})
endif
aadd(mm_tmp, {"diag","C",5,0,"@!",;
              nil,;
              space(5),nil,;
              "Шифр диагноза (осн.+сопут.): [ с ]",;
              {|| val2_10diag() }})
aadd(mm_tmp, {"diag1","C",5,0,"@!",;
              nil,;
              space(5),nil,;
              "                            [ по ]",;
              {|| val2_10diag() }})
aadd(mm_tmp, {"kod_diag","C",5,0,"@!",;
              nil,;
              space(5),nil,;
              "Шифр ОСНОВНОГО диагноза: [ с ]",;
              {|| val2_10diag() }})
aadd(mm_tmp, {"kod_diag1","C",5,0,"@!",;
              nil,;
              space(5),nil,;
              "                        [ по ]",;
              {|| val2_10diag() }})
aadd(mm_tmp, {"soput_d","C",5,0,"@!",;
              nil,;
              space(5),nil,;
              "Шифр СОПУТСТВУЮЩЕГО диагноза: [ с ]",;
              {|| val2_10diag() }})
aadd(mm_tmp, {"soput_d1","C",5,0,"@!",;
              nil,;
              space(5),nil,;
              "                             [ по ]",;
              {|| val2_10diag() }})
aadd(mm_tmp, {"osl_d","C",5,0,"@!",;
              nil,;
              space(5),nil,;
              "Шифр диагноза ОСЛОЖНЕНИЯ: [ с ]",;
              {|| val2_10diag() }})
aadd(mm_tmp, {"osl_d1","C",5,0,"@!",;
              nil,;
              space(5),nil,;
              "                         [ по ]",;
              {|| val2_10diag() }})
aadd(mm_tmp, {"pred_d","C",5,0,"@!",;
              nil,;
              space(5),nil,;
              "Шифр ПРЕДВАРИТЕЛЬНОГО диагноза: [ с ]",;
              {|| val2_10diag() }})
aadd(mm_tmp, {"pred_d1","C",5,0,"@!",;
              nil,;
              space(5),nil,;
              "                               [ по ]",;
              {|| val2_10diag() }})
if is_talon
  aadd(mm_tmp, {"talon_diag","N",1,0,NIL,;
                 {|x|menu_reader(x,{{|k,r,c|f_mn_tal_diag(k,r,c)}},A__FUNCTION)},;
                0,{|| space(10) },;
                "Присутствует талон амбулаторного пациента?",,;
                {|| !emptyall(mdiag,mkod_diag,msoput_d) } })
endif
aadd(mm_tmp, {"otd","N",3,0,NIL,;
              {|x|menu_reader(x,{ { |k,r,c| get_otd(k,r+1,c) }},A__FUNCTION)},;
              0,{|| space(10) },;
              "Отделение, в котором выписан счет" })
aadd(mm_tmp, {"ist_fin","N",2,0,NIL,;
              {|x|menu_reader(x,mm_ist_fin,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Источник финансирования"})
aadd(mm_tmp, {"komu","N",2,0,NIL,;
              {|x|menu_reader(x,mm_komu,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Принадлежность счёта",;
              {|g,o| f_valid_komu(g,o) }})
aadd(mm_tmp, {"company","N",5,0,NIL,;
              {|x|menu_reader(x,mm_company,A__MENUVERT)},;
              0,{|| space(10) },;
              "  ==>",,{||eq_any(m1komu,0,1,3)}})
aadd(mm_tmp, {"uslugi","N",4,0,NIL,;
              {|x|menu_reader(x,{ { |k,r,c| ob2_v_usl(.t.,r+1,"Услуги (ТФОМС)") }},A__FUNCTION)},;
              0,{|| space(10) },;
              "Оказанные услуги (ТФОМС)" })
aadd(mm_tmp, {"uslugiF","N",4,0,NIL,;
              {|x|menu_reader(x,{ { |k,r,c| obF2_v_usl(.t.,r+1,"Услуги (ФФОМС)","tmpF") }},A__FUNCTION)},;
              0,{|| space(10) },;
              "Оказанные услуги (ФФОМС)" })
aadd(mm_tmp, {"dom","N",1,0,NIL,;
              {|x|menu_reader(x,mm_dom,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_dom,x)},;
              "Где оказана услуга",,;
              {|| m1usl_ok == 3 }})
aadd(mm_tmp, {"otd_usl","N",3,0,NIL,;
              {|x|menu_reader(x,{ { |k,r,c| get_otd(k,r+1,c) }},A__FUNCTION)},;
              0,{|| space(10) },;
              "Отделение, в котором оказана услуга" })
aadd(mm_tmp, {"vr1","N",5,0,NIL,;
              nil,;
              0,nil,;
              "Врач, оказавший услугу(и)",;
              {|g| st_v_vrach(g,"mvr") } })
aadd(mm_tmp, {"vr","C",50,0,NIL,;
              nil,;
              space(50),nil,;
              "                         ",,;
              {|| .f. } })
aadd(mm_tmp, {"isvr","N",1,0,NIL,;
              {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
              0,{|| space(10) },;
              "Код врача проставлен?",,;
              {|| mvr1==0 } })
aadd(mm_tmp, {"as1","N",5,0,NIL,;
              nil,;
              0,nil,;
              "Ассистент, оказавший услугу(и)",;
              {|g| st_v_vrach(g,"mas") } })
aadd(mm_tmp, {"as","C",50,0,NIL,;
              nil,;
              space(50),nil,;
              "                              ",,;
              {|| .f. } })
aadd(mm_tmp, {"isas","N",1,0,NIL,;
              {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
              0,{|| space(10) },;
              "Код ассистента проставлен?",,;
              {|| mas1==0 } })
aadd(mm_tmp, {"vras1","N",5,0,NIL,;
              nil,;
              0,nil,;
              "Человек, оказавший услугу(и)",;
              {|g| st_v_vrach(g,"mvras") } })
aadd(mm_tmp, {"vras","C",50,0,NIL,;
              nil,;
              space(50),nil,;
              "                            ",,;
              {|| .f. } })
aadd(mm_tmp, {"slug_usl","N",3,0,NIL,;
              {|x|menu_reader(x, ;
                { { |k,r,c| get_slugba(k,r,c) }},A__FUNCTION)},;
              0,{|| space(10) },;
              "Служба, в которой оказана услуга" })
aadd(mm_tmp, {"srok_min","N",3,0,,;
              nil,;
              0,nil,;
              "Срок лечения (минимальный)"})
aadd(mm_tmp, {"srok_max","N",3,0,,;
              nil,;
              0,nil,;
              "Срок лечения (максимальный)"})
aadd(mm_tmp, {"summa_min","N",10,2,,;
              nil,;
              0,nil,;
              "Сумма лечения (минимальная)"})
aadd(mm_tmp, {"summa_max","N",10,2,,;
              nil,;
              0,nil,;
              "Сумма лечения (максимальная)"})
aadd(mm_tmp, {"vid_doc","N",5,0,NIL,;
              {|x|menu_reader(x,arr_doc,A__MENUBIT)},;
              lvid_doc,{|x|inieditspr(A__MENUBIT,arr_doc,x)},;
              "Вид документа",NIL})
delete file (tmp_file)
init_base(tmp_file,,mm_tmp,0)
//
R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
k := f_edit_spr(A__APPEND,mm_tmp,"множественному запросу",;
                "e_use(cur_dir+'tmp_mn_p')",0,1,,,,,"write_mn_p")
if k > 0
  mywait()
  use (tmp_file) new alias MN
  if mn->ist_fin >= 0
    Private _arr_if := {mn->ist_fin}, _what_if := _init_if(), _arr_komit := {}
  endif
  if is_talon .and. mn->kategor == 0 .and. mn->talon_diag == 0
    is_talon := (is_kategor2 .and. mn->kategor2 > 0)
  endif
  if yes_vypisan == B_END .and. mn->zav_lech > 0
    Private p_zak_sl := (mn->zav_lech==2)  // ? законченный случай
    mn->zav_lech := yes_vypisan + mn->zav_lech - 1
  endif
  // заменить таб.номер на код
  R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
  if mn->vrach1 > 0
    find (str(mn->vrach1,5))
    if found()
      mn->vrach1 := perso->kod
    endif
  endif
  if mn->vr1 > 0
    find (str(mn->vr1,5))
    if found()
      mn->vr1 := perso->kod
    endif
  endif
  if mn->as1 > 0
    find (str(mn->as1,5))
    if found()
      mn->as1 := perso->kod
    endif
  endif
  if mn->vras1 > 0
    find (str(mn->vras1,5))
    if found()
      mn->vras1 := perso->kod
    endif
  endif
  perso->(dbCloseArea())
  if mn->date_schet > 0
    p_regim := 2
  elseif mn->date_lech > 0
    p_regim := 1
  elseif mn->date_usl > 0
    p_regim := 3
  endif
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
  Private arr_usl := {}, arr_uslF := {}, fl_summa := .t., NUMdiag, NUMdiag1
  // заранее диапазоны диагнозов переведём в числовые значения
  if !emptyall(mn->diag,mn->diag1)
    NUMdiag := diag2num(mn->diag)
    NUMdiag1 := diag2num(mn->diag1)
  endif
  Private NUMkod_diag, NUMkod_diag1
  if !emptyall(mn->kod_diag,mn->kod_diag1)
    NUMkod_diag := diag2num(mn->kod_diag)
    NUMkod_diag1 := diag2num(mn->kod_diag1)
  endif
  Private NUMsoput_d, NUMsoput_d1
  if !emptyall(mn->soput_d,mn->soput_d1)
    NUMsoput_d := diag2num(mn->soput_d)
    NUMsoput_d1 := diag2num(mn->soput_d1)
  endif
  Private NUMpred_d, NUMpred_d1
  if !emptyall(mn->pred_d,mn->pred_d1)
    NUMpred_d := diag2num(mn->pred_d)
    NUMpred_d1 := diag2num(mn->pred_d1)
  endif
  Private NUMosl_d, NUMosl_d1
  if !emptyall(mn->osl_d,mn->osl_d1)
    NUMosl_d := diag2num(mn->osl_d)
    NUMosl_d1 := diag2num(mn->osl_d1)
  endif
  if mn->otd_usl > 0 .or. mn->vr1 > 0 .or. mn->as1 > 0 .or. ;
       mn->vras1 > 0 .or. mn->slug_usl > 0 .or. mn->uslugi > 0 .or. mn->uslugiF > 0 .or. mn->dom > 0
    fl_summa := .f.
  endif
  if mn->uslugi > 0
    fl_rak_usl := .f.
    use (cur_dir+"tmp") index (cur_dir+"tmpn") new
    go top
    dbeval({|| aadd(arr_usl, {tmp->u_kod,tmp->u_shifr,tmp->u_name,0,0,0}),;
               iif(left(tmp->u_shifr,3)=="71.", fl_rak_usl := .t., );
           })
    tmp->(dbCloseArea())
    if !isbit(mn->vid_doc,6)
      fl_rak_usl := .f.
    endif
  endif
  if mn->uslugiF > 0
    use (cur_dir+"tmpF") index (cur_dir+"tmpFn") new
    go top
    dbeval({|| aadd(arr_uslF, {tmpf->u_kod,tmpf->u_shifr,tmpf->u_name,0,0,0});
           })
    tmpf->(dbCloseArea())
  endif
  flag_hu := (mn->otd_usl > 0 .or. mn->vr1 > 0 .or. mn->as1 > 0 .or. mn->vras1 > 0 .or. ;
              mn->slug_usl > 0 .or. mn->uslugi > 0 .or. mn->dom > 0 .or. ;
              mn->kol_pos == 2 .or. mn->date_usl > 0 .or. mn->profil_u > 0)
  flag_huF := (mn->otd_usl > 0 .or. mn->vr1 > 0 .or. mn->as1 > 0 .or. mn->vras1 > 0 .or. ;
               mn->uslugiF > 0 .or. mn->dom > 0 .or. ;
               mn->kol_pos == 2 .or. mn->date_usl > 0 .or. mn->profil_u > 0)
  dbcreate(cur_dir+"tmp",{{"kod",      "N", 7,0},;
                          {"kod_k",    "N", 7,0},;
                          {"stoim",    "N",10,2},;
                          {"rak_p",    "N", 3,0},;
                          {"rak_s",    "N",10,2}})
  use (cur_dir+"tmp") new
  dbcreate(cur_dir+"tmp_k",{{"kod_k","N",7,0},;
                            {"kol",  "N",6,0}})
  use (cur_dir+"tmp_k") new
  index on str(kod_k,7) to (cur_dir+"tmp_k")
  if mn->kol_pos == 2
    Private kol_pos_amb := 0, pol_pos_stom1 := 0, pol_pos_stom2 := 0, pol_pos_stom3 := 0
    dbcreate(cur_dir+"tmp_kp",{{"kod_k","N",7,0},;
                               {"data", "C",4,0}})
    use (cur_dir+"tmp_kp") new
    index on str(kod_k,7)+data to (cur_dir+"tmp_kp")
  endif
  f1_diag_statist_bukva()
  fl_exit := .f.
  if p_regim == 3  // по дате оказания усуги
    dbcreate(cur_dir+"tmp_hum",{{"kod","N",7,0}})
    use (cur_dir+"tmp_hum") new
    R_Use(dir_server+"human_u",dir_server+"human_ud","HU")
    find (pdate_usl[7])
    index on kod to (cur_dir+"tmp_hu") while date_u <= pdate_usl[8] UNIQUE
    go top
    do while !eof()
      select TMP_HUM
      append blank
      replace kod with hu->kod
      select HU
      skip
    enddo
    hu->(dbCloseArea())
    tmp_hum->(dbCloseArea())
  endif
  if mem_trudoem == 2
    useUch_Usl()
  endif
  Status_Key("^<Esc>^ - прервать поиск")
  if isbit(mn->vid_doc,6) .or. mn->rak > 0
    R_Use(dir_server+"mo_raksh",,"RAKSH")
    index on str(kod_h,7) to (cur_dir+"tmp_raksh")
  endif
  use_base("lusl")
  use_base("luslc")
  use_base("luslf")
  R_Use(dir_server+"mo_su",,"MOSU")
  R_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"human_u_",,"HU_")
  R_Use(dir_server+"human_u",dir_server+"human_u","HU")
  set relation to recno() into HU_, to u_kod into USL
  //
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",,"SCHET")
  set relation to recno() into SCHET_
  //
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART_, recno() into KART2
  //
  R_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_
  //
  Private c_view := 0, c_found := 0
  do case
    case p_regim == 1  // по дате окончания лечения
      select HUMAN
      set index to (dir_server+"humand")
      dbseek(dtos(pdate_lech[5]),.t.)
      do while human->k_data <= pdate_lech[6] .and. !eof()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if f_is_uch(st_a_uch,human->lpu)
          date_24(human->k_data)
          s1_mnog_poisk(@c_view,@c_found)
        endif
        select HUMAN
        skip
      enddo
    case p_regim == 2  // по дате выписки счета
      select HUMAN
      set index to (dir_server+"humans")
      select SCHET
      set index to (dir_server+"schetd")
      set filter to empty(schet_->IS_DOPLATA)
      dbseek(pdate_schet[7],.t.)
      do while schet->pdate <= pdate_schet[8] .and. !eof()
        date_24(c4tod(schet->pdate))
        select HUMAN
        find (str(schet->kod,6))
        do while human->schet == schet->kod
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          if f_is_uch(st_a_uch,human->lpu)
            s1_mnog_poisk(@c_view,@c_found)
          endif
          select HUMAN
          skip
        enddo
        if fl_exit ; exit ; endif
        select SCHET
        skip
      enddo
    case p_regim == 3  // по дате оказания усуги
      use (cur_dir+"tmp_hum") new
      set relation to kod into HUMAN
      go top
      do while !eof()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if f_is_uch(st_a_uch,human->lpu)
          date_24(human->k_data)
          s1_mnog_poisk(@c_view,@c_found)
        endif
        select TMP_HUM
        skip
      enddo
  endcase
  j := tmp->(lastrec())
  close databases
  if j == 0
    if !fl_exit
      func_error(4,"Нет сведений!")
    endif
  else
    mywait()
    use (tmp_file) new alias MN
    s1 := if(fl_summa, "  Сумма  ", "Стоимость")
    s2 := if(fl_summa, " лечения ", "  услуг  ")
    arr_title := {;
     "────────────────────────────────────────┬─────────",;
     "             Ф.И.О. больного            │"+ s1     ,;
     "                                        │"+ s2     ,;
     "────────────────────────────────────────┴─────────"}
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
      arr_title[1] += "┬────────"
      arr_title[2] += "│ Сроки  "
      arr_title[3] += "│лечения "
      arr_title[4] += "┴────────"
    endif
    if isbit(mn->vid_doc,4)
      arr_title[1] += "┬─────────────"
      arr_title[2] += "│   Диагноз   "
      arr_title[3] += "│             "
      arr_title[4] += "┴─────────────"
    endif
    if isbit(mn->vid_doc,5)
      arr_title[1] += "┬───────────────"
      arr_title[2] += "│ Номер и дата  "
      arr_title[3] += "│    счета      "
      arr_title[4] += "┴───────────────"
    endif
    if isbit(mn->vid_doc,6)
      arr_title[1] += "┬─────────"
      arr_title[2] += "│   РАК   "
      arr_title[3] += "│         "
      arr_title[4] += "┴─────────"
      R_Use(dir_server+"mo_raksh",cur_dir+"tmp_raksh","RAKSH")
    endif
    if isbit(mn->vid_doc,7)
      arr_title[1] += "┬─────"
      arr_title[2] += "│ Леч."
      arr_title[3] += "│ врач"
      arr_title[4] += "┴─────"
    endif
      if isbit(mn->vid_doc,8)
      arr_title[1] += "┬───────────────────────"
      arr_title[2] += "│                       "
      arr_title[3] += "│     Список услуг      "
      arr_title[4] += "┴───────────────────────"
    endif
    if isbit(mn->vid_doc,9)
      arr_title[1] += "┬────────"
      arr_title[2] += "│Дополнит"
      arr_title[3] += "│критерий"
      arr_title[4] += "┴────────"
    endif
    if yes_parol
      if isbit(mn->vid_doc,10)
        arr_title[1] += "┬──────────"
        arr_title[2] += "│Дата ввода"
        arr_title[3] += "│и оператор"
        arr_title[4] += "┴──────────"
      endif
    endif
    reg_print := f_reg_print(arr_title,@sh,2)
    if sh < 65 ; sh := 65 ; endif
    R_Use(dir_server+"human_u_",,"HU_")
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    set relation to recno() into HU_
    R_Use(dir_server+"uslugi",,"USL")
    R_Use(dir_server+"mo_su",,"MOSU")
    R_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
    R_Use(dir_server+"schet_",,"SCHET_")
    R_Use(dir_server+"schet",,"SCHET")
    set relation to recno() into SCHET_
    if yes_parol
      R_Use(dir_server+"base1",,"BASE1")
    endif
    R_Use(dir_server+"mo_pers",,"PERSO")
    R_Use(dir_server+"kartote2",,"KART2")
    R_Use(dir_server+"kartote_",,"KART_")
    R_Use(dir_server+"kartotek",,"KART")
    set relation to recno() into KART_, to recno() into KART2
    R_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","ONKSL") // Сведения о случае лечения онкологического заболевания
    R_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
    R_Use(dir_server+"human_2",,"HUMAN_2")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humank","HUMAN")
    set relation to recno() into HUMAN_, to recno() into HUMAN_2
    fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
    add_string("")
    add_string(center(expand("РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА"),sh))
    titleN_uch(st_a_uch,sh,lcount_uch)
    add_string("")
    add_string(" == ПАРАМЕТРЫ ПОИСКА ==")
    if mn->date_lech > 0
      add_string("Дата окончания лечения: "+pdate_lech[4])
    endif
    if mn->date_schet > 0
      add_string("Дата выписки счета: "+pdate_schet[4])
    endif
    if mn->date_usl > 0
      add_string("Дата оказания услуг: "+pdate_usl[4])
    endif
    if mn->perevyst != 1
      add_string(upper(inieditspr(A__MENUVERT, mm_perevyst, mn->perevyst)))
    endif
    if mn->rak > 0
      add_string(upper(inieditspr(A__MENUVERT, mm_rak, mn->rak)))
    endif
    if yes_vypisan == B_END .and. mn->zav_lech > 0
      add_string("Лечение завершено?: "+iif(mn->zav_lech==B_STANDART,"да","нет"))
    endif
    if mn->reestr > 0
      add_string(inieditspr(A__MENUVERT, mm_reestr, mn->reestr))
    endif
    if mn->schet > 0
      add_string(inieditspr(A__MENUVERT, mm_schet, mn->schet))
      if mn->schet == 2 .and. mn->regschet > 0
        add_string(inieditspr(A__MENUVERT, mm_regschet, mn->regschet))
      endif
    endif
    if mn->d_p_m > 0
      s := "Диспансеризация/Профилактика/Медосмотр?: "+;
           inieditspr(A__MENUBIT,mm_d_p_m,mn->d_p_m)
      k := perenos(a_diagnoz,s,sh)
      add_string(a_diagnoz[1])
      for i := 2 to k
        add_string(padl(alltrim(a_diagnoz[i]),sh))
      next
    endif
    if mn->pz > 0
      add_string("Вид план-заказа: "+inieditspr(A__MENUVERT, mm_pz, mn->pz))
    endif
    if mn->dvojn > 1
      add_string("Двойные случаи: "+inieditspr(A__MENUVERT, mm_dvojn, mn->dvojn))
    endif
    if mn->zno == 2
      add_string("Признак подорения на злокачественное новообразование: да")
    endif
    if mn->kol_lu > 0
      add_string("Количество листов учета по одному больному более "+lstr(mn->kol_lu))
    endif
    if !empty(much_doc)
      add_string("№ амб.карты/истории болезни: "+much_doc)
    endif
    if is_uchastok > 0
      if !empty(mn->bukva)
        add_string("Буква: "+mn->bukva)
      endif
      if !empty(mn->uchast)
        add_string("Участок: "+init_uchast(arr_uchast))
      endif
    endif
    if glob_mo[_MO_IS_UCH] .and. !empty(mn->o_prik)
      add_string("Отношение к прикреплению: "+inieditspr(A__MENUVERT, mm_prik, mn->o_prik))
    endif
    if !empty(mfio)
      add_string("ФИО: "+mfio)
    endif
    if mn->inostran > 0
      add_string("Документы иностранных граждан: "+inieditspr(A__MENUVERT, mm_da_net, mn->inostran))
    endif
    if mn->gorod_selo > 0
      add_string("Житель: "+inieditspr(A__MENUVERT, mm_g_selo, mn->gorod_selo))
    endif
    if mn->mi_git > 0
      add_string("Место жительства: "+inieditspr(A__MENUVERT, mm_mest, mn->mi_git))
    endif
    if !empty(mn->_okato)
      add_string("Адрес регистрации (ОКАТО): "+ret_okato_ulica('',mn->_okato))
    endif
    if !empty(madres)
      add_string("Улица: "+madres)
    endif
    if !empty(mmr_dol)
      add_string("Место работы: "+mmr_dol)
    endif
    if mn->invalid > 0
      add_string("Наличие инвалидности: "+inieditspr(A__MENUVERT, mm_invalid, mn->invalid))
    endif
    if mn->kategor > 0
      add_string("Код категории льготы: "+inieditspr(A__MENUVERT, stm_kategor, mn->kategor))
    endif
    if is_talon .and. is_kategor2 .and. mn->kategor2 > 0
      add_string("Категория МО: "+inieditspr(A__MENUVERT, stm_kategor2, mn->kategor2))
    endif
    if !empty(mn->pol)
      add_string("Пол: "+mn->pol)
    endif
    if mn->vzros_reb >= 0
      add_string("Возрастная принадлежность: "+inieditspr(A__MENUVERT, menu_vzros, mn->vzros_reb))
    endif
    if !empty(mn->god_r_min) .or. !empty(mn->god_r_max)
      if empty(mn->god_r_min)
        add_string("Лица, родившиеся до "+full_date(mn->god_r_max))
      elseif empty(mn->god_r_max)
        add_string("Лица, родившиеся после "+full_date(mn->god_r_min))
      else
        add_string("Лица, родившиеся с "+full_date(mn->god_r_min)+" по "+full_date(mn->god_r_max))
      endif
    endif
    if mn->rab_nerab >= 0
      add_string(upper(inieditspr(A__MENUVERT, menu_rab, mn->rab_nerab)))
    endif
    if mn->USL_OK > 0
      add_string("Условия оказания: "+inieditspr(A__MENUVERT, tmp_V006, mn->USL_OK))
    endif
    /*if mn->VIDPOM > 0
      add_string("Вид помощи: "+inieditspr(A__MENUVERT, tmp_V008, mn->VIDPOM))
    endif*/
    if mn->PROFIL > 0
      add_string("Профиль (в случае): "+inieditspr(A__MENUVERT, tmp_V002, mn->PROFIL))
    endif
    if mn->PROFIL_U > 0
      add_string("Профиль (в услуге): "+inieditspr(A__MENUVERT, tmp_V002, mn->PROFIL_U))
    endif
    /*if mn->IDSP > 0
      add_string("Способ оплаты: "+inieditspr(A__MENUVERT, tmp_V010, mn->IDSP))
    endif*/
    if mn->rslt > 0
      add_string("Результат обращения: "+inieditspr(A__MENUVERT, mm_rslt, mn->rslt))
    endif
    if mn->ishod > 0
      add_string("Исход заболевания: "+inieditspr(A__MENUVERT, mm_ishod, mn->ishod))
    endif
    /*if is_talon .and. mn->povod > 0
      add_string("Повод обращения: "+;
                 inieditspr(A__MENUVERT, stm_povod, mn->povod))
    endif
    if is_talon .and. mn->travma > 0
      add_string("Вид травмы: "+;
                 inieditspr(A__MENUVERT, stm_travma, mn->travma))
    endif*/
    if mn->bolnich1 > 0
      add_string("Больничный: "+inieditspr(A__MENUVERT, menu_bolnich, mn->bolnich1))
    endif
    if mn->bolnich > 0
      add_string("Кол-во дней на больничном более "+lstr(mn->bolnich))
    endif
    if mn->vrach1 > 0
      add_string("Лечащий врач: "+alltrim(mn->vrach))
    endif
    if yes_bukva .and. !empty(mn->status_st)
      add_string("Статус стоматологического больного: "+alltrim(mn->status_st))
    endif
    if !emptyany(mn->diag,mn->diag1)
      add_string("Шифр диагноза (осн.+сопут.): с "+alltrim(mn->diag)+" по "+alltrim(mn->diag1))
    elseif !empty(mn->diag)
      add_string("Шифр диагноза (осн.+сопут.): "+mn->diag)
    endif
    if !emptyany(mn->kod_diag,mn->kod_diag1)
      add_string("Шифр основного диагноза: с "+alltrim(mn->kod_diag)+" по "+alltrim(mn->kod_diag1))
    elseif !empty(mn->kod_diag)
      add_string("Шифр основного диагноза: "+mn->kod_diag)
    endif
    if !emptyany(mn->soput_d,mn->soput_d1)
      add_string("Шифр сопутствующего диагноза: с "+alltrim(mn->soput_d)+" по "+alltrim(mn->soput_d1))
    elseif !empty(mn->soput_d)
      add_string("Шифр сопутствующего диагноза: "+mn->soput_d)
    endif
    if !emptyany(mn->osl_d,mn->osl_d1)
      add_string("Шифр диагноза осложнения: с "+alltrim(mn->osl_d)+" по "+alltrim(mn->osl_d1))
    elseif !empty(mn->osl_d)
      add_string("Шифр диагноза осложнения: "+mn->osl_d)
    endif
    if !emptyany(mn->pred_d,mn->pred_d1)
      add_string("Шифр предварительного диагноза: с "+alltrim(mn->pred_d)+" по "+alltrim(mn->pred_d1))
    elseif !empty(mn->pred_d)
      add_string("Шифр предварительного диагноза: "+mn->pred_d)
    endif
    f_put_tal_diag()  // вывод информации о характере, диспансеризации...
    if yes_h_otd == 1 .and. mn->otd > 0
      add_string("Отделение, в котором выписан счет: "+inieditspr(A__POPUPMENU, dir_server+"mo_otd", mn->otd))
    endif
    if mn->ist_fin >= 0
      add_string("Источник финансирования "+inieditspr(A__MENUVERT, mm_ist_fin, mn->ist_fin))
    endif
    if mn->komu >= 0
      add_string("Принадлежность счёта: "+inieditspr(A__MENUVERT, mm_komu, mn->komu))

      if mn->company > 0
        add_string("  ==> "+inieditspr(A__MENUVERT, mm_company, mn->company))
      endif
    endif
    if mn->srok_min > 0 .or. mn->srok_max > 0
      if empty(mn->srok_min)
        add_string("Срок лечения (максимальный) "+lstr(mn->srok_max)+" дн.")
      elseif empty(mn->srok_max)
        add_string("Срок лечения (минимальный) "+lstr(mn->srok_min)+" дн.")
      else
        add_string("Срок лечения от "+lstr(mn->srok_min)+" до "+lstr(mn->srok_max)+" дн.")
      endif
    endif
    if mn->summa_min > 0 .or. mn->summa_max > 0
      if empty(mn->summa_min)
        add_string("Стоимость лечения менее "+lstr(mn->summa_max,10,2))
      elseif empty(mn->summa_max)
        add_string("Стоимость лечения более "+lstr(mn->summa_min,10,2))
      else
        add_string("Стоимость лечения в диапазоне от "+lstr(mn->summa_min,10,2)+" до "+lstr(mn->summa_max,10,2))
      endif
    endif
    if mn->dom > 0
      add_string("Где оказана услуга: "+inieditspr(A__MENUVERT, mm_dom, mn->dom))
    endif
    if mn->otd_usl > 0
      add_string("Отделение, в котором оказана услуга: "+inieditspr(A__POPUPMENU, dir_server+"mo_otd", mn->otd_usl))
    endif
    if mn->vr1 > 0
      add_string("Врач, оказавший услугу(и): "+alltrim(mn->vr))
    endif
    if mn->isvr > 0
      add_string("Код врача "+if(mn->isvr==1,"не ","")+"проставлен")
    endif
    if mn->as1 > 0
      add_string("Ассистент, оказавший услугу(и): "+alltrim(mn->as))
    endif
    if mn->isas > 0
      add_string("Код ассистента "+if(mn->isas==1,"не ","")+"проставлен")
    endif
    if mn->vras1 > 0
      add_string("Человек, оказавший услугу(и): "+alltrim(mn->vras))
    endif
    if mn->date_vvod > 0
      add_string("Дата ввода: "+pdate_vvod[4])
    endif
    if mn->slug_usl > 0
      add_string("Служба, в которой оказаны услуги: "+mslugba[2])
    endif
    if mn->uslugi > 0
      l := s := k := 0
      aeval(arr_usl, {|x| l := max(l,len(rtrim(x[3]))) } )
      if fl_rak_usl
        l -= 11
      endif
      verify_FF(HH-1,.t.,sh)
      add_string(padr("Оказанные услуги (ТФОМС):",l+13)+"|Кол-во|  Ст-ть   "+iif(fl_rak_usl,"| Снято РАК",""))
      for i := 1 to len(arr_usl)
        verify_FF(HH,.t.,sh)
        add_string("  "+arr_usl[i,2]+" "+;
                   padr(arr_usl[i,3],l)+"|"+put_val(arr_usl[i,4],5)+" |"+put_kopE(arr_usl[i,5],10)+;
                   iif(fl_rak_usl.and.left(arr_usl[i,2],3)=="71.","|"+put_kopE(arr_usl[i,6],10),""))
        k += arr_usl[i,4]
        s += arr_usl[i,5]
      next
      add_string("  ИТОГО:     Оказано услуг "+lstr(k)+" на сумму "+lstr(s,12,2)+"р.")
    endif
    if mn->uslugiF > 0
      l := s := k := 0
      aeval(arr_uslF, {|x| l := max(l,len(rtrim(x[3]))) } )
      verify_FF(HH-1,.t.,sh)
      add_string(padr("Оказанные услуги (ФФОМС):",l+23)+"|Кол-во")
      for i := 1 to len(arr_uslF)
        verify_FF(HH,.t.,sh)
        add_string("  "+arr_uslF[i,2]+" "+;
                   padr(arr_uslF[i,3],l)+"|"+put_val(arr_uslF[i,4],5))
        k += arr_uslF[i,4]
      next
      add_string("  ИТОГО:     Оказано услуг "+lstr(k))
    endif
    use (cur_dir+"tmp_bbuk") index (cur_dir+"tmp_bbuk") new
    use (cur_dir+"tmp_buk") index (cur_dir+"tmp_buk") new
    if lastrec() > 0
      verify_FF(HH-3,.t.,sh)
      add_string("Стоматологический статус|Больн.|Случаев")
      w1 := 17
      f3_diag_statist_bukva(HH,sh)
    endif
    add_string("")
    add_string(" == РЕЗУЛЬТАТЫ ПОИСКА ==")
    if mn->kol_lu > 0
      use (cur_dir+"tmp_k") index (cur_dir+"tmp_k") new
      COUNT TO skol FOR tmp_k->kol > mn->kol_lu
      use (cur_dir+"tmp") new
      set relation to str(kod,7) into HUMAN, to str(kod_k,7) into TMP_K
      index on upper(human->fio)+dtos(human->k_data) to (cur_dir+"tmp") ;
            for tmp_k->kol > mn->kol_lu
    else
      use (cur_dir+"tmp_k") new
      use (cur_dir+"tmp") new
      set relation to str(kod,7) into HUMAN
      index on upper(human->fio)+dtos(human->k_data) to (cur_dir+"tmp")
      add_string("Итого количество больных: "+lstr(tmp_k->(lastrec()))+" чел.")
      s := "Итого листов учета: "+lstr(tmp->(lastrec()))+" на сумму "+lput_kop(ssumma,.t.)+" руб."
      if suet > 0
        s += " ("+alltrim(str_0(suet,15,4))+" УЕТ)"
      endif
      add_string(s)
    endif
    if !empty(srak_s)
      add_string("Сумма, снятая актами контроля "+lput_kop(srak_s,.t.)+" руб.")
    endif
    if mn->kol_pos == 2
      verify_FF(HH-5,.t.,sh)
      add_string("Количество амбулаторных посещений: "+lstr(kol_pos_amb))
      add_string("Количество стоматологических посещений всего: "+lstr(pol_pos_stom1+pol_pos_stom2+pol_pos_stom3))
      add_string(padl(  "в том числе с лечебной целью: ",47)+lstr(pol_pos_stom1))
      add_string(padl(      "с профилактической целью: ",47)+lstr(pol_pos_stom2))
      add_string(padl("при оказании неотложной помощи: ",47)+lstr(pol_pos_stom3))
      //use (cur_dir+"tmp_kp") new
      //add_string("Количество посещений (сколько дней пациенты заходили в МО): "+lstr(tmp_kp->(lastrec())))
    endif
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    ssumma := skol_lu := 0
    keyboard ""
    select TMP
    go top
    do while !eof()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      select ONKSL
      find (str(human->kod,7))
      is_oncology := f_is_oncology(1)
      k_diagnoz := k_usl := 0
      afill(tt_diagnoz,"") ; afill(tt_usl,"")
      //
      is_2 := .f. ; rec_1 := 0
      mn_data := human->n_data
      if human->ishod == 89
        select HUMAN_3
        set order to 2 // встать на индекс по 2-му случаю
        find (str(human->kod,7))
        if found()
          mn_data := human_3->N_DATA
          is_2 := .t.
          rec_1 := human_3->KOD
        endif
      endif
      //
      s1 := left(human->fio,40)
      kart->(dbGoto(human->kod_k))
      if mem_kodkrt == 2
        s2 := " ["
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
      else
        s2 := space(7)
      endif
      if mn->komu < 0
        s2 += f4_view_list_schet(human->komu,cut_code_smo(human_->smo),human->str_crb)
      endif
      if yes_bukva .and. !empty(human_->status_st)
        tmp1 := " "+alltrim(human_->status_st)
        s2 := padr(s2,50-len(tmp1))+tmp1
      else
        s2 := padr(s2,50)
      endif
      s3 := iif(mem_kodkrt == 2, space(1), space(7))
      if !empty(kart->SNILS)
        s3 += transform(kart->SNILS,picture_pf)+" "
      endif
      if mn->invalid == 9
        if kart_->INVALID == 1
          s3 += "инв.1группы "
        elseif kart_->INVALID == 2
          s3 += "инв.2группы "
        elseif kart_->INVALID == 3
          s3 += "инв.3группы "
        else
          s3 += "дети-инвалиды "
        endif
      endif
      if mn->bolnich1 > 1 .or. mn->bolnich > 0
        s3 += "больничн. "+left(date_8(c4tod(human->date_b_1)),5)+"-"+date_8(c4tod(human->date_b_2))
      elseif !empty(mmr_dol)
        s3 += alltrim(kart->mr_dol)
      endif
      s3 := padr(s3,50)
      //
      s1 += str(tmp->stoim,10,2)
      ssumma += tmp->stoim
      ++skol_lu
      //
      if isbit(mn->vid_doc,1)
        s1 += " "+date_8(human->date_r)
        s2 += space(9)
        s3 += space(9)
      endif
      //
      if isbit(mn->vid_doc,2) // адрес
        perenos(a_diagnoz,ret_okato_ulica(kart->adres,kart_->okatog,0,2),24)
        s1 += " "+padr(alltrim(a_diagnoz[1]),24)
        s2 += " "+padr(alltrim(a_diagnoz[2]),24)
        s3 += " "+padr(alltrim(a_diagnoz[3]),24)
      endif
      //
      if isbit(mn->vid_doc,3)
        if mn_data == human->k_data
          s1 += " "+date_8(human->k_data)
          s2 += space(9)
        else
          s1 += " с"+left(date_8(mn_data),5)+"по"
          s2 += " "+date_8(human->k_data)
        endif
        s3 += space(9)
      endif
      //
      if isbit(mn->vid_doc,4)
        afill(adiag_talon,0)
        for i := 1 to 16
          adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
        next
        arr := diag_to_array(,.t.,.t.,.t.,.t.,adiag_talon)
        tmp1 := ""
        for i := 1 to len(arr)
          tmp1 += arr[i]+" "
        next
        for i := 1 to 8
          if !empty(s := substr(human->diag_plus,i,1))
            if yes_bukva .and. (j := ascan(md_plus, s)) > 0
              sd_plus[j] ++
            endif
          endif
        next
        k_diagnoz := perenos(a_diagnoz,tmp1,13)
        s1 += " "+padc(alltrim(a_diagnoz[1]),13)
        s2 += " "+padc(alltrim(a_diagnoz[2]),13)
        s3 += " "+padc(alltrim(a_diagnoz[3]),13)
        if k_diagnoz > 3
          tt_diagnoz := aclone(a_diagnoz)
        endif
      endif
      //
      if isbit(mn->vid_doc,5)
        if human->tip_h >= B_SCHET .and. human->schet > 0
          select SCHET
          goto (human->schet)
          s1 += " "+padc(alltrim(schet_->nschet),15)
          s2 += " "+padc(date_8(schet_->dschet)+"г.",15)
        else
          s1 += " "+padc("-",15)
          s2 += space(16)
        endif
        s3 += space(16)
      endif
      //
      if isbit(mn->vid_doc,6)
        if tmp->rak_p == 0
          s1 += " "+padc("оплачи-",9)
          s2 += " "+padc("вается",9)
          s3 += space(10)
        else
          s1 += " "+padr("снят "+lstr(tmp->rak_p)+"%",9)
          if human_->oplata == 9
            s2 += " "+padc("перевыс-",9)
            s3 += " "+padc("тавлен",9)
          else
            s2 += " "+padc(lstr(tmp->rak_s,9,2),9)
            s3 += space(10)
          endif
        endif
      endif
      //
      if isbit(mn->vid_doc,7)
        if human_->vrach > 0
          select PERSO
          goto (human_->vrach)
          s1 += put_val(perso->tab_nom,6)
        else
          s1 += space(6)
        endif
        s2 += space(6)
        s3 += space(6)
      endif
      //
      if isbit(mn->vid_doc,8)
        tmp1 := "" ; aup := {}
        ar := {human->kod}
        if is_2
          Ins_Array(ar,1,rec_1)
        endif
        for j := 1 to len(ar)
          Select HU
          find (str(ar[j],7))
          do while hu->kod == ar[j] .and. !eof()
            if hu->kol_1 > 0
              Select USL
              goto (hu->u_kod)
              //if empty(l1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
                l1 := usl->shifr
              //endif
              l3 := ""//iif(hu->is_edit > 1, "[-"+lstr(hu->is_edit)+"%]", "")
              if (i := ascan(aup, {|x| x[1]==l1 .and. x[3]==l3} )) == 0
                aadd(aup, {l1,0,l3}) ; i := len(aup)
              endif
              aup[i,2] += hu->kol_1
            endif
            select HU
            Skip
          enddo
        next j
        asort(aup,,,{|x,y| fsort_usl(x[1]) < fsort_usl(y[1]) } )
        for j := 1 to len(ar)
          Select MOHU
          find (str(ar[j],7))
          do while mohu->kod == ar[j] .and. !eof()
            if !empty(mohu->kol_1)
              Select MOSU
              goto (mohu->u_kod)
              l1 := iif(empty(mosu->shifr), mosu->shifr1, mosu->shifr)
              l3 := ""
              if (i := ascan(aup, {|x| x[1]==l1 .and. x[3]==l3} )) == 0
                aadd(aup, {l1,0,l3}) ; i := len(aup)
              endif
              aup[i,2] += mohu->kol_1
            endif
            Select MOHU
            Skip
          enddo
        next j
        if mn->uslugi > 0
          bup := {}
          for i := 1 to len(arr_usl)
            if (l := ascan(aup,{|x| x[1] == arr_usl[i,2]})) > 0
              aadd(bup, aclone(aup[l]) )
              adel(aup,l) ; asize(aup,len(aup)-1)
            endif
          next
          for i := len(bup) to 1 step -1
            aadd(aup, nil) ; ains(aup,1) ; aup[1] := bup[i]
          next
        endif
        if mn->uslugiF > 0
          bup := {}
          for i := 1 to len(arr_uslF)
            if (l := ascan(aup,{|x| x[1] == arr_uslF[i,2]})) > 0
              aadd(bup, aclone(aup[l]) )
              adel(aup,l) ; asize(aup,len(aup)-1)
            endif
          next
          for i := len(bup) to 1 step -1
            aadd(aup, nil) ; ains(aup,1) ; aup[1] := bup[i]
          next
        endif
        for i := 1 to len(aup)
          tmp1 += alltrim(aup[i,1])+iif(aup[i,2] > 1, "("+lstr(aup[i,2])+")", "")+aup[i,3]+","
        next
        tmp1 := left(tmp1,len(tmp1)-1)
        k_usl := perenos(a_diagnoz,tmp1,23,",")
        s1 += " "+padc(alltrim(a_diagnoz[1]),23)
        s2 += " "+padc(alltrim(a_diagnoz[2]),23)
        s3 += " "+padc(alltrim(a_diagnoz[3]),23)
        if k_usl > 3
          tt_usl := aclone(a_diagnoz)
        endif
      endif
      //
      if isbit(mn->vid_doc,9)
        afill(a_diagnoz,"") ; i := 0
        if !empty(human_2->pc3) .and. !left(human_2->pc3,1) == '6' // кроме "старости"
          a_diagnoz[++i] := human_2->pc3
        elseif is_oncology  == 2
          if !empty(onksl->crit)
            a_diagnoz[++i] := onksl->crit
          endif
          if !empty(onksl->crit2)
            a_diagnoz[++i] := onksl->crit2  // второй критерий
          endif
        endif
        s1 += " "+padc(a_diagnoz[1],8)
        s2 += " "+padc(a_diagnoz[2],8)
        s3 += " "+padc(a_diagnoz[3],8)
      endif
      if yes_parol
        if isbit(mn->vid_doc,10)
          s1 += " "+date_8(c4tod(human->date_e))+"г."
          if asc(human->kod_p) > 0
            select BASE1
            goto (asc(human->kod_p))
            if !eof() .and. !empty(base1->p1)
              s2 += " "+left(crypt(base1->p1,gpasskod),10)
            endif
          elseif human_2->PN3 > 0
            s2 += " ИМПОРТ"
          endif
        endif
      endif
      add_string(s1)
      add_string(s2)
      add_string(s3)
      if k_diagnoz > 3 .or. k_usl > 3
        for i := 4 to min(10,max(k_diagnoz,k_usl))
          s3 := space(50)
          if isbit(mn->vid_doc,1)
            s3 += space(9)
          endif
          if isbit(mn->vid_doc,2)
            s3 += " "+space(24)
          endif
          if isbit(mn->vid_doc,3)
            s3 += space(9)
          endif
          if isbit(mn->vid_doc,4)
            s3 += " "+padc(alltrim(tt_diagnoz[i]),13)
          endif
          if isbit(mn->vid_doc,5)
            s3 += space(16)
          endif
          if isbit(mn->vid_doc,6)
            s3 += space(10)
          endif
          if isbit(mn->vid_doc,7)
            s3 += space(6)
          endif
          if isbit(mn->vid_doc,8)
            s3 += " "+padc(alltrim(tt_usl[i]),23)
          endif
          add_string(s3)
        next
      endif
      if is_2
        add_string(space(5)+"! Это двойной случай !")
      endif
      select TMP
      skip
    enddo
    add_string(replicate("─",sh))
    if fl_exit
      add_string("*** "+expand("ОПЕРАЦИЯ ПРЕРВАНА"))
    else
      if mn->kol_lu > 0
        add_string("Итого количество больных: "+lstr(skol)+" чел.")
        add_string("Итого листов учета: "+lstr(skol_lu)+;
                   " на сумму  "+lput_kop(ssumma,.t.)+" руб.")
      else
        add_string("  Итого листов учета: "+lstr(tmp->(lastrec()))+;
                   " на сумму  "+lput_kop(ssumma,.t.)+" руб.")
        if yes_bukva
          for i := 1 to k_plus
            if !empty(sd_plus[i])
              add_string(padl('"'+md_plus[i]+'"  : ',29)+lstr(sd_plus[i]))
            endif
          next
        endif
      endif
    endif
    fclose(fp)
    close databases
    viewtext(name_file,,,,.t.,,,reg_print)
  endif
endif
close databases
restscreen(buf) ; setcolor(tmp_color)
return NIL

*****
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

***** 26.02.20
Static Function s1_mnog_poisk(cv,cf)
Static a_stom_vp := {{},{},{}}
Local i, j, k, n, s, arr, fl := .t., flu := .f., mkol, mstoim := 0, fl1, fl2, vid_vp := 1,;
      au := {}, au_lu := {}, au_flu := {}, msumma, mn_data, rec_1 := 0, is_2 := .f.,;
      mrak_p := 0, mrak_s := 0, d, lshifr, muet := 0, god_r, arr1, adiag_talon[16]  // из статталона к диагнозам
if empty(a_stom_vp[1])
  f_vid_p_stom({},{},a_stom_vp[1],{1})
  f_vid_p_stom({},{},a_stom_vp[2],{2})
  f_vid_p_stom({},{},a_stom_vp[3],{3})
endif
++cv
mn_data := human->n_data
msumma := human->cena_1
kart->(dbGoto(human->kod_k))
if fl
  if mn->dvojn == 1
    fl := (human->ishod != 88)
  elseif mn->dvojn == 2
    fl := (human->ishod == 89)
  elseif mn->dvojn == 3
    fl := !eq_any(human->ishod,88,89)
  endif
  if fl
    if human->ishod == 89
      select HUMAN_3
      set order to 2 // встать на индекс по 2-му случаю
      find (str(human->kod,7))
      if found()
        mn_data := human_3->N_DATA
        msumma := human_3->CENA_1
        rec_1 := human_3->KOD
        is_2 := .t.
      endif
    endif
  endif
endif
if fl .and. mn->date_lech > 0 .and. p_regim != 1
  fl := between(human->k_data,pdate_lech[5],pdate_lech[6])
endif
if fl .and. mn->date_schet > 0 .and. p_regim != 2
  fl := !empty(human->DATE_CLOSE) .and. between(human->DATE_CLOSE,pdate_lech[5],pdate_lech[6])
  if (fl := (human->schet > 0))
    if schet->kod != human->schet
      schet->(dbGoto(human->schet))
    endif
    fl := between(schet->pdate,pdate_schet[7],pdate_schet[8])
  endif
endif
if fl .and. mn->perevyst != 1
  if mn->perevyst == 0
    fl := (human_->oplata != 9)
  elseif mn->perevyst == 2
    fl := (human_->oplata == 9)
  endif
endif
if fl .and. mn->rak > 0
  k := 0 // по умолчанию оплачен, если даже нет РАКа
  select RAKSH
  find (str(human->kod,7))
  do while human->kod == raksh->kod_h .and. !eof()
    k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
    skip
  enddo
  if !empty(round(k,2))
    mrak_s := k
    if empty(human->cena_1) // скорая помощь с нулевой ценой
      if (y := year(human->k_data)) == 2018
        n := 2224.60
      elseif y == 2017
        n := 1819.50
      else  // 2016 год
        n := 1747.70
      endif
      mrak_p := k := round(mrak_s/n*100,0)
    else
      mrak_p := k := round(mrak_s/human->cena_1*100,0)
    endif
  endif
  do case
    case mn->rak == 1 // {"за исключением полностью неоплачиваемых",1},;
      fl := (k < 100)
    case mn->rak == 2 // {"полностью неоплачиваемые и перевыставленные",2},;
      fl := (k == 100 .and. human_->oplata == 9)
    case mn->rak == 3 // {"полностью неоплачиваемые и неперевыставленные",3},;
      fl := (k == 100 .and. human_->oplata != 9)
    case mn->rak == 4 // {"полностью неоплачиваемые",4},;
      fl := (k == 100)
    case mn->rak == 5 // {"частично неоплачиваемые",5},;
      fl := (k > 0 .and. k < 100)
    case mn->rak == 6 // {"полностью или частично неоплачиваемые",6};
      fl := (k > 0)
  endcase
endif
if fl .and. mn->date_vvod > 0
  fl := between(human->date_e,pdate_vvod[7],pdate_vvod[8])
endif
if fl .and. yes_vypisan == B_END .and. mn->zav_lech > 0
  if p_zak_sl  // если законченный случай
    fl := (human->tip_h >= mn->zav_lech)  // проверить все вплоть до счетов
  else
    fl := (human->tip_h <= mn->zav_lech)
  endif
endif
if fl
  if mn->reestr == 1
    fl := (human_->reestr == 0)
  elseif mn->reestr == 2
    fl := (human_->reestr > 0)
  endif
endif
if fl
  if mn->schet == 1
    fl := (human->schet <= 0)
  elseif mn->schet == 2
    if (fl := (human->schet > 0)) .and. mn->regschet > 0
      if schet->kod != human->schet
        schet->(dbGoto(human->schet))
      endif
      if mn->regschet == 1
        fl := (schet_->NREGISTR != 0) // не зарегистрированные
      elseif mn->regschet == 2
        fl := (schet_->NREGISTR == 0) // зарегистрированные
      endif
    endif
  endif
endif
if fl .and. mn->d_p_m > 0
  fl := .f.
  if !fl .and. isbit(mn->d_p_m,1) // диспансеризация детей-сирот при стационаре I этап",1}
    fl := (human->ishod == 101 .and. !empty(human->za_smo))
  endif
  if !fl .and. isbit(mn->d_p_m,2) // диспансеризация детей-сирот при стационаре II этап",2},;
    fl := (human->ishod == 102 .and. !empty(human->za_smo))
  endif
  if !fl .and. isbit(mn->d_p_m,3) // диспансеризация детей-сирот под опекой I этап",3},;
    fl := (human->ishod == 101 .and. empty(human->za_smo))
  endif
  if !fl .and. isbit(mn->d_p_m,4) // диспансеризация детей-сирот под опекой II этап",4},;
    fl := (human->ishod == 102 .and. empty(human->za_smo))
  endif
  if !fl .and. isbit(mn->d_p_m,5) // диспансеризация взрослого населения I этап",5},;
    fl := (human->ishod == 201)
  endif
  if !fl .and. isbit(mn->d_p_m,6) // диспансеризация взрослого населения II этап",6},;
    fl := (human->ishod == 202)
  endif
  if !fl .and. isbit(mn->d_p_m,7) // профилактика взрослого населения",7},;
    fl := (human->ishod == 203)
  endif
  if !fl .and. isbit(mn->d_p_m,8) // диспансеризация взрослого населения I этап 1 раз в два года
    fl := (human->ishod == 204)
  endif
  if !fl .and. isbit(mn->d_p_m,9) // диспансеризация взрослого населения II этап 1 раз в два года
    fl := (human->ishod == 205)
  endif
  if !fl .and. isbit(mn->d_p_m,10) // профосмотр несовершеннолетних I этап",8},;
    fl := (human->ishod == 301)
  endif
  if !fl .and. isbit(mn->d_p_m,11) // профосмотр несовершеннолетних II этап",9},;
    fl := (human->ishod == 302)
  endif
  if !fl .and. isbit(mn->d_p_m,12) // предварительный осмотр несовершеннолетних I этап",10},;
    fl := (human->ishod == 303)
  endif
  if !fl .and. isbit(mn->d_p_m,13) // предварительный осмотр несовершеннолетних II этап",11},;
    fl := (human->ishod == 304)
  endif
  if !fl .and. isbit(mn->d_p_m,14) // периодический осмотр несовершеннолетних",12};
    fl := (human->ishod == 305)
  endif
endif
if fl .and. mn->pz > 0
  fl := (human_->PZTIP == mn->pz)
endif
if fl .and. mn->zno == 2
  fl := (human->OBRASHEN == '1')
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
if fl .and. glob_mo[_MO_IS_UCH] .and. !empty(mn->o_prik)
  kart->(dbGoto(human->kod_k))
  if mn->o_prik == 1 // прикреплен к нашей МО
    fl := (kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
  elseif mn->o_prik == 2 // не прикреплен к нашей МО
    fl := !(kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
  endif
endif
if fl .and. !empty(mfio)
  fl := like(mfio,upper(human->fio))
endif
if fl .and. mn->inostran > 0
  if mn->inostran == 1 //нет
    //9,21,22,23,24
    fl := !equalany(kart_->vid_ud,9,21,22,23,24)
  else
    fl := equalany(kart_->vid_ud,9,21,22,23,24)
  endif
endif
if fl .and. mn->gorod_selo > 0
  if mn->gorod_selo == 1
    fl := !f_is_selo(kart_->gorod_selo,kart_->okatog)
  else
    fl := f_is_selo(kart_->gorod_selo,kart_->okatog)
  endif
endif
if fl .and. !empty(madres)
  fl := like(madres,upper(kart->adres))
endif
if fl .and. !empty(mmr_dol)
  fl := like(mmr_dol,upper(kart->mr_dol))
endif
if fl .and. mn->invalid > 0
  if mn->invalid == 9
    fl := (kart_->INVALID > 0)
  else
    fl := (kart_->INVALID == mn->invalid)
  endif
endif
if fl .and. mn->kategor > 0
  fl := (mn->kategor == kart_->kategor)
endif
if fl .and. is_kategor2 .and. mn->kategor2 > 0
  fl := (mn->kategor2 == kart_->kategor2)
endif
/*if fl .and. is_talon .and. (mn->povod > 0 .or. mn->travma > 0)
  fl1 := fl2 := .t.
  if mn->povod > 0
    fl1 := .f.
  endif
  if mn->travma > 0
    fl2 := .f.
  endif
  if mn->povod > 0 .and. mn->povod == human_->povod
    fl1:= .t.
  endif
  if mn->travma > 0 .and. mn->travma == human_->travma
    fl2 := .t.
  endif
  fl := (fl1 .and. fl2)
endif*/
if fl .and. !empty(mn->pol)
  fl := (human->pol == mn->pol)
endif
if fl .and. mn->vzros_reb >= 0
  fl := (human->vzros_reb == mn->vzros_reb)
endif
if fl .and. !empty(mn->god_r_min)
  fl := (mn->god_r_min <= human->date_r)
endif
if fl .and. !empty(mn->god_r_max)
  fl := (human->date_r <= mn->god_r_max)
endif
if fl .and. mn->rab_nerab >= 0
  fl := (kart->rab_nerab == mn->rab_nerab)
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
if fl .and. mn->USL_OK > 0
  fl := (human_->USL_OK == mn->USL_OK)
endif
/*if fl .and. mn->VIDPOM > 0
  fl := (human_->VIDPOM == mn->VIDPOM)
endif*/
if fl .and. mn->PROFIL > 0
  fl := (human_->PROFIL == mn->PROFIL)
endif
/*if fl .and. mn->IDSP > 0
  fl := (human_->IDSP == mn->IDSP)
endif*/
if fl .and. mn->rslt > 0
  fl := (human_->RSLT_NEW == mn->rslt)
endif
if fl .and. mn->ishod > 0
  fl := (human_->ISHOD_NEW == mn->ishod)
endif
if fl .and. mn->bolnich1 > 0
  fl := (human->bolnich+1 == mn->bolnich1)
endif
if fl .and. mn->bolnich > 0 .and. mn->bolnich1 != 1  // не "нет"
  fl := .f.
  if human->bolnich > 0 .and. (c4tod(human->date_b_2) - c4tod(human->date_b_1) + 1) >= mn->bolnich
    fl := .t.
  endif
endif
if fl .and. mn->vrach1 > 0
  fl := (human_->vrach == mn->vrach1)
endif
if fl .and. yes_bukva .and. !empty(mn->status_st)
  if (fl := !empty(human_->status_st))
    fl := .f.
    s := alltrim(mn->status_st)
    for i := 1 to len(s)
      fl := (substr(s,i,1) $ human_->status_st)
      if fl ; exit ; endif
    next
  endif
endif
if fl .and. !empty(mn->osl_d)
  arr := {human_2->OSL1,human_2->OSL2,human_2->OSL3}
  fl := .f.
  for j := 1 to len(arr)
    if !empty(arr[j])
      arr[j] := padr(arr[j],5)
      if empty(mn->osl_d1)
        fl := (arr[j] == mn->osl_d)
      else
        fl := between(diag2num(arr[j]),NUMosl_d,NUMosl_d1)
      endif
      if fl ; exit ; endif  // т.е. один диагноз удовлетворяет условию
    endif
  next
endif
if fl .and. !empty(mn->pred_d)
  if between(human->ishod,201,203)  // дисп-ия (профосмотр) взрослого населения
    Private pole_diag, pole_1pervich
    for i := 1 to 5
      pole_diag := "mdiag"+lstr(i)
      pole_1pervich := "m1pervich"+lstr(i)
      Private &pole_diag := space(6)
      Private &pole_1pervich := 0
    next
    read_arr_DVN(human->kod)
    arr := {}
    for i := 1 to 5
      pole_diag := "mdiag"+lstr(i)
      pole_1pervich := "m1pervich"+lstr(i)
      if !empty(&pole_diag) .and. &pole_1pervich == 2  // предварительный диагноз
        aadd(arr,&pole_diag)
      endif
    next
  else
    arr := {human_->KOD_DIAG0}
  endif
  fl := .f.
  for j := 1 to len(arr)
    if !empty(arr[j])
      arr[j] := padr(arr[j],5)
      if empty(mn->pred_d1)
        fl := (arr[j] == mn->pred_d)
      else
        fl := between(diag2num(arr[j]),NUMpred_d,NUMpred_d1)
      endif
      if fl ; exit ; endif  // т.е. один диагноз удовлетворяет условию
    endif
  next
endif
if fl .and. !emptyall(mn->diag,mn->kod_diag,mn->soput_d)
  arr := {{human->KOD_DIAG ,1,0,0},;
          {human->KOD_DIAG2,2,0,0},;
          {human->KOD_DIAG3,3,0,0},;
          {human->KOD_DIAG4,4,0,0},;
          {human->SOPUT_B1 ,5,0,0},;
          {human->SOPUT_B2 ,6,0,0},;
          {human->SOPUT_B3 ,7,0,0},;
          {human->SOPUT_B4 ,8,0,0}}
  if is_talon .and. mn->talon_diag > 0
    afill(adiag_talon,0)
    for i := 1 to 16
      adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
    next
    for j := 1 to len(arr)
      for i := 1 to 2
        if adiag_talon[j*2-(2-i)] > 0
          arr[j,2+i] := 1
        endif
      next
    next
  endif
  if fl .and. !emptyall(mn->diag,mn->diag1) // проверим все заболевания
    fl := .f.
    for j := 1 to len(arr)
      if empty(mn->diag1)
        fl := (arr[j,1] == mn->diag)
      else
        fl := between(diag2num(arr[j,1]),NUMdiag,NUMdiag1)
      endif
      if fl
        if is_talon .and. mn->talon_diag > 0
          fl := .f.
          if arr[j,3] > 0 .or. arr[j,4] > 0 .or. arr_tal_diag[1,3] == 2 .or. arr_tal_diag[2,3] == 2
            for i := 1 to 2
              if arr[j,2+i] > 0 .or. arr_tal_diag[i,3] == 2
                k := adiag_talon[j*2-(2-i)]
                if arr_tal_diag[i,3] == 2
                  if empty(k)
                    fl := .t.
                  endif
                elseif arr_tal_diag[i,1] > 0 .and. between(k,arr_tal_diag[i,1],arr_tal_diag[i,2])
                  fl := .t.
                endif
                if fl ; exit ; endif
              endif
            next
          endif
        endif
        if fl ; exit ; endif  // т.е. один диагноз удовлетворяет условию
      endif
    next
  endif
  if fl .and. !emptyall(mn->kod_diag,mn->kod_diag1) // проверим основное заболевание
    fl := .f.
    j := 1 // первое = основное заболевание
    if empty(mn->kod_diag1)
      fl := (arr[j,1] == mn->kod_diag)
    else
      fl := between(diag2num(arr[j,1]),NUMkod_diag,NUMkod_diag1)
    endif
    if fl
      if is_talon .and. mn->talon_diag > 0
        fl := .f.
        if arr[j,3] > 0 .or. arr[j,4] > 0 .or. arr_tal_diag[1,3] == 2 .or. arr_tal_diag[2,3] == 2
          for i := 1 to 2
            if arr[j,2+i] > 0 .or. arr_tal_diag[i,3] == 2
              k := adiag_talon[j*2-(2-i)]
              if arr_tal_diag[i,3] == 2
                if empty(k)
                  fl := .t.
                endif
              elseif arr_tal_diag[i,1] > 0 .and. between(k,arr_tal_diag[i,1],arr_tal_diag[i,2])
                fl := .t.
              endif
              if fl ; exit ; endif
            endif
          next
        endif
      endif
    endif
  endif
  if fl .and. !emptyall(mn->soput_d,mn->soput_d1) // проверим сопутствующие заболевания
    fl := .f.
    for j := 2 to len(arr)  // начиная со второго
      if empty(mn->soput_d1)
        fl := (arr[j,1] == mn->soput_d)
      else
        fl := between(diag2num(arr[j,1]),NUMsoput_d,NUMsoput_d1)
      endif
      if fl
        if is_talon .and. mn->talon_diag > 0
          fl := .f.
          if arr[j,3] > 0 .or. arr[j,4] > 0 .or. arr_tal_diag[1,3] == 2 .or. arr_tal_diag[2,3] == 2
            for i := 1 to 2
              if arr[j,2+i] > 0 .or. arr_tal_diag[i,3] == 2
                k := adiag_talon[j*2-(2-i)]
                if arr_tal_diag[i,3] == 2
                  if empty(k)
                    fl := .t.
                  endif
                elseif arr_tal_diag[i,1] > 0 .and. between(k,arr_tal_diag[i,1],arr_tal_diag[i,2])
                  fl := .t.
                endif
                if fl ; exit ; endif
              endif
            next
          endif
        endif
        if fl ; exit ; endif  // т.е. один диагноз удовлетворяет условию
      endif
    next
  endif
endif
if fl .and. yes_h_otd == 1 .and. mn->otd > 0
  fl := (human->otd == mn->otd)
endif
if fl .and. mn->ist_fin >= 0
  fl := _f_ist_fin()
endif
if fl .and. mn->komu >= 0
  if mn->company == 0
    if mn->komu == 0
      fl := !empty(human_->smo)
    else
      fl := (mn->komu == human->komu)
    endif
  elseif mn->komu == 0
    if human->schet > 0
      if schet->kod != human->schet
        schet->(dbGoto(human->schet))
      endif
      fl := (int(val(schet_->smo)) == mn->company)
    else
      fl := (int(val(cut_code_smo(human_->smo))) == mn->company)
    endif
  else
    fl := (mn->komu == human->komu .and. mn->company == human->str_crb)
  endif
endif
k := human->k_data - mn_data + 1
if fl .and. mn->srok_min > 0
  fl := (mn->srok_min <= k)
endif
if fl .and. mn->srok_max > 0
  fl := (k <= mn->srok_max)
endif
if fl .and. mn->summa_min > 0
  fl := (mn->summa_min <= msumma)
endif
if fl .and. mn->summa_max > 0
  fl := (msumma <= mn->summa_max)
endif
fl1 := fl2 := .t.
if fl
  if flag_hu .or. flag_huF
    ar := {human->kod}
    if is_2
      Ins_Array(ar,1,rec_1)
    endif
  endif
  if flag_hu
    for i := 1 to len(ar)
      select HU
      find (str(ar[i],7))
      do while hu->kod == ar[i] .and. !eof()
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if f_paraklinika(usl->shifr,lshifr1,human->k_data)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          aadd(au_lu,{lshifr,;              // 1
                      c4tod(hu->date_u),;               // 2
                      hu_->profil,;         // 3
                      hu_->PRVS,;           // 4
                      alltrim(usl->shifr),; // 5
                      hu->kol_1,;           // 6
                      c4tod(hu_->date_u2),;     // 7
                      hu_->kod_diag,;       // 8
                      hu->(recno()),;       // 9 - номер записи
                      hu->is_edit})         // 10
          if flag_hu
            aadd(au,{1,hu->(recno()),len(au_lu)})
          endif
        endif
        select HU
        skip
      enddo
    next i
  endif
  if flag_huF
    for i := 1 to len(ar)
      select MOHU
      find (str(ar[i],7))
      do while mohu->kod == ar[i] .and. !eof()
        Select MOSU
        goto (mohu->u_kod)
        aadd(au_flu,{mosu->shifr1,;         // 1
                     c4tod(mohu->date_u),;  // 2
                     mohu->profil,;         // 3
                     mohu->PRVS,;           // 4
                     mosu->shifr,;          // 5
                     mohu->kol_1,;          // 6
                     c4tod(mohu->date_u2),; // 7
                     mohu->kod_diag,;       // 8
                     mohu->(recno())})      // 9 - номер записи
        aadd(au,{2,mohu->(recno()),len(au_flu)})
        select MOHU
        skip
      enddo
    next i
    if mn->kol_pos == 2
      k := 0
      f_vid_p_stom(au_lu,{},,,human->k_data,@vid_vp,@k,,au_flu)
      if vid_vp == 1 // с лечебной целью
        pol_pos_stom1 += k  // по поводу заболевания
      elseif vid_vp == 2 // // с профилактической целью
        pol_pos_stom2 += k  // профилактика
      elseif vid_vp == 3 // // при оказании неотложной помощи
        pol_pos_stom3 += k  // в неотложной форме
      endif
    endif
  endif
  if flag_hu .or. flag_huF
    if mn->kol_pos == 2 .and. eq_any(human_->USL_OK,1,4) // стационар и СМП
      select TMP_KP
      for d := human->n_data to human->k_data
        s := dtoc4(d)
        find (str(human->kod_k,7)+s)
        if !found()
          append blank
          tmp_kp->kod_k := human->kod_k
          tmp_kp->data  := s
        endif
      next
    endif
    mkol := 0
    for iau := 1 to len(au)
      lal := {"hu","mohu"}[au[iau,1]]
      lal_ := {"hu_","mohu"}[au[iau,1]]
      dbSelectArea(lal)
      dbGoto(au[iau,2])
      flu := .t.
      if flu .and. mn->date_usl > 0
        flu := between(&lal.->date_u,pdate_usl[7],pdate_usl[8])
      endif
      if flu .and. mn->dom > 0
        if au[iau,1] == 1 // только для HU
          do case
            case mn->dom == 1 // в поликлинике
              flu := (hu->KOL_RCP >= 0)
            case mn->dom == 2 // на дому
              flu := (hu->KOL_RCP == -1)
            case mn->dom == 3 // на дому-АКТИВ
              flu := (hu->KOL_RCP == -2)
            case mn->dom == 4 // на дому + на дому-АКТИВ
              flu := (hu->KOL_RCP < 0)
          endcase
        elseif mn->dom > 1 // фед.услуги только в поликлинике
          flu := .f.
        endif
      endif
      if flu .and. mn->otd_usl > 0
        flu := (&lal.->otd == mn->otd_usl)
      endif
      if flu .and. mn->PROFIL_U > 0
        flu := (&lal_.->PROFIL == mn->PROFIL_U)
      endif
      if flu .and. mn->vras1 > 0
        flu := (&lal.->kod_vr == mn->vras1 .or. &lal.->kod_as == mn->vras1)
      endif
      if flu .and. mn->vr1 > 0
        flu := (&lal.->kod_vr == mn->vr1)
      endif
      if flu .and. mn->isvr > 0
        if mn->isvr == 1  // нет
          flu := (&lal.->kod_vr == 0)
        else
          flu := (&lal.->kod_vr > 0)
        endif
      endif
      if flu .and. mn->as1 > 0
        flu := (&lal.->kod_as == mn->as1)
      endif
      if flu .and. mn->isas > 0
        if mn->isas == 1  // нет
          flu := (&lal.->kod_as == 0)
        else
          flu := (&lal.->kod_as > 0)
        endif
      endif
      if flu .and. mn->slug_usl > 0 .and. au[iau,1] == 1 // только для HU
        flu := (usl->slugba == mn->slug_usl)
      endif
      if flu
        if au[iau,1] == 1 .and. mn->uslugi > 0
          i := ascan(arr_usl,{|x| x[1] == hu->u_kod})
          if (flu := (i > 0))
            fl1 := .f.
            arr_usl[i,4] += hu->kol_1
            arr_usl[i,5] += hu->stoim_1
            arr_usl[i,6] += mrak_s
          endif
        elseif au[iau,1] == 2 .and. mn->uslugiF > 0
          i := ascan(arr_uslF,{|x| x[1] == mohu->u_kod})
          if (flu := (i > 0))
            fl2 := .f.
            arr_uslF[i,4] += mohu->kol_1
          endif
        endif
      endif
      if flu
        mkol += &lal.->kol_1
        mstoim += &lal.->stoim_1
        if mem_trudoem == 2 // подсчитывать трудоёмкость
          if au[iau,1] == 1
            muet += round_5(hu->kol_1 * opr_uet(human->vzros_reb), 4)
          elseif human_->usl_ok == 3 // только для стоматологии
            if year(human->k_data) > 2018
              select LUSLF
              find (mosu->shifr1)
              muet += round_5(mohu->kol_1 * iif(human->vzros_reb==0, luslf->uetv, luslf->uetd), 4)
            else
              select LUSLF18
              find (mosu->shifr1)
              muet += round_5(mohu->kol_1 * iif(human->vzros_reb==0, luslf18->uetv, luslf18->uetd), 4)
            endif
          endif
        endif
        if mn->kol_pos == 2 .and. eq_any(human_->USL_OK,2,3) .and. au[iau,1] == 1
          i := au[iau,3]
          lshifr := au_lu[i,1]
          if human_->USL_OK == 2 // дневной стационар
            if left(lshifr,5) == "55.1." // кол-во пациенто-дней
              for i := 1 to hu->kol_1
                if i == 1
                  s := hu->date_u
                else
                  s := dtoc4(c4tod(hu->date_u)+i-1)
                endif
                select TMP_KP
                find (str(human->kod_k,7)+s)
                if !found()
                  append blank
                  tmp_kp->kod_k := human->kod_k
                  tmp_kp->data  := s
                endif
              next
            endif
          elseif !f_is_zak_sl_vr(lshifr)  // поликлиника
            if left(lshifr,2) == "2." // врачебные приёмы амбулаторные
              if between_shifr(lshifr,"2.79.52","2.79.64")
                vid_vp := 2 // с профилактической целью
              elseif between_shifr(lshifr,"2.88.40","2.88.51")
                vid_vp := 2 // с профилактической целью
              elseif between_shifr(lshifr,"2.80.29","2.80.38")
                vid_vp := 3 // при оказании неотложной помощи
              else
                kol_pos_amb += hu->kol_1
              endif
            else // проверяем старую стоматологию
              for i := 1 to 3
                if ascan(a_stom_vp[i],lshifr) > 0
                  do case
                    case i == 1 // с лечебной целью
                      pol_pos_stom1 += hu->kol_1  // по поводу заболевания
                    case i == 2 // // с профилактической целью
                      pol_pos_stom2 += hu->kol_1  // профилактика
                    case i == 3 // // при оказании неотложной помощи
                      pol_pos_stom3 += hu->kol_1  // в неотложной форме
                  endcase
                  exit
                endif
              next
            endif
          endif
        endif
        if flu .and. mn->kol_pos == 2
          select TMP_KP
          find (str(human->kod_k,7)+&lal.->date_u)
          if !found()
            append blank
            tmp_kp->kod_k := human->kod_k
            tmp_kp->data  := &lal.->date_u
          endif
        endif
      endif
    next
    if emptyall(mkol,mstoim)
      fl := .f.
    elseif mn->uslugi > 0 .and. fl1 // не попало ни одной услуги из списка отбора
      fl := .f.
    elseif mn->uslugiF > 0 .and. fl2 // не попало ни одной услуги из списка отбора
      fl := .f.
    endif
  else
    mstoim := msumma
  endif
endif
if fl
  select TMP_K
  find (str(human->kod_k,7))
  if !found()
    append blank
    tmp_k->kod_k := human->kod_k
  endif
  tmp_k->kol ++
  select TMP
  append blank
  tmp->kod := human->kod
  tmp->kod_k := human->kod_k
  tmp->stoim := mstoim
  tmp->rak_p := mrak_p
  tmp->rak_s := mrak_s
  ssumma += mstoim
  srak_s += mrak_s
  if muet > 0
    suet += muet
  endif
  f2_diag_statist_bukva()
  if ++cf % 5000 == 0
    tmp->(dbCommit())
    tmp_k->(dbCommit())
  endif
endif
@ maxrow(),1 say lstr(cv) color cColorSt2Msg
@ row(),col() say "/" color "W/R"
@ row(),col() say lstr(cf) color cColorStMsg
return NIL

*****
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

*****
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

*****
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

*****
Function f_put_tal_diag()
Static mm_s := {"Характер заболевания",;
                "Диспансерный учет"}
Local i, s
for i := 1 to 2
  if arr_tal_diag[i,3] == 2
    add_string(mm_s[i]+": не введён")
  elseif arr_tal_diag[i,1] > 0
    s := mm_s[i]+": "+lstr(arr_tal_diag[i,1])
    if arr_tal_diag[i,1] != arr_tal_diag[i,2]
      s += " - "+lstr(arr_tal_diag[i,2])
    endif
    add_string(s)
  endif
next
return NIL

***** 16.07.20 форма 14-МЕД (ОМС)
Function forma14_med_oms()
Static group_ini := "f14_med_oms"
Local begin_date, end_date, buf := savescreen(), arr_m, i, j, k, k1, k2,;
      t_arr[10], t_arr1[10], name_file := "f14med"+stxt, tfoms_pz[5,11],;
      sh, HH := 80, reg_print := 5, is_trudosp, is_rebenok, is_inogoro,;
      is_reabili, is_ekstra, lshifr1, koef, vid_vp, r1 := 9, fl_exit := .f.,;
      is_vmp, d2_year, ar, arr_excel := {}, fl_error := .f., is_z_sl,;
      cFileProtokol := "tmp"+stxt, arr_prof := {}, arr_usl, au, ii,;
      filetmp14 := "tmp14"+stxt, sum_k := 0, sum_ki := 0, sum_kd := 0, sum_kt := 0, kol_d := 0 , sum_d := 0
Local arr_skor[81,2], arr_eko[2,2], arr_profil := {}, arr_dn_stac := {}, arrDdn_stac[4], fl_pol1[15],;
      arr_pol[32], arr_pol1[15,5], arr_pril5[29,3], ifff := 0, kol_stom_pos := 0, lal, lalf
old5 := old2 := 0
afillall(arr_skor,0)
afillall(arr_eko,0)
afill(arrDdn_stac,0)
afill(arr_pol,0)
afillall(arr_pril5,0)
afillall(arr_pol1,0)
arr_pol1[ 1,1] := "Посещений - всего (02+11+13)"
arr_pol1[ 2,1] := "Посещения с профилактическими и иными целями (03+06+09)"
arr_pol1[ 3,1] := "посещения с профилактическими целями, всего"
arr_pol1[ 4,1] := "из строки 03 - посещения, связанные с диспансеризацией"
arr_pol1[ 5,1] := 'из строки 03 - посещения по специальности "стоматология"'
arr_pol1[ 6,1] := "разовые посещения в связи с заболеваниями, всего"
arr_pol1[ 7,1] := "из строки 06 - посещения на дому"
arr_pol1[ 8,1] := 'из строки 06 - посещения по специальности "стоматология"'
arr_pol1[ 9,1] := "посещения с иными целями, всего"
arr_pol1[10,1] := "из строки 09 паллиативная медицинская помощь"
arr_pol1[11,1] := "Посещения при оказании помощи в неотложной форме, всего"
arr_pol1[12,1] := "из строки 11 - посещения на дому"
arr_pol1[13,1] := "Посещения, включенные в обращение в связи с заболеваниями"
arr_pol1[14,1] := 'из строки 13 - посещения по специальности "стоматология"'
arr_pol1[15,1] := "Из строки 01 - посещения к среднему медперсоналу"
//
arr_pril5[ 1,1] := "Объёмы всего ,руб."
arr_pril5[ 2,1] := "СМП - вызовов, ед."
arr_pril5[ 3,1] := "СМП - лиц, чел."
arr_pril5[ 4,1] := "СМП - руб."
arr_pril5[ 8,1] := "Всего посещений"
arr_pril5[ 9,1] := "Всего расходов на амб.помощь"
arr_pril5[10,1] := "Число обращений по поводу заболевания"
arr_pril5[11,1] := "Число посещений с проф.(иной) целью"
arr_pril5[12,1] := "руб."
arr_pril5[13,1] := "Число посещений по неотл.мед.помощи"
arr_pril5[14,1] := "руб."
arr_pril5[15,1] := "Стационар - койко-дней"
arr_pril5[16,1] := "Стационар - случаев госпитализации"
arr_pril5[17,1] := "Стационар - руб."
arr_pril5[18,1] := "Стац(ВМП) - койко-дней"
arr_pril5[19,1] := "Стац(ВМП) - случаев госпитализации"
arr_pril5[20,1] := "Стац(ВМП) - руб."
arr_pril5[21,1] := "Стац(реабил) - койко-дней"
arr_pril5[22,1] := "Стац(реабил) - случаев госпитализации"
arr_pril5[23,1] := "Стац(реабил) - руб."
arr_pril5[24,1] := "Дн.стац. - пациенто-дней"
arr_pril5[25,1] := "Дн.стац. - пациентов, чел."
arr_pril5[26,1] := "Дн.стац. - руб."
arr_pril5[27,1] := "Дн.стац.ЭКО - пациенто-дней"
arr_pril5[28,1] := "Дн.стац.ЭКО - пациентов, чел."
arr_pril5[29,1] := "Дн.стац.ЭКО - руб."
arr_m := {2020,1,6,"за январь - июнь 2020 года",0d20200101,0d20200630}
lal := "lusl" ; lalf := "luslf"
Private mk1, mk2, mk3, mk4, md1, md11, md12, md2, md21, md22, md3, md4
ar := GetIniSect(tmp_ini,group_ini)
mk1 := int(val(a2default(ar,"mk1","0")))
mk2 := int(val(a2default(ar,"mk2","0")))
mk3 := int(val(a2default(ar,"mk3","0")))
mk4 := int(val(a2default(ar,"mk4","0")))
md1 := int(val(a2default(ar,"md1","0")))
md11 := int(val(a2default(ar,"md11","0")))
md12 := int(val(a2default(ar,"md12","0")))
md2 := int(val(a2default(ar,"md2","0")))
md21 := int(val(a2default(ar,"md21","0")))
md22 := int(val(a2default(ar,"md22","0")))
md3 := int(val(a2default(ar,"md3","0")))
md4 := int(val(a2default(ar,"md4","0")))
box_shadow(r1,2,22,77,color1,"Форма 14-МЕД "+arr_m[4],color8)
tmp_solor := setcolor(cDataCGet)
@ r1+ 1,4 say center("Стационар (раздел II)",72) color color14
@ r1+ 2,4 say "Число коек на конец отчетного периода (коек)      " get mk1 pict "9999"
@ r1+ 3,4 say "  из них: для детей (0-17 лет включительно) (коек)" get mk2 pict "9999"
@ r1+ 4,4 say "Число коек в среднем за отчетный период (коек)    " get mk3 pict "9999"
@ r1+ 5,4 say "  из них: для детей (0-17 лет включительно) (коек)" get mk4 pict "9999"
@ r1+ 6,4 say center("Дневной стационар (раздел IV)",72) color color14
@ r1+ 7,4 say "Число дневных стационаров                   " get md1 pict "9999"
@ r1+ 8,4 say "    из них при оказании специализированной помощи" get md11 pict "9999" valid md11 <= md1
@ row(),col() say ", в т.ч.ВМП" get md12 pict "9999" valid md12 <= md11
@ r1+ 9,4 say "  Из них оказывающие помощь детям (0-17 лет)" get md2 pict "9999"
@ r1+10,4 say "    из них при оказании специализированной помощи" get md21 pict "9999" valid md21 <= md2
@ row(),col() say ", в т.ч.ВМП" get md22 pict "9999" valid md22 <= md21
@ r1+11,4 say "Число мест на конец отчетного периода       " get md3 pict "9999"
@ r1+12,4 say "Число мест, в среднем за отчетный период    " get md4 pict "9999"
status_key("^<Esc>^ - выход;  ^<PgDn>^ - создание отчёта")
myread()
restscreen(buf)
if lastkey() == K_ESC
  return nil
endif
SetIniSect(tmp_ini,group_ini,{{"mk1",mk1},;
                              {"mk2",mk2},;
                              {"mk3",mk3},;
                              {"mk4",mk4},;
                              {"md1",md1},;
                              {"md11",md11},;
                              {"md12",md12},;
                              {"md2",md2},;
                              {"md21",md21},;
                              {"md22",md22},;
                              {"md3",md3},;
                              {"md4",md4}})
WaitStatus(arr_m[4])
@ maxrow(),0 say " ждите..." color "W/R"
begin_date := dtoc4(arr_m[5])
end_date := dtoc4(arr_m[6])
dbcreate(cur_dir+"tmp",{{"nstr","N",2,0},;
                        {"sum4","N",15,2},;
                        {"sum5","N",15,2},;
                        {"sum6","N",15,2},;
                        {"sum7","N",15,2},;
                        {"sum8","N",15,2},;
                        {"sum9","N",15,2}})
use (cur_dir+"tmp") new alias TMP
index on str(nstr,2) to (cur_dir+"tmp")
append blank ; tmp->nstr :=  1 ; tmp->sum4 := tmp->sum5 := mk1
append blank ; tmp->nstr :=  2 ; tmp->sum4 := tmp->sum5 := mk2
append blank ; tmp->nstr :=  3 ; tmp->sum4 := tmp->sum5 := mk3
append blank ; tmp->nstr :=  4 ; tmp->sum4 := tmp->sum5 := mk4
append blank ; tmp->nstr := 46 ; tmp->sum4 := tmp->sum5 := md1 ; tmp->sum7 := md11 ; tmp->sum8 := md12
append blank ; tmp->nstr := 47 ; tmp->sum4 := tmp->sum5 := md2 ; tmp->sum7 := md21 ; tmp->sum8 := md22
append blank ; tmp->nstr := 48 ; tmp->sum4 := tmp->sum5 := md3
append blank ; tmp->nstr := 49 ; tmp->sum4 := tmp->sum5 := md4
dbcreate(cur_dir+"tmpf14",{;
   {"KOD_XML",  "N", 6,0},; // ссылка на файл "mo_xml"
   {"SCHET",    "N", 6,0},; //
   {"KOD_RAK",  "N", 6,0},; // № записи в файле RAK
   {"KOD_RAKS", "N", 6,0},; // № записи в файле RAKS
   {"KOD_RAKSH","N", 8,0},; // № записи в файле RAKSH
   {"kol_akt",  "N", 2,0},; //
   {"usl_ok",   "N", 1,0},; //
   {"KOD_H",    "N", 7,0};  // код листа учета по БД "human"
  })
use (cur_dir+"tmpf14") new alias TMPF14
Use_base("lusl")
Use_base("luslf")
R_Use(dir_exe+"_mo0unit",cur_dir+"_mo0unit","MOUNIT")
R_Use(dir_server+"mo_su",,"MOSU")
R_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to recno() into HU_, to u_kod into USL
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
//
*********************************************************************
mdate_rak := arr_m[6]+9 // по какую дату РАК сумма к оплате 09.07.20
*********************************************************************
R_Use(dir_server+"mo_xml",,"MO_XML")
R_Use(dir_server+"mo_rak",,"RAK")
set relation to kod_xml into MO_XML
R_Use(dir_server+"mo_raks",,"RAKS")
set relation to akt into RAK
R_Use(dir_server+"mo_raksh",,"RAKSH")
set relation to kod_raks into RAKS
index on str(kod_h,7) to (cur_dir+"tmp_raksh") for mo_xml->DFILE <= mdate_rak
//
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",,"SCHET")
set relation to recno() into SCHET_
ob_kol := 0
go top
do while !eof()
  fl := .f.
  if schet_->IS_DOPLATA == 0 .and. !empty(val(schet_->smo)) .and. schet_->NREGISTR == 0 // только зарегистрированные
    @ maxrow(),0 say padr(alltrim(schet_->NSCHET)+" от "+date_8(schet_->DSCHET),27) color "W/R"
    // дата регистрации
    mdate := date_reg_schet()
    // дата отчетного периода
    mdate1 := stod(strzero(schet_->nyear,4)+strzero(schet_->nmonth,2)+"15")
    //
    *** 2020 год
    k := 7 // дата регистрации по 07.07.20
    ***
    fl := between(mdate,arr_m[5],arr_m[6]+k) .and. between(mdate1,arr_m[5],arr_m[6]) // !!отч.период 2020 год
  endif
  if fl
    select HUMAN
    find (str(schet->kod,6))
    do while human->schet == schet->kod .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      // по умолчанию оплачен, если даже нет РАКа
      koef := 1 ; k := j := 0
      select RAKSH
      find (str(human->kod,7))
      do while human->kod == raksh->kod_h .and. !eof()
        if !empty(raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP)
          ++j
        endif
        k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
        skip
      enddo
      if !empty(round(k,2))
        if empty(human->cena_1) // скорая помощь
          koef := 0
        elseif round_5(human->cena_1,2) <= round_5(k,2) // полное снятие
          koef := 0
        else // частичное снятие
          koef := (human->cena_1-k)/human->cena_1
        endif
        select RAKSH
        find (str(human->kod,7))
        do while human->kod == raksh->kod_h .and. !eof()
          if !empty(raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP)
            select TMPF14
            append blank
            tmpf14->KOD_XML   := rak->kod_xml
            tmpf14->SCHET     := schet->kod
            tmpf14->KOD_RAK   := raks->AKT
            tmpf14->KOD_RAKS  := raksh->KOD_RAKS
            tmpf14->KOD_RAKSH := raksh->(recno())
            tmpf14->KOD_H     := human->kod
            tmpf14->kol_akt   := j
            tmpf14->usl_ok    := iif(schet_->BUKVA=="T",5,human_->USL_OK)
          endif
          select RAKSH
          skip
        enddo
      endif
      if koef > 0
        afill(fl_pol1,0)
        is_vmp := (human_2->VMP == 1)
        is_trudosp := f_starshe_trudosp(human->POL,human->DATE_R,human->n_data,2)
        is_reabili := (human_->PROFIL == 158)
        is_rebenok := (human->VZROS_REB > 0)
        is_inogoro := (int(val(schet_->smo)) == 34)
        igs := iif(f_is_selo(kart_->gorod_selo,kart_->okatog), 3, 2)
        if !(fl_stom := (schet_->BUKVA == "T")) // стоматология в отдельной таблице
          arr_pril5[1,igs] += round(human->cena_1*koef,2)
        endif
        if schet_->BUKVA == "K" // отдельные медицинские услуги учитываем только суммой
          arr_pol1[6,4] += round(human->cena_1*koef,2)
          if is_inogoro
            arr_pol1[6,5] += round(human->cena_1*koef,2)
          endif
        endif
        is_dializ := .f.
        is_z_sl := .f.
        is_ekstra := .f.
        is_centr_z := .f.
        is_s_obsh := .f.
        is_kt := .f.
        is_prvs_206 := (ret_new_prvs(human_->prvs) == 206) // лечебное дело
        kol_2_3 := kol_2_6 := kol_2_60 := kol_sr := kol_2_sr := 0
        isp := 1
        is_sred_stom := .f.
        ds_spec := ds1_spec := kol_stom := kol_dializ := 0
        vid_vp := 0 // по умолчанию профилактика
        d2_year := year(human->k_data)
        if human_->USL_OK == 1 // стационар
          //
        elseif human_->USL_OK == 2 // дневной стационар
          is_ekstra := (human_->PROFIL == 137)
        elseif human_->USL_OK == 3 // поликлиника
          vid_vp := -1
        elseif human_->USL_OK == 4 // скорая помощь
          i := int(val(substr(human_->FORMA14,1,1)))
          isp := iif(i == 0, 1, 2)
        endif
        afillall(tfoms_pz,0)
        ap := {}
        arr_usl := {} ; au := {}
        lvidpom := 1 ; lvidpoms := "" ; svp := space(5)
        select HU
        find (str(human->kod,7))
        do while hu->kod == human->kod .and. !eof()
          lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,,,,@svp)
            lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
            ta := f14tf_nastr(@lshifr,,d2_year)
            lshifr := alltrim(lshifr)
            aadd(au,{lshifr,hu->kol_1,round(hu->stoim_1*koef,2),0,0,hu->kol_1})
            i16 := 0
            dbSelectArea(lal)
            find (padr(lshifr,10))
            if found() .and. !empty(&lal.->unit_code)
              select MOUNIT
              find (str(&lal.->unit_code,3))
              if found() .and. mounit->pz > 0
                if (i16 := mounit->ii) > 0
                  j1 := glob_array_PZ_20[i16,1]
                  if eq_any(j1,68,75,87)
                    //vid_vp := 0 // Посещение профилактическое
                  elseif eq_any(j1,69,76)
                    //vid_vp := 1 // в неотложной форме
                  elseif eq_any(j1,70,77,91,92)
                    //vid_vp := 2 // обращения с лечебной целью
                  elseif j1 == 71
                    is_centr_z := .t.
                    //vid_vp := 0 // Посещение профилактическое Центра здоровья
                  elseif eq_any(j1,73,74,87,88,89,90)  // т.е. 261,262,318,319,320,321
                    vid_vp := 0 // комплексное посещение при диспансеризации
                    is_z_sl := .t.
                  elseif j1 == 64 .or. between(j1,79,86) .or. between(j1,93,98) // исследования
                    is_kt := .t. ; ds1_spec := 1
                    vid_vp := 0 // Посещение профилактическое
                  elseif eq_any(j1,63,65,67)
                    is_dializ := .t.
                  endif
                endif
              endif
              select HU
            endif
            if human_->USL_OK == 1 // стационар
              //
            elseif human_->USL_OK == 2  // дневной стационар
              is_dializ := .t.
              if left(lshifr,5) == "60.3."
                kol_dializ += hu->kol_1
              endif
              aadd(arr_usl,lshifr)
              if !empty(svp) .and. "," $ svp
                lvidpoms := svp
              endif
              if (i := ret_vid_pom(1,lshifr,human->k_data)) > 0
                lvidpom := i
              endif
            elseif eq_any(left(lshifr,5),"2.78.","2.89.") // обращения с лечебной целью
              vid_vp := 2 // обращения с лечебной целью
              if lshifr == "2.78.2"
                is_s_obsh := .t. // врачи общей практики
              elseif eq_any(lshifr,"2.78.36","2.78.39","2.78.40")
                kol_sr += hu->kol_1
              endif
              if left(lshifr,5) == "2.89."
                ds_spec := 1 // первичная специализированная
                is_reabili := .t.
              elseif !eq_any(human_->PROFIL,97,57,68,3,42,85,87)
                ds_spec := 1
              endif
            endif
            if f_is_zak_sl_vr(lshifr)
              is_z_sl := .t.
            endif
            //
            if eq_any(left(lshifr,4),"2.6.","2.60")
              kol_stom += hu->kol_1
            endif
            if eq_any(lshifr,"2.3.3","2.3.4","2.60.3","2.60.4") // фельдшерские приёмы
              fl_pol1[15] := -1
            endif
            if eq_any(lshifr,"2.78.60","2.79.63","2.79.64","2.80.38","2.88.50") // зубной врач (средний мед.персонал)
              fl_pol1[15] := -1
              is_sred_stom := .t.
            endif
            if left(lshifr,5) == "2.80." .and. hu->KOL_RCP < 0 // посещения в неотложной форме на дому
              fl_pol1[12] += hu->kol_1
            endif
            if left(lshifr,5) == "2.88." .and. hu->KOL_RCP < 0 // разовое посещение на дому
              fl_pol1[7] += hu->kol_1
            endif
            //
            for j := 1 to len(ta)
              k := ta[j,1] ; mkol1 := 0
              if between(k,1,10)
                if ta[j,2] == 1 // законченный случай стационара
                  mkol := human->k_data - human->n_data  // койко-день
                elseif ta[j,2] == 0
                  mkol := hu->kol_1
                else
                  mkol := 0
                  mkol1 := hu->kol_1
                endif
                muet := 0
                msum := round(hu->stoim_1*koef,2)
                ii := 0
                is_obsh := .f.
                if k == 2 // стационар
                  ii := 1
                elseif k == 1 // поликлиника
                  ii := 2
                  aadd(arr_usl,left(lshifr,5))
                  if left(lshifr,2) == "2."
                    if left(lshifr,4) == "2.3."
                      kol_2_3 += hu->kol_1
                      if eq_any(lshifr,"2.3.3","2.3.4")
                        kol_2_sr += hu->kol_1
                      endif
                    elseif left(lshifr,4) == "2.6."
                      kol_2_6 += hu->kol_1
                    elseif left(lshifr,5) == "2.60."
                      kol_2_60 += hu->kol_1
                      if eq_any(lshifr,"2.60.3","2.60.4")
                        kol_2_sr += hu->kol_1
                      endif
                    elseif left(lshifr,5) == "2.76." // центр здоровья
                      vid_vp := 0 // Посещение профилактическое
                    elseif left(lshifr,5) == "2.79." // посещение с профилактической целью
                      vid_vp := 0 // Посещение профилактическое
                      if !eq_any(human_->PROFIL,97,57,68,3,42,85,87)
                        ds1_spec := 1 // первичная специализированная
                      endif
                      if eq_any(lshifr,"2.79.2","2.79.45")
                        is_obsh := .t.
                      endif
                      if eq_any(lshifr,"2.79.34","2.79.37","2.79.38","2.79.49","2.79.50")
                        kol_sr += hu->kol_1
                      endif
                    elseif left(lshifr,5) == "2.80." // в неотложной форме
                      vid_vp := 1 // в неотложной форме
                      if !eq_any(human_->PROFIL,97,57,68,3,42,85,87,160)
                        ds1_spec := 1
                      endif
                      if lshifr == "2.80.2"
                        is_obsh := .t.
                      endif
                      if eq_any(lshifr,"2.80.19","2.80.22","2.80.23","2.80.27")
                        kol_sr += hu->kol_1
                      endif
                    elseif left(lshifr,5) == "2.81." // консультации специалистов
                      vid_vp := 0 // Посещение профилактическое
                      if !eq_any(human_->PROFIL,68,97)
                        ds1_spec := 1
                      endif
                    elseif left(lshifr,5) == "2.82." // Посещение в приёмном покое (в неотложной форме)
                      vid_vp := 1 // в неотложной форме
                      if !eq_any(human_->PROFIL,57,68,97)
                        ds1_spec := 1
                      endif
                    elseif left(lshifr,5) == "2.83." // диспансеризация детей-сирот
                      if lshifr == "2.83.15"
                        is_obsh := .t.
                      endif
                    elseif left(lshifr,5) == "2.88." // разовое посещение
                      vid_vp := 0 // Посещение профилактическое
                      if !eq_any(human_->PROFIL,97,57,68,3,42,85,87)
                        ds1_spec := 1
                      endif
                      if eq_any(lshifr,"2.88.3","2.88.53","2.88.79")
                        is_obsh := .t.
                      endif
                      if eq_any(lshifr,"2.88.35","2.88.36","2.88.37")
                        kol_sr += hu->kol_1
                      endif
                    endif
                  elseif left(lshifr,5) == "60.3."
                    is_dializ := .t.
                  endif
                  if i16 > 0
                    aadd(ap,{lshifr,iif(empty(mkol),mkol1,mkol),is_obsh})
                  endif
                elseif k == 7 // отд.мед.услуги
                  ii := 2 // в поликлинику
                  mkol := 0  // участвует не количеством, а только суммой
                  is_kt := .t.
                  ds1_spec := 1
                elseif k == 8 // СМП
                  ii := 5
                elseif eq_any(k,3,4,5) // дневной стационар
                  ii := 4
                  if left(lshifr,5) == "55.1."
                    //
                  else
                    mkol := 0
                  endif
                endif
                if is_dializ
                  if human_->USL_OK == 1 // стационар
                    ii := 1
                  elseif human_->USL_OK == 2 // дневной стационар
                    ii := 4
                  elseif human_->USL_OK == 3 // поликлиника
                    ii := 2
                    mkol := 1
                    ds_spec := ds1_spec := 1
                    vid_vp := 2 // по поводу заболевания
                  endif
                endif
                if fl_stom // стоматология
                  //
                elseif ii > 0
                  tfoms_pz[ii,1] := 1
                  tfoms_pz[ii,2] += mkol
                  tfoms_pz[ii,3] += msum
                  if is_vmp
                    tfoms_pz[ii, 9] := 1
                    tfoms_pz[ii,10] += mkol
                    tfoms_pz[ii,11] += msum
                  endif
                  if ii == 2 // поликлиника
                    if is_obsh
                      tfoms_pz[ii,7] += mkol
                      tfoms_pz[ii,8] += msum
                      if ds1_spec == 1
                        tfoms_pz[ii,9] += mkol
                        tfoms_pz[ii,10] += msum
                      endif
                    else
                      if ds1_spec == 1
                        tfoms_pz[ii,5] += mkol
                        tfoms_pz[ii,6] += msum
                      endif
                    endif
                  endif
                endif
              endif
            next j
          endif
          select HU
          skip
        enddo
my_debug(vid_vp < 0,print_array(au))
        if kol_dializ > 0
          tfoms_pz[ii,2] := kol_dializ // заменяем на кол-во диализных процедур
        endif
        ta := {}
        if fl_stom // стоматология
          tfoms_pz[1,1] := 0
          tfoms_pz[2,1] := 0
          tfoms_pz[3,1] := 1
          tfoms_pz[4,1] := 0
          tfoms_pz[5,1] := 0
        endif
        do case
          // стационар
          case tfoms_pz[1,1] > 0
            if (i := ascan(arr_profil, {|x| x[1] == human_->PROFIL })) == 0
              aadd(arr_profil, {human_->PROFIL,0,0,0,0}) ; i := len(arr_profil)
            endif
            if human->ishod == 88 // это 1-й л/у в двойном случае
              tfoms_pz[1,1] := 0
            else
              arr_profil[i,2] ++
            endif
            arr_profil[i,3] += round(human->cena_1*koef,2)
            if is_inogoro
              arr_profil[i,4] ++ ; arr_profil[i,5] += round(human->cena_1*koef,2)
            endif
            arr_pril5[15,igs] += tfoms_pz[1,2] // "Стационар - койко-дней"
            arr_pril5[16,igs] += tfoms_pz[1,1] // "Стационар - случаев госпитализации"
            arr_pril5[17,igs] += tfoms_pz[1,3] // "Стационар - руб."
            if is_vmp
              arr_pril5[18,igs] += tfoms_pz[1,2] // Стац(ВМП) - койко-дней"
              arr_pril5[19,igs] += tfoms_pz[1,1] // Стац(ВМП) - случаев госпитализации"
              arr_pril5[20,igs] += tfoms_pz[1,3] // Стац(ВМП) - руб."
            endif
            aadd(ta,{ 5,tfoms_pz[1,1],tfoms_pz[1,1],tfoms_pz[1,9],tfoms_pz[1,3],tfoms_pz[1,3],tfoms_pz[1,11]})
            aadd(ta,{10,tfoms_pz[1,2],tfoms_pz[1,2],tfoms_pz[1,10]})
            if is_rebenok
              aadd(ta,{ 6,tfoms_pz[1,1],tfoms_pz[1,1],tfoms_pz[1,9],tfoms_pz[1,3],tfoms_pz[1,3],tfoms_pz[1,11]})
              aadd(ta,{11,tfoms_pz[1,2],tfoms_pz[1,2],tfoms_pz[1,10]})
            endif
            if is_trudosp
              aadd(ta,{ 7,tfoms_pz[1,1],tfoms_pz[1,1],tfoms_pz[1,9],tfoms_pz[1,3],tfoms_pz[1,3],tfoms_pz[1,11]})
              aadd(ta,{12,tfoms_pz[1,2],tfoms_pz[1,2],tfoms_pz[1,10]})
            endif
            if is_reabili
              arr_pril5[21,igs] += tfoms_pz[1,2] // "Стац(реабил) - койко-дней"
              arr_pril5[22,igs] += tfoms_pz[1,1] // "Стац(реабил) - случаев госпитализации"
              arr_pril5[23,igs] += tfoms_pz[1,3] // "Стац(реабил) - руб."
              aadd(ta,{ 8,tfoms_pz[1,1],tfoms_pz[1,1],tfoms_pz[1,9],tfoms_pz[1,3],tfoms_pz[1,3],tfoms_pz[1,11]})
              aadd(ta,{13,tfoms_pz[1,2],tfoms_pz[1,2],tfoms_pz[1,10]})
            endif
            if is_inogoro
              aadd(ta,{ 9,tfoms_pz[1,1],tfoms_pz[1,1],tfoms_pz[1,9],tfoms_pz[1,3],tfoms_pz[1,3],tfoms_pz[1,11]})
              aadd(ta,{14,tfoms_pz[1,2],tfoms_pz[1,2],tfoms_pz[1,10]})
            endif
          // поликлиника
          case tfoms_pz[2,1] > 0
            arr_pril5[9,igs] += round(human->cena_1*koef,2) // "Всего расходов на амб.помощь"
            if is_kt // для КТ обнуляем количество
              tfoms_pz[ii,1] := tfoms_pz[ii,2] := tfoms_pz[ii,5] := tfoms_pz[ii,7] := tfoms_pz[ii,9] := 0
            elseif is_dializ // перит.диализ
              vid_vp := 2 // по поводу заболевания
              ds_spec := 1
            endif
            if kol_2_60 > 0 .and. ascan(arr_usl,"2.78.") > 0
              arr_pril5[8,igs] += kol_2_60 // "Всего посещений"
            endif
            if kol_2_6 > 0 .and. ascan(arr_usl,"2.89.") > 0
              arr_pril5[8,igs] += kol_2_6 // "Всего посещений"
            endif
            fl := eq_any(schet_->BUKVA,'A','K')
            if schet_->BUKVA == 'K'
              vid_vp := 2 // по поводу заболевания
              sum_k += tfoms_pz[2,3]
              if is_rebenok
                sum_kd += tfoms_pz[2,3]
              endif
              if is_trudosp
                sum_kt += tfoms_pz[2,3]
              endif
              if is_inogoro
                sum_ki += tfoms_pz[2,3]
              endif
            endif
            if vid_vp == 1 // в неотложной форме
              fl_pol1[11] += tfoms_pz[2,2]
              arr_pril5[ 8,igs] += tfoms_pz[2,2] // "Всего посещений"
              arr_pril5[13,igs] += tfoms_pz[2,2] // "Число посещений по неотл.мед.помощи"
              arr_pril5[14,igs] += tfoms_pz[2,3] // "руб."
              aadd(ta,{22,tfoms_pz[2,2],tfoms_pz[2,2],tfoms_pz[2,5],tfoms_pz[2,3],tfoms_pz[2,3],tfoms_pz[2,6]})
              aadd(ta,{23,tfoms_pz[2,7],tfoms_pz[2,7],tfoms_pz[2,9],tfoms_pz[2,8],tfoms_pz[2,8],tfoms_pz[2,10]})
              if fl
                arr_pol[22] += tfoms_pz[2,3]
                arr_pol[23] += tfoms_pz[2,8]
              endif
              if is_rebenok
                aadd(ta,{24,tfoms_pz[2,2],tfoms_pz[2,2],tfoms_pz[2,5],tfoms_pz[2,3],tfoms_pz[2,3],tfoms_pz[2,6]})
                if fl
                  arr_pol[24] += tfoms_pz[2,3]
                endif
              endif
              if is_trudosp
                aadd(ta,{25,tfoms_pz[2,2],tfoms_pz[2,2],tfoms_pz[2,5],tfoms_pz[2,3],tfoms_pz[2,3],tfoms_pz[2,6]})
                if fl
                  arr_pol[25] += tfoms_pz[2,3]
                endif
              endif
              if is_inogoro
                aadd(ta,{26,tfoms_pz[2,2],tfoms_pz[2,2],tfoms_pz[2,5],tfoms_pz[2,3],tfoms_pz[2,3],tfoms_pz[2,6]})
                if fl
                  arr_pol[26] += tfoms_pz[2,3]
                endif
              endif
            elseif vid_vp == 2 // по поводу заболевания
              fl_pol1[13] := -1
              arr_pril5[10,igs] += tfoms_pz[2,1] // "Число обращений по поводу заболевания"
              aadd(ta,{27,tfoms_pz[2,1],tfoms_pz[2,1],iif(ds_spec==1,tfoms_pz[2,1],0),tfoms_pz[2,3],tfoms_pz[2,3],iif(ds_spec==1,tfoms_pz[2,3],0)})
              if fl
                arr_pol[27] += tfoms_pz[2,3]
              endif
              if is_s_obsh
                aadd(ta,{28,tfoms_pz[2,1],tfoms_pz[2,1],iif(ds_spec==1,tfoms_pz[2,1],0),tfoms_pz[2,3],tfoms_pz[2,3],iif(ds_spec==1,tfoms_pz[2,3],0)})
                if fl
                  arr_pol[28] += tfoms_pz[2,3]
                endif
              endif
              if is_rebenok
                aadd(ta,{29,tfoms_pz[2,1],tfoms_pz[2,1],iif(ds_spec==1,tfoms_pz[2,1],0),tfoms_pz[2,3],tfoms_pz[2,3],iif(ds_spec==1,tfoms_pz[2,3],0)})
                if fl
                  arr_pol[29] += tfoms_pz[2,3]
                endif
              endif
              if is_trudosp
                aadd(ta,{30,tfoms_pz[2,1],tfoms_pz[2,1],iif(ds_spec==1,tfoms_pz[2,1],0),tfoms_pz[2,3],tfoms_pz[2,3],iif(ds_spec==1,tfoms_pz[2,3],0)})
                if fl
                  arr_pol[30] += tfoms_pz[2,3]
                endif
              endif
              if is_reabili
                aadd(ta,{31,tfoms_pz[2,1],tfoms_pz[2,1],iif(ds_spec==1,tfoms_pz[2,1],0),tfoms_pz[2,3],tfoms_pz[2,3],iif(ds_spec==1,tfoms_pz[2,3],0)})
                if fl
                  arr_pol[31] += tfoms_pz[2,3]
                endif
              endif
              if is_inogoro
                aadd(ta,{32,tfoms_pz[2,1],tfoms_pz[2,1],iif(ds_spec==1,tfoms_pz[2,1],0),tfoms_pz[2,3],tfoms_pz[2,3],iif(ds_spec==1,tfoms_pz[2,3],0)})
                if fl
                  arr_pol[32] += tfoms_pz[2,3]
                endif
              endif
            elseif vid_vp == 0 // профилактика
              tfoms_pz[2,2] := tfoms_pz[2,7] := tfoms_pz[2,9] := tfoms_pz[2,5] := 0 // обнулим количество приемов
              if eq_any(schet_->BUKVA,'O','F','R','D','U') // диспансеризация и профосмотры
                lshifr := "дисп-ия" ; lkol := 1
                if (j := ascan(arr_prof, {|x| x[1] == lshifr })) == 0
                  aadd(arr_prof, {lshifr,0}) ; j := len(arr_prof)
                endif
                arr_prof[j,2] += lkol
                //
                tfoms_pz[2,2] += lkol
                if is_prvs_206 // лечебное дело в диспансеризации
                  fl_pol1[15] += lkol
                endif
                // терапевт, педиатр, врач общей практики, фельдшер при диспансеризации
                fl_pol1[3] += lkol
                fl_pol1[4] += lkol
              else
                for i := 1 to len(ap)
                  lshifr := ap[i,1] ; lkol := ap[i,2]
                  if (j := ascan(arr_prof, {|x| x[1] == lshifr })) == 0
                    aadd(arr_prof, {lshifr,0}) ; j := len(arr_prof)
                  endif
                  arr_prof[j,2] += lkol
                  //
                  tfoms_pz[2,2] += lkol
                  if ap[i,3] // is_obsh
                    tfoms_pz[2,7] += lkol
                    if ds1_spec == 1
                      tfoms_pz[2,9] += lkol
                    endif
                  else
                    if ds1_spec == 1
                      tfoms_pz[2,5] += lkol
                    endif
                  endif
                  if eq_any(left(lshifr,5),"2.79.","2.76.") // профилактика и центры здоровья
                    if between_shifr(lshifr,"2.79.44","2.79.50")  // патронаж
                      fl_pol1[9] += lkol
                      if eq_any(human_->profil,49,53,54) // паллиативная медицинская помощь
                        fl_pol1[10] += lkol
                      endif
                    else
                      fl_pol1[3] += lkol
                    endif
                  endif
                  if eq_any(lshifr,"2.79.34","2.79.37","2.79.38","2.79.49","2.79.50",; // фельдшерские приёмы
                                   "2.80.19","2.80.22","2.80.23","2.80.27",;
                                   "2.88.35","2.88.36","2.88.37","2.90.2")
                    fl_pol1[15] += lkol
                  endif
                  if eq_any(left(lshifr,5),"2.88.","2.81.") // разовое посещение или консультации
                    fl_pol1[6] += lkol
                  endif
                next
              endif
              if is_z_sl .and. tfoms_pz[2,2] > 0
                tfoms_pz[2,3] := round(human->cena_1*koef,2)
                if ds1_spec == 1
                  tfoms_pz[2,6] := round(human->cena_1*koef,2)
                endif
                if is_obsh
                  tfoms_pz[2,8] := round(human->cena_1*koef,2)
                  if ds1_spec == 1
                    tfoms_pz[2,10] := round(human->cena_1*koef,2)
                  endif
                endif
              endif
              if eq_any(schet_->BUKVA,'G','J','D','O','R','F','V','I','U')
                kol_d += tfoms_pz[2,2]
                sum_d += tfoms_pz[2,3]
              endif
              arr_pril5[ 8,igs] += tfoms_pz[2,2] // "Всего посещений"
              arr_pril5[11,igs] += tfoms_pz[2,2] // "Число посещений с проф.(иной) целью"
              arr_pril5[12,igs] += tfoms_pz[2,3] // "руб."
              aadd(ta,{15,tfoms_pz[2,2],tfoms_pz[2,2],tfoms_pz[2,5],tfoms_pz[2,3],tfoms_pz[2,3],tfoms_pz[2,6]})
              aadd(ta,{16,tfoms_pz[2,7],tfoms_pz[2,7],tfoms_pz[2,9],tfoms_pz[2,8],tfoms_pz[2,8],tfoms_pz[2,10]})
              if fl
                arr_pol[15] += tfoms_pz[2,3]
                arr_pol[16] += tfoms_pz[2,8]
              endif
              if is_centr_z
                aadd(ta,{17,tfoms_pz[2,2],tfoms_pz[2,2],tfoms_pz[2,5],tfoms_pz[2,3],tfoms_pz[2,3],tfoms_pz[2,6]})
                if fl
                  arr_pol[17] += tfoms_pz[2,3]
                endif
              endif
              if is_rebenok
                aadd(ta,{18,tfoms_pz[2,2],tfoms_pz[2,2],tfoms_pz[2,5],tfoms_pz[2,3],tfoms_pz[2,3],tfoms_pz[2,6]})
                if fl
                  arr_pol[18] += tfoms_pz[2,3]
                endif
                if is_centr_z
                  aadd(ta,{19,tfoms_pz[2,2],tfoms_pz[2,2],tfoms_pz[2,5],tfoms_pz[2,3],tfoms_pz[2,3],tfoms_pz[2,6]})
                  if fl
                    arr_pol[19] += tfoms_pz[2,3]
                  endif
                endif
              endif
              if is_trudosp
                aadd(ta,{20,tfoms_pz[2,2],tfoms_pz[2,2],tfoms_pz[2,5],tfoms_pz[2,3],tfoms_pz[2,3],tfoms_pz[2,6]})
                if fl
                  arr_pol[20] += tfoms_pz[2,3]
                endif
              endif
              if is_inogoro
                aadd(ta,{21,tfoms_pz[2,2],tfoms_pz[2,2],tfoms_pz[2,5],tfoms_pz[2,3],tfoms_pz[2,3],tfoms_pz[2,6]})
                if fl
                  arr_pol[21] += tfoms_pz[2,3]
                endif
              endif
            endif
          // стоматология
          case tfoms_pz[3,1] > 0
            au_flu := {} ; muet := 0
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
                           mohu->kod_diag})       // 8
              dbSelectArea(lalf)
              find (mosu->shifr1)
              muet += round_5(mohu->kol_1 * iif(human->vzros_reb==0, &lalf.->uetv, &lalf.->uetd), 2)
              select MOHU
              skip
            enddo
            tfoms_pz[3,4] := muet
            ret_tip := 0
            // 1 с лечебной целью
            // 2 с профилактической целью
            // 2  -- " -- " -- " -- " -- разовое по поводу заболевания
            // 3 при оказании неотложной помощи
            ret_kol := 0
            is_2_88 := .f.
            f_vid_p_stom(au,{},,,human->k_data,@ret_tip,@ret_kol,@is_2_88,au_flu)
            do case
              case ret_tip == 1
                vid_vp := 2 // по поводу заболевания
                fl_pol1[13] := -1
                fl_pol1[14] := -1
              case ret_tip == 2
                vid_vp := 0 // профилактика
                if is_2_88 // разовое по поводу заболевания
                  fl_pol1[6] := -1
                  fl_pol1[8] := -1
                else
                  fl_pol1[3] := -1
                  fl_pol1[5] := -1
                endif
              case ret_tip == 3
                vid_vp := 1 // в неотложной форме
                fl_pol1[11] := -1
            endcase
            tfoms_pz[3,1] := 1
            tfoms_pz[3,2] := ret_kol
            tfoms_pz[3,3] := round(human->cena_1*koef,2)
            func_f14_stom(tfoms_pz[3,3],ret_tip,ret_kol,is_2_88,is_rebenok,is_trudosp,is_inogoro,is_sred_stom)
            kol_stom := ret_kol
            kol_stom_pos += ret_kol
            // в таблицу Excel добавляются только УЕТ-ы
            aadd(ta,{45,tfoms_pz[3,4],tfoms_pz[3,4],tfoms_pz[3,3],tfoms_pz[3,3]})
          // дневной стационар
          case tfoms_pz[4,1] > 0
            if !empty(lvidpoms)
              if !eq_ascan(arr_usl,"55.1.2","55.1.3") .or. glob_mo[_MO_KOD_TFOMS] == '801935' // ЭКО-Москва
                lvidpoms := ret_vidpom_licensia(human_->USL_OK,lvidpoms,human_->profil) // только для дн.стационара при стационаре
              endif
              if !empty(lvidpoms) .and. !("," $ lvidpoms)
                lvidpom := int(val(lvidpoms))
                lvidpoms := ""
              endif
            endif
            if !empty(lvidpoms)
              if eq_ascan(arr_usl,"55.1.1","55.1.4")
                if "31" $ lvidpoms
                  lvidpom := 31
                endif
              elseif eq_ascan(arr_usl,"55.1.2","55.1.3")
                if eq_any(human_->PROFIL,57,68,97) //терапия,педиатр,врач общ.практики
                  if "12" $ lvidpoms
                    lvidpom := 12
                  endif
                else
                  if "13" $ lvidpoms
                    lvidpom := 13
                  endif
                endif
              endif
            endif
            //
            if (i := ascan(arr_dn_stac, {|x| x[1] == human_->PROFIL })) == 0
              aadd(arr_dn_stac, {human_->PROFIL,0,0,0,0}) ; i := len(arr_dn_stac)
            endif
            if is_dializ
              lvidpom := 31 // !!!!!!!
            endif
            arr_dn_stac[i,2] += tfoms_pz[4,1]
            arr_dn_stac[i,3] += tfoms_pz[4,3]
            if lvidpom == 13
              ds_spec := 1
            elseif lvidpom == 31
              ds_spec := 2
            else
              ds_spec := 0
            endif
            if is_rebenok
              arr_dn_stac[i,5] += tfoms_pz[4,2]
            else
              arr_dn_stac[i,4] += tfoms_pz[4,2]
            endif
            if ascan(arr_usl,"55.1.3") > 0 // на дому
              arrDdn_stac[1] += tfoms_pz[4,1]
              arrDdn_stac[2] += tfoms_pz[4,3]
              if is_rebenok
                arrDdn_stac[4] += tfoms_pz[4,2]
              else
                arrDdn_stac[3] += tfoms_pz[4,2]
              endif
            endif
            arr_pril5[24,igs] += tfoms_pz[4,2] // "Дн.стац. - пациенто-дней"
            arr_pril5[25,igs] += tfoms_pz[4,1] // "Дн.стац. - пациентов, чел."
            arr_pril5[26,igs] += tfoms_pz[4,3] // "Дн.стац. - руб."
            aadd(ta,{50,tfoms_pz[4,1],tfoms_pz[4,1],iif(ds_spec==1,tfoms_pz[4,1],0),iif(ds_spec==2,tfoms_pz[4,1],0),tfoms_pz[4,9]})
            aadd(ta,{55,tfoms_pz[4,2],tfoms_pz[4,2],iif(ds_spec==1,tfoms_pz[4,2],0),iif(ds_spec==2,tfoms_pz[4,2],0),tfoms_pz[4,10]})
            if is_rebenok
              aadd(ta,{51,tfoms_pz[4,1],tfoms_pz[4,1],iif(ds_spec==1,tfoms_pz[4,1],0),iif(ds_spec==2,tfoms_pz[4,1],0),tfoms_pz[4,9]})
              aadd(ta,{56,tfoms_pz[4,2],tfoms_pz[4,2],iif(ds_spec==1,tfoms_pz[4,2],0),iif(ds_spec==2,tfoms_pz[4,2],0),tfoms_pz[4,10]})
            endif
            if is_trudosp
              aadd(ta,{52,tfoms_pz[4,1],tfoms_pz[4,1],iif(ds_spec==1,tfoms_pz[4,1],0),iif(ds_spec==2,tfoms_pz[4,1],0),tfoms_pz[4,9]})
              aadd(ta,{57,tfoms_pz[4,2],tfoms_pz[4,2],iif(ds_spec==1,tfoms_pz[4,2],0),iif(ds_spec==2,tfoms_pz[4,2],0),tfoms_pz[4,10]})
            endif
            if is_reabili
              aadd(ta,{53,tfoms_pz[4,1],tfoms_pz[4,1],iif(ds_spec==1,tfoms_pz[4,1],0),iif(ds_spec==2,tfoms_pz[4,1],0),tfoms_pz[4,9]})
              aadd(ta,{58,tfoms_pz[4,2],tfoms_pz[4,2],iif(ds_spec==1,tfoms_pz[4,2],0),iif(ds_spec==2,tfoms_pz[4,2],0),tfoms_pz[4,10]})
            endif
            if is_inogoro
              aadd(ta,{54,tfoms_pz[4,1],tfoms_pz[4,1],iif(ds_spec==1,tfoms_pz[4,1],0),iif(ds_spec==2,tfoms_pz[4,1],0),tfoms_pz[4,9]})
              aadd(ta,{59,tfoms_pz[4,2],tfoms_pz[4,2],iif(ds_spec==1,tfoms_pz[4,2],0),iif(ds_spec==2,tfoms_pz[4,2],0),tfoms_pz[4,10]})
            endif
            if is_ekstra
              arr_pril5[27,igs] += tfoms_pz[4,2] // "Дн.стац.ЭКО - пациенто-дней"
              arr_pril5[28,igs] += tfoms_pz[4,1] // "Дн.стац.ЭКО - пациентов, чел."
              arr_pril5[29,igs] += tfoms_pz[4,3] // "Дн.стац.ЭКО - руб."
              arr_eko[1,1] += tfoms_pz[4,2]
              arr_eko[1,2] += tfoms_pz[4,10]
              aadd(ta,{65,tfoms_pz[4,1],tfoms_pz[4,1],0,iif(ds_spec==2,tfoms_pz[4,1],0),tfoms_pz[4,9]})
              aadd(ta,{67,tfoms_pz[4,3],tfoms_pz[4,3],0,iif(ds_spec==2,tfoms_pz[4,3],0),tfoms_pz[4,11]})
              if is_inogoro
                arr_eko[2,1] += tfoms_pz[4,2]
                arr_eko[2,2] += tfoms_pz[4,10]
                aadd(ta,{66,tfoms_pz[4,1],tfoms_pz[4,1],0,iif(ds_spec==2,tfoms_pz[4,1],0),tfoms_pz[4,9]})
                aadd(ta,{68,tfoms_pz[4,3],tfoms_pz[4,3],0,iif(ds_spec==2,tfoms_pz[4,3],0),tfoms_pz[4,11]})
              endif
            endif
            aadd(ta,{60,tfoms_pz[4,3],tfoms_pz[4,3],iif(ds_spec==1,tfoms_pz[4,3],0),iif(ds_spec==2,tfoms_pz[4,3],0),tfoms_pz[4,11]})
            if is_rebenok
              aadd(ta,{61,tfoms_pz[4,3],tfoms_pz[4,3],iif(ds_spec==1,tfoms_pz[4,3],0),iif(ds_spec==2,tfoms_pz[4,3],0),tfoms_pz[4,11]})
            endif
            if is_trudosp
              aadd(ta,{62,tfoms_pz[4,3],tfoms_pz[4,3],iif(ds_spec==1,tfoms_pz[4,3],0),iif(ds_spec==2,tfoms_pz[4,3],0),tfoms_pz[4,11]})
            endif
            if is_reabili
              aadd(ta,{63,tfoms_pz[4,3],tfoms_pz[4,3],iif(ds_spec==1,tfoms_pz[4,3],0),iif(ds_spec==2,tfoms_pz[4,3],0),tfoms_pz[4,11]})
            endif
            if is_inogoro
              aadd(ta,{64,tfoms_pz[4,3],tfoms_pz[4,3],iif(ds_spec==1,tfoms_pz[4,3],0),iif(ds_spec==2,tfoms_pz[4,3],0),tfoms_pz[4,11]})
            endif
          // скорая помощь
          case tfoms_pz[5,1] > 0
            arr_pril5[2,igs] += tfoms_pz[5,1] // "СМП - вызовов, ед."
            arr_pril5[3,igs] += tfoms_pz[5,1] // "СМП - лиц, чел."
            arr_pril5[4,igs] += tfoms_pz[5,3] // "СМП - руб."
            aadd(ta,{69,tfoms_pz[5,1],tfoms_pz[5,1]})
            arr_skor[69,isp] += tfoms_pz[5,1]
            aadd(ta,{73,tfoms_pz[5,1],tfoms_pz[5,1]})
            arr_skor[73,isp] += tfoms_pz[5,1]
            aadd(ta,{77,tfoms_pz[5,3],tfoms_pz[5,3]})
            arr_skor[77,isp] += tfoms_pz[5,3]
            if is_rebenok
              aadd(ta,{70,tfoms_pz[5,1],tfoms_pz[5,1]})
              arr_skor[70,isp] += tfoms_pz[5,1]
              aadd(ta,{74,tfoms_pz[5,1],tfoms_pz[5,1]})
              arr_skor[74,isp] += tfoms_pz[5,1]
              aadd(ta,{78,tfoms_pz[5,3],tfoms_pz[5,3]})
              arr_skor[78,isp] += tfoms_pz[5,3]
            endif
            if is_trudosp
              aadd(ta,{71,tfoms_pz[5,1],tfoms_pz[5,1]})
              arr_skor[71,isp] += tfoms_pz[5,1]
              aadd(ta,{75,tfoms_pz[5,1],tfoms_pz[5,1]})
              arr_skor[75,isp] += tfoms_pz[5,1]
              aadd(ta,{79,tfoms_pz[5,3],tfoms_pz[5,3]})
              arr_skor[79,isp] += tfoms_pz[5,3]
            endif
            if is_inogoro
              aadd(ta,{72,tfoms_pz[5,1],tfoms_pz[5,1]})
              arr_skor[72,isp] += tfoms_pz[5,1]
              aadd(ta,{76,tfoms_pz[5,1],tfoms_pz[5,1]})
              arr_skor[76,isp] += tfoms_pz[5,1]
              aadd(ta,{80,tfoms_pz[5,3],tfoms_pz[5,3]})
              arr_skor[80,isp] += tfoms_pz[5,3]
            endif
        endcase
        for j := 1 to len(ta)
          select TMP
          find (str(ta[j,1],2))
          if !found()
            append blank
            tmp->nstr := ta[j,1]
          endif
          tmp->sum4 += ta[j,2]
          tmp->sum5 += ta[j,3]
          if len(ta[j]) > 3
            tmp->sum6 += ta[j,4]
          endif
          if len(ta[j]) > 4
            tmp->sum7 += ta[j,5]
          endif
          if len(ta[j]) > 5
            tmp->sum8 += ta[j,6]
          endif
          if len(ta[j]) > 6
            tmp->sum9 += ta[j,7]
          endif
        next
        for i := 1 to len(arr_pol1)
          if fl_pol1[i] > 0
            arr_pol1[i,2] += fl_pol1[i]
            arr_pol1[i,4] += round(human->cena_1*koef,2)
            if is_inogoro
              arr_pol1[i,3] += fl_pol1[i]
              arr_pol1[i,5] += round(human->cena_1*koef,2)
            endif
          elseif fl_pol1[i] < 0
            arr_pol1[i,2] += kol_stom
            arr_pol1[i,4] += round(human->cena_1*koef,2)
            if is_inogoro
              arr_pol1[i,3] += kol_stom
              arr_pol1[i,5] += round(human->cena_1*koef,2)
            endif
          endif
        next
      endif
      select HUMAN
      skip
    enddo
  endif
  if fl_exit ; exit ; endif
  select SCHET
  skip
enddo
delete file (filetmp14)
if !fl_exit .and. tmpf14->(lastrec()) > 0
  HH := 80
  arr_title := {;
  "──────────────────────┬──────────────────────┬──────────┬───────────────────────────",;
  "  № в счёте, ФИО,     │ отч.период, № счёта, │Суммы слу-│                           ",;
  "  ст-ть случая        │ дата счёта           │чая,снятия│ РАК, № и дата акта        ",;
  "──────────────────────┴──────────────────────┴──────────┴───────────────────────────"}
  sh := len(arr_title[1])
  //
  fp := fcreate(filetmp14) ; n_list := 1 ; tek_stroke := 0
  add_string("")
  add_string(center("Список случаев, не вошедших в форму 14",sh))
  select RAKSH
  set index to
  select HUMAN
  set index to
  select TMPF14
  set relation to KOD_RAKSH into RAKSH, to schet into SCHET, to kod_h into HUMAN
  index on str(usl_ok,1)+str(schet_->nyear,4)+str(schet_->nmonth,2)+;
           str(human_->SCHET_ZAP,6) to (cur_dir+"tmpf14")
  for j := 1 to 5
    find (str(j,1))
    if found()
      add_string("")
      if j == 5
        add_string(center("[ стоматология ]",sh))
      else
        add_string(center("["+inieditspr(A__MENUVERT,glob_V006,j)+"]",sh))
      endif
      aeval(arr_title, {|x| add_string(x) } )
      do while tmpf14->usl_ok == j .and. !eof()
        s1 := lstr(human_->SCHET_ZAP)+". "+alltrim(human->fio)
        if tmpf14->kol_akt > 1
          s1 += " ("+lstr(tmpf14->kol_akt)+" актов)"
        endif
        s2 := right(str(schet_->nyear,4),2)+"/"+strzero(schet_->nmonth,2)+" "+;
              alltrim(schet_->nschet)+" от "+date_8(schet_->dschet)
        s3 := alltrim(rak->nakt)+" от "+date_8(rak->dakt)
        arr1 := array(5) ; arr2 := array(5) ; arr3 := array(5)
        k1 := perenos(arr1,s1,22)
        k2 := perenos(arr2,s2,22)
        k3 := perenos(arr3,s3,27)
        Ins_Array(arr3,1,alltrim(mo_xml->fname)) ; ++k3
        k := max(k1,k2,k3,3)
        if verify_FF(HH-k,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        v := raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
        if round(human->cena_1,2) == round(v,2)
          s := "="
        elseif empty(human->cena_1)
          s := ">"
        else
          s := "<"
        endif
        add_string(padr(arr1[1],23)+padr(arr2[1],22)+str(human->cena_1,11,2)+" "+arr3[1])
        add_string(padr(arr1[2],23)+padr(arr2[2],22)+str(v,11,2)+" "+arr3[2])
        add_string(padr(arr1[3],23)+padr(arr2[3],22)+padl(s,11)+" "+arr3[3])
        for i := 4 to k
          add_string(padr(arr1[i],23)+padr(arr2[i],23)+space(11)+" "+arr3[i])
        next
        add_string(replicate("─",sh))
        select TMPF14
        skip
      enddo
    endif
  next
  fclose(fp)
endif
close databases
if fl_exit
  restscreen(buf)
  return func_error(4,"Процесс прерван!")
endif
//
arr_razdel := {;
 {"2. стационар",1,14},;
 {"3. амбулаторная медицинская помощь",15,32},;
 {"4. стоматологическая помощь",33,45},;
 {"5. дневные стационары",46,68},;
 {"6. скорая медицинская помощь",69,81};
}
//
R_Use(dir_server+"organiz",,"ORG")
ar := {}
aadd(ar, {12,77,mm_month[arr_m[3]] })
aadd(ar, {12,94,right(lstr(arr_m[1]),2) })
aadd(ar, {35,48,glob_mo[_MO_FULL_NAME] })
aadd(ar, {37,19,glob_mo[_MO_ADRES] })
aadd(ar, {42,19,org->okpo })
aadd(arr_excel, {"Лист 1",aclone(ar)})
//
use (cur_dir+"tmp") index (cur_dir+"tmp") new
for i := 1 to len(arr_razdel)
  ar := {} ; i_stroke := iif(eq_any(i,1,4), 7, 6)
  for j := arr_razdel[i,2] to arr_razdel[i,3]
    ++i_stroke
    find (str(j,2))
    if found()
      do case
        case i == 1
          dm := 9
        case i == 2
          dm := 9
        case i == 3
          dm := 7
        case i == 4
          dm := 8
        case i == 5
          dm := 5
      endcase
      i_column := iif(i==5, 4, 3)
      for k := 4 to dm
        ++i_column
        d := 0
        do case
          case i == 1
            d := iif(k < 7, 0, 2)
          case i == 2
            d := iif(k < 7, 0, 2)
          case i == 3
            d := iif(k < 6, 0, 2)
          case i == 4
            d := iif(between(j,60,64) .or. j > 66, 2, 0)
          case i == 5
            d := iif(j < 77, 0, 2)
        endcase
        pole := "tmp->sum"+lstr(k)
        if !empty(&pole)
          aadd(ar, {i_stroke,i_column,lstr(&pole,15,d)})
        endif
      next
    endif
  next
  for k := 1 to len(ar)
    if "." $ ar[k,3]
      ar[k,3] := charrepl(".",ar[k,3],",")
    endif
  next
  aadd(arr_excel, {"Раздел "+left(arr_razdel[i,1],1),aclone(ar)})
next
close databases
restscreen(buf)
delete file (cFileProtokol)
/*k := 0
for i := 1 to len(arr_prof)
  fl_error := .t.
  strfile(padr(arr_prof[i,1],10)+str(arr_prof[i,2],10)+;
          hb_eol(),cFileProtokol,.t.)
  k += arr_prof[i,2]
next
strfile(padr("Профприёмы",10)+str(k,10)+hb_eol(),cFileProtokol,.t.)*/
//
strfile(hb_eol()+;
        padc("Дополнительные данные для заполнения формы 62",80)+;
        hb_eol(),cFileProtokol,.t.)
if kol_stom_pos > 0
  fl_error := .t.
  use (cur_dir+"TMP_STOM") new
  strfile(hb_eol()+;
          "Отчёт о количестве и стоимости обращений и посещений при оказании стоматологической помощи"+;
          hb_eol()+;
"___________________________________________________________________________________________________________________________"+hb_eol()+;
"___________________________|______всего____________|_________дети__________|____старше трудоспос.__|____иногородние________"+hb_eol()+;
"                           |случа|посе-|  сумма    |случа|посе-|  сумма    |случа|посе-|  сумма    |случа|посе-|  сумма    "+hb_eol()+;
"___________________________|ев___|щений|___________|ев___|щений|___________|ев___|щений|___________|ев___|щений|___________"+hb_eol(),cFileProtokol,.t.)
  for i := 1 to 10
    goto (i)
    if i == 9 .and. empty(tmp_stom->k2)
      loop
    endif
    strfile(tmp_stom->name+str(tmp_stom->k2,6)+str(tmp_stom->k3,6)+str(tmp_stom->k4,12,2)+;
                           str(tmp_stom->k5,6)+str(tmp_stom->k6,6)+str(tmp_stom->k7,12,2)+;
                           str(tmp_stom->k8,6)+str(tmp_stom->k9,6)+str(tmp_stom->k10,12,2)+;
                           str(tmp_stom->k11,6)+str(tmp_stom->k12,6)+str(tmp_stom->k13,12,2)+hb_eol(),cFileProtokol,.t.)
  next
  use
endif
fl := .f.
for i := 1 to len(arr_pril5)
  if !empty(arr_pril5[i,2]+arr_pril5[i,3])
    fl := .t. ; exit
  endif
next
if fl
  fl_error := .t.
  strfile(hb_eol()+;
          padl("Приложение 5 к форме 62",80)+hb_eol()+;
"─────────────────────────────────────────┬────────────┬────────────┬────────────"+hb_eol()+;
"                                         │   всего    │городские ж.│сельские жит"+hb_eol()+;
"─────────────────────────────────────────┴────────────┴────────────┴────────────"+hb_eol(),cFileProtokol,.t.)
  for i := 1 to len(arr_pril5)
    if !empty(arr_pril5[i,2]+arr_pril5[i,3])
      strfile(padr(arr_pril5[i,1],39)+str(i,2)+;
              padl(alltrim(put_val_0(arr_pril5[i,2]+arr_pril5[i,3],13,2)),13)+;
              padl(alltrim(put_val_0(arr_pril5[i,2],13,2)),13)+;
              padl(alltrim(put_val_0(arr_pril5[i,3],13,2)),13)+;
              hb_eol(),cFileProtokol,.t.)
    endif
  next
endif
if !empty(arr_dn_stac)
  fl_error := .t.
  asort(arr_dn_stac,,,{|x,y| x[1] < y[1] })
  aadd(arr_dn_stac, {"",0,0,0,0}) ; j := len(arr_dn_stac)
  strfile(hb_eol()+;
          padc("Дневной стационар по профилям",80)+hb_eol()+;
"──────────────────────────────┬─────────────────────┬──────┬──────────────────────"+hb_eol()+;
"                              │        Всего        │ сред.│  число пациенто-дней "+hb_eol()+;
"            Профиль           ├───────┬─────────────│ длит.├───────┬──────┬───────"+hb_eol()+;
"                              │случаев│    сумма    │1случ.│ всего │взрос.│ дети  "+hb_eol()+;
"──────────────────────────────┴───────┴─────────────┴──────┴───────┴──────┴───────"+hb_eol(),cFileProtokol,.t.)
  for i := 1 to len(arr_dn_stac)-1
    s := padr(lstr(arr_dn_stac[i,1])+" "+inieditspr(A__MENUVERT, glob_V002, arr_dn_stac[i,1]),30)+;
            put_val(arr_dn_stac[i,2],8)+put_kope(arr_dn_stac[i,3],14)
    k := 0
    if arr_dn_stac[i,2] > 0
      k := (arr_dn_stac[i,4]+arr_dn_stac[i,5])/arr_dn_stac[i,2]
    endif
    s += str(k,6,1)+put_val(arr_dn_stac[i,4]+arr_dn_stac[i,5],9)+;
         put_val(arr_dn_stac[i,4],7)+put_val(arr_dn_stac[i,5],7)
    strfile(s+hb_eol(),cFileProtokol,.t.)
    arr_dn_stac[j,2] += arr_dn_stac[i,2]
    arr_dn_stac[j,3] += arr_dn_stac[i,3]
    arr_dn_stac[j,4] += arr_dn_stac[i,4]
    arr_dn_stac[j,5] += arr_dn_stac[i,5]
  next
  strfile(replicate("─",83)+hb_eol(),cFileProtokol,.t.)
  s := padr("Итого:",30)+;
            put_val(arr_dn_stac[j,2],8)+put_kope(arr_dn_stac[j,3],14)
  k := 0
  if arr_dn_stac[j,2] > 0
    k := (arr_dn_stac[j,4]+arr_dn_stac[j,5])/arr_dn_stac[j,2]
  endif
  s += str(k,6,1)+put_val(arr_dn_stac[j,4]+arr_dn_stac[j,5],9)+;
       put_val(arr_dn_stac[j,4],7)+put_val(arr_dn_stac[j,5],7)
  strfile(s+hb_eol(),cFileProtokol,.t.)
  strfile(replicate("─",83)+hb_eol(),cFileProtokol,.t.)
  s := padr("в т.ч.в дн.стационарах на дому",30)+;
            put_val(arrDdn_stac[1],8)+put_kope(arrDdn_stac[2],14)
  k := 0
  if arrDdn_stac[1] > 0
    k := (arrDdn_stac[3]+arrDdn_stac[4])/arrDdn_stac[1]
  endif
  s += str(k,6,1)+put_val(arrDdn_stac[3]+arrDdn_stac[4],9)+;
       put_val(arrDdn_stac[3],7)+put_val(arrDdn_stac[4],7)
  strfile(s+hb_eol(),cFileProtokol,.t.)
endif
if !empty(arr_profil)
  fl_error := .t.
  asort(arr_profil,,,{|x,y| x[1] < y[1] })
  strfile(hb_eol()+;
          padc("Стационар по профилям",80)+hb_eol()+;
"──────────────────────────────┬────────────────────────┬────────────────────────"+hb_eol()+;
"                              │        Всего           │   в т.ч. иногородние   "+hb_eol()+;
"            Профиль           ├─────────┬──────────────┼─────────┬──────────────"+hb_eol()+;
"                              │пациентов│     сумма    │пациентов│     сумма    "+hb_eol()+;
"──────────────────────────────┴─────────┴──────────────┴─────────┴──────────────"+hb_eol(),cFileProtokol,.t.)
  for i := 1 to len(arr_profil)
    strfile(padr(lstr(arr_profil[i,1])+" "+inieditspr(A__MENUVERT, glob_V002, arr_profil[i,1]),30)+;
            put_val(arr_profil[i,2],10)+put_kope(arr_profil[i,3],15)+;
            put_val(arr_profil[i,4],10)+put_kope(arr_profil[i,5],15)+;
            hb_eol(),cFileProtokol,.t.)
  next
endif
fl := .f.
for i := 15 to 32
  if arr_pol[i] > 0
    fl := .t. ; exit
  endif
next
if fl
  fl_error := .t.
  strfile(hb_eol()+;
          padc("Амбулаторно-поликлиническая помощь",80)+hb_eol()+;
'──────────────────────────────────────────────────┬─────────────────────────────'+hb_eol()+;
'                                                  │стоимость по счетам "A" и "K"'+hb_eol()+;
'──────────────────────────────────────────────────┴─────────────────────────────'+hb_eol()+;
"Посещения с профилактической целью, всего          15"+put_kope(arr_pol[15],20)+hb_eol()+;
"  из них: врачей общей практики (семейных врачей)  16"+put_kope(arr_pol[16],20)+hb_eol()+;
"          центров здоровья                         17"+put_kope(arr_pol[17],20)+hb_eol()+;
"  из строки 15: детьми (0-17 лет включительно)     18"+put_kope(arr_pol[18],20)+hb_eol()+;
"    из них центров здоровья детьми (0-17 лет)      19"+put_kope(arr_pol[19],20)+hb_eol()+;
"           лицами старше трудоспособного возраста  20"+put_kope(arr_pol[20],20)+hb_eol()+;
" лицами, застрахованными за пределами субъекта РФ  21"+put_kope(arr_pol[21],20)+hb_eol()+;
"Посещения при оказании мед.помощи в неотл.форме    22"+put_kope(arr_pol[22],20)+hb_eol()+;
"  из них: врачей общей практики (семейных врачей)  23"+put_kope(arr_pol[23],20)+hb_eol()+;
"  из строки 22: детьми (0-17 лет включительно)     24"+put_kope(arr_pol[24],20)+hb_eol()+;
"           лицами старше трудоспособного возраста  25"+put_kope(arr_pol[25],20)+hb_eol()+;
" лицами, застрахованными за пределами субъекта РФ  26"+put_kope(arr_pol[26],20)+hb_eol()+;
"Обращения по поводу заболевания, всего             27"+put_kope(arr_pol[27],20)+hb_eol()+;
" из них к врачам общей практики (семейным врачам)  28"+put_kope(arr_pol[28],20)+hb_eol()+;
"  из строки 27: детей (0-17 лет включительно)      29"+put_kope(arr_pol[29],20)+hb_eol()+;
"     лиц старше трудоспособного возраста           30"+put_kope(arr_pol[30],20)+hb_eol()+;
"     лиц, при прохождении реабилитации             31"+put_kope(arr_pol[31],20)+hb_eol()+;
"     лиц, застрахованных за пределами субъекта РФ  32"+put_kope(arr_pol[32],20)+hb_eol(),cFileProtokol,.t.)
endif
fl := .f.
for i := 1 to 15
  if arr_pol1[i,2] > 0
    fl := .t. ; exit
  endif
next
if fl
  fl_error := .t.
  strfile(hb_eol()+;
          padc("3000 Фактические объёмы посещений и их финансирование",80)+hb_eol()+;
"────────────────────────────────────┬───────────────┬───────────────────────────"+hb_eol()+;
"                                    │   посещений   │          сумма            "+hb_eol()+;
" Наименование показателя            ├───────┬───────┼─────────────┬─────────────"+hb_eol()+;
"                                    │ всего │иногор.│    всего    │в т.ч. иногор"+hb_eol()+;
"────────────────────────────────────┴───────┴───────┴─────────────┴─────────────"+hb_eol(),cFileProtokol,.t.)
  add_val_2_array(arr_pol1,2,3,2,5)
  add_val_2_array(arr_pol1,2,6,2,5)
  add_val_2_array(arr_pol1,2,9,2,5)
  //
  add_val_2_array(arr_pol1,1,2,2,5)
  add_val_2_array(arr_pol1,1,11,2,5)
  add_val_2_array(arr_pol1,1,13,2,5)
  for i := 1 to len(arr_pol1)
    k := perenos(t_arr,arr_pol1[i,1],33)
    strfile(padr(rtrim(t_arr[1]),34,".")+strzero(i,2)+;
            put_val(arr_pol1[i,2],8)+put_val(arr_pol1[i,3],8)+;
            put_kope(arr_pol1[i,4],14)+put_kope(arr_pol1[i,5],14)+hb_eol(),cFileProtokol,.t.)
    for j := 2 to k
      strfile(padl(alltrim(t_arr[j]),34)+hb_eol(),cFileProtokol,.t.)
    next
  next
endif
if !empty(sum_k)
  fl_error := .t.
  strfile(hb_eol()+"Сумма по счетам, имеющим параметр К = "+lstr(sum_k,12,2)+;
                   " (в т.ч.дети "+lstr(sum_kd,12,2)+", трудоспос."+lstr(sum_kt,12,2)+;
                   ", иногородние "+lstr(sum_ki,12,2)+")"+hb_eol(),cFileProtokol,.t.)
endif
if !empty(sum_d)
  fl_error := .t.
  strfile(hb_eol()+"По счетам, имеющим параметр G,J,D,O,R,F,V,I,U = "+lstr(kol_d)+" приёмов на сумму "+lstr(sum_d,12,2)+hb_eol(),cFileProtokol,.t.)
endif
if arr_eko[1,1] > 0
  fl_error := .t.
  strfile(hb_eol()+;
    "Проведено выбывшими пациентами пациенто-дней при ЭКО  "+lstr(arr_eko[1,1])+" (в т.ч.ВМП "+lstr(arr_eko[1,2])+")"+hb_eol()+;
    "  из них лиц, застрахованных за пределами субъекта РФ "+lstr(arr_eko[2,1])+" (в т.ч.ВМП "+lstr(arr_eko[2,2])+")"+hb_eol(),cFileProtokol,.t.)
endif
if arr_skor[69,1] > 0 .or. arr_skor[69,2] > 0
  fl_error := .t.
  strfile(hb_eol()+padc("Скорая помощь",80)+hb_eol()+;
"──────────────────────────────────────────────────────┬────────────┬────────────"+hb_eol()+;
"                                                      │в неотлож.ф.│в экстрен.ф."+hb_eol()+;
"──────────────────────────────────────────────────────┴────────────┴────────────"+hb_eol()+;
"Число выполненных вызовов скорой медицинской помощи,69"+put_kope(arr_skor[69,1],13)+put_kope(arr_skor[69,2],13)+hb_eol()+;
"  из них: к детям (0-17 лет включительно)          ,70"+put_kope(arr_skor[70,1],13)+put_kope(arr_skor[70,2],13)+hb_eol()+;
"          к лицам старше трудоспособного возраста  ,71"+put_kope(arr_skor[71,1],13)+put_kope(arr_skor[71,2],13)+hb_eol()+;
"   к лицам, застрахованным за пределами субъекта РФ,72"+put_kope(arr_skor[72,1],13)+put_kope(arr_skor[72,2],13)+hb_eol()+;
"Число лиц, обслуженных бригадами скорой мед.помощи ,73"+put_kope(arr_skor[73,1],13)+put_kope(arr_skor[73,2],13)+hb_eol()+;
"  из них: детей (0-17 лет включительно)            ,74"+put_kope(arr_skor[74,1],13)+put_kope(arr_skor[74,2],13)+hb_eol()+;
"          лиц старше трудоспособного возраста      ,75"+put_kope(arr_skor[75,1],13)+put_kope(arr_skor[75,2],13)+hb_eol()+;
"       лиц, застрахованных за пределами субъекта РФ,76"+put_kope(arr_skor[76,1],13)+put_kope(arr_skor[76,2],13)+hb_eol()+;
"Стоимость оказанной скорой медицинской помощи,всего,77"+put_kope(arr_skor[77,1],13)+put_kope(arr_skor[77,2],13)+hb_eol()+;
"  из них: детям (0-17 лет включительно)            ,78"+put_kope(arr_skor[78,1],13)+put_kope(arr_skor[78,2],13)+hb_eol()+;
"          лицам старше трудоспособного возраста    ,79"+put_kope(arr_skor[79,1],13)+put_kope(arr_skor[79,2],13)+hb_eol()+;
"     лицам, застрахованным за пределами субъекта РФ,80"+put_kope(arr_skor[80,1],13)+put_kope(arr_skor[80,2],13)+hb_eol()+;
"Стоимость иных видов медицинской помощи и услуг    ,81"+put_kope(arr_skor[81,1],13)+put_kope(arr_skor[81,2],13)+hb_eol(),cFileProtokol,.t.)
endif
if file(filetmp14)
  viewtext(filetmp14,,,,.t.,,,5)
endif
if fl_error
  viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,3)
endif
fill_in_Excel_Book(dir_exe+"mo_14med"+sxls,;
                   cur_dir+"__14med"+sxls,;
                   arr_excel,;
                   "присланный из ТФОМС")
return NIL

*

***** 24.01.19 распечатка формы №1 из приказа ФОМС №146
Function forma1_ffoms()
Local mdate, i, j, k, d1, d2, arr_smo := {}, at1, at2, ta, fl_month, tmp, b1_1, a1_1,;
      _bd, fl, b1, b2, a1, a2, lsmo, name_file := "forma1", HH := 80, sh := 84
Private arr_m
if (arr_m := year_month(,,,3)) == NIL
  return NIL
elseif arr_m[1] < 2018
  return func_error(4,"Новый алгоритм создания данной формы введен с 2018 года!")
endif
WaitStatus("Сбор информации")
adbf := {{"smo","N",5,0},;
         {"s1","N",1,0},;
         {"s2","N",1,0},;
         {"schet","N",6,0},;
         {"summa1","N",15,2},; // за месяц
         {"summa2","N",15,2}} // снг
dbcreate(cur_dir+"tmp1",adbf)
use (cur_dir+"tmp1") new
index on str(smo,5)+str(s1,1)+str(s2,1) to (cur_dir+"tmp1")
dbcreate(cur_dir+"tmp1prot",adbf)
use (cur_dir+"tmp1prot") new
index on str(smo,5)+str(s1,1)+str(s2,1)+str(schet,6) to (cur_dir+"tmp1prot")
//
adbf := {{"smo","N",5,0},;
         {"pz","N",1,0},;
         {"vid","N",1,0},;
         {"schet","N",6,0},;
         {"kol1","N",15,2},; // за месяц
         {"kol2","N",15,2},; // снг
         {"kol3","N",6,0},; // за месяц
         {"kol4","N",6,0},; // снг
         {"summa1","N",15,2},; // за месяц
         {"summa2","N",15,2}} // снг
dbcreate(cur_dir+"tmp2",adbf)
use (cur_dir+"tmp2") new
index on str(smo,5)+str(vid,1)+str(pz,1) to (cur_dir+"tmp2")
dbcreate(cur_dir+"tmp2prot",adbf)
use (cur_dir+"tmp2prot") new
index on str(smo,5)+str(vid,1)+str(pz,1)+str(schet,6) to (cur_dir+"tmp2prot")
dbcreate(cur_dir+"tmp2pr_u",{{"kod","N",6,0},;
                             {"shifr","C",20,0},;
                             {"kol","N",15,2}})
use (cur_dir+"tmp2pr_u") new
index on str(kod,6)+shifr to (cur_dir+"tmp2pr_u")
adbf := {{"smo","N",5,0},;
         {"kod_k","N",7,0},;
         {"enp","C",16,0},;
         {"pz","N",1,0},;
         {"vid","N",1,0},;
         {"kol3","N",6,0},; // за месяц
         {"kol4","N",6,0}}  // снг
dbcreate(cur_dir+"tmp3",adbf)
use (cur_dir+"tmp3") new
//index on str(smo,5)+str(vid,1)+str(pz,1)+str(kod_k,7) to (cur_dir+"tmp3")
index on str(smo,5)+str(vid,1)+str(pz,1)+enp to (cur_dir+"tmp3")
//
tmp := aclone(arr_m)
tmp[5] := 1 // январь
ret_days_for_akt_sverki(tmp,@b1_1,,@a1_1,)
//my_debug(,print_array({tmp,b1_1,,a1_1,}))
//
d1 := d2 := 10
ret_days_for_akt_sverki(arr_m,@b1,@b2,@a1,@a2)
//my_debug(,print_array({arr_m,b1,b2,a1,a2}))
Use_base("lusl")
Use_base("luslf")
R_Use(dir_server+"mo_su",,"MOSU")
R_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to u_kod into USL
R_Use(dir_server+"kartote2",,"KART2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
set relation to recno() into HUMAN_, to kod_k into KART2
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",,"SCHET")
set relation to recno() into SCHET_
go top
do while !eof()
  lsmo := int(val(schet_->smo))
  if !empty(lsmo) .and. schet_->NREGISTR == 0 // только зарегистрированные
    @ maxrow(),0 say padr("№ "+alltrim(schet_->NSCHET)+" от "+date_8(schet_->DSCHET),28) color "W/R"
    mdate := date_reg_schet() // дата регистрации
    if lsmo == 34
      if between(mdate,boy(arr_m[5]),arr_m[6])
        fl_month := between(mdate,arr_m[5],arr_m[6])
        f1forma1_ffoms(0,arr_m,arr_smo,fl_month,schet->summa,0,0)
      endif
    else
      if between(mdate,boy(arr_m[5])+b1_1,arr_m[6]+b2)
        fl_month := between(mdate,arr_m[5]+b1,arr_m[6]+b2)
        f1forma1_ffoms(0,arr_m,arr_smo,fl_month,schet->summa,b1,b2)
      endif
    endif
    mdate1 := stod(strzero(schet_->nyear,4)+strzero(schet_->nmonth,2)+"15")
    fl_month := between(mdate1,arr_m[5],arr_m[6]) // отч.период текущий месяц
    if arr_m[1] == 2018 .and. arr_m[3] == 12
      d2 := 21
      if glob_mo[_MO_KOD_TFOMS] == '134505'
        d2 := 23
      endif
    elseif arr_m[1] == 2019 .and. arr_m[3] == 12
      d2 := 17
    endif
    msmo := int(val(schet_->smo))
    fl := between(mdate,boy(arr_m[5]),arr_m[6]+d2) ;// дата регистрации по 10 числа след.месяца
            .and. between(mdate1,boy(arr_m[5]),arr_m[6]) // !!отч.период этот год
    if fl
      if !fl_month
        // счета за пред.отч.периоды с датой от 11 тек.месяца по 10 след.месяца
        fl_month := between(mdate,arr_m[5]+d1,arr_m[6]+d2)
      endif
      if msmo != 34 .and. ascan(arr_smo, {|x| x[2] == msmo }) == 0
        aadd(arr_smo, {"",msmo})
      endif
      select HUMAN
      find (str(schet->kod,6))
      do while human->schet == schet->kod .and. !eof()
        UpdateStatus()
        f2forma1_ffoms(msmo,fl_month)
        select HUMAN
        skip
      enddo
    endif
  endif
  select SCHET
  skip
enddo
@ maxrow(),0 say padr("подсчёт снятий",28) color "W/R"
arr_h := {}
R_Use(dir_server+"mo_xml",,"MO_XML")
R_Use(dir_server+"mo_rak",,"RAK")
set relation to KOD_XML into MO_XML
R_Use(dir_server+"mo_raks",,"RAKS")
set relation to akt into RAK
R_Use(dir_server+"mo_raksh",,"RAKSH")
set relation to kod_raks into RAKS
index on str(kod_h,7) to (cur_dir+"tmp_raksh") for between(mo_xml->dfile,boy(arr_m[5]),arr_m[6]+a2)
                                             //for between(rak->DAKT,boy(arr_m[5]),arr_m[6])
go top
do while !eof()
  UpdateStatus()
  if ascan(arr_h,raksh->kod_h) == 0
    human->(dbGoto(raksh->kod_h))
    if human->schet > 0 .and. raksh->oplata > 1
      schet->(dbGoto(human->schet))
      if schet_->NREGISTR == 0 // только зарегистрированные
        if int(val(schet_->smo)) == 34
          fl_month := between(mo_xml->dfile,arr_m[5],arr_m[6])
          fl := (mo_xml->dfile <= arr_m[6])
        else
          fl_month := between(mo_xml->dfile,arr_m[5]+a1,arr_m[6]+a2)
          fl := (mo_xml->dfile >= boy(arr_m[5])+a1_1)
        endif
        if fl
          f1forma1_ffoms(1,arr_m,arr_smo,fl_month,raksh->SANK_MEK+raksh->SANK_MEE+raksh->SANK_EKMP)
        endif
      endif
    endif
  endif
  select RAKSH
  skip
enddo
@ maxrow(),0 say padr("подсчёт количества человек",28) color "W/R"
select TMP2
go top
do while !eof()
  UpdateStatus()
  select TMP3
  find (str(tmp2->smo,5)+str(tmp2->vid,1)+str(tmp2->pz,1))
  do while tmp3->smo == tmp2->smo .and. tmp3->pz  == tmp2->pz .and. tmp3->vid == tmp2->vid .and. !eof()
    UpdateStatus()
    if tmp3->kol3 > 0
      tmp2->kol3++
    endif
    if tmp3->kol4 > 0
      tmp2->kol4++
    endif
    select TMP3
    skip
  enddo
  select TMP2
  skip
enddo
close databases
if len(arr_smo) > 0
  asort(arr_smo,,,{|x,y| x[2] < y[2] })
  for i := 1 to len(arr_smo)
    if (j := ascan(glob_arr_smo,{|x| x[2] == arr_smo[i,2]})) > 0
      arr_smo[i,1] := glob_arr_smo[j,1]
    else
      arr_smo[i,1] := "СМО с кодом "+lstr(arr_smo[i,2])
    endif
  next
endif
ClrLine(maxrow(),color0) ; mybell() ; mybell()
ireg := popup_prompt(T_ROW,T_COL-5,1,{"Распечатка формы №1","Протокол создания формы №1"})
arr_title1 := {;
"     Раздел I. Использование средств обязательного медицинского страхования     ",;
"─────────────────────────────────────────────────┬───┬────────────┬─────────────",;
"                                                 │№№ │  Отчетный  │  Нарастающим",;
"Наименование показателя                          │стр│  месяц     │  итогом     ",;
"─────────────────────────────────────────────────┴───┴────────────┴─────────────"}
at1 := {}
at2 := {}
aadd(at1,{"Сумма средств по счетам, предоставленным СМО","",0,0})
aadd(at1,{"к оплате в отчетном месяце (стр.06а+06б)","06",6,0})
aadd(at1,{"  из них: за предыдущий месяц","06а",6,1})
aadd(at1,{"          за отчетный месяц","06б",6,2})
aadd(at1,{" в т.ч. сумма средств, не принятых (удержанных)","",0,0})
aadd(at1,{" по результатам контроля объемов, сроков,качества","",0,0})
aadd(at1,{" и условий предоставления мед.помощи (07а+07б)","07",7,0})
aadd(at1,{"  из них: за предыдущие месяцы","07а",7,1})
aadd(at1,{"          за отчетный месяц","07б",7,2})
aadd(at2,{"Сумма средств по счетам, предоставленным ТФОМС к","",0,0})
aadd(at2,{"оплате в отчетном месяце","08",8,0})
aadd(at2,{" в т.ч. сумма средств, не принятых (удержанных)","",0,0})
aadd(at2,{" по результатам контроля объемов,сроков,качества","",0,0})
aadd(at2,{" и условий предоставления медицинской помощи","09",9,0})
//
arr_title2 := {;
"     Раздел II. Сведения об оказанной застрахованному лицу медицинской помощи       ",;
"────────────────────┬───┬───┬───────────────────────────┬───────────────────────────",;
"       Вид          │ № │уч.│   за отчетный месяц       │     с начала года         ",;
"   медицинской      │стр│еди├───────┬──────┬────────────┼───────┬──────┬────────────",;
"      помощи        │оки│ниц│ кол-во│числен│  стоимость │ кол-во│числен│  стоимость ",;
"────────────────────┼───┼───┼───────┼──────┼────────────┼───────┼──────┼────────────",;
"         3          │   │ 4 │   6   │  7   │     8      │   9   │  10  │     11     ",;
"────────────────────┴───┴───┴───────┴──────┴────────────┴───────┴──────┴────────────"}
at_r2 := {}
aadd(at_r2,{"Первичная медико-    ",""   ,""   ,0,0})
aadd(at_r2,{"   санитарная помощь ","10" ,""   ,1,0})
aadd(at_r2,{"  амбулатар.помощь   ","11" ,"пос",1,1})
aadd(at_r2,{"  дневной стационар  ","12" ,"п/д",1,3})
aadd(at_r2,{"  стоматологическая  ","13" ,"УЕТ",1,4})
aadd(at_r2,{"Скорая медицинская   ",""   ,""   ,0,0})
aadd(at_r2,{"              помощь ","14" ,"СМП",2,6})
aadd(at_r2,{"Специализированная   ",""   ,""   ,0,0})
aadd(at_r2,{" медпомощь,в т.ч.ВМП ","15" ,""   ,3,0})
aadd(at_r2,{"  амбулатор.помощь   ","16" ,"пос",3,1})
aadd(at_r2,{"  стационар          ","17" ,"к/д",3,2})
aadd(at_r2,{"  дневной стационар  ","18" ,"п/д",3,3})
aadd(at_r2,{"  диагностич.услуги  ","19" ,"усл",3,5})
//
if ireg == 2
  name_file += "p"
endif
fp := fcreate(name_file+stxt) ; n_list := 1 ; tek_stroke := 0
use (cur_dir+"tmp1") index (cur_dir+"tmp1") new
use (cur_dir+"tmp2") index (cur_dir+"tmp2") new
if ireg == 2 // протокол созданияя формы 1
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",,"SCHET")
  set relation to recno() into SCHET_
  use (cur_dir+"tmp1prot") new
  set relation to schet into SCHET
  index on str(smo,5)+str(s1,1)+str(s2,1)+dtos(date_reg_schet())+schet_->nschet to (cur_dir+"tmp1prot")
  use (cur_dir+"tmp2pr_u") new
  index on str(kod,6)+fsort_usl(shifr) to (cur_dir+"tmp2pr_u")
  use (cur_dir+"tmp2prot") new
  set relation to schet into SCHET
  index on str(smo,5)+str(vid,1)+str(pz,1)+dtos(date_reg_schet())+schet_->nschet to (cur_dir+"tmp2prot")
  add_string("Протокол создания формы №1 для ФФОМС "+arr_m[4])
  add_string(" [ зарегистрированные счета по дате РЕГИСТРАЦИИ ]")
  for i := 1 to len(arr_smo)
    verify_FF(HH-6,.t.,sh)
    add_string("")
    add_string(arr_smo[i,1])
    for j := 1 to len(at1)
      select TMP1
      find (str(arr_smo[i,2],5)+str(at1[j,3],1)+str(at1[j,4],1))
      if found() .and. tmp1->summa1 > 0
        select TMP1prot
        find (str(arr_smo[i,2],5)+str(at1[j,3],1)+str(at1[j,4],1))
        if found()
          verify_FF(HH-4,.t.,sh)
          add_string(replicate("─",53))
          add_string(padr(at1[j,1],50)+padr(at1[j,2],3))
          add_string(replicate("─",53))
          do while arr_smo[i,2] == tmp1prot->smo .and. at1[j,3] == tmp1prot->s1 ;
                                                 .and. at1[j,4] == tmp1prot->s2 .and. !eof()
            verify_FF(HH,.t.,sh)
            add_string(space(6)+put_otch_period()+" "+;
                       schet_->nschet+" "+date_8(date_reg_schet())+str(tmp1prot->summa1,13,2))
            skip
          enddo
        endif
      endif
    next
    for j := 1 to len(at_r2)
      select TMP2
      find (str(arr_smo[i,2],5)+str(at_r2[j,4],1)+str(at_r2[j,5],1))
      if found() .and. tmp2->kol1 > 0
        select TMP2prot
        find (str(arr_smo[i,2],5)+str(at_r2[j,4],1)+str(at_r2[j,5],1))
        if found()
          verify_FF(HH-5,.t.,sh)
          add_string(replicate("─",63))
          if at_r2[j,5] == 0
            add_string(padr(at_r2[j-1,1],21)+padr(at_r2[j-1,2],4)+padr(at_r2[j-1,3],4))
          endif
          au := {}
          add_string(padr(at_r2[j,1],21)+padr(at_r2[j,2],4)+padr(at_r2[j,3],4))
          add_string(replicate("─",63))
          do while arr_smo[i,2] == tmp2prot->smo .and. at_r2[j,4] == tmp2prot->vid ;
                                                 .and. at_r2[j,5] == tmp2prot->pz .and. !eof()
            verify_FF(HH,.t.,sh)
            s := space(6)+put_otch_period()+" "+schet_->nschet+" "+date_8(date_reg_schet())
            if at_r2[j,5] > 0
              s += umest_val(tmp2prot->kol1,10,2)
            else
              s += space(10)
            endif
            s += put_val(tmp2prot->summa1,13,2)
            select TMP2pr_u
            find (str(tmp2prot->(recno()),6))
            if found()
              s += " ("
              do while tmp2pr_u->kod == tmp2prot->(recno()) .and. !eof()
                s += alltrim(tmp2pr_u->shifr)+"-"+alltrim(str_0(tmp2pr_u->kol,12,2))+","
                if (k := ascan(au, {|x| x[1] == tmp2pr_u->shifr })) == 0
                  aadd(au, {tmp2pr_u->shifr,0}) ; k := len(au)
                endif
                au[k,2] += tmp2pr_u->kol
                skip
              enddo
              s := left(s,len(s)-1)
              s += ")"
            endif
            select TMP2prot
            add_string(s)
            skip
          enddo
          if !empty(au)
            asort(au,,,{|x,y| iif(x[2]==y[2], fsort_usl(x[1]) < fsort_usl(y[1]), x[2] > y[2]) } )
            s := "по всем счетам: "
            for k := 1 to len(au)
              s += alltrim(au[k,1])+"-"+alltrim(str_0(au[k,2],12,2))+","
            next
            s := left(s,len(s)-1)
            add_string(s)
          endif
        endif
      endif
    next
  next
else
  add_string("Форма №1 для ФФОМС "+arr_m[4]+" (по приказу ФОМС №146 от 16.08.11)")
  add_string(" [ зарегистрированные счета по дате РЕГИСТРАЦИИ ]")
  for i := 1 to len(arr_smo)
    verify_FF(HH-17,.t.,sh)
    add_string("")
    add_string(arr_smo[i,1])
    add_string(replicate("=",20))
    aeval(arr_title1, {|x| add_string(x) } )
    for j := 1 to len(at1)
      s := padr(at1[j,1],50)+padr(at1[j,2],3)
      if at1[j,3] > 0
        select TMP1
        find (str(arr_smo[i,2],5)+str(at1[j,3],1)+str(at1[j,4],1))
        if found()
          s += str(tmp1->summa1,13,2)
          if !empty(tmp1->summa2)
            s += str(tmp1->summa2,14,2)
          endif
        endif
      endif
      add_string(s)
    next
    add_string("")
    verify_FF(HH-25,.t.,sh)
    aeval(arr_title2, {|x| add_string(x) } )
    for j := 1 to len(at_r2)
      s := padr(at_r2[j,1],21)+padr(at_r2[j,2],4)+padr(at_r2[j,3],4)
      if at_r2[j,4] > 0
        select TMP2
        find (str(arr_smo[i,2],5)+str(at_r2[j,4],1)+str(at_r2[j,5],1))
        if found()
          if at_r2[j,5] > 0
            s += umest_val(tmp2->kol1,7,2)+" "
          else
            s += space(8)
          endif
          s += put_val(tmp2->kol3,6)+put_val(tmp2->summa1,13,2)+" "
          if at_r2[j,5] > 0
            s += umest_val(tmp2->kol2,7,2)+" "
          else
            s += space(8)
          endif
          s += put_val(tmp2->kol4,6)+put_val(tmp2->summa2,13,2)
        endif
      endif
      add_string(s)
    next
  next
  verify_FF(HH-22,.t.,sh)
  add_string("")
  add_string("И Т О Г О")
  add_string(replicate("=",20))
  aeval(arr_title1, {|x| add_string(x) } )
  for j := 1 to len(at1)
    s := padr(at1[j,1],50)+padr(at1[j,2],3) ; ss1 := ss2 := 0
    if at1[j,3] > 0
      for i := 1 to len(arr_smo)
        select TMP1
        find (str(arr_smo[i,2],5)+str(at1[j,3],1)+str(at1[j,4],1))
        if found()
          ss1 += tmp1->summa1
          ss2 += tmp1->summa2
        endif
      next
      if !empty(ss1)
        s += str(ss1,13,2)
        if !empty(ss2)
          s += str(ss2,14,2)
        endif
      endif
    endif
    add_string(s)
  next
  for j := 1 to len(at2)
    s := padr(at2[j,1],50)+padr(at2[j,2],3)
    if at2[j,3] > 0
      select TMP1
      find (str(34,5)+str(at2[j,3],1)+str(at2[j,4],1))
      if found()
        s += str(tmp1->summa1,13,2)
        if !empty(tmp1->summa2)
          s += str(tmp1->summa2,14,2)
        endif
      endif
    endif
    add_string(s)
  next
  add_string("")
  verify_FF(HH-25,.t.,sh)
  aeval(arr_title2, {|x| add_string(x) } )
  for j := 1 to len(at_r2)
    s := padr(at_r2[j,1],21)+padr(at_r2[j,2],4)+padr(at_r2[j,3],4)
    if at_r2[j,4] > 0
      ss1 := ss2 := ss3 := ss4 := ss5 := ss6 := 0
      for i := 1 to len(arr_smo)
        select TMP2
        find (str(arr_smo[i,2],5)+str(at_r2[j,4],1)+str(at_r2[j,5],1))
        if found()
          if at_r2[j,5] > 0
            ss1 += tmp2->kol1
            ss2 += tmp2->kol2
          endif
          ss3 += tmp2->kol3
          ss4 += tmp2->kol4
          ss5 += tmp2->summa1
          ss6 += tmp2->summa2
        endif
      next
      if at_r2[j,5] > 0
        s += umest_val(ss1,7,2)+" "
      else
        s += space(8)
      endif
      s += put_val(ss3,6)+put_val(ss5,13,2)+" "
      if at_r2[j,5] > 0
        s += umest_val(ss2,7,2)+" "
      else
        s += space(8)
      endif
      s += put_val(ss4,6)+put_val(ss6,13,2)
    endif
    add_string(s)
  next
endif
      arr_title2[1] := "              других субъектов Российской Федерации, медицинской помощи"
Ins_Array(arr_title2,1,"  Раздел III. Сведения об оказанной лицам, застрахованным на территории")
at_r2[ 2,2] := "20"
at_r2[ 3,2] := "21"
at_r2[ 4,2] := "22"
at_r2[ 5,2] := "23"
at_r2[ 7,2] := "24"
at_r2[ 9,2] := "25"
at_r2[10,2] := "26"
at_r2[11,2] := "27"
at_r2[12,2] := "28"
at_r2[13,2] := "39"
if ireg == 2
  aadd(arr_smo, {"ТФОМС (иногородние)",34})
  i := len(arr_smo) // для ТФОМС
  verify_FF(HH-6,.t.,sh)
  add_string("")
  add_string(arr_smo[i,1])
  for j := 1 to len(at2)
    select TMP1
    find (str(arr_smo[i,2],5)+str(at2[j,3],1)+str(at2[j,4],1))
    if found() .and. tmp1->summa1 > 0
      select TMP1prot
      find (str(arr_smo[i,2],5)+str(at2[j,3],1)+str(at2[j,4],1))
      if found()
        verify_FF(HH-4,.t.,sh)
        add_string(replicate("─",53))
        add_string(padr(at2[j,1],50)+padr(at2[j,2],3))
        add_string(replicate("─",53))
        do while arr_smo[i,2]==tmp1prot->smo .and. at2[j,3]==tmp1prot->s1 ;
                                             .and. at2[j,4]==tmp1prot->s2 .and. !eof()
          verify_FF(HH,.t.,sh)
          add_string(space(6)+put_otch_period()+" "+;
                     schet_->nschet+" "+date_8(date_reg_schet())+str(tmp1prot->summa1,13,2))
          skip
        enddo
      endif
    endif
  next
  for j := 1 to len(at_r2)
    select TMP2
    find (str(arr_smo[i,2],5)+str(at_r2[j,4],1)+str(at_r2[j,5],1))
    if found() .and. tmp2->kol1 > 0
      select TMP2prot
      find (str(arr_smo[i,2],5)+str(at_r2[j,4],1)+str(at_r2[j,5],1))
      if found()
        verify_FF(HH-5,.t.,sh)
        add_string(replicate("─",63))
        if at_r2[j,5] == 0
          add_string(padr(at_r2[j-1,1],21)+padr(at_r2[j-1,2],4)+padr(at_r2[j-1,3],4))
        endif
        au := {}
        add_string(padr(at_r2[j,1],21)+padr(at_r2[j,2],4)+padr(at_r2[j,3],4))
        add_string(replicate("─",63))
        do while arr_smo[i,2] == tmp2prot->smo .and. at_r2[j,4] == tmp2prot->vid ;
                                               .and. at_r2[j,5] == tmp2prot->pz .and. !eof()
          verify_FF(HH,.t.,sh)
          s := space(6)+put_otch_period()+" "+schet_->nschet+" "+date_8(date_reg_schet())
          if at_r2[j,5] > 0
            s += umest_val(tmp2prot->kol1,10,2)
          else
            s += space(10)
          endif
          s += put_val(tmp2prot->summa1,13,2)
          select TMP2pr_u
          find (str(tmp2prot->(recno()),6))
          if found()
            s += " ("
            do while tmp2pr_u->kod == tmp2prot->(recno()) .and. !eof()
              s += alltrim(tmp2pr_u->shifr)+"-"+alltrim(str_0(tmp2pr_u->kol,12,2))+","
              if (k := ascan(au, {|x| x[1] == tmp2pr_u->shifr })) == 0
                aadd(au, {tmp2pr_u->shifr,0}) ; k := len(au)
              endif
              au[k,2] += tmp2pr_u->kol
              skip
            enddo
            s := left(s,len(s)-1)
            s += ")"
          endif
          select TMP2prot
          add_string(s)
          skip
        enddo
        if !empty(au)
          asort(au,,,{|x,y| iif(x[2]==y[2], fsort_usl(x[1]) < fsort_usl(y[1]), x[2] > y[2]) } )
          s := "по всем счетам: "
          for k := 1 to len(au)
            s += alltrim(au[k,1])+"-"+alltrim(str_0(au[k,2],12,2))+","
          next
          s := left(s,len(s)-1)
          add_string(s)
        endif
      endif
    endif
  next
else
  add_string("")
  verify_FF(HH-25,.t.,sh)
  aeval(arr_title2, {|x| add_string(x) } )
  for j := 1 to len(at_r2)
    s := padr(at_r2[j,1],21)+padr(at_r2[j,2],4)+padr(at_r2[j,3],4)
    if at_r2[j,4] > 0
      select TMP2
      find (str(34,5)+str(at_r2[j,4],1)+str(at_r2[j,5],1))
      if found()
        if at_r2[j,5] > 0
          s += umest_val(tmp2->kol1,7,2)+" "
        else
          s += space(8)
        endif
        s += put_val(tmp2->kol3,6)+put_val(tmp2->summa1,13,2)+" "
        if at_r2[j,5] > 0
          s += umest_val(tmp2->kol2,7,2)+" "
        else
          s += space(8)
        endif
        s += put_val(tmp2->kol4,6)+put_val(tmp2->summa2,13,2)
      endif
    endif
    add_string(s)
  next
endif
close databases
fclose(fp)
viewtext(name_file+stxt,,,,.t.,,,5)
return NIL

*

***** 26.02.20
Function f1forma1_ffoms(delta,arr_m,arr_smo,fl_month,_summa,_b1,_b2)
Local msmo, ns, ns1, mdate
DEFAULT _b1 TO 0, _b2 TO 0
if (msmo := int(val(schet_->smo))) == 34
  ns := 8+delta
else
  ns := 6+delta
  if ascan(arr_smo, {|x| x[2] == msmo }) == 0
    aadd(arr_smo, {"",msmo})
  endif
endif
select TMP1
find (str(msmo,5)+str(ns,1)+str(0,1))
if !found()
  append blank
  tmp1->smo := msmo
  tmp1->s1  := ns
  tmp1->s2  := 0
endif
if fl_month
  tmp1->summa1 += _summa
  select TMP1prot
  find (str(msmo,5)+str(ns,1)+str(0,1)+str(schet->kod,6))
  if !found()
    append blank
    tmp1prot->smo := msmo
    tmp1prot->s1  := ns
    tmp1prot->s2  := 0
    tmp1prot->schet := schet->kod
  endif
  tmp1prot->summa1 += _summa
endif
tmp1->summa2 += _summa
if ns == 6+delta .and. fl_month
  if schet_->nyear == arr_m[1] .and. schet_->nmonth == arr_m[3]
    ns1 := 2
  else
    ns1 := 1
  endif
  select TMP1
  find (str(msmo,5)+str(ns,1)+str(ns1,1))
  if !found()
    append blank
    tmp1->smo := msmo
    tmp1->s1  := ns
    tmp1->s2  := ns1
  endif
  tmp1->summa1 += _summa
  select TMP1prot
  find (str(msmo,5)+str(ns,1)+str(ns1,1)+str(schet->kod,6))
  if !found()
    append blank
    tmp1prot->smo := msmo
    tmp1prot->s1  := ns
    tmp1prot->s2  := ns1
    tmp1prot->schet := schet->kod
  endif
  tmp1prot->summa1 += _summa
endif
return NIL

*

***** 19.01.19
Function f2forma1_ffoms(msmo,fl_month)
Local tfoms_pz[6,3], mkol, ta, i, ii, j, k, lshifr, lvidpom := 1, lshifr1, j1, fl,;
      arr := {}, mkol_k := 0, mkol_1 := 0, mkol_2 := 0, mkol_55 := 0, lenp,;
      fl_T := (schet_->bukva == "T"), fl_K := (schet_->bukva == "K"), lalf := "luslf"
if arr_m[1] == 2018
  lalf += "18"
elseif arr_m[1] == 2019
  lalf += "19"
endif
select HU
find (str(human->kod,7))
do while hu->kod == human->kod .and. !eof()
  lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
  if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
    lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
    if human_->USL_OK == 3 .and. hu->stoim_1 > 0 .and. ;  // только для п-ки
                                  (i := ret_vid_pom(1,lshifr,human->k_data)) > 0
      lvidpom := iif(eq_any(i,1,11,12), 1, 3)
    endif
    fl := .f.
    if left(lshifr,5) == "1.11."
      mkol_1 += hu->kol_1
      fl := .t.
    elseif left(lshifr,2) == "2."
      if eq_any(left(lshifr,4),"2.4.","2.78","2.89","2.90","2.91") .or. fl_T
        //
      else
        fl := .t.
        mkol_2 += hu->kol_1
      endif
    elseif left(lshifr,5) == "55.1."
      if lshifr == "55.1.3"
        lvidpom := 1
      else
        lvidpom := 3
      endif
      mkol_55 += hu->kol_1
      fl := .t.
    elseif fl_K
      mkol_k += hu->kol_1
      fl := .t.
    endif
    if fl_month .and. fl
      if (i := ascan(arr, {|x| x[1] == lshifr})) == 0
        aadd(arr, {lshifr,0}) ; i := len(arr)
      endif
      arr[i,2] += hu->kol_1
    endif
  endif
  select HU
  skip
enddo
afillall(tfoms_pz,0)
if human_->USL_OK == 1 // стационар
  ii := 2
  lvidpom := 3
  tfoms_pz[ii,1] := mkol_1
elseif human_->USL_OK == 2 // дневной стационар
  ii := 3
  if empty(mkol_55)
    lvidpom := 3
  else
    tfoms_pz[ii,1] := mkol_55
  endif
elseif human_->USL_OK == 3 // поликлиника
  if fl_T // стоматология
    lvidpom := 1
    ii := 4
    select MOHU
    find (str(human->kod,7))
    do while mohu->kod == human->kod .and. !eof()
      dbSelectArea(lalf)
      find (mosu->shifr1)
      mkol := round_5(mohu->kol_1 * iif(human->vzros_reb==0, &lalf.->uetv, &lalf.->uetd), 2)
      tfoms_pz[ii,1] += mkol // кол-во УЕТ
      if fl_month
        if valtype(tfoms_pz[ii,3]) == "N"
          tfoms_pz[ii,3] := {}
        endif
        if (i := ascan(tfoms_pz[ii,3], {|x| x[1] == mosu->shifr1})) == 0
          aadd(tfoms_pz[ii,3], {mosu->shifr1,0}) ; i := len(tfoms_pz[ii,3])
        endif
        tfoms_pz[ii,3,i,2] += mkol
      endif
      select MOHU
      skip
    enddo
  elseif fl_K // отдельные услуги
    ii := 5
    lvidpom := 3
    tfoms_pz[ii,1] := mkol_k
  else
    ii := 1
    tfoms_pz[ii,1] := mkol_2 // кол-во врачебных приёмов
  endif
elseif human_->USL_OK == 4 // скорая помощь
  lvidpom := 2
  ii := 6
  tfoms_pz[ii,1] := 1 // один вызов СМП
endif
tfoms_pz[ii,2] := human->cena_1 // сумма всего случая по-новому
if valtype(tfoms_pz[ii,3]) == "N"
  tfoms_pz[ii,3] := aclone(arr)
endif
for ii := 1 to 6
  if !emptyall(tfoms_pz[ii,1],tfoms_pz[ii,2])
    select TMP2
    find (str(msmo,5)+str(lvidpom,1)+str(ii,1))
    if !found()
      append blank
      tmp2->smo := msmo
      tmp2->pz  := ii
      tmp2->vid := lvidpom
    endif
    if fl_month
      tmp2->kol1   += tfoms_pz[ii,1]
      tmp2->summa1 += tfoms_pz[ii,2]
      select TMP2prot
      find (str(msmo,5)+str(lvidpom,1)+str(ii,1)+str(schet->kod,6))
      if !found()
        append blank
        tmp2prot->smo := msmo
        tmp2prot->pz  := ii
        tmp2prot->vid := lvidpom
        tmp2prot->schet := schet->kod
      endif
      tmp2prot->kol1   += tfoms_pz[ii,1]
      tmp2prot->summa1 += tfoms_pz[ii,2]
      for i := 1 to len(tfoms_pz[ii,3])
        if tfoms_pz[ii,3,i,2] > 0
          select TMP2pr_u
          find (str(tmp2prot->(recno()),6)+padr(tfoms_pz[ii,3,i,1],20))
          if !found()
            append blank
            TMP2pr_u->kod := tmp2prot->(recno())
            TMP2pr_u->shifr := tfoms_pz[ii,3,i,1]
          endif
          TMP2pr_u->kol += tfoms_pz[ii,3,i,2]
        endif
      next
    endif
    tmp2->kol2   += tfoms_pz[ii,1]
    tmp2->summa2 += tfoms_pz[ii,2]
    select TMP2
    find (str(msmo,5)+str(lvidpom,1)+str(0,1))
    if !found()
      append blank
      tmp2->smo := msmo
      tmp2->pz  := 0
      tmp2->vid := lvidpom
    endif
    if fl_month
      tmp2->kol1   += tfoms_pz[ii,1]
      tmp2->summa1 += tfoms_pz[ii,2]
      select TMP2prot
      find (str(msmo,5)+str(lvidpom,1)+str(0,1)+str(schet->kod,6))
      if !found()
        append blank
        tmp2prot->smo := msmo
        tmp2prot->pz  := 0
        tmp2prot->vid := lvidpom
        tmp2prot->schet := schet->kod
      endif
      tmp2prot->kol1   += tfoms_pz[ii,1]
      tmp2prot->summa1 += tfoms_pz[ii,2]
    endif
    tmp2->kol2   += tfoms_pz[ii,1]
    tmp2->summa2 += tfoms_pz[ii,2]
    //
    if len(lenp := alltrim(kart2->kod_mis)) != 16
      lenp := lstr(human->kod_k)
    endif
    select TMP3
    //find (str(msmo,5)+str(lvidpom,1)+str(ii,1)+str(human->kod_k,7))
    find (str(msmo,5)+str(lvidpom,1)+str(ii,1)+padr(lenp,16))
    if !found()
      append blank
      tmp3->smo := msmo
      tmp3->kod_k := human->kod_k
      tmp3->enp := lenp
      tmp3->pz  := ii
      tmp3->vid := lvidpom
    endif
    if fl_month
      tmp3->kol3++
    endif
    tmp3->kol4++
    select TMP3
    //find (str(msmo,5)+str(lvidpom,1)+str(0,1)+str(human->kod_k,7))
    find (str(msmo,5)+str(lvidpom,1)+str(0,1)+padr(lenp,16))
    if !found()
      append blank
      tmp3->smo := msmo
      tmp3->kod_k := human->kod_k
      tmp3->enp := lenp
      tmp3->pz  := 0
      tmp3->vid := lvidpom
    endif
    if fl_month
      tmp3->kol3++
    endif
    tmp3->kol4++
  endif
next
return NIL

*****
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

***** 11.10.18
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

***** 11.10.18
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
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new alias TMP
index on str(nn,1)+str(ist_fin,1)+str(tip,1)+str(spec,9) to (cur_dir+"tmp")
if m1usl == 1
  dbcreate(cur_dir+"tmpu",adbf)
  use (cur_dir+"tmpu") new alias TMPU
  index on str(nn,1)+str(ist_fin,1)+str(tip,1)+str(spec,9)+str(u_kod,5) to (cur_dir+"tmpu")
endif
//
R_Use(dir_server+"mo_su",,"MOSU")
R_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"human_u",{dir_server+"human_u",;
                            dir_server+"human_ud"},"HU")
set relation to recno() into HU_, to u_kod into USL
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
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
name_file := "prik_848"+stxt ; HH := 42
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
use (cur_dir+"tmp") index (cur_dir+"tmp") new
if m1usl == 1
  R_Use(dir_server+"mo_su",,"MOSU")
  R_Use(dir_server+"uslugi",,"USL")
  use (cur_dir+"tmpu") index (cur_dir+"tmpu") new
endif
for _tip := 1 to 5
  arr_title := {}
  arr2 := {}
  select TMP
  find ("10"+str(_tip,1))
  do while tmp->nn == 1 .and. tmp->tip==_tip .and. tmp->ist_fin==0 .and. !eof()
    if ascan(arr2, {|x| x[1] == tmp->spec}) == 0
      if _tip == 2 .and. m1dolpro == 0 .and. tmp->spec < 0
        aadd(arr2,{tmp->spec,inieditspr(A__MENUVERT,glob_V015,abs(tmp->spec))})
      else
        aadd(arr2,{tmp->spec,inieditspr(A__MENUVERT,;
                                        iif(_tip==2.and.m1dolpro==0,glob_V004,glob_V002),;
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
          aadd(arr,{tmp->spec,inieditspr(A__MENUVERT,glob_V015,abs(tmp->spec))})
        else
          aadd(arr,{tmp->spec,inieditspr(A__MENUVERT,;
                                        iif(_tip==2.and.m1dolpro==0,glob_V004,glob_V002),;
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

*

***** 28.12.17
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

***** 14.10.15
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

*****
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
