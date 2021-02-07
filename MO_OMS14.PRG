***** mo_oms14.prg - режимы для 2014 года (и ранее)
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 07.02.21
Function verify_1_sluch_18(fl_view)
Local _ocenka := 5, ta := {}, u_other := {}, ssumma := 0, auet, fl, lshifr1,;
      i, j, k, c, s := " ", a_srok_lech := {}, a_period_stac := {}, a_disp := {},;
      d1, d2, cd1, cd2, ym2, a_period_amb := {}, a_1_11, u_1_stom := "", lprofil, ;
      lbukva, lst, lidsp, a_idsp := {}, a_bukva := {}, t_arr[2], ltip, lkol, ;
      a_dializ := {}, is_2_88 := .f., a_rec_ffoms := {}, mpovod := 1 // 1.0
if empty(human->k_data)
  return .t.  // не проверять
endif
DEFAULT fl_view TO .t.
rec_human := human->(recno())
Private mdate_r := human->date_r, mvozrast, mdvozrast, M1VZROS_REB := human->VZROS_REB,;
        arr_usl_otkaz := {}, m1novor := 0, mpol := human->pol, mDATE_R2 := ctod(""),;
        is_oncology := 0, version_3_1 := left(dtos(human->k_data),6) > "201808" // с сентября 2018 года
if human_->NOVOR > 0
  m1novor := 1 // для переопределения M1VZROS_REB
  mDATE_R2 := human_->DATE_R2
  mpol := human_->POL2
endif
fv_date_r(human->n_data) // переопределение M1VZROS_REB
m1novor := human_->NOVOR // для запрета пересечения детей по номеру
if M1VZROS_REB != human->VZROS_REB  // если неверно,
  human->(G_RLock(forever))
  human->VZROS_REB := M1VZROS_REB   // то перезаписываем
  UnLock
endif
if version_3_1 //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  is_oncology := f_is_oncology(1)
endif
//
glob_kartotek := human->kod_k
d1 := human->n_data ; d2 := human->k_data ; cuch_doc := human->uch_doc
ym2 := left(dtos(d2),6)
d1_year := year(d1) ; d2_year := year(d2)
cd1 := dtoc4(d1) ; cd2 := dtoc4(d2)
gnot_disp := (human->ishod < 100)
gkod_diag := human->kod_diag
gusl_ok := human_->usl_ok
//
if gusl_ok == 4 // если "скорая помощь"
  select HUMAN
  set order to 3
  find (dtos(d2)+cuch_doc)
  do while human->k_data == d2 .and. cuch_doc == human->uch_doc .and. !eof()
    fl := human_->usl_ok == 4 .and. glob_kartotek == human->kod_k .and. rec_human != human->(recno())
    if fl .and. human->schet > 0 .and. eq_any(human_->oplata,2,9)
      fl := .f. // лист учёта снят по акту или выставлен повторно
    endif
    if fl
      aadd(ta, '"'+alltrim(cuch_doc)+'" повтор № карты вызова от '+;
               date_8(human->k_data)+" "+alltrim(human->fio))
    endif
    skip
  enddo
endif
// просмотр других случаев данного больного
select HUMAN
set order to 2
find (str(glob_kartotek,7))
do while human->kod_k == glob_kartotek .and. !eof()
  fl := (rec_human != human->(recno()) .and. year(human->k_data) > 2016) // прошлый год не смотрим вообще
  if fl .and. human->schet > 0 .and. eq_any(human_->oplata,2,9)
    fl := .f. // лист учёта снят по акту (и выставлен повторно)
  endif
  if fl .and. m1novor != human_->NOVOR
    fl := .f. // лист учёта на новорожденного (или наоборот)
  endif
  if fl .and. gnot_disp .and. human->ishod < 100 ; // если не диспансеризация
        .and. gusl_ok == human_->usl_ok ; // если те же условия оказания помощи
        .and. !empty(gkod_diag) .and. left(gkod_diag,3) == left(human->kod_diag,3) ; // тот же основной диагноз
        .and. (k := d1 - human->k_data) >= 0  // и случай оказан раньше проверяемого
    if gusl_ok == 3     // поликлиника
      if k < 16
        aadd(a_rec_ffoms,{human->(recno()),0,k})
      endif
    elseif gusl_ok == 4 // скорая помощь
      if k < 2
        aadd(a_rec_ffoms,{human->(recno()),0,k})
      endif
    else                // круглосуточный и дневной стационар
      if k < 31
        aadd(a_rec_ffoms,{human->(recno()),0,k})
      endif
    endif
  endif
  // если диапазон лечения перекрывается в стационаре и дневном стационаре
  if fl .and. eq_any(human_->USL_OK,1,2)
    fl1 := (left(dtos(human->k_data),6) == ym2)   // один и тот же месяц окончания лечения
    fl2 := overlap_diapazon(human->n_data,human->k_data,d1,d2) // перекрывается диапазон лечения
    fl3 := .t.
    k := 0
    if is_alldializ .and. (fl1 .or. fl2) .and. year(human->k_data) > 2017 // прошлый год не смотрим вообще
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          if left(lshifr,5) == "60.3." // диализ
            if human_->USL_OK == 2 // диализ в дневном стационаре
              fl3 := .f.
              if fl1
                k := 2
              endif
            elseif fl2 // диализ в стационаре
              k := 1
            endif
            exit
          endif
        endif
        select HU
        skip
      enddo
      if k > 1
        aadd(a_dializ,{human->n_data,human->k_data,human_->USL_OK,human->OTD,k}) // диализы не в кругл.стационаре
      endif
    endif
    if k < 2 .and. fl2 .and. fl3 .and. iif(is_alldializ, year(human->k_data) > 2017, .t.)
      aadd(a_srok_lech,{human->n_data,human->k_data,human_->USL_OK,human->OTD,k})
    endif
  endif
  // если диапазон лечения частично перекрывается
  if fl .and. human->n_data <= d2 .and. d1 <= human->k_data
    is_period_amb := .f.
    // стационар
    if human_->USL_OK == 1
      aadd(a_period_stac,{human->n_data,;
                          human->k_data,;
                          human_->USL_OK,;
                          human->OTD,;
                          human->kod_diag,;
                          human_->profil,;
                          human_->RSLT_NEW,;
                          human_->ISHOD_NEW,;
                          k})
    // поликлиника
    elseif human_->USL_OK == 3 .and. human->ishod < 101 ;
             .and. !(human_->profil==60 .and. glob_mo[_MO_KOD_TFOMS]=='103001') // не онкология
      is_period_amb := .t.
    endif
    select HU
    find (str(human->kod,7))
    do while hu->kod == human->kod .and. !eof()
      // если услуга в том же диапазоне лечения
      if between(hu->date_u,cd1,cd2)
        aadd(u_other, {hu->u_kod,hu->date_u,hu->kol_1,hu_->profil,0,human->n_data,human->k_data,human->OTD})
      endif
      if is_period_amb
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          if eq_any(left(lshifr,5),"2.80.","2.82.")
            is_period_amb := .f. ; exit
          elseif lshifr == "60.3.1" // перит.диализ
            aadd(a_dializ,{human->n_data,human->k_data,human_->USL_OK,human->OTD,3}) // диализы не в кругл.стационаре
            exit
          endif
        endif
      endif
      select HU
      skip
    enddo
    if is_period_amb
      aadd(a_period_amb,{human->n_data,human->k_data,human_->profil,human->OTD,human->(recno())})
    endif
    select MOHU
    find (str(human->kod,7))
    do while mohu->kod == human->kod .and. !eof()
      if between(mohu->date_u,cd1,cd2) // услуга в том же диапазоне лечения
        aadd(u_other, {mohu->u_kod,mohu->date_u,mohu->kol_1,mohu->profil,1})
      endif
      skip
    enddo
  endif
  // диспансеризация/профилактика взрослого населения
  if fl .and. between(human->ishod,201,205)
    // если год начала текущего лечения = году начала прошлого лечения
    if year(human->n_data) == year(d1) // для диспансеризации
      aadd(a_disp, {human->ishod-200,human->n_data,human->k_data,human_->RSLT_NEW})
    endif
    // для профилактики
    if human->ishod == 203 .and. count_years(human->date_r,human->n_data)==mvozrast
      aadd(a_disp, {human->ishod-200,human->n_data,human->k_data,human_->RSLT_NEW})
    endif
  endif
  select HUMAN
  skip
enddo
select HUMAN
set order to 1
dbGoto(rec_human)
G_RLock(forever)
uch->(dbGoto(human->LPU))
otd->(dbGoto(human->OTD))
s := fam_i_o(human->fio)+" "
if !empty(otd->short_name)
  s += "["+alltrim(otd->short_name)+"] "
endif
s += date_8(human->n_data)+"-"+date_8(human->k_data)
@ maxrow(),0 say padr(" "+s,50) color "G+/R"
if empty(CHARREPL("0",human->uch_doc,space(10)))
  if human_->usl_ok == 3
    s := "амбулаторной карты"
  elseif human_->usl_ok == 4
    s := "карты вызова"
  else
    s := "истории болезни"
  endif
  aadd(ta,'Не заполнен номер '+s+': '+human->uch_doc)
endif
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
if d2_year - d1_year > 1
  aadd(ta, "время лечения составляет "+lstr(human->k_data-human->n_data)+" дней")
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
if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
  human->KOD_DIAG := "Z01.7" // всегда
endif
mdiagnoz := diag_to_array(,,,,.t.)
if len(mdiagnoz) == 0 .or. empty(mdiagnoz[1])
  aadd(ta,'не заполнено поле "ОСНОВНОЙ ДИАГНОЗ"')
endif
if select("MKB_10") == 0
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
endif
select MKB_10
for i := 1 to len(mdiagnoz)
  mdiagnoz[i] := padr(mdiagnoz[i],6)
  find (mdiagnoz[i])
  if found()
    if !between(human->ishod,101,305) .and. i == 1 .and. !between_date(mkb_10->dbegin,mkb_10->dend,human->k_data)
      aadd(ta,"основной диагноз не входит в ОМС")
    endif
    if !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
      aadd(ta,"несовместимость диагноза по полу "+alltrim(mdiagnoz[i]))
    endif
  else
    aadd(ta,"не найден диагноз "+alltrim(mdiagnoz[i])+" в справочнике МКБ-10")
  endif
next
mdiagnoz3 := {}
if !empty(human_2->OSL1)
  aadd(mdiagnoz3,human_2->OSL1)
endif
if !empty(human_2->OSL2)
  aadd(mdiagnoz3,human_2->OSL2)
endif
if !empty(human_2->OSL3)
  aadd(mdiagnoz3,human_2->OSL3)
endif
select MKB_10
for i := 1 to len(mdiagnoz3)
  mdiagnoz3[i] := padr(mdiagnoz3[i],6)
  find (mdiagnoz3[i])
  if found()
    if !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
      aadd(ta,"несовместимость диагноза по полу "+alltrim(mdiagnoz3[i]))
    endif
  else
    aadd(ta,"не найден диагноз "+alltrim(mdiagnoz3[i])+" в справочнике МКБ-10")
  endif
next
if ascan(menu_vidud,{|x| x[2] == kart_->vid_ud }) == 0
  if human_->vpolis < 3
    aadd(ta,'не заполнено поле "ВИД удостоверения личности"')
  endif
else
  if empty(kart_->nom_ud)
    if human_->vpolis < 3
      aadd(ta,'должно быть заполнено поле "НОМЕР удостоверения личности" для "'+;
              inieditspr(A__MENUVERT, menu_vidud, kart_->vid_ud)+'"')
    endif
  //elseif !eq_any(kart_->vid_ud,9,18,21,24) .and. !ver_number(kart_->nom_ud)
    //aadd(ta,'поле "НОМЕР удостоверения личности" должно быть цифровым')
  endif
  if !empty(kart_->nom_ud)
    s := space(80)
    if !val_ud_nom(2,kart_->vid_ud,kart_->nom_ud,@s)
      aadd(ta,s)
    endif
  endif
  if eq_any(kart_->vid_ud,1,3,14) .and. empty(kart_->ser_ud)
    aadd(ta,'не заполнено поле "СЕРИЯ удостоверения личности" для "'+;
            inieditspr(A__MENUVERT, menu_vidud, kart_->vid_ud)+'"')
  endif
  if human_->usl_ok < 4 .and. eq_any(kart_->vid_ud,3,14) .and. ;
         !empty(kart_->ser_ud) .and. empty(del_spec_symbol(kart_->mesto_r)) .and. human_->vpolis < 3
    aadd(ta,iif(kart_->vid_ud==3,'для свид-ва о рождении','для паспорта РФ')+;
            ' обязательно заполнение поля "Место рождения"')
  endif
  if !empty(kart_->ser_ud)
    s := space(80)
    if !val_ud_ser(2,kart_->vid_ud,kart_->ser_ud,@s)
      aadd(ta,s)
    endif
  endif
endif
val_fio(retFamImOt(2,.f.),ta)
kart_->(G_RLock(forever))
s := alltrim(kart_->okatog)
if mo_nodigit(s)
  aadd(ta,"нецифровые символы в ОКАТО регистрации")
endif
if len(s) == 0
  if human_->vpolis < 3
    aadd(ta,'не заполнен код ОКАТО в поле "Адрес регистрации"')
  endif
elseif len(s) > 0 .and. len(s) < 11
  kart_->okatog := padr(s,11,"0")
endif
s := alltrim(kart_->okatop)
if mo_nodigit(s)
  aadd(ta,"нецифровые символы в ОКАТО пребывания")
endif
if len(s) > 0 .and. len(s) < 11
  kart_->okatop := padr(s,11,"0")
endif
if !empty(kart->snils)
  s := space(80)
  if !val_snils(kart->snils,2,@s)
    aadd(ta,s+" у пациента")
  endif
endif
human_->(G_RLock(forever))
human_->SPOLIS := val_polis(human_->SPOLIS)
human_->NPOLIS := val_polis(human_->NPOLIS)
Valid_SN_Polis(human_->vpolis,human_->SPOLIS,human_->NPOLIS,ta,between(human_->smo,'34001','34007'))
human_2->(G_RLock(forever))
//
if select("SMO") == 0
  R_Use(dir_exe+"_mo_smo",cur_dir+"_mo_smo2","SMO")
  //index on smo to (sbase+'2')
endif
select SMO
if alltrim(human_->smo) == '34'
  if empty(human_->OKATO)
    aadd(ta,'не введён субъект РФ, в котором застрахован пациент')
  elseif empty(ret_inogSMO_name(2))
    aadd(ta,'не введена иногородняя страховая компания')
  endif
else
  select SMO
  find (human_->smo)
  if found()
    human_->OKATO := smo->okato
  else
    aadd(ta,'не найдена СМО с кодом "'+human_->smo+'"')
  endif
endif
//
d := human->k_data - human->n_data
adiag := {}
kkd := kds := kvp := kuet := kkt := ksmp := 0
mpztip := mpzkol := kol_uet := 0
kkd_1_11 := kkd_1_12 := kol_ksg := 0
is_reabil := is_dializ := is_perito := is_s_dializ := is_eko := fl_stom := fl_dop_ob_em := .f.
if is_dop_ob_em
  fl_dop_ob_em := (human->reg_lech == 9)
endif
au_lu := {} ; au_flu := {} ; au_lu_ne := {} ; arr_perso := {} ; arr_unit := {}
is_kt := is_mrt := is_angio := is_koronaro := is_g_cit := is_pr_skr := .f.
is_71_1 := is_71_2 := is_71_3 := is_dom := .f.
kvp_2_78 := kvp_2_89 := kol_2_3 := kol_2_60 := kol_2_4 := kol_2_6 := kol_55_1 := 0
kvp_70_5 := kvp_70_6 := kvp_70_3 := kvp_72_2 := kvp_72_3 := kvp_72_4 := 0
is_2_78 := is_2_79 := is_2_80 := is_2_81 := is_2_82 := .f.
is_2_83 := is_2_84 := is_2_85 := is_2_86 := is_2_87 := is_2_88 := is_2_89 := .f.
a_2_89 := {0,0,0}
is_disp_DDS := is_disp_DVN := is_disp_DVN3 := is_prof_PN := is_neonat := is_pren_diagn := .f.
is_70_3 := is_70_5 := is_70_6 := is_72_2 := is_72_3 := is_72_4 := .f.
lstkol := 0 ; lstshifr := shifr_ksg := "" ; cena_ksg := 0
midsp := musl_ok := mRSLT_NEW := mprofil := mvrach := m1lis := 0
lvidpoms := ""
// для физкультурного диспансера
arr_lfk := {"3.1.5","3.1.19","3.4.31","4.2.153","4.11.136","7.12.5",;
            "7.12.6","7.12.7","7.2.2","13.1.1","14.2.3",;
            "19.1.2","19.1.5","19.1.6","19.1.7","19.1.9","19.1.11","19.1.12","19.1.29","19.1.30",;
            "19.2.2","19.2.4","19.3.1","19.5.19","19.6.1",;
            "20.1.1","20.1.2","20.1.3",;
            "20.2.1","20.2.2",;
            "21.1.1","21.1.2","21.1.3",;
            "22.1.1","22.1.2","22.1.3"}
//
f_put_glob_podr(human_->USL_OK,d2,ta) // заполнить код подразделения
musl_ok := 3  // п-ка по умолчанию 
ldnej := 0
if human_->USL_OK < 3
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
      lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
      if eq_any(left(lshifr,5),"1.11.","55.1.")
        ldnej += hu->kol_1
      endif
    endif
    select HU
    skip
  enddo
endif
select HU
find (str(human->kod,7))
do while hu->kod == human->kod .and. !eof()
  lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
  if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,@auet,@lbukva,@lst,@lidsp,@s)
    if empty(hu->kol_1)
      aadd(ta,'не заполнено поле "Количество услуг" для "'+alltrim(usl->shifr)+'"')
    endif
    lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
    if hu->STOIM_1 > 0 .or. left(lshifr,3) == "71."  // скорая помощь
      if !empty(lbukva) .and. ascan(a_bukva,{|x| x[1] == lbukva }) == 0
        aadd(a_bukva,{lbukva,lshifr})
      endif
      if !empty(lidsp) .and. ascan(a_idsp,{|x| x[1] == lidsp }) == 0
        aadd(a_idsp,{lidsp,lshifr})
      endif
    endif
    if lst == 1
      k := 0 ; lstshifr := "" ; lstkol := hu->kol_1
      for i := 1 to len(lshifr)
        if !empty(c := substr(lshifr,i,1))
          lstshifr += c
          if c == "." ; ++k ; endif
          if k == 2 ; exit ; endif // две точки в шифре услуги
        endif
      next
    endif
    otd->(dbGoto(hu->OTD))
    hu_->(G_RLock(forever))
    if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
      hu_->kod_diag := mdiagnoz[1]
    endif
    if hu->is_edit == 0 .and. is_lab_usluga(lshifr)
      hu->(G_RLock(forever))
      hu->is_edit := -1
      hu->kod_vr := hu->kod_as := 0
      lprofil := iif(left(lshifr,5) == "4.16.", 6, 34)
      if select("MOPROF") == 0
        R_Use(dir_exe+"_mo_prof",cur_dir+"_mo_prof","MOPROF")
        //index on shifr+str(vzros_reb,1)+str(profil,3) to (sbase)
      endif
      select MOPROF
      find (padr(lshifr,20)+str(iif(human->vzros_reb == 0, 0, 1),1))
      if found()
        lprofil := moprof->profil
      endif
      hu_->profil := lprofil
    endif
    if empty(hu->kod_vr)
      if eq_any(alltrim(lshifr),"4.20.2")
        // не заполняется код врача
      elseif hu->is_edit == -1
        if human_->USL_OK == 3
          hu_->PRVS := iif(hu_->profil == 34, -13, -54)
        else
          aadd(ta,'лабораторная услуга "'+alltrim(usl->shifr)+'" может быть оказана только в поликлинике')
        endif
      else
        aadd(ta,'не заполнено поле "Врач, оказавший услугу '+alltrim(usl->shifr)+'"')
      endif
    else
      if empty(mvrach) .and. !(ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34))
        mvrach := hu->kod_vr
      endif
      pers->(dbGoto(hu->kod_vr))
      mprvs := -ret_new_spec(pers->prvs,pers->prvs_new)
      if empty(mprvs)
        aadd(ta,'нет специальности в справочнике персонала у "'+alltrim(pers->fio)+'"')
      elseif hu_->PRVS != mprvs
        hu_->PRVS := mprvs
      endif
      if hu_->PRVS > 0 .and. ret_V004_V015(hu_->PRVS) == 0
        aadd(ta,'не найдено специальности в справочнике V015 у "'+alltrim(pers->fio)+'"')
      endif
      // проверяем на специальность
      UslugaAccordancePRVS(lshifr,human->vzros_reb,hu_->prvs,ta,usl->shifr,hu->kod_vr)
    endif
    if empty(mprofil)
      mprofil := usl->profil
      if empty(mprofil)
        mprofil := hu_->profil
      endif
    endif
    if empty(hu_->profil)
      hu_->profil := usl->profil
      if empty(hu_->profil)
        hu_->profil := otd->profil
      endif
    endif
    if hu_->profil > 0 .and. hu_->profil != correct_profil(hu_->profil)
      hu_->profil := correct_profil(hu_->profil)
    endif
    if !valid_GUID(hu_->ID_U)
      hu_->ID_U := mo_guid(3,hu_->(recno()))
    endif
    mdate := c4tod(hu->date_u)
    if !empty(hu->kod_vr) .and. mdate >= human->n_data .and. ascan(arr_perso,hu->kod_vr) == 0
      aadd(arr_perso,hu->kod_vr)
    endif
    mdate_u1 := dtoc4(human->n_data)
    mdate_u2 := hu->date_u
    alltrim_lshifr := alltrim(lshifr)
    left_lshifr_2 := left(lshifr,2)
    left_lshifr_3 := left(lshifr,3)
    left_lshifr_4 := left(lshifr,4)
    left_lshifr_5 := left(lshifr,5)
    if hu->kol_1 > 1 .and. ascan(arr_lfk,alltrim_lshifr) > 0
      mdate_u2 := dtoc4(mdate + hu->kol_1 - 1)
    endif
    // проверяем на профиль
    lprofil := UslugaAccordanceProfil(lshifr,human->vzros_reb,hu_->profil,ta,usl->shifr)
    if human_->USL_OK == 4 .and. lprofil != hu_->profil
      hu_->profil := lprofil
    endif
    select LUSL18
    find (padr(lshifr,10))
    if found() .and. !empty(lusl18->unit_code) .and. ascan(arr_unit,lusl18->unit_code) == 0
      aadd(arr_unit,lusl18->unit_code)
    endif
    aadd(au_lu,{lshifr,;              // 1
                mdate,;               // 2
                hu_->profil,;         // 3
                hu_->PRVS,;           // 4
                alltrim(usl->shifr),; // 5
                hu->kol_1,;           // 6
                c4tod(mdate_u2),;     // 7
                hu_->kod_diag,;       // 8
                hu->(recno()),;       // 9 - номер записи
                hu->is_edit})         // 10
    kodKSG := ""
    if is_ksg(lshifr)
      if !empty(s) .and. "," $ s
        lvidpoms := s
      endif
      shifr_ksg := kodKSG := alltrim_lshifr
      cena_ksg := hu->u_cena
      if between(int(val(kodKSG)),1325,1342) .or. between(int(val(kodKSG)),2123,2134)
        is_reabil := .t.
      elseif kodKSG == '2005.0'
        is_eko := .t.
      endif
      kol_ksg += hu->kol_1
    endif
    if !empty(kodKSG) // КСГ
      if left(kodKSG,1) == "1"
        musl_ok := 1  // стационар
        midsp := 33
        /*if d2 > 0d20181031
          if glob_mo[_MO_KOD_TFOMS] == '791904'
            aadd(ta,'в Вашей МО работа со стационаром приостановлена до следующей тарифной комиссии')
          elseif eq_any(int(val(kodKSG)),1002,1004,1005)
            aadd(ta,'работа с данной КСГ приостановлена до следующей тарифной комиссии')
          endif
        endif*/
      else
        musl_ok := 2  // дневной стационар
        midsp := 43
      endif
      mdate_u2 := dtoc4(human->k_data)
    elseif left_lshifr_2 == "1."
      musl_ok := 1  // стационар
      mdate_u2 := dtoc4(human->k_data)
      if left_lshifr_5 == "1.11."
        kkd += hu->kol_1
        kkd_1_11 += hu->kol_1
        hu_->PZKOL := hu->kol_1
        if mdate+hu->kol_1 <= d2
          mdate_u2 := dtoc4(mdate+hu->kol_1)
        endif
      // elseif eq_any(left_lshifr_5,"1.12.","1.15.","1.16.","1.17.","1.18.") // ВМП  // 07.02.2021
      elseif eq_any(left_lshifr_5,"1.20.","1.15.","1.16.","1.17.","1.18.") // ВМП
        midsp := 18 // Законченный случай в круглосуточном стационаре
        kkd_1_12 += hu->kol_1
        kol_ksg += hu->kol_1
        hu_->PZKOL := d
        if !is_12_VMP
          aadd(ta,'работа с услугой '+alltrim_lshifr+' запрещена в Вашей МО')
        endif
      else
        // ошибка
      endif
      hu_->PZTIP := 1
    elseif left_lshifr_3 == "55."
      musl_ok := 2  // дн.стационар
      mdate_u2 := dtoc4(human->k_data)
      if left_lshifr_5 == "55.1." // кол-во пациенто-дней
        kds += hu->kol_1
        kol_55_1 += hu->kol_1
        hu_->PZKOL := hu->kol_1
        if mdate+hu->kol_1-1 <= d2
          mdate_u2 := dtoc4(mdate+hu->kol_1-1)
        endif
      else
        // ошибка
      endif
      hu_->PZTIP := 2
    elseif alltrim_lshifr == "56.1.723" .and. human->ishod == 202 // второй этап ДВН - одна услуга
      is_disp_DVN := .t.
    elseif left_lshifr_5 == "60.2." .or. eq_any(alltrim_lshifr,"4.20.702","4.15.746") // ЛДП
      mpovod := 1 // 1.0
      mIDSP := 4 // лечебно-диагностическая процедура
      kkt += hu->kol_1
      hu_->PZTIP := 5
      hu_->PZKOL := hu->kol_1
      musl_ok := 3  // п-ка
      if eq_any(alltrim_lshifr,"60.2.1","60.2.2","60.2.8")
        is_kt := .t.
      elseif eq_any(alltrim_lshifr,"60.2.3","60.2.4")
        is_mrt := .t.
      elseif alltrim_lshifr == "60.2.6"
        is_angio := .t.
      elseif alltrim_lshifr == "60.2.7"
        is_koronaro := .t.
      elseif alltrim_lshifr == "4.20.702"
        is_g_cit := .t.
      elseif alltrim_lshifr == "4.15.746"
        is_pr_skr := .t.
      endif
    elseif left_lshifr_5 == "60.3." // диализ
      mIDSP := 4 // лечебно-диагностическая процедура
      kkt += hu->kol_1
      hu_->PZTIP := 5
      hu_->PZKOL := hu->kol_1
      mdate_u2 := dtoc4(human->k_data)
      if alltrim_lshifr == "60.3.1"
        mpovod := 10 // 3.0
        musl_ok := 3  // п-ка
        is_perito := .t.
      elseif eq_any(alltrim_lshifr,"60.3.9","60.3.10")
        musl_ok := 2  // дневной стационар
        is_dializ := .t.
      else
        musl_ok := 1  // стационар
        is_s_dializ := .t.
      endif
    elseif eq_any(left_lshifr_5,"71.1.","71.2.","71.3.")  // скорая помощь
      musl_ok := 4  // СМП
      mIDSP := 24 // Вызов скорой медицинской помощи
      if left_lshifr_5 == "71.1."
        is_71_1 := .t.
      elseif left_lshifr_5 == "71.2."
        is_71_2 := .t.
      else
        is_71_3 := .t.
      endif
      hu_->PZTIP := 6
      hu_->PZKOL := hu->kol_1
      ksmp += hu->kol_1
    elseif left_lshifr_2 == "4."
      if left_lshifr_5 == "4.26."
        is_neonat := .t.
      endif
      if hu->is_edit == 1 .and. d1 <= c4tod(mdate_u2)
        m1lis := 1
      endif
    else
      musl_ok := 3  // п-ка
      mIDSP := 1 // Посещение в поликлинике
      mpztip := 3 ; mpzkol := hu->kol_1
      if hu->KOL_RCP < 0
        is_dom := .t.
      endif
      if left_lshifr_4 == "2.3."
        kol_2_3++
      elseif left_lshifr_4 == "2.6."
        kol_2_6++
      elseif left_lshifr_5 == "2.60."
        kol_2_60++
      elseif alltrim_lshifr == "2.4.1"
        kol_2_4++
      elseif left_lshifr_5 == "2.76."
        mpovod := 7 // 2.3
        mIDSP := 12 // Комплексная услуга центра здоровья
      elseif left_lshifr_5 == "2.78."
        mpovod := 10 // 3.0
        if between_shifr(alltrim_lshifr,"2.78.54","2.78.60")
          fl_stom := .t.
          mpztip := 4
        else
          ++kvp_2_78
          is_2_78 := .t.
          mIDSP := 17 // Законченный случай в поликлинике
        endif
        mdate_u2 := dtoc4(human->k_data)
      elseif left_lshifr_5 == "2.79."
        if between_shifr(alltrim_lshifr,"2.79.44","2.79.50")
          mpovod := 8 // 2.5 - патронаж
        else
          mpovod := 9 // 2.6
        endif
        if between_shifr(alltrim_lshifr,"2.79.59","2.79.64")
          fl_stom := .t.
          mpztip := 4
        else
          is_2_79 := .t.
          if alltrim_lshifr == "2.79.51"
            is_pren_diagn := .t.
          endif
        endif
      elseif left_lshifr_5 == "2.80."
        mpovod := 2 // 1.1
        if between_shifr(alltrim_lshifr,"2.80.34","2.80.38")
          fl_stom := .t.
          mpztip := 4
        else
          is_2_80 := .t.
        endif
      elseif left_lshifr_5 == "2.81."
        mpovod := 1 // 1.0
        is_2_81 := .t.
      elseif left_lshifr_5 == "2.82."
        mpovod := 2 // 1.1
        is_2_82 := .t.
        mIDSP := 22 // Посещение в приёмном покое
      elseif left_lshifr_5 == "2.83."
        is_disp_DDS := .t.
        is_2_83 := .t.
      elseif left_lshifr_5 == "2.84."
        mIDSP := 11 // диспансеризация
        is_disp_DVN := .t.
        is_2_84 := .t.
      elseif left_lshifr_5 == "2.85." // профилактика несовершеннолетних
        is_prof_PN := .t.
        is_2_85 := .t.
      elseif left_lshifr_5 == "2.87."
        is_disp_DDS := .t.
        is_2_87 := .t.
      elseif left_lshifr_5 == "2.88."
        mpovod := 1 // 1.0
        if between_shifr(alltrim_lshifr,"2.88.46","2.88.51")
          fl_stom := .t.
          mpztip := 4
        else
          is_2_88 := .t.
        endif
      elseif left_lshifr_5 == "2.89."
        mpovod := 10 // 3.0
        ++kvp_2_89
        is_2_89 := .t.
        i := int(val(right(alltrim_lshifr,1)))
        if !between(i,1,len(a_2_89))
          i := 2
        endif
        a_2_89[i] := 1
        mdate_u2 := dtoc4(human->k_data)
      elseif left_lshifr_5 == "2.90."
        mIDSP := 11 // диспансеризация
        is_disp_DVN := .t.
      elseif left_lshifr_5 == "2.91."
        mIDSP := 29 // за посещение в поликлинике
        is_prof_PN := .t.
      elseif eq_any(left_lshifr_5,"70.3.","72.1.") // диспансеризация взрослых
        is_disp_DVN := .t.
        if left_lshifr_5 == "70.3."
          mIDSP := 11 // диспансеризация
        else
          is_disp_DVN3 := .t.
          mIDSP := 17 // Законченный случай в поликлинике
        endif
        ++kvp_70_3
        is_70_3 := .t.
        mdate_u2 := dtoc4(human->k_data)
      elseif left_lshifr_5 == "72.2." // профилактика несовершеннолетних
        is_prof_PN := .t.
        ++kvp_72_2
        is_72_2 := .t.
        mdate_u2 := dtoc4(human->k_data)
      elseif left_lshifr_5 == "70.5." // диспансеризация детей-сирот
        is_disp_DDS := .t.
        mIDSP := 11 // диспансеризация
        ++kvp_70_5
        is_70_5 := .t.
        mdate_u2 := dtoc4(human->k_data)
      elseif left_lshifr_5 == "70.6." // диспансеризация детей-сирот
        is_disp_DDS := .t.
        mIDSP := 11 // диспансеризация
        ++kvp_70_6
        is_70_6 := .t.
        mdate_u2 := dtoc4(human->k_data)
      endif
      if is_usluga_disp_nabl(alltrim_lshifr)
        mpovod := 4 // 1.3-Диспансерное наблюдение
        ldate_next := c4tod(human->DATE_OPL)
        if empty(ldate_next)
          aadd(ta,'для услуги '+alltrim_lshifr+' не заполнена "Дата следующей явки пациента для диспансерного наблюдения"')
        elseif ldate_next < d2
          aadd(ta,'для услуги '+alltrim_lshifr+' "дата следующей явки пациента для диспансерного наблюдения" меньше даты окончания лечения')
        endif
      endif
      kvp += hu->kol_1
      hu_->PZTIP := mPZTIP
      hu_->PZKOL := mPZKOL
    endif
    if musl_ok != 3 .and. !(hu->date_u==mdate_u1) .and. len(au_lu) == 1
      aadd(ta,'дата услуги '+alltrim_lshifr+' должна равняться дате начала лечения')
    endif
    hu_->date_u2 := mdate_u2
    if empty(hu_->kod_diag) .and. len(mdiagnoz) > 0
      hu_->kod_diag := mdiagnoz[1]
    endif
    select MKB_10
    find (padr(hu_->kod_diag,6))
    if !found()
      aadd(ta,"не найден диагноз "+alltrim(hu_->kod_diag)+"("+alltrim(usl->shifr)+") в справочнике МКБ-10")
    endif
    aadd(adiag,hu_->kod_diag)
    atail(au_lu)[7] := c4tod(mdate_u2)
    atail(au_lu)[8] := hu_->kod_diag
    if empty(kodKSG) // для КСГ цену перепроверим потом через definition_ksg()
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
      else
        aadd(ta,'Не найдена услуга '+rtrim(lshifr)+iif(human->vzros_reb==0," для взрослых"," для детей")+' в справочнике ТФОМС')
      endif
    endif
    ssumma += hu->stoim_1
  else
    aadd(au_lu_ne,{usl->shifr,;        // 1
                   lshifr1,;           // 2
                   usl->name,;         // 3
                   c4tod(hu->date_u),; // 4
                   hu->kol_1})         // 5
  endif
  select HU
  skip
enddo
if is_dom .and. mpovod == 1
  mpovod := 3 // 1.2 - активное посещение, т.е. на дому
endif
//
fl := (ascan(mdiagnoz, {|x| padr(x,5) == "Z03.1" }) > 0)
if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN
  is_oncology := 0
  if fl
    aadd(ta,'при диспансеризации не должно быть основного (или сопутствующего) диагноза Z03.1 "наблюдение при подозрении на злокачественную опухоль"')
  endif
else
  for i := 1 to len(au_lu)
    if !between(au_lu[i,2],d1,d2)
      aadd(ta,'услуга '+au_lu[i,5]+'('+date_8(au_lu[i,2])+') не попадает в диапазон лечения')
    endif
  next
  if version_3_1 .and. human_->usl_ok < 4 .and. fl .and. !(human->OBRASHEN == '1')
    if is_oncology > 0 // онкология - направления
      aadd(ta,'основной (или сопутствующий) диагноз Z03.1 "наблюдение при подозрении на злокачественную опухоль", но лист учёта и так онкологический')
    else
      aadd(ta,'если основной (или сопутствующий) диагноз Z03.1 "наблюдение при подозрении на злокачественную опухоль", то в поле "подозрение на ЗНО" должно стоять "да"')
    endif
  endif
endif
al := "luslf18"
if is_oncology > 0 // онкология - направления
  if is_oncology == 2 // онкология
    if mpovod == 4  // Диспансерное наблюдение
      is_oncology := 1 // для дисп.наблюдения не вводится онкология
    elseif human_->USL_OK == 3 .and. len(au_lu) == 0
      is_oncology := 1 // пока не введены услуги - не проверяем онкологию
    endif
  endif
  if human->OBRASHEN == '1' .and. ascan(mdiagnoz, {|x| padr(x,5) == "Z03.1" }) == 0
    aadd(ta,'при "подозрении на ЗНО" в листе учёта обязательно должен быть основной (или сопутствующий) диагноз Z03.1 "наблюдение при подозрении на злокачественную опухоль"')
  endif
  i := 0
  arr := {}
  select ONKNA // онконаправления
  find (str(human->kod,7))
  do while onkna->kod == human->kod .and. !eof()
    ++i
    aadd(arr, {onkna->NAPR_DATE,;
               onkna->NAPR_V,;
               iif(onkna->NAPR_V == 3, onkna->MET_ISSL, 0),;
               iif(onkna->NAPR_V == 3, onkna->U_KOD, 0),;
               "",;
               onkna->(recno()) })
    if !between(onkna->NAPR_DATE,d1,d2)
      aadd(ta,"дата направления должна быть внутри сроков лечения (направление "+lstr(i)+')')
    endif
    if onkna->NAPR_V == 3
      if empty(onkna->MET_ISSL)
        aadd(ta,'не определён "Метод диагн.исследования" для направления '+lstr(i))
      elseif empty(onkna->U_KOD)
        aadd(ta,'не определена "Медицинская услуга" для направления '+lstr(i))
      else
        select MOSU
        goto (onkna->U_KOD)
        if empty(mosu->shifr1)
          aadd(ta,'не определена "Медицинская услуга" для направления '+lstr(i))
        else
          dbSelectArea(al)
          find (padr(mosu->shifr1,20))
          if found()
            if onkna->MET_ISSL != &al.->onko_napr
              aadd(ta,'не тот метод диагн.исследования в услуге '+;
                      alltrim(iif(empty(mosu->shifr),mosu->shifr1,mosu->shifr))+' для направления '+lstr(i))
            endif
          else
            aadd(ta,'услуга '+alltrim(iif(empty(mosu->shifr),mosu->shifr1,mosu->shifr))+;
                    ' не найдена в справочнике (для направления '+lstr(i)+')')
          endif
        endif
      endif
    endif
    select ONKNA
    skip
  enddo
  for i := 1 to len(arr)  // ищем дубликаты направления
    s := dtos(arr[i,1])+str(arr[i,2],1)+str(arr[i,3],1)+str(arr[i,4],6)
    arr[i,5] := s
    if i > 1 .and. (j := ascan(arr, {|x| s == x[5] }, 1, i-1)) > 0
      select ONKNA
      goto (arr[i,6])
      DeleteRec(.t.)  // удаляем дубликат направления
    endif
  next
endif
//
select MOHU
find (str(human->kod,7))
do while mohu->kod == human->kod .and. !eof()
  lshifr := mosu->shifr1
  dbSelectArea(al)
  find (padr(lshifr,20))
  usl_found := found()
  s := alltrim(mosu->shifr1)+iif(empty(mosu->shifr),"","("+alltrim(mosu->shifr)+")")
  if mosu->tip == 5
    aadd(ta,'услуга "'+s+'" удалена в 2017 году')
  endif
  if empty(mohu->kol_1)
    aadd(ta,'не заполнено поле "Количество услуг" для "'+s+'"')
  endif
  mdate := c4tod(mohu->date_u)
  if !between(mdate,d1,d2)
    aadd(ta,'услуга '+s+' ('+date_8(mdate)+') не попадает в диапазон лечения')
  endif
  otd->(dbGoto(mohu->OTD))
  mohu->(G_RLock(forever))
  if empty(mohu->kod_vr)
    if usl_found .and. &al.->telemed == 1
      if !(mohu->PRVS == human_->PRVS)
        mohu->PRVS := human_->PRVS // для телемедицины специальность копируем из случая
      endif
      if !(mohu->profil == human_->profil)
        mohu->profil := human_->profil // для телемедицины профиль копируем из случая
      endif
    else
      aadd(ta,'не заполнено поле "Врач, оказавший услугу '+s+'"')
    endif
  else
    if ascan(arr_perso,mohu->kod_vr) == 0
      aadd(arr_perso,mohu->kod_vr)
    endif
    if empty(mvrach) .and. !(ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34))
      mvrach := mohu->kod_vr
    endif
    pers->(dbGoto(mohu->kod_vr))
    mprvs := -ret_new_spec(pers->prvs,pers->prvs_new)
    if empty(mprvs)
      aadd(ta,'нет специальности в справочнике персонала у "'+alltrim(pers->fio)+'"')
    elseif mohu->PRVS != mprvs
      mohu->PRVS := mprvs
    endif
    if mohu->PRVS > 0 .and. ret_V004_V015(mohu->PRVS) == 0
      aadd(ta,'не найдено специальности в справочнике V015 у "'+alltrim(pers->fio)+'"')
    endif
  endif
  if empty(mprofil)
    mprofil := mosu->profil
    if empty(mprofil)
      mprofil := mohu->profil
    endif
  endif
  if empty(mohu->profil)
    mohu->profil := mosu->profil
    if empty(mohu->profil)
      mohu->profil := otd->profil
    endif
  endif
  if empty(mohu->profil)
    aadd(ta,'для услуги '+s+' не заполнено поле "Профиль"')
  elseif mohu->profil != correct_profil(mohu->profil)
    mohu->profil := correct_profil(mohu->profil)
  endif
  ltip_onko := 0
  if usl_found
    ltip_onko := &al.->onko_ksg
    do case
      case human_->usl_ok == 1
        if &al.->tip == 2
          aadd(ta,'услуга '+s+' относится к стоматологическим')
        endif
      case human_->usl_ok == 2
        if &al.->tip == 2
          aadd(ta,'услуга '+s+' относится к стоматологическим')
        endif
      case human_->usl_ok == 3
        if fl_stom
          if empty(&al.->tip)
            aadd(ta,'услуга '+s+' не относится к стоматологическим')
          else
            // проверяем на профиль
            UslugaAccordanceProfil(lshifr,human->vzros_reb,mohu->profil,ta,mosu->shifr)
            // проверяем на специальность
            UslugaAccordancePRVS(lshifr,human->vzros_reb,mohu->prvs,ta,mosu->shifr,mohu->kod_vr)
          endif
        elseif &al.->telemed == 0
          aadd(ta,'услугу '+s+' нельзя вводить для амбулаторной помощи')
        endif
      case human_->usl_ok == 4
        if &al.->telemed == 0
          aadd(ta,'услугу '+s+' нельзя вводить для скорой помощи')
        endif
    endcase
  else
    aadd(ta,'услуга '+s+' не найдена в справочнике')
  endif
  if !valid_GUID(mohu->ID_U)
    mohu->ID_U := mo_guid(4,mohu->(recno()))
  endif
  mohu->date_u2 := mohu->date_u
  if empty(mohu->kod_diag) .and. len(mdiagnoz) > 0
    mohu->kod_diag := mdiagnoz[1]
  endif
  select MKB_10
  find (padr(mohu->kod_diag,6))
  if !found()
    aadd(ta,"не найден диагноз "+alltrim(mohu->kod_diag)+" в справочнике МКБ-10")
  endif
  aadd(au_flu,{lshifr,;               // 1
               mdate,;                // 2
               mohu->profil,;         // 3
               mohu->PRVS,;           // 4
               mosu->shifr,;          // 5
               mohu->kol_1,;          // 6
               c4tod(mohu->date_u2),; // 7
               mohu->kod_diag,;       // 8
               mohu->(recno()),;      // 9
               ltip_onko,;            // 10 тип онкологического лечения
               .f.})                  // 11 тип онкологического лечения ставим в услугу
  select MOHU
  skip
enddo
v := 0
if .f. // is_oncology == 2 // онкология - в 2019 за 2018 не проверяем и не отправляем
  select ONKSL
  find (str(human->kod,7))
  if between(onksl->PR_CONS,1,3) .and. !between(onksl->DT_CONS,d1,d2)
    aadd(ta,"дата консилиума по онкологии должна быть внутри сроков лечения")
  endif
  fl := .t.
  if empty(onksl->ONK_T)
    fl := .f. ; aadd(ta,"онкология: не введена стадия заболевания T")
  endif
  if empty(onksl->ONK_N)
    fl := .f. ; aadd(ta,"онкология: не введена стадия заболевания N")
  endif
  if empty(onksl->ONK_M)
    fl := .f. ; aadd(ta,"онкология: не введена стадия заболевания M")
  endif
  fl_lock_onksl := .t.
  if fl
    fl := f_verify_tnm(3,onksl->ONK_T,mdiagnoz[1],ta)
    if fl
      fl := f_verify_tnm(4,onksl->ONK_N,mdiagnoz[1],ta)
    endif
    if fl
      fl := f_verify_tnm(5,onksl->ONK_M,mdiagnoz[1],ta)
    endif
    if fl
      if select("N6") == 0
        R_Use(dir_exe+"_mo_N006",cur_dir+"_mo_N006","N6")
      endif
      select N6
      s := padr(mdiagnoz[1],5)
      find (s)
      if !(fl_found := found())
        s := padr(mdiagnoz[1],3)
        find (s)
        fl_found := (found() .and. s == alltrim(n6->ds_gr))
      endif
      if fl_found
        find (padr(s,5)+str(onksl->ONK_T,6)+str(onksl->ONK_N,6)+str(onksl->ONK_M,6))
        if found()
          if onksl->stad != n6->id_st
            fl_lock_onksl := .f.
            select ONKSL
            G_RLock(forever)
            onksl->stad := n6->id_st // Справочник N006: по сочетанию стадий TNM исправлено поле "Стадия"
          endif
        else
          aadd(ta,"справочник N006: некорректное сочетание стадий TNM")
        endif
      else
        if empty(onksl->STAD)
          aadd(ta,"онкология: не введена стадия заболевания")
        else
          f_verify_tnm(2,onksl->STAD,mdiagnoz[1],ta)
        endif
      endif
    endif
  endif
  // гистология
  ar_N009 := {}
  if select("N9") == 0
    R_Use(dir_exe+"_mo_N009",,"N9")
  endif
  select N9
  dbeval({|| aadd(ar_N009,{"",n9->id_mrf,{}}) }, {|| padr(mdiagnoz[1],3) == n9->ds_mrf })
  /*if len(ar_N009) > 0
        R_Use(exe_dir+"_mo_N007",cur_dir+"_mo_N007","N7")
        R_Use(exe_dir+"_mo_N008",cur_dir+"_mo_N008","N8")
        for i := 1 to min(2,len(mm_N009))
          select N7
          find (str(mm_N009[i,2],6))
          if found()
            mm_N009[i,1] := alltrim(n7->mrf_name)
          else
            func_error(4,"Не найден гистологический признак ID_MRF="+lstr(mm_N009[i,2])+" для "+mkod_diag)
          endif
          select N8
          find (str(mm_N009[i,2],6))
          do while n8->id_mrf == mm_N009[i,2] .and. !eof()
            aadd(mm_N009[i,3], {alltrim(n8->r_m_name),n8->id_r_m})
            skip
          enddo
          if ascan(mm_N009[i,3], {|x| x[2] == &("m1gist"+lstr(i)) }) == 0
            &("m1gist"+lstr(i)) := 0
          endif
          &("mgist"+lstr(i)) := inieditspr(A__MENUVERT, mm_N009[i,3], &("m1gist"+lstr(i)))
        next
      endif*/
  // Иммуногистохимия/маркеры
  ar_N012 := {}
  if select("N12") == 0
    R_Use(dir_exe+"_mo_N012",,"N12")
  endif
  select N12
  dbeval({|| aadd(ar_N012,{"",n12->id_igh,{}}) }, {|| padr(mdiagnoz[1],3) == n12->ds_igh })
  /*if len(ar_N012) > 0
        R_Use(exe_dir+"_mo_N010",cur_dir+"_mo_N010","N10")
        R_Use(exe_dir+"_mo_N011",cur_dir+"_mo_N011","N11")
        for i := 1 to min(5,len(mm_N012))
          select N10
          find (str(mm_N012[i,2],6))
          if found()
            mm_N012[i,1] := alltrim(n10->igh_name)
          else
            func_error(4,"Не найден гистологический признак ID_IGH="+lstr(mm_N012[i,2])+" для "+mkod_diag)
          endif
          select N11
          find (str(mm_N012[i,2],6))
          do while n11->id_igh == mm_N012[i,2] .and. !eof()
            aadd(mm_N012[i,3], {alltrim(n11->kod_r_i),n11->id_r_i})
            skip
          enddo
          if ascan(mm_N012[i,3], {|x| x[2] == &("m1mark"+lstr(i)) }) == 0
            &("m1mark"+lstr(i)) := 0
          endif
          &("mmark"+lstr(i)) := inieditspr(A__MENUVERT, mm_N012[i,3], &("m1mark"+lstr(i)))
        next
      endif*/
  arr_onkdi0 := {}
  arr_onkdi1 := {}
  arr_onkdi2 := {}
  select ONKDI
  find (str(human->kod,7))
  do while onkdi->kod == human->kod .and. !eof()
    if !empty(onkdi->DIAG_DATE)
      aadd(arr_onkdi0, {onkdi->DIAG_DATE,onkdi->DIAG_TIP,onkdi->DIAG_CODE,onkdi->DIAG_RSLT})
    elseif onkdi->DIAG_TIP == 1
      aadd(arr_onkdi1, {onkdi->DIAG_DATE,onkdi->DIAG_TIP,onkdi->DIAG_CODE,onkdi->DIAG_RSLT})
    elseif onkdi->DIAG_TIP == 2
      aadd(arr_onkdi2, {onkdi->DIAG_DATE,onkdi->DIAG_TIP,onkdi->DIAG_CODE,onkdi->DIAG_RSLT})
    endif
    skip
  enddo
  if len(arr_onkdi0) == 0
    if len(arr_onkdi1) != len(ar_N009)
      aadd(ta,"не все гистологии заполнены")
    endif
    if len(arr_onkdi2) != len(ar_N012)
      aadd(ta,"не все иммуногистохимии заполнены")
    endif
  else
    if len(arr_onkdi1) > 0
      aadd(ta,"гистология не должна заполняться при заполненной дате взятия материала")
    endif
    if len(arr_onkdi2) > 0
      aadd(ta,"иммуногистохимия не должна заполняться при заполненной дате взятия материала")
    endif
  endif
  //
  if select("N1") == 0
    R_Use(dir_exe+"_mo_N001",,"N1")
  endif
  select ONKPR
  find (str(human->kod,7))
  do while onkpr->kod == human->kod .and. !eof()
    if !between(onkpr->PROT,1,6)
      aadd(ta,"Некорректно записано противопоказание к проведению (отказ от проведения)")
    elseif onkpr->D_PROT > d2
      n1->(dbGoto(onkpr->PROT))
      aadd(ta,alltrim(lower(n1->prot_name))+" - дата регистрации больше даты окончания лечения")
    endif
    select ONKPR
    skip
  enddo
  //
  fl := .t.
  fl_lek_ter := .f.
  select ONKUS
  find (str(human->kod,7))
  do while onkus->kod == human->kod .and. !eof()
    i := j := k := k1 := 0
    do case // Тип онкоуслуги в соответствии со справочником N013
      case between(onkus->USL_TIP,1,3)
        k := onkus->USL_TIP
      case onkus->USL_TIP == 4
        s := iif(M1VZROS_REB == 0, "A25.30.033", "A25.30.014")
        if !(left(human_2->pc3,2) == "sh") .and. (j := ascan(au_flu, {|x| x[10] == 2 })) == 0
          aadd(ta,'для химиолучевой терапии обязательна к заполнению услуга назначения лекарственных препаратов '+s)
        elseif j > 0 .and. !(alltrim(au_flu[j,1]) == s)
          aadd(ta,'для химиолучевой терапии обязательна к заполнению услуга назначения лекарственных препаратов '+s)
        endif
        k := 3 // в 2019 году поставить "4"
      case onkus->USL_TIP == 5
        k := 5 ; k1 := 9  // в 2019 году поставить как-то по-другому
    endcase
    if k > 0
      i := ascan(au_flu, {|x| x[10] == k })
    endif
    if i == 0 .and. k1 > 0
      k := k1
      i := ascan(au_flu, {|x| x[10] == k })
    endif
    if i > 0
      select MOHU
      goto (au_flu[i,9])
      G_RLock(forever)
      mohu->USL_TIP := iif(eq_any(onkus->USL_TIP,4,5), k, onkus->USL_TIP)
      mohu->HIR_TIP := onkus->HIR_TIP
      mohu->LEK_TIP_L := onkus->LEK_TIP_L
      mohu->LEK_TIP_V := onkus->LEK_TIP_V
      mohu->LUCH_TIP := onkus->LUCH_TIP
      mohu->PZKOL := onkus->SOD
      if onkus->USL_TIP == 1
        if empty(onkus->HIR_TIP)
          aadd(ta,'не заполнен тип хирургического лечения')
        endif
      elseif onkus->USL_TIP == 2
        if empty(onkus->LEK_TIP_V)
          aadd(ta,'не заполнен цикл лекарственной терапии')
        endif
        if empty(onkus->LEK_TIP_L)
          aadd(ta,'не заполнена линия лекарственной терапии')
        endif
      elseif between(onkus->USL_TIP,3,4)
        if empty(onkus->LUCH_TIP)
          aadd(ta,'не заполнен тип '+iif(onkus->USL_TIP==3,'','химио')+'лучевой терапии')
        endif
        if empty(onkus->SOD)
          aadd(ta,'для '+iif(onkus->USL_TIP==3,'','химио')+'лучевой терапии не заполнена суммарная очаговая доза (СОД)')
        endif
      endif
      v += onkus->SOD
      au_flu[i,11] := .t.
    elseif onkus->USL_TIP == 2 .and. human_2->VMP == 0 // если ВМП, пусть добавляют сами
      fl_lek_ter := .t.
    elseif between(onkus->USL_TIP,1,5) .and. !eq_any(shifr_ksg,"1138.0","2051.0")
      s := {"Хирургическое лечение",;
            "Лекарственная противоопухолевая терапия",;
            "Лучевая терапия",;
            "Химиолучевая терапия",;
            "Другое"}[onkus->USL_TIP]
      aadd(ta,'для онколечения "'+lower(s)+'" не введена услуга')
      fl := .f.
    endif
    select ONKUS
    skip
  enddo
  if fl_lek_ter
    k := ret_kod_usl_lek_ter(M1VZROS_REB)
    select MOHU
    Add1Rec(7)
    mohu->kod     := human->kod
    mohu->kod_vr  := human_->VRACH
    mohu->kod_as  := 0
    mohu->u_kod   := k
    mohu->u_cena  := 0
    mohu->date_u  := cd1
    mohu->otd     := human->OTD
    mohu->kol_1   := 1
    mohu->stoim_1 := 0
    mohu->ID_U    := mo_guid(4,mohu->(recno()))
    mohu->PROFIL  := human_->PROFIL
    mohu->PRVS    := human_->PRVS
    mohu->kod_diag:= mdiagnoz[1]
    mohu->zf      := ""
    fl := .f.
  endif
  for i := 1 to len(au_flu)
    if au_flu[i,11]
      fl := .f.
    else // очистим те услуги, в которых ничего не прописали
      select MOHU
      goto (au_flu[i,9])
      if mohu->USL_TIP > 0
        G_RLock(forever)
        mohu->USL_TIP := 0
        mohu->HIR_TIP := 0
        mohu->LEK_TIP_L := 0
        mohu->LEK_TIP_V := 0
        mohu->LUCH_TIP := 0
        mohu->PZKOL := 0
      endif
    endif
  next i
  if !(onksl->SOD == v)
    select ONKSL
    if fl_lock_onksl
      G_RLock(forever)
    endif
    onksl->SOD := v // суммарная очаговая доза
  endif
  if human_->USL_OK < 3 .and. fl .and. !eq_any(shifr_ksg,"1138.0","2051.0")
    aadd(ta,'не введено проведённое онкологическое лечение')
  endif
endif
mpztip := mpzkol := 0
if !(round(human->cena_1,2) == round(ssumma,2))
  aadd(ta,'Сумма случая '+lstr(human->cena_1)+' не равна сумме услуг '+lstr(ssumma))
  aadd(ta,'Выполните ПЕРЕИНДЕКСИРОВАНИЕ и отредактируйте услуги в листе учёта')
endif
if empty(au_lu)
  if empty(au_flu)
    aadd(ta,'Не введено ни одной услуги')
  else
    aadd(ta,'Не введена основная услуга, но введена манипуляция Минздрава РФ')
  endif
endif
if empty(human_->profil)
  human_->profil := mprofil  // сначала профиль из первой услуги
endif
if empty(human_->profil)
  otd->(dbGoto(human->OTD))
  human_->profil := otd->profil  // если нет, то из отделения
endif
if !empty(human_->profil) .and. human_->profil != correct_profil(human_->profil)
  human_->profil := correct_profil(human_->profil)
endif
if len(mdiagnoz) > 0 .and. left(mdiagnoz[1],3) == "O04" .and. eq_any(human_->profil,136,137) // акушерству и гинекологии
  if !between(human_2->pn2,1,2)
    aadd(ta,"для диагноза "+alltrim(mdiagnoz[1])+" обязательно заполнять, искусственное прерывание беременности проводилось по медицинским показаниям или нет")
  elseif human_2->pn2 == 1 .and. (len(mdiagnoz) < 2 .or. empty(mdiagnoz[2]))
    aadd(ta,"для диагноза "+alltrim(mdiagnoz[1])+" (искусственное прерывание беременности по медицинским показаниям) не указан сопутствующий диагноз")
  endif
endif
if empty(human_->VRACH) .and. !(ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34))
  human_->VRACH := mvrach // врача из первой услуги
endif
if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
  mpzkol := len(au_lu)
endif
if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
  human->UCH_DOC := lstr(human_2->PN3) // ORDER по ЛИС перезаписываем (вдруг исправили)
  human_->VRACH := 0
  human_->PRVS := iif(human_->profil == 34, -13, -54)
elseif empty(human_->VRACH)
  aadd(ta,'не заполнено поле "Лечащий врач"')
else
  pers->(dbGoto(human_->VRACH))
  mprvs := -ret_new_spec(pers->prvs,pers->prvs_new)
  if empty(mprvs)
    aadd(ta,'нет специальности в справочнике персонала у "'+alltrim(pers->fio)+'"')
  elseif human_->PRVS != mprvs
    human_->PRVS := mprvs
  endif
  if human_->PRVS > 0 .and. ret_V004_V015(human_->PRVS) == 0
    aadd(ta,'не найдено специальности в справочнике V015 у "'+alltrim(pers->fio)+'"')
  endif
  if ascan(arr_perso,human_->VRACH) == 0
    aadd(arr_perso,human_->VRACH)
  endif
endif
for i := 1 to len(arr_perso)
  pers->(dbGoto(arr_perso[i]))
  mvrach := fam_i_o(pers->fio)+" ["+lstr(pers->tab_nom)+"]"
  if empty(pers->snils)
    aadd(ta,"не введен СНИЛС у врача - "+mvrach)
  else
    s := space(80)
    if !val_snils(pers->snils,2,@s)
      aadd(ta,s+" у врача - "+mvrach)
    endif
  endif
next
if empty(human_->USL_OK)
  human_->USL_OK := musl_ok
elseif mUSL_OK > 0 .and. human_->USL_OK != mUSL_OK
  aadd(ta,'в поле "Условия оказания" должно быть "'+inieditspr(A__MENUVERT,glob_V006,mUSL_OK)+'"')
endif
if human_->USL_OK == 3 // для поликлиники
  s := space(80)
  if !vr_pr_1_den(2,@s,u_other)
    aadd(ta,s)
  endif
endif
if human_->USL_OK == 1 .and. substr(human_->FORMA14,1,1)=='0' .and. !is_s_dializ
  if empty(human_->NPR_MO)
    aadd(ta,'при ПЛАНОВОЙ госпитализации должно быть заполнено поле "Направившая МО"')
  elseif empty(human_2->NPR_DATE)
    if glob_mo[_MO_KOD_TFOMS] == ret_mo(human_->NPR_MO)[_MO_KOD_TFOMS]
      human_2->NPR_DATE := d1
    else
      aadd(ta,'должно быть заполнено поле "Дата направления на госпитализацию"')
    endif
  elseif human_2->NPR_DATE > d1
    aadd(ta,'"Дата направления на госпитализацию" больше "Даты начала лечения"')
  elseif human_2->NPR_DATE+60 < d1
    aadd(ta,'Направлению на госпитализацию больше двух месяцев')
  endif
endif
if eq_any(human_->USL_OK,1,2)
  i := human_2->p_per
  if !between(human_2->p_per,1,4) // если не вводили
    i := iif(substr(human_->FORMA14,2,1) == '1', 2, 1)
  elseif substr(human_->FORMA14,2,1) == '1' // если скорая помощь
    i := 2
  elseif !(substr(human_->FORMA14,2,1) == '1') // если не скорая помощь
    if i == 2 // если скорая помощь
      i := 1
    endif
  endif
  if i != human_2->p_per
    human_2->p_per := i
  endif
endif
if kkt == 0 .and. eq_any(human_->USL_OK,1,2) .and. len(a_srok_lech) > 0
  for i := 1 to len(a_srok_lech)
    otd->(dbGoto(a_srok_lech[i,4]))
    if a_srok_lech[i,5] == 0
      otd->(dbGoto(a_srok_lech[i,4]))
      aadd(ta,'пересечение '+date_8(a_srok_lech[i,1])+"-"+date_8(a_srok_lech[i,2])+;
              iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]"))
    endif
  next
endif
if fl_stom
  mpzkol := 1
  if f_vid_p_stom(au_lu,ta,,,d2,@ltip,@lkol,@is_2_88,au_flu)
    do case
      case ltip == 1 // с лечебной целью
        mpztip := 65
        if lkol < 2
          aadd(ta,'при обращении по поводу заболевания должно быть не менее ДВУХ посещений к врачу-стоматологу')
        elseif ascan(au_lu, {|x| alltrim(x[1]) == "2.78.55" }) > 0 .and. ;
               eq_any(left(human->KOD_DIAG,3),"K05","K06") .and. lkol < 5
          aadd(ta,'при обращении по поводу заболевания пародонта должно быть не менее ПЯТИ посещений к врачу-стоматологу')
        elseif human->KOD_DIAG == "Z01.2"
          aadd(ta,'основной диагноз Z01.2 применяется при посещении с профилактической целью в стоматологии, а в случае - по поводу заболевания')
        endif
      case ltip == 2 // с профилактической целью или разовое по поводу заболевания
        mpztip := 63
        if lkol != 1
          aadd(ta,'при посещении с профилактической целью должно быть ОДНО посещение к врачу-стоматологу')
        elseif is_2_88 .and. human->KOD_DIAG == "Z01.2"
          aadd(ta,'при разовом посещении по поводу заболевания в стоматологии основной диагноз не должен быть Z01.2')
        elseif !is_2_88 .and. !(human->KOD_DIAG == "Z01.2")
          aadd(ta,'при посещении с профилактической целью в стоматологии основной диагноз всегда Z01.2')
        endif
        if !is_2_88
          human_->RSLT_NEW := 314
          human_->ISHOD_NEW := 304
        endif
      case ltip == 3 // при оказании неотложной помощи
        mpztip := 64
        if lkol != 1
          aadd(ta,'при неотложном посещении должно быть ОДНО посещение к врачу-стоматологу')
        elseif human->KOD_DIAG == "Z01.2"
          aadd(ta,'основной диагноз Z01.2 применяется при посещении с профилактической целью в стоматологии, а в случае - неотложное')
        endif
    endcase
    if ltip > 1 .and. d1 != d2
      aadd(ta,iif(ltip==2,'при посещении с профилактической целью','при неотложном посещении')+' дата окончания должна равняться дате начала лечения')
    endif
  endif
endif
if human_->USL_OK == 1  // стационар
  if kol_ksg > 1
    aadd(ta,'введено более одной КСГ')
  endif
  mpztip := 52 // 52,"Случай госпитализации","случ.госп."},;
  mpzkol := kkd_1_11
  if (i := d2 - d1) == 0
    i := 1
  endif
  if kkd_1_11 != i
    if !is_s_dializ
      aadd(ta,'количество койко-дней 1.11.* должно равняться '+lstr(i))
    endif
  elseif is_reabil // реабилитация
    mpztip := 53 // 53,"случай госпитализации при реабилитации","госп.реаб."},;
    if human_2->VMP == 1 // если установили ВМП
      aadd(ta,'при реабилитации не может быть оказана ВМП')
    endif
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "1.11."
        if !(alltrim(au_lu[i,1]) == "1.11.2")
          aadd(ta,'неверная услуга '+au_lu[i,1])
        endif
        aadd(a_1_11,{au_lu[i,2],;
                     au_lu[i,7],;
                     au_lu[i,3],;
                     au_lu[i,4],;
                     au_lu[i,6]})
      endif
    next
    if len(a_1_11) == 1
      if a_1_11[1,1] != d1
        aadd(ta,'дата начала услуги 1.11.2 должна равняться дате начала лечения')
      endif
      if a_1_11[1,2] != d2
        aadd(ta,'дата окончания услуги 1.11.2 должна равняться дате окончания лечения')
      endif
    else
      aadd(ta,'услуга 1.11.2 должна встречаться один раз')
    endif
  else // остальные койко-дни
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "1.11."
        if !(alltrim(au_lu[i,1]) == "1.11.1")
          aadd(ta,'неверная услуга '+au_lu[i,1])
        endif
        aadd(a_1_11,{au_lu[i,2],;
                     au_lu[i,7],;
                     au_lu[i,3],;
                     au_lu[i,4],;
                     au_lu[i,6]})
      endif
    next
    if len(a_1_11) > 0
      asort(a_1_11,,,{|x,y| x[1] < y[1] })
      if a_1_11[1,1] != d1
        aadd(ta,'дата начала первой услуги 1.11.1 должна равняться дате начала лечения')
      endif
      for i := 2 to len(a_1_11)
        if a_1_11[i-1,2] != a_1_11[i,1]
          aadd(ta,'дата начала '+lstr(i)+'-й услуги 1.11.1 должна равняться '+date_8(a_1_11[i-1,2]))
        endif
      next
      if atail(a_1_11)[2] != d2
        aadd(ta,'дата окончания последней услуги 1.11.1 должна равняться дате окончания лечения')
      endif
    endif
  endif
  if empty(human_->profil)
    aadd(ta,'в случае не проставлен профиль')
  elseif empty(human_->PRVS)
    aadd(ta,'у лечащего врача в случае не проставлена специальность')
  elseif is_reabil // реабилитация
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "1.11."
        aadd(a_1_11,{alltrim(au_lu[i,8]),;
                     au_lu[i,3],;
                     au_lu[i,4]})
      endif
    next
    fl := .f.
    for i := 1 to len(a_1_11)
      if len(mdiagnoz) > 0 .and. alltrim(mdiagnoz[1]) == a_1_11[i,1] .and. human_->PRVS == a_1_11[i,3]
        fl := .t. ; exit
      endif
    next
    if !fl
      aadd(ta,'в услуге 1.11.2 должны повториться диагноз+врач из случая')
    endif
  else // остальные койко-дни
    if human_->profil == 158
      aadd(ta,'в случае нельзя использовать профиль по: '+inieditspr(A__MENUVERT, glob_V002, 158))
    endif
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "1.11."
        aadd(a_1_11,{alltrim(au_lu[i,8]),;
                     au_lu[i,3],;
                     au_lu[i,4]})
      endif
    next
    for i := 1 to len(au_flu)
      aadd(a_1_11,{alltrim(au_flu[i,8]),;
                   au_flu[i,3],;
                   au_flu[i,4]})
    next
    fl := .f.
    for i := 1 to len(a_1_11)
      if len(mdiagnoz) > 0 .and. alltrim(mdiagnoz[1]) == a_1_11[i,1] .and. ;
              human_->profil == a_1_11[i,2] .and. human_->PRVS == a_1_11[i,3]
        if a_1_11[i,2] == 158
          aadd(ta,'в услуге нельзя использовать профиль по: '+inieditspr(A__MENUVERT, glob_V002, 158))
        endif
        fl := .t. ; exit
      endif
    next
    if !fl .and. !is_s_dializ
      aadd(ta,'в одной из услуг должны повториться диагноз+профиль+врач из случая')
    endif
  endif
  if human_2->VMP == 1 // проверим ВМП
    if is_12_VMP  // ВМП по-новому
      make_V018_V019(d2)
      if empty(human_2->TAL_NUM)
        aadd(ta,'ВМП оказана, но не введен номер талона на ВМП')
      endif
      if empty(human_2->TAL_D)
        aadd(ta,'ВМП оказана, но не введена дата выдачи талона на ВМП')
      elseif !eq_any(year(human_2->TAL_D),d2_year-1,d2_year,d2_year+1)
        aadd(ta,'дата выдачи талона на ВМП ('+date_8(human_2->TAL_D)+') должна быть в текущем или прошлом году')
      endif
      if empty(human_2->TAL_P)
        aadd(ta,'ВМП оказана, но не введена дата планируемой госпитализации в соответствии с талоном на ВМП')
      elseif !eq_any(year(human_2->TAL_P),d2_year-1,d2_year,d2_year+1)
        aadd(ta,'дата планируемой госпитализации в соответствии с талоном на ВМП ('+date_8(human_2->TAL_P)+') должна быть в текущем или прошлом году')
      endif
      if empty(human_2->VIDVMP)
        aadd(ta,'ВМП оказана, но не введён вид ВМП')
      elseif ascan(glob_V018, {|x| x[1] == alltrim(human_2->VIDVMP) }) == 0
        aadd(ta,'Не найден вид ВМП "'+human_2->VIDVMP+'" в справочнике V018')
      elseif empty(human_2->METVMP)
        aadd(ta,'ВМП оказана, введён вид ВМП, но не введён метод ВМП')
      elseif (i := ascan(glob_V019, {|x| x[1] == human_2->METVMP })) > 0
        if glob_V019[i,4] == alltrim(human_2->VIDVMP)
          if !(len(mdiagnoz) == 0 .or. empty(mdiagnoz[1]))
            fl := .f. ; s := padr(mdiagnoz[1],6)
            for j := 1 to len(glob_V019[i,3])
              if left(s,len(glob_V019[i,3,j])) == glob_V019[i,3,j]
                fl := .t. ; exit
              endif
            next
            if fl
              if empty(mpztip := ret_PZ_VMP(human_2->METVMP))
                mpztip := 1
              endif
            else
              aadd(ta,'основной диагноз '+s+', а у метода ВМП "'+lstr(human_2->METVMP)+'.'+alltrim(glob_V019[i,2])+'"')
              aadd(ta,'└─допустимые диагнозы: '+print_array(glob_V019[i,3]))
            endif
          endif
        else
          aadd(ta,'метод ВМП '+lstr(human_2->METVMP)+' не соответствует виду ВМП '+human_2->VIDVMP)
        endif
      else
        aadd(ta,'Не найден метод ВМП '+lstr(human_2->METVMP)+' в справочнике V019')
      endif
    else
      human_2->VMP     := 0
      human_2->VIDVMP  := ""
      human_2->METVMP  := 0
      human_2->TAL_NUM := ""
      human_2->TAL_D   := ctod("")
      human_2->TAL_P   := ctod("")
    endif
  endif
  if is_alldializ .and. len(a_period_stac) > 0
    fl := .f.
    for i := 1 to len(a_period_stac)
      otd->(dbGoto(a_period_stac[i,4]))
      if is_s_dializ // это диализ
        if a_period_stac[i,9] == 0 // проверяем случай основного лечения
          if human->n_data == a_period_stac[i,1] .and. human->k_data == a_period_stac[i,2]
            fl := .t.
            if !(human->kod_diag   == a_period_stac[i,5] .and.;
                 human_->profil    == a_period_stac[i,6] .and.;
                 human_->RSLT_NEW  == a_period_stac[i,7] .and.;
                 human_->ISHOD_NEW == a_period_stac[i,8])
              aadd(ta,'в стационарном случае основного лечения (с КСГ) '+;
                   date_8(a_period_stac[i,1])+"-"+date_8(a_period_stac[i,2])+;
                   iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]")+;
                   ' должны повторяться основной диагноз, профиль, результат и исход лечения из данного случая')
            endif
          endif
        endif
      else // это лечение
        if a_period_stac[i,9] == 1 // ищем диализ в стационаре
          if human->n_data == a_period_stac[i,1] .and. human->k_data == a_period_stac[i,2]
            fl := .t.
            if !(human->kod_diag   == a_period_stac[i,5] .and.;
                 human_->profil    == a_period_stac[i,6] .and.;
                 human_->RSLT_NEW  == a_period_stac[i,7] .and.;
                 human_->ISHOD_NEW == a_period_stac[i,8])
              aadd(ta,'в стационарном случае диализа '+;
                   date_8(a_period_stac[i,1])+"-"+date_8(a_period_stac[i,2])+;
                   iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]")+;
                   ' должны повторяться основной диагноз, профиль, результат и исход лечения из данного случая')
            endif
            exit
          endif
        endif
      endif
    next
    if !fl .and. is_s_dializ
      aadd(ta,'совместно со случаем стационарного диализа должен быть введён стационарный случай основного лечения (с КСГ)')
    endif
  endif
  // добавим период, если лечился в стационаре
  aadd(a_period_stac,{human->n_data,;
                      human->k_data,;
                      human_->USL_OK,;
                      human->OTD,;
                      human->kod_diag,;
                      human_->profil,;
                      human_->RSLT_NEW,;
                      human_->ISHOD_NEW,;
                      iif(is_s_dializ, 1, 0)})
elseif human_->USL_OK == 2 .and. !is_dializ // дневной стационар
  if kol_ksg > 1
    aadd(ta,'введено более одной КСГ')
  endif
  mpztip := 55 // 55,"случай лечения","случ.лечен"},;
  mpzkol := kol_55_1
  if empty(kol_55_1)
    aadd(ta,'не введена услуга пациенто-день 55.1.*')
  elseif is_reabil // реабилитация
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "55.1."
        if !(alltrim(au_lu[i,1]) == "55.1.4")
          aadd(ta,'неверная услуга '+rtrim(au_lu[i,1])+", должна быть 55.1.4")
        endif
        select HU
        goto (au_lu[i,9])
        select HU_
        UnLock
        aadd(a_1_11,{au_lu[i,2],;  // 1-mdate
                     au_lu[i,7],;  // 2-c4tod(mdate_u2)
                     au_lu[i,3],;  // 3-hu_->profil
                     au_lu[i,4],;  // 4-hu_->PRVS
                     au_lu[i,6],;  // 5-hu->kol_1
                     au_lu[i,9]})  // 6-номер записи
      endif
    next
    if len(a_1_11) == 1
      if a_1_11[1,1] != d1
        aadd(ta,'дата начала услуги 55.1.4 должна равняться дате начала лечения')
      endif
      if a_1_11[1,2] != d2
        select HU
        goto (a_1_11[1,6])
        hu_->(G_RLock(forever))
        hu_->date_u2 := cd2
        //aadd(ta,'дата окончания услуги 55.1.4 должна равняться дате окончания лечения')
      endif
    else
      aadd(ta,'услуга 55.1.4 должна встречаться один раз')
    endif
  else // остальные койко-дни
    a_1_11 := {}
    s := ""
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "55.1."
        if empty(s) ; s := au_lu[i,1] ; endif
        if !(au_lu[i,1] == s) // не смешивать разные 55.1.*
          aadd(ta,'неверная услуга '+au_lu[i,1])
        elseif !eq_any(alltrim(au_lu[i,1]),"55.1.1","55.1.2","55.1.3")
          aadd(ta,'неверная услуга '+rtrim(au_lu[i,1]))
        endif
        select HU
        goto (au_lu[i,9])
        select HU_
        UnLock
        aadd(a_1_11,{au_lu[i,2],;   // 1-mdate
                     au_lu[i,7],;   // 2-c4tod(mdate_u2)
                     au_lu[i,3],;   // 3-hu_->profil
                     au_lu[i,4],;   // 4-hu_->PRVS
                     au_lu[i,6],;   // 5-hu->kol_1
                     au_lu[i,9]})   // 6-номер записи
      endif
    next
    if (k := len(a_1_11)) > 0
      asort(a_1_11,,,{|x,y| x[1] < y[1] })
      if a_1_11[1,1] != d1
        aadd(ta,'дата начала первой услуги 55.1.* должна равняться дате начала лечения')
      endif
      for i := 2 to k
        // 1-дата окончания пред.услуги = дата начала след.услуги минус 1
        a_1_11[i-1,2] := a_1_11[i,1] - 1
        // 2-дата окончания пред.услуги = дата начала пред.услуги + дни - 1
        d := a_1_11[i-1,1] + a_1_11[i-1,5] - 1
        if d > a_1_11[i-1,2]
          aadd(ta,'дата начала '+lstr(i)+'-й услуги 55.1.* должна равняться '+date_8(d+1))
        endif
      next
      if empty(ta) // нет ошибок
        for i := 1 to k
          select HU
          goto (a_1_11[i,6])
          hu_->(G_RLock(forever))
          if i == k
            a_1_11[i,2] := d2   // для последней услуги
            hu_->date_u2 := cd2 // поставим дату окончания лечения
            d := a_1_11[i,1] + a_1_11[i,5] - 1
            if d > d2
              aadd(ta,'дата окончания последней услуги 55.1.* больше даты окончания лечения '+date_8(d))
            endif
          else
            hu_->date_u2 := dtoc4(a_1_11[i,2]) // перепишем дату окончания
          endif
        next
      endif
    endif
  endif
  if empty(human_->profil)
    aadd(ta,'в случае не проставлен профиль')
  elseif empty(human_->PRVS)
    aadd(ta,'у лечащего врача в случае не проставлена специальность')
  elseif is_reabil // реабилитация
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "55.1."
        aadd(a_1_11,{alltrim(au_lu[i,8]),;
                     au_lu[i,3],;
                     au_lu[i,4]})
      endif
    next
    fl := .f.
    for i := 1 to len(a_1_11)
      if len(mdiagnoz) > 0 .and. alltrim(mdiagnoz[1]) == a_1_11[i,1] .and. human_->PRVS == a_1_11[i,3]
        fl := .t. ; exit
      endif
    next
    if !fl
      aadd(ta,'в услуге 55.1.4 должны повториться диагноз+врач из случая')
    endif
  else // остальные койко-дни
    a_1_11 := {}
    for i := 1 to len(au_lu)
      if left(au_lu[i,1],5) == "55.1."
        aadd(a_1_11,{alltrim(au_lu[i,8]),;
                     au_lu[i,3],;
                     au_lu[i,4]})
      endif
    next
    for i := 1 to len(au_flu)
      aadd(a_1_11,{alltrim(au_flu[i,8]),;
                   au_flu[i,3],;
                   au_flu[i,4]})
    next
    fl := .f.
    for i := 1 to len(a_1_11)
      if len(mdiagnoz) > 0 .and. alltrim(mdiagnoz[1]) == a_1_11[i,1] .and. ;
              human_->profil == a_1_11[i,2] .and. human_->PRVS == a_1_11[i,3]
        fl := .t. ; exit
      endif
    next
    if !fl
      aadd(ta,'в одной из услуг 55.1.* должны повториться диагноз+профиль+врач из случая')
    endif
  endif
  if !empty(lvidpoms)
    if ascan(au_lu,{|x| alltrim(x[1]) == "55.1.2"}) > 0 .or. ;
       ascan(au_lu,{|x| alltrim(x[1]) == "55.1.3"}) > 0
       //
    else // только для дн.стационара при стационаре смотрим лицензию
      lvidpoms := ret_vidpom_licensia(human_->USL_OK,lvidpoms)
    endif
    if "," $ lvidpoms
      if ascan(au_lu,{|x| alltrim(x[1]) == "55.1.1"}) > 0 .or. ;
         ascan(au_lu,{|x| alltrim(x[1]) == "55.1.4"}) > 0 .or. ;
         ascan(au_lu,{|x| alltrim(x[1]) == "55.1.6"}) > 0
        if !("31" $ lvidpoms)
          aadd(ta,'для КСГ='+shifr_ksg+' в справочнике Т006 не введён вид помощи 31')
        endif
      else
        if eq_any(human_->PROFIL,57,68,97) //терапия,педиатр,врач общ.практики
          if !("12" $ lvidpoms)
            aadd(ta,'для КСГ='+shifr_ksg+' в справочнике Т006 не введён вид помощи 12; '+;
                    'вероятно, в случае не может стоять профиль "терапевт", "педиатр", "врач общ.практики"')
          endif
        else
          if !("13" $ lvidpoms)
            aadd(ta,'для КСГ='+shifr_ksg+' в справочнике Т006 не введён вид помощи 13; '+;
                    'проставьте в случае профиль "терапевт", "педиатр", "врач общ.практики" '+;
                    'или звоните в ТФОМС об ошибке в справочнике')
          endif
        endif
      endif
    endif
  endif
endif
if len(a_period_stac) > 0 .and. !is_s_dializ .and. !is_dializ .and. !is_perito
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    aadd(u_other, {hu->u_kod,hu->date_u,hu->kol_1,hu_->profil,0,human->n_data,human->k_data,human->OTD})
    select HU
    skip
  enddo
  select HU
  set relation to
  for i := 1 to len(u_other)
    if u_other[i,5] == 0
      usl->(dbGoto(u_other[i,1]))
      lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
      if is_usluga_TFOMS(usl->shifr,lshifr1,u_other[i,7])
        mdate := c4tod(u_other[i,2])
        if (k := ascan(a_period_stac, {|x| x[1] < mdate .and. mdate < x[2]})) > 0
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          if (left(lshifr,2)=="2." .or. eq_any(left(lshifr,3),"60.","70.","71.","72.")) ;
                          .and. !(left(lshifr,5)=="60.3.") .and. is_2_stomat(lshifr,,.t.) == 0 // не стоматология
            otd->(dbGoto(u_other[i,8]))
            aadd(ta,'услуга '+alltrim(usl->shifr)+' от '+date_8(mdate)+' в случае '+;
                 date_8(u_other[i,6])+"-"+date_8(u_other[i,7])+;
                 iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]"))
            otd->(dbGoto(a_period_stac[k,4]))
            aadd(ta,'└>пересекается со случаем стац.лечения '+;
                 date_8(a_period_stac[k,1])+"-"+date_8(a_period_stac[k,2])+;
                 iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]"))
          endif
        endif
      endif
    endif
  next
  select HU
  set relation to recno() into HU_, to u_kod into USL
endif
if eq_any(human_->USL_OK,1,2) .and. !is_s_dializ .and. !is_dializ .and. human_2->VMP == 0 // не ВМП
  arr_ksg := definition_KSG_18()
  if empty(arr_ksg[2]) // нет ошибок
    if shifr_ksg == arr_ksg[3] // КСГ определена правильно
      if !(round(cena_ksg,2) == round(arr_ksg[4],2)) // не та цена
        aadd(ta,"в л/у для КСГ="+arr_ksg[3]+" стоит цена "+lstr(cena_ksg,10,2)+", а должна быть "+lstr(arr_ksg[4],10,2))
      else
        put_str_kslp_kiro(arr_ksg)
      endif
    else // не тот шифр КСГ
      aadd(ta,"в л/у стоит КСГ="+alltrim(shifr_ksg)+"("+lstr(cena_ksg,10,2)+"), а должна быть "+arr_ksg[3]+"("+lstr(arr_ksg[4],10,2)+")")
    endif
  else
    aeval(arr_ksg[2],{|x| aadd(ta,x) })
  endif
endif
// проверим период, если лечился амбулаторно
if human_->USL_OK == 3 .and. human->ishod < 101 ;// не диспансеризация
                        .and. m1novor == human_->NOVOR ;
                         .and. !(is_2_80 .or. is_2_82) ;// не неотложная помощь
                          .and. !(ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)) ; // не КДП2
                           .and. len(a_period_amb) > 0
  for i := 1 to len(a_period_amb)
    if a_period_amb[i,3] == human_->profil
      aadd(ta,'данный случай пересекается со случаем амбулаторного лечения')
      otd->(dbGoto(a_period_amb[i,4]))
      aadd(ta,'└>с тем же профилем '+;
              date_8(a_period_amb[i,1])+"-"+date_8(a_period_amb[i,2])+;
              iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]"))
      //aadd(ta,'└>данный л/у - запись № '+lstr(human->(recno()))+', прошлый л/у - запись № '+lstr(a_period_amb[i,5]))
    endif
  next
endif
if mRSLT_NEW > 0
  human_->RSLT_NEW := mRSLT_NEW // записать доп.диспансеризацию
endif
//
if is_2_78
  mIDSP := 17 // Законченный случай в поликлинике
  if kvp_2_78 > 1
    aadd(ta,'в случае применены '+lstr(kvp_2_78)+' услуги "2.78.*" (должна быть одна)')
  endif
endif
if is_disp_DDS // is_70_5 .or. is_70_6
  mIDSP := 11 // диспансеризация
  if kvp_70_5 > 1
    aadd(ta,'в случае применены '+lstr(kvp_70_5)+' услуги "70.5.*" (должна быть одна)')
  endif
  if kvp_70_6 > 1
    aadd(ta,'в случае применены '+lstr(kvp_70_6)+' услуги "70.6.*" (должна быть одна)')
  endif
endif
if is_disp_DVN // is_70_3
  mIDSP := 11 // диспансеризация
  if is_disp_DVN3 // профилактика
    mIDSP := 17 // Законченный случай в поликлинике
  endif
  if kvp_70_3 > 1
    aadd(ta,'в случае применены '+lstr(kvp_70_3)+' услуг "зак.сл." (должна быть одна)')
  endif
endif
if is_prof_PN // is_72_2
  if is_72_2
    a_idsp := {{30,"За законченный случай в поликлинике"}}
  else
    a_idsp := {{29,"За посещение в поликлинике"}}
  endif
  if kvp_72_2 > 1
    aadd(ta,'в случае применены '+lstr(kvp_72_2)+' услуги "72.2.*" (должна быть одна)')
  endif
endif
if (k := len(a_idsp)) == 0
  aadd(ta,'ни в одной из услуг в справочнике ТФОМС не установлен способ оплаты')
elseif k == 1
  midsp := human_->IDSP := a_idsp[1,1]
else
  aadd(ta,'смешивание способов оплаты: '+;
          lstr(a_idsp[1,1])+'-'+alltrim(a_idsp[1,2])+' и '+;
          lstr(a_idsp[2,1])+'-'+alltrim(a_idsp[2,2]))
endif
if (k := len(a_bukva)) == 0
  aadd(ta,'ни в одной из услуг в справочнике T002 не установлена буква счёта')
elseif k == 1
  //
else
  aadd(ta,'смешивание букв счёта: '+;
          a_bukva[1,1]+'-'+alltrim(a_bukva[1,2])+' и '+;
          a_bukva[2,1]+'-'+alltrim(a_bukva[2,2]))
endif
if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN
  //
elseif len(mdiagnoz) > 0 .and. ascan(adiag,mdiagnoz[1]) == 0
  aadd(ta, "основной диагноз "+rtrim(mdiagnoz[1])+" не встречается ни в одной услуге")
endif
//
if empty(human_->USL_OK)
  aadd(ta,'не заполнено поле "Условия оказания"')
endif
if empty(human_->PROFIL)
  aadd(ta,'не заполнено поле "Профиль"')
elseif eq_any(human_->USL_OK,1,2)
  if empty(human_2->profil_k)
    aadd(ta,'в случае не проставлен профиль койки')
  else
    if select("PRPRK") == 0
      R_Use(dir_exe+"_mo_prprk",cur_dir+"_mo_prprk","PRPRK")
      //index on str(profil,3)+str(profil_k,3) to (cur_dir+sbase)
    endif
    select PRPRK
    find (str(human_->profil,3)+str(human_2->profil_k,3))
    if found()
      if !empty(prprk->vozr)
        if human->vzros_reb == 0
          if prprk->vozr == "Д"
            aadd(ta,'возраст пациента не соответствует профилю койки')
          endif
        else
          if prprk->vozr == "Ж"
            aadd(ta,'возраст пациента не соответствует профилю койки')
          endif
        endif
      endif
      if !empty(prprk->pol) .and. !(human->pol == prprk->pol)
        aadd(ta,'значение поля "Пол" не соответствует профилю койки')
      endif
    else
      s := ""
      select PRPRK
      find (str(human_->profil,3))
      do while prprk->profil == human_->profil .and. !eof()
        s += '"'+inieditspr(A__MENUVERT, glob_V020, prprk->profil_k)+'" '
        skip
      enddo
      if empty(s)
        aadd(ta,'профиль медицинской помощи не оплачивается в ОМС')
      else
        aadd(ta,'профиль мед.помощи не соответствует профилю койки; допустимый профиль койки: '+s)
      endif
    endif
  endif
endif
if empty(human_->IDSP)
  aadd(ta,'не заполнено поле "Способ оплаты"')
endif
if empty(human_->RSLT_NEW)
  aadd(ta,'не заполнено поле "Результат обращения"')
elseif int(val(left(lstr(human_->RSLT_NEW),1))) != human_->USL_OK
  aadd(ta,'в поле "Результат обращения" стоит неверное значение')
endif
if empty(human_->ISHOD_NEW)
  aadd(ta,'не заполнено поле "Исход заболевания"')
elseif int(val(left(lstr(human_->ISHOD_NEW),1))) != human_->USL_OK
  aadd(ta,'в поле "Исход заболевания" стоит неверное значение')
endif
if is_2_82
  if human_->profil == 134
    aadd(ta,'в случае не должно быть профиля "Приёмного отделения"')
  endif
endif
if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN .or. is_pren_diagn .or. kol_ksg > 0 ;
                                                .or. is_2_89 .or. is_reabil //.or. is_s_dializ
  if is_reabil  // проводим проверку на профиль при реабилитации
    if human_->profil != 158
      aadd(ta,'в случае надо использовать профиль по: '+inieditspr(A__MENUVERT, glob_V002, 158))
    endif
    for i := 1 to len(au_lu)
      if au_lu[i,3] == 158 .and. alltrim(au_lu[i,1]) != shifr_ksg
        aadd(ta,'нельзя в услуге '+alltrim(au_lu[i,1])+'использовать профиль по: '+inieditspr(A__MENUVERT, glob_V002, au_lu[i,3]))
      endif
    next
    if is_reabil_slux
      t_arr := {"1331.0","1332.0","1333.0","1335.0","2127.0","2128.0","2130.0"}
      for i := 1 to len(t_arr)
        if t_arr[i] == shifr_ksg .and. !between(human_2->PN1,1,3)
          human_2->PN1 := 1
          //aadd(ta,'в случае реабилитации для КСГ='+shifr_ksg+' необходимо заполнить поле "вид мед.реабилитации"')
        endif
      next
    endif
  endif
else
  if human_->profil == 158
    aadd(ta,'в случае нельзя использовать профиль по: '+inieditspr(A__MENUVERT, glob_V002, 158))
  endif
  arr_profil := {human_->profil}
  for i := 1 to len(au_lu)
    if au_lu[i,10] >= 0 .and. ascan(arr_profil,au_lu[i,3]) == 0
      aadd(arr_profil,au_lu[i,3])
    endif
  next
  for i := 1 to len(au_flu)
    if ascan(arr_profil,au_flu[i,3]) == 0
      aadd(arr_profil,au_flu[i,3])
    endif
  next
  if len(arr_profil) > 1
    if human_->USL_OK == 4  // если скорая помощь
      human_->profil := au_lu[1,3]
    else
      aadd(ta,'в случае использован профиль по: '+inieditspr(A__MENUVERT, glob_V002, arr_profil[1]))
      for i := 2 to len(arr_profil)
        aadd(ta,'                  а в услуге по: '+inieditspr(A__MENUVERT, glob_V002, arr_profil[i]))
      next
    endif
  elseif empty(arr_profil[1])
    aadd(ta,'в случае не проставлен профиль')
  endif
  //
  if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
    // не проверять
  else
    arr_prvs := {human_->PRVS}
    for i := 1 to len(au_lu)
      if au_lu[i,10] >= 0 .and. ascan(arr_prvs,au_lu[i,4]) == 0
        aadd(arr_prvs,au_lu[i,4])
      endif
    next
    for i := 1 to len(au_flu)
      if ascan(arr_prvs,au_flu[i,4]) == 0
        aadd(arr_prvs,au_flu[i,4])
      endif
    next
    if len(arr_prvs) > 1
      aadd(ta,'в случае использованы разные специальности врачей')
    endif
  endif
endif
if lstkol > 0
  lstshifr += "*"
  if lstkol > 1
    aadd(ta,'кол-во услуг '+lstshifr+' ('+lstr(lstkol)+') более 1')
  endif
  if len(au_lu) > 1 .and. kol_ksg == 0
    if is_2_78 .or. is_2_89 .or. is_70_5 .or. is_70_6 .or. is_70_3 .or. is_72_2
      //
    else
      aadd(ta,'кроме услуги '+lstshifr+' в листе учета не должно быть других услуг ТФОМС')
    endif
  endif
endif
s := "2.60.*"
if is_2_78
  is_1_den := is_last_den := .f. ; zs := oth_usl := 0 ; am := {}
  for i := 1 to len(au_lu)
    if left(au_lu[i,1],5) == "2.78."
      ++zs
    elseif left(au_lu[i,1],4) == "2.60"
      if d1 == au_lu[i,2]
        is_1_den := .t.
      elseif d2 == au_lu[i,2]
        is_last_den := .t.
      endif
      if (j := ascan(am,{|x| x[1] == month(au_lu[i,2])} )) == 0
        aadd(am,{month(au_lu[i,2]),0}) ; j := len(am)
      endif
      am[j,2] ++
    elseif au_lu[i,10] >= 0
      ++oth_usl
    endif
  next
  j := len(am)
  if !is_last_den .and. j > 0
    asort(am,,,{|x,y| x[1] < y[1]})
    if kol_2_60 > 1 .and. month(d2) == am[j,1]
      aadd(ta,'последняя услуга '+s+' должна быть оказана в последний день лечения')
    endif
    if month(d2) - am[j,1] > 1 .and. year(d1) == year(d2)
      aadd(ta,'в предыдущем месяце не оказано врачебных приёмов')
    endif
  endif
  if zs > 1
    aadd(ta,'в листе учета более одной услуги "законченный случай"')
  endif
  if oth_usl > 0
    aadd(ta,'кроме услуги '+lstshifr+' и '+s+' в листе учета не должно быть других услуг')
  endif
  if kol_2_60 < 2
    aadd(ta,'кроме услуги '+lstshifr+' в листе учета должно быть 2 и более услуг '+s)
  endif
  if kol_2_60 > 0 .and. !is_1_den
    aadd(ta,'первая услуга '+s+' должна быть оказана в первый день лечения')
  endif
elseif is_2_89 // медицинская реабилитация (физкультурный диспансер)
  if d1 == d2
    aadd(ta,'время лечения не должно равняться одному дню')
  endif
  if empty(human_->NPR_MO)
    aadd(ta,'не заполнено "Направившая МО", в которой пациент имел прикрепление')
  else
    if empty(human_2->NPR_DATE)
      aadd(ta,'должно быть заполнено поле "Дата направления на лечение"')
    elseif human_2->NPR_DATE > d1
      aadd(ta,'"Дата направления на лечение" больше "Даты начала лечения"')
    elseif human_2->NPR_DATE+60 < d1
      aadd(ta,'Направлению на лечение больше двух месяцев')
    endif
    if !ret_mo(human_->NPR_MO)[_MO_IS_UCH]
      aadd(ta,'введена "Направившая МО", которая не имеет право прикреплять пациентов')
    endif
  endif
  aps := {} // сочетание профиля и специальности
  aadd(aps, {17, {113403}})  // детская кардиология
  aadd(aps, {29, {112205}})  // кардиология
  aadd(aps, {34, {1107,1301,1402,1702}})  // клинической лабораторной диагностике
  aadd(aps, {37, {2013}})  // лабораторному делу
  aadd(aps, {38, {2011}})  // лабораторной диагностике
  aadd(aps, {41, {110904,111003,111902,112216,112303,113404,2023,2024}})  // лечебной физкультуре и спортивной медицине
  aadd(aps, {42, {2002}})  // лечебному делу
  aadd(aps, {53, {1109}})  // неврологии
  aadd(aps, {57, {1110}})  // общей врачебной практике (семейной медицине)
  aadd(aps, {65, {1112}})  // офтальмологии
  aadd(aps, {68, {1134}})  // педиатрии
  aadd(aps, {78, {1118,1802,2020}})  // рентгенологии
  aadd(aps, {79, {110902,112219}})  // рефлексотерапии
  aadd(aps, {97, {1122}})  // терапии
  aadd(aps, {100,{1123}})  // травматологии и ортопедии
  aadd(aps, {109,{110102,110905,111005,111904,112220,1124,113417,140107,2022}})  // физиотерапии
  aadd(aps, {111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202}})  // функциональной диагностике
  /*aadd(au_lu,{lshifr,;              // 1
                mdate,;               // 2
                hu_->profil,;         // 3
                hu_->PRVS,;           // 4
                alltrim(usl->shifr),; // 5
                hu->kol_1,;           // 6
                c4tod(mdate_u2),;     // 7
                hu_->kod_diag})       // 8
  */
  human_->profil := 158  // медицинской реабилитации
  if a_2_89[1] == 1 .and. ret_old_prvs(human_->PRVS) != 1123
    aadd(ta,'специальность у лечащего врача должна быть Травматология и ортопедия')
  elseif a_2_89[2] == 1 .and. ret_old_prvs(human_->PRVS) != 1109
    aadd(ta,'специальность у лечащего врача должна быть Неврология')
  elseif a_2_89[3] == 1
    if human->vzros_reb == 0
      if !eq_any(ret_old_prvs(human_->PRVS),112205,1122)
        aadd(ta,'специальность у лечащего врача должна быть Кардиология (или Терапия)')
      endif
    else
      if !eq_any(ret_old_prvs(human_->PRVS),113403,1134)
        aadd(ta,'специальность у лечащего врача должна быть Детская кардиология (или Педиатрия)')
      endif
    endif
  endif
  is_1_den := is_last_den := .f. ; zs := km := oth_usl := 0 ; s := ""
  for i := 1 to len(au_lu)
    alltrim_lshifr := alltrim(au_lu[i,1])
    left_lshifr_2 := left(au_lu[i,1],2)
    left_lshifr_3 := left(au_lu[i,1],3)
    left_lshifr_4 := left(au_lu[i,1],4)
    left_lshifr_5 := left(au_lu[i,1],5)
    if !between(au_lu[i,2],d1,d2)
      aadd(ta,'дата услуги '+alltrim_lshifr+' вне диапазона лечения ('+date_8(au_lu[i,2])+')')
    endif
    if len(mdiagnoz) > 0 .and. !(alltrim(mdiagnoz[1])==alltrim(au_lu[i,8]))
      aadd(ta,'в услуге '+alltrim_lshifr+' должен стоять основной диагноз')
    endif
    if left_lshifr_5 == "2.89."
      zs += au_lu[i,6]
    elseif left_lshifr_4 == "2.6."
      if au_lu[i,6] != 1
        aadd(ta,'в услуге '+alltrim_lshifr+' количество не должно быть больше 1')
      endif
      if d1 == au_lu[i,2]
        is_1_den := .t.
      elseif d2 == au_lu[i,2]
        is_last_den := .t.
      endif
      if au_lu[i,6] != 1
        aadd(ta,'в услуге '+alltrim_lshifr+' количество не должно быть больше 1')
      endif
    elseif ascan(arr_lfk,alltrim_lshifr) > 0
      ++km
      if eq_any(alltrim_lshifr,"4.2.153","4.11.136","3.4.31") .and. au_lu[i,6] != 1
        aadd(ta,'в услуге '+alltrim_lshifr+' количество не должно быть больше 1')
      endif
      if au_lu[i,6] > 1 .and. au_lu[i,2] + au_lu[i,6] - 1 > d2
        aadd(ta,'дата окончания услуги '+alltrim_lshifr+' больше даты окончания лечения')
      endif
      fl_not_2_89 := .f.
      if left_lshifr_3 == "20." // ЛФК
        atmp := {"20.1.2","20.1.1","20.1.3"}
        for j := 1 to 3
          if alltrim_lshifr == atmp[j] .and. a_2_89[j] == 0
            fl_not_2_89 := .t.
          endif
        next
        if alltrim_lshifr == "20.2.1" .and. emptyall(a_2_89[1],a_2_89[2])
          fl_not_2_89 := .t.
        elseif alltrim_lshifr == "20.2.2" .and. a_2_89[3] == 0
          fl_not_2_89 := .t.
        endif
      elseif left_lshifr_3 == "21." // массаж
        atmp := {"21.1.2","21.1.1","21.1.3"}
        for j := 1 to 3
          if alltrim_lshifr == atmp[j] .and. a_2_89[j] == 0
            fl_not_2_89 := .t.
          endif
        next
      elseif left_lshifr_3 == "22." // рефлексотерапия
        atmp := {"22.1.2","22.1.1","22.1.3"}
        for j := 1 to 3
          if alltrim_lshifr == atmp[j] .and. a_2_89[j] == 0
            fl_not_2_89 := .t.
          endif
        next
      endif
      if fl_not_2_89
        aadd(ta,'услуга '+alltrim_lshifr+' не совпадает по наименованию с кодом законченного случая обращения')
      endif
    else
      s += alltrim_lshifr+" " ; ++oth_usl
    endif
    if (j := ascan(aps,{|x| x[1] == au_lu[i,3]})) > 0 .and. ascan(aps[j,2],ret_old_prvs(au_lu[i,4])) == 0
      aadd(ta,'в услуге '+alltrim_lshifr+' у врача стоит неверная специальность')
      aadd(ta,' у Вас: '+lstr(au_lu[i,4])+', разрешено: '+print_array(aps[j,2]))
    endif
  next
  if zs > 1
    aadd(ta,'в листе учета более одной услуги "законченный случай"')
  endif
  if oth_usl > 0
    aadd(ta,'в листе учета не должно быть данных услуг: '+s)
  endif
  if kol_2_6 < 2
    aadd(ta,'кроме услуги '+lstshifr+' в листе учета должно быть две и более услуг 2.6.*')
  endif
  if kol_2_6 > 0
    if !is_1_den
      aadd(ta,'первая услуга 2.6.* должна быть оказана в первый день лечения')
    endif
    if !is_last_den
      aadd(ta,'последняя услуга 2.6.* должна быть оказана в последний день лечения')
    endif
  endif
  if km == 0
    aadd(ta,'в листе учета нет ни одной услуги "манипуляция"')
  endif
elseif is_70_5 .or. is_70_6 .or. is_70_3 .or. is_72_2
  //
elseif kol_2_60 > 0
  aadd(ta,'вместе с услугами '+s+' должна быть услуга "законченный случай"')
endif
d := human->k_data - human->n_data
if kkd > 0
  if empty(d) .and. kkd == 1
    // по-новому один койко-день
  elseif kkd > d
    aadd(ta,'кол-во койко-дней ('+lstr(kkd)+') превышает срок лечения на '+lstr(kkd-d))
  elseif kkd < d
    aadd(ta,'кол-во койко-дней ('+lstr(kkd)+') меньше срока лечения на '+lstr(d-kkd))
  endif
elseif kds > 0
  if kds > (d+1)
    aadd(ta,'кол-во услуг дневного стационара ('+lstr(kds)+') превышает срок лечения на '+lstr(kds-(d+1)))
  endif
  if is_eko
    if human_->PROFIL != 137
      aadd(ta,'для КСГ='+shifr_ksg+' профиль должен быть по "акушерству и гинекологии (использованию вспомогательных репродуктивных технологий)"')
    endif
    a_1_11 := {}
    for i := 1 to len(au_flu)
      aadd(a_1_11,alltrim(au_flu[i,1]))
    next
    j := 1 // КСЛП - 1 схема
    if ascan(a_1_11,"A11.20.031") > 0  // крио
      j := 6  // 6 схема
      if ascan(a_1_11,"A11.20.028") > 0 // третий этап
        j := 2   // 2 схема
      endif
    elseif ascan(a_1_11,"A11.20.025.001") > 0  // первый этап
      j := 3  // 3 схема
      if ascan(a_1_11,"A11.20.036") > 0  // завершающий второй этап
        j := 4  // 4 схема
      elseif ascan(a_1_11,"A11.20.028") > 0  // завершающий третий этап
        j := 5  // 5 схема
      endif
    elseif ascan(a_1_11,"A11.20.030.001") > 0  // только четвертый этап
      j := 7  // 7 схема
    endif
    ashema := {;
      {"A11.20.017"},;
      {"A11.20.017","A11.20.028","A11.20.031"},;
      {"A11.20.017","A11.20.025.001"},;
      {"A11.20.017","A11.20.025.001","A11.20.036"},;
      {"A11.20.017","A11.20.025.001","A11.20.028"},;
      {"A11.20.017","A11.20.031"},;
      {"A11.20.017","A11.20.030.001"};
    }
    if (k := len(ashema[j])) == (n := len(a_1_11))
      //
    elseif k > n
      aadd(ta,'в листе учёта по ЭКО не хватает услуг '+print_array(a_1_11))
    elseif k < n
      for i := 1 to k
        if (n := ascan(a_1_11,ashema[j,i])) > 0
          Del_Array(a_1_11,n)
        endif
      next
      if len(a_1_11) > 0
        aadd(ta,'в листе учёта по ЭКО лишние услуги '+print_array(a_1_11))
      endif
    endif
  endif
elseif kkt > 0 .and. !is_s_dializ .and. !is_dializ .and. !is_perito
  mPZTIP := 66 // 66,"Р-исследование","Р-исслед."},;
  mPZKOL := kkt
  if !emptyall(kkd,kds,kvp,ksmp)
    aadd(ta,'кроме услуг 60.2.* в листе учета не должно быть других услуг ТФОМС')
  endif
  if human_->USL_OK != 3
    aadd(ta,'в поле "Условия оказания" должно быть "Поликлиника"')
  endif
  if is_kt
    s := "КТ"
  elseif is_mrt
    s := "МРТ"
  elseif is_angio
    s := "ангиографии"
  elseif is_koronaro
    s := "коронарографии"
  elseif is_g_cit
    s := "жидкостной цитологии"
    mPZTIP := 68 // 68,"жидкостная цитология","жидк.цитол"},;
  elseif is_pr_skr
    s := "пренатального скрининга"
    mPZTIP := 67 // 67,"пренатальный скрининг","прен.скрин"},;
  endif
  if empty(human_->NPR_MO)
    aadd(ta,'для '+s+' должно быть заполнено "Направившая МО"')
  elseif empty(human_2->NPR_DATE)
    if glob_mo[_MO_KOD_TFOMS] == ret_mo(human_->NPR_MO)[_MO_KOD_TFOMS]
      human_2->NPR_DATE := d1
    else
      aadd(ta,'должно быть заполнено поле "Дата направления"')
    endif
  elseif human_2->NPR_DATE > d1
    aadd(ta,'"Дата направления" больше "Даты начала лечения"')
  elseif human_2->NPR_DATE+60 < d1
    aadd(ta,'Направлению больше двух месяцев')
  endif
  if !eq_any(human_->ISHOD_NEW,304)
    aadd(ta,'в поле "Исход заболевания" должно быть "Без перемен"')
  endif
  if is_g_cit .or. is_pr_skr
    if !eq_any(human_->RSLT_NEW,314)
      aadd(ta,'в поле "Результат обращения" должно быть "Динамическое наблюдение"')
    endif
    if kkt > 1
      aadd(ta,'кол-во услуг '+s+' ('+lstr(kkt)+') не должно быть более 1')
    endif
    if human_->PROFIL != 34
      aadd(ta,'для '+s+' профиль должен быть КЛИНИЧЕСКАЯ ЛАБОРАТОРНАЯ ДИАГНОСТИКА')
    endif
  else
    if !eq_any(human_->RSLT_NEW,304)
      aadd(ta,'в поле "Результат обращения" должно быть "Лечение продолжено"')
    endif
    if kkt > 2
      aadd(ta,'кол-во услуг '+s+' ('+lstr(kkt)+') не должно быть более 2')
    endif
    if human_->PROFIL != 78
      aadd(ta,'для '+s+' профиль должен быть РЕНТГЕНОЛОГИЯ')
    endif
  endif
elseif kvp > 0
  mPZKOL := kvp-kvp_2_78-kvp_2_89
  if mIDSP == 12
    mPZTIP := 60 // 60,"Посещение профилактическое Центра здоровья","ПосПроф.ЦЗ"},;
    if kvp > 1 // Комплексная услуга центра здоровья
      aadd(ta,'в центре здоровья введено '+lstr(kvp)+' услуги (должна быть одна)')
    endif
  endif
  if d2 > d1
    if is_2_88
      if month(d1) == month(d2)
        aadd(ta,'для данной услуги срок лечения - один день')
      elseif month(d2) - month(d1) > 1 .and. year(d1) == year(d2)
        aadd(ta,'для данной услуги срок лечения не может быть более месяца')
      endif
    elseif is_2_80 .or. is_2_81 .or. is_2_82 .or. is_pren_diagn
      aadd(ta,'для данной услуги срок лечения - один день')
    endif
  endif
  if kvp > 1 .and. (is_2_80 .or. is_2_81 .or. is_2_82 .or. is_2_88)
    aadd(ta,'количество услуг должно быть равно 1')
  endif
  if is_2_78 .or. is_2_89
    mpztip := 59 // 59,"Обращение","амб.обращ."},;
    mPZKOL := 1 // ???
  elseif is_2_79 .or. is_2_81 .or. is_2_88
    mpztip := 57 // 57,"Посещение профилактическое","амб.проф."},;
  elseif is_2_80 .or. is_2_82
    mpztip := 58 // 58,"Посещение неотложное","амб.неотл."},;
  endif
elseif ksmp > 0
  mpztip := 51 // 51,"Вызов СМП","вызов СМП"},;
  mpzkol := ksmp
  if ksmp > 1
    aadd(ta,'количество услуг СМП должно быть равно 1')
  endif
  if len(au_lu) > 1
    aadd(ta,'кроме услуги 71.* в листе учета не должно быть других услуг ТФОМС')
  endif
  if human_->USL_OK != 4
    aadd(ta,'для услуги СМП условия должны быть "Скорая помощь"')
  endif
  /*if human_->PROFIL != 84
    aadd(ta,'для услуги СМП профиль должен быть по "скорой медицинской помощи"')
  endif*/
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
if is_dializ
  s := "гемодиализа"
  if kds > 0
    aadd(ta,'для '+s+' не вводится пациенто-день')
  endif
  if !eq_any(human_->PROFIL,56) // НЕФРОЛОГИЯ
    aadd(ta,'для '+s+' профиль должен быть НЕФРОЛОГИЯ')
  endif
  if !eq_any(ret_old_prvs(human_->PRVS),112207,113412) // НЕФРОЛОГИЯ
    aadd(ta,'для '+s+' специальность врача должна быть НЕФРОЛОГИЯ')
  endif
  human_->NPR_MO := glob_mo[_MO_KOD_TFOMS] // безусловно проставляем направившую МО
  human_2->NPR_DATE := d1
  mpztip := 56 // 56,"случай диализа","случ.диал."},;
  mpzkol := kkt
  /*if human_->RSLT_NEW != 201
    aadd(ta,'в поле "Результат обращения" должно быть "Выписан"')
  endif*/
  for i := 1 to len(a_dializ)
    if a_dializ[i,5] == 2
      aadd(ta,'в данном отчётном месяце уже был гемодиализ '+date_8(a_dializ[i,1])+"-"+date_8(a_dializ[i,2]))
    elseif a_dializ[i,5] == 3 .and. overlap_diapazon(a_dializ[i,1],a_dializ[i,2],d1,d2)
      if left(upper(human->fio),4) == "БОРЩ"
        // этого человека не проверяем
      else
        aadd(ta,'пересечение гемодиализа с перитонеальным диализом '+date_8(a_dializ[i,1])+"-"+date_8(a_dializ[i,2]))
      endif
    endif
  next
endif
if is_perito
  s := "для ПЕРИТОНЕАЛЬНОГО ДИАЛИЗА "
  if kds > 0
    aadd(ta,'для '+s+' не вводится пациенто-день')
  endif
  if human_->PROFIL != 56
    aadd(ta,s+'профиль должен быть НЕФРОЛОГИЯ')
  endif
  if !eq_any(ret_old_prvs(human_->PRVS),112207,113412) // НЕФРОЛОГИЯ
    aadd(ta,s+'специальность врача должна быть НЕФРОЛОГИЯ')
  endif
  human_->NPR_MO := glob_mo[_MO_KOD_TFOMS] // безусловно проставляем направившую МО
  human_2->NPR_DATE := d1
  mpztip := 56 // 56,"случай диализа","случ.диал."},;
  mpzkol := kkt
  /*if !eq_any(human_->RSLT_NEW,201,202,203,205)
    aadd(ta,'в поле "Результат обращения" стоит неверное значение')
  endif
  if human_->ISHOD_NEW == 201
    aadd(ta,'в поле "Исход заболевания" стоит неверное значение')
  endif*/
  for i := 1 to len(a_dializ)
    if a_dializ[i,5] == 3
      aadd(ta,'в данном отчётном месяце уже был перитонеальный диализ '+date_8(a_dializ[i,1])+"-"+date_8(a_dializ[i,2]))
    elseif a_dializ[i,5] == 2 .and. overlap_diapazon(a_dializ[i,1],a_dializ[i,2],d1,d2)
      if left(upper(human->fio),4) == "БОРЩ"
        // этого человека не проверяем
      else
        aadd(ta,'пересечение перитонеального диализа с гемодиализом '+date_8(a_dializ[i,1])+"-"+date_8(a_dializ[i,2]))
      endif
    endif
  next
endif
if is_s_dializ
  s := "услуги диализа в стационаре"
  if kkd > 0
    aadd(ta,'для '+s+' не вводится койко-день')
  endif
  human_->NPR_MO := glob_mo[_MO_KOD_TFOMS] // безусловно проставляем направившую МО
  human_2->NPR_DATE := d1
  mpztip := 54 // 54,"случай ЗПТ","случай ЗПТ"},;
  mpzkol := kkt
  for i := 1 to len(a_dializ)
    j := a_dializ[i,5] - 1
    if !between(j,1,2)
      j := 1
    endif
    if overlap_diapazon(a_dializ[i,1],a_dializ[i,2],d1,d2) .or. eq_any(d1,a_dializ[i,1],a_dializ[i,2]) ;
                                                           .or. eq_any(d2,a_dializ[i,1],a_dializ[i,2])
      aadd(ta,'услуга диализа в стационаре пересекается со случаем '+{"гемо","перитонеального "}[j]+'диализа '+date_8(a_dializ[i,1])+"-"+date_8(a_dializ[i,2]))
    endif
  next
  for i := 1 to len(a_srok_lech)
    otd->(dbGoto(a_srok_lech[i,4]))
    if a_srok_lech[i,5] == 1
      otd->(dbGoto(a_srok_lech[i,4]))
      aadd(ta,'пересечение с аналогичным диализом '+date_8(a_srok_lech[i,1])+"-"+date_8(a_srok_lech[i,2])+;
              iif(empty(otd->short_name), "", " ["+alltrim(otd->short_name)+"]"))
    endif
  next
endif
if is_disp_DDS //
  metap := 1
  m1mobilbr := 0
  tip_lu := iif(!empty(human->ZA_SMO), TIP_LU_DDS, TIP_LU_DDSOP)
  if d1_year != d2_year
    aadd(ta,'Дата начала и окончания случая должны быть в одном году')
  endif
  if eq_any(human->ishod,101,102)
    metap := human->ishod-100
    read_arr_DDS(human->kod)
  else
    aadd(ta,'Диспансеризацию детей-сирот надо вводить через специальный экран ввода')
  endif
  is_1_den := is_last_den := .f. ; zs := kvp := 0 ; oth_usl := ""
  for i := 1 to len(au_lu)
    if au_lu[i,3] == 0
      aadd(ta,'в услуге '+alltrim(au_lu[i,1])+' не проставлен профиль')
    endif
    if au_lu[i,4] == 0
      aadd(ta,'в услуге '+alltrim(au_lu[i,1])+' не проставлена спец-ть врача')
    endif
    if au_lu[i,2] > d2
      aadd(ta,'услуга '+au_lu[i,5]+'('+date_8(au_lu[i,2])+') не попадает в диапазон лечения')
    endif
    if is_issl_DDS(au_lu[i],mvozrast,ta)
      s := 'услуга '+au_lu[i,5]+'('+date_8(au_lu[i,2])+')'
      if alltrim(au_lu[i,1]) == "7.61.3"
        if au_lu[i,2] < addmonth(d1,-12)
          aadd(ta,'Флюорография оказана более 1 года назад')
        endif
      elseif mvozrast < 2
        if au_lu[i,2] < addmonth(d1,-1)
          aadd(ta,s+' оказана более 1 месяца назад')
        endif
      else
        if au_lu[i,2] < addmonth(d1,-3)
          aadd(ta,s+' оказана более 3 месяцев назад')
        endif
      endif
      if d1 == au_lu[i,2]
        is_1_den := .t.
      endif
    else
      s := 'услуга '+au_lu[i,5]+'-'+inieditspr(A__MENUVERT,glob_V002,au_lu[i,3])+'('+date_8(au_lu[i,2])+')'
      if is_osmotr_DDS_1_etap(au_lu[i],mvozrast,metap,mpol,tip_lu) //eq_any(alltrim(au_lu[i,5]),'2.3.1','2.4.1') // + 2.4.1-психиатр
        if eq_any(au_lu[i,3],68,57) // педиатр (врач общей практики)
          if au_lu[i,2] < d1
            aadd(ta,'Дата осмотра педиатра на I этапе не попадает в диапазон лечения')
          endif
        elseif mvozrast < 2
          if au_lu[i,2] < addmonth(d1,-1)
            aadd(ta,s+' оказана более 1 месяца назад')
          endif
        else
          if au_lu[i,2] < addmonth(d1,-3)
            aadd(ta,s+' оказана более 3 месяцев назад')
          endif
        endif
      elseif au_lu[i,2] < d1
        aadd(ta,s+' не попадает в диапазон лечения')
      endif
      if eq_any(left(au_lu[i,1],5),"70.5.","70.6.")
        ++zs
        s := ret_shifr_zs_DDS(tip_lu)
        if !(alltrim(au_lu[i,1]) == s)
          aadd(ta,'в л/у услуга '+alltrim(au_lu[i,1])+', а должна быть '+s+;
                  ' для возраста '+lstr(mvozrast)+' '+s_let(mvozrast))
        endif
      elseif is_osmotr_DDS(au_lu[i],mvozrast,ta,metap,mpol,tip_lu)
        if eq_any(left(au_lu[i,1],5),"2.83.","2.87.")
          ++kvp
        elseif left(au_lu[i,1],4) == "2.3."
          ++kvp
        endif
        if d1 == au_lu[i,2]
          is_1_den := .t.
        endif
        if d2 == au_lu[i,2]
          is_last_den := .t.
        endif
      else
        oth_usl += alltrim(au_lu[i,1])+" "
      endif
    endif
  next
  if metap == 1 .and. zs > 1
    aadd(ta,'в листе учета более одной услуги "законченный случай"')
  elseif metap == 2 .and. zs > 0
    aadd(ta,'для I и II этапов ДДС не должно быть услуг "законченный случай"')
  endif
  if !empty(oth_usl)
    aadd(ta,'в листе учета ДДС лишние услуги: '+oth_usl)
  endif
  if !is_1_den
    //aadd(ta,'первый врачебный осмотр должен быть оказан в первый день лечения')
  endif
  if !is_last_den
    aadd(ta,'последний врачебный осмотр должен быть оказан в последний день лечения')
  endif
  k := 0
  for d := d1 to d2
    if is_work_day(d)
      ++k
    endif
  next
  if metap == 1 .and. k > 10
    aadd(ta,'Срок ДДС I этапа должен составлять не более 10 рабочих дней (у Вас '+lstr(k)+')')
  elseif metap == 2 .and. k > 45
    aadd(ta,'Срок ДДС I и II этапа должен составлять не более 45 рабочих дней (у Вас '+lstr(k)+')')
  endif
endif
if is_prof_PN //
  human_->profil := 151  // медицинским осмотрам профилактическим
  metap := 1
  if d1_year != d2_year
    aadd(ta,'Дата начала и окончания случая должны быть в одном году')
  endif
  if eq_any(human->ishod,301,302)
    metap := human->ishod-300
    license_for_dispans(2,d1,ta)
  else
    aadd(ta,'Профилактику несовершеннолетних надо вводить через специальный экран ввода')
  endif
  mperiod := ret_period_PN(mdate_r,d1,d2)
  if between(mperiod,1,31)
    np_oftal_2_85_21(mperiod,d2) // добавить или удалить офтальмолога в массив для несовершеннолетних для 12 месяцев
    read_arr_PN(human->kod)
    kol_d_otkaz := 0
    if valtype(arr_usl_otkaz) == "A"
      for j := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[j]
        if valtype(ar) == "A" .and. len(ar) > 9 .and. valtype(ar[5]) == "C" .and. ;
                                                     valtype(ar[10]) == "C" .and. ar[10] $ "io"
          lshifr := alltrim(ar[5])
          if ar[10] == "i" // исследования
            if (i := ascan(np_arr_issled, {|x| valtype(x[1]) == "C" .and. x[1] == lshifr})) > 0
              if is_issled_PN({lshifr,ar[6],ar[4],ar[2]},mperiod,ta,human->pol)
                ++kol_d_otkaz
              endif
            endif
          elseif (i := ascan(np_arr_osmotr, {|x| valtype(x[1]) == "C" .and. x[1] == lshifr})) > 0 // осмотры
            if is_osmotr_PN({lshifr,ar[6],ar[4],ar[2]},mperiod,ta,metap,human->pol)
              ++kol_d_otkaz
            endif
          endif
        endif
      next j
    endif
    is_1_den := is_last_den := .f. ; zs := kvp := 0 ; oth_usl := kod_zs := "" ; is_neonat := .f.
    for i := 1 to len(au_lu)
      if au_lu[i,3] == 0
        aadd(ta,'в услуге '+alltrim(au_lu[i,1])+' не проставлен профиль')
      endif
      if au_lu[i,4] == 0
        aadd(ta,'в услуге '+alltrim(au_lu[i,1])+' не проставлена спец-ть врача')
      endif
      if au_lu[i,2] > d2
        aadd(ta,'услуга '+au_lu[i,5]+'('+date_8(au_lu[i,2])+') не попадает в диапазон лечения')
      endif
      if is_issled_PN(au_lu[i],mperiod,ta,mpol)
        s := 'услуга '+au_lu[i,5]+'('+date_8(au_lu[i,2])+')'
        if mvozrast < 2
          if left(au_lu[i,5],5) == "4.26."
            is_neonat := .t.
          endif
          if au_lu[i,2] < addmonth(d1,-1)
            aadd(ta,s+' оказана более 1 месяца назад')
          endif
        else
          if au_lu[i,2] < addmonth(d1,-3)
            aadd(ta,s+' оказана более 3 месяцев назад')
          endif
        endif
        if d1 == au_lu[i,2]
          is_1_den := .t.
        endif
      else
        s := 'услуга '+au_lu[i,5]+'-'+inieditspr(A__MENUVERT,glob_V002,au_lu[i,3])+'('+date_8(au_lu[i,2])+')'
        if eq_any(au_lu[i,3],68,57) // педиатр (врач общей практики)
          if au_lu[i,2] < d1
            aadd(ta,'Дата осмотра педиатра не попадает в диапазон лечения')
          endif
        elseif is_1_etap_PN(au_lu[i],mperiod,metap) // если услуга из 1 этапа
          if mvozrast < 2
            if au_lu[i,2] < addmonth(d1,-1)
              aadd(ta,s+' оказана более 1 месяца назад')
            endif
          else
            if au_lu[i,2] < addmonth(d1,-3)
              aadd(ta,s+' оказана более 3 месяцев назад')
            endif
          endif
        elseif au_lu[i,2] < d1
          aadd(ta,s+' не попадает в диапазон лечения')
        endif
        if left(au_lu[i,1],5) == "72.2."
          ++zs
          kod_zs := alltrim(au_lu[i,1])
        elseif eq_any(au_lu[i,3],68,57) // педиатр (врач общей практики)
          ++kvp
          if d1 == au_lu[i,2]
            is_1_den := .t.
          endif
          if d2 == au_lu[i,2]
            is_last_den := .t.
          endif
        elseif is_osmotr_PN(au_lu[i],mperiod,ta,metap,mpol)
          if eq_any(left(au_lu[i,1],4),"2.3.","2.4.","2.85","2.91")
            ++kvp
          endif
          if d1 == au_lu[i,2]
            is_1_den := .t.
          endif
          if d2 == au_lu[i,2]
            is_last_den := .t.
          endif
        elseif !(metap == 2 .and. is_lab_usluga(au_lu[i,1]))
          oth_usl += alltrim(au_lu[i,1])+" "
        endif
      endif
    next
    if metap == 1 .and. zs == 1
      s := ret_shifr_zs_PN(mperiod)
      if !(kod_zs == s)
        aadd(ta,'в л/у услуга '+kod_zs+', а должна быть '+s+;
                ' для возраста '+lstr(mvozrast)+' '+s_let(mvozrast))
      endif
    elseif metap == 1 .and. zs > 1
      aadd(ta,'в листе учета более одной услуги "законченный случай"')
    elseif metap == 2 .and. zs > 0
      aadd(ta,'для двухэтапной профилактики несовершеннолетних не должно быть услуг "законченный случай"')
    endif
    if !empty(oth_usl)
      aadd(ta,'в листе учета ПН лишние услуги: '+oth_usl)
    endif
    if !is_1_den
      //aadd(ta,'первый врачебный осмотр должен быть оказан в первый день лечения')
    endif
    if !is_last_den
      aadd(ta,'последний врачебный осмотр должен быть оказан в последний день лечения')
    endif
    k := 0
    for d := d1 to d2
      if is_work_day(d)
        ++k
      endif
    next
    if metap == 1 .and. k > 20
      aadd(ta,'Срок ПН I этапа должен составлять 20 рабочих дней (у Вас '+lstr(k)+')')
    elseif metap == 2 .and. k > 45
      aadd(ta,'Срок ПН I и II этапа должен составлять 45 рабочих дней (у Вас '+lstr(k)+')')
    endif
    // проверим, выполнены обязательные услуги (и наоборот)
    ar := aclone(np_arr_1_etap[mperiod,5])
    for i := 1 to len(ar) // исследования
      lshifr := alltrim(ar[i])
      if ascan(au_lu, {|x| alltrim(x[1]) == lshifr}) > 0
        // услуга оказана
      elseif ascan(arr_usl_otkaz, {|x| valtype(x)=="A" .and. valtype(x[5])=="C" .and. alltrim(x[5])==lshifr}) > 0
        // услуга в отказах
      else
        s := ""
        if (j := ascan(np_arr_issled, {|x| x[1] == lshifr})) > 0
          s := np_arr_issled[j,3]
        endif
        aadd(ta,'некорректно записано исследование '+lshifr+' '+s+' (отредактируйте)')
      endif
    next
    ar := aclone(np_arr_1_etap[mperiod,4])
    for i := 1 to len(ar) // осмотры 1 -го этапа
      lshifr := alltrim(ar[i])
      if (j := ascan(np_arr_osmotr, {|x| x[1] == lshifr})) > 0
        fl := .f.
        if ascan(au_lu, {|x| alltrim(x[1]) == lshifr}) > 0
          fl := .t. // услуга оказана
        elseif ascan(arr_usl_otkaz, {|x| valtype(x)=="A" .and. valtype(x[5])=="C" .and. alltrim(x[5])==lshifr}) > 0
          fl := .t. // услуга в отказах
        elseif !empty(np_arr_osmotr[j,2]) .and. !(np_arr_osmotr[j,2] == human->pol)
          loop
        else
          for k := 1 to len(au_lu)
            // проверяем только нулевые услуги
            if eq_any(left(au_lu[k,1],4),"2.3.","2.4.") .and. au_lu[k,3] == np_arr_osmotr[j,4]
              fl := .t. // услуга оказана (нашли по профилю)
              exit
            endif
          next k
        endif
        if !fl
          aadd(ta,'некорректно записан врачебный осмотр 1-го этапа "'+np_arr_osmotr[j,3]+'" (отредактируйте)')
        endif
      endif
    next i
    if empty(ta) // если пока нет ошибок
      fl := .f.
      for i := 1 to len(au_lu)
        if eq_any(au_lu[i,3],68,57) ; // педиатр (врач общей практики)
                  .and. left(au_lu[i,1],4) == "2.3." // на 1-ом этапе
          fl := .t. ; exit
        endif
      next i
      if !fl
        aadd(ta,'некорректно записан врачебный осмотр педиатра на 1-ом этапе (отредактируйте)')
      endif
    endif
  else
    aadd(ta,"Не удалось определить возрастной период для профилактики несовершеннолетнего")
  endif
endif
if is_disp_DVN //
  human_->profil := 151  // медицинским осмотрам профилактическим
  m1g_cit := m1veteran := m1dispans := 0 ; is_prazdnik := .f.
  read_arr_DVN(human->kod)
  if d1_year != d2_year
    aadd(ta,'Дата начала и окончания случая должны быть в одном году')
  endif
  for i := 1 to len(au_lu_ne)
    s := alltrim(au_lu_ne[i,1])
    if !empty(au_lu_ne[i,2])
      s += "("+alltrim(au_lu_ne[i,2])+")"
    endif
    s += ' '+alltrim(au_lu_ne[i,3])
    aadd(ta,'неверная услуга "'+s+'" от '+date_8(au_lu_ne[i,4])+'г.')
  next
  metap := 3
  if between(human->ishod,201,205)
    metap := human->ishod-200
    license_for_dispans(1,d1,ta)
  else
    aadd(ta,'Диспансеризацию/профилактику взрослых надо вводить через специальный экран ввода')
  endif
  if m1veteran == 1
    if metap == 3
      aadd(ta,'Профилактику взрослых не проводят ветеранам ВОВ (блокадникам)')
    else
      mdvozrast := ret_vozr_DVN_veteran(mdvozrast,human->k_data)
    endif
  endif
  for i := 1 to len(a_disp)
    // {human->ishod-200,human->n_data,human->k_data,human_->RSLT_NEW}
    if overlap_diapazon(a_disp[i,2],a_disp[i,3],d1,d2)
      aadd(ta,'пересечение с '+iif(a_disp[i,1]==3,"профилактикой ","диспансеризацией ")+;
              date_8(a_disp[i,2])+"-"+date_8(a_disp[i,3]))
    endif
  next
  if metap == 2 .and. ascan(a_disp, {|x| x[1] == 1 }) == 0
    aadd(ta,'это II этап диспансеризации, но отсутствует случай I этапа диспансеризации')
  elseif metap == 5 .and. ascan(a_disp, {|x| x[1] == 4 }) == 0
    aadd(ta,'это II этап диспансеризации, но отсутствует случай I этапа диспансеризации раз в 2 года')
  endif
  // отметим обязательные услуги
  arr1 := array(count_dvn_arr_usl,5)    ; afillall(arr1,0)
  arr2 := array(count_dvn_arr_umolch,5) ; afillall(arr2,0)
  for i := 1 to count_dvn_arr_usl
    fl_ekg := .f. ; i_otkaz := 0
    if f_is_usl_oms_sluch_DVN(i,metap,iif(metap==3,mvozrast,mdvozrast),mpol,,@i_otkaz,@fl_ekg)
      arr1[i,2] := 1
      arr1[i,3] := i_otkaz
      arr1[i,5] := iif(fl_ekg, 1, 0) // 1 - необязательный возраст
    endif
  next
  for i := 1 to count_dvn_arr_umolch
    if f_is_umolch_sluch_DVN(i,metap,iif(metap==3,mvozrast,mdvozrast),mpol)
      arr2[i,2] := 1
    endif
  next
  // отметим выполненные услуги
  for j := 1 to len(au_lu)
    lshifr := alltrim(au_lu[j,1])
    fl := .t.
    if ((lshifr == "2.3.3" .and. au_lu[j,3] == 3) .or.  ; // акушерскому делу
          (lshifr == "2.3.1" .and. au_lu[j,3] == 136))  ; // акушерству и гинекологии
        .and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.1.12"})) > 0
      arr1[i,1] ++
      fl := .f.
    endif
    if fl
      for i := 1 to count_dvn_arr_umolch
        if arr2[i,1] == 0 .and. dvn_arr_umolch[i,2] == lshifr
          arr2[i,1] ++ ; fl := .f. ; exit
        endif
      next
    endif
    if fl
      for i := 1 to count_dvn_arr_usl
        if arr1[i,1] == 0
          if valtype(dvn_arr_usl[i,2]) == "C"
            if dvn_arr_usl[i,2] == "4.20.1"
              if lshifr == "4.20.1"
                m1g_cit := 1
              elseif lshifr == "4.20.2"
                m1g_cit := 2 ; fl := .f.
              endif
            endif
            if dvn_arr_usl[i,2] == lshifr
              fl := .f.
            endif
          elseif len(dvn_arr_usl[i]) > 11 .and. valtype(dvn_arr_usl[i,12]) == "A"
            if ascan(dvn_arr_usl[i,12],{|x| x[1] == lshifr .and. x[2] == au_lu[j,3]}) > 0
              fl := .f.
            endif
          endif
          if !fl
            arr1[i,1] ++ ; exit
          endif
        endif
      next
    endif
    if fl .and. ascan(dvn_700,{|x| x[2] == lshifr}) > 0
      fl := .f. // к нулевой услуге добавлена услуга с ценой на "700"
    endif
    if fl .and. !eq_any(left(lshifr,5),"70.3.","72.1.")
      aadd(ta,lshifr+' - некорректная настройка в справочнике услуг шифра ТФОМС')
    endif
  next j
  is_1_den := is_last_den := .f. ; zs := kvp := 0 ; oth_usl := ""
  mv := iif(metap == 3, mvozrast, mdvozrast)
  kod_spec_ter := 0
  if eq_any(metap,1,4)
    for i := 1 to len(au_lu)
      if eq_any(au_lu[i,3],97,57,42) // профиль терапевт (врач общей практики)
        kod_spec_ter := au_lu[i,4]  // специальность терапевта (врача общей практики)
        exit
      endif
    next
  elseif eq_any(metap,2,5) // поверка на обязательное сочетание услуг второго этапа
    ar := array(len(dvn_2_etap),2) ; afillall(ar,0)
    for i := 1 to len(au_lu)
      lshifr := alltrim(au_lu[i,1])
      for j := 1 to len(dvn_2_etap)
        if ascan(dvn_2_etap[j,1],lshifr) > 0 .and. between(mdvozrast,dvn_2_etap[j,3],dvn_2_etap[j,4])
          ar[j,1] := 1
        elseif ascan(dvn_2_etap[j,2],lshifr) > 0 .and. between(mdvozrast,dvn_2_etap[j,3],dvn_2_etap[j,4])
          ar[j,2] := 1
        endif
      next
    next
    for j := 1 to len(dvn_2_etap)
      if empty(ar[j,1]) .and. !empty(ar[j,2])
        if len(dvn_2_etap[j,2]) == 1
          s := 'для услуги '+dvn_2_etap[j,2,1]
        else
          s := 'для услуг '+print_array(dvn_2_etap[j,2])
        endif
        s += ' обязательно наличие услуги '
        if len(dvn_2_etap[j,1]) == 1
          s += dvn_2_etap[j,1,1]
        else
          s += print_array(dvn_2_etap[j,1])
        endif
        s += " (в возрасте от "+lstr(dvn_2_etap[j,3])+" до "+lstr(dvn_2_etap[j,4])+" лет)"
        aadd(ta,s)
      //elseif !empty(ar[j,1]) .and. empty(ar[j,2])
        //aadd(ta,'для услуги '+print_array(dvn_2_etap[j,1])+' обязательно наличие  услуг '+print_array(dvn_2_etap[j,2]))
      endif
    next
  endif
  a_4_20_1 := {0,0}
  for i := 1 to len(au_lu)
    lshifr := alltrim(au_lu[i,1])
    do case
      case lshifr == "4.1.12" // Осмотр акушеркой, взятие мазка (соскоба)
        a_4_20_1[1] := 3
      case eq_any(lshifr,"4.20.1","4.20.2") // Иссл-е взятого цитологического материала
        a_4_20_1[2] := 3
        if lshifr == "4.20.2" .and. au_lu[i,7] < d1
          m1g_cit := 1
        endif
    endcase
  next
  // учёт и проверка отказов
  kol_d_usl := kol_d_otkaz := kol_n_date := 0
  if valtype(arr_usl_otkaz) == "A"
    for j := 1 to len(arr_usl_otkaz)
      ar := arr_usl_otkaz[j]
      if valtype(ar) == "A" .and. len(ar) >= 10 .and. valtype(ar[5]) == "C"
        lshifr := alltrim(ar[5])
        if (i := ascan(dvn_arr_usl, {|x| valtype(x[2]) == "C" .and. x[2] == lshifr})) > 0
          if valtype(ar[10]) == "N" .and. between(ar[10],1,2)
            ++kol_d_usl
            arr1[i,4] := ar[10] // 1-отказ, 2-невозможность
            if lshifr == "4.1.12" // Осмотр акушеркой, взятие мазка (соскоба)
              a_4_20_1[1] := ar[10]
            endif
            if ar[10] == 1
              ++kol_d_otkaz
              // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
              is_usluga_dvn({lshifr,ar[9],ar[4],ar[2]},mv,ta,metap,mpol,kod_spec_ter)
            endif
          endif
        endif
      endif
    next
  endif
  if !eq_any(metap,2,5) // проверим, выполнены обязательные услуги (и наоборот)
    for i := 1 to count_dvn_arr_usl
      s := '"'+iif(valtype(dvn_arr_usl[i,2]) == "C", dvn_arr_usl[i,2]+' ', '')
      s += dvn_arr_usl[i,1]+'"'
      if arr1[i,2] == 0 // не надо выполнять
        if arr1[i,1] > 1
          aadd(ta,'не надо выполнять, а выполнили '+s)
        endif
      elseif arr1[i,2] == 1 // надо выполнять
        if arr1[i,1] == 0 .and. arr1[i,5] == 0 // ЭКГ + обязательный возраст
          if arr1[i,4] == 2 .and. arr1[i,3] < 2 // "невозможно", разрешён "отказ"
            aadd(ta,'НЕВЕРНО установлена "невозможность" оказания услуги '+s)
          elseif arr1[i,4] == 0 // не отказ
            fl := .t.
            if valtype(dvn_arr_usl[i,2]) == "C"
              if dvn_arr_usl[i,2] == "4.20.1" .and. a_4_20_1[1] < 3
                fl := .f.
              endif
            endif
            if fl
              aadd(ta,'не оказана услуга '+s)
            endif
          endif
        elseif arr1[i,1] > 1
          aadd(ta,'выполнили более одной услуги '+s)
        endif
      endif
    next
    for i := 1 to count_dvn_arr_umolch
      s := '"'+dvn_arr_umolch[i,2]+' '+dvn_arr_umolch[i,1]+'"'
      if arr2[i,2] == 0 // не надо выполнять
        if arr2[i,1] > 1
          aadd(ta,'не надо выполнять, а выполнили '+s)
        endif
      elseif arr2[i,2] == 1 // надо выполнять
        if empty(arr2[i,1])
          aadd(ta,'нет услуги '+s)
        elseif arr2[i,1] > 1
          aadd(ta,'более одной услуги '+s)
        endif
      endif
    next
  endif
  k700 := 0
  for i := 1 to len(au_lu)
    hu->(dbGoto(au_lu[i,9]))       // 9 - номер записи
    lshifr := alltrim(au_lu[i,1])
    if left(lshifr,4) == '2.3.' .and. !empty(au_lu[i,3])
      s := 'услуга '+au_lu[i,5]+'-'+inieditspr(A__MENUVERT,glob_V002,au_lu[i,3])+'('+date_8(au_lu[i,2])+')'
    else
      s := 'услуга '+au_lu[i,5]+'('+date_8(au_lu[i,2])+')'
    endif
    if au_lu[i,3] == 0
      aadd(ta,s+' - не проставлен профиль')
    endif
    if au_lu[i,4] == 0
      aadd(ta,s+' - не проставлена спец-ть врача')
    endif
    if au_lu[i,2] > d2
      aadd(ta,s+' не попадает в диапазон лечения')
    endif
    if is_usluga_dvn(au_lu[i],mv,ta,metap,mpol,kod_spec_ter)
      if metap == 1 .and. empty(hu->u_cena) .and. !eq_any(left(lshifr,5),"4.20.","2.90.")
        ++kol_d_usl
      elseif metap == 3 .and. !(lshifr == "56.1.14")
        ++kol_d_usl
      endif
      if d1 == au_lu[i,2]
        is_1_den := .t.
      endif
      if !eq_any(metap,2,5) .and. au_lu[i,2] < d1 .and. !eq_any(lshifr,"4.20.1","4.20.2")
        ++kol_n_date // учтена ранее оказанная услуга
      endif
      if eq_any(metap,2,5) .and. au_lu[i,2] < d1
        aadd(ta,s+' не попадает в диапазон лечения')
      elseif left(lshifr,2) == "2." .and. eq_any(au_lu[i,3],97,57,42)
        if au_lu[i,2] != d2
          aadd(ta,s+' - терапевт должен проводить осмотр последним')
        endif
      elseif alltrim(au_lu[i,1]) == "7.61.3"
        if eq_any(year(au_lu[i,2]),d1_year,d1_year-1)
          // в течение предшествующего календарного года либо года проведения диспансеризации проводилась флюорография
        else
          aadd(ta,'Флюорография оказана в позапрошлом календарном году')
        endif
      else
        if au_lu[i,2] < addmonth(d1,-12)
          aadd(ta,s+' оказана более 1 года назад')
        endif
      endif
      if left(lshifr,5) == "2.84."
        ++kvp
      elseif eq_any(left(lshifr,4),"2.3.","2.90")
        ++kvp
      endif
      if d1 == au_lu[i,2]
        is_1_den := .t.
      endif
      if d2 == au_lu[i,2]
        is_last_den := .t.
      endif
    elseif ascan(dvn_700,{|x| x[2] == lshifr}) > 0
      ++k700 // к нулевой услуге добавлена услуга с ценой на "700"
    elseif eq_any(left(lshifr,5),"70.3.","72.1.")
      ++zs
      s := ret_shifr_zs_DVN(metap,mv,mpol,d2)
      if !(lshifr == s)
        aadd(ta,'в л/у услуга '+lshifr+', а должна быть '+s+' для возраста '+lstr(mv)+' '+s_let(mv))
      endif
    else
      oth_usl += lshifr+" "
    endif
  next
  if ascan(arr_vozrast_DVN,mdvozrast) > 0
    if metap > 2
      aadd(ta,'в '+lstr(mdvozrast)+s_let(mdvozrast)+' проводится диспансеризация, а проведена профилактика')
    endif
  else
    if eq_any(metap,1,2)
      aadd(ta,'в '+lstr(mvozrast)+s_let(mvozrast)+' проводится профилактика, а проведена диспансеризация')
    endif
  endif
  do case
    case metap == 1
      if zs > 1
        aadd(ta,'в листе учета более одной услуги "законченный случай"')
      elseif emptyall(zs,k700)
        aadd(ta,'в листе нет услуг с ценой')
      endif
      if (i := ascan(dvn_85, {|x| x[1] == kol_d_usl })) > 0
        if (k := dvn_85[i,1] - dvn_85[i,2]) < kol_d_otkaz
          aadd(ta,'отказы пациента составляют '+lstr(kol_d_otkaz/kol_d_usl*100,5,0)+'% (должно быть не более 15%)')
          aadd(ta,'отказов-'+lstr(kol_d_otkaz)+', всего учитываемых услуг-'+lstr(kol_d_usl))
        elseif kol_n_date+kol_d_otkaz <= k // отказы + ранее оказано менее 15%
          if zs == 0 .or. k700 > 0
            aadd(ta,'в листе учета должна быть услуга "законченный случай" - отредактируйте')
          endif
        else
          if zs > 0 .or. empty(k700)
            aadd(ta,'в листе учета не должно быть услуги "законченный случай" - отредактируйте')
          endif
        endif
      else
        aadd(ta,'слишком много отказов-'+lstr(kol_d_otkaz))//+' услуг-'+lstr(kol_d_usl))
      endif
    case metap == 4
      if zs > 1
        aadd(ta,'в листе учета более одной услуги "законченный случай"')
      elseif emptyall(zs,k700)
        aadd(ta,'в листе учета нет услуг с ценой')
      endif
    case eq_any(metap,2,5)
      if zs > 0
        aadd(ta,'для II этапа ДВН не должно быть услуг "законченный случай"')
      endif
    case metap == 3
      if zs > 1
        aadd(ta,'в листе учета более одной услуги "законченный случай"')
      endif
      if (i := ascan(prof_vn_85, {|x| x[1] == kol_d_usl })) > 0
        if prof_vn_85[i,1] - prof_vn_85[i,2] < kol_d_otkaz
          aadd(ta,'отказы пациента составляют '+lstr(kol_d_otkaz/kol_d_usl*100,5,0)+'% (должно быть не более 15%)')
          aadd(ta,'отказов-'+lstr(kol_d_otkaz)+', всего учитываемых услуг-'+lstr(kol_d_usl))
        endif
      else
        aadd(ta,'слишком много отказов-'+lstr(kol_d_otkaz))
      endif
  endcase
  if !empty(oth_usl)
    aadd(ta,'в листе учета ДВН лишние услуги: '+oth_usl)
  endif
  if !is_1_den
    //aadd(ta,'первый врачебный осмотр должен быть оказан в первый день лечения')
  endif
  if !is_last_den
    aadd(ta,'последний врачебный осмотр должен быть оказан в последний день лечения')
  endif
  if metap != 3 .and. eq_any(human_->RSLT_NEW,317,318,355,356)
    adiag_talon := array(16)
    for i := 1 to 16
      adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
    next
    am := {}
    for i := 1 to len(mdiagnoz)
      if !empty(mdiagnoz[i]) .and. eq_any(adiag_talon[i*2],1,2)
        aadd(am,mdiagnoz[i]) // массив диагнозов с диспансеризацией
      endif
    next
    do case
      case human_->RSLT_NEW == 317 // {"Проведена диспансеризация - присвоена I группа здоровья"   ,1,317}
        if !empty(am)
          aadd(ta,'для I группы здоровья не должно быть установления диспансерного учёта '+print_array(am))
        endif
      case human_->RSLT_NEW == 318 // {"Проведена диспансеризация - присвоена II группа здоровья"  ,2,318}
        fl := .f.
        for i := 1 to len(am)
          if left(am[i],3) == "E78"
            fl := .t.
          else
            aadd(ta,'для II группы здоровья диспансерный учёт может быть установлен только для гиперхолестеринемии, а не для '+am[i])
          endif
        next
        if fl .and. m1dispans != 3 // {"участковым терапевтом",3}
          aadd(ta,'для II группы здоровья "Диспансерное наблюдение установлено" может быть только "участковым терапевтом"')
        endif
      case human_->RSLT_NEW == 355 // {"Проведена диспансеризация - присвоена IIIа группа здоровья",3,355}
        if empty(am)
          aadd(ta,'для IIIа группы здоровья обязательно должен быть установлен диспансерный учёт')
        endif
      case human_->RSLT_NEW == 356 // {"Проведена диспансеризация - присвоена IIIб группа здоровья",4,356}
        if empty(am)
          aadd(ta,'для IIIб группы здоровья обязательно должен быть установлен диспансерный учёт')
        endif
    endcase
  endif
endif
if is_pren_diagn //
  human_->PROFIL := 106 // ультразвуковой диагностике
  if human->n_data != human->k_data
    aadd(ta,'Дата окончания лечения должна совпадать с датой начала лечения')
  endif
  if human->ishod != 99
    aadd(ta,'Пренатальная диагностика вводится через специальный экран ввода')
  endif
  k1 := k2 := 0 ; oth_usl := ""
  for i := 1 to len(au_lu)
    if eq_any(alltrim(au_lu[i,1]),"2.79.51","8.30.3")
      k1 += au_lu[i,6]
    elseif alltrim(au_lu[i,1]) == "4.26.6"
      k1 += au_lu[i,6]
    elseif alltrim(au_lu[i,1]) == "2.5.1"
      k2 += au_lu[i,6]
    else
      oth_usl += alltrim(au_lu[i,1])+" "
    endif
  next
  if k1 != 3
    aadd(ta,'в листе учета неверное количество обязательных услуг')
  endif
  if k2 > 1
    aadd(ta,'в листе учета должно быть не более одной услуги 2.5.1')
  endif
  if !empty(oth_usl)
    aadd(ta,'в листе учета пренатальной диагностики лишние услуги: '+oth_usl)
  endif
endif
if human_->USL_OK == 4 .and. !(is_71_1 .or. is_71_2 .or. is_71_3)
  aadd(ta,'для условия "Скорая помощь" не введены услуги СМП')
endif
if !empty(u_1_stom)
  // просмотр других случаев данного больного
  select HUMAN
  set order to 2
  find (str(glob_kartotek,7))
  do while human->kod_k == glob_kartotek .and. !eof()
    if (fl := (d2_year==year(human->k_data) .and. rec_human!=human->(recno())))
      //
    endif
    if fl .and. human->schet > 0 .and. eq_any(human_->oplata,2,9)
      fl := .f. // лист учёта снят по акту или выставлен повторно
    endif
    if fl .and. m1novor != human_->NOVOR
      fl := .f. // лист учёта на новорожденного (или наоборот)
    endif
    if fl .and. human_->idsp == 4 // лечебно-диагностическая процедура
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          if f_is_1_stom(lshifr)
            aadd(ta,'оказана услуга первичного стоматологического приёма '+u_1_stom+',')
            aadd(ta,' а в случае '+date_8(human->n_data)+'-'+date_8(human->k_data)+' уже была оказана услуга '+lshifr)
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
  human->(dbGoto(rec_human))
endif
if human_->oplata == 2
  aadd(ta,'вернулся из ТФОМС с ошибкой и ещё не отредактирован')
endif
if is_disp_DDS .or. is_disp_DVN .or. is_prof_PN
  arr_unit := {144} // "комплексное посещение при диспансеризации"
endif
if len(arr_unit) > 1
  if select("MOUNIT") == 0
    R_Use(dir_exe+"_mo8unit",cur_dir+"_mo8unit","MOUNIT")
  endif
  s := "совокупность услуг должна быть из одной учётной единицы объёма, а в данном случае: "
  select MOUNIT
  for i := 1 to len(arr_unit)
    find (str(arr_unit[i],3))
    if found()
      s += alltrim(mounit->name)+", "
    endif
  next
  aadd(ta,left(s,len(s)-2))
endif
if fl_view .and. !is_s_dializ .and. !is_dializ .and. !is_perito .and. len(a_rec_ffoms) > 0 // повтор диагноза
  ltip := 0
  i := 1
  asort(a_rec_ffoms,,,{|x,y| x[3] < y[3] })
  if gusl_ok == 3     // поликлиника
    if is_2_78
      ltip := 1
    elseif is_2_80
      ltip := 2
    elseif is_2_88
      ltip := 3
    elseif is_2_89
      ltip := 4
    endif
    if ltip == 0
      i := 0
    else
      fl := .f.
      for i := 1 to len(a_rec_ffoms)
        select HU
        find (str(a_rec_ffoms[i,1],7))
        do while hu->kod == a_rec_ffoms[i,1] .and. !eof()
          lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
            lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
            left_lshifr_5 := left(lshifr,5)
            if left_lshifr_5 == "2.78."
              if !between_shifr(lshifr,"2.78.54","2.78.60")
                a_rec_ffoms[i,2] := 1
                fl := .t.
              endif
            elseif left_lshifr_5 == "2.80."
              if !between_shifr(lshifr,"2.80.34","2.80.38")
                if ltip == 2 // если прошлое и новое лечение "2.80."
                  a_rec_ffoms[i,2] := 2
                  fl := .t.
                endif
              endif
            elseif left_lshifr_5 == "2.88."
              if !between_shifr(lshifr,"2.88.46","2.88.51")
                a_rec_ffoms[i,2] := 3
                fl := .t.
              endif
            elseif left_lshifr_5 == "2.89."
              a_rec_ffoms[i,2] := 4
              fl := .t.
            endif
          endif
          if fl ; exit ; endif
          select HU
          skip
        enddo
        if fl ; exit ; endif
      next
      if !fl
        i := 0
      endif
    endif
  endif
  if i > 0
    select D_SROK
    append blank
    d_srok->kod  := human->kod
    d_srok->tip  := ltip
    d_srok->otd  := human->otd
    d_srok->kod1 := a_rec_ffoms[i,1]
    d_srok->tip1 := a_rec_ffoms[i,2]
    d_srok->dni  := a_rec_ffoms[i,3]
  endif
endif
if len(ta) > 0
  _ocenka := 0
  verify_FF(80-len(ta)-3,.t.,80)
  add_string("")
  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  add_string(alltrim(human->fio)+" "+alltrim(human->kod_diag)+" "+;
             date_8(human->n_data)+"-"+date_8(human->k_data)+;
             " ("+count_ymd(human->date_r,human->n_data)+")")
  Ins_Array(ta,1,alltrim(uch->name)+'/'+alltrim(otd->name)+'/профиль по "'+;
                 inieditspr(A__MENUVERT, glob_V002, human_->profil)+'"')
  if human->cena_1 == 0 ; // если цена нулевая
      .and. eq_any(human->ishod,201,202) // диспансеризация взрослого населения
    asize(ta,1) // чтобы не выводить бессмысленные строки
    aadd(ta,"не определена сумма случая - отредактируйте")
  endif
  for i := 1 to len(ta)
    for j := 1 to perenos(t_arr,ta[i],78)
      if j == 1
        add_string(iif(i==1," ", "- ")+t_arr[j])
      else
        add_string(padl(alltrim(t_arr[j]),80))
      endif
    next
  next
else
  if is_disp_DDS .or. is_disp_DVN3 .or. is_prof_PN
    mpztip := 72 // {72,260,"комплексное посещение при диспансеризации","ПосДиспанс.","",""},; //
    mpzkol := 1
  elseif is_disp_DVN .and. eq_any(metap,1,4)
    mpztip := 73 // {73,261,"комплексное посещение при ДВН 1 этап","ДВН 1","",""},; //
    mpzkol := 1
  elseif is_disp_DVN .and. eq_any(metap,2,5)
    mpztip := 74 // {74,262,"комплексное посещение при ДВН 2 этап","ДВН 2","",""},; //
    mpzkol := 1
  endif
  if ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
    mpzkol := len(au_lu) // кол-во анализов
  endif
  if len(arr_unit) == 1
    if select("MOUNIT") == 0
      R_Use(dir_exe+"_mo8unit",cur_dir+"_mo8unit","MOUNIT")
    endif
    select MOUNIT
    find (str(arr_unit[1],3))
    if found() .and. mounit->pz > 0
      mpztip := mounit->pz
    endif
  endif
  human_->POVOD := mpovod
  human_->PZTIP := mpztip
  human_->PZKOL := mpzkol
endif
if !valid_GUID(human_->ID_PAC)
  human_->ID_PAC := mo_guid(1,human_->(recno()))
endif
if !valid_GUID(human_->ID_C)
  human_->ID_C := mo_guid(2,human_->(recno()))
endif
human_->ST_VERIFY := _ocenka // проверен
if fl_view
  //dbUnLockAll()
endif
return (_ocenka >= 5)

*

/***** 22.09.14 определение КСГ по остальным введённым полям ввода
Function definition_KSG_14(par)
// файлы "human", "human_" и "human_2" открыты и стоят на нужной записи
//       "human" открыт для записи суммы случая
// выполнено use_base("human_u","HU") - для записи
// выполнено use_base("mo_hu","MOHU") - для записи
Static ad_ksg_3, ad_ksg_4
Static arr_c := {{"t006->c0","0"},{"t006->c8","8"},{"t006->c9","9"}}
Local mdiagnoz, aHirKSG := {}, aTerKSG := {}, fl_cena, lvmp, lvidvmp := 0,;
      i, j, k, s, ar, fl, im, lshifr, lk_data, lvr, ldni, ldate_r, lpol,;
      cenaTer := 0, cenaHir := 0, ksgHir, ars := {}, arerr := {}, amohu := {},;
      lksg := "", lcena := 0, osn_diag, sop_diag, osn_diag3, lprofil,;
      arr_man := {}, rule_onko_1 := {.f.,.f.,.f.}, rule_onko_2 := {.f.,.f.}
DEFAULT par TO 1
Private pole
if par == 1
  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  if (lvmp := human_2->VMP) == 1
    lvidvmp := human_2->METVMP
  endif
  lk_data := human->k_data
  ldate_r := iif(human_->NOVOR > 0, human_->date_r2, human->date_r)
  lpol    := iif(human_->NOVOR > 0, human_->pol2,    human->pol)
  lvr     := iif(human->VZROS_REB==0, 0, 1) // 0-взрослый, 1-ребенок
  ldni    := human->n_data - ldate_r // для ребёнка возраст в днях
  lprofil := human_->profil
  aadd(ars,alltrim(human->fio)+" "+date_8(human->n_data)+"-"+date_8(human->k_data))
  aadd(ars,iif(lVMP==1,' ВМП','')+' '+alltrim(uch->name)+'/'+alltrim(otd->name)+;
           '/профиль "'+inieditspr(A__MENUVERT, glob_V002, human_->profil)+'"')
  // массив диагнозов (минимум два)
  mdiagnoz := diag_for_xml(,,,,.t.)
  osn_diag := alltrim(mdiagnoz[1])
  sop_diag := alltrim(mdiagnoz[2])
else // из режима импорта случаев
  if (lvmp := iif(empty(ihuman->VID_HMP), 0, 1)) == 1
    lvidvmp := ihuman->METOD_HMP
  endif
  lk_data := ihuman->date_2
  ldate_r := iif(ihuman->NOVOR > 0, ihuman->reb_dr,  ihuman->dr)
  lpol    := iif(ihuman->NOVOR > 0, ihuman->reb_pol, ihuman->w)
  lpol    := iif(lpol == 1, "М","Ж")
  lvr     := iif(m1VZROS_REB==0, 0, 1) // 0-взрослый, 1-ребенок
  ldni    := ihuman->date_1 - ldate_r // для ребёнка возраст в днях
  lprofil := ihuman->profil
  aadd(ars,alltrim(ihuman->fio)+" "+date_8(ihuman->date_1)+"-"+date_8(ihuman->date_2))
  aadd(ars,iif(lVMP==1,' ВМП','')+' профиль "'+inieditspr(A__MENUVERT, glob_V002, ihuman->PROFIL)+'"')
  osn_diag := alltrim(ihuman->DS1)
  sop_diag := alltrim(ihuman->DS2)
endif
aadd(ars,' дата.р.'+full_date(ldate_r)+', '+iif(lpol=='М','мужчина','женщина')+;
         ', осн.диагноз '+osn_diag+iif(empty(sop_diag), '', ', сопут.диагноз '+sop_diag))
if lprofil == 158 // профиль = "медицинской реабилитации"
  lksg := "1.13.1"
  aadd(ars,' для профиля "медицинской реабилитации" вместо КСГ введена услуга '+lksg)
  lcena := ret_cena_KSG(lksg,lvr,lk_data,arerr)
  if lcena > 0
    aadd(ars," РЕЗУЛЬТАТ: выбрана услуга="+lksg+" с ценой "+lstr(lcena,11,2))
  endif
  return {ars,arerr,lksg,lcena}
endif
if lk_data >= stod("20140217") .and. lvidvmp > 0 .and. ascan(arr_12_VMP,lvidvmp) > 0
  lksg := "1.12."+lstr(lvidvmp)
  aadd(ars," для "+lstr(lvidvmp)+" метода ВМП вместо КСГ введена услуга "+lksg)
  lcena := ret_cena_KSG(lksg,lvr,lk_data,arerr)
  if lcena > 0
    aadd(ars," РЕЗУЛЬТАТ: выбрана услуга="+lksg+" с ценой "+lstr(lcena,11,2))
  endif
  return {ars,arerr,lksg,lcena}
endif
if lk_data >= stod("20140701") .and. lvidvmp > 0 .and. ascan(arr_14_VMP,lvidvmp) > 0
  lksg := "1.14."+lstr(lvidvmp)
  aadd(ars," для "+lstr(lvidvmp)+" метода ВМП вместо КСГ введена услуга "+lksg)
  lcena := ret_cena_KSG(lksg,lvr,lk_data,arerr)
  if lcena > 0
    aadd(ars," РЕЗУЛЬТАТ: выбрана услуга="+lksg+" с ценой "+lstr(lcena,11,2))
  endif
  return {ars,arerr,lksg,lcena}
endif
if select("T006") == 0
  R_Use(exe_dir+"_mo_t006",cur_dir+"_mo_t006","T006")
endif
if ad_ksg_3 == NIL // один раз при первом вызове функции
  ad_ksg_3 := {} // заполним массив диагнозами для КСГ=3
  select T006
  index on shifr to (cur_dir+"tmp_t006")
  find ("003")
  do while t006->shifr == "003" .and. !eof()
    aadd(ad_ksg_3,{alltrim(t006->name),t006->(recno())})
    skip
  enddo
  ad_ksg_4 := {} // заполним массив диагнозами для КСГ=4
  find ("004")
  do while t006->shifr == "004" .and. !eof()
    aadd(ad_ksg_4,{alltrim(t006->name),t006->(recno())})
    skip
  enddo
  set index to (cur_dir+"_mo_t006")
endif
// собираем в массив все терапевтические КСГ
ar := {}
select T006
find ("1"+padr(osn_diag,20))
do while t006->TYPE_KSG==1 .and. t006->NAME==padr(osn_diag,20) .and. !eof()
  if lVMP == 1
    if t006->r1 == 1 // ВМП
      for i := 1 to len(arr_c)
        pole := arr_c[i,1]
        if &pole == 1
          s := "111"+arr_c[i,2]+t006->shifr
          select LUSL
          find (padr(s,10))
          if found()
            aadd(ar,{s,0})
          endif
        endif
      next
    endif
  else
    if t006->r0 == 1 // специализированная
      for i := 1 to len(arr_c)
        pole := arr_c[i,1]
        if &pole == 1
          s := "110"+arr_c[i,2]+t006->shifr
          select LUSL
          find (padr(s,10))
          if found()
            aadd(ar,{s,0})
          endif
        endif
      next
    endif
  endif
  select T006
  skip
enddo
j := 0 ; fl_cena := .f.
for i := 1 to len(ar)
  ar[i,2] := ret_cena_KSG(ar[i,1],lvr,lk_data)
  if ar[i,2] > 0
    ++j
    fl_cena := .t.
  endif
next
aadd(aTerKSG,{osn_diag,sop_diag,j,aclone(ar)})
//aadd(ars," aTerKSG: "+print_array(aTerKSG))
f_put_debug_KSG_14(1,aTerKSG,1,ars)
// массив манипуляций
if par == 1
  if select("MOSU") == 0
    R_Use(dir_server+"mo_su",,"MOSU")
  endif
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    if mosu->(recno()) != mohu->u_kod
      mosu->(dbGoto(mohu->u_kod))
    endif
    aadd(amohu,mosu->shifr1)
    select MOHU
    skip
  enddo
else
  select IHU
  find (str(ihuman->kod,10))
  do while ihu->kod == ihuman->kod .and. !eof()
    if eq_any(left(ihu->CODE_USL,1),"A","B")
      aadd(amohu,ihu->CODE_USL)
    endif
    skip
  enddo
endif
for im := 1 to len(amohu)
  lshifr := alltrim(amohu[im])
  if eq_any(lshifr,"A25.30.014","A25.30.032")
    rule_onko_1[3] := .t.
  endif
  aadd(arr_man,lshifr) // массив хирургических манипуляций
  // собираем в массив все хирургические КСГ
  ar := {}
  select T006
  find ("2"+padr(lshifr,20))
  do while t006->TYPE_KSG==2 .and. t006->NAME==padr(lshifr,20) .and. !eof()
    if lVMP == 1
      if t006->r1 == 1 // ВМП
        for i := 1 to len(arr_c)
          pole := arr_c[i,1]
          if &pole == 1
            s := "121"+arr_c[i,2]+t006->shifr
            select LUSL
            find (padr(s,10))
            if found()
              aadd(ar,{s,0})
            endif
          endif
        next
      endif
    else
      if t006->r0 == 1 // специализированная
        for i := 1 to len(arr_c)
          pole := arr_c[i,1]
          if &pole == 1
            s := "120"+arr_c[i,2]+t006->shifr
            select LUSL
            find (padr(s,10))
            if found()
              aadd(ar,{s,0})
            endif
          endif
        next
      endif
    endif
    select T006
    skip
  enddo
  // обработка по пункту 5 письма 12-20-874
  if eq_any(lshifr,"A16.20.007","A16.20.015","A16.20.024","A16.20.025",;
                   "A16.20.025.001","A16.20.030","A16.20.055","A16.20.023")
    if (i := ascan(ad_ksg_3,{|x| x[1] == osn_diag })) > 0
      k := 3 // значит нужно применить КСГ=3
      t006->(dbGoto(ad_ksg_3[i,2]))
    elseif (i := ascan(ad_ksg_4,{|x| x[1] == osn_diag })) > 0
      k := 4 // значит нужно применить КСГ=4
      t006->(dbGoto(ad_ksg_4[i,2]))
    endif
    if i > 0
      s := "1"+str(t006->TYPE_KSG,1)+iif(lVMP==1,"19","00")+t006->shifr
      // если разрешены КСГ 3 или 4 и цена больше нуля
      if ascan(aTerKSG[1,4],{|x| x[1] == s .and. x[2] > 0 }) > 0
        aadd(ars," т.к. услуга "+lshifr+" и диагноз "+osn_diag+", меняем КСГ="+right(ar[1,1],3)+" на КСГ="+lstr(k))
        ar := {}
      else
        aadd(ars," т.к. для диагноза "+osn_diag+" у Вас закрыт КСГ="+lstr(k)+", оставляем КСГ="+right(ar[1,1],3))
      endif
    endif
  endif
  j := 0
  if len(ar) > 0
    for i := 1 to len(ar)
      ar[i,2] := ret_cena_KSG(ar[i,1],lvr,lk_data)
      if ar[i,2] > 0
        ++j
        fl_cena := .t.
        if eq_any(left(lshifr,4),"A03.","A06.","A07.","A11.","A14.","A16.","A20.","A22.","A24.")
          rule_onko_1[2] := .t.
        endif
        if left(lshifr,4) == "B03."
          rule_onko_2[1] := .t.
        else
          rule_onko_2[2] := .t.
        endif
      endif
    next
    aadd(aHirKSG,{lshifr,mohu->(recno()),j,aclone(ar)})
    i := len(aHirKSG)
    //aadd(ars," aHirKSG["+lstr(i)+"]: "+print_array(aHirKSG[i]))
    f_put_debug_KSG_14(2,aHirKSG,i,ars)
  endif
next
rule_onko_1[1] := (left(osn_diag,1) == "C")
if fl_cena
  if len(aTerKSG) > 0
    if aTerKSG[1,3] == 0 // нет КСГ с ценой
      if len(aTerKSG[1,4]) > 0
        aTerKSG[1,4] := {}
        //aadd(ars," новый aTerKSG - массив КСГ обнулён")
        aadd(ars," ...обработка терапевтических КСГ - шаг 1...")
        f_put_debug_KSG_14(1,aTerKSG,1,ars)
      endif
    elseif len(aTerKSG[1,4]) > 1
      ar := {}
      for i := 1 to len(aTerKSG[1,4])
        if aTerKSG[1,4,i,2] > 0
          aadd(ar,aTerKSG[1,4,i])
        endif
      next
      aTerKSG[1,4] := aclone(ar)
      //aadd(ars," новый aTerKSG: "+print_array(aTerKSG))
      aadd(ars," ...обработка терапевтических КСГ - шаг 2...")
      f_put_debug_KSG_14(1,aTerKSG,1,ars)
    endif
  endif
  if len(aHirKSG) > 0
    aadd(ars," ...обработка хирургических КСГ - шаг 1...")
    for j := len(aHirKSG) to 1 step -1
      if aHirKSG[j,3] == 0 // нет КСГ с ценой
        Del_Array(aHirKSG,j)
      elseif len(aHirKSG[j,4]) > 1
        ar := {}
        for i := 1 to len(aHirKSG[j,4])
          if aHirKSG[j,4,i,2] > 0
            aadd(ar,aHirKSG[j,4,i])
          endif
        next
        aHirKSG[j,4] := aclone(ar)
      endif
    next
    if len(aHirKSG) == 0
      //aadd(ars," новый aHirKSG[] пуст")
      aadd(ars," нет хирургических КСГ")
    else
      //aeval(aHirKSG,{|x,i| aadd(ars," новый aHirKSG["+lstr(i)+"]: "+print_array(x)) })
      aeval(aHirKSG,{|x,i| f_put_debug_KSG_14(2,aHirKSG,i,ars) })
    endif
  endif
  cenaTer := 0
  if aTerKSG[1,3] > 0
    if aTerKSG[1,3] == 1
      cenaTer := aTerKSG[1,4,1,2]
    else
      aadd(ars," ...обработка терапевтических КСГ - шаг 3...")
      Private rule_onko_3 := rule_onko_1[1] .and. !rule_onko_1[2] ;
                              .and. !rule_onko_1[3] .and. !rule_onko_2[1]
      cenaTer := f_TerKSG_1_of_2(aTerKSG,arr_man,lpol,lvr,ldni,ars,arerr)
      //aadd(ars," ещё более новый aTerKSG: "+print_array(aTerKSG))
      f_put_debug_KSG_14(1,aTerKSG,1,ars)
    endif
  endif
  cenaHir := 0 ; ksgHir := ""
  for j := 1 to len(aHirKSG)
    if aHirKSG[j,3] == 1 // один КСГ с ценой
      fl := .f. ; osn_diag3 := left(osn_diag,3)
      if aHirKSG[j,1] == "A16.12.004.009"
        fl := .t.
        if between(osn_diag3,"I21","I22") .or. osn_diag=="I20.0" // 109 I20.0,I21-I22
          fl := .f.
        endif
      elseif aHirKSG[j,1] == "A22.20.004" // 015 C51-C58 Законченный случай госпитализации при проведении операции на женских половых органах (уровень затрат 4)
        fl := .t.
        if between(osn_diag3,"C51","C58")
          fl := .f.
        endif
      elseif aHirKSG[j,1] == "A22.30.019"
        fl := .t.
        if osn_diag3=="C37" .or. eq_any(osn_diag,"C38.1","C38.2","C38.3") // 121 C37,C38.1,C38.2,C38.3
          fl := .f.
        endif
      endif
      if fl
        aadd(arerr,' для манипуляции '+aHirKSG[j,1]+' и КСГ='+aHirKSG[j,4,1,1]+' неверный диагноз '+osn_diag)
        aHirKSG[j,4,1,2] := 0 // обнулим цену
        aHirKSG[j,3] := 0     // обнуляем кол-во КСГ с ценой
      endif
    elseif aHirKSG[j,3] > 1 // два и более КСГ с ценой
      aadd(ars," ...обработка хирургических КСГ - шаг 2...")
      f_HirKSG_1_of_2(aTerKSG,aHirKSG,j,lpol,lvr,ldni,ars,arerr)
      //aadd(ars," ещё более новый aHirKSG["+lstr(j)+"]: "+print_array(aHirKSG[j]))
      f_put_debug_KSG_14(2,aHirKSG,j,ars)
    endif
    if aHirKSG[j,3] > 0 .and. aHirKSG[j,4,1,2] > cenaHir
      ksgHir  := aHirKSG[j,4,1,1]
      cenaHir := aHirKSG[j,4,1,2]
    endif
  next
  if len(aHirKSG) > 1 .and. cenaHir > 0
    aadd(ars," из хирургических КСГ выбрана "+ksgHir+" с максимальной ценой "+lstr(cenaHir,11,2))
  endif
  if cenaHir > 0 .and. !(cenaHir < cenaTer) // не меньше, т.е. >=
    if len(aTerKSG[1,4]) > 0  .and. alltrim(aTerKSG[1,4,1,1]) == "1108201" .and. ;
       rule_onko_1[1] .and. !rule_onko_1[2] .and. !rule_onko_1[3] .and. !rule_onko_2[1]
      lksg  := aTerKSG[1,4,1,1]
      lcena := cenaTer
      aadd(ars," в соответствии с правилом №3 для онкологии от 01.09.14г.")
      aadd(ars,"  выбрана терапевтическая КСГ="+lksg+" с ценой "+lstr(lcena,11,2))
      cenaHir := 0 // обнулим хир.цену
    else
      lksg  := ksgHir
      lcena := cenaHir
    endif
  endif
  if cenaTer > 0 .and. cenaTer > cenaHir
    if rule_onko_1[1] .and. rule_onko_1[2] .and. !rule_onko_1[3]
      lksg  := ksgHir
      lcena := cenaHir
      aadd(ars," т.к. диагноз="+osn_diag+" и нет химиотерапевтического лечения,")
      aadd(ars,"  то оставляем хирургическую КСГ="+ksgHir+" с ценой "+lstr(cenaHir,11,2))
    elseif rule_onko_1[1] .and. rule_onko_2[1] .and. !rule_onko_2[2]
      lksg  := ksgHir
      lcena := cenaHir
      aadd(ars," т.к. проведено комплексное обследование B03.* и установлен диагноз="+osn_diag+",")
      aadd(ars,"  то оставляем хирургическую КСГ="+ksgHir+" с ценой "+lstr(cenaHir,11,2))
    else
      lksg  := aTerKSG[1,4,1,1]
      lcena := cenaTer
      if cenaHir > 0
        aadd(ars," вместо хирургической КСГ="+ksgHir+" с ценой "+lstr(cenaHir,11,2))
        aadd(ars,"  выбрана терапевтическая КСГ="+lksg+" с большей ценой "+lstr(lcena,11,2))
      endif
    endif
  endif
  if lcena > 0 .and. !empty(lksg)
    if right(lksg,3) == "069" .and. ldni > 28
      aadd(arerr," для КСГ="+lksg+" ребёнок должен быть новорожденный <= 28 дней")
      lksg  := ""
      lcena := 0
    endif
  endif
  if lcena > 0 .and. !empty(lksg)
    aadd(ars," РЕЗУЛЬТАТ: выбрана КСГ="+lksg+" с ценой "+lstr(lcena,11,2))
  else
    aadd(arerr," РЕЗУЛЬТАТ: не получилось выбрать КСГ")
  endif
else
  s := " Не удалось определить КСГ"
  if lVMP == 1
    s += " для ВМП"
  endif
  k := 0
  if len(aTerKSG) > 0 .and. len(aTerKSG[1,4]) > 0
    k := 1
  endif
  if len(aHirKSG) > 0 .and. len(aHirKSG[1,4]) > 0
    k := 2
  endif
  if k == 1
    s += " (для "+aTerKSG[1,4,1,1]+" нулевая цена)"
  elseif k == 2
    s += " (для "+aHirKSG[1,4,1,1]+" нулевая цена)"
  endif
  aadd(arerr,s)
endif
return {ars,arerr,lksg,lcena}

*

*****  вывести строку в отладочный массив о КСГ
Function f_put_debug_KSG_14(k,arr,i,ars)
// k = 1 - терапевтическая
// k = 2 - хирургическая
Local s := " ", j, blk_ksg := {|x| "КСГ="+x[1]+"-"+lstr(x[2],11,2)+"р." }
if k == 1
  s += "терапевтическая"
else
  s += "хирургическая"
endif
if len(arr[i,4]) == 0
  s += " КСГ не определена"
else
  if eq_any(k,2,5)
    s := " "+arr[i,1]+" - "+s+" ["+lstr(i)+"]"
  endif
  s += " "
  for j := 1 to len(arr[i,4])
    s += eval(blk_ksg,arr[i,4,j])
    if j < len(arr[i,4])
      s += ", "
    endif
  next
endif
aadd(ars,s)
return NIL*/

*

/***** 22.09.14 вернуть одну терапевтическую КСГ (если их 2 и более)
Function f_TerKSG_1_of_2(aTer,aHir,lpol,lvr,ldni,ta,ea)
// 0039 при стенокардии (кроме нестабильной), хронической ИБС
// 0107 при проведении коронарографии диагностической при ИБС + A06.10.006
Static ar_39_107 := {"I20.1","I20.8","I20.9","I25.0","I25.1","I25.2","I25.3",;
                     "I25.4","I25.5","I25.6","I25.8","I25.9"}
// 0042 при других болезнях сердца
// 0107 при проведении коронарографии диагностической при ИБС + A06.10.006
Static ar_42_107 := {"I24.0","I24.1","I24.8","I24.9"}
// 0033 1 дети
// 0194 0 взрослые
Static ar_33_194 := {"E10.0","E10.1","E10.2","E10.3","E10.4","E10.5","E10.6","E10.7","E10.8","E10.9",;
                     "E11.0","E11.1","E11.2","E11.3","E11.4","E11.5","E11.6","E11.7","E11.8","E11.9",;
                     "E12.0","E12.1","E12.2","E12.3","E12.4","E12.5","E12.6","E12.7","E12.8","E12.9",;
                     "E13.0","E13.1","E13.2","E13.3","E13.4","E13.5","E13.6","E13.7","E13.8","E13.9",;
                     "E14.0","E14.1","E14.2","E14.3","E14.4","E14.5","E14.6","E14.7","E14.8","E14.9",;
                     "R73.0","R73.9","R81"}
// 0031 1 дети     + должно быть A25.30.014
// 0074 0 взрослые + должно быть A25.30.032
Static ar_31_74 := {"C91.0","C92.0","C92.4","C92.5","C93.0","C94.0","C94.2","C95.0"}
// травма - политравма
Static ar_poli := {"J95.1","J95.2","J96.0","N17.0","N17.1","N17.2","N17.8","N17.9","T79.4"}
//
Local osn_diag := aTer[1,1], sop_diag := aTer[1,2], i, j, k, l, fl, lcena
if aTer[1,3] == 2
  // сначала проверим коронарографию - КСГ=107
  if ascan(ar_39_107,osn_diag) > 0 .or. ascan(ar_42_107,osn_diag) > 0
    i := 0
    for j := 1 to 2
      if right(aTer[1,4,j,1],3) == "107"
        i := j ; exit
      endif
    next
    if i == 0 // ошибка
      i := 1 ; j := 2
      aadd(ea,' нет КСГ=107, просто оставляем первую КСГ='+right(aTer[1,4,i,1],3))
      Del_Array(aTer[1,4],j)
    else
      j := iif(i == 1, 2, 1)
      if ascan(aHir,"A06.10.006") > 0
        aadd(ta,' т.к. присутствует коронарография A06.10.006, оставляем КСГ='+right(aTer[1,4,i,1],3))
        Del_Array(aTer[1,4],j)
      else
        aadd(ta,' т.к. отсутствует коронарография A06.10.006, оставляем КСГ='+right(aTer[1,4,j,1],3))
        Del_Array(aTer[1,4],i)
      endif
    endif
  elseif ascan(ar_33_194,osn_diag) > 0
    i := j := 0
    for k := 1 to 2
      if right(aTer[1,4,k,1],3) == "194"
        i := k // взрослый
      elseif right(aTer[1,4,k,1],3) == "033"
        j := k // ребёнок
      endif
    next
    if lvr == 0 // взрослый
      if i == 0
        aadd(ea,' нет КСГ=194 для взрослого '+osn_diag)
      else
        if j > 0
          aadd(ta,' т.к. пациент взрослый, оставляем КСГ='+right(aTer[1,4,i,1],3))
          Del_Array(aTer[1,4],j)
        endif
      endif
    else // ребёнок
      if j == 0
        aadd(ea,' нет КСГ=33 для ребёнка '+osn_diag)
      else
        if i > 0
          aadd(ta,' т.к. пациент ребёнок, оставляем КСГ='+right(aTer[1,4,j,1],3))
          Del_Array(aTer[1,4],i)
        endif
      endif
    endif
  elseif ascan(ar_31_74,osn_diag) > 0
    i := j := l := 0
    for k := 1 to 2
      if right(aTer[1,4,k,1],3) == "074"
        i := k // взрослый
      elseif right(aTer[1,4,k,1],3) == "031"
        j := k // ребёнок
      elseif right(aTer[1,4,k,1],4) == "8201"
        l := k //
      endif
    next
    if lvr == 0 // взрослый
      if i == 0
        aadd(ea,' нет КСГ=74 для взрослого '+osn_diag)
      else
        if j > 0
          aadd(ta,' т.к. пациент взрослый, оставляем КСГ='+right(aTer[1,4,i,1],3))
          Del_Array(aTer[1,4],j)
        endif
        if ascan(aHir,"A25.30.032") > 0
          aadd(ta,' т.к.присутствует манипуляция A25.30.032, оставляем КСГ=74')
          j := iif(i == 1, 2, 1)
          Del_Array(aTer[1,4],j)
        elseif l > 0
          aadd(ta,' т.к.нет манипуляции A25.30.032, оставляем КСГ=1108201')
          Del_Array(aTer[1,4],i)
        else
          aadd(ea,' ошибка для КСГ=74 и т.д.')
        endif
      endif
    else // ребёнок
      if j == 0
        aadd(ea,' нет КСГ=31 для ребёнка '+osn_diag)
      else
        if i > 0
          aadd(ta,' т.к. пациент ребёнок, оставляем КСГ='+right(aTer[1,4,j,1],3))
          Del_Array(aTer[1,4],i)
        endif
        if ascan(aHir,"A25.30.014") > 0
          aadd(ta,' т.к.присутствует манипуляция A25.30.014, оставляем КСГ=31')
          i := iif(j == 1, 2, 1)
          Del_Array(aTer[1,4],i)
        elseif l > 0
          aadd(ta,' т.к.нет манипуляции A25.30.014, оставляем КСГ=1108201')
          Del_Array(aTer[1,4],j)
        else
          aadd(ea,' ошибка для КСГ=31 и т.д.')
        endif
      endif
    endif
  elseif eq_any(left(osn_diag,5),"S30.2","T19.8")
    i := j := 0
    for k := 1 to 2
      if right(aTer[1,4,k,1],3) == "137"
        i := k // мужчина
      elseif right(aTer[1,4,k,1],3) == "008"
        j := k // женщина
      endif
    next
    if lpol == "М" // мужчина
      if i == 0
        aadd(ea,' нет КСГ=137 для мужчины '+osn_diag)
      else
        if j > 0
          aadd(ta,' т.к. пациент мужчина, оставляем КСГ='+right(aTer[1,4,i,1],3))
          Del_Array(aTer[1,4],j)
        endif
      endif
    else // женщина
      if j == 0
        aadd(ea,' нет КСГ=8 для женщины '+osn_diag)
      else
        if i > 0
          aadd(ta,' т.к. пациент женщина, оставляем КСГ='+right(aTer[1,4,j,1],3))
          Del_Array(aTer[1,4],i)
        endif
      endif
    endif
  elseif eq_any(left(osn_diag,5),"S38.0","S38.2")
    i := j := 0
    for k := 1 to 2
      if right(aTer[1,4,k,1],3) == "126"
        i := k // мужчина
      elseif right(aTer[1,4,k,1],3) == "008"
        j := k // женщина
      endif
    next
    if lpol == "М" // мужчина
      if i == 0
        aadd(ea,' нет КСГ=126 для мужчины '+osn_diag)
      else
        if j > 0
          aadd(ta,' т.к. пациент мужчина, оставляем КСГ='+right(aTer[1,4,i,1],3))
          Del_Array(aTer[1,4],j)
        endif
      endif
    else // женщина
      if j == 0
        aadd(ea,' нет КСГ=8 для женщины '+osn_diag)
      else
        if i > 0
          aadd(ta,' т.к. пациент женщина, оставляем КСГ='+right(aTer[1,4,j,1],3))
          Del_Array(aTer[1,4],i)
        endif
      endif
    endif
  elseif ascan(ar_poli,osn_diag) > 0
    i := 0
    for k := 1 to 2
      if right(aTer[1,4,k,1],3) == "127"
        i := k ; exit // политравма
      endif
    next
    if i == 0
      aadd(ea,' нет КСГ=127 (политравма) для '+osn_diag)
    else
      j := iif(i == 1, 2, 1)
      if !empty(sop_diag) .and. eq_any(left(sop_diag,1),"S","T") // сопут.травма
        aadd(ta,' т.к. пациент сопут.диагноз травма '+sop_diag+', оставляем КСГ='+right(aTer[1,4,i,1],4))
        Del_Array(aTer[1,4],j)
      else
        aadd(ta,' т.к. '+iif(empty(sop_diag), 'нет сопут.диагноза', 'сопут.диагноз не травма '+sop_diag)+;
                ', оставляем КСГ='+right(aTer[1,4,j,1],3))
        Del_Array(aTer[1,4],i)
      endif
    endif
  else
    if rule_onko_3 .and. (k := ascan(aTer[1,4], {|x| x[1] == "1108201"})) > 0
      lcena := aTer[1,4,k,2] ; j := k
      aadd(ta," в соответствии с правилом №3 для онкологии от 01.09.14г.")
      aadd(ta,"  из терапевтических КСГ выбрана "+aTer[1,4,j,1]+" с ценой "+lstr(aTer[1,4,j,2],11,2))
      i := iif(j == 1, 2, 1)
      Del_Array(aTer[1,4],i)
    else
      lcena := j := 0
      for k := 1 to 2
        if aTer[1,4,k,2] > lcena
          lcena := aTer[1,4,k,2] ; j := k
        endif
      next
      if j > 0 .and. lcena > 0
        aadd(ta," из терапевтических КСГ выбрана "+aTer[1,4,j,1]+" с максимальной ценой "+lstr(aTer[1,4,j,2],11,2))
        i := iif(j == 1, 2, 1)
        Del_Array(aTer[1,4],i)
      else
        aadd(ea,' не удалось найти правило для двух терапевтических КСГ')
      endif
    endif
  endif
else
  aadd(ea,' более двух терапевтических КСГ')
endif
aTer[1,3] := len(aTer[1,4])
return iif(aTer[1,3]==0, 0, aTer[1,4,1,2])*/

*

/***** 22.01.14 вернуть одну хирургическую КСГ (если их 2 и более)
Function f_HirKSG_1_of_2(aTer,aHir,jh,lpol,lvr,ldni,ta,ea)
Local osn_diag, sop_diag, osn_diag3, i, j, k, fl, lksg := ""
osn_diag := aTer[1,1]
sop_diag := aTer[1,2]
osn_diag3 := left(osn_diag,3)
if aHir[jh,1] == "A16.20.079"
  i := j := 0
  for k := 1 to 2
    if right(aHir[jh,4,k,1],3) == "011"
      i := k // аборт
    elseif right(aHir[jh,4,k,1],3) == "012"
      j := k //
    endif
  next
  if left(osn_diag,3) == "O04"
    if i == 0
      aadd(ea,' нет КСГ=11 для A16.20.079 + '+osn_diag)
    else
      aadd(ta,' т.к. диагноз '+osn_diag+', оставляем КСГ='+right(aHir[jh,4,i,1],3))
      Del_Array(aHir[jh,4],j)
    endif
  else // остальные
    if j == 0
      aadd(ea,' нет КСГ=12 для A16.20.079')
    else
      aadd(ta,' т.к. диагноз не "O04", оставляем КСГ='+right(aHir[jh,4,j,1],3))
      Del_Array(aHir[jh,4],i)
    endif
  endif
elseif aHir[jh,1] == "A16.24.006.001"
  i := j := 0
  for k := 1 to 2
    if right(aHir[jh,4,k,1],3) == "087"
      i := k // ЛОР
    elseif right(aHir[jh,4,k,1],3) == "065"
      j := k //
    endif
  next
  if left(osn_diag,3) == "H81"
    if i == 0
      aadd(ea,' нет КСГ=87 для A16.24.006.001 + '+osn_diag)
    else
      aadd(ta,' т.к. диагноз '+osn_diag+', оставляем КСГ='+right(aHir[jh,4,i,1],3))
      Del_Array(aHir[jh,4],j)
    endif
  else // остальные
    if j == 0
      aadd(ea,' нет КСГ=65 для A16.24.006.001')
    else
      aadd(ta,' т.к. диагноз не "H81", оставляем КСГ='+right(aHir[jh,4,j,1],3))
      Del_Array(aHir[jh,4],i)
    endif
  endif
elseif eq_any(aHir[jh,1],"A16.20.042","A16.20.042.001")
  i := j := 0
  for k := 1 to 2
    if right(aHir[jh,4,k,1],3) == "145"
      i := k // мужчины
    elseif right(aHir[jh,4,k,1],3) == "015"
      j := k // женщины
    endif
  next
  if lpol == "М"
    if i == 0
      aadd(ea,' нет КСГ=145 для мужчины')
    else
      aadd(ta,' т.к. пациент мужчина, оставляем КСГ='+right(aHir[jh,4,i,1],3))
      Del_Array(aHir[jh,4],j)
    endif
  else // остальные
    if j == 0
      aadd(ea,' нет КСГ=15 для женщины')
    else
      aadd(ta,' т.к. пациент женщина, оставляем КСГ='+right(aHir[jh,4,j,1],3))
      Del_Array(aHir[jh,4],i)
    endif
  endif
elseif aHir[jh,1] == "A07.30.008"
  if between(osn_diag3,"C18","C21")
    lksg := "046" // C18-C21       Законченный случай госпитализации при проведении операции на кишечнике и анальной области (уровень затрат 4)
  elseif between(osn_diag3,"C40","C41")
    lksg := "131" // C40-C41       Законченный случай госпитализации при проведении операции на костно-мышечной системе и суставах (уровень затрат 4)
  elseif between(osn_diag3,"C43","C49")
    lksg := "152" // C43-C49       Законченный случай госпитализации при проведении операции на коже, подкожной клетчатке, придатках кожи (уровень затрат 5)
  elseif between(osn_diag3,"C73","C75")
    lksg := "157" // C73-C75       Законченный случай госпитализации при проведении операции на эндокринных железах кроме гипофиза (уровень затрат 4)
  elseif osn_diag3 == "C50"
    lksg := "168" // C50           Законченный случай госпитализации при проведении операции на молочной железе (уровень затрат 4)
  elseif osn_diag3 == "C25"
    lksg := "173" // C25           Законченный случай госпитализации при проведении операции на печени и поджелудочной железе (уровень затрат 4)
  elseif eq_any(osn_diag3,"C15","C16") .or. osn_diag == "C17.0"
    lksg := "177" // C15,C16,C17.0 Законченный случай госпитализации при проведении операции на пищеводе, желудке, двенадцатиперстной кишке (уровень затрат 4)
  endif
  f1_HirKSG_1_of_2(lksg,aTer,aHir,jh,lpol,lvr,ldni,ta,ea)
elseif aHir[jh,1] == "A16.12.051"
  if between(osn_diag3,"C51","C58")
    lksg := "015" // C51-C58       Законченный случай госпитализации при проведении операции на женских половых органах (уровень затрат 4)
  elseif osn_diag == "C49.3"
    lksg := "121" // C49.3         Законченный случай госпитализации при проведении операции на нижних дыхательных путях и легочной ткани, органах средостения (уровень затрат 5)
  elseif between(osn_diag3,"C43","C47") .or. osn_diag3 == "C49"
    lksg := "152" // C43-C47,C49   Законченный случай госпитализации при проведении операции на коже, подкожной клетчатке, придатках кожи (уровень затрат 5)
  elseif between(osn_diag3,"C40","C41")
    lksg := "131" // C40-C41       Законченный случай госпитализации при проведении операции на костно-мышечной системе и суставах (уровень затрат 4)
  elseif between(osn_diag3,"C73","C75")
    lksg := "157" // C73-C75       Законченный случай госпитализации при проведении операции на эндокринных железах кроме гипофиза (уровень затрат 4)
  elseif between(osn_diag3,"C22","C24")
    lksg := "173" // C22-C24       Законченный случай госпитализации при проведении операции на печени и поджелудочной железе (уровень затрат 4)
  elseif osn_diag3 == "C48"
    lksg := "184" // C48           Законченный случай госпитализации при проведении других операций на органах брюшной полости (уровень затрат 4)
  endif
  f1_HirKSG_1_of_2(lksg,aTer,aHir,jh,lpol,lvr,ldni,ta,ea)
elseif aHir[jh,1] == "A16.30.053"
  if between(osn_diag3,"C51","C58")
    lksg := "015" // C51-C58       Законченный случай госпитализации при проведении операции на женских половых органах (уровень затрат 4)
  elseif between(osn_diag3,"C18","C21")
    lksg := "046" // C18-C21       Законченный случай госпитализации при проведении операции на кишечнике и анальной области (уровень затрат 4)
  elseif between(osn_diag3,"C22","C24")
    lksg := "173" // C22-C24       Законченный случай госпитализации при проведении операции на печени и поджелудочной железе (уровень затрат 4)
  elseif eq_any(osn_diag3,"C15","C16") .or. osn_diag == "C17.0"
    lksg := "177" // C15,C16,C17.0 Законченный случай госпитализации при проведении операции на пищеводе, желудке, двенадцатиперстной кишке (уровень затрат 4)
  elseif osn_diag3 == "C48"
    lksg := "184" // C48           Законченный случай госпитализации при проведении других операций на органах брюшной полости (уровень затрат 4)
  endif
  f1_HirKSG_1_of_2(lksg,aTer,aHir,jh,lpol,lvr,ldni,ta,ea)
elseif aHir[jh,1] == "A16.30.054"
  if between(osn_diag3,"C30","C33")
    lksg := "088" // C30-C33       Законченный случай госпитализации при проведении операции на органе слуха, придаточных пазухах носа и верхних дыхательных путях (уровень затрат 5)
  elseif osn_diag3 == "C48"
    lksg := "184" // C48           Законченный случай госпитализации при проведении других операций на органах брюшной полости (уровень затрат 4)
  endif
  f1_HirKSG_1_of_2(lksg,aTer,aHir,jh,lpol,lvr,ldni,ta,ea)
elseif aHir[jh,1] == "A16.30.055"
  if between(osn_diag3,"C51","C58")
    lksg := "015" // C51-C58       Законченный случай госпитализации при проведении операции на женских половых органах (уровень затрат 4)
  elseif between(osn_diag3,"C18","C21")
    lksg := "046" // C18-C21       Законченный случай госпитализации при проведении операции на кишечнике и анальной области (уровень затрат 4)
  elseif between(osn_diag3,"C30","C33")
    lksg := "088" // C30-C33       Законченный случай госпитализации при проведении операции на органе слуха, придаточных пазухах носа и верхних дыхательных путях (уровень затрат 5)
  elseif between(osn_diag3,"C40","C41")
    lksg := "131" // C40-C41       Законченный случай госпитализации при проведении операции на костно-мышечной системе и суставах (уровень затрат 4)
  elseif between(osn_diag3,"C64","C68")
    lksg := "145" // C64-C68       Законченный случай госпитализации при проведении операции на почке и мочевыделительной системе (уровень затрат 4)
  elseif between(osn_diag3,"C43","C47") .or. osn_diag3 == "C49"
    lksg := "152" // C43-C47,C49   Законченный случай госпитализации при проведении операции на коже, подкожной клетчатке, придатках кожи (уровень затрат 5)
  elseif eq_any(osn_diag3,"C15","C16") .or. osn_diag == "C17.0"
    lksg := "177" // C15,C16,C17.0 Законченный случай госпитализации при проведении операции на пищеводе, желудке, двенадцатиперстной кишке (уровень затрат 4)
  elseif osn_diag3 == "C48"
    lksg := "184" // C48           Законченный случай госпитализации при проведении других операций на органах брюшной полости (уровень затрат 4)
  endif
  f1_HirKSG_1_of_2(lksg,aTer,aHir,jh,lpol,lvr,ldni,ta,ea)
elseif eq_any(aHir[jh,1],"A22.30.016","A22.30.017","A22.30.018",;
                         "A22.30.020.001","A22.30.023")
  if between(osn_diag3,"C18","C21")
    lksg := "046" // C18-C21       Законченный случай госпитализации при проведении операции на кишечнике и анальной области (уровень затрат 4)
  elseif between(osn_diag3,"C30","C33")
    lksg := "088" // C30-C33       Законченный случай госпитализации при проведении операции на органе слуха, придаточных пазухах носа и верхних дыхательных путях (уровень затрат 5)
  elseif eq_any(osn_diag3,"C15","C16") .or. osn_diag == "C17.0"
    lksg := "177" // C15,C16,C17.0 Законченный случай госпитализации при проведении операции на пищеводе, желудке, двенадцатиперстной кишке (уровень затрат 4)
  endif
  f1_HirKSG_1_of_2(lksg,aTer,aHir,jh,lpol,lvr,ldni,ta,ea)
elseif aHir[jh,1] == "A22.30.022"
  if between(osn_diag3,"C40","C41")
    lksg := "131" // C40-C41       Законченный случай госпитализации при проведении операции на костно-мышечной системе и суставах (уровень затрат 4)
  elseif osn_diag3 == "C50"
    lksg := "168" // C50           Законченный случай госпитализации при проведении операции на молочной железе (уровень затрат 4)
  elseif between(osn_diag3,"C22","C25")
    lksg := "173" // C22-C25       Законченный случай госпитализации при проведении операции на печени и поджелудочной железе (уровень затрат 4)
  elseif osn_diag3 == "C48"
    lksg := "184" // C48           Законченный случай госпитализации при проведении других операций на органах брюшной полости (уровень затрат 4)
  endif
  f1_HirKSG_1_of_2(lksg,aTer,aHir,jh,lpol,lvr,ldni,ta,ea)
elseif aHir[jh,3] == 2 .and. (i := ascan(aHir[jh,4], {|x| right(x[1],3)=='032' })) > 0
  j := iif(i==1, 2, 1)
  if ldni <= 28
    aadd(ta,' т.к. возраст <= 28 ('+lstr(ldni)+') дн., оставляем КСГ='+right(aHir[jh,4,i,1],3))
    Del_Array(aHir[jh,4],j)
  else
    aadd(ta,' т.к. возраст > 28 ('+lstr(ldni)+') дн., оставляем КСГ='+right(aHir[jh,4,j,1],3))
    Del_Array(aHir[jh,4],i)
  endif
else
  aadd(ea,' не удалось найти правило для нескольких хирургических КСГ')
endif
aHir[jh,3] := len(aHir[jh,4])
return NIL

***** 22.01.14 оставить одну хирургическую КСГ (или ни одной)
Function f1_HirKSG_1_of_2(lksg,aTer,aHir,jh,lpol,lvr,ldni,ta,ea)
Local i, ar := {}
if !empty(lksg)
  for i := 1 to len(aHir[jh,4])
    if right(aHir[jh,4,i,1],3) == lksg
      aadd(ar,aHir[jh,4,i]) ; exit
    endif
  next
  aHir[jh,4] := aclone(ar)
  if !empty(ar)
    aadd(ea,' для манипуляции '+aHir[jh,1]+' и диагноза '+aTer[1,1]+' выбрана КСГ='+aHir[jh,4,1,1])
  endif
endif
if empty(ar)
  aadd(ea,' для манипуляции '+aHir[jh,1]+' и диагноза '+aTer[1,1]+' не найдена КСГ')
endif
return NIL*/

*

/***** 28.08.15 определение КСГ по остальным введённым полям ввода
Function definition_KSG_15(par)
// файлы "human", "human_" и "human_2" открыты и стоят на нужной записи
//       "human" открыт для записи суммы случая
// выполнено use_base("human_u","HU") - для записи
// выполнено use_base("mo_hu","MOHU") - для записи
Static ad_ksg_3, ad_ksg_4
Static sp0, sp1, sp6, sp15
Static a_iskl_1 := {; // исключение из правил №1
  {  7, 13},;
  {  7, 14},;
  {  8, 13},;
  { 22, 64},;
  { 81,193},;
  { 81,196},;
  {143,138},;
  {166,245},;
  {244,245},;
  {200, 37},;
  {226,211};
 }
Local mdiagnoz, aHirKSG := {}, aTerKSG := {}, fl_cena := .f., lvmp, lvidvmp := 0,;
      i, j, k, s, ar, fl, im, lshifr, ln_data, lk_data, lvr, ldni, ldate_r, lpol,;
      lfio, lrslt, cenaTer := 0, cenaHir := 0, ksgHir, ars := {}, arerr := {}, ;
      lksg := "", lcena := 0, osn_diag3, lprofil, ldnej := 0,;
      osn_diag := space(6), sop_diag := {}, osl_diag := {}, tmp,;
      kol_ter := 0, kol_hir := 0, lkoef, fl_reabil, fl_dop_ob_em := .f.,;
      ahu := {}, amohu := {}, date_usl := stod("20151231")
DEFAULT par TO 1, sp0 TO "", sp1 TO space(1), sp6 TO space(6), sp15 TO space(20)
Private pole
if par == 1
  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  if (lvmp := human_2->VMP) == 1
    lvidvmp := human_2->METVMP
  endif
  lfio    := alltrim(human->fio)
  ln_data := human->n_data
  lk_data := human->k_data
  if is_dop_ob_em
    fl_dop_ob_em := (human->reg_lech == 9)
  endif
  lrslt   := human_->RSLT_NEW
  lusl    := lstr(human_->USL_OK)
  ldate_r := iif(human_->NOVOR > 0, human_->date_r2, human->date_r)
  lpol    := iif(human_->NOVOR > 0, human_->pol2,    human->pol)
  lvr     := iif(human->VZROS_REB==0, 0, 1) // 0-взрослый, 1-ребенок
  ldni    := human->n_data - ldate_r // для ребёнка возраст в днях
  lprofil := human_->profil
  // массив диагнозов (минимум два)
  mdiagnoz := diag_to_array(,,,,.t.)
  if len(mdiagnoz) > 0
    osn_diag := mdiagnoz[1]
    if len(mdiagnoz) > 1
      sop_diag := aclone(mdiagnoz)
      Del_Array(sop_diag,1) // начиная со 2-го - сопутствующие диагнозы
    endif
  endif
  if !empty(human_2->OSL1)
    aadd(osl_diag,human_2->OSL1)
  endif
  if !empty(human_2->OSL2)
    aadd(osl_diag,human_2->OSL2)
  endif
  if !empty(human_2->OSL3)
    aadd(osl_diag,human_2->OSL3)
  endif
else // из режима импорта случаев
  if (lvmp := iif(empty(ihuman->VID_HMP), 0, 1)) == 1
    lvidvmp := ihuman->METOD_HMP
  endif
  lusl    := lstr(ihuman->USL_OK)
  lfio    := alltrim(ihuman->fio)
  ln_data := ihuman->date_1
  lk_data := ihuman->date_2
  lrslt   := ihuman->RSLT
  ldate_r := iif(ihuman->NOVOR > 0, ihuman->reb_dr,  ihuman->dr)
  lpol    := iif(ihuman->NOVOR > 0, ihuman->reb_pol, ihuman->w)
  lpol    := iif(lpol == 1, "М","Ж")
  lvr     := iif(m1VZROS_REB==0, 0, 1) // 0-взрослый, 1-ребенок
  ldni    := ihuman->date_1 - ldate_r // для ребёнка возраст в днях
  lprofil := ihuman->profil
  osn_diag := padr(ihuman->DS1,6)
  if !empty(ihuman->DS2)
    aadd(sop_diag, padr(ihuman->DS2,6))
  endif
  if !empty(ihuman->DS2_2)
    aadd(sop_diag, padr(ihuman->DS2_2,6))
  endif
  if !empty(ihuman->DS2_3)
    aadd(sop_diag, padr(ihuman->DS2_3,6))
  endif
  if !empty(ihuman->DS2_4)
    aadd(sop_diag, padr(ihuman->DS2_4,6))
  endif
  if !empty(ihuman->DS2_5)
    aadd(sop_diag, padr(ihuman->DS2_5,6))
  endif
  if !empty(ihuman->DS2_6)
    aadd(sop_diag, padr(ihuman->DS2_6,6))
  endif
  if !empty(ihuman->DS2_7)
    aadd(sop_diag, padr(ihuman->DS2_7,6))
  endif
  if !empty(ihuman->DS3)
    aadd(osl_diag, padr(ihuman->DS3,6))
  endif
  if !empty(ihuman->DS3_2)
    aadd(osl_diag, padr(ihuman->DS3_2,6))
  endif
  if !empty(ihuman->DS3_3)
    aadd(osl_diag, padr(ihuman->DS3_3,6))
  endif
endif
date_usl := lk_data //!!!!!!!!!!!!раскомментировать после теста!!!!!!!!!!!!!!!
if lusl == '1'
  if (ldnej := lk_data - ln_data) == 0
    ldnej := 1
  endif
else
  lrslt := 0
endif
aadd(ars,lfio+" "+date_8(ln_data)+"-"+date_8(lk_data)+" ("+lstr(ldnej)+"дн.) "+;
         inieditspr(A__MENUVERT, glob_V009, lrslt))
s := iif(lVMP==1,'ВМП ',' ')
if par == 1
  s += alltrim(uch->name)+'/'+alltrim(otd->name)+'/'
endif
s += 'профиль "'+inieditspr(A__MENUVERT, glob_V002, lprofil)+'"'
aadd(ars,s)
aadd(ars,' д.р.'+full_date(ldate_r)+iif(lvr==0,'(взр.','(реб.')+'), '+iif(lpol=='М','муж.','жен.')+;
         ', осн.диаг.'+osn_diag+;
         iif(empty(sop_diag), '', ', соп.диаг.'+charrem(' ',print_array(sop_diag)))+;
         iif(empty(osl_diag), '', ', диаг.осл.'+charrem(' ',print_array(osl_diag))))
if empty(osn_diag)
  aadd(arerr,' не введён основной диагноз')
  return {ars,arerr,lksg,lcena}
endif
if lvmp > 0
  if lvidvmp == 0
    aadd(arerr,' не введён метод ВМП')
  elseif ascan(arr_12_VMP,lvidvmp) == 0
    aadd(arerr,' для метода ВМП '+lstr(lvidvmp)+' нет услуги ТФОМС')
  else
    lksg := "1.12."+lstr(lvidvmp)
    aadd(ars," для "+lstr(lvidvmp)+" метода ВМП введена услуга "+lksg)
    lcena := ret_cena_KSG(lksg,lvr,date_usl)
    if lcena > 0
      aadd(ars," РЕЗУЛЬТАТ: выбрана услуга="+lksg+" с ценой "+lstr(lcena,11,2))
    else
      aadd(arerr,' для Вашей МО в справочнике ТФОМС не найдена услуга: '+lksg)
    endif
  endif
  return {ars,arerr,alltrim(lksg),lcena}
endif
// составляем массив услуг и массив манипуляций
if par == 1
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    usl->(dbGoto(hu->u_kod))
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,date_usl))
      lshifr := usl->shifr
    endif
    lshifr := alltrim(lshifr)
    if ascan(ahu,lshifr) == 0
      aadd(ahu,lshifr)
    endif
    if lusl == '2' .and. left(lshifr,5)=='55.1.'
      ldnej += hu->kol_1
    endif
    select HU
    skip
  enddo
  if select("MOSU") == 0
    R_Use(dir_server+"mo_su",,"MOSU")
  endif
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    if mosu->(recno()) != mohu->u_kod
      mosu->(dbGoto(mohu->u_kod))
    endif
    if ascan(amohu,mosu->shifr1) == 0
      aadd(amohu,mosu->shifr1)
    endif
    select MOHU
    skip
  enddo
else
  select IHU
  find (str(ihuman->kod,10))
  do while ihu->kod == ihuman->kod .and. !eof()
    if eq_any(left(ihu->CODE_USL,1),"A","B")
      if ascan(amohu,ihu->CODE_USL)==0
        aadd(amohu,ihu->CODE_USL)
      endif
    else
      if ascan(ahu,alltrim(ihu->CODE_USL)) == 0
        aadd(ahu,alltrim(ihu->CODE_USL))
      endif
      if lusl == '2' .and. left(ihu->CODE_USL,5)=='55.1.'
        ldnej += ihu->KOL_USL
      endif
    endif
    skip
  enddo
endif
if lvr == 0 // '3'-дети, '4'-взрослые
  lage := '4'
  s := "взр."
else
  lage := '3'
  s := "дети"
  if ldni < 90
    lage += '2' // дети до 90 дней
    s := "< 90дн."
  endif
  if ldni < 28
    lage += '1' // дети до 28 дней
    s := "< 28дн."
  endif
endif
ars[1] := lfio+" "+date_8(ln_data)+"-"+date_8(lk_data)+" ("+lstr(ldnej)+"дн.) "+;
          inieditspr(A__MENUVERT, glob_V009, lrslt)
ars[3] := ' д.р.'+full_date(ldate_r)+'('+s+'), '+iif(lpol=='М','муж.','жен.')+;
          ', осн.диаг.'+osn_diag+;
          iif(empty(sop_diag), '', ', соп.диаг.'+charrem(' ',print_array(sop_diag)))+;
          iif(empty(osl_diag), '', ', диаг.осл.'+charrem(' ',print_array(osl_diag)))
lrslt := lstr(lrslt)
if len(lrslt) != 3
  lrslt := "***"
endif
lsex := iif(lpol=='М','1','2')
llos := ''
if ldnej > 2
  llos += '1'
endif
if ldnej < 5
  llos += '2'
endif
if ldnej < 4
  llos += '3'
else
  llos += '4'
endif
//aadd(ars,'   ║age='+lage+' sex='+lsex+' los='+llos)
if select("K006") == 0
  R_Use(exe_dir+"_mo5k006",{cur_dir+"_mo5k006",cur_dir+"_mo5k006_"},"K006")
    {"SHIFR",      "C",     10,      0},;
    {"DS",         "C",      6,      0},;
    {"DS1",        "M",     10,      0},;
    {"DS2",        "M",     10,      0},;
    {"SY",         "C",     20,      0},;
    {"AGE",        "C",      1,      0},;
    {"SEX",        "C",      1,      0},;
    {"LOS",        "C",      1,      0},;
  //index on substr(shifr,1,1)+ds+sy to (sbase)      // по диагнозу/операции
  //index on substr(shifr,1,1)+sy+ds to (sbase+"_")  // по операции/диагнозу
endif
if select("T006") == 0
  R_Use(exe_dir+"_mo5t006",cur_dir+"_mo5t006","T006")
  //index on substr(shifr,1,1)+NAME to (sbase)  // по диагнозу или операции
endif
fl_reabil := (ascan(ahu,"1.11.2") > 0 .or. ascan(ahu,"55.1.4") > 0)
// собираем КСГ по осн.диагнозу (терапевтические и комбинированные)
ar := {}
select T006
find (lusl+padr(osn_diag,20))
do while left(t006->shifr,1)==lusl .and. t006->NAME==padr(osn_diag,20) .and. !eof()
  lkoef := iif(lvr==0, t006->kzv, t006->kzd)
  if lkoef > 0 .and. ;
     iif(fl_reabil, substr(t006->shifr,3,1)=='2', substr(t006->shifr,3,1)!='2')
    select LUSL
    find (padr(t006->shifr,10))
    if between_date(lusl->DATEBEG,lusl->DATEEND,date_usl) .and. iif(fl_dop_ob_em,lusl->bukva=="N",!(lusl->bukva=="N"))
      aadd(ar,{t006->shifr,0,lkoef,t006->profil,osn_diag,sp15,sp1,sp1,sp1,sp1,sp0,sp0,0})
    endif
  endif
  select T006
  skip
enddo
tmp := {}
select K006
set order to 1
find (lusl+padr(osn_diag,6))
do while left(k006->shifr,1)==lusl .and. k006->ds==padr(osn_diag,6) .and. !eof()
  lkoef := iif(lvr==0, k006->kzv, k006->kzd)
  select LUSL
  find (padr(k006->shifr,10))
  fl := lkoef > 0 .and. ;
        between_date(lusl->DATEBEG,lusl->DATEEND,date_usl) .and. ;
        iif(fl_dop_ob_em,lusl->bukva=="N",!(lusl->bukva=="N")) .and. ;
        iif(fl_reabil, substr(k006->shifr,3,1)=='2', substr(k006->shifr,3,1)!='2')
  sds1 := iif(empty(k006->ds1), sp0, alltrim(k006->ds1)+sp6) // соп.диагноз
  sds2 := iif(empty(k006->ds2), sp0, alltrim(k006->ds2)+sp6) // диагн.осложнения
  j := 0
  if fl .and. !empty(k006->sy)
    if (i := ascan(amohu,k006->sy)) > 0
      aadd(tmp,i)
      j += 10
    else
      fl := .f.
    endif
  endif
  if fl .and. !empty(k006->age)
    if (fl := (k006->age $ lage))
      if k006->age == '1'
        j += 5
      elseif k006->age == '2'
        j += 2
      else
        j ++
      endif
    endif
  endif
  if fl .and. !empty(k006->sex)
    fl := (k006->sex == lsex)
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(k006->los)
    fl := (k006->los $ llos)
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(k006->rslt)
    fl := (lrslt $ k006->rslt)
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(sds1)
    fl := .f.
    for i := 1 to len(sop_diag)
      if sop_diag[i] $ sds1
        fl := .t. ; exit
      endif
    next
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(sds2)
    fl := .f.
    for i := 1 to len(osl_diag)
      if osl_diag[i] $ sds2
        fl := .t. ; exit
      endif
    next
    if fl ; j ++ ; endif
  endif
  if fl
    aadd(ar,{k006->shifr,0,lkoef,k006->profil,osn_diag,k006->sy,k006->age,k006->sex,k006->los,k006->rslt,sds1,sds2,j})
  endif
  select K006
  skip
enddo
if len(ar) > 0
  for i := 1 to len(tmp)
    im := tmp[i]
    amohu[im] := "" // очистить, чтобы не включать в хирургическую КСГ
  next
  for i := 1 to len(ar)
    ar[i,2] := ret_cena_KSG(ar[i,1],lvr,date_usl)
    if ar[i,2] > 0
      fl_cena := .t.
    endif
  next
  aTerKSG := aclone(ar)
  if len(aTerKSG) > 1
    asort(aTerKSG,,,{|x,y| iif(x[13]==y[13], x[3] > y[3], x[13] > y[13]) })
  endif
    aadd(ars,"   ║тер.КСГ: "+print_array(aTerKSG[1]))
  for j := 2 to len(aTerKSG)
    aadd(ars,"   ║"+space(9)+print_array(aTerKSG[j]))
  next
  if (kol_ter := f_put_debug_KSG(1,aTerKSG,ars)) > 1
    aadd(ars," └─> выбираем терап.КСГ="+aTerKSG[1,1]+" [КЗ="+lstr(aTerKSG[1,3])+"]")
  endif
endif
// собираем КСГ по манипуляциям (хирургические и комбинированные)
ar := {}
for im := 1 to len(amohu)
  if !empty(lshifr := alltrim(amohu[im]))
    select T006
    find (lusl+padr(lshifr,20))
    do while left(t006->shifr,1)==lusl .and. t006->NAME==padr(lshifr,20) .and. !eof()
      lkoef := iif(lvr==0, t006->kzv, t006->kzd)
      if lkoef > 0 .and. iif(fl_reabil, substr(t006->shifr,3,1)=='2', substr(t006->shifr,3,1)!='2')
        select LUSL
        find (padr(t006->shifr,10))
        if between_date(lusl->DATEBEG,lusl->DATEEND,date_usl) .and. ;
                    iif(fl_dop_ob_em,lusl->bukva=="N",!(lusl->bukva=="N"))
          aadd(ar,{t006->shifr,0,lkoef,t006->profil,sp6,lshifr,sp1,sp1,sp1,sp1,sp0,sp0,0})
        endif
      endif
      select T006
      skip
    enddo
    select K006
    set order to 2
    find (lusl+padr(lshifr,20))
    do while left(k006->shifr,1)==lusl .and. k006->sy==padr(lshifr,20) .and. !eof()
      lkoef := iif(lvr==0, k006->kzv, k006->kzd)
      select LUSL
      find (padr(k006->shifr,10))
      fl := lkoef > 0 .and. ;
            between_date(lusl->DATEBEG,lusl->DATEEND,date_usl) .and. ;
            iif(fl_dop_ob_em,lusl->bukva=="N",!(lusl->bukva=="N")) .and. ;
            iif(fl_reabil, substr(k006->shifr,3,1)=='2', substr(k006->shifr,3,1)!='2')
      sds1 := iif(empty(k006->ds1), sp0, alltrim(k006->ds1)+sp6) // соп.диагноз
      sds2 := iif(empty(k006->ds2), sp0, alltrim(k006->ds2)+sp6) // диагн.осложнения
      j := 0
      if fl .and. !empty(k006->ds)
        fl := (k006->ds == osn_diag)
        if fl ; j += 10 ; endif
      endif
      if fl .and. !empty(k006->age)
        if (fl := (k006->age $ lage))
          if k006->age == '1'
            j += 5
          elseif k006->age == '2'
            j += 2
          else
            j ++
          endif
        endif
      endif
      if fl .and. !empty(k006->sex)
        fl := (k006->sex == lsex)
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(k006->los)
        fl := (k006->los $ llos)
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(k006->rslt)
        fl := (lrslt $ k006->rslt)
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(sds1)
        fl := .f.
        for i := 1 to len(sop_diag)
          if sop_diag[i] $ sds1
            fl := .t. ; exit
          endif
        next
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(sds2)
        fl := .f.
        for i := 1 to len(osl_diag)
          if osl_diag[i] $ sds2
            fl := .t. ; exit
          endif
        next
        if fl ; j ++ ; endif
      endif
      if fl
        aadd(ar,{k006->shifr,0,lkoef,k006->profil,k006->ds,lshifr,k006->age,k006->sex,k006->los,k006->rslt,sds1,sds2,j})
      endif
      select K006
      skip
    enddo
  endif
next
if len(ar) > 0
  for i := 1 to len(ar)
    ar[i,2] := ret_cena_KSG(ar[i,1],lvr,date_usl)
    if ar[i,2] > 0
      fl_cena := .t.
    endif
  next
  aHirKSG := aclone(ar)
  if len(aHirKSG) > 1
    asort(aHirKSG,,,{|x,y| iif(x[13]==y[13], x[3] > y[3], x[13] > y[13]) })
  endif
    aadd(ars,"   ║хир.КСГ: "+print_array(aHirKSG[1]))
  for j := 2 to len(aHirKSG)
    aadd(ars,"   ║"+space(9)+print_array(aHirKSG[j]))
  next
  if (kol_hir := f_put_debug_KSG(2,aHirKSG,ars)) > 1
    aadd(ars," └─> выбираем хирур.КСГ="+aHirKSG[1,1]+" [КЗ="+lstr(aHirKSG[1,3])+"]")
  endif
endif
if kol_ter > 0 .and. kol_hir > 0
  i := int(val(right(aTerKSG[1,1],3)))
  j := int(val(right(aHirKSG[1,1],3)))
  if lusl == '2' .and. eq_any(j,99,100)
    lksg  := aHirKSG[1,1]
    lcena := aHirKSG[1,2]
    aadd(ars," выбираем хирур.КСГ="+lstr(j)+" (ДИАЛИЗ) вместо "+lstr(i))
  elseif !empty(aTerKSG[1,6]) // т.е. диагноз + услуга
    lksg  := aTerKSG[1,1]
    lcena := aTerKSG[1,2]
    aadd(ars," выбираем комбинированную КСГ="+lksg+" (осн.диагноз+услуга "+rtrim(aTerKSG[1,6])+")")
  elseif ascan(a_iskl_1, {|x| x[1]==i .and. x[2]==j}) > 0 // исключение из правил №1
    lksg  := aHirKSG[1,1]
    lcena := aHirKSG[1,2]
    aadd(ars," в соответствии с ИНСТРУКЦИЕЙ выбираем хирур.КСГ="+lstr(j)+" вместо "+lstr(i))
  else
    if aTerKSG[1,3] > aHirKSG[1,3] // "если хирур.КЗ меньше терапевтического КЗ"
      lksg  := aTerKSG[1,1]
      lcena := aTerKSG[1,2]
      aadd(ars," выбираем терап.КСГ="+lstr(i)+" с БОЛЬШИМ коэффициентом затратоёмкости "+lstr(aTerKSG[1,3]))
    else
      lksg  := aHirKSG[1,1]
      lcena := aHirKSG[1,2]
      aadd(ars," оставляем хирур.КСГ="+lstr(j)+" с коэффициентом затратоёмкости "+lstr(aHirKSG[1,3]))
    endif
  endif
elseif kol_ter > 0
  lksg  := aTerKSG[1,1]
  lcena := aTerKSG[1,2]
elseif kol_hir > 0
  lksg  := aHirKSG[1,1]
  lcena := aHirKSG[1,2]
endif
if !empty(lksg)
  s := " РЕЗУЛЬТАТ: выбрана КСГ="+lksg
  if empty(lcena)
    s += ", но не определена цена в справочнике ТФОМС"
    aadd(arerr,s)
  else
    s += " с ценой "+lstr(lcena,11,2)+"р."
    aadd(ars,s)
  endif
else
  aadd(arerr," РЕЗУЛЬТАТ: не получилось выбрать КСГ"+;
             iif(fl_reabil,' для случая медицинской реабилитации',''))
endif
return {ars,arerr,alltrim(lksg),lcena}*/

*

/***** 13.12.16 определение КСГ по остальным введённым полям ввода
Function definition_KSG_16(par)
// файлы "human", "human_" и "human_2" открыты и стоят на нужной записи
//       "human" открыт для записи суммы случая
// выполнено use_base("human_u","HU") - для записи
// выполнено use_base("mo_hu","MOHU") - для записи
Static ad_ksg_3, ad_ksg_4
Static sp0, sp1, sp6, sp15
Static a_iskl_1 := {; // исключение из правил №1
  {  6,  1, '2'},;
  {111,  0, '2'},;
  {112,  0, '2'},;
  {113,  0, '2'},;
  {114,  0, '2'},;
  {115,  0, '2'},;
  {116,  0, '2'},;
  {117,  0, '2'},;
  {118,  0, '2'},;
  { 11,  9, '1'},; // 1-КСГ по операции,2-КСГ по диагнозу
  { 12,  9, '1'},;
  { 11, 10, '1'},;
  { 73, 18, '1'},;
  { 74, 18, '1'},;
  {154,160, '1'},;
  {281,280, '1'},;
  {281,188, '1'},;
  {226,223, '1'},;
  { 34,225, '1'},;
  {237,252, '1'},;
  {300,  0, '1'},;
  {301,  0, '1'},;
  {302,  0, '1'},;
  {303,  0, '1'},;
  {304,  0, '1'},;
  {305,  0, '1'},;
  {306,  0, '1'},;
  {307,  0, '1'},;
  {308,  0, '1'};
 }
Local mdiagnoz, aHirKSG := {}, aTerKSG := {}, fl_cena := .f., lvmp, lvidvmp := 0,;
      i, j, k, c, s, ar, fl, im, lshifr, ln_data, lk_data, lvr, ldni, ldate_r, lpol,;
      lfio, lrslt, cenaTer := 0, cenaHir := 0, ksgHir, ars := {}, arerr := {}, ;
      lksg := "", lcena := 0, osn_diag3, lprofil, ldnej := 0, y := 0, m := 0, d := 0,;
      osn_diag := space(6), sop_diag := {}, osl_diag := {}, tmp,;
      kol_ter := 0, kol_hir := 0, lkoef, fl_reabil, fl_dop_ob_em := .f.,;
      ahu := {}, amohu := {}, date_usl := stod("20161231")
DEFAULT par TO 1, sp0 TO "", sp1 TO space(1), sp6 TO space(6), sp15 TO space(20)
Private pole
if par == 1
  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  if (lvmp := human_2->VMP) == 1
    lvidvmp := human_2->METVMP
  endif
  lfio    := alltrim(human->fio)
  ln_data := human->n_data
  lk_data := human->k_data
  if is_dop_ob_em
    fl_dop_ob_em := (human->reg_lech == 9)
  endif
  lrslt   := human_->RSLT_NEW
  lusl    := lstr(human_->USL_OK)
  ldate_r := iif(human_->NOVOR > 0, human_->date_r2, human->date_r)
  lpol    := iif(human_->NOVOR > 0, human_->pol2,    human->pol)
  lvr     := iif(human->VZROS_REB==0, 0, 1) // 0-взрослый, 1-ребенок
  lprofil := human_->profil
  // массив диагнозов (минимум два)
  mdiagnoz := diag_to_array(,,,,.t.)
  if len(mdiagnoz) > 0
    osn_diag := mdiagnoz[1]
    if len(mdiagnoz) > 1
      sop_diag := aclone(mdiagnoz)
      Del_Array(sop_diag,1) // начиная со 2-го - сопутствующие диагнозы
    endif
  endif
  if !empty(human_2->OSL1)
    aadd(osl_diag,human_2->OSL1)
  endif
  if !empty(human_2->OSL2)
    aadd(osl_diag,human_2->OSL2)
  endif
  if !empty(human_2->OSL3)
    aadd(osl_diag,human_2->OSL3)
  endif
else // из режима импорта случаев
  if (lvmp := iif(empty(ihuman->VID_HMP), 0, 1)) == 1
    lvidvmp := ihuman->METOD_HMP
  endif
  lusl    := lstr(ihuman->USL_OK)
  lfio    := alltrim(ihuman->fio)
  ln_data := ihuman->date_1
  lk_data := ihuman->date_2
  lrslt   := ihuman->RSLT
  ldate_r := iif(ihuman->NOVOR > 0, ihuman->reb_dr,  ihuman->dr)
  lpol    := iif(ihuman->NOVOR > 0, ihuman->reb_pol, ihuman->w)
  lpol    := iif(lpol == 1, "М","Ж")
  lvr     := iif(m1VZROS_REB==0, 0, 1) // 0-взрослый, 1-ребенок
  lprofil := ihuman->profil
  osn_diag := padr(ihuman->DS1,6)
  if !empty(ihuman->DS2)
    aadd(sop_diag, padr(ihuman->DS2,6))
  endif
  if !empty(ihuman->DS2_2)
    aadd(sop_diag, padr(ihuman->DS2_2,6))
  endif
  if !empty(ihuman->DS2_3)
    aadd(sop_diag, padr(ihuman->DS2_3,6))
  endif
  if !empty(ihuman->DS2_4)
    aadd(sop_diag, padr(ihuman->DS2_4,6))
  endif
  if !empty(ihuman->DS2_5)
    aadd(sop_diag, padr(ihuman->DS2_5,6))
  endif
  if !empty(ihuman->DS2_6)
    aadd(sop_diag, padr(ihuman->DS2_6,6))
  endif
  if !empty(ihuman->DS2_7)
    aadd(sop_diag, padr(ihuman->DS2_7,6))
  endif
  if !empty(ihuman->DS3)
    aadd(osl_diag, padr(ihuman->DS3,6))
  endif
  if !empty(ihuman->DS3_2)
    aadd(osl_diag, padr(ihuman->DS3_2,6))
  endif
  if !empty(ihuman->DS3_3)
    aadd(osl_diag, padr(ihuman->DS3_3,6))
  endif
endif
ldni := ln_data - ldate_r // для ребёнка возраст в днях
count_ymd(ldate_r,ln_data,@y,@m,@d)
date_usl := lk_data //!!!!!!!!!!!!раскомментировать после теста!!!!!!!!!!!!!!!
if lusl == '1'
  if (ldnej := lk_data - ln_data) == 0
    ldnej := 1
  endif
else
  lrslt := 0
endif
aadd(ars,lfio+" "+date_8(ln_data)+"-"+date_8(lk_data)+" ("+lstr(ldnej)+"дн.) "+;
         inieditspr(A__MENUVERT, glob_V009, lrslt))
s := iif(lVMP==1,'ВМП ',' ')
if par == 1
  s += alltrim(uch->name)+'/'+alltrim(otd->name)+'/'
endif
s += 'профиль "'+inieditspr(A__MENUVERT, glob_V002, lprofil)+'"'
aadd(ars,s)
aadd(ars,' д.р.'+full_date(ldate_r)+iif(lvr==0,'(взр.','(реб.')+'), '+iif(lpol=='М','муж.','жен.')+;
         ', осн.диаг.'+osn_diag+;
         iif(empty(sop_diag), '', ', соп.диаг.'+charrem(' ',print_array(sop_diag)))+;
         iif(empty(osl_diag), '', ', диаг.осл.'+charrem(' ',print_array(osl_diag))))
if empty(osn_diag)
  aadd(arerr,' не введён основной диагноз')
  return {ars,arerr,lksg,lcena}
endif
if lvmp > 0
  if lvidvmp == 0
    aadd(arerr,' не введён метод ВМП')
  elseif ascan(arr_12_VMP,lvidvmp) == 0
    aadd(arerr,' для метода ВМП '+lstr(lvidvmp)+' нет услуги ТФОМС')
  else
    lksg := iif(fl_dop_ob_em,"1.15.","1.12.")+lstr(lvidvmp)
    aadd(ars," для "+lstr(lvidvmp)+" метода ВМП введена услуга "+lksg)
    lcena := ret_cena_KSG(lksg,lvr,date_usl)
    if lcena > 0
      aadd(ars," РЕЗУЛЬТАТ: выбрана услуга="+lksg+" с ценой "+lstr(lcena,11,2))
    else
     aadd(arerr,' для Вашей МО в справочнике ТФОМС не найдена услуга: '+lksg)
    endif
  endif
  return {ars,arerr,alltrim(lksg),lcena}
endif
// составляем массив услуг и массив манипуляций
if par == 1
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    usl->(dbGoto(hu->u_kod))
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,date_usl))
      lshifr := usl->shifr
    endif
    lshifr := alltrim(lshifr)
    if ascan(ahu,lshifr) == 0
      aadd(ahu,lshifr)
    endif
    if lusl == '2' .and. left(lshifr,5)=='55.1.'
      ldnej += hu->kol_1
    endif
    select HU
    skip
  enddo
  if select("MOSU") == 0
    R_Use(dir_server+"mo_su",,"MOSU")
  endif
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    if mosu->(recno()) != mohu->u_kod
      mosu->(dbGoto(mohu->u_kod))
    endif
    if lusl == '2' .and. ascan(glob_MU_dializ,alltrim(mosu->shifr1)) > 0
      ldnej += mohu->kol_1
    endif
    if ascan(amohu,mosu->shifr1) == 0
      aadd(amohu,mosu->shifr1)
    endif
    select MOHU
    skip
  enddo
else
  select IHU
  find (str(ihuman->kod,10))
  do while ihu->kod == ihuman->kod .and. !eof()
    if eq_any(left(ihu->CODE_USL,1),"A","B")
      if ascan(amohu,ihu->CODE_USL)==0
        aadd(amohu,ihu->CODE_USL)
      endif
    else
      if ascan(ahu,alltrim(ihu->CODE_USL)) == 0
        aadd(ahu,alltrim(ihu->CODE_USL))
      endif
      if lusl == '2' .and. left(ihu->CODE_USL,5)=='55.1.'
        ldnej += ihu->KOL_USL
      endif
    endif
    skip
  enddo
endif
if lvr == 0 //
  lage := '5'
  s := "взр."
else
  lage := '4'
  s := "дети"
  if ldni <= 28
    lage += '1' // дети до 28 дней
    s := "0-28дн."
  elseif ldni <= 90
    lage += '2' // дети до 90 дней
    s := "29-90дн."
  elseif y < 1 // до 1 года
    lage += '3' // дети от 91 дня до 1 года
    s := "91день-1год"
  endif
endif
ars[1] := lfio+" "+date_8(ln_data)+"-"+date_8(lk_data)+" ("+lstr(ldnej)+"дн.) "+;
          inieditspr(A__MENUVERT, glob_V009, lrslt)
ars[3] := ' д.р.'+full_date(ldate_r)+'('+s+'), '+iif(lpol=='М','муж.','жен.')+;
          ', осн.диаг.'+osn_diag+;
          iif(empty(sop_diag), '', ', соп.диаг.'+charrem(' ',print_array(sop_diag)))+;
          iif(empty(osl_diag), '', ', диаг.осл.'+charrem(' ',print_array(osl_diag)))
lrslt := lstr(lrslt)
if len(lrslt) != 3
  lrslt := "***"
endif
lsex := iif(lpol=='М','1','2')
llos := ''
if ldnej < 4
  llos += '1'
  if lusl == '2' .and. ldnej == 1
    llos += '7'
  endif
else
  llos += '2'
endif
if ldnej < 7
  llos += '3'
else
  llos += '4'
endif
if ldnej < 21
  llos += '6'
else
  llos += '5'
endif
//aadd(ars,'   ║age='+lage+' sex='+lsex+' los='+llos)
if select("K006") == 0
  R_Use(exe_dir+"_mo6k006",{cur_dir+"_mo6k006",cur_dir+"_mo6k006_"},"K006")
    {"SHIFR",      "C",     10,      0},;
    {"DS",         "C",      6,      0},;
    {"DS1",        "M",     10,      0},;
    {"DS2",        "M",     10,      0},;
    {"SY",         "C",     20,      0},;
    {"AGE",        "C",      1,      0},;
    {"SEX",        "C",      1,      0},;
    {"LOS",        "C",      1,      0},;
  //index on substr(shifr,1,1)+ds+sy to (sbase)      // по диагнозу/операции
  //index on substr(shifr,1,1)+sy+ds to (sbase+"_")  // по операции/диагнозу
endif
fl_reabil := (ascan(ahu,"1.11.2") > 0 .or. ascan(ahu,"55.1.4") > 0)
// собираем КСГ по осн.диагнозу (терапевтические и комбинированные)
ar := {}
tmp := {}
select K006
set order to 1
find (lusl+padr(osn_diag,6))
do while left(k006->shifr,1)==lusl .and. k006->ds==padr(osn_diag,6) .and. !eof()
  lkoef := iif(lvr==0, k006->kzv, k006->kzd)
  if empty(lkoef) .and. ascan(glob_KSG_dializ,alltrim(k006->shifr)) > 0
    lkoef := 99
  endif
  c := substr(k006->shifr,2,1)
  select LUSL
  find (padr(k006->shifr,10))
  fl := lkoef > 0 .and. ;
        between_date(lusl->DATEBEG,lusl->DATEEND,date_usl) .and. ;
        iif(fl_reabil, c==iif(fl_dop_ob_em,'6','2'), c==iif(fl_dop_ob_em,'5','0'))
  sds1 := iif(empty(k006->ds1), sp0, alltrim(k006->ds1)+sp6) // соп.диагноз
  sds2 := iif(empty(k006->ds2), sp0, alltrim(k006->ds2)+sp6) // диагн.осложнения
  j := 0
  if fl .and. !empty(k006->sy)
    if (i := ascan(amohu,k006->sy)) > 0
      j += 10
    else
      fl := .f.
    endif
  endif
  if fl .and. !empty(k006->age)
    if (fl := (k006->age $ lage))
      if k006->age == '1'
        j += 5
      elseif k006->age == '2'
        j += 3
      elseif k006->age == '3'
        j += 2
      else
        j ++
      endif
    endif
  endif
  if fl .and. !empty(k006->sex)
    fl := (k006->sex == lsex)
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(k006->los)
    fl := (k006->los $ llos)
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(k006->rslt)
    fl := (lrslt $ k006->rslt)
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(sds1)
    fl := .f.
    for i := 1 to len(sop_diag)
      if sop_diag[i] $ sds1
        fl := .t. ; exit
      endif
    next
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(sds2)
    fl := .f.
    for i := 1 to len(osl_diag)
      if osl_diag[i] $ sds2
        fl := .t. ; exit
      endif
    next
    if fl ; j ++ ; endif
  endif
  if fl
    if !empty(k006->sy) .and. (i := ascan(amohu,k006->sy)) > 0
      aadd(tmp,i)
    endif
    aadd(ar,{k006->shifr,0,lkoef,k006->profil,osn_diag,k006->sy,k006->age,k006->sex,k006->los,k006->rslt,sds1,sds2,j})
  endif
  select K006
  skip
enddo
if len(ar) > 0
  for i := 1 to len(tmp)
    im := tmp[i]
    amohu[im] := "" // очистить, чтобы не включать в хирургическую КСГ
  next
  for i := 1 to len(ar)
    ar[i,2] := ret_cena_KSG(ar[i,1],lvr,date_usl)
    if ar[i,2] > 0
      fl_cena := .t.
    endif
  next
  aTerKSG := aclone(ar)
  if len(aTerKSG) > 1
    asort(aTerKSG,,,{|x,y| iif(x[13]==y[13], x[3] > y[3], x[13] > y[13]) })
  endif
    aadd(ars,"   ║КСГ: "+print_array(aTerKSG[1]))
  for j := 2 to len(aTerKSG)
    aadd(ars,"   ║     "+print_array(aTerKSG[j]))
  next
  if (kol_ter := f_put_debug_KSG(0,aTerKSG,ars)) > 1
    aadd(ars," └─> выбираем КСГ="+aTerKSG[1,1]+" [КЗ="+lstr(aTerKSG[1,3])+"]")
  endif
endif
// собираем КСГ по манипуляциям (хирургические и комбинированные)
ar := {}
for im := 1 to len(amohu)
  if !empty(lshifr := alltrim(amohu[im]))
    select K006
    set order to 2
    find (lusl+padr(lshifr,20))
    do while left(k006->shifr,1)==lusl .and. k006->sy==padr(lshifr,20) .and. !eof()
      lkoef := iif(lvr==0, k006->kzv, k006->kzd)
      if empty(lkoef) .and. ascan(glob_KSG_dializ,alltrim(k006->shifr)) > 0
        lkoef := 99
      endif
      c := substr(k006->shifr,2,1)
      select LUSL
      find (padr(k006->shifr,10))
      fl := lkoef > 0 .and. ;
            between_date(lusl->DATEBEG,lusl->DATEEND,date_usl) .and. ;
            iif(fl_reabil, c==iif(fl_dop_ob_em,'6','2'), c==iif(fl_dop_ob_em,'5','0'))
      sds1 := iif(empty(k006->ds1), sp0, alltrim(k006->ds1)+sp6) // соп.диагноз
      sds2 := iif(empty(k006->ds2), sp0, alltrim(k006->ds2)+sp6) // диагн.осложнения
      j := 0
      if fl .and. !empty(k006->ds)
        fl := (k006->ds == osn_diag)
        if fl ; j += 10 ; endif
      endif
      if fl .and. !empty(k006->age)
        if (fl := (k006->age $ lage))
          if k006->age == '1'
            j += 5
          elseif k006->age == '2'
            j += 3
          elseif k006->age == '3'
            j += 2
          else
            j ++
          endif
        endif
      endif
      if fl .and. !empty(k006->sex)
        fl := (k006->sex == lsex)
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(k006->los)
        fl := (k006->los $ llos)
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(k006->rslt)
        fl := (lrslt $ k006->rslt)
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(sds1)
        fl := .f.
        for i := 1 to len(sop_diag)
          if sop_diag[i] $ sds1
            fl := .t. ; exit
          endif
        next
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(sds2)
        fl := .f.
        for i := 1 to len(osl_diag)
          if osl_diag[i] $ sds2
            fl := .t. ; exit
          endif
        next
        if fl ; j ++ ; endif
      endif
      if fl
        aadd(ar,{k006->shifr,0,lkoef,k006->profil,k006->ds,lshifr,k006->age,k006->sex,k006->los,k006->rslt,sds1,sds2,j})
      endif
      select K006
      skip
    enddo
  endif
next
if len(ar) > 0
  for i := 1 to len(ar)
    ar[i,2] := ret_cena_KSG(ar[i,1],lvr,date_usl)
    if ar[i,2] > 0
      fl_cena := .t.
    endif
  next
  aHirKSG := aclone(ar)
  if len(aHirKSG) > 1
    asort(aHirKSG,,,{|x,y| iif(x[13]==y[13], x[3] > y[3], x[13] > y[13]) })
  endif
    aadd(ars,"   ║КСГ: "+print_array(aHirKSG[1]))
  for j := 2 to len(aHirKSG)
    aadd(ars,"   ║     "+print_array(aHirKSG[j]))
  next
  if (kol_hir := f_put_debug_KSG(0,aHirKSG,ars)) > 1
    aadd(ars," └─> выбираем КСГ="+aHirKSG[1,1]+" [КЗ="+lstr(aHirKSG[1,3])+"]")
  endif
endif
if kol_ter > 0 .and. kol_hir > 0
  i := int(val(right(aTerKSG[1,1],3)))
  j := int(val(right(aHirKSG[1,1],3)))
  if !empty(aTerKSG[1,6]) // т.е. диагноз + услуга
    lksg  := aTerKSG[1,1]
    lcena := aTerKSG[1,2]
    aadd(ars," выбираем КСГ="+lksg+" (осн.диагноз+услуга "+rtrim(aTerKSG[1,6])+")")
  elseif ascan(a_iskl_1, {|x| x[1]==j .and. eq_any(x[2],0,i) .and. lusl==x[3] }) > 0 // исключение из правил №1
    lksg  := aHirKSG[1,1]
    lcena := aHirKSG[1,2]
    aadd(ars," в соответствии с ИНСТРУКЦИЕЙ по группировке выбираем КСГ="+lstr(j)+" вместо "+lstr(i))
  else
    if aTerKSG[1,3] > aHirKSG[1,3] // "если хирур.КЗ меньше терапевтического КЗ"
      lksg  := aTerKSG[1,1]
      lcena := aTerKSG[1,2]
      aadd(ars," выбираем КСГ="+lstr(i)+" с БОЛЬШИМ коэффициентом затратоёмкости "+lstr(aTerKSG[1,3]))
    else
      lksg  := aHirKSG[1,1]
      lcena := aHirKSG[1,2]
      aadd(ars," оставляем КСГ="+lstr(j)+" с коэффициентом затратоёмкости "+lstr(aHirKSG[1,3]))
    endif
  endif
elseif kol_ter > 0
  lksg  := aTerKSG[1,1]
  lcena := aTerKSG[1,2]
elseif kol_hir > 0
  lksg  := aHirKSG[1,1]
  lcena := aHirKSG[1,2]
endif
akslp := {}
if !empty(lksg)
  s := " РЕЗУЛЬТАТ: выбрана КСГ="+lksg
  if empty(lcena)
    s += ", но не определена цена в справочнике ТФОМС"
    aadd(arerr,s)
  else
    s += ", цена "+lstr(lcena,11,2)+"р. "
    akslp := f_cena_kslp(@lcena,lksg,ldate_r,ln_data,lk_data)
    if !empty(akslp)
      s += "(КСЛП="+str(akslp[2],4,2)+", цена "+lstr(lcena,11,2)+"р.)"
    endif
    aadd(ars,s)
  endif
else
  aadd(arerr," РЕЗУЛЬТАТ: не получилось выбрать КСГ"+;
             iif(fl_reabil,' для случая медицинской реабилитации',''))
endif
return {ars,arerr,alltrim(lksg),lcena,akslp}*/

*

/***** 04.08.17 определение КСГ по остальным введённым полям ввода - 2017 год
Function definition_KSG_17(par)
// файлы "human", "human_" и "human_2" открыты и стоят на нужной записи
//       "human" открыт для записи суммы случая
// выполнено use_base("human_u","HU") - для записи
// выполнено use_base("mo_hu","MOHU") - для записи
Static ad_ksg_3, ad_ksg_4
Static sp0, sp1, sp6, sp15
Static a_iskl_1 := {; // исключение из правил №1
  {  6,  1, '2'},;
  {113,  0, '2'},;
  {114,  0, '2'},;
  {115,  0, '2'},;
  {116,  0, '2'},;
  {117,  0, '2'},;
  {118,  0, '2'},;
  {119,  0, '2'},;
  {120,  0, '2'},;
  { 11,  9, '1'},; // 1-КСГ по операции,2-КСГ по диагнозу
  { 12,  9, '1'},;
  { 11, 10, '1'},;
  { 74, 18, '1'},;
  { 75, 18, '1'},;
  {160,166, '1'},;
  {287,286, '1'},;
  {287,194, '1'},;
  {232,229, '1'},;
  { 34,231, '1'},;
  {243,258, '1'},;
  {307,  0, '1'},;
  {308,  0, '1'},;
  {309,  0, '1'},;
  {310,  0, '1'},;
  {311,  0, '1'},;
  {312,  0, '1'},;
  {313,  0, '1'},;
  {314,  0, '1'},;
  {315,  0, '1'};
 }
Local mdiagnoz, aHirKSG := {}, aTerKSG := {}, fl_cena := .f., lvmp, lvidvmp := 0, lstentvmp := 0,;
      i, j, k, c, s, ar, fl, im, lshifr, ln_data, lk_data, lvr, ldni, ldate_r, lpol,;
      lfio, lrslt, cenaTer := 0, cenaHir := 0, ksgHir, ars := {}, arerr := {}, ;
      lksg := "", lcena := 0, osn_diag3, lprofil, ldnej := 0, y := 0, m := 0, d := 0,;
      osn_diag := space(6), sop_diag := {}, osl_diag := {}, tmp,;
      kol_ter := 0, kol_hir := 0, lkoef, fl_reabil, fl_dop_ob_em := .f.,;
      ahu := {}, amohu := {}, date_usl := stod("20170101")
DEFAULT par TO 1, sp0 TO "", sp1 TO space(1), sp6 TO space(6), sp15 TO space(20)
Private pole
if par == 1
  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  if (lvmp := human_2->VMP) == 1
    lvidvmp := human_2->METVMP
    if between(lvidvmp,498,499)
      lstentvmp := int(val(left(human_2->PC1,1))) // кол-во стентов для методов ВМП 498,499
    endif
  endif
  lfio    := alltrim(human->fio)
  ln_data := human->n_data
  lk_data := human->k_data
  if is_dop_ob_em
    fl_dop_ob_em := (human->reg_lech == 9)
  endif
  lrslt   := human_->RSLT_NEW
  lusl    := lstr(human_->USL_OK)
  ldate_r := iif(human_->NOVOR > 0, human_->date_r2, human->date_r)
  lpol    := iif(human_->NOVOR > 0, human_->pol2,    human->pol)
  lvr     := iif(human->VZROS_REB==0, 0, 1) // 0-взрослый, 1-ребенок
  lprofil := human_->profil
  // массив диагнозов (минимум два)
  mdiagnoz := diag_to_array(,,,,.t.)
  if len(mdiagnoz) > 0
    osn_diag := mdiagnoz[1]
    if len(mdiagnoz) > 1
      sop_diag := aclone(mdiagnoz)
      Del_Array(sop_diag,1) // начиная со 2-го - сопутствующие диагнозы
    endif
  endif
  if !empty(human_2->OSL1)
    aadd(osl_diag,human_2->OSL1)
  endif
  if !empty(human_2->OSL2)
    aadd(osl_diag,human_2->OSL2)
  endif
  if !empty(human_2->OSL3)
    aadd(osl_diag,human_2->OSL3)
  endif
else // из режима импорта случаев
  if (lvmp := iif(empty(ihuman->VID_HMP), 0, 1)) == 1
    lvidvmp := ihuman->METOD_HMP
  endif
  lusl    := lstr(ihuman->USL_OK)
  lfio    := alltrim(ihuman->fio)
  ln_data := ihuman->date_1
  lk_data := ihuman->date_2
  lrslt   := ihuman->RSLT
  ldate_r := iif(ihuman->NOVOR > 0, ihuman->reb_dr,  ihuman->dr)
  lpol    := iif(ihuman->NOVOR > 0, ihuman->reb_pol, ihuman->w)
  lpol    := iif(lpol == 1, "М","Ж")
  lvr     := iif(m1VZROS_REB==0, 0, 1) // 0-взрослый, 1-ребенок
  lprofil := ihuman->profil
  osn_diag := padr(ihuman->DS1,6)
  if !empty(ihuman->DS2)
    aadd(sop_diag, padr(ihuman->DS2,6))
  endif
  if !empty(ihuman->DS2_2)
    aadd(sop_diag, padr(ihuman->DS2_2,6))
  endif
  if !empty(ihuman->DS2_3)
    aadd(sop_diag, padr(ihuman->DS2_3,6))
  endif
  if !empty(ihuman->DS2_4)
    aadd(sop_diag, padr(ihuman->DS2_4,6))
  endif
  if !empty(ihuman->DS2_5)
    aadd(sop_diag, padr(ihuman->DS2_5,6))
  endif
  if !empty(ihuman->DS2_6)
    aadd(sop_diag, padr(ihuman->DS2_6,6))
  endif
  if !empty(ihuman->DS2_7)
    aadd(sop_diag, padr(ihuman->DS2_7,6))
  endif
  if !empty(ihuman->DS3)
    aadd(osl_diag, padr(ihuman->DS3,6))
  endif
  if !empty(ihuman->DS3_2)
    aadd(osl_diag, padr(ihuman->DS3_2,6))
  endif
  if !empty(ihuman->DS3_3)
    aadd(osl_diag, padr(ihuman->DS3_3,6))
  endif
endif
ldni := ln_data - ldate_r // для ребёнка возраст в днях
count_ymd(ldate_r,ln_data,@y,@m,@d)
date_usl := lk_data //!!!!!!!!!!!!раскомментировать после теста!!!!!!!!!!!!!!!
if lusl == '1' // стационар
  if (ldnej := lk_data - ln_data) == 0
    ldnej := 1
  endif
else
  lrslt := 0
endif
aadd(ars,lfio+" "+date_8(ln_data)+"-"+date_8(lk_data)+" ("+lstr(ldnej)+"дн.) "+;
         inieditspr(A__MENUVERT, glob_V009, lrslt))
s := iif(lVMP==1,'ВМП ',' ')
if par == 1
  s += alltrim(uch->name)+'/'+alltrim(otd->name)+'/'
endif
s += 'профиль "'+inieditspr(A__MENUVERT, glob_V002, lprofil)+'"'
aadd(ars,s)
aadd(ars,' д.р.'+full_date(ldate_r)+iif(lvr==0,'(взр.','(реб.')+'), '+iif(lpol=='М','муж.','жен.')+;
         ', осн.диаг.'+osn_diag+;
         iif(empty(sop_diag), '', ', соп.диаг.'+charrem(' ',print_array(sop_diag)))+;
         iif(empty(osl_diag), '', ', диаг.осл.'+charrem(' ',print_array(osl_diag))))
if empty(osn_diag)
  aadd(arerr,' не введён основной диагноз')
  return {ars,arerr,lksg,lcena}
endif
if f_put_glob_podr(int(val(lusl)),date_usl,arerr) // заполнить код подразделения
  return {ars,arerr,lksg,lcena}
endif
if lvmp > 0
  if lvidvmp == 0
    aadd(arerr,' не введён метод ВМП')
  elseif ascan(arr_12_VMP,lvidvmp) == 0
    aadd(arerr,' для метода ВМП '+lstr(lvidvmp)+' нет услуги ТФОМС')
  else
    lksg := iif(fl_dop_ob_em,"1.15.","1.12.")+lstr(lvidvmp)
    if date_usl >= d_01_08_2017 .and. between(lvidvmp,498,499) .and. between(lstentvmp,1,3)
      lksg := "1."+lstr(15+lstentvmp)+"."+lstr(lvidvmp)
    endif
    aadd(ars," для "+lstr(lvidvmp)+" метода ВМП введена услуга "+lksg+;
             iif(lstentvmp==0,""," (кол-во стентов="+lstr(lstentvmp)+")"))
    lcena := ret_cena_KSG(lksg,lvr,date_usl)
    if lcena > 0
      aadd(ars," РЕЗУЛЬТАТ: выбрана услуга="+lksg+" с ценой "+lstr(lcena,11,2))
    elseif date_usl >= d_01_08_2017 .and. between(lvidvmp,498,499) .and. !between(lstentvmp,1,3)
      aadd(arerr,' не введено число стентов, установленных в коронарные артерии')
    else
      aadd(arerr,' для Вашей МО в справочнике ТФОМС не найдена услуга: '+lksg)
    endif
  endif
  return {ars,arerr,alltrim(lksg),lcena}
endif
// составляем массив услуг и массив манипуляций
if par == 1
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    usl->(dbGoto(hu->u_kod))
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,date_usl))
      lshifr := usl->shifr
    endif
    lshifr := alltrim(lshifr)
    if ascan(ahu,lshifr) == 0
      aadd(ahu,lshifr)
    endif
    if lusl == '2' .and. left(lshifr,5)=='55.1.'
      ldnej += hu->kol_1
    endif
    select HU
    skip
  enddo
  if select("MOSU") == 0
    R_Use(dir_server+"mo_su",,"MOSU")
  endif
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    if mosu->(recno()) != mohu->u_kod
      mosu->(dbGoto(mohu->u_kod))
    endif
    if lusl == '2' .and. ascan(glob_MU_dializ,alltrim(mosu->shifr1)) > 0
      ldnej += mohu->kol_1
    endif
    if ascan(amohu,mosu->shifr1) == 0
      aadd(amohu,mosu->shifr1)
    endif
    select MOHU
    skip
  enddo
else
  select IHU
  find (str(ihuman->kod,10))
  do while ihu->kod == ihuman->kod .and. !eof()
    if eq_any(left(ihu->CODE_USL,1),"A","B")
      if ascan(amohu,ihu->CODE_USL)==0
        aadd(amohu,ihu->CODE_USL)
      endif
    else
      if ascan(ahu,alltrim(ihu->CODE_USL)) == 0
        aadd(ahu,alltrim(ihu->CODE_USL))
      endif
      if lusl == '2' .and. left(ihu->CODE_USL,5)=='55.1.'
        ldnej += ihu->KOL_USL
      endif
    endif
    skip
  enddo
endif
if lvr == 0 //
  lage := '5'
  s := "взр."
else
  lage := '4'
  s := "дети"
  if ldni <= 28
    lage += '1' // дети до 28 дней
    s := "0-28дн."
  elseif ldni <= 90
    lage += '2' // дети до 90 дней
    s := "29-90дн."
  elseif y < 1 // до 1 года
    lage += '3' // дети от 91 дня до 1 года
    s := "91день-1год"
  endif
  if y < 2 // до 2 лет
    lage += '6' // дети до 2 лет
    s := "до2лет"
  endif
endif
ars[1] := lfio+" "+date_8(ln_data)+"-"+date_8(lk_data)+" ("+lstr(ldnej)+"дн.) "+;
          inieditspr(A__MENUVERT, glob_V009, lrslt)
ars[3] := ' д.р.'+full_date(ldate_r)+'('+s+'), '+iif(lpol=='М','муж.','жен.')+;
          ', осн.диаг.'+osn_diag+;
          iif(empty(sop_diag), '', ', соп.диаг.'+charrem(' ',print_array(sop_diag)))+;
          iif(empty(osl_diag), '', ', диаг.осл.'+charrem(' ',print_array(osl_diag)))
lrslt := lstr(lrslt)
if len(lrslt) != 3
  lrslt := "***"
endif
lsex := iif(lpol=='М','1','2')
llos := ''
if ldnej < 4
  llos += '1'
  if lusl == '2' .and. ldnej == 1
    llos += '7'
  endif
else
  llos += '2'
endif
if ldnej < 7
  llos += '3'
else
  llos += '4'
endif
if ldnej < 21
  llos += '6'
else
  llos += '5'
endif
//aadd(ars,'   ║age='+lage+' sex='+lsex+' los='+llos)
if select("K006") == 0
  R_Use(exe_dir+"_mo7k006",{cur_dir+"_mo7k006",cur_dir+"_mo7k006_"},"K006")
    {"SHIFR",      "C",     10,      0},;
    {"DS",         "C",      6,      0},;
    {"DS1",        "M",     10,      0},;
    {"DS2",        "M",     10,      0},;
    {"SY",         "C",     20,      0},;
    {"AGE",        "C",      1,      0},;
    {"SEX",        "C",      1,      0},;
    {"LOS",        "C",      1,      0},;
  //index on substr(shifr,1,1)+ds+sy to (sbase)      // по диагнозу/операции
  //index on substr(shifr,1,1)+sy+ds to (sbase+"_")  // по операции/диагнозу
endif
fl_reabil := (ascan(ahu,"1.11.2") > 0 .or. ascan(ahu,"55.1.4") > 0)
// собираем КСГ по осн.диагнозу (терапевтические и комбинированные)
ar := {}
tmp := {}
select K006
set order to 1
find (lusl+padr(osn_diag,6))
do while left(k006->shifr,1)==lusl .and. k006->ds==padr(osn_diag,6) .and. !eof()
  lkoef := iif(lvr==0, k006->kzv, k006->kzd)
  if empty(lkoef) .and. ascan(glob_KSG_dializ,alltrim(k006->shifr)) > 0
    lkoef := 99
  endif
  c := substr(k006->shifr,2,1)
  select LUSL17
  find (padr(k006->shifr,10))
  fl := lkoef > 0 .and. ;
        between_date(lusl17->DATEBEG,lusl17->DATEEND,date_usl) .and. ;
        iif(fl_reabil, c==iif(fl_dop_ob_em,'6','2'), c==iif(fl_dop_ob_em,'5','0'))
  sds1 := iif(empty(k006->ds1), sp0, alltrim(k006->ds1)+sp6) // соп.диагноз
  sds2 := iif(empty(k006->ds2), sp0, alltrim(k006->ds2)+sp6) // диагн.осложнения
  j := 0
  if fl .and. !empty(k006->sy)
    if (i := ascan(amohu,k006->sy)) > 0
      j += 10
    else
      fl := .f.
    endif
  endif
  if fl .and. !empty(k006->age)
    if (fl := (k006->age $ lage))
      if k006->age == '1'
        j += 5
      elseif k006->age == '2'
        j += 3
      elseif k006->age == '3'
        j += 2
      else
        j ++
      endif
    endif
  endif
  if fl .and. !empty(k006->sex)
    fl := (k006->sex == lsex)
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(k006->los)
    fl := (k006->los $ llos)
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(k006->rslt)
    fl := (lrslt $ k006->rslt)
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(sds1)
    fl := .f.
    for i := 1 to len(sop_diag)
      if sop_diag[i] $ sds1
        fl := .t. ; exit
      endif
    next
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(sds2)
    fl := .f.
    for i := 1 to len(osl_diag)
      if osl_diag[i] $ sds2
        fl := .t. ; exit
      endif
    next
    if fl ; j ++ ; endif
  endif
  if fl
    if !empty(k006->sy) .and. (i := ascan(amohu,k006->sy)) > 0
      aadd(tmp,i)
    endif
    aadd(ar,{k006->shifr,0,lkoef,k006->profil,osn_diag,k006->sy,k006->age,k006->sex,k006->los,k006->rslt,sds1,sds2,j})
  endif
  select K006
  skip
enddo
if len(ar) > 0
  for i := 1 to len(tmp)
    im := tmp[i]
    amohu[im] := "" // очистить, чтобы не включать в хирургическую КСГ
  next
  for i := 1 to len(ar)
    ar[i,2] := ret_cena_KSG(ar[i,1],lvr,date_usl)
    if ar[i,2] > 0
      fl_cena := .t.
    endif
  next
  aTerKSG := aclone(ar)
  if len(aTerKSG) > 1
    asort(aTerKSG,,,{|x,y| iif(x[13]==y[13], x[3] > y[3], x[13] > y[13]) })
  endif
    aadd(ars,"   ║КСГ: "+print_array(aTerKSG[1]))
  for j := 2 to len(aTerKSG)
    aadd(ars,"   ║     "+print_array(aTerKSG[j]))
  next
  if (kol_ter := f_put_debug_KSG(0,aTerKSG,ars)) > 1
    aadd(ars," └─> выбираем КСГ="+aTerKSG[1,1]+" [КЗ="+lstr(aTerKSG[1,3])+"]")
  endif
endif
// собираем КСГ по манипуляциям (хирургические и комбинированные)
ar := {}
for im := 1 to len(amohu)
  if !empty(lshifr := alltrim(amohu[im]))
    select K006
    set order to 2
    find (lusl+padr(lshifr,20))
    do while left(k006->shifr,1)==lusl .and. k006->sy==padr(lshifr,20) .and. !eof()
      lkoef := iif(lvr==0, k006->kzv, k006->kzd)
      if empty(lkoef) .and. ascan(glob_KSG_dializ,alltrim(k006->shifr)) > 0
        lkoef := 99
      endif
      c := substr(k006->shifr,2,1)
      select LUSL17
      find (padr(k006->shifr,10))
      fl := lkoef > 0 .and. ;
            between_date(lusl17->DATEBEG,lusl17->DATEEND,date_usl) .and. ;
            iif(fl_reabil, c==iif(fl_dop_ob_em,'6','2'), c==iif(fl_dop_ob_em,'5','0'))
      sds1 := iif(empty(k006->ds1), sp0, alltrim(k006->ds1)+sp6) // соп.диагноз
      sds2 := iif(empty(k006->ds2), sp0, alltrim(k006->ds2)+sp6) // диагн.осложнения
      j := 0
      if fl .and. !empty(k006->ds)
        fl := (k006->ds == osn_diag)
        if fl ; j += 10 ; endif
      endif
      if fl .and. !empty(k006->age)
        if (fl := (k006->age $ lage))
          if k006->age == '1'
            j += 5
          elseif k006->age == '2'
            j += 3
          elseif k006->age == '3'
            j += 2
          else
            j ++
          endif
        endif
      endif
      if fl .and. !empty(k006->sex)
        fl := (k006->sex == lsex)
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(k006->los)
        fl := (k006->los $ llos)
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(k006->rslt)
        fl := (lrslt $ k006->rslt)
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(sds1)
        fl := .f.
        for i := 1 to len(sop_diag)
          if sop_diag[i] $ sds1
            fl := .t. ; exit
          endif
        next
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(sds2)
        fl := .f.
        for i := 1 to len(osl_diag)
          if osl_diag[i] $ sds2
            fl := .t. ; exit
          endif
        next
        if fl ; j ++ ; endif
      endif
      if fl
        aadd(ar,{k006->shifr,0,lkoef,k006->profil,k006->ds,lshifr,k006->age,k006->sex,k006->los,k006->rslt,sds1,sds2,j})
      endif
      select K006
      skip
    enddo
  endif
next
if len(ar) > 0
  for i := 1 to len(ar)
    ar[i,2] := ret_cena_KSG(ar[i,1],lvr,date_usl)
    if ar[i,2] > 0
      fl_cena := .t.
    endif
  next
  aHirKSG := aclone(ar)
  if len(aHirKSG) > 1
    asort(aHirKSG,,,{|x,y| iif(x[13]==y[13], x[3] > y[3], x[13] > y[13]) })
  endif
    aadd(ars,"   ║КСГ: "+print_array(aHirKSG[1]))
  for j := 2 to len(aHirKSG)
    aadd(ars,"   ║     "+print_array(aHirKSG[j]))
  next
  if (kol_hir := f_put_debug_KSG(0,aHirKSG,ars)) > 1
    aadd(ars," └─> выбираем КСГ="+aHirKSG[1,1]+" [КЗ="+lstr(aHirKSG[1,3])+"]")
  endif
endif
if kol_ter > 0 .and. kol_hir > 0
  i := int(val(right(aTerKSG[1,1],3)))
  j := int(val(right(aHirKSG[1,1],3)))
  if !empty(aTerKSG[1,6]) // т.е. диагноз + услуга
    lksg  := aTerKSG[1,1]
    lcena := aTerKSG[1,2]
    aadd(ars," выбираем КСГ="+lksg+" (осн.диагноз+услуга "+rtrim(aTerKSG[1,6])+")")
  elseif ascan(a_iskl_1, {|x| x[1]==j .and. eq_any(x[2],0,i) .and. lusl==x[3] }) > 0 // исключение из правил №1
    lksg  := aHirKSG[1,1]
    lcena := aHirKSG[1,2]
    aadd(ars," в соответствии с ИНСТРУКЦИЕЙ по группировке выбираем КСГ="+lstr(j)+" вместо "+lstr(i))
  else
    if aTerKSG[1,3] > aHirKSG[1,3] // "если хирур.КЗ меньше терапевтического КЗ"
      lksg  := aTerKSG[1,1]
      lcena := aTerKSG[1,2]
      aadd(ars," выбираем КСГ="+lstr(i)+" с БОЛЬШИМ коэффициентом затратоёмкости "+lstr(aTerKSG[1,3]))
    else
      lksg  := aHirKSG[1,1]
      lcena := aHirKSG[1,2]
      aadd(ars," оставляем КСГ="+lstr(j)+" с коэффициентом затратоёмкости "+lstr(aHirKSG[1,3]))
    endif
  endif
elseif kol_ter > 0
  lksg  := aTerKSG[1,1]
  lcena := aTerKSG[1,2]
elseif kol_hir > 0
  lksg  := aHirKSG[1,1]
  lcena := aHirKSG[1,2]
endif
akslp := {}
if !empty(lksg)
  s := " РЕЗУЛЬТАТ: выбрана КСГ="+lksg
  if empty(lcena)
    s += ", но не определена цена в справочнике ТФОМС"
    aadd(arerr,s)
  else
    s += ", цена "+lstr(lcena,11,2)+"р. "
    akslp := f_cena_kslp(@lcena,lksg,ldate_r,ln_data,lk_data)
    if !empty(akslp)
      s += "(КСЛП="+str(akslp[2],4,2)+", цена "+lstr(lcena,11,2)+"р.)"
    endif
    aadd(ars,s)
  endif
else
  aadd(arerr," РЕЗУЛЬТАТ: не получилось выбрать КСГ"+;
             iif(fl_reabil,' для случая медицинской реабилитации',''))
endif
return {ars,arerr,alltrim(lksg),lcena,akslp}*/

***** 16.01.19 определение КСГ по остальным введённым полям ввода - 2018 год
Function definition_KSG_18(par)
// файлы "human", "human_" и "human_2" открыты и стоят на нужной записи
//       "human" открыт для записи суммы случая
// выполнено use_base("human_u","HU") - для записи
// выполнено use_base("mo_hu","MOHU") - для записи
Static ad_ksg_3, ad_ksg_4
Static sp0, sp1, sp6, sp15
Static a_iskl_1 := {; // исключение из правил №1
  {  6,  1, '2'},;
  {123,  0, '2'},;
  {124,  0, '2'},;
  {125,  0, '2'},;
  {126,  0, '2'},;
  {127,  0, '2'},;
  {128,  0, '2'},;
  {129,  0, '2'},;
  {130,  0, '2'},;
  {131,  0, '2'},;
  {132,  0, '2'},;
  { 11,  9, '1'},; // 1-КСГ по операции,2-КСГ по диагнозу
  { 12,  9, '1'},;
  { 11, 10, '1'},;
  { 76, 18, '1'},;
  { 77, 18, '1'},;
  {173,179, '1'},;
  {301,300, '1'},;
  {301,207, '1'},;
  {245,242, '1'},;
  { 35,244, '1'},;
  {256,271, '1'},;
  {325,  0, '1'},;
  {326,  0, '1'},;
  {327,  0, '1'},;
  {328,  0, '1'},;
  {329,  0, '1'},;
  {330,  0, '1'},;
  {331,  0, '1'},;
  {332,  0, '1'},;
  {333,  0, '1'},;
  {334,  0, '1'},;
  {335,  0, '1'},;
  {336,  0, '1'},;
  {337,  0, '1'},;
  {338,  0, '1'};
 }
Local mdiagnoz, aHirKSG := {}, aTerKSG := {}, fl_cena := .f., lvmp, lvidvmp := 0, lstentvmp := 0,;
      i, j, k, c, s, ar, fl, im, lshifr, ln_data, lk_data, lvr, ldni, ldate_r, lpol,;
      lad_cr := "", lfio, cenaTer := 0, cenaHir := 0, ksgHir, ars := {}, arerr := {}, ;
      lksg := "", lcena := 0, osn_diag3, lprofil, ldnej := 0, y := 0, m := 0, d := 0,;
      osn_diag := space(6), sop_diag := {}, osl_diag := {}, tmp, akslp, akiro,;
      kol_ter := 0, kol_hir := 0, lkoef, fl_reabil, lkiro := 0, lkslp := "", lbartell := "",;
      is_dializ := .f., ahu := {}, amohu := {}, date_usl := stod("20180101")
DEFAULT par TO 1, sp0 TO "", sp1 TO space(1), sp6 TO space(6), sp15 TO space(20)
Private pole
if par == 1
  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  if (lvmp := human_2->VMP) == 1
    lvidvmp := human_2->METVMP
  endif
  lad_cr  := alltrim(human_2->pc3)
  lfio    := alltrim(human->fio)
  ln_data := human->n_data
  lk_data := human->k_data
  lusl    := lstr(human_->USL_OK)
  ldate_r := iif(human_->NOVOR > 0, human_->date_r2, human->date_r)
  lpol    := iif(human_->NOVOR > 0, human_->pol2,    human->pol)
  lvr     := iif(human->VZROS_REB==0, 0, 1) // 0-взрослый, 1-ребенок
  lprofil := human_->profil
  // массив диагнозов (минимум два)
  mdiagnoz := diag_to_array(,,,,.t.)
  if len(mdiagnoz) > 0
    osn_diag := mdiagnoz[1]
    if len(mdiagnoz) > 1
      sop_diag := aclone(mdiagnoz)
      Del_Array(sop_diag,1) // начиная со 2-го - сопутствующие диагнозы
    endif
  endif
  if !empty(human_2->OSL1)
    aadd(osl_diag,human_2->OSL1)
  endif
  if !empty(human_2->OSL2)
    aadd(osl_diag,human_2->OSL2)
  endif
  if !empty(human_2->OSL3)
    aadd(osl_diag,human_2->OSL3)
  endif
else // из режима импорта случаев
  if (lvmp := iif(empty(ihuman->VID_HMP), 0, 1)) == 1
    lvidvmp := ihuman->METOD_HMP
  endif
  lad_cr  := alltrim(ihuman->ad_cr)
  lusl    := lstr(ihuman->USL_OK)
  lfio    := alltrim(ihuman->fio)
  ln_data := ihuman->date_1
  lk_data := ihuman->date_2
  ldate_r := iif(ihuman->NOVOR > 0, ihuman->reb_dr,  ihuman->dr)
  lpol    := iif(ihuman->NOVOR > 0, ihuman->reb_pol, ihuman->w)
  lpol    := iif(lpol == 1, "М","Ж")
  lvr     := iif(m1VZROS_REB==0, 0, 1) // 0-взрослый, 1-ребенок
  lprofil := ihuman->profil
  osn_diag := padr(ihuman->DS1,6)
  if !empty(ihuman->DS2)
    aadd(sop_diag, padr(ihuman->DS2,6))
  endif
  if !empty(ihuman->DS2_2)
    aadd(sop_diag, padr(ihuman->DS2_2,6))
  endif
  if !empty(ihuman->DS2_3)
    aadd(sop_diag, padr(ihuman->DS2_3,6))
  endif
  if !empty(ihuman->DS2_4)
    aadd(sop_diag, padr(ihuman->DS2_4,6))
  endif
  if !empty(ihuman->DS2_5)
    aadd(sop_diag, padr(ihuman->DS2_5,6))
  endif
  if !empty(ihuman->DS2_6)
    aadd(sop_diag, padr(ihuman->DS2_6,6))
  endif
  if !empty(ihuman->DS2_7)
    aadd(sop_diag, padr(ihuman->DS2_7,6))
  endif
  if !empty(ihuman->DS3)
    aadd(osl_diag, padr(ihuman->DS3,6))
  endif
  if !empty(ihuman->DS3_2)
    aadd(osl_diag, padr(ihuman->DS3_2,6))
  endif
  if !empty(ihuman->DS3_3)
    aadd(osl_diag, padr(ihuman->DS3_3,6))
  endif
endif
if eq_any(lad_cr,'60','61')
  lbartell := lad_cr
  lad_cr := ""
endif
ldni := ln_data - ldate_r // для ребёнка возраст в днях
count_ymd(ldate_r,ln_data,@y,@m,@d)
date_usl := lk_data //!!!!!!!!!!!!раскомментировать после теста!!!!!!!!!!!!!!!
if lusl == '1' // стационар
  if (ldnej := lk_data - ln_data) == 0
    ldnej := 1
  endif
endif
aadd(ars,lfio+" "+date_8(ln_data)+"-"+date_8(lk_data)+" ("+lstr(ldnej)+"дн.)")
s := iif(lVMP==1,'ВМП ',' ')
if par == 1
  s += alltrim(uch->name)+'/'+alltrim(otd->name)+'/'
endif
s += 'профиль "'+inieditspr(A__MENUVERT, glob_V002, lprofil)+'"'
aadd(ars,s)
aadd(ars,' д.р.'+full_date(ldate_r)+iif(lvr==0,'(взр.','(реб.')+'), '+iif(lpol=='М','муж.','жен.')+;
         ', осн.диаг.'+osn_diag+;
         iif(empty(sop_diag), '', ', соп.диаг.'+charrem(' ',print_array(sop_diag)))+;
         iif(empty(osl_diag), '', ', диаг.осл.'+charrem(' ',print_array(osl_diag))))
if empty(osn_diag)
  aadd(arerr,' не введён основной диагноз')
  return {ars,arerr,lksg,lcena,{},{}}
endif
if f_put_glob_podr(int(val(lusl)),date_usl,arerr) // заполнить код подразделения
  return {ars,arerr,lksg,lcena}
endif
if lvmp > 0
  if lvidvmp == 0
    aadd(arerr,' не введён метод ВМП')
  elseif ascan(arr_12_VMP,lvidvmp) == 0
    aadd(arerr,' для метода ВМП '+lstr(lvidvmp)+' нет услуги ТФОМС')
  else
    // lksg := "1.12."+lstr(lvidvmp)  // 07.02.2021
    lksg := "1.20."+lstr(lvidvmp)
    aadd(ars," для "+lstr(lvidvmp)+" метода ВМП введена услуга "+lksg)
    lcena := ret_cena_KSG(lksg,lvr,date_usl)
    if lcena > 0
      aadd(ars," РЕЗУЛЬТАТ: выбрана услуга="+lksg+" с ценой "+lstr(lcena,11,2))
    else
      aadd(arerr,' для Вашей МО в справочнике ТФОМС не найдена услуга: '+lksg)
    endif
  endif
  return {ars,arerr,alltrim(lksg),lcena,{},{}}
endif
// составляем массив услуг и массив манипуляций
if par == 1
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    usl->(dbGoto(hu->u_kod))
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,date_usl))
      lshifr := usl->shifr
    endif
    lshifr := alltrim(lshifr)
    if left(lshifr,5) == "60.3."
      is_dializ := .t.
      exit
    endif
    if ascan(ahu,lshifr) == 0
      aadd(ahu,lshifr)
    endif
    if lusl == '2' .and. left(lshifr,5)=='55.1.'
      ldnej += hu->kol_1
    endif
    select HU
    skip
  enddo
  if select("MOSU") == 0
    R_Use(dir_server+"mo_su",,"MOSU")
  endif
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    if mosu->(recno()) != mohu->u_kod
      mosu->(dbGoto(mohu->u_kod))
    endif
    if ascan(amohu,mosu->shifr1) == 0
      aadd(amohu,mosu->shifr1)
    endif
    select MOHU
    skip
  enddo
else
  select IHU
  find (str(ihuman->kod,10))
  do while ihu->kod == ihuman->kod .and. !eof()
    if eq_any(left(ihu->CODE_USL,1),"A","B")
      if ascan(amohu,ihu->CODE_USL)==0
        aadd(amohu,ihu->CODE_USL)
      endif
    else
      if ascan(ahu,alltrim(ihu->CODE_USL)) == 0
        aadd(ahu,alltrim(ihu->CODE_USL))
      endif
      if left(ihu->CODE_USL,5) == "60.3."
        is_dializ := .t.
        exit
      endif
      if lusl == '2' .and. left(ihu->CODE_USL,5)=='55.1.'
        ldnej += ihu->KOL_USL
      endif
    endif
    skip
  enddo
endif
if is_dializ
  return {{},{"это диализ"},"",0,{},{},.t.}
endif
if lvr == 0 //
  lage := '5'
  s := "взр."
else
  lage := '4'
  s := "дети"
  fl := .t.
  if ldni <= 28
    lage += '1' // дети до 28 дней
    s := "0-28дн."
    fl := .f.
  elseif ldni <= 90
    lage += '2' // дети до 90 дней
    s := "29-90дн."
    fl := .f.
  elseif y < 1 // до 1 года
    lage += '3' // дети от 91 дня до 1 года
    s := "91день-1год"
    fl := .f.
  endif
  if y < 2 // до 2 лет
    lage += '7' // дети до 2 лет
    if fl
      s := "до2лет"
    endif
  endif
endif
ars[1] := lfio+" "+date_8(ln_data)+"-"+date_8(lk_data)+" ("+lstr(ldnej)+"дн.)"
ars[3] := ' д.р.'+full_date(ldate_r)+'('+s+'), '+iif(lpol=='М','муж.','жен.')+;
          ', осн.диаг.'+osn_diag+;
          iif(empty(sop_diag), '', ', соп.диаг.'+charrem(' ',print_array(sop_diag)))+;
          iif(empty(osl_diag), '', ', диаг.осл.'+charrem(' ',print_array(osl_diag)))
lsex := iif(lpol=='М','1','2')
llos := ''
if ldnej < 4
  llos += '1'
endif
//aadd(ars,'   ║age='+lage+' sex='+lsex+' los='+llos)
if select("K006") == 0
  R_Use(exe_dir+"_mo8k006",{cur_dir+"_mo8k006",cur_dir+"_mo8k006_"},"K006")
  /*{"SHIFR",      "C",     10,      0},;
    {"DS",         "C",      6,      0},;
    {"DS1",        "M",     10,      0},;
    {"DS2",        "M",     10,      0},;
    {"SY",         "C",     20,      0},;
    {"AGE",        "C",      1,      0},;
    {"SEX",        "C",      1,      0},;
    {"LOS",        "C",      1,      0},;
    {"AD_CR",      "C",     10,      0},;*/
  //index on substr(shifr,1,1)+ds+sy to (sbase)      // по диагнозу/операции
  //index on substr(shifr,1,1)+sy+ds to (sbase+"_")  // по операции/диагнозу
endif
fl_reabil := (ascan(ahu,"1.11.2") > 0 .or. ascan(ahu,"55.1.4") > 0)
// собираем КСГ по осн.диагнозу (терапевтические и комбинированные)
ar := {}
tmp := {}
select K006
set order to 1
find (lusl+padr(osn_diag,6))
do while left(k006->shifr,1)==lusl .and. k006->ds==padr(osn_diag,6) .and. !eof()
  lkoef := k006->kz
  select LUSL18
  find (padr(k006->shifr,10))
  fl := lkoef > 0 .and. between_date(lusl18->DATEBEG,lusl18->DATEEND,date_usl)
  if fl
    fl := between_date(k006->DATEBEG,k006->DATEEND,date_usl)
  endif
  if fl
    sds1 := iif(empty(k006->ds1), sp0, alltrim(k006->ds1)+sp6) // соп.диагноз
    sds2 := iif(empty(k006->ds2), sp0, alltrim(k006->ds2)+sp6) // диагн.осложнения
  endif
  j := 0
  if fl .and. !empty(k006->sy)
    if (i := ascan(amohu,k006->sy)) > 0
      j += 10
    else
      fl := .f.
    endif
  endif
  if fl .and. !empty(k006->age)
    if (fl := (k006->age $ lage))
      if k006->age == '1'
        j += 5
      elseif k006->age == '2'
        j += 3
      elseif k006->age == '3'
        j += 2
      else
        j ++
      endif
    endif
  endif
  if fl .and. !empty(k006->sex)
    fl := (k006->sex == lsex)
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(k006->los)
    fl := (k006->los $ llos)
    if fl ; j ++ ; endif
  endif
  if fl
    if empty(lad_cr) // в случае нет доп.критерия
      if !empty(k006->ad_cr) // а в справочнике есть доп.критерий
        fl := .f.
      endif
    else // в случае есть доп.критерий
      if empty(k006->ad_cr) // а в справочнике нет доп.критерия
        fl := .f.
      else                  // а в справочнике есть доп.критерий
        fl := (lad_cr == alltrim(k006->ad_cr))
        if fl ; j ++ ; endif
      endif
    endif
  endif
  if fl .and. !empty(sds1)
    fl := .f.
    for i := 1 to len(sop_diag)
      if sop_diag[i] $ sds1
        fl := .t. ; exit
      endif
    next
    if fl ; j ++ ; endif
  endif
  if fl .and. !empty(sds2)
    fl := .f.
    for i := 1 to len(osl_diag)
      if osl_diag[i] $ sds2
        fl := .t. ; exit
      endif
    next
    if fl ; j ++ ; endif
  endif
  if fl
    if !empty(k006->sy) .and. (i := ascan(amohu,k006->sy)) > 0
      aadd(tmp,i)
    endif
    aadd(ar,{k006->shifr,; //  1
             0,;           //  2
             lkoef,;       //  3
             lusl18->kiro,;  //  4 k006->profil,;
             osn_diag,;    //  5
             k006->sy,;    //  6
             k006->age,;   //  7
             k006->sex,;   //  8
             k006->los,;   //  9
             k006->ad_cr,; // 10
             sds1,;        // 11
             sds2,;        // 12
             j,;           // 13
             lusl18->kslps}) // 14
  endif
  select K006
  skip
enddo
if len(ar) > 0
  for i := 1 to len(tmp)
    im := tmp[i]
    amohu[im] := "" // очистить, чтобы не включать в хирургическую КСГ
  next
  for i := 1 to len(ar)
    ar[i,2] := ret_cena_KSG(ar[i,1],lvr,date_usl)
    if ar[i,2] > 0
      fl_cena := .t.
    endif
  next
  aTerKSG := aclone(ar)
  if len(aTerKSG) > 1
    asort(aTerKSG,,,{|x,y| iif(x[13]==y[13], x[3] > y[3], x[13] > y[13]) })
  endif
  /*aadd(ars,"   ║КСГ: "+print_array(aTerKSG[1]))
  for j := 2 to len(aTerKSG)
    aadd(ars,"   ║     "+print_array(aTerKSG[j]))
  next*/
  if (kol_ter := f_put_debug_KSG(0,aTerKSG,ars)) > 1
    aadd(ars," └─> выбираем КСГ="+aTerKSG[1,1]+" [КЗ="+lstr(aTerKSG[1,3])+"]")
  endif
endif
// собираем КСГ по манипуляциям (хирургические и комбинированные)
ar := {}
for im := 1 to len(amohu)
  if !empty(lshifr := alltrim(amohu[im]))
    select K006
    set order to 2
    find (lusl+padr(lshifr,20))
    do while left(k006->shifr,1)==lusl .and. k006->sy==padr(lshifr,20) .and. !eof()
      lkoef := k006->kz
      select LUSL18
      find (padr(k006->shifr,10))
      fl := lkoef > 0 .and. between_date(lusl18->DATEBEG,lusl18->DATEEND,date_usl)
      if fl
        fl := between_date(k006->DATEBEG,k006->DATEEND,date_usl)
      endif
      if fl
        sds1 := iif(empty(k006->ds1), sp0, alltrim(k006->ds1)+sp6) // соп.диагноз
        sds2 := iif(empty(k006->ds2), sp0, alltrim(k006->ds2)+sp6) // диагн.осложнения
      endif
      j := 0
      if fl .and. !empty(k006->ds)
        fl := (k006->ds == osn_diag)
        if fl ; j += 10 ; endif
      endif
      if fl .and. !empty(k006->age)
        if (fl := (k006->age $ lage))
          if k006->age == '1'
            j += 5
          elseif k006->age == '2'
            j += 3
          elseif k006->age == '3'
            j += 2
          else
            j ++
          endif
        endif
      endif
      if fl .and. !empty(k006->sex)
        fl := (k006->sex == lsex)
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(k006->los)
        fl := (k006->los $ llos)
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(k006->ad_cr)  // в справочнике есть доп.критерий
        fl := .f.
        if !empty(lad_cr)        // в случае есть доп.критерий
          fl := (lad_cr == alltrim(k006->ad_cr))
          if fl ; j ++ ; endif
        endif
      endif
      /*if fl .and. !(left(lad_cr,2) == "sh")
        if empty(lad_cr) // в случае нет доп.критерия
          if !empty(k006->ad_cr) // в справочнике есть доп.критерий
            fl := .f.
          endif
        else // в случае есть доп.критерий
          if empty(k006->ad_cr) // в справочнике нет доп.критерия
            fl := .f.
          else                  // в справочнике есть доп.критерий
            fl := (lad_cr == alltrim(k006->ad_cr))
            if fl ; j ++ ; endif
          endif
        endif
      endif*/
      if fl .and. !empty(sds1)
        fl := .f.
        for i := 1 to len(sop_diag)
          if sop_diag[i] $ sds1
            fl := .t. ; exit
          endif
        next
        if fl ; j ++ ; endif
      endif
      if fl .and. !empty(sds2)
        fl := .f.
        for i := 1 to len(osl_diag)
          if osl_diag[i] $ sds2
            fl := .t. ; exit
          endif
        next
        if fl ; j ++ ; endif
      endif
      if fl
        aadd(ar,{k006->shifr,; //  1
                 0,;           //  2
                 lkoef,;       //  3
                 lusl18->kiro,;  //  4 k006->profil,;
                 k006->ds,;    //  5
                 lshifr,;      //  6
                 k006->age,;   //  7
                 k006->sex,;   //  8
                 k006->los,;   //  9
                 k006->ad_cr,; // 10
                 sds1,;        // 11
                 sds2,;        // 12
                 j,;           // 13
                 lusl18->kslps}) // 14
      endif
      select K006
      skip
    enddo
  endif
next
if len(ar) > 0
  for i := 1 to len(ar)
    ar[i,2] := ret_cena_KSG(ar[i,1],lvr,date_usl)
    if ar[i,2] > 0
      fl_cena := .t.
    endif
  next
  aHirKSG := aclone(ar)
  if len(aHirKSG) > 1
    asort(aHirKSG,,,{|x,y| iif(x[13]==y[13], x[3] > y[3], x[13] > y[13]) })
  endif
  /*aadd(ars,"   ║КСГ: "+print_array(aHirKSG[1]))
  for j := 2 to len(aHirKSG)
    aadd(ars,"   ║     "+print_array(aHirKSG[j]))
  next*/
  if (kol_hir := f_put_debug_KSG(0,aHirKSG,ars)) > 1
    aadd(ars," └─> выбираем КСГ="+aHirKSG[1,1]+" [КЗ="+lstr(aHirKSG[1,3])+"]")
  endif
endif
if kol_ter > 0 .and. kol_hir > 0
  i := int(val(substr(aTerKSG[1,1],2,3)))
  j := int(val(substr(aHirKSG[1,1],2,3)))
  if !empty(aTerKSG[1,6]) // т.е. диагноз + услуга
    lksg  := aTerKSG[1,1]
    lcena := aTerKSG[1,2]
    lkiro := aTerKSG[1,4]
    lkslp := aTerKSG[1,14]
    aadd(ars," выбираем КСГ="+lksg+" (осн.диагноз+услуга "+rtrim(aTerKSG[1,6])+")")
  elseif ascan(a_iskl_1, {|x| x[1]==j .and. eq_any(x[2],0,i) .and. lusl==x[3] }) > 0 // исключение из правил №1
    lksg  := aHirKSG[1,1]
    lcena := aHirKSG[1,2]
    lkiro := aHirKSG[1,4]
    lkslp := aHirKSG[1,14]
    aadd(ars," в соответствии с ИНСТРУКЦИЕЙ по группировке выбираем КСГ="+lstr(j)+" вместо "+lstr(i))
  else
    if aTerKSG[1,3] > aHirKSG[1,3] // "если хирур.КЗ меньше терапевтического КЗ"
      lksg  := aTerKSG[1,1]
      lcena := aTerKSG[1,2]
      lkiro := aTerKSG[1,4]
      lkslp := aTerKSG[1,14]
      aadd(ars," выбираем КСГ="+lstr(i)+" с БОЛЬШИМ коэффициентом затратоёмкости "+lstr(aTerKSG[1,3]))
    else
      lksg  := aHirKSG[1,1]
      lcena := aHirKSG[1,2]
      lkiro := aHirKSG[1,4]
      lkslp := aHirKSG[1,14]
      aadd(ars," оставляем КСГ="+lstr(j)+" с коэффициентом затратоёмкости "+lstr(aHirKSG[1,3]))
    endif
  endif
elseif kol_ter > 0
  lksg  := aTerKSG[1,1]
  lcena := aTerKSG[1,2]
  lkiro := aTerKSG[1,4]
  lkslp := aTerKSG[1,14]
elseif kol_hir > 0
  lksg  := aHirKSG[1,1]
  lcena := aHirKSG[1,2]
  lkiro := aHirKSG[1,4]
  lkslp := aHirKSG[1,14]
endif
akslp := {} ; akiro := {}
if !empty(lksg)
  s := " РЕЗУЛЬТАТ: выбрана КСГ="+lksg
  if empty(lcena)
    s += ", но не определена цена в справочнике ТФОМС"
    aadd(arerr,s)
  else
    s += ", цена "+lstr(lcena,11,2)+"р. "
    aadd(ars,s)
    s := ""
    if left(lksg,4) == '1343' .and. lbartell == '61' // старость
      lkslp := ""
    endif
    akslp := f_cena_kslp(@lcena,lksg,ldate_r,ln_data,lk_data,lkslp,amohu)
    if !empty(akslp)
      s += "  (КСЛП = "+str(akslp[2],4,2)+", цена "+lstr(lcena,11,2)+"р.)"
    endif
    if !empty(lkiro) .and. ldnej < 4
      akiro := f_cena_kiro_18(@lcena,lkiro)
      s += "  (КИРО = "+str(akiro[2],4,2)+", цена "+lstr(lcena,11,2)+"р.)"
    endif
    if !empty(s)
      aadd(ars,s)
    endif
  endif
else
  aadd(arerr," РЕЗУЛЬТАТ: не получилось выбрать КСГ"+;
             iif(fl_reabil,' для случая медицинской реабилитации',''))
endif
return {ars,arerr,alltrim(lksg),lcena,akslp,akiro}

***** 18.01.18
Function f_cena_kiro_18(/*@*/_cena,lkiro)
Local _akiro := {0,1}
if lkiro == 1
  _akiro := {lkiro,0.8}
elseif lkiro == 2
  _akiro := {lkiro,0.2}
endif
_cena := round_5(_cena*_akiro[2],1)
return _akiro

***** 27.08.18 вынуть старый реестр из XML-файлов и записать во временные DBF-файлы
Function extract_old_reestr(mkod,mname_xml,flag_tmp1,is_all,goal_dir)
Local arr_f, ii, oXmlDoc, j, j1, _ar, buf := save_maxrow(), name_zip := alltrim(mname_xml)+szip, fl := .f.
Private pole
for ii := 1 to len(arr_f)
  // читаем файл в память
  oXmlDoc := HXMLDoc():Read(_tmp_dir1+arr_f[ii])
  if oXmlDoc == NIL .or. Empty( oXmlDoc:aItems )
    fl := func_error(4,"Ошибка в чтении файла "+arr_f[ii])
    exit
  endif
  FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
    @ maxrow(),1 say padr(lstr(ii)+"/"+lstr(j),8) color cColorSt2Msg
    oXmlNode := oXmlDoc:aItems[1]:aItems[j]
    do case
      case flag_tmp1 .and. "ZGLV" == oXmlNode:title
        tmp1->_VERSION :=          mo_read_xml_stroke(oXmlNode,"VERSION")
        tmp1->_DATA    := xml2date(mo_read_xml_stroke(oXmlNode,"DATA"))
        tmp1->_FILENAME:=          mo_read_xml_stroke(oXmlNode,"FILENAME")
        tmp1->_SD_Z    :=      val(mo_read_xml_stroke(oXmlNode,"SD_Z",,.f.))
      case flag_tmp1 .and. "SCHET" == oXmlNode:title
        tmp1->_CODE    :=      val(mo_read_xml_stroke(oXmlNode,"CODE"))
        tmp1->_CODE_MO :=          mo_read_xml_stroke(oXmlNode,"CODE_MO")
        tmp1->_YEAR    :=      val(mo_read_xml_stroke(oXmlNode,"YEAR"))
        tmp1->_MONTH   :=      val(mo_read_xml_stroke(oXmlNode,"MONTH"))
        tmp1->_NSCHET  :=          mo_read_xml_stroke(oXmlNode,"NSCHET")
        tmp1->_DSCHET  := xml2date(mo_read_xml_stroke(oXmlNode,"DSCHET"))
        tmp1->_SUMMAV  :=      val(mo_read_xml_stroke(oXmlNode,"SUMMAV"))
      case "ZAP" == oXmlNode:title
        if is_all
          select T1
          append blank
          t1->kod := mkod
          t1->N_ZAP := mo_read_xml_stroke(oXmlNode,"N_ZAP")
          t1->PR_NOV := mo_read_xml_stroke(oXmlNode,"PR_NOV")
          if (oNode1 := oXmlNode:Find("PACIENT")) != NIL
            t1->ID_PAC  := mo_read_xml_stroke(oNode1,"ID_PAC")
            t1->VPOLIS  := mo_read_xml_stroke(oNode1,"VPOLIS")
            t1->SPOLIS  := mo_read_xml_stroke(oNode1,"SPOLIS",,.f.)
            t1->NPOLIS  := mo_read_xml_stroke(oNode1,"NPOLIS")
            t1->ENP     := mo_read_xml_stroke(oNode1,"ENP",,.f.)
            t1->SMO     := mo_read_xml_stroke(oNode1,"SMO")
            t1->SMO_OK  := mo_read_xml_stroke(oNode1,"SMO_OK",,.f.)
            t1->SMO_NAM := mo_read_xml_stroke(oNode1,"SMO_NAM",,.f.)
            t1->MO_PR   := mo_read_xml_stroke(oNode1,"MO_PR",,.f.)
            t1->NOVOR   := mo_read_xml_stroke(oNode1,"NOVOR",,.f.)
            t1->VNOV_D  := mo_read_xml_stroke(oNode1,"VNOV_D",,.f.)
            if (oNode2 := oNode1:Find("DISABILITY")) != NIL
              t1->INV        := mo_read_xml_stroke(oNode2,"INV")
              t1->DATA_INV   := mo_read_xml_stroke(oNode2,"DATA_INV")
              t1->REASON_INV := mo_read_xml_stroke(oNode2,"REASON_INV")
              t1->DS_INV     := mo_read_xml_stroke(oNode2,"DS_INV",,.f.)
            endif
          endif
          if (oNode1 := oXmlNode:Find("SLUCH")) != NIL
            t1->IDCASE   := mo_read_xml_stroke(oNode1,"IDCASE")
            t1->ID_C     := mo_read_xml_stroke(oNode1,"ID_C")
            t1->DISP     := mo_read_xml_stroke(oNode1,"DISP",,.f.)
            t1->USL_OK   := mo_read_xml_stroke(oNode1,"USL_OK")
            t1->VIDPOM   := mo_read_xml_stroke(oNode1,"VIDPOM")
            t1->FOR_POM  := mo_read_xml_stroke(oNode1,"FOR_POM",,.f.)
            t1->VID_HMP  := mo_read_xml_stroke(oNode1,"VID_HMP",,.f.)
            t1->METOD_HMP:= mo_read_xml_stroke(oNode1,"METOD_HMP",,.f.)
            t1->F_SP     := mo_read_xml_stroke(oNode1,"F_SP",,.f.)
            t1->NPR_MO   := mo_read_xml_stroke(oNode1,"NPR_MO",,.f.)
            t1->NPR_DATE := mo_read_xml_stroke(oNode1,"NPR_DATE",,.f.)
            t1->EXTR     := mo_read_xml_stroke(oNode1,"EXTR",,.f.)
            t1->LPU      := mo_read_xml_stroke(oNode1,"LPU")
            t1->LPU_1    := mo_read_xml_stroke(oNode1,"LPU_1",,.f.)
            t1->PODR     := mo_read_xml_stroke(oNode1,"PODR",,.f.)
            t1->PROFIL   := mo_read_xml_stroke(oNode1,"PROFIL")
            t1->PROFIL_K := mo_read_xml_stroke(oNode1,"PROFIL_K",,.f.)
            t1->DET      := mo_read_xml_stroke(oNode1,"DET",,.f.)
            t1->P_CEL    := mo_read_xml_stroke(oNode1,"P_CEL",,.f.)
            t1->TAL_D    := mo_read_xml_stroke(oNode1,"TAL_D",,.f.)
            t1->TAL_P    := mo_read_xml_stroke(oNode1,"TAL_P",,.f.)
            t1->TAL_NUM  := mo_read_xml_stroke(oNode1,"TAL_NUM",,.f.)
            t1->VBR      := mo_read_xml_stroke(oNode1,"VBR",,.f.)
            t1->NHISTORY := mo_read_xml_stroke(oNode1,"NHISTORY")
            t1->P_OTK    := mo_read_xml_stroke(oNode1,"P_OTK",,.f.)
            t1->P_PER    := mo_read_xml_stroke(oNode1,"P_PER",,.f.)
            t1->DATE_1   := mo_read_xml_stroke(oNode1,"DATE_1"  )
            t1->DATE_2   := mo_read_xml_stroke(oNode1,"DATE_2"  )
            t1->DS0      := mo_read_xml_stroke(oNode1,"DS0",,.f.)
            t1->DS1      := mo_read_xml_stroke(oNode1,"DS1")
            t1->DS1_PR   := mo_read_xml_stroke(oNode1,"DS1_PR",,.f.) // для диспансеризации
            t1->PR_D_N   := mo_read_xml_stroke(oNode1,"PR_D_N",,.f.) // для диспансеризации
            // DS2 для диспансеризации
            j1 := 0
            for i := 1 to len(oNode1:aitems) // последовательный просмотр
              oNode2 := oNode1:aItems[i]     // т.к. услуг м.б. несколько
              if valtype(oNode2) != "C" .AND. oNode2:title == "DS2_N"
                if ++j1 > 4 ; exit ; endif
                pole := "t1->DS2N"+iif(j1==1, "", "_"+lstr(j1))
                &pole := mo_read_xml_stroke(oNode2,"DS2")
                pole := "t1->DS2N"+iif(j1==1, "", "_"+lstr(j1))+"_PR"
                &pole := mo_read_xml_stroke(oNode2,"DS2_PR",,.f.)
                pole := "t1->DS2N"+iif(j1==1, "", "_"+lstr(j1))+"_D"
                &pole := mo_read_xml_stroke(oNode2,"PR_D",,.f.)
              endif
            next
            // DS2 для обычного листа учёта
            _ar := mo_read_xml_array(oNode1,"DS2") // М.Б.НЕСКОЛЬКО DS2
            for j1 := 1 to min(7,len(_ar))
              pole := "t1->DS2"+iif(j1==1, "", "_"+lstr(j1))
              &pole := _ar[j1]
            next
            _ar := mo_read_xml_array(oNode1,"DS3") // М.Б.НЕСКОЛЬКО DS3
            for j1 := 1 to min(3,len(_ar))
              pole := "t1->DS3"+iif(j1==1, "", "_"+lstr(j1))
              &pole := _ar[j1]
            next
            t1->DS_ONK := mo_read_xml_stroke(oNode1,"DS_ONK",,.f.)
            t1->C_ZAB := mo_read_xml_stroke(oNode1,"C_ZAB",,.f.)
            t1->DN := mo_read_xml_stroke(oNode1,"DN",,.f.)
            t1->MSE := mo_read_xml_stroke(oNode1,"MSE",,.f.)
            _ar := mo_read_xml_array(oNode1,"VNOV_M") // М.Б.НЕСКОЛЬКО VNOV_M
            for j1 := 1 to min(3,len(_ar))
              pole := "t1->VNOV_M"+iif(j1==1, "", "_"+lstr(j1))
              &pole := _ar[j1]
            next
            t1->CODE_MES1:= mo_read_xml_stroke(oNode1,"CODE_MES1",,.f.)
            if (oNode3 := oNode1:Find("ONK_SL")) != NIL
              t1->DS1_T := mo_read_xml_stroke(oNode3,"DS1_T",,.f.)
              t1->PR_CONS := mo_read_xml_stroke(oNode3,"PR_CONS",,.f.)
              t1->DT_CONS := mo_read_xml_stroke(oNode3,"DT_CONS",,.f.)
              t1->STAD := mo_read_xml_stroke(oNode3,"STAD",,.f.)
              t1->ONK_T := mo_read_xml_stroke(oNode3,"ONK_T",,.f.)
              t1->ONK_N := mo_read_xml_stroke(oNode3,"ONK_N",,.f.)
              t1->ONK_M := mo_read_xml_stroke(oNode3,"ONK_M",,.f.)
              t1->MTSTZ := mo_read_xml_stroke(oNode3,"MTSTZ",,.f.)
              for j1 := 1 to len(oNode3:aitems) // последовательный просмотр
                oNode2 := oNode3:aItems[j1]     // т.к. услуг м.б. несколько
                if valtype(oNode2) != "C" .AND. oNode2:title == "B_DIAG"
                  select T7
                  append blank
                  t7->KOD       := mkod
                  t7->IDCASE    := t1->IDCASE // для связи со случаем
                  t7->DIAG_DATE := mo_read_xml_stroke(oNode2,"DIAG_DATE",,.f.)
                  t7->DIAG_TIP  := mo_read_xml_stroke(oNode2,"DIAG_TIP",,.f.)
                  t7->DIAG_CODE := mo_read_xml_stroke(oNode2,"DIAG_CODE",,.f.)
                  t7->DIAG_RSLT := mo_read_xml_stroke(oNode2,"DIAG_RSLT",,.f.)
                elseif valtype(oNode2) != "C" .AND. oNode2:title == "B_PROT"
                  select T8
                  append blank
                  t8->KOD    := mkod
                  t8->IDCASE := t1->IDCASE // для связи со случаем
                  t8->PROT   := mo_read_xml_stroke(oNode2,"PROT",,.f.)
                  t8->D_PROT := mo_read_xml_stroke(oNode2,"D_PROT",,.f.)
                endif
              next j1
              t1->SOD := mo_read_xml_stroke(oNode3,"SOD",,.f.)
            endif
            t1->RSLT := mo_read_xml_stroke(oNode1,"RSLT")
            if (oNode3 := oNode1:Find("PRESCRIPTION")) != NIL
              for i := 1 to len(oNode3:aitems) // последовательный просмотр
                oNode2 := oNode3:aItems[i]     // т.к. назначений м.б. несколько
                if valtype(oNode2) != "C" .AND. oNode2:title == "PRESCRIPTIONS"
                  select T5
                  append blank
                  t5->KOD    := mkod
                  t5->IDCASE := t1->IDCASE // для связи со случаем
                  t5->NAZ_N  := mo_read_xml_stroke(oNode2,"NAZ_N",,.f.)  // версия 3.1
                  t5->NAZ_R  := mo_read_xml_stroke(oNode2,"NAZ_R",,.f.)  // версия 3.1
                  t5->NAZR   := mo_read_xml_stroke(oNode2,"NAZR",,.f.)
                  _ar := mo_read_xml_array(oNode2,"NAZ_SP") // М.Б.НЕСКОЛЬКО NAZ_SP
                  for j1 := 1 to min(3,len(_ar))
                    pole := "t5->NAZ_SP"+lstr(j1)
                    &pole := _ar[j1]
                  next
                  _ar := mo_read_xml_array(oNode2,"NAZ_V") // М.Б.НЕСКОЛЬКО NAZ_V
                  for j1 := 1 to min(3,len(_ar))
                    pole := "t5->NAZ_V"+lstr(j1)
                    &pole := _ar[j1]
                  next
                  t5->NAZ_PMP := mo_read_xml_stroke(oNode2,"NAZ_PMP",,.f.)
                  t5->NAZ_PK  := mo_read_xml_stroke(oNode2,"NAZ_PK",,.f.)
                endif
              next
            endif
            t1->ISHOD    := mo_read_xml_stroke(oNode1,"ISHOD")
            t1->PRVS     := mo_read_xml_stroke(oNode1,"PRVS")
            t1->IDDOKT   := mo_read_xml_stroke(oNode1,"IDDOKT",,.f.)
            t1->OS_SLUCH := mo_read_xml_stroke(oNode1,"OS_SLUCH",,.f.)
            t1->IDSP     := mo_read_xml_stroke(oNode1,"IDSP")
            t1->ED_COL   := mo_read_xml_stroke(oNode1,"ED_COL",,.f.)
            t1->TARIF    := mo_read_xml_stroke(oNode1,"TARIF",,.f.)
            t1->SUMV     := mo_read_xml_stroke(oNode1,"SUMV")
            t1->AD_CR    := mo_read_xml_stroke(oNode1,"AD_CRITERION",,.f.)
            t1->DKK2     := mo_read_xml_stroke(oNode1,"DKK2",,.f.)
            t1->NEXT_VISIT := mo_read_xml_stroke(oNode1,"NEXT_VISIT",,.f.)
            t1->IT_SL    := mo_read_xml_stroke(oNode1,"IT_SL",,.f.)
            t1->COMENTSL := mo_read_xml_stroke(oNode1,"COMENTSL",,.f.)
            if (oNode3 := oNode1:Find("S_KIRO")) != NIL
              t1->CODE_KIRO := mo_read_xml_stroke(oNode3,"CODE_KIRO")
              t1->VAL_K     := mo_read_xml_stroke(oNode3,"VAL_K")
            endif
            for j1 := 1 to len(oNode1:aitems) // последовательный просмотр
              oNode2 := oNode1:aItems[j1]     // т.к. услуг м.б. несколько
              if valtype(oNode2) != "C" .AND. oNode2:title == "NAPR"
                select T6
                append blank
                t6->KOD      := mkod
                t6->IDCASE   := t1->IDCASE // для связи со случаем
                t6->NAPR_DATE:= mo_read_xml_stroke(oNode2,"NAPR_DATE")
                t6->NAPR_V   := mo_read_xml_stroke(oNode2,"NAPR_V")
                t6->MET_ISSL := mo_read_xml_stroke(oNode2,"MET_ISSL")
                t6->U_KOD    := mo_read_xml_stroke(oNode2,"NAPR_USL")
              elseif valtype(oNode2) != "C" .AND. oNode2:title == "USL"
                select T2
                append blank
                t2->KOD      := mkod
                t2->IDCASE   := t1->IDCASE // для связи со случаем
                t2->IDSERV   := mo_read_xml_stroke(oNode2,"IDSERV")
                t2->ID_U     := mo_read_xml_stroke(oNode2,"ID_U")
                t2->LPU      := mo_read_xml_stroke(oNode2,"LPU")
                t2->LPU_1    := mo_read_xml_stroke(oNode2,"LPU_1",,.f.)
                t2->PODR     := mo_read_xml_stroke(oNode2,"PODR",,.f.)
                t2->PROFIL   := mo_read_xml_stroke(oNode2,"PROFIL")
                t2->VID_VME  := mo_read_xml_stroke(oNode2,"VID_VME",,.f.)
                t2->DET      := mo_read_xml_stroke(oNode2,"DET",,.f.)
                t2->DATE_IN  := mo_read_xml_stroke(oNode2,"DATE_IN")
                t2->DATE_OUT := mo_read_xml_stroke(oNode2,"DATE_OUT")
                t2->P_OTK    := mo_read_xml_stroke(oNode2,"P_OTK",,.f.)
                t2->DS       := mo_read_xml_stroke(oNode2,"DS",,.f.)
                t2->CODE_USL := mo_read_xml_stroke(oNode2,"CODE_USL")
                t2->KOL_USL  := mo_read_xml_stroke(oNode2,"KOL_USL")
                t2->TARIF    := mo_read_xml_stroke(oNode2,"TARIF")
                t2->SUMV_USL := mo_read_xml_stroke(oNode2,"SUMV_USL")
                if (oNode3 := oNode2:Find("ONK_USL")) != NIL
                  t2->USL_TIP  := mo_read_xml_stroke(oNode3,"USL_TIP",,.f.)
                  t2->HIR_TIP  := mo_read_xml_stroke(oNode3,"HIR_TIP",,.f.)
                  t2->LEK_TIP_L:= mo_read_xml_stroke(oNode3,"LEK_TIP_L",,.f.)
                  t2->LEK_TIP_V:= mo_read_xml_stroke(oNode3,"LEK_TIP_V",,.f.)
                  t2->LUCH_TIP := mo_read_xml_stroke(oNode3,"LUCH_TIP",,.f.)
                endif
                t2->PRVS     := mo_read_xml_stroke(oNode2,"PRVS")
                t2->CODE_MD  := mo_read_xml_stroke(oNode2,"CODE_MD",,.f.)
                t2->COMENTU  := mo_read_xml_stroke(oNode2,"COMENTU",,.f.)
              endif
            next
            if (oNode3 := oNode1:Find("SL_KOEFF")) != NIL
              for j1 := 1 to len(oNode3:aitems) // последовательный просмотр
                oNode2 := oNode3:aItems[j1]     // т.к. услуг м.б. несколько
                if valtype(oNode2) != "C" .AND. oNode2:title == "COEFF"
                  select T4
                  append blank
                  t4->KOD      := mkod
                  t4->IDCASE   := t1->IDCASE // для связи со случаем
                  t4->CODE_SL  := mo_read_xml_stroke(oNode2,"CODE_SL")
                  t4->VAL_C    := mo_read_xml_stroke(oNode2,"VAL_C")
                endif
              next
            endif
          endif
        endif
        if flag_tmp1
          tmp1->_KOL ++
          tmp1->_MAX := max(tmp1->_MAX,int(val(mo_read_xml_stroke(oXmlNode,"N_ZAP"))))
        endif
      case is_all .and. "PERS" == oXmlNode:title
        select T3
        append blank
        t3->KOD     := mkod
        t3->ID_PAC  := mo_read_xml_stroke(oXmlNode,"ID_PAC")
        t3->FAM     := mo_read_xml_stroke(oXmlNode,"FAM")
        t3->IM      := mo_read_xml_stroke(oXmlNode,"IM")
        t3->OT      := mo_read_xml_stroke(oXmlNode,"OT",,.f.)
        t3->W       := mo_read_xml_stroke(oXmlNode,"W")
        t3->DR      := mo_read_xml_stroke(oXmlNode,"DR")
        t3->DOST    := mo_read_xml_stroke(oXmlNode,"DOST",,.f.)
        t3->TEL     := mo_read_xml_stroke(oXmlNode,"TEL",,.f.)
        t3->FAM_P   := mo_read_xml_stroke(oXmlNode,"FAM_P",,.f.)
        t3->IM_P    := mo_read_xml_stroke(oXmlNode,"IM_P",,.f.)
        t3->OT_P    := mo_read_xml_stroke(oXmlNode,"OT_P",,.f.)
        t3->W_P     := mo_read_xml_stroke(oXmlNode,"W_P",,.f.)
        t3->DR_P    := mo_read_xml_stroke(oXmlNode,"DR_P",,.f.)
        t3->DOST_P  := mo_read_xml_stroke(oXmlNode,"DOST_P",,.f.)
        t3->MR      := mo_read_xml_stroke(oXmlNode,"MR",,.f.)
        t3->DOCTYPE := mo_read_xml_stroke(oXmlNode,"DOCTYPE",,.f.)
        t3->DOCSER  := mo_read_xml_stroke(oXmlNode,"DOCSER",,.f.)
        t3->DOCNUM  := mo_read_xml_stroke(oXmlNode,"DOCNUM",,.f.)
        t3->SNILS   := mo_read_xml_stroke(oXmlNode,"SNILS",,.f.)
        t3->OKATOG  := mo_read_xml_stroke(oXmlNode,"OKATOG",,.f.)
        t3->OKATOP  := mo_read_xml_stroke(oXmlNode,"OKATOP",,.f.)
    endcase
    if j % 2000 == 0
      commit
    endif
  next j
next ii
return fl