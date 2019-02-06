***** mo_omsi.prg - информация по ОМС
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** вместо иногородней СМО подставить код ТФОМС
Function cut_code_smo(_smo)
Local s := space(5)
if !empty(_smo)
 if left(_smo,3) == '340'
   s := _smo
 else
   s := '34   '
 endif
endif
return s

***** просмотр/печать листов учёта
Function o_list_uch()
Local j := 0, buf := savescreen(), mtitul, func_step := "", r2 := maxrow()-2
if polikl1_kart() > 0
  mywait()
  if yes_parol
    func_step := "f3o_list_uch"
  endif
  Private blk_open := {|| ;
    iif(yes_parol, R_Use(dir_server+"base1",,"BASE1"), nil),;
    R_Use(dir_server+"mo_otd",,"OTD"),;
    R_Use(dir_server+"mo_rees",,"REES"),;
    R_Use(dir_server+"schet_",,"SCHET_"),;
    R_Use(dir_server+"schet",,"SCHET"),;
    dbSetRelation( "SCHET_", {|| recno()}, "recno()" ),;
    R_Use(dir_server+"human_",,"HUMAN_"),;
    R_Use(dir_server+"human",,"HUMAN"),;
    dbSetRelation( "HUMAN_", {|| recno()}, "recno()" ),;
    dbSetRelation( "OTD", {|| otd}, "otd" ),;
    dbSetRelation( "SCHET", {|| schet}, "schet" ) }
  eval(blk_open)
  set index to (dir_server+"humankk")
  find (str(glob_kartotek,7))
  if found()
    mtitul := alltrim(fio)
    index on dtos(k_data)+dtos(n_data) to (cur_dir+"tmp_olu") while kod_k == glob_kartotek descending
    dbeval( {|| ++j } )
    go top
    if yes_parol
      r2 := maxrow()-6
      box_shadow(maxrow()-4,2,maxrow()-2,77,color5)
    endif
    if j > 0
       Alpha_Browse(T_ROW,2,r2,77,"f1o_list_uch",color5,;
                    mtitul,"B/W",,.t.,,func_step,"f4o_list_uch",,;
                    {'═','░','═',"N/W,W+/N,"+;
                                 "B/W,W+/B,"+;
                                 "R/W,W+/R,"+;
                                 "RB/W,W+/RB,"+;
                                 "GR/W,W+/GR,"+;
                                 "BG+/W,W+/BG",.t.} )
    endif
  else
    func_error(4,"В базе данных нет листов учета на выбранного человека!")
  endif
  close databases
endif
restscreen(buf)
return NIL

***** 25.11.14
Function f1o_list_uch(oBrow)
Local oColumn, blk := {|_i| _i:=iif(between(human->tip_h,1,6),human->tip_h,2),;
                            {{1,2},{3,4},{5,6},{7,8},{9,10},{11,12}}[_i] }
//
oColumn := TBColumnNew(" Начало; лечения", {|| date_8(human->n_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Окончание; лечения", {|| date_8(human->k_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" Отд.", {|| otd->short_name })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("  Стоимость;   лечения", ;
                         {|| padl(expand_value(human->cena_1,2),13) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Примечание", {|| padr(f2o_list_uch(human->tip_h),33) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
status_key("^<Esc>^ выход ^<Enter>^ печать л/у ^<F9>^ печать свода л/у ^<F10>^ печать справки ОМС")
return NIL

*****
Function f2o_list_uch(k)
Static arr := {"лечится",;
               "не закончено лечение",;
               "закончено лечение",;
               "",;
               "",;
               ""}
Local s
k := iif(between(k,1,6), k, 4)
s := arr[k]
if k == B_STANDART .and. human_->reestr > 0
  rees->(dbGoto(human_->reestr))
  s := "реестр № "+lstr(rees->nschet)+" от "+date_8(rees->dschet)
endif
if k >= B_SCHET  // добавление номера счета
  s := "счёт № "+alltrim(schet_->nschet)+" от "+date_8(schet_->dschet)
endif
return s

*****
Function f3o_list_uch()
Local s := "Добавление "+date_8(c4tod(human->date_e))+"г. "
if asc(human->kod_p) > 0
  select BASE1
  goto (asc(human->kod_p))
  if !eof() .and. !empty(base1->p1)
    s += alltrim(crypt(base1->p1,gpasskod))+" "
  endif
endif
if !empty(human_->DATE_E2)
  s := alltrim(s)+", "
  s += "исправление "+date_8(c4tod(human_->DATE_E2))+"г. "
  if asc(human_->kod_p2) > 0
    select BASE1
    goto (asc(human_->kod_p2))
    if !eof() .and. !empty(base1->p1)
      s += alltrim(crypt(base1->p1,gpasskod))
    endif
  endif
endif
@ maxrow()-3,3 say padc(s,74) color "B/W"
select HUMAN
return NIL

***** 25.11.14
Function f4o_list_uch(nKey,oBrow)
Local buf, rec, k := -1, fl := .f., arr_m, arr_rec := {}
rec := human->(recno())
if eq_any(nkey,K_ENTER,K_F10)
  fl := .t.
  glob_perso := human->kod
elseif nkey == K_F9
  buf := savescreen()
  change_attr()
  if (arr_m := year_month()) != NIL
    go top
    dbeval( {|| aadd(arr_rec, {human->k_data,human->(recno())}) },;
            {|| between(human->k_data,arr_m[5],arr_m[6]) } )
    if len(arr_rec) > 0
      fl := .t.
      asort(arr_rec,,,{|x,y| x[1] < y[1] } )
    else
      goto (rec)
      func_error(4,"Не найдено листов учета по данному больному в требуемом диапазоне времени!")
    endif
  endif
  restscreen(buf)
endif
if fl
  close databases
  if nkey == K_ENTER
    print_l_uch(glob_perso)
  elseif nkey == K_F9
    print_al_uch(arr_rec,arr_m)
  elseif nkey == K_F10
    print_spravka_OMS(glob_perso)
  endif
  eval(blk_open)
  set index to (cur_dir+"tmp_olu")
  goto (rec)
endif
return k

***** 20.01.19
Function print_l_uch(mkod, par, regim, lnomer)
// mkod - код больного по БД human
Local sh := 80, HH := 77, buf := save_maxrow(),;
      name_lpu, name_otd := "", mvzros_reb, mreg_lech, mmest_inog, mrab_nerab,;
      mkomu, name_org, mlech_vr := "", mishod, mprodol, msumma := 0, mmi_git,;
      mud_lich := "", arr, n_file := "list_uch"+stxt, adiag_talon[16],;
      madres, i := 1, j, k, tmp[2], tmp1, w1 := 37, s, s1, mnum_lu, lshifr1
DEFAULT par TO 1, regim TO 1, lnomer TO 0
mywait()
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
//
R_Use(dir_server+"organiz",,"ORG")
name_org := alltrim(org->name)
dbCloseAll()
if !myFileDeleted(cur_dir+"tmp1"+sdbf)
  return NIL
endif
dbcreate(cur_dir+"tmp1",{{"kod","N",4,0},;
                         {"name","C",255,0},;
                         {"shifr","C",20,0},;
                         {"shifr1","C",20,0},;
                         {"dom","N",1,0},;
                         {"zf","C",30,0},;
                         {"kod_diag","C",5,0},;
                         {"date_u1","D",8,0},;
                         {"date_u2","D",8,0},;
                         {"rec_hu","N",8,0},;
                         {"otd","C",5,0},;
                         {"plus","L",1,0},;
                         {"is_edit","N",2,0},;
                         {"kod_vr","N",5,0},;
                         {"kod_as","N",5,0},;
                         {"profil","N",4,0},;
                         {"kol","N",4,0},;
                         {"summa","N",11,2}})
use (cur_dir+"tmp1")
index on str(kod,4) to (cur_dir+"tmp11")
index on dtos(date_u1)+fsort_usl(shifr) to (cur_dir+"tmp12")
use (cur_dir+"tmp1") index (cur_dir+"tmp11"),(cur_dir+"tmp12") alias tmp1
Use_base("lusl")
Use_base("luslf")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to recno() into HU_
R_Use(dir_server+"mo_su",,"MOSU")
R_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"human_2",,"HUMAN_2")
goto (mkod)
R_Use(dir_server+"human_",,"HUMAN_")
goto (mkod)
R_Use(dir_server+"human",,"HUMAN")
goto (mkod)
R_Use(dir_server+"mo_pers",,"PERSO")
goto (human_->vrach)
mlech_vr := iif(empty(perso->tab_nom), "", lstr(perso->tab_nom)+" ")+alltrim(perso->fio)
otd->(dbGoto(human->otd))
R_Use(dir_server+"kartote_",,"KART_")
goto (human->kod_k)
R_Use(dir_server+"kartotek",,"KART")
goto (human->kod_k)
//
Private mvid_ud := kart_->vid_ud,;
        mser    := kart_->ser_ud,;
        mnom    := kart_->nom_ud,;
        m1kategor := kart_->kategor,;
        m1povod  := human_->POVOD,;
        m1travma := human_->TRAVMA
afill(adiag_talon,0)
for i := 1 to 16
  adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
next
Private M1F14_EKST := int(val(substr(human_->FORMA14,1,1)))
Private M1F14_SKOR := int(val(substr(human_->FORMA14,2,1)))
Private M1F14_VSKR := int(val(substr(human_->FORMA14,3,1)))
Private M1F14_RASH := int(val(substr(human_->FORMA14,4,1)))
if mvid_ud > 0
  mud_lich := ""
  if (j := ascan(menu_vidud, {|x| x[2] == mvid_ud})) > 0
    mud_lich := menu_vidud[j,4]+": "
  endif
  if !empty(mser)
    mud_lich += charone(" ",mser)+" "
  endif
  if !empty(mnom)
    mud_lich += mnom+" "
  endif
endif
mpolis := alltrim(rtrim(human_->SPOLIS)+" "+human_->NPOLIS)+" ("+;
          alltrim(inieditspr(A__MENUVERT, mm_vid_polis, human_->VPOLIS))+")"
madres := iif(emptyall(kart_->okatog,kart->adres), "",;
              ret_okato_ulica(kart->adres,kart_->okatog))
madresp := iif(emptyall(kart_->okatop,kart_->adresp), "",;
               ret_okato_ulica(kart_->adresp,kart_->okatop))
//
if human->tip_h >= B_SCHET .and. human->schet > 0 // добавление номера счета
  R_Use(dir_server+"schet_",,"SCHET_")
  goto (human->schet)
  R_Use(dir_server+"schet",,"SCHET")
  goto (human->schet)
  add_string("Счет № "+alltrim(schet_->nschet)+" от "+date_8(schet_->dschet)+"г."+;
             if(human_->SCHET_ZAP==0, "", "  [ № "+lstr(human_->SCHET_ZAP)+" ]"))
  if eq_any(human_->oplata,2,3,9)
    s := iif(eq_any(human_->oplata,2,9),"Не","Частично")+" оплачен. "
    if human_->oplata == 3
      s += "("+lstr(human_->sump)+") "
    endif
    R_Use(dir_server+"mo_os",,"MO_OS")
    Locate for kod == mkod
    if found()
      s += "Акт № "+alltrim(mo_os->AKT)+" от "+date_8(mo_os->DATE_OPL)+" "
      if !empty(s1 := ret_t005(mo_os->REFREASON))
        s += "Код дефекта "+s1+". "
      endif
      if mo_os->IS_REPEAT == 1
        s += "Лист учёта выставлен повторно."
      endif
    else
      R_Use(dir_server+"mo_rak",,"RAK")
      R_Use(dir_server+"mo_raks",,"RAKS")
      set relation to akt into RAK
      R_Use(dir_server+"mo_raksh",,"RAKSH")
      set relation to kod_raks into RAKS
      arr := {}
      Locate for kod_h == mkod
      do while found()
        aadd(arr, {rak->NAKT,rak->DAKT,raksh->REFREASON,raksh->NEXT_KOD})
        continue
      enddo
      asort(arr,,,{|x,y| x[2] < y[2] })
      for i := 1 to len(arr)
        s += "Акт № "+alltrim(arr[i,1])+" от "+date_8(arr[i,2])+". "
        if !empty(s1 := ret_t005(arr[i,3]))
          s += "Код дефекта "+s1+". "
        endif
        if arr[i,4] > 0
          s += "Лист учёта выставлен повторно. "
        endif
        if i < len(arr)
          s += "; "
        endif
      next
    endif
    for i := 1 to perenos(tmp,s,sh)
      add_string(tmp[i])
    next
  endif
  add_string("")
endif
name_lpu := rtrim(inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->lpu))
name_otd := "  [ "+alltrim(otd->name)+" ]"
mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, human->vzros_reb)
mrab_nerab := inieditspr(A__MENUVERT, menu_rab, kart->rab_nerab)
mkomu := f4_view_list_schet(human->komu,cut_code_smo(human_->smo),human->str_crb)
mnum_lu := alltrim(human->uch_doc)
if yes_num_lu == 1
  mnum_lu += " ["+lstr(human->kod)+"]"
endif
//
for i := 1 to perenos(tmp,name_org,sh)
  add_string(center(alltrim(tmp[i]),sh))
next
add_string("")
add_string(center(name_lpu+name_otd,sh))
add_string("")
add_string(center("Л_И_С_Т  У_Ч_Е_Т_А",sh))
add_string(center("М_Е_Д_И_Ц_И_Н_С_К_И_Х  У_С_Л_У_Г  № "+mnum_lu,sh))
print_l_uch_disp(sh)
add_string("")
add_string("  Ф.И.О.: "+human->fio+"          Пол: "+human->pol)
add_string("  Дата рождения: "+full_date(human->date_r)+"  ("+mvzros_reb+")")
if !empty(mud_lich)
  k := perenos(tmp,mud_lich,sh-2)
  add_string("  "+tmp[1])
  for i := 2 to k
    add_string(padl(alltrim(tmp[i]),sh))
  next
endif
k := perenos(tmp,"Место рождения: "+kart_->mesto_r,sh-2)
add_string("  "+tmp[1])
for i := 2 to k
  add_string(padl(alltrim(tmp[i]),sh))
next
k := perenos(tmp,"Адрес регистрации: "+madres,sh-2)
add_string("  "+tmp[1])
for i := 2 to k
  add_string(padl(alltrim(tmp[i]),sh))
next
if !empty(madresp)
  k := perenos(tmp,"Адрес пребывания: "+madresp,sh-2)
  add_string("  "+tmp[1])
  for i := 2 to k
    add_string(padl(alltrim(tmp[i]),sh))
  next
endif
if !empty(human->mr_dol)
  add_string("  Место работы/учебы: "+human->mr_dol)
endif
add_string("  Статус пациента: "+mrab_nerab)
if human_->NOVOR > 0
  add_string("")
  add_string("  Новорожденный: "+lstr(human_->NOVOR)+"-й ребёнок, д.р. "+;
             date_8(human_->DATE_R2)+", пол "+human_->POL2)
  add_string("")
endif
if !empty(human_->NPR_MO) .and. !(human_->NPR_MO == glob_mo[_MO_KOD_TFOMS])
  k := perenos(tmp,"Направившая МО: "+ret_mo(human_->NPR_MO)[_MO_FULL_NAME],sh-2)
  add_string("  "+tmp[1])
  for i := 2 to k
    add_string(padl(alltrim(tmp[i]),sh))
  next
  if !empty(human_2->NPR_DATE)
    add_string("  Дата направления: "+full_date(human_2->NPR_DATE))
  endif
endif
add_string("  Принадлежность счета: "+mkomu)
add_string("                     Серия и номер страхового полиса: "+mpolis)
if M1F14_EKST == 1
  s := "  Госпитализирован по экстренным показаниям"
  if M1F14_SKOR == 1
    s += " (доставлен скорой мед.помощью)"
  endif
  add_string(s)
endif
s := "  "
if !empty(human_->KOD_DIAG0)
  s := padr("  Первичный диагноз: "+human_->KOD_DIAG0,40)
endif
//if !empty(human_->STATUS_ST)
  //s += "Статус стом.больного: "+alltrim(human_->STATUS_ST)
//endif
if !empty(s)
  add_string(s)
endif
arr := diag_to_array(,.t.,.t.,.t.,.t.,adiag_talon)
if len(arr) > 0
  add_string("  Основной диагноз: "+arr[1])
  if len(arr) > 1
    tmp1 := "  Сопутствующие диагнозы:"
    for j := 2 to len(arr)
      tmp1 += " "+arr[j]
    next
    add_string(tmp1)
  endif
endif
tmp1 := ""
arr := {human_2->OSL1,human_2->OSL2,human_2->OSL3}
for j := 1 to len(arr)
  tmp1 += " "+arr[j]
next
if !empty(tmp1)
  add_string("  Диагнозы осложнения:"+tmp1)
endif  
add_string("  Медицинская помощь: условия оказания: "+inieditspr(A__MENUVERT, glob_V006, human_->USL_OK))
//add_string("    вид: "+inieditspr(A__MENUVERT, glob_V008, human_->VIDPOM))
if human_->PROFIL > 0
  k := perenos(tmp,"профиль: "+inieditspr(A__MENUVERT, glob_V002, human_->PROFIL),sh-4)
  add_string(space(4)+tmp[1])
  for i := 2 to k
    add_string(padl(alltrim(tmp[i]),sh))
  next
endif
if human_2->PROFIL_K > 0 .and. human_->USL_OK < 3
  k := perenos(tmp,"профиль койки: "+inieditspr(A__MENUVERT, glob_V020, human_2->PROFIL_K),sh-4)
  add_string(space(4)+tmp[1])
  for i := 2 to k
    add_string(padl(alltrim(tmp[i]),sh))
  next
endif
k := perenos(tmp,inieditspr(A__MENUVERT, glob_V010, human_->IDSP),sh-19)
add_string("    способ оплаты: "+tmp[1])
for i := 2 to k
  add_string(space(19)+tmp[i])
next
k := perenos(tmp,"Результат обращения: "+inieditspr(A__MENUVERT, glob_V009, human_->RSLT_NEW),sh-2)
add_string("  "+tmp[1])
for i := 2 to k
  add_string(padl(alltrim(tmp[i]),sh))
next
add_string("  Исход заболевания: "+inieditspr(A__MENUVERT, glob_V012, human_->ISHOD_NEW))
if is_death(human_->RSLT_NEW) .and. M1F14_VSKR == 1 // смерть
  s := "  Проведено патологоанатомическое вскрытие"
  if M1F14_RASH == 1
    s += " (установлено расхождение диагнозов)"
  endif
  add_string(s)
endif
if human_2->VMP == 1 .and. !empty(human_2->VIDVMP)
  if !empty(human_2->TAL_NUM)
    add_string("  Номер талона на ВМП: "+human_2->TAL_NUM)
  endif
  k := perenos(tmp,ret_V018(human_2->VIDVMP,human->k_data),sh-11)
  add_string("  Вид ВМП: "+tmp[1])
  for i := 2 to k
    add_string(space(11)+tmp[i])
  next
  if !empty(human_2->METVMP)
    k := perenos(tmp,ret_V019(human_2->METVMP,human_2->VIDVMP,human->k_data),sh-14)
    add_string("   метод ВМП: "+tmp[1])
    for i := 2 to k
      add_string(space(14)+tmp[i])
    next
  endif
endif
if year(human->k_data) > 2017 .and. !empty(human_2->pc3)
  add_string("  Дополнительный критерий : "+human_2->pc3)
endif
if !empty(mlech_vr)
  add_string("  Лечащий врач : "+mlech_vr)
endif
add_string("")
add_string(center("Срок лечения с "+full_date(human->n_data)+" по "+full_date(human->k_data),sh))
add_string("")
if human->bolnich > 0
  add_string("  Временная нетрудоспособность (больничный) с "+;
             full_date(c4tod(human->date_b_1))+" по "+full_date(c4tod(human->date_b_2)))
  if human->bolnich == 2
    add_string("  (По уходу: дата рождения родителя "+;
               full_date(human_->RODIT_DR)+", пол "+human_->RODIT_POL+")")
  endif
  add_string("")
endif
add_string(center("О_К_А_З_А_Н_Ы   У_С_Л_У_Г_И",sh))
Select HU
find (str(mkod,7))
do while hu->kod == mkod .and. !eof()
  if !emptyall(hu->kol_1,hu->stoim_1)
    Select OTD
    goto (hu->otd)
    Select USL
    goto (hu->u_kod)
    lname := usl->name
    select LUSL
    find (padr(usl->shifr,10))
    if found()
      lname := lusl->name  // наименование услуги из справочника ТФОМС
    else
      select LUSL18
      find (padr(usl->shifr,10))
      if found()
        lname := lusl18->name  // наименование услуги из справочника ТФОМС
      endif
    endif
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    select TMP1
    append blank
    tmp1->kod := usl->kod
    tmp1->name := lname
    tmp1->shifr := usl->shifr //iif(empty(lshifr1), usl->shifr, lshifr1)
    tmp1->shifr1 := lshifr1
    tmp1->date_u1 := c4tod(hu->date_u)
    tmp1->date_u2 := c4tod(hu_->date_u2)
    tmp1->rec_hu := hu->(recno())
    tmp1->kod_diag := hu_->KOD_DIAG
    tmp1->dom := iif(between(hu->kol_rcp,-2,-1), -hu->kol_rcp, 0)
    tmp1->otd := otd->short_name
    if human->k_data < 0d20120301
      tmp1->plus := !f_paraklinika(usl->shifr,lshifr1,c4tod(hu->date_u))
    else
      tmp1->plus := !f_paraklinika(usl->shifr,lshifr1,human->k_data)
    endif
    tmp1->profil := hu_->profil
    tmp1->is_edit := hu->is_edit
    tmp1->kod_vr := hu->kod_vr
    tmp1->kod_as := hu->kod_as
    tmp1->kol += hu->kol_1
    tmp1->summa += hu->stoim_1
  endif
  select HU
  Skip
enddo
Select MOHU
find (str(mkod,7))
do while mohu->kod == mkod .and. !eof()
  if !empty(mohu->kol_1)
    Select OTD
    goto (mohu->otd)
    Select MOSU
    goto (mohu->u_kod)
    lname := mosu->name
    if year(human->k_data) > 2018
      select LUSLF
      find (padr(mosu->shifr1,20))
      if found()
        lname := luslf->name  // наименование услуги из справочника ТФОМС
      endif
    else
      select LUSLF18
      find (padr(mosu->shifr1,20))
      if found()
        lname := luslf18->name  // наименование услуги из справочника ТФОМС
      endif
    endif
    select TMP1
    append blank
    tmp1->kod := mosu->kod
    tmp1->name := lname
    tmp1->shifr := iif(empty(mosu->shifr), mosu->shifr1, mosu->shifr)
    tmp1->shifr1 := mosu->shifr1
    tmp1->date_u1 := c4tod(mohu->date_u)
    tmp1->date_u2 := c4tod(mohu->date_u2)
    tmp1->rec_hu := mohu->(recno())
    tmp1->kod_diag := mohu->KOD_DIAG
    if STisZF(human_->USL_OK,human_->PROFIL)
      tmp1->zf := mohu->ZF
    endif
    tmp1->otd := otd->short_name
    tmp1->plus := .f.
    tmp1->kod_vr := mohu->kod_vr
    tmp1->kod_as := mohu->kod_as
    tmp1->kol += mohu->kol_1
    tmp1->summa += mohu->stoim_1
  endif
  select MOHU
  Skip
enddo
mpsumma := 0
w1 := 34
print1_l_uch(w1)
select TMP1
set order TO 2
go top
do while !eof()
  s := alltrim(tmp1->shifr)
  if !(alltrim(tmp1->shifr) == alltrim(tmp1->shifr1)) .and. !empty(tmp1->shifr1)
    s += "("+alltrim(tmp1->shifr1)+")"
  endif
  s += iif(tmp1->dom==1,"/на дому/",iif(tmp1->dom==2,"/домАКТИВ/"," "))
  s += alltrim(tmp1->name)
  if eq_any(alltrim(tmp1->shifr),"2.3.1","2.3.3","2.6.1","2.60.1")
    s += " ("+alltrim(inieditspr(A__MENUVERT, glob_V002, tmp1->PROFIL))+")"
  elseif !empty(tmp1->zf)
    s += " ЗФ:"+alltrim(tmp1->ZF)
  endif
  k := perenos(tmp,s,w1)
  if verify_FF(HH)
    print1_l_uch(w1)
  endif
  if eq_any(left(tmp1->shifr,5),"1.11.","55.1.")
    s := left(date_8(tmp1->date_u1),2)+"-"+left(date_8(tmp1->date_u2),5)+" "
  else
    s := date_8(tmp1->date_u1)+" "
  endif
  if tmp1->is_edit == 1
    s += "КДП№2 "
  elseif tmp1->is_edit == -1
    s += "ЦКДЛ  "
  elseif alltrim(tmp1->shifr) == "4.20.2" 
    s += "ВОКОД "
  else
    s += tmp1->otd+" "
  endif
  s += tmp1->kod_diag+" "
  s += padr(tmp[1],w1)
  s += put_val(ret_tabn(tmp1->kod_vr),6)+;
       put_val(ret_tabn(tmp1->kod_as),6)
  if tmp1->plus
    s += padl("+"+lstr(tmp1->kol),4)
    mpsumma += tmp1->summa
  else
    if tmp1->summa >= 100000
      s += " "+padr(lstr(tmp1->kol),3)
    else
      s += put_val(tmp1->kol,4)
    endif
    msumma += tmp1->summa
  endif
  s += put_kopE(tmp1->summa,9)
  add_string(s)
  s1 := ""
  if tmp1->summa > 0 .and. is_ksg(tmp1->shifr)
    if year(human->k_data) > 2017
      if !empty(human_2->pc1)
        akslp := List2Arr(human_2->pc1)
        if len(akslp) > 1
          s1 += "(с учётом КСЛП="+str(ret_koef_kslp(akslp),4,2)+") " 
        endif
      endif
      if !empty(human_2->pc2)
        akiro := List2Arr(human_2->pc2)
        if len(akiro) > 1
          s1 += "(с учётом КИРО="+str(akiro[2],4,2)+")" 
        endif
      endif
    elseif human_->USL_OK == 1 // стационар
      s := iif(empty(tmp1->shifr1),tmp1->shifr,tmp1->shifr1)
      if human_->USL_OK < 3 .and. !empty(human_2->pc1)
        akslp := List2Arr(human_2->pc1)
        if len(akslp) > 1 .and. valtype(akslp) == "N"
          s1 += "(с учётом КСЛП="+str(akslp[2],4,2)+")"
        endif 
      endif
    endif
  endif
  if k == 1 .and. !empty(s1)
    k := 2
  endif
  for i := 2 to k
    add_string(space(21)+padl(rtrim(tmp[i]),w1)+iif(i==2.and.!empty(s1),padl(s1,25),""))
  next
  select TMP1
  skip
enddo
zap
set order to 1
add_string(replicate("-",sh))
s := "Общая сумма лечения: "+put_kop(human->cena_1,12)
if mpsumma > 0
  s := alltrim(s)+" (+"+lput_kop(mpsumma,.t.)+")"
endif
add_string(padl(s,sh))
close databases
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.f.,,,5)
return NIL

*****
Static Function print1_l_uch(w1)
add_string("────────┬─────┬─────┬"+replicate("─",w1)             +"┬─────┬─────┬───┬────────")
add_string("  Дата  │ Отд.│МКБ10│"+padc("Наименование услуги",w1)+"│ Врач│ Асс.│Кол│ Сумма  ")
add_string("────────┴─────┴─────┴"+replicate("─",w1)             +"┴─────┴─────┴───┴────────")
return NIL

***** 14.02.18 печать доп.заголовка, если это лист учёта диспансеризации/профилактики
Function print_l_uch_disp(sh)
Local s := ""
if eq_any(human->ishod,101,102)
  s := "диспансеризация детей-сирот "+;
       iif(!empty(human->ZA_SMO), "в стационаре", "под опекой")+;
       iif(human->ishod==101, " I этап", " I и II этап")
elseif eq_any(human->ishod,201,202,203)
  s := iif(human->ishod==203, "профилактика", "диспансеризация")+;
       " опр.групп взрослого населения"
  if eq_any(human->ishod,201,202)
    s += iif(human->ishod==201, " I", " II")+" этап"
  endif
elseif eq_any(human->ishod,204,205)
  s := "диспансеризация опр.групп взрослого населения (1 раз в 2 года) "+iif(human->ishod==204,"I","II")+" этап"
elseif eq_any(human->ishod,301,302)
  s := "профилактика несовершеннолетних"+;
       iif(human->ishod==301, " I этап", " I и II этап")
elseif eq_any(human->ishod,303,304)
  s := "предварительный осмотр несовершеннолетних"+;
       iif(human->ishod==303, " I этап", " I и II этап")
elseif human->ishod == 305
  s := "периодический осмотр несовершеннолетних"
endif
if !empty(s)
  add_string("")
  add_string(center(" ["+s+"]",sh))
endif
return NIL

***** 12.11.13 печать нескольких листов учёта
Function print_al_uch(arr_h,arr_m)
Local sh := 80, HH := 77, buf := save_maxrow(),;
      name_lpu, mvzros_reb, mreg_lech, mmest_inog, mrab_nerab,;
      mkomu, name_org, mlech_vr := "", mishod, mprodol, msumma := 0, mmi_git,;
      mud_lich := "", arr, n_file := "list_uch"+stxt, adiag_talon[16],;
      i := 1, j, k, tmp[2], tmp1, w1 := 65, s, mnum_lu, fl_parakl, lshifr1
mywait()
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
//
R_Use(dir_server+"organiz")
name_org := center(alltrim(name),sh)
dbCloseAll()
if !myFileDeleted(cur_dir+"tmp1"+sdbf)
  return NIL
endif
dbcreate(cur_dir+"tmp1",{{"kod","N",4,0},;
                 {"name","C",65,0},;
                 {"shifr","C",10,0},;
                 {"dom","N",1,0},;
                 {"zf","C",30,0},;
                 {"kod_diag","C",5,0},;
                 {"date_u1","D",8,0},;
                 {"rec_hu","N",8,0},;
                 {"otd","C",5,0},;
                 {"plus","L",1,0},;
                 {"is_edit","N",2,0},;
                 {"kod_vr","N",5,0},;
                 {"kod_as","N",5,0},;
                 {"profil","N",4,0},;
                 {"kol","N",4,0},;
                 {"summa","N",11,2}})
use (cur_dir+"tmp1")
index on str(kod,4) to (cur_dir+"tmp11")
index on dtos(date_u1)+fsort_usl(shifr) to (cur_dir+"tmp12")
dbCloseAll()
//
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_
goto ( atail(arr_h)[2] )
mpolis := alltrim(rtrim(human_->SPOLIS)+" "+human_->NPOLIS)+" ("+;
          alltrim(inieditspr(A__MENUVERT, mm_vid_polis, human_->VPOLIS))+")"
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
goto (human->kod_k)
madres := iif(emptyall(kart_->okatog,kart->adres), "",;
              ret_okato_ulica(kart->adres,kart_->okatog))
Private mvid_ud := kart_->vid_ud,;
        mser    := kart_->ser_ud,;
        mnom    := kart_->nom_ud
if mvid_ud > 0
  mud_lich := ""
  if (j := ascan(menu_vidud, {|x| x[2] == mvid_ud})) > 0
    mud_lich := menu_vidud[j,4]+": "
  endif
  if !empty(mser)
    mud_lich += charone(" ",mser)+" "
  endif
  if !empty(mnom)
    mud_lich += mnom+" "
  endif
endif
//
mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, human->vzros_reb)
mrab_nerab := inieditspr(A__MENUVERT, menu_rab, human->rab_nerab)
mkomu := f4_view_list_schet(human->komu,cut_code_smo(human_->smo),human->str_crb)
mnum_lu := alltrim(human->uch_doc)
if yes_num_lu == 1
  mnum_lu += " ["+lstr(human->kod)+"]"
endif
add_string(name_org)
add_string("")
add_string(center("Л_И_С_Ты  У_Ч_Е_Т_А",sh))
add_string(center("М_Е_Д_И_Ц_И_Н_С_К_И_Х  У_С_Л_У_Г  № "+mnum_lu,sh))
add_string(center(arr_m[4],sh))
add_string("")
add_string("  Ф.И.О.: "+human->fio+"          Пол: "+human->pol)
add_string("  Дата рождения: "+full_date(human->date_r)+"  [ "+mvzros_reb+" ]")
if !empty(mud_lich)
  k := perenos(tmp,mud_lich,sh-2)
  add_string("  "+tmp[1])
  for i := 2 to k
    add_string(padl(alltrim(tmp[i]),sh))
  next
endif
add_string("  Адрес: "+madres)
if !empty(kart->mr_dol)
  add_string("  Место работы/учебы: "+human->mr_dol)
endif
add_string("  Статус пациента: "+mrab_nerab)
add_string("  Принадлежность счета: "+mkomu)
add_string("  Полис: "+mpolis)
//
R_Use(dir_server+"mo_uch",,"UCH")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"mo_pers",,"PERSO")
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",,"SCHET")
set relation to recno() into SCHET_
R_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to recno() into HU_
R_Use(dir_server+"mo_su",,"MOSU")
R_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
use (cur_dir+"tmp1") index (cur_dir+"tmp11"),(cur_dir+"tmp12") new alias tmp1
for ii := 1 to len(arr_h)
  select TMP1
  set order to 1
  zap
  select HUMAN
  goto (arr_h[ii,2])
  if human->schet > 0
    schet->(dbGoto(human->schet))
  endif
  mlech_vr := ""
  if human_->vrach > 0
    select PERSO
    goto (human_->vrach)
    mlech_vr := alltrim(perso->fio)
  endif
  //
  afill(adiag_talon,0)
  for j := 1 to 16
    adiag_talon[j] := int(val(substr(human_->DISPANS,j,1)))
  next
  //
  verify_FF(HH-5,.t.,sh)
  print_l_uch_disp(sh)
  add_string("")
  add_string(padc(" Срок лечения с "+full_date(human->n_data)+" по "+full_date(human->k_data)+" ",sh,"─"))
  uch->(dbGoto(human->lpu))
  otd->(dbGoto(human->otd))
  add_string("  Условия: "+;
             inieditspr(A__MENUVERT, glob_V006, human_->USL_OK)+", "+;
             alltrim(otd->name)+" ["+alltrim(uch->name)+"]")
  s := "  "
  if !empty(human_->KOD_DIAG0)
    s := padr("  Первичный диагноз: "+human_->KOD_DIAG0,40)
  endif
  if !empty(human_->STATUS_ST)
    s += "Статус стом.больного: "+alltrim(human_->STATUS_ST)
  endif
  if !empty(s)
    add_string(s)
  endif
  arr := diag_to_array(,.t.,.t.,.t.,.t.,adiag_talon)
  if len(arr) > 0
    add_string("  Шифр основного заболевания: "+arr[1])
    if len(arr) > 1
      tmp1 := "  Шифры сопутствующих заболеваний:"
      for j := 2 to len(arr)
        tmp1 += " "+arr[j]
      next
      add_string(tmp1)
    endif
  endif
  verify_FF(HH-6,.t.,sh)
  if human_->PROFIL > 0
    add_string("  Профиль: "+inieditspr(A__MENUVERT, glob_V002, human_->PROFIL))
  endif
  add_string("  Способ оплаты: "+inieditspr(A__MENUVERT, glob_V010, human_->IDSP))
  add_string("  Результат обращения: "+inieditspr(A__MENUVERT, glob_V009, human_->RSLT_NEW))
  add_string("  Исход заболевания: "+inieditspr(A__MENUVERT, glob_V012, human_->ISHOD_NEW))
  if !empty(mlech_vr)
    add_string("  Лечащий врач : "+mlech_vr)
  endif
  if human->bolnich > 0
    add_string("  Временная нетрудоспособность (больничный) с "+;
               full_date(c4tod(human->date_b_1))+" по "+full_date(c4tod(human->date_b_2)))
    add_string("")
  endif
  Select HU
  find (str(arr_h[ii,2],7))
  do while hu->kod == arr_h[ii,2] .and. !eof()
    if !emptyall(hu->kol_1,hu->stoim_1)
      Select OTD
      goto (hu->otd)
      Select USL
      goto (hu->u_kod)
      lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
      select TMP1
      append blank
      tmp1->kod := usl->kod
      tmp1->name := usl->name
      tmp1->shifr := usl->shifr //iif(empty(lshifr1), usl->shifr, lshifr1)
      tmp1->date_u1 := c4tod(hu->date_u)
      tmp1->dom := iif(between(hu->kol_rcp,-2,-1), -hu->kol_rcp, 0)
      tmp1->rec_hu := hu->(recno())
      tmp1->kod_diag := hu_->KOD_DIAG
      tmp1->otd := otd->short_name
      if human->k_data < 0d20120301
        tmp1->plus := !f_paraklinika(usl->shifr,lshifr1,c4tod(hu->date_u))
      else
        tmp1->plus := !f_paraklinika(usl->shifr,lshifr1,human->k_data)
      endif
      tmp1->is_edit := hu->is_edit
      tmp1->kod_vr := hu->kod_vr
      tmp1->kod_as := hu->kod_as
      tmp1->profil := hu_->profil
      tmp1->kol += hu->kol_1
      tmp1->summa += hu->stoim_1
    endif
    select HU
    Skip
  enddo
  Select MOHU
  find (str(arr_h[ii,2],7))
  do while mohu->kod == arr_h[ii,2] .and. !eof()
    if !empty(mohu->kol_1)
      Select OTD
      goto (mohu->otd)
      Select MOSU
      goto (mohu->u_kod)
      select TMP1
      append blank
      tmp1->kod := mosu->kod
      tmp1->name := mosu->name
      tmp1->shifr := iif(empty(mosu->shifr), mosu->shifr1, mosu->shifr)
      tmp1->date_u1 := c4tod(mohu->date_u)
      tmp1->rec_hu := mohu->(recno())
      tmp1->kod_diag := mohu->KOD_DIAG
      if STisZF(human_->USL_OK,human_->PROFIL)
        tmp1->zf := mohu->ZF
      endif
      tmp1->otd := otd->short_name
      tmp1->plus := .f.
      tmp1->kod_vr := mohu->kod_vr
      tmp1->kod_as := mohu->kod_as
      tmp1->kol += mohu->kol_1
      tmp1->summa += mohu->stoim_1
    endif
    select MOHU
    Skip
  enddo
  mpsumma := 0
  verify_FF(HH-4,.t.,sh)
  w1 := 34
  print1_l_uch(w1)
  select TMP1
  set order TO 2
  go top
  do while !eof()
    s := alltrim(tmp1->shifr)+iif(tmp1->dom==1,"/на дому/",iif(tmp1->dom==2,"/домАКТИВ/"," "))+alltrim(tmp1->name)
    if eq_any(alltrim(tmp1->shifr),"2.3.1","2.3.3","2.6.1","2.60.1")
      s += " ("+alltrim(inieditspr(A__MENUVERT, glob_V002, tmp1->PROFIL))+")"
    elseif !empty(tmp1->zf)
      s += " ЗФ:"+alltrim(tmp1->ZF)
    endif
    k := perenos(tmp,s,w1)
    if verify_FF(HH)
      print1_l_uch(w1)
    endif
    s := date_8(tmp1->date_u1)+" "
    if tmp1->is_edit == 1
      s += "КДП№2 "
    elseif tmp1->is_edit == -1
      s += "ЦКДЛ  "
    elseif alltrim(tmp1->shifr) == "4.20.2" 
      s += "ВОКОД "
    else
      s += tmp1->otd+" "
    endif
    s += tmp1->kod_diag+" "
    s += padr(tmp[1],w1)
    s += put_val(ret_tabn(tmp1->kod_vr),6)+;
         put_val(ret_tabn(tmp1->kod_as),6)
    if tmp1->plus
      s += padl("+"+lstr(tmp1->kol),4)
      mpsumma += tmp1->summa
    else
      s += put_val(tmp1->kol,4)
      msumma += tmp1->summa
    endif
    s += put_kopE(tmp1->summa,9)
    add_string(s)
    for i := 2 to k
      add_string(space(21)+padl(rtrim(tmp[i]),w1))
    next
    select TMP1
    skip
  enddo
  add_string(padl(replicate("-",33),sh))
  s := "Общая сумма лечения: "+put_kop(human->cena_1,12)
  if mpsumma > 0
    s := alltrim(s)+" (+"+lput_kop(mpsumma,.t.)+")"
  endi
  add_string(padl(s,sh))
next ii
close databases
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.f.,,,5)
return NIL

***** 19.12.13
Function menu_schet_akt(r,c)
Static mas_pmt := {"По ~всем выставленным случаям",;
                   "За вычетом всех снятых по ~актам",;
                   "Без учёта ~повторно выставленных"}
Static mas_msg := {"По всем выставленным случаям",;
                   "За вычетом всех случаев, суммы которых были сняты по актам",;
                   "По всем выставленным случаям, но без учёта повторно выставленных случаев"}
Local j, buf := save_maxrow()
DEFAULT r TO T_ROW, c TO T_COL-5
if (j := popup_prompt(r,c,glob_schet_akt,mas_pmt,mas_msg,,"BG+/RB,W+/B,GR+/RB,BG+/B")) > 0
  glob_schet_akt := j
endif
rest_box(buf)
return j

***** 19.12.13
Function title_schet_akt(sh)
if glob_schet_akt == 2
  add_string(center("[ за вычетом снятых по актам ]",sh))
elseif glob_schet_akt == 3
  add_string(center("[ без учёта повторно выставленных случаев ]",sh))
endif
return NIL

***** 19.12.13
Function f_usl_schet_akt(loplata)
Local fl := .t.
if glob_schet_akt == 2
  fl := !eq_any(loplata,2,9)
elseif glob_schet_akt == 3
  fl := (loplata != 9)
endif
return fl

***** 22.06.17 статистика
Function e_statist(k)
Static si1 := 1, si2 := 3, si3 := 1, si4 := 1, si5 := 1, si6 := 1, ;
       si7 := 1, si8 := 1, si9 := 1, si61 := 1, si12 := 1, si13 := 1,;
       si14 := 1, si15 := 1, si16 := 1, si17 := 1, si18 := 1, si19 := 1
Static sds := 2
Local mas_pmt, mas_msg, mas_fun, j, uch_otd
DEFAULT k TO 1
do case
  case k == 1
    uch_otd := saveuchotd()
    Private p_net_otd := .t.
    mas_pmt := {"По ~счетам",;
                "~Объём работ по услугам",;
                "Объём по номенклатуре ~ФФОМС",;
                "Статистические ~формы",;
                "~Многовариантный поиск",;
                "~Прочая информация"}
    mas_msg := {"Статистика по счетам",;
                "Статистика по объёму работ персонала (по оказанным услугам)",;
                "Статистика по объёму работ персонала (по номенклатуре ФФОМС)",;
                "Статистика по диагнозам + статистические формы",;
                "Получение сводной информации (многовариантный поиск)",;
                "Прочая информация"}
    mas_fun := {"e_statist(11)",;
                "e_statist(12)",;
                "e_statist(13)",;
                "e_statist(14)",;
                "e_statist(15)",;
                "e_statist(16)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
    restuchotd(uch_otd)
  case k == 11
    Private pds := 2
    mas_pmt := {"По ~выставленным счетам",;
                "По ~зарегистрированным счетам",;
                "По ~актам контроля",;
                "По ~оплаченным счетам",;
                "~Сводная информация"}
    mas_msg := {"Статистика по выставленным счетам",;
                "Статистика по зарегистрированным счетам",;
                "Статистика по актам контроля",;
                "Статистика по оплаченным счетам",;
                "Сводная информация (зарег.счета + акты контроля + платёжные документы)"}
    mas_fun := {"e_statist(121)",;
                "e_statist(122)",;
                "e_statist(123)",;
                "e_statist(124)",;
                "e_statist(125)"}
    popup_prompt(T_ROW,T_COL-5,si12,mas_pmt,mas_msg,mas_fun)
  case k == 121
    mas_pmt := {"~Счета за период",;
                "~Конкретный счет",;
                "форма 14-~ТФОМС",;
                "~Узкие специалисты"}
    mas_msg := {"Статистическая информация по всем счетам за период времени",;
                "Статистическая информация по конкретному счету",;
                "Выборка информации по форме 14-ТФОМС за период времени",;
                "Оплата медицинской помощи за счет средств Программы модернизации на 2011-2012гг."}
    mas_fun := {"e_statist(21)",;
                "e_statist(22)",;
                "e_statist(23)",;
                "e_statist(24)"}
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)
  case k == 122
    pds := 3 // по дате регистрации счёта
    mas_pmt := {"~Счета за период",;
                "форма 14-~ТФОМС",;
                "~Незарегистрированные счета",;
                "форма 14-МЕД (~ОМС)",;
                "форма ~1 приказа №146 ФФОМС",;
                "отчёт ~Ф-МПП"}
    mas_msg := {"Статистическая информация по всем счетам за период времени",;
                "Выборка информации по форме 14-ТФОМС за период времени",;
                "Список незарегистрированных счетов",;
                "Подготовка формы №14-МЕД(ОМС)(во исполнение приказа Росстата от 17.04.14г. №258)",;
                "Подготовка формы №1 (во исполнение приказа ФФОМС от 16.08.11г №146)",;
                "Сведения о медицинской помощи, оказываемой по территориальной программе ОМС"}
   mas_fun := {"e_statist(141)",;
                "e_statist(142)",;
                "e_statist(143)",;
                "e_statist(144)",;
                "e_statist(145)",;
                "e_statist(146)"}
    popup_prompt(T_ROW,T_COL-5,si14,mas_pmt,mas_msg,mas_fun)
  case k == 123
    mas_pmt := {"~Суммы снятий",;
                "Список снятий (~дефекты)",;
                "Список снятий (~пациенты)",;
                "Список ~РАК",;
                "Список счетов ~без РАК"}
    mas_msg := {"Суммы снятий с расшифровкой по СМО, дефектам и видам экспертизы",;
                "Список снятий по актам контроля с указанием кодов дефектов",;
                "Список снятий по актам контроля с указанием пациентов",;   
                "Список реестров актов контроля с указанием наименований и дат файлов РАК",;   
                "Список счетов, по которым нет актов контроля"}
    mas_fun := {"e_statist(151)",;
                "e_statist(152)",;
                "e_statist(153)",;
                "e_statist(154)",;
                "e_statist(155)"}
    popup_prompt(T_ROW,T_COL-5,si15,mas_pmt,mas_msg,mas_fun)
  case k == 124
    mas_pmt := {"~Платёжные поручения"}
    mas_msg := {"Список платёжных поручений"}
    mas_fun := {"e_statist(161)"}
    popup_prompt(T_ROW,T_COL-5,si16,mas_pmt,mas_msg,mas_fun)
  case k == 125
    mas_pmt := {"~Акты сверки по СМО",;
                "~Оборотная ведомость"}
    mas_msg := {"Распечатка акта сверки по конкретной СМО",;
                "Составление оборотной ведомости"}
    mas_fun := {"e_statist(171)",;
                "e_statist(172)"}
    popup_prompt(T_ROW,T_COL-5,si17,mas_pmt,mas_msg,mas_fun)
  case k == 12
    mas_pmt := {"Объём работ (по дате оказания ~услуги)",;
                "Объём работ (по дате ~выписки счета)",;
                "Объём работ (по дате ~окончания лечения)",;
                "Объём работ (по ~невыписанным счетам)"}
    mas_msg := {"Статистика по объёму работ персонала (по дате начала оказания услуги)",;
                "Статистика по объёму работ персонала (по дате выписки счета)",;
                "Статистика по объёму работ персонала (по дате окончания лечения)",;
                "Статистика по объёму работ персонала (по больным, еще не включенным в счета)"}
    mas_fun := {"ob1_statist(0,1)",;
                "ob1_statist(0,2)",;
                "ob1_statist(0,3)",;
                "ob1_statist(0,4)"}
    Private pi1 := si2, psz, _arr_if, _what_if := _init_if(), _arr_komit := {}
    popup_prompt(T_ROW-len(mas_pmt)-3,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
    if pi1 != NIL ; si2 := pi1 ; endif
  case k == 13
    mas_pmt := {"Объём работ (по дате оказания ~услуги)",;
                "Объём работ (по дате ~выписки счета)",;
                "Объём работ (по дате ~окончания лечения)",;
                "Объём работ (по ~невыписанным счетам)"}
    mas_msg := {"Статистика по объёму работ персонала (по дате начала оказания услуги)",;
                "Статистика по объёму работ персонала (по дате выписки счета)",;
                "Статистика по объёму работ персонала (по дате окончания лечения)",;
                "Статистика по объёму работ персонала (по больным, еще не включенным в счета)"}
    mas_fun := {"obF_statist(0,1)",;
                "obF_statist(0,2)",;
                "obF_statist(0,3)",;
                "obF_statist(0,4)"}
    Private pi1 := si2, psz, _arr_if, _what_if := _init_if(), _arr_komit := {}
    popup_prompt(T_ROW-len(mas_pmt)-3,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
    if pi1 != NIL ; si2 := pi1 ; endif
  case k == 14
    mas_pmt := {"Статистические формы (по дате ~окончания лечения)",;
                "Статистические формы (по дате ~выписки счета)",;
                "~Проверка на соответствие правилам статистики",;
                "Ввод/редактирование правил ~статистики",;
                "~Настройка правил статистики"}
    mas_msg := {"Статистика по диагнозам и статистические формы (по дате окончания лечения)",;
                "Статистика по диагнозам и статистические формы (по дате выписки счета)",;
                "Проверка на соответствие правилам статистики",;
                "Ввод/редактирование правил статистики",;
                "Настройка правил статистики"}
    mas_fun := {"e_statist(41)",;
                "e_statist(42)",;
                "e_statist(43)",;
                "e_statist(44)",;
                "e_statist(45)"}
    popup_prompt(T_ROW-len(mas_pmt)-3,T_COL-5,si5,mas_pmt,mas_msg,mas_fun)
  case k == 15
    s_mnog_poisk()
  case k == 16
    mas_pmt := {"По иногородним и иностранцам",;
                "Приказ №~848 ВОМИАЦ",;
                "Стационарные случаи по ~профилям",;
                "Стоматологическая форма 39 - ~ХИРУРГИЯ",;
                "Стоматологическая форма 39 - ~ТЕРАПИЯ",;
                "Отчёт о количестве выданных ~справок ОМС"}
    mas_msg := {"Создание отчётов по иногородним и иностранцам для КЗВО",;
                "Подготовка информации во исполнение Приказа №848 ВОМИАЦ",;
                "Подсчёт стационарных случаев по профилям (по диагнозам и операциям)",;
                "Стоматологическая форма 39 по хирургическим приёмам",;
                "Стоматологическая форма 39 по терапевтическим приёмам",;
                "Отчёт о количестве выданных справок о стоимости оказанной мед.помощи в сфере ОМС"}
    mas_fun := {"e_statist(181)",;
                "e_statist(182)",;
                "e_statist(183)",;
                "e_statist(184)",;
                "e_statist(185)",;
                "e_statist(186)"}
    popup_prompt(T_ROW,T_COL-5,si18,mas_pmt,mas_msg,mas_fun)
  case k == 181
    pr_inog_inostr()
  case k == 182
    prikaz_848_miac()
  case k == 183
    i_stac_sl_profil()
  case k == 184
    f_stom_39_hirur()
  case k == 185
    f_stom_39_terap()
  case k == 186
    f_otchet_spravka_OMS()
  case between(k,21,29)
    pds := 2
    if eq_any(k,21,23) // для счетов и формы 14
      mas_pmt := {"По дате ~выписки счета",;
                  "По ~отчётному периоду"}
      if (j := popup_prompt(T_ROW,T_COL-5,sds,mas_pmt,,,"B/BG,W+/B,N/BG,BG+/B")) > 0
        sds := j
      endif
      pds := j
    endif
    if pds > 0
      do case
        case k == 21
          mas_pmt := {"~Список счетов",;
                      "С объединением по ~принадлежности",;
                      "С разбивкой по ~отделениям",;
                      "С разбивкой по слу~жбам"}
          mas_fun := {"s3_statist(1)",;
                      "s3_statist(2)",;
                      "e_statist(31)",;
                      "s3_statist(4)"}
          Private pi4 := si4
          popup_prompt(T_ROW,T_COL-5,si4,mas_pmt,mas_msg,mas_fun)
          if pi4 != NIL ; si4 := pi4 ; endif
        case k == 22
          s4_statist()
        case k == 23
          s5_statist()
        case k == 24
          uzkie_spec()
      endcase
    endif
  case k == 141
    mas_pmt := {"~Список счетов",;
                "С объединением по ~принадлежности"}
    mas_fun := {"s3_statist(1)",;
                "s3_statist(2)"}
    Private pi4 := si4
    popup_prompt(T_ROW,T_COL-5,si4,mas_pmt,mas_msg,mas_fun)
    if pi4 != NIL ; si4 := pi4 ; endif
  case k == 142
    s5_statist()
  case k == 143 // Незарегистрированные счета
    spisok_s_not_registred()
  case k == 144
    forma14_med_oms()
  case k == 145
    forma1_ffoms()
  case k == 146
    report_f_mpp()
  case k == 151 // Суммы снятий по актам
    akt_summa_of_refusal()
  case k == 152 // Список снятий по актам (дефекты)
    akt_list_of_refusal_defect()
  case k == 153 // Список снятий по актам (пациенты)
    akt_list_of_refusal_pacient()
  case k == 154 // Список РАК
    pr_list_RAK()
  case k == 155 // Список счетов без РАК
    pr_schet_bez_RAK()
  case k == 161 // Список платёжных поручений
    i_list_of_pd()
  case k == 171 // Акты сверки по СМО
    akt_sverki_smo()
  case k == 172
    mas_pmt := {"Снятия, оплата, ~долги по счетам",;
                "Составление ~оборотной ведомости",;
                "Ввод входящего ~сальдо"}
    mas_msg := {"Распечатка информации по счетам, сумме снятий по ним, сумме оплате и долге",;
                "Составление и распечатка оборотной ведомости",;
                "Ввод входящего сальдо для корректного формирования оборотной ведомости"}
    mas_fun := {"e_statist(191)",;
                "e_statist(192)",;
                "e_statist(193)"}
    popup_prompt(T_ROW,T_COL-5,si19,mas_pmt,mas_msg,mas_fun)
  case k == 191 // Выставлено/снято/оплачено
    pr1_oborot_schet()
  case k == 192 // Оборотная ведомость
    pr2_oborot_schet()
  case k == 193 // Ввод входящего сальдо
    saldo_oborot_schet()
  case k == 31
    mas_pmt := {"По отделениям, где ~выписан счет",;
                "По отделениям, где оказаны ~услуги"}
    mas_fun := {"s3_statist(3,1)",;
                "s3_statist(3,2)"}
    popup_prompt(T_ROW,T_COL-5,2,mas_pmt,mas_msg,mas_fun)
  case k == 41 .or. k == 42
    Private pi_schet := 1
    if k == 41
      mas_pmt := {"По ~всем случаям",;
                  "По случаям, ~попавшим в счета",;
                  "По случаям, ~не попавшим в счета"}
      if (j := popup_prompt(T_ROW,T_COL-5,si61,mas_pmt,,,"B/BG,W+/B,N/BG,BG+/B")) == 0
        return NIL
      endif
      pi_schet := si61 := j
    endif
    Private pi1 := k-40
    mas_pmt := {"По ~диагнозам",;
                "Форма № 1~2",;
                "Форма № 1~4",;
                "Форма № 14~дс",;
                "Форма № 1~6-вн",;
                "Форма № ~30",;
                "Форма № 3~9",;
                "Форма № 5~7",;
                "По ~больным"}
    mas_msg := {"Статистика по диагнозам",;
                "Сведения о числе заболеваний, зарегистрированных у больных...",;
                "Отчет о деятельности стационара",;
                "Сведения о деятельности дневных стационаров ЛПУ",;
                "Сведения о причинах временной нетрудоспособности",;
                "Сведения об учреждении здравоохранения",;
                "Учет услуг и посещений в поликлинике и на дому",;
                "Сведения о травмах, отравлениях и других последствиях воздействия внешних причин",;
                "Больные, по которым вводился характер заболевания (первичное/повторное)"}
    mas_fun := {"e_statist(51)",;
                "e_statist(52)",;
                "e_statist(53)",;
                "e_statist(54)",;
                "e_statist(55)",;
                "e_statist(56)",;
                "e_statist(57)",;
                "e_statist(58)",;
                "e_statist(59)"}
    popup_prompt(T_ROW,T_COL-5,si6,mas_pmt,mas_msg,mas_fun)
  case k == 43
    prover_rule()
  case k == 44
    mas_pmt := {"Правила ~Комитета здравоохранения",;
                "Правила ~лечебного учреждения"}
    mas_msg := {"Просмотр правил статистики Комитета здравоохранения",;
                "Ввод/редактирование правил статистики Вашего лечебного учреждения"}
    mas_fun := {"e_statist(61)",;
                "e_statist(62)"}
    popup_prompt(T_ROW,T_COL-5,si7,mas_pmt,mas_msg,mas_fun)
  case k == 45
    nastr_rule()
  case k == 51
    mas_pmt := {"~Общая форма",;
                "По ~четырехзначным шифрам",;
                "По ~трехзначным шифрам",;
                "По ~подгруппам заболеваний",;
                "По ~группам заболеваний",;
                "~Лечащий врач + диагнозы"}
    mas_msg := {"Статистика по диагнозам: общая форма",;
                "Статистика по диагнозам: по четырехзначным шифрам",;
                "Статистика по диагнозам: по трехзначным шифрам",;
                "Статистика по диагнозам: по подгруппам заболеваний",;
                "Статистика по диагнозам: по группам заболеваний",;
                "Статистика по диагнозам: лечащий врач + диагнозы"}
    mas_fun := {"e_statist(71)",;
                "e_statist(72)",;
                "e_statist(73)",;
                "e_statist(74)",;
                "e_statist(75)",;
                "e_statist(76)"}
    if is_uchastok > 0
      aadd(mas_pmt, "~Участок + диагнозы")
      aadd(mas_msg, "Статистика по диагнозам: участок + диагнозы")
      aadd(mas_fun, "e_statist(77)")
    endif
    popup_prompt(T_ROW,T_COL-5,si8,mas_pmt,mas_msg,mas_fun)
  case k == 52
    forma_12()
  case k == 53
    forma_14()
  case k == 54
    forma_14ds()
  case k == 55
    forma_16()
  case k == 56
    forma_30()
  case k == 57
    forma_39()
  case k == 58
    forma_57()
  case k == 59
    f_stat_boln()
  case k == 61 .or. k == 62
    Private prs := k-60
    Private file_stat := {f_stat_com,f_stat_lpu}[prs]
    Private dostup_stat := {.f.,.t.}[prs]
    if kod_polzovat == chr(0)
      dostup_stat := .t.
    endif
    if tip_polzovat != 0
      dostup_stat := .f.
    endif
    Private s_msg := "^<Esc>^ выход"
    if dostup_stat
      s_msg += " ^<Enter>^ редактирование ^<Ins>^ добавление ^<Del>^ удаление"
    endif
    s_msg += " ^<F1>^ помощь"
    mas_pmt := {"~Острые заболевания",;
                "~Диспансеризация",;
                "Диагноз + ~пол"}
    mas_fun := {"e_statist(81)",;
                "e_statist(82)",;
                "e_statist(83)"}
    if prs == 2 // только для ЛПУ
      aadd(mas_pmt, "~Неверный диагноз")
      aadd(mas_fun, "e_statist(84)")
      if yes_bukva
        aadd(mas_pmt, "~Буква раз в год")
        aadd(mas_fun, "e_statist(85)")
        aadd(mas_pmt, "~Сочетание букв")
        aadd(mas_fun, "e_statist(86)")
      endif
    endif
    mas_msg := {}
    i := 0
    do while i < len(mas_pmt)
      i := i + 1
      aadd(mas_msg, "Правило "+iif(prs==1,"КОМ-","ЛПУ-")+str(i,1)+": "+rule_section[i])
    enddo
    popup_prompt(T_ROW,T_COL-5,si9,mas_pmt,mas_msg,mas_fun)
  case k == 71
    diag0statist()
  case k == 72
    diag_statist(1)
  case k == 73
    diag_statist(2)
  case k == 74
    diag_statist(3)
  case k == 75
    diag_statist(4)
  case k == 76
    diagLVstatist()
  case k == 77
    diagLUstatist()
  case k == 81
    st_rule_1()
  case k == 82
    st_rule_2()
  case k == 83
    st_rule_3()
  case k == 84
    st_rule_4()
  case k == 85
    st_rule_5()
  case k == 86
    st_rule_6()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si3 := j
  elseif between(k,41,49)
    si5 := j
  elseif between(k,51,59)
    si6 := j
  elseif between(k,61,69)
    si7 := j
  elseif between(k,71,79)
    si8 := j
  elseif between(k,81,89)
    si9 := j
  elseif between(k,121,129)
    si12 := j
  elseif between(k,141,149)
    si14 := j
  elseif between(k,151,159)
    si15 := j
  elseif between(k,161,169)
    si16 := j
  elseif between(k,171,179)
    si17 := j
  elseif between(k,181,189)
    si18 := j
  elseif between(k,191,199)
    si19 := j
  endif
endif
return NIL

***** объем работ персонала (по оказанным услуга)
Function ob1_statist(k,k1)
Static si0 := 1, si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 1,;
       si6 := 1, si_slugba
Local mas_pmt, mas_msg, mas_fun, j, fl
do case
  case k == 0
    pi1 := k1
    Private pi_schet := 1
    if k1 == 3
      mas_pmt := {"По ~всем случаям",;
                  "По случаям, ~попавшим в счета",;
                  "По случаям, ~не попавшим в счета"}
      if (j := popup_prompt(T_ROW,T_COL-5,si6,mas_pmt,,,"B/BG,W+/B,N/BG,BG+/B")) == 0
        return NIL
      endif
      pi_schet := si6 := j
    endif
    mas_pmt := {"~Стоимость лечения",;
                "~Заработная плата"}
    mas_msg := {"Статистика по объёму работ с подсчетом стоимости лечения",;
                "Статистика по объёму работ с подсчетом заработной платы"}
    mas_fun := {"ob1_statist(1,1)",;
                "ob1_statist(1,2)"}
    popup_prompt(T_ROW,T_COL-5,si0,mas_pmt,mas_msg,mas_fun,color0+",R/BG,GR+/N")
  case k == 1
    psz := si0 := k1
    mas_pmt := {"~Отделения",;
                "~Службы",;
                "~Персонал",;
                "~Услуги"}
    mas_msg := {"Статистика по работе персонала и оказанным услугам в отделениях",;
                "Количество услуг и сумма лечения по службам",;
                "Статистика по работе персонала (независимо от отделения)",;
                "Статистика по оказанию конкретных услуг (независимо от отделения)"}
    mas_fun := {"ob1_statist(11)",;
                "ob1_statist(12)",;
                "ob1_statist(13)",;
                "ob1_statist(14)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11  // отделения
    mas_pmt := {"~Список отделений",;
                "Отделение + ~персонал",;
                "Отделение + ~услуги",;
                "Отделени~я + услуги",;
                "~Отделение + персонал + услуги",;
                "Отделение + услуга + ~больные",;
                "Отделение + 1 человек + бо~льные"}
    mas_msg := {"Количество услуг и сумма лечения по отделениям",;
                "Статистика по работе персонала в конкретном отделении",;
                "Статистика по услугам, оказанным в конкретном отделении",;
                "Статистика по услугам, оказанным в отделениях (плюс промежуточные итоги)",;
                "Статистика по работе персонала (плюс оказанные услуги) в конкретном отделении",;
                "Статистика по оказанной услуге (плюс больные) в конкретном отделении",;
                "Статистика по работе 1 человека (плюс больные) в конкретном отделении"}
    mas_fun := {"ob1_statist(21)",;
                "ob1_statist(22)",;
                "ob1_statist(23)",;
                "ob1_statist(24)",;
                "ob1_statist(25)",;
                "ob1_statist(26)",;
                "ob1_statist(27)"}
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 12  // службы
    mas_pmt := {"Службы + ~отделения",;
                "Отделения + ~службы",;
                "Службы + ~услуги",;
                "Служб~а + услуги",;
                "Отделени~е + службы + услуги",;
                "Отделен~ие + служба + услуги"}
    mas_msg := {"Количество услуг и сумма лечения по службам (с разбивкой по отделениям)",;
                "Количество услуг и сумма лечения по отделениям (с разбивкой по службам)",;
                "Статистика по оказанным услугам (с объединением по службам)",;
                "Статистика по оказанным услугам (по конкретной службе)",;
                "Статистика по оказанным услугам в конкретном отделении (с объед. по службам)",;
                "Статистика по оказанным услугам в конкретном отделении (по конкретной службе)"}
    mas_fun := {"ob1_statist(31)",;
                "ob1_statist(32)",;
                "ob1_statist(33)",;
                "ob1_statist(34)",;
                "ob1_statist(35)",;
                "ob1_statist(36)"}
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)
  case k == 13  // персонал
    mas_pmt := {"1 человек + ~услуги",;
                "1 человек + услуги + ~больные",;
                "~Весь персонал",;
                "~N человек + услуги",;
                "Весь ~персонал + услуги"}
    mas_msg := {"Статистика по работе конкретного работающего (плюс оказанные услуги)",;
                "Статистика по работе конкретного работающего (плюс услуги плюс больные)",;
                "Количество услуг и сумма лечения по всему списку работающих",;
                "Статистика по работе некоторых работающих (плюс оказанные услуги)",;
                "Статистика по работе всех работающих (плюс оказанные услуги)"}
    mas_fun := {"ob1_statist(41)",;
                "ob1_statist(42)",;
                "ob1_statist(43)",;
                "ob1_statist(44)",;
                "ob1_statist(45)"}
    popup_prompt(T_ROW,T_COL-5,si4,mas_pmt,mas_msg,mas_fun)
  case k == 14  // услуги
    mas_pmt := {"~Список услуг",;
                "Все ~услуги",;
                "Список услуг+~больные"}
    mas_msg := {"Статистика по оказанию конкретных услуг (независимо от отделения)",;
                "Статистика по оказанию всех услуг (независимо от отделения)",;
                "Статистика по оказанию конкретных услуг [с больными] (независимо от отделения)"}
    mas_fun := {"ob1_statist(51)",;
                "ob1_statist(52)",;
                "ob1_statist(53)"}
    popup_prompt(T_ROW,T_COL-5,si5,mas_pmt,mas_msg,mas_fun)
*** отделения
  case k == 21    // список отделений
    ob2_statist(1)
  case k == 22    // отделение + персонал
    ob2_statist(2)
  case k == 23    // отделение + услуги
    ob2_statist(3)
  case k == 24    // отделения + услуги
    ob2_statist(31)
  case k == 25    // отделение + персонал + услуги
    ob2_statist(4)
  case k == 26    // отделение + услуга + больные
    ob2_statist(8)
  case k == 27    // отделение + персонал + больные
    ob2_statist(9)
*** службы
  case k == 31    // службы + отделения
    ob2_statist(0)
  case k == 32    // отделения + службы
    ob2_statist(100)
  case k == 33    // службы + услуги
    ob2_statist(10)
  case equalany(k,34,36)    // служба + услуги
    fl := .f.
    R_Use(dir_server+"slugba",dir_server+"slugba","SL")
    if si_slugba == NIL
      go top
    else
      find (str(si_slugba,3))
    endif
    if Alpha_Browse(T_ROW,T_COL-5,maxrow()-2,T_COL+45,"f2spr_other",color0)
      fl := .t. ; si_slugba := sl->shifr
      j := { sl->shifr, lstr(sl->shifr)+". "+alltrim(sl->name) }
    endif
    sl->(dbCloseArea())
    if fl
      ob2_statist(iif(k==34,11,111),j)
    endif
  case k == 35    // отделение + службы + услуги
    ob2_statist(110)
*** персонал
  case k == 41    // конкретный работающий + услуги
    ob2_statist(5)
  case k == 42    // конкретный работающий + услуги + больные
    ob2_statist(13)
  case k == 43    // список персонала с объемом работ
    ob2_statist(7)
  case k == 44    // список работающих + услуги
    ob2_statist(5,{1})
  case k == 45    // весь персонал + услуги
    ob2_statist(5,{2})
*** услуги
  case k == 51    // список услуг
    ob2_statist(6)
  case k == 52    // все услуги
    ob2_statist(12)
  case k == 53    // список услуг + больные
    ob2_statist(14)
endcase
if k > 10
  if between(k,11,19)
    si1 := k-10
  elseif between(k,21,29)
    si2 := k-20
  elseif between(k,31,39)
    si3 := k-30
  elseif between(k,41,49)
    si4 := k-40
  elseif between(k,51,59)
    si5 := k-50
  endif
endif
return NIL

***** 12.03.14 объем работ персонала (по номенклатуре ФФОМС)
Function obF_statist(k,k1)
Static si0 := 1, si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 1, si6 := 1
Local mas_pmt, mas_msg, mas_fun, j, fl
do case
  case k == 0
    pi1 := k1
    Private pi_schet := 1
    if k1 == 3
      mas_pmt := {"По ~всем случаям",;
                  "По случаям, ~попавшим в счета",;
                  "По случаям, ~не попавшим в счета"}
      if (j := popup_prompt(T_ROW,T_COL-5,si6,mas_pmt,,,"B/BG,W+/B,N/BG,BG+/B")) == 0
        return NIL
      endif
      pi_schet := si6 := j
    endif
    /*mas_pmt := {"~Стоимость лечения",;
                "~Заработная плата"}
    mas_msg := {"Статистика по объёму работ с подсчетом стоимости лечения",;
                "Статистика по объёму работ с подсчетом заработной платы"}
    mas_fun := {"obF_statist(1,1)",;
                "obF_statist(1,2)"}
    popup_prompt(T_ROW,T_COL-5,si0,mas_pmt,mas_msg,mas_fun,color0+",R/BG,GR+/N")*/
    obF_statist(1,1)
  case k == 1
    psz := si0 := k1
    mas_pmt := {"~Отделения",;
                "~Персонал",;
                "~Номенклатура"}
    mas_msg := {"Статистика по работе персонала и оказанным номенклатурным услугам в отделениях",;
                "Статистика по работе персонала (независимо от отделения)",;
                "Статистика по оказанию конкретных номенклатурных услуг (независимо от отделения)"}
    mas_fun := {"obF_statist(11)",;
                "obF_statist(12)",;
                "obF_statist(13)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11  // отделения
    mas_pmt := {"~Список отделений",;
                "Отделение + ~персонал",;
                "Отделение + ~услуги",;
                "Отделени~я + услуги",;
                "~Отделение + персонал + услуги",;
                "Отделение + услуга + ~больные",;
                "Отделение + 1 человек + бо~льные"}
    mas_msg := {"Количество услуг по отделениям",;
                "Статистика по работе персонала в конкретном отделении",;
                "Статистика по услугам, оказанным в конкретном отделении",;
                "Статистика по услугам, оказанным в отделениях (плюс промежуточные итоги)",;
                "Статистика по работе персонала (плюс оказанные услуги) в конкретном отделении",;
                "Статистика по оказанной услуге (плюс больные) в конкретном отделении",;
                "Статистика по работе 1 человека (плюс больные) в конкретном отделении"}
    mas_fun := {"obF_statist(21)",;
                "obF_statist(22)",;
                "obF_statist(23)",;
                "obF_statist(24)",;
                "obF_statist(25)",;
                "obF_statist(26)",;
                "obF_statist(27)"}
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 12  // персонал
    mas_pmt := {"1 человек + ~услуги",;
                "1 человек + услуги + ~больные",;
                "~Весь персонал",;
                "~N человек + услуги",;
                "Весь ~персонал + услуги"}
    mas_msg := {"Статистика по работе конкретного работающего (плюс оказанные услуги)",;
                "Статистика по работе конкретного работающего (плюс услуги плюс больные)",;
                "Количество услуг по всему списку работающих",;
                "Статистика по работе некоторых работающих (плюс оказанные услуги)",;
                "Статистика по работе всех работающих (плюс оказанные услуги)"}
    mas_fun := {"obF_statist(41)",;
                "obF_statist(42)",;
                "obF_statist(43)",;
                "obF_statist(44)",;
                "obF_statist(45)"}
    popup_prompt(T_ROW,T_COL-5,si4,mas_pmt,mas_msg,mas_fun)
  case k == 13  // услуги
    mas_pmt := {"~Список услуг",;
                "Все ~услуги",;
                "Список услуг+~больные"}
    mas_msg := {"Статистика по оказанию конкретных услуг (независимо от отделения)",;
                "Статистика по оказанию всех услуг (независимо от отделения)",;
                "Статистика по оказанию конкретных услуг [с больными] (независимо от отделения)"}
    mas_fun := {"obF_statist(51)",;
                "obF_statist(52)",;
                "obF_statist(53)"}
    popup_prompt(T_ROW,T_COL-5,si5,mas_pmt,mas_msg,mas_fun)
*** отделения
  case k == 21    // список отделений
    obF2_statist(1)
  case k == 22    // отделение + персонал
    obF2_statist(2)
  case k == 23    // отделение + услуги
    obF2_statist(3)
  case k == 24    // отделения + услуги
    obF2_statist(31)
  case k == 25    // отделение + персонал + услуги
    obF2_statist(4)
  case k == 26    // отделение + услуга + больные
    obF2_statist(8)
  case k == 27    // отделение + персонал + больные
    obF2_statist(9)
*** персонал
  case k == 41    // конкретный работающий + услуги
    obF2_statist(5)
  case k == 42    // конкретный работающий + услуги + больные
    obF2_statist(13)
  case k == 43    // список персонала с объемом работ
    obF2_statist(7)
  case k == 44    // список работающих + услуги
    obF2_statist(5,{1})
  case k == 45    // весь персонал + услуги
    obF2_statist(5,{2})
*** услуги
  case k == 51    // список услуг
    obF2_statist(6)
  case k == 52    // все услуги
    obF2_statist(12)
  case k == 53    // список услуг + больные
    obF2_statist(14)
endcase
if k > 10
  if between(k,11,19)
    si1 := k-10
  elseif between(k,21,29)
    si2 := k-20
  elseif between(k,31,39)
    si3 := k-30
  elseif between(k,41,49)
    si4 := k-40
  elseif between(k,51,59)
    si5 := k-50
  endif
endif
return NIL

***** статистика по план-заказу
Function pz_statist(k)
Static si1 := 2
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"По ~одному счету",;
                "По ~счетам за отчётный период",;
                "По счетам по дате окончания ~лечения",;
                "По ~невыписанным счетам",;
                "~Расчёт потребности в фин.обеспечении"}
    mas_msg := {"Статистика по конкретному счету",;
                "Статистика по счетам за отчётный период времени (кратный месяцу)",;
                "Статистика по счетам с выборкой по дате окончания лечения",;
                "Статистика по невыписанным счетам",;
                "Расчёт потребности в финансовом обеспечении выполнения объёмов мед.помощи"}
    mas_fun := {"pz_statist(11)",;
                "pz_statist(12)",;
                "pz_statist(13)",;
                "pz_statist(14)",;
                "pz_statist(15)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    pz1statist(1)
  case k == 12
    pz1statist(2,1)
  case k == 13
    pz1statist(2,2)
  case k == 14
    pz1statist(3)
  case k == 15
    pz_raschet_potr()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

***** 05.02.19
Function pz1statist(par,par2)
Static _su := 2
Local buf := savescreen(), fl_exit := .f., fl := .t., a_otd := {},;
      name_file := "plan_z"+stxt, arr_m, ta[2], arr_title, ;
      sh := 80, HH := 60, reg_print := 2, arr_name := f14tf_array(),;
      mstr_crb, mismo, ltrud, lplan, lcount_uch, lcount_otd
Private flag_uet := .t., as[10,3], s_stac, sdstac, s_amb, skt, ssmp, suet, sstoim, ;
        su, su1, arr_goi, arr_zn := {B_END,B_STANDART}, arr_rees_no := {1,2},;
        kol_sl_2 := 0, arr_lp := {}, fl_period := .f.
Private fl_plan := .f., ym_kol_mes := 1, tfoms_pz[6]
afill(tfoms_pz,0)
if par > 1 .and. (arr_goi := ret_g_o_i(T_ROW,T_COL-5)) == NIL
  return NIL
endif
Private v_deti := 1, apf := {},   apz2016 := {}, luapz2016 := {}, is_2019 := .f.
if (v_deti := popup_prompt(T_ROW,T_COL-5,1,;
                           {"по ~всем пациентам","по ~детям"},,,;
                           "N/G*,W+/B,B/G*,BG+/B")) == 0
  restscreen(buf)
  return NIL
endif
if par == 1
  arr_goi := {1,2}
  Private p_number, p_date
  if !input_schet(15)
    restscreen(buf)
    return NIL
  endif
elseif par == 2
  if (arr_m := year_month(T_ROW,T_COL-5)) == NIL
    return NIL
  endif
  if par2 == 1
    Private mdate_reg
    if !is_otch_period(arr_m)
      return NIL
    elseif !ret_date_reg_otch_period()
      return NIL
    endif
  endif
  if par2 == 2 .and. arr_m[6] < 0d20180101
    return func_error(4,"Период должен быть не ранее 2018 года")
  endif
  if mem_trudoem == 2 .and. mem_tr_plan == 2 .and. ym_kol_mes > 0
    fl_plan := .t.
  endif
  fl := pz2statist(arr_m,par2)
else
  if yes_vypisan == B_END .and. (arr_zn := ret_z_n(T_ROW,T_COL-5)) == NIL
    return NIL
  endif
  if ascan(arr_zn,B_STANDART) > 0 .and. (arr_rees_no := ret_reestr_no(T_ROW,T_COL-5)) == NIL
    return NIL
  endif
  if (arr_m := year_month(T_ROW,T_COL-5)) == NIL
    return NIL
  endif
endif
mas_pmt := {"Список ~отделений (план-заказ)",;
            "Вывод списка ~услуг (план-заказ)",;
            "~Службы + услуги (список услуг)",;
            "Наработка по ~врачам (список услуг)"}
if (su := popup_prompt(T_ROW,T_COL-5,_su,mas_pmt)) == 0
  fl := .f.
elseif su == 4 .and. (su1 := popup_prompt(T_ROW,T_COL-5,1,;
               {"~Итоговые суммы по врачам","С расшифровкой ~услуг"})) == 0
  fl := .f.
endif
if !fl
  restscreen(buf)
  return NIL
endif
_su := su
if par == 2 .and. eq_any(su,1,2,5) 
  if arr_m[1] > 2018
    R_Use(dir_exe+"_mo9unit",,"MOUNIT")
    index on str(ii,3) to (cur_dir+"tmp_unitii")
    set index to (cur_dir+"_mo9unit"),(cur_dir+"tmp_unitii") 
    is_2019 := .t.
    apz2016 := arr_plan_zakaz(.t.)
    luapz2016 := arr_plan_zakaz(.t.)
  else
    R_Use(dir_exe+"_mo8unit",,"MOUNIT")
    index on str(ii,3) to (cur_dir+"tmp_unitii")
    set index to (cur_dir+"_mo8unit"),(cur_dir+"tmp_unitii") 
    apz2016 := arr_plan_zakaz(.f.)
    luapz2016 := arr_plan_zakaz(.f.)
  endif
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
  restscreen(buf)
  return NIL
endif
if par < 3 .and. menu_schet_akt() == 0
  restscreen(buf)
  return NIL
endif
if len(st_a_uch) == 1
  glob_uch := st_a_uch[1]
  if (st_a_otd := inputN_otd(T_ROW,T_COL-5,.f.,.f.,glob_uch,@lcount_otd)) == NIL
    restscreen(buf)
    return NIL
  endif
  aeval(st_a_otd, {|x| aadd(a_otd,x[1]) })
else
  R_Use(dir_server+"mo_otd",,"OTD")
  go top
  do while !eof()
    if f_is_uch(st_a_uch,otd->kod_lpu) .and. ;
          iif(valtype(arr_m) == 'A', between_date(otd->DBEGIN,otd->DEND,arr_m[5],arr_m[6]), .t.)
      aadd(a_otd, otd->(recno()))
    endif
    skip
  enddo
  otd->(dbCloseArea())
endif
adbf := {{"kod","N",4,0},;
         {"kod1","N",4,0},;
         {"shifr","C",10,0},;
         {"u_name","C",255,0},;
         {"kol","N",7,0},;
         {"kol1","N",7,0},;
         {"uet","N",11,4},;
         {"sum","N",13,2}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
if su > 2
  index on str(kod,4) to (cur_dir+"tmp")
else
  index on shifr to (cur_dir+"tmp")
endif
if su == 4
  dbcreate(cur_dir+"tmp1",adbf)
  use (cur_dir+"tmp1") new
  index on str(kod,4)+str(kod1,4) to (cur_dir+"tmp1")
endif
adbf := {{"otd", "N", 3,0},;
         {"uch", "N", 3,0},;
         {"kol1","N", 7,0},;
         {"kol2","N", 7,0},;
         {"kol3","N", 7,0},;
         {"kol4","N", 7,0},;
         {"kol5","N",12,2},;
         {"kol6","N", 7,0},;
         {"kol7","N", 7,0},;
         {"kol8","N", 7,0},;
         {"kol9","N", 7,0},;
         {"kol10","N",7,0}}
dbcreate(cur_dir+"tmpo",adbf)
use (cur_dir+"tmpo") new
index on str(otd,3) to (cur_dir+"tmpo")
dbcreate(cur_dir+"tmpok",{{"otd", "N",3,0},{"kod_k","N",7,0}})
use (cur_dir+"tmpok") new
index on str(otd,3)+str(kod_k,7) to (cur_dir+"tmpok")
dbcreate(cur_dir+"tmpos",{{"otd", "N",3,0},{"kod","N",7,0}})
use (cur_dir+"tmpos") new
index on str(otd,3)+str(kod,7) to (cur_dir+"tmpos")
R_Use(dir_server+"mo_su",,"MOSU")
R_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to u_kod into USL, to recno() into HU_
afillall(as,0)
s_stac := sdstac := s_amb := skt := ssmp := suet := sstoim := 0
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
if par == 1
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",dir_server+"schetk","SCHET")
  set relation to recno() into SCHET_
  find (str(glob_schet,6))
  p_number := alltrim(schet_->NSCHET)
  p_date := schet_->DSCHET
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humans","HUMAN")
  set relation to recno() into HUMAN_
  find (str(glob_schet,6))
  do while human->schet == glob_schet .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if f_usl_schet_akt(human_->oplata) .and. iif(v_deti==1,.t.,human->VZROS_REB>0)
      f1pz1statist(a_otd,1)
    endif
    select HUMAN
    skip
  enddo
elseif par == 2
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humans","HUMAN")
  set relation to recno() into HUMAN_
  use (cur_dir+"tmp_smo") index (cur_dir+"tmp_smo1") new
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
  set relation to recno() into SCHET_
  set filter to empty(schet_->IS_DOPLATA)
  go top
  do while !eof()
    if par2 == 1
      if emptyany(schet_->nyear,schet_->nmonth)
        fl := between(schet->pdate,arr_m[7],arr_m[8])
      else
        mdate := stod(strzero(schet_->nyear,4)+strzero(schet_->nmonth,2)+'15')
        if (fl := between(mdate,arr_m[5],arr_m[6]))
          fl_period := .t.
        endif
      endif
      if fl .and. mdate_reg != NIL
        fl := (schet_->NREGISTR==0 .and. date_reg_schet() <= mdate_reg)
      endif
    else
      if emptyany(schet_->nyear,schet_->nmonth)
        fl := .f.
      else
        mdate := stod(strzero(schet_->nyear,4)+strzero(schet_->nmonth,2)+'01')
        do while .t.
          if (fl := between(mdate,arr_m[5],arr_m[6]))
            exit
          endif
          ++mdate
          if mdate == eom(mdate)
            exit
          endif
        enddo
      endif
    endif
    if fl
      if schet_->ifin > 0
        mkomu := 0
        mstr_crb := 0
        msmo := schet_->smo
      else
        mkomu := iif(schet->komu==1, 1, 3)
        mstr_crb := schet->str_crb
        msmo := space(5)
      endif
      select TMP_SMO
      find (str(mkomu,1)+str(mstr_crb,2)+msmo)
      if found() .and. tmp_smo->is == 1
        @ maxrow(),0 say padr("№ "+alltrim(schet_->NSCHET)+" от "+date_8(schet_->DSCHET),28) color "W/R"
        select HUMAN
        find (str(schet->kod,6))
        do while human->schet == schet->kod .and. !eof()
          UpdateStatus()
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          if iif(par2 == 1, .t., between(human->k_data,arr_m[5],arr_m[6])) ;
                                  .and. f_usl_schet_akt(human_->oplata) ;
                                  .and. iif(v_deti==1,.t.,human->VZROS_REB>0)
            f1pz1statist(a_otd,1)
          endif
          select HUMAN
          skip
        enddo
        if fl_exit ; exit ; endif
      endif
    endif
    select SCHET
    skip
  enddo
else
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humann","HUMAN")
  set relation to recno() into HUMAN_
  dbseek("1",.t.)
  do while human->tip_h < B_SCHET .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if between(human->k_data,arr_m[5],arr_m[6]) .and. ascan(arr_zn,human->tip_h) > 0 ;
                                                .and. iif(v_deti == 1,.t.,human->VZROS_REB > 0)
      if human_->reestr == 0
        fl := ascan(arr_rees_no,1) > 0
      else
        fl := ascan(arr_rees_no,2) > 0
      endif
      if fl
        f1pz1statist(a_otd,2)
      endif
    endif
    select HUMAN
    skip
  enddo
endif
if su == 1
  sh := 86
endif
for i := 1 to len(apz2016)
  aadd(adbf, {"kol"+strzero(apz2016[i,2],2),"N",9,2})
next
//
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string(padl("дата печати "+date_8(sys_date)+" "+hour_min(seconds()),sh))
titleN_uch(st_a_uch,sh,lcount_uch)
if len(st_a_uch) == 1
  titleN_otd(st_a_otd,sh,lcount_otd)
endif
add_string("")
if su > 2
  add_string(padc("Список оказанных услуг",sh))
else
  add_string(padc("Статистика по выполнению план-заказа",sh))
endif
if par == 1
  add_string(center("по счету № "+p_number+" от "+full_date(p_date)+" г.",sh))
elseif par == 2 .and. par2 == 1
  add_string(center("по счетам "+arr_m[4],sh))
  if fl_period
    add_string(center("[ подсчёт производится по отчётному периоду]",sh))
    if mdate_reg != NIL
      add_string(center("[ по счетам, зарегистрированным по "+full_date(mdate_reg)+"г. включительно ]",sh))
    endif
  endif
elseif par == 2 .and. par2 == 2
  add_string(center("по счетам (дата окончания лечения "+arr_m[4]+")",sh))
else
  add_string(center("по невыписанным счетам (дата окончания лечения "+arr_m[4]+")",sh))
endif
if v_deti == 2
  add_string(center("[ ПО ДЕТЯМ ]",sh))
endif
if par < 3
  title_schet_akt(sh)
endif
if eq_any(su,1,2,5)
  add_string("")
  k := 0
  add_string("──────────────────────────────────────────┬──────────┬────────────┬──────────────")
  add_string("                                          │план-заказ│листов учета│    сумма     ")
  add_string("──────────────────────────────────────────┴──────────┴────────────┴──────────────")
  for i := 1 to len(luapz2016)
    if luapz2016[i,3] > 0 .or. apz2016[i,3] > 0
      s := padl(luapz2016[i,1],42)
      if empty(apz2016[i,3]) .and. !empty(luapz2016[i,3])
        s += str(luapz2016[i,3]-kol_sl_2,10,0)
      else
        s += str(apz2016[i,3]-kol_sl_2,10,0)
      endif
      s += str(luapz2016[i,3],10,0)+str(luapz2016[i,2],17,2)
      add_string(s)
      k += luapz2016[i,3]
    endif
  next
  add_string(replicate("─",sh))
  add_string(padl("Всего листов учета",42)+str(k,20,0)+str(sstoim,17,2))
  add_string("")
  add_string("─────────────────────────────────────────────────┬──────┬────────┬──────────────")
  add_string("                                                 │Кол-во│        │  Стоимость   ")
  add_string("                                                 │ услуг│ У.Е.Т. │    услуг     ")
  add_string("─────────────────────────────────────────────────┴──────┴────────┴──────────────")
  for i := 1 to 10
    if !emptyall(as[i,1],as[i,2],as[i,3])
      k := perenos(ta,arr_name[i],49)
      if i == 6
        add_string(padr(ta[1],49)+str(as[i,1],7,0))
      else
        add_string(padr(ta[1],49)+str(as[i,1],7,0)+;
                                  umest_val(as[i,2],9,2)+;
                                  put_kopE(as[i,3],15))
      endif
      for j := 2 to k
        add_string(padl(alltrim(ta[j]),49))
      next
    endif
  next
endif
if su == 1
  arr_title := {;
"──────────────────────────────╥────┬─────╥─────┬─────┬─────┬─────┬────────┬─────┬─────",;
"                              ║ че-│ слу-║кой- │паци-│врач.│стома│стомато-│отдел│вызо-",;
"  Наименование отделения      ║ ло-│ ча- ║ко-  │енто-│приё-│тол. │логичес-│медиц│вов  ",;
"                              ║ век│ ев  ║дней │дней │мов  │посещ│ких УЕТ │услуг│СМП  ",;
"──────────────────────────────╨────┴─────╨─────┴─────┴─────┴─────┴────────┴─────┴─────";
  }
//
  aeval(arr_title, {|x| add_string(x) } )
  n1 := 30
  R_Use(dir_server+"mo_uch",,"UCH")
  R_Use(dir_server+"mo_otd",,"OTD")
  set relation to kod_lpu into UCH
  select TMPO
  set index to
  dbeval({|| otd->(dbGoto(tmpo->otd)), tmpo->uch := otd->kod_lpu })
  set relation to otd into OTD
  index on upper(uch->name)+str(uch,3)+upper(otd->name)+str(otd,3) to (cur_dir+"tmpo")
  old_uch := 0
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if old_uch != tmpo->uch
      if old_uch > 0
        add_string("")
      endif
      add_string(upper(uch->name))
      add_string(replicate("═",sh))
      old_uch := tmpo->uch
    endif
    k := ks := 0
    select TMPOK
    find (str(tmpo->otd,3))
    dbeval({|| ++k},,{|| tmpok->otd==tmpo->otd })
    select TMPOS
    find (str(tmpo->otd,3))
    dbeval({|| ++ks},,{|| tmpos->otd==tmpo->otd })
    add_string(padr(otd->name,n1)+;
               put_val(k,5)+;
               put_val(ks,6)+;
               put_val(tmpo->kol1,6)+;
               put_val(tmpo->kol2,6)+;
               put_val(tmpo->kol3,6)+;
               put_val(tmpo->kol4,6)+;
               " "+umest_val(tmpo->kol5,8,2)+;
               put_val(tmpo->kol6,6)+;
               put_val(tmpo->kol7,6))
    select TMPO
    skip
  enddo
elseif eq_any(su,2,3)
  n1 := iif(flag_uet, 49, 58)
  arr_title := {;
  replicate("─",n1),;
  space(n1),;
  padc("Наименование услуги",n1),;
  replicate("─",n1)}
  arr_title[1] += "┬──────"
  arr_title[2] += "│Кол-во"
  arr_title[3] += "│ услуг"
  arr_title[4] += "┴──────"
  if flag_uet
    arr_title[1] += "┬────────"
    arr_title[2] += "│        "
    arr_title[3] += "│ У.Е.Т. "
    arr_title[4] += "┴────────"
  endif
  arr_title[1] += "┬──────────────"
  arr_title[2] += "│  Стоимость   "
  arr_title[3] += "│    услуг     "
  arr_title[4] += "┴──────────────"
  aeval(arr_title, {|x| add_string(x) } )
  select HU
  set relation to
  if su == 2
    select TMP
    index on fsort_usl(shifr) to (cur_dir+"tmp")
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      k := perenos(as,tmp->u_name,n1-11)
      s := tmp->shifr+" "+padr(as[1],n1-11)+str(tmp->kol,7,0)
      if flag_uet
        if empty(tmp->uet)
          if empty(tmp->kol) .and. !empty(tmp->kol1)
            s += padr(" ("+lstr(tmp->kol1)+")",9)
          else
            s += space(9)
          endif
        else
          s += " "+umest_val(tmp->uet,8,2)
        endif
      endif
      s += put_kopE(tmp->sum,14)
      add_string(s)
      for j := 2 to k
        add_string(space(11)+as[j])
      next
      if (j := ascan(arr_lp, {|x| x[1] == tmp->shifr })) > 0
        for k := 1 to len(arr_lp[j,2])
          asort(arr_lp[j,2],,,{|x,y| fsort_usl(x[1]) < fsort_usl(y[1]) })
          s := space(10)+"в т.ч. "+alltrim(arr_lp[j,2,k,1])
          if len(s) > n1
            s := padr(s,n1)
          else
            s := padl(s,n1)
          endif
          s := s+str(arr_lp[j,2,k,2],7)
          if !empty(arr_lp[j,2,k,3])
            s += " ("+lstr(arr_lp[j,2,k,3])+")"
          endif
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(s)
        next
      endif
      select TMP
      skip
    enddo
  else
    select TMP
    set relation to kod into USL
    R_Use(dir_server+"slugba",dir_server+"slugba","SL")
    select USL
    set relation to str(slugba,3) into SL
    select TMP
    index on str(usl->slugba,3)+fsort_usl(usl->shifr) to (cur_dir+"tmp")
    old_s := -999
    ssl := array(3) ; afill(ssl,0)
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      if !(old_s == usl->slugba)
        if old_s > -999
          add_string(replicate("─",sh))
          s := padl("Итого по службе:",n1)+str(ssl[1],7,0)
          if flag_uet
            s += " "+umest_val(ssl[2],8,2)
          endif
          s += put_kopE(ssl[3],14)
          add_string(s)
          add_string("")
        endif
        add_string(padc("Служба: "+lstr(usl->slugba)+"."+alltrim(sl->name),sh,"_"))
        old_s := usl->slugba
        afill(ssl,0)
      endif
      k := perenos(as,usl->name,n1-11)
      s := usl->shifr+" "+padr(as[1],n1-11)+str(tmp->kol,7,0)
      if flag_uet
        s += " "+umest_val(tmp->uet,8,2)
      endif
      s += put_kopE(tmp->sum,14)
      add_string(s)
      for j := 2 to k
        add_string(space(11)+as[j])
      next
      ssl[1] += tmp->kol
      ssl[2] += tmp->uet
      ssl[3] += tmp->sum
      select TMP
      skip
    enddo
    if ssl[1] > 0
      add_string(replicate("─",sh))
      s := padl("Итого по службе:",n1)+str(ssl[1],7,0)
      if flag_uet
        s += " "+umest_val(ssl[2],8,2)
      endif
      s += put_kopE(ssl[3],14)
      add_string(s)
    endif
  endif
elseif su == 4
  if !flag_uet
    fl_plan := .f.
  endif
  n1 := 80-18
  if flag_uet
    n1 -= 9
  endif
  if fl_plan
    n1 -= 10
  endif
  arr_title := {;
  replicate("─",n1),;
  space(n1),;
  padc("Врач"+iif(su1==1,""," (плюс услуги)"),n1),;
  replicate("─",n1)}
  if fl_plan
    arr_title[1] += "┬────"
    arr_title[2] += "│План"
    arr_title[3] += "│ УЕТ"
    arr_title[4] += "┴────"
  endif
  arr_title[1] += "┬──────"
  arr_title[2] += "│Кол-во"
  arr_title[3] += "│ услуг"
  arr_title[4] += "┴──────"
  if flag_uet
    arr_title[1] += "┬────────"
    arr_title[2] += "│        "
    arr_title[3] += "│ У.Е.Т. "
    arr_title[4] += "┴────────"
  endif
  arr_title[1] += "┬──────────"
  arr_title[2] += "│Стоимость "
  arr_title[3] += "│  услуг   "
  arr_title[4] += "┴──────────"
  if fl_plan
    arr_title[1] += "┬────"
    arr_title[2] += "│ %% "
    arr_title[3] += "│план"
    arr_title[4] += "┴────"
  endif
  aeval(arr_title, {|x| add_string(x) } )
  select HU
  set relation to
  if fl_plan
    R_Use(dir_server+"uch_pers",dir_server+"uch_pers","UCHP")
  endif
  select TMP1
  set relation to kod1 into USL
  index on str(kod,4)+fsort_usl(usl->shifr) to (cur_dir+"tmp1")
  G_Use(dir_server+"mo_pers",,"PERSO")
  select TMP
  set relation to kod into PERSO
  index on upper(perso->fio) to (cur_dir+"tmp")
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    s := iif(empty(perso->fio), "__Не введен врач__", alltrim(perso->fio))+" ["+lstr(perso->tab_nom)+"]"
    k := perenos(as,s,n1)
    s := padr(as[1],n1)
    if fl_plan
      ltrud := ret_trudoem(tmp->kod,tmp->uet,ym_kol_mes,arr_m,@lplan)
      s += put_val(lplan,5,0)
    endif
    s += str(tmp->kol,7,0)
    if flag_uet
      s += " "+umest_val(tmp->uet,8,2)
    endif
    s += put_kopE(tmp->sum,11)
    if fl_plan
      s += " "+umest_val(ltrud,4,1)
    endif
    add_string(s)
    for j := 2 to k
      add_string(padl(alltrim(as[j]),n1))
    next
    if su1 == 2
      select TMP1
      find (str(tmp->kod,4))
      do while tmp->kod == tmp1->kod .and. !eof()
        if verify_FF(HH,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        lname := usl->name
        select LUSL
        find (padr(usl->shifr,10))
        if found()
          lname := lusl->name  // наименование услуги из справочника ТФОМС
        endif
        k := perenos(as,alltrim(usl->shifr)+" "+alltrim(lname),n1-2)
        s := "  "+padr(as[1],n1-2)
        if fl_plan
          s += space(5)
        endif
        s += str(tmp1->kol,7,0)
        if flag_uet
          s += " "+umest_val(tmp1->uet,8,2)
        endif
        s += put_kopE(tmp1->sum,11)
        add_string(s)
        for j := 2 to k
          add_string(padl(alltrim(as[j]),n1))
        next
        select TMP1
        skip
      enddo
    endif
    select TMP
    skip
  enddo
endif
fclose(fp)
close databases
/*for i := 1 to len(apf)
  my_debug(,padr(apf[i,1],10) + lstr(apf[i,2])) 
next*/
restscreen(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

***** 05.02.19
Function f1pz1statist(arr_otd,par)
Local lreg_lech := {0,0,0,0,0}, s, lkod, lshifr, ta, i, j, k, mkol1,;
      mkol, muet, msum, koef := 1, lshifr1, fl := .t., arr_dn_st := {"","",0},;
      d2_year := year(human->k_data), ar, i14 := 0, i16 := 0, au_su1 := {}, sdializ := ""
if par == 2
  if int(val(cut_code_smo(human_->smo))) == 34
    fl := (ascan(arr_goi,2) > 0)
  else
    fl := (ascan(arr_goi,1) > 0)
  endif
endif
if !fl
  return NIL
endif
if glob_schet_akt == 2 .and. human_->oplata == 3
  koef := human_->sump/human->cena_1
endif
if human->ishod == 89 // это 2-ой л/у в двойном случае
  kol_sl_2++
endif  
sstoim += human->cena_1*koef
ar := array(len(luapz2016)) ; afill(ar,0)
select HU
find (str(human->kod,7))
do while hu->kod == human->kod .and. !eof()
  if ascan(arr_otd,hu->otd) > 0
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
      lshifr := usl->shifr
    endif
    ta := f14tf_nastr(lshifr,,d2_year)
    for j := 1 to len(ta)
      if (k := ta[j,3]) > 0
        ar[k] ++
      endif
    next
  endif
  select HU
  skip
enddo
for j := 1 to len(ar)
  if ar[j] > 0
    if empty(luapz2016[j,3])
      luapz2016[j,2] := 0
    endif
    luapz2016[j,3] ++
    luapz2016[j,2] += human->cena_1*koef
  endif
next
select HU
find (str(human->kod,7))
do while hu->kod == human->kod .and. !eof()
  if ascan(arr_otd,hu->otd) > 0
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    muet := hu->kol_1 * ret_tfoms_uet(usl->shifr,lshifr1,human->vzros_reb)
    tfoms_pz[4] += muet
    if eq_any(su,3,4)
      suet += muet
      lkod := iif(su==3, hu->u_kod, hu->kod_vr)
      select TMP
      find (str(lkod,4))
      if !found()
        append blank
        tmp->kod := lkod
        if recno() % 5000 == 0
          dbCommit()
        endif
      endif
      tmp->kol += hu->kol_1
      tmp->uet += muet
      tmp->sum += hu->stoim_1*koef
      if su == 4
        select TMP1
        find (str(hu->kod_vr,4)+str(hu->u_kod,4))
        if !found()
          append blank
          tmp1->kod := hu->kod_vr
          tmp1->kod1 := hu->u_kod
          tmp1->shifr := usl->shifr
          if recno() % 5000 == 0
            dbCommit()
          endif
        endif
        tmp1->kol += hu->kol_1
        tmp1->uet += muet
        tmp1->sum += hu->stoim_1*koef
      endif
      if empty(lshifr := lshifr1)
        lshifr := usl->shifr
      endif
      ta := f14tf_nastr(lshifr,,d2_year)
      for j := 1 to len(ta)
        k := ta[j,1]
        if between(k,1,10)
          if k == 2
            tfoms_pz[1] += hu->kol_1
          elseif k == 1 // врачебные приёмы
            if ta[j,2] >= 0
              tfoms_pz[3] += hu->kol_1
            endif
          elseif k == 7
            tfoms_pz[5] += hu->kol_1
          elseif k == 8
            tfoms_pz[6] += hu->kol_1
          elseif eq_any(k,3,4,5)
            tfoms_pz[2] += hu->kol_1
          endif
          if ta[j,2] >= 0
            as[k,1] += hu->kol_1
            as[k,2] += muet
          endif
          as[k,3] += hu->stoim_1
        endif
      next
    else
      if empty(lshifr := lshifr1)
        lshifr := usl->shifr
      endif
      lname := alltrim(usl->name)
      s := lshifr
      ta := f14tf_nastr(@lshifr,@lname,d2_year)
      lshifr := padr(lshifr,10)
      fl := .t.
      for j := 1 to len(ta)
        i16 := ta[j,3]
        k := ta[j,1] ; mkol1 := 0
        if between(k,1,10)
          if ta[j,2] == 1  // законченный случай
            mkol := human->k_data - human->n_data  // койко-день
            if between(ta[j,1],3,5) // дневной стационар до 1 апреля
              ++mkol
            endif
            if (i := ascan(arr_lp, {|x| x[1] == lshifr })) == 0
              aadd(arr_lp, {lshifr,{}}) ; i := len(arr_lp)
            endif
            if (i1 := ascan(arr_lp[i,2], {|x| x[1] == s })) == 0
              aadd(arr_lp[i,2], {s,0,0}) ; i1 := len(arr_lp[i,2])
            endif
            arr_lp[i,2,i1,2] += mkol
            arr_lp[i,2,i1,3] ++
          elseif ta[j,2] == 0
            mkol := hu->kol_1
            if between(ta[j,1],3,5) .or. (ta[j,1] == 2 .and. d2_year > 2013)
              arr_dn_st[2] := lshifr
              arr_dn_st[3] += mkol
            endif
          else
            mkol := 0
            mkol1 := hu->kol_1
            if between(ta[j,1],3,5) .or. (ta[j,1] == 2 .and. d2_year > 2013)
              arr_dn_st[1] := lshifr
            endif
          endif
          if mkol > 0
            if hu->kol_rcp < 0 .and. DomUslugaTFOMS(lshifr)
              s := iif(hu->kol_rcp == -1, "на дому", "на дому(АКТИВ)")
              if (i := ascan(arr_lp, {|x| x[1] == lshifr })) == 0
                aadd(arr_lp, {lshifr,{}}) ; i := len(arr_lp)
              endif
              if (i1 := ascan(arr_lp[i,2], {|x| x[1] == s })) == 0
                aadd(arr_lp[i,2], {s,0,0}) ; i1 := len(arr_lp[i,2])
              endif
              arr_lp[i,2,i1,2] += mkol
              //arr_lp[i,2,i1,3] ++
            endif
            if eq_any(left(lshifr,4),"2.3.","2.6.","2.60","1.11","55.1")
              s := inieditspr(A__MENUVERT, glob_V002, hu_->PROFIL)
              if (i := ascan(arr_lp, {|x| x[1] == lshifr })) == 0
                aadd(arr_lp, {lshifr,{}}) ; i := len(arr_lp)
              endif
              if (i1 := ascan(arr_lp[i,2], {|x| x[1] == s })) == 0
                aadd(arr_lp[i,2], {s,0,0}) ; i1 := len(arr_lp[i,2])
              endif
              arr_lp[i,2,i1,2] += mkol
              //arr_lp[i,2,i1,3] ++
            endif
          endif
          if k == 2
            tfoms_pz[1] += mkol
          elseif k == 1
            tfoms_pz[3] += mkol
          elseif k == 7
            tfoms_pz[5] += mkol
          elseif k == 8
            tfoms_pz[6] += mkol
          elseif eq_any(k,3,4,5)
            tfoms_pz[2] += mkol
          endif
          msum := hu->stoim_1*koef
          if eq_any(k,9,10)  // УЕТ для стоматологий
            suet += muet
            if apz2016[i16,2] == 62 // УЕТ стоматологии
              apz2016[i16,3] += muet
            endif
          elseif i16 > 0
            select MOUNIT
            set order to 2
            find (str(i16,3))
            if mounit->c_t == 2 // план-заказ подсчитывается по случаю
              //apz2016[i16,3] ++
              apz2016[i16,3] := 0
            else
              apz2016[i16,3] += mkol
            endif
            set order to 1
              /*if eq_any(apz2016[i16,2],57,60,61)
                if (i := ascan(apf, {|x| x[1]==lshifr })) == 0
                  aadd(apf, {lshifr,0}) ; i := len(apf)
                endif
                apf[i,2] += iif(empty(mkol), mkol1, mkol)
              endif*/
          endif
          select TMP
          find (padr(lshifr,10))
          if !found()
            append blank
            tmp->shifr := lshifr
            tmp->u_name := lname
          endif
          if fl
            tmp->kol += mkol
            tmp->kol1 += mkol1
            tmp->uet += muet
            tmp->sum += msum
            if su == 1 .and. ((between(k,1,8) .and. !empty(mkol)) .or. !empty(muet))
              aadd(au_su1,{hu->otd,human->kod_k,human->kod,k,mkol,muet})
            endif
          endif
          as[k,1] += mkol
          as[k,2] += muet
          as[k,3] += msum
          fl := .f.
        endif
      next
    endif
  endif
  select HU
  skip
enddo
if !empty(sdializ)
  if (i := ascan(arr_lp, {|x| x[1] == sdializ })) == 0
    aadd(arr_lp, {sdializ,{}}) ; i := len(arr_lp)
  endif
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    lshifr := alltrim(mosu->shifr1)
    if mohu->kol_1 > 0 .and. ascan(glob_MU_dializ,lshifr) > 0
      if (i1 := ascan(arr_lp[i,2], {|x| x[1] == lshifr })) == 0
        aadd(arr_lp[i,2], {lshifr,0,0}) ; i1 := len(arr_lp[i,2])
      endif
      arr_lp[i,2,i1,2] += mohu->kol_1
    endif
    select MOHU
    skip
  enddo
elseif !emptyany(arr_dn_st[1],arr_dn_st[2],arr_dn_st[3]) // дневной стационар с 1 апреля 2013 года или КСГ с 2014 года
  if (i := ascan(arr_lp, {|x| x[1] == arr_dn_st[1] })) == 0
    aadd(arr_lp, {arr_dn_st[1],{}}) ; i := len(arr_lp)
  endif
  if (i1 := ascan(arr_lp[i,2], {|x| x[1] == arr_dn_st[2] })) == 0
    aadd(arr_lp[i,2], {arr_dn_st[2],0,0}) ; i1 := len(arr_lp[i,2])
  endif
  arr_lp[i,2,i1,2] += arr_dn_st[3]
  arr_lp[i,2,i1,3] ++
endif
if su == 1
  for i := 1 to len(au_su1)
    // aadd(au_su1,{hu->otd,human->kod_k,human->kod,k,mkol,muet})
    select TMPO
    find (str(au_su1[i,1],3))
    if !found()
      append blank
      tmpo->otd := au_su1[i,1]
    endif
    if au_su1[i,4] == 2
      tmpo->kol1 += au_su1[i,5]
    elseif au_su1[i,4] == 1
      tmpo->kol3 += au_su1[i,5]
    elseif au_su1[i,4] == 6
      tmpo->kol4 += au_su1[i,5]
    elseif au_su1[i,4] == 7
      tmpo->kol6 += au_su1[i,5]
    elseif au_su1[i,4] == 8
      tmpo->kol7 += au_su1[i,5]
    elseif eq_any(au_su1[i,4],3,4,5)
      tmpo->kol2 += au_su1[i,5]
    endif
    tmpo->kol5 += au_su1[i,6]
    if i == len(au_su1)
      select TMPOK
      find (str(au_su1[i,1],3)+str(au_su1[i,2],7))
      if !found()
        append blank
        tmpok->otd := au_su1[i,1]
        tmpok->kod_k := au_su1[i,2]
      endif
      select TMPOS
      find (str(au_su1[i,1],3)+str(au_su1[i,3],7))
      if !found()
        append blank
        tmpos->otd := au_su1[i,1]
        tmpos->kod := au_su1[i,3]
      endif
    endif
  next i
endif
return NIL

*****
Static Function ret_g_o_i(r,c)
Static sast := {.t.,.f.},;
       sarr := {{'город+область',1},;
                {'иногородние  ',2}}
Local ret, i, j, a
if (a := bit_popup(T_ROW,T_COL-5,sarr,sast)) != NIL
  ret := {} ; afill(sast,.f.)
  for i := 1 to len(a)
    aadd(ret,a[i,2])
    if (j := ascan(sarr,{|x| x[2]==a[i,2] })) > 0
      sast[j] := .t.
    endif
  next
endif
return ret

*****
Static Function ret_z_n(r,c)
Static sast := {.t.,.t.},;
       sarr := {{'не закончившие лечение',B_END},;
                {'закончившие лечение'   ,B_STANDART}}
Local ret, i, j, a
if (a := bit_popup(T_ROW,T_COL-5,sarr,sast)) != NIL
  ret := {} ; afill(sast,.f.)
  for i := 1 to len(a)
    aadd(ret,a[i,2])
    if (j := ascan(sarr,{|x| x[2]==a[i,2] })) > 0
      sast[j] := .t.
    endif
  next
endif
return ret

*****
Static Function ret_reestr_no(r,c)
Static sast := {.t.,.t.},;
       sarr := {{'не попавшие в реестры',1},;
                {'попавшие в реестры'   ,2}}
Local ret, i, j, a
if (a := bit_popup(T_ROW,T_COL-5,sarr,sast)) != NIL
  ret := {} ; afill(sast,.f.)
  for i := 1 to len(a)
    aadd(ret,a[i,2])
    if (j := ascan(sarr,{|x| x[2]==a[i,2] })) > 0
      sast[j] := .t.
    endif
  next
endif
return ret

***** 19.02.13
Function pz2statist(arr_m,par2)
Local begin_date, end_date, buf := save_maxrow(), fl := .f., mstr_crb, mismo
begin_date := arr_m[7]
end_date := arr_m[8]
//
mywait()
//
adbf := {{"KOMU"     ,   "N",     1,     0},; // от 0 до 5
         {"STR_CRB"  ,   "N",     2,     0},; // код стр.компании, комитета и т.п.
         {"NKOMU"    ,   "C",    35,     0},;
         {"IFIN"     ,   "N",     1,     0},;
         {"SMO"      ,   "C",     5,     0},; // код СМО
         {"KOL_BOLN" ,   "N",     6,     0},;
         {"SUMMA"    ,   "N",    13,     2},;
         {"is"       ,   "N",     1,     0}}
dbcreate(cur_dir+"tmp_smo",adbf)
use (cur_dir+"tmp_smo") new alias TMP
index on str(komu,1)+str(str_crb,2)+smo to (cur_dir+"tmp_smo1")
index on nkomu to (cur_dir+"tmp_smo2")
set index to (cur_dir+"tmp_smo1"),(cur_dir+"tmp_smo2")
if par2 == 2
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humans","HUMAN")
  set relation to recno() into HUMAN_
endif
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
set relation to recno() into SCHET_
set filter to empty(schet_->IS_DOPLATA)
go top
do while !eof()
  if par2 == 1
    if emptyany(schet_->nyear,schet_->nmonth)
      fl := between(schet->pdate,arr_m[7],arr_m[8])
    else
      mdate := stod(strzero(schet_->nyear,4)+strzero(schet_->nmonth,2)+'15')
      fl := between(mdate,arr_m[5],arr_m[6])
    endif
    if fl .and. mdate_reg != NIL
      fl := (schet_->NREGISTR==0 .and. date_reg_schet() <= mdate_reg)
    endif
  else
    if emptyany(schet_->nyear,schet_->nmonth)
      fl := .f.
    else
      mdate := stod(strzero(schet_->nyear,4)+strzero(schet_->nmonth,2)+'01')
      do while .t.
        if (fl := between(mdate,arr_m[5],arr_m[6]))
          exit
        endif
        ++mdate
        if mdate == eom(mdate)
          exit
        endif
      enddo
    endif
  endif
  if fl
    if schet->komu == 2 .or. int(val(schet_->smo))==34
      fl := (ascan(arr_goi,2) > 0)
    else
      fl := (ascan(arr_goi,1) > 0)
    endif
  endif
  if fl .and. schet->komu != 5
    if schet_->ifin > 0
      mkomu := 0
      mstr_crb := 0
      msmo := schet_->smo
    else
      mkomu := iif(schet->komu==1, 1, 3)
      mstr_crb := schet->str_crb
      msmo := space(5)
    endif
    if par2 == 1
      select TMP
      find (str(mkomu,1)+str(mstr_crb,2)+msmo)
      if !found()
        append blank
        replace tmp->komu with mkomu,;
                tmp->str_crb with mstr_crb, tmp->smo with msmo,;
                tmp->is with 1
      endif
      tmp->kol_boln += schet->kol
      tmp->summa += schet->summa
    else
      select HUMAN
      find (str(schet->kod,6))
      do while human->schet == schet->kod .and. !eof()
        if between(human->k_data,arr_m[5],arr_m[6]) ;
                .and. iif(v_deti==1,.t.,human->VZROS_REB>0)
          select TMP
          find (str(mkomu,1)+str(mstr_crb,2)+msmo)
          if !found()
            append blank
            replace tmp->komu with mkomu,;
                    tmp->str_crb with mstr_crb, tmp->smo with msmo,;
                    tmp->is with 1
          endif
          tmp->kol_boln ++
          tmp->summa += human->cena_1
        endif
        select HUMAN
        skip
      enddo
    endif
  endif
  select SCHET
  skip
enddo
if tmp->(lastrec()) == 0
  fl := func_error(4,"Нет счетов за указанный период времени!")
else
  schet->(dbCloseArea())
  select TMP
  dbeval({|| tmp->nkomu := f4_view_list_schet(tmp->komu,tmp->smo,tmp->str_crb) })
  set order to 2
  go top
  if Alpha_Browse(T_ROW,0,maxrow()-1,79,"pz21statist",color0,;
                  "Счета "+arr_m[4],"R/BG",,,,,;
                  "pz22statist",,{'═','░','═',"N/BG,W+/N,B/BG,W+/B",,0} )
    fl := .t.
  endif
endif
close databases
rest_box(buf)
return fl

*****
Function pz21statist(oBrow)
Local oColumn, blk := {|| iif (tmp->is==1, {1,2}, {3,4}) }
oColumn := TBColumnNew(" ", {|| if(tmp->is==1,""," ")})
oBrow:addColumn(oColumn)
oColumn:colorBlock := blk
oColumn := TBColumnNew(center("Принадлежность счета",35),{|| left(tmp->nkomu,35)})
oBrow:addColumn(oColumn)
oColumn:colorBlock := blk
oColumn := TBColumnNew(" Кол.; бол.", {|| str(tmp->kol_boln,6) })
oBrow:addColumn(oColumn)
oColumn:colorBlock := blk
oColumn := TBColumnNew(" Сумма счета", {|| put_kop(tmp->summa,13) })
oBrow:addColumn(oColumn)
oColumn:colorBlock := blk
oColumn := TBColumnNew(" ", {|| if(tmp->is==1,""," ")})
oBrow:addColumn(oColumn)
oColumn:colorBlock := blk
status_key("^<Esc>^ - выход;  ^<Enter>^ - подсчет;  ^<Ins><+><->^ - отметить СМО для подсчета")
return NIL

*****
Function pz22statist(nKey,oBrow)
Local ret := 0
do case
  case nKey == 45  // минус
    rec := tmp->(recno())
    tmp->( dbeval({|| tmp->is := 0 } ))
    tmp->(dbGoto(rec))
    ret := 0
  case nKey == 43  // плюс
    rec := tmp->(recno())
    tmp->( dbeval({|| tmp->is := 1 } ))
    tmp->(dbGoto(rec))
    ret := 0
  case nKey == K_INS
    tmp->is := iif(tmp->is == 1, 0, 1)
    oBrow:down()
    ret := 0
endcase
return ret

***** 27.09.13 Расчёт потребности в финансовом обеспечении выполнения объёмов мед.помощи
Function pz_raschet_potr()
Local buf := savescreen(), fl_exit := .f., i, j, k, lreg_lech[9], ;
      name_file := "pz_r_p"+stxt, arr_m, ta[2], arr_title, lshifr, ;
      d2_year, sh := 80, HH := 80, reg_print := 5, au
if (arr_m := input_year()) == NIL
  return NIL
endif
Private s_stac, sdstac, s_amb, skt, ssmp, suet, sstoim
s_stac := sdstac := s_amb := skt := ssmp := suet := sstoim := 0
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
dbcreate(cur_dir+"tmp",{;
  {"shifr","C",10,0},;
  {"tip1","N",1,0},;
  {"tip2","N",1,0},;
  {"vr","N",1,0},; // 0-взрослый, 1-ребенок
  {"tarif","N",10,2},;
  {"mm","N",2,0},;
  {"kol1","N",11,2},;
  {"kol2","N",11,2},;
  {"kol3","N",11,2},;
  {"kol4","N",11,2};
 })
use (cur_dir+"tmp") new
index on shifr+str(vr,1)+str(tarif,10,2) to (cur_dir+"tmp")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to u_kod into USL, to recno() into HU_
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
set relation to recno() into HUMAN_
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",,"SCHET")
set relation to recno() into SCHET_
index on pdate+nomer_s to (cur_dir+"tmp_sch") ;
      for emptyall(schet_->NREGISTR,schet_->IS_DOPLATA) .and. ;
          int(val(schet_->smo)) > 34000 .and. schet_->nyear==arr_m[1] .and. ;
          between(date_reg_schet(),arr_m[5],arr_m[6])
go top
do while !eof()
  @ maxrow(),0 say padr(alltrim(schet_->NSCHET)+" "+;
                        date_8(schet_->DSCHET),24) color "W/R"
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  select HUMAN
  find (str(schet->kod,6))
  do while human->schet == schet->kod .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if human_->oplata != 9
      d2_year := year(human->k_data)
      lvr := iif(human->vzros_reb==0, 1, 2)
      sstoim += human->cena_1
      afill(lreg_lech,0)
      is_z_sl := .f.
      au := {}
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        muet := hu->kol_1 * ret_tfoms_uet(usl->shifr,lshifr,human->vzros_reb)
        if empty(lshifr)
          lshifr := usl->shifr
        endif
        ta := f14tf_nastr(lshifr,,d2_year)
        for j := 1 to len(ta)
          k := ta[j,1]
          if between(k,1,8)
            i := 2                // остальные - амбулаторно
            if k == 2             // k := 2 - койко-дни
              i := 1
            elseif between(k,3,5) // k := 3,4,5 - дневной стационар
              i := 3
            elseif k == 7 // о/м/у
              i := 4
            elseif k == 8 // СМП
              i := 5
            endif
            ++ lreg_lech[i]
            if k != 6 // не стомат.посещение
              aadd(au,{i,iif(ta[j,2]==0,1,2),lshifr,hu->kol_1,hu->u_cena,hu_->profil})
              if ta[j,2] != 0
                is_z_sl := .t.
              endif
            endif
          endif
          if eq_any(k,9,10)  // УЕТ для стоматологий
            suet += muet
            aadd(au,{6,1,iif(k==9,"УЕТ леч.","УЕТ орт."),muet,0,0})
          endif
        next
        select HU
        skip
      enddo
      if lreg_lech[1] > 0
        ++s_stac
      elseif lreg_lech[3] > 0
        ++sdstac
      elseif lreg_lech[4] > 0
        ++skt
      elseif lreg_lech[5] > 0
        ++ssmp
      else
        ++s_amb
      endif
      if eq_any(human->ishod,101,102,201,202,203,204,205,301,302,303,304,305)
        is_disp := .t.
        is_z_sl := .f.
      else
        is_disp := .f.
      endif
      k := month(human->k_data)
      for i := 1 to len(au)
        if is_z_sl
          if au[i,2] == 1 // оставим только законченный случай
            loop          // пропустим все остальные услуги
          endif
        elseif is_disp
          if au[i,2] == 2 // оставим только приёмы
            loop          // пропустим шифр законченного случая
          endif
          au[i,3] := str(au[i,6],10)
          au[i,5] := au[i,6]
        endif
        select TMP
        find (padr(au[i,3],10)+str(lvr,1)+str(au[i,5],10,2))
        if !found()
          append blank
          tmp->shifr := au[i,3]
          tmp->tip1 := iif(is_disp, 7, au[i,1])
          tmp->tip2 := au[i,2]
          tmp->vr := lvr
          tmp->tarif := au[i,5]
        endif
        if tmp->mm == 0 .or. k < tmp->mm
          tmp->mm := k
        endif
        if between(k,1,3)
          tmp->kol1 += au[i,4]
        elseif between(k,4,6)
          tmp->kol2 += au[i,4]
        elseif between(k,7,9)
          tmp->kol3 += au[i,4]
        else
          tmp->kol4 += au[i,4]
        endif
      next
    endif
    select HUMAN
    skip
  enddo
  if fl_exit ; exit ; endif
  select SCHET
  skip
enddo
if fl_exit
  close databases
  return NIL
endif
arr_title := {;
"───────────────────────────────┬───┬────────┬────────┬────────┬────────┬────────",;
" Услуга                        │Вид│ Тариф  │ I кв.  │ II кв. │ III кв.│ IV кв. ",;
"───────────────────────────────┴───┴────────┴────────┴────────┴────────┴────────"}
// 32                                   8.2     9
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string(padl("дата печати "+date_8(sys_date),sh))
add_string("")
add_string(center("Расчёт потребности в финансовом обеспечении выполнения объёмов мед.помощи",sh))
add_string(center("по зарегистрированным счетам "+arr_m[4],sh))
add_string(center("[ отчётный период "+lstr(arr_m[1])+" год]",sh))
add_string(center("[ без учёта иногородних ]",sh))
add_string(center("[ без учёта повторно выставленных случаев ]",sh))
add_string("")
add_string("Всего листов учета: "+lstr(s_stac+sdstac+s_amb+skt+ssmp))
add_string("   в том числе:")
if s_stac > 0
  add_string(padl("стационар:",31)+" "+lstr(s_stac))
endif
if sdstac > 0
  add_string(padl("дневной стационар:",31)+" "+lstr(sdstac))
endif
if s_amb > 0
  add_string(padl("поликлиника:",31)+" "+lstr(s_amb))
endif
if skt > 0
  add_string(padl("отдельные медицинские услуги:",31)+" "+lstr(skt))
endif
if ssmp > 0
  add_string(padl("скорая медицинская помощь:",31)+" "+lstr(ssmp))
endif
add_string("")
add_string("Общая сумма лечения :  "+lstr(sstoim,13,2))
if suet > 0
  add_string("Общее количество УЕТ:  "+alltrim(str_0(suet,13,2)))
endif
aeval(arr_title, {|x| add_string(x) } )
if select("LUSL") == 0
  Use_base("lusl")
endif
select TMP
index on str(tip1,1)+str(tip2,1)+fsort_usl(shifr)+str(mm,2)+str(vr,1) to (cur_dir+"tmp")
for i := 1 to 7
  for j := 1 to 2
    find (str(i,1)+str(j,1))
    if !found() ; loop ; endif
    if verify_FF(HH-3,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    s := {"Стационар","Поликлиника","Дневной стационар","Отдельые медуслуги",;
          "СМП","Стоматология","Диспансеризация/Профилактика/Медосмотры"}[i]
    if i == 1
      s += " ["+{"койко-дни","законченные случаи"}[j]+"]"
    elseif i == 2
      s += " ["+{"посещения","обращения"}[j]+"]"
    elseif i == 3
      s += " ["+{"пациенто-дни","законченные случаи"}[j]+"]"
    endif
    add_string("")
    add_string(s)
    add_string(replicate("─",sh))
    do while tmp->tip1==i .and. tmp->tip2==j .and. !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      if tmp->tip1 == 7
        s := inieditspr(A__MENUVERT, glob_V002, int(tmp->tarif))
        s := padr(s,31)+" "+{"вз.","реб"}[tmp->vr]+space(9)
      else
        s := alltrim(tmp->shifr)+" "
        select LUSL
        find (padr(tmp->shifr,10))
        if found()
          s += lusl->name
        endif
        s := padr(s,31)+" "+{"вз.","реб"}[tmp->vr]+put_kopE(tmp->tarif,9)
      endif
      s += umest_val(tmp->kol1,9,2)+umest_val(tmp->kol2,9,2)+;
           umest_val(tmp->kol3,9,2)+umest_val(tmp->kol4,9,2)
      add_string(s)
      select TMP
      skip
    enddo
  next
next
fclose(fp)
close databases
restscreen(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

***** 30.10.14 статистика по работе операторов
Function st_operator()
Local i, j, k, mdate, buf24, sh := 0, arr_oper := {}, arr_g,;
      s0, s1, s2, s3, s4, buf, name_file := "operator"+stxt, ;
      arr_title, reg_print := 2, ls, fl_orto := .f., r1 := 9,;
      arrNtitle, llen, ldec, fl_old, fl_new
Private koef0, koef1 := 20, koef2 := 9, koef21 := 3, koef3 := 1, ;
        stoim := 0.012, mprocent := 0,;
        koef_orto := 22, koef1_orto := 22
koef0 := koef1 - koef2
if tip_polzovat != 0
  return func_error(4,"Доступ в данный режим разрешен только администратору системы!")
endif
if (arr_g := year_month()) == NIL
  return NIL
endif
R_Use(dir_server+"mo_oper",dir_server+"mo_oper","OP")
dbseek(arr_g[7],.t.)
fl_old := (op->pd <= arr_g[8] .and. !eof())
close databases
//
R_Use(dir_server+"mo_opern",dir_server+"mo_opern","OP")
dbseek(arr_g[7],.t.)
fl_new := (op->pd <= arr_g[8] .and. !eof())
close databases
buf24 := save_maxrow()
if fl_old
  if is_task(X_ORTO)
    fl_orto := .t. ; r1 -= 2
  endif
  setcolor(cDataCGet)
  buf := box_shadow(r1,10,22,69)
  str_center(r1+2,"Вам предлагаются следующие коэффициенты трудоемкости",color8)
  str_center(r1+3,"(которые имеется возможность отредактировать):",color8)
  j := r1+5
  @ j,13 say "Заполнение картотеки (РЕГИСТРАТУРА)               " ;
                         get koef0 pict "99" valid {|g| fst_operator(g)}
  ++j
  @ j,13 say "Ввод полных реквизитов при вводе листа учёта      " ;
                         get koef1 pict "99" valid {|g| fst_operator(g)}
  ++j
  @ j,13 say "Выбор из картотеки при вводе листа учёта          " ;
                         get koef2 pict "99" valid {|g| fst_operator(g)}
  ++j
  @ j,13 say "Повторный выбор пациента из картотеки при вводе   " ;
                         get koef21 pict "99" valid {|g| fst_operator(g)}
  ++j
  @ j,13 say "Коэффициент трудоемкости при вводе одной услуги   " ;
          get koef3 pict "99" when .f.
  if fl_orto
    ++j
    @ j,13 say "Заполнение картотеки в задаче ОРТОПЕДИЯ           " ;
                         get koef1_orto pict "99" valid {|g| fst_operator(g)}
    ++j
    @ j,13 say "Заполнение ортопедической карточки больного       " ;
                         get koef_orto pict "99" valid {|g| fst_operator(g)}
  endif
  ++j
  @ j,13 say "Цена одной условной единицы информации в рублях" ;
          get stoim pict "9.999"
  ++j
  @ j,13 say "Процент надбавки" get mprocent pict "99"
  status_key("^<Esc>^ - выход из режима;  ^<Enter>^ - подтверждение ввода")
  myread()
  rest_box(buf)
  if lastkey() == K_ESC
    return NIL
  endif
  if mprocent > 0
    reg_print := 3
  endif
  mywait()
  arr_title := array(5)
  arr_title[1] := "────────────────────┬─────────┬─────────┬─────────┬─────────┬──────┬───────┬────────"
  arr_title[2] := "       Ф.И.О.       │Карточка │ Полные  │Выбор из │  Кол-во │Объём │ Объём │Заработ."
  arr_title[3] := "     операторов     │(реги-ра)│реквизиты│картотеки│  услуг  │в усл.│ работ │ сумма  "
  arr_title[4] := "                    │"+padc("( *"+lstr(koef0)+" )",9)+;
                                                "│"+padc("( *"+lstr(koef1)+" )",9)+;
                                                          "│"+padc("( *"+lstr(koef2)+"/"+lstr(koef21)+" )",9)+;
                                                                    "│"+padc("( *"+lstr(koef3)+" )",9)+;
                                                                              "│един. │  в %  │ в руб. "
  arr_title[5] := "────────────────────┴─────────┴─────────┴─────────┴─────────┴──────┴───────┴────────"
  if mprocent > 0
    arr_title[1] := arr_title[1]+"┬────────"
    arr_title[2] := arr_title[2]+"│Зарплата"
    arr_title[3] := arr_title[3]+"│ в руб."
    arr_title[4] := arr_title[4]+"│"+padc("(+"+lstr(mprocent)+"%)",8)
    arr_title[5] := arr_title[5]+"┴────────"
  endif
  sh := len(arr_title[1])
endif
if fl_new
  arrNtitle := array(5)
  arrNtitle[1] := "──────────────────────────────┬────────────┬────────────┬────────────┬──────────"
  arrNtitle[2] := "                              │ Картотека  │ Лист учёта │   Услуги   │Всего от- "
  arrNtitle[3] := "  Ф.И.О. операторов           ├─────┬──────┼─────┬──────┼─────┬──────┤редактиро-"
  arrNtitle[4] := "                              │ чел.│ полей│ л/у │ полей│услуг│ полей│вано полей"
  arrNtitle[5] := "──────────────────────────────┴─────┴──────┴─────┴──────┴─────┴──────┴──────────"
  sh := max(sh,len(arrNtitle[1]))
endif
fp := fcreate("operator"+stxt) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Объём работы операторов",sh))
add_string(center(arr_g[4],sh))
add_string("")
if fl_old
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+"base1",,"B1")
  R_Use(dir_server+"mo_oper",dir_server+"mo_oper","OP")
  dbseek(arr_g[7],.t.)
  do while op->pd <= arr_g[8] .and. !eof()
    if (i := ascan(arr_oper, {|x| x[1]==op->task })) == 0
      aadd(arr_oper, {op->task,{}} ) ; i := len(arr_oper)
    endif
    if op->app_edit == 1 .and. ;
           ascan(arr_oper[i,2], {|x| x[1]==op->po .and. x[10]==0 }) == 0
      b1->(dbGoto(asc(op->po)))
      aadd(arr_oper[i,2], {op->po,;
                           crypt(b1->p1,gpasskod),;
                           0,;
                           0,;
                           0,;
                           0,;
                           0,;
                           0,;
                           0,;
                           0} )
    endif
    if (k := ascan(arr_oper[i,2], ;
               {|x| x[1]==op->po .and. x[10]==op->app_edit })) == 0
      b1->(dbGoto(asc(op->po)))
      aadd(arr_oper[i,2], {op->po,;
                           crypt(b1->p1,gpasskod),;
                           0,;
                           0,;
                           0,;
                           0,;
                           0,;
                           0,;
                           0,;
                           op->app_edit} )
      k := len(arr_oper[i,2])
    endif
    if op->app_edit == 0
      llen := 6 ; ldec := 0
    else
      llen := 7 ; ldec := 2
    endif
    arr_oper[i,2,k,3] += ft_unsqzn(op->v0,llen,ldec)
    arr_oper[i,2,k,4] += ft_unsqzn(op->vr,llen,ldec)
    arr_oper[i,2,k,5] += ft_unsqzn(op->vk,6,0)  // всегда целое число
    arr_oper[i,2,k,6] += ft_unsqzn(op->vu,llen,ldec)
    skip
  enddo
  store 0 to s0, s1, s2, s3, s4, skart, skart2
  asort(arr_oper,,,{|x,y| x[1] < y[1] } )
  for i := 1 to len(arr_oper)
    asort(arr_oper[i,2],,,{|x,y| if(x[2]==y[2], x[10] < y[10], x[2] < y[2]) } )
    aeval(arr_oper[i,2], {|x| s0 += x[3], s1 += x[4], s2 += x[5], s3 += x[6] } )
    if eq_any(arr_oper[i,1],3,4)  // ОРТОПЕДИЯ
      aeval(arr_oper[i,2], {|x,j| arr_oper[i,2,j,7] := ;
                  round(koef1_orto*x[3] + koef_orto*x[5] + koef3*x[6],0) } )
    else
      aeval(arr_oper[i,2], {|x,j| arr_oper[i,2,j,7] := ;
                            round(koef0 * x[3] + ;
                                  koef1 * x[4] + ;
                                  iif(x[10]==0, koef2, koef21) * x[5] + ;
                                  koef3 * x[6], 0) ;
                           } )
    endif
    aeval(arr_oper[i,2], {|x,j| s4 += arr_oper[i,2,j,7] } )
  next
  close databases
  s4 := round(s4,0) // объем в условных единицах - целое число
  if s4 > 0
    for i := 1 to len(arr_oper)
      for j := 1 to len(arr_oper[i,2])
        if arr_oper[i,2,j,10] == 1 .and. j > 1 ;
                           .and. arr_oper[i,2,j-1,10] == 0 ;
                           .and. arr_oper[i,2,j-1,1] == arr_oper[i,2,j,1]
          arr_oper[i,2,j-1,7] += arr_oper[i,2,j,7]
        endif
        if arr_oper[i,2,j,10] == 0   // учет только добавлений
          skart += (arr_oper[i,2,j,4] + arr_oper[i,2,j,5])
        endif
        if arr_oper[i,2,j,10] == 1   // учет вторичных выборов
          skart2 += arr_oper[i,2,j,5]
        endif
        arr_oper[i,2,j,8] := arr_oper[i,2,j,7]*100/s4
      next
    next
    // подсчет процентов
    for i := 1 to len(arr_oper)
      for j := 1 to len(arr_oper[i,2])
        arr_oper[i,2,j,8] := arr_oper[i,2,j,7]*100/s4
      next
    next
    k := ssum := szrp := 0 ; fl_orto := .f.
    for i := 1 to len(arr_oper)
      sum1 := zrp1 := 0
      s := "СТРАХОВАЯ МЕДИЦИНА"
      if arr_oper[i,1] == 1
        s := "РЕГИСТРАТУРА"
      elseif arr_oper[i,1] == 2
        s := "ПЛАТНЫЕ УСЛУГИ"
      elseif eq_any(arr_oper[i,1],3,4)
        s := "ОРТОПЕДИЯ "+iif(arr_oper[i,1] == 3, "ПЛАТНАЯ", "БЕСПЛАТНАЯ")
        if !fl_orto
          arr_title[4] := stuff(arr_title[4],22,9,padc("( *"+lstr(koef1_orto)+" )",9))
          arr_title[4] := stuff(arr_title[4],42,9,padc("( *"+lstr(koef_orto)+" )",9))
          add_string("")
          aeval(arr_title, {|x| add_string(x) } )
          fl_orto := .t.
        endif
      endif
      add_string(center(expand(s),sh))
      for j := 1 to len(arr_oper[i,2])
        if arr_oper[i,2,j,7] > 0
          if arr_oper[i,2,j,10] == 0
            ++k
            ls := round(arr_oper[i,2,j,7]*stoim,2)
            sum1 += ls
            ssum += ls
            s := arr_oper[i,2,j,2]+;
                 put_val(arr_oper[i,2,j,3],9)+;
                 put_val(arr_oper[i,2,j,4],10)+;
                 put_val(arr_oper[i,2,j,5],10)+;
                 put_val(arr_oper[i,2,j,6],10)+;
                 put_val(arr_oper[i,2,j,7],8)+;
                 put_val(arr_oper[i,2,j,8],8,2)+;
                 put_kopE(ls,9)
            if mprocent > 0
              ls := round(ls * (100+mprocent) / 100, 2)
              s += put_kopE(ls,9)
              zrp1 += ls
              szrp += ls
            endif
          else
            s := space(20)+;
                 put_dec_oper(arr_oper[i,2,j,3],9)+;
                 put_dec_oper(arr_oper[i,2,j,4],10)+;
                 put_dec_oper(arr_oper[i,2,j,5],10)+;
                 put_dec_oper(arr_oper[i,2,j,6],10)
          endif
          add_string(s)
        endif
      next
      add_string(space(sh-25)+replicate("-",25))
      s := padl("Итого : "+lput_kop(sum1),84)
      if mprocent > 0
        s += put_kopE(zrp1,9)
      endif
      add_string(s)
    next
    if k > 1
      add_string(replicate("─",sh))
      s := padl("Итого : ",20)+put_dec_oper(s0,9,.f.)+;
                               put_dec_oper(s1,10,.f.)+;
                               put_dec_oper(s2,10,.f.)+;
                               put_dec_oper(s3,10,.f.)+;
                               put_val(s4,8)+;
                               space(8)+;
                               put_kopE(ssum,9)
      if mprocent > 0
        s += put_kopE(szrp,9)
      endif
      add_string(s)
    endif
    add_string(replicate("─",sh))
    add_string("  Количество введенных карточек : "+lstr(skart))
    if skart2 > 0
      add_string("  повторных выборов из картотеки: "+lstr(skart2))
    endif
  endif
endif
if fl_new
  dbcreate(cur_dir+"tmp",{;
   {"PO",      "N",   3,   0},; // код оператора
   {"FO",      "C",  20,   0},; // ФИО оператора
   {"PT",      "N",   3,   0},; // код задачи
   {"TP",      "N",   1,   0},; // тип (1-карточка, 2-л/у, 3-услуги)
   {"AE",      "N",   1,   0},; // 1-добавление, 2-редактирование, 3-удаление
   {"KK",      "N",   9,   0},; // кол-во (карточек, л/у или услуг)
   {"KP",      "N",   9,   0};  // количество введённых полей
  })
  use (cur_dir+"tmp") new
  index on str(pt,3)+str(po,3)+str(ae,1)+str(tp,1) to (cur_dir+"tmp")
  R_Use(dir_server+"base1",,"B1")
  R_Use(dir_server+"mo_opern",dir_server+"mo_opern","OP")
  dbseek(arr_g[7],.t.)
  do while op->pd <= arr_g[8] .and. !eof()
    _po := asc(op->po)
    _pt := asc(op->pt)
    _ae := asc(op->ae)
    _tp := asc(op->tp)
    llen := 6
    select TMP
    find (str(_pt,3)+str(_po,3)+str(_ae,1)+str(_tp,1))
    if !found()
      append blank
      tmp->pt := _pt
      tmp->po := _po
      tmp->ae := _ae
      tmp->tp := _tp
      b1->(dbGoto(_po))
      tmp->fo := crypt(b1->p1,gpasskod)
    endif
    tmp->kk += ft_unsqzn(op->kk,llen)
    tmp->kp += ft_unsqzn(op->kp,llen)
    select OP
    skip
  enddo
  arr_task := {;
    {"Регистратура"     ,X_REGIST},;
    {"Приёмный покой"   ,X_PPOKOJ},;
    {"ОМС"              ,X_OMS   },;
    {"Платные услуги"   ,X_PLATN },;
    {"Ортопедия ПЛАТНАЯ",X_ORTO  },;
    {"Ортопедия БЮДЖЕТ" ,X_ORTO+100},;
    {"Касса МО"         ,X_KASSA };
   }
  aeval(arrNtitle, {|x| add_string(x) } )
  select TMP
  for i := 1 to len(arr_task)
    find (str(arr_task[i,2],3))
    if found()
      add_string(padc(arr_task[i,1],sh,"_"))
      arr_oper := {}
      find (str(arr_task[i,2],3))
      do while tmp->pt == arr_task[i,2] .and. !eof()
        if ascan(arr_oper, {|x| x[2] == tmp->po }) == 0
          aadd(arr_oper, {tmp->fo,tmp->po})
        endif
        skip
      enddo
      asort(arr_oper,,,{|x,y| upper(x[1]) < upper(y[1]) })
      for j := 1 to len(arr_oper)
        for k := 1 to 3
          s := padr(iif(k==1, arr_oper[j,1], ""), 21)
          s += padr({"добавлено","отредакт.","удалено"}[k],9)
          skp := 0
          for n := 1 to 3
            find (str(arr_task[i,2],3)+str(arr_oper[j,2],3)+str(k,1)+str(n,1))
            s += put_val(tmp->kk,5)+put_val(tmp->kp,7)+" "
            skp += tmp->kp
          next
          s += put_val(skp,9)
          add_string(s)
        next
      next
    endif
  next
endif
fclose(fp)
close databases
rest_box(buf24)
viewtext(Devide_Into_Pages(name_file,60,80),,,,.t.,,,2)
return NIL

*****
Static Function fst_operator(get)
Local mvar := readvar(), s := "Допустимый диапазон для данного коэффициента трудоемкости "
if mvar == "KOEF1" .and. !between(&mvar,15,99)
  &mvar := get:original
  return func_error(4,s+"15 - 99.")
endif
if (mvar == "KOEF0" .or. mvar == "KOEF2") .and. !between(&mvar,3,50)
  &mvar := get:original
  return func_error(4,s+"3 - 50.")
endif
if mvar == "KOEF21" .and. !between(&mvar,2,KOEF2-1)
  &mvar := get:original
  return func_error(4,s+"2 - "+lstr(KOEF2-1)+".")
endif
return .t.

*****
Static Function put_dec_oper(v,l,fl_plus)
Local s := put_val_0(v,l,2)
DEFAULT fl_plus TO .t.
return padl(if(empty(s).or.!fl_plus,"","+")+alltrim(s),l)

***** 13.08.18 печать бланков
Function prn_blank(k)
Static si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 1, si6 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~Онкология",;
                "Скорая ~помощь",;
                "Диспансеризация детей-~сирот",;
                "Диспансеризация ~взрослых",;
                "Медосмотры ~несовершеннолетних"}
    mas_msg := {"Распечатка бланков и справочников для онкологических листов учёта",;
                "Распечатка бланков для скорой помощи",;
                "Распечатка бланков по диспансеризации детей-сирот",;
                "Распечатка бланков по диспансеризации и профилактике взрослого населения",;
                "Распечатка бланков по медицинским осмотрам несовершеннолетних"}
    mas_fun := {"prn_blank(11)",;
                "prn_blank(12)",;
                "prn_blank(13)",;
                "prn_blank(14)",;
                "prn_blank(15)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    mas_pmt := {"~Контрольный лист учёта ЗНО",;
                "~Правила заполнения контрольного листа учёта ЗНО"}
    mas_msg := {"Распечатка контрольного листа учёта мед.помощи, оказанной пациентам, страдающим ЗНО",;
                "Распечатка правил заполнения контрольного листа учёта ЗНО"}
    mas_fun := {"prn_blank(61)",;
                "prn_blank(62)"}
    popup_prompt(T_ROW,T_COL-5,si6,mas_pmt,mas_msg,mas_fun)
  case k == 12
    mas_pmt := {"Приложение к ~карте вызова СМП",;
                "~Правила заполнения приложения"}
    mas_msg := {"Распечатка приложения к карте вызова скорой помощи",;
                "Распечатка правил заполнения приложения к карте вызова скорой помощи"}
    mas_fun := {"prn_blank(21)",;
                "prn_blank(22)"}
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 13
    mas_pmt := {"Диспансеризация детей-~сирот",;
                "~Памятка по заполнению л/у по диспансеризации детей-сирот"}
    mas_msg := {"Распечатка бланка листа учёта для диспансеризации детей-сирот",;
                "Распечатка памятки по заполнению л/у по диспансеризации детей-сирот"}
    mas_fun := {"prn_blank(31)",;
                "prn_blank(32)"}
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)
  case k == 14
    mas_pmt := {"~Диспансеризация I этап",;
                "Диспансеризация II ~этап",;
                "~Профилактический осмотр",;
                "Диспансеризация раз в ~2 года"}
    mas_msg := {"Распечатка бланка листа учёта для диспансеризации взрослого населения I этап",;
                "Распечатка бланка листа учёта для диспансеризации взрослого населения II этап",;
                "Распечатка бланка листа учёта для профилактичесого осмотра взрослого населения",;
                "Распечатка бланка листа учёта для диспансеризации взрослого населения раз в 2 года"}
    mas_fun := {"prn_blank(41)",;
                "prn_blank(42)",;
                "prn_blank(43)",;
                "prn_blank(44)"}
    popup_prompt(T_ROW,T_COL-5,si4,mas_pmt,mas_msg,mas_fun)
  case k == 15
    mas_pmt := {"Лист учёта ~профилактики несовершеннолетних",;
                "~Вклыдыш(и) услуг к л/у профилактики несовершеннолетних",;
                "Лист учёта пред~варительного медосмотра",;
                "Лист учёта перио~дического медосмотра"}
    mas_msg := {"Распечатка бланка листа учёта для профилактики несовершеннолетних",;
                "Распечатка вкладыша с услугами к л/у для профилактики несовершеннолетних",;
                "Распечатка бланка листа учёта для предварительного медосмотра несовершеннолетних",;
                "Распечатка бланка листа учёта для периодического медосмотра несовершеннолетних"}
    mas_fun := {"prn_blank(51)",;
                "prn_blank(52)",;
                "prn_blank(53)",;
                "prn_blank(54)"}
    popup_prompt(T_ROW,T_COL-5,si5,mas_pmt,mas_msg,mas_fun)
  case k == 21
    call_fr("smp_2")
  case k == 22
    call_fr("smpp_2")
  case k == 31
    call_fr("mo_b_dds")
  case k == 32
    call_fr("mo_p_dds")
  case k == 41
    call_fr("mo_b1dvn")
  case k == 42
    call_fr("mo_b2dvn")
  case k == 43
    call_fr("mo_b3dvn")
  case k == 44
    call_fr("mo_b4dvn")
  case k == 51
    call_fr("mo_b_pn")
  case k == 52
    f_blank_usl_pn()
  case k == 53
    call_fr("mo_b_predn")
  case k == 54
    call_fr("mo_b_pern")
  case k == 61 // Контрольный лист учёта ЗНО
    call_fr("mo_onko_KL")
  case k == 62 // Правила заполнения контрольного листа учёта ЗНО
    readme2wordpad(exe_dir+cslash+'RULE_KL.RTF')
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  elseif between(k,31,39)
    si3 := j
  elseif between(k,41,49)
    si4 := j
  elseif between(k,51,59)
    si5 := j
  elseif between(k,61,69)
    si6 := j
  endif
endif
return NIL

***** 11.09.18
FUNCTION pr_sprav_onk_vmp()
Static mm_usl_tip := {'"Хирургическое лечение"',;
                      '"Лекарственная противоопухолевая терапия"',;
                      '"Лучевая терапия"'}
Local buf := save_maxrow(), name_file := "metodVMPonko"+stxt, sh := 80, HH := 60, t_arr[2], i, s
mywait()
fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
R_Use(exe_dir+"_mo_ovmp",cur_dir+"_mo_ovmp","OVMP")
add_string("")
add_string(center("Классификатор методов ВМП по онкозаболеваниям с указанием типов лечения",sh))
add_string("")
for i := 1 to 1000
  find (str(i,3))
  if found()
    verify_FF(HH,.t.,sh)
    s := str(i,3)+"  "+mm_usl_tip[OVMP->USL1]
    if ovmp->usl2 > 0
      s += iif(ovmp->tip == 0, " или ", " и ")+mm_usl_tip[OVMP->USL2]
    endif
    add_string(s)
  endif
next
rest_box(buf)
fclose(fp)
viewtext(name_file,,,,.t.,,,2)
close databases
return NIL

***** 16.08.18
Function pr_sprav_N002(n)
Local sh := 75, HH := 60, reg_print := 2, name_file := "n00"+lstr(n)+".txt", i, ad := {},;
      as_ := {"","st","t","n","m"}, poled, polen, polek, lal, j, k, t_arr[2]
lal := "N"+lstr(n)
poled := lal+"->ds_"+as_[n]
polek := lal+"->kod_"+as_[n]
polen := lal+"->"+as_[n]+"_name"
R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
R_Use(dir_exe+"_mo_N00"+lstr(n),,"N"+lstr(n))
do case
  case n == 2
    index on ds_st to tmp_n2 unique memory
  case n == 3
    index on ds_t to tmp_n3 unique memory
  case n == 4
    index on ds_n to tmp_n4 unique memory
  case n == 5
    index on ds_m to tmp_n5 unique memory
endcase
go top
do while !eof()     
  aadd(ad, padr(&poled,6)) 
  skip
enddo
if empty(ad[1])
  aadd(ad,space(6))
  Del_Array(ad,1)
endif  
set index to (cur_dir+"_mo_N00"+lstr(n)+"d")
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Классификатор "+{"","стадий","Tumor","Nodus","Metastasis"}[n]+" N00"+lstr(n),sh))
add_string("")
for i := 1 to len(ad)
  verify_FF(HH-2,.t.,sh)
  add_string(replicate("-",sh))
  if empty(ad[i])
    add_string("Прочие диагнозы")
  else
    fl := .t.
    select DIAG
    find (ad[i])
    do while diag->shifr == ad[i] .and. !eof()
      add_string(iif(fl, ad[i], space(6))+diag->name)
      fl := .f.
      skip
    enddo
  endif
  verify_FF(HH-3,.t.,sh)
  add_string(replicate("-",sh))
  add_string(space(5)+padl({"","Стадия","Tumor","Nodus","Metastasis"}[n],15)+space(10)+iif(n > 2, "Наименование",""))
  add_string(replicate("-",sh))
  ad[i] := left(ad[i],5)
  dbSelectArea(lal)
  find (ad[i])
  do while &poled == ad[i] .and. !eof()
    verify_FF(HH,.t.,sh)
    k := perenos(t_arr,iif(n > 2, &polen, ""),55)
    add_string(space(5)+padl(&polek,15)+t_arr[1])
    for j := 2 to k
      verify_FF(HH,.t.,sh)
      add_string(space(20)+t_arr[j])
    next
    skip
  enddo   
next
fclose(fp)
close databases
viewtext(name_file,,,,.t.,,,reg_print)
return NIL

***** 16.08.18
FUNCTION pr_sprav_N006()
Local sh := 75, HH := 60, reg_print := 2, name_file := "n006.txt", i, ad := {}
R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
R_Use(dir_exe+"_mo_N002",,"N2")
index on str(id_st,6) to tmp_n2 memory
R_Use(dir_exe+"_mo_N003",,"N3")
index on str(id_t,6) to tmp_n3 memory
R_Use(dir_exe+"_mo_N004",,"N4")
index on str(id_n,6) to tmp_n4 memory
R_Use(dir_exe+"_mo_N005",,"N5")
index on str(id_m,6) to tmp_n5 memory
R_Use(dir_exe+"_mo_N006",,"N6")
index on ds_gr to tmp_n6 unique memory
dbeval({|| aadd(ad, padr(n6->ds_gr,6)) })
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Справочник соответствия стадий TNM",sh))
add_string(center("( правильное соответствие значений идентификаторов TNM и стадии )",sh))
add_string("")
for i := 1 to len(ad)
  verify_FF(HH-2,.t.,sh)
  add_string(replicate("-",sh))
  fl := .t.
  select DIAG
  find (ad[i])
  do while diag->shifr == ad[i] .and. !eof()
    add_string(iif(fl, ad[i], space(6))+diag->name)
    fl := .f.
    skip
  enddo
  verify_FF(HH-3,.t.,sh)
  add_string(replicate("-",sh))
  add_string(space(5)+padl("Tumor",15)+padl("Nodus",15)+padl("Metastasis",15)+padl("Стадия",15))
  add_string(replicate("-",sh))
  ad[i] := left(ad[i],5)
  select N6
  set relation to str(id_st,6) into N2, to str(id_t,6) into N3, to str(id_n,6) into N4, to str(id_m,6) into N5
  index on id_gr to tmp_n6 for ds_gr == ad[i] memory
  go top
  do while !eof()
    verify_FF(HH,.t.,sh)
    add_string(space(5)+padl(n3->kod_t,15)+padl(n4->kod_n,15)+padl(n5->kod_m,15)+padl(n2->kod_st,15))
    select N6
    skip
  enddo   
next
fclose(fp)
close databases
viewtext(name_file,,,,.t.,,,reg_print)
return NIL

***** 27.09.18
FUNCTION f_blank_usl_pn()
Static arrv := {;
  {"Новорожденный",1},;
  {"1 месяц",2},;
  {"2 месяца",3},;
  {"3 месяца",4},;
  {"4 м.,5 м.,6 м.,7 м.,8 м.,9 м.,10 м.,11 м., 1 год 3 м., 1 год 6 м.",5},;
  {"1 год",13},;
  {"2 года",16},;
  {"3 года",17},;
  {"4 года,5 лет,8 лет,9 лет,11 лет, 12 лет",18},;
  {"6 лет",20},;
  {"7 лет",21},;
  {"10 лет",24},;
  {"13 лет",27},;
  {"14 лет",28},;
  {"15 лет",29},;
  {"16 лет",30},;
  {"17 лет",31};
 }
Local i, mperiod, ar, s, buf := savescreen(), ret_arr[2]
delFRfiles()
do while (mperiod := popup_2array(arrv,3,11,mperiod,1,@ret_arr,;
     "Вклыдыши услуг к л/у профилактики несовершеннолетних","B/W",color5)) > 0
  dbcreate(fr_titl,{{"name","C",130,0}})
  use (fr_titl) new alias FRT
  append blank
  frt->name := ret_arr[1]
  dbcreate(fr_data,{{"name","C",100,0}})
  use (fr_data) new alias FRD
  np_oftal_2_85_21(mperiod,0d20180901)
  ar := np_arr_1_etap[mperiod]
  if !empty(ar[5]) // не пустой массив исследований
    for i := 1 to count_pn_arr_iss
      if ascan(ar[5],np_arr_issled[i,1]) > 0
        s := np_arr_issled[i,3]
        if ascan(glob_arr_usl_LIS,np_arr_issled[i,1]) > 0
          s += "    <b><i>в МО / в КДП2</b></i>"
        endif
        if valtype(np_arr_issled[i,2]) == "C"
          s += " ("+iif(np_arr_issled[i,2]=="М","мальчики","девочки")+")"
        endif
        append blank
        frd->name := s
      endif
    next
  endif
  dbcreate(fr_data+"1",{{"name","C",100,0}})
  use (fr_data+"1") new alias FRD1
  if !empty(ar[4]) // не пустой массив осмотров
    for i := 1 to count_pn_arr_osm
      if ascan(ar[4],np_arr_osmotr[i,1]) > 0
        s := np_arr_osmotr[i,3]
        if valtype(np_arr_osmotr[i,2]) == "C"
          s += " ("+iif(np_arr_osmotr[i,2]=="М","мальчики","девочки")+")"
        endif
        append blank
        frd1->name := s
      endif
    next
  endif
  append blank
  frd1->name := "педиатр (врач общей практики)"
  dbcreate(fr_data+"2",{{"name","C",100,0}})
  use (fr_data+"2") new alias FRD2
  for i := 1 to count_pn_arr_osm
    if ascan(ar[4],np_arr_osmotr[i,1]) == 0
      s := np_arr_osmotr[i,3]
      if valtype(np_arr_osmotr[i,2]) == "C"
        s += " ("+iif(np_arr_osmotr[i,2]=="М","мальчики","девочки")+")"
      endif
      append blank
      frd2->name := s
    endif
  next
  append blank
  frd2->name := "педиатр (врач общей практики)"
  close databases
  call_fr("mo_b_pn1")
enddo
restscreen(buf)
return NIL

*****
FUNCTION ne_real()
Local c := cColorStMsg, c1 := cColorSt2Msg
n_message({"Приносим извинения.",;
           "В данный момент функция не реализована."},,c,c,,,c1 )
return NIL

***** 24.01.19 отчёт Ф-МПП
Function report_f_mpp()
Local begin_date, end_date, buf := savescreen(), arr_m, i, j, k, k1, k2, is_rebenok, is_inogoro,;
      lshifr1, koef, mvid, mour, fl_exit := .f., mkol, musl, d2_year, ar, arr_profil, ii, fl_K
if (arr_m := year_month(,,,4)) == NIL
  return NIL
elseif arr_m[1] < 2018
  return func_error(4,"Алгоритм введен с 2018 года!")
elseif !eq_any(arr_m[3],3,6,9,12)
  return func_error(4,"Последний месяц должен быть окончанием квартала.")
elseif arr_m[2] != 1  
  return func_error(4,"Первый месяц должен быть ЯНВАРЬ.")
endif
WaitStatus(arr_m[4])
dbcreate(cur_dir+"tmp1",{;
  {"usl_ok", "N", 1,0},;
  {"profil", "N", 3,0},;  // профиль в БД
  {"is_our", "N", 1,0},;  // 0-наш, 1-иногородний
  {"vz_reb", "N", 1,0},;  // 0-взрослые, 1-ребёнок
  {"vid",    "N", 1,0},;  // 1-3
  {"kol",    "N", 6,0},;  // случаев
  {"usl",    "N", 6,0},;  // услуг
  {"summa",  "N",14,2}})  // оплаченная сумма
use (cur_dir+"tmp1") new
index on str(usl_ok,1)+str(profil,3)+str(is_our,1)+str(vid,1)+str(vz_reb,1) to (cur_dir+"tmp1")
Use_base("lusl")
R_Use(dir_exe+"_mo8unit",cur_dir+"_mo8unit","MOUNIT")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to recno() into HU_, to u_kod into USL
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
//
*********************************************************************
mdate_rak := arr_m[6]+iif(arr_m[3]==12,22,10) // по какую дату РАК сумма к оплате 10.04.18
if arr_m[3] == 12 .and. glob_mo[_MO_KOD_TFOMS] == '134505'
  mdate_rak := 23
endif
*********************************************************************
R_Use(dir_server+"mo_xml",,"MO_XML")
R_Use(dir_server+"mo_rak",,"RAK")
set relation to kod_xml into MO_XML
R_Use(dir_server+"mo_raks",,"RAKS")
set relation to akt into RAK
R_Use(dir_server+"mo_raksh",,"RAKSH")
set relation to kod_raks into RAKS
index on str(kod_h,7) to (cur_dir+"tmp_raksh") for mo_xml->DFILE <= mdate_rak
//
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",,"SCHET")
set relation to recno() into SCHET_
ob_kol := 0
go top
do while !eof()
  fl := .f.
  if schet_->IS_DOPLATA==0 .and. !empty(val(schet_->smo)) .and. schet_->NREGISTR == 0 // только зарегистрированные
    @ maxrow(),0 say padr(alltrim(schet_->NSCHET)+" от "+date_8(schet_->DSCHET),27) color "W/R"
    // дата регистрации
    mdate := date_reg_schet()
    // дата отчетного периода
    mdate1 := stod(strzero(schet_->nyear,4)+strzero(schet_->nmonth,2)+"15")
    //
    *** 2018 год
    k := iif(arr_m[3]==12,21,10) // дата регистрации по 10.04.18
    if arr_m[3] == 12 .and. glob_mo[_MO_KOD_TFOMS] == '134505'
      k := 23
    endif
    ***
    fl := between(mdate,arr_m[5],arr_m[6]+k) ;
            .and. between(mdate1,arr_m[5],arr_m[6]) // !!отч.период 2018 год
  endif
  if fl
    select HUMAN
    find (str(schet->kod,6))
    do while human->schet == schet->kod .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if .t. // human_->USL_OK < 4 // кроме скорой помощи
        // по умолчанию оплачен, если даже нет РАКа
        koef := 1 ; k := 0
        select RAKSH
        find (str(human->kod,7))
        do while human->kod == raksh->kod_h .and. !eof()
          k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
          skip
        enddo
        if !empty(round(k,2))
          if empty(human->cena_1) // скорая помощь
            koef := 0
          elseif round_5(human->cena_1,2) <= round_5(k,2) // полное снятие
            koef := 0
          else // частичное снятие
            koef := (human->cena_1-k)/human->cena_1
          endif
        endif
        if koef > 0
          is_rebenok := (human->VZROS_REB > 0)
          is_inogoro := (int(val(schet_->smo)) == 34)
          fl_K := (schet_->BUKVA == "K") // отдельные медицинские услуги учитываем только суммой
          is_dializ := .f.
          is_z_sl := .f.
          d2_year := year(human->k_data)
          munit := musl := 0
          select HU
          find (str(human->kod,7))
          do while hu->kod == human->kod .and. !eof()
            lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
            if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
              lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
              if human_->USL_OK == 1 // стационар
                if left(lshifr,5) == "1.11."
                  musl += hu->kol_1
                endif
                select LUSL
                find (padr(lshifr,10))
                if found() .and. !empty(lusl->unit_code)
                  munit := lusl->unit_code
                  if !(eq_any(munit,29,141,142) .or. between(munit,207,258))
                    munit := 0
                  endif
                endif
              elseif human_->USL_OK == 2 // дневной стационар
                select LUSL
                find (padr(lshifr,10))
                if found() .and. !empty(lusl->unit_code)
                  munit := lusl->unit_code
                  if !eq_any(munit,143,259)
                    munit := 0
                  endif
                endif
              elseif human_->USL_OK == 3 // поликлиника
                select LUSL
                find (padr(lshifr,10))
                if found() .and. !empty(lusl->unit_code)
                  munit := lusl->unit_code
                  musl += hu->kol_1
                endif
              endif
            endif
            select HU
            skip
          enddo
          mvid := mkol := 1
          if human_->USL_OK == 1 // стационар
            if munit == 141 // диализ
              mkol := musl := 0
            endif
          elseif human_->USL_OK == 2 // дневной стационар
            //
          elseif human_->USL_OK == 3 // поликлиника
            if eq_any(munit,31,146)
              mvid := 2
            elseif eq_any(munit,32,147,205)
              mvid := 3
              if munit == 205 // перит.диализ
                mkol := musl := 1
              endif
            else
              if between(munit,260,262) // диспансеризация
                musl := 1 // вместо количества услуг учитываем одну услугу
              elseif eq_any(munit,30,38,145)
                // профилактика - учитываем услуги
              else
                mkol := musl := 0 // все остальные - учитываем только стоимость
              endif
            endif
          elseif human_->USL_OK == 4 // скорая помощь
            mkol := musl := 1
          endif
          mour := iif(is_inogoro, 1, 0)
          if is_rebenok
            j := 1
          else
            j := 0
          endif
          select TMP1
          find (str(human_->USL_OK,1)+str(human_->profil,3)+str(mour,1)+str(mvid,1)+str(j,1))
          if !found()
            append blank
            tmp1->usl_ok := human_->USL_OK
            tmp1->profil := human_->profil
            tmp1->is_our := mour
            tmp1->vz_reb := j
            tmp1->vid    := mvid
          endif
          tmp1->kol += mkol
          tmp1->usl += musl
          tmp1->summa += round(human->cena_1*koef,2)
        endif
      endif
      select HUMAN
      skip
    enddo
  endif
  select SCHET
  skip
enddo
if fl_exit
  func_error(4,"Процесс прерван!")
elseif tmp1->(lastrec()) == 0
  func_error(4,"Нет информации!")
else
  name_file := "_fmpp"+stxt  
  HH := 55
  arr_title := {;
"────────────────────────────────────────┬────────────────────────────────┬────────────────────────────────┬────────────────────────────────",;
"                                        │   с профилактической целью     │    по неотложной мед.помощи    │        по заболеванию          ",;
"                                        ├────────────┬────────────┬──────┼────────────┬────────────┬──────┼────────────┬────────────┬──────",;
"         Наименование профилей          │  стоимость │    в т.ч.  │посе- │  стоимость │    в т.ч.  │посе- │  стоимость │    в т.ч.  │обра- ",;
"                                        │            │  по детям  │ щений│            │  по детям  │ щений│            │  по детям  │ щений",;
"────────────────────────────────────────┼────────────┼────────────┼──────┼────────────┼────────────┼──────┼────────────┼────────────┼──────",;
"                    1                   │     9      │     10     │  11  │     12     │     13     │  14  │     15     │     16     │  17  ",;
"────────────────────────────────────────┴────────────┴────────────┴──────┴────────────┴────────────┴──────┴────────────┴────────────┴──────";
  }
  sh := len(arr_title[1])
  reg_print := 5
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string(padr(glob_mo[_MO_SHORT_NAME],sh-10)+"(в рублях)")
  add_string(center("Сведения о медицинской помощи, оказываемой по территориальной программе ОМС (Ф-МПП)",sh))
  add_string(center('по состоянию на " 1 " '+month_r(arr_m[6]+1)+str(year(arr_m[6]+1),5)+" г.",sh))
  add_string("")
  ii := 3
  select TMP1
  find (str(ii,1))
  if found()
    aeval(arr_title, {|x| add_string(x) } )
    for mour := 0 to 1
      arr_profil := {}
      find (str(ii,1))
      do while tmp1->usl_ok == ii .and. !eof()
        if tmp1->is_our == mour .and. ascan(arr_profil, {|x| x[1] == tmp1->profil }) == 0 
          aadd(arr_profil, {tmp1->profil,inieditspr(A__MENUVERT, glob_V002, tmp1->profil)}) 
        endif
        skip
      enddo
      if len(arr_profil) > 0
        if verify_FF(HH-2,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        add_string(center("поликлиника "+iif(mour==0,"(наши)","(иногородние)"),sh))
        add_string(replicate("~",sh))
        asort(arr_profil,,,{|x,y| upper(x[2]) < upper(y[2]) })
        for i := 1 to len(arr_profil)
          s := padr(arr_profil[i,2],40)
          for mvid := 1 to 3
            ss := {0,0,0}
            for j := 0 to 1
              find (str(ii,1)+str(arr_profil[i,1],3)+str(mour,1)+str(mvid,1)+str(j,1))
              if found()
                ss[1] += tmp1->summa
                if j == 1
                  ss[2] += tmp1->summa
                endif
                ss[3] += tmp1->usl
              endif
            next j
            s += put_kopE(ss[1],13)+put_kopE(ss[2],13)+put_val(ss[3],7)
          next mvid
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(s)
          add_string(replicate("─",sh))
        next i
      endif
    next
  endif
  arr_title := {;
"────────────────────────────────────────────────────────────┬─────────────────────────┬─────────────────────────",;
"                                                            │         всеего          │       в т.ч. дети       ",;
"                                                            ├────────────┬────────────┼────────────┬────────────",;
"                   Наименование профилей                    │   случаи   │   сумма    │   случаи   │   сумма    ",;
"                                                            │  лечения   │            │  лечения   │            ",;
"────────────────────────────────────────────────────────────┼────────────┼────────────┼────────────┼────────────",;
"                              1                             │     5      │     6      │     7      │      8     ",;
"────────────────────────────────────────────────────────────┴────────────┴────────────┴────────────┴────────────";
  }
  sh := len(arr_title[1])
  ii := 2
  select TMP1
  find (str(ii,1))
  if found()
    verify_FF(HH-10,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
    for mour := 0 to 1
      arr_profil := {}
      find (str(ii,1))
      do while tmp1->usl_ok == ii .and. !eof()
        if tmp1->is_our == mour .and. ascan(arr_profil, {|x| x[1] == tmp1->profil }) == 0 
          aadd(arr_profil, {tmp1->profil,inieditspr(A__MENUVERT, glob_V002, tmp1->profil)}) 
        endif
        skip
      enddo
      if len(arr_profil) > 0
        if verify_FF(HH-2,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        add_string(center("дневной стационар "+iif(mour==0,"(наши)","(иногородние)"),sh))
        add_string(replicate("~",sh))
        asort(arr_profil,,,{|x,y| upper(x[2]) < upper(y[2]) })
        for i := 1 to len(arr_profil)
          s := padr(arr_profil[i,2],60)
          for mvid := 1 to 1
            ss := {0,0,0,0}
            for j := 0 to 1
              find (str(ii,1)+str(arr_profil[i,1],3)+str(mour,1)+str(mvid,1)+str(j,1))
              if found()
                ss[1] += tmp1->kol
                ss[2] += tmp1->summa
                if j == 1
                  ss[3] += tmp1->kol
                  ss[4] += tmp1->summa
                endif
              endif
            next j
            s += put_val(ss[1],10)+put_kopE(ss[2],16)+;
                 put_val(ss[3],10)+put_kopE(ss[4],16)
          next mvid
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(s)
          add_string(replicate("─",sh))
        next i
      endif
    next
  endif
  arr_title := {;
"────────────────────────────────────────────────────────────┬──────────────────────────┬──────────────────────────",;
"                                                            │           всего          │      в т.ч. дети         ",;
"                                                            ├──────┬──────┬────────────┼──────┬──────┬────────────",;
"                   Наименование профилей                    │случаи│койко-│   сумма    │случаи│койко-│   сумма    ",;
"                                                            │      │ дни  │            │      │ дни  │            ",;
"────────────────────────────────────────────────────────────┼──────┼──────┼────────────┼──────┼──────┼────────────",;
"                              1                             │  5   │  6   │     7      │  8   │  9   │     10     ",;
"────────────────────────────────────────────────────────────┴──────┴──────┴────────────┴──────┴──────┴────────────";
  }
  sh := len(arr_title[1])
  ii := 1
  select TMP1
  find (str(ii,1))
  if found()
    verify_FF(HH-10,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
    for mour := 0 to 1
      arr_profil := {}
      find (str(ii,1))
      do while tmp1->usl_ok == ii .and. !eof()
        if tmp1->is_our == mour .and. ascan(arr_profil, {|x| x[1] == tmp1->profil }) == 0 
          aadd(arr_profil, {tmp1->profil,inieditspr(A__MENUVERT, glob_V002, tmp1->profil)}) 
        endif
        skip
      enddo
      if len(arr_profil) > 0
        if verify_FF(HH-2,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        add_string(center("стационар "+iif(mour==0,"(наши)","(иногородние)"),sh))
        add_string(replicate("~",sh))
        asort(arr_profil,,,{|x,y| upper(x[2]) < upper(y[2]) })
        for i := 1 to len(arr_profil)
          s := padr(arr_profil[i,2],60)
          for mvid := 1 to 1
            ss := {0,0,0,0,0,0}
            for j := 0 to 1
              find (str(ii,1)+str(arr_profil[i,1],3)+str(mour,1)+str(mvid,1)+str(j,1))
              if found()
                ss[1] += tmp1->kol
                ss[2] += tmp1->usl
                ss[3] += tmp1->summa
                if j == 1
                  ss[4] += tmp1->kol
                  ss[5] += tmp1->usl
                  ss[6] += tmp1->summa
                endif
              endif
            next j
            s += put_val(ss[1],7)+put_val(ss[2],7)+put_kopE(ss[3],13)+;
                 put_val(ss[4],7)+put_val(ss[5],7)+put_kopE(ss[6],13)
          next mvid
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(s)
          add_string(replicate("─",sh))
        next i
      endif
    next
  endif
  ii := 4
  select TMP1
  find (str(ii,1))
  if found()
    verify_FF(HH,.t.,sh)
    ss := array(2,2)
    afillall(ss,0)
    for mour := 0 to 1
      arr_profil := {}
      find (str(ii,1))
      do while tmp1->usl_ok == ii .and. !eof()
        if tmp1->is_our == mour
          ss[mour+1,1] += tmp1->kol 
          ss[mour+1,2] += tmp1->summa 
        endif
        skip
      enddo
    next
    add_string("скорая помощь (наши)       "+put_val(ss[1,1],6)+" чел."+put_kopE(ss[1,2],12)+" руб.")
    add_string("скорая помощь (иногородние)"+put_val(ss[2,1],6)+" чел."+put_kopE(ss[2,2],12)+" руб.")
  endif
  fclose(fp)
  close databases
  restscreen(buf)
  Private yes_albom := .t.
  viewtext(name_file,,,,.t.,,,reg_print)
endif  
close databases
restscreen(buf)
return NIL
