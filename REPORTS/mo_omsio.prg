// mo_omsio.prg - информация по ОМС (объём работ)
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static lcount_uch := 1
Static lcount_otd := 1

//
Function func_pi_schet(fl, al)
  
  DEFAULT fl TO .t., al TO 'human'
  if fl .and. pi_schet > 1
    if pi_schet == 2
      fl := &al.->schet > 0
    elseif pi_schet == 3
      fl := &al.->schet <= 0
    endif
  endif
  return fl

//
Function str_pi_schet()
  Local s := '[ по дате окончания лечения'

  if pi_schet == 2
    s += ', попавшие в счета'
  elseif pi_schet == 3
    s += ', не попавшие в счета'
  endif
  s += ' ]'
  return s

// 13.03.14
Function ob2_statist(k, serv_arr)
Local i, j, arr[2], begin_date, end_date, bk := 1, ek := 99, al, ;
      fl_exit := .f., sh := 80, HH := 57, regim := 2, s, fl_1_list := .t., ;
      len_n, pkol, ptrud, pstoim, old_perso, old_vr_as, old_usl, ;
      old_fio, arr_otd := {}, md, mkol, mstoim, arr_kd := {}, len_kd := 0, ;
      xx, yy, pole_va, lrec, t_date1, t_date2, arr_title, msum, msum_opl, ;
      musluga, mperso := {}, mkod_perso, arr_usl := {}, adbf1, adbf2, ;
      arr_svod_nom := {}, arr_m, lshifr1
Private is_all := .t.
Private skol := {0, 0}, strud := {0, 0}, sstoim := {0, 0}
if eq_any(k, 2, 3, 4, 8, 9, 110, 111)  // по отделению
  if (st_a_otd := inputN_otd(T_ROW, T_COL - 5, .f., .f., ,@lcount_otd)) == NIL
    return NIL
  endif
  aeval(st_a_otd, {|x| aadd(arr_otd,x) })
  if k == 8 .and. (musluga := input_usluga()) == NIL
    return NIL
  endif
  if k == 9 .and. !input_perso(T_ROW, T_COL - 5, .f.)
    return NIL
  endif
else  // по учреждению(ям)
  if (st_a_uch := inputN_uch(T_ROW, T_COL - 5, , ,@lcount_uch)) == NIL
    return NIL
  endif
  R_Use(dir_server + 'mo_otd', ,'OTD')
  dbeval({|| aadd(arr_otd,{otd->(recno()),otd->name,otd->kod_lpu}) }, ;
         {|| f_is_uch(st_a_uch,otd->kod_lpu)} )
  OTD->(dbCloseArea())
  if ((k==5.and.serv_arr==NIL) .or. k==13) .and. !input_perso(T_ROW, T_COL - 5, .f.)
    return NIL
  endif
endif
//
if eq_any(k, 3, 31, 4, 13)
  if (xx := popup_prompt(T_ROW, T_COL - 5, 1,{'Все ~услуги','~Список услуг'})) == 0
    return NIL
  endif
  is_all := (xx == 1)
endif
//
Private fl_plan := .f., fl7_plan := .f., fl5_plan := .f., ym_kol_mes := 1
arr_m := {year(sys_date),month(sys_date), , ,sys_date,sys_date, ,}
if pi1 != 4
  if (arr := year_month()) == NIL
    return NIL
  endif
  begin_date := arr[7]
  end_date := arr[8]
  arr_m := aclone(arr)
endif
if mem_trudoem == 2 .and. mem_tr_plan == 2 .and. eq_any(k, 5, 7) .and. ym_kol_mes > 0
  fl_plan := .t.
  if k == 5
    fl5_plan := .t.
  endif
  if k == 7
    fl7_plan := .t.
  endif
endif
if k == 5 .and. serv_arr != NIL
  if serv_arr[1] == 1  // N человек
    if (mperso := input_kperso()) == NIL
      return NIL
    endif
  elseif serv_arr[1] == 2  // весь персонал
    mywait()
    mperso := {}
    R_Use(dir_server + 'human_u',{dir_server + 'human_uv', ;
                                dir_server + 'human_ua'},'HU')
    R_Use(dir_server + 'mo_pers', ,'P2')
    go top
    do while !eof()
      if p2->kod > 0
        fl := .f.
        select HU
        set order to 1
        find (str(p2->kod, 4))
        if !(fl := found())
          set order to 2
          find (str(p2->kod, 4))
          fl := found()
        endif
        if fl
          aadd(mperso, {p2->kod,''} )
        endif
      endif
      select P2
      skip
    enddo
    hu->(dbCloseArea())
    p2->(dbCloseArea())
  endif
endif
if !fbp_ist_fin(T_ROW, T_COL - 5)
  return NIL
endif
adbf1 := { ;
     {'U_KOD'  ,    'N',      4,      0}, ;  // код услуги
     {'U_SHIFR',    'C',     10,      0}, ;  // шифр услуги
     {'U_NAME',     'C',    255,      0}, ;  // наименование услуги
     {'FIO',        'C',     25,      0}, ;  // ФИО больного
     {'KOD',        'N',      7,      0}, ;  // код больного
     {'K_DATA',     'D',      8,      0}, ;  // дата окончания лечения
     {'KOL'    ,    'N',      5,      0}, ;  // количество услуг
     {'STOIM',      'N',     20,      4};   // стоимость услуг
    }
adbf2 := { ;
     {'otd',        'N',      3,      0}, ;  // отделение, где оказана услуга
     {'U_KOD'  ,    'N',      4,      0}, ;  // код услуги
     {'U_SHIFR',    'C',     10,      0}, ;  // шифр услуги
     {'U_NAME',     'C',    255,      0}, ;  // наименование услуги
     {'VR_AS',      'N',      1,      0}, ;  // врач - 1 ; ассистент - 2
     {'TAB_NOM',    'N',      5,      0}, ;  // таб.номер врача (ассистента)
     {'SVOD_NOM',   'N',      5,      0}, ;  // сводный таб.номер
     {'KOD_VR_AS',  'N',      4,      0}, ;  // код врача (ассистента)
     {'FIO',        'C',     60,      0}, ;  // Ф.И.О. врача (ассистента)
     {'KOD_AS' ,    'N',      4,      0}, ;  // код ассистента
     {'TRUDOEM',    'N',     13,      4}, ;  // трудоемкость услуг УЕТ
     {'KOL'    ,    'N',      6,      0}, ;  // количество услуг
     {'STOIM'  ,    'N',     16,      4};   // итоговая стоимость услуги
    }
if !is_all
  dbcreate(cur_dir + 'tmp', adbf2)
  use (cur_dir + 'tmp') new
  index on str(u_kod, 4) to (cur_dir + 'tmpk')
  index on fsort_usl(u_shifr) to (cur_dir + 'tmpn')
  close databases
  ob2_v_usl()
  use (cur_dir + 'tmp') new
  dbeval({|| aadd(arr_usl,tmp->u_kod) } )
  use
  if len(arr_usl) == 0
    return NIL
  endif
endif
if eq_any(k, 8, 9, 13, 14)  // вывод списка больных
  dbcreate(cur_dir + 'tmp', adbf1)
else
  dbcreate(cur_dir + 'tmp', adbf2)
endif
WaitStatus('<Esc> - прервать поиск') ; mark_keys({'<Esc>'})
use (cur_dir + 'tmp')
do case
  case k == 0  // Количество услуг и сумма лечения по службам (с разбивкой по отделениям)
    index on str(kod_vr_as, 4)+str(otd, 3) to (cur_dir + 'tmpk')
    index on str(kod_vr_as, 4)+str(u_kod, 4)+upper(left(u_name, 20)) to (cur_dir + 'tmpn')
  case k == 100  // Количество услуг и сумма лечения по отделениям (с разбивкой по службам)
    index on str(kod_vr_as, 4)+str(otd, 3) to (cur_dir + 'tmpk')
    index on str(u_kod, 4)+str(otd, 3)+upper(left(u_name, 20)) to (cur_dir + 'tmpn')
  case k == 1  // Количество услуг и сумма лечения по отделениям
    index on str(otd, 3) to (cur_dir + 'tmpk')
    index on str(u_kod, 4)+upper(fio) to (cur_dir + 'tmpn')
  case k == 2  // Статистика по работе персонала в конкретном отделении
    index on str(vr_as, 1)+str(kod_vr_as, 4) to (cur_dir + 'tmpk')
    index on upper(left(fio, 30))+str(kod_vr_as, 4)+str(vr_as, 1) to (cur_dir + 'tmpn')
  case k == 3  // Статистика по услугам, оказанным в конкретном отделении
    index on str(u_kod, 4) to (cur_dir + 'tmpk')
    index on fsort_usl(u_shifr) to (cur_dir + 'tmpn')
  case k == 31  // Статистика по услугам, оказанным в конкретных отделениях
    index on str(otd, 3)+str(u_kod, 4) to (cur_dir + 'tmpk')
    index on upper(fio)+str(otd, 3)+fsort_usl(u_shifr) to (cur_dir + 'tmpn')
  case k == 4  // Статистика по работе персонала (плюс оказанные услуги) в конкретном отделении
    index on str(vr_as, 1)+str(kod_vr_as, 4)+str(u_kod, 4) to (cur_dir + 'tmpk')
    index on upper(left(fio, 30))+str(kod_vr_as, 4)+str(vr_as, 1)+fsort_usl(u_shifr) to (cur_dir + 'tmpn')
  case k == 5  // Статистика по работе конкретного человека (плюс оказанные услуги)
    index on str(vr_as, 1)+str(kod_vr_as, 4)+str(u_kod, 4) to (cur_dir + 'tmpk')
    if serv_arr == NIL
      index on str(vr_as, 1)+fsort_usl(u_shifr) to (cur_dir + 'tmpn')
    else
      index on upper(left(fio, 30))+str(kod_vr_as, 4)+str(vr_as, 1)+fsort_usl(u_shifr) to (cur_dir + 'tmpn')
    endif
  case k == 6  // Статистика по конкретным услугам
    index on str(u_kod, 4) to (cur_dir + 'tmpk')
    index on fsort_usl(u_shifr) to (cur_dir + 'tmpn')
    close databases
    ob2_v_usl()
  case k == 7  // Статистика по работе всего персонала
    index on str(vr_as, 1)+str(kod_vr_as, 4) to (cur_dir + 'tmpk')
    index on upper(left(fio, 30))+str(kod_vr_as, 4)+str(vr_as, 1) to (cur_dir + 'tmpn')
  case eq_any(k, 8, 9)  // вывод списка больных
    index on str(kod, 7) to (cur_dir + 'tmpk')
    index on dtos(k_data)+upper(left(fio, 30)) to (cur_dir + 'tmpn')
  case eq_any(k, 10, 110) // Статистика по услугам по всем службам
    index on str(u_kod, 4) to (cur_dir + 'tmpk')
    index on str(kod_vr_as, 4)+fsort_usl(u_shifr) to (cur_dir + 'tmpn')
  case eq_any(k, 11, 111) // Статистика по услугам конкретной службы
    index on str(u_kod, 4) to (cur_dir + 'tmpk')
    index on fsort_usl(u_shifr) to (cur_dir + 'tmpn')
  case k == 12 // Статистика по всем услугам
    index on str(u_kod, 4) to (cur_dir + 'tmpk')
    index on fsort_usl(u_shifr) to (cur_dir + 'tmpn')
  case k == 13  // вывод услуг + списка больных
    index on str(u_kod, 4)+str(kod, 7) to (cur_dir + 'tmpk')
    index on fsort_usl(u_shifr)+str(u_kod, 4)+dtos(k_data)+upper(left(fio, 30)) to (cur_dir + 'tmpn')
  case k == 14  // Статистика по конкретным услугам + список больных
    index on str(u_kod, 4)+str(kod, 7) to (cur_dir + 'tmpk')
    index on fsort_usl(u_shifr)+str(u_kod, 4)+dtos(k_data)+upper(left(fio, 30)) to (cur_dir + 'tmpn')
    close databases
    ob2_v_usl()
endcase
use (cur_dir + 'tmp') index (cur_dir + 'tmpk'),(cur_dir + 'tmpn') alias TMP
if mem_trudoem == 2
  useUch_Usl()
endif
if hb_fileExists(dir_server + 'usl_del'+sdbf)
  R_Use(dir_server + 'usl_del', ,'UD')
  index on str(kod, 4) to (cur_dir + 'tmp_ud')
endif
R_Use(dir_server + 'uslugi', ,'USL')
Private is_1_usluga := (len(arr_usl) == 1)
if psz == 2 .and. eq_any(is_oplata, 5, 6, 7)
  open_opl_5()
  if is_oplata == 7
    cre_tmp7()
  endif
endif
R_Use(dir_server + 'mo_pers', ,'PERSO')
if eq_any(k, 5, 9, 13)  // Статистика по работе конкретного человека
  if serv_arr == NIL
    mperso := {glob_human}
  endif
  if pi1 == 4  // по невыписанным счетам
    pole_kol := 'hu->kol_1'
    pole_stoim := 'hu->stoim_1'
    R_Use(dir_server + 'human_u', dir_server + 'human_u','HU')
    R_Use(dir_server + 'human_', ,'HUMAN_')
    R_Use(dir_server + 'human', dir_server + 'humann','HUMAN')
    set relation to recno() into HUMAN_
    dbseek('1', .t.)
    do while human->tip_h < B_SCHET .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select HU
      find (str(human->kod, 7))
      do while hu->kod == human->kod .and. !eof()
        if iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
          mkod_perso := 0
          if hu->kod_vr > 0 .and. ;
                    ascan(mperso, {|x| x[1] == hu->kod_vr } ) > 0
            mkod_perso := hu->kod_vr
          elseif hu->kod_as > 0 .and. ;
                    ascan(mperso, {|x| x[1] == hu->kod_as } ) > 0
            mkod_perso := hu->kod_as
          endif
          if mkod_perso > 0
            if k == 5
              ob3_statist(k, arr_otd, serv_arr, mkod_perso)
            elseif eq_any(k, 9, 13)
              ob5_statist(k, arr_otd, serv_arr)
            endif
          endif
        endif
        select HU
        skip
      enddo
      select HUMAN
      skip
    enddo
  else   // between(pi1, 1, 3)
    R_Use(dir_server + 'schet', ,'SCHET')
    R_Use(dir_server + 'human_', ,'HUMAN_')
    R_Use(dir_server + 'human', dir_server + 'humank','HUMAN')
    set relation to recno() into HUMAN_
    R_Use(dir_server + 'human_u',{dir_server + 'human_uv', ;
                                dir_server + 'human_ua', ;
                                dir_server + 'human_u'},'HU')
    for yy := 1 to len(mperso)
      mkod_perso := mperso[yy, 1]
      for xx := 1 to 2
        pole_va := {'hu->kod_vr','hu->kod_as'}[xx]
        select HU
        if xx == 1
          set order to 1
        elseif xx == 2
          set order to 2
        endif
        do case
          case pi1 == 1  // по дате оказания услуги
            pole_kol := 'hu->kol'
            pole_stoim := 'hu->stoim'
            select HU
            dbseek(str(mkod_perso, 4)+begin_date, .t.)
            do while &pole_va == mkod_perso .and. hu->date_u <= end_date .and. !eof()
              UpdateStatus()
              if inkey() == K_ESC
                fl_exit := .t. ; exit
              endif
              if iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
                human->(dbSeek(str(hu->kod, 7)))
                if human_->oplata < 9
                  if k == 5
                    ob3_statist(k, arr_otd, serv_arr, mkod_perso)
                  elseif eq_any(k, 9, 13) .and. ;
                        if(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
                    ob5_statist(k, arr_otd, serv_arr)
                  endif
                endif
              endif
              select HU
              skip
            enddo
          case between(pi1, 2, 3)  // по дате выписки счета и окончания лечения
            pole_kol := 'hu->kol_1'
            pole_stoim := 'hu->stoim_1'
            select HU
            dni_vr := max(366,mem_dni_vr) // отнимем min год
            dbseek(str(mkod_perso, 4)+dtoc4(arr[5]-dni_vr), .t.)
            do while &pole_va == mkod_perso .and. hu->date_u <= end_date .and. !eof()
              UpdateStatus()
              if inkey() == K_ESC
                fl_exit := .t. ; exit
              endif
              if iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
                select HUMAN
                find (str(hu->kod, 7))
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
                    ob3_statist(k, arr_otd, serv_arr, mkod_perso)
                  elseif eq_any(k, 9, 13)
                    ob5_statist(k, arr_otd, serv_arr)
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
elseif eq_any(k, 6, 8, 14)  // Статистика по конкретным(ой) услугам(е)
  if eq_any(k, 6, 14)
    select TMP  // в базе данных уже занесены необходимые нам услуги
                // переносим их в массив arr_usl
    dbeval({|| aadd(arr_usl,{tmp->u_kod,tmp->(recno())}) } )
    if k == 14
      zap
    endif
  elseif k == 8
    arr_usl := {{musluga[1], 0}}
  endif
  is_1_usluga := (len(arr_usl) == 1)
  if pi1 == 4  // по невыписанным счетам
    pole_kol := 'hu->kol_1'
    pole_stoim := 'hu->stoim_1'
    R_Use(dir_server + 'human_u', dir_server + 'human_u','HU')
    R_Use(dir_server + 'human_', ,'HUMAN_')
    R_Use(dir_server + 'human', dir_server + 'humann','HUMAN')
    set relation to recno() into HUMAN_
    dbseek('1', .t.)
    do while human->tip_h < B_SCHET .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select HU
      find (str(human->kod, 7))
      do while hu->kod == human->kod .and. !eof()
        if (i := ascan(arr_usl, {|x| x[1] == hu->u_kod } )) > 0
          if k == 6
            tmp->(dbGoto(arr_usl[i, 2]))
            lrec := tmp->(recno())
            ob3_statist(k, arr_otd, serv_arr)
          elseif eq_any(k, 8, 14)
            ob5_statist(k, arr_otd, serv_arr)
          endif
        endif
        select HU
        skip
      enddo
      select HUMAN
      skip
    enddo
  else   // between(pi1, 1, 3)
    t_date1 := dtoc4(arr[5]-180)
    t_date2 := dtoc4(arr[5]-1)
    R_Use(dir_server + 'schet', ,'SCHET')
    R_Use(dir_server + 'human_', ,'HUMAN_')
    R_Use(dir_server + 'human', dir_server + 'humank','HUMAN')
    set relation to recno() into HUMAN_
    R_Use(dir_server + 'human_u',{dir_server + 'human_uk', ;
                                dir_server + 'human_u'},'HU')
    for xx := 1 to len(arr_usl)
      if k == 6
        tmp->(dbGoto(arr_usl[xx, 2]))
        lrec := tmp->(recno())
      endif
      do case
        case pi1 == 1  // по дате оказания услуги
          pole_kol := 'hu->kol'
          pole_stoim := 'hu->stoim'
          select HU
          find (str(arr_usl[xx, 1], 4))
          do while hu->u_kod == arr_usl[xx, 1] .and. !eof()
            UpdateStatus()
            if inkey() == K_ESC
              fl_exit := .t. ; exit
            endif
            select HUMAN
            find (str(hu->kod, 7))
            if human_->oplata < 9 .and. between(hu->date_u,begin_date,end_date)
              if k == 6
                ob3_statist(k, arr_otd, serv_arr)
              elseif eq_any(k, 8, 14)
                ob5_statist(k, arr_otd, serv_arr)
              endif
            endif
            select HU
            skip
          enddo
        case between(pi1, 2, 3)  // по дате выписки счета и окончания лечения
          pole_kol := 'hu->kol_1'
          pole_stoim := 'hu->stoim_1'
          select HU
          find (str(arr_usl[xx, 1], 4))
          do while hu->u_kod == arr_usl[xx, 1] .and. !eof()
            UpdateStatus()
            if inkey() == K_ESC
              fl_exit := .t. ; exit
            endif
            select HUMAN
            find (str(hu->kod, 7))
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
                ob3_statist(k, arr_otd, serv_arr)
              elseif eq_any(k, 8, 14)
                ob5_statist(k, arr_otd, serv_arr)
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
      pole_kol := 'hu->kol'
      pole_stoim := 'hu->stoim'
      R_Use(dir_server + 'human_', ,'HUMAN_')
      R_Use(dir_server + 'human', ,'HUMAN')
      set relation to recno() into HUMAN_
      R_Use(dir_server + 'human_u', dir_server + 'human_ud','HU')
      set relation to kod into HUMAN
      select HU
      dbseek(begin_date, .t.)
      do while hu->date_u <= end_date .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if human_->oplata < 9 .and. iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
          ob3_statist(k, arr_otd, serv_arr)
        endif
        select HU
        skip
      enddo
      select HU
      set relation to
    case pi1 == 2  // по дате выписки счета
      pole_kol := 'hu->kol_1'
      pole_stoim := 'hu->stoim_1'
      R_Use(dir_server + 'human_u', dir_server + 'human_u','HU')
      R_Use(dir_server + 'human_', ,'HUMAN_')
      R_Use(dir_server + 'human', dir_server + 'humans','HUMAN')
      set relation to recno() into HUMAN_
      R_Use(dir_server + 'schet', dir_server + 'schetd','SCHET')
      set filter to !eq_any(mest_inog, 6, 7)
      dbseek(begin_date, .t.)
      do while schet->pdate <= end_date .and. !eof()
        select HUMAN
        find (str(schet->kod, 6))
        do while human->schet == schet->kod .and. !eof()
          UpdateStatus()
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          if human_->oplata < 9
            select HU
            find (str(human->kod, 7))
            do while hu->kod == human->kod .and. !eof()
              if iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
                ob3_statist(k, arr_otd, serv_arr)
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
      pole_kol := 'hu->kol_1'
      pole_stoim := 'hu->stoim_1'
      R_Use(dir_server + 'human_u', dir_server + 'human_u','HU')
      R_Use(dir_server + 'human_', ,'HUMAN_')
      R_Use(dir_server + 'human', dir_server + 'humand','HUMAN')
      set relation to recno() into HUMAN_
      dbseek(dtos(arr_m[5]), .t.)
      do while human->k_data <= arr_m[6] .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if human_->oplata < 9 .and. func_pi_schet(.t.)
          select HU
          find (str(human->kod, 7))
          do while hu->kod == human->kod .and. !eof()
            if iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
              ob3_statist(k, arr_otd, serv_arr)
            endif
            select HU
            skip
          enddo
        endif
        select HUMAN
        skip
      enddo
    case pi1 == 4  // по невыписанным счетам
      pole_kol := 'hu->kol_1'
      pole_stoim := 'hu->stoim_1'
      R_Use(dir_server + 'human_u', dir_server + 'human_u','HU')
      R_Use(dir_server + 'human_', ,'HUMAN_')
      R_Use(dir_server + 'human', dir_server + 'humann','HUMAN')
      set relation to recno() into HUMAN_
      dbseek('1', .t.)
      do while human->tip_h < B_SCHET .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        select HU
        find (str(human->kod, 7))
        do while hu->kod == human->kod .and. !eof()
          if iif(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
            ob3_statist(k, arr_otd, serv_arr)
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
  func_error(4, 'Нет сведений!')
else
  mywait()
  if eq_any(k, 8, 9, 13, 14)
    arr_title := { ;
'─────────────────────────┬─────┬──────────┬────────╥───────────────┬────────╥──────────', ;
'                         │ Кол.│Стоимость │  Дата  ║               │  Дата  ║          ', ;
'         Ф.И.О.          │услуг│оказ.услуг│окон.леч║  Номер счета  │  счета ║Примечание', ;
'─────────────────────────┴─────┴──────────┴────────╨───────────────┴────────╨──────────'}
    R_Use(dir_server + 'human_', ,'HUMAN_')
    R_Use(dir_server + 'human', dir_server + 'humank','HUMAN')
    set relation to recno() into HUMAN_
    R_Use(dir_server + 'schet_', ,'SCHET_')
    R_Use(dir_server + 'schet', ,'SCHET')
    set relation to recno() into SCHET_
 else
    len_n := 58
    if mem_trudoem == 2
      len_n := 49
    endif
    arr_title := array(4)
    arr_title[1] := replicate('─',len_n)
    arr_title[2] := space(len_n)
    arr_title[3] := space(len_n)
    arr_title[4] := replicate('─',len_n)
    if !fl7_plan
      arr_title[1] += '┬──────'
      arr_title[2] += '│Кол-во'
      arr_title[3] += '│ услуг'
      arr_title[4] += '┴──────'
    endif
    if mem_trudoem == 2
      arr_title[1] += '┬────────'
      arr_title[2] += '│        '
      arr_title[3] += '│ У.Е.Т. '
      arr_title[4] += '┴────────'
    endif
    if fl7_plan
      arr_title[1] += '┬──────'
      arr_title[2] += '│  %%  '
      arr_title[3] += '│выпол.'
      arr_title[4] += '┴──────'
    endif
    arr_title[1] += '┬──────────────'
    arr_title[2] += '│'+padc(if(psz==1,'Стоимость','Заработная'), 14)
    arr_title[3] += '│'+padc(if(psz==1,'услуг','плата'), 14)
    arr_title[4] += '┴──────────────'
  endif
  sh := len(arr_title[1])
  SET(_SET_DELETED, .F.)
  use (cur_dir + 'tmp') index (cur_dir + 'tmpk'),(cur_dir + 'tmpn') NEW alias TMP
  if !eq_any(k, 1, 8, 9)
    if eq_any(k, 0, 10, 100, 110)
      R_Use(dir_server + 'slugba', dir_server + 'slugba','SL')
    endif
    if eq_any(k, 3, 31, 4, 5, 6, 10, 11, 12, 13, 14, 110, 111)
      use_base('lusl')
      R_Use(dir_server + 'uslugi', ,'USL')
    endif
    R_Use(dir_server + 'mo_pers', ,'PERSO')
    select TMP
    set order to 0
    go top
    do while !eof()
      if eq_any(k, 0, 10, 100, 110)
        select SL
        find (str(tmp->kod_vr_as, 3))
        if found() .and. !deleted()
          if k == 100
            tmp->u_name := str(sl->shifr, 3)+'. '+sl->name
          else
            tmp->fio := str(sl->shifr, 3)+'. '+sl->name
          endif
        else
          select TMP
          DELETE
        endif
      endif
      if eq_any(k, 3, 31, 4, 5, 6, 10, 11, 12, 13, 14, 110, 111)
        select USL
        goto (tmp->u_kod)
        if usl->kod <= 0 .or. deleted() .or. eof()
          select TMP
          DELETE
        else
          tmp->u_shifr := usl->shifr
          s := ''
          if !empty(lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod,arr_m[6])) .and. !(usl->shifr==lshifr1)
            s += '(' + alltrim(lshifr1)+')'
          endif
          if empty(lshifr1) .or. lshifr1 == usl->shifr
            select LUSL
            find (usl->shifr)
            if found()
              tmp->u_name := s+lusl->name
            else
              tmp->u_name := s+usl->name
            endif
          else
            tmp->u_name := s+usl->name
          endif
        endif
      endif
      if eq_any(k, 2, 4, 5, 7)
        select PERSO
        goto (tmp->kod_vr_as)
        if deleted() .or. eof()
          select TMP
          DELETE
        else
          tmp->fio := perso->fio
          tmp->tab_nom := perso->tab_nom
          tmp->svod_nom := perso->svod_nom
          if k == 7 .and. !fl7_plan ;
                    .and. !empty(perso->tab_nom) ;
                    .and. !empty(perso->svod_nom)
            if (i := ascan(arr_svod_nom, ;
                 {|x| x[1] == perso->svod_nom .and. x[2] == tmp->vr_as})) == 0
              aadd(arr_svod_nom, {perso->svod_nom,tmp->vr_as,{}} )
              i := len(arr_svod_nom)
            endif
            aadd(arr_svod_nom[i, 3], tmp->(recno()) )
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
        pkol := ptrud := pstoim := 0
        for j := 2 to len(arr_svod_nom[i, 3])
          goto (arr_svod_nom[i, 3,j])
          ptrud  += tmp->TRUDOEM
          pkol   += tmp->KOL
          pstoim += tmp->STOIM
          DELETE
        next
        goto (arr_svod_nom[i, 3, 1])
        tmp->TRUDOEM += ptrud
        tmp->KOL     += pkol
        tmp->STOIM   += pstoim
      next
    endif
  endif
  SET(_SET_DELETED, .T.)
  fp := fcreate('ob_stat' + stxt) ; tek_stroke := 0 ; n_list := 1
  add_string(padl('дата печати ' + date_8(sys_date), sh))
  if k == 0
    ob6_statist()
    add_string(center('Статистика по службам (с разбивкой по отделениям)', sh))
    titleN_uch(st_a_uch, sh,lcount_uch)
  elseif k == 100
    ob7_statist()
    add_string(center('Статистика по отделениям (с разбивкой по службам)', sh))
    titleN_uch(st_a_uch, sh,lcount_uch)
  elseif k == 1
    add_string(center('Статистика по отделениям', sh))
    titleN_uch(st_a_uch, sh,lcount_uch)
  elseif k == 5
    add_string(center('Статистика по оказанным услугам', sh))
    titleN_uch(st_a_uch, sh,lcount_uch)
    if serv_arr == NIL  // по одному человеку
      add_string(center('"' + upper(glob_human[2]) + ;
                        ' [' + lstr(glob_human[5]) + ']"', sh))
    endif
  elseif eq_any(k, 6, 14)
    add_string(center('Статистика по услугам', sh))
    titleN_uch(st_a_uch, sh,lcount_uch)
  elseif k == 7
    add_string(center('Статистика по работе персонала', sh))
    titleN_uch(st_a_uch, sh,lcount_uch)
  elseif eq_any(k, 10, 110)
    add_string(center('Статистика по услугам (с объединением по службам)', sh))
    if k == 10
      titleN_uch(st_a_uch, sh,lcount_uch)
    else
      titleN_otd(st_a_otd, sh,lcount_otd)
      add_string(center('< ' + alltrim(glob_uch[2])+' >', sh))
    endif
  elseif eq_any(k, 11, 111)
    add_string(center('Статистика по службе', sh))
    add_string(center(serv_arr[2], sh))
    if k == 11
      titleN_uch(st_a_uch, sh,lcount_uch)
    else
      titleN_otd(st_a_otd, sh,lcount_otd)
      add_string(center('< ' + alltrim(glob_uch[2])+' >', sh))
    endif
  elseif k == 12
    add_string(center('Статистика по всем оказанным услугам', sh))
    titleN_uch(st_a_uch, sh,lcount_uch)
  elseif k == 13
    add_string(center('Список больных, которым были оказаны услуги врачом (ассистентом):', sh))
    add_string(center('"' + upper(glob_human[2]) + ;
                      ' [' + lstr(glob_human[5]) + ']"', sh))
    titleN_uch(st_a_uch, sh,lcount_uch)
  else
    add_string(center('Статистика по отделению', sh))
    titleN_otd(st_a_otd, sh,lcount_otd)
    add_string(center('< ' + alltrim(glob_uch[2])+' >', sh))
    if eq_any(k, 8, 9)
      add_string('')
      if k == 8
        add_string(center('Список больных, которым была оказана услуга:', sh))
        add_string(center('"' + musluga[2] + '"', sh))
      else
        add_string(center('Список больных, которым были оказаны услуги врачом (ассистентом):', sh))
        add_string(center('"' + upper(glob_human[2]) + ;
                          ' [' + lstr(glob_human[5]) + ']"', sh))
      endif
    endif
  endif
  add_string('')
  _tit_ist_fin(sh)
  if pi1 != 4
    add_string(center(arr[4], sh))
    add_string('')
  endif
  do case
    case pi1 == 1
      s := '[ по дате оказания услуги ]'
    case pi1 == 2
      s := '[ по дате выписки счета ]'
    case pi1 == 3
      s := str_pi_schet()
    case pi1 == 4
      s := '[ по больным, еще не включенным в счет ]'
  endcase
  add_string(center(s, sh))
  add_string('')
  if fl_plan
    R_Use(dir_server + 'uch_pers', dir_server + 'uch_pers','UCHP')
  endif
  select TMP
  set order to 2
  go top
  if eq_any(k, 8, 9, 13, 14)
    mb := mkol := msum := old_usl := 0
    aeval(arr_title, {|x| add_string(x) } )
    do while !eof()
      if verify_FF(HH, .t., sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      if eq_any(k, 13, 14) .and. tmp->u_kod != old_usl
        if old_usl > 0
          add_string(replicate('─', sh))
          add_string(padr('Кол-во больных - ' + lstr(mb), 28)+ ;
                     padl(expand_value(msum, 2), 13)+' руб.')
          add_string(padl('Кол-во услуг - ' + lstr(mkol), 30))
          mb := mkol := msum := 0
        endif
        add_string('')
        for i := 1 to perenos(arr,rtrim(tmp->u_shifr)+'. '+tmp->u_name, sh-2)
          add_string('│ '+arr[i])
        next
        add_string('└'+replicate('─', sh-1))
      endif
      old_usl := tmp->u_kod
      select HUMAN
      find (str(tmp->kod, 7))
      select SCHET
      goto (human->schet)
      s := tmp->fio+ ;
           put_val(tmp->kol, 5)+ ;
           put_kopE(tmp->stoim, 11)+'  '+ ;
           date_8(tmp->k_data)
      if human->tip_h >= B_SCHET
        s += padc(alltrim(schet_->nschet), 17) + date_8(c4tod(schet->pdate))
      endif
      add_string(s)
      mkol += tmp->kol ; msum += tmp->stoim ; ++mb
      select TMP
      skip
    enddo
    add_string(replicate('─', sh))
    add_string(padr('Кол-во больных - ' + lstr(mb), 28)+ ;
               padl(expand_value(msum, 2), 13)+' руб.')
    add_string(padl('Кол-во услуг - ' + lstr(mkol), 30))
  else
    pkol := ptrud := pstoim := 0
    old_perso := tmp->kod_vr_as ; old_vr_as := tmp->vr_as
    old_fio := '['+put_tab_nom(tmp->tab_nom,tmp->svod_nom)+'] '
    old_fio += tmp->fio
    old_slugba := tmp->fio
    old_shifr := iif(eq_any(k, 31, 100), tmp->otd, tmp->kod_vr_as)
    if eq_any(k, 2, 5, 7)
      old_perso := -1  // для печати Ф.И.О. в начале
    endif
    select TMP
    do while !eof()
      if eq_any(k, 0, 10, 31, 100, 110) .and. ;
              old_shifr != iif(eq_any(k, 31, 100), tmp->otd, tmp->kod_vr_as)
        add_string(space(4)+replicate('.', sh-4))
        add_string(padr(space(4)+old_slugba,len_n)+ ;
                   put_val(pkol, 7, 0)+ ;
                   if(mem_trudoem==2,umest_val(ptrud, 9, 2),'')+ ;
                   put_kopE(pstoim, 15))
        add_string(replicate('─', sh))
        pkol := ptrud := pstoim := 0
      endif
      if k == 4 .and. !(old_perso == tmp->kod_vr_as .and. old_vr_as == tmp->vr_as)
        add_string(space(4)+replicate('.', sh-4))
        add_string(padr(space(4)+old_fio,len_n-4)+ ;
                   if(psz==1,if(old_vr_as==1,'врач','асс.'),space(4))+ ;
                   put_val(pkol, 7, 0)+ ;
                   if(mem_trudoem==2,umest_val(ptrud, 9, 2),'')+ ;
                   put_kopE(pstoim, 15))
        add_string(replicate('─', sh))
        pkol := ptrud := pstoim := 0
      endif
      if fl_1_list .or. verify_FF(HH, .t., sh)
        aeval(arr_title, {|x| add_string(x) } )
        fl_1_list := .f.
      endif
      if k == 4
        pkol += tmp->kol
        ptrud += tmp->trudoem
        pstoim += tmp->stoim
        skol[tmp->vr_as] += tmp->kol
        strud[tmp->vr_as] += tmp->trudoem
        sstoim[tmp->vr_as] += tmp->stoim
        j := perenos(arr,tmp->u_shifr+' '+tmp->u_name,len_n)
        add_string(padr(arr[1],len_n)+ ;
                   put_val(tmp->kol, 7, 0)+ ;
                   if(mem_trudoem==2,umest_val(tmp->trudoem, 9, 2),'')+ ;
                   put_kopE(tmp->stoim, 15))
        for i := 2 to j
          add_string(space(11)+arr[i])
        next
        old_perso := tmp->kod_vr_as
        old_vr_as := tmp->vr_as
        old_fio := '['+put_tab_nom(tmp->tab_nom,tmp->svod_nom)+'] '
        old_fio += tmp->fio
      else
        do case
          case eq_any(k, 0, 31, 100)
            s := padr(tmp->u_name,len_n-7)+left(tmp->u_shifr, 7)
            skol[1] += tmp->kol
            strud[1] += tmp->trudoem
            sstoim[1] += tmp->stoim
            pkol += tmp->kol
            ptrud += tmp->trudoem
            pstoim += tmp->stoim
            if k == 0
              old_slugba := tmp->fio ; old_shifr := tmp->kod_vr_as
            elseif eq_any(k, 31, 100)
              old_slugba := tmp->fio ; old_shifr := tmp->otd
              j := perenos(arr,tmp->u_shifr+' '+tmp->u_name,len_n)
              s := padr(arr[1],len_n)
            endif
          case k == 1
            s := padr(tmp->fio,len_n)
            skol[1] += tmp->kol
            strud[1] += tmp->trudoem
            sstoim[1] += tmp->stoim
          case eq_any(k, 2, 7)
            if empty(tmp->u_shifr)
              s := '['+put_tab_nom(tmp->tab_nom,tmp->svod_nom)+']'
              if len(s) < 8
                s := padr(s, 8)
              endif
            else
              s := padr('[+' + alltrim(tmp->u_shifr)+']', 8)
            endif
            if fl7_plan
              s += tmp->fio
              s := padr(s,len_n)+umest_val(tmp->trudoem, 9, 2)
              j := ret_trudoem(tmp->kod_vr_as,tmp->trudoem,ym_kol_mes,arr_m)
              s += '  '+put_val_0(j, 5, 1)
              add_string(s+put_kopE(tmp->stoim, 15))
            else
              if old_perso == tmp->kod_vr_as
                s := ''
              else
                s += tmp->fio
              endif
              s := padr(s,len_n-5)+' '+ ;
                   if(psz==1,if(tmp->vr_as==1,'врач','асс.'),space(4))
              skol[tmp->vr_as] += tmp->kol
              strud[tmp->vr_as] += tmp->trudoem
              sstoim[tmp->vr_as] += tmp->stoim
              old_perso := tmp->kod_vr_as
            endif
          case eq_any(k, 3, 6, 10, 11, 12, 110, 111)
            j := perenos(arr,tmp->u_shifr+' '+tmp->u_name,len_n)
            s := padr(arr[1],len_n)
            skol[1] += tmp->kol
            strud[1] += tmp->trudoem
            sstoim[1] += tmp->stoim
            if eq_any(k, 10, 110)
              pkol += tmp->kol
              ptrud += tmp->trudoem
              pstoim += tmp->stoim
              old_slugba := tmp->fio ; old_shifr := tmp->kod_vr_as
            endif
          case k == 5
            if serv_arr != NIL .and. old_perso != tmp->kod_vr_as
              if old_perso > 0
                add_string(replicate('─', sh))
                fl := .f.
                if !emptyall(skol[1],strud[1],sstoim[1])
                  fl := .t.
                  s := padl('И Т О Г О :  ',len_n-4)
                  if psz == 1 ; s += 'врач'
                  else        ; s += space(4)
                  endif
                  add_string(s+ ;
                             put_val(skol[1], 7, 0)+ ;
                             if(mem_trudoem==2,umest_val(strud[1], 9, 2),'')+ ;
                             put_kopE(sstoim[1], 15))
                endif
                if !emptyall(skol[2],strud[2],sstoim[2])
                  s := if(fl, '', 'И Т О Г О :  ')
                  add_string(padl(s,len_n-4)+'асс.'+ ;
                             put_val(skol[2], 7, 0)+ ;
                             if(mem_trudoem==2,umest_val(strud[2], 9, 2),'')+ ;
                             put_kopE(sstoim[2], 15))
                endif
                if fl5_plan
                  j := ret_trudoem(old_perso,strud[1]+strud[2],ym_kol_mes,arr_m)
                  add_string(space(31)+ ;
                     padl(' ' + alltrim(str_0(j, 7, 1))+' % выполнения', sh-31,'─'))
                  select TMP
                endif
                afill(skol, 0) ; afill(strud, 0) ; afill(sstoim, 0)
              endif
              add_string('')
              add_string(space(5)+put_tab_nom(tmp->tab_nom,tmp->svod_nom)+ ;
                         '. '+upper(rtrim(tmp->fio)))
            endif
            j := perenos(arr,tmp->u_shifr+' '+tmp->u_name,len_n-6)
            s := padr(arr[1],len_n-4)+ ;
                 if(psz==1,if(tmp->vr_as==1,'врач','асс.'),space(4))
            skol[tmp->vr_as] += tmp->kol
            strud[tmp->vr_as] += tmp->trudoem
            sstoim[tmp->vr_as] += tmp->stoim
            old_perso := tmp->kod_vr_as
        endcase
        if !fl7_plan
          add_string(s+ ;
                     put_val(tmp->kol, 7, 0)+ ;
                     if(mem_trudoem==2,umest_val(tmp->trudoem, 9, 2),'')+ ;
                     put_kopE(tmp->stoim, 15))
        endif
        if eq_any(k, 3, 31, 5, 6, 10, 11, 12, 110, 111) .and. j > 1
          for i := 2 to j
            add_string(space(11)+arr[i])
          next
        endif
      endif
      select TMP
      skip
    enddo
    if eq_any(k, 0, 10, 31, 100, 110)
      add_string(space(4)+replicate('.', sh-4))
      add_string(padr(space(4)+old_slugba,len_n)+ ;
                 put_val(pkol, 7, 0)+ ;
                 if(mem_trudoem==2,umest_val(ptrud, 9, 2),'')+ ;
                 put_kopE(pstoim, 15))
      add_string('')
    endif
    if k == 4
      add_string(space(4)+replicate('.', sh-4))
      add_string(padr(space(4)+old_fio,len_n-4)+ ;
                 if(psz==1,if(old_vr_as==1,'врач','асс.'),space(4))+ ;
                 put_val(pkol, 7, 0)+ ;
                 if(mem_trudoem==2,umest_val(ptrud, 9, 2),'')+ ;
                 put_kopE(pstoim, 15))
      add_string('')
    endif
    add_string(replicate('─', sh))
    fl := .f.
    if !emptyall(skol[1],strud[1],sstoim[1])
      fl := .t.
      s := padl('И Т О Г О :  ',len_n-4)
      if eq_any(k, 2, 4, 5, 7) .and. psz == 1
        s += 'врач'
      else
        s += space(4)
      endif
      if fl7_plan
        add_string(s+str_0(strud[1], 9, 1)+put_kopE(sstoim[1], 22))
      else
        add_string(s+ ;
                   str(skol[1], 7, 0)+ ;
                   if(mem_trudoem==2,umest_val(strud[1], 9, 2),'')+ ;
                   put_kopE(sstoim[1], 15))
      endif
    endif
    if (eq_any(k, 2, 4, 5, 7)) .and. !emptyall(skol[2],strud[2],sstoim[2])
      s := if(fl, '', 'И Т О Г О :  ')
      s := padl(s,len_n-4)+'асс.'
      if fl7_plan
        add_string(s+str_0(strud[2], 9, 1)+put_kopE(sstoim[2], 22))
      else
        add_string(s+ ;
                   str(skol[2], 7, 0)+ ;
                   if(mem_trudoem==2,umest_val(strud[2], 9, 2),'')+ ;
                   put_kopE(sstoim[2], 15))
      endif
    endif
    if fl5_plan
      j := ret_trudoem(old_perso,strud[1]+strud[2],ym_kol_mes,arr_m)
      add_string(space(31)+ ;
                 padl(' ' + alltrim(str_0(j, 7, 1))+' % выполнения', sh-31,'─'))
    endif
  endif
  if psz == 2 .and. is_oplata == 7 .and. is_1_usluga
    file_tmp7(arr_usl[1], sh,HH)
  endif
  fclose(fp)
  close databases
  viewtext('ob_stat' + stxt, , , , (sh > 80), , ,regim)
endif
return NIL

//
Static Function ob3_statist(k, arr_otd, serv_arr, mkod_perso)
Local i, j, mtrud := {0, 0, 0}, koef_z := {1, 1, 1}, k1 := 2, s1 := '2', lstoim
if !_f_ist_fin()
  return NIL
endif
if hu->u_kod > 0 .and. (&pole_kol > 0 .or. &pole_stoim > 0) .and. ;
                          (i := ascan(arr_otd, {|x| hu->otd==x[1]})) > 0
  lstoim := _f_stoim(1)
  if mem_trudoem == 2
    mtrud := _f_trud(&pole_kol, human->vzros_reb,hu->kod_vr,hu->kod_as)
  endif
  if psz == 2 .and. eq_any(is_oplata, 5, 6, 7)
    koef_z := ret_p3_z(hu->u_kod,hu->kod_vr,hu->kod_as)
    if is_oplata == 7 .and. is_1_usluga
      put_tmp7(&pole_kol,hu->kod_vr,hu->kod_as,mtrud,koef_z, 1)
    endif
    k1 := 1 ; s1 := '1'
  endif
  if fl7_plan
    k1 := 1 ; s1 := '1'
  endif
  select TMP
  do case
    case eq_any(k, 0, 100)
      select USL
      goto (hu->u_kod)
      if !usl->(eof()) .and. usl->slugba >= 0
        select TMP
        find (str(usl->slugba, 4)+str(hu->otd, 3))
        if !found()
          append blank
          tmp->otd := arr_otd[i, 1]
          if k == 0
            tmp->u_name := arr_otd[i, 2]
          elseif k == 100
            tmp->fio := arr_otd[i, 2]
          endif
          tmp->kod_vr_as := usl->slugba
          if (j := ascan(st_a_uch, {|x| x[1] == arr_otd[i, 3] } )) > 0
            tmp->u_kod := arr_otd[i, 3]  // код ЛПУ
            if len(st_a_uch) > 1
              if k == 0
                tmp->u_name := padr(arr_otd[i, 2], 31)+st_a_uch[j, 2]
              elseif k == 100
                tmp->fio := alltrim(tmp->fio)+' [' + alltrim(st_a_uch[j, 2])+']'
              endif
            endif
          endif
        endif
        tmp->kol += &pole_kol
        if mem_trudoem == 2 .and. psz == 2 .and. is_oplata == 6
          tmp->stoim += lstoim * koef_z[1]
        else
          tmp->stoim += _f_koef_z(lstoim,&pole_kol,koef_z)
        endif
        tmp->trudoem += mtrud[1]
      endif
    case k == 1
      find (str(hu->otd, 3))
      if !found()
        append blank
        tmp->otd := arr_otd[i, 1]
        tmp->fio := arr_otd[i, 2]
        if (j := ascan(st_a_uch, {|x| x[1] == arr_otd[i, 3] } )) > 0
          tmp->u_kod := arr_otd[i, 3]   // код ЛПУ
          tmp->fio := padr(arr_otd[i, 2], 31)+st_a_uch[j, 2]
        endif
      endif
      tmp->kol += &pole_kol
      tmp->stoim += _f_koef_z(lstoim,&pole_kol,koef_z)
      tmp->trudoem += mtrud[1]
    case eq_any(k, 2, 7)
      if hu->kod_vr > 0
        find ('1'+str(hu->kod_vr, 4))
        if !found()
          append blank
          tmp->vr_as := 1
          tmp->kod_vr_as := hu->kod_vr
        endif
        j := _f_koef_z(lstoim,&pole_kol,koef_z, 2)
        tmp->kol += &pole_kol
        tmp->stoim += j
        tmp->trudoem += mtrud[2]
        if fl7_plan
          strud[1] += mtrud[2]
          sstoim[1] += j
        endif
      endif
      if hu->kod_as > 0
        find (s1+str(hu->kod_as, 4))
        if !found()
          append blank
          tmp->vr_as := k1
          tmp->kod_vr_as := hu->kod_as
        endif
        j := _f_koef_z(lstoim,&pole_kol,koef_z, 3)
        tmp->kol += &pole_kol
        tmp->stoim += j
        tmp->trudoem += mtrud[3]
        if fl7_plan
          strud[2] += mtrud[3]
          sstoim[2] += j
        endif
      endif
    case eq_any(k, 3, 31, 6)
      if k == 31
        find (str(hu->otd, 3)+str(hu->u_kod, 4))
      else
        find (str(hu->u_kod, 4))
      endif
      if !found()
        append blank
        if k == 31
          tmp->otd := arr_otd[i, 1]
          tmp->fio := arr_otd[i, 2]
          if (j := ascan(st_a_uch, {|x| x[1] == arr_otd[i, 3] } )) > 0
            tmp->fio := alltrim(tmp->fio)+' [' + alltrim(st_a_uch[j, 2])+']'
          endif
        endif
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += &pole_kol
      tmp->stoim += _f_koef_z(lstoim,&pole_kol,koef_z)
      tmp->trudoem += mtrud[1]
    case k == 4
      if hu->kod_vr > 0
        find ('1'+str(hu->kod_vr, 4)+str(hu->u_kod, 4))
        if !found()
          append blank
          tmp->vr_as := 1
          tmp->kod_vr_as := hu->kod_vr
          tmp->u_kod := hu->u_kod
        endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z(lstoim,&pole_kol,koef_z, 2)
        tmp->trudoem += mtrud[2]
      endif
      if hu->kod_as > 0
        find (s1+str(hu->kod_as, 4)+str(hu->u_kod, 4))
        if !found()
          append blank
          tmp->vr_as := k1
          tmp->kod_vr_as := hu->kod_as
          tmp->u_kod := hu->u_kod
        endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z(lstoim,&pole_kol,koef_z, 3)
        tmp->trudoem += mtrud[3]
      endif
    case k == 5
      if hu->kod_vr == mkod_perso
        find ('1'+str(mkod_perso, 4)+str(hu->u_kod, 4))
        if !found()
          append blank
          tmp->vr_as := 1
          tmp->kod_vr_as := mkod_perso
          tmp->u_kod := hu->u_kod
        endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z(lstoim,&pole_kol,koef_z, 2)
        tmp->trudoem += mtrud[2]
      endif
      if hu->kod_as == mkod_perso
        find (s1+str(mkod_perso, 4)+str(hu->u_kod, 4))
        if !found()
          append blank
          tmp->vr_as := k1
          tmp->kod_vr_as := mkod_perso
          tmp->u_kod := hu->u_kod
        endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z(lstoim,&pole_kol,koef_z, 3)
        tmp->trudoem += mtrud[3]
      endif
    case eq_any(k, 10, 110)  // службы + услуги
      select USL
      goto (hu->u_kod)
      if !eof() .and. usl->slugba >= 0
        select TMP
        find (str(hu->u_kod, 4))
        if !found()
          append blank
          tmp->kod_vr_as := usl->slugba
          tmp->u_kod := usl->kod
        endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z(lstoim,&pole_kol,koef_z)
        tmp->trudoem += mtrud[1]
      endif
    case eq_any(k, 11, 111)  // служба + услуги
      select USL
      goto (hu->u_kod)
      if !eof() .and. usl->slugba == serv_arr[1]
        select TMP
        find (str(hu->u_kod, 4))
        if !found()
          append blank
          tmp->u_kod := usl->kod
        endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z(lstoim,&pole_kol,koef_z)
        tmp->trudoem += mtrud[1]
      endif
    case k == 12  // все услуги
      select USL
      goto (hu->u_kod)
      if !eof()
        select TMP
        find (str(hu->u_kod, 4))
        if !found()
          append blank
          tmp->u_kod := usl->kod
        endif
        tmp->kol += &pole_kol
        tmp->stoim += _f_koef_z(lstoim,&pole_kol,koef_z)
        tmp->trudoem += mtrud[1]
      endif
  endcase
endif
return NIL

//
Static Function ob4_statist(k, arr_otd, i, mkol, mstoim, serv_arr, mkod_perso)
Local j, mtrud := {0, 0, 0}, koef_z := {1, 1, 1}, k1 := 2, s1 := '2'
if !_f_ist_fin()
  return NIL
endif
if mem_trudoem == 2
  mtrud := _f_trud(mkol, human->vzros_reb,hu->kod_vr,hu->kod_as)
endif
if psz == 2 .and. eq_any(is_oplata, 5, 6, 7)
  koef_z := ret_p3_z(hu->u_kod,hu->kod_vr,hu->kod_as)
  if is_oplata == 7 .and. is_1_usluga
    put_tmp7(mkol,hu->kod_vr,hu->kod_as,mtrud,koef_z, 1)
  endif
  k1 := 1 ; s1 := '1'
endif
if fl7_plan
  k1 := 1 ; s1 := '1'
endif
select TMP
do case
  case eq_any(k, 0, 100)
    select USL
    goto (hu->u_kod)
    if !usl->(eof()) .and. usl->slugba >= 0
      select TMP
      find (str(usl->slugba, 4)+str(hu->otd, 3))
      if !found()
        append blank
        tmp->otd := arr_otd[i, 1]
        if k == 0
          tmp->u_name := arr_otd[i, 2]
        elseif k == 100
          tmp->fio := arr_otd[i, 2]
        endif
        tmp->kod_vr_as := usl->slugba
        if (j := ascan(st_a_uch, {|x| x[1] == arr_otd[i, 3] } )) > 0
          tmp->u_kod := arr_otd[i, 3]   // код ЛПУ
          if len(st_a_uch) > 1
            if k == 0
              tmp->u_name := padr(arr_otd[i, 2], 31)+st_a_uch[j, 2]
            elseif k == 100
              tmp->fio := alltrim(tmp->fio)+' [' + alltrim(st_a_uch[j, 2])+']'
            endif
          endif
        endif
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z)
      tmp->trudoem += mtrud[1]
    endif
  case k == 1
    find (str(hu->otd, 3))
    if !found()
      append blank
      tmp->otd := arr_otd[i, 1]
      tmp->fio := arr_otd[i, 2]
      if (j := ascan(st_a_uch, {|x| x[1] == arr_otd[i, 3] } )) > 0
        tmp->u_kod := arr_otd[i, 3]  // код ЛПУ
        tmp->fio := padr(arr_otd[i, 2], 31)+st_a_uch[j, 2]
      endif
    endif
    tmp->kol += mkol
    tmp->stoim += _f_koef_z(mstoim,mkol,koef_z)
    tmp->trudoem += mtrud[1]
  case eq_any(k, 2, 7)
    if hu->kod_vr > 0
      find ('1'+str(hu->kod_vr, 4))
      if !found()
        append blank
        tmp->vr_as := 1
        tmp->kod_vr_as := hu->kod_vr
      endif
      j := _f_koef_z(mstoim,mkol,koef_z, 2)
      tmp->kol += mkol
      tmp->stoim += j
      tmp->trudoem += mtrud[2]
      if fl7_plan
        strud[1] += mtrud[2]
        sstoim[1] += j
      endif
    endif
    if hu->kod_as > 0
      find (s1+str(hu->kod_as, 4))
      if !found()
        append blank
        tmp->vr_as := k1
        tmp->kod_vr_as := hu->kod_as
      endif
      j := _f_koef_z(mstoim,mkol,koef_z, 3)
      tmp->kol += mkol
      tmp->stoim += j
      tmp->trudoem += mtrud[3]
      if fl7_plan
        strud[2] += mtrud[3]
        sstoim[2] += j
      endif
    endif
  case eq_any(k, 3, 6)
    find (str(hu->u_kod, 4))
    if !found()
      append blank
      tmp->u_kod := hu->u_kod
    endif
    tmp->kol += mkol
    tmp->stoim += _f_koef_z(mstoim,mkol,koef_z, 1)
    tmp->trudoem += mtrud[1]
  case k == 4
    if hu->kod_vr > 0
      find ('1'+str(hu->kod_vr, 4)+str(hu->u_kod, 4))
      if !found()
        append blank
        tmp->vr_as := 1
        tmp->kod_vr_as := hu->kod_vr
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z, 2)
      tmp->trudoem += mtrud[2]
    endif
    if hu->kod_as > 0
      find (s1+str(hu->kod_as, 4)+str(hu->u_kod, 4))
      if !found()
        append blank
        tmp->vr_as := k1
        tmp->kod_vr_as := hu->kod_as
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z, 3)
      tmp->trudoem += mtrud[3]
    endif
  case k == 5
    if hu->kod_vr == mkod_perso
      find ('1'+str(mkod_perso, 4)+str(hu->u_kod, 4))
      if !found()
        append blank
        tmp->vr_as := 1
        tmp->kod_vr_as := mkod_perso
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z, 2)
      tmp->trudoem += mtrud[2]
    endif
    if hu->kod_as == mkod_perso
      find (s1+str(mkod_perso, 4)+str(hu->u_kod, 4))
      if !found()
        append blank
        tmp->vr_as := k1
        tmp->kod_vr_as := mkod_perso
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z, 3)
      tmp->trudoem += mtrud[3]
    endif
  case eq_any(k, 10, 110)  // службы + услуги
    select USL
    goto (hu->u_kod)
    if !eof() .and. usl->slugba >= 0
      select TMP
      find (str(hu->u_kod, 4))
      if !found()
        append blank
        tmp->kod_vr_as := usl->slugba
        tmp->u_kod := usl->kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z, 1)
      tmp->trudoem += mtrud[1]
    endif
  case eq_any(k, 11, 111)  // служба + услуги
    select USL
    goto (hu->u_kod)
    if !eof() .and. usl->slugba == serv_arr[1]
      select TMP
      find (str(hu->u_kod, 4))
      if !found()
        append blank
        tmp->u_kod := usl->kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z, 1)
      tmp->trudoem += mtrud[1]
    endif
  case k == 12  // все услуги
    select USL
    goto (hu->u_kod)
    if !eof()
      select TMP
      find (str(hu->u_kod, 4))
      if !found()
        append blank
        tmp->u_kod := usl->kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z, 1)
      tmp->trudoem += mtrud[1]
    endif
endcase
return NIL

//
Static Function ob5_statist(k, arr_otd, serv_arr, mkol, mstoim)
if !_f_ist_fin()
  return NIL
endif
if arr_otd != NIL .and. ascan(arr_otd, {|x| hu->otd==x[1]}) == 0
  return NIL
endif
select TMP
if eq_any(k, 13, 14)
  find (str(hu->u_kod, 4)+str(human->kod, 7))
else
  find (str(human->kod, 7))
endif
if !found()
  append blank
  if eq_any(k, 13, 14)
    tmp->u_kod := hu->u_kod
  endif
  tmp->kod := human->kod
  tmp->fio := fam_i_o(human->fio)
  tmp->k_data := human->k_data
endif
DEFAULT mkol TO &pole_kol, mstoim TO &pole_stoim
tmp->kol += mkol
tmp->stoim += mstoim
return NIL

// подсчитать процент по отделениям (для службы)
Static Function ob6_statist()
Local arr := {}, i
select TMP
go top
do while !eof()
  if (i := ascan(arr, {|x| x[1] == tmp->kod_vr_as} )) == 0
    aadd(arr, {tmp->kod_vr_as, 0} ) ; i := len(arr)
  endif
  arr[i, 2] += tmp->stoim
  skip
enddo
go top
do while !eof()
  if (i := ascan(arr, {|x| x[1] == tmp->kod_vr_as} )) >  0 .and. arr[i, 2] > 0
    tmp->u_shifr := str(tmp->stoim / arr[i, 2] * 100, 6, 2)+'%'
  endif
  skip
enddo
return NIL

// подсчитать процент по службам (для отделения)
Static Function ob7_statist()
Local arr := {}, i
select TMP
go top
do while !eof()
  if (i := ascan(arr, {|x| x[1] == tmp->otd} )) == 0
    aadd(arr, {tmp->otd, 0} ) ; i := len(arr)
  endif
  arr[i, 2] += tmp->stoim
  skip
enddo
go top
do while !eof()
  if (i := ascan(arr, {|x| x[1] == tmp->otd} )) > 0 .and. arr[i, 2] > 0
    tmp->u_shifr := str(tmp->stoim / arr[i, 2] * 100, 6, 2)+'%'
  endif
  skip
enddo
return NIL

//
Static Function _f_stoim(k)
Local sstoim, skol, scena
if k == 1
  skol := &pole_kol
  sstoim := &pole_stoim
else
  skol := hu->kol
  sstoim := hu->stoim
endif
if empty(sstoim) .and. select('UD') > 0
  select UD
  find (str(hu->u_kod, 4))
  if found()
    scena := iif(human->vzros_reb==0, ud->cena, ud->cena_d)
    sstoim := round_5(scena*skol, 2)
  endif
endif
return sstoim

// инициализация источников финансирования
Function _init_if()
Local i, arr_f := {'str_komp', ,'komitet'}, arr := {I_FIN_OMS}, arr2 := {}
for i := 1 to 3
  if i != 2 .and. hb_fileExists(dir_server+arr_f[i]+sdbf)
    R_Use(dir_server+arr_f[i], ,'_B')
    go top
    do while !eof()
      if iif(i == 1, !between(_b->tfoms, 44, 47), .t.)
        aadd(arr2, {i,_b->kod,_b->ist_fin})
        if ascan(arr,_b->ist_fin) == 0
          aadd(arr,_b->ist_fin)
        endif
      endif
      skip
    enddo
    Use
  endif
next
return {arr,arr2}

// вернуть источник фин-ия (bit-овый вариант)
Function fbp_ist_fin(r, c)
Static sast := {}
Local fl := .t., i, j, a, arr := {}
_arr_if := {}
_arr_komit := {}
if len(_what_if[1]) > 1
  for i := 1 to len(mm_ist_fin)
    if ascan(_what_if[1],mm_ist_fin[i, 2]) > 0
      aadd(arr,mm_ist_fin[i])
    endif
  next
  if (j := len(arr)) > 0
    if len(sast) != j
      sast := array(j) ; afill(sast, .t.)
    endif
    if (a := bit_popup(r,c,arr,sast)) != NIL
      afill(sast, .f.) ; fl := .t.
      for i := 1 to len(a)
        aadd(_arr_if,a[i, 2])
        if (j := ascan(arr,{|x| x[2]==a[i, 2] })) > 0
          sast[j] := .t.
        endif
      next
    endif
    if len(_arr_if) == len(arr)
      _arr_if := {}
    endif
    if len(_arr_if) == 1 .and. _arr_if[1] == I_FIN_BUD
      arr := {}
      R_Use(dir_server + 'komitet', ,'KOM')
      go top
      do while !eof()
        if kom->ist_fin == I_FIN_BUD
          aadd(arr, {alltrim(kom->name),kom->kod})
        endif
        skip
      enddo
      kom->(dbCloseArea())
      _arr_komit := aclone(arr)
      if len(arr) > 1
        if (a := bit_popup(r,c,arr)) != NIL
          _arr_komit := {}
          for i := 1 to len(a)
            aadd(_arr_komit,aclone(a[i]))
          next
        endif
      endif
    endif
  endif
endif
return fl

// проверить источник финансирования
Function _f_ist_fin()
Local fl := .t., k
if len(_arr_if) > 0
  if (human->komu==0 .or. !empty(val(human_->smo))) .and. ascan(_arr_if,I_FIN_OMS) > 0
    return fl // ТФОМС
  endif
  if human->komu == 5 .and. ascan(_arr_if,I_FIN_PLAT) > 0
    return fl // личный счет = платные услуги
  endif
  fl := .f.
  if (k := ascan(_what_if[2], {|x| x[1]==human->komu .and. x[2]==human->str_crb})) > 0
    if (fl := (ascan(_arr_if,_what_if[2,k, 3]) > 0))
      if len(_arr_if) == 1 .and. _arr_if[1] == I_FIN_BUD .and. len(_arr_komit) > 0
        fl := (ascan(_arr_komit,{|x| x[2] == _what_if[2,k, 2] }) > 0)
      endif
    endif
  endif
endif
return fl

// 17.03.13
Function _tit_ist_fin(sh)
Local i, s := '[ '
if valtype(_arr_if) == 'A' .and. len(_arr_if) > 0
  if len(_arr_if) == 1 .and. _arr_if[1] == I_FIN_BUD .and. len(_arr_komit) == 1
    s += _arr_komit[1, 1]
  else
    for i := 1 to len(_arr_if)
      s += alltrim(inieditspr(A__MENUVERT, mm_ist_fin, _arr_if[i]))+', '
    next
  endif
  s := substr(s, 1,len(s)-2)+' ]'
  add_string(center(s, sh))
endif
return NIL

//
Function ret_p3_z(mkod_usl, mkod_vr, mkod_as)
Local mk[8], tmp_select := select(), i := 0, lgruppa, ;
      lshifr, lrazryad, lotdal, lprocent := {0, 0}, lkod, ltip, ap2 := {0, 0}, ;
      luet := {0, 0, 0, 0, 0}
afill(mk, 0)
if mkod_vr > 0 .or. mkod_as > 0
  select USL
  goto (mkod_usl)
  if !eof()  // удачное перемещение по БД услуг
    if eq_any(is_oplata, 5, 6, 7)
      lshifr := fsort_usl(usl->shifr)
      if glob_task == X_PLATN  // для задачи 'Платные услуги'
        for i := 1 to 2
          lrazryad := lotdal := 0
          if (lkod := {mkod_vr,mkod_as}[i]) > 0
            perso->(dbGoto(lkod))
            lrazryad := perso->uroven
            lotdal := perso->otdal
          endif
          if i == 1
            ltip := O5_VR_PLAT  // врач(пл.)
            if is_oplata == 7 .and. human->tip_usl == PU_D_SMO
              ltip := O5_VR_DMS  // врач(ДМС)
            endif
          else
            ltip := O5_AS_PLAT  // асс.(пл.)
            if is_oplata == 7 .and. human->tip_usl == PU_D_SMO
              ltip := O5_AS_DMS  // асс.(ДМС)
            endif
          endif
          lprocent := ret_opl_5(lshifr,ltip,lrazryad,lotdal)
          mk[i+1] := lprocent[1]
          ap2[i] := lprocent[2]
          if is_oplata == 7 .and. emptyall(lprocent[1],lprocent[2])
            luet := ret_opl_7(lshifr,iif(human->tip_usl==PU_D_SMO, 3, 2),kart->vzros_reb)
          endif
        next
      else  // для задачи ОМС
        for i := 1 to 2
          lrazryad := lotdal := 0
          if (lkod := {mkod_vr,mkod_as}[i]) > 0
            perso->(dbGoto(lkod))
            lrazryad := perso->uroven
            lotdal := perso->otdal
          endif
          if i == 1
            ltip := O5_VR_OMS  // врач(ОМС)
          else
            ltip := O5_AS_OMS  // асс.(ОМС)
          endif
          lprocent := ret_opl_5(lshifr,ltip,lrazryad,lotdal)
          mk[i+1] := lprocent[1]
          ap2[i] := lprocent[2]
          if is_oplata == 7 .and. emptyall(lprocent[1],lprocent[2])
            luet := ret_opl_7(lshifr, 1, human->vzros_reb)
          endif
        next
      endif
      if mkod_vr > 0 .and. mkod_as == 0
        if ap2[1] > 0
          mk[2] := ap2[1]  // заменяем на значение % оплаты при отсутствии ассистента
        else
          mk[2] += mk[3]   // прибавляем долю отсутствующего ассистента
        endif
        mk[3] := 0
      endif
      if mkod_vr == 0 .and. mkod_as > 0
        if ap2[2] > 0
          mk[3] := ap2[2]  // заменяем на значение % оплаты при отсутствии врача
        else
          mk[3] += mk[2]   // прибавляем долю отсутствующего врача
        endif
        mk[2] := 0
      endif
      mk[1] := mk[2] + mk[3]
      if is_oplata == 7 .and. empty(mk[1])
        for i := 1 to 5
          mk[3+i] := luet[i]
        next
        if luet[5] == 0 // вариант 2
          if mkod_vr > 0 .and. mkod_as == 0
            mk[6] += mk[7]   // прибавляем ст-ть УЕТ отсутствующего ассистента
            mk[5] := mk[7] := 0
          endif
          if mkod_vr == 0 .and. mkod_as > 0
            mk[4] := mk[6] := 0 // берем только зарплату ассистента
          endif
        else // вариант 1
          if mkod_vr > 0 .and. mkod_as == 0
            mk[4] += mk[5]   // прибавляем кол-во УЕТ отсутствующего ассистента
            mk[5] := 0
          endif
          if mkod_vr == 0 .and. mkod_as > 0
            mk[5] += mk[4]   // прибавляем кол-во УЕТ отсутствующего врача
            mk[4] := 0
          endif
        endif
      else
        aeval(mk, {|x,i| mk[i] := x / 100 } )
      endif
    endif
  endif
endif
select (tmp_select)
return mk

//
Function open_opl_5()
if is_oplata == 7
  arr_opl_7 := {}
  R_Use(dir_server + 'u_usl_7', ,'U7')
  go top
  do while !eof()
    if !empty(u7->name)
      aadd(arr_opl_7, {u7->v_uet_oms, ;
                       u7->a_uet_oms, ;
                       u7->v_uet_pl , ;
                       u7->a_uet_pl , ;
                       u7->v_uet_dms, ;
                       u7->a_uet_dms, ;
                       {Slist2arr(u7->usl_ins),Slist2arr(u7->usl_del)}, ;
                       u7->variant})
    endif
    skip
  enddo
  u7->(dbCloseArea())
  len_arr_7 := len(arr_opl_7)
endif
G_Use(dir_server + 'u_usl_5', ,'U5')
index on str(tip, 2)+fsort_usl(iif(empty(usl_2),usl_1,usl_2))+ ;
      str(razryad, 2)+str(otdal, 1) to (cur_dir + 'tmp_u5')
return NIL

//
Function ret_opl_5(lshifr, i, lrazryad, lotdal)
Local musl_1, musl_2, lprocent := 0, lprocent2 := 0, fl1 := .f., fl2 := .f.
select U5
dbseek(str(i, 2)+lshifr, .t.)
do while u5->tip == i .and. !eof()
  musl_1 := musl_2 := fsort_usl(u5->usl_1)
  if !empty(u5->usl_2)
    musl_2 := fsort_usl(u5->usl_2)
  endif
  if between(lshifr,musl_1,musl_2)
    if u5->razryad == 0 .and. !fl1 .and. !fl2
      fl1 := .t.
      lprocent := u5->procent
      lprocent2 := u5->procent2
    endif
    if lrazryad > 0 .and. lrazryad == u5->razryad .and. u5->otdal == 0 .and. !fl2
      fl2 := .t.
      lprocent := u5->procent
      lprocent2 := u5->procent2
    endif
    if lotdal > 0 .and. lrazryad > 0 .and. ;
             lrazryad == u5->razryad .and. lotdal == u5->otdal
      lprocent := u5->procent
      lprocent2 := u5->procent2
      exit
    endif
  elseif fl1 .or. fl2
    exit
  endif
  select U5
  skip
enddo
return {lprocent,lprocent2}

//
Function ret_opl_7(lshifr, k, lvzros_reb)
Local luet[5], i, luetv, lueta, lstv, lsta
afill(luet, 0)
for i := 1 to len_arr_7
  if ret_f_nastr(arr_opl_7[i, 7], usl->shifr)
    luetv := opr_uet(lvzros_reb, 1)
    lueta := opr_uet(lvzros_reb, 2)
    do case
      case k == 1  // ОМС
        lstv := arr_opl_7[i, 1]
        lsta := arr_opl_7[i, 2]
      case k == 2  // платные
        lstv := arr_opl_7[i, 3]
        lsta := arr_opl_7[i, 4]
      case k == 3  // ДМС
        lstv := arr_opl_7[i, 5]
        lsta := arr_opl_7[i, 6]
    endcase
    luet := {luetv,lueta,lstv,lsta,arr_opl_7[i, 8]}
    exit
  endif
next
return luet

//
Function _f_koef_z(lstoim, lkol, lkoef, k)
Local vv := 0, va := 0, v := 0, fl := .f.
DEFAULT k TO 1
if psz == 2 .and. is_oplata == 7 .and. emptyany(lstoim,lkoef[1])
  if k == 1 .or. k == 2
    vv := lkoef[4] * lkoef[6]
  endif
  if k == 1 .or. k == 3
    va := lkoef[5] * lkoef[7]
  endif
  fl := .t.
endif
if fl
  v := (vv + va) * lkol
else
  v := lstoim * lkoef[k]
endif
return v

//
Function _f_trud(lkol, lvzros_reb, lkod_vr, lkod_as)
Local mtrud := {0, 0, 0}
mtrud[1] := round_5(lkol * opr_uet(lvzros_reb), 4)
if is_oplata == 7
  mtrud[2] := round_5(lkol * opr_uet(lvzros_reb, 1), 4)
  mtrud[3] := round_5(lkol * opr_uet(lvzros_reb, 2), 4)
else
  //mtrud[3] := round_5(mtrud[1]/2, 4)
  //mtrud[2] := mtrud[1] - mtrud[3]
  mtrud[2] := mtrud[3] := mtrud[1]
endif
if lkod_vr > 0 .and. lkod_as == 0
  mtrud[3] := 0
  mtrud[2] := mtrud[1]
elseif lkod_vr == 0 .and. lkod_as > 0
  mtrud[2] := 0
  mtrud[3] := mtrud[1]
endif
return mtrud

//
Function cre_tmp7()
dbcreate(cur_dir + 'tmp7',{{'kod_vr','N', 4, 0}, ;
                 {'kod_as','N', 4, 0}, ;
                 {'tip','N', 1, 0}, ;
                 {'kol','N', 4, 0}, ;
                 {'uet_vr','N', 11, 4}, ;
                 {'uet_as','N', 11, 4}, ;
                 {'zrp_vr','N', 11, 2}, ;
                 {'zrp_as','N', 11, 2}})
use (cur_dir + 'tmp7') new
index on str(tip, 1)+str(kod_vr, 4)+str(kod_as, 4) to (cur_dir + 'tmp7')
return NIL

//
Function put_tmp7(lkol, lkod_vr, lkod_as, atrud, akoef_z, k)
select TMP7
find (str(k, 1)+str(lkod_vr, 4)+str(lkod_as, 4))
if !found()
  append blank
  tmp7->tip    := k
  tmp7->kod_vr := lkod_vr
  tmp7->kod_as := lkod_as
endif
tmp7->kol += lkol
tmp7->uet_vr += akoef_z[4]
tmp7->uet_as += akoef_z[5]
tmp7->zrp_vr += _f_koef_z(0,lkol,akoef_z, 2)
tmp7->zrp_as += _f_koef_z(0,lkol,akoef_z, 3)
return NIL

//
Function file_tmp7(ausl, sh, HH, k)
Local arr_title, i, s, lkod_usl, skol := 0, svuet := 0, sauet := 0, ;
      svzrp := 0, sazrp := 0
DEFAULT k TO 1  // ОМС
if valtype(ausl) == 'A'
  lkod_usl := ausl[1]
else
  return NIL
endif
arr_title := { ;
  '───┬──────────╥─────┬─────╥───────────────╥─────────────────────', ;
  '   │Количество║ Врач│ Асс.║     У Е Т     ║   Заработная плата  ', ;
  '   │  услуг   ║     │     ╟───────┬───────╫──────────┬──────────', ;
  '   │          ║     │     ║  врач │  асс. ║   Врач   │ Ассистент', ;
  '───┴──────────╨─────┴─────╨───────┴───────╨──────────┴──────────'}
sh := len(arr_title[1])
if select('PERSO') == 0
  R_Use(dir_server + 'mo_pers', ,'PERSO')
endif
if select('TMP7') == 0
  Use (cur_dir + 'tmp7') index (cur_dir + 'tmp7') new
endif
if select('UU') == 0
  useUch_Usl()
endif
select UU
find (str(lkod_usl, 4))
if select('USL') == 0
  R_Use(dir_server + 'uslugi', ,'USL')
endif
usl->(dbGoto(lkod_usl))
//
verify_FF(HH - 16, .t., sh)
add_string('')
add_string(center('Алгоритм определения заработной платы по услуге', sh))
add_string(center('"' + alltrim(usl->shifr) + '"', sh))
add_string(center('"' + alltrim(usl->name) + '"', sh))
add_string('')
s := 'УЕТ для взрослого - врач: ' + alltrim(str_0(uu->vkoef_v, 7, 4))+ ;
                       ', асс.: ' + alltrim(str_0(uu->akoef_v, 7, 4))
add_string(center(s, sh))
s := 'УЕТ для ребенка - врач: ' + alltrim(str_0(uu->vkoef_r, 7, 4))+ ;
                     ', асс.: ' + alltrim(str_0(uu->akoef_r, 7, 4))
add_string(center(s, sh))
for i := 1 to len_arr_7
  if ret_f_nastr(arr_opl_7[i, 7], usl->shifr)
    add_string('')
    if k == 1  // ОМС
      s := 'ст-ть ОМС УЕТ для врача: ' + lstr(arr_opl_7[i, 1], 12, 2)+ ;
                        ', для асс.: ' + lstr(arr_opl_7[i, 2], 12, 2)
      add_string(center(s, sh))
    else
      s := 'ст-ть платных УЕТ для врача: ' + lstr(arr_opl_7[i, 3], 12, 2)+ ;
                            ', для асс.: ' + lstr(arr_opl_7[i, 4], 12, 2)
      add_string(center(s, sh))
      s := 'ст-ть ДМС УЕТ для врача: ' + lstr(arr_opl_7[i, 5], 12, 2)+ ;
                        ', для асс.: ' + lstr(arr_opl_7[i, 6], 12, 2)
      add_string(center(s, sh))
    endif
    exit
  endif
next
add_string('')
aeval(arr_title, {|x| add_string(x) } )
select TMP7
go top
do while !eof()
  s := {'ОМС','пл.','ДМС'}[tmp7->tip]+str(tmp7->kol, 7)
  skol += tmp7->kol
  if tmp7->kod_vr == 0
    s += space(10)
  else
    s += str(ret_tabn(tmp7->kod_vr), 10)
  endif
  if tmp7->kod_as == 0
    s += space(6)
  else
    s += str(ret_tabn(tmp7->kod_as), 6)
  endif
  s += ' '+umest_val(tmp7->uet_vr, 7, 4)+' '+umest_val(tmp7->uet_as, 7, 4)
  svuet += tmp7->uet_vr
  sauet += tmp7->uet_as
  s += str(tmp7->zrp_vr, 11, 2)+str(tmp7->zrp_as, 11, 2)
  svzrp += tmp7->zrp_vr
  sazrp += tmp7->zrp_as
  if verify_FF(HH, .t., sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(s)
  select TMP7
  skip
enddo
add_string(replicate('─', sh))
s := str(skol, 10)+space(10+6)
s += ' '+umest_val(svuet, 7, 4)+' '+umest_val(sauet, 7, 4)+ ;
     str(svzrp, 11, 2)+str(sazrp, 11, 2)
add_string(s)
add_string(center('Итого УЕТ: '+ltrim(umest_val(svuet+sauet, 11, 4))+ ;
                  ', зар.плата: ' + lstr(svzrp+sazrp, 12, 2), sh))
return NIL

//
Function o_proverka(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {'Общая проверка по ~запросу', ;
                'Не введен код ~врача', ;
                'Не введен код ~ассистента', ;
                'Врач + ~больные за день', ;
                'Одинаковые сочетания - № карты + ~дата вызова', ;
                '~Рассогласования в базах данных'}
    mas_msg := {'Общие проверки (многовариантный запрос)', ;
                'Проверка листов учета на отсутствие кода врача', ;
                'Проверка листов учета на отсутствие кода ассистента', ;
                'Вывод списка принятых больных конкретным врачом за день', ;
                'Поиск одинаковых сочетаний номера карты вызова + даты вызова', ;
                'Поиск рассогласований в базах данных (не заполнены или неверно заполнены поля)'}
    mas_fun := {'o_proverka(11)', ;
                'o_proverka(12)', ;
                'o_proverka(13)', ;
                'o_proverka(14)', ;
                'o_proverka(15)', ;
                'o_proverka(16)'}
    uch_otd := saveuchotd()
    Private p_net_otd := .t.
    popup_prompt(T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun)
    restuchotd(uch_otd)
  case k == 11
    proch_proverka()
  case k == 12
    o_pr_vr_as(1)
  case k == 13
    o_pr_vr_as(2)
  case k == 14
    i_vr_boln()
  case k == 15
    posik_smp_n_d()
  case k == 16
    poisk_rassogl()
endcase
if k > 10
  j := int(val(right(lstr(k), 1)))
  if between(k, 11, 19)
    si1 := j
  endif
endif
return NIL

// 15.06.18
Function proch_proverka()
Static sd, sl := 2
Static mm_schet := {{'по счетам         ', 1}, ;
                    {'по реестрам       ', 2}, ;
                    {'по невыписанным...', 3}}
Static mm_logical := {{'логическое И  ', 1}, ;
                      {'логическое ИЛИ', 2}}
Local buf := savescreen(), tmp_color := setcolor(cDataCGet), ;
      name_file := cur_dir + 'proverka' + stxt, i, j, arr_usl, ;
      sh := 64, HH := 57, reg_print := 2, r1 := 9, cdate, mdiagnoz, ;
      mm_da_net := {{'нет', 1},{'да ', 2}}, lcount_uch
if (st_a_uch := inputN_uch(T_ROW, T_COL - 5, , , @lcount_uch)) == NIL
  return NIL
endif
DEFAULT sd TO sys_date
Private pdate_schet, m1schet := 1, mschet, ;
        m1logic := sl, mlogic, ;
        m1mkb := 0, mmkb := space(3), ;
        m1usl_dn := 0, musl_dn := space(3), ;
        m1ns_usl := 0, mns_usl := space(3), ;
        m1ns1usl := 1, mns1usl, ;
        m1pervich := 0, mpervich := space(3), ;
        mkol := 0, msrok1 := 0, msrok2 := 0, ;
        m1date_schet := 0, mdate_schet := space(10), ;
        mm_ns1usl := {{'только по этому случаю  ', 1}, ;
                      {'по всем случаям больного', 2}}, ;
        gl_area := {r1, 2, maxrow()-2, maxcol()-2, 0}
mns1usl := inieditspr(A__MENUVERT,mm_ns1usl,m1ns1usl)
mschet := inieditspr(A__MENUVERT,mm_schet,m1schet)
mlogic := inieditspr(A__MENUVERT, mm_logical, m1logic)
r1 := maxrow() - 14
box_shadow(r1, 2,maxrow() - 2, maxcol() - 2, , 'Ввод данных для поиска информации', color8)
do while .t.
  j := r1 + 1
  ++j
  @ j, 4 say 'Где искать' get mschet ;
        reader {|x|menu_reader(x,mm_schet,A__MENUVERT, , , .f.)} ;
        valid {|| iif(m1schet > 1, mdate_schet := ctod(''),), .t. }
  @ row(),col()+3 say 'Дата счёта' get mdate_schet ;
        reader {|x|menu_reader(x, ;
                 {{|k,r,c| k:=year_month(r+1,c), ;
                    if(k == nil, nil, (pdate_schet := aclone(k), k:={k[1], k[4]})), ;
                      k }}, A__FUNCTION, , , .f.)} ;
        when m1schet == 1
  ++j
  @ j, 4 say 'Метод поиска' get mlogic ;
        reader {|x|menu_reader(x,mm_logical,A__MENUVERT, , , .f.)}
  ++j
  @ j, 4 say 'Максимальное количество оказанных услуг' get mkol pict '999'
  ++j
  @ j, 4 say 'Срок лечения (в днях): минимальный' get msrok1 pict '999'
  @ row(),col() say ', максимальный' get msrok2 pict '999'
  ++j
  @ j, 4 say 'Количество одноименных услуг <= количества дней лечения?' get musl_dn ;
        reader {|x|menu_reader(x,mm_da_net,A__MENUVERT, , , .f.)}
  ++j
  @ j, 4 say 'Проверять все диагнозы на соответствие МКБ-10 (по ОМС)?' get mmkb ;
        reader {|x|menu_reader(x,mm_da_net,A__MENUVERT, , , .f.)}
  ++j
  @ j, 4 say 'Проверять несовместимость услуг по дате оказания?' get mns_usl ;
        reader {|x|menu_reader(x,mm_da_net,A__MENUVERT, , , .f.)}
  ++j
  @ j, 4 say '- как выполнять данную проверку' get mns1usl ;
        reader {|x|menu_reader(x,mm_ns1usl,A__MENUVERT, , , .f.)}
  ++j
  @ j, 4 say 'Проверять наличие более 1 стом. первичного приема в году?' get mpervich ;
        reader {|x|menu_reader(x,mm_da_net,A__MENUVERT, , , .f.)}
  status_key('^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода')
  myread()
  if lastkey() == K_ESC
    exit
  elseif m1schet == 1
    if empty(m1date_schet)
      func_error(4, 'Обязательно должно быть заполнено поле ДАТА СЧЕТА!')
      loop
    elseif pdate_schet[1] < 2016
      func_error(4, 'Проверяется только после 2016 года!')
      loop
    endif
  endif 
  if f_Esc_Enter('начала проверки')
    sd := mdate_schet ; sl := m1logic
    mywait()
    dbcreate(cur_dir + 'tmp',{{'schet','N', 6, 0}, ;
                            {'kod','N', 7, 0}})
    dbcreate(cur_dir + 'tmpk',{{'rec','N', 7, 0}, ;
                             {'name','C', 100, 0}})
    use (cur_dir + 'tmp') new
    index on str(schet, 6)+str(kod, 7) to (cur_dir + 'tmp')
    use (cur_dir + 'tmpk') new
    index on str(rec, 7) to (cur_dir + 'tmpk')
    fl_exit := .f.
    fl_srok := (msrok1 > 0 .or. msrok2 > 0)
    R_Use(dir_server + 'kartotek', ,'KART')
    R_Use(dir_server + 'ns_usl_k', dir_server + 'ns_usl_k','NSK')
    G_Use(dir_server + 'ns_usl', ,'NS')
    if m1ns_usl == 2
      js := 0
      go top
      do while !eof()
        j := 0
        select NSK
        find (str(ns->(recno()), 6))
        do while nsk->kod == ns->(recno()) .and. !eof()
          ++j
          skip
        enddo
        select NS
        G_RLock(forever)
        ns->kol := j
        js += j
        UnLock
        skip
      enddo
      if empty(js)
        m1ns_usl := 0 ; mns_usl := space(3)
      endif
    endif
    R_Use(dir_exe+'_mo_mkb',cur_dir + '_mo_mkb','MKB_10')
    R_Use(dir_server + 'mo_uch', ,'UCH')
    R_Use(dir_server + 'mo_otd', ,'OTD')
    Use_base('lusl')
    Use_base('luslc')
    Use_base('uslugi')
    R_Use(dir_server + 'uslugi1',{dir_server + 'uslugi1', ;
                                dir_server + 'uslugi1s'},'USL1')
    R_Use(dir_server + 'human_u', dir_server + 'human_u','HU')
    R_Use(dir_server + 'mo_su', ,'MOSU')
    R_Use(dir_server + 'mo_hu', dir_server + 'mo_hu','MOHU')
    set relation to u_kod into MOSU
    js := jh := jt := 0
    WaitStatus('<Esc> - прервать поиск') ; mark_keys({'<Esc>'})
    if m1schet == 1
      R_Use(dir_server + 'human_2', ,'HUMAN_2')
      R_Use(dir_server + 'human_', ,'HUMAN_')
      R_Use(dir_server + 'human',{dir_server + 'humans', ;
                                dir_server + 'humankk'},'HUMAN')
      set relation to recno() into HUMAN_, to recno() into HUMAN_2
      R_Use(dir_server + 'schet_', ,'SCHET_')
      R_Use(dir_server + 'schet', dir_server + 'schetd','SCHET')
      set relation to recno() into SCHET_
      set filter to empty(schet_->IS_DOPLATA)
      dbseek(pdate_schet[7], .t.)
      do while schet->pdate <= pdate_schet[8] .and. !eof()
        ++js
        select HUMAN
        find (str(schet->kod, 6))
        do while human->schet == schet->kod .and. !eof()
          ++jh
          @ maxrow(), 1 say lstr(js) color cColorSt2Msg
          @ row(),col() say '/' color 'W/R'
          @ row(),col() say lstr(jh) color cColorStMsg
          if jt > 0
            @ row(),col() say '/' color 'W/R'
            @ row(),col() say lstr(jt) color 'G+/R'
          endif
          UpdateStatus()
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          jt := f1proch_proverka(jt)
          select HUMAN
          skip
        enddo
        if fl_exit ; exit ; endif
        select SCHET
        skip
      enddo
    else
      R_Use(dir_server + 'human_2', ,'HUMAN_2')
      R_Use(dir_server + 'human_', ,'HUMAN_')
      R_Use(dir_server + 'human',{dir_server + 'humann', ;
                                dir_server + 'humankk'},'HUMAN')
      set relation to recno() into HUMAN_, to recno() into HUMAN_2
      dbseek('1', .t.)
      do while human->tip_h < B_SCHET .and. !eof()
        if iif(m1schet==3, empty(human_->reestr), !empty(human_->reestr)) .and. year(human->k_data) > 2017
          ++jh
          @ maxrow(), 1 say lstr(jh) color cColorStMsg
          if jt > 0
            @ row(),col() say '/' color 'W/R'
            @ row(),col() say lstr(jt) color 'G+/R'
          endif
          UpdateStatus()
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          jt := f1proch_proverka(jt)
        endif
        select HUMAN
        skip
      enddo
    endif
    j := tmp->(lastrec())
    close databases
    if fl_exit
      // ничего - просто выход
    elseif j == 0
      func_error(4, 'Проверка проведена успешно! Нарушений нет.')
    else
      mywait()
      R_Use(dir_server + 'mo_otd', ,'OTD')
      R_Use(dir_server + 'schet_', ,'SCHET_')
      R_Use(dir_server + 'schet', ,'SCHET')
      set relation to recno() into SCHET_
      R_Use(dir_server + 'human_', ,'HUMAN_')
      R_Use(dir_server + 'human', dir_server + 'humank','HUMAN')
      set relation to recno() into HUMAN_, to otd into OTD
      use (cur_dir + 'tmp') new
      set relation to str(kod, 7) into HUMAN, to schet into SCHET
      index on schet->nomer_s+str(tmp->schet, 6)+upper(left(human->fio, 20)) to (cur_dir + 'tmp')
      use (cur_dir + 'tmpk') new
      index on str(rec, 7) to (cur_dir + 'tmpk')
      fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
      add_string('')
      if m1schet == 1
        add_string(center(expand('РЕЗУЛЬТАТ ПРОВЕРКИ СЧЕТОВ'), sh))
        add_string(center(pdate_schet[4], sh))
      else
        add_string(center('РЕЗУЛЬТАТ ПРОВЕРКИ ПО НЕВЫПИСАННЫМ СЧЕТАМ'+ ;
                          iif(m1schet==2,' (по реестрам)',''), sh))
      endif
      titleN_uch(st_a_uch, sh)
      add_string('')
      old_s := 0
      select TMP
      go top
      do while !eof()
        verify_FF(HH, .t., sh)
        if !(old_s == tmp->schet)
          add_string('')
          add_string('СЧЕТ № '+rtrim(schet_->nschet))
          add_string(replicate('=', 22))
        endif
        add_string('')
        add_string(iif(m1schet == 1, lstr(human_->schet_zap)+'. ', '')+ ;
                   alltrim(human->fio)+', ' + full_date(human->date_r)+ ;
                   iif(empty(otd->SHORT_NAME), '', ' [' + alltrim(otd->SHORT_NAME)+']')+ ;
                   ' ' + date_8(human->n_data)+'-' + date_8(human->k_data))
        select TMPK
        find (str(tmp->(recno()), 7))
        do while tmpk->rec == tmp->(recno()) .and. !eof()
          add_string(space(10)+rtrim(tmpk->name))
          skip
        enddo
        old_s := tmp->schet
        select TMP
        skip
      enddo
      fclose(fp)
      close databases
      viewtext(name_file, , , , (sh > 80), , , reg_print)
    endif
  endif
  exit
enddo
close databases
restscreen(buf) ; setcolor(tmp_color)
return NIL

// 22.08.23
Function f1proch_proverka(jt)
Local i, j, k, k1, ju, fl_tmp, fl_next, arr_usl := {}, srok_l, mvid_ud, ;
      arr, s, arr_date, bd1, bd2, y, lshifr, u_1_stom := '', not_ksg := .t.
if human_->oplata < 9 .and. f_is_uch(st_a_uch, human->lpu)
  srok_l := human->k_data - human->n_data + 1
  fl_tmp := .f. ; fl_next := .t.
  // проверим правильность определения КСГ
  if human_->USL_OK < 3
    if (y := year(human->K_DATA)) > 2018
      arr := definition_KSG()
    else
      arr := definition_KSG()   // definition_KSG_18() просто подменил
    endif
    if select('K006') > 0
      k006->(dbCloseArea())
    endif
    if len(arr) == 7 // диализ
      //
    elseif !empty(arr[2])
      if !fl_tmp
        select TMP
        AddRec(6)
        if m1schet == 1
          tmp->schet := schet->(recno())
        endif
        tmp->kod := human->(recno())
        fl_tmp := .t.
      endif
      for i := 1 to len(arr[2])
        select TMPK
        AddRec(7)
        tmpk->rec := tmp->(recno())
        tmpk->name := arr[2,i]
      next
    elseif !empty(arr[3])
      select HU
      find (str(human->kod, 7))
      do while hu->kod == human->kod .and. !eof()
        usl->(dbGoto(hu->u_kod))
        if empty(lshifr := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data))
          lshifr := usl->shifr
        endif
        if alltrim(lshifr) == arr[3] // уже стоит тот же КСГ
          if !(round(hu->u_cena, 2) == round(arr[4], 2)) // не та цена
            if !fl_tmp
              select TMP
              AddRec(6)
              if m1schet == 1
                tmp->schet := schet->(recno())
              endif
              tmp->kod := human->(recno())
              fl_tmp := .t.
            endif
            select TMPK
            AddRec(7)
            tmpk->rec := tmp->(recno())
            tmpk->name := 'в л/у для КСГ='+arr[3]+' стоит цена ' + lstr(hu->u_cena, 10, 2)+', а должна быть ' + lstr(arr[4], 10, 2)
          endif
          exit
        endif
        select LUSL
        find (lshifr) // длина lshifr 10 знаков
        if found() .and. (left(lshifr, 5) == '1.12.' .or. is_ksg(lusl->shifr)) // стоит другой КСГ
          if !fl_tmp
            select TMP
            AddRec(6)
            if m1schet == 1
              tmp->schet := schet->(recno())
            endif
            tmp->kod := human->(recno())
            fl_tmp := .t.
          endif
          select TMPK
          AddRec(7)
          tmpk->rec := tmp->(recno())
          tmpk->name := 'в л/у стоит КСГ=' + alltrim(lshifr)+'(' + lstr(hu->u_cena, 10, 2)+ ;
                        '), а должна быть '+arr[3]+'(' + lstr(arr[4], 10, 2)+')'
          exit
        endif
        select HU
        skip
      enddo
    endif
  endif
  //
  if (mkol > 0 .or. m1usl_dn == 2) .and. fl_next
    arr_usl := {}
    select HU
    find (str(human->kod, 7))
    do while hu->kod == human->kod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if (i := ascan(arr_usl, {|x| x[1] == usl->shifr } )) == 0
        aadd(arr_usl, {usl->shifr, 0} ) ; i := len(arr_usl)
      endif
      arr_usl[i, 2] += hu->kol_1
      skip
    enddo
    _ju := 0
    for i := 1 to len(arr_usl)
      if mkol > 0 .and. arr_usl[i, 2] > mkol
        ++_ju
        if !fl_tmp
          select TMP
          AddRec(6)
          if m1schet == 1
            tmp->schet := schet->(recno())
          endif
          tmp->kod := human->(recno())
          fl_tmp := .t.
        endif
        select TMPK
        AddRec(7)
        tmpk->rec := tmp->(recno())
        tmpk->name := 'кол-во услуг ' + alltrim(arr_usl[i, 1])+' - ' + lstr(arr_usl[i, 2])
      endif
      if m1usl_dn == 2 .and. arr_usl[i, 2] > srok_l
        ++_ju
        if !fl_tmp
          select TMP
          AddRec(6)
          if m1schet == 1
            tmp->schet := schet->(recno())
          endif
          tmp->kod := human->(recno())
          fl_tmp := .t.
        endif
        select TMPK
        AddRec(7)
        tmpk->rec := tmp->(recno())
        tmpk->name := 'кол-во услуг ' + alltrim(arr_usl[i, 1])+':  '+ ;
                      lstr(arr_usl[i, 2])+' > ' + lstr(srok_l)+' (срока лечения)'
      endif
    next
    if _ju == 0 ; fl_next := .f. ; endif
  endif
  if m1logic == 2 ; fl_next := .t. ; endif
  //
  if fl_srok .and. fl_next
    fl := .f.
    if msrok1 > 0 .and. msrok2 == 0
      fl := (msrok1 <= srok_l)
    elseif msrok1 == 0 .and. msrok2 > 0
      fl := (srok_l <= msrok2)
    elseif msrok1 > 0 .and. msrok2 > 0
      fl := between(srok_l,msrok1,msrok2)
    endif
    if fl
      if !fl_tmp
        select TMP
        AddRec(6)
        if m1schet == 1
          tmp->schet := schet->(recno())
        endif
        tmp->kod := human->(recno())
        fl_tmp := .t.
      endif
      select TMPK
      AddRec(7)
      tmpk->rec := tmp->(recno())
      tmpk->name := 'срок лечения (в днях) - ' + lstr(srok_l)
    else
      fl_next := .f.
    endif
  endif
  if m1logic == 2 ; fl_next := .t. ; endif
  //
  if m1mkb == 2 .and. fl_next
    mdiagnoz := diag_to_array()
    s := ''
    for i := 1 to len(mdiagnoz)
      select MKB_10
      find (padr(mdiagnoz[i], 6))
      if !between_date(mkb_10->dbegin,mkb_10->dend, human->k_data)
        s += alltrim(mdiagnoz[i])+' '
      endif
    next
    if !empty(s)
      if !fl_tmp
        select TMP
        AddRec(6)
        if m1schet == 1
          tmp->schet := schet->(recno())
        endif
        tmp->kod := human->(recno())
        fl_tmp := .t.
      endif
      select TMPK
      AddRec(7)
      tmpk->rec := tmp->(recno())
      tmpk->name := 'диагноз не входит в ОМС: '+s
    else
      fl_next := .f.
    endif
  endif
  if m1logic == 2 ; fl_next := .t. ; endif
  //
  if m1ns_usl == 2 .and. fl_next
    // сначала проверим данный случай
    arr_usl := {} ; arr_date := {}
    select HU
    find (str(human->kod, 7))
    do while hu->kod == human->kod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if (i := ascan(arr_usl,{|x| x[1]==usl->shifr .and. x[2]==hu->date_u})) == 0
        aadd(arr_usl,{usl->shifr,hu->date_u, 0}) ; i := len(arr_usl)
      endif
      arr_usl[i, 3] += hu->kol_1
      if ascan(arr_date,hu->date_u) == 0
        aadd(arr_date,hu->date_u)
      endif
      skip
    enddo
    if m1ns1usl == 2  // теперь проверим остальные случаи
      select HUMAN
      rec_human := human->(recno())
      bd1 := human->n_data ; bd2 := human->k_data
      mkod_k := human->kod_k
      set order to 2
      //
      find (str(mkod_k, 7))
      do while human->kod_k == mkod_k .and. !eof()
        if rec_human != human->(recno()) ; // текущий случай пропускаем
           .and. human->n_data <= bd2 .and. bd1 <= human->k_data // и диапазон лечения частично перекрывается
          select HU
          find (str(human->kod, 7))
          do while hu->kod == human->kod .and. !eof()
            usl->(dbGoto(hu->u_kod))
            if (i := ascan(arr_usl,{|x| x[1]==usl->shifr .and. x[2]==hu->date_u})) > 0
              arr_usl[i, 3] += hu->kol_1
            endif
            skip
          enddo
        endif
        select HUMAN
        skip
      enddo
      select HUMAN
      set order to 1
      goto (rec_human)
    endif
    k1 := 0
    select NS
    go top
    do while !eof()
      for i := 1 to len(arr_date)
        k := 0
        if ns->kol == 1
          select NSK
          find (str(ns->(recno()), 6))
          if (j := ascan(arr_usl,{|x| x[1]==nsk->shifr .and. x[2]==arr_date[i]})) > 0
            k := arr_usl[j, 3]
          endif
        else
          select NSK
          find (str(ns->(recno()), 6))
          do while nsk->kod == ns->(recno()) .and. !eof()
            if ascan(arr_usl,{|x| x[1]==nsk->shifr .and. x[2]==arr_date[i]}) > 0
              ++k
            endif
            skip
          enddo
        endif
        if k > 1
          ++k1
          if !fl_tmp
            select TMP
            AddRec(6)
            if m1schet == 1
              tmp->schet := schet->(recno())
            endif
            tmp->kod := human->(recno())
            fl_tmp := .t.
          endif
          select TMPK
          AddRec(7)
          tmpk->rec := tmp->(recno())
          tmpk->name := 'несовместимость услуг по дате: '+dtoc(c4tod(arr_date[i]))+' ' + alltrim(ns->name)
        endif
      next
      select NS
      skip
    enddo
    if k1 == 0
      fl_next := .f.
    endif
  endif
  if m1logic == 2 ; fl_next := .t. ; endif
  //
  if m1pervich == 2 .and. fl_next
    k1 := 0
    // сначала проверим данный случай
    select HU
    find (str(human->kod, 7))
    do while hu->kod == human->kod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
      if is_usluga_TFOMS(usl->shifr,lshifr1, human->k_data)
        lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
        if f_is_1_stom(lshifr)
          u_1_stom := lshifr ; exit
        endif
      endif
      select HU
      skip
    enddo
    if !empty(u_1_stom)  // теперь проверим остальные случаи
      select HUMAN
      rec_human := human->(recno())
      d2_year := year(human->k_data)
      m1novor := human_->NOVOR
      mkod_k := human->kod_k
      set order to 2
      //
      find (str(mkod_k, 7))
      do while human->kod_k == mkod_k .and. !eof()
        if (fl := (d2_year==year(human->k_data) .and. rec_human!=human->(recno())))
          //
        endif
        if fl .and. human->schet > 0 .and. eq_any(human_->oplata, 2, 9)
          fl := .f. // лист учёта снят по акту или выставлен повторно
        endif
        if fl .and. m1novor != human_->NOVOR
          fl := .f. // лист учёта на новорожденного (или наоборот)
        endif
        if fl .and. human_->idsp == 4 // лечебно-диагностическая процедура
          select HU
          find (str(human->kod, 7))
          do while hu->kod == human->kod .and. !eof()
            usl->(dbGoto(hu->u_kod))
            lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
            if is_usluga_TFOMS(usl->shifr,lshifr1, human->k_data)
              lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
              if f_is_1_stom(lshifr)
                ++k1
                if !fl_tmp
                  select TMP
                  AddRec(6)
                  if m1schet == 1
                    tmp->schet := schet->(recno())
                  endif
                  tmp->kod := human->(recno())
                  fl_tmp := .t.
                endif
                select TMPK
                AddRec(7)
                tmpk->rec := tmp->(recno())
                tmpk->name := 'перв.стом.приём '+u_1_stom+', и в случае ' + date_8(human->n_data)+'-' + date_8(human->k_data)+': '+lshifr
              endif
            endif
            select HU
            skip
          enddo
        endif
        select HUMAN
        skip
      enddo
      select HUMAN
      set order to 1
      goto (rec_human)
    endif
    if k1 == 0
      fl_next := .f.
    endif
  endif
  //
  if fl_tmp
    if m1logic == 1 .and. !fl_next
      if m1schet == 1
        k := schet->(recno())
      else
        k := 0
      endif
      select TMP
      find (str(k, 6)+str(human->(recno()), 7))
      if found()
        select TMPK
        do while .t.
          find (str(tmp->(recno()), 7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        select TMP
        DeleteRec()
      endif
    else
      if ++jt % 2000 == 0
        Commit
      endif
    endif
  endif
endif
return jt

//
Function o_pr_vr_as(reg)
  Static sj := 1
  Local mas_pmt := {'Проверка по ~невыписанным счетам', ;
                  'Проверка по дате ~выписки счета'}
  Local mas_msg := {'Проверка на отсутствие кода по невыписанным счетам', ;
                  'Проверка на отсутствие кода по дате выписки счета'}
  Local i, j, k, arr, fl, fl_exit := .f., buf := save_maxrow(), ;
      s, sh, HH := 57, arr_title, name_file := cur_dir + 'proverka' + stxt, ;
      arr_usl := {}, lcount_uch

  if (st_a_uch := inputN_uch(T_ROW, T_COL - 5, , , @lcount_uch)) == NIL
    return NIL
  endif
  if (j := popup_prompt(T_ROW, T_COL - 5, sj, mas_pmt, mas_msg)) == 0
    return NIL
  endif
  sj := j
  if j == 2 .and. (arr := year_month()) == NIL
    return NIL
  endif
  if (k := f_alert({'Каким образом производить проверку на отсутствие кодов персонала.', ;
                  'Выберите действие:'}, ;
                 {' По ~всем услугам ', ;
                  ' ~Исключая некоторые услуги '}, ;
                 1, 'N+/BG', 'R/BG', , , col1menu )) == 0
    return NIL
  elseif k == 2
    dbcreate(cur_dir + 'tmp', { ;
        {'U_KOD'  ,    'N',      4,      0}, ;  // код услуги
        {'U_SHIFR',    'C',     10,      0}, ;  // шифр услуги
        {'U_NAME',     'C',     65,      0}})  // наименование услуги
    use (cur_dir + 'tmp')
    index on str(u_kod, 4) to (cur_dir + 'tmpk')
    index on fsort_usl(u_shifr) to (cur_dir + 'tmpn')
    close databases
    ob2_v_usl()
    use (cur_dir + 'tmp')
    dbeval({|| aadd(arr_usl, tmp->u_kod) } )
    use
  endif
  WaitStatus('<Esc> - прервать поиск')
  mark_keys({'<Esc>'})
  dbcreate(cur_dir + 'tmp', {{'rec', 'N', 7, 0}})
  use (cur_dir + 'tmp') new
  if j == 1
    R_Use(dir_server + 'human_u', dir_server + 'human_u', 'HU')
    R_Use(dir_server + 'human_', , 'HUMAN_')
    R_Use(dir_server + 'human', dir_server + 'humann', 'HUMAN')
    set relation to recno() into HUMAN_
    dbseek('1', .t.)
    do while human->tip_h < B_SCHET .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t.
        exit
      endif
      if human_->oplata < 9 .and. f_is_uch(st_a_uch, human->lpu)
        fl := .f.
        select HU
        find (str(human->kod, 7))
        do while hu->kod == human->kod .and. !eof()
          if ascan(arr_usl, hu->u_kod) == 0
            if reg == 1
              if hu->kod_vr == 0
                fl := .t.
                exit
              endif
            else
              if hu->kod_as == 0
                fl := .t.
                exit
              endif
            endif
          endif
          select HU
          skip
        enddo
        if fl
          select TMP
          append blank
          tmp->rec := human->(recno())
        endif
      endif
      select HUMAN
      skip
    enddo
  elseif j == 2
    R_Use(dir_server + 'human_u', dir_server + 'human_u', 'HU')
    R_Use(dir_server + 'human_', , 'HUMAN_')
    R_Use(dir_server + 'human', dir_server + 'humans', 'HUMAN')
    set relation to recno() into HUMAN_
    R_Use(dir_server + 'schet_', , 'SCHET_')
    R_Use(dir_server + 'schet', dir_server + 'schetd', 'SCHET')
    set relation to recno() into SCHET_
    set filter to empty(schet_->IS_DOPLATA)
    dbseek(arr[7], .t.)
    do while schet->pdate <= arr[8] .and. !eof()
      select HUMAN
      find (str(schet->kod, 6))
      do while human->schet == schet->kod .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t.
          exit
        endif
        if human_->oplata < 9 .and. f_is_uch(st_a_uch, human->lpu)
          fl := .f.
          select HU
          find (str(human->kod, 7))
          do while hu->kod == human->kod .and. !eof()
            if ascan(arr_usl, hu->u_kod) == 0
              if reg == 1
                if hu->kod_vr == 0
                  fl := .t.
                  exit
                endif
              else
                if hu->kod_as == 0
                  fl := .t.
                  exit
                endif
              endif
            endif
            select HU
            skip
          enddo
          if fl
            select TMP
            append blank
            tmp->rec := human->(recno())
          endif
        endif
        select HUMAN
        skip
      enddo
      if fl_exit
        exit
      endif
      select SCHET
      skip
    enddo
    select SCHET
    set index to
  endif
  if tmp->(lastrec()) > 0
    mywait()
    s := {'Отделение', 'Номер и дата счета'}[j]
    arr_title := { ;
      '─────────────────────────────────────────────────┬───────────────────┬──────────', ;
      '              Ф.И.О. больного                    │'   +padc(s, 19)+  '│  Сумма   ', ;
      '─────────────────────────────────────────────────┴───────────────────┴──────────'}
    sh := len(arr_title[1])
    fp := fcreate(name_file)
    tek_stroke := 0
    n_list := 1
    add_string('')
    add_string(center('Список больных, у которых в оказанных услугах', sh))
    add_string(center('отсутствует код ' + {'врача', 'ассистента'}[reg], sh))
    add_string('')
    if j == 1
      add_string(center('[ по невыписанным счетам ]', sh))
    else
      add_string(center('[ по дате выписки счета ]', sh))
      add_string(center(arr[4], sh))
    endif
    titleN_uch(st_a_uch, sh, lcount_uch)
    add_string('')
    aeval(arr_title, {|x| add_string(x) } )
    //
    select HUMAN
    set index to
    R_Use(dir_server + 'mo_otd', , 'OTD')
    select TMP
    set relation to rec into HUMAN
    index on upper(human->fio) to (cur_dir + 'tmp')
    go top
    i := 0
    do while !eof()
      s := str(++i, 4) + '. ' + left(human->fio, 43) + ' '
      if j == 1
        select OTD
        goto (human->otd)
        s += otd->short_name
      else
        select SCHET
        goto (human->schet)
        s += schet_->NSCHET + ' ' + date_8(schet_->DSCHET)
      endif
      if verify_FF(HH, .t., sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s + put_kopE(human->cena_1, 11))
      select TMP
      skip
    enddo
    close databases
    fclose(fp)
    viewtext(name_file, , , , .f., , , 2)
  else
    func_error(4, 'Не обнаружено услуг с незанесенным персоналом!')
  endif
  close databases
  rest_box(buf)
  return NIL

// Вывод списка принятых больных конкретным врачом за день
Function i_vr_boln()
  Local sh := 80, HH := 60, old_d := '', begin_date, end_date, arr_m, ;
      name_file := cur_dir + 'lech_vr' + stxt, i, j, s, skol := 0, ab := {}

  if (arr_m := year_month()) == NIL
    return NIL
  endif
  if !input_perso(T_ROW, T_COL - 5)
    return NIL
  endif
  begin_date := arr_m[7]
  end_date   := arr_m[8]
  fp := fcreate(name_file)
  tek_stroke := 0
  n_list := 1
  s := ' Ф.И.О. и должность врача: ' + alltrim(glob_human[2]) + ' [' + lstr(glob_human[5]) + ']'
  if len(glob_human) > 5 .and. !empty(glob_human[6])
    s += ' (' + glob_human[6] + ')'       // должность
  endif
  add_string(center(s, sh))
  add_string(center(arr_m[4], sh))
  add_string('')
  R_Use(dir_server + 'uslugi', , 'USL')
  R_Use(dir_server + 'human_', , 'HUMAN_')
  R_Use(dir_server + 'human', , 'HUMAN')
  set relation to recno() into HUMAN_
  R_Use(dir_server + 'human_u', dir_server + 'human_uv', 'HU')
  dbseek(str(glob_human[1], 4) + begin_date, .t.)
  do while hu->kod_vr == glob_human[1] .and. hu->date_u <= end_date .and. !eof()
    human->(dbGoto(hu->kod))
    if human_->oplata < 9
      if !(old_d == hu->date_u)
        if !empty(old_d)
          for i := 1 to len(ab)
            s := str(i, 5) + '. ' + alltrim(ab[i, 2]) + ' ('
            for j := 1 to len(ab[i, 3])
              usl->(dbGoto(ab[i, 3, j]))
              s += alltrim(usl->shifr) + ','
            next
            s := left(s, len(s) - 1) + ')'
            verify_FF(HH, .t., sh)
            add_string(s)
            ++skol
          next
        endif
        verify_FF(HH - 1, .t., sh)
        old_d := hu->date_u
        ab := {}
        add_string(full_date(c4tod(old_d)))
      endif
      if (i := ascan(ab, {|x| x[1] == human->kod_k})) == 0
        aadd(ab, {human->kod_k, human->fio,{}})
        i := len(ab)
      endif
      if (j := ascan(ab[i, 3], hu->u_kod)) == 0
        aadd(ab[i, 3], hu->u_kod)
      endif
    endif
    select HU
    skip
  enddo
  if !empty(old_d)
    for i := 1 to len(ab)
      s := str(i, 5) + '. ' + alltrim(ab[i, 2]) + ' ('
      for j := 1 to len(ab[i, 3])
        usl->(dbGoto(ab[i, 3, j]))
        s += alltrim(usl->shifr) + ','
      next
      s := left(s, len(s) - 1) + ')'
      verify_FF(HH, .t., sh)
      add_string(s)
      ++skol
    next
  endif
  if skol > 0
    add_string('Всего больных: ' + lstr(skol))
  endif
  fclose(fp)
  close databases
  viewtext(name_file, , , , .t., , , 2)
  return NIL

// 14.05.13 Поиск одинаковых сочетаний номера карты вызова + даты вызова
Function posik_smp_n_d()
  ne_real()
  /*
  Local i, j, k, arr, s, buf := save_maxrow(), fl_exit := .f., sh := 65, ;
      old_f, old_n, old_d, HH := 80, reg_print := 1, ;
      name_file := cur_dir + 'smp_n_d' + stxt

  if (arr_m := year_month()) == NIL
    return NIL
  endif
  mywait()
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string('')
  add_string(center('Поиск повторов номера карты вызова (за день)', sh))
  add_string(center(arr_m[4], sh))
  add_string('')
  dbcreate(cur_dir + 'tmp',{{'uch_doc','C', 10, 0}})
  use (cur_dir + 'tmp') new
  R_Use(dir_server + 'mo_otd', ,'OTD')
  R_Use(dir_server + 'human_', ,'HUMAN_')
  R_Use(dir_server + 'human', dir_server + 'humand','HUMAN')
  set relation to recno() into HUMAN_
  old_f := replicate('-', 50)
  old_n := replicate('-', 10)
  old_d := arr_m[5] - 1
  dbseek(dtos(arr_m[5]), .t.)
  do while human->k_data <= arr_m[6] .and. !eof()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if human_->usl_ok == 4
      if old_d == human->k_data .and. old_n == human->uch_doc
        add_string(''' + alltrim(old_n)+'' от ' + date_8(old_d)+' ' + alltrim(old_f))
      endif
      add_string(''' + alltrim(cuch_doc)+'' от ' + date_8(old_d)+' ' + alltrim(human->fio))
      d1 := human->n_data ; d2 := human->k_data ; cuch_doc := human->uch_doc
      d2_year := year(d2)
      cd1 := dtoc4(d1) ; cd2 := dtoc4(d2)
      //
      if human_->usl_ok == 4 // если 'скорая помощь'
        select HUMAN
        set order to 3
        find (dtos(d2)+cuch_doc)
        do while human->k_data == d2 .and. cuch_doc == human->uch_doc .and. !eof()
          if human_->usl_ok == 4 .and. glob_kartotek == human->kod_k ;
                           .and. rec_human != human->(recno())
          endif
          skip
        enddo
      endif
      select HUMAN
      skip
    enddo
  else
    close databases
  if fl_exit
    add_string(expand('ПРОЦЕСС ПРЕРВАН'))
  endif
  fclose(fp)
  rest_box(buf)
  if kol_err > 0
    viewtext(Devide_Into_Pages(name_file, 80, 80), , , , (sh > 80), , , reg_print)
  else
    n_message({'','Повторов не обнаружено!'})
  endif*/
  return NIL

// 27.10.13
Function poisk_rassogl()
  Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
      fl_exit := .f., sh := 80, HH := 80, reg_print := 5, pi1, fl_parakl, ;
      name_file := cur_dir + 'rassogl' + stxt, lcount_uch, sschet

  if (arr_m := year_month()) == NIL
    return NIL
  endif
  if (pi1 := popup_prompt(T_ROW, T_COL - 5, 2, ;
            {'По дате ~окончания лечения', 'По дате ~выписки счета'})) == 0
  return NIL
  endif
  mywait()
  Private kol_err := 0
  fp := fcreate(name_file)
  tek_stroke := 0
  n_list := 1
  add_string('')
  add_string(center('Обнаруженные рассогласования в базах данных', sh))
  add_string(center(arr_m[4], sh))
  R_Use(dir_server + 'mo_uch', , 'UCH')
  R_Use(dir_server + 'mo_otd', , 'OTD')
  R_Use(dir_server + 'uslugi', , 'USL')
  R_Use(dir_server + 'human_u', dir_server + 'human_u', 'HU')
  set relation to u_kod into USL
  if pi1 == 1 // по дате окончания лечения
    begin_date := arr_m[5]
    end_date := arr_m[6]
    R_Use(dir_server + 'schet_', , 'SCHET_')
    R_Use(dir_server + 'schet', , 'SCHET')
    set relation to recno() into SCHET_
    R_Use(dir_server + 'human_', , 'HUMAN_')
    R_Use(dir_server + 'human', dir_server + 'humand', 'HUMAN')
    set relation to schet into SCHET, to recno() into HUMAN_
    dbseek(dtos(begin_date), .t.)
    do while human->k_data <= end_date .and. !eof()
      if inkey() == K_ESC
        fl_exit := .t.
        exit
      endif
      if human_->oplata < 9
        f1_poisk_rassogl()
      endif
      select HUMAN
      skip
    enddo
  else
    begin_date := arr_m[7]
    end_date := arr_m[8]
    R_Use(dir_server + 'human_', , 'HUMAN_')
    R_Use(dir_server + 'human', dir_server + 'humans', 'HUMAN')
    set relation to recno() into HUMAN_
    R_Use(dir_server + 'schet_', , 'SCHET_')
    R_Use(dir_server + 'schet', dir_server + 'schetd', 'SCHET')
    set relation to recno() into SCHET_
    set filter to empty(schet_->IS_DOPLATA)
    dbseek(begin_date, .t.)
    do while schet->pdate <= end_date .and. !eof()
      sschet := 0
      select HUMAN
      find (str(schet->kod, 6))
      do while human->schet == schet->kod .and. !eof()
        if inkey() == K_ESC
          fl_exit := .t.
          exit
        endif
        if human_->oplata < 9
          f1_poisk_rassogl()
        endif
        sschet += human->cena_1
        select HUMAN
        skip
      enddo
      if fl_exit
        exit
      endif
      if !(round(sschet, 2) == round(schet->summa, 2))
        ++kol_err
        add_string('Счет № ' + alltrim(schet_->NSCHET) + ;
                  ' от ' + full_date(schet_->DSCHET) + 'г.')
        add_string(space(2)+'сумма случаев не равна сумме счёта ' + lstr(sschet, 2)+'!=' + lstr(schet->summa, 2))
      endif
      select SCHET
      skip
    enddo
  endif
  close databases
  if fl_exit
    add_string(expand('ПРОЦЕСС ПРЕРВАН'))
  endif
  fclose(fp)
  rest_box(buf)
  if kol_err > 0
    viewtext(Devide_Into_Pages(name_file, 80, 80), , , , (sh > 80), , , reg_print)
  else
    n_message({'', 'Рассогласований не обнаружено!'})
  endif
  return NIL

// 17.10.23
Function f1_poisk_rassogl()
  Static sd20120301
  Local i := 0, ss := 0, fl
  Local aerr := { ;
    {'не проставлено учреждение в случае', 0, 0}, ;
    {'не найдено учреждение с кодом', 0, 0}, ;
    {'не проставлено отделение в случае', 0, 0}, ;
    {'не найдено отделение с кодом', 0, 0}, ;
    {'в случае стоит не то учреждение для отделения с кодом', 0, 0}, ;
    {'не проставлено отделение в услугах', 0, 0}, ;
    {'учреждение в случае не равно учреждению в услуге', 0, 0}, ;
    {'услуга не попадает в сроки лечения', 0, 0}, ;
    {'сумма услуг не равна сумма случая', 0, 0};
  }

  DEFAULT sd20120301 TO stod('20120301')
  if human->lpu <= 0
    aerr[1, 2] := 1
  else
    select UCH
    dbGoto(human->lpu)
    if eof() .or. uch->kod != human->lpu
      aerr[2, 2] := 1
      aerr[2, 3] := human->lpu
    endif
  endif
  if human->otd <= 0
    aerr[3, 2] := 1
  else
    select OTD
    dbGoto(human->otd)
    if eof() .or. otd->kod != human->otd
      aerr[4, 2] := 1
      aerr[4, 3] := human->otd
    elseif otd->kod_lpu != human->lpu
      aerr[5, 2] := 1
      aerr[5, 3] := human->otd
    endif
  endif
  select HU
  find (str(human->kod, 7))
  do while hu->kod == human->kod .and. !eof()
    if hu->otd <= 0
      aerr[6, 2] := 1
    endif
    if human->ishod < 100 .and. !between(c4tod(hu->date_u), human->n_data, human->k_data)
      aerr[8, 2] := 1
      aerr[8, 3] := c4tod(hu->date_u)
    endif
    /*otd->(dbGoto(hu->otd))
    if otd->kod_lpu != human->lpu
      aerr[7, 2] := human->lpu ; aerr[7, 3] := otd->kod_lpu ; exit
    endif*/
    if human->k_data < sd20120301
      fl := f_paraklinika(usl->shifr, usl->shifr1, c4tod(hu->date_u))
    else
      fl := f_paraklinika(usl->shifr, usl->shifr1, human->k_data)
    endif
    if fl ;
        .and. hu->kod_vr <> 0 // добавил проверку на пустого врача для углубленной диспансеризации после COVID-19
      ss += hu->stoim_1
    endif
    select HU
    skip
  enddo
  if !(round(ss, 2) == round(human->cena_1, 2))
    if round(ss, 2) == 1280.30 .and. round(human->cena_1, 2) == 771.40
      //
    elseif round(ss, 2) == 1280.30 .and. round(human->cena_1, 2) == 1216.60
      //
    else
      aerr[9, 2] := human->cena_1
      aerr[9, 3] := ss
    endif  
  endif
  aeval(aerr,{|x| i += x[2] })

  if i > 0 
    ++kol_err
    add_string('')
    if human->schet > 0
      add_string('Счет № ' + alltrim(schet_->NSCHET)+ ;
                  ' от ' + full_date(schet_->DSCHET) + 'г.')
    endif
    add_string(lstr(human->kod) + ' ' + alltrim(human->fio) + ', ' + ;
             left(dtoc(human->n_data), 5) + '-' + date_8(human->k_data) + 'г.')
    for i := 1 to len(aerr)
      if !empty(aerr[i, 2])
        s := space(2) + aerr[i, 1] + ' '
        do case
          case i == 1  // не проставлено учреждение в случае', 0, 0}, ;
            //
          case i == 2  // не найдено учреждение с кодом', 0, 0}, ;
            s += lstr(aerr[i, 3])
          case i == 3  // не проставлено отделение в случае', 0, 0}, ;
            //
          case i == 4  // не найдено отделение с кодом', 0, 0}, ;
            s += lstr(aerr[i, 3])
          case i == 5  // в случае стоит не то учреждение для отделения с кодом', 0, 0}, ;
            s += lstr(aerr[i, 3])
          case i == 6  // не проставлено отделение в услугах', 0, 0}, ;
            //
          case i == 7  // учреждение в случае не равно учреждению в услуге', 0, 0}, ;
            s += lstr(aerr[i, 2]) + '=' + lstr(aerr[i, 3])
          case i == 8  // услуга не попадает в сроки лечения', 0, 0}, ;
            s += full_date(aerr[i, 3])
          case i == 9  // сумма услуг не равна сумма случая', 0, 0};
            s += lstr(aerr[i, 2]) + '=' + lstr(aerr[i, 3])
        endcase
        add_string(s)
      endif
    next
  endif
  return NIL
