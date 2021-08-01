#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 29.07.21
function f_valid_Begdata_DVN_COVID(get)
  local i

  for i:= 1 to len(uslugiEtap_DVN_COVID(metap))-iif(metap == 1,2,1)
    // на 1-этапе одна услуга не отображается в списке (70.8.1)
    mvar := "MDATE"+lstr(i)
    &mvar := ctod(get:buffer)
    update_get(mvar)
  next

  return .t.

***** 29.07.21
function f_valid_Enddata_DVN_COVID(get)

  // на 1-этапе одна услуга не отображается в списке (70.8.1)
  mvar := "MDATE"+lstr(len(uslugiEtap_DVN_COVID(metap))-iif(metap == 1,1,0))
  &mvar := ctod(get:buffer)
  update_get(mvar)

  return .t.

***** 23.01.17
Function f_valid_diag_oms_sluch_DVN_COVID(get,k)
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
  
  
***** 20.07.21 рабочая ли услуга (умолчание) ДВН в зависимости от этапа, возраста и пола
Function f_is_umolch_sluch_DVN_COVID(i, _etap, _vozrast, _pol)
  Local fl := .f.
  local j, ta, ar   // := ret_dvn_arr_COVID_umolch()[i]

  if i > len(ret_dvn_arr_COVID_umolch()[i])
    return fl
  else
    ar := ret_dvn_arr_COVID_umolch()[i]
  endif
  if valtype(ar[3]) == "N"
    fl := (ar[3] == _etap)
  else
    fl := ascan(ar[3],_etap) > 0
  endif
  return fl
  
***** 15.06.19
Function ret_etap_DVN_COVID(lkod_h,lkod_k)
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
    if fl .and. between(human->ishod,401,402) // ???
      i := human->ishod-400
      if year(human->n_data) == d1 // текущий год
        aadd( ae[1], { i, human->k_data, human_->RSLT_NEW } )
      endif
    endif
    skip
  enddo
  close databases
  return ae
  
***** 16.02.2020 является ли выходным (праздничным) днём проведения диспансеризации
Function f_is_prazdnik_DVN_COVID(_n_data)
  return !is_work_day(_n_data)
  
***** 20.07.21 вернуть шифр услуги законченного случая для ДВН углубленной COVID
Function ret_shifr_zs_DVN_COVID(_etap,_vozrast,_pol,_date)
  Local lshifr := "", fl, is_disp, n := 1
    
  if _etap == 1
    n := 1
      if is_prazdnik
        n += 700
      endif
    lshifr := '70.8.1'
  elseif _etap == 2
  endif
  return lshifr
  
  
***** 16.07.21 вернуть "правильный" профиль для диспансеризации/профилактики
Function ret_profil_dispans_COVID(lprofil,lprvs)

  if lprofil == 34 // если профиль по "клинической лабораторной диагностике"
    if ret_old_prvs(lprvs) == 2013 // и спец-ть "Лабораторное дело"
      lprofil := 37 // сменим на профиль по "лабораторному делу"
    elseif ret_old_prvs(lprvs) == 2011 // или "Лабораторная диагностика"
      lprofil := 38 // сменим на профиль по "лабораторной диагностике"
    endif
  endif
  return lprofil
  
***** 01.08.21
Function save_arr_DVN_COVID(lkod, mk_data) 
  Local arr := {}, i, sk, ta

  if type("mfio") == "C"
    aadd(arr,{"mfio",alltrim(mfio)})
  endif
  if type("mdate_r") == "D"
    aadd(arr,{"mdate_r",mdate_r})
  endif
  aadd(arr,{ "0",m1mobilbr})   // "N",мобильная бригада
  aadd(arr,{ "1",mDateCOVID})     // "D",дата окончания лечения COVID
  aadd(arr,{ "2",mOKSI})     // "N",оксиметрия
  aadd(arr,{ "3",m1strong})     // "N",тяжесть течения болезни
  aadd(arr,{ "4",m1dyspnea})     // "N",одышка
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
    pole_dn_dispans := "mdndispans"+sk
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
      if type(pole_dn_dispans)=="D"
        aadd(ta, &pole_dn_dispans)
      else
        aadd(ta,ctod(""))
      endif
      aadd(arr,{lstr(10+i),ta})
    endif
  next i
  // отказы пациента
  if !empty(arr_usl_otkaz)
    aadd(arr,{"19",arr_usl_otkaz}) // массив
  endif
  aadd(arr,{"30",m1GRUPPA})    // "N1",группа здоровья после дисп-ии
  if type("m1prof_ko") == "N"
    aadd(arr,{"31",m1prof_ko})    // "N1",вид проф.консультирования
  endif
  // if type("m1ot_nasl1") == "N"
    aadd(arr,{"40",arr_otklon}) // массив
    // aadd(arr,{"41",m1ot_nasl1})
    // aadd(arr,{"42",m1ot_nasl2})
    // aadd(arr,{"43",m1ot_nasl3})
    // aadd(arr,{"44",m1ot_nasl4})
    aadd(arr,{"45",m1dispans})
    aadd(arr,{"46",m1nazn_l})
    if mk_data >= 0d20210801
      aadd(arr,{"47",{m1dopo_na, mtab_v_dopo_na}})
    else
      aadd(arr,{"47",m1dopo_na})
    endif
    aadd(arr,{"48",m1ssh_na})
    aadd(arr,{"49",m1spec_na})
    if mk_data >= 0d20210801
      aadd(arr,{"50",{m1sank_na, mtab_v_sanat}})
    else
      aadd(arr,{"50",m1sank_na})
    endif
  // endif
  if type("m1p_otk") == "N"
    aadd(arr,{"51",m1p_otk})
  endif
  if mk_data >= 0d20210801
    if type("m1napr_v_mo") == "N"
      aadd(arr,{"52",{m1napr_v_mo, mtab_v_mo}})
    endif
  else
    if type("m1napr_v_mo") == "N"
      aadd(arr,{"52",m1napr_v_mo})
    endif
  endif
  if type("arr_mo_spec") == "A"   //.and. !empty(arr_mo_spec)
    aadd(arr,{"53",arr_mo_spec}) // массив
  endif
  if mk_data >= 0d20210801
    if type("m1napr_stac") == "N"
      aadd(arr,{"54",{m1napr_stac, mtab_v_stac}})
    endif
  else
    if type("m1napr_stac") == "N"
      aadd(arr,{"54",m1napr_stac})
    endif
  endif
  if type("m1profil_stac") == "N"
    aadd(arr,{"55",m1profil_stac})
  endif
  if mk_data >= 0d20210801
    if type("m1napr_reab") == "N"
      aadd(arr,{"56",{m1napr_reab, mtab_v_reab}})
    endif
  else
    if type("m1napr_reab") == "N"
      aadd(arr,{"56",m1napr_reab})
    endif
  endif
  if type("m1profil_kojki") == "N"
    aadd(arr,{"57",m1profil_kojki})
  endif
  save_arr_DISPANS(lkod,arr)
  return NIL

***** 01.08.21
Function read_arr_DVN_COVID(lkod,is_all)
  Local arr, i, sk
  
  Private mvar
  arr := read_arr_DISPANS(lkod)
  DEFAULT is_all TO .t.
  for i := 1 to len(arr)
    if valtype(arr[i]) == "A" .and. valtype(arr[i,1]) == "C"
      do case
        case arr[i,1] == "0" .and. valtype(arr[i,2]) == "N"
          m1mobilbr := arr[i,2]
        case arr[i,1] == "1" .and. valtype(arr[i,2]) == "D"
          mDateCOVID := arr[i,2]
        case arr[i,1] == "2" .and. valtype(arr[i,2]) == "N"
          mOKSI := arr[i,2]
        case arr[i,1] == "3" .and. valtype(arr[i,2]) == "N"
          m1strong := arr[i,2]
        case arr[i,1] == "4" .and. valtype(arr[i,2]) == "N"
          m1dyspnea := arr[i,2]
        case is_all .and. eq_any(arr[i,1],"11","12","13","14","15") .and. ;
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
          pole_dn_dispans := "mdndispans"+sk
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
          if len(arr[i,2]) >= 10 .and. valtype(arr[i,2,10]) == "D" .and. type(pole_dn_dispans) == "D"
            &pole_dn_dispans := arr[i,2,10]
          endif
        case is_all .and. arr[i,1] == "19" .and. valtype(arr[i,2]) == "A"
            arr_usl_otkaz := arr[i,2]
        case arr[i,1] == "30" .and. valtype(arr[i,2]) == "N"
          //m1GRUPPA := arr[i,2]
        case arr[i,1] == "31" .and. valtype(arr[i,2]) == "N"
          m1prof_ko := arr[i,2]
        case is_all .and. arr[i,1] == "40" .and. valtype(arr[i,2]) == "A"
          arr_otklon := arr[i,2]
        // case arr[i,1] == "41" .and. valtype(arr[i,2]) == "N"
        //   m1ot_nasl1 := arr[i,2]
        // case arr[i,1] == "42" .and. valtype(arr[i,2]) == "N"
        //   m1ot_nasl2 := arr[i,2]
        // case arr[i,1] == "43" .and. valtype(arr[i,2]) == "N"
        //   m1ot_nasl3 := arr[i,2]
        // case arr[i,1] == "44" .and. valtype(arr[i,2]) == "N"
        //   m1ot_nasl4 := arr[i,2]
        case arr[i,1] == "45" .and. valtype(arr[i,2]) == "N"
          m1dispans  := arr[i,2]
        case arr[i,1] == "46" .and. valtype(arr[i,2]) == "N"
          m1nazn_l   := arr[i,2]
        case arr[i,1] == "47"
          if valtype(arr[i,2]) == "N"
            m1dopo_na  := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1dopo_na  := arr[i,2][1]
            mtab_v_dopo_na := arr[i,2][2]
          endif
        case arr[i,1] == "48" .and. valtype(arr[i,2]) == "N"
          m1ssh_na   := arr[i,2]
        case arr[i,1] == "49" .and. valtype(arr[i,2]) == "N"
          m1spec_na  := arr[i,2]
        case arr[i,1] == "50"
          if valtype(arr[i,2]) == "N"
            m1sank_na  := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1sank_na  := arr[i,2][1]
            mtab_v_sanat := arr[i,2][2]
          endif
        case arr[i,1] == "51" .and. valtype(arr[i,2]) == "N"
          m1p_otk  := arr[i,2]
        case arr[i,1] == "52" 
          if valtype(arr[i,2]) == "N"
            m1napr_v_mo  := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1napr_v_mo  := arr[i,2][1]
            mtab_v_mo := arr[i,2][2]
          endif
        case arr[i,1] == "53" .and. valtype(arr[i,2]) == "A"
          arr_mo_spec := arr[i,2]
        case arr[i,1] == "54"
          if valtype(arr[i,2]) == "N"
            m1napr_stac := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1napr_stac := arr[i,2][1]
            mtab_v_stac := arr[i,2][2]
          endif
        case arr[i,1] == "55" .and. valtype(arr[i,2]) == "N"
          m1profil_stac := arr[i,2]
        case arr[i,1] == "56"
          if valtype(arr[i,2]) == "N"
            m1napr_reab := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1napr_reab := arr[i,2][1]
            mtab_v_reab := arr[i,2][2]
          endif
        case arr[i,1] == "57" .and. valtype(arr[i,2]) == "N"
          m1profil_kojki := arr[i,2]
        endcase
    endif
  next
  return NIL
    
***** 20.07.21
Function ret_ndisp_COVID( lkod_h, lkod_k )   //,/*@*/new_etap,/*@*/msg)
  local fl := .t., msg

  msg := ' '

  ar := ret_etap_DVN_COVID(lkod_h,lkod_k)
  if (len(ar[1]) == 0) .and. (lkod_h == 0)
    metap := 1
  elseif  (len(ar[1]) == 1) .and. (lkod_h == 0)
    if ! eq_any(ar[1,1,3], 352, 353, 357, 358)
      msg := 'В ' + lstr(year(mn_data)) + ' году проведен I этап углубленной диспансеризации без направления на II этап!'
      hb_Alert(msg)
      fl := .f.
    endif
    metap := 2
  endif

  mndisp := inieditspr(A__MENUVERT, mm_ndisp, metap)
  return fl

***** 20.07.21 скорректировать массивы по углубленной диспансеризации COVID
Function ret_arrays_disp_COVID()
  local dvn_COVID_arr_usl

  // 1- наименование меню
  // 2- шифр услуги
  // 3- этап или список допустимых этапов, пример: {1,2}
  // 4 - диагноз (0 или 1) может быть?
  // 5- возможен отказ пациента (0 - нет, 1 - да)
  // 6 - возраст для мужчин (число лет), если 1 - все возраста, если список {} то конкретные значения возраста
  // 7 - возраст для женщин (число лет), если 1 - все возраста, если список {} то конкретные значения возраста
  
  //  10- V002 - Классификатор прифилей оказанной медицинской помощи
  //  11- V004 - Классификатор медицинских специальностей
  //  12 - признак услуги ТФОМС/ФФОМС 0 - ТФОМСб 1 - ФФОМС
  //  13 - соответствующая услуга ФФОМС услуге ТФОМС
  dvn_COVID_arr_usl := {; // Услуги на экран для ввода
      { "Пульсооксиметрия", "A12.09.005", 1, 0, 1,1,1,;
        1,1,111,{2021,110103,110303,110906,111006,111905,112212,112611,113418,113509,180202},;
        1,'';
      },;
      { "Проведение спирометрии или спирографии","A12.09.001",1,0,1,1,1,;
        1,1,111,{2021,110103,110303,110906,111006,111905,112212,112611,113418,113509,180202},;
        1,'';
      },;
      { "Общий (клинический) анализ крови развернутый","B03.016.003",1,0,1,1,1,;
        1,1,{34,37,38},{1107,1301,1402,1702,1801,2011},;
        1,'';
      },;
      { "Анализ крови биохимический общетерапевтический","B03.016.004",1,0,1,1,1,;
        1,1,{34,37,38},{1107,1301,1402,1702,1801,2011},;
        1,'';
      },;
      { "Рентгенография легких","A06.09.007",1,0,1,1,1,;
        1,1,78,{1118,1802,2020},;
        1,'';
      },;
      { "Проведение теста с 6 минутной ходьбой","70.8.2",1,0,1,1,1,;
        1,1,{42,151},{39,76,206},;
        0,'A23.30.023';
      },;
      { "Определение концентрации Д-димера в крови","70.8.3",1,0,1,1,1,;
        1,1,{34,37,38},{26,215,217},;
        0,'A09.05.051.001';
      },;
      { "Проведение Эхокардиографии","70.8.50",2,0,1,1,1,;
        1,1,{106,111},{81,89,226},;
        0,'A04.10.002';
      },;
      { "Проведение КТ легких","70.8.51",2,0,1,1,1,;
        1,1,78,60,;
        0,'A06.09.005';
      },;
      { "Дуплексное сканир-ие вен нижних конечностей","70.8.52",2,0,1,1,1,;
        1,1,106,81,;
        0,'A04.12.006.002';
      },;
      { "Приём (осмотр) врачом-терапевтом первичный","B01.026.001",1,1,0,1,1,;
        1,1,{42,151},{2021,110103,110303,110906,111006,111905,112212,112611,113418,113509,180202},;
        1,'';
      },;
      { "Приём (осмотр) врачом-терапевтом повторный","B01.026.002",2,1,0,1,1,;
        1,1,{42,151},{2021,110103,110303,110906,111006,111905,112212,112611,113418,113509,180202},;
        1,'';
      },;
      { "Комплексное посещение углубленная диспансеризация I этап","70.8.1",1,1,0,1,1,;
        1,1,{42,151},{2021,110103,110303,110906,111006,111905,112212,112611,113418,113509,180202},;
        0,'';
      };
    }
return dvn_COVID_arr_usl

***** 22.07.21 получить услуги этапа диспансеризации COVID
function uslugiEtap_DVN_COVID(_etap)
  // _etap - этап диспансеризации
  local retArray := {}
  local i
  local usl := ret_arrays_disp_COVID()

  for i := 1 to len(usl)
    if valtype(usl[i, 3]) == "N"
      fl := (usl[i, 3] == _etap)
    else
      fl := ascan(usl[i, 3], _etap) > 0
    endif
    if fl
      aadd(retArray, usl[i])
    endif
  next
  return retArray

****** 26.07.21 получить индекс услуги на этапе диспансеризации COVID
function indexUslugaEtap_DVN_COVID(_etap, lshifr)
  // _etap - этап диспансеризации
  // lshifr - шифр услуги
  local index := 0
  local i := 0
  local usl := uslugiEtap_DVN_COVID(_etap)

  for i := 1 to len(usl)
    if alltrim(usl[i, 2]) == alltrim(lshifr)
      index := i
      exit
    endif
  next
  return index

***** 20.07.21 рабочая ли услуга по углубленной диспансеризации COVID в зависимости от этапа
Function f_is_usl_oms_sluch_DVN_COVID( i, _etap, allUsl, /*@*/_diag, /*@*/_otkaz) //, /*@*/_ekg)
  Local fl := .f.
  local ars := {}
  // local ar := ret_arrays_disp_COVID()[i]
  local ar := uslugiEtap_DVN_COVID(_etap)[i]

  if valtype(ar[2]) == "C" .and. _etap == 1 .and. alltrim(ar[2]) == "70.8.1" .and. ( ! allUsl )
    return fl
  endif
  if valtype(ar[3]) == "N"
    fl := (ar[3] == _etap)
  else
    fl := ascan(ar[3],_etap) > 0
  endif
  _diag := (ar[4] == 1)
  _otkaz := 0
  if valtype(ar[2]) == "C"
    aadd(ars,ar[2])
  else
    ars := aclone(ar[2])
  endif
  if eq_any(_etap,1,2) .and. ar[5] == 1
    _otkaz := 1 // можно ввести отказ
  endif
  return fl

***** 16.07.21 массив услуг, записываемые всегда по умолчанию по углубленной диспансеризации COVID
Function ret_dvn_arr_COVID_umolch()
  local dvn_COVID_arr_umolch := {}

  // 1- наименование меню
  // 2- шифр услуги
  // 3- этап или список допустимых этапов, пример: {1,2}
  // 4 - диагноз (0 или 1) может быть?
  // 5- возможен отказ пациента (0 - нет, 1 - да)
  // 6 - возраст для мужчин (число лет), если 1 - все возраста, если список {} то конкретные значения возраста
  // 7 - возраст для женщин (число лет), если 1 - все возраста, если список {} то конкретные значения возраста
  
  //  10- V002 - Классификатор прифилей оказанной медицинской помощи
  //  11- V004 - Классификатор медицинских специальностей

    // count_dvn_arr_usl := len(dvn_COVID_arr_usl)
    // count_dvn_arr_umolch := len(dvn_arr_umolch)
  return dvn_COVID_arr_umolch

// 21.07.2021
function foundFFOMSUsluga(lshifr)
  local kod_uslf := 0
  local tmp_select := select()

  if select("luslf") == 0
    use_base("luslf")
  endif
  if select("mosu") == 0
    Use_base("mo_su")
  endif
  select MOSU
  set order to 3 // по шифру ФФОМС
  find (padr(lshifr,20))
  if found()
    kod_uslf := mosu->kod
  else
    select LUSLF
    find (padr(lshifr,20))
    if found()
      select MOSU
      set order to 1
      FIND (STR(-1,6))
      if found()
        G_RLock(forever)
      else
        AddRec(6)
      endif
      kod_uslf := mosu->kod := recno()
      mosu->name := luslf->name
      mosu->shifr1 := lshifr
      mosu->PROFIL := 0
    endif
  endif
  select (tmp_select)
  MOSU->(dbCloseArea())
  luslf->(dbCloseArea())
  luslf18->(dbCloseArea())
  luslf19->(dbCloseArea())
  luslf20->(dbCloseArea())

  return kod_uslf

// 22.07.2021
function foundFFOMSUslugaById(id)
  // id - код услуги
  local tmp_select := select()
  local retArray := {}

  if select("mosu") == 0
    Use_base("mo_su")
  endif
  select MOSU
  set order to 1 // по коду
  find (str(id,6))
  if found()
    retArray := {MOSU->KOD, MOSU->NAME, MOSU->SHIFR1, MOSU->PROFIL, MOSU->TIP, MOSU->SLUGBA, MOSU->ZF}
  endif
  select (tmp_select)
  MOSU->(dbCloseArea())

  return retArray