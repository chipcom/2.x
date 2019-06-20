***** mo_omsr.prg - работа с реестром в задаче ОМС
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

#define max_rec_reestr 9999

Static Sreestr_sem := "Работа с реестрами"
Static Sreestr_err := "В данный момент с реестрами работает другой пользователь."
Static sadiag1 := {}

***** 10.05.19 скорректировать вид помощи для дневного стационара (в стационаре) по лицензии
Function ret_vidpom_licensia(lusl_ok,lvidpoms)
Static mo_licensia := {;
  {'101004',2,'31'},;  // ВОУНЦ
  {'141023',2,'31'},;  // б-ца 15
  {'801935',2,'31'},;  // ЭКО-Москва
  {'391001',2,'31'};   // Камышинская гор.б-ца 1
 }
Local i := ascan(mo_licensia, {|x| x[1] == glob_mo[_MO_KOD_TFOMS] .and. x[2] == lusl_ok })
if i > 0
  lvidpoms := mo_licensia[i,3]
endif
return lvidpoms

***** 20.09.15 если это коммерческая скорая
Function is_komm_SMP()
Static _is
Static a_komm_SMP := {;
  "806501"; // Волгоградская неотложка
 }
if _is == NIL // т.е. определяется один раз за сеанс работы задачи
  _is := (ascan(a_komm_SMP,glob_mo[_MO_KOD_TFOMS]) > 0)
endif
return _is

***** 14.02.14 является ли услуга "с неотложной целью"
Function f_is_neotl_pom(lshifr)
Static a_stom_n := {; // при оказании неотложной помощи
  "57.1.72","57.1.73","57.1.74","57.1.75","57.1.76","57.1.77",;
  "57.1.78","57.1.79","57.1.80","57.1.81";
 }
lshifr := alltrim(lshifr)
return eq_any(left(lshifr,5),"2.80.","2.82.") .or. ascan(a_stom_n,lshifr) > 0

***** 18.11.14 зак.случай в п-ке
Function f_is_zak_sl_vr(lshifr)
return eq_any(left(lshifr,5),;
       "2.78.",; // Законченный случай обращения с лечебной целью к врачу ...
       "2.89.",; // Законченный случай обращения с целью медицинской реабилитации
       "70.3.",; // Законченный случай диспансеризации взрослого населения
       "70.5.",; // Законченный случай диспансеризации детей-сирот в стационаре
       "70.6.",; // Законченный случай диспансеризации детей-сирот под опекой
       "72.1.",; // Законченный случай профосмотра взрослого населения
       "72.2.",; // Законченный случай профосмотра несовершеннолетних
       "72.3.",; // Законченный случай предварительного осмотра несовершеннолетних
       "72.4.")  // Законченный случай периодического осмотра несовершеннолетних

***** 13.02.14 является ли услуга первичным стоматологическим приёмом
Function f_is_1_stom(lshifr,ret_arr)
Static a_1_stom := {;
  "57.1.36","57.1.39","57.1.42","57.1.45","57.1.51",; // 2013 год
  "57.1.57","57.1.58","57.1.59","57.1.60","57.1.61",; // с лечебной
  "57.1.62","57.1.64","57.1.66","57.1.68","57.1.70","57.5.1",; // с профилактической
  "57.1.72","57.1.74","57.1.76","57.1.78","57.1.80";  // с неотложной
 }
Local i
lshifr := alltrim(lshifr)
if valtype(ret_arr) == "A"
  for j := 1 to len(a_1_stom)
    aadd(ret_arr, a_1_stom[j])
  next
endif
return ascan(a_1_stom,lshifr) > 0

***** 16.10.16 является ли услуга стоматологической с нулевой ценой
Function is_2_stomat(lshifr,/*@*/is_2_88,is_new)
Local a_stom16_2 := {;
  {1,"2.78.47","2.78.53"},; // с лечебной целью
  {2,"2.79.52","2.79.58"},; // с профилактической целью
  {2,"2.88.40","2.88.45"},; //  -- " -- " -- " -- " -- разовое по поводу заболевания
  {3,"2.80.29","2.80.33"};  // при оказании неотложной помощи
}
Local j, ret := 0
DEFAULT is_new TO .f.
if is_new // с 1 августа 2016 года
  a_stom16_2 := {;
    {1,"2.78.54","2.78.60"},; // с лечебной целью
    {2,"2.79.59","2.79.64"},; // с профилактической целью
    {2,"2.88.46","2.88.51"},; //  -- " -- " -- " -- " -- разовое по поводу заболевания
    {3,"2.80.34","2.80.38"};  // при оказании неотложной помощи
  }
endif
is_2_88 := .f.
lshifr := alltrim(lshifr)
for j := 1 to len(a_stom16_2)
  if between_shifr(lshifr,a_stom16_2[j,2],a_stom16_2[j,3])
    ret := a_stom16_2[j,1]
    is_2_88 := (j == 3)
    exit
  endif
next
return ret

***** 12.03.18 пересечение в стоматологическом случае разных видов посещений
Function f_vid_p_stom(arr_usl,ta,ret_arr,ret_tip_a,lk_data,/*@*/ret_tip,/*@*/ret_kol,/*@*/is_2_88,arrFusl)
/*
 arr_usl   - двумерный массив, шифр услуги в первом элементе
 ta        - массив с текстами ошибок
 ret_arr   - возвращаемый массив врачебных приёмов в зависимости от содержания ret_tip_a
 ret_tip_a - м.б. {1,2,3}(default), {1}, {2}, {3}
 lk_data   - дата окончания случая
 ret_tip   - 2016 год - возврат типа (от 1 до 3)
 ret_kol   - 2016 год - возврат количества врачебных приёмов в случае
 is_2_88   - является ли разовым по поводу заболевания
 arrFusl   - двумерный массив, шифр услуги ФФОМС в первом элементе
*/
Static a_stom14 := {; // с лечебной целью
  {"57.1.35","57.1.37","57.1.38","57.1.40","57.1.41",;
   "57.1.43","57.1.44","57.1.46","57.1.52",;
   "57.1.57","57.1.58","57.1.59","57.1.60","57.1.61",;
   "57.4.38","57.4.39","57.4.40","57.4.41";
  },;
  {; // с профилактической целью
   "57.1.62","57.1.63","57.1.64","57.1.65","57.1.66","57.1.67",;
   "57.1.68","57.1.69","57.1.70","57.1.71","57.5.1","57.5.2";
  },;
  {; // при оказании неотложной помощи
   "57.1.72","57.1.73","57.1.74","57.1.75","57.1.76","57.1.77",;
   "57.1.78","57.1.79","57.1.80","57.1.81";
  };
}
Static a_stom15 := {; // с лечебной целью
  {"57.1.35","57.1.37","57.1.38","57.1.40","57.1.41",;
   "57.1.43","57.1.44","57.1.46","57.1.52",;
   "57.1.57","57.1.58","57.1.59","57.1.60","57.1.61",;
   "57.4.38","57.4.39","57.4.41";
  },;
  {; // с профилактической целью
   "57.4.40","57.5.1","57.5.2";
  },;
  {}; // при оказании неотложной помощи
}
Static a_old_stom16 := {;
  {"57.1.57","57.1.58","57.1.59","57.1.60","57.1.61","57.4.38",; // с лечебной целью
   "57.1.37","57.1.40","57.1.43","57.1.46","57.1.52","57.4.39","57.4.40","57.4.41"},;
  {"57.1.57","57.1.58","57.1.59","57.1.60","57.1.61","57.4.38",; // с профилактической целью
   "57.5.1","57.5.2","57.4.40","57.4.41",;
   "57.1.37","57.1.40","57.1.43","57.1.46","57.1.52","57.4.39"},;
  {"57.1.57","57.1.58","57.1.59","57.1.60","57.1.61",;           // при оказании неотложной помощи
   "57.1.37","57.1.40","57.1.43","57.1.46","57.1.52"};
}
Static a_old_stom16_2 := {;
  {1,"2.78.47","2.78.53"},; // с лечебной целью
  {2,"2.79.52","2.79.58"},; // с профилактической целью
  {2,"2.88.40","2.88.45"},; //  -- " -- " -- " -- " -- разовое по поводу заболевания
  {3,"2.80.29","2.80.33"};  // при оказании неотложной помощи
}
// с 1 августа 2016 года
Static a_new_stom16 := {;
  {"B01.064.003","B01.064.004","B01.065.001","B01.065.002","B01.065.003","B01.065.004","B01.065.007","B01.065.008","B01.067.001","B01.067.002","B01.063.001","B01.063.002"},;
  {"B04.064.001","B04.064.002","B04.065.001","B04.065.002","B04.065.003","B04.065.004","B04.065.005","B04.065.006","B01.065.005","B01.065.006","B04.063.001"},;
  {"B01.064.003","B01.064.004","B01.065.001","B01.065.002","B01.065.003","B01.065.004","B01.065.007","B01.065.008","B01.067.001","B01.067.002","B01.063.001","B01.063.002"},;
  {"B01.064.003","B01.064.004","B01.065.001","B01.065.002","B01.065.003","B01.065.004","B01.065.007","B01.065.008","B01.067.001","B01.067.002"};
}
Static a_new_stom16_2 := {;
  {1,"2.78.54","2.78.60"},; // с лечебной целью
  {2,"2.79.59","2.79.64"},; // с профилактической целью
  {2,"2.88.46","2.88.51"},; //  -- " -- " -- " -- " -- разовое по поводу заболевания
  {3,"2.80.34","2.80.38"};  // при оказании неотложной помощи
}
Static a_coord_stom18 := {;
 {{"2.78.54","2.78.55","2.79.59","2.88.46","2.80.34"},{"B01.065.001","B01.065.002","B04.065.001","B04.065.002"}},; // терапевт
 {{"2.78.56","2.88.51","2.80.35"},{"B01.067.001","B01.067.002"}},; // хирург
 {{"2.78.57","2.79.62","2.88.49"},{"B01.063.001","B01.063.002","B04.063.001"}},; // ортодонт
 {{"2.78.58","2.79.60","2.88.47","2.80.37"},{"B01.064.003","B01.064.004","B04.064.001","B04.064.002"}},; // детский
 {{"2.78.60","2.79.63","2.88.50","2.80.38"},{"B01.065.003","B01.065.004","B04.065.003","B04.065.004"}},; // зубной врач
 {{"2.79.64"},{"B01.065.005","B01.065.006"}},; // гигиенист
 {{"2.78.59","2.79.61","2.88.48","2.80.36"},{"B01.065.007","B01.065.008","B04.065.005","B04.065.006"}}; // общей практики
}
// первичные приёмы
Static a_new_1st_stom16 := {"B01.063.001","B01.064.003","B01.065.001","B01.065.003","B01.065.005","B01.065.007","B01.067.001"}
//
Local a_stom, a_stom16_2, i, j, jm, k := 0, n := 0, lshifr, s := "", y, is_new, lshifr2 := ""
if valtype(lk_data) == "D" .and. (y := year(lk_data)) > 2015 // 2016 год
  jm := 0 ; ret_tip := 0 ; ret_kol := 0 ; is_2_88 := .f.
  is_new := (lk_data >= d_01_08_2016)
  if is_new // с 1 августа 2016 года
    a_stom16_2 := a_new_stom16_2
  else
    a_stom16_2 := a_old_stom16_2
  endif
  for i := 1 to len(arr_usl)
    lshifr := alltrim(arr_usl[i,1])
    for j := 1 to len(a_stom16_2)
      if between_shifr(lshifr,a_stom16_2[j,2],a_stom16_2[j,3])
        lshifr2 := lshifr
        k += arr_usl[i,6] // складываем количество услуг 2.*
        jm := j
        ret_tip := a_stom16_2[j,1]
        is_2_88 := (j == 3)
        ++n ; s += ' '+lshifr ; exit
      endif
    next
  next
  if n == 0
    aadd(ta,'не введена нулевая стомат.услуга (2.78.*,2.79.*,2.80.*,2.88.*)')
  elseif n > 1
    aadd(ta,'пересечение в стомат.случае разных видов посещений -'+s)
  elseif k != 1
    aadd(ta,'количество стомат.услуг должно быть =1 (2.78.*,2.79.*,2.80.*,2.88.*)')
  else
    if is_new // с 1 августа 2016 года
      k := 0
      for i := 1 to len(arrFusl)
        lshifr := alltrim(arrFusl[i,1])
        s := lshifr+iif(empty(arrFusl[i,5]), '', ' ('+alltrim(arrFusl[i,5])+')')
        if ascan(a_new_1st_stom16,lshifr) > 0
          ++k
        endif
        if eq_any(left(lshifr,3),"B01","B04")
          if ascan(a_new_stom16[jm],lshifr) > 0
            ret_kol += arrFusl[i,6] // складываем количество услуг
            if len(arrFusl[i]) > 9
              arrFusl[i,10] := 1
            endif
            if arrFusl[i,6] > 1
              aadd(ta,'в услуге '+s+' количество больше 1')
            endif
            if y > 2017 .and. !empty(lshifr2)
              for j := 1 to len(a_coord_stom18)
                if ascan(a_coord_stom18[j,2],lshifr) > 0 .and. ascan(a_coord_stom18[j,1],lshifr2) == 0
                  aadd(ta,'врачебный приём '+s+' не соответствует услуге '+lshifr2)
                endif
              next j
            endif
          else
            for j := 1 to len(a_new_stom16)
              if j == jm ; loop ; endif
              if ascan(a_new_stom16[j],lshifr) > 0
                aadd(ta,'услуга '+s+' относится к другому типу листа учёта')
                exit
              endif
            next
          endif
        endif
      next
      if k > 1
        aadd(ta,'услуга первичного стоматологического приёма оказана более одного раза в данном случае')
      endif
    else
      a_stom := a_old_stom16
      for i := 1 to len(arr_usl)
        lshifr := alltrim(arr_usl[i,1])
        if ascan(a_stom[ret_tip],lshifr) > 0
          ret_kol += arr_usl[i,6] // складываем количество услуг
          if len(arr_usl[i]) > 9
            arr_usl[i,10] := 1
          endif
        endif
      next
    endif
  endif
else // 2015 год и ранее
  if valtype(lk_data) == "D" .and. lk_data > stod("20150630")
    a_stom := a_stom15
  else
    a_stom := a_stom14
  endif
  for i := 1 to 3
    for j := 1 to len(arr_usl)
      if (k := ascan(a_stom[i],alltrim(arr_usl[j,1]))) > 0
        ++n ; s += ' '+a_stom[i,k] ; exit
      endif
    next
  next
  if n == 0
    aadd(ta,'не было ввода ни одного стоматологического посещения')
  elseif n > 1
    aadd(ta,'пересечение в стомат.случае разных видов посещений -'+s)
  endif
endif
if valtype(ret_arr) == "A"
  DEFAULT ret_tip_a TO {1,2,3}
  for i := 1 to 3
    if ascan(ret_tip_a,i) > 0
      for j := 1 to len(a_stom[i])
        aadd(ret_arr, a_stom[i,j])
      next
    endif
  next
endif
return (n == 1)

***** 11.03.14 дневной стационар с 1 апреля 2013 года
Function f_dn_stac_01_04(lshifr)
return eq_any(left(lshifr,5),"55.5.","55.6.","55.7.","55.8.")

***** 10.03.13
Function func_valid_polis(_vpolis,_SPOLIS,_NPOLIS,is_volgograd)
Local a_err := {}
Valid_SN_Polis(_vpolis,_SPOLIS,_NPOLIS,a_err,is_volgograd)
if !empty(a_err)
  n_message(a_err,,"GR+/R","W+/R",,,"G+/R")
endif
return .t.

***** 10.03.13
Function Valid_SN_Polis(_vpolis,_SPOLIS,_NPOLIS,a_err,is_volgograd)
Local i, c, CountDigit := 0, s := ""
if empty(_vpolis)
  aadd(a_err,'не заполнено поле "Вид полиса"')
endif
if empty(_npolis)
  aadd(a_err,"не заполнен номер полиса")
endif
if _vpolis == 1
  DEFAULT is_volgograd TO .f.
  if is_volgograd // ТОЛЬКО ДЛЯ ВОЛГОГРАДСКОЙ ОБЛАСТИ
    s := alltrim(_SPOLIS)+alltrim(_NPOLIS)
    CountDigit := len(s)
    s := charrem(" ",CHARREPL("0123456789", s, SPACE(10)))
    if !empty(s)
      aadd(a_err, 'недопустимые символы в (старом) Волгоградском полисе "'+s+'"')
    elseif CountDigit != 16
      aadd(a_err, "в (старом) Волгоградском полисе должно быть 16 цифр")
    endif
  endif
else
  if !empty(_SPOLIS)
    aadd(a_err, "для данного вида СЕРИЯ ПОЛИСА не заполняется")
  endif
  _NPOLIS := alltrim(_NPOLIS)
  s := charrem(" ",CHARREPL("0123456789", _NPOLIS, SPACE(10)))
  CountDigit := len(_NPOLIS)
  if !empty(s)
    aadd(a_err, '"'+s+'" недопустимые символы в НОМЕРЕ ПОЛИСА')
  elseif _vpolis == 2
    if CountDigit != 9
      aadd(a_err, _NPOLIS+" - в НОМЕРЕ временного ПОЛИСА должно быть 9 цифр")
    endif
  elseif _vpolis == 3
    if CountDigit == 16
      if !f_checksum_polis(_NPOLIS)
        aadd(a_err, _NPOLIS+" - неверная контрольная сумма в ПОЛИСЕ единого образца")
      endif
    else
      aadd(a_err, _NPOLIS+" - в НОМЕРЕ ПОЛИСА должно быть 16 цифр")
    endif
  endif
endif
return NIL

***** 15.01.17 проверить контрольную сумму в ПОЛИСЕ единого образца
Function f_checksum_polis(_NPOLIS)
Local i, n, s := ""
// а) Выбираются цифры, стоящие в нечётных позициях, по порядку,
//    начиная справа, записываются в виде числа.
for i := 15 to 1 step -2
  s += substr(_NPOLIS,i,1)
next
// Полученное число умножается на 2.
n := int(val(s)*2)
// б) Выбираются цифры, стоящие в чётных позициях, по порядку,
//    начиная справа, записываются в виде числа.
s := ""
for i := 14 to 1 step -2
  s += substr(_NPOLIS,i,1)
next
// Полученное число приписывается слева от числа, полученного в пункте а).
s += lstr(n)
// в) Складываются все цифры полученного в пункте б) числа.
n := 0
for i := 1 to len(s)
  n += int(val(substr(s,i,1)))
next
// г) Полученное в пункте в) число вычитается из ближайшего большего
//    или равного числа, кратного 10.
n := int(val(right(lstr(n),1)))
i := 0
if n > 0
  i := 10-n
endif
// В результате получается искомая контрольная цифра.
return lstr(i) == right(_NPOLIS,1)

***** 21.02.14 проверка, не встречаются ли в строке нецифровые значения
Function mo_nodigit(s)
return !empty(CHARREPL("0123456789", s, SPACE(10)))

***** 13.04.14
Function correct_profil(lp)
if lp == 2 // акушерству и гинекологии
  lp := 136 // акушерству и гинекологии (за исключением использования вспомогательных репродуктивных технологий)
elseif lp == 64 // оториноларингологии
  lp := 162 // оториноларингологии (за исключением кохлеарной имплантации)
endif
return lp

***** 31.01.19
Function verify_1_sluch(fl_view)
Local _ocenka := 5, ta := {}, u_other := {}, ssumma := 0, auet, fl, lshifr1,;
      i, j, k, c, s := " ", a_srok_lech := {}, a_period_stac := {}, a_disp := {},;
      d1, d2, cd1, cd2, ym2, a_period_amb := {}, a_1_11, u_1_stom := "", lprofil, ;
      lbukva, lst, lidsp, a_idsp := {}, a_bukva := {}, t_arr[2], ltip, lkol, ;
      a_dializ := {}, is_2_88 := .f., a_rec_ffoms := {}, mpovod := 1 // 1.0
if empty(human->k_data)
  return .t.  // не проверять
endif
DEFAULT fl_view TO .t.
rec_human := human->(recno())
Private mdate_r := human->date_r, mvozrast, mdvozrast, M1VZROS_REB := human->VZROS_REB,;
        arr_usl_otkaz := {}, m1novor := 0, mpol := human->pol, mDATE_R2 := ctod(""),;
        is_oncology := 0, is_oncology_smp := 0
if human_->NOVOR > 0
  m1novor := 1 // для переопределения M1VZROS_REB
  mDATE_R2 := human_->DATE_R2
  mpol := human_->POL2
endif
fv_date_r(human->n_data) // переопределение M1VZROS_REB
m1novor := human_->NOVOR // для запрета пересечения детей по номеру
if M1VZROS_REB != human->VZROS_REB  // если неверно,
  human->(G_RLock(forever))
  human->VZROS_REB := M1VZROS_REB   // то перезаписываем
  UnLock
endif
is_oncology := f_is_oncology(1,@is_oncology_smp)
//
glob_kartotek := human->kod_k
d1 := human->n_data ; d2 := human->k_data ; cuch_doc := human->uch_doc
ym2 := left(dtos(d2),6)
d1_year := year(d1) ; d2_year := year(d2)
cd1 := dtoc4(d1) ; cd2 := dtoc4(d2)
gnot_disp := (human->ishod < 100)
gkod_diag := human->kod_diag
gusl_ok := human_->usl_ok
Private is_disp_19 := !(d2 < d_01_05_2019)
//
if gusl_ok == 4 // если "скорая помощь"
  select HUMAN
  set order to 3
  find (dtos(d2)+cuch_doc)
  do while human->k_data == d2 .and. cuch_doc == human->uch_doc .and. !eof()
    fl := human_->usl_ok == 4 .and. glob_kartotek == human->kod_k .and. rec_human != human->(recno())
    if fl .and. human->schet > 0 .and. eq_any(human_->oplata,2,9)
      fl := .f. // лист учёта снят по акту или выставлен повторно
    endif
    if fl
      aadd(ta, '"'+alltrim(cuch_doc)+'" повтор № карты вызова от '+;
               date_8(human->k_data)+" "+alltrim(human->fio))
    endif
    skip
  enddo
endif
// просмотр других случаев данного больного
select HUMAN
set order to 2
find (str(glob_kartotek,7))
do while human->kod_k == glob_kartotek .and. !eof()
  fl := (rec_human != human->(recno()) .and. year(human->k_data) > 2018) // прошлый год не смотрим вообще
  if fl .and. human->schet > 0 .and. eq_any(human_->oplata,2,9)
    fl := .f. // лист учёта снят по акту (и выставлен повторно)
  endif
  if fl .and. m1novor != human_->NOVOR
    fl := .f. // лист учёта на новорожденного (или наоборот)
  endif
  if fl .and. gnot_disp .and. human->ishod < 100 ; // если не диспансеризация
        .and. gusl_ok == human_->usl_ok ; // если те же условия оказания помощи
        .and. !empty(gkod_diag) .and. left(gkod_diag,3) == left(human->kod_diag,3) ; // тот же основной диагноз
        .and. (k := d1 - human->k_data) >= 0  // и случай оказан раньше проверяемого
    if gusl_ok == 3     // поликлиника
      if k < 16
        aadd(a_rec_ffoms,{human->(recno()),0,k})
      endif
    elseif gusl_ok == 4 // скорая помощь
      if k < 2
        aadd(a_rec_ffoms,{human->(recno()),0,k})
      endif
    else                // круглосуточный и дневной стационар
      if k < 31
        aadd(a_rec_ffoms,{human->(recno()),0,k})
      endif
    endif
  endif
  // если диапазон лечения перекрывается в стационаре и дневном стационаре
  if fl .and. eq_any(human_->USL_OK,1,2)
    fl1 := (left(dtos(human->k_data),6) == ym2)   // один и тот же месяц окончания лечения
    fl2 := overlap_diapazon(human->n_data,human->k_data,d1,d2) // перекрывается диапазон лечения
    fl3 := .t.
    k := 0
    if is_alldializ .and. (fl1 .or. fl2) .and. year(human->k_data) > 2018 // прошлый год не смотрим вообще
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          if left(lshifr,5) == "60.3." // диализ
            if human_->USL_OK == 2 // диализ в дневном стационаре
              fl3 := .f.
              if fl1
                k := 2
              endif
            elseif fl2 // диализ в стационаре
              k := 1
            endif
            exit
          endif
        endif
        select HU
        skip
      enddo
      if k > 1
        aadd(a_dializ,{human->n_data,human->k_data,human_->USL_OK,human->OTD,k}) // диализы не в кругл.стационаре
      endif
    endif
    if k < 2 .and. fl2 .and. fl3 .and. iif(is_alldializ, year(human->k_data) > 2018, .t.)
      aadd(a_srok_lech,{human->n_data,human->k_data,human_->USL_OK,human->OTD,k})
    endif
  endif
  // если диапазон лечения частично перекрывается
  if fl .and. human->n_data <= d2 .and. d1 <= human->k_data
    is_period_amb := .f.
    // стационар
    if human_->USL_OK == 1
      aadd(a_period_stac,{human->n_data,;
                          human->k_data,;
                          human_->USL_OK,;
                          human->OTD,;
                          human->kod_diag,;
                          human_->profil,;
                          human_->RSLT_NEW,;
                          human_->ISHOD_NEW,;
                          k})
    // поликлиника
    elseif human_->USL_OK == 3 .and. human->ishod < 101 ;
             .and. !(human_->profil == 60 .and. glob_mo[_MO_KOD_TFOMS] == '103001') // не онкология
      is_period_amb := .t.
    endif
    select HU
    find (str(human->kod,7))
    do while hu->kod == human->kod .and. !eof()
      // если услуга в том же диапазоне лечения
      if between(hu->date_u,cd1,cd2)
        aadd(u_other, {hu->u_kod,hu->date_u,hu->kol_1,hu_->profil,0,human->n_data,human->k_data,human->OTD})
      endif
      if is_period_amb
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          if eq_any(left(lshifr,5),"2.80.","2.82.")
            is_period_amb := .f. ; exit
          elseif lshifr == "60.3.1" // перит.диализ
            aadd(a_dializ,{human->n_data,human->k_data,human_->USL_OK,human->OTD,3}) // диализы не в кругл.стационаре
            exit
          endif
        endif
      endif
      select HU
      skip
    enddo
    if is_period_amb
      aadd(a_period_amb,{human->n_data,human->k_data,human_->profil,human->OTD,human->(recno())})
    endif
    select MOHU
    find (str(human->kod,7))
    do while mohu->kod == human->kod .and. !eof()
      if between(mohu->date_u,cd1,cd2) // услуга в том же диапазоне лечения
        aadd(u_other, {mohu->u_kod,mohu->date_u,mohu->kol_1,mohu->profil,1})
      endif
      skip
    enddo
  endif
  // диспансеризация/профилактика взрослого населения
  if fl .and. between(human->ishod,201,205)
    // если год начала текущего лечения = году начала прошлого лечения
    if year(human->n_data) == year(d1) // для диспансеризации
      aadd(a_disp, {human->ishod-200,human->n_data,human->k_data,human_->RSLT_NEW})
    endif
    // для профилактики
    if human->ishod == 203 .and. count_years(human->date_r,human->n_data)==mvozrast
      aadd(a_disp, {human->ishod-200,human->n_data,human->k_data,human_->RSLT_NEW})
    endif
  endif
  select HUMAN
  skip
enddo
select HUMAN
set order to 1
dbGoto(rec_human)
G_RLock(forever)
human_->(G_RLock(forever))
human_2->(G_RLock(forever))
uch->(dbGoto(human->LPU))
otd->(dbGoto(human->OTD))
s := fam_i_o(human->fio)+" "
if !empty(otd->short_name)
  s += "["+alltrim(otd->short_name)+"] "
endif
s += date_8(human->n_data)+"-"+date_8(human->k_data)
@ maxrow(),0 say padr(" "+s,50) color "G+/R"
if empty(CHARREPL("0",human->uch_doc,space(10)))
  if human_->usl_ok == 3
    s := "амбулаторной карты"
  elseif human_->usl_ok == 4
    s := "карты вызова"
  else
    s := "истории болезни"
  endif
  aadd(ta,'Не заполнен номер '+s+': '+human->uch_doc)
endif
// проверка по датам
if year(human->date_r) < 1900
  aadd(ta, "дата рождения: "+full_date(human->date_r)+" ( < 1900г.)")
endif
if human->date_r > human->n_data
  aadd(ta, "дата рождения: "+full_date(human->date_r)+;
            " > даты начала лечения: "+full_date(human->n_data))
endif
if human->n_data > human->k_data
  aadd(ta, "дата начала лечения: "+full_date(human->n_data)+;
            " > даты окончания лечения: "+full_date(human->k_data))
endif
if d2_year - d1_year > 1
  aadd(ta, "время лечения составляет "+lstr(human->k_data-human->n_data)+" дней")
endif
if human->k_data > sys_date
  aadd(ta, "дата окончания лечения > системной даты: "+full_date(human->k_data))
endif
if human_->NOVOR > 0
  if empty(human_->DATE_R2)
    aadd(ta, "не введена дата рождения новорожденного")
  elseif human_->DATE_R2 > human->n_data
    aadd(ta, "дата рождения новорожденного: "+full_date(human_->DATE_R2)+" больше даты начала лечения: "+full_date(human->n_data))
  elseif human->n_data - human_->DATE_R2 > 60
    aadd(ta, "новорожденному более двух месяцев")
  endif
endif
if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
  human->KOD_DIAG := "Z01.7" // всегда
endif
mdiagnoz := diag_to_array(,,,,.t.)
if len(mdiagnoz) == 0 .or. empty(mdiagnoz[1])
  aadd(ta,'не заполнено поле "ОСНОВНОЙ ДИАГНОЗ"')
endif
if select("MKB_10") == 0
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
endif
select MKB_10
for i := 1 to len(mdiagnoz)
  mdiagnoz[i] := padr(mdiagnoz[i],6)
  find (mdiagnoz[i])
  if found()
    if !between(human->ishod,101,305) .and. i == 1 .and. !between_date(mkb_10->dbegin,mkb_10->dend,human->k_data)
      aadd(ta,"основной диагноз не входит в ОМС")
    endif
    if !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
      aadd(ta,"несовместимость диагноза по полу "+alltrim(mdiagnoz[i]))
    endif
  else
    aadd(ta,"не найден диагноз "+alltrim(mdiagnoz[i])+" в справочнике МКБ-10")
  endif
next
mdiagnoz3 := {}
if !empty(human_2->OSL1)
  aadd(mdiagnoz3,human_2->OSL1)
endif
if !empty(human_2->OSL2)
  aadd(mdiagnoz3,human_2->OSL2)
endif
if !empty(human_2->OSL3)
  aadd(mdiagnoz3,human_2->OSL3)
endif
ar := {}
select MKB_10
for i := 1 to len(mdiagnoz3)
  if left(mdiagnoz3[i],3) == "R52"
    aadd(ar,i)
  endif
  mdiagnoz3[i] := padr(mdiagnoz3[i],6)
  find (mdiagnoz3[i])
  if found()
    if !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
      aadd(ta,"несовместимость диагноза по полу "+alltrim(mdiagnoz3[i]))
    endif
  else
    aadd(ta,"не найден диагноз "+alltrim(mdiagnoz3[i])+" в справочнике МКБ-10")
  endif
next
s := ""
if len(mdiagnoz) > 0 .and. f_oms_beremenn(mdiagnoz[1]) == 3 .and. between(human_2->pn2,1,4)
  s := "R52."+{"0","1","2","9"}[human_2->pn2]
endif
if !emptyall(s,ar)
  if empty(ar)
    human_2->OSL3 := s
  else
    fl := .t.
    for i := 3 to 1 step -1
      pole := "human_2->OSL"+lstr(i)
      if left(&pole,3) == "R52"
        if fl
          fl := .f.
          if !(alltrim(pole) == s)
            &pole := s  // самый последний - перезапишем
          endif
        else
          &pole := ""   // остальные - очистим
        endif
      endif
    next
  endif
endif
if ascan(menu_vidud,{|x| x[2] == kart_->vid_ud }) == 0
  if human_->vpolis < 3
    aadd(ta,'не заполнено поле "ВИД удостоверения личности"')
  endif
else
  if empty(kart_->nom_ud)
    if human_->vpolis < 3
      aadd(ta,'должно быть заполнено поле "НОМЕР удостоверения личности" для "'+;
              inieditspr(A__MENUVERT, menu_vidud, kart_->vid_ud)+'"')
    endif
  //elseif !eq_any(kart_->vid_ud,9,18,21,24) .and. !ver_number(kart_->nom_ud)
    //aadd(ta,'поле "НОМЕР удостоверения личности" должно быть цифровым')
  endif
  if !empty(kart_->nom_ud)
    s := space(80)
    if !val_ud_nom(2,kart_->vid_ud,kart_->nom_ud,@s)
      aadd(ta,s)
    endif
  endif
  if eq_any(kart_->vid_ud,1,3,14) .and. empty(kart_->ser_ud)
    aadd(ta,'не заполнено поле "СЕРИЯ удостоверения личности" для "'+;
            inieditspr(A__MENUVERT, menu_vidud, kart_->vid_ud)+'"')
  endif
  if human_->usl_ok < 4 .and. eq_any(kart_->vid_ud,3,14) .and. ;
         !empty(kart_->ser_ud) .and. empty(del_spec_symbol(kart_->mesto_r)) .and. human_->vpolis < 3
    aadd(ta,iif(kart_->vid_ud==3,'для свид-ва о рождении','для паспорта РФ')+;
            ' обязательно заполнение поля "Место рождения"')
  endif
  if !empty(kart_->ser_ud)
    s := space(80)
    if !val_ud_ser(2,kart_->vid_ud,kart_->ser_ud,@s)
      aadd(ta,s)
    endif
  endif
endif
val_fio(retFamImOt(2,.f.),ta)
kart_->(G_RLock(forever))
s := alltrim(kart_->okatog)
if mo_nodigit(s)
  aadd(ta,"нецифровые символы в ОКАТО регистрации")
endif
if len(s) == 0
  if human_->vpolis < 3
    aadd(ta,'не заполнен код ОКАТО в поле "Адрес регистрации"')
  endif
elseif len(s) > 0 .and. len(s) < 11
  kart_->okatog := padr(s,11,"0")
endif
s := alltrim(kart_->okatop)
if mo_nodigit(s)
  aadd(ta,"нецифровые символы в ОКАТО пребывания")
endif
if len(s) > 0 .and. len(s) < 11
  kart_->okatop := padr(s,11,"0")
endif
if !empty(kart->snils)
  s := space(80)
  if !val_snils(kart->snils,2,@s)
    aadd(ta,s+" у пациента")
  endif
endif
human_->SPOLIS := val_polis(human_->SPOLIS)
human_->NPOLIS := val_polis(human_->NPOLIS)
Valid_SN_Polis(human_->vpolis,human_->SPOLIS,human_->NPOLIS,ta,between(human_->smo,'34001','34007'))
//
if select("SMO") == 0
  R_Use(dir_exe+"_mo_smo",cur_dir+"_mo_smo2","SMO")
  //index on smo to (sbase+'2')
endif
select SMO
if alltrim(human_->smo) == '34'
  if empty(human_->OKATO)
    aadd(ta,'не введён субъект РФ, в котором застрахован пациент')
  elseif empty(ret_inogSMO_name(2))
    aadd(ta,'не введена иногородняя страховая компания')
  endif
else
  select SMO
  find (human_->smo)
  if found()
    human_->OKATO := smo->okato
  else
    aadd(ta,'не найдена СМО с кодом "'+human_->smo+'"')
  endif
endif
//
d := human->k_data - human->n_data
adiag := {}
kkd := kds := kvp := kuet := kkt := ksmp := 0
mpztip := mpzkol := kol_uet := 0
kkd_1_11 := kkd_1_12 := kol_ksg := 0
is_reabil := is_dializ := is_perito := is_s_dializ := is_eko := fl_stom := fl_dop_ob_em := .f.
if is_dop_ob_em
  fl_dop_ob_em := (human->reg_lech == 9)
endif
au_lu := {} ; au_flu := {} ; au_lu_ne := {} ; arr_perso := {} ; arr_unit := {}
is_kt := is_mrt := is_angio := is_koronaro := is_g_cit := is_pr_skr := .f.
is_71_1 := is_71_2 := is_71_3 := is_dom := .f.
kvp_2_78 := kvp_2_89 := kol_2_3 := kol_2_60 := kol_2_4 := kol_2_6 := kol_55_1 := 0
kvp_70_5 := kvp_70_6 := kvp_70_3 := kvp_72_2 := kvp_72_3 := kvp_72_4 := 0
is_2_78 := is_2_79 := is_2_80 := is_2_81 := is_2_82 := .f.
is_2_83 := is_2_84 := is_2_85 := is_2_86 := is_2_87 := is_2_88 := is_2_89 := .f.
a_2_89 := array(11) ; afill(a_2_89,0)
is_disp_DDS := is_disp_DVN := is_disp_DVN3 := is_prof_PN := is_neonat := is_pren_diagn := .f.
is_70_3 := is_70_5 := is_70_6 := is_72_2 := is_72_3 := is_72_4 := .f.
lstkol := 0 ; lstshifr := shifr_ksg := "" ; cena_ksg := 0
midsp := musl_ok := mRSLT_NEW := mprofil := mvrach := m1lis := 0
lvidpoms := ""
// реабилитация - для физкультурного диспансера и других
arr_lfk := {"3.1.5","3.1.19","3.4.31",;
            "4.2.153","4.11.136",;
            "7.12.5","7.12.6","7.12.7","7.2.2",;
            "13.1.1",;
            "14.2.3",;
            "19.1.1","19.1.2","19.1.3","19.1.5","19.1.6","19.1.7","19.1.9","19.1.11","19.1.12","19.1.29","19.1.30",;
            "19.2.1","19.2.2","19.2.4","19.3.1","19.5.1","19.5.2","19.5.19","19.6.1",;
            "20.1.1","20.1.2","20.1.3","20.1.4","20.2.1","20.2.2",;
            "21.1.1","21.1.2","21.1.3","21.1.4","21.2.1",;
            "22.1.1","22.1.2","22.1.3"}
//
f_put_glob_podr(human_->USL_OK,d2,ta) // заполнить код подразделения
musl_ok := 3  // п-ка по умолчанию 
ldnej := 0
if human_->USL_OK < 3
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
      lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
      if eq_any(left(lshifr,5),"1.11.","55.1.")
        ldnej += hu->kol_1
      endif
    endif
    select HU
    skip
  enddo
endif
d_sroks := ""
select HU
find (str(human->kod,7))
do while hu->kod == human->kod .and. !eof()
  lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
  if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,@auet,@lbukva,@lst,@lidsp,@s)
    if empty(hu->kol_1)
      aadd(ta,'не заполнено поле "Количество услуг" для "'+alltrim(usl->shifr)+'"')
    endif
    lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
    if hu->STOIM_1 > 0 .or. left(lshifr,3) == "71."  // скорая помощь
      if !empty(lbukva) .and. ascan(a_bukva,{|x| x[1] == lbukva }) == 0
        aadd(a_bukva,{lbukva,lshifr})
      endif
      if !empty(lidsp) .and. ascan(a_idsp,{|x| x[1] == lidsp }) == 0
        aadd(a_idsp,{lidsp,lshifr})
      endif
    endif
    if lst == 1
      k := 0 ; lstshifr := "" ; lstkol := hu->kol_1
      for i := 1 to len(lshifr)
        if !empty(c := substr(lshifr,i,1))
          lstshifr += c
          if c == "." ; ++k ; endif
          if k == 2 ; exit ; endif // две точки в шифре услуги
        endif
      next
    endif
    otd->(dbGoto(hu->OTD))
    hu->(G_RLock(forever))
    hu_->(G_RLock(forever))
    if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
      hu_->kod_diag := mdiagnoz[1]
    endif
    if hu->is_edit == 0 .and. is_lab_usluga(lshifr)
      hu->is_edit := -1
      hu->kod_vr := hu->kod_as := 0
      lprofil := iif(left(lshifr,5) == "4.16.", 6, 34)
      if select("MOPROF") == 0
        R_Use(dir_exe+"_mo_prof",cur_dir+"_mo_prof","MOPROF")
        //index on shifr+str(vzros_reb,1)+str(profil,3) to (sbase)
      endif
      select MOPROF
      find (padr(lshifr,20)+str(iif(human->vzros_reb == 0, 0, 1),1))
      if found()
        lprofil := moprof->profil
      endif
      hu_->profil := lprofil
    endif
    if empty(hu->kod_vr)
      if eq_any(alltrim(lshifr),"4.20.2")
        // не заполняется код врача
      elseif hu->is_edit == -1
        if human_->USL_OK == 3
          hu_->PRVS := iif(hu_->profil == 34, -13, -54)
        else
          aadd(ta,'лабораторная услуга "'+alltrim(usl->shifr)+'" может быть оказана только в поликлинике')
        endif
      elseif hu->is_edit == 0
        aadd(ta,'не заполнено поле "Врач, оказавший услугу '+alltrim(usl->shifr)+'"')
      endif
    else
      if empty(mvrach) .and. !(ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34))
        mvrach := hu->kod_vr
      endif
      pers->(dbGoto(hu->kod_vr))
      mprvs := -ret_new_spec(pers->prvs,pers->prvs_new)
      if empty(mprvs)
        aadd(ta,'нет специальности в справочнике персонала у "'+alltrim(pers->fio)+'"')
      elseif hu_->PRVS != mprvs
        hu_->PRVS := mprvs
      endif
      if hu_->PRVS > 0 .and. ret_V004_V015(hu_->PRVS) == 0
        aadd(ta,'не найдено специальности в справочнике V015 у "'+alltrim(pers->fio)+'"')
      endif
      // проверяем на специальность
      UslugaAccordancePRVS(lshifr,human->vzros_reb,hu_->prvs,ta,usl->shifr,hu->kod_vr)
    endif
    if empty(mprofil)
      mprofil := usl->profil
      if empty(mprofil)
        mprofil := hu_->profil
      endif
    endif
    if empty(hu_->profil)
      hu_->profil := usl->profil
      if empty(hu_->profil)
        hu_->profil := otd->profil
      endif
    endif
    if hu_->profil > 0 .and. hu_->profil != correct_profil(hu_->profil)
      hu_->profil := correct_profil(hu_->profil)
    endif
    if !valid_GUID(hu_->ID_U)
      hu_->ID_U := mo_guid(3,hu_->(recno()))
    endif
    mdate := c4tod(hu->date_u)
    if !empty(hu->kod_vr) .and. mdate >= human->n_data .and. ascan(arr_perso,hu->kod_vr) == 0
      aadd(arr_perso,hu->kod_vr)
    endif
    mdate_u1 := dtoc4(human->n_data)
    mdate_u2 := hu->date_u
    alltrim_lshifr := alltrim(lshifr)
    left_lshifr_2 := left(lshifr,2)
    left_lshifr_3 := left(lshifr,3)
    left_lshifr_4 := left(lshifr,4)
    left_lshifr_5 := left(lshifr,5)
    if hu->kol_1 > 1 .and. ascan(arr_lfk,alltrim_lshifr) > 0
      mdate_u2 := dtoc4(mdate + hu->kol_1 - 1)
    endif
    // проверяем на профиль
    lprofil := UslugaAccordanceProfil(lshifr,human->vzros_reb,hu_->profil,ta,usl->shifr)
    if human_->USL_OK == 4 .and. lprofil != hu_->profil
      hu_->profil := lprofil
    endif
    select LUSL
    find (padr(lshifr,10))
    if found() .and. !empty(lusl->unit_code) .and. ascan(arr_unit,lusl->unit_code) == 0
      aadd(arr_unit,lusl->unit_code)
    endif
    aadd(au_lu,{lshifr,;              // 1
                mdate,;               // 2
                hu_->profil,;         // 3
                hu_->PRVS,;           // 4
                alltrim(usl->shifr),; // 5
                hu->kol_1,;           // 6
                c4tod(mdate_u2),;     // 7
                hu_->kod_diag,;       // 8
                hu->(recno()),;       // 9 - номер записи
                hu->is_edit})         // 10
    kodKSG := ""
    if is_ksg(lshifr)
      if !empty(s) .and. "," $ s
        lvidpoms := s
      endif
      shifr_ksg := kodKSG := alltrim_lshifr
      cena_ksg := hu->u_cena
      if substr(kodKSG,3,2) == "37"
        is_reabil := .t.
      elseif kodKSG == 'ds02.005'
        is_eko := .t.
      endif
      kol_ksg += hu->kol_1
    endif
    if !empty(kodKSG) // КСГ
      if left(kodKSG,2) == "st"
        musl_ok := 1  // стационар
        midsp := 33
      else
        musl_ok := 2  // дневной стационар
        midsp := 43
      endif
      mdate_u2 := dtoc4(human->k_data)
    elseif left_lshifr_2 == "1."
      musl_ok := 1  // стационар
      mdate_u2 := dtoc4(human->k_data)
      if left_lshifr_5 == "1.11."
        kkd += hu->kol_1
        kkd_1_11 += hu->kol_1
        hu_->PZKOL := hu->kol_1
        if mdate+hu->kol_1 <= d2
          mdate_u2 := dtoc4(mdate+hu->kol_1)
        endif
      elseif left_lshifr_5 == "1.12." // ВМП
        midsp := 18 // Законченный случай в круглосуточном стационаре
        kkd_1_12 += hu->kol_1
        kol_ksg += hu->kol_1
        hu_->PZKOL := d
        if !is_12_VMP
          aadd(ta,'работа с услугой '+alltrim_lshifr+' запрещена в Вашей МО')
        endif
      else
        // ошибка
      endif
      hu_->PZTIP := 1
    elseif left_lshifr_3 == "55."
      musl_ok := 2  // дн.стационар
      mdate_u2 := dtoc4(human->k_data)
      if left_lshifr_5 == "55.1." // кол-во пациенто-дней
        kds += hu->kol_1
        kol_55_1 += hu->kol_1
        hu_->PZKOL := hu->kol_1
        if mdate+hu->kol_1-1 <= d2
          mdate_u2 := dtoc4(mdate+hu->kol_1-1)
        endif
      else
        // ошибка
      endif
      hu_->PZTIP := 2
    elseif alltrim_lshifr == "56.1.723" .and. human->ishod == 202 // второй этап ДВН - одна услуга
      is_disp_DVN := !is_disp_19
    elseif eq_any(left_lshifr_5,"60.4.","60.5.") .or. eq_any(alltrim_lshifr,"4.20.702","4.15.746") // ЛДП
      mpovod := 1 // 1.0
      mIDSP := 4 // лечебно-диагностическая процедура
      kkt += hu->kol_1
      hu_->PZTIP := 5
      hu_->PZKOL := hu->kol_1
      musl_ok := 3  // п-ка
      if alltrim_lshifr == "60.4."
        is_kt := .t.
      elseif alltrim_lshifr == "60.5."
        is_mrt := .t.
      elseif alltrim_lshifr == "4.20.702"
        is_g_cit := .t.
      elseif alltrim_lshifr == "4.15.746"
        is_pr_skr := .t.
      endif
    elseif left_lshifr_5 == "60.3." // диализ
      mIDSP := 4 // лечебно-диагностическая процедура
      kkt += hu->kol_1
      hu_->PZTIP := 5
      hu_->PZKOL := hu->kol_1
      mdate_u2 := dtoc4(human->k_data)
      if alltrim_lshifr == "60.3.1"
        mpovod := 10 // 3.0
        musl_ok := 3  // п-ка
        is_perito := .t.
      elseif eq_any(alltrim_lshifr,"60.3.9","60.3.10")
        musl_ok := 2  // дневной стационар
        is_dializ := .t.
      else
        musl_ok := 1  // стационар
        is_s_dializ := .t.
      endif
    elseif eq_any(left_lshifr_5,"71.1.","71.2.","71.3.")  // скорая помощь
      musl_ok := 4  // СМП
      mIDSP := 24 // Вызов скорой медицинской помощи
      if left_lshifr_5 == "71.1."
        is_71_1 := .t.
      elseif left_lshifr_5 == "71.2."
        is_71_2 := .t.
      else
        is_71_3 := .t.
      endif
      hu_->PZTIP := 6
      hu_->PZKOL := hu->kol_1
      ksmp += hu->kol_1
    elseif left_lshifr_2 == "4."
      if left_lshifr_5 == "4.26."
        is_neonat := .t.
      endif
      if eq_any(hu->is_edit,1,2) .and. d1 <= c4tod(mdate_u2)
        m1lis := hu->is_edit
      endif
    else
      musl_ok := 3  // п-ка
      mIDSP := 1 // Посещение в поликлинике
      mpztip := 3 ; mpzkol := hu->kol_1
      if hu->KOL_RCP < 0
        is_dom := .t.
      endif
      if left_lshifr_4 == "2.3."
        kol_2_3++
      elseif left_lshifr_4 == "2.6."
        kol_2_6++
      elseif left_lshifr_5 == "2.60."
        kol_2_60++
      elseif alltrim_lshifr == "2.4.1"
        kol_2_4++
      elseif left_lshifr_5 == "2.76."
        mpovod := 7 // 2.3
        mIDSP := 12 // Комплексная услуга центра здоровья
      elseif left_lshifr_5 == "2.78."
        mpovod := 10 // 3.0
        d_sroks := AfterAtNum(".",alltrim_lshifr)
        if between_shifr(alltrim_lshifr,"2.78.54","2.78.60")
          fl_stom := .t.
          mpztip := 4
        else
          ++kvp_2_78
          is_2_78 := .t.
          mIDSP := 17 // Законченный случай в поликлинике
        endif
        mdate_u2 := dtoc4(human->k_data)
      elseif left_lshifr_5 == "2.79."
        d_sroks := AfterAtNum(".",alltrim_lshifr)
        if between_shifr(alltrim_lshifr,"2.79.44","2.79.50")
          mpovod := 8 // 2.5 - патронаж
        else
          mpovod := 9 // 2.6
        endif
        if between_shifr(alltrim_lshifr,"2.79.59","2.79.64")
          fl_stom := .t.
          mpztip := 4
        else
          is_2_79 := .t.
          if alltrim_lshifr == "2.79.51"
            is_pren_diagn := .t.
          endif
        endif
      elseif left_lshifr_5 == "2.80."
        d_sroks := AfterAtNum(".",alltrim_lshifr)
        mpovod := 2 // 1.1
        if between_shifr(alltrim_lshifr,"2.80.34","2.80.38")
          fl_stom := .t.
          mpztip := 4
        else
          is_2_80 := .t.
        endif
      elseif left_lshifr_5 == "2.81."
        mpovod := 1 // 1.0
        is_2_81 := .t.
      elseif left_lshifr_5 == "2.82."
        mpovod := 2 // 1.1
        is_2_82 := .t.
        mIDSP := 22 // Посещение в приёмном покое
      elseif left_lshifr_5 == "2.83."
        is_disp_DDS := .t.
        is_2_83 := .t.
      elseif left_lshifr_5 == "2.84."
        mIDSP := 11 // диспансеризация
        is_disp_DVN := .t.
        is_2_84 := .t.
      elseif left_lshifr_5 == "2.85." // профилактика несовершеннолетних
        is_prof_PN := .t.
        is_2_85 := .t.
      elseif left_lshifr_5 == "2.87."
        is_disp_DDS := .t.
        is_2_87 := .t.
      elseif left_lshifr_5 == "2.88."
        d_sroks := AfterAtNum(".",alltrim_lshifr)
        mpovod := 1 // 1.0
        if between_shifr(alltrim_lshifr,"2.88.46","2.88.51")
          fl_stom := .t.
          mpztip := 4
        else
          is_2_88 := .t.
        endif
      elseif left_lshifr_5 == "2.89."
        mpovod := 10 // 3.0
        ++kvp_2_89
        is_2_89 := .t.
        i := int(val(AfterAtNum(".",alltrim_lshifr)))
        if !between(i,1,len(a_2_89))
          i := 2
        endif
        a_2_89[i] := 1
        mdate_u2 := dtoc4(human->k_data)
      elseif left_lshifr_5 == "2.90."
        mIDSP := 11 // диспансеризация
        is_disp_DVN := .t.
      elseif left_lshifr_5 == "2.91."
        mIDSP := 29 // за посещение в поликлинике
        is_prof_PN := .t.
      elseif eq_any(left_lshifr_5,"70.3.","70.7.","72.1.","72.5.","72.6.","72.7.") // диспансеризация взрослых
        is_disp_DVN := .t.
        if eq_any(left_lshifr_5,"70.3.","70.7.")
          mIDSP := 11 // диспансеризация
        else
          is_disp_DVN3 := .t.
          mIDSP := 17 // Законченный случай в поликлинике
        endif
        ++kvp_70_3
        is_70_3 := .t.
        mdate_u2 := dtoc4(human->k_data)
      elseif left_lshifr_5 == "72.2." // профилактика несовершеннолетних
        is_prof_PN := .t.
        ++kvp_72_2
        is_72_2 := .t.
        mdate_u2 := dtoc4(human->k_data)
      elseif left_lshifr_5 == "70.5." // диспансеризация детей-сирот
        is_disp_DDS := .t.
        mIDSP := 11 // диспансеризация
        ++kvp_70_5
        is_70_5 := .t.
        mdate_u2 := dtoc4(human->k_data)
      elseif left_lshifr_5 == "70.6." // диспансеризация детей-сирот
        is_disp_DDS := .t.
        mIDSP := 11 // диспансеризация
        ++kvp_70_6
        is_70_6 := .t.
        mdate_u2 := dtoc4(human->k_data)
      endif
      if is_usluga_disp_nabl(alltrim_lshifr)
        mpovod := 4 // 1.3-Диспансерное наблюдение
        ldate_next := c4tod(human->DATE_OPL)
        if empty(ldate_next)
          aadd(ta,'для услуги '+alltrim_lshifr+' не заполнена "Дата следующей явки пациента для диспансерного наблюдения"')
        elseif ldate_next < d2
          aadd(ta,'для услуги '+alltrim_lshifr+' "дата следующей явки пациента для диспансерного наблюдения" меньше даты окончания лечения')
        endif
      endif
      kvp += hu->kol_1
      hu_->PZTIP := mPZTIP
      hu_->PZKOL := mPZKOL
    endif
    if musl_ok != 3 .and. !(hu->date_u==mdate_u1) .and. len(au_lu) == 1
      aadd(ta,'дата услуги '+alltrim_lshifr+' должна равняться дате начала лечения')
    endif
    hu_->date_u2 := mdate_u2
    if empty(hu_->kod_diag) .and. len(mdiagnoz) > 0
      hu_->kod_diag := mdiagnoz[1]
    endif
    select MKB_10
    find (padr(hu_->kod_diag,6))
    if !found()
      aadd(ta,"не найден диагноз "+alltrim(hu_->kod_diag)+"("+alltrim(usl->shifr)+") в справочнике МКБ-10")
    endif
    aadd(adiag,hu_->kod_diag)
    atail(au_lu)[7] := c4tod(mdate_u2)
    atail(au_lu)[8] := hu_->kod_diag
    if empty(kodKSG) // для КСГ цену перепроверим потом через definition_ksg()
      fl_del := fl_uslc := .f.
      v := fcena_oms(lshifr,;
                     (human->vzros_reb==0),;
                     human->k_data,;
                     @fl_del,;
                     @fl_uslc)
      if fl_uslc  // если нашли в справочнике ТФОМС
        if fl_del
          aadd(ta,'Цена на услугу '+rtrim(lshifr)+' отсутствует в справочнике ТФОМС')
        elseif !(round(v,2) == round(hu->u_cena,2))
          aadd(ta,'Ошибка в цене услуги['+;
                  iif(human->vzros_reb==0,'взр','реб')+;
                  ']: '+rtrim(lshifr)+": "+lstr(hu->u_cena,9,2)+;
                  ", должно быть: "+lstr(v,9,2))
        endif
        if !(round(hu->u_cena*hu->kol_1,2) == round(hu->stoim_1,2))
          aadd(ta,'Услуга '+rtrim(lshifr)+': сумма строки '+;
                  lstr(hu->stoim_1)+' не равна произведению '+;
                  lstr(hu->u_cena)+" * "+lstr(hu->kol_1))
        endif
      else
        aadd(ta,'Не найдена услуга '+rtrim(lshifr)+iif(human->vzros_reb==0," для взрослых"," для детей")+' в справочнике ТФОМС')
      endif
    endif
    ssumma += hu->stoim_1
  else
    aadd(au_lu_ne,{usl->shifr,;        // 1
                   lshifr1,;           // 2
                   usl->name,;         // 3
                   c4tod(hu->date_u),; // 4
                   hu->kol_1})         // 5
  endif
  select HU
  skip
enddo
if is_dom .and. mpovod == 1
  mpovod := 3 // 1.2 - активное посещение, т.е. на дому
endif
//
fl := (ascan(mdiagnoz, {|x| padr(x,5) == "Z03.1" }) > 0)
if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN
  is_oncology := 0
  if fl
    aadd(ta,'при диспансеризации не должно быть основного (или сопутствующего) диагноза Z03.1 "наблюдение при подозрении на злокачественную опухоль"')
  endif
else
  for i := 1 to len(au_lu)
    if !between(au_lu[i,2],d1,d2)
      aadd(ta,'услуга '+au_lu[i,5]+'('+date_8(au_lu[i,2])+') не попадает в диапазон лечения')
    endif
  next
  if human_->usl_ok < 4 .and. fl .and. !(human->OBRASHEN == '1')
    if is_oncology > 0 // онкология - направления
      aadd(ta,'основной (или сопутствующий) диагноз Z03.1 "наблюдение при подозрении на злокачественную опухоль", но лист учёта и так онкологический')
    else
      aadd(ta,'если основной (или сопутствующий) диагноз Z03.1 "наблюдение при подозрении на злокачественную опухоль", то в поле "подозрение на ЗНО" должно стоять "да"')
    endif
  endif
endif
if is_oncology_smp > 0 // специально для скорой помощи
  select ONKCO
  find (str(human->kod,7))
  if found()
    if between(onkco->PR_CONS,1,3) .and. !between(onkco->DT_CONS,d1,d2)
      aadd(ta,"дата консилиума по онкологии должна быть внутри сроков лечения")
    endif
  else
    AddRec(7)
    onkco->kod := human->kod
    onkco->PR_CONS := 0 // 0-отсутствует необходимость
    onkco->DT_CONS := ctod("")
    UnLock
  endif
endif
al := "luslf"
if is_oncology > 0 // онкология - направления
  if human->OBRASHEN == '1' .and. ascan(mdiagnoz, {|x| padr(x,5) == "Z03.1" }) == 0
    aadd(ta,'при "подозрении на ЗНО" в листе учёта обязательно должен быть основной (или сопутствующий) диагноз Z03.1 "наблюдение при подозрении на злокачественную опухоль"')
  endif
  i := 0
  arr := {}
  select ONKNA // онконаправления
  find (str(human->kod,7))
  do while onkna->kod == human->kod .and. !eof()
    ++i
    aadd(arr, {onkna->NAPR_DATE,;
               onkna->NAPR_MO,;
               onkna->NAPR_V,;
               iif(onkna->NAPR_V == 3, onkna->MET_ISSL, 0),;
               iif(onkna->NAPR_V == 3, onkna->U_KOD, 0),;
               "",;
               onkna->(recno()) })
    if !between(onkna->NAPR_DATE,d1,d2)
      aadd(ta,"дата направления должна быть внутри сроков лечения (направление "+lstr(i)+')')
    endif
    if onkna->NAPR_V == 3
      if empty(onkna->MET_ISSL)
        aadd(ta,'не определён "Метод диагн.исследования" для направления '+lstr(i))
      elseif empty(onkna->U_KOD)
        aadd(ta,'не определена "Медицинская услуга" для направления '+lstr(i))
      else
        select MOSU
        goto (onkna->U_KOD)
        if empty(mosu->shifr1)
          aadd(ta,'не определена "Медицинская услуга" для направления '+lstr(i))
        else
          dbSelectArea(al)
          find (padr(mosu->shifr1,20))
          if found()
            if onkna->MET_ISSL != &al.->onko_napr
              aadd(ta,'не тот метод диагн.исследования в услуге '+;
                      alltrim(iif(empty(mosu->shifr),mosu->shifr1,mosu->shifr))+' для направления '+lstr(i))
            endif
          else
            aadd(ta,'услуга '+alltrim(iif(empty(mosu->shifr),mosu->shifr1,mosu->shifr))+;
                    ' не найдена в справочнике (для направления '+lstr(i)+')')
          endif
        endif
      endif
    endif
    select ONKNA
    skip
  enddo
  for i := 1 to len(arr)  // ищем дубликаты направления
    s := dtos(arr[i,1])+arr[i,2]+str(arr[i,3],1)+str(arr[i,4],1)+str(arr[i,5],6)
    arr[i,6] := s
    if i > 1 .and. (j := ascan(arr, {|x| s == x[6] }, 1, i-1)) > 0
      select ONKNA
      goto (arr[i,7])
      DeleteRec(.t.)  // удаляем дубликат направления
    endif
  next
endif
//
select MOHU
find (str(human->kod,7))
do while mohu->kod == human->kod .and. !eof()
  lshifr := mosu->shifr1
  dbSelectArea(al)
  find (padr(lshifr,20))
  usl_found := found()
  s := alltrim(mosu->shifr1)+iif(empty(mosu->shifr),"","("+alltrim(mosu->shifr)+")")
  if mosu->tip == 5
    aadd(ta,'услуга "'+s+'" удалена в 2017 году')
  endif
  if empty(mohu->kol_1)
    aadd(ta,'не заполнено поле "Количество услуг" для "'+s+'"')
  endif
  mdate := c4tod(mohu->date_u)
  if !between(mdate,d1,d2)
    aadd(ta,'услуга '+s+' ('+date_8(mdate)+') не попадает в диапазон лечения')
  endif
  otd->(dbGoto(mohu->OTD))
  mohu->(G_RLock(forever))
  if empty(mohu->kod_vr)
    if usl_found .and. &al.->telemed == 1
      if !(mohu->PRVS == human_->PRVS)
        mohu->PRVS := human_->PRVS // для телемедицины специальность копируем из случая
      endif
      if !(mohu->profil == human_->profil)
        mohu->profil := human_->profil // для телемедицины профиль копируем из случая
      endif
    else
      aadd(ta,'не заполнено поле "Врач, оказавший услугу '+s+'"')
    endif
  else
    if ascan(arr_perso,mohu->kod_vr) == 0
      aadd(arr_perso,mohu->kod_vr)
    endif
    if empty(mvrach) .and. !(ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34))
      mvrach := mohu->kod_vr
    endif
    pers->(dbGoto(mohu->kod_vr))
    mprvs := -ret_new_spec(pers->prvs,pers->prvs_new)
    if empty(mprvs)
      aadd(ta,'нет специальности в справочнике персонала у "'+alltrim(pers->fio)+'"')
    elseif mohu->PRVS != mprvs
      mohu->PRVS := mprvs
    endif
    if mohu->PRVS > 0 .and. ret_V004_V015(mohu->PRVS) == 0
      aadd(ta,'не найдено специальности в справочнике V015 у "'+alltrim(pers->fio)+'"')
    endif
  endif
  if empty(mprofil)
    mprofil := mosu->profil
    if empty(mprofil)
      mprofil := mohu->profil
    endif
  endif
  if empty(mohu->profil)
    mohu->profil := mosu->profil
    if empty(mohu->profil)
      mohu->profil := otd->profil
    endif
  endif
  if empty(mohu->profil)
    aadd(ta,'для услуги '+s+' не заполнено поле "Профиль"')
  elseif mohu->profil != correct_profil(mohu->profil)
    mohu->profil := correct_profil(mohu->profil)
  endif
  ltip_onko := 0
  if usl_found
    if !empty(&al.->par_org)
      if empty(mohu->zf)
        aadd(ta,'в услуге '+s+' не введены органы (части тела), на которых выполнена операция')
      else
        a1 := List2Arr(mohu->zf)
        a2 := List2Arr(&al.->par_org)
        s1 := ""
        for i := 1 to len(a2)
          if ascan(a1,a2[i]) > 0
            s1 += lstr(a2[i])+","
          endif
        next
        if !empty(s1)
          s1 := left(s1,len(s1)-1)
        endif
        if empty(s1) .or. !(s1 == alltrim(mohu->zf))
          aadd(ta,'в услуге '+s+' некорректно введены органы (части тела) '+alltrim(mohu->zf))
        endif
      endif
    endif
    ltip_onko := &al.->onko_ksg
    do case
      case human_->usl_ok == 1
        if &al.->tip == 2
          aadd(ta,'услуга '+s+' относится к стоматологическим')
        endif
      case human_->usl_ok == 2
        if &al.->tip == 2
          aadd(ta,'услуга '+s+' относится к стоматологическим')
        endif
      case human_->usl_ok == 3
        if fl_stom
          if empty(&al.->tip)
            aadd(ta,'услуга '+s+' не относится к стоматологическим')
          else
            // проверяем на профиль
            UslugaAccordanceProfil(lshifr,human->vzros_reb,mohu->profil,ta,mosu->shifr)
            // проверяем на специальность
            UslugaAccordancePRVS(lshifr,human->vzros_reb,mohu->prvs,ta,mosu->shifr,mohu->kod_vr)
          endif
          if &al.->zf == 1  // обязателен ввод зубной формулы
            arr_zf := STverifyZF(mohu->zf,human->date_r,d1,ta,s)
            STVerifyKolZf(arr_zf,mohu->kol_1,ta,s)
          endif
        elseif &al.->telemed == 0
          aadd(ta,'услугу '+s+' нельзя вводить для амбулаторной помощи')
        endif
      case human_->usl_ok == 4
        if &al.->telemed == 0
          aadd(ta,'услугу '+s+' нельзя вводить для скорой помощи')
        endif
    endcase
  else
    aadd(ta,'услуга '+s+' не найдена в справочнике')
  endif
  if !valid_GUID(mohu->ID_U)
    mohu->ID_U := mo_guid(4,mohu->(recno()))
  endif
  mohu->date_u2 := mohu->date_u
  if empty(mohu->kod_diag) .and. len(mdiagnoz) > 0
    mohu->kod_diag := mdiagnoz[1]
  endif
  select MKB_10
  find (padr(mohu->kod_diag,6))
  if !found()
    aadd(ta,"не найден диагноз "+alltrim(mohu->kod_diag)+" в справочнике МКБ-10")
  endif
  aadd(au_flu,{lshifr,;               // 1
               mdate,;                // 2
               mohu->profil,;         // 3
               mohu->PRVS,;           // 4
               mosu->shifr,;          // 5
               mohu->kol_1,;          // 6
               c4tod(mohu->date_u2),; // 7
               mohu->kod_diag,;       // 8
               mohu->(recno()),;      // 9
               ltip_onko,;            // 10 тип онкологического лечения
               .f.})                  // 11 тип онкологического лечения ставим в услугу
  select MOHU
  skip
enddo
v := 0
if is_oncology == 2 // онкология
  select ONKSL
  find (str(human->kod,7))
  select ONKCO
  find (str(human->kod,7))
  if found()
    if between(onkco->PR_CONS,1,3) .and. !between(onkco->DT_CONS,d1,d2)
      aadd(ta,"дата консилиума по онкологии должна быть внутри сроков лечения")
    endif
  else
    AddRec(7)
    onkco->kod := human->kod
    onkco->PR_CONS := 0 // 0-отсутствует необходимость
    onkco->DT_CONS := ctod("")
    UnLock
  endif
  fl := .t.
  if between(onksl->ds1_t,0,4)
    if empty(onksl->STAD)
      aadd(ta,"онкология: не введена стадия заболевания")
    else
      f_verify_tnm(2,onksl->STAD,mdiagnoz[1],ta)
    endif
  endif
  if onksl->ds1_t == 0 .and. human->vzros_reb == 0
    if empty(onksl->ONK_T)
      fl := .f. ; aadd(ta,"онкология: не введена стадия заболевания T")
    endif
    if empty(onksl->ONK_N)
      fl := .f. ; aadd(ta,"онкология: не введена стадия заболевания N")
    endif
    if empty(onksl->ONK_M)
      fl := .f. ; aadd(ta,"онкология: не введена стадия заболевания M")
    endif
    if fl
      fl := f_verify_tnm(3,onksl->ONK_T,mdiagnoz[1],ta)
    endif
    if fl
      fl := f_verify_tnm(4,onksl->ONK_N,mdiagnoz[1],ta)
    endif
    if fl
      fl := f_verify_tnm(5,onksl->ONK_M,mdiagnoz[1],ta)
    endif
  endif
  // гистология
  /*  mmb_diag := {{"выполнено (результат получен)",98},;
                   {"выполнено (результат не получен)",97},;
                   {"отказ",0},;
                   {"не показано",7},;
                   {"противопоказано",8}} */
  if onksl->b_diag == 0 // отказ
    // при составлении реестра самостоятельно дополнить блок противопоказаний id_prot = 0
  elseif onksl->b_diag == 7 // не показано
    // при составлении реестра самостоятельно дополнить блок противопоказаний id_prot = 7
  elseif onksl->b_diag == 8 // противопоказано
    // при составлении реестра самостоятельно дополнить блок противопоказаний id_prot = 8
  elseif onksl->b_diag == -1 // выполнено (до 1 сентября 2018 года)
    // при составлении реестра блок B_DIAG не заполняется
  elseif eq_any(onksl->b_diag,97,98) // выполнено
    ar_N009 := {}
    if select("N9") == 0
      R_Use(dir_exe+"_mo_N009",,"N9")
    endif
    select N9
    dbeval({|| aadd(ar_N009,{"",n9->id_mrf,{}}) }, {|| padr(mdiagnoz[1],3) == n9->ds_mrf })
    /*if len(ar_N009) > 0
          R_Use(exe_dir+"_mo_N007",cur_dir+"_mo_N007","N7")
          R_Use(exe_dir+"_mo_N008",cur_dir+"_mo_N008","N8")
          for i := 1 to min(2,len(mm_N009))
            select N7
            find (str(mm_N009[i,2],6))
            if found()
              mm_N009[i,1] := alltrim(n7->mrf_name)
            else
              func_error(4,"Не найден гистологический признак ID_MRF="+lstr(mm_N009[i,2])+" для "+mkod_diag)
            endif
            select N8
            find (str(mm_N009[i,2],6))
            do while n8->id_mrf == mm_N009[i,2] .and. !eof()
              aadd(mm_N009[i,3], {alltrim(n8->r_m_name),n8->id_r_m})
              skip
            enddo
            if ascan(mm_N009[i,3], {|x| x[2] == &("m1gist"+lstr(i)) }) == 0
              &("m1gist"+lstr(i)) := 0
            endif
            &("mgist"+lstr(i)) := inieditspr(A__MENUVERT, mm_N009[i,3], &("m1gist"+lstr(i)))
          next
        endif*/
    // Иммуногистохимия/маркеры
    ar_N012 := {}
    if select("N12") == 0
      R_Use(dir_exe+"_mo_N012",,"N12")
    endif
    select N12
    dbeval({|| aadd(ar_N012,{"",n12->id_igh,{}}) }, {|| padr(mdiagnoz[1],3) == n12->ds_igh })
    /*if len(ar_N012) > 0
          R_Use(exe_dir+"_mo_N010",cur_dir+"_mo_N010","N10")
          R_Use(exe_dir+"_mo_N011",cur_dir+"_mo_N011","N11")
          for i := 1 to min(5,len(mm_N012))
            select N10
            find (str(mm_N012[i,2],6))
            if found()
              mm_N012[i,1] := alltrim(n10->igh_name)
            else
              func_error(4,"Не найден гистологический признак ID_IGH="+lstr(mm_N012[i,2])+" для "+mkod_diag)
            endif
            select N11
            find (str(mm_N012[i,2],6))
            do while n11->id_igh == mm_N012[i,2] .and. !eof()
              aadd(mm_N012[i,3], {alltrim(n11->kod_r_i),n11->id_r_i})
              skip
            enddo
            if ascan(mm_N012[i,3], {|x| x[2] == &("m1mark"+lstr(i)) }) == 0
              &("m1mark"+lstr(i)) := 0
            endif
            &("mmark"+lstr(i)) := inieditspr(A__MENUVERT, mm_N012[i,3], &("m1mark"+lstr(i)))
          next
        endif*/
    arr_onkdi0 := {}
    arr_onkdi1 := {}
    arr_onkdi2 := {}
    ngist := nimmun := 0 ; fl_krit_date := .f.
    select ONKDI
    find (str(human->kod,7))
    if found()
      if empty(onkdi->DIAG_DATE)
        aadd(arr_onkdi0, .f.)
      else
        if onkdi->DIAG_DATE < 0d20180901
          fl_krit_date := .t.
          //aadd(ta,"Дата взятия материала "+full_date(onkdi->DIAG_DATE)+"г. меньше КРИТИЧЕСКОЙ даты")
        endif
      endif
      do while onkdi->kod == human->kod .and. !eof()
        if onkdi->DIAG_TIP == 1
          aadd(arr_onkdi1, {onkdi->DIAG_DATE,onkdi->DIAG_TIP,onkdi->DIAG_CODE,onkdi->DIAG_RSLT})
          if onkdi->DIAG_RSLT > 0
            ++ngist
          endif
        elseif onkdi->DIAG_TIP == 2
          aadd(arr_onkdi2, {onkdi->DIAG_DATE,onkdi->DIAG_TIP,onkdi->DIAG_CODE,onkdi->DIAG_RSLT})
          if onkdi->DIAG_RSLT > 0
            ++nimmun
          endif
        endif
        skip
      enddo
    endif
    if fl_krit_date // выполнено (до 1 сентября 2018 года)
      select ONKDI // при составлении реестра блок B_DIAG не заполняется
      do while .t.
        find (str(human->kod,7))
        if !found() ; exit ; endif
        DeleteRec(.t.)
      enddo
      select ONKSL
      G_RLock(forever)
      onksl->b_diag := -1
      UnLock
    else
      if len(arr_onkdi0) > 0
        aadd(ta,"не заполннена дата взятия материала")
      endif
      if len(arr_onkdi1) != len(ar_N009)
        aadd(ta,"ошибки заполнения таблицы гистологий")
      endif
      if len(arr_onkdi2) != len(ar_N012)
        aadd(ta,"ошибки заполнения таблицы иммуногистохимий")
      endif
      if onksl->b_diag == 98
        if ngist != len(ar_N009)
          aadd(ta,"не все гистологии заполнены")
        endif
        if nimmun != len(ar_N012)
          aadd(ta,"не все иммуногистохимии заполнены")
        endif
      endif
    endif
  endif
  //
  if select("N1") == 0
    R_Use(dir_exe+"_mo_N001",,"N1")
  endif
  select ONKPR
  find (str(human->kod,7))
  do while onkpr->kod == human->kod .and. !eof()
    if !between(onkpr->PROT,0,8)
      aadd(ta,"Некорректно записано противопоказание к проведению (отказ от проведения)")
    elseif onkpr->D_PROT > d2
      n1->(dbGoto(onkpr->PROT))
      aadd(ta,alltrim(lower(n1->prot_name))+" - дата регистрации больше даты окончания лечения")
    endif
    select ONKPR
    skip
  enddo
  // услуга обязательна для стационара и дневного стационара при проведении противоопухолевого лечения
  if human_->usl_ok < 3
    arr_onk_usl := {}
    select ONKUS
    find (str(human->kod,7))
    do while onkus->kod == human->kod .and. !eof()
      if between(onkus->USL_TIP,1,6)
        aadd(arr_onk_usl,onkus->USL_TIP)
        k := iif(onkus->USL_TIP == 4, 3, onkus->USL_TIP)
        if (i := ascan(au_flu, {|x| x[10] == k })) > 0
          if onkus->USL_TIP == 1
            if empty(onkus->HIR_TIP)
              aadd(ta,'не заполнен тип хирургического лечения')
            endif
          elseif onkus->USL_TIP == 2
            if empty(onkus->LEK_TIP_V)
              aadd(ta,'не заполнен цикл лекарственной терапии')
            endif
            if empty(onkus->LEK_TIP_L)
              aadd(ta,'не заполнена линия лекарственной терапии')
            endif
          elseif between(onkus->USL_TIP,3,4)
            if empty(onkus->LUCH_TIP)
              aadd(ta,'не заполнен тип '+iif(onkus->USL_TIP==3,'','химио')+'лучевой терапии')
            endif
          endif
          au_flu[i,11] := .t.
        elseif eq_any(onkus->USL_TIP,1,3,4)
          aadd(ta,'не введена услуга для выбранного типа онкологического лечения ('+;
                  {"хирург.","","лучевая","химиолучевая"}[onkus->USL_TIP]+')')
        endif
        if onkus->USL_TIP == 5 .and. onksl->ds1_t != 6
          aadd(ta,'для выбранного повода обращения нельзя вводить "симптоматическое лечение"')
        elseif onkus->USL_TIP == 6 .and. onksl->ds1_t != 5
          aadd(ta,'для выбранного повода обращения нельзя вводить лечение "диагностика"')
        endif
      endif
      select ONKUS
      skip
    enddo
    if empty(arr_onk_usl)
      if iif(human_2->VMP == 1, .t., between(onksl->ds1_t,0,2))
        aadd(ta,'не введено онкологическое лечение')
      endif
    elseif eq_ascan(arr_onk_usl,2,4)
      if empty(onksl->crit)
        aadd(ta,'не введена схема лекарственной терапии')
      else
        if human->vzros_reb  > 0 .or. is_lymphoid(mdiagnoz[1]) // если ребёнок или ЗНО кроветворная или лимфоидная
          if alltrim(onksl->crit) == "нет"
            // всё правильно
          else
            aadd(ta,'для гематологии и/или детей вместо схемы лечения необходимо указывать "без схемы лекарственной терапии"')
          endif
        else
          if alltrim(onksl->crit) == "нет"
            aadd(ta,'нельзя указывать "без схемы", необходимо указывать схему')
          else
            // всё правильно
          endif
        endif
      endif
      if empty(onksl->wei)
        aadd(ta,'не введена масса тела для выбранного типа онкологического лечения')
      elseif !(onksl->wei < 201)
        aadd(ta,'слишком большая масса тела для выбранного типа онкологического лечения')
      endif
      if empty(onksl->hei)
        aadd(ta,'не введен рост пациента для выбранного типа онкологического лечения')
      elseif !(onksl->hei < 251)
        aadd(ta,'слишком большой рост пациента для выбранного типа онкологического лечения')
      endif
      if empty(onksl->bsa)
        aadd(ta,'не введена площадь поверхности тела для выбранного типа онкологического лечения')
      endif
      arr_lek := {} ; fl := .t.
      Select ONKLE
      find (str(human->kod,7))
      do while onkle->kod == human->kod .and. !eof()
        if empty(onkle->REGNUM)
          aadd(ta,'не введен идентификатор лекарственного препарата - отредактируйте cписок лекарственных препаратов')
          fl := .f.
          exit
        else
          if empty(onkle->CODE_SH)
            aadd(ta,'не введена схема лекарственной терапии в лекарствах - отредактируйте cписок лекарственных препаратов')
            fl := .f.
            exit
          else
            if (i := ascan(arr_lek, {|x| x[1] == onkle->REGNUM .and. x[2] == onkle->CODE_SH })) == 0
              aadd(arr_lek, {onkle->REGNUM,onkle->CODE_SH})
            endif
          endif
          if empty(onkle->DATE_INJ)
            aadd(ta,'не введена дата введения препарата - отредактируйте cписок лекарственных препаратов')
            fl := .f.
            exit
          elseif !between(onkle->DATE_INJ,d1,d2)
            aadd(ta,'дата введения препарата выходит за сроки лечения - отредактируйте cписок лекарственных препаратов')
            fl := .f.
            exit
          endif
        endif
        Select ONKLE
        skip
      enddo
      if fl
        if empty(arr_lek)
          aadd(ta,'не заполнен cписок лекарственных препаратов')
        endif
        if select("N20") == 0
          R_Use(exe_dir+"_mo_N020",cur_dir+"_mo_N020","N20")
        endif
        if select("N21") == 0
          R_Use(exe_dir+"_mo_N021",cur_dir+"_mo_N021","N21")
        endif
        select N21
        find (onksl->crit)
        if found()
          n := 0
          do while n21->code_sh == onksl->crit .and. !eof()
            if (i := ascan(arr_lek, {|x| x[1] == n21->id_lekp })) > 0
              ++n
            elseif onksl->is_err == 0
              aadd(ta,'не по всем препаратам введены даты - отредактируйте cписок лекарственных препаратов')
              fl := .f.
              exit
            endif
            select N21
            skip
          enddo
          if fl .and. n != len(arr_lek)
            aadd(ta,'отредактируйте cписок лекарственных препаратов')
          endif
        endif
      endif
    endif
  endif
endif
mpztip := mpzkol := 0
if !(round(human->cena_1,2) == round(ssumma,2))
  aadd(ta,'Сумма случая '+lstr(human->cena_1)+' не равна сумме услуг '+lstr(ssumma))
  aadd(ta,'Выполните ПЕРЕИНДЕКСИРОВАНИЕ и отредактируйте услуги в листе учёта')
endif
if empty(au_lu)
  if empty(au_flu)
    aadd(ta,'Не введено ни одной услуги')
  else
    aadd(ta,'Не введена основная услуга, но введена манипуляция Минздрава РФ')
  endif
endif
if empty(human_->profil)
  human_->profil := mprofil  // сначала профиль из первой услуги
endif
if empty(human_->profil)
  otd->(dbGoto(human->OTD))
  human_->profil := otd->profil  // если нет, то из отделения
endif
if !empty(human_->profil) .and. human_->profil != correct_profil(human_->profil)
  human_->profil := correct_profil(human_->profil)
endif
if len(mdiagnoz) > 0 .and. left(mdiagnoz[1],3) == "O04" .and. eq_any(human_->profil,136,137) // акушерству и гинекологии
  if !between(human_2->pn2,1,2)
    aadd(ta,"для диагноза "+alltrim(mdiagnoz[1])+" обязательно заполнять, искусственное прерывание беременности проводилось по медицинским показаниям или нет")
  elseif human_2->pn2 == 1 .and. (len(mdiagnoz) < 2 .or. empty(mdiagnoz[2]))
    aadd(ta,"для диагноза "+alltrim(mdiagnoz[1])+" (искусственное прерывание беременности по медицинским показаниям) не указан сопутствующий диагноз")
  endif
endif
if empty(human_->VRACH) .and. !(ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34))
  human_->VRACH := mvrach // врача из первой услуги
endif
if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
  mpzkol := len(au_lu)
endif
if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
  human->UCH_DOC := lstr(human_2->PN3) // ORDER по ЛИС перезаписываем (вдруг исправили)
  human_->VRACH := 0
  human_->PRVS := iif(human_->profil == 34, -13, -54)
elseif empty(human_->VRACH)
  aadd(ta,'не заполнено поле "Лечащий врач"')
else
  pers->(dbGoto(human_->VRACH))
  mprvs := -ret_new_spec(pers->prvs,pers->prvs_new)
  if empty(mprvs)
    aadd(ta,'нет специальности в справочнике персонала у "'+alltrim(pers->fio)+'"')
  elseif human_->PRVS != mprvs
    human_->PRVS := mprvs
  endif
  if human_->PRVS > 0 .and. ret_V004_V015(human_->PRVS) == 0
    aadd(ta,'не найдено специальности в справочнике у "'+alltrim(pers->fio)+'"')
  endif
  if ascan(arr_perso,human_->VRACH) == 0
    aadd(arr_perso,human_->VRACH)
  endif
endif
for i := 1 to len(arr_perso)
  pers->(dbGoto(arr_perso[i]))
  mvrach := fam_i_o(pers->fio)+" ["+lstr(pers->tab_nom)+"]"
  if empty(pers->snils)
    aadd(ta,"не введен СНИЛС у врача - "+mvrach)
  else
    s := space(80)
    if !val_snils(pers->snils,2,@s)
      aadd(ta,s+" у врача - "+mvrach)
    endif
  endif
next
if empty(human_->USL_OK)
  human_->USL_OK := musl_ok
elseif mUSL_OK > 0 .and. human_->USL_OK != mUSL_OK
  aadd(ta,'в поле "Условия оказания" должно быть "'+inieditspr(A__MENUVERT,glob_V006,mUSL_OK)+'"')
endif
if human_->USL_OK == 3 // для поликлиники
  s := space(80)
  if !vr_pr_1_den(2,@s,u_other)
    aadd(ta,s)
  endif
endif
if human_->USL_OK == 1 .and. substr(human_->FORMA14,1,1)=='0'
  if empty(human_->NPR_MO)
    aadd(ta,'при ПЛАНОВОЙ госпитализации должно быть заполнено поле "Направившая МО"')
  elseif empty(human_2->NPR_DATE)
    if glob_mo[_MO_KOD_TFOMS] == ret_mo(human_->NPR_MO)[_MO_KOD_TFOMS]
      human_2->NPR_DATE := d1
    else
      aadd(ta,'должно быть заполнено поле "Дата направления на госпитализацию"')
    endif
  elseif human_2->NPR_DATE > d1
    aadd(ta,'"Дата направления на госпитализацию" больше "Даты начала лечения"')
  elseif human_2->NPR_DATE+60 < d1
    aadd(ta,'Направлению на госпитализацию больше двух месяцев')
  endif
endif
if eq_any(human_->USL_OK,1,2)
  i := human_2->p_per
  if !between(human_2->p_per,1,4) // если не вводили
    i := iif(substr(human_->FORMA14,2,1) == '1', 2, 1)
  elseif substr(human_->FORMA14,2,1) == '1' // если скорая помощь
    i := 2
  elseif !(substr(human_->FORMA14,2,1) == '1') // если не скорая помощь
    if i == 2 // если скорая помощь
      i := 1
    endif
  endif
  if i != human_2->p_per
    human_2->p_per := i
  endif
endif
if kkt == 0 .and. eq_any(human_->USL_OK,1,2) .and. len(a_srok_lech) > 0
  for i := 1 to len(a_srok_lech)
    otd->(dbGoto(a_srok_lech[i,4]))
    if a_srok_lech[i,5] == 0
      otd->(dbGoto(a_srok_lech[i,4]))
      aadd(ta,'пересечение '+date_8(a_srok_lech[i,1])+"-"+date_8(a_srok_lech[i,2])+;
              iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]"))
    endif
  next
endif
if fl_stom
  mpzkol := 1
  if f_vid_p_stom(au_lu,ta,,,d2,@ltip,@lkol,@is_2_88,au_flu)
    do case
      case ltip == 1 // с лечебной целью
        mpztip := 65
        if lkol < 2
          aadd(ta,'при обращении по поводу заболевания должно быть не менее ДВУХ посещений к врачу-стоматологу')
        elseif ascan(au_lu, {|x| alltrim(x[1]) == "2.78.55" }) > 0 .and. ;
               eq_any(left(human->KOD_DIAG,3),"K05","K06") .and. lkol < 5
          aadd(ta,'при обращении по поводу заболевания пародонта должно быть не менее ПЯТИ посещений к врачу-стоматологу')
        elseif human->KOD_DIAG == "Z01.2"
          aadd(ta,'основной диагноз Z01.2 применяется при посещении с профилактической целью в стоматологии, а в случае - по поводу заболевания')
        endif
      case ltip == 2 // с профилактической целью или разовое по поводу заболевания
        mpztip := 63
        if lkol != 1
          aadd(ta,'при посещении с профилактической целью должно быть ОДНО посещение к врачу-стоматологу')
        elseif is_2_88 .and. human->KOD_DIAG == "Z01.2"
          aadd(ta,'при разовом посещении по поводу заболевания в стоматологии основной диагноз не должен быть Z01.2')
        elseif !is_2_88 .and. !(human->KOD_DIAG == "Z01.2")
          aadd(ta,'при посещении с профилактической целью в стоматологии основной диагноз всегда Z01.2')
        endif
        if !is_2_88
          human_->RSLT_NEW := 314
          human_->ISHOD_NEW := 304
        endif
      case ltip == 3 // при оказании неотложной помощи
        mpztip := 64
        if lkol != 1
          aadd(ta,'при неотложном посещении должно быть ОДНО посещение к врачу-стоматологу')
        elseif human->KOD_DIAG == "Z01.2"
          aadd(ta,'основной диагноз Z01.2 применяется при посещении с профилактической целью в стоматологии, а в случае - неотложное')
        endif
    endcase
    if ltip > 1 .and. d1 != d2
      aadd(ta,iif(ltip==2,'при посещении с профилактической целью','при неотложном посещении')+' дата окончания должна равняться дате начала лечения')
    endif
  endif
endif
if human_->USL_OK == 1  // стационар
  if human_2->VNR > 0 .and. !between(human_2->VNR,301,2499)
    aadd(ta,'вес недоношенного ребёнка должен быть более 300 г и менее 2500 г')
  endif
  for i := 1 to 3
    pole := "human_2->VNR"+lstr(i)
    if &pole > 0 .and. !between(&pole,301,2499)
      aadd(ta,'вес '+lstr(i)+'-го недоношенного ребёнка должен быть более 300 г и менее 2500 г')
    endif
  next
  if kol_ksg > 1
    aadd(ta,'введено более одной КСГ')
  endif
  mpztip := 52 // 52,"Случай госпитализации","случ.госп."},;
  mpzkol := kkd_1_11
  if (i := d2 - d1) == 0
    i := 1
  endif
  if kkd_1_11 != i
    aadd(ta,'количество койко-дней 1.11.* должно равняться '+lstr(i))
  elseif is_reabil // реабилитация
    mpztip := 53 // 53,"случай госпитализации при реабилитации","госп.реаб."},;
    if human_2->VMP == 1 // если установили ВМП
      aadd(ta,'при реабилитации не может быть оказана ВМП')
    endif
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "1.11."
        if !(alltrim(au_lu[i,1]) == "1.11.2")
          aadd(ta,'неверная услуга '+au_lu[i,1])
        endif
        aadd(a_1_11,{au_lu[i,2],;
                     au_lu[i,7],;
                     au_lu[i,3],;
                     au_lu[i,4],;
                     au_lu[i,6]})
      endif
    next
    if len(a_1_11) == 1
      if a_1_11[1,1] != d1
        aadd(ta,'дата начала услуги 1.11.2 должна равняться дате начала лечения')
      endif
      if a_1_11[1,2] != d2
        aadd(ta,'дата окончания услуги 1.11.2 должна равняться дате окончания лечения')
      endif
    else
      aadd(ta,'услуга 1.11.2 должна встречаться один раз')
    endif
  else // остальные койко-дни
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "1.11."
        if !(alltrim(au_lu[i,1]) == "1.11.1")
          aadd(ta,'неверная услуга '+au_lu[i,1])
        endif
        aadd(a_1_11,{au_lu[i,2],;
                     au_lu[i,7],;
                     au_lu[i,3],;
                     au_lu[i,4],;
                     au_lu[i,6]})
      endif
    next
    if len(a_1_11) > 0
      asort(a_1_11,,,{|x,y| x[1] < y[1] })
      if a_1_11[1,1] != d1
        aadd(ta,'дата начала первой услуги 1.11.1 должна равняться дате начала лечения')
      endif
      for i := 2 to len(a_1_11)
        if a_1_11[i-1,2] != a_1_11[i,1]
          aadd(ta,'дата начала '+lstr(i)+'-й услуги 1.11.1 должна равняться '+date_8(a_1_11[i-1,2]))
        endif
      next
      if atail(a_1_11)[2] != d2
        aadd(ta,'дата окончания последней услуги 1.11.1 должна равняться дате окончания лечения')
      endif
    endif
  endif
  if empty(human_->profil)
    aadd(ta,'в случае не проставлен профиль')
  elseif empty(human_->PRVS)
    aadd(ta,'у лечащего врача в случае не проставлена специальность')
  elseif is_reabil // реабилитация
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "1.11."
        aadd(a_1_11,{alltrim(au_lu[i,8]),;
                     au_lu[i,3],;
                     au_lu[i,4]})
      endif
    next
    fl := .f.
    for i := 1 to len(a_1_11)
      if len(mdiagnoz) > 0 .and. alltrim(mdiagnoz[1]) == a_1_11[i,1] .and. human_->PRVS == a_1_11[i,3]
        fl := .t. ; exit
      endif
    next
    if !fl
      aadd(ta,'в услуге 1.11.2 должны повториться диагноз+врач из случая')
    endif
  else // остальные койко-дни
    if human_->profil == 158
      aadd(ta,'в случае нельзя использовать профиль по: '+inieditspr(A__MENUVERT, glob_V002, 158))
    endif
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "1.11."
        aadd(a_1_11,{alltrim(au_lu[i,8]),;
                     au_lu[i,3],;
                     au_lu[i,4]})
      endif
    next
    for i := 1 to len(au_flu)
      aadd(a_1_11,{alltrim(au_flu[i,8]),;
                   au_flu[i,3],;
                   au_flu[i,4]})
    next
    fl := .f.
    for i := 1 to len(a_1_11)
      if len(mdiagnoz) > 0 .and. alltrim(mdiagnoz[1]) == a_1_11[i,1] .and. ;
              human_->profil == a_1_11[i,2] .and. human_->PRVS == a_1_11[i,3]
        if a_1_11[i,2] == 158
          aadd(ta,'в услуге нельзя использовать профиль по: '+inieditspr(A__MENUVERT, glob_V002, 158))
        endif
        fl := .t. ; exit
      endif
    next
    if !fl
      aadd(ta,'в одной из услуг должны повториться диагноз+профиль+врач из случая')
    endif
  endif
  ar_1_19_1 := {}
  for i := 1 to len(au_lu)
    if left(au_lu[i,1],5) == "1.19."
      aadd(ar_1_19_1,au_lu[i,2])
      if au_lu[i,6] > 1
        aadd(ta,'в услуге 1.19.1 ('+dtoc(au_lu[i,2])+") количество больше 1")
      endif
    endif
  next
  for j := 1 to len(ar_1_19_1)
    fl := .t.
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "1.11." .and. eq_any(ar_1_19_1[j],au_lu[i,2],au_lu[i,7])
        fl := .f. ; exit
      endif
    next
    if fl
      aadd(ta,'дата услуги 1.19.1 ('+dtoc(ar_1_19_1[j])+") обязательно должна равняться дате начала/окончания одной из услуг 1.11.1/1.11.2")
    endif
  next
  if human_2->VMP == 1 // проверим ВМП
    if is_12_VMP  // ВМП по-новому
      if !empty(ar_1_19_1)
        aadd(ta,'при оказании ВМП не может быть применена услуга 1.19.1')
      endif
      make_V018_V019(d2)
      if empty(human_2->TAL_NUM)
        aadd(ta,'ВМП оказана, но не введен номер талона на ВМП')
      endif
      if empty(human_2->TAL_D)
        aadd(ta,'ВМП оказана, но не введена дата выдачи талона на ВМП')
      elseif !eq_any(year(human_2->TAL_D),d2_year-1,d2_year,d2_year+1)
        aadd(ta,'дата выдачи талона на ВМП ('+date_8(human_2->TAL_D)+') должна быть в текущем или прошлом году')
      endif
      if empty(human_2->TAL_P)
        aadd(ta,'ВМП оказана, но не введена дата планируемой госпитализации в соответствии с талоном на ВМП')
      elseif !eq_any(year(human_2->TAL_P),d2_year-1,d2_year,d2_year+1)
        aadd(ta,'дата планируемой госпитализации в соответствии с талоном на ВМП ('+date_8(human_2->TAL_P)+') должна быть в текущем или прошлом году')
      endif
      if empty(human_2->VIDVMP)
        aadd(ta,'ВМП оказана, но не введён вид ВМП')
      elseif ascan(glob_V018, {|x| x[1] == alltrim(human_2->VIDVMP) }) == 0
        aadd(ta,'Не найден вид ВМП "'+human_2->VIDVMP+'" в справочнике V018')
      elseif empty(human_2->METVMP)
        aadd(ta,'ВМП оказана, введён вид ВМП, но не введён метод ВМП')
      elseif (i := ascan(glob_V019, {|x| x[1] == human_2->METVMP })) > 0
        if glob_V019[i,4] == alltrim(human_2->VIDVMP)
          if !(len(mdiagnoz) == 0 .or. empty(mdiagnoz[1]))
            fl := .f. ; s := padr(mdiagnoz[1],6)
            for j := 1 to len(glob_V019[i,3])
              if left(s,len(glob_V019[i,3,j])) == glob_V019[i,3,j]
                fl := .t. ; exit
              endif
            next
            if fl
              if empty(mpztip := ret_PZ_VMP(human_2->METVMP))
                mpztip := 1
              endif
            else
              aadd(ta,'основной диагноз '+s+', а у метода ВМП "'+lstr(human_2->METVMP)+'.'+alltrim(glob_V019[i,2])+'"')
              aadd(ta,'└─допустимые диагнозы: '+print_array(glob_V019[i,3]))
            endif
          endif
        else
          aadd(ta,'метод ВМП '+lstr(human_2->METVMP)+' не соответствует виду ВМП '+human_2->VIDVMP)
        endif
      else
        aadd(ta,'Не найден метод ВМП '+lstr(human_2->METVMP)+' в справочнике V019')
      endif
    else
      human_2->VMP     := 0
      human_2->VIDVMP  := ""
      human_2->METVMP  := 0
      human_2->TAL_NUM := ""
      human_2->TAL_D   := ctod("")
      human_2->TAL_P   := ctod("")
    endif
  endif
  /*if is_alldializ .and. len(a_period_stac) > 0
    fl := .f.
    for i := 1 to len(a_period_stac)
      otd->(dbGoto(a_period_stac[i,4]))
      if is_s_dializ // это диализ
        if a_period_stac[i,9] == 0 // проверяем случай основного лечения
          if human->n_data == a_period_stac[i,1] .and. human->k_data == a_period_stac[i,2]
            fl := .t.
            if !(human->kod_diag   == a_period_stac[i,5] .and.;
                 human_->profil    == a_period_stac[i,6] .and.;
                 human_->RSLT_NEW  == a_period_stac[i,7] .and.;
                 human_->ISHOD_NEW == a_period_stac[i,8])
              aadd(ta,'в стационарном случае основного лечения (с КСГ) '+;
                   date_8(a_period_stac[i,1])+"-"+date_8(a_period_stac[i,2])+;
                   iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]")+;
                   ' должны повторяться основной диагноз, профиль, результат и исход лечения из данного случая')
            endif
          endif
        endif
      else // это лечение
        if a_period_stac[i,9] == 1 // ищем диализ в стационаре
          if human->n_data == a_period_stac[i,1] .and. human->k_data == a_period_stac[i,2]
            fl := .t.
            if !(human->kod_diag   == a_period_stac[i,5] .and.;
                 human_->profil    == a_period_stac[i,6] .and.;
                 human_->RSLT_NEW  == a_period_stac[i,7] .and.;
                 human_->ISHOD_NEW == a_period_stac[i,8])
              aadd(ta,'в стационарном случае диализа '+;
                   date_8(a_period_stac[i,1])+"-"+date_8(a_period_stac[i,2])+;
                   iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]")+;
                   ' должны повторяться основной диагноз, профиль, результат и исход лечения из данного случая')
            endif
            exit
          endif
        endif
      endif
    next
    if !fl .and. is_s_dializ
      aadd(ta,'совместно со случаем стационарного диализа должен быть введён стационарный случай основного лечения (с КСГ)')
    endif
  endif*/
  // добавим период, если лечился в стационаре
  aadd(a_period_stac,{human->n_data,;
                      human->k_data,;
                      human_->USL_OK,;
                      human->OTD,;
                      human->kod_diag,;
                      human_->profil,;
                      human_->RSLT_NEW,;
                      human_->ISHOD_NEW,;
                      iif(is_s_dializ, 1, 0)})
elseif human_->USL_OK == 2 .and. kol_ksg > 0 // дневной стационар
  if kol_ksg > 1
    aadd(ta,'введено более одной КСГ')
  endif
  mpztip := 55 // 55,"случай лечения","случ.лечен"},;
  mpzkol := kol_55_1
  if empty(kol_55_1)
    aadd(ta,'не введена услуга пациенто-день 55.1.*')
  elseif is_reabil // реабилитация
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "55.1."
        if !(alltrim(au_lu[i,1]) == "55.1.4")
          aadd(ta,'неверная услуга '+rtrim(au_lu[i,1])+", должна быть 55.1.4")
        endif
        aadd(a_1_11,{au_lu[i,2],;  // 1-mdate
                     au_lu[i,7],;  // 2-c4tod(mdate_u2)
                     au_lu[i,3],;  // 3-hu_->profil
                     au_lu[i,4],;  // 4-hu_->PRVS
                     au_lu[i,6],;  // 5-hu->kol_1
                     au_lu[i,9]})  // 6-номер записи
      endif
    next
    if len(a_1_11) == 1
      if a_1_11[1,1] != d1
        aadd(ta,'дата начала услуги 55.1.4 должна равняться дате начала лечения')
      endif
      if a_1_11[1,2] != d2
        select HU
        goto (a_1_11[1,6])
        hu_->(my_Rec_Lock(a_1_11[1,6]))
        hu_->date_u2 := cd2
      endif
    else
      aadd(ta,'услуга 55.1.4 должна встречаться один раз')
    endif
  else // остальные койко-дни
    a_1_11 := {}
    s := ""
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "55.1."
        if empty(s) ; s := au_lu[i,1] ; endif
        if !(au_lu[i,1] == s) // не смешивать разные 55.1.*
          aadd(ta,'неверная услуга '+au_lu[i,1])
        elseif !eq_any(alltrim(au_lu[i,1]),"55.1.1","55.1.2","55.1.3")
          aadd(ta,'неверная услуга '+rtrim(au_lu[i,1]))
        endif
        aadd(a_1_11,{au_lu[i,2],;   // 1-mdate
                     au_lu[i,7],;   // 2-c4tod(mdate_u2)
                     au_lu[i,3],;   // 3-hu_->profil
                     au_lu[i,4],;   // 4-hu_->PRVS
                     au_lu[i,6],;   // 5-hu->kol_1
                     au_lu[i,9]})   // 6-номер записи
      endif
    next
    if (k := len(a_1_11)) > 0
      asort(a_1_11,,,{|x,y| x[1] < y[1] })
      if a_1_11[1,1] != d1
        aadd(ta,'дата начала первой услуги 55.1.* должна равняться дате начала лечения')
      endif
      for i := 2 to k
        // 1-дата окончания пред.услуги = дата начала след.услуги минус 1
        a_1_11[i-1,2] := a_1_11[i,1] - 1
        // 2-дата окончания пред.услуги = дата начала пред.услуги + дни - 1
        d := a_1_11[i-1,1] + a_1_11[i-1,5] - 1
        if d > a_1_11[i-1,2]
          aadd(ta,'дата начала '+lstr(i)+'-й услуги 55.1.* должна равняться '+date_8(d+1))
        endif
      next
      if empty(ta) // нет ошибок
        for i := 1 to k
          select HU
          goto (a_1_11[i,6])
          hu_->(my_Rec_Lock(a_1_11[i,6]))
          if i == k
            a_1_11[i,2] := d2   // для последней услуги
            hu_->date_u2 := cd2 // поставим дату окончания лечения
            d := a_1_11[i,1] + a_1_11[i,5] - 1
            if d > d2
              aadd(ta,'дата окончания последней услуги 55.1.* больше даты окончания лечения '+date_8(d))
            endif
          else
            hu_->date_u2 := dtoc4(a_1_11[i,2]) // перепишем дату окончания
          endif
        next
      endif
    endif
  endif
  if empty(human_->profil)
    aadd(ta,'в случае не проставлен профиль')
  elseif empty(human_->PRVS)
    aadd(ta,'у лечащего врача в случае не проставлена специальность')
  elseif is_reabil // реабилитация
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "55.1."
        aadd(a_1_11,{alltrim(au_lu[i,8]),;
                     au_lu[i,3],;
                     au_lu[i,4]})
      endif
    next
    fl := .f.
    for i := 1 to len(a_1_11)
      if len(mdiagnoz) > 0 .and. alltrim(mdiagnoz[1]) == a_1_11[i,1] .and. human_->PRVS == a_1_11[i,3]
        fl := .t. ; exit
      endif
    next
    if !fl
      aadd(ta,'в услуге 55.1.4 должны повториться диагноз+врач из случая')
    endif
  else // остальные койко-дни
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "55.1."
        aadd(a_1_11,{alltrim(au_lu[i,8]),;
                     au_lu[i,3],;
                     au_lu[i,4]})
      endif
    next
    for i := 1 to len(au_flu)
      aadd(a_1_11,{alltrim(au_flu[i,8]),;
                   au_flu[i,3],;
                   au_flu[i,4]})
    next
    fl := .f.
    for i := 1 to len(a_1_11)
      if len(mdiagnoz) > 0 .and. alltrim(mdiagnoz[1]) == a_1_11[i,1] .and. ;
              human_->profil == a_1_11[i,2] .and. human_->PRVS == a_1_11[i,3]
        fl := .t. ; exit
      endif
    next
    if !fl
      aadd(ta,'в одной из услуг 55.1.* должны повториться диагноз+профиль+врач из случая')
    endif
  endif
  if !empty(lvidpoms)
    if ascan(au_lu,{|x| alltrim(x[1]) == "55.1.2"}) > 0 .or. ;
       ascan(au_lu,{|x| alltrim(x[1]) == "55.1.3"}) > 0
       //
    else // только для дн.стационара при стационаре смотрим лицензию
      lvidpoms := ret_vidpom_licensia(human_->USL_OK,lvidpoms)
    endif
    if "," $ lvidpoms
      if ascan(au_lu,{|x| alltrim(x[1]) == "55.1.1"}) > 0 .or. ;
         ascan(au_lu,{|x| alltrim(x[1]) == "55.1.4"}) > 0 .or. ;
         ascan(au_lu,{|x| alltrim(x[1]) == "55.1.6"}) > 0
        if !("31" $ lvidpoms)
          aadd(ta,'для КСГ='+shifr_ksg+' в справочнике Т006 не введён вид помощи 31')
        endif
      else
        if eq_any(human_->PROFIL,57,68,97) //терапия,педиатр,врач общ.практики
          if !("12" $ lvidpoms)
            aadd(ta,'для КСГ='+shifr_ksg+' в справочнике Т006 не введён вид помощи 12; '+;
                    'вероятно, в случае не может стоять профиль "терапевт", "педиатр", "врач общ.практики"')
          endif
        else
          if !("13" $ lvidpoms)
            aadd(ta,'для КСГ='+shifr_ksg+' в справочнике Т006 не введён вид помощи 13; '+;
                    'проставьте в случае профиль "терапевт", "педиатр", "врач общ.практики" '+;
                    'или звоните в ТФОМС об ошибке в справочнике')
          endif
        endif
      endif
    endif
  endif
endif
if len(a_period_stac) > 0 //.and. !is_s_dializ .and. !is_dializ .and. !is_perito
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    aadd(u_other, {hu->u_kod,hu->date_u,hu->kol_1,hu_->profil,0,human->n_data,human->k_data,human->OTD})
    select HU
    skip
  enddo
  select HU
  set relation to
  for i := 1 to len(u_other)
    if u_other[i,5] == 0
      usl->(dbGoto(u_other[i,1]))
      lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
      if is_usluga_TFOMS(usl->shifr,lshifr1,u_other[i,7])
        mdate := c4tod(u_other[i,2])
        if (k := ascan(a_period_stac, {|x| x[1] < mdate .and. mdate < x[2]})) > 0
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          if (left(lshifr,2)=="2." .or. eq_any(left(lshifr,3),"60.","70.","71.","72.")) ;
                          .and. !(left(lshifr,5)=="60.3.") .and. is_2_stomat(lshifr,,.t.) == 0 // не стоматология
            otd->(dbGoto(u_other[i,8]))
            aadd(ta,'услуга '+alltrim(usl->shifr)+' от '+date_8(mdate)+' в случае '+;
                 date_8(u_other[i,6])+"-"+date_8(u_other[i,7])+;
                 iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]"))
            otd->(dbGoto(a_period_stac[k,4]))
            aadd(ta,'└>пересекается со случаем стац.лечения '+;
                 date_8(a_period_stac[k,1])+"-"+date_8(a_period_stac[k,2])+;
                 iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]"))
          endif
        endif
      endif
    endif
  next i
  select HU
  set relation to recno() into HU_, to u_kod into USL
endif
if eq_any(human_->USL_OK,1,2) .and. kol_ksg > 0 .and. human_2->VMP == 0 // не ВМП
  arr_ksg := definition_KSG()
  if empty(arr_ksg[2]) // нет ошибок
    if shifr_ksg == arr_ksg[3] // КСГ определена правильно
      if !(round(cena_ksg,2) == round(arr_ksg[4],2)) // не та цена
        aadd(ta,"в л/у для КСГ="+arr_ksg[3]+" стоит цена "+lstr(cena_ksg,10,2)+", а должна быть "+lstr(arr_ksg[4],10,2))
      else
        put_str_kslp_kiro(arr_ksg,.f.)
      endif
    else // не тот шифр КСГ
      aadd(ta,"в л/у стоит КСГ="+alltrim(shifr_ksg)+"("+lstr(cena_ksg,10,2)+"), а должна быть "+arr_ksg[3]+"("+lstr(arr_ksg[4],10,2)+")")
    endif
  else
    aeval(arr_ksg[2],{|x| aadd(ta,x) })
  endif
endif
// проверим период, если лечился амбулаторно
if human_->USL_OK == 3 .and. human->ishod < 101 ;// не диспансеризация
                        .and. m1novor == human_->NOVOR ;
                         .and. !(is_2_80 .or. is_2_82) ;// не неотложная помощь
                          .and. !(ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)) ; // не КДП2
                           .and. len(a_period_amb) > 0
  for i := 1 to len(a_period_amb)
    if a_period_amb[i,3] == human_->profil
      aadd(ta,'данный случай пересекается со случаем амбулаторного лечения')
      otd->(dbGoto(a_period_amb[i,4]))
      aadd(ta,'└>с тем же профилем '+;
              date_8(a_period_amb[i,1])+"-"+date_8(a_period_amb[i,2])+;
              iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]"))
      //aadd(ta,'└>данный л/у - запись № '+lstr(human->(recno()))+', прошлый л/у - запись № '+lstr(a_period_amb[i,5]))
    endif
  next
endif
if mRSLT_NEW > 0
  human_->RSLT_NEW := mRSLT_NEW // записать доп.диспансеризацию
endif
//
if is_2_78
  mIDSP := 17 // Законченный случай в поликлинике
  if kvp_2_78 > 1
    aadd(ta,'в случае применены '+lstr(kvp_2_78)+' услуги "2.78.*" (должна быть одна)')
  endif
endif
if is_disp_DDS // is_70_5 .or. is_70_6
  mIDSP := 11 // диспансеризация
  if kvp_70_5 > 1
    aadd(ta,'в случае применены '+lstr(kvp_70_5)+' услуги "70.5.*" (должна быть одна)')
  endif
  if kvp_70_6 > 1
    aadd(ta,'в случае применены '+lstr(kvp_70_6)+' услуги "70.6.*" (должна быть одна)')
  endif
endif
if is_disp_DVN // is_70_3
  mIDSP := 11 // диспансеризация
  if is_disp_DVN3 // профилактика
    mIDSP := 17 // Законченный случай в поликлинике
  endif
  if kvp_70_3 > 1
    aadd(ta,'в случае применены '+lstr(kvp_70_3)+' услуг "зак.сл." (должна быть одна)')
  endif
endif
if is_prof_PN // is_72_2
  if is_72_2
    a_idsp := {{30,"За законченный случай в поликлинике"}}
  else
    a_idsp := {{29,"За посещение в поликлинике"}}
  endif
  if kvp_72_2 > 1
    aadd(ta,'в случае применены '+lstr(kvp_72_2)+' услуги "72.2.*" (должна быть одна)')
  endif
endif
if (k := len(a_idsp)) == 0 .and. is_dializ
  a_idsp := {{4,"Лечебно-диагностическая процедура"}}
  k := 1
endif
if k == 0
  aadd(ta,'ни в одной из услуг в справочнике ТФОМС не установлен способ оплаты')
elseif k == 1
  midsp := human_->IDSP := a_idsp[1,1]
else
  aadd(ta,'смешивание способов оплаты: '+;
          lstr(a_idsp[1,1])+'-'+alltrim(a_idsp[1,2])+' и '+;
          lstr(a_idsp[2,1])+'-'+alltrim(a_idsp[2,2]))
endif
if (k := len(a_bukva)) == 0
  aadd(ta,'ни в одной из услуг в справочнике T002 не установлена буква счёта')
elseif k == 1
  //
else
  aadd(ta,'смешивание букв счёта: '+;
          a_bukva[1,1]+'-'+alltrim(a_bukva[1,2])+' и '+;
          a_bukva[2,1]+'-'+alltrim(a_bukva[2,2]))
endif
if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN
  //
elseif len(mdiagnoz) > 0 .and. ascan(adiag,mdiagnoz[1]) == 0
  aadd(ta, "основной диагноз "+rtrim(mdiagnoz[1])+" не встречается ни в одной услуге")
endif
//
if empty(human_->USL_OK)
  aadd(ta,'не заполнено поле "Условия оказания"')
endif
if empty(human_->PROFIL)
  aadd(ta,'не заполнено поле "Профиль"')
elseif eq_any(human_->USL_OK,1,2)
  if empty(human_2->profil_k)
    aadd(ta,'в случае не проставлен профиль койки')
  else
    if select("PRPRK") == 0
      R_Use(dir_exe+"_mo_prprk",cur_dir+"_mo_prprk","PRPRK")
      //index on str(profil,3)+str(profil_k,3) to (cur_dir+sbase)
    endif
    select PRPRK
    find (str(human_->profil,3)+str(human_2->profil_k,3))
    if found()
      if !empty(prprk->vozr)
        if human->vzros_reb == 0
          if prprk->vozr == "Д"
            aadd(ta,'возраст пациента не соответствует профилю койки')
          endif
        else
          if prprk->vozr == "В"
            aadd(ta,'возраст пациента не соответствует профилю койки')
          endif
        endif
      endif
      if !empty(prprk->pol) .and. !(human->pol == prprk->pol)
        aadd(ta,'значение поля "Пол" не соответствует профилю койки')
      endif
    else
      s := ""
      select PRPRK
      find (str(human_->profil,3))
      do while prprk->profil == human_->profil .and. !eof()
        s += '"'+inieditspr(A__MENUVERT, glob_V020, prprk->profil_k)+'" '
        skip
      enddo
      if empty(s)
        aadd(ta,'профиль медицинской помощи не оплачивается в ОМС')
      else
        aadd(ta,'профиль мед.помощи не соответствует профилю койки; допустимый профиль койки: '+s)
      endif
    endif
  endif
endif
if empty(human_->IDSP)
  aadd(ta,'не заполнено поле "Способ оплаты"')
endif
if empty(human_->RSLT_NEW)
  aadd(ta,'не заполнено поле "Результат обращения"')
elseif int(val(left(lstr(human_->RSLT_NEW),1))) != human_->USL_OK
  aadd(ta,'в поле "Результат обращения" стоит неверное значение')
endif
if empty(human_->ISHOD_NEW)
  aadd(ta,'не заполнено поле "Исход заболевания"')
elseif int(val(left(lstr(human_->ISHOD_NEW),1))) != human_->USL_OK
  aadd(ta,'в поле "Исход заболевания" стоит неверное значение')
endif
if is_2_82
  if human_->profil == 134
    aadd(ta,'в случае не должно быть профиля "Приёмного отделения"')
  endif
endif
if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_pren_diagn .or. kol_ksg > 0 ;
                                                .or. is_2_89 .or. is_reabil //.or. is_s_dializ
  if is_reabil  // проводим проверку на профиль при реабилитации
    if human_->profil != 158
      aadd(ta,'в случае надо использовать профиль по: '+inieditspr(A__MENUVERT, glob_V002, 158))
    endif
    for i := 1 to len(au_lu)
      if au_lu[i,3] == 158 .and. alltrim(au_lu[i,1]) != shifr_ksg
        aadd(ta,'нельзя в услуге '+alltrim(au_lu[i,1])+'использовать профиль по: '+inieditspr(A__MENUVERT, glob_V002, au_lu[i,3]))
      endif
    next
    if is_reabil_slux
      t_arr := {"1331.0","1332.0","1333.0","1335.0","2127.0","2128.0","2130.0"}
      for i := 1 to len(t_arr)
        if t_arr[i] == shifr_ksg .and. !between(human_2->PN1,1,3)
          human_2->PN1 := 1
          //aadd(ta,'в случае реабилитации для КСГ='+shifr_ksg+' необходимо заполнить поле "вид мед.реабилитации"')
        endif
      next
    endif
  endif
else
  if human_->profil == 158
    aadd(ta,'в случае нельзя использовать профиль по: '+inieditspr(A__MENUVERT, glob_V002, 158))
  endif
  arr_profil := {human_->profil}
  for i := 1 to len(au_lu)
    if au_lu[i,10] >= 0 .and. ascan(arr_profil,au_lu[i,3]) == 0
      aadd(arr_profil,au_lu[i,3])
    endif
  next
  for i := 1 to len(au_flu)
    if ascan(arr_profil,au_flu[i,3]) == 0
      aadd(arr_profil,au_flu[i,3])
    endif
  next
  if len(arr_profil) > 1
    if human_->USL_OK == 4  // если скорая помощь
      human_->profil := au_lu[1,3]
    else
      aadd(ta,'в случае использован профиль по: '+inieditspr(A__MENUVERT, glob_V002, arr_profil[1]))
      for i := 2 to len(arr_profil)
        aadd(ta,'                  а в услуге по: '+inieditspr(A__MENUVERT, glob_V002, arr_profil[i]))
      next
    endif
  elseif empty(arr_profil[1])
    aadd(ta,'в случае не проставлен профиль')
  endif
  //
  if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
    // не проверять
  else
    arr_prvs := {human_->PRVS}
    for i := 1 to len(au_lu)
      if au_lu[i,10] >= 0 .and. ascan(arr_prvs,au_lu[i,4]) == 0
        aadd(arr_prvs,au_lu[i,4])
      endif
    next
    for i := 1 to len(au_flu)
      if ascan(arr_prvs,au_flu[i,4]) == 0
        aadd(arr_prvs,au_flu[i,4])
      endif
    next
    if len(arr_prvs) > 1
      aadd(ta,'в случае использованы разные специальности врачей')
    endif
  endif
endif
if lstkol > 0
  lstshifr += "*"
  if lstkol > 1
    aadd(ta,'кол-во услуг '+lstshifr+' ('+lstr(lstkol)+') более 1')
  endif
  if len(au_lu) > 1 .and. kol_ksg == 0
    if is_2_78 .or. is_2_89 .or. is_70_5 .or. is_70_6 .or. is_70_3 .or. is_72_2
      //
    else
      aadd(ta,'кроме услуги '+lstshifr+' в листе учета не должно быть других услуг ТФОМС')
    endif
  endif
endif
s := "2.60.*"
if is_2_78
  is_1_den := is_last_den := .f. ; zs := oth_usl := 0 ; am := {}
  for i := 1 to len(au_lu)
    if left(au_lu[i,1],5) == "2.78."
      ++zs
    elseif left(au_lu[i,1],4) == "2.60"
      if d1 == au_lu[i,2]
        is_1_den := .t.
      elseif d2 == au_lu[i,2]
        is_last_den := .t.
      endif
      if (j := ascan(am,{|x| x[1] == month(au_lu[i,2])} )) == 0
        aadd(am,{month(au_lu[i,2]),0}) ; j := len(am)
      endif
      am[j,2] ++
    elseif au_lu[i,10] >= 0
      ++oth_usl
    endif
  next
  j := len(am)
  if !is_last_den .and. j > 0
    asort(am,,,{|x,y| x[1] < y[1]})
    if kol_2_60 > 1 .and. month(d2) == am[j,1]
      aadd(ta,'последняя услуга '+s+' должна быть оказана в последний день лечения')
    endif
    if month(d2) - am[j,1] > 1 .and. year(d1) == year(d2)
      aadd(ta,'в предыдущем месяце не оказано врачебных приёмов')
    endif
  endif
  if zs > 1
    aadd(ta,'в листе учета более одной услуги "законченный случай"')
  endif
  if oth_usl > 0
    aadd(ta,'кроме услуги '+lstshifr+' и '+s+' в листе учета не должно быть других услуг')
  endif
  if kol_2_60 < 2
    aadd(ta,'кроме услуги '+lstshifr+' в листе учета должно быть 2 и более услуг '+s)
  endif
  if kol_2_60 > 0 .and. !is_1_den
    aadd(ta,'первая услуга '+s+' должна быть оказана в первый день лечения')
  endif
elseif is_2_89 // медицинская реабилитация (физкультурный диспансер)
  if d1 == d2
    aadd(ta,'время лечения не должно равняться одному дню')
  endif
  if empty(human_->NPR_MO)
    aadd(ta,'не заполнено "Направившая МО", в которой пациент имел прикрепление')
  else
    if empty(human_2->NPR_DATE)
      aadd(ta,'должно быть заполнено поле "Дата направления на лечение"')
    elseif human_2->NPR_DATE > d1
      aadd(ta,'"Дата направления на лечение" больше "Даты начала лечения"')
    elseif human_2->NPR_DATE+60 < d1
      aadd(ta,'Направлению на лечение больше двух месяцев')
    endif
    if !(glob_mo[_MO_KOD_TFOMS] == '103001') .and. !ret_mo(human_->NPR_MO)[_MO_IS_UCH]
      aadd(ta,'введена "Направившая МО", которая не имеет право прикреплять пациентов')
    endif
  endif
  aps := {} // сочетание профиля и специальности
  aadd(aps, {17, {113403}})  // детская кардиология
  aadd(aps, {18, {112801,113401,113501}})  // детской онкологии
  aadd(aps, {29, {112205}})  // кардиология
  aadd(aps, {34, {1107,1301,1402,1702}})  // клинической лабораторной диагностике
  aadd(aps, {37, {2013}})  // лабораторному делу
  aadd(aps, {38, {2011}})  // лабораторной диагностике
  aadd(aps, {41, {110904,111003,111902,112216,112303,113404,2023,2024}})  // лечебной физкультуре и спортивной медицине
  aadd(aps, {42, {2002}})  // лечебному делу
  aadd(aps, {53, {1109}})  // неврологии
  aadd(aps, {57, {1110}})  // общей врачебной практике (семейной медицине)
  aadd(aps, {60, {1128}})  // онкологии
  aadd(aps, {65, {1112}})  // офтальмологии
  aadd(aps, {68, {1134}})  // педиатрии
  aadd(aps, {78, {1118,1802,2020}})  // рентгенологии
  aadd(aps, {79, {110902,112219}})  // рефлексотерапии
  aadd(aps, {97, {1122}})  // терапии
  aadd(aps, {100,{1123}})  // травматологии и ортопедии
  aadd(aps, {109,{110102,110905,111005,111904,112220,1124,113417,140107,2022}})  // физиотерапии
  aadd(aps, {111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202}})  // функциональной диагностике
  /*aadd(au_lu,{lshifr,;              // 1
                mdate,;               // 2
                hu_->profil,;         // 3
                hu_->PRVS,;           // 4
                alltrim(usl->shifr),; // 5
                hu->kol_1,;           // 6
                c4tod(mdate_u2),;     // 7
                hu_->kod_diag})       // 8
  */
  human_->profil := 158  // медицинской реабилитации
  if a_2_89[1] == 1 .and. ret_old_prvs(human_->PRVS) != 1123
    aadd(ta,'специальность у лечащего врача должна быть Травматология и ортопедия')
  elseif eq_any(1,a_2_89[2],a_2_89[4],a_2_89[5]) .and. ret_old_prvs(human_->PRVS) != 1109
    aadd(ta,'специальность у лечащего врача должна быть Неврология')
  elseif a_2_89[3] == 1
    if human->vzros_reb == 0
      if !eq_any(ret_old_prvs(human_->PRVS),112205,1122)
        aadd(ta,'специальность у лечащего врача должна быть Кардиология (или Терапия)')
      endif
    else
      if !eq_any(ret_old_prvs(human_->PRVS),113403,1134)
        aadd(ta,'специальность у лечащего врача должна быть Детская кардиология (или Педиатрия)')
      endif
    endif
  endif
  is_1_den := is_last_den := .f. ; zs := km := oth_usl := 0 ; s := "" ; shifr_zs := ""
  for i := 1 to len(au_lu)
    if left(au_lu[i,1],5) == "2.89."
      shifr_zs := au_lu[i,1] ; exit
    endif
  next
  for i := 1 to len(au_lu)
    alltrim_lshifr := alltrim(au_lu[i,1])
    left_lshifr_2 := left(au_lu[i,1],2)
    left_lshifr_3 := left(au_lu[i,1],3)
    left_lshifr_4 := left(au_lu[i,1],4)
    left_lshifr_5 := left(au_lu[i,1],5)
    if !between(au_lu[i,2],d1,d2)
      aadd(ta,'дата услуги '+alltrim_lshifr+' вне диапазона лечения ('+date_8(au_lu[i,2])+')')
    endif
    if len(mdiagnoz) > 0 .and. !(alltrim(mdiagnoz[1]) == alltrim(au_lu[i,8]))
      aadd(ta,'в услуге '+alltrim_lshifr+' должен стоять основной диагноз')
    endif
    if left_lshifr_5 == "2.89."
      zs += au_lu[i,6]
    elseif left_lshifr_4 == "2.6."
      if d1 == au_lu[i,2]
        is_1_den := .t.
      elseif d2 == au_lu[i,2]
        is_last_den := .t.
      endif
      if au_lu[i,6] != 1
        aadd(ta,'в услуге '+alltrim_lshifr+' количество не должно быть больше 1')
      endif
    elseif ascan(arr_lfk,alltrim_lshifr) > 0
      ++km
      if eq_any(alltrim_lshifr,"4.2.153","4.11.136","3.4.31") .and. au_lu[i,6] != 1
        aadd(ta,'в услуге '+alltrim_lshifr+' количество не должно быть больше 1')
      endif
      if au_lu[i,6] > 1 .and. au_lu[i,2] + au_lu[i,6] - 1 > d2
        aadd(ta,'дата окончания услуги '+alltrim_lshifr+' больше даты окончания лечения')
      endif
      fl_not_2_89 := .f.
      if left_lshifr_3 == "20." // ЛФК
        atmp := {"20.1.2","20.1.1","20.1.3","20.1.1","20.1.1","20.1.4","20.1.4","20.1.4","20.1.4","20.1.4","20.1.4"}
        if ascan(atmp,alltrim_lshifr) > 0
          for j := 1 to 11
            if a_2_89[j] == 1 .and. !(alltrim_lshifr == atmp[j])
              fl_not_2_89 := .t.
            endif
          next
        endif
        if alltrim_lshifr == "20.2.1" .and. emptyall(a_2_89[1],a_2_89[2],a_2_89[4],a_2_89[5])
          fl_not_2_89 := .t.
        elseif alltrim_lshifr == "20.2.2" .and. a_2_89[3] == 0
          fl_not_2_89 := .t.
        endif
      elseif left_lshifr_3 == "21." // массаж
        // кроме онкологии
        atmp := {"21.1.2","21.1.1","21.1.3","21.1.1","21.1.1"}
        if ascan(atmp,alltrim_lshifr) > 0
          for j := 1 to len(atmp)
            if a_2_89[j] == 1 .and. !(alltrim_lshifr == atmp[j])
              fl_not_2_89 := .t.
            endif
          next
        endif
        // онкология
        if alltrim_lshifr == "21.1.4" .and. emptyall(a_2_89[6],a_2_89[7],a_2_89[9],a_2_89[10])
          fl_not_2_89 := .t.
        endif
        if alltrim_lshifr == "21.2.1" .and. emptyall(a_2_89[6],a_2_89[7],a_2_89[8],a_2_89[9],a_2_89[11])
          fl_not_2_89 := .t.
        endif
      elseif left_lshifr_3 == "22." // рефлексотерапия
        // кроме онкологии
        atmp := {"22.1.2","22.1.1","22.1.3","22.1.1","22.1.1"}
        if ascan(atmp,alltrim_lshifr) > 0
          for j := 1 to 5
            if a_2_89[j] == 1 .and. !(alltrim_lshifr == atmp[j])
              fl_not_2_89 := .t.
            endif
          next
        endif
      endif
      if fl_not_2_89
        aadd(ta,'услуга '+alltrim_lshifr+' не входит в набор услуг для обращения с целью медицинской реабилитации '+shifr_zs)
      endif
    else
      s += alltrim_lshifr+" " ; ++oth_usl
    endif
    if (j := ascan(aps,{|x| x[1] == au_lu[i,3]})) > 0 .and. ascan(aps[j,2],ret_old_prvs(au_lu[i,4])) == 0
      aadd(ta,'в услуге '+alltrim_lshifr+' у врача стоит неверная специальность')
      aadd(ta,' у Вас: '+lstr(au_lu[i,4])+', разрешено: '+print_array(aps[j,2]))
    endif
  next
  if zs > 1
    aadd(ta,'в листе учета более одной услуги 2.89.* "законченный случай"')
  endif
  if oth_usl > 0
    aadd(ta,'в листе учета не должно быть данных услуг: '+s)
  endif
  if kol_2_6 < 2
    aadd(ta,'кроме услуги '+lstshifr+' в листе учета должно быть две и более услуг 2.6.*')
  endif
  if kol_2_6 > 0
    if !is_1_den
      aadd(ta,'первая услуга 2.6.* должна быть оказана в первый день лечения')
    endif
    if !is_last_den
      aadd(ta,'последняя услуга 2.6.* должна быть оказана в последний день лечения')
    endif
  endif
  if km == 0
    aadd(ta,'в листе учета нет ни одной услуги "манипуляция"')
  endif
elseif is_70_5 .or. is_70_6 .or. is_70_3 .or. is_72_2
  //
elseif kol_2_60 > 0
  aadd(ta,'вместе с услугами '+s+' должна быть услуга "законченный случай"')
endif
d := human->k_data - human->n_data
if kkd > 0
  if empty(d) .and. kkd == 1
    // по-новому один койко-день
  elseif kkd > d
    aadd(ta,'кол-во койко-дней ('+lstr(kkd)+') превышает срок лечения на '+lstr(kkd-d))
  elseif kkd < d
    aadd(ta,'кол-во койко-дней ('+lstr(kkd)+') меньше срока лечения на '+lstr(d-kkd))
  endif
elseif kds > 0
  if kds > (d+1)
    aadd(ta,'кол-во услуг дневного стационара ('+lstr(kds)+') превышает срок лечения на '+lstr(kds-(d+1)))
  endif
  if is_eko
    if human_->PROFIL != 137
      aadd(ta,'для КСГ='+shifr_ksg+' профиль должен быть по "акушерству и гинекологии (использованию вспомогательных репродуктивных технологий)"')
    endif
    a_1_11 := {}
    for i := 1 to len(au_flu)
      aadd(a_1_11,alltrim(au_flu[i,1]))
    next
    j := 1 // КСЛП - 1 схема
    if ascan(a_1_11,"A11.20.031") > 0  // крио
      j := 6  // 6 схема
      if ascan(a_1_11,"A11.20.028") > 0 // третий этап
        j := 2   // 2 схема
      endif
    elseif ascan(a_1_11,"A11.20.025.001") > 0  // первый этап
      j := 3  // 3 схема
      if ascan(a_1_11,"A11.20.036") > 0  // завершающий второй этап
        j := 4  // 4 схема
      elseif ascan(a_1_11,"A11.20.028") > 0  // завершающий третий этап
        j := 5  // 5 схема
      endif
    elseif ascan(a_1_11,"A11.20.030.001") > 0  // только четвертый этап
      j := 7  // 7 схема
    endif
    ashema := {;
      {"A11.20.017"},;
      {"A11.20.017","A11.20.028","A11.20.031"},;
      {"A11.20.017","A11.20.025.001"},;
      {"A11.20.017","A11.20.025.001","A11.20.036"},;
      {"A11.20.017","A11.20.025.001","A11.20.028"},;
      {"A11.20.017","A11.20.031"},;
      {"A11.20.017","A11.20.030.001"};
    }
    if (k := len(ashema[j])) == (n := len(a_1_11))
      //
    elseif k > n
      aadd(ta,'в листе учёта по ЭКО не хватает услуг '+print_array(a_1_11))
    elseif k < n
      for i := 1 to k
        if (n := ascan(a_1_11,ashema[j,i])) > 0
          Del_Array(a_1_11,n)
        endif
      next
      if len(a_1_11) > 0
        aadd(ta,'в листе учёта по ЭКО лишние услуги '+print_array(a_1_11))
      endif
    endif
  endif
elseif kkt > 0 .and. !is_s_dializ .and. !is_dializ .and. !is_perito
  mPZTIP := 66 // 66,"Р-исследование","Р-исслед."},;
  mPZKOL := kkt
  if !emptyall(kkd,kds,kvp,ksmp)
    aadd(ta,'кроме услуг 60.* в листе учета не должно быть других услуг ТФОМС')
  endif
  if human_->USL_OK != 3
    aadd(ta,'в поле "Условия оказания" должно быть "Поликлиника"')
  endif
  if is_kt
    s := "КТ"
  elseif is_mrt
    s := "МРТ"
  elseif is_angio
    s := "ангиографии"
  elseif is_koronaro
    s := "коронарографии"
  elseif is_g_cit
    s := "жидкостной цитологии"
    mPZTIP := 68 // 68,"жидкостная цитология","жидк.цитол"},;
  elseif is_pr_skr
    s := "пренатального скрининга"
    mPZTIP := 67 // 67,"пренатальный скрининг","прен.скрин"},;
  endif
  if empty(human_->NPR_MO)
    aadd(ta,'для '+s+' должно быть заполнено "Направившая МО"')
  elseif empty(human_2->NPR_DATE)
    if glob_mo[_MO_KOD_TFOMS] == ret_mo(human_->NPR_MO)[_MO_KOD_TFOMS]
      human_2->NPR_DATE := d1
    else
      aadd(ta,'должно быть заполнено поле "Дата направления"')
    endif
  elseif human_2->NPR_DATE > d1
    aadd(ta,'"Дата направления" больше "Даты начала лечения"')
  elseif human_2->NPR_DATE+60 < d1
    aadd(ta,'Направлению больше двух месяцев')
  endif
  if !eq_any(human_->ISHOD_NEW,304)
    aadd(ta,'в поле "Исход заболевания" должно быть "Без перемен"')
  endif
  if is_g_cit .or. is_pr_skr
    if !eq_any(human_->RSLT_NEW,314)
      aadd(ta,'в поле "Результат обращения" должно быть "Динамическое наблюдение"')
    endif
    if kkt > 1
      aadd(ta,'кол-во услуг '+s+' ('+lstr(kkt)+') не должно быть более 1')
    endif
    if human_->PROFIL != 34
      aadd(ta,'для '+s+' профиль должен быть КЛИНИЧЕСКАЯ ЛАБОРАТОРНАЯ ДИАГНОСТИКА')
    endif
  else
    if !eq_any(human_->RSLT_NEW,304)
      aadd(ta,'в поле "Результат обращения" должно быть "Лечение продолжено"')
    endif
    if kkt > 2
      //aadd(ta,'кол-во услуг '+s+' ('+lstr(kkt)+') не должно быть более 2')
    endif
    if human_->PROFIL != 78
      aadd(ta,'для '+s+' профиль должен быть РЕНТГЕНОЛОГИЯ')
    endif
  endif
elseif kvp > 0
  mPZKOL := kvp-kvp_2_78-kvp_2_89
  if mIDSP == 12
    mPZTIP := 60 // 60,"Посещение профилактическое Центра здоровья","ПосПроф.ЦЗ"},;
    if kvp > 1 // Комплексная услуга центра здоровья
      aadd(ta,'в центре здоровья введено '+lstr(kvp)+' услуги (должна быть одна)')
    endif
  endif
  if d2 > d1
    if is_2_88
      if month(d1) == month(d2)
        aadd(ta,'для данной услуги срок лечения - один день')
      elseif month(d2) - month(d1) > 1 .and. year(d1) == year(d2)
        aadd(ta,'для данной услуги срок лечения не может быть более месяца')
      endif
    elseif is_2_80 .or. is_2_81 .or. is_2_82 .or. is_pren_diagn
      aadd(ta,'для данной услуги срок лечения - один день')
    endif
  endif
  if kvp > 1 .and. (is_2_80 .or. is_2_81 .or. is_2_82 .or. is_2_88)
    aadd(ta,'количество услуг должно быть равно 1')
  endif
  if is_2_78 .or. is_2_89
    mpztip := 59 // 59,"Обращение","амб.обращ."},;
    mPZKOL := 1 // ???
  elseif is_2_79 .or. is_2_81 .or. is_2_88
    mpztip := 57 // 57,"Посещение профилактическое","амб.проф."},;
  elseif is_2_80 .or. is_2_82
    mpztip := 58 // 58,"Посещение неотложное","амб.неотл."},;
  endif
elseif ksmp > 0
  mpztip := 51 // 51,"Вызов СМП","вызов СМП"},;
  mpzkol := ksmp
  if ksmp > 1
    aadd(ta,'количество услуг СМП должно быть равно 1')
  endif
  if len(au_lu) > 1
    aadd(ta,'кроме услуги 71.* в листе учета не должно быть других услуг ТФОМС')
  endif
  if human_->USL_OK != 4
    aadd(ta,'для услуги СМП условия должны быть "Скорая помощь"')
  endif
  /*if human_->PROFIL != 84
    aadd(ta,'для услуги СМП профиль должен быть по "скорой медицинской помощи"')
  endif*/
  if human_->IDSP != 24
    aadd(ta,'для услуги СМП способ оплаты должен быть "Вызов скорой медицинской помощи"')
  endif
  if d1 < d2
    aadd(ta,'для скорой помощи дата начала должна равняться дате окончания лечения')
  endif
  if is_komm_SMP() .and. d2 < 0d20190501 // если это коммерческая скорая
    if is_71_1
      aadd(ta,'для коммерческой СМП необходимо применять услуги 71.2.*')
    endif
  elseif human_->OKATO == '18000'
    if is_71_2
      aadd(ta,'для пациентов, застрахованных на территории Волгоградской области,')
      aadd(ta,'необходимо применять услуги 71.1.*')
    endif
  else
    if is_71_1
      aadd(ta,'для пациентов, застрахованных за пределами Волгоградской области,')
      aadd(ta,'необходимо применять услуги 71.2.*')
    endif
  endif
endif
if is_dializ
  s := "гемодиализа"
  if kds > 0 .and. kol_ksg == 0
    aadd(ta,'для '+s+' не вводится пациенто-день')
  endif
  if !eq_any(human_->PROFIL,56) // НЕФРОЛОГИЯ
    aadd(ta,'для '+s+' профиль должен быть НЕФРОЛОГИЯ')
  endif
  if !eq_any(ret_old_prvs(human_->PRVS),112207,113412) // НЕФРОЛОГИЯ
    aadd(ta,'для '+s+' специальность врача должна быть НЕФРОЛОГИЯ')
  endif
  human_->NPR_MO := glob_mo[_MO_KOD_TFOMS] // безусловно проставляем направившую МО
  human_2->NPR_DATE := d1
  mpztip := 56 // 56,"случай диализа","случ.диал."},;
  mpzkol := kkt
  /*if human_->RSLT_NEW != 201
    aadd(ta,'в поле "Результат обращения" должно быть "Выписан"')
  endif*/
  /*for i := 1 to len(a_dializ)
    if a_dializ[i,5] == 2
      aadd(ta,'в данном отчётном месяце уже был гемодиализ '+date_8(a_dializ[i,1])+"-"+date_8(a_dializ[i,2]))
    elseif a_dializ[i,5] == 3 .and. overlap_diapazon(a_dializ[i,1],a_dializ[i,2],d1,d2)
      if left(upper(human->fio),4) == "БОРЩ"
        // этого человека не проверяем
      else
        aadd(ta,'пересечение гемодиализа с перитонеальным диализом '+date_8(a_dializ[i,1])+"-"+date_8(a_dializ[i,2]))
      endif
    endif
  next*/
endif
if is_perito
  s := "для ПЕРИТОНЕАЛЬНОГО ДИАЛИЗА "
  if human_->PROFIL != 56
    aadd(ta,s+'профиль должен быть НЕФРОЛОГИЯ')
  endif
  if !eq_any(ret_old_prvs(human_->PRVS),112207,113412) // НЕФРОЛОГИЯ
    aadd(ta,s+'специальность врача должна быть НЕФРОЛОГИЯ')
  endif
  human_->NPR_MO := glob_mo[_MO_KOD_TFOMS] // безусловно проставляем направившую МО
  human_2->NPR_DATE := d1
  mpztip := 56 // 56,"случай диализа","случ.диал."},;
  mpzkol := kkt
  /*if !eq_any(human_->RSLT_NEW,201,202,203,205)
    aadd(ta,'в поле "Результат обращения" стоит неверное значение')
  endif
  if human_->ISHOD_NEW == 201
    aadd(ta,'в поле "Исход заболевания" стоит неверное значение')
  endif*/
  /*for i := 1 to len(a_dializ)
    if a_dializ[i,5] == 3
      aadd(ta,'в данном отчётном месяце уже был перитонеальный диализ '+date_8(a_dializ[i,1])+"-"+date_8(a_dializ[i,2]))
    elseif a_dializ[i,5] == 2 .and. overlap_diapazon(a_dializ[i,1],a_dializ[i,2],d1,d2)
      if left(upper(human->fio),4) == "БОРЩ"
        // этого человека не проверяем
      else
        aadd(ta,'пересечение перитонеального диализа с гемодиализом '+date_8(a_dializ[i,1])+"-"+date_8(a_dializ[i,2]))
      endif
    endif
  next*/
endif
if is_s_dializ
  s := "услуги диализа в стационаре"
  human_->NPR_MO := glob_mo[_MO_KOD_TFOMS] // безусловно проставляем направившую МО
  human_2->NPR_DATE := d1
  mpztip := 54 // 54,"случай ЗПТ","случай ЗПТ"},;
  mpzkol := kkt
  for i := 1 to len(a_dializ)
    j := a_dializ[i,5] - 1
    if !between(j,1,2)
      j := 1
    endif
    if overlap_diapazon(a_dializ[i,1],a_dializ[i,2],d1,d2) .or. eq_any(d1,a_dializ[i,1],a_dializ[i,2]) ;
                                                           .or. eq_any(d2,a_dializ[i,1],a_dializ[i,2])
      aadd(ta,'услуга диализа в стационаре пересекается со случаем '+{"гемо","перитонеального "}[j]+'диализа '+date_8(a_dializ[i,1])+"-"+date_8(a_dializ[i,2]))
    endif
  next
  for i := 1 to len(a_srok_lech)
    otd->(dbGoto(a_srok_lech[i,4]))
    if a_srok_lech[i,5] == 1
      otd->(dbGoto(a_srok_lech[i,4]))
      aadd(ta,'пересечение с аналогичным диализом '+date_8(a_srok_lech[i,1])+"-"+date_8(a_srok_lech[i,2])+;
              iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]"))
    endif
  next
endif
if is_disp_DDS //
  metap := 1
  m1mobilbr := 0
  human->OBRASHEN := ''
  tip_lu := iif(!empty(human->ZA_SMO), TIP_LU_DDS, TIP_LU_DDSOP)
  if d1_year != d2_year
    aadd(ta,'Дата начала и окончания случая должны быть в одном году')
  endif
  if eq_any(human->ishod,101,102)
    metap := human->ishod-100
    read_arr_DDS(human->kod)
  else
    aadd(ta,'Диспансеризацию детей-сирот надо вводить через специальный экран ввода')
  endif
  is_1_den := is_last_den := .f. ; zs := kvp := 0 ; oth_usl := ""
  for i := 1 to len(au_lu)
    if au_lu[i,3] == 0
      aadd(ta,'в услуге '+alltrim(au_lu[i,1])+' не проставлен профиль')
    endif
    if au_lu[i,4] == 0
      aadd(ta,'в услуге '+alltrim(au_lu[i,1])+' не проставлена спец-ть врача')
    endif
    if au_lu[i,2] > d2
      aadd(ta,'услуга '+au_lu[i,5]+'('+date_8(au_lu[i,2])+') не попадает в диапазон лечения')
    endif
    if is_issl_DDS(au_lu[i],mvozrast,ta)
      s := 'услуга '+au_lu[i,5]+'('+date_8(au_lu[i,2])+')'
      if alltrim(au_lu[i,1]) == "7.61.3"
        if au_lu[i,2] < addmonth(d1,-12)
          aadd(ta,'Флюорография оказана более 1 года назад')
        endif
      elseif mvozrast < 2
        if au_lu[i,2] < addmonth(d1,-1)
          aadd(ta,s+' оказана более 1 месяца назад')
        endif
      else
        if au_lu[i,2] < addmonth(d1,-3)
          aadd(ta,s+' оказана более 3 месяцев назад')
        endif
      endif
      if d1 == au_lu[i,2]
        is_1_den := .t.
      endif
    else
      s := 'услуга '+au_lu[i,5]+'-'+inieditspr(A__MENUVERT,glob_V002,au_lu[i,3])+'('+date_8(au_lu[i,2])+')'
      if is_osmotr_DDS_1_etap(au_lu[i],mvozrast,metap,mpol,tip_lu) //eq_any(alltrim(au_lu[i,5]),'2.3.1','2.4.1') // + 2.4.1-психиатр
        if eq_any(au_lu[i,3],68,57) // педиатр (врач общей практики)
          if au_lu[i,2] < d1
            aadd(ta,'Дата осмотра педиатра на I этапе не попадает в диапазон лечения')
          endif
        elseif mvozrast < 2
          if au_lu[i,2] < addmonth(d1,-1)
            aadd(ta,s+' оказана более 1 месяца назад')
          endif
        else
          if au_lu[i,2] < addmonth(d1,-3)
            aadd(ta,s+' оказана более 3 месяцев назад')
          endif
        endif
      elseif au_lu[i,2] < d1
        aadd(ta,s+' не попадает в диапазон лечения')
      endif
      if eq_any(left(au_lu[i,1],5),"70.5.","70.6.")
        ++zs
        s := ret_shifr_zs_DDS(tip_lu)
        if !(alltrim(au_lu[i,1]) == s)
          aadd(ta,'в л/у услуга '+alltrim(au_lu[i,1])+', а должна быть '+s+;
                  ' для возраста '+lstr(mvozrast)+' '+s_let(mvozrast))
        endif
      elseif is_osmotr_DDS(au_lu[i],mvozrast,ta,metap,mpol,tip_lu)
        if eq_any(left(au_lu[i,1],5),"2.83.","2.87.")
          ++kvp
        elseif left(au_lu[i,1],4) == "2.3."
          ++kvp
        endif
        if d1 == au_lu[i,2]
          is_1_den := .t.
        endif
        if d2 == au_lu[i,2]
          is_last_den := .t.
        endif
      else
        oth_usl += alltrim(au_lu[i,1])+" "
      endif
    endif
  next
  if metap == 1 .and. zs > 1
    aadd(ta,'в листе учета более одной услуги "законченный случай"')
  elseif metap == 2 .and. zs > 0
    aadd(ta,'для I и II этапов ДДС не должно быть услуг "законченный случай"')
  endif
  if !empty(oth_usl)
    aadd(ta,'в листе учета ДДС лишние услуги: '+oth_usl)
  endif
  if !is_1_den
    //aadd(ta,'первый врачебный осмотр должен быть оказан в первый день лечения')
  endif
  if !is_last_den
    aadd(ta,'последний врачебный осмотр должен быть оказан в последний день лечения')
  endif
  k := 0
  for d := d1 to d2
    if is_work_day(d)
      ++k
    endif
  next
  if metap == 1 .and. k > 10
    aadd(ta,'Срок ДДС I этапа должен составлять не более 10 рабочих дней (у Вас '+lstr(k)+')')
  elseif metap == 2 .and. k > 45
    aadd(ta,'Срок ДДС I и II этапа должен составлять не более 45 рабочих дней (у Вас '+lstr(k)+')')
  endif
endif
if is_prof_PN //
  human_->profil := 151  // медицинским осмотрам профилактическим
  metap := 1
  m1mobilbr := 0
  if d1_year != d2_year
    aadd(ta,'Дата начала и окончания случая должны быть в одном году')
  endif
  if eq_any(human->ishod,301,302)
    metap := human->ishod-300
    license_for_dispans(2,d1,ta)
  else
    aadd(ta,'Профилактику несовершеннолетних надо вводить через специальный экран ввода')
  endif
  mperiod := ret_period_PN(mdate_r,d1,d2)
  if between(mperiod,1,31)
    np_oftal_2_85_21(mperiod,d2) // добавить или удалить офтальмолога в массив для несовершеннолетних для 12 месяцев
    read_arr_PN(human->kod)
    kol_d_otkaz := 0
    if valtype(arr_usl_otkaz) == "A"
      for j := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[j]
        if valtype(ar) == "A" .and. len(ar) > 9 .and. valtype(ar[5]) == "C" .and. ;
                                                     valtype(ar[10]) == "C" .and. ar[10] $ "io"
          lshifr := alltrim(ar[5])
          if ar[10] == "i" // исследования
            if (i := ascan(np_arr_issled, {|x| valtype(x[1]) == "C" .and. x[1] == lshifr})) > 0
              if is_issled_PN({lshifr,ar[6],ar[4],ar[2]},mperiod,ta,human->pol)
                ++kol_d_otkaz
              endif
            endif
          elseif (i := ascan(np_arr_osmotr, {|x| valtype(x[1]) == "C" .and. x[1] == lshifr})) > 0 // осмотры
            if is_osmotr_PN({lshifr,ar[6],ar[4],ar[2]},mperiod,ta,metap,human->pol)
              ++kol_d_otkaz
            endif
          endif
        endif
      next j
    endif
    is_1_den := is_last_den := .f. ; zs := kvp := 0 ; oth_usl := kod_zs := "" ; is_neonat := .f.
    for i := 1 to len(au_lu)
      if au_lu[i,3] == 0
        aadd(ta,'в услуге '+alltrim(au_lu[i,1])+' не проставлен профиль')
      endif
      if au_lu[i,4] == 0
        aadd(ta,'в услуге '+alltrim(au_lu[i,1])+' не проставлена спец-ть врача')
      endif
      if au_lu[i,2] > d2
        aadd(ta,'услуга '+au_lu[i,5]+'('+date_8(au_lu[i,2])+') не попадает в диапазон лечения')
      endif
      if is_issled_PN(au_lu[i],mperiod,ta,mpol)
        s := 'услуга '+au_lu[i,5]+'('+date_8(au_lu[i,2])+')'
        if mvozrast < 2
          if left(au_lu[i,5],5) == "4.26."
            is_neonat := .t.
          endif
          if au_lu[i,2] < addmonth(d1,-1)
            aadd(ta,s+' оказана более 1 месяца назад')
          endif
        else
          if au_lu[i,2] < addmonth(d1,-3)
            aadd(ta,s+' оказана более 3 месяцев назад')
          endif
        endif
        if d1 == au_lu[i,2]
          is_1_den := .t.
        endif
      else
        s := 'услуга '+au_lu[i,5]+'-'+inieditspr(A__MENUVERT,glob_V002,au_lu[i,3])+'('+date_8(au_lu[i,2])+')'
        if eq_any(au_lu[i,3],68,57) // педиатр (врач общей практики)
          if au_lu[i,2] < d1
            aadd(ta,'Дата осмотра педиатра не попадает в диапазон лечения')
          endif
        elseif is_1_etap_PN(au_lu[i],mperiod,metap) // если услуга из 1 этапа
          if mvozrast < 2
            if au_lu[i,2] < addmonth(d1,-1)
              aadd(ta,s+' оказана более 1 месяца назад')
            endif
          else
            if au_lu[i,2] < addmonth(d1,-3)
              aadd(ta,s+' оказана более 3 месяцев назад')
            endif
          endif
        elseif au_lu[i,2] < d1
          aadd(ta,s+' не попадает в диапазон лечения')
        endif
        if left(au_lu[i,1],5) == "72.2."
          ++zs
          kod_zs := alltrim(au_lu[i,1])
        elseif eq_any(au_lu[i,3],68,57) // педиатр (врач общей практики)
          ++kvp
          if d1 == au_lu[i,2]
            is_1_den := .t.
          endif
          if d2 == au_lu[i,2]
            is_last_den := .t.
          endif
        elseif is_osmotr_PN(au_lu[i],mperiod,ta,metap,mpol)
          if eq_any(left(au_lu[i,1],4),"2.3.","2.4.","2.85","2.91")
            ++kvp
          endif
          if d1 == au_lu[i,2]
            is_1_den := .t.
          endif
          if d2 == au_lu[i,2]
            is_last_den := .t.
          endif
        elseif !(metap == 2 .and. is_lab_usluga(au_lu[i,1]))
          oth_usl += alltrim(au_lu[i,1])+" "
        endif
      endif
    next
    if metap == 1 .and. zs == 1
      s := ret_shifr_zs_PN(mperiod)
      if !(kod_zs == s)
        aadd(ta,'в л/у услуга '+kod_zs+', а должна быть '+s+;
                ' для возраста '+lstr(mvozrast)+' '+s_let(mvozrast))
      endif
    elseif metap == 1 .and. zs > 1
      aadd(ta,'в листе учета более одной услуги "законченный случай"')
    elseif metap == 2 .and. zs > 0
      aadd(ta,'для двухэтапной профилактики несовершеннолетних не должно быть услуг "законченный случай"')
    endif
    if !empty(oth_usl)
      aadd(ta,'в листе учета ПН лишние услуги: '+oth_usl)
    endif
    if !is_1_den
      //aadd(ta,'первый врачебный осмотр должен быть оказан в первый день лечения')
    endif
    if !is_last_den
      aadd(ta,'последний врачебный осмотр должен быть оказан в последний день лечения')
    endif
    k := 0
    for d := d1 to d2
      if is_work_day(d)
        ++k
      endif
    next
    if metap == 1 .and. k > 20
      aadd(ta,'Срок ПН I этапа должен составлять 20 рабочих дней (у Вас '+lstr(k)+')')
    elseif metap == 2 .and. k > 45
      aadd(ta,'Срок ПН I и II этапа должен составлять 45 рабочих дней (у Вас '+lstr(k)+')')
    endif
    // проверим, выполнены обязательные услуги (и наоборот)
    ar := aclone(np_arr_1_etap[mperiod,5])
    for i := 1 to len(ar) // исследования
      lshifr := alltrim(ar[i])
      if ascan(au_lu, {|x| alltrim(x[1]) == lshifr}) > 0
        // услуга оказана
      elseif ascan(arr_usl_otkaz, {|x| valtype(x)=="A" .and. valtype(x[5])=="C" .and. alltrim(x[5])==lshifr}) > 0
        // услуга в отказах
      else
        s := ""
        if (j := ascan(np_arr_issled, {|x| x[1] == lshifr})) > 0
          s := np_arr_issled[j,3]
        endif
        aadd(ta,'некорректно записано исследование '+lshifr+' '+s+' (отредактируйте)')
      endif
    next
    ar := aclone(np_arr_1_etap[mperiod,4])
    for i := 1 to len(ar) // осмотры 1 -го этапа
      lshifr := alltrim(ar[i])
      if (j := ascan(np_arr_osmotr, {|x| x[1] == lshifr})) > 0
        fl := .f.
        if ascan(au_lu, {|x| alltrim(x[1]) == lshifr}) > 0
          fl := .t. // услуга оказана
        elseif ascan(arr_usl_otkaz, {|x| valtype(x)=="A" .and. valtype(x[5])=="C" .and. alltrim(x[5])==lshifr}) > 0
          fl := .t. // услуга в отказах
        elseif !empty(np_arr_osmotr[j,2]) .and. !(np_arr_osmotr[j,2] == human->pol)
          loop
        else
          for k := 1 to len(au_lu)
            // проверяем только нулевые услуги
            if eq_any(left(au_lu[k,1],4),"2.3.","2.4.") .and. au_lu[k,3] == np_arr_osmotr[j,4]
              fl := .t. // услуга оказана (нашли по профилю)
              exit
            endif
          next k
        endif
        if !fl
          aadd(ta,'некорректно записан врачебный осмотр 1-го этапа "'+np_arr_osmotr[j,3]+'" (отредактируйте)')
        endif
      endif
    next i
    if empty(ta) // если пока нет ошибок
      fl := .f.
      for i := 1 to len(au_lu)
        if eq_any(au_lu[i,3],68,57) ; // педиатр (врач общей практики)
                  .and. left(au_lu[i,1],4) == "2.3." // на 1-ом этапе
          fl := .t. ; exit
        endif
      next i
      if !fl
        aadd(ta,'некорректно записан врачебный осмотр педиатра на 1-ом этапе (отредактируйте)')
      endif
    endif
  else
    aadd(ta,"Не удалось определить возрастной период для профилактики несовершеннолетнего")
  endif
endif
if is_disp_DVN //
  m1mobilbr := 0
  human_->profil := 151  // медицинским осмотрам профилактическим
  ret_arr_vozrast_DVN(d2)
  ret_arrays_disp(is_disp_19)
  m1g_cit := m1veteran := m1dispans := 0
  if empty(sadiag1)
    Private file_form, diag1 := {}, len_diag := 0
    if (file_form := search_file("DISP_NAB"+sfrm)) == NIL
      aadd(ta,"Не обнаружен файл DISP_NAB"+sfrm)
    endif
    f2_vvod_disp_nabl("A00")
    sadiag1 := diag1
  endif
  for i := 1 to 5
    sk := lstr(i)
    pole_diag := "mdiag"+sk
    pole_1pervich := "m1pervich"+sk
    pole_1dispans := "m1dispans"+sk
    pole_dn_dispans := "mdndispans"+sk
    Private &pole_diag := space(6)
    Private &pole_1pervich := 0
    Private &pole_1dispans := 0
    Private &pole_dn_dispans := ctod("")
  next
  m1dopo_na := 0
  m1napr_v_mo := 0 // {{"-- нет --",0},{"в нашу МО",1},{"в иную МО",2}}, ;
  arr_mo_spec := {}
  m1napr_stac := 0 // {{"--- нет ---",0},{"в стационар",1},{"в дн. стац.",2}}, ;
  m1profil_stac := 0
  m1napr_reab := 0
  m1profil_kojki := 0
  is_disp_nabl := .f.
  arr_nazn := {}
  read_arr_DVN(human->kod)
  if m1dopo_na > 0
    aadd(arr_nazn,{3,{}}) ; j := len(arr_nazn)
    for i := 1 to 3
      if isbit(m1dopo_na,i)
        aadd(arr_nazn[j,2],i)
      endif
    next
  endif
  if between(m1napr_v_mo,1,2) .and. !empty(arr_mo_spec) // {{"-- нет --",0},{"в нашу МО",1},{"в иную МО",2}}, ;
    aadd(arr_nazn,{m1napr_v_mo,{}}) ; j := len(arr_nazn)
    for i := 1 to min(3,len(arr_mo_spec))
      aadd(arr_nazn[j,2],arr_mo_spec[i])
    next
  endif
  if human->OBRASHEN == '1'
    if ascan(arr_nazn,{|x| x[1] == 2 }) > 0 .or. ascan(arr_nazn,{|x| x[1] == 3 }) > 0
      aadd(ta,"не введено направление при подозрении на ЗНО")
    endif
  endif
  if between(m1napr_stac,1,2) .and. m1profil_stac > 0 // {{"--- нет ---",0},{"в стационар",1},{"в дн. стац.",2}}, ;
    aadd(arr_nazn,{iif(m1napr_stac==1,5,4),m1profil_stac})
  endif
  if m1napr_reab == 1 .and. m1profil_kojki > 0
    aadd(arr_nazn,{6,m1profil_kojki})
  endif
  for i := 1 to 5
    sk := lstr(i)
    pole_diag := "mdiag"+sk
    pole_1pervich := "m1pervich"+sk
    pole_1dispans := "m1dispans"+sk
    pole_dn_dispans := "mdndispans"+sk
    arr_diag := {alltrim(&pole_diag),&pole_1pervich,&pole_1dispans,&pole_dn_dispans}
    // действия при записи в лист учёта
    if arr_diag[2] == 0 // "ранее выявлено"
      arr_diag[2] := 2  // заменяем, как в листе учёта ОМС
    endif
    if arr_diag[3] > 0 // "дисп.наблюдение установлено" и "ранее выявлено"
      if arr_diag[2] == 2 // "ранее выявлено"
        arr_diag[3] := 1 // то "Состоит"
      else
        arr_diag[3] := 2 // то "Взят"
      endif
    endif
    // действия при записи в реестр
    s := 3 // не подлежит диспансерному наблюдению
    if arr_diag[2] == 1 // впервые
      if arr_diag[3] == 2
        s := 2 // взят на диспансерное наблюдение
      endif
    elseif arr_diag[2] == 2 // ранее
      if arr_diag[3] == 1
        s := 1 // состоит на диспансерном наблюдении
      elseif arr_diag[3] == 2
        s := 2 // взят на диспансерное наблюдение
      endif
    endif
    if !empty(arr_diag[1]) .and. ascan(sadiag1,arr_diag[1]) > 0
      if empty(arr_diag[4])
        if s == 2
          aadd(ta,'не введена дата следующего визита для '+arr_diag[1])
        endif
      elseif arr_diag[4] > d2
        if s == 1
          is_disp_nabl := .t.
        endif
      else
        aadd(ta,'некорректная дата следующего визита для '+arr_diag[1])
      endif
    endif
  next
  if d1_year != d2_year
    aadd(ta,'Дата начала и окончания случая должны быть в одном году')
  endif
  for i := 1 to len(au_lu_ne)
    s := alltrim(au_lu_ne[i,1])
    if !empty(au_lu_ne[i,2])
      s += "("+alltrim(au_lu_ne[i,2])+")"
    endif
    s += ' '+alltrim(au_lu_ne[i,3])
    aadd(ta,'неверная услуга "'+s+'" от '+date_8(au_lu_ne[i,4])+'г.')
  next
  metap := 3
  if between(human->ishod,201,205)
    metap := human->ishod-200
    license_for_dispans(1,d1,ta)
  else
    aadd(ta,'Диспансеризацию/профилактику взрослых надо вводить через специальный экран ввода')
  endif
  if m1veteran == 1
    if metap == 3
      aadd(ta,'Профилактику взрослых не проводят ветеранам ВОВ (блокадникам)')
    else
      mdvozrast := ret_vozr_DVN_veteran(mdvozrast,d2)
    endif
  endif
  is_prof_disp := .f.
  // если это профосмотр
  if metap == 3 .and. ascan(ret_arr_vozrast_DVN(d2),mdvozrast) > 0 // а возраст диспансеризации
    metap := 1 // превращаем в диспансеризацию
    is_prof_disp := .t.
  endif
  for i := 1 to len(a_disp)
    // {human->ishod-200,human->n_data,human->k_data,human_->RSLT_NEW}
    if overlap_diapazon(a_disp[i,2],a_disp[i,3],d1,d2)
      aadd(ta,'пересечение с '+iif(a_disp[i,1]==3,"профилактикой ","диспансеризацией ")+;
              date_8(a_disp[i,2])+"-"+date_8(a_disp[i,3]))
    endif
  next
  if metap == 2 .and. ascan(a_disp, {|x| x[1] == 1 }) == 0
    aadd(ta,'это II этап диспансеризации, но отсутствует случай I этапа диспансеризации')
  elseif metap == 5 .and. ascan(a_disp, {|x| x[1] == 4 }) == 0
    aadd(ta,'это II этап диспансеризации, но отсутствует случай I этапа диспансеризации раз в 2 года')
  endif
  // отметим обязательные услуги
  arr1 := array(count_dvn_arr_usl,5)    ; afillall(arr1,0)
  arr2 := array(count_dvn_arr_umolch,5) ; afillall(arr2,0)
  for i := 1 to count_dvn_arr_usl
    fl_ekg := .f. ; i_otkaz := 0
    if f_is_usl_oms_sluch_DVN(i,metap,iif(metap==3.and.!is_disp_19,mvozrast,mdvozrast),mpol,,@i_otkaz,@fl_ekg)
      arr1[i,2] := 1
      arr1[i,3] := i_otkaz
      arr1[i,5] := iif(fl_ekg, 1, 0) // 1 - необязательный возраст
    endif
  next
  for i := 1 to count_dvn_arr_umolch
    if f_is_umolch_sluch_DVN(i,metap,iif(metap==3.and.!is_disp_19,mvozrast,mdvozrast),mpol)
      arr2[i,2] := 1
    endif
  next
  // отметим выполненные услуги
  for j := 1 to len(au_lu)
    lshifr := alltrim(au_lu[j,1])
    fl := .t.
    if !is_disp_19 .and. ((lshifr == "2.3.3" .and. au_lu[j,3] == 3) .or.  ; // акушерскому делу
                          (lshifr == "2.3.1" .and. au_lu[j,3] == 136))  ; // акушерству и гинекологии
        .and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.1.12"})) > 0
      arr1[i,1] ++
      fl := .f.
    endif
    if fl
      for i := 1 to count_dvn_arr_umolch
        if arr2[i,1] == 0 .and. dvn_arr_umolch[i,2] == lshifr
          arr2[i,1] ++ ; fl := .f. ; exit
        endif
      next
    endif
    if fl
      for i := 1 to count_dvn_arr_usl
        if metap == 2 .and. valtype(dvn_arr_usl[i,2]) == "C" .and. dvn_arr_usl[i,2] == lshifr
          s := '"'+dvn_arr_usl[i,2]+' '+dvn_arr_usl[i,1]+'"'
          if valtype(dvn_arr_usl[i,3]) == "N"
            if dvn_arr_usl[i,3] != 2
              aadd(ta,'не надо выполнять, а выполнили '+s)
            endif
          else
            if ascan(dvn_arr_usl[i,3],2) == 0
              aadd(ta,'не надо выполнять, а выполнили '+s)
            endif
          endif
        endif
        if arr1[i,1] == 0
          if valtype(dvn_arr_usl[i,2]) == "C"
            if dvn_arr_usl[i,2] == "4.20.1"
              if lshifr == "4.20.1"
                m1g_cit := 1
              elseif lshifr == "4.20.2"
                m1g_cit := 2 ; fl := .f.
              endif
            endif
            if dvn_arr_usl[i,2] == lshifr
              fl := .f.
            endif
          endif
          if fl .and. len(dvn_arr_usl[i]) > 11 .and. valtype(dvn_arr_usl[i,12]) == "A"
            if ascan(dvn_arr_usl[i,12],{|x| x[1] == lshifr .and. x[2] == au_lu[j,3]}) > 0
              fl := .f.
            endif
          endif
          if !fl
            arr1[i,1] ++ ; exit
          endif
        endif
      next
    endif
    if fl .and. !is_disp_19 .and. ascan(dvn_700,{|x| x[2] == lshifr}) > 0
      fl := .f. // к нулевой услуге добавлена услуга с ценой на "700"
    endif
    if fl .and. !eq_any(left(lshifr,5),"70.3.","70.7.","72.1.","72.5.","72.6.","72.7.")
      aadd(ta,lshifr+' - некорректная настройка в справочнике услуг шифра ТФОМС')
    endif
  next j
  is_1_den := is_last_den := .f. ; zs := kvp := 0 ; oth_usl := ""
  mv := iif(metap == 3 .and. !is_disp_19, mvozrast, mdvozrast)
  kod_spec_ter := 0
  if eq_any(metap,1,4)
    for i := 1 to len(au_lu)
      if eq_any(au_lu[i,3],97,57,42) // профиль терапевт (врач общей практики)
        kod_spec_ter := au_lu[i,4]  // специальность терапевта (врача общей практики)
        exit
      endif
    next
  elseif eq_any(metap,2,5) // поверка на обязательное сочетание услуг второго этапа
    ar := array(len(dvn_2_etap),2) ; afillall(ar,0)
    for i := 1 to len(au_lu)
      lshifr := alltrim(au_lu[i,1])
      for j := 1 to len(dvn_2_etap)
        if ascan(dvn_2_etap[j,1],lshifr) > 0 .and. between(mdvozrast,dvn_2_etap[j,3],dvn_2_etap[j,4])
          ar[j,1] := 1
        elseif ascan(dvn_2_etap[j,2],lshifr) > 0 .and. between(mdvozrast,dvn_2_etap[j,3],dvn_2_etap[j,4])
          ar[j,2] := 1
        endif
      next
    next
    for j := 1 to len(dvn_2_etap)
      if empty(ar[j,1]) .and. !empty(ar[j,2])
        if len(dvn_2_etap[j,2]) == 1
          s := 'для услуги '+dvn_2_etap[j,2,1]
        else
          s := 'для услуг '+print_array(dvn_2_etap[j,2])
        endif
        s += ' обязательно наличие услуги '
        if len(dvn_2_etap[j,1]) == 1
          s += dvn_2_etap[j,1,1]
        else
          s += print_array(dvn_2_etap[j,1])
        endif
        s += " (в возрасте от "+lstr(dvn_2_etap[j,3])+" до "+lstr(dvn_2_etap[j,4])+" лет)"
        aadd(ta,s)
      //elseif !empty(ar[j,1]) .and. empty(ar[j,2])
        //aadd(ta,'для услуги '+print_array(dvn_2_etap[j,1])+' обязательно наличие  услуг '+print_array(dvn_2_etap[j,2]))
      endif
    next
  endif
  a_4_20_1 := {0,0}
  for i := 1 to len(au_lu)
    lshifr := alltrim(au_lu[i,1])
    do case
      case lshifr == "4.1.12" // Осмотр акушеркой, взятие мазка (соскоба)
        a_4_20_1[1] := 3
      case eq_any(lshifr,"4.20.1","4.20.2") // Иссл-е взятого цитологического материала
        a_4_20_1[2] := 3
        if lshifr == "4.20.2" .and. au_lu[i,7] < d1
          m1g_cit := 1
        endif
    endcase
  next
  // учёт и проверка отказов
  kol_d_usl := kol_d_otkaz := kol_n_date := kol_ob_otkaz := 0
  if valtype(arr_usl_otkaz) == "A"
    for j := 1 to len(arr_usl_otkaz)
      ar := arr_usl_otkaz[j]
      if valtype(ar) == "A" .and. len(ar) >= 10 .and. valtype(ar[5]) == "C"
        lshifr := alltrim(ar[5])
        for i := 1 to count_dvn_arr_usl
          if valtype(dvn_arr_usl[i,2]) == "C" .and. ;
            (dvn_arr_usl[i,2] == lshifr .or. (len(dvn_arr_usl[i]) > 11 .and. valtype(dvn_arr_usl[i,12]) == "A" ;
                                                               .and. ascan(dvn_arr_usl[i,12],{|x| x[1] == lshifr}) > 0))
            if valtype(ar[10]) == "N" .and. between(ar[10],1,2)
              ++kol_d_usl
              arr1[i,4] := ar[10] // 1-отказ, 2-невозможность
              if lshifr == "4.1.12" // Осмотр акушеркой, взятие мазка (соскоба)
                a_4_20_1[1] := ar[10]
              endif
              if ar[10] == 1
                ++kol_d_otkaz
                if is_disp_19 .and. eq_any(lshifr,"4.8.4","4.14.66","7.57.3","2.3.1","2.3.3","4.1.12","4.20.1","4.20.2")
                  ++kol_ob_otkaz // кол-во отказов от обязательных услуг
                endif
                // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
                is_usluga_dvn({lshifr,ar[9],ar[4],ar[2]},mv,ta,metap,mpol,kod_spec_ter)
              endif
            endif
          endif
        next i
      endif
    next j
  endif
  if kol_ob_otkaz > 0 .and. metap == 1 .and. !is_prof_disp
    aadd(ta,'некорректно записан случай профоосмотра в год диспансеризации- отредактируйте')
  endif
  if !eq_any(metap,2,5) // проверим, выполнены обязательные услуги (и наоборот)
    for i := 1 to count_dvn_arr_usl
      s := '"'+iif(valtype(dvn_arr_usl[i,2]) == "C", dvn_arr_usl[i,2]+' ', '')
      s += dvn_arr_usl[i,1]+'"'
      if arr1[i,2] == 0 // не надо выполнять
        if arr1[i,1] > 1
          aadd(ta,'не надо выполнять, а выполнили '+s)
        endif
      elseif arr1[i,2] == 1 // надо выполнять
        if arr1[i,1] == 0 .and. arr1[i,5] == 0 // ЭКГ + обязательный возраст
          if arr1[i,4] == 2 .and. arr1[i,3] < 2 // "невозможно", разрешён "отказ"
            aadd(ta,'НЕВЕРНО установлена "невозможность" оказания услуги '+s)
          elseif arr1[i,4] == 0 // не отказ
            fl := .t.
            if valtype(dvn_arr_usl[i,2]) == "C"
              if dvn_arr_usl[i,2] == "4.20.1" .and. a_4_20_1[1] < 3
                fl := .f.
              endif
            endif
            if fl
              aadd(ta,'не оказана услуга '+s)
            endif
          endif
        elseif arr1[i,1] > 1
          aadd(ta,'выполнили более одной услуги '+s)
        endif
      endif
    next
    for i := 1 to count_dvn_arr_umolch
      s := '"'+dvn_arr_umolch[i,2]+' '+dvn_arr_umolch[i,1]+'"'
      if arr2[i,2] == 0 // не надо выполнять
        if arr2[i,1] > 1
          aadd(ta,'не надо выполнять, а выполнили '+s)
        endif
      elseif arr2[i,2] == 1 // надо выполнять
        if empty(arr2[i,1])
          aadd(ta,'нет услуги '+s)
        elseif arr2[i,1] > 1
          aadd(ta,'более одной услуги '+s)
        endif
      endif
    next
  endif
  k700 := kkt := kzad := 0
  for i := 1 to len(au_lu)
    hu->(dbGoto(au_lu[i,9]))       // 9 - номер записи
    lshifr := alltrim(au_lu[i,1])
    if left(lshifr,4) == '2.3.' .and. !empty(au_lu[i,3])
      s := 'услуга '+au_lu[i,5]+'-'+inieditspr(A__MENUVERT,glob_V002,au_lu[i,3])+'('+date_8(au_lu[i,2])+')'
    else
      s := 'услуга '+au_lu[i,5]+'('+date_8(au_lu[i,2])+')'
    endif
    if au_lu[i,3] == 0
      aadd(ta,s+' - не проставлен профиль')
    endif
    if au_lu[i,4] == 0
      aadd(ta,s+' - не проставлена спец-ть врача')
    endif
    if au_lu[i,2] > d2
      aadd(ta,s+' не попадает в диапазон лечения')
    endif
    if is_usluga_dvn(au_lu[i],mv,ta,metap,mpol,kod_spec_ter)
      if metap == 1 .and. empty(hu->u_cena) .and. !eq_any(left(lshifr,5),"4.20.","2.90.")
        ++kol_d_usl
      elseif metap == 3 .and. !(lshifr == "56.1.14")
        ++kol_d_usl
      endif
      if d1 == au_lu[i,2]
        is_1_den := .t.
      endif
      if metap == 2
        if eq_any(lshifr,"7.2.701","7.2.702","7.2.703","7.2.704","7.2.705")
          ++kkt
        endif
        if eq_any(lshifr,"10.6.710","10.4.701")
          ++kzad
        endif
      endif
      if !eq_any(metap,2,5) .and. au_lu[i,2] < d1 .and. !eq_any(lshifr,"4.20.1","4.20.2")
        if is_disp_19
          if year(au_lu[i,2]) < year(d1) // кол-во услуг без отказа выполнены ранее
            ++kol_n_date                 // начала проведения диспансеризации и не принадлежат текущему календарному году
          endif
        else
          ++kol_n_date // учтена ранее оказанная услуга
        endif
      endif
      if eq_any(metap,2,5) .and. au_lu[i,2] < d1
        aadd(ta,s+' не попадает в диапазон лечения')
      elseif left(lshifr,2) == "2." .and. eq_any(au_lu[i,3],97,57,42)
        if au_lu[i,2] != d2
          aadd(ta,s+' - терапевт должен проводить осмотр последним')
        endif
      elseif alltrim(au_lu[i,1]) == "7.61.3" .and. !is_disp_19
        if eq_any(year(au_lu[i,2]),d1_year,d1_year-1)
          // в течение предшествующего календарного года либо года проведения диспансеризации проводилась флюорография
        else
          aadd(ta,'Флюорография оказана в позапрошлом календарном году')
        endif
      else
        if au_lu[i,2] < addmonth(d1,-12)
          aadd(ta,s+' оказана более 1 года назад')
        endif
      endif
      if left(lshifr,5) == "2.84."
        ++kvp
      elseif eq_any(left(lshifr,4),"2.3.","2.90")
        ++kvp
      endif
      if d1 == au_lu[i,2]
        is_1_den := .t.
      endif
      if d2 == au_lu[i,2]
        is_last_den := .t.
      endif
    elseif ascan(dvn_700,{|x| x[2] == lshifr}) > 0
      ++k700 // к нулевой услуге добавлена услуга с ценой на "700"
    elseif eq_any(left(lshifr,5),"70.3.","70.7.","72.1.","72.5.","72.6.","72.7.")
      ++zs
      if is_prof_disp
        s := ret_shifr_zs_DVN(3,mv,mpol,d2)
      else
        s := ret_shifr_zs_DVN(metap,mv,mpol,d2)
      endif
      if !(lshifr == s)
        aadd(ta,'в л/у услуга '+lshifr+', а должна быть '+s+' для возраста '+lstr(mv)+' '+s_let(mv)+'. Отредактируйте!')
      endif
    else
      oth_usl += lshifr+" "
    endif
  next
  if kkt > 1
    aadd(ta,'разрешается выполнить только одну процедуру рентгенографиии или КТ органов грудной клетки')
  endif
  if kzad > 1
    aadd(ta,'не разрешается совместно применять ректосигмоколоноскопию и ректороманоскопию')
  endif
  if ascan(ret_arr_vozrast_DVN(d2),mdvozrast) > 0
    if metap > 2
      aadd(ta,'в '+lstr(mdvozrast)+s_let(mdvozrast)+' проводится диспансеризация, а проведена профилактика')
    endif
  else
    if eq_any(metap,1,2)
      aadd(ta,'в '+lstr(mvozrast)+s_let(mvozrast)+' проводится профилактика, а проведена диспансеризация')
    endif
  endif
  do case
    case metap == 1 .or. (metap == 3 .and. is_disp_19)
      if zs > 1
        aadd(ta,'в листе учета более одной услуги "законченный случай"')
      elseif emptyall(zs,k700) .and. !is_disp_19
        aadd(ta,'в листе нет услуг с ценой')
      endif
      if (i := ascan(dvn_85, {|x| x[1] == kol_d_usl })) > 0
        if (k := dvn_85[i,1] - dvn_85[i,2]) < kol_d_otkaz
          aadd(ta,'отказы пациента составляют '+lstr(kol_d_otkaz/kol_d_usl*100,5,0)+'% (должно быть не более 15%)')
          aadd(ta,'отказов-'+lstr(kol_d_otkaz)+', всего учитываемых услуг-'+lstr(kol_d_usl))
        elseif kol_n_date+kol_d_otkaz <= k // отказы + ранее оказано менее 15%
          if zs == 0 .or. k700 > 0
            aadd(ta,'в листе учета должна быть услуга "законченный случай" - отредактируйте')
          endif
        elseif !is_disp_19
          if zs > 0 .or. empty(k700)
            aadd(ta,'в листе учета не должно быть услуги "законченный случай" - отредактируйте')
          endif
        endif
      else
        aadd(ta,'слишком много отказов-'+lstr(kol_d_otkaz)+' услуг-'+lstr(kol_d_usl))
      endif
    case metap == 4
      if zs > 1
        aadd(ta,'в листе учета более одной услуги "законченный случай"')
      elseif emptyall(zs,k700)
        aadd(ta,'в листе учета нет услуг с ценой')
      endif
    case eq_any(metap,2,5)
      if zs > 0
        aadd(ta,'для II этапа ДВН не должно быть услуг "законченный случай"')
      endif
    case metap == 3 .and.  !is_disp_19
      if zs > 1
        aadd(ta,'в листе учета более одной услуги "законченный случай"')
      endif
      if (i := ascan(prof_vn_85, {|x| x[1] == kol_d_usl })) > 0
        if prof_vn_85[i,1] - prof_vn_85[i,2] < kol_d_otkaz
          aadd(ta,'отказы пациента составляют '+lstr(kol_d_otkaz/kol_d_usl*100,5,0)+'% (должно быть не более 15%)')
          aadd(ta,'отказов-'+lstr(kol_d_otkaz)+', всего учитываемых услуг-'+lstr(kol_d_usl))
        endif
      else
        aadd(ta,'слишком много отказов-'+lstr(kol_d_otkaz))
      endif
  endcase
  if !empty(oth_usl)
    aadd(ta,'в листе учета ДВН лишние услуги: '+oth_usl)
  endif
  if !is_1_den
    //aadd(ta,'первый врачебный осмотр должен быть оказан в первый день лечения')
  endif
  if !is_last_den
    aadd(ta,'последний врачебный осмотр должен быть оказан в последний день лечения')
  endif
  if metap != 3 .and. eq_any(human_->RSLT_NEW,317,318,355,356)
    adiag_talon := array(16)
    for i := 1 to 16
      adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
    next
    am := {}
    for i := 1 to len(mdiagnoz)
      if !empty(mdiagnoz[i]) .and. eq_any(adiag_talon[i*2],1,2)
        aadd(am,mdiagnoz[i]) // массив диагнозов с диспансеризацией
      endif
    next
    do case
      case human_->RSLT_NEW == 317 // {"Проведена диспансеризация - присвоена I группа здоровья"   ,1,317}
        if !empty(am)
          aadd(ta,'для I группы здоровья не должно быть установления диспансерного учёта '+print_array(am))
        endif
      case human_->RSLT_NEW == 318 // {"Проведена диспансеризация - присвоена II группа здоровья"  ,2,318}
        fl := .f.
        for i := 1 to len(am)
          if left(am[i],3) == "E78"
            fl := .t.
          else
            aadd(ta,'для II группы здоровья диспансерный учёт может быть установлен только для гиперхолестеринемии, а не для '+am[i])
          endif
        next
        if fl .and. m1dispans != 3 // {"участковым терапевтом",3}
          aadd(ta,'для II группы здоровья "Диспансерное наблюдение установлено" может быть только "участковым терапевтом"')
        endif
      case human_->RSLT_NEW == 355 // {"Проведена диспансеризация - присвоена IIIа группа здоровья",3,355}
        if empty(am)
          aadd(ta,'для IIIа группы здоровья обязательно должен быть установлен диспансерный учёт')
        endif
      case human_->RSLT_NEW == 356 // {"Проведена диспансеризация - присвоена IIIб группа здоровья",4,356}
        if empty(am)
          aadd(ta,'для IIIб группы здоровья обязательно должен быть установлен диспансерный учёт')
        endif
    endcase
  endif
endif
if is_pren_diagn //
  human_->PROFIL := 106 // ультразвуковой диагностике
  if human->n_data != human->k_data
    aadd(ta,'Дата окончания лечения должна совпадать с датой начала лечения')
  endif
  if human->ishod != 99
    aadd(ta,'Пренатальная диагностика вводится через специальный экран ввода')
  endif
  k1 := k2 := 0 ; oth_usl := ""
  for i := 1 to len(au_lu)
    if eq_any(alltrim(au_lu[i,1]),"2.79.51","8.30.3")
      k1 += au_lu[i,6]
    elseif alltrim(au_lu[i,1]) == "4.26.6"
      k1 += au_lu[i,6]
    elseif alltrim(au_lu[i,1]) == "2.5.1"
      k2 += au_lu[i,6]
    else
      oth_usl += alltrim(au_lu[i,1])+" "
    endif
  next
  if k1 != 3
    aadd(ta,'в листе учета неверное количество обязательных услуг')
  endif
  if k2 > 1
    aadd(ta,'в листе учета должно быть не более одной услуги 2.5.1')
  endif
  if !empty(oth_usl)
    aadd(ta,'в листе учета пренатальной диагностики лишние услуги: '+oth_usl)
  endif
endif
if human_->USL_OK == 4 .and. !(is_71_1 .or. is_71_2 .or. is_71_3)
  aadd(ta,'для условия "Скорая помощь" не введены услуги СМП')
endif
if !empty(u_1_stom)
  // просмотр других случаев данного больного
  select HUMAN
  set order to 2
  find (str(glob_kartotek,7))
  do while human->kod_k == glob_kartotek .and. !eof()
    if (fl := (d2_year==year(human->k_data) .and. rec_human!=human->(recno())))
      //
    endif
    if fl .and. human->schet > 0 .and. eq_any(human_->oplata,2,9)
      fl := .f. // лист учёта снят по акту или выставлен повторно
    endif
    if fl .and. m1novor != human_->NOVOR
      fl := .f. // лист учёта на новорожденного (или наоборот)
    endif
    if fl .and. human_->idsp == 4 // лечебно-диагностическая процедура
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          if f_is_1_stom(lshifr)
            aadd(ta,'оказана услуга первичного стоматологического приёма '+u_1_stom+',')
            aadd(ta,' а в случае '+date_8(human->n_data)+'-'+date_8(human->k_data)+' уже была оказана услуга '+lshifr)
          endif
        endif
        select HU
        skip
      enddo
    endif
    select HUMAN
    skip
  enddo
  select HUMAN
  set order to 1
  human->(dbGoto(rec_human))
endif
if human_->oplata == 2
  aadd(ta,'вернулся из ТФОМС с ошибкой и ещё не отредактирован')
endif
//if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN
  //arr_unit := {144} // "комплексное посещение при диспансеризации"
//endif
if len(arr_unit) > 1
  if select("MOUNIT") == 0
    R_Use(dir_exe+"_mo9unit",cur_dir+"_mo9unit","MOUNIT")
  endif
  s := "совокупность услуг должна быть из одной учётной единицы объёма, а в данном случае: "
  select MOUNIT
  for i := 1 to len(arr_unit)
    find (str(arr_unit[i],3))
    if found()
      s += alltrim(mounit->name)+", "
    endif
  next
  aadd(ta,left(s,len(s)-2))
endif
if fl_view .and. !is_s_dializ .and. !is_dializ .and. !is_perito .and. len(a_rec_ffoms) > 0 // повтор диагноза
  ltip := 0 ; s := ""
  i := 1
  asort(a_rec_ffoms,,,{|x,y| x[3] < y[3] })
  if gusl_ok == 3     // поликлиника
    if is_2_78
      ltip := 1
    elseif is_2_80
      ltip := 2
    elseif is_2_88
      ltip := 3
    elseif is_2_89
      ltip := 4
    endif
    if ltip == 0
      i := 0
    else
      fl := .f.
      for i := 1 to len(a_rec_ffoms)
        select HU
        find (str(a_rec_ffoms[i,1],7))
        do while hu->kod == a_rec_ffoms[i,1] .and. !eof()
          lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
            lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
            left_lshifr_5 := left(lshifr,5)
            if left_lshifr_5 == "2.78."
              if !between_shifr(lshifr,"2.78.54","2.78.60")
                a_rec_ffoms[i,2] := 1
                s := AfterAtNum(".",lshifr)
                fl := .t.
              endif
            elseif left_lshifr_5 == "2.80."
              if !between_shifr(lshifr,"2.80.34","2.80.38")
                if ltip == 2 // если прошлое и новое лечение "2.80."
                  a_rec_ffoms[i,2] := 2
                  s := AfterAtNum(".",lshifr)
                  fl := .t.
                endif
              endif
            elseif left_lshifr_5 == "2.88."
              if !between_shifr(lshifr,"2.88.46","2.88.51")
                a_rec_ffoms[i,2] := 3
                s := AfterAtNum(".",lshifr)
                fl := .t.
              endif
            elseif left_lshifr_5 == "2.89."
              a_rec_ffoms[i,2] := 4
              s := AfterAtNum(".",lshifr)
              fl := .t.
            endif
          endif
          if fl ; exit ; endif
          select HU
          skip
        enddo
        if fl ; exit ; endif
      next
      if !fl
        i := 0
      endif
    endif
  endif
  if i > 0
    select D_SROK
    append blank
    d_srok->kod   := human->kod
    d_srok->tip   := ltip
    d_srok->tips  := d_sroks
    d_srok->otd   := human->otd
    d_srok->kod1  := a_rec_ffoms[i,1]
    d_srok->tip1  := a_rec_ffoms[i,2]
    d_srok->tip1s := s
    d_srok->dni   := a_rec_ffoms[i,3]
  endif
endif
if len(ta) > 0
  _ocenka := 0
  verify_FF(80-len(ta)-3,.t.,80)
  add_string("")
  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  add_string(alltrim(human->fio)+" "+alltrim(human->kod_diag)+" "+;
             date_8(human->n_data)+"-"+date_8(human->k_data)+;
             " ("+count_ymd(human->date_r,human->n_data)+")")
  Ins_Array(ta,1,alltrim(uch->name)+'/'+alltrim(otd->name)+'/профиль по "'+;
                 inieditspr(A__MENUVERT, glob_V002, human_->profil)+'"')
  if human->cena_1 == 0 ; // если цена нулевая
      .and. eq_any(human->ishod,201,202) // диспансеризация взрослого населения
    asize(ta,1) // чтобы не выводить бессмысленные строки
    aadd(ta,"не определена сумма случая - отредактируйте")
  endif
  for i := 1 to len(ta)
    for j := 1 to perenos(t_arr,ta[i],78)
      if j == 1
        add_string(iif(i==1," ", "- ")+t_arr[j])
      else
        add_string(padl(alltrim(t_arr[j]),80))
      endif
    next
  next
else
  if is_disp_DDS .or. is_disp_DVN3 .or. is_prof_PN
    mpztip := 72 // {72,260,"комплексное посещение при диспансеризации","ПосДиспанс.","",""},; //
    mpzkol := 1
  elseif is_disp_DVN .and. eq_any(metap,1,4)
    mpztip := 73 // {73,261,"комплексное посещение при ДВН 1 этап","ДВН 1","",""},; //
    mpzkol := 1
  elseif is_disp_DVN .and. eq_any(metap,2,5)
    mpztip := 74 // {74,262,"комплексное посещение при ДВН 2 этап","ДВН 2","",""},; //
    mpzkol := 1
  endif
  if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
    mpzkol := len(au_lu) // кол-во анализов
  endif
  if len(arr_unit) == 1
    if select("MOUNIT") == 0
      R_Use(dir_exe+"_mo9unit",cur_dir+"_mo9unit","MOUNIT")
    endif
    select MOUNIT
    find (str(arr_unit[1],3))
    if found() .and. mounit->pz > 0
      mpztip := mounit->pz
    endif
  endif
  human_->POVOD := mpovod
  human_->PZTIP := mpztip
  human_->PZKOL := mpzkol
endif
if !valid_GUID(human_->ID_PAC)
  human_->ID_PAC := mo_guid(1,human_->(recno()))
endif
if !valid_GUID(human_->ID_C)
  human_->ID_C := mo_guid(2,human_->(recno()))
endif
human_->ST_VERIFY := _ocenka // проверен
if fl_view
  //dbUnLockAll()
endif
return (_ocenka >= 5)

***** 04.03.19
Function f_create_diag_srok()
dbcreate(cur_dir+"tmp_d_srok",{{"kod","N",7,0},;
                               {"tip","N",1,0},;
                               {"tips","C",3,0},;
                               {"otd","N",3,0},;
                               {"kod1","N",7,0},;
                               {"tip1","N",1,0},;
                               {"tip1s","C",3,0},;
                               {"dni","N",2,0}})
use (cur_dir+"tmp_d_srok") new alias D_SROK
return NIL

***** 14.02.19
Function verify_OMS(arr_m,fl_view)
Local ii := 0, iprov := 0, inprov := 0, ko := 2, fl, name_file := "err_sl"+stxt,;
      name_file2, name_file3, kr_unlock, i,;
      mas_pmt := {"Список обнаруженных ошибок в результате проверки"}, mas_file := {}
aadd(mas_file,name_file)
DEFAULT arr_m TO year_month(T_ROW,T_COL+5,,3), fl_view TO .t.
if arr_m == NIL
  return NIL
endif
if fl_view .and. (ko := popup_prompt(T_ROW,T_COL+5,1,;
                                     {"Проверять ~всех пациентов",;
                                      "Не проверять вернувшихся из ТФОМС с ~ошибкой"})) == 0
  return NIL
endif
kr_unlock := iif(fl_view,50,1000)
WaitStatus("Начало проверки...")
fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("Список обнаруженных ошибок",80))
add_string(center("по дате окончания лечения "+arr_m[4],80))
add_string("")
if !fl_view
  Use (cur_dir+"tmp") new
  use (cur_dir+"tmpb") index (cur_dir+"tmpb") new
endif
dbcreate(cur_dir+"tmp_no",{{"kod","N",7,0},;
                           {"tip","N",1,0},;
                           {"komu","N",1,0},;
                           {"str_crb","N",2,0}})
use (cur_dir+"tmp_no") new
f_create_diag_srok()
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
G_Use(dir_server+"human",dir_server+"humand","HUMAN")
dbseek(dtos(arr_m[5]),.t.)
index on upper(fio)+str(kod_k,7) to (cur_dir+"tmp_hfio") ;
      while human->k_data <= arr_m[6] .and. !eof() ;
      for tip_h == B_STANDART .and. empty(schet) .and. !empty(k_data)
set index to (dir_server+"humans"),(dir_server+"humankk"),(dir_server+"humand"),(cur_dir+"tmp_hfio")
set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
set order to 4
go top
do while !eof()
  if emptyall(iprov,inprov)
    UpdateStatus()
  endif
  if empty(human_->reestr)
    ++ii
    if (fl := (human->cena_1 == 0)) // если цена нулевая
      if is_smp(human_->USL_OK,human_->PROFIL)  // скорая помощь
        fl = .f.
      elseif eq_any(human->ishod,201,202,204) // диспансеризация взрослого населения
        fl = .f.
      endif
    endif
    if empty(int(val(human_->smo))) // нет СМО
      fl := .t.
    endif
    if fl // прочие счета
      select TMP_NO
      append blank
      tmp_no->kod  := human->kod
      tmp_no->tip  := iif(human->cena_1 == 0, 1, 2)
      tmp_no->komu := human->komu
      tmp_no->str_crb := human->str_crb
    elseif ko == 2 .and. human_->oplata == 2 .and. human_->ST_VERIFY < 5
      // не проверять вернувшихся из ТФОМС с ошибкой
    else
      if arr_m[1] > 2018
        fl := verify_1_sluch(fl_view)
      else
        fl := verify_1_sluch_18(fl_view)
      endif
      if fl .and. !between(human->ishod,201,205)
        ++iprov
        if !fl_view .and. human->ishod != 88 //  // это не 1-ый л/у в двойном случае
          select TMPB
          find (str(human->kod,7))
          if !found()
            append blank
            tmpb->kod_human := human->kod
            tmpb->n_data := human->n_data
            tmpb->k_data := human->k_data
            tmpb->cena_1 := human->cena_1
            tmpb->PZKOL := human_->pzkol
            tmpb->ishod := human->ishod
            tmpb->plus := .t.
            tmpb->kod_tmp := 1
            tmpb->plus := .t.
            if arr_m[1] > 2016
              if between(human->ishod,301,305) .or. between(human->ishod,201,205) .or. between(human->ishod,101,102)
                tmpb->tip := 2
                kol_2r++
              else
                tmpb->tip := 1
                kol_1r++
              endif
            endif
          endif
          if iprov >= max_rec_reestr // если число проверенных без ошибок достигло максимума,
            exit                     // остальных не проверяем, начинаем составление реестра
          endif
        endif
      else
        ++inprov
      endif
    endif
    @ maxrow(),50 say padl("всего: "+lstr(iprov+inprov)+", ошибок: "+lstr(inprov),30) color cColorSt2Msg
  endif
  if ii % kr_unlock == 0
    dbUnlockAll()
    dbCommitAll()
  endif
  select HUMAN
  set order to 4  //
  skip
enddo
dbUnlockAll()
dbCommitAll()
if inprov == 0
  if iprov > 0
    add_string("Проверено случаев - "+lstr(iprov)+". Ошибок не обнаружено.")
  else
    add_string("Нечего проверять!")
  endif
endif
fclose(fp)
if !fl_view
  select HUMAN
  set index to
  G_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
  /*
  // сначала проверяем случаи, которые оба закончились в отчётном месяце
  select TMPB
  index on str(kod_human,7) to (cur_dir+"tmpb") for ishod == 88  // 1-ый лист учёта в двойном случае
  go top
  do while !eof()
    select HUMAN_3
    find (str(tmpb->kod_human,7))
    if found()
      select HUMAN
      goto (tmpb->kod_human)
      ln_data := human->n_data
      lk_data := human->k_data
      ldiag := human->kod_diag
      lcena := human->cena_1
      pz := human_->PZKOL
      select HUMAN
      goto (human_3->kod2)
      if human->k_data <= arr_m[6] ; // если 2-ой л/у также заканчивается в текущем месяце
                 .and. human_->ST_VERIFY >= 5 // если 2-ой л/у также прошёл проверку
        lk_data := human->k_data
        lcena += human->cena_1
        pz += human_->PZKOL
        select HUMAN_3
        G_RLock(forever)
        human_3->N_DATA    := ln_data
        human_3->K_DATA    := lk_data
        human_3->CENA_1    := lcena
        human_3->RSLT_NEW  := human_->RSLT_NEW
        human_3->ISHOD_NEW := human_->ISHOD_NEW
        human_3->VNR1      := human_2->VNR1
        human_3->VNR2      := human_2->VNR2
        human_3->VNR3      := human_2->VNR3
        human_3->PZKOL     := pz
        human_3->ST_VERIFY := 5
        tmpb->n_data := ln_data
        tmpb->k_data := lk_data
        tmpb->cena_1 := lcena
        tmpb->PZKOL := pz
      else
        tmpb->tip := 0 //p_tip_reestr
        kol_1r--
      endif
    else
      tmpb->tip := 0 //p_tip_reestr
      kol_1r--
    endif
    select TMPB
    skip
  enddo*/
  // проверяем случаи, где 2-ой случай закончился в текущем отчётном месяце, а 1-ый - неважно
  select HUMAN_3
  set order to 2 // встать на индекс по 2-му случаю
  select TMPB
  index on str(kod_human,7) to (cur_dir+"tmpb") for ishod == 89  // 2-ой лист учёта в двойном случае
  go top
  do while !eof()
    select HUMAN_3
    find (str(tmpb->kod_human,7))
    if found()
      select HUMAN
      goto (tmpb->kod_human)  // 2-ой лист учёта в двойном случае
      ln_data := human->n_data
      lk_data := human->k_data
      ldiag := human->kod_diag
      lcena := human->cena_1
      pz := human_->PZKOL
      select HUMAN
      goto (human_3->kod)
      if human_->ST_VERIFY >= 5 // если 1-ый л/у также прошёл проверку
        ln_data := human->n_data
        lcena += human->cena_1
        pz += human_->PZKOL
        select HUMAN_3
        G_RLock(forever)
        human_3->N_DATA    := ln_data
        human_3->K_DATA    := lk_data
        human_3->CENA_1    := lcena
        select HUMAN
        goto (human_3->kod2)  // снова встать на 2-ой случай, чтобы взять исход, результат, ...
        human_3->RSLT_NEW  := human_->RSLT_NEW
        human_3->ISHOD_NEW := human_->ISHOD_NEW
        human_3->VNR1      := human_2->VNR1
        human_3->VNR2      := human_2->VNR2
        human_3->VNR3      := human_2->VNR3
        human_3->PZKOL     := pz
        human_3->ST_VERIFY := 5
        tmpb->n_data := ln_data
        tmpb->k_data := lk_data
        tmpb->cena_1 := lcena
        tmpb->PZKOL := pz
      else
        tmpb->tip := 0 //p_tip_reestr
        kol_1r--
      endif
    else
      tmpb->tip := 0 //p_tip_reestr
      kol_1r--
    endif
    select TMPB
    skip
  enddo
endif
if fl_view .and. d_srok->(lastrec()) > 0
  name_file2 := "err_sl2"+stxt
  delete file (name_file2)
  aadd(mas_pmt,"Случаи повторных обращений по поводу одного заболевания")
  aadd(mas_file,name_file2)
  mywait()
  delFRfiles()
  adbf := {{"name","C",130,0},;
           {"name1","C",150,0},;
           {"period","C",150,0}}
  dbcreate(fr_titl, adbf)
  use (fr_titl) new alias FRT
  append blank
  frt->name := glob_mo[_MO_SHORT_NAME]
  frt->name1 := "Список случаев повторных обращений по поводу одного и того же заболевания"
  frt->period := arr_m[4]
  adbf := {{"fio","C",100,0},;
           {"diag","C",5,0},;
           {"diag1","C",5,0},;
           {"srok","C",30,0},;
           {"srok1","C",30,0},;
           {"tip","C",12,0},;
           {"tip1","C",12,0},;
           {"otd","C",200,0},;
           {"otd1","C",200,0},;
           {"vrach","C",100,0},;
           {"vrach1","C",100,0}}
  dbcreate(fr_data,adbf)
  use (fr_data) new alias FRD
  am := {"78","80","88","89"}
  select HUMAN
  set index to
  select D_SROK
  go top
  do while !eof()
    select HUMAN
    goto (d_srok->kod)
    select FRD
    append blank
    frd->fio := alltrim(human->fio)+" д.р."+full_date(human->date_r)+" (повтор через "+lstr(d_srok->dni)+" дн.)"
    frd->diag := human->kod_diag
    frd->srok := full_date(human->n_data)+" - "+full_date(human->k_data)
    if d_srok->tip > 0
      frd->tip := "( 2."+am[d_srok->tip]+"."+d_srok->tips+" )"
    elseif human_->usl_ok == 1
      frd->tip := "( стац. )"
    elseif human_->usl_ok == 2
      frd->tip := "( дн.ст. )"
    elseif human_->usl_ok == 4
      frd->tip := "( скорая )"
    endif
    uch->(dbGoto(human->LPU))
    otd->(dbGoto(human->OTD))
    frd->otd := alltrim(uch->name)+'/ '+alltrim(otd->name)+'/ профиль по "'+;
                inieditspr(A__MENUVERT, glob_V002, human_->profil)+'"'
    pers->(dbGoto(human_->VRACH))
    frd->vrach := "[ "+lstr(pers->tab_nom)+" ] "+pers->fio
    //
    select HUMAN
    goto (d_srok->kod1)
    frd->diag1 := human->kod_diag
    frd->srok1 := full_date(human->n_data)+" - "+full_date(human->k_data)
    if d_srok->tip1 > 0
      frd->tip1 := "( 2."+am[d_srok->tip1]+"."+d_srok->tip1s+" )"
    elseif human_->usl_ok == 1
      frd->tip1 := "( стац. )"
    elseif human_->usl_ok == 2
      frd->tip1 := "( дн.ст. )"
    elseif human_->usl_ok == 4
      frd->tip1 := "( скорая )"
    endif
    uch->(dbGoto(human->LPU))
    otd->(dbGoto(human->OTD))
    frd->otd1 := alltrim(uch->name)+'/ '+alltrim(otd->name)+'/ профиль по "'+;
                 inieditspr(A__MENUVERT, glob_V002, human_->profil)+'"'
    pers->(dbGoto(human_->VRACH))
    frd->vrach1 := "[ "+lstr(pers->tab_nom)+" ] "+pers->fio
    select D_SROK
    skip
  enddo
endif
if fl_view .and. tmp_no->(lastrec()) > 0
  name_file3 := "err_sl3"+stxt
  aadd(mas_pmt,"Список листов учёта, которые не проверялись")
  aadd(mas_file,name_file3)
  fp := fcreate(name_file3) ; n_list := 1 ; tek_stroke := 0
  select HUMAN
  set index to
  add_string("")
  add_string(center("Список листов учёта, которые не проверялись",80))
  R_Use(dir_server+"str_komp",,"STR")
  R_Use(dir_server+"komitet",,"KOM")
  select TMP_NO
  set relation to kod into HUMAN
  index on str(tip,1)+str(komu,1)+str(str_crb,2)+upper(human->fio) to (cur_dir+"tmp_no")
  old_tip := old_komu := old_str_crb := -1
  go top
  do while !eof()
    verify_FF(77,.t.,80)
    add_string("")
    if old_tip != tmp_no->tip
      old_tip := tmp_no->tip
      if tmp_no->tip == 1
        add_string(padc("Нулевая цена",80,"-"))
      endif
    endif
    if old_komu != tmp_no->komu
      old_komu := tmp_no->komu
      if tmp_no->tip == 2 .and. tmp_no->komu == 0
        add_string(padc("Пустая СМО",80,"-"))
      endif
    endif
    if !(old_komu == tmp_no->komu .and. old_str_crb == tmp_no->str_crb)
      old_komu := tmp_no->komu ; old_str_crb := tmp_no->str_crb
      do case
        case tmp_no->komu == 1
          str->(dbGoto(tmp_no->str_crb))
          add_string(padc("Прочая компания: "+alltrim(str->name),80,"-"))
        case tmp_no->komu == 3
          kom->(dbGoto(tmp_no->str_crb))
          add_string(padc("Комитет/МО: "+alltrim(kom->name),80,"-"))
        case tmp_no->komu == 5
          add_string(padc("Личный счёт",80,"-"))
      endcase
    endif
    uch->(dbGoto(human->LPU))
    otd->(dbGoto(human->OTD))
    add_string(alltrim(human->fio)+" "+date_8(human->n_data)+"-"+date_8(human->k_data))
    add_string(" "+alltrim(uch->name)+"/"+alltrim(otd->name))
    select TMP_NO
    skip
  enddo
  fclose(fp)
endif
close databases
if fl_view
  ClrLine(maxrow(),color0)
  if len(mas_pmt) == 1
    viewtext(name_file,,,,.t.,,,5)
  else
    i := 1
    keyboard chr(K_ENTER)
    do while i > 0
      if (i := popup_prompt(T_ROW,T_COL+5,i,mas_pmt,mas_pmt)) == 0
        if !f_Esc_Enter("выхода из просмотра")
          i := 1
        endif
      elseif hb_fileExists(mas_file[i])
        viewtext(mas_file[i],,,,.t.,,,5)
      else
        call_fr("mo_d_srok")
      endif
    enddo
  endif
endif
return NIL

***** 04.02.19
Function create_reestr()
Local buf := save_maxrow(), i, j, k := 0, k1 := 0, arr, bSaveHandler, fl, rec, pole, arr_m
if tip_polzovat != 0
  return func_error(4,err_admin)
endif
if find_unfinished_reestr_sp_tk()
  return func_error(4,"Попытайтесь снова")
endif
if (arr_m := year_month(T_ROW,T_COL+5,,3)) == NIL
  return NIL
endif
if !myFileDeleted(cur_dir+"tmpb"+sdbf)
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp"+sdbf)
  return NIL
endif
arr := {"Предупреждение!",;
        "",;
        "Во время составления реестра",;
        "никто не должен работать в задаче ОМС"}
n_message(arr,,"GR+/R","W+/R",,,"G+/R")
Private pkol := 0, psumma := 0, ;
        CODE_LPU := glob_mo[_MO_KOD_TFOMS], ;
        CODE_MO  := glob_mo[_MO_KOD_FFOMS]
stat_msg("Подождите, работаю...")
dbcreate(cur_dir+"tmpb",{;
    {"kod_tmp"  ,"N", 6,0},;
    {"kod_human","N", 7,0},;
    {"n_data"   ,"D", 8,0},;
    {"k_data"   ,"D", 8,0},;
    {"cena_1"   ,"N",11,2},;
    {"PZKOL"    ,"N", 3,0},;
    {"PZ"       ,"N", 2,0},;
    {"ishod"    ,"N", 3,0},;
    {"tip"      ,"N", 1,0},; // 1 - обычный реестр, 2 -диспансеризация
    {"yes_del"  ,"L", 1,0},; // надо ли удалить после дополнительной проверки
    {"PLUS"     ,"L", 1,0};  // включается ли в счет
   })
use (cur_dir+"tmpb") new
index on str(kod_human,7) to (cur_dir+"tmpb")
adbf := {;
    {"MIN_DATE",    "D",     8,     0},;
    {"DNI",         "N",     3,     0},;
    {"NYEAR",       "N",     4,     0},; // отчетный год;;
    {"NMONTH",      "N",     2,     0},; // отчетный месяц;;
    {"KOL",         "N",     6,     0},;
    {"SUMMA",       "N",    15,     2},;
    {"KOD",         "N",     6,     0}}
for i := 0 to 99
  aadd(adbf,{"PZ"+lstr(i),"N",9,2})
next
mnyear := arr_m[1] ; mnmonth := arr_m[3]
dbcreate(cur_dir+"tmp",adbf)
Use (cur_dir+"tmp") new alias TMP
append blank
replace tmp->nyear with mnyear, tmp->nmonth with mnmonth, tmp->min_date with arr_m[6]
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_
dbseek(dtos(arr_m[5]),.t.)
do while human->k_data <= arr_m[6] .and. !eof()
  if ++k1 % 100 == 0
    @ maxrow(),1 say lstr(k1) color cColorSt2Msg
    @ row(),col() say "/" color "W/R"
    @ row(),col() say lstr(k) color cColorStMsg
  endif
  if human->tip_h == B_STANDART .and. emptyall(human_->reestr,human->schet) ;
                                .and. (human->cena_1 > 0 .or. human_->USL_OK == 4) ;
                                .and. val(human_->smo) > 0 .and. human_->ST_VERIFY >= 5 // и проверили
    if tmp->kol < 999999
      ++k
      tmp->kol++
      tmp->summa += human->cena_1
      tmp->min_date := min(tmp->min_date,human->k_data)
    endif
  endif
  select HUMAN
  skip
enddo
close databases
if k == 0
  rest_box(buf)
  func_error(4,"Нет пациентов для включения в реестр с датой окончания "+arr_m[4])
else
  Use (cur_dir+"tmp") new
  k := sys_date - tmp->min_date
  tmp->dni := iif(between(k,1,999), k, 0)
  go top
  rest_box(buf)
  if Alpha_Browse(T_ROW,2,T_ROW+7,77,"f1create_reestr",color0,;
                  "Невыписанные реестры случаев","R/BG",,,,,"f2create_reestr",,;
                  {'═','░','═',"N/BG,W+/N,B/BG,W+/B,R/BG",.f.,180} )
    rest_box(buf)
    if sys_date < stod(strzero(tmp->nyear,4)+strzero(tmp->nmonth,2)+"11")
      func_error(10,"Сегодня "+date_8(sys_date)+", а реестры разрешается отсылать с 11 числа")
    elseif mo_Lock_Task(X_OMS)
      close databases
      fl := .t.
      bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
      BEGIN SEQUENCE
        R_Use(dir_server+"human")
        index on str(schet,6)+str(tip_h,1)+upper(substr(fio,1,20)) to (dir_server+"humans") progress
        index on str(if(kod>0,kod_k,0),7)+str(tip_h,1) to (dir_server+"humankk") progress
        index on dtos(k_data)+uch_doc to (dir_server+"humand") progress
        Use
        R_Use(dir_server+"human_u")
        index on str(kod,7)+date_u to (dir_server+"human_u") progress
        Use
        R_Use(dir_server+"mo_hu")
        index on str(kod,7)+date_u to (dir_server+"mo_hu") progress
        Use
        R_Use(dir_server+"human_3")
        index on str(kod,7) to (dir_server+"human_3") progress
        index on str(kod2,7) to (dir_server+"human_32") progress
        Use
        R_Use(dir_server+"mo_onkna")
        index on str(kod,7) to (dir_server+"mo_onkna") progress
        R_Use(dir_server+"mo_onksl")
        index on str(kod,7) to (dir_server+"mo_onksl") progress
        R_Use(dir_server+"mo_onkco")
        index on str(kod,7) to (dir_server+"mo_onkco") progress
        R_Use(dir_server+"mo_onkdi")
        index on str(kod,7)+str(diag_tip,1)+str(diag_code,3) to (dir_server+"mo_onkdi") progress
        R_Use(dir_server+"mo_onkpr")
        index on str(kod,7)+str(prot,1) to (dir_server+"mo_onkpr") progress
        R_Use(dir_server+"mo_onkus")
        index on str(kod,7)+str(usl_tip,1) to (dir_server+"mo_onkus") progress
        R_Use(dir_server+"mo_onkle")
        index on str(kod,7)+regnum+code_sh+dtos(date_inj) to (dir_server+"mo_onkle") progress
        Use
      RECOVER USING error
        fl := func_error(10,"Возникла непредвиденная ошибка при переиндексировании!")
      END
      ERRORBLOCK(bSaveHandler)
      close databases
      if fl
        Private kol_1r := 0, kol_2r := 0, p_tip_reestr := 1
        verify_OMS(arr_m,.f.)
        ClrLine(maxrow(),color0)
        if kol_1r == 0 .and. kol_2r == 0
          //
        elseif kol_1r > 0 .and. kol_2r == 0
          p_tip_reestr := 1
        elseif kol_1r == 0 .and. kol_2r > 0
          p_tip_reestr := 2
        elseif f_alert({"",;
                        padc("Выберите тип реестра случаев для отправки в ТФОМС",70,"."),;
                        ""},;
                       {" Реестр ~обычный("+lstr(kol_1r)+")"," Реестр по ~диспансеризации("+lstr(kol_2r)+")"},;
                       1,"W/RB","G+/RB",maxrow()-6,,"BG+/RB,W+/R,W+/RB,GR+/R" ) == 2
          p_tip_reestr := 2
        endif
        mywait()
        use (cur_dir+"tmp") new
        _k := tmp->kol
        tmp->kol := 0
        tmp->summa := 0
        tmp->min_date := stod(strzero(tmp->nyear,4)+strzero(tmp->nmonth,2)+"01")
        for i := 0 to 99
          pole := "tmp->PZ"+lstr(i)
          &pole := 0
        next
        R_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
        set order to 2
        R_Use(dir_server+"human_",,"HUMAN_")
        R_Use(dir_server+"human",,"HUMAN")
        use (cur_dir+"tmpb") new
        set relation to kod_human into HUMAN, to kod_human into HUMAN_
        go top
        do while !eof()
          if human_->ST_VERIFY >= 5 .and. tmpb->tip == p_tip_reestr
            tmp->kol++
            if tmpb->ishod == 89
              select HUMAN_3
              find (str(human->kod,7))
              tmp->summa += human_3->cena_1
              tmp->min_date := min(tmp->min_date,human_3->k_data)
              k := human_3->PZKOL
              select TMPB
            else
              tmp->summa += human->cena_1
              tmp->min_date := min(tmp->min_date,human->k_data)
              k := human_->PZKOL
            endif
            j := human_->PZTIP
            tmpb->PZ := j
            pole := "tmp->PZ"+lstr(j)
            if tmp->nyear > 2018 // 2019 год
              if (i := ascan(glob_array_PZ_19, {|x| x[1] == j })) > 0 .and. !empty(glob_array_PZ_19[i,5])
                &pole := &pole + 1 // учёт по случаям
              else
                &pole := &pole + k // учёт по единицам план-заказа
              endif
            else
              if (i := ascan(glob_array_PZ_18, {|x| x[1] == j })) > 0 .and. !empty(glob_array_PZ_18[i,5])
                &pole := &pole + 1
              else
                &pole := &pole + human_->PZKOL
              endif
            endif
          else
            tmpb->yes_del := .t. // удалить после дополнительной проверки
          endif
          skip
        enddo
        if tmp->kol == 0
          func_error(4,"После дополнительной проверки некого включать в реестр")
        else
          if _k != tmp->kol
            select TMPB
            delete for yes_del
            pack
          endif
          if tmp->nyear > 2018 // 2019 год
            create1reestr19(tmp->(recno()),tmp->nyear,tmp->nmonth)
          else
            create1reestr17(tmp->(recno()),tmp->nyear,tmp->nmonth)
          endif
        endif
      endif
      mo_UnLock_Task(X_OMS)
    endif
  endif
  rest_box(buf)
endif
close databases
return NIL

*****
Function f1create_reestr(oBrow)
Local oColumn, n := 36, n1 := 20, blk
oColumn := TBColumnNew("Отчетный год", {|| str(tmp->nyear,4) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Отчетный месяц", {|| str(tmp->nmonth,2) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Дни max", {|| put_val(tmp->dni,3) })
oColumn:defColor := {5,5}
oColumn:colorBlock := {|| {5,5} }
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол-во больных", {|| str(tmp->kol,10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Сумма случаев", {|| str(tmp->summa,15,2) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
status_key('^<Esc>^ выход;  ^<Enter>^ составить реестр случаев;  ^<F9>^ печать списка пациентов')
return NIL

*****
Function f2create_reestr(nKey,oBrow)
Local buf, rec, k := -1, sh := 80, HH := 60, nfile := "spisok"+stxt, j := 0
do case
  case nkey == K_F9
    buf := save_maxrow()
    mywait()
    rec := tmp->(recno())
    fp := fcreate(nfile) ; n_list := 1 ; tek_stroke := 0
    add_string("")
    add_string(center("Список пациентов за отчётный период "+str(tmp->nyear,4)+"/"+strzero(tmp->nmonth,2),sh))
    add_string("")
    R_Use(dir_server+"mo_otd",,"OTD")
    R_Use(dir_server+"human",,"HUMAN")
    set relation to otd into OTD
    use (cur_dir+"tmpb") new
    set relation to kod_human into HUMAN
    index on upper(human->fio)+dtos(human->k_data) to (cur_dir+"tmpb") for kod_tmp == rec
    go top
    do while !eof()
      verify_FF(HH, .t., sh)
      add_string(str(++j,5)+". "+padr(human->fio,47)+date_8(human->n_data)+"-"+;
                 date_8(human->k_data)+" ["+otd->short_name+"]")
      skip
    enddo
    fclose(fp)
    otd->(dbCloseArea())
    human->(dbCloseArea())
    tmpb->(dbCloseArea())
    select TMP
    rest_box(buf)
    viewtext(nfile,,,,,,,2)
endcase
return k

***** 24.01.18
Function create1reestr17(_recno,_nyear,_nmonth)
Local buf := savescreen(), s, i, j, pole
Private mpz[100], oldpz[100], atip[100]
for j := 0 to 99
  pole := "tmp->PZ"+lstr(j)
  mpz[j+1] := oldpz[j+1] := &pole
  atip[j+1] := "-"
  if _nyear < 2018
    if (i := ascan(glob_array_PZ, {|x| x[1] == j })) > 0
      atip[j+1] := glob_array_PZ[i,4]
    endif
  else
    if (i := ascan(glob_array_PZ_18, {|x| x[1] == j })) > 0
      atip[j+1] := glob_array_PZ_18[i,4]
    endif
  endif
next
Private pkol := tmp->kol, psumma := tmp->summa, pnyear := _nyear
Private old_kol := pkol, old_summa := psumma, p_blk := {|mkol,msum| f_blk_create1reestr17(_nyear) }
close databases
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_
use (cur_dir+"tmpb") new alias TMP
set relation to kod_human into HUMAN
index on upper(human->fio)+dtos(human->k_data) to (cur_dir+"tmpb") for kod_tmp == _recno
go top
eval(p_blk)
if Alpha_Browse(3,0,maxrow()-4,79,"f1create1reestr17",color0,;
                "Составление реестра случаев за "+mm_month[_nmonth]+str(_nyear,5)+" года","BG+/GR",;
                .t.,.t.,,,"f2create1reestr17",,;
                {'═','░','═',"N/BG,W+/N,B/BG,W+/B",,300} )
  if pkol > 0 .and. (j := f_alert({"",;
                  "Каким образом сортировать реестр, отправляемый в ТФОМС",;
                  ""},;
                 {" по ~ФИО пациента "," по ~убыванию стоимости "},;
                 1,"W/RB","G+/RB",maxrow()-6,,"BG+/RB,W+/R,W+/RB,GR+/R" )) > 0
    f_message({"Системная дата: "+date_month(sys_date,.t.),;
               "Обращаем Ваше внимание, что",;
               "реестр будет создан с этой датой.",;
               "",;
               "Изменить её будет НЕВОЗМОЖНО!",;
               "",;
               "Сортировка реестра: "+{"по ФИО пациента","по убыванию стоимости лечения"}[j]},,;
               "GR+/R","W+/R")
    if f_Esc_Enter("составления реестра")
      restscreen(buf)
      create2reestr17(_recno,_nyear,_nmonth,j)
    endif
  endif
endif
close databases
restscreen(buf)
return NIL

***** 21.05.17
Function f_blk_create1reestr17(_nyear)
Local i, s, ta[2], sh := maxcol()+1
s := "Случаев - "+expand_value(pkol)+" на сумму "+expand_value(psumma,2)+" руб."
@ 0,0 say padc(s,sh) color color1
s := ""
for i := 1 to len(mpz)
  if !empty(mpz[i])
    s += alltrim(str_0(mpz[i],9,2))+" "+atip[i]+", "
  endif
next
if !empty(s)
  s := "(п/з: "+substr(s,1,len(s)-2)+")"
endif
perenos(ta,s,sh)
for i := 1 to 2
  @ i,0 say padc(alltrim(ta[i]),sh) color color1
next
return NIL

***** 24.01.18
Static Function f_p_z17(_pzkol,_pz,k)
Local s, s2, i
if pnyear < 2018 .and. _PZ == 62
  s := "УЕТ"
  s2 := ltrim(str(_pzkol,9,2))
else
  s2 := alltrim(str_0(_pzkol,9,2))
  s := atip[_PZ+1]
  if pnyear < 2018
    if (i := ascan(glob_array_PZ, {|x| x[1] == _PZ })) > 0 .and. !empty(glob_array_PZ[i,5])
      s2 += glob_array_PZ[i,5]
    endif
  else
    if (i := ascan(glob_array_PZ_18, {|x| x[1] == _PZ })) > 0 .and. !empty(glob_array_PZ_18[i,5])
      s2 += glob_array_PZ_18[i,5]
    endif
  endif
endif
return iif(k == 1, s, s2)

***** 29.03.16
Function f1create1reestr17(oBrow)
Local oColumn, tmp_color, blk_color := {|| if(tmp->plus, {1,2}, {3,4}) }, n := 30
oColumn := TBColumnNew(" ", {|| if(tmp->plus,""," ") })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(center("Ф.И.О. больного",n), {|| padr(human->fio,n) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("План-заказ", {|| padc(f_p_z17(human_->pzkol,tmp->pz,1),10) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол-во", {|| padc(f_p_z17(human_->pzkol,tmp->pz,2),6) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Нача-; ло", {|| left(dtoc(human->n_data),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Окончан.;лечения", {|| date_8(human->k_data) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Стоимость; лечения", {|| put_kopE(human->cena_1,10) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
tmp_color := setcolor("N/BG")
@ maxrow()-3,0 say padr(" <Esc> - выход     <Enter> - подтверждение составления реестра",80)
@ maxrow()-2,0 say padr(" <Ins> - отметить одного пациента или снять отметку с одного пациента",80)
@ maxrow()-1,0 say padr(" <+> - отметить всех пациентов (или по одному виду ПЛАНА-ЗАКАЗА) ",80)
@ maxrow()-0,0 say padr(" <-> - снять со всех отметки (никто не попадает в реестр)",80)
mark_keys({"<Esc>","<Enter>","<Ins>","<+>","<->","<F9>"},"R/BG")
setcolor(tmp_color)
return NIL

***** 24.01.18
Function f2create1reestr17(nKey,oBrow)
Local buf, rec, k := -1, s, i, j, mas_pmt := {}, arr, r1, r2
do case
  case nkey == K_INS
    replace tmp->plus with !tmp->plus
    j := tmp->pz + 1
    if pnyear >= 2018
      i := ascan(glob_array_PZ_18, {|x| x[1] == tmp->PZ })
    elseif pnyear >= 2016
      i := ascan(glob_array_PZ, {|x| x[1] == tmp->PZ })
    endif
    if tmp->plus
      psumma += human->cena_1 ; pkol++
      if pnyear < 2018
        if i > 0 .and. !empty(glob_array_PZ[i,5])
          mpz[j] ++
        else
          mpz[j] += human_->PZKOL
        endif
      else
        if i > 0 .and. !empty(glob_array_PZ_18[i,5])
          mpz[j] ++
        else
          mpz[j] += human_->PZKOL
        endif
      endif
    else
      psumma -= human->cena_1 ; pkol--
      if pnyear < 2018
        if i > 0 .and. !empty(glob_array_PZ[i,5])
          mpz[j] --
        else
          mpz[j] -= human_->PZKOL
        endif
      else
        if i > 0 .and. !empty(glob_array_PZ_18[i,5])
          mpz[j] --
        else
          mpz[j] -= human_->PZKOL
        endif
      endif
    endif
    eval(p_blk)
    k := 0
    keyboard chr(K_TAB)
  case nkey == 43  // +
    arr := {}
    aadd(mas_pmt, "Отметить всех пациентов") ; aadd(arr,-1)
    if !empty(oldpz[1])
      aadd(mas_pmt, "Отметить неопределённых пациентов") ; aadd(arr,0)
    endif
    if pnyear < 2018
      for j := 2 to len(oldpz)
        if !empty(oldpz[j]) .and. (i := ascan(glob_array_PZ, {|x| x[1] == j-1 })) > 0
          aadd(mas_pmt, 'Отметить "'+glob_array_PZ[i,3]+'"') ; aadd(arr,j-1)
        endif
      next
    else
      for j := 2 to len(oldpz)
        if !empty(oldpz[j]) .and. (i := ascan(glob_array_PZ_18, {|x| x[1] == j-1 })) > 0
          aadd(mas_pmt, 'Отметить "'+glob_array_PZ_18[i,3]+'"') ; aadd(arr,j-1)
        endif
      next
    endif
    r1 := 12
    r2 := r1 + len(mas_pmt) + 1
    if r2 > maxrow()-2
      r2 := maxrow()-2
      r1 := r2 - len(mas_pmt) - 1
      if r1 < 2
        r1 := 2
      endif
    endif
    if (j := popup_SCR(r1,12,r2,67,mas_pmt,1,color5,.t.)) > 0
      j := arr[j]
      rec := recno()
      buf := save_maxrow()
      mywait()
      if j == -1
        tmp->(dbeval({|| tmp->plus := .t. }))
        psumma := old_summa ; pkol := old_kol
        aeval(mpz, {|x,i| mpz[i] := oldpz[i] })
      else
        psumma := pkol := 0
        afill(mpz,0)
        mpz[j+1] := oldpz[j+1]
        go top
        do while !eof()
          if tmp->pz == j
            tmp->plus := .t.
            psumma += human->cena_1
            pkol++
          else
            tmp->plus := .f.
          endif
          skip
        enddo
      endif
      goto (rec)
      rest_box(buf)
      eval(p_blk)
      k := 0
    endif
  case nkey == 45  //  -
    rec := recno()
    buf := save_maxrow()
    mywait()
    tmp->(dbeval({|| tmp->plus := .f. }))
    goto (rec)
    rest_box(buf)
    psumma := pkol := 0
    afill(mpz,0)
    eval(p_blk)
    k := 0
endcase
return k

***** 01.11.18 создание XML-файлов реестра
Function create2reestr17(_recno,_nyear,_nmonth,reg_sort)
Local mnn, mnschet := 1, fl, mkod_reestr, name_zip, arr_zip := {}, ;
      lst, lshifr1, code_reestr, mb, me, nsh, adiag_talon[16]
//
Private version_3_1 := (strzero(_nyear,4)+strzero(_nmonth,2) > "201808") // с сентября 2018 года
//
stat_msg("Составление реестра случаев")
close databases
nsh := f_mb_me_nsh(_nyear,@mb,@me)
R_Use(dir_exe+"_mo_mkb",,"MKB_10")
index on shifr+str(ks,1) to (cur_dir+"_mo_mkb")
G_Use(dir_server+"mo_rees",,"REES")
index on str(nn,nsh) to (cur_dir+"tmp_rees") for nyear == _nyear .and. nmonth == _nmonth
fl := .f.
for mnn := mb to me
  find (str(mnn,nsh))
  if !found() // нашли свободный номер
    fl := .t. ; exit
  endif
next
if !fl
  close databases
  return func_error(10,"Не удалось найти свободный номер пакета в ТФОМС. Проверьте настройки!")
endif
index on str(nschet,6) to (cur_dir+"tmp_rees") for nyear == _nyear
if !eof()
  go bottom
  mnschet := rees->nschet+1
endif
if !between(mnschet,mem_beg_rees,mem_end_rees)
  fl := .f.
  for mnschet := mem_beg_rees to mem_end_rees
    find (str(mnschet,6))
    if !found() // нашли свободный номер
      fl := .t. ; exit
    endif
  next
  if !fl
    close databases
    return func_error(10,"Не удалось найти свободный номер реестра. Проверьте настройки!")
  endif
endif
set index to
AddRecN()
rees->KOD    := recno()
rees->NSCHET := mnschet
rees->DSCHET := sys_date
rees->NYEAR  := _NYEAR
rees->NMONTH := _NMONTH
rees->NN     := mnn
s := "RM"+CODE_LPU+"T34"+"_"+right(strzero(_NYEAR,4),2)+strzero(_NMONTH,2)+strzero(mnn,nsh)
rees->NAME_XML := {"H","F"}[p_tip_reestr]+s
mkod_reestr := rees->KOD
rees->CODE  := ret_unique_code(mkod_reestr)
code_reestr := rees->CODE
//
G_Use(dir_server+"mo_xml",,"MO_XML")
AddRecN()
mo_xml->KOD    := recno()
mo_xml->FNAME  := rees->NAME_XML
mo_xml->FNAME2 := "L"+s
mo_xml->DFILE  := rees->DSCHET
mo_xml->TFILE  := hour_min(seconds())
mo_xml->TIP_OUT := _XML_FILE_REESTR // тип высылаемого файла;1-реестр
mo_xml->REESTR := mkod_reestr
//
rees->KOD_XML := mo_xml->KOD
UnLock
Commit
//
//R_Use(exe_dir+"_mo_v024",cur_dir+"_mo_v024","V024")
use_base("lusl")
use_base("luslc")
use_base("luslf")
R_Use(dir_server+"mo_uch",,"UCH")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"mo_pers",,"P2")
R_Use(dir_server+"uslugi",,"USL")
G_Use(dir_server+"mo_rhum",,"RHUM")
index on str(REESTR,6) to (cur_dir+"tmp_rhum")
G_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to recno() into HU_, to u_kod into USL
R_Use(dir_server+"mo_su",,"MOSU")
G_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
if p_tip_reestr == 1
  R_Use(dir_server+"kart_inv",,"INV")
  index on str(kod,7) to (cur_dir+"tmp_inv")
endif
R_Use(dir_server+"kartote2",,"KART2")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_, to recno() into KART2
R_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","ONKNA") // онконаправления
R_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","ONKSL") // Сведения о случае лечения онкологического заболевания
R_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","ONKDI") // Диагностический блок
R_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","ONKPR") // Сведения об имеющихся противопоказаниях
G_Use(dir_server+"human_2",,"HUMAN_2")
G_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
use (cur_dir+"tmpb") new
set relation to kod_human into HUMAN
if reg_sort == 1
  index on upper(human->fio) to (cur_dir+"tmpb") for kod_tmp==_recno .and. plus
else
  index on str(pz,2)+str(10000000-human->cena_1,11,2) to (cur_dir+"tmpb") for kod_tmp==_recno .and. plus
endif
pkol := psumma := iusl := 0
go top
do while !eof()
  pkol++ ; psumma += human->cena_1
  @ maxrow(),1 say lstr(pkol) color cColorSt2Msg
  select RHUM
  AddRec(6)
  rhum->REESTR := mkod_reestr
  rhum->KOD_HUM := human->kod
  rhum->REES_ZAP := pkol
  human_->(G_RLock(forever))
  if human_->REES_NUM < 99
    human_->REES_NUM := human_->REES_NUM+1
  endif
  human_->REESTR := mkod_reestr
  human_->REES_ZAP := pkol
  UnLock
  if pkol % 2000 == 0
    Commit
  endif
  select TMPB
  skip
enddo
select TMPB
set relation to
select REES
G_RLock(forever)
rees->KOL := pkol
rees->SUMMA := psumma
dbUnlockAll()
dbCommitAll()
//
Private arr_usl_otkaz, fl_2_14 := .f.
//
oXmlDoc := HXMLDoc():New()
oXmlDoc:Add( HXMLNode():New( "ZL_LIST") )
 oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
  if version_3_1
    s := '3.1'
    fl_2_14 := .t.
  else
    s := '2.12'
    if p_tip_reestr == 1
      if _NYEAR > 2017
        s := '2.13'
        if _NYEAR == 2018 .and. _NMONTH >= 5 // с мая 2018 года
          s := '2.14'
          fl_2_14 := .t.
        endif
      endif
    endif
  endif
  mo_add_xml_stroke(oXmlNode,"VERSION" ,s)
  mo_add_xml_stroke(oXmlNode,"DATA"    ,date2xml(rees->DSCHET))
  mo_add_xml_stroke(oXmlNode,"FILENAME",mo_xml->FNAME)
  mo_add_xml_stroke(oXmlNode,"SD_Z"    ,lstr(pkol)) // новое поле
 oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "SCHET" ) )
  mo_add_xml_stroke(oXmlNode,"CODE"   ,lstr(code_reestr))
  mo_add_xml_stroke(oXmlNode,"CODE_MO",CODE_MO)
  mo_add_xml_stroke(oXmlNode,"YEAR"   ,lstr(_NYEAR))
  mo_add_xml_stroke(oXmlNode,"MONTH"  ,lstr(_NMONTH))
  mo_add_xml_stroke(oXmlNode,"NSCHET" ,lstr(rees->NSCHET))
  mo_add_xml_stroke(oXmlNode,"DSCHET" ,date2xml(rees->DSCHET))
  mo_add_xml_stroke(oXmlNode,"SUMMAV" ,str(psumma,15,2))
//
select RHUM
set relation to kod_hum into HUMAN
index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR==mkod_reestr
go top
do while !eof()
  @ maxrow(),0 say str(rhum->REES_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
  fl_DISABILITY := is_zak_sl := is_zak_sl_vr := .f.
  lshifr_zak_sl := lvidpoms := ""
  a_usl := {} ; a_fusl := {} ; lvidpom := 1 ; lfor_pom := 3
  atmpusl := {} ; akslp := {} ; akiro := {} ; tarif_zak_sl := human->cena_1
  v_reabil_slux := 0
  m1veteran := 0
  m1mobilbr := 0  // мобильная бригада
  m1mesto_prov := 0
  m1p_otk := 0    // признак отказа
  m1dopo_na := 0
  m1napr_v_mo := 0 // {{"-- нет --",0},{"в нашу МО",1},{"в иную МО",2}}, ;
  arr_mo_spec := {}
  m1napr_stac := 0 // {{"--- нет ---",0},{"в стационар",1},{"в дн. стац.",2}}, ;
  m1profil_stac := 0
  m1napr_reab := 0
  m1profil_kojki := 0
  fl_disp_nabl := .f.
  ldate_next := ctod("")
  //
  is_oncology := f_is_oncology(1)
  if p_tip_reestr == 2
    is_oncology := 0
  endif
  arr_onkna := {}
  select ONKNA
  find (str(human->kod,7))
  do while onkna->kod == human->kod .and. !eof()
    mosu->(dbGoto(onkna->U_KOD))
    aadd(arr_onkna, {onkna->NAPR_DATE,onkna->NAPR_V,onkna->MET_ISSL,mosu->shifr1})
    skip
  enddo
  //
  mvsod := 0
  select ONKSL
  find (str(human->kod,7))
  //
  arr_onkdi := {}
  select ONKDI
  find (str(human->kod,7))
  do while onkdi->kod == human->kod .and. !eof()
    aadd(arr_onkdi, {onkdi->DIAG_DATE,onkdi->DIAG_TIP,onkdi->DIAG_CODE,onkdi->DIAG_RSLT})
    skip
  enddo
  //
  arr_onkpr := {}
  select ONKPR
  find (str(human->kod,7))
  do while onkpr->kod == human->kod .and. !eof()
    aadd(arr_onkpr, {onkpr->PROT,onkpr->D_PROT})
    skip
  enddo
  //
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,,@lst,,@s)
      lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
      if human_->USL_OK == 3 .and. is_usluga_disp_nabl(lshifr)
        ldate_next := c4tod(human->DATE_OPL)
        fl_disp_nabl := .t.
      endif
      aadd(atmpusl,lshifr)
      if !empty(s) .and. "," $ s
        lvidpoms := s
      endif
      if (hu->stoim_1 > 0 .or. left(lshifr,3) == "71.") .and. (i := ret_vid_pom(1,lshifr,human->k_data)) > 0
        lvidpom := i
      endif
      if f_is_neotl_pom(lshifr)
        lfor_pom := 2 // неотложная
      endif
      if ascan(glob_KSG_dializ,lshifr) > 0 // диализ в 2017 году
        lvidpoms := ""
        lvidpom := 31
      endif
      if lst == 1
        lshifr_zak_sl := lshifr
        if f_is_zak_sl_vr(lshifr) // зак.случай в п-ке
          is_zak_sl_vr := .t.
        else
          is_zak_sl_vr := .t. // КСГ
          if _NYEAR < 2018 // стационар
            if human_->USL_OK == 1 .and. p_tip_reestr == 1
              akslp := f_cena_kslp(hu->stoim,lshifr,iif(human_->NOVOR==0,human->date_r,human_->DATE_R2),human->n_data,human->k_data)
            endif
          else // 2018
            if human_->USL_OK < 3 .and. p_tip_reestr == 1
              if !empty(human_2->pc1)
                akslp := List2Arr(human_2->pc1)
              endif
              if !empty(human_2->pc2)
                akiro := List2Arr(human_2->pc2)
              endif
            endif
          endif
          if !empty(akslp) .or. !empty(akiro)
            otd->(dbGoto(human->OTD))
            f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
            tarif_zak_sl := fcena_oms(lshifr,(human->vzros_reb==0),human->k_data)
          endif
          if eq_any(human_->USL_OK,1,2) .and. human_->PROFIL == 158 .and. is_reabil_slux
            if _NYEAR > 2017
              t_arr := {"1331.0","1332.0","1333.0","1335.0","2127.0","2128.0","2130.0"}
              for i := 1 to len(t_arr)
                if t_arr[i] == lshifr .and. !between(human_2->PN1,1,3)
                  v_reabil_slux := human_2->PN1
                endif
              next
            else
              t_arr := {"12???311","12???312","22???117","22???118"}
              for i := 1 to len(t_arr)
                if like(t_arr[i],lshifr) .and. between(human_2->PN1,1,3)
                  v_reabil_slux := human_2->PN1
                endif
              next
            endif
          endif
        endif
      else
        aadd(a_usl,hu->(recno()))
      endif
    endif
    select HU
    skip
  enddo
  if is_oncology == 2 .and. human_->USL_OK == 3 .and. fl_disp_nabl // Диспансерное наблюдение
    is_oncology := 1 // для дисп.наблюдения не вводится онкология
  endif
  if !empty(lvidpoms)
    if !eq_ascan(atmpusl,"55.1.2","55.1.3") .or. glob_mo[_MO_KOD_TFOMS] == '801935' // ЭКО-Москва
      lvidpoms := ret_vidpom_licensia(human_->USL_OK,lvidpoms) // только для дн.стационара при стационаре
    endif
    if !empty(lvidpoms) .and. !("," $ lvidpoms)
      lvidpom := int(val(lvidpoms))
      lvidpoms := ""
    endif
  endif
  if !empty(lvidpoms)
    if eq_ascan(atmpusl,"55.1.1","55.1.4","55.1.6")
      if "31" $ lvidpoms
        lvidpom := 31
      endif
    elseif eq_ascan(atmpusl,"55.1.2","55.1.3")
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
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    mvsod += mohu->PZKOL
    aadd(a_fusl,mohu->(recno()))
    skip
  enddo
  a_otkaz := {}
  arr_nazn := {}
  if eq_any(human->ishod,101,102) // дисп-ия детей-сирот
    read_arr_DDS(human->kod)
  elseif eq_any(human->ishod,301,302) // профосмотры несовершеннолетних
    arr_usl_otkaz := {}
    read_arr_PN(human->kod)
    if valtype(arr_usl_otkaz) == "A"
      for j := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[j]
        if valtype(ar) == "A" .and. len(ar) > 9 .and. valtype(ar[5]) == "C" .and. ;
                                                      valtype(ar[10]) == "C" .and. ar[10] $ "io"
          lshifr := alltrim(ar[5])
          ldate := human->N_DATA // дата
          if valtype(ar[9]) == "D"
            ldate := ar[9]
          endif
          if ar[10] == "i" // исследования
            if (i := ascan(np_arr_issled, {|x| valtype(x[1]) == "C" .and. x[1] == lshifr})) > 0
              aadd(a_otkaz,{lshifr,;
                            ar[6],; // диагноз
                            ldate,; // дата
                            correct_profil(ar[4]),; // профиль
                            ar[2],; // специальность
                            0,;     // цена
                            1})     // 1-отказ,2-невозможность
            endif
          elseif (i := ascan(np_arr_osmotr, {|x| valtype(x[1]) == "C" .and. x[1] == lshifr})) > 0 // осмотры
            if (i := ascan(np_arr_osmotr_KDP2, {|x| x[1] == lshifr })) > 0
              lshifr := np_arr_osmotr_KDP2[i,3]  // замена врачебного приёма на 2.3.*
            endif
            aadd(a_otkaz,{lshifr,;
                          ar[6],; // диагноз
                          ldate,; // дата
                          correct_profil(ar[4]),; // профиль
                          ar[2],; // специальность
                          0,;     // цена
                          1})     // 1-отказ,2-невозможность
          endif
        endif
      next j
    endif
  elseif between(human->ishod,201,205) // дисп-ия I этап или профилактика
    arr_usl_otkaz := {}
    read_arr_DVN(human->kod)
    if valtype(arr_usl_otkaz) == "A" .and. eq_any(human->ishod,201,203) // не II этап
      for j := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[j]
        if valtype(ar) == "A" .and. len(ar) >= 10 .and. valtype(ar[5]) == "C"
          lshifr := alltrim(ar[5])
          if (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]==lshifr})) > 0
            if valtype(ar[10]) == "N" .and. between(ar[10],1,2)
              aadd(a_otkaz,{lshifr,;
                            ar[6],; // диагноз
                            human->N_DATA,; // дата
                            correct_profil(ar[4]),; // профиль
                            ar[2],; // специальность
                            ar[8],; // цена
                            ar[10]}) // 1-отказ,2-невозможность
            endif
          endif
        endif
      next j
    endif
  endif
  if m1dopo_na > 0
    aadd(arr_nazn,{3,{}}) ; j := len(arr_nazn)
    for i := 1 to 3
      if isbit(m1dopo_na,i)
        aadd(arr_nazn[j,2],i)
      endif
    next
  endif
  if between(m1napr_v_mo,1,2) .and. !empty(arr_mo_spec) // {{"-- нет --",0},{"в нашу МО",1},{"в иную МО",2}}, ;
    aadd(arr_nazn,{m1napr_v_mo,{}}) ; j := len(arr_nazn)
    for i := 1 to min(3,len(arr_mo_spec))
      aadd(arr_nazn[j,2],arr_mo_spec[i])
    next
  endif
  if between(m1napr_stac,1,2) .and. m1profil_stac > 0 // {{"--- нет ---",0},{"в стационар",1},{"в дн. стац.",2}}, ;
    aadd(arr_nazn,{iif(m1napr_stac==1,5,4),m1profil_stac})
  endif
  if m1napr_reab == 1 .and. m1profil_kojki > 0
    aadd(arr_nazn,{6,m1profil_kojki})
  endif
  cSMOname := ""
  if alltrim(human_->smo) == '34'
    cSMOname := ret_inogSMO_name(2)
  endif
  mdiagnoz := diag_for_xml(,.t.,,,.t.)
  if p_tip_reestr == 1
    if glob_mo[_MO_IS_UCH] .and. ;                    // наше МО имеет прикреплённое население
       human_->USL_OK == 3 .and. ;                    // поликлиника
       kart2->MO_PR == glob_MO[_MO_KOD_TFOMS] .and. ; // прикреплён к нашему МО
       between(kart_->INVALID,1,4)                    // инвалид
      select INV
      find (str(human->kod_k,7))
      if found() .and. !emptyany(inv->DATE_INV,inv->PRICH_INV)
        // дата начала лечения отстоит от даты первичного установления инвалидности не более чем на год
        fl_DISABILITY := (inv->DATE_INV < human->n_data .and. human->n_data <= addmonth(inv->DATE_INV,12))
      endif
    endif
  else
    afill(adiag_talon,0)
    for i := 1 to 16
      adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
    next
  endif
  mdiagnoz3 := {}
  if !empty(human_2->OSL1)
    aadd(mdiagnoz3,human_2->OSL1)
  endif
  if !empty(human_2->OSL2)
    aadd(mdiagnoz3,human_2->OSL2)
  endif
  if !empty(human_2->OSL3)
    aadd(mdiagnoz3,human_2->OSL3)
  endif
  oZAP := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZAP" ) )
   mo_add_xml_stroke(oZAP,"N_ZAP" ,lstr(rhum->REES_ZAP))
   mo_add_xml_stroke(oZAP,"PR_NOV",iif(human_->SCHET_NUM > 0, '1', '0')) // если попал в счёт 2-й раз и т.д.
   oPAC := oZAP:Add( HXMLNode():New( "PACIENT" ) )
    mo_add_xml_stroke(oPAC,"ID_PAC",human_->ID_PAC)
    mo_add_xml_stroke(oPAC,"VPOLIS",lstr(human_->VPOLIS))
    if !empty(human_->SPOLIS)
      mo_add_xml_stroke(oPAC,"SPOLIS",human_->SPOLIS)
    endif
    mo_add_xml_stroke(oPAC,"NPOLIS",human_->NPOLIS)
    if len(alltrim(kart2->kod_mis)) == 16
      mo_add_xml_stroke(oPAC,"ENP",kart2->kod_mis) // Единый номер полиса единого образца
    endif
    if empty(cSMOname)
      mo_add_xml_stroke(oPAC,"SMO" ,human_->smo)
    endif
    mo_add_xml_stroke(oPAC,"SMO_OK",iif(empty(human_->OKATO),"18000",human_->OKATO))
    if !empty(cSMOname)
      mo_add_xml_stroke(oPAC,"SMO_NAM",cSMOname)
    endif
    if human_->NOVOR == 0
      mo_add_xml_stroke(oPAC,"NOVOR",lstr(human_->NOVOR))
    else
      mnovor := iif(human_->pol2=="М",'1','2')+;
                strzero(day(human_->DATE_R2),2)+;
                strzero(month(human_->DATE_R2),2)+;
                right(lstr(year(human_->DATE_R2)),2)+;
                strzero(human_->NOVOR,2)
      mo_add_xml_stroke(oPAC,"NOVOR",mnovor)
    endif
    //mo_add_xml_stroke(oPAC,"MO_PR",???)
    if human_->USL_OK == 1 .and. human_2->VNR > 0
      // стационар + л/у на недоношенного ребёнка
      mo_add_xml_stroke(oPAC,"VNOV_D",lstr(human_2->VNR))
    endif
    if fl_DISABILITY // Сведения о первичном признании застрахованного лица инвалидом
      oDISAB := oPAC:Add( HXMLNode():New( "DISABILITY" ) )
       // группа инвалидности при первичном признании застрахованного лица инвалидом
       mo_add_xml_stroke(oDISAB,"INV",lstr(kart_->invalid))
       // Дата первичного установления инвалидности
       mo_add_xml_stroke(oDISAB,"DATA_INV",date2xml(inv->DATE_INV))
       // Код причины установления  инвалидности
       mo_add_xml_stroke(oDISAB,"REASON_INV",lstr(inv->PRICH_INV))
      if !empty(inv->DIAG_INV) // Код основного заболевания по МКБ-10
       mo_add_xml_stroke(oDISAB,"DS_INV",inv->DIAG_INV)
      endif
    endif
   oSLUCH := oZAP:Add( HXMLNode():New( "SLUCH" ) )
    mo_add_xml_stroke(oSLUCH,"IDCASE"  ,lstr(rhum->REES_ZAP))
    mo_add_xml_stroke(oSLUCH,"ID_C"    ,human_->ID_C)
    if p_tip_reestr == 2
      s := space(3)
      ret_tip_lu(@s)
      if !empty(s)
        mo_add_xml_stroke(oSLUCH,"DISP",s) // Тип диспансеризации
      endif
    endif
    mo_add_xml_stroke(oSLUCH,"USL_OK"  ,lstr(human_->USL_OK))
    mo_add_xml_stroke(oSLUCH,"VIDPOM"  ,lstr(lvidpom))
    do case
      case human_->USL_OK == 1 // стационар
        i := iif(left(human_->FORMA14,1)=='1', 1, 3)
      case human_->USL_OK == 4 // скорая помощь
        i := iif(left(human_->FORMA14,1)=='1', 1, 2)
      otherwise
        i := lfor_pom
    endcase
    // 1 - экстренная, 2 - неотложная, 3 - плановая
    mo_add_xml_stroke(oSLUCH,"FOR_POM",lstr(i))
    if (is_vmp := human_->USL_OK == 1 .and. human_2->VMP == 1 ;// ВМП
                                      .and. !emptyany(human_2->VIDVMP,human_2->METVMP))
      mo_add_xml_stroke(oSLUCH,"VID_HMP",human_2->VIDVMP)
      mo_add_xml_stroke(oSLUCH,"METOD_HMP",lstr(human_2->METVMP))
    endif
    if p_tip_reestr == 1 .and. !empty(human_->NPR_MO) ;
                         .and. !empty(mNPR_MO := ret_mo(human_->NPR_MO)[_MO_KOD_FFOMS])
      mo_add_xml_stroke(oSLUCH,"NPR_MO",mNPR_MO)
      if fl_2_14
        s := iif(empty(human_2->NPR_DATE), human->N_DATA, human_2->NPR_DATE)
        mo_add_xml_stroke(oSLUCH,"NPR_DATE",date2xml(s))
      endif
    endif
    if human_->USL_OK == 1 .and. !fl_2_14 // стационар
      i := int(val(left(human_->FORMA14,1)))
      mo_add_xml_stroke(oSLUCH,"EXTR",lstr(i+1))
    endif
    mo_add_xml_stroke(oSLUCH,"LPU",CODE_LPU)
    otd->(dbGoto(human->OTD))
    if human_->USL_OK == 1 .and. is_otd_dep .and. _NYEAR > 2017
      f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
      if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
        i := 1
      endif
      mo_add_xml_stroke(oSLUCH,"LPU_1",lstr(mm_otd_dep[i,3]))
      mo_add_xml_stroke(oSLUCH,"PODR" ,lstr(glob_otd_dep))
    elseif human_->USL_OK == 1 .and. is_adres_podr .and. _NYEAR == 2017 .and. human->K_DATA >= d_01_08_2017
      f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
      mo_add_xml_stroke(oSLUCH,"PODR"  ,glob_podr)
    endif
    mo_add_xml_stroke(oSLUCH,"PROFIL"  ,lstr(human_->PROFIL))
    if p_tip_reestr == 1
      if human_->USL_OK < 3 .and. fl_2_14
        mo_add_xml_stroke(oSLUCH,"PROFIL_K",lstr(human_2->PROFIL_K))
      endif
      mo_add_xml_stroke(oSLUCH,"DET"   ,iif(human->VZROS_REB==0,'0','1'))
      if human_->USL_OK == 3 .and. fl_2_14
        s := "2.6"
        if (i := ascan(glob_V025, {|x| x[2] == human_->povod})) > 0
          s := glob_V025[i,3]
        endif
        mo_add_xml_stroke(oSLUCH,"P_CEL",s)
      endif
    else
      mo_add_xml_stroke(oSLUCH,"VBR"   ,iif(m1mobilbr==0,'0','1'))
    endif
    if is_vmp
      mo_add_xml_stroke(oSLUCH,"TAL_D" ,date2xml(human_2->TAL_D)) // Дата выдачи талона на ВМП
      mo_add_xml_stroke(oSLUCH,"TAL_P" ,date2xml(human_2->TAL_P)) // Дата планируемой госпитализации в соответствии с талоном на ВМП
      if fl_2_14
        mo_add_xml_stroke(oSLUCH,"TAL_NUM" ,human_2->TAL_NUM) // номер талона на ВМП
      endif
    endif
    mo_add_xml_stroke(oSLUCH,"NHISTORY",iif(empty(human->UCH_DOC),lstr(human->kod),human->UCH_DOC))
    if !is_vmp .and. eq_any(human_->USL_OK,1,2)
      mo_add_xml_stroke(oSLUCH,"P_PER" ,lstr(human_2->P_PER)) // Признак поступления/перевода
    elseif p_tip_reestr == 2
      mo_add_xml_stroke(oSLUCH,"P_OTK" ,iif(m1p_otk==0,'0','1')) // Признак отказа
    endif
    mo_add_xml_stroke(oSLUCH,"DATE_1"  ,date2xml(human->N_DATA))
    mo_add_xml_stroke(oSLUCH,"DATE_2"  ,date2xml(human->K_DATA))
    if p_tip_reestr == 1 .and. !empty(human_->kod_diag0)
      mo_add_xml_stroke(oSLUCH,"DS0"   ,human_->kod_diag0)
    endif
    mo_add_xml_stroke(oSLUCH,"DS1"     ,rtrim(mdiagnoz[1]))
    if p_tip_reestr == 2
      s := 0
      if adiag_talon[1] == 1 // впервые
        mo_add_xml_stroke(oSLUCH,"DS1_PR",'1')
        if adiag_talon[2] == 2
          s := 1
        endif
      elseif adiag_talon[1] == 2 // ранее
        if adiag_talon[2] == 1
          s := 2 // состоит
        elseif adiag_talon[2] == 2
          s := 1 // взят
        endif
      endif
      if version_3_1 .and. human->OBRASHEN == '1'
        mo_add_xml_stroke(oSLUCH,"DS_ONK",'1')
      endif
      mo_add_xml_stroke(oSLUCH,"PR_D_N",lstr(s))
    endif
    if p_tip_reestr == 1
      for i := 2 to len(mdiagnoz)
        if !empty(mdiagnoz[i])
          mo_add_xml_stroke(oSLUCH,"DS2" ,rtrim(mdiagnoz[i]))
        endif
      next
      for i := 1 to len(mdiagnoz3) // ЕЩЁ ДИАГНОЗы ОСЛОЖНЕНИЯ ЗАБОЛЕВАНИЯ
        if !empty(mdiagnoz3[i])
          mo_add_xml_stroke(oSLUCH,"DS3",rtrim(mdiagnoz3[i]))
        endif
      next
      if version_3_1 .and. human_->USL_OK < 4
        if human->OBRASHEN == '1' .and. is_oncology < 2 //.and. human_->PROFIL != 158
          mo_add_xml_stroke(oSLUCH,"DS_ONK",'1')
        endif
        if human_->USL_OK == 3
          //mo_add_xml_stroke(oSLUCH,"C_ZAB",'1')
        endif
      endif
      if human_->USL_OK == 3 .and. fl_2_14 .and. human_->povod == 4 // Обязательно, если P_CEL=1.3
        s := 2 // взят
        if adiag_talon[1] == 2 // ранее
          if adiag_talon[2] == 1
            s := 1 // состоит
          elseif adiag_talon[2] == 2
            s := 2 // взят
          elseif adiag_talon[2] == 3 // снят
            s := 4 // снят по причине выздоровления
          elseif adiag_talon[2] == 4
            s := 6 // снят по другим причинам
          endif
        endif
        mo_add_xml_stroke(oSLUCH,"DN",lstr(s))
      endif
      //mo_add_xml_stroke(oSLUCH,"MSE",'1')
      if human_->USL_OK == 1 // стационар
        // вес недоношенных детей для л/у матери
        if human_2->VNR1 > 0
          mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(human_2->VNR1))
        endif
        if human_2->VNR2 > 0
          mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(human_2->VNR2))
        endif
        if human_2->VNR3 > 0
          mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(human_2->VNR3))
        endif
      endif
    else // диспансеризация
      for i := 2 to len(mdiagnoz)
        if !empty(mdiagnoz[i])
         oDiag := oSLUCH:Add( HXMLNode():New( "DS2_N" ) )
          mo_add_xml_stroke(oDiag,"DS2",rtrim(mdiagnoz[i]))
          s := 0
          if adiag_talon[i*2-1] == 1 // впервые
            mo_add_xml_stroke(oDiag,"DS2_PR",'1')
            if adiag_talon[i*2] == 2
              s := 1
            endif
          elseif adiag_talon[i*2-1] == 2 // ранее
            if adiag_talon[i*2] == 1
              s := 2 // состоит
            elseif adiag_talon[i*2] == 2
              s := 1 // взят
            endif
          endif
          mo_add_xml_stroke(oDiag,"PR_D",lstr(s))
        endif
      next
    endif
    if is_zak_sl .or. is_zak_sl_vr
      mo_add_xml_stroke(oSLUCH,"CODE_MES1",lshifr_zak_sl)
    endif
    if version_3_1 .and. human_->USL_OK < 4 .and. is_oncology > 0
      for j := 1 to len(arr_onkna)
       oNAPR := oSLUCH:Add( HXMLNode():New( "NAPR" ) )
        mo_add_xml_stroke(oNAPR,"NAPR_DATE",date2xml(arr_onkna[j,1]))
        mo_add_xml_stroke(oNAPR,"NAPR_V",lstr(arr_onkna[j,2]))
        if arr_onkna[j,2] == 3
          mo_add_xml_stroke(oNAPR,"MET_ISSL",lstr(arr_onkna[j,3]))
          mo_add_xml_stroke(oNAPR,"NAPR_USL",arr_onkna[j,4])
        endif
      next j
      if is_oncology == 2
       oONK_SL := oSLUCH:Add( HXMLNode():New( "ONK_SL" ) )
        mo_add_xml_stroke(oONK_SL,"DS1_T",lstr(onksl->DS1_T))
        if .f. // between(onksl->PR_CONS,1,3)
          //mo_add_xml_stroke(oONK_SL,"PR_CONS",lstr(onksl->PR_CONS))
          //mo_add_xml_stroke(oONK_SL,"DT_CONS",date2xml(onksl->DT_CONS))
        endif
        mo_add_xml_stroke(oONK_SL,"STAD",lstr(onksl->STAD))
        mo_add_xml_stroke(oONK_SL,"ONK_T",lstr(onksl->ONK_T))
        mo_add_xml_stroke(oONK_SL,"ONK_N",lstr(onksl->ONK_N))
        mo_add_xml_stroke(oONK_SL,"ONK_M",lstr(onksl->ONK_M))
        if between(onksl->DS1_T,1,2) .and. onksl->MTSTZ == 1
          mo_add_xml_stroke(oONK_SL,"MTSTZ",lstr(onksl->MTSTZ))
        endif
        for j := 1 to len(arr_onkdi)
         oDIAG := oONK_SL:Add( HXMLNode():New( "B_DIAG" ) )
          if arr_onkdi[j,2] == 0
            mo_add_xml_stroke(oDIAG,"DIAG_DATE",date2xml(arr_onkdi[j,1]))
          else
            mo_add_xml_stroke(oDIAG,"DIAG_TIP", lstr(arr_onkdi[j,2]))
            mo_add_xml_stroke(oDIAG,"DIAG_CODE",lstr(arr_onkdi[j,3]))
            mo_add_xml_stroke(oDIAG,"DIAG_RSLT",lstr(arr_onkdi[j,4]))
          endif
        next j
        for j := 1 to len(arr_onkpr)
         oPROT := oONK_SL:Add( HXMLNode():New( "B_PROT" ) )
          mo_add_xml_stroke(oPROT,"PROT",lstr(arr_onkpr[j,1]))
          mo_add_xml_stroke(oPROT,"D_PROT",date2xml(arr_onkpr[j,2]))
        next j
        if mvsod > 0
          mo_add_xml_stroke(oONK_SL,"SOD",lstr(mvsod,6,2))
        endif
      endif
    endif
    mo_add_xml_stroke(oSLUCH,"RSLT",lstr(human_->RSLT_NEW))
    if p_tip_reestr == 2 .and. len(arr_nazn) > 0
      oPRESCRIPTION := oSLUCH:Add( HXMLNode():New( "PRESCRIPTION" ) )
      for j := 1 to len(arr_nazn)
       oPRESCRIPTIONS := oPRESCRIPTION:Add( HXMLNode():New( "PRESCRIPTIONS" ) )
        if version_3_1
          mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_N",lstr(j))
          mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_R",lstr(arr_nazn[j,1]))
        else
          mo_add_xml_stroke(oPRESCRIPTIONS,"NAZR",lstr(arr_nazn[j,1]))
        endif
        if eq_any(arr_nazn[j,1],1,2)
          for i := 1 to len(arr_nazn[j,2])
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SP",lstr(arr_nazn[j,2,i]))
          next
        elseif arr_nazn[j,1] == 3
          for i := 1 to len(arr_nazn[j,2])
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_V",lstr(arr_nazn[j,2,i]))
          next
        elseif eq_any(arr_nazn[j,1],4,5)
          mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PMP",lstr(arr_nazn[j,2]))
        elseif arr_nazn[j,1] == 6
          mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PK",lstr(arr_nazn[j,2]))
        endif
      next
    endif
    mo_add_xml_stroke(oSLUCH,"ISHOD",lstr(human_->ISHOD_NEW))
    mo_add_xml_stroke(oSLUCH,"PRVS",put_prvs_to_reestr(human_->PRVS,_NYEAR))
    if p_tip_reestr == 1 .and. ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
      mo_add_xml_stroke(oSLUCH,"IDDOKT","0")
    else
      p2->(dbGoto(human_->vrach))
      mo_add_xml_stroke(oSLUCH,"IDDOKT",p2->snils)
    endif
    mo_add_xml_stroke(oSLUCH,"IDSP"    ,lstr(human_->IDSP))
    if is_zak_sl .or. is_zak_sl_vr
      mo_add_xml_stroke(oSLUCH,"ED_COL",'1')
      mo_add_xml_stroke(oSLUCH,"TARIF" ,lstr(tarif_zak_sl,10,2))
    endif
    mo_add_xml_stroke(oSLUCH,"SUMV"    ,lstr(human->cena_1,10,2))
    if p_tip_reestr == 1
      if _nyear > 2017 .and. !empty(human_2->pc3) .and. !left(human_2->pc3,1) == '6' // кроме "старости"
        mo_add_xml_stroke(oSLUCH,"AD_CRITERION",human_2->pc3)
        /*if fl_2_14
          select V024
          find (human_2->pc3)
          if found()
            mo_add_xml_stroke(oSLUCH,"DKK2",human_2->pc3)
          endif
        endif*/
      endif
      if !empty(akslp)
        mo_add_xml_stroke(oSLUCH,"IT_SL",lstr(akslp[2],4,2))
      endif
      if _nyear > 2017 .and. !empty(akiro)
        oSL := oSLUCH:Add( HXMLNode():New( "S_KIRO" ) )
         mo_add_xml_stroke(oSL,"CODE_KIRO",lstr(akiro[1]))
         mo_add_xml_stroke(oSL,"VAL_K",lstr(akiro[2],4,2))
      endif
      if !empty(ldate_next)
        mo_add_xml_stroke(oSLUCH,"NEXT_VISIT",date2xml(bom(ldate_next)))
      endif
    endif
    if !is_zak_sl
      for j := 1 to len(a_usl)
        select HU
        goto (a_usl[j])
        hu_->(G_RLock(forever))
        hu_->REES_ZAP := ++iusl
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
        oUSL := oSLUCH:Add( HXMLNode():New( "USL" ) )
        mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(hu_->REES_ZAP))
        mo_add_xml_stroke(oUSL,"ID_U"    ,hu_->ID_U)
        if hu->is_edit == 1 // гематологические исследования
          mo_add_xml_stroke(oUSL,"LPU"   ,'125901') // т.е. иссл-ие проводится в КДП №2
        elseif lshifr == "4.20.2" // жидкостная цитология
          mo_add_xml_stroke(oUSL,"LPU"   ,'103001') // т.е. иссл-ие проводится в онкологии
        else
          mo_add_xml_stroke(oUSL,"LPU"   ,CODE_LPU)
        endif
        if p_tip_reestr == 1
          if human_->USL_OK == 1 .and. is_otd_dep .and. _NYEAR > 2017
            otd->(dbGoto(hu->OTD))
            f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
            if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
              i := 1
            endif
            mo_add_xml_stroke(oUSL,"LPU_1",lstr(mm_otd_dep[i,3]))
            mo_add_xml_stroke(oUSL,"PODR" ,lstr(glob_otd_dep))
          elseif hu->KOL_RCP < 0 .and. DomUslugaTFOMS(lshifr)
            mo_add_xml_stroke(oUSL,"PODR",'0')
          endif
        endif
        mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(hu_->PROFIL))
        if p_tip_reestr == 1
          mo_add_xml_stroke(oUSL,"DET"   ,iif(human->VZROS_REB==0,'0','1'))
        endif
        mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(c4tod(hu->DATE_U)))
        mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(c4tod(hu_->DATE_U2)))
        if p_tip_reestr == 1
          mo_add_xml_stroke(oUSL,"DS"    ,hu_->kod_diag)
        else
          mo_add_xml_stroke(oUSL,"P_OTK" ,'0')
        endif
        mo_add_xml_stroke(oUSL,"CODE_USL",lshifr)
        mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(hu->KOL_1,6,2))
        mo_add_xml_stroke(oUSL,"TARIF"   ,lstr(hu->U_CENA,10,2))
        mo_add_xml_stroke(oUSL,"SUMV_USL",lstr(hu->STOIM_1,10,2))
        mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(hu_->PRVS,_NYEAR))
        if c4tod(hu->DATE_U) < human->n_data ; // если сделано ранее
                       .or. eq_any(hu->is_edit,-1,1) .or. lshifr == "4.20.2" // не заполняется код врача
          mo_add_xml_stroke(oUSL,"CODE_MD",'0')
        else
          p2->(dbGoto(hu->kod_vr))
          mo_add_xml_stroke(oUSL,"CODE_MD" ,p2->snils)
        endif
      next
    endif
    if p_tip_reestr == 2 .and. len(a_otkaz) > 0 // отказы (диспансеризация или профосмоты несовешеннолетних)
      for j := 1 to len(a_otkaz)
        oUSL := oSLUCH:Add( HXMLNode():New( "USL" ) )
        mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(++iusl))
        mo_add_xml_stroke(oUSL,"ID_U"    ,mo_guid(3,iusl))
        mo_add_xml_stroke(oUSL,"LPU"     ,CODE_LPU)
        mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(a_otkaz[j,4]))
        mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(a_otkaz[j,3]))
        mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(a_otkaz[j,3]))
        mo_add_xml_stroke(oUSL,"P_OTK"   ,lstr(a_otkaz[j,7]))
        mo_add_xml_stroke(oUSL,"CODE_USL",a_otkaz[j,1])
        mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(1,6,2))
        mo_add_xml_stroke(oUSL,"TARIF"   ,lstr(a_otkaz[j,6],10,2))
        mo_add_xml_stroke(oUSL,"SUMV_USL",lstr(a_otkaz[j,6],10,2))
        mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(a_otkaz[j,5],_NYEAR))
        mo_add_xml_stroke(oUSL,"CODE_MD" ,'0') // отказ => 0
      next
    endif
    if p_tip_reestr == 1 .and. len(a_fusl) > 0 // добавляем операции
      for j := 1 to len(a_fusl)
        select MOHU
        goto (a_fusl[j])
        mohu->(G_RLock(forever))
        mohu->REES_ZAP := ++iusl
        lshifr := alltrim(mosu->shifr1)
        oUSL := oSLUCH:Add( HXMLNode():New( "USL" ) )
        mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(mohu->REES_ZAP))
        mo_add_xml_stroke(oUSL,"ID_U"    ,mohu->ID_U)
        mo_add_xml_stroke(oUSL,"LPU"     ,CODE_LPU)
        if human_->USL_OK == 1 .and. is_otd_dep .and. _NYEAR > 2017
          otd->(dbGoto(hu->OTD))
          f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
          if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
            i := 1
          endif
          mo_add_xml_stroke(oUSL,"LPU_1",lstr(mm_otd_dep[i,3]))
          mo_add_xml_stroke(oUSL,"PODR" ,lstr(glob_otd_dep))
        endif
        mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(mohu->PROFIL))
        mo_add_xml_stroke(oUSL,"VID_VME",lshifr)
        mo_add_xml_stroke(oUSL,"DET"     ,iif(human->VZROS_REB==0,'0','1'))
        mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(c4tod(mohu->DATE_U)))
        mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(c4tod(mohu->DATE_U2)))
        mo_add_xml_stroke(oUSL,"DS"      ,mohu->kod_diag)
        mo_add_xml_stroke(oUSL,"CODE_USL",lshifr)
        mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(mohu->KOL_1,6,2))
        mo_add_xml_stroke(oUSL,"TARIF"   ,'0')//lstr(mohu->U_CENA,10,2))
        mo_add_xml_stroke(oUSL,"SUMV_USL",'0')//lstr(mohu->STOIM_1,10,2))
        mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(mohu->PRVS,_NYEAR))
        if is_telemedicina(lshifr) // не заполняется код врача
          mo_add_xml_stroke(oUSL,"CODE_MD",'0')
        else
          p2->(dbGoto(mohu->kod_vr))
          mo_add_xml_stroke(oUSL,"CODE_MD" ,p2->snils)
        endif
        if is_oncology == 2 .and. mohu->USL_TIP > 0 .and. human_->USL_OK < 3
         oONK := oUSL:Add( HXMLNode():New( "ONK_USL" ) )
          mo_add_xml_stroke(oONK,"USL_TIP",lstr(iif(mohu->USL_TIP==9,0,mohu->USL_TIP)))
          if mohu->USL_TIP == 1
            mo_add_xml_stroke(oONK,"HIR_TIP",lstr(mohu->HIR_TIP))
          endif
          if mohu->USL_TIP == 2
            mo_add_xml_stroke(oONK,"LEK_TIP_L",lstr(mohu->LEK_TIP_L))
            mo_add_xml_stroke(oONK,"LEK_TIP_V",lstr(mohu->LEK_TIP_V))
          endif
          if eq_any(mohu->USL_TIP,3,4)
            mo_add_xml_stroke(oONK,"LUCH_TIP",lstr(mohu->LUCH_TIP))
          endif
        endif
      next
    endif
    if p_tip_reestr == 1 .and. !empty(akslp)
      oSL := oSLUCH:Add( HXMLNode():New( "SL_KOEFF" ) )
       oCOEFF := oSL:Add( HXMLNode():New( "COEFF" ) )
        mo_add_xml_stroke(oCOEFF,"CODE_SL",lstr(akslp[1]))
        mo_add_xml_stroke(oCOEFF,"VAL_C",lstr(akslp[2],4,2))
    endif
    j := 0 ; fl := .f.
    if p_tip_reestr == 1
      if (ibrm := f_oms_beremenn(mdiagnoz[1])) == 1 .and. eq_any(human_->profil,136,137) // акушерству и гинекологии
        j := iif(human_2->pn2 == 1, 4, 3)
      elseif ibrm == 2 .and. human_->USL_OK == 3 // поликлиника
        j := iif(human_2->pn2 == 1, 5, 6)
        if j == 5 .and. !eq_any(human_->profil,136,137)
          j := 6  // т.е. только акушер-гинеколог может поставить на учёт по беременности
        endif
      elseif ibrm == 3 .and. human->K_DATA > stod("20170619") // основной диагноз - онкология с 20 июня
        j := iif(human_2->pn2 == 1, 8, 7)
      endif
    elseif p_tip_reestr == 2
      if between(human->ishod,201,205) // ДВН
        j := iif(human->RAB_NERAB==0,20,iif(human->RAB_NERAB==1,10,14))
        if human->ishod != 203 .and. m1veteran == 1
          j := iif(human->RAB_NERAB==0, 21, 11)
        endif
      elseif between(human->ishod,301,302) .and. human->K_DATA >= d_01_05_2018
        j := iif(between(m1mesto_prov,0,1), m1mesto_prov, 0)
        fl := .t.
      endif
    elseif v_reabil_slux > 0
      j := v_reabil_slux - 1
    endif
    if j > 0 .or. fl
      mo_add_xml_stroke(oSLUCH,"COMENTSL",lstr(j))
    endif
  select RHUM
  if rhum->REES_ZAP % 2000 == 0
    dbUnlockAll()
    dbCommitAll()
  endif
  skip
enddo
dbUnlockAll()
dbCommitAll()
stat_msg("Запись XML-файла реестра случаев")
oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
name_zip := alltrim(mo_xml->FNAME)+szip
aadd(arr_zip, alltrim(mo_xml->FNAME)+sxml)
//
stat_msg("Составление реестра пациентов")
oXmlDoc := HXMLDoc():New()
oXmlDoc:Add( HXMLNode():New( "PERS_LIST") )
 oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
  mo_add_xml_stroke(oXmlNode,"VERSION" ,'2.12')
  mo_add_xml_stroke(oXmlNode,"DATA"     ,date2xml(rees->DSCHET))
  mo_add_xml_stroke(oXmlNode,"FILENAME" ,mo_xml->FNAME2)
  mo_add_xml_stroke(oXmlNode,"FILENAME1",mo_xml->FNAME)
select RHUM
go top
do while !eof()
  @ maxrow(),0 say str(rhum->REES_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
  arr_fio := retFamImOt(2,.f.)
  oPAC := oXmlDoc:aItems[1]:Add( HXMLNode():New( "PERS" ) )
  mo_add_xml_stroke(oPAC,"ID_PAC" ,human_->ID_PAC)
  if human_->NOVOR == 0
    mo_add_xml_stroke(oPAC,"FAM"  ,arr_fio[1])
    mo_add_xml_stroke(oPAC,"IM"   ,arr_fio[2])
    if !empty(arr_fio[3])
      mo_add_xml_stroke(oPAC,"OT" ,arr_fio[3])
    endif
    mo_add_xml_stroke(oPAC,"W"    ,iif(human->pol=="М",'1','2'))
    mo_add_xml_stroke(oPAC,"DR"   ,date2xml(human->date_r))
    if empty(arr_fio[3])
      mo_add_xml_stroke(oPAC,"DOST",'1') // отсутствует отчество
    endif
    if p_tip_reestr == 2 // Указывается только для диспансеризации при предоставлении сведений
      if     len(alltrim(kart_->PHONE_H)) == 11
        mo_add_xml_stroke(oPAC,"TEL",substr(kart_->PHONE_H,2))
      elseif len(alltrim(kart_->PHONE_M)) == 11
        mo_add_xml_stroke(oPAC,"TEL",substr(kart_->PHONE_M,2))
      elseif len(alltrim(kart_->PHONE_W)) == 11
        mo_add_xml_stroke(oPAC,"TEL",substr(kart_->PHONE_W,2))
      endif
    endif
  else
    mo_add_xml_stroke(oPAC,"W"    ,iif(human_->pol2=="М",'1','2'))
    mo_add_xml_stroke(oPAC,"DR"   ,date2xml(human_->date_r2))
    mo_add_xml_stroke(oPAC,"FAM_P",arr_fio[1])
    mo_add_xml_stroke(oPAC,"IM_P" ,arr_fio[2])
    if !empty(arr_fio[3])
      mo_add_xml_stroke(oPAC,"OT_P",arr_fio[3])
    endif
    mo_add_xml_stroke(oPAC,"W_P"  ,iif(human->pol=="М",'1','2'))
    mo_add_xml_stroke(oPAC,"DR_P" ,date2xml(human->date_r))
    if empty(arr_fio[3])
      mo_add_xml_stroke(oPAC,"DOST_P",'1') // отсутствует отчество
    endif
  endif
  if !empty(smr := del_spec_symbol(kart_->mesto_r))
    mo_add_xml_stroke(oPAC,"MR",smr)
  endif
  if human_->vpolis == 3 .and. emptyany(kart_->nom_ud,kart_->nom_ud)
    // для нового полиса паспорт необязателен
  else
    mo_add_xml_stroke(oPAC,"DOCTYPE",lstr(kart_->vid_ud))
    if !empty(kart_->ser_ud)
      mo_add_xml_stroke(oPAC,"DOCSER",kart_->ser_ud)
    endif
    mo_add_xml_stroke(oPAC,"DOCNUM",kart_->nom_ud)
  endif
  if !empty(kart->snils)
    mo_add_xml_stroke(oPAC,"SNILS",transform(kart->SNILS,picture_pf))
  endif
  if human_->vpolis == 3 .and. empty(kart_->okatog)
    // для нового полиса место регистрации необязательно
  else
    mo_add_xml_stroke(oPAC,"OKATOG" ,kart_->okatog)
  endif
  if len(alltrim(kart_->okatop)) == 11
    mo_add_xml_stroke(oPAC,"OKATOP",kart_->okatop)
  endif
  select RHUM
  skip
enddo
stat_msg("Запись XML-файла реестра пациентов")
oXmlDoc:Save(alltrim(mo_xml->FNAME2)+sxml)
aadd(arr_zip, alltrim(mo_xml->FNAME2)+sxml)
//
close databases
if chip_create_zipXML(name_zip,arr_zip,.t.)
  keyboard chr(K_TAB)+chr(K_ENTER)
endif
return NIL

***** 28.08.18 создать счета по результатам прочитанного реестра СП
Function create_schet17_from_XML(arr_XML_info,aerr,fl_msg,arr_s,name_sp_tk)
Local arr_schet := {}, c, len_stand, _arr_stand, lshifr, i, j, k, lbukva,;
      doplataF, doplataR, mnn, fl, name_zip, arr_zip := {}, lshifr1,;
      CODE_LPU := glob_mo[_MO_KOD_TFOMS], code_schet, mb, me, nsh,;
      CODE_MO  := glob_mo[_MO_KOD_FFOMS], s1
DEFAULT fl_msg TO .t., arr_s TO {}
Private pole
//
use (cur_dir+"tmp1file") new alias TMP1
mdate_schet := tmp1->_DSCHET
nsh := f_mb_me_nsh(tmp1->_year,@mb,@me)
// составляем массив будущих счетов
// открыть распакованный реестр
use (cur_dir+"tmp_r_t1") new index (cur_dir+"tmpt1") alias T1
use (cur_dir+"tmp_r_t2") new index (cur_dir+"tmpt2") alias T2
use (cur_dir+"tmp_r_t3") new index (cur_dir+"tmpt3") alias T3
use (cur_dir+"tmp_r_t4") new index (cur_dir+"tmpt4") alias T4
use (cur_dir+"tmp_r_t5") new index (cur_dir+"tmpt5") alias T5
use (cur_dir+"tmp_r_t6") new index (cur_dir+"tmpt6") alias T6
use (cur_dir+"tmp_r_t7") new index (cur_dir+"tmpt7") alias T7
use (cur_dir+"tmp_r_t8") new index (cur_dir+"tmpt8") alias T8
R_Use(dir_server+"mo_pers",,"PERS")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
G_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to recno() into HU_, to u_kod into USL
R_Use(dir_server+"mo_su",,"MOSU")
G_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
G_Use(dir_server+"mo_xml",,"MO_XML")
use_base("human")
set order to 0
set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
use (cur_dir+"tmp2file") new alias TMP2
set relation to kod_human into HUMAN
index on upper(human->fio) to (cur_dir+"tmp2") for _OPLATA == 1
go top
do while !eof()
  c := " "
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    lbukva := " "
    if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,@lbukva)
      lshifr1 := iif(empty(lshifr1), usl->shifr, lshifr1)
      if hu->STOIM_1 > 0 .or. left(lshifr1,3) == "71."  // скорая помощь
        if !empty(lbukva)
          c := lbukva
          exit
        endif
      endif
    endif
    select HU
    skip
  enddo
  if type("pr_array_schet") == "A" .and. empty(c)
    c := "A"   // искусственно для экспорта из чужих БД случаев с отсутствующими услугами
  endif
  if empty(c)
    s := alltrim(human->fio)+" - не найдена буква счёта"
    aadd(aerr,s)
    close databases
    return func_error(4,s)
  else
    tmp2->SCHET_CHAR := c
  endif
  if (i := ascan(arr_schet, {|x| x[1]==tmp2->_SMO .and. x[2]==tmp2->SCHET_CHAR})) == 0
    aadd(arr_schet, {tmp2->_SMO,tmp2->SCHET_CHAR,0,0,0,0,0,0,0,0})
    i := len(arr_schet)
  endif
  arr_schet[i,3] ++
  arr_schet[i,4] += human->cena_1
  arr_schet[i,8] := 0 // сюда запишем код счёта
  arr_schet[i,9] := 0 // сюда запишем номер пакета
  arr_schet[i,10] := 0 // сюда запишем индекс массива pr_array_schet
  tmp2->SCHET_ZAP := arr_schet[i,3]
  tmp2->SCHET := i
  //
  select TMP2
  skip
enddo
if type("pr_array_schet") == "A"
  for ii := 1 to len(arr_schet)
    fl := .f.
    mn_schet := alltrim(arr_schet[ii,1])+"-"+alltrim(tmp1->_NSCHET)+arr_schet[ii,2]
    if (i := ascan(pr_array_schet, {|x| alltrim(x[3])==mn_schet .and. x[6]==tmp1->_year})) > 0
      arr_schet[ii,9] := pr_array_schet[i,2] // сюда запишем номер пакета
      arr_schet[ii,10] := i
    endif
    if arr_schet[ii,10] == 0
      my_debug(,lstr(tmp1->_year)+"/"+strzero(tmp1->_month,2)+" не найден счёт "+mn_schet)
    else
      i := arr_schet[ii,10]
      s := lstr(tmp1->_year)+"/"+strzero(tmp1->_month,2)+" "+padr(mn_schet,15)
      s += "max: "+lstr(pr_array_schet[i,8])
      if pr_array_schet[i,8] == arr_schet[ii,3]
        s += " = "
        s1 := "+"
      else
        s += " != "
        s1 := "-"
        fl := .t.
      endif
      s += lstr(arr_schet[ii,3])+", кол: "+lstr(pr_array_schet[i,7])
      if pr_array_schet[i,7] == arr_schet[ii,3]
        s += " = "
        s1 += "+"
      else
        s += " != "
        s1 += "-"
        fl := .t.
      endif
      s += lstr(arr_schet[ii,3])+", сум: "+lstr(pr_array_schet[i,5],13,2)
      if round(pr_array_schet[i,5],2) == round(arr_schet[ii,4],2)
        s += " = "
        s1 += "+"
      else
        s += " != "
        s1 += "-"
        fl := .t.
      endif
      s += lstr(arr_schet[ii,4],13,2)
      my_debug(,s1+s)
    endif
    if arr_schet[ii,10] > 0 // счёт найден в "pr_array_schet"
      i := arr_schet[ii,10]
      arr_schet[ii,3] := arr_schet[ii,4] := 0
      select TMP2
      index on upper(_ID_C) to (cur_dir+"tmp2") for schet == ii
      dbeval({|| tmp2->SCHET_ZAP := 0 }) // обнуляем номер позиции в счёте
      use (cur_dir+"tmp_s_id") new alias TS
      index on NIDCASE to (cur_dir+"tmp_ts") for kod == pr_array_schet[i,11]
      go top
      do while !eof()
        select TMP2
        find (upper(ts->ID_C))
        if found()
          tmp2->SCHET_ZAP := ts->NIDCASE
          human->(dbGoto(tmp2->kod_human))
          arr_schet[ii,3] ++
          arr_schet[ii,4] += human->cena_1
        else
          my_debug(,"в счёте не найден пациент с GUID "+ts->ID_C)
          my_debug(,"└─>"+print_array(pr_array_schet[i]))
        endif
        select TS
        skip
      enddo
      ts->(dbCloseArea())
      if fl .or. !(pr_array_schet[i,8] == arr_schet[ii,3] .and. ;
                   pr_array_schet[i,7] == arr_schet[ii,3] .and. ;
                   round(pr_array_schet[i,5],2) == round(arr_schet[ii,4],2))
        if fl
          my_debug(,"после исправления:")
        else
          my_debug(,"что-то случилось:")
        endif
        s := lstr(tmp1->_year)+"/"+strzero(tmp1->_month,2)+" "+padr(mn_schet,15)
        s += "max: "+lstr(pr_array_schet[i,8])
        if pr_array_schet[i,8] == arr_schet[ii,3]
          s += " = "
          s1 := "+"
        else
          s += " != "
          s1 := "-"
        endif
        s += lstr(arr_schet[ii,3])+", кол: "+lstr(pr_array_schet[i,7])
        if pr_array_schet[i,7] == arr_schet[ii,3]
          s += " = "
          s1 += "+"
        else
          s += " != "
          s1 += "-"
        endif
        s += lstr(arr_schet[ii,3])+", сум: "+lstr(pr_array_schet[i,5],13,2)
        if round(pr_array_schet[i,5],2) == round(arr_schet[ii,4],2)
          s += " = "
          s1 += "+"
        else
          s += " != "
          s1 += "-"
        endif
        s += lstr(arr_schet[ii,4],13,2)
        my_debug(,s1+s)
      endif
    endif
  next
endif
R_Use(dir_server+"schet_",,"SCH")
index on smo+str(nn,nsh) to (cur_dir+"tmp_sch") for nyear == tmp1->_YEAR .and. nmonth == tmp1->_MONTH
fl := .f.
for i := 1 to len(arr_schet)
  fl := .f. ; sKodSMO := arr_schet[i,1]
  if arr_schet[i,9] > 0
    find (sKodSMO+str(arr_schet[i,9],nsh))
    if found() // номер уже занят
      arr_schet[i,9] := 0
    endif
  endif
  fl := (arr_schet[i,9] > 0)
  if !fl
    for mnn := mb to me
      if ascan(arr_schet, {|x| x[1] == sKodSMO .and. x[9] == mnn}) == 0
        find (sKodSMO+str(mnn,nsh))
        if !found() // нашли свободный номер
          fl := .t. ; arr_schet[i,9] := mnn ; exit
        endif
      endif
    next
  endif
  if !fl ; exit ; endif
next
if !fl
  close databases
  s := "Не удалось найти свободный номер пакета в ТФОМС. Проверьте настройки!"
  aadd(aerr,s)
  return func_error(4,s)
endif
sch->(dbCloseArea())
use_base("schet")
set relation to
// определим дату счёта, чтобы она не была раньше даты чтения реестра в ТФОМС
mdate_schet := max(mdate_schet,sys_date)
strfile(space(10)+"Список составленных счетов:"+hb_eol(),cFileProtokol,.t.)
select TMP2
index on str(schet,6)+str(schet_zap,6) to (cur_dir+"tmp2") for schet_zap > 0
for ii := 1 to len(arr_schet)
  mnn := arr_schet[ii,9]
  sKodSMO := alltrim(arr_schet[ii,1])
  s := "M"+CODE_LPU+iif(sKodSMO=='34',"T","S")+sKodSMO+"_"+;
       right(strzero(tmp1->_YEAR,4),2)+strzero(tmp1->_MONTH,2)+;
       strzero(mnn,nsh)
  mn_schet := sKodSMO+"-"+alltrim(tmp1->_NSCHET)+arr_schet[ii,2]
  stat_msg("Составление реестра случаев по счёту № "+mn_schet)
  //
  c := upper(left(name_sp_tk,1)) // {"H","F"}[p_tip_reestr]+s
  p_tip_reestr := iif(c == "H", 1, 2)
  select SCHET
  AddRec(6)
  arr_schet[ii,8] := mkod := recno()
  schet->KOD := mkod
  schet->NOMER_S := mn_schet
  aadd(arr_s,mn_schet)
  schet->PDATE := dtoc4(mdate_schet)
  schet->KOL   := arr_schet[ii,3]
  schet->SUMMA := arr_schet[ii,4]
  schet->KOL_OST   := arr_schet[ii,3]
  schet->SUMMA_OST := arr_schet[ii,4]
  //
  select SCHET_
  do while schet_->(lastrec()) < mkod
    APPEND BLANK
  enddo
  goto (mkod)
  G_RLock(forever)
  schet_->IFIN       := 1 // источник финансирования;1-ТФОМС(СМО)
  schet_->IS_MODERN  := 0 // является модернизацией, 0-нет
  schet_->IS_DOPLATA := 0 // является доплатой;0-нет
  schet_->BUKVA      := arr_schet[ii,2]
  schet_->NSCHET     := mn_schet
  schet_->DSCHET     := mdate_schet
  schet_->SMO        := sKodSMO
  schet_->NYEAR      := tmp1->_YEAR
  schet_->NMONTH     := tmp1->_MONTH
  schet_->NN         := mnn
  schet_->NAME_XML   := c+s // {"H","F"}[p_tip_reestr]+s
  schet_->XML_REESTR := mXML_REESTR
  schet_->NREGISTR   := 1 // ещё не зарегистрирован
  schet_->CODE := ret_unique_code(mkod,12)
  code_schet := schet_->code
  //
  select MO_XML
  AddRecN()
  mo_xml->KOD    := recno()
  mo_xml->FNAME  := c+s
  mo_xml->FNAME2 := "L"+s
  mo_xml->DFILE  := schet_->DSCHET
  mo_xml->TFILE  := hour_min(seconds())
  mo_xml->TIP_OUT := _XML_FILE_SCHET  // тип высылаемого файла;2-счет
  mo_xml->SCHET   := mkod  // код счета (отсылаемого или обработанного СМО)
  //
  schet_->KOD_XML := mo_xml->KOD
  UnLock
  //
  strfile(lstr(ii)+". "+mn_schet+" от "+date_8(mdate_schet)+" ("+;
          lstr(arr_schet[ii,3])+" чел.) "+;
          inieditspr(A__MENUVERT,glob_arr_smo,int(val(sKodSMO)))+;
          hb_eol(),cFileProtokol,.t.)
  //
  oXmlDoc := HXMLDoc():New()
  oXmlDoc:Add( HXMLNode():New( "ZL_LIST") )
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
    if tmp1->_YEAR > 2018 .or. (tmp1->_YEAR == 2018 .and. tmp1->_MONTH >= 9) // с сентября 2018 года
      s := '3.1'
    else
      s := '2.12'
      if c == "H"
        if tmp1->_YEAR > 2017
          s := '2.13'
          if tmp1->_YEAR == 2018 .and. tmp1->_MONTH >= 5 // с мая 2018 года
            s := '2.14'
          endif
        endif
      endif
    endif
    mo_add_xml_stroke(oXmlNode,"VERSION" ,s)
    mo_add_xml_stroke(oXmlNode,"DATA"    ,date2xml(schet_->DSCHET))
    mo_add_xml_stroke(oXmlNode,"FILENAME",mo_xml->FNAME)
    mo_add_xml_stroke(oXmlNode,"SD_Z"    ,lstr(arr_schet[ii,3])) // новое поле
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "SCHET" ) )
    mo_add_xml_stroke(oXmlNode,"CODE"   ,lstr(code_schet))
    mo_add_xml_stroke(oXmlNode,"CODE_MO",CODE_MO)
    mo_add_xml_stroke(oXmlNode,"YEAR"   ,lstr(tmp1->_YEAR ))
    mo_add_xml_stroke(oXmlNode,"MONTH"  ,lstr(tmp1->_MONTH))
    mo_add_xml_stroke(oXmlNode,"NSCHET" ,mn_schet)
    mo_add_xml_stroke(oXmlNode,"DSCHET" ,date2xml(schet_->DSCHET))
    mo_add_xml_stroke(oXmlNode,"PLAT"   ,schet_->SMO)
    mo_add_xml_stroke(oXmlNode,"SUMMAV" ,str(schet->SUMMA,15,2))
  // запись номера счета по больным
  iidserv := 0
  select TMP2
  find (str(ii,6))
  do while tmp2->schet==ii .and. !eof()
    @ maxrow(),0 say str(tmp2->schet_zap/arr_schet[ii,3]*100,6,2)+"%" color cColorSt2Msg
    human->(G_RLock(forever))
    human->schet := mkod ; human->tip_h := B_SCHET
    human_->(G_RLock(forever))
    human_->schet_zap := tmp2->schet_zap
    if human_->SCHET_NUM < 99
      human_->SCHET_NUM := human_->SCHET_NUM+1
    endif
    UnLock
    //
    select T1
    find (str(tmp2->_N_ZAP,6))
    if found() // нашли в отосланном реестре
      a_usl := {}
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        if is_usluga_TFOMS(usl->shifr,opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data),human->k_data)
          aadd(a_usl,{hu->(recno()),hu_->REES_ZAP})
        endif
        select HU
        skip
      enddo
      a_fusl := {}
      select MOHU
      find (str(human->kod,7))
      do while mohu->kod == human->kod .and. !eof()
        aadd(a_fusl,{mohu->(recno()),mohu->REES_ZAP})
        skip
      enddo
      oZAP := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZAP" ) )
       mo_add_xml_stroke(oZAP,"N_ZAP" ,lstr(human_->schet_zap))
       mo_add_xml_stroke(oZAP,"PR_NOV",t1->PR_NOV) // по версии 2.12
       oPAC := oZAP:Add( HXMLNode():New( "PACIENT" ) )
        mo_add_xml_stroke(oPAC,"ID_PAC",t1->ID_PAC)
        mo_add_xml_stroke(oPAC,"VPOLIS",t1->VPOLIS)
        if !empty(t1->SPOLIS)
          mo_add_xml_stroke(oPAC,"SPOLIS",t1->SPOLIS)
        endif
        mo_add_xml_stroke(oPAC,"NPOLIS",t1->NPOLIS)
        if !empty(t1->ENP)
          mo_add_xml_stroke(oPAC,"ENP",t1->ENP)
        endif
        mo_add_xml_stroke(oPAC,"SMO"   ,t1->smo)
        mo_add_xml_stroke(oPAC,"SMO_OK",t1->SMO_OK)
        mo_add_xml_stroke(oPAC,"NOVOR",t1->NOVOR)
        mo_add_xml_stroke(oPAC,"MO_PR",t1->MO_PR)
        if !empty(t1->VNOV_D)
          mo_add_xml_stroke(oPAC,"VNOV_D",t1->VNOV_D)
        endif
        if !empty(t1->INV) // Сведения о первичном признании застрахованного лица инвалидом
         oDISAB := oPAC:Add( HXMLNode():New( "DISABILITY" ) )
          mo_add_xml_stroke(oDISAB,"INV",t1->INV)
          mo_add_xml_stroke(oDISAB,"DATA_INV",t1->DATA_INV)
          mo_add_xml_stroke(oDISAB,"REASON_INV",t1->REASON_INV)
         if !empty(t1->DS_INV)
          mo_add_xml_stroke(oDISAB,"DS_INV",t1->DS_INV)
         endif
        endif
       oSLUCH := oZAP:Add( HXMLNode():New( "SLUCH" ) )
        mo_add_xml_stroke(oSLUCH,"IDCASE",lstr(human_->schet_zap))
        mo_add_xml_stroke(oSLUCH,"ID_C"  ,t1->ID_C)
        if !empty(t1->DISP)
          mo_add_xml_stroke(oSLUCH,"DISP",t1->DISP) // Тип диспансеризации
        endif
        mo_add_xml_stroke(oSLUCH,"USL_OK",t1->USL_OK)
        mo_add_xml_stroke(oSLUCH,"VIDPOM",t1->VIDPOM)
        if !empty(t1->FOR_POM)
          mo_add_xml_stroke(oSLUCH,"FOR_POM",t1->FOR_POM)
        endif
        if !empty(t1->VID_HMP)
          mo_add_xml_stroke(oSLUCH,"VID_HMP",t1->VID_HMP)
        endif
        if !empty(t1->METOD_HMP)
          mo_add_xml_stroke(oSLUCH,"METOD_HMP",t1->METOD_HMP)
        endif
        if !empty(t1->F_SP)
          mo_add_xml_stroke(oSLUCH,"F_SP",t1->F_SP)
        endif
        if !empty(t1->NPR_MO)
          mo_add_xml_stroke(oSLUCH,"NPR_MO",t1->NPR_MO)
        endif
        if !empty(t1->NPR_DATE)
          mo_add_xml_stroke(oSLUCH,"NPR_DATE",t1->NPR_DATE)
        endif
        if !empty(t1->EXTR)
          mo_add_xml_stroke(oSLUCH,"EXTR",t1->EXTR)
        endif
        mo_add_xml_stroke(oSLUCH,"LPU",t1->LPU)
        if !empty(t1->LPU_1)
          mo_add_xml_stroke(oSLUCH,"LPU_1",t1->LPU_1)
        endif
        if !empty(t1->PODR)
          mo_add_xml_stroke(oSLUCH,"PODR",t1->PODR)
        endif
        mo_add_xml_stroke(oSLUCH,"PROFIL",t1->PROFIL)
        if !empty(t1->PROFIL_K)
          mo_add_xml_stroke(oSLUCH,"PROFIL_K",t1->PROFIL_K)
        endif
        if !empty(t1->DET)
          mo_add_xml_stroke(oSLUCH,"DET",t1->DET)
        endif
        if !empty(t1->P_CEL)
          mo_add_xml_stroke(oSLUCH,"P_CEL",t1->P_CEL)
        endif
        if !empty(t1->VBR)
          mo_add_xml_stroke(oSLUCH,"VBR"     ,t1->VBR)
        endif
        if !empty(t1->TAL_D)
          mo_add_xml_stroke(oSLUCH,"TAL_D"   ,t1->TAL_D)
          mo_add_xml_stroke(oSLUCH,"TAL_P"   ,t1->TAL_P)
          if !empty(t1->TAL_NUM)
            mo_add_xml_stroke(oSLUCH,"TAL_NUM",t1->TAL_NUM)
          endif
        endif
        mo_add_xml_stroke(oSLUCH,"NHISTORY",t1->NHISTORY)
        if !empty(t1->P_PER)
          mo_add_xml_stroke(oSLUCH,"P_PER"   ,t1->P_PER)
        endif
        if !empty(t1->P_OTK)
          mo_add_xml_stroke(oSLUCH,"P_OTK"   ,t1->P_OTK)
        endif
        mo_add_xml_stroke(oSLUCH,"DATE_1"  ,t1->DATE_1)
        mo_add_xml_stroke(oSLUCH,"DATE_2"  ,t1->DATE_2)
        if !empty(t1->DS0)
          mo_add_xml_stroke(oSLUCH,"DS0"   ,t1->DS0)
        endif
        mo_add_xml_stroke(oSLUCH,"DS1"     ,t1->DS1)
        if !empty(t1->DS1_PR)
          mo_add_xml_stroke(oSLUCH,"DS1_PR",t1->DS1_PR)
        endif
        if p_tip_reestr == 2 .and. !empty(t1->DS_ONK)
          mo_add_xml_stroke(oSLUCH,"DS_ONK",t1->DS_ONK)
        endif
        if !empty(t1->PR_D_N)
          mo_add_xml_stroke(oSLUCH,"PR_D_N",t1->PR_D_N)
        endif
        for j := 1 to 7
          pole := "t1->DS2"+iif(j==1, "", "_"+lstr(j))
          if !empty(&pole)
            mo_add_xml_stroke(oSLUCH,"DS2",&pole)
          endif
        next
        for j := 1 to 3
          pole := "t1->DS3"+iif(j==1, "", "_"+lstr(j))
          if !empty(&pole)
            mo_add_xml_stroke(oSLUCH,"DS3",&pole)
          endif
        next
        if p_tip_reestr == 1 .and. !empty(t1->DS_ONK)
          mo_add_xml_stroke(oSLUCH,"DS_ONK",t1->DS_ONK)
        endif
        if !empty(t1->C_ZAB)
          mo_add_xml_stroke(oSLUCH,"C_ZAB",t1->C_ZAB)
        endif
        if !empty(t1->DN)
          mo_add_xml_stroke(oSLUCH,"DN",t1->DN)
        endif
        if !empty(t1->MSE)
          mo_add_xml_stroke(oSLUCH,"MSE",t1->MSE)
        endif
        for j := 1 to 3
          pole := "t1->VNOV_M"+iif(j==1, "", "_"+lstr(j))
          if !empty(&pole)
            mo_add_xml_stroke(oSLUCH,"VNOV_M",&pole)
          endif
        next
        for j1 := 1 to 4
          pole := "t1->DS2N"+iif(j1==1, "", "_"+lstr(j1))
          if !empty(&pole)
           oD := oSLUCH:Add( HXMLNode():New( "DS2_N" ) )
            mo_add_xml_stroke(oD,"DS2",&pole)
            pole := "t1->DS2N"+iif(j1==1, "", "_"+lstr(j1))+"_PR"
            if !empty(&pole)
              mo_add_xml_stroke(oD,"DS2_PR",&pole)
            endif
            pole := "t1->DS2N"+iif(j1==1, "", "_"+lstr(j1))+"_D"
            if !empty(&pole)
              mo_add_xml_stroke(oD,"PR_D",&pole)
            endif
          endif
        next
        if !empty(t1->CODE_MES1)
          mo_add_xml_stroke(oSLUCH,"CODE_MES1",t1->CODE_MES1)
        endif
        select T6
        find (t1->IDCASE)
        do while t1->IDCASE == t6->IDCASE .and. !eof()
         oNAPR := oSLUCH:Add( HXMLNode():New( "NAPR" ) )
          mo_add_xml_stroke(oNAPR,"NAPR_DATE",t6->NAPR_DATE)
          mo_add_xml_stroke(oNAPR,"NAPR_V",t6->NAPR_V)
          if int(val(t6->NAPR_V)) == 3
            mo_add_xml_stroke(oNAPR,"MET_ISSL",t6->MET_ISSL)
            mo_add_xml_stroke(oNAPR,"NAPR_USL",t6->U_KOD)
          endif
          skip
        enddo
        if !empty(t1->DS1_T)
         oONK_SL := oSLUCH:Add( HXMLNode():New( "ONK_SL" ) )
          mo_add_xml_stroke(oONK_SL,"DS1_T",t1->DS1_T)
          if !empty(t1->PR_CONS)
           mo_add_xml_stroke(oONK_SL,"PR_CONS",t1->PR_CONS)
           mo_add_xml_stroke(oONK_SL,"DT_CONS",t1->DT_CONS)
          endif
          mo_add_xml_stroke(oONK_SL,"STAD",t1->STAD)
          mo_add_xml_stroke(oONK_SL,"ONK_T",t1->ONK_T)
          mo_add_xml_stroke(oONK_SL,"ONK_N",t1->ONK_N)
          mo_add_xml_stroke(oONK_SL,"ONK_M",t1->ONK_M)
          if !empty(t1->MTSTZ)
           mo_add_xml_stroke(oONK_SL,"MTSTZ",t1->MTSTZ)
          endif
          select T7
          find (t1->IDCASE)
          do while t1->IDCASE == t7->IDCASE .and. !eof()
           oDIAG := oONK_SL:Add( HXMLNode():New( "B_DIAG" ) )
            if !empty(t7->DIAG_DATE)
             mo_add_xml_stroke(oDIAG,"DIAG_DATE",t7->DIAG_DATE)
            else
             mo_add_xml_stroke(oDIAG,"DIAG_TIP", t7->DIAG_TIP)
             mo_add_xml_stroke(oDIAG,"DIAG_CODE",t7->DIAG_CODE)
             mo_add_xml_stroke(oDIAG,"DIAG_RSLT",t7->DIAG_RSLT)
            endif
           skip
          enddo
          select T8
          find (t1->IDCASE)
          do while t1->IDCASE == t8->IDCASE .and. !eof()
           oPROT := oONK_SL:Add( HXMLNode():New( "B_PROT" ) )
            mo_add_xml_stroke(oPROT,"PROT",t8->PROT)
            mo_add_xml_stroke(oPROT,"D_PROT",t8->D_PROT)
           skip
          enddo
          if !empty(t1->SOD)
           mo_add_xml_stroke(oONK_SL,"SOD",t1->SOD)
          endif
        endif
        mo_add_xml_stroke(oSLUCH,"RSLT",t1->RSLT)
        select T5
        find (t1->IDCASE)
        if found()
          oPRESCRIPTION := oSLUCH:Add( HXMLNode():New( "PRESCRIPTION" ) )
          do while t1->IDCASE == t5->IDCASE .and. !eof()
            oPRESCRIPTIONS := oPRESCRIPTION:Add( HXMLNode():New( "PRESCRIPTIONS" ) )
            if !empty(t5->NAZ_N)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_N",t5->NAZ_N)
            endif
            if !empty(t5->NAZ_R)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_R",t5->NAZ_R)
            endif
            if !empty(t5->NAZR)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZR",t5->nazr)
            endif
            for i := 1 to 3
              pole := "t5->NAZ_SP"+lstr(i)
              if !empty(&pole)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SP",&pole)
              endif
            next
            for i := 1 to 3
              pole := "t5->NAZ_V"+lstr(i)
              if !empty(&pole)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_V",&pole)
              endif
            next
            if !empty(t5->NAZ_PMP)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PMP",t5->NAZ_PMP)
            endif
            if !empty(t5->NAZ_PK)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PK",t5->NAZ_PK)
            endif
            select T5
            skip
          enddo
        endif
        mo_add_xml_stroke(oSLUCH,"ISHOD"   ,t1->ISHOD)
        mo_add_xml_stroke(oSLUCH,"PRVS"    ,t1->PRVS)
        if !empty(t1->IDDOKT)
          mo_add_xml_stroke(oSLUCH,"IDDOKT",t1->IDDOKT)
        endif
        if !empty(t1->OS_SLUCH)
          mo_add_xml_stroke(oSLUCH,"OS_SLUCH",t1->OS_SLUCH)
        endif
        mo_add_xml_stroke(oSLUCH,"IDSP"    ,t1->IDSP)
        if !empty(t1->ED_COL)
          mo_add_xml_stroke(oSLUCH,"ED_COL",t1->ED_COL)
          mo_add_xml_stroke(oSLUCH,"TARIF" ,t1->TARIF)
        endif
        mo_add_xml_stroke(oSLUCH,"SUMV"    ,t1->SUMV)
        if !empty(t1->AD_CR)
          mo_add_xml_stroke(oSLUCH,"AD_CRITERION",t1->AD_CR)
          if !empty(t1->DKK2)
            mo_add_xml_stroke(oSLUCH,"DKK2",t1->DKK2)
          endif
        endif
        if !empty(t1->IT_SL)
          mo_add_xml_stroke(oSLUCH,"IT_SL" ,t1->IT_SL)
        endif
        if !empty(t1->CODE_KIRO)
          oSL := oSLUCH:Add( HXMLNode():New( "S_KIRO" ) )
           mo_add_xml_stroke(oSL,"CODE_KIRO",t1->CODE_KIRO)
           mo_add_xml_stroke(oSL,"VAL_K",t1->VAL_K)
        endif
        if !empty(t1->NEXT_VISIT)
          mo_add_xml_stroke(oSLUCH,"NEXT_VISIT",t1->NEXT_VISIT)
        endif
        select T2
        find (t1->IDCASE)
        do while t1->IDCASE == t2->IDCASE .and. !eof()
          ++iidserv
          if (j := ascan(a_fusl, {|x| x[2] == int(val(t2->IDSERV))} )) > 0
            select MOHU
            goto (a_fusl[j,1])
            mohu->(G_RLock(forever))
            mohu->SCHET_ZAP := iidserv
            UnLock
          else
            if (j := ascan(a_usl, {|x| x[2] == int(val(t2->IDSERV))} )) == 0
              j := 1 // ????? такого не может быть
            endif
            if j <= len(a_usl)
              select HU
              goto (a_usl[j,1])
              hu_->(G_RLock(forever))
              hu_->SCHET_ZAP := iidserv
              UnLock
            endif
          endif
          oUSL := oSLUCH:Add( HXMLNode():New( "USL" ) )
          mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(iidserv))
          mo_add_xml_stroke(oUSL,"ID_U"    ,t2->ID_U)
          mo_add_xml_stroke(oUSL,"LPU"     ,t2->LPU)
          if !empty(t2->LPU_1)
            mo_add_xml_stroke(oUSL,"LPU_1" ,t2->LPU_1)
          endif
          if !empty(t2->PODR)
            mo_add_xml_stroke(oUSL,"PODR"  ,t2->PODR)
          endif
          mo_add_xml_stroke(oUSL,"PROFIL"  ,t2->PROFIL)
          if !empty(t2->VID_VME)
            mo_add_xml_stroke(oUSL,"VID_VME",t2->VID_VME)
          endif
          if !empty(t2->DET)
            mo_add_xml_stroke(oUSL,"DET"   ,t2->DET)
          endif
          mo_add_xml_stroke(oUSL,"DATE_IN" ,t2->DATE_IN)
          mo_add_xml_stroke(oUSL,"DATE_OUT",t2->DATE_OUT)
          if !empty(t2->DS)
            mo_add_xml_stroke(oUSL,"DS"    ,t2->DS)
          endif
          if !empty(t2->P_OTK)
            mo_add_xml_stroke(oUSL,"P_OTK" ,t2->P_OTK)
          endif
          mo_add_xml_stroke(oUSL,"CODE_USL",t2->CODE_USL)
          mo_add_xml_stroke(oUSL,"KOL_USL" ,t2->KOL_USL)
          mo_add_xml_stroke(oUSL,"TARIF"   ,t2->TARIF)
          mo_add_xml_stroke(oUSL,"SUMV_USL",t2->SUMV_USL)
          mo_add_xml_stroke(oUSL,"PRVS"    ,t2->PRVS)
          mo_add_xml_stroke(oUSL,"CODE_MD",t2->CODE_MD)
          if !empty(t2->USL_TIP)
           oONK := oUSL:Add( HXMLNode():New( "ONK_USL" ) )
            mo_add_xml_stroke(oONK,"USL_TIP",t2->USL_TIP)
            if !empty(t2->HIR_TIP)
             mo_add_xml_stroke(oONK,"HIR_TIP",t2->HIR_TIP)
            endif
            if !empty(t2->LEK_TIP_L)
             mo_add_xml_stroke(oONK,"LEK_TIP_L",t2->LEK_TIP_L)
             mo_add_xml_stroke(oONK,"LEK_TIP_V",t2->LEK_TIP_V)
            endif
            if !empty(t2->LUCH_TIP)
             mo_add_xml_stroke(oONK,"LUCH_TIP",t2->LUCH_TIP)
            endif
          endif
          if !empty(t2->COMENTU)
            mo_add_xml_stroke(oUSL,"COMENTU",t2->COMENTU)
          endif
          select T2
          skip
        enddo
        select T4
        find (t1->IDCASE)
        if found()
          oSL := oSLUCH:Add( HXMLNode():New( "SL_KOEFF" ) )
          do while t1->IDCASE == t4->IDCASE .and. !eof()
            oCOEFF := oSL:Add( HXMLNode():New( "COEFF" ) )
            mo_add_xml_stroke(oCOEFF,"CODE_SL",t4->CODE_SL)
            mo_add_xml_stroke(oCOEFF,"VAL_C"  ,t4->VAL_C)
            select T4
            skip
          enddo
        endif
        if !empty(t1->COMENTSL)
          mo_add_xml_stroke(oSLUCH,"COMENTSL",t1->COMENTSL)
        endif
    else // не нашли в отосланном реестре - почему?
      func_error(4,'В реестре не найден пациент "'+alltrim(human->fio)+'"')
    endif
    //
    select TMP2
    skip
  enddo
  Commit
  @ maxrow(),0 say " запись" color cColorSt2Msg
  oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
  name_zip := alltrim(mo_xml->FNAME)+szip
  arr_zip := {alltrim(mo_xml->FNAME)+sxml}
  //
  stat_msg("Составление реестра пациентов по счёту № "+mn_schet)
  oXmlDoc := HXMLDoc():New()
  oXmlDoc:Add( HXMLNode():New( "PERS_LIST") )
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
    mo_add_xml_stroke(oXmlNode,"VERSION" ,'2.12')
    mo_add_xml_stroke(oXmlNode,"DATA"     ,date2xml(schet_->DSCHET))
    mo_add_xml_stroke(oXmlNode,"FILENAME" ,mo_xml->FNAME2)
    mo_add_xml_stroke(oXmlNode,"FILENAME1",mo_xml->FNAME)
  select TMP2
  find (str(ii,6))
  do while tmp2->schet==ii .and. !eof()
    @ maxrow(),0 say str(tmp2->schet_zap/arr_schet[ii,3]*100,6,2)+"%" color cColorSt2Msg
    select T3
    find (upper(tmp2->_ID_PAC))
    if found() // нашли в отосланном реестре
      oPAC := oXmlDoc:aItems[1]:Add( HXMLNode():New( "PERS" ) )
      mo_add_xml_stroke(oPAC,"ID_PAC",t3->ID_PAC)
      mo_add_xml_stroke(oPAC,"FAM"   ,t3->FAM)
      mo_add_xml_stroke(oPAC,"IM"    ,t3->IM)
      if !empty(t3->OT)
        mo_add_xml_stroke(oPAC,"OT"  ,t3->OT)
      endif
      mo_add_xml_stroke(oPAC,"W"     ,t3->W)
      mo_add_xml_stroke(oPAC,"DR"    ,t3->DR)
      if !empty(t3->dost)
        mo_add_xml_stroke(oPAC,"DOST",t3->dost) // отсутствует отчество
      endif
      if !empty(t3->tel)
        mo_add_xml_stroke(oPAC,"TEL",t3->tel)
      endif
      if !empty(t3->FAM_P)
        mo_add_xml_stroke(oPAC,"FAM_P",t3->FAM_P)
        mo_add_xml_stroke(oPAC,"IM_P" ,t3->IM_P)
        if !empty(t3->OT_P)
          mo_add_xml_stroke(oPAC,"OT_P" ,t3->OT_P)
        endif
        mo_add_xml_stroke(oPAC,"W_P"  ,t3->W_P)
        mo_add_xml_stroke(oPAC,"DR_P" ,t3->DR_P)
        if !empty(t3->dost_p)
          mo_add_xml_stroke(oPAC,"DOST_P",t3->dost_p) // отсутствует отчество
        endif
      endif
      if !empty(t3->MR)
        mo_add_xml_stroke(oPAC,"MR",t3->MR)
      endif
      if !empty(t3->DOCNUM)
        mo_add_xml_stroke(oPAC,"DOCTYPE",t3->DOCTYPE)
        if !empty(t3->DOCSER)
          mo_add_xml_stroke(oPAC,"DOCSER",t3->DOCSER)
        endif
        mo_add_xml_stroke(oPAC,"DOCNUM" ,t3->DOCNUM)
      endif
      if !empty(t3->SNILS)
        mo_add_xml_stroke(oPAC,"SNILS",t3->SNILS)
      endif
      if !empty(t3->OKATOG)
        mo_add_xml_stroke(oPAC,"OKATOG",t3->OKATOG)
      endif
      if !empty(t3->OKATOP)
        mo_add_xml_stroke(oPAC,"OKATOP",t3->OKATOP)
      endif
    else // не нашли в отосланном реестре
      func_error(4,'В реестре не найден пациент "'+alltrim(tmp2->_ID_PAC)+'"')
    endif
    select TMP2
    skip
  enddo
  @ maxrow(),0 say " запись" color cColorSt2Msg
  oXmlDoc:Save(alltrim(mo_xml->FNAME2)+sxml)
  aadd(arr_zip, alltrim(mo_xml->FNAME2)+sxml)
  if chip_create_zipXML(name_zip,arr_zip,.t.)
    // может быть, сделать ещё что-нибудь после записи счёта?
  endif
next
// запишем время окончания обработки
select MO_XML
goto (mXML_REESTR)
G_RLock(forever)
mo_xml->TWORK2 := hour_min(seconds())
close databases
if fl_msg
  stat_msg("Запись счетов завершена!") ; mybell(2,OK)
endif
return .t.

*

***** Просмотр списка реестров, запись для ТФОМС
Function view_list_reestr()
Local i, k, buf := savescreen(), tmp_help := chm_help_code
if !G_SLock(Sreestr_sem)
  return func_error(4,Sreestr_err)
endif
Private goal_dir := dir_server+dir_XML_MO+cslash
G_Use(dir_server+"mo_xml",,"MO_XML")
G_Use(dir_server+"mo_rees",,"REES")
index on dtos(dschet)+str(nschet,6) to (cur_dir+"tmp_rees") DESCENDING
go top
if eof()
  func_error(4,"Нет реестров")
else
  chm_help_code := 113
  Private reg := 1
  Alpha_Browse(T_ROW,0,23,79,"f1_view_list_reestr",color0,,,,,,,;
               "f2_view_list_reestr",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
endif
close databases
G_SUnLock(Sreestr_sem)
chm_help_code := tmp_help
restscreen(buf)
return NIL

*****
Function f1_view_list_reestr(oBrow)
Local oColumn, ;
      blk := {|| iif(hb_fileExists(goal_dir+alltrim(rees->NAME_XML)+szip), ;
                     iif(empty(rees->date_out), {3,4}, {1,2}),;
                     {5,6}) }
oColumn := TBColumnNew(" Номер",{|| rees->nschet })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Дата",{|| date_8(rees->dschet) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Пери-;од",;
          {|| iif(emptyany(rees->nyear,rees->nmonth), ;
                  space(5), ;
                  right(lstr(rees->nyear),2)+"/"+strzero(rees->nmonth,2)) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Сумма реестра",{|| padl(expand_value(rees->summa,2),15) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Кол.; бол.", {|| str(rees->kol,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Наименование файла",{|| padr(rees->NAME_XML,22) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Примечание",{|| f11_view_list_reestr() })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if reg == 1
  status_key("^<Esc>^ выход; ^<F5>^ запись для ТФОМС; ^<F3>^ информация о реестре; ^<F9>^ статистика")
else
  status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор реестра для возврата")
endif
return NIL

*****
Static Function f11_view_list_reestr()
Local s := ""
if !hb_fileExists(goal_dir+alltrim(rees->NAME_XML)+szip)
  s := "нет файла"
elseif empty(rees->date_out)
  s := "не записан"
else
  s := "зап. "+lstr(rees->NUMB_OUT)+" раз"
endif
return padr(s,10)

*

*****
Function f2_view_list_reestr(nKey,oBrow)
Local ret := -1, rec := rees->(recno()), tmp_color := setcolor(), r, r1, r2,;
      s, buf := savescreen(), arr, i, k, mdate, t_arr[2], arr_pmt := {}
do case
  case nKey == K_F5
    r := row()
    arr := {} ; k := 0 ; mdate := rees->dschet
    find (dtos(mdate))
    do while rees->dschet == mdate .and. !eof()
      if !emptyany(rees->name_xml,rees->kod_xml)
        aadd(arr, {rees->nschet,rees->name_xml,rees->kod_xml,rees->(recno())})
        if empty(rees->date_out)
          ++k
        endif
      endif
      skip
    enddo
    if len(arr) == 0
      func_error(4,"Нечего записывать!")
    else
      if len(arr) > 1
        asort(arr,,,{|x,y| x[1] < y[1]})
        for i := 1 to len(arr)
          rees->(dbGoto(arr[i,4]))
          aadd(arr_pmt, {"Реестр № "+lstr(rees->nschet)+" ("+;
                         lstr(rees->nyear)+"/"+strzero(rees->nmonth,2)+;
                         ") файл "+alltrim(rees->name_xml),aclone(arr[i])})
        next
        if r+2+len(arr) > maxrow()-2
          r2 := r-1
          r1 := r2-len(arr)-1
          if r1 < 0 ; r1 := 0 ; endif
        else
          r1 := r+1
        endif
        arr := {}
        if (t_arr := bit_popup(r1,10,arr_pmt,,color5,1,"Записываемые файлы реестров ("+date_8(mdate)+")","B/W")) != NIL
          aeval(t_arr, {|x| aadd(arr,aclone(x[2])) })
        endif
        t_arr := array(2)
      endif
      if len(arr) > 0
        s := "Количество реестров - "+lstr(len(arr))+;
             ", записываются в первый раз - "+lstr(k)+":"
        for i := 1 to len(arr)
          if i > 1
            s += ","
          endif
          s += " "+lstr(arr[i,1])+" ("+alltrim(arr[i,2])+szip+")"
        next
        if k > 0
          f_message({"Обращаем Ваше внимание, что после записи реестра",;
                     "НЕВОЗМОЖНО будет выполнить ВОЗВРАТ реестра"},,"GR+/R","W+/R",2)
        endif
        perenos(t_arr,s,74)
        f_message(t_arr,,color1,color8)
        if f_Esc_Enter("записи реестров за "+date_8(mdate))
          Private p_var_manager := "copy_schet"
          s := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,2,.f.,,,) // "norton" для выбора каталога
          if !empty(s)
            if upper(s) == upper(goal_dir)
              func_error(4,"Вы выбрали каталог, в котором уже записаны целевые файлы! Это недопустимо.")
            else
              cFileProtokol := "protrees"+stxt
              strfile(hb_eol()+center(glob_mo[_MO_SHORT_NAME],80)+hb_eol()+hb_eol(),cFileProtokol)
              smsg := "Реестры записаны на: "+s+;
                      " ("+full_date(sys_date)+"г. "+hour_min(seconds())+")"
              strfile(center(smsg,80)+hb_eol(),cFileProtokol,.t.)
              k := 0
              for i := 1 to len(arr)
                rees->(dbGoto(arr[i,4]))
                smsg := lstr(i)+". Реестр № "+lstr(rees->nschet)+;
                        " от "+date_8(mdate)+"г. (отч.период "+;
                         lstr(rees->nyear)+"/"+strzero(rees->nmonth,2)+;
                         ") "+alltrim(rees->name_xml)+szip
                strfile(hb_eol()+smsg+hb_eol(),cFileProtokol,.t.)
                smsg := "   количество пациентов - "+lstr(rees->kol)+;
                        ", сумма реестра - "+expand_value(rees->summa,2)
                strfile(smsg+hb_eol(),cFileProtokol,.t.)
                zip_file := alltrim(arr[i,2])+szip
                if hb_fileExists(goal_dir+zip_file)
                  mywait('Копирование "'+zip_file+'" в каталог "'+s+'"')
                  //copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
                  copy file (goal_dir+zip_file) to (s+zip_file)
                  //if hb_fileExists(hb_OemToAnsi(s)+zip_file)
                  if hb_fileExists(s+zip_file)
                    ++k
                    rees->(G_RLock(forever))
                    rees->DATE_OUT := sys_date
                    if rees->NUMB_OUT < 99
                      rees->NUMB_OUT ++
                    endif
                    //
                    mo_xml->(dbGoto(arr[i,3]))
                    mo_xml->(G_RLock(forever))
                    mo_xml->DREAD := sys_date
                    mo_xml->TREAD := hour_min(seconds())
                  else
                    smsg := "! Ошибка записи файла "+s+zip_file
                    func_error(4,smsg)
                    strfile(smsg+hb_eol(),cFileProtokol,.t.)
                  endif
                else
                  smsg := "! Не обнаружен файл "+goal_dir+zip_file
                  func_error(4,smsg)
                  strfile(smsg+hb_eol(),cFileProtokol,.t.)
                endif
              next
              UnLock
              Commit
              viewtext(cFileProtokol,,,,.t.,,,2)
              /*asize(t_arr,1)
              perenos(t_arr,"Записано реестров - "+lstr(k)+" в каталог "+s+;
                     iif(k == len(arr), "", ", не записано реестров - "+lstr(len(arr)-k)),60)
              stat_msg("Запись завершена!")
              n_message(t_arr,,"GR+/B","W+/B",18,,"G+/B")*/
            endif
          endif
        endif
      endif
    endif
    select REES
    goto (rec)
    ret := 0
  case nKey == K_F3
    f3_view_list_reestr(oBrow)
    ret := 0
  case nKey == K_F9
    mywait()
    R_Use(dir_server+"mo_rhum",,"RHUM")
    nfile := "reesstat"+stxt ; sh := 80 ; HH := 60
    fp := fcreate(nfile) ; n_list := 1 ; tek_stroke := 0
    add_string("")
    add_string(center("Статистика по реестрам",sh))
    add_string("")
    arr_title := {;
      "──────┬────────┬────────────────────┬────┬────────────┬───────┬─────────────┬───",;
      "Номер │  Дата  │   Наименование     │Кол.│    Сумма   │Реестры│Кол-во не об-│Ста",;
      "реестр│ реестра│   файла реестра    │боль│   реестра  │СП и ТК│работ.в ТФОМС│тус",;
      "──────┴────────┴────────────────────┴────┴────────────┴───────┴─────────────┴───"}
    aeval(arr_title, {|x| add_string(x) } )
    oldy := oldm := 0
    select REES
    index on str(NYEAR,4)+str(NMONTH,2)+str(NSCHET,6) to (cur_dir+"tmpr1") for NYEAR > 2014
    go top
    do while !eof()
      if verify_FF(HH-2, .t., sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      if !(oldy==rees->NYEAR .and. oldm==rees->NMONTH)
        add_string("")
        add_string(padc("Отчётный период "+lstr(rees->nyear)+"/"+strzero(rees->nmonth,2),sh,"_"))
        oldy := rees->NYEAR ; oldm := rees->NMONTH
      endif
      s := str(rees->NSCHET,6)+" "+date_8(rees->DSCHET)+" "+;
           padr(rees->NAME_XML,20)+;
           str(rees->KOL,5)+put_kop(rees->SUMMA,13)
      select MO_XML
      index on FNAME to (cur_dir+"tmp_x2") ;
            for reestr==rees->kod .and. TIP_OUT==0 .and. TIP_IN==_XML_FILE_SP
      kol_sp := 0 ; dbeval({|| ++kol_sp })
      select RHUM
      index on str(REES_ZAP,6) to (cur_dir+"tmp_r2") ;
            for reestr == rees->kod .and. OPLATA == 0
      kol_ne := 0 ; dbeval({|| ++kol_ne })
      s += padc(iif(kol_sp==0,"-",lstr(kol_sp)),9)
      s += padc(iif(kol_ne==0,"-",lstr(kol_ne)),13)
      s += " "+iif(kol_ne==0," =","!!!")
      add_string(s)
      select REES
      skip
    enddo
    close databases
    fclose(fp)
    keyboard chr(K_END)
    viewtext(nfile,,,,,,,2,,,.f.)
    G_Use(dir_server+"mo_xml",,"MO_XML")
    G_Use(dir_server+"mo_rees",cur_dir+"tmp_rees","REES")
    goto (rec)
    ret := 0
  case nKey == K_CTRL_F12
    ret := delete_reestr_sp_tk(rees->(recno()),alltrim(rees->NAME_XML))
    close databases
    G_Use(dir_server+"mo_xml",,"MO_XML")
    G_Use(dir_server+"mo_rees",cur_dir+"tmp_rees","REES")
    goto (rec)
endcase
setcolor(tmp_color)
restscreen(buf)
return ret

*

*****
Function f3_view_list_reestr(oBrow)
Static si := 1
Local i, r := row(), r1, r2, buf := save_maxrow(), ;
      mm_func := {-1,-2,-3},;
      mm_menu := {"Список ~всех пациентов в реестре",;
                  "Список ~обработанных в ТФОМС",;
                  "Список ~не обработанных в ТФОМС"}
mywait()
select MO_XML
index on FNAME to (cur_dir+"tmp_xml") ;
      for reestr==rees->kod .and. between(TIP_IN,_XML_FILE_FLK,_XML_FILE_SP) .and. empty(TIP_OUT)
go top
do while !eof()
  aadd(mm_func, mo_xml->kod)
  aadd(mm_menu, "Протокол чтения "+rtrim(mo_xml->FNAME)+iif(empty(mo_xml->TWORK2),"-ЧТЕНИЕ НЕ ЗАВЕРШЕНО",""))
  skip
enddo
select MO_XML
set index to
if r <= 12
  r1 := r+1 ; r2 := r1+len(mm_menu)+1
else
  r2 := r-1 ; r1 := r2-len(mm_menu)-1
endif
rest_box(buf)
if (i := popup_prompt(r1,10,si,mm_menu,,,color5)) > 0
  si := i
  if mm_func[i] < 0
    f31_view_list_reestr(abs(mm_func[i]),mm_menu[i])
  else
    mo_xml->(dbGoto(mm_func[i]))
    viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+alltrim(mo_xml->FNAME)+stxt,60,80),,,,.t.,,,2)
  endif
endif
select REES
return NIL

***** 15.02.19
Function f31_view_list_reestr(reg,s)
Local fl := .t., buf := save_maxrow(), s1, lal, n_file := "reesspis"+stxt
mywait()
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Список пациентов реестра № "+lstr(rees->nschet)+" от "+date_8(rees->dschet),80))
add_string(center("( "+charrem("~",s)+" )",80))
add_string("")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, to otd into OTD
R_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
R_Use(dir_server+"mo_rhum",,"RHUM")
index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == rees->kod
go top
do while !eof()
  do case
    case reg == 1
      fl := .t.
    case reg == 2
      fl := (rhum->OPLATA > 0)
    case reg == 3
      fl := (rhum->OPLATA == 0)
  endcase
  if fl
    select HUMAN
    goto (rhum->kod_hum)
    lal := "human"
    s1 := ""
    if human->ishod == 88
      s1 := " 2сл"
      select HUMAN_3
      set order to 1
      find (str(rhum->kod_hum,7))
      lal += "_3"
    elseif human->ishod == 89
      s1 := " 2сл"
      select HUMAN_3
      set order to 2
      find (str(rhum->kod_hum,7))
      lal += "_3"
    endif
    s := padr(human->fio,50-len(s1))+s1+" "+otd->short_name+;
         " "+date_8(&lal.->n_data)+"-"+date_8(&lal.->k_data)
    if rhum->REES_ZAP < 10000
      s := str(rhum->REES_ZAP,4)+". "+s
    else
      s := lstr(rhum->REES_ZAP)+"."+s
    endif
    verify_FF(60,.t.,80)
    add_string(s)
  endif
  select RHUM
  skip
enddo
human_3->(dbCloseArea())
human_->(dbCloseArea())
human->(dbCloseArea())
otd->(dbCloseArea())
rhum->(dbCloseArea())
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.t.,,,2)
return NIL

***** вернуть ещё не записанный на дискету реестр
Function vozvrat_reestr()
Local i, k, buf := savescreen(), arr, tmp_help := chm_help_code, mkod_reestr
if tip_polzovat != 0
  return func_error(4,err_admin)
endif
if !G_SLock(Sreestr_sem)
  return func_error(4,Sreestr_err)
endif
Private goal_dir := dir_server+dir_XML_MO+cslash
G_Use(dir_server+"mo_rees",,"REES")
index on dtos(dschet)+str(nschet,6) to (cur_dir+"tmp_rees") DESCENDING for empty(date_out)
go top
if eof()
  func_error(4,"Не обнаружено реестров, не отправленных в ТФОМС")
else
  chm_help_code := 114
  Private reg := 2
  if Alpha_Browse(T_ROW,0,23,79,"f1_view_list_reestr",color0,,,,.t.,,,,,;
                  {'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",,60} )
    mkod_reestr := rees->KOD
    mywait()
    G_Use(dir_server+"mo_xml",,"MO_XML")
    index on FNAME to (cur_dir+"tmp_xml") for reestr==mkod_reestr .and. TIP_OUT==0
    k := kol_err := 0
    go top
    do while !eof()
      if mo_xml->TIP_IN == _XML_FILE_SP
        ++k
      elseif mo_xml->TIP_IN == _XML_FILE_FLK
        kol_err += mo_xml->kol2
      endif
      skip
    enddo
    if k > 0
      func_error(4,"По данному реестру уже были прочитаны реестры СП и ТК. Возврат ЗАПРЕЩЁН!")
    elseif kol_err > 0
      func_error(4,"По данному реестру был прочитан протокол ФЛК с ошибками. Возврат ЗАПРЕЩЁН!")
    else
      f1vozvrat_reestr(mkod_reestr)
    endif
  endif
endif
close databases
G_SUnLock(Sreestr_sem)
chm_help_code := tmp_help
restscreen(buf)
return NIL

***** 15.02.19
Static Function f1vozvrat_reestr(mkod_reestr)
Local buf := savescreen()
close databases
G_Use(dir_server+"mo_rees",,"REES")
goto (mkod_reestr)
stat_msg("")
arr := {}
aadd(arr,"Удаляется реестр № "+lstr(rees->nschet)+" от "+full_date(rees->dschet)+"г.")
aadd(arr,'за период "'+iif(between(rees->nmonth,1,12), mm_month[rees->nmonth], lstr(rees->nmonth)+" месяц")+;
         str(rees->nyear,5)+' года".')
aadd(arr,"Сумма реестра "+lput_kop(rees->summa,.t.)+;
         " руб., количество пациентов "+lstr(rees->kol)+" чел.")
aadd(arr,"Наименование файла "+alltrim(rees->NAME_XML))
aadd(arr,"")
aadd(arr,"После подтверждения удаления пациенты будут вычеркнуты")
aadd(arr,"из данного реестра, а реестр будет удален.")
f_message(arr,,color1,color8)
if f_Esc_Enter("удаления реестра № "+lstr(rees->nschet),.t.)
  stat_msg("Подтвердите удаление ещё раз.") ; mybell(2)
  if f_Esc_Enter("удаления реестра № "+lstr(rees->nschet),.t.)
    mywait("Ждите. Производится удаление реестра.")
    G_Use(dir_server+"human_u_",,"HU_")
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    set relation to recno() into HU_
    G_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
    G_Use(dir_server+"human",,"HUMAN")
    G_Use(dir_server+"human_",,"HUMAN_")
    G_Use(dir_server+"mo_rhum",,"RHUM")
    index on str(reestr,6) to (cur_dir+"tmp_rhum")
    do while .t.
      select RHUM
      find (str(mkod_reestr,6))
      if !found() ; exit ; endif
      //
      select HUMAN_
      goto (rhum->KOD_HUM)
      if human_->REESTR == mkod_reestr // на всякий случай
        select HUMAN
        goto (rhum->KOD_HUM)
        if human->ishod == 88 // сначала проверим, не двойной ли это случай (по-старому)
          select HUMAN_3
          set order to 1
          find (str(human->kod,7))
          if found()
            select HUMAN_
            goto (human_3->kod2) // встать на 2-ой лист учёта
            select HU
            find (str(human_3->kod2,7))
            do while human_3->kod2 == hu->kod .and. !eof()
              hu_->(G_RLock(forever))
              hu_->REES_ZAP := 0
              hu_->(dbUnLock())
              select HU
              skip
            enddo
            human_->(G_RLock(forever))
            if human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM-1
            endif
            human_->REES_ZAP := 0
            human_->REESTR := 0
            human_->(dbUnLock())
            // обработка заголовка двойного случая
            human_3->(G_RLock(forever))
            if human_3->REES_NUM > 0
              human_3->REES_NUM := human_3->REES_NUM-1
            endif
            human_3->REES_ZAP := 0
            human_3->REESTR := 0
            human_3->(dbUnLock())
          endif
          // возвращаемся к 1-му листу учёта
          select HUMAN_
          goto (rhum->KOD_HUM)
          select HU
          find (str(rhum->KOD_HUM,7))
          do while rhum->KOD_HUM == hu->kod .and. !eof()
            hu_->(G_RLock(forever))
            hu_->REES_ZAP := 0
            hu_->(dbUnLock())
            select HU
            skip
          enddo
          human_->(G_RLock(forever))
          if human_->REES_NUM > 0
            human_->REES_NUM := human_->REES_NUM-1
          endif
          human_->REES_ZAP := 0
          human_->REESTR := 0
          human_->(dbUnLock())
        elseif human->ishod == 89 // теперь проверим, не двойной ли это случай (по-новому)
          // сначала обработаем 2-ой случай
          select HU
          find (str(rhum->KOD_HUM,7))
          do while rhum->KOD_HUM == hu->kod .and. !eof()
            hu_->(G_RLock(forever))
            hu_->REES_ZAP := 0
            hu_->(dbUnLock())
            select HU
            skip
          enddo
          human_->(G_RLock(forever))
          if human_->REES_NUM > 0
            human_->REES_NUM := human_->REES_NUM-1
          endif
          human_->REES_ZAP := 0
          human_->REESTR := 0
          human_->(dbUnLock())
          // поищем 1-ый случай
          select HUMAN_3
          set order to 2
          find (str(human->kod,7))
          if found()
            select HUMAN_
            goto (human_3->kod) // встать на 1-ый лист учёта
            select HU
            find (str(human_3->kod2,7))
            do while human_3->kod2 == hu->kod .and. !eof()
              hu_->(G_RLock(forever))
              hu_->REES_ZAP := 0
              hu_->(dbUnLock())
              select HU
              skip
            enddo
            human_->(G_RLock(forever))
            if human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM-1
            endif
            human_->REES_ZAP := 0
            human_->REESTR := 0
            human_->(dbUnLock())
            // обработка заголовка двойного случая
            human_3->(G_RLock(forever))
            if human_3->REES_NUM > 0
              human_3->REES_NUM := human_3->REES_NUM-1
            endif
            human_3->REES_ZAP := 0
            human_3->REESTR := 0
            human_3->(dbUnLock())
          endif
        else
          // обработка одинарного случая
          select HUMAN_
          goto (rhum->KOD_HUM)
          select HU
          find (str(rhum->KOD_HUM,7))
          do while rhum->KOD_HUM == hu->kod .and. !eof()
            hu_->(G_RLock(forever))
            hu_->REES_ZAP := 0
            hu_->(dbUnLock())
            select HU
            skip
          enddo
          human_->(G_RLock(forever))
          if human_->REES_NUM > 0
            human_->REES_NUM := human_->REES_NUM-1
          endif
          human_->REES_ZAP := 0
          human_->REESTR := 0
          human_->(dbUnLock())
        endif
      endif
      //
      select RHUM
      DeleteRec(.t.)
    enddo
    zip_file := alltrim(rees->name_xml)+szip
    if hb_fileExists(goal_dir+zip_file)
      delete file (goal_dir+zip_file)
    endif
    G_Use(dir_server+"mo_xml",,"MO_XML")
    goto (rees->KOD_XML)
    if !eof() .and. !deleted()
      DeleteRec(.t.)
    endif
    select REES
    DeleteRec(.t.)
    stat_msg("Реестр удалён!") ; mybell(2,OK)
  endif
endif
close databases
restscreen(buf)
return NIL

***** 15.02.19 аннулировать чтение реестра СП и ТК по реестру с кодом mkod_reestr
Function delete_reestr_sp_tk(mkod_reestr,mname_reestr)
Local i, s, r := row(), r1, r2, buf := save_maxrow(), ;
      mm_menu := {}, mm_func := {}, mm_flag := {}, mreestr_sp_tk, ;
      arr_f, cFile, oXmlDoc, aerr := {}, is_allow_delete, ;
      cFileProtokol := "tmp"+stxt, is_other_reestr, bSaveHandler,;
      arr_schet, rees_nschet := rees->nschet, mtip_in
mywait()
select MO_XML
index on FNAME to (cur_dir+"tmp_xml") for reestr==mkod_reestr .and. TIP_OUT==0
go top
do while !eof()
  if mo_xml->TIP_IN == _XML_FILE_SP
    aadd(mm_func, mo_xml->kod)
    s := "Реестр СП и ТК "+rtrim(mo_xml->FNAME)+" прочитан "+date_8(mo_xml->DWORK)
    if empty(mo_xml->TWORK2)
      aadd(mm_flag,.t.)
      s += "-ПРОЦЕСС НЕ ЗАВЕРШЁН"
    else
      aadd(mm_flag,.f.)
      s += " в "+mo_xml->TWORK1
    endif
    aadd(mm_menu,s)
  elseif mo_xml->TIP_IN == _XML_FILE_FLK
    if mo_xml->kol2 > 0
      aadd(mm_func, mo_xml->kod)
      aadd(mm_flag,.f.)
      s := "Протокол ФЛК "+rtrim(mo_xml->FNAME)+" прочитан "+;
           date_8(mo_xml->DWORK)+" в "+mo_xml->TWORK1
      aadd(mm_menu,s)
    endif
  endif
  skip
enddo
select MO_XML
set index to
rest_box(buf)
if len(mm_menu) == 0
  if involved_password(1,rees_nschet,"подтверждения возврата (удаления) реестра")
    f1vozvrat_reestr(mkod_reestr)
  endif
  return 1
endif
if r <= 18
  r1 := r+1 ; r2 := r1+len(mm_menu)+1
else
  r2 := r-1 ; r1 := r2-len(mm_menu)-1
endif
if (i := popup_prompt(r1,10,1,mm_menu,,,color5)) > 0
  is_allow_delete := mm_flag[i]
  mreestr_sp_tk := mm_func[i]
  mywait()
  select MO_XML
  goto (mreestr_sp_tk)
  cFile := alltrim(mo_xml->FNAME)
  mtip_in := mo_xml->TIP_IN
  close databases
  if mtip_in == _XML_FILE_SP // возврат реестра СП и ТК
    if (arr_f := Extract_Zip_XML(dir_server+dir_XML_TF,cFile+szip)) != NIL ;
                                                       .and. mo_Lock_Task(X_OMS)
      cFile += sxml
      // читаем файл в память
      oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
      if oXmlDoc == NIL .or. Empty( oXmlDoc:aItems )
        func_error(4,"Ошибка в чтении файла "+cFile)
      else // читаем и записываем XML-файл во временные TMP-файлы
        reestr_sp_tk_tmpfile(oXmlDoc,aerr,cFile)
        if !empty(aerr)
          Ins_Array(aerr,1,"")
          Ins_Array(aerr,1,center("Ошибки в чтении файла "+cFile,80))
          aeval(aerr,{|x| strfile(x+hb_eol(),cFileProtokol,.t.) })
          viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,2)
          delete file (cFileProtokol)
        else
          // если точно попал в другой реестр
          is_other_reestr := is_delete_human := .f.
          R_Use(dir_server+"human",,"HUMAN")
          R_Use(dir_server+"human_",,"HUMAN_")
          R_Use(dir_server+"mo_rhum",,"RHUM")
          index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
          select TMP2
          go top
          do while !eof()
            select RHUM
            find (str(tmp2->_N_ZAP,6))
            if found()
              tmp2->kod_human := rhum->KOD_HUM
              select HUMAN
              goto (rhum->KOD_HUM)
              if emptyany(human->kod,human->fio)
                is_delete_human := .t. ; exit
              endif
              select HUMAN_
              goto (rhum->KOD_HUM)
              if human_->REESTR > 0 .and. human_->REESTR != mkod_reestr
                is_other_reestr := .t. ; exit
              endif
            endif
            select TMP2
            skip
          enddo
          if !is_other_reestr .and. !is_delete_human
            // если попал в другой реестр, вернулся с ошибкой, и отредактирован
            R_Use(dir_server+"mo_rees",,"REES")
            select RHUM
            set relation to reestr into REES
            // сортируем пациентов по дате попадания в реестры
            index on str(kod_hum,7)+dtos(rees->DSCHET) to (cur_dir+"tmp_rhum")
            select TMP2
            go top
            do while !eof()
              r := r1 := 0
              select RHUM
              find (str(tmp2->kod_human,7))
              do while tmp2->kod_human == rhum->KOD_HUM
                ++r // во сколько реестров попал
                if rhum->reestr == mkod_reestr
                  r1 := r // какой по номеру текущий реестр
                endif
                skip
              enddo
              if r1 > 0 .and. r > r1  // если текущий реестр не последний
                is_other_reestr := .t. ; exit
              endif
              select TMP2
              skip
            enddo
          endif
          if is_delete_human
            func_error(10,"Некоторые пациенты из данного реестра уже УДАЛЕНЫ. Операция запрещена!")
          elseif is_other_reestr
            func_error(10,"Пациенты из данного реестра уже ПОПАЛИ В ДРУГОЙ РЕЕСТР. Операция запрещена!")
          else
            if !is_allow_delete .and. involved_password(1,rees_nschet,"аннулирования чтения реестра СП и ТК")
              is_allow_delete := .t.
            endif
            if is_allow_delete
              close databases
              arr_schet := {}
              R_Use(dir_server+"schet_",,"SCH")
              index on nschet to (cur_dir+"tmp_sch") for XML_REESTR == mreestr_sp_tk
              dbeval({|| aadd(arr_schet,{alltrim(nschet),recno(),KOD_XML}) })
              sch->(dbCloseArea())
              is_allow_delete := .f.
              G_Use(dir_server+"mo_rees",,"REES")
              goto (mkod_reestr)
              use (cur_dir+"tmp1file") new alias TMP1
              use (cur_dir+"tmp2file") new alias TMP2
              arr := {}
              aadd(arr,"Реестр № "+lstr(rees->nschet)+" от "+full_date(rees->dschet)+"г.")
              aadd(arr,'период "'+lstr(rees->nmonth)+"/"+lstr(rees->nyear)+;
                       '", сумма '+lput_kop(rees->summa,.t.)+;
                       " руб., кол-во пациентов "+lstr(rees->kol)+" чел.")
              aadd(arr,"")
              aadd(arr,"Аннулируется реестр СП и ТК № "+alltrim(tmp1->_NSCHET)+" от "+full_date(tmp1->_dschet)+"г.")
              aadd(arr,"кол-во пациентов "+lstr(tmp2->(lastrec()))+" чел. (файл "+Name_Without_Ext(cFile)+")")
              if len(arr_schet) > 0
                aadd(arr,"Количество удаляемых счетов - "+lstr(len(arr_schet))+" сч.")
              endif
              aadd(arr,"После подтверждения аннулирования все последствия чтения данного")
              aadd(arr,"реестра СП и ТК, а также сам реестр СП и ТК, будут удалены.")
              f_message(arr,,cColorSt2Msg,cColorSt1Msg)
              s := "Подтвердите аннулирование реестра СП и ТК"
              stat_msg(s) ; mybell(1)
              if f_Esc_Enter("аннулирования",.t.)
                stat_msg(s+" ещё раз.") ; mybell(3)
                if f_Esc_Enter("аннулирования",.t.)
                  mywait()
                  is_allow_delete := .t.
                endif
              endif
            endif
            // переиндексируем некоторые файлы
            if is_allow_delete
              Private fl_open := .t.
              bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
              BEGIN SEQUENCE
                index_base("schet") // для составления счетов
                index_base("human") // для разноски счетов
                index_base("mo_refr")  // для записи причин отказов
                index_base("human_3")  // для двойных случаев
              RECOVER USING error
                is_allow_delete := func_error(10,"Возникла непредвиденная ошибка при переиндексировании!")
              END
              ERRORBLOCK(bSaveHandler)
            endif
            // аннулируем последствия чтения реестра СП и ТК
            if is_allow_delete
              close databases
              use_base("schet")
              set relation to
              G_Use(dir_server+"schetd",,"SD")
              index on str(kod,6) to (cur_dir+"tmp_sd")
              G_Use(dir_server+"mo_xml",,"MO_XML")
              G_Use(dir_server+"mo_refr",dir_server+"mo_refr","REFR")
              G_Use(dir_server+"mo_rhum",,"RHUM")
              index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
              G_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
              use_base("human")
              set order to 0
              use (cur_dir+"tmp2file") new alias TMP2
              go top
              do while !eof()
                select RHUM
                find (str(tmp2->_N_ZAP,6))
                G_RLock(forever)
                rhum->OPLATA := 0
                select HUMAN
                goto (tmp2->kod_human)
                if human->ishod == 88  // сначала проверим, не двойной ли это случай (по-старому)
                  select HUMAN_3
                  set order to 1
                  find (str(tmp2->kod_human,7))
                  if found()
                    select HUMAN
                    goto (human_3->kod2)  // встали на 2-ой лист учёта
                    human->(G_RLock(forever))
                    human->schet := 0 ; human->tip_h := B_STANDART
                    human_->(G_RLock(forever))
                    if human_->schet_zap > 0
                      if human_->SCHET_NUM > 0
                        human_->SCHET_NUM := human_->SCHET_NUM-1
                      endif
                      human_->schet_zap := 0
                    endif
                    human_->OPLATA := 0
                    human_->REESTR := mkod_reestr
                    UnLock
                    // очистка заголовка двойного случая
                    human_3->(G_RLock(forever))
                    human_3->schet := 0
                    if human_3->schet_zap > 0
                      if human_3->SCHET_NUM > 0
                        human_3->SCHET_NUM := human_3->SCHET_NUM - 1
                      endif
                      human_3->schet_zap := 0
                    endif
                    human_3->OPLATA := 0
                    human_3->REESTR := mkod_reestr
                  endif
                  // возвращаемся к 1-му листу учёта
                  select HUMAN
                  goto (tmp2->kod_human)
                  human->(G_RLock(forever))
                  human->schet := 0 ; human->tip_h := B_STANDART
                  human_->(G_RLock(forever))
                  if human_->schet_zap > 0
                    if human_->SCHET_NUM > 0
                      human_->SCHET_NUM := human_->SCHET_NUM-1
                    endif
                    human_->schet_zap := 0
                  endif
                  human_->OPLATA := 0
                  human_->REESTR := mkod_reestr
                  UnLock
                elseif human->ishod == 89 // теперь проверим, не двойной ли это случай (по-новому)
                  // сначала обработаем 2-ой случай
                  human->(G_RLock(forever))
                  human->schet := 0 ; human->tip_h := B_STANDART
                  human_->(G_RLock(forever))
                  if human_->schet_zap > 0
                    if human_->SCHET_NUM > 0
                      human_->SCHET_NUM := human_->SCHET_NUM-1
                    endif
                    human_->schet_zap := 0
                  endif
                  human_->OPLATA := 0
                  human_->REESTR := mkod_reestr
                  UnLock
                  // поищем 1-ый случай
                  select HUMAN_3
                  set order to 2
                  find (str(human->kod,7))
                  if found() // нашли двойной случай
                    select HUMAN
                    goto (human_3->kod) // встать на 1-ый лист учёта
                    human->(G_RLock(forever))
                    human->schet := 0 ; human->tip_h := B_STANDART
                    human_->(G_RLock(forever))
                    if human_->schet_zap > 0
                      if human_->SCHET_NUM > 0
                        human_->SCHET_NUM := human_->SCHET_NUM-1
                      endif
                      human_->schet_zap := 0
                    endif
                    human_->OPLATA := 0
                    human_->REESTR := mkod_reestr
                    UnLock
                    // очистка заголовка двойного случая
                    human_3->(G_RLock(forever))
                    human_3->schet := 0
                    if human_3->schet_zap > 0
                      if human_3->SCHET_NUM > 0
                        human_3->SCHET_NUM := human_3->SCHET_NUM - 1
                      endif
                      human_3->schet_zap := 0
                    endif
                    human_3->OPLATA := 0
                    human_3->REESTR := mkod_reestr
                  endif
                else
                  // обработка одинарного случая
                  select HUMAN
                  goto (tmp2->kod_human)
                  human->(G_RLock(forever))
                  human->schet := 0 ; human->tip_h := B_STANDART
                  human_->(G_RLock(forever))
                  if human_->schet_zap > 0
                    if human_->SCHET_NUM > 0
                      human_->SCHET_NUM := human_->SCHET_NUM-1
                    endif
                    human_->schet_zap := 0
                  endif
                  human_->OPLATA := 0
                  human_->REESTR := mkod_reestr
                  UnLock
                endif
                select REFR
                do while .t.
                  find (str(1,1)+str(mkod_reestr,6)+str(1,1)+str(tmp2->kod_human,8))
                  if !found() ; exit ; endif
                  DeleteRec(.t.)
                enddo
                select TMP2
                skip
              enddo
              for i := 1 to len(arr_schet)
                //
                select SD
                find (str(arr_schet[i,2],6))
                if found()
                  DeleteRec(.t.)
                endif
                //
                select SCHET_
                goto (arr_schet[i,2])
                DeleteRec(.t.,.f.)  // без пометки на удаление
                //
                select SCHET
                goto (arr_schet[i,2])
                DeleteRec(.t.)
                //
                if arr_schet[i,3] > 0
                  select MO_XML
                  goto (arr_schet[i,3])
                  if !empty(mo_xml->FNAME)
                    s := dir_server+dir_XML_MO+cslash+alltrim(mo_xml->FNAME)+szip
                    if hb_fileExists(s)
                      delete file (s)
                    endif
                  endif
                  DeleteRec(.t.)
                endif
              next
              select MO_XML
              goto (mreestr_sp_tk)
              DeleteRec()
              close databases
              stat_msg("Реестр СП и ТК успешно аннулирован. Можно прочитать ещё раз.") ; mybell(5)
            endif
          endif
        endif
      endif
      mo_UnLock_Task(X_OMS)
    endif
  elseif mTIP_IN == _XML_FILE_FLK // возврат протокола ФЛК
    if (arr_f := Extract_Zip_XML(dir_server+dir_XML_TF,cFile+szip)) != NIL .and. mo_Lock_Task(X_OMS)
      cFile += sxml
      // читаем файл в память
      oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
      if oXmlDoc == NIL .or. Empty( oXmlDoc:aItems )
        func_error(4,"Ошибка в чтении файла "+cFile)
      else // читаем и записываем XML-файл во временные TMP-файлы
        is_err_FLK := protokol_flk_tmpfile(arr_f,aerr)
        close databases
        if empty(aerr) .and. !extract_reestr(mkod_reestr,mname_reestr)
          aadd(aerr,"Не найден ZIP-архив с РЕЕСТРом "+mname_reestr)
          aadd(aerr,"Без данного архива дальнейшая работа НЕВОЗМОЖНА!")
        endif
        if !empty(aerr)
          Ins_Array(aerr,1,"")
          Ins_Array(aerr,1,center("Ошибки в чтении файла "+cFile,80))
          aeval(aerr,{|x| strfile(x+hb_eol(),cFileProtokol,.t.) })
          viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,2)
          delete file (cFileProtokol)
        else
          // если точно попал в другой реестр
          is_other_reestr := is_delete_human := .f.
          use (cur_dir+"tmp1file") new alias TMP1
          use (cur_dir+"tmp2file") new alias TMP2
          index on str(tip,1)+str(oshib,3) to (cur_dir+"tmp2")
          use (cur_dir+"tmp_r_t1") new alias T1
          index on upper(ID_PAC) to (cur_dir+"tmp_r_t1")
          use (cur_dir+"tmp_r_t2") new alias T2
          use (cur_dir+"tmp_r_t3") new alias T3
          use (cur_dir+"tmp_r_t4") new alias T4
          // заполнить поле "N_ZAP" в файле "tmp2"
          fill_tmp2_file_flk()
          R_Use(dir_server+"human",,"HUMAN")
          R_Use(dir_server+"human_",,"HUMAN_")
          R_Use(dir_server+"mo_rhum",,"RHUM")
          index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
          select TMP2
          go top
          do while !eof()
            if !empty(tmp2->BAS_EL) .and. !empty(tmp2->ID_BAS) .and. !empty(tmp2->N_ZAP)
              select RHUM
              find (str(tmp2->N_ZAP,6))
              if found()
                tmp2->kod_human := rhum->KOD_HUM
                select HUMAN
                goto (rhum->KOD_HUM)
                if emptyany(human->kod,human->fio)
                  is_delete_human := .t. ; exit
                endif
                select HUMAN_
                goto (rhum->KOD_HUM)
                if human_->REESTR > 0 .and. human_->REESTR != mkod_reestr
                  is_other_reestr := .t. ; exit
                endif
              endif
            endif
            select TMP2
            skip
          enddo
          if !is_other_reestr .and. !is_delete_human
            // если попал в другой реестр, вернулся с ошибкой, и отредактирован
            R_Use(dir_server+"mo_rees",,"REES")
            select RHUM
            set relation to reestr into REES
            // сортируем пациентов по дате попадания в реестры
            index on str(kod_hum,7)+dtos(rees->DSCHET) to (cur_dir+"tmp_rhum")
            select TMP2
            go top
            do while !eof()
              r := r1 := 0
              select RHUM
              find (str(tmp2->kod_human,7))
              do while tmp2->kod_human == rhum->KOD_HUM
                ++r // во сколько реестров попал
                if rhum->reestr == mkod_reestr
                  r1 := r // какой по номеру текущий реестр
                endif
                skip
              enddo
              if r1 > 0 .and. r > r1  // если текущий реестр не последний
                is_other_reestr := .t. ; exit
              endif
              select TMP2
              skip
            enddo
          endif
          if is_delete_human
            func_error(10,"Некоторые пациенты из данного реестра уже УДАЛЕНЫ. Операция запрещена!")
          elseif is_other_reestr
            func_error(10,"Пациенты из данного реестра уже ПОПАЛИ В ДРУГОЙ РЕЕСТР. Операция запрещена!")
          else
            if !is_allow_delete .and. involved_password(1,rees_nschet,"аннулирования чтения протокола ФЛК")
              is_allow_delete := .t.
            endif
            if is_allow_delete
              close databases
              is_allow_delete := .f.
              R_Use(dir_server+"mo_rees",,"REES")
              goto (mkod_reestr)
              use (cur_dir+"tmp1file") new alias TMP1
              use (cur_dir+"tmp2file") new alias TMP2
              arr := {}
              aadd(arr,"Реестр № "+lstr(rees->nschet)+" от "+full_date(rees->dschet)+"г.")
              aadd(arr,'период "'+lstr(rees->nmonth)+"/"+lstr(rees->nyear)+;
                       '", сумма '+lput_kop(rees->summa,.t.)+;
                       " руб., кол-во пациентов "+lstr(rees->kol)+" чел.")
              aadd(arr,"")
              aadd(arr,"Аннулируется чтение протокола ФЛК № "+alltrim(tmp1->FNAME))
              aadd(arr,"кол-во пациентов с ошибкой "+lstr(tmp2->(lastrec()))+" чел.")
              aadd(arr,"После подтверждения аннулирования все последствия чтения")
              aadd(arr,"данного протокола ФЛК, а также сам протокол, будут удалены.")
              f_message(arr,,cColorSt2Msg,cColorSt1Msg)
              s := "Подтвердите аннулирование чтения протокола ФЛК"
              stat_msg(s) ; mybell(1)
              if f_Esc_Enter("аннулирования",.t.)
                stat_msg(s+" ещё раз.") ; mybell(3)
                if f_Esc_Enter("аннулирования",.t.)
                  mywait()
                  is_allow_delete := .t.
                endif
              endif
            endif
            // аннулируем последствия чтения реестра ФЛК
            if is_allow_delete
              close databases
              G_Use(dir_server+"mo_xml",,"MO_XML")
              G_Use(dir_server+"mo_rhum",,"RHUM")
              index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
              G_Use(dir_server+"human_",,"HUMAN_")
              use (cur_dir+"tmp2file") new alias TMP2
              set relation to kod_human into HUMAN_
              go top
              do while !eof()
                select RHUM
                find (str(tmp2->N_ZAP,6))
                G_RLock(forever)
                rhum->OPLATA := 0
                select HUMAN_
                G_RLock(forever)
                human_->OPLATA := 0
                human_->REESTR := mkod_reestr
                UnLock
                select TMP2
                skip
              enddo
              select MO_XML
              goto (mreestr_sp_tk)
              DeleteRec()
              close databases
              stat_msg("Протокол ФЛК успешно аннулирован.") ; mybell(5)
            endif
          endif
        endif
      endif
      mo_UnLock_Task(X_OMS)
    endif
  endif
endif
rest_box(buf)
return 0
