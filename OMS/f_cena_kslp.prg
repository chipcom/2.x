#include "inkey.ch"
#include "..\..\_mylib_hbt\function.ch"
#include "..\..\_mylib_hbt\edit_spr.ch"
#include "..\chip_mo.ch"


***** 25.01.21 определить коэф-т сложности лечения пациента и пересчитать цену
Function f_cena_kslp(/*@*/_cena,_lshifr,_date_r,_n_data,_k_data,lkslp,arr_usl,lPROFIL_K,arr_diag,lpar_org,lad_cr)
  Static s_1_may := 0d20160430, s_18 := 0d20171231, s_19 := 0d20181231
  static s_20 := 0d20201231
  Static s_kslp17 := {;
    {1,1.1, 0,  3},;   // до 4 лет
    {2,1.1,75,999};    // 75 лет и старше
   }
  Static s_kslp16 := {;
    {1,1.1 , 0,  3},;   // до 4 лет
    {2,1.05,75,999};    // 75 лет и старше
   }
  Local i, j, vksg, y := 0, fl, ausl := {}, s_kslp, _akslp := {}, sop_diag
  DEFAULT lad_cr TO space(10)

  _lshifr := alltrim(_lshifr) // перенес

  if _k_data > s_20
    if empty(lkslp)
      return _akslp
    endif
    s_kslp := {;
      // {code, Коэффициент, возрастНачало, возрастКонец}
      { 1, 1.02, 75, 999},; // Сложность лечения пациента, связанная с возрастом (лица 75 лет и старше) (в том числе, включая консультацию врача-гериатра)
      { 3, 1.20,  0,  18},; // Предоставление спального места и питания законному представителю (дети до 4 лет, дети старше 4 лет при наличии медицинских показаний)
      { 4, 1.20,  0,  18},; // Проведение первой иммунизации против респираторно-синцитиальной вирусной инфекции в период госпитализации по поводу лечения нарушений, возникающих в перинатальном периоде, являющихся показанием к иммунизации
      { 5, 1.20, 18, 999},; // Развертывание индивидуального поста
      { 6, 1.30, 18, 999},; // Проведение сочетанных хирургических вмешательств
      { 7, 1.30, 18, 999},; // Проведение однотипных операций на парных органах
      { 8, 1.50, 18, 999},; // Проведение антимикробной терапии инфекций, вызванных полирезистентными микроорганизмами
      { 9, 1.50, 18, 999},; // Наличие у пациента тяжелой сопутствующей патологии, осложнений заболеваний, сопутствующих заболеваний, влияющих на сложность лечения пациента (перечень указанных заболеваний и состояний
      {10, 1.50, 18, 999};  // Сверхдлительные сроки госпитализации, обусловленные медицинскими показаниями
    }

    count_ymd(_date_r,_n_data,@y)
    lkslp := list2arr(lkslp)
    for j := 1 to len(lkslp)
      if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0 // стоит данный КСЛП в выбранной КСГ
        if between(y,s_kslp[i,3],s_kslp[i,4])
          fl := .t.
          if lkslp[j] == 1  // для людей старше 75 лет
            fl := (lprofil_k != 16 ; // пациент лежит не на геронтологической койке
                    .and. !(_lshifr == "st38.001"))
          elseif lkslp[j] == 5
            sop_diag := aclone(arr_diag)
            del_array(sop_diag,1)
            fl := (lprofil_k == 16 .and. ; // пациент лежит на геронтологической койке
                    !(_lshifr == "st38.001") .and. ;//!(alltrim(arr_diag[1]) == "R54") .and. ; // с основным диагнозом не <R54-старость>
                    ascan(sop_diag, {|x| alltrim(x) == "R54"}) > 0 ) // в соп.диагнозах есть <R54-старость>
          endif
          if fl
            aadd(_akslp,s_kslp[i,1])
            aadd(_akslp,s_kslp[i,2])
            exit
          endif
        endif
      endif
    next

  elseif _k_data > s_19  // с 2019 года
    if !empty(lkslp)
      // _lshifr := alltrim(_lshifr)
      if _lshifr == "ds02.005" // ЭКО, lkslp = 12,13,14
        s_kslp := {;
          {12,0.60},;
          {13,1.10},;
          {14,0.19};
        }
        for i := 1 to len(arr_usl)
          if valtype(arr_usl[i]) == "A"
            aadd(ausl,alltrim(arr_usl[i,1]))  // массив многомерный
          else
            aadd(ausl,alltrim(arr_usl[i]))    // массив одномерный
          endif
        next i
        j := 0 // КСЛП - 1 схема
        if ascan(ausl,"A11.20.031") > 0  // крио
          j := 13  // 6 схема
          if ascan(ausl,"A11.20.028") > 0 // третий этап
            j := 0   // 2 схема
          endif
        elseif ascan(ausl,"A11.20.025.001") > 0  // первый этап
          j := 12  // 3 схема
          if ascan(ausl,"A11.20.036") > 0  // завершающий второй этап
            j := 12  // 4 схема
          elseif ascan(ausl,"A11.20.028") > 0  // завершающий третий этап
            j := 12  // 5 схема
          endif
        elseif ascan(ausl,"A11.20.030.001") > 0  // только четвертый этап
          j := 14  // 7 схема
        endif
        if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
          aadd(_akslp,s_kslp[i,1])
          aadd(_akslp,s_kslp[i,2])
          _cena := round_5(_cena*s_kslp[i,2],0)  // с 2019 года цена округляется до рублей
        endif
        if !empty(_akslp) .and. _k_data > 0d20191231 // с 2020 года
          _akslp[1] += 3 // т.е. с 2020 года КСЛП для ЭКО 15,16,17
        endif
      else // остальные КСГ
        s_kslp := {;
          { 1,1.10, 0,  0},;  // до 1 года
          { 2,1.10, 1,  3},;  // от 1 до 3 лет включительно
          { 4,1.02,75,999},;  // 75 и старше
          { 5,1.10,60,999};   // 60 и старше и астения
        }
        count_ymd(_date_r,_n_data,@y)
        lkslp := list2arr(lkslp)
        for j := 1 to len(lkslp)
          if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0 // стоит данный КСЛП в выбранной КСГ
            if between(y,s_kslp[i,3],s_kslp[i,4])
              fl := .t.
              if lkslp[j] == 4
                fl := (lprofil_k != 16 ; // пациент лежит не на геронтологической койке
                        .and. !(_lshifr == "st38.001"))
              elseif lkslp[j] == 5
                sop_diag := aclone(arr_diag)
                del_array(sop_diag,1)
                fl := (lprofil_k == 16 .and. ; // пациент лежит на геронтологической койке
                        !(_lshifr == "st38.001") .and. ;//!(alltrim(arr_diag[1]) == "R54") .and. ; // с основным диагнозом не <R54-старость>
                        ascan(sop_diag, {|x| alltrim(x) == "R54"}) > 0 ) // в соп.диагнозах есть <R54-старость>
              endif
              if fl
                aadd(_akslp,s_kslp[i,1])
                aadd(_akslp,s_kslp[i,2])
                exit
              endif
            endif
          endif
        next
        if ascan(lkslp,11) > 0 .and. lpar_org > 1 // разрешена КСЛП=11 и введены парные органы
          aadd(_akslp,11)
          aadd(_akslp,1.2)
        endif
        if ascan(lkslp,18) > 0 .and. "cr6" $ lad_cr // разрешена КСЛП=18 и для сложного COVID-19
          aadd(_akslp,18)
          aadd(_akslp,1.2)
        endif
        if !empty(_akslp)
          _cena := round_5(_cena*ret_koef_kslp(_akslp),0)  // с 2019 года цена округляется до рублей
        endif
      endif
    endif
  elseif _k_data > s_18  // с 2018 года
    if !empty(lkslp)
      // _lshifr := alltrim(_lshifr)
      if _lshifr == "2005.0" // ЭКО, lkslp = 12,13,14
        s_kslp := {;
          {12,0.60},;
          {13,1.10},;
          {14,0.19};
        }
        for i := 1 to len(arr_usl)
          if valtype(arr_usl[i]) == "A"
            aadd(ausl,alltrim(arr_usl[i,1]))  // массив многомерный
          else
            aadd(ausl,alltrim(arr_usl[i]))    // массив одномерный
          endif
        next i
        j := 0 // КСЛП - 1 схема
        if ascan(ausl,"A11.20.031") > 0  // крио
          j := 13  // 6 схема
          if ascan(ausl,"A11.20.028") > 0 // третий этап
            j := 0   // 2 схема
          endif
        elseif ascan(ausl,"A11.20.025.001") > 0  // первый этап
          j := 12  // 3 схема
          if ascan(ausl,"A11.20.036") > 0  // завершающий второй этап
            j := 12  // 4 схема
          elseif ascan(ausl,"A11.20.028") > 0  // завершающий третий этап
            j := 12  // 5 схема
          endif
        elseif ascan(ausl,"A11.20.030.001") > 0  // только четвертый этап
          j := 14  // 7 схема
        endif
        if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
          aadd(_akslp,s_kslp[i,1])
          aadd(_akslp,s_kslp[i,2])
          _cena := round_5(_cena*s_kslp[i,2],1)
        endif
      else // остальные КСГ
        s_kslp := {;
          { 1,1.10, 0,  0},;  // до 1 года
          { 2,1.10, 1,  3},;  // от 1 до 3 лет включительно
          { 4,1.05,75,999},;  // 75 и старше
          { 5,1.10,60,999};   // 60 и старше и астения
        }
        count_ymd(_date_r,_n_data,@y)
        lkslp := list2arr(lkslp)
        for j := 1 to len(lkslp)
          if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0
            if between(i,1,5) .and. between(y,s_kslp[i,3],s_kslp[i,4])
              aadd(_akslp,s_kslp[i,1])
              aadd(_akslp,s_kslp[i,2])
              _cena := round_5(_cena*s_kslp[i,2],1)
              exit
            endif
          endif
        next
      endif
    endif
  elseif _k_data > s_1_may ;                 // с 1 мая 2016 года
              .and. left(_lshifr,1) == '1' ; // круглосуточный стационар
              .and. !("." $ _lshifr)         // это шифр КСГ
    // _lshifr := alltrim(_lshifr)
    count_ymd(_date_r,_n_data,@y)
    vksg := int(val(right(_lshifr,3))) // последние три цифры - код КСГ
    if (fl := vksg < 900) // не диализ
      if year(_k_data) > 2016
        s_kslp := s_kslp17
        if y < 1 .and. between(vksg,105,111) // до 1 года и малая масса при рождении
          fl := .f.
        endif
      else
        s_kslp := s_kslp16
      endif
      if fl
        for i := 1 to len(s_kslp)
          if between(y,s_kslp[i,3],s_kslp[i,4])
            aadd(_akslp,s_kslp[i,1])
            aadd(_akslp,s_kslp[i,2])
            _cena := round_5(_cena*s_kslp[i,2],1)
            exit
          endif
        next
      endif
    endif
  endif
  return _akslp
  
  