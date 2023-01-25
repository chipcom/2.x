***** различные функции для задачи ОМС - mo_omsf.prg
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// Static Shodata_sem := "Работа с ходатайствами"
// Static Shodata_err := "В данный момент с ходатайствами работает другой пользователь."

***** 08.09.18 очистить запись в строке файла "human_2"
Function put_0_human_2()
human_2->OSL1 := human_2->OSL2 := human_2->OSL3 := human_2->TAL_NUM := human_2->VIDVMP := ""
human_2->P_PER := human_2->PROFIL_K := human_2->VMP := human_2->METVMP := 0
human_2->NPR_DATE := human_2->TAL_D := human_2->TAL_P := ctod("")
human_2->VNR := human_2->VNR1 := human_2->VNR2 := human_2->VNR3 := 0
human_2->PC1 := human_2->PC2 := human_2->PC3 := human_2->PC4 := human_2->PC5 := human_2->PC6 := ""
human_2->PN1 := human_2->PN2 := human_2->PN3 := human_2->PN4 := human_2->PN5 := human_2->PN6 := 0
return NIL

***** 15.01.18 заполнить код подразделения/отделения
Function f_put_glob_podr(lusl,lkdate,_arr)
DEFAULT _arr TO {}
glob_podr := "" ; glob_otd_dep := 0
if lusl == 1 .and. lkdate >= d_01_08_2017
  if year(lkdate) > 2017
    if is_otd_dep
      glob_otd_dep := otd->CODE_DEP // код отделения по кодировке ТФОМС из справочника SprDep - 18 год
      if empty(glob_otd_dep)
        // базы отделения и учреждения открыты и стоят на нужной записи
        aadd(_arr,' не заполнен код отделения по кодировке ТФОМС для "'+alltrim(otd->name)+'/'+alltrim(uch->name)+'"')
      endif
    endif
  else // для второй половины 2017 года
    if is_adres_podr
      glob_podr := otd->CODE_TFOMS // код адресного подразделения
      if empty(glob_podr)
        // базы отделения и учреждения открыты и стоят на нужной записи
        aadd(_arr,' не заполнен адрес удалённого подразделения для "'+alltrim(otd->name)+'/'+alltrim(uch->name)+'"')
      endif
    endif
  endif
endif
return len(_arr) > 0

***** 06.02.22
Function f_oms_beremenn(sdiag)
  Static arr := {"O10","O11","O12","O13","O14","O15","O16",;
               "O20","O21","O22","O23","O24","O25","O26","O28",;
               "O30","O31","O32","O33","O36","O40","O41",;
               "O43","O44","O45","O46","O47","O98","O99",;
               "Z33","Z34","Z35","Z36"}
  Local k := 0, j, c, s
  local ad_criteria := getAdditionalCriteria(0d20190101)

  pr_ds_it := 0
  if (c := left(sdiag,1)) == "C"
    pr_ds_it := k := 3 // онкология
  elseif c == "O" .or. c == "Z"
    if (s := left(sdiag,3)) == "O04"
      k := 1 // аборт
    elseif ascan(arr,s) > 0
      k := 2 // беременность
    endif
  endif
  if pr_ds_it == 0 .and. alltrim(sdiag) == "R54"
    pr_ds_it := 4
  endif
  // if pr_ds_it == 0 .and. (j := ascan(arr_ad_cr_it19,{|x| x[1] == padr(sdiag,5) })) > 0
  if pr_ds_it == 0 .and. (j := ascan(ad_criteria, {|x| x[1] == padr(sdiag,5) })) > 0
    // pr_ds_it := arr_ad_cr_it19[j,2]
    pr_ds_it := ad_criteria[j,2]
  endif
  if eq_any(k,1,2) .and. type("m1USL_OK") == "N" .and. m1USL_OK == 4 // СМП
    k := 0
  endif
  return k

***** 02.01.18
Function f_valid_beremenn(sdiag)
Local k
if (ibrm := f_oms_beremenn(sdiag)) > 0
  SetPos(rdiag,26)
  mm_prer_b := iif(ibrm == 1, mm1prer_b, iif(ibrm == 2, mm2prer_b, mm3prer_b))
  if ibrm == 1
    DispOut("прерывание беременности",cDataCGet)
    if !between(m1prer_b,0,2)
      m1prer_b := 0
    endif
  elseif ibrm == 2
    DispOut("дисп.набл.за беременной",cDataCGet)
    if !between(m1prer_b,0,1)
      m1prer_b := 0
    endif
  elseif ibrm == 3
    DispOut("     боли при онкологии",cDataCGet)
    k := iif(year(mk_data) > 2018, 4, 1)
    if !between(m1prer_b,0,k)
      m1prer_b := 0
    endif
  endif
  if ibrm == 1 .and. m1prer_b == 0
    mprer_b := space(28)
  else
    mprer_b := inieditspr(A__MENUVERT, mm_prer_b, m1prer_b)
  endif
else
  m1prer_b := 0
  mprer_b := space(28)
endif
return update_get("mprer_b")

***** 11.09.14 составить усечённые массивы учреждений/отделений на конкретную дату
Function make_arr_uch_otd(mdate,mlpu)
Local a_uch := {}, not_lpu := !(valtype(mlpu)=="N"), tmp_select := select()
if empty(mdate)
  mdate := sys_date
endif
R_Use(dir_server+"mo_uch",,"UCH")
R_Use(dir_server+"mo_otd",,"OTD")
if yes_many_uch .or. not_lpu
  select UCH
  dbeval({|| iif(between_date(uch->dbegin,uch->dend,mdate), aadd(a_uch,uch->(recno())), nil) })
else
  aadd(a_uch,mLPU)
endif
select OTD
dbeval({|| iif(between_date(otd->dbegin,otd->dend,mdate), aadd(pr_arr,{otd->(recno()),otd->name,otd->kod_lpu,""}), nil),;
           iif(mem_otdusl == 2, aadd(pr1arr_otd,{otd->(recno()),otd->name,otd->kod_lpu,""}), nil);
       },;
       {|| iif(yes_many_uch .or. not_lpu, ascan(a_uch,otd->kod_lpu) > 0, otd->kod_lpu == mLPU) };
      )
if empty(a_uch)
  func_error(4,"На дату "+full_date(mdate)+" нет настроенных учреждений")
endif
if empty(pr_arr)
  func_error(4,"На дату "+full_date(mdate)+" нет настроенных отделений")
endif
if (yes_many_uch .or. not_lpu) .and. len(a_uch) > 1
  select UCH
  aeval(pr_arr, {|x,i| dbGoto(x[3]), pr_arr[i,4] := uch->short_name } )
  aeval(pr1arr_otd, {|x,i| dbGoto(x[3]), pr1arr_otd[i,4] := uch->short_name } )
  //
  asort(pr_arr,,,{|x,y| iif(x[3] == y[3], upper(x[2]) < upper(y[2]), ;
                                          upper(x[4]) < upper(y[4])) } )
  aeval(pr_arr, {|x| aadd(pr_arr_otd,x[4]+" ▒ "+x[2]) } )
else
  asort(pr_arr,,,{|x,y| upper(x[2]) < upper(y[2]) } )
  aeval(pr_arr, {|x| aadd(pr_arr_otd,x[2]) } )
endif
if not_lpu
  uch->(dbCloseArea())
  otd->(dbCloseArea())
  select (tmp_select)
endif
return NIL

***** 23.12.12 является ли услуга приёмом на дому
Function priem_na_domu(lshifr)
Static arr := {"2.56.1","2.56.2","2.56.3","2.56.4","2.56.5","2.56.6",;
               "2.56.7","2.56.8","2.56.9","2.56.10","2.56.11","2.56.12",;
               "2.56.13","2.56.14","2.72.3"}
Local i, fl := .f.
lshifr := alltrim(lshifr)
for i := 1 to len(arr)
  if lshifr == arr[i]
    fl := .t. ; exit
  endif
next
return fl

***** 31.01.13 является ли услуга профилактическим приёмом
Function priem_profilak(lshifr)
lshifr := alltrim(lshifr)
return left(lshifr,5)=="2.79." .or. eq_any(lshifr,"2.9.3","2.32.3","2.1.4")

***** 24.07.13 является ли услуга приёмом врача общей практики
Function UslugaObshPraktika(lshifr,lprofil)
Static arr := {"2.72.1","2.72.3","2.79.2","2.80.2","2.83.15","2.85.15","2.86.15","2.87.15"}
Static arrp := {"2.84.2","2.84.7"}
Local i, fl := .f.
DEFAULT lprofil TO 0
lshifr := alltrim(lshifr)
for i := 1 to len(arr)
  if lshifr == arr[i]
    fl := .t. ; exit
  endif
next
if !fl .and. lprofil == 57
  for i := 1 to len(arrp)
    if lshifr == arrp[i]
      fl := .t. ; exit
    endif
  next
endif
return fl

***** 09.06.19 проверить, нулевая ли цена услуги в ТФОМС
Function NulUslugaTFOMS(lshifr1)
lshifr1 := alltrim(lshifr1)
return eq_any(left(lshifr1,2),"3.","4.","7.") .or. ;
       eq_any(left(lshifr1,5),"1.11.","1.19.","2.60.","55.1.","71.1.") .or. ;
       eq_any(left(lshifr1,4),"2.3.","2.4.","2.5.","2.6.") .or. ;
       eq_any(left(lshifr1,3),"13.","14.","19.","20.","21.","22.") .or. ;
       between_shifr(lshifr1,"2.78.47","2.78.53") .or. between_shifr(lshifr1,"2.79.52","2.79.58") .or. ;
       between_shifr(lshifr1,"2.80.29","2.80.33") .or. between_shifr(lshifr1,"2.88.40","2.88.45")

***** 27.01.14 проверить, возможен ли ввод признака "на дому" для услуги ТФОМС
Function DomUslugaTFOMS(lshifr1)
return eq_any(left(lshifr1,5),"2.60.","2.79.","2.80.","2.88.") .or. left(lshifr1,4) == "2.3."

***** 16.01.20 является услуга для среднего медперсонала?
Function UslugaFeldsher(lshifr)
Static arr := {"2.57.1","71.1.1","71.2.1","2.3.3","2.3.4","2.60.3","2.60.4",;
               "2.78.28","2.78.29","2.78.36","2.78.39","2.78.40",;
               "2.79.19","2.79.20","2.79.34","2.79.37","2.79.38",;
               "2.79.49","2.79.50",;
               "2.80.12","2.80.13","2.80.19","2.80.22","2.80.23","2.80.27",;
               "2.80.50","2.80.53","2.80.54",;
               "2.88.35","2.88.36","2.88.37",;
               "57.1.46","57.1.60","57.1.70","57.1.71","57.1.80","57.1.81"}
return ascan(arr,alltrim(lshifr)) > 0 .or. ;
       eq_any(left(lshifr,2),"3.","4.","7.") .or. ;
       eq_any(left(lshifr,3),"13.","14.","19.","20.","21.","22.")

***** 14.01.13 относится ли случай к скорой помощи
Function is_smp(_USL_OK,_PROFIL)
return _USL_OK == 4 .or. _PROFIL == 84

***** вернуть наименование иногородней СМО
Function init_ismo(lsmo)
Local s := space(10), tmp_select
if !empty(lsmo)
  tmp_select := select()
  R_Use(dir_exe+"_mo_smo",cur_dir + "_mo_smo2","SMO")
  find (padr(lsmo,5))
  if found()
    s := rtrim(smo->name)
  endif
  use
  select (tmp_select)
endif
return s

***** по дате окончания лечения вернуть массив групп нозологий по модернизации
Function ret_arr_stand(mdate)
Local i, arr := {}
for i := 1 to len(g_arr_stand)
  if mdate >= g_arr_stand[i,1]
    arr := g_arr_stand[i,2]
  endif
next
return arr

***** проверить по листу учета, законченный случай или нет, вернуть шифр услуги
Function ret_zak_sl(/*@*/susl,/*@*/doplataF,/*@*/doplataR,/*@*/lotd,/*@*/lvrach,__date)
Static sa_usl
Local len_stand, _arr_stand, lshifr, tmp_select := select(), i, j, k, s, ret := 0
susl := "" ; doplataF := doplataR := lotd := lvrach := 0
if select("HU") == 0
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"human_u",dir_server+"human_u","HU")
  set relation to u_kod into USL
endif
select HU
find (str(human->kod,7))
do while hu->kod == human->kod .and. !eof()
  if !(hu->u_kod == usl->kod) // если нет связи по relation
    usl->(dbGoto(hu->u_kod))  // то перемещаемся принудительно
  endif
  s := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
  if is_usluga_TFOMS(usl->shifr,s,human->k_data)
    lshifr := iif(empty(s), usl->shifr, s)
    // в листе учета д.б. одна услуга по ОМС = законченный случай
    if left(lshifr,4) == "1.7." // чтобы не проверять лишнее
      //len_stand := len(_arr_stand := ret_arr_stand(human->k_data))
      //if !empty(len_stand)
        //DEFAULT sa_usl TO Uslugi_MKB_Standart() // закачаем массив ноз.форм (услуг по ним)
        susl := alltrim(lshifr)
        //for i := 1 to len_stand
          //j := _arr_stand[i] // код от 1 до 11 (ноз.форм)
          //if (k := ascan(sa_usl[j],susl)) > 0 // эта услуга входит в стандарт
            lotd := hu->otd ; lvrach := hu->kod_vr
            // то ищем сумму доплат
            if select("LUSLD") == 0
              use_base("lusld")
            endif
            select LUSLD
            find (lshifr)
            do while lshifr == lusld->shifr .and. !eof()
              // поиск цены по дате окончания лечения
              if between_date(lusld->datebeg,lusld->dateend,iif(__date==NIL,human->k_data,__date))
                doplataF := lusld->dopl_F // по ссылке вернем сумму фед.доплаты
                doplataR := lusld->dopl_R // по ссылке вернем сумму рег.доплаты
                exit
              endif
              skip
            enddo
            ret := 1 //; exit
          //endif
        //next
        exit // в листе учета д.б. одна услуга по ОМС
      //endif
    elseif left(lshifr,5) == "70.1." // чтобы не проверять лишнее
      ret := 2 ; exit
    endif
  endif
  select HU
  skip
enddo
select (tmp_select)
return ret

** вернуть первые два диагоноза для записи в XML-файл
Function diag_for_xml(al, fl_trim, fl_dop, fl_del, fl_6, adiag_talon)
  Local mdiagnoz := diag_to_array(al, fl_trim, fl_dop, fl_del, fl_6, adiag_talon)

  aadd(mdiagnoz, '') // чтобы был безусловно первый элемент
  aadd(mdiagnoz, '') // чтобы был безусловно второй элемент
  if empty(mdiagnoz[1]) // если пустой основной диагноз, заполним его
    mdiagnoz[1] := 'Z01.8' // Другое уточнённое специальное обследование
  endif
  return mdiagnoz

** 31.10.22 вернуть диагнозы в массиве
Function diag_to_array(al, fl_trim, fl_dop, fl_del, fl_6, adiag_talon)
  Local ad, _arr := {}, j, k, s, lshifr, dp, dp1, _ta, tmp_select := select()

  DEFAULT al      TO 'human', ; // alias БД листов учета
          fl_trim TO .f., ;     // удалять завершающие пробелы
          fl_dop  TO .f., ;     // дописывать букву
          fl_del  TO .t., ;     // удалять повторяющиеся диагнозы
          fl_6    TO .f.        // разрешать поиск шестизначных диагнозов
  if empty(al)
    ad := {MKOD_DIAG , ;
           MKOD_DIAG2, ;
           MKOD_DIAG3, ;
           MKOD_DIAG4, ;
          MSOPUT_B1, ;
          MSOPUT_B2, ;
          MSOPUT_B3, ;
          MSOPUT_B4}
  else
    ad := {&al.->KOD_DIAG , ;
           &al.->KOD_DIAG2, ;
           &al.->KOD_DIAG3, ;
           &al.->KOD_DIAG4, ;
          &al.->SOPUT_B1, ;
          &al.->SOPUT_B2, ;
          &al.->SOPUT_B3, ;
          &al.->SOPUT_B4}
  endif
  if fl_6
    if select('MKB_10') == 0
      R_Use(dir_exe + '_mo_mkb', cur_dir + '_mo_mkb', 'MKB_10')
    endif
    select MKB_10
  endif
  for j := 1 to 8
    if iif(fl_del, !empty(ad[j]), .t.)
      lshifr := ad[j]
      dp := dp1 := ''
      if fl_trim
        lshifr := alltrim(lshifr)
      endif
      if adiag_talon != NIL
        s := adiag_talon[j * 2 - 1]
        if eq_any(s, 1, 2)
          dp := iif(s == 1, '+', '-')
        endif
        s := adiag_talon[j * 2]
        if s > 0
          dp += 'д' + lstr(s)
        endif
      endif
      if !empty(al)
        k := substr(&al.->diag_plus, j, 1)
        if fl_6 .and. !empty(k)
          find (ad[j] + k)
          if found() // если нашли шестизначный шифр
            lshifr := ad[j] + k
          endif
        endif
        if fl_dop .and. !empty(k) .and. k $ yes_d_plus
          dp1 := k
        endif
      endif
      aadd(_arr, {lshifr, dp + dp1})
    endif
  next
  _ta := {}
  if fl_del // удалим из списка повторяющиеся диагнозы
    for j := 1 to len(_arr)
      if ascan(_ta, {|x| x == _arr[j, 1] } ) == 0
        aadd(_ta, _arr[j, 1] )
      endif
    next
    for j := 1 to len(_ta)
      s := ''
      for k := 1 to len(_arr)
        if _arr[k, 1] == _ta[j]
          s += _arr[k, 2]
        endif
      next
      _ta[j] += s
    next
  else
    for j := 1 to len(_arr)
      aadd(_ta, _arr[j, 1] + _arr[j, 2])
    next
  endif
  if tmp_select > 0
    select (tmp_select)
  endif
  return _ta

***** 26.01.17
Function add_val_2_array(arr,i,j,k1,k2)
// arr - двумерный массив
// i   - элемент (первое измерение), в который добавляем
// j   - элемент (первое измерение), который добавляем
// k1  - с какого элемента (второе измерение) идёт суммирование
// k2  - последний элемент (второе измерение), который суммируется
Local k
for k := k1 to k2
  arr[i,k] += arr[j,k]
next
return NIL

***** проверка на соответствие законченного случая диагнозу
Function ZakSluchAccordanceDiagnoz(lshifr,mdiagnoz,ta)
Local i, fl := {.f.,.f.}
if select("UZK") == 0
  R_Use(dir_exe+"_mo_uslz",cur_dir + "_mo_uslz","UZK")
  //index on shifr+str(type_diag,1)+kod_diag to (sbase)
endif
lshifr := padr(lshifr,10)
select UZK
find (lshifr)
if found()
  for i := 1 to min(2,len(mdiagnoz))
    mdiagnoz[i] := padr(mdiagnoz[i],6)
    fl[i] := .t.
  next
  for i := 1 to 2
    find (lshifr+str(i,1))
    if found()
      if fl[i]
        find (lshifr+str(i,1)+mdiagnoz[i])
        if !found()
          aadd(ta,rtrim(lshifr)+' для законченного случая не соответствует '+iif(i==1,'основной','сопутствующий')+' диагноз')
        endif
      else
        aadd(ta,rtrim(lshifr)+' для законченного случая не введён '+iif(i==1,'основной','сопутствующий')+' диагноз')
      endif
    endif
  next
endif
return NIL

***** проверка, умер ли пациент
Function is_death(_rslt)
return eq_any(_rslt,105,106,205,206,313,405,406,411) // по результату лечения

***** врачебных приемов не должно быть более одного в один день
Function vr_pr_1_den(par,/*@*/msg,in_arr)
Local tmp_select := select(), lshifr, i, j, k, fl, s, arr_usl := {},;
      ad := {}, _arr := {}, lpshifr := "", arr_pusl := {}
DEFAULT in_arr TO {}
msg := ""
select HU
find (str(human->kod,7))
do while hu->kod == human->kod .and. !eof()
  if hu->(recno()) != hu_->(recno())  // если не связаны по RELATION
    hu_->( dbGoto(hu->(recno())) )
  endif
  aadd(_arr, {hu->u_kod,hu->date_u,hu->kol_1,hu_->profil,0})
  if ascan(ad,hu->date_u) == 0
    aadd(ad,hu->date_u)
  endif
  skip
enddo
select MOHU
find (str(human->kod,7))
do while mohu->kod == human->kod .and. !eof()
  aadd(_arr, {mohu->u_kod,mohu->date_u,mohu->kol_1,mohu->profil,1})
  if ascan(ad,mohu->date_u) == 0
    aadd(ad,mohu->date_u)
  endif
  skip
enddo
// проходим услуги по текущему листу учёта
for k := 1 to len(_arr)
  if !empty(lshifr := st_pr_1_den(_arr[k],@lpshifr))
    if (i := ascan(arr_usl,{|x| x[1] == lshifr .and. x[2] == _arr[k,2]})) == 0
      aadd(arr_usl,{lshifr,_arr[k,2],0,0}) ; i := len(arr_usl)
    endif
    arr_usl[i,3] += _arr[k,3]
    arr_usl[i,4] += _arr[k,3]
  elseif !empty(lpshifr)
    if (i := ascan(arr_pusl,{|x| x[1]==lpshifr .and. x[2]==_arr[k,2] .and. x[5]==_arr[k,4]})) == 0
      aadd(arr_pusl,{lpshifr,_arr[k,2],0,0,_arr[k,4]}) ; i := len(arr_pusl)
    endif
    arr_pusl[i,3] += _arr[k,3]
    arr_pusl[i,4] += _arr[k,3]
  endif
next
// теперь проходим услуги из других листов учёта
for k := 1 to len(in_arr)
  if !empty(lshifr := st_pr_1_den(in_arr[k],@lpshifr))
    if (i := ascan(arr_usl,{|x| x[1] == lshifr .and. x[2] == in_arr[k,2]})) > 0
      arr_usl[i,4] += in_arr[k,3]
    endif
  elseif !empty(lpshifr)
    if (i := ascan(arr_pusl,{|x| x[1]==lpshifr .and. x[2]==in_arr[k,2] .and. x[5]==in_arr[k,4]})) > 0
      arr_pusl[i,4] += in_arr[k,3]
    endif
  endif
next
for i := 1 to len(arr_usl)
  s := 'Услуга "'+arr_usl[i,1]+'" '+date_8(c4tod(arr_usl[i,2]))+'г. оказана '
  if arr_usl[i,3] > 1
    msg := s+lstr(arr_usl[i,3])+' раз'+iif(arr_usl[i,3] < 5, 'а', '')
  elseif arr_usl[i,4] > 1
    msg := s+lstr(arr_usl[i,4])+' раз'+iif(arr_usl[i,4] < 5, 'а', '')+;
           " (в другом случае)"
  endif
next
for i := 1 to len(arr_pusl)
  s := arr_pusl[i, 1] + ' (' + inieditspr(A__MENUVERT, getV002(), arr_pusl[i, 5]) + ;
       ') ' + date_8(c4tod(arr_pusl[i, 2])) + 'г. оказана '
  if arr_pusl[i,3] > 1
    msg := s+lstr(arr_pusl[i,3])+' раз'+iif(arr_pusl[i,3] < 5, 'а', '')
  elseif arr_pusl[i,4] > 1
    msg := s+lstr(arr_pusl[i,4])+' раз'+iif(arr_pusl[i,4] < 5, 'а', '')+;
           " (в другом случае)"
  endif
next
select (tmp_select)
fl := .t.
if !empty(msg)
  if par == 1  // для GET-системы
    func_error(4,msg)
  else  // для проверки ТФОМС
    fl := .f.
  endif
endif
return fl

***** 18.02.14
Static Function st_pr_1_den(_u_a,/*@*/pshifr)
Static a_usl := {"2.*","57.1.1","57.1.4","57.1.5","57.6.1","60.2.*",;
                 "57.1.36","57.1.39","57.1.42","57.1.45",;
                 "57.1.47","57.1.48","57.1.49","57.1.50"}
Static a_no_usl := {"2.34.1","2.34.3","2.56.1","2.3.1","2.3.2","2.3.3",;
                    "2.6.1","2.6.2",;
                    "2.60.1","2.60.2","2.60.3","2.60.4","2.60.5"}
Local fl := .f., lshifr, j
pshifr := ""
if _u_a[5] == 0
  usl->(dbGoto(_u_a[1]))
  if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
    lshifr := usl->shifr
  endif
  lshifr := alltrim(lshifr)
else
  mosu->(dbGoto(_u_a[1]))
  lshifr := alltrim(mosu->shifr1)
endif
for j := 1 to len(a_usl)
  if "*" $ a_usl[j]
    fl := like(a_usl[j],lshifr)
  else
    fl := (a_usl[j] == lshifr)
  endif
  if fl .and. (ascan(a_no_usl,lshifr) > 0 .or. eq_any(left(lshifr,5),"2.80.","2.82."))
    fl := .f. ; pshifr := lshifr
  endif
  if fl ; exit ; endif
next
return iif(fl, lshifr, "")

***** определить сроки лечения
Function f_srok_lech(beg_data,end_data,_usl_ok)
Local s, k
DEFAULT _usl_ok TO 0
s := "Срок лечения с "+full_date(beg_data)+;
              "г. по "+full_date(end_data)+"г."
if !emptyany(beg_data,end_data)
  k := end_data - beg_data + 1
  if _usl_ok == 1  // для стационара
    k -= 1         // день поступления и день выписки = один день
  endif
  s += " ["+lstr(k)+"дн.]"
endif
return s

***** 02.02.20
Function f_arr_usl1()
Local i, s, arr := {}, arr1 := {"2.76.5","2.76.7"}
if hb_fileExists(dir_server+"usl1year"+smem)
  arr := rest_arr(dir_server+"usl1year"+smem)
  for i := 1 to len(arr)
    select USL
    goto (arr[i])
    // заменить шифр услуги на услугу по кодировке ТФОМС
    if empty(s := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
      s := usl->shifr
    endif
    s := alltrim(s)
    if ascan(arr1,s) == 0
      aadd(arr1,s)
    endif
  next
endif
return arr1

***** 18.08.18
Function verify_uva(reg)
Local i
DEFAULT reg TO 1
if type("arr_uva") == "A" .and. len(arr_uva) > 0 ;
                          .and. (i := ascan(arr_uva, {|x| like(x[1],alltrim(mshifr)) } )) > 0
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
endif
return NIL

***** вернуть табельный номер по коду врача
Function ret_tabn(lkod_vr)
Local ltab_nom := 0
if lkod_vr > 0 .and. select("PERSO") > 0
  perso->(dbGoto(lkod_vr))
  if perso->kod == lkod_vr // если стоим на нужной записи
    ltab_nom := perso->tab_nom
  endif
endif
return ltab_nom

***** 10.04.18 подсчитать и записать сумму случая в режиме ввода услуг в случай ОМС
Function summa_usl(fl_edit)
Local j := 0, s := 0, ldate_next := ctod("")
DEFAULT fl_edit TO .t.
if tmp->(lastrec()) > 0
  select TMP
  go top
  do while !eof()
    if f_paraklinika(tmp->shifr_u,tmp->shifr1,human->k_data)
      s += tmp->stoim_1
    endif
    if !empty(tmp->DATE_NEXT)
      ldate_next := tmp->DATE_NEXT
      fl_edit := .t.
    endif
    tmp->number := ++j
    skip
  enddo
endif
s := round(s,2)
if !(round(human->cena,2) == s .and. round(human->cena_1,2) == s) .or. fl_edit
  select HUMAN
  G_RLock(forever)
  human->cena := human->cena_1 := s
  human->DATE_OPL := dtoc4(ldate_next)
  //
  human_->(G_RLock(forever))
  human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
  human_->ST_VERIFY := 0 // снова ещё не проверен
  if type("fl_edit_usl")=="L" .and. fl_edit_usl // только при редактированиии
    human_->kod_p2  := kod_polzovat    // код оператора
    human_->date_e2 := c4sys_date
  endif
  UNLOCK
  COMMIT
endif
return NIL

***** надо ли учитывать сумму данной услуги в сумме случая
Function f_paraklinika(lshifr,lshifr1,ldate_usl)
Local tmp_select, fl := is_usluga_TFOMS(lshifr,lshifr1,ldate_usl)
if !fl .and. empty(val(human_->smo)) // если не ОМС
  if eq_any(human->komu,1,3) .and. human->str_crb > 0 // прочие компании/комитеты (МО)
    tmp_select := select()
    R_Use(dir_server+iif(human->komu==1,"str_komp","komitet"),,"_SK")
    goto (human->str_crb)
    fl := (_sk->parakl == 1)
    _sk->(dbCloseArea())
    select (tmp_select)
  elseif human->komu == 5 // личный счёт
    fl := (mem_ls_parakl == 1)
  endif
endif
return fl

***** 05.01.20 является ли данная услуга услугой ТФОМС
Function is_usluga_TFOMS__(lshifr,lshifr1,ldate_usl,;
                         /*@*/arr_uet,/*@*/lbukva,/*@*/lst,/*@*/lidsp,/*@*/lvidpoms)
Local _shifr, tmp_select := select(), fl := .f., y := 2020, lal := "lusl"
y := year(ldate_usl)
if select("LUSL") == 0
  use_base("lusl")
endif
// if y < 2019
//   lal += "18"
// elseif y < 2020
//   lal += "19"
// endif
lal := create_name_alias(lal, y)

lst := 0 ; lvidpoms := "" ; lbukva := " "
_shifr := iif(empty(lshifr1), lshifr, lshifr1)
dbSelectArea(lal)
find (padr(_shifr,10))
if found() //.and. between_date(lusl->datebeg,lusl->dateend,ldate_usl)
  fl := .t.
  lbukva := alltrim(&lal.->bukva)
  if len(lbukva) != 1 // для 18 года
    lbukva := " "
  endif
  lst := &lal.->st
  lidsp := int(val(&lal.->idsp))
  if &lal.->(fieldpos("idsps")) > 0 .and. "," $ &lal.->idsps
    lidsp := 0
  endif
  arr_uet := {&lal.->uetv,&lal.->uetd}
  lvidpoms := alltrim(&lal.->vmp_s)
endif
if !fl
  if select("LUSLF") == 0
    use_base("luslf")
  endif
  lal := "luslf"
  // if y < 2019
  //   lal += "18"
  // elseif y < 2020
  //   lal += "19"
  // endif
  lal := create_name_alias(lal, y)

  dbSelectArea(lal)
  find (padr(_shifr,20))
  if found() //.and. between_date(luslf->datebeg,luslf->dateend,ldate_usl)
    fl := .t.
    lbukva := " "
    arr_uet := {&lal.->uetv,&lal.->uetd}
  endif
endif
select (tmp_select)
return fl // подтверждение, что услуга - ОМС

** 15.11.22 является ли данная услуга услугой ТФОМС
Function is_usluga_TFOMS(lshifr, lshifr1, ldate_usl, ;
  /*@*/arr_uet, /*@*/lbukva, /*@*/lst, /*@*/lidsp, /*@*/lvidpoms)
  Local _shifr, tmp_select := select(), fl := .f.
  local lal := 'lusl', y := WORK_YEAR

  y := year(ldate_usl)
  if select('LUSL') == 0
    use_base('lusl')
  endif

  lal := create_name_alias(lal, y)

  lst := 0
  lvidpoms := ''
  lbukva := ' '
  _shifr := iif(empty(lshifr1), lshifr, lshifr1)
  dbSelectArea(lal)
  find (padr(_shifr, 10))
  if found() //.and. between_date(lusl->datebeg,lusl->dateend,ldate_usl)
    fl := .t.
    lbukva := alltrim(&lal.->bukva)
    if len(lbukva) != 1 // для 18 года
      lbukva := ' '
    endif
    lst := &lal.->st
    lidsp := int(val(&lal.->idsp))
    if &lal.->(fieldpos('idsps')) > 0 .and. ',' $ &lal.->idsps
      lidsp := 0
    endif
    arr_uet := {&lal.->uetv, &lal.->uetd}
    lvidpoms := alltrim(&lal.->vmp_s)
  endif
  if !fl
    if select('LUSLF') == 0
      use_base('luslf')
    endif
    lal := 'luslf'
    lal := create_name_alias(lal, y)
  
    dbSelectArea(lal)
    find (padr(_shifr, 20))
    if found() //.and. between_date(luslf->datebeg,luslf->dateend,ldate_usl)
      fl := .t.
      lbukva := ' '
      arr_uet := {&lal.->uetv, &lal.->uetd}
    endif
  endif
  select (tmp_select)
  return fl // подтверждение, что услуга - ОМС

***** 15.01.19
Function ret_tfoms_uet(lshifr,lshifr1,lvzros_reb)
Local _shifr, tmp_select, luet := 0
/*_shifr := iif(empty(lshifr1), lshifr, lshifr1)
if left(_shifr,3) == "57."
  tmp_select := select()
  if select("LUSL") == 0
    use_base("lusl")
  endif
  select LUSL18
  find (padr(_shifr,10))
  if found()
    luet := iif(lvzros_reb==0,lusl18->uetv,lusl18->uetd)
  endif
  select (tmp_select)
endif*/
return luet

***** 02.11.20 проверка на код лабораторной услуги, направляемой в ЦКДЛ
Function is_lab_usluga(lshifr)
Static sl := "4."
Static arr := {"8.5","11.5","12.5","12.6","13.5","15.5","16.5","17.5"}
Local fl := .f.
if left(lshifr,2) == sl
  lshifr := alltrim(lshifr)
  for i := 1 to len(arr)
    if like(sl+arr[i]+"??",lshifr)
      fl := .t. ; exit
    endif
  next
endif
return fl

***** 10.09.18
Function ret_kod_usl_lek_ter(lVZROS_REB)
Static skodv := 0, skodr := 0
Local s, lkod
lkod := iif(lVZROS_REB == 0, skodv, skodr)
if lkod == 0
  s := iif(lVZROS_REB == 0, "A25.30.033", "A25.30.014")
  use_base("mo_su","MOSU1")
  set order to 3
  find (padr(s,20))
  if found()
    lkod := mosu1->kod
  else
    set order to 1
    FIND (STR(-1,6))
    if found()
      G_RLock(forever)
    else
      AddRec(6)
    endif
    lkod := mosu1->kod := recno()
    mosu1->name := "Назначение лекарственных препаратов при онкологическом заболевании у "+;
                   iif(lVZROS_REB == 0, "взрослых", "детей")
    mosu1->shifr1 := s
  endif
  mosu1->(dbCloseArea())
  if lVZROS_REB == 0
    skodv := lkod
  else
    skodr := lkod
  endif
endif
return lkod

** 13.11.22 функция определения массива в ф-ии редактирования листа учёта
Function f_define_tnm(n, ldiag)
  Local ar, sn := lstr(n), sd := padr(ldiag, 5)

  Local lal := 'n' + sn, polek, poled, polei, s := {'', 'ST', 'T', 'N', 'M'}[n]
  polek := lal + '->kod_' + s
  poled := lal + '->ds_' + s
  polei := lal + '->id_' + s
  if select(lal) == 0
    R_Use(exe_dir + '_mo_N00' + sn, {cur_dir + '_mo_N00' + sn, cur_dir + '_mo_N00' + sn + 'd'}, lal)
  endif
  dbSelectArea(lal) // встать на справочник N0...
  set order to 2
  find (sd)
  if found()
    ar := f1_define_tnm(sd, 5, polek, poled, polei)
  else
    sd := padr(ldiag, 3)
    find (sd)
    if found() .and. sd == alltrim(&poled)
      ar := f1_define_tnm(sd, 3, polek, poled, polei)
    else
      find (space(5))
      ar := f1_define_tnm(space(5), 5, polek, poled, polei)
    endif
  endif
  return ar

** 13.11.22
Function f1_define_tnm(s, n, polek, poled, polei)
  Local arr := {}

  do while left(&poled, n) == s .and. !eof()
    if empty(s) .or. alltrim(&poled) == alltrim(s)
      aadd(arr, {&polek, &polei})
    endif
    skip
  enddo
  return arr

***** 22.10.19 проверка правильности соответствующей стадии по соответствующему справочнику
Function f_verify_tnm(n,lkod,ldiag,ar)
Local sn := lstr(n), sd
Local fl := .t., lal := "n"+sn, polek, poled, s := {"","ST","T","N","M"}[n]
Local smsg := "онкология: в справочнике N00"+sn+" не найдена стадия заболевания "+s+"="+lstr(lkod)+" для диагноза "+ldiag
polek := lal+"->kod_"+s
poled := lal+"->ds_"+s
if select(lal) == 0
  R_Use(exe_dir + "_mo_N00"+sn,{cur_dir + "_mo_N00"+sn,cur_dir + "_mo_N00"+sn+"d"},lal)
endif
dbSelectArea(lal) // встать на справочник N0...
set order to 1    // переключиться на индекс по коду
find (str(lkod,6))
if found()
  if empty(&poled) // если не заполнено поле диагноза
    sd := padr(ldiag,5)
    set order to 2 // переключиться на индекс по диагнозу
    find (sd)      // поиск пятизначного диагноза
    if found()     // если нашли - ошибка
      fl := .f. ; aadd(ar,smsg)
    else
      sd := padr(ldiag,3)
      find (sd)    // поиск трёхзначного диагноза
      if found() .and. sd == alltrim(&poled)  // если нашли - ошибка
        fl := .f. ; aadd(ar,smsg)
      endif
    endif
  elseif len(alltrim(&poled)) == 5
    if !(left(ldiag,5) == &poled)
      fl := .f. ; aadd(ar,smsg)
    endif
  else
    if !(left(ldiag,3) == alltrim(&poled))
      fl := .f. ; aadd(ar,smsg)
    endif
  endif
else
  fl := .f. ; aadd(ar,smsg)
endif
return fl

***** 14.01.19 проверка правильности введённых стадий по справочнику N006 в get'e
Function f_valid_tnm(g)
Local buf, fl_found, s := padr(mkod_diag,5)
/*if !emptyany(m1ONK_T,m1ONK_N,m1ONK_M)
  select N6
  find (s)
  if !(fl_found := found())
    s := padr(mkod_diag,3)
    find (s)
    fl_found := (found() .and. s == alltrim(n6->ds_gr))
  endif
  if fl_found
    find (padr(s,5)+str(m1ONK_T,6)+str(m1ONK_N,6)+str(m1ONK_M,6))
    if found()
      if m1stad != n6->id_st
        m1stad := n6->id_st
        mSTAD  := padr(inieditspr(A__MENUVERT, mm_N002, m1STAD),5)
        buf := save_maxrow()
        stat_msg('Справочник N006: по сочетанию стадий TNM исправлено поле "Стадия"') ; mybell(1,OK)
        rest_box(buf)
        update_get("mstad")
      endif
    else
      func_error(2,"Справочник N006: некорректное сочетание стадий TNM")
    endif
  endif
endif*/
return .t.

***** 03.04.20
Function get_rez_gist(k,r,c)
Local r1, r2, c1, c2, i, kg := len(arr_rez_gist), sk, buf, ret[2]
r2 := r-1
if (r1 := r2-kg-1) < 0
  r1 := 0
  r2 := r1+kg+1
endif
c1 := 10
c2 := 77
setcolor(color5)
buf := box_shadow(r1,c1,r2,c2,,"Ввод результатов гистологии","G/W")
@ r2,c1+7 say " <Esc> отказ,  <PgDn> запись,  <Пробел> очистить поле " color "R/W"
Private pole_rslt, pole_1rslt, pole_menu
for i := 1 to kg
  sk := lstr(i)
  pole_rslt := "mrslt"+sk
  pole_1rslt := "m1rslt"+sk
  pole_menu := "mm_rslt"+sk
  Private &pole_1rslt := arr_rez_gist[i,4]
  Private &pole_rslt := inieditspr(A__MENUVERT, arr_rez_gist[i,3], arr_rez_gist[i,4])
  Private &pole_menu := arr_rez_gist[i,3]
next
for i := 1 to kg
  sk := lstr(i)
  pole_rslt := "mrslt"+sk
  pole_1rslt := "m1rslt"+sk
  pole_menu := "mm_rslt"+sk
  @ r1+i,c1+2 say padr(arr_rez_gist[i,1],37) get &pole_rslt ;
              reader {|x|menu_reader(x,&pole_menu,A__MENUVERT_SPACE,,,.f.)}
next
myread()
if lastkey() != K_ESC
  for i := 1 to kg
    pole_1rslt := "m1rslt"+lstr(i)
    arr_rez_gist[i,4] := &pole_1rslt
  next
endif
kg := 0
aeval(arr_rez_gist,{|x| iif(x[4] > 0, ++kg, )})
ret[1] := iif(kg > 0, 1, 0)
ret[2] := "количество гистологий - "+lstr(kg)
rest_box(buf)
return ret

** 15.01.23
Function f_valid_usl_tip(g, o)
  
  if o != NIL .and. o != m1usl_tip
    mm_shema_usl := {}
    lstr1 := space(12) ; m1usl_tip1 := 0 ;  musl_tip1 := space(69)
    lstr2 := space(13) ; m1usl_tip2 := 0 ;  musl_tip2 := space(19)
    lstr_sod := ret_str_onc(1, 2) ; mvsod := 0 ; msod := space(6)
    lstr_fr  := ret_str_onc(2, 2) ; mk_fr := space(2)
    lstr_wei := ret_str_onc(3, 2) ; mwei := space(5)
    lstr_hei := ret_str_onc(4, 2) ; mhei := space(3)
    lstr_bsa := ret_str_onc(5, 2) ; mbsa := space(4)
    lstr_err := ret_str_onc(6, 2) ; mis_err := space(11)
    lstr_she := ret_str_onc(7, 2) ; mcrit := space(57)
    lstr_lek := ret_str_onc(8, 2) ; mlek := space(53)
    lstr_ptr := ret_str_onc(9, 2) ; mpptr := space(3) ; m1pptr := 0
    if between(m1usl_tip, 1, 4)
      lstr1 := padr(mm_str1[m1usl_tip + 1], 12)
      if m1usl_tip == 1
        mm_usl_tip1 := mm_N014
      elseif m1usl_tip == 2
        lstr2 := 'Линия терапии'
        mm_usl_tip1 := mm_N016
        mm_usl_tip2 := mm_N015
        musl_tip2 := padr(mm_usl_tip2[1, 1], 19)
        m1usl_tip2 := mm_usl_tip2[1, 2]
      elseif between(m1usl_tip, 3, 4)
        mm_usl_tip1 := mm_N017
        lstr_sod := ret_str_onc(1, 1)
        msod := padr(alltrim(str_0(mvsod, 6, 2)), 6)
        lstr_fr  := ret_str_onc(2, 1)
      endif
      if eq_any(m1usl_tip, 2, 4)
        if left(m1crit, 2) == 'mt' .and. m1usl_tip == 2
          m1crit := space(10)
        elseif eq_any(left(m1crit, 2), 'не', 'sh') .and. m1usl_tip == 4
          m1crit := space(10)
        endif
        lstr_wei := ret_str_onc(3, 1)
        lstr_hei := ret_str_onc(4, 1)
        lstr_bsa := ret_str_onc(5, 1)
        if m1usl_tip == 2
          lstr_err := ret_str_onc(6, 1)
          mis_err := inieditspr(A__MENUVERT, mm_shema_err, m1is_err)
        endif
        lstr_she := ret_str_onc(7, 1)
        mm_shema_usl := iif(m1usl_tip == 2, _arr_sh, _arr_mt)
        mcrit := padr(inieditspr(A__MENUVERT, mm_shema_usl, m1crit), 57)
        lstr_lek := ret_str_onc(8, 1)
        // mlek := padr(init_lek_pr(m1usl_tip, m1crit), 53)
        mlek := padr(init_lek_pr(), 53)
        lstr_ptr := ret_str_onc(9, 1)
        mpptr := inieditspr(A__MENUVERT, mm_danet, m1pptr)
      endif
      musl_tip1 := padr(mm_usl_tip1[1, 1], 69)
      m1usl_tip1 := mm_usl_tip1[1, 2]
    endif
    update_get('lstr1')
    update_get('musl_tip1')
    update_get('lstr2')
    update_get('musl_tip2')
    update_get('lstr_sod')
    update_get('msod')
    update_get('lstr_fr')
    update_get('mk_fr')
    update_get('lstr_wei')
    update_get('mwei')
    update_get('lstr_hei')
    update_get('mhei')
    update_get('lstr_bsa')
    update_get('mbsa')
    update_get('lstr_err')
    update_get('mis_err')
    update_get('lstr_she')
    update_get('mcrit')
    update_get('lstr_lek')
    update_get('mlek')
    update_get('lstr_ptr')
    update_get('mpptr')
  endif
  return .t.

** 13.11.22
Function is_usluga_disp_nabl(_shifr, _shifr1)

  if empty(_shifr1)
    _shifr := alltrim(_shifr)
  else
    _shifr := alltrim(_shifr1)
  endif
  return between_shifr(_shifr, '2.78.61', '2.78.86') ;
    .or. between_shifr(_shifr, '2.88.52', '2.88.103') ;
    .or. between_shifr(_shifr, '2.88.105', '2.88.106') ;
    .or. between_shifr(_shifr, '2.88.120', '2.88.145') ;
    .or. _shifr == '2.5.2'  // добавил согласно письму ТФОМС 09-30-376/1 от 09.11.22 года

** 05.09.19 является услугой телемедицины - не заполняется код врача
Function is_telemedicina(lshifr, /*@*/fl2)
  Local fl := .f., tmp_select := select()

  fl2 := .f.
  select LUSLF
  find (padr(lshifr, 20))
  if found() .and. alltrim(lshifr) == alltrim(luslf->shifr) .and. luslf->telemed == 1
    fl := .t.
    fl2 := (left(luslf->shifr, 4) == 'B01.')
  endif
  select (tmp_select)
  return fl

** 12.01.20 вернуть разрешённые парные органы
Function ret_par_org(lshifr, _k_data)
  Local s := '', lalf := 'LUSLF', tmp_select := select()

  // if year(_k_data) < 2020 // т.к. в 2020 году пополнился список операций на парных органах
  //   lalf += "19"
  // endif
  lalf := create_name_alias(lalf, _k_data)
  dbSelectArea(lalf)
  if fieldnum('par_org') > 0
    find (padr(lshifr,20))
    if found() .and. alltrim(lshifr) == alltrim(&lalf.->shifr)
      s := alltrim(&lalf.->par_org)
    endif
  endif
  select (tmp_select)
  return s

** 22.01.19 обязательна ли зубная формула
Function ret_is_zf(lshifr)
  Local n := 0, tmp_select := select()
  select LUSLF
  if fieldnum('zf') > 0
    find (padr(lshifr, 20))
    if found() .and. alltrim(lshifr) == alltrim(luslf->shifr)
      n := luslf->zf
    endif
  endif
  select (tmp_select)
  return n

** 22.01.19 вернуть строку парных органов
Function ini_par_org(val, orig)
  Local i, j, a := List2Arr(orig), a1 := List2Arr(val), ret := ''

  for i := 1 to len(a)
    if ascan(a1,a[i]) > 0 .and. (j := ascan(garr_par_org, {|x| x[2] == a[i]})) > 0
      ret += garr_par_org[j, 1] + ','
    endif
  next
  return iif(empty(ret), space(10), left(ret, len(ret) - 1))

***** 07.02.19 в GET'е выбор парных органов
Function get_par_org(r,c,val,orig)
Local fl := .t., i, j, a := List2Arr(orig), a1 := List2Arr(val), arr := {}, sast, ret, rets, r1, r2
for i := 1 to len(a)
  if (j := ascan(garr_par_org, {|x| x[2] == a[i] })) > 0
    aadd(arr, aclone(garr_par_org[j]))
  endif
next
sast := array(len(arr)) ; afill(sast,.f.)
for i := 1 to len(arr)
  if ascan(a1,arr[i,2]) > 0
    sast[i] := .t.
  endif
next
a := NIL
if len(arr) > 0
  r2 := r-1
  if (r1 := r2-len(arr)-1) < 0
    r1 := 0
  endif
  a := bit_popup(r1,c,arr,sast)
endif
ret := rets := space(10)
if valtype(a) == "A"
  ret := rets := ""
  for i := 1 to len(a)
    rets += a[i,1]+","
    ret += lstr(a[i,2])+","
  next
  rets := left(rets,len(rets)-1)
  ret := left(ret,len(ret)-1)
endif
return {ret,rets}

***** 18.09.19
Function f_usl1year(lshifr,_mshifr,_mname)
Local k := 0, c, s, tmp_select := select(), buf := save_maxrow(),;
      rec_human := human->(recno()), rec_hu := hu->(recno()),;
      lyear := year(mdate_u1), lshifr_
lshifr := alltrim(lshifr) // на всякий случай
if ascan(arr_usl1year,lshifr) > 0
  mywait()
  select HUMAN
  set index to (dir_server+"humankk")
  find (str(glob_kartotek,7))
  do while human->kod_k == glob_kartotek .and. !eof()
    if lyear == year(human->n_data) .or. lyear == year(human->k_data)
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        usl->(dbGoto(hu->u_kod))
        if empty(lshifr_ := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
          lshifr_ := usl->shifr
        endif
        lshifr_ := alltrim(lshifr_)
        if lshifr == lshifr_ .and. lyear == year(c4tod(hu->date_u))
          ++k
        endif
        skip
      enddo
    endif
    select HUMAN
    skip
  enddo
  human->(dbGoto(rec_human))
  hu->(dbGoto(rec_hu))
  select (tmp_select)
  rest_box(buf)
  if k > 0
    s := "раз"
    c := right(str(k),1)
    if !between(k,11,19) .and. eq_any(c,"2","3","4")
      s += "а"
    endif
    n_message({"Предупреждение!",;
               "",;
               "Услуга "+alltrim(_mshifr),;
               "("+alltrim(_mname)+")",;
               "должна встречаться у больного не более одного раза в году,",;
               "а у данного больного она встречалась уже "+lstr(k)+" "+s+"!"},,;
               "GR+/R","W+/R",,,"G+/R")
  endif
endif
return NIL

***** 11.01.13 вернуть уровень МО в зависимости от даты
Function get_uroven(dDate)
Local i, ret := 4 // с 2013 года у всех индивидуальные тарифы
DEFAULT dDate TO sys_date
if year(dDate) < 2013
  for i := 1 to len(glob_mo[_MO_UROVEN])
    if dDate >= glob_mo[_MO_UROVEN,i,1]
      ret := glob_mo[_MO_UROVEN,i,2]
    endif
  next
endif
return ret

***** для 1-3ур. вернуть уровень для услуг "койко-день" или 1-й для остальных
Function get2uroven(sShifr,nU)
DEFAULT nU TO get_uroven()
if nU < 4 .and. !(left(sShifr,2)=="1.")
  nU := 1
endif
return nU

***** 24.11.21
Function fcena_oms(sShifr,lVzReb,dDate,/*@*/fl_delete,/*@*/fl_yes,/*@*/_ifin)
  Local i, v, tmp_select := select(), lvr, nu, lal, s := glob_mo[_MO_KOD_TFOMS]

  sShifr := padr(sShifr, 10)
  if valtype(dDate) == "D"
    dDate := {dDate}
  endif
  if !empty(glob_podr) .and. year(dDate[1]) == 2017
    s := padr(glob_podr, 6) // заменяем на код адреса подразделения
  endif
  lvr := iif(lVzReb, 0, 1)
  for i := 1 to len(dDate)
    v := 0
    nu := get2uroven(sShifr, get_uroven(dDate[i]))
    _ifin := 0
    fl_delete := .t. ; fl_yes := .f.
    lal := "luslc"
    lal := create_name_alias(lal, dDate[i])
    dbselectarea(lal)
    set order to 1
    find (sShifr+str(lvr,1)+str(glob_otd_dep,3)) // сначала ищем цену для конкретного отделения
    do while sShifr == &lal.->shifr .and. &lal.->VZROS_REB == lvr .and. &lal.->depart == glob_otd_dep .and. !eof()
      fl_yes := .t.
      if between_date(&lal.->datebeg,&lal.->dateend,dDate[i]) // поиск цены по дате окончания лечения
        fl_delete := .f.
        v := &lal.->CENA ; exit
      endif
      skip
    enddo
    if !fl_yes .and. fl_delete // если не нашли
      find (sShifr+str(lvr,1)+str(0,3)) // то ищем цену для depart = 0
      do while sShifr == &lal.->shifr .and. &lal.->VZROS_REB == lvr .and. &lal.->depart == 0 .and. !eof()
        fl_yes := .t.
        if between_date(&lal.->datebeg,&lal.->dateend,dDate[i]) // поиск цены по дате окончания лечения
          fl_delete := .f.
          v := &lal.->CENA ; exit
        endif
        skip
      enddo
    endif
    if empty(v)
      exit
    endif
  next
  select (tmp_select)
  return v

***** 24.02.21
Function f1cena_oms(sShifr,sShifr1,lVzReb,dDate,lis_nul,/*@*/fl_uslc,/*@*/fl_del)
Local s, v, lu_cena
DEFAULT lis_nul TO .f.
fl_uslc := .f. ; fl_del := .f.
s := iif(empty(sShifr1),sShifr,sShifr1)
v := fcena_oms(s,;
               lVzReb,;
               dDate,;
               @fl_del,;
               @fl_uslc)
if fl_uslc  // если нашли в справочнике ТФОМС
  lu_cena := v
  if fl_del .and. !lis_nul
    func_error(4,"В справочнике ТФОМС услуга "+alltrim(s)+" удалена (на "+full_date(dDate)+")")
  endif
elseif !lis_nul
  //func_error(4,"В справочнике ТФОМС данная услуга отсутствует!")
endif
return lu_cena

** Группы МКБ + услуги по стандартам
Function Uslugi_MKB_Standart()
Local arr
arr := array(11)
// инфаркты миокарда
arr[1] := {}
aadd(arr[1],"1.7.25")
aadd(arr[1],"1.7.26")
aadd(arr[1],"1.7.27")
aadd(arr[1],"1.7.46")
aadd(arr[1],"1.7.47")
aadd(arr[1],"1.7.48")
aadd(arr[1],"1.7.49")
// инсульты
arr[2] := {}
aadd(arr[2],"1.7.28")
aadd(arr[2],"1.7.29")
aadd(arr[2],"1.7.30")
aadd(arr[2],"1.7.31")
aadd(arr[2],"1.7.51")
aadd(arr[2],"1.7.52")
// ЧМТ
arr[3] := {}
aadd(arr[3],"1.7.32")
aadd(arr[3],"1.7.33")
aadd(arr[3],"1.7.34")
// онкология
arr[4] := {}
aadd(arr[4],"1.7.13")
aadd(arr[4],"1.7.14")
aadd(arr[4],"1.7.15")
aadd(arr[4],"1.7.16")
aadd(arr[4],"1.7.17")
aadd(arr[4],"1.7.18")
// пневмонии
arr[5] := {}
aadd(arr[5],"1.7.19")
aadd(arr[5],"1.7.20")
aadd(arr[5],"1.7.21")
aadd(arr[5],"1.7.22")
aadd(arr[5],"1.7.23")
aadd(arr[5],"1.7.24")
aadd(arr[5],"1.7.44")
aadd(arr[5],"1.7.45")
aadd(arr[5],"1.7.50")
// язвы
arr[6] := {}
aadd(arr[6],"1.7.35")
aadd(arr[6],"1.7.36")
aadd(arr[6],"1.7.37")
aadd(arr[6],"1.7.58")
aadd(arr[6],"1.7.59")
aadd(arr[6],"1.7.60")
aadd(arr[6],"1.7.61")
aadd(arr[6],"1.7.62")
aadd(arr[6],"1.7.63")
aadd(arr[6],"1.7.64")
aadd(arr[6],"1.7.65")
aadd(arr[6],"1.7.66")
// родовая травма
arr[7] := {}
aadd(arr[7],"1.7.41")
aadd(arr[7],"1.7.42")
aadd(arr[7],"1.7.43")
// новорожденный с низкой массой тела
arr[8] := {}
aadd(arr[8],"1.7.38")
aadd(arr[8],"1.7.39")
aadd(arr[8],"1.7.40")
// астма
arr[9] := {}
aadd(arr[9],"1.7.67")
aadd(arr[9],"1.7.68")
aadd(arr[9],"1.7.69")
aadd(arr[9],"1.7.70")
// диабет
arr[10] := {}
aadd(arr[10],"1.7.71")
aadd(arr[10],"1.7.72")
aadd(arr[10],"1.7.73")
// панкреатит
arr[11] := {}
aadd(arr[11],"1.7.74")
aadd(arr[11],"1.7.75")
aadd(arr[11],"1.7.77")
return arr

** сделать единую строку полиса из полей серии и номера полиса
Function make_polis(_spolis, _npolis)
  Local s := alltrim(_spolis)

  if !empty(s)
    s += ' '
  endif
  return s + alltrim(_npolis)

** 19.05.22 вывести наименование диагноза при вводе случая
Function diag_screen(k, arr_d, lUp)
  Static buf_d
  Local i, lc, r // := 12

  default lUp TO .f.

  r := iif(lUp, 5, 12)
  if type('row_diag_screen') == 'N' .and. row_diag_screen > 0
    r := row_diag_screen
  endif
  if k == 0 // обнулить буфер
    buf_d := nil
  elseif k == 1 // если надо, отрисовать прямоугольник, и вывести диагноз
    if buf_d == nil
      buf_d := box_shadow(r, 3, r + 5, 76, 'N/RB', 'Диагноз', 'W/RB')
    endif
    for i := 1 to len(arr_d)
      lc := if('в ОМС' $ arr_d[i] .or. 'по полу' $ arr_d[i], 'GR+/RB', 'W+/RB')
      @ r+i,5 say padr(arr_d[i],71) color lc
    next
  elseif k == 2 // восстановить экран  и обнулить буфер
    if buf_d != nil
      rest_box(buf_d)
    endif
    buf_d := nil
  endif
  return .t.


***** вывести мигалки перед диагнозами, если введена доп.инф-ия по талону
Function put_dop_diag()
// позиции get'ов диагнозов
Static arc := {{9,25},{10,25},{10,33},{10,41},{10,49},{10,57},{10,65},{10,73}}
Local i, j, fl[8]
if is_talon
  afill(fl,.f.)
  j := 0
  for i := 1 to 16
    if i % 2 == 1
      ++j
    endif
    if adiag_talon[i] > 0
      fl[j] := .t.
    endif
  next
  if !(type("row_dop_diag") == "N")
    Private row_dop_diag := 0
  endif
  for i := 1 to 8
    @ arc[i,1]+row_dop_diag,arc[i,2]-1 say iif(fl[i], chr(16), " ") color color8
  next
endif
return .t.

** сделать "пяти или шести-значные" диагнозы
Function make_diagP(k)
if k == 1  // сделать "шестизначные" диагнозы
  MKOD_DIAG  := MKOD_DIAG  + substr(mdiag_plus,1,1)
  MKOD_DIAG2 := MKOD_DIAG2 + substr(mdiag_plus,2,1)
  MKOD_DIAG3 := MKOD_DIAG3 + substr(mdiag_plus,3,1)
  MKOD_DIAG4 := MKOD_DIAG4 + substr(mdiag_plus,4,1)
  MSOPUT_B1  := MSOPUT_B1  + substr(mdiag_plus,5,1)
  MSOPUT_B2  := MSOPUT_B2  + substr(mdiag_plus,6,1)
  MSOPUT_B3  := MSOPUT_B3  + substr(mdiag_plus,7,1)
  MSOPUT_B4  := MSOPUT_B4  + substr(mdiag_plus,8,1)
else       // сделать "пятизначные" диагнозы
  mdiag_plus := right(MKOD_DIAG ,1)+;
                right(MKOD_DIAG2,1)+;
                right(MKOD_DIAG3,1)+;
                right(MKOD_DIAG4,1)+;
                right(MSOPUT_B1 ,1)+;
                right(MSOPUT_B2 ,1)+;
                right(MSOPUT_B3 ,1)+;
                right(MSOPUT_B4 ,1)
  MKOD_DIAG  := left(MKOD_DIAG ,5)
  MKOD_DIAG2 := left(MKOD_DIAG2,5)
  MKOD_DIAG3 := left(MKOD_DIAG3,5)
  MKOD_DIAG4 := left(MKOD_DIAG4,5)
  MSOPUT_B1  := left(MSOPUT_B1 ,5)
  MSOPUT_B2  := left(MSOPUT_B2 ,5)
  MSOPUT_B3  := left(MSOPUT_B3 ,5)
  MSOPUT_B4  := left(MSOPUT_B4 ,5)
endif
return NIL

** сформировать номер амбулаторной карты
Function amb_kartaN(fl_0)
Local lnomer := lstr(kart->kod)
if is_uchastok == 1
  lnomer := ""
  if !emptyall(kart->bukva,kart->uchast,kart->kod_vu)
    if !empty(kart->bukva)
      lnomer += kart->bukva
    endif
    lnomer += lstr(kart->uchast,2)
    DEFAULT fl_0 TO .f.
    if kart->kod_vu > 0 .or. fl_0
      lnomer += "/"+lstr(kart->kod_vu)
    endif
  endif
elseif is_uchastok == 2
  if !emptyall(kart->bukva,kart->uchast)
    lnomer := ""
    if !empty(kart->bukva)
      lnomer += kart->bukva
    endif
    lnomer += lstr(kart->uchast,2)
    lnomer += "/"+lstr(kart->kod)
  endif
elseif is_uchastok == 3
  lnomer := kart2->kod_AK
endif
return lnomer

***** 24.07.18 выбрать карточку пациента из картотеки
Function polikl_kart(k)
// k = 1 - начало лечения -> ввод карточки
// k = 2 - возврат кода по картотеке
Static sesc := "^<Esc>^ выход  "
Static senter := "^<Enter>^ ввод  "
Static sF10p := "^<F10>^ поиск по полису  "
Static sF10f := "^<F10>^ поиск по ФИО  "
Static sF10s := "^<F10>^ поиск по СНИЛС  "
Static sF11  := "^<F11>^ читать электронный полис"
Static _err_slock := "В данный момент с карточкой этого пациента работает другой пользователь."
Static s_regim := 1, s_shablon := "", s_polis := "", s_snils := ""
Local tmp1, mkod := -1, i, fl_number := .t., s, append_or_edit := 0,;
      k1 := 0, k2 := 1, str_sem, mbukva := "", tmp_color, buf, buf24, ar
Private tmp, name_reader := ""
// обмен информацией с программой Smart Delta Systems
import_kart_from_sds()
/////////////////////////////////////////////////////
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
    if mem_smp_input == 1 .and. ((len(glob_otd) > 2 .and. glob_otd[3] == 4) .or. ;
       (len(glob_otd) > 3 .and. eq_any(glob_otd[4],TIP_LU_SMP,TIP_LU_NMP))) // скорая помощь (неотложная мед.помощь)
      s_shablon := ""
      keyboard chr(K_ENTER)
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
  if append_or_edit == 2 // добавили в картотеку
    keyboard chr(K_ENTER)
    oms_sluch(,glob_kartotek)
  else // перезаписали в картотеке
    if verify_lechenie(glob_kartotek,@k1)
      if k1 > 0
        str_sem := "Редактирование человека "+lstr(glob_perso)
        if !G_SLock(str_sem)
          return func_error(4,err_slock)
        endif
        Private fl_v_lech := .t.
      endif
      keyboard chr(K_ENTER)
      oms_sluch(k1,glob_kartotek)
      if k1 > 0
        G_SUnLock(str_sem)
      endif
    endif
  endif
elseif s_regim == 1
  s_shablon := alltrim(tmp)
  if empty(tmp := alltrim(tmp))
    mkod := 0
    if k == 1  // режим "Добавление" в задаче ОМС
      oms_sluch()
    endif
  elseif tmp == "*"
    if oms_view_kart(T_ROW)
      mkod := glob_kartotek
      if k == 1 .and. verify_lechenie(glob_kartotek,@k1)
        if k1 > 0
          str_sem := "Редактирование человека "+lstr(glob_perso)
          if !G_SLock(str_sem)
            return func_error(4,err_slock)
          endif
          Private fl_v_lech := .t.
        endif
        oms_sluch(k1,glob_kartotek)
        if k1 > 0
          G_SUnLock(str_sem)
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
      if fvalid_fio(1,tmp,fl_number,mbukva) .and. ;
                             verify_lechenie(glob_kartotek,@k1)
        if k1 > 0
          str_sem := "Редактирование человека "+lstr(glob_perso)
          if !G_SLock(str_sem)
            return func_error(4,err_slock)
          endif
          Private fl_v_lech := .t.
        endif
        oms_sluch(k1,glob_kartotek)
        if k1 > 0
          G_SUnLock(str_sem)
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
      oms_sluch()
    endif
  elseif k == 1
    if fvalid_fio(s_regim,tmp,fl_number,mbukva) .and. ;
                             verify_lechenie(glob_kartotek,@k1)
      if k1 > 0
        str_sem := "Редактирование человека "+lstr(glob_perso)
        if !G_SLock(str_sem)
          return func_error(4,err_slock)
        endif
        Private fl_v_lech := .t.
      endif
      oms_sluch(k1,glob_kartotek)
      if k1 > 0
        G_SUnLock(str_sem)
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

** выбор карточки из картотеки
Function oms_view_kart(r1,r2)
Local buf := savescreen(), mkod := 0, arr_blk, fl := .f.
DEFAULT r1 TO 2, r2 TO maxrow()-2
Private mr1 := r1, mr2 := r2, str_find := "1", muslovie := "kart->kod > 0"
arr_blk := {{|| FindFirst(str_find)},;
            {|| FindLast(str_find)},;
            {|n| SkipPointer(n, muslovie)},;
            str_find,muslovie;
           }
if use_base("kartotek")
  if glob_kartotek > 0
    set order to 1
    find (STR(glob_kartotek,7))
    fl := found()
  endif
  set order to 2
  if !fl
    find (str_find)
    if !found()
      close databases
      return func_error(4,"Не найдено нужных записей!")
    endif
  endif
  if Alpha_Browse(mr1,2,mr2,77,"f1oms_view_kart",color0,,,,;
                  .t.,arr_blk,,,,;
                  {'═','░','═',"N/BG,W+/N,B/BG,W+/B,R/BG,W+/R",,300} )
    if (glob_kartotek := kart->kod) == 0
      func_error(4,"Не найдено нужных записей!")
    elseif eq_any(glob_task,X_OMS,X_PPOKOJ) .and. kart->MEST_INOG == 8
      func_error(4,"Не разрешается работать с анонимами в данной задаче!")
    else
      mkod := glob_kartotek
      glob_k_fio := alltrim(kart->fio)
    endif
  endif
endif
close databases
restscreen(buf)
return (mkod > 0)

***** 20.02.14
Function f1oms_view_kart(oBrow)
Local oColumn, blk, n := 42
if glob_mo[_MO_IS_UCH]
  blk := {|| iif(kart2->mo_pr==glob_MO[_MO_KOD_TFOMS], {1,2},;
                           iif(empty(kart2->mo_pr), {3,4}, {5,6})) }
endif
if mem_kodkrt == 2
  if is_uchastok == 1
    n -= 11
  elseif eq_any(is_uchastok,2,3)
    n -= 12
  else
    n -= 7
  endif
endif
oColumn := TBColumnNew(center("Фамилия, имя, отчество",n),{|| left(kart->fio,n)})
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if mem_kodkrt == 2
  if is_uchastok > 0
    oColumn := TBColumnNew(" ",{|| kart->bukva})
    oColumn:defColor := {3,3}
    oColumn:colorBlock := {|| {3,3} }
    oBrow:addColumn(oColumn)
    oColumn := TBColumnNew("Уч",{|| put_val(kart->uchast,2)})
    oColumn:defColor := {3,3}
    oColumn:colorBlock := {|| {3,3} }
    oBrow:addColumn(oColumn)
  endif
  if is_uchastok == 1
    oColumn := TBColumnNew(" Код",{|| put_val(kart->kod_vu,5)})
    oColumn:defColor := {3,3}
    oColumn:colorBlock := {|| {3,3} }
    oBrow:addColumn(oColumn)
  elseif is_uchastok == 2
    oColumn := TBColumnNew("  Код",{|| kart->kod})
    oColumn:defColor := {3,3}
    oColumn:colorBlock := {|| {3,3} }
    oBrow:addColumn(oColumn)
  elseif is_uchastok == 3
    oColumn := TBColumnNew("Код АК",{|| left(kart2->kod_AK,6) })
    oColumn:defColor := {3,3}
    oColumn:colorBlock := {|| {3,3} }
    oBrow:addColumn(oColumn)
  endif
endif
oColumn := TBColumnNew("Дата рожд.",{|| full_date(kart->date_r)})
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(center("Полис",17),{|| " "+kart->polis})
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
return NIL

***** 05.02.19 есть ли листы учёта по данному пациенту
Function verify_lechenie(kod_kart,/*@*/p1)
Local buf := save_maxrow(), arr := {}, i, k, r2, mas2, mpic
p1 := 0
mywait()
R_Use(dir_server+"mo_pp",dir_server+"mo_pp_h","PP")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
for k := 1 to B_STANDART
  // k = 1 - проверим листы, добавленные в Приёмном покое - уже так не делаем
  // k = 2(B_END) - проверим листы с незавершённым лечением
  // B_STANDART = 3 - проверим листы с завершённым лечением
  find (str(kod_kart,7)+str(k,1))
  do while human->kod_k == kod_kart .and. human->tip_h == k .and. !eof()
    human_->(dbGoto(human->(recno())))
    if empty(human_->reestr) .and. !eq_any(human->ishod,88,89) // если человек в данный момент лечится
      aadd(arr, {"",;
                 date_8(human->n_data),;
                 date_8(human->k_data),;
                 human->cena_1,;
                 human->kod,;
                 human->otd,;
                 "",;
                 human->tip_h,;
                 human->lpu,;
                 "",;
                 human->k_data;
                } )
      i := len(arr)
      select PP
      find (str(human->kod,7))
      if found()
        arr[i,8] := B_BOLEN // поэтому искусственно делаем приёмный покой
      endif
      arr[i,7] := iif(arr[i,8]==B_STANDART,space(7),iif(arr[i,8]==B_END,"не зав.","п/покой"))
    endif
    select HUMAN
    skip
  enddo
next
pp->(dbCloseArea())
human_->(dbCloseArea())
human->(dbCloseArea())
if (k := len(arr)) > 0
  R_Use(dir_server+"mo_otd",,"OTD")
  aeval(arr, {|x,i| otd->(dbGoto(x[6])), arr[i,1] := left(otd->name,30) } )
  Use
  if k == 1
    R_Use(dir_server+"mo_uch",,"UCH")
    aeval(arr, {|x,i| uch->(dbGoto(x[9])), arr[i,10] := " ["+alltrim(uch->name)+"]" } )
    Use
    ClrLine(maxrow(),color0)
    if f_alert({"На выбранного больного уже выписан лист учета в отделении",;
                charone('"','"'+alltrim(arr[1,1])+'"'+arr[1,10]),;
                iif(arr[1,8]==B_STANDART,"",iif(arr[1,8]==B_END,"(Лечение не завершено)","(Добавили в приёмном покое)")),;
                "[ Период лечения с "+arr[1,2]+" по "+arr[1,3]+" ]",;
                "Выберите действие:"},;
                {" ~Новый лист учета "," ~Редактирование старого листа учета "},;
                1,;
                "N+/BG",;
                "R/BG",15,,col1menu ) == 2
      glob_perso := p1 := arr[1,5]
      R_Use(dir_server+"mo_otd",,"OTD")
      goto (arr[1,6])
      glob_otd := {otd->kod,alltrim(otd->name),otd->idump,otd->tiplu}
      use
    endif
  else
    R_Use(dir_server+"mo_uch",,"UCH")
    aeval(arr, {|x,i| uch->(dbGoto(x[9])), arr[i,10] := uch->short_name } )
    Use
    asort(arr,,,{|x,y| x[11] < y[11] } )
    mas2 := {{ 1,center("Отделение",30)},;
             {10,"Учреж;дение"},;
             { 2,"Начало;лечения"},;
             { 3,"Окончан.;лечения"},;
             { 4,"   Сумма; лечения"},;
             { 7,"Приме-;чание"}}
    mpic := {,,,,{9,2},}
    status_key("^<Esc>^ - новый лист учета;  ^<Enter>^ - добавление в старый лист учета")
    if (r2 := T_ROW+k+4) > maxrow()-2
      r2 := maxrow()-2
    endif
    if (k := Arrn_Browse(T_ROW,2,r2,77,arr,mas2,1,,color0,;
                         "Листы учета по больному, не включенные в реестры",'B/BG',,,mpic,,,;
                         {"═","░","═"})) > 0
      glob_perso := p1 := arr[k,5]
      R_Use(dir_server+"mo_otd",,"OTD")
      goto (arr[k,6])
      glob_otd := {otd->kod,alltrim(otd->name),otd->idump,otd->tiplu}
      use
    endif
  endif
endif
rest_box(buf)
return .t.

** 14.03.16 поиск по шаблону в картотеке
Function fvalid_fio(lregim,input_sh,fl_number,mbukva)
Local fl := .f., pos1, pos2, tmp_list, buf, ;
      tmp2 := "", c1, fl_bukva, s_msg, rec_tmp := 0
DEFAULT lregim TO 1, mbukva TO ""
if !myFileDeleted(cur_dir + "tmp_kart"+sdbf)
  return fl
endif
Private top_frm
if lregim == 1
  Private mfio := input_sh
  pos1 := at("*",mfio) ; pos2 := at("?",mfio)
elseif lregim == 2
  Private mpolis := input_sh
else
  Private msnils := input_sh
endif
//
Private tmp1, ch
buf := savescreen()
dbcreate(cur_dir + "tmp_kart",{{"kod","N",7,0},;
                     {"fio","C",50,0},;
                     {"mest_inog","N",1,0},;
                     {"bukva","C",1,0},;
                     {"uchast","N",2,0},;
                     {"kod_vu","N",5,0},;
                     {"kod_AK","C",6,0}} )
use (cur_dir + "tmp_kart") new alias TMP
index on upper(fio) to (cur_dir + "tmp_kart")
if lregim == 1
  if fl_number
    if is_uchastok == 1
      R_Use(dir_server+"kartotek",dir_server+"kartoteu","KART")
      find (input_sh)
      if found()
        mywait()
        fl_bukva := (right(input_sh,5) == "00000" .and. !empty(mbukva))
        fl := .t.
        do while input_sh == (strzero(kart->uchast,2)+strzero(kart->kod_vu,5))
          if if(fl_bukva, (kart->bukva == mbukva), .t.)
            select TMP
            append blank
            tmp->kod := kart->kod ; tmp->fio := kart->fio
            tmp->mest_inog := kart->mest_inog
            tmp->bukva := kart->bukva
            tmp->uchast := kart->uchast
            tmp->kod_vu := kart->kod_vu
            if tmp->kod == glob_kartotek
              rec_tmp := tmp->(recno())
            endif
          endif
          select KART
          skip
        enddo
        tmp2 := input_sh
      else
        func_error(4,"Неудачный поиск по коду "+input_sh+" в картотеке!")
      endif
    elseif is_uchastok != 3
      R_Use(dir_server+"kartotek",,"KART")
      goto (int(val(input_sh)))
      if !eof() .and. kart->kod > 0 .and. !deleted()
        fl := .t.
        select TMP
        append blank
        tmp->kod := kart->kod ; tmp->fio := kart->fio
        tmp->mest_inog := kart->mest_inog
        tmp->bukva := kart->bukva
        tmp->uchast := kart->uchast
        tmp2 := input_sh
        if tmp->kod == glob_kartotek
          rec_tmp := tmp->(recno())
        endif
      else
        func_error(4,"Неудачный поиск по коду "+input_sh+" в картотеке!")
      endif
    endif
  elseif (pos1 > 0 .or. pos2 > 0)
    WaitStatus("Ждите! Производится поиск в картотеке.  (<Esc> - прервать поиск)")
    @ 2,0 say ""
    R_Use(dir_server+"kartote2",,"KART2")
    R_Use(dir_server+"kartotek",dir_server+"kartoten","KART")
    set relation to recno() into KART2
    tmp2 := upper(alltrim(mfio)) ; ch := left(ltrim(mfio),1)
    if !(ch == "*" .or. ch == "?")
      tmp1 := tmp2
      if "*" $ tmp1 ; tmp1 := beforatnum("*",tmp1,1) ; endif
      if "?" $ tmp1 ; tmp1 := beforatnum("?",tmp1,1) ; endif
      if len(tmp1) > 20 ; tmp1 := left(tmp1,20) ; endif
      ch := len(tmp1)
      select KART
      find ("1"+tmp1)
      do while kart->kod > 0 .and. tmp1 == left(upper(fio),ch) .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC ; exit ; endif
        if like(tmp2,upper(kart->fio))
          select TMP
          append blank
          tmp->kod := kart->kod ; tmp->fio := kart->fio
          tmp->mest_inog := kart->mest_inog
          if is_uchastok > 0
            tmp->bukva := kart->bukva
            tmp->uchast := kart->uchast
            tmp->kod_vu := kart->kod_vu
            if is_uchastok == 3
              tmp->kod_AK := kart2->kod_AK
            endif
          endif
          if tmp->kod == glob_kartotek
            rec_tmp := tmp->(recno())
          endif
        endif
        select KART
        skip
      enddo
    else
      select KART
      find ("1")
      do while kart->kod > 0 .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC ; exit ; endif
        if like(tmp2,upper(kart->fio))
          select TMP
          append blank
          tmp->kod := kart->kod ; tmp->fio := kart->fio
          tmp->mest_inog := kart->mest_inog
          if is_uchastok > 0
            tmp->bukva := kart->bukva
            tmp->uchast := kart->uchast
            tmp->kod_vu := kart->kod_vu
            if is_uchastok == 3
              tmp->kod_AK := kart2->kod_AK
            endif
          endif
          if tmp->kod == glob_kartotek
            rec_tmp := tmp->(recno())
          endif
        endif
        select KART
        skip
      enddo
    endif
  endif
  s_msg := "по шаблону "+tmp2
elseif lregim == 2
  WaitStatus("Ждите! Производится поиск в картотеке.  (<Esc> - прервать поиск)")
  @ 2,0 say ""
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartotek",dir_server+"kartotep","KART")
  set relation to recno() into KART2
  find ("1"+mpolis)
  do while kart->polis == mpolis .and. kart->kod > 0 .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC ; exit ; endif
    select TMP
    append blank
    tmp->kod := kart->kod ; tmp->fio := kart->fio
    tmp->mest_inog := kart->mest_inog
    if is_uchastok > 0
      tmp->bukva := kart->bukva
      tmp->uchast := kart->uchast
      tmp->kod_vu := kart->kod_vu
      if is_uchastok == 3
        tmp->kod_AK := kart2->kod_AK
      endif
    endif
    if tmp->kod == glob_kartotek
      rec_tmp := tmp->(recno())
    endif
    select KART
    skip
  enddo
  s_msg := "по полису "+alltrim(mpolis)
elseif lregim == 3
  WaitStatus("Ждите! Производится поиск в картотеке.  (<Esc> - прервать поиск)")
  @ 2,0 say ""
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartotek",dir_server+"kartotes","KART")
  set relation to recno() into KART2
  find ("1"+msnils)
  do while kart->snils == msnils .and. kart->kod > 0 .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC ; exit ; endif
    select TMP
    append blank
    tmp->kod := kart->kod ; tmp->fio := kart->fio
    tmp->mest_inog := kart->mest_inog
    if is_uchastok > 0
      tmp->bukva := kart->bukva
      tmp->uchast := kart->uchast
      tmp->kod_vu := kart->kod_vu
      if is_uchastok == 3
        tmp->kod_AK := kart2->kod_AK
      endif
    endif
    if tmp->kod == glob_kartotek
      rec_tmp := tmp->(recno())
    endif
    select KART
    skip
  enddo
  s_msg := "по СНИЛС "+transform(mSNILS,picture_pf)
endif
fl := ( tmp->(lastrec()) > 0 )
close databases
if fl
  if !(type("is_r_mu") == "L")
    Public is_r_mu := .f.
  endif
  save gets to tmp_list
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  use (cur_dir + "tmp_kart") index (cur_dir + "tmp_kart") new alias TMP
  set relation to kod into KART, to kod into KART_, to kod into KART2
  if rec_tmp > 0
    goto (rec_tmp)
  else
    go top
  endif
  change_attr()
  top_frm := 14
  @ 13,0 say padc("_Просмотр картотеки_",80,"░") color "R/BG"
  c1 := 24
  if mem_kodkrt == 2
    if is_uchastok == 1
      c1 -= 10
    elseif eq_any(is_uchastok,2,3)
      c1 -= 12
    else
      c1 -= 7
    endif
  endif
  if (fl := Alpha_Browse(0,c1,11,77,"f1_v_fiotmp",color0,;
         "Результат отбора "+s_msg,'B/BG',.f.,.t.,,;
         "f2_v_fio",,,{"═","░","═","N/BG,W+/N,B/BG,W+/B,R/BG,W+/R",,0} ))
    if glob_task == X_OMS .and. tmp->MEST_INOG == 8
      fl := func_error(4,"Не разрешается работать с анонимами в задаче ОМС!")
    else
      m1kod_k := glob_kartotek := tmp->kod
      glob_k_fio := alltrim(tmp->fio)
    endif
  endif
  close databases
else
  func_error(4,"Неудачный поиск "+s_msg+" в картотеке!")
endif
restscreen(buf)
//
return fl

*****
Function f1_v_fiotmp(oBrow)
Local blk
if glob_mo[_MO_IS_UCH]
  blk := {|| iif(kart2->mo_pr==glob_MO[_MO_KOD_TFOMS], {1,2}, iif(empty(kart2->mo_pr), {3,4}, {5,6})) }
endif
oColumn := TBColumnNew(center("Ф.И.О.",49),{||padr(tmp->fio,49)})
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if mem_kodkrt == 2
  if is_uchastok > 0
    oColumn := TBColumnNew(" ",{|| tmp->bukva})
    oColumn:colorBlock := blk
    oBrow:addColumn(oColumn)
    //
    oColumn := TBColumnNew("Уч",{|| put_val(tmp->uchast,2)})
    oColumn:colorBlock := blk
    oBrow:addColumn(oColumn)
  endif
  if is_uchastok == 1
    oColumn := TBColumnNew(" Код",{|| put_val(tmp->kod_vu,5)})
    oColumn:colorBlock := blk
    oBrow:addColumn(oColumn)
  elseif is_uchastok == 2
    oColumn := TBColumnNew("  Код",{|| str(tmp->kod,7) })
    oColumn:colorBlock := blk
    oBrow:addColumn(oColumn)
  elseif is_uchastok == 3
    oColumn := TBColumnNew("Код АК",{|| tmp->kod_AK })
    oColumn:colorBlock := blk
    oBrow:addColumn(oColumn)
  endif
endif
status_key("^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор")
return NIL

*****
Function f1_v_fio(oBrow)
  Local oColumn

  oColumn := TBColumnNew(center('Ф.И.О.', 49), {||padr(tmp->fio, 49)})
  oBrow:addColumn(oColumn)
  status_key('^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор')
  return NIL

*****
Function f2_v_fio()
  
  kartotek_to_screen(14,23)
  if !(type('dubl1_kart') == 'N')
    select TMP
  endif
  return NIL

*****
Function input_schet(rr, r, c)
Local mas_pmt := {"Поиск по ~номеру счета",;
                  "Поиск по ~принадлежности счета"}
Local i, k, recc := 0, fl := .f., buf, tmp_color := setcolor(), ar
Local adbf_tmp := {;
   {"KOD",        "N",      6,      0},;
   {"NOMER_S",    "C",     15,      0},;
   {"DATE_S",     "D",      8,      0},;
   {"SUMMA",      "N",     13,      2},;
   {"KOL",        "N",      4,      0},;
   {"NAME",       "C",     40,      0},;
   {"KRIT",       "C",     10,      0},;
   {"KOMU",       "N",      1,      0},;
   {"SMO",        "C",      5,      0},; // код СМО
   {"STR_CRB",    "N",      2,      0};
  }
DEFAULT r TO T_ROW, c TO T_COL-5
if !myFileDeleted(cur_dir + "tmp"+sdbf)
  return fl
endif
ar := GetIniSect(tmp_ini,"schet")
Private mnomer := padr(a2default(ar,"number"),15), ;
        p_i := val(a2default(ar,"i","1"))
if .t.//(i := popup_prompt(r,c,p_i,mas_pmt)) > 0
  p_i := i := 1  // !!!!
  do case
    case i == 1
      buf := box_shadow(16,20,20,59,color8)
      tmp_color := setcolor(cDataCGet)
      buf24 := save_maxrow()
      status_key("^<Esc>^ - отказ;  ^<Enter>^ - подтверждение выбора счета")
      @ 18,22 say "Введите номер счета" get mnomer picture "@!@K"
      myread({"confirm"})
      if lastkey() != K_ESC .and. !empty(mnomer)
        dbcreate(cur_dir + "tmp",adbf_tmp)
        Use (cur_dir + "tmp") new alias TMP
        R_Use(dir_server+"schet_",,"SCHET_")
        R_Use(dir_server+"schet",dir_server+"schetn","SCHET")
        set relation to recno() into SCHET_
        find (padr(mnomer,10))
        if found()
          do while schet->nomer_s == padr(mnomer,10) .and. !eof()
            if schet_->NSCHET == mnomer
              recc++
              select TMP
              append blank
              tmp->KOD     := schet->KOD
              tmp->NOMER_S := schet_->NSCHET
              tmp->DATE_S  := schet_->DSCHET
              tmp->SUMMA   := schet->SUMMA
              tmp->KOL     := schet->KOL
              tmp->KOMU    := schet->KOMU
              tmp->smo     := schet_->smo
              tmp->STR_CRB := schet->STR_CRB
              tmp->krit    := f3_view_list_schet()
            endif
            select SCHET
            skip
          enddo
        endif
        schet_->(dbCloseArea())
        schet->(dbCloseArea())
        rest_box(buf)
        rest_box(buf24)
        setcolor(tmp_color)
        if recc > 0
          select TMP
          if recc == 1
            fl := .t.
            go top
            glob_schet := tmp->kod
          else
            dbeval({|| tmp->name := f4_view_list_schet(tmp->komu,tmp->smo,tmp->str_crb) })
            index on descend(dtos(date_s)) to (cur_dir + "tmp")
            go top
            if (fl := Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1inp_schet",color0,;
                            "Счета с номером "+alltrim(mnomer),"R/BG",;
                            .f.,,,,,,{'═','░','═',,,180} ))
              glob_schet := tmp->kod
            endif
          endif
        else
          func_error(4,"Счёта с номером "+alltrim(mnomer)+" нет в базе данных!")
        endif
      endif
    case i == 2
      ne_real()
      /*if (k := func2_komu(,,r-1,c,.t.)) != NIL
        buf24 := save_maxrow()
        mywait()
        dbcreate(cur_dir + "tmp",adbf_tmp)
        Use (cur_dir + "tmp") new alias TMP
        index on descend(date_s) to (cur_dir + "tmp")
        G_Use(dir_server+"schet",dir_server+"schetp","SCHET")
        find (str(glob_komu,1)+str(glob_all[1],2))
        do while schet->komu == glob_komu .and. schet->str_crb == glob_all[1] .and. !eof()
          recc++
          select TMP
          append blank
          replace tmp->KOD     with schet->KOD    ,;
                  tmp->NOMER_S with schet->NOMER_S,;
                  tmp->DATE_S  with c4tod(schet->pdate) ,;
                  tmp->SUMMA   with schet->SUMMA  ,;
                  tmp->KOL     with schet->KOL    ,;
                  tmp->LPU     with schet->LPU    ,;
                  tmp->KOMU    with schet->KOMU   ,;
                  tmp->ismo    with schet->ismo   ,;
                  tmp->STR_CRB with schet->STR_CRB,;
                  tmp->krit    with fs_krit()
          select SCHET
          skip
        enddo
        select SCHET
        Use
        if recc == 0
          func_error(4,"Нет счетов по выбранной организации")
        else
          select TMP
          dbeval({|| tmp->name := inieditspr(A__POPUPMENU,dir_server+"l_ucher",tmp->lpu)})
          go top
          rest_box(buf24)
          if Alpha_Browse(r,2,maxrow()-2,77,"f1inp_schet",color0,;
                          k[2],"R/BG",.f.,,,,,,{'═','░','═',,,180} )
            glob_schet := tmp->kod
            glob_uch[1] := tmp->lpu
            glob_uch[2] := rtrim(tmp->name)
            fl := .t.
          endif
        endif
      endif*/
  endcase
endif
close databases
SetIniSect(tmp_ini,"schet",{{"number",mnomer},{"i",lstr(p_i)}})
if fl
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",dir_server+"schetk","SCHET")
  set relation to recno() into SCHET_
  find (str(glob_schet,6))
  box_shadow(rr,0,rr+7,33,color1,"Информация о счете",color8,0)
  setcolor(color8)
  @ rr+1,8 say "~~~~~~~~~~~~~~~~~~"
  setcolor(color1)
  @ rr+2,1 say "№ "+alltrim(schet_->NSCHET)+" от "+date_8(schet_->DSCHET)+"г."
  @ rr+3,1 say "Критерий: "+f3_view_list_schet() color "BG+/B"
  @ rr+4,1 say left(f4_view_list_schet(),33) color "G+/B"
  @ rr+5,1 say "Кол-во больных в счете: "+lstr(schet->kol)+" чел."
  @ rr+6,1 say "Сумма счета: "+expand_value(schet->summa,2)+" руб."
  schet_->(dbCloseArea())
  schet->(dbCloseArea())
endif
setcolor(tmp_color)
return fl

**
Function f1inp_schet(oBrow)
  Local oColumn

  oColumn := TBColumnNew("  Номер;  счета", {|| tmp->nomer_s })
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("  Дата;  счета", {|| tmp->date_s })
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Кол.;бол.", {|| tmp->kol })
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(" Сумма счета", {|| put_kop(tmp->summa, 12) })
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(" Критерий", {|| tmp->krit })
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(center("Принадлежность счета",24),{|| left(tmp->name, 24)})
  oBrow:addColumn(oColumn)
  return NIL

*****
Function fs_krit()
Local s := ""
if empty(schet_->NAME_XML)
  if schet->MEST_INOG == 5 .or. schet_->IS_MODERN == 1
    s := "законч.случай"
    if between(schet->RAB_NERAB,0,2)
      s := {"раб","нер","н/д"}[schet->RAB_NERAB+1]+"/"+s
    endif
  elseif schet_->IS_DOPLATA == 1 .and. schet_->IFIN == 2
    s := "ДОПЛАТА ФФОМС"
  elseif schet_->IS_DOPLATA == 1 .and. schet_->IFIN == 1
    s := "ДОПЛАТА ТФОМС"
  else
    if between(schet->RAB_NERAB,0,2)
      s := {"раб","нер","н/д"}[schet->RAB_NERAB+1]+"/"
    else
      s := space(4)
    endif
    if between(schet->MI_GIT,0,2)
      s += {"гор.","обл.","иног"}[schet->MI_GIT+1]
    endif
    if between(schet->vid_mp,0,6)
      s += "/"+{"амб.","стац","дс/п","дому","дс/б","стом","УДП"}[schet->vid_mp+1]
    endif
  endif
else
  if schet_->IS_MODERN == 1
    if right(rtrim(schet_->NSCHET),1)=='M'
      s := "законч.случай"
    else
      s := "УДП"
    endif
  endif
  if empty(s) .and. schet_->IFIN > 0
    s := "ОМС "
    if schet_->IFIN == 1
      s += "ТФОМС"
    elseif schet_->IFIN == 2
      s += "ФФОМС"
    endif
  endif
endif
return padr(s,13)

*****
Function func_kriterij()
Local s := ""
if empty(schet_->NAME_XML)
  if schet->MEST_INOG == 5 .or. schet_->IS_MODERN == 1
    s := "Критерий - по зак.случаям лечения"
  else
    if between(schet->VZROS_REB,0,2)
      s += "Критерий - "+{"взрослый","ребенок","подросток"}[schet->VZROS_REB+1]+"; "
    endif
    if between(schet->RAB_NERAB,0,2)
      s += {"Работающие","Неработающие","Нераб.дети"}[schet->RAB_NERAB+1]+"; "
    endif
    if between(schet->MI_GIT,0,2)
      s += {"Город","Область","Иногородние"}[schet->MI_GIT+1]+"; "
    elseif between(schet->MEST_INOG,0,2)
      s += "Финан-ие: "+{"Город","Область","Иногородние"}[schet->MEST_INOG+1]+"; "
    endif
    if between(schet->VID_MP,0,6)
      s += "/"+{"амб.","стац","дс/п","дому","дс/б","стом","УДП"}[schet->vid_mp+1]+";"
    endif
    if !empty(s)
      s := left(s,len(s)-2)
    endif
  endif
else
  if schet_->IS_MODERN == 1
    if right(rtrim(schet_->NSCHET),1)=='M'
      s := "Критерий - по зак.случаям лечения"
    else
      s := "Углубленная детская диспансеризация"
    endif
  endif
  if empty(s) .and. schet_->IFIN > 0
    s := "ОМС "
    if schet_->IFIN == 1
      s += "ТФОМС"
    elseif schet_->IFIN == 2
      s += "ФФОМС"
    endif
  endif
endif
return s

***** 21.03.14
Function save_arr_PredN(lkod)
Local arr := {}, k, ta
Private mvar
if type("mfio") == "C"
  aadd(arr,{"mfio",alltrim(mfio)})
endif
if type("mdate_r") == "D"
  aadd(arr,{"mdate_r",mdate_r})
endif
aadd(arr,{"1",mperiod}) // "N",номер диапазона (от 1 до 4)
aadd(arr,{"6",m1MO_PR}) // "C6",код МО прикрепления
aadd(arr,{"8",m1school}) // "N6",код образовательного учреждения
aadd(arr,{"9",m1tip_school}) // "N1",тип образовательного учреждения
aadd(arr,{"16.8",mGRUPPA})    // "N1",группа здоровья после дисп-ии
aadd(arr,{"16.9",m1GR_FIZ})    // "N1",группа здоровья для физкультуры
// 18.результаты проведения исследований
for i := 1 to count_predn_arr_iss
  mvar := "MREZi"+lstr(i)
  if !empty(&mvar)
    aadd(arr,{"18."+lstr(i),alltrim(&mvar)})
  endif
next
save_arr_DISPANS(lkod,arr)
return NIL

***** 14.08.13
Function read_arr_PredN(lkod)
Local arr, i, k
Private mvar
arr := read_arr_DISPANS(lkod)
for i := 1 to len(arr)
  if valtype(arr[i]) == "A" .and. valtype(arr[i,1]) == "C"
    do case
      case arr[i,1] == "1" .and. valtype(arr[i,2]) == "N"
        mperiod := arr[i,2]
      case arr[i,1] == "6" .and. valtype(arr[i,2]) == "C"
        m1MO_PR := arr[i,2]
      case arr[i,1] == "8" .and. valtype(arr[i,2]) == "N"
        m1school := arr[i,2]
      case arr[i,1] == "9" .and. valtype(arr[i,2]) == "N"
        m1tip_school := arr[i,2]
      case arr[i,1] == "16.8" .and. valtype(arr[i,2]) == "N"
        //mGRUPPA := arr[i,2]
      case arr[i,1] == "16.9" .and. valtype(arr[i,2]) == "N"
        m1GR_FIZ := arr[i,2]
      otherwise
        for k := 1 to count_predn_arr_iss
          if arr[i,1] == "18."+lstr(k) .and. valtype(arr[i,2]) == "C"
            mvar := "MREZi"+lstr(k)
            &mvar := padr(arr[i,2],17)
          endif
        next
    endcase
  endif
next
return NIL

***** 21.03.14
Function save_arr_PerN(lkod)
Local arr := {}, k, ta
Private mvar
if type("mfio") == "C"
  aadd(arr,{"mfio",alltrim(mfio)})
endif
if type("mdate_r") == "D"
  aadd(arr,{"mdate_r",mdate_r})
endif
aadd(arr,{"1",mperiod}) // "N",номер диапазона (от 1 до 4)
aadd(arr,{"6",m1MO_PR}) // "C6",код МО прикрепления
aadd(arr,{"8",m1school}) // "N6",код образовательного учреждения
aadd(arr,{"9",m1tip_school}) // "N1",тип образовательного учреждения
aadd(arr,{"10",m1protivo}) // "N1",противопоказания к продолжению учёбы
// 18.результаты проведения исследований
for i := 1 to count_pern_arr_iss
  mvar := "MREZi"+lstr(i)
  if !empty(&mvar)
    aadd(arr,{"18."+lstr(i),alltrim(&mvar)})
  endif
next
save_arr_DISPANS(lkod,arr)
return NIL

***** 25.08.13
Function read_arr_PerN(lkod)
Local arr, i, k
Private mvar
arr := read_arr_DISPANS(lkod)
for i := 1 to len(arr)
  if valtype(arr[i]) == "A" .and. valtype(arr[i,1]) == "C"
    do case
      case arr[i,1] == "1" .and. valtype(arr[i,2]) == "N"
        mperiod := arr[i,2]
      case arr[i,1] == "6" .and. valtype(arr[i,2]) == "C"
        m1MO_PR := arr[i,2]
      case arr[i,1] == "8" .and. valtype(arr[i,2]) == "N"
        m1school := arr[i,2]
      case arr[i,1] == "9" .and. valtype(arr[i,2]) == "N"
        m1tip_school := arr[i,2]
      case arr[i,1] == "10" .and. valtype(arr[i,2]) == "N"
        m1protivo := arr[i,2]
      otherwise
        for k := 1 to count_pern_arr_iss
          if arr[i,1] == "18."+lstr(k) .and. valtype(arr[i,2]) == "C"
            mvar := "MREZi"+lstr(k)
            &mvar := padr(arr[i,2],17)
          endif
        next
    endcase
  endif
next
return NIL

***** 19.09.13
Function save_arr_DISPANS(lkod,arr)
Local l, s, i, i1, i2, arr_d := {}, tmp_select := select()
if empty(arr) ; return NIL ; endif
use_base("mo_hdisp")
find (str(lkod,7))
do while hdisp->kod == lkod .and. !eof()
  aadd(arr_d, hdisp->(recno()) )
  skip
enddo
l := fieldlen(fieldnum("NAME")) // берём длину поля базы данных
s := SAVE_ARR_MEM(arr) // сохранение массива в символьной переменной
arr := {}
do while len(s) > 0
  aadd(arr, left(s,l))
  s := substr(s,l+1)
enddo
i1 := len(arr_d)
i2 := len(arr)
for i := 1 to i2
  if i > i1
    Add1Rec(7)
    hdisp->kod := lkod
  else
    goto (arr_d[i])
    G_RLock(forever)
  endif
  hdisp->ks := i
  hdisp->name := arr[i]
next
if i2 < i1
  for i := i2+1 to i1
    goto (arr_d[i])
    DeleteRec(.t.)
  next
endif
hdisp->(dbCloseArea())
select (tmp_select)
return NIL

***** 16.06.13
Function read_arr_DISPANS(lkod)
  Local s := "", tmp_select := select()

  use_base("mo_hdisp")
  find (str(lkod,7))
  do while hdisp->kod == lkod .and. !eof()
    s += hdisp->name
    skip
  enddo
  hdisp->(dbCloseArea())
  select (tmp_select)
  return REST_ARR_MEM(s) // востановление массива из символьной переменной s
