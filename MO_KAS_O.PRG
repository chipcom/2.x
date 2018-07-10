*******************************************************************************
* mo_kas_o.prg - ортопедия в задаче "Касса"
*******************************************************************************
* 29.09.15 f_ort_nar()
*          f2_kas_ort(oBrow)
*          sum_tmphum()
*          f3_kas_ort(nKey,oBrow)
* 11.05.14 f4_kas_ort(rec,tmprec)
*          fe_ko_kusl(oBrow)
*          f3e_ko_kusl()
*          f2e_ko_kusl(nKey,oBrow)
*          f_glob_nar()
*          ret_ort_nar()
* 11.05.14 yes_o_chek(/*@*/vsum,/*@*/vsd,/*@*/s,/*@*/v_bank)
*          f41_kas_ort(par)
*          f42_kas_ort()
*          prn_kas_ort(lnomer_n,fl_hu)
*******************************************************************************
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

*

#define _KO_K_OPL      6  // итого к оплате по всему наряду
#define _KO_OPL        7  // уже оплачено
#define _KO_DOPL       8  // доплатить
#define _KO_SUMMA      9  // платная сумма наряда
#define _KO_O_SUMMA   10  // общая сумма за день
#define _KO_CENA      11  // сумма оплаты
#define _KO_SUMMA_NAR 12  // общая сумма наряда
#define _KO_LEN       12

Static enter_1 := 0

***** 03.07.18
Function f_ort_nar()
Local buf, str_sem, fl
Parameters par
// par = 1 - открытие наряда
// par = 2 - редактирование наряда
if  mek_kassa == 1 //.and. mek_nkassa == 1
  Private drvFR
  IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    //
  else
    return func_error(4,"Ошибка запуска драйвера КАССЫ")
  endif
endif

if par == 1
  fl := (polikl1_kart() > 0)
else
  if enter_1 > 0
    fl := .t.
  else
    fl := ret_ort_nar()
  endif
endif
if fl
  str_sem := "KASSA - Редактирование человека "+lstr(glob_kartotek)
  if !G_SLock(str_sem)
    return func_error(4,err_slock)
  endif
  buf := savescreen()
  use_base("kas_ort","HUMAN")
  Private adbf := dbstruct()
  aadd(adbf, {"rec_hum","N",7,0})
  dbcreate(cur_dir+"tmphum",adbf)
  use (cur_dir+"tmphum") new
  index on iif(tip_n>0,"1","2")+dtos(k_data) to (cur_dir+"tmphum")
  if par == 2
    select HUMAN
    adbf := array(fcount())
    set order to 4
    find (str(glob_nar[6],4)+str(glob_nar[1],6))
    do while human->year_n==glob_nar[6] .and. human->nomer_n==glob_nar[1] .and. !eof()
      aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
      select TMPHUM
      append blank
      aeval(adbf, {|x,i| fieldput(i,x) } )
      tmphum->rec_hum := human->(recno())
      select HUMAN
      skip
    enddo
    select TMPHUM
    go top
  endif
  close databases
  Private bOrt_open := ;
          {|| R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO"),;
              use_base("kas_ort","HUMAN"),;
              G_Use(cur_dir+"tmphum",cur_dir+"tmphum",,.t.,.t.), dbGoTop() }
  eval(bOrt_open)
  if par == 1
    f3_kas_ort(K_INS)
    if enter_1 > 0
      keyboard chr(K_TAB)+chr(K_ENTER)
    endif
  else
    mtitle := glob_k_fio+", наряд № "+lstr(glob_nar[1])+"/"+lstr(glob_nar[6])
    Alpha_Browse(T_ROW,2,maxrow()-2,77,"f2_kas_ort",color0,mtitle,"BG+/GR",;
                 .f.,.t.,,,"f3_kas_ort",,;
                 {"═","░","═","N/BG,W+/N,B/BG,BG+/B,N+/BG,W/N",.t.,180} )
    enter_1 := 0
  endif
  close databases
  restscreen(buf)
  G_SUnLock(str_sem)
endif
return NIL

*****
Function f2_kas_ort(oBrow)
Local oColumn, blk := {|| iif(tmphum->tip_n==2, {3,4}, iif(tmphum->tip_n==1, {1,2}, {5,6})) }
Local tip_bank := {"бн","МИ","VI","MC"}

oColumn := TBColumnNew("Тип",{|| {"   ","сл.","пр."}[tmphum->tip_n+1] })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Вид наряда ",{|| inieditspr(A__MENUVERT,mm_kas_vid,tmphum->vid) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" № наряда",{|| padr(lstr(tmphum->nomer_n)+"/"+lstr(tmphum->year_n),9) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Дата оплаты", {|| full_date(tmphum->k_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
//oColumn := TBColumnNew(" № чека",{|| iif(tmphum->sbank > 0, "бн"+put_val(tmphum->n_chek,6), put_val(tmphum->n_chek,8)) })
//
oColumn := TBColumnNew(" № чека",{|| iif(tmphum->sbank > 0,;
tip_bank[tmphum->fr_tipkart+1]+iif(tmphum->sbank == tmphum->cena," ","Н")+put_val(tmphum->n_chek,5),;
put_val(tmphum->n_chek,8)) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Сумма чека", {|| put_kop(tmphum->cena,10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Сумма пл.услуг", {|| put_kop(tmphum->summa,10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
status_key("^<Esc>^ выход;  ^<Enter>^ ред-ие полей;  ^<Ins>^ редактировать наряд;  ^<F9>^ печать")
sum_tmphum()
return NIL

*****
Function sum_tmphum()
Local s1 := 0, s2 := 0, rec := tmphum->(recno())
go top
do while !eof()
  s1 += tmphum->cena
  s2 += tmphum->summa
  skip
enddo
goto (rec)
@ 23,51 say put_kop(s1,10) color "W/N"
@ 23,62 say put_kop(s2,10) color "W/N"
return NIL

*

*****
Function f3_kas_ort(nKey,oBrow)
LOCAL j := 0, flag := -1, buf := save_row(maxrow()), buf1, fl := .f., rec, mkod,;
      tmp_color := setcolor(), r1 := 13, c1 := 2, v_summa, v_sdacha, adbf, s,;
      i, path_exe, str_sem
Private ldate_voz, lsum_voz
do case
  case nKey == K_F9 .and. !empty(tmphum->nomer_n)
    prn_kas_ort(tmphum->nomer_n,.f.)
  case nKey == K_INS .and. par == 1
    str_sem := "KASSA - Добавление ортопедического наряда"
    if !G_SLock(str_sem)
      return func_error(4,err_slock)
    endif
    enter_1 := 0
    Private mvid := space(10), m1vid := 2,;
            mtip_n := space(10), m1tip_n := 1,;
            mnomer_n := ret_last_N(),;
            mkod_vr := 0, mtabn_vr := 0, mvrach := space(35),;
            mkod_tex := 0, mtabn_tex := 0, mtexnik := space(35),;
            gl_area := {1,0,23,79,0}
    mvid := inieditspr(A__MENUVERT,mm_kas_vid,m1vid)
    mtip_n := inieditspr(A__MENUVERT,mm_kas_tip,m1tip_n)
    buf1 := box_shadow(r1,c1,23,77,color8,;
                       "Добавление нового наряда",cDataPgDn)
    setcolor(cDataCGet)
    do while .t.
      @ r1+2,c1+3 say "Номер наряда" get mnomer_n pict "999999" when .f.
      @ r1+3,c1+3 say "Тип наряда" get mtip_n ;
            reader {|x|menu_reader(x,mm_kas_tip,A__MENUVERT,,,.f.)}
      @ r1+4,c1+3 say "Вид наряда" get mvid ;
            reader {|x|menu_reader(x,mm_kas_vid,A__MENUVERT,,,.f.)}
      @ r1+5,c1+3 say "Таб.№ врача" get mtabn_vr pict "99999" ;
                  valid {|g| f5e_kp_kusl(g,2,3) }
      @ row(),col()+3 get mvrach when .f. color color14
      @ r1+6,c1+3 say "Таб.№ техника" get mtabn_tex pict "99999" ;
                  valid {|g| f5e_kp_kusl(g,2,4) }
      @ row(),col()+3 get mtexnik when .f. color color14
      status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение записи")
      myread()
      if lastkey() != K_ESC .and. f_Esc_Enter(1)
        if emptyany(m1tip_n,m1vid,mkod_vr)
          func_error(4,"Введены не все данные!")
          loop
        endif
        select TMPHUM
        append blank
        tmphum->vid := m1vid
        tmphum->tip_n := m1tip_n
        tmphum->KOD_K := glob_kartotek
        tmphum->NOMER_N := mnomer_n
        tmphum->year_n := year(sys_date)
        tmphum->N_CHEK := 0
        tmphum->SMENA := glob_smena
        tmphum->k_data := sys_date
        tmphum->kod_vr := mkod_vr
        tmphum->kod_tex := mkod_tex
        tmphum->CENA := tmphum->SUMMA := tmphum->O_SUMMA := tmphum->sbank := 0
        tmphum->KOD_OPER := asc(kod_polzovat)
        //
        select HUMAN
        AddRec(7)
        human->vid := m1vid
        human->tip_n := m1tip_n
        human->KOD_K := glob_kartotek
        human->NOMER_N := mnomer_n
        human->year_n := year(sys_date)
        human->N_CHEK := 0
        human->SMENA := glob_smena
        human->k_data := sys_date
        human->kod_vr := mkod_vr
        human->kod_tex := mkod_tex
        human->CENA := human->SUMMA := human->O_SUMMA := human->sbank := 0
        human->KOD_OPER := asc(kod_polzovat)
        Commit
        UnLock
        rec := human->(recno())
        tmphum->rec_hum := rec
        rectmp := tmphum->(recno())
        glob_nar := f_glob_nar()
        if f4_kas_ort(rec,rectmp)  // запись чека
          flag := 0
          enter_1 := glob_nar[2]
        else
          // если не подтвердили чек - удаляем запись из БД human
          use_base("kas_ortu","HU")
          do while .t.
            find (str(rec,7))
            if !found() ; exit ; endif
            DeleteRec(.t.)
          enddo
          hu->(dbCloseArea())
          select HUMAN
          goto (rec)
          DeleteRec()
          flag := 1
        endif
      endif
      exit
    enddo
    rest_box(buf)
    rest_box(buf1)
    G_SUnLock(str_sem)
  case nKey == K_ENTER .and. par == 2 .and. tmphum->tip_n > 0
    Private mvid, m1vid := tmphum->vid,;
            mtip_n, m1tip_n := tmphum->tip_n,;
            mnomer_n := tmphum->NOMER_N,;
            mkod_vr := tmphum->kod_vr, mtabn_vr, mvrach := space(35),;
            mkod_tex := tmphum->kod_tex, mtabn_tex, mtexnik := space(35),;
            gl_area := {1,0,23,79,0}
    if mkod_vr > 0
      select PERSO
      goto (mkod_vr)
      if !eof() .and. !deleted()
        mvrach := padr(perso->fio,35)
        mtabn_vr := perso->tab_nom
      endif
    endif
    if mkod_tex > 0
      select PERSO
      goto (mkod_tex)
      if !eof() .and. !deleted()
        mtexnik := padr(perso->fio,35)
        mtabn_tex := perso->tab_nom
      endif
    endif
    mvid := inieditspr(A__MENUVERT,mm_kas_vid,m1vid)
    mtip_n := inieditspr(A__MENUVERT,mm_kas_tip,m1tip_n)
    buf1 := box_shadow(r1,c1,23,77,color8,;
                       "Редактирование полей в наряде",cDataPgDn)
    setcolor(cDataCGet)
    do while .t.
      @ r1+2,c1+3 say "Номер наряда" get mnomer_n pict "999999" when .f.
      @ r1+3,c1+3 say "Тип наряда" get mtip_n ;
            reader {|x|menu_reader(x,mm_kas_tip,A__MENUVERT,,,.f.)}
      @ r1+4,c1+3 say "Вид наряда" get mvid ;
            reader {|x|menu_reader(x,mm_kas_vid,A__MENUVERT,,,.f.)}
      @ r1+5,c1+3 say "Таб.№ врача" get mtabn_vr pict "99999" ;
                  valid {|g| f5e_kp_kusl(g,2,3) }
      @ row(),col()+3 get mvrach when .f. color color14
      @ r1+6,c1+3 say "Таб.№ техника" get mtabn_tex pict "99999" ;
                  valid {|g| f5e_kp_kusl(g,2,4) }
      @ row(),col()+3 get mtexnik when .f. color color14
      status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение записи")
      myread()
      if lastkey() != K_ESC .and. f_Esc_Enter(1)
        if emptyany(m1tip_n,m1vid,mkod_vr)
          func_error(4,"Введены не все данные!")
          loop
        endif
        select TMPHUM
        tmphum->vid := m1vid
        tmphum->tip_n := m1tip_n
        tmphum->kod_vr := mkod_vr
        tmphum->kod_tex := mkod_tex
        //
        select HUMAN
        goto (tmphum->rec_hum)
        G_RLock(forever)
        human->vid := m1vid
        human->tip_n := m1tip_n
        human->kod_vr := mkod_vr
        human->kod_tex := mkod_tex
        Commit
        UnLock
        flag := 0
      endif
      exit
    enddo
    rest_box(buf)
    rest_box(buf1)
    select TMPHUM
  case nKey == K_INS .and. par == 2
    select TMPHUM
    append blank
    tmphum->vid := glob_nar[4]
    tmphum->tip_n := 0
    tmphum->KOD_K := glob_kartotek
    tmphum->NOMER_N := glob_nar[1]
    tmphum->year_n := glob_nar[6]
    tmphum->N_CHEK := 0
    tmphum->SMENA := glob_smena
    tmphum->k_data := sys_date
    tmphum->CENA := tmphum->SUMMA := tmphum->O_SUMMA := tmphum->sbank := 0
    tmphum->KOD_OPER := asc(kod_polzovat)
    //
    select HUMAN
    AddRec(7)
    human->vid := glob_nar[4]
    human->tip_n := 0
    human->KOD_K := glob_kartotek
    human->NOMER_N := glob_nar[1]
    human->year_n := glob_nar[6]
    human->N_CHEK := 0
    human->SMENA := glob_smena
    human->k_data := sys_date
    human->CENA := human->SUMMA := human->O_SUMMA := human->sbank := 0
    human->KOD_OPER := asc(kod_polzovat)
    rec := human->(recno())
    tmphum->rec_hum := rec
    Commit
    UnLock
    rectmp := tmphum->(recno())
    if f4_kas_ort(rec,rectmp)  // запись чека
      select TMPHUM
    else
      use_base("kas_ortu","HU")
      do while .t.
        find (str(rec,7))
        if !found() ; exit ; endif
        DeleteRec(.t.)
      enddo
      hu->(dbCloseArea())
      select HUMAN
      goto (rec)
      DeleteRec(.t.)
      select TMPHUM
      DeleteRec()
      go top
    endif
    sum_tmphum()
    flag := 0
  case nKey == K_DEL .and. tmphum->KOD_K > 0 .and. tmphum->N_CHEK==0 .and. f_Esc_Enter(2)
    rec := tmphum->rec_hum
    human->(dbGoto(rec))
    use_base("kas_ortu","HU")
    do while .t.
      find (str(rec,7))
      if !found() ; exit ; endif
      DeleteRec(.t.)
    enddo
    hu->(dbCloseArea())
    select HUMAN
    goto (rec)
    DeleteRec(.t.)
    select TMPHUM
    DeleteRec()
    flag := 1
  otherwise
    keyboard ""
endcase
return flag

*

***** 05.08.16
Function f4_kas_ort(rec,tmprec)
Local fl := .f., adbf, buf := savescreen(), tmp_color := setcolor(color1), ;
      j, l_color, mtitle, arr, ln_chek := 0,;
      mi_post, mphone_m, maddress, tip_kart := 2,;
      fr_zavodnomer := ""
Private fl_found := .f., mcena[_KO_LEN], pvid := human->vid, p_opl := 0
Private arr_opl := {}
afill(mcena,0)



// 00.07.17 поиск номера или э.почты.
/*t_hum_rec := ho->(recno())
kart_kod  := human->kod_k
hum_o_kod := human->(recno())
*/
mi_post   := space(30)
mphone_m  := space(11)
/*
t_select := select()
select HO
do while ho->kod == hum_o_kod  .and. !eof()
  if len(alltrim(ho->i_post)) > 4
    mi_post := ho->i_post
  endif
  skip
enddo
goto (t_hum_rec)*/
//выбираем приоритетом телефон
//select(t_select)


R_Use(dir_server+"kartotek",,"KART")
goto (glob_kartotek)
Private smvzros_reb := kart->vzros_reb
kart->(dbCloseArea())
// поиск телефона
R_Use(dir_server+"kartote_",,"KR_") //00.07.17
goto(glob_kartotek)
mphone_m := kr_->phone_m
kr_->(dbCloseArea())
mphone_m := TransformPhone( mphone_m )
if len(alltrim(mphone_m)) < 11
  maddress := mi_post
else
  maddress := mphone_m
endif
//
G_Use(dir_server+"kas_usl",,"KU")
index on str(u_kod,4) to (cur_dir+"tmp_ku")
f41_kas_ort(1)
if par == 2
  f42_kas_ort()
endif
R_Use(dir_server+"pu_date",dir_server+"pu_date","PUD")
R_Use(dir_server+"pu_cena",{dir_server+"pu_cena",;
                            dir_server+"pu_cenau"},"PUC")
cls
pr_1_str("Ввод ортопед.услуг для больного < "+alltrim(glob_k_fio)+" >")
l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"
mtitle := "Наряд № "+lstr(human->nomer_n)+", дата оплаты: "+full_date(human->k_data)+"г."
Private flag_1 := .t.
do while .t.
  select TMP
  go top
  if lastrec() == 0
    keyboard chr(K_INS)
  endif
  summa_usl(@mcena)
  f3e_ko_kusl()
  Alpha_Browse(2,0,18,79,"fe_ko_kusl",color1,mtitle,col_tit_popup,;
               .f.,.t.,,,"f2e_ko_kusl",,;
               {"═","░","═",l_color,.t.,180} )
  summa_usl(@mcena)
  if emptyall(mcena[_KO_O_SUMMA],mcena[_KO_DOPL])
    j := 1
  else
    arr := {" Выход без записи "," Печать чека "," Возврат в редактирование "}
    if empty(mcena[_KO_DOPL])
      arr[2] := " Запись "
    endif
    j := f_alert({padc("Выберите действие",60,".")},arr,;
                 2,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
  endif
  if j == 1
    exit
  elseif j == 2
    tmp->(dbCloseArea())
    fl := .f.
    if empty(mcena[_KO_DOPL])
      fl := .t.
      ln_chek := -1
    else
      Private p_summa := mcena[_KO_DOPL], fl_sdacha := .f.
      v_summa := v_sdacha := v_bank := 0
      if yes_o_chek(@v_summa,@v_sdacha,@mcena,@v_bank,,@maddress,@tip_kart)
        adbf := {{"name", "C",128,0},;  //00.01.18
                 {"vrach","C", 40,0},;
                 {"cena", "N", 10,2},;
                 {"kol",  "N",  4,0},;
                 {"nds18","N",  1,0},; //10.08.08
                 {"nds10","N",  1,0}}
        dbcreate(cur_dir+"tmp",adbf)
        use (cur_dir+"tmp") new
        append blank
        tmp->name := "Наряд номер "+lstr(human->nomer_n)
        tmp->cena := mcena[_KO_CENA]
        tmp->kol := 1
        if chek_fr(v_summa,v_sdacha,@ln_chek,v_bank,,@fr_zavodnomer,maddress,tip_kart)
        //if (ln_chek := human->(recno())) > 0
          fl := .t.
        endif
        tmp->(dbCloseArea())
//mywait("Печатается чек...")
//inkey(5)  // пока так
      endif
    endif
    if fl
      select HUMAN
      goto (rec)
      G_RLock(forever)
      human->N_CHEK := ln_chek
      human->cena := mcena[_KO_CENA]
      human->summa := mcena[_KO_SUMMA]
      human->o_summa := mcena[_KO_O_SUMMA]
      human->sbank := v_bank
      human->FR_zavod := fr_zavodnomer
      human->FR_tipkart := tip_kart
      human->fr_tip     := 2
      UnLock
      select TMPHUM
      goto (tmprec)
      tmphum->N_CHEK := ln_chek
      tmphum->cena := mcena[_KO_CENA]
      tmphum->summa := mcena[_KO_SUMMA]
      tmphum->o_summa := mcena[_KO_O_SUMMA]
      tmphum->sbank := v_bank
      tmphum->FR_tipkart := tip_kart
      tmphum->fr_tip     := 2
      Commit
    endif
    use (cur_dir+"tmp_usl") new alias tmp
    restscreen(buf)
    exit
  elseif j == 3
    loop
  endif
enddo
tmp->(dbCloseArea())
usl->(dbCloseArea())
puc->(dbCloseArea())
pud->(dbCloseArea())
ku->(dbCloseArea())
hu->(dbCloseArea())
select TMPHUM
setcolor(tmp_color)
restscreen(buf)
return fl

*****
Function fe_ko_kusl(oBrow)
Local oColumn, blk_color := {|| iif(tmp->is==1, {3,4}, {1,2}) }
//
oColumn := TBColumnNew("Вид услуги",{|| padr(inieditspr(A__MENUVERT,mm_kas_vid,tmp->vid),11) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Дата;опла-;ты", {|| left(full_date(tmp->k_data),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("   Шифр;  услуги",{|| tmp->shifr_u })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Наименование;  услуги",{|| left(tmp->name_u,20) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Ко-;лич.;усл.",{|| tmp->kol })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("   Цена;  услуги",{|| put_kop(tmp->u_cena,10) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Общая; стоимость; услуги",{|| put_kop(tmp->stoim,10) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
status_key("^<Esc>^ выход ^<Enter>^ ред-ие ^<Ins>^ добавление ^<Del>^ удаление ^<F9>^ печать")
return NIL

*

*****
Function f3e_ko_kusl()
Static arr := {{"И_Т_О_Г_О сумма наряда",_KO_SUMMA_NAR},;
               {"итого сумма за ",_KO_O_SUMMA},;
               {"итого к оплате",_KO_K_OPL},;
               {"оплачено",_KO_OPL},;
               {"доплатить",_KO_DOPL}}
Static scolor := "W/B", scolor1 := "G/B", scolor2 := "G+/B", si := 0
Local i, j
if si == 0
  si := 1
  arr[2,1] += left(dtoc(sys_date),5)
endif
for i := 1 to 5
  @ 18+i,0 say space(80) color scolor
  j := arr[i,2]
  @ 18+i,10 say padl(arr[i,1],22) color scolor
  @ row(),col() say str(mcena[j],11,2) color iif(empty(mcena[j]),scolor1,scolor2)
  j := i
  @ 18+i,54 say padl(mm_kas_vid[i,1],13) color scolor
  @ row(),col() say str(mcena[j],11,2) color iif(empty(mcena[j]),scolor1,scolor2)
next
return NIL

*****
Function f2e_ko_kusl(nKey,oBrow)
LOCAL flag := -1, buf := savescreen(), fl := .f., rec, ;
      i1, k, j := 0, s := 0, so := 0, adbf, adbf1, tmp_color := setcolor(), ;
      rec_tmp := tmp->(recno()), mrec_hu := tmp->rec_hu
Private r1 := 13
do case
  case nKey == K_F9
    prn_kas_ort(human->nomer_n,.t.)
    R_Use(dir_server+"pu_date",dir_server+"pu_date","PUD")
    R_Use(dir_server+"pu_cena",{dir_server+"pu_cena",;
                                dir_server+"pu_cenau"},"PUC")
    use_base("kas_ortu","HU")
    G_Use(dir_server+"kas_usl",cur_dir+"tmp_ku","KU")
    R_Use(dir_server+"uslugi",dir_server+"uslugish","USL")
    use (cur_dir+"tmp_usl") new index (cur_dir+"tmp_usl") alias tmp
    goto (rec_tmp)
  case nKey == K_INS .or. (nKey == K_ENTER .and. tmp->rec_hu > 0 .and. tmp->is==0)
    chm_help_code := 1//HM_Edit1_kart
    if nKey == K_INS .and. !fl_found
      colorwin(7,0,7,79,"B/B","W+/RB")
    endif
    Private mu_kod := if(nKey == K_INS, 0, tmp->u_kod),;
            mu_cena := if(nKey == K_INS, 0, tmp->u_cena),;
            mkol := if(nKey == K_INS, 0, tmp->kol),;
            mstoim := if(nKey == K_INS, 0, tmp->stoim),;
            mshifr := if(nKey == K_INS, space(10), tmp->shifr_u),;
            mname_u := if(nKey == K_INS, space(65), tmp->name_u),;
            mvid := space(10), m1vid := if(nKey == K_INS, pvid, tmp->vid),;
            gl_area := {1,0,23,79,0}
    mvid := inieditspr(A__MENUVERT,mm_kas_vid,m1vid)
    box_shadow(r1,0,23,79,color8,;
             if(nKey == K_INS,"Добавление новой",;
                              "Редактирование")+" ортопедической услуги в чеке","RB+/B")
    do while .t.
      setcolor(cDataCGet)
      @ r1+2,2 say "Вид услуги" get mvid ;
               reader {|x|menu_reader(x,mm_kas_vid,A__MENUVERT,,,.f.)}
      @ r1+3,2 say "Шифр услуги" get mshifr pict "@!" ;
               when {|g| f5e_kp_kusl(g,1,1,2) } ;
               valid {|g| f5e_kp_kusl(g,2,1,2) }
      @ r1+4,2 say "Цена услуги" get mu_cena pict pict_cena ;
               when {|g| f5e_kp_kusl(g,1,2) } ;
               valid {|g| f5e_kp_kusl(g,2,2) }
      @ r1+5,2 say "Услуга" get mname_u when .f. color color14
      @ r1+6,2 say "Количество услуг" get mkol pict "999" ;
               valid {|g| f5e_kp_kusl(g,2,5) }
      @ r1+7,2 say "Общая стоимость услуги" get mstoim pict pict_cena ;
               when .f.
      status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи")
      myread()
      if lastkey() != K_ESC
        if emptyany(m1vid,mu_kod,mstoim)
          func_error(4,"Введены не все данные!")
          loop
        else
          mywait()
          select HU
          if nKey == K_INS
            AddRec(7)
            mrec_hu := hu->(recno())
            fl_found := .t.
            select TMP
            append blank
            rec_tmp := tmp->(recno())
          else
            goto (mrec_hu)
            G_RLock(forever)
            select TMP
            goto (rec_tmp)
          endif
          select HU
          replace hu->kod     with human->(recno()),;
                  hu->vid     with m1vid,;
                  hu->stoim   with mstoim,;
                  hu->u_kod   with mu_kod,;
                  hu->u_cena  with mu_cena,;
                  hu->kol     with mkol
          UNLOCK
          select TMP
          tmp->rec_hu := mrec_hu
          tmp->vid := m1vid
          tmp->k_data := sys_date
          tmp->U_KOD := mu_kod
          tmp->U_CENA := mu_cena
          tmp->KOL := mkol
          tmp->STOIM := mstoim
          tmp->shifr_u := mshifr
          tmp->name_u := mname_u
          tmp->shifr_u := mshifr
          tmp->name_u := mname_u
          tmp->rec_hu := mrec_hu
          summa_usl(@mcena)
          COMMIT
        endif
      endif
      exit
    enddo
    flag := 0
    if nKey == K_INS .and. !fl_found
      flag := 1
    endif
    restscreen(buf)
    f3e_ko_kusl()
    select TMP
    oBrow:goTop()
    goto (rec_tmp)
    setcolor(tmp_color)
  case nKey == K_DEL .and. tmp->rec_hu > 0 .and. tmp->is==0
    if f_Esc_Enter(2)
      mywait()
      select HU
      goto (tmp->rec_hu)
      DeleteRec(.t.)
      select TMP
      DeleteRec(.t.)
      UNLOCK
      COMMIT
      oBrow:goTop()
      go top
      summa_usl(@mcena)
      if eof()
        fl_found := .f. ; keyboard chr(K_INS)
      endif
      flag := 0
      restscreen(buf)
      f3e_ko_kusl()
    endif
  otherwise
    keyboard ""
endcase
return flag

*****
Static Function summa_usl(s)
Local i, fl, rec := tmp->(recno())
afill(s,0)
s[_KO_OPL] := p_opl  // уже оплачено
select TMP
go top
do while !eof()
  s[_KO_SUMMA_NAR] += tmp->stoim
  fl := equalany(tmp->vid,LPU_KAS_PLAT,LPU_KAS_PL_S)
  if fl
    s[_KO_K_OPL] += tmp->stoim
  endif
  if between(tmp->vid,1,5)
    s[tmp->vid] += tmp->stoim
  endif
  if tmp->is == 0
    if fl
      s[_KO_SUMMA] += tmp->stoim
    endif
    s[_KO_O_SUMMA] += tmp->stoim
  endif
  skip
enddo
goto (rec)
s[_KO_DOPL] := s[_KO_K_OPL] - s[_KO_OPL]  // доплатить
for i := 1 to len(s)
  s[i] := round_5(s[i],2)
next
return NIL

*

*****
Function f_glob_nar()
return {human->nomer_n,;
        human->(recno()),;
        human->tip_n,;
        human->vid,;
        human->kod_k,;
        human->year_n,;
        human->k_data}

***** вернуть последний номер наряда
Static Function ret_last_N()
Local n := 0, tmp_select := select(), rec, y := year(sys_date)
select HUMAN
rec := human->(recno())
set order to 4
dbseek(str(y+1,4),.t.)
skip -1
if year(human->k_data) == y
  n := human->nomer_n
endif
set order to 1
goto (rec)
select (tmp_select)
return n+1

*****
Function ret_ort_nar()
Static si := 1
Local i, n, r2, fl := .f., arr := {}, arr1 := {}, buf
if (i := popup_prompt(T_ROW,T_COL+5,si,;
                 {"Поиск в ~картотеке","По номеру ~наряда"})) == 0
  return fl
endif
if (si := i) == 1
  if polikl1_kart() > 0
    use_base("kas_ort","HUMAN")
    find (str(glob_kartotek,7))
    do while human->kod_k == glob_kartotek .and. !eof()
      if human->tip_n > 0 .and. ascan(arr,{|x| human->nomer_n==x[1]}) == 0
        aadd(arr,f_glob_nar())
      endif
      skip
    enddo
    Use
    if len(arr) == 0
      fl := func_error(4,'Нет открытых нарядов для "'+glob_k_fio+'"')
    else
      asort(arr,,,{|x,y| iif(x[6]==y[6], x[1] > y[1], x[6] > y[6])})
      for i := 1 to len(arr)
        aadd(arr1, "Наряд № "+lstr(arr[i,1])+"/"+lstr(arr[i,6]))
      next
      buf := savescreen()
      status_key("^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор номера наряда")
      if (r2 := T_ROW+len(arr1)+1) > maxrow()-2
        r2 := maxrow()-2
      endif
      if (i := popup(T_ROW,T_COL+5,r2,T_COL+5+22,arr1,,color0,.t.)) > 0
        glob_nar := arr[i]
        fl := .t.
      endif
      restscreen(buf)
    endif
  endif
else
  if (n := input_value(20,15,22,64,color1,;
                          space(10)+"Введите номер наряда",;
                          glob_nar[1],"999999")) != NIL .and. i > 0
    use_base("kas_ort","HUMAN")
    set order to 4
    for i := year(sys_date)-10 to year(sys_date)+10
      find (str(i,4)+str(n,6))
      do while human->year_n==i .and. human->nomer_n==n .and. !eof()
        if human->tip_n > 0 .and. human->kod_k > 0
          aadd(arr,f_glob_nar())
        endif
        skip
      enddo
    next
    Use
    if len(arr) == 0
      fl := func_error(4,"Не найден наряд № "+lstr(n))
    elseif len(arr) == 1
      glob_nar := arr[1]
      fl := .t.
    else
      asort(arr,,,{|x,y| iif(x[6]==y[6], x[1] > y[1], x[6] > y[6])})
      R_Use(dir_server+"kartotek",,"KART")
      for i := 1 to len(arr)
        goto (arr[i,5])
        aadd(arr1, "Наряд № "+lstr(arr[i,1])+"/"+lstr(arr[i,6])+"  "+fam_i_o(kart->fio))
      next
      use
      buf := savescreen()
      status_key("^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор номера наряда")
      if (r2 := T_ROW+len(arr1)+1) > maxrow()-2
        r2 := maxrow()-2
      endif
      if (i := popup(T_ROW,T_COL+5,r2,T_COL+5+42,arr1,,color0,.t.)) > 0
        glob_nar := arr[i]
        fl := .t.
      endif
      restscreen(buf)
    endif
    if fl
      R_Use(dir_server+"kartotek",,"KART")
      goto (glob_nar[5])
      glob_kartotek := kart->kod
      glob_k_fio := alltrim(kart->fio)
      Use
    endif
  endif
endif
return fl

*

***** 11.05.14
Function yes_o_chek(/*@*/vsum,/*@*/vsd,/*@*/s,/*@*/vbank,rm,/*@*/address,/*@*/tip_kart)


Local tip_bank_kart := {{"МИР",1},;
                        {"VISA",2},;
                        {"MasterCard",3}}
Local fl := .f., tmp_color, buf := savescreen(), r := 11, a[3], ;
      j, spict := "999999.99"
change_attr()
if meK_bank == 1
  tmp_color := setcolor(cDataCGet)
  Private vnos_summa := 0, bank_summa := 0,;
         mbank_kart, m1bank_kart := tip_kart,;
         maddress := padr(address,30)
  mbank_kart := inieditspr(A__MENUVERT,tip_bank_kart,m1bank_kart)
  p_summa := s[_KO_DOPL]
  do while .t.
    buf := box_shadow(r,6,r+10,73)
    buf24 := save_maxrow()
    @ r+1,8 say "Телефон или Электр.почта" get maddress pict "@S30" ;
        valid { | g | ControlAddress( g, maddress ) }
    @ r+2,8 say "Итоговая сумма наряда " get s[_KO_K_OPL] picture spict when .f.
    @ r+3,8 say "Сумма предыдущих оплат" get s[_KO_OPL] picture spict when .f.
    @ r+4,8 say "Следует доплатить     " get s[_KO_DOPL] picture spict when .f. ;
            color "G+/B"
    @ r+5,8 say "Сумма оплаты          " get p_summa picture spict ;
            valid iif(s[_KO_DOPL] > 0, p_summa > 0 .and. p_summa <= s[_KO_DOPL], .t.)
    @ r+6,8 say "-------------------------------------------------------------"
    @ r+7,8 say "Введите вносимую сумму (для подсчета сдачи)       " ;
            get vnos_summa picture spict valid {|g| val_y_chek(g,1) }
    @ r+8,8 say "Сумма, вносимая безналичными (по банковской карте)" ;
            get bank_summa picture spict valid {|g| val_y_chek(g,2) } ;
            when round_5(vnos_summa,2) < p_summa
    @ r+9,8 say "Тип банковской карты" get mbank_kart ;
                   reader {|x|menu_reader(x,tip_bank_kart,A__MENUVERT,,,.f.)};
                                             when bank_summa > 0
    status_key("^<Esc>^ - выход без записи чека;  ^<PgDn>^ - запись чека")
    myread()
    j := f_alert({padc("Выберите действие",60,".")},;
                 {" Выход без записи "," Печать чека "," Возврат в редактирование "},;
                 iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
    if j == 1
      exit
    elseif j == 3
      loop
    endif
    if round_5(bank_summa,2) > 0 .and. lastkey() != K_ESC ;
                                 .and. !f_Esc_Enter("оплаты по карте")
      rest_box(buf)
      rest_box(buf24)
      loop
    endif
    rest_box(buf)
    rest_box(buf24)
    s[_KO_CENA] := p_summa
    if vnos_summa >= p_summa
      a[1] := vnos_summa
      a[2] := p_summa
      a[3] := round_5(vnos_summa - p_summa, 2)
      f_message({"Вносимая сумма: "+str(a[1],10,2),;
                 "Сумма чека    : "+str(a[2],10,2),;
                 "──────────────────────────",;
                 "Сумма сдачи   : "+str(a[3],10,2)},,;
                cHelpCMain,cHelpCMain)
      fl_sdacha := .t.
      vsum := a[1] ; vsd := a[3] ; vbank := 0
    else
      f_message({"Сумма наличными: "+str(vnos_summa,10,2),;
                 "Сумма по карте : "+str(bank_summa,10,2),;
                 "Сумма чека     : "+str(p_summa,   10,2)},,;
                cHelpCMain,cHelpCMain)
      fl_sdacha := .f.
      vsum := vnos_summa ; vsd := 0 ; vbank := bank_summa

    endif
    address  := maddress
    tip_kart := m1bank_kart
    fl := .t.
    exit
  enddo
  setcolor(tmp_color)
else
  tmp_color := setcolor(cDataCGet)
  buf := box_shadow(r,6,r+7,73)
  buf24 := save_row(maxrow())
  Private vnos_summa := 0, mkocena := s[_KO_DOPL]
  @ r+1,8 say "Итоговая сумма наряда " get s[_KO_K_OPL] picture spict when .f.
  @ r+2,8 say "Сумма предыдущих оплат" get s[_KO_OPL] picture spict when .f.
  @ r+3,8 say "Следует доплатить     " get s[_KO_DOPL] picture spict when .f. ;
          color "G+/B"
  @ r+4,8 say "Сумма оплаты          " get mkocena picture spict ;
          valid iif(s[_KO_DOPL] > 0, mkocena > 0 .and. mkocena <= s[_KO_DOPL], .t.)
  @ r+5,8 say "------------------------------------------------------"
  @ r+6,8 say "Введите вносимую сумму (для подсчета сдачи)" ;
          get vnos_summa picture spict ;
          valid iif(empty(vnos_summa), .t., mkocena <= vnos_summa)
  status_key("^<Esc>^ - выход без записи чека;  ^<Enter>^ - запись и печать чека")
  myread()
  restscreen()
  setcolor(tmp_color)
  if lastkey() != K_ESC
    s[_KO_CENA] := p_summa := mkocena
    if vnos_summa > 0
      a[1] := vnos_summa
      a[2] := p_summa
      a[3] := round_5(vnos_summa - p_summa, 2)
      f_message({"Вносимая сумма: "+str(a[1],10,2),;
                 "Сумма чека    : "+str(a[2],10,2),;
                 "──────────────────────────",;
                 "Сумма сдачи   : "+str(a[3],10,2)},,;
                cHelpCMain,cHelpCMain)
      fl_sdacha := .t.
      vsum := a[1] ; vsd := a[3] ; vbank := 0
    endif
    fl := .t.
  endif
endif
return fl

*

*****
Function f41_kas_ort(par)
Local adbf := {;
  {"is"       ,   "N",     1,     0},; // 0-добавление,1-ред-ие
  {"rec_hu"   ,   "N",     7,     0},; // номер записи по БД "HU"
  {"k_data"   ,   "D",     8,     0},; // дата оплаты
  {"VID"      ,   "N",     1,     0},; // вид услуги
  {"U_KOD"    ,   "N",     4,     0},; // код услуги
  {"U_CENA"   ,   "N",    10,     2},; // цена услуги
  {"KOL"      ,   "N",     3,     0},; // количество услуг
  {"STOIM"    ,   "N",    10,     2},; // итоговая стоимость услуги
  {"shifr_u"  ,   "C",    10,     0},;
  {"name_u"   ,   "C",    65,     0}}
dbcreate(cur_dir+"tmp_usl",adbf)
use (cur_dir+"tmp_usl") new alias tmp
if par == 1
  index on str(2-is,1)+str(vid,1)+dtos(k_data)+fsort_usl(shifr_u) to (cur_dir+"tmp_usl")
else
  index on str(vid,1)+dtos(k_data)+fsort_usl(shifr_u) to (cur_dir+"tmp_usl")
endif
use_base("kas_ortu","HU")
R_Use(dir_server+"uslugi",dir_server+"uslugish","USL")
return NIL

*****
Function f42_kas_ort()
Local rec := human->(recno())
if type("p_opl") != "N"
  Private p_opl := 0
endif
select HUMAN
set order to 4
find (str(glob_nar[6],4)+str(glob_nar[1],6))
do while human->year_n==glob_nar[6] .and. human->nomer_n==glob_nar[1] .and. !eof()
  p_opl += human->cena
  aadd(arr_opl,{human->vid,;      //  1
                human->TIP_N,;    //  2
                human->kod_vr,;   //  3
                human->kod_tex,;  //  4
                human->N_CHEK,;   //  5
                human->SMENA,;    //  6
                human->k_data,;   //  7
                human->cena,;     //  8
                human->summa,;    //  9
                human->o_summa,;  // 10
                human->kod_oper}) // 11
  select HU
  find (str(human->(recno()),7))
  do while hu->kod == human->(recno()) .and. !eof()
    usl->(dbGoto(hu->u_kod))
    select TMP
    append blank
    tmp->is      := 1
    tmp->rec_hu  := hu->(recno())
    tmp->k_data  := human->k_data
    tmp->VID     := hu->VID
    tmp->U_KOD   := hu->U_KOD
    tmp->U_CENA  := hu->U_CENA
    tmp->KOL     := hu->KOL
    tmp->STOIM   := hu->STOIM
    tmp->shifr_u := usl->shifr
    tmp->name_u  := usl->name
    select HU
    skip
  enddo
  select HUMAN
  skip
enddo
// сначала tip_n=1 или tip_n=2, а затем по дате
asort(arr_opl,,,{|x,y| iif(x[7]==y[7], x[2] > y[2], x[7] < y[7]) })
select HUMAN
set order to 1
goto (rec)
return NIL

*

*****
Function prn_kas_ort(lnomer_n,fl_hu)
Local rec := tmphum->(recno()), i, s
if !fl_hu
  Private arr_opl := {}
  f41_kas_ort(2)
  f42_kas_ort()
endif
Private file_sh
if !empty(mem_or_ext) .and. ;
   !empty(file_sh := menu_shablon(3,3,dir_exe+"*."+mem_or_ext,color8,.f.,.f.))
  Private t_arr_opl := {}, mvrach := "", mtexnik := "", ;
          mtabn_vr := mtabn_tex := 0,;
          mnomer_n := glob_nar[1],;
          mvid := inieditspr(A__MENUVERT,mm_kas_vid,glob_nar[4]),;
          mtip_n := inieditspr(A__MENUVERT,mm_kas_tip,glob_nar[3])
  if len(arr_opl) > 0
    if arr_opl[1,3] > 0
      perso->(dbGoto(arr_opl[1,3]))
      mtabn_vr := perso->tab_nom
      mvrach := alltrim(perso->fio)
    endif
    if arr_opl[1,4] > 0
      perso->(dbGoto(arr_opl[1,4]))
      mtabn_tex := perso->tab_nom
      mtexnik := alltrim(perso->fio)
    endif
  endif
  R_Use(dir_server+"base1",,"BASE1")
  for i := 1 to len(arr_opl)
    if !emptyall(arr_opl[i,8],arr_opl[i,9],arr_opl[i,9])
      base1->(dbGoto(arr_opl[i,11]))
      s := ""
      if !eof() .and. !empty(base1->p1)
        s := alltrim(crypt(base1->p1,gpasskod))
      endif
      aadd(t_arr_opl, {arr_opl[i,2],;  //  1 - tip_n
                       arr_opl[i,5],;  //  2 - N_CHEK
                       arr_opl[i,6],;  //  3 - SMENA
                       s,;             //  4 - регистратор
                       arr_opl[i,7],;  //  5 - k_data
                       arr_opl[i,8],;  //  6 - cena
                       arr_opl[i,9],;  //  7 - summa
                       arr_opl[i,10]}) //  8 - o_summa
    endif
  next
  base1->(dbCloseArea())
  asort(t_arr_opl,,,{|x,y| iif(x[5]==y[5], x[2]<y[2], x[5]<y[5]) })
  select TMP
  index on str(vid,1)+dtos(k_data)+fsort_usl(shifr_u) to (cur_dir+"tmp_usl2")
  go top
  kassa_r_list_uch(1,"f1_pr_shab(file_sh)")
endif
close databases
eval(bOrt_open)
goto (rec)
return NIL
