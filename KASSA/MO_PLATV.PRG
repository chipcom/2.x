// mo_platv.prg
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// вернуть тип услуги (тип больного)
Function f_p_tip_usl(r,c)
Static sk := PU_PLAT
Local out_arr
DEFAULT r TO T_ROW, c TO T_COL+5
popup_2array(menu_kb,r,c,sk,1,@out_arr)
if out_arr != NIL
  sk := out_arr[2]
endif
return out_arr

// вернуть тип услуги (bit-овый вариант)
Function fbp_tip_usl(r,c,ret_arr)
Static sast := {.t.,.f.,.f.}
Local i, j, a, out_arr
DEFAULT r TO T_ROW, c TO T_COL+5
if (a := bit_popup(r,c,menu_kb,sast)) != NIL
  out_arr := {} ; afill(sast,.f.)
  for i := 1 to len(a)
    aadd(out_arr,a[i,2])
    if (j := ascan(menu_kb,{|x| x[2]==a[i,2] })) > 0
      sast[j] := .t.
    endif
  next
  if len(a) == 1
    if a[1,2] == PU_D_SMO  // добр.страхование
      ret_arr := ret_arr_dms(r,c)
    elseif a[1,2] == PU_PR_VZ  // взаимозачет
      ret_arr := ret_arr_vz(r,c)
    endif
  endif
endif
return out_arr



//
Function tit_tip_usl(k,a_dms,sh)
Local i, s := "[ "
if len(k) < 3
  for i := 1 to len(k)
    s += alltrim(inieditspr(A__MENUVERT, menu_kb, k[i]))+", "
  next
  s := substr(s,1,len(s)-2)+" ]"
  add_string(center(s,sh))
  if len(k) == 1 .and. valtype(a_dms) == "A"
    if k[1] == PU_D_SMO  // добр.страхование
      if len(a_dms) == 1
        add_string(center("ДСМО: "+alltrim(inieditspr(A__POPUPMENU,dir_server+"p_d_smo",a_dms[1])),sh))
      endif
    elseif k[1] == PU_PR_VZ  // взаимозачет
      if len(a_dms) == 1
        add_string(center("Предприятие: "+alltrim(inieditspr(A__POPUPMENU,dir_server+"p_pr_vz",a_dms[1])),sh))
      endif
    endif
  endif
endif
return NIL



//
Function ret_arr_dms(r1,c1)
Static sa
Local r2, c2, nr := 0, arr := {}, t_mas := {}, buf, buf1, i, ret
DEFAULT r1 TO T_ROW, c1 TO T_COL+5
G_Use(dir_server+"p_d_smo",,"MM")
dbeval({|| ++nr, aadd(arr, {mm->(recno()), mm->name} ) } )
Use
if nr == 0
  func_error(4,"База данных ДСМО пуста!")
  return NIL
endif
asort(arr,,,{|x,y| upper(x[2]) < upper(y[2])})
aeval(arr, {|x| aadd(t_mas,x[2]) } )
r2 := r1 + nr + 1
c2 := c1 + 33 + 1
if c2 > 77
  c2 := 77 ; c1 := 76 - 33
endif
if r2 > maxrow()-2 ; r2 := maxrow()-2 ; endif
if r2 == maxrow()-2
  r1 := r2 - nr - 1
  if r1 < 2 ; r1 := 2 ; endif
endif
buf := save_box(r1,c1,r2+1,c2+2)
buf1 := save_row(maxrow())
aeval(t_mas, {|x,i,fl| fl := iif(sa==NIL, .t., ascan(sa,arr[i,1]) > 0),;
                       t_mas[i] := iif(fl," * ","   ")+t_mas[i] } )
status_key("^<Esc>^-отказ; ^<Enter>^-выбор; ^<Ins,+,->^-смена признака печати данной ДСМО")
if popup(r1,c1,r2,c2,t_mas,,color0,.t.,"fmenu_reader") > 0
  ret := {}
  FOR i := 1 TO nr
    IF "*" $ left(t_mas[i],3)
      aadd(ret,arr[i,1])
    ENDIF
  NEXT
  if empty(ret)
    ret := NIL
  endif
  sa := ret
endif
rest_box(buf)
rest_box(buf1)
return ret



//
Function ret_arr_vz(r1,c1)
Static sa
Local r2, c2, nr := 0, arr := {}, t_mas := {}, buf, buf1, i, ret
DEFAULT r1 TO T_ROW, c1 TO T_COL+5
G_Use(dir_server+"p_pr_vz",,"MM")
dbeval({|| ++nr, aadd(arr, {mm->(recno()), mm->name} ) } )
Use
if nr == 0
  func_error(4,"База данных предприятий пуста!")
  return NIL
endif
asort(arr,,,{|x,y| upper(x[2]) < upper(y[2])})
aeval(arr, {|x| aadd(t_mas,x[2]) } )
r2 := r1 + nr + 1
c2 := c1 + 33 + 1
if c2 > 77
  c2 := 77 ; c1 := 76 - 33
endif
if r2 > maxrow()-2 ; r2 := maxrow()-2 ; endif
if r2 == maxrow()-2
  r1 := r2 - nr - 1
  if r1 < 2 ; r1 := 2 ; endif
endif
buf := save_box(r1,c1,r2+1,c2+2)
buf1 := save_row(maxrow())
aeval(t_mas, {|x,i,fl| fl := iif(sa==NIL, .t., ascan(sa,arr[i,1]) > 0),;
                       t_mas[i] := iif(fl," * ","   ")+t_mas[i] } )
status_key("^<Esc>^-отказ; ^<Enter>^-выбор; ^<Ins,+,->^-смена признака печати данного предприятия")
if popup(r1,c1,r2,c2,t_mas,,color0,.t.,"fmenu_reader") > 0
  ret := {}
  FOR i := 1 TO nr
    IF "*" $ left(t_mas[i],3)
      aadd(ret,arr[i,1])
    ENDIF
  NEXT
  if empty(ret)
    ret := NIL
  endif
  sa := ret
endif
rest_box(buf)
rest_box(buf1)
return ret



// 02.07.18
Function kart_plat()
Local buf, str_sem
if polikl1_kart() > 0
  if glob_kassa == 1 .and. mek_kassa == 1 //.and. mek_nkassa == 1
    Private drvFR
    IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
      FR_ZAMENA_otrezka()
    else
      return func_error(4,"Ошибка запуска драйвера КАССЫ")
    endif
  endif
  //
  str_sem := "ПУ Редактирование человека "+lstr(glob_kartotek)
  if !G_SLock(str_sem)
    return func_error(4,err_slock)
  endif
  buf := savescreen()
  Private fl_found, str_find, muslovie
  str_find := str(glob_kartotek,7)
  muslovie := "human->kod_k == glob_kartotek"
  R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
  use_base("hum_p","HUMAN")
  find (str_find)
  fl_found := found()
  arr_blk := {{| | FindFirst(str_find)},;
              {| | FindLast(str_find,-1)},;
              {|n| SkipPointer(n, muslovie)},;
              str_find,muslovie;
             }
  if !fl_found ; keyboard chr(K_INS) ; endif
  mtitle := "Платные услуги: "+glob_k_fio
  Alpha_Browse(T_ROW,0,maxrow()-2,79,"f2_k_plat",color0,mtitle,"BG+/GR",;
               .f.,.t.,arr_blk,,"f3_k_plat",,;
               {"═","░","═","N/BG,W+/N,B/BG,BG+/B,R/BG,GR+/R",.t.,180} )
  close databases
  restscreen(buf)
  G_SUnLock(str_sem)
endif
return NIL



// 08.10.17
Function f2_k_plat(oBrow)
Local oColumn, s, blk := {|| iif(human->is_kas==2, {5,6}, iif(human->cena > 0, {1,2}, {3,4})) }
Local tip_bank := {"бн","МИ","VI","MC","БАНК"}

if glob_kassa == 1 .and. mek_kassa == 1 // в кассе 01.12.2008
  //oColumn := TBColumnNew("  ",{|| iif(human->sbank < 1, "    ",iif(human->sbank == human->cena, "б/н ","б/нН")) })
  oColumn := TBColumnNew("    ",;
    {|| iif(human->sbank < 1, "    ",;
                              tip_bank[human->fr_tipkart+1]+iif(human->sbank==human->cena," ","Н")) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("    ",;
    {|| iif(human->tip_usl==PU_PLAT, {"    ",str(human->kv_cia,4)," "}[human->is_kas+1], ;
                                     iif(human->tip_usl==PU_PR_VZ, "в/з ","ДМС ")) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
elseif glob_kassa == 1 .and. mek_kassa == 2 // с ФР но не в КАССЕ 01.12.2008
  oColumn := TBColumnNew("№ кв.;книжки",{|| put_val(human->n_kvit,5) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("    ",;
    {|| iif(human->tip_usl==PU_PLAT, {"    ",str(human->kv_cia,4)," "}[human->is_kas+1], ;
                                     iif(human->tip_usl==PU_PR_VZ, "в/з ","ДМС ")) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
elseif glob_pl_reg == 1
  oColumn := TBColumnNew("№ кв.;книжки",{|| put_val(human->n_kvit,5) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  //
  oColumn := TBColumnNew("№ кви-;танции",{|| put_val(human->kv_cia,6) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  //
  oColumn := TBColumnNew("  Дата; оплаты",{|| date_8(c4tod(human->pdate)) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
endif
//
oColumn := TBColumnNew(" Начало; лечения", {|| date_8(human->n_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Окончан.; лечения", {|| date_8(human->k_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
if mem_naprvr == 2
  oColumn := TBColumnNew("Напр.;врач",{|| put_val(ret_tabn(human->kod_vr),5) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
endif
//
oColumn := TBColumnNew("Стоимость; лечения", {|| put_kop(human->cena,10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
if glob_kassa == 1
  oColumn := TBColumnNew("  Возврат;  денег",{|| put_kop(human->sum_voz,10) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
else
  oColumn := TBColumnNew(" ",{|| iif(human->tip_usl==PU_D_SMO,'д',iif(human->tip_usl==PU_PR_VZ,'з',' ')) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
endif
//
oColumn := TBColumnNew("  Дата;закрытия", {|| date_8(human->date_close) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if is_task(X_KASSA)
  @ maxrow()-1,0 say padc("<Esc>выход <Enter>редактирование <Ins>добавление <Del>удаление <F8>возврат",80) color "N/W"
  s := "<Ctrl+Enter>ввод услуг <F9>договор <F3>квитанции <F4>просмотр чеков <F10>печать чека"
else
  @ maxrow()-1,0 say padc("<Esc> выход <Enter> редактирование <Ins> добавление <Del> удаление",80) color "N/W"
  s := "<Ctrl+Enter> ввод услуг <F8> возврат <F9> договор <F10> печать чека"
endif
@ maxrow(),0 say padc(s,80) color "N/W"
mark_keys({"<Esc>","<Enter>","<Ins>","<Del>","<Ctrl+Enter>","<F3>","<F4>","<F8>","<F9>","<F10>"},"R/W")
return NIL

// 20.10.23
Function f3_k_plat(nKey,oBrow)
LOCAL j := 0, flag := -1, buf := save_row(maxrow()), buf1, fl := .f., rec, mkod,;
      tmp_color := setcolor(), r1 := 15, c1 := 2, v_summa, v_sdacha, adbf, s,;
      ln_chek := 0, t_hum_rec := 0, kart_kod, t_k_data, lnds, fr_zavodnomer := "",;
      mi_post, mphone_m, maddress, tip_kart := 2, mkod_kem_vid,;
      err_close := "Лист учета ЗАКРЫТ. Доступ разрешён только администратору системы!"
Private ldate_voz, lsum_voz, lfr_data, lfr_time
do case
  case nKey == K_F3
    view_p_kvit(K_F3)
  case nKey == K_F4 .and. is_task(X_KASSA)
    view_p_kvit(K_F4)
  case nKey == K_F8 .and. glob_kassa == 1 .and. human->is_kas == 1 .and.;
                   human->kod_k > 0 .and. ver_pub_date(human->k_data,.t.) .and.;
                   human->cena > 0
    if !empty(human->date_close) .and. !hb_user_curUser:IsAdmin()
      func_error(4,err_close)
      return flag
    endif
    rec := human->(recno())
    vozvrat_platn(rec)
    select PERSO
    select HUMAN
    goto (rec)
    setcolor(tmp_color)
    rest_box(buf) ; flag := 0
  case nKey == K_F10 .and. glob_kassa == 1 .and. human->is_kas == 2 .and. human->cena > 0
    buf := savescreen()
    // убрал спецдобавку для КСП3
    ClrLine(maxrow()-1,color0)
    // поиск номера или эл.почты
    t_hum_rec := human->(recno())
    kart_kod  := human->kod_k
    mi_post   := space(30)
    mphone_m  := space(11)
    select HUMAN
    do while human->kod_k == kart_kod  .and. !eof()
      if len(alltrim(human->i_post)) > 4
        mi_post := human->i_post
      endif
      skip
    enddo
    goto (t_hum_rec)
    // поиск телефона
    R_Use(dir_server+"kartote_",,"KR_")
    goto(human->kod_k)
    mphone_m := kr_->phone_m
    kr_->(dbCloseArea())
    mphone_m := TransformPhone( mphone_m )
    //выбираем приоритетом телефон
    if len(alltrim(mphone_m)) < 11
      maddress := mi_post
    else
      maddress := mphone_m
    endif
    //
    R_Use(dir_server+"uslugi",,"USL")
    R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
    set relation to u_kod into USL
    find (str(human->(recno()),7))
    // сразу сортируем по шифру услуг
    index on fsort_usl(usl->shifr) to (cur_dir+"tmp") while hu->kod == human->(recno())
    adbf := {{"name", "C",128,0},;
             {"vrach","C", 50,0},;
             {"cena", "N", 10,2},;
             {"kol",  "N",  4,0},;
             {"nds20","N",  1,0},;
             {"nds18","N",  1,0},;
             {"nds10","N",  1,0}}
    dbcreate(cur_dir+"tmp",adbf)
    use (cur_dir+"tmp") new
    adbf := {}
    select HU
    go top
    do while !eof()
      if hu->kod_vr > 0 .and. ascan(adbf,hu->kod_vr) == 0
        aadd(adbf,hu->kod_vr)  // массив врачей
      endif
      skip
    enddo
    fl := .t.
    select HU
    go top
    do while !eof()
      if !empty(round_5(hu->stoim,2))
        select TMP
        append blank
        if glob_mo[_MO_KOD_TFOMS] == '171004' // КБ-4
          tmp->name := alltrim(usl->name)+" "+alltrim(usl->full_name)
        else 
          if mek_kod_usl > 1 
            if len(alltrim(usl->full_name)) > 3
              tmp->name := alltrim(usl->full_name)
            else
              tmp->name := alltrim(usl->name)
            endif
          else  
            if len(alltrim(usl->full_name)) > 3
               tmp->name := alltrim(usl->shifr)+" "+alltrim(usl->full_name)
            else
               tmp->name := alltrim(usl->shifr)+" "+alltrim(usl->name)
            endif
          endif  
        endif
        if hu->kod_vr > 0 .and. fl
          perso->(dbGoto(hu->kod_vr))
          tmp->vrach := fam_i_o(perso->fio)+" <"+lstr(perso->tab_nom)+">"
          if len(adbf) == 1  // если врач один,
            fl := .f.        // то печатаем его только в 1-ой услуге
          endif
        endif
        tmp->cena := round_5(hu->stoim / hu->kol, 2)
        tmp->kol := hu->kol
        // НДС
        if round(tmp->cena,2) == round(usl->pcena_d,2) // дети
          lnds := round_5(usl->pnds_d,0)
        else // взрослые
          lnds := round_5(usl->pnds,0)
        endif
        if lnds == 18
          tmp->nds18 := 1
        elseif lnds == 10
          tmp->nds10 := 1
        elseif lnds == 20
          tmp->nds20 := 1
        endif
      endif
      select HU
      skip
    enddo
    hu->(dbCloseArea())
    usl->(dbCloseArea())
    Private p_summa := round_5(human->cena,2), fl_sdacha := .f.,;
            mplat_fio := human->plat_fio, mplat_inn := human->plat_inn
    v_summa := v_sdacha := v_bank := 0
    if yes_chek(@v_summa,@v_sdacha,@v_bank,,@maddress,@tip_kart) .and.;
       chek_fr(v_summa,v_sdacha,@ln_chek,v_bank,,@fr_zavodnomer,maddress,tip_kart)
      select HUMAN
      G_RLock(forever)
      human->is_kas  := 1
      human->kv_cia  := ln_chek
      human->sbank   := v_bank
      human->fr_data := lfr_data
      human->fr_time := lfr_time
      human->pdate   := lfr_data
      human->KOD_OPER:= asc(kod_polzovat)
      human->FR_zavod:= fr_zavodnomer
      human->FR_tipkart := tip_kart
      human->fr_tip     := 2
      human->i_post     :=  maddress
      UnLock
      human->(dbCommit())
      flag := 0
    endif
    tmp->(dbCloseArea())
    select HUMAN
    restscreen(buf)
  case nKey == K_F9 //.and. human->cena > 0
    // печать договора
    Private pac_FIO, pac_adres, pac_data, dog_data, pac_kod, pac_1FIO, pac_kvit, phone_m
    Private m1vid_ud, mnom, MSER, MVID_UD, mregistrator := alltrim(fio_polzovat)
    Private mplat_fio := human->plat_fio, mplat_inn := human->plat_inn, nom_prihod := 0
    Private mplat_adres  := space(50),; // адрес плательщика
            mplat_pasport := space(15),;  // документ плательщика
            mplat_data_ud := date(), mplat_vidan_ud := " "   
    Private lnomer, l1nomer, muchastok
    Private okato_adresr, okato_adresg
    Private mdov_date, mdov_nomer, mdov_dolgn   //
    Private mmesto_r,;       // место рождения
            m,;      // документ выдан
            mdata_vidan_ud   // дата выдачи удостоверения
    buf := savescreen()
    ClrLine(23,color0)
    mdov_date  := oper_dov_date  
    mdov_nomer := oper_dov_nomer
    mdov_dolgn := dolj_polzovat
    t_hum_rec := human->(recno())
    kart_kod := human->kod_k
    t_k_data := year(human->k_data)
    select HUMAN
    do while human->kod_k == kart_kod .and. year(human->k_data) == t_k_data .and. !eof()
      ++nom_prihod
      skip
    enddo
    goto (t_hum_rec)
    pac_kvit := human->kv_cia
    R_Use(dir_server+"kartotek",,"KR")
    goto (human->kod_k)
    lnomer := l1nomer := lstr(kr->kod)
    muchastok := put_val(kr->uchast,2)
    luchast := ""
    if is_uchastok == 1
      if !emptyall(kr->bukva,kr->uchast,kr->kod_vu)
        lnomer := ""
        if !empty(kr->bukva)
          lnomer += kr->bukva
        endif
        lnomer += lstr(kr->uchast,2)
        if kr->kod_vu > 0
          lnomer += "/"+lstr(kr->kod_vu)
        endif
        l1nomer := lnomer
      endif
    elseif eq_any(is_uchastok,2,3)
      if !emptyall(kr->bukva,kr->uchast)
        luchast := " [уч-к "
        if !empty(kr->bukva)
          luchast += kr->bukva
        endif
        luchast += lstr(kr->uchast,2)
        luchast += "] "
      endif
      if is_uchastok == 3
        R_Use(dir_server+"kartote2",,"KART2")
        if human->kod_k <= lastrec()
          goto (human->kod_k)
          luchast += alltrim(kart2->kod_AK)
        endif
        kart2->(dbCloseArea())
      endif
    endif
    lnomer := expand(lnomer)+luchast
    pac_fio   := fam_i_o(kr->fio)
    pac_1fio  := alltrim(kr->fio)
    pac_adres := alltrim(kr->adres)
    pac_data  := full_date(kr->date_r)
    pac_kod   := lstr(kr->kod)
    kr->(dbCloseArea())
    R_Use(dir_server+"kartote_",,"KR_")
    goto (human->kod_k)
    okato_adresg := ret_okato_ulica("",kr_->okatog,1,2)
    okato_adresr := ret_okato_ulica("",kr_->okatop,1,2)
    m1vid_ud := kr_->vid_ud
    mnom     := kr_->nom_ud
    mser     := kr_->ser_ud
    mmesto_r := kr_->mesto_r
    mphone_m := kr_->phone_m
    mkod_kem_vid := kr_->kemvyd
    mdata_vidan_ud := kr_->kogdavyd 
    kr_->(dbCloseArea())
    phone_m := TransformPhone( mphone_m)
    mvid_ud := get_Name_Vid_Ud(m1vid_ud)
    //
    if mkod_kem_vid > 0
      R_Use(dir_server+"s_kemvyd",,"VYD")
      goto (mkod_kem_vid)
      mvidan_ud := vyd->name
      vyd->(dbCloseArea())
    endif  
    dog_data := human->n_data
    R_Use(dir_server+"hum_plat",dir_server+"hum_plat","KPLAT")
    find (str(human->(recno()),7))
    if found()
      mplat_adres   := KPLAT->ADRES
      mplat_pasport := KPLAT->PASPORT
      mplat_data_ud := KPLAT->kogdavyd
      if KPLAT->kemvyd > 0
        R_Use(dir_server+"s_kemvyd",,"VYD")
        goto (KPLAT->kemvyd)
        mplat_vidan_ud := vyd->name
        vyd->(dbCloseArea())
      endif  
    endif
    KPLAT->(dbCloseArea())
    //
    Use_base("humanst",,,.T.) // только для чтения
    R_Use(dir_server+"uslugi",,"USL")
    R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
    set relation to u_kod into USL
    find (str(human->(recno()),7))
    // сразу сортируем по шифру услуг
    index on fsort_usl(usl->shifr) to (cur_dir+"tmp") while hu->kod == human->(recno())
    adbf := {{"name",      "C", 65, 0},; // наименование услуги
             {"shifr",     "C", 10, 0},; // шифр услуги
             {"cena",      "N", 10, 2},;
             {"kol",       "N",  4, 0},;
             {"kod_vr",    "N",  4, 0},;
             {"full_name", "C",255, 0},;
             {"vrach",     "C", 50, 0},;
             {"nds20",     "N",  1, 0},;
             {"nds18",     "N",  1, 0},;
             {"nds10",     "N",  1, 0},;
             {"kod_diag",  "C",  6, 0},; 
             {"zf",        "C",  20,0} }
    dbcreate(cur_dir+"tmp",adbf)
    use (cur_dir+"tmp") new
    select HU
    go top
    do while !eof()
      select TMP
      append blank
      tmp->name      := alltrim(usl->name)
      tmp->full_name := iif(len(alltrim(usl->full_name)) < 2, alltrim(usl->name),;
                                                              alltrim(usl->full_name))
      tmp->shifr     := alltrim(usl->shifr)
      tmp->cena      := round_5(hu->stoim / hu->kol, 2)
      tmp->kol       := hu->kol
      tmp->kod_vr    := hu->kod_vr
      if hu->kod_vr > 0
        perso->(dbGoto(hu->kod_vr))
        tmp->vrach := fam_i_o(perso->fio)+" <"+lstr(perso->tab_nom)+">"
      endif
      // НДС
      if round(tmp->cena,2) == round(usl->pcena_d,2) // дети
        lnds := round_5(usl->pnds_d,0)
      else // взрослые
        lnds := round_5(usl->pnds,0)
      endif
      if lnds == 18
        tmp->nds18 := 1
      elseif lnds == 10
        tmp->nds10 := 1
      elseif lnds == 20
        tmp->nds20 := 1
      endif
      // зубная формула
      select HUMANST
      find (str(2,1)+str(hu->(recno()),8))
      if found()
        tmp->KOD_DIAG  := humanst->KOD_DIAG
        tmp->ZF        := humanst->ZF
      endif
      select HU
      skip
    enddo
    usl->(dbCloseArea())
    hu->(dbCloseArea())
    HUMANST->(dbCloseArea())
    select TMP
    index on fsort_usl(shifr) to (cur_dir+"tmp")
    Private p_summa := round_5(human->cena,2)
    rec := human->(recno()) ; c1 := human->lpu
    if len(alltrim(mem_dogovor)) > 3
      print_shablon(alltrim(mem_dogovor))
    else
      Private file_sh
      if !empty(alltrim(mem_dogovor)) .and. ;
         !empty(file_sh := menu_shablon(3,3,dir_exe+"*."+upper(alltrim(mem_dogovor)),color8,.f.))
        select TMP
        go top
        f1_pr_shab(file_sh)
      endif
    endif
    close databases
    //
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
    use_base("hum_p","HUMAN")
    goto (rec)
    setcolor(tmp_color)
    flag := 0
    restscreen(buf)
  case nKey == K_INS .or. (nKey == K_ENTER .and. human->kod_k > 0)
    if nKey == K_ENTER .and. !empty(human->date_close) .and. !hb_user_curUser:IsAdmin()
      func_error(4,err_close)
      return flag
    endif
    if nKey == K_INS .and. !fl_found
      colorwin(7,0,7,79,"N/N","W+/N")
      colorwin(7,0,7,79,"N/N","BG+/B")
      colorwin(7,0,7,79,"N/N","GR+/R")
    endif
    rec := recno()
    flag := f_p_kart(nKey)
  case nKey == K_DEL .and. human->is_kas != 1 .and. ;
                             human->kod_k > 0 .and. ver_pub_date(human->k_data,.t.)
    if !empty(human->date_close) .and. !hb_user_curUser:IsAdmin()
      func_error(4,err_close)
    elseif f_Esc_Enter(2,.t.)
      mywait()
      G_Use(dir_server+"hum_p_u",{dir_server+"hum_p_u",;
                                  dir_server+"hum_p_uk",;
                                  dir_server+"hum_p_ud",;
                                  dir_server+"hum_p_uv",;
                                  dir_server+"hum_p_ua"},"HU")
      j := 0
      do while .t.
        select HU
        find (str(human->(recno()),7))
        if !found() ; exit ; endif
        DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
        ++j
      enddo
      hu->(dbCloseArea())
      write_work_oper(glob_task,OPER_USL,3,j)
      write_work_oper(glob_task,OPER_LIST,3)
      select HUMAN
      DeleteRec(.t.)
      Commit
      oBrow:goTop()
      find (str_find)
      if !found()
        fl_found := .f.
      endif
      stat_msg("Лист учета удален!") ; mybell(1,OK)
      flag := 0
      if !fl_found
        flag := 1
      endif
      rest_box(buf)
    endif
  case human->is_kas == 1 .and. nKey == K_DEL .and. human->kod_k > 0 .and. human->cena > 0
    if !empty(human->date_close) .and. !hb_user_curUser:IsAdmin()
      func_error(4,err_close)
    elseif human->sum_voz > 0
      func_error(4,"По данному листу учета уже производился возврат денег!")
    else
      ldate_voz := sys_date
      lsum_voz := human->CENA - human->sbank
      s := " \"+;
        "      Общая стоимость услуг = "+lput_kop(human->CENA,.t.)+" руб.\"+;
        "      Введите дату  возврата  @           \"+;
        "      Введите сумму возврата  @           \"+;
        " \"
      DisplBox(s,;
        , ;                   // цвет окна (умолч. - cDataCGet)
        {"ldate_voz","lsum_voz"},; // массив Private-переменных для редактирования
        {,pict_cena},; // массив Picture для редактирования
        17)
      if lastkey() == K_ESC
        //
      elseif round(lsum_voz,2) <= 0
        mybell()
      elseif lsum_voz > human->CENA - human->sbank
        //func_error(4,"Сумма возврата больше стоимости услуг!")
        func_error(4,"Возврат чека проводите по клавише <F8> !")
      elseif mek_kassa == 1
        //.and. f_Esc_Enter("возврата "+lput_kop(lsum_voz,.t.)+" руб.") .and. vozv_fr(lsum_voz)
        //select HUMAN
        //G_RLock(forever)
        //replace human->date_voz with dtoc4(ldate_voz), human->sum_voz with lsum_voz
        //UnLock
        //human->(dbCommit())
        //stat_msg("Сумма возврата записана!") ; mybell(1,OK)
        //flag := 0
        //rest_box(buf)
        func_error(4,"Возврат чека проводите по клавише <F8> !")
      elseif hb_user_curUser:IsAdmin() .and. mek_kassa == 2 .and. ;
             involved_password(1,1,"возврата "+lput_kop(lsum_voz,.t.)+" руб.") .and. ;
             f_Esc_Enter("возврата "+lput_kop(lsum_voz,.t.)+" руб.")
        select HUMAN
        G_RLock(forever)
        replace human->date_voz with dtoc4(ldate_voz), human->sum_voz with lsum_voz
        UnLock
        human->(dbCommit())
        stat_msg("Сумма возврата записана!") ; mybell(1,OK)
        flag := 0
        rest_box(buf)
      endif
    endif
  case nKey == K_CTRL_RET .and. human->kod_k > 0
    if !empty(human->date_close) .and. !hb_user_curUser:IsAdmin()
      func_error(4,err_close)
      return flag
    endif
    rec := human->(recno()) ; c1 := human->lpu
    close databases
    usl_p_kart(rec,c1)
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
    use_base("hum_p","HUMAN")
    goto (rec)
    setcolor(tmp_color)
    rest_box(buf) ; flag := 0
  otherwise
    keyboard ""
endcase
return flag

//
Function ret_zapros3000()
Local buf, r1 := 12, r2 := 18, i, tmp_color := setcolor(color1)
buf := box_shadow(r1,10,r2,69,,"РАБОТА со СКИДОЧНЫМИ картами","W/R+")
setcolor(color8)
str_center(r1+2,"Внимание !")
str_center(r1+3,"Плательщик имеет СКИДОЧНУЮ КАРТУ ?")
setcolor(color1)
str_center(r2-2,"Выберите действие:")
setmtcolor("BG+/B,W+/R,GR+/B,GR+/R")
@ r2-1,24 prompt " ~Карты НЕТ "
@ r2-1,44 prompt " ~СКИДКА 1000р "
menu to i
setcolor(tmp_color)
rest_box(buf)
return (i == 2)

//
Function ret_soob_3000(tip, sum_1, sum_2)
Local buf, r1 := 12, r2 := 18, i, tmp_color := setcolor(color1)
if tip == 1
  buf := box_shadow(r1,10,r2,69,,"РАБОТА со СКИДОЧНЫМИ картами","W/R+")
  setcolor(color8)
  str_center(r1+2,"Внимание !")
  //str_center(r1+3,"Сумма ДО скидки    :"+put_kop(sum_1))
  str_center(r1+3,"Сумма ПОСЛЕ скидки :"+put_kop(sum_1-sum_2,8))
  str_center(r1+4,"Сумма СКИДКИ :"+put_kop(sum_2,8))
  setcolor(color1)
  setmtcolor("BG+/B,W+/R,GR+/B,GR+/R")
  @ r2-1,37 prompt " ~ОК "
  menu to i
  setcolor(tmp_color)
  rest_box(buf)
else
  buf := savescreen()
  f_message({"Внимание !",;
           "",;
           "Сумма cкидки ВЕЛИКА :"+put_kop(sum_2,8),;
           "Скидка отменена Проведите скидку вручную !"},,"GR+/R","W+/R",13)
  inkey(0)
  restscreen(buf)
endif
return NIL


//
Function view_p_kvit(nkey)
Local sh := 80, HH := 57, reg_print := 2, buf := save_row(maxrow()), i, ;
      name_file := "tmp"+stxt, j := 0, tmp_select := select(), arr_lpu := {}, ;
      rec := human->(recno())
mywait()
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center(iif(nKey==K_F3,"Оплаченные услуги","Список чеков"),sh))
add_string(center(glob_k_fio,sh))
R_Use(dir_server+"uslugi",,"USL")
if nKey == K_F3
  R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
  set relation to u_kod into USL
  select HUMAN
  find (str_find)
  do while &muslovie
    ++j
    add_string("")
    add_string(lstr(j)+".")
    add_string("Квитанционная книжка №:  "+lstr(human->n_kvit)+;
               ",  квитанция №:  "+lstr(human->kv_cia)+;
               ",  дата оплаты:  "+date_8(c4tod(human->pdate)))
    select HU
    find (str(human->(recno()),7))
    do while hu->kod == human->(recno())
      s := space(10)+"Шифр услуги:  "+usl->shifr+",  "+;
                     "кол-во услуг:"+str(hu->kol,4)
      if hu->kod_vr > 0
        s += ",  код врача:  "+lstr(ret_tabn(hu->kod_vr))
      endif
      add_string(s)
      skip
    enddo
    select HUMAN
    skip
  enddo
  hu->(dbCloseArea())
  select HUMAN
  goto (rec)
else
  R_Use(dir_server+"kas_pl_u",dir_server+"kas_pl1u","KPLU")
  set relation to u_kod into USL
  R_Use(dir_server+"kas_pl",dir_server+"kas_pl1","KPL")
  find (str(glob_kartotek,7))
  do while kpl->kod_k == glob_kartotek
    ++j
    add_string("")
    add_string(lstr(j)+".")
    add_string("Дата оплаты: "+full_date(kpl->k_data)+;
               ",  чек №: "+lstr(kpl->n_chek)+;
               ",  сумма за услуги: "+lput_kop(kpl->cena,.t.))
    select KPLU
    find (str(kpl->(recno()),7))
    do while kplu->kod == kpl->(recno())
      s := "  Услуга: "+alltrim(usl->shifr)+;
           ", цена: "+lput_kop(kplu->u_cena,.t.)+;
           ", кол-во: "+lstr(kplu->kol)+;
           ", ст-ть: "+lput_kop(kplu->stoim,.t.)+;
           ", врач: "+lstr(ret_tabn(kplu->kod_vr))
      add_string(s)
      select KPLU
      skip
    enddo
    select KPL
    skip
  enddo
  kpl->(dbCloseArea())
  kplu->(dbCloseArea())
endif
usl->(dbCloseArea())
fclose(fp)
rest_box(buf)
select (tmp_select)
if j == 0
  func_error(4,"Не было ввода "+iif(nKey==K_F3,"квитанций","чеков")+" по данному больному!")
else
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL



// 18.12.23
Function f_p_kart(nKey)
Static st_n_kvit := 0
Static st_tip_usl := 0
Local buf := savescreen(), tmp_color := setcolor(), str_1, fl, ;
      colget_menu := "R/W", i, k, tmp_help := help_code, s_msg, ;
      pos_read := 0, k_read := 0, count_edit := 0,;
      ret := -1
Private is_mkb10 := .f., r1 := 11
if mem_plsoput == 2
  --r1
endif
is_mkb10 := .t.
mywait()
Private ;
    MKOD_DIAG   := space(6)          ,; // шифр 1-ой осн.болезни
    MSOPUT_B1   := space(6)          ,; // шифр 1-ой сопутствующей болезни
    MSOPUT_B2   := space(6)          ,; // шифр 2-ой сопутствующей болезни
    MSOPUT_B3   := space(6)          ,; // шифр 3-ой сопутствующей болезни
    MSOPUT_B4   := space(6)          ,; // шифр 4-ой сопутствующей болезни
    MSOPUT_B5   := space(6)          ,; // шифр 5-ой сопутствующей болезни
    MN_KVIT     := st_n_kvit         ,; // номер квитанционной книжки
    mkv_cia     := 0                 ,;
    mdate_u1    := iif(glob_kassa==1, sys_date, ctod("")),;
    MLPU        := glob_uch[2]       ,; // наименование учреждения
    M1LPU       := glob_uch[1]       ,; // код учреждения
    MOTD        := glob_otd[2]       ,; // наименование отделения
    M1OTD       := glob_otd[1]       ,; // код отделения
    MN_DATA     := sys_date          ,; // дата начала лечения
    MK_DATA     := sys_date          ,; // дата окончания лечения
    mkod_vr     := 0                 ,; // код направившего врача
    MCENA       := 0,;                    // стоимость лечения
    mtabn_vr := 0, mvrach := space(35),;
    mtip_usl, m1tip_usl := st_tip_usl,;
    mpr_smo := space(10), m1pr_smo := 0,;
    mpolis := space(25), ;
    mGP_NOMER := space(16), mGP_DATE := ctod(""),;
    mGP2NOMER := space(16), mGP2DATE := ctod(""),;
    mplat_fio := space(40), mplat_inn := space(12),;
    mplat_adres := space(50),; // адрес плательщика
    mplat_pasport := space(15),;  // документ плательщика
    MKEMVYD, M1KEMVYD := 0, MKOGDAVYD := ctod('') // кем и когда выдан паспорт ПЛАТЕЛЬЩИКА
Private is_kassa := .t.
if nKey == K_ENTER
  if human->is_kas == 1
    is_kassa := .f.
  endif
  MKOD_DIAG   := human->KOD_DIAG      // шифр 1-ой осн.болезни
  MSOPUT_B1   := human->SOPUT_B1      // шифр 1-ой сопутствующей болезни
  MSOPUT_B2   := human->SOPUT_B2      // шифр 2-ой сопутствующей болезни
  MSOPUT_B3   := human->SOPUT_B3      // шифр 3-ой сопутствующей болезни
  MSOPUT_B4   := human->SOPUT_B4      // шифр 4-ой сопутствующей болезни
  MSOPUT_B5   := human->SOPUT_B5      // шифр 5-ой сопутствующей болезни
  MN_KVIT     := human->N_KVIT        // номер квитанционной книжки
  mkv_cia     := human->kv_cia
  mdate_u1    := c4tod(human->pdate)
  M1LPU       := human->LPU           // код учреждения
  M1OTD       := human->OTD           // код отделения
  MN_DATA     := human->N_DATA        // дата начала лечения
  MK_DATA     := human->K_DATA        // дата окончания лечения
  mkod_vr     := human->kod_vr
  MCENA       := human->CENA          // стоимость лечения
  m1tip_usl   := human->tip_usl
  if m1tip_usl == 0
    mplat_fio := human->plat_fio
    mplat_inn := human->plat_inn

  else
    m1pr_smo := human->pr_smo
    mpolis := human->d_polis
    mGP_NOMER := human->GP_NOMER
    mGP_DATE  := human->GP_DATE
    mGP2NOMER := human->GP2NOMER
    mGP2DATE  := human->GP2DATE
  endif
  if mkod_vr > 0
    select PERSO
    goto (mkod_vr)
    mvrach := padr(perso->fio,35)
    mtabn_vr := perso->tab_nom
  endif
endif
R_Use(dir_server+"hum_plat",dir_server+"hum_plat","KPLAT")
find (str(human->(recno()),7))
if found()
  mplat_adres   := KPLAT->ADRES
  mplat_pasport := KPLAT->PASPORT
  m1kemvyd  := Kplat->kemvyd   // кем выдан документ ПЛАТЕЛЬЩИКА
  mkogdavyd := kplat->kogdavyd // когда выдан документ ПЛАТЕЛЬЩИКА
endif
KPLAT->(dbCloseArea())
//
mtip_usl := inieditspr(A__MENUVERT, menu_kb, m1tip_usl)
mlpu := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
motd := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
MKEMVYD := inieditspr(A__POPUPMENU, dir_server + 's_kemvyd', M1KEMVYD)
if m1tip_usl == PU_D_SMO
  mpr_smo := inieditspr(A__POPUPMENU, dir_server+"p_d_smo", m1pr_smo)
elseif m1tip_usl == PU_PR_VZ
  mpr_smo := inieditspr(A__POPUPMENU, dir_server+"p_pr_vz", m1pr_smo)
endif
str_1 := " карточки лечения больного"
if nKey == K_INS
  str_1 := "добавление"+str_1
else
  str_1 := "редактирование"+str_1
endif
Private gl_area := {r1,0,maxrow()-1,maxcol(),0}
box_shadow(r1,0,maxrow()-1,maxcol(),color1,"Платные услуги - "+str_1,color8)
status_key("^<Esc>^ - выход;  ^<PgDn>^ - запись")
help_code := -1
if nKey == K_INS .and. glob_pl_reg == 1
  mdate_u1 := sys_date
  MN_DATA  := ctod("")
  MK_DATA  := ctod("")
endif
diag_screen(0)
*
do while .t.
  setcolor(cDataCGet)
  @ r1+1,1 clear to maxrow()-2,maxcol()-1
  @ r1+2,2 say "ЛПУ" get mlpu ;
     reader {|x|menu_reader(x,{{|k,r,c|ret_uch_otd(k,r,c,sys_date,,X_PLATN)}},A__FUNCTION,,,.f.)}
  @ r1+2,37 say "Отделение" get motd when .f.
  @ r1+3,2 say "Категория больного" get mtip_usl ;
            reader {|x|menu_reader(x,menu_kb,A__MENUVERT,,,.f.)} ;
            valid {|g,o| val_tip_usl(g,o) } ;
            when is_kassa
  get1_p_kart()  // остальные Get'ы
  if nKey == K_ENTER .and. !ver_pub_date(mk_data,.t.)
    keyboard chr(K_ESC)
  endif
  count_edit := myread(,@pos_read,++k_read)
  if lastkey() != K_ESC
    err_date_diap(mn_data,"Дата начала лечения")
    err_date_diap(mk_data,"Дата окончания лечения")
    if glob_pl_reg == 1
      err_date_diap(mdate_u1,"Дата оплаты услуги")
    endif
    if f_Esc_Enter(1)
      if m1lpu == 0
        func_error(4,"Не введено лечебное учреждение!")
        loop
      endif
      if empty(mk_data)
        func_error(4,"Не введена дата окончания лечения.")
        loop
      endif
//    if empty(mkod_diag)
//      func_error(4,"Не введен шифр заболевания.")
//      loop
//    endif
      mywait()
      select HUMAN
      if nKey == K_INS
        AddRec(7)
        human->kod_k := glob_kartotek
        if glob_kassa == 1 .and. m1tip_usl == PU_PLAT  // если не взаимозачет
          human->is_kas := 2
        endif
        fl_found := .t.
      else
        G_RLock(forever)
      endif
      st_n_kvit := mn_kvit
      human->KOD_DIAG := MKOD_DIAG       // шифр 1-ой осн.болезни
      human->SOPUT_B1 := MSOPUT_B1       // шифр 1-ой сопутствующей болезни
      human->SOPUT_B2 := MSOPUT_B2       // шифр 2-ой сопутствующей болезни
      human->SOPUT_B3 := MSOPUT_B3       // шифр 3-ой сопутствующей болезни
      human->SOPUT_B4 := MSOPUT_B4       // шифр 4-ой сопутствующей болезни
      human->SOPUT_B5 := MSOPUT_B5       // шифр 5-ой сопутствующей болезни
      human->N_KVIT   := MN_KVIT         // номер квитанционной книжки
      human->LPU      := M1LPU           // код учреждения
      human->OTD      := M1OTD           // код отделения
      human->N_DATA   := MN_DATA         // дата начала лечения
      human->K_DATA   := MK_DATA         // дата окончания лечения
      human->kod_vr   := mkod_vr
      human->kv_cia   := mkv_cia
      human->pdate    := dtoc4(mdate_u1)
      human->tip_usl  := m1tip_usl
      if m1tip_usl == 0
        human->pr_smo := 0
        human->plat_fio := mplat_fio
        human->plat_inn := mplat_inn
       else
        human->pr_smo := m1pr_smo
        human->d_polis := mpolis
        human->GP_NOMER := mGP_NOMER
        human->GP_DATE  := mGP_DATE
        human->GP2NOMER := mGP2NOMER
        human->GP2DATE  := mGP2DATE
        human->is_kas := 0
      endif
      UnLock
      human->(dbCommit())
      G_Use(dir_server+"hum_plat",dir_server+"hum_plat","KPLAT")
      if len(alltrim(mplat_adres)) > 2 .or. len(alltrim(mplat_pasport)) > 2
        find (str(human->(recno()),7))
        if !found()
          append blank
        else
          G_RLock(forever)
        endif
        KPLAT->kod     := human->(recno())
        KPLAT->ADRES   := mplat_adres
        KPLAT->PASPORT := mplat_pasport
        KPLAT->kemvyd := m1kemvyd     // кем выдан документ ПЛАТЕЛЬЩИКА
        KPLAT->kogdavyd := mkogdavyd  // когда выдан документ ПЛАТЕЛЬЩИКА
      else
        find (str(human->(recno()),7))
        if found()
          deleterec(.t.)
        endif
      endif
      KPLAT->(dbCloseArea())
      select HUMAN
      st_tip_usl := m1tip_usl
      write_work_oper(glob_task,OPER_LIST,iif(nKey==K_INS,1,2),1,count_edit)
      ret := 0
    endif
  endif
  if nKey == K_INS .and. !fl_found
    ret := 1
  endif
  exit
enddo
select HUMAN
diag_screen(2)
setcolor(tmp_color)
restscreen(buf)
help_code := tmp_help
return ret



//
Function val_tip_usl(get,old)
Local fl := .t.
if m1tip_usl == 0
  m1pr_smo := 0 ; mpr_smo := space(10)
endif
if old != NIL .and. old != m1tip_usl
  m1pr_smo := 0 ; mpr_smo := space(10)
  get1_p_kart()
endif
return fl



// 31.03.14
Function get1_p_kart()  // остальные Get'ы
Local bg := {|o,k| get_MKB10(o,k) }, j := r1+3,  pic_diag := "@K@!"
asize(GetList,3)   // берем первые 3 элемента
@ j,37 clear to j,maxcol()-1
@ j+1,1 clear to maxrow()-2,maxcol()-1
if m1tip_usl == PU_D_SMO
  @ j,37 say "СМО" get mpr_smo reader ;
            {|x| menu_reader(x,;
                 {dir_server+"p_d_smo",,,,,color0,"Добровольные СМО","B/BG"},;
                 A__POPUPBASE1,,,.f.);
            }
  ++j
  @ j,2 say "Полис" get mpolis picture "@!@S20"
  @ j,col()+1 say "Гарантийное письмо №" get mGP_NOMER picture "@!@S14"
  @ j,col()+1 say "от" get mGP_DATE
  ++j
  @ j,29      say "Гарантийное письмо №" get mGP2NOMER picture "@!@S14"
  @ j,col()+1 say "от" get mGP2DATE
elseif m1tip_usl == PU_PR_VZ
  @ j,37 say "Предприятие" get mpr_smo reader ;
            {|x| menu_reader(x,;
                 {dir_server+"p_pr_vz",,,,,color0,"Предприятия по взаимозачету","B/BG"},;
                 A__POPUPBASE1,,,.f.);
            }
  ++j
  @ j,2 say "Полис" get mpolis picture "@!@S20"
  @ j,col()+1 say "Гарантийное письмо №" get mGP_NOMER picture "@!@S14"
  @ j,col()+1 say "от" get mGP_DATE
  ++j
  @ j,29      say "Гарантийное письмо №" get mGP2NOMER picture "@!@S14"
  @ j,col()+1 say "от" get mGP2DATE
endif
++j
@ j,2 say "Шифр основного заболевания" get mkod_diag ;
  picture pic_diag reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,,) ;
  when diag_screen(2) .and. when_diag()
if mem_plsoput == 2
  ++j
  @ j,2 say "Шифры сопуствующих заболеваний" get msoput_b1;
             picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.f.,.f.,,)
  @ row(),col()+1 say "," get msoput_b2;
             picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.f.,.f.,,)
  @ row(),col()+1 say "," get msoput_b3;
             picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.f.,.f.,,)
  @ row(),col()+1 say "," get msoput_b4;
             picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.f.,.f.,,)
  @ row(),col()+1 say "," get msoput_b5;
             picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.f.,.f.,,)
endif
if mem_naprvr == 2
  ++j
    @ j,2 say "Таб.№ направившего врача" get mtabn_vr pict "99999" ;
             valid {|g| f5e_p_kusl(g,2,3) }
    @ row(),col()+1 get mvrach when .f. color color14
endif
if glob_pl_reg == 1
  ++j
  @ j,2 say "Номер квитанционной книжки" get mn_kvit pict "99999"
  ++j
  @ j,2 say "Номер квитанции" get mkv_cia pict "999999"
elseif glob_kassa == 1 .and. mek_kassa == 1 //01.12.2008
  ++j
  @ j,12 say ""
elseif glob_kassa == 1 .and. mek_kassa == 2 //01.12.2008
  ++j
  @ j,2 say "Номер квитанционной книжки" get mn_kvit pict "99999"
endif
if glob_pl_reg == 1 .or. glob_kassa == 1
  @ row(),col()+2 say "Дата оплаты услуги" get mdate_u1 ;
          valid {|| if(empty(mn_data), (mn_data:=mdate_u1), nil),;
                    if(empty(mk_data), (mk_data:=mdate_u1), nil),;
                    update_get() } ;
          when is_kassa
  ++j
  @ j,2 say "Дата начала лечения" get mn_data //valid {|g|f_k_data(g,1)}
  @ row(),col()+2 say "Дата окончания лечения" get mk_data //valid {|g|f_k_data(g,2)}
else
  ++j
  @ j,2 say "Дата начала лечения" get mn_data valid {|g|f_k_data(g,1)}
  ++j
  @ j,2 say "Дата окончания лечения" get mk_data valid {|g|f_k_data(g,2)}
endif
if m1tip_usl == PU_PLAT
  ++j
  @ j,2 say "Плательщик: ФИО" get mplat_fio
  @ j,col() say ", ИНН" get mplat_inn
  ++j
  @ j,2 say "Адрес" get mplat_adres pict "@S45"
  @ j,col() say ", № док." get mplat_pasport
  ++j
  @ j, 2 say 'Выдано' get mkogdavyd
  @ j, col() say ',' get mkemvyd reader {|x|menu_reader(x, {{|k, r, c|get_s_kemvyd(k, r, c)}}, A__FUNCTION, , , .f.)}
endif
++j
@ j,50 say "Стоимость лечения "+lstr(mcena,11,2) color "GR+/B"
return NIL



//
Function f5e_p_kusl(get,when_valid,k)
Local fl := .t., s, i, j, old_kod, mvar, amsg, arr_zf,;
      msg1_err := "Код врача равен коду ассистента! Это недопустимо.",;
      msg2_err := "Человека с таким кодом нет в базе данных персонала!",;
      blk_sum := {|| mstoim := round_5(mu_cena * mkol, 2) }
if when_valid == 1    // when
  if k == 2     // Шифр услуги
    if !empty(mshifr)
      fl := .f.
    endif
  elseif k == 5 // Количество услуг
    if empty(mshifr)
      fl := .f.
    elseif mt_edit > 1
      fl := .f.
    endif
  elseif k == 7 // Общая стоимость услуги
    if empty(mshifr)
      fl := .f.
    endif
  elseif k == 10  // код отделения
    SetKey( K_F3, {|p,l,v| get1_otd(p,l,v,get:Row,get:Col)} )
    @ r1,45 say "<F3> - выбор отделения из меню" color color13
  endif
else                  // valid
  if k == 1     // Дата оказания услуги
    if !emptyany(human->n_data,mdate_u1) .and. mdate_u1 < human->n_data
      fl := func_error(4,"Введенная дата меньше даты начала лечения!")
    elseif !emptyany(human->k_data,mdate_u1) .and. mdate_u1 > human->k_data
      fl := func_error(4,"Введенная дата больше даты окончания лечения!")
    endif
    if is_zf_stomat == 1 .and. fl
      i := 0
      if !empty(mkod_diag)
        ++i
      endif
      if !empty(mzf)
        ++i
      endif
      if i > 0 // перепрыгнуть на ввод шифра услуги
        keyboard replicate(chr(K_TAB),i)
      endif
    endif
  elseif k == 2 // Шифр услуги
    if !empty(mshifr) .and. !(mshifr == get:original)
      mshifr := transform_shifr(mshifr)
      select USL
      set order to 1
      find (mshifr)
      if found()
        mu_kod := usl->kod
        mname_u := usl->name
        mis_nul := usl->is_nulp
        if mis_nul  // услуга с нулевой ценой
          mu_cena := 0 ; mt_edit := 1
        else
          // берем цену для платных услуг
          mu_cena := if(smvzros_reb==0, usl->pcena, usl->pcena_d)
          if human->tip_usl==PU_D_SMO .and. usl->dms_cena > 0
            mu_cena := usl->dms_cena
          endif
        endif
        mkol := 1
        eval(blk_sum)
        update_gets()
        if is_zf_stomat == 1
          usl->(dbGoto(mu_kod)) // на всякий случай
          if !empty(mzf) .and. usl->zf == 0
            //n_message({"В данную услугу запрещен ввод зубной формулы!",;
            //           "(Не будет записана)"},,"W/G","N/G",,,"GR/G")
          endif
        endif
      elseif get_k_usluga(mshifr,smvzros_reb,@fl)
        box_shadow(r1-5,40,r1-3,77,cColorStMsg,;
                   "Комплексная услуга",cColorSt2Msg)
        @ r1-4,41 say padc("Количество услуг - "+lstr(len(pr_k_usl)),36) color cColorStMsg
        mkol := 1
        if fl  // сменить код врача и ассистента
          mvrach := space(35)
          mtabn_vr := 0
          if mkod_vr > 0
            select PERSO
            goto (mkod_vr)
            if !eof() .and. !deleted()
              mvrach := padr(perso->fio,35)
              mtabn_vr := perso->tab_nom
            endif
          endif
          massist := space(35)
          mtabn_as := 0
          if mkod_as > 0
            select PERSO
            goto (mkod_as)
            if !eof() .and. !deleted()
              massist := padr(perso->fio,35)
              mtabn_as := perso->tab_nom
            endif
          endif
        endif
        fl := update_gets()
      else
        fl := func_error(4,"Такого шифра нет в базе данных услуг.")
      endif
    endif
  elseif k == 3 // Код врача
    old_kod := mkod_vr
    if empty(mtabn_vr)
      mkod_vr := 0
      mvrach := space(35)
    else
      select PERSO
      find (str(mtabn_vr,5))
      if found()
        if type("mkod_as") == "N" .and. perso->kod == mkod_as
          fl := func_error(4,msg1_err)
        elseif mem_kat_va == 2 .and. perso->kateg != 1
          fl := func_error(4,"Данный сотрудник не является ВРАЧОМ по штатному расписанию")
        else
          mkod_vr := perso->kod
          mvrach := padr(perso->fio,35)
        endif
      else
        fl := func_error(4,msg2_err)
      endif
    endif
    if old_kod != mkod_vr
      update_get("mvrach")
    endif
  elseif k == 4 // Код ассистента
    old_kod := mkod_as
    if empty(mtabn_as)
      mkod_as := 0
      massist := space(35)
    else
      select PERSO
      find (str(mtabn_as,5))
      if found()
        if perso->kod == mkod_vr
          fl := func_error(4,msg1_err)
        elseif mem_kat_va == 2 .and. perso->kateg != 2
          fl := func_error(4,"Данный сотрудник не является СРЕДНИМ МЕД.ПЕРСОНАЛОМ по штатному расписанию")
        else
          mkod_as := perso->kod
          massist := padr(perso->fio,35)
        endif
      else
        fl := func_error(4,msg2_err)
      endif
    endif
    if old_kod != mkod_as
      update_get("massist")
    endif
  elseif k == 5 // Количество услуг
    if mkol != get:original
      eval(blk_sum)
      update_gets()
    endif
  elseif k == 6 // Коэффициент индексации услуги
    SetKey( K_F2, NIL )
    @ r1+8,45 say space(28) color color13
    eval(blk_sum)
    update_gets()
  elseif k == 7 // Общая стоимость услуги
    if !(round(mstoim,2) == round_5(mu_cena * mkol, 2))
      if mt_edit == 0
        mt_edit := 2
      elseif mt_edit == 1
        mt_edit := 3
      endif
      @ r1+8,37 say "[ редактировалась стоимость услуги ]" color color13
    endif
  elseif k == 10  // код отделения
    if (i := ascan(pr_arr, {|x| x[1] == m1otd } )) > 0
      motd := pr_arr[i,2] ; update_get("motd")
      SetKey( K_F3, NIL )
      @ r1,45 say space(30) color color13
    else
      fl := func_error(4,"Данный код отделения не найден!")
    endif
  elseif k == 11  // код медсестры
    mvar := &(readvar())
    if mvar == 0
      mvar := "P"+readvar()
      &mvar := 0
    elseif mvar != get:original
      select MS
      find ("1"+str(mvar,5))
      if found()
        mvar := "P"+readvar()
        &mvar := ms->(recno())
      else
        fl := func_error(4,"Медсестра с данным кодом не найдена!")
      endif
    endif
  elseif k == 12  // код санитарки
    mvar := &(readvar())
    if mvar == 0
      mvar := "P"+readvar()
      &mvar := 0
    elseif mvar != get:original
      select MS
      find ("2"+str(mvar,5))
      if found()
        mvar := "P"+readvar()
        &mvar := ms->(recno())
      else
        fl := func_error(4,"Санитарка с данным кодом не найдена!")
      endif
    endif
  elseif k == 101  // зубная формула
    if !empty(mzf)
      amsg := {}
      if mu_kod > 0
        usl->(dbGoto(mu_kod))
        if usl->zf == 0
          aadd(amsg, "В данную услугу запрещен ввод зубной формулы!")
        endif
      endif
      arr_zf := STverifyZF(mzf,smdate_r,human->n_data,@amsg)
      if len(arr_zf) > 0
        if empty(mkod_diag)
          aadd(amsg, 'Не введен диагноз!')
        endif
        STverDelZub(human->kod_k,arr_zf,dtoc4(mdate_u1),1,mrec_hu,@amsg)
        if len(amsg) > 0
          n_message(amsg,,"W/G","N/G",,,"GR/G")
        endif
      endif
    endif
  endif
  if !fl
    &(readvar()) := get:original
  elseif equalany(k,3,4) .and. mem_otdusl==2 .and. type("pr1arr_otd")=="A"
    if (old_kod := mkod_vr) == 0
      old_kod := mkod_as
    endif
    if old_kod > 0
      select PERSO
      goto (old_kod)
      if iif(yes_many_uch, .t., perso->uch == glob_uch[1]) .and. ;
              perso->otd > 0 .and. ;
                (i := ascan(pr1arr_otd,{|x| x[1] == perso->otd})) > 0
        m1otd := perso->otd ; motd := pr1arr_otd[i,2]
        update_get("m1otd") ; update_get("motd")
      else
        &(readvar()) := get:original
        if iif(yes_many_uch, .t., perso->uch == glob_uch[1])
          fl := func_error(4,"Не проставлено отделение, в котором работает данный человек!")
        else
          fl := func_error(4,"Данный человек работает в другом учреждении!")
        endif
        /*if (glob_otd := ret_1st_otd(glob_uch[1])) != NIL
          m1otd := glob_otd[1] ; motd := padr(glob_otd[2],30)
        endif*/
      endif
    endif
  endif
endif
return fl



// 16.10.18
Function poisk_plat()
Static sdate, sn_kvit := 0, skv1 := 0, skv2 := 0
Local buf := savescreen(), tmp_color := setcolor(cDataCGet),;
      j := 0, i,;
      pr_kod_vr, pr_med1, pr_med2, pr_med3, pr_san1, pr_san2, pr_san3,;
      adbf := {{"REC_HUM"  ,   "N",     7,     0},; // номер записи по БД hum_p
               {"FIO"      ,   "C",    50,     0},;
               {"OTD"      ,   "N",     3,     0},; // код отделения
               {"N_KVIT"   ,   "N",     5,     0},; // номер квитанционной книжки
               {"KV_CIA"   ,   "N",     6,     0},; // номер квитанции
               {"CENA"     ,   "N",    10,     2},; // стоимость лечения
               {"DATA"     ,   "D",     8,     0},; // дата
               {"FL_DATA"  ,   "L",     1,     0},; // флаг равенства дат
               {"kod_vr"   ,   "N",     5,     0},; // код врача
               {"med1"     ,   "N",     5,     0},; // код медсестры
               {"med2"     ,   "N",     5,     0},; // код медсестры
               {"med3"     ,   "N",     5,     0},; // код медсестры
               {"san1"     ,   "N",     5,     0},; // код санитарки
               {"san2"     ,   "N",     5,     0},; // код санитарки
               {"san3"     ,   "N",     5,     0},; // код санитарки
               {"FL_EDIT"  ,   "L",     1,     0}}  // флаг редактирования
DEFAULT sdate TO sys_date
if glob_kassa == 1 .and. mek_kassa == 1
  Private drvFR
  IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    //
  else
    return func_error(4,"Ошибка запуска драйвера КАССЫ")
  endif
endif
Private mdate := sdate, mn_kvit := sn_kvit, mkv1 := skv1, mkv2 := skv2,;
        gl_area := {12,0,23,79,0}
box_shadow(13,2,22,77,,"Ввод данных для выборки информации",color8)
@ 15,4 say "Дата окончания лечения" get mdate valid !empty(mdate)
@ 16,4 say "Номер квитанционной книжки" get mn_kvit pict "99999"
if glob_pl_reg == 1
  @ 17,5 say "Начальный номер квитанции" get mkv1 pict "999999"
  @ 18,5 say "Конечный  номер квитанции" get mkv2 pict "999999"
endif
status_key("^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода")
myread()
if lastkey() != K_ESC .and. ver_pub_date(mdate,.t.) .and. f_Esc_Enter("ввода")
  sdate := mdate ; sn_kvit := mn_kvit ; skv1 := mkv1 ; skv2 := mkv2
  mywait()
  dbcreate(cur_dir+"tmp",adbf)
  use (cur_dir+"tmp") new
  G_Use(dir_server+"plat_ms",dir_server+"plat_ms","MS")
  G_Use(dir_server+"kartotek",,"KART")
  G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
  G_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
  find (dtos(mdate))
  do while human->k_data == mdate .and. !eof()
    fl := .t.
    if fl .and. mn_kvit > 0
      fl := (mn_kvit == human->n_kvit)
    endif
    if fl .and. mkv1 > 0
      fl := (mkv1 <= human->kv_cia)
    endif
    if fl .and. mkv2 > 0
      fl := (human->kv_cia <= mkv2)
    endif
    if fl
      fld := (human->n_data == human->k_data)
      if fld .and. glob_pl_reg == 1
        fld := (human->k_data == c4tod(human->pdate))
      endif
      select HU
      find (str(human->(recno()),7))
      pr_kod_vr := hu->kod_vr
      pr_med1   := hu->med1
      pr_med2   := hu->med2
      pr_med3   := hu->med3
      pr_san1   := hu->san1
      pr_san2   := hu->san2
      pr_san3   := hu->san3
      do while hu->kod == human->(recno())
        if fld
          fld := (human->pdate == hu->date_u)
        endif
        if pr_kod_vr != hu->kod_vr ; pr_kod_vr := 0 ; endif
        if pr_med1 != hu->med1     ; pr_med1   := 0 ; endif
        if pr_med2 != hu->med2     ; pr_med2   := 0 ; endif
        if pr_med3 != hu->med3     ; pr_med3   := 0 ; endif
        if pr_san1 != hu->san1     ; pr_san1   := 0 ; endif
        if pr_san2 != hu->san2     ; pr_san2   := 0 ; endif
        if pr_san3 != hu->san3     ; pr_san3   := 0 ; endif
        skip
      enddo
      //
      select MS
      if pr_med1 > 0
        goto (pr_med1)
        if !eof() .and. ms->tip == 1
          pr_med1 := ms->tab_nom
        endif
      endif
      if pr_med2 > 0
        goto (pr_med2)
        if !eof() .and. ms->tip == 1
          pr_med2 := ms->tab_nom
        endif
      endif
      if pr_med3 > 0
        goto (pr_med3)
        if !eof() .and. ms->tip == 1
          pr_med3 := ms->tab_nom
        endif
      endif
      if pr_san1 > 0
        goto (pr_san1)
        if !eof() .and. ms->tip == 2
          pr_san1 := ms->tab_nom
        endif
      endif
      if pr_san2 > 0
        goto (pr_san2)
        if !eof() .and. ms->tip == 2
          pr_san2 := ms->tab_nom
        endif
      endif
      if pr_san3 > 0
        goto (pr_san3)
        if !eof() .and. ms->tip == 2
          pr_san3 := ms->tab_nom
        endif
      endif
      //
      select KART
      goto (human->kod_k)
      select TMP
      append blank
      tmp->REC_HUM := human->(recno())
      tmp->OTD := human->otd
      tmp->FIO := kart->fio
      tmp->N_KVIT := human->n_kvit
      tmp->KV_CIA := human->kv_cia
      tmp->CENA := human->cena
      tmp->DATA := human->k_data
      tmp->fl_data := fld  // одинаковая ли дата ?
      tmp->kod_vr := pr_kod_vr
      tmp->med1   := pr_med1
      tmp->med2   := pr_med2
      tmp->med3   := pr_med3
      tmp->san1   := pr_san1
      tmp->san2   := pr_san2
      tmp->san3   := pr_san3
    endif
    select HUMAN
    skip
  enddo
  if (j := tmp->(lastrec())) > 0
    select TMP
    sort on n_kvit,kv_cia to (cur_dir+"tmp1")
  endif
  close databases
  if j == 0
    func_error(4,"Не найдено листов учета по данному запросу!")
  endif
endif
restscreen(buf) ; setcolor(tmp_color)
if j > 0
  R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
  use_base("hum_p","HUMAN")
  set order to 0
  use (cur_dir+"tmp1") new alias TMP
  go top
  box_shadow(maxrow()-4,2,maxrow()-2,77,"W/B")
  Alpha_Browse(T_ROW,0,maxrow()-6,79,"f1_po_plat",color0,,,;
               .f.,.t.,,"f2_po_plat","f3_po_plat",,;
               {"═","░","═","N/BG,W+/N,B/BG,BG+/B,RB/BG,W+/RB",.t.,180} )
  close databases
endif
restscreen(buf)
return NIL

// 05.10.17
Function f1_po_plat(oBrow)
Local oColumn, blk := {|| iif(tmp->fl_edit, {5,6}, iif(tmp->fl_data, {1,2}, {3,4})) }
//
oColumn := TBColumnNew("№ кв.;книжк",{|| tmp->n_kvit })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("№ кви-;танции",{|| tmp->kv_cia })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Отд",{|| tmp->otd })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("  Дата; оплаты", {|| date_8(tmp->data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Ст-сть; лечения", {|| umest_val(tmp->cena,8,2) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Врач",{|| put_val(ret_tabn(tmp->kod_vr),5) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" М/c;  1", {|| put_val(tmp->med1,5) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" М/c;  2", {|| put_val(tmp->med2,5) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" М/c;  3", {|| put_val(tmp->med3,5) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" Сан.;  1", {|| put_val(tmp->san1,5) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" Сан.;  2", {|| put_val(tmp->san2,5) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" Сан.;  3", {|| put_val(tmp->san3,5) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" ",{|| iif(tmp->fl_edit, "", " ") })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
status_key("^<Esc>^ - выход;  ^<Enter>^ - редактирование;  ^<Ctrl+Enter>^ - редактирование услуг")
return NIL

//
Function f2_po_plat()
@ maxrow()-3,4 say tmp->fio color color1
return NIL

// 05.10.17
Function f3_po_plat(nKey,oBrow)
LOCAL j := 0, flag := -1, buf := save_row(maxrow()), buf1, fl := .f., rec, mkod,;
      rec1, llpu, tmp_color := setcolor(), r, str_sem, is_ed_date
if nKey == K_ENTER .or. nKey == K_CTRL_RET
  rec1 := tmp->(recno())
  human->(dbGoto(tmp->rec_hum))
  rec := human->(recno())
  llpu := human->lpu
  glob_kartotek := human->kod_k
  glob_k_fio := tmp->fio
  str_sem := "ПУ Редактирование человека "+lstr(glob_kartotek)
  if !G_SLock(str_sem)
    func_error(4,err_slock)
    return flag
  endif
  if nKey == K_ENTER
    Private pr_arr := {}
    R_Use(dir_server+"mo_otd",,"OTD")
    dbeval({|| aadd(pr_arr,{otd->(recno()),otd->name}) },;
           {|| otd->kod_lpu == human->lpu .and. between_date(otd->DBEGINP,otd->DENDP,tmp->data)} )
    asort(pr_arr,,,{|x,y| x[2] < y[2] } )
    R_Use(dir_server+"plat_ms",dir_server+"plat_ms","MS")
    r := T_ROW+3+oBrow:rowPos
    Private mn_kvit := tmp->n_kvit,;
            mkv_cia := tmp->kv_cia,;
            motd := tmp->otd,;
            mdate := tmp->data,;
            mkod_vr := tmp->kod_vr, mtabn_vr := 0,;
            pmmed1 := 0, mmed1 := tmp->med1,;
            pmmed2 := 0, mmed2 := tmp->med2,;
            pmmed3 := 0, mmed3 := tmp->med3,;
            pmsan1 := 0, msan1 := tmp->san1,;
            pmsan2 := 0, msan2 := tmp->san2,;
            pmsan3 := 0, msan3 := tmp->san3
    if mkod_vr > 0
      mtabn_vr := ret_tabn(mkod_vr)
    endif
    select MS
    if mmed1 > 0
      find ("1"+str(mmed1,5))
      if found()
        pmmed1 := ms->(recno())
      endif
    endif
    if mmed2 > 0
      find ("1"+str(mmed2,5))
      if found()
        pmmed2 := ms->(recno())
      endif
    endif
    if mmed3 > 0
      find ("1"+str(mmed3,5))
      if found()
        pmmed3 := ms->(recno())
      endif
    endif
    if msan1 > 0
      find ("2"+str(msan1,5))
      if found()
        pmsan1 := ms->(recno())
      endif
    endif
    if msan2 > 0
      find ("2"+str(msan2,5))
      if found()
        pmsan2 := ms->(recno())
      endif
    endif
    if msan3 > 0
      find ("2"+str(msan3,5))
      if found()
        pmsan3 := ms->(recno())
      endif
    endif
    setcolor(cDataCGet)
    status_key("^<Esc>^ - выход;  ^<PgDn>^ - запись")
    do while .t.
      @ r,1 get mn_kvit pict "99999"
      if glob_pl_reg == 1
        @ r,7 get mkv_cia pict "999999"
      endif
      @ r,14 get motd valid {|g| val_pl_otd(g) }
      if tmp->fl_data
        @ r,17 get mdate
      endif
      if mkod_vr > 0
        @ r,36 get mtabn_vr pict "99999" valid {|g| f5e_p_kusl(g,2,3) }
      endif
      if mmed1 > 0
        @ r,42 get mmed1 pict "99999" valid {|g| f5e_p_kusl(g,2,11) }
      endif
      if mmed2 > 0
        @ r,48 get mmed2 pict "99999" valid {|g| f5e_p_kusl(g,2,11) }
      endif
      if mmed3 > 0
        @ r,54 get mmed3 pict "99999" valid {|g| f5e_p_kusl(g,2,11) }
      endif
      if msan1 > 0
        @ r,60 get msan1 pict "99999" valid {|g| f5e_p_kusl(g,2,12) }
      endif
      if msan2 > 0
        @ r,66 get msan2 pict "99999" valid {|g| f5e_p_kusl(g,2,12) }
      endif
      if msan3 > 0
        @ r,72 get msan3 pict "99999" valid {|g| f5e_p_kusl(g,2,12) }
      endif
      myread()
      if lastkey() != K_ESC .and. f_Esc_Enter(1)
        mywait()
        tmp->fl_edit := .t.
        select HUMAN
        G_RLock(forever)
        if human->n_kvit != mn_kvit
          human->n_kvit := mn_kvit
          tmp->n_kvit := mn_kvit
        endif
        if glob_pl_reg == 1 .and. human->kv_cia != mkv_cia
          human->kv_cia := mkv_cia
          tmp->kv_cia := mkv_cia
        endif
        if human->otd != motd
          human->otd := motd
          tmp->otd := motd
        endif
        is_ed_date := .f.
        if tmp->fl_data .and. human->n_data != mdate
          human->n_data := mdate
          human->k_data := mdate
          human->pdate  := dtoc4(mdate)
          tmp->data     := mdate
          is_ed_date := .t.
        endif
        UnLock
        G_Use(dir_server+"hum_p_u",{dir_server+"hum_p_u",;
                                    dir_server+"hum_p_uk",;
                                    dir_server+"hum_p_ud",;
                                    dir_server+"hum_p_uv",;
                                    dir_server+"hum_p_ua"},"HU")
        find (str(rec,7))
        do while hu->kod == rec
          G_RLock(forever)
          if is_ed_date
            hu->date_u := dtoc4(mdate)
          endif
          if mkod_vr > 0 .and. mkod_vr != hu->kod_vr
            hu->kod_vr := mkod_vr
            tmp->kod_vr := mtabn_vr
          endif
          if pmmed1 > 0 .and. pmmed1 != hu->med1
            hu->med1 := pmmed1
            tmp->med1 := mmed1
          endif
          if pmmed2 > 0 .and. pmmed2 != hu->med2
            hu->med2 := pmmed2
            tmp->med2 := mmed2
          endif
          if pmmed3 > 0 .and. pmmed3 != hu->med3
            hu->med3 := pmmed3
            tmp->med3 := mmed3
          endif
          if pmsan1 > 0 .and. pmsan1 != hu->san1
            hu->san1 := pmsan1
            tmp->san1 := msan1
          endif
          if pmsan2 > 0 .and. pmsan2 != hu->san2
            hu->san2 := pmsan2
            tmp->san2 := msan2
          endif
          if pmsan3 > 0 .and. pmsan3 != hu->san3
            hu->san3 := pmsan3
            tmp->san3 := msan3
          endif
          UnLock
          skip
        enddo
      endif
      exit
    enddo
    close databases
  elseif nKey == K_CTRL_RET
    close databases
    usl_p_kart(rec,llpu)
  endif
  R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
  use_base("hum_p","HUMAN")
  set order to 0
  goto (rec)
  use (cur_dir+"tmp1") new alias TMP
  goto (rec1)
  tmp->cena := human->cena
  setcolor(tmp_color)
  rest_box(buf) ; flag := 0
  G_SUnLock(str_sem)
else
  keyboard ""
endif
return flag

//
Function val_pl_otd(get)
Local i, fl := .t.
if (i := ascan(pr_arr, {|x| x[1] == motd } )) == 0
  fl := func_error(4,"Данный код отделения не найден!")
  motd := get:original
endif
return fl



//
Function close_lu(k)
Static si1 := 2, si2 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    if !hb_user_curUser:IsAdmin()
      return func_error(4,err_admin)
    endif
    mas_pmt := {"Закрыть л/учета для ~одного больного",;
                "Закрыть л/учета для ~всех",;
                "~Убрать у больного отметку о закрытии л/учета"}
    mas_msg := {"Закрыть лист учета для одного больного",;
                "Закрыть листы учета для всех",;
                "Убрать у больного отметку о закрытии листа учета"}
    mas_fun := {"close_lu(11)",;
                "close_lu(12)",;
                "close_lu(13)"}
    popup_prompt(T_ROW,T_COL+5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    f1close_lu(1)
  case k == 12
    f1close_lu(2)
  case k == 13
    f1close_lu(3)
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  endif
endif
return NIL



//
Function f1close_lu(par)
Local buf, str_sem
Private atip_usl, mtitle, p_regim := par, mdate, arr_m
if (atip_usl := f_p_tip_usl()) == NIL
  return NIL
endif
Private str_find := str(atip_usl[2],1),;
        muslovie := "hu->tip_usl=="+lstr(atip_usl[2])
do case
  case par == 1  // Закрыть лист учета для одного больного
    str_find += "0"
    muslovie += " .and. empty(date_close)"
  case par == 2  // Закрыть листы учета для всех
    str_find += "0"
    muslovie += " .and. empty(date_close)"
  case par == 3  // Убрать у больного отметку о закрытии листа учета
    str_find += "1"
    muslovie += " .and. !empty(date_close)"
endcase
muslovie += " .and. !eof()"
str_sem := "ПУ Закрытие листа учета"
if !G_SLock(str_sem)
  return func_error(4,err_slock)
endif
do case
  case par == 1  // Закрыть лист учета для одного больного
    f2close_lu()
  case par == 2  // Закрыть листы учета для всех
    if atip_usl[2] == PU_D_SMO .and. glob_close == 0  // по оплате
      if f_Esc_Enter("закрытия л/учета по ДМС")
        f1CloseDms()
      endif
    else  // вручную
      mdate := input_value(20,2,22,77,"GR+/R,W+/N",;
                       space(10)+"Введите максимальную дату окончания лечения",;
                       sys_date)
      if mdate != NIL
        f2close_lu()
      endif
    endif
  case par == 3  // Убрать у больного отметку о закрытии листа учета
    if (arr_m := year_month(T_ROW,T_COL+5)) != NIL
      f2close_lu()
    endif
endcase
close databases
G_SUnLock(str_sem)
return NIL



//
Function f2close_lu()
Local buf := savescreen(), j, fl
mywait()
dbcreate(cur_dir+"tmp",{{"rec","N",7,0},;
                        {"is","N",1,0}})
use (cur_dir+"tmp") new
G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HUP")
G_Use(dir_server+"hum_p",dir_server+"hum_pc","HU")
find (str_find)
do while &muslovie
  fl := .t.
  if p_regim == 2
    fl := (hu->k_data <= mdate)
  elseif p_regim == 3
    fl := between(hu->date_close,arr_m[5],arr_m[6])
  endif
  if fl
    select TMP
    append blank
    tmp->rec := hu->(recno())
    if hu->cena > 0 .and. p_regim == 2
      tmp->is := 1
      select HUP
      find (str(hu->(recno()),7))
      do while hup->kod == hu->(recno())
        if emptyall(hup->kod_vr,hup->kod_as)
          fl := .f. ; exit
        endif
        skip
      enddo
      if !fl
        tmp->is := 0
      endif
    endif
    if tmp->(lastrec()) % 5000 == 0
      Commit
    endif
  endif
  select HU
  skip
enddo
j := tmp->(lastrec())
close databases
restscreen(buf)
if j == 0
  if p_regim == 3
    return func_error(4,"Для данной категории больных нет закрытых листов учета!")
  else
    return func_error(4,"Для данной категории больных закрыты все листы учета!")
  endif
else
  if p_regim == 3
    mtitle := 'З'
  else
    mtitle := 'Нез'
  endif
  mtitle += 'акрытые л/учета: "'+alltrim(atip_usl[1])+'"'
  if p_regim == 2
    mtitle += ' [по '+full_date(mdate)+'г.]'
  elseif p_regim == 3
    mtitle += ' ['+arr_m[4]+']'
  endif
  G_Use(dir_server+"kartotek",,"KART")
  G_Use(dir_server+"hum_p",,"HU")
  set relation to kod_k into KART
  use (cur_dir+"tmp") new
  set relation to rec into HU
  index on upper(kart->fio)+str(hu->kod_k,7)+dtos(hu->k_data) to (cur_dir+"tmp")
  go top
  fl := .f.
  if Alpha_Browse(2,1,maxrow()-2,78,"f2_k_close",color0,mtitle,"BG+/GR",;
                  .t.,.t.,,,"f3_k_close",,;
                  {,,,"N/BG,W+/N,B/BG,BG+/B,R/BG,GR+/R",.f.,180} )
    Private pkol := 0, psumma := 0
    kart->(dbCloseArea())
    select TMP
    set relation to
    if p_regim > 1
      go top
      do while !eof()
        if tmp->is == 1
          ++pkol
          psumma += hu->cena
        endif
        skip
      enddo
      box_shadow(18,2,18,77,"W+/R","Отмечено "+lstr(pkol)+;
                 " чел. на сумму "+lput_kop(psumma,.t.)+" руб.",,0)
    endif
    select HU
    set index to (dir_server+"hum_pc")
    set order to 0
    do case
      case p_regim == 1
        if atip_usl[2] == PU_D_SMO .and. glob_close == 0
          func_error(4,"Для данной категории больных закрывайте все листы учета!")
        else
          mdate := input_value(20,2,22,77,"GR+/R,W+/N",;
                           space(15)+"Введите дату закрытия листа учета",;
                           sys_date)
          if mdate != NIL .and. f_Esc_Enter("закрытия листа учета")
            fl := .t.
            select HU
            dbGoto(tmp->rec)
            G_RLock(forever)
            hu->date_close := mdate
            UnLock
          endif
        endif
      case p_regim == 2
        if pkol == 0
          func_error(4," ")
        else
          mdate := input_value(20,2,22,77,"GR+/R,W+/N",;
                           space(15)+"Введите дату закрытия листов учета",;
                           sys_date)
          if mdate != NIL .and. f_Esc_Enter("закрытия листов учета")
            fl := .t.
            mywait()
            select TMP
            go top
            do while !eof()
              if tmp->is == 1
                select HU
                dbGoto(tmp->rec)
                G_RLock(forever)
                hu->date_close := mdate
                UnLock
              endif
              select TMP
              skip
            enddo
          endif
        endif
      case p_regim == 3
        if pkol == 0
          func_error(4," ")
        elseif f_Esc_Enter("снятия признака закрытия",.t.)
          fl := .t.
          mywait()
          select TMP
          go top
          do while !eof()
            if tmp->is == 1
              select HU
              dbGoto(tmp->rec)
              G_RLock(forever)
              hu->date_close := ctod("")
              UnLock
            endif
            select TMP
            skip
          enddo
        endif
    endcase
  endif
  close databases
  if fl
    stat_msg("Операция завершена!") ; mybell(2,OK)
  endif
  restscreen(buf)
endif
return NIL



//
Function f2_k_close(oBrow)
Local oColumn, n := 37, s, blk := {|| iif(hu->cena > 0, {1,2}, {5,6}) }
if p_regim > 1
  n -= 2
  blk := {|| iif(tmp->is==1, {1,2}, iif(hu->cena > 0, {3,4}, {5,6})) }
  oColumn := TBColumnNew(" ",{|| iif(tmp->is==1,chr(16)," ") })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew(center("Ф.И.О.",n),{|| padr(kart->fio,n) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" Начало; лечения", {|| date_8(hu->n_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Окончан.;лечения", {|| date_8(hu->k_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Стоимость; лечения", {|| put_kop(hu->cena,10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
s := "^<Esc>^ выход ^<F9>^ печать "
do case
  case p_regim == 1
    s += "^<Enter>^ закрыть л/учета"
  case p_regim > 1
    s += "^<Enter>^ подтверждение ^<Ins,+,->^ отметка"
endcase
s += " ^<F3>^ просмотр"
status_key(s)
return NIL

//
Function f3_k_close(nKey,oBrow)
LOCAL j := 0, ret := -1, buf := save_row(maxrow()), buf1, fl := .f., tmp_rec, ;
      tmp_color := setcolor(), j1,;
      n_file := "_close"+stxt, sh := 80, HH := 60, reg_print := 2
do case
  case nKey == K_F3
    mywait()
    fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
    arr_title := {;
"─────┬──────────┬────────────────────────────────────┬─────┬─────┬────┬─────────",;
"Дата │   Шифр   │       Наименование услуги          │ Врач│ Асс.│Кол.│Стоимость",;
"─────┴──────────┴────────────────────────────────────┴─────┴─────┴────┴─────────"}
    add_string("")
    add_string("ФИО: "+kart->fio)
    add_string("Срок лечения: "+full_date(hu->n_data)+"-"+full_date(hu->k_data))
    aeval(arr_title, {|x| add_string(x) } )
    R_Use(dir_server+"mo_pers",,"PERSO")
    R_Use(dir_server+"uslugi",,"USL")
    R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HUP")
    set relation to u_kod into USL
    find (str(hu->(recno()),7))
    index on hup->date_u+fsort_usl(usl->shifr) to (cur_dir+"tmp_hup") ;
          while hup->kod == hu->(recno())
    go top
    do while !eof()
      s := left(full_date(c4tod(hup->date_u)),5)+" "+;
           usl->shifr+" "+left(usl->name,36)+" "
      s += put_val(ret_tabn(hup->kod_vr),5)+" "+;
           put_val(ret_tabn(hup->kod_as),5)
      s += str(hup->kol,5)
      s += put_kop(hup->stoim,10)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s)
      if emptyall(hup->kod_vr,hup->kod_as)
        add_string(center(replicate("~",sh-10),sh))
      endif
      skip
    enddo
    add_string(replicate("─",sh))
    add_string(put_kop(hu->cena,sh))
    hup->(dbCloseArea())
    usl->(dbCloseArea())
    fclose(fp)
    rest_box(buf)
    viewtext(n_file,,,,(sh>80),,,reg_print)
    select TMP
  case eq_any(nKey,43,45,K_INS) .and. equalany(p_regim,2,3)
    do case
      case nKey == 45  // минус
        tmp_rec := tmp->(recno())
        tmp->( dbeval({|| tmp->is := 0 } ))
        tmp->(dbGoto(tmp_rec))
        ret := 0
      case nKey == 43  // плюс
        tmp_rec := tmp->(recno())
        tmp->( dbeval({|| tmp->is := 1 } ))
        tmp->(dbGoto(tmp_rec))
        ret := 0
      case nKey == K_INS
        tmp->is := iif(tmp->is==1, 0, 1)
        oBrow:down()
        ret := 0
    endcase
  case nKey == K_F9
    tmp_rec := tmp->(recno())
    if (j := f_alert({"Выберите порядок сортировки листов учета в выходном документе"},;
                     {" По ~ФИО больного "," По ~дате окончания лечения "},;
                     1,"W/RB","G+/RB",20,,"BG+/RB,W+/R,W+/RB,GR+/R" )) == 0
      return ret
    endif
    fl := .t.
    do case
      case p_regim == 1 // Закрыть лист учета для одного больного
        j1 := 1
        mtitle2 := ""
      case p_regim == 2 // Закрыть листы учета для всех
        j1 := f_alert({"Выберите содержание выходного документа"},;
                      {" ~Весь список "," ~Отмеченные больные "},;
                      2,"W/RB","G+/RB",20,,"BG+/RB,W+/R,W+/RB,GR+/R" )
        if (fl := (j1 > 0))
          mtitle2 := iif(j1==1,"","[больные, отмеченные для закрытия листа учета]")
        endif
      case p_regim == 3 // Убрать у больного отметку о закрытии листа учета
        j1 := f_alert({"Выберите содержание выходного документа"},;
                      {" ~Весь список "," ~Отмеченные больные "},;
                      1,"W/RB","G+/RB",20,,"BG+/RB,W+/R,W+/RB,GR+/R" )
        if (fl := (j1 > 0))
          mtitle2 := iif(j1==1,"","[больные, отмеченные для снятия признака закрытия листа учета]")
        endif
    endcase
    if fl
      arr_title := {;
"────────────────────────────────────────────────┬──────────┬──────────┬─────────",;
"                     Ф.И.О.                     │  Начало  │ Окончание│Стоимость",;
"                                                │  лечения │  лечения │ лечения ",;
"────────────────────────────────────────────────┴──────────┴──────────┴─────────"}
      if atip_usl[2] == PU_PLAT
        mywait()
        select TMP
        if j == 1
          index on upper(kart->fio)+str(hu->kod_k,7)+dtos(hu->k_data) to (cur_dir+"tmp")
        else
          index on dtos(hu->k_data)+upper(kart->fio) to (cur_dir+"tmp")
        endif
        fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
        add_string(center(mtitle,sh))
        add_string(center(mtitle2,sh))
        add_string("")
        aeval(arr_title, {|x| add_string(x) } )
        j := 0
        go top
        do while !eof()
          if iif(j1==1, .t., tmp->is==1)
            if verify_FF(HH,.t.,sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            add_string(padr(lstr(++j)+". "+kart->fio,48)+" "+;
                       full_date(hu->n_data)+" "+;
                       full_date(hu->k_data)+;
                       put_kop(hu->cena,10))
          endif
          select TMP
          skip
        enddo
        fclose(fp)
        close databases
        viewtext(n_file,,,,(sh>80),,,reg_print)
      elseif atip_usl[2] == PU_PR_VZ .or. atip_usl[2] == PU_D_SMO
        mywait()
        if atip_usl[2] == PU_D_SMO
          G_Use(dir_server+"p_d_smo",,"DMS")
        else
          G_Use(dir_server+"p_pr_vz",,"DMS")
        endif
        select HU
        set relation to kod_k into KART, to pr_smo into DMS
        select TMP
        if j == 1
          index on upper(dms->name)+upper(kart->fio)+dtos(hu->k_data) to (cur_dir+"tmp")
        else
          index on upper(dms->name)+dtos(hu->k_data)+upper(kart->fio) to (cur_dir+"tmp")
        endif
        fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
        add_string(center(mtitle,sh))
        add_string(center(mtitle2,sh))
        aeval(arr_title, {|x| add_string(x) } )
        old_dms := -1 ; j := 0
        go top
        do while !eof()
          if iif(j1==1, .t., tmp->is==1)
            if old_dms != hu->pr_smo
              if verify_FF(HH-4,.t.,sh)
                aeval(arr_title, {|x| add_string(x) } )
              endif
              add_string("")
              add_string(center(alltrim(upper(dms->name)),sh))
              add_string(replicate("=",sh))
              j := 0
            endif
            if verify_FF(HH,.t.,sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            add_string(padr(lstr(++j)+". "+kart->fio,48)+" "+;
                       full_date(hu->n_data)+" "+;
                       full_date(hu->k_data)+;
                       put_kop(hu->cena,10))
            old_dms := hu->pr_smo
          endif
          select TMP
          skip
        enddo
        fclose(fp)
        close databases
        viewtext(n_file,,,,(sh>80),,,reg_print)
      endif
    endif
    close databases
    G_Use(dir_server+"kartotek",,"KART")
    G_Use(dir_server+"hum_p",,"HU")
    set relation to kod_k into KART
    use (cur_dir+"tmp") new
    set relation to rec into HU
    index on upper(kart->fio)+str(hu->kod_k,7)+dtos(hu->k_data) to (cur_dir+"tmp")
    goto (tmp_rec)
    rest_box(buf)
  otherwise
    keyboard ""
endcase
return ret



//
Function f1CloseDms()
mywait()
//
dbcreate(cur_dir+"tmpk",{{"kod_k","N",7,0},;
                         {"pr_smo","N",6,0},;
                         {"summa","N",11,2},;
                         {"sum_opl","N",11,2}})
use (cur_dir+"tmpk") new
index on str(pr_smo,6)+str(kod_k,7) to (cur_dir+"tmpk")
dbcreate(cur_dir+"tmph",{{"kod","N",7,0},;
                         {"kod_k","N",7,0},;
                         {"pr_smo","N",6,0},;
                         {"k_data","D",8,0},;
                         {"date_opl","D",8,0},;
                         {"summa","N",11,2},;
                         {"sum_opl","N",11,2}})
use (cur_dir+"tmph") new
G_Use(dir_server+"hum_p",dir_server+"hum_pc","HU")
find (str(atip_usl[2],1))
do while hu->tip_usl==atip_usl[2] .and. !eof()
  select TMPH
  append blank
  tmph->kod := hu->(recno())
  tmph->kod_k := hu->kod_k
  tmph->pr_smo := hu->pr_smo
  tmph->k_data := hu->k_data
  tmph->summa := hu->cena
  if tmph->(lastrec()) % 2000 == 0
    commit
  endif
  select TMPK
  find (str(hu->pr_smo,6)+str(hu->kod_k,7))
  if !found()
    append blank
    tmpk->kod_k := hu->kod_k
    tmpk->pr_smo := hu->pr_smo
  endif
  tmpk->summa += hu->cena
  select HU
  skip
enddo
select TMPH
index on str(pr_smo,6)+str(kod_k,7)+dtos(k_data) to (cur_dir+"tmph")
select HU
set order to 0
//
G_Use(dir_server+"plat_vz",dir_server+"plat_vz","PLZ")
select TMPK
set index to
go top
do while !eof()
  ar_opl := {}
  select PLZ
  find (str(atip_usl[2],1)+str(tmpk->pr_smo,6)+str(tmpk->kod_k,7))
  do while plz->tip == atip_usl[2] .and. plz->pr_smo == tmpk->pr_smo ;
                                   .and. plz->kod_k == tmpk->kod_k .and. !eof()
    aadd(ar_opl, {plz->summa_opl,;
                  plz->date_opl})
    tmpk->sum_opl += plz->summa_opl
    select PLZ
    skip
  enddo
  if tmpk->sum_opl > 0
    asort(ar_opl,,,{|x,y| x[2] < y[2]})
    select TMPH
    find (str(tmpk->pr_smo,6)+str(tmpk->kod_k,7))
    do while tmph->pr_smo == tmpk->pr_smo .and. tmph->kod_k == tmpk->kod_k .and. !eof()
      s := tmph->summa
      do while s > 0 .and. len(ar_opl) > 0
        s := round_5(s,2)
        mopl := round_5(ar_opl[1,1],2)
        if mopl > s .or. mopl == s
          so := s   // сумма оплаты = остатку от суммы лечения
          ar_opl[1,1] -= s
          s := 0
          tmph->date_opl := max(ar_opl[1,2],tmph->k_data)
          if empty(mopl := round_5(ar_opl[1,1],2))  // на всякий случай,
            Del_Array(ar_opl,1)    // если не сработало >= (при ==)
          endif
        else
          so := mopl   // сумма оплаты = остатку от суммы платежки
          s -= mopl
          Del_Array(ar_opl,1)
        endif
        tmph->sum_opl += so
        if len(ar_opl) == 0
          exit
        endif
      enddo
      select TMPH
      skip
    enddo
    select TMPH
    find (str(tmpk->pr_smo,6)+str(tmpk->kod_k,7))
    do while tmph->pr_smo == tmpk->pr_smo .and. tmph->kod_k == tmpk->kod_k .and. !eof()
      mdate := ctod("")
      if round_5(tmph->summa,2) <= round_5(tmph->sum_opl,2)
        mdate := tmph->date_opl
      endif
      select HU
      goto (tmph->kod)
      if tmph->date_opl != hu->date_close
        G_RLock(forever)
        hu->date_close := mdate
        UnLock
      endif
      select TMPH
      skip
    enddo
  endif
  select TMPK
  if tmpk->(lastrec()) % 2000 == 0
    commit
  endif
  skip
enddo
stat_msg("Операция завершена!") ; mybell(2,OK)
return NIL


//
Function f_usl_date()
Local t_arr[BR_LEN], buf := savescreen(), blk
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := T_COL-7
t_arr[BR_RIGHT] := t_arr[BR_LEFT]+19
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := ""
t_arr[BR_TITUL_COLOR] := "W+/GR"
t_arr[BR_SEMAPHORE] := "Дата смены цен - платные услуги"
t_arr[BR_OPEN] := {|| f1_usl_date(,,"open") }
t_arr[BR_CLOSE] := {|| dbCloseAll() }
t_arr[BR_ARR_BROWSE] := {,,,"N/BG,W+/N,B/BG,BG+/B,W+/BG,N/W",.t.,300}
t_arr[BR_FL_INDEX] := .t.
t_arr[BR_FL_NOCLEAR] := .t.
t_arr[BR_COLUMN] := {{ " Дата смены цен",{|| padc(full_date(pud->data),16) }, blk }}
t_arr[BR_STAT_MSG] := {|| ;
  status_key("^<Esc>^ выход ^<Ctrl+Enter>^ услуги ^<Ins>^ добавить ^<Del>^ удалить ^<F9>^ - печать") }
t_arr[BR_EDIT] := {|nk,ob| f1_usl_date(nk,ob,"edit") }
edit_browse(t_arr)
restscreen(buf)
return NIL

//
Function f1_usl_date(nKey,oBrow,cregim)
Local ret := -1, r := row(), c := col(), buf, fl := .f., rec := 0, k := 19
do case
  case cregim == "open"
    G_Use(dir_server+"pu_date",dir_server+"pu_date","PUD")
    go top
    ret := !eof()
  case cregim == "edit"
    do case
      case nKey == K_F9
        f2_usl_date(recno())
      case nKey == K_INS
        if !fl_found
          colorwin(pr1+3,pc1,pr1+3,pc2,"N/N","W+/N")
        endif
        if !eof()
          rec := recno()
        endif
        Private mdata := sys_date, gl_area := {1,0,23,79,0}
        save screen to buf
        tmp_color := setcolor(cDataCScr)
        box_shadow(k,pc1+1,21,pc2-1,,"Добавление",cDataPgDn)
        setcolor(cDataCGet)
        @ k+1,pc1+3 say "Дата" get mdata
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. !empty(mdata) .and. f_Esc_Enter(1)
          AddRecN()
          rec := recno()
          replace data with mdata
          Unlock
          Commit
          oBrow:goTop()
          goto (rec)
        endif
        if rec == 0
          ret := 1
        else
          goto (rec)
          ret := 0
        endif
        setcolor(tmp_color)
        restore screen from buf
      case nKey == K_DEL .and. f_Esc_Enter(2,.t.)
        G_Use(dir_server+"pu_cena",{dir_server+"pu_cena",;
                                    dir_server+"pu_cenau"},"PUC")
        do while .t.
          find (str(pud->(recno()),4))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        puc->(dbCloseArea())
        select PUD
        DeleteRec()
        oBrow:goTop()
        ret := 0
        if eof()
          ret := 1
        endif
      case nKey == K_CTRL_ENTER
        f3_usl_date(recno())
        ret := 0
    endcase
endcase
@ r,c say ""
return ret



//
Function f2_usl_date(rec)
Local arr[2], s, i, k, buf := save_row(maxrow()), ;
      sh := 80, HH := 60, name_file := "pl_cena"+stxt
mywait()
fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("Список платных услуг, у которых изменилась цена "+full_date(pud->data)+"г.",sh))
add_string("")
G_Use(dir_server+"uslugi",,"USL")
G_Use(dir_server+"pu_cena",dir_server+"pu_cena","PUC")
set relation to kod_usl into USL
find (str(rec,4))
index on fsort_usl(usl->shifr) to (cur_dir+"tmp_usl") while puc->kod_date == rec
go top
do while !eof()
  s := alltrim(usl->shifr)+" "+alltrim(usl->name)+;
       " [ПлЦ="+lstr(puc->pcena,11,2)+;
       ", ПлЦД="+lstr(puc->pcena_d,11,2)+;
       ", ПлДМС="+lstr(puc->dms_cena,11,2)+"]"
  k := perenos(arr,s,sh)
  verify_FF(HH,.t.,sh)
  add_string(arr[1])
  for i := 2 to k
    add_string(padl(alltrim(arr[i]),sh))
  next
  skip
enddo
puc->(dbCloseArea())
usl->(dbCloseArea())
select PUD
rest_box(buf)
fclose(fp)
viewtext(name_file,,,,.f.,,,2)
return NIL

//
Function f3_usl_date(rec)
Local buf := savescreen(), adbf
Private fl_found, prec := rec
mywait()
G_Use(dir_server+"uslugi",dir_server+"uslugish","USL")
G_Use(dir_server+"pu_cena",{dir_server+"pu_cena",;
                            dir_server+"pu_cenau"},"PUC")
adbf := dbstruct()
aadd(adbf, {"rec_puc","N",6,0} )
aadd(adbf, {"shifr","C",10,0} )
aadd(adbf, {"name","C",64,0} )
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new alias TMP
index on shifr to (cur_dir+"tmp")
select PUC
find (str(prec,4))
if (fl_found := found())
  do while puc->kod_date == prec .and. !eof()
    select USL
    goto (puc->kod_usl)
    select TMP
    append blank
    tmp->kod_date := prec
    tmp->kod_usl  := puc->kod_usl
    tmp->pcena    := puc->pcena
    tmp->pcena_d  := puc->pcena_d
    tmp->dms_cena := puc->dms_cena
    tmp->rec_puc  := puc->(recno())
    tmp->shifr    := usl->shifr
    tmp->name     := usl->name
    select PUC
    skip
  enddo
endif
select TMP
go top
if !fl_found ; keyboard chr(K_INS) ; endif
box_shadow(0,2,0,77,"GR+/RB","Список платных услуг, у которых изменилась цена "+full_date(pud->data)+"г.",,0)
Alpha_Browse(2,1,23,77,"f4_usl_date",color0,"","BG+/GR",;
             .t.,.t.,,,"f5_usl_date",,;
             {"═","░","═","N/BG,W+/N,B/BG",.t.,58} )
puc->(dbCloseArea())
usl->(dbCloseArea())
tmp->(dbCloseArea())
select PUD
restscreen(buf)
return NIL

//
Function f4_usl_date(oBrow)
Local oColumn, n := 40
oColumn := TBColumnNew("   Шифр", {|| tmp->shifr })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(center("Наименование услуги",n), {|| left(tmp->name,n) })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Пл.цена", {|| umest_val(tmp->pcena,7,2) })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("ЦенаРеб", {|| umest_val(tmp->pcena_d,7,2) })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("ЦенаДМС", {|| umest_val(tmp->dms_cena,7,2) })
oBrow:addColumn(oColumn)
status_key("^<Esc>^ - выход;  ^<Ins>^ - добавление;  ^<Enter>^ - ред-ие цен;  ^<Del>^ - удаление")
return NIL

//
Function f5_usl_date(nKey,oBrow)
LOCAL j := 0, k := -1, buf := save_row(maxrow()), buf1, fl := .f., rec,;
      tmp_color := setcolor(), r1 := 12, c1 := 2,;
      rec_tmp := tmp->(recno()), rec_puc := tmp->rec_puc
do case
  case nKey == K_INS .or. nKey == K_ENTER
    if !fl_found .and. nKey == K_INS
      colorwin(5,0,5,79,"N/N","W+/N")
    endif
    Private mkod := iif(nKey == K_INS, 0, tmp->kod_usl),;
            mname := iif(nKey == K_INS, space(60), tmp->name),;
            mshifr := iif(nKey == K_INS, space(10), tmp->shifr),;
            mpcena := iif(nKey == K_INS, 0, tmp->pcena),;
            mpcena_d := iif(nKey == K_INS, 0, tmp->pcena_d),;
            mdms_cena := iif(nKey == K_INS, 0, tmp->dms_cena),;
            gl_area := {1,0,23,79,0}
    buf1 := box_shadow(r1,c1,21,76,color8,;
             "Добавление новой услуги в список",cDataPgDn)
    setcolor(cDataCGet)
    @ r1+2,pc1+3 say "Шифр услуги" get mshifr picture "@!" ;
                 valid f6_usl_date() when (nKey == K_INS)
    @ r1+3,pc1+3 say "Наименование услуги"
    @ r1+4,pc1+5 get mname when .f.
    @ r1+5,pc1+3 say "Цена платной услуги" get mpcena pict pict_cena
    @ r1+6,pc1+3 say "Цена платной услуги для ребека" get mpcena_d pict pict_cena
    @ r1+7,pc1+3 say "Цена ДМС услуги" get mdms_cena pict pict_cena
    status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
    myread()
    if lastkey() != K_ESC .and. mkod > 0 .and. f_Esc_Enter(1)
      mywait()
      select PUC
      if nKey == K_INS
        AddRec(4)
        fl_found := .t.
        puc->kod_date := prec
        puc->kod_usl  := mkod
      else
        goto (rec_puc)
        G_RLock(forever)
      endif
      puc->pcena    := mpcena
      puc->pcena_d  := mpcena_d
      puc->dms_cena := mdms_cena
      UNLOCK
      rec_puc := puc->(recno())
      select TMP
      if nKey == K_INS
        append blank
        rec_tmp := tmp->(recno())
        tmp->kod_date := prec
        tmp->kod_usl  := mkod
        tmp->shifr    := mshifr
        tmp->name     := mname
        tmp->rec_puc  := puc->(recno())
      endif
      tmp->pcena    := mpcena
      tmp->pcena_d  := mpcena_d
      tmp->dms_cena := mdms_cena
      COMMIT
      k := 0
    elseif !fl_found
      k := 1
    endif
    select TMP
    oBrow:goTop()
    goto (rec_tmp)
    setcolor(tmp_color)
    rest_box(buf) ; rest_box(buf1)
  case nKey == K_DEL .and. tmp->kod_usl > 0 .and. f_Esc_Enter(2)
    mywait()
    select PUC
    goto (tmp->rec_puc)
    DeleteRec(.t.)
    select TMP
    DeleteRec(.t.)
    COMMIT
    k := 0
    select TMP
    oBrow:goTop()
    go top
    if eof()
      fl_found := .f. ; k := 1
    endif
    rest_box(buf)
  otherwise
    keyboard ""
endcase
return k

//
Function f6_usl_date()
Local fl := valid_shifr(), rec, ar
if fl
  select TMP
  rec := recno()
  find (mshifr)
  if found()
    fl := func_error(4,"Вы повторно вводите данную услугу!")
  endif
  goto (rec)
  if fl
    select USL
    find (mshifr)
    if found()
      mkod := usl->kod
      mname := usl->name
      ar := CenaUslDate(pud->data-1,mkod)
      mpcena    := ar[1]
      mpcena_d  := ar[2]
      mdms_cena := ar[3]
      update_gets()
    else
      fl := func_error(4,"Нет такого шифра в базе данных услуг!")
    endif
  endif
endif
return fl






// 28.03.23
Function vozvrat_platn(kod_human)
Local buf := savescreen(), sotgr, str_sem, s, arr_v := {}, arr_p := {},;
      s_msg, mtitle, m1title := "", fl, tmp_s, i_m_otv := 0, j := 0,;
      eval_box := {|_c,_s| box_shadow(2,9,2,70,_c,_s,,0) }, ln_chek := 0,;
      sum_bank, sum_nal, sum_itog, tip_banka
Private rec_rashod, reg_otgruz := 1,;
        p_otgr_p_gr := 0, a_uch_1, a_uch_2,;
        summa_oplat := 0, summa_oplat_bn := 0
Private mkol1 := 0, p_summa := 0, old_summa := 0, p1_summa := 0

        //
mtitle := 'Возврат услуг'
restscreen(buf)
//

if human->cena <= human->sum_voz
  return func_error(4,' Уже все вернули !')
endif
//
summa_oplat := (human->cena - human->sum_voz)
summa_oplat_bn := human->sbank
tip_banka := human->fr_tipkart
//human->(dbCloseArea())
//
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
adbf := dbstruct()
aadd(adbf, {"date_u1","D",  8,0} )
aadd(adbf, {"shifr_u","C", 10,0} )
aadd(adbf, {"name_u", "C",128,0} )
aadd(adbf, {"is_nul", "L",  1,0} )
aadd(adbf, {"summa1", "N",  9,3} )
aadd(adbf, {"summa2", "N",  9,3} )
aadd(adbf, {"vz_cena","N",  9,3} )
aadd(adbf, {"kol1",   "N",  5,0} )
aadd(adbf, {"number", "N",  6,0} )
aadd(adbf, {"rec_hu", "N",  7,0} )
aadd(adbf, {"nds20",  "N",  1,0} )
aadd(adbf,  {"nds18", "N",  1,0} )
aadd(adbf,  {"nds10", "N",  1,0} )
//
dbcreate(cur_dir+"tmp_usl",adbf)
use (cur_dir+"tmp_usl") new alias tmp
index on str(u_kod,4)+str(kod_vr,4)+date_u to (cur_dir+"tmp1usl")
select HU
set relation to u_kod into USL
find (str(kod_human,7))
if (fl_found := found())
  adbf := array(fcount())
  cls
  do while hu->kod == kod_human .and. !eof()
    aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
    select TMP
    find (str(hu->u_kod,4)+str(hu->kod_vr,4)+hu->date_u)
    if found()
      tmp->kol     := tmp->kol  + hu->kol
      tmp->kol1    := tmp->kol1 + hu->kol
      tmp->summa1  := tmp->summa1 + hu->stoim
      tmp->summa2  := tmp->summa1
      tmp->vz_cena := round_5(tmp->summa1/tmp->kol,2)
    else
      append blank
      aeval(adbf, {|x,i| fieldput(i,x) } )
      tmp->date_u1  := c4tod(hu->date_u)
      tmp->shifr_u  := usl->shifr
      if len(alltrim(usl->full_name)) > 3
        tmp->name_u := alltrim(usl->shifr)+" "+alltrim(usl->full_name)
      else
        tmp->name_u := alltrim(usl->shifr)+" "+alltrim(usl->name)
      endif
      if round_5(usl->pnds,2) > 0
        if round_5(usl->pnds,0) == 18
          tmp->nds18 := 1
        elseif round_5(usl->pnds,0) == 20
          tmp->nds20 := 1
        elseif round_5(usl->pnds,0) == 10
          tmp->nds10 := 1
        endif
      endif
      tmp->is_nul   := usl->is_nulp
      tmp->rec_hu   := hu->(recno())
      tmp->kol1     := hu->kol
      tmp->summa1   := tmp->stoim
      tmp->vz_cena  := round_5(tmp->summa1/tmp->kol1,2)
    endif
    select HU
    skip
  enddo
endif
select TMP
if mem_ordusl == 1
  index on dtos(date_u1)+fsort_usl(shifr_u) to (cur_dir+"tmp_usl")
else
  index on fsort_usl(shifr_u)+dtos(date_u1) to (cur_dir+"tmp_usl")
endif
tmp->(dbeval({|| tmp->number := ++j } ) )
hu->(dbCloseArea())
usl->(dbCloseArea())
// удаление пред-х возвратов
p_summa := summa_oplat
//
select TMP
go top
box_shadow(3,4,20,75,color1,mtitle,color8,0)
Alpha_Browse(5,7,20,72,"f1v_vozvrat",color0,m1title,"BG+/GR",;
             .t.,.t.,,,"f2v_vozvrat",,;
             {"═","░","═","N/BG,W+/N,B/BG,W+/B,R/BG,R/B",.t.,180,"*+"} )
if f_Esc_Enter("возврата",.t.)
  // вначале возвращаем наличку
  if p_summa <= (summa_oplat - summa_oplat_bn)
    sum_bank  := 0
    tip_banka := 0
    sum_nal   := p_summa
  else
    sum_nal   := summa_oplat - summa_oplat_bn
    sum_bank  := p_summa - sum_nal
  endif
// корректировка
if sum_nal < 0 .and. sum_bank > 0
   // были предыдущие возвраты
  sum_nal := 0
  sum_bank := p_summa
endif
  fl := vozvrat_fr(sum_nal,sum_bank,@ln_chek,1,tip_banka)
  // сам чек
  if fl
    // заносим возврат
    G_Use(dir_server+"hum_p_u",{dir_server+"hum_p_u",;
                                dir_server+"hum_p_uk",;
                                dir_server+"hum_p_ud",;
                                dir_server+"hum_p_uv",;
                                dir_server+"hum_p_ua"},"HU")
    select TMP
    go top
    do while !eof()
      select TMP
      if tmp->kol1 > 0
        aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
        select HU
        append blank
        aeval(adbf, {|x,i| fieldput(i,x) } )
        hu->kol   := tmp->kol1 * (-1)
        hu->stoim := tmp->summa1 * (-1)
      endif
      select TMP
      skip
    enddo
    hu->(dbCloseArea())
    select HUMAN
    G_RLock(forever)
    replace human->date_voz with dtoc4(date()), human->sum_voz with (p_summa+human->sum_voz) 
    UnLock
    human->(dbCommit())
    stat_msg("Сумма возврата записана!") ; mybell(1,OK)
    is_choice := .f.
    //s := K_END + K_ENTER
    //keysend(s)
  endif
endif
tmp->(dbCloseArea())
restscreen(buf)
return NIL

//  10.09.18
Function f1v_vozvrat(oBrow)
Local n, oColumn, blk := {|| if(tmp->kol1 > 0, {3,4}, {5,6} ) }
//
oColumn := TBColumnNew(" NN; пп",{|| str(tmp->number,3) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("   Шифр;  услуги",{|| tmp->shifr_u })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Врач",{|| put_val(ret_tabn(tmp->kod_vr),5) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Асс.",{|| put_val(ret_tabn(tmp->kod_as),5) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Ко-;лич.;усл.",{|| tmp->kol })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" Общая; стоимость; услуги",{|| put_kop(tmp->stoim,10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Вернуть;кол-во",{|| put_val_0(tmp->kol1,5,0) })
oColumn:defColor := {5,5}
oColumn:colorBlock := {|| if(tmp->kol1 > 0, {3,4}, {5,6}) }
oBrow:addColumn(oColumn)
//
status_key("^<Esc>^ - выход для записи;  ^<Enter>^ - редактирование количества;")
return NIL


// 10.09.18
Function f2v_vozvrat(nKey,oBrow)
Local j := 0, flag := -1, buf := save_row(24), buf1, fl := .f., t_rec,;
      nr := row(), c1, rec, mkod, buf0, tmp_color := setcolor(), ;
      blk := {|| devpos(1,2), devout(padc("Услуг к возврату"+;
              " на сумму - "+lput_kop(p_summa,.t.)+" руб.",72),"W/B") }
old_summa := 0
t_rec := recno()
go top
do while !eof()
  //old_summa += round(tmp->u_cena * tmp->kol1, 2)
  old_summa += round(tmp->vz_cena * tmp->kol1, 2)
  //old_summa += round_5(round_5(tmp->summa2/tmp->kol,2) * tmp->kol1, 2)
  skip
enddo
eval(blk)
goto t_rec
do case
  case nKey == K_ESC
    setcolor(tmp_color) ; flag := 1
  case nKey == K_ENTER
    setcolor("GR+/RB,GR+/RB,,,G+/RB")
    old_kol := mkol1 := tmp->kol1
    c1 :=  58
    @ nr,c1 get mkol1 pict "99999" valid {|g|f3v_vozvrat(g)}
    myread()
    if lastkey() != K_ESC
      //p1_summa := round(tmp->u_cena * tmp->kol1, 2)
      p1_summa := round(tmp->vz_cena * tmp->kol1, 2)
      //p1_summa += round((tmp->summa2/tmp->kol) * (tmp->kol1- mkol1), 2)
      p_summa  := old_summa - p1_summa
      //tmp->summa1 := round_5(tmp->u_cena * mkol1, 2)
      tmp->summa1 := round_5(tmp->vz_cena * mkol1, 2)

      p_summa :=  p_summa + tmp->summa1
      tmp->kol1   := mkol1
      tmp->stoim  := tmp->summa1
      //keyboard chr(K_ESC)
    endif
    //
    eval(blk)
    //
    setcolor(tmp_color) ; flag := 0
  otherwise
    keyboard ""
endcase
return flag


//
Function f3v_vozvrat(get)
Local lkol1
Private mvar := readvar()
if &mvar < 0 .and. lastkey() != K_UP
  &mvar := get:original
  return func_error(3,"Ошибка! Данное значение не может быть меньше нуля.")
endif
if !(round_5(mkol1,3) == round_5(get:original,3))
  if mkol1 > tmp->kol
    &mvar := get:original
    return func_error(3,"Ошибка! Возвращаемое количество услуг не может превышать фактическое.")
  endif
endif
return .t.
