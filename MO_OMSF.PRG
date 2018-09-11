***** различные функции для задачи ОМС - mo_omsf.prg
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

Static Shodata_sem := "Работа с ходатайствами"
Static Shodata_err := "В данный момент с ходатайствами работает другой пользователь."

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
      glob_otd_dep := otd->CODE_DEP // код отделения по кодировке ТФОМС из справочника SprDep - 2018 год
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

***** 02.08.17 работало в 2017 году, в 2018 - закомментировано 
/*Function f_valid_metvmp(_metvmp)
if between(_metvmp,498,499)
  if !(mstentvmp $ "123")
    mstentvmp := ' '
  endif
  SetPos(p_nstr_stent,1)
  DispOut(p_str_stent,cDataCGet)
else             
  mstentvmp := ' '
  SetPos(p_nstr_stent,1)
  DispOut(space(len(p_str_stent)),cDataCGet)
endif  
return update_get("mstentvmp")*/ 

***** 13.02.18 
Function f_oms_beremenn(sdiag)
Static arr := {"O10","O11","O12","O13","O14","O15","O16",;
               "O20","O21","O22","O23","O24","O25","O26","O28",;
               "O30","O31","O32","O33","O36","O40","O41",;
               "O43","O44","O45","O46","O47","O98","O99",;
               "Z33","Z34","Z35","Z36"}
Local k := 0, j, c, s
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
if pr_ds_it == 0 .and. (j := ascan(arr_ad_cr_it,{|x| x[1] == padr(sdiag,5) })) > 0
  pr_ds_it := arr_ad_cr_it[j,2]
endif 
if eq_any(k,1,2) .and. type("m1USL_OK") == "N" .and. m1USL_OK == 4 // СМП
  k := 0
endif 
return k
              
***** 21.06.17
Function f_valid_beremenn(sdiag)
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
    if !between(m1prer_b,0,1)
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

***** 10.04.18
Function f_valid2ad_cr()
Static mm_st1 := {}, mm_dn1 := {}, mm_st2 := {}, mm_dn2 := {}
Static mm_bartel := {;
  {"индекс Бартела 60 баллов и менее","60"},;
  {"индекс Бартела более 60 баллов",  "61"}}
Static mm_it := {;
  {"не проводилась непрерывная искусственная вентиляция легких","   "},;
  {"it1-непрерывное проведение ИВЛ в течение 72 часов и более", "it1"},;
  {"it2-непрерывное проведение ИВЛ в течение 480 часов и более","it2"}}
Static mm_rb := {;
  {"не оценивалось состояние по Шкале Реабилитационной Маршрутизации","   "},;
  {"rb2 - оценка состояния пациента 2 балла по ШРМ", "rb2"},;
  {"rb3 - оценка состояния пациента 3 балла по ШРМ", "rb3"},;
  {"rb4 - оценка состояния пациента 4 балла по ШРМ", "rb4"},;
  {"rb5 - оценка состояния пациента 5 баллов по ШРМ","rb5"},;
  {"rb6 - оценка состояния пациента 6 баллов по ШРМ","rb6"},;
  {"rbs - медицинская реабилитация детей с нарушениями слуха","rbs"}}
Local i
Static sd1kv
input_ad_cr := .f. ; mm_ad_cr := {}
if m1usl_ok < 3 .and. m1vmp == 0
  if m1profil == 158 // реабилитация
    input_ad_cr := .t.
    aadd(mm_ad_cr,mm_rb[1])
    if m1usl_ok == 1
      aadd(mm_ad_cr,mm_rb[3])
      aadd(mm_ad_cr,mm_rb[4])
      aadd(mm_ad_cr,mm_rb[5])
      aadd(mm_ad_cr,mm_rb[6])
      aadd(mm_ad_cr,mm_rb[7])
    else
      aadd(mm_ad_cr,mm_rb[2])
      aadd(mm_ad_cr,mm_rb[3])
      aadd(mm_ad_cr,mm_rb[7])
    endif
  elseif eq_any(pr_ds_it,1,2) .and. m1usl_ok == 1
    input_ad_cr := .t.
    aadd(mm_ad_cr,mm_it[1])
    aadd(mm_ad_cr,mm_it[pr_ds_it+1])
  elseif pr_ds_it == 3
    input_ad_cr := .t.
    DEFAULT sd1kv TO stod("20180331")
    if m1usl_ok == 1
      if mk_data > sd1kv
        if empty(mm_st2)
          R_Use(exe_dir+"_mo8shema",,"IT")
          dbeval({|| aadd(mm_st2,{it->kod+it->name,it->kod}) },;
                 {|| it->ksg > 0 .and. between(mk_data,it->datebeg,it->dateend) })
          it->(dbCloseArea())
        endif
        mm_ad_cr := mm_st2
      else
        if empty(mm_st1)
          R_Use(exe_dir+"_mo8shema",,"IT")
          dbeval({|| aadd(mm_st1,{it->kod+it->name,it->kod}) },;
                 {|| it->ksg > 0 .and. between(mk_data,it->datebeg,it->dateend) })
          it->(dbCloseArea())
        endif
        mm_ad_cr := mm_st1
      endif
    else
      if mk_data > sd1kv
        if empty(mm_dn2)
          R_Use(exe_dir+"_mo8shema",,"IT")
          dbeval({|| aadd(mm_dn2,{it->kod+it->name,it->kod}) },{|| between(mk_data,it->datebeg,it->dateend) })
          it->(dbCloseArea())
        endif
        mm_ad_cr := mm_dn2
      else
        if empty(mm_dn1)
          R_Use(exe_dir+"_mo8shema",,"IT")
          dbeval({|| aadd(mm_dn1,{it->kod+it->name,it->kod}) },{|| between(mk_data,it->datebeg,it->dateend) })
          it->(dbCloseArea())
        endif
        mm_ad_cr := mm_dn1
      endif
    endif
  elseif pr_ds_it == 4
    input_ad_cr := .t.
    mm_ad_cr := mm_bartel
  endif
  if input_ad_cr
    if (i := ascan(mm_ad_cr,{|x| padr(x[2],10) == padr(m1ad_cr,10) })) > 0
      mad_cr := padr(mm_ad_cr[i,1],66) 
    else
      mad_cr := space(66) ; m1ad_cr := space(10)
    endif
    if type("p_nstr_ad_cr") == "N"
      @ p_nstr_ad_cr,1 say p_str_ad_cr
      update_get("mad_cr")
    endif
  endif
endif
return .t.               

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
  dbeval({|| iif(between_date(uch->dbegin,uch->dend,mdate), ;
                 aadd(a_uch,uch->(recno())), nil) })
else
  aadd(a_uch,mLPU)
endif
select OTD
dbeval({|| iif(between_date(otd->dbegin,otd->dend,mdate), ;
               aadd(pr_arr,{otd->(recno()),otd->name,otd->kod_lpu,""}), nil),;
           iif(mem_otdusl == 2, ;
               aadd(pr1arr_otd,{otd->(recno()),otd->name,otd->kod_lpu,""}), nil);
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

***** 25.01.16 вернуть код специальности из справочника V015 по коду из справочника V004 
Function ret_V004_V015(_PRVS)
Local i, ret := 0
if (i := ascan(glob_arr_V004_V015, {|x| x[1] == _PRVS })) > 0
  ret := glob_arr_V004_V015[i,2] 
endif
return ret 

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

***** 30.01.16 проверить, нулевая ли цена услуги в ТФОМС
Function NulUslugaTFOMS(lshifr1)
lshifr1 := alltrim(lshifr1)
return eq_any(left(lshifr1,2),"3.","4.","7.") .or. ;
       eq_any(left(lshifr1,5),"1.11.","2.60.","55.1.","71.1.") .or. ;
       eq_any(left(lshifr1,4),"2.3.","2.4.","2.5.","2.6.") .or. ;
       eq_any(left(lshifr1,3),"13.","14.","19.","20.","21.","22.") .or. ;
       between_shifr(lshifr1,"2.78.47","2.78.53") .or. between_shifr(lshifr1,"2.79.52","2.79.58") .or. ;
       between_shifr(lshifr1,"2.80.29","2.80.33") .or. between_shifr(lshifr1,"2.88.40","2.88.45")

***** 27.01.14 проверить, возможен ли ввод признака "на дому" для услуги ТФОМС
Function DomUslugaTFOMS(lshifr1)
return eq_any(left(lshifr1,5),"2.60.","2.79.","2.80.","2.88.") .or. left(lshifr1,4) == "2.3."

***** 30.07.15 является услуга для среднего медперсонала?
Function UslugaFeldsher(lshifr)
Static arr := {"2.57.1","71.1.1","71.2.1","2.3.3","2.3.4","2.60.3","2.60.4",;
               "2.78.28","2.78.29","2.78.36","2.78.39","2.78.40",;
               "2.79.19","2.79.20","2.79.34","2.79.37","2.79.38",;
               "2.79.49","2.79.50",;
               "2.80.12","2.80.13","2.80.19","2.80.22","2.80.23","2.80.27",;
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
  R_Use(dir_exe+"_mo_smo",cur_dir+"_mo_smo2","SMO")
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

***** сформировать справочник по настройке организации/учреждения/отделения
Function create_classif_FFOMS(reg,_name)
// reg - возврат кслассификатора для 0-организации/1-учреждения/2-отделения
Local i, k, arr, arr1, arr2, fl := .t., ret := {}, ret1
Private name_arr := "glob_"+_name
//
arr := GetIniVar(local_tools_ini,{{_name,'0',""}})
arr := list2arr(arr[1])
if len(arr) > 0
  ret := aclone(arr)
  if reg > 0
    arr1 := GetIniVar(local_tools_ini,{{_name,"1-"+lstr(glob_uch[1]),""}})
    arr1 := list2arr(arr1[1])
    if (k := len(arr1)) > 0
      for i := k to 1 step -1
        if ascan(ret,arr1[i]) == 0
          Del_Array(arr1,i)
        endif
      next
      ret := aclone(arr1)
    endif
    if reg == 2
      arr2 := GetIniVar(local_tools_ini,{{_name,"2-"+lstr(glob_otd[1]),""}})
      arr2 := list2arr(arr2[1])
      if (k := len(arr2)) > 0
        for i := k to 1 step -1
          if ascan(ret,arr2[i]) == 0
            Del_Array(arr2,i)
          endif
        next
        ret := aclone(arr2)
      endif
    endif
  endif
endif
if len(ret) > 0
  ret1 := {}
  for i := 1 to len(ret)
    if (k := ascan(&name_arr, {|x| x[2] == ret[i] })) > 0
      aadd(ret1, &name_arr.[k])
    endif
  next
elseif upper(_name) == "V002"
  ret1 := aclone(glob_V002)
else
  ret1 := cut_glob_array(&name_arr,sys_date)
endif
asort(ret1,,,{|x,y| upper(x[1]) < upper(y[1]) })
return ret1

***** вернуть первые два диагоноза для записи в XML-файл
Function diag_for_xml(al,fl_trim,fl_dop,fl_del,fl_6,adiag_talon)
Local mdiagnoz := diag_to_array(al,fl_trim,fl_dop,fl_del,fl_6,adiag_talon)
aadd(mdiagnoz,"") // чтобы был безусловно первый элемент
aadd(mdiagnoz,"") // чтобы был безусловно второй элемент
if empty(mdiagnoz[1]) // если пустой основной диагноз, заполним его
  mdiagnoz[1] := "Z01.8" // Другое уточнённое специальное обследование
endif
return mdiagnoz

***** 17.08.2018 вернуть диагнозы в массиве
Function diag_to_array(al,fl_trim,fl_dop,fl_del,fl_6,adiag_talon)
Local ad, _arr := {}, j, k, s, lshifr, dp, dp1, _ta, tmp_select := select()
DEFAULT al      TO "human", ; // alias БД листов учета
        fl_trim TO .f., ;     // удалять завершающие пробелы
        fl_dop  TO .f., ;     // дописывать букву
        fl_del  TO .t., ;     // удалять повторяющиеся диагнозы
        fl_6    TO .f.        // разрешать поиск шестизначных диагнозов
if empty(al)
  ad := {MKOD_DIAG ,;
         MKOD_DIAG2,;
         MKOD_DIAG3,;
         MKOD_DIAG4,;
         MSOPUT_B1 ,;
         MSOPUT_B2 ,;
         MSOPUT_B3 ,;
         MSOPUT_B4}
else        
  ad := {&al.->KOD_DIAG ,;
         &al.->KOD_DIAG2,;
         &al.->KOD_DIAG3,;
         &al.->KOD_DIAG4,;
         &al.->SOPUT_B1 ,;
         &al.->SOPUT_B2 ,;
         &al.->SOPUT_B3 ,;
         &al.->SOPUT_B4}
endif       
if fl_6
  if select("MKB_10") == 0
    R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
  endif
  select MKB_10
endif
for j := 1 to 8
  if iif(fl_del, !empty(ad[j]), .t.)
    lshifr := ad[j] ; dp := dp1 := ""
    if fl_trim
      lshifr := alltrim(lshifr)
    endif
    if adiag_talon != NIL
      s := adiag_talon[j*2-1]
      if eq_any(s,1,2)
        dp := iif(s == 1, "+", "-")
      endif
      s := adiag_talon[j*2]
      if s > 0
        dp += "д"+lstr(s)
      endif
    endif
    if !empty(al)
      k := substr(&al.->diag_plus,j,1)
      if fl_6 .and. !empty(k)
        find (ad[j]+k)
        if found() // если нашли шестизначный шифр
          lshifr := ad[j]+k
        endif
      endif
      if fl_dop .and. !empty(k) .and. k $ yes_d_plus
        dp1 := k
      endif
    endif
    aadd(_arr, {lshifr,dp+dp1})
  endif
next
_ta := {}
if fl_del // удалим из списка повторяющиеся диагнозы
  for j := 1 to len(_arr)
    if ascan(_ta, {|x| x == _arr[j,1] } ) == 0
      aadd(_ta, _arr[j,1] )
    endif
  next
  for j := 1 to len(_ta)
    s := ""
    for k := 1 to len(_arr)
      if _arr[k,1] == _ta[j]
        s += _arr[k,2]
      endif
    next
    _ta[j] += s
  next
else
  for j := 1 to len(_arr)
    aadd(_ta, _arr[j,1] + _arr[j,2])
  next
endif
if tmp_select > 0
  select (tmp_select)
endif
return _ta

***** 08.08.16 проверка на соответствие услуги профилю
Function UslugaAccordanceProfil(lshifr,lvzros_reb,lprofil,ta,short_shifr)
Local s := "", s1 := ""
if valtype(short_shifr)=="C" .and. !empty(short_shifr) .and. !(alltrim(lshifr)==alltrim(short_shifr))
  s1 := "("+alltrim(short_shifr)+")"
endif
if select("MOPROF") == 0
  R_Use(dir_exe+"_mo_prof",cur_dir+"_mo_prof","MOPROF")
  //index on shifr+str(vzros_reb,1)+str(profil,3) to (sbase)
endif
lshifr := padr(lshifr,20)
lvzros_reb := iif(lvzros_reb==0, 0, 1)
select MOPROF
find (lshifr)
if found() // если данная услуга участвует в проверке по профилю
  find (lshifr+str(lvzros_reb,1)+str(lprofil,3))
  if !found()
    find (lshifr+str(lvzros_reb,1))
    if human_->USL_OK == 4  // если скорая помощь
      if found()                // и нашли первый попавшийся профиль,
        lprofil := moprof->profil // то заменяем без всяких сообщений
      endif
    else // для всех остальных условий формируем сообщение об ошибке
      do while moprof->shifr==lshifr .and. moprof->vzros_reb==lvzros_reb .and. !eof()
        s += '"'+lstr(moprof->profil)+"."+inieditspr(A__MENUVERT, glob_V002, moprof->profil)+'", '
        skip
      enddo
      aadd(ta,rtrim(lshifr)+s1+' - профиль "'+lstr(lprofil)+"."+;
              inieditspr(A__MENUVERT, glob_V002, lprofil)+;
              '" для '+{'взрослого','ребёнка'}[lvzros_reb+1]+;
              ' недопустим'+iif(empty(s),"",' (разрешается '+left(s,len(s)-2)+')'))
    endif
  endif
endif
return lprofil

***** 08.08.16 проверка на соответствие услуги специальности
Function UslugaAccordancePRVS(lshifr,lvzros_reb,lprvs,ta,short_shifr,lvrach)
Local s := "", s1 := ""
if valtype(short_shifr)=="C" .and. !empty(short_shifr) .and. !(alltrim(lshifr)==alltrim(short_shifr))
  s1 := "("+alltrim(short_shifr)+")"
endif
if select("MOSPEC") == 0
  R_Use(dir_exe+"_mo_spec",cur_dir+"_mo_spec","MOSPEC")
  //index on shifr+str(vzros_reb,1)+str(prvs_new,4) to (sbase)
endif
lshifr := padr(lshifr,20)
lvzros_reb := iif(lvzros_reb==0, 0, 1)
if lprvs < 0
  lprvs := abs(lprvs)
else
  lprvs := ret_V004_V015(human_->PRVS)
endif
select MOSPEC
find (lshifr)
if found() // если данная услуга участвует в проверке по специальности
  find (lshifr+str(lvzros_reb,1)+str(lprvs,6))
  if !found()
    find (lshifr+str(lvzros_reb,1))
    // формируем сообщение об ошибке
    do while mospec->shifr==lshifr .and. mospec->vzros_reb==lvzros_reb .and. !eof()
      s += '"'+lstr(mospec->prvs_new)+"."+inieditspr(A__MENUVERT, glob_V015, mospec->prvs_new)+'", '
      skip
    enddo
    pers->(dbGoto(lvrach))
    aadd(ta,rtrim(lshifr)+s1+' - ('+fam_i_o(pers->fio)+' ['+lstr(pers->tab_nom)+;
            ']) специальность "'+lstr(lprvs)+'.'+;
            inieditspr(A__MENUVERT, glob_V015, lprvs)+;
            '" для '+{'взрослого','ребёнка'}[lvzros_reb+1]+;
            ' недопустима'+iif(empty(s),"",' (разрешается '+left(s,len(s)-2)+')'))
  endif
endif
return nil

***** 08.08.16 вернуть значение специальности в кодировке справочника V004
Function ret_old_prvs(new_kod)
Local i, old_kod := new_kod
if new_kod < 0
  new_kod := abs(new_kod)
  if (i := ascan(glob_arr_V004_V015, {|x| x[2] == new_kod })) > 0
    old_kod := glob_arr_V004_V015[i,1] 
  elseif (i := ascan(glob_arr_V015_V004, {|x| x[3] == new_kod })) > 0 
    old_kod := glob_arr_V015_V004[i,1]
  endif 
endif
return old_kod

***** 19.10.16 вернуть значение специальности в кодировке справочника V015
Function ret_new_prvs(_prvs)
Local new_kod
if _prvs < 0
  new_kod := abs(_prvs)
else
  new_kod := ret_V004_V015(_prvs)  
endif
return new_kod

***** 01.04.18 вернуть массив соответствий специальности V015 специальностям V0004
Function ret_arr_new_olds_prvs()
Local i, j, np, op, arr := {}
for i := 1 to len(glob_arr_V004_V015)
  op := glob_arr_V004_V015[i,1]
  np := glob_arr_V004_V015[i,2]
  if (j := ascan(arr, {|x| x[1] == np })) == 0
    aadd(arr, {np,{}}) ;  j := len(arr)
  endif
  aadd(arr[j,2], op)
next  
for i := 1 to len(glob_arr_V015_V004)
  op := glob_arr_V015_V004[i,1]
  np := glob_arr_V015_V004[i,3]
  if (j := ascan(arr, {|x| x[1] == np })) == 0
    aadd(arr, {np,{}}) ;  j := len(arr)
  endif
  aadd(arr[j,2], op)
next
return asort(arr,,,{|x,y| x[1] < y[1] })  

***** 08.02.17 вернуть значение специальности для XML-файла реестра
Function put_prvs_to_reestr(_PRVS,_YEAR)
Local k := _PRVS
if _YEAR < 2016
  k := ret_old_prvs(_PRVS)
else  
  if _PRVS < 0
    k := abs(_PRVS)
  else
    k := ret_V004_V015(_PRVS)
  endif 
endif
return lstr(k)

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
  R_Use(dir_exe+"_mo_uslz",cur_dir+"_mo_uslz","UZK")
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
  s := arr_pusl[i,1]+' ('+inieditspr(A__MENUVERT,glob_V002,arr_pusl[i,5])+;
       ") "+date_8(c4tod(arr_pusl[i,2]))+'г. оказана '
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

*****
Function f_arr_usl1()
Local i, s, arr := {}, arr1 := {}
if hb_fileExists(dir_server+"usl1year"+smem)
  arr := rest_arr(dir_server+"usl1year"+smem)
  for i := 1 to len(arr)
    select USL
    goto (arr[i])
    // заменить шифр услуги на услугу по кодировке ТФОМС
    if empty(s := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
      s := usl->shifr
    endif
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

***** 24.01.18 является ли данная услуга услугой ТФОМС
Function is_usluga_TFOMS(lshifr,lshifr1,ldate_usl,;
                         /*@*/arr_uet,/*@*/lbukva,/*@*/lst,/*@*/lidsp,/*@*/lvidpoms)
Local _shifr, tmp_select := select(), fl := .f., is_18, lal 
is_18 := (year(ldate_usl) > 2017)
if select("LUSL") == 0
  use_base("lusl")
endif
lal := iif(is_18, "lusl", "lusl17")
lst := 0 ; lvidpoms := "" ; lbukva := " "
_shifr := iif(empty(lshifr1), lshifr, lshifr1)
dbSelectArea(lal)
find (padr(_shifr,10))
if found() //.and. between_date(lusl->datebeg,lusl->dateend,ldate_usl)
  fl := .t.
  lbukva := alltrim(&lal.->bukva)
  if len(lbukva) != 1 // для 2018 года
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
  lal := iif(is_18, "luslf", "luslf17")
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

***** 24.01.18
Function ret_tfoms_uet(lshifr,lshifr1,lvzros_reb)
Local _shifr, tmp_select, luet := 0
_shifr := iif(empty(lshifr1), lshifr, lshifr1)
if left(_shifr,3) == "57."
  tmp_select := select()
  if select("LUSL") == 0
    use_base("lusl")
  endif
  select LUSL17
  find (padr(_shifr,10))
  if found()
    luet := iif(lvzros_reb==0,lusl17->uetv,lusl17->uetd)
  endif
  select (tmp_select)
endif
return luet

***** 04.09.17 проверка на код лабораторной услуги, направляемой в ЦКДЛ
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

***** 09.09.2018 редактировать другое направление (№...)
Function change_num_napr()
Local n, fl := .f., tmp_keys, tmp_gets, buf, tmp_color := setcolor()
if emptyany(mNAPR_DATE,m1NAPR_V)
  func_error(4,"Ещё не заполнено направление № "+lstr(cur_napr))
  return .t.
endif  
tmp_keys := my_savekey()
save gets to tmp_gets
buf := savescreen()
change_attr()
if (n := input_value(4,33,6,77,color5,"Добавление/редактирование направления №",cur_napr,"9")) == NIL
  // отказ
elseif eq_any(n,0,cur_napr)  
  // выбрали то же направление, что и редактируется
else
my_debug(,print_array({n,cur_napr,count_napr}))  
  if cur_napr == 0
    cur_napr := 1
  endif
  if select("TNAPR") == 0
    use (cur_dir+"tmp_onkna") new alias TNAPR
  else
    select TNAPR
  endif
  count_napr := lastrec()
  if cur_napr <= count_napr
    goto (cur_napr) // номер текущего направления
  else
    append blank
  endif
  tnapr->NAPR_DATE := mNAPR_DATE
  tnapr->NAPR_V := m1NAPR_V
  tnapr->MET_ISSL := m1MET_ISSL
  tnapr->U_KOD := mu_kod
  tnapr->shifr_u := mshifr
  tnapr->shifr1 := mshifr1
  tnapr->name_u := mname_u
  count_napr := lastrec()
  //
  if n <= count_napr
    cur_napr := n 
    goto (cur_napr) // номер текущего направления
    mNAPR_DATE := tnapr->NAPR_DATE
    m1NAPR_V := tnapr->NAPR_V
    m1MET_ISSL := iif(m1napr_v == 3, tnapr->MET_ISSL, 0)
    mu_kod := iif(m1napr_v == 3, tnapr->U_KOD, 0)
    mshifr := iif(m1napr_v == 3, tnapr->shifr_u, space(20))
    mshifr1 := iif(m1napr_v == 3, tnapr->shifr1, space(20))
    mname_u := iif(m1napr_v == 3, tnapr->name_u, space(65))
  else
    cur_napr := count_napr+1
    mNAPR_DATE := ctod("")
    m1NAPR_V := 0
    m1MET_ISSL := 0
    mu_kod := 0
    mshifr := space(20)
    mshifr1 := space(20)
    mname_u := space(65)
  endif 
  mNAPR_V := padr(inieditspr(A__MENUVERT, mm_napr_v, m1napr_v),30)
  mMET_ISSL := padr(inieditspr(A__MENUVERT, mm_MET_ISSL, m1MET_ISSL),45)
  tip_onko_napr := 0
endif                      
restscreen(buf)
restore gets from tmp_gets
my_restkey(tmp_keys)
setcolor(tmp_color)
setcursor()
return update_gets()

***** 10.09.2018
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

***** 09.09.2018
Function f_valid_tnm(g)
Local buf    
if !emptyany(m1ONK_T,m1ONK_N,m1ONK_M)
  select N6
  find (padr(mkod_diag,3))
  if found()
    find (padr(mkod_diag,3)+str(m1ONK_T,6)+str(m1ONK_N,6)+str(m1ONK_M,6))
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
endif
return .t.

***** 19.08.18
Function when_ds_onk()
Private yes_oncology := .f.
f_is_oncology(2)
return !yes_oncology

***** 20.08.18
Function f_is_oncology(r)
Local i, k, mdiagnoz, lprofil, lzno := 0
if r == 1
  mdiagnoz := diag_to_array()
  lprofil := human_->profil
  if human->OBRASHEN == '1'
    lzno := 1
  endif
else
  mdiagnoz := diag_to_array(" ")
  lprofil := m1profil
  lzno := m1ds_onk
endif
if empty(mdiagnoz)
  aadd(mdiagnoz,space(6))
endif
k := lzno  
if left(mdiagnoz[1],1) == "C"
  k := 2
elseif left(mdiagnoz[1],3) == "D70"
  for i := 2 to len(mdiagnoz)
    if left(mdiagnoz[i],1) == "C"
      if between(left(mdiagnoz[i],3),"C00","C80") .or. left(mdiagnoz[i],3) == "C97"
        k := 2
      endif
    endif
  next
endif
if k == 2
  yes_oncology := .t.
  m1ds_onk := 0 ; mds_onk := inieditspr(A__MENUVERT, mm_danet, m1ds_onk)
  if lprofil == 158
    k := 1
  endif
endif
return k

***** 22.08.18
Function f_valid_usl_tip(g,o)
if o != NIL .and. o != m1usl_tip
  lstr1 := space(12) ; m1usl_tip1 := 0 ;  musl_tip1 := space(69)
  lstr2 := space(13) ; m1usl_tip2 := 0 ;  musl_tip2 := space(19)
  lstr3 := space(3) ; mvsod := 0 ; msod := space(6)
  if between(m1usl_tip,1,4) 
    lstr1 := padr(mm_str1[m1usl_tip+1],12)
    if m1usl_tip == 1
      mm_usl_tip1 := mm_N014
    elseif m1usl_tip == 2 
      lstr2 := "Линия терапии"
      mm_usl_tip1 := mm_N016
      mm_usl_tip2 := mm_N015
      musl_tip2 := padr(mm_usl_tip2[1,1],19) ; m1usl_tip2 := mm_usl_tip2[1,2]
    elseif between(m1usl_tip,3,4) 
      mm_usl_tip1 := mm_N017
      lstr3 := "СОД"
      msod := padr(alltrim(str_0(mvsod,6,2)),6)
    endif
    musl_tip1 := padr(mm_usl_tip1[1,1],69) ; m1usl_tip1 := mm_usl_tip1[1,2]
  endif
  update_get("lstr1")
  update_get("musl_tip1")
  update_get("lstr2")
  update_get("musl_tip2")
  update_get("lstr3")
  update_get("msod")
endif
return .t.

***** 06.08.18
Function is_usluga_disp_nabl(_shifr,_shifr1)
if empty(_shifr1)
  _shifr := alltrim(_shifr)
else
  _shifr := alltrim(_shifr1)
endif  
return between_shifr(_shifr,"2.78.61","2.78.84") .or. between_shifr(_shifr,"2.88.52","2.88.75")

***** 18.08.18 функция для when и valid при вводе услуг в лист учёта
Function f5editkusl(get,when_valid,k)
Local fl := .t., s, i, lu_cena, lshifr1, v, old_kod, amsg, arr_zf, fl1, fl2, ;
      msg1_err := "Код врача равен коду ассистента! Это недопустимо.",;
      msg2_err := "Человека с таким кодом нет в базе данных персонала!",;
      blk_sum := {|| mstoim_1 := round_5(mu_cena * mkol_1, 2) }
if when_valid == 1    // when
  if k == 2     // Шифр услуги
    if !empty(mshifr)
      fl := .f.
    endif
  elseif k == 3 // Код врача
    fl := vr_uva
  elseif k == 4 // Код ассистента
    fl := as_uva
  elseif k == 5 // Количество услуг
    if empty(mshifr)
      fl := .f.
    endif
  elseif k == 10  // код отделения
    SetKey( K_F3, {|p,l,v| get1_otd(p,l,v,get:Row,get:Col)} )
    @ r1,45 say "<F3> - выбор отделения из меню" color color13
  endif
else  // valid
  if k == 1     // Дата оказания услуги
    if !emptyany(human->n_data,mdate_u1) .and. mdate_u1 < human->n_data
      fl := func_error(4,"Введенная дата меньше даты начала лечения!")
    elseif !emptyany(human->k_data,mdate_u1) .and. mdate_u1 > human->k_data
      fl := func_error(4,"Введенная дата больше даты окончания лечения!")
    endif
    if fl .and. is_zf_stomat == 1 .and. !empty(mzf)
      // перепрыгнуть на ввод шифра услуги
      keyboard chr(K_TAB)
    endif
  elseif k == 2 // Шифр услуги
    if !empty(mshifr) .and. !(mshifr == get:original)
      mshifr := transform_shifr(mshifr)
      // сначала проверим на код лаб.услуги, направляемой в ЦКДЛ
      if is_lab_usluga(mshifr) .and. !(type("is_oncology") == "N")
        fl := .f.
        if f1cena_oms(mshifr,;
                      mshifr,;
                      (human->vzros_reb==0),;
                      human->k_data,;
                      .t.,;
                      @mis_oms) == NIL
          select LUSL
          find (padr(mshifr,10))
          if found()
            func_error(4,"Данная лабораторная услуга не разрешена для использования в Вашей МО")
          else
            func_error(4,"Введена несуществующая лабораторная услуга")
          endif
          mshifr := space(20)               
        else // услуга разрешена данной МО
          if select("MOPROF") == 0
            R_Use(dir_exe+"_mo_prof",cur_dir+"_mo_prof","MOPROF")
            //index on shifr+str(vzros_reb,1)+str(profil,3) to (sbase)
          endif
          m1profil := iif(left(mshifr,5) == "4.16.", 6, 34)
          select MOPROF
          find (padr(mshifr,20)+str(iif(human->vzros_reb == 0, 0, 1),1))
          if found()                
            m1profil := moprof->profil
          endif
          select USL
          set order to 1
          find (padr(mshifr,10))
          if found() // уже занесена в наш справочник услуг
            mu_kod  := usl->kod
          else // не занесена в наш справочник услуг
            mu_kod := foundOurUsluga(mshifr,human->k_data,m1PROFIL,human->VZROS_REB,@mu_cena,2)
            select USL
            set order to 0
            goto (mu_kod)
          endif
          mname_u := usl->name
          mn_base := 0
          mstoim_1 := mu_cena := 0
          mis_nul := .t.
          mis_edit := -1 // т.е. лаб.услуга направлена в ЦКДЛ
          mu_koef := 1
          mPROFIL := padr(inieditspr(A__MENUVERT, glob_V002, m1PROFIL),69)
          mkod_vr := mtabn_vr := 0 ; mvrach := space(35)
          mkod_as := mtabn_as := 0 ; massist := space(35)
          mkol := mkol_1 := 1
          fl := update_gets()
        endif
        return fl
      endif
      // сначала проверим на код операции ФФОМС
      fl1 := fl2 := .f.
      select LUSLF
      find (padr(mshifr,20))
      if found() .and. alltrim(mshifr) == alltrim(luslf->shifr)
        tip_onko_napr := luslf->onko_napr
        tip_onko_ksg := luslf->onko_ksg
        fl1 := .t.
        select MOSU
        set order to 3
        find (padr(mshifr,20)) // поищем федеральный код операции ФФОМС
        if found()
          if mosu->tip == 0 // проверяем, что ЭТО НЕ стоматология 2016 (удалённая)
            mu_kod  := mosu->kod
            mname_u := mosu->name
            mshifr1 := mosu->shifr1
            if !empty(mosu->profil)
              m1PROFIL := mosu->profil
              mPROFIL := padr(inieditspr(A__MENUVERT, glob_V002, m1PROFIL),69)
            endif
          else // Старая стоматология 2016
            fl1 := .f.
            fl2 := .T.
          endif
        else
          mu_kod  := 0
          mname_u := left(luslf->name,65)
          mshifr1 := mshifr
        endif
      endif
      if !fl1 // не нашли в операциях ФФОМС
        select MOSU
        set order to 2
        find (padr(mshifr,10)) // поищем собственный код операции ФФОМС
        if found()
          if mosu->tip == 0 // проверяем, что ЭТО НЕ стоматология 2016 (удалённая)
            fl1 := .t.
            mu_kod  := mosu->kod
            mname_u := mosu->name
            mshifr1 := mosu->shifr1
            if !empty(mosu->profil)
              m1PROFIL := mosu->profil
              mPROFIL := padr(inieditspr(A__MENUVERT, glob_V002, m1PROFIL),69)
            endif
          else // Старая стоматология 2016
            fl1 := .f.
            fl2 := .T.
          endif
        endif
      endif
      if fl1
        mn_base := 1
        mstoim_1 := mu_cena := 0
        mis_nul := .t.
        mkol := mkol_1 := 1
        verify_uva(2)
        update_gets()
        if type("row_dom") == "N"
          m1dom := 0 ; mdom := space(20)
          @ row_dom,1 say space(78) color color1
        endif
        return fl  // !!!!!!!!!!!!!!!!!!!!!
      endif
      if type("is_oncology") == "N"
        if !empty(mshifr)
          fl := func_error(4,"Такого шифра нет в базе данных услуг.")
        endif
        return fl
      endif
      if fl2
        fl := func_error(4,"Данную СТОМАТОЛОГИЧЕСКУЮ услугу запрещено вводить после 2016г!")
      else // теперь проверим по старому алгоритму
        select USL
        set order to 1
        find (padr(mshifr,10))
        if found()
          lu_cena := iif(human->vzros_reb==0, usl->cena, usl->cena_d)
          lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          if (v := f1cena_oms(usl->shifr,;
                              lshifr1,;
                              (human->vzros_reb==0),;
                              human->k_data,;
                              usl->is_nul,;
                              @mis_oms)) != NIL
            lu_cena := v
          endif
          fl1 := .t.
          if empty(lu_cena)
            fl1 := .f.
            if NulUslugaTFOMS(iif(empty(lshifr1), usl->shifr, lshifr1))
              fl1 := .t.
            else
              fl1 := usl->is_nul
            endif
          endif
          if !fl1
            fl := func_error(4,"В данной услуге не проставлена цена!")
          else
            if mem_otdusl==2 .and. type("pr1arr_otd")=="A"
              // автоматическое присвоение отделения по месту работы персонала
              fl := .t.
            else
              select UO
              find (str(usl->kod,4))
              if found() .and. !(chr(m1otd) $ uo->otdel)
                fl := func_error(4,"Данную услугу запрещено вводить в данном отделении!")
              endif
            endif
            if fl
              mu_kod  := usl->kod
              mname_u := usl->name
              mshifr1 := lshifr1
              mu_cena := lu_cena
              mis_nul := usl->is_nul
              mu_koef := 1
              if mis_nul  // услуга с нулевой ценой
                mu_cena := 0
              endif
              mkol := mkol_1 := 1
              fl_date_next := is_usluga_disp_nabl(mshifr,mshifr1)
              if !empty(usl->profil)
                m1PROFIL := usl->profil
                mPROFIL := padr(inieditspr(A__MENUVERT, glob_V002, m1PROFIL),69)
              endif
              eval(blk_sum)
              verify_uva(2)
              update_gets()
              if type("row_dom") == "N" .and. !DomUslugaTFOMS(iif(empty(lshifr1), usl->shifr, lshifr1))
                m1dom := 0 ; mdom := space(20)
                @ row_dom,1 say space(34) color color1
              endif
              if type("row_dom") == "N" .and. !fl_date_next
                mdate_next := ctod("")
                @ row_dom,35 say space(42) color color1
              endif
              if is_zf_stomat == 1 .and. !empty(mzf)
                usl->(dbGoto(mu_kod)) // на всякий случай
                if usl->zf == 0
                  //n_message({"В данную услугу запрещен ввод зубной формулы!",;
                  //           "(Не будет записана)"},,"W/G","N/G",,,"GR/G")
                endif
              endif
              if !empty(arr_usl1year)
                f_usl1year(iif(empty(mshifr1),mshifr,mshifr1),mshifr,mname_u)
              endif
            endif
          endif
        elseif get_k_usluga(mshifr,human->vzros_reb,@fl)
          box_shadow(r1-5,40,r1-3,77,cColorStMsg,;
                     "Комплексная услуга",cColorSt2Msg)
          @ r1-4,41 say padc("Количество услуг - "+lstr(len(pr_k_usl)),36) color cColorStMsg
          mkol := mkol_1 := 1
          if fl  // сменить код врача и ассистента
            mvrach := space(35)
            mtabn_vr := 0
            if mkod_vr > 0
              select PERSO
              goto (mkod_vr)
              if !eof() .and. !deleted()
                mvrach := padr(perso->fio,35)
                mtabn_vr := perso->tab_nom
              endif
            endif
            massist := space(35)
            mtabn_as := 0
            if mkod_as > 0
              select PERSO
              goto (mkod_as)
              if !eof() .and. !deleted()
                massist := padr(perso->fio,35)
                mtabn_as := perso->tab_nom
              endif
            endif
          endif
          fl := update_gets()
        else
          fl := func_error(4,"Такого шифра нет в базе данных услуг.")
        endif
      endif
    endif
  elseif k == 3 // Код врача
    old_kod := mkod_vr
    if empty(mtabn_vr)
      mkod_vr := 0
      mvrach := space(35)
    else
      select PERSO
      find (str(mtabn_vr,5))
      if found()
        if type("mkod_as") == "N" .and. perso->kod == mkod_as
          fl := func_error(4,msg1_err)
        elseif mem_kat_va == 2 .and. perso->kateg != 1 .and. ;
                    !UslugaFeldsher(iif(empty(mshifr1),mshifr,mshifr1))
          fl := func_error(4,"Данный сотрудник не является ВРАЧОМ по штатному расписанию")
        else
          mkod_vr := perso->kod
          m1prvs := -ret_new_spec(perso->prvs,perso->prvs_new)
          mvrach := padr(fam_i_o(perso->fio)+" "+ret_tmp_prvs(m1prvs),57)
        endif
      else
        fl := func_error(4,msg2_err)
      endif
    endif
    if old_kod != mkod_vr
      update_get("mvrach")
    endif
  elseif k == 4 // Код ассистента
    old_kod := mkod_as
    if empty(mtabn_as)
      mkod_as := 0
      massist := space(35)
    else
      select PERSO
      find (str(mtabn_as,5))
      if found()
        if perso->kod == mkod_vr
          fl := func_error(4,msg1_err)
        elseif mem_kat_va == 2 .and. perso->kateg != 2
          fl := func_error(4,"Данный сотрудник не является СРЕДНИМ МЕД.ПЕРСОНАЛОМ по штатному расписанию")
        else
          mkod_as := perso->kod
          massist := padr(perso->fio,35)
        endif
      else
        fl := func_error(4,msg2_err)
      endif
    endif
    if old_kod != mkod_as
      update_get("massist")
    endif
  elseif k == 5 // Количество услуг
    if mkol_1 != get:original
      eval(blk_sum)
      update_get("mstoim_1")
    endif
  elseif k == 10  // код отделения
    if (i := ascan(pr_arr, {|x| x[1] == m1otd } )) > 0
      if type("mu_kod") == "N" .and. mu_kod > 0 .and. mn_base == 0
        select UO
        find (str(mu_kod,4))
        if found() .and. !(chr(m1otd) $ uo->otdel)
          fl := func_error(4,"Данную услугу запрещено вводить в данном отделении!")
        endif
      endif
      if fl
        motd := pr_arr[i,2] ; update_get("motd")
        SetKey( K_F3, NIL )
        @ r1,45 say space(30) color color13
      endif
    else
      fl := func_error(4,"Данный код отделения не найден!")
    endif
  elseif k == 101  // зубная формула
    if !empty(mzf)
      amsg := {}
      if mu_kod > 0 .and. mn_base == 0
        usl->(dbGoto(mu_kod))
        if usl->zf == 0
          aadd(amsg, "В данную услугу запрещен ввод зубной формулы!")
        endif
      endif
      arr_zf := STverifyZF(mzf,human->date_r,human->n_data,@amsg)
      if len(arr_zf) > 0
        if empty(mkod_diag)
          aadd(amsg, 'Не введен диагноз!')
        endif
        STverDelZub(human->kod_k,arr_zf,dtoc4(mdate_u1),iif(mn_base==0,1,7),mrec_hu,@amsg)
        if len(amsg) > 0
          n_message(amsg,,"W/G","N/G",,,"GR/G")
        endif
      endif
    endif
  endif
  if !fl
    &(readvar()) := get:original
  elseif equalany(k,3,4) .and. mem_otdusl==2 .and. type("pr1arr_otd")=="A"
    if (old_kod := mkod_vr) == 0
      old_kod := mkod_as
    endif
    if old_kod > 0 .and. mn_base == 0
      select PERSO
      goto (old_kod)
      if iif(yes_many_uch, .t., perso->uch == glob_uch[1]) .and. ;
              perso->otd > 0 .and. ;
                (i := ascan(pr1arr_otd,{|x| x[1] == perso->otd})) > 0
        select UO
        find (str(mu_kod,4))
        if found() .and. !(chr(perso->otd) $ uo->otdel)
          fl := func_error(4,'Данную услугу запрещено вводить в отделении "'+alltrim(pr1arr_otd[i,2])+'"!')
          &(readvar()) := get:original
        else
          m1otd := perso->otd ; motd := pr1arr_otd[i,2]
          update_get("m1otd") ; update_get("motd")
        endif
      else
        &(readvar()) := get:original
        if iif(yes_many_uch, .t., perso->uch == glob_uch[1])
          fl := func_error(4,"Не проставлено отделение, в котором работает данный человек!")
        else
          fl := func_error(4,"Данный человек работает в другом учреждении!")
        endif
      endif
    endif
  endif
endif
return fl

*

*****
Function f_usl1year(lshifr,_mshifr,_mname)
Local k := 0, c, s, tmp_select := select(), buf := save_maxrow(),;
      rec_human := human->(recno()), rec_hu := hu->(recno()),;
      lyear := year(mdate_u1), lshifr_
lshifr := padr(lshifr,10) // на всякий случай сделаем ширину 10 сиволов
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

*

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

*

***** 13.01.18
Function fcena_oms(sShifr,lVzReb,dDate,/*@*/fl_delete,/*@*/fl_yes,/*@*/_ifin)
Local i, v, tmp_select := select(), lvr, nu, lal, s := glob_mo[_MO_KOD_TFOMS]
sShifr := padr(sShifr,10)
if valtype(dDate) == "D"
  dDate := {dDate}
endif
if !empty(glob_podr) .and. year(dDate[1]) == 2017
  s := padr(glob_podr,6) // заменяем на код адреса подразделения
endif
lvr := iif(lVzReb,0,1)
for i := 1 to len(dDate)
  v := 0
  nu := get2uroven(sShifr,get_uroven(dDate[i]))
  _ifin := 0
  fl_delete := .t. ; fl_yes := .f.
  lal := "luslc"
  if year(dDate[i]) < 2016
   lal += "14"
  elseif year(dDate[i]) < 2018
   lal += "15"
  endif
  dbselectarea(lal)
  if year(dDate[1]) > 2017 // 2018 год
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
  elseif nu > 3 // работаем с индивидуальными тарифами
    set order to 2
    find (s+sShifr+str(lvr,1))
    do while sShifr == &lal.->shifr .and. &lal.->CODEMO == s .and. &lal.->VZROS_REB == lvr .and. !eof()
      fl_yes := .t.
      if between_date(&lal.->datebeg,&lal.->dateend,dDate[i]) // поиск цены по дате окончания лечения
        fl_delete := .f.
        v := &lal.->CENA ; exit
      endif
      skip
    enddo
  else // уровни с 1 по 3
    set order to 1
    find (sShifr+str(nu,1)+str(lvr,1))
    do while sShifr == &lal.->shifr .and. &lal.->uroven == nu .and. &lal.->VZROS_REB == lvr .and. !eof()
      fl_yes := .t.
      if between_date(&lal.->datebeg,&lal.->dateend,dDate[i]) // поиск цены по дате окончания лечения
        fl_delete := .f.
        v := &lal.->CENA ; exit
      endif
      skip
    enddo
  endif
  set order to 1
  if empty(v)
    exit
  endif
next
select (tmp_select)
return v

*

***** 24.01.13
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

*

***** Группы МКБ + услуги по стандартам
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

*

***** сделать единую строку полиса из полей серии и номера полиса
Function make_polis(_spolis,_npolis)
Local s := alltrim(_spolis)
if !empty(s)
  s += " "
endif
return s+alltrim(_npolis)

*

***** вывести наименование диагноза при вводе случая
Function diag_screen(k,arr_d)
Static buf_d
Local i, lc, r := 12
if type("row_diag_screen") == "N" .and. row_diag_screen > 0
  r := row_diag_screen
endif
if k == 0 // обнулить буфер
  buf_d := nil
elseif k == 1 // если надо, отрисовать прямоугольник, и вывести диагноз
  if buf_d == nil
    buf_d := box_shadow(r,3,r+5,76,"N/RB","Диагноз","W/RB")
  endif
  for i := 1 to len(arr_d)
    lc := if("в ОМС" $ arr_d[i] .or. "по полу" $ arr_d[i], "GR+/RB", "W+/RB")
    @ r+i,5 say padr(arr_d[i],71) color lc
  next
elseif k == 2 // восстановить экран  и обнулить буфер
  if buf_d != nil
    rest_box(buf_d)
  endif
  buf_d := nil
endif
return .t.

*

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

*

***** сделать "пяти или шести-значные" диагнозы
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

*

***** сформировать номер амбулаторной карты
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
Static sF11 := "^<F11>^ читать электронный полис"
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

*

***** выбор карточки из картотеки
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

***** 10.09.18 есть ли листы учёта по данному пациенту
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
    if empty(human_->reestr) // если человек в данный момент лечится
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

*

***** 14.03.16 поиск по шаблону в картотеке
Function fvalid_fio(lregim,input_sh,fl_number,mbukva)
Local fl := .f., pos1, pos2, tmp_list, buf, ;
      tmp2 := "", c1, fl_bukva, s_msg, rec_tmp := 0
DEFAULT lregim TO 1, mbukva TO ""
if !myFileDeleted(cur_dir+"tmp_kart"+sdbf)
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
dbcreate(cur_dir+"tmp_kart",{{"kod","N",7,0},;
                     {"fio","C",50,0},;
                     {"mest_inog","N",1,0},;
                     {"bukva","C",1,0},;
                     {"uchast","N",2,0},;
                     {"kod_vu","N",5,0},;
                     {"kod_AK","C",6,0}} )
use (cur_dir+"tmp_kart") new alias TMP
index on upper(fio) to (cur_dir+"tmp_kart")
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
  use (cur_dir+"tmp_kart") index (cur_dir+"tmp_kart") new alias TMP
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
  blk := {|| iif(kart2->mo_pr==glob_MO[_MO_KOD_TFOMS], {1,2},;
                           iif(empty(kart2->mo_pr), {3,4}, {5,6})) }
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
oColumn := TBColumnNew(center("Ф.И.О.",49),{||padr(tmp->fio,49)})
oBrow:addColumn(oColumn)
status_key("^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор")
return NIL

*****
Function f2_v_fio()
kartotek_to_screen(14,23)
if !(type("dubl1_kart") == "N")
  select TMP
endif
return NIL

*

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
if !myFileDeleted(cur_dir+"tmp"+sdbf)
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
        dbcreate(cur_dir+"tmp",adbf_tmp)
        Use (cur_dir+"tmp") new alias TMP
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
            index on descend(dtos(date_s)) to (cur_dir+"tmp")
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
        dbcreate(cur_dir+"tmp",adbf_tmp)
        Use (cur_dir+"tmp") new alias TMP
        index on descend(date_s) to (cur_dir+"tmp")
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

*****
Function f1inp_schet(oBrow)
Local oColumn
oColumn := TBColumnNew("  Номер;  счета", {|| tmp->nomer_s })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Дата;  счета", {|| tmp->date_s })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол.;бол.", {|| tmp->kol })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Сумма счета", {|| put_kop(tmp->summa,12) })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Критерий", {|| tmp->krit })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(center("Принадлежность счета",24),{|| left(tmp->name,24)})
oBrow:addColumn(oColumn)
return NIL

*

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

*

***** 03.02.13 оформление ходатайства
Function TFOMS_hodatajstvo(arr_m,iRefr,par)
Local buf24 := save_maxrow(), t_arr[BR_LEN], blk
if !myFileDeleted(cur_dir+"tmp_k"+sdbf)
  return NIL
endif
mywait()
dbcreate(cur_dir+"tmp_k",{{"kod","N",7,0},;
                          {"kod_lu","N",7,0},;
                          {"k_data","D",8,0},;
                          {"is","N",1,0}})
use (cur_dir+"tmp_k") new
R_Use(dir_server+"human",,"HUMAN")
use (cur_dir+"tmp_h") new
go top
do while !eof()
  if tmp_h->REFREASON == iRefr
    human->(dbGoto(tmp_h->kod))
    select TMP_K
    append blank
    replace kod with human->kod_k,;
            kod_lu with human->(recno()),;
            k_data with human->k_data,;
            is with 1
  endif
  select TMP_H
  skip
enddo
close databases
if par == 1
  return create_file_hodatajstvo(arr_m)
endif
//
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
use (cur_dir+"tmp_k") new alias TMP
set relation to kod into KART, to kod into KART_
index on upper(kart->fio) to (cur_dir+"tmp_k")
rest_box(buf24)
//
t_arr[BR_TOP] := 2
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "Выбор пациентов для оформления ходатайства"
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
blk := {|| iif(tmp->is==1, {1,2}, {3,4}) }
t_arr[BR_COLUMN] := {{ ' ', {|| iif(tmp->is==1, '', ' ') },blk },;
                     { center("ФИО",30), {|| padr(kart->fio,30) },blk },;
                     { " ",{|| kart->pol },blk },;
                     { "Дата рожд.",{|| full_date(kart->date_r) },blk },;
                     { " Адрес",{|| padr(ret_okato_ulica(kart->adres,kart_->okatog,,2),26) },blk }}
t_arr[BR_EDIT] := {|nk,ob| f1tfoms_hodatajstvo(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход для редактирования и печати;  ^<+,-,Ins>^ отметить пациента для печати") }
go top
Private ob_kol := tmp->(lastrec())
edit_browse(t_arr)
if ob_kol > 0
  delFRfiles()
  adbf := {{"name","C",80,0},;
           {"predst","C",40,0},;
           {"data","C",10,0}}
  dbcreate(fr_titl, adbf)
  use (fr_titl) new alias FRT
  append blank
  frt->name   := glob_mo[_MO_SHORT_NAME]
  frt->predst := ""
  frt->data   := full_date(sys_date)
  //
  adbf := {{"fio","C",30,0},;
           {"fam","C",40,0},;
           {"ima","C",40,0},;
           {"ots","C",40,0},;
           {"pol_m","C",1,0},;
           {"pol_g","C",1,0},;
           {"date_r","C",10,0},;
           {"mesto_r","C",100,0},;
           {"vpasport","C",50,0},;
           {"spasport","C",10,0},;
           {"npasport","C",20,0},;
           {"dpasport","C",10,0},;
           {"gragd","C",40,0},;
           {"snils","C",14,0},;
           {"iadres","C",6,0},;
           {"sadres","C",40,0},;
           {"radres","C",40,0},;
           {"gadres","C",40,0},;
           {"nadres","C",40,0},;
           {"ulica","C",50,0},;
           {"dom","C",10,0},;
           {"korp","C",10,0},;
           {"kvar","C",10,0},;
           {"phone","C",20,0},;
           {"email","C",40,0},;
           {"is","N",1,0}}
  dbcreate(fr_data,adbf)
  use (fr_data) new alias FRD
  select TMP
  go top
  do while !eof()
    if tmp->is == 1
      arr := retFamImOt(1,.f.)
      select FRD
      append blank
      frd->fio := fam_i_o(kart->fio,arr)
      frd->fam := arr[1]
      frd->ima := arr[2]
      frd->ots := arr[3]
      frd->pol_m := iif(kart->pol=="М",'√',' ')
      frd->pol_g := iif(kart->pol=="М",' ','√')
      frd->date_r := full_date(kart->date_r)
      frd->mesto_r := kart_->mesto_r
      frd->vpasport := inieditspr(A__MENUVERT, glob_F011, kart_->vid_ud)
      frd->spasport := kart_->ser_ud
      frd->npasport := kart_->nom_ud
      frd->dpasport := full_date(kart_->kogdavyd)
      if !(empty(kart_->strana) .or. kart_->strana=='643')
        frd->gragd := inieditspr(A__MENUVERT, glob_O001, kart_->strana)
      endif
      if !empty(kart->SNILS)
        frd->snils := transform(kart->SNILS,picture_pf)
      endif
      frd->iadres := ""
      arr := ret_okato_Array(kart_->okatog)
      frd->sadres := arr[1]
      frd->radres := arr[2]
      frd->gadres := arr[3]
      frd->nadres := arr[4]
      frd->ulica := kart->adres
      frd->dom := ""
      frd->korp := ""
      frd->kvar := ""
      frd->phone := kart_->PHONE_W
      frd->email := ""
    endif
    select TMP
    skip
  enddo
  //
  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := maxrow()-2
  t_arr[BR_LEFT] := 2
  t_arr[BR_RIGHT] := 77
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := "Редактирование пациентов для оформления ходатайства"
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
  blk := {|| iif(frd->is==1, {1,2}, {3,4}) }
  t_arr[BR_COLUMN] := {{ center("ФИО",20), {|| padr(fio,20) },blk },;
                       { "Дата рожд.",{|| full_date(date_r) },blk },;
                       { " Улица",{|| padr(ulica,40) },blk }}
  t_arr[BR_EDIT] := {|nk,ob| f2tfoms_hodatajstvo(nk,ob,"edit") }
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - редактирование адреса;  ^<F9>^ - печать ходатайств") }
  select FRD
  go top
  edit_browse(t_arr)
  close databases
endif
close databases
return NIL

*****
Function f1tfoms_hodatajstvo(nKey,oBrow,regim)
Local k := -1, rec, fl
if regim == "edit"
  do case
    case nkey == K_INS
      replace tmp->is with if(tmp->is==1,0,1)
      if tmp->is==1
        ob_kol++
      else
        ob_kol--
      endif
      k := 0
      keyboard chr(K_TAB)
    case nkey == 43 .or. nkey == 45  // + или -
      fl := (nkey == 43)
      rec := recno()
      tmp->(dbeval({|| tmp->is := iif(fl,1,0) }))
      goto (rec)
      if fl
        ob_kol := tmp->(lastrec())
      else
        ob_kol := 0
      endif
      k := 0
  endcase
endif
return k

*****
Function f2tfoms_hodatajstvo(nKey,oBrow,regim)
Local k := -1, rec, fl, buf := savescreen()
if regim == "edit"
  do case
    case nkey == K_ENTER
      Private miadres := frd->iadres,;
              msadres := frd->sadres,;
              mradres := frd->radres,;
              mgadres := frd->gadres,;
              mnadres := frd->nadres,;
              mulica  := frd->ulica ,;
              mdom    := frd->dom   ,;
              mkorp   := frd->korp  ,;
              mkvar   := frd->kvar  ,;
              mphone  := frd->phone ,;
              memail  := frd->email ,;
              mpredst := frt->predst,;
              mdata   := frt->data
      r := 8
      setcolor(cDataCGet)
      ClrLines(r,23)
      @ r,0 to r,79
      str_center(r,alltrim(frd->fio))
      ++r
      ++r ; @ r,1 say "Почтовый индекс" get miadres
      ++r ; @ r,1 say "Регион" get msadres when .f.
      ++r ; @ r,1 say "Район" get mradres
      ++r ; @ r,1 say "Город" get mgadres
      ++r ; @ r,1 say "Село" get mnadres
      ++r ; @ r,1 say "Улица" get mulica
      ++r ; @ r,1 say "Дом" get mdom
      ++r ; @ r,1 say "Корпус" get mkorp
      ++r ; @ r,1 say "Квартира" get mkvar
      ++r ; @ r,1 say "Служебный телефон" get mphone
      ++r ; @ r,1 say "E-mail" get memail
      ++r ; @ r,1 say "Представитель" get mpredst
      ++r ; @ r,1 say "Дата ходатайства" get mdata
      status_key("^<Esc>^ - выход;  ^<PgDn>^ - запись")
      myread()
      if lastkey() != K_ESC
        frd->is := 1
        frd->iadres := miadres
        frd->sadres := msadres
        frd->radres := mradres
        frd->gadres := mgadres
        frd->nadres := mnadres
        frd->ulica  := mulica
        frd->dom    := mdom
        frd->korp   := mkorp
        frd->kvar   := mkvar
        frd->phone  := mphone
        frd->email  := memail
        frt->predst := mpredst
        frt->data   := mdata
        Commit
      endif
      restscreen(buf)
      k := 0
    case nkey == K_F9
      rec := recno()
      close databases
      call_fr("mo_hodat")
      use (fr_titl) new alias FRT
      use (fr_data) new alias FRD
      goto (rec)
      k := 0
  endcase
endif
return k

*

***** 05.02.13 создание файла ХОДАТАЙСТВА для отсылки в ТФОМС
Function create_file_hodatajstvo(arr_m)
Local i, k := 0, as, fl := .f., mnn, mb, me, mfilial,;
      buf := save_maxrow()
R_Use(dir_server+"organiz",,"ORG")
if empty(mfilial := org->filial_h)
  close databases
  return func_error(4,'Не выбран филиал ТФОМС для отправки файла с ходатайствами ("Ваша организация")')
endif
mywait()
dbcreate(cur_dir+"tmp_k1",{{"kod","N",7,0},;
                           {"kod_lu","N",7,0},;
                           {"k_data","D",8,0},;
                           {"ntable","N",1,0},;
                           {"is","N",1,0}})
use (cur_dir+"tmp_k1") new
index on str(kod,7) to (cur_dir+"tmp_k1")
use (cur_dir+"tmp_k") new
go top
do while !eof()
  select TMP_K1
  find (str(tmp_k->kod,7))
  if found()
    if tmp_k->k_data > tmp_k1->k_data
      replace kod_lu with tmp_k->kod_lu,;
              k_data with tmp_k->k_data
    endif
  else
    append blank
    replace kod    with tmp_k->kod,;
            kod_lu with tmp_k->kod_lu,;
            k_data with tmp_k->k_data,;
            is with 1
  endif
  select TMP_K
  skip
enddo
f_mb_me_nsh(2013,@mb,@me)
R_Use(dir_server+"mo_hod",,"HOD")
index on str(nn,3) to (cur_dir+"tmp_rees") for year(dfile)==year(sys_date)
for mnn := mb to me
  find (str(mnn,3))
  if !found() // нашли свободный номер
    fl := .t. ; exit
  endif
next
if !fl
  rest_box(buf)
  close databases
  return func_error(10,"Не удалось найти свободный номер пакета в ТФОМС. Проверьте настройки!")
endif
set index to
R_Use(dir_server+"mo_hod_k",,"HODK")
set relation to kod into HOD
index on str(kod_k,7) to (cur_dir+"tmp_hodk") ;
      for hod->nyear==arr_m[1] .and. hod->nmonth==arr_m[2]
select TMP_K1
go top
do while !eof()
  select HODK
  find (str(tmp_k1->kod,7))
  if found()
    tmp_k1->is := 0
  endif
  select TMP_K1
  skip
enddo
delete for is == 0
pack
as := {{0,'34001',''},{0,'34002',''},{0,'34006',''},{0,'34007',''},{0,'прочие',''}}
R_Use(dir_server+"human_",,"HUMAN_")
select TMP_K1
set index to
go top
do while !eof()
  human_->(dbGoto(tmp_k1->kod_lu))
  i := 3
  if human_->smo == as[1,2]
    i := 1
  elseif human_->smo == as[2,2]
    i := 2
  endif
  tmp_k1->ntable := i
  ++k ; ++as[i,1]
  skip
enddo
close databases
rest_box(buf)
if k == 0
  return func_error(4,"По всем пациентам уже отправлены ходатайства "+arr_m[4])
endif
j := 0
for i := 1 to 3
  if as[i,1] > 0
    ++j
  endif
next
if f_alert({'Составляется архив с ходатайствами',;
            '(количество пациентов - '+lstr(k)+', количество таблиц Excel - '+lstr(j)+').',;
            '',;
            'Выберите действие:'},;
           {" Отказ "," Создание файла ходатайства "},;
           2,"GR+/R","W+/R",16,,"GR+/R,N/BG") == 2
  n_file := "HD_"+lstr(mfilial)+"_M"+glob_mo[_MO_KOD_TFOMS]+"_"+lstr(mnn)
  for i := 1 to 3
    if as[i,1] > 0
      as[i,3] := n_file+"_"+as[i,2]+".xls"
      delete file (as[i,3])
      delFRfiles()
      adbf := {{"name_f","C",30,0},;
               {"codemo","C",6,0},;
               {"name","C",60,0},;
               {"data","C",10,0}}
      dbcreate(fr_titl, adbf)
      use (fr_titl) new alias FRT
      append blank
      frt->name_f := as[i,3]
      frt->codemo := glob_mo[_MO_KOD_TFOMS]
      frt->name   := glob_mo[_MO_SHORT_NAME]
      frt->data   := full_date(sys_date)
      adbf := {{"nomer","N",4,0},;
               {"fam","C",50,0},;
               {"im","C",50,0},;
               {"ot","C",50,0},;
               {"pol","C",3,0},;
               {"date_r","C",10,0},;
               {"vid_ud","N",2,0},;
               {"name_ud","C",20,0},;
               {"ser_ud","C",10,0},;
               {"nom_ud","C",20,0},;
               {"mesto_r","C",100,0},;
               {"snils","C",14,0},;
               {"okatog","C",11,0},;
               {"adresg","C",250,0},;
               {"vidpolis","C",10,0},;
               {"polis","C",40,0},;
               {"smo","C",5,0},;
               {"name_smo","C",60,0},;
               {"okato","C",5,0},;
               {"region","C",60,0},;
               {"proch","C",60,0}}
      dbcreate(fr_data,adbf)
      use (fr_data) new alias FRD
      R_Use(dir_exe+"_mo_smo",cur_dir+"_mo_smo2","SMO")
      R_Use(dir_server+"kartote_",,"KART_")
      R_Use(dir_server+"kartotek",,"KART")
      set relation to recno() into KART_
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_, kod_k into KART
      use (cur_dir+"tmp_k1") new
      set relation to kod_lu into HUMAN
      index on upper(human->fio) to (cur_dir+"tmp_k1")
      k := 0
      go top
      do while !eof()
        if tmp_k1->ntable == i
          arr_fio := retFamImOt(2)
          select FRD
          append blank
          frd->nomer := ++k
          frd->FAM := arr_fio[1]
          frd->IM  := arr_fio[2]
          frd->OT  := arr_fio[3]
          frd->pol := iif(human->pol=="М","муж","жен")
          frd->date_r := full_date(human->date_r)
          frd->vid_ud := kart_->vid_ud
          if (j := ascan(menu_vidud, {|x| x[2] == kart_->vid_ud})) > 0
            frd->name_ud := menu_vidud[j,4]
          endif
          frd->ser_ud := kart_->ser_ud
          frd->nom_ud := kart_->nom_ud
          if !empty(smr := del_spec_symbol(kart_->mesto_r))
            frd->mesto_r := charone(" ",smr)
          endif
          if !empty(kart->snils)
            frd->snils := transform(kart->SNILS,picture_pf)
          endif
          frd->okatog := kart_->okatog
          frd->adresg := ret_okato_ulica(kart->adres,kart_->okatog,1,2)
          frd->vidpolis := lstr(human_->VPOLIS)+"-"+inieditspr(A__MENUVERT, mm_vid_polis, human_->VPOLIS)
          frd->polis := alltrim(alltrim(human_->SPOLIS)+" "+human_->NPOLIS)
          frd->smo := human_->smo
          frd->name_smo := inieditspr(A__MENUVERT, glob_arr_smo, int(val(human_->smo)))
          if empty(frd->name_smo)
            select SMO
            find (padr(human_->smo,5))
            frd->name_smo := smo->name
          endif
          if empty(frd->okato := human_->okato)
            select SMO
            find (padr(human_->smo,5))
            frd->okato := smo->okato
          endif
          frd->region := inieditspr(A__MENUVERT, glob_array_srf, frd->okato)
          frd->proch := alltrim(alltrim(kart_->PHONE_H)+" "+alltrim(kart_->PHONE_M)+" "+kart_->PHONE_W)
        endif
        select TMP_K1
        skip
      enddo
      close databases
      call_fr("mo_hodex",3,as[i,3],,.f.)
    endif
  next
  //
  G_Use(dir_server+"mo_hod",,"HOD")
  AddRecN()
  hod->KOD := recno()
  hod->NYEAR := arr_m[1]
  hod->NMONTH := arr_m[2]
  hod->NN := mnn
  hod->KOL1 := 0
  hod->KOL2 := 0
  hod->KOL3 := 0
  hod->FNAME := n_file
  hod->DFILE := sys_date
  hod->TFILE := hour_min(seconds())
  hod->DATE_OUT := ctod("")
  hod->NUMB_OUT := 0
  G_Use(dir_server+"mo_hod_k",,"HODK")
  index on str(kod,6) to (cur_dir+"tmp_hodk")
  use (cur_dir+"tmp_k1") new
  arr_zip := {}
  for i := 1 to 3
    if as[i,1] > 0
      aadd(arr_zip, as[i,3])
      select TMP_K1
      go top
      do while !eof()
        if tmp_k1->ntable == i
          select HODK
          AddRec(6)
          hodk->KOD := hod->KOD
          hodk->KOD_K := tmp_k1->kod
          pole := "hod->KOL"+lstr(i)
          &pole := &pole + 1
        endif
        select TMP_K1
        skip
      enddo
    endif
  next
  close databases
  if chip_create_zipXML(n_file+szip,arr_zip,.t.)
    view_list_hodatajstvo()
  endif
endif
return NIL

*

***** 04.02.13
Function view_list_hodatajstvo()
Local buf := savescreen()
if !G_SLock(Shodata_sem)
  return func_error(4,Shodata_err)
endif
Private goal_dir := dir_server+dir_XML_MO+cslash
G_Use(dir_server+"mo_hod",,"HOD")
index on str(year(dfile),4)+str(nn,4) to (cur_dir+"tmp_hod") DESCENDING
go top
if eof()
  func_error(4,"Нет файлов ходатайств")
else
  Alpha_Browse(T_ROW,2,22,77,"f1_view_list_hodatajstvo",color0,,,,,,,;
               "f2_view_list_hodatajstvo",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
endif
close databases
G_SUnLock(Shodata_sem)
restscreen(buf)
return NIL

***** 22.02.17
Function f1_view_list_hodatajstvo(oBrow)
Local oColumn, ;
      blk := {|| iif(hb_fileExists(goal_dir+alltrim(hod->FNAME)+szip), ;
                     iif(empty(hod->date_out), {3,4}, {1,2}),;
                     {5,6}) }
oColumn := TBColumnNew("Номер",{|| hod->nn })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Дата",{|| date_8(hod->dfile) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Пери-;од",{|| right(str(hod->nyear,4),2)+"/"+strzero(hod->nmonth,2) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Кол.;Капитал", {|| put_val(hod->kol1,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Кол.;Согаз", {|| put_val(hod->kol2,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Кол.;прочие", {|| put_val(hod->kol3,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Наименование файла",{|| padr(hod->FNAME,20) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Примечание",{|| f11_view_list_hodatajstvo() })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
status_key("^<Esc>^ выход ^<Enter>^ просмотр ^<F5>^ запись ^<Del>^ удалить ещё не записанный файл")
return NIL

*****
Static Function f11_view_list_hodatajstvo()
Local s := ""
if !hb_fileExists(goal_dir+alltrim(hod->FNAME)+szip)
  s := "нет файла"
elseif empty(hod->date_out)
  s := "не записан"
else
  s := "зап. "+lstr(hod->NUMB_OUT)+" раз"
endif
return padr(s,10)

*

***** 24.02.17
Function f2_view_list_hodatajstvo(nKey,oBrow)
Local ret := -1, tmp_color := setcolor(), r, r1, r2, arr_f,;
      s, buf := savescreen(), arr, i, k, mdate, t_arr[2], arr_pmt := {}
do case
  case nKey == K_ENTER
    if (arr_f := Extract_Zip_XML(goal_dir,alltrim(hod->FNAME)+szip)) != NIL
      if (k := len(arr_f)) > 1
        stat_msg("Ждите. Сейчас будут открыты "+lstr(k)+" таблицы Excel в разных окнах.")
      else
        stat_msg("Ждите. Сейчас будет открыта таблица Excel "+arr_f[1])
      endif
      mybell(2,OK)
      for i := 1 to k
        ShellExecute(GetDeskTopWindow(),'open','Excel.exe',_tmp_dir1+arr_f[i],,1)
      next
    endif
  case nKey == K_F5
    if f_Esc_Enter("записи файла за "+date_8(hod->dfile))
      Private p_var_manager := "copy_schet"
      s := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,2,.f.,,,) // "norton" для выбора каталога
      if !empty(s)
        if upper(s) == upper(goal_dir)
          func_error(4,"Вы выбрали каталог, в котором уже записан целевой файл! Это недопустимо.")
        else
          zip_file := alltrim(hod->FNAME)+szip
          if hb_fileExists(goal_dir+zip_file)
            mywait('Копирование "'+zip_file+'" в каталог "'+s+'"')
            //copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
            copy file (goal_dir+zip_file) to (s+zip_file)
            //if hb_fileExists(hb_OemToAnsi(s)+zip_file)
            if hb_fileExists(s+zip_file)
              hod->(G_RLock(forever))
              hod->DATE_OUT := sys_date
              if hod->NUMB_OUT < 99
                hod->NUMB_OUT ++
              endif
              UnLock
              Commit
            else
              smsg := "Ошибка записи файла "+s+zip_file
              func_error(4,"Ошибка записи файла "+s+zip_file)
            endif
          else
            func_error(4,"Не обнаружен файл "+goal_dir+zip_file)
          endif
        endif
      endif
    endif
    ret := 0
  case nKey == K_DEL .and. empty(hod->DATE_OUT)
    if f_Esc_Enter("удаления файла за "+date_8(hod->dfile),.t.)
      stat_msg("Подтвердите удаление ещё раз.") ; mybell(2)
      if f_Esc_Enter("удаления файла за "+date_8(hod->dfile),.t.)
        mywait("Ждите. Производится удаление файла ходатайства.")
        G_Use(dir_server+"mo_hod_k",,"HODK")
        index on str(kod,6) to (cur_dir+"tmp_hodk")
        do while .t.
          find (str(hod->kod,6))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        zip_file := alltrim(hod->fname)+szip
        if hb_fileExists(goal_dir+zip_file)
          delete file (goal_dir+zip_file)
        endif
        select HOD
        DeleteRec(.t.)
        stat_msg("Файл ходатайства удалён!") ; mybell(2,OK)
        ret := 1
      endif
    endif
endcase
setcolor(tmp_color)
restscreen(buf)
return ret

***** 01.08.18
Function save_arr_DDS(lkod)
Local arr := {}, k, ta
Private mvar
if type("mfio") == "C"
  aadd(arr,{"mfio",alltrim(mfio)})
endif
if type("mdate_r") == "D"
  aadd(arr,{"mdate_r",mdate_r})
endif
aadd(arr,{"0",m1mobilbr})   // "N",мобильная бригада
aadd(arr,{"1",m1stacionar}) // "N",код стационара
aadd(arr,{"2.3",m1kateg_uch}) // "N",Категория учета ребенка: 0-ребенок-сирота; 1-ребенок, оставшийся без попечения родителей; 2-ребенок, находящийся в трудной жизненной ситуации, 3-нет категории
aadd(arr,{"2.4",m1gde_nahod}) // "N",На момент проведения диспансеризации находится 0-в стационарном учреждении, 1-под опекой, 2-попечительством, 3-передан в приемную семью, 4-передан в патронатную семью, 5-усыновлен (удочерена), 6-другое
aadd(arr,{"4",mdate_post}) // "D",Дата поступления в стационарное учреждение
if m1prich_vyb > 0
  aadd(arr,{"5",m1prich_vyb}) // "N",0-нет. Причина выбытия из стационарного учреждения: 1-опека, 2-попечительство, 3-усыновление (удочерение), 4-передан в приемную семью, 5-передан в патронатную семью, 6-выбыл в другое стационарное учреждение, 7-выбыл по возрасту, 8-смерть, 9-другое
  aadd(arr,{"5.1",mDATE_VYB}) // "D",Дата выбытия
endif
if !empty(mPRICH_OTS)
  aadd(arr,{"6",alltrim(mPRICH_OTS)}) // "C70",причина отсутствия на момент проведения диспансеризации
endif
aadd(arr,{"8",m1MO_PR}) // "C6",код МО прикрепления
aadd(arr,{"12.1",mWEIGHT})  // "N3",вес в кг
aadd(arr,{"12.2",mHEIGHT})  // "N3",рост в см
aadd(arr,{"12.3",mPER_HEAD})  // "N3",окружность головы в см
aadd(arr,{"12.4",m1FIZ_RAZV})  // "N",физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
aadd(arr,{"12.4.1",m1FIZ_RAZV1})  // "N",физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
aadd(arr,{"12.4.2",m1FIZ_RAZV2})  // "N",физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
if mvozrast < 5
  aadd(arr,{"13.1.1",m1psih11})  // "N1",познавательная функция (возраст развития)
  aadd(arr,{"13.1.2",m1psih12})  // "N1",моторная функция (возраст развития)
  aadd(arr,{"13.1.3",m1psih13})  // "N1",эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития)
  aadd(arr,{"13.1.4",m1psih14})  // "N1",предречевое и речевое развитие (возраст развития)
else
  aadd(arr,{"13.2.1",m1psih21})  // "N1",Психомоторная сфера: (норма, отклонение)
  aadd(arr,{"13.2.2",m1psih22})  // "N1",Интеллект: (норма, отклонение)
  aadd(arr,{"13.2.3",m1psih23})  // "N1",Эмоционально-вегетативная сфера: (норма, отклонение)
endif
if mpol == "М"
  aadd(arr,{"14.1.P"  ,m141p})     // "N1",Половая формула мальчика
  aadd(arr,{"14.1.Ax" ,m141ax})   // "N1",Половая формула мальчика
  aadd(arr,{"14.1.Fa" ,m141fa})   // "N1",Половая формула мальчика
else
  aadd(arr,{"14.2.P"  ,m142p})     // "N1",Половая формула девочки
  aadd(arr,{"14.2.Ax" ,m142ax})   // "N1",Половая формула девочки
  aadd(arr,{"14.2.Ma" ,m142ma})   // "N1",Половая формула девочки
  aadd(arr,{"14.2.Me" ,m142me})   // "N1",Половая формула девочки
  aadd(arr,{"14.2.Me1",m142me1}) // "N2",Половая формула девочки - menarhe (лет)
  aadd(arr,{"14.2.Me2",m142me2}) // "N2",Половая формула девочки - menarhe (месяцев)
  aadd(arr,{"14.2.Me3",m1142me3}) // "N1",Половая формула девочки - menses (характеристика): регулярные, нерегулярные, обильные, умеренные, скудные, болезненные и безболезненные
  aadd(arr,{"14.2.Me4",m1142me4}) // "N1",Половая формула девочки - menses (характеристика): регулярные, нерегулярные, обильные, умеренные, скудные, болезненные и безболезненные
  aadd(arr,{"14.2.Me5",m1142me5}) // "N1",Половая формула девочки - menses (характеристика): регулярные, нерегулярные, обильные, умеренные, скудные, болезненные и безболезненные
endif
aadd(arr,{"15.1",m1diag_15_1}) // "C6",Состояние здоровья до проведения диспансеризации-Практически здоров
if m1diag_15_1 == 0 .and. !empty(mdiag_15_1_1)
  ta := {mdiag_15_1_1}
  for k := 2 to 14
    mvar := "m1diag_15_1_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"15.2",ta})
endif
if m1diag_15_1 == 0 .and. !empty(mdiag_15_2_1)
  ta := {mdiag_15_2_1}
  for k := 2 to 14
    mvar := "m1diag_15_2_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"15.3",ta})
endif
if m1diag_15_1 == 0 .and. !empty(mdiag_15_3_1)
  ta := {mdiag_15_3_1}
  for k := 2 to 14
    mvar := "m1diag_15_3_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"15.4",ta})
endif
if m1diag_15_1 == 0 .and. !empty(mdiag_15_4_1)
  ta := {mdiag_15_4_1}
  for k := 2 to 14
    mvar := "m1diag_15_4_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"15.5",ta})
endif
if m1diag_15_1 == 0 .and. !empty(mdiag_15_5_1)
  ta := {mdiag_15_5_1}
  for k := 2 to 14
    mvar := "m1diag_15_5_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"15.6",ta})
endif
aadd(arr,{"15.9",mGRUPPA_DO}) // "N1",группа здоровья до дисп-ии
aadd(arr,{"16.1",m1diag_16_1}) // "C6",Состояние здоровья по результатам проведения диспансеризации (Практически здоров)
if m1diag_16_1 == 0 .and. !empty(mdiag_16_1_1)
  ta := {mdiag_16_1_1}
  for k := 2 to 16
    mvar := "m1diag_16_1_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"16.2",ta})
endif
if m1diag_16_1 == 0 .and. !empty(mdiag_16_2_1)
  ta := {mdiag_16_2_1}
  for k := 2 to 16
    mvar := "m1diag_16_2_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"16.3",ta})
endif
if m1diag_16_1 == 0 .and. !empty(mdiag_16_3_1)
  ta := {mdiag_16_3_1}
  for k := 2 to 16
    mvar := "m1diag_16_3_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"16.4",ta})
endif
if m1diag_16_1 == 0 .and. !empty(mdiag_16_4_1)
  ta := {mdiag_16_4_1}
  for k := 2 to 16
    mvar := "m1diag_16_4_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"16.5",ta})
endif
if m1diag_16_1 == 0 .and. !empty(mdiag_16_5_1)
  ta := {mdiag_16_5_1}
  for k := 2 to 16
    mvar := "m1diag_16_5_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"16.6",ta})
endif
if m1invalid1 == 1
  ta := {m1invalid1,m1invalid2,minvalid3,minvalid4,;
         m1invalid5,m1invalid6,minvalid7,m1invalid8}
  aadd(arr,{"16.7",ta})   // массив из 8
endif
aadd(arr,{"16.8",mGRUPPA})    // "N1",группа здоровья после дисп-ии
if m1privivki1 > 0
  ta := {m1privivki1,m1privivki2,mprivivki3}
  aadd(arr,{"16.9",ta})  // массив из 4,Проведение профилактических прививок
endif
if !empty(mrek_form)
  aadd(arr,{"16.10",alltrim(mrek_form)}) // Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой
endif
if !empty(mrek_disp)
  aadd(arr,{"16.11",alltrim(mrek_disp)}) // Рекомендации по диспансерному наблюдению, лечению, медицинской реабилитации и санаторно-курортному лечению с указанием диагноза (код МКБ), вида медицинской организации и специальности (должности) врача
endif
// 18.результаты проведения исследований
for i := 1 to count_dds_arr_iss
  mvar := "MREZi"+lstr(i)
  if !empty(&mvar)
    aadd(arr,{"18."+lstr(i),alltrim(&mvar)})
  endif
next
if type("m1napr_stac") == "N" 
  aadd(arr,{"54",m1napr_stac})
endif  
if type("m1profil_stac") == "N"       
  aadd(arr,{"55",m1profil_stac})
endif  
if type("m1napr_reab") == "N" 
  aadd(arr,{"56",m1napr_reab})
endif  
if type("m1profil_kojki") == "N"       
  aadd(arr,{"57",m1profil_kojki})
endif  
save_arr_DISPANS(lkod,arr)
return NIL

***** 01.08.18
Function read_arr_DDS(lkod)
Local arr, i, k
Private mvar
arr := read_arr_DISPANS(lkod)
for i := 1 to len(arr)
  if valtype(arr[i]) == "A" .and. valtype(arr[i,1]) == "C"
    do case
      case arr[i,1] == "0" .and. valtype(arr[i,2]) == "N"
        m1mobilbr := arr[i,2]
      case arr[i,1] == "1"
        //m1stacionar := arr[i,2]
      case arr[i,1] == "2.3" .and. valtype(arr[i,2]) == "N"
        m1kateg_uch := arr[i,2]
      case arr[i,1] == "2.4" .and. valtype(arr[i,2]) == "N"
        m1gde_nahod := arr[i,2]
      case arr[i,1] == "4" .and. valtype(arr[i,2]) == "D"
        mdate_post := arr[i,2]
      case arr[i,1] == "5" .and. valtype(arr[i,2]) == "N"
        m1prich_vyb := arr[i,2]
      case arr[i,1] == "5.1" .and. valtype(arr[i,2]) == "D"
        mDATE_VYB := arr[i,2]
      case arr[i,1] == "6" .and. valtype(arr[i,2]) == "C"
        mPRICH_OTS := padr(arr[i,2],70)
      case arr[i,1] == "8" .and. valtype(arr[i,2]) == "C"
        m1MO_PR := arr[i,2]
      case arr[i,1] == "12.1" .and. valtype(arr[i,2]) == "N"
        mWEIGHT := arr[i,2]
      case arr[i,1] == "12.2" .and. valtype(arr[i,2]) == "N"
        mHEIGHT := arr[i,2]
      case arr[i,1] == "12.3" .and. valtype(arr[i,2]) == "N"
        mPER_HEAD := arr[i,2]
      case arr[i,1] == "12.4" .and. valtype(arr[i,2]) == "N"
        m1FIZ_RAZV := arr[i,2]
      case arr[i,1] == "12.4.1" .and. valtype(arr[i,2]) == "N"
        m1FIZ_RAZV1 := arr[i,2]
      case arr[i,1] == "12.4.2" .and. valtype(arr[i,2]) == "N"
        m1FIZ_RAZV2 := arr[i,2]
      case arr[i,1] == "13.1.1" .and. valtype(arr[i,2]) == "N"
        m1psih11 := arr[i,2]
      case arr[i,1] == "13.1.2" .and. valtype(arr[i,2]) == "N"
        m1psih12 := arr[i,2]
      case arr[i,1] == "13.1.3" .and. valtype(arr[i,2]) == "N"
        m1psih13 := arr[i,2]
      case arr[i,1] == "13.1.4" .and. valtype(arr[i,2]) == "N"
        m1psih14 := arr[i,2]
      case arr[i,1] == "13.2.1" .and. valtype(arr[i,2]) == "N"
        m1psih21 := arr[i,2]
      case arr[i,1] == "13.2.2" .and. valtype(arr[i,2]) == "N"
        m1psih22 := arr[i,2]
      case arr[i,1] == "13.2.3" .and. valtype(arr[i,2]) == "N"
        m1psih23 := arr[i,2]
      case arr[i,1] == "14.1.P" .and. valtype(arr[i,2]) == "N"
        m141p := arr[i,2]
      case arr[i,1] == "14.1.Ax" .and. valtype(arr[i,2]) == "N"
        m141ax := arr[i,2]
      case arr[i,1] == "14.1.Fa" .and. valtype(arr[i,2]) == "N"
        m141fa := arr[i,2]
      case arr[i,1] == "14.2.P" .and. valtype(arr[i,2]) == "N"
        m142p := arr[i,2]
      case arr[i,1] == "14.2.Ax" .and. valtype(arr[i,2]) == "N"
        m142ax := arr[i,2]
      case arr[i,1] == "14.2.Ma" .and. valtype(arr[i,2]) == "N"
        m142ma := arr[i,2]
      case arr[i,1] == "14.2.Me" .and. valtype(arr[i,2]) == "N"
        m142me := arr[i,2]
      case arr[i,1] == "14.2.Me1" .and. valtype(arr[i,2]) == "N"
        m142me1 := arr[i,2]
      case arr[i,1] == "14.2.Me2" .and. valtype(arr[i,2]) == "N"
        m142me2 := arr[i,2]
      case arr[i,1] == "14.2.Me3" .and. valtype(arr[i,2]) == "N"
        m1142me3 := arr[i,2]
      case arr[i,1] == "14.2.Me4" .and. valtype(arr[i,2]) == "N"
        m1142me4 := arr[i,2]
      case arr[i,1] == "14.2.Me5" .and. valtype(arr[i,2]) == "N"
        m1142me5 := arr[i,2]
      case arr[i,1] == "15.1" .and. valtype(arr[i,2]) == "N"
        m1diag_15_1 := arr[i,2]
      case arr[i,1] == "15.2" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
        mdiag_15_1_1 := arr[i,2,1]
        for k := 2 to 14
          if len(arr[i,2]) >= k
            mvar := "m1diag_15_1_"+lstr(k)
            &mvar := arr[i,2,k]
          endif
        next
      case arr[i,1] == "15.3" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
        mdiag_15_2_1 := arr[i,2,1]
        for k := 2 to 14
          if len(arr[i,2]) >= k
            mvar := "m1diag_15_2_"+lstr(k)
            &mvar := arr[i,2,k]
          endif
        next
      case arr[i,1] == "15.4" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
        mdiag_15_3_1 := arr[i,2,1]
        for k := 2 to 14
          if len(arr[i,2]) >= k
            mvar := "m1diag_15_3_"+lstr(k)
            &mvar := arr[i,2,k]
          endif
        next
      case arr[i,1] == "15.5" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
        mdiag_15_4_1 := arr[i,2,1]
        for k := 2 to 14
          if len(arr[i,2]) >= k
            mvar := "m1diag_15_4_"+lstr(k)
            &mvar := arr[i,2,k]
          endif
        next
      case arr[i,1] == "15.6" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
        mdiag_15_5_1 := arr[i,2,1]
        for k := 2 to 14
          if len(arr[i,2]) >= k
            mvar := "m1diag_15_5_"+lstr(k)
            &mvar := arr[i,2,k]
          endif
        next
      case arr[i,1] == "15.9" .and. valtype(arr[i,2]) == "N"
        mGRUPPA_DO := arr[i,2]
      case arr[i,1] == "16.1" .and. valtype(arr[i,2]) == "N"
        m1diag_16_1 := arr[i,2]
      case arr[i,1] == "16.2" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
        mdiag_16_1_1 := arr[i,2,1]
        for k := 2 to 16
          if len(arr[i,2]) >= k
            mvar := "m1diag_16_1_"+lstr(k)
            &mvar := arr[i,2,k]
          endif
        next
      case arr[i,1] == "16.3" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
        mdiag_16_2_1 := arr[i,2,1]
        for k := 2 to 16
          if len(arr[i,2]) >= k
            mvar := "m1diag_16_2_"+lstr(k)
            &mvar := arr[i,2,k]
          endif
        next
      case arr[i,1] == "16.4" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
        mdiag_16_3_1 := arr[i,2,1]
        for k := 2 to 16
          if len(arr[i,2]) >= k
            mvar := "m1diag_16_3_"+lstr(k)
            &mvar := arr[i,2,k]
          endif
        next
      case arr[i,1] == "16.5" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
        mdiag_16_4_1 := arr[i,2,1]
        for k := 2 to 16
          if len(arr[i,2]) >= k
            mvar := "m1diag_16_4_"+lstr(k)
            &mvar := arr[i,2,k]
          endif
        next
      case arr[i,1] == "16.6" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
        mdiag_16_5_1 := arr[i,2,1]
        for k := 2 to 16
          if len(arr[i,2]) >= k
            mvar := "m1diag_16_5_"+lstr(k)
            &mvar := arr[i,2,k]
          endif
        next
      case arr[i,1] == "16.7" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 8
        m1invalid1 := arr[i,2,1]
        m1invalid2 := arr[i,2,2]
        minvalid3  := arr[i,2,3]
        minvalid4  := arr[i,2,4]
        m1invalid5 := arr[i,2,5]
        m1invalid6 := arr[i,2,6]
        minvalid7  := arr[i,2,7]
        m1invalid8 := arr[i,2,8]
      case arr[i,1] == "16.8" .and. valtype(arr[i,2]) == "N"
        //mGRUPPA := arr[i,2]
      case arr[i,1] == "16.9" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 3
        m1privivki1 := arr[i,2,1]
        m1privivki2 := arr[i,2,2]
        mprivivki3  := arr[i,2,3]
      case arr[i,1] == "16.10" .and. valtype(arr[i,2]) == "C"
        mrek_form := padr(arr[i,2],255)
      case arr[i,1] == "16.11" .and. valtype(arr[i,2]) == "C"
        mrek_disp := padr(arr[i,2],255)
      case arr[i,1] == "54" .and. valtype(arr[i,2]) == "N"
        m1napr_stac := arr[i,2] 
      case arr[i,1] == "55" .and. valtype(arr[i,2]) == "N"
        m1profil_stac := arr[i,2]
      case arr[i,1] == "56" .and. valtype(arr[i,2]) == "N"
        m1napr_reab := arr[i,2]
      case arr[i,1] == "57" .and. valtype(arr[i,2]) == "N"
        m1profil_kojki := arr[i,2]
      otherwise
        for k := 1 to count_dds_arr_iss
          if arr[i,1] == "18."+lstr(k) .and. valtype(arr[i,2]) == "C"
            mvar := "MREZi"+lstr(k)
            &mvar := padr(arr[i,2],17)
          endif
        next
    endcase
  endif
next
return NIL

***** 29.01.17
Function save_arr_DVN(lkod)
Local arr := {}, i, sk, ta
if type("mfio") == "C"
  aadd(arr,{"mfio",alltrim(mfio)})
endif
if type("mdate_r") == "D"
  aadd(arr,{"mdate_r",mdate_r})
endif
aadd(arr,{ "VB",m1veteran})  // "N",ветеран ВОВ (блокадник)
aadd(arr,{ "0",m1mobilbr})   // "N",мобильная бригада
aadd(arr,{ "1",m1kurenie})   // "N",Курение
aadd(arr,{ "2",m1riskalk})   // "N",Алкоголь
aadd(arr,{ "3",m1pod_alk})   // "N",наркотики
aadd(arr,{ "3.1",m1psih_na})   // "N",        направлен к психиатру-наркологу
aadd(arr,{ "4",m1fiz_akt})   // "N",Низкая физическая активность
aadd(arr,{ "5",m1ner_pit})   // "N",Нерациональное питание
aadd(arr,{ "6",mWEIGHT})     // "N",Вес
aadd(arr,{ "7",mHEIGHT})     // "N",рост
aadd(arr,{ "8",mOKR_TALII})  // "N",окружность талии
aadd(arr,{ "9",mad1})        // "N",Артериальное давление
aadd(arr,{"10",mad2})        // "N",Артериальное давление
aadd(arr,{"11",m1addn})      // "N",Гипотензивная терапия
aadd(arr,{"12",mholest})     // "N",Общий холестерин
aadd(arr,{"13",m1holestdn})  // "N",Гиполипидемическая терапия
aadd(arr,{"14",mglukoza})    // "N",Глюкоза
aadd(arr,{"15",m1glukozadn}) // "N",Гипогликемическая терапия
aadd(arr,{"16",mssr})        // "N",Суммарный сердечно-сосудистый риск
for i := 1 to 5
  sk := lstr(i)
  pole_diag := "mdiag"+sk
  pole_1pervich := "m1pervich"+sk
  pole_1stadia := "m1stadia"+sk
  pole_1dispans := "m1dispans"+sk
  pole_1dop := "m1dop"+sk
  pole_1usl := "m1usl"+sk
  pole_1san := "m1san"+sk
  pole_d_diag := "mddiag"+sk
  pole_d_dispans := "mddispans"+sk
  if !empty(&pole_diag)
    ta := {&pole_diag,;
           &pole_1pervich,;
           &pole_1stadia,;
           &pole_1dispans}
    if type(pole_1dop)=="N" .and. type(pole_1usl)=="N" .and. type(pole_1san)=="N"
      aadd(ta, &pole_1dop)
      aadd(ta, &pole_1usl)
      aadd(ta, &pole_1san)
    else
      aadd(ta,0)
      aadd(ta,0)
      aadd(ta,0)
    endif
    if type(pole_d_diag)=="D" .and. type(pole_d_dispans)=="D"
      aadd(ta, &pole_d_diag)
      aadd(ta, &pole_d_dispans)
    else
      aadd(ta,ctod(""))
      aadd(ta,ctod(""))
    endif
    aadd(arr,{lstr(20+i),ta})
  endif
next
if !empty(arr_usl_otkaz)
  aadd(arr,{"29",arr_usl_otkaz}) // массив
endif
aadd(arr,{"30",m1GRUPPA})    // "N1",группа здоровья после дисп-ии
if type("m1prof_ko}") == "N"
  aadd(arr,{"31",m1prof_ko})    // "N1",вид проф.консультирования
endif
if type("m1ot_nasl1") == "N"
  aadd(arr,{"40",arr_otklon}) // массив
  aadd(arr,{"41",m1ot_nasl1})
  aadd(arr,{"42",m1ot_nasl2})
  aadd(arr,{"43",m1ot_nasl3})
  aadd(arr,{"44",m1ot_nasl4})
  aadd(arr,{"45",m1dispans})
  aadd(arr,{"46",m1nazn_l})
  aadd(arr,{"47",m1dopo_na})
  aadd(arr,{"48",m1ssh_na})
  aadd(arr,{"49",m1spec_na})
  aadd(arr,{"50",m1sank_na})
endif
if type("m1p_otk") == "N"
  aadd(arr,{"51",m1p_otk})
endif  
if type("m1napr_v_mo") == "N"
  aadd(arr,{"52",m1napr_v_mo})
endif  
if type("arr_mo_spec") == "A" .and. !empty(arr_mo_spec)
  aadd(arr,{"53",arr_mo_spec}) // массив
endif
if type("m1napr_stac") == "N" 
  aadd(arr,{"54",m1napr_stac})
endif  
if type("m1profil_stac") == "N"       
  aadd(arr,{"55",m1profil_stac})
endif  
if type("m1napr_reab") == "N" 
  aadd(arr,{"56",m1napr_reab})
endif  
if type("m1profil_kojki") == "N"       
  aadd(arr,{"57",m1profil_kojki})
endif  
save_arr_DISPANS(lkod,arr)
return NIL

***** 29.01.17
Function read_arr_DVN(lkod,is_all)
Local arr, i, sk
Private mvar
arr := read_arr_DISPANS(lkod)
DEFAULT is_all TO .t.
for i := 1 to len(arr)
  if valtype(arr[i]) == "A" .and. valtype(arr[i,1]) == "C"
    do case
      case arr[i,1] == "VB" .and. valtype(arr[i,2]) == "N"
        m1veteran := arr[i,2]
      case arr[i,1] == "0" .and. valtype(arr[i,2]) == "N"
        m1mobilbr := arr[i,2]
      case arr[i,1] == "1" .and. valtype(arr[i,2]) == "N"
        m1kurenie := arr[i,2]
      case arr[i,1] == "2" .and. valtype(arr[i,2]) == "N"
        m1riskalk := arr[i,2]
      case arr[i,1] == "3" .and. valtype(arr[i,2]) == "N"
        m1pod_alk := arr[i,2]
      case arr[i,1] == "3.1" .and. valtype(arr[i,2]) == "N"
        m1psih_na := arr[i,2]
      case arr[i,1] == "4" .and. valtype(arr[i,2]) == "N"
        m1fiz_akt := arr[i,2]
      case arr[i,1] == "5" .and. valtype(arr[i,2]) == "N"
        m1ner_pit := arr[i,2]
      case arr[i,1] == "6" .and. valtype(arr[i,2]) == "N"
        mWEIGHT := arr[i,2]
      case arr[i,1] == "7" .and. valtype(arr[i,2]) == "N"
        mHEIGHT := arr[i,2]
      case arr[i,1] == "8" .and. valtype(arr[i,2]) == "N"
        mOKR_TALII := arr[i,2]
      case arr[i,1] == "9" .and. valtype(arr[i,2]) == "N"
        mad1 := arr[i,2]
      case arr[i,1] == "10" .and. valtype(arr[i,2]) == "N"
        mad2 := arr[i,2]
      case arr[i,1] == "11" .and. valtype(arr[i,2]) == "N"
        m1addn := arr[i,2]
      case arr[i,1] == "12" .and. valtype(arr[i,2]) == "N"
        mholest := arr[i,2]
      case arr[i,1] == "13" .and. valtype(arr[i,2]) == "N"
        m1holestdn := arr[i,2]
      case arr[i,1] == "14" .and. valtype(arr[i,2]) == "N"
        mglukoza := arr[i,2]
      case arr[i,1] == "15" .and. valtype(arr[i,2]) == "N"
        m1glukozadn := arr[i,2]
      case arr[i,1] == "16" .and. valtype(arr[i,2]) == "N"
        mssr := arr[i,2]
      case is_all .and. eq_any(arr[i,1],"21","22","23","24","25") .and. ;
                           valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 7
        sk := right(arr[i,1],1)
        pole_diag := "mdiag"+sk
        pole_1pervich := "m1pervich"+sk
        pole_1stadia := "m1stadia"+sk
        pole_1dispans := "m1dispans"+sk
        pole_1dop := "m1dop"+sk
        pole_1usl := "m1usl"+sk
        pole_1san := "m1san"+sk
        pole_d_diag := "mddiag"+sk
        pole_d_dispans := "mddispans"+sk
        if valtype(arr[i,2,1]) == "C"
          &pole_diag := arr[i,2,1]
        endif
        if valtype(arr[i,2,2]) == "N"
          &pole_1pervich := arr[i,2,2]
        endif
        if valtype(arr[i,2,3]) == "N"
          &pole_1stadia := arr[i,2,3]
        endif
        if valtype(arr[i,2,4]) == "N"
          &pole_1dispans := arr[i,2,4]
        endif
        if valtype(arr[i,2,5]) == "N" .and. type(pole_1dop) == "N"
          &pole_1dop := arr[i,2,5]
        endif
        if valtype(arr[i,2,6]) == "N" .and. type(pole_1usl) == "N"
          &pole_1usl := arr[i,2,6]
        endif
        if valtype(arr[i,2,7]) == "N" .and. type(pole_1san) == "N"
          &pole_1san := arr[i,2,7]
        endif
        if len(arr[i,2]) >= 8 .and. valtype(arr[i,2,8]) == "D" .and. type(pole_d_diag) == "D"
          &pole_d_diag := arr[i,2,8]
        endif
        if len(arr[i,2]) >= 9 .and. valtype(arr[i,2,9]) == "D" .and. type(pole_d_dispans) == "D"
          &pole_d_dispans := arr[i,2,9]
        endif
      case is_all .and. arr[i,1] == "29" .and. valtype(arr[i,2]) == "A"
        arr_usl_otkaz := arr[i,2]
      case arr[i,1] == "30" .and. valtype(arr[i,2]) == "N"
        //m1GRUPPA := arr[i,2]
      case arr[i,1] == "31" .and. valtype(arr[i,2]) == "N"
        m1prof_ko := arr[i,2]
      case is_all .and. arr[i,1] == "40" .and. valtype(arr[i,2]) == "A"
        arr_otklon := arr[i,2]
      case arr[i,1] == "41" .and. valtype(arr[i,2]) == "N"
        m1ot_nasl1 := arr[i,2]
      case arr[i,1] == "42" .and. valtype(arr[i,2]) == "N"
        m1ot_nasl2 := arr[i,2]
      case arr[i,1] == "43" .and. valtype(arr[i,2]) == "N"
        m1ot_nasl3 := arr[i,2]
      case arr[i,1] == "44" .and. valtype(arr[i,2]) == "N"
        m1ot_nasl4 := arr[i,2]
      case arr[i,1] == "45" .and. valtype(arr[i,2]) == "N"
        m1dispans  := arr[i,2]
      case arr[i,1] == "46" .and. valtype(arr[i,2]) == "N"
        m1nazn_l   := arr[i,2]
      case arr[i,1] == "47" .and. valtype(arr[i,2]) == "N"
        m1dopo_na  := arr[i,2]
      case arr[i,1] == "48" .and. valtype(arr[i,2]) == "N"
        m1ssh_na   := arr[i,2]
      case arr[i,1] == "49" .and. valtype(arr[i,2]) == "N"
        m1spec_na  := arr[i,2]
      case arr[i,1] == "50" .and. valtype(arr[i,2]) == "N"
        m1sank_na  := arr[i,2]
      case arr[i,1] == "51" .and. valtype(arr[i,2]) == "N"
        m1p_otk  := arr[i,2]
      case arr[i,1] == "52" .and. valtype(arr[i,2]) == "N"
        m1napr_v_mo  := arr[i,2]
      case arr[i,1] == "53" .and. valtype(arr[i,2]) == "A"
        arr_mo_spec := arr[i,2]
      case arr[i,1] == "54" .and. valtype(arr[i,2]) == "N"
        m1napr_stac := arr[i,2] 
      case arr[i,1] == "55" .and. valtype(arr[i,2]) == "N"
        m1profil_stac := arr[i,2]
      case arr[i,1] == "56" .and. valtype(arr[i,2]) == "N"
        m1napr_reab := arr[i,2]
      case arr[i,1] == "57" .and. valtype(arr[i,2]) == "N"
        m1profil_kojki := arr[i,2]
    endcase
  endif
next
return NIL

*

***** 07.05.18
Function save_arr_PN(lkod)
Local arr := {}, k, ta
Private mvar
if type("mfio") == "C"
  aadd(arr,{"mfio",alltrim(mfio)})
endif
if type("mdate_r") == "D"
  aadd(arr,{"mdate_r",mdate_r})
endif
aadd(arr,{"0",m1mobilbr})   // "N",мобильная бригада
aadd(arr,{"1",mperiod}) // "N",номер диапазона (от 1 до 33)
aadd(arr,{"2",m1mesto_prov})   // "N",место проведения
aadd(arr,{"5",m1kateg_uch}) // "N",Категория учета ребенка: 0-ребенок-сирота; 1-ребенок, оставшийся без попечения родителей; 2-ребенок, находящийся в трудной жизненной ситуации, 3-нет категории
aadd(arr,{"6",m1MO_PR}) // "C6",код МО прикрепления
aadd(arr,{"8",m1school}) // "N6",код образовательного учреждения
aadd(arr,{"12.1",mWEIGHT})  // "N3",вес в кг
aadd(arr,{"12.2",mHEIGHT})  // "N3",рост в см
aadd(arr,{"12.3",mPER_HEAD})  // "N3",окружность головы в см
aadd(arr,{"12.4",m1FIZ_RAZV})  // "N",физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
aadd(arr,{"12.4.1",m1FIZ_RAZV1})  // "N",физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
aadd(arr,{"12.4.2",m1FIZ_RAZV2})  // "N",физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
if mdvozrast < 5
  aadd(arr,{"13.1.1",m1psih11})  // "N1",познавательная функция (возраст развития)
  aadd(arr,{"13.1.2",m1psih12})  // "N1",моторная функция (возраст развития)
  aadd(arr,{"13.1.3",m1psih13})  // "N1",эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития)
  aadd(arr,{"13.1.4",m1psih14})  // "N1",предречевое и речевое развитие (возраст развития)
else
  aadd(arr,{"13.2.1",m1psih21})  // "N1",Психомоторная сфера: (норма, отклонение)
  aadd(arr,{"13.2.2",m1psih22})  // "N1",Интеллект: (норма, отклонение)
  aadd(arr,{"13.2.3",m1psih23})  // "N1",Эмоционально-вегетативная сфера: (норма, отклонение)
endif
if mpol == "М"
  aadd(arr,{"14.1.P"  ,m141p})     // "N1",Половая формула мальчика
  aadd(arr,{"14.1.Ax" ,m141ax})   // "N1",Половая формула мальчика
  aadd(arr,{"14.1.Fa" ,m141fa})   // "N1",Половая формула мальчика
else
  aadd(arr,{"14.2.P"  ,m142p})     // "N1",Половая формула девочки
  aadd(arr,{"14.2.Ax" ,m142ax})   // "N1",Половая формула девочки
  aadd(arr,{"14.2.Ma" ,m142ma})   // "N1",Половая формула девочки
  aadd(arr,{"14.2.Me" ,m142me})   // "N1",Половая формула девочки
  aadd(arr,{"14.2.Me1",m142me1}) // "N2",Половая формула девочки - menarhe (лет)
  aadd(arr,{"14.2.Me2",m142me2}) // "N2",Половая формула девочки - menarhe (месяцев)
  aadd(arr,{"14.2.Me3",m1142me3}) // "N1",Половая формула девочки - menses (характеристика): регулярные, нерегулярные, обильные, умеренные, скудные, болезненные и безболезненные
  aadd(arr,{"14.2.Me4",m1142me4}) // "N1",Половая формула девочки - menses (характеристика): регулярные, нерегулярные, обильные, умеренные, скудные, болезненные и безболезненные
  aadd(arr,{"14.2.Me5",m1142me5}) // "N1",Половая формула девочки - menses (характеристика): регулярные, нерегулярные, обильные, умеренные, скудные, болезненные и безболезненные
endif
aadd(arr,{"15.1",m1diag_15_1}) // "N1",Состояние здоровья до проведения диспансеризации-Практически здоров
if m1diag_15_1 == 0 .and. !empty(mdiag_15_1_1)
  ta := {mdiag_15_1_1}
  for k := 2 to 14
    mvar := "m1diag_15_1_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"15.2",ta})
endif
if m1diag_15_1 == 0 .and. !empty(mdiag_15_2_1)
  ta := {mdiag_15_2_1}
  for k := 2 to 14
    mvar := "m1diag_15_2_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"15.3",ta})
endif
if m1diag_15_1 == 0 .and. !empty(mdiag_15_3_1)
  ta := {mdiag_15_3_1}
  for k := 2 to 14
    mvar := "m1diag_15_3_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"15.4",ta})
endif
if m1diag_15_1 == 0 .and. !empty(mdiag_15_4_1)
  ta := {mdiag_15_4_1}
  for k := 2 to 14
    mvar := "m1diag_15_4_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"15.5",ta})
endif
if m1diag_15_1 == 0 .and. !empty(mdiag_15_5_1)
  ta := {mdiag_15_5_1}
  for k := 2 to 14
    mvar := "m1diag_15_5_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"15.6",ta})
endif
aadd(arr,{"15.9",mGRUPPA_DO}) // "N1",группа здоровья до дисп-ии
aadd(arr,{"15.10",m1GR_FIZ_DO})  // "N1",группа здоровья для физкультуры
aadd(arr,{"16.1",m1diag_16_1}) // "N1",Состояние здоровья по результатам проведения диспансеризации (Практически здоров)
if m1diag_16_1 == 0 .and. !empty(mdiag_16_1_1)
  ta := {mdiag_16_1_1}
  for k := 2 to 16
    mvar := "m1diag_16_1_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"16.2",ta})
endif
if m1diag_16_1 == 0 .and. !empty(mdiag_16_2_1)
  ta := {mdiag_16_2_1}
  for k := 2 to 16
    mvar := "m1diag_16_2_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"16.3",ta})
endif
if m1diag_16_1 == 0 .and. !empty(mdiag_16_3_1)
  ta := {mdiag_16_3_1}
  for k := 2 to 16
    mvar := "m1diag_16_3_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"16.4",ta})
endif
if m1diag_16_1 == 0 .and. !empty(mdiag_16_4_1)
  ta := {mdiag_16_4_1}
  for k := 2 to 16
    mvar := "m1diag_16_4_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"16.5",ta})
endif
if m1diag_16_1 == 0 .and. !empty(mdiag_16_5_1)
  ta := {mdiag_16_5_1}
  for k := 2 to 16
    mvar := "m1diag_16_5_"+lstr(k)
    aadd(ta,&mvar)
  next
  aadd(arr,{"16.6",ta})
endif
if m1invalid1 == 1
  ta := {m1invalid1,m1invalid2,minvalid3,minvalid4,m1invalid5,m1invalid6,minvalid7,m1invalid8}
  aadd(arr,{"16.7",ta})   // массив из 8
endif
aadd(arr,{"16.8",mGRUPPA})    // "N1",группа здоровья после дисп-ии
aadd(arr,{"16.9",m1GR_FIZ})    // "N1",группа здоровья для физкультуры
if m1privivki1 > 0
  ta := {m1privivki1,m1privivki2,mprivivki3}
  aadd(arr,{"16.10",ta})  // массив из 4,Проведение профилактических прививок
endif
if !empty(mrek_form)
  aadd(arr,{"16.11",alltrim(mrek_form)}) // Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой
endif
if !empty(mrek_disp)
  aadd(arr,{"16.12",alltrim(mrek_disp)}) // Рекомендации по диспансерному наблюдению, лечению, медицинской реабилитации и санаторно-курортному лечению с указанием диагноза (код МКБ), вида медицинской организации и специальности (должности) врача
endif
// 18.результаты проведения исследований
for i := 1 to count_pn_arr_iss
  mvar := "MREZi"+lstr(i)
  if !empty(&mvar)
    aadd(arr,{"18."+lstr(i),alltrim(&mvar)})
  endif
next
if !empty(arr_usl_otkaz)
  aadd(arr,{"29",arr_usl_otkaz}) // массив
endif
if type("m1p_otk") == "N"
  aadd(arr,{"51",m1p_otk})
endif  
if type("m1napr_stac") == "N" 
  aadd(arr,{"54",m1napr_stac})
endif  
if type("m1profil_stac") == "N"       
  aadd(arr,{"55",m1profil_stac})
endif  
if type("m1napr_reab") == "N" 
  aadd(arr,{"56",m1napr_reab})
endif  
if type("m1profil_kojki") == "N"       
  aadd(arr,{"57",m1profil_kojki})
endif  
save_arr_DISPANS(lkod,arr)
return NIL

***** 07.05.18
Function read_arr_PN(lkod,is_all)
Local arr, i, k
DEFAULT is_all TO .t.
Private mvar
arr := read_arr_DISPANS(lkod)
for i := 1 to len(arr)
  if valtype(arr[i]) == "A" .and. valtype(arr[i,1]) == "C"
    if arr[i,1] == "1" .and. valtype(arr[i,2]) == "N"
      mperiod := arr[i,2]
    elseif is_all
      do case
        case arr[i,1] == "0" .and. valtype(arr[i,2]) == "N"
          m1mobilbr := arr[i,2]
        case arr[i,1] == "2" .and. valtype(arr[i,2]) == "N"
          m1mesto_prov := arr[i,2]
        case arr[i,1] == "5" .and. valtype(arr[i,2]) == "N"
          m1kateg_uch := arr[i,2]
        case arr[i,1] == "6" .and. valtype(arr[i,2]) == "C"
          m1MO_PR := arr[i,2]
        case arr[i,1] == "8" .and. valtype(arr[i,2]) == "N"
          m1school := arr[i,2]
        case arr[i,1] == "12.1" .and. valtype(arr[i,2]) == "N"
          mWEIGHT := arr[i,2]
        case arr[i,1] == "12.2" .and. valtype(arr[i,2]) == "N"
          mHEIGHT := arr[i,2]
        case arr[i,1] == "12.3" .and. valtype(arr[i,2]) == "N"
          mPER_HEAD := arr[i,2]
        case arr[i,1] == "12.4" .and. valtype(arr[i,2]) == "N"
          m1FIZ_RAZV := arr[i,2]
        case arr[i,1] == "12.4.1" .and. valtype(arr[i,2]) == "N"
          m1FIZ_RAZV1 := arr[i,2]
        case arr[i,1] == "12.4.2" .and. valtype(arr[i,2]) == "N"
          m1FIZ_RAZV2 := arr[i,2]
        case arr[i,1] == "13.1.1" .and. valtype(arr[i,2]) == "N"
          m1psih11 := arr[i,2]
        case arr[i,1] == "13.1.2" .and. valtype(arr[i,2]) == "N"
          m1psih12 := arr[i,2]
        case arr[i,1] == "13.1.3" .and. valtype(arr[i,2]) == "N"
          m1psih13 := arr[i,2]
        case arr[i,1] == "13.1.4" .and. valtype(arr[i,2]) == "N"
          m1psih14 := arr[i,2]
        case arr[i,1] == "13.2.1" .and. valtype(arr[i,2]) == "N"
          m1psih21 := arr[i,2]
        case arr[i,1] == "13.2.2" .and. valtype(arr[i,2]) == "N"
          m1psih22 := arr[i,2]
        case arr[i,1] == "13.2.3" .and. valtype(arr[i,2]) == "N"
          m1psih23 := arr[i,2]
        case arr[i,1] == "14.1.P" .and. valtype(arr[i,2]) == "N"
          m141p := arr[i,2]
        case arr[i,1] == "14.1.Ax" .and. valtype(arr[i,2]) == "N"
          m141ax := arr[i,2]
        case arr[i,1] == "14.1.Fa" .and. valtype(arr[i,2]) == "N"
          m141fa := arr[i,2]
        case arr[i,1] == "14.2.P" .and. valtype(arr[i,2]) == "N"
          m142p := arr[i,2]
        case arr[i,1] == "14.2.Ax" .and. valtype(arr[i,2]) == "N"
          m142ax := arr[i,2]
        case arr[i,1] == "14.2.Ma" .and. valtype(arr[i,2]) == "N"
          m142ma := arr[i,2]
        case arr[i,1] == "14.2.Me" .and. valtype(arr[i,2]) == "N"
          m142me := arr[i,2]
        case arr[i,1] == "14.2.Me1" .and. valtype(arr[i,2]) == "N"
          m142me1 := arr[i,2]
        case arr[i,1] == "14.2.Me2" .and. valtype(arr[i,2]) == "N"
          m142me2 := arr[i,2]
        case arr[i,1] == "14.2.Me3" .and. valtype(arr[i,2]) == "N"
          m1142me3 := arr[i,2]
        case arr[i,1] == "14.2.Me4" .and. valtype(arr[i,2]) == "N"
          m1142me4 := arr[i,2]
        case arr[i,1] == "14.2.Me5" .and. valtype(arr[i,2]) == "N"
          m1142me5 := arr[i,2]
        case arr[i,1] == "15.1" .and. valtype(arr[i,2]) == "N"
          m1diag_15_1 := arr[i,2]
        case arr[i,1] == "15.2" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
          mdiag_15_1_1 := arr[i,2,1]
          for k := 2 to 14
            if len(arr[i,2]) >= k
              mvar := "m1diag_15_1_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "15.3" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
          mdiag_15_2_1 := arr[i,2,1]
          for k := 2 to 14
            if len(arr[i,2]) >= k
              mvar := "m1diag_15_2_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "15.4" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
          mdiag_15_3_1 := arr[i,2,1]
          for k := 2 to 14
            if len(arr[i,2]) >= k
              mvar := "m1diag_15_3_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "15.5" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
          mdiag_15_4_1 := arr[i,2,1]
          for k := 2 to 14
            if len(arr[i,2]) >= k
              mvar := "m1diag_15_4_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "15.6" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 14
          mdiag_15_5_1 := arr[i,2,1]
          for k := 2 to 14
            if len(arr[i,2]) >= k
              mvar := "m1diag_15_5_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "15.9" .and. valtype(arr[i,2]) == "N"
          mGRUPPA_DO := arr[i,2]
        case arr[i,1] == "15.10" .and. valtype(arr[i,2]) == "N"
          m1GR_FIZ_DO := arr[i,2]
        case arr[i,1] == "16.1" .and. valtype(arr[i,2]) == "N"
          m1diag_16_1 := arr[i,2]
        case arr[i,1] == "16.2" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
          mdiag_16_1_1 := arr[i,2,1]
          for k := 2 to 16
            if len(arr[i,2]) >= k
              mvar := "m1diag_16_1_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "16.3" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
          mdiag_16_2_1 := arr[i,2,1]
          for k := 2 to 16
            if len(arr[i,2]) >= k
              mvar := "m1diag_16_2_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "16.4" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
          mdiag_16_3_1 := arr[i,2,1]
          for k := 2 to 16
            if len(arr[i,2]) >= k
              mvar := "m1diag_16_3_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "16.5" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
          mdiag_16_4_1 := arr[i,2,1]
          for k := 2 to 16
            if len(arr[i,2]) >= k
              mvar := "m1diag_16_4_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "16.6" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 16
          mdiag_16_5_1 := arr[i,2,1]
          for k := 2 to 16
            if len(arr[i,2]) >= k
              mvar := "m1diag_16_5_"+lstr(k)
              &mvar := arr[i,2,k]
            endif
          next
        case arr[i,1] == "16.7" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 8
          m1invalid1 := arr[i,2,1]
          m1invalid2 := arr[i,2,2]
          minvalid3  := arr[i,2,3]
          minvalid4  := arr[i,2,4]
          m1invalid5 := arr[i,2,5]
          m1invalid6 := arr[i,2,6]
          minvalid7  := arr[i,2,7]
          m1invalid8 := arr[i,2,8]
        case arr[i,1] == "16.8" .and. valtype(arr[i,2]) == "N"
          //mGRUPPA := arr[i,2]
        case arr[i,1] == "16.9" .and. valtype(arr[i,2]) == "N"
          m1GR_FIZ := arr[i,2]
        case arr[i,1] == "16.10" .and. valtype(arr[i,2]) == "A" .and. len(arr[i,2]) >= 3
          m1privivki1 := arr[i,2,1]
          m1privivki2 := arr[i,2,2]
          mprivivki3  := arr[i,2,3]
        case arr[i,1] == "16.11" .and. valtype(arr[i,2]) == "C"
          mrek_form := padr(arr[i,2],255)
        case arr[i,1] == "16.12" .and. valtype(arr[i,2]) == "C"
          mrek_disp := padr(arr[i,2],255)
        case is_all .and. arr[i,1] == "29" .and. valtype(arr[i,2]) == "A"
          arr_usl_otkaz := arr[i,2]
        case arr[i,1] == "51" .and. valtype(arr[i,2]) == "N"
          m1p_otk  := arr[i,2]
        case arr[i,1] == "54" .and. valtype(arr[i,2]) == "N"
          m1napr_stac := arr[i,2] 
        case arr[i,1] == "55" .and. valtype(arr[i,2]) == "N"
          m1profil_stac := arr[i,2]
        case arr[i,1] == "56" .and. valtype(arr[i,2]) == "N"
          m1napr_reab := arr[i,2]
        case arr[i,1] == "57" .and. valtype(arr[i,2]) == "N"
          m1profil_kojki := arr[i,2]
        otherwise
          for k := 1 to count_pn_arr_iss
            if arr[i,1] == "18."+lstr(k) .and. valtype(arr[i,2]) == "C"
              mvar := "MREZi"+lstr(k)
              &mvar := padr(arr[i,2],17)
            endif
          next
      endcase
    endif
  endif
next
return NIL

*

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

*

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

*

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

*

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

*

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

*

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
