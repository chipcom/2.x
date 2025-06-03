#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 19.03.19 вернуть шифр услуги законченного случая для диспансеризации детей-сирот
Function ret_shifr_zs_DDS(tip_lu)
  Local s := ""
  if m1mobilbr == 1 // диспансеризация проведена мобильной бригадой
    if m1lis > 0 // без гематологических иссл-ий
      if mvozrast < 1
        s := iif(tip_lu==TIP_LU_DDS, "70.5.21", "70.6.19")
      elseif mvozrast < 3
        s := iif(tip_lu==TIP_LU_DDS, "70.5.22", "70.6.20")
      elseif mvozrast < 5
        s := iif(tip_lu==TIP_LU_DDS, "70.5.23", "70.6.21")
      elseif mvozrast < 7
        s := iif(tip_lu==TIP_LU_DDS, "70.5.24", "70.6.22")
      elseif mvozrast < 15
        s := iif(tip_lu==TIP_LU_DDS, "70.5.25", "70.6.23")
      else
        s := iif(tip_lu==TIP_LU_DDS, "70.5.26", "70.6.24")
      endif
    else  // гематологические иссл-ия проводятся в ЛПУ
      if mvozrast < 1
        s := iif(tip_lu==TIP_LU_DDS, "70.5.9", "70.6.7")
      elseif mvozrast < 3
        s := iif(tip_lu==TIP_LU_DDS, "70.5.10", "70.6.8")
      elseif mvozrast < 5
        s := iif(tip_lu==TIP_LU_DDS, "70.5.11", "70.6.9")
      elseif mvozrast < 7
        s := iif(tip_lu==TIP_LU_DDS, "70.5.12", "70.6.10")
      elseif mvozrast < 15
        s := iif(tip_lu==TIP_LU_DDS, "70.5.13", "70.6.11")
      else
        s := iif(tip_lu==TIP_LU_DDS, "70.5.14", "70.6.12")
      endif
    endif
  else // дисп-ия проведена в МО (не мобильной бригадой)
    if m1lis > 0 // без гематологических иссл-ий
      if mvozrast < 1
        s := iif(tip_lu==TIP_LU_DDS, "70.5.15", "70.6.13")
      elseif mvozrast < 3
        s := iif(tip_lu==TIP_LU_DDS, "70.5.16", "70.6.14")
      elseif mvozrast < 5
        s := iif(tip_lu==TIP_LU_DDS, "70.5.17", "70.6.15")
      elseif mvozrast < 7
        s := iif(tip_lu==TIP_LU_DDS, "70.5.18", "70.6.16")
      elseif mvozrast < 15
        s := iif(tip_lu==TIP_LU_DDS, "70.5.19", "70.6.17")
      else
        s := iif(tip_lu==TIP_LU_DDS, "70.5.20", "70.6.18")
      endif
    else  // гематологические иссл-ия проводятся в ЛПУ
      if mvozrast < 1
        s := iif(tip_lu==TIP_LU_DDS, "70.5.3", "70.6.1")
      elseif mvozrast < 3
        s := iif(tip_lu==TIP_LU_DDS, "70.5.4", "70.6.2")
      elseif mvozrast < 5
        s := iif(tip_lu==TIP_LU_DDS, "70.5.5", "70.6.3")
      elseif mvozrast < 7
        s := iif(tip_lu==TIP_LU_DDS, "70.5.6", "70.6.4")
      elseif mvozrast < 15
        s := iif(tip_lu==TIP_LU_DDS, "70.5.7", "70.6.5")
      else
        s := iif(tip_lu==TIP_LU_DDS, "70.5.8", "70.6.6")
      endif
    endif
  endif
  return s

***** 05.09.21
Function save_arr_DDS(lkod)
  Local arr := {}, k, ta
  local aliasIsUse := aliasIsAlreadyUse('TPERS')
  local oldSelect

  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server()+"mo_pers",dir_server()+"mo_pers","TPERS") 
  endif

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
  if mk_data >= 0d20210801
    if mtab_v_dopo_na != 0
      if TPERS->(dbSeek(str(mtab_v_dopo_na,5)))
        aadd(arr,{"47",{m1dopo_na, TPERS->kod}})
      else
        aadd(arr,{"47",{m1dopo_na, 0}})
      endif
    else
      aadd(arr,{"47",{m1dopo_na, 0}})
    endif
  else
    aadd(arr,{"47",m1dopo_na})
  endif
  if mk_data >= 0d20210801
    if type("m1napr_v_mo") == "N"
      if mtab_v_mo != 0
        if TPERS->(dbSeek(str(mtab_v_mo,5)))
          aadd(arr,{"52",{m1napr_v_mo, TPERS->kod}})
        else
          aadd(arr,{"52",{m1napr_v_mo, 0}})
        endif
      else
        aadd(arr,{"52",{m1napr_v_mo, 0}})
      endif
    endif
  else
    if type("m1napr_v_mo") == "N"
      aadd(arr,{"52",m1napr_v_mo})
    endif
  endif
  if type("arr_mo_spec") == "A" .and. !empty(arr_mo_spec)
    aadd(arr,{"53",arr_mo_spec}) // массив
  endif
  if mk_data >= 0d20210801
    if type("m1napr_stac") == "N"
      if mtab_v_stac != 0
        if TPERS->(dbSeek(str(mtab_v_stac,5)))
          aadd(arr,{"54",{m1napr_stac, TPERS->kod}})
        else
          aadd(arr,{"54",{m1napr_stac, 0}})
        endif
      else
        aadd(arr,{"54",{m1napr_stac, 0}})
      endif
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
      if mtab_v_reab != 0
        if TPERS->(dbSeek(str(mtab_v_reab,5)))
          aadd(arr,{"56",{m1napr_reab, TPERS->kod}})
        else
          aadd(arr,{"56",{m1napr_reab, 0}})
        endif
      else
        aadd(arr,{"56",{m1napr_reab, 0}})
      endif
    endif
  else
    if type("m1napr_reab") == "N"
      aadd(arr,{"56",m1napr_reab})
    endif
  endif
  if type("m1profil_kojki") == "N"
    aadd(arr,{"57",m1profil_kojki})
  endif

  if ! aliasIsUse
    TPERS->(dbCloseArea())
    Select(oldSelect)
  endif

  save_arr_DISPANS(lkod,arr)
  return NIL
  
***** 05.09.21
Function read_arr_DDS(lkod)
  Local arr, i, k
  local aliasIsUse := aliasIsAlreadyUse('TPERS')
  local oldSelect
  Private mvar

  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server()+"mo_pers",,"TPERS") 
  endif

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
        // case arr[i,1] == "47" .and. valtype(arr[i,2]) == "N"
        //   m1dopo_na  := arr[i,2]
        case arr[i,1] == "47"
          if valtype(arr[i,2]) == "N"
            m1dopo_na  := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1dopo_na  := arr[i,2][1]
            if arr[i,2][2] > 0
              TPERS->(dbGoto(arr[i,2][2]))
              mtab_v_dopo_na := TPERS->tab_nom
            endif
            // mtab_v_dopo_na := arr[i,2][2]
          endif
        // case arr[i,1] == "52" .and. valtype(arr[i,2]) == "N"
        //   m1napr_v_mo  := arr[i,2]
        case arr[i,1] == "52" 
          if valtype(arr[i,2]) == "N"
            m1napr_v_mo  := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1napr_v_mo  := arr[i,2][1]
            if arr[i,2][2] > 0
              TPERS->(dbGoto(arr[i,2][2]))
              mtab_v_mo := TPERS->tab_nom
            endif
            // mtab_v_mo := arr[i,2][2]
          endif
        case arr[i,1] == "53" .and. valtype(arr[i,2]) == "A"
          arr_mo_spec := arr[i,2]
        // case arr[i,1] == "54" .and. valtype(arr[i,2]) == "N"
        //   m1napr_stac := arr[i,2]
        case arr[i,1] == "54"
          if valtype(arr[i,2]) == "N"
            m1napr_stac := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1napr_stac := arr[i,2][1]
            if arr[i,2][2] > 0
              TPERS->(dbGoto(arr[i,2][2]))
              mtab_v_stac := TPERS->tab_nom
            endif
            // mtab_v_stac := arr[i,2][2]
          endif
        case arr[i,1] == "55" .and. valtype(arr[i,2]) == "N"
          m1profil_stac := arr[i,2]
        // case arr[i,1] == "56" .and. valtype(arr[i,2]) == "N"
        //   m1napr_reab := arr[i,2]
        case arr[i,1] == "56"
          if valtype(arr[i,2]) == "N"
            m1napr_reab := arr[i,2]
          elseif valtype(arr[i,2]) == "A"
            m1napr_reab := arr[i,2][1]
            if arr[i,2][2] > 0
              TPERS->(dbGoto(arr[i,2][2]))
              mtab_v_reab := TPERS->tab_nom
            endif
            // mtab_v_reab := arr[i,2][2]
          endif
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

  if ! aliasIsUse
    TPERS->(dbCloseArea())
    Select(oldSelect)
  endif

  return NIL
  