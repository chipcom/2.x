***** mo_moder.prg - информация по модернизации
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

#define _MD_USL   1 // Шифр услуги законченного случая
#define _MD_DIAG  2 // Основной диагноз
#define _MD_OTD   3 // Отделение, где оказана услуга
#define _MD_VRACH 4 // Врач, оказавший услугу
#define _MD_SMO   5 // Страховая компания
#define _MD_SCHET 6 // счёт
#define _MD_HUMAN 7 // № ист.бол., ФИО, сроки лечения

*****
Function modern_statist(k)
Static si1 := 1, sds := 1, ssp := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~Законченные случаи (доплаты ФФОМС)",;
                "~Законченные случаи (доплаты ТФОМС)",;
                "Углубленная ~диспансеризация подростков"}
    mas_msg := {"Статистика по законченным случаям с указанием сумм доплат ФФОМС",;
                "Статистика по законченным случаям с указанием сумм доплат ТФОМС",;
                "Статистика по углубленной диспансеризации подростков"}
    mas_fun := {"modern_statist(11)",;
                "modern_statist(12)",;
                "modern_statist(13)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case between(k,11,19)
    mas_pmt := {"По дате ~выписки счета",;
                "По ~отчётному периоду",;
                "По дате ~регистрации счета"}
    if (j := popup_prompt(T_ROW,T_COL-5,sds,mas_pmt,,,"B/BG,W+/B,N/BG,BG+/B")) > 0
      sds := j
      Private pds := j
      mas_pmt := {"~Список счетов",;
                  "С объединением по ~принадлежности"}
      if eq_any(k,11,12)
        aadd(mas_pmt, "Многовариантный ~запрос")
      endif
      if (j := popup_prompt(T_ROW,T_COL-5,ssp,mas_pmt)) > 0
        ssp := j
        do case
          case k == 11
            f1zs_modern_statist(2,ssp)
          case k == 12
            f1zs_modern_statist(1,ssp)
          case k == 13
            f1udp_modern_statist(ssp)
        endcase
      endif
    endif
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
Function f1zs_modern_statist(k2,k3)
// k2 - 1-ТФОМС, 2-ФФОМС
// k3 = 1 - Список счетов
// k3 = 2 - С объединением по принадлежности
// k3 = 3 - Многовариантный запрос
Local ktmp := 0, arr_m, hGauge, fl, anv, v_doplata, r_doplata, lshifr,;
      pole, polen, rec, lsmo, lotd, lvrach, ldiag, lsumma, llen, _js := 1,;
      buf := save_maxrow(), sh, HH := 57, arr_title, reg_print, t_arr[2],;
      name_file := "modern_z"+stxt, pp[8], spp[8], old_smo := -1, i, j, k, s,;
      s1, is_20_11, sdate := stod("20121120")
if (arr_m := year_month(,,.f.)) == NIL
  return NIL
endif
if pds==2 .and. !(arr_m[5]==bom(arr_m[5]) .and. arr_m[6]==eom(arr_m[6]))
  return func_error(4,"Запрашиваемый период должен быть кратен месяцу")
endif
if k3 == 3 .and. ((_js := popup_prompt(T_ROW,T_COL-5,1,;
      {"По всем счетам","С возможностью выбора счетов"})) == 0 .or. ;
                                       empty(anv := f2zs_modern_statist()))
  return NIL
endif
if R_Use(dir_server+"schet_",,"SCHET_") .and. ;
    R_Use(dir_server+"schet",,"SCHET") .and. ;
     R_Use(dir_server+"schetd",,"SD")
  //
  hGauge := GaugeNew(,,,"Поиск информации",.t.)
  GaugeDisplay( hGauge )
  select SD
  index on str(kod,6) to (cur_dir+"tmp_sd")
  dbcreate(cur_dir+"tmp",{;
    {"is","N",1,0},;
    {"smo","N",5,0},;
    {"kol","N",6,0},;
    {"ot_per","C",5,0},;
    {"PDATE","C",4,0},;
    {"NOMER_S","C",15,0},;
    {"summa","N",13,2},;
    {"a_s","C",100,0},;
    {"schetf","N",6,0};
   })
  use (cur_dir+"tmp") new
  select SCHET
  set relation to recno() into SCHET_
  go top
  do while !eof()
    GaugeUpdate( hGauge, recno()/lastrec())
    if schet_->IS_DOPLATA == 1 // является доплатой?;0-нет, 1-да для IFIN=1 или 2
      if pds == 1
        fl := between(schet_->dschet,arr_m[5],arr_m[6])
      elseif pds == 2
        fl := between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_m[5],arr_m[6])
      else
        fl := (schet_->NREGISTR==0 .and. between(date_reg_schet(),arr_m[5],arr_m[6]))
      endif
      if fl .and. schet_->IFIN == k2 // 1-ТФОМС, 2-ФФОМС
        select TMP
        append blank
        tmp->is := 1
        tmp->smo := val(schet_->smo)
        tmp->schetf := schet->kod
        tmp->pdate := schet->pdate
        tmp->nomer_s := schet_->nschet
        tmp->kol := schet->kol
        tmp->summa := schet->summa
        tmp->ot_per := put_otch_period()
        arr := {}
        select SD
        find (str(schet->kod,6))
        do while schet->kod == sd->kod .and. !eof()
          aadd(arr,sd->kod2)
          skip
        enddo
        tmp->a_s := arr2List(arr)
      endif
    endif
    select SCHET
    skip
  enddo
  CloseGauge(hGauge)
  ktmp := tmp->(lastrec())
  close databases
  if ktmp == 0
    func_error(4,"Не обнаружено счетов по модернизации "+arr_m[4])
  endif
endif
close databases
if ktmp > 0 .and. k3 == 3
  if _js == 2 .and. !f6zs_modern_statist()
    return NIL
  endif
  mywait()
  adbf := {;
    {"kol","N",6,0},;
    {"summaf","N",13,2},;
    {"summao","N",13,2};
   }
  llen := len(anv)
  for i := 1 to 7
    aadd(adbf, {"kod" +lstr(i),"C",10,0})
    aadd(adbf, {"name"+lstr(i),"C",255,0})
  next
  dbcreate(cur_dir+"tmp1",adbf)
  use (cur_dir+"tmp1") new alias TMP
  index on kod1+kod2+kod3+kod4+kod5+kod6+kod7 to (cur_dir+"tmp1")
  use_base("lusl")
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"mo_pers",,"PERSO")
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
  R_Use(dir_server+"human_u",dir_server+"human_u","HU")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humans","HUMAN")
  set relation to recno() into HUMAN_
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",,"SCHET")
  set relation to recno() into SCHET_
  R_Use(dir_server+"schetd",cur_dir+"tmp_sd","SD")
  use (cur_dir+"tmp") new alias tmps
  index on pdate to (cur_dir+"tmp") for is == 1
  go top
  do while !eof()
    schet->(dbGoto(tmps->schetf))
    rec := schet->(recno())
    lsmo := schet_->smo
    if schet_->NREGISTR == 0 // зарегистрированные счета
      is_20_11 := (date_reg_schet() >= sdate)
    else
      is_20_11 := (schet_->DSCHET > stod("20121210")) // 10.12.2012г.
    endif
    select SD
    find (str(tmps->schetf,6))
    do while sd->kod == tmps->schetf .and. !eof()
      schet->(dbGoto(sd->kod2))
      Select HUMAN
      find (str(sd->kod2,6))
      do while human->schet == sd->kod2 .and. !eof()
        lshifr := "" ; v_doplata := r_doplata := lotd := lvrach := 0
        ret_zak_sl(@lshifr,@v_doplata,@r_doplata,@lotd,@lvrach,iif(is_20_11, sdate, nil))
        if iif(k2==1, !empty(r_doplata), .t.)
          ldiag := diag_for_xml(,.t.,,,.t.)[1]
          lsumma := iif(k2==2,v_doplata,r_doplata)
          for k := 1 to llen
            s := ""
            for i := 1 to llen-k+1
              do case
                case anv[i,2] == _MD_USL
                  s += padr(lshifr,10)
                case anv[i,2] == _MD_DIAG
                  s += padr(ldiag,10)
                case anv[i,2] == _MD_OTD
                  s += padr(lstr(lotd),10)
                case anv[i,2] == _MD_VRACH
                  s += padr(lstr(lvrach),10)
                case anv[i,2] == _MD_SMO
                  s += padr(lsmo,10)
                case anv[i,2] == _MD_SCHET
                  s += padr(lstr(tmps->schetf),10)
                case anv[i,2] == _MD_HUMAN
                  s += padr(lstr(human->kod),10)
              endcase
            next
            select TMP
            find (padr(s,llen*10))
            if !found()
              append blank
              for i := 1 to llen-k+1
                pole := "tmp->kod"+lstr(i)
                polen := "tmp->name"+lstr(i)
                do case
                  case anv[i,2] == _MD_USL
                    &pole := lshifr
                    select LUSL
                    find (padr(lshifr,10))
                    &polen := rtrim(lshifr)+" "+lusl->name
                  case anv[i,2] == _MD_DIAG
                    &pole := ldiag
                    s1 := alltrim(ldiag)+" "
                    select DIAG
                    find (padr(ldiag,6))
                    do while diag->shifr == padr(ldiag,6) .and. !eof()
                      s1 += alltrim(diag->name)+" "
                      skip
                    enddo
                    &polen := s1
                  case anv[i,2] == _MD_OTD
                    &pole := lstr(lotd)
                    otd->(dbGoto(lotd))
                    &polen := otd->name
                  case anv[i,2] == _MD_VRACH
                    &pole := lstr(lvrach)
                    perso->(dbGoto(lvrach))
                    &polen := alltrim(perso->fio)+" ["+lstr(perso->tab_nom)+"]"
                  case anv[i,2] == _MD_SMO
                    &pole := lsmo
                    &polen := f4_view_list_schet(0,lsmo,0)
                  case anv[i,2] == _MD_SCHET
                    &pole := lstr(tmps->schetf)
                    &polen := tmps->nomer_s+" от "+date_8(c4tod(tmps->pdate))
                  case anv[i,2] == _MD_HUMAN
                    &pole := lstr(human->kod)
                    &polen := alltrim(human->uch_doc)+" "+;
                              alltrim(human->fio)+" "+;
                              date_8(human->n_data)+"-"+date_8(human->k_data)+;
                              " ("+lstr(human->k_data-human->n_data)+"к/д)"
                endcase
              next
            endif
            tmp->kol ++
            tmp->summaf += lsumma
            tmp->summao += human->cena_1
          next
        endif
        //
        Select HUMAN
        skip
      enddo
      select SD
      skip
    enddo
    select TMPS
    skip
  enddo
  //
  arr_title := {;
"────────────────────────────────────────────────┬─────┬────────────┬────────────"}
  for i := 1 to llen
    s := padr(space((i-1)*2)+anv[i,1],48)+"│"
    if i == llen
      s += " кол.│доплата"+{"ТФОМС","ФФОМС"}[k2]+"│сумма по ОМС"
    else
      s += "     │            │"
    endif
    aadd(arr_title,s)
  next
  aadd(arr_title,;
"────────────────────────────────────────────────┴─────┴────────────┴────────────")
  HH := 80
  reg_print := f_reg_print(arr_title,@sh,2)
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("Информация по модернизации (законченные случаи)",sh))
  if pds == 1
    s := "дата выписки счетов"
  elseif pds == 2
    s := "отчетный период"
  else
    s := "дата регистрации счетов"
  endif
  add_string(center("[ "+s+" "+arr_m[4]+" ]",sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  select TMP
  index on left(name1,20)+left(name2,20)+left(name3,20)+;
           left(name4,20)+left(name5,20)+left(name6,20)+left(name7,20) to (cur_dir+"tmp1")
  go top
  do while !eof()
    k := 12 ; s := tmp->name7
    if empty(tmp->name2)
      k := 0 ; s := tmp->name1
    elseif empty(tmp->name3)
      k := 2 ; s := tmp->name2
    elseif empty(tmp->name4)
      k := 4 ; s := tmp->name3
    elseif empty(tmp->name5)
      k := 6 ; s := tmp->name4
    elseif empty(tmp->name6)
      k := 8 ; s := tmp->name5
    elseif empty(tmp->name7)
      k := 10 ; s := tmp->name6
    endif
    j := perenos(t_arr,s,48-k)
    if verify_FF(HH-j+1,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(padr(space(k)+t_arr[1],48)+put_val(tmp->kol,6)+;
               put_kopE(tmp->summaf,13)+put_kopE(tmp->summao,13))
    for i := 2 to j
      add_string(padl(alltrim(t_arr[i]),48))
    next
    select TMP
    skip
  enddo
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
elseif ktmp > 0
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",,"SCHET")
  set relation to recno() into SCHET_
  use (cur_dir+"tmp") new
  if k3 == 1
    index on pdate+nomer_s to (cur_dir+"tmp")
  else
    index on str(smo,5)+pdate+nomer_s to (cur_dir+"tmp")
  endif
  s1 := {"ТФОМС ","ФФОМС "}[k2]
  arr_title := {;
   "─────┬────────┬───────────────┬─────┬────────────┬────────────────────┬───────────────┬─────┬────────────",;
   "Отчет│  Дата  │ Номер счёта на│ Кол.│Сумма доплат│                    │Номер основного│ Кол.│Сумма счёта ",;
   "перио│  счета │ доплату "+s1+"│больн│   "+s1+"   │ Наименование СМО   │  счёта ОМС    │больн│    ОМС     ",;
   "─────┴────────┴───────────────┴─────┴────────────┴────────────────────┴───────────────┴─────┴────────────"}
  reg_print := f_reg_print(arr_title,@sh)
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center(expand("СПИСОК СЧЕТОВ"),sh))
  add_string(center("по модернизации (законченные случаи)",sh))
  if pds == 1
    s := "дата выписки счетов"
  elseif pds == 2
    s := "отчетный период"
  else
    s := "дата регистрации счетов"
  endif
  add_string(center("[ "+s+" "+arr_m[4]+" ]",sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  afill(spp,0) ; afill(pp,0) ; pj := 0
  select TMP
  go top
  do while !eof()
    if k3 == 2 .and. tmp->smo != old_smo
      if pj > 0
        if verify_FF(HH-2,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        add_string(space(21)+replicate("-",sh-21))
        add_string(padl("Итого:",30)+;
                   put_val(pp[1],6)+put_kopE(pp[2],13)+space(37)+;
                   put_val(pp[5],6)+put_kopE(pp[6],13))
        add_string("")
      endif
      pj := 0 ; afill(pp,0)
    endif
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    arr := List2Arr(tmp->a_s)
    schet->(dbGoto(tmp->schetf))
    s := put_otch_period()+" "+;
         date_8(schet_->dschet)+" "+;
         schet_->nschet+;
         put_val(schet->kol,6)+put_kopE(schet->summa,13)+;
         " "+padr(f4_view_list_schet(),21)
    spp[1] += schet->kol   ; pp[1] += schet->kol
    spp[2] += schet->summa ; pp[2] += schet->summa
    if len(arr) > 0
      schet->(dbGoto(arr[1]))
      s += schet_->nschet+;
           put_val(schet->kol,6)+put_kopE(schet->summa,13)
      spp[5] += schet->kol   ; pp[5] += schet->kol
      spp[6] += schet->summa ; pp[6] += schet->summa
    endif
    add_string(s)
    for i := 2 to len(arr)
      schet->(dbGoto(arr[i]))
      s := space(71)
      s += schet_->nschet+;
           put_val(schet->kol,6)+put_kopE(schet->summa,13)
      add_string(s)
      spp[5] += schet->kol   ; pp[5] += schet->kol
      spp[6] += schet->summa ; pp[6] += schet->summa
    next
    ++pj
    old_smo := tmp->smo
    select TMP
    skip
  enddo
  if verify_FF(HH-2,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  if k3 == 2 .and. pj > 0
    add_string(space(21)+replicate("-",sh-21))
    add_string(padl("Итого:",30)+;
               put_val(pp[1],6)+put_kopE(pp[2],13)+space(37)+;
               put_val(pp[5],6)+put_kopE(pp[6],13))
  endif
  if verify_FF(HH-2,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  if spp[1] > 0
    add_string(replicate("═",sh))
    add_string(padl("Всего:",30)+;
               put_val(spp[1],6)+put_kopE(spp[2],13)+space(37)+;
               put_val(spp[5],6)+put_kopE(spp[6],13))
  endif
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL

*

*****
Function f2zs_modern_statist()
Local arr_por, buf := savescreen(), ret_arr := {}, ;
      mas2 := {{ 1,"№"},{ 2,padr("Наименование",31)}},;
      mas_p := {{1,0},},;
      blk := {|b,ar,nDim,nElem,nKey| f3zs_modern_statist(b, ar, nDim, nElem, nKey)}
arr_por := {{1,"Шифр услуги законченного случая",_MD_USL  },;
            {2,"Основной диагноз               ",_MD_DIAG },;
            {3,"Отделение, где оказана услуга  ",_MD_OTD  },;
            {4,"Врач, оказавший услугу         ",_MD_VRACH},;
            {5,"Страховая компания             ",_MD_SMO  },;
            {6,"Счёт (№ и дата)                ",_MD_SCHET}}
Arrn_Browse(T_ROW,T_COL-5,T_ROW+9,T_COL+33,arr_por,mas2,1,,color1,;
            "Смена порядка ключевых полей",color8,.t.,,;
            mas_p,blk,{.f.,.f.,.f.})
dbcreate(cur_dir+"tmp",{{"name","C",31,0},{"plus","L",1,0},{"nv","N",2,0}})
use (cur_dir+"tmp") new
for i := 1 to len(arr_por)
  append blank
  replace name with arr_por[i,2], nv with arr_por[i,3]
  if i < 3
    replace plus with .t.
  endif
next
append blank
replace name with "№ ист.бол., ФИО, сроки лечения", nv with _MD_HUMAN
go top
restscreen(buf)
if Alpha_Browse(T_ROW,T_COL-5,T_ROW+10,T_COL+33,"f4zs_modern_statist",color0,;
                "Список полей для отчёта","BG+/GR",;
                .t.,.t.,,,"f5zs_modern_statist",,;
                {'═','░','═',"N/BG,W+/N,B/BG,W+/B",,300} )
  dbeval({|| aadd(ret_arr,{name,nv}) },{|| plus })
endif
close databases
restscreen(buf)
return ret_arr

*****
Function f3zs_modern_statist(b, ar, nDim, nElem, nKey)
LOCAL nRow := ROW(), nCol := COL(), flag := .f., i
Private tmp
if nKey == K_ENTER .or. between(nKey,48,57)
  tmp := ar[nElem,1]
  @ nRow,nCol get tmp picture "9"
  myread({"confirm"})
  if lastkey() != K_ESC .and. tmp > 0 .and. tmp != ar[nElem,1]
    if (i := ascan(ar, {|x| x[1] == tmp } ) ) == 0
      func_error(4,"Разрешается вводить только номера, присутствующие в таблице.")
    else
      if nElem > i  // переставляется "вверх" по таблице
        aeval(parr, {|x,j| parr[j,1] := j+1 }, i, nElem-i )
      else          // переставляется "вниз" по таблице
        aeval(parr, {|x,j| parr[j,1] := j-1 }, nElem+1, i-nElem )
      endif
      parr[nElem,1] := tmp
      flag := .t.
      asort(parr,,,{|x,y| x[1] < y[1]})
      b:refreshAll() ; b:goTop() ; ieval(tmp-1, {|| b:down() } )
    endif
  endif
else
  keyboard ""
endif
@ nRow, nCol SAY ""
return flag

*****
Function f4zs_modern_statist(oBrow)
Local oColumn, n := 31, blk_color := {|| if(tmp->plus, {1,2}, {3,4}) }
oColumn := TBColumnNew(" ", {|| if(tmp->plus,""," ") })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(center("Наименование поля",n), {|| tmp->name })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" ", {|| if(tmp->plus,""," ") })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
status_key("^<Esc>^ отказ  ^<Enter>^ начало поиска  ^<Ins>^ отметить поле для включения в отчёт")
return NIL

*****
Function f5zs_modern_statist(nKey,oBrow)
Local k := -1
if nkey == K_INS
  replace tmp->plus with !tmp->plus
  k := 0
  keyboard chr(K_TAB)
endif
return k

*****
Function f6zs_modern_statist()
Local k, buf24 := save_maxrow(), t_arr[BR_LEN], blk
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 11
t_arr[BR_RIGHT] := 67
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "Выбор счетов для многовариантного запроса"
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
blk := {|| iif(tmp->is==1, {1,2}, {3,4}) }
t_arr[BR_COLUMN] := {{ ' ', {|| iif(tmp->is==1, '', ' ') },blk },;
                     { "От/п.",{|| tmp->ot_per },blk },;
                     { "Номер счёта", {|| tmp->nomer_s },blk },;
                     { "  Дата",{|| date_8(c4tod(tmp->pdate)) },blk },;
                     { " Кол.",{|| put_val(tmp->kol,6) },blk },;
                     { " Сумма счёта",{|| put_kop(tmp->summa,13) },blk }}
t_arr[BR_EDIT] := {|nk,ob| f7zs_modern_statist(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход для печати;  ^<+,-,Ins>^ отметить счёт для анализа") }
use (cur_dir+"tmp") new
index on pdate+nomer_s to (cur_dir+"tmp")
edit_browse(t_arr)
k := 0
dbeval({|| ++k },{|| tmp->is==1})
use
return (k > 0)

*****
Function f7zs_modern_statist(nKey,oBrow,regim)
Local k := -1, rec, fl
if regim == "edit"
  do case
    case nkey == K_INS
      replace tmp->is with if(tmp->is==1,0,1)
      k := 0
      keyboard chr(K_TAB)
    case nkey == 43 .or. nkey == 45  // + или -
      fl := (nkey == 43)
      rec := recno()
      tmp->(dbeval({|| tmp->is := iif(fl,1,0) }))
      goto (rec)
      k := 0
  endcase
endif
return k

*

*****
Function f1udp_modern_statist(k3)
// k3 = 1 - Список счетов
// k3 = 2 - С объединением по принадлежности
Static sa_usl
Local k := 0, arr_m, hGauge, fl,;
      buf := save_maxrow(), sh, HH := 57, arr_title, reg_print, ;
      name_file := "modern_u"+stxt, pp[8], spp[8], old_smo := -1, s
if (arr_m := year_month(,,.f.)) == NIL
  return NIL
endif
if pds==2 .and. !(arr_m[5]==bom(arr_m[5]) .and. arr_m[6]==eom(arr_m[6]))
  return func_error(4,"Запрашиваемый период должен быть кратен месяцу")
endif
if R_Use(dir_server+"human_",,"HUMAN_") .and. ;
    R_Use(dir_server+"human",dir_server+"humans","HUMAN") .and. ;
     R_Use(dir_server+"human_u",dir_server+"human_u","HU") .and. ;
      R_Use(dir_server+"uslugi",,"USL") .and. ;
       R_Use(dir_server+"schet_",,"SCHET_") .and. ;
        R_Use(dir_server+"schet",,"SCHET")
  //
  hGauge := GaugeNew(,,,"Поиск информации",.t.)
  GaugeDisplay( hGauge )
  dbcreate(cur_dir+"tmp",{;
    {"smo","N",5,0},;
    {"schet","N",6,0};
   })
  use (cur_dir+"tmp") new
  select HUMAN
  set relation to recno() into HUMAN_
  select SCHET
  set relation to recno() into SCHET_
  go top
  do while !eof()
    GaugeUpdate( hGauge, recno()/lastrec())
    if schet_->IS_MODERN == 1 // является модернизацией?;0-нет, 1-да для IFIN=1
      if pds == 1
        fl := between(schet_->dschet,arr_m[5],arr_m[6])
      elseif pds == 2
        fl := between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_m[5],arr_m[6])
      else
        fl := (schet_->NREGISTR==0 .and. between(date_reg_schet(),arr_m[5],arr_m[6]))
      endif
      if fl
        fl := .f.
        select HUMAN
        find (str(schet->kod,6))
        do while human->schet == schet->kod .and. !eof()
          select HU
          find (str(human->kod,7))
          do while hu->kod == human->kod .and. !eof()
            usl->(dbGoto(hu->u_kod))
            if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
              lshifr := usl->shifr
            endif
            if left(lshifr,5) == "70.1." // доп.диспансеризация
              fl := .t. ; exit
            endif
            select HU
            skip
          enddo
          if fl ; exit ; endif
          select HUMAN
          skip
        enddo
      endif
      if fl
        select TMP
        append blank
        tmp->smo := val(schet_->smo)
        tmp->schet := schet->kod
      endif
    endif
    select SCHET
    skip
  enddo
  CloseGauge(hGauge)
  k := tmp->(lastrec())
  close databases
  if k == 0
    func_error(4,"Не обнаружено счетов по модернизации "+arr_m[4])
  endif
endif
close databases
if k > 0
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",,"SCHET")
  set relation to recno() into SCHET_
  use (cur_dir+"tmp") new
  set relation to schet into SCHET
  if k3 == 1
    index on schet->pdate+schet_->nschet to (cur_dir+"tmp")
  else
    index on str(smo,5)+schet->pdate+schet_->nschet to (cur_dir+"tmp")
  endif
  arr_title := {;
   "───────────────┬─────┬────────┬─────┬────────────┬────────────────────",;
   " Номер счёта   │Отч.п│  Дата  │ Кол.│ Сумма счёта│ Наименование СМО   ",;
   "───────────────┴─────┴────────┴─────┴────────────┴────────────────────"}
  reg_print := f_reg_print(arr_title,@sh)
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center(expand("СПИСОК СЧЕТОВ"),sh))
  add_string(center("по углубленной диспансеризации подростков",sh))
  if pds == 1
    s := "дата выписки счетов"
  elseif pds == 2
    s := "отчетный период"
  else
    s := "дата регистрации счетов"
  endif
  add_string(center("[ "+s+" "+arr_m[4]+" ]",sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  afill(spp,0) ; afill(pp,0) ; pj := 0
  select TMP
  go top
  do while !eof()
    if k3 == 2 .and. tmp->smo != old_smo
      if pj > 0
        if verify_FF(HH-2,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        add_string(space(21)+replicate("-",sh-21))
        add_string(padl("Итого:",30)+;
                   put_val(pp[1],6)+put_kopE(pp[2],13))
        add_string("")
      endif
      pj := 0 ; afill(pp,0)
    endif
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(schet_->nschet+" "+;
               put_otch_period()+" "+;
               date_8(schet_->dschet)+;
               put_val(schet->kol,6)+put_kopE(schet->summa,13)+;
               " "+f4_view_list_schet())
    ++pj
    old_smo := tmp->smo
    spp[1] += schet->kol   ; pp[1] += schet->kol
    spp[2] += schet->summa ; pp[2] += schet->summa
    select TMP
    skip
  enddo
  if verify_FF(HH-2,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  if k3 == 2 .and. pj > 0
    add_string(space(21)+replicate("-",sh-21))
    add_string(padl("Итого:",30)+;
               put_val(pp[1],6)+put_kopE(pp[2],13))
  endif
  if verify_FF(HH-2,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  if spp[1] > 0
    add_string(replicate("═",sh))
    add_string(padl("Всего:",30)+;
               put_val(spp[1],6)+put_kopE(spp[2],13))
  endif
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL

*

***** 12.10.14 ДВН - добавление или редактирование случая (листа учета)
Function oms_sluch_DVN13(Loc_kod,kod_kartotek,f_print)
// Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
// kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
// f_print - наименование функции для печати
Static st_N_DATA, st_K_DATA
Local bg := {|o,k| get_MKB10(o,k,.t.) }, arr_del := {}, mrec_hu := 0,;
      buf := savescreen(), tmp_color := setcolor(), a_smert := {},;
      p_uch_doc := "@!", pic_diag := "@K@!", arr_usl := {},;
      i, j, k, s, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0, ar, larr, lu_kod,;
      tmp_help := chm_help_code, fl_write_sluch := .f., mu_cena
//
Default st_N_DATA TO sys_date, st_K_DATA TO sys_date
Default Loc_kod TO 0, kod_kartotek TO 0
//
if kod_kartotek == 0 // добавление в картотеку
  if (kod_kartotek := edit_kartotek(0,,,.t.)) == 0
    return NIL
  endif
endif
chm_help_code := 3002
Private P_BEGIN_RSLT := 342, D_BEGIN_RSLT := 316, D_BEGIN_RSLT2 := 351
Private mfio := space(50), mpol, mdate_r, madres, mvozrast, mdvozrast,;
  M1VZROS_REB, MVZROS_REB, m1novor := 0,;
  m1company := 0, mcompany, mm_company,;
  mkomu, M1KOMU := 0, M1STR_CRB := 0,; // 0-ОМС,1-компании,3-комитеты/ЛПУ,5-личный счет
  msmo := "34001", rec_inogSMO := 0,;
  mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100),;
  mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20)
Private mkod := Loc_kod, mtip_h, is_talon := .f., mshifr_zs := "",;
        mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
  M1LPU := glob_uch[1], MLPU,;
  M1OTD := glob_otd[1], MOTD,;
  M1FIO_KART := 1, MFIO_KART,;
  MRAB_NERAB, M1RAB_NERAB := 0,; // 0-работающий, 1 -неработающий
  mveteran, m1veteran := 0,;
  mmobilbr, m1mobilbr := 0,;
  MUCH_DOC    := space(10)         ,; // вид и номер учетного документа
  MKOD_DIAG   := space(5)          ,; // шифр 1-ой осн.болезни
  MKOD_DIAG2  := space(5)          ,; // шифр 2-ой осн.болезни
  MKOD_DIAG3  := space(5)          ,; // шифр 3-ой осн.болезни
  MKOD_DIAG4  := space(5)          ,; // шифр 4-ой осн.болезни
  MSOPUT_B1   := space(5)          ,; // шифр 1-ой сопутствующей болезни
  MSOPUT_B2   := space(5)          ,; // шифр 2-ой сопутствующей болезни
  MSOPUT_B3   := space(5)          ,; // шифр 3-ой сопутствующей болезни
  MSOPUT_B4   := space(5)          ,; // шифр 4-ой сопутствующей болезни
  MDIAG_PLUS  := space(8)          ,; // дополнения к диагнозам
  adiag_talon[16]                  ,; // из статталона к диагнозам
  m1rslt  := 317      ,; // результат (присвоена I группа здоровья)
  m1ishod := 306      ,; // исход = осмотр
  MN_DATA := st_N_DATA         ,; // дата начала лечения
  MK_DATA := st_K_DATA         ,; // дата окончания лечения
  MVRACH := space(10)         ,; // фамилия и инициалы лечащего врача
  M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0,; // код, таб.№ и спец-ть лечащего врача
  m1povod  := 4,;   // Профилактический
  m1travma := 0, ;
  m1USL_OK :=  3,; // поликлиника
  m1VIDPOM :=  1,; // первичная
  m1PROFIL := 97,; // 97-терапия,57-общая врач.практика (семейн.мед-а),42-лечебное дело
  m1IDSP   := 11,; // доп.диспансеризация
  mcena_1 := 0
//
Private arr_usl_dop := {}, arr_usl_otkaz := {}
Private metap := 0,;  // 1-первый этап, 2-второй этап, 3-профилактика
        mndisp,;
        mWEIGHT := 0,;   // вес в кг
        mHEIGHT := 0,;   // рост в см
        mOKR_TALII := 0,; // окружность талии в см
        mtip_mas, m1tip_mas := 0,;
        mkurenie, m1kurenie := 0,; //
        mriskalk, m1riskalk := 0,; //
        mpod_alk, m1pod_alk := 0,; //
        mpsih_na, m1psih_na := 0,; //
        mfiz_akt, m1fiz_akt := 0,; //
        mner_pit, m1ner_pit := 0,; //
        mprof_ko, m1prof_ko := 0,; //
        maddn, m1addn := 0, mad1 := 120, mad2 := 80,; // давление
        mholestdn, m1holestdn := 0, mholest := 0,; //"99.99"
        mglukozadn, m1glukozadn := 0, mglukoza := 0,; //"99.99"
        mssr := 0,; // "99"
        mgruppa, m1gruppa := 9      // группа здоровья
Private mvar, m1var
Private mm_ndisp := {{"Диспансеризация I  этап",1},;
                     {"Диспансеризация II этап",2},;
                     {"Профилактический осмотр",3}}
Private mm_prof_ko := {{"индивидуальное",0},;
                       {"групповое",1}}
Private mm_gruppaP := {{"Присвоена I группа здоровья"  ,1},;
                       {"Присвоена II группа здоровья" ,2},;
                       {"Присвоена III группа здоровья",3}}
Private mm_gruppaD := aclone(mm_gruppaP)
aadd(mm_gruppaD, {"Направлен на 2 этап, предварительно присвоена I группа здоровья",11})
aadd(mm_gruppaD, {"Направлен на 2 этап, предварительно присвоена II группа здоровья",12})
aadd(mm_gruppaD, {"Направлен на 2 этап, предварительно присвоена III группа здоровья",13})
Private mm_otkaz := {{"_выполнено",0},;
                     {"отказ пац.",1},;
                     {"невозможно",2}}
Private mm_otkaz1 := {mm_otkaz[1],mm_otkaz[2]}
Private mm_pervich := {{"впервые",1},;
                       {"_ранее_",0}}
Private mm_stadia  := {{"ранняя",0},;
                       {"запущ.",1}}
Private mm_dispans := {{"ранее уст.",1},;
                       {"вперв.уст.",2},;
                       {"не установ",0}}
Private mm_usl := {{"амбулатор",0},;
                   {"стационар",1},;
                   {"спец.стац",2},;
                   {"в т.ч.ВМП",3}}
//
Private pole_diag, pole_pervich, pole_1pervich,;
        pole_stadia, pole_1stadia,;
        pole_dispans, pole_1dispans,;
        pole_dop, pole_1dop, pole_gde,;
        pole_usl, pole_1usl,;
        pole_san, pole_1san
for i := 1 to 5
  sk := lstr(i)
  pole_diag := "mdiag"+sk
  pole_pervich := "mpervich"+sk
  pole_1pervich := "m1pervich"+sk
  pole_stadia := "mstadia"+sk
  pole_1stadia := "m1stadia"+sk
  pole_dispans := "mdispans"+sk
  pole_1dispans := "m1dispans"+sk
  pole_dop := "mdop"+sk
  pole_gde := "mgde"+sk
  pole_1dop := "m1dop"+sk
  pole_usl := "musl"+sk
  pole_1usl := "m1usl"+sk
  pole_san := "msan"+sk
  pole_1san := "m1san"+sk
  Private &pole_diag := space(6)
  Private &pole_pervich := space(7)
  Private &pole_1pervich := 0
  Private &pole_stadia := space(6)
  Private &pole_1stadia := 0
  Private &pole_dispans := space(10)
  Private &pole_1dispans := 0
  Private &pole_dop := space(9)
  Private &pole_1dop := 0
  Private &pole_gde := space(4)
  Private &pole_usl := space(9)
  Private &pole_1usl := 0
  Private &pole_san := space(3)
  Private &pole_1san := 0
next
for i := 1 to count_dvn_arr_usl13
  mvar := "MTAB_NOMv"+lstr(i)
  Private &mvar := 0
  mvar := "MTAB_NOMa"+lstr(i)
  Private &mvar := 0
  mvar := "MDATE"+lstr(i)
  Private &mvar := ctod("")
  mvar := "MKOD_DIAG"+lstr(i)
  Private &mvar := space(6)
  mvar := "MOTKAZ"+lstr(i)
  Private &mvar := mm_otkaz[1,1]
  mvar := "M1OTKAZ"+lstr(i)
  Private &mvar := mm_otkaz[1,2]
next
//
afill(adiag_talon,0)
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2
if mkod_k > 0
  R_Use(dir_server+"kartote2",,"KART2")
  goto (mkod_k)
  R_Use(dir_server+"kartote_",,"KART_")
  goto (mkod_k)
  R_Use(dir_server+"kartotek",,"KART")
  goto (mkod_k)
  M1FIO       := 1
  mfio        := kart->fio
  mpol        := kart->pol
  mdate_r     := kart->date_r
  M1VZROS_REB := kart->VZROS_REB
  mADRES      := kart->ADRES
  mMR_DOL     := kart->MR_DOL
  m1RAB_NERAB := kart->RAB_NERAB
  mPOLIS      := kart->POLIS
  m1VIDPOLIS  := kart_->VPOLIS
  mSPOLIS     := kart_->SPOLIS
  mNPOLIS     := kart_->NPOLIS
  m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
  msmo        := kart_->SMO
  m1MO_PR     := kart2->MO_PR
  if kart->MI_GIT == 9
    m1komu    := kart->KOMU
    m1str_crb := kart->STR_CRB
  endif
  if eq_any(is_uchastok,1,3)
    MUCH_DOC := padr(amb_kartaN(),10)
  elseif mem_kodkrt == 2
    MUCH_DOC := padr(lstr(mkod_k),10)
  endif
  if alltrim(msmo) == '34'
    mnameismo := ret_inogSMO_name(1,,.t.) // открыть и закрыть
  endif
  // проверка исхода = СМЕРТЬ
  select HUMAN
  set index to (dir_server+"humankk")
  find (str(mkod_k,7))
  do while human->kod_k == mkod_k .and. !eof()
    if human_->oplata != 9 .and. human_->NOVOR == 0
      if recno() != Loc_kod .and. is_death(human_->RSLT_NEW) .and. empty(a_smert)
        a_smert := {"Данный больной умер!",;
                    "Лечение с "+full_date(human->N_DATA)+;
                          " по "+full_date(human->K_DATA)}
      endif
      if Loc_kod == 0 .and. between(human->ishod,201,203)
        M1RAB_NERAB := human->RAB_NERAB // 0-работающий, 1-неработающий, 2-обучающ.ОЧНО
        read_arr_DVN(human->kod,.f.)
      endif
    endif
    select HUMAN
    skip
  enddo
  set index to
endif
if empty(mWEIGHT)
  mWEIGHT := iif(mpol=="М", 70, 55)   // вес в кг
endif
if empty(mHEIGHT)
  mHEIGHT := iif(mpol=="М", 170, 160)  // рост в см
endif
if empty(mOKR_TALII)
  mOKR_TALII := iif(mpol=="М", 94, 80) // окружность талии в см
endif
if Loc_kod > 0
  select HUMAN
  goto (Loc_kod)
  M1LPU       := human->LPU
  M1OTD       := human->OTD
  M1FIO       := 1
  mfio        := human->fio
  mpol        := human->pol
  mdate_r     := human->date_r
  MTIP_H      := human->tip_h
  M1VZROS_REB := human->VZROS_REB
  MADRES      := human->ADRES         // адрес больного
  MMR_DOL     := human->MR_DOL        // место работы или причина безработности
  M1RAB_NERAB := human->RAB_NERAB     // 0-работающий, 1-неработающий, 2-обучающ.ОЧНО
  mUCH_DOC    := human->uch_doc
  m1VRACH     := human_->vrach
  MKOD_DIAG0  := human_->KOD_DIAG0
  MKOD_DIAG   := human->KOD_DIAG
  MKOD_DIAG2  := human->KOD_DIAG2
  MKOD_DIAG3  := human->KOD_DIAG3
  MKOD_DIAG4  := human->KOD_DIAG4
  MSOPUT_B1   := human->SOPUT_B1
  MSOPUT_B2   := human->SOPUT_B2
  MSOPUT_B3   := human->SOPUT_B3
  MSOPUT_B4   := human->SOPUT_B4
  MDIAG_PLUS  := human->DIAG_PLUS
  MPOLIS      := human->POLIS         // серия и номер страхового полиса
  for i := 1 to 16
    adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
  next
  m1VIDPOLIS  := human_->VPOLIS
  mSPOLIS     := human_->SPOLIS
  mNPOLIS     := human_->NPOLIS
  if empty(val(msmo := human_->SMO))
    m1komu := human->KOMU
    m1str_crb := human->STR_CRB
  else
    m1komu := m1str_crb := 0
  endif
  m1okato    := human_->OKATO  // ОКАТО субъекта РФ территории страхования
  mn_data    := human->N_DATA
  mk_data    := human->K_DATA
  mcena_1    := human->CENA_1
  if (metap := human->ishod-200) == 3 // профилактика
    m1GRUPPA := human_->RSLT_NEW-P_BEGIN_RSLT
  elseif human_->RSLT_NEW > D_BEGIN_RSLT2 // направлен на II этап
    m1GRUPPA := human_->RSLT_NEW-D_BEGIN_RSLT2+10
  else // диспансеризация I или II этап
    m1GRUPPA := human_->RSLT_NEW-D_BEGIN_RSLT
    if between(human_->RSLT_NEW,318,319) .and. human_2->PN1 == 1
      // меняем результат лечения с 11 октября 2014 года - направлен на II этап
      m1GRUPPA := human_->RSLT_NEW-D_BEGIN_RSLT+10
    endif
  endif
  //
  larr := array(2,count_dvn_arr_usl13) ; afillall(larr,0)
  R_Use(dir_server+"uslugi",,"USL")
  use_base("human_u")
  find (str(Loc_kod,7))
  do while hu->kod == Loc_kod .and. !eof()
    usl->(dbGoto(hu->u_kod))
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
      lshifr := usl->shifr
    endif
    lshifr := alltrim(lshifr)
    if eq_any(left(lshifr,5),"70.3.","72.1.")
      mshifr_zs := lshifr
    else
      fl := .t.
      if lshifr == "2.3.3" .and. hu_->PROFIL == 3 ; // акушерскому делу
          .and. (i := ascan(dvn_arr_usl13, {|x| valtype(x[2])=="C" .and. x[2]=="4.20.1"})) > 0
        fl := .f. ; larr[1,i] := hu->(recno())
      endif
      if fl
        for i := 1 to count_dvn_arr_umolch13
          if empty(larr[2,i]) .and. dvn_arr_umolch13[i,2] == lshifr
            fl := .f. ; larr[2,i] := hu->(recno()) ; exit
          endif
        next
      endif
      if fl
        for i := 1 to count_dvn_arr_usl13
          if empty(larr[1,i])
            if valtype(dvn_arr_usl13[i,2]) == "C"
              if dvn_arr_usl13[i,2] == lshifr
                fl := .f.
              endif
            elseif len(dvn_arr_usl13[i]) > 11
              if ascan(dvn_arr_usl13[i,12],{|x| x[1]==lshifr .and. x[2]==hu_->PROFIL}) > 0
                fl := .f.
              endif
            endif
            if !fl
              larr[1,i] := hu->(recno()) ; exit
            endif
          endif
        next
      endif
      if fl
        n_message({"Некорректная настройка в справочнике услуг:",;
                   alltrim(usl->name),;
                   "шифр услуги в справочнике "+usl->shifr,;
                   "шифр ТФОМС - "+opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data)},,;
                  "GR+/R","W+/R",,,"G+/R")
      endif
    endif
    aadd(arr_usl,hu->(recno()))
    select HU
    skip
  enddo
  R_Use(dir_server+"mo_pers",,"P2")
  for i := 1 to count_dvn_arr_usl13
    if !empty(larr[1,i])
      hu->(dbGoto(larr[1,i]))
      if hu->kod_vr > 0
        p2->(dbGoto(hu->kod_vr))
        mvar := "MTAB_NOMv"+lstr(i)
        &mvar := p2->tab_nom
      endif
      if hu->kod_as > 0
        p2->(dbGoto(hu->kod_as))
        mvar := "MTAB_NOMa"+lstr(i)
        &mvar := p2->tab_nom
      endif
      mvar := "MDATE"+lstr(i)
      &mvar := c4tod(hu->date_u)
      if !empty(hu_->kod_diag) .and. !(left(hu_->kod_diag,1)=="Z")
        mvar := "MKOD_DIAG"+lstr(i)
        &mvar := hu_->kod_diag
      endif
      m1var := "M1OTKAZ"+lstr(i)
      if hu_->PROFIL == 3 .and. ;
          valtype(dvn_arr_usl13[i,2])=="C" .and. dvn_arr_usl13[i,2]=="4.20.1"
        &m1var := 2 // невозможность выполнения
      endif
      mvar := "MOTKAZ"+lstr(i)
      &mvar := inieditspr(A__MENUVERT, mm_otkaz, &m1var)
    endif
  next
  if alltrim(msmo) == '34'
    mnameismo := ret_inogSMO_name(2,@rec_inogSMO,.t.) // открыть и закрыть
  endif
  read_arr_DVN(Loc_kod)
  if valtype(arr_usl_otkaz) == "A"
    for j := 1 to len(arr_usl_otkaz)
      ar := arr_usl_otkaz[j]
      if valtype(ar) == "A" .and. len(ar) >= 5 .and. valtype(ar[5]) == "C"
        lshifr := alltrim(ar[5])
        if (i := ascan(dvn_arr_usl13, {|x| valtype(x[2])=="C" .and. x[2]==lshifr})) > 0
          if valtype(ar[1]) == "N" .and. ar[1] > 0
            p2->(dbGoto(ar[1]))
            mvar := "MTAB_NOMv"+lstr(i)
            &mvar := p2->tab_nom
          endif
          if valtype(ar[3]) == "N" .and. ar[3] > 0
            p2->(dbGoto(ar[3]))
            mvar := "MTAB_NOMa"+lstr(i)
            &mvar := p2->tab_nom
          endif
          mvar := "MDATE"+lstr(i)
          &mvar := mn_data
          if len(ar) >= 9 .and. valtype(ar[9]) == "D"
            &mvar := ar[9]
          endif
          m1var := "M1OTKAZ"+lstr(i)
          &m1var := 1
          if len(ar) >= 10 .and. valtype(ar[10]) == "N" .and. between(ar[10],1,2)
            &m1var := ar[10]
          endif
          mvar := "MOTKAZ"+lstr(i)
          &mvar := inieditspr(A__MENUVERT, mm_otkaz, &m1var)
        endif
      endif
    next
  endif
  for i := 1 to 5
    f_valid_diag_oms_sluch_DVN13(,i)
  next
endif
if !(left(msmo,2) == '34') // не Волгоградская область
  m1ismo := msmo ; msmo := '34'
endif
is_talon := .t.
close databases
fv_date_r( iif(Loc_kod>0,mn_data,) )
MFIO_KART := _f_fio_kart()
mndisp    := inieditspr(A__MENUVERT, mm_ndisp, metap)
mrab_nerab:= inieditspr(A__MENUVERT, menu_rab, m1rab_nerab)
mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
mlpu      := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
motd      := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
mismo     := init_ismo(m1ismo)
f_valid_komu(,-1)
if m1komu == 0
  m1company := int(val(msmo))
elseif eq_any(m1komu,1,3)
  m1company := m1str_crb
endif
mcompany := inieditspr(A__MENUVERT, mm_company, m1company)
if m1company == 34
  if !empty(mismo)
    mcompany := padr(mismo,38)
  elseif !empty(mnameismo)
    mcompany := padr(mnameismo,38)
  endif
endif
mveteran := inieditspr(A__MENUVERT, mm_danet, m1veteran)
mmobilbr := inieditspr(A__MENUVERT, mm_danet, m1mobilbr)
mgruppa  := inieditspr(A__MENUVERT, mm_gruppaD, m1gruppa)
mkurenie := inieditspr(A__MENUVERT, mm_danet, m1kurenie)
mriskalk := inieditspr(A__MENUVERT, mm_danet, m1riskalk)
mpod_alk := inieditspr(A__MENUVERT, mm_danet, m1pod_alk)
if m1pod_alk == 0 ; m1psih_na := 0 ; endif
mpsih_na := inieditspr(A__MENUVERT, mm_danet, m1psih_na)
mfiz_akt := inieditspr(A__MENUVERT, mm_danet, m1fiz_akt)
mner_pit := inieditspr(A__MENUVERT, mm_danet, m1ner_pit)
maddn    := inieditspr(A__MENUVERT, mm_danet, m1addn)
mholestdn := inieditspr(A__MENUVERT, mm_danet, m1holestdn)
mglukozadn := inieditspr(A__MENUVERT, mm_danet, m1glukozadn)
mtip_mas := ret_tip_mas(mWEIGHT,mHEIGHT,@m1tip_mas)
mprof_ko := inieditspr(A__MENUVERT, mm_prof_ko, m1prof_ko)
ret_ndisp(Loc_kod,kod_kartotek)
//
if !empty(f_print)
  return &(f_print+"("+lstr(Loc_kod)+","+lstr(kod_kartotek)+")")
endif
//
str_1 := " случая диспансеризации/профосмотра взрослого населения"
if Loc_kod == 0
  str_1 := "Добавление"+str_1
  mtip_h := yes_vypisan
else
  str_1 := "Редактирование"+str_1
endif
setcolor(color8)
@ 0,0 say padc(str_1,80) color "B/BG*"
Private gl_area := {1,0,maxrow()-1,maxcol(),0}
setcolor(cDataCGet)
make_diagP(1)  // сделать "шестизначные" диагнозы
Private num_screen := 1
do while .t.
  close databases
  j := 1
  myclear(j)
  if yes_num_lu == 1 .and. Loc_kod > 0
    @ j,50 say padl("Лист учета № "+lstr(Loc_kod),29) color color14
  endif
  @ j,0 say "Экран "+lstr(num_screen) color color8
  if num_screen > 1
    s := alltrim(mfio)+" ("+lstr(mvozrast)+" "+s_let(mvozrast)+")"
    @ j,80-len(s) say s color color14
  endif
  if num_screen == 1 //
    //++j; @ j,1 say "Учреждение" get mlpu when .f. color cDataCSay
    //     @ row(),col()+2 say "Отделение" get motd when .f. color cDataCSay
    //
    ++j; @ j,1 say "ФИО" get mfio_kart ;
         reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
         valid {|g,o| update_get("mdate_r"),;
                      update_get("mkomu"),update_get("mcompany") }
         @ row(),col()+5 say "Д.р." get mdate_r when .f. color color14
    ++j; @ j,1 say " Работающий?" get mrab_nerab ;
         reader {|x|menu_reader(x,menu_rab,A__MENUVERT,,,.f.)}
         @ j,40 say "Ветеран ВОВ (блокадник)?" get mveteran ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say " Принадлежность счёта" get mkomu ;
               reader {|x|menu_reader(x,mm_komu,A__MENUVERT,,,.f.)} ;
               valid {|g,o| f_valid_komu(g,o) } ;
               color colget_menu
         @ row(),col()+1 say "==>" get mcompany ;
             reader {|x|menu_reader(x,mm_company,A__MENUVERT,,,.f.)} ;
             when m1komu < 5 ;
             valid {|g| func_valid_ismo(g,m1komu,38) }
    ++j; @ j,1 say " Полис ОМС: серия" get mspolis when m1komu == 0
         @ row(),col()+3 say "номер"  get mnpolis when m1komu == 0
         @ row(),col()+3 say "вид"    get mvidpolis ;
                      reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT,,,.f.)} ;
                      when m1komu == 0 ;
                      valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
    //
    ++j; @ j,1 say "Сроки" get mn_data ;
               valid {|g| f_k_data(g,1),;
                          iif(mvozrast < 18, func_error(4,"Это не взрослый пациент!"), nil),;
                          ret_ndisp(Loc_kod,kod_kartotek) ;
                     }
         @ row(),col()+1 say "-"   get mk_data valid {|g|f_k_data(g,2)}
         @ row(),col()+7 get mndisp when .f. color color14
    ++j; @ j,1 say "№ амбулаторной карты" get much_doc picture "@!" ;
               when !(is_uchastok == 1 .and. is_task(X_REGIST)) ;
                     .or. mem_edit_ist==2
         @ j,col()+5 say "Мобильная бригада?" get mmobilbr ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "Курение" get mkurenie ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
         @ j,15 say "Вероятно пагубное потребление алкоголя" get mriskalk ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say " Зависимость от алкоголя/наркотиков" get mpod_alk ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
         @ j,col()+2 say "направлен к психиатру/наркологу" get mpsih_na ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say " Низкая физическая активность" get mfiz_akt ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
         @ j,col()+5 say "Нерациональное питание" get mner_pit ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "Вес" get mWEIGHT pict "999" ;
               valid {|| iif(between(mWEIGHT,30,200),,func_error(4,"Неразумный вес")),;
                         mtip_mas := ret_tip_mas(mWEIGHT,mHEIGHT),;
                         update_get("mtip_mas") }
         @ row(),col()+1 say "кг, рост" get mHEIGHT pict "999" ;
               valid {|| iif(between(mHEIGHT,40,250),,func_error(4,"Неразумный рост")),;
                         mtip_mas := ret_tip_mas(mWEIGHT,mHEIGHT),;
                         update_get("mtip_mas") }
         @ row(),col()+1 say "см, окружность талии" get mOKR_TALII  pict "999" ;
               valid {|| iif(between(mOKR_TALII,40,200),,func_error(4,"Неразумное значение окружности талии")), .t.}
         @ row(),col()+1 say "см"
         @ row(),col()+5 get mtip_mas color color14 when .f.
    ++j; @ j,1 say " Артериальное давление" get mad1 pict "999" ;
               valid {|| iif(between(mad1,60,220),,func_error(4,"Неразумное давление")), .t.}
         @ row(),col() say "/" get mad2 pict "999";
               valid {|| iif(between(mad1,40,180),,func_error(4,"Неразумное давление")),;
                         iif(mad1 > mad2,,func_error(4,"Неразумное давление")),;
                         .t.}
         @ row(),col()+1 say "мм рт.ст.    Гипотензивная терапия" get maddn ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say " Общий холестерин" get mholest pict "99.99" ;
               valid {|| iif(empty(mholest) .or. between(mholest,3,8),,func_error(4,"Неразумное значение холестерина")), .t.}
         @ row(),col()+1 say "ммоль/л     Гиполипидемическая терапия" get mholestdn ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say " Глюкоза" get mglukoza pict "99.99" ;
               valid {|| iif(empty(mglukoza) .or. between(mglukoza,2.2,25),,func_error(4,"Критическое значение глюкозы")), .t.}
         @ row(),col()+1 say "ммоль/л     Гипогликемическая терапия" get mglukozadn ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "───────┬────────┬──────┬──────────┬───────────────────┬───────────────────────"
    ++j; @ j,1 say "диагноз│выявлено│стадия│дисп.набл.│требует доп.лечения│нужд. в сан.-кур. леч-и"
    ++j; @ j,1 say "───────┴────────┴──────┴──────────┴───────────────────┴───────────────────────"
    //              1       9        18     25         36        46        56
    ++j; @ j,1  get mdiag1 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN13(g,1),;
                                .f.) }
         @ j,9  get mpervich1 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag1)
         @ j,18 get mstadia1 ;
                reader {|x|menu_reader(x,mm_stadia,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag1)
         @ j,25 get mdispans1 ;
                reader {|x|menu_reader(x,mm_dispans,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag1)
         @ j,36 get mdop1 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag1) ;
                valid  {|g| f_valid_diag_oms_sluch_DVN13(g,1) }
         @ j,40 get mgde1 color color1 when .f.
         @ j,46 get musl1 ;
                reader {|x|menu_reader(x,mm_usl,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag1) .and. m1dop1 == 1
         @ j,56 get msan1 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag1)
    //
    ++j; @ j,1  get mdiag2 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN13(g,2),;
                                .f.) }
         @ j,9  get mpervich2 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag2)
         @ j,18 get mstadia2 ;
                reader {|x|menu_reader(x,mm_stadia,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag2)
         @ j,25 get mdispans2 ;
                reader {|x|menu_reader(x,mm_dispans,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag2)
         @ j,36 get mdop2 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag2) ;
                valid  {|g| f_valid_diag_oms_sluch_DVN13(g,2) }
         @ j,40 get mgde2 color color1 when .f.
         @ j,46 get musl2 ;
                reader {|x|menu_reader(x,mm_usl,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag2) .and. m1dop2 == 1
         @ j,56 get msan2 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag2)
    //
    ++j; @ j,1  get mdiag3 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN13(g,3),;
                                .f.) }
         @ j,9  get mpervich3 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag3)
         @ j,18 get mstadia3 ;
                reader {|x|menu_reader(x,mm_stadia,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag3)
         @ j,25 get mdispans3 ;
                reader {|x|menu_reader(x,mm_dispans,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag3)
         @ j,36 get mdop3 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag3) ;
                valid  {|g| f_valid_diag_oms_sluch_DVN13(g,3) }
         @ j,40 get mgde3 color color1 when .f.
         @ j,46 get musl3 ;
                reader {|x|menu_reader(x,mm_usl,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag3) .and. m1dop3 == 1
         @ j,56 get msan3 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag3)
    //
    ++j; @ j,1  get mdiag4 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN13(g,4),;
                                .f.) }
         @ j,9  get mpervich4 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag4)
         @ j,18 get mstadia4 ;
                reader {|x|menu_reader(x,mm_stadia,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag4)
         @ j,25 get mdispans4 ;
                reader {|x|menu_reader(x,mm_dispans,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag4)
         @ j,36 get mdop4 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag4) ;
                valid  {|g| f_valid_diag_oms_sluch_DVN13(g,4) }
         @ j,40 get mgde4 color color1 when .f.
         @ j,46 get musl4 ;
                reader {|x|menu_reader(x,mm_usl,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag4) .and. m1dop4 == 1
         @ j,56 get msan4 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag4)
    //
    ++j; @ j,1  get mdiag5 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN13(g,5),;
                                .f.) }
         @ j,9  get mpervich5 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag5)
         @ j,18 get mstadia5 ;
                reader {|x|menu_reader(x,mm_stadia,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag5)
         @ j,25 get mdispans5 ;
                reader {|x|menu_reader(x,mm_dispans,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag5)
         @ j,36 get mdop5 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag5) ;
                valid  {|g| f_valid_diag_oms_sluch_DVN13(g,5) }
         @ j,40 get mgde5 color color1 when .f.
         @ j,46 get musl5 ;
                reader {|x|menu_reader(x,mm_usl,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag5) .and. m1dop5 == 1
         @ j,56 get msan5 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag5)
    //
    ++j; @ j,1 say "─────────────────────────────────────── Суммарный сердечно-сосудистый риск" get mssr pict "99" ;
               valid {|| iif(between(mssr,0,47),,func_error(4,"Неразумное значение суммарного сердечно-сосудистого риска")), .t.}
         @ row(),col() say "%"
    status_key("^<Esc>^ выход без записи ^<PgDn>^ на 2-ю страницу")
    if !empty(a_smert)
      n_message(a_smert,,"GR+/R","W+/R",,,"G+/R")
    endif
  elseif num_screen == 2 //
    ret_ndisp(Loc_kod,kod_kartotek)
    ++j; @ j,8 get mndisp when .f. color color14
    if mvozrast != mdvozrast
      s := "(в "+lstr(year(mn_data))+" году исполняется "+lstr(mdvozrast)+" "+s_let(mdvozrast)+")"
      @ j,80-len(s) say s color color14
    endif
    ++j; @ j,1 say "────────────────────────────────────────────┬─────┬─────┬──────────"+iif(metap==2,"","┬──────────") color color8
    ++j; @ j,1 say "Наименования исследований                   │врач │ассис│дата услуг"+iif(metap==2,"","│выполнение") color color8
    ++j; @ j,1 say "────────────────────────────────────────────┴─────┴─────┴──────────"+iif(metap==2,"","┴──────────") color color8
    if mem_por_ass == 0
      @ j-1,52 say space(5)
    endif
    fl_vrach := .t.
    for i := 1 to count_dvn_arr_usl13
      fl_diag := .f.
      i_otkaz := 0
      if f_is_usl_oms_sluch_DVN13(i,metap,iif(metap==3,mvozrast,mdvozrast),mpol,;
                                  @fl_diag,@i_otkaz)
        if fl_diag .and. fl_vrach
          ++j; @ j,1 say "────────────────────────────────────────────┬─────┬─────┬──────────┬──────────" color color8
          ++j; @ j,1 say "Наименования осмотров                       │врач │ассис│дата услуг│Диагноз   " color color8
          ++j; @ j,1 say "────────────────────────────────────────────┴─────┴─────┴──────────┴──────────" color color8
          if mem_por_ass == 0
            @ j-1,52 say space(5)
          endif
          fl_vrach := .f.
        endif
        mvarv := "MTAB_NOMv"+lstr(i)
        mvara := "MTAB_NOMa"+lstr(i)
        mvard := "MDATE"+lstr(i)
        if empty(&mvard)
          &mvard := mn_data
        endif
        mvarz := "MKOD_DIAG"+lstr(i)
        mvaro := "MOTKAZ"+lstr(i)
        ++j; @ j,1 say dvn_arr_usl13[i,1]
             @ j,46 get &mvarv pict "99999" valid {|g| v_kart_vrach(g) }
      if mem_por_ass > 0
        @ j,52 get &mvara pict "99999" valid {|g| v_kart_vrach(g) }
      endif
        @ j,58 get &mvard
        if fl_diag
          @ j,69 get &mvarz picture pic_diag ;
                 reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
        elseif i_otkaz == 1
          @ j,69 get &mvaro ;
                 reader {|x|menu_reader(x,mm_otkaz1,A__MENUVERT,,,.f.)}
        elseif eq_any(i_otkaz,2,3)
          @ j,69 get &mvaro ;
                 reader {|x|menu_reader(x,mm_otkaz,A__MENUVERT,,,.f.)}
        endif
      endif
    next
    ++j; @ j,1 say replicate("─",78) color color8
    if metap == 2
      ++j; @ j,1 say "Профилактическое консультирование" get mprof_ko ;
                 reader {|x|menu_reader(x,mm_prof_ko,A__MENUVERT,,,.f.)}
    endif
    ++j; @ j,1 say "ГРУППА состояния ЗДОРОВЬЯ"
         @ j,col()+1 get mGRUPPA ;
                reader {|x|menu_reader(x,iif(metap==1,mm_gruppaD,mm_gruppaP),A__MENUVERT,,,.f.)}
    status_key("^<Esc>^ выход без записи ^<PgUp>^ на 1-ю страницу ^<PgDn>^ ЗАПИСЬ")
  endif
  count_edit += myread()
  if num_screen == 2
    if lastkey() == K_PGUP
      k := 3
      --num_screen
    else
      k := f_alert({padc("Выберите действие",60,".")},;
                   {" Выход без записи "," Запись "," Возврат в редактирование "},;
                   iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
    endif
  else
    if lastkey() == K_PGUP
      k := 3
      if num_screen > 1
        --num_screen
      endif
    elseif lastkey() == K_ESC
      if (k := f_alert({padc("Выберите действие",60,".")},;
                       {" Выход без записи "," Возврат в редактирование "},;
                       1,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )) == 2
        k := 3
      endif
    else
      k := 3
      ++num_screen
      if mvozrast < 18
        num_screen := 1
        func_error(4,"Это не взрослый пациент!")
      elseif metap == 0
        num_screen := 1
        func_error(4,"Проверьте сроки лечения!")
      endif
    endif
  endif
  if k == 3
    loop
  elseif k == 2
    num_screen := 1
    if m1komu < 5 .and. empty(m1company)
      if m1komu == 0     ; s := "СМО"
      elseif m1komu == 1 ; s := "компании"
      else               ; s := "комитета/МО"
      endif
      func_error(4,'Не заполнено наименование '+s)
      loop
    endif
    if m1komu == 0 .and. empty(mnpolis)
      func_error(4,'Не заполнен номер полиса')
      loop
    endif
    if empty(mn_data)
      func_error(4,"Не введена дата начала лечения.")
      loop
    endif
    if mvozrast < 18
      func_error(4,"Профилактика оказана НЕ взрослому пациенту!")
      loop
    endif
    if empty(mk_data)
      func_error(4,"Не введена дата окончания лечения.")
      loop
    elseif mk_data < stod("20130601")
      func_error(4,"Дата окончания лечения не должна быть ранее 1 июня 2013 года")
      loop
    elseif mk_data > stod("20150331")
      func_error(4,"Дата окончания лечения не должна быть позже 31 марта 2015 года")
      loop
    endif
    if empty(CHARREPL("0",much_doc,space(10)))
      func_error(4,'Не заполнен номер амбулаторной карты')
      loop
    endif
    if empty(mWEIGHT)
      func_error(4,"Не введён вес.")
      loop
    endif
    if empty(mHEIGHT)
      func_error(4,"Не введён рост.")
      loop
    endif
    if empty(mOKR_TALII)
      func_error(4,"Не введена окружность талии.")
      loop
    endif
    if m1veteran == 1
      if metap == 3
        func_error(4,"Профилактику взрослых не проводят ветеранам ВОВ (блокадникам)")
        loop
      //elseif M1RAB_NERAB == 2 // 2-студент
        //func_error(4,"Студент не может быть ветераном ВОВ (блокадником)")
        //loop
      //elseif year(mdate_r) > 1945
        //func_error(4,"Слишком молодой ветеран ВОВ (блокадник)")
        //loop
      endif
    endif
    //
    mdef_diagnoz := iif(metap==2, "Z01.8 ", "Z00.8 ")
    R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","P2")
    num_screen := 2
    max_date1 := mn_data
    fl := .t.
    k := ku := 0
    arr_osm1 := array(count_dvn_arr_usl13,10) ; afillall(arr_osm1,0)
    for i := 1 to count_dvn_arr_usl13
      fl_diag := fl_ekg := .f.
      i_otkaz := 0
      if f_is_usl_oms_sluch_DVN13(i,metap,iif(metap==3,mvozrast,mdvozrast),mpol,;
                                  @fl_diag,@i_otkaz,@fl_ekg)
        mvart := "MTAB_NOMv"+lstr(i)
        if empty(&mvart) .and. (metap==2 .or. fl_ekg) // ЭКГ, не введён врач
          loop                                        // и необязательный возраст
        endif
        mvara := "MTAB_NOMa"+lstr(i)
        mvard := "MDATE"+lstr(i)
        mvarz := "MKOD_DIAG"+lstr(i)
        mvaro := "M1OTKAZ"+lstr(i)
        if &mvard == mn_data
          k := i
        endif
        ar := dvn_arr_usl13[i]
        if i_otkaz == 2 .and. &mvaro == 2 // если исследование невозможно
          arr_osm1[i,5] := ar[2] // шифр услуги
          arr_osm1[i,9] := iif(empty(&mvard), mn_data, &mvard)
          arr_osm1[i,10] := &mvaro
        elseif empty(&mvard)
          fl := func_error(4,'Не введена дата услуги "'+ltrim(ar[1])+'"')
        elseif empty(&mvart)
          fl := func_error(4,'Не введен врач в услуге "'+ltrim(ar[1])+'"')
        else
          select P2
          find (str(&mvart,5))
          if found()
            arr_osm1[i,1] := p2->kod
            arr_osm1[i,2] := p2->prvs
          endif
          if !empty(&mvara)
            select P2
            find (str(&mvara,5))
            if found()
              arr_osm1[i,3] := p2->kod
            endif
          endif
          if valtype(ar[10]) == "N"
            arr_osm1[i,4] := ar[10] // профиль
          else
            if len(ar[10]) == len(ar[11]) ; // кол-во профилей = кол-ву спец-тей
                       .and. arr_osm1[i,2] > 0 ; // и нашли специальность
                       .and. (j := ascan(ar[11],arr_osm1[i,2])) > 0
              // берём профиль, соответствующий специальности
            else
              j := 1 // если нет, берём первый профиль из списка
            endif
            arr_osm1[i,4] := ar[10,j] // профиль
          endif
          ++ku
          if valtype(ar[2]) == "C"
            arr_osm1[i,5] := ar[2] // шифр услуги
          else
            if len(ar[2]) >= metap
              j := metap
            else
              j := 1
            endif
            arr_osm1[i,5] := ar[2,j] // шифр услуги
            if i == count_dvn_arr_usl13 // последняя услуга из массива - терапевт
              if metap == 2
                j := 0
                for j1 := 1 to i-1
                  if !empty(arr_osm1[j1,5]) .and. eq_any(arr_osm1[j1,5],"4.12.170","4.12.171","4.12.173","10.3.13")
                    j := j1 ; exit
                  endif
                next
                if j == 0 // если не нашли ни одной услуги из списка
                  arr_osm1[i,5] := "2.84.7" // меняем шифр услуги приёма терапевта
                endif
                if arr_osm1[i,2] == 2002 // специальность-фельдшер
                  fl := func_error(4,"Фельдшер не может заменить терапевта на II этапе диспансеризации")
                endif
              else // 1 и 3 этап
                if arr_osm1[i,2] == 1110 // специальность-врач общей практики
                  arr_osm1[i,5] := "2.3.2" // шифр услуги
                elseif arr_osm1[i,2] == 2002 // специальность-фельдшер
                  arr_osm1[i,5] := "2.3.3" // шифр услуги
                endif
              endif
            endif
          endif
          if !fl_diag .or. empty(&mvarz) .or. left(&mvarz,1) == "Z"
            arr_osm1[i,6] := mdef_diagnoz
          else
            arr_osm1[i,6] := &mvarz
            select MKB_10
            find (padr(arr_osm1[i,6],6))
            if found() .and. !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
              fl := func_error(4,"Несовместимость диагноза по полу "+arr_osm1[i,6])
            endif
          endif
          if i_otkaz > 0
            arr_osm1[i,10] := &mvaro
            if i_otkaz == 3 .and. &mvaro == 2 // Иссл-е цит.материала,4.20.1
              arr_osm1[i,5] := "2.3.3" // приём фельдшера-акушера
              arr_osm1[i,4] := 3 // профиль - акушерскому делу
              arr_osm1[i,10] := 0 // нет отказа
            endif
          endif
          arr_osm1[i,9] := &mvard
          max_date1 := max(max_date1,arr_osm1[i,9])
        endif
      endif
      if !fl ; exit ; endif
    next
    if !fl
      loop
    endif
    if metap == 2
      if ku < 2
        func_error(4,"На II этапе обязателен осмотр терапевта и ещё какие-либо услуги.")
        loop
      endif
      if k == 0
        func_error(4,"Дата первого осмотра (исследования) должна равняться дате начала лечения.")
        loop
      endif
    endif
    if emptyany(arr_osm1[count_dvn_arr_usl13,1],arr_osm1[count_dvn_arr_usl13,9])
      fl := func_error(4,'Не введён приём терапевта (врача общей практики)')
    elseif arr_osm1[count_dvn_arr_usl13,9] < mk_data
      fl := func_error(4,'Терапевт (врач общей практики) должен проводить осмотр последним!')
    endif
    if !fl
      loop
    endif
    if between(m1GRUPPA,1,3)
      m1rslt := iif(metap==3, P_BEGIN_RSLT, D_BEGIN_RSLT) + m1GRUPPA
    elseif between(m1GRUPPA,11,13)
      m1rslt := D_BEGIN_RSLT2 + m1GRUPPA - 10
    else
      func_error(4,"Не введена ГРУППА состояния ЗДОРОВЬЯ")
      loop
    endif
    //
    err_date_diap(mn_data,"Дата начала лечения")
    err_date_diap(mk_data,"Дата окончания лечения")
    //
    if mem_op_out == 2 .and. yes_parol
      box_shadow(19,10,22,69,cColorStMsg)
      str_center(20,'Оператор "'+fio_polzovat+'".',cColorSt2Msg)
      str_center(21,'Ввод данных за '+date_month(sys_date),cColorStMsg)
    endif
    mywait()
    //
    if metap == 2
      i := count_dvn_arr_usl13
      m1vrach  := arr_osm1[i,1]
      m1prvs   := arr_osm1[i,2]
      m1assis  := arr_osm1[i,3]
      m1PROFIL := arr_osm1[i,4]
      MKOD_DIAG := padr(arr_osm1[i,6],6)
    else  // metap := 1,3
      aadd(arr_osm1,array(10)) ; i := len(arr_osm1)
      arr_osm1[i,1] := arr_osm1[i-1,1]
      arr_osm1[i,2] := arr_osm1[i-1,2]
      arr_osm1[i,3] := arr_osm1[i-1,3]
      arr_osm1[i,4] := arr_osm1[i-1,4]
      arr_osm1[i,5] := ret_shifr_zs_DVN13(metap,iif(metap==3,mvozrast,mdvozrast),mpol)
      arr_osm1[i,6] := arr_osm1[i-1,6]
      arr_osm1[i,9] := mn_data
      arr_osm1[i,10] := 0
      m1vrach  := arr_osm1[i,1]
      m1prvs   := arr_osm1[i,2]
      m1assis  := arr_osm1[i,3]
      m1PROFIL := arr_osm1[i,4]
      MKOD_DIAG := padr(arr_osm1[i,6],6)
    endif
    select MKB_10
    find (MKOD_DIAG)
    if found() .and. !between_date(mkb_10->dbegin,mkb_10->dend,mk_data)
      MKOD_DIAG := mdef_diagnoz // если диагноз не входит в ОМС, то умолчание
    endif
    for i := 1 to count_dvn_arr_umolch13
      if f_is_umolch_sluch_DVN13(i,metap,iif(metap==3,mvozrast,mdvozrast),mpol)
        aadd(arr_osm1,array(10)) ; j := len(arr_osm1)
        arr_osm1[j,1] := m1vrach
        arr_osm1[j,2] := m1prvs
        arr_osm1[j,3] := m1assis
        arr_osm1[j,4] := m1PROFIL
        arr_osm1[j,5] := dvn_arr_umolch13[i,2]
        arr_osm1[j,6] := mdef_diagnoz
        arr_osm1[j,9] := iif(dvn_arr_umolch13[i,8]==0, mn_data, mk_data)
        arr_osm1[j,10] := 0
      endif
    next
    make_diagP(2)  // сделать "пятизначные" диагнозы
    //
    Use_base("lusl")
    Use_base("luslc")
    Use_base("uslugi")
    R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                                dir_server+"uslugi1s"},"USL1")
    mcena_1 := mu_cena := 0
    arr_usl_dop := {}
    arr_usl_otkaz := {}
    for i := 1 to len(arr_osm1)
      if valtype(arr_osm1[i,5]) == "C"
        arr_osm1[i,7] := foundOurUsluga(arr_osm1[i,5],mk_data,arr_osm1[i,4],M1VZROS_REB,@mu_cena)
        arr_osm1[i,8] := mu_cena
        mcena_1 += mu_cena
        if arr_osm1[i,10] == 0
          aadd(arr_usl_dop,arr_osm1[i])
        else
          aadd(arr_usl_otkaz,arr_osm1[i])
        endif
      endif
    next
    //
    Use_base("human")
    if Loc_kod > 0
      find (str(Loc_kod,7))
      mkod := Loc_kod
      G_RLock(forever)
    else
      Add1Rec(7)
      mkod := recno()
      replace human->kod with mkod
    endif
    select HUMAN_
    do while human_->(lastrec()) < mkod
      APPEND BLANK
    enddo
    goto (mkod)
    G_RLock(forever)
    //
    select HUMAN_2
    do while human_2->(lastrec()) < mkod
      APPEND BLANK
    enddo
    goto (mkod)
    G_RLock(forever)
    //
    st_N_DATA := MN_DATA
    glob_perso := mkod
    if m1komu == 0
      msmo := lstr(m1company)
      m1str_crb := 0
    else
      msmo := ""
      m1str_crb := m1company
    endif
    //
    human->kod_k      := glob_kartotek
    human->TIP_H      := B_STANDART // 3-лечение завершено
    human->FIO        := MFIO          // Ф.И.О. больного
    human->POL        := MPOL          // пол
    human->DATE_R     := MDATE_R       // дата рождения больного
    human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
    human->ADRES      := MADRES        // адрес больного
    human->MR_DOL     := MMR_DOL       // место работы или причина безработности
    human->RAB_NERAB  := M1RAB_NERAB   // 0-работающий, 1-неработающий, 2-студент
    human->KOD_DIAG   := mkod_diag     // шифр 1-ой осн.болезни
    human->diag_plus  := mdiag_plus    //
    human->KOMU       := M1KOMU        // от 0 до 5
    human_->SMO       := msmo
    human->STR_CRB    := m1str_crb
    human->POLIS      := make_polis(mspolis,mnpolis) // серия и номер страхового полиса
    human->LPU        := M1LPU         // код учреждения
    human->OTD        := M1OTD         // код отделения
    human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
    human->N_DATA     := MN_DATA       // дата начала лечения
    human->K_DATA     := MK_DATA       // дата окончания лечения
    human->CENA := human->CENA_1 := MCENA_1 // стоимость лечения
    human->ishod      := 200+metap
    human->bolnich    := 0
    human->date_b_1   := ""
    human->date_b_2   := ""
    human_->RODIT_DR  := ctod("")
    human_->RODIT_POL := ""
    s := "" ; aeval(adiag_talon, {|x| s += str(x,1) })
    human_->DISPANS   := s
    human_->STATUS_ST := ""
    //human_->POVOD     := m1povod
    //human_->TRAVMA    := m1travma
    human_->VPOLIS    := m1vidpolis
    human_->SPOLIS    := ltrim(mspolis)
    human_->NPOLIS    := ltrim(mnpolis)
    human_->OKATO     := "" // это поле вернётся из ТФОМС в случае иногороднего
    human_->NOVOR     := 0
    human_->DATE_R2   := ctod("")
    human_->POL2      := ""
    human_->USL_OK    := m1USL_OK
    human_->VIDPOM    := m1VIDPOM
    human_->PROFIL    := m1PROFIL
    human_->IDSP      := iif(metap == 3, 17, 11)
    human_->NPR_MO    := ''
    human_->FORMA14   := '0000'
    human_->KOD_DIAG0 := ''
    human_->RSLT_NEW  := m1rslt
    human_->ISHOD_NEW := m1ishod
    human_->VRACH     := m1vrach
    human_->PRVS      := m1prvs
    human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
    human_->ST_VERIFY := 0 // снова ещё не проверен
    if Loc_kod == 0  // при добавлении
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
      human->kod_p   := kod_polzovat    // код оператора
      human->date_e  := c4sys_date
    else // при редактированиии
      human_->kod_p2  := kod_polzovat    // код оператора
      human_->date_e2 := c4sys_date
    endif
    put_0_human_2()
    Private fl_nameismo := .f.
    if m1komu == 0 .and. m1company == 34
      human_->OKATO := m1okato // ОКАТО субъекта РФ территории страхования
      if empty(m1ismo)
        if !empty(mnameismo)
          fl_nameismo := .t.
        endif
      else
        human_->SMO := m1ismo  // заменяем "34" на код иногородней СМО
      endif
    endif
    if fl_nameismo .or. rec_inogSMO > 0
      G_Use(dir_server+"mo_hismo",,"SN")
      index on str(kod,7) to (cur_dir+"tmp_ismo")
      find (str(mkod,7))
      if found()
        if fl_nameismo
          G_RLock(forever)
          sn->smo_name := mnameismo
        else
          DeleteRec(.t.)
        endif
      else
        if fl_nameismo
          AddRec(7)
          sn->kod := mkod
          sn->smo_name := mnameismo
        endif
      endif
    endif
    i1 := len(arr_usl)
    i2 := len(arr_usl_dop)
    Use_base("human_u")
    for i := 1 to i2
      select HU
      if i > i1
        Add1Rec(7)
        hu->kod := human->kod
      else
        goto (arr_usl[i])
        G_RLock(forever)
      endif
      mrec_hu := hu->(recno())
      hu->kod_vr  := arr_usl_dop[i,1]
      hu->kod_as  := arr_usl_dop[i,3]
      hu->u_koef  := 1
      hu->u_kod   := arr_usl_dop[i,7]
      hu->u_cena  := arr_usl_dop[i,8]
      hu->is_edit := 0
      hu->date_u  := dtoc4(arr_usl_dop[i,9])
      hu->otd     := m1otd
      hu->kol := hu->kol_1 := 1
      hu->stoim := hu->stoim_1 := arr_usl_dop[i,8]
      hu->KOL_RCP := 0
      select HU_
      do while hu_->(lastrec()) < mrec_hu
        APPEND BLANK
      enddo
      goto (mrec_hu)
      G_RLock(forever)
      if i > i1 .or. !valid_GUID(hu_->ID_U)
        hu_->ID_U := mo_guid(3,hu_->(recno()))
      endif
      hu_->PROFIL := arr_usl_dop[i,4]
      hu_->PRVS   := arr_usl_dop[i,2]
      hu_->kod_diag := arr_usl_dop[i,6]
      hu_->zf := ""
      UNLOCK
    next
    if i2 < i1
      for i := i2+1 to i1
        select HU
        goto (arr_usl[i])
        DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
      next
    endif
    save_arr_DVN(mkod)
    write_work_oper(glob_task,OPER_LIST,iif(Loc_kod==0,1,2),1,count_edit)
    fl_write_sluch := .t.
    close databases
    stat_msg("Запись завершена!",.f.)
  endif
  exit
enddo
close databases
setcolor(tmp_color)
restscreen(buf)
chm_help_code := tmp_help
if fl_write_sluch // если записали - запускаем проверку
  if type("fl_edit_DVN") == "L"
    fl_edit_DVN := .t.
  endif
  if !empty(val(msmo))
    verify_OMS_sluch(glob_perso)
  endif
endif
return NIL

*

***** 15.06.13
Function f_valid_diag_oms_sluch_DVN13(get,k)
Local sk := lstr(k)
Private pole_diag := "mdiag"+sk,;
        pole_pervich := "mpervich"+sk,;
        pole_1pervich := "m1pervich"+sk,;
        pole_stadia := "mstadia"+sk,;
        pole_1stadia := "m1stadia"+sk,;
        pole_dispans := "mdispans"+sk,;
        pole_1dispans := "m1dispans"+sk,;
        pole_dop := "mdop"+sk,;
        pole_1dop := "m1dop"+sk,;
        pole_gde := "mgde"+sk,;
        pole_usl := "musl"+sk,;
        pole_1usl := "m1usl"+sk,;
        pole_san := "msan"+sk,;
        pole_1san := "m1san"+sk
if get == NIL .or. !(&pole_diag == get:original)
  if empty(&pole_diag)
    &pole_pervich := space(7)
    &pole_1pervich := 0
    &pole_stadia := space(6)
    &pole_1stadia := 0
    &pole_dispans := space(10)
    &pole_1dispans := 0
    &pole_dop := space(9)
    &pole_1dop := 0
    &pole_usl := space(9)
    &pole_1usl := 0
    &pole_san := space(3)
    &pole_1san := 0
    &pole_gde := space(4)
  else
    &pole_pervich := inieditspr(A__MENUVERT, mm_pervich, &pole_1pervich)
    &pole_stadia := inieditspr(A__MENUVERT, mm_stadia, &pole_1stadia)
    &pole_dispans := inieditspr(A__MENUVERT, mm_dispans, &pole_1dispans)
    &pole_dop := inieditspr(A__MENUVERT, mm_danet, &pole_1dop)
    &pole_san := inieditspr(A__MENUVERT, mm_danet, &pole_1san)
    if &pole_1dop == 0
      &pole_gde := space(4)
      &pole_usl := space(9)
      &pole_1usl := 0
    else
      &pole_gde := "где:"
      &pole_usl := inieditspr(A__MENUVERT, mm_usl, &pole_1usl)
    endif
  endif
endif
update_get(pole_pervich)
update_get(pole_stadia)
update_get(pole_dispans)
update_get(pole_dop)
update_get(pole_gde)
update_get(pole_usl)
update_get(pole_san)
return .t.

***** 13.06.13 рабочая ли услуга ДВН в зависимости от этапа, возраста и пола
Function f_is_usl_oms_sluch_DVN13(i,_etap,_vozrast,_pol,;
                                  /*@*/_diag,/*@*/_otkaz,/*@*/_ekg)
Local fl := .f., ar := dvn_arr_usl13[i]
if valtype(ar[3]) == "N"
  fl := (ar[3] == _etap)
else
  fl := ascan(ar[3],_etap) > 0
endif
_diag := (ar[4] == 1)
_otkaz := 0
if _etap != 2 .and. ar[5] == 1
  _otkaz := 1 // можно ввести отказ
  if valtype(ar[2]) == "C" .and. eq_any(ar[2],"7.57.3","7.61.3","4.20.1")
    _otkaz := 2 // можно ввести невозможность
    if ar[2] == "4.20.1" // Иссл-е взятого цитологического материала
      _otkaz := 3 // заменить на приём фельдшера-акушера
    endif
  endif
endif
if fl .and. len(ar) > 5 .and. _etap == 1
  i := iif(_pol=="М", 6, 7)
  if valtype(ar[i]) == "N"
    fl := (ar[i] != 0)
    if ar[i] < 0  // ЭКГ
      _ekg := (_vozrast < abs(ar[i])) // необязательный возраст
    endif
  else
    fl := ascan(ar[i],_vozrast) > 0
  endif
endif
if fl .and. len(ar) > 7 .and. eq_any(_etap,2,3)
  i := iif(_pol=="М", 8, 9)
  if valtype(ar[i]) == "N"
    fl := (ar[i] != 0)
  else
    fl := between(_vozrast,ar[i,1],ar[i,2])
  endif
endif
return fl

***** 18.06.13 рабочая ли услуга (умолчание) ДВН в зависимости от этапа, возраста и пола
Function f_is_umolch_sluch_DVN13(i,_etap,_vozrast,_pol)
Local fl := .f., ar := dvn_arr_umolch13[i]
if valtype(ar[3]) == "N"
  fl := (ar[3] == _etap)
else
  fl := ascan(ar[3],_etap) > 0
endif
if fl .and. len(ar) > 4 .and. _etap == 1
  i := iif(_pol=="М", 4, 5)
  if valtype(ar[i]) == "N"
    fl := (ar[i] != 0)
  else
    fl := ascan(ar[i],_vozrast) > 0
  endif
endif
if fl .and. len(ar) > 6 .and. _etap == 3
  i := iif(_pol=="М", 6, 7)
  if valtype(ar[i]) == "N"
    fl := (ar[i] != 0)
  else
    fl := between(_vozrast,ar[i,1],ar[i,2])
  endif
endif
return fl

***** 05.06.13 вернуть шифр услуги законченного случая для ДВН
Function ret_shifr_zs_DVN13(_etap,_vozrast,_pol)
Local lshifr := ""
if _etap == 1
  if _pol == "М"
    if _vozrast == 36
      lshifr := "70.3.8"
    elseif _vozrast == 39
      lshifr := "70.3.9"
    elseif _vozrast == 42
      lshifr := "70.3.10"
    elseif _vozrast == 45
      lshifr := "70.3.11"
    elseif _vozrast == 48
      lshifr := "70.3.12"
    elseif eq_any(_vozrast,54,60,66,72,78,84,90,96)
      lshifr := "70.3.13"
    elseif eq_any(_vozrast,51,57,63,69,75,81,87,93,99)
      lshifr := "70.3.14"
    else // 21,24,27,30,33
      lshifr := "70.3.7"
    endif
  else
    if _vozrast == 39
      lshifr := "70.3.2"
    elseif _vozrast == 42
      lshifr := "70.3.3"
    elseif _vozrast == 45
      lshifr := "70.3.4"
    elseif eq_any(_vozrast,48,54,60,66,72,78,84,90,96)
      lshifr := "70.3.5"
    elseif eq_any(_vozrast,51,57,63,69,75,81,87,93,99)
      lshifr := "70.3.6"
    else // 21,24,27,30,33,36
      lshifr := "70.3.1"
    endif
  endif
else // _etap == 3
  if _pol == "М"
    if _vozrast < 45
      lshifr := "72.1.4"
    else
      lshifr := "72.1.5"
    endif
  else
    if _vozrast < 39
      lshifr := "72.1.1"
    elseif _vozrast < 45
      lshifr := "72.1.2"
    else
      lshifr := "72.1.3"
    endif
  endif
endif
return lshifr
