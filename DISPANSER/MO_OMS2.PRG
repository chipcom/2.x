***** режимы ввода данных для задачи ОМС (продолжение) - mo_oms2.prg
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 06.09.21 ввод направлений при подозрении на ЗНО - профосмотры несовершеннолетних
Function fget_napr_PN(k,r,c)
  Local r1, r2, n := 4, buf, tmp_keys, tmp_list, tmp_color
  local strNeedTabNumber := 'Необходимо указать табельный направившего врача'
  local recNumberDoctor := 0

  buf := savescreen()
  change_attr()
  tmp_keys := my_savekey()
  save gets to tmp_list
  //
  use_base('mo_pers', 'TPERS')
  use_base("luslf")
  Use_base("mo_su")
  use (cur_dir+"tmp_onkna") new alias TNAPR
  count_napr := lastrec()
  mNAPR_MO := space(6)
  if cur_napr > 0 .and. cur_napr <= count_napr
    goto (cur_napr) // номер текущего направления
    mNAPR_DATE := tnapr->NAPR_DATE
    select TPERS
    TPERS->(dbGoto(tnapr->KOD_VR))
    if !(TPERS->(eof())) .and. !(TPERS->(bof()))
      mTab_Number := TPERS->TAB_NOM
    else
      mTab_Number := 0
    endif
    select TNAPR
    m1NAPR_MO := tnapr->NAPR_MO
    if empty(m1NAPR_MO)
      mNAPR_MO := space(60)
    else
      mNAPR_MO := ret_mo(m1NAPR_MO)[_MO_SHORT_NAME]
    endif
    m1NAPR_V := tnapr->NAPR_V
    m1MET_ISSL := tnapr->MET_ISSL
    mu_kod := iif(m1napr_v == 3, tnapr->U_KOD, 0)
    mshifr := iif(m1napr_v == 3, tnapr->shifr_u, space(20))
    mshifr1 := iif(m1napr_v == 3, tnapr->shifr1, space(20))
    mname_u := iif(m1napr_v == 3, tnapr->name_u, space(65))
  else
    cur_napr := 1
    mNAPR_DATE := ctod("")
    mTab_Number := 0
    m1NAPR_MO := space(6)
    mNAPR_MO := space(60)
    m1NAPR_V := 0
    m1MET_ISSL := 0
    mu_kod := 0
    mshifr := space(20)
    mshifr1 := space(20)
    mname_u := space(65)
  endif
  mNAPR_V := inieditspr(A__MENUVERT, mm_napr_v, m1napr_v)
  mMET_ISSL := inieditspr(A__MENUVERT, mm_MET_ISSL, m1MET_ISSL)
  tip_onko_napr := 0
  j := r-9
  box_shadow(j,0,j+9,maxcol()-2,color1,"Ввод направлений при подозрении на ЗНО",color8)
  @ ++j,1 say "НАПРАВЛЕНИЕ №" get cur_napr pict "99" when .f.
  @ j,col() say "(из" get count_napr pict "99" when .f.
  @ j,col() say ")"
  @ j,29 say "(<F5> - добавление/редактирование направления №...)" color "G/B"
  @ ++j,3 say "Дата направления" get mNAPR_DATE ;
            valid {|| iif(empty(mNAPR_DATE) .or. between(mNAPR_DATE,mn_data,mk_data), .t., ;
            func_error(4,"Дата направления должна быть внутри сроков лечения")) }
  @ ++j,3 say "Табельный номер направившего врача" get mTab_Number pict "99999" ;
            valid {|g| iif(!v_kart_vrach(g), func_error(4, strNeedTabNumber), .t.) }
  @ ++j,3 say "В какую МО направлен" get mnapr_mo ;
            reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c)}},A__FUNCTION,,,.f.)}
  @ ++j,3 say "Вид направления" get mnapr_v ;
            reader {|x|menu_reader(x,mm_napr_v,A__MENUVERT,,,.f.)} //; color colget_menu
  @ ++j,5 say "Метод диагностического исследования" get mmet_issl ;
            reader {|x|menu_reader(x,mm_met_issl,A__MENUVERT,,,.f.)} ;
            when m1napr_v == 3 //; color colget_menu
  @ ++j,5 say "Медицинская услуга" get mshifr pict "@!" ;
            when {|g| m1napr_v == 3 .and. m1MET_ISSL > 0 } ;
            valid {|g|
                        Local fl := f5editkusl(g,2,2)
                        if empty(mshifr)
                          mu_kod  := 0
                          mname_u := space(65)
                          mshifr1 := mshifr
                        elseif fl .and. tip_onko_napr > 0 .and. tip_onko_napr != m1MET_ISSL
                          func_error(4,"Тип медуслуги не соответствует методу диагностического исследования")
                        endif
                        return fl
                   }
  @ ++j,7 say "Услуга" get mname_u when .f. color color14
  //
  set key K_F5 TO change_num_napr
  myread()
  set key K_F5

  select TPERS
  if TPERS->(dbSeek(str(mTab_Number,5)))
    recNumberDoctor := TPERS->(recno())
  else
    recNumberDoctor := 0
  endif

  close databases
  if !(emptyany(mNAPR_DATE,m1NAPR_V) .and. count_napr == 0)
    if cur_napr == 0
      cur_napr := 1
    endif
    use (cur_dir+"tmp_onkna") new alias TNAPR
    count_napr := lastrec()
    if cur_napr <= count_napr
      goto (cur_napr) // номер текущего направления
    else
      append blank
    endif
    tnapr->NAPR_DATE := mNAPR_DATE
    tnapr->KOD_VR := recNumberDoctor
    tnapr->NAPR_MO := m1NAPR_MO
    tnapr->NAPR_V := m1NAPR_V
    tnapr->MET_ISSL := iif(m1NAPR_V == 3, m1MET_ISSL, 0)
    tnapr->U_KOD := iif(m1NAPR_V == 3, mu_kod, 0)
    tnapr->shifr_u := iif(m1NAPR_V == 3, mshifr, "")
    tnapr->shifr1 := iif(m1NAPR_V == 3, mshifr1, "")
    tnapr->name_u := iif(m1NAPR_V == 3, mname_u, "")
    cur_napr := recno()
    count_napr := lastrec()
    use
  endif
  setcolor(tmp_color)
  restore gets from tmp_list
  my_restkey(tmp_keys)
  restscreen(buf)
  return {0,"Количество направлений - "+lstr(count_napr)}

***** 06.09.2021 редактировать другое направление (№...)
Function change_num_napr()
  Local r, n, fl := .f., tmp_keys, tmp_gets, buf, tmp_color := setcolor()
  local recNumberDoctor := 0

  if emptyany(mNAPR_DATE,m1NAPR_V)
    func_error(4,"Ещё не заполнено направление № "+lstr(cur_napr))
    return .t.
  endif
  tmp_keys := my_savekey()
  save gets to tmp_gets
  buf := savescreen()
  change_attr()
  r := 4
  if (n := input_value(r,33,r+2,77,color5,"Добавление/редактирование направления №",cur_napr,"99")) == NIL
    // отказ
  elseif eq_any(n,0,cur_napr)
    // выбрали то же направление, что и редактируется
  else
    if cur_napr == 0
      cur_napr := 1
    endif
    // select TPERS
    // if TPERS->(dbSeek(str(mTab_Number,5)))
    //   recNumberDoctor := TPERS->(recno())
    // else
      recNumberDoctor := 0
    // endif

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
    tnapr->KOD_VR := recNumberDoctor
    tnapr->NAPR_MO := m1NAPR_MO
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

      select TPERS
      TPERS->(dbGoto(tnapr->KOD_VR))
      if !(TPERS->(eof())) .and. !(TPERS->(bof()))
        mTab_Number := TPERS->TAB_NOM
      else
        mTab_Number := 0
      endif
      select TNAPR

      m1NAPR_MO := tnapr->NAPR_MO
      m1NAPR_V := tnapr->NAPR_V
      m1MET_ISSL := iif(m1napr_v == 3, tnapr->MET_ISSL, 0)
      mu_kod := iif(m1napr_v == 3, tnapr->U_KOD, 0)
      mshifr := iif(m1napr_v == 3, tnapr->shifr_u, space(20))
      mshifr1 := iif(m1napr_v == 3, tnapr->shifr1, space(20))
      mname_u := iif(m1napr_v == 3, tnapr->name_u, space(65))
    else
      cur_napr := count_napr+1
      mNAPR_DATE := ctod("")
      mTab_Number := 0
      m1NAPR_MO := space(6)
      mNAPR_MO := space(60)
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
  
***** 23.01.17
Function f_valid_diag_oms_sluch_DVN(get,k)
Local sk := lstr(k)
Private pole_diag := "mdiag"+sk,;
        pole_d_diag := "mddiag"+sk,;
        pole_pervich := "mpervich"+sk,;
        pole_1pervich := "m1pervich"+sk,;
        pole_stadia := "m1stadia"+sk,;
        pole_dispans := "mdispans"+sk,;
        pole_1dispans := "m1dispans"+sk,;
        pole_d_dispans := "mddispans"+sk
if get == NIL .or. !(&pole_diag == get:original)
  if empty(&pole_diag)
    &pole_pervich := space(12)
    &pole_1pervich := 0
    &pole_d_diag := ctod("")
    &pole_stadia := 1
    &pole_dispans := space(3)
    &pole_1dispans := 0
    &pole_d_dispans := ctod("")
  else
    &pole_pervich := inieditspr(A__MENUVERT, mm_pervich, &pole_1pervich)
    &pole_dispans := inieditspr(A__MENUVERT, mm_danet, &pole_1dispans)
  endif
endif
if emptyall(m1dispans1,m1dispans2,m1dispans3,m1dispans4,m1dispans5)
  m1dispans := 0
elseif m1dispans == 0
  m1dispans := ps1dispans
endif
mdispans := inieditspr(A__MENUVERT, mm_dispans, m1dispans)
update_get(pole_pervich)
update_get(pole_d_diag)
update_get(pole_stadia)
update_get(pole_dispans)
update_get(pole_d_dispans)
update_get("mdispans")
return .t.

// ***** 19.06.19 рабочая ли услуга ДВН в зависимости от этапа, возраста и пола
// Function f_is_usl_oms_sluch_DVN(i,_etap,_vozrast,_pol,/*@*/_diag,/*@*/_otkaz,/*@*/_ekg)
// Local fl := .f., ars := {}, ar := dvn_arr_usl[i]
// if valtype(ar[3]) == "N"
//   fl := (ar[3] == _etap)
// else
//   fl := ascan(ar[3],_etap) > 0
// endif
// _diag := (ar[4] == 1)
// _otkaz := 0
// _ekg := .f.
// if valtype(ar[2]) == "C"
//   aadd(ars,ar[2])
// else
//   ars := aclone(ar[2])
// endif
// if eq_any(_etap,1,3) .and. ar[5] == 1 .and. ascan(ars,"4.20.1") == 0
//   _otkaz := 1 // можно ввести отказ
//   if valtype(ar[2]) == "C" .and. eq_ascan(ars,"7.57.3","7.61.3","4.1.12")
//     _otkaz := 2 // можно ввести невозможность
//     if ascan(ars,"4.1.12") > 0 // взятие мазка
//       _otkaz := 3 // заменить на приём фельдшера-акушера
//     endif
//   endif
// endif
// if fl .and. eq_any(_etap,1,4,5)
//   if _etap == 1
//     i := iif(_pol == "М", 6, 7)
//   elseif len(ar) < 14
//     return .f.
//   else
//     i := iif(_pol == "М", 13, 14)
//   endif
//   if valtype(ar[i]) == "N" // специально для услуги "Электрокардиография","13.1.1" ранее 2018 года
//     fl := (ar[i] != 0)
//     if ar[i] < 0  // ЭКГ
//       _ekg := (_vozrast < abs(ar[i])) // необязательный возраст
//     endif
//   else // для 1,4,5 этапа возраст указан массивом
//     fl := ascan(ar[i],_vozrast) > 0
//   endif
// endif
// if fl .and. eq_any(_etap,2,3)
//   i := iif(_pol=="М", 8, 9)
//   if valtype(ar[i]) == "N"
//     fl := (ar[i] != 0)
//   elseif type("is_disp_19") == "L" .and. is_disp_19
//     fl := ascan(ar[i],_vozrast) > 0
//   else // для 2 этапа и профилактики возраст указан диапазоном
//     fl := between(_vozrast,ar[i,1],ar[i,2])
//   endif
// endif
// return fl

***** 16.06.19 рабочая ли услуга (умолчание) ДВН в зависимости от этапа, возраста и пола
Function f_is_umolch_sluch_DVN(i,_etap,_vozrast,_pol)
Local fl := .f., j, ta, ar := dvn_arr_umolch[i]
if _etap > 3
  return fl
endif
if valtype(ar[3]) == "N"
  fl := (ar[3] == _etap)
else
  fl := ascan(ar[3],_etap) > 0
endif
if fl
  if _etap == 1
    i := iif(_pol=="М", 4, 5)
  else//if _etap == 3
    i := iif(_pol=="М", 6, 7)
  endif
  if valtype(ar[i]) == "N"
    fl := (ar[i] != 0)
  elseif valtype(ar[i]) == "C"
    // "18,65" - для краткого инд.проф.консультирования
    ta := list2arr(ar[i])
    for i := len(ta) to 1 step -1
      if _vozrast >= ta[i]
        for j := 0 to 99
          if _vozrast == int(ta[i]+j*3)
            fl := .t. ; exit
          endif
        next
        if fl ; exit ; endif
      endif
    next
  else
    fl := between(_vozrast,ar[i,1],ar[i,2])
  endif
endif
return fl

*

***** 04.02.21 скорректировать массивы по диспансеризации
Function ret_arrays_disp(is_disp_19,tis_disp_21)
Static sp := 0
Local p := iif(is_disp_19, 2, 1), blk
DEFAULT tis_disp_21 TO .t.

if p != sp
  if (sp := p) == 1
    dvn_arr_usl := aclone(dvn_arr_usl18)
    dvn_arr_umolch := aclone(dvn_arr_umolch18)
  else
    blk := {|d1,d2,d|
                      Local i, arr := {}
                      DEFAULT d TO 1
                      for i := d1 to d2 step d
                        aadd(arr,i)
                      next
                      return arr
           }
    // 1- наименование меню
    // 2- шифр услуги
    // 3- этап (1,2,3,4,5)
    // 4- что-то связано с диагнозом



    //  10- V002 - Классификатор прифилей оказанной медицинской помощи
    //  11- V004 - Классификатор медицинских специальностей
   if tis_disp_21
     dvn_arr_usl := {; // Услуги на экран для ввода
      {"Измерение внутриглазного давления","3.4.9",1,0,1,;
        eval(blk,40,99),;
        eval(blk,40,99),;
        1,1,65,{1112};
       },;
      {"Исследование крови на общий холестерин","4.12.174",{1,3},0,1,;
        1,1,1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Исследование уровня глюкозы в крови","4.12.169",{1,3},0,1,;
        1,1,1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Исследование крови на гликированный гемо-ин","4.12.775",2,0,1,;
        1,1,1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Клинический анализ крови (3 показателя)","4.11.137",1,0,1,;
        eval(blk,40,99),;
        eval(blk,40,99),;
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Исследование кала на скрытую кровь","4.8.4",1,0,1,;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,65,66,67,68,69,70,71,72,73,74,75},;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,65,66,67,68,69,70,71,72,73,74,75},;
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Кровь на простат-специфический антиген","4.14.66",1,0,1,;
        {45,50,55,60,64},;
        0,;
        1,0,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Осмотр акушеркой или акушером-гинекологом","2.3.1",{1,3},0,1,; // женщины
        0,1,0,1,{3,42,136},{2003,2002,1101},;
        {{"2.3.1",136},{"2.3.3",3},{"2.3.3",42}},1,1;
       },;
      {"Взятие мазка (соскоба) с пов-ти шейки матки","4.1.12",1,0,1,; // женщины
        0,;
        {18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63},;
        1,1,{3,42,136},{2003,2002,1101};
       },;
      {"Иссл-е взятого цитологического материала","4.20.1",1,0,1,; // если невозможна 4.1.12
        0,;
        {18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63},;     // то очистить
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};               // эту услугу
       },;
      {"Маммография обеих молочных желез","7.57.3",1,0,1,; // женщины
        0,;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74},;
        0,1,78,{1118,1802,2020};
       },;
      {"Флюорография лёгких профилактическая","7.61.3",{1,3},0,1,;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        78,{1118,1802,2020};
       },;
      {"Электрокардиография (в покое)","13.1.1",{1,3},0,1,;
        eval(blk,35,99),;
        eval(blk,35,99),;
        eval(blk,35,99),;
        eval(blk,35,99),;
        111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202,2021};
       },;
      {"Фиброэзофагогастродуоденоскопия","10.3.13",1,0,1,;
        {45},;
        {45},;
        1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"Фиброэзофагогастродуоденоскопия","10.3.713",2,0,1,;
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"Спирометрия","16.1.717",2,0,1,; // "2.84.11"
        1,1,1,1,111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202,2021};
       },;
      {"Дуплексное сканир-ие брахиоцефальных артерий","8.23.706",2,0,1,; // "2.84.1"
        1,1,1,1,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203};
       },;
      {"Рентгенография органов грудной клетки","7.2.702",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"КТ органов грудной полости","7.2.701",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"Спиральная КТ легких","7.2.703",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"КТ органов грудной полости (с контрастир-ием)","7.2.704",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"Однофотонная эмиссионная КТ легких","7.2.705",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"Ректосигмоколоноскопия диагностическая","10.6.710",2,0,1,; // "2.84.6"
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"Ректороманоскопия","10.4.701",2,0,1,;                      // "2.84.6"
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"Углубленное профилактическое консультирование","56.1.723",2,0,1,;
        1,1,1,1,{97,57,42},{1122,1110,2002};
       },;
      {"Приём врача невролога","2.84.1",2,1,0,;
        1,1,1,1,53,{1109};
       },;
      {"Приём врача офтальмолога","2.84.3",2,1,0,;
        1,1,1,1,65,{1112};
       },;
      {"Приём врача оториноларинголога","2.84.8",2,1,0,;
        1,1,1,1,162,{1111};
       },;
      {"Приём врача уролога (хирурга)","2.84.10",2,1,0,;
        1,1,1,0,{108,112},{112603,1126};
       },;
      {"Приём врача акушера-гинеколога","2.84.5",2,1,0,;
        1,1,0,1,136,{1101};
       },;
      {"Приём врача колопроктолога (хирурга)","2.84.6",2,1,0,;
        1,1,1,1,{30,30,112},{112601,113503,1126};
       },;
      {"Приём врача дерматовенеролог","2.84.14",2,1,0,;
        1,1,1,1,16,{1104};
       },;
      {"Приём врача терапевта",{"2.3.7","2.84.11","2.3.2"},{1,2,3},1,0,;
        1,1,1,1,{97,57,42},{1122,1110,2002},;
        {{"2.3.7",57},{"2.3.7",97},{"2.3.2",57},{"2.3.2",97},{"2.3.4",42},{"2.84.11",57},{"2.84.11",97}},1,1;
       };
     }
    else
     dvn_arr_usl := {; // Услуги на экран для ввода
      {"Измерение внутриглазного давления","3.4.9",1,0,1,;
        eval(blk,40,99),;
        eval(blk,40,99),;
        1,1,65,{1112};
       },;
      {"Исследование крови на общий холестерин","4.12.174",{1,3},0,1,;
        1,1,1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Исследование уровня глюкозы в крови","4.12.169",{1,3},0,1,;
        1,1,1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Клинический анализ крови (3 показателя)","4.11.137",1,0,1,;
        eval(blk,40,99),;
        eval(blk,40,99),;
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Исследование кала на скрытую кровь","4.8.4",1,0,1,;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,65,66,67,68,69,70,71,72,73,74,75},;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,65,66,67,68,69,70,71,72,73,74,75},;
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Кровь на простат-специфический антиген","4.14.66",1,0,1,;
        {45,50,55,60,64},;
        0,;
        1,0,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Осмотр акушеркой или акушером-гинекологом","2.3.1",{1,3},0,1,; // женщины
        0,1,0,1,{3,42,136},{2003,2002,1101},;
        {{"2.3.1",136},{"2.3.3",3},{"2.3.3",42}},1,1;
       },;
      {"Взятие мазка (соскоба) с пов-ти шейки матки","4.1.12",1,0,1,; // женщины
        0,;
        {18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63},;
        1,1,{3,42,136},{2003,2002,1101};
       },;
      {"Иссл-е взятого цитологического материала","4.20.1",1,0,1,; // если невозможна 4.1.12
        0,;
        {18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63},;     // то очистить
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};               // эту услугу
       },;
      {"Маммография обеих молочных желез","7.57.3",1,0,1,; // женщины
        0,;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74},;
        0,1,78,{1118,1802,2020};
       },;
      {"Флюорография лёгких профилактическая","7.61.3",{1,3},0,1,;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        78,{1118,1802,2020};
       },;
      {"Электрокардиография (в покое)","13.1.1",{1,3},0,1,;
        eval(blk,35,99),;
        eval(blk,35,99),;
        eval(blk,35,99),;
        eval(blk,35,99),;
        111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202,2021};
       },;
      {"Фиброэзофагогастродуоденоскопия","10.3.13",1,0,1,;
        {45},;
        {45},;
        1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"Фиброэзофагогастродуоденоскопия","10.3.713",2,0,1,;
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"Спирометрия","16.1.717",2,0,1,; // "2.84.11"
        1,1,1,1,111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202,2021};
       },;
      {"Дуплексное сканир-ие брахиоцефальных артерий","8.23.706",2,0,1,; // "2.84.1"
        1,1,1,1,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203};
       },;
      {"Рентгенография органов грудной клетки","7.2.702",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"КТ органов грудной полости","7.2.701",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"Спиральная КТ легких","7.2.703",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"КТ органов грудной полости (с контрастир-ием)","7.2.704",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"Однофотонная эмиссионная КТ легких","7.2.705",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"Ректосигмоколоноскопия диагностическая","10.6.710",2,0,1,; // "2.84.6"
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"Ректороманоскопия","10.4.701",2,0,1,;                      // "2.84.6"
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"Углубленное профилактическое консультирование","56.1.723",2,0,1,;
        1,1,1,1,{97,57,42},{1122,1110,2002};
       },;
      {"Приём врача невролога","2.84.1",2,1,0,;
        1,1,1,1,53,{1109};
       },;
      {"Приём врача офтальмолога","2.84.3",2,1,0,;
        1,1,1,1,65,{1112};
       },;
      {"Приём врача оториноларинголога","2.84.8",2,1,0,;
        1,1,1,1,162,{1111};
       },;
      {"Приём врача уролога (хирурга)","2.84.10",2,1,0,;
        1,1,1,0,{108,112},{112603,1126};
       },;
      {"Приём врача акушера-гинеколога","2.84.5",2,1,0,;
        1,1,0,1,136,{1101};
       },;
      {"Приём врача колопроктолога (хирурга)","2.84.6",2,1,0,;
        1,1,1,1,{30,30,112},{112601,113503,1126};
       },;
      {"Приём врача терапевта",{"2.3.7","2.84.11","2.3.2"},{1,2,3},1,0,;
        1,1,1,1,{97,57,42},{1122,1110,2002},;
        {{"2.3.7",57},{"2.3.7",97},{"2.3.2",57},{"2.3.2",97},{"2.3.4",42},{"2.84.11",57},{"2.84.11",97}},1,1;
       };
     }
    endif
    //
    dvn_arr_umolch := {; // услуги, записываемые всегда по умолчанию
      {"Опрос (анкетирование)","56.1.16",{1,3},1,1,1,1,0},;
      {"Измерение артериального давления","3.1.5",{1,3},1,1,1,1,0},;
      {"Антропометрия, расчёт индекса массы тела","3.1.19",{1,3},1,1,1,1,0},;
      {"Определение относительного суммарного сердечно-сосудистого риска","56.1.18",{1,3},{18,39},{18,39},{18,39},{18,39},1},;
      {"Определение абсолютного суммарного сердечно-сосудистого риска","56.1.19",1,{40,64},{40,64},1,1,1},;
      {"Краткое индивидуальное профилактическое консультирование","56.1.14",1,"18,65","18,65",1,1,1};
    }
  endif
  count_dvn_arr_usl := len(dvn_arr_usl)
  count_dvn_arr_umolch := len(dvn_arr_umolch)
endif
return NIL

***** 15.06.18 скорректировать возраст диспансеризации для ветеранов
Function ret_vozr_DVN_veteran(_dvozrast,_data)
Local i, _arr_vozrast_DVN := ret_arr_vozrast_DVN(_data)
if ascan(_arr_vozrast_DVN,_dvozrast) == 0
  if _dvozrast < _arr_vozrast_DVN[1]
    _dvozrast := _arr_vozrast_DVN[1]
  elseif _dvozrast > atail(_arr_vozrast_DVN)
    _dvozrast := atail(_arr_vozrast_DVN)
  else
    for i := 2 to len(_arr_vozrast_DVN)
      if between(_dvozrast,_arr_vozrast_DVN[i-1],_arr_vozrast_DVN[i])
        if _dvozrast == _arr_vozrast_DVN[i-1] + 1
          _dvozrast := _arr_vozrast_DVN[i-1]
        else
          _dvozrast := _arr_vozrast_DVN[i]
        endif
        exit
      endif
    next
  endif
endif
return _dvozrast

***** 15.06.19 вернуть массив возрастов дисп-ии для старого или нового Приказов МЗ РФ
Function ret_arr_vozrast_DVN(_data)
Static sp := 0, arr := {}
Local i, p := iif(_data < d_01_05_2019, 1, 2)
if p != sp
  arr := aclone(arr_vozrast_DVN) // по старому Приказу МЗ РФ
  if (sp := p) == 2 // по новому Приказу МЗ РФ
    asize(arr,7) // уберём хвост после 39 лет {21,24,27,30,33,36,39,
    Ins_Array(arr,1,18) // вставим в начало =18 лет
    for i := 40 to 99
      aadd(arr,i) // добавим в конец подряд с 40 по 99 лет
    next
  endif
endif
return arr

***** 02.07.19
Function ret_ndisp(lkod_h,lkod_k,/*@*/new_etap,/*@*/msg)
Local i, i1, i2, i3, i4, i5, s, s1, is_disp, ar, fl := .t.
is_disp_19 := !(mk_data < d_01_05_2019)
is_disp_21 := !(mk_data < d_01_01_2021)
ret_arrays_disp(is_disp_19,is_disp_21)
msg := " "
new_etap := metap
is_dostup_2_year := .f.
if m1veteran == 1
  mdvozrast := ret_vozr_DVN_veteran(mdvozrast,mk_data)
endif
if !(is_disp := ascan(ret_arr_vozrast_DVN(mk_data),mdvozrast) > 0)
  if !is_disp_19 // по старому приказу МЗ РФ
    is_dostup_2_year := ascan(arr2m_vozrast_DVN,mdvozrast) > 0
    if !is_dostup_2_year .and. mpol == "Ж"
      is_dostup_2_year := ascan(arr2g_vozrast_DVN,mdvozrast) > 0
    endif
  endif
endif
if metap == 0
  if is_disp
    new_etap := 1
  else
    new_etap := 3
  endif
elseif metap == 3
  if is_disp
    new_etap := 1
  else
    // остаётся = 3
  endif
else
  if is_disp
    // остаётся = 1 или 2
  elseif new_etap < 4
    new_etap := 3
  endif
endif
ar := ret_etap_DVN(lkod_h,lkod_k)
if new_etap != 3
  if empty(ar[1]) // в этом году ещё ничего не делали
    // оставляем 1
  else
    i1 := i2 := i3 := i4 := i5 := 0
    for i := 1 to len(ar[1])
      do case
        case ar[1,i,1] == 1 // дисп-ия 1 этап
          i1 := i
        case ar[1,i,1] == 2 // дисп-ия 2 этап
          i2 := i
        case ar[1,i,1] == 3 // профилактика
          i3 := i
          msg := date_8(ar[1,i,2])+"г. уже проведён профилактический медосмотр!"
        case ar[1,i,1] == 4 // дисп-ия 1 этап 1 раз в 2 года
          i4 := i
          msg := "В "+lstr(year(mn_data))+" году уже проведена диспансеризации 1 раз в 2 года"
        case ar[1,i,1] == 5 // дисп-ия 2 этап 1 раз в 2 года
          i5 := i
          msg := "В "+lstr(year(mn_data))+" году уже проведена диспансеризации 1 раз в 2 года"
      endcase
    next
    if eq_any(new_etap,1,2) .and. new_etap != metap
      if i1 == 0
        new_etap := 1 // делаем 1 этап
      elseif i2 == 0
        new_etap := 2 // делаем 2 этап
      endif
    endif
    if i1 > 0 .and. i2 > 0
      msg := "В "+lstr(year(mn_data))+" году уже проведены оба этапа диспансеризации!"
    elseif i1 > 0 .and. !empty(ar[1,i1,2]) .and. ar[1,i1,2] > mn_data
      msg := "Диспансеризация I этапа закончилась "+date_8(ar[1,i1,2])+"г.!"
    endif
    if eq_any(new_etap,4,5) .and. new_etap != metap
      if i4 == 0
        new_etap := 4 // делаем 1 этап
      elseif i5 == 0
        new_etap := 5 // делаем 2 этап
      endif
    endif
    if i4 > 0 .and. i5 > 0
      msg := "В "+lstr(year(mn_data))+" году уже проведены оба этапа диспансеризации (раз в 2 года)!"
    elseif i4 > 0 .and. !empty(ar[1,i4,2]) .and. ar[1,i4,2] > mn_data
      msg := "Диспансеризация I этапа (раз в 2 года) закончилась "+date_8(ar[1,i4,2])+"г.!"
    endif
  endif
else //if new_etap == 3
  if empty(ar[1]) // в этом году ещё ничего не делали
    if empty(ar[2]) // посмотрим прошлый год
      // оставляем 3
    elseif ascan(ar[2],{|x| x[1] == 3 }) > 0 // профилактика была в прошлом году
      if is_dostup_2_year
        new_etap := 4 // сразу разрешаем дисп-ию 1 раз в 2 года, т.к. в прошлом
      else
        msg := "Профилактика проводится 1 раз в 2 года ("+date_8(ar[2,1,2])+"г. уже проведена)"
      endif
    endif
  else
    i1 := i2 := i3 := i4 := i5 := 0
    for i := 1 to len(ar[1])
      do case
        case ar[1,i,1] == 1 // дисп-ия 1 этап
          i1 := i
          msg := date_8(ar[1,i,2])+"г. уже проведена диспансеризация I этапа!"
        case ar[1,i,1] == 2 // дисп-ия 2 этап
          i2 := i
          msg := date_8(ar[1,i,2])+"г. уже проведена диспансеризация II этапа!"
        case ar[1,i,1] == 3 // профилактика
          i3 := i
          msg := date_8(ar[1,i,2])+"г. уже проведён профилактический медосмотр!"
        case ar[1,i,1] == 4 // дисп-ия 1 этап раз в 2 года
          i4 := i
        case ar[1,i,1] == 5 // дисп-ия 2 этап раз в 2 года
          i5 := i
      endcase
    next
    if i4 > 0
      if i5 > 0
        msg := "В "+lstr(year(mn_data))+" году уже проведены оба этапа диспансеризации (раз в 2 года)!"
      elseif !empty(ar[1,i4,2]) .and. ar[1,i4,2] > mn_data
        msg := "Диспансеризация I этапа (раз в 2 года) закончилась "+date_8(ar[1,i4,2])+"г.!"
      else
        new_etap := 5 // делаем 2 этап
      endif
    endif
  endif
endif
if empty(msg)
  metap := new_etap
  mndisp := inieditspr(A__MENUVERT, mm_ndisp, metap)
else
  metap := 0
  mndisp := space(23)
  func_error(4,fam_i_o(mfio)+" "+msg)
endif
return fl

***** 15.06.19
Function ret_etap_DVN(lkod_h,lkod_k)
Local ae := {{},{}}, fl, i, k, d1 := year(mn_data)
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
set relation to recno() into HUMAN_
find (str(lkod_k,7))
do while human->kod_k == lkod_k .and. !eof()
  fl := (lkod_h != human->(recno()))
  if fl .and. human->schet > 0 .and. human_->oplata == 9
    fl := .f. // лист учёта снят по акту и выставлен повторно
  endif
  if fl .and. between(human->ishod,201,205) // ???
    i := human->ishod-200
    if year(human->n_data) == d1 // текущий год
      aadd(ae[1],{i,human->k_data,human_->RSLT_NEW})
    //elseif i >= 3 .and. mk_data < d_01_05_2019 .and. year(human->n_data) == d1-1 // профилактика прошлый год ???
      //aadd(ae[2],{i,human->k_data,human_->RSLT_NEW})
    endif
  endif
  skip
enddo
close databases
return ae

***** 08.08.13 вернуть тип массы в строке
Function ret_tip_mas(_WEIGHT,_HEIGHT,/*@*/ret)
Static mm_tip_mas := {{"Дефицит массы тела",0,18.4},;
                      {"Нормальная масса тела",18.5,24.9},;
                      {"Избыточная масса тела",25.0,29.9},;
                      {"Ожирение I степени",30.0,34.9},;
                      {"Ожирение II степени",35.0,39.9},;
                      {"Ожирение III степени",40.0,9999}}
Local i, k, s := ""
ret := 2
if !emptyany(_WEIGHT,_HEIGHT)
  _HEIGHT /= 100  // рост из сантиметров в метры
  k := round(_WEIGHT/_HEIGHT/_HEIGHT,1) // индекс Кетле
  if (i := ascan(mm_tip_mas,{|x| between(k,x[2],x[3]) })) > 0
    ret := i
    s := mm_tip_mas[i,1]
  endif
endif
return padr(s,21)

***** 16.02.2020 является ли выходным (праздничным) днём проведения диспансеризации
Function f_is_prazdnik_DVN(_n_data)
return !is_work_day(_n_data)

/*
70.7.1	Законченный случай диспансеризации взрослых 1 этап (мужчины 18,24,30)
70.7.2	Законченный случай диспансеризации взрослых 1 этап (мужчины 21,27,33)
70.7.3	Законченный случай диспансеризации взрослых 1 этап (мужчины 40,44,46,52,56,58,62)
70.7.4	Законченный случай диспансеризации взрослых 1 этап (мужчины 42,48,54)
70.7.5	Законченный случай диспансеризации взрослых 1 этап (мужчины 41,43,47,49,53,59)
70.7.6	Законченный случай диспансеризации взрослых 1 этап (мужчины 50,64)
70.7.7	Законченный случай диспансеризации взрослых 1 этап (мужчины 51,57,63)
70.7.8	Законченный случай диспансеризации взрослых 1 этап (мужчины 55)
70.7.9	Законченный случай диспансеризации взрослых 1 этап (мужчины 60)
70.7.10	Законченный случай диспансеризации взрослых 1 этап (мужчины 61)
70.7.11	Законченный случай диспансеризации взрослых 1 этап (мужчины 36)
70.7.12	Законченный случай диспансеризации взрослых 1 этап (мужчины 39)
70.7.13	Законченный случай диспансеризации взрослых 1 этап (мужчины 45)
70.7.14	Законченный случай диспансеризации взрослых 1 этап (женщины 18,24,30)
70.7.15	Законченный случай диспансеризации взрослых 1 этап (женщины 21,27,33)
70.7.16	Законченный случай диспансеризации взрослых 1 этап (женщины 42,48,54,60)
70.7.17	Законченный случай диспансеризации взрослых 1 этап (женщины 40,44,46,50,52,56,58,62,64)
70.7.18	Законченный случай диспансеризации взрослых 1 этап (женщины 41,43,47,49)
70.7.19	Законченный случай диспансеризации взрослых 1 этап (женщины 51,57,63)
70.7.20	Законченный случай диспансеризации взрослых 1 этап (женщины 53,55,59,61)
70.7.21	Законченный случай диспансеризации взрослых 1 этап (женщины 36)
70.7.22	Законченный случай диспансеризации взрослых 1 этап (женщины 39)
70.7.23	Законченный случай диспансеризации взрослых 1 этап (женщины 45)
70.7.24	Законченный случай диспансеризации взрослых 1 этап (65,71)
70.7.25	Законченный случай диспансеризации взрослых 1 этап (66,70,72)
70.7.26	Законченный случай диспансеризации взрослых 1 этап (67,69,73,75)
70.7.27	Законченный случай диспансеризации взрослых 1 этап (68,74)
70.7.28	Законченный случай диспансеризации взрослых 1 этап (76,78,82,84,88,90,94,96)
70.7.29	Законченный случай диспансеризации взрослых 1 этап (80,86,92,98)
70.7.30	Законченный случай диспансеризации взрослых 1 этап (77,83,89,95)
70.7.31	Законченный случай диспансеризации взрослых 1 этап (79,81,85,87,91,93,97,99)
*/
***** 16.02.20 вернуть шифр услуги законченного случая для ДВН
Function ret_shifr_zs_DVN(_etap,_vozrast,_pol,_date)
Local lshifr := "", fl, is_disp, n := 1
if _date >= 0d20190501 // с 1 мая
  if _etap == 1
    if _pol == "М" // мужчины
      if eq_any(_vozrast,18,24,30)
        n := 1
      elseif eq_any(_vozrast,21,27,33)
        n := 2
      elseif eq_any(_vozrast,40,44,46,52,56,58,62)
        n := 3
      elseif eq_any(_vozrast,42,48,54)
        n := 4
      elseif eq_any(_vozrast,41,43,47,49,53,59)
        n := 5
      elseif eq_any(_vozrast,50,64)
        n := 6
      elseif eq_any(_vozrast,51,57,63)
        n := 7
      elseif _vozrast == 55
        n := 8
      elseif _vozrast == 60
        n := 9
      elseif _vozrast == 61
        n := 10
      elseif _vozrast == 36
        n := 11
      elseif _vozrast == 39
        n := 12
      elseif _vozrast == 45
        n := 13
      elseif eq_any(_vozrast,65,71)
        n := 24
      elseif eq_any(_vozrast,66,70,72)
        n := 25
      elseif eq_any(_vozrast,67,69,73,75)
        n := 26
      elseif eq_any(_vozrast,68,74)
        n := 27
      elseif eq_any(_vozrast,76,78,82,84,88,90,94,96)
        n := 28
      elseif eq_any(_vozrast,80,86,92,98)
        n := 29
      elseif eq_any(_vozrast,77,83,89,95)
        n := 30
      elseif eq_any(_vozrast,79,81,85,87,91,93,97,99)
        n := 31
      endif
    else // женщины
      if eq_any(_vozrast,18,24,30)
        n := 14
      elseif eq_any(_vozrast,21,27,33)
        n := 15
      elseif eq_any(_vozrast,42,48,54,60)
        n := 16
      elseif eq_any(_vozrast,40,44,46,50,52,56,58,62,64)
        n := 17
      elseif eq_any(_vozrast,41,43,47,49)
        n := 18
      elseif eq_any(_vozrast,51,57,63)
        n := 19
      elseif eq_any(_vozrast,53,55,59,61)
        n := 20
      elseif _vozrast == 36
        n := 21
      elseif _vozrast == 39
        n := 22
      elseif _vozrast == 45
        n := 23
      elseif eq_any(_vozrast,65,71)
        n := 32
      elseif eq_any(_vozrast,66,70,72)
        n := 33
      elseif eq_any(_vozrast,67,69,73,75)
        n := 34
      elseif eq_any(_vozrast,68,74)
        n := 35
      elseif eq_any(_vozrast,76,78,82,84,88,90,94,96)
        n := 36
      elseif eq_any(_vozrast,77,83,89,95)
        n := 37
      elseif eq_any(_vozrast,79,81,85,87,91,93,97,99)
        n := 38
      elseif eq_any(_vozrast,80,86,92,98)
        n := 39
      endif
    endif
    if m1g_cit == 2
      if m1mobilbr == 1
        n += 600
      else
        n += 500
      endif
    else
      if is_prazdnik
        n += 700
      elseif m1mobilbr == 1
        n += 300
      endif
    endif
    lshifr := "70.7."+lstr(n)
  elseif _etap == 3
    is_disp := (ascan(ret_arr_vozrast_DVN(_date),_vozrast) > 0)
/*
72.5.1	Законченный случай профилактического медицинского осмотра взрослых (мужчины 19,23,25,29,31)
72.5.2	Законченный случай профилактического медицинского осмотра взрослых (мужчины 20,22,26,28,32,34)
72.5.3	Законченный случай профилактического медицинского осмотра взрослых (мужчины 35,37)
72.5.4	Законченный случай профилактического медицинского осмотра взрослых (мужчины 38)
72.5.5	Законченный случай профилактического медицинского осмотра взрослых (женщины 19,23,25,29,31)
72.5.6	Законченный случай профилактического медицинского осмотра взрослых (женщины 20,22,26,28,32,34)
72.5.7	Законченный случай профилактического медицинского осмотра взрослых (женщины 35,37)
72.5.8	Законченный случай профилактического медицинского осмотра взрослых (женщины 38)
*/
    if !is_disp // профосмотр оформлен как обычно
      if _pol == "М" // мужчины
        if eq_any(_vozrast,19,23,25,29,31)
          n := 1
        elseif eq_any(_vozrast,20,22,26,28,32,34)
          n := 2
        elseif eq_any(_vozrast,35,37)
          n := 3
        else // _vozrast == 38
          n := 4
        endif
      else // женщины
        if eq_any(_vozrast,19,23,25,29,31)
          n := 5
        elseif eq_any(_vozrast,20,22,26,28,32,34)
          n := 6
        elseif eq_any(_vozrast,35,37)
          n := 7
        else // _vozrast == 38
          n := 8
        endif
      endif
      if is_prazdnik
        n += 700
      elseif m1mobilbr == 1
        n += 300
      endif
      // "6" - в рамках диспансерного наблюдения
      fl := .t.
      if type("is_disp_nabl") == "L" .and. is_disp_nabl
        fl := .f.
      endif
      lshifr := "72."+iif(fl,"5","6")+"."+lstr(n)
    else // если вместо диспансеризации оформляется профосмотр
/*
72.7.1	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 18,24,30)
72.7.2	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 21,27,33)
72.7.3	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 40,42,44,46,48,50,52,54,56,58,60,62,64)
72.7.4	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 41,43,45,47,49,51,53,55,57,59,61,63)
72.7.5	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 36)
72.7.6	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 39)
72.7.7	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 18,24,30)
72.7.8	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 21,27,33)
72.7.9	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 40,42,44,46,48,50,52,54,56,58,60,62,64)
72.7.10	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 41,43,45,47,49,51,53,55,57,59,61,63)
72.7.11	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 36)
72.7.12	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 39)
72.7.13	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99)
72.7.14	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98)
72.7.15	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99)
72.7.16	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98)
*/
      if _pol == "М" // мужчины
        if eq_any(_vozrast,18,24,30)
          n := 1
        elseif eq_any(_vozrast,21,27,33)
          n := 2
        elseif eq_any(_vozrast,40,42,44,46,48,50,52,54,56,58,60,62,64)
          n := 3
        elseif eq_any(_vozrast,41,43,45,47,49,51,53,55,57,59,61,63)
          n := 4
        elseif _vozrast == 36
          n := 5
        elseif _vozrast == 39
          n := 6
        elseif eq_any(_vozrast,65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99)
          n := 13
        elseif eq_any(_vozrast,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98)
          n := 14
        endif
      else // женщины
        if eq_any(_vozrast,18,24,30)
          n := 7
        elseif eq_any(_vozrast,21,27,33)
          n := 8
        elseif eq_any(_vozrast,40,42,44,46,48,50,52,54,56,58,60,62,64)
          n := 9
        elseif eq_any(_vozrast,41,43,45,47,49,51,53,55,57,59,61,63)
          n := 10
        elseif _vozrast == 36
          n := 11
        elseif _vozrast == 39
          n := 12
        elseif eq_any(_vozrast,65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99)
          n := 15
        elseif eq_any(_vozrast,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98)
          n := 16
        endif
      endif
      if is_prazdnik
        n += 700
      elseif m1mobilbr == 1
        n += 300
      endif
      lshifr := "72.7."+lstr(n)
    endif
  endif
elseif _etap == 1 // до 1 мая
  if _pol == "М" // мужчины
    if eq_any(_vozrast,21,24,27,30,33)
      lshifr := iif(m1lis > 0, "70.3.98", "70.3.97")
//70.3.97 ЗС дисп-ии мужчин (21,24,27,30,33 лет), 1 этап
//70.3.98 ЗС дисп-ии мужчин (21,24,27,30,33 лет) без гематологических исследований, 1 этап
    elseif eq_any(_vozrast,36,39,42,48,54)
      lshifr := iif(m1lis > 0, "70.3.100", "70.3.99")
//70.3.99 ЗС дисп-ии мужчин (36,39,42,48,54 лет), 1 этап
//70.3.100 ЗС дисп-ии мужчин (36,39,42,48,54 лет) без гематологических исследований, 1 этап
    elseif _vozrast == 45
      lshifr := iif(m1lis > 0, "70.3.199", "70.3.198")
//70.3.198 ЗС дисп-ии мужчин (45 лет), 1 этап
//70.3.199 ЗС дисп-ии мужчин (45 лет) без гематологических исследований, 1 этап
    elseif _vozrast == 51
      lshifr := iif(m1lis > 0, "70.3.105", "70.3.104")
//70.3.104 ЗС дисп-ии мужчин (51 года), 1 этап
//70.3.105 ЗС дисп-ии мужчин (51 года) без гематологических исследований, 1 этап
    elseif _vozrast == 57
      lshifr := iif(m1lis > 0, "70.3.109", "70.3.108")
//70.3.108 ЗС дисп-ии мужчин (57 лет), 1 этап
//70.3.109 ЗС дисп-ии мужчин (57 лет) без гематологических исследований, 1 этап
    elseif _vozrast == 60
      lshifr := iif(m1lis > 0, "70.3.113", "70.3.112")
//70.3.112 ЗС дисп-ии мужчин (60 лет), 1 этап
//70.3.113 ЗС дисп-ии мужчин (60 лет) без гематологических исследований, 1 этап
    elseif _vozrast == 63
      lshifr := iif(m1lis > 0, "70.3.115", "70.3.114")
//70.3.114 ЗС дисп-ии мужчин (63 лет), 1 этап
//70.3.115 ЗС дисп-ии мужчин (63 лет) без гематологических исследований, 1 этап
    elseif eq_any(_vozrast,66,72)
      lshifr := iif(m1lis > 0, "70.3.103", "70.3.102")
//70.3.102 ЗС дисп-ии мужчин (66,72 лет), 1 этап
//70.3.103 ЗС дисп-ии мужчин (66,72 лет) без гематологических исследований, 1 этап
    elseif _vozrast == 69
      lshifr := iif(m1lis > 0, "70.3.119", "70.3.118")
//70.3.118 ЗС дисп-ии мужчин (69 лет), 1 этап
//70.3.119 ЗС дисп-ии мужчин (69 лет) без гематологических исследований, 1 этап
    elseif eq_any(_vozrast,75,78,81,84)
      lshifr := iif(m1lis > 0, "70.3.165", "70.3.164")
//70.3.164 ЗС дисп-ии мужчин (75,78,81,84 лет), 1 этап
//70.3.165 ЗС дисп-ии мужчин (75,78,81,84 лет) без гематологических исследований, 1 этап
    else//if eq_any(_vozrast,87,90,93,96,99)
      lshifr := iif(m1lis > 0, "70.3.167", "70.3.166")
//70.3.166 ЗС дисп-ии мужчин (87,90,93,96,99 лет), 1 этап
//70.3.167 ЗС дисп-ии мужчин (87,90,93,96,99 лет) без гематологических исследований, 1 этап
    endif
  else // женщины
    if m1lis > 0 // без гематологических иссл-ий
      if eq_any(_vozrast,21,24,27)
        lshifr := "70.3.123"
//70.3.123 ЗС дисп-ии женщин (21,24,27 лет) без гематологических исследований, 1 этап
      elseif eq_any(_vozrast,30,33,36)
        lshifr := iif(m1g_cit == 2, "70.3.173", "70.3.125")
//70.3.125 ЗС дисп-ии женщин (30,33,36 лет) без гематологических исследований, 1 этап
//70.3.173 ЗС дисп-ии женщин (30,33,36 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif _vozrast == 39
        lshifr := iif(m1g_cit == 2, "70.3.175", "70.3.127")
//70.3.127 ЗС дисп-ии женщин (39 лет) без гематологических исследований, 1 этап
//70.3.175 ЗС дисп-ии женщин (39 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif _vozrast == 42
        lshifr := iif(m1g_cit == 2, "70.3.179", "70.3.131")
//70.3.131 ЗС дисп-ии женщин (42 лет) без гематологических исследований, 1 этап
//70.3.179 ЗС дисп-ии женщин (42 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif eq_any(_vozrast,45,48)
        lshifr := iif(m1g_cit == 2, "70.3.183", "70.3.135")
//70.3.135 ЗС дисп-ии женщин (45,48 лет) без гематологических исследований, 1 этап
//70.3.183 ЗС дисп-ии женщин (45,48 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif eq_any(_vozrast,51,57)
        lshifr := iif(m1g_cit == 2, "70.3.187", "70.3.149")
//70.3.149 ЗС дисп-ии женщин (51,57 лет) без гематологических исследований, 1 этап
//70.3.187 ЗС дисп-ии женщин (51,57 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif _vozrast == 54
        lshifr := iif(m1g_cit == 2, "70.3.191", "70.3.153")
//70.3.153 ЗС дисп-ии женщин (54 лет) без гематологических исследований, 1 этап
//70.3.191 ЗС дисп-ии женщин (54 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif _vozrast == 60
        lshifr := iif(m1g_cit == 2, "70.3.195", "70.3.157")
//70.3.157 ЗС дисп-ии женщин (60 лет) без гематологических исследований, 1 этап
//70.3.195 ЗС дисп-ии женщин (60 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif _vozrast == 63
        lshifr := "70.3.161"
//70.3.161 ЗС дисп-ии женщин (63 лет) без гематологических исследований, 1 этап
      elseif _vozrast == 66
        lshifr := "70.3.202"
//70.3.202 ЗС дисп-ии женщин (66 лет) без гематологических исследований, 1 этап
      elseif _vozrast == 69
        lshifr := "70.3.143"
//70.3.143 ЗС дисп-ии женщин (69 лет) без гематологических исследований, 1 этап
      elseif _vozrast == 72
        lshifr := "70.3.147"
//70.3.147 ЗС дисп-ии женщин (72 лет) без гематологических исследований, 1 этап
      elseif eq_any(_vozrast,75,78,81,84)
        lshifr := "70.3.169"
//70.3.169 ЗС дисп-ии женщин (75,78,81,84 лет) без гематологических исследований, 1 этап
      else//if eq_any(_vozrast,87,90,93,96,99)
        lshifr := "70.3.171"
//70.3.171 ЗС дисп-ии женщин (87,90,93,96,99 лет) без гематологических исследований, 1 этап
      endif
    else // гематологические иссл-ия проводятся в ЛПУ
      if eq_any(_vozrast,21,24,27)
        lshifr := "70.3.122"
//70.3.122 ЗС дисп-ии женщин (21,24,27 лет), 1 этап
      elseif eq_any(_vozrast,30,33,36)
        lshifr := iif(m1g_cit == 2, "70.3.172", "70.3.124")
//70.3.124 ЗС дисп-ии женщин (30,33,36 лет), 1 этап
//70.3.172 ЗС дисп-ии женщин (30,33,36 лет) без цитологического исследования, 1 этап
      elseif _vozrast == 39
        lshifr := iif(m1g_cit == 2, "70.3.174", "70.3.126")
//70.3.126 ЗС дисп-ии женщин (39 лет), 1 этап
//70.3.174 ЗС дисп-ии женщин (39 лет) без цитологического исследования, 1 этап
      elseif _vozrast == 42
        lshifr := iif(m1g_cit == 2, "70.3.178", "70.3.130")
//70.3.130 ЗС дисп-ии женщин (42 лет), 1 этап
//70.3.178 ЗС дисп-ии женщин (42 лет) без цитологического исследования, 1 этап
      elseif eq_any(_vozrast,45,48)
        lshifr := iif(m1g_cit == 2, "70.3.182", "70.3.134")
//70.3.134 ЗС дисп-ии женщин (45,48 лет), 1 этап
//70.3.182 ЗС дисп-ии женщин (45,48 лет) без цитологического исследования, 1 этап
      elseif eq_any(_vozrast,51,57)
        lshifr := iif(m1g_cit == 2, "70.3.186", "70.3.148")
//70.3.148 ЗС дисп-ии женщин (51,57 лет), 1 этап
//70.3.186 ЗС дисп-ии женщин (51,57 лет) без цитологического исследования, 1 этап
      elseif _vozrast == 54
        lshifr := iif(m1g_cit == 2, "70.3.190", "70.3.152")
//70.3.152 ЗС дисп-ии женщин (54 лет), 1 этап
//70.3.190 ЗС дисп-ии женщин (54 лет) без цитологического исследования, 1 этап
      elseif _vozrast == 60
        lshifr := iif(m1g_cit == 2, "70.3.194", "70.3.156")
//70.3.156 ЗС дисп-ии женщин (60 лет), 1 этап
//70.3.194 ЗС дисп-ии женщин (60 лет) без цитологического исследования, 1 этап
      elseif _vozrast == 63
        lshifr := "70.3.160"
//70.3.160 ЗС дисп-ии женщин (63 лет), 1 этап
      elseif _vozrast == 66
        lshifr := "70.3.140"
//70.3.140 ЗС дисп-ии женщин (66 лет), 1 этап
      elseif _vozrast == 69
        lshifr := "70.3.142"
//70.3.142 ЗС дисп-ии женщин (69 лет), 1 этап
      elseif _vozrast == 72
        lshifr := "70.3.146"
//70.3.146 ЗС дисп-ии женщин (72 лет), 1 этап
      elseif eq_any(_vozrast,75,78,81,84)
        lshifr := "70.3.168"
//70.3.168 ЗС дисп-ии женщин (75,78,81,84 лет), 1 этап
      else//if eq_any(_vozrast,87,90,93,96,99)
        lshifr := "70.3.170"
//70.3.170 ЗС дисп-ии женщин (87,90,93,96,99 лет), 1 этап
      endif
    endif
  endif
elseif _etap == 3
  if _pol == "М"
    if _vozrast < 45
      lshifr := iif(m1lis > 0, "72.1.14", "72.1.4")
    else
      lshifr := iif(m1lis > 0, "72.1.15", "72.1.5")
    endif
  else
    if _vozrast < 39
      lshifr := iif(m1lis > 0, "72.1.11", "72.1.1")
    elseif _vozrast < 45
      lshifr := iif(m1lis > 0, "72.1.12", "72.1.2")
    else
      lshifr := iif(m1lis > 0, "72.1.13", "72.1.3")
    endif
  endif
elseif _etap == 4
  if _pol == "М"
    lshifr := "70.3.101"
//70.3.101 ЗС дисп-ии мужчин (49,53,55,59,61,65,67,71,73), 1 этап (иссл.1 раз в 2 года)
  else
    if eq_any(_vozrast,49,53,55,59,61,65,67,71,73)
      lshifr := "70.3.138"
//70.3.138 ЗС дисп-ии женщин (49,53,55,59,61,65,67,71,73), 1 этап (иссл.1 раз в 2 года)
    else
      lshifr := "70.3.139"
//70.3.139 ЗС дисп-ии женщин (50,52,56,58,62,64,68,70), 1 этап (иссл.1 раз в 2 года)
    endif
  endif
endif
return lshifr

***** 06.05.15 вернуть "правильный" профиль для диспансеризации/профилактики
Function ret_profil_dispans(lprofil,lprvs)
if lprofil == 34 // если профиль по "клинической лабораторной диагностике"
  if ret_old_prvs(lprvs) == 2013 // и спец-ть "Лабораторное дело"
    lprofil := 37 // сменим на профиль по "лабораторному делу"
  elseif ret_old_prvs(lprvs) == 2011 // или "Лабораторная диагностика"
    lprofil := 38 // сменим на профиль по "лабораторной диагностике"
  endif
endif
return lprofil

***** 01.02.20
Function fget_spec_deti(k,r,c,a_spec)
Local tmp_select := select(), i, j, as := {}, s, blk, t_arr[BR_LEN], n_file := cur_dir+"tmpspecdeti"
if !hb_fileExists(n_file+sdbf)
  if select("MOSPEC") == 0
    R_Use(dir_exe+"_mo_spec",cur_dir+"_mo_spec","MOSPEC")
    //index on shifr+str(vzros_reb,1)+str(prvs_new,4) to (sbase)
  endif
  select MOSPEC
  find ("2.")
  do while left(mospec->shifr,2) == "2." .and. !eof()
    if mospec->vzros_reb == 1 // дети
      if ascan(as,mospec->prvs_new) == 0
        aadd(as,mospec->prvs_new)
      endif
    endif
    skip
  enddo
  if select("MOSPEC") > 0
    mospec->(dbCloseArea())
  endif
  for i := 1 to len(as)
    if (j := ascan(glob_arr_V015_V021,{|x| x[2] == as[i]})) > 0 // перевод из 21-го справочника
      as[i] := glob_arr_V015_V021[j,1]                          // в 15-ый справочник
    endif
  next
  dbcreate(n_file,{{"name","C",30,0},;
                   {"kod","C",4,0},;
                   {"kod_up","C",4,0},;
                   {"name1","C",50,0},;
                   {"is","L",1,0}})
  use (n_file) new alias SDVN
  use (cur_dir+"tmp_v015") index (cur_dir+"tmpkV015") new alias tmp_ga
  go top
  do while !eof()
    if (i := ascan(as,int(val(tmp_ga->kod)))) > 0
      select SDVN
      append blank
      sdvn->name := afteratnum(".",tmp_ga->name,1)
      sdvn->kod := tmp_ga->kod
      s := ""
      select TMP_GA
      rec := recno()
      do while !empty(tmp_ga->kod_up)
        find (tmp_ga->kod_up)
        if found()
          s += alltrim(afteratnum(".",tmp_ga->name,1))+"/"
        else
          exit
        endif
      enddo
      goto (rec)
      sdvn->name1 := s
    endif
    skip
  enddo
  sdvn->(dbCloseArea())
  tmp_ga->(dbCloseArea())
endif
use (n_file) new alias tmp_ga
do while !eof()
  tmp_ga->is := (ascan(a_spec,int(val(tmp_ga->kod))) > 0)
  skip
enddo
index on upper(name)+kod to (n_file)
if r <= maxrow()/2
  t_arr[BR_TOP] := r+1
  t_arr[BR_BOTTOM] := maxrow()-2
else
  t_arr[BR_BOTTOM] := r-1
  t_arr[BR_TOP] := 2
endif
blk := {|| iif(tmp_ga->is, {1,2}, {3,4}) }
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.f.}
t_arr[BR_COLUMN] := {;
  { " ", {|| iif(tmp_ga->is,""," ") }, blk },;
  { "Код", {|| left(tmp_ga->kod,3) },blk },;
  { center("Медицинская специальность",26), {|| padr(tmp_ga->name,26) },blk },;
  { center("подчинение",45), {|| left(tmp_ga->name1,45) },blk };
}
t_arr[BR_EDIT] := {|nk,ob| f1get_spec_DVN(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Ins>^ - отметить специальность/снять отметку со специальности") }
go top
edit_browse(t_arr)
s := ""
asize(a_spec,0)
go top
do while !eof()
  if tmp_ga->is
    s += alltrim(tmp_ga->kod)+","
    aadd(a_spec,int(val(tmp_ga->kod)))
  endif
  skip
enddo
if empty(s)
  s := "---"
else
  s := left(s,len(s)-1)
endif
tmp_ga->(dbCloseArea())
select (tmp_select)
return {1,s}

// ***** 01.02.17
// Function fget_spec_DVN(k,r,c,a_spec)
// Static as := {;
//   {8,2},;
//   {255,1},;
//   {112,1},;
//   {58,1},;
//   {65,1},;
//   {113,1},;
//   {133,1},;
//   {257,1},;
//   {114,1},;
//   {258,1},;
//   {115,1},;
//   {66,1},;
//   {116,1},;
//   {10,1},;
//   {32,1},;
//   {260,1},;
//   {118,1},;
//   {139,2},;
//   {59,1},;
//   {67,1},;
//   {120,1},;
//   {134,1},;
//   {14,2},;
//   {140,1},;
//   {261,1},;
//   {123,1},;
//   {17,1},;
//   {19,2},;
//   {20,2},;
//   {23,1},;
//   {262,1},;
//   {125,1},;
//   {138,1},;
//   {263,1},;
//   {126,1},;
//   {141,1},;
//   {75,1},;
//   {28,1},;
//   {145,2},;
//   {29,1},;
//   {30,2},;
//   {31,1},;
//   {97,1};
// }
// Local tmp_select := select(), s, blk, t_arr[BR_LEN], n_file := cur_dir+"tmpspecdvn"
// if !hb_fileExists(n_file+sdbf)
//   dbcreate(n_file,{{"name","C",30,0},;
//                    {"kod","C",4,0},;
//                    {"kod_up","C",4,0},;
//                    {"name1","C",50,0},;
//                    {"isn","N",1,0},;
//                    {"is","L",1,0}})
//   use (n_file) new alias SDVN
//   use (cur_dir+"tmp_v015") index (cur_dir+"tmpkV015") new alias tmp_ga
//   go top
//   do while !eof()
//     if (i := ascan(as,{|x| lstr(x[1]) == rtrim(tmp_ga->kod)})) > 0
//       select SDVN
//       append blank
//       sdvn->name := afteratnum(".",tmp_ga->name,1)
//       sdvn->kod := tmp_ga->kod
//       sdvn->isn := as[i,2]
//       s := ""
//       select TMP_GA
//       rec := recno()
//       do while !empty(tmp_ga->kod_up)
//         find (tmp_ga->kod_up)
//         if found()
//           s += alltrim(afteratnum(".",tmp_ga->name,1))+"/"
//         else
//           exit
//         endif
//       enddo
//       goto (rec)
//       sdvn->name1 := s
//     endif
//     skip
//   enddo
//   sdvn->(dbCloseArea())
//   tmp_ga->(dbCloseArea())
// endif
// use (n_file) new alias tmp_ga
// do while !eof()
//   tmp_ga->is := (ascan(a_spec,int(val(tmp_ga->kod))) > 0)
//   skip
// enddo
// if metap == 3
//   index on upper(name)+kod to (n_file)
// else
//   index on upper(name)+kod to (n_file) for isn == 1
// endif
// if r <= maxrow()/2
//   t_arr[BR_TOP] := r+1
//   t_arr[BR_BOTTOM] := maxrow()-2
// else
//   t_arr[BR_BOTTOM] := r-1
//   t_arr[BR_TOP] := 2
// endif
// blk := {|| iif(tmp_ga->is, {1,2}, {3,4}) }
// t_arr[BR_LEFT] := 0
// t_arr[BR_RIGHT] := 79
// t_arr[BR_COLOR] := color0
// t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.f.}
// t_arr[BR_COLUMN] := {;
//   { " ", {|| iif(tmp_ga->is,""," ") }, blk },;
//   { "Код", {|| left(tmp_ga->kod,3) },blk },;
//   { center("Медицинская специальность",26), {|| padr(tmp_ga->name,26) },blk },;
//   { center("подчинение",45), {|| left(tmp_ga->name1,45) },blk };
// }
// t_arr[BR_EDIT] := {|nk,ob| f1get_spec_DVN(nk,ob,"edit") }
// t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Ins>^ - отметить специальность/снять отметку со специальности") }
// go top
// edit_browse(t_arr)
// s := ""
// asize(a_spec,0)
// go top
// do while !eof()
//   if iif(metap == 3, .t., tmp_ga->isn==1) .and. tmp_ga->is
//     s += alltrim(tmp_ga->kod)+","
//     aadd(a_spec,int(val(tmp_ga->kod)))
//   endif
//   skip
// enddo
// if empty(s)
//   s := "---"
// else
//   s := left(s,len(s)-1)
// endif
// tmp_ga->(dbCloseArea())
// select (tmp_select)
// return {1,s}

// ***** 11.11.17
// Function f1get_spec_DVN(nKey,oBrow,regim)
// if regim == "edit" .and. nkey == K_INS
//   tmp_ga->is := !tmp_ga->is
//   keyboard chr(K_TAB)
// endif
// return 0

***** 20.01.19 гемодиализ (1) и перитонеальный диализ (2)
Function oms_sluch_dializ(par,Loc_kod,kod_kartotek)
// Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
// kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
Static SKOD_DIAG := 'N18.5', st_N_DATA, st_K_DATA, st_vrach := 0
Local top2 := {2,11}[par]
Local bg := {|o,k| get_MKB10(o,k,.t.) },;
      buf := savescreen(), tmp_color := setcolor(), a_smert := {},;
      p_uch_doc := "@!", pic_diag := "@K@!",;
      i, d, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0, arr_usl, fl, ss,;
      tmp_help := chm_help_code, fl_write_sluch := .f.
Static kod_ksg := "ds18.002", arr_lek := {;
  {"A25.28.001.001","препараты железа"},;
  {"A25.28.001.002","антианемические препараты (стимуляторы эритропоэза)"},;
  {"A25.28.001.003","антипаратиреоидные препараты"},;
  {"A25.28.001.004","препараты витамина D и его аналогов"},;
  {"A25.28.001.005","препараты аминокислот, включая комбинации с полипептидами"},;
  {"A25.28.001.006","препараты для лечения гиперкальциемии, гиперкалиемии и гиперфосфатемии"}}
//
Default st_N_DATA TO bom(sys_date), st_K_DATA TO eom(sys_date)
Private mkol_proc := 0, mkol_proc2 := 0,;
  MFIO        := space(50)         ,; // Ф.И.О. больного
  mfam := space(40), mim := space(40), mot := space(40),;
  mpol        := "М"            ,;
  mdate_r     := boy(addmonth(sys_date,-12*30)) ,;
  MVZROS_REB, M1VZROS_REB := 0,;
  MADRES      := space(50)         ,; // адрес больного
  m1MEST_INOG := 0, newMEST_INOG := 0,;
  MVID_UD                          ,; // вид удостоверения
  M1VID_UD    := 14                ,; // 1-18
  mser_ud := space(10), mnom_ud := space(20), ;
  mspolis := space(10), mnpolis := space(20), msmo := '34007',;
  mnamesmo, m1namesmo,;
  m1company := 0, mcompany, mm_company, ;
  m1KOMU := 0, MKOMU, M1STR_CRB := 0, ;
  mvidpolis, m1vidpolis := 1,;
  msnils := space(11),;
  mokatog := padr(alltrim(okato_umolch),11,"0"),;
  m1adres_reg := 1, madres_reg,;
  rec_inogSMO := 0, ;
  mkol[6], musl_lek[6],;
  mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100)
afill(mkol,0)
afill(musl_lek,0)
//
Private mkod := Loc_kod, mtip_h, is_talon := .f.,;
        mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
  M1LPU := glob_uch[1], MLPU,;
  M1OTD := glob_otd[1], MOTD,;
  M1FIO_KART := 1, MFIO_KART,;
  MUCH_DOC    := space(10)         ,; // вид и номер учетного документа
  MKOD_DIAG   := SKOD_DIAG         ,; // шифр 1-ой осн.болезни
  MKOD_DIAG2  := space(5)          ,; // шифр 2-ой осн.болезни
  MKOD_DIAG3  := space(5)          ,; // шифр 3-ой осн.болезни
  MKOD_DIAG4  := space(5)          ,; // шифр 4-ой осн.болезни
  MSOPUT_B1   := space(5)          ,; // шифр 1-ой сопутствующей болезни
  MSOPUT_B2   := space(5)          ,; // шифр 2-ой сопутствующей болезни
  MSOPUT_B3   := space(5)          ,; // шифр 3-ой сопутствующей болезни
  MSOPUT_B4   := space(5)          ,; // шифр 4-ой сопутствующей болезни
  MDIAG_PLUS  := space(8)          ,; // дополнения к диагнозам
  mrslt, m1rslt := 0         ,; // результат
  mishod, m1ishod := 0      ,; // исход
  MN_DATA     := st_N_DATA         ,; // дата начала лечения
  MK_DATA     := st_K_DATA         ,; // дата окончания лечения
  MVRACH      := space(10)         ,; // фамилия и инициалы лечащего врача
  M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0,; // код, таб.№ и спец-ть лечащего врача
  m1novor := 0, mnovor, mcount_reb := 0, ldnej := 0,;
  mDATE_R2 := ctod(""), mpol2 := " ",;
  m1USL_OK, m1PROFIL := 56, m1PROFIL_K := 41 // НЕФРОЛОГИЯ
//
Private mm_rslt := {}, mm_ishod := {}
if par == 1 // гемодиализ (1)
  m1USL_OK := 2
  aeval(glob_V009,{|x| iif(x[5]==m1usl_ok, aadd(mm_rslt,x), nil) })
  m1rslt := 201 ; m1ishod := 203
else // перитонеальный диализ (2)
  m1USL_OK := 3
  aeval(glob_V009,{|x| iif(x[5]==m1usl_ok.and.x[2]<316, aadd(mm_rslt,x), nil) })
  m1rslt := 314 ; m1ishod := 304
endif
aeval(glob_V012,{|x| iif(x[5]==m1usl_ok, aadd(mm_ishod,x), nil) })
//
R_Use(dir_server+"kartote_",,"KART_")
goto (kod_kartotek)
R_Use(dir_server+"kartotek",,"KART")
goto (kod_kartotek)
mFIO        := kart->FIO
mpol        := kart->pol
mDATE_R     := kart->DATE_R
m1VZROS_REB := kart->VZROS_REB
mADRES      := kart->ADRES
msnils      := kart->snils
if kart->MI_GIT == 9
  m1KOMU    := kart->KOMU
  M1STR_CRB := kart->STR_CRB
endif
if kart->MEST_INOG == 9 // т.е. отдельно занесены Ф.И.О.
  m1MEST_INOG := kart->MEST_INOG
endif
m1vidpolis  := kart_->VPOLIS // вид полиса (от 1 до 3);1-старый,2-врем.,3-новый
mspolis     := kart_->SPOLIS // серия полиса
mnpolis     := kart_->NPOLIS // номер полиса
msmo        := kart_->SMO    // реестровый номер СМО
m1vid_ud    := kart_->vid_ud   // вид удостоверения личности
mser_ud     := kart_->ser_ud   // серия удостоверения личности
mnom_ud     := kart_->nom_ud   // номер удостоверения личности
mokatog     := kart_->okatog       // код места жительства по ОКАТО
m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
//
arr := retFamImOt(1,.f.)
mfam := padr(arr[1],40)
mim  := padr(arr[2],40)
mot  := padr(arr[3],40)
if alltrim(msmo) == '34'
  mnameismo := ret_inogSMO_name(1,@rec_inogSMO)
elseif left(msmo,2) == '34'
  // Волгоградская область
elseif !empty(msmo)
  m1ismo := msmo ; msmo := '34'
endif
if eq_any(is_uchastok,1,3)
  MUCH_DOC := padr(amb_kartaN(),10)
elseif mem_kodkrt == 2
  MUCH_DOC := padr(lstr(mkod_k),10)
endif
close databases
chm_help_code := 3002
//
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
set relation to recno() into HUMAN_
// проверка исхода = СМЕРТЬ
find (str(mkod_k,7))
do while human->kod_k == mkod_k .and. !eof()
  if recno() != Loc_kod .and. is_death(human_->RSLT_NEW) .and. ;
                               human_->oplata != 9 .and. human_->NOVOR == 0
    a_smert := {"Данный больной умер!",;
                "Лечение с "+full_date(human->N_DATA)+;
                      " по "+full_date(human->K_DATA)}
    exit
  endif
  skip
enddo
if !(left(msmo,2) == '34') // не Волгоградская область
  m1ismo := msmo ; msmo := '34'
endif
if m1vrach > 0
  R_Use(dir_server+"mo_pers",,"P2")
  goto (m1vrach)
  MTAB_NOM := p2->tab_nom
  m1prvs := -ret_new_spec(p2->prvs,p2->prvs_new)
  mvrach := padr(fam_i_o(p2->fio)+" "+ret_tmp_prvs(m1prvs),36)
endif
close databases
fv_date_r( iif(Loc_kod>0,mn_data,) )
MFIO_KART := _f_fio_kart()
mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
mrslt     := inieditspr(A__MENUVERT, mm_rslt, m1rslt)
mishod    := inieditspr(A__MENUVERT, mm_ishod, m1ishod)
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
str_1 := iif(par==1,"гемодиализа","перитонеального диализа")+" за месяц"
if Loc_kod == 0
  str_1 := "Добавление "+str_1
  mtip_h := yes_vypisan
else
  str_1 := "Редактирование "+str_1
endif
setcolor(color8)
myclear(top2)
@ top2-1,0 say padc(str_1,80) color "B/BG*"
Private gl_area := {1,0,maxrow()-1,maxcol(),0}
status_key("^<Esc>^ - выход  ^<PgDn>^ - запись листов учёта")
setcolor(cDataCGet)
make_diagP(1)  // сделать "шестизначные" диагнозы
Private row_diag_screen := 9
diag_screen(0)
do while .t.
  j := top2
  if yes_num_lu == 1 .and. Loc_kod > 0
    @ j,50 say padl("Лист учета № "+lstr(Loc_kod),29) color color14
  endif
  //
  ++j; @ j,1 say "Учреждение" get mlpu when .f. color cDataCSay
       @ row(),col()+2 say "Отделение" get motd when .f. color cDataCSay
  //
  ++j; @ j,1 say "ФИО" get mfio_kart ;
       reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
       valid {|g,o| update_get("mkomu"),update_get("mcompany") }
  //
  ++j; @ j,1 say "Принадлежность счёта" get mkomu ;
             reader {|x|menu_reader(x,mm_komu,A__MENUVERT,,,.f.)} ;
             valid {|g,o| f_valid_komu(g,o) } ;
             color colget_menu
       @ row(),col()+1 say "==>" get mcompany ;
           reader {|x|menu_reader(x,mm_company,A__MENUVERT,,,.f.)} ;
           when diag_screen(2) .and. m1komu < 5 ;
           valid {|g| func_valid_ismo(g,m1komu,38) }
  //
  ++j; @ j,1 say "Полис ОМС: серия" get mspolis when m1komu == 0
       @ row(),col()+3 say "номер"  get mnpolis when m1komu == 0
       @ row(),col()+3 say "вид"    get mvidpolis ;
                    reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT,,,.f.)} ;
                    when diag_screen(2) .and. m1komu == 0 ;
                    valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
  //
  ++j; @ j,1 say "Основной диагноз" get mkod_diag picture pic_diag when .f. //reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mn_data,iif(m1novor==0,mpol,mpol2))
       @ row(),col() say ", соп.диагноз" get mkod_diag2 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mn_data,iif(m1novor==0,mpol,mpol2))
  //
  ++j; @ j,1 say "№ амб.карты" get much_doc picture "@!" ;
             when !(is_uchastok == 1 .and. is_task(X_REGIST)) ;
                   .or. mem_edit_ist==2
             //   !(    У23/12356     и есть "Регистратура")
       @ row(),col()+1 say "Врач" get MTAB_NOM pict "99999" ;
             valid {|g| v_kart_vrach(g,.t.) } when diag_screen(2)
       @ row(),col()+1 get mvrach when .f. color color14
  //
  ++j; @ j,1 say "Диализ проводился с" get mn_data valid {|g| f_d_dializ()}
       @ row(),col()+1 say            "по" get mk_data valid {|g| f_d_dializ()}
  //
  if par == 1
    ++j; @ j,1 say "Количество процедур лекарственной терапии:"
   for i := 1 to 6
    ++j; @ j,2 say arr_lek[i,1] get mkol[i] pict "99"
         @ j,col()+1 say arr_lek[i,2]
   next
    ++j; @ j,1 say "Количество НИЗКОпоточных процедур" get mkol_proc pict "99"
    ++j; @ j,1 say "Количество ВЫСОКОпоточных процедур" get mkol_proc2 pict "99"
  endif
  ++j; @ j,1 say "Результат обращения" get mrslt ;
           reader {|x|menu_reader(x,mm_rslt,A__MENUVERT,,,.f.)} ;
           valid {|g,o| f_valid_rslt(g,o) }
  //
  ++j; @ j,1 say "Исход заболевания" get mishod ;
           reader {|x|menu_reader(x,mm_ishod,A__MENUVERT,,,.f.)}
  if !empty(a_smert)
    n_message(a_smert,,"GR+/R","W+/R",,,"G+/R")
  endif
  if pos_read > 0 .and. lower(GetList[pos_read]:name) == "mishod"
    --pos_read
  endif
  count_edit := myread(,@pos_read,++k_read)
  diag_screen(2)
  k := f_alert({padc("Выберите действие",60,".")},;
               {" Выход без записи "," Запись "," Возврат в редактирование "},;
               iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
  if k == 3
    loop
  elseif k == 2
    if empty(mn_data)
      func_error(4,"Не введена дата начала процедур.")
      loop
    endif
    if empty(mk_data)
      func_error(4,"Не введена дата окончания процедур.")
      loop
    elseif year(mk_data) < 2018
      func_error(4,"Данный режим работает только с 2018 года.")
      loop
    endif
    if mk_data < mn_data
      func_error(4,"Дата окончания меньше даты начала процедур.")
      loop
    endif
    if !(left(dtos(mn_data),6) == left(dtos(mk_data),6))
      func_error(4,"Даты начала и окончания процедур не в одном отчётном месяце.")
      loop
    endif
    ldnej := mk_data - mn_data + 1
    vlek := vdial := 0
    if par == 1
      if empty(vdial := mkol_proc + mkol_proc2)
        func_error(4,"Количество процедур гемодиализа равно нулю")
        loop
      elseif mkol_proc + mkol_proc2 > ldnej
        func_error(4,"Количество процедур гемодиализа больше длительности лечения")
        loop
      endif
      vlek := 0
      for i := 1 to 6
        vlek += mkol[i]
      next
      if vlek > 0
        if year(mk_data) == 2018
          func_error(4,"Работа с лекарственными препаратами разрешена только с 2019 года.")
          loop
        elseif !(alltrim(mkod_diag) == "N18.5")
          func_error(4,"Для КСГ лекарственной терапии основной диагноз должен быть N18.5")
          loop
        endif
      endif
    endif
    if empty(CHARREPL("0",much_doc,space(10)))
      func_error(4,'Не заполнен номер амбулаторной карты')
      loop
    endif
    if m1vrach == 0
      func_error(4,'Не заполнен табельный номер лечащего врача')
      loop
    endif
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
    if empty(mkod_diag)
      func_error(4,"Не введен шифр основного заболевания.")
      loop
    endif
    err_date_diap(mn_data,"Дата начала процедур")
    err_date_diap(mk_data,"Дата окончания процедур")
    arr_usl := {}
    if par == 1
      if vlek > 0
        aadd(arr_usl,{"55.1.1",0,0,iif(vlek > vdial, vdial, vlek)})
      endif
      if mkol_proc > 0
        aadd(arr_usl,{"60.3.9",0,0,mkol_proc})
      endif
      if mkol_proc2 > 0
        aadd(arr_usl,{"60.3.10",0,0,mkol_proc2})
      endif
    else
      aadd(arr_usl,{"60.3.1",0,0,ldnej})
    endif
    fv_date_r(mn_data) // переопределение M1VZROS_REB
    Use_base("lusl")
    Use_base("luslc")
    Use_base("uslugi")
    R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                                dir_server+"uslugi1s"},"USL1")
    glob_podr := "" ; glob_otd_dep := 0 ; fl := .t.
    for i := 1 to len(arr_usl)
      arr_usl[i,2] := foundOurUsluga(arr_usl[i,1],mk_data,m1PROFIL,M1VZROS_REB,@arr_usl[i,3])
      if empty(arr_usl[i,2])
        fl := func_error(4,'Цена на услугу '+arr_usl[i,1]+' отсутствует в справочнике ТФОМС')
      endif
    next
    close databases
    if !fl
      loop
    endif
    k := f_alert({padc("Сейчас будет записан лист учёта. Выберите действие",60,".")},;
                 {" Выход без записи "," Запись "," Возврат в редактирование "},;
                 iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
    if k == 3
      loop
    elseif k == 1
      exit
    endif
    if mem_op_out == 2 .and. yes_parol
      box_shadow(19,10,22,69,cColorStMsg)
      str_center(20,'Оператор "'+fio_polzovat+'".',cColorSt2Msg)
      str_center(21,'Ввод данных за '+date_month(sys_date),cColorStMsg)
    endif
    mywait()
    make_diagP(2)  // сделать "пятизначные" диагнозы
    if m1komu == 0
      msmo := lstr(m1company)
      m1str_crb := 0
    else
      msmo := ""
      m1str_crb := m1company
    endif
    st_N_DATA := MN_DATA
    st_K_DATA := MK_DATA
    st_VRACH := m1vrach
    SKOD_DIAG := substr(MKOD_DIAG,1,5)
    Private mu_kod, mu_cena, fl_nameismo
    Use_base("lusl")
    Use_base("luslc")
    use_base("luslf")
    Use_base("mo_su")
    Use_base("uslugi")
    R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                                dir_server+"uslugi1s"},"USL1")
    G_Use(dir_server+"mo_hismo",,"SN")
    index on str(kod,7) to (cur_dir+"tmp_ismo")
    Use_base("mo_hu")
    use_base("human_u")
    Use_base("human")
    Add1Rec(7)
    mkod := recno()
    replace human->kod with mkod
    select HUMAN_
    do while human_->(lastrec()) < mkod
      APPEND BLANK
    enddo
    goto (mkod)
    G_RLock(forever)
    select HUMAN_2
    do while human_2->(lastrec()) < mkod
      APPEND BLANK
    enddo
    goto (mkod)
    G_RLock(forever)
    glob_perso := mkod
    //
    human->kod_k      := mkod_k
    human->TIP_H      := B_STANDART
    human->FIO        := MFIO          // Ф.И.О. больного
    human->POL        := MPOL          // пол
    human->DATE_R     := MDATE_R       // дата рождения больного
    human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
    human->ADRES      := MADRES        // адрес больного
    human->KOD_DIAG   := MKOD_DIAG     // шифр 1-ой осн.болезни
    human->KOD_DIAG2  := MKOD_DIAG2    // шифр 2-ой осн.болезни
    human->KOD_DIAG3  := MKOD_DIAG3    // шифр 3-ой осн.болезни
    human->KOD_DIAG4  := MKOD_DIAG4    // шифр 4-ой осн.болезни
    human->SOPUT_B1   := MSOPUT_B1     // шифр 1-ой сопутствующей болезни
    human->SOPUT_B2   := MSOPUT_B2     // шифр 2-ой сопутствующей болезни
    human->SOPUT_B3   := MSOPUT_B3     // шифр 3-ой сопутствующей болезни
    human->SOPUT_B4   := MSOPUT_B4     // шифр 4-ой сопутствующей болезни
    human->diag_plus  := mdiag_plus    //
    human->KOMU       := M1KOMU        // от 0 до 5
    human_->SMO       := msmo
    human->STR_CRB    := m1str_crb
    human->POLIS      := make_polis(mspolis,mnpolis) // серия и номер страхового полиса
    human->LPU        := M1LPU         // код учреждения
    human->OTD        := M1OTD         // код отделения
    human->UCH_DOC    := MUCH_DOC // вид и номер учетного документа
    human->N_DATA     := MN_DATA // дата начала лечения
    human->K_DATA     := MK_DATA // дата окончания лечения
    human->CENA := human->CENA_1 := 0 // стоимость лечения
    human_->DISPANS   := replicate("0",16)
    human_->POVOD     := 1
    //human_->TRAVMA    := m1travma
    human_->VPOLIS    := m1vidpolis
    human_->SPOLIS    := ltrim(mspolis)
    human_->NPOLIS    := ltrim(mnpolis)
    human_->OKATO     := "" // это поле вернётся из ТФОМС в случае иногороднего
    human_->NOVOR     := iif(m1novor==0, 0       , mcount_reb)
    human_->DATE_R2   := iif(m1novor==0, ctod(""), mDATE_R2  )
    human_->POL2      := iif(m1novor==0, ""      , mpol2     )
    human_->USL_OK    := m1USL_OK //
    human_->PROFIL    := m1PROFIL // 56
    human_->FORMA14   := "0000"
    human_->RSLT_NEW  := m1rslt
    human_->ISHOD_NEW := m1ishod
    human_->VRACH     := m1vrach
    human_->PRVS      := m1prvs
    human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
    human_->ST_VERIFY := 0 // снова ещё не проверен
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
    put_0_human_2()
    human_2->PROFIL_K := m1PROFIL_K // 41
    fl_nameismo := .f.
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
      select SN
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
    ss := 0
    // записываем услуги
    for i := 1 to len(arr_usl)
      select HU
      Add1Rec(7)
      mrec_hu := hu->(recno())
      replace hu->kod     with mkod,;
              hu->kod_vr  with m1vrach,;
              hu->kod_as  with 0,;
              hu->u_koef  with 1,;
              hu->u_kod   with arr_usl[i,2],;
              hu->u_cena  with arr_usl[i,3],;
              hu->is_edit with 0,;
              hu->date_u  with dtoc4(MN_DATA),;
              hu->otd     with m1otd,;
              hu->kol     with arr_usl[i,4],;
              hu->stoim   with arr_usl[i,3]*arr_usl[i,4],;
              hu->kol_1   with arr_usl[i,4],;
              hu->stoim_1 with arr_usl[i,3]*arr_usl[i,4],;
              hu->KOL_RCP with 0
      ss += arr_usl[i,3]*arr_usl[i,4]
      select HU_
      do while hu_->(lastrec()) < mrec_hu
        APPEND BLANK
      enddo
      goto (mrec_hu)
      G_RLock(forever)
      if Loc_kod == 0 .or. !valid_GUID(hu_->ID_U)
        hu_->ID_U := mo_guid(3,hu_->(recno()))
      endif
      hu_->PROFIL   := m1PROFIL
      hu_->PRVS     := m1PRVS
      hu_->kod_diag := mkod_diag
      hu_->zf       := ""
    next i
    if par == 1 .and. vlek > 0
      for i := 1 to len(arr_lek)
        if mkol[i] > 0
          mu_kod := append_shifr_mo_su(arr_lek[i,1])
          select MOHU
          Add1Rec(7)
          mohu->kod     := mkod
          mohu->kod_vr  := m1vrach
          mohu->kod_as  := 0
          mohu->u_kod   := mu_kod
          mohu->u_cena  := 0
          mohu->date_u  := dtoc4(MN_DATA)
          mohu->otd     := m1otd
          mohu->kol_1   := mkol[i]
          mohu->stoim_1 := 0
          mohu->ID_U    := mo_guid(4,mohu->(recno()))
          mohu->PROFIL  := m1PROFIL
          mohu->PRVS    := m1PRVS
          mohu->kod_diag := mkod_diag
        endif
      next
    endif
    human->CENA := human->CENA_1 := ss // стоимость лечения
    write_work_oper(glob_task,OPER_LIST,iif(Loc_kod==0,1,2),1,count_edit)
    fl_write_sluch := .t.
    close databases
    stat_msg("Запись завершена!",.f.)
    if par == 1 .and. vlek > 0
      f_1pac_definition_KSG(mkod)
    endif
  endif
  exit
enddo
close databases
diag_screen(2)
setcolor(tmp_color)
restscreen(buf)
chm_help_code := tmp_help
if fl_write_sluch // если записали - запускаем проверку
  verify_OMS_sluch(mkod)
endif
return nil

***** 04.07.19 добавить шифр манипуляции в свой справочник MO_SU
Function append_shifr_mo_su(lshifr,fl_commit)
Local lu_kod := 0, arr := {}
DEFAULT fl_commit TO .t.
select MOSU
set order to 3 // по шифру ФФОМС
find (padr(lshifr,20))
do while mosu->shifr1 == padr(lshifr,20) .and. !eof()
  aadd(arr,{iif(left(mosu->shifr,1)=="*",1,0),mosu->kod})
  skip
enddo
if !empty(arr)
  asort(arr,,,{|x,y| x[1] < y[1] }) // все старые стомат.услуги со звёздочкой в конец массива
  lu_kod := arr[1,2]
else
  select LUSLF
  find (padr(lshifr,20))
  select MOSU
  set order to 1
  FIND (STR(-1,6))
  if found()
    G_RLock(forever)
  else
    AddRec(6)
  endif
  lu_kod := mosu->kod := recno()
  mosu->name := luslf->name
  mosu->shifr1 := lshifr
  mosu->PROFIL := m1PROFIL
  if fl_commit
    UnLock
    Commit
  endif
endif
return lu_kod

***** 03.02.15
Static Function f_d_dializ()
if !(left(dtos(mn_data),6) == left(dtos(mk_data),6))
  func_error(4,"Даты начала и окончания процедур не в одном отчётном месяце.")
endif
return .t.

*

***** 27.11.14
Function create_FR_file_for_spravkaOMS()
dbCloseAll()
delFRfiles()
dbcreate(fr_titl,{{"name","C",255,0},;
                  {"adres","C",255,0},;
                  {"data","D",8,0},;
                  {"data1","D",8,0},;
                  {"data2","D",8,0},;
                  {"fio","C",60,0}})
use (fr_titl) new alias FRT
append blank
frt->name := glob_mo[_MO_FULL_NAME]
frt->adres := glob_mo[_MO_ADRES]
dbcreate(fr_data,{{"name","C",255,0},;
                  {"name1","C",55,0},;
                  {"shifr","C",10,0},;
                  {"kol","N",4,0},;
                  {"cena","N",11,2},;
                  {"summa","N",11,2}})
use (fr_data) new alias FRD
index on shifr to (cur_dir+"tmp1")
return NIL

*

***** 12.12.14 печать справки ОМС по готовому листу учёта
Function print_spravka_OMS(mkod)
// mkod - код больного по БД human
Local r1, c1, r2, c2, mdate, buf := save_maxrow(), msumma := 0, lshifr
get_row_col_max(18,4,@r1,@c1,@r2,@c2)
if (mdate := input_value(r1,c1,r2,c2,color1,;
      "Введите дату выдачи справки о стоимости мед.помощи по ОМС",;
      sys_date)) == NIL
  return NIL
endif
mywait()
create_FR_file_for_spravkaOMS()
Use_base("lusl")
Use_base("luslf")
R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                            dir_server+"uslugi1s"},"USL1")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
R_Use(dir_server+"human_",,"HUMAN_")
goto (mkod)
R_Use(dir_server+"human",,"HUMAN")
goto (mkod)
if mdate < human->k_data
  rest_box(buf)
  close databases
  return func_error(4,"Дата выдачи справки меньше даты окончания лечения!")
endif
frt->data := mdate
frt->data1 := human->n_data
frt->data2 := human->k_data
frt->fio := human->fio
Select HU
find (str(mkod,7))
do while hu->kod == mkod .and. !eof()
  if !emptyany(hu->kol_1,hu->stoim_1)
    usl->(dbGoto(hu->u_kod))
    lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    if is_usluga_TFOMS(usl->shifr,lshifr,human->k_data)
      lshifr := iif(empty(lshifr), usl->shifr, lshifr)
      select LUSL
      find (padr(lshifr,10))
      Select FRD
      find (padr(lshifr,10))
      if !found()
        append blank
        frd->shifr := lshifr
        frd->name := lusl->name  // наименование услуги из справочника ТФОМС
        frd->cena := hu->stoim_1 / hu->kol_1
      endif
      frd->kol += hu->kol_1
      frd->summa += hu->stoim_1
      msumma += hu->stoim_1
    endif
  endif
  select HU
  Skip
enddo
Select FRD
go top
do while !eof()
  if frd->kol > 1
    frd->name1 := " (в количестве "+lstr(frd->kol)+")"
  endif
  Skip
enddo
index on str(summa,11,2) to (fr_data) descending
G_Use(dir_server+"mo_sprav",,"SPR_OMS")
Locate for kod_h == mkod
if found()
  G_RLock(forever)
else
  append blank
  spr_oms->KOD_H  := mkod
  spr_oms->KOD_K  := 0
endif
spr_oms->FIO    := human->FIO
spr_oms->DATE_R := human->DATE_R
spr_oms->DATA   := mdate
spr_oms->N_DATA := human->n_data
spr_oms->K_DATA := human->k_data
if human_->USL_OK == 1
  spr_oms->TIP := 2  // стационар
elseif human_->USL_OK == 2
  spr_oms->TIP := 3  // дневной стационар
else
  spr_oms->TIP := 1  // амбулаторно
endif
spr_oms->STOIM  := human->CENA_1
close databases
rest_box(buf)
call_fr("mo_spravkaOMS")
return NIL

*

***** 27.11.14 Ввод и распечатка справки о стоимости оказанной медицинской помощи в сфере ОМС")
Function f_spravka_OMS()
Local i, j, k, k1, buf := savescreen(), rec_spr_oms := 0
k1 := polikl1_kart()
close databases // если вдруг вышли по <Esc>
//
Private mfio := space(50), mdate_r := ctod(""),;
        mdate := sys_date, mn_data := sys_date, mk_data := sys_date,;
        mstoim := 0, m1usl := 1, musl := " ", parr_usl := {},;
        p_box_buf, gl_area := {1,0,23,79,0}
if k1 > 0
  R_Use(dir_server+"kartotek",,"KART")
  goto (glob_kartotek)
  mfio    := kart->fio
  mdate_r := kart->date_r
  close databases
endif
Private r1 := maxrow()-18
do while .t.
  setcolor(cDataCGet)
  ClrLines(r1,maxrow()-1)
  @ r1-1,0 say padc("Справка ОМС",80) color "B/B*"
  if p_box_buf != NIL
    rest_box(p_box_buf)
  endif
  i := r1+1
  if k1 == 0
        @ i,1 say "Пациент" get mfio pict "@!"
        @ row(),col()+2 say "Дата р." get mdate_r
  else
        @ i,1 say "Пациент" color "G+/B" get mfio when .f.
        @ row(),col()+2 say "Дата р." color "G+/B" get mdate_r when .f.
  endif
  ++i ; @ i,1 say "Сроки лечения: с" get mn_data
        @ row(),col()+1 say "по" get mk_data
        @ row(),col()+7 say "Дата выдачи справки" get mdate ;
                        valid {|| __keyboard(CHR(K_ENTER)), .t. }
  ++i ; @ i,1 say "Оказанные услуги:" color color8 get musl ;
              reader {|x|menu_reader(x,{{|k,r,c| fu_spravka_OMS(r,c)}},A__FUNCTION,,,.f.)}
  status_key("^<Esc>^ - выход для печати")
  myread()
  do while (k := f_alert({padc("Выберите действие",60,".")},;
             {" Выход "," Печать справки "," Возврат в редактирование "},;
             2,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )) == 0
  enddo
  if k == 1
    exit
  elseif k == 2
    if empty(mfio)
      func_error(4,"Не введены Ф.И.О.")
      loop
    endif
    if empty(mdate)
      func_error(4,"Не введена дата выдачи справки.")
      loop
    endif
    if empty(mn_data)
      func_error(4,"Не введена дата начала лечения.")
      loop
    endif
    if empty(mk_data)
      func_error(4,"Не введена дата окончания лечения.")
      loop
    endif
    if mdate < mk_data
      func_error(4,"Дата выдачи справки меньше даты окончания лечения.")
      loop
    endif
    if mk_data < mn_data
      func_error(4,"Дата окончания лечения меньше даты начала лечения.")
      loop
    endif
    mstoim := 0 ; mtip := 2 // стационар
    for i := 1 to len(parr_usl)
      mstoim += parr_usl[i,2] * parr_usl[i,3]
      if left(parr_usl[i,5],3) == "55."
        mtip := 3  // дневной стационар
        exit
      elseif left(parr_usl[i,5],2) == "2." .or. eq_any(left(parr_usl[i,5],3),"57.","60.","70.","72.")
        mtip := 1  // амбулаторно
        exit
      endif
    next
    if empty(mstoim)
      func_error(4,"Не введены услуги.")
      loop
    endif
    create_FR_file_for_spravkaOMS()
    Use_base("lusl")
    frt->data := mdate
    frt->data1 := mn_data
    frt->data2 := mk_data
    frt->fio := mfio
    for i := 1 to len(parr_usl)
      if !emptyany(parr_usl[i,2],parr_usl[i,3])
        select LUSL
        find (padr(parr_usl[i,5],10))
        Select FRD
        find (padr(parr_usl[i,5],10))
        if !found()
          append blank
          frd->shifr := parr_usl[i,5]
          frd->name := lusl->name  // наименование услуги из справочника ТФОМС
          frd->cena := parr_usl[i,3]
        endif
        frd->kol += parr_usl[i,2]
        frd->summa += parr_usl[i,2] * parr_usl[i,3]
      endif
    next
    Select FRD
    go top
    do while !eof()
      if frd->kol > 1
        frd->name1 := " (в количестве "+lstr(frd->kol)+")"
      endif
      Skip
    enddo
    index on str(summa,11,2) to (fr_data) descending
    G_Use(dir_server+"mo_sprav",,"SPR_OMS")
    if rec_spr_oms == 0
      append blank
      spr_oms->KOD_H  := 0
      spr_oms->KOD_K  := iif(k1 > 0, glob_kartotek, 0)
      rec_spr_oms := recno()
    else
      goto (rec_spr_oms)
      G_RLock(forever)
    endif
    spr_oms->FIO    := mFIO
    spr_oms->DATE_R := mDATE_R
    spr_oms->DATA   := mdate
    spr_oms->N_DATA := mn_data
    spr_oms->K_DATA := mk_data
    spr_oms->TIP    := mtip
    spr_oms->STOIM  := mstoim
    close databases
    call_fr("mo_spravkaOMS")
  endif
enddo
restscreen(buf)
return NIL

***** 27.11.14
Function fu_spravka_OMS(r,c)
Local arr_title := {{1," Шифр усл."},;
                    {2,"Кол"},;
                    {3,"   Цена   "},;
                    {4," Наименование услуги"}},;
      mpic := {,{3,0},{10,2}}, tmp_color := setcolor("W+/B,W+/RB"), i
local blk := {|b,ar,nDim,nElem,nKey| fu2spravka_OMS(b, ar, nDim, nElem, nKey)}
if emptyany(mdate_r,mn_data,mk_data)
  func_error(4,"Проверьте правильность ввода даты рождения и сроков лечения")
else
  @ r,c say space(10) color "B/B"
  Private mvzros_reb := iif(count_years(mdate_r,mn_data) < 18, 1, 0)
  if len(parr_usl) == 0
    aadd(parr_usl, {space(10),1,0,space(40),""})
  endif
  Use_base("lusl")
  Use_base("luslc")
  R_Use(dir_server+"uslugi",dir_server+"uslugish","USL")
  Arrn_Browse(r+1,2,maxrow()-2,77,parr_usl,arr_title,1,,,,,.t.,,mpic,blk,{.t.,.t.,.t.})
  p_box_buf := save_box(r+1,0,maxrow()-1,79)
  close databases
endif
setcolor(tmp_color)
return {1," "}

***** 27.11.14
Function fu2spravka_OMS(b, ar, nDim, nElem, nKey)
LOCAL nRow := ROW(), nCol := COL(), i, j, flag := .f., fl, lshifr, lshifr1
DO CASE
  CASE nKey == K_DOWN .or. nKey == K_INS
    b:panHome()
  CASE nKey == K_LEFT
    b:left()
  CASE nKey == K_RIGHT
    if nDim == 1
      b:right()
    endif
  OTHERWISE
    if (nKey == K_ENTER .or. between(nKey,48,57)) .and. nDim < 3
      if nDim == 1 .and. empty(parr[nElem,nDim])
        if between(nKey,48,57)
          keyboard chr(nKey)
        endif
        Private mshifr := space(10)
        @ nRow, nCol GET mshifr picture "@!" valid valid_shifr()
        myread()
        if lastkey() != K_ESC
          lshifr := mname := ""
          select USL
          find (mshifr)
          if found()
            mname := usl->name
            lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data)
            if is_usluga_TFOMS(usl->shifr,lshifr1,mk_data)
              lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
            else
              func_error(4,'Это не услуга ТФОМС: '+lshifr1)
            endif
          else
            select LUSL
            find (mshifr)
            if found()
              lshifr := lusl->shifr
              mname := lusl->name
            else
              func_error(4,'Это не услуга ТФОМС: '+mshifr)
            endif
          endif
          if !empty(lshifr)
            fl_del := fl_uslc := .f.
            glob_podr := "" ; glob_otd_dep := 0
            v := fcena_oms(lshifr,;
                           (mvzros_reb==0),;
                           mk_data,;
                           @fl_del,;
                           @fl_uslc)
            if fl_uslc  // если нашли в справочнике ТФОМС
              if fl_del
                func_error(4,'Цена на услугу '+rtrim(lshifr)+' отсутствует в справочнике ТФОМС')
              else
                fl := .t.
                parr[nElem,1] := mshifr
                if empty(parr[nElem,2])
                  parr[nElem,2] := 1
                endif
                parr[nElem,3] := v
                parr[nElem,4] := left(mname,40)
                parr[nElem,5] := lshifr
                b:right()
                b:refreshAll() ; flag := .t.
              endif
            else
              func_error(4,'Не найдена услуга в справочнике ТФОМС: '+lshifr)
            endif
          endif
        endif
      elseif nDim == 2
        if between(nKey,48,57)
          keyboard chr(nKey)
        endif
        Private mkol := parr[nElem,nDim]
        @ nRow, nCol GET mkol picture "999"
        myread()
        if lastkey() != K_ESC .and. mkol >= 0
          parr[nElem,2] := mkol
          flag := .t.
        endif
      endif
    else
      keyboard ""
    endif
ENDCASE
@ nRow, nCol SAY ""
return flag

*

***** 27.11.14 Отчёт о количестве выданных справок ОМС
Function f_otchet_spravka_OMS()
Local arr_m, buf := save_maxrow(), as := {0,0,0}, sh := 80, HH := 80, ;
      i, n_file := "o_sprOMS"+stxt
if (arr_m := year_month()) != NIL
  mywait()
  R_Use(dir_server+"mo_sprav",,"SPR_OMS")
  index on data to (cur_dir+"tmp") for between(data,arr_m[5],arr_m[6])
  go top
  do while !eof()
    i := 1
    if between(spr_oms->TIP,1,3)
      i := spr_oms->TIP
    endif
    as[i] ++
    skip
  enddo
  Use
  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string(glob_mo[_MO_SHORT_NAME])
  add_string(padl("Приложение 3",sh))
  add_string(padl("к Приказу МЗВО и ТФОМС",sh))
  add_string(padl("№2841/758 от 29.10.2014г.",sh))
  add_string("")
  add_string(center("Отчёт",sh))
  add_string(center("О количестве справок о стоимости оказанной медицинской помощи в",sh))
  add_string(center("сфере ОМС, выданных застрахованным лицам в медицинских организациях",sh))
  add_string(center(arr_m[4],sh))
  add_string("")
  add_string("────────────────────────────────────────────────────────────────────────────────")
  add_string("      Количество проинформированных пациентов с выдачей справок о стоимости     ")
  add_string("                      медицинской помощи в сфере ОМС                            ")
  add_string("──────────────────────────┬──────────────────────────┬──────────────────────────")
  add_string(" в амбулаторно-поликлини- │  в условиях стационара   │     в условиях дневного  ")
  add_string("     ческих условиях      │                          │         стационара       ")
  add_string("──────────────────────────┴──────────────────────────┴──────────────────────────")
  add_string("")
  add_string(padc(lstr(as[1]),26)+" "+padc(lstr(as[2]),26)+" "+padc(lstr(as[3]),26))
  add_string("")
  add_string("────────────────────────────────────────────────────────────────────────────────")
  fclose(fp)
  rest_box(buf)
  viewtext(n_file,,,,.f.,,,2)
endif
return NIL
