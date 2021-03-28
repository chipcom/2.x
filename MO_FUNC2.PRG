***** mo_func2.prg
#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 14.02.17 вернуть код СМО из наименования файла РАК (т.е. чей РАК)
Function ret_owner_rak(fname)
return padr(BeforAtNum("M",substr(fname,3),1),5)

***** 09.02.15 ищем в массиве (1-ый параметр) любое вхождение со 2-го параметра и т.д.
Function eq_ascan( ... )
Local fl := .f., i, arr := hb_aParams()
if len(arr) > 1 .and. valtype(arr[1]) == "A"
  for i := 2 to len(arr) // начиная со второго параметра
    if ascan(arr[1],arr[i]) > 0 // проверяем вхождение в массив
      fl := .t. ; exit
    endif
  next
endif
return fl

***** 06.04.15 сделать усечённое меню, если третий параметр больше 0
Function mo_cut_menu(old_menu)
Local i, new_menu := {}
for i := 1 to len(old_menu)
  if old_menu[i,3] > 0
    aadd(new_menu, aclone(old_menu[i]))
  endif
next
return new_menu

***** 22.09.15 вернуть коэф-т оплаты случая из РАК-ов
Function ret_koef_from_RAK(lkod)
Local koef := 1, k := 0 // по умолчанию оплачен, если даже нет РАКа
if select("RAKSH") == 0
  R_Use(dir_server+"mo_raksh",,"RAKSH")
  index on str(kod_h,7) to (cur_dir+"tmp_raksh")
endif
select RAKSH
find (str(lkod,7))
do while lkod == raksh->kod_h .and. !eof()
  k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
  skip
enddo
if !empty(round(k,2))
  k := human->cena_1 - k
  if human->cena_1 > 0
    koef := k/human->cena_1
  endif
endif
return koef

***** 24.04.13 вернуть действующую СМО
Function ret_actual_smo(r,c)
Static si := 34007
Local i, arr := {}, ret, ret_arr
DEFAULT r TO T_ROW, c TO T_COL-5
for i := 1 to len(glob_arr_smo)
  if glob_arr_smo[i,3] == 1
    aadd(arr,glob_arr_smo[i])
  endif
next
if popup_2array(arr,r,c,si,1,@ret_arr) > 0 .and. valtype(ret_arr) == "A"
  ret := array(2)
  si := ret_arr[2]
  ret[1] := padr(lstr(ret_arr[2]),5)
  ret[2] := ret_arr[1]
endif
return ret

***** вернуть уникальное значение CODE (N8) для XML-файлов
Function ret_unique_code(_kod,nlen)
Static strValid := "0123456789"
Local i, n, s := ""
DEFAULT nlen TO 8
for i := 1 To nlen
  n := random()+mem_beg_rees // поправка на начальный номер реестра
  s += substr(strValid, n%10 + 1, 1) // по алгориитму GUID
next
s += lstr(_kod) // добавим к строке код записи
do while len(s) > nlen
  s := substr(s,2)  // на всякий случай сделаем не более nlen символов
enddo
return val(s)

***** 12.07.20 определить лицо старше трудоспособного возраста
Function f_starshe_trudosp(_pol,_date_r,_data,par)
Local v
DEFAULT par TO 1
if par == 1
  v := iif(_pol=="М", 60, 55) // для МИАЦ
else
  v := iif(_pol=="М", 65, 60) // для ТФОМС
endif
return count_years(_date_r,_data) >= v

***** 02.01.21
Function arr_plan_zakaz(ly)
Local i, apz := {}
DEFAULT ly TO 2021
if ly > 2020
  for i := 1 to len(glob_array_PZ_21)
    aadd(apz,{glob_array_PZ_21[i,3],;
              glob_array_PZ_21[i,1],;
              0,;
              glob_array_PZ_21[i,6],;
              glob_array_PZ_21[i,5],;
              {};
             } )
  next
elseif ly == 2020
  for i := 1 to len(glob_array_PZ_20)
    aadd(apz,{glob_array_PZ_20[i,3],;
              glob_array_PZ_20[i,1],;
              0,;
              glob_array_PZ_20[i,6],;
              glob_array_PZ_20[i,5],;
              {};
             } )
  next
elseif ly == 2019
  for i := 1 to len(glob_array_PZ_19)
    aadd(apz,{glob_array_PZ_19[i,3],;
              glob_array_PZ_19[i,1],;
              0,;
              glob_array_PZ_19[i,6],;
              glob_array_PZ_19[i,5],;
              {};
             } )
  next
else
  for i := 1 to len(glob_array_PZ_18)
    aadd(apz,{glob_array_PZ_18[i,3],;
              glob_array_PZ_18[i,1],;
              0,;
              glob_array_PZ_18[i,6],;
              glob_array_PZ_18[i,5],;
              {};
             } )
  next
endif
return apz

***** 02.01.21 по шифру услуги вернуть номер элемента массива "arr_plan_zakaz" для 2020 года
Function f_arr_plan_zakaz_21(lshifr)
Local i, j, c, k := 0, shb, i16 := 0
if select("LUSL") == 0
  Use_base("lusl")
endif
select LUSL
find (padr(lshifr,10))
if found() .and. !empty(lusl->unit_code)
  if select("MOUNIT") == 0
    R_Use(dir_exe+"_mo1unit",cur_dir+"_mo1unit","MOUNIT")
  endif
  select MOUNIT
  set order to 1
  find (str(lusl->unit_code,3))
  if found() .and. mounit->pz > 0
    k := mounit->pz
    i16 := mounit->ii
  endif
endif
if k > 0 .and. empty(i16)
  i16 := ascan(glob_array_PZ_21, {|x| x[1] == k })
endif
return i16

***** 02.01.21 по шифру услуги вернуть номер элемента массива "arr_plan_zakaz" для 2020 года
Function f_arr_plan_zakaz_20(lshifr)
Local i, j, c, k := 0, shb, i16 := 0
if select("LUSL") == 0
  Use_base("lusl")
endif
select LUSL20
find (padr(lshifr,10))
if found() .and. !empty(lusl20->unit_code)
  if select("MOUNIT20") == 0
    R_Use(dir_exe+"_mo0unit",cur_dir+"_mo0unit","MOUNIT20")
  endif
  select MOUNIT20
  set order to 1
  find (str(lusl20->unit_code,3))
  if found() .and. mounit20->pz > 0
    k := mounit20->pz
    i16 := mounit20->ii
  endif
endif
if k > 0 .and. empty(i16)
  i16 := ascan(glob_array_PZ_20, {|x| x[1] == k })
endif
return i16

***** 02.01.19 по шифру услуги вернуть номер элемента массива "arr_plan_zakaz" для 2019 года
Function f_arr_plan_zakaz_19(lshifr)
Local i, j, c, k := 0, shb, i16 := 0
if select("LUSL") == 0
  Use_base("lusl")
endif
select LUSL19
find (padr(lshifr,10))
if found() .and. !empty(lusl19->unit_code)
  if select("MOUNIT19") == 0
    R_Use(dir_exe+"_mo9unit",cur_dir+"_mo9unit","MOUNIT19")
  endif
  select MOUNIT19
  set order to 1
  find (str(lusl19->unit_code,3))
  if found() .and. mounit19->pz > 0
    k := mounit19->pz
    i16 := mounit19->ii
  endif
endif
if k > 0 .and. empty(i16)
  i16 := ascan(glob_array_PZ_19, {|x| x[1] == k })
endif
return i16

***** 04.02.18 по шифру услуги вернуть номер элемента массива "arr_plan_zakaz" для 2018 года
Function f_arr_plan_zakaz_18(lshifr)
Local i, j, c, k := 0, shb, i16 := 0
if select("LUSL") == 0
  Use_base("lusl")
endif
select LUSL18
find (padr(lshifr,10))
if found() .and. !empty(lusl18->unit_code)
  if select("MOUNIT18") == 0
    R_Use(dir_exe+"_mo8unit",cur_dir+"_mo8unit","MOUNIT18")
  endif
  select MOUNIT18
  set order to 1
  find (str(lusl18->unit_code,3))
  if found() .and. mounit18->pz > 0
    k := mounit18->pz
    i16 := mounit18->ii
  endif
endif
if k > 0 .and. empty(i16)
  i16 := ascan(glob_array_PZ_18, {|x| x[1] == k })
endif
return i16

/***** 19.04.15
Function arr_plan_zakaz(fl)
Local i, apz := {}
DEFAULT fl TO .f.
aadd(apz,{"Случай госпитализации",         0,0,{}})
aadd(apz,{"Обращение",                    32,0,{"2.78.*","2.89.*"}})
aadd(apz,{"Посещение неотложное",         31,0,{"2.80.*","2.82.*"}})
aadd(apz,{"Посещение профилактическое",   30,0,{"2.76.*","2.79.*","2.81.*","2.88.*"}})
if fl // вызываем из план-заказа, чтобы выделить центры здоровья
  i := len(apz)
  del_array(apz[i,4],1) // удаляем 2.76.*
  aadd(apz,{"Посещение Центра здоровья",  35,0,{"2.76.*"}})
endif
aadd(apz,{"Посещение при диспансеризации",34,0,{"2.3.*","2.83.*","2.84.*","2.85.*","2.86.*","2.87.*"}})
aadd(apz,{"УЕТ стоматологии",              5,0,{"57.*"}})
aadd(apz,{"Пациенто-день",                 2,0,{"55.1.*","55.2.*","55.3.*","55.4.*"}})
aadd(apz,{"Гемодиализ",                   28,0,{"60.2.9"}})
aadd(apz,{"Р-исследование",               33,0,{"4.20.702","4.15.746","60.2.1","60.2.2","60.2.3","60.2.4","60.2.6","60.2.7","60.2.8"}})
if fl // вызываем из план-заказа, чтобы выделить жидкостную цитологию
  i := len(apz)
  del_array(apz[i,4],1) // удаляем "4.20.702"
  del_array(apz[i,4],1) // удаляем "4.15.746"
  aadd(apz,{"Лабораторные исследования",  36,0,{"4.20.702","4.15.746"}})
endif
aadd(apz,{"Вызов СМП",                    26,0,{"71.*"}})
//aadd(apz,{"Случай в дневном стационаре",  99,0,{}})
return apz*/

***** 26.02.13
Function f14tf_array()
Static arr_name := {;
  "Количество амбулаторно-поликлинических посещений",; // 1
  "Количество койко-дней",;                            // 2
  "Количество дней лечения в дневном стационаре при стационаре",;  // 3
  "Количество дней лечения в дневном стационаре при поликлинике",; // 4
  "Количество дней лечения в стационаре на дому",;                 // 5
  "Количество стоматологических посещений",; // 6
  "Количество отдельных медицинских услуг",; // 7
  "Количество вызовов скорой медицинской помощи",; // 8
  "Количество лечебных УЕТ",;        // 9
  "Количество ортодонтических УЕТ",; // 10
  "Услуги, не вошедшие в 14-ю форму"}
return arr_name

***** 24.02.21
Function f14tf_nastr(/*@*/lshifr,/*@*/lname,lyear)
Static a_usl, a_zak_sl, syear
Local ta := {}, i, j, k, i14 := 0, arr, shb, fl := .f., fl1 := .f., ret := {}
if type("apz2016") == "A" .and. !empty(apz2016)
  if type("is_2021") == "L" .and. is_2021
    i14 := f_arr_plan_zakaz_21(lshifr)
  elseif type("is_2020") == "L" .and. is_2020
    i14 := f_arr_plan_zakaz_20(lshifr)
  elseif type("is_2019") == "L" .and. is_2019
    i14 := f_arr_plan_zakaz_19(lshifr)
  else
    i14 := f_arr_plan_zakaz_18(lshifr)
  endif
endif
if a_usl == NIL .or. syear != lyear
  a_usl := array(10,2)
  // врачебные приемы
  a_usl[1,1] := {"2.*","70.*","72.*"}
  a_usl[1,2] := {"2.4.*",;
                 "2.78.47","2.78.48","2.78.49","2.78.50","2.78.51","2.78.52","2.78.53",;
                 "2.79.52","2.79.53","2.79.54","2.79.55","2.79.56","2.79.57","2.79.58",;
                 "2.88.40","2.88.41","2.88.42","2.88.43","2.88.44","2.88.45",;
                 "2.80.29","2.80.30","2.80.31","2.80.32","2.80.33"}
  // койко-дни
  a_usl[2,1] := {"1.*"} // включаемые услуги
  // a_usl[2,2] := {"1.12.*","1.13.*","1.14.*","1.15.*","1.16.*","1.17.*","1.18.*"} // исключаемые услуги 07.02.21
  a_usl[2,2] := {"1.12.*","1.13.*","1.14.*","1.15.*","1.16.*","1.17.*","1.18.*","1.20.*"} // исключаемые услуги 07.02.21
  // дневной стационар при стационаре
  a_usl[3,1] := {"55.1.1","55.1.4","55.1.5","55.2.*","55.5.*","55.8.*","60.2.9"}
  a_usl[3,2] := {}
  // дневной стационар при поликлинике
  a_usl[4,1] := {"55.1.2","55.3.*","55.6.*"}
  a_usl[4,2] := {}
  // дневной стационар на дому
  a_usl[5,1] := {"55.1.3","55.4.*","55.7.*"}
  a_usl[5,2] := {}
  // стомат.врачебные приемы
  a_usl[6,1] := {}
  f_vid_p_stom({},{},a_usl[6,1]) // добавим все новые стоматологические приёмы
  a_usl[6,2] := {}
  // отдельные медицинские услуги
  a_usl[7,1] := {"4.20.702","4.15.746","4.17.777","4.11.738","4.11.739","4.11.740","4.8.804",;
                 "4.12.7*","4.12.8*","4.12.9*","4.13.7*","4.15.7*","4.16.7*","4.17.7*","4.27.1",;
                 "60.*"}
  a_usl[7,2] := {"60.2.9"}
  // СМП
  a_usl[8,1] := {"71.*"}
  a_usl[8,2] := {}
  // лечебные УЕТ
  a_usl[9,1] := {"57.1.*","57.2.*","57.3.*","57.5.*"}
  a_usl[9,2] := {"57.1.4","57.1.32","57.1.33"}
  // ортодонтические УЕТ
  a_usl[10,1] := {"57.1.4","57.1.32","57.1.33","57.4.*"}
  a_usl[10,2] := {}
endif
lshifr := alltrim(lshifr)
if select("LUSL") == 0
  Use_base("lusl")
endif
select LUSL
find (padr(lshifr,10))
if found()
  lname := lusl->name  // наименование услуги из справочника ТФОМС
endif
//my_debug(,str(lyear))
if lyear == 2021
  if is_ksg(lshifr,1) .or. left(lshifr,5) == "1.20."  // 07.02.21
    return {{2,-1,i14}}
  elseif is_ksg(lshifr,2) // КСГ дневного стационара
    return {{3,-1,i14}}
  endif
else
  if is_ksg(lshifr,1) .or. left(lshifr,5) == "1.12."
    return {{2,-1,i14}}
  elseif is_ksg(lshifr,2) // КСГ дневного стационара
    return {{3,-1,i14}}
  endif
endif
// включаемые услуги
for j := 1 to len(a_usl)
  for i := 1 to len(a_usl[j,1])
    if !empty(shb := a_usl[j,1,i])
      if "*" $ shb .or. "?" $ shb
        fl := like(alltrim(shb),lshifr)
      else
        fl := (shb == lshifr)
      endif
      if fl
        if f_is_zak_sl_vr(lshifr) .or. f_dn_stac_01_04(lshifr)
          k := -1 // зак.случай в п-ке или дневной стационар
        else
          k := 0
        endif
        aadd(ta,{j,k,i14})
      endif
    endif
  next
next
for k := 1 to len(ta)  // исключаемые услуги
  j := ta[k,1]
  for i := 1 to len(a_usl[j,2])
    if !empty(shb := a_usl[j,2,i])
      if "*" $ shb .or. "?" $ shb
        fl := !like(alltrim(shb),lshifr)
      else
        fl := !(shb == lshifr)
      endif
      if !fl ; ta[k,1] := 0 ; endif
    endif
  next
next
for k := 1 to len(ta)
  if ta[k,1] > 0
    aadd(ret,ta[k])
  endif
next
if len(ret) == 0
  aadd(ret,{len(a_usl)+1,0,i14})
endif
return ret

***** подменить услуги по по законченным случаям на обычные койко-дни
Function ChangeUslugiZakSluch()
Local arr := {}
aadd(arr,{"1.7.1","1.2.1"})
aadd(arr,{"1.7.2","1.2.6"})
aadd(arr,{"1.7.3","1.2.6"})
aadd(arr,{"1.7.4","1.2.6"})
aadd(arr,{"1.7.5","1.2.6"})
aadd(arr,{"1.7.6","1.2.6"})
aadd(arr,{"1.7.7","1.2.14"})
aadd(arr,{"1.7.8","1.2.14"})
aadd(arr,{"1.7.9","1.2.6"})
aadd(arr,{"1.7.10","1.2.6"})
aadd(arr,{"1.7.11","1.2.14"})
aadd(arr,{"1.7.12","1.2.3"})
aadd(arr,{"1.7.13","1.2.19"})
aadd(arr,{"1.7.14","1.2.19"})
aadd(arr,{"1.7.15","1.2.19"})
aadd(arr,{"1.7.16","1.2.19"})
aadd(arr,{"1.7.17","1.2.19"})
aadd(arr,{"1.7.18","1.2.19"})
aadd(arr,{"1.7.19","1.1.5"})
aadd(arr,{"1.7.20","1.1.9"})
aadd(arr,{"1.7.21","1.1.52"})
aadd(arr,{"1.7.22","1.1.5"})
aadd(arr,{"1.7.23","1.1.9"})
aadd(arr,{"1.7.24","1.1.52"})
aadd(arr,{"1.7.25","1.4.2"})
aadd(arr,{"1.7.26","1.1.7"})
aadd(arr,{"1.7.27","1.1.5"})
aadd(arr,{"1.7.28","1.1.5"})
aadd(arr,{"1.7.29","1.1.5"})
aadd(arr,{"1.7.30","1.1.3"})  // (неврология)
aadd(arr,{"1.7.31","1.1.3"})  // (неврология)
aadd(arr,{"1.7.32","1.2.3"})  // (нейрохирургия)
aadd(arr,{"1.7.33","1.2.1"})
aadd(arr,{"1.7.34","1.2.5"})
aadd(arr,{"1.7.35","1.1.5"})
aadd(arr,{"1.7.36","1.1.11"})
aadd(arr,{"1.7.37","1.2.1"})
aadd(arr,{"1.7.38","1.2.25"})
aadd(arr,{"1.7.39","1.2.25"})
aadd(arr,{"1.7.40","1.1.36"}) // патологии новорожденных
aadd(arr,{"1.7.41","1.2.25"})
aadd(arr,{"1.7.42","1.2.25"})
aadd(arr,{"1.7.43","1.1.36"}) // патологии новорожденных
aadd(arr,{"1.7.44","1.1.19"})
aadd(arr,{"1.7.45","1.1.19"})
aadd(arr,{"1.7.46","1.1.7"})
aadd(arr,{"1.7.47","1.1.5"})
aadd(arr,{"1.7.48","1.4.2"})
aadd(arr,{"1.7.49","1.1.7"})
aadd(arr,{"1.7.50","1.2.15"})
aadd(arr,{"1.7.51","1.2.3"})
aadd(arr,{"1.7.52","1.2.3"})
aadd(arr,{"1.7.53","1.1.1"})  // эндокринология
aadd(arr,{"1.7.54","1.2.3"})
aadd(arr,{"1.7.55","1.2.7"})
aadd(arr,{"1.7.56","1.1.3"})
aadd(arr,{"1.7.57","1.1.8"})
aadd(arr,{"1.7.58","1.1.19"})  // (педиатрия)
aadd(arr,{"1.7.59","1.1.5"})   // (терапия)
aadd(arr,{"1.7.60","1.1.11"})  // (гастроэнтерология)
aadd(arr,{"1.7.61","1.2.1"})   // (хирургия)
aadd(arr,{"1.7.62","1.1.19"})  // (педиатрия)
aadd(arr,{"1.7.63","1.1.5"})   // (терапия)
aadd(arr,{"1.7.64","1.1.11"})  // (гастроэнтерология)
aadd(arr,{"1.7.65","1.2.1"})   // (хирургия)
aadd(arr,{"1.7.66","1.1.19"})  // (педиатрия)
aadd(arr,{"1.7.67","1.1.5"})   // (терапия)
aadd(arr,{"1.7.68","1.1.9"})   // (пульмонология)
aadd(arr,{"1.7.69","1.1.19"})  // (педиатрия)
aadd(arr,{"1.7.70","1.1.53"})  // (аллергология)
aadd(arr,{"1.7.71","1.1.5"})   // (терапия)
aadd(arr,{"1.7.72","1.1.1"})   // эндокринология
aadd(arr,{"1.7.73","1.1.19"})  // (педиатрия)
aadd(arr,{"1.7.74","1.2.1"})   // (хирургия)
aadd(arr,{"1.7.75","1.1.5"})   // (терапия)
aadd(arr,{"1.7.77","1.1.11"})  // (гастроэнтерология)
aadd(arr,{"1.7.78","1.1.36"})  // патологии новорожденных
aadd(arr,{"1.7.79","1.1.7"})   // (кардиология)
aadd(arr,{"1.7.80","1.1.5"})   // (терапия)
//
aadd(arr,{"1.10.1","1.1.5"})   // (терапия)
aadd(arr,{"1.10.2","1.1.9"})   // (пульмонология)
aadd(arr,{"1.10.3","1.1.52"})  // (инфекционное отд)
aadd(arr,{"1.10.4","1.1.19"})  // (педиатрия)
aadd(arr,{"1.10.5","1.1.19"})  // (педиатрия)
aadd(arr,{"1.10.6","1.1.5"})   // (терапия)
aadd(arr,{"1.10.7","1.1.9"})   // (пульмонология)
aadd(arr,{"1.10.8","1.1.52"})  // (инфекционное отд)
aadd(arr,{"1.10.9","1.1.7"})   // (кардиология)
aadd(arr,{"1.10.10","1.1.5"})  // (терапия)
aadd(arr,{"1.10.11","1.1.7"})  // (кардиология )
aadd(arr,{"1.10.12","1.1.5"})  // (терапия)
aadd(arr,{"1.10.13","1.2.3"})  // (нейрохирургия)
aadd(arr,{"1.10.14","1.2.3"})  // (нейрохирургия)
aadd(arr,{"1.10.15","1.1.5"})  // (терапия)
aadd(arr,{"1.10.16","1.1.5"})  // (терапия)
aadd(arr,{"1.10.17","1.1.3"})  // (неврология)
aadd(arr,{"1.10.18","1.1.3"})  // (неврология)
aadd(arr,{"1.10.19","1.2.3"})  // (нейрохирургия)
aadd(arr,{"1.10.20","1.2.1"})  // (хирургия)
aadd(arr,{"1.10.21","1.2.5"})  // (травматология)
aadd(arr,{"1.10.22","1.1.5"})  // (терапия)
aadd(arr,{"1.10.23","1.1.11"}) // (гастроэнтерология)
aadd(arr,{"1.10.24","1.2.1"})  // (хирургия)
aadd(arr,{"1.10.25","1.1.19"}) // (педиатрия)
aadd(arr,{"1.10.26","1.2.19"}) // (онкология)
aadd(arr,{"1.10.27","1.2.19"}) // (онкология)
aadd(arr,{"1.10.28","1.2.19"}) // (онкология)
aadd(arr,{"1.10.29","1.2.19"}) // (онкология)
aadd(arr,{"1.10.30","1.2.19"}) // (онкология)
aadd(arr,{"1.10.31","1.2.19"}) // (онкология)
aadd(arr,{"1.10.32","1.2.25"}) //
aadd(arr,{"1.10.33","1.1.36"}) // патологии новорожденных
aadd(arr,{"1.10.34","1.2.25"}) //
aadd(arr,{"1.10.35","1.1.36"}) //
aadd(arr,{"1.10.36","1.2.15"}) // (торакальной хирургии)
aadd(arr,{"1.10.37","1.1.5"})  // (терапия)
aadd(arr,{"1.10.38","1.1.11"}) // (гастроэнтерология)
aadd(arr,{"1.10.39","1.2.1"})  // (хирургия)
aadd(arr,{"1.10.40","1.1.19"}) // (педиатрия)
aadd(arr,{"1.10.41","1.1.5"})  // (терапия)
aadd(arr,{"1.10.42","1.1.11"}) // (гастроэнтерология)
aadd(arr,{"1.10.43","1.2.1"})  // (хирургия)
aadd(arr,{"1.10.44","1.1.19"}) // (педиатрия)
aadd(arr,{"1.10.45","1.1.5"})  // (терапия)
aadd(arr,{"1.10.46","1.1.9"})  // (пульмонология)
aadd(arr,{"1.10.47","1.1.19"}) // (педиатрия)
aadd(arr,{"1.10.48","1.1.53"}) // (аллергология)
aadd(arr,{"1.10.49","1.1.5"})  // (терапия)
aadd(arr,{"1.10.50","1.1.1"})  // эндокринология
aadd(arr,{"1.10.51","1.1.19"}) // (педиатрия)
aadd(arr,{"1.10.52","1.2.1"})  // (хирургия)
aadd(arr,{"1.10.53","1.1.5"})  // (терапия)
aadd(arr,{"1.10.55","1.1.11"}) // (гастроэнтерология)
aadd(arr,{"1.10.56","1.1.36"}) // патологии новорожденных
aadd(arr,{"1.10.57","1.1.7"})  // (кардиология)
aadd(arr,{"1.10.58","1.1.5"})  // (терапия)
return arr

*

***** Перечень кодов мед.услуг, используемых при определении размера финансирования
***** медицинских организаций, участвующих в мероприятиях по повышению доступности
***** амбулаторной медицинской помощи, проводимых в рамках Программа модернизации
***** здравоохранения Волгоградской области на 2011-2012 годы
Function UsllugiUzkieSpec()
Local arr := {}
//2.  ВРАЧЕБНЫЙ ПРИЕМ ПО ПРОФИЛЯМ
aadd(arr,{"2.1.1"  ,"Врачебный прием терапевтический"})  // !!!
aadd(arr,{"2.2.1"  ,"Врачебный прием пульмонологический"})
aadd(arr,{"2.9.1"  ,"Врачебный прием дерматологический"})
aadd(arr,{"2.11.1" ,"Врачебный прием ревматологический"})
aadd(arr,{"2.14.1" ,"Врачебный прием травматолога-ортопеда"})
aadd(arr,{"2.15.1" ,"Врачебный прием урологический"})
aadd(arr,{"2.16.1" ,"Врачебный прием акушера-гинеколога"})
aadd(arr,{"2.18.1" ,"Врачебный прием отоларингологический"})
aadd(arr,{"2.19.1" ,"Врачебный прием аллерголога-иммунолога"})
aadd(arr,{"2.20.1" ,"Врачебный прием хирургический"})
aadd(arr,{"2.21.1" ,"Врачебный прием кардиологический"})
aadd(arr,{"2.22.1" ,"Врачебный прием онкологический"})
aadd(arr,{"2.22.3" ,"Врачебный прием онколога-маммолога"})
aadd(arr,{"2.22.4" ,"Врачебный прием онколога-колопроктолога"})
aadd(arr,{"2.22.5" ,"Врачебный прием торакального онколога"})
aadd(arr,{"2.22.6" ,"Врачебный прием онколога-гинеколога"})
aadd(arr,{"2.22.7" ,"Врачебный прием онколога-отоларинголога"})
aadd(arr,{"2.22.8" ,"Врачебный прием онколога-уролога"})
aadd(arr,{"2.22.9" ,"Врачебный прием онколога-стоматолога"})
aadd(arr,{"2.22.10","Врачебный прием онколога-гематолога"})
aadd(arr,{"2.22.11","Врачебный прием онколога-химиотерапевта"})
aadd(arr,{"2.22.12","Врачебный прием радиолога"})
aadd(arr,{"2.24.1" ,"Врачебный прием рефлексотерапевтический"})
aadd(arr,{"2.27.1" ,"Врачебный прием эндокринологический"})
aadd(arr,{"2.29.1" ,"Врачебный прием офтальмологический"})
aadd(arr,{"2.30.1" ,"Врачебный прием неврологический"})
aadd(arr,{"2.31.1" ,"Врачебный прием гастроэнтерологический"})
aadd(arr,{"2.32.1" ,"Врачебный прием педиатрический"})   // !!!
aadd(arr,{"2.34.1" ,"Врачебный прием физиотерапевтический"})
aadd(arr,{"2.34.3" ,"Прием врача физиотерапевтической поликлиники"})
aadd(arr,{"2.35.1" ,"Врачебный прием врача по лечебной физкультуре"})
aadd(arr,{"2.41.1" ,"Врачебный прием инфекционный"})
aadd(arr,{"2.56.4" ,"Посещение неврологом на дому"})
aadd(arr,{"2.56.5" ,"Посещение кардиологом на дому"})
aadd(arr,{"2.56.6" ,"Посещение ревматологом на дому"})
aadd(arr,{"2.56.7" ,"Посещение хирургом на дому"})
aadd(arr,{"2.56.8" ,"Посещение урологом на дому"})
aadd(arr,{"2.56.9" ,"Посещение онкологом на дому"})
aadd(arr,{"2.56.10","Посещение акушером-гинекологом на дому"})
aadd(arr,{"2.56.11","Посещение дерматологом на дому"})
aadd(arr,{"2.56.12","Посещение офтальмологом на дому"})
aadd(arr,{"2.56.13","Посещение отоларингологом на дому"})
aadd(arr,{"2.56.14","Посещение травматологом на дому"})
aadd(arr,{"2.57.2" ,"Врачебный прием нейрохирурга"})
aadd(arr,{"2.57.3" ,"Врачебный прием колопроктолога"})
aadd(arr,{"2.57.4" ,"Врачебный прием сердечно-сосудистого хирурга"})
//2.70. ВРАЧЕБНЫЕ ПРИЕМЫ КОНСУЛЬТАТИВНЫЕ
aadd(arr,{"2.70.1" ,"Консультативный прием кардиолога"})
aadd(arr,{"2.70.2" ,"Консультативный прием ревматолога"})
aadd(arr,{"2.70.3" ,"Консультативный прием гастроэнтеролога"})
aadd(arr,{"2.70.4" ,"Консультативный прием пульмонолога"})
aadd(arr,{"2.70.5" ,"Консультативный прием эндокринолога"})
aadd(arr,{"2.70.6" ,"Консультативный прием нефролога"})
aadd(arr,{"2.70.7" ,"Консультативный прием гематолога"})
aadd(arr,{"2.70.8" ,"Консультативный прием аллерголога-иммунолога"})
aadd(arr,{"2.70.11","Консультативный прием инфекциониста"})
aadd(arr,{"2.70.12","Консультативный прием травматолога-ортопеда"})
aadd(arr,{"2.70.13","Консультативный прием уролога"})
aadd(arr,{"2.70.14","Консультативный прием нейрохирурга"})
aadd(arr,{"2.70.16","Консультативный прием колопроктолога"})
aadd(arr,{"2.70.18","Консультативный прием онколога"})
aadd(arr,{"2.70.19","Консультативный прием акушера-гинеколога"})
aadd(arr,{"2.70.20","Консультативный прием отоларинголога"})
aadd(arr,{"2.70.21","Консультативный прием офтальмолога"})
aadd(arr,{"2.70.22","Консультативный прием невролога"})
aadd(arr,{"2.70.23","Консультативный прием дерматолога"})
aadd(arr,{"2.70.24","Консультативный прием сердечно-сосудистого хирурга"})
aadd(arr,{"2.70.27","Консультативный прием хирурга"})
aadd(arr,{"2.70.29","Консультативный прием сурдолога"})
aadd(arr,{"2.70.30","Консультативный прием онколога-маммолога"})
aadd(arr,{"2.70.31","Консультативный прием онколога-колопроктолога"})
aadd(arr,{"2.70.32","Консультативный прием торакального онколога"})
aadd(arr,{"2.70.33","Консультативный прием онколога-гинеколога"})
aadd(arr,{"2.70.34","Консультативный прием онколога-отоларинголога"})
aadd(arr,{"2.70.35","Консультативный прием онколога-уролога"})
aadd(arr,{"2.70.36","Консультативный прием онколога-стоматолога"})
aadd(arr,{"2.70.37","Консультативный прием онколога-гематолога"})
aadd(arr,{"2.70.38","Консультативный прием онколога-химиотерапевта"})
aadd(arr,{"2.70.39","Консультативный прием офтальмолога глаукомного кабинета"})
aadd(arr,{"2.81.1", "Консультация врача педиатра"})
aadd(arr,{"2.81.2", "Консультация врача кардиолога"})
aadd(arr,{"2.81.3", "Консультация врача инфекциониста"})
aadd(arr,{"2.81.4", "Консультация врача ревматолога"})
aadd(arr,{"2.81.5", "Консультация врача невролога"})
aadd(arr,{"2.81.6", "Консультация врача дерматолога"})
aadd(arr,{"2.81.7", "Консультация врача генетика"})
aadd(arr,{"2.81.8", "Консультация врача сурдолога"})
aadd(arr,{"2.81.9", "Консультация врача гастроэнтеролога"})
aadd(arr,{"2.81.10","Консультация врача пульмонолога"})
aadd(arr,{"2.81.11","Консультация врача эндокринолога"})
aadd(arr,{"2.81.12","Консультация врача нефролога"})
aadd(arr,{"2.81.13","Консультация врача гематолога"})
aadd(arr,{"2.81.14","Консультация врача аллерголога-иммунолога"})
aadd(arr,{"2.81.15","Консультация врача хирурга"})
aadd(arr,{"2.81.16","Консультация врача сердечно-сосудистого хирурга"})
aadd(arr,{"2.81.17","Консультация врача отоларинголога"})
aadd(arr,{"2.81.18","Консультация врача офтальмолога"})
aadd(arr,{"2.81.19","Консультация врача офтальмолога глаукомного кабинета"})
aadd(arr,{"2.81.20","Консультация врача травматолога-ортопеда"})
aadd(arr,{"2.81.21","Консультация врача уролога"})
aadd(arr,{"2.81.22","Консультация врача нейрохирурга"})
aadd(arr,{"2.81.23","Консультация врача акушера-гинеколога"})
aadd(arr,{"2.81.24","Консультация врача онколога"})
aadd(arr,{"2.81.25","Консультация врача онколога-маммолога"})
aadd(arr,{"2.81.26","Консультация врача онколога-колопроктолога"})
aadd(arr,{"2.81.27","Консультация врача торакального онколога"})
aadd(arr,{"2.81.28","Консультация врача онколога-гинеколога"})
aadd(arr,{"2.81.29","Консультация врача онколога-отоларинголога"})
aadd(arr,{"2.81.30","Консультация врача онколога-уролога"})
aadd(arr,{"2.81.31","Консультация врача онколога-стоматолога"})
aadd(arr,{"2.81.32","Консультация врача онколога-гематолога"})
aadd(arr,{"2.81.33","Консультация врача онколога-химиотерапевта"})
aadd(arr,{"2.81.34","Консультация врача челюстно-лицевого хирурга"})
aadd(arr,{"2.81.35","Консультация врача колопроктолога"})
aadd(arr,{"57.1.1" ,"Прием врача-стоматолога (зубного врача) первичный"})
aadd(arr,{"57.1.2" ,"Прием врача-стоматолога (зубного врача) повторный"})
aadd(arr,{"57.1.3" ,"Врачебный прием стоматологический консультативный"})
aadd(arr,{"57.1.4" ,"Врачебный прием ортодонта консультативный"})
aadd(arr,{"57.1.5" ,"Посещение стоматологом на дому"})
aadd(arr,{"57.1.32","Врачебный прием ортодонта первичный"})
aadd(arr,{"57.1.33","Врачебный прием ортодонта повторный"})
aadd(arr,{"57.1.36","Прием стоматолога-терапевта первичный"})
aadd(arr,{"57.1.37","Прием стоматолога-терапевта повторный"})
aadd(arr,{"57.1.38","Прием стоматолога-терапевта консультативный"})
aadd(arr,{"57.1.39","Прием стоматолога-хирурга первичный"})
aadd(arr,{"57.1.40","Прием стоматолога-хирурга повторный"})
aadd(arr,{"57.1.41","Прием стоматолога-хирурга консультативный"})
aadd(arr,{"57.1.42","Прием детского стоматолога первичный"})
aadd(arr,{"57.1.43","Прием детского стоматолога повторный"})
aadd(arr,{"57.1.44","Прием детского стоматолога консультативный"})
aadd(arr,{"57.1.45","Прием зубного врача первичный"})
aadd(arr,{"57.1.46","Прием зубного врача повторный"})
aadd(arr,{"57.1.47","Посещение стоматологом-терапевтом на дому"})
aadd(arr,{"57.1.48","Посещение детским стоматологом на дому"})
aadd(arr,{"57.1.49","Посещение стоматологом-хирургом на дому"})
aadd(arr,{"57.1.50","Посещение зубным врачом на дому"})
return arr

*


***** 16.07.17 заполнить таблицу Excel'а
Function fill_in_Excel_Book(inFile,outFile,fillArray,smsg)
Local buf := save_maxrow(), bSaveHandler, msgArray := {}
local oSheet, oBook, oExcel, is_open_or_create, iS, jC, a, v, s
keyboard ""
if !hb_FileExists(inFile)
  return func_error(4,"Не обнаружен файл шаблона "+inFile)
elseif valtype(smsg) == "C"
  aadd(msgArray,"Имеется возможность выгрузить информацию в файл/шаблон Excel,")
  aadd(msgArray,smsg+".")
  aadd(msgArray,"Файл "+upper(outFile)+" не должет быть открыт")
  aadd(msgArray,"(и, вообще, лучше закрыть программу Excel, если она открыта).")
  aadd(msgArray,"")
  aadd(msgArray,"Выберите действие:")
  if f_alert(msgArray,{" Отказ "," Выгрузка в файл Excel "},1,"GR+/R","W+/R",,,"GR+/R,N/BG") != 2
    return NIL
  endif
endif
stat_msg("Ждите! Производится запуск Excel")
if Start_Excel(@oExcel,@is_open_or_create)
  oExcel:Visible := .f.
  oExcel:DisplayAlerts:=.f.
  oBook := oExcel:WorkBooks:Open(inFile)
  FOR EACH oSheet IN oBook:WorkSheets
    stat_msg('Обрабатывается лист "'+oSheet:Name+'"')
    if (iS := ascan(fillArray, {|x| x[1] == oSheet:Name })) > 0
      a := fillArray[iS,2]
      for jC := 1 to len(a) // цикл по ячейкам конкретного листа
        s := ""
        if (v := valtype(a[jC,3])) == "N"
          s := lstr(a[jC,3])
        elseif v == "C"
          s := a[jC,3]
        elseif v == "D"
          s := full_date(a[jC,3])
        endif
//my_debug(,print_array({oSheet:Name,a[jC,1],a[jC,2],s}))
        oSheet:Cells(a[jC,1],a[jC,2]):Value := s
      next
    endif
  next
  bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
  BEGIN SEQUENCE
    if int(val(oExcel:get("Version"))) < 12
      oBook:SaveAs(outFile,43)  // xlExcel9795
    else
      oBook:SaveAs(outFile,56)  // xlExcel8
    endif
    if is_open_or_create == 2 // если Excel не был открыт, а мы его открыли
      oBook:close(.f.,,.f.)   // закрыть книгу
      oExcel:Quit()           // закрываем Excel
      oBook  := nil
      oSheet := nil
      oExcel := nil
      millisec(1000)  // pause
      WAPI_SHELLEXECUTE(0,"OPEN",outFile) // снова запускаем Excel
    else
      oBook:Activate()        // сделать книгу активной
      oExcel:Visible := .t.   // сделать Excel видимым
    endif
  RECOVER USING error
    oBook:close(.f.,,.f.)   // закрыть книгу
    oExcel:Quit()           // закрываем Excel
    oBook  := nil
    oSheet := nil
    oExcel := nil
    func_error(4,"Ошибка сохранения файла "+upper(outFile))
  END
  ERRORBLOCK(bSaveHandler)
else
  func_error(4,"Неудачная попытка запуска Excel")
endif
rest_box(buf)
return NIL

***** 10.11.13 запуск Excel'а
Function Start_Excel(/*@*/oExcel,/*@*/is_open_or_create)
Static sExcel := "Excel.Application"
Local ret := .f., bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
is_open_or_create := 0
BEGIN SEQUENCE
  oExcel := GetActiveObject(sExcel) // проверим, не открыт ли уже Excel
  oExcel:DisplayAlerts:=.f.
  is_open_or_create := 1
  ret := .t.
RECOVER USING error
  ret := .f.
  BEGIN SEQUENCE
    oExcel := CreateObject(sExcel)  // иначе открываем сами
    is_open_or_create := 2
    ret := .t.
  RECOVER USING error
    ret := .f.
  END
END
ERRORBLOCK(bSaveHandler)
Return ret

***** 12.07.17
Function func_f14_stom(s,ltip,lkol,is_2_88,is_rebenok,is_trudosp,is_inogoro,is_sred)
Local i, k, al := "TMP_STOM"
if select(al) == 0
  dbcreate(al,{{"name","C",27,0},;
               {"k2","N",6,0},;
               {"k3","N",6,0},;
               {"k4","N",13,2},;
               {"k5","N",6,0},;
               {"k6","N",6,0},;
               {"k7","N",13,2},;
               {"k8","N",6,0},;
               {"k9","N",6,0},;
               {"k10","N",13,2},;
               {"k11","N",6,0},;
               {"k12","N",6,0},;
               {"k13","N",13,2}})
  use (al) new
  append blank
  &al.->name := "Обращение с лечебной целью"
  append blank
  &al.->name := " в т.ч. к зубному врачу"
  append blank
  &al.->name := "Посещение с профилактической целью"
  append blank
  &al.->name := " в т.ч. к среднему медперсоналу"
  append blank
  &al.->name := "Разовое посещение по заболеванию"
  append blank
  &al.->name := " в т.ч. к среднему медперсоналу"
  append blank
  &al.->name := "Посещение при оказании неотложной помощи"
  append blank
  &al.->name := " в т.ч. к среднему медперсоналу"
  append blank
  &al.->name := "Прочие"
  append blank
  &al.->name := "Общий итог"
endif
au := {} ; k := 0
do case
  case ltip == 1 // по поводу заболевания
    k := 1
  case ltip == 2 // профилактика
    k := iif(is_2_88, 5, 3)
  case ltip == 3 // в неотложной форме
    k := 7
endcase
if k == 0
  aadd(au,9)
else
  aadd(au,k)
  if is_sred
    aadd(au,k+1)
  endif
endif
aadd(au,10)
dbSelectArea(al)
for i := 1 to len(au)
  goto (au[i])
  &al.->k2 ++
  &al.->k3 += lkol
  &al.->k4 += s
  if is_rebenok
    &al.->k5 ++
    &al.->k6 += lkol
    &al.->k7 += s
  endif
  if is_trudosp
    &al.->k8 ++
    &al.->k9 += lkol
    &al.->k10+= s
  endif
  if is_inogoro
    &al.->k11 ++
    &al.->k12 += lkol
    &al.->k13 += s
  endif
next
return NIL
