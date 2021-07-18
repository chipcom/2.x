// #include "inkey.ch"
#include "function.ch"
// #include "edit_spr.ch"
#include "chip_mo.ch"

***** 17.07.21
Function save_arr_DVN_COVID(lkod)
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
  aadd(arr,{"20",m1GRUPPA})    // "N1",группа здоровья после дисп-ии
  // if type("m1ot_nasl1") == "N"
    aadd(arr,{"30",arr_otklon}) // массив
    aadd(arr,{"31",m1dispans})
    aadd(arr,{"32",m1nazn_l})
  // endif
  if type("m1p_otk") == "N"
    aadd(arr,{"33",m1p_otk})
  endif
  save_arr_DISPANS(lkod,arr)
  return NIL

***** 21.01.19
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
        case arr[i,1] == "20" .and. valtype(arr[i,2]) == "N"
          //m1GRUPPA := arr[i,2]
        case is_all .and. arr[i,1] == "30" .and. valtype(arr[i,2]) == "A"
          arr_otklon := arr[i,2]
        case arr[i,1] == "31" .and. valtype(arr[i,2]) == "N"
          m1dispans  := arr[i,2]
        case arr[i,1] == "32" .and. valtype(arr[i,2]) == "N"
          m1nazn_l   := arr[i,2]
        case arr[i,1] == "33" .and. valtype(arr[i,2]) == "N"
          m1p_otk  := arr[i,2]
      endcase
    endif
  next
  return NIL
