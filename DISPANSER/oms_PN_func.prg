#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 03.08.21
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
  if mk_data >= 0d20210801
    if mtab_v_dopo_na != 0
      if p2->(dbSeek(str(mtab_v_dopo_na,5)))
        aadd(arr,{"47",{m1dopo_na, p2->kod}})
      else
        aadd(arr,{"47",{m1dopo_na, 0}})
      endif
    else
      aadd(arr,{"47",{m1dopo_na, 0}})
    endif
    // aadd(arr,{"47",{m1dopo_na, mtab_v_dopo_na}})
  else
    aadd(arr,{"47",m1dopo_na})
  endif
  // if type("m1dopo_na") == "N"
  //   aadd(arr,{"47",m1dopo_na})
  // endif
  if type("m1p_otk") == "N"
    aadd(arr,{"51",m1p_otk})
  endif
  if mk_data >= 0d20210801
    if type("m1napr_v_mo") == "N"
      if mtab_v_mo != 0
        if p2->(dbSeek(str(mtab_v_mo,5)))
          aadd(arr,{"52",{m1napr_v_mo, p2->kod}})
        else
          aadd(arr,{"52",{m1napr_v_mo, 0}})
        endif
      else
        aadd(arr,{"52",{m1napr_v_mo, 0}})
      endif
      // aadd(arr,{"52",{m1napr_v_mo, mtab_v_mo}})
    endif
  else
    if type("m1napr_v_mo") == "N"
      aadd(arr,{"52",m1napr_v_mo})
    endif
  endif
  // if type("m1napr_v_mo") == "N"
  //   aadd(arr,{"52",m1napr_v_mo})
  // endif
  if type("arr_mo_spec") == "A" .and. !empty(arr_mo_spec)
    aadd(arr,{"53",arr_mo_spec}) // массив
  endif
  if mk_data >= 0d20210801
    if type("m1napr_stac") == "N"
      if mtab_v_stac != 0
        if p2->(dbSeek(str(mtab_v_stac,5)))
          aadd(arr,{"54",{m1napr_stac, p2->kod}})
        else
          aadd(arr,{"54",{m1napr_stac, 0}})
        endif
      else
        aadd(arr,{"54",{m1napr_stac, 0}})
      endif
      // aadd(arr,{"54",{m1napr_stac, mtab_v_stac}})
    endif
  else
    if type("m1napr_stac") == "N"
      aadd(arr,{"54",m1napr_stac})
    endif
  endif
  // if type("m1napr_stac") == "N"
  //   aadd(arr,{"54",m1napr_stac})
  // endif
  if type("m1profil_stac") == "N"
    aadd(arr,{"55",m1profil_stac})
  endif
  if mk_data >= 0d20210801
    if type("m1napr_reab") == "N"
      if mtab_v_reab != 0
        if p2->(dbSeek(str(mtab_v_reab,5)))
          aadd(arr,{"56",{m1napr_reab, p2->kod}})
        else
          aadd(arr,{"56",{m1napr_reab, 0}})
        endif
      else
        aadd(arr,{"56",{m1napr_reab, p2->kod}})
      endif
      // aadd(arr,{"56",{m1napr_reab, mtab_v_reab}})
    endif
  else
    if type("m1napr_reab") == "N"
      aadd(arr,{"56",m1napr_reab})
    endif
  endif
  // if type("m1napr_reab") == "N"
  //   aadd(arr,{"56",m1napr_reab})
  // endif
  if type("m1profil_kojki") == "N"
    aadd(arr,{"57",m1profil_kojki})
  endif
  save_arr_DISPANS(lkod,arr)
  return NIL
  
  ***** 01.02.20
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
          case arr[i,1] == "47"
            if valtype(arr[i,2]) == "N"
              m1dopo_na  := arr[i,2]
            elseif valtype(arr[i,2]) == "A"
              m1dopo_na  := arr[i,2][1]
              if arr[i,2][2] > 0
                p2->(dbGoto(arr[i,2][2]))
                mtab_v_dopo_na := p2->tab_nom
              endif
              // mtab_v_dopo_na := arr[i,2][2]
            endif
          // case arr[i,1] == "47" .and. valtype(arr[i,2]) == "N"
          //   m1dopo_na  := arr[i,2]
          case arr[i,1] == "51" .and. valtype(arr[i,2]) == "N"
            m1p_otk  := arr[i,2]
          case arr[i,1] == "52" 
            if valtype(arr[i,2]) == "N"
              m1napr_v_mo  := arr[i,2]
            elseif valtype(arr[i,2]) == "A"
              m1napr_v_mo  := arr[i,2][1]
              if arr[i,2][2] > 0
                p2->(dbGoto(arr[i,2][2]))
                mtab_v_mo := p2->tab_nom
              endif
              // mtab_v_mo := arr[i,2][2]
            endif
          // case arr[i,1] == "52" .and. valtype(arr[i,2]) == "N"
          //   m1napr_v_mo  := arr[i,2]
          case arr[i,1] == "53" .and. valtype(arr[i,2]) == "A"
            arr_mo_spec := arr[i,2]
          case arr[i,1] == "54"
            if valtype(arr[i,2]) == "N"
              m1napr_stac := arr[i,2]
            elseif valtype(arr[i,2]) == "A"
              m1napr_stac := arr[i,2][1]
              if arr[i,2][2] > 0
                p2->(dbGoto(arr[i,2][2]))
                mtab_v_stac := p2->tab_nom
              endif
              // mtab_v_stac := arr[i,2][2]
            endif
          // case arr[i,1] == "54" .and. valtype(arr[i,2]) == "N"
          //   m1napr_stac := arr[i,2]
          case arr[i,1] == "55" .and. valtype(arr[i,2]) == "N"
            m1profil_stac := arr[i,2]
          case arr[i,1] == "56"
            if valtype(arr[i,2]) == "N"
              m1napr_reab := arr[i,2]
            elseif valtype(arr[i,2]) == "A"
              m1napr_reab := arr[i,2][1]
              if arr[i,2][2] > 0
                p2->(dbGoto(arr[i,2][2]))
                mtab_v_reab := p2->tab_nom
              endif
              // mtab_v_reab := arr[i,2][2]
            endif
          // case arr[i,1] == "56" .and. valtype(arr[i,2]) == "N"
          //   m1napr_reab := arr[i,2]
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
  