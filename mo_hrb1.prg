***** mo_hrb1.prg - старые функции
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 04.09.13 Журнал регистрации новых больных
Function i_new_boln()
Local arr_m, fl, ldate, buf := save_maxrow()
if (arr_m := year_month()) != NIL
  mywait()
  //
  dbcreate(cur_dir+"tmp",{{"is","N",1,0},;
                  {"kod_k","N",7,0},;
                  {"task","N",1,0},;
                  {"uch","N",3,0},;
                  {"otd","N",3,0},;
                  {"data","D",8,0},;
                  {"KOD_P","C",1,0}}) // код пользователя, добавившего л/у
  use (cur_dir+"tmp") new
  index on str(kod_k,7) to (cur_dir+"tmp")
  if is_task(X_REGIST)
    WaitStatus("Подзадача РЕГИСТРАТУРА")
    R_Use(dir_server+"mo_regi",dir_server+"mo_regi2","REGI")
    //index on pdate to (dir_server+"mo_regi2") progress
    dbseek(arr_m[7],.t.)
    do while regi->pdate <= arr_m[8] .and. !eof()
      UpdateStatus()
      fl := .f.
      select TMP
      find (str(regi->kod_k,7))
      if found()
        if c4tod(regi->pdate) < tmp->data
          fl := .t.
        endif
      else
        append blank
        tmp->is := 1
        tmp->kod_k := regi->kod_k
        fl := .t.
      endif
      if fl
        tmp->task := X_REGIST
        tmp->uch := regi->tip
        tmp->otd := regi->op
        tmp->data := c4tod(regi->pdate)
        tmp->KOD_P := regi->kod_p
      endif
      select REGI
      skip
    enddo
    regi->(dbCloseArea())
  endif
  if is_task(X_PPOKOJ)
    WaitStatus("Подзадача ПРИЁМНЫЙ ПОКОЙ")
    R_Use(dir_server+"mo_pp",dir_server+"mo_pp_d","PP")
    //index on dtos(n_data)+n_time to (dir_server+"mo_pp_d") progress
    dbseek(dtos(arr_m[5]),.t.)
    do while pp->n_data <= arr_m[6] .and. !eof()
      UpdateStatus()
      fl := .f.
      select TMP
      find (str(pp->kod_k,7))
      if found()
        if pp->n_data < tmp->data
          fl := .t.
        endif
      else
        append blank
        tmp->is := 1
        tmp->kod_k := pp->kod_k
        fl := .t.
      endif
      if fl
        tmp->task := X_PPOKOJ
        tmp->uch := pp->lpu
        tmp->otd := pp->otd
        tmp->data := pp->n_data
        tmp->KOD_P := pp->kod_p
      endif
      select PP
      skip
    enddo
    pp->(dbCloseArea())
  endif
  if is_task(X_PLATN)
    WaitStatus("Подзадача ПЛАТНЫЕ УСЛУГИ")
    R_Use(dir_server+"hum_p",dir_server+"hum_pd","PLAT")
    //index on dtos(k_data) to (dir_server+"hum_pd") progress
    dbseek(dtos(addmonth(arr_m[5],-6)),.t.)
    index on dtos(n_data) to (cur_dir+"tmp_plat") ;
          for between(n_data,arr_m[5],arr_m[6]) ;
          while k_data <= arr_m[6]
    go top
    do while !eof()
      UpdateStatus()
      fl := .f.
      select TMP
      find (str(plat->kod_k,7))
      if found()
        if plat->n_data < tmp->data
          fl := .t.
        endif
      else
        append blank
        tmp->is := 1
        tmp->kod_k := plat->kod_k
        fl := .t.
      endif
      if fl
        tmp->task := X_PLATN
        tmp->uch := plat->lpu
        tmp->otd := plat->otd
        tmp->data := plat->n_data
        tmp->KOD_P := chr(plat->KOD_OPER)
      endif
      select PLAT
      skip
    enddo
    plat->(dbCloseArea())
    if is_task(X_KASSA)
      R_Use(dir_server+"kas_pl",dir_server+"kas_pl2","KP")
      //index on dtos(k_data) to (dir_server+"kas_pl2") progress
      dbseek(dtos(arr_m[5]),.t.)
      do while kp->k_data <= arr_m[6] .and. !eof()
        UpdateStatus()
        fl := .f.
        select TMP
        find (str(kp->kod_k,7))
        if found()
          if kp->k_data < tmp->data
            fl := .t.
          endif
        else
          append blank
          tmp->is := 1
          tmp->kod_k := kp->kod_k
          fl := .t.
        endif
        if fl
          tmp->task := X_KASSA
          tmp->data := kp->k_data
          tmp->KOD_P := chr(kp->KOD_OPER)
        endif
        select KP
        skip
      enddo
      kp->(dbCloseArea())
    endif
  endif
  if is_task(X_ORTO)
    R_Use(dir_server+"hum_ort",dir_server+"hum_ortd","ORT")
    //index on dtos(k_data) to (dir_server+"hum_ortd") progress
    dbseek(dtos(addmonth(arr_m[5],-6)),.t.)
    index on dtos(n_data) to (cur_dir+"tmp_ort") ;
          for between(n_data,arr_m[5],arr_m[6]) ;
          while k_data <= arr_m[6]
    go top
    do while !eof()
      UpdateStatus()
      fl := .f.
      select TMP
      find (str(ort->kod_k,7))
      if found()
        if ort->n_data < tmp->data
          fl := .t.
        endif
      else
        append blank
        tmp->is := 1
        tmp->kod_k := ort->kod_k
        fl := .t.
      endif
      if fl
        tmp->task := X_ORTO
        tmp->uch := ort->lpu
        tmp->otd := ort->otd
        tmp->data := ort->n_data
      endif
      select ORT
      skip
    enddo
    ort->(dbCloseArea())
    if is_task(X_KASSA)
      R_Use(dir_server+"kas_ort",dir_server+"kas_ort2","KP")
      //index on dtos(k_data) to (dir_server+"kas_ort2") progress
      dbseek(dtos(arr_m[5]),.t.)
      do while kp->k_data <= arr_m[6] .and. !eof()
        UpdateStatus()
        fl := .f.
        select TMP
        find (str(kp->kod_k,7))
        if found()
          if kp->k_data < tmp->data
            fl := .t.
          endif
        else
          append blank
          tmp->is := 1
          tmp->kod_k := kp->kod_k
          fl := .t.
        endif
        if fl
          tmp->task := X_KASSA
          tmp->data := kp->k_data
          tmp->KOD_P := chr(kp->KOD_OPER)
        endif
        select KP
        skip
      enddo
      kp->(dbCloseArea())
    endif
  endif
  WaitStatus("Подзадача ОМС")
  R_Use(dir_server+"human",dir_server+"humand","OMS")
  //index on dtos(k_data)+uch_doc to (dir_server+"humand") progress
  dbseek(dtos(addmonth(arr_m[5],-6)),.t.)
  index on dtos(n_data) to (cur_dir+"tmp_oms") ;
        for between(n_data,arr_m[5],arr_m[6]) ;
        while k_data <= arr_m[6]
  go top
  do while !eof()
    UpdateStatus()
    fl := .f.
    select TMP
    find (str(oms->kod_k,7))
    if found()
      if oms->n_data <= tmp->data
        fl := .t.
      endif
    else
      append blank
      tmp->is := 1
      tmp->kod_k := oms->kod_k
      fl := .t.
    endif
    if fl
      tmp->task := X_OMS
      tmp->uch := oms->lpu
      tmp->otd := oms->otd
      tmp->data := oms->n_data
      tmp->KOD_P := oms->kod_p
    endif
    select OMS
    skip
  enddo
  select OMS
  set index to (dir_server+"humankk")
  select TMP
  go top
  do while !eof()
    UpdateStatus()
    if tmp->is == 1
      select OMS
      find (str(tmp->kod_k,7))
      do while oms->kod_k == tmp->kod_k .and. !eof()
        if oms->n_data < tmp->data
          tmp->is := 0 ; exit
        endif
        select OMS
        skip
      enddo
    endif
    select TMP
    skip
  enddo
  oms->(dbCloseArea())
  if is_task(X_PPOKOJ)
    R_Use(dir_server+"mo_pp",dir_server+"mo_pp_r","PP")
    select TMP
    go top
    do while !eof()
      UpdateStatus()
      if tmp->is == 1
        select PP
        find (str(tmp->kod_k,7))
        do while pp->kod_k == tmp->kod_k .and. pp->n_data < arr_m[6] .and. !eof()
          if pp->n_data < tmp->data
            tmp->is := 0 ; exit
          endif
          select PP
          skip
        enddo
      endif
      select TMP
      skip
    enddo
    pp->(dbCloseArea())
  endif
  if is_task(X_PLATN)
    R_Use(dir_server+"hum_p",dir_server+"hum_pkk","PLAT")
    select TMP
    go top
    do while !eof()
      UpdateStatus()
      if tmp->is == 1
        select PLAT
        find (str(tmp->kod_k,7))
        do while plat->kod_k == tmp->kod_k .and. !eof()
          if plat->n_data < tmp->data
            tmp->is := 0 ; exit
          endif
          select PLAT
          skip
        enddo
      endif
      select TMP
      skip
    enddo
    plat->(dbCloseArea())
    if is_task(X_KASSA)
      R_Use(dir_server+"kas_pl",dir_server+"kas_pl1","KP")
      select TMP
      go top
      do while !eof()
        UpdateStatus()
        if tmp->is == 1
          select KP
          find (str(tmp->kod_k,7))
          do while kp->kod_k == tmp->kod_k .and. !eof()
            if kp->k_data < tmp->data
              tmp->is := 0 ; exit
            endif
            select KP
            skip
          enddo
        endif
        select TMP
        skip
      enddo
      kp->(dbCloseArea())
    endif
  endif
  if is_task(X_ORTO)
    R_Use(dir_server+"hum_ort",dir_server+"hum_ortk","ORT")
    select TMP
    go top
    do while !eof()
      UpdateStatus()
      if tmp->is == 1
        select ORT
        find (str(tmp->kod_k,7))
        do while ort->kod_k == tmp->kod_k .and. !eof()
          if ort->n_data < tmp->data
            tmp->is := 0 ; exit
          endif
          select ORT
          skip
        enddo
      endif
      select TMP
      skip
    enddo
    ort->(dbCloseArea())
    if is_task(X_KASSA)
      R_Use(dir_server+"kas_ort",dir_server+"kas_ort1","KP")
      select TMP
      go top
      do while !eof()
        UpdateStatus()
        if tmp->is == 1
          select KP
          find (str(tmp->kod_k,7))
          do while kp->kod_k == tmp->kod_k .and. !eof()
            if kp->k_data < tmp->data
              tmp->is := 0 ; exit
            endif
            select KP
            skip
          enddo
        endif
        select TMP
        skip
      enddo
      kp->(dbCloseArea())
    endif
  endif
  WaitStatus("Новые пациенты")
  R_Use(dir_server+"kartote2",,"KART2")
  index on pc1 to (cur_dir+"tmpkart2") for !empty(pc1) .and. between(substr(pc1,2,4),arr_m[7],arr_m[8])
  go top
  do while !eof()
    UpdateStatus()
    ldate := c4tod(substr(pc1,2,4))
    select TMP
    find (str(kart2->(recno()),7))
    if !found()
      append blank
      tmp->kod_k := kart2->(recno())
      tmp->task := X_REGIST
      tmp->data := ldate
    endif
    tmp->is := 2
    if ldate <= tmp->data
      tmp->data := ldate
      tmp->uch := 1 // т.е. печатать отделение, если есть
    endif
    tmp->KOD_P := left(kart2->pc1,1)
    select KART2
    skip
  enddo
  close databases
  //
  delFRfiles()
  dbcreate(fr_titl,{{"name","C",130,0},;
                    {"itog","N",6,0},;
                    {"period","C",50,0}})
  use (fr_titl) new alias FRT
  append blank
  frt->name := glob_mo[_MO_SHORT_NAME]
  frt->period := arr_m[4]
  dbcreate(fr_data,{{"nomer","C",15,0},;
                    {"fio","C",60,0},;
                    {"date_r","D",8,0},;
                    {"adres","C",250,0},;
                    {"oper","C",100,0}})
  use (fr_data) new alias FRD
  R_Use(dir_server+"base1",,"BASE1")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  use (cur_dir+"tmp") new
  set relation to kod_k into KART, to kod_k into KART_
  index on upper(kart->fio) to (cur_dir+"tmp") for is > 0
  go top
  do while !eof()
    frt->itog ++
    s := ""
    if asc(tmp->kod_p) > 0
      select BASE1
      goto (asc(tmp->kod_p))
      if !eof() .and. !empty(base1->p1)
        s += alltrim(crypt(base1->p1,gpasskod))+eos
      endif
    endif
    if tmp->task == X_REGIST
      if !empty(tmp->otd)
        if tmp->uch == 1
          s += inieditspr(A__POPUPMENU,dir_server+"mo_otd",tmp->otd)
        else
          s += inieditspr(A__POPUPMENU,dir_server+"p_priem",tmp->otd)
        endif
      endif
    else
      if !empty(tmp->otd)
        s += inieditspr(A__POPUPMENU,dir_server+"mo_otd",tmp->otd)
        if tmp->task != X_OMS
          s += eos
        endif
      endif
      do case
        case tmp->task == X_PPOKOJ
          s += "(пр/покой)"
        case tmp->task == X_PLATN
          s += "(пл/услуги)"
        case tmp->task == X_ORTO
          s += "(ортопедия)"
        case tmp->task == X_KASSA
          s += "(касса)"
      endcase
    endif
    select FRD
    append blank
    frd->nomer := amb_kartaN()
    frd->fio := kart->fio
    frd->date_r := kart->date_r
    frd->adres := iif(emptyall(kart_->okatog,kart->adres), "",;
                       ret_okato_ulica(kart->adres,kart_->okatog))
    frd->oper := s
    select TMP
    skip
  enddo
  close databases
  rest_box(buf)
  call_fr("mo_new_b")
endif
return NIL

***** 13.03.18 Информация о количестве удалённых постоянных зубов с 2005 по 2015 годы
Function i_kol_del_zub()
Local fl_exit := .f., hGauge
hGauge := GaugeNew(,,,"Информация о количестве удалённых зубов",.t.)
GaugeDisplay( hGauge )
dbcreate(cur_dir+"tmp",{;
  {"god","N",4,0},;
  {"kod_k","N",7,0},;
  {"pol","C",1,0},;
  {"vozr","N",2,0},;
  {"kol","N",6,0}})
use (cur_dir+"tmp") new
index on str(god,4)+str(kod_k,7) to tmp memory
use_base("lusl")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to recno() into HU_, to u_kod into USL
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to kod into HUMAN_, to kod into HUMAN_2
go top
do while !eof()
  GaugeUpdate( hGauge, recno()/lastrec() )
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if human->kod > 0 .and. human_->oplata != 9
    lgod := year(human->k_data)
    if between(lgod,2005,2015)
      lkol := 0
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          if between_shifr(lshifr,"57.3.2","57.3.8") .or. between_shifr(lshifr,"57.8.72","57.8.78")
            lkol += hu->kol_1
          endif
        endif
        select HU
        skip
      enddo
      if lkol > 0
        select TMP
        find (str(lgod,4)+str(human->kod_k,7))
        if !found()
          append blank
          tmp->god := lgod
          tmp->kod_k := human->kod_k
          tmp->pol := human->pol
          k := lgod - year(human->date_r)
          tmp->vozr := iif(k < 100, k, 99)
        endif
        tmp->kol += lkol
      endif
    endif
  endif
  select HUMAN
  if recno() % 5000 == 0
    Commit
  endif
  skip
enddo
CloseGauge(hGauge)
k := tmp->(lastrec())
close databases
if !fl_exit .and. k > 0
  agod := {}
  use (cur_dir+"tmp") new
  index on god to tmp unique memory
  dbeval({|| aadd(agod,tmp->god) })
  name_file := "del_zub"+stxt
  HH := 60
  arr_title := {;
    "─────────────────┬───────────────┬───────────────┬───────────────",;
    "                 │   мужчины     │    женщины    │    всего      ",;
    "Возрастной период├───────┬───────┼───────┬───────┼───────┬───────",;
    "                 │ зубов │человек│ зубов │человек│ зубов │человек",;
    "─────────────────┴───────┴───────┴───────┴───────┴───────┴───────";
  }
  sh := len(arr_title[1])
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string(glob_mo[_MO_SHORT_NAME])
  add_string("")
  add_string(center("Информация о количестве удалённых постоянных зубов",sh))
  aeval(arr_title, {|x| add_string(x) } )
  arr := array(6,6)
  select TMP
  for ig := 1 to len(agod)
    index on str(kod_k,7) to tmp for god == agod[ig] memory
    afillall(arr,0)
    go top
    do while !eof()
      if tmp->vozr < 21
        j := 1
      elseif tmp->vozr < 36
        j := 2
      elseif tmp->vozr < 61
        j := 3
      elseif tmp->vozr < 76
        j := 4
      else
        j := 5
      endif
      k := iif(tmp->pol == "М", 1, 3)
      ax := {j,6} ; ay1 := {k,5} ; ay2 := {k+1,6}
      for ix := 1 to 2
        x := ax[ix]
        for iy := 1 to 2
          y := ay1[iy]
          arr[x,y] += tmp->kol
          y := ay2[iy]
          arr[x,y] ++
        next iy
      next ix
      select TMP
      skip
    enddo
    if verify_FF(HH-8,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string("")
    add_string(padc("в "+lstr(agod[ig])+" году",sh,"_"))
    for i := 1 to 6
      s := {"до 20 лет","21-35 лет","36-60 лет","61-75 лет","старше 75 лет","Итого"}[i]
      s := padc(s,17)
      for j := 1 to 6
        s += put_val(arr[i,j],8)
      next
      add_string(s)
    next
  next
  close databases
  fclose(fp)
  viewtext(name_file,,,,.t.,,,1)
endif
return NIL

***** 09.07.17 Телефонограмма №15 ВО КЗ
Function phonegram_15_kz()
Local fl_exit := .f., i, j, k, v, koef, msum, ifin, ldate_r, y, m, buf := save_maxrow(),;
      mkol, mdni, akslp, begin_date := stod("20170101"), end_date := stod("20170630")
Private arr_m := {2017, 1, 6, "за 1-ое полугодие 2017 года", ;
                  begin_date, end_date, dtoc4(begin_date), dtoc4(end_date)}
WaitStatus(arr_m[4])
dbcreate(cur_dir+"tmp",{{"nstr","N",1,0},;
                        {"oms","N",1,0},;
                        {"mm","N",2,0},;
                        {"kol","N",6,0},;
                        {"dni","N",6,0},;
                        {"sum","N",15,2},;
                        {"kslp","N",15,2}})
use (cur_dir+"tmp") new alias TMP
index on str(oms,1)+str(nstr,1)+str(mm,2) to (cur_dir+"tmp")
R_Use(dir_server+"mo_rak",,"RAK")
R_Use(dir_server+"mo_raks",,"RAKS")
set relation to akt into RAK
R_Use(dir_server+"mo_raksh",,"RAKSH")
set relation to kod_raks into RAKS
index on str(kod_h,7) to (cur_dir+"tmp_raksh")
//
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",,"SCHET")
set relation to recno() into SCHET_
//
R_Use(dir_server+"uslugi",,"USL")
G_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to recno() into HU_, to u_kod into USL
//
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2
dbseek(dtos(arr_m[5]),.t.)
do while human->k_data <= arr_m[6] .and. !eof()
  @ maxrow(),0 say date_8(human->k_data) color "W/R"
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if human_->USL_OK == 1 .and. f_starshe_trudosp(human->POL,human->DATE_R,human->n_data)
    mkol := 1 ; mdni := 0 ; akslp := {} ; fl := .t.
    select HU
    find (str(human->kod,7))
    do while hu->kod == human->kod .and. !eof()
      lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
      if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
        lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
        if left(lshifr,1) == '1' .and. !("." $ lshifr) // это шифр КСГ (круглосуточный стационар)
          if int(val(right(lshifr,3))) >= 900 // последние три цифры - код КСГ
            fl := .f.
            mkol := 0 // диализ не учитываем количественно
          endif
          if fl
            akslp := f_cena_kslp(hu->stoim,lshifr,iif(human_->NOVOR==0,human->date_r,human_->DATE_R2),human->n_data,human->k_data)
            if !empty(akslp)
              fl := .f.
            endif
          endif
        endif
      endif
      select HU
      skip
    enddo
    if empty(akslp)
      akslp := {0,0}
    endif
    ifin := msum := 0 ; koef := 1
    if human->schet > 0 // попал в счет ОМС
      schet->(dbGoto(human->schet))
      if (fl := (schet_->NREGISTR == 0)) // только зарегистрированные счета
        // по умолчанию оплачен, если даже нет РАКа
        k := 0
        select RAKSH
        find (str(human->kod,7))
        do while human->kod == raksh->kod_h .and. !eof()
          k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
          skip
        enddo
        if !empty(round(k,2))
          if round_5(human->cena_1,2) <= round_5(k,2) // полное снятие
            koef := 0
          else // частичное снятие
            koef := (human->cena_1-k)/human->cena_1
          endif
        endif
        if koef > 0
          msum := round(human->cena_1*koef,2)
          ifin := 1
        endif
      endif
    endif
    ldate_r := human->DATE_R
    if human_->NOVOR > 0
      ldate_r := human_->DATE_R2
    endif
    count_ymd(ldate_r,human->n_data,@y)
    v := {1,0,0}
    if y >= 60
      v[2] := 1
    endif
    if y >= 75
      v[3] := 1
    endif
    m := month(human->k_data)
    if mkol > 0 .and. (mdni := human->k_data - human->n_data) == 0
      mdni := 1
    endif
    for i := 1 to 3
      if v[i] > 0
        select TMP
        find (str(0,1)+str(i,1)+str(m,2))
        if !found()
          append blank
          tmp->nstr := i
          tmp->oms := 0
          tmp->mm := m
        endif
        tmp->kol += mkol
        tmp->dni += mdni
        tmp->sum += human->cena_1
        if !empty(akslp[2])
          tmp->kslp += (human->cena_1 - round_5(human->cena_1 / akslp[2], 1))
        endif
      endif
    next i
    if ifin == 1 // попал в ОМС
      for i := 1 to 3
        if v[i] > 0
          select TMP
          find (str(1,1)+str(i,1)+str(m,2))
          if !found()
            append blank
            tmp->nstr := i
            tmp->oms := 1
            tmp->mm := m
          endif
          tmp->kol += mkol
          tmp->dni += mdni
          tmp->sum += msum
          if !empty(akslp[2])
            tmp->kslp += (msum - round_5(msum / akslp[2], 1))
          endif
        endif
      next i
    endif
  endif
  select HUMAN
  skip
enddo
if !fl_exit
  if tmp->(lastrec()) > 0
    HH := 80
    arr_title := {;
"────────────────┬──────────┬────────────┬────────────┬────────────┬────────────┬────────────┬────────────┬─────────────",;
"  Возраст       │ значение │   январь   │   февраль  │    март    │   апрель   │    май     │    июнь    │    ИТОГО    ",;
"────────────────┴──────────┴────────────┴────────────┴────────────┴────────────┴────────────┴────────────┴─────────────"}
    sh := len(arr_title[1])
    //
    nfile := "phone_15"+stxt
    fp := fcreate(nfile) ; n_list := 1 ; tek_stroke := 0
    add_string(center("Статистика оказания стационарной медицинской помощи лицам пожилого возраста",sh))
    add_string(center(arr_m[4],sh))
    select TMP
    for ifin := 0 to 1
      add_string("")
      add_string(center({"Всего пролечено","ОМС (зарегистрировано в ТФОМС)"}[ifin+1],sh))
      aeval(arr_title, {|x| add_string(x) } )
      for j := 1 to 3
        s1 := {"мужчины","",""}[j]
        s2 := {" 60 лет и старше","60 лет и старше","75 лет и старше"}[j]
        s3 := {"женщины","",""}[j]
        s4 := {" 55 лет и старше","",""}[j]
        s1 := padr(s1,17) + "больных   "
        s2 := padr(s2,17) + "койко-дней"
        s3 := padr(s3,17) + "сумма     "
        s4 := padr(s4,17) + "надб(КСЛП)"
        ss := {0,0,0,0}
        for m := 1 to 6
          find (str(ifin,1)+str(j,1)+str(m,2))
          if found()
            s1 += put_val(tmp->kol,13)
            s2 += put_val(tmp->dni,13)
            s3 += str(tmp->sum,13,1)
            s4 += str(tmp->kslp,13,1)
            ss[1] += tmp->kol
            ss[2] += tmp->dni
            ss[3] += tmp->sum
            ss[4] += tmp->kslp
          else
            s1 += space(13)
            s2 += space(13)
            s3 += space(13)
            s4 += space(13)
          endif
        next m
        s1 += put_val(ss[1],14)
        s2 += put_val(ss[2],14)
        s3 += str(ss[3],14,1)
        s4 += str(ss[4],14,1)
        add_string(s1)
        add_string(s2)
        add_string(s3)
        add_string(s4)
        add_string(replicate("─",sh))
      next j
    next ifin
    fclose(fp)
    close databases
    rest_box(buf)
    viewtext(nfile,,,,.t.,,,3)
  else
    func_error(4,"Нет информации по стационару за 2017 год!")
  endif
endif
close databases
rest_box(buf)
return NIL

** 24.01.23
Function b_25_perinat_2()
Static si := 1, sk := 1
Local buf := savescreen(), arr_m, i, j, k, _arr_komit := {}, fl_exit := .f.
if (arr_m := year_month(,,,4)) == NIL
  return NIL
endif
if (musl_ok := popup_prompt(T_ROW,T_COL-5,si,{"Стационарное лечение","Дневной стационар"})) == 0
  return NIL
endif
si := musl_ok
if (mkomp := popup_prompt(T_ROW,T_COL-5,sk,{"Страховые компании","Прочие компании","Комитеты (МО)"})) == 0
  return NIL
endif
if (sk := mkomp) > 1
  n_file := {"","str_komp","komitet"}[sk]
  if hb_fileExists(dir_server+n_file+sdbf)
    arr := {}
    R_Use(dir_server+n_file,,"_B")
    go top
    do while !eof()
      if iif(sk == 1, !between(_b->tfoms,44,47), .t.)
        aadd(arr, {alltrim(_b->name),_b->kod})
      endif
      skip
    enddo
    _b->(dbCloseArea())
    if len(arr) > 0
      if (r := T_ROW-3-len(arr)) < 2
        r := 2
      endif
      if (a := bit_popup(r,T_COL-5,arr)) != NIL
        for i := 1 to len(a)
          aadd(_arr_komit,aclone(a[i]))
        next
      else
        return func_error(4,"Нет выбора")
      endif
    else
      return func_error(4,"Ошибка")
    endif
  else
    return func_error(4,"Не обнаружен файл "+dir_server+n_file+sdbf)
  endif
endif
WaitStatus(arr_m[4])
dbcreate(cur_dir+"tmp",{;
  {"ID_PAC",  "N", 7,0},;
  {"ID_SL",   "N", 7,0},;
  {"VID_MP",  "N", 1,0},;
  {"OSN_DIAG","C", 6,0},;
  {"SOP_DIAG","C",50,0},;
  {"OSL_DIAG","C",20,0},;
  {"DNI",     "N", 3,0},;
  {"KOD_OTD", "C", 6,0},;
  {"PROFIL",  "C",99,0},;
  {"POL_PAC", "N", 1,0},;
  {"DATE_ROG","C",10,0},;
  {"DATE_GOS","C",10,0},;
  {"VIDVMP",  "C",12,0},; // вид ВМП по справочнику V018
  {"METVMP",  "C", 4,0},; // метод ВМП по справочнику V019
  {"REANIMAC","C", 3,0},;
  {"SEBESTO", "C",12,0},;
  {"USLUGI",  "C",99,0}})
use (cur_dir+"tmp") new
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"mo_su",,"MOSU")
G_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
use_base("lusl")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to recno() into HU_, to u_kod into USL
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2
dbseek(dtos(arr_m[5]),.t.)
do while human->k_data <= arr_m[6] .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  fl := .f.
  do case
    case mkomp == 1
      fl := (human->komu==0 .or. !empty(val(human_->smo)))
    case mkomp == 2
      fl := (human->komu==1 .and. ascan(_arr_komit, {|x| x[2] == human->str_crb }) > 0)
    case mkomp == 3
      fl := (human->komu==3 .and. ascan(_arr_komit, {|x| x[2] == human->str_crb }) > 0)
  endcase
  if fl .and. human_->oplata < 9 .and. human_->usl_ok == musl_ok
    is_dializ := .f. ; arr_sl := {}
    select HU
    find (str(human->kod,7))
    do while hu->kod == human->kod .and. !eof()
      lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
      if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
        lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
        if eq_any(left(lshifr,5),"1.11.","55.1.")
          lshifr1 := alltrim(usl->shifr)
          i := len(arr_sl)
          if i > 0 .and. hu->otd==arr_sl[i,7] .and. hu_->profil==arr_sl[i,3] .and. lshifr1==arr_sl[i,2]
            arr_sl[i,5] := hu_->date_u2
            arr_sl[i,6] += hu->kol_1
          else
            aadd(arr_sl,{lshifr,;              // 1
                         lshifr1,;             // 2
                         hu_->profil,;         // 3
                         hu->date_u,;          // 4
                         hu_->date_u2,;        // 5
                         hu->kol_1,;           // 6
                         hu->otd,;             // 7
                         lshifr})              // 8 - услуги Минздрава
          endif
        elseif !is_dializ
          is_dializ := (ascan(glob_KSG_dializ,lshifr) > 0) // КСГ с диализом
        endif
      endif
      select HU
      skip
    enddo
    if !is_dializ
      mdiagnoz := diag_for_xml(,.t.,,,.t.)
      mdiagnoz2 := ""
      for i := 2 to len(mdiagnoz)
        if !empty(mdiagnoz[i])
          mdiagnoz2 += mdiagnoz[i]+";"
        endif
      next
      if !empty(mdiagnoz2)
        mdiagnoz2 := left(mdiagnoz2,len(mdiagnoz2)-1)
      endif
      mdiagnoz3 := ""
      if !empty(human_2->OSL1)
        mdiagnoz3 += alltrim(human_2->OSL1)+";"
      endif
      if !empty(human_2->OSL2)
        mdiagnoz3 += alltrim(human_2->OSL2)+";"
      endif
      if !empty(human_2->OSL3)
        mdiagnoz3 += alltrim(human_2->OSL3)+";"
      endif
      if !empty(mdiagnoz3)
        mdiagnoz3 := left(mdiagnoz3,len(mdiagnoz3)-1)
      endif
      select MOHU
      find (str(human->kod,7))
      do while mohu->kod == human->kod .and. !eof()
        if (i := ascan(arr_sl,{|x| mohu->DATE_U >= x[4] .and. mohu->DATE_U2 <= x[5] })) > 0
          arr_sl[i,8] += ";"+alltrim(mosu->shifr1)
        endif
        select MOHU
        skip
      enddo
      for i := 1 to len(arr_sl)
        select OTD
        goto (arr_sl[i,7])
        select TMP
        append blank
        tmp->ID_PAC   := human->kod_k
        tmp->ID_SL    := human->kod
        tmp->VID_MP   := iif(human_2->vmp > 0, 1, 0)
        tmp->OSN_DIAG := mdiagnoz[1]
        tmp->SOP_DIAG := mdiagnoz2
        tmp->OSL_DIAG := mdiagnoz3
        tmp->DNI      := arr_sl[i,6]
        if arr_sl[i,1] == arr_sl[i,2]
          tmp->KOD_OTD := lstr(arr_sl[i,7])
        else
          tmp->KOD_OTD := arr_sl[i,2]
        endif
        // tmp->PROFIL   := inieditspr(A__MENUVERT, glob_V002, arr_sl[i,3])
        tmp->PROFIL   := inieditspr(A__MENUVERT, getV002(), arr_sl[i,3])
        tmp->POL_PAC  := iif(iif(human_->NOVOR > 0, human_->pol2, human->pol) == "М", 1, 0)
        tmp->DATE_ROG := full_date(iif(human_->NOVOR > 0, human_->date_r2, human->date_r))
        tmp->DATE_GOS := full_date(c4tod(arr_sl[i,4]))
        tmp->VIDVMP   := iif(human_2->vmp > 0, human_2->VIDVMP, "")
        tmp->METVMP   := iif(human_2->vmp > 0, lstr(human_2->METVMP), "")
        tmp->REANIMAC := iif(arr_sl[i,3] == 5, lstr(arr_sl[i,6]), "")
        tmp->USLUGI   := arr_sl[i,8]
      next
    endif
  endif
  select HUMAN
  skip
enddo
close databases
restscreen(buf)
if !fl_exit
  n_file := "SVED"
  copy file (cur_dir+"tmp"+sdbf) to (cur_dir+n_file+sdbf)
  n_message({"В каталоге "+upper(cur_dir),;
             "создан файл "+upper(n_file+sdbf),;
             "со сведениями о случаях лечения пациентов."},,;
             cColorStMsg,cColorStMsg,,,cColorSt2Msg)
endif
return NIL

***** 22.06.17
Function forma_792_MIAC()
Local fl_exit := .f., arr_f := {"str_komp",,"komitet"}, i, j, k, v, koef, msum, ifin, ;
      acomp := {}, ldate_r, y, m, d, buf := save_maxrow(),;
      begin_date := stod("20160101"), end_date := stod("20161231")
Private arr_m := {2016, 1, 12, "за 2016 год", begin_date, end_date, dtoc4(begin_date), dtoc4(end_date)}
WaitStatus(arr_m[4])
for i := 1 to 3
  if i != 2 .and. hb_fileExists(dir_server+arr_f[i]+sdbf)
    R_Use(dir_server+arr_f[i],,"_B")
    go top
    do while !eof()
      if iif(i == 1, !between(_b->tfoms,44,47), .t.) .and. _b->ist_fin == I_FIN_BUD
        aadd(acomp, {i,_b->kod}) // список бюджетных компаний
      endif
      skip
    enddo
    Use
  endif
next
dbcreate(cur_dir+"tmp",{{"nstr","N",1,0},;
                        {"oms","N",1,0},;
                        {"profil","N",3,0},;
                        {"kol1","N",6,0},;
                        {"sum1","N",15,2},;
                        {"kol2","N",6,0},;
                        {"sum2","N",15,2},;
                        {"kol3","N",6,0},;
                        {"sum3","N",15,2},;
                        {"kol4","N",6,0},;
                        {"sum4","N",15,2},;
                        {"kol","N",6,0},;
                        {"sum","N",15,2}})
use (cur_dir+"tmp") new alias TMP
index on str(oms,1)+str(nstr,1)+str(profil,3) to (cur_dir+"tmp")
R_Use(dir_server+"mo_rak",,"RAK")
R_Use(dir_server+"mo_raks",,"RAKS")
set relation to akt into RAK
R_Use(dir_server+"mo_raksh",,"RAKSH")
set relation to kod_raks into RAKS
index on str(kod_h,7) to (cur_dir+"tmp_raksh")
//
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",,"SCHET")
set relation to recno() into SCHET_
//
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2
dbseek(dtos(arr_m[5]),.t.)
do while human->k_data <= arr_m[6] .and. !eof()
  @ maxrow(),0 say date_8(human->k_data) color "W/R"
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if human_->USL_OK == 1 .and. (j := f1forma_792_MIAC(human->kod_diag)) > 0 // стационар
    ifin := msum := 0 ; koef := 1 ; fl := .f.
    if human->schet > 0
      schet->(dbGoto(human->schet))
      if (fl := (schet_->NREGISTR == 0)) // только зарегистрированные
        // по умолчанию оплачен, если даже нет РАКа
        k := 0
        select RAKSH
        find (str(human->kod,7))
        do while human->kod == raksh->kod_h .and. !eof()
          k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
          skip
        enddo
        if !empty(round(k,2))
          if round_5(human->cena_1,2) <= round_5(k,2) // полное снятие
            koef := 0
          else // частичное снятие
            koef := (human->cena_1-k)/human->cena_1
          endif
        endif
        if (fl := (koef > 0))
          msum := round(human->cena_1*koef,2)
          ifin := 1
        endif
      endif
    endif
    if !fl .and. ascan(acomp, {|x| x[1]==human->komu .and. x[2]==human->str_crb}) > 0 // бюджет
      msum := human->cena_1
      ifin := 2
    endif
    if ifin > 0
      ldate_r := human->DATE_R
      if human_->NOVOR > 0
        ldate_r := human_->DATE_R2
      endif
      count_ymd(ldate_r,human->n_data,@y,@m,@d)
      if y == 0 .or. (y == 1 .and. m == 0 .and. d == 0)
        v := 1
      elseif y < 17
        v := 2
      elseif y < 60
        v := 3
      else
        v := 4
      endif
      polek := "tmp->kol"+lstr(v)
      poles := "tmp->sum"+lstr(v)
      select TMP
      find (str(ifin,1)+str(j,1)+str(0,3))
      if !found()
        append blank
        tmp->nstr := j
        tmp->oms := ifin
        tmp->profil := 0
      endif
      &(polek) ++
      &(poles) += msum
      tmp->kol ++
      tmp->sum += msum
      select TMP
      find (str(ifin,1)+str(j,1)+str(human_->profil,3))
      if !found()
        append blank
        tmp->nstr := j
        tmp->oms := ifin
        tmp->profil := human_->profil
      endif
      &(polek) ++
      &(poles) += msum
      tmp->kol ++
      tmp->sum += msum
      select TMP
      find (str(ifin,1)+str(0,1)+str(human_->profil,3))
      if !found()
        append blank
        tmp->nstr := 0
        tmp->oms := ifin
        tmp->profil := human_->profil
      endif
      &(polek) ++
      &(poles) += msum
      tmp->kol ++
      tmp->sum += msum
    endif
  endif
  select HUMAN
  skip
enddo
if !fl_exit
  if tmp->(lastrec()) > 0
    HH := 80
    arr_title := {;
  "───────┬───────────────────┬───────────────────┬───────────────────┬───────────────────┬───────────────────",;
  "       │    до 1 года      │  от 1 г. до 16 лет│   от 17 до 59 лет │ от 60 лет и старше│      всего        ",;
  "       │───────────────────│───────────────────│───────────────────│───────────────────│───────────────────",;
  "МКБ-10 │ кол. │   сумма    │ кол. │   сумма    │ кол. │   сумма    │ кол. │   сумма    │ кол. │   сумма    ",;
  "───────┴──────┴────────────┴──────┴────────────┴──────┴────────────┴──────┴────────────┴──────┴────────────"}
    sh := len(arr_title[1])
    //
    nfile := "pr_792"+stxt
    fp := fcreate(nfile) ; n_list := 1 ; tek_stroke := 0
    add_string(center("Фактические показатели объёма и финансового обеспечения специализированной медицинской помощи, оказанной в",sh))
    add_string(center("стационарных условиях, по отдельным профилям медицинской помощи за 2016 год (в тыс.руб.)",sh))
    for ifin := 1 to 2
      select TMP
      find (str(ifin,1))
      if found()
        add_string("")
        add_string(center({"ОМС","бюджет"}[ifin],sh))
        aeval(arr_title, {|x| add_string(x) } )
        add_string(center("Диагнозы + профили",sh))
        add_string(replicate("─",sh))
        for j := 1 to 5
          s := {"E10-E14","C00-C97","A00-B99","J00-J99","P35-P39"}[j]
          find (str(ifin,1)+str(j,1)+str(0,3))
          if found()
            for v := 1 to 4
              polek := "tmp->kol"+lstr(v)
              poles := "tmp->sum"+lstr(v)
              if empty(&(polek))
                s += space(20)
              else
                s += str(&(polek),7)+str(&(poles)/1000,13,3)
              endif
            next v
            s += str(tmp->kol,7)+str(tmp->sum/1000,13,3)
          endif
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(s)
          dbseek(str(ifin,1)+str(j,1)+str(1,3),.t.)
          do while tmp->nstr == j .and. tmp->oms == ifin .and. !eof()
            if verify_FF(HH-1,.t.,sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            // add_string("- "+inieditspr(A__MENUVERT, glob_V002, tmp->PROFIL))
            add_string('- ' + inieditspr(A__MENUVERT, getV002(), tmp->PROFIL))
            s := space(7)
            for v := 1 to 4
              polek := "tmp->kol"+lstr(v)
              poles := "tmp->sum"+lstr(v)
              if empty(&(polek))
                s += space(20)
              else
                s += str(&(polek),7)+str(&(poles)/1000,13,3)
              endif
            next v
            s += str(tmp->kol,7)+str(tmp->sum/1000,13,3)
            add_string(s)
            skip
          enddo
          add_string(replicate("─",sh))
        next j
        add_string(center("Профили",sh))
        add_string(replicate("─",sh))
        dbseek(str(ifin,1)+str(0,1),.t.)
        do while tmp->nstr == 0 .and. tmp->oms == ifin .and. !eof()
          if verify_FF(HH-1,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          // add_string(inieditspr(A__MENUVERT, glob_V002, tmp->PROFIL))
          add_string(inieditspr(A__MENUVERT, getV002(), tmp->PROFIL))
          s := space(7)
          for v := 1 to 4
            polek := "tmp->kol"+lstr(v)
            poles := "tmp->sum"+lstr(v)
            if empty(&(polek))
              s += space(20)
            else
              s += str(&(polek),7)+str(&(poles)/1000,13,3)
            endif
          next v
          s += str(tmp->kol,7)+str(tmp->sum/1000,13,3)
          add_string(s)
          skip
        enddo
      endif
    next ifin
    fclose(fp)
    close databases
    rest_box(buf)
    viewtext(nfile,,,,.t.,,,6)
  else
    func_error(4,"Нет информации по стационару за 2016 год!")
  endif
endif
close databases
rest_box(buf)
return NIL

***** 22.06.17
Function f1forma_792_MIAC(mkod_diag)
Local k := 0, c, s
c := left(mkod_diag,1)
s := left(mkod_diag,3)
if c == "C"
  k := 2
elseif c == "J"
  k := 4
elseif c == "A" .or. c == "B"
  k := 3
elseif between(s,"E10","E14")
  k := 1
elseif between(s,"P35","P39")
  k := 5
endif
return k

*

***** 16.10.16 Мониторинг по видам медицинской помощи для Комитета здравоохранения ВО
Function monitoring_vid_pom()
Static mm_schet := {{"все случаи",1},{"в выставленных счетах",2},{"в зарегистрированных счетах",3}}
Local mm_tmp := {}, buf := savescreen(), tmp_color := setcolor(cDataCGet),;
      tmp_help := help_code, hGauge, name_file := "mon_kz"+stxt,;
      sh := 80, HH := 60, i, k, tmp_file := "tmp_mon"+sdbf, r1, r2
Private pdate_lech
//
aadd(mm_tmp, {"date_lech","N",4,0,NIL,;
              {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c),;
                           iif(k==nil,nil,(pdate_lech:=aclone(k),k:={k[1],k[4]})),;
                           k }},A__FUNCTION)},;
              0,{|| space(10) },;
              'Дата окончания лечения (отч.период)',{|| f_valid_mon() }})
aadd(mm_tmp, {"schet","N",1,0,NIL,;
              {|x|menu_reader(x,mm_schet,A__MENUVERT)},;
              3,{|x|inieditspr(A__MENUVERT,mm_schet,x)},;
              "Какие случаи учитываются",{|| f_valid_mon() }})
aadd(mm_tmp, {"date_reg","D",8,0,,;
              nil,;
              ctod(""),nil,;
              "По какую дату (включительно) зарегистрирован счёт",;
              {|| f_valid_mon() },{|| m1schet == 3 }})
aadd(mm_tmp, {"rak","N",1,0,NIL,;
              {|x|menu_reader(x,mm_danet,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_danet,x)},;
              "Учитывать случаи, полностью снятые по актам контроля",;
              {|| f_valid_mon() }})
aadd(mm_tmp, {"date_rak","D",8,0,,,ctod(""),,;
              "По какую дату (включительно) проверять акты контроля",,;
              {|| m1rak == 0 }})
delete file (tmp_file)
init_base(tmp_file,,mm_tmp,0)
r1 := 16 ; r2 := 22
FillScrArea(r1-1,0,r1-1,79,"░",color1)
str_center(r1-1," Мониторинг по видам медицинской помощи ",color8)
FillScrArea(r2+1,0,r2+1,79,"░",color1)
if f_edit_spr(A__APPEND,mm_tmp,"","e_use(cur_dir+'tmp_mon')",0,1,,,,{r1,0,r2,79,-1},"write_mon") > 0
  restscreen(buf)
  if year(pdate_lech[5]) < 2016
    return func_error(4,"Данный алгоритм работает с 2016 года")
  endif
  mywait()
  use (tmp_file) new alias MN
  arr := {;
    {"Мед.помощь в рамках террпрограммы ОМС","10","",0,0},; // 1
    {"скорая медицинская помощь","11","вызов",0,0},;             // 2
    {"медицинская помощь","12.1","посещение с проф.целью",0,0},;    // 3
    {"    в амбулаторных","12.2","посещение по неотложной помощи",0,0},;// 4
    {"    условиях","12.3","обращение",0,0},;                           // 5
    {"стационар","13","случай госпитализации",0,0},;                // 6
    {"  в т.ч. реабилитация","14","койко-день",0,0},;                 // 7
    {"  в т.ч. ВМП","15","случай госпитализации",0,0},;               // 8
    {"дневной стационар","16","пациенто-день",0,0} ;                // 9
   }
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"human_u_",,"HU_")
  R_Use(dir_server+"human_u",dir_server+"human_u","HU")
  set relation to recno() into HU_, to u_kod into USL
  if mn->rak == 0
    R_Use(dir_server+"mo_xml",,"MO_XML")
    R_Use(dir_server+"mo_rak",,"RAK")
    set relation to kod_xml into MO_XML
    R_Use(dir_server+"mo_raks",,"RAKS")
    set relation to akt into RAK
    R_Use(dir_server+"mo_raksh",,"RAKSH")
    set relation to kod_raks into RAKS
    index on str(kod_h,7) to (cur_dir+"tmp_raksh") for rak->DAKT <= mn->date_rak
  endif
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",,"SCHET")
  set relation to recno() into SCHET_
  //
  R_Use(dir_server+"human_2",,"HUMAN_2")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_, to recno() into HUMAN_2
  dbseek(dtos(pdate_lech[5]),.t.)
  old := pdate_lech[5]-1
  do while human->k_data <= pdate_lech[6] .and. !eof()
    if old != human->k_data
      old := human->k_data
      @ maxrow(),0 say date_8(human->k_data) color cColorWait
    endif
    fl := (human->komu==0 .or. !empty(val(human_->smo)))
    if fl .and. mn->schet > 1
      fl := (human->schet > 0)
      if fl .and. mn->schet == 3
        schet->(dbGoto(human->schet))
        fl := (date_reg_schet() <= mn->date_reg) // дата регистрации
      endif
    endif
    fl_stom := .f.
    koef := 1 // по умолчанию оплачен, если даже нет РАКа
    if mn->rak == 0 // не включать полностью снятые
      k := 0
      select RAKSH
      find (str(human->kod,7))
      do while human->kod == raksh->kod_h .and. !eof()
        k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
        skip
      enddo
      if !empty(round(k,2))
        if empty(human->cena_1) // скорая помощь
          koef := 0
        elseif round_5(human->cena_1,2) == round_5(k,2) // полное снятие
          koef := 0
        else // частичное снятие
          koef := (human->cena_1-k)/human->cena_1
        endif
      endif
    endif
    if fl .and. koef > 0
      lsum := round(human->cena_1*koef,2)
      arr[1,5] += lsum
      if human_->USL_OK == 4 // скорая помощь
        arr[2,4] ++ ; arr[2,5] += lsum
      else
        vid_vp := 0 // по умолчанию профилактика
        d2_year := year(human->k_data)
        au := {}
        kp := 0 // количество процедур
        select HU
        find (str(human->kod,7))
        do while hu->kod == human->kod .and. !eof()
          lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
            lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
            ta := f14tf_nastr(@lshifr,,d2_year)
            lshifr := alltrim(lshifr)
            aadd(au,{lshifr,hu->kol_1,round(hu->stoim_1*koef,2),0,0,hu->kol_1})
            if eq_any(left(lshifr,5),"2.78.","2.89.")
              kp := 1
              vid_vp := 2 // обращения с лечебной целью
            elseif eq_any(left(lshifr,5),"2.80.","2.82.")
              kp += hu->kol_1
              vid_vp := 1 // в неотложной форме
            elseif left(lshifr,2) == "2." // остальная профилактика
              if eq_any(left(lshifr,5),"2.60.","2.90.")
                //
              else
                kp += hu->kol_1
              endif
            elseif left(lshifr,2) == "1." // койко-дни
              kp += hu->kol_1 // если реабилитация
            elseif left(lshifr,3) == "55."  // пациенто-дни
              kp += hu->kol_1
            elseif left(lshifr,5) == "60.2." .or. lshifr == "4.20.702" // Р-исследование
              kp := 0  // участвует не количеством, а только суммой
            elseif left(lshifr,3) == "57."  // стоматология
              fl_stom := .t.
            endif
          endif
          select HU
          skip
        enddo
        if human_->USL_OK == 1 // стационар
          if ascan(glob_KSG_dializ,lshifr) > 0 // КСГ с диализом
            arr[6,5] += lsum
          else
            arr[6,4] ++ ; arr[6,5] += lsum
            if human_->PROFIL == 158
              arr[7,4] += kp ; arr[7,5] += lsum
            endif
            if human_2->VMP == 1
              arr[8,4] ++ ; arr[8,5] += lsum
            endif
          endif
        elseif human_->USL_OK == 2 // дневной стационар
          if ascan(glob_KSG_dializ,lshifr) == 0
            arr[9,4] += kp
          endif
          arr[9,5] += lsum
        else // поликлиника
          if fl_stom
            ret_tip := kp := 0
            f_vid_p_stom(au,{},,,human->k_data,@ret_tip,@kp)
            do case
              case ret_tip == 1
                vid_vp := 2 // по поводу заболевания
              case ret_tip == 2
                vid_vp := 0 // профилактика
              case ret_tip == 3
                vid_vp := 1 // в неотложной форме
            endcase
          endif
          if vid_vp == 2 // по поводу заболевания
            arr[5,4] ++ ; arr[5,5] += lsum
          elseif vid_vp == 1 // в неотложной форме
            arr[4,4] += kp ; arr[4,5] += lsum
          else // профилактика
            arr[3,4] += kp ; arr[3,5] += lsum
          endif
        endif
      endif
    endif
    select HUMAN
    skip
  enddo
  close databases
  arr_title := {;
  "─────────────────────────────────┬────┬────────────────────┬──────┬─────────────",;
  "Виды и условия оказания мед.пом. │№стр│ Единица измерения  │ кол. │ сумма в руб.",;
  "─────────────────────────────────┴────┴────────────────────┴──────┴─────────────"}
  fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
  add_string("")
  add_string(center("Мониторинг по видам медицинской помощи",sh))
  add_string(center(pdate_lech[4],sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  for i := 1 to len(arr)
    add_string(padr(arr[i,1],33)+" "+padr(arr[i,2],5)+padr(arr[i,3],20)+;
               put_val(arr[i,4],7)+put_kopE(arr[i,5],14))
  next
  fclose(fp)
  restscreen(buf) ; setcolor(tmp_color)
  viewtext(name_file,,,,(.t.),,,2)
endif
close databases
restscreen(buf) ; setcolor(tmp_color)
return NIL

*****
Function write_mon(k)
Local fl := .t.
if k == 1
  if empty(mdate_lech)
    fl := func_error(4,"Обязательно должно быть заполнено поле даты окончания лечения!")
  else
    if m1schet == 3
      if empty(mdate_reg) .or. mdate_reg < pdate_lech[6]
        fl := func_error(4,'Некорректное содержание поля "По какую дату (включительно) зарегистрирован счёт"')
      endif
    endif
    if m1rak == 0
      if empty(mdate_rak) .or. mdate_rak < pdate_lech[6] .or. ;
                                 ( m1schet == 3 .and. mdate_rak < mdate_reg)
        fl := func_error(4,'Некорректное содержание поля "По какую дату (включительно) проверять акты контроля"')
      endif
    endif
  endif
endif
return fl

*****
Function f_valid_mon()
if !empty(pdate_lech)
  if m1schet == 3
    if empty(mdate_reg) .or. mdate_reg < pdate_lech[6]
      mdate_reg := pdate_lech[6]+10
    endif
  else
    mdate_reg := ctod("")
  endif
  if m1rak == 0
    if empty(mdate_rak) .or. mdate_rak < pdate_lech[6] .or. ;
                                 ( m1schet == 3 .and. mdate_rak < mdate_reg)
      if m1schet == 3
        mdate_rak := mdate_reg
      else
        mdate_rak := pdate_lech[6]+10
      endif
    endif
  else
    mdate_rak := ctod("")
  endif
endif
return update_gets()
