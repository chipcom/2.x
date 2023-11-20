***** mo_omsif.prg - всякие разные статистические формы
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch  := 1
Static f39_nastr := "f39_nast.ini"
Static f39_sect := "Форма 39 - "

*****
Function forma_12(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j, uch_otd
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Распечатка ~формы 12", ;
                "Форма + ~диагнозы", ;
                "С разбивкой по ~отделениям", ;
                "На 100000 ~населения"}
    mas_msg := {"Распечатка формы № 12", ;
                "Распечатка аналога формы 12 с уточнением диагнозов", ;
                "Распечатка аналога формы 12 (статистики по диагнозам) с разбивкой по отд-иям", ;
                "Распечатка аналога формы 12 на 100000 населения"}
    mas_fun := {"forma_12(11)", ;
                "forma_12(12)", ;
                "forma_12(13)", ;
                "forma_12(14)"}
    if ret_is_talon() .and. pi1 == 1 // по дате окончания лечения
      aadd(mas_pmt,"~Редактирование стат.талона")
      aadd(mas_msg,"Редактирование стат.талона")
      aadd(mas_fun,"forma_12(15)")
    endif
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    forma_12_(.f.,.f.)
  case k == 12
    forma_12_(.t.,.f.)
  case k == 13
    forma_12_o()
  case k == 14
    forma_12_(.f.,.t.)
  case k == 15
    edit_bolnich(2)
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

***** 15.01.23
Function forma_12_(is_diag,is_100000)
Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
      s1_, s1, s2, s3, s4, d1, d2, diapazon, kh, hGauge, v, ;
      j1, j2, t_arr1, t_arr2, ls1, ls2, name1, ;
      fl_exit := .f., sh, sh1, HH := 80, reg_print, speriod, ;
      arr_title, name_file, s_lu := 0, tmp_color, adbf, lfp, ;
      md_plus, sd_plus, k_plus, jh := 0, arr_m, yes_god, ;
      file_form, is_talon := .t., bbuf, blk_usl, ab := {}
if is_100000
  name_file := "_form12a"+stxt
else
  name_file := iif(is_diag, "_frm_12d", "_form_12")+stxt
endif
Private adiag_talon[16], arr_v := {{0,14},{0,3},{15,17},{18,999}}, ;
        len_name := {28,28,28,28,28}, kol_dt, koef_dt[5], p_is_voz[5], ;
        GOD_PENSIONEROV   
afill(p_is_voz, .f.)

file_form := dir_exe+"_mo_form"+sdbf
if !hb_FileExists(file_form)
  return func_error(4,"Не обнаружен файл настройки статистических форм _MO_FORM"+sdbf)
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
GOD_PENSIONEROV := arr_m[1]
yes_god := (arr_m[2]==1 .and. arr_m[3]==12)
if (st_a_uchast := ret_uchast(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if is_100000
  kol_dt := {10000,3000,5000,15000,7000}
  tmp_color := setcolor(cDataCGet)
  buf := box_shadow(14,2,22,77,color1,"Введите количество обслуживаемого населения",color8)
  @ 16,10 say padl("Дети (до 14 лет)",40) get kol_dt[1] pict "999999"
  @ 17,10 say padl("Дети первых трех лет жизни",40) get kol_dt[2] pict "999999"
  @ 18,10 say padl("Дети (15-17 лет)",40) get kol_dt[3] pict "999999"
  @ 19,10 say padl("Взрослые (старше 18 лет)",40) get kol_dt[4] pict "999999"
  @ 20,10 say padl("Взрослые старше трудоспособного возраста",40) get kol_dt[5] pict "999999"
  myread()
  rest_box(buf)
  if lastkey() == K_ESC
    return NIL
  endif
  for i := 1 to len(kol_dt)
    koef_dt[i] := iif(kol_dt[i] > 0, 100000/kol_dt[i], 0)
  next
endif
Private fl_12_selo := (f_alert({'Каким образом распечатывать форму 12 ?', ;
                                ''}, ;
                               {" Итого "," По сельскому населению "}, ;
                               1,"GR+/R","W+/R",18,,"GR+/R,N/BG") == 2)
buf := save_maxrow()
Private fl_plus := .f.
if !empty(yes_d_plus)
  fl_plus := .t. ; md_plus := array(len(yes_d_plus))
  k_plus := len(md_plus)
  afill(md_plus," ")
  aeval(md_plus, {|x,i| md_plus[i] := substr(yes_d_plus,i,1) } )
  sd_plus := array(k_plus)
  afill(sd_plus,0)
endif
speriod := arr_m[4]
//
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
Private yes_rule := read_rule(D_RULE_N_F12)
//
adbf := {{"stroke","C",8,0}, ;
         {"table","N",4,0}, ;
         {"tip","N",1,0}, ;
         {"voz","N",1,0}, ;   // 1 - 5
         {"sluch","N",7,0}, ;
         {"sluch5","N",7,0}, ;
         {"sluch6","N",7,0}, ;
         {"sluch7","N",7,0}, ;
         {"sluch8","N",7,0}, ;
         {"sluch9","N",7,0}, ;
         {"sluch10","N",7,0}, ;
         {"sluch11","N",7,0}, ;
         {"sluch12","N",7,0}, ;
         {"sluch13","N",7,0}, ;
         {"sluch14","N",7,0}, ;
         {"sluch15","N",7,0}, ;
         {"sluch16","N",7,0}, ;
         {"sluch17","N",7,0}, ;
         {"sluch18","N",7,0}, ;
         {"sluch19","N",7,0}, ;
         {"sluch20","N",7,0}, ;
         {"sluch21","N",7,0}, ;
         {"sluch22","N",7,0}, ;
         {"sluch23","N",7,0}, ;
         {"sluch24","N",7,0}, ;
         {"sluch25","N",7,0}, ;
         {"pervich","N",7,0}, ;
         {"dispans1","N",7,0}, ;
         {"dispans","N",7,0}, ;
         {"i_sluch","N",7,0}, ;
         {"i_pervich","N",7,0}, ;
         {"i_dispans","N",7,0}}
//
dbcreate(cur_dir+"tmp_tab",adbf)
use (cur_dir+"tmp_tab") new alias TMP_TAB
index on stroke+str(tip,1)+str(voz,1) to (cur_dir+"tmp_tab")
//
dbcreate(cur_dir+"tmp_kart",{{"kod_k","N",7,0}, ;
                             {"voz","N",1,0}, ;   // 1 - 5
                             {"let","N",2,0}, ;
                             {"perv","N",1,0}, ;
                             {"disp1","N",1,0}, ;
                             {"disp","N",1,0}})
use (cur_dir+"tmp_kart") new
index on str(kod_k,7) to (cur_dir+"tmp_kart")
//
Private diag1 := {{},{},{},{},{}}, len_diag[5], p_tip := 1, x := 0
use (file_form) new alias TMP
set filter to forma == 12
go top
do while !eof()
  UpdateStatus()
  if tmp->table == 1000
    x := 1
  elseif tmp->table == 1500
    x := 2
  elseif tmp->table == 2000
    x := 3
  elseif tmp->table == 3000
    x := 4
  elseif tmp->table == 4000
    x := 5
  endif
  s1 := alltrim(tmp->stroke)     // номер строки
  if iif(is_diag, (right(s1,2) == ".0"), .t.)
    s2 := alltrim(tmp->diagnoz)  // диагнозы
    k := st_nom_stroke(s1)
    s4 := k+iif(tmp->bold==1,"<b>","")+alltrim(tmp->name)+iif(tmp->bold==1,"</b>","")     // наименование
    diapazon := {}
    for i := 1 to numtoken(s2,", ;")
      s3 := token(s2,", ;",i)
      if "-" $ s3
        d1 := token(s3,"-",1)
        d2 := token(s3,"-",2)
      else
        d1 := d2 := s3
      endif
      aadd(diapazon, {diag_to_num(d1,1),diag_to_num(d2,2)} )
    next
    p_tip := 1
    if eq_any(substr(lstr(tmp->table),2,1),"1","6")
      p_tip := 2
    endif
    select TMP_TAB
    append blank
    tmp_tab->stroke := s1
    tmp_tab->tip    := p_tip
    tmp_tab->voz    := x
    tmp_tab->table  := tmp->table
    aadd(diag1[x], {s1,p_tip,diapazon,tmp->table,s2,s4})
  endif
  select TMP
  skip
enddo
tmp->(dbCloseArea())
//
for i := 1 to 5
  len_diag[i] := len(diag1[i])
next
if is_diag
  aadd(adbf,{"diagnoz","C",5,0})
  dbcreate(cur_dir+"tmp_dia",adbf)
  use (cur_dir+"tmp_dia") new alias TMP_D
  index on str(voz,1)+diagnoz to (cur_dir+"tmp_dia")
endif
delFRfiles()
adbf := {{"name","C",255,0}, ;
         {"adres","C",255,0}, ;
         {"name1","C",255,0}, ;
         {"v1001_1","N",6,0}, ;
         {"v1001_2","N",6,0}, ;
         {"v1001_3","N",6,0}, ;
         {"v1002_1","N",6,0}, ;
         {"v1002_2","N",6,0}, ;
         {"v1650_1","N",6,0}, ;
         {"v1700_1","N",6,0}, ;
         {"v1800_1","N",6,0}, ;
         {"v1800_2","N",6,0}, ;
         {"v1800_3","N",6,0}, ;
         {"v1800_4","N",6,0}, ;
         {"v1900_5","N",6,0}, ;
         {"v1900_6","N",6,0}, ;
         {"v1900_7","N",6,0}, ;
         {"v1900_8","N",6,0}, ;
         {"v1900_9","N",6,0}, ;
         {"v2001_1","N",6,0}, ;
         {"v2001_2","N",6,0}, ;
         {"v2001_3","N",6,0}, ;
         {"v2001_4","N",6,0}, ;
         {"v3002_1","N",6,0}, ;
         {"v3002_2","N",6,0}, ;
         {"v3002_3","N",6,0}, ;
         {"v4001_1","N",6,0}, ;
         {"v4001_2","N",6,0}, ;
         {"v4001_3","N",6,0}, ;
         {"v5000_1","N",6,0}, ;
         {"v5000_2","N",6,0}, ;
         {"v5000_3","N",6,0}, ;
         {"v5000_4","N",6,0}, ;
         {"v5100_1","N",6,0}, ;
         {"v5100_2","N",6,0}, ;
         {"period","C",100,0}}
dbcreate(fr_titl, adbf)
use (fr_titl) new alias FRT
append blank

//
//
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
R_Use(dir_server+"human_2",,"HUMAN_2")
kh := 0
adbf := NIL
if yes_rule  // "исправляем" в соответствии с правилами статистики
  bbuf := save_maxrow()
  mywait("Ждите. Создаётся условный индексный файл...")
  if pi1 == 1 // по дате окончания лечения
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    set relation to recno() into HUMAN_, to recno() into HUMAN_2
    dbseek(dtos(arr_m[5]),.t.)
    index on str(kod_k,7)+dtos(k_data) to (cur_dir+"tmp_h") ;
          while k_data <= arr_m[6] ;
          for kod > 0 .and. human_->usl_ok == 3 .and. human_->oplata < 9 ;
                      .and. human_->NOVOR == 0 .and. func_pi_schet()
  else
    R_Use(dir_server+"schet",,"SCHET")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",,"HUMAN")
    set relation to schet into SCHET, to recno() into HUMAN_, to recno() into HUMAN_2
    index on str(kod_k,7)+dtos(k_data) to (cur_dir+"tmp_h") ;
          for kod > 0 .and. schet > 0 .and. human_->usl_ok == 3 .and. human_->oplata < 9 ;
                      .and. human_->NOVOR == 0 .and. between(schet->pdate,arr_m[7],arr_m[8]) ;
          progress
  endif
  rest_box(bbuf)
  hGauge := GaugeNew(,,,"Попытка исправления в соответствии с правилами",.t.)
  GaugeDisplay( hGauge )
  if fl_12_selo
    blk_usl := {|| f_is_selo(kart_->gorod_selo,kart_->okatog) .and. ;
                   f_is_uch(st_a_uch,human->lpu) .and. ;
                   f_is_uchast(st_a_uchast,kart->uchast) }
  else
    blk_usl := {|| f_is_uch(st_a_uch,human->lpu) .and. ;
                   f_is_uchast(st_a_uchast,kart->uchast) }
  endif
  select KART
  go top
  do while !eof()
    UpdateStatus()
    GaugeUpdate( hGauge, recno()/lastrec() )
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if f1_prover_rule(blk_usl,ab,12)
      @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
      if jh > 0
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jh) color cColorStMsg
      endif
      verify12rule(ab,kart->pol,yes_god)
      jh := f2_f12(jh,is_diag)
    endif
    select KART
    if recno() % 5000 == 0
      Commit
    endif
    skip
  enddo
  CloseGauge(hGauge)
else  // не "исправляем" в соответствии с правилами статистики
  if pi1 == 1 // по дате окончания лечения
    begin_date := arr_m[5]
    end_date := arr_m[6]
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",{dir_server+"humand", ;
                              dir_server+"humank"},"HUMAN")
    set relation to kod_k into KART, to recno() into HUMAN_, to recno() into HUMAN_2
    dbseek(dtos(begin_date),.t.)
    do while human->k_data <= end_date .and. !eof()
      @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
      if jh > 0
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jh) color cColorStMsg
      endif

      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if human_->usl_ok == 3 .and. human_->oplata < 9 .and. ;
         iif(fl_12_selo, f_is_selo(kart_->gorod_selo,kart_->okatog), .t.) .and. ;
         func_pi_schet() .and. f_is_uch(st_a_uch,human->lpu) .and. f_is_uchast(st_a_uchast,kart->uchast)
        date_24(human->k_data)
        jh := f1_f12(jh,is_diag)
      endif
      select HUMAN
      skip
    enddo
  else
    begin_date := arr_m[7]
    end_date := arr_m[8]
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",{dir_server+"humans", ;
                              dir_server+"humank"},"HUMAN")
    set relation to kod_k into KART, to recno() into HUMAN_, to recno() into HUMAN_2
    R_Use(dir_server+"schet_",,"SCHET_")
    R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
    set relation to recno() into SCHET_
    set filter to empty(schet_->IS_DOPLATA)
    dbseek(begin_date,.t.)
    do while schet->pdate <= end_date .and. !eof()
      date_24(c4tod(schet->pdate))
      select HUMAN
      find (str(schet->kod,6))
      do while human->schet == schet->kod .and. !eof()
        @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
        if human_->usl_ok == 3 .and. human_->oplata < 9 .and. ;
           iif(fl_12_selo, f_is_selo(kart_->gorod_selo,kart_->okatog), .t.) .and. ;
           f_is_uch(st_a_uch,human->lpu) .and. f_is_uchast(st_a_uchast,kart->uchast)
          if jh > 0
            @ row(),col() say "/" color "W/R"
            @ row(),col() say lstr(jh) color cColorStMsg
          endif
          UpdateStatus()
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          jh := f1_f12(jh,is_diag)
        endif
        select HUMAN
        skip
      enddo
      select SCHET
      skip
    enddo
  endif
endif
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
//
mywait()
reg_print := 6
x := 1
if is_100000
  arr_title := f12_100000_title()
else
  arr_title := f12_title()
endif
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(alltrim(org->name))
add_string(alltrim(org->adres))
add_string(padl("Форма № 12",sh))
add_string(padl("Утверждена",sh))
add_string(padl("Приказом Росстата",sh))
add_string(padl("от 22.11.2019г. № 679",sh))
add_string(center("СВЕДЕНИЯ О ЧИСЛЕ ЗАБОЛЕВАНИЙ, ЗАРЕГИСТРИРОВАННЫХ У ПАЦИЕНТОВ,",sh))
add_string(center("ПРОЖИВАЮЩИХ В РАЙОНЕ ОБСЛУЖИВАНИЯ МЕДИЦИНСКОЙ ОРГАНИЗАЦИИ",sh))
add_string(center(speriod,sh))
add_string(center(iif(fl_12_selo,"(по сельскому населению)",""),sh))
titleN_uch(st_a_uch,sh,lcount_uch)
title_uchast(st_a_uchast,sh)
if pi1 == 1
  add_string(center(str_pi_schet(),sh))
else
  add_string(center("[ по дате выписки счета ]",sh))
endif
add_string()
//
use (fr_titl) new alias FRT
frt->name := alltrim(org->name)
frt->adres := alltrim(org->adres)
frt->period := speriod
if fl_12_selo
  frt->name1 := "(по сельскому населению)"
endif
adbf := {;
  {"name","C",250,0}, ;
  {"stroke","C",10,0}, ;
  {"diagnoz","C",40,0};
 }
for i := 4 to 19
  aadd(adbf, {"kol"+lstr(i),"N",8,0})
next
for i := 0 to 9
  name_f := fr_data+iif(i > 0, lstr(i), "")
  al := "FRD"+iif(i > 0, lstr(i), "")
  dbcreate(cur_dir+name_f,adbf)
  E_Use(cur_dir+name_f,,al)
next
if is_diag
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB10")
  use (cur_dir+"tmp_dia") new alias TMP_D
  index on stroke+str(tip,1)+str(voz,1)+diagnoz to (cur_dir+"tmp_dia")
endif
use (cur_dir+"tmp_tab") index (cur_dir+"tmp_tab") new alias TMP
for x := 1 to 5 // diag1[x] => {s1,p_tip,diapazon,tmp->table,s2,s4}
  if !p_is_voz[x] ; loop ; endif
  if is_100000
    arr_title := f12_100000_title()
  else
    arr_title := f12_title()
  endif
  sh := sh1 := len(arr_title[1])
  name1 := {"Дети (0-14 лет включительно)", ;
            "Дети первых трех лет жизни", ;
            "Дети (15-17 лет включительно)", ;
            "Взрослые 18 лет и более", ;
            "Взрослые старше трудоспособного возраста (с 55 лет у женщин и с 60 лет у мужчин)"}[x]
  if x > 1
    add_string(chr(12)) ; tek_stroke := 0 ; n_list++
    next_list(sh)
  endif
  add_string(center(lstr(x)+". "+name1,sh))
  add_string(" ("+lstr(diag1[x,1,4])+")"+padl("Код по ОКЕИ: человек - 792",sh-8))
  aeval(arr_title, {|x| add_string(x) } )
  v := x
  al := "FRD"+iif(x > 1, lstr(int(x*2-2)), "")
  //diag1[x] => {s1,p_tip,diapazon,tmp->table,s2,s4}
  for ix := 1 to len(diag1[x])
    s1 := padr(diag1[x,ix,1],8) ; s1_ := diag1[x,ix,1]
    p_tip := diag1[x,ix,2]
    if p_tip == 2 .and. v == x
      v := 0
      if !is_100000
        if is_diag
          add_string(replicate("-",sh1))
        else
          f_bot_f12(x,HH,sh)
        endif
        asize(arr_title,6)
        arr_title[1] := left(arr_title[1],len_name[x]+22) + "┬───────────────────"
        arr_title[2] := left(arr_title[2],len_name[x]+22) + "│     Обращения     "
        arr_title[3] := left(arr_title[3],len_name[x]+22) + "├─────────┬─────────"
        arr_title[4] := left(arr_title[4],len_name[x]+22) + "│         │ из них  "
        arr_title[5] := left(arr_title[5],len_name[x]+22) + "│  всего  │повторные"
        arr_title[6] := left(arr_title[6],len_name[x]+22) + "┴─────────┴─────────"
        sh1 := len(arr_title[1])
        if !verify_FF(HH-13,.t.,sh)
          add_string("")
        endif
        add_string(center(name1,sh1))
        add_string(center("Факторы, влияющие на состояние здоровья населения и обращения",sh1))
        add_string(center("в медиицнские организации (с профилактической и иными целями)",sh1))
        add_string("")
        add_string(" ("+lstr(diag1[x,ix,4])+")"+padl("Код по ОКЕИ: единица - 642",sh1-8))
        aeval(arr_title, {|x| add_string(x) } )
      endif
      al := "FRD"+lstr(int(x*2-1))
      --ix
    elseif iif(is_diag, (right(s1_,2) == ".0"), .t.)
      if is_100000 .and. p_tip == 2
        ft_skip()
        loop
      endif
      s2 := diag1[x,ix,5] // строка диагнозов
      s3 := diag1[x,ix,6] // наименование
      select TMP
      find (s1+str(p_tip,1)+str(x,1))
      if found() .and. iif(is_diag, (tmp->sluch + tmp->dispans > 0), .t.)
        t_arr1 := {} ; t_arr2 := array(12)
        j1 := perenos(t_arr1,charrepl(eos,s3,"  "),len_name[x])
        j2 := perenos(t_arr2,s2,12,", ;")
        for i := j1+1 to j2
          ++j1 ; aadd(t_arr1,"")
        next
        select TMP
        find (s1+str(p_tip,1)+str(x,1))
        ls1 := padr(t_arr1[1],len_name[x])+;
               padc(alltrim(s1),10)+;
               padc(alltrim(t_arr2[1]),12)
        dbSelectArea(al)
        append blank
        &al.->name := s3
        &al.->stroke := s1
        &al.->diagnoz := s2
        if is_100000
          ls1 += put_val(tmp->sluch,7)+;
                 put_val(tmp->sluch7,7)
          ls1 += put_val(tmp->sluch*koef_dt[x],7)+;
                 put_val(tmp->sluch7*koef_dt[x],7)
          if !emptyany(tmp->sluch7,tmp->sluch)
            ls1 += umest_val(tmp->sluch7/tmp->sluch*100,7,2)
          endif
        else
          k15 := tmp->sluch6 - tmp->sluch12
          if (k16 := tmp->sluch14) > k15
            k16 := k15
            if tmp->sluch > tmp->sluch5 .and. k16 > 0
              --k16
            endif
          endif
          if p_tip == 2
            &al.->kol4  := tmp->sluch
            &al.->kol5  := tmp->sluch5
            ls1 += put_val(tmp->sluch,8)
          elseif x == 1
            &al.->kol4  := tmp->sluch
            &al.->kol5  := tmp->sluch11
            &al.->kol6  := tmp->sluch14
            &al.->kol8  := tmp->sluch6
            &al.->kol9  := tmp->sluch7
            &al.->kol10 := tmp->sluch8
            &al.->kol11 := tmp->sluch9
            &al.->kol14 := tmp->sluch12
            &al.->kol15 := k15
            ls1 += put_val(tmp->sluch,8)+;
                   put_val(tmp->sluch11,7)+;
                   put_val(tmp->sluch14,7)+;
                   put_val(tmp->sluch6,7)+;
                   put_val(tmp->sluch7,7)+;
                   put_val(tmp->sluch8,7)+;
                   put_val(tmp->sluch9,7)+;
                   put_val(tmp->sluch12,6)+;
                   put_val(k15,6)
          elseif x == 2
            &al.->kol4  := tmp->sluch
            &al.->kol5  := tmp->sluch24
            &al.->kol6  := tmp->sluch25
            &al.->kol7  := tmp->sluch5
            &al.->kol8  := tmp->sluch6
            &al.->kol9  := tmp->sluch16
            &al.->kol10 := tmp->sluch7
            &al.->kol11 := tmp->sluch17
            &al.->kol12 := tmp->sluch8
            &al.->kol13 := tmp->sluch18
            &al.->kol14 := tmp->sluch9
            &al.->kol15 := tmp->sluch19
            &al.->kol16 := tmp->sluch12
            &al.->kol17 := tmp->sluch22
            &al.->kol18 := tmp->sluch6 - tmp->sluch12
            &al.->kol19 := tmp->sluch16 - tmp->sluch22
            ls1 += put_val(tmp->sluch,8)+;
                   put_val(tmp->sluch5,7)+;
                   put_val(tmp->sluch6,7)+;
                   put_val(tmp->sluch7,7)+;
                   put_val(tmp->sluch8,7)+;
                   put_val(tmp->sluch9,7)+;
                   put_val(tmp->sluch12,6)+;
                   put_val(k15,6)
          elseif x == 3
            &al.->kol4  := tmp->sluch
            &al.->kol7  := tmp->sluch5
            &al.->kol8  := tmp->sluch6
            &al.->kol9  := tmp->sluch7
            &al.->kol10 := tmp->sluch8
            &al.->kol11 := tmp->sluch9
            &al.->kol12 := tmp->sluch10
            &al.->kol13 := tmp->sluch11
            &al.->kol14 := tmp->sluch12
            &al.->kol15 := k15
            &al.->kol16 := k16
            ls1 += put_val(tmp->sluch,6)+;
                   put_val(tmp->sluch5,6)+;
                   put_val(tmp->sluch6,5)+;
                   put_val(tmp->sluch7,5)+;
                   put_val(tmp->sluch8,5)+;
                   put_val(tmp->sluch9,5)+;
                   put_val(tmp->sluch10,3)+;
                   put_val(tmp->sluch11,5)+;
                   put_val(tmp->sluch12,5)+;
                   put_val(k15,5)+;
                   put_val(k16,5)
          else
            &al.->kol4  := tmp->sluch
            &al.->kol8  := tmp->sluch6
            &al.->kol9  := tmp->sluch7
            &al.->kol10 := tmp->sluch8
            &al.->kol11 := tmp->sluch9
            &al.->kol12 := tmp->sluch10
            &al.->kol14 := tmp->sluch12
            &al.->kol15 := k15
            ls1 += put_val(tmp->sluch,8)+;
                   put_val(tmp->sluch6,7)+;
                   put_val(tmp->sluch7,7)+;
                   put_val(tmp->sluch8,7)+;
                   put_val(tmp->sluch9,7)+;
                   put_val(tmp->sluch10,7)+;
                   put_val(tmp->sluch12,6)+;
                   put_val(k15,6)
          endif
        endif
        if verify_FF(HH-max(j1,j2),.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        if is_diag .and. !(s1_ == "1.0")
          add_string(replicate("-",sh1))
        endif
        add_string(ls1)
        for i := 2 to max(j1,j2)
          ls2 := padr(t_arr1[i],len_name[x])+;
                 space(10)+;
                 padc(alltrim(t_arr2[i]),12)
          add_string(ls2)
        next
        if iif(is_diag, !(s1_ == "1.0" .and. p_tip == 1), .t.)
          add_string(replicate("-",sh1))
        endif
        if is_diag
          select TMP_D
          find (s1+str(p_tip,1)+str(x,1))
          do while tmp_d->stroke == s1 .and. tmp_d->tip == p_tip .and. tmp_d->voz == x .and. !eof()
            select MKB10
            find (tmp_d->diagnoz)
            s := alltrim(mkb10->name)+" "
            skip
            do while left(mkb10->shifr,5) == tmp_d->diagnoz .and. mkb10->ks > 0 .and. !eof()
              s += alltrim(mkb10->name)+" "
              skip
            enddo
            j1 := perenos(t_arr1,s,len_name[x]+10)
            if verify_FF(HH-j1,.t.,sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            dbSelectArea(al)
            append blank
            &al.->name := s
            &al.->diagnoz := tmp_d->diagnoz
            ls1 := padr(t_arr1[1],len_name[x]+10)+;
                   padc(alltrim(tmp_d->diagnoz),12)
            k15 := tmp_d->sluch6 - tmp_d->sluch12
            if (k16 := tmp_d->sluch14) > k15
              k16 := k15
              if tmp_d->sluch > tmp_d->sluch5 .and. k16 > 0
                --k16
              endif
            endif
            if p_tip == 2
              &al.->kol4  := tmp_d->sluch
              &al.->kol5  := tmp_d->sluch5
              ls1 += put_val(tmp_d->sluch,8)
            elseif x == 1
              &al.->kol4  := tmp_d->sluch
              &al.->kol5  := tmp_d->sluch11
              &al.->kol6  := tmp_d->sluch14
              &al.->kol8  := tmp_d->sluch6
              &al.->kol9  := tmp_d->sluch7
              &al.->kol10 := tmp_d->sluch8
              &al.->kol11 := tmp_d->sluch9
              &al.->kol14 := tmp_d->sluch12
              &al.->kol15 := k15
              ls1 += put_val(tmp_d->sluch,8)+;
                     put_val(tmp_d->sluch11,7)+;
                     put_val(tmp_d->sluch14,7)+;
                     put_val(tmp_d->sluch6,7)+;
                     put_val(tmp_d->sluch7,7)+;
                     put_val(tmp_d->sluch8,7)+;
                     put_val(tmp_d->sluch9,7)+;
                     put_val(tmp_d->sluch12,6)+;
                     put_val(k15,6)
            elseif x == 2
              &al.->kol4  := tmp_d->sluch
              &al.->kol5  := tmp_d->sluch24
              &al.->kol6  := tmp_d->sluch25
              &al.->kol7  := tmp_d->sluch5
              &al.->kol8  := tmp_d->sluch6
              &al.->kol9  := tmp_d->sluch16
              &al.->kol10 := tmp_d->sluch7
              &al.->kol11 := tmp_d->sluch17
              &al.->kol12 := tmp_d->sluch8
              &al.->kol13 := tmp_d->sluch18
              &al.->kol14 := tmp_d->sluch9
              &al.->kol15 := tmp_d->sluch19
              &al.->kol16 := tmp_d->sluch12
              &al.->kol17 := tmp_d->sluch22
              &al.->kol18 := tmp_d->sluch6 - tmp_d->sluch12
              &al.->kol19 := tmp_d->sluch16 - tmp_d->sluch22
              ls1 += put_val(tmp_d->sluch,8)+;
                     put_val(tmp_d->sluch5,7)+;
                     put_val(tmp_d->sluch6,7)+;
                     put_val(tmp_d->sluch7,7)+;
                     put_val(tmp_d->sluch8,7)+;
                     put_val(tmp_d->sluch9,7)+;
                     put_val(tmp_d->sluch12,6)+;
                     put_val(k15,6)
            elseif x == 3
              &al.->kol4  := tmp_d->sluch
              &al.->kol7  := tmp_d->sluch5
              &al.->kol8  := tmp_d->sluch6
              &al.->kol9  := tmp_d->sluch7
              &al.->kol10 := tmp_d->sluch8
              &al.->kol11 := tmp_d->sluch9
              &al.->kol12 := tmp_d->sluch10
              &al.->kol13 := tmp_d->sluch11
              &al.->kol14 := tmp_d->sluch12
              &al.->kol15 := k15
              &al.->kol16 := k16
              ls1 += put_val(tmp_d->sluch,6)+;
                     put_val(tmp_d->sluch5,6)+;
                     put_val(tmp_d->sluch6,5)+;
                     put_val(tmp_d->sluch7,5)+;
                     put_val(tmp_d->sluch8,5)+;
                     put_val(tmp_d->sluch9,5)+;
                     put_val(tmp_d->sluch10,3)+;
                     put_val(tmp_d->sluch11,5)+;
                     put_val(tmp_d->sluch12,5)+;
                     put_val(k15,5)+;
                     put_val(k16,5)
            else
              &al.->kol4  := tmp_d->sluch
              &al.->kol8  := tmp_d->sluch6
              &al.->kol9  := tmp_d->sluch7
              &al.->kol10 := tmp_d->sluch8
              &al.->kol11 := tmp_d->sluch9
              &al.->kol12 := tmp_d->sluch10
              &al.->kol14 := tmp_d->sluch12
              &al.->kol15 := k15
              ls1 += put_val(tmp_d->sluch,8)+;
                     put_val(tmp_d->sluch6,7)+;
                     put_val(tmp_d->sluch7,7)+;
                     put_val(tmp_d->sluch8,7)+;
                     put_val(tmp_d->sluch9,7)+;
                     put_val(tmp_d->sluch10,7)+;
                     put_val(tmp_d->sluch12,6)+;
                     put_val(k15,6)
            endif
            add_string(ls1)
            for i := 2 to j1
              add_string(padl(alltrim(t_arr1[i]),len_name[x]+10))
            next
            select TMP_D
            skip
          enddo
        endif
      endif
    endif
  next
next
fclose(fp)
close databases
rest_box(buf)
if is_100000
  viewtext(name_file,,,,.t.,,,reg_print)
else
  call_fr("mo_forma12")
endif
return NIL

***** 11.12.16
Function f_bot_f12(x,HH,sh)
Local v1 := 0, v2 := 0, v3 := 0, v4 := 0, v5 := 0, v6 := 0
use (cur_dir+"TMP_KART") new
if x == 1
  index on str(kod_k,7) to (cur_dir+"tmp_kart") for voz < 3 // т.к. дети и новорожденные считались отдельно
elseif x == 4
  index on str(kod_k,7) to (cur_dir+"tmp_kart") for voz > 3 // т.к. взрослые и пенсионеры считались отдельно
else
  index on str(kod_k,7) to (cur_dir+"tmp_kart") for voz == x
endif
go top
do while !eof()
  ++v1
  if perv > 0
    ++v2
  endif
  if disp > 0
    ++v3
    if let < 5
      ++v5
    elseif let < 10
      ++v6
    elseif let == 18
      ++v4
    endif
  endif
  skip
enddo
use
verify_FF(HH-3,.t.,sh)
add_string("("+lstr(diag1[x,1,4]+1)+") Число физических лиц зарегистрированных пациентов - всего 1(___"+lstr(v1)+"___),")
add_string(space(7)+"из них с диагнозом, установленным впервые в жизни 2(___"+lstr(v2)+"___),")
add_string(space(7)+"состоит под диспансерным наблюдением на конец отчетного года (из гр.13, стр.1.0) 3(___"+lstr(v3)+"___).")
do case
  case x == 1
    frt->v1001_1 := v1
    frt->v1001_2 := v2
    frt->v1001_3 := v3
    frt->v1002_1 := v5
    frt->v1002_2 := v6
  case x == 2
    frt->v1700_1 := v1
  case x == 3
    frt->v2001_1 := v1
    frt->v2001_2 := v2
    frt->v2001_3 := v3
    frt->v2001_4 := v4
  case x == 4
    frt->v3002_1 := v1
    frt->v3002_2 := v2
    frt->v3002_3 := v3
  case x == 5
    frt->v4001_1 := v1
    frt->v4001_2 := v2
    frt->v4001_3 := v3
endcase
return NIL

***** 03.01.16
Function f12_title()
Local arr := array(8)
arr[1] := replicate("─",len_name[x])
arr[2] := padc("",len_name[x])
arr[3] := padc("Наименование классов и",len_name[x])
arr[4] := padc("отдельных болезней",len_name[x])
arr[5] := padc("",len_name[x])
arr[6] := replicate("─",len_name[x])
arr[7] := padc("1",len_name[x])
arr[8] := replicate("─",len_name[x])
arr[1] := arr[1] + "┬────────┬────────────"
arr[2] := arr[2] + "│        │   Код по   "
arr[3] := arr[3] + "│   №    │   МКБ-10   "
arr[4] := arr[4] + "│ строки │ пересмотра "
arr[5] := arr[5] + "│        │            "
arr[6] := arr[6] + "┼────────┼────────────"
arr[7] := arr[7] + "│   2    │     3      "
arr[8] := arr[8] + "┴────────┴────────────"
if x == 1
  arr[1] := arr[1] + "┬─────────────────────────────────────────────────┬─────┬─────"
  arr[2] := arr[2] + "│          Зарегистрировано заболеваний           │Снято│Состо"
  arr[3] := arr[3] + "├───────┬──────┬──────┬─из графы 4──┬──из графы 7─┤сДисп│итПод"
  arr[4] := arr[4] + "│ всего │  0-4 │  5-9 │взято │впервы│взято │Проф. │наблю│Дисп."
  arr[5] := arr[5] + "│       │ года │  лет │наДисп│Диагно│наДисп│осмотр│дения│набл."
  arr[6] := arr[6] + "┼───────┼──────┼──────┼──────┼──────┼──────┼──────┼─────┼─────"
  arr[7] := arr[7] + "│   4   │   5  │   6  │  8   │  9   │  10  │  11  │ 14  │ 15  "
  arr[8] := arr[8] + "┴───────┴──────┴──────┴──────┴──────┴──────┴──────┴─────┴─────"
elseif x == 2
  arr[1] := arr[1] + "┬──────────────────────────────────────────┬─────┬─────"
  arr[2] := arr[2] + "│       Зарегистрировано заболеваний       │Снято│Состо"
  arr[3] := arr[3] + "├───────┬──────┬─из графы 4──┬──из графы 7─┤сДисп│итПод"
  arr[4] := arr[4] + "│ всего │до 1  │взято │впервы│взято │Проф. │наблю│Дисп."
  arr[5] := arr[5] + "│       │месяца│наДисп│Диагно│наДисп│осмотр│дения│набл."
  arr[6] := arr[6] + "┼───────┼──────┼──────┼──────┼──────┼──────┼─────┼─────"
  arr[7] := arr[7] + "│   4   │  5   │  8   │  9   │  10  │  11  │ 14  │ 15  "
  arr[8] := arr[8] + "┴───────┴──────┴──────┴──────┴──────┴──────┴─────┴─────"
elseif x == 3
  arr[1] := arr[1] + "┬───────────────────────────────────────┬────┬────┬────"
  arr[2] := arr[2] + "│     Зарегистрировано заболеваний      │Снят│Сост│Из  "
  arr[3] := arr[3] + "├─────┬─────┬─из гр.4─┬─из графы 7─┬────┤сДис│оит │граф"
  arr[4] := arr[4] + "│всего│изНих│взят│впер│на  │Проф│Ди│изГ8│набл│подД│ 13 "
  arr[5] := arr[5] + "│     │юноши│наДи│вые │Дисп│осмо│Вз│юнош│юден│набл│юнош"
  arr[6] := arr[6] + "┼─────┼─────┼────┼────┼────┼────┼──┼────┼────┼────┼────"
  arr[7] := arr[7] + "│  4  │  7  │  8 │  9 │ 10 │ 11 │12│ 13 │ 14 │ 15 │ 16 "
  arr[8] := arr[8] + "┴─────┴─────┴────┴────┴────┴────┴──┴────┴────┴────┴────"
else
  arr[1] := arr[1] + "┬──────────────────────────────────────────┬─────┬─────"
  arr[2] := arr[2] + "│        Зарегистрировано заболеваний      │Снято│Состо"
  arr[3] := arr[3] + "├───────┬─из графы 4──┬─────из графы 7─────┤сДисп│итПод"
  arr[4] := arr[4] + "│ всего │взято │впервы│взято │Проф. │Диспан│наблю│Дисп."
  arr[5] := arr[5] + "│       │наДисп│Диагно│наДисп│осмотр│ВзрНас│дения│набл."
  arr[6] := arr[6] + "┼───────┼──────┼──────┼──────┼──────┼──────┼─────┼─────"
  arr[7] := arr[7] + "│   4   │  8   │  9   │  10  │  11  │  12  │ 14  │ 15  "
  arr[8] := arr[8] + "┴───────┴──────┴──────┴──────┴──────┴──────┴─────┴─────"
endif
return arr

*****
Function f12_100000_title()
Local arr := array(6)
arr[1] := replicate("─",len_name[x])
arr[2] := padc("",len_name[x])
arr[3] := padc("Наименование классов и",len_name[x])
arr[4] := padc("отдельных болезней",len_name[x])
arr[5] := padc("",len_name[x])
arr[6] := replicate("─",len_name[x])
arr[1] := arr[1] + '┬────────┬────────────┬─────────────┬─────────────┬──────'
arr[2] := arr[2] + '│        │   Код по   │Зарегистриров│  на 100000  │Часто-'
arr[3] := arr[3] + '│   №    │   МКБ-10   ├──────┬──────┼──────┬──────┤та вы-'
arr[4] := arr[4] + '│ строки │ пересмотра │всего │в т.ч.│всего │в т.ч.│явле- '
arr[5] := arr[5] + '│        │            │      │с "+" │      │с "+" │ния % '
arr[6] := arr[6] + '┴────────┴────────────┴──────┴──────┴──────┴──────┴──────'
return arr

*

***** 13.12.16 возврат массива диагнозов для формы 12 из дисп-ии взрослого населения
Function ret_f12_DVN(Loc_kod,par)
Local rec, rec2 := 0, lkod_k, ldate, lyear, arr := {}, i, j, k, s, is_student, is_1 := .f., is_disp := .f.
rec := human->(recno())
is_student := (human->RAB_NERAB == 2)
if par == 1 .and. human->ishod == 201
  rec := human->(recno())
  lyear := year(human->k_data)
  lkod_k := human->kod_k
  select HUMAN
  set order to 2
  find (str(lkod_k,7))
  do while lkod_k == human->kod_k .and. !eof()
    if human->ishod == 202 .and. lyear == year(human->k_data) .and. human_->oplata < 9
      rec2 := human->(recno()) ; exit
    endif
    skip
  enddo
  set order to 1
  goto (rec)
endif
select HUMAN
if rec2 > 0
  goto (rec2)
endif
Private pole_diag, pole_1pervich, pole_1dispans
for i := 1 to 5
  pole_diag := "mdiag"+lstr(i)
  pole_1pervich := "m1pervich"+lstr(i)
  pole_1dispans := "m1dispans"+lstr(i)
  Private &pole_diag := space(6)
  Private &pole_1pervich := 0
  Private &pole_1dispans := 0
next
read_arr_DVN(human->(recno()))
for i := 1 to 5
  pole_diag := "mdiag"+lstr(i)
  pole_1pervich := "m1pervich"+lstr(i)
  pole_1dispans := "m1dispans"+lstr(i)
  if !empty(&pole_diag) .and. !(left(&pole_diag,1) == "Z")
    if &pole_1pervich < 2 // впервые и ранее выявленный
      if &pole_1pervich == 1 // впервые
        is_1 := .t.
      else // ранее выявленный
        &pole_1pervich := 2
      endif
      if &pole_1dispans == 1
        if &pole_1pervich == 1 // впервые
          is_disp := .t.
          &pole_1dispans := 2
        else // ранее выявленный
          &pole_1dispans := 1
        endif
      endif
      aadd(arr, {&pole_diag,&pole_1pervich,&pole_1dispans})
    endif
  endif
next
if rec2 > 0
  goto (rec)
endif
if is_student .and. select("frt") > 0
  frt->v5000_1 ++
  frt->v5000_2 ++
  if is_1
    frt->v5000_3 ++
    if is_disp
      frt->v5000_4 ++
    endif
  endif
endif
return arr

*

***** 12.12.16 возврат массива диагнозов для формы 12 из профосмотров несовершеннолетних и дисп-ии детей-сирот
Function ret_f12_PN(Loc_kod,par)
Local arr, ad := {}, i, j, k, s, lshifr
for i := 1 to 5
  for k := 1 to 16
    s := "diag_16_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      Private &mvar := space(6)
    else
      m1var := "m1"+s
      Private &m1var := 0
      Private &mvar := space(3)
    endif
  next
next
if par == 1
  read_arr_DDS(Loc_kod)
else
  for i := 1 to count_pn_arr_iss // исследования
    mvar := "MREZi"+lstr(i)
    Private &mvar := space(17)
  next
  read_arr_PN(Loc_kod)
  if select("frt") > 0
    select HU
    find (str(Loc_kod,7))
    do while hu->kod == Loc_kod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
        lshifr := usl->shifr
      endif
      lshifr := alltrim(lshifr)
      for i := 1 to count_pn_arr_iss // исследования
        if np_arr_issled[i,1] == lshifr
          if lshifr == "3.5.4"  // "Аудиологический скрининг"
            frt->v1800_1 ++
            mvar := "MREZi"+lstr(i)
            if !empty(&mvar)
              frt->v1800_2 ++
            endif
          elseif lshifr == "4.26.1" // "Неонатальный скрининг на гипотиреоз"
            frt->v1900_6 ++
          elseif lshifr == "4.26.2" // "Неонатальный скрининг на фенилкетонурию"
            frt->v1900_5 ++
          elseif lshifr == "4.26.3" // "Неонатальный скрининг на адреногенитальный синдром"
            frt->v1900_7 ++
          elseif lshifr == "4.26.4" // "Неонатальный скрининг на муковисцидоз"
            frt->v1900_9 ++
          elseif lshifr == "4.26.5" // "Неонатальный скрининг на галактоземию"
            frt->v1900_8 ++
          endif
        endif
      next
      select HU
      skip
    enddo
  endif
endif
for i := 1 to 5
  j := 0
  for k := 1 to 3
    s := "diag_16_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      if !empty(&mvar) .and. !(left(&mvar,1) == "Z")
        arr := array(3) ; afill(arr,0) ; arr[1] := alltrim(&mvar)
        if len(arr[1]) > 5
          arr[1] := left(arr[1],5)
        endif
        aadd(ad,arr) ; j := len(ad)
      endif
    elseif j > 0
      m1var := "m1"+s
      ad[j,k] := &m1var
    endif
  next
next
arr := {}
for i := 1 to len(ad) // цикл по диагнозам
  aadd(arr, {ad[i,1],iif(ad[i,2]==0,2,1),ad[i,3]})
  // ad[i,2] = 1 - уст.впервые, 2 - повторно
  // ad[i,3] = 1 - состоит, 2 - взят
next
return arr

***** 16.01.20
Function f1_f12(jh,is_diag)
Local arr_d := {}, is_talon := .t., arr := {}, i, j, k, m, k4, k1, s, v, v4 := 0, ;
      mvozrast, fl, fl_plus, _dispans, kol_sluch, kol_plus, fl_z, mpol, lnum_kol := 0
Private spec_vozrast := 0, spec1vozrast := 0, mlet := 0
if human_->NOVOR > 0
  mpol := human_->POL2
  mvozrast := count_years(human_->DATE_R2,human->n_data)
else
  mpol := human->pol
  mvozrast := count_years(human->date_r,human->n_data)
  mlet := year(human->n_data) - year(human->date_r)
endif
if mvozrast < 5
  spec_vozrast := 2
  if mvozrast == 0
    m := 0
    if human_->NOVOR > 0
      count_ymd(human_->DATE_R2,human->n_data,,@m,)
    else
      count_ymd(human->DATE_R,human->n_data,,@m,)
    endif
    if m == 0
      spec_vozrast := 1  // до месяца
    endif
  endif
  if mvozrast < 1
    spec1vozrast := 1
  elseif mvozrast < 4
    spec1vozrast := 2
  endif
elseif mvozrast < 10
  spec_vozrast := 3
endif

v := ret_v_f12(mpol,mvozrast,@v4)

if eq_any(human->ishod,101,102,201,202,203,204,205,301,302)

  if eq_any(human->ishod,101,102)
    arr := ret_f12_PN(human->kod,1)
    lnum_kol := 9 // профосмотр
  elseif eq_any(human->ishod,201,203,204)
    arr := ret_f12_DVN(human->kod,1)
    lnum_kol := iif(human->ishod == 203, 9, 10) // профосмотр или диспансеризация
  elseif eq_any(human->ishod,301,302)
    arr := ret_f12_PN(human->kod,2)
    lnum_kol := 9 // профосмотр
  endif
  if empty(arr) .and. eq_any(human->ishod,202,205)
    aadd(arr, {human->KOD_DIAG,0,0})
  endif
  for i := 1 to len(arr)
    arr[i,1] := padr(arr[i,1],5)
    if !empty(arr[i,1]) .and. ascan(arr_d, arr[i,1]) == 0 .and. (k := ret_f_12(v,arr[i,1])) != NIL
      fl := fl_plus := .f.
      _dispans := arr[i,3]
      if arr[i,2] > 0
        fl := .t.
        fl_plus := (arr[i,2] == 1)
      endif
      fl_z := .f.
      if !fl .and. left(arr[i,1],1) == "Z"
        fl := fl_z := .t.
      endif
      if fl
        kol_sluch := iif(fl, 1, 0)
        kol_plus := iif(fl_plus, 1, 0)
        aadd(arr_d, arr[i,1])
        p_is_voz[v] := .t.
        s_f1_f12(is_diag,arr[i,1],k,v,mpol,kol_sluch,kol_plus,_dispans,lnum_kol)
        if v4 > 0 .and. (k4 := ret_f_12(v4,arr[i,1])) != NIL
          p_is_voz[v4] := .t.
          s_f1_f12(is_diag,arr[i,1],k4,v4,mpol,kol_sluch,kol_plus,_dispans,lnum_kol)
        endif
        if !fl_z
          f12_kod_k(human->kod_k,v,v4,kol_plus,_dispans)
        endif
      endif
    endif
  next
else
  afill(adiag_talon,0)
  for i := 1 to 16
    adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
  next
  arr := {human->KOD_DIAG , ;
          human->KOD_DIAG2, ;
          human->KOD_DIAG3, ;
          human->KOD_DIAG4, ;
          human->SOPUT_B1 , ;
          human->SOPUT_B2 , ;
          human->SOPUT_B3 , ;
          human->SOPUT_B4}
  for i := 1 to len(arr)
    arr[i] := padr(arr[i],5)
    if !empty(arr[i]) .and. ascan(arr_d, arr[i]) == 0 .and. (k := ret_f_12(v,arr[i])) != NIL
      fl := fl_plus := .f. ; _dispans := 0
      s := substr(human->diag_plus,i,1)
      if eq_any(s,"+","-")  // старая форма
        fl := .t.
        fl_plus := (s == "+")
      elseif is_talon
        s := adiag_talon[i*2-1]
        fl := eq_any(s,1,2)
        fl_plus := (s == 1)
      endif
      if is_talon
        k1 := adiag_talon[i*2]
        if between(k1,1,3)
          _dispans := k1
        endif
        if !fl .and. _dispans > 0  // если не определен характер заболевания,
          fl_plus := (_dispans == 2)   // то определяем его принудительно
          fl := .t.
        endif
      endif
      fl_z := .f.
      if !fl .and. left(arr[i],1) == "Z"
        fl := fl_z := .t.
      endif
      if fl
        kol_sluch := iif(fl, 1, 0)
        kol_plus := iif(fl_plus, 1, 0)
        aadd(arr_d, arr[i])
        p_is_voz[v] := .t.
        s_f1_f12(is_diag,arr[i],k,v,mpol,kol_sluch,kol_plus,_dispans)
        if v4 > 0 .and. (k4 := ret_f_12(v4,arr[i])) != NIL
          p_is_voz[v4] := .t.
          s_f1_f12(is_diag,arr[i],k4,v4,mpol,kol_sluch,kol_plus,_dispans)
        endif
        if !fl_z
          f12_kod_k(human->kod_k,v,v4,kol_plus,_dispans)
        endif
      endif
    endif
  next
endif
if len(arr_d) > 0
  ++jh
endif
return jh

***** 14.01.20
Function s_f1_f12(is_diag,lshifr,k,v,lpol,kol_sluch,kol_plus,_dispans,lnom_kol)
Local j, n
Private pole
DEFAULT lnom_kol TO 0
for j := 1 to len(k)
  select TMP_TAB
  find (padr(k[j,1],8)+str(k[j,2],1)+str(v,1))
  tmp_tab->sluch += kol_sluch
  tmp_tab->sluch7 += kol_plus
  if eq_any(_dispans,1,2) // Состоит, Взят
    tmp_tab->sluch6 += kol_sluch
    tmp_tab->sluch13 += kol_sluch
    if kol_plus > 0 .and. _dispans == 2 // Взят
      tmp_tab->sluch8 += kol_plus
    endif
  elseif _dispans == 3 // Снят
    tmp_tab->sluch12 += kol_sluch
  endif
  if kol_plus > 0 .and. eq_any(lnom_kol,9,10)
    pole := "tmp_tab->sluch"+lstr(lnom_kol)
    &pole := &pole + min(1,kol_plus)
  endif
  if v == 1
    if spec_vozrast == 2
      tmp_tab->sluch11 += kol_plus
    elseif spec_vozrast == 3
      tmp_tab->sluch14 += kol_sluch
    endif
  elseif v == 2
    if spec_vozrast == 1 // до 1 месяца
      tmp_tab->sluch5 += kol_sluch
    endif
    if spec1vozrast == 1 // до 1 года
      tmp_tab->sluch24 += kol_sluch
    else
      tmp_tab->sluch25 += kol_sluch
      tmp_tab->sluch7 -= kol_plus
      tmp_tab->sluch17 += kol_plus
      if eq_any(_dispans,1,2) // Состоит, Взят
        tmp_tab->sluch6 -= kol_sluch
        tmp_tab->sluch16 += kol_sluch
        tmp_tab->sluch13 -= kol_sluch
        tmp_tab->sluch23 += kol_sluch
        if kol_plus > 0 .and. _dispans == 2 // Взят
          tmp_tab->sluch8 -= kol_plus
          tmp_tab->sluch18 += kol_plus
        endif
      elseif _dispans == 3 // Снят
        tmp_tab->sluch12 -= kol_sluch
        tmp_tab->sluch22 += kol_sluch
      endif
      if kol_plus > 0 .and. eq_any(lnom_kol,9,10)
        pole := "tmp_tab->sluch"+lstr(lnom_kol)
        &pole := &pole - min(1,kol_plus)
        pole := "tmp_tab->sluch"+lstr(lnom_kol+10)
        &pole := &pole + min(1,kol_plus)
      endif
    endif
  elseif v == 3 .and. upper(lpol) == "М"
    tmp_tab->sluch5 += kol_sluch
    if kol_plus > 0 .and. _dispans == 2 // Взят
      tmp_tab->sluch11 += kol_plus
    endif
    if eq_any(_dispans,1,2) // Состоит, Взят
      tmp_tab->sluch14 += kol_sluch
    endif
  endif
next
if is_diag
  select TMP_D
  find (str(v,1)+padr(lshifr,5))
  if !found()
    append blank
    tmp_d->diagnoz := lshifr
    if (j := ascan(k, {|x| n := alltrim(x[1]), (!(n=="1.0" .and. x[2]==1) .and. right(n,2)==".0")} )) > 0
      tmp_d->stroke := padr(k[j,1],8)
      tmp_d->tip := k[j,2]
    endif
    tmp_d->voz := v
  endif
  tmp_d->sluch += kol_sluch
  tmp_d->sluch7 += kol_plus
  if eq_any(_dispans,1,2) // Состоит, Взят
    tmp_d->sluch6 += kol_sluch
    tmp_d->sluch13 += kol_sluch
    if kol_plus > 0 .and. _dispans == 2 // Взят
      tmp_d->sluch8 += kol_plus
    endif
  elseif _dispans == 3 // Снят
    tmp_d->sluch12 += kol_sluch
  endif
  if kol_plus > 0 .and. eq_any(lnom_kol,9,10)
    pole := "tmp_d->sluch"+lstr(lnom_kol)
    &pole := &pole + min(1,kol_plus)
  endif
  if v == 1
    if spec_vozrast == 2
      tmp_d->sluch11 += kol_plus
    elseif spec_vozrast == 3
      tmp_d->sluch14 += kol_sluch
    endif
  elseif v == 2
    if spec_vozrast == 1
      tmp_d->sluch5 += kol_sluch
    endif
    if spec1vozrast == 1
      tmp_d->sluch24 += kol_sluch
    else
      tmp_d->sluch25 += kol_sluch
      tmp_d->sluch7 -= kol_plus
      tmp_d->sluch17 += kol_plus
      if eq_any(_dispans,1,2) // Состоит, Взят
        tmp_d->sluch6 -= kol_sluch
        tmp_d->sluch16 += kol_sluch
        tmp_d->sluch13 -= kol_sluch
        tmp_d->sluch23 += kol_sluch
        if kol_plus > 0 .and. _dispans == 2 // Взят
          tmp_d->sluch8 -= kol_plus
          tmp_d->sluch18 += kol_plus
        endif
      elseif _dispans == 3 // Снят
        tmp_d->sluch12 -= kol_sluch
        tmp_d->sluch22 += kol_sluch
      endif
      if kol_plus > 0 .and. eq_any(lnom_kol,9,10)
        pole := "tmp_d->sluch"+lstr(lnom_kol)
        &pole := &pole - min(1,kol_plus)
        pole := "tmp_d->sluch"+lstr(lnom_kol+10)
        &pole := &pole + min(1,kol_plus)
      endif
    endif
  elseif v == 3 .and. upper(lpol) == "М"
    tmp_d->sluch5 += kol_sluch
    if kol_plus > 0 .and. _dispans == 2 // Взят
      tmp_d->sluch11 += kol_plus
    endif
    if eq_any(_dispans,1,2) // Состоит, Взят
      tmp_d->sluch14 += kol_sluch
    endif
  endif
endif
return NIL

*

***** 14.01.20
Function f2_f12(jh,is_diag)
Local i, j, k, k4, m, s, v, v4 := 0, mvozrast, mdate, ll, a3 := {}, fl_z, kz, ad := {}, ;
      lshifr, fl, fl_plus, _dispans, ret := .f., kol_sluch, kol_plus, lshifr3, lnum_kol := 0
Private spec_vozrast := 0, spec1vozrast := 0, mlet := 0
select TMP1RULE
find ("1")
do while tmp1rule->tip == 1 .and. !eof()
  kz := lnum_kol := 0
  fl := fl_plus := fl_z := .f. ; _dispans := 0
  lshifr := padr(tmp1rule->shifr,5)
  if left(lshifr,1) == "Z"
    fl := fl_z := .t.
  elseif tmp1rule->kol1 > 0 .or. tmp1rule->kol2 > 0 .or. tmp1rule->dispan > 0
    lshifr3 := left(lshifr,3)
    aadd(a3,lshifr3)
    fl := .t.
    if (fl_plus := (tmp1rule->kol1 > 0))
      lnum_kol := tmp1rule->num_kol
    endif
    if tmp1rule->dispan > 0 .and. ascan(ad,lshifr3) == 0
      aadd(ad,lshifr3)
      _dispans := tmp1rule->dispan
    endif
  endif
  mdate := kart->date_r
  select TMP2RULE
  find (str(tmp1rule->kod,6))
  do while tmp2rule->kod == tmp1rule->kod .and. !eof()
    ++kz
    mdate := max(mdate,tmp2rule->n_data)
    skip
  enddo
  // определяем возраст по дате начала самого последнего лечения
  mvozrast := count_years(kart->date_r, mdate)
  mlet := year(mdate) - year(kart->date_r)
  spec_vozrast := 0
  if mvozrast < 5
    spec_vozrast := 2
    if mvozrast == 0
      count_ymd(kart->date_r, mdate,,@m,)
      if m == 0
        spec_vozrast := 1
      endif
    endif
    if mvozrast < 1
      spec1vozrast := 1
    elseif mvozrast < 4
      spec1vozrast := 2
    endif
  elseif mvozrast < 10
    spec_vozrast := 3
  endif
  v := ret_v_f12(kart->pol,mvozrast,@v4)
  if fl .or. _dispans > 0
    if !empty(lshifr) .and. (k := ret_f_12(v,lshifr)) != NIL
      ret := .t.
      if fl_z
        kol_sluch := kol_plus := kz
      else
        kol_sluch := tmp1rule->kol1 + tmp1rule->kol2
      endif
      kol_plus := tmp1rule->kol1
      p_is_voz[v] := .t.
      s_f1_f12(is_diag,lshifr,k,v,kart->pol,kol_sluch,kol_plus,_dispans,lnum_kol)
      if v4 > 0 .and. (k4 := ret_f_12(v4,lshifr)) != NIL
        p_is_voz[v4] := .t.
        s_f1_f12(is_diag,lshifr,k4,v4,kart->pol,kol_sluch,kol_plus,_dispans,lnum_kol)
      endif
      if !fl_z
        f12_kod_k(kart->kod,v,v4,kol_plus,_dispans)
      endif
    endif
  endif
  select TMP1RULE
  skip
enddo
select TMP1RULE
find ("2")
do while tmp1rule->tip == 2 .and. !eof()
  fl := fl_plus := fl_z := .f. ; dispans := lnum_kol := 0
  lshifr := left(tmp1rule->shifr,3)
  if left(lshifr,1) == "Z"
    fl := fl_z := .t.  // т.к. уже занесли пятизначный шифр
  elseif ascan(a3,lshifr) == 0 .and. (tmp1rule->kol1 > 0 .or. tmp1rule->kol2 > 0)
    aadd(a3,lshifr)
    fl := .t.
    if (fl_plus := (tmp1rule->kol1 > 0))
      lnum_kol := tmp1rule->num_kol
    endif
  endif
  if fl .or. _dispans > 0
    mdate := kart->date_r
    select TMP2RULE
    find (str(tmp1rule->kod,6))
    do while tmp2rule->kod == tmp1rule->kod .and. !eof()
      mdate := max(mdate,tmp2rule->n_data)
      skip
    enddo
    // определяем возраст по дате начала самого последнего лечения
    mvozrast := count_years(kart->date_r, mdate)
    mlet := year(mdate) - year(kart->date_r)
    spec_vozrast := 0
    if mvozrast < 5
      spec_vozrast := 2
      if mvozrast == 0
        count_ymd(kart->date_r, mdate,,@m,)
        if m == 0
          spec_vozrast := 1
        endif
      endif
      if mvozrast < 1
        spec1vozrast := 1
      elseif mvozrast < 4
        spec1vozrast := 2
      endif
    elseif mvozrast < 10
      spec_vozrast := 3
    endif
    v := ret_v_f12(kart->pol,mvozrast,@v4)
    lshifr := padr(lshifr,5)
    if !empty(lshifr) .and. (k := ret_f_12(v,lshifr)) != NIL
      ret := .t.
      kol_sluch := tmp1rule->kol1 + tmp1rule->kol2
      kol_plus := tmp1rule->kol1
      p_is_voz[v] := .t.
      s_f1_f12(is_diag,lshifr,k,v,kart->pol,kol_sluch,kol_plus,_dispans,lnum_kol)
      if v4 > 0 .and. (k4 := ret_f_12(v4,lshifr)) != NIL
        p_is_voz[v4] := .t.
        s_f1_f12(is_diag,lshifr,k4,v4,kart->pol,kol_sluch,kol_plus,_dispans,lnum_kol)
      endif
      if !fl_z
        f12_kod_k(kart->kod,v,v4,kol_plus,_dispans)
      endif
    endif
  endif
  select TMP1RULE
  skip
enddo
if ret
  ++jh
endif
return jh

*****
Function ret_f_12(k,lshifr)
Local ret := {}, i, j, d, r
d := diag_to_num(lshifr,1)
if k == 0
  for i := 1 to len_diag
    r := diag1[i,3]
    for j := 1 to len(r)
      if between(d,r[j,1],r[j,2])
        aadd(ret, {diag1[i,1],diag1[i,2]})
        exit
      endif
    next
  next
else
  for i := 1 to len_diag[k]
    r := diag1[k,i,3]
    for j := 1 to len(r)
      if between(d,r[j,1],r[j,2])
        aadd(ret, {diag1[k,i,1],diag1[k,i,2]})
        exit
      endif
    next
  next
endif
if len(ret) == 0 ; ret := NIL ; endif
return ret

***** 15.01.23
Function ret_v_f12(mpol,mvozrast,/*@*/v4)
Local v
if (v := ascan(arr_v, {|x| between(mvozrast,x[1],x[2]) } )) == 0
  v := 4 // если почему-то не нашли - взрослые
endif
v4 := 0
if v == 1 .and. mvozrast < 4
  v4 := 2 // дети до 3х лет
elseif v == 4 
  if GOD_PENSIONEROV < 2020  
    if ((mpol == "Ж" .and. mvozrast >= 55) .or. (mpol == "М" .and. mvozrast >= 60))
      v4 := 5 // взрослые старше трудоспособного возраста
    endif 
  elseif GOD_PENSIONEROV < 2022  
    if ((mpol == "Ж" .and. mvozrast >= 56) .or. (mpol == "М" .and. mvozrast >= 61))
      v4 := 5 // взрослые старше трудоспособного возраста
    endif  
  elseif GOD_PENSIONEROV < 2024  
     if ((mpol == "Ж" .and. mvozrast >= 57) .or. (mpol == "М" .and. mvozrast >= 62))
       v4 := 5 // взрослые старше трудоспособного возраста
     endif  
  elseif GOD_PENSIONEROV < 2026  
      if ((mpol == "Ж" .and. mvozrast >= 58) .or. (mpol == "М" .and. mvozrast >= 63))
        v4 := 5 // взрослые старше трудоспособного возраста
      endif  
  else
    if ((mpol == "Ж" .and. mvozrast >= 59) .or. (mpol == "М" .and. mvozrast >= 64))
      v4 := 5 // взрослые старше трудоспособного возраста
    endif  
  endif   
endif
return v

*

***** 15.01.23
Function forma_12_o()
Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
      fl_exit := .f., sh := 79, HH := 80, reg_print := 5, speriod, ;
      arr_title, name_file := "_frm_12o"+stxt, s_lu := 0, s_human := 0, ;
      fl_plus := .f., md_plus, sd_plus, k_plus, jh := 0, arr_m, ;
      is_talon := .t., pole, arv, nf, adbf, kh, s1, s2, s3
Private au1, au2, adiag_talon[16], GOD_PENSIONEROV 
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
GOD_PENSIONEROV := arr_m[1]
if !empty(yes_d_plus)
  fl_plus := .t. ; md_plus := array(len(yes_d_plus))
  k_plus := len(md_plus)
  afill(md_plus," ")
  aeval(md_plus, {|x,i| md_plus[i] := substr(yes_d_plus,i,1) } )
  sd_plus := array(k_plus)
  afill(sd_plus,0)
endif
speriod := arr_m[4]
//
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
nf := dir_server+"f39_nast"+smem
if file(nf)
  arv := rest_arr(nf)
  au1 := arv[1]
  au2 := arv[2]
else
  au1 := {{"2.*"},{}}   // Врачебные приемы
  au2 := {{},{}}
endif
//
adbf := {{"otd","N",3,0}, ;
         {"lu","N",7,0}, ;
         {"stt_lu","N",7,0}, ;
         {"stt_diag","N",7,0}}
dbcreate(cur_dir+"tmp_tab",adbf)
use (cur_dir+"tmp_tab") new alias TMP_TAB
index on str(otd,3) to (cur_dir+"tmp_tab")
//
adbf := {{"otd","N",3,0}, ;
         {"kod","N",7,0}, ;
         {"vrach","C",30,0}, ;
         {"diag1","C",6,0}, ;
         {"diag2","C",6,0}, ;
         {"diag3","C",6,0}, ;
         {"diag4","C",6,0}, ;
         {"diag5","C",6,0}, ;
         {"diag6","C",6,0}, ;
         {"diag7","C",6,0}, ;
         {"diag8","C",6,0}}
dbcreate(cur_dir+"tmp_fio",adbf)
use (cur_dir+"tmp_fio") new alias TMP_FIO
adbf := NIL
//
kh := 0
R_Use(dir_server+"mo_pers",,"PERSO")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to u_kod into USL
if pi1 == 1  // по дате окончания лечения
  begin_date := arr_m[5]
  end_date := arr_m[6]
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",{dir_server+"humand",dir_server+"humank"},"HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(begin_date),.t.)
  do while human->k_data <= end_date .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
    if jh > 0
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jh) color cColorStMsg
    endif
    if human_->usl_ok == 3 .and. human_->oplata < 9 .and. ;
       func_pi_schet() .and. f_is_uch(st_a_uch,human->lpu)
      date_24(human->k_data)
      jh := f1_f12_o(jh)
    endif
    select HUMAN
    skip
  enddo
else
  begin_date := arr_m[7]
  end_date := arr_m[8]
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",{dir_server+"humans",dir_server+"humank"},"HUMAN")
  set relation to recno() into HUMAN_
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
  set relation to recno() into SCHET_
  set filter to empty(schet_->IS_DOPLATA)
  dbseek(begin_date,.t.)
  do while schet->pdate <= end_date .and. !eof()
    date_24(c4tod(schet->pdate))
    select HUMAN
    find (str(schet->kod,6))
    do while human->schet == schet->kod
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
      if jh > 0
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jh) color cColorStMsg
      endif
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if human_->usl_ok == 3 .and. human_->oplata < 9 .and. f_is_uch(st_a_uch,human->lpu)
        jh := f1_f12_o(jh)
      endif
      select HUMAN
      skip
    enddo
    if fl_exit
      exit
    endif
    select SCHET
    skip
  enddo
endif
s_human := tmp_fio->(lastrec())
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
//
mywait()
arr_title := {;
"──────────────────────────────┬──────────────┬───────────────┬─────────────────", ;
"                              │  Количество  │   Случаев с   │   Диагнозов с   ", ;
"          Отделение           │   случаев    │первич./повтор.│ первич./повтор. ", ;
"──────────────────────────────┴──────────────┴───────────────┴─────────────────"}
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string(center("Статистика о первичных (повторных) заболеваниях",sh))
titleN_uch(st_a_uch,sh,lcount_uch)
add_string("")
add_string(center(speriod,sh))
if pi1 == 1
  add_string(center(str_pi_schet(),sh))
else
  add_string(center("[ по дате выписки счета ]",sh))
endif
add_string("")
aeval(arr_title, {|x| add_string(x) } )
//
R_Use(dir_server+"mo_otd",,"OTD")
use (cur_dir+"tmp_tab") new alias TMP
set relation to otd into OTD
index on upper(otd->name) to (cur_dir+"tmp_tab")
go top
s1 := s2 := s3 := 0
do while !eof()
  add_string(padr(otd->name,30)+put_val(tmp->lu,10);
                               +put_val(tmp->stt_lu,16);
                               +put_val(tmp->stt_diag,17))
  s1 += tmp->lu
  s2 += tmp->stt_lu
  s3 += tmp->stt_diag
  skip
enddo
add_string(replicate("─",sh))
add_string(space(30)+put_val(s1,10);
                    +put_val(s2,16);
                    +put_val(s3,17))
close databases
if s_human > 0
  add_string(chr(12))
  tek_stroke := 0 ; n_list++
  next_list(sh)
  add_string("")
  add_string(center("Список больных с первичными (повторными) заболеваниями",sh))
  add_string("")
  //
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"human",,"HUMAN")
  use (cur_dir+"tmp_fio") new alias TMP
  set relation to otd into OTD, to kod into HUMAN
  index on upper(otd->name)+left(upper(human->fio),12) to (cur_dir+"tmp_fio")
  go top
  s1 := 0
  do while !eof()
    verify_FF(HH-2,.t.,sh)
    if tmp->otd != s1
      add_string("= "+upper(alltrim(otd->name))+" =")
      s1 := tmp->otd
    endif
    s := space(3)+left(human->fio,34)+" "+full_date(human->k_data)+space(3)
    for i := 1 to 8
      pole := "tmp->diag"+lstr(i)
      if !empty(&pole)
        s += "  "+&pole
      endif
    next
    if !empty(tmp->vrach)
      s += "  "+alltrim(tmp->vrach)
    endif
    add_string(s)
    skip
  enddo
endif
fclose(fp)
close databases
rest_box(buf)
viewtext(name_file,,,,.t.,,,reg_print)
return NIL

***** 05.01.16
Function f1_f12_o(jh)
Local arr_d := {}, arr := {}, i, j, k, s, fl, fl_plus, arv, pole, is_talon := .t.
if eq_any(human->ishod,101,102,201,202,203,204,205,301,302)
  if eq_any(human->ishod,101,102)
    arr := ret_f12_PN(human->kod,1)
  elseif eq_any(human->ishod,201,203,204)
    arr := ret_f12_DVN(human->kod,1)
  elseif eq_any(human->ishod,301,302)
    arr := ret_f12_PN(human->kod,2)
  endif
  for i := 1 to len(arr)
    arr[i,1] := padr(arr[i,1],5)
    if !empty(arr[i,1])
      fl := fl_plus := .f.
      if arr[i,2] > 0
        fl := .t.
        fl_plus := (arr[i,2] == 1)
      endif
      if fl
        aadd(arr_d, alltrim(arr[i,1])+iif(fl_plus,"+","-"))
      endif
    endif
  next
else
  afill(adiag_talon,0)
  for i := 1 to 16
    adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
  next
  arr := {human->KOD_DIAG , ;
          human->KOD_DIAG2, ;
          human->KOD_DIAG3, ;
          human->KOD_DIAG4, ;
          human->SOPUT_B1 , ;
          human->SOPUT_B2 , ;
          human->SOPUT_B3 , ;
          human->SOPUT_B4}
  for i := 1 to len(arr)
    arr[i] := padr(arr[i],5)
    if !empty(arr[i])
      fl := fl_plus := .f.
      s := substr(human->diag_plus,i,1)
      if equalany(s,"+","-")  // старая форма
        fl := .t.
        fl_plus := (s == "+")
      elseif is_talon
        s := adiag_talon[i*2-1]   // характер заболевания
        if (fl := equalany(s,1,2))
          fl_plus := (s == 1)
        else
          s := adiag_talon[i*2]   // диспансеризация
          if (fl := equalany(s,1,2))
            fl_plus := (s == 1)
          endif
        endif
      endif
      if fl
        aadd(arr_d, alltrim(arr[i])+iif(fl_plus,"+","-"))
      endif
    endif
  next
endif
select TMP_TAB
find (str(human->otd,3))
if !found()
  append blank
  tmp_tab->otd := human->otd
endif
tmp_tab->lu ++
if (j := len(arr_d)) > 0
  tmp_tab->stt_lu ++
  tmp_tab->stt_diag += j
  //
  select TMP_FIO
  append blank
  tmp_fio->otd := human->otd
  tmp_fio->kod := human->(recno())
  for i := 1 to min(j,8)
    pole := "tmp_fio->diag"+lstr(i)
    &pole := arr_d[i]
  next
  arv := {}
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    if hu->kod_vr > 0 .and. ascan(arv,hu->kod_vr) == 0 .and. ;
          (ret_f_nastr(au1,usl->shifr) .or. ret_f_nastr(au2,usl->shifr))
      aadd(arv, hu->kod_vr)
    endif
    skip
  enddo
  if len(arv) > 0
    aeval(arv, {|x,i| perso->(dbGoto(x)),arv[i]:=perso->tab_nom })
    asort(arv)
    s := "["
    aeval(arv, {|x| s += lstr(x)+"," } )
    s := substr(s,1,len(s)-1)+"]"
    tmp_fio->vrach := s
  endif
  if tmp_fio->(lastrec()) % 5000 == 0
    Commit
  endif
endif
if j > 0
  ++jh
endif
return jh

*

***** 05.01.17 для "исправлялки" форм 12 и 57
Function verify12rule(arr_bukva,lpol,yes_god)
Local i, j, k, ta := {}, lb := len(arr_bukva), s, ta4 := {}, rec, fl
select TMP_RULE
find ("3")
if found()  // т.е. работаем с правилами номер 3
  select TMP1RULE
  find ("1")
  do while tmp1rule->tip == 1 .and. !eof()
    select TMP_RULE
    dbseek("3"+str(tmp1rule->dnum,6),.t.)
    if tmp_rule->rule == 3 .and. !(tmp_rule->pol == lpol) ;
                           .and. between(tmp1rule->dnum,tmp_rule->dnum1,tmp_rule->dnum2)
      aadd(ta4,tmp1rule->(recno()))
    endif
    select TMP1RULE
    skip
  enddo
endif
select TMP_RULE
find ("4")
if found()  // т.е. работаем с правилом номер 4
  select TMP1RULE
  find ("1")
  do while tmp1rule->tip == 1 .and. !eof()
    select TMP_RULE
    dbseek("4"+str(tmp1rule->dnum,6),.t.)
    if tmp_rule->rule == 4 .and. between(tmp1rule->dnum,tmp_rule->dnum1,tmp_rule->dnum2)
      aadd(ta4,tmp1rule->(recno()))
    endif
    select TMP1RULE
    skip
  enddo
endif
if len(ta4) > 0
  select TMP1RULE
  for i := 1 to len(ta4)
    goto (ta4[i])
    delete  // пометить на удаление
  next
endif
select TMP_RULE
find ("1")
if found()  // т.е. работаем с правилами номер 1
  select TMP1RULE
  find ("1")
  do while tmp1rule->tip == 1 .and. !eof()
    select TMP_RULE
    dbseek("1"+str(tmp1rule->dnum,6),.t.)
    if tmp_rule->rule == 1 .and. between(tmp1rule->dnum,tmp_rule->dnum1,tmp_rule->dnum2)
      // острое заболевание
      if tmp1rule->kol2 > 0  // если указан характер ПОВТОРНОЕ
        tmp1rule->kol2 := 0  // то просто уберем это
      endif
      if tmp1rule->kol1 == 0  // если не указан характер ПЕРВИЧНОЕ
        tmp1rule->kol1 := 1  // то поставим хотя бы раз !!!???
      elseif tmp1rule->kol1 > 1  // характер ПЕРВИЧНОЕ указан более 1 раза
        tmp1rule->kol1 := f3_ver_rule(tmp1rule->kod,tmp_rule->dni4)
      endif
    else // хроническое заболевание
      if tmp1rule->kol1 > 1
        tmp1rule->kol1 := 1
      endif
      if tmp1rule->kol2 > 1
        tmp1rule->kol2 := 1
      endif
      if tmp1rule->kol1 > 0
        tmp1rule->kol2 := 0
      endif
      if yes_god .and. emptyall(tmp1rule->kol1,tmp1rule->kol2)
        tmp1rule->kol2 := 1
      endif
    endif
    select TMP1RULE
    skip
  enddo
  //
  select TMP1RULE
  find ("2")
  do while tmp1rule->tip == 2 .and. !eof()
    select TMP_RULE
    dbseek("1"+str(tmp1rule->dnum,6),.t.)
    if tmp_rule->rule == 1 .and. between(tmp1rule->dnum,tmp_rule->dnum1,tmp_rule->dnum2)
      // острое заболевание
      tmp1rule->kol1 := 0 // уберем
      tmp1rule->kol2 := 0 // уберем
      tmp1rule->dispan := 0  // !!!!!!!!!!!!!!!!!
    else // хроническое заболевание для трехзначного диагноза
      if tmp1rule->kol1 + tmp1rule->kol2 > 1
        tmp1rule->kol1 := 0  // первичное уберем
        tmp1rule->kol2 := 1  // повторное хотя бы раз
      endif
    endif
    select TMP1RULE
    skip
  enddo
  select TMP1RULE
  find ("1")
  do while tmp1rule->tip == 1 .and. !eof()
    rec := recno()
    find ("2"+padr(left(tmp1rule->shifr,3),5))
    fl := (found() .and. tmp1rule->kol2 > 0)
    goto (rec)
    if fl  // если повторный характер уже занесен по трехзначной рубрике
      tmp1rule->kol2 := 0 // уберем
    endif
    skip
  enddo
endif
return NIL

***** 11.12.16
Static Function f12_kod_k(mkod_k,v,v4,kol_plus,_dispans)
Static sc := 0
select TMP_KART
find (str(mkod_k,7))
if !found()
  append blank
  tmp_kart->kod_k := mkod_k
endif
tmp_kart->voz := iif(v4 > 0, v4, v)
if kol_plus > 0
  tmp_kart->perv := 1
endif
tmp_kart->let := iif(between(mlet,0,99), mlet, 0)
if eq_any(_dispans,1,2)
  tmp_kart->disp := 1
  if _dispans == 2 // Взят
    tmp_kart->disp1 := 1
  endif
endif
if ++sc == 5000
  commit
  sc := 0
endif
return NIL

*

***** 10.03.19
Function forma_14(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j, uch_otd
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Распечатка ~формы 14", ;
                "Форма 14 + ~диагнозы", ;
                "~Отделение + форма 14", ;
                "~Переведённые в другие ЛПУ"}
    mas_msg := {"Распечатка формы № 14", ;
                "Распечатка аналога формы 14 с уточнением диагнозов", ;
                "Распечатка аналога формы 14 с диагнозами по конкретному отделению", ;
                "Распечатка аналога формы 14 с уточнением диагнозов по переведённым в другие ЛПУ"}
    mas_fun := {"forma_14(11)", ;
                "forma_14(12)", ;
                "forma_14(13)", ;
                "forma_14(14)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    forma_14_(.f.,.f.)
  case k == 12
    forma_14_(.t.,.f.)
  case k == 13
    forma_14_(.t.,.t.)
  case k == 14
    forma_14_(.t.,.f.,.t.)
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL


// 27.05.23
Function forma_14_(is_diag, is_otd, is_pereved)
  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
        fl_exit := .f., sh, HH := 80, reg_print, speriod, ;
        arr_title, name_file, jh := 0, jh1 := 0, arr_m, nf, file_form

  DEFAULT is_pereved TO .f.
  name_file := cur_dir + iif(is_diag, '_frm_14d', '_form_14') + stxt
  if (file_form := search_file('forma_14' + sfrm)) == NIL
    return func_error(4, 'Не обнаружен файл FORMA_14' + sfrm)
  endif

  Private len_name := 28, arr_usl, yes_vmp := .f., yes_perevod := is_pereved
st_a_uchast := {}
if is_otd
  if input_uch(T_ROW,T_COL-5,sys_date) == NIL .or. ;
                     input_otd(T_ROW,T_COL-5,sys_date) == NIL
    return NIL
  endif
else
  if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
    return NIL
  endif
  if !is_pereved .and. (st_a_uchast := ret_uchast(T_ROW,T_COL-5)) == NIL
    return NIL
  endif
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
speriod := arr_m[4]
//
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
Private arr_perevod[11] ; afill(arr_perevod,0)
//
adbf := {{"stroke","C",9,0}, ;
         {"tip"   ,"N",1,0}, ;
         {"p_boln","N",7,0}, ;
         {"p_ekst","N",7,0}, ;
         {"p_skor","N",7,0}, ;
         {"p_bdo1","N",7,0}, ;
         {"p_kd"  ,"N",9,0}, ;
         {"p_kd1" ,"N",9,0}, ;
         {"p_umer","N",7,0}, ;
         {"p_vskr","N",7,0}, ;
         {"p_rash","N",7,0}, ;
         {"p_udo1","N",7,0}}
//

dbcreate(cur_dir+"tmp_tab",adbf)
use (cur_dir+"tmp_tab") new alias TMP_TAB
index on str(tip,1)+stroke to (cur_dir+"tmp_tab")
//
Private diag1 := {}, len_diag
lfp := fopen(file_form)
do while !feof(lfp)
  UpdateStatus()
  s := fReadLn(lfp)
  s1 := alltrim(left(s,9))     // номер строки
  if iif(is_diag, (right(s1,2) == ".0"), .t.) // только группы типа 1.0, 2.0, ..., 10.0
    s2 := alltrim(token(s," ",2))
/*for i := 1 to len(s2) // проверка на русские буквы в диагнозах
  if ISRALPHA(substr(s2,i,1))
    strfile(s2+eos,"ttt.ttt",.t.)
    exit
  endif
next*/
    s3 := token(s," ",3)
    s3 := substr(s,atnum(s3,s,1))
    //
    k := st_nom_stroke(s1)
    for i := 1 to numtoken(s3,cslash)
      s4 := k+alltrim(token(s3,cslash,i))
      len_name := max(len_name,len(s4))
    next
    diapazon := {}
    for i := 1 to numtoken(s2,",")
      s3 := token(s2,",",i)
      if "-" $ s3
        d1 := token(s3,"-",1)
        d2 := token(s3,"-",2)
      else
        d1 := d2 := s3
      endif
      aadd(diapazon, {diag_to_num(d1,1),diag_to_num(d2,2)} )
    next
    select TMP_TAB
    for i := 1 to 3
      append blank
      tmp_tab->tip := i
      tmp_tab->stroke := s1
    next
    aadd(diag1, {s1,diapazon})
  endif
enddo
fclose(lfp)
len_diag := len(diag1)
if is_diag
  aadd(adbf,{"diagnoz","C",6,0})
  dbcreate(cur_dir+"tmp_dia",adbf)
  use (cur_dir+"tmp_dia") new alias TMP_D
  index on str(tip,1)+diagnoz to (cur_dir+"tmp_dia")
endif
//
adbf := {{"stroke", "C",9,0}, ;
         {"p_boln", "N",7,0}, ;
         {"p_umer", "N",7,0}, ;
         {"p_umer6","N",7,0}, ;
         {"p1boln", "N",7,0}, ;
         {"p1umer", "N",7,0}, ;
         {"p1umer6","N",7,0}}
//
dbcreate(cur_dir+"tmp_3000",adbf)
use (cur_dir+"tmp_3000") new
index on stroke to (cur_dir+"tmp_3000")
//
Private arr_3000 := f14_arr_3000(), diag1_3000 := {}, len_diag_3000
for j := 1 to len(arr_3000)
  s1 := arr_3000[j,2]  // номер строки
  s2 := arr_3000[j,3]  // диагнозы
  if iif(is_diag, !("." $ s1), .t.) // только группы типа 1, 2, ..., 7
    diapazon := {}
    for i := 1 to numtoken(s2,",")
      s3 := token(s2,",",i)
      if "-" $ s3
        d1 := token(s3,"-",1)
        d2 := token(s3,"-",2)
      else
        d1 := d2 := s3
      endif
      aadd(diapazon, {diag_to_num(d1,1),diag_to_num(d2,2)} )
    next
    select TMP_3000
    append blank
    tmp_3000->stroke := s1
    aadd(diag1_3000, {s1,diapazon})
  endif
next
len_diag_3000 := len(diag1_3000)
if is_diag
  aadd(adbf,{"diagnoz","C",6,0})
  dbcreate(cur_dir+"tmp_d3",adbf)
  use (cur_dir+"tmp_d3") new
  index on diagnoz to (cur_dir+"tmp_d3")
endif
//
adbf := {{"stroke", "C",9,0}, ;
         {"p_boln", "N",7,0}, ;
         {"p_boln1","N",7,0}, ;
         {"p_boln2","N",7,0}, ;
         {"p_boln3","N",7,0}, ;
         {"p_boln4","N",7,0}, ;
         {"_p_boln", "N",7,0}, ;
         {"_p_boln1","N",7,0}, ;
         {"_p_boln2","N",7,0}, ;
         {"_p_boln3","N",7,0}, ;
         {"_p_boln4","N",7,0}, ;
         {"p_umer", "N",7,0}, ;
         {"p_umer1","N",7,0}, ;
         {"p_umer2","N",7,0}, ;
         {"p_umer3","N",7,0}, ;
         {"p_umer4","N",7,0}, ;
         {"_p_umer", "N",7,0}, ;
         {"_p_umer1","N",7,0}, ;
         {"_p_umer2","N",7,0}, ;
         {"_p_umer3","N",7,0}, ;
         {"_p_umer4","N",7,0}, ;
         {"p_onko", "N",7,0}}
//
dbcreate(cur_dir+"tmp_4000",adbf)
use (cur_dir+"tmp_4000") new
index on stroke to (cur_dir+"tmp_4000")
//
Private arr_4000 := f14_arr_4000(), usl1_4000 := {}, len_usl_4000
for j := 1 to len(arr_4000)
  s1 := arr_4000[j,2]  // номер строки
  s2 := arr_4000[j,3]  // включающие услуги
  if iif(is_diag, !("." $ s1), .t.) // только группы типа 1, 2, ...
    diapazon := {} ; diapazon1 := {}
    for i := 1 to numtoken(s2,",")
      s3 := token(s2,",",i)
      if "-" $ s3
        d1 := token(s3,"-",1)
        d2 := token(s3,"-",2)
      else
        d1 := d2 := s3
      endif
      aadd(diapazon, {usl_to_ffoms(d1,1),usl_to_ffoms(d2,2)} )
    next
    if len(arr_4000[j]) > 3
      s2 := arr_4000[j,4]  // исключающие услуги
      for i := 1 to numtoken(s2,",")
        s3 := token(s2,",",i)
        if "-" $ s3
          d1 := token(s3,"-",1)
          d2 := token(s3,"-",2)
        else
          d1 := d2 := s3
        endif
        aadd(diapazon1, {usl_to_ffoms(d1,1),usl_to_ffoms(d2,2)} )
      next
    endif
    select TMP_4000
    append blank
    tmp_4000->stroke := s1
    aadd(usl1_4000, {s1,diapazon,diapazon1})
  endif
next
len_usl_4000 := len(usl1_4000)
if is_diag
  aadd(adbf,{"shifr","C",14,0})
  dbcreate(cur_dir+"tmp_d4",adbf)
  use (cur_dir+"tmp_d4") new
  index on shifr to (cur_dir+"tmp_d4")
endif
//
adbf := {{"stroke", "C",9,0}, ;
  {"vip_0_14","N",7,0}, ;
  {"vip_15_19","N",7,0}, ;
  {"vip_20_24","N",7,0}, ;
  {"vip_25_29","N",7,0}, ;
  {"vip_30_34","N",7,0}, ;
  {"vip_35_39","N",7,0}, ;
  {"vip_40_44","N",7,0}, ;
  {"vip_45_49","N",7,0}, ;
  {"vip_50_54","N",7,0}, ;
  {"vip_55_59","N",7,0}, ;
  {"vip_60_64","N",7,0}, ;
  {"vip_65_69","N",7,0}, ;
  {"vip_70_74","N",7,0}, ;
  {"vip_75_79","N",7,0}, ;
  {"vip_80_84","N",7,0}, ;
  {"vip_85_99","N",7,0}, ;
  {"umer_0_14","N",7,0}, ;
  {"umer_15_19","N",7,0}, ;
  {"umer_20_24","N",7,0}, ;
  {"umer_25_29","N",7,0}, ;
  {"umer_30_34","N",7,0}, ;
  {"umer_35_39","N",7,0}, ;
  {"umer_40_44","N",7,0}, ;
  {"umer_45_49","N",7,0}, ;
  {"umer_50_54","N",7,0}, ;
  {"umer_55_59","N",7,0}, ;
  {"umer_60_64","N",7,0}, ;
  {"umer_65_69","N",7,0}, ;
  {"umer_70_74","N",7,0}, ;
  {"umer_75_79","N",7,0}, ;
  {"umer_80_84","N",7,0}, ;
  {"umer_85_99","N",7,0}}                 
//
dbcreate(cur_dir+"tmp_2910",adbf)
use (cur_dir+"tmp_2910") new
index on stroke to (cur_dir+"tmp_2910")
//
Private arr_2910 := f14_arr_2910(), diag1_2910 := {}, len_diag_2910
for j := 1 to len(arr_2910)
  s1 := arr_2910[j,2]  // номер строки
  s2 := arr_2910[j,3]  // диагнозы
  if iif(is_diag, !("." $ s1), .t.) // только группы типа 1, 2, ..., 7
    diapazon := {}
    for i := 1 to numtoken(s2,",")
      s3 := token(s2,",",i)
      if "-" $ s3
        d1 := token(s3,"-",1)
        d2 := token(s3,"-",2)
      else
        d1 := d2 := s3
      endif
      aadd(diapazon, {diag_to_num(d1,1),diag_to_num(d2,2)} )
    next
    select TMP_2910
    append blank
    tmp_2910->stroke := s1
    aadd(diag1_2910, {s1,diapazon})
  endif
next
len_diag_2910 := len(diag1_2910)
if is_diag
   aadd(adbf,{"diagnoz","C",6,0})
  dbcreate(cur_dir+"tmp_d5",adbf)
  use (cur_dir+"tmp_d5") new
  index on diagnoz to (cur_dir+"tmp_d5")
endif
//
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to u_kod into USL
R_Use(dir_server+"kartotek",,"KART")
if pi1 == 1 // по дате окончания лечения
  begin_date := arr_m[5]
  end_date := arr_m[6]
  R_Use(dir_server+"human_2",,"HUMAN_2")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to kod_k into KART, to recno() into HUMAN_, to recno() into HUMAN_2
  dbseek(dtos(begin_date),.t.)
  do while human->k_data <= end_date .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if human_->usl_ok == 1 .and. human_->oplata < 9 .and. ;
       iif(is_otd, (human->otd == glob_otd[1]), f_is_uch(st_a_uch,human->lpu)) ;
       .and. func_pi_schet() .and. f_is_uchast(st_a_uchast,kart->uchast) ;
       .and. iif(is_pereved, human_->RSLT_NEW == 102, .t.)
      jh := f1_f14(jh,@jh1,is_diag)
      @ maxrow(),1 say lstr(jh) color cColorSt2Msg
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jh1) color cColorStMsg
      date_24(human->k_data)
    endif
    select HUMAN
    skip
  enddo
else
  begin_date := arr_m[7]
  end_date := arr_m[8]
  R_Use(dir_server+"human_2",,"HUMAN_2")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humans","HUMAN")
  set relation to kod_k into KART, to recno() into HUMAN_, to recno() into HUMAN_2
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
  set relation to recno() into SCHET_
  set filter to empty(schet_->IS_DOPLATA)
  dbseek(begin_date,.t.)
  do while schet->pdate <= end_date .and. !eof()
    date_24(c4tod(schet->pdate))
    select HUMAN
    find (str(schet->kod,6))
    do while human->schet == schet->kod .and. !eof()
      if human_->usl_ok == 1 .and. human_->oplata < 9 .and. ;
         iif(is_otd, (human->otd == glob_otd[1]), f_is_uch(st_a_uch,human->lpu)) ;
         .and. f_is_uchast(st_a_uchast,kart->uchast) ;
         .and. iif(is_pereved, human_->RSLT_NEW == 102, .t.)
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        jh := f1_f14(jh,@jh1,is_diag)
        @ maxrow(),1 say lstr(jh) color cColorSt2Msg
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jh1) color cColorStMsg
      endif
      select HUMAN
      skip
    enddo
    if fl_exit
      exit
    endif
    select SCHET
    skip
  enddo
endif
//
//
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
//
mywait()
reg_print := 6
Private x := 3
arr_title := f14_title()
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(replicate("-",sh))
x := 1
arr_title := f14_title()
sh := len(arr_title[1])
add_string(padr(org->name,sh))
add_string(space(60)+padl("Форма № 14",sh-60))
add_string(padl("Утверждена",sh))
add_string(padl("Приказом Росстата",sh))
add_string(padl("от 27.12.2022г. № 985",sh))
add_string(center("СВЕДЕНИЯ О ДЕЯТЕЛЬНОСТИ ПОДРАЗДЕЛЕНИЙ МЕДИЦИНСКОЙ ОРГАНИЗАЦИИ,",sh))
add_string(center("ОКАЗЫВАЮЩИХ МЕДИЦИНСКУЮ ПОМОЩЬ В СТАЦИОНАРНЫХ УСЛОВИЯХ",sh))
if is_otd
  add_string(center(alltrim(glob_otd[2]),sh))
else
  titleN_uch(st_a_uch,sh,lcount_uch)
  title_uchast(st_a_uchast,sh)
endif
if is_pereved
  add_string(center("[ переведённые в другие ЛПУ ]",sh))
endif
add_string("")
add_string(center(speriod,sh))
if pi1 == 1
  add_string(center(str_pi_schet(),sh))
else
  add_string(center("[ по дате выписки счета ]",sh))
endif
add_string("")
//
if is_diag
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB10")
  use (cur_dir+"tmp_dia") new alias TMP_D
  index on str(tip,1)+stroke+diagnoz to (cur_dir+"tmp_dia")
  use (cur_dir+"tmp_d3") new
  index on stroke+diagnoz to (cur_dir+"tmp_d3")
  use (cur_dir+"tmp_d4") new
  index on stroke+shifr to (cur_dir+"tmp_d4")
  use (cur_dir+"tmp_d5") new
  index on stroke+diagnoz to (cur_dir+"tmp_d5")
endif
use (cur_dir+"tmp_2910") index (cur_dir+"tmp_2910") new
use (cur_dir+"tmp_3000") index (cur_dir+"tmp_3000") new
use (cur_dir+"tmp_4000") index (cur_dir+"tmp_4000") new
use (cur_dir+"tmp_tab") index (cur_dir+"tmp_tab") new alias TMP
ft_use(file_form)
add_string(center("1. СОСТАВ ПАЦИЕНТОВ В СТАЦИОНАРЕ, СРОКИ И ИСХОДЫ ЛЕЧЕНИЯ",sh))
add_string(" (2000)"+padl("Код по ОКЕИ: человек - 792",sh-8))
for x := 1 to 3
  arr_title := f14_title()
  sh := len(arr_title[1])
  if x > 1  // искусственный перевод страницы
    tek_stroke := HH+10
    verify_FF(HH,.t.,sh)
  endif
  aeval(arr_title, {|x| add_string(x) } )
  ft_gotop()
  do while !ft_eof() .and. !empty( s := ft_ReadLn() )
    s1 := left(s,9) ; s1_ := alltrim(s1)
    if iif(is_diag, (right(s1_,2) == ".0"), .t.)
      s2 := token(s," ",2)
      s3 := token(s," ",3)
      s3 := substr(s,atnum(s3,s,1))
      select TMP
      find (str(x,1)+s1)
      if found() .and. iif(is_diag, !emptyall(tmp->p_boln,tmp->p_umer), .t.)
        k := st_nom_stroke(s1)
        //
        j1 := 0 ; t_arr1 := {} ; t_arr2 := array(12)
        for i := 1 to numtoken(s3,cslash)
          s := alltrim(token(s3,cslash,i))
          ++j1 ; aadd(t_arr1,k+s)
        next
        j2 := perenos(t_arr2,s2,12,",")
        for i := j1+1 to j2
          ++j1 ; aadd(t_arr1,"")
        next
        if verify_FF(HH-max(j1,j2),.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        ls1 := padr(t_arr1[1],len_name)+;
               padc(alltrim(s1),11)+;
               padc(alltrim(t_arr2[1]),12)
        ls1 += put_val(tmp->p_boln,7)+;
               put_val(tmp->p_ekst,7)+;
               put_val(tmp->p_skor,7)
      if x == 3
        ls1 += put_val(tmp->p_bdo1,7)
      endif
        ls1 += put_val(tmp->p_kd  ,8)
      if x == 3
        ls1 += put_val(tmp->p_kd1 ,7)
      endif
        ls1 += put_val(tmp->p_umer,4)+;
               put_val(tmp->p_vskr,4)+;
               put_val(tmp->p_rash,4)
      if x == 3
        ls1 += space(6)+put_val(tmp->p_udo1,4)
      endif
        if is_diag .and. !(s1_ == "1.0")
          add_string(replicate("-",sh))
        endif
        add_string(ls1)
        for i := 2 to max(j1,j2)
          ls2 := padr(t_arr1[i],len_name)+;
                 space(11)+;
                 padc(alltrim(t_arr2[i]),12)
          add_string(ls2)
        next
        if iif(is_diag, !(s1_ == "1.0"), .t.)
          add_string(replicate("-",sh))
        endif
        if is_diag
          select TMP_D
          find (str(x,1)+s1)
          do while tmp_d->tip==x .and. tmp_d->stroke==s1 .and. !eof()
            select MKB10
            find (tmp_d->diagnoz)
            s := alltrim(mkb10->name)+" "
            skip
            do while mkb10->shifr == tmp_d->diagnoz .and. mkb10->ks > 0 ;
                                                            .and. !eof()
              s += alltrim(mkb10->name)+" "
              skip
            enddo
            j1 := perenos(t_arr1,s,len_name+11)
            if verify_FF(HH-j1,.t.,sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            ls1 := padr(t_arr1[1],len_name+11)+;
                   padc(alltrim(tmp_d->diagnoz),12)
            ls1 += put_val(tmp_d->p_boln,7)+;
                   put_val(tmp_d->p_ekst,7)+;
                   put_val(tmp_d->p_skor,7)
          if x == 3
            ls1 += put_val(tmp_d->p_bdo1,7)
          endif
            ls1 += put_val(tmp_d->p_kd  ,8)
          if x == 3
            ls1 += put_val(tmp_d->p_kd1 ,7)
          endif
            ls1 += put_val(tmp_d->p_umer,4)+;
                   put_val(tmp_d->p_vskr,4)+;
                   put_val(tmp_d->p_rash,4)
          if x == 3
            ls1 += space(6)+put_val(tmp_d->p_udo1,4)
          endif
            add_string(ls1)
            for i := 2 to j1
              add_string(padl(alltrim(t_arr1[i]),len_name+11))
            next
            select TMP_D
            skip
          enddo
        endif
      endif
    endif
    ft_skip()
  enddo
next
ft_use()
//
arr_title := {;
"_____________________________________________________________________________________________________", ;
"                                        │     │            │_____до_1000_г______│_____1000_г_и_более_", ;
"                                        │  №  │            │Посту-│из них умерло│Посту-│из них умерло", ;
"    Наименование заболеваний            │стро-│   Код по   │пило  ├──────┬──────│пило  ├──────┬──────", ;
"                                        │ ки  │   МКБ-10   │пациен│ всего│0-6дн.│пациен│ всего│0-6дн.", ;
"────────────────────────────────────────┴─────┴────────────┴──────┴──────┴──────┴──────┴──────┴──────"}
sh := len(arr_title[1])
len_name := 40
tek_stroke := HH+10
verify_FF(HH,.t.,sh)
add_string(center("2. СОСТАВ НОВОРОЖДЕННЫХ С ЗАБОЛЕВАНИЯМИ, ПОСТУПИВШИХ В ВОЗРАСТЕ 0-6 ДНЕЙ ЖИЗНИ,",sh))
add_string(center("И ИСХОДЫ ИХ ЛЕЧЕНИЯ",sh))
add_string("")
add_string("(3000)"+padl("Код по ОКЕИ: человек - 792",sh-6))
aeval(arr_title, {|x| add_string(x) } )
for k := 1 to len(arr_3000)
  s1_ := arr_3000[k,2] ; s1 := padr(s1_,9)
  if iif(is_diag, !("." $ s1_), .t.)
    select TMP_3000
    find (s1)
    if found() .and. iif(is_diag, !emptyall(tmp_3000->p_boln,tmp_3000->p1boln), .t.)
      t_arr1 := array(12) ; t_arr2 := array(12)
      afill(t_arr1,"")    ; afill(t_arr2,"")
      j1 := perenos(t_arr1,arr_3000[k,1],len_name)
      j2 := perenos(t_arr2,arr_3000[k,3],12,",")
      if verify_FF(HH-max(j1,j2),.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      ls1 := padr(t_arr1[1],len_name)+;
             padc(s1_,7)+;
             padc(alltrim(t_arr2[1]),12)
      ls1 += put_val(tmp_3000->p_boln,7)+;
             put_val(tmp_3000->p_umer,7)+;
             put_val(tmp_3000->p_umer6,7)
      ls1 += put_val(tmp_3000->p1boln,7)+;
             put_val(tmp_3000->p1umer,7)+;
             put_val(tmp_3000->p1umer6,7)
      if is_diag .and. !(s1_ == "1")
        add_string(replicate("-",sh))
      endif
      add_string(ls1)
      for i := 2 to max(j1,j2)
        ls2 := padl(alltrim(t_arr1[i]),len_name)+;
               space(7)+;
               padc(alltrim(t_arr2[i]),12)
        add_string(ls2)
      next
      if iif(is_diag, !(s1_ == "1"), .t.)
        add_string(replicate("-",sh))
      endif
      if is_diag
        select TMP_D3
        find (s1)
        do while tmp_d3->stroke==s1 .and. !eof()
          select MKB10
          find (tmp_d3->diagnoz)
          s := alltrim(mkb10->name)+" "
          skip
          do while mkb10->shifr == tmp_d3->diagnoz .and. mkb10->ks > 0 ;
                                                          .and. !eof()
            s += alltrim(mkb10->name)+" "
            skip
          enddo
          j1 := perenos(t_arr1,s,len_name+7)
          if verify_FF(HH-j1,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          ls1 := padr(t_arr1[1],len_name+7)+;
                 padc(alltrim(tmp_d3->diagnoz),12)
          ls1 += put_val(tmp_d3->p_boln,7)+;
                 put_val(tmp_d3->p_umer,7)+;
                 put_val(tmp_d3->p_umer6,7)
          ls1 += put_val(tmp_d3->p1boln,7)+;
                 put_val(tmp_d3->p1umer,7)+;
                 put_val(tmp_d3->p1umer6,7)
          add_string(ls1)
          for i := 2 to j1
            add_string(padl(alltrim(t_arr1[i]),len_name+7))
          next
          select TMP_D3
          skip
        enddo
      endif
    endif
  endif
next
//
use_base("luslf")
arr_title := {;
"────────────────────────────────────────┬─────────┬──────┬───────────────────────────┬──────┬───────────────────────────┬──────", ;
"                                        │         │Число │          из них     старше│Умерло│          из них     старше│Злока-", ;
"    Наименование операции               │ № строки│опера-├──────┬──────┬──────┐труд. │опери-├──────┬──────┬──────┐труд. │честв.", ;
"                                        │         │ций   │0-14л.│до1год│15-17л│возрас│рован.│0-14л.│до1год│15-17л│возрас│образ.", ;
"────────────────────────────────────────┼─────────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────", ;
"                 1                      │    2    │  3   │  4   │  5   │  6   │3/4001│  19  │  20  │  21  │  22  │7/4001│  27  ", ;
"────────────────────────────────────────┴─────────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────"}
sh := len(arr_title[1])
len_name := 40
tek_stroke := HH+10
verify_FF(HH,.t.,sh)
add_string(center("3. ХИРУРГИЧЕСКАЯ РАБОТА ОРГАНИЗАЦИИ",sh))
add_string("")
add_string("(4000)"+padl("Код по ОКЕИ: единица - 642",sh-6))
aeval(arr_title, {|x| add_string(x) } )
for k := 1 to len(arr_4000)
  s1_ := arr_4000[k,2] ; s1 := padr(s1_,9)
  if iif(is_diag, !("." $ s1_), .t.)
    select TMP_4000
    find (s1)
    if found() .and. iif(is_diag, !empty(tmp_4000->p_boln), .t.)
      t_arr1 := array(12)
      afill(t_arr1,"")
      j1 := perenos(t_arr1,arr_4000[k,1],len_name)
      if verify_FF(HH-j1,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      ls1 := padr(t_arr1[1],len_name)+;
             padc(s1_,11)
      ls1 += put_val(tmp_4000->p_boln,6)+;
             put_val(tmp_4000->p_boln1,7)+;
             put_val(tmp_4000->p_boln2,7)+;
             put_val(tmp_4000->p_boln3,7)+;
             put_val(tmp_4000->p_boln4,7)+;
             put_val(tmp_4000->p_umer,7)+;
             put_val(tmp_4000->p_umer1,7)+;
             put_val(tmp_4000->p_umer2,7)+;
             put_val(tmp_4000->p_umer3,7)+;
             put_val(tmp_4000->p_umer4,7)+;
             put_val(tmp_4000->p_onko,7)
      if is_diag .and. !(s1_ == "1")
        add_string(replicate("-",sh))
      endif
      add_string(ls1)
      for i := 2 to j1
        ls2 := padl(alltrim(t_arr1[i]),len_name)
        add_string(ls2)
      next
      if iif(is_diag, !(s1_ == "1"), .t.)
        add_string(replicate("-",sh))
      endif
      if is_diag
        select TMP_D4
        find (s1)
        do while tmp_d4->stroke == s1 .and. !eof()
          if arr_m[1] > 2018
            select luslf
            find (tmp_d4->shifr)
            s := alltrim(tmp_d4->shifr) + ' ' + alltrim(luslf->name)
          elseif LUSLF18->(used())
            select luslf18
            find (tmp_d4->shifr)
            s := alltrim(tmp_d4->shifr) + ' ' + alltrim(luslf18->name)
          endif
          j1 := perenos(t_arr1,s,len_name+11)
          if verify_FF(HH-j1,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          ls1 := padr(t_arr1[1],len_name+11)
          ls1 += put_val(tmp_d4->p_boln,6)+;
                 put_val(tmp_d4->p_boln1,7)+;
                 put_val(tmp_d4->p_boln2,7)+;
                 put_val(tmp_d4->p_boln3,7)+;
                 put_val(tmp_d4->p_boln4,7)+;
                 put_val(tmp_d4->p_umer,7)+;
                 put_val(tmp_d4->p_umer1,7)+;
                 put_val(tmp_d4->p_umer2,7)+;
                 put_val(tmp_d4->p_umer3,7)+;
                 put_val(tmp_d4->p_umer4,7)+;
                 put_val(tmp_d4->p_onko,7)
          add_string(ls1)
          for i := 2 to j1
            add_string(padl(alltrim(t_arr1[i]),len_name+11))
          next
          select TMP_D4
          skip
        enddo
      endif
    endif
  endif
next
//
if yes_vmp
  arr_title := {;
  "────────────────────────────────────────┬─────────┬──────┬───────────────────────────┬──────┬───────────────────────────", ;
  "                                        │         │Число │          из них     старше│Умерло│          из них     старше", ;
  "    Наименование операции               │ № строки│операц├──────┬──────┬──────┐труд. │опери-├──────┬──────┬──────┐труд. ", ;
  "                                        │         │ий ВМТ│0-14л.│до1год│15-17л│возрас│рован.│0-14л.│до1год│15-17л│возрас", ;
  "────────────────────────────────────────┼─────────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────", ;
  "                 1                      │    2    │   7  │   8  │   9  │  10  │4/4001│  23  │  24  │  25  │  26  │8/4001", ;
  "────────────────────────────────────────┴─────────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────"}
  sh := len(arr_title[1])
  len_name := 40
  tek_stroke := HH+10
  verify_FF(HH,.t.,sh)
  add_string(center("3. ХИРУРГИЧЕСКАЯ РАБОТА ОРГАНИЗАЦИИ - с применением ВМТ",sh))
  add_string("")
  add_string("(4000)"+padl("Код по ОКЕИ: единица - 642",sh-6))
  aeval(arr_title, {|x| add_string(x) } )
  for k := 1 to len(arr_4000)
    s1_ := arr_4000[k,2] ; s1 := padr(s1_,9)
    if iif(is_diag, !("." $ s1_), .t.)
      select TMP_4000
      find (s1)
      if found() .and. !empty(tmp_4000->_p_boln)
        t_arr1 := array(12)
        afill(t_arr1,"")
        j1 := perenos(t_arr1,arr_4000[k,1],len_name)
        if verify_FF(HH-j1,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        ls1 := padr(t_arr1[1],len_name)+;
               padc(s1_,11)
        ls1 += put_val(tmp_4000->_p_boln,6)+;
               put_val(tmp_4000->_p_boln1,7)+;
               put_val(tmp_4000->_p_boln2,7)+;
               put_val(tmp_4000->_p_boln3,7)+;
               put_val(tmp_4000->_p_boln4,7)+;
               put_val(tmp_4000->_p_umer,7)+;
               put_val(tmp_4000->_p_umer1,7)+;
               put_val(tmp_4000->_p_umer2,7)+;
               put_val(tmp_4000->_p_umer3,7)+;
               put_val(tmp_4000->_p_umer4,7)
        if is_diag .and. !(s1_ == "1")
          add_string(replicate("-",sh))
        endif
        add_string(ls1)
        for i := 2 to max(j1,j2)
          ls2 := padl(alltrim(t_arr1[i]),len_name)
          add_string(ls2)
        next
        if iif(is_diag, !(s1_ == "1"), .t.)
          add_string(replicate("-",sh))
        endif
        if is_diag
          select TMP_D4
          find (s1)
          do while tmp_d4->stroke==s1 .and. !eof()
            if !empty(tmp_d4->_p_boln)
              if arr_m[1] > 2018
                select luslf
                find (tmp_d4->shifr)
                s := alltrim(tmp_d4->shifr)+" "+alltrim(luslf->name)
              elseif LUSLF18->(used())
                select luslf18
                find (tmp_d4->shifr)
                s := alltrim(tmp_d4->shifr)+" "+alltrim(luslf18->name)
              endif
              j1 := perenos(t_arr1,s,len_name+11)
              if verify_FF(HH-j1,.t.,sh)
                aeval(arr_title, {|x| add_string(x) } )
              endif
              ls1 := padr(t_arr1[1],len_name+11)
              ls1 += put_val(tmp_d4->_p_boln,6)+;
                     put_val(tmp_d4->_p_boln1,7)+;
                     put_val(tmp_d4->_p_boln2,7)+;
                     put_val(tmp_d4->_p_boln3,7)+;
                     put_val(tmp_d4->_p_boln4,7)+;
                     put_val(tmp_d4->_p_umer,7)+;
                     put_val(tmp_d4->_p_umer1,7)+;
                     put_val(tmp_d4->_p_umer2,7)+;
                     put_val(tmp_d4->_p_umer3,7)+;
                     put_val(tmp_d4->_p_umer4,7)
              add_string(ls1)
              for i := 2 to j1
                add_string(padl(alltrim(t_arr1[i]),len_name+11))
              next
            endif
            select TMP_D4
            skip
          enddo
        endif
      endif
    endif
  next
endif
//
arr_title := {;
  "___________________________________________________________________________________________________________________________", ;
  "                                        │     │            │_____Выписано_пациентов_(из_таб.2000_гр.4_и_гр.22)_в_возрасте__", ;
  "                                        │  №  │            │ 0 │ 15│ 20│ 25│ 30│ 35│ 40│ 45│ 50│ 55│ 60│ 65│ 70│ 75│ 80│ 85", ;
  "    Наименование заболеваний            │стро-│   Код по   │ 14│ 19│ 24│ 29│ 34│ 39│ 44│ 49│ 54│ 59│ 64│ 69│ 74│ 79│ 84│...", ;
  "                                        │ ки  │   МКБ-10   │лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет", ;
  "────────────────────────────────────────┴─────┴────────────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───"}
  sh := len(arr_title[1])
  len_name := 40
  tek_stroke := HH+10
  verify_FF(HH,.t.,sh)
  add_string(center("2. СВЕДЕНИЯ О ЧИСЛЕ ВЫБЫВШИХ ИЗ СТАЦИОНАРА ПО ВОЗРАСТУ ПАЦИЕНТА, человек",sh))
  add_string("")
  add_string("(2910)"+padl("Код по ОКЕИ: человек - 792",sh-6))
  aeval(arr_title, {|x| add_string(x) } )
  for k := 1 to len(arr_2910)
    s1_ := arr_2910[k,2] ; s1 := padr(s1_,9)
    if iif(is_diag, !("." $ s1_), .t.)
      select TMP_2910
      find (s1)
      if found() //.and. iif(is_diag, !emptyall(tmp_2910->p_boln,tmp_2910->p1boln), .t.)
        t_arr1 := array(12) ; t_arr2 := array(12)
        afill(t_arr1,"")    ; afill(t_arr2,"")
        j1 := perenos(t_arr1,arr_2910[k,1],len_name)
        j2 := perenos(t_arr2,arr_2910[k,3],12,",")
        if verify_FF(HH-max(j1,j2),.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        ls1 := padr(t_arr1[1],len_name)+;
               padc(s1_,7)+;
               padc(alltrim(t_arr2[1]),12)
        ls1 += put_val(tmp_2910->vip_0_14,4)+;
               put_val(tmp_2910->vip_15_19,4)+;
               put_val(tmp_2910->vip_20_24,4)
        ls1 += put_val(tmp_2910->vip_25_29,4)+;
               put_val(tmp_2910->vip_30_34,4)+;
               put_val(tmp_2910->vip_35_39,4)
        ls1 += put_val(tmp_2910->vip_40_44,4)+;
               put_val(tmp_2910->vip_45_49,4)+;
               put_val(tmp_2910->vip_50_54,4)
        ls1 += put_val(tmp_2910->vip_55_59,4)+;
               put_val(tmp_2910->vip_60_64,4)+;
               put_val(tmp_2910->vip_65_69,4) 
        ls1 += put_val(tmp_2910->vip_70_74,4)+;
               put_val(tmp_2910->vip_75_79,4)+;
               put_val(tmp_2910->vip_80_84,4)+; 
               put_val(tmp_2910->vip_85_99,4)
         if is_diag .and. !(s1_ == "1")
          add_string(replicate("-",sh))
        endif
        add_string(ls1)
        for i := 2 to max(j1,j2)
          ls2 := padl(alltrim(t_arr1[i]),len_name)+;
                 space(7)+;
                 padc(alltrim(t_arr2[i]),12)
          add_string(ls2)
        next
        if iif(is_diag, !(s1_ == "1"), .t.)
          add_string(replicate("-",sh))
        endif
        if is_diag
          select TMP_D5
          find (s1)
          do while tmp_d5->stroke==s1 .and. !eof()
            select MKB10
            find (tmp_d5->diagnoz)
            s := alltrim(mkb10->name)+" "
            skip
            do while mkb10->shifr == tmp_d5->diagnoz .and. mkb10->ks > 0 ;
                                                            .and. !eof()
              s += alltrim(mkb10->name)+" "
              skip
            enddo
            j1 := perenos(t_arr1,s,len_name+7)
            if verify_FF(HH-j1,.t.,sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            ls1 := padr(t_arr1[1],len_name+7)+;
                   padc(alltrim(tmp_d5->diagnoz),12)
            ls1 += put_val(tmp_d5->vip_0_14,4)+;
                   put_val(tmp_d5->vip_15_19,4)+;
                   put_val(tmp_d5->vip_20_24,4)
            ls1 += put_val(tmp_d5->vip_25_29,4)+;
                   put_val(tmp_d5->vip_30_34,4)+;
                   put_val(tmp_d5->vip_35_39,4)
            ls1 += put_val(tmp_d5->vip_40_44,4)+;
                   put_val(tmp_d5->vip_45_49,4)+;
                   put_val(tmp_d5->vip_50_54,4)
            ls1 += put_val(tmp_d5->vip_55_59,4)+;
                   put_val(tmp_d5->vip_60_64,4)+;
                   put_val(tmp_d5->vip_65_69,4) 
            ls1 += put_val(tmp_d5->vip_70_74,4)+;
                   put_val(tmp_d5->vip_75_79,4)+;
                   put_val(tmp_d5->vip_80_84,4)+; 
                   put_val(tmp_d5->vip_85_99,4)
            add_string(ls1)
            for i := 2 to j1
              add_string(padl(alltrim(t_arr1[i]),len_name+7))
            next
            select TMP_D5
            skip
          enddo
        endif
      endif
    endif
  next
  //
  arr_title := {;
    "___________________________________________________________________________________________________________________________", ;
    "                                        │     │            │_____Умерло_пациентов_(из_таб.2000_гр.4_и_гр.22)_в_возрасте____", ;
    "                                        │  №  │            │ 0 │ 15│ 20│ 25│ 30│ 35│ 40│ 45│ 50│ 55│ 60│ 65│ 70│ 75│ 80│ 85", ;
    "    Наименование заболеваний            │стро-│   Код по   │ 14│ 19│ 24│ 29│ 34│ 39│ 44│ 49│ 54│ 59│ 64│ 69│ 74│ 79│ 84│...", ;
    "                                        │ ки  │   МКБ-10   │лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет│лет", ;
    "────────────────────────────────────────┴─────┴────────────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───"}
    sh := len(arr_title[1])
    len_name := 40
    tek_stroke := HH+10
    verify_FF(HH,.t.,sh)
    //add_string(center("2. СВЕДЕНИЯ О ЧИСЛЕ ВЫБЫВШИХ ИЗ СТАЦИОНАРА ПО ВОЗРАСТУ ПАЦИЕНТА, человек",sh))
    add_string("")
    //add_string("(2910)"+padl("Код по ОКЕИ: человек - 792",sh-6))
    aeval(arr_title, {|x| add_string(x) } )
    for k := 1 to len(arr_2910)
      s1_ := arr_2910[k,2] ; s1 := padr(s1_,9)
      if iif(is_diag, !("." $ s1_), .t.)
        select TMP_2910
        find (s1)
        if found() //.and. iif(is_diag, !emptyall(tmp_2910->p_boln,tmp_2910->p1boln), .t.)
          t_arr1 := array(12) ; t_arr2 := array(12)
          afill(t_arr1,"")    ; afill(t_arr2,"")
          j1 := perenos(t_arr1,arr_2910[k,1],len_name)
          j2 := perenos(t_arr2,arr_2910[k,3],12,",")
          if verify_FF(HH-max(j1,j2),.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          ls1 := padr(t_arr1[1],len_name)+;
                 padc(s1_,7)+;
                 padc(alltrim(t_arr2[1]),12)
          ls1 += put_val(tmp_2910->umer_0_14,4)+;
                 put_val(tmp_2910->umer_15_19,4)+;
                 put_val(tmp_2910->umer_20_24,4)
          ls1 += put_val(tmp_2910->umer_25_29,4)+;
                 put_val(tmp_2910->umer_30_34,4)+;
                 put_val(tmp_2910->umer_35_39,4)
          ls1 += put_val(tmp_2910->umer_40_44,4)+;
                 put_val(tmp_2910->umer_45_49,4)+;
                 put_val(tmp_2910->umer_50_54,4)
          ls1 += put_val(tmp_2910->umer_55_59,4)+;
                 put_val(tmp_2910->umer_60_64,4)+;
                 put_val(tmp_2910->umer_65_69,4) 
          ls1 += put_val(tmp_2910->umer_70_74,4)+;
                 put_val(tmp_2910->umer_75_79,4)+;
                 put_val(tmp_2910->umer_80_84,4)+; 
                 put_val(tmp_2910->umer_85_99,4)
            
          if is_diag .and. !(s1_ == "1")
            add_string(replicate("-",sh))
          endif
          add_string(ls1)
          for i := 2 to max(j1,j2)
            ls2 := padl(alltrim(t_arr1[i]),len_name)+;
                   space(7)+;
                   padc(alltrim(t_arr2[i]),12)
            add_string(ls2)
          next
          if iif(is_diag, !(s1_ == "1"), .t.)
            add_string(replicate("-",sh))
          endif
          if is_diag
            select TMP_D5
            find (s1)
            do while tmp_d5->stroke==s1 .and. !eof()
              select MKB10
              find (tmp_d5->diagnoz)
              s := alltrim(mkb10->name)+" "
              skip
              do while mkb10->shifr == tmp_d5->diagnoz .and. mkb10->ks > 0 ;
                                                              .and. !eof()
                s += alltrim(mkb10->name)+" "
                skip
              enddo
              j1 := perenos(t_arr1,s,len_name+7)
              if verify_FF(HH-j1,.t.,sh)
                aeval(arr_title, {|x| add_string(x) } )
              endif
              ls1 := padr(t_arr1[1],len_name+7)+;
                     padc(alltrim(tmp_d5->diagnoz),12)
              ls1 += put_val(tmp_d5->umer_0_14,4)+;
                     put_val(tmp_d5->umer_15_19,4)+;
                     put_val(tmp_d5->umer_20_24,4)
              ls1 += put_val(tmp_d5->umer_25_29,4)+;
                     put_val(tmp_d5->umer_30_34,4)+;
                     put_val(tmp_d5->umer_35_39,4)
              ls1 += put_val(tmp_d5->umer_40_44,4)+;
                     put_val(tmp_d5->umer_45_49,4)+;
                     put_val(tmp_d5->umer_50_54,4)
              ls1 += put_val(tmp_d5->umer_55_59,4)+;
                     put_val(tmp_d5->umer_60_64,4)+;
                     put_val(tmp_d5->umer_65_69,4) 
              ls1 += put_val(tmp_d5->umer_70_74,4)+;
                     put_val(tmp_d5->umer_75_79,4)+;
                     put_val(tmp_d5->umer_80_84,4)+; 
                     put_val(tmp_d5->umer_85_99,4)
            
              add_string(ls1)
              for i := 2 to j1
                add_string(padl(alltrim(t_arr1[i]),len_name+7))
              next
              select TMP_D5
              skip
            enddo
          endif
        endif
      endif
    next
/*if arr_perevod[5]+arr_perevod[6]+arr_perevod[9]+arr_perevod[10] > 0
  add_string(replicate("=",sh))
  ls1 := padr("Кроме того, больные переведенные в другие стационары:",len_name+22)
  ls1 += put_val(arr_perevod[4],6)+space(2)+;
         put_val(arr_perevod[5],8)+;
         put_val(arr_perevod[6],6)+space(2)+space(2)+;
         put_val(arr_perevod[7],6)+;
         put_val(arr_perevod[8],6)+;
         put_val(arr_perevod[9],8)+;
         put_val(arr_perevod[10],6)+space(3)+space(3)+;
         put_val(arr_perevod[11],6)
  add_string(ls1)
endif*/
fclose(fp)
close databases
rest_box(buf)
viewtext(name_file,,,,.t.,,,reg_print)
return NIL

*

***** 16.01.23
Function f14_arr_2910()
  Static arr := {;
    {"сахарный диабет (из стр. 5.4)","1","E10-E11,E13-E14"}, ;
    {"болезни, характеризующиеся\повышенным кровяным давлением (из стр.10.3)","2","I10,I11.9,I12.9,I13.9"}, ;
    {"хроническая ишемическая\болезнь сердца (стр. 10.4.5)","3","I25"}, ;
    {"бронхит хронический и\неуточненный, эмфизема (стр. 11.7)","4","J40-J43"}, ;
    {"другая хроническая\обструктивная легочная\болезнь (стр.11.8)","5","J44"}, ;
    {"бронхоэктатическая болезнь (стр. 11.9)","6","J47"}, ;
    {"астма, астматический статус (стр. 11.10)","7","J45,J46"};
    }
  return arr

***** 02.01.16
Function f14_arr_3000()
Static arr := {;
  {"Всего новорожденных, в том числе с заболеваниями:","1",""}, ;
  {"острые респираторные инфекции верхних дыхательных путей, грипп","2","J00-J06,J10-J11"}, ;
  {"пневмонии","3","J12-J18"}, ;
  {"инфекции кожи и подкожной клетчатки","4","L00-L08"}, ;
  {"отдельные состояния, возникающие в перинатальном периоде","5","P00-P96"}, ;
  {"из них: замедленный рост и недостаточность питания","5.1","P05"}, ;
  {"родовая травма - всего","5.2","P10-P15"}, ;
  {"в т.ч. разрыв внутричерепных тканей и кровоизлияние вследствие родовой травмы","5.2.1","P10"}, ;
  {"дыхательные нарушения, характерные для перинатального периода, - всего","5.3","P20-P28"}, ;
  {"из них: внутриутробная гипоксия, асфиксия при родах","5.3.1","P20,P21"}, ;
  {"дыхательное расстройство у новорожденных","5.3.2","P22"}, ;
  {"врожденная пневмония","5.3.3","P23"}, ;
  {"неонатальные аспирационные синдромы","5.3.4","P24"}, ;
  {"инфекционные болезни, специфичные для перинатального периода, - всего","5.4","P35-P39"}, ;
  {"из них бактериальный сепсис новорожденного","5.4.1","P36"}, ;
  {"гемолитическая болезнь плода и новорожденного, водянка плода, обусловленная гемолитической болезнью, ядерная желтуха","5.5","P55-P57"}, ;
  {"неонатальная желтуха, обусловленная чрезмерным гемолизом, другими и неуточненными причинами","5.6","P58-P59"}, ;
  {"геморрагическая болезнь, диссеминированное внутрисосудистое свертывание у плода и новорожденного, другие перинатальные гематологические нарушения","5.7","P53,P60,P61"}, ;
  {"врожденные аномалии (пороки развития), деформации и хромосомные нарушения","6","Q00-Q99"}, ;
  {"прочие болезни","7","U07.1,U07.2"}, ;
  {"прочие болезни","8",""};
}
return arr

*

***** 02.01.16
Function f14_arr_4000()
Static arr := {;
  {"Всего операций","1",""}, ;
  {"в том числе: операции на нервной системе","2","23,24"}, ;
  {"удаление травматической внутричерепной гематомы,очага ушиба, вдавленного перелома черепа, устранение дефекта черепа и лицевого скилета","2.1",""}, ;
  {"операции при сосудистых пороках мозга","2.2",""}, ;
  {"из них: на аневризмах","2.2.1",""}, ;
  {"  из них: эндоваскулярное выключение","2.2.1.1",""}, ;
  {"на мальформациях","2.2.2",""}, ;
  {"  из них: эндоваскулярное выключение","2.2.2.1",""}, ;
  {"операции при церебральном инсульте","2.3",""}, ;
  {"из них: при геморрагическом инсульте","2.3.1",""}, ;
  {"  из них: открытое удаление гематомы","2.3.1.1",""}, ;
  {"при инфаркте мозга","2.3.2",""}, ;
  {"  из них: краниотомия","2.3.2.1",""}, ;
  {"  эндоваскулярная тромбоэкстракция","2.3.2.2",""}, ;
  {"операции при окклюзионно-стенотических поражениях сосудов мозга","2.4",""}, ;
  {"из них: на экстрацеребральных отделах сонных и позвоночных артерий","2.4.1",""}, ;
  {"  из них: эндартерэктомия, редрессация, реимплантация","2.4.1.1",""}, ;
  {"  стентирование","2.4.1.2",""}, ;
  {"на внутричерепных артериях","2.4.2",""}, ;
  {"  из них: экстраинтракраниальные анастомозы","2.4.2.1",""}, ;
  {"  стентирование","2.4.2.2",""}, ;
  {"удаление опухолей головного, спинного мозга","2.5",""}, ;
  {"операции при функциональных расстройствах","2.6",""}, ;
  {"из них: при болевых синдромах","2.6.1",""}, ;
  {"  из них васкулярная декомпрессия","2.6.1.1",""}, ;
  {"при эпилепсии, паркинсонизме, мышечно-тонических расстройствах","2.6.2",""}, ;
  {"  из них: резекционные и деструктивные операции","2.6.2.1",""}, ;
  {"  установка стимуляторов","2.6.2.2",""}, ;
  {"декомпрессивные, стабилизирующие операции при позвоночно-спинальной травме","2.7",""}, ;
  {"декомпрессивные, стабилизирующие операции при дегенеративных заболеваниях позвоничника","2.8",""}, ;
  {"операции на периферических нервах","2.9",""}, ;
  {"ликворошунтирующие операции","2.10",""}, ;
  {"операции при врожденных аномалиях развития центральной нервной системы","2.11",""}, ;
  {"операции на эндокринной системе","3","22"}, ;
  {"из них тиреотомии","3.1","22.001-22.003"}, ;
  {"операции на органе зрения","4","26"}, ;
  {"из них: кератопластика","4.1","26.049"}, ;
  {"задняя витреоэктомия","4.2","26.089"}, ;
  {"транпупиллярная термотерапия","4.3",""}, ;
  {"брахитерапия","4.4",""}, ;
  {"операции по поводу: глаукомы","4.5","26.112,26.118"}, ;
  {"из них: с применением шунтов и дренажей","4.5.1",""}, ;
  {"энуклеации","4.6","26.098"}, ;
  {"катаракты","4.7","26.092-26.096"}, ;
  {"из них: методом факоэмульсификации","4.7.1","26.093"}, ;
  {"интравитреальное введение ингибитора ангиогенеза","4.8","26.086"}, ;
  {"операции на органах уха, горла, носа","5","08,25,27"}, ;
  {"из них: на ухе","5.1","25"}, ;
  {"на миндалинах и аденоидах","5.2","08.016,08.002"}, ;
  {"операции на органах дыхания","6","09"}, ;
  {"из них: на трахее","6.1","09.009.005,09.014.003,09.023"}, ;
  {"пневмонэктомия","6.2","09.009.003,09.014,09.015.002,09.016.003,09.025"}, ;
  {"эксплоративная торакотомия","6.3","09.006"}, ;
  {"операции на сердце","7","10,12.004.008-12.004.009"}, ;
  {"из них на открытом сердце","7.01","10.002,10.018"}, ;
  {"из них с искусственным кровообращением","7.0.2",""}, ;
  {"коррекция врожденных пороков сердца","7.1",""}, ;
  {"коррекция приобретенных поражений клапанов сердца","7.2",""}, ;
  {"при нарушении ритма - всего","7.3","10.014"}, ;
  {"из них: имплантация кардиостимулятора","7.3.1","10.014"}, ;
  {"коррекция тахиаритмий","7.4",""}, ;
  {"из них: катетерных аблаций","7.4.1",""}, ;
  {"по поводу ишемических болезней сердца","7.5","10.031-10.032"}, ;
  {"из них: аортокоронарное шунтирование","7.5.1","10.031.008"}, ;
  {"ангиопластика коронарных артерий","7.5.2","12.004.008-12.004.009"}, ;
  {"из них со стентированием","7.5.2.1","12.004.009"}, ;
  {"операции на сосудах","8","12","12.004.008-12.004.009"}, ;
  {"из них: операции на артериях","8.1","12.001,12.003-12.005,12.008,12.026,12.048,12.049"}, ;
  {"из них на питающих головной мозг","8.1.1","12.026,12.048,12.049,12.008.001,12.008.002"}, ;
  {"из них: каротидные эндартерэктомии","8.1.1.1","12.008.001,12.008.002"}, ;
  {"экстраинтракраниальные анастемозы","8.1.1.2","12.048,12.049"}, ;
  {"рентгенэндоваскулярные дилятации","8.1.1.3","12.026"}, ;
  {"из них со стентированием","8.1.1.3.1","12.026.003-12.026.007"}, ;
  {"на почечных артериях","8.1.2","12.008.006,12.011.003,12.011.007,12.054.002"}, ;
  {"на аорте","8.1.3","12.008.005,12.011.002,12.011.004,12.025,12.044,12.055.001,12.056"}, ;
  {"операции на венах","8.2","12.002,12.006,12.012,12.015,12.016,12.027,12.035,12.036,12.039,12.040"}, ;
  {"операции на органах брюшной полости","9","14,15,16,17,18,19,30.001-30.013","16.001-16.009,16.012"}, ;
  {"из них: на желудке по поводу язвенной болезни","9.1","16.013,16.021"}, ;
  {"аппендэктомии при хроническом аппендиците","9.2","18.009-18.010"}, ;
  {"грыжеиссечение при неущемленной грыже","9.3","30.001-30.005"}, ;
  {"холецистэктомия при хроническом холецистите","9.4","14.006"}, ;
  {"лапаротомия диагностическая","9.5","30.006.002"}, ;
  {"на кишечнике","9.6","17,18,19,30.013"}, ;
  {"из них: на прямой кишке","9.6.1","19","19.013,19.016"}, ;
  {"по поводу геморроя","9.7","19.013,19.016"}, ;
  {"операции на почках и мочеточниках","10","28"}, ;
  {"операции на мужских половых органах","11","21","21.026"}, ;
  {"из них операции на предстательной железе","11.1","21.001-21.006"}, ;
  {"операции по поводу стерилизации мужчин","12","21.026"}, ;
  {"операции на женских половых органах","13","20.001-20.069","20.031,20.032,20.037"}, ;
  {"из них: экстирпация и надвлагалищная ампутация матки","13.1","20.010-20.014,20.063"}, ;
  {"на придатках матки по поводу бесплодия","13.2","20.038"}, ;
  {"на яичниках по поводу новообразований","13.3","20.001"}, ;
  {"по поводу стерилизации женщин","13.4","20.041"}, ;
  {"выскабливание матки (кроме аборта)","13.5",""}, ;
  {"акушерские операции","14","20.070-20.083,20.037"}, ;
  {"из них: по поводу внематочной беременности","14.1",""}, ;
  {"наложение щипцов","14.2","20.070"}, ;
  {"вакуум-экстракция","14.3","20.071"}, ;
  {"кесарево сечение в сроке 22 недель беременности и более","14.4",""}, ;
  {"кесарево сечение в сроке менее 22 недель беременности","14.5",""}, ;
  {"аборт","14.6","20.037"}, ;
  {"плодоразрушающие","14.7","20.072"}, ;
  {"экстирпация и надвлагалищная ампутация матки в сроке 22 недель беременности и более, в родах и после родов","14.8",""}, ;
  {"экстирпация и надвлагалищная ампутация матки при прерывании беременности в сроке менее 22 недель беременности или после прерывания","14.9",""}, ;
  {"операции на костно-мышечной системе","15","02,03,04"}, ;
  {"из них: корригирующие остеотомии","15.1","03.024.001"}, ;
  {"на челюстно-лицевой области","15.2","03.053-03.057"}, ;
  {"при травмах костей таза","15.3","03.024.002,03.068,03.070,03.071"}, ;
  {"при около- и внутрисуставных переломах","15.4","03.026.001,04.004.001"}, ;
  {"на позвоночнике","15.5","04.007,04.010,04.029-04.032"}, ;
  {"при врожденном вывихе бедра","15.6",""}, ;
  {"ампутации и экзартикуляции","15.7","03.071,03.078,03.082,04.023"}, ;
  {"эндопротезирование, всего","15.8","03.063.003-03.063.006,03.064.003-03.064.005,04.021,04.026,04.027"}, ;
  {"из него: тазобедренного сустава","15.8.1","03.063.003-03.063.004"}, ;
  {"коленного сустава","15.8.2","03.063.005-03.063.006"}, ;
  {"на грудной стенке","15.9","03.044"}, ;
  {"из них: торакомиопластика","15.9.1","03.044"}, ;
  {"торакостомия","15.9.2",""}, ;
  {"операции на молочной железе","16","20.031,20.032"}, ;
  {"операции на коже и подкожной клетчатке","17","01"}, ;
  {"из них: операции на челюстно-лицевой области","17.1","01.031.002,01.031.003"}, ;
  {"операции на средостении","18","11"}, ;
  {"из них операции на вилочковой железе","18.1",""}, ;
  {"операции на пищеводе","19","16.001-16.009,16.012"}, ;
  {"операции на лимфатической системе","20","13"}, ;
  {"прочие операции","21","30"};
}
return arr

*

*****
Function f14_title()
Local arr := array(10)
arr[ 1] := replicate("─",len_name)
arr[ 2] := padc("",len_name)
arr[ 3] := padc("",len_name)
arr[ 4] := padc("",len_name)
arr[ 5] := padc("Наименование болезни",len_name)
arr[ 6] := padc("",len_name)
arr[ 7] := padc("",len_name)
arr[ 8] := replicate("─",len_name)
arr[ 9] := padc("1",len_name)
arr[10] := replicate("─",len_name)
arr[ 1] := arr[ 1] + "┬─────────┬────────────┬"
arr[ 2] := arr[ 2] + "│         │            │"
arr[ 3] := arr[ 3] + "│    №    │   Код по   ├"
arr[ 4] := arr[ 4] + "│  строки │   МКБ-10   │"
arr[ 5] := arr[ 5] + "│         │ пересмотра ├"
arr[ 6] := arr[ 6] + "│         │            │"
arr[ 7] := arr[ 7] + "│         │            │"
arr[ 8] := arr[ 8] + "┼─────────┼────────────┼"
arr[ 9] := arr[ 9] + "│    2    │      3     │"
arr[10] := arr[10] + "┴─────────┴────────────┴"
if x == 1
  arr[ 1] := arr[ 1] + "──────────────────────────────────────────────"
  arr[ 2] := arr[ 2] + "          А.Взрослые (18 лет и старше)"
  arr[ 3] := arr[ 3] + "────────────────────┬───────┬─────────────────"
  arr[ 4] := arr[ 4] + "  Выписано больных  │Провед.│ Умерло больных"
  arr[ 5] := arr[ 5] + "──────┬──────┬──────┤выписан├───┬───┬───┬──┬──"
  arr[ 6] := arr[ 6] + "Всего │достав│достав│койко- │все│пат│уст│см│ус"
  arr[ 7] := arr[ 7] + "      │экстре│скорой│дней   │го │вск│рас│вс│ра"
  arr[ 8] := arr[ 8] + "──────┼──────┼──────┼───────┼───┼───┼───┼──┼──"
  arr[ 9] := arr[ 9] + "  4   │  5   │  6   │   7   │ 8 │ 9 │10 │11│12"
  arr[10] := arr[10] + "──────┴──────┴──────┴───────┴───┴───┴───┴──┴──"
elseif x == 2
  arr[ 1] := arr[ 1] + "──────────────────────────────────────────────"
  arr[ 2] := arr[ 2] + "Б.Взрослые старше трудоспособного возрста     "
  arr[ 3] := arr[ 3] + "────────────────────┬───────┬─────────────────"
  arr[ 4] := arr[ 4] + "  Выписано больных  │Провед.│ Умерло больных"
  arr[ 5] := arr[ 5] + "──────┬──────┬──────┤выписан├───┬───┬───┬──┬──"
  arr[ 6] := arr[ 6] + "Всего │достав│достав│койко- │все│пат│уст│см│ус"
  arr[ 7] := arr[ 7] + "      │экстре│скорой│дней   │го │вск│рас│вс│ра"
  arr[ 8] := arr[ 8] + "──────┼──────┼──────┼───────┼───┼───┼───┼──┼──"
  arr[ 9] := arr[ 9] + "  13  │  14  │  15  │   16  │17 │18 │19 │20│21"
  arr[10] := arr[10] + "──────┴──────┴──────┴───────┴───┴───┴───┴──┴──"
elseif x == 3
  arr[ 1] := arr[ 1] + "────────────────────────────────────────────────────────────────"
  arr[ 2] := arr[ 2] + "            В.Дети (в возрасте 0-17 лет включительно)"
  arr[ 3] := arr[ 3] + "───────────────────────────┬───────┬──────┬─────────────────────"
  arr[ 4] := arr[ 4] + "      Выписано больных     │Провед.│из них│   Умерло больных    "
  arr[ 5] := arr[ 5] + "──────┬──────┬──────┬──────┤выписан┤в воз-├───┬───┬───┬──┬──┬───"
  arr[ 6] := arr[ 6] + "Всего │достав│достав│из них│койко- │расте │все│пат│уст│см│ус│до "
  arr[ 7] := arr[ 7] + "      │экстре│скорой│до 1г.│дней   │до 1 г│го │вск│рас│вс│ра│1г."
  arr[ 8] := arr[ 8] + "──────┼──────┼──────┼──────┼───────┼──────┼───┼───┼───┼──┼──┼───"
  arr[ 9] := arr[ 9] + "  22  │  23  │  24  │  25  │   26  │  27  │28 │29 │30 │31│32│33 "
  arr[10] := arr[10] + "──────┴──────┴──────┴──────┴───────┴──────┴───┴───┴───┴──┴──┴───"
endif
return arr

** 14.03.23
Function ret_kd_f14()
  Local lshifr, mkol := 0, i
  local arrShifr := {'1.12.', '1.13.', '1.14.', '1.15.', '1.16.', '1.17.', '1.18.'}

  for i := 2020 to WORK_YEAR
    aadd(arrShifr, code_services_VMP(i))
  next

  if empty(lshifr := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data))
    lshifr := usl->shifr
  endif
  if eq_any(left(lshifr, 4), '1.7.', '1.9.') .or. left(lshifr, 5) == '1.10.' // законченный случай
    mkol := human->k_data - human->n_data
  elseif left(lshifr, 2) == '1.'  // остальные койко-дни
    // if !eq_any(left(lshifr, 5), '1.12.', '1.13.', '1.14.', '1.15.', '1.16.*', '1.17.*', '1.18.*', '1.20.*', '1.21.*', '1.22.*')  // 11.02.22
    if ascan(arrShifr, left(lshifr, 5)) == 0
      mkol := hu->kol
    endif
  endif
  return mkol

***** 14.04.21
Function f1_f14(jh,jh1,is_diag)
Local arr := {}, arr_d := {}, i, j, k, n, lkd := 0, lum, _kd, arr_tip, ;
      M1F14_EKST := 0, M1F14_SKOR := 0, M1F14_VSKR := 0, M1F14_RASH := 0, ;
      mdiag, nkd, mvozrast, mmonth, mday, arr_oper := {}, fl_death := .f., ;
      fl_pensioner := .f., flag_vmp := .f.
if human_->NOVOR > 0
  count_ymd(human_->DATE_R2,human->n_data,@mvozrast,@mmonth,@mday)
else
  count_ymd(human->date_r,human->n_data,@mvozrast,@mmonth,@mday)
endif
if mvozrast < 18
  arr_tip := {3}
else
  arr_tip := {1}
  if human->n_data < stod('20200101') 
    if (human->pol == "Ж" .and. mvozrast >= 55) .or. ;
       (human->pol == "М" .and. mvozrast >= 60)
       fl_pensioner := .t.
      aadd(arr_tip,2)
    endif
  elseif human->n_data < stod('20220101') 
    if (human->pol == "Ж" .and. mvozrast >= 56) .or. ;
      (human->pol == "М" .and. mvozrast >= 61)
      fl_pensioner := .t.
     aadd(arr_tip,2)
   endif
  elseif human->n_data < stod('20240101') 
    if (human->pol == "Ж" .and. mvozrast >= 57) .or. ;
      (human->pol == "М" .and. mvozrast >= 62)
      fl_pensioner := .t.
     aadd(arr_tip,2)
   endif
  elseif human->n_data < stod('20260101') 
    if (human->pol == "Ж" .and. mvozrast >= 58) .or. ;
      (human->pol == "М" .and. mvozrast >= 63)
      fl_pensioner := .t.
     aadd(arr_tip,2)
   endif
  else 
    if (human->pol == "Ж" .and. mvozrast >= 59) .or. ;
      (human->pol == "М" .and. mvozrast >= 64)
      fl_pensioner := .t.
     aadd(arr_tip,2)
   endif
  endif
endif
M1F14_EKST := int(val(substr(human_->FORMA14,1,1)))
M1F14_SKOR := int(val(substr(human_->FORMA14,2,1)))
M1F14_VSKR := int(val(substr(human_->FORMA14,3,1)))
M1F14_RASH := int(val(substr(human_->FORMA14,4,1)))
arr := diag_to_array(,,,,.t.)
if len(arr) == 0
  return jh
endif
mdiag := padr(arr[1],6) // только основной диагноз
if human_2->VMP == 1 // если установили ВМП
  flag_vmp := .t.
endif
lkd := 0
select HU
find (str(human->kod,7))
do while hu->kod == human->kod .and. !eof()
  if (_kd := ret_kd_f14()) > 0  // проверим все койко-дни
    lkd += _kd
  endif
  skip
enddo
if (nkd := lkd) > 0
  if select("MOHU") == 0
    R_Use(dir_server+"mo_su",,"MOSU")
    R_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
    set relation to u_kod into MOSU
  endif
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    if left(mosu->shifr1,4) == "A16."
      aadd(arr_oper, {alltrim(mosu->shifr1),mohu->kol_1,left(mohu->kod_diag,1)})
    endif
    skip
  enddo
endif
if nkd > 0 .and. (k := ret_f_14(mdiag)) != NIL
  aadd(arr_d, mdiag)
  if len(k) > 0
    fl_perevod := .f. ; lv := 1 ; lum := 0 ; ++jh1
    if eq_any(human_->RSLT_NEW,102,202) // исход - перевод в другое ЛПУ
      fl_perevod := .t.
    elseif is_death(human_->RSLT_NEW) // смерть
      fl_death := .t.
      lum := 1 ; lv := 0 ; lkd := 0 // если умер, то койко-дни не учитывать
    endif
    if fl_perevod .and. !yes_perevod
      if mvozrast >= 18
        arr_perevod[4] += lv
        arr_perevod[5] += lkd
        arr_perevod[6] += lum
      else
        arr_perevod[7]  += lv
        arr_perevod[9]  += lkd
        arr_perevod[10] += lum
        if mvozrast < 1
          arr_perevod[8]  += lv
          arr_perevod[11] += lum
        endif
      endif
    else
      for x := 1 to len(arr_tip)
        for j := 1 to len(k)
          select TMP_TAB
          find (str(arr_tip[x],1)+padr(k[j,1],9))
          tmp_tab->p_boln += lv
          if M1F14_EKST == 1
            tmp_tab->p_ekst += lv
            if M1F14_SKOR == 1
              tmp_tab->p_skor += lv
            endif
          endif
          tmp_tab->p_kd   += lkd
          tmp_tab->p_umer += lum
          if M1F14_VSKR == 1
            tmp_tab->p_vskr += lum
            if M1F14_RASH == 1
              tmp_tab->p_rash += lum
            endif
          endif
          if mvozrast < 1 // до 1 года
            tmp_tab->p_bdo1 += lv
            tmp_tab->p_kd1  += lkd
            tmp_tab->p_udo1 += lum
          endif
        next
      next
      if is_diag
        for x := 1 to len(arr_tip)
          select TMP_D
          find (str(arr_tip[x],1)+mdiag)
          if !found()
            append blank
            tmp_d->tip := arr_tip[x]
            tmp_d->diagnoz := mdiag
            if (j := ascan(k, {|y| n := alltrim(y[1]), (!(n=="1.0") .and. right(n,2)==".0")} )) > 0
              tmp_d->stroke := padr(k[j,1],9)
            endif
          endif
          tmp_d->p_boln += lv
          if M1F14_EKST == 1
            tmp_d->p_ekst += lv
            if M1F14_SKOR == 1
              tmp_d->p_skor += lv
            endif
          endif
          tmp_d->p_kd   += lkd
          tmp_d->p_umer += lum
          if M1F14_VSKR == 1
            tmp_d->p_vskr += lum
            if M1F14_RASH == 1
              tmp_d->p_rash += lum
            endif
          endif
          if mvozrast < 1
            tmp_d->p_bdo1 += lv
            tmp_d->p_kd1  += lkd
            tmp_d->p_udo1 += lum
          endif
        next
      endif
    endif
  endif
endif
// врезка таблица 2910
if nkd > 0 
  k := ret_f_14_2910(mdiag)
  for j := 1 to len(k)
    select TMP_2910
    find (padr(k[j,1],9))
    if found()
    if is_death(human_->RSLT_NEW) // смерть
      lum := 1
      lvip := 0
    else
      lum := 0
      lvip := 1
    endif    
    if mvozrast <= 14 
      tmp_2910->umer_0_14 += lum
      tmp_2910->vip_0_14  += lvip 
    elseif 15 <= mvozrast .and. mvozrast <= 19 
      tmp_2910->umer_15_19 += lum
      tmp_2910->vip_15_19  += lvip 
    elseif 20 <= mvozrast .and. mvozrast <= 24   
      tmp_2910->umer_20_24 += lum
      tmp_2910->vip_20_24  += lvip 
    elseif 25 <= mvozrast .and. mvozrast <= 29 
      tmp_2910->umer_25_29 += lum
      tmp_2910->vip_25_29  += lvip 
    elseif 30 <= mvozrast .and. mvozrast <= 34 
      tmp_2910->umer_30_34 += lum
      tmp_2910->vip_30_34  += lvip 
    elseif 35 <= mvozrast .and. mvozrast <= 39 
      tmp_2910->umer_35_39 += lum
      tmp_2910->vip_35_39  += lvip 
    elseif 40 <= mvozrast .and. mvozrast <= 44 
      tmp_2910->umer_40_44 += lum
      tmp_2910->vip_40_44  += lvip 
    elseif 45 <= mvozrast .and. mvozrast <= 29 
      tmp_2910->umer_45_49 += lum
      tmp_2910->vip_45_49  += lvip 
    elseif 50 <= mvozrast .and. mvozrast <= 54 
      tmp_2910->umer_50_54 += lum
      tmp_2910->vip_50_54  += lvip 
    elseif 55 <= mvozrast .and. mvozrast <= 59 
      tmp_2910->umer_55_59 += lum
      tmp_2910->vip_55_59  += lvip 
    elseif 60 <= mvozrast .and. mvozrast <= 64 
      tmp_2910->umer_60_64 += lum
      tmp_2910->vip_60_64  += lvip 
    elseif 65 <= mvozrast .and. mvozrast <= 69 
      tmp_2910->umer_65_69 += lum
      tmp_2910->vip_65_69  += lvip 
    elseif 70 <= mvozrast .and. mvozrast <= 74 
      tmp_2910->umer_70_74 += lum
      tmp_2910->vip_70_74  += lvip 
    elseif 75 <= mvozrast .and. mvozrast <= 79 
      tmp_2910->umer_75_79 += lum
      tmp_2910->vip_75_79  += lvip 
    elseif 80 <= mvozrast .and. mvozrast <= 84 
      tmp_2910->umer_80_84 += lum
      tmp_2910->vip_80_84  += lvip 
    else //if 20 <= mvozrast .and. mvozrast <= 24 
      tmp_2910->umer_85_99 += lum    
      tmp_2910->vip_85_99  += lvip  
    endif
  endif
  next
  if is_diag
    select TMP_D3
    find (mdiag)
    if !found()
      append blank
      tmp_d5->diagnoz := mdiag
      if (j := ascan(k,{|y|eq_any(alltrim(y[1]),'2','3','4','5','6','7')})) > 0
        tmp_d5->stroke := padr(k[j,1],9)
      endif
    endif
    //
    //
    //
    if is_death(human_->RSLT_NEW) // смерть
      lum := 1
      lvip := 0
    else
      lum := 0
      lvip := 1
    endif    
    if mvozrast <= 14 
      tmp_d5->umer_0_14 += lum
      tmp_d5->vip_0_14  += lvip 
    elseif 15 <= mvozrast .and. mvozrast <= 19 
      tmp_d5->umer_15_19 += lum
      tmp_d5->vip_15_19  += lvip 
    elseif 20 <= mvozrast .and. mvozrast <= 24   
      tmp_d5->umer_20_24 += lum
      tmp_d5->vip_20_24  += lvip 
    elseif 25 <= mvozrast .and. mvozrast <= 29 
      tmp_d5->umer_25_29 += lum
      tmp_2910->vip_25_29  += lvip 
    elseif 30 <= mvozrast .and. mvozrast <= 34 
      tmp_d5->umer_30_34 += lum
      tmp_d5->vip_30_34  += lvip 
    elseif 35 <= mvozrast .and. mvozrast <= 39 
      tmp_d5->umer_35_39 += lum
      tmp_d5->vip_35_39  += lvip 
    elseif 40 <= mvozrast .and. mvozrast <= 44 
      tmp_d5->umer_40_44 += lum
      tmp_d5->vip_40_44  += lvip 
    elseif 45 <= mvozrast .and. mvozrast <= 29 
      tmp_d5->umer_45_49 += lum
      tmp_d5->vip_45_49  += lvip 
    elseif 50 <= mvozrast .and. mvozrast <= 54 
      tmp_d5->umer_50_54 += lum
      tmp_d5->vip_50_54  += lvip 
    elseif 55 <= mvozrast .and. mvozrast <= 59 
      tmp_d5->umer_55_59 += lum
      tmp_d5->vip_55_59  += lvip 
    elseif 60 <= mvozrast .and. mvozrast <= 64 
      tmp_d5->umer_60_64 += lum
      tmp_d5->vip_60_64  += lvip 
    elseif 65 <= mvozrast .and. mvozrast <= 69 
      tmp_d5->umer_65_69 += lum
      tmp_d5->vip_65_69  += lvip 
    elseif 70 <= mvozrast .and. mvozrast <= 74 
      tmp_d5->umer_70_74 += lum
      tmp_d5->vip_70_74  += lvip 
    elseif 75 <= mvozrast .and. mvozrast <= 79 
      tmp_d5->umer_75_79 += lum
      tmp_d5->vip_75_79  += lvip 
    elseif 80 <= mvozrast .and. mvozrast <= 84 
      tmp_d5->umer_80_84 += lum
      tmp_d5->vip_80_84  += lvip 
    else //if 20 <= mvozrast .and. mvozrast <= 24 
      tmp_d5->umer_85_99 += lum    
      tmp_d5->vip_85_99  += lvip  
    endif
  endif
  aadd(arr_d, mdiag)
endif
//
// конец врезки 2910
// проверяем таблицу 3000 (новорожденных)
if nkd > 0 .and. human_->NOVOR > 0 .and. mvozrast == 0 .and. mmonth == 0 .and. mday <= 6
  k := ret_f_14_3000(mdiag)
  //my_debug(,"3000 "+print_array(k))
  for j := 1 to len(k)
    select TMP_3000
    find (padr(k[j,1],9))
    //my_debug(,"3000 "+padr(k[j,1],9))
    if human_2->VNR < 1000
      tmp_3000->p_boln ++
      if fl_death
        tmp_3000->p_umer ++
        if nkd <= 6
          tmp_3000->p_umer6 ++
        endif
      endif
    else
      tmp_3000->p1boln ++
      if fl_death
        tmp_3000->p1umer ++
        if nkd <= 6
          tmp_3000->p1umer6 ++
        endif
      endif
    endif
  next
  if is_diag
    select TMP_D3
    find (mdiag)
    if !found()
      append blank
      tmp_d3->diagnoz := mdiag
      if (j := ascan(k,{|y|eq_any(alltrim(y[1]),'2','3','4','5','6','7')})) > 0
        tmp_d3->stroke := padr(k[j,1],9)
      endif
    endif
    if human_2->VNR < 1000
      tmp_d3->p_boln ++
      if fl_death
        tmp_d3->p_umer ++
        if nkd <= 6
          tmp_d3->p_umer6 ++
        endif
      endif
    else
      tmp_d3->p1boln ++
      if fl_death
        tmp_d3->p1umer ++
        if nkd <= 6
          tmp_d3->p1umer6 ++
        endif
      endif
    endif
  endif
  aadd(arr_d, mdiag)
endif
// проверяем таблицу 4000 (операции)
if len(arr_oper) > 0
  for i := 1 to len(arr_oper)
    k := ret_f_14_4000(arr_oper[i,1])
    for j := 1 to len(k)
      select TMP_4000
      find (padr(k[j,1],9))
      tmp_4000->p_boln += arr_oper[i,2]
      if mvozrast <= 14
        tmp_4000->p_boln1 += arr_oper[i,2]
        if mvozrast < 1
          tmp_4000->p_boln2 += arr_oper[i,2]
        endif
      elseif mvozrast < 18
        tmp_4000->p_boln3 += arr_oper[i,2]
      elseif fl_pensioner
        tmp_4000->p_boln4 += arr_oper[i,2]
      endif
      if fl_death .and. i == 1
        tmp_4000->p_umer += arr_oper[i,2]
        if mvozrast <= 14
          tmp_4000->p_umer1 += arr_oper[i,2]
          if mvozrast < 1
            tmp_4000->p_umer2 += arr_oper[i,2]
          endif
        elseif mvozrast < 18
          tmp_4000->p_umer3 += arr_oper[i,2]
        elseif fl_pensioner
          tmp_4000->p_umer4 += arr_oper[i,2]
        endif
      endif
      if arr_oper[i,3] == "C"
        tmp_4000->p_onko += arr_oper[i,2]
      endif
      if flag_vmp
        yes_vmp := .t.
        tmp_4000->_p_boln += arr_oper[i,2]
        if mvozrast <= 14
          tmp_4000->_p_boln1 += arr_oper[i,2]
          if mvozrast < 1
            tmp_4000->_p_boln2 += arr_oper[i,2]
          endif
        elseif mvozrast < 18
          tmp_4000->_p_boln3 += arr_oper[i,2]
        elseif fl_pensioner
          tmp_4000->_p_boln4 += arr_oper[i,2]
        endif
        if fl_death .and. i == 1
          tmp_4000->_p_umer += arr_oper[i,2]
          if mvozrast <= 14
            tmp_4000->_p_umer1 += arr_oper[i,2]
            if mvozrast < 1
              tmp_4000->_p_umer2 += arr_oper[i,2]
            endif
          elseif mvozrast < 18
            tmp_4000->_p_umer3 += arr_oper[i,2]
          elseif fl_pensioner
            tmp_4000->_p_umer4 += arr_oper[i,2]
          endif
        endif
      endif
    next
    if is_diag
      select TMP_D4
      find (padr(arr_oper[i,1],14))
      if !found()
        append blank
        tmp_d4->shifr := arr_oper[i,1]
        if (j := ascan(k, {|y| n:=alltrim(y[1]), !(n=="1" .or. "."$n)} )) > 0
          tmp_d4->stroke := padr(k[j,1],9)
        endif
      endif
      tmp_d4->p_boln += arr_oper[i,2]
      if mvozrast <= 14
        tmp_d4->p_boln1 += arr_oper[i,2]
        if mvozrast < 1
          tmp_d4->p_boln2 += arr_oper[i,2]
        endif
      elseif mvozrast < 18
        tmp_d4->p_boln3 += arr_oper[i,2]
      elseif fl_pensioner
        tmp_d4->p_boln4 += arr_oper[i,2]
      endif
      if fl_death .and. i == 1
        tmp_d4->p_umer += arr_oper[i,2]
        if mvozrast <= 14
          tmp_d4->p_umer1 += arr_oper[i,2]
          if mvozrast < 1
            tmp_d4->p_umer2 += arr_oper[i,2]
          endif
        elseif mvozrast < 18
          tmp_d4->p_umer3 += arr_oper[i,2]
        elseif fl_pensioner
          tmp_d4->p_umer4 += arr_oper[i,2]
        endif
      endif
      if arr_oper[i,3] == "C"
        tmp_d4->p_onko += arr_oper[i,2]
      endif
      if flag_vmp
        tmp_d4->_p_boln += arr_oper[i,2]
        if mvozrast <= 14
          tmp_d4->_p_boln1 += arr_oper[i,2]
          if mvozrast < 1
            tmp_d4->_p_boln2 += arr_oper[i,2]
          endif
        elseif mvozrast < 18
          tmp_d4->_p_boln3 += arr_oper[i,2]
        elseif fl_pensioner
          tmp_d4->_p_boln4 += arr_oper[i,2]
        endif
        if fl_death .and. i == 1
          tmp_d4->_p_umer += arr_oper[i,2]
          if mvozrast <= 14
            tmp_d4->_p_umer1 += arr_oper[i,2]
            if mvozrast < 1
              tmp_d4->_p_umer2 += arr_oper[i,2]
            endif
          elseif mvozrast < 18
            tmp_d4->_p_umer3 += arr_oper[i,2]
          elseif fl_pensioner
            tmp_d4->_p_umer4 += arr_oper[i,2]
          endif
        endif
      endif
    endif
  next
  aadd(arr_d, mdiag)
endif
if len(arr_d) > 0
  ++jh
endif
return jh

*

*****
Function ret_f_14(lshifr)
Local ret := {}, i, j, d, r
d := diag_to_num(lshifr,1)
for i := 1 to len_diag
  r := diag1[i,2]
  for j := 1 to len(r)
    if between(d,r[j,1],r[j,2])
      aadd(ret, {diag1[i,1],diag1[i,2]})
      exit
    endif
  next
next
if len(ret) == 0 ; ret := NIL ; endif
return ret

***** 16.01.23
Function ret_f_14_2910(lshifr)
  Local ret := {}, i, j, d, r
  //aadd(ret,{'1',{}})
  d := diag_to_num(lshifr,1)
  for i := 1 to len_diag_2910
    r := diag1_2910[i,2]
    for j := 1 to len(r)
      if between(d,r[j,1],r[j,2])
        aadd(ret, {diag1_2910[i,1],diag1_2910[i,2]})
        exit
      endif
    next
  next
 // if len(ret) == 1
 //   aadd(ret,{'7',{}})
 // endif
  return ret

***** 08.01.13
Function ret_f_14_3000(lshifr)
Local ret := {}, i, j, d, r
aadd(ret,{'1',{}})
d := diag_to_num(lshifr,1)
for i := 1 to len_diag_3000
  r := diag1_3000[i,2]
  for j := 1 to len(r)
    if between(d,r[j,1],r[j,2])
      aadd(ret, {diag1_3000[i,1],diag1_3000[i,2]})
      exit
    endif
  next
next
if len(ret) == 1
  aadd(ret,{'8',{}})
endif
return ret

***** 11.01.14
Function ret_f_14_4000(lshifr)
Local ret := {}, i, j, d, r, fl
aadd(ret,{'1',{}})
if len(lshifr) == 10
  lshifr += ".000"
endif
for i := 1 to len_usl_4000
  fl := .t.
  if !empty(r := usl1_4000[i,3]) // сначала проверим исключающие диапазоны
    for j := 1 to len(r)
      if between(lshifr,r[j,1],r[j,2])
        fl := .f.
        exit
      endif
    next
  endif
  if fl
    r := usl1_4000[i,2] // а теперь - включающие диапазоны
    for j := 1 to len(r)
      if between(lshifr,r[j,1],r[j,2])
        aadd(ret, {usl1_4000[i,1],usl1_4000[i,2]})
        exit
      endif
    next
  endif
next
if len(ret) == 1
  aadd(ret,{'20',{}})
endif
return ret

*****
Function usl_to_ffoms(lshifr,k)
Local l := len(lshifr)
if !eq_any(l,2,6,10)
  func_error(4,"Неверный шифр услуги "+lshifr)
endif
do while l < 10
  if k == 1
    lshifr += ".000"
  else
    lshifr += ".999"
  endif
  l := len(lshifr)
enddo
return "A16."+lshifr

*

***** 12.02.13
Function forma_14ds(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j, uch_otd
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Распечатка ~формы 14дс", ;
                "Форма 14дс + ~диагнозы", ;
                "~Отделение + форма 14дс"}
    mas_msg := {"Распечатка формы № 14дс", ;
                "Распечатка аналога формы 14дс с уточнением диагнозов", ;
                "Распечатка аналога формы 14дс с диагнозами по конкретному отделению"}
    mas_fun := {"forma_14ds(11)", ;
                "forma_14ds(12)", ;
                "forma_14ds(13)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    f1_frm14ds(.f.,.f.)
  case k == 12
    f1_frm14ds(.t.,.f.)
  case k == 13
    f1_frm14ds(.t.,.t.)
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
Function f1_frm14ds(is_diag,is_otd)
Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
      fl_exit := .f., sh, HH := 80, reg_print, speriod, ;
      arr_title, name_file, t_arr1[2], ;
      jh := 0, jh1 := 0, arr_m, nf, file_form
name_file := iif(is_diag, "_fr14dsd", "_frm14ds")+stxt
Private len_name := 28
if is_otd
  st_a_uchast := {}
  if input_uch(T_ROW,T_COL-5,sys_date) == NIL .or. ;
                     input_otd(T_ROW,T_COL-5,sys_date) == NIL
    return NIL
  endif
else
  if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
    return NIL
  endif
  if (st_a_uchast := ret_uchast(T_ROW,T_COL-5)) == NIL
    return NIL
  endif
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
speriod := arr_m[4]
//
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
adbf := {{"stroke","N",2,0}, ;
         {"tip"   ,"N",1,0}, ;
         {"p1boln","N",7,0}, ;
         {"p1stac","N",7,0}, ;
         {"p1kd"  ,"N",9,0}, ;
         {"p1umer","N",7,0}, ;
         {"p2boln","N",7,0}, ;
         {"p2stac","N",7,0}, ;
         {"p2kd"  ,"N",9,0}, ;
         {"p2umer","N",7,0}, ;
         {"p3boln","N",7,0}, ;
         {"p3stac","N",7,0}, ;
         {"p3kd"  ,"N",9,0}, ;
         {"p3umer","N",7,0}}
//
dbcreate(cur_dir+"tmp_tab",adbf)
use (cur_dir+"tmp_tab") new alias TMP_TAB
index on str(tip,1)+str(stroke,2) to (cur_dir+"tmp_tab")
//
Private diag1 := {}, len_diag, arr_frm14 := f14ds_arr()
for s1 := 1 to len(arr_frm14)
  if iif(is_diag, ("-" $ arr_frm14[s1,1]), .t.)
    s2 := arr_frm14[s1,1]
/*for i := 1 to len(s2) // проверка на русские буквы в диагнозах
  if ISRALPHA(substr(s2,i,1))
    strfile(s2+eos,"ttt.ttt",.t.)
    exit
  endif
next*/
    diapazon := {}
    if "-" $ s2
      d1 := token(s2,"-",1)
      d2 := token(s2,"-",2)
    else
      d1 := d2 := s2
    endif
    aadd(diapazon, {diag_to_num(d1,1),diag_to_num(d2,2)} )
    select TMP_TAB
    for i := 1 to 2
      append blank
      tmp_tab->tip := i
      tmp_tab->stroke := s1
    next
    aadd(diag1, {s1,diapazon})
  endif
next
len_diag := len(diag1)
//
if is_diag
  aadd(adbf,{"diagnoz","C",5,0})
  dbcreate(cur_dir+"tmp_dia",adbf)
  use (cur_dir+"tmp_dia") new alias TMP_D
  index on str(tip,1)+diagnoz to (cur_dir+"tmp_dia")
endif
// по дате окончания лечения
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to u_kod into USL
R_Use(dir_server+"kartotek",,"KART")
if pi1 == 1 // по дате окончания лечения
  begin_date := arr_m[5]
  end_date := arr_m[6]
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to kod_k into KART, to recno() into HUMAN_
  dbseek(dtos(begin_date),.t.)
  do while human->k_data <= end_date .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if human_->usl_ok == 2 .and. human_->oplata < 9 .and. ;
       iif(is_otd, (human->otd == glob_otd[1]), f_is_uch(st_a_uch,human->lpu)) ;
       .and. func_pi_schet() .and. f_is_uchast(st_a_uchast,kart->uchast)
      jh := f1_f14ds(jh,@jh1,is_diag)
      @ maxrow(),1 say lstr(jh) color cColorSt2Msg
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jh1) color cColorStMsg
      date_24(human->k_data)
    endif
    select HUMAN
    skip
  enddo
else
  begin_date := arr_m[7]
  end_date := arr_m[8]
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humans","HUMAN")
  set relation to kod_k into KART, to recno() into HUMAN_
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
  set relation to recno() into SCHET_
  set filter to empty(schet_->IS_DOPLATA)
  dbseek(begin_date,.t.)
  do while schet->pdate <= end_date .and. !eof()
    date_24(c4tod(schet->pdate))
    select HUMAN
    find (str(schet->kod,6))
    do while human->schet == schet->kod .and. !eof()
      if human_->usl_ok == 2 .and. human_->oplata < 9 .and. ;
         iif(is_otd, (human->otd == glob_otd[1]), f_is_uch(st_a_uch,human->lpu)) ;
         .and. f_is_uchast(st_a_uchast,kart->uchast)
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        jh := f1_f14ds(jh,@jh1,is_diag)
        @ maxrow(),1 say lstr(jh) color cColorSt2Msg
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jh1) color cColorStMsg
      endif
      select HUMAN
      skip
    enddo
    if fl_exit
      exit
    endif
    select SCHET
    skip
  enddo
endif
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
//
mywait()
reg_print := 6
Private x := 1
arr_title := f14dstitle()
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(padr(org->name,60)+padl("Форма № 14дс",sh-60))
add_string(padl("Утверждена Приказом",sh))
add_string(padl("Минздрава России",sh))
add_string(padl("от 30.12.2002 № 413",sh))
add_string(center("СВЕДЕНИЯ О ДЕЯТЕЛЬНОСТИ ДНЕВНЫХ СТАЦИОНАРОВ ЛЕЧЕБНО-ПРОФИЛАКТИЧЕСКОГО УЧРЕЖДЕНИЯ",sh))
if is_otd
  add_string(center(alltrim(glob_otd[2]),sh))
else
  titleN_uch(st_a_uch,sh,lcount_uch)
  title_uchast(st_a_uchast,sh)
endif
add_string("")
add_string(center(speriod,sh))
if pi1 == 1
  add_string(center(str_pi_schet(),sh))
else
  add_string(center("[ по дате выписки счета ]",sh))
endif
add_string("")
//
if is_diag
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB10")
  use (cur_dir+"tmp_dia") new alias TMP_D
  index on str(tip,1)+str(stroke,2)+diagnoz to (cur_dir+"tmp_dia")
endif
use (cur_dir+"tmp_tab") index (cur_dir+"tmp_tab") new alias TMP
for x := 1 to 2
  s2 := "СОСТАВ БОЛЬНЫХ В ДНЕВНОМ СТАЦИОНАРЕ, СРОКИ И ИСХОДЫ ЛЕЧЕНИЯ"
  if x == 1
    add_string(center("РАЗДЕЛ II. "+s2,sh))
    add_string(" (2000)"+padl("(18 лет и старше)",sh-8))
  else // искусственный перевод страницы
    tek_stroke := HH+10
    verify_FF(HH,.t.,sh)
    add_string(center(s2,sh))
    add_string(" (2003)"+padl("(дети 0-17 лет включительно)",sh-8))
  endif
  aeval(arr_title, {|x| add_string(x) } )
  for s1 := 1 to len(arr_frm14)
    if iif(is_diag, ("-" $ arr_frm14[s1,1]), .t.)
      s2 := arr_frm14[s1,1]  // диагнозы
      s3 := arr_frm14[s1,2]
      select TMP
      find (str(x,1)+str(s1,2))
      if found() .and. iif(is_diag, (!emptyall(tmp->p1boln,tmp->p1umer,tmp->p2boln,tmp->p2umer,tmp->p3boln,tmp->p3umer)), .t.)
        j1 := perenos(t_arr1,s3,len_name)
        if verify_FF(HH-j1,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        ls1 := padr(t_arr1[1],len_name)+;
               str(s1,3)+" "+;
               padc(alltrim(s2),7)
        ls1 += put_val(tmp->p1boln,7)+;
               put_val(tmp->p1stac,7)+;
               put_val(tmp->p1kd  ,8)+;
               put_val(tmp->p1umer,5)
        ls1 += put_val(tmp->p2boln,7)+;
               put_val(tmp->p2stac,7)+;
               put_val(tmp->p2kd  ,8)+;
               put_val(tmp->p2umer,5)
        ls1 += put_val(tmp->p3boln,7)+;
               put_val(tmp->p3stac,7)+;
               put_val(tmp->p3kd  ,8)+;
               put_val(tmp->p3umer,5)
        add_string(ls1)
        for i := 2 to j1
          add_string(t_arr1[i])
        next
        add_string(replicate("-",sh))
        if is_diag
          select TMP_D
          find (str(x,1)+str(s1,2))
          do while tmp_d->tip==x .and. tmp_d->stroke==s1 .and. !eof()
            select MKB10
            find (tmp_d->diagnoz)
            s := alltrim(mkb10->name)+" "
            skip
            do while left(mkb10->shifr,5) == tmp_d->diagnoz .and. mkb10->ks > 0 ;
                                                            .and. !eof()
              s += alltrim(mkb10->name)+" "
              skip
            enddo
            j1 := perenos(t_arr1,s,len_name+4)
            if verify_FF(HH-j1,.t.,sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            ls1 := padr(t_arr1[1],len_name+4)+;
                   padc(alltrim(tmp_d->diagnoz),7)
            ls1 += put_val(tmp_d->p1boln,7)+;
                   put_val(tmp_d->p1stac,7)+;
                   put_val(tmp_d->p1kd  ,8)+;
                   put_val(tmp_d->p1umer,5)
            ls1 += put_val(tmp_d->p2boln,7)+;
                   put_val(tmp_d->p2stac,7)+;
                   put_val(tmp_d->p2kd  ,8)+;
                   put_val(tmp_d->p2umer,5)
            ls1 += put_val(tmp_d->p3boln,7)+;
                   put_val(tmp_d->p3stac,7)+;
                   put_val(tmp_d->p3kd  ,8)+;
                   put_val(tmp_d->p3umer,5)
            add_string(ls1)
            for i := 2 to j1
              add_string(padl(alltrim(t_arr1[i]),len_name+4))
            next
            select TMP_D
            skip
          enddo
          add_string(replicate("-",sh))
        endif
      endif
    endif
  next
next
fclose(fp)
close databases
rest_box(buf)
viewtext(name_file,,,,.t.,,,reg_print)
return NIL

***** 04.01.16
Function f14ds_arr()
Local arr := {}
aadd(arr,{"A00-T98","Всего"})
aadd(arr,{"A00-B99","некоторые инфекционные и паразитарные болезни"})
aadd(arr,{"C00-D48","новообразования"})
aadd(arr,{"D50-D89","болезни крови, кроветворных органов и отдельные нарушения, вовлекающие иммунный механизм"})
aadd(arr,{"E00-E90","болезни эндокринной системы, расстройства питания и нарушения обмена веществ"})
aadd(arr,{"F00-F99","психические расстройства и расстройства поведения"})
aadd(arr,{"G00-G99","болезни нервной системы"})
aadd(arr,{"H00-H59","болезни глаза и его придаточного аппарата"})
aadd(arr,{"H60-H95","болезни уха и сосцевидного отростка"})
aadd(arr,{"I00-I99","болезни системы кровообращения"})
aadd(arr,{"J00-J99","болезни органов дыхания"})
aadd(arr,{"K00-K93","болезни органов пищеварения"})
aadd(arr,{"L00-L99","болезни кожи и подкожной клетчатки"})
aadd(arr,{"M00-M99","болезни костно-мышечной системы и соединительной ткани"})
aadd(arr,{"N00-N99","болезни мочеполовой системы"})
aadd(arr,{"O00-O99","беременность, роды и послеродовой период"})
aadd(arr,{"P00-P99","отдельные состояния, взникающие в перинатальном периоде"})
aadd(arr,{"Q00-Q99","врожденные аномалии, пороки развития, деформации и хромосомные нарушения"})
aadd(arr,{"R00-R99","симптомы, признаки и отклонения от нормы, выявленные при клинических и лабораторных исследованиях, не классифицированные в других рубриках"})
aadd(arr,{"S00-T98","травмы, отравления и некоторые другие последствия воздействия внешних причин"})
aadd(arr,{"Z00-Z99","Кроме того: факторы, влияющие на состояние здоровья и обращения в учреждения здравоохранения"})
aadd(arr,{"X"      ,"Оперировано больных (числа выписанных и переведенных)"})
aadd(arr,{"X"      ,"Число проведенных операций"})
return arr

*****
Function f14dstitle()
Local arr := array(10)
arr[ 1] := replicate("─",len_name)
arr[ 2] := padc("",len_name)
arr[ 3] := padc("",len_name)
arr[ 4] := padc("",len_name)
arr[ 5] := padc("Наименование болезни",len_name)
arr[ 6] := padc("",len_name)
arr[ 7] := padc("",len_name)
arr[ 8] := replicate("─",len_name)
arr[ 9] := padc("1",len_name)
arr[10] := replicate("─",len_name)
arr[ 1] := arr[ 1] + "┬──┬───────┬──────────────────────────┬──────────────────────────┬──────────────────────────"
arr[ 2] := arr[ 2] + "│  │       │Дн.стац.больничных учрежд.│Дн.стац.амб.-поликл.учрежд│     Стационар на дому    "
arr[ 3] := arr[ 3] + "│  │ Код по├──────┬──────┬───────┬────┼──────┬──────┬───────┬────┼──────┬──────┬───────┬────"
arr[ 4] := arr[ 4] + "│NN│ МКБ Х │ Выпи-│из них│провед.│умер│ Выпи-│из них│провед.│умер│ Выпи-│из них│провед.│умер"
arr[ 5] := arr[ 5] + "│ст│ пере- │ сано │напр.в│вып.бол│ло  │ сано │напр.в│вып.бол│ло  │ сано │напр.в│вып.бол│ло  "
arr[ 6] := arr[ 6] + "│ро│ смотра│ боль-│кругл.│дней   │    │ боль-│кругл.│дней   │    │ боль-│кругл.│дней   │    "
arr[ 7] := arr[ 7] + "│ки│       │ ных  │стац-р│лечения│    │ ных  │стац-р│лечения│    │ ных  │стац-р│лечения│    "
arr[ 8] := arr[ 8] + "┼──┼───────┼──────┼──────┼───────┼────┼──────┼──────┼───────┼────┼──────┼──────┼───────┼────"
arr[ 9] := arr[ 9] + "│ 2│   3   │   4  │   5  │   6   │  7 │   8  │   9  │   10  │ 11 │  12  │  13  │   14  │ 15 "
arr[10] := arr[10] + "┴──┴───────┴──────┴──────┴───────┴────┴──────┴──────┴───────┴────┴──────┴──────┴───────┴────"
return arr

*

***** 04.01.16
Function f1_f14ds(jh,jh1,is_diag)
Local arr := {}, arr_d := {}, i, j, k, n, mvozrast, lkd, lum, _kd
if human_->NOVOR > 0
  mvozrast := count_years(human_->DATE_R2,human->n_data)
else
  mvozrast := count_years(human->date_r,human->n_data)
endif
arr := diag_to_array()
if len(arr) == 0
  return jh
endif
asize(arr,1)  // только основной диагноз
for i := 1 to len(arr)
  arr[i] := padr(arr[i],5)
  if ascan(arr_d, arr[i]) == 0 .and. (k := ret_f_14(arr[i])) != NIL
    aadd(arr_d, arr[i])
    if len(k) > 0
      lkd := {0,0,0}
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
          lshifr := usl->shifr
        endif
        if alltrim(lshifr) == "60.2.9" // Проведение гемодиализа
          lkd[1] += hu->kol
        elseif left(lshifr,3) == "55."
          if human->k_data < 0d20130401 // дневной стационар до 1 апреля 2013
            j := int(val(substr(lshifr,4,1)))
            n := j-4 // 1 квартал 2013 года
            if between(n,1,3)
              lkd[n] += human->k_data-human->n_data+1
              exit
            endif
            n := j-1 // по 2012 год
            if between(n,1,3)
              lkd[n] += hu->kol
            endif
          elseif year(human->k_data) > 2013 .and. eq_any(left(lshifr,5),"55.2.","55.3.","55.4.")
            // от 1 до 4 пациенто-дней с 2014 года
            n := int(val(substr(lshifr,4,1))) - 1
            if between(n,1,3)
              lkd[n] += hu->kol
            endif
          elseif left(lshifr,5) == "55.1." // с 1 апреля 2013 года
            n := int(val(substr(lshifr,6,1)))
            if n > 3     // 55.1.4 - Пациенто-дни для учета в законченном случае реабилитации
              n := 1     // 55.1.5 - Пациенто-день для учета ЭКО ВМП
            endif
            if between(n,1,3)
              lkd[n] += hu->kol
            endif
          endif
        endif
        select HU
        skip
      enddo
      if !emptyall(lkd[1],lkd[2],lkd[3])   // если была услуга ПАЦИЕНТО-ДЕНЬ
        fl_perevod := .f. ; lv := 1 ; lum := 0 ; ++jh1
        if eq_any(human_->RSLT_NEW,202,203) // исход - направлен на госпитализацию/перевод в другое ЛПУ
          fl_perevod := .t.
        elseif is_death(human_->RSLT_NEW) // смерть
          lum := 1 ; lv := 0 // если умер, то койко-дни не учитывать
        endif
        x := iif(mvozrast >= 18, 1, 2)
        for j := 1 to len(k)
          select TMP_TAB
          find (str(x,1)+str(k[j,1],2))
          if !empty(lkd[1])   // если была услуга КОЙКО-ДЕНЬ
            if lum == 1
              tmp_tab->p1umer ++
            else
              tmp_tab->p1boln ++
              if fl_perevod
                tmp_tab->p1stac ++
              endif
              tmp_tab->p1kd += lkd[1]
            endif
          elseif !empty(lkd[2])   // если была услуга КОЙКО-ДЕНЬ
            if lum == 1
              tmp_tab->p2umer ++
            else
              tmp_tab->p2boln ++
              if fl_perevod
                tmp_tab->p2stac ++
              endif
              tmp_tab->p2kd += lkd[2]
            endif
          elseif !empty(lkd[3])   // если была услуга КОЙКО-ДЕНЬ
            if lum == 1
              tmp_tab->p3umer ++
            else
              tmp_tab->p3boln ++
              if fl_perevod
                tmp_tab->p3stac ++
              endif
              tmp_tab->p3kd += lkd[3]
            endif
          endif
        next
        if is_diag
          select TMP_D
          find (str(x,1)+padr(arr[i],5))
          if !found()
            append blank
            tmp_d->tip := x
            tmp_d->diagnoz := arr[i]
            if (j := ascan(k, {|y| y[1] > 1 })) > 0
              tmp_d->stroke := k[j,1]
            endif
          endif
          if !empty(lkd[1])   // если была услуга КОЙКО-ДЕНЬ
            if lum == 1
              tmp_d->p1umer ++
            else
              tmp_d->p1boln ++
              if fl_perevod
                tmp_d->p1stac ++
              endif
              tmp_d->p1kd += lkd[1]
            endif
          elseif !empty(lkd[2])   // если была услуга КОЙКО-ДЕНЬ
            if lum == 1
              tmp_d->p2umer ++
            else
              tmp_d->p2boln ++
              if fl_perevod
                tmp_d->p2stac ++
              endif
              tmp_d->p2kd += lkd[2]
            endif
          elseif !empty(lkd[3])   // если была услуга КОЙКО-ДЕНЬ
            if lum == 1
              tmp_d->p3umer ++
            else
              tmp_d->p3boln ++
              if fl_perevod
                tmp_d->p3stac ++
              endif
              tmp_d->p3kd += lkd[3]
            endif
          endif
        endif
      endif
    endif
  endif
next
if len(arr_d) > 0
  ++jh
endif
return jh

*

*****
Function forma_16(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j, uch_otd
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Распечатка ~формы 16вн", ;
                "Форма 16вн + ~диагнозы"}
    mas_msg := {"Распечатка формы № 16вн", ;
                "Распечатка аналога формы № 16вн с уточнением диагнозов"}
    mas_fun := {"forma_16(11)", ;
                "forma_16(12)"}
    if pi1 == 1 // по дате окончания лечения
      aadd(mas_pmt,"~Редактирование больничных")
      aadd(mas_msg,"Редактирование больничных")
      aadd(mas_fun,"forma_16(13)")
    endif
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    forma_16_vn(.f.)
  case k == 12
    forma_16_vn(.t.)
  case k == 13
    edit_bolnich(1)
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

***** 15.01.23
Function forma_16_vn(is_diag)
Static sy := 1
Local begin_date, end_date, pole, file_form, jh := 0, jt := 0, ;
      i, j, k, buf := save_maxrow(), adbf, lfp, t_arr1[20], t_arr2[20], ;
      mdate_b_1, mdate_b_2, mshifr, mdate_r, mvozrast, d1, d2, ;
      arr_title, sh, HH := 76, reg_print := 6, n_file, ;
      yes_otd, fl, lshifr, arr_stroke := {}, ;
      lmenu := {"~Сводная ведомость","Ведомость по ~отделению"}
n_file := iif(is_diag, "_frm_16d", "_form_16")+stxt
if (file_form := search_file("forma_16"+sfrm)) == NIL
  return func_error(4,"Не обнаружен файл FORMA_16"+sfrm)
endif
//if count_uch > 1
  aadd(lmenu, "Ведомость по ~учреждению")
//endif
if (yes_otd := popup_prompt(T_ROW,T_COL-5,sy,lmenu)) == 0
  return NIL
elseif yes_otd == 2 .and. (input_uch(T_ROW,T_COL-5,sys_date) == NIL .or. ;
                           input_otd(T_ROW,T_COL-5,sys_date) == NIL)
  return NIL
elseif yes_otd == 3 .and. input_uch(T_ROW,T_COL-5,sys_date) == NIL
  return NIL
endif
sy := yes_otd
if (arr_m := year_month()) == NIL
  return NIL
endif
st_a_uchast := {}
if equalany(yes_otd,1,3) .and. (st_a_uchast := ret_uchast(T_ROW,T_COL-5)) == NIL
  return NIL
endif
Private diag1 := {}, len_diag, ;
        s1sluch, s1dni, s1v[10], s2sluch, s2dni, s2v[10], ;
        arr_v := {{15,19},{20,24},{25,29},{30,34},{35,39}, ;
                  {40,44},{45,49},{50,54},{55,59},{60,999}}
s1sluch := s1dni := s2sluch := s2dni := 0
afill(s1v,0) ; afill(s2v,0)
begin_date := arr_m[5]
end_date := arr_m[6]
adbf := {{"stroke","C",2,0}, ;
         {"pol","C",1,0}, ;
         {"sluch","N",7,0}, ;
         {"dni","N",7,0}, ;
         {"v1","N",7,0}, ;
         {"v2","N",7,0}, ;
         {"v3","N",7,0}, ;
         {"v4","N",7,0}, ;
         {"v5","N",7,0}, ;
         {"v6","N",7,0}, ;
         {"v7","N",7,0}, ;
         {"v8","N",7,0}, ;
         {"v9","N",7,0}, ;
         {"v10","N",7,0}}
WaitStatus()
//
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new alias TMP
index on stroke to (cur_dir+"tmp")
lfp := fopen(file_form)
do while .t.
  UpdateStatus()
  if feof(lfp)
    s := "54.  O03-O08 Аборты"
  else
    s := fReadLn(lfp)
  endif
  if iif(is_diag, !(substr(s,6,1) == " "), .t.)
    s1 := left(s,3)
    s2 := alltrim(token(s," ",2))
/*for i := 1 to len(s2) // проверка на русские буквы в диагнозах
  if ISRALPHA(substr(s2,i,1))
    strfile(s2+eos,"ttt.ttt",.t.)
    exit
  endif
next*/
    diapazon := {}
    for i := 1 to numtoken(s2,",")
      s3 := token(s2,",",i)
      if "-" $ s3
        d1 := token(s3,"-",1)
        d2 := token(s3,"-",2)
      else
        d1 := d2 := s3
      endif
      aadd(diapazon, {diag_to_num(d1,1),diag_to_num(d2,2)} )
    next
    aadd(arr_stroke,left(s1,2))
    if right(s1,1) == " "
      append blank
      tmp->stroke := s1 ; tmp->pol := "м"
      aadd(diag1, {s1,"М",diapazon})
      //
      append blank
      s1 := strzero(val(s1)+1,2)
      tmp->stroke := s1 ; tmp->pol := "ж"
      aadd(diag1, {s1,"Ж",diapazon})
    else
      append blank
      tmp->stroke := s1 ; tmp->pol := "ж"
      aadd(diag1, {s1,"Ж",diapazon})
    endif
    if tmp->stroke == "54"
      aadd(arr_stroke,"55")
      // добавляем две строки "по уходу за ребенком"
      append blank
      tmp->stroke := "55" ; tmp->pol := "м"
      append blank
      tmp->stroke := "56" ; tmp->pol := "ж"
      exit
    endif
  endif
enddo
fclose(lfp)
len_diag := len(diag1)
//
if is_diag
  aadd(adbf,{"diagnoz","C",5,0})
  dbcreate(cur_dir+"tmp_dia",adbf)
  use (cur_dir+"tmp_dia") new alias TMP_D
  index on diagnoz+upper(pol) to (cur_dir+"tmp_dia")
endif
//
R_Use(dir_server+"kartotek",,"KART")
if pi1 == 1 // по дате окончания лечения
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"BO")
  set relation to kod_k into KART, to recno() into HUMAN_
  index on dtos(k_data) to (cur_dir+"tmp_f16") ;
        for human_->oplata < 9 .and. func_pi_schet(.t.,"bo") .and. ;
            bolnich > 0 .and. between(date_b_2,arr_m[7],arr_m[8]) ;
        progress
  go top
  do while !eof()
    UpdateStatus()
    @ maxrow(),1 say lstr(++jh) color cColorSt2Msg
    @ row(),col() say "/" color "W/R"
    @ row(),col() say lstr(jt) color cColorStMsg
    date_24(bo->k_data)
    jt += f1_f16(yes_otd,is_diag,st_a_uchast)
    select BO
    skip
  enddo
else
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humans","BO")
  set relation to kod_k into KART, to recno() into HUMAN_
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
  set relation to recno() into SCHET_
  set filter to empty(schet_->IS_DOPLATA)
  dbseek(arr_m[7],.t.)
  do while schet->pdate <= arr_m[8] .and. !eof()
    date_24(c4tod(schet->pdate))
    select BO
    find (str(schet->kod,6))
    do while bo->schet == schet->kod .and. !eof()
      UpdateStatus()
      @ maxrow(),1 say lstr(++jh) color cColorSt2Msg
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jt) color cColorStMsg
      if human_->oplata < 9
        jt += f1_f16(yes_otd,is_diag,st_a_uchast)
      endif
      select BO
      skip
    enddo
    select SCHET
    skip
  enddo
endif
close databases
//
mywait()
arr_title := {;
 "────────────────────────────┬────────────┬─┬──┬───────┬───────┬─────────────────────────────────────────────────┬───────", ;
 "                            │   Шифр     │П│NN│Число  │Число  │        в том числе по возрастам (лет):          │Средняя", ;
 "          Причина           │  по МКБ    │о│ст│дней   │случаев├────┬────┬────┬────┬────┬────┬────┬────┬────┬────┤длит-ть", ;
 "     нетрудоспособности     │   10-го    │л│ро│временн│временн│15- │20- │25- │30- │35- │40- │45- │50- │55- │60л.│пребыв.", ;
 "                            │ пересмотра │ │ки│нетр-ти│нетр-ти│  19│  24│  29│  34│  39│  44│  49│  54│  59│и ст│на б/л ", ;
 "────────────────────────────┼────────────┼─┼──┼───────┼───────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼───────", ;
 "              1             │      2     │3│4 │   5   │   6   │  7 │  8 │  9 │ 10 │ 11 │ 12 │ 13 │ 14 │ 15 │ 16 │   -   ", ;
 "────────────────────────────┴────────────┴─┴──┴───────┴───────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴───────"}
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
sh := len(arr_title[1])
R_Use(dir_server+"organiz",,"ORG")
add_string(padr(org->name,60)+padl("Форма 16-вн",sh-60))
add_string(padl("Утверждена",sh))
add_string(padl("Приказом Росстата",sh))
add_string(padl("от 27.12.2022г. № 985",sh))
add_string(center("Сведения о причинах временной нетрудоспособности",sh))
add_string(center(arr_m[4],sh))
if yes_otd == 2
  add_string("")
  add_string(center(glob_otd[2],sh))
elseif yes_otd == 3
  add_string("")
  add_string(center(glob_uch[2],sh))
endif
title_uchast(st_a_uchast,sh)
if pi1 == 1
  add_string(center(str_pi_schet(),sh))
else
  add_string(center("[ по дате выписки счета ]",sh))
endif
add_string("")
aeval(arr_title, {|x| add_string(x) } )
if is_diag
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB10")
  use (cur_dir+"tmp_dia") new alias TMP_D
  go top
  do while !eof()
    if ascan(arr_stroke,tmp_d->stroke) == 0
      tmp_d->stroke := strzero(val(tmp_d->stroke)-1,2)
    endif
    skip
  enddo
  index on stroke+diagnoz+iif(pol=="М","1","2") to (cur_dir+"tmp_dia")
endif
use (cur_dir+"tmp") index (cur_dir+"tmp") new
ft_use(file_form)
do while !ft_eof() .and. !empty( s := ft_ReadLn() )
  if iif(is_diag, !(substr(s,6,1) == " "), .t.)
    s1 := left(s,2)
    if substr(s,3,1) == " "
      k := 2
    else
      k := 1
    endif
    is_found := .f.
    select TMP
    find (s1)
    if found()
      is_found := (tmp->dni > 0)
      if !is_found .and. k == 2
        find (strzero(val(s1)+1,2))
        if found()
          is_found := (tmp->dni > 0)
        endif
      endif
    endif
    if iif(is_diag, is_found, .t.)
      s2 := token(s," ",2)
      s3 := token(s," ",3)
      s3 := substr(s,atnum(s3,s,1))
      if !(substr(s,6,1) == " ")
        j1 := perenos(t_arr1,s3,28)
        if !is_diag .and. !ft_eof()
          ft_skip()
          ls1 := ft_ReadLn()
          if substr(ls1,6,1) == " "
            //++j1 ; t_arr1[j1] := "  в том числе:"
          endif
          ft_skip(-1)
        endif
      elseif !(substr(s,10,1) == " ")
        j1 := perenos(t_arr1,s3,25)
        aeval(t_arr1, {|x,i| t_arr1[i] := space(3)+x }, 1, j1)
      else
        j1 := perenos(t_arr1,s3,22)
        aeval(t_arr1, {|x,i| t_arr1[i] := space(6)+x }, 1, j1)
      endif
      j2 := perenos(t_arr2,s2,12,",")
      find (s1)
      ls1 := padr(rtrim(t_arr1[1]),28,".")+" "+;
             padr(t_arr2[1],12)+" "+if(k==2,"м","ж")+" "+s1+;
             put_val(tmp->dni,8)+;
             put_val(tmp->sluch,8)+;
             put_val(tmp->v1,5)+;
             put_val(tmp->v2,5)+;
             put_val(tmp->v3,5)+;
             put_val(tmp->v4,5)+;
             put_val(tmp->v5,5)+;
             put_val(tmp->v6,5)+;
             put_val(tmp->v7,5)+;
             put_val(tmp->v8,5)+;
             put_val(tmp->v9,5)+;
             put_val(tmp->v10,5)+;
             if(empty(tmp->sluch), "", umest_val(tmp->dni/tmp->sluch,7,1))
      ls2 := padr(t_arr1[2],28)+" "+padr(t_arr2[2],12)
      if k == 2
        s1_ := strzero(val(s1)+1,2)
        find (s1_)
        ls2 += " ж "+s1_+;
             put_val(tmp->dni,8)+;
             put_val(tmp->sluch,8)+;
             put_val(tmp->v1,5)+;
             put_val(tmp->v2,5)+;
             put_val(tmp->v3,5)+;
             put_val(tmp->v4,5)+;
             put_val(tmp->v5,5)+;
             put_val(tmp->v6,5)+;
             put_val(tmp->v7,5)+;
             put_val(tmp->v8,5)+;
             put_val(tmp->v9,5)+;
             put_val(tmp->v10,5)+;
             if(empty(tmp->sluch), "", umest_val(tmp->dni/tmp->sluch,7,1))
      endif
      add_string("")
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(ls1)
      add_string(ls2)
      for i := 3 to max(j1,j2)
        add_string(padr(t_arr1[i],28)+" "+padr(t_arr2[i],12))
      next
      if is_diag
        add_string(replicate("-",sh))
        select TMP_D
        find (s1)
        do while tmp_d->stroke == s1 .and. !eof()
          lshifr := tmp_d->diagnoz
          select MKB10
          find (lshifr)
          s := alltrim(mkb10->name)+" "
          skip
          do while left(mkb10->shifr,5) == lshifr .and. mkb10->ks > 0 ;
                                                  .and. !eof()
            s += alltrim(mkb10->name)+" "
            skip
          enddo
          j1 := perenos(t_arr1,s,35)
          ls1 := lshifr+" "+padr(t_arr1[1],35)
          ls2 := space(6)  +padr(t_arr1[2],35)
          ls1 += " "+lower(tmp_d->pol)+space(3)+;
                 put_val(tmp_d->dni,8)+;
                 put_val(tmp_d->sluch,8)+;
                 put_val(tmp_d->v1,5)+;
                 put_val(tmp_d->v2,5)+;
                 put_val(tmp_d->v3,5)+;
                 put_val(tmp_d->v4,5)+;
                 put_val(tmp_d->v5,5)+;
                 put_val(tmp_d->v6,5)+;
                 put_val(tmp_d->v7,5)+;
                 put_val(tmp_d->v8,5)+;
                 put_val(tmp_d->v9,5)+;
                 put_val(tmp_d->v10,5)+;
                 if(empty(tmp_d->sluch), "", ;
                                umest_val(tmp_d->dni/tmp_d->sluch,7,1))
          select TMP_D
          skip
          if !eof()
            if lshifr == tmp_d->diagnoz
              ls2 += " "+lower(tmp_d->pol)+space(3)+;
                     put_val(tmp_d->dni,8)+;
                     put_val(tmp_d->sluch,8)+;
                     put_val(tmp_d->v1,5)+;
                     put_val(tmp_d->v2,5)+;
                     put_val(tmp_d->v3,5)+;
                     put_val(tmp_d->v4,5)+;
                     put_val(tmp_d->v5,5)+;
                     put_val(tmp_d->v6,5)+;
                     put_val(tmp_d->v7,5)+;
                     put_val(tmp_d->v8,5)+;
                     put_val(tmp_d->v9,5)+;
                     put_val(tmp_d->v10,5)+;
                     if(empty(tmp_d->sluch), "", ;
                                    umest_val(tmp_d->dni/tmp_d->sluch,7,1))
            else
              skip -1
            endif
          endif
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(ls1)
          add_string(ls2)
          select TMP_D
          skip
        enddo
        add_string(replicate("-",sh))
      endif
    endif
  endif
  ft_skip()
enddo
ft_use()
t_arr1 := {;
"", ;
"Всего по заболеваниям                     м 52", ;
"                                          ж 53", ;
"  из них: аборты (из стр.45) O03-O08      ж 54", ;
"", ;
"   уход за больным..........              м 55", ;
"                                          ж 56", ;
"", ;
"   отпуск в связи с санатор-              м 57", ;
"   но-курортным лечением                  ж 58", ;
"   (без туберкулеза и доле-", ;
"   чивания инфаркта миокарда)", ;
"", ;
"   освобождение от работы в               м 59", ;
"   связи с карантином и                   ж 60", ;
"   бактерионосительством", ;
"", ;
"  из них: в связи с карантином   Z20.8,   м 61", ;
"   по COVID-19 (из стр. 59 - 60) Z22.8,   ж 62", ;
"                                 Z29.0", ;  
"", ; 
"ИТОГО ПО ВСЕМ ПРИЧИНАМ                    м 63", ;
"                                          ж 64", ;
"", ;
"Отпуск по беременности и родам            ж 65", ;
""}
last_stroke := "*"
select TMP
for i := 1 to len(t_arr1)
  if empty(t_arr1[1]) .and. verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  ls1 := t_arr1[i]
  if "м 52" == right(t_arr1[i],4)
    ls1 := padr(ls1,46)+;
         put_val(s1dni,8)+;
         put_val(s1sluch,8)+;
         put_val(s1v[1],5)+;
         put_val(s1v[2],5)+;
         put_val(s1v[3],5)+;
         put_val(s1v[4],5)+;
         put_val(s1v[5],5)+;
         put_val(s1v[6],5)+;
         put_val(s1v[7],5)+;
         put_val(s1v[8],5)+;
         put_val(s1v[9],5)+;
         put_val(s1v[10],5)+;
         if(empty(s1sluch), "", umest_val(s1dni/s1sluch,7,1))
  elseif "ж 53" == right(t_arr1[i],4)
    ls1 := padr(ls1,46)+;
         put_val(s2dni,8)+;
         put_val(s2sluch,8)+;
         put_val(s2v[1],5)+;
         put_val(s2v[2],5)+;
         put_val(s2v[3],5)+;
         put_val(s2v[4],5)+;
         put_val(s2v[5],5)+;
         put_val(s2v[6],5)+;
         put_val(s2v[7],5)+;
         put_val(s2v[8],5)+;
         put_val(s2v[9],5)+;
         put_val(s2v[10],5)+;
         if(empty(s2sluch), "", umest_val(s2dni/s2sluch,7,1))
  elseif "ж 54" == right(t_arr1[i],4)
    find ("54")
    if iif(is_diag, (tmp->dni > 0), .t.)
      ls1 := padr(ls1,46)+;
           put_val(tmp->dni,8)+;
           put_val(tmp->sluch,8)+;
           put_val(tmp->v1,5)+;
           put_val(tmp->v2,5)+;
           put_val(tmp->v3,5)+;
           put_val(tmp->v4,5)+;
           put_val(tmp->v5,5)+;
           put_val(tmp->v6,5)+;
           put_val(tmp->v7,5)+;
           put_val(tmp->v8,5)+;
           put_val(tmp->v9,5)+;
           put_val(tmp->v10,5)+;
           if(empty(tmp->sluch), "", umest_val(tmp->dni/tmp->sluch,7,1))
    else
      ls1 := ""
    endif
  elseif "м 55" == right(t_arr1[i],4)  // по уходу за ребенком
    find ("55")
    ls1 := padr(ls1,46)+;
         put_val(tmp->dni,8)+;
         put_val(tmp->sluch,8)+;
         put_val(tmp->v1,5)+;
         put_val(tmp->v2,5)+;
         put_val(tmp->v3,5)+;
         put_val(tmp->v4,5)+;
         put_val(tmp->v5,5)+;
         put_val(tmp->v6,5)+;
         put_val(tmp->v7,5)+;
         put_val(tmp->v8,5)+;
         put_val(tmp->v9,5)+;
         put_val(tmp->v10,5)+;
         if(empty(tmp->sluch), "", umest_val(tmp->dni/tmp->sluch,7,1))
         s1dni   += tmp->dni
         s1sluch += tmp->sluch
         s1v[1]  += tmp->v1
         s1v[2]  += tmp->v2
         s1v[3]  += tmp->v3
         s1v[4]  += tmp->v4
         s1v[5]  += tmp->v5
         s1v[6]  += tmp->v6
         s1v[7]  += tmp->v7
         s1v[8]  += tmp->v8
         s1v[9]  += tmp->v9
         s1v[10] += tmp->v10
  elseif "ж 56" == right(t_arr1[i],4)  // по уходу за ребенком
    find ("56")
    ls1 := padr(ls1,46)+;
         put_val(tmp->dni,8)+;
         put_val(tmp->sluch,8)+;
         put_val(tmp->v1,5)+;
         put_val(tmp->v2,5)+;
         put_val(tmp->v3,5)+;
         put_val(tmp->v4,5)+;
         put_val(tmp->v5,5)+;
         put_val(tmp->v6,5)+;
         put_val(tmp->v7,5)+;
         put_val(tmp->v8,5)+;
         put_val(tmp->v9,5)+;
         put_val(tmp->v10,5)+;
         if(empty(tmp->sluch), "", umest_val(tmp->dni/tmp->sluch,7,1))
         s2dni   += tmp->dni
         s2sluch += tmp->sluch
         s2v[1]  += tmp->v1
         s2v[2]  += tmp->v2
         s2v[3]  += tmp->v3
         s2v[4]  += tmp->v4
         s2v[5]  += tmp->v5
         s2v[6]  += tmp->v6
         s2v[7]  += tmp->v7
         s2v[8]  += tmp->v8
         s2v[9]  += tmp->v9
         s2v[10] += tmp->v10
  elseif "м 63" == right(t_arr1[i],4)
    ls1 := padr(ls1,46)+;
         put_val(s1dni,8)+;
         put_val(s1sluch,8)+;
         put_val(s1v[1],5)+;
         put_val(s1v[2],5)+;
         put_val(s1v[3],5)+;
         put_val(s1v[4],5)+;
         put_val(s1v[5],5)+;
         put_val(s1v[6],5)+;
         put_val(s1v[7],5)+;
         put_val(s1v[8],5)+;
         put_val(s1v[9],5)+;
         put_val(s1v[10],5)+;
         if(empty(s1sluch), "", umest_val(s1dni/s1sluch,7,1))
  elseif "ж 64" == right(t_arr1[i],4)
    ls1 := padr(ls1,46)+;
         put_val(s2dni,8)+;
         put_val(s2sluch,8)+;
         put_val(s2v[1],5)+;
         put_val(s2v[2],5)+;
         put_val(s2v[3],5)+;
         put_val(s2v[4],5)+;
         put_val(s2v[5],5)+;
         put_val(s2v[6],5)+;
         put_val(s2v[7],5)+;
         put_val(s2v[8],5)+;
         put_val(s2v[9],5)+;
         put_val(s2v[10],5)+;
         if(empty(s2sluch), "", umest_val(s2dni/s2sluch,7,1))
  elseif is_diag
    ls1 := ""
  endif
  if !emptyall(ls1,last_stroke)
    add_string(ls1)
  endif
  last_stroke := ls1
next
close databases
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,(sh > 80),,,reg_print)
return NIL

*

*****
Function ret_boln(lpol,lshifr)
Local ret := {}, i, j, d, r
d := diag_to_num(lshifr,1)
for i := 1 to len_diag
  if upper(lpol) == upper(diag1[i,2])
    r := diag1[i,3]
    for j := 1 to len(r)
      if between(d,r[j,1],r[j,2])
        aadd(ret, diag1[i,1])
        exit
      endif
    next
  endif
next
if len(ret) == 0 ; ret := NIL ; endif
return ret

*

***** 02.01.15
Function f1_f16(yes_otd,is_diag,st_a_uchast)
Local fl, mdate_b_1, mdate_b_2, mshifr, mpol, mvozrast, mdate_r, i, k, v, ;
      arr, pole, pole1, ret := 0
if (fl := (bo->bolnich > 0))
  mdate_b_1 := c4tod(bo->date_b_1)
  mdate_b_2 := c4tod(bo->date_b_2)
  fl := !emptyany(mdate_b_1,mdate_b_2)
endif
if fl
  fl := f_is_uchast(st_a_uchast,kart->uchast)
endif
if fl
  if yes_otd == 2
    fl := (bo->otd == glob_otd[1])
  elseif yes_otd == 3
    fl := (bo->lpu == glob_uch[1])
  endif
endif
if fl
  arr := diag_to_array("bo")
  fl := len(arr) > 0
endif
if fl
  mshifr := padr(arr[1],5)   // берем только основной диагноз
  mdate_r := iif(human_->NOVOR > 0, human_->DATE_R2, bo->date_r)
  mpol := iif(human_->NOVOR > 0, human_->pol2, bo->pol)
  if (k := ret_boln(mpol,mshifr)) != NIL .or. bo->bolnich == 2
    ret := 1
    if bo->bolnich == 2 // по уходу за ребенком
      mpol := "Ж" ; k := {"54"}
      mdate_r := human_->RODIT_DR  // дата рождения родителя
      if human_->RODIT_POL == "М"
        mpol := "М" ; k := {"53"}  // переопределяем номер строки
      endif
    endif
    mvozrast := count_years(mdate_r, bo->n_data)
    if (v := ascan(arr_v, {|x| between(mvozrast,x[1],x[2]) } )) == 0
      v := 8
    endif
    pole := "tmp->v"+lstr(v)
    pole1 := "tmp_d->v"+lstr(v)
    d := mdate_b_2 - mdate_b_1 + 1
    for i := 1 to len(k)
      select TMP
      find (k[i])
      tmp->sluch ++
      tmp->dni += d
      &pole := &pole+1
    next
    if bo->bolnich < 2 // не по уходу за ребенком
      if upper(mpol) == "М"
        s1sluch ++
        s1dni += d
        s1v[v] ++
      else
        s2sluch ++
        s2dni += d
        s2v[v] ++
      endif
      if is_diag
        select TMP_D
        find (padr(mshifr,5)+upper(mpol))
        if !found()
          append blank
          tmp_d->diagnoz := mshifr
          tmp_d->pol := upper(mpol)
          if (i := ascan(k, {|x| val(x) < val("50") } )) > 0
            tmp_d->stroke := k[i]
          endif
        endif
        tmp_d->sluch ++
        tmp_d->dni += d
        &pole1 := &pole1+1
      endif
    endif
  endif
endif
return ret

** 06.11.22
Function forma_30()
Local i, j, k, arr, s, buf := save_maxrow(), fl_exit := .f., ;
      reg_print, name_file := "_form_30"+stxt, ;
      jh := 0, jh1 := 0, arr_m
if (arr_m := year_month()) == NIL
  return NIL
endif
Private sh, HH := 78, arr_title
adbf := {{"tip",   "N",1,0}, ;  // 1-4
         {"kod",   "N",9,0}, ;  // врач,профиль,специальность,услуга
         {"p3",    "N",7,0}, ;
         {"p4",    "N",7,0}, ;
         {"p5",    "N",7,0}, ;
         {"p6",    "N",7,0}, ;
         {"p7",    "N",7,0}, ;
         {"p8",    "N",7,0}, ;
         {"p9",    "N",7,0}, ;
         {"p10",   "N",7,0}, ;
         {"p11",   "N",7,0}, ;
         {"p12",   "N",7,0}, ;
         {"p13",   "N",7,0}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
index on str(tip,1)+str(kod,9) to (cur_dir+"tmp")
//
adbf := {{"tip",   "N",1,0}, ;  // 1-4
         {"kod",   "N",9,0}, ;  // врач,профиль,специальность,услуга
         {"p5",    "N",7,0}, ;
         {"p6",    "N",7,0}, ;
         {"p7",    "N",7,0}, ;
         {"p8",    "N",7,0}, ;
         {"p9",    "N",7,0}, ;
         {"p10",   "N",7,0}, ;
         {"p11",   "N",7,0}, ;
         {"p12",   "N",7,0}, ;
         {"p13",   "N",7,0}, ;
         {"p14",   "N",7,0}, ;
         {"p15",   "N",7,0}}
dbcreate(cur_dir+"tmp1",adbf)
use (cur_dir+"tmp1") new
index on str(tip,1)+str(kod,9) to (cur_dir+"tmp1")
//
adbf := {{"tip",   "N",1,0}, ;  // 1-4
         {"kod",   "N",9,0}, ;  // врач,профиль,специальность,услуга
         {"p2",    "N",7,0}, ;
         {"p3",    "N",7,0}, ;
         {"p4",    "N",7,0}, ;
         {"p5",    "N",7,0}, ;
         {"p6",    "N",7,0}, ;
         {"p7",    "N",7,0}, ;
         {"p8",    "N",7,0}, ;
         {"p9",    "N",7,0}, ;
         {"p10",   "N",7,0}, ;
         {"p11",   "N",7,0}, ;
         {"p12",   "N",7,0}, ;
         {"p13",   "N",7,0}, ;
         {"p14",   "N",7,0}, ;
         {"p15",   "N",7,0}}
dbcreate(cur_dir+"tmp2",adbf)
use (cur_dir+"tmp2") new
index on str(tip,1)+str(kod,9) to (cur_dir+"tmp2")
//
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
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
if pi1 == 1 // по дате окончания лечения
  begin_date := arr_m[5]
  end_date := arr_m[6]
  R_Use(dir_server+"human_2",,"HUMAN_2")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to kod_k into KART, to recno() into HUMAN_, recno() into HUMAN_2
  dbseek(dtos(arr_m[5]),.t.)
  do while human->k_data <= arr_m[6] .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if human_->oplata < 9 .and. func_pi_schet()
      jh := f1_f30_dop(jh,jh1)
      jh := f1_f30(jh-1,@jh1)
      @ maxrow(),1 say lstr(jh) color cColorSt2Msg
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jh1) color cColorStMsg
    endif
    date_24(human->k_data)
    select HUMAN
    skip
  enddo
else
  R_Use(dir_server+"human_2",,"HUMAN_2")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humans","HUMAN")
  set relation to kod_k into KART, to recno() into HUMAN_, recno() into HUMAN_2
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
  set relation to recno() into SCHET_
  set filter to empty(schet_->IS_DOPLATA)
  dbseek(arr_m[7],.t.)
  do while schet->pdate <= arr_m[8] .and. !eof()
    date_24(c4tod(schet->pdate))
    select HUMAN
    find (str(schet->kod,6))
    do while human->schet == schet->kod .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if human_->oplata < 9
        jh := f1_f30_dop(jh,jh1)
        jh := f1_f30(jh-1,@jh1)
      endif
      @ maxrow(),1 say lstr(jh) color cColorSt2Msg
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jh1) color cColorStMsg
      select HUMAN
      skip
    enddo
    if fl_exit
      exit
    endif
    select SCHET
    skip
  enddo
endif
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
//
mywait()
arr_title := {;
"───────────────────────┬──┬────────────────────┬────────────────────┬──────────────────────────────────", ;
"                       │№ │   Число посещений  │из общего числа по  │ число посещений врачами на дому  ", ;
"                       │ст├──────┬──────┬──────┤ поводу заболеваний ├──────┬──────┬──────┬──────┬──────", ;
"Наименование должностей│ро│      │в т.ч.│детьми├──────┬──────┬──────┤всего │из них│из гр9│из гр9│из г12", ;
"                       │ки│всего │сельск│ 0-17 │сельс.│18 лет│ дети │      │сельск│по пов│ дети │по пов", ;
"                       │  │      │жителя│ лет  │жител.│и стар│0-17л.│      │жителе│заболе│0-17л.│заболе", ;
"───────────────────────┼──┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────", ;
"           1           │2 │  3   │  4   │  5   │  6   │  7   │  8   │  9   │  10  │  11  │  12  │  13  ", ;
"───────────────────────┴──┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────";
}
sh := len(arr_title[1])
reg_print := 6
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(padr(org->name,108))
add_string(padl("Форма № 30",sh))
add_string(padl("Утверждена Приказом",sh))
add_string(padl("Росстата России",sh))
add_string(padl("от 27.12.2016г. № 866",sh))
add_string(center("СВЕДЕНИЯ ОБ УЧРЕЖДЕНИИ ЗДРАВООХРАНЕНИЯ",sh))
add_string(center(arr_m[4],sh))
if pi1 == 1
  add_string(center(str_pi_schet(),sh))
else
  add_string(center("[ по дате выписки счета ]",sh))
endif
add_string("")
add_string(center("Раздел III. ДЕЯТЕЛЬНОСТЬ МО ПО ОКАЗАНИЮ МЕД.ПОМОЩИ В АМБУЛАТОРНЫХ УСЛОВИЯХ",sh))
add_string("")
add_string(center("1. Работа врачей медицинской организации в амбулаторных условиях",sh))
add_string("(2100)"+padl("Код по ОКЕИ: посещение в смену - 545",sh-6))
aeval(arr_title, {|x| add_string(x) } )
use (cur_dir+"tmp") new index (cur_dir+"tmp")
find (str(0,1))
if found()
  f2_f30("Врачи всего","01")
  add_string(replicate("-",sh))
  add_string("в т.ч. по врачам")
  R_Use(dir_server+"mo_pers",,"PERS")
  select TMP
  set relation to kod into PERS
  index on upper(pers->fio) to (cur_dir+"tmp") for tip == 1
  go top
  do while !eof()
    f2_f30(lstr(pers->tab_nom)+" "+fam_i_o(pers->fio))
    skip
  enddo
  add_string(replicate("-",sh))
  add_string("в т.ч. по профилям")
  select TMP
  set relation to
  index on str(kod,9) to (cur_dir+"tmp") for tip == 2
  go top
  do while !eof()
    f2_f30(inieditspr(A__MENUVERT, getV002(), tmp->kod))
    skip
  enddo
  add_string(replicate("-",sh))
  add_string("в т.ч. по специальностям")
  select TMP
  set relation to
  index on padr(lstr(kod),9) to (cur_dir+"tmp") for tip == 3
  go top
  do while !eof()
    f2_f30(inieditspr(A__MENUVERT, getV015(), tmp->kod))
    skip
  enddo
  R_Use(dir_server+"uslugi",,"USL")
  add_string(replicate("-",sh))
  add_string("в т.ч. по услугам")
  select TMP
  set relation to kod into USL
  index on fsort_usl(usl->shifr) to (cur_dir+"tmp") for tip == 4
  go top
  do while !eof()
    f2_f30(alltrim(usl->shifr)+" "+usl->name)
    skip
  enddo
  R_Use(dir_server+"mo_su",,"MOSU")
  select TMP
  set relation to kod into MOSU
  index on fsort_usl(mosu->shifr) to (cur_dir+"tmp") for tip == 5
  go top
  do while !eof()
    lshifr := alltrim(mosu->shifr1)
    if !empty(mosu->shifr)
      lshifr += "("+alltrim(mosu->shifr)+")"
    endif
    f2_f30(lshifr+" "+mosu->name)
    skip
  enddo
endif
arr_title := {;
"──────────────────────────┬───────────────────────────┬────────────────────┬─────────────┬─────────────", ;
"                          │   Поступило больных       │  выписано больных  │   умерло    │ койко-дней  ", ;
"                          ├──────┬──────┬──────┬──────┼──────┬──────┬──────┼──────┬──────┼──────┬──────", ;
"      Профиль коек        │      │в т.ч.│детей │старше│      │старше│в     │всего │старше│всего │старше", ;
"                          │всего │сельск│ 0-17 │трудос│ всего│трудос│дневны│      │трудос│      │трудос", ;
"                          │      │жителе│ лет  │возвра│      │возвра│стацио│      │возвра│      │возвра", ;
"──────────────────────────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────", ;
"           2              │  6   │  7   │  8   │  9   │  10  │  11  │  12  │  13  │  14  │  15  │  16  ", ;
"──────────────────────────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────";
}
sh := len(arr_title[1])
tek_stroke := HH+10
verify_FF(HH,.t.,sh)
add_string("")
add_string(center("Раздел IV. ДЕЯТЕЛЬНОСТЬ МО ПО ОКАЗАНИЮ МЕД.ПОМОЩИ В СТАЦИОНАРНЫХ УСЛОВИЯХ",sh))
add_string("")
add_string(center("1. Коечный фонд и его использование",sh))
add_string("(3100)"+padl("Коды по ОКЕИ: койка - 911, человек - 792",sh-6))
aeval(arr_title, {|x| add_string(x) } )
use (cur_dir+"tmp1") new index (cur_dir+"tmp1")
find (str(0,1))
if found()
  f2_f30("Коек всего",,2) //!!!!!!!
  add_string(replicate("-",sh))
  add_string("в т.ч. по профилям")
  index on str(kod,9) to (cur_dir+"tmp1") for tip == 1
  go top
  do while !eof()
    f2_f30(inieditspr(A__MENUVERT, getV002(), tmp1->kod),,2)
    skip
  enddo
endif
if fl_exit ; return NIL ; endif
//
mywait()
arr_title := {;
"───────────────────────┬─────────────────────────────────────────┬─────────────────────────────────────────", ;
"                       │                 Число посещений         │из общего числа посещений по поводу забол", ;
"                       ├─────┬─────┬─────┬─────┬─────┬─────┬─────┼─────┬─────┬─────┬─────┬─────┬─────┬─────", ;
"Наименование должностей│     │в т.ч│из 2 │из 4 │дети │из 6 │из 6 │     │в т.ч│18лет│старш│дети │из 13│из 13", ;
"                       │всего│сельс│старш│сельс│ 0-17│в т.ч│сельс│всего│сельс│  и  │труд │0-17л│в т.ч│сельс", ;
"                       │     │ ких │труд.│ ких │ лет │дети │ ких │     │ ких │стар │оспос│     │ 0-14│ ких ", ;
"                       │     │жител│возр.│жител│     │0-14 │жител│     │жител│ ше  │возр │     │     │жител", ;
"───────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────", ;
"           1           │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 │  12 │  13 │  14 │  15 ", ;
"───────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────";
}
sh := len(arr_title[1])
tek_stroke := HH+10
verify_FF(HH,.t.,sh)
add_string("")
add_string(center("Раздел III. ДЕЯТЕЛЬНОСТЬ МО ПО ОКАЗАНИЮ МЕД.ПОМОЩИ В АМБУЛАТОРНЫХ УСЛОВИЯХ",sh))
add_string(center("дополнение",sh))
add_string(center("1. Работа врачей медицинской организации в амбулаторных условиях",sh))
add_string("(2100)"+padl("Код по ОКЕИ: посещение в смену - 545",sh-6))
aeval(arr_title, {|x| add_string(x) } )
use (cur_dir+"tmp2") new index (cur_dir+"tmp2")
find (str(0,1))
if found()  // в tmp уже должны входить
  f2_f30_dop("Врачи всего","01")
  add_string(replicate("-",sh))
  add_string("в т.ч. по врачам")
//  R_Use(dir_server+"mo_pers",,"PERS")
  select TMP2
  set relation to kod into PERS
  index on upper(pers->fio) to (cur_dir+"tmp2") for tip == 1
  go top
  do while !eof()
    f2_f30_dop(lstr(pers->tab_nom)+" "+fam_i_o(pers->fio))
    skip
  enddo
  add_string(replicate("-",sh))
  add_string("в т.ч. по профилям")
  select TMP2
  set relation to
  index on str(kod,9) to (cur_dir+"tmp2") for tip == 2
  go top
  do while !eof()
    f2_f30_dop(inieditspr(A__MENUVERT, getV002(), tmp2->kod))
    skip
  enddo
  add_string(replicate("-",sh))
  add_string("в т.ч. по специальностям")
  select TMP2
  set relation to
  index on padr(lstr(kod),9) to (cur_dir+"tmp2") for tip == 3
  go top
  do while !eof()
    f2_f30_dop(inieditspr(A__MENUVERT, getV015(), tmp2->kod))
    skip
  enddo
//  R_Use(dir_server+"uslugi",,"USL")
  add_string(replicate("-",sh))
  add_string("в т.ч. по услугам")
  select TMP2
  set relation to kod into USL
  index on fsort_usl(usl->shifr) to (cur_dir+"tmp2") for tip == 4
  go top
  do while !eof()
    f2_f30_dop(alltrim(usl->shifr)+" "+usl->name)
    skip
  enddo
//  R_Use(dir_server+"mo_su",,"MOSU")
  select TMP2
  set relation to kod into MOSU
  index on fsort_usl(mosu->shifr) to (cur_dir+"tmp2") for tip == 5
  go top
  do while !eof()
    lshifr := alltrim(mosu->shifr1)
    if !empty(mosu->shifr)
      lshifr += "("+alltrim(mosu->shifr)+")"
    endif
    f2_f30_dop(lshifr+" "+mosu->name)
    skip
  enddo
endif
//
fclose(fp)
close databases
rest_box(buf)
viewtext(name_file,,,,.t.,,,reg_print)
return NIL

*

***** 19.10.16
Function f1_f30(jh,jh1)
Local i, j, k, n, mvozrast, is_selo, is_dom, is_zabol, fl_stom_new := .f., au_lu := {}, au_flu := {}, ;
      lshifr, lshifr1, yes_30 := .f., fl_pensioner := .f., fl_death := .f., ;
      d2_year := year(human->k_data), au_su1 := {}, vid_vp := 0 // по умолчанию профилактика
if human_->NOVOR > 0
  mvozrast := count_years(human_->DATE_R2,human->n_data)
else
  mvozrast := count_years(human->date_r,human->n_data)
endif
is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog)  // признак села
if (human->pol == "Ж" .and. mvozrast >= 55) .or. ;
   (human->pol == "М" .and. mvozrast >= 60)
  fl_pensioner := .t.
endif
if is_death(human_->RSLT_NEW) // смерть
  fl_death := .t.
endif
select HU
find (str(human->kod,7))
do while hu->kod == human->kod .and. !eof()
  lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
  if f_paraklinika(usl->shifr,lshifr1,human->k_data)
    lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
    if is_2_stomat(lshifr,,.t.) > 0
      fl_stom_new := .t.
      aadd(au_lu,{lshifr, ;              // 1
                  c4tod(hu->date_u), ;   // 2
                  hu_->profil, ;         // 3
                  hu_->PRVS, ;           // 4
                  alltrim(usl->shifr), ; // 5
                  hu->kol_1, ;           // 6
                  c4tod(hu->date_u), ;   // 7
                  hu_->kod_diag, ;       // 8
                  hu->(recno()), ;       // 9 - номер записи
                  0})                   // 10 - для возврата
    endif
    if eq_any(left(lshifr,5),"2.80.","2.82.")
      vid_vp := 1 // в неотложной форме или Посещение в приёмном покое
      exit
    elseif eq_any(left(lshifr,5),"2.78.","2.89.")
      vid_vp := 2 // по поводу заболевания
      exit
    elseif left(lshifr,5) == "2.88."
      vid_vp := 2 // разовое по поводу заболевания
      exit
    elseif d2_year < 2016 .and. left(lshifr,3) == "57." // стоматология
      for i := 1 to 3
        ar := {}
        f_vid_p_stom({},{},ar,{i})
        if ascan(ar,lshifr) > 0
          if i == 1 // с лечебной целью
            vid_vp := 3 // по поводу заболевания
          elseif i == 2 // // с профилактической целью
            vid_vp := 1 // профилактика
          else // // при оказании неотложной помощи
            vid_vp := 2 // в неотложной форме
          endif
          exit
        endif
      next
      if vid_vp > 0
        --vid_vp
        exit
      endif
    endif
  endif
  select HU
  skip
enddo
is_zabol := (vid_vp > 0)
if fl_stom_new
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    aadd(au_flu,{mosu->shifr1, ;         // 1
                 c4tod(mohu->date_u), ;  // 2
                 mohu->profil, ;         // 3
                 mohu->PRVS, ;           // 4
                 mosu->shifr, ;          // 5
                 mohu->kol_1, ;          // 6
                 c4tod(mohu->date_u2), ; // 7
                 mohu->kod_diag, ;       // 8
                 mohu->(recno()), ;      // 9 - номер записи
                 0})                    // 10 - для возврата
    select MOHU
    skip
  enddo
  f_vid_p_stom(au_lu,{},,,human->k_data,,,,au_flu)
  for j := 1 to len(au_flu)
    if au_flu[j,10] == 1 // является врачебным приёмом
      mohu->(dbGoto(au_flu[j,9]))
      is_dom := .f. // на дому
      yes_30 := .t.
      mkol := au_flu[j,6]
      select TMP
      for i := 0 to 4
        lkod := {0,mohu->kod_vr,mohu->PROFIL,ret_new_prvs(mohu->PRVS),mohu->u_kod}[i+1]
        if i == 4 ; i := 5 ; endif
        find (str(i,1)+str(lkod,9))
        if !found()
          append blank
          tmp->tip := i
          tmp->kod := lkod
        endif
        if is_dom
          tmp->p9 += mkol
          if is_selo
            tmp->p10 += mkol
          endif
          if is_zabol
            tmp->p11 += mkol
          endif
          if mvozrast < 18
            tmp->p12 += mkol
            if is_zabol
              tmp->p13 += mkol
            endif
          endif
        else
          tmp->p3 += mkol
          if is_selo
            tmp->p4 += mkol
          endif
          if mvozrast < 18
            tmp->p5 += mkol
          endif
          if is_zabol
            if is_selo
              tmp->p6 += mkol
            endif
            if mvozrast >= 18
              tmp->p7 += mkol
            else
              tmp->p8 += mkol
            endif
          endif
        endif
      next
    endif
  next
else
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
            if year(human->k_data) > 2012
              is_dom := (hu->kol_rcp < 0 .and. DomUslugaTFOMS(lshifr)) // на дому - по новому
            else
              is_dom := priem_na_domu(lshifr) // на дому - по старому
              is_zabol := !priem_profilak(lshifr) // по поводу заболевания
              if is_zabol .and. left(human->KOD_DIAG,1) == "Z" // профилактический приём
                is_zabol := .f.
              endif
            endif
          elseif eq_any(k,3,4,5) // дневной стационар
            ii := k
          endif
          if ii == 1 // стационар
            yes_30 := .t.
            aadd(au_su1,{hu_->PROFIL,mkol})
            //aadd(au_su1,{human_2->PROFIL_K,mkol})
          elseif ii == 2  // поликлиника
            yes_30 := .t.
            select TMP
            for i := 0 to 4
              lkod := {0,hu->kod_vr,hu_->PROFIL,ret_new_prvs(hu_->PRVS),hu->u_kod}[i+1]
              find (str(i,1)+str(lkod,9))
              if !found()
                append blank
                tmp->tip := i
                tmp->kod := lkod
              endif
              if is_dom
                tmp->p9 += mkol
                if is_selo
                  tmp->p10 += mkol
                endif
                if is_zabol
                  tmp->p11 += mkol
                endif
                if mvozrast < 18
                  tmp->p12 += mkol
                  if is_zabol
                    tmp->p13 += mkol
                  endif
                endif
              else
                tmp->p3 += mkol
                if is_selo
                  tmp->p4 += mkol
                endif
                if mvozrast < 18
                  tmp->p5 += mkol
                endif
                if is_zabol
                  if is_selo
                    tmp->p6 += mkol
                  endif
                  if mvozrast >= 18
                    tmp->p7 += mkol
                  else
                    tmp->p8 += mkol
                  endif
                endif
              endif
            next
          endif
        endif
      next
    endif
    select HU
    skip
  enddo
endif
if yes_30
  ++jh1
  for j := 1 to len(au_su1) // стационар
    select TMP1
    for i := 0 to 1
      lkod := iif(i == 0, 0, au_su1[j,1])
      find (str(i,1)+str(lkod,9))
      if !found()
        append blank
        tmp1->tip := i
        tmp1->kod := lkod
      endif
      tmp1->p14 += au_su1[j,2]
      if fl_pensioner
        tmp1->p15 += au_su1[j,2]
      endif
      if j == len(au_su1)
        tmp1->p5 ++
        if is_selo
          tmp1->p6 ++
        endif
        if mvozrast < 18
          tmp1->p7 ++
        endif
        if fl_pensioner
          tmp1->p8 ++
        endif
        if fl_death
          tmp1->p12 ++
          if fl_pensioner
            tmp1->p13 ++
          endif
        else
          tmp1->p9 ++
          if fl_pensioner
            tmp1->p10 ++
          endif
          if human_->RSLT_NEW == 103 // Переведён в дневной стационар
            tmp1->p11 ++
          endif
        endif
      endif
    next
  next
endif
return jh+1

***** 03.12.15
Function f2_f30(s1,s2,par)
Local i, s, lal := "tmp->p", n1 := 3, n2 := 13
if s2 == NIL
  s := padr(s1,26)
else
  s := padr(s1,23)+" "+s2
endif
if par != NIL .and. par == 2
  n1 := 5 ; n2 := 15 ; lal := "tmp1->p"
endif
for i := n1 to n2
  s += put_val(&(lal+lstr(i)),7)
next
if verify_FF(HH,.t.,sh)
  aeval(arr_title, {|x| add_string(x) } )
endif
add_string(s)
return NIL

*

***** 08.01.19
Function f1_f30_dop(jh,jh1)
Local i, j, k, n, mvozrast, is_selo, is_dom, is_zabol, fl_stom_new := .f., au_lu := {}, au_flu := {}, ;
      lshifr, lshifr1, yes_30 := .f., fl_pensioner := .f., fl_death := .f., ;
      d2_year := year(human->k_data), au_su1 := {}, vid_vp := 0 // по умолчанию профилактика
if human_->NOVOR > 0
  mvozrast := count_years(human_->DATE_R2,human->n_data)
else
  mvozrast := count_years(human->date_r,human->n_data)
endif
is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog)  // признак села
if (human->pol == "Ж" .and. mvozrast >= 55) .or. ;
   (human->pol == "М" .and. mvozrast >= 60)
  fl_pensioner := .t.
endif
if is_death(human_->RSLT_NEW) // смерть
  fl_death := .t.
endif
select HU
find (str(human->kod,7))
do while hu->kod == human->kod .and. !eof()
  lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
  if f_paraklinika(usl->shifr,lshifr1,human->k_data)
    lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
    if is_2_stomat(lshifr,,.t.) > 0
      fl_stom_new := .t.
      aadd(au_lu,{lshifr, ;              // 1
                  c4tod(hu->date_u), ;   // 2
                  hu_->profil, ;         // 3
                  hu_->PRVS, ;           // 4
                  alltrim(usl->shifr), ; // 5
                  hu->kol_1, ;           // 6
                  c4tod(hu->date_u), ;   // 7
                  hu_->kod_diag, ;       // 8
                  hu->(recno()), ;       // 9 - номер записи
                  0})                   // 10 - для возврата
    endif
    if eq_any(left(lshifr,5),"2.80.","2.82.")
      vid_vp := 1 // в неотложной форме или Посещение в приёмном покое
      exit
    elseif eq_any(left(lshifr,5),"2.78.","2.89.")
      vid_vp := 2 // по поводу заболевания
      exit
    elseif left(lshifr,5) == "2.88."
      vid_vp := 2 // разовое по поводу заболевания
      exit
    elseif d2_year < 2016 .and. left(lshifr,3) == "57." // стоматология
      for i := 1 to 3
        ar := {}
        f_vid_p_stom({},{},ar,{i})
        if ascan(ar,lshifr) > 0
          if i == 1 // с лечебной целью
            vid_vp := 3 // по поводу заболевания
          elseif i == 2 // // с профилактической целью
            vid_vp := 1 // профилактика
          else // // при оказании неотложной помощи
            vid_vp := 2 // в неотложной форме
          endif
          exit
        endif
      next
      if vid_vp > 0
        --vid_vp
        exit
      endif
    endif
  endif
  select HU
  skip
enddo
is_zabol := (vid_vp > 0)
if fl_stom_new
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    aadd(au_flu,{mosu->shifr1, ;         // 1
                 c4tod(mohu->date_u), ;  // 2
                 mohu->profil, ;         // 3
                 mohu->PRVS, ;           // 4
                 mosu->shifr, ;          // 5
                 mohu->kol_1, ;          // 6
                 c4tod(mohu->date_u2), ; // 7
                 mohu->kod_diag, ;       // 8
                 mohu->(recno()), ;      // 9 - номер записи
                 0})                    // 10 - для возврата
    select MOHU
    skip
  enddo
  f_vid_p_stom(au_lu,{},,,human->k_data,,,,au_flu)
  for j := 1 to len(au_flu)
    if au_flu[j,10] == 1 // является врачебным приёмом
      mohu->(dbGoto(au_flu[j,9]))
      is_dom := .f. // на дому
      yes_30 := .t.
      mkol := au_flu[j,6]
      select TMP2
      for i := 0 to 4
        lkod := {0,mohu->kod_vr,mohu->PROFIL,ret_new_prvs(mohu->PRVS),mohu->u_kod}[i+1]
        if i == 4 ; i := 5 ; endif
        find (str(i,1)+str(lkod,9))
        if !found()
          append blank
          tmp2->tip := i
          tmp2->kod := lkod
        endif
        tmp2->p2 += mkol
        if is_selo             // село
          tmp2->p3 += mkol
        endif
        if fl_pensioner        // старше трудоспособного
          tmp2->p4 += mkol
          if is_selo
            tmp2->p5 += mkol    // страше трудосп+село
          endif
        endif
        if mvozrast < 18       //  дети до 18 лет
          tmp2->p6 += mkol
          if mvozrast < 15
            tmp2->p7 += mkol    //  дети до 15 лет
          endif
          if is_selo
            tmp2->p8 += mkol    //  дети до 18 лет +село
          endif
        endif
        if is_zabol
          tmp2->p9 += mkol      // всего по заболеванию
          if is_selo
            tmp2->p10 += mkol   // село
          endif
          if mvozrast >= 18
            tmp2->p11 += mkol   // старше 18 лет
            if fl_pensioner
              tmp2->p12 += mkol // старше трудоспособного
            endif
          else
            tmp2->p13 += mkol   //  дети до 18 лет
            if mvozrast < 15
              tmp2->p14 += mkol //  дети до 15 лет
            endif
            if is_selo
              tmp2->p15 += mkol //  дети до 18 лет + село
            endif
          endif
        endif
      next
    endif
  next
else
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
            if year(human->k_data) > 2012
              is_dom := (hu->kol_rcp < 0 .and. DomUslugaTFOMS(lshifr)) // на дому - по новому
            else
              is_dom := priem_na_domu(lshifr) // на дому - по старому
              is_zabol := !priem_profilak(lshifr) // по поводу заболевания
              if is_zabol .and. left(human->KOD_DIAG,1) == "Z" // профилактический приём
                is_zabol := .f.
              endif
            endif
          elseif eq_any(k,3,4,5) // дневной стационар
            ii := k
          endif
          if ii == 1 // стационар
            //yes_30 := .t.
            //aadd(au_su1,{hu_->PROFIL,mkol})
          elseif ii == 2  // поликлиника
            yes_30 := .t.
            select TMP2
            for i := 0 to 4
              lkod := {0,hu->kod_vr,hu_->PROFIL,ret_new_prvs(hu_->PRVS),hu->u_kod}[i+1]
              find (str(i,1)+str(lkod,9))
              if !found()
                append blank
                tmp2->tip := i
                tmp2->kod := lkod
              endif
              tmp2->p2 += mkol
              if is_selo             // село
                tmp2->p3 += mkol
              endif
              if fl_pensioner        // старше трудоспособного
                tmp2->p4 += mkol
                if is_selo
                  tmp2->p5 += mkol    // страше трудосп+село
                endif
              endif
              if mvozrast < 18       //  дети до 18 лет
                tmp2->p6 += mkol
                if mvozrast < 15
                  tmp2->p7 += mkol    //  дети до 15 лет
                endif
                if is_selo
                  tmp2->p8 += mkol    //  дети до 18 лет +село
                endif
              endif
              if is_zabol
                tmp2->p9 += mkol      // всего по заболеванию
                if is_selo
                  tmp2->p10 += mkol   // село
                endif
                if mvozrast >= 18
                  tmp2->p11 += mkol   // старше 18 лет
                  if fl_pensioner
                    tmp2->p12 += mkol // старше трудоспособного
                  endif
                else
                  tmp2->p13 += mkol   //  дети до 18 лет
                  if mvozrast < 15
                    tmp2->p14 += mkol //  дети до 15 лет
                  endif
                  if is_selo
                    tmp2->p15 += mkol //  дети до 18 лет + село
                  endif
                endif
              endif
            next
          endif
        endif
      next
    endif
    select HU
    skip
  enddo
endif
return jh+1

***** 08.01.19
Function f2_f30_dop(s1,s2,par)
Local i, s, lal := "tmp2->p", n1 := 2, n2 := 15
s := padr(s1,23) //+s2
for i := n1 to n2
  s += put_val(&(lal+lstr(i)),6)
next
if verify_FF(HH,.t.,sh)
  aeval(arr_title, {|x| add_string(x) } )
endif
add_string(s)
return NIL




*

***** 18.03.13
Function forma_39(k)
Static si1 := 1, si2 := 1
Local mas_pmt, mas_msg, mas_fun, j, uch_otd
DEFAULT k TO 1
do case
  case k == 1
    Private au1, au2, au3, au4, au5 := 2, au6, fl_povod, lp := array(23), ;
            _arr_if, _what_if := _init_if(), _arr_komit := {}
    get_nastr(.f.)
    mas_pmt := {"Форма 39 по ~врачу", ;
                "Форма 39 по ~отделению", ;
                "Форма 39 по ~учреждению", ;
                "Форма 39 по орг~анизации", ;
                "~Настройка формы 39 "+iif(au5==2,"[вкл]","[выкл]")}
    mas_msg := {"Распечатка формы 39 по врачу", ;
                "Распечатка формы 39 по отделению", ;
                "Распечатка формы 39 по лечебному учреждению", ;
                "Распечатка формы 39 по организации, в которой более одного учреждения", ;
                "Настройка для составления формы 39"}
    mas_fun := {"forma_39(11)", ;
                "forma_39(12)", ;
                "forma_39(13)", ;
                "forma_39(14)", ;
                "forma_39(15)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    forma_39_()
  case k == 12
    forma_39otd()
  case k == 13
    forma_39all()
  case k == 14
    forma_39org()
  case k == 15
    mas_pmt := {'"Посещений в п-ке по поводу заболеваний"', ;
                '"Профилактических приемов в п-ке"', ;
                '"Посещений на дому по поводу заболеваний"', ;
                '"Профилактических приемов на дому"', ;
                iif(au5==1,"ВКЛ","ВЫКЛ")+'ючение режима исправления', ;
                'Включение и настройка работы с поводом обращения', ;
                'Ввод плана работы отделений'}
    mas_msg := {'Настройка колонки "Посещений в п-ке по поводу заболеваний" (колонка N 6)', ;
                'Настройка колонки "Профилактических приемов в п-ке" (колонка N 9)', ;
                'Настройка колонки "Посещений на дому по поводу заболеваний" (колонка N 11)', ;
                'Настройка колонки "Профилактических приемов на дому" (колонки N 15-16)', ;
                'Включение/выключение режима исправления формы 39', ;
                'Включение и настройка работы с поводом обращения', ;
                'Ввод плана работы отделений'}
    mas_fun := {"forma_39(21)", ;
                "forma_39(22)", ;
                "forma_39(23)", ;
                "forma_39(24)", ;
                "forma_39(25)", ;
                "forma_39(26)", ;
                "forma_39(27)"}
    popup_prompt(T_ROW-3-len(mas_pmt),T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case between(k,21,24)
    forma_39_na(k-20)
  case k == 25
    nfile := dir_server+f39_nastr
    name_sect := f39_sect+"5"
    name_var := "ИСПРАВЛЕНИЕ"
    ar := GetIniVar(nFile,{{name_sect,name_var,"2"}})
    if (j := f_alert({'Выполнять исправление формы 39 ?', ;
                      ""}, ;
                      {" ~Нет ", ;
                       " ~Да "}, ;
                      int(val(ar[1])),"N+/BG*","R/BG*",18,,col1menu )) > 0
      SetIniVar(nFile,{{name_sect,name_var,j}})
      if au5 != j
        keyboard chr(K_ESC)+chr(K_ESC)+chr(K_ENTER)
      endif
    endif
  case k == 26
    forma_39_povod()
  case k == 27
    plan_39()
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

***** 07.02.13
Function forma_39_()
Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
      fl_exit := .f., HH := 58, reg_print := 3, speriod, ;
      arr_title, name_file := "_form_39"+stxt, s_lu := 0, s_human := 0, ;
      kh := 0, jh := 0, arr_m, arr_pl
if !get_nastr()
  return NIL
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
  return NIL
endif
if (arr_pl := ret_oms_pl(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if ascan(arr_pl,F_YES_OMS) > 0 .and. !fbp_ist_fin(T_ROW,T_COL-5)
  return NIL
endif
if !input_perso(T_ROW,T_COL-5,.f.)
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
speriod := arr_m[4]
begin_date := arr_m[7]
end_date := arr_m[8]
//
WaitStatus(iif(au5==2,"В","Вы")+"ключен режим исправления")
mark_keys({"<Esc>"})
//
cre_tmp({{"data","C",4,0}})
use (cur_dir+"tmp") new alias TMP
index on data to (cur_dir+"tmp")
R_Use(dir_server+"mo_otd",,"OTD")
if ascan(arr_pl,F_YES_OMS) > 0
  if pi1 == 1  // по дате окончания лечения
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    set relation to recno() into HUMAN_
    dbseek(dtos(arr_m[5]),.t.)
    do while human->k_data <= arr_m[6] .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if human_->oplata < 9 .and. func_pi_schet() .and. (arr := yes_f_39(1,glob_human[1])) != NIL
        ++jh
        for i := 1 to len(arr)
          select TMP
          find (arr[i,1])  // поиск по дате услуги
          if !found()
            append blank
            tmp->data := arr[i,1]
          endif
          write_f39(arr[i])
        next
      endif
      @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
      if jh > 0
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jh) color cColorStMsg
      endif
      select HUMAN
      skip
    enddo
  else
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humans","HUMAN")
    set relation to recno() into HUMAN_
    R_Use(dir_server+"schet_",,"SCHET_")
    R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
    set relation to recno() into SCHET_
    set filter to empty(schet_->IS_DOPLATA)
    dbseek(begin_date,.t.)
    do while schet->pdate <= end_date .and. !eof()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select HUMAN
      find (str(schet->kod,6))
      do while human->schet == schet->kod .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if human_->oplata < 9 .and. (arr := yes_f_39(1,glob_human[1])) != NIL
          ++jh
          for i := 1 to len(arr)
            select TMP
            find (arr[i,1])  // поиск по дате услуги
            if !found()
              append blank
              tmp->data := arr[i,1]
            endif
            write_f39(arr[i])
          next
        endif
        @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
        if jh > 0
          @ row(),col() say "/" color "W/R"
          @ row(),col() say lstr(jh) color cColorStMsg
        endif
        select HUMAN
        skip
      enddo
      if fl_exit ; exit ; endif
      select SCHET
      skip
    enddo
  endif
endif
if ascan(arr_pl,F_YES_PL) > 0
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU_P")
  R_Use(dir_server+"hum_p",dir_server+"hum_pd","HUM_P")
  dbseek(dtos(arr_m[5]),.t.)
  do while hum_p->k_data <= arr_m[6] .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if (arr := yes_f_39_pl(1,glob_human[1])) != NIL
      ++jh
      for i := 1 to len(arr)
        select TMP
        find (arr[i,1])  // поиск по дате услуги
        if !found()
          append blank
          tmp->data := arr[i,1]
        endif
        write_f39(arr[i])
      next
    endif
    @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
    if jh > 0
      @ row(),col() say "/" color "BG/R"
      @ row(),col() say lstr(jh) color cColorStMsg
    endif
    select HUM_P
    skip
  enddo
endif
j := tmp->(lastrec())
Private regim := 1
arr_title := f39_title()
Private sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
f39_shapka()
titleN_uch(st_a_uch,sh,lcount_uch)
_tit_ist_fin(sh)
s := " Ф.И.О. и должность врача: "+alltrim(glob_human[2])
s += " ["+lstr(glob_human[5])+"]"   // таб.номер
if len(glob_human) > 5 .and. !empty(glob_human[6])
  s += " ("+glob_human[6]+")"       // должность
endif
frt->name1 := s
add_string(s)
if pi1 == 1
  s := " "+str_pi_schet()
else
  s := " [ по дате выписки счета ]"
endif
frt->name2 := speriod+s
add_string("                           "+speriod+s)
s := " Участок: территориальный № ________ цеховой № ________"
add_string(s)
frt->name3 := s
//
Private sp[20]
afill(sp,0)
select TMP
go top
aeval(arr_title, {|x| add_string(x) } )
arr_title := f39_title2()
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  f_str_39(left(dtoc(c4tod(tmp->data)),5),1)
  select TMP
  skip
enddo
add_string(replicate("-",sh))
f_str_39("Всего",2)
add_string("")
frt->name5 := "Подпись врача ________________"
fclose(fp)
close databases
rest_box(buf)
if j == 0
  func_error(4,"Нет информации!")
else
  name_fr := "mo_f39"+sfr3
  if _upr_epson() .or. !file(dir_exe+name_fr)
    viewtext(name_file,,,,.t.,,,reg_print)
  else
    call_fr(name_fr)
  endif
endif
return NIL

***** 23.12.12
Function f39_shapka()
Local arr_org := array(3)
R_Use(dir_server+"organiz",,"ORG")
perenos(arr_org,org->name,30)
frt->name_org := org->name
org->(dbCloseArea())
add_string(padc("Министерство здравоохранения",30)+      padl("Форма № 039/у-02",sh-30))
add_string(padc("Российской Федерации",        30)+   padl("Утверждена Приказом",sh-30))
add_string(padc(alltrim(arr_org[1]),           30)+      padl("Минздрава России",sh-30))
add_string(padc(alltrim(arr_org[2]),           30)+ padl("от 30.12.2002г. N 413",sh-30))
add_string(padc(alltrim(arr_org[3]),           30))
add_string(center("ВЕДОМОСТЬ",sh))
add_string(center("УЧЕТА ВРАЧЕБНЫХ ПОСЕЩЕНИЙ",sh))
add_string(center("В АМБУЛАТОРНО - ПОЛИКЛИНИЧЕСКИХ УЧРЕЖДЕНИЯХ, НА ДОМУ",sh))
add_string("")
return NIL

***** 23.12.12
Function f39_title()
Local arr := array(15)
if regim == 1
  arr[ 1] := "─────"
  arr[ 2] := "Дата "
  arr[ 3] := "     "
  arr[ 4] := "     "
  arr[ 5] := "     "
  arr[ 6] := "     "
  arr[ 7] := "     "
  arr[ 8] := "     "
  arr[ 9] := "     "
  arr[10] := "     "
  arr[11] := "     "
  arr[12] := "     "
  arr[13] := "─────"
  arr[14] := "1    "
  arr[15] := "─────"
  frt->name4 := "Дата"
else
  arr[ 1] := "────────────────"
  arr[ 2] := "                "
  arr[ 3] := "                "
  arr[ 4] := "                "
  arr[ 5] := "                "
  arr[ 6] := "                "
  arr[ 7] := "                "
  arr[ 8] := "                "
  arr[ 9] := "                "
  arr[10] := "                "
  arr[11] := "                "
  arr[12] := "                "
  arr[13] := "────────────────"
  arr[14] := "1               "
  arr[15] := "────────────────"
endif
arr[ 1] := arr[ 1]+"┬───────────┬───────────┬─────────────────┬─────┬─────┬───────────────────────────────────┬───────────────────────"
arr[ 2] := arr[ 2]+"│Число по-  │в том числе│из общего числа  │профи│Число│ из общего числа посещений на дому │    Число посещений    "
arr[ 3] := arr[ 3]+"│сещений в  │в возрасте │посещений в поли-│лакти│посе-│                                   │    по видам оплаты    "
arr[ 4] := arr[ 4]+"│поликлинике│(из графы  │клинике по поводу│чес- │щений├───────────────────────┬───────────┼─────┬─────┬─────┬─────"
arr[ 5] := arr[ 5]+"│           │2)         │заболеваний      │ких  │на   │ по поводу заболеваний │из числа   │ ОМС │бюд- │плат-│ ДМС "
arr[ 6] := arr[ 6]+"├─────┬─────┤           ├─────┬───────────┤     │дому ├─────┬─────────────────┤профилакти-│     │жет  │ные  │     "
arr[ 7] := arr[ 7]+"│всего│из   │           │всего│в т.ч.     │     │(все-│всего│в т.ч. в возрасте│ческих     │     │     │     │     "
arr[ 8] := arr[ 8]+"│     │них  │           │     │в возрасте │     │го)  │     ├─────┬─────┬─────┼─────┬─────┤     │     │     │     "
arr[ 9] := arr[ 9]+"│     │сель-├─────┬─────┤     ├─────┬─────┤     │     │     │0-17 │в    │60лет│0-17 │в    │     │     │     │     "
arr[10] := arr[10]+"│     │cких │0-17 │60лет│     │0-17 │60лет│     │     │     │лет  │т.ч. │и ста│лет  │т.ч. │     │     │     │     "
arr[11] := arr[11]+"│     │жите-│лет  │и ста│     │лет  │и ста│     │     │     │     │0-1  │рше  │     │0-1  │     │     │     │     "
arr[12] := arr[12]+"│     │лей  │     │рше  │     │     │рше  │     │     │     │     │год  │     │     │год  │     │     │     │     "
arr[13] := arr[13]+"┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────"
arr[14] := arr[14]+"│2    │3    │4    │5    │6    │7    │8    │9    │10   │11   │12   │13   │14   │15   │16   │17   │18   │19   │20   "
arr[15] := arr[15]+"┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────"
return arr

*****
Function f39_title2()
Local arr := array(3)
if regim == 1
  arr[1] := "─────"
  arr[2] := "1    "
  arr[3] := "─────"
else
  arr[1] := "────────────────"
  arr[2] := "1               "
  arr[3] := "────────────────"
endif
arr[1] := arr[1]+"┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────"
arr[2] := arr[2]+"│2    │3    │4    │5    │6    │7    │8    │9    │10   │11   │12   │13   │14   │15   │16   │17   │18   │19   │20   "
arr[3] := arr[3]+"┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────"
return arr

*

***** 07.02.13
Function forma_39otd()
Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
      fl_exit := .f., HH := 58, reg_print := 3, speriod, ;
      arr_title, name_file := "_form_39"+stxt, s_lu := 0, s_human := 0, ;
      kh := 0, jh := 0, arr_m, arr_pl
if !get_nastr()
  return NIL
endif
if input_uch(T_ROW,T_COL-5,sys_date) == NIL .or. input_otd(T_ROW,T_COL-5,sys_date) == NIL
  return NIL
endif
if (arr_pl := ret_oms_pl(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if ascan(arr_pl,F_YES_OMS) > 0 .and. !fbp_ist_fin(T_ROW,T_COL-5)
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
speriod := arr_m[4]
begin_date := arr_m[7]
end_date := arr_m[8]
//
WaitStatus(iif(au5==2,"В","Вы")+"ключен режим исправления")
//
cre_tmp({{"p_kod","N",4,0}, ;
         {"tab_nom","N",5,0}, ;
         {"name","C",30,0}})
use (cur_dir+"tmp") new alias TMP
index on str(p_kod,4) to (cur_dir+"tmp")
R_Use(dir_server+"mo_otd",,"OTD")
if ascan(arr_pl,F_YES_OMS) > 0
  if pi1 == 1  // по дате окончания лечения
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    set relation to recno() into HUMAN_
    dbseek(dtos(arr_m[5]),.t.)
    do while human->k_data <= arr_m[6] .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if human_->oplata < 9 .and. func_pi_schet() .and. (arr := yes_f_39(2,glob_otd[1])) != NIL
        ++jh
        for i := 1 to len(arr)
          select TMP
          find (str(arr[i,21],4))  // поиск по коду врача
          if !found()
            append blank
            tmp->p_kod := arr[i,21]
          endif
          write_f39(arr[i])
        next
      endif
      @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
      if jh > 0
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jh) color cColorStMsg
      endif
      select HUMAN
      skip
    enddo
  else
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humans","HUMAN")
    set relation to recno() into HUMAN_
    R_Use(dir_server+"schet_",,"SCHET_")
    R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
    set relation to recno() into SCHET_
    set filter to empty(schet_->IS_DOPLATA)
    dbseek(begin_date,.t.)
    do while schet->pdate <= end_date .and. !eof()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select HUMAN
      find (str(schet->kod,6))
      do while human->schet == schet->kod .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if human_->oplata < 9 .and. (arr := yes_f_39(2,glob_otd[1])) != NIL
          ++jh
          for i := 1 to len(arr)
            select TMP
            find (str(arr[i,21],4))  // поиск по коду врача
            if !found()
              append blank
              tmp->p_kod := arr[i,21]
            endif
            write_f39(arr[i])
          next
        endif
        @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
        if jh > 0
          @ row(),col() say "/" color "W/R"
          @ row(),col() say lstr(jh) color cColorStMsg
        endif
        select HUMAN
        skip
      enddo
      if fl_exit ; exit ; endif
      select SCHET
      skip
    enddo
  endif
endif
if ascan(arr_pl,F_YES_PL) > 0
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU_P")
  R_Use(dir_server+"hum_p",dir_server+"hum_pd","HUM_P")
  dbseek(dtos(arr_m[5]),.t.)
  do while hum_p->k_data <= arr_m[6] .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if (arr := yes_f_39_pl(2,glob_otd[1])) != NIL
      ++jh
      for i := 1 to len(arr)
        select TMP
        find (str(arr[i,21],4))  // поиск по коду врача
        if !found()
          append blank
          tmp->p_kod := arr[i,21]
        endif
        write_f39(arr[i])
      next
    endif
    @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
    if jh > 0
      @ row(),col() say "/" color "BG/R"
      @ row(),col() say lstr(jh) color cColorStMsg
    endif
    select HUM_P
    skip
  enddo
endif
if (j := tmp->(lastrec())) > 0
  R_Use(dir_server+"mo_pers",,"P2")
  tmp->(dbeval({|| p2->(dbgoto(tmp->p_kod)), ;
                   tmp->tab_nom := p2->tab_nom, ;
                   tmp->name := fam_i_o(p2->fio) } ))
  select TMP
  index on upper(name) to (cur_dir+"tmp")
endif
Private regim := 2
arr_title := f39_title()
Private sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
f39_shapka()
_tit_ist_fin(sh)
s := alltrim(glob_otd[2])+" ("+alltrim(glob_uch[2])+")"
add_string(center(s,sh))
frt->name1 := s
s := "Отчетный период: "+speriod
add_string(center(s,sh))
frt->name2 := s
if pi1 == 1
  s := str_pi_schet()
else
  s := "[ по дате выписки счета ]"
endif
add_string(center(s,sh))
frt->name3 := s
add_string("")
//
Private sp[20]
afill(sp,0)
select TMP
go top
aeval(arr_title, {|x| add_string(x) } )
arr_title := f39_title2()
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  ls1 := lstr(tmp->tab_nom,6)+"/"+tmp->name
  f_str_39(left(ls1,16),1,ls1)
  select TMP
  skip
enddo
add_string(replicate("-",sh))
f_str_39(padc("Всего:",16),2)
fclose(fp)
close databases
rest_box(buf)
if j == 0
  func_error(4,"Нет информации!")
else
  name_fr := "mo_f39"+sfr3
  if _upr_epson() .or. !file(dir_exe+name_fr)
    viewtext(name_file,,,,.t.,,,reg_print)
  else
    call_fr(name_fr)
  endif
endif
return NIL

*

***** 07.02.13
Function forma_39all()
Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
      fl_exit := .f., tm, ;
      s_lu := 0, s_human := 0, ;
      kh := 0, jh := 0, arr_m, arr_pl
if !get_nastr()
  return NIL
endif
if input_uch(T_ROW,T_COL-5,sys_date) == NIL
  return NIL
endif
if (arr_pl := ret_oms_pl(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if ascan(arr_pl,F_YES_OMS) > 0 .and. !fbp_ist_fin(T_ROW,T_COL-5)
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
Private speriod := arr_m[4]
begin_date := arr_m[7]
end_date := arr_m[8]
//
WaitStatus(iif(au5==2,"В","Вы")+"ключен режим исправления")
//
cre_tmp({{"p_kod","N",4,0}, ;
         {"tip","N",1,0}, ;   // 1-весь персонал, 2-перс.в отделении, 3-отделение
         {"otd","N",3,0}, ;
         {"tab_nom","N",5,0}, ;
         {"name","C",30,0}})
use (cur_dir+"tmp") new alias TMP
index on str(tip,1)+str(p_kod,4)+str(otd,3) to (cur_dir+"tmp")
R_Use(dir_server+"mo_otd",,"OTD")
if ascan(arr_pl,F_YES_OMS) > 0
  if pi1 == 1  // по дате окончания лечения
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    set relation to recno() into HUMAN_
    dbseek(dtos(arr_m[5]),.t.)
    do while human->k_data <= arr_m[6] .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if human_->oplata < 9 .and. func_pi_schet() .and. (arr := yes_f_39(0)) != NIL
        ++jh
        for i := 1 to len(arr)
          select TMP
          find ("1"+str(arr[i,21],4))  // поиск по коду врача
          if !found()
            append blank
            tmp->p_kod := arr[i,21]
            tmp->tip := 1
          endif
          write_f39(arr[i])
          select TMP
          find ("2"+str(arr[i,21],4)+str(arr[i,22],3)) // врач+отделение
          if !found()
            append blank
            tmp->p_kod := arr[i,21]
            tmp->otd := arr[i,22]
            tmp->tip := 2
          endif
          write_f39(arr[i])
          select TMP
          find ("3"+str(0,4)+str(arr[i,22],3))  // учреждение+отделения
          if !found()
            append blank
            tmp->otd := arr[i,22]
            tmp->tip := 3
          endif
          write_f39(arr[i])
        next
      endif
      @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
      if jh > 0
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jh) color cColorStMsg
      endif
      select HUMAN
      skip
    enddo
  else
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humans","HUMAN")
    set relation to recno() into HUMAN_
    R_Use(dir_server+"schet_",,"SCHET_")
    R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
    set relation to recno() into SCHET_
    set filter to empty(schet_->IS_DOPLATA)
    dbseek(begin_date,.t.)
    do while schet->pdate <= end_date .and. !eof()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select HUMAN
      find (str(schet->kod,6))
      do while human->schet == schet->kod
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if human_->oplata < 9 .and. (arr := yes_f_39(0)) != NIL
          ++jh
          for i := 1 to len(arr)
            select TMP
            find ("1"+str(arr[i,21],4))  // поиск по коду врача
            if !found()
              append blank
              tmp->p_kod := arr[i,21]
              tmp->tip := 1
            endif
            write_f39(arr[i])
            select TMP
            find ("2"+str(arr[i,21],4)+str(arr[i,22],3)) // врач+отделение
            if !found()
              append blank
              tmp->p_kod := arr[i,21]
              tmp->otd := arr[i,22]
              tmp->tip := 2
            endif
            write_f39(arr[i])
            select TMP
            find ("3"+str(0,4)+str(arr[i,22],3))  // учреждение+отделения
            if !found()
              append blank
              tmp->otd := arr[i,22]
              tmp->tip := 3
            endif
            write_f39(arr[i])
          next
        endif
        @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
        if jh > 0
          @ row(),col() say "/" color "W/R"
          @ row(),col() say lstr(jh) color cColorStMsg
        endif
        select HUMAN
        skip
      enddo
      if fl_exit ; exit ; endif
      select SCHET
      skip
    enddo
  endif
endif
if ascan(arr_pl,F_YES_PL) > 0
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU_P")
  R_Use(dir_server+"hum_p",dir_server+"hum_pd","HUM_P")
  dbseek(dtos(arr_m[5]),.t.)
  do while hum_p->k_data <= arr_m[6] .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if (arr := yes_f_39_pl(0)) != NIL
      ++jh
      for i := 1 to len(arr)
        select TMP
        find ("1"+str(arr[i,21],4))  // поиск по коду врача
        if !found()
          append blank
          tmp->p_kod := arr[i,21]
          tmp->tip := 1
        endif
        write_f39(arr[i])
        select TMP
        find ("2"+str(arr[i,21],4)+str(arr[i,22],3)) // врач+отделение
        if !found()
          append blank
          tmp->p_kod := arr[i,21]
          tmp->otd := arr[i,22]
          tmp->tip := 2
        endif
        write_f39(arr[i])
        select TMP
        find ("3"+str(0,4)+str(arr[i,22],3))  // учреждение+отделения
        if !found()
          append blank
          tmp->otd := arr[i,22]
          tmp->tip := 3
        endif
        write_f39(arr[i])
      next
    endif
    @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
    if jh > 0
      @ row(),col() say "/" color "BG/R"
      @ row(),col() say lstr(jh) color cColorStMsg
    endif
    select HUM_P
    skip
  enddo
endif
if (j := tmp->(lastrec())) > 0
  if select("OTD") == 0
    R_Use(dir_server+"mo_otd",,"OTD")
  endif
  R_Use(dir_server+"mo_pers",,"P2")
  tmp->(dbeval({|| p2->(dbgoto(tmp->p_kod)), otd->(dbgoto(tmp->otd)), ;
                   tmp->tab_nom := p2->tab_nom, ;
                   tmp->name := iif(tmp->tip==3, otd->name, fam_i_o(p2->fio)) } ))
endif
close databases
rest_box(buf)
if j == 0
  return func_error(4,"Нет информации!")
endif
if type("MenuTo_Minut") == "N"
  tm := MenuTo_Minut
else
  Private MenuTo_Minut
endif
mybell()
MenuTo_Minut := 0  // не выходить автоматически из MENU TO
keyboard ""
popup_prompt(T_ROW-7,T_COL-5,1, ;
  {"Список ~отделений", ;
   "Список ~персонала", ;
   "Персонал в о~тделении", ;
   "Отделения план/~факт"},, ;
  {"f_39all_1(3)", ;
   "f_39all_1(1)", ;
   "f_39all_1(2)", ;
   "f_39all_2(3)"})
MenuTo_Minut := tm
return NIL

*

***** 05.02.13
Function f_39all_1(par)
Static sotd := 1
Local buf, HH := 58, reg_print := 3, ;
      arr_title, name_file := "_form_39"+stxt, s, ls1, ;
      arr := {}, arr_otd := {}, r := T_ROW, r2, c := T_COL-5, i
if par == 2
  buf := savescreen(r,0,maxrow(),maxcol())
  use (cur_dir+"tmp") new
  index on upper(name) to (cur_dir+"tmp") for tip == 3
  dbeval({|| aadd(arr, tmp->otd), aadd(arr_otd,tmp->name) } )
  use
  i := ascan(arr, sotd)
  if (r2 := r+len(arr)+1) > maxrow()-2
    r2 := maxrow()-2
  endif
  status_key("^<Esc>^ - выход без выбора;  ^<Enter>^ - выбор отделения")
  if (i := popup(r,c,r2,c+33,arr_otd,i,color0,.t.)) > 0
    glob_otd := {arr[i], alltrim(arr_otd[i])}
    sotd := arr[i]
  endif
  restscreen(r,0,maxrow(),maxcol(),buf)
  if i == 0 ; return NIL ; endif
endif
buf := save_maxrow()
mywait()
use (fr_data) new alias FRD
zap
use (fr_titl) new alias FRT
use (cur_dir+"tmp") new
do case
  case par == 1
    index on upper(name) to (cur_dir+"tmp") for tip == 1
  case par == 2
    index on upper(name) to (cur_dir+"tmp") for tip == 2 .and. otd == glob_otd[1]
  case par == 3
    index on upper(name) to (cur_dir+"tmp") for tip == 3
endcase
Private regim := 2
arr_title := f39_title()
Private sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
f39_shapka()
_tit_ist_fin(sh)
s := alltrim(glob_uch[2])
if par == 2
  s := glob_otd[2] + " [ "+s+" ]"
endif
frt->name1 := s
add_string(center(s,sh))
s := "Отчетный период: "+speriod
frt->name2 := s
add_string(center(s,sh))
if pi1 == 1
  s := str_pi_schet()
else
  s := "[ по дате выписки счета ]"
endif
frt->name3 := s
add_string(center(s,sh))
add_string("")
//
Private sp[20]
afill(sp,0)
select TMP
go top
aeval(arr_title, {|x| add_string(x) } )
arr_title := f39_title2()
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  if par == 3
    ls1 := tmp->name
  else
    ls1 := lstr(tmp->tab_nom,6)+"/"+tmp->name
  endif
  f_str_39(left(ls1,16),1,ls1)
  select TMP
  skip
enddo
add_string(replicate("-",sh))
f_str_39(padc("Всего:",16),2)
fclose(fp)
close databases
rest_box(buf)
name_fr := "mo_f39"+sfr3
if _upr_epson() .or. !file(dir_exe+name_fr)
  viewtext(name_file,,,,.t.,,,reg_print)
else
  call_fr(name_fr)
endif
return NIL

*

*****
Function f_39all_2(par)
Static sotd := 1
Local buf, sh, HH := 58, reg_print := 3, ;
      arr_title, name_file := "_form_39"+stxt, s, ls1, ;
      arr := {}, arr_otd := {}, r := T_ROW, r2, c := T_COL-5, i
if par == 2
  buf := savescreen(r,0,maxrow(),maxcol())
  use (cur_dir+"tmp") new
  index on upper(name) to (cur_dir+"tmp") for tip == 3
  dbeval({|| aadd(arr, tmp->otd), aadd(arr_otd,tmp->name) } )
  use
  i := ascan(arr, sotd)
  if (r2 := r+len(arr)+1) > maxrow()-2
    r2 := maxrow()-2
  endif
  status_key("^<Esc>^ - выход без выбора;  ^<Enter>^ - выбор отделения")
  if (i := popup(r,c,r2,c+28,arr_otd,i,color0,.t.)) > 0
    glob_otd := {arr[i], alltrim(arr_otd[i])}
    sotd := arr[i]
  endif
  restscreen(r,0,maxrow(),maxcol(),buf)
  if i == 0 ; return NIL ; endif
endif
buf := save_maxrow()
mywait()
use (cur_dir+"tmp") new
do case
  case par == 1
    index on upper(name) to (cur_dir+"tmp") for tip == 1
  case par == 2
    index on upper(name) to (cur_dir+"tmp") for tip == 2 .and. otd == glob_otd[1]
  case par == 3
    index on upper(name) to (cur_dir+"tmp") for tip == 3
endcase
arr_title := {;
 "───────────────────────────────┬────────────────────┬────────────────────┬────────────────────", ;
 "                               │  Врачебных приемов │    Профилактик     │ Посещений на дому  ", ;
 "                               ├──────┬──────┬──────┼──────┬──────┬──────┼──────┬──────┬──────", ;
 "                               │ план │ факт │  %%  │ план │ факт │  %%  │ план │ факт │  %%  ", ;
 "───────────────────────────────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────"}
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Ведомость",sh))
add_string(center("учета врачебных посещений",sh))
add_string(center("в амбулаторно-поликлинических учреждениях, на дому",sh))
s := alltrim(glob_uch[2])
if par == 2
  s := glob_otd[2] + " [ "+s+" ]"
endif
add_string(center(s,sh))
add_string(center("Отчетный период: "+speriod,sh))
add_string("")
//
sp1 := sp2 := sp3 := sp4 := sp5 := sp6 := 0
R_Use(dir_server+"mo_otd",,"OTD")
select TMP
set relation to otd into OTD
go top
aeval(arr_title, {|x| add_string(x) } )
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  if par == 3
    ls1 := tmp->name
  else
    ls1 := alltrim(tmp->name)+" ["+lstr(tmp->tab_nom)+"]"
  endif
  ls1 := padr(ls1,31)
  pr1 := pr2 := pr3 := 0
  if otd->plan_vp > 0
    pr1 := tmp->p2 / otd->plan_vp * 100
  endif
  if otd->plan_pf > 0
    pr2 := tmp->p9 / otd->plan_pf * 100
  endif
  if otd->plan_pd > 0
    pr3 := tmp->p10 / otd->plan_pd * 100
  endif
  ls1 += " "+put_val(otd->plan_vp,6)+;
         " "+put_val(tmp->p2,6)+;
         " "+umest_val(pr1,6,2)+;
         " "+put_val(otd->plan_pf,6)+;
         " "+put_val(tmp->p9,6)+;
         " "+umest_val(pr2,6,2)+;
         " "+put_val(otd->plan_pd,6)+;
         " "+put_val(tmp->p10,6)+;
         " "+umest_val(pr3,6,2)
  add_string(ls1)
  sp1 += otd->plan_vp
  sp2 += tmp->p2
  sp3 += otd->plan_pf
  sp4 += tmp->p9
  sp5 += otd->plan_pd
  sp6 += tmp->p10
  skip
enddo
add_string(replicate("-",sh))
ls1 := padc("Всего:",31)
pr1 := pr2 := pr3 := 0
if sp1 > 0
  pr1 := sp2 / sp1 * 100
endif
if sp3 > 0
  pr2 := sp4 / sp3 * 100
endif
if sp5 > 0
  pr3 := sp6 / sp5 * 100
endif
ls1 += " "+put_val(sp1,6)+;
       " "+put_val(sp2,6)+;
       " "+umest_val(pr1,6,2)+;
       " "+put_val(sp3,6)+;
       " "+put_val(sp4,6)+;
       " "+umest_val(pr2,6,2)+;
       " "+put_val(sp5,6)+;
       " "+put_val(sp6,6)+;
       " "+umest_val(pr3,6,2)
add_string(ls1)
fclose(fp)
close databases
rest_box(buf)
viewtext(name_file,,,,.t.,,,reg_print)
return NIL

*

***** 26.02.17
Function forma_39org()
Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
      fl_exit := .f., tm, ;
      s_lu := 0, s_human := 0, ;
      kh := 0, jh := 0, arr_m, arr_pl
if !get_nastr()
  return NIL
endif
if (arr_pl := ret_oms_pl(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if ascan(arr_pl,F_YES_OMS) > 0 .and. !fbp_ist_fin(T_ROW,T_COL-5)
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
Private speriod := arr_m[4]
begin_date := arr_m[7]
end_date := arr_m[8]
//
WaitStatus(iif(au5==2,"В","Вы")+"ключен режим исправления")
//
cre_tmp({{"p_kod","N",4,0}, ;
         {"tip","N",1,0}, ;   // 1-весь персонал, 2-перс.в отделении, 3-отделение
         {"uch","N",3,0}, ;
         {"otd","N",3,0}, ;
         {"tab_nom","N",5,0}, ;
         {"name","C",30,0}})
use (cur_dir+"tmp") new alias TMP
index on str(tip,1)+str(p_kod,4)+str(uch,3)+str(otd,3) to (cur_dir+"tmp")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"mo_uch",,"UCH")
if ascan(arr_pl,F_YES_OMS) > 0
  if pi1 == 1  // по дате окончания лечения
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    set relation to recno() into HUMAN_
    dbseek(dtos(arr_m[5]),.t.)
    do while human->k_data <= arr_m[6] .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if human_->oplata < 9 .and. func_pi_schet() .and. (arr := yes_f_39(-1)) != NIL
        ++jh
        for i := 1 to len(arr)
          select TMP
          find ("1"+str(arr[i,21],4))  // поиск по коду врача
          if !found()
            append blank
            tmp->p_kod := arr[i,21]
            tmp->tip := 1
          endif
          write_f39(arr[i])
          select TMP
          find ("2"+str(arr[i,21],4)+str(arr[i,23],3)) // врач+учреждение
          if !found()
            append blank
            tmp->p_kod := arr[i,21]
            tmp->uch := arr[i,23]
            tmp->tip := 2
          endif
          write_f39(arr[i])
          select TMP
          find ("3"+str(0,4)+str(arr[i,23],3))  // МО+учреждение
          if !found()
            append blank
            tmp->uch := arr[i,23]
            tmp->tip := 3
          endif
          write_f39(arr[i])
          select TMP
          find ("4"+str(0,4)+str(0,3)+str(arr[i,22],3))  // МО+отделение
          if !found()
            append blank
            tmp->otd := arr[i,22]
            tmp->tip := 4
          endif
          write_f39(arr[i])
        next
      endif
      @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
      if jh > 0
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jh) color cColorStMsg
      endif
      select HUMAN
      skip
    enddo
  else
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humans","HUMAN")
    set relation to recno() into HUMAN_
    R_Use(dir_server+"schet_",,"SCHET_")
    R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
    set relation to recno() into SCHET_
    set filter to empty(schet_->IS_DOPLATA)
    dbseek(begin_date,.t.)
    do while schet->pdate <= end_date .and. !eof()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select HUMAN
      find (str(schet->kod,6))
      do while human->schet == schet->kod .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if human_->oplata < 9 .and. (arr := yes_f_39(-1)) != NIL
          ++jh
          for i := 1 to len(arr)
            select TMP
            find ("1"+str(arr[i,21],4))  // поиск по коду врача
            if !found()
              append blank
              tmp->p_kod := arr[i,21]
              tmp->tip := 1
            endif
            write_f39(arr[i])
            select TMP
            find ("2"+str(arr[i,21],4)+str(arr[i,23],3)) // врач+учреждение
            if !found()
              append blank
              tmp->p_kod := arr[i,21]
              tmp->uch := arr[i,23]
              tmp->tip := 2
            endif
            write_f39(arr[i])
            select TMP
            find ("3"+str(0,4)+str(arr[i,23],3))  // МО+учреждение
            if !found()
              append blank
              tmp->uch := arr[i,23]
              tmp->tip := 3
            endif
            write_f39(arr[i])
            select TMP
            find ("4"+str(0,4)+str(0,3)+str(arr[i,22],3))  // МО+отделение
            if !found()
              append blank
              tmp->otd := arr[i,22]
              tmp->tip := 4
            endif
            write_f39(arr[i])
          next
        endif
        @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
        if jh > 0
          @ row(),col() say "/" color "W/R"
          @ row(),col() say lstr(jh) color cColorStMsg
        endif
        select HUMAN
        skip
      enddo
      if fl_exit ; exit ; endif
      select SCHET
      skip
    enddo
  endif
endif
if ascan(arr_pl,F_YES_PL) > 0
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU_P")
  R_Use(dir_server+"hum_p",dir_server+"hum_pd","HUM_P")
  dbseek(dtos(arr_m[5]),.t.)
  do while hum_p->k_data <= arr_m[6] .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if (arr := yes_f_39_pl(-1)) != NIL
      ++jh
      for i := 1 to len(arr)
        select TMP
        find ("1"+str(arr[i,21],4))  // поиск по коду врача
        if !found()
          append blank
          tmp->p_kod := arr[i,21]
          tmp->tip := 1
        endif
        write_f39(arr[i])
        select TMP
        find ("2"+str(arr[i,21],4)+str(arr[i,23],3)) // врач+учреждение
        if !found()
          append blank
          tmp->p_kod := arr[i,21]
          tmp->uch := arr[i,23]
          tmp->tip := 2
        endif
        write_f39(arr[i])
        select TMP
        find ("3"+str(0,4)+str(arr[i,23],3))  // МО+учреждение
        if !found()
          append blank
          tmp->uch := arr[i,23]
          tmp->tip := 3
        endif
        write_f39(arr[i])
        select TMP
        find ("4"+str(0,4)+str(0,3)+str(arr[i,22],3))  // МО+отделение
        if !found()
          append blank
          tmp->otd := arr[i,22]
          tmp->tip := 4
        endif
        write_f39(arr[i])
      next
    endif
    @ maxrow(),1 say lstr(++kh) color cColorSt2Msg
    if jh > 0
      @ row(),col() say "/" color "BG/R"
      @ row(),col() say lstr(jh) color cColorStMsg
    endif
    select HUM_P
    skip
  enddo
endif
if (j := tmp->(lastrec())) > 0
  if select("UCH") == 0
    R_Use(dir_server+"mo_uch",,"UCH")
  endif
  if select("OTD") == 0
    R_Use(dir_server+"mo_otd",,"OTD")
  endif
  R_Use(dir_server+"mo_pers",,"P2")
  tmp->(dbeval({|| p2->(dbgoto(tmp->p_kod)), uch->(dbgoto(tmp->uch)), otd->(dbgoto(tmp->otd)), ;
                   tmp->tab_nom := p2->tab_nom, ;
                   tmp->name := iif(tmp->tip==4, otd->name, iif(tmp->tip==3, uch->name, fam_i_o(p2->fio))) } ))
endif
close databases
rest_box(buf)
if j == 0
  return func_error(4,"Нет информации!")
endif
if type("MenuTo_Minut") == "N"
  tm := MenuTo_Minut
else
  Private MenuTo_Minut
endif
mybell()
MenuTo_Minut := 0  // не выходить автоматически из MENU TO
keyboard ""
popup_prompt(T_ROW-6,T_COL-5,1, ;
  {"Список ~учреждений", ;
   "Список ~отделений", ;
   "Список ~персонала", ;
   "Персонал в у~чреждении"},, ;
  {"f_39org_1(3)", ;
   "f_39org_1(4)", ;
   "f_39org_1(1)", ;
   "f_39org_1(2)"})
MenuTo_Minut := tm
return NIL

*

***** 26.02.17
Function f_39org_1(par)
Static such := 1
Local buf, HH := 58, reg_print := 3, ;
      arr_title, name_file := "_form_39"+stxt, s, ls1, ;
      arr := {}, arr_uch := {}, r := T_ROW, r2, c := T_COL-5, i
if par == 2
  buf := savescreen(r,0,maxrow(),maxcol())
  use (cur_dir+"tmp") new
  index on upper(name) to (cur_dir+"tmp") for tip == 3
  dbeval({|| aadd(arr, tmp->uch), aadd(arr_uch,tmp->name) } )
  use
  i := ascan(arr, such)
  if (r2 := r+len(arr)+1) > maxrow()-2
    r2 := maxrow()-2
  endif
  status_key("^<Esc>^ - выход без выбора;  ^<Enter>^ - выбор учреждения")
  if (i := popup(r,c,r2,c+33,arr_uch,i,color0,.t.)) > 0
    glob_uch := {arr[i], alltrim(arr_uch[i])}
    such := arr[i]
  endif
  restscreen(r,0,maxrow(),maxcol(),buf)
  if i == 0 ; return NIL ; endif
endif
buf := save_maxrow()
mywait()
use (fr_data) new alias FRD
zap
use (fr_titl) new alias FRT
use (cur_dir+"tmp") new
do case
  case par == 1
    index on upper(name) to (cur_dir+"tmp") for tip == 1
  case par == 2
    index on upper(name) to (cur_dir+"tmp") for tip == 2 .and. uch == glob_uch[1]
  case par == 3
    index on upper(name) to (cur_dir+"tmp") for tip == 3
  case par == 4
    index on upper(name) to (cur_dir+"tmp") for tip == 4
endcase
Private regim := 2
arr_title := f39_title()
Private sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
f39_shapka()
_tit_ist_fin(sh)
s := ""
if par == 2
  s := alltrim(glob_uch[2])
endif
frt->name1 := s
add_string(center(s,sh))
s := "Отчетный период: "+speriod
frt->name2 := s
add_string(center(s,sh))
if pi1 == 1
  s := str_pi_schet()
else
  s := "[ по дате выписки счета ]"
endif
frt->name3 := s
add_string(center(s,sh))
add_string("")
//
Private sp[20]
afill(sp,0)
select TMP
go top
aeval(arr_title, {|x| add_string(x) } )
arr_title := f39_title2()
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  if eq_any(par,3,4)
    ls1 := tmp->name
  else
    ls1 := lstr(tmp->tab_nom,6)+"/"+tmp->name
  endif
  f_str_39(left(ls1,16),1,ls1)
  select TMP
  skip
enddo
add_string(replicate("-",sh))
f_str_39(padc("Всего:",16),2)
fclose(fp)
close databases
rest_box(buf)
name_fr := "mo_f39"+sfr3
if _upr_epson() .or. !file(dir_exe+name_fr)
  viewtext(name_file,,,,.t.,,,reg_print)
else
  call_fr(name_fr)
endif
return NIL

*

*****
Function forma_39_na(par)
Local nfile := dir_server+f39_nastr, name_sect := f39_sect+lstr(par)
Local arr, adbf, arr_usl, i
arr := {'"Посещений в п-ке по поводу заболеваний"', ;
        '"Профилактических приемов в п-ке"', ;
        '"Посещений на дому по поводу заболеваний"', ;
        '"Профилактических приемов на дому"'}
arr_usl := GetIniSect(nFile, name_sect)
adbf := {;
     {"U_KOD"  ,    "N",      4,      0}, ;  // код услуги
     {"U_SHIFR",    "C",     10,      0}, ;  // шифр услуги
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
ob2_v_usl(,2,"Настройка формы 39: колонка "+arr[par])
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

***** 18.03.13
Function forma_39_povod()
Static default_povod_nastr := {;
  {1,1}, ;
  {2,1}, ;
  {3,1}, ;
  {4,2}, ;
  {5,2}, ;
  {6,2}, ;
  {7,1}, ;
  {8,1}, ;
  {9,2}}
Static mm_z_p := {{"по поводу заболеваний  ",1}, ;
                  {"профилактические приемы",2}}
Static mm_p_u := {{"оказанных услуг ",0}, ;
                  {"повода обращения",1}}
Local nfile := dir_server+f39_nastr, ;
      name_sect := f39_sect+"6", ;
      r, ar, i, j, k, n := len(stm_povod), ;
      buf := savescreen()
ar := GetIniSect(nFile, name_sect)
Private mvar, m1var, mpovod, m1povod := int(val(a2default(ar,"povod","0")))
mpovod := inieditspr(A__MENUVERT, mm_p_u, m1povod)
//
r := 5
Private gl_area := {1,0,23,79,0}
setcolor(cDataCGet)
myclear(r)
@ r,0 to r,maxcol()
r += 2
@ r,2 say "Заполнение формы 39 (задача ОМС) на основании" ;
      get mpovod reader {|x|menu_reader(x,mm_p_u,A__MENUVERT,,,.f.)}
@ r+1,2 say "───────────────────────────────────┬────────────────────────────────────────"
@ r+2,2 say "  Повод обращения                  │ в какую колонку формы 39 попадает      "
@ r+3,2 say "───────────────────────────────────┴────────────────────────────────────────"
r += 3
for i := 1 to n
  k := 1
  if (j := ascan(default_povod_nastr, {|x| x[1] == stm_povod[i,2] })) > 0
    k := default_povod_nastr[j,2]
  endif
  j := int(val(a2default(ar,"povod_"+lstr(stm_povod[i,2]),"0")))
  if between(j,1,2)
    k := j
  endif
  //
  mvar  := "mda" +lstr(stm_povod[i,2])
  m1var := "m1da"+lstr(stm_povod[i,2])
  Private &m1var := k
  Private &mvar  := inieditspr(A__MENUVERT, mm_z_p, k)
  @ r+i,2 say stm_povod[i,1]
  @ row(),40 get &mvar reader {|x|menu_reader(x,mm_z_p,A__MENUVERT,,,.f.)}
next
status_key("^<Esc>^ - выход;  ^<PgDn>^ - подтверждение записи настроек")
myread()
if lastkey() != K_ESC .and. f_Esc_Enter("записи настроек")
  ar := {{"povod",m1povod}}
  for i := 1 to n
    mvar  := "mda" +lstr(stm_povod[i,2])
    m1var := "m1da"+lstr(stm_povod[i,2])
    aadd(ar,{"povod_"+lstr(stm_povod[i,2]),&m1var})
  next
  SetIniSect(nFile, name_sect, ar)
endif
restscreen(buf)
return NIL

*

*****
Function plan_39()
Local arr := {}, buf := savescreen(), ;
      arr_title := {{1,"  Отделение"}, ;
                    {2,"План;врач.;приемов"}, ;
                    {3,"План;профи-;лактик"}, ;
                    {4,"План;посещ.;на дому"}}, ;
      mpic := {,{6,0},{6,0}}, tmp_color := setcolor(), i
local blk := {|b,ar,nDim,nElem,nKey| f1plan_39(b, ar, nDim, nElem, nKey)}
if input_uch(T_ROW,T_COL-5,sys_date) == NIL
  return NIL
endif
R_Use(dir_server+"mo_otd",,"OTD")
dbeval({|| if(between_date(otd->DBEGIN,otd->DEND,sys_date) ;
         .or. between_date(otd->DBEGINP,otd->DENDP,sys_date), ;
   aadd(arr,{padr(otd->name,43), ;
             otd->plan_vp, ;
             otd->plan_pf, ;
             otd->plan_pd, ;
             otd->(recno())}), nil) }, ;
       {|| otd->kod_lpu == glob_uch[1] } )
close databases
asort(arr,,,{|x,y| x[1] < y[1] } )
Private updt_koef := .f.
keyboard chr(K_RIGHT)
Arrn_Browse(2,2,maxrow()-2,77,arr,arr_title,1,,color0, ;
            "Месячный план приемов в учреждении <"+alltrim(glob_uch[2])+">",'b/bg',,,mpic,blk,{.f.,.f.,.f.})
if updt_koef .and. f_Esc_Enter(1)
  G_Use(dir_server+"mo_otd",,"OTD")
  for i := 1 to len(arr)
    goto (arr[i,5])
    G_RLock(forever)
    otd->plan_vp := arr[i,2]
    otd->plan_pf := arr[i,3]
    otd->plan_pd := arr[i,4]
    UnLock
  next
  close databases
endif
restscreen(buf)
setcolor(tmp_color)
return NIL

*****
Function f1plan_39(b, ar, nDim, nElem, nKey)
LOCAL nRow := ROW(), nCol := COL(), flag := .f., ;
      buf := save_maxrow(), buf1, r1, mkod
if nKey == K_RIGHT
  b:right()
elseif nKey == K_LEFT .and. nDim > 2
  b:left()
elseif nKey == K_ENTER .or. between(nKey,46,57)
  @ nRow,nCol get parr[nElem,nDim] picture "999999"
  myread()
  b:refreshAll() ; flag := .t.
  updt_koef := .t.
else
  keyboard ""
endif
@ nRow, nCol SAY ""
return flag

*

***** 23.12.12
Function f_str_39(ls1,par,par2)
Local arr[20], i, pole
afill(arr,0)
if par == 1
  for i := 2 to 20
    pole := "tmp->p"+lstr(i)
    arr[i] := &pole
    sp[i] += &pole
  next
else
  for i := 2 to 20
    arr[i] := sp[i]
  next
endif
select FRD
append blank
frd->p1 := ltrim(iif(par2==NIL, ls1, par2))
for i := 2 to 20
  ls1 += put_val(arr[i],6)
  pole := "frd->p"+lstr(i)
  &pole := arr[i]
next
add_string(ls1)
return NIL

***** 18.03.13
Static Function get_nastr(yes_err)
Static spovod := "povod"
Local nf := dir_server+f39_nastr, fl, i, ar := {}, ret := .t.
DEFAULT yes_err TO .t.
au6 := {}
if (fl := file(nf))
  au1 := GetIniSect(nf,f39_sect+"1")
  au2 := GetIniSect(nf,f39_sect+"2")
  au3 := GetIniSect(nf,f39_sect+"3")
  au4 := GetIniSect(nf,f39_sect+"4")
  au5 := int(val(GetIniVar(nf,{{f39_sect+"5","ИСПРАВЛЕНИЕ","2"}})[1]))
  ar  := GetIniSect(nf,f39_sect+"6")
  fl := .f.
  for i := 1 to len(au1)
    fl := .t.
    au1[i,2] := int(val(au1[i,2]))
  next
  for i := 1 to len(au2)
    fl := .t.
    au2[i,2] := int(val(au2[i,2]))
  next
  for i := 1 to len(au3)
    fl := .t.
    au3[i,2] := int(val(au3[i,2]))
  next
  for i := 1 to len(au4)
    fl := .t.
    au4[i,2] := int(val(au4[i,2]))
  next
  for i := 1 to len(ar)
    if left(lower(ar[i,1]),6) == spovod+"_"
      aadd(au6, {int(val(substr(ar[i,1],7))),int(val(ar[i,2]))})
    endif
  next
endif
fl_povod := int(val(a2default(ar,spovod,"0")))
if !fl .and. au5 != 2 .and. yes_err
  ret := func_error(4,"Не произведена настройка формы 39")
endif
return ret

***** 23.12.12
Static Function cre_tmp(adbf)
aadd(adbf,{ "p1","C",50,0})
aadd(adbf,{ "p2","N",7,0})
aadd(adbf,{ "p3","N",7,0})
aadd(adbf,{ "p4","N",7,0})
aadd(adbf,{ "p5","N",7,0})
aadd(adbf,{ "p6","N",7,0})
aadd(adbf,{ "p7","N",7,0})
aadd(adbf,{ "p8","N",7,0})
aadd(adbf,{ "p9","N",7,0})
aadd(adbf,{"p10","N",7,0})
aadd(adbf,{"p11","N",7,0})
aadd(adbf,{"p12","N",7,0})
aadd(adbf,{"p13","N",7,0})
aadd(adbf,{"p14","N",7,0})
aadd(adbf,{"p15","N",7,0})
aadd(adbf,{"p16","N",7,0})
aadd(adbf,{"p17","N",7,0})
aadd(adbf,{"p18","N",7,0})
aadd(adbf,{"p19","N",7,0})
aadd(adbf,{"p20","N",7,0})
dbcreate(cur_dir+"tmp",adbf)
delFRfiles()
dbcreate(fr_titl,{{"name_org","C",130,0}, ;
                  {"name1","C",130,0}, ;
                  {"name2","C",130,0}, ;
                  {"name3","C",130,0}, ;
                  {"name4","C", 30,0}, ;
                  {"name5","C", 50,0}})
dbcreate(fr_data,adbf)
use (fr_data) new alias FRD
use (fr_titl) new alias FRT
append blank
return NIL

***** записать одну строку из массива в TMP-файл
Static Function write_f39(ar)
Local i, pole
for i := 2 to 20
  pole := "tmp->p"+lstr(i)
  &pole := &pole + ar[i]
next
return NIL

***** 22.12.16 проверить больного по БД human и вернуть результат в виде массива
Static Function yes_f_39(par1,par2)
Static arr_f := {"str_komp",,"komitet"}
Local i, j, k, s, mvozrast, is_selo, ret, arr := {}
if !(_f_ist_fin() .and. human_->usl_ok == 3)
  return ret
endif
if human_->NOVOR > 0
  mvozrast := count_years(human_->DATE_R2,human->n_data)
else
  mvozrast := count_years(human->date_r,human->n_data)
endif
if select("KART_") == 0
  R_Use(dir_server+"kartote_",,"KART_")
endif
kart_->(dbGoto(human->kod_k))
is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog)  // признак села
i := human->komu ; j := 0
if i == 0
  j := 17   // ОМС
elseif eq_any(i,1,3)  // прочие компании или комитеты (МО)
  if hb_fileExists(dir_server+arr_f[i]+sdbf)
    R_Use(dir_server+arr_f[i],,"_B")
    goto (human->str_crb)
    if eq_any(_b->ist_fin,I_FIN_PLAT,I_FIN_LPU) // платные, взаиморасчёты с ЛПУ
      j := 19   // платные
    elseif _b->ist_fin == I_FIN_DMS // ДМС
      j := 20   // ДМС
    else // все остальные (бюджет, за свой счёт, не оплачивается)
      j := 18   // бюджет
    endif
    Use
  endif
elseif i == 5  // личный счет
  j := 19   // платные
endif
if between(j,17,20)
  if select("USL") == 0
    R_Use(dir_server+"uslugi",,"USL")
  endif
  if year(human->k_data) < 2016
    select HU
    find (str(human->kod,7))
    do while hu->kod == human->kod .and. !eof()
      otd->(dbGoto(hu->otd))
      if iif(par1 == -1, .t., f_is_uch(st_a_uch,otd->kod_lpu)) .and. hu->kod_vr > 0  // если проставлен код врача
        k := hu->kol
        afill(lp,0)
        lp[1]  := hu->date_u
        lp[21] := hu->kod_vr
        lp[22] := hu->otd
        lp[23] := otd->kod_lpu
        ___f_39(1,k,mvozrast,is_selo)
        if !emptyall(lp[2],lp[10])
          lp[j] := k
          aadd(arr,aclone(lp))
        endif
      endif
      select HU
      skip
    enddo
  else // начиная с 2016 года
    if select("MOHU") == 0
      R_Use(dir_server+"mo_su",,"MOSU")
      R_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
      set relation to u_kod into MOSU
    endif
    arr := ___f_39_2016(par1,j,mvozrast,is_selo)
  endif
  if len(arr) > 0
    do case
      case par1 == -1  // по организации
        ret := arr
      case par1 == 0  // по учреждению
        ret := arr
      case par1 == 1  // по врачу
        if ascan(arr,{|x| x[21] == par2}) > 0
          ret := {}
          for i := 1 to len(arr)
            if arr[i,21] == par2
              aadd(ret,arr[i])
            endif
          next
        endif
      case par1 == 2 // по отделению
        if ascan(arr,{|x| x[22] == par2}) > 0
          ret := {}
          for i := 1 to len(arr)
            if arr[i,22] == par2
              aadd(ret,arr[i])
            endif
          next
        endif
    endcase
  endif
endif
return ret

***** 19.02.13 проверить больного по БД hum_p и вернуть результат в виде массива
Static Function yes_f_39_pl(par1,par2)
Local i, j, k, s, mvozrast, arr, is_selo, ret
kart->(dbgoto(hum_p->kod_k))
mvozrast := count_years(kart->date_r, hum_p->n_data)
if select("KART_") == 0
  R_Use(dir_server+"kartote_",,"KART_")
endif
select KART_
goto (kart->(recno()))
is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog)  // признак села
arr := {}
select HU_P
find (str(hum_p->(recno()),7))
do while hu_p->kod == hum_p->(recno()) .and. !eof()
  otd->(dbGoto(hu_p->otd))
  if iif(par1 == -1, .t., f_is_uch(st_a_uch,otd->kod_lpu)) .and. hu_p->kod_vr > 0  // если проставлен код врача
    k := hu_p->kol
    afill(lp,0)
    lp[1]  := hu_p->date_u
    lp[21] := hu_p->kod_vr
    lp[22] := hu_p->otd
    lp[23] := otd->kod_lpu
    ___f_39(2,k,mvozrast,is_selo)
    if !emptyall(lp[2],lp[10])
      if hum_p->TIP_USL == 1  // ДМС
        lp[20] := k
      else
        lp[19] := k   // платные
      endif
      aadd(arr,aclone(lp))
    endif
  endif
  select HU_P
  skip
enddo
if len(arr) > 0
  do case
    case par1 == -1  // по организации
      ret := arr
    case par1 == 0  // по учреждению
      ret := arr
    case par1 == 1  // по врачу
      if ascan(arr,{|x| x[21] == par2}) > 0
        ret := {}
        for i := 1 to len(arr)
          if arr[i,21] == par2
            aadd(ret,arr[i])
          endif
        next
      endif
    case par1 == 2 // по отделению
      if ascan(arr,{|x| x[22] == par2}) > 0
        ret := {}
        for i := 1 to len(arr)
          if arr[i,22] == par2
            aadd(ret,arr[i])
          endif
        next
      endif
  endcase
endif
return ret

***** 03.04.14 до 2016 года
Function ___f_39(par,k,mvozrast,is_selo)
Local _1, _2, _3, _4, lshifr, lshifr1 := "", ldiag, ta, i, j, is_dom := .f., d2_year := year(sys_date)
if select("USL") == 0
  R_Use(dir_server+"uslugi",,"USL")
endif
_1 := _2 := _3 := _4 := .f.
if par == 1
  d2_year := year(human->k_data)
  ldiag := human->kod_diag
  usl->(dbGoto(hu->u_kod))
  if !(_1 := (ascan(au1,{|x| x[2] == hu->u_kod}) > 0))  // врачебных приемов
    if !(_2 := (ascan(au2,{|x| x[2] == hu->u_kod}) > 0))  // Профилактических приемов
      if !(_3 := (ascan(au3,{|x| x[2] == hu->u_kod}) > 0))  // Посещений на дому
        _4 := (ascan(au4,{|x| x[2] == hu->u_kod}) > 0)  // Профилактических приемов на дому
      endif
    endif
  endif
  lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
  lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
  if d2_year > 2012 .and. hu->kol_rcp < 0 .and. DomUslugaTFOMS(lshifr)
    _3 := is_dom := .t. ; _4 := .f.
    if _2
      _4 := .t. ; _3 := .f.
    endif
    _1 := _2 := .f.
  endif
else
  ldiag := hum_p->kod_diag
  usl->(dbGoto(hu_p->u_kod))
  if !(_1 := (ascan(au1,{|x| x[2] == hu_p->u_kod}) > 0))  // врачебных приемов
    if !(_2 := (ascan(au2,{|x| x[2] == hu_p->u_kod}) > 0))  // Профилактических приемов
      if !(_3 := (ascan(au3,{|x| x[2] == hu_p->u_kod}) > 0))  // Посещений на дому
        _4 := (ascan(au4,{|x| x[2] == hu_p->u_kod}) > 0)  // Профилактических приемов на дому
      endif
    endif
  endif
  lshifr := usl->shifr
endif
if au5 == 2 .or. (par == 1 .and. fl_povod == 1) // исправлять
  if priem_na_domu(lshifr) // на дому - по старому
    is_dom := .t.
    if !(_3 .or. _4)
      _1 := _2 := _4 := .f.
      _3 := .t.
    endif
  elseif priem_profilak(lshifr) // профилактический приём
    if !(_2 .or. _4)
      _1 := _3 := _4 := .f.
      _2 := .t.
    endif
    if is_dom
      _1 := _2 := _3 := .f.
      _4 := .t.
    endif
  elseif is_dom // на дому - по новому
    if !(_3 .or. _4)
      _1 := _2 := _4 := .f.
      _3 := .t.
    endif
  endif
  if !(_1 .or. _2 .or. _3 .or. _4) .and. par == 1
    ta := f14tf_nastr(lshifr,,d2_year)
    for j := 1 to len(ta)
      if eq_any(ta[j,1],1,6) .and. ta[j,2] >= 0
        if is_dom
          _3 := .t.  // посещений на дому
        else
          _1 := .t.  // врачебный приём
        endif
        exit
      endif
    next
  endif
  if (_1 .or. _2 .or. _3 .or. _4) .and. left(ldiag,1) == "Z" // всегда профилактический приём
    if _3 .or. _4
      _1 := _2 := _3 := .f.
      _4 := .t.
    else
      _1 := _3 := _4 := .f.
      _2 := .t.
    endif
  endif
endif
// если работаем по поводу обращения
if (_1 .or. _2 .or. _3 .or. _4) .and. par == 1 .and. fl_povod == 1
  if (i := ascan(au6, {|x| x[1] == human_->POVOD })) > 0
    j := au6[i,2]
  else
    j := 1 // по поводу заболеваний
  endif
  _1 := _2 := _3 := _4 := .f.
  if j == 1
    if is_dom
      _3 := .t.  // посещений на дому
    else
      _1 := .t.  // врачебный приём
    endif
  else
    if is_dom
      _4 := .t.  // профилактический прием на дому
    else
      _2 := .t.  // профилактический приём
    endif
  endif
endif
if _1 .or. _2
  lp[2] := k
  if is_selo
    lp[3] := k
  endif
  if mvozrast < 18
    lp[4] := k
  elseif mvozrast >= 60
    lp[5] := k
  endif
endif
if _1
  lp[6] := k
  if mvozrast < 18
    lp[7] := k
  elseif mvozrast >= 60
    lp[8] := k
  endif
endif
if _2
  lp[9] := k
endif
if _3 .or. _4
  lp[10] := k
endif
if _3
  lp[11] := k
  if mvozrast < 18
    lp[12] := k
    if mvozrast < 1
      lp[13] := k
    endif
  elseif mvozrast >= 60
    lp[14] := k
  endif
endif
if _4
  if mvozrast < 18
    lp[15] := k
    if mvozrast < 1
      lp[16] := k
    endif
  endif
endif
return NIL

***** 19.08.19 начиная с 2016 года
Function ___f_39_2016(par1,jcol,mvozrast,is_selo)
Local _1, _2, _3, _4, lshifr, lshifr1 := "", ldiag, ta, i, j, is_dom := .f., arr := {}, ;
      is_zabol, fl_stom_new := .f., au_lu := {}, au_flu := {}, vid_vp := 0, ; // по умолчанию профилактика
      d2_year := year(human->k_data)
select HU
find (str(human->kod,7))
do while hu->kod == human->kod .and. !eof()
  usl->(dbGoto(hu->u_kod))
  lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
  if f_paraklinika(usl->shifr,lshifr1,human->k_data)
    lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
    if is_2_stomat(lshifr,,.t.) > 0 // для случаев с 1 августа 2016 года
      fl_stom_new := .t.
      aadd(au_lu,{lshifr, ;              // 1
                  c4tod(hu->date_u), ;   // 2
                  0, ;         // 3
                  0, ;           // 4
                  alltrim(usl->shifr), ; // 5
                  hu->kol_1, ;           // 6
                  c4tod(hu->date_u), ;   // 7
                  "", ;       // 8
                  hu->(recno()), ;       // 9 - номер записи
                  0})                   // 10 - для возврата
    endif
    if eq_any(left(lshifr,5),"2.80.","2.82.")
      vid_vp := 1 // в неотложной форме или Посещение в приёмном покое
      exit
    elseif eq_any(left(lshifr,5),"2.78.","2.89.")
      vid_vp := 2 // по поводу заболевания
      exit
    elseif left(lshifr,5) == "2.88."
      if is_usluga_disp_nabl(lshifr)
        vid_vp := 0 // считаем профилактикой
      else
        vid_vp := 2 // разовое по поводу заболевания
      endif
      exit
    endif
  endif
  select HU
  skip
enddo
is_zabol := (vid_vp > 0)
if fl_stom_new
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    aadd(au_flu,{mosu->shifr1, ;         // 1
                 c4tod(mohu->date_u), ;  // 2
                 mohu->profil, ;         // 3
                 mohu->PRVS, ;           // 4
                 mosu->shifr, ;          // 5
                 mohu->kol_1, ;          // 6
                 c4tod(mohu->date_u2), ; // 7
                 mohu->kod_diag, ;       // 8
                 mohu->(recno()), ;      // 9 - номер записи
                 0})                    // 10 - для возврата
    select MOHU
    skip
  enddo
  f_vid_p_stom(au_lu,{},,,human->k_data,,,,au_flu)
  for j := 1 to len(au_flu)
    if au_flu[j,10] == 1 // является врачебным приёмом
      mohu->(dbGoto(au_flu[j,9]))
      otd->(dbGoto(mohu->otd))
      if iif(par1 == -1, .t., f_is_uch(st_a_uch,otd->kod_lpu)) .and. mohu->kod_vr > 0  // если проставлен код врача
        is_dom := .f. // на дому
        k := au_flu[j,6] // кол-во услуг
        afill(lp,0)
        lp[1]  := mohu->date_u
        lp[21] := mohu->kod_vr
        lp[22] := mohu->otd
        lp[23] := otd->kod_lpu
        _1 := _2 := _3 := _4 := .f.
        // 1 врачебный приём
        // 2 профилактический приём
        if is_zabol
          _1 := .t.
        else
          _2 := .t.
        endif
        lp[2] := k
        if is_selo
          lp[3] := k
        endif
        if mvozrast < 18
          lp[4] := k
        elseif mvozrast >= 60
          lp[5] := k
        endif
        if _1
          lp[6] := k
          if mvozrast < 18
            lp[7] := k
          elseif mvozrast >= 60
            lp[8] := k
          endif
        endif
        if _2
          lp[9] := k
        endif
        lp[jcol] := k
        aadd(arr,aclone(lp))
      endif
    endif
  next
else
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    usl->(dbGoto(hu->u_kod))
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    if f_paraklinika(usl->shifr,lshifr1,human->k_data)
      lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
      if !eq_any(left(lshifr,5),"2.90.","2.91.")
        ta := f14tf_nastr(@lshifr,,d2_year)
        lshifr := alltrim(lshifr)
        for j := 1 to len(ta)
          if eq_any(ta[j,1],1,6).and. ta[j,2] == 0
            k := hu->kol_1
            otd->(dbGoto(hu->otd))
            if iif(par1 == -1, .t., f_is_uch(st_a_uch,otd->kod_lpu)) .and. hu->kod_vr > 0  // если проставлен код врача
              is_dom := (hu->kol_rcp < 0 .and. DomUslugaTFOMS(lshifr)) // на дому - по новому
              _1 := _2 := _3 := _4 := .f.
              afill(lp,0)
              lp[1]  := hu->date_u
              lp[21] := hu->kod_vr
              lp[22] := hu->otd
              lp[23] := otd->kod_lpu
              // 1 врачебный приём
              // 2 профилактический приём
              // 3 посещений на дому
              // 4 профилактический прием на дому
              if is_zabol
                if is_dom
                  _3 := .t.  // посещений на дому
                else
                  _1 := .t.  // врачебный приём
                endif
              else
                if is_dom
                  _4 := .t.  // профилактический прием на дому
                else
                 _2 := .t.  // профилактический приём
                endif
              endif
              if _1 .or. _2
                lp[2] := k
                if is_selo
                  lp[3] := k
                endif
                if mvozrast < 18
                  lp[4] := k
                elseif mvozrast >= 60
                  lp[5] := k
                endif
              endif
              if _1
                lp[6] := k
                if mvozrast < 18
                  lp[7] := k
                elseif mvozrast >= 60
                  lp[8] := k
                endif
              endif
              if _2
                lp[9] := k
              endif
              if _3 .or. _4
                lp[10] := k
              endif
              if _3
                lp[11] := k
                if mvozrast < 18
                  lp[12] := k
                  if mvozrast < 1
                    lp[13] := k
                  endif
                elseif mvozrast >= 60
                  lp[14] := k
                endif
              endif
              if _4
                if mvozrast < 18
                  lp[15] := k
                  if mvozrast < 1
                    lp[16] := k
                  endif
                endif
              endif
              lp[jcol] := k
              aadd(arr,aclone(lp))
            endif
          endif
        next j
      endif
    endif
    select HU
    skip
  enddo
endif
return arr

*****
Function ret_oms_pl(r,c)
Static sast := {.t.,.t.}, ;
       sarr := {{'по задаче ОМС'             ,F_YES_OMS}, ;
                {'по задаче "Платные услуги"',F_YES_PL }}
Local ret := {1}, i, j, a
if is_task(X_PLATN) // для платных услуг
  ret := NIL
  if (a := bit_popup(T_ROW,T_COL-5,sarr,sast)) != NIL
    ret := {} ; afill(sast,.f.)
    for i := 1 to len(a)
      aadd(ret,a[i,2])
      if (j := ascan(sarr,{|x| x[2]==a[i,2] })) > 0
        sast[j] := .t.
      endif
    next
  endif
endif
return ret

*

*****
Function forma_57(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j, uch_otd
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Распечатка ~формы 57", ;
                "Форма 57 + ~диагнозы", ;
                "Форма 57 + ~больные"}
    mas_msg := {"Распечатка формы № 57", ;
                "Распечатка аналога формы № 57 с уточнением диагнозов", ;
                "Распечатка аналога формы № 57 с уточнением диагнозов и со списком больных"}
    mas_fun := {"forma_57(11)", ;
                "forma_57(12)", ;
                "forma_57(13)"}
    if ret_is_talon() .and. pi1 == 1 // по дате окончания лечения
      aadd(mas_pmt,"~Редактирование стат.талона")
      aadd(mas_msg,"Редактирование стат.талона")
      aadd(mas_fun,"forma_57(14)")
    endif
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    forma_57_(1)
  case k == 12
    forma_57_(2)
  case k == 13
    forma_57_(3)
  case k == 14
    edit_bolnich(2)
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

*

***** 05.01.17
Function forma_57_(is_diag)
Static sy := 1
Local begin_date, end_date, pole, file_form, yes_god
Local i, j, k, buf := save_maxrow(), adbf, lfp, t_arr1[20], t_arr2[20], ;
      fl_exit := .f., jh := 0, jt := 0, mshifr, mvozrast, d1, d2, ;
      arr_stroke := {{},{},{}}, fl, s, arr, bbuf, blk_usl, ab := {}
file_form := dir_exe+"_mo_form"+sdbf
if !hb_FileExists(file_form)
  return func_error(4,"Не обнаружен файл настройки статистических форм "+upper(file_form))
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
yes_god := (arr_m[2]==1 .and. arr_m[3]==12)
if (st_a_uchast := ret_uchast(T_ROW,T_COL-5)) == NIL
  return NIL
endif
Private diag1 := {{},{},{}}, fl_plus := !empty(yes_d_plus), len_diag[3]
begin_date := arr_m[5]
end_date := arr_m[6]
adbf := {{"stroke","C",2,0}, ;
         {"table","N",4,0}, ;
         {"voz","N",1,0}, ;  // 1 - 3
         {"v04","N",7,0}, ;  // V01-Y98
         {"v05","N",7,0}, ;  // V01-V99
         {"v06","N",7,0}, ;  // дорожно-транспортные
         {"v07","N",7,0}, ;  // W00-X59
         {"v08","N",7,0}, ;  // W65-W74
         {"v09","N",7,0}, ;  // X00-X09
         {"v10","N",7,0}, ;  // X40-X49
         {"v11","N",7,0}, ;  // X42
         {"v12","N",7,0}, ;  // X45
         {"v13","N",7,0}, ;  // X60-X84
         {"v14","N",7,0}, ;  // X62
         {"v15","N",7,0}, ;  // X65
         {"v16","N",7,0}, ;  // X85-Y09
         {"v17","N",7,0}, ;  // Y10-Y34
         {"v18","N",7,0}, ;  // Y35-Y38
         {"v19","N",7,0}, ;  // Y40-Y84
         {"v20","N",7,0}}   // Y85-Y89
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
s := "V01-V04,V06.1,V09.2-V09.3,V10.4-V10.9,V11.4-V11.9,V12.4-V12.9,V13.4-V13.9,"+;
     "V14.4-V14.9,V15.4-V15.9,V16.4-V16.9,V17.4-V17.9,V18.4-V18.9,V19.4-V19.9,"+;
     "V20.4-V20.9,V21.4-V21.9,V22.4-V22.9,V23.4-V23.9,V24.4-V24.9,V25.4-V25.9,"+;
     "V26.4-V26.9,V27.4-V27.9,V28.4-V28.9,V29.4-V29.9,"+;
     "V30.5-V30.9,V31.5-V31.9,V32.5-V32.9,V33.5-V33.9,V34.5-V34.9,V35.5-V35.9,"+;
     "V36.5-V36.9,V37.5-V37.9,V38.5-V38.9,V39.4-V39.9,"+;
     "V40.5-V40.9,V41.5-V41.9,V42.5-V42.9,V43.5-V43.9,V44.5-V44.9,V45.5-V45.9,"+;
     "V46.5-V46.9,V47.5-V47.9,V48.5-V48.9,V49.4-V49.9,"+;
     "V50.5-V50.9,V51.5-V51.9,V52.5-V52.9,V53.5-V53.9,V54.5-V54.9,V55.5-V55.9,"+;
     "V56.5-V56.9,V57.5-V57.9,V58.5-V58.9,V59.4-V59.9,"+;
     "V60.5-V60.9,V61.5-V61.9,V62.5-V62.9,V63.5-V63.9,V64.5-V64.9,V65.5-V65.9,"+;
     "V66.5-V66.9,V67.5-V67.9,V68.5-V68.9,V69.4-V69.9,"+;
     "V70.5-V70.9,V71.5-V71.9,V72.5-V72.9,V73.5-V73.9,V74.5-V74.9,V75.5-V75.9,"+;
     "V76.5-V76.9,V77.5-V77.9,V78.5-V78.9,V79.4-V79.9,V82.1,V82.9"
arr   := {"","","", ;  // 1 - 3
          "V01-Y98", ;
          "V01-V99", ;
          s, ;         // дорожно-транспортные
          "W00-X59", ;
          "W65-W74", ;
          "X00-X09", ;
          "X40-X49", ;
          "X42", ;
          "X45", ;
          "X60-X84", ;
          "X62", ;
          "X65", ;
          "X85-Y09", ;
          "Y10-Y34", ;
          "Y35-Y38", ;
          "Y40-Y84", ;
          "Y85-Y89"}
Private yes_rule := read_rule(D_RULE_N_F57), arr_57_wide := {}
for j := 1 to len(arr)
  diapazon := {} ; s2 := arr[j]
  for i := 1 to numtoken(s2,",")
    s3 := token(s2,",",i)
    if "-" $ s3
      d1 := token(s3,"-",1)
      d2 := token(s3,"-",2)
    else
      d1 := d2 := s3
    endif
    aadd(diapazon, {diag_to_num(d1,1),diag_to_num(d2,2)} )
  next
  aadd(arr_57_wide, diapazon)
next
//
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new alias TMP
index on str(voz,1)+stroke to (cur_dir+"tmp")
use (file_form) new alias FRM
set filter to forma == 57
go top
do while !eof()
  UpdateStatus()
  if frm->table == 1000
    x := 1
  elseif frm->table == 2000
    x := 2
  elseif frm->table == 3000
    x := 3
  endif
  s1 := alltrim(frm->stroke)     // номер строки
  if iif(is_diag > 1, s1 == "1", .t.)
    s2 := alltrim(frm->diagnoz)  // диагнозы
    k := iif("-" $ s2, "", space(2))
    s4 := k+iif(frm->bold==1,"<b>","")+alltrim(frm->name)+iif(frm->bold==1,"</b>","")     // наименование
    diapazon := {}
    for i := 1 to numtoken(s2,",")
      s3 := token(s2,",",i)
      if "-" $ s3
        d1 := token(s3,"-",1)
        d2 := token(s3,"-",2)
      else
        d1 := d2 := s3
      endif
      aadd(diapazon, {diag_to_num(d1,1),diag_to_num(d2,2)} )
    next
    aadd(arr_stroke[x],s1)
    select TMP
    append blank
    tmp->stroke := s1
    tmp->voz    := x
    tmp->table  := frm->table
    s2 := iif(frm->bold==1,"<b>","")+s2+iif(frm->bold==1,"</b>","")     // диагноз
    aadd(diag1[x], {s1,1,diapazon,frm->table,s2,s4})
  endif
  select FRM
  skip
enddo
frm->(dbCloseArea())
for i := 1 to 3
  len_diag[i] := len(diag1[i])
next
//
if is_diag > 1
  aadd(adbf,{"diagnoz","C",5,0})
  dbcreate(cur_dir+"tmp_dia",adbf)
  use (cur_dir+"tmp_dia") new alias TMP_D
  index on str(voz,1)+diagnoz to (cur_dir+"tmp_dia")
endif
if is_diag == 3
  aadd(adbf,{"kod_human","N",7,0})
  dbcreate(cur_dir+"tmp_hum",adbf)
  use (cur_dir+"tmp_hum") new alias TMP_H
  index on str(voz,1)+diagnoz+str(kod_human,7) to (cur_dir+"tmp_hum")
endif
//
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
if yes_rule  // "исправляем" в соответствии с правилами статистики
  bbuf := save_maxrow()
  mywait("Ждите. Создаётся условный индексный файл...")
  if pi1 == 1 // по дате окончания лечения
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    set relation to recno() into HUMAN_, to recno() into HUMAN_2
    dbseek(dtos(arr_m[5]),.t.)
    index on str(kod_k,7)+dtos(k_data) to (cur_dir+"tmp_h") ;
          while k_data <= arr_m[6] ;
          for kod > 0 .and. human_->usl_ok == 3 .and. human_->oplata < 9 ;
                      .and. human_->NOVOR == 0 .and. func_pi_schet()
  else
    R_Use(dir_server+"schet",,"SCHET")
    R_Use(dir_server+"human",,"HUMAN")
    set relation to schet into SCHET, to recno() into HUMAN_, to recno() into HUMAN_2
    index on str(kod_k,7)+dtos(k_data) to (cur_dir+"tmp_h") ;
          for kod > 0 .and. human_->usl_ok == 3 .and. human_->oplata < 9 ;
                      .and. human_->NOVOR == 0 .and. between(schet->pdate,arr_m[7],arr_m[8]) ;
          progress
  endif
  rest_box(bbuf)
  hGauge := GaugeNew(,,,"Попытка исправления в соответствии с правилами",.t.)
  GaugeDisplay( hGauge )
  blk_usl := {|| f_is_uch(st_a_uch,human->lpu) .and. f_is_uchast(st_a_uchast,kart->uchast) }
  select KART
  go top
  do while !eof()
    UpdateStatus()
    GaugeUpdate( hGauge, recno()/lastrec() )
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if f1_prover_rule(blk_usl,ab,57)
      @ maxrow(),1 say lstr(++jh) color cColorSt2Msg
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jt) color cColorStMsg
      verify12rule(ab,kart->pol,yes_god)
      jt += f2_f57(is_diag)
    endif
    select KART
    skip
  enddo
  CloseGauge(hGauge)
else  // не "исправляем" в соответствии с правилами статистики
  if pi1 == 1 // по дате окончания лечения
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    set relation to kod_k into KART, to recno() into HUMAN_, to recno() into HUMAN_2
    dbseek(dtos(begin_date),.t.)
    do while human->k_data <= end_date .and. !eof()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      UpdateStatus()
      @ maxrow(),1 say lstr(++jh) color cColorSt2Msg
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jt) color cColorStMsg
      if human_->usl_ok == 3 .and. human_->oplata < 9 .and. func_pi_schet() .and. ;
         f_is_uch(st_a_uch,human->lpu) .and. f_is_uchast(st_a_uchast,kart->uchast)
        date_24(human->k_data)
        jt += f1_f57(is_diag)
      endif
      select HUMAN
      skip
    enddo
  else
    R_Use(dir_server+"human",dir_server+"humans","HUMAN")
    set relation to kod_k into KART, to recno() into HUMAN_, to recno() into HUMAN_2
    R_Use(dir_server+"schet_",,"SCHET_")
    R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
    set relation to recno() into SCHET_
    set filter to empty(schet_->IS_DOPLATA)
    dbseek(arr_m[7],.t.)
    do while schet->pdate <= arr_m[8] .and. !eof()
      date_24(c4tod(schet->pdate))
      select HUMAN
      find (str(schet->kod,6))
      do while human->schet == schet->kod
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        UpdateStatus()
        @ maxrow(),1 say lstr(++jh) color cColorSt2Msg
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jt) color cColorStMsg
        if human_->usl_ok == 3 .and. human_->oplata < 9 .and. f_is_uch(st_a_uch,human->lpu) ;
                               .and. f_is_uchast(st_a_uchast,kart->uchast)
          jt += f1_f57(is_diag)
        endif
        select HUMAN
        skip
      enddo
      select SCHET
      skip
    enddo
  endif
endif
close databases
if fl_exit
  rest_box(buf)
  return NIL
endif
//
mywait()
delFRfiles()
adbf := {{"name","C",255,0}, ;
         {"adres","C",255,0}, ;
         {"name1","C",255,0}, ;
         {"period","C",100,0}}
dbcreate(fr_titl, adbf)
use (fr_titl) new alias FRT
append blank
//
R_Use(dir_server+"organiz",,"ORG")
frt->name := alltrim(org->name)
frt->adres := alltrim(org->adres)
frt->period := arr_m[4]
if pi1 == 1
  frt->name1 := str_pi_schet()
else
  frt->name1 := "[ по дате выписки счета ]"
endif
if is_diag > 1
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB10")
  use (cur_dir+"tmp_dia") index (cur_dir+"tmp_dia") new alias TMP_D
endif
if is_diag == 3
  R_Use(dir_server+"schet",,"SCHET")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_
  use (cur_dir+"tmp_hum") new alias TMP_H
  set relation to kod_human into HUMAN
  index on str(voz,1)+diagnoz+upper(human->fio)+dtos(human->k_data) to (cur_dir+"tmp_hum")
endif
adbf := {;
  {"name","C",250,0}, ;
  {"diagnoz","C",40,0}, ;
  {"stroke","C",10,0};
 }
for i := 4 to 20
  aadd(adbf, {"kol"+lstr(i),"N",8,0})
next
for i := 0 to 2
  name_f := fr_data+iif(i > 0, lstr(i), "")
  al := "FRD"+iif(i > 0, lstr(i), "")
  dbcreate(cur_dir+name_f,adbf)
  E_Use(cur_dir+name_f,,al)
next
use (cur_dir+"tmp") index (cur_dir+"tmp") new
for x := 1 to 3 // diag1[x] => {s1,1,diapazon,tmp->table,s2,s4}
  al := "FRD"+iif(x > 1, lstr(x-1), "")
  //diag1[x] => {s1,p_tip,diapazon,tmp->table,s2,s4}
  for ix := 1 to len(diag1[x])
    s1 := padr(diag1[x,ix,1],2) ; s1_ := diag1[x,ix,1]
    if iif(is_diag > 1, s1_ == "1", .t.)
      s2 := diag1[x,ix,5] // строка диагнозов
      s3 := diag1[x,ix,6] // наименование
      select TMP
      find (str(x,1)+s1)
      dbSelectArea(al)
      append blank
      &al.->name := s3
      &al.->stroke := s1
      &al.->diagnoz := s2
      for i := 4 to 20
        pole1 := "tmp->v"+strzero(i,2)
        pole2 := al+"->kol"+lstr(i)
        &pole2 := &pole1
      next
      if is_diag > 1
        select TMP_D
        find (str(x,1))
        do while tmp_d->voz == x .and. !eof()
          lshifr := tmp_d->diagnoz
          select MKB10
          find (lshifr)
          s := alltrim(mkb10->name)+" "
          skip
          do while left(mkb10->shifr,5) == lshifr .and. mkb10->ks > 0 .and. !eof()
            s += alltrim(mkb10->name)+" "
            skip
          enddo
          dbSelectArea(al)
          append blank
          if is_diag == 3
            &al.->name := "<b>"+s+"</b>"
            &al.->diagnoz := "<b>"+lshifr+"</b>"
          else
            &al.->name := s
            &al.->diagnoz := lshifr
          endif
          &al.->stroke := ""
          for i := 4 to 20
            pole1 := "tmp_d->v"+strzero(i,2)
            pole2 := al+"->kol"+lstr(i)
            &pole2 := &pole1
          next
          if is_diag == 3
            select TMP_H
            find (str(x,1)+lshifr)
            do while tmp_h->voz == x .and. tmp_h->diagnoz == lshifr .and. !eof()
              s := ""
              if mem_kodkrt == 2 .and. is_uchastok == 2 .and. human->kod_k > 0
                s := "["+lstr(human->kod_k)+"] "
              endif
              s += alltrim(human->fio)+" "+left(dtoc(human->n_data),5)+"-"+left(dtoc(human->k_data),5)
              if human->schet > 0
                schet->(dbGoto(human->schet))
                s += " сч.№"+alltrim(schet->nomer_s)+" от "+date_8(c4tod(schet->pdate))
              endif
              dbSelectArea(al)
              append blank
              &al.->name := s
              &al.->stroke := ""
              &al.->diagnoz := ""
              for i := 4 to 20
                pole1 := "tmp_h->v"+strzero(i,2)
                pole2 := al+"->kol"+lstr(i)
                &pole2 := &pole1
              next
              select TMP_H
              skip
            enddo
          endif
          select TMP_D
          skip
        enddo
      endif
    endif
  next
next
close databases
rest_box(buf)
call_fr("mo_forma57")
return NIL

***** 05.01.17
Function f1_f57(is_diag)
Local i, j, k, mshifr, mvozrast, d1, d2, fl, arr_d := {}, arr, tip_travma, ;
      mpol, k1, v3 := 0, s, is_talon := .t., adiag_talon[16]
Private arr_v := {{0,17},{18,999}}, arr_all := {}
afill(adiag_talon,0)
for i := 1 to 16
  adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
next
arr := {human_2->OSL1,human_2->OSL2,human_2->OSL3}
for i := 1 to len(arr)
  if !empty(lshifr := alltrim(arr[i]))
    if eq_any(left(lshifr,1),"V","W","X","Y")
      aadd(arr_all,padr(lshifr,5))
    endif
  endif
next
arr := {human->KOD_DIAG , ;
        human->KOD_DIAG2, ;
        human->KOD_DIAG3, ;
        human->KOD_DIAG4, ;
        human->SOPUT_B1 , ;
        human->SOPUT_B2 , ;
        human->SOPUT_B3 , ;
        human->SOPUT_B4}
for i := 1 to len(arr)
  if !empty(lshifr := alltrim(arr[i]))
    if eq_any(left(lshifr,1),"V","W","X","Y")
      aadd(arr_all,padr(lshifr,5))
    endif
  endif
next
if human_->NOVOR > 0
  mpol := human_->POL2
  mvozrast := count_years(human_->DATE_R2,human->n_data)
else
  mpol := human->pol
  mvozrast := count_years(human->date_r,human->n_data)
endif
v := ret_v_f57(mpol,mvozrast,@v3)
if empty(tip_travma := ret_f_57_wide()) //  если NIL, то по-старому из меню типа травмы
  tip_travma := {4}
  do case
    case human_->TRAVMA == 4 // {"Дорожно-транспортная пр-венная",4}, ;
      aadd(tip_travma,5)
    case human_->TRAVMA == 8 // {"Дор.трансп., не связанная с пр-вом",8}, ;
      aadd(tip_travma,5)
      aadd(tip_travma,6)
    otherwise
      aadd(tip_travma,7)
  endcase
endif
for i := 1 to len(arr)
  fl := .f.
  s := substr(human->diag_plus,i,1)
  if eq_any(s,"+","-")  // старая форма
    fl := .t.
  elseif is_talon
    s := adiag_talon[i*2-1]
    fl := eq_any(s,1,2)
    if !fl   // если не определен характер заболевания, то определяем его
      fl := eq_any(adiag_talon[i*2],1,2)   // принудительно через диспансеризацию
    endif
  endif
  mshifr := padr(arr[i],5)
  if fl .and. !empty(mshifr) .and. ascan(arr_d, mshifr) == 0 .and. (k := ret_f_12(v,mshifr)) != NIL
    aadd(arr_d, mshifr)
    s_f1_f57(is_diag,k,mshifr,mpol,v,tip_travma)
    if v3 == 3 .and. (k3 := ret_f_12(v3,mshifr)) != NIL
      s_f1_f57(is_diag,k3,mshifr,mpol,v3,tip_travma)
    endif
  endif
next
return iif(len(arr_d) > 0, 1, 0)

***** 05.01.17
Function ret_f_57_wide()
Local ret := {}, i, j, k, d, r, lshifr
for k := 1 to len(arr_all) // по всем диагнозам данного случая
  lshifr := arr_all[k]
  d := diag_to_num(lshifr,1)
  for i := 1 to len(arr_57_wide) // по всем колонкам в ширину
    r := arr_57_wide[i]
    for j := 1 to len(r) // по диапазону диагнозов в одной колонке
      if between(d,r[j,1],r[j,2])
        aadd(ret,i)
      endif
    next j
  next i
  if !empty(ret) ; exit ; endif // если один из диагнозов нашли, - выходим из цикла
next k
if len(ret) == 0 ; ret := NIL ; endif
return ret

***** 04.01.17
Function s_f1_f57(is_diag,k,mshifr,mpol,v,tip_travma)
Local i, icol, j, d1, d2, fl, arr_d := {}, s, ta, lk := len(k)
ta := array(lk,20) ; afillall(ta,0)
for j := 1 to lk
  for i := 1 to len(tip_travma)
    icol := tip_travma[i]
    ta[j,icol] ++
  next
next
for j := 1 to lk
  select TMP
  find (str(v,1)+padr(k[j,1],2))
  for i := 4 to 20
    pole := "tmp->v"+strzero(i,2)
    &pole := &pole + ta[j,i]
  next
next
if is_diag > 1
  select TMP_D
  find (str(v,1)+padr(mshifr,5))
  if !found()
    append blank
    tmp_d->diagnoz := mshifr
    tmp_d->voz := v
  endif
  for i := 4 to 20
    pole := "tmp_d->v"+strzero(i,2)
    &pole := &pole + ta[1,i]
  next
endif
if is_diag == 3
  select TMP_H
  find (str(v,1)+padr(mshifr,5)+str(human->kod,7))
  if !found()
    append blank
    tmp_h->diagnoz := mshifr
    tmp_h->voz := v
    tmp_h->kod_human := human->kod
  endif
  for i := 4 to 20
    pole := "tmp_h->v"+strzero(i,2)
    &pole := &pole + ta[1,i]
  next
endif
return NIL

***** 05.01.17
Function f2_f57(is_diag)
Local i, j, k, ll, mshifr, mvozrast, d1, d2, fl, tip_travma, ret := .f., ;
      v3 := 0, mpol, s, is_talon := .t.
Private arr_v := {{0,17},{18,999}}
select TMP1RULE
find ("1")
do while tmp1rule->tip == 1 .and. !eof()
  if tmp1rule->kol1 > 0 .and. !empty(tmp1rule->shifr)
    mshifr := padr(tmp1rule->shifr,5)
    mdate := kart->date_r
    select TMP2RULE
    find (str(tmp1rule->kod,6))
    do while tmp2rule->kod == tmp1rule->kod .and. !eof()
      mdate := max(mdate,tmp2rule->n_data)
      if !empty(tmp2rule->travma)
        tip_travma := list2arr(tmp2rule->travma)
      endif
      skip
    enddo
    // определяем возраст по дате начала самого последнего лечения
    mpol := kart->pol
    mvozrast := count_years(kart->date_r, mdate)
    v := ret_v_f57(mpol,mvozrast,@v3)
    if (k := ret_f_12(v,mshifr)) != NIL
      if empty(tip_travma)
        tip_travma := {4,7}
      endif
      ret := .t.
      s_f1_f57(is_diag,k,mshifr,kart->pol,v,tip_travma)
      if v3 == 3 .and. (k3 := ret_f_12(v3,mshifr)) != NIL
        s_f1_f57(is_diag,k3,mshifr,mpol,v3,tip_travma)
      endif
    endif
  endif
  select TMP1RULE
  skip
enddo
return iif(ret, 1, 0)

***** 29.12.16
Function ret_v_f57(mpol,mvozrast,/*@*/v3)
Local v
if (v := ascan(arr_v, {|x| between(mvozrast,x[1],x[2]) } )) == 0
  v := 2 // если почему-то не нашли - взрослые
endif
v3 := 0
if v == 2 .and. ((mpol == "Ж" .and. mvozrast >= 55) .or. (mpol == "М" .and. mvozrast >= 60))
  v3 := 3 // взрослые старше трудоспособного возраста
endif
return v

*

***** 05.01.16
Function edit_bolnich(par)
Local arr_m, buf := savescreen(), i, mkod := 0, k, l_color, fl := .f., mtitul, ;
      ind2, arr_blk, fl_schet := .f., str_error := "Не найдено нужных записей!"
if (arr_m := year_month()) == NIL
  return NIL
endif
Private begin_date := arr_m[5], end_date := arr_m[6], pr_regim := par
Private mr1 := 2
mtitul := "Окончившие лечение "+arr_m[4]
mywait()
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"mo_uch",,"UCH")
G_Use(dir_server+"human_",,"HUMAN_")
G_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_, to lpu into UCH, to otd into OTD
dbseek(dtos(begin_date),.t.)
index on upper(fio)+dtos(k_data) to (cur_dir+"tmp_h") ;
      for human_->oplata < 9 .and. !between(ishod,101,305) ;
      while k_data <= end_date
go top
if eof()
  func_error(4,str_error)
else
  Alpha_Browse(mr1,2,maxrow()-2,77,"f1_e_boln",color0,mtitul,"W+/GR",,.t.,arr_blk,,"f2_e_boln",, ;
               {'═','░','═',"N/BG,W+/N,B/BG,BG+/B",.t.,600} )
endif
close databases
restscreen(buf)
return NIL

*****
Function f1_e_boln(oBrow)
Local oColumn, blk := {|| if(human->bolnich > 0, {3,4}, {1,2}) }, r := 29
//
oColumn := TBColumnNew(center("ФИО пациента",r),{||left(human->fio,r)})
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if yes_bukva // если в настройке - работа со статусом стом.больного
  oColumn := TBColumnNew("Стом.", {|| left(human_->STATUS_ST,5) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
else
  oColumn := TBColumnNew(" Учр.", {|| uch->short_name })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew(" Отд.", {|| otd->short_name })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Диаг-;ноз", {|| human->kod_diag })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" Начало;лечения", {|| date_8(human->n_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Окончан.;лечения", {|| date_8(human->k_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Больнич-;  ный", ;
                       {|| padc(if(human->bolnich>0,"есть",""),8) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
status_key("^<Esc>^ - выход;  ^<Enter>^ - редактирование;  ^<F2>^ - поиск")
return NIL

*****
Function f2_e_boln(nkey)
Static menu_bolnich := {{"нет",0},{"да ",1},{"РОД",2}}
Static tmp := " "
Local buf := savescreen(), buf1, rec1 := recno(), fl := -1, r1, ;
      c, i, j, arr, mtitul, bg := {|o,k| get_without_input(o,k,.t.) }
Private tmp1
if nkey == K_ENTER
  Private is_talon := .t.
  Private ;
    mn_data := human->n_data, ;
    mk_data := human->k_data, ;
    mpol := human->pol, ;
    M1VZROS_REB := human->VZROS_REB, ;    // 0-взрослый, 1-ребенок, 2-подросток
    mstatus_st  := human_->STATUS_ST, ;
    MKOD_DIAG  := human->KOD_DIAG , ;     // шифр 1-ой осн.болезни
    MKOD_DIAG2 := human->KOD_DIAG2, ;     // шифр 2-ой осн.болезни
    MKOD_DIAG3 := human->KOD_DIAG3, ;     // шифр 3-ой осн.болезни
    MKOD_DIAG4 := human->KOD_DIAG4, ;     // шифр 4-ой осн.болезни
    msoput_b1  := human->soput_b1 , ;
    msoput_b2  := human->soput_b2 , ;
    msoput_b3  := human->soput_b3 , ;
    msoput_b4  := human->soput_b4 , ;
    mdiag_plus := human->diag_plus, ;
    m1povod    := human_->POVOD, ;
    m1travma   := human_->TRAVMA, ;
    adiag_talon[16]                , ; // из статталона к диагнозам
    MBOLNICH, m1bolnich := human->bolnich        , ; // больничный
    mdate_b_1 := c4tod(human->date_b_1), ; // дата начала больничного
    mdate_b_2 := c4tod(human->date_b_2), ; // дата окончания больничного
    mrodit_dr  := ctod("")          , ; // дата рождения родителя
    mrodit_pol := " "               , ; // пол родителя
    gl_area := {r1,0,23,79,0}
  if m1bolnich == 2
    mrodit_dr  := human_->RODIT_DR
    mrodit_pol := human_->RODIT_POL
  endif
  mbolnich := inieditspr(A__MENUVERT, menu_bolnich, m1bolnich)
  make_diagP(1)  // сделать "шестизначные" диагнозы
  afill(adiag_talon,0)
  for i := 1 to 16
    adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
  next
  Private mpovod  := inieditspr(A__MENUVERT, stm_povod, m1povod)
  Private mtravma := inieditspr(A__MENUVERT, stm_travma, m1travma)
  Private row_dop_diag := 7
  //
  mtitul := "Редактирование "+{"больничного","стат.талона"}[pr_regim]
  box_shadow(10,0,21,79,color1,mtitul,color8)
  setcolor(cDataCGet)
  @ 11,1 say "Вид и номер учетного документа: "
  @ row(),col() say human->UCH_DOC color "G+/B"
  @ 12,1 say "Ф.И.О.: "
  @ row(),col() say human->fio color "G+/B"
  @ 13,1  say "Дата рождения: "
  @ row(),col() say human->DATE_R color "G+/B"
  @ 14,1 say "Срок лечения с "
  @ row(),col() say full_date(human->n_data) color color8
  @ row(),col() say " по "
  @ row(),col() say full_date(human->k_data) color color8
  if yes_bukva // если в настройке для отделения - работа со статусом стом.больного
    @ 15,34 say "Статус стоматологического больного" get mstatus_st picture "@!" ;
            valid {|g| f_valid_status_st(g) }
  endif
  if pr_regim == 1
    @ 16,1 say "Основной диагноз" get mkod_diag when .f.
    @ 18,1 say "Больничный" get mbolnich ;
            reader {|x|menu_reader(x,menu_bolnich,A__MENUVERT,,,.f.)} ;
            valid {|g,o| f_valid_bolnich(g,o) }
         @ row(),col()+1 say "==> с" get mdate_b_1 when m1bolnich > 0
         @ row(),col()+1 say "по" get mdate_b_2 when m1bolnich > 0
         @ row(),col()+1 say "Д.р.родителя" get mrodit_dr when m1bolnich == 2
    if mem_pol == 1
         @ row(),col()+1 say "Пол" get mrodit_pol ;
                reader {|x|menu_reader(x,menupol,A__MENUVERT,,,.f.)} ;
                when m1bolnich == 2
    else
         @ row(),col()+1 say "Пол" get mrodit_pol pict "@!" ;
                valid {|g| mrodit_pol $ "МЖ" } ;
                when m1bolnich == 2
    endif
  else
    @ 16,1 say "Основной диагноз       " get mkod_diag  reader {|o|MyGetReader(o,bg)} when when_diag()
    @ 17,1 say "Сопутствующие диагнозы " get mkod_diag2 reader {|o|MyGetReader(o,bg)} when when_diag()
    @ row(),col() say ","                get mkod_diag3 reader {|o|MyGetReader(o,bg)} when when_diag()
    @ row(),col() say ","                get mkod_diag4 reader {|o|MyGetReader(o,bg)} when when_diag()
    @ row(),col() say ","                get msoput_b1  reader {|o|MyGetReader(o,bg)} when when_diag()
    @ row(),col() say ","                get msoput_b2  reader {|o|MyGetReader(o,bg)} when when_diag()
    @ row(),col() say ","                get msoput_b3  reader {|o|MyGetReader(o,bg)} when when_diag()
    @ row(),col() say ","                get msoput_b4  reader {|o|MyGetReader(o,bg)} when when_diag()
    if mem_st_pov == 1
      @ 18,1 say "Повод обращения" get mpovod ;
             reader {|x|menu_reader(x,stm_povod,A__MENUVERT,,,.f.)}
    else
      @ 18,1 say "Повод обращения" get m1povod pict "9" ;
             valid {|g| val_st_pov(g) }
      @ row(),col()+1 get mpovod color color14 when .f.
    endif
    if .t.//is_travma // если в настройке для отделения - работа с травмой
      if mem_st_trav == 1
        @ 18,43 say "Вид травмы" get mtravma ;
               reader {|x|menu_reader(x,stm_travma,A__MENUVERT,,,.f.)}
      else
        @ 18,43 say "Вид травмы" get m1travma pict "99" ;
                valid {|g| val_st_trav(g) }
        @ row(),col()+1 get mtravma color color14 when .f.
      endif
    endif
    put_dop_diag()
    set key K_F10 TO inp_dop_diag
  endif
  status_key("^<Esc>^ - выход;  ^<PgDn>^ - запись"+iif(pr_regim==2,";  ^<F10>^ - доп.информация к диагнозу",""))
  myread()
  if pr_regim == 2
    set key K_F10 TO
  endif
  if lastkey() != K_ESC .and. f_Esc_Enter(1)
    make_diagP(2)  // сделать "пятизначные" диагнозы
    select HUMAN_
    G_RLock(forever)
    select HUMAN
    G_RLock(forever)
    human_->STATUS_ST := ltrim(MSTATUS_ST)
    if pr_regim == 1
      human->bolnich    := m1bolnich
      human->date_b_1   := iif(m1bolnich==0,"",dtoc4(mdate_b_1))
      human->date_b_2   := iif(m1bolnich==0,"",dtoc4(mdate_b_2))
      human_->RODIT_DR  := iif(m1bolnich<2,ctod(""),mrodit_dr)
      human_->RODIT_POL := iif(m1bolnich<2,"",mrodit_pol)
    else
      s := "" ; aeval(adiag_talon, {|x| s += str(x,1) })
      human_->DISPANS := s
      human_->POVOD   := m1povod
      human_->TRAVMA  := m1travma
    endif
    /*replace ;       т.е. диагнозы запрещено изменять
       human->KOD_DIAG  with MKOD_DIAG  , ;   // шифр 1-ой осн.болезни
       human->KOD_DIAG2 with MKOD_DIAG2 , ;   // шифр 2-ой осн.болезни
       human->KOD_DIAG3 with MKOD_DIAG3 , ;   // шифр 3-ой осн.болезни
       human->KOD_DIAG4 with MKOD_DIAG4 , ;   // шифр 4-ой осн.болезни
       human->SOPUT_B1  with MSOPUT_B1  , ;   // шифр 1-ой сопутствующей болезни
       human->SOPUT_B2  with MSOPUT_B2  , ;   // шифр 2-ой сопутствующей болезни
       human->SOPUT_B3  with MSOPUT_B3  , ;   // шифр 3-ой сопутствующей болезни
       human->SOPUT_B4  with MSOPUT_B4  , ;   // шифр 4-ой сопутствующей болезни
       human->diag_plus with mdiag_plus
    */
    UnLock
    Commit
  endif
  select HUMAN
  setcolor(color0)
  restscreen(buf)
  return -1
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
  i := 0
  Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := mr1+3, ;
          k2 := 21, tmp2 := upper(tmp), ch := left(tmp,1)
  if !(ch == "*" .or. ch == "?")
    tmp1 := tmp2
    if "*" $ tmp1 ; tmp1 := beforatnum("*",tmp1,1) ; endif
    if "?" $ tmp1 ; tmp1 := beforatnum("?",tmp1,1) ; endif
    if len(tmp1) > 12 ; tmp1 := left(tmp1,12) ; endif
    ch := len(tmp1)
    find (tmp1)
    do while tmp1 == left(upper(fio),ch) .and. !eof()
      if like(tmp2,upper(fio))
        if ++i > 4000 ; exit ; endif
        aadd(tmp_mas,human->fio) ; aadd(tmp_kod,human->(recno()))
      endif
      skip
    enddo
  else
    go top
    do while !eof()
      if like(tmp2,upper(fio))
        if ++i > 4000 ; exit ; endif
        aadd(tmp_mas,human->fio) ; aadd(tmp_kod,human->(recno()))
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
    status_key("^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор")
    if (i := popup(k1+1,13,k2,66,tmp_mas,i,color0)) > 0
      goto (tmp_kod[i])
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
