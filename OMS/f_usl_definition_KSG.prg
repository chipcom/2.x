#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** 13.03.23 определить КСГ для 1 пациента из режима редактирования услуг
Function f_usl_definition_KSG(lkod, k_data2, lDoubleSluch)
  Local arr, buf := save_maxrow(), lshifr, lrec, lu_kod, lcena, not_ksg := .t., ;
        mrec_hu, tmp_rec := 0, tmp_select := select(), is_usl1 := .f., ;
        ret := {}, lyear := year(human->K_DATA), i, s, sdial, fl
  local lalias

  default lDoubleSluch to .f.
  if human_->USL_OK < 3
    mywait('Определение КСГ')
    usl->(dbCloseArea()) // переоткрыть справочник услуг
    Use_base('uslugi')
    if select('USL1') == 0
      is_usl1 := .t.
      R_Use(dir_server + 'uslugi1', {dir_server + 'uslugi1', ;
                                  dir_server + 'uslugi1s'}, 'USL1')
    endif
    select TMP
    if lastrec() > 0
      tmp_rec := recno()
    endif
    set relation to
    if lyear > 2018
      arr := definition_KSG(1, k_data2, lDoubleSluch)
    else
      arr := definition_KSG_18()
    endif
    sdial := 0
    fl := .t.
    if len(arr) == 7
      if valtype(arr[7]) == 'N'
        sdial := arr[7] // для 2019 года
        if emptyall(arr[1], arr[2], arr[3], arr[4])
          fl := .f. // диализ в дневном стационаре без КСГ
        endif
      else
        fl := .f. // для 2018 года
      endif
    endif
    if fl // не диализ 2018 года
      aeval(arr[1], {|x| my_debug( , x), aadd(ret, x)})
      if !empty(arr[2])
        my_debug(,'ОШИБКА:')
        aeval(arr[2], {|x| my_debug( , x), aadd(ret, x)})
      endif
      lrec := lcena := 0
      select TMP
      go top
      do while !eof()
        if empty(lshifr := tmp->shifr1)
          lshifr := tmp->shifr_u
        endif
        if !empty(arr[3]) .and. alltrim(lshifr) == arr[3] // уже стоит тот же КСГ
          not_ksg := .f.
          lcena := arr[4]
          if !(round(tmp->u_cena, 2) == round(lcena, 2)) // перезапишем цену
            tmp->u_cena := lcena
            tmp->stoim_1 := lcena
            select HU
            goto (tmp->rec_hu)
            G_RLock(forever)
            hu->u_cena := lcena
            hu->stoim := hu->stoim_1 := lcena
            UnLock
          endif
          exit
        endif

        lalias := create_name_alias('lusl', lyear)
        dbSelectArea(lalias)
        find (padr(lshifr, 10)) // длина lshifr 10 знаков
        if found() .and. (eq_any(left(lshifr, 5), code_services_VMP(lyear)) .or. is_ksg((lalias)->shifr))
          lrec := tmp->(recno())
          exit
        endif

        // if lyear == 2023
        //   select LUSL
        //   find (padr(lshifr, 10)) // длина lshifr 10 знаков
        //   // if found() .and. (eq_any(left(lshifr, 5), '1.22.') .or. is_ksg(lusl->shifr)) // стоит другой КСГ
        //   if found() .and. (eq_any(left(lshifr, 5), code_services_VMP(2023)) .or. is_ksg(lusl->shifr)) // стоит другой КСГ
        //     lrec := tmp->(recno())
        //     exit
        //   endif
        // elseif lyear == 2022
        //   select LUSL22
        //   find (padr(lshifr, 10)) // длина lshifr 10 знаков
        //   // if found() .and. (eq_any(left(lshifr, 5), '1.21.') .or. is_ksg(lusl22->shifr)) // стоит другой КСГ
        //   if found() .and. (eq_any(left(lshifr, 5), code_services_VMP(2022)) .or. is_ksg(lusl22->shifr)) // стоит другой КСГ
        //     lrec := tmp->(recno())
        //     exit
        //   endif
        // elseif lyear == 2021
        //   select LUSL21
        //   find (padr(lshifr, 10)) // длина lshifr 10 знаков
        //   // if found() .and. (eq_any(left(lshifr, 5), '1.20.') .or. is_ksg(lusl21->shifr)) // стоит другой КСГ
        //   if found() .and. (eq_any(left(lshifr, 5), code_services_VMP(2021)) .or. is_ksg(lusl21->shifr)) // стоит другой КСГ
        //     lrec := tmp->(recno())
        //     exit
        //   endif
        // elseif lyear == 2020
        //   select LUSL20
        //   find (padr(lshifr, 10)) // длина lshifr 10 знаков
        //   // if found() .and. (eq_any(left(lshifr, 5), '1.12.') .or. is_ksg(lusl20->shifr)) // стоит другой КСГ
        //   if found() .and. (eq_any(left(lshifr, 5), code_services_VMP(2020)) .or. is_ksg(lusl20->shifr)) // стоит другой КСГ
        //     lrec := tmp->(recno())
        //     exit
        //   endif
        // elseif lyear == 2019
        //   select LUSL19
        //   find (padr(lshifr, 10)) // длина lshifr 10 знаков
        //   // if found() .and. (eq_any(left(lshifr,5), '1.12.') .or. is_ksg(lusl19->shifr)) // стоит другой КСГ
        //   if found() .and. (eq_any(left(lshifr, 5), code_services_VMP(2019)) .or. is_ksg(lusl19->shifr)) // стоит другой КСГ
        //     lrec := tmp->(recno())
        //     exit
        //   endif
        // else
        //   select LUSL18
        //   find (padr(lshifr, 10)) // длина lshifr 10 знаков
        //   // if found() .and. (eq_any(left(lshifr, 5), '1.12.') .or. is_ksg(lusl18->shifr)) // стоит другой КСГ
        //   if found() .and. (eq_any(left(lshifr, 5), code_services_VMP(2018)) .or. is_ksg(lusl18->shifr)) // стоит другой КСГ
        //     lrec := tmp->(recno())
        //     exit
        //   endif
        // endif
        select TMP
        skip
      enddo
      if empty(arr[2])
        if empty(lcena)
          lu_kod := foundOurUsluga(arr[3], human->k_data, human_->profil, human->VZROS_REB, @lcena)
          if lyear == 2023  // 23 год
            if len(arr) > 4 .and. !empty(arr[5])
              lcena := round_5(lcena + 25986.7 * ret_koef_kslp_21(arr[5], lyear), 0)
            endif
            if len(arr) > 5 .and. !empty(arr[6])
              lcena := round_5(lcena*arr[6,2],0)
            endif
          elseif lyear == 2022  // 22 год
              if len(arr) > 4 .and. !empty(arr[5])
                lcena := round_5(lcena + 24322.6 * ret_koef_kslp_21(arr[5], lyear), 0)
              endif
              if len(arr) > 5 .and. !empty(arr[6])
                lcena := round_5(lcena*arr[6, 2], 0)
              endif
          elseif lyear == 2021  // 21 год
            if len(arr) > 4 .and. !empty(arr[5])
              lcena := round_5(lcena * ret_koef_kslp_21(arr[5], lyear), 0)
            endif
            if len(arr) > 5 .and. !empty(arr[6])
              lcena := round_5(lcena*arr[6, 2], 0)
            endif
          elseif lyear > 2018  // округление до рублей с 2019 года
            if len(arr) > 4 .and. !empty(arr[5])
              lcena := round_5(lcena * ret_koef_kslp(arr[5]), 0)
            endif
            if len(arr) > 5 .and. !empty(arr[6])
              lcena := round_5(lcena*arr[6, 2], 0)
            endif
          else
            if len(arr) > 4 .and. !empty(arr[5])
              lcena := round_5(lcena*arr[5, 2], 1)
            endif
            if len(arr) > 5 .and. !empty(arr[6])
              lcena := round_5(lcena*arr[6, 2], 1)
            endif
          endif
          if round(arr[4], 2) == round(lcena, 2) // цена определена правильно
            usl->(dbGoto(lu_kod))
            select HU
            if lrec == 0
              Add1Rec(7)
              hu->kod := human->kod
            else
              select TMP
              goto (lrec)
              select HU
              goto (tmp->rec_hu)
              G_RLock(forever)
            endif
            mrec_hu := hu->(recno())
            hu->kod_vr  := human_->VRACH
            hu->kod_as  := 0
            hu->u_koef  := 1
            hu->u_kod   := lu_kod
            hu->u_cena  := lcena
            hu->is_edit := 0
            hu->date_u  := dtoc4(human->n_data)
            hu->otd     := human->otd
            hu->kol := hu->kol_1 := 1
            hu->stoim := hu->stoim_1 := lcena
            select HU_
            do while hu_->(lastrec()) < mrec_hu
              APPEND BLANK
            enddo
            goto (mrec_hu)
            G_RLock(forever)
            if lrec == 0 .or. !valid_GUID(hu_->ID_U)
              hu_->ID_U := mo_guid(3, hu_->(recno()))
            endif
            hu_->PROFIL := human_->PROFIL
            hu_->PRVS   := human_->PRVS
            hu_->kod_diag := human->KOD_DIAG
            hu_->zf := ''
            UnLock
            //
            select TMP
            if lrec == 0
              append blank
              hu->kod := human->kod
            else
              goto (lrec)
            endif
            tmp->KOD     := human->kod
            tmp->DATE_U  := hu->date_u
            tmp->U_KOD   := lu_kod
            tmp->U_CENA  := lcena
            tmp->KOD_VR  := human_->VRACH
            tmp->KOD_AS  := 0
            tmp->OTD     := human->otd
            tmp->KOL_1   := 1
            tmp->STOIM_1 := lcena
            tmp->kod_diag:= human->KOD_DIAG
            tmp->ZF      := ''
            tmp->PROFIL  := human_->PROFIL
            tmp->PRVS    := human_->PRVS
            tmp->date_u1 := human->n_data
            tmp->shifr_u := arr[3]
            tmp->shifr1  := arr[3]
            tmp->name_u  := usl->name
            tmp->is_nul  := usl->is_nul
            tmp->is_oms  := .t.
            tmp->n_base  := 0
            tmp->dom     := 0
            tmp->rec_hu  := mrec_hu
          else
            func_error(4, 'ОШИБКА: разница в цене услуги ' + lstr(arr[4]) + ' != ' + lstr(lcena))
            not_ksg := .f.
            lcena := 0
          endif
        endif
      elseif lrec > 0 // не удалось определить КСГ
        select TMP
        goto (lrec)
        select HU
        goto (tmp->rec_hu)
        DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
        select TMP
        DeleteRec(.t.)  // с пометкой на удаление
        lcena := 0
      endif
      if !(round(human->CENA_1, 2) == round(lcena+sdial, 2))
        select HUMAN
        G_RLock(forever)
        human->CENA := human->CENA_1 := lcena + sdial // перезапишем стоимость лечения
        UnLock
      endif
      put_str_kslp_kiro(arr)
      commit
      if empty(arr[2])
        if not_ksg
          i := len(arr[1])
          s := arr[1, i]
          if !('РЕЗУЛЬТАТ' $ arr[1, i]) .and. i > 1
            s := alltrim(arr[1, i - 1] + s)
          endif
          stat_msg(s)
          mybell(2, OK)
        endif
      else
        func_error(4,'ОШИБКА: ' + arr[2, 1])
      endif
    endif
    if is_usl1
      usl1->(dbCloseArea())
    endif
    usl->(dbCloseArea()) // переоткрыть справочник услуг
    R_Use(dir_server + 'uslugi', dir_server + 'uslugish', 'USL')
    select TMP
    set relation to otd into OTD
    if tmp_rec > 0
      goto (tmp_rec)
    endif
    select (tmp_select)
    rest_box(buf)
  endif
  return ret
  