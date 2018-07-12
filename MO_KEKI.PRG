***** mo_keki.prg - режимы информации для задачи "КЭК"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 29.11.17
Function kek_ret_s_70()
Local i, k, s := eks->EO_28
if type("p_ar") == "A"
  afill(p_ar,0)
  k := min(70,len(s))
  s := ""
  for i := 1 to k
    p_ar[i] := int(val(substr(eks->EO_28,i,1)))
    if i == 22 .and. p_ar[i] < 3 .and. p_ar[21] == 3
      p_ar[i] := 3 
    endif
    s += lstr(p_ar[i])
  next
endif
return s

*****
Function kek_prn_eks()
Local j, ao
if is_admin_kek()
  if (j := _work_eks(T_ROW,T_COL-5,@ao,.t.)) != NIL
    f3_kek_vvod(3,j,ao)
  endif
else
  f3_kek_vvod(3,,_work_otd(T_ROW,T_COL-5))
endif
return NIL

***** 12.06.17
Function kek_ret_shifr3()
Local j, fl, lshifr := space(8)
if select("human") == 0
  R_Use(dir_server+"human",,"human")
  goto (hu->kod_lu)
endif  
for j := 1 to len(menu_stac17_kek) // Критерии качества по группам заболеваний (состояний)
  if human->VZROS_REB == 0 // 0-взрослый
    fl := (menu_stac17_kek[j,2] == 1)
  else // ребенок
    fl := (menu_stac17_kek[j,3] == 1)
  endif
  if fl .and. ret_f_kek(human->kod_diag,menu_stac17_kek[j,4])
    lshifr := padr(menu_stac17_kek[j,1],8)
    exit
  endif 
next j
return lshifr

***** 27.03.17
Function kek_prn_karta(kek_human,rec_eks,art)
Local sb := {"A","B","C","D","K","P","R"}
Local ab, arr[2], i, lshifr, reg_print := 2, n_file := "ek_karta"+stxt
Private sh := 84, HH := 60
R_Use(dir_server+"organiz",,"ORG")
perenos(arr,org->name,49)
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",,"SCHET")
set relation to recno() into SCHET_
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART, to schet into SCHET
G_Use(dir_server+"mo_kekh",,"HU")
set relation to kod_lu into HUMAN
goto (kek_human)
Private is_2017 := (year(hu->K_DATA) > 2016)
G_Use(dir_server+"mo_keke",,"EKS")
goto (rec_eks)
ab := f_ball_kek(hu->ishod)
R_Use(dir_server+"base1",,"B1")
goto (eks->kod_eks)
mvrach := ""
if hu->vrach > 0
  R_Use(dir_server+"mo_pers",,"P2")
  goto (hu->vrach)
  mvrach := alltrim(p2->fio)
endif
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
if !is_2017
  add_string(padl("Приложение № 6",sh))
  add_string(padl("к приказу № 703 от 02.07.2007г.",sh))
  add_string("")
endif
add_string("           Эксперт                        Лечебно-профилактическое учреждение")
add_string(space(5)+padc(alltrim(crypt(b1->p1,gpasskod)),20)+space(10)+center(arr[1],49))
add_string(space(5)+padc(alltrim(crypt(b1->p5,gpasskod)),20)+space(10)+center(arr[2],49))
add_string("")
add_string(center("Экспертная карта № ______",sh))
add_string(center("по оценке качества и технологии оказания медицинской помощи",sh))
add_string("")
add_string(center("Паспортная часть",sh))
add_string('Отделение: "'+alltrim(inieditspr(A__POPUPMENU, dir_server+"mo_otd", hu->OTD))+'" ['+;
           {"стационар","днев.стационар","поликлиника"}[iif(between(hu->usl_ok,1,3),hu->usl_ok,1)]+"]")
add_string('Ф.И.О. лечащего врача: "'+mvrach+'"')
if hu->usl_ok == 3
  add_string("№ амбулаторной карты: "+hu->IST_BOL)
  add_string("Дата начала: "+full_date(human->N_DATA)+", окончания лечения: "+full_date(human->K_DATA))
else
  add_string("№ истории болезни: "+hu->IST_BOL)
  add_string("Дата поступления: "+full_date(human->N_DATA)+"  Дата выписки: "+full_date(human->K_DATA))
endif  
add_string('Ф.И.О. пациента: "'+alltrim(kart->FIO)+'"')
add_string('Пол: "'+iif(kart->pol=="М","1 муж.","2 жен.")+'"')
if hu->usl_ok == 1
  add_string("Проведено койко-дней: "+lstr(hu->KOJKO_DNI))
elseif hu->usl_ok == 2
  add_string("Проведено пациенто-дней: "+lstr(hu->KOJKO_DNI))
endif  
f1_ek("Источник средств существования",hu->IST_DOHOD,mm_7_kek)
add_string("Возраст: "+f2_ek(kart->date_r,human->N_DATA)+"  (дата рождения "+full_date(kart->date_r)+"г.)")
add_string("Житель: "+inieditspr(A__MENUVERT, mm_9_kek, hu->GITEL))
if hu->usl_ok == 3
  add_string("Первичный диагноз: "+alltrim(hu->DIAG_PRED))
else
  add_string("Диагноз при поступлении: "+alltrim(hu->DIAG_POST))
  add_string("Диагноз предварительный: "+alltrim(hu->DIAG_PRED))
endif
add_string("Диагноз заключительный клинический")
add_string(" - основной: "+alltrim(hu->KOD_DIAG)+" "+alltrim(hu->DIAG_OSN))
add_string(" - осложнение основного: "+alltrim(hu->DIAG_OSL))
add_string(" - сопутствующий: "+alltrim(hu->DIAG_SOP))
if hu->usl_ok < 3
  add_string(" - конкурирующий: "+alltrim(hu->DIAG_KON))
  f1_ek("Госпитализация больного в стационар",hu->PLAN_EKS,mm_13_kek)
endif  
f1_ek('"Согласие" больного на проведение лечебно-диагностических мероприятий',hu->SOGLASIE,mm_14_kek)
if hu->usl_ok < 3
  f1_ek("Пути поступления",hu->PUTI_POS,mm_15_kek)
  f1_ek("Поступление в данный стационар",hu->POST_ST,mm_16_kek)
  f1_ek("Госпитализирован по данному заболеванию",hu->GOSPIT,mm_17_kek)
endif
f1_ek("Исход заболевания",hu->ISHOD,mm_18_kek)
add_string("")
add_string(replicate("-",sh))
add_string("")
add_string(center("Экспертная оценка",sh))
if is_2017
  Private p_ar := array(70)
  s := kek_ret_s_70()
  if !(eks->EO_28 == s)
    select EKS
    G_RLock(forever)
    eks->EO_28 := s
    ab := f_ball_kek(hu->ishod)
    eks->O_E     := ab[1,8]
    eks->O_ALL   := ab[1,9]
    eks->p_zapol := f_p_zapol_kek(hu->ISHOD,is_2017)
    UnLock
    Commit
  endif
  R_Use(dir_exe+"_mo_kek",,"MK")
  index on fsort_usl(shifr) to (cur_dir+"tmp_mk") ;
        for left(shifr,4) == iif(hu->usl_ok==3,"2.1.","2.2.")
  go top
  do while !eof()
    s := alltrim(mk->name)
    do while eq_any(right(s,1),";",chr(13),chr(10))
      s := left(s,len(s)-1)
    enddo
    if mk->nn == 0
      f1_ek(s)
    elseif mk->nn > 0 .and. p_ar[mk->nn] < 3
      f1_ek(s,p_ar[mk->nn]-1,mm_danet)
    endif
    select MK
    skip
  enddo
  if hu->usl_ok < 3
    lshifr := kek_ret_shifr3()
    if !(hu->shifr3 == lshifr)
      select HU
      G_RLock(forever)
      hu->shifr3 := lshifr
      UnLock
      Commit
    endif
  endif
  if hu->usl_ok < 3 .and. !empty(hu->shifr3)
    select MK
    index on fsort_usl(shifr) to (cur_dir+"tmp_mk") for shifr == hu->shifr3
    go top
    do while !eof()
      s := alltrim(mk->name)
      do while eq_any(right(s,1),";",chr(13),chr(10))
        s := left(s,len(s)-1)
      enddo
      if mk->nn == 0
        f1_ek(s+":")
      elseif mk->nn > 0 .and. p_ar[mk->nn] < 3
        f1_ek("- "+s,p_ar[mk->nn]-1,mm_danet)
      endif
      select MK
      skip
    enddo
  endif
else
  f1_ek(" 1. Состояние больного при поступлении в стационар",eks->EO_1,menu_1_kek)
  f1_ek(" 2. Объем описания состояния больного при поступлении в стационар",eks->EO_2,menu_2_kek)
  f1_ek(" 3. Соответствие диагнозов рубрификации МКБ-10")
  f1_ek("    - при поступлении",eks->EO_3_POST,menu_3_kek)
  f1_ek("    - предварительный",eks->EO_3_PRED,menu_3_kek)
  f1_ek("    - заключительный клинический",eks->EO_3_OSN,menu_3_kek)
  add_string(" 4. План обследования и лечения больного: "+iif(eks->EO_4==2,"4.2. Имеется","4.1. Отсутствует"))
  if eks->EO_4 == 2  //  4.2. Имеется (далее пункты 4.2.1. и 4.2.2)
    f1_ek("  4.2.1 Своевременность",eks->EO_4_2_1,menu_4_2_1_kek)
    f1_ek("  4.2.2 Обоснованность",eks->EO_4_2_2,menu_4_2_2_kek)
  endif
  f1_ek(" 5. Наличие ежедневных дневниковых записей",eks->EO_5,menu_5_kek)
  f1_ek(" 6. Отражают ли дневниковые записи эффект от проводимой терапии",eks->EO_6,menu_6_kek)
  f1_ek(" 7. Оформление медицинской документации",eks->EO_7,menu_7_kek)
  f1_ek(" 8. Наличие дневников динамического круглосуточного наблюдения тяжелого больного",eks->EO_8,menu_8_kek)
  f1_ek(" 9. Наличие записей заведующего отделением в истории болезни (в случае, если зав.отделением не был лечащим врачом)",eks->EO_9,menu_9_kek)
  f1_ek("10. Своевременность и объем диагностических мероприятий",eks->EO_10,menu_10_kek)
  f1_ek("11. Оценка результатов диагностических исследований")
  if !emptyall(eks->EO_11_L_1,eks->EO_11_L_2,eks->EO_11_L_3,eks->EO_11_L_4,eks->EO_11_L_5)
    f1_ek("  Лабораторные методы исследования")
    if !empty(eks->EO_11_L_1)
      f1_ek("  - общий анализ крови",eks->EO_11_L_1,menu_11_kek)
    endif
    if !empty(eks->EO_11_L_2)
      f1_ek("  - общий анализ мочи",eks->EO_11_L_2,menu_11_kek)
    endif
    if !empty(eks->EO_11_L_3)
      f1_ek("  - биохимический анализ крови",eks->EO_11_L_3,menu_11_kek)
    endif
    if !empty(eks->EO_11_L_4)
      f1_ek("  - анализ крови на глюкозу",eks->EO_11_L_4,menu_11_kek)
    endif
    if !empty(eks->EO_11_L_5)
      f1_ek("  - прочие",eks->EO_11_L_5,menu_11_kek)
    endif
  endif
  if !emptyall(eks->EO_11_I_1,eks->EO_11_I_2,eks->EO_11_I_3,eks->EO_11_I_4)
    f1_ek("  Инструментальные методы исследования")
    if !empty(eks->EO_11_I_1)
      f1_ek("  - ЭКГ",eks->EO_11_I_1,menu_11_kek)
    endif
    if !empty(eks->EO_11_I_2)
      f1_ek("  - УЗИ",eks->EO_11_I_2,menu_11_kek)
    endif
    if !empty(eks->EO_11_I_3)
      f1_ek("  - ФГС",eks->EO_11_I_3,menu_11_kek)
    endif
    if !empty(eks->EO_11_I_4)
      f1_ek("  - прочие",eks->EO_11_I_4,menu_11_kek)
    endif
  endif
  if !emptyall(eks->EO_11_R_1,eks->EO_11_R_2,eks->EO_11_R_3,eks->EO_11_R_4)
    f1_ek("  Рентгенографические методы исследования")
    if !empty(eks->EO_11_R_1)
      f1_ek("  - рентгенография",eks->EO_11_R_1,menu_11_kek)
    endif
    if !empty(eks->EO_11_R_2)
      f1_ek("  - КТ",eks->EO_11_R_2,menu_11_kek)
    endif
    if !empty(eks->EO_11_R_3)
      f1_ek("  - ЯМР",eks->EO_11_R_3,menu_11_kek)
    endif
    if !empty(eks->EO_11_R_4)
      f1_ek("  - прочие",eks->EO_11_R_4,menu_11_kek)
    endif
  endif
  f1_ek("12. Клинический заключительный диагноз",eks->EO_12,menu_12_kek)
  f1_ek("13. Соответствие проводимого лечения выставленному диагнозу",eks->EO_13,menu_13_kek)
  f1_ek("14. Лечение начато",eks->EO_14,menu_14_kek)
  f1_ek("15. Комбинации лекарственных средств, используемых при лечении",eks->EO_15,menu_15_kek)
  f1_ek("16. Дозировка лекарственных препаратов в листах назначения",eks->EO_16,menu_16_kek)
  f1_ek("17. Соответствие сроков лечения стандартам, принятым по данному заболеванию при выписке больного из стационара",eks->EO_17,menu_17_kek)
  if eks->EO_18 > 0
    f1_ek("18. Реанимационные мероприятия в случае их необходимости, проведены",eks->EO_18,menu_18_kek)
  endif
  f1_ek("19. Консилиум и осмотр специалистами в данном случае",eks->EO_19,menu_19_kek)
  f1_ek("20. Обращение за консультацией к главным внештатным специалистам",eks->EO_20,menu_20_kek)
  if eks->EO_21 > 0
    f1_ek("21. Выполнение рекомендации консультантов",eks->EO_21,menu_21_kek)
  endif
  f1_ek("22. Существовала необходимость в переводе больного в специализированное отделение, учреждение",eks->EO_22,menu_22_kek)
  if eks->EO_22 == 1
    f1_ek("23. В случае необходимости перевод больного в специализированное отделение, учреждение произведен",eks->EO_23,menu_23_kek)
  endif
  f1_ek("24. Этапные эпикризы при пребывании в стационаре более трех недель",eks->EO_24,menu_24_kek)
  if hu->ISHOD == 5
    f1_ek("25. В случае летального исхода вскрытие",eks->EO_25,menu_25_kek)
    f1_ek("26. Карта разбора летального исхода на КИЛИ",eks->EO_26,menu_26_kek)
    f1_ek("27. Замечания к карте разбора летального исхода на КИЛИ",eks->EO_27,menu_27_kek)
    f1_ek("28. Патологоанатомический диагноз: "+alltrim(eks->EO_28))
    f1_ek("29. Оценка расхождения заключительного клинического и патологоанатомического диагнозов",eks->EO_29,menu_29_kek)
    f1_ek("30. Оформление посмертного эпикриза",eks->EO_30,menu_30_kek)
  endif
endif  
verify_FF(HH-4-eks->N_ZAKLUCH,.f.,sh)
i := 0
Use_base("mo_kekez")
find (str(eks->(recno()),7))
do while eksz->kod == eks->(recno()) .and. !eof()
  ++i
  if i == 1
    add_string(" Заключение: "+rtrim(eksz->name))
  else
    add_string("             "+rtrim(eksz->name))
  endif
  skip
enddo
if is_2017
  //
else
  add_string("")
  s := "Баллы:"
  for i := 1 to 7
    s += " "+sb[i]+" = "
    if ab[2,i] == 0
      s += '"-"'
    else
      s += alltrim(_put_ocen(ab[1,i],ab[2,i]))
    endif
    if i < 7 ; s += "," ; endif
  next
  add_string(s)
endif
if mem_ball_kek == 0
  add_string("Итого: E = "+lstr(ab[1,8])+",  оценка: "+inieditspr(A__MENUVERT, mm_ocenka_kek, ab[1,9]))
else
  add_string("Итого: E = "+alltrim(_put_ocen(ab[1,8])))
endif
add_string("")
add_string('____________________________                "___"_______________201__г.')
add_string("     Подпись эксперта")
close databases
fclose(fp)
viewtext(n_file,,,,(sh>80),,,reg_print)
return NIL

*****
Static Function f1_ek(s,lvar,lmenu)
Local arr[5], i, k
if lvar != NIL
  s += ': "'+alltrim(inieditspr(A__MENUVERT,lmenu,lvar))+'"'
endif
k := perenos(arr,s,sh-2)
verify_FF(HH-k,.f.,sh)
add_string(arr[1])
for i := 2 to k
  add_string(space(2)+alltrim(arr[i]))
next
return NIL

*****
Static Function f2_ek(ldate_r,lN_DATA)
Local s, v := count_years(ldate_r,lN_DATA)
if v < 20
  s := "1. до 20 лет"
elseif v < 30
  s := "2. 20-29"
elseif v < 40
  s := "3. 30-39"
elseif v < 50
  s := "4. 40-49"
elseif v < 55
  s := "5. 50-54"
elseif v < 60
  s := "6. 55-59"
elseif v < 70
  s := "7. 60-69"
else
  s := "8. 70 и более"
endif
return '"'+s+'"'

***** 19.12.17
Function kek_info2017(k)
Static sk := 1, si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 1
Local mas_pmt, mas_msg, mas_fun, i, j
DEFAULT k TO 1
/*Количественный анализ экпертиз  
  по отделениям
    Список отделений
    Отделение + больные
  по экспертам
    Список экспертов
    Эксперт + больные
  по врачам
    Список врачей
    Врач + больные
  по поводам экспертизы
    Список поводов
    Повод + больные*/
do case
  case k == 1
    mas_pmt := {"Сводные результаты экспертной оценки качества",;
                "Дефекты качества по группам критериев",;
                "Количественный анализ экпертиз",;  
                "Журнал учёта КЭР МО",;
                "Качество и безопасность"}
    mas_msg := {"Сводные результаты экспертной оценки качества по учреждению",;
                "Характеристика дефектов качества в разрезе подразделений, врачей, экспертов",;
                "Количественный анализ экпертиз качества",;  
                "Журнал учёта клинико-экспертной работы медицинской организации",;
                "Распечатка отчётов по контролю качества и безопасности медицинской деятельности"}
    mas_fun := {"kek_info2017(11)",;
                "kek_info2017(12)",;
                "kek_info2017(13)",;
                "kek_info2017(14)",;
                "kek_info2017(15)"}
    Private arr_m, ke, is_2017 := .t.            
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11 // Сводные результаты экспертной оценки качества
    kek_svod_rez_17()
  case k == 12 // Дефекты качества по группам критериев
    mas_pmt := {"по учреждению",;
                "по отделению",;
                "по эксперту",;
                "по поводу экспертизы",;
                "по врачу",;
                "Динамика за 2 года"}
    mas_msg := {"Характеристика дефектов качества по учреждению",;
                "Характеристика дефектов качества по отделению",;
                "Характеристика дефектов качества по эксперту (список больных)",;
                "Характеристика дефектов качества по поводу экспертизы (список больных)",;
                "Характеристика дефектов качества по врачу (список больных)",;
                "Динамика уровней профилей индикаторов по результатам экспертной работы"}
    mas_fun := {"kek_info2017(21)",;
                "kek_info2017(22)",;
                "kek_info2017(23)",;
                "kek_info2017(24)",;
                "kek_info2017(25)",;
                "kek_info2017(26)"}
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 13 // Количественный анализ экпертиз
    mas_pmt := {"по отделениям",;
                "по врачам",;
                "по экспертам",;
                "по поводам экспертизы"}
    mas_msg := {"Количественный анализ экпертиз по отделениям",;
                "Количественный анализ экпертиз по врачам",;
                "Количественный анализ экпертиз по экспертам",;
                "Количественный анализ экпертиз по поводам экспертизы"}
    mas_fun := {"kek_info2017(31)",;
                "kek_info2017(32)",;
                "kek_info2017(33)",;
                "kek_info2017(34)"}
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)
  case k == 14 // Журнал учёта КЭР МО
    kek_prn_pril14()
  case k == 15 // Качество и безопасность
    kek_k_and_b()
  case k == 21  
    mas_pmt := {"по отделениям",;
                "по экспертам",;
                "по поводам экспертизы",;
                "по врачам"}
    mas_msg := {"Характеристика дефектов качества по отделениям",;
                "Характеристика дефектов качества по экспертам",;
                "Характеристика дефектов качества по поводам экспертизы",;
                "Характеристика дефектов качества по врачам"}
    mas_fun := {"kek_info2017(41)",;
                "kek_info2017(42)",;
                "kek_info2017(43)",;
                "kek_info2017(44)"}
    popup_prompt(T_ROW,T_COL-5,si4,mas_pmt,mas_msg,mas_fun)
  case k == 22  
    mas_pmt := {"по экспертам",;
                "по поводам экспертизы",;
                "по врачам",;
                "по больным"}
    mas_msg := {"Характеристика дефектов качества по экспертам в конкретном отделении",;
                "Характеристика дефектов качества по поводам экспертизы в конкретном отделении",;
                "Характеристика дефектов качества по врачам в конкретном отделении",;
                "Характеристика дефектов качества по больным в конкретном отделении"}
    mas_fun := {"kek_info2017(51)",;
                "kek_info2017(52)",;
                "kek_info2017(53)",;
                "kek_info2017(54)"}
    popup_prompt(T_ROW,T_COL-5,si5,mas_pmt,mas_msg,mas_fun)
  case k == 23  
    if (arr_m := year_month(T_ROW,T_COL-5)) != NIL .and. (ke := _work_eks(T_ROW,T_COL-5,,.f.)) != NIL
      kek_har_def_17(5,2)
    endif
  case k == 24  
    if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
      i := popup_2array(menu_povod_kek,T_ROW,T_COL-5,sk,1,@ke)
      if valtype(ke) == "A"
        sk := ke[2]
        kek_har_def_17(5,3)
      endif
    endif
  case k == 25  
    if (arr_m := year_month(T_ROW,T_COL-5)) != NIL .and. ret_kek_vr(,T_ROW,T_COL-5,arr_m) != NIL
      kek_har_def_17(5,4)
    endif
  case k == 26  
    kek_prn_pril7(13)
  case k == 31  
    kek_inf_otd()
  case k == 32  
    kek_inf_vrach()
  case k == 33
    kek_inf_eks()
  case k == 34
    kek_inf_povod()
  case between(k,41,49)
    if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
      kek_har_def_17(k-40)
    endif  
  case between(k,51,59)
    if (arr_m := year_month(T_ROW,T_COL-5)) != NIL .and. ret_kek_otd(,T_ROW,T_COL-5,arr_m) != NIL
      kek_har_def_17(k-50+1,1) // par=2,3,4 par2=1
    endif
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  elseif between(k,31,39)
    si3 := j
  elseif between(k,41,49)
    si4 := j
  elseif between(k,51,59)
    si5 := j
  endif
endif
return NIL

*

***** 29.06.17
Function kek_info2016(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Приложение №~7",;
                "Приложение №~14",;
                "По ~экспертам",;
                "~Повод экспертизы",;
                "для ~Облздрава",;
                "Качество и ~безопасность"}
    mas_msg := {"Распечатка таблиц из приложения №7",;
                "Распечатка таблицы из приложения №14",;
                "Получение информации по экспертам",;
                "Получение информации по поводу экспертизы",;
                "Распечатка таблиц для Облздрава",;
                "Распечатка отчётов по контролю качества и безопасности медицинской деятельности"}
    mas_fun := {"kek_info2016(11)",;
                "kek_info2016(12)",;
                "kek_info2016(13)",;
                "kek_info2016(14)",;
                "kek_info2016(15)",;
                "kek_info2016(16)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    kek_prn_pril7()
  case k == 12
    kek_prn_pril14()
  case k == 13
    kek_inf_eks()
  case k == 14
    kek_inf_povod()
  case k == 15
    kek_oblzdrav()
  case k == 16
    kek_k_and_b()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

***** 26.06.13
Function kek_prn_pril7(k)
Static si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Таблицы ~3-4",;
                "Таблицы ~5-11",;
                "Таблица ~12"}
    mas_msg := {"Количественная хар-ка профилей индикаторов по врачам, отделениям и больнице",;
                "Количественная характеристика индикаторов качества (блоки A-R)",;
                "Динамика уровней профилей индикаторов по результатам экспертной работы"}
    mas_fun := {"kek_prn_pril7(11)",;
                "kek_prn_pril7(12)",;
                "kek_prn_pril7(13)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case between(k,11,13)
    do case
      case k == 11
        mas_pmt := {"Таблица ~3 (по больнице)",;
                    "Таблица ~4 (по отделению)",;
                    "~Врач + больные",;
                    "По ~экспертам",;
                    "~Поводы экспертизы",;
                    "~Уровни экспертизы"}
        mas_msg := {"Количественная хар-ка профилей индикаторов по отделениям и больнице в целом",;
                    "Количественная хар-ка профилей индикаторов в разрезе конкретного отделения",;
                    "Количественная хар-ка профилей индикаторов в разрезе конкретного врача",;
                    "Количественная хар-ка профилей индикаторов по экспертам",;
                    "Количественная хар-ка профилей индикаторов по поводам экспертизы",;
                    "Количественная хар-ка профилей индикаторов по уровням экспертизы"}
        mas_fun := {"kek_prn_pril7(21)",;
                    "kek_prn_pril7(22)",;
                    "kek_prn_pril7(23)",;
                    "kek_prn_pril7(24)",;
                    "kek_prn_pril7(25)",;
                    "kek_prn_pril7(26)"}
        popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
      case k == 12
        mas_pmt := {"Таблица  ~5 (Блок А)",;
                    "Таблица  ~6 (Блок В)",;
                    "Таблица  ~7 (Блок С)",;
                    "Таблица  ~8 (Блок D)",;
                    "Таблица  ~9 (Блок К)",;
                    "Таблица 1~0 (Блок Р)",;
                    "Таблица 1~1 (Блок R)"}
        mas_msg := {"(Блок А) Колич.хар-ка индикаторов качества ведения медицинской документации",;
                    "(Блок В) Колич.хар-ка индикаторов качества диагностических мероприятий",;
                    "(Блок С) Колич.хар-ка индикаторов качества постановки диагноза",;
                    "(Блок D) Колич.хар-ка индикаторов качества лечебно-профилактических мероприятий",;
                    "(Блок К) Колич.хар-ка индикаторов качества проведения консультаций",;
                    "(Блок Р) Колич.хар-ка индикаторов качества лечебно-диагностических мероприятий",;
                    "(Блок R) Колич.хар-ка индикаторов качества экспертного заключения при летальном исходе"}
        mas_fun := {"kek_prn_pril7(31)",;
                    "kek_prn_pril7(32)",;
                    "kek_prn_pril7(33)",;
                    "kek_prn_pril7(34)",;
                    "kek_prn_pril7(35)",;
                    "kek_prn_pril7(36)",;
                    "kek_prn_pril7(37)"}
        popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)
      case k == 13
        mas_pmt := {"По ~учреждению",;
                    "По ~отделению",;
                    "По ~врачу",;
                    "По ~эксперту",;
                    "По ~диагнозу"}
        if (arr_m := ret_2_diap()) != NIL .and. ;
             (j := popup_prompt(T_ROW,T_COL-5,si5,mas_pmt)) > 0
          si5 := j
          do case
            case si5 == 1
              kek_p7_t12(si5)
            case si5 == 2
              if ret_kek_otd(,T_ROW,T_COL-5,arr_m,2) != NIL
                kek_p7_t12(si5)
              endif
            case si5 == 3
              if ret_kek_vr(,T_ROW,T_COL-5,arr_m,2) != NIL
                kek_p7_t12(si5)
              endif
            case si5 == 4
              if (j := _work_eks(T_ROW,T_COL-5,,.f.,arr_m[2,1],arr_m[1,2])) != NIL
                kek_p7_t12(si5,j)
              endif
            case si5 == 5
              kek_p7_t12_mkb(T_ROW)
          endcase
        endif
    endcase
  otherwise
    if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
      do case
        case k == 21
          kek_p7_t3(1)
        case k == 22
          if ret_kek_otd(,T_ROW,T_COL-5,arr_m) != NIL
            kek_p7_t3(2)
          endif
        case k == 23
          if ret_kek_vr(,T_ROW,T_COL-5,arr_m) != NIL
            kek_p7_t3(3)
          endif
        case k == 24
          kek_p7_t3(4)
        case k == 25
          kek_p7_t3(5)
        case k == 26
          kek_p7_t3(6)
        case between(k,31,37)
          mas_pmt := {"~Учреждение + врачи",;
                      "~Отделение + врачи",;
                      "Учреждение + ~больные",;
                      "Отделение + бо~льные",;
                      "~Врач + больные",;
                      "Учреждение + ~эксперты"}
          if (j := popup_prompt(T_ROW,T_COL-5,si4,mas_pmt)) > 0
            si4 := j
            if eq_any(si4,1,3)
              kek_p7_t5(1,iif(si4==1,1,2),k-30)
            elseif si4 == 6
              kek_p7_t5(1,3,k-30)
            elseif eq_any(si4,2,4)
              if ret_kek_otd(,T_ROW,T_COL-5,arr_m) != NIL
                kek_p7_t5(2,iif(si4==2,1,2),k-30)
              endif
            elseif ret_kek_vr(,T_ROW,T_COL-5,arr_m) != NIL
              kek_p7_t5(3,2,k-30)
            endif
          endif
      endcase
    endif
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  elseif between(k,31,39)
    si3 := j
  endif
endif
return NIL

***** 11.07.18
Function kek_p7_t3(par)
Local sb := {"a","b","c","d","k","p","r","e"}
Local adbf, ab, i, poleK, poleO, aitog[8], kitog[8],;
      sh, HH := 52, reg_print, n_file := "pr7_tb"+lstr(par+2)+stxt
afill(aitog,0) ; afill(kitog,0) ; skol := 0
mywait()
adbf := {;
  {"kod",  "N", 7, 0},;
  {"kol",  "N", 6, 0},;
  {"K_A",  "N", 1, 0},;   // коэф-т A
  {"K_B",  "N", 1, 0},;   // коэф-т B
  {"K_C",  "N", 1, 0},;   // коэф-т C
  {"K_D",  "N", 1, 0},;   // коэф-т D
  {"K_K",  "N", 1, 0},;   // коэф-т K
  {"K_P",  "N", 1, 0},;   // коэф-т P
  {"K_R",  "N", 1, 0},;   // коэф-т R
  {"K_E",  "N", 1, 0},;   // коэф-т E
  {"O_A",  "N", 5, 3},;   // оценка A
  {"O_B",  "N", 5, 3},;   // оценка B
  {"O_C",  "N", 5, 3},;   // оценка C
  {"O_D",  "N", 5, 3},;   // оценка D
  {"O_K",  "N", 5, 3},;   // оценка K
  {"O_P",  "N", 5, 3},;   // оценка P
  {"O_R",  "N", 5, 3},;   // оценка R
  {"O_E",  "N", 5, 3}}    // оценка E
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
R_Use(dir_server+"base1",,"B1")
R_Use(dir_server+"human",,"HUMAN")
R_Use(dir_server+"mo_kekh",,"HU")
set relation to kod_lu into HUMAN
R_Use(dir_server+"mo_keke",dir_server+"mo_keked","EKS")
// index on dtos(date_eks) to (dir_server+"mo_keked") 
set relation to kod into HU
dbseek(dtos(arr_m[5]),.t.)
do while eks->date_eks <= arr_m[6] .and. !eof()
  fl := .t.
  if par == 2
    fl := hu->otd==kek_otd[1]
  elseif par == 3
    fl := hu->vrach==kek_vrach[1]
  endif
  if fl
    ab := f_ball_kek(hu->ishod)
    select TMP
    append blank
    do case
      case par == 1
        tmp->kod := hu->otd
      case par == 2
        tmp->kod := hu->vrach
      case par == 3
        tmp->kod := hu->(recno())
      case par == 4
        tmp->kod := eks->kod_eks
      case par == 5
        tmp->kod := hu->POVOD_EKS
      case par == 6
        b1->(dbGoto(eks->kod_eks))
        tmp->kod := b1->p6
    endcase
    for i := 1 to 8
      poleK := "tmp->k_"+sb[i]
      poleO := "tmp->o_"+sb[i]
      &poleK := ab[2,i]
      &poleO := ab[1,i]
      if &poleK > 0
        aitog[i] += &poleO
        kitog[i] ++
      endif
    next
  endif
  select EKS
  skip
enddo
//
dbcreate(cur_dir+"tmp2",adbf)
use (cur_dir+"tmp2") new
index on str(kod,7) to (cur_dir+"tmp2")
select TMP
go top
do while !eof()
  select TMP2
  find (str(tmp->kod,7))
  if !found()
    append blank
    tmp2->kod := tmp->kod
  endif
  ++ tmp2->kol
  select TMP
  skip
enddo
select TMP
index on str(kod,7) to (cur_dir+"tmp")
select TMP2
go top
do while !eof()
  skol += tmp2->kol
  select TMP
  for i := 1 to 8
    poleK := "tmp->k_"+sb[i]
    poleO := "tmp->o_"+sb[i]
    b := k := 0
    find (str(tmp2->kod,7))
    do while tmp->kod == tmp2->kod
      if &poleK > 0
        ++k ; b += &poleO
      endif
      skip
    enddo
    poleK := "tmp2->k_"+sb[i]
    poleO := "tmp2->o_"+sb[i]
    if k > 0
      &poleK := 1
      &poleO := b/k
    endif
  next
  select TMP2
  skip
enddo
//
do case
  case par == 1
    s := "Структурные подразделения"
  case par == 2
    s := "Ф.И.О. врача"
  case par == 3
    s := "Ф.И.О. больного"
  case par == 4
    s := "Ф.И.О. эксперта"
  case par == 5
    s := "Повод экспертизы"
  case par == 6
    s := "Уровень экспертизы"
endcase
arr_title := {;
"──────────────────────────────┬──────┬───────────────────────────────────────────────────────────────────────────────────────",;
"                              │      │                            Профили индикаторов",;
"                              │Кол-во├──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────",;
"                              │экспер│    А     │    В     │    С     │    D     │    К     │    Р     │    R     │    Е     ",;
             padc(s,30)      +"│тиз   │ качество │диагности-│постановка│лечебно-  │консульта-│преемстве-│экспертное│инт.оценка",;
"                              │      │ ведения  │ческие    │ диагноза │профилакти│   ции    │ нность   │заключение│качества и",;
"                              │      │ докумен- │мероприя- │          │ческие ме-│          │          │при леталь│технологии",;
"                              │      │ тации    │тия       │          │роприятия │          │          │ном исходе│оказанияМП",;
"──────────────────────────────┴──────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────"}
reg_print := 5
f_reg_print(arr_title,@sh)
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
stable := stitle := stitle2 := ""
if par == 1
  stable := "Таблица 3"
  stitle := "Количественная характеристика профилей индикаторов и интегрированная оценка уровня качества лечения"
  stitle2 := "по отделениям и больнице в целом"
elseif par == 2
  stable := "Таблица 4"
  stitle := "Количественная характеристика профилей индикаторов и интегрированная оценка уровня качества лечения"
  stitle2 := 'в разрезе отделения: "'+alltrim(kek_otd[2])+'"'
elseif par == 3
  stitle := 'Профили индикаторов по врачу: "'+alltrim(kek_vrach[2])+'"'
elseif par == 4
  stitle := 'Профили индикаторов по экспертам'
elseif par == 5
  stitle := 'Профили индикаторов по поводам экспертизы'
elseif par == 6
  stitle := 'Профили индикаторов по уровню экспертизы'
endif
add_string(padl(stable,sh))
add_string(center(stitle,sh))
add_string(center(stitle2,sh))
add_string(center(arr_m[4],sh))
aeval(arr_title, {|x| add_string(x) } )
//
close databases
if par == 1
  R_Use(dir_server+"mo_otd",,"OV")
elseif par == 2
  R_Use(dir_server+"mo_pers",,"OV")
elseif par == 3
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to kod_k into KART
  R_Use(dir_server+"mo_kekh",,"OV")
  set relation to kod_lu into HUMAN
elseif par == 4
  R_Use(dir_server+"base1",,"OV")
endif
use (cur_dir+"tmp2") new
if par <= 4
  set relation to kod into OV
  if par == 1
    index on upper(ov->name) to (cur_dir+"tmp2")
  elseif par == 2
    index on upper(ov->fio) to (cur_dir+"tmp2")
  elseif par == 3
    index on upper(kart->fio) to (cur_dir+"tmp2")
  else
    index on ov->(recno()) to (cur_dir+"tmp2")
  endif
else
  index on kod to (cur_dir+"tmp2")
endif
go top
do while !eof()
  if par == 1
    s := ov->name
  elseif par == 2
    s := ov->fio
  elseif par == 3
    s := padr(fam_i_o(kart->fio),22)+date_8(human->k_data)
  elseif par == 4
    s := alltrim(crypt(ov->p1,gpasskod))+"/"+alltrim(crypt(ov->p5,gpasskod))
  elseif par == 5
    s := inieditspr(A__MENUVERT, menu_povod_kek, tmp2->kod)
  elseif par == 6
    s := "Уровень экспертизы "+lstr(tmp2->kod)
  endif
  s := padr(s,30)+str(tmp2->kol,7)
  for i := 1 to 8
    poleK := "tmp2->k_"+sb[i]
    poleO := "tmp2->o_"+sb[i]
    s += _put_ocen(&poleO,&poleK)
  next
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(s)
  add_string(replicate("─",sh))
  select TMP2
  skip
enddo
if eq_any(par,1,4,5,6)
  s := "Учреждение"
elseif par == 2
  s := "Отделение"
else
  s := "По врачу"
endif
s += " в целом"
s := padc(s,30)+str(skol,7)
if par < 4
  for i := 1 to 8
    if kitog[i] > 0
      s += _put_ocen(aitog[i]/kitog[i])
    else
      s += space(11)
    endif
  next
endif
add_string(s)
fclose(fp)
close databases
Private yes_albom := .t.
viewtext(n_file,,,,(sh>80),,,reg_print)
return NIL

***** 26.06.13
Static Function _put_ocen(v,k,l)
Local s, n := iif(mem_ball_kek == 0, 3, 2)
DEFAULT k TO 1, l TO 11
if empty(k)
  s := space(l-n-2)+"-"+space(n+1)
else
  if mem_ball_kek == 1
    v *= 5
  endif
  s := str_0(v,l,n)
endif
return s

***** 11.07.18
Function kek_p7_t5(par1,par2,par3)
// par1: 1-учреждение, 2-отделение, 3-врач
// par2: 1-врачи, 2-больные, 3-эксперты
// par3: от 1 до 7 (от A до R)
Local adbf, ab, i, poleK, poleO, aitog[8], kitog[8],;
      sh, HH := 52, reg_print, ar1, ar2, t_arr[2],;
      n_file := "pr7_t"+lstr(par1)+lstr(par2)+lstr(par3)+stxt
afill(aitog,0) ; afill(kitog,0) ; skol := 0
mywait()
adbf := {;
  {"kod",  "N", 7, 0},;
  {"kol",  "N", 6, 0},;
  {"K_K",  "N", 1, 0},;
  {"K_1",  "N", 1, 0},;
  {"K_2",  "N", 1, 0},;
  {"K_3",  "N", 1, 0},;
  {"K_4",  "N", 1, 0},;
  {"K_5",  "N", 1, 0},;
  {"K_6",  "N", 1, 0},;
  {"K_7",  "N", 1, 0},;
  {"O_K",  "N", 5, 3},;
  {"O_1",  "N", 5, 3},;
  {"O_2",  "N", 5, 3},;
  {"O_3",  "N", 5, 3},;
  {"O_4",  "N", 5, 3},;
  {"O_5",  "N", 5, 3},;
  {"O_6",  "N", 5, 3},;
  {"O_7",  "N", 5, 3}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
R_Use(dir_server+"human",,"HUMAN")
R_Use(dir_server+"mo_kekh",,"HU")
set relation to kod_lu into HUMAN
R_Use(dir_server+"mo_keke",dir_server+"mo_keked","EKS")
// index on dtos(date_eks) to (dir_server+"mo_keked") 
set relation to kod into HU
dbseek(dtos(arr_m[5]),.t.)
do while eks->date_eks <= arr_m[6] .and. !eof()
  fl := .t.
  if par1 == 2
    fl := hu->otd==kek_otd[1]
  elseif par1 == 3
    fl := hu->vrach==kek_vrach[1]
  endif
  if fl
    f_ball_kek(hu->ishod,par3,@ar1,@ar2)
    select TMP
    append blank
    if par2 == 1
      tmp->kod := hu->vrach
    elseif par2 == 2
      tmp->kod := hu->(recno())
    else
      tmp->kod := eks->kod_eks
    endif
    tmp->o_k := ar2[1]
    tmp->k_k := ar2[2]
    for i := 1 to 7
      poleK := "tmp->k_"+lstr(i)
      poleO := "tmp->o_"+lstr(i)
      &poleO := ar1[i,1]
      &poleK := ar1[i,2]
      if &poleK > 0
        aitog[i] += &poleO
        kitog[i] ++
      endif
    next
  endif
  select EKS
  skip
enddo
//
dbcreate(cur_dir+"tmp2",adbf)
use (cur_dir+"tmp2") new
index on str(kod,7) to (cur_dir+"tmp2")
select TMP
go top
do while !eof()
  select TMP2
  find (str(tmp->kod,7))
  if !found()
    append blank
    tmp2->kod := tmp->kod
  endif
  ++ tmp2->kol
  select TMP
  skip
enddo
select TMP
index on str(kod,7) to (cur_dir+"tmp")
select TMP2
go top
do while !eof()
  skol += tmp2->kol
  select TMP
  for i := 1 to 8
    if i == 8
      poleK := "tmp->k_k"
      poleO := "tmp->o_k"
    else
      poleK := "tmp->k_"+lstr(i)
      poleO := "tmp->o_"+lstr(i)
    endif
    b := k := 0
    find (str(tmp2->kod,7))
    do while tmp->kod == tmp2->kod
      if &poleK > 0
        ++k ; b += &poleO
      endif
      skip
    enddo
    if i == 8
      poleK := "tmp2->k_k"
      poleO := "tmp2->o_k"
    else
      poleK := "tmp2->k_"+lstr(i)
      poleO := "tmp2->o_"+lstr(i)
    endif
    if k > 0
      &poleK := 1
      &poleO := b/k
    endif
  next
  select TMP2
  skip
enddo
close databases
//
if par2 == 1
  s := "Ф.И.О. врача"
elseif par2 == 2
  s := "Ф.И.О. больного"
else
  s := "Ф.И.О. эксперта"
endif
arr_title := {;
"──────────────────────────────┬──────",;
"                              │      ",;
"                              │Кол-во",;
"                              │экспер",;
             padc(s,30)      +"│тиз   ",;
"                              │      ",;
"                              │      ",;
"──────────────────────────────┴──────"}
kk := 1 ; kp := 5
do case
  case par3 == 1
    s := "(Блок А) Количественная характеристика индикаторов качества ведения медицинской документации"
    arr_title[1] += "┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────"
    arr_title[2] += "│   А01    │   А02    │   А03    │   А04    │   А05    │Средне-   "
    arr_title[3] += "│объем опи-│наличие   │оформление│наличие   │этапные   │взвешенное"
    arr_title[4] += "│сания сос-│ежедневных│медицинс- │дневников │эпикризы  │значение  "
    arr_title[5] += "│тояния    │дневнико- │кой доку- │динамичес.│(более 3-х│блокa A   "
    arr_title[6] += "│больного  │вых       │ментации  │наблюдения│недель пре│          "
    arr_title[7] += "│при поступ│записей   │          │тяж.больн.│бывания)  │          "
    arr_title[8] += "┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────"
  case par3 == 2
    s := "(Блок В) Количественная характеристика индикаторов качества проведения диагностических мероприятий"
    arr_title[1] += "┬──────────┬──────────┬────────────────────────────────┬──────────"
    arr_title[2] += "│   В01    │   В02    │              В03               │Средне-   "
    arr_title[3] += "│план обсле│своевремен│  оценка результатов диагности- │взвешенное"
    arr_title[4] += "│дования и │ность и   │  ческих методов исследования   │значение  "
    arr_title[5] += "│лечения   │объем диаг├──────────┬──────────┬──────────┤блокa В   "
    arr_title[6] += "│больного  │ностически│  лабора- │инструмен-│рентгено- │          "
    arr_title[7] += "│          │мероприяти│  торных  │тальных   │графически│          "
    arr_title[8] += "┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────"
  case par3 == 3
    s := "(Блок С) Количественная характеристика индикаторов качества постановки диагноза"
    arr_title[1] += "┬──────────┬──────────┬──────────"
    arr_title[2] += "│   С01    │   С02    │Средне-   "
    arr_title[3] += "│соответст-│клиничес- │взвешенное"
    arr_title[4] += "│вие       │кий заклю-│значение  "
    arr_title[5] += "│диагнозов │чительный │блокa С   "
    arr_title[6] += "│рубрифик-и│диагноз   │          "
    arr_title[7] += "│МКБ-10    │          │          "
    arr_title[8] += "┴──────────┴──────────┴──────────"
    kp := 2
  case par3 == 4
    s := "(Блок D) Количественная характеристика индикаторов качества проведения лечебно-профилактических мероприятий"
    arr_title[1] += "┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────"
    arr_title[2] += "│   D01    │   D02    │   D03    │   D04    │   D05    │   D06    │   D07    │Средне-   "
    arr_title[3] += "│отражают  │соответств│ лечение  │комбинации│дозировка │соответст-│ реанима- │взвешенное"
    arr_title[4] += "│дневниковы│проводимог│ начато   │лекарствен│лекарствен│вие сроков│ ционные  │значение  "
    arr_title[5] += "│записи    │лечения   │          │средств,  │препаратов│лечения   │ мероприя-│блокa D   "
    arr_title[6] += "│эффект от │выставленн│          │используем│в листах  │стандартам│ тия      │          "
    arr_title[7] += "│пр.терапии│диагнозу  │          │при лечени│назначения│дан.забол.│          │          "
    arr_title[8] += "┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────"
    kp := 7
  case par3 == 5
    s := "(Блок К) Количественная характеристика индикаторов качества проведения консультаций"
    arr_title[1] += "┬──────────┬──────────┬──────────┬──────────┬──────────"
    arr_title[2] += "│   К01    │   К02    │   К03    │   К04    │Средне-   "
    arr_title[3] += "│наличие   │консилиум │обращение │выполнение│взвешенное"
    arr_title[4] += "│записей   │и осмотр  │за консуль│рекоменда-│значение  "
    arr_title[5] += "│зав.отдел.│специалис-│тацией    │ций консу-│блокa К   "
    arr_title[6] += "│в истории │тами      │к главным │льтантов  │          "
    arr_title[7] += "│болезни   │          │внешт.спец│          │          "
    arr_title[8] += "┴──────────┴──────────┴──────────┴──────────┴──────────"
    kp := 4
  case par3 == 6
    s := "(Блок Р) Количественная характеристика индикаторов качества преемственности лечебно-диагностических мероприятий"
    arr_title[1] += "┬──────────────────────"
    arr_title[2] += "│        Р01           "
    arr_title[3] += "│в случае необходимости"
    arr_title[4] += "│перевод больного в    "
    arr_title[5] += "│специализированное    "
    arr_title[6] += "│отделение, учреждение "
    arr_title[7] += "│произведен            "
    arr_title[8] += "┴──────────────────────"
    kp := 1 ; kk := 0
  case par3 == 7
    s := "(Блок R) Количественная характеристика индикаторов качества экспертного заключения при летальном исходе"
    arr_title[1] += "┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────"
    arr_title[2] += "│   R01    │   R02    │   R03    │   R04    │   R05    │Средне-   "
    arr_title[3] += "│в случае  │карта     │замечания │оценка    │оформление│взвешенное"
    arr_title[4] += "│летального│разбора   │к карте   │расхожден.│посмертно-│значение  "
    arr_title[5] += "│исхода    │летального│разбора   │зак.клинич│го        │блокa R   "
    arr_title[6] += "│вскрытие  │исхода    │лет.исхода│и пат.анат│эпикриза  │          "
    arr_title[7] += "│          │на КИЛИ   │на КИЛИ   │диагнозов │          │          "
    arr_title[8] += "┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────"
endcase
sh := len(arr_title[1])
if sh < 66
  reg_print := 4 ; HH := 80
elseif sh < 86
  reg_print := 5 ; HH := 80
elseif sh < 97
  reg_print := 4
else
  reg_print := 5
endif
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
if par2 == 1
  add_string(padl("Таблица "+lstr(par3+4),sh))
endif
for i := 1 to perenos(t_arr,s,sh)
  add_string(center(alltrim(t_arr[i]),sh))
next
if par1 == 1
  add_string(center("в учреждении в целом",sh))
elseif par1 == 2
  add_string(center('в отделении: "'+alltrim(kek_otd[2])+'"',sh))
elseif par1 == 3
  add_string(center('по врачу: "'+alltrim(kek_vrach[2])+'"',sh))
endif
add_string(center(arr_m[4],sh))
aeval(arr_title, {|x| add_string(x) } )
//
if par2 == 1
  R_Use(dir_server+"mo_pers",,"OV")
elseif par2 == 2
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to kod_k into KART
  R_Use(dir_server+"mo_kekh",,"OV")
  set relation to kod_lu into HUMAN
else
  R_Use(dir_server+"base1",,"OV")
endif
use (cur_dir+"tmp2") new
set relation to kod into OV
if par2 == 1
  index on upper(ov->fio) to (cur_dir+"tmp2")
elseif par2 == 2
  index on upper(kart->fio) to (cur_dir+"tmp2")
else
  index on ov->(recno()) to (cur_dir+"tmp2")
endif
go top
do while !eof()
  if par2 == 1
    s := ov->fio
  elseif par2 == 2
    s := padr(fam_i_o(kart->fio),22)+date_8(human->k_data)
  else
    s := alltrim(crypt(ov->p1,gpasskod))+"/"+alltrim(crypt(ov->p5,gpasskod))
  endif
  s := padr(s,30)+str(tmp2->kol,7)
  for i := 1 to kp
    poleK := "tmp2->k_"+lstr(i)
    poleO := "tmp2->o_"+lstr(i)
    s += _put_ocen(&poleO,&poleK)
  next
  if kk > 0
    s += _put_ocen(tmp2->o_k,tmp2->k_k)
  endif
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(s)
  add_string(replicate("─",sh))
  skip
enddo
if par1 == 1
  s := "Учреждение"
elseif par1 == 2
  s := "Отделение"
else
  s := "По врачу"
endif
s := padc(s+" в целом",30)+str(skol,7)
if par2 == 1
  for i := 1 to kp
    if kitog[i] > 0
      s += _put_ocen(aitog[i]/kitog[i])
    else
      s += space(11)
    endif
  next
  if kk > 0 .and. kitog[8] > 0
    s += _put_ocen(aitog[8]/kitog[8])
  endif
endif
add_string(s)
fclose(fp)
close databases
if sh > 85
  Private yes_albom := .t.
endif
viewtext(n_file,,,,(sh>80),,,reg_print)
return NIL

***** 11.07.18
Function kek_p7_t12(par,inp_arr)
Local ar1[3], ar2[3], sh := 64, HH := 60, reg_print := 1, n_file := "pr7_t12"+stxt
Local sb := {"a","b","c","d","k","p","r","e"}
Local adbf, ab, i, poleK, poleO, aitog[2,8], kitog[2,8]
afillall(aitog,0) ; afillall(kitog,0) ; skol := 0
mywait()
adbf := {;
  {"kod",        "N",      1,      0},;
  {"kol",        "N",      6,      0},;
  {"K_A",        "N",      2,      0},;   // коэф-т A
  {"K_B",        "N",      2,      0},;   // коэф-т B
  {"K_C",        "N",      2,      0},;   // коэф-т C
  {"K_D",        "N",      2,      0},;   // коэф-т D
  {"K_K",        "N",      2,      0},;   // коэф-т K
  {"K_P",        "N",      2,      0},;   // коэф-т P
  {"K_R",        "N",      2,      0},;   // коэф-т R
  {"K_E",        "N",      2,      0},;   // коэф-т E
  {"O_A",        "N",      5,      3},;   // оценка A
  {"O_B",        "N",      5,      3},;   // оценка B
  {"O_C",        "N",      5,      3},;   // оценка C
  {"O_D",        "N",      5,      3},;   // оценка D
  {"O_K",        "N",      5,      3},;   // оценка K
  {"O_P",        "N",      5,      3},;   // оценка P
  {"O_R",        "N",      5,      3},;   // оценка R
  {"O_E",        "N",      5,      3}}    // оценка E
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
R_Use(dir_server+"human",,"HUMAN")
R_Use(dir_server+"mo_kekh",,"HU")
set relation to kod_lu into HUMAN
R_Use(dir_server+"mo_keke",,"EKS")
set relation to kod into HU
go top
do while !eof()
  fl1 := between(eks->date_eks,arr_m[1,1],arr_m[1,2])
  fl2 := between(eks->date_eks,arr_m[2,1],arr_m[2,2])
  if (fl := (fl1 .or. fl2))
    if par == 2
      fl := hu->otd==kek_otd[1]
    elseif par == 3
      fl := hu->vrach==kek_vrach[1]
    elseif par == 4
      fl := eks->kod_eks==inp_arr[2]
    elseif par == 5
      fl := left(hu->kod_diag,3)==inp_arr[2]
    endif
  endif
  if fl
    ab := f_ball_kek(hu->ishod)
    select TMP
    append blank
    tmp->kod := iif(fl1, 1, 2)
    for i := 1 to 8
      poleK := "tmp->k_"+sb[i]
      poleO := "tmp->o_"+sb[i]
      &poleK := ab[2,i]
      &poleO := ab[1,i]
      if &poleK > 0
        aitog[tmp->kod,i] += &poleO
        kitog[tmp->kod,i] ++
      endif
    next
  endif
  select EKS
  skip
enddo
//
dbcreate(cur_dir+"tmp2",adbf)
use (cur_dir+"tmp2") new
index on str(kod,1) to (cur_dir+"tmp2")
select TMP
go top
do while !eof()
  select TMP2
  find (str(tmp->kod,1))
  if !found()
    append blank
    tmp2->kod := tmp->kod
  endif
  ++ tmp2->kol
  select TMP
  skip
enddo
select TMP
index on str(kod,1) to (cur_dir+"tmp")
select TMP2
go top
do while !eof()
  skol += tmp2->kol
  select TMP
  for i := 1 to 8
    poleK := "tmp->k_"+sb[i]
    poleO := "tmp->o_"+sb[i]
    b := k := 0
    find (str(tmp2->kod,1))
    do while tmp->kod == tmp2->kod
      if &poleK > 0
        ++k ; b += &poleO
      endif
      skip
    enddo
    poleK := "tmp2->k_"+sb[i]
    poleO := "tmp2->o_"+sb[i]
    if k > 0
      &poleK := 1
      &poleO := b/k
    endif
  next
  select TMP2
  skip
enddo
//
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
if eq_any(par,1,2) .and. year(arr_m[1,2]) < 2017
  add_string(padl("Таблица 12",sh))
endif
s := "Динамика уровней профилей индикаторов и интегрированного "+;
     "показателя качества и технологии оказания медицинской помощи "+;
     "по результатам экспертной работы"
for i := 1 to perenos(ar1,s,sh)
  add_string(center(alltrim(ar1[i]),sh))
next
if par == 1
  add_string(center("по учреждению в целом",sh))
elseif par == 2
  add_string(center('по отделению: "'+alltrim(kek_otd[2])+'"',sh))
elseif par == 3
  add_string(center('по врачу: "'+alltrim(kek_vrach[2])+'"',sh))
elseif par == 4
  add_string(center('по эксперту: "'+alltrim(charone(" ",inp_arr[1]))+'"',sh))
elseif par == 5
  for i := 1 to perenos(ar1,'по диагнозу: '+inp_arr[2]+' '+inp_arr[1],sh)
    add_string(center(alltrim(ar1[i]),sh))
  next
endif
perenos(ar1,arr_m[2,3],18)
perenos(ar2,arr_m[1,3],18)
for i := 1 to 3
  ar1[i] := padc(alltrim(ar1[i]),18)
  ar2[i] := padc(alltrim(ar2[i]),18)
next
add_string("────────────────┬──────────────────┬──────────────────┬─────────")
add_string("          \ Годы│"+ar1[1]        +"│"+ar2[1]        +"│ Динамика")
add_string("Профили     \   │"+ar1[2]        +"│"+ar2[2]        +"│   (+/-) ")
add_string("индикаторов   \ │"+ar1[3]        +"│"+ar2[3]        +"│         ")
add_string("────────────────┼──────────────────┼──────────────────┼─────────")
add_string("       А        │                  │                  │         ")
add_string("качество ведения│"+f1p7_t12(aitog,kitog,1))
add_string("документации    │                  │                  │         ")
add_string("────────────────┼──────────────────┼──────────────────┼─────────")
add_string("       В        │                  │                  │         ")
add_string("диагностические │"+f1p7_t12(aitog,kitog,2))
add_string("мероприятия     │                  │                  │         ")
add_string("────────────────┼──────────────────┼──────────────────┼─────────")
add_string("       С        │                  │                  │         ")
add_string("постановка      │"+f1p7_t12(aitog,kitog,3))
add_string("диагноза        │                  │                  │         ")
add_string("────────────────┼──────────────────┼──────────────────┼─────────")
add_string("       D        │                  │                  │         ")
add_string("лечебно-        │"+f1p7_t12(aitog,kitog,4))
add_string("профилактические│                  │                  │         ")
add_string("мероприятия     │                  │                  │         ")
add_string("────────────────┼──────────────────┼──────────────────┼─────────")
add_string("       К        │                  │                  │         ")
add_string("консультации    │"+f1p7_t12(aitog,kitog,5))
add_string("                │                  │                  │         ")
add_string("────────────────┼──────────────────┼──────────────────┼─────────")
add_string("       Р        │                  │                  │         ")
add_string("преемственность │"+f1p7_t12(aitog,kitog,6))
add_string("                │                  │                  │         ")
add_string("────────────────┼──────────────────┼──────────────────┼─────────")
add_string("       R        │                  │                  │         ")
add_string("экспертное      │"+f1p7_t12(aitog,kitog,7))
add_string("заключение при  │                  │                  │         ")
add_string("летальном исходе│                  │                  │         ")
add_string("────────────────┼──────────────────┼──────────────────┼─────────")
add_string("       Е        │                  │                  │         ")
add_string("интегрированная │"+f1p7_t12(aitog,kitog,8))
add_string("оценка качества │                  │                  │         ")
add_string("и технологии    │                  │                  │         ")
add_string("оказания МП     │                  │                  │         ")
add_string("────────────────┴──────────────────┴──────────────────┴─────────")
fclose(fp)
close databases
viewtext(n_file)
return NIL

***** 26.03.13
Static Function f1p7_t12(aitog,kitog,i)
Local s := "", v, v2 := 0, v1 := 0, fl1 := .f., fl2 := .f.
if kitog[2,i] > 0
  s += _put_ocen(aitog[2,i]/kitog[2,i],,12)
  v2 := round_5(aitog[2,i]/kitog[2,i],3)
  fl1 := .t.
else
  s += space(12)
endif
s += space(6)+"│"
if kitog[1,i] > 0
  s += _put_ocen(aitog[1,i]/kitog[1,i],,12)
  v1 := round_5(aitog[1,i]/kitog[1,i],3)
  fl2 := .t.
else
  s += space(12)
endif
s += space(6)+"│  "
if fl1 .and. fl2
  v := round_5(v1-v2,3)
  if v < 0
    s += "-"+_put_ocen(abs(v),,5)
  elseif v > 0
    s += "+"+_put_ocen(v,,5)
  else
    s += "  ="
  endif
endif
return s

***** 11.07.18 
Function kek_p7_t12_mkb(r)
Local ar1[3], ar2[3],;
      buf := save_maxrow(), i, ret, skod, _sname, t_arr[BR_LEN], blk
DEFAULT r TO T_ROW
mywait()
dbcreate(cur_dir+"tmpd",{{"kod","C",3,0},;
                         {"kol1","N",3,0},;
                         {"kol2","N",3,0},;
                         {"name","C",255,0}})
use (cur_dir+"tmpd") new
index on kod to (cur_dir+"tmpd")
R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB")
R_Use(dir_server+"human",,"HUMAN")
R_Use(dir_server+"mo_kekh",,"HU")
set relation to kod_lu into HUMAN
R_Use(dir_server+"mo_keke",,"EKS")
set relation to kod into HU
go top
do while !eof()
  fl1 := between(eks->date_eks,arr_m[1,1],arr_m[1,2])
  fl2 := between(eks->date_eks,arr_m[2,1],arr_m[2,2])
  if fl1 .or. fl2
    skod := left(hu->kod_diag,3)
    select TMPD
    find (skod)
    if !found()
      append blank
      tmpd->kod := skod
      _sname := ""
      select MKB
      find (padr(skod,6))
      do while mkb->shifr == padr(skod,6) .and. !eof()
        _sname += alltrim(mkb->name)+" "
        if len(_sname) > 255
          exit
        endif
        skip
      enddo
      tmpd->name := _sname
    endif
    if fl1
      tmpd->kol1 ++
    endif
    if fl2
      tmpd->kol2 ++
    endif
  endif
  select EKS
  skip
enddo
i := tmpd->(lastrec())
select TMPD
go top
skod := tmpd->kod
close databases
rest_box(buf)
if i == 0
  func_error(4,"Нет информации!")
else
  t_arr[BR_TOP] := r
  t_arr[BR_BOTTOM] := 23
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := "Приложение №7 - таблица 12 по диагнозам"
  t_arr[BR_TITUL_COLOR] := "W+/GR"
  t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
  blk := {|| if(kol1>0 .and.kol2>0, {1,2}, {3,4}) }
  perenos(ar1,arr_m[2,3],7)
  perenos(ar2,arr_m[1,3],7)
  t_arr[BR_COLUMN] := {{ "Код;по;МКБ",{|| tmpd->kod}, blk },;
                       { "Больных;"+ar1[1]+";"+ar1[2]+";"+ar1[3],{|| put_val(tmpd->kol2,4)}, blk },;
                       { "Больных;"+ar2[1]+";"+ar2[2]+";"+ar2[3],{|| put_val(tmpd->kol1,4)}, blk },;
                       { " Наименование диагноза",{|| left(tmpd->name,56)}, blk }}
  t_arr[BR_STAT_MSG] := {|| ;
    status_key("^<Esc>^ - выход; ^<Enter>^ - печать таблицы по данному диагнозу") }
  t_arr[BR_EDIT] := {|nk,ob| kek_t12_mkb(nk,ob,"edit") }
  Private fl_ret
  do while .t.
    fl_ret := .f.
    use (cur_dir+"tmpd") index (cur_dir+"tmpd") new
    find (skod)
    edit_browse(t_arr)
    if fl_ret
      skod := tmpd->kod
      kek_p7_t12(5,{alltrim(tmpd->name),tmpd->kod})
    else
      exit
    endif
  enddo
  close databases
endif
return NIL

*****
Function kek_t12_mkb(nKey,oBrow,regim)
Local ret := -1
if regim == "edit" .and. nKey == K_ENTER
  fl_ret := .t.
  ret := 1
endif
return ret

***** 12.10.17
Function kek_prn_pril14()
Static stip_eks := 2
Local arr_m, adbf, ash[13], ss[10], ii := 0,;
      sh, HH := 52, reg_print := 5, n_file := "pril_14"+stxt
Private is_2017 := .t.
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL .and. ;
                (ltip_eks := input_value(18,18,20,61,color1,;
         "Введите уровень экспертизы (от 1 до 3)",stip_eks,"9")) != NIL .and. ;
           between(ltip_eks,1,3)
  stip_eks := ltip_eks
  mywait()
  arr_title := {;
  "───┬──────────┬────────────┬───────────┬───────┬─────┬─┬────────────┬──────┬─────────┬────────┬─────┬──────────────────────────",;
  " N │   Дата   │ Отделение, │  Фамилия, │ Номер │Дата │П│  Диагноз   │Исход │Характе- │Отклоне-│Оцен-│        Заключение        ",;
  "п/п│экспертизы│лечащий врач│    имя,   │истории│рожде│о│(осн.сопут.)│забо- │ристика  │ние от  │ ка  │                          ",;
  "   │          │            │  отчество │болезни│ния  │л│в соответст-│лева- │случая   │стандарт│     │                          ",;
  "   │   ФИО    │            │  пациента │       │     │ │вии с МКБ-10│ния   │экспер-  │дефекты,│     │                          ",;
  "   │ эксперта │            │           │       │     │ │            │      │тизы     │ошибки  │     │                          ",;
  "───┼──────────┼────────────┼───────────┼───────┼─────┼─┼────────────┼──────┼─────────┼────────┼─────┼──────────────────────────",;
  " 1 │     2    │     3      │     4     │   5   │  6  │7│     8      │  9   │   10    │   11   │ 12  │            13            ",;
  "───┴──────────┴────────────┴───────────┴───────┴─────┴─┴────────────┴──────┴─────────┴────────┴─────┴──────────────────────────"}
  ash[ 1] :=  3
  ash[ 2] := 10
  ash[ 3] := 12
  ash[ 4] := 11
  ash[ 5] :=  7
  ash[ 6] :=  5
  ash[ 7] :=  1
  ash[ 8] := 12
  ash[ 9] :=  6
  ash[10] :=  9
  ash[11] :=  8
  ash[12] :=  5
  ash[13] := 26
  sh := len(arr_title[1])
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  if arr_m[1] < 2017
    add_string(padl('Приложение №14',sh))
    is_2017 := .f.
  endif
  add_string(padc('Журнал',sh))
  add_string(padc('учета клинико-экспертной работы медицинского учреждения '+arr_m[4],sh))
  add_string(padc('(экспертиза качества медицинской помощи - уровень '+lstr(ltip_eks)+')',sh))
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to kod_k into KART
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"mo_pers",,"VR")
  R_Use(dir_server+"mo_kekh",,"HU")
  set relation to vrach into VR, to otd into OTD, to kod_lu into HUMAN
  R_Use(dir_server+"base1",,"OV")
  Use_base("mo_kekez")
  Use_base("mo_keke")
  set relation to kod into HU, kod_eks into OV
  set order to 3  // по дате экспертизы
  dbseek(dtos(arr_m[5]),.t.)
  index on dtos(date_eks)+otd->name+kart->fio to (cur_dir+"tmp_eks") ;
        for tip_eks == ltip_eks ;
        while date_eks <= arr_m[6]
  go top
  do while !eof()
    afill(ss,space(sh))
    put_ss( 1,ss,ash,lstr(++ii))
    put_ss( 2,ss,ash,full_date(eks->date_eks)+" "+crypt(ov->p1,gpasskod))
    put_ss( 3,ss,ash,alltrim(otd->short_name)+" "+alltrim(vr->fio))
    put_ss( 4,ss,ash,alltrim(kart->fio))
    put_ss( 5,ss,ash,alltrim(hu->ist_bol))
    put_ss( 6,ss,ash,full_date(kart->date_r))
    put_ss( 7,ss,ash,kart->pol)
    s := alltrim(hu->kod_diag)
    if !empty(hu->diag_sop)
      s += ","+alltrim(hu->diag_sop)
    endif
    put_ss( 8,ss,ash,s)
    put_ss( 9,ss,ash,inieditspr(A__MENUVERT, mm_18_kek, hu->ISHOD),.t.)
    put_ss(10,ss,ash,inieditspr(A__MENUVERT, menu_povod_kek, hu->POVOD_EKS))
    _b := f_ball_kek(hu->ishod)
    if _b[3] == 0
      s := iif(empty(_b[1,8]), "", "не выявлено дефектов")
    else
      s := "кол-во дефектов "+lstr(_b[3])
    endif
    put_ss(11,ss,ash,s)
    put_ss(12,ss,ash,alltrim(_put_ocen(_b[1,8])))
    s := ""
    select EKSZ
    find (str(eks->(recno()),7))
    do while eksz->kod == eks->(recno()) .and. !eof()
      s += alltrim(eksz->name)+" "
      skip
    enddo
    put_ss(13,ss,ash,s,.t.)
    k := len_ss(ss)
    if verify_FF(HH-k,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    for j := 1 to k
      add_string(ss[j])
    next
    add_string(replicate("-",sh))
    select EKS
    skip
  enddo
  fclose(fp)
  close databases
  Private yes_albom := .t.
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
return NIL

*****
Static Function put_ss(k,as,an,s,fl)
Local i, j, l, n := 1, arr[10], sh := an[k]
if valtype(s) == "C"
  DEFAULT fl TO .f.
  if k > 1
    for j := 1 to k-1
      n += an[j]+1
    next
  endif
  j := perenos(arr,s,sh)
  if fl .or. j > len(as)
    l := 1
    for i := 1 to len(as)
      as[i] := stuff(as[i],n,sh,padr(ltrim(substr(s,l,sh)),sh))
      l += sh
    next
  else
    for i := 1 to j
      as[i] := stuff(as[i],n,sh,padr(arr[i],sh))
    next
  endif
endif
return NIL

*****
Static Function len_ss(arr)
Local i, k := len(arr)
for i := len(arr) to 1 step -1
  if !empty(arr[i])
    k := i ; exit
  endif
next
return k

*****
Function kek_inf_eks(k)
Static si1 := 1, si2 := 1, si3 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Список ~экспертов",;
                "Эксперт + ~больные"}
    mas_msg := {"Вывод списка экспертов с указанием количества экспертиз",;
                "Вывод списка проэкспертированных больных конкретным экспертом"}
    mas_fun := {"kek_inf_eks(11)",;
                "kek_inf_eks(12)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    f1inf_kek_eks()
  case k == 12
    f2inf_kek_eks()
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

***** 11.07.18
Function f1inf_kek_eks()
Local arr_m, adbf, ab, skol := 0,;
      sh, HH := 80, reg_print, n_file := "inf1_eks"+stxt
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  adbf := {;
    {"kod",  "N", 7, 0},;
    {"kol",  "N", 6, 0},;
    {"O_E",  "N",20, 3}}    // суммарная оценка E
  dbcreate(cur_dir+"tmp",adbf)
  use (cur_dir+"tmp") new
  index on str(kod,3) to (cur_dir+"tmp")
  R_Use(dir_server+"human",,"HUMAN")
  R_Use(dir_server+"mo_kekh",,"HU")
  set relation to kod_lu into HUMAN
  R_Use(dir_server+"mo_keke",dir_server+"mo_keked","EKS")
  // index on dtos(date_eks) to (dir_server+"mo_keked") 
  set relation to kod into HU
  dbseek(dtos(arr_m[5]),.t.)
  do while eks->date_eks <= arr_m[6] .and. !eof()
    ab := f_ball_kek(hu->ishod)
    select TMP
    find (str(eks->kod_eks,3))
    if !found()
      append blank
      tmp->kod := eks->kod_eks
    endif
    tmp->kol ++
    tmp->o_e += ab[1,8]
    select EKS
    skip
  enddo
  //
  arr_title := {;
  "────────────────────────────────────────────────┬──────┬───────",;
  "                                                │Кол-во│Средняя",;
  "              Ф.И.О. эксперта                   │экспер│ оценка",;
  "                                                │тиз   │"+iif(arr_m[1] < 2017,"   Е",""),;
  "────────────────────────────────────────────────┴──────┴───────"}
  reg_print := 4
  f_reg_print(arr_title,@sh)
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string(center('Количество экспертиз по экспертам',sh))
  add_string(center(arr_m[4],sh))
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+"base1",,"OV")
  select TMP
  set relation to kod into OV
  index on ov->(recno()) to (cur_dir+"tmp2")
  go top
  do while !eof()
    s := padr(crypt(ov->p1,gpasskod),21)+crypt(ov->p5,gpasskod)+" (гр."+lstr(ov->p6)+")"
    s := padr(s,48)+str(tmp->kol,6)
    skol += tmp->kol
    if tmp->kol > 0
      s += _put_ocen(tmp->o_e/tmp->kol,,8)
    endif
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(s)
    add_string(replicate("─",sh))
    skip
  enddo
  add_string(padc("Учреждение в целом",48)+str(skol,6))
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
return NIL

***** 11.07.18
Function f2inf_kek_eks()
Local arr_m, adbf, ab, skol := 0, old_d := ctod(""),;
      sh, HH := 60, reg_print, n_file := "inf2_eks"+stxt
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL .and. (ke := _work_eks(T_ROW,T_COL-5,,.f.)) != NIL
  mywait()
  adbf := {;
    {"kod",      "N", 7, 0},;
    {"date_eks", "D", 8, 0},;
    {"O_E",      "N", 5, 3}}    // суммарная оценка E
  dbcreate(cur_dir+"tmp",adbf)
  use (cur_dir+"tmp") new
  R_Use(dir_server+"human",,"HUMAN")
  R_Use(dir_server+"mo_kekh",,"HU")
  set relation to kod_lu into HUMAN
  R_Use(dir_server+"mo_keke",dir_server+"mo_keked","EKS")
  // index on dtos(date_eks) to (dir_server+"mo_keked") 
  set relation to kod into HU
  dbseek(dtos(arr_m[5]),.t.)
  do while eks->date_eks <= arr_m[6] .and. !eof()
    if eks->kod_eks == ke[2]
      ab := f_ball_kek(hu->ishod)
      select TMP
      append blank
      tmp->kod := hu->(recno())
      tmp->date_eks := eks->date_eks
      tmp->o_e := ab[1,8]
    endif
    select EKS
    skip
  enddo
  close databases
  //
  arr_title := {;
  "──────────┬────────────────────────┬──────────────┬─────────────────────┬──────",;
  " Дата экс-│     Ф.И.О. больного    │   Период     │      Отделение      │Оценка",;
  " пертизы  │                        │   лечения    │                     │  Е   ",;
  "──────────┴────────────────────────┴──────────────┴─────────────────────┴──────"}
  reg_print := 2
  f_reg_print(arr_title,@sh)
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string(center('Список экспертиз по эксперту',sh))
  add_string(center(charone(" ",ke[1]),sh))
  add_string(center(arr_m[4],sh))
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to kod_k into KART
  R_Use(dir_server+"mo_kekh",,"OV")
  set relation to kod_lu into HUMAN, to otd into OTD
  use (cur_dir+"tmp") new
  set relation to kod into OV
  index on dtos(date_eks)+upper(kart->fio) to (cur_dir+"tmp2")
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if !(old_d == tmp->date_eks)
      add_string(full_date(tmp->date_eks))
    endif
    s := " "+padr(kart->fio,34)+" "+;
         left(dtoc(human->n_data),5)+"-"+date_8(human->k_data)+" "+;
         padr(ltrim(otd->name),21)+_put_ocen(tmp->o_e,,7)
    skol ++
    add_string(s)
    old_d := tmp->date_eks
    skip
  enddo
  add_string(replicate("─",sh))
  add_string(padc("Итого количество экспертиз: "+lstr(skol),sh))
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
return NIL

*****
Function kek_inf_povod(k)
Static si1 := 1, si2 := 1, si3 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Список ~поводов",;
                "Повод + ~больные"}
    mas_msg := {"Вывод списка поводов с указанием количества экспертиз",;
                "Вывод списка проэкспертированных больных по конкретному поводу"}
    mas_fun := {"kek_inf_povod(11)",;
                "kek_inf_povod(12)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    f1inf_kek_povod()
  case k == 12
    f2inf_kek_povod()
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

***** 11.07.18
Function f1inf_kek_povod()
Local i, ap, arr_m, adbf, ab, skol := 0,;
      sh, HH := 80, reg_print, n_file := "inf1_pov"+stxt
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  ap := aclone(menu_povod_kek)
  for i := 1 to len(ap)
    aadd(ap[i],0)  //добавим 3-ий эл-т для подсчета кол-ва больных
  next
  adbf := {;
    {"povod_eks",  "N", 1, 0},;
    {"kod",  "N", 7, 0},;
    {"kol",  "N", 6, 0}}
  dbcreate(cur_dir+"tmp",adbf)
  use (cur_dir+"tmp") new
  index on str(povod_eks,1)+str(kod,3) to (cur_dir+"tmp")
  R_Use(dir_server+"human",,"HUMAN")
  R_Use(dir_server+"mo_kekh",,"HU")
  set relation to kod_lu into HUMAN
  R_Use(dir_server+"mo_keke",dir_server+"mo_keked","EKS")
  // index on dtos(date_eks) to (dir_server+"mo_keked") 
  set relation to kod into HU
  dbseek(dtos(arr_m[5]),.t.)
  do while eks->date_eks <= arr_m[6] .and. !eof()
    if (i := ascan(ap, {|x| x[2]==hu->POVOD_EKS})) > 0
      ap[i,3] ++
      select TMP
      find (str(hu->POVOD_EKS,1)+str(eks->kod_eks,3))
      if !found()
        append blank
        tmp->povod_eks := hu->POVOD_EKS
        tmp->kod := eks->kod_eks
      endif
      tmp->kol ++
    endif
    select EKS
    skip
  enddo
  //
  arr_title := {;
  "───────────────────────────────────────────────────────┬──────",;
  " Повод экспертизы (Ф.И.О. эксперта)                    │Кол-во",;
  "───────────────────────────────────────────────────────┴──────"}
  reg_print := 4
  f_reg_print(arr_title,@sh)
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string(center('Количество больных по поводу экспертизы',sh))
  add_string(center('Количество экспертиз по экспертам',sh))
  add_string(center(arr_m[4],sh))
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+"base1",,"OV")
  select TMP
  set relation to kod into OV
  index on str(povod_eks,1)+str(ov->(recno()),6) to (cur_dir+"tmp2")
  for i := 1 to len(ap)
    if verify_FF(HH-1,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(padr(ap[i,1],sh-7)+str(ap[i,3],6))
    skol += ap[i,3]
    select TMP
    find (str(ap[i,2],1))
    do while tmp->povod_eks==ap[i,2] .and. !eof()
      if tmp->kol > 0
        s := padr(crypt(ov->p1,gpasskod),21)+crypt(ov->p5,gpasskod)+;
                      " (гр."+lstr(ov->p6)+")"
        s := padr(s,48)+str(tmp->kol,6)
        if verify_FF(HH,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        add_string(space(sh-48-6)+s)
      endif
      skip
    enddo
    add_string(replicate("─",sh))
  next
  add_string(padc("Больных по учреждению в целом",sh-6)+str(skol,6))
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
return NIL

***** 11.07.18
Function f2inf_kek_povod()
Static sk := 0
Local arr_m, adbf, ab, skol := 0, old_d := ctod(""), i, ke, ;
      sh, HH := 60, reg_print, n_file := "inf2_pov"+stxt
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  i := popup_2array(menu_povod_kek,T_ROW,T_COL-5,sk,1,@ke)
  if valtype(ke) == "A"
    sk := ke[2]
    mywait()
    adbf := {;
      {"kod",      "N", 7, 0},;
      {"date_eks", "D", 8, 0},;
      {"O_E",      "N", 5, 3}}    // суммарная оценка E
    dbcreate(cur_dir+"tmp",adbf)
    use (cur_dir+"tmp") new
    R_Use(dir_server+"human",,"HUMAN")
    R_Use(dir_server+"mo_kekh",,"HU")
    set relation to kod_lu into HUMAN
    R_Use(dir_server+"mo_keke",dir_server+"mo_keked","EKS")
    // index on dtos(date_eks) to (dir_server+"mo_keked") 
    set relation to kod into HU
    dbseek(dtos(arr_m[5]),.t.)
    do while eks->date_eks <= arr_m[6] .and. !eof()
      if ke[2] == hu->povod_eks
        ab := f_ball_kek(hu->ishod)
        select TMP
        append blank
        tmp->kod := hu->(recno())
        tmp->date_eks := eks->date_eks
        tmp->o_e := ab[1,8]
      endif
      select EKS
      skip
    enddo
    close databases
    //
    arr_title := {;
    "──────────┬───────────────────────────┬───────────┬────────────────────────────",;
    " Дата экс-│     Ф.И.О. больного       │  Период   │      Отделение             ",;
    " пертизы  │                           │  лечения  │                            ",;
    "──────────┴───────────────────────────┴───────────┴────────────────────────────"}
    reg_print := 2
    f_reg_print(arr_title,@sh)
    fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
    add_string(center('Список больных по поводу экспертизы',sh))
    add_string(center('"'+ke[1]+'"',sh))
    add_string(center(arr_m[4],sh))
    aeval(arr_title, {|x| add_string(x) } )
    R_Use(dir_server+"mo_otd",,"OTD")
    R_Use(dir_server+"kartotek",,"KART")
    R_Use(dir_server+"human",,"HUMAN")
    set relation to kod_k into KART
    R_Use(dir_server+"mo_kekh",,"OV")
    set relation to kod_lu into HUMAN, to otd into OTD
    use (cur_dir+"tmp") new
    set relation to kod into OV
    index on dtos(date_eks)+upper(kart->fio) to (cur_dir+"tmp2")
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      if !(old_d == tmp->date_eks)
        add_string(full_date(tmp->date_eks))
      endif
      s := " "+padr(kart->fio,37)+" "+;
           left(dtoc(human->n_data),5)+"-"+left(dtoc(human->k_data),5)+" "+;
           padr(ltrim(otd->name),28)
      skol ++
      add_string(s)
      old_d := tmp->date_eks
      skip
    enddo
    add_string(replicate("─",sh))
    add_string(padc("Итого количество больных (экспертиз): "+lstr(skol),sh))
    fclose(fp)
    close databases
    viewtext(n_file,,,,(sh>80),,,reg_print)
  endif
endif
return NIL

*****
Function ret_2_diap()  
Static sm11 := 1, sm12 := 12, sy1
Static sm21 := 0, sm22 := 0, sy2 := 0
Local ar, buf := savescreen(), fl, r := 16, p2 := "99", s01 := "01"
DEFAULT sy1 TO year(sys_date)
box_shadow(r,2,22,77,color1,"Ввод двух периодов времени для сравнения",color8)
Private m11 := sm11, m12 := sm12, my1 := sy1, ;
        m21 := sm21, m22 := sm22, my2 := sy2
setcolor(cDataCGet)
do while .t.
  @ r+2,4 say "Основной период времени: месяцы с" get m11 pict p2 valid {|| m11 >= 0}
  @ row(),col() say " по" get m12 pict p2 valid {|| m11 <= m12 .and. m12 <= 12}
  @ row(),col() say ", год" get my1 pict p2+p2 valid {|| _make_2_diap() }
  @ r+4,4 say "Предыдущий период времени: месяцы с" get m21 pict p2 valid {|| m21 >= 0}
  @ row(),col() say " по" get m22 pict p2 valid {|| m21 <= m22 .and. m22 <= 12}
  @ row(),col() say ", год" get my2 pict p2+p2
  myread()
  if lastkey() != K_ESC
    fl := .t.
    if emptyany(m11,m12,my1)
      fl := func_error(4,"Введены не все данные в ОСНОВНОМ периоде")
    endif
    if emptyany(m21,m22,my2)
      fl := func_error(4,"Введены не все данные в ПРЕДЫДУЩЕМ периоде")
    endif
    if fl
      ar := array(2,3)
      ar[1,1] := stod(f_m_y(my1,m11)+s01)
      ar[1,2] := eom(stod(f_m_y(my1,m12)+s01))
      ar[1,3] := s_year_month(m11,m12,my1)
      ar[2,1] := stod(f_m_y(my2,m21)+s01)
      ar[2,2] := eom(stod(f_m_y(my2,m22)+s01))
      ar[2,3] := s_year_month(m21,m22,my2)
      sm11 := m11 ; sm12 := m12 ; sy1 := my1
      sm21 := m21 ; sm22 := m22 ; sy2 := my2
    else
      loop
    endif
  endif
  exit
enddo
setcolor(color0)
restscreen(buf)
return ar

*****
Static Function s_year_month(k1,k2,ry)
Local s_mes_god := ""
do case
  case k1 == k2
    s_mes_god := lower(mm_month[k1])
  case k1 == 1 .and. k2 == 3
    s_mes_god := "I кв."
  case k1 == 4 .and. k2 == 6
    s_mes_god := "II кв."
  case k1 == 7 .and. k2 == 9
    s_mes_god := "III кв."
  case k1 == 10 .and. k2 == 12
    s_mes_god := "IV кв."
  case k1 == 1 .and. k2 == 6
    s_mes_god := "1-ое полугодие"
  case k1 == 7 .and. k2 == 12
    s_mes_god := "2-ое полугодие"
  otherwise
    s_mes_god := lstr(k1)+"-"+lstr(k2)+" месяцы"
endcase
if k1 == 1 .and. k2 == 12
  s_mes_god := lstr(ry)+" год"
else
  s_mes_god += str(ry,5)+"г."
endif
return s_mes_god

*****
Static Function _make_2_diap()
Local n
if emptyany(m21,m22,my2)
  n := m12 - m11 + 1
  if m12 > n
    m21 := m11-n ; m22 := m12-n ; my2 := my1
  else
    m21 := m11 ; m22 := m12 ; my2 := my1-1
  endif
  update_gets()
endif
return .t.

*****
Static Function f_m_y(y,m)
return strzero(y,4)+strzero(m,2)

***** 21.12.17
Function kek_inf_otd(k)
Static si1 := 1, si2 := 1, si3 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Список ~отделений",;
                "Отделение + ~больные"}
    mas_msg := {"Вывод списка отделений с указанием количества экспертиз",;
                "Вывод списка проэкспертированных больных в конкретном отделении"}
    mas_fun := {"kek_inf_otd(11)",;
                "kek_inf_otd(12)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    f1inf_kek_otd()
  case k == 12
    f2inf_kek_otd()
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

***** 11.07.18
Function f1inf_kek_otd()
Local arr_m, adbf, ab, skol := 0,;
      sh, HH := 60, reg_print, n_file := "inf1_otd"+stxt
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  adbf := {;
    {"kod",  "N", 7, 0},;
    {"kol",  "N", 6, 0},;
    {"O_E",  "N",20, 3}}    // суммарная оценка E
  dbcreate(cur_dir+"tmp",adbf)
  use (cur_dir+"tmp") new
  index on str(kod,3) to (cur_dir+"tmp")
  R_Use(dir_server+"human",,"HUMAN")
  R_Use(dir_server+"mo_kekh",,"HU")
  set relation to kod_lu into HUMAN
  R_Use(dir_server+"mo_keke",dir_server+"mo_keked","EKS")
  // index on dtos(date_eks) to (dir_server+"mo_keked") 
  set relation to kod into HU
  dbseek(dtos(arr_m[5]),.t.)
  do while eks->date_eks <= arr_m[6] .and. !eof()
    ab := f_ball_kek(hu->ishod)
    select TMP
    find (str(hu->otd,3))
    if !found()
      append blank
      tmp->kod := hu->otd
    endif
    tmp->kol ++
    tmp->o_e += ab[1,8]
    select EKS
    skip
  enddo
  //
  arr_title := {;
  "────────────────────────────────────────────────┬──────┬───────",;
  "                                                │Кол-во│Средняя",;
  "            Наименование отделения              │экспер│ оценка",;
  "                                                │тиз   │"+iif(arr_m[1] < 2017,"   Е",""),;
  "────────────────────────────────────────────────┴──────┴───────"}
  reg_print := 1
  f_reg_print(arr_title,@sh)
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string(center('Количество экспертиз по отделениям',sh))
  add_string(center(arr_m[4],sh))
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+"mo_otd",,"OV")
  select TMP
  set relation to kod into OV
  index on upper(ov->name) to (cur_dir+"tmp2")
  go top
  do while !eof()
    s := padr(ov->name,48)+str(tmp->kol,6)
    skol += tmp->kol
    if tmp->kol > 0
      s += _put_ocen(tmp->o_e/tmp->kol,,8)
    endif
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(s)
    skip
  enddo
  add_string(replicate("─",sh))
  add_string(padc("Учреждение в целом",48)+str(skol,6))
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
return NIL

***** 11.07.18
Function f2inf_kek_otd()
Local arr_m, adbf, ab, skol := 0, old_d := ctod(""),;
      sh, HH := 60, reg_print, n_file := "inf2_otd"+stxt
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL .and. ret_kek_otd(,T_ROW,T_COL-5,arr_m) != NIL
  mywait()
  adbf := {;
    {"kod",      "N", 7, 0},;
    {"kod_eks",  "N", 7, 0},;
    {"date_eks", "D", 8, 0},;
    {"O_E",      "N", 5, 3}}    // суммарная оценка E
  dbcreate(cur_dir+"tmp",adbf)
  use (cur_dir+"tmp") new
  R_Use(dir_server+"human",,"HUMAN")
  R_Use(dir_server+"mo_kekh",,"HU")
  set relation to kod_lu into HUMAN
  R_Use(dir_server+"mo_keke",dir_server+"mo_keked","EKS")
  // index on dtos(date_eks) to (dir_server+"mo_keked") 
  set relation to kod into HU
  dbseek(dtos(arr_m[5]),.t.)
  do while eks->date_eks <= arr_m[6] .and. !eof()
    if hu->otd == kek_otd[1]
      ab := f_ball_kek(hu->ishod)
      select TMP
      append blank
      tmp->kod := hu->(recno())
      tmp->kod_eks := eks->kod_eks
      tmp->date_eks := eks->date_eks
      tmp->o_e := ab[1,8]
    endif
    select EKS
    skip
  enddo
  close databases
  //
  arr_title := {;
  "──────────┬───────────────────────────┬───────────┬─────────────────────┬──────",;
  " Дата экс-│     Ф.И.О. больного       │  Период   │      Эксперт        │Оценка",;
  " пертизы  │                           │  лечения  │                     │  Е   ",;
  "──────────┴───────────────────────────┴───────────┴─────────────────────┴──────"}
  reg_print := 2
  f_reg_print(arr_title,@sh)
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string(center('Список экспертиз по отделению',sh))
  add_string(center('по отделению: "'+alltrim(kek_otd[2])+'"',sh))
  add_string(center(arr_m[4],sh))
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+"base1",,"B1")
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to kod_k into KART
  R_Use(dir_server+"mo_kekh",,"OV")
  set relation to kod_lu into HUMAN
  use (cur_dir+"tmp") new
  set relation to kod into OV, to kod_eks into B1
  index on dtos(date_eks)+upper(kart->fio) to (cur_dir+"tmp2")
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if !(old_d == tmp->date_eks)
      add_string(full_date(tmp->date_eks))
    endif
    s := " "+padr(kart->fio,37)+" "+;
         left(dtoc(human->n_data),5)+"-"+left(dtoc(human->k_data),5)+" "+;
         padr(crypt(b1->p1,gpasskod),21)+_put_ocen(tmp->o_e,,7)
    skol ++
    add_string(s)
    old_d := tmp->date_eks
    skip
  enddo
  add_string(replicate("─",sh))
  add_string(padc("Итого количество экспертиз: "+lstr(skol),sh))
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
return NIL

***** 11.07.18
Function kek_inf_vrach()
Local arr_m, adbf, ab, skol := 0,;
      sh, HH := 60, reg_print, n_file := "inf1_vrach"+stxt
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  adbf := {;
    {"kod",  "N", 7, 0},;
    {"kol",  "N", 6, 0},;
    {"O_E",  "N",20, 3}}    // суммарная оценка E
  dbcreate(cur_dir+"tmp",adbf)
  use (cur_dir+"tmp") new
  index on str(kod,7) to (cur_dir+"tmp")
  R_Use(dir_server+"human",,"HUMAN")
  R_Use(dir_server+"mo_kekh",,"HU")
  set relation to kod_lu into HUMAN
  R_Use(dir_server+"mo_keke",dir_server+"mo_keked","EKS")
  // index on dtos(date_eks) to (dir_server+"mo_keked") 
  set relation to kod into HU
  dbseek(dtos(arr_m[5]),.t.)
  do while eks->date_eks <= arr_m[6] .and. !eof()
    ab := f_ball_kek(hu->ishod)
    select TMP
    find (str(hu->vrach,7))
    if !found()
      append blank
      tmp->kod := hu->vrach
    endif
    tmp->kol ++
    tmp->o_e += ab[1,8]
    select EKS
    skip
  enddo
  //
  arr_title := {;
  "────────────────────────────────────────────────┬──────┬───────",;
  "                                                │Кол-во│Средняя",;
  "            ФИО лечащего врача                  │экспер│ оценка",;
  "                                                │тиз   │"+iif(arr_m[1] < 2017,"   Е",""),;
  "────────────────────────────────────────────────┴──────┴───────"}
  reg_print := 1
  f_reg_print(arr_title,@sh)
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string(center('Количество экспертиз по врачам',sh))
  add_string(center(arr_m[4],sh))
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+"mo_pers",,"OV")
  select TMP
  set relation to kod into OV
  index on upper(ov->fio) to (cur_dir+"tmp2")
  go top
  do while !eof()
    s := padr(ov->fio,48)+str(tmp->kol,6)
    skol += tmp->kol
    if tmp->kol > 0
      s += _put_ocen(tmp->o_e/tmp->kol,,8)
    endif
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(s)
    skip
  enddo
  add_string(replicate("─",sh))
  add_string(padc("Учреждение в целом",48)+str(skol,6))
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
return NIL
