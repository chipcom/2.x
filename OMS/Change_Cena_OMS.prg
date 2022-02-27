#include 'function.ch'
#include 'chip_mo.ch'

***** 23.10.19 Изменение цен на услуги в соответствии со справочником услуг ТФОМС
Function Change_Cena_OMS()
  Local buf := save_maxrow(), lshifr1, fl, lrec, rec_human, k_data2, kod_ksg, begin_date := addmonth(sys_date,-3)
  Local fl_ygl_disp := .F.
  if begin_date < boy(begin_date)
    begin_date := boy(begin_date)
  endif
  n_message({"Данный режим предназначен для изменения цен на услуги",;
             "и суммы случаев в листах учёта, которые не включены",;
             "в реестры (счета), на цены из справочника услуг ТФОМС.",;
             "ВНИМАНИЕ !!!",;
             "Во время выполнения данной операции",;
             "никто не должен работать в задаче ОМС."},,;
             "GR+/R","W+/R",,,"G+/R")
  if f_Esc_Enter("изменения цен",.t.) .and. mo_Lock_Task(X_OMS)
    mywait()
    fl := .t.
    bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
    BEGIN SEQUENCE
      R_Use(dir_server+"human")
      index on str(schet,6)+str(tip_h,1)+upper(substr(fio,1,20)) to (dir_server+"humans") progress
      Use
      R_Use(dir_server+"human_u")
      index on str(kod,7)+date_u to (dir_server+"human_u") progress
      Use
    RECOVER USING error
      fl := func_error(10,"Возникла непредвиденная ошибка при переиндексировании!")
    END
    ERRORBLOCK(bSaveHandler)
    close databases
    if fl
      WaitStatus()
      use_base("lusl")
      use_base("luslc")
      use_base("luslf")
      Use_base("mo_su")
      set order to 0
    //dbselectarea("luslc20")
  
      G_Use(dir_server+"uslugi",{dir_server+"uslugish",;
                                 dir_server+"uslugi"},"USL")
      set order to 0
      Use_base("mo_hu")
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"mo_uch",,"UCH")
      G_Use(dir_server+"human_u",dir_server+"human_u","HU")
      G_Use(dir_server+"human_2",,"HUMAN_2")
      G_Use(dir_server+"human_",,"HUMAN_")
      G_Use(dir_server+"human",dir_server+"humans","HUMAN")
      set relation to recno() into HUMAN_, to recno() into HUMAN_2
      sm_human := i_human := 0
      find (str(0,6))
      do while human->schet == 0 .and. !eof()
        // цикл по людям
        UpdateStatus()
        k_data2 := human->k_data
        if human->ishod == 88
          rec_human := human->(recno())
          select HUMAN
          goto (human_2->pn4) // ссылка на 2-й лист учёта
          k_data2 := human->k_data // переприсваиваем дату окончания лечения
          goto (rec_human)
        endif
        if human_->reestr == 0 .and. k_data2 > begin_date
          ++sm_human
          @ maxrow(),1  say lstr(i_human) color "G+/R"
          @ row(),col() say "/" color "R+/R"
          @ row(),col() say lstr(sm_human) color "GR+/R"
          uch->(dbGoto(human->LPU))
          otd->(dbGoto(human->OTD))
          f_put_glob_podr(human_->USL_OK,human->k_data) // заполнить код подразделения
          sdial := mcena_1 := 0 ; fl := .f. ; kod_ksg := ""
          select HU
          find (str(human->kod,7))
          if human->ishod == 401 .or. human->ishod == 402
            fl_ygl_disp := .T.
          else 
            fl_ygl_disp := .F.
          endif
          do while hu->kod == human->kod .and. !eof()
            // цикл по услугам
            usl->(dbGoto(hu->u_kod))
            mdate := c4tod(hu->date_u)
            lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,k_data2)
            if is_usluga_TFOMS(usl->shifr,lshifr1,k_data2)
              lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
              if human_->USL_OK < 3 .and. is_ksg(lshifr)
                kod_ksg := lshifr
                lrec := hu->(recno())
              else
                lu_cena := hu->u_cena
                fl_del := fl_uslc := .f.
                v := fcena_oms(lshifr,;
                               (human->vzros_reb==0),;
                               k_data2,;
                               @fl_del,;
                               @fl_uslc)
                if fl_uslc // если нашли в справочнике ТФОМС
                  lu_cena := v
                endif
                mstoim_1 := round_5(lu_cena * hu->kol_1,2)
                select HU
                if !(round(hu->u_cena,2) == round(lu_cena,2) .and. round(hu->stoim_1,2) == round(mstoim_1,2))
                  G_RLock(forever)
                  replace u_cena  with lu_cena, stoim with mstoim_1, stoim_1 with mstoim_1
                  fl := .t.
                  // возможна добавка по УД
                endif
                if fl_ygl_disp .and. hu->kod_vr == 0 .and. hu->kod_as == 0
                  // не суммируем 
                else  
                   mcena_1 += hu->stoim_1
                endif
                //my_debug(,"Сумма накопительная")
                //my_debug(,mcena_1)
              endif
            endif
            select HU
            skip
          enddo
          if !empty(kod_ksg)
            if select("K006") != 0
              k006->(dbCloseArea())
            endif
            if year(human->k_data) > 2018
              arr_ksg := definition_KSG(1,k_data2)
            else
              arr_ksg := definition_KSG_18()
            endif
            fl1 := .t.
            if len(arr_ksg) == 7
              if valtype(arr_ksg[7]) == "N"
                sdial := arr_ksg[7] // для 2019 года
              else
                fl1 := .f. // для 2018 года
              endif
            endif
            if !fl1 // диализ 2018 года
              //
            elseif empty(arr_ksg[2]) // нет ошибок
              mcena_1 := arr_ksg[4]
              select HU
              goto (lrec)
              if !(round(mcena_1,2) == round(hu->u_cena,2))
                G_RLock(forever)
                replace u_cena  with mcena_1, stoim with mcena_1, stoim_1 with mcena_1
                fl := .t.
              endif
              put_str_kslp_kiro(arr_ksg)
            endif
          endif
          if fl .or. !(round(mcena_1+sdial,2) == round(human->cena_1,2))
            ++i_human
            human->(G_RLock(forever))
            human->cena := human->cena_1 := mcena_1+sdial
            human_->(G_RLock(forever))
            human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
            human_->ST_VERIFY := 0 // снова ещё не проверен
            UnLock ALL
          endif
          if sm_human % 1000 == 0
            COMMIT
          endif
        endif
        select HUMAN
        skip
      enddo
      close databases
      rest_box(buf)
      ///////////////////// ОБРАБОТКА ЗАВЕРШЕНА  //////////////////////////
      if sm_human == 0
        func_error(4,"В базе данных нет пациентов, не попавших в реестры (счета)!")
      elseif i_human == 0
        func_error(4,"Не обнаружено листов учёта с необходимостью пересчёта цен")
      else
        n_message({"Изменение цен произведено - "+lstr(i_human)+" л/у"},,"W/RB","BG+/RB",,,"G+/RB")
      endif
    endif
    mo_UnLock_Task(X_OMS)
    close databases
  endif
  return NIL
  