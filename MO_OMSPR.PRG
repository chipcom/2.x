***** mo_omspr.prg - прочие счета для задачи ОМС
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

*****
Function other_schets(k)
Static si1 := 2
Local mas_pmt, mas_msg, mas_fun, j, str_sem
DEFAULT k TO 1
do case
  case k == 1
    if tip_polzovat != 0
      return func_error(4,err_admin)
    endif
    mas_pmt := {"Список ~прочих счетов",;
                "~Невыписанные счета",;
                "Выписка ~счёта",;
                "~Корректировка счёта",;
                "~Возврат счёта"}
    mas_msg := {"Просмотр/печать прочих счетов",;
                "Составление прочего счёта через режим невыписанных счетов",;
                "Составление прочего счёта по конкретной компании",;
                "Редактирование (корректировка) прочего счёта",;
                "Возврат прочего счёта"}
    mas_fun := {"other_schets(11)",;
                "other_schets(12)",;
                "other_schets(13)",;
                "other_schets(14)",;
                "other_schets(15)"}
    str_sem := "Работа со счетами"
    if !G_SLock(str_sem)
      return func_error(4,"В данный момент со счетами работает другой пользователь.")
    endif
    popup_prompt(T_ROW,T_COL+5,si1,mas_pmt,mas_msg,mas_fun)
    G_SUnLock(str_sem)
  case k == 11
    other_schet_view()
  case k == 12
    other_schet_nevyp()
  case k == 13
    other_schet_vyp()
  case k == 14
    other_schet_edit()
  case k == 15
    other_schet_vozvrat()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

*

***** Просмотр списка счетов, печать счетов
Function other_schet_view()
Local i, k, buf := savescreen(), tmp_help := chm_help_code,;
      mdate := stod("20110101")
mywait()
R_Use(dir_server+"mo_rees",,"REES")
G_Use(dir_server+"mo_xml",,"MO_XML")
G_Use(dir_server+"schet_",,"SCHET_")
G_Use(dir_server+"schet",dir_server+"schetd","SCHET")
set relation to recno() into SCHET_
dbseek(dtoc4(mdate),.t.)
index on dtos(schet_->dschet)+schet_->nschet to (cur_dir+"tmp_sch") ;
      for schet_->dschet >= mdate .and. !empty(pdate) .and.;
          !(schet_->IS_DOPLATA==1 .or. !empty(val(schet_->smo))) ;
      DESCENDING
go top
if eof()
  restscreen(buf)
  close databases
  return func_error(4,"Нет выписанных счетов c "+date_month(mdate))
endif
chm_help_code := 1//H_opl_schet
Alpha_Browse(T_ROW,0,23,79,"f1_view_other_schet",color0,,,,,,,;
             "f2_view_other_schet",,{'═','░','═',"N/BG,W+/N",.t.,60} )
close databases
chm_help_code := tmp_help
restscreen(buf)
return NIL

*****
Function f1_view_other_schet(oBrow)
Local s, oColumn, blk
oColumn := TBColumnNew("Номер счета",{|| schet->nomer_s })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("   Дата",{|| full_date(schet_->dschet) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Сумма счета",{|| put_kop(schet->summa,13) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол.;бол.", {|| str(schet->kol,4) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Принадлежность;счета",{|| padr(f4_view_list_schet(),34) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
status_key("^<Esc>^ выход ^<F7>^ печать акта ^<F8>^ печать счёта-фактуры ^<F9>^ печать счёта")
return NIL

***** 06.12.12
Function f2_view_other_schet(nKey,oBrow)
Local ret := -1, rec := schet->(recno()), tmp_color := setcolor(), r, r1, r2,;
      s, buf := savescreen(), arr, i, k, mdate, t_arr[2], arr_pmt := {}
do case
  case nKey == K_F9
    print_other_schet(1)
    ret := 0
  case nKey == K_F8
    print_faktura(1)
    ret := 0
  case nKey == K_F7
    print_akt(1)
    ret := 0
endcase
select SCHET
setcolor(tmp_color)
restscreen(buf)
return ret

*

***** невыписанные счета
Function other_schet_nevyp()
Local buf := save_maxrow(), k := 0, s1, s2, mstr_crb, gnevyp_schet := .f.
if !myFileDeleted(cur_dir+"tmp"+sdbf)
  return NIL
endif
Private pkol := 0, psumma := 0
mywait()
dbcreate(cur_dir+"tmp",{;
    {"KOMU"     ,   "N",     1,     0},;
    {"STR_CRB"  ,   "N",     2,     0},;
    {"MIN_DATE" ,   "D",     8,     0},;
    {"DNI"      ,   "N",     3,     0},;
    {"KOL_BOLN" ,   "N",     6,     0},;
    {"SUMMA"    ,   "N",    13,     2},;
    {"NKOMU"    ,   "C",    80,     0},;
    {"KOD"      ,   "N",     7,     0},;
    {"PLUS"     ,   "L",     1,     0}})
Use (cur_dir+"tmp") alias TMP
index on str(komu,1)+str(str_crb,2) to (cur_dir+"tmp")
index on nkomu to (cur_dir+"tmp1")
Use (cur_dir+"tmp") index (cur_dir+"tmp"),(cur_dir+"tmp1") alias TMP
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
set relation to recno() into HUMAN_
find (str(0,6)+str(B_STANDART,1))
do while human->schet == 0 .and. human->tip_h == B_STANDART .and. !eof()
  if human_->reestr == 0 .and. ;
        human->cena_1 > 0 .and. human->komu > 0 .and. empty(val(human_->smo))
    mstr_crb := iif(human->komu==5,0,human->str_crb)
    select TMP
    find (str(human->komu,1)+str(mstr_crb,2))
    if found() .and. human->komu != 5
      tmp->kol_boln++
      tmp->summa += human->cena_1
      tmp->min_date := min(tmp->min_date,human->k_data)
    else
      k++
      append blank
      replace tmp->komu with human->komu,;
              tmp->str_crb with mstr_crb,;
              tmp->kol_boln with 1, tmp->summa with human->cena_1,;
              tmp->min_date with human->k_data, ;
              tmp->plus with .t.
      if human->komu == 5
        replace tmp->nkomu with " Личн.счет - "+alltrim(human->fio)+", "+;
                      left(dtoc(human->n_data),5)+"-"+date_8(human->k_data),;
                tmp->kod with human->kod
      endif
    endif
    pkol++ ; psumma += human->cena_1
  endif
  select HUMAN
  skip
enddo
if k == 0
  rest_box(buf)
  func_error(4,"В базе данных нет больных, по которым не выписаны прочие счета!")
else
  human_->(dbCloseArea())
  human->(dbCloseArea())
  select TMP
  set order to 0
  go top
  do while !eof()
    if tmp->komu != 5
      tmp->nkomu := func1_komu(tmp->komu,tmp->str_crb)
    endif
    k := sys_date - tmp->min_date
    tmp->dni := iif(between(k,1,999), k, -99)
    skip
  enddo
  set order to 2
  go top
  rest_box(buf)
  s1 := " Общее количество больных - "+expand_value(pkol)+" чел. "
  s2 := " Общая сумма счетов - "+expand_value(psumma,2)+" руб. "
  k := 80-max(len(s1),len(s2))
  buf := box_shadow(T_ROW-3,k,T_ROW-2,79,color1,,,0)
  @ T_ROW-3,k say s1 color color8
  @ T_ROW-2,k say s2 color color8
  if Alpha_Browse(T_ROW,0,23,79,"f1nevyp_schet",color0,;
                  "Невыписанные счета","R/BG",,,,,"f2nevyp_schet",,;
                  {'═','░','═',"N/BG,W+/N,B/BG,W+/B,R/BG",.f.,0} )
    gnevyp_schet := .t.
    if (glob_komu := tmp->komu) == 1
      glob_strah[1] := tmp->str_crb
    elseif glob_komu == 3
      glob_komitet[1] := tmp->str_crb
    endif
    glob_all := {tmp->str_crb,rtrim(tmp->nkomu)}
    if glob_komu == 5
      glob_all := {tmp->kod,rtrim(tmp->nkomu)}
    endif
  endif
  rest_box(buf)
endif
close databases
if gnevyp_schet
  vyp1other_schet(.f.,glob_komu,glob_all[1])
endif
return NIL

*****
Function f1nevyp_schet(oBrow)
Local oColumn, n := 57, blk
oColumn := TBColumnNew(center("Принадлежность счета",n),{|| left(tmp->nkomu,n)})
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Дни;max", {|| put_val(tmp->dni,3) })
oColumn:defColor := {5,5}
oColumn:colorBlock := {|| {5,5} }
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол.;бол.", {|| str(tmp->kol_boln,4) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Сумма счета", {|| str(tmp->summa,11,2) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
status_key('^<Esc>^ - выход;  ^<F10>^ - проверка цен;  ^<Enter>^ - вход в режим "Выписка счета"')
return NIL

*****
Function f2nevyp_schet(nKey,oBrow)
Local iprov := 0, inprov := 0
Local buf, rec, k := -1, sh := 80, HH := 60, nfile := "err_sl"+stxt, j := 0
do case
  case nkey == K_F10
    buf := save_maxrow()
    mywait()
    rec := tmp->(recno())
    fp := fcreate(nfile) ; n_list := 1 ; tek_stroke := 0
    add_string("")
    add_string(center("Список обнаруженных ошибок по невыписанным счетам",80))
    add_string(center(alltrim(tmp->nkomu),80))
    add_string("")
    //
    R_Use(dir_server+"mo_pers",,"PERS")
    R_Use(dir_server+"mo_uch",,"UCH")
    R_Use(dir_server+"mo_otd",,"OTD")
    use_base("lusl")
    use_base("luslc")
    R_Use(dir_server+"uslugi",,"USL")
    R_Use(dir_server+"human_u_",,"HU_")
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    set relation to recno() into HU_, to u_kod into USL
    R_Use(dir_server+"kartote_",,"KART_")
    R_Use(dir_server+"kartotek",,"KART")
    set relation to recno() into KART_
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",,"HUMAN")
    set relation to recno() into HUMAN_, to kod_k into KART
    if tmp->komu == 5
      goto (tmp->kod)
      if verify_1_other_sluch()
        ++iprov
      else
        ++inprov
      endif
    else
      set index to (dir_server+"humans")
      find (str(0,6)+str(B_STANDART,1))
      do while human->schet == 0 .and. human->tip_h == B_STANDART .and. !eof()
        if human_->reestr == 0 .and. human->cena_1 > 0 .and. ;
            human->komu == tmp->komu .and. human->str_crb == tmp->str_crb ;
               .and. empty(val(human_->smo))
          if verify_1_other_sluch()
            ++iprov
          else
            ++inprov
          endif
          @ 24,0 say padc("Прошли проверку: "+lstr(iprov)+", не прошли проверку: "+lstr(inprov),80) color cColorSt2Msg
        endif
        select HUMAN
        skip
      enddo
    endif
    if inprov == 0
      if iprov > 0
        add_string("Проверено случаев - "+lstr(iprov)+". Ошибок не обнаружено.")
      else
        add_string("Нечего проверять!")
      endif
    endif
    fclose(fp)
    close databases
    rest_box(buf)
    viewtext(nfile,,,,,,,2)
    Use (cur_dir+"tmp") index (cur_dir+"tmp"),(cur_dir+"tmp1") alias TMP
    set order to 2
    goto (rec)
endcase
return k

*

*****
Function verify_1_other_sluch()
Local ta := {}, ssumma := 0, fl, _ocenka := 5, lshifr1, auet
rec_human := human->(recno())
glob_kartotek := human->kod_k
d1 := human->n_data ; d2 := human->k_data ; dnovor := human_->NOVOR
d2_year := year(d2)
cd1 := dtoc4(d1) ; cd2 := dtoc4(d2)
uch->(dbGoto(human->LPU))
otd->(dbGoto(human->OTD))
// проверка по датам
if year(human->date_r) < 1900
  aadd(ta, "дата рождения: "+full_date(human->date_r)+" ( < 1900г.)")
endif
if human->date_r > human->n_data
  aadd(ta, "дата рождения: "+full_date(human->date_r)+;
            " > даты начала лечения: "+full_date(human->n_data))
endif
if human->n_data > human->k_data
  aadd(ta, "дата начала лечения: "+full_date(human->n_data)+;
            " > даты окончания лечения: "+full_date(human->k_data))
endif
if human->k_data - human->n_data > 364
  aadd(ta, "время лечения составляет больше года")
endif
if human->k_data > sys_date
  aadd(ta, "дата окончания лечения > системной даты: "+full_date(human->k_data))
endif
if human_->NOVOR > 0
  if empty(human_->DATE_R2)
    aadd(ta, "не введена дата рождения новорожденного")
  elseif human_->DATE_R2 > human->n_data
    aadd(ta, "дата рождения новорожденного: "+full_date(human_->DATE_R2)+" больше даты начала лечения: "+full_date(human->n_data))
  elseif human->n_data - human_->DATE_R2 > 60
    aadd(ta, "новорожденному более двух месяцев")
  endif
endif
mdiagnoz := diag_to_array(,,,,.t.)
if len(mdiagnoz) == 0 .or. empty(mdiagnoz[1])
  aadd(ta,'не заполнено поле "ОСНОВНОЙ ДИАГНОЗ"')
endif
val_fio(retFamImOt(2,.f.),ta)
//
d := human->k_data - human->n_data
kkd := kds := kvp := kuet := kkt := ksmp := 0 ; mpztip := mpzkol := kol_uet := 0
kkd_1_7 := 0 ; fl_1_7_12 := .f. ; kkd_1_10 := 0 ; fl_70_1 := .f. ; au_lu := {}
               fl_1_7_53 := .f. ; is_perito := .f.
kkd_1_9 := 0 ; is_kt := is_mrt := is_71_1 := is_71_2 := .f. ; lstkol := kvp_2_78 := 0
is_2_78 := is_2_79 := is_2_80 := is_2_81 := is_2_82 := .f. ; lstshifr := ""
midsp := musl_ok := mRSLT_NEW := mprofil := mvrach := 0
f_put_glob_podr(human_->USL_OK,d2,ta) // заполнить код подразделения 
select HU
find (str(human->kod,7))
do while hu->kod == human->kod .and. !eof()
  mdate := c4tod(hu->date_u)
  if !between(mdate,d1,d2)
    aadd(ta,'услуга '+alltrim(usl->shifr)+'('+date_8(mdate)+') не попадает в диапазон лечения')
  endif
  lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
  is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,@auet)
  is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,@auet,,@lst)
  if f_paraklinika(usl->shifr,lshifr1,human->k_data)
    lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
    if lst == 1
      k := 0 ; lstshifr := "" ; lstkol := hu->kol_1
      for i := 1 to len(lshifr)
        c := substr(lshifr,i,1)
        lstshifr += c
        if c == "." ; ++k ; endif
        if k == 2 ; exit ; endif
      next
    endif
    otd->(dbGoto(hu->OTD))
    aadd(au_lu,{lshifr,mdate,hu_->profil,hu_->PRVS})
    mdate_u1 := dtoc4(human->n_data)
    mdate_u2 := hu->date_u
    if left(lshifr,2) == "1."
      musl_ok := 1  // стационар
      mdate_u2 := dtoc4(human->k_data)
      if left(lshifr,4) == "1.7."
        midsp := 18 // Законченный случай в круглосуточном стационаре
        kkd_1_7 += hu->kol_1
        i := int(val(substr(lshifr,5)))
        fl_1_7_12 := between(i,1,12)  // от 1.7.1  до 1.7.12
        fl_1_7_53 := between(i,53,57) // от 1.7.53 до 1.7.57
        ZakSluchAccordanceDiagnoz(lshifr,mdiagnoz,ta)
      elseif left(lshifr,5) == "1.10."
        midsp := 18 // Законченный случай в круглосуточном стационаре
        kkd_1_10 += hu->kol_1
        ZakSluchAccordanceDiagnoz(lshifr,mdiagnoz,ta)
      elseif left(lshifr,4) == "1.9."
        midsp := 14 // Лечение в профильном отделении стационара
        kkd_1_9 += hu->kol_1
      else
        midsp := 5 // Койко-день в круглосуточном стационаре
        kkd += hu->kol_1
      endif
    elseif left(lshifr,3) == "55."
      musl_ok := 2  // дн.стационар
      mdate_u2 := dtoc4(human->k_data)
      if left(lshifr,5) == "55.2." // дн.стац. при б-це
        midsp := 6
        kds += hu->kol_1
      elseif left(lshifr,5) == "55.3." // дн.стац. при п-ке
        midsp := 7
        kds += hu->kol_1
      elseif left(lshifr,5) == "55.4." // стационар на дому
        midsp := 8
        kds += hu->kol_1
      elseif left(lshifr,5) == "55.5." // Законченный случай в дн.стац. при б-це
        midsp := 19
        kds += d+1
      elseif left(lshifr,5) == "55.6." // Законченный случай в дн.стац. при п-ке
        midsp := 20
        kds += d+1
      elseif left(lshifr,5) == "55.7." // Законченный случай в стационаре на дому
        midsp := 21
        kds += d+1
      endif
      if eq_any(alltrim(lshifr),"55.4.2","55.7.8") // перитонеальный диализ
        is_perito := .t.
      endif
    elseif left(lshifr,5) == "60.2."  // ЛДП
      mIDSP := 4 // лечебно-диагностическая процедура
      kkt += hu->kol_1
      if eq_any(alltrim(lshifr),"60.2.1","60.2.2","60.2.8")
        is_kt := .t.
      endif
      if eq_any(alltrim(lshifr),"60.2.3","60.2.4")
        is_mrt := .t.
      endif
      if d2_year > 2012
        musl_ok := 3  // п-ка
      endif
    elseif eq_any(left(lshifr,5),"71.1.","71.2.")  // скорая помощь
      musl_ok := 4  // СМП
      mIDSP := 24 // Вызов скорой медицинской помощи
      if left(lshifr,5) == "71.1."
        is_71_1 := .t.
      else
        is_71_2 := .t.
      endif
      ksmp += hu->kol_1
    else
      musl_ok := 3  // п-ка
      mIDSP := 1 // Посещение в поликлинике
      if left(lshifr,5) == "2.76."
        mIDSP := 12 // Комплексная услуга центра здоровья
      elseif left(lshifr,5) == "2.78."
        ++kvp_2_78
        is_2_78 := .t.
        mIDSP := 17 // Законченный случай в поликлинике
      elseif left(lshifr,5) == "2.79."
        is_2_79 := .t.
      elseif left(lshifr,5) == "2.80."
        is_2_80 := .t.
      elseif left(lshifr,5) == "2.81."
        is_2_81 := .t.
      elseif left(lshifr,5) == "2.82."
        is_2_82 := .t.
        mIDSP := 22 // Посещение в приёмном покое
      elseif left(lshifr,5) == "70.1."
        mIDSP := 11 // Дополнительная диспансеризация
        mRSLT_NEW := 312
        fl_70_1 := .t.
        if mdate < stod("20110901")
          aadd(a_h,'Услуга '+rtrim(lshifr)+' оказана ранее 1 сентября')
        endif
      elseif left(lshifr,3) == "57."
        mIDSP := 4 // лечебно-диагностическая процедура
        mpzkol := hu->kol_1*iif(human->vzros_reb==0, auet[1], auet[2])
        kol_uet += mpzkol
      endif
      kvp += hu->kol_1
    endif
    if musl_ok != 3 .and. !(hu->date_u==mdate_u1) .and. len(au_lu) == 1
      aadd(ta,'дата услуги '+alltrim(lshifr)+' должна равняться дате начала лечения')
    endif
    hu_->date_u2 := mdate_u2
    fl_del := fl_uslc := .f.
    v := fcena_oms(lshifr,;
                   (human->vzros_reb==0),;
                   human->k_data,;
                   @fl_del,;
                   @fl_uslc)
    if fl_uslc  // если нашли в справочнике ТФОМС
      if fl_del
        aadd(ta,'Цена на услугу '+rtrim(lshifr)+' отсутствует в справочнике ТФОМС')
      elseif !(round(v,2) == round(hu->u_cena,2))
        aadd(ta,'Ошибка в цене услуги['+;
                iif(human->vzros_reb==0,'взр','реб')+;
                ']: '+rtrim(lshifr)+": "+lstr(hu->u_cena,9,2)+;
                ", должно быть: "+lstr(v,9,2))
      endif
      if !(round(hu->u_cena*hu->kol_1,2) == round(hu->stoim_1,2))
        aadd(ta,'Услуга '+rtrim(lshifr)+': сумма строки '+;
                lstr(hu->stoim_1)+' не равна произведению '+;
                lstr(hu->u_cena)+" * "+lstr(hu->kol_1))
      endif
    endif
    ssumma += hu->stoim_1
  endif
  select HU
  skip
enddo
if !(round(human->cena_1,2) == round(ssumma,2))
  aadd(ta,'Сумма случая '+lstr(human->cena_1)+' не равна сумме услуг '+lstr(ssumma))
  aadd(ta,'Выполните ПЕРЕИНДЕКСИРОВАНИЕ и отредактируйте услуги в листе учёта')
endif
if empty(au_lu)
  aadd(ta,'Не введено ни одной услуги')
endif
if empty(human_->USL_OK)
  human_->USL_OK := musl_ok
endif
if is_2_78
  mIDSP := 17 // Законченный случай в поликлинике
endif
if empty(human_->IDSP)
  human_->IDSP := midsp
endif
if kkd_1_7 > 0
  if !fl_1_7_53 .and. d < iif(fl_1_7_12, 2, 4)
    aadd(ta,'для услуги 1.7.* слишком мал срок лечения')
  endif
elseif kkd_1_9 > 0
  if d < 4
    aadd(ta,'для услуги 1.9.* слишком мал срок лечения')
  endif
elseif kkd_1_10 > 0
  if d < 4
    aadd(ta,'для услуги 1.10.* слишком мал срок лечения')
  endif
elseif kkd > 0
  if empty(d) .and. kkd == 1
    // по-новому один койко-день
  elseif kkd > d
    aadd(ta,'кол-во койко-дней ('+lstr(kkd)+') превышает срок лечения на '+lstr(kkd-d))
  elseif kkd < d
    aadd(ta,'кол-во койко-дней ('+lstr(kkd)+') меньше срока лечения на '+lstr(d-kkd))
  elseif kkd > 3 .and. d2_year > 2012
    aadd(ta,'кол-во койко-дней ('+lstr(kkd)+') должно быть 1-3 дня')
  endif
elseif kds > 0
  if kds > (d+1)
    aadd(ta,'кол-во услуг дневного стационара ('+lstr(kds)+') превышает срок лечения')
  endif
elseif kkt > 0
  if is_kt
    if kkt > 2
      aadd(ta,'кол-во услуг КОМПЬЮТЕРНАЯ ТОМОГРАФИЯ ('+lstr(kkt)+') не должно быть более 2')
    endif
  elseif is_mrt
    if kkt > 2
      aadd(ta,'кол-во услуг МРТ ('+lstr(kkt)+') не должно быть более 2')
    endif
  elseif alltrim(au_lu[1,1]) == '60.2.5'
    if month(d1) != month(d2)
      aadd(ta,'для услуги гемодиализа случай должен быть в одном отчётном месяце')
    endif
  else // 60.2.6 Ангиография   60.2.7 Коронарография
    if kkt > 2
      aadd(ta,'кол-во услуг ('+lstr(kkt)+') не должно быть более 2')
    endif
  endif
elseif kvp > 0
  if d2 > d1 .and. (is_2_80 .or. is_2_81 .or. is_2_82)
    aadd(ta,'для данной услуги срок лечения - один день')
  endif
elseif ksmp > 0
  if ksmp > 1
    aadd(ta,'количество услуг СМП должно быть равно 1')
  endif
  if len(au_lu) > 1
    aadd(ta,'кроме услуги 71.* в листе учета не должно быть других услуг ТФОМС')
  endif
  if human_->USL_OK != 4
    aadd(ta,'для услуги СМП условия должны быть "Скорая помощь"')
  endif
  if human_->PROFIL != 84
    aadd(ta,'для услуги СМП профиль должен быть "скорой медицинской помощи"')
  endif
  if human_->IDSP != 24
    aadd(ta,'для услуги СМП способ оплаты должен быть "Вызов скорой медицинской помощи"')
  endif
  if d1 < d2
    aadd(ta,'для скорой помощи дата начала должна равняться дате окончания лечения')
  endif
  if is_komm_SMP() // если это коммерческая скорая
    if is_71_1
      aadd(ta,'для коммерческой СМП необходимо применять услуги 71.2.*')
    endif
  elseif human_->OKATO == '18000'
    if is_71_2
      aadd(ta,'для пациентов, застрахованных на территории Волгоградской области,')
      aadd(ta,'необходимо применять услуги 71.1.*')
    endif
  else
    if is_71_1
      aadd(ta,'для пациентов, застрахованных за пределами Волгоградской области,')
      aadd(ta,'необходимо применять услуги 71.2.*')
    endif
  endif
endif
if human_->USL_OK == 4 .and. !is_71_1 .and. !is_71_2
  aadd(ta,'для условия "Скорая помощь" не введены услуги СМП')
endif
if len(ta) > 0
  _ocenka := 0
  verify_FF(80-len(ta)-3,.t.,80)
  add_string("")
  add_string(alltrim(human->fio)+" "+;
             date_8(human->n_data)+"-"+date_8(human->k_data))
  add_string(" "+alltrim(uch->name)+"/"+alltrim(otd->name))
  aeval(ta, {|x| add_string("- "+x) })
endif
return (_ocenka >= 5)

*

*****
Function other_schet_vyp()
Local mas_pmt := {"Выписать ~один счет"},;
      mas_msg := {"Выписать один (прочий) счет"},;
      mas_fun := {"vyp1other_schet()"}
if is_0_schet == 1
  aadd(mas_pmt, "Выписать счет с ~нулевой суммой")
  aadd(mas_msg, "Выписать счет с нулевой суммой (по параклинике)")
  aadd(mas_fun, "vyp0other_schet()")
endif
if len(mas_pmt) == 1
  return &(mas_fun[1])
else
  popup_prompt(T_ROW,T_COL+5,1,mas_pmt,mas_msg,mas_fun)
endif
return NIL

*****
Function func2_komu(kod_komu,kod_str_crb,r,c,fl_top)
Local i, k, r1, r2, mmenu := {"~Прочие компании",;
                              "~Комитеты (МО)",;
                              "~Личный счет"}
DEFAULT kod_komu TO glob_komu
if fl_top == NIL
  fl_top := (r < 12)
endif
if !(kod_komu == 2 .or. kod_komu == 5) .and. type("mstr_crb") == "N"
  kod_str_crb := mstr_crb
endif
if (i := popup_prompt(if(fl_top,r+1,r-7),c,kod_komu,mmenu)) > 0
  r1 := if(fl_top, r+1, 2)
  r2 := if(fl_top, r+10, r-1)
  glob_komu := i
  do case
    case i == 1
      DEFAULT kod_str_crb TO glob_strah[1]
      if (k := popup_edit(dir_server+"str_komp",r1,c,r2,kod_str_crb,;
          PE_RETURN,,,,{||!between(tfoms,44,47)},,,fl_top,"Прочие компании",col_tit_popup)) != NIL
        pp_str_crb := mstr_crb := k[1]
        glob_all := glob_strah := k
        return {1,"СМО - "+alltrim(k[2])}
      endif
    case i == 2
      DEFAULT kod_str_crb TO glob_komitet[1]
      if (k := popup_edit(dir_server+"komitet",r1,c,r2,kod_str_crb,;
             PE_RETURN,,,,,,,fl_top,"Комитеты (МО)",col_tit_popup)) != NIL
        pp_str_crb := mstr_crb := k[1]
        glob_all := glob_komitet := k
        return {3,alltrim(k[2])}
      endif
    case i == 3
      glob_all := {0,"Личный счет"}
      pp_str_crb := mstr_crb := 0
      return {5,"Личный счет"}
  endcase
endif
return NIL

*

***** Выписать счет с нулевой суммой (по параклинике)
Function vyp0other_schet()
Local buf := save_maxrow(), k := 0, s1, s2, adbf
Private pkol := 0, psumma := 0, par_ns := 1
gnevyp_schet := .f.
mywait()
adbf := {;
    {"KOMU"     ,   "N",     1,     0},;
    {"STR_CRB"  ,   "N",     2,     0},;
    {"MIN_DATE" ,   "D",     8,     0},;
    {"DNI"      ,   "N",     3,     0},;
    {"KOL_BOLN" ,   "N",     6,     0},;
    {"SUMMA"    ,   "N",    13,     2},;
    {"NKOMU"    ,   "C",    80,     0},;
    {"KOD"      ,   "N",     7,     0},;
    {"PLUS"     ,   "L",     1,     0}}
dbcreate(cur_dir+"tmp",adbf)
Use (cur_dir+"tmp") alias TMP
index on str(komu,1)+str(str_crb,2) to (cur_dir+"tmp")
index on nkomu to (cur_dir+"tmp1")
Use (cur_dir+"tmp") index (cur_dir+"tmp"),(cur_dir+"tmp1") alias TMP
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
set relation to recno() into HUMAN_
find (str(0,6)+str(B_STANDART,1))
do while human->schet == 0 .and. human->tip_h == B_STANDART .and. !eof()
  if human_->reestr == 0 .and. ;
       empty(human->cena_1) .and. human->komu > 0 .and. empty(val(human_->smo))
    mstr_crb := iif(human->komu==5,0,human->str_crb)
    select TMP
    find (str(human->komu,1)+str(mstr_crb,2))
    if found() .and. human->komu != 5
      tmp->kol_boln++
      tmp->summa += human->cena_1
      tmp->min_date := min(tmp->min_date,human->k_data)
    else
      k++
      append blank
      replace tmp->komu with human->komu, ;
              tmp->str_crb with mstr_crb,;
              tmp->kol_boln with 1, tmp->summa with human->cena_1,;
              tmp->min_date with human->k_data, ;
              tmp->plus with .t.
      if human->komu == 5
        replace tmp->nkomu with " Личн.счет - "+alltrim(human->fio)+", "+;
                      left(dtoc(human->n_data),5)+"-"+date_8(human->k_data),;
                tmp->kod with human->kod
      endif
    endif
    pkol++ ; psumma += human->cena_1
  endif
  select HUMAN
  skip
enddo
if k == 0
  rest_box(buf)
  func_error(4,"Не обнаружено больных с нулевой суммой случая, по которым не выписаны счета!")
else
  human_->(dbCloseArea())
  human->(dbCloseArea())
  select TMP
  set order to 0
  go top
  do while !eof()
    if tmp->komu != 5
      tmp->nkomu := func1_komu(tmp->komu,tmp->str_crb)
    endif
    k := sys_date - tmp->min_date
    tmp->dni := iif(between(k,1,999), k, -99)
    skip
  enddo
  set order to 2
  go top
  rest_box(buf)
  s1 := " Общее количество больных - "+expand_value(pkol)+" чел. "
  s2 := " Общая сумма счетов - "+expand_value(psumma,2)+" руб. "
  k := 80-max(len(s1),len(s2))
  buf := box_shadow(T_ROW-3,k,T_ROW-2,79,color1,,,0)
  @ T_ROW-3,k say s1 color color8
  @ T_ROW-2,k say s2 color color8
  if Alpha_Browse(T_ROW,0,23,79,"f1nevyp_schet",color0,;
                  "Невыписанные счета с нулевой суммой","R/BG",,,,,"f2nevyp_schet",,;
                  {'═','░','═',"N/BG,W+/N,B/BG,W+/B,R/BG",.f.,0} )
    gnevyp_schet := .t.
    if (glob_komu := tmp->komu) == 1
      glob_strah[1] := tmp->str_crb
    elseif glob_komu == 3
      glob_komitet[1] := tmp->str_crb
    endif
    glob_all := {tmp->str_crb,rtrim(tmp->nkomu)}
    if glob_komu == 5
      glob_all := {tmp->kod,rtrim(tmp->nkomu)}
    endif
    close databases
    Private p_0_schet := .t.
    vyp1other_schet(.t.,glob_komu,glob_all[1])
  endif
  rest_box(buf)
endif
close databases
return NIL

*

*****
Function vyp1other_schet(is_nul,lkomu,lstr_crb)
Local buf := save_maxrow(), buf1
Local mas_pmt, mas_fun, mas1_pmt, dbf_tmp, lrzs
Local i, j, k, k1 := 0, tmp1, tmp2, lOldDeleted, ;
      tmp_arr, tmp1_arr, fl_err := .f., larr_r := {}
DEFAULT is_nul TO .f.
mas_pmt := {"Предварительный просмотр ~счета",;
            "Предварительный просмотр ~листов учета",;
            "~Исключение из счета некоторых больных",;
            "~Выписка счета"}
mas_fun := {"print_other_schet()",;
            "pr_vklad(1)",;
            "f1vyp_schet()",;
            "f2vyp_schet()"}
dbf_tmp := {;
  {"KOD"      ,   "N",     7,     0},;
  {"NOMER"    ,   "N",     6,     0},;
  {"KOD_K"    ,   "N",     7,     0},;
  {"N_DATA"   ,   "D",     8,     0},; // дата начала лечения
  {"K_DATA"   ,   "D",     8,     0},; // дата окончания лечения
  {"FIO"      ,   "C",    50,     0},; // Ф.И.О. больного
  {"DATE_R"   ,   "D",     8,     0},; // дата рождения
  {"VZROS_REB",   "N",     1,     0},; // 0-взрослый, 1 -ребенок, 2-подросток
  {"CENA"     ,   "N",    12,     2},; // стоимость лечения
  {"RAB_NERAB",   "N",     1,     0},; // 0-работающий, 1 -неработающий
  {"PLUS"     ,   "L",     1,     0}}  // включается ли в счет
mas1_pmt := {"Выписать счет по всем ~больным",;
             "Выписать счет по ~условию"}
Private p_1, p_2, ob_summa := 0, ob_kol, str_kriterij := "Все больные",;
        muslovie := ".t.", mmax_kol := 999
Private mn1_data := ctod(""), mn2_data := ctod(""),;
        mk1_data := ctod(""), mk2_data := ctod("")
Private p_number := "___", p_date := ctod("")
if iif(lkomu != NIL, .t., (k := func2_komu(,,T_ROW-1,T_COL+6)) != NIL)
  if lkomu == NIL
    glob_komu := k[1]
  else
    k := {glob_komu,glob_all[2]}
  endif
  if glob_komu == 5 // меню людей с личными счетами
    dbcreate(cur_dir+"tmp",dbf_tmp)
    Use (cur_dir+"tmp") alias TMP
    index on upper(fio) to (cur_dir+"tmp")
    R_Use(dir_server+"human",dir_server+"humans","HUMAN")
    find (str(0,6)+str(B_STANDART,1))
    do while human->schet == 0 .and. human->tip_h == B_STANDART .and. !eof()
      if iif(is_nul, empty(human->CENA_1), human->CENA_1 > 0) ;
                                                     .and. human->komu == 5
        k1++
        select TMP
        append blank
        replace tmp->KOD    with human->KOD ,;
                tmp->KOD_K  with human->KOD_K ,;
                tmp->n_data with human->n_data,;
                tmp->k_data with human->k_data,;
                tmp->FIO    with human->FIO ,;
                tmp->date_r with human->date_r,;
                tmp->CENA   with human->CENA_1,;
                tmp->PLUS   with .t.
      endif
      select HUMAN
      skip
    enddo
    j := 0
    select TMP
    go top
    do while !eof()
      tmp->NOMER := ++j
      skip
    enddo
    close databases
    if k1 == 0
      rest_box(buf)
      return func_error(4,"Не найдено людей с личными счетами!")
    endif
    Use (cur_dir+"tmp") index (cur_dir+"tmp") alias TMP
    if lkomu != NIL
      Locate for kod == glob_all[1]
      if !found()
        go top
      endif
    endif
    if Alpha_Browse(T_ROW,2,maxrow()-2,77,"f2pr_vklad",color0,;
                "Выбор больного для выписки личного счета","R/BG",.t.,,,,,,;
                {'═','░','═',,,0} )
      glob_all := {tmp->kod,alltrim(tmp->fio)}
      close databases
    else
      close databases
      rest_box(buf)
      return NIL
    endif
    k1 := 0
  endif
  dbcreate(cur_dir+"tmp",dbf_tmp)
  Use (cur_dir+"tmp") alias TMP
  index on upper(fio) to (cur_dir+"tmp")
  k1 := 0
  if glob_komu == 5
    R_Use(dir_server+"human",,"HUMAN")
    goto (glob_all[1])
    k1++
    select TMP
    append blank
    replace tmp->KOD       with human->KOD      ,;
            tmp->KOD_K     with human->KOD_K ,;
            tmp->n_data    with human->n_data,;
            tmp->k_data    with human->k_data   ,;
            tmp->FIO       with human->FIO      ,;
            tmp->date_r    with human->date_r,;
            tmp->VZROS_REB with human->VZROS_REB,;
            tmp->CENA      with human->CENA_1   ,;
            tmp->RAB_NERAB with human->RAB_NERAB,;
            tmp->PLUS      with .t.
    k := {5,"Личный счет - "+rtrim(human->fio)}
    glob_all := {0,""}
  else
    R_Use(dir_server+"uslugi",,"USL")
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    set relation to u_kod into USL
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humans","HUMAN")
    set relation to recno() into HUMAN_
    find (str(0,6)+str(B_STANDART,1))
    do while human->schet == 0 .and. human->tip_h == B_STANDART .and. !eof()
      if iif(is_nul, empty(human->CENA_1), human->CENA_1 > 0) ;
           .and. human_->reestr == 0 .and. empty(val(human_->smo)) .and. ;
           human->komu == glob_komu .and. human->str_crb == glob_all[1]
        k1++
        select TMP
        append blank
        replace tmp->KOD       with human->KOD      ,;
                tmp->KOD_K     with human->KOD_K ,;
                tmp->n_data    with human->n_data,;
                tmp->k_data    with human->k_data   ,;
                tmp->FIO       with human->FIO      ,;
                tmp->date_r    with human->date_r,;
                tmp->VZROS_REB with human->VZROS_REB,;
                tmp->CENA      with human->CENA_1   ,;
                tmp->PLUS      with .t.
      endif
      select HUMAN
      skip
    enddo
  endif
  j := 0
  select TMP
  go top
  do while !eof()
    tmp->NOMER := ++j
    skip
  enddo
  close databases
  rest_box(buf)
  if k1 == 0
    func_error(4,"Некого включать в данный счет!")
  else
    s_lpu_smo := k[2]
    buf := savescreen()
    box_shadow(0,2,3,77,color1,"Информация о счете",color8,0)
    setcolor(color1)
    @ 1,4 say s_lpu_smo color "BG+/B"
    @ 2,6 say "Количество больных: "+lstr(k1)+" чел."
    setcolor(color0)
    if (k1 := iif(glob_komu==5, 1, popup_prompt(T_ROW,T_COL+6,1,mas1_pmt))) > 0
      if iif(k1 == 1, .t., usl_vyp_schet()) // выписать счет по условию
        mywait()
        lOldDeleted := SET(_SET_DELETED, .F.)
        Use (cur_dir+"tmp") index (cur_dir+"tmp")
        go top
        i := ob_summa := ob_kol := 0
        do while !eof()
          if &muslovie .and. ob_kol < mmax_kol
            ob_kol++ ; ob_summa += tmp->cena
          else
            i++
            delete
          endif
          skip
        enddo
        if i > 0
          Pack
          j := 0
          select TMP
          go top
          do while !eof()
            tmp->NOMER := ++j
            skip
          enddo
        endif
        Use
        SET(_SET_DELETED, lOldDeleted)  // Восстановление среды _SET_DELETED
        restscreen(buf)
        box_shadow(0,2,5,77,color1,"Информация о счете",color8,0)
        setcolor(color1)
        @ 1,4 say s_lpu_smo color "BG+/B"
        @ 2,10 say "Количество больных в счете: "+expand_value(ob_kol)+" чел."
        @ 3,10 say "Сумма счета: "+expand_value(ob_summa,2)+" руб."
        setcolor(color0)
        if ob_kol == 0
          func_error(4,"По выбранному критерию нет больных!")
        else
          if ob_kol == 1
            Del_Array(mas_pmt,3)
            Del_Array(mas_fun,3)
          endif
          popup_prompt(T_ROW-len(mas_pmt)-3,T_COL+6,1,mas_pmt,,mas_fun)
        endif
      endif
    endif
    restscreen(buf)
  endif
endif
gnevyp_schet := .f.
return NIL

*****
Function pr_vklad(k)
Local i := 1, buf := savescreen()
Private is_spisok := .t., p_k := k
use (cur_dir+"tmp") index (cur_dir+"tmp") new
if lastrec() == 1
  keyboard chr(K_ENTER)
endif
Alpha_Browse(T_ROW,2,maxrow()-2,77,"f2pr_vklad",color0,;
             "Выбор больного","R/BG",.t.,,,,"f9pr_vklad",,;
             {'═','░','═',,.t.,0} )
close databases
restscreen(buf)
return NIL

*****
Function f2pr_vklad(oBrow)
Local oColumn, n := 40
oColumn := TBColumnNew(" №№; пп", {|| str(tmp->nomer,4) })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(center("Ф.И.О. больного",n),{|| left(tmp->fio,n)})
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("На-;чало",{|| left(date_8(tmp->k_data),5) })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Оконч.;лечения",{|| date_8(tmp->k_data) })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("   Сумма", {|| padl(expand_value(tmp->cena,2),13) })
oBrow:addColumn(oColumn)
if type("is_spisok") == "L" .and. is_spisok
  status_key("^^,нач.буква - просмотр;  ^<Esc>^-выход;  ^<Enter>^-печать;  ^<F9>^-печать списка")
endif
return NIL

*****
Function f9pr_vklad(nKey,oBrow)
Static srazmer := 0
Local k := -1, rec, hGauge, i, j, n, nrec, l, arr, lkod, lnomer,;
      n_file, buf := savescreen()
do case
  case nKey == K_ENTER // печать 1 листа учета
    rec := tmp->(recno()) ; lkod := tmp->kod ; lnomer := tmp->nomer
    close databases
    print_l_uch( lkod, 2, p_k, lnomer )
    use (cur_dir+"tmp") index (cur_dir+"tmp") new
    goto (rec)
  case nKey == K_F9 // непрерывная печать листов учета
    f_message({"","При просмотре списка листов учета",;
               "комбинация клавиш <Ctrl+F10> позволяет",;
               "вызвать на экран справочник диагнозов",;
               ""},,"B/W","N/W")
    if (i := input_value(20,2,22,77,"N/W,GR+/R",;
        "Введите стоимость лечения, выше которой распечатываются л/учета",;
                    srazmer,"9999999")) != NIL
      srazmer := i
      ClrLine(24,color0)
      rec := tmp->(recno()) ; nrec := tmp->(lastrec()) ; n := 0
      hGauge := GaugeNew(,,{"GR+/RB","BG+/RB","G+/RB"},"Печать листов учета",.t.)
      GaugeDisplay( hGauge )
      //
      dbcreate(cur_dir+"tmps",{{"nomer","N",4,0},;
                               {"stroke","C",80,0}})
      use (cur_dir+"tmps") new
      index on str(nomer,4) to (cur_dir+"tmps")
      //
      dbcreate(cur_dir+"tmpd",{{"nomer","N",4,0},;
                               {"kol_s","N",3,0}})
      use (cur_dir+"tmpd") new
      index on str(kol_s,3) to (cur_dir+"tmpd")
      //
      dbcreate(cur_dir+"tmp1",{{"kod","N",4,0},;
                               {"name","C",65,0},;
                               {"shifr","C",10,0},;
                               {"plus","L",1,0},;
                               {"kol","N",4,0},;
                               {"summa","N",11,2}})
      use (cur_dir+"tmp1") new
      index on str(kod,4) to (cur_dir+"tmp11")
      index on fsort_usl(shifr) to (cur_dir+"tmp12")
      set index to (cur_dir+"tmp11"),(cur_dir+"tmp12") 
      //
      R_Use(dir_server+"uslugi",dir_server+"uslugi","USL")
      R_Use(dir_server+"human_u",dir_server+"human_u","HU")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",dir_server+"humank","HUMAN")
      set relation to recno() into HUMAN_
      for i := 1 to nrec
        select TMP
        goto (i)
        if tmp->cena >= srazmer
          ++n
          arr := f91pr_vklad(tmp->kod, tmp->nomer)
          for j := 1 to len(arr)
            select TMPS
            append blank
            tmps->nomer := n
            tmps->stroke := arr[j]
          next
          select TMPD
          append blank
          tmpd->nomer := n
          tmpd->kol_s := len(arr)
        endif
        GaugeUpdate( hGauge, i/nrec )
      next
      CloseGauge(hGauge)
      if n == 0
        func_error(4,"В счете нет больных со стоимостью лечения больше "+lstr(srazmer)+" руб.")
      endif
      tmp1->(dbCloseArea())
      usl->(dbCloseArea())
      hu->(dbCloseArea())
      human_->(dbCloseArea())
      human->(dbCloseArea())
      if n > 0
        mywait() ; i := 0 ; n_file := "list_uch"+stxt
        fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
        add_string("Приложение к счету № "+alltrim(p_number)+" от "+dtoc(p_date)+" г.")
        add_string("")
        add_string(center("Листы учета пролеченных больных [ >="+lstr(srazmer)+"руб. ]",80))
        add_string("")
        add_string(replicate(".",80))
        select TMPD
        go top
        do while !eof()
          if tek_stroke + tmpd->kol_s > 80
            add_string(chr(12)) ; tek_stroke := 0 ; ++n_list
          elseif tek_stroke > 0 .and. i > 0
            add_string(replicate(".",80))
          endif
          ++i
          select TMPS
          find (str(tmpd->nomer,4))
          do while tmps->nomer == tmpd->nomer
            verify_FF(80)
            add_string(rtrim(tmps->stroke))
            skip
          enddo
          select TMPD
          skip
        enddo
        fclose(fp)
        set key K_CTRL_F10 to f10pr_vklad
        viewtext(n_file,,,,.f.,,,5)
        set key K_CTRL_F10 to
      endif
      tmps->(dbCloseArea())
      tmpd->(dbCloseArea())
      select TMP
      goto (rec)
    endif
    restscreen(buf)
endcase
return k

*****
Function f91pr_vklad(mkod, mnomer)
// mkod - код больного по БД human
// mnomer - номер больного по счету
Local sh := 80, arr := {}, arr1, msumma := 0, adiag_talon[16],;
      i := 1, j, k, s, tmp[2], tmp1, w1 := 65, mishod, mprodol, ;
      lshifr1, fl_parakl, fl_plus, mpsumma
//
select TMP1
set order to 1
zap
select HUMAN
find (str(mkod,7))
aadd(arr, "")
aadd(arr, padr("№ "+lstr(mnomer)+".  "+human->fio,sh-27)+;
          padl("Дата рождения: "+full_date(human->date_r),27))
afill(adiag_talon,0)
for i := 1 to 16
  adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
next
arr1 := diag_to_array(,.t.,.t.,.t.,.t.,adiag_talon)
aadd(arr, "  Шифр основного заболевания: "+arr1[1])
if len(arr1) > 1
  tmp1 := "  Шифры сопутствующих заболеваний:"
  for j := 2 to len(arr1)
    tmp1 += " "+arr1[j]
  next
  aadd(arr, tmp1)
endif
aadd(arr, "  Результат обращения: "+inieditspr(A__MENUVERT, glob_V009, human_->RSLT_NEW))
aadd(arr, "  Исход заболевания: "+inieditspr(A__MENUVERT, glob_V012, human_->ISHOD_NEW))
aadd(arr, "  Срок лечения с "+full_date(human->n_data)+" по "+full_date(human->k_data))
Select HU
find (str(mkod,7))
do while hu->kod == mkod .and. !eof()
  if !emptyall( hu->kol_1, hu->stoim_1 )
    Select USL
    dbSeek(str(hu->u_kod,4))
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    select TMP1
    find (str(usl->kod,4))
    if !found()
      append blank
      tmp1->kod := usl->kod
      tmp1->name := usl->name
      tmp1->shifr := if(empty(lshifr1), usl->shifr, lshifr1)
    endif
    tmp1->plus := !f_paraklinika(usl->shifr,lshifr1,human->k_data)
    tmp1->kol += hu->kol_1
    tmp1->summa += hu->stoim_1
  endif
  select HU
  Skip
enddo
mpsumma := 0
select TMP1
set order TO 2
go top
aadd(arr, "--------------------------------------------------------------------------------")
aadd(arr, "                      Наименование услуги                       | Кол |  Сумма  ")
aadd(arr, "--------------------------------------------------------------------------------")
do while !eof()
  k := perenos(tmp,tmp1->shifr+" "+tmp1->name,w1)
  if tmp1->plus
    aadd(arr, padr(tmp[1],65)+padl("+"+lstr(tmp1->kol),4)+" "+put_kopE(tmp1->summa,10))
    mpsumma += tmp1->summa
  else
    aadd(arr, padr(tmp[1],66)+put_val(tmp1->kol,3)+" "+put_kopE(tmp1->summa,10))
    msumma += tmp1->summa
  endif
  if k > 1
    aadd(arr, padl(rtrim(tmp[2]),w1))
  endif
  skip
enddo
aadd(arr, space(45)+replicate("-",sh-45))
//msumma := round(msumma,2)
msumma := human->cena_1
s := "Общая сумма лечения: "+put_kop(msumma,12)
if mpsumma > 0
  s := alltrim(s)+" (+"+lput_kop(mpsumma,.t.)+")"
endif
aadd(arr, padl(s,sh))
return arr

*****
Function f10pr_vklad()
set key K_CTRL_F10 to
f10_diagnoz()
set key K_CTRL_F10 to f10pr_vklad
return NIL

*

***** 05.12.12 печать прочего счёта
Function print_other_schet(is_vyp,is_usl,n_file)
Local sh := 169, HH := 40, regim := 3, buf := save_maxrow(), ;
      tmp, tmp1, tmp2 := "", mcena_1, hGauge, lshifr1,;
      name_lpu, name_otd, mvzros_reb, mmest_inog, mrab_nerab, ;
      mkomu, fl_parakl, mdate, r1, c1,;
      i:=1, j:=0, k, k1, k2, k3, k4, k5, srok_lech, ;
      a_fio[8], a_polis[8], a_adres[8], a_rabota[8], a_shifr[8], a_mesto_l[8], j1, ;
      tel_org, razmer_usl := 0, is_view := .t., mdate_r[10], arr
DEFAULT is_vyp TO 0,;  // по умолчанию счет еще не выписан
        n_file TO "schet_o"+stxt
Private name_org, adres_org, inn_org, pok_name, pok_adres, pok_inn,;
        schet_org, bank_org, mfo_org, mkorr_schet,;
        mfio_ruk, mfio_bux, ob_summa := 0, pj
if is_usl == NIL
  is_usl := 1
else
  is_view := .f.
endif
mywait()
delFRfiles()
name_lpu := rtrim(glob_uch[2])
adbf := {{"name_org","C",130,0},;
         {"adres_org","C",110,0},;
         {"inn_org","C",30,0},;
         {"tel_org","C",20,0},;
         {"bank_org","C",130,0},;
         {"schet_org","C",45,0},;
         {"korr_schet","C",45,0},;
         {"bik","C",10,0},;
         {"ruk","C",20,0},;
         {"bux","C",20,0},;
         {"komu","C",80,0},;
         {"nschet","C",20,0},;
         {"dschet","D",8,0},;
         {"ssumma","C",250,0},;
         {"summa","N",15,2},;
         {"kol","N",6,0}}
dbcreate(fr_titl, adbf)
R_Use(dir_server+"organiz",,"ORG")
use (fr_titl) new alias FRT
append blank
frt->name_org := name_org := alltrim(org->name)
frt->adres_org := adres_org := alltrim(org->adres)
frt->inn_org := inn_org := iif(empty(org->inn), "", ", ИНН "+org->inn)
frt->tel_org := tel_org := iif(empty(org->telefon), "", " тел."+org->telefon)
frt->schet_org := schet_org := alltrim(org->r_schet)
frt->korr_schet := mkorr_schet := alltrim(org->k_schet)
frt->bank_org := bank_org := alltrim(org->bank)
frt->bik := mfo_org := alltrim(org->smfo)
frt->ruk := mruk := alltrim(org->ruk)
frt->bux := mbux := alltrim(org->bux)
org->(dbCloseArea())
//
adbf := {{"nomer","N",4,0},;
         {"fio","C",50,0},;
         {"pol","C",10,0},;
         {"date_r","D",8,0},;
         {"otd","C",100,0},;
         {"pasport","C",50,0},;
         {"adresp","C",250,0},;
         {"adresg","C",250,0},;
         {"snils","C",50,0},;
         {"mr_dol","C",50,0},;
         {"diagnoz","C",100,0},;
         {"s_lech","C",20,0},;
         {"stoim","N",12,2},;
         {"uslugi","C",250,0}}
dbcreate(fr_data,adbf)
use (fr_data) new alias FRD
index on str(nomer,4) to (fr_data)
//
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
if is_usl == 1
  dbcreate(cur_dir+"tmp1",{{"shifr","C",10,0},;
                           {"kol",  "N", 4,0},;
                           {"data", "D", 8,0}} )
  use (cur_dir+"tmp1") new
  index on shifr+dtos(data) to (cur_dir+"tmp11")
  index on fsort_usl(shifr)+dtos(data) to (cur_dir+"tmp12")
  set index to (cur_dir+"tmp11"),(cur_dir+"tmp12")
endif
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"uslugi",dir_server+"uslugi","USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
if is_vyp == 1
  dbcreate(cur_dir+"tmp",{{"kod","N",7,0},{"fio","C",50,0}})
  use (cur_dir+"tmp") new
  select HUMAN
  set index to (dir_server+"humans")
  find (str(schet->kod,6))
  do while human->schet == schet->kod .and. !eof()
    select TMP
    append blank
    tmp->kod := human->kod
    tmp->fio := human->fio
    select HUMAN
    skip
  enddo
  select TMP
  index on upper(fio) to (cur_dir+"tmp")
  use
  Private p_number := alltrim(schet->nomer_s), p_date := c4tod(schet->pdate)
endif
frt->nschet := p_number
frt->dschet := p_date
select HUMAN
set index to (dir_server+"humank")
set relation to recno() into HUMAN_, to otd into OTD, to kod_k into KART
Use (cur_dir+"tmp") index (cur_dir+"tmp") new alias TMP
go top
select HUMAN
find (str(tmp->kod,7))
if human->komu == 5
  mkomu := "( Личный счет )"
else
  mkomu := 'в "' + func1_komu(human->komu,human->str_crb)+'"'
endif
frt->komu := mkomu
//
add_string("ПОСТАВЩИК:  "+name_org+inn_org)
add_string("            "+adres_org+tel_org)
add_string("р/с N "+schet_org+" в "+bank_org+", БИК "+mfo_org+", кор/c "+mkorr_schet)
add_string(center("Счет N "+alltrim(p_number)+" от "+full_date(p_date)+" г.",sh))
add_string(center("на оплату медицинских услуг",sh))
add_string("")
add_string(center(mkomu,sh))
add_string("")
arr_title := {;
  "════╤════════════════════════╤═════════════╤══════════╤════════════════════════╤══════════════════════╤═══════════╤═══════════╤═════════╤══════════════════════╤═════════",;
  "    │                        │Серия и номер│          │                        │                      │   Шифры   │           │ Вид и   │                      │         ",;
  " NN │    Ф.И.О. больного     │ страхового  │   Дата   │     Домашний  адрес    │   Место работы или   │ основного │   Срок    │ номеp   │    Место лечения     │Стоимость",;
  " пп │                        │   полиса    │ рождения │                        │ причина безработности│и сопутств.│  лечения  │учетного │ (отделение, участок) │ лечения,",;
  "    │                        │             │          │                        │                      │заболеваний│           │документа│                      │  в pуб. ",;
  "────┼────────────────────────┼─────────────┼──────────┼────────────────────────┼──────────────────────┼───────────┼───────────┼─────────┼──────────────────────┼─────────",;
  "  1 │           2            │      3      │    4     │            5           │           6          │     7     │     8     │    9    │          10          │    11   ",;
  "════╧════════════════════════╧═════════════╧══════════╧════════════════════════╧══════════════════════╧═══════════╧═══════════╧═════════╧══════════════════════╧═════════"}
arr1title := {;
  "────┬────────────────────────┬─────────────┬──────────┬────────────────────────┬──────────────────────┬───────────┬───────────┬─────────┬──────────────────────┬─────────",;
  "  1 │           2            │      3      │    4     │            5           │           6          │     7     │     8     │    9    │          10          │    11   ",;
  "────┴────────────────────────┴─────────────┴──────────┴────────────────────────┴──────────────────────┴───────────┴───────────┴─────────┴──────────────────────┴─────────"}
aeval(arr_title, {|x| add_string(x) })
//
hGauge := GaugeNew(,,,"Составление счета",.t.)
GaugeDisplay( hGauge )
select TMP
go top
do while !eof()
  ++j
  GaugeUpdate( hGauge, j/lastrec() )
  Select HUMAN
  find (str(tmp->kod,7))
  if found()
    select FRD
    append blank
    frd->nomer := j
    frd->fio := human->fio
    frd->pol := iif(human->pol=="М","муж","жен")
    frd->date_r := human->date_r
    name_otd := alltrim(otd->name)
    mpolis := human->polis
    srok_lech := iif(human->n_data == human->k_data, dtoc(human->n_data), substr(dtoc(human->n_data),1,5)+"-"+substr(dtoc(human->k_data),1,5))
    frd->s_lech := srok_lech
    k1 := perenos(a_fio,human->fio,24)
    kp := perenos(a_polis,mpolis,13)
    tmp1 := ret_okato_ulica(kart->adres,kart_->okatog)
    frd->adresg := tmp1
    k2 := perenos(a_adres,tmp1,24," ,;")
    k3 := perenos(a_rabota,human->mr_dol,22)
    arr := diag_to_array(,.t.,,,.t.)
    tmp1 := ""
    aeval(arr, {|x| tmp1 += x+" " } )
    frd->diagnoz := tmp1
    k4 := perenos(a_shifr,tmp1,11)
    tmp := name_otd
    if fieldnum("uchastok") > 0
      tmp += ", участок-"+lstr(human->uchastok)
    endif
    frd->otd := tmp
    k5 := perenos(a_mesto_l,tmp,22," ,;")
    if verify_FF(HH,.t.,sh)
      aeval(arr1title, {|x| add_string(x) })
    endif
    mcena_1 := human->cena_1
    mdate_r := full_date(human->date_r)
    s := ""
    if !empty(kart_->ser_ud)
      s += alltrim(kart_->ser_ud)+" "
    endif
    if !empty(kart_->nom_ud)
      s += alltrim(kart_->nom_ud)
    endif
    if !empty(s) .and. (k := ascan(menu_vidud, {|x| x[2] == kart_->vid_ud})) > 0
      s := menu_vidud[k,4]+" "+s
    endif
    frd->pasport := s
    if !empty(kart->snils)
      frd->snils := transform(kart->SNILS,picture_pf)
    endif
    frd->mr_dol := human->mr_dol
    frd->stoim := human->cena_1
    add_string(put_val(j,4)+"."+padr(a_fio[1],24)+" "+;
               padc(alltrim(a_polis[1]),13)+;
               " "+mdate_r+" "+padr(a_adres[1],24)+" "+;
               padr(a_rabota[1],22)+" "+padc(alltrim(a_shifr[1]),11)+" "+;
               padc(srok_lech,11)+" "+padc(alltrim(human->uch_doc),9)+" "+;
               padc(alltrim(a_mesto_l[1]),22)+str(mcena_1,10,2))
    for k := 2 to max(k1,k2,k3,k4,k5,kp)
      add_string(space(5)+padr(a_fio[k],25)+;
                 padc(alltrim(a_polis[k]),13)+;
                 space(12)+;
                 padr(a_adres[k],25)+;
                 padr(a_rabota[k],23)+padc(alltrim(a_shifr[k]),11)+;
                 space(23)+padc(alltrim(a_mesto_l[k]),22))
    next
    ob_summa += mcena_1
    if is_usl == 1 .and. mcena_1 >= razmer_usl
      Select HU
      find (str(tmp->kod,7))
      do while hu->kod == tmp->kod .and. !eof()
        Select USL
        find (str(hu->u_kod,4))
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if f_paraklinika(usl->shifr,lshifr1,human->k_data) .and. hu->kol_1 > 0// .and. hu->u_cena > 0
          mdate := c4tod(hu->date_u)
          s := if(empty(lshifr1), usl->shifr, lshifr1)
          select TMP1
          find (s+dtos(mdate))
          if !found()
            append blank
            tmp1->shifr := s
            tmp1->data := mdate
          endif
          tmp1->kol += hu->kol_1
        endif
        select HU
        Skip
      enddo
      select TMP1
      set order TO 2
      go top
      tmp := "Медуслуги:"
      do while !eof()
        if !empty(tmp1->shifr)
          tmp += " "+alltrim(tmp1->shifr)+;
                 "("+lstr(tmp1->kol)+","+date_8(tmp1->data)+"),"
        endif
        skip
      enddo
      tmp := left(tmp,len(tmp)-1)
      frd->uslugi := substr(tmp,12)
      j1 := perenos(a_fio,tmp,sh-10," ")
      if verify_FF(HH-j1-1,.t.,sh)
        aeval(arr1title, {|x| add_string(x) })
      endif
      for k := 1 to j1
        add_string(space(10)+a_fio[k])
      next
      add_string("")
      select TMP1
      zap
      set order to 1
    endif
  endif
  select TMP
  skip
enddo
otd->(dbCloseArea())
usl->(dbCloseArea())
hu->(dbCloseArea())
kart_->(dbCloseArea())
kart->(dbCloseArea())
human_->(dbCloseArea())
human->(dbCloseArea())
tmp->(dbCloseArea())
if is_usl == 1
  tmp1->(dbCloseArea())
endif
if select("LUSL") > 0
  lusl->(dbCloseArea())
endif
CloseGauge(hGauge)
if verify_FF(HH-8,.t.,sh)
  aeval(arr1title, {|x| add_string(x) })
endif
if is_vyp == 1  // если счет выписан, взять сумму из БД счетов
  ob_summa := schet->summa
endif
frt->ssumma := srub_kop(ob_summa,.t.)
frt->summa := ob_summa
frt->kol := j
add_string(replicate("─",sh))
add_string(padr("Количество пролеченных больных в счете - "+lstr(j),sh-20)+;
           "Итого: "+str(ob_summa,13,2))
pj := j
add_string("")
for i := 1 to perenos(a_fio,"("+srub_kop(ob_summa,.t.)+")",sh)
  add_string(a_fio[i])
next
add_string("")
add_string(space(35)+"Руководитель      ________________________ / "+mruk+" /")
add_string("")
add_string(space(35)+"Главный бухгалтер ________________________ / "+mbux+" /")
fclose(fp)
frd->(dbCloseArea())
frt->(dbCloseArea())
rest_box(buf)
if is_view
  name_fr := "mo_schpr"+sfr3
  if _upr_epson() .or. !file(dir_exe+name_fr)
    Private yes_albom := .t.
    viewtext(n_file,,,,.t.,,,regim)
  else
    call_fr(name_fr)
  endif
endif
return NIL

*

***** Исключение из счета некоторых больных
Function f1vyp_schet()
Local i := 1, j, buf := save_box(T_ROW,0,24,79), fl, ;
      str_sem, old_cena, new_cena
Private old_summa := ob_summa, old_kol := ob_kol, regim_t := 1
Private p_blk := {|mkol,msum| DevPos( 2, 10 ) ,;
    DevOut( padr("Количество больных в счете: "+;
                    expand_value(mkol)+" чел.",50), color1 ),;
    DevPos( 3, 10 ) ,;
    DevOut( padr("Сумма счета: "+;
                    expand_value(msum,2)+" руб.",40), color1 ) }
use (cur_dir+"tmp") index (cur_dir+"tmp")
fl := .f.
if Alpha_Browse(T_ROW,0,20,79,"f1_tmp_sch",color1,;
          "Корректировка счета","G+/B",.t.,.t.,,,"f2_tmp_sch",,;
          {'═','░','═',"W+/B,W+/R,GR+/B,GR+/R",,300} )
  if ob_kol == 0
    func_error(4,"В счете никого не осталось! Операция запрещена.")
  elseif old_kol != ob_kol .and. f_Esc_Enter("корректировки счета")
    fl := .t.
    mywait()
    delete for !plus
    pack
    j := 0
    select TMP
    go top
    do while !eof()
      tmp->NOMER := ++j
      skip
    enddo
  endif
endif
if !fl
  ob_summa := old_summa ; ob_kol := old_kol
  tmp->(dbeval({|| tmp->plus := .t. } ))
endif
close databases
eval(p_blk,ob_kol,ob_summa)
rest_box(buf)
return NIL

*****
Function f2vyp_schet()
Local buf, tmp_color := setcolor(), buf24 := save_maxrow(), fl, mkod, i, hGauge
buf := box_shadow(15,20,20,59,color8)
setcolor(cDataCGet)
Private mnomer := space(10), mdate := sys_date
if type("p_0_schet") == "L"
  mnomer := padr(retNext0Schet(),10)
  keyboard chr(K_TAB)
endif
do while .t.
  status_key("^<Esc>^ - выход без записи счета;  ^<Enter>^ - подтверждение записи счета")
  @ 17,28 say "Номер счета " get mnomer picture "@!"
  @ 18,28 say "Дата счета  " get mdate
  myread({"confirm"})
  if lastkey() != K_ESC
    if empty(mnomer)
      func_error(4,"Вы не ввели номер счета!")
      loop
    endif
    mywait()
    fl := .f.
    R_Use(dir_server+"schet",dir_server+"schetn","SCHET")
    find (mnomer)
    do while schet->nomer_s == mnomer .and. !eof()
      if year(mdate) == year(c4tod(schet->pdate))
        fl := .t. ; exit
      endif
      skip
    enddo
    Use
    if fl
      func_error(4,"В этом году счет с таким номером уже был выписан! Исправьте номер счета.")
      loop
    elseif f_Esc_Enter("записи счета")
      Use (cur_dir+"tmp") new alias TMP
      index on upper(fio) to (cur_dir+"tmp")
      if Use_base("schet") .and. Use_base("human")
        hGauge := GaugeNew(,,{"GR+/RB","BG+/RB","G+/RB"},;
                           "Запись номера счета по всем больным",.t.)
        GaugeDisplay( hGauge )
        select SCHET
        AddRec(6)
        mkod := recno()
        replace kod with mkod, nomer_s with mnomer, pdate with dtoc4(mdate),;
                komu with glob_komu, str_crb with glob_all[1],;
                summa with ob_summa, kol with ob_kol,;
                summa_ost with ob_summa, kol_ost with ob_kol
        //
        select SCHET_
        do while schet_->(lastrec()) < mkod
          APPEND BLANK
        enddo
        goto (mkod)
        G_RLock(forever)
        schet_->NSCHET := mnomer
        schet_->DSCHET := mdate
        UnLock
        Commit
        // запись номера счета по больным
        i := 0
        select TMP
        go top
        do while !eof()
          GaugeUpdate( hGauge, recno()/lastrec() )
          select HUMAN
          find (str(tmp->kod,7))
          if found()  // на всякий случай
            G_RLock(forever)
            human->schet := mkod ; human->tip_h := B_SCHET
            human_->(G_RLock(forever))
            human_->schet_zap := ++i
            UnLock
          endif
          select TMP
          skip
        enddo
        close databases
        CloseGauge(hGauge)
        stat_msg("Запись счета завершена!") ; mybell(2,OK)
      endif
      close databases
      keyboard chr(K_ESC)
      exit
    endif
  else
    exit
  endif
enddo
setcolor(tmp_color)
rest_box(buf)
rest_box(buf24)
return NIL

*

*****
Function usl_vyp_schet(amp)
Local fl := .f., buf := savescreen(), buf1, r := 9, i := 3, k,;
      tmp_color := setcolor(), tmp_help := help_code
Private gl_area := {1,0,23,79,0}
setcolor(cDataCGet)
do while .t.
  if i == 3
    mmax_kol := 999
    mn1_data := mn2_data := mk1_data := mk2_data := ctod("")
  endif
  box_shadow(r,8,r+4,71,color1,"Редактирование условий отбора в счет",color8)
  @ r+1,10 say "Макс.кол-во больных в счете" get mmax_kol pict "999"
  @ r+2,10 say "Больные начали лечение с" get mn1_data
  @ row(),col()+1 say "по" get mn2_data
  @ r+3,10 say "Больные закончили лечение с" get mk1_data
  @ row(),col()+1 say "по" get mk2_data
  status_key("^<Esc>^ - отказ;  ^<PgDn>^ - подтверждение")
  myread()
  buf1 := box_shadow(19,2,23,77,color0)
  setmtcolor(col1menu)
  @ 21, 5 prompt " ~Отказ "
  @ 21,14 prompt " Составить ~счет "
  @ 21,32 prompt " ~Очистка полей "
  @ 21,49 prompt " Продолжить ~редактирование "
  i := iif(lastkey() == K_ESC, 1, 2)
  menu to i
  rest_box(buf1)
  if i < 2
    exit
  elseif i == 2
    buf1 := save_maxrow() ; k := 0 ; muslovie := "" ; str_kriterij := ""
    mywait()
    if !emptyall(mn1_data,mn2_data)
      str_kriterij += "Начало лечения:"
      if !empty(mn1_data)
        str_kriterij += " после "+dtoc(mn1_data)+"; "
        muslovie += "tmp->n_data >= mn1_data .and. "
      endif
      if !empty(mn2_data)
        str_kriterij += " до "+dtoc(mn2_data)+"; "
        muslovie += "tmp->n_data <= mn2_data .and. "
      endif
    endif
    if !emptyall(mk1_data,mk2_data)
      str_kriterij += "Оконч.лечения:"
      if !empty(mk1_data)
        str_kriterij += " после "+dtoc(mk1_data)+"; "
        muslovie += "tmp->k_data >= mk1_data .and. "
      endif
      if !empty(mk2_data)
        str_kriterij += " до "+dtoc(mk2_data)+"; "
        muslovie += "tmp->k_data <= mk2_data .and. "
      endif
    endif
    use (cur_dir+"tmp") index (cur_dir+"tmp")
    if empty(muslovie)
      muslovie := ".t."
      str_kriterij := "Все больные"
      k := min(tmp->(lastrec()),mmax_kol)
    else
      muslovie := left(muslovie,len(muslovie)-7)
      str_kriterij := left(str_kriterij,len(str_kriterij)-2)
      k := 0
      go top
      do while !eof()
        if &muslovie .and. k < mmax_kol
          ++k
        endif
        skip
      enddo
    endif
    Use
    rest_box(buf1)
    if k == 0
      func_error(4,"По данному условию некого включать в счет!")
    else
      fl := .t.
      exit
    endif
  endif
enddo
restscreen(buf)
setcolor(tmp_color)
return fl

*

*****
Function other_schet_edit()
ne_real()
return NIL

*

*****
Function other_schet_vozvrat()
Local buf := savescreen(), i, s, mkod_opl, mdoplata, msmo, mdate, as := {}
if input_schet(0)
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",dir_server+"schetk","SCHET")
  set relation to recno() into SCHET_
  find (str(glob_schet,6))
  mkod_opl := schet->flag_opl ; mdate := c4tod(schet->pdate)
  mdoplata := schet_->IS_DOPLATA
  msmo := val(schet_->smo)
  close databases
  if mdoplata == 1
    func_error(4,"Это счет на доплату! Возврат запрещен.")
  elseif !empty(msmo)
    func_error(4,"Это счет ОМС! Возврат запрещен.")
  elseif mkod_opl > 0
    func_error(4,"По данному счету уже произведена оплата! Возврат запрещен.")
  elseif ver_pub_date(mdate,.t.)
    i := 16
    box_shadow(i,10,22,69,color0)
    setcolor("R/BG")
    aadd(as,glob_schet)
    str_center(i+1,"Предупреждение!")
    str_center(i+2,"После подтверждения больные будут вычеркнуты")
    str_center(i+3,"из данного счета, а счет будет удален.")
    setcolor(color0)
    setmtcolor(col1menu)
    @ 21,24 prompt " ~Отказ "
    @ 21,33 prompt " Подтверждение ~возврата "
    menu to i
    if i == 2 .and. Use_base("schet") .and. Use_base("human")
      set order to 6
      mywait()
      for i := 1 to len(as)
        do while .t.
          find (str(as[i],6))
          if !found() ; exit ; endif
          G_RLock(forever)
          human->schet := 0
          human->tip_h := B_STANDART
          human_->(G_RLock(forever))
          human_->schet_zap := 0
          UnLock
        enddo
      next
      select SCHET
      find (str(glob_schet,6))
      select SCHET_
      DeleteRec(.t.,.f.) // очистить и не помечать на удаление
      select SCHET
      DeleteRec(.t.)
      close databases
      stat_msg("Возврат счета прошел успешно.") ; mybell(2,OK)
    endif
  endif
endif
restscreen(buf)
return NIL

*

*****
Function f1_tmp_sch(oBrow)
Local oColumn, tmp_color, blk_color := {|| if(tmp->plus, {3,4}, {1,2}) },;
      s1, s2, s3, n := 42
if regim_t == 3
  oColumn := TBColumnNew(center("Ф.И.О. больного",n+2), {|| padr(tmp->fio,n+2) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
else
  oColumn := TBColumnNew("   NN", {|| if(tmp->plus,""," ")+str(tmp->nomer,4) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(center("Ф.И.О. больного",n), {|| padr(tmp->fio,n) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew("На-;чало", {|| left(dtoc(tmp->n_data),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Окончан.;лечения", {|| date_8(tmp->k_data) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("   Сумма", {|| padl(expand_value(tmp->cena,2),13) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
tmp_color := setcolor("N/W")
do case
  case regim_t == 1
    s1 := "корректировки счета"
    s2 := "все включены в счет"
    s3 := "все исключены из счета"
  case regim_t == 2
    s1 := "частичной оплаты счета"
    s2 := "все включены в частично оплачиваемый счет"
    s3 := "все исключены из счета"
  case regim_t == 3
    s1 := "простановки стандарта"
    s2 := "всем проставлен стандарт"
    s3 := "никому не проставлен стандарт"
  case regim_t == 4
    s1 := "возврата больных"
    s2 := "все оплачены"
    s3 := "все становятся неоплаченными"
endcase
@ 21,0 say padr(" <Esc> - выход без изменений;    <Enter> - подтверждение "+s1,80)
@ 22,0 say padr(" <Ins> - отметить одного больного или снять отметку с одного больного",80)
@ 23,0 say padr(" <+> - отметить всех больных ("+s2+")",80)
@ 24,0 say padr(" <-> - снять отметку со всех больных ("+s3+")",80)
mark_keys({s1},"R/W")
mark_keys({"<Esc>","<Enter>","<Ins>","<+>","<->"},"B/W")
setcolor(tmp_color)
return NIL

*****
Function f2_tmp_sch(nKey,oBrow)
Local buf, rec, k := -1
do case
  case nkey == K_INS
    replace tmp->plus with !tmp->plus
    if tmp->plus
      ob_summa += tmp->cena ; ob_kol++
    else
      ob_summa -= tmp->cena ; ob_kol--
    endif
    eval(p_blk,ob_kol,ob_summa)
    k := 0
    keyboard chr(K_TAB)
  case nkey == 43 .or. nkey == 45  // + или -
    fl := (nkey == 43)
    rec := recno()
    buf := save_maxrow()
    mywait()
    tmp->(dbeval({|| tmp->plus := fl}))
    goto (rec)
    rest_box(buf)
    if fl
      ob_summa := old_summa ; ob_kol := tmp->(lastrec())
    else
      ob_summa := ob_kol := 0
    endif
    eval(p_blk,ob_kol,ob_summa)
    k := 0
endcase
return k

*

*****
Function retNext0Schet()
Local buf := save_maxrow(), n := 1, c2, c := "П"
mywait("Поиск следующего номера счета")
c2 := left(dtoc4(mdate),2)
G_Use(dir_server+"schet",,"SCHET")
index on f_nom0sch(nomer_s) to (cur_dir+"tmp_sch") ;
      for left(nomer_s,1)==c .and. left(pdate,2)==c2
go top
if !eof()
  go bottom
  n := f_nom0sch(schet->nomer_s)+1
endif
close databases
rest_box(buf)
return c+lstr(n)

***** определить целую величину номера счета
Function f_nom0sch(s)
Local c, i, n := 0
s := substr(alltrim(s),2)
for i := 1 to len(s)
  c := ASC(substr(s,i,1))
  if between(c,48,57)  // если цифра
    n := int(val(substr(s,i)))
    exit
  endif
next
return n

*

***** 17.09.13
Function akt_kontrol_2012()
Local buf, fl, ii := 0, fl_numeration := .f., str_sem := "Оплата счетов"
Local t_arr[BR_LEN], blk, s
if tip_polzovat != 0
  return func_error(4,err_admin)
endif
if G_SLock(str_sem)
  buf := savescreen()
  fl := input_schet(0)
  restscreen(buf)
  if fl
    R_Use(dir_server+"schet_",,"SCHET_")
    R_Use(dir_server+"schet",dir_server+"schetk","SCHET")
    set relation to recno() into SCHET_
    find (str(glob_schet,6))
    Private snyear := schet_->nyear
    if emptyany(schet_->nyear,schet_->nmonth)
      fl_numeration := .t.
    endif
    t_arr[BR_TITUL] := "Счёт № "+alltrim(schet_->nschet)+" от "+;
                       date_8(schet_->dschet)+" "+f4_view_list_schet()
    //
    Private mm_eksp := {{"МЭК ",1},;
                        {"МЭЭ ",2},;
                        {"ЭКМП",3}}
    adbf := {{"nomer","N",4,0},;
             {"kod","N",7,0},;
             {"fio","C",50,0},;
             {"date_r","D",8,0},;
             {"stoim","N",10,2},;
             {"sump","N",10,2},;
             {"oplata","N",1,0},;
             {"is_ekps","N",1,0},;
             {"IS_REPEAT","N",1,0},;
             {"prim","C",20,0}}
    dbcreate(cur_dir+"tmps",adbf)
    use (cur_dir+"tmps") new
    R_Use(dir_server+"mo_rak",,"RAK")
    R_Use(dir_server+"mo_raks",,"RAKS")
    set relation to akt into RAK
    R_Use(dir_server+"mo_raksh",,"RAKSH")
    set relation to kod_raks into RAKS
    index on str(kod_h,7) to (cur_dir+"tmp_raksh") for raks->SCHET == glob_schet
    R_Use(dir_server+"mo_os",,"MO_OS")
    index on str(kod,7) to (cur_dir+"tmp_moos")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humans","HUMAN")
    set relation to recno() into HUMAN_
    Select HUMAN
    find (str(glob_schet,6))
    do while human->schet == glob_schet .and. !eof()
      select TMPS
      append blank
      tmps->nomer  := iif(fl_numeration, ++ii, human_->SCHET_ZAP)
      tmps->kod    := human->kod
      tmps->fio    := human->fio
      tmps->date_r := human->date_r
      tmps->stoim  := human->cena_1
      tmps->oplata := human_->oplata
      if human_->oplata == 1
        tmps->sump := human->cena_1
      elseif eq_any(human_->oplata,2,9)
        tmps->sump := 0
        tmps->oplata := 2
      else
        tmps->sump := human_->sump
      endif
      select MO_OS
      find (str(human->kod,7))
      if found()
        tmps->is_ekps := 1
        tmps->IS_REPEAT := mo_os->IS_REPEAT
        tmps->prim := _prim_akt_kontrol_2012()
      elseif human_->oplata > 1
        s := ""
        if human_->oplata == 2
          s := "отказ"
        elseif human_->oplata == 3
          s := "част."
        elseif human_->oplata == 4
          s := "возврат"
        elseif human_->oplata == 9
          s := "повтор"
        endif
        select RAKSH
        find (str(human->kod,7))
        if found()
          s += " "+alltrim(rak->NAKT)+" от "+date_8(rak->DAKT)
        elseif !empty(s)
          s += "-акт не найден"
        endif
        tmps->prim := s
      endif
      Select HUMAN
      skip
    enddo
    close databases
    //
    t_arr[BR_TOP] := T_ROW
    t_arr[BR_BOTTOM] := maxrow()-1
    t_arr[BR_LEFT] := 0
    t_arr[BR_RIGHT] := 79
    t_arr[BR_COLOR] := color0
    t_arr[BR_TITUL_COLOR] := "BG+/GR"
    t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.t.}
    blk := {|| iif(tmps->is_ekps == 0, {1,2}, {3,4}) }
    t_arr[BR_COLUMN] := {{ "№/пп", {|| tmps->nomer }, blk },;
                         { " Ф.И.О.", {|| padr(tmps->fio,30) }, blk },;
                         { "Дата рожд", {|| full_date(tmps->date_r) }, blk },;
                         { "Стоимость", {|| put_kop(tmps->stoim,10) }, blk },;
                         { " Примечание", {|| padr(tmps->prim,20) }, blk } }
    t_arr[BR_EDIT] := {|nk,ob| f1akt_kontrol_2012(nk,ob,"edit") }
    t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход  ^<Del>^ отменить акт  ^<Enter>^ добавить акт  ^<F9>^ печать листа учёта") }
    use (cur_dir+"tmps") new
    index on nomer to (cur_dir+"tmps")
    edit_browse(t_arr)
    close databases
  endif
  G_SUnLock(str_sem)
else
  func_error(4,"В данный момент с оплатой счетов работает другой пользователь.")
endif
return NIL

***** 19.12.13
Static Function f1akt_kontrol_2012(nKey,oBrow,regim)
Static mm_oplata := {{"полная оплата",1},;
                     {"полный отказ",2},;
                     {"частичный отказ",3}}
Static mm_repeat := {{"нет (обычное снятие)",0},;
                     {"повторное выставление листа учёта",1}}
Local ret := -1, rec, buf, i, r, fl
if regim == "edit"
  rec := recno()
  glob_perso := tmps->kod
  do case
    case nKey == K_ENTER
      if snyear > 2012
        func_error(4,'С 2013 года снятие осуществляется в режиме "Реестр актов контроля"')
        return ret
      endif
      buf := savescreen()
      Private makt := space(15), mdate_opl := sys_date,;
              mtip_eksp, m1tip_eksp := 1, msump := tmps->stoim,;
              moplata, m1oplata := tmps->oplata,;
              mrepeat, m1repeat := tmps->IS_REPEAT,;
              merror := space(10), m1error := 0,;
              gl_area := {1,0,23,79,0}
      G_Use(dir_server+"mo_os",cur_dir+"tmp_moos","MO_OS")
      if tmps->is_ekps == 1
        find (str(glob_perso,7))
        if found()
          makt := mo_os->AKT
          mdate_opl := mo_os->DATE_OPL
          m1oplata := mo_os->oplata
          msump := mo_os->sump
          if !empty(mo_os->SANK_MEE)
            m1tip_eksp := 2
          elseif !empty(mo_os->SANK_EKMP)
            m1tip_eksp := 3
          endif
          if (m1error := mo_os->REFREASON) > 0
            merror := inieditspr(A__POPUPMENU, dir_exe+"_mo_t005", m1error)
          endif
        endif
      endif
      mtip_eksp := inieditspr(A__MENUVERT,mm_eksp,m1tip_eksp)
      moplata := inieditspr(A__MENUVERT,mm_oplata,m1oplata)
      mrepeat := inieditspr(A__MENUVERT,mm_repeat,m1repeat)
      //
      r := pr1+1
      setcolor(cDataCGet)
      ClrLines(r,23)
      @ r,0 say padc(iif(mo_os->(found()),"Просмотр","Ввод")+" акта снятия",80,"─") color "B+/B"
      @ r+2,1 say "Номер случая в счёте" get tmps->nomer when.f.
      @ r+3,1 say "Пациент" get tmps->fio when.f.
      @ r+4,1 say "Дата рождения" get tmps->date_r when.f.
      @ r+5,1 say "Сумма случая" get tmps->stoim when.f.
      @ r+6,1 say " Вид оплаты" get moplata ;
              reader {|x|menu_reader(x,mm_oplata,A__MENUVERT,,,.f.)} ;
              valid {|| iif(m1oplata==2, msump:=0, nil), update_get("msump") }
      @ r+7,1 say "Сумма, принятая к оплате" get msump pict "9999999.99" ;
              when m1oplata == 3
      @ r+8,1 say "Номер акта" get makt when m1oplata > 1
      @ row(),col()+3 say "Дата акта" get mdate_opl when m1oplata > 1
      @ r+9,1 say "Вид экспертизы" get mtip_eksp ;
              reader {|x|menu_reader(x,mm_eksp,A__MENUVERT,,,.f.)} ;
              when m1oplata > 1
      @ r+10,1 say "Код дефекта" get merror ;
             reader {|x|menu_reader(x,{dir_exe+"_mo_t005"},A__POPUPEDIT,,,.f.)} ;
             when m1oplata > 1
      @ r+11,1 say "Выставить случай повторно?" get mrepeat ;
              reader {|x|menu_reader(x,mm_repeat,A__MENUVERT,,,.f.)} ;
              when m1oplata == 2
      if mo_os->(found())
        clear_gets()
        stat_msg("Нажмите любую клавишу")
        inkey(0)
        setlastkey(K_ESC)
      else
        keyboard chr(K_ENTER)
        status_key("^<Esc>^ - отказ;  ^<PgDn>^ - подтверждение записи акта")
        myread()
      endif
      fl := (lastkey() != K_ESC)
      if fl .and. m1oplata == 1
        fl := func_error(4,"Не было ввода акта снятия")
      endif
      if fl .and. m1oplata == 3
        m1repeat := 0
        if round(tmps->stoim,2) <= round(msump,2)
          fl := func_error(4,"Сумма, принятая к оплате, должна быть меньше суммы случая")
        endif
        if empty(msump) .or. msump < 0
          fl := func_error(4,"Сумма, принятая к оплате, должна быть больше нуля")
        endif
      endif
      if fl .and. f_Esc_Enter("записи акта снятия",.t.)
        if m1repeat == 1
          // сначала запоминаем копию листа учёта в массивах
          use_base("human")
          set relation to // "отвязываем"
          goto (glob_perso)
          ahuman := get_field()
          select HUMAN_
          goto (glob_perso)
          ahuman_ := get_field()
          select HUMAN_2
          goto (glob_perso)
          ahuman_2 := get_field()
          if (fl_iname := (human_->smo == '34   '))
            G_Use(dir_server+"mo_hismo",,"SN")
            index on str(kod,7) to (cur_dir+"tmp_ismo")
            find (str(glob_perso,7))
            mnameismo := sn->smo_name
          endif
          arr_hu := {}
          use_base("human_u")
          set relation to // "отвязываем"
          find (str(glob_perso,7))
          do while hu->kod == glob_perso .and. !eof()
            ahu := get_field()
            select HU_
            goto (hu->(recno()))
            ahu_ := get_field()
            aadd(arr_hu,{ahu,ahu_})
            select HU
            skip
          enddo
        endif
        select MO_OS
        AddRec(7)
        mo_os->KOD := glob_perso
        mo_os->AKT := makt
        mo_os->DATE_OPL := mdate_opl
        mo_os->OPLATA := m1oplata
        mo_os->IS_REPEAT := m1repeat
        mo_os->SUMP := msump
        if m1tip_eksp == 1
          mo_os->SANK_MEK := tmps->stoim - msump
        elseif m1tip_eksp == 2
          mo_os->SANK_MEE := tmps->stoim - msump
        elseif m1tip_eksp == 3
          mo_os->SANK_EKMP := tmps->stoim - msump
        endif
        mo_os->REFREASON := m1error
        mo_os->NEXT_KOD  := 0
        //
        tmps->is_ekps := 1
        tmps->IS_REPEAT := m1repeat
        tmps->prim := _prim_akt_kontrol_2012()
        //
        if m1repeat == 1
          select HUMAN_
        else
          G_Use(dir_server+"human_",,"HUMAN_")
        endif
        goto (glob_perso)
        G_RLock(forever)
        human_->OPLATA := iif(m1repeat==0, mo_os->OPLATA, 9)
        human_->SUMP      := mo_os->SUMP
        human_->SANK_MEK  := mo_os->SANK_MEK
        human_->SANK_MEE  := mo_os->SANK_MEE
        human_->SANK_EKMP := mo_os->SANK_EKMP
        if m1repeat == 1
          // теперь записываем в БД копию листа учёта
          select HUMAN
          Add1Rec(7)
          mkod := recno()
          aeval(ahuman, {|x,i| fieldput(i,x) } )
          human->kod      := mkod
          human->TIP_H    := B_STANDART // лечение завершено
          human->DATE_OPL := ""
          human->schet    := 0
          //
          mo_os->NEXT_KOD := mkod // запомним, в какую запись попала копия л/у
          //
          select HUMAN_
          do while human_->(lastrec()) < mkod
            APPEND BLANK
          enddo
          goto (mkod)
          G_RLock(forever)
          aeval(ahuman_, {|x,i| fieldput(i,x) } )
          human_->KOD_UP    := glob_perso // код оригинального листа учёта
          human_->SUMP      := 0
          human_->OPLATA    := 0
          human_->SANK_MEK  := 0
          human_->SANK_MEE  := 0
          human_->SANK_EKMP := 0
          human_->REESTR    := 0
          human_->REES_ZAP  := 0
          human_->SCHET_ZAP := 0
          human_->ST_VERIFY := 0 // снова ещё не проверен
          //
          select HUMAN_2
          do while human_2->(lastrec()) < mkod
            APPEND BLANK
          enddo
          goto (mkod)
          G_RLock(forever)
          aeval(ahuman_2, {|x,i| fieldput(i,x) } )
          if fl_iname
            select SN
            find (str(mkod,7))
            if found()
              if !empty(mnameismo)
                G_RLock(forever)
                sn->smo_name := mnameismo
              else
                DeleteRec(.t.)
              endif
            else
              if !empty(mnameismo)
                AddRec(7)
                sn->kod := mkod
                sn->smo_name := mnameismo
              endif
            endif
          endif
          for i := 1 to len(arr_hu)
            select HU
            Add1Rec(7)
            aeval(arr_hu[i,1], {|x,i| fieldput(i,x) } )
            hu->kod := mkod
            select HU_
            do while hu_->(lastrec()) < hu->(recno())
              APPEND BLANK
            enddo
            goto (hu->(recno()))
            G_RLock(forever)
            aeval(arr_hu[i,2], {|x,i| fieldput(i,x) } )
            hu_->OPLATA    := 0
            hu_->REES_ZAP  := 0
            hu_->SCHET_ZAP := 0
          next
        endif
      endif
      close databases
      restscreen(buf)
      use (cur_dir+"tmps") index (cur_dir+"tmps") new
      goto (rec)
      ret := 0
    case nKey == K_DEL
      if tmps->is_ekps == 1 .and. f_Esc_Enter("удаления акта снятия",.t.)
        buf := savescreen()
        fl := .t.
        if tmps->IS_REPEAT == 1
          f_message({"","При удалении данного акта снятия",;
                     "также будет удалён повторно выставленный",;
                     "лист учёта",""},,"GR+/R","W+/R")
          fl := f_Esc_Enter("удаления акта снятия",.t.)
        endif
        if fl
          G_Use(dir_server+"mo_os",cur_dir+"tmp_moos","MO_OS")
          find (str(glob_perso,7))
          mkod := mo_os->NEXT_KOD
          if tmps->IS_REPEAT == 1 .and. mkod > 0
            // удаляем повторно выставленный лист учёта
            Use_base("human")
            find (str(mkod,7))
            if human->schet > 0 .or. human_->REESTR > 0
              fl := func_error(10,"Повторно выставленный лист учёта уже попал в реестр (счёт). Удаление запрещено!")
            endif
            if fl
              Use_base("mo_hu")
              do while .t.
                select MOHU
                find (str(mkod,7))
                if !found() ; exit ; endif
                DeleteRec(.t.,.f.)  // без пометки на удаление
              enddo
              Use_base("human_u")
              do while .t.
                select HU
                find (str(mkod,7))
                if !found() ; exit ; endif
                //
                select HU_
                DeleteRec(.t.,.f.)
                select HU
                DeleteRec(.t.,.f.)  // без пометки на удаление
              enddo
              select HUMAN_
              DeleteRec(.t.,.f.)
              select HUMAN
              DeleteRec(.t.,.f.)  // без пометки на удаление
              G_RLock(forever)
              replace human->schet with -1  // (вместо нуля)
            endif
          else
            G_Use(dir_server+"human_",,"HUMAN_")
          endif
          if fl
            select HUMAN_
            goto (glob_perso)
            G_RLock(forever)
            human_->OPLATA    := 1
            human_->SANK_MEK  := 0
            human_->SANK_MEE  := 0
            human_->SANK_EKMP := 0
            UnLock
            //
            select MO_OS
            find (str(glob_perso,7))
            if found()
              DeleteRec(.t.)
            endif
            //
            tmps->is_ekps := 0
            tmps->IS_REPEAT := 0
            tmps->prim := ""
          endif
        endif
        restscreen(buf)
        close databases
        use (cur_dir+"tmps") index (cur_dir+"tmps") new
        goto (rec)
      endif
      ret := 0
    case nKey == K_F9
      print_l_uch(glob_perso)
      use (cur_dir+"tmps") index (cur_dir+"tmps") new
      goto (rec)
  endcase
endif
return ret

***** 19.12.13
Static Function _prim_akt_kontrol_2012()
Local i := 0, s := ""
if !empty(mo_os->SANK_MEK)
  i := 1
elseif !empty(mo_os->SANK_MEE)
  i := 2
elseif !empty(mo_os->SANK_EKMP)
  i := 3
endif
if i > 0
  s := alltrim(mm_eksp[i,1])+" "
endif
s += left(date_8(mo_os->DATE_OPL),5)+" "
if mo_os->IS_REPEAT == 1
  s += "повторно выставлен"
elseif mo_os->oplata == 2
  s += "полный отказ"
elseif mo_os->oplata > 2
  s += "("+lstr(mo_os->sump,10,2)+")"
endif
return s

*

***** отметка о регистрации счетов в ТФОМС
Function registr_schet()
Local i, k, buf := savescreen(), tmp_help := chm_help_code,;
      mdate := stod("20110101")
mywait()
G_Use(dir_server+"schet_",,"SCHET_")
G_Use(dir_server+"schet",dir_server+"schetd","SCHET")
set relation to recno() into SCHET_
dbseek(dtoc4(mdate),.t.)
index on dtos(schet_->dschet)+schet_->nschet to (cur_dir+"tmp_sch") ;
      for schet_->dschet >= mdate .and. !empty(pdate) .and.;
          (schet_->IS_DOPLATA==1 .or. !empty(val(schet_->smo))) ;
      DESCENDING
go top
if eof()
  restscreen(buf)
  close databases
  return func_error(4,"Нет выписанных счетов c "+date_month(mdate))
endif
chm_help_code := 1//H_opl_schet
Alpha_Browse(T_ROW,0,23,79,"f1_view_registr_schet",color0,,,,,,,;
             "f2_view_registr_schet",,{'═','░','═',"N/BG,W+/N,R/BG,W+/R,RB/BG,W+/RB,GR/BG,W+/GR",.t.,60} )
close databases
chm_help_code := tmp_help
restscreen(buf)
return NIL

*****
Function f1_view_registr_schet(oBrow)
Local s, oColumn, ;
   blk := {|| iif(schet_->NREGISTR==3, {7,8},;
                  iif(schet_->NREGISTR==2, {5,6},;
                      iif(schet_->NREGISTR==1, {3,4}, {1,2} ))) }
oColumn := TBColumnNew("Номер счета",{|| schet_->nschet })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Дата",{|| date_8(schet_->dschet) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Пе-;риод",;
          {|| iif(emptyany(schet_->nyear,schet_->nmonth), ;
                  space(5), ;
                  right(str(schet_->nyear,4),2)+"/"+strzero(schet_->nmonth,2)) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Сумма счета",{|| put_kop(schet->summa,13) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол.;бол.", {|| str(schet->kol,4) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Дата ре-;гистрац.",{|| f11_view_registr_schet() })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Примечание",{|| padr(f12_view_registr_schet(),19) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
status_key("^<Esc>^ выход  ^<Enter>^ регистрация  ^<F2>^ поиск  ^<F9>^ печать незарег.счетов")
return NIL

*****
Function f11_view_registr_schet()
Local mdate := schet_->dregistr
if eq_any(schet_->NREGISTR,0,2) .and. empty(mdate)
  mdate := schet_->dschet
endif
return date_8(mdate)

*****
Function f12_view_registr_schet()
Local s := ""
if schet_->NREGISTR == 3
  s := "удалён/перевыставлен"
elseif schet_->NREGISTR == 2
  s := iif(empty(schet_->SREGISTR), "отказ в регистрации", schet_->SREGISTR)
elseif schet_->NREGISTR == 1
  s := "ещё не зарегистрирован"
endif
return s

*****
Function f2_view_registr_schet(nKey,oBrow)
Static mm_tip := {{"не зарегистрирован ",1},;
                  {"зарегистрирован    ",0},;
                  {"отказ в регистрации",2}}
Local ret := -1, rec := schet->(recno()), tmp_color := setcolor(),;
      r1, buf := savescreen(), rec1, fl
do case
  case nKey == K_ENTER
    if schet_->NREGISTR == 3
      func_error(4,"Счёт удалён. Случаи перевыставлены. Редактирование запрещено!")
      return ret
    endif
    Private mdate, mtitle, mtip, m1tip, mprim, gl_area := {r1,2,22,77,0}
    mdate := schet_->dschet
    mtitle := " №"+alltrim(schet_->nschet)+" от "+date_8(schet_->dschet)+"г."
    mprim := space(20)
    if schet_->NREGISTR == 1
      m1tip := 1
    elseif schet_->NREGISTR == 2
      m1tip := 2
      if !empty(schet_->dregistr)
        mdate := schet_->dregistr
      endif
      mprim := schet_->sregistr
    else
      m1tip := 0
      if !empty(schet_->dregistr)
        mdate := schet_->dregistr
      endif
    endif
    mtip := inieditspr(A__MENUVERT,mm_tip,m1tip)
    r1 := 15
    setcolor(cDataCGet)
    box_shadow(r1,2,22,77,,"Регистрация счёта"+mtitle,color8)
    @ r1+2,4 say "Отметка о регистрации" get mtip ;
             reader {|x|menu_reader(x,mm_tip,A__MENUVERT,,,.f.)}
    @ r1+3,4 say "Дата регистрации (отказа)" get mdate when m1tip != 1
    @ r1+4,4 say "Причина отказа" get mprim when m1tip == 2
    status_key("^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода")
    myread()
    if lastkey() != K_ESC .and. f_Esc_Enter(1)
      select SCHET_
      G_RLock(forever)
      schet_->nregistr := m1tip
      if m1tip != 1
        schet_->dregistr := mdate
      endif
      schet_->sregistr := iif(m1tip == 2, mprim, "")
      UnLock
      Commit
      select SCHET
      ret := 0
    endif
  case nKey == K_F2
    Private ar := GetIniSect(tmp_ini,"schet")
    Private mnomer := padr(a2default(ar,"number"),15)
    box_shadow(16,20,20,59,color8)
    setcolor(cDataCGet)
    status_key("^<Esc>^ - отказ;  ^<Enter>^ - подтверждение выбора счета")
    @ 18,22 say "Введите номер счета" get mnomer picture "@!@K"
    myread({"confirm"})
    rec1 := 0
    if lastkey() != K_ESC .and. !empty(mnomer)
      mywait()
      go top
      Locate for schet_->NSCHET == mnomer
      if found()
        rec1 := schet->(recno())
      else
        func_error(4,"Не найден счёт с номером "+alltrim(mnomer))
      endif
    endif
    if rec1 == 0
      goto (rec)
    else
      oBrow:goTop()
      goto (rec1)
      SetIniVar(tmp_ini,{{"schet","number",mnomer}})
      ret := 0
    endif
  case nKey == K_F9
    ne_real()
  case nKey == K_CTRL_F12 .and. schet_->NREGISTR == 1
    fl := .f.
    Private mkod_schet := schet->kod
    Private name_schet := alltrim(schet_->nschet)
    Private _date_schet := schet_->dschet
    close databases
    if G_SLock1Task(sem_task,sem_vagno) // запрет доступа всем
      if involved_password(4,name_schet,"удаления/перевыставления счёта "+name_schet) ;
          .and. f_Esc_Enter("удаления счёта") ;
          .and. m_copy_DB_from_end(.t.) // резервное копирование
        WaitStatus("Перевыставление случаев из удаляемого счёта")
        arr_human := {}
        fl_iname := .f.
        use_base("human_u")
        set relation to // "отвязываем"
        use_base("mo_hu")
        set relation to // "отвязываем"
        use_base("human")
        set order to 6
        find (str(mkod_schet,6))
        do while human->schet == mkod_schet .and. !eof()
          if human_->smo == '34   '
            fl_iname := .t.
          endif
          aadd(arr_human, human->(recno()) )
          skip
        enddo
        select HUMAN
        set order to 1
        set relation to // "отвязываем"
        if fl_iname
          G_Use(dir_server+"mo_hismo",,"SN")
          index on str(kod,7) to (cur_dir+"tmp_ismo")
        endif
        for ii := 1 to len(arr_human)
          UpdateStatus()
          glob_perso := arr_human[ii]
          select HUMAN
          goto (glob_perso)
          ahuman := get_field()
          select HUMAN_
          goto (glob_perso)
          ahuman_ := get_field()
          select HUMAN_2
          goto (glob_perso)
          ahuman_2 := get_field()
          mnameismo := ""
          if fl_iname .and. human_->smo == '34   '
            select SN
            find (str(glob_perso,7))
            mnameismo := sn->smo_name
          endif
          arr_hu := {}
          select HU
          find (str(glob_perso,7))
          do while hu->kod == glob_perso .and. !eof()
            ahu := get_field()
            select HU_
            goto (hu->(recno()))
            ahu_ := get_field()
            aadd(arr_hu,{ahu,ahu_})
            select HU
            skip
          enddo
          arr_mohu := {}
          select MOHU
          find (str(glob_perso,7))
          do while mohu->kod == glob_perso .and. !eof()
            aadd(arr_mohu,get_field())
            skip
          enddo
          arr_disp := read_arr_DISPANS(glob_perso)
          //
          select HUMAN_
          goto (glob_perso)
          G_RLock(forever)
          human_->OPLATA := 9
          // теперь записываем в БД копию листа учёта
          select HUMAN
          Add1Rec(7)
          mkod := recno()
          aeval(ahuman, {|x,i| fieldput(i,x) } )
          human->kod      := mkod
          human->TIP_H    := B_STANDART // лечение завершено
          human->DATE_OPL := ""
          human->schet    := 0
          //
          select HUMAN_
          do while human_->(lastrec()) < mkod
            APPEND BLANK
          enddo
          goto (mkod)
          G_RLock(forever)
          aeval(ahuman_, {|x,i| fieldput(i,x) } )
          human_->KOD_UP    := glob_perso // код оригинального листа учёта
          human_->SUMP      := 0
          human_->OPLATA    := 0
          human_->SANK_MEK  := 0
          human_->SANK_MEE  := 0
          human_->SANK_EKMP := 0
          human_->REESTR    := 0
          human_->REES_ZAP  := 0
          human_->SCHET_ZAP := 0
          human_->ST_VERIFY := 0 // снова ещё не проверен
          if human_->SCHET_NUM > 0
            human_->SCHET_NUM := human_->SCHET_NUM - 1
          endif
          //
          select HUMAN_2
          do while human_2->(lastrec()) < mkod
            APPEND BLANK
          enddo
          goto (mkod)
          G_RLock(forever)
          aeval(ahuman_2, {|x,i| fieldput(i,x) } )
          if fl_iname .and. human_->smo == '34   '
            select SN
            find (str(mkod,7))
            if found()
              if !empty(mnameismo)
                G_RLock(forever)
                sn->smo_name := mnameismo
              else
                DeleteRec(.t.)
              endif
            else
              if !empty(mnameismo)
                AddRec(7)
                sn->kod := mkod
                sn->smo_name := mnameismo
              endif
            endif
          endif
          for i := 1 to len(arr_hu)
            select HU
            Add1Rec(7)
            aeval(arr_hu[i,1], {|x,i| fieldput(i,x) } )
            hu->kod := mkod
            select HU_
            do while hu_->(lastrec()) < hu->(recno())
              APPEND BLANK
            enddo
            goto (hu->(recno()))
            G_RLock(forever)
            aeval(arr_hu[i,2], {|x,i| fieldput(i,x) } )
            hu_->OPLATA    := 0
            hu_->REES_ZAP  := 0
            hu_->SCHET_ZAP := 0
          next
          //
          for i := 1 to len(arr_mohu)
            select MOHU
            Add1Rec(7)
            aeval(arr_mohu[i], {|x,i| fieldput(i,x) } )
            mohu->kod       := mkod
            mohu->OPLATA    := 0
            mohu->REES_ZAP  := 0
            mohu->SCHET_ZAP := 0
          next
          save_arr_DISPANS(mkod,arr_disp)
        next
        fl := .t.
      endif
      close databases
      // разрешение доступа всем
      G_SUnLock(sem_vagno)
      keyboard ""
    else
      func_error(4,"В данный момент работают другие задачи. Операция запрещена!")
    endif
    G_Use(dir_server+"schet_",,"SCHET_")
    G_Use(dir_server+"schet",cur_dir+"tmp_sch","SCHET")
    set relation to recno() into SCHET_
    goto (rec)
    if fl
      select SCHET_
      G_RLock(forever)
      schet_->nregistr := 3
      schet_->dregistr := sys_date
      schet_->sregistr := "удалён и перевыставлен"
      UnLock
      Commit
      select SCHET
      stat_msg("Счёт удалён. Все случаи перевыставлены. Отредактируйте их!")
      mybell(2,OK)
    endif
    rec := 0
endcase
setcolor(tmp_color)
restscreen(buf)
return ret

*

***** 05.10.17 печать счёта-фактуры
Function print_faktura(regim)
Local adbf := {}, ip := 0, s, ret
//
if (ret := input_diapazon(maxrow()-4,9,maxrow()-2,68,color8,;
                          {"Введите номер","и дату","счёта-фактуры"},;
                          {schet->nomer_s,c4tod(schet->pdate)})) == NIL
  return NIL
endif
//
Private pole := "_t->name"
delFRfiles()
dbcreate(fr_titl,{{"title1","C",100,0},;
                  {"title2","C",100,0},;
                  {"name01","C",200,0},;
                  {"name02","C",200,0},;
                  {"name03","C",200,0},;
                  {"name04","C",200,0},;
                  {"name05","C",200,0},;
                  {"name06","C",200,0},;
                  {"name07","C",200,0},;
                  {"name08","C",200,0},;
                  {"name09","C",200,0},;
                  {"name10","C",200,0},;
                  {"name11","C",200,0},;
                  {"name12","C",200,0},;
                  {"name13","C",200,0},;
                  {"name14","C",200,0},;
                  {"name15","C",200,0},;
                  {"pril","C",200,0},;
                  {"pril2","C",100,0},;
                  {"bottom","C",2000,0},;
                  {"stoim","C",15,0},;
                  {"nds","C",15,0},;
                  {"itogo","C",15,0},;
                  {"ind_pred","C",80,0},;
                  {"svid_vo","C",80,0},;
                  {"fio_ruk","C",50,0},;
                  {"fio_bux","C",50,0}})
for j := 1 to 13
  aadd(adbf, {"p_"+lstr(j),"C",60,0})
next
dbcreate(fr_data,adbf)
use (fr_titl) new alias _t
append blank
use (fr_data) new alias _d
R_Use(dir_server+"organiz",,"ORG")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
set relation to kod_k into KART
find (str(schet->kod,6))
pok_name := pok_adres := pok_inn := ""
s := "Оказание медицинских услуг - "
if schet->komu == 5
  pok_name := alltrim(human->fio)
  pok_adres := ret_okato_ulica(kart->adres,kart_->okatog)
  s += fam_i_o(pok_name)
else
  if schet->kol == 1
    s += fam_i_o(human->fio)
  else
    s += lstr(schet->kol)+" чел."
  endif
  if schet->komu == 1
    R_Use(dir_server+"str_komp",,"PK")
    goto (schet->str_crb)
  else
    R_Use(dir_server+"komitet",,"PK")
    goto (schet->str_crb)
  endif
  pok_name := alltrim(iif(empty(pk->fname), pk->name, pk->fname))
  pok_adres := alltrim(pk->adres)
  pok_inn := alltrim(pk->inn)
  pk->(dbCloseArea())
endif
kart_->(dbCloseArea())
kart->(dbCloseArea())
human->(dbCloseArea())
//
_t->pril := "Приложение № 1"+eos+;
            "к постановлению Правительства"+eos+;
            "Российской Федерации"+eos+;
            "от 26 декабря 2011 г. № 1137"
_t->pril2 := "(в ред.Постановления Правительства РФ от 19.08.2017 №981)"
_t->title1 := "СЧЕТ-ФАКТУРА  № "+alltrim(ret[1])+" от "+date_month(ret[2],.t.)
_t->title2 := "ИСПРАВЛЕНИЕ   № -          от -"
ip := 1
&(pole+strzero(++ip,2)) := "Продавец :  "+org->name
&(pole+strzero(++ip,2)) := "Адрес :  "+org->adres
&(pole+strzero(++ip,2)) := "ИНН/КПП продавца :  "+org->inn
&(pole+strzero(++ip,2)) := "Грузоотправитель и его адрес :  "+alltrim(org->name)+", "+org->adres
&(pole+strzero(++ip,2)) := "Грузополучатель и его адрес :  "+pok_name+", "+pok_adres
&(pole+strzero(++ip,2)) := "К платежно-расчетному документу № _________ от ____________________"
&(pole+strzero(++ip,2)) := "Покупатель :  "+pok_name
&(pole+strzero(++ip,2)) := "Адрес :  "+pok_adres
&(pole+strzero(++ip,2)) := "ИНН/КПП покупателя :  "+pok_inn
&(pole+strzero(++ip,2)) := "Валюта: наименование, код :  Российский рубль, 643"
&(pole+strzero(++ip,2)) := "Идентификатор государственного контракта, договора (соглашения) (при наличии):"
select _d
append blank
_d->p_1 := s
_d->p_2 := "-"
_d->p_3 := "-"
_d->p_4 := "1"
_d->p_5 := lstr(schet->summa,11,2)
_d->p_6 := lstr(schet->summa,13,2)
_d->p_7 := "без акциза"
_d->p_8 := _d->p_9 := "без НДС"
_d->p_10 := lstr(schet->summa,13,2)
_d->p_11 := "643"
_d->p_12 := "Россия"
//_d->p_13 := mtamog
_t->stoim := lstr(schet->summa,15,2)
_t->nds := ""
_t->itogo := lstr(schet->summa,15,2)
_t->fio_ruk := alltrim(org->ruk)
_t->fio_bux := alltrim(org->bux)
org->(dbCloseArea())
_d->(dbCloseArea())
_t->(dbCloseArea())
call_fr("mo_faktu"+sfr3)
return NIL

*

***** 07.12.12 печать акта выполненных работ
Function print_akt(regim)
Local adbf := {}, s, ret
//
if (ret := input_diapazon(maxrow()-4,14,maxrow()-2,64,color8,;
                          {"Введите номер","и дату","акта"},;
                          {schet->nomer_s,c4tod(schet->pdate)})) == NIL
  return NIL
endif
//
delFRfiles()
dbcreate(fr_titl,{{"nomer","C",10,0},;
                  {"data","C",30,0},;
                  {"prod_name","C",150,0},;
                  {"prod_adres","C",100,0},;
                  {"prod_inn","C",20,0},;
                  {"pok_name","C",150,0},;
                  {"pok_adres","C",100,0},;
                  {"pok_inn","C",20,0},;
                  {"stoim","C",15,0},;
                  {"sstoim","C",200,0}})
for j := 1 to 7
  aadd(adbf, {"p_"+lstr(j),"C",60,0})
next
dbcreate(fr_data,adbf)
use (fr_titl) new alias _t
append blank
use (fr_data) new alias _d
R_Use(dir_server+"organiz",,"ORG")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
set relation to kod_k into KART
find (str(schet->kod,6))
p_name := p_adres := p_inn := ""
s := "Оказание медицинских услуг - "
if schet->komu == 5
  p_name := alltrim(human->fio)
  p_adres := ret_okato_ulica(kart->adres,kart_->okatog)
  s += fam_i_o(human->fio)
else
  if schet->kol == 1
    s += fam_i_o(human->fio)
  else
    s += lstr(schet->kol)+" чел."
  endif
  if schet->komu == 1
    R_Use(dir_server+"str_komp",,"PK")
    goto (schet->str_crb)
  else
    R_Use(dir_server+"komitet",,"PK")
    goto (schet->str_crb)
  endif
  p_name := alltrim(iif(empty(pk->fname), pk->name, pk->fname))
  p_adres := alltrim(pk->adres)
  p_inn := alltrim(pk->inn)
  pk->(dbCloseArea())
endif
kart_->(dbCloseArea())
kart->(dbCloseArea())
human->(dbCloseArea())
//
_t->nomer := alltrim(ret[1])
_t->data := date_month(ret[2],.t.)
_t->prod_name := org->name
_t->prod_adres := org->adres
_t->prod_inn := org->inn
_t->pok_name := p_name
_t->pok_adres := p_adres
_t->pok_inn := p_inn
select _d
append blank
_d->p_1 := s
_d->p_2 := "1"
_d->p_3 := _d->p_4 := lstr(schet->summa,11,2)
_d->p_5 := _d->p_6 := "-"
_d->p_7 := lstr(schet->summa,13,2)
_t->stoim := lstr(schet->summa,15,2)
_t->sstoim := srub_kop(schet->summa,.t.)
org->(dbCloseArea())
_d->(dbCloseArea())
_t->(dbCloseArea())
call_fr("mo_akt"+sfr3)
return NIL

*

***** 17.03.13 список незарегистрированных счетов
Function spisok_s_not_registred()
Local i, k, mdate := stod("20110101"),;
      sh, HH := 60, reg_print, n_file := "ne_zag_s"+stxt
mywait()
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
set relation to recno() into SCHET_
dbseek(dtoc4(mdate),.t.)
index on dtos(schet_->dschet)+schet_->nschet to (cur_dir+"tmp_sch") ;
      for schet_->NREGISTR > 0 .and. schet_->dschet >= mdate .and. !empty(pdate) .and.;
          (schet_->IS_DOPLATA==1 .or. !empty(val(schet_->smo))) ;
      DESCENDING
go top
arr_title := {;
"───────────────┬──────────┬───────┬─────────────┬────┬──────────────────────────",;
"  Номер счета  │   Дата   │Период │ Сумма счета │Кол.│ Примечание               ",;
"               │   счёта  │       │             │бол.│                          ",;
"───────────────┴──────────┴───────┴─────────────┴────┴──────────────────────────"}
reg_print := 2
f_reg_print(arr_title,@sh)
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center('Список незарегистрированных счетов',sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
do while !eof()
  s := schet_->nschet+" "+full_date(schet_->dschet)+" "+;
       iif(emptyany(schet_->nyear,schet_->nmonth), space(7), ;
                    str(schet_->nyear,4)+"/"+strzero(schet_->nmonth,2))+;
       put_kop(schet->summa,14)+str(schet->kol,5)+" "+;
       f12_view_registr_schet()
  add_string(s)
  skip
enddo
add_string(replicate("─",sh))
fclose(fp)
close databases
viewtext(n_file,,,,(sh>80),,,reg_print)
return NIL
