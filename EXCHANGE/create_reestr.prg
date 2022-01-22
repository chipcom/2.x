#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 28.12.21
Function create_reestr()
  Local buf := save_maxrow(), i, j, k := 0, k1 := 0, arr, bSaveHandler, fl, rec, pole, arr_m

  if ! hb_user_curUser:IsAdmin()
    return func_error(4,err_admin)
  endif
  if find_unfinished_reestr_sp_tk()
    return func_error(4,"Попытайтесь снова")
  endif
  if (arr_m := year_month(T_ROW,T_COL+5,,3)) == NIL
    return NIL
  endif
  //!!! ВНИМАНИЕ
  // if 2022 == arr_m[1]
  if 2023 == arr_m[1]
    return func_error(4,"Реестры за 2022 год недоступны")
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
      {"fio"      ,"C",50,0},;
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
          if ! exist_reserve_KSG(human->kod, 'HUMAN')
            tmp->kol++
            tmp->min_date := min(tmp->min_date,human->k_data)
          endif
          tmp->summa += human->cena_1
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
      // if .f.
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
              tmpb->fio := human->fio
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
  
  