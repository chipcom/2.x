***** mo_omsfo.prg - информация по ОМС (объём работ по номенклатуре ФФОМС)
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch := 1
Static lcount_otd := 1

***** 30.08.16 вернуть вид помощи (bit-овый вариант)
Function fbp_mz_rf(r,c)
Static sast := {}
Local fl := .t., i, j, a, arr := {}
if glob_menu_mz_rf[1]
  aadd(arr, {"стационар",1})
endif  
if glob_menu_mz_rf[2]
  aadd(arr, {"дневной стационар",2})
endif  
if glob_menu_mz_rf[3]
  aadd(arr, {"стоматология",3})
endif  
if (j := len(arr)) == 1
  return arr
elseif j > 1
  if len(sast) != j
    sast := array(j) ; afill(sast,.t.)
  endif
  if (a := bit_popup(r,c,arr,sast)) != NIL
    afill(sast,.f.) ; fl := .t.
    for i := 1 to len(a)
      if (j := ascan(arr,{|x| x[2]==a[i,2] })) > 0
        sast[j] := .t.
      endif
    next
  endif
endif
return a

***** 30.08.16
Function obF2_statist(k,serv_arr)
Local i, j, arr[2], begin_date, end_date, bk := 1, ek := 99, al,;
      fl_exit := .f., sh := 80, HH := 57, regim := 2, s, fl_1_list := .t.,;
      len_n, pkol, pkol1, ptrud, old_perso, old_vr_as, old_usl,;
      old_fio, arr_otd := {}, md, mkol, mkol1, arr_kd := {}, len_kd := 0,;
      xx, yy, pole_va, lrec, t_date1, t_date2, arr_title, msum, msum_opl,;
      musluga, mperso := {}, mkod_perso, arr_usl := {}, adbf1, adbf2, ;
      arr_svod_nom := {}, arr_m, lshifr1
Private is_all := .t., ret_mz_rf
Private skol := {0,0}, skol1 := {0,0}, strud := {0,0}
if eq_any(k,2,3,4,8,9)  // по отделению
  if (st_a_otd := inputN_otd(T_ROW,T_COL-5,.f.,.f.,,@lcount_otd)) == NIL
    return NIL
  endif
  aeval(st_a_otd, {|x| aadd(arr_otd,x) })
  if k == 8 .and. (musluga := input_Fusluga()) == NIL
    return NIL
  endif
  if k == 9 .and. !input_perso(T_ROW,T_COL-5,.f.)
    return NIL
  endif
else  // по учреждению(ям)
  if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
    return NIL
  endif
  R_Use(dir_server+"mo_otd",,"OTD")
  dbeval({|| aadd(arr_otd,{otd->(recno()),otd->name,otd->kod_lpu}) },;
         {|| f_is_uch(st_a_uch,otd->kod_lpu)} )
  otd->(dbCloseArea())
  if ((k==5.and.serv_arr==NIL) .or. k==13) .and. !input_perso(T_ROW,T_COL-5,.f.)
    return NIL
  endif
endif
//
if eq_any(k,3,31,4,13)
  if (xx := popup_prompt(T_ROW,T_COL-5,1,{"Все ~услуги","~Список услуг"})) == 0
    return NIL
  endif
  is_all := (xx == 1)
endif
//
Private ym_kol_mes := 1
arr_m := {year(sys_date),month(sys_date),,,sys_date,sys_date,,}
if pi1 != 4
  if (arr := year_month()) == NIL
    return NIL
  endif
  begin_date := arr[7]
  end_date := arr[8]
  arr_m := aclone(arr)
endif
if k == 5 .and. serv_arr != NIL
  if serv_arr[1] == 1  // N человек
    if (mperso := input_kperso()) == NIL
      return NIL
    endif
  elseif serv_arr[1] == 2  // весь персонал
    mywait()
    mperso := {}
    R_Use(dir_server+"mo_hu",{dir_server+"mo_huv",;
                              dir_server+"mo_hua"},"HU")
    R_Use(dir_server+"mo_pers",,"P2")
    go top
    do while !eof()
      if p2->kod > 0
        fl := .f.
        select HU
        set order to 1
        find (str(p2->kod,4))
        if !(fl := found())
          set order to 2
          find (str(p2->kod,4))
          fl := found()
        endif
        if fl
          aadd(mperso, {p2->kod,""} )
        endif
      endif
      select P2
      skip
    enddo
    hu->(dbCloseArea())
    p2->(dbCloseArea())
  endif
endif
if !fbp_ist_fin(T_ROW,T_COL-5)
  return NIL
endif
if (ret_mz_rf := fbp_mz_rf(T_ROW,T_COL-5)) == NIL
  return NIL
endif
adbf1 := {;
     {"U_KOD"  ,    "N",      6,      0},;  // код услуги
     {"U_SHIFR",    "C",     20,      0},;  // шифр услуги
     {"U_NAME",     "C",    255,      0},;  // наименование услуги
     {"FIO",        "C",     25,      0},;  // ФИО больного
     {"KOD",        "N",      7,      0},;  // код больного
     {"K_DATA",     "D",      8,      0},;  // дата окончания лечения
     {"TRUDOEM",    "N",     13,      2},;  // количество УЕТ
     {"KOL"    ,    "N",      5,      0},;  // количество услуг
     {"KOL1"   ,    "N",      5,      0} ;  // количество услуг
    }
adbf2 := {;
     {"otd",        "N",      3,      0},;  // отделение, где оказана услуга
     {"U_KOD"  ,    "N",      6,      0},;  // код услуги
     {"U_SHIFR",    "C",     20,      0},;  // шифр услуги
     {"U_NAME",     "C",    255,      0},;  // наименование услуги
     {"VR_AS",      "N",      1,      0},;  // врач - 1 ; ассистент - 2
     {"TAB_NOM",    "N",      5,      0},;  // таб.номер врача (ассистента)
     {"SVOD_NOM",   "N",      5,      0},;  // сводный таб.номер
     {"KOD_VR_AS",  "N",      4,      0},;  // код врача (ассистента)
     {"FIO",        "C",     60,      0},;  // Ф.И.О. врача (ассистента)
     {"KOD_AS" ,    "N",      4,      0},;  // код ассистента
     {"TRUDOEM",    "N",     13,      2},;  // количество УЕТ
     {"KOL"    ,    "N",      6,      0},;  // количество услуг
     {"KOL1"   ,    "N",      6,      0} ;  // количество услуг
    }
if !is_all
  dbcreate(cur_dir+"tmp", adbf2)
  use (cur_dir+"tmp") new
  index on str(u_kod,6) to (cur_dir+"tmpk")
  index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
  close databases
  obF2_v_usl()
  use (cur_dir+"tmp") new
  dbeval({|| aadd(arr_usl,tmp->u_kod) } )
  use
  if len(arr_usl) == 0
    return NIL
  endif
endif
if eq_any(k,8,9,13,14)  // вывод списка больных
  dbcreate(cur_dir+"tmp", adbf1)
else
  dbcreate(cur_dir+"tmp", adbf2)
endif
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
use (cur_dir+"tmp")
do case
  case k == 1  // Количество услуг и сумма лечения по отделениям
    index on str(otd,3) to (cur_dir+"tmpk")
    index on str(u_kod,6)+upper(fio) to (cur_dir+"tmpn")
  case k == 2  // Статистика по работе персонала в конкретном отделении
    index on str(vr_as,1)+str(kod_vr_as,4) to (cur_dir+"tmpk")
    index on upper(left(fio,30))+str(kod_vr_as,4)+str(vr_as,1) to (cur_dir+"tmpn")
  case k == 3  // Статистика по услугам, оказанным в конкретном отделении
    index on str(u_kod,6) to (cur_dir+"tmpk")
    index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
  case k == 31  // Статистика по услугам, оказанным в конкретных отделениях
    index on str(otd,3)+str(u_kod,6) to (cur_dir+"tmpk")
    index on upper(fio)+str(otd,3)+fsort_usl(u_shifr) to (cur_dir+"tmpn")
  case k == 4  // Статистика по работе персонала (плюс оказанные услуги) в конкретном отделении
    index on str(vr_as,1)+str(kod_vr_as,4)+str(u_kod,6) to (cur_dir+"tmpk")
    index on upper(left(fio,30))+str(kod_vr_as,4)+str(vr_as,1)+fsort_usl(u_shifr) to (cur_dir+"tmpn")
  case k == 5  // Статистика по работе конкретного человека (плюс оказанные услуги)
    index on str(vr_as,1)+str(kod_vr_as,4)+str(u_kod,6) to (cur_dir+"tmpk")
    if serv_arr == NIL
      index on str(vr_as,1)+fsort_usl(u_shifr) to (cur_dir+"tmpn")
    else
      index on upper(left(fio,30))+str(kod_vr_as,4)+str(vr_as,1)+fsort_usl(u_shifr) to (cur_dir+"tmpn")
    endif
  case k == 6  // Статистика по конкретным услугам
    index on str(u_kod,6) to (cur_dir+"tmpk")
    index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
    close databases
    obF2_v_usl()
  case k == 7  // Статистика по работе всего персонала
    index on str(vr_as,1)+str(kod_vr_as,4) to (cur_dir+"tmpk")
    index on upper(left(fio,30))+str(kod_vr_as,4)+str(vr_as,1) to (cur_dir+"tmpn")
  case eq_any(k,8,9)  // вывод списка больных
    index on str(kod,7) to (cur_dir+"tmpk")
    index on dtos(k_data)+upper(left(fio,30)) to (cur_dir+"tmpn")
  case k == 12 // Статистика по всем услугам
    index on str(u_kod,6) to (cur_dir+"tmpk")
    index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
  case k == 13  // вывод услуг + списка больных
    index on str(u_kod,6)+str(kod,7) to (cur_dir+"tmpk")
    index on fsort_usl(u_shifr)+str(u_kod,6)+dtos(k_data)+upper(left(fio,30)) to (cur_dir+"tmpn")
  case k == 14  // Статистика по конкретным услугам + список больных
    index on str(u_kod,6)+str(kod,7) to (cur_dir+"tmpk")
    index on fsort_usl(u_shifr)+str(u_kod,6)+dtos(k_data)+upper(left(fio,30)) to (cur_dir+"tmpn")
    close databases
    obF2_v_usl()
endcase
use (cur_dir+"tmp") index (cur_dir+"tmpk"),(cur_dir+"tmpn") alias TMP
R_Use(dir_server+"mo_su",,"USL")
Private is_1_usluga := (len(arr_usl) == 1)
use_base("luslf")
R_Use(dir_server+"mo_pers",,"PERSO")
if eq_any(k,5,9,13)  // Статистика по работе конкретного человека
  if serv_arr == NIL
    mperso := {glob_human}
  endif
  if pi1 == 4  // по невыписанным счетам
    pole_kol := "hu->kol_1"
    R_Use(dir_server+"mo_hu",dir_server+"mo_hu","HU")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humann","HUMAN")
    set relation to recno() into HUMAN_
    dbseek("1",.t.)
    do while human->tip_h < B_SCHET .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        if iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
          mkod_perso := 0
          if hu->kod_vr > 0 .and. ascan(mperso, {|x| x[1] == hu->kod_vr } ) > 0
            mkod_perso := hu->kod_vr
          elseif hu->kod_as > 0 .and. ascan(mperso, {|x| x[1] == hu->kod_as } ) > 0
            mkod_perso := hu->kod_as
          endif
          if mkod_perso > 0
            if k == 5
              obF3_statist(k, arr_otd, serv_arr, mkod_perso)
            elseif eq_any(k,9,13)
              obF5_statist(k, arr_otd, serv_arr)
            endif
          endif
        endif
        select HU
        skip
      enddo
      select HUMAN
      skip
    enddo
  else   // between(pi1,1,3)
    R_Use(dir_server+"schet",,"SCHET")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humank","HUMAN")
    set relation to recno() into HUMAN_
    R_Use(dir_server+"mo_hu",{dir_server+"mo_huv",;
                              dir_server+"mo_hua",;
                              dir_server+"mo_hu"},"HU")
    for yy := 1 to len(mperso)
      mkod_perso := mperso[yy,1]
      for xx := 1 to 2
        pole_va := {"hu->kod_vr","hu->kod_as"}[xx]
        select HU
        if xx == 1
          set order to 1
        elseif xx == 2
          set order to 2
        endif
        do case
          case pi1 == 1  // по дате оказания услуги
            pole_kol := "hu->kol_1"
            select HU
            dbseek(str(mkod_perso,4)+begin_date,.t.)
            do while &pole_va == mkod_perso .and. hu->date_u <= end_date .and. !eof()
              UpdateStatus()
              if inkey() == K_ESC
                fl_exit := .t. ; exit
              endif
              if iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
                human->(dbSeek(str(hu->kod,7)))
                if human_->oplata < 9
                  if k == 5
                    obF3_statist(k, arr_otd, serv_arr, mkod_perso)
                  elseif eq_any(k,9,13) .and. iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
                    obF5_statist(k, arr_otd, serv_arr)
                  endif
                endif
              endif
              select HU
              skip
            enddo
          case between(pi1,2,3)  // по дате выписки счета и окончания лечения
            pole_kol := "hu->kol_1"
            select HU
            dni_vr := max(366,mem_dni_vr) // отнимем min год
            dbseek(str(mkod_perso,4)+dtoc4(arr[5]-dni_vr),.t.)
            do while &pole_va == mkod_perso .and. hu->date_u <= end_date .and. !eof()
              UpdateStatus()
              if inkey() == K_ESC
                fl_exit := .t. ; exit
              endif
              if iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
                select HUMAN
                find (str(hu->kod,7))
                fl := .f.
                if human_->oplata < 9
                  if pi1 == 2
                    if human->schet > 0 //.and. human->cena_1 > 0
                      select SCHET
                      goto (human->schet)
                      fl := between(schet->pdate,begin_date,end_date)
                    endif
                  else // pi1 == 3
                    fl := between(human->k_data,arr_m[5],arr_m[6])
                    fl := func_pi_schet(fl)
                  endif
                endif
                if fl
                  if k == 5
                    obF3_statist(k, arr_otd, serv_arr, mkod_perso)
                  elseif eq_any(k,9,13)
                    obF5_statist(k, arr_otd, serv_arr)
                  endif
                endif
              endif
              select HU
              skip
            enddo
        endcase
      next
      if fl_exit ; exit ; endif
    next
  endif
elseif eq_any(k,6,8,14)  // Статистика по конкретным(ой) услугам(е)
  if eq_any(k,6,14)
    select TMP  // в базе данных уже занесены необходимые нам услуги
                // переносим их в массив arr_usl
    dbeval({|| aadd(arr_usl,{tmp->u_kod,tmp->(recno())}) } )
    if k == 14
      zap
    endif
  elseif k == 8
    arr_usl := {{musluga[1],0}}
  endif
  is_1_usluga := (len(arr_usl) == 1)
  if pi1 == 4  // по невыписанным счетам
    pole_kol := "hu->kol_1"
    R_Use(dir_server+"mo_hu",dir_server+"mo_hu","HU")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humann","HUMAN")
    set relation to recno() into HUMAN_
    dbseek("1",.t.)
    do while human->tip_h < B_SCHET .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        if (i := ascan(arr_usl, {|x| x[1] == hu->u_kod } )) > 0
          if k == 6
            tmp->(dbGoto(arr_usl[i,2]))
            lrec := tmp->(recno())
            obF3_statist(k, arr_otd, serv_arr)
          elseif eq_any(k,8,14)
            obF5_statist(k, arr_otd, serv_arr)
          endif
        endif
        select HU
        skip
      enddo
      select HUMAN
      skip
    enddo
  else   // between(pi1,1,3)
    t_date1 := dtoc4(arr[5]-180)
    t_date2 := dtoc4(arr[5]-1)
    R_Use(dir_server+"schet",,"SCHET")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humank","HUMAN")
    set relation to recno() into HUMAN_
    R_Use(dir_server+"mo_hu",{dir_server+"mo_huk",;
                              dir_server+"mo_hu"},"HU")
    for xx := 1 to len(arr_usl)
      if k == 6
        tmp->(dbGoto(arr_usl[xx,2]))
        lrec := tmp->(recno())
      endif
      do case
        case pi1 == 1  // по дате оказания услуги
          pole_kol := "hu->kol_1"
          select HU
          find (str(arr_usl[xx,1],6))
          do while hu->u_kod == arr_usl[xx,1] .and. !eof()
            UpdateStatus()
            if inkey() == K_ESC
              fl_exit := .t. ; exit
            endif
            select HUMAN
            find (str(hu->kod,7))
            if human_->oplata < 9 .and. between(hu->date_u,begin_date,end_date)
              if k == 6
                obF3_statist(k, arr_otd, serv_arr)
              elseif eq_any(k,8,14)
                obF5_statist(k, arr_otd, serv_arr)
              endif
            endif
            select HU
            skip
          enddo
        case between(pi1,2,3)  // по дате выписки счета и окончания лечения
          pole_kol := "hu->kol_1"
          select HU
          find (str(arr_usl[xx,1],6))
          do while hu->u_kod == arr_usl[xx,1] .and. !eof()
            UpdateStatus()
            if inkey() == K_ESC
              fl_exit := .t. ; exit
            endif
            select HUMAN
            find (str(hu->kod,7))
            fl := .f.
            if human_->oplata < 9
              if pi1 == 2
                if human->schet > 0 //.and. human->cena_1 > 0
                  select SCHET
                  goto (human->schet)
                  fl := between(schet->pdate,begin_date,end_date)
                endif
              else // pi1 == 3
                fl := between(human->k_data,arr_m[5],arr_m[6])
                fl := func_pi_schet(fl)
              endif
            endif
            if fl
              if k == 6
                obF3_statist(k, arr_otd, serv_arr)
              elseif eq_any(k,8,14)
                obF5_statist(k, arr_otd, serv_arr)
              endif
            endif
            select HU
            skip
          enddo
      endcase
      if fl_exit ; exit ; endif
    next
  endif
else
  do case
    case pi1 == 1  // по дате оказания услуги
      pole_kol := "hu->kol_1"
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_
      R_Use(dir_server+"mo_hu",dir_server+"mo_hud","HU")
      set relation to kod into HUMAN
      select HU
      dbseek(begin_date,.t.)
      do while hu->date_u <= end_date .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if human_->oplata < 9 .and. iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
          obF3_statist(k, arr_otd, serv_arr)
        endif
        select HU
        skip
      enddo
      select HU
      set relation to
    case pi1 == 2  // по дате выписки счета
      pole_kol := "hu->kol_1"
      R_Use(dir_server+"mo_hu",dir_server+"mo_hu","HU")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",dir_server+"humans","HUMAN")
      set relation to recno() into HUMAN_
      R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
      set filter to !eq_any(mest_inog,6,7)
      dbseek(begin_date,.t.)
      do while schet->pdate <= end_date .and. !eof()
        select HUMAN
        find (str(schet->kod,6))
        do while human->schet == schet->kod .and. !eof()
          UpdateStatus()
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          if human_->oplata < 9
            select HU
            find (str(human->kod,7))
            do while hu->kod == human->kod .and. !eof()
              if iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
                obF3_statist(k, arr_otd, serv_arr)
              endif
              select HU
              skip
            enddo
          endif
          select HUMAN
          skip
        enddo
        if fl_exit ; exit ; endif
        select SCHET
        skip
      enddo
    case pi1 == 3  // по дате окончания лечения
      pole_kol := "hu->kol_1"
      R_Use(dir_server+"mo_hu",dir_server+"mo_hu","HU")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",dir_server+"humand","HUMAN")
      set relation to recno() into HUMAN_
      dbseek(dtos(arr_m[5]),.t.)
      do while human->k_data <= arr_m[6] .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if human_->oplata < 9 .and. func_pi_schet(.t.)
          select HU
          find (str(human->kod,7))
          do while hu->kod == human->kod .and. !eof()
            if iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
              obF3_statist(k, arr_otd, serv_arr)
            endif
            select HU
            skip
          enddo
        endif
        select HUMAN
        skip
      enddo
    case pi1 == 4  // по невыписанным счетам
      pole_kol := "hu->kol_1"
      R_Use(dir_server+"mo_hu",dir_server+"mo_hu","HU")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",dir_server+"humann","HUMAN")
      set relation to recno() into HUMAN_
      dbseek("1",.t.)
      do while human->tip_h < B_SCHET .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        select HU
        find (str(human->kod,7))
        do while hu->kod == human->kod .and. !eof()
          if iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
            obF3_statist(k, arr_otd, serv_arr)
          endif
          select HU
          skip
        enddo
        select HUMAN
        skip
      enddo
  endcase
endif
j := tmp->(lastrec())
close databases
if fl_exit ; return NIL ; endif
if j == 0
  func_error(4,"Нет сведений!")
else
  mywait()
  fl_kol1 := .f.
  if eq_any(k,8,9,13,14)
    arr_title := {;
"─────────────────────────┬─────┬────────╥───────────────┬────────╥──────────",;
"                         │ Кол.│  Дата  ║               │  Дата  ║          ",;
"         Ф.И.О.          │услуг│окон.леч║  Номер счета  │  счета ║Примечание",;
"─────────────────────────┴─────┴────────╨───────────────┴────────╨──────────"}
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humank","HUMAN")
    set relation to recno() into HUMAN_
    R_Use(dir_server+"schet_",,"SCHET_")
    R_Use(dir_server+"schet",,"SCHET")
    set relation to recno() into SCHET_
  else
    len_n := sh-8
    if (fl_kol1 := eq_any(k,2,4,5,7))
      len_n -= 8
    endif
    fl_uet := .f.
    if ascan(ret_mz_rf,{|x| x[2] == 3 }) > 0
      fl_uet := .t.
      len_n -= 9
    endif
    arr_title := array(4)
    arr_title[1] := replicate("─",len_n)
    arr_title[2] := space(len_n)
    arr_title[3] := space(len_n)
    arr_title[4] := replicate("─",len_n)
    if fl_uet
      arr_title[1] += "┬────────"
      arr_title[2] += "│        "
      arr_title[3] += "│ У.Е.Т. "
      arr_title[4] += "┴────────"
    endif
    if fl_kol1
      arr_title[1] += "┬───────┬───────"
      arr_title[2] += "│ Кол-во│ Кол-во"
      arr_title[3] += "│  врач │ ассис."
      arr_title[4] += "┴───────┴───────"
    else
      arr_title[1] += "┬───────"
      arr_title[2] += "│ Кол-во"
      arr_title[3] += "│ услуг "
      arr_title[4] += "┴───────"
    endif
  endif
  sh := len(arr_title[1])
  SET(_SET_DELETED, .F.)
  use_base("luslf")
  R_Use(dir_server+"mo_su",,"USL")
  use (cur_dir+"tmp") index (cur_dir+"tmpk"),(cur_dir+"tmpn") NEW alias TMP
  if !eq_any(k,1,8,9)
    R_Use(dir_server+"mo_pers",,"PERSO")
    select TMP
    set order to 0
    go top
    do while !eof()
      if eq_any(k,3,31,4,5,6,12,13,14)
        select USL
        goto (tmp->u_kod)
        if usl->kod <= 0 .or. deleted() .or. eof()
          select TMP
          DELETE
        else
          lname := usl->name
          select LUSLF
          find (usl->shifr1)
          if found()
            lname := luslf->name
          else
            select LUSLF17
            find (usl->shifr1)
            if found()
              lname := luslf17->name
            else
              select LUSLF15
              find (usl->shifr1)
              if found()
                lname := luslf15->name
              else
                select LUSLF14
                find (usl->shifr1)
                if found()
                  lname := luslf14->name
                endif  
              endif
            endif
          endif
          tmp->u_shifr := usl->shifr1
          s := ""
          if !empty(usl->shifr)
            s += "("+alltrim(usl->shifr)+")"
          endif
          tmp->u_name := s + lname
        endif
      endif
      if fl_kol1
        select PERSO
        goto (tmp->kod_vr_as)
        if deleted() .or. eof()
          select TMP
          DELETE
        else
          tmp->fio := perso->fio
          tmp->tab_nom := perso->tab_nom
          tmp->svod_nom := perso->svod_nom
          if k == 7 .and. !empty(perso->tab_nom) .and. !empty(perso->svod_nom)
            if (i := ascan(arr_svod_nom, {|x| x[1] == perso->svod_nom .and. x[2] == tmp->vr_as})) == 0
              aadd(arr_svod_nom, {perso->svod_nom,tmp->vr_as,{}} )
              i := len(arr_svod_nom)
            endif
            aadd(arr_svod_nom[i,3], tmp->(recno()) )
            tmp->u_shifr := lstr(perso->svod_nom)
          endif
        endif
      endif
      select TMP
      skip
    enddo
    if k == 7 .and. len(arr_svod_nom) > 0
      select TMP
      for i := 1 to len(arr_svod_nom)
        pkol := pkol1 := ptrud := 0
        for j := 2 to len(arr_svod_nom[i,3])
          goto (arr_svod_nom[i,3,j])
          pkol   += tmp->KOL
          pkol1  += tmp->KOL1
          ptrud  += tmp->trudoem
          DELETE
        next
        goto (arr_svod_nom[i,3,1])
        tmp->KOL  += pkol
        tmp->KOL1 += pkol1
        ptrud  += tmp->trudoem
      next
    endif
  endif
  SET(_SET_DELETED, .T.)
  fp := fcreate("obF_stat"+stxt) ; tek_stroke := 0 ; n_list := 1
  add_string(padl("дата печати "+date_8(sys_date),sh))
  if k == 1
    add_string(center("Статистика по отделениям",sh))
    titleN_uch(st_a_uch,sh,lcount_uch)
  elseif k == 5
    add_string(center("Статистика по оказанным услугам",sh))
    titleN_uch(st_a_uch,sh,lcount_uch)
    if serv_arr == NIL  // по одному человеку
      add_string(center('"'+upper(glob_human[2])+;
                        ' ['+lstr(glob_human[5])+']"',sh))
    endif
  elseif eq_any(k,6,14)
    add_string(center("Статистика по услугам",sh))
    titleN_uch(st_a_uch,sh,lcount_uch)
  elseif k == 7
    add_string(center("Статистика по работе персонала",sh))
    titleN_uch(st_a_uch,sh,lcount_uch)
  elseif k == 12
    add_string(center("Статистика по всем оказанным услугам",sh))
    titleN_uch(st_a_uch,sh,lcount_uch)
  elseif k == 13
    add_string(center("Список больных, которым были оказаны услуги врачом (ассистентом):",sh))
    add_string(center('"'+upper(glob_human[2])+;
                      ' ['+lstr(glob_human[5])+']"',sh))
    titleN_uch(st_a_uch,sh,lcount_uch)
  else
    add_string(center("Статистика по отделению",sh))
    titleN_otd(st_a_otd,sh,lcount_otd)
    add_string(center("< "+alltrim(glob_uch[2])+" >",sh))
    if eq_any(k,8,9)
      add_string("")
      if k == 8
        add_string(center("Список больных, которым была оказана услуга:",sh))
        for i := 1 to perenos(arr,'"'+musluga[2]+'"',sh)
          add_string(center(alltrim(arr[i]),sh))
        next
      else
        add_string(center("Список больных, которым были оказаны услуги врачом (ассистентом):",sh))
        add_string(center('"'+upper(glob_human[2])+' ['+lstr(glob_human[5])+']"',sh))
      endif
    endif
  endif
  s := "["
  for i := 1 to len(ret_mz_rf)
    s += ret_mz_rf[i,1]+", "
  next
  s := left(s,len(s)-2)+"]"
  add_string(center(s,sh))
  add_string("")
  _tit_ist_fin(sh)
  if pi1 != 4
    add_string(center(arr[4],sh))
    add_string("")
  endif
  do case
    case pi1 == 1
      s := "[ по дате оказания услуги ]"
    case pi1 == 2
      s := "[ по дате выписки счета ]"
    case pi1 == 3
      s := str_pi_schet()
    case pi1 == 4
      s := "[ по больным, ещё не включенным в счет ]"
  endcase
  add_string(center(s,sh))
  add_string("")
  select TMP
  set order to 2
  go top
  if eq_any(k,8,9,13,14)
    mb := mkol := old_usl := 0
    aeval(arr_title, {|x| add_string(x) } )
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      if eq_any(k,13,14) .and. tmp->u_kod != old_usl
        if old_usl > 0
          add_string(replicate("─",sh))
          add_string("Кол-во больных - "+lstr(mb)+",  кол-во услуг - "+lstr(mkol))
          mb := mkol := 0
        endif
        add_string("")
        for i := 1 to perenos(arr,rtrim(tmp->u_shifr)+". "+tmp->u_name,sh-2)
          add_string("│ "+arr[i])
        next
        add_string("└"+replicate("─",sh-1))
      endif
      old_usl := tmp->u_kod
      select HUMAN
      find (str(tmp->kod,7))
      select SCHET
      goto (human->schet)
      s := tmp->fio+put_val(tmp->kol,6)+" "+date_8(tmp->k_data)
      if human->tip_h >= B_SCHET
        s += padc(alltrim(schet_->nschet),17)+date_8(c4tod(schet->pdate))
      endif
      add_string(s)
      mkol += tmp->kol ; ++mb
      select TMP
      skip
    enddo
    add_string(replicate("─",sh))
    add_string("Кол-во больных - "+lstr(mb)+",  кол-во услуг - "+lstr(mkol))
  else
    pkol := pkol1 := ptrud := 0
    old_perso := tmp->kod_vr_as ; old_vr_as := tmp->vr_as
    old_fio := "["+put_tab_nom(tmp->tab_nom,tmp->svod_nom)+"] "
    old_fio += tmp->fio
    old_slugba := tmp->fio
    old_shifr := iif(k == 31, tmp->otd, tmp->kod_vr_as)
    if eq_any(k,2,5,7)
      old_perso := -1  // для печати Ф.И.О. в начале
    endif
    select TMP
    do while !eof()
      if k == 31 .and. old_shifr != tmp->otd
        add_string(space(4)+replicate(".",sh-4))
        s := padr(space(4)+old_slugba,len_n)
        if fl_uet
          s += umest_val(ptrud,9,2)
        endif
        add_string(s+put_val(pkol,8,0))
        add_string(replicate("─",sh))
        pkol := pkol1 := ptrud := 0
      endif
      if k == 4 .and. !(old_perso == tmp->kod_vr_as .and. old_vr_as == tmp->vr_as)
        add_string(space(4)+replicate(".",sh-4))
        s := padr(space(4)+old_fio,len_n)
        if fl_uet
          s += umest_val(ptrud,9,2)
        endif
        add_string(s+put_val(pkol,8,0)+put_val(pkol1,8,0))
        add_string(replicate("─",sh))
        pkol := pkol1 := ptrud := 0
      endif
      if fl_1_list .or. verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
        fl_1_list := .f.
      endif
      if k == 4
        pkol += tmp->kol
        pkol1 += tmp->kol1
        ptrud += tmp->trudoem
        skol[tmp->vr_as] += tmp->kol
        skol1[tmp->vr_as] += tmp->kol1
        strud[tmp->vr_as] += tmp->trudoem
        s := rtrim(tmp->u_shifr)+" "+alltrim(tmp->u_name)
        if len(s) > len_n 
          j := perenos(arr,s,len_n)
          s := padr(arr[1],len_n)
          if fl_uet
            s += umest_val(tmp->trudoem,9,2)
          endif
          add_string(s+put_val(tmp->kol,8,0)+put_val(tmp->kol1,8,0))
          for i := 2 to j
            add_string(padl(alltrim(arr[i]),len_n+1))
          next
        else
          s := padr(s,len_n)
          if fl_uet
            s += umest_val(tmp->trudoem,9,2)
          endif
          add_string(s+put_val(tmp->kol,8,0)+put_val(tmp->kol1,8,0))
        endif
        old_perso := tmp->kod_vr_as
        old_vr_as := tmp->vr_as
        old_fio := "["+put_tab_nom(tmp->tab_nom,tmp->svod_nom)+"] "+tmp->fio
      else
        do case
          case k == 31
            skol[1] += tmp->kol
            skol1[1] += tmp->kol1
            strud[1] += tmp->trudoem
            pkol += tmp->kol
            pkol1 += tmp->kol1
            ptrud += tmp->trudoem
            old_slugba := tmp->fio ; old_shifr := tmp->otd
            j := perenos(arr,rtrim(tmp->u_shifr)+" "+alltrim(tmp->u_name),len_n)
            s := padr(arr[1],len_n)
          case k == 1
            s := padr(tmp->fio,len_n)
            skol[1] += tmp->kol
            skol1[1] += tmp->kol1
            strud[1] += tmp->trudoem
          case eq_any(k,2,7)
            if empty(tmp->u_shifr)
              s := "["+put_tab_nom(tmp->tab_nom,tmp->svod_nom)+"]"
              if len(s) < 8
                s := padr(s,8)
              endif
            else
              s := padr("[+"+alltrim(tmp->u_shifr)+"]",8)
            endif
            if old_perso == tmp->kod_vr_as
              s := ""
            else
              s += tmp->fio
            endif
            s := padr(s,len_n)
            skol[tmp->vr_as] += tmp->kol
            skol1[tmp->vr_as] += tmp->kol1
            strud[1] += tmp->trudoem
            old_perso := tmp->kod_vr_as
          case eq_any(k,3,6,12)
            j := perenos(arr,rtrim(tmp->u_shifr)+" "+alltrim(tmp->u_name),len_n)
            s := padr(arr[1],len_n)
            skol[1] += tmp->kol
            skol1[1] += tmp->kol1
            strud[1] += tmp->trudoem
          case k == 5
            if serv_arr != NIL .and. old_perso != tmp->kod_vr_as
              if old_perso > 0
                add_string(replicate("─",sh))
                fl := .f.
                if !emptyall(skol[1],skol1[1])
                  fl := .t.
                  s := padl("И Т О Г О :  ",len_n)
                  if fl_uet
                    s += umest_val(strud[1],9,2)
                  endif
                  add_string(s+put_val(skol[1],8,0)+put_val(skol1[1],8,0))
                endif
                afill(skol,0) ; afill(skol1,0) ; afill(strud,0)
              endif
              add_string("")
              add_string(space(5)+put_tab_nom(tmp->tab_nom,tmp->svod_nom)+". "+upper(rtrim(tmp->fio)))
            endif
            j := perenos(arr,rtrim(tmp->u_shifr)+" "+alltrim(tmp->u_name),len_n)
            s := padr(arr[1],len_n)
            skol[tmp->vr_as] += tmp->kol
            skol1[tmp->vr_as] += tmp->kol1
            strud[1] += tmp->trudoem
            old_perso := tmp->kod_vr_as
        endcase
        if fl_uet
          s += umest_val(tmp->trudoem,9,2)
        endif
        add_string(s+put_val(tmp->kol,8,0)+iif(fl_kol1, put_val(tmp->kol1,8,0), ""))
        if eq_any(k,3,31,5,6,12) .and. j > 1
          for i := 2 to j
            add_string(padl(alltrim(arr[i]),len_n+1))
          next
        endif
      endif
      select TMP
      skip
    enddo
    if k == 31
      add_string(space(4)+replicate(".",sh-4))
      s := padr(space(4)+old_slugba,len_n) 
      if fl_uet
        s += umest_val(ptrud,9,2)
      endif
      add_string(s+put_val(pkol,8,0))
      add_string("")
    endif
    if k == 4
      add_string(space(4)+replicate(".",sh-4))
      s := padr(space(4)+old_fio,len_n)
      if fl_uet
        s += umest_val(ptrud,9,2)
      endif
      add_string(s+put_val(pkol,8,0)+put_val(pkol1,8,0))
      add_string("")
    endif
    add_string(replicate("─",sh))
    fl := .f.
    if !emptyall(skol[1],skol1[1])
      fl := .t.
      s := padl("И Т О Г О :  ",len_n)
      if fl_uet
        s += umest_val(strud[1],9,2)
      endif
      add_string(s+put_val(skol[1],8,0)+iif(fl_kol1, put_val(skol1[1],8,0), ""))
    endif
  endif
  fclose(fp)
  close databases
  viewtext("obF_stat"+stxt,,,,(sh>80),,,regim)
endif
return NIL

*

***** 29.01.17
Function _f_trud_F(lu_kod,lkol,lvzros_reb,lkod_vr,lkod_as)
Local mtrud := {0,0,0}
select USL
goto (lu_kod)
if !eof() .and. !empty(usl->shifr1)
  if year(human->k_data) > 2017
    select LUSLF
    find (usl->shifr1)
    mtrud[1] := mtrud[2] := mtrud[3] := round_5(lkol * iif(lvzros_reb==0, luslf->uetv, luslf->uetd), 2)
  elseif year(human->k_data) > 2016
    select LUSLF17
    find (usl->shifr1)
    mtrud[1] := mtrud[2] := mtrud[3] := round_5(lkol * iif(lvzros_reb==0, luslf17->uetv, luslf17->uetd), 2)
  else
    select LUSLF15
    find (usl->shifr1)
    mtrud[1] := mtrud[2] := mtrud[3] := round_5(lkol * iif(lvzros_reb==0, luslf15->uetv, luslf15->uetd), 2)
  endif
  if lkod_vr > 0 .and. lkod_as == 0
    mtrud[3] := 0
    mtrud[2] := mtrud[1]
  elseif lkod_vr == 0 .and. lkod_as > 0
    mtrud[2] := 0
    mtrud[3] := mtrud[1]
  endif
//my_debug(,usl->shifr1+"mtrud:"+print_array(mtrud))
endif  
return mtrud

***** 30.08.16
Static Function obF3_statist(k, arr_otd, serv_arr, mkod_perso)
Local i, j, k1 := 1, s1 := "1", mtrud := {0,0,0}
if !_f_ist_fin()
  return NIL
endif
if ascan(ret_mz_rf,{|x| x[2] == human_->USL_OK }) == 0
  return NIL
endif
if hu->u_kod > 0 .and. &pole_kol > 0 .and. (i := ascan(arr_otd, {|x| hu->otd==x[1]})) > 0
  mtrud := _f_trud_F(hu->u_kod,&pole_kol,human->vzros_reb,hu->kod_vr,hu->kod_as)
  select TMP
  do case
    case k == 1
      find (str(hu->otd,3))
      if !found()
        append blank
        tmp->otd := arr_otd[i,1]
        tmp->fio := arr_otd[i,2]
        if (j := ascan(st_a_uch, {|x| x[1] == arr_otd[i,3] } )) > 0
          tmp->u_kod := arr_otd[i,3]   // код ЛПУ
          tmp->fio := padr(arr_otd[i,2],31)+st_a_uch[j,2]
        endif
      endif
      tmp->kol += &pole_kol
      tmp->trudoem += mtrud[1]
    case eq_any(k,2,7)
      if hu->kod_vr > 0
        find ("1"+str(hu->kod_vr,4))
        if !found()
          append blank
          tmp->vr_as := 1
          tmp->kod_vr_as := hu->kod_vr
        endif
        tmp->kol += &pole_kol
        tmp->trudoem += mtrud[2]
      endif
      if hu->kod_as > 0
        find (s1+str(hu->kod_as,4))
        if !found()
          append blank
          tmp->vr_as := k1
          tmp->kod_vr_as := hu->kod_as
        endif
        tmp->kol1 += &pole_kol
        tmp->trudoem += mtrud[3]
      endif
    case eq_any(k,3,31,6)
      if k == 31
        find (str(hu->otd,3)+str(hu->u_kod,6))
      else
        find (str(hu->u_kod,6))
      endif
      if !found()
        append blank
        if k == 31
          tmp->otd := arr_otd[i,1]
          tmp->fio := arr_otd[i,2]
          if (j := ascan(st_a_uch, {|x| x[1] == arr_otd[i,3] } )) > 0
            tmp->fio := alltrim(tmp->fio)+" ["+alltrim(st_a_uch[j,2])+"]"
          endif
        endif
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += &pole_kol
      tmp->trudoem += mtrud[1]
    case k == 4
      if hu->kod_vr > 0
        find ("1"+str(hu->kod_vr,4)+str(hu->u_kod,6))
        if !found()
          append blank
          tmp->vr_as := 1
          tmp->kod_vr_as := hu->kod_vr
          tmp->u_kod := hu->u_kod
        endif
        tmp->kol += &pole_kol
        tmp->trudoem += mtrud[2]
      endif
      if hu->kod_as > 0
        find (s1+str(hu->kod_as,4)+str(hu->u_kod,6))
        if !found()
          append blank
          tmp->vr_as := k1
          tmp->kod_vr_as := hu->kod_as
          tmp->u_kod := hu->u_kod
        endif
        tmp->kol1 += &pole_kol
        tmp->trudoem += mtrud[3]
      endif
    case k == 5
      if hu->kod_vr == mkod_perso
        find ("1"+str(mkod_perso,4)+str(hu->u_kod,6))
        if !found()
          append blank
          tmp->vr_as := 1
          tmp->kod_vr_as := mkod_perso
          tmp->u_kod := hu->u_kod
        endif
        tmp->kol += &pole_kol
        tmp->trudoem += mtrud[2]
      endif
      if hu->kod_as == mkod_perso
        find (s1+str(mkod_perso,4)+str(hu->u_kod,6))
        if !found()
          append blank
          tmp->vr_as := k1
          tmp->kod_vr_as := mkod_perso
          tmp->u_kod := hu->u_kod
        endif
        tmp->kol1 += &pole_kol
        tmp->trudoem += mtrud[3]
      endif
    case k == 12  // все услуги
      select USL
      goto (hu->u_kod)
      if !eof()
        select TMP
        find (str(hu->u_kod,6))
        if !found()
          append blank
          tmp->u_kod := usl->kod
        endif
        tmp->kol += &pole_kol
        tmp->trudoem += mtrud[1]
      endif
  endcase
endif
return NIL

*

***** 30.08.16
Static Function obF4_statist(k, arr_otd, i, mkol, serv_arr, mkod_perso)
Local j, k1 := 1, s1 := "1", mtrud := {0,0,0}
if !_f_ist_fin()
  return NIL
endif
if ascan(ret_mz_rf,{|x| x[2] == human_->USL_OK }) == 0
  return NIL
endif
mtrud := _f_trud_F(hu->u_kod,mkol,human->vzros_reb,hu->kod_vr,hu->kod_as)
select TMP
do case
  case k == 1
    find (str(hu->otd,3))
    if !found()
      append blank
      tmp->otd := arr_otd[i,1]
      tmp->fio := arr_otd[i,2]
      if (j := ascan(st_a_uch, {|x| x[1] == arr_otd[i,3] } )) > 0
        tmp->u_kod := arr_otd[i,3]  // код ЛПУ
        tmp->fio := padr(arr_otd[i,2],31)+st_a_uch[j,2]
      endif
    endif
    tmp->kol += mkol
    tmp->trudoem += mtrud[1]
  case eq_any(k,2,7)
    if hu->kod_vr > 0
      find ("1"+str(hu->kod_vr,4))
      if !found()
        append blank
        tmp->vr_as := 1
        tmp->kod_vr_as := hu->kod_vr
      endif
      tmp->kol += mkol
      tmp->trudoem += mtrud[2]
    endif
    if hu->kod_as > 0
      find (s1+str(hu->kod_as,4))
      if !found()
        append blank
        tmp->vr_as := k1
        tmp->kod_vr_as := hu->kod_as
      endif
      tmp->kol1 += mkol
      tmp->trudoem += mtrud[3]
    endif
  case eq_any(k,3,6)
    find (str(hu->u_kod,6))
    if !found()
      append blank
      tmp->u_kod := hu->u_kod
    endif
    tmp->kol += mkol
    tmp->trudoem += mtrud[1]
  case k == 4
    if hu->kod_vr > 0
      find ("1"+str(hu->kod_vr,4)+str(hu->u_kod,6))
      if !found()
        append blank
        tmp->vr_as := 1
        tmp->kod_vr_as := hu->kod_vr
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += mkol
      tmp->trudoem += mtrud[2]
    endif
    if hu->kod_as > 0
      find (s1+str(hu->kod_as,4)+str(hu->u_kod,6))
      if !found()
        append blank
        tmp->vr_as := k1
        tmp->kod_vr_as := hu->kod_as
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol1 += mkol
      tmp->trudoem += mtrud[3]
    endif
  case k == 5
    if hu->kod_vr == mkod_perso
      find ("1"+str(mkod_perso,4)+str(hu->u_kod,6))
      if !found()
        append blank
        tmp->vr_as := 1
        tmp->kod_vr_as := mkod_perso
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += mkol
      tmp->trudoem += mtrud[2]
    endif
    if hu->kod_as == mkod_perso
      find (s1+str(mkod_perso,4)+str(hu->u_kod,6))
      if !found()
        append blank
        tmp->vr_as := k1
        tmp->kod_vr_as := mkod_perso
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol1 += mkol
      tmp->trudoem += mtrud[3]
    endif
  case k == 12  // все услуги
    select USL
    goto (hu->u_kod)
    if !eof()
      select TMP
      find (str(hu->u_kod,6))
      if !found()
        append blank
        tmp->u_kod := usl->kod
      endif
      tmp->kol += mkol
      tmp->trudoem += mtrud[1]
    endif
endcase
return NIL

*

***** 30.08.16
Static Function obF5_statist(k, arr_otd, serv_arr, mkol)
if !_f_ist_fin()
  return NIL
endif
if ascan(ret_mz_rf,{|x| x[2] == human_->USL_OK }) == 0
  return NIL
endif
if arr_otd != NIL .and. ascan(arr_otd, {|x| hu->otd==x[1]}) == 0
  return NIL
endif
select TMP
if eq_any(k,13,14)
  find (str(hu->u_kod,6)+str(human->kod,7))
else
  find (str(human->kod,7))
endif
if !found()
  append blank
  if eq_any(k,13,14)
    tmp->u_kod := hu->u_kod
  endif
  tmp->kod := human->kod
  tmp->fio := fam_i_o(human->fio)
  tmp->k_data := human->k_data
endif
DEFAULT mkol TO &pole_kol
tmp->kol += mkol
return NIL

***** 27.03.18
Function obF2_v_usl(is_get,r1,mtitul,name_tmp)
Local t_arr[BR_LEN], buf := savescreen(), k, ret
DEFAULT is_get TO .f., r1 TO T_ROW, name_tmp TO "tmp"
if r1 > 14 ; r1 := 14 ; endif
R_Use(dir_server+"mo_su",{dir_server+"mo_sush",;
                          dir_server+"mo_sush1"},"USL")
use (cur_dir+name_tmp) index (cur_dir+name_tmp+"k"),(cur_dir+name_tmp+"n") new alias TMP
set order to 2
t_arr[BR_TOP] := r1
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := mtitul
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_OPEN] := {|| !eof() }
t_arr[BR_ARR_BROWSE] := {"═","░","═",,.t.}
t_arr[BR_COLUMN] := {{ padc("Шифр",20), {|| tmp->u_shifr } },;
                     { center("Наименование услуги",57), {|| left(tmp->u_name,57) } } }
t_arr[BR_STAT_MSG] := {|| ;
  status_key("^<Esc>^ выход;  ^<Ins>^ добавление;  ^<Del>^ удаление услуги;  ^<F9>^ печать списка") }
t_arr[BR_EDIT] := {|nk,ob| obF21v_usl(nk,ob,"edit",mtitul) }
edit_browse(t_arr)
if is_get
  go top
  k := 0
  dbeval({|| iif(tmp->u_kod > 0, ++k, nil)})
  ret := {k,"Кол-во услуг - "+lstr(k)}
endif
tmp->(dbCloseArea())
usl->(dbCloseArea())
restscreen(buf)
if !is_get
  WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
endif
return ret

***** 12.03.14
Function obF21v_usl(nKey,oBrow,regim,mtitul)
Local ret := -1, s
Local buf, fl := .f., rec, rec1, k := 19, tmp_color, n_file, sh := 81, HH := 60
do case
  case regim == "edit"
    do case
      case nKey == K_F9
        DEFAULT mtitul TO "Список выбранных услуг"
        buf := save_row(maxrow())
        mywait()
        rec := recno()
        Private reg_print := 2
        n_file := "obF2v_us"+stxt
        fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
        add_string("")
        add_string(center(mtitul,sh))
        add_string("")
        go top
        do while !eof()
          verify_FF(HH, .t., sh)
          add_string(rtrim(tmp->u_shifr)+" "+alltrim(tmp->u_name))
          skip
        enddo
        goto (rec)
        fclose(fp)
        rest_box(buf)
        viewtext(n_file,,,,(.t.),,,reg_print)
      case nKey == K_INS
        save screen to buf
        Private mshifr := space(20)
        tmp_color := setcolor(cDataCScr)
        box_shadow(k,pc1+1,21,pc2-1,,"Добавление услуги",cDataPgDn)
        setcolor(cDataCGet)
        @ k+1,pc1+25 say "Шифр услуги" get mshifr picture "@!" valid valid_shifr()
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. !empty(mshifr)
          if "*" == alltrim(mshifr)
            func_error(4,'Воспользуйтесь режимом "Все услуги"!')
          elseif "*" $ mshifr .or. "?" $ mshifr
            mshifr := alltrim(mshifr)
            mywait()
            select USL
            set order to 1
            go top
            do while !eof()
              if like(mshifr,usl->shifr) .or. like(mshifr,usl->shifr1)
                select TMP
                set order to 1
                fl_found := fl := .t.
                AddRec(6)
                ret := 0
                s := iif(empty(usl->shifr), "", "("+alltrim(usl->shifr)+") ")
                replace tmp->u_shifr with usl->shifr1,;
                        tmp->u_name with s+usl->name,;
                        tmp->u_kod with usl->kod
              endif
              select USL
              skip
            enddo
            select TMP
            set order to 2
            if fl
              oBrow:goTop()
            else
              func_error(4,"Не найдено услуг по шаблону <"+mshifr+">.")
            endif
          else
            fl := .f.
            select USL
            if len(alltrim(mshifr)) <= 10
              set order to 1
              find (padr(mshifr,10))
              fl := found()
            endif
            if !fl
              set order to 2
              find (padr(mshifr,20))
              fl := found()
            endif
            select TMP
            if fl
              set order to 1
              fl_found := .t.
              AddRec(6)
              rec := recno()
              s := iif(empty(usl->shifr), "", "("+alltrim(usl->shifr)+") ")
              replace tmp->u_shifr with usl->shifr1,;
                      tmp->u_name with s+usl->name,;
                      tmp->u_kod with usl->kod
              set order to 2
              oBrow:goTop()
              goto (rec)
              ret := 0
            else
              func_error(4,"Услуги с данным шифром нет в справочнике!")
            endif
          endif
        endif
        if !fl_found
          ret := 1
        endif
        setcolor(tmp_color)
        restore screen from buf
      case nKey == K_DEL .and. !empty(tmp->u_kod)
        rec1 := 0
        rec := recno()
        skip
        if !eof()
          rec1 := recno()
        endif
        goto (rec)
        DeleteRec()
        if rec1 == 0
          oBrow:goBottom()
        else
          goto (rec1)
        endif
        ret := 0
        if eof()
          ret := 1
        endif
    endcase
endcase
return ret

***** 16.05.18
Function input_Fusluga()
Local ar, musl, arr_usl, buf, fl, s
ar := GetIniSect(tmp_ini,"Fuslugi")
musl := padr(a2default(ar,"shifr"),20)
if (musl := input_value(18,6,20,73,color1,;
            space(13)+"Введите шифр услуги",musl,"@K@!")) != NIL .and. !empty(musl)
  buf := save_maxrow()
  mywait()
  musl := transform_shifr(musl)
  SetIniSect(tmp_ini,"Fuslugi",{{"shifr",musl}})
  R_Use(dir_server+"mo_su",{dir_server+"mo_sush",;
                            dir_server+"mo_sush1"},"USL")
  fl := .f.
  select USL
  if len(alltrim(musl)) <= 10
    set order to 1
    find (padr(musl,10))
    fl := found()
  endif
  if !fl
    set order to 2
    find (padr(musl,20))
    fl := found()
  endif
  if fl
    s := iif(empty(usl->shifr), "", "("+alltrim(usl->shifr)+") ")
    R_Use(exe_dir+"_mo8uslf",cur_dir+"_mo8uslf","luslf")
    find (usl->shifr1)
    arr_usl := {usl->kod,alltrim(usl->shifr1)+". "+s+alltrim(luslf->name),usl->shifr1}
    luslf->(dbCloseArea())
  else
    func_error(4,"Услуга с шифром "+alltrim(musl)+" не найдена в нашем справочнике!")
  endif
  usl->(dbCloseArea())
  rest_box(buf)
endif
return arr_usl
