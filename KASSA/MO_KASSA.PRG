*******************************************************************************
* mo_kassa.prg
*******************************************************************************
*          begin_task_kassa()
*          fk_usl_cena()
*          f0_usl_cen(oBrow)
*          f1_usl_cen(nKey,oBrow)
*          f2_usl_cen()
*          fk_usl_dogov()
*          f1_usl_dogov(nKey,oBrow)
*          f2_usl_dogov()
*          nastr_kassa(k)
* 03.03.13 kassa_r_list_uch(par,name_func)
* 22.07.16 kas_plat()
*          f2_kas_plat(oBrow)
*          f21_ksa_plat(rec)
*          f22_ksa_plat(rec)
*          f3_kas_plat(nKey,oBrow)
* 22.07.16 f4_kas_plat(fl_edit)
*          fe_kp_kusl(oBrow)
*          f3e_kp_kusl()
*          f2e_kp_kusl(nKey,oBrow)
*          f5e_kp_kusl(get,when_valid,k,ipl_ort)
*          regi_s_plat(k)
*          f2r_s_plat(reg)
*          pl_priemden()
*          pl_dogovor()
*          pl_2dogovor()
*          inputNpozic(r,c,fl_max)
*          f_is_pozic(arr_s,pozic)
*******************************************************************************
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

*

Static smvzros_reb

*****
Function begin_task_kassa()
Static n_zapusk := 0
if n_zapusk == 0
  ++n_zapusk
  Public glob_smena, glob_nar := {0,0,0,0,0,0,ctod("")},;
         mm_kas_tip := {{"сложный",LPU_KAS_SLOG},;
                        {"простой",LPU_KAS_PROS}},;
         mm_kas_vid := {{"бесплатные",   LPU_KAS_B_PL},;  // 1
                        {"платные",      LPU_KAS_PLAT},;  // 2
                        {"пл.со скидкой",LPU_KAS_PL_S},;  // 3
                        {"ДМС",          LPU_KAS_DMS },;  // 4
                        {"взаимозачет",  LPU_KAS_VZ  }}   // 5
  nastr_kassa(1)
  f5_sist_fr(1)
endif
if copy_Tools_Ini()
  Tools_Ini_OMS(1,0,0)
  Tools_Ini_Platn(1,0,0)
else
  return .f.
endif
if (glob_smena := input_value(20,29,22,51,color1,;
                              "Номер смены (1-2)",1,"9")) == NIL
  return .f.
endif
if !between(glob_smena,1,2)
  return func_error(4,"Неверно введен номер смены!")
endif
if hb_FileExists("__kassa_.log") .and. filesize("__kassa_.log") > 5000000
  delete file __kassa_.log
endif
blk_ekran := {|_s| _s := alltrim(fio_polzovat)+;
                         ", смена: "+lstr(glob_smena)+", "+;
                         full_date(sys_date),;
                   devpos(maxrow()-2,maxcol()-len(_s)), ;
                   devout(_s,"W+/N*") }
return .t.

*

*****
Function fk_usl_cena()
Local buf := savescreen(), adbf, i
Private fl_found := .f.
if !myFileDeleted(cur_dir+"tmp"+sdbf)
  return NIL
endif
mywait()
R_Use(dir_server+"uslugi",dir_server+"uslugish","USL")
adbf := {{"kod","N",4,0},;
         {"shifr","C",10,0},;
         {"name","C",64,0}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new alias TMP
index on fsort_usl(shifr) to (cur_dir+"tmp")
G_Use(dir_server+"kas_usl",,"KU")
index on str(u_kod,4) to (cur_dir+"tmp_ku")
go top
do while !eof()
  fl_found := .t.
  select USL
  goto (ku->u_kod)
  select TMP
  append blank
  tmp->kod := ku->u_kod
  tmp->shifr := usl->shifr
  tmp->name := usl->name
  select KU
  skip
enddo
select TMP
go top
if !fl_found ; keyboard chr(K_INS) ; endif
box_shadow(0,2,0,77,"GR+/RB","Список услуг, при вводе которых разрешается редактировать цену",,0)
Alpha_Browse(2,1,23,77,"f0_usl_cen",color0,,,.t.,.t.,,,"f1_usl_cen",,;
             {"═","░","═","N/BG,W+/N,B/BG",.t.,58} )
close databases
restscreen(buf)
return NIL

*****
Function f0_usl_cen(oBrow)
Local oColumn
oColumn := TBColumnNew("   Шифр", {|| tmp->shifr })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(center("Наименование услуги",64), {|| tmp->name })
oBrow:addColumn(oColumn)
status_key("^<Esc>^ - выход;  ^<Ins>^ - добавление;  ^<Del>^ - удаление")
return NIL

*****
Function f1_usl_cen(nKey,oBrow)
LOCAL j := 0, k := -1, buf := save_row(maxrow()), buf1, fl := .f., rec,;
      tmp_color := setcolor(), r1 := 14, c1 := 2, ;
      rec_tmp := tmp->(recno())
do case
  case nKey == K_INS
    if !fl_found
      colorwin(5,0,5,79,"N/N","W+/N")
    endif
    Private mkod := 0,;
            mname := space(60),;
            mshifr := space(10),;
            gl_area := {1,0,23,79,0}
    buf1 := box_shadow(r1,c1,21,77,color8,;
             "Добавление новой услуги в список",cDataPgDn)
    setcolor(cDataCGet)
    @ r1+2,pc1+3 say "Шифр услуги" get mshifr picture "@!" ;
                valid f2_usl_cen()
    @ r1+3,pc1+3 say "Наименование услуги"
    @ r1+4,pc1+5 get mname when .f.
    status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
    myread()
    if lastkey() != K_ESC .and. !empty(mshifr) .and. f_Esc_Enter(1)
      mywait()
      fl_found := .t.
      select TMP
      append blank
      tmp->kod := mkod
      tmp->shifr := mshifr
      tmp->name := mname
      rec_tmp := tmp->(recno())
      select KU
      find (str(mkod,4))
      if !found()
        AddRec(4)
        ku->u_kod := mkod
        UnLock
      endif
      select TMP
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
  case nKey == K_DEL .and. !empty(tmp->shifr) .and. f_Esc_Enter(2)
    mywait()
    select KU
    find (str(tmp->kod,4))
    if found()
      DeleteRec(.t.)
    endif
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

*****
Function f2_usl_cen()
Local fl := valid_shifr()
if fl
  select USL
  find (mshifr)
  if found()
    select KU
    find (str(usl->kod,4))
    if found()
      fl := func_error(4,"Данная услуга уже была добавлена в список!")
    else
      mkod := usl->kod
      mname := usl->name
    endif
  else
    fl := func_error(4,"Нет такого шифра в базе данных услуг!")
  endif
endif
return fl

*

*****
Function fk_usl_dogov()
Local buf := savescreen(), adbf, i
Private fl_found := .f.
if !myFileDeleted(cur_dir+"tmp"+sdbf)
  return NIL
endif
mywait()
R_Use(dir_server+"uslugi",dir_server+"uslugish","USL")
adbf := {{"kod","N",4,0},;
         {"shifr","C",10,0},;
         {"name","C",64,0}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new alias TMP
index on fsort_usl(shifr) to (cur_dir+"tmp")
G_Use(dir_server+"kas_usld",,"KU")
index on str(u_kod,4) to (cur_dir+"tmp_ku")
go top
do while !eof()
  fl_found := .t.
  select USL
  goto (ku->u_kod)
  select TMP
  append blank
  tmp->kod := ku->u_kod
  tmp->shifr := usl->shifr
  tmp->name := usl->name
  select KU
  skip
enddo
select TMP
go top
if !fl_found ; keyboard chr(K_INS) ; endif
box_shadow(0,2,0,77,"GR+/RB","Список услуг, исключаемых из журнала регистрации",,0)
Alpha_Browse(2,1,23,77,"f0_usl_cen",color0,,,.t.,.t.,,,"f1_usl_cen",,;
             {"═","░","═","N/BG,W+/N,B/BG",.t.,58} )
close databases
restscreen(buf)
return NIL

*****
Function f1_usl_dogov(nKey,oBrow)
LOCAL j := 0, k := -1, buf := save_row(maxrow()), buf1, fl := .f., rec,;
      tmp_color := setcolor(), r1 := 14, c1 := 2, ;
      rec_tmp := tmp->(recno())
do case
  case nKey == K_INS
    if !fl_found
      colorwin(5,0,5,79,"N/N","W+/N")
    endif
    Private mkod := 0,;
            mname := space(60),;
            mshifr := space(10),;
            gl_area := {1,0,23,79,0}
    buf1 := box_shadow(r1,c1,21,77,color8,;
             "Добавление новой услуги в список",cDataPgDn)
    setcolor(cDataCGet)
    @ r1+2,pc1+3 say "Шифр услуги" get mshifr picture "@!" ;
                valid f2_usl_dogov()
    @ r1+3,pc1+3 say "Наименование услуги"
    @ r1+4,pc1+5 get mname when .f.
    status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
    myread()
    if lastkey() != K_ESC .and. !empty(mshifr) .and. f_Esc_Enter(1)
      mywait()
      fl_found := .t.
      select TMP
      append blank
      tmp->kod := mkod
      tmp->shifr := mshifr
      tmp->name := mname
      rec_tmp := tmp->(recno())
      select KU
      find (str(mkod,4))
      if !found()
        AddRec(4)
        ku->u_kod := mkod
        UnLock
      endif
      select TMP
      ku->(dbCOMMIT())
      k := 0
    elseif !fl_found
      k := 1
    endif
    select TMP
    oBrow:goTop()
    goto (rec_tmp)
    setcolor(tmp_color)
    rest_box(buf) ; rest_box(buf1)
  case nKey == K_DEL .and. !empty(tmp->shifr) .and. f_Esc_Enter(2)
    mywait()
    select KU
    find (str(tmp->kod,4))
    if found()
      DeleteRec(.t.)
    endif
    select TMP
    DeleteRec(.t.)
    ku->(dbCOMMIT())
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

*****
Function f2_usl_dogov()
Local fl := valid_shifr()
if fl
  select USL
  find (mshifr)
  if found()
    select KU
    find (str(usl->kod,4))
    if found()
      fl := func_error(4,"Данная услуга уже была добавлена в список!")
    else
      mkod := usl->kod
      mname := usl->name
    endif
  else
    fl := func_error(4,"Нет такого шифра в базе данных услуг!")
  endif
endif
return fl

*

*****
Function nastr_kassa(k)
Static mm_da_net := {{"нет",1},{"да ",2}}
Local mm_tmp := {}, buf, fl := .f., s
if k == 1
  Public mem_pl_ext  := "PLK",;
         mem_or_ext  := "ORK",;
         mem_vozvra  := 1,;
         mem_dop_st  := 1
  if hb_FileExists("_lpukas_.mem")
    restore from _lpukas_ additive
  else
    save all like mem_* to _lpukas_
  endif
  ***************
elseif k == 2
  ***************
  buf := save_row(maxrow()) ; mywait()
  close databases
  delete file tmp.dbf
  aadd(mm_tmp, {"pl_ext","C",3,0,"@!",;
                NIL,;
                "",NIL,;
                'Расширение для шаблонов документов по платным услугам'})
  aadd(mm_tmp, {"e_1","C",1,0,NIL,;
                NIL,;
                " ",NIL,;
                " ",,;
                {||.f.} })
  aadd(mm_tmp, {"vozvrat","N",1,0,NIL,;
                {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                "Разрешить администратору возвраты без КАССЫ?"})
  aadd(mm_tmp, {"dop_str","N",1,0,NIL,;  //21.05.08
                {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
                1,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
                "В журналах договоров разделять чеки строкой?"})
  if is_task(X_ORTO)
    aadd(mm_tmp, {"or_ext","C",3,0,"@!",;
                  NIL,;
                  "",NIL,;
                  'Расширение для шаблонов документов по ортопедическим услугам'})
  endif
  init_base(cur_dir+"tmp",,mm_tmp,0)
  use (cur_dir+"tmp") new
  append blank
  tmp->pl_ext  := mem_pl_ext
  tmp->vozvrat := mem_vozvra
  tmp->dop_str := mem_dop_st //21.05.08
  if is_task(X_ORTO)
    tmp->or_ext := mem_or_ext
  endif
  close databases
  if f_edit_spr(A__EDIT,mm_tmp,'настройке работы с задачей "Касса МО"',;
                "g_use(cur_dir+'tmp',,,.t.,.t.)",0,1) > 0
    use (cur_dir+"tmp") new
    mem_pl_ext  := tmp->pl_ext
    mem_vozvra  := tmp->vozvrat
    mem_dop_st  := tmp->dop_str
    if is_task(X_ORTO)
      mem_or_ext := tmp->or_ext
    endif
    save all like mem_* to _lpukas_
  endif
  close databases
  rest_box(buf)
endif
return NIL

// 29.03.23
Function kassa_r_list_uch(par, name_func)
// 1 - платные услуги
// 2 - ортопедические услуги
Local i := 1, j, k, s, fl, buf := save_row(maxrow())
Local luchast := "", arr, m1vid_ud, ;
      m1kategor := atail(stm_kategor)[2]  // т.е. прочие (последнее значение)
Private name_lpu, name_otd, mvzros_reb, mreg_lech, mmest_inog, mrab_nerab,;
        mkomu, name_org, mmi_git, mkategor := " ", mvid_ud, mnom, mser, ;
        l1nomer, lnomer, mrajon_git, mrajon_fin, mpolis, msrok_polis, ;
        mregistrator := "", mtime, mfio, mpol, mdate_r, madres, mmr_dol, ;
        muchastok, s_prim1 := {}, mfio1 := "", mvid_ud1 := "", mser1 := "",;
        mnom1 := "", msnils := "", mokatog := "", mokatop := ""
mywait()
//
R_Use(dir_server+"kartotek",,"KART")
goto (glob_kartotek)
R_Use(dir_server+"kartote_",,"KART_")
goto (glob_kartotek)
R_Use(dir_server+"organiz",,"ORG")
name_lpu := alltrim(org->name)
name_otd := ""
R_Use(dir_server+"k_prim1",dir_server+"k_prim1","K_PRIM1")
find (str(kart->kod,7))
do while k_prim1->kod == kart->kod .and. !eof()
  aadd(s_prim1, rtrim(k_prim1->name))
  skip
enddo
k_prim1->(dbCloseArea())
if len(s_prim1) == 0
  aadd(s_prim1, "")
endif
if human->KOD_OPER > 0
  R_Use(dir_server+"base1",,"BASE1")
  goto (human->KOD_OPER)
  if !eof() .and. !empty(base1->p1)
    mregistrator := alltrim(crypt(base1->p1,gpasskod))
  endif
endif
mfio := upper(kart->fio)
mpolis := kart->polis
msnils := expand(transform(kart->SNILS,picture_pf))
mpol := kart->pol
mdate_r := full_date(kart->date_r)
madres := iif(emptyall(kart_->okatog,kart->adres), "",;
              ret_okato_ulica(kart->adres,kart_->okatog))
mmr_dol := kart->mr_dol
mtime := hour_min(seconds())
msrok_polis := full_date(c4tod(kart->srok_polis))
mvzros_reb := upper(inieditspr(A__MENUVERT, menu_vzros, kart->vzros_reb))
mmi_git    := okato_mi_git(kart_->okatog)
mrajon_git := okato_rajon(kart_->okatog)
mmest_inog := mrajon_fin := ""
mkomu := "СМО: "
if alltrim(kart_->SMO) == '34'
  s := ret_inogSMO_name(1)
  mkomu += iif(empty(s), "ТФОМС (иногородние)", s)
  mmest_inog := inieditspr(A__MENUVERT,glob_array_srf,kart_->KVARTAL_D) // ОКАТО субъекта РФ территории страхования
elseif left(kart_->SMO,2) == '34'
  mkomu += alltrim(inieditspr(A__MENUVERT, glob_arr_smo, int(val(kart_->smo))))
  mmest_inog := 'Волгоградская область'
elseif !empty(kart_->SMO)
  mkomu += init_ismo(kart_->SMO)
  mmest_inog := inieditspr(A__MENUVERT,glob_array_srf,kart_->KVARTAL_D) // ОКАТО субъекта РФ территории страхования
endif
mrab_nerab := upper(inieditspr(A__MENUVERT, menu_rab, kart->rab_nerab))
m1vid_ud := kart_->vid_ud
mnom     := kart_->nom_ud
mser     := kart_->ser_ud
if empty(stm_kategor2)
  m1kategor := kart_->kategor
  mkategor := upper(inieditspr(A__MENUVERT, stm_kategor, m1kategor))
else
  m1kategor := kart_->kategor2
  mkategor := upper(inieditspr(A__MENUVERT, stm_kategor2, m1kategor))
endif
mvid_ud := get_Name_Vid_Ud(m1vid_ud)
if empty(mser) ; mser := space(10) ; endif
if empty(mnom) ; mnom := space(10) ; endif
//
lnomer := l1nomer := lstr(kart->kod)
muchastok := put_val(kart->uchast,2)
if is_uchastok == 1
  if !emptyall(kart->bukva,kart->uchast,kart->kod_vu)
    lnomer := ""
    if !empty(kart->bukva)
      lnomer += kart->bukva
    endif
    lnomer += lstr(kart->uchast,2)
    if kart->kod_vu > 0
      lnomer += "/"+lstr(kart->kod_vu)
    endif
    l1nomer := lnomer
  endif
elseif eq_any(is_uchastok,2,3)
  if !emptyall(kart->bukva,kart->uchast)
    luchast := " [уч-к "
    if !empty(kart->bukva)
      luchast += kart->bukva
    endif
    luchast += lstr(kart->uchast,2)
    luchast += "] "
  endif
  if is_uchastok == 3
    luchast += alltrim(kart2->kod_AK)
  endif
endif
lnomer := expand(lnomer)+luchast
if !empty(name_func) .and. !("(" $ name_func)
  name_func += "()"
endif
k := &name_func
rest_box(buf)
return NIL

*

***** 02.07.18
Function kas_plat()
Local buf, str_sem
//
if  mek_kassa == 1 //.and. mek_nkassa == 1
  Private drvFR
  IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    FR_ZAMENA_otrezka()
  else
    return func_error(4,"Ошибка запуска драйвера КАССЫ")
  endif
endif
//
if polikl1_kart() > 0
  str_sem := "KASSA - Редактирование человека "+lstr(glob_kartotek)
  if !G_SLock(str_sem)
    return func_error(4,err_slock)
  endif
  buf := savescreen()
  Private fl_found, str_find, muslovie
  str_find := str(glob_kartotek,7)
  muslovie := "human->kod_k == glob_kartotek"
  R_Use(dir_server+"mo_pers",,"PERSO")
  R_Use(dir_server+"uslugi",,"USL")
  use_base("kas_pl_u","HU")
  set relation to u_kod into USL
  use_base("kas_pl","HUMAN")
  find (str_find)
  fl_found := found()
  arr_blk := {{| | FindFirst(str_find)},;
              {| | FindLast(str_find,-1)},;
              {|n| SkipPointer(n, muslovie)},;
              str_find,muslovie;
             }
  if !fl_found ; keyboard chr(K_INS) ; endif
  mtitle := glob_k_fio
  Alpha_Browse(T_ROW,0,maxrow()-2,79,"f2_kas_plat",color0,mtitle,"BG+/GR",;
               .f.,.t.,arr_blk,,"f3_kas_plat",,;
               {"═","░","═","N/BG,W+/N,B/BG,BG+/B",.t.,180} )
  close databases
  restscreen(buf)
  G_SUnLock(str_sem)
endif
return NIL

*****
Function f2_kas_plat(oBrow)
Local oColumn, blk := {|| iif(human->cena < 0, {3,4}, {1,2}) },;
tip_bank := {"бн","МИ","VI","MC"}
//
oColumn := TBColumnNew(" № чека",{|| iif(human->sbank > 0,;
tip_bank[human->fr_tipkart+1]+iif(human->sbank == human->cena," ","Н")+put_val(human->n_chek,5),;
put_val(human->n_chek,8)) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Дата чека", {|| full_date(human->k_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Сумма чека", {|| put_kop(human->cena,10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("     Услуги в чеке", {|| padr(f21_ksa_plat(human->(recno())),36) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("  Кассир", {|| padr(f22_ksa_plat(human->KOD_OPER),10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
status_key("^<Esc>^-выход; ^<Enter>^-редактирование чека; ^<Ins>^-добавление чека; ^<F9>^-печать")
return NIL

*****
Function f21_ksa_plat(rec)
Local s := "", t_vr, tmp_select := select()
select HU
find (str(rec,7))
do while rec == hu->kod .and. !eof()
  select PERSO
  goto (hu->kod_vr)
  t_vr := perso->tab_nom
  s += alltrim(usl->shifr)+"-"+lstr(hu->kol)+"("+lstr(t_vr)+") "
  select HU
  skip
enddo
select (tmp_select)
return s

*****
Function f22_ksa_plat(rec)
Local mregistrator := "", tmp_select := select()
if rec > 0
  R_Use(dir_server+"base1",,"BASE1")
  goto (rec)
  if !eof() .and. !empty(base1->p1)
    mregistrator := alltrim(crypt(base1->p1,gpasskod))
  endif
  base1->(dbclosearea())
  select (tmp_select)
endif
return mregistrator

*****
Function f3_kas_plat(nKey,oBrow)
LOCAL j := 0, flag := -1, buf := save_row(maxrow()), buf1, fl := .f., rec, mkod,;
      tmp_color := setcolor(), r1 := 15, c1 := 2, v_summa, v_sdacha, adbf, s,;
      t_hum_rec := 0, kart_kod, t_k_data, i
Private ldate_voz, lsum_voz, nom_prihod := 0
do case
  case nKey == K_F9 .and. !empty(human->cena)
    if !myFileDeleted(cur_dir+"tmp"+sdbf)
      return flag
    endif
    rec := human->(recno())
    t_hum_rec := human->(recno())
    kart_kod := human->kod_k
    t_k_data := year(human->k_data)
    select HUMAN
    do while human->kod_k == kart_kod .and.;
             year(human->k_data) == t_k_data .and. !eof()
      ++nom_prihod
      skip
    enddo
    goto (t_hum_rec)
    adbf := {{"shifr","C",10,0},;
             {"name", "C",65,0},;
             {"vrach","C",40,0},;
             {"cena", "N",10,2},;
             {"kol",  "N", 4,0}}
    dbcreate(cur_dir+"tmp",adbf)
    use (cur_dir+"tmp") new
    adbf := {}
    select HU
    find (str(rec,7))
    index on str(kod_vr,4)+fsort_usl(usl->shifr) to (cur_dir+"tmp") while hu->kod == rec
    go top
    do while !eof()
      if hu->kod_vr > 0 .and. ascan(adbf,hu->kod_vr) == 0
        aadd(adbf,hu->kod_vr)  // массив врачей
      endif
      skip
    enddo
    go top
    do while !eof()
      select TMP
      append blank
      tmp->shifr := usl->shifr
      tmp->name := usl->name
      if hu->kod_vr > 0 .and. (i := ascan(adbf,hu->kod_vr)) > 0
        perso->(dbGoto(hu->kod_vr))
        tmp->vrach := fam_i_o(perso->fio)+" <"+lstr(perso->tab_nom)+">"
        Del_Array(adbf,i)
      endif
      tmp->cena := hu->U_CENA
      tmp->kol := hu->kol
      select HU
      skip
    enddo
    Private file_sh
    if !empty(mem_pl_ext) .and. ;
       !empty(file_sh := menu_shablon(3,3,dir_exe+"*."+mem_pl_ext,color8,.f.))
      select TMP
      go top
      kassa_r_list_uch(1,"f1_pr_shab(file_sh)")
    endif
    close databases
    R_Use(dir_server+"mo_pers",,"PERSO")
    R_Use(dir_server+"uslugi",,"USL")
    use_base("kas_pl_u","HU")
    set relation to u_kod into USL
    use_base("kas_pl","HUMAN")
    goto (rec)
  case nKey == K_ENTER
    rec := human->(recno())
    close databases
    use_base("kas_pl","HUMAN")
    goto (rec)
    f4_kas_plat(2)
    R_Use(dir_server+"mo_pers",,"PERSO")
    R_Use(dir_server+"uslugi",,"USL")
    use_base("kas_pl_u","HU")
    set relation to u_kod into USL
    select HUMAN
    goto (rec)
  case nKey == K_INS
    if !fl_found
      colorwin(7,0,7,79,"N/N","W+/N")
      colorwin(7,0,7,79,"N/N","BG+/B")
    endif
    AddRec(7)
    human->KOD_K := glob_kartotek
    human->N_CHEK := 0
    human->SMENA := glob_smena
    human->K_DATA := sys_date
    human->CENA := human->sbank := 0
    human->KOD_OPER := asc(kod_polzovat)
    human->(DBCommit()) //16.06.08
    UnLock
    rec := human->(recno())
    close databases
    use_base("kas_pl","HUMAN")
    goto (rec)
    if f4_kas_plat(1)  // запись чека
      flag := 0
    else
      use_base("kas_pl_u","HU")
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
    R_Use(dir_server+"mo_pers",,"PERSO")
    R_Use(dir_server+"uslugi",,"USL")
    use_base("kas_pl_u","HU")
    set relation to u_kod into USL
    select HUMAN
    goto (rec)
  case nKey == K_DEL .and. human->KOD_K > 0 .and. human->N_CHEK==0 .and. f_Esc_Enter(2)
    rec := human->(recno())
    select HU
    do while .t.
      find (str(rec,7))
      if !found() ; exit ; endif
      DeleteRec(.t.)
    enddo
    select HUMAN
    goto (rec)
    DeleteRec()
    flag := 1
  otherwise
    keyboard ""
endcase
return flag


*

***** 04.07.17
Function f4_kas_plat(fl_edit)
Local fl := .f., adbf, buf := savescreen(), tmp_color := setcolor(color1), ;
      j, l_color, mtitle, ln_chek := 0, fl_opl_vozvr := 0, rec, t_date,;
      fr_zavodnomer := "", mi_post, mphone_m, maddress, tip_kart := 2,;
      summa_oplat := 0, summa_oplat_bn := 0, tip_banka := 1,;
      v_sdacha := 0
Private fl_found := .f., mcena := 0, pr_kod_vr := 0, flg_edit := fl_edit,;
        is_open_u1 := .f., lfr_data, lfr_time
//
lfr_data := dtoc4(date())
lfr_time := timetosec()
//
R_Use(dir_server+"kartotek",,"KART")
goto (glob_kartotek)
smvzros_reb := kart->vzros_reb
kart->(dbCloseArea())
G_Use(dir_server+"kas_usl",,"KU")
index on str(u_kod,4) to (cur_dir+"tmp_ku")
adbf := {;
    {"rec_hu"   ,   "N",     7,     0},; // номер записи по БД "HU"
    {"KOD_VR"   ,   "N",     4,     0},; // код врача
    {"U_KOD"    ,   "N",     4,     0},; // код услуги
    {"U_CENA"   ,   "N",    10,     2},; // цена услуги
    {"KOL"      ,   "N",     3,     0},; // количество услуг
    {"STOIM"    ,   "N",    10,     2},; // итоговая стоимость услуги
    {"shifr_u"  ,   "C",    10,     0},;
    {"name_u"   ,   "C",   128,     0}}
dbcreate(cur_dir+"tmp_usl",adbf)
use (cur_dir+"tmp_usl") new alias tmp
index on fsort_usl(shifr_u) to (cur_dir+"tmp_usl")
use_base("kas_pl_u","HU")
R_Use(dir_server+"uslugi",dir_server+"uslugish","USL")
R_Use(dir_server+"usl_otd",dir_server+"usl_otd","UO")
G_Use(dir_server+"pu_date",dir_server+"pu_date","PUD")
G_Use(dir_server+"pu_cena",{dir_server+"pu_cena",;
                            dir_server+"pu_cenau"},"PUC")
R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
cls
pr_1_str("Ввод чека для больного < "+alltrim(glob_k_fio)+" >")
l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"
mtitle := "Дата оплаты: "+full_date(human->k_data)+"г."
//
Private flag_1 := .t.
if fl_edit == 2
  select HU
  rec := human->(recno())
  find (str(rec,7))
  do while rec == hu->kod .and. !eof()
    select TMP
    append blank
    tmp->rec_hu  := hu->(recno())
    tmp->KOD_VR  := hu->kod_vr
    tmp->U_KOD   := hu->u_kod
    tmp->U_CENA  := hu->u_cena
    tmp->KOL     := hu->kol
    tmp->STOIM   := hu->stoim
    select USL
    goto (hu->u_kod)
    tmp->shifr_u := usl->shifr
    tmp->name_u  := usl->name
    select HU
    skip
  enddo
  select TMP
  go top
else
  keyboard chr(K_INS)
endif
do while .t.
  Alpha_Browse(2,0,maxrow()-2,79,"fe_kp_kusl",color1,mtitle,col_tit_popup,;
               .f.,.t.,,,"f2e_kp_kusl",,;
               {"═","░","═",l_color,.t.,180} )
  if empty(mcena)
    j := 1
  else
    if flg_edit == 1
      j := f_alert({padc("Выберите действие",60,".")},;
                   {" Выход без записи "," Печать чека "," Возврат в редактирование "},;
                   2,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
    else
      j := 1
    endif
  endif
  if j == 1
    exit
  elseif j == 2
    tmp->(dbCloseArea())
    // 00.07.17 поиск номера или э.почты.
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
    R_Use(dir_server+"kartote_",,"KR_") //00.02.17
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
    use (cur_dir+"tmp_usl") new index (cur_dir+"tmp_usl")
    adbf := {{"name",   "C",128,0},; // 24.12.17
             {"name_u", "C",128,0},;
             {"vrach",  "C", 40,0},;
             {"cena",   "N", 10,2},;
             {"U_CENA", "N", 10,2},;
             {"vz_cena","N",  9,3},;
             {"kol",    "N",  4,0},;
             {"kol1",   "N",  4,0},;
             {"nds20",  "N",  1,0},; //10.08.08
             {"nds18",  "N",  1,0},; //10.08.08
             {"nds10",  "N",  1,0}}
    dbcreate(cur_dir+"tmp",adbf)
    use (cur_dir+"tmp") new
    adbf := {}
    select TMP_USL
    go top
    do while !eof()
      if tmp_usl->kod_vr > 0 .and. ascan(adbf,tmp_usl->kod_vr) == 0
        aadd(adbf,tmp_usl->kod_vr)  // массив врачей
      endif
      skip
    enddo
    fl := .t.
    select TMP_USL
    go top
    do while !eof()
      select TMP
      append blank
      select USL
      goto (tmp_usl->U_KOD)
      if mek_kod_usl > 1 
        if len(alltrim(usl->full_name)) > 3
          tmp->name_u := alltrim(usl->full_name)
          tmp->name := alltrim(usl->full_name)
        else
          tmp->name_u := alltrim(usl->name)
          tmp->name := alltrim(usl->name)
        endif
      else  
        if len(alltrim(usl->full_name)) > 3
          tmp->name_u := alltrim(usl->shifr)+" "+alltrim(usl->full_name)
          tmp->name := alltrim(usl->shifr)+" "+alltrim(usl->full_name)
        else
          tmp->name_u := alltrim(usl->shifr)+" "+alltrim(usl->name)
          tmp->name := alltrim(usl->shifr)+" "+alltrim(usl->name)
        endif
      endif
      select TMP
      if tmp_usl->kod_vr > 0 .and. fl
        perso->(dbGoto(tmp_usl->kod_vr))
        tmp->vrach := fam_i_o(perso->fio)+" <"+lstr(perso->tab_nom)+">"
        if len(adbf) == 1  // если врач один,
          fl := .f.        // то печатаем его только в 1-ой услуге
        endif
      endif
      tmp->cena    := tmp_usl->U_CENA
      tmp->u_cena  := tmp_usl->U_CENA
      tmp->vz_cena := tmp_usl->U_CENA
      select USL
      goto (tmp_usl->U_KOD)
      if round(tmp->cena,2) == round(usl->pcena_d,2) // дети-взрослые
        // дети
        if round_5(usl->pnds_d,2) > 0
          if round_5(usl->pnds_d,0) == 18
            tmp->nds18 := 1
          elseif round_5(usl->pnds_d,0) == 20
            tmp->nds20 := 1
          elseif round_5(usl->pnds_d,0) == 10
            tmp->nds10 := 1
          endif
        endif
      else
        if round_5(usl->pnds,2) > 0
          if round_5(usl->pnds,0) == 18
            tmp->nds18 := 1
          elseif round_5(usl->pnds,0) == 20
            tmp->nds20 := 1
          elseif round_5(usl->pnds,0) == 10
            tmp->nds10 := 1
          endif
        endif
      endif
      if tmp_usl->kol < 0 //призн. возврата
        fl_opl_vozvr := 1
        tmp->kol  := tmp_usl->kol*(-1)
        tmp->kol1 := tmp_usl->kol*(-1)
      else
        tmp->kol := tmp_usl->kol
      endif
      select TMP_USL
      skip
    enddo
    Private p_summa := round_5(mcena,2), fl_sdacha := .f.
    v_summa := v_sdacha := v_bank := round_5(0,2)
    fl := .f.
    if fl_opl_vozvr == 0
      if yes_chek(@v_summa,@v_sdacha,@v_bank,,@maddress,@tip_kart) .and.;
        chek_fr(round_5(v_summa,2),v_sdacha,@ln_chek,round_5(v_bank,2),,@fr_zavodnomer,maddress,tip_kart)
        fl := .t.
        select HUMAN
        G_RLock(forever)
        human->N_CHEK := ln_chek
        human->cena := mcena
        human->sbank := v_bank
        t_date := human->k_data
        human->k_data := c4tod(lfr_data)
        human->fr_data := lfr_data
        human->fr_time := lfr_time
        human->FR_zavod := fr_zavodnomer
        human->FR_tipkart := tip_kart
        human->fr_tip     := 2
        human->i_post     :=  maddress //00.02.17
        UnLock
        human->(DBCommit())
        if t_date != human->k_data
          fl := func_error(4,"ВНИМАНИЕ! Дата в чеке "+full_date(human->k_data)+"  Дата в компьютере"+full_date(t_date) )
        endif
      endif
    else  // возврат
      v_summa := mcena*(-1)
      if mem_vozvra == 2 .and. hb_user_curUser:IsAdmin() //07.04.08
        fl := .t.                                 // возврат без кассы
        select HUMAN
        G_RLock(forever)
        human->N_CHEK := 0
        human->cena := mcena
        human->sbank := mcena //18.11.14
        UnLock
        human->(DBCommit()) //16.06.08
      else
        summa_oplat    := 0
        summa_oplat_bn := 0
        tip_banka      := 1
        maddress       := ""
        v_sdacha       := 0
        //
        p_summa := round_5(mcena,2)

        if yes_chek(@summa_oplat,@v_sdacha,@summa_oplat_bn,,@maddress,@tip_banka)
          p_summa := p_summa*(-1)
          // вначале возвращаем чистый безнал
          if round(p_summa,2) ==  round(summa_oplat_bn,2)
            sum_nal   := 0
            sum_bank  := p_summa
          elseif p_summa <= (summa_oplat - summa_oplat_bn)
             // чистый нал
            sum_bank  := 0
            tip_banka := 0
            sum_nal   := p_summa
          else
            sum_nal   := p_summa - summa_oplat_bn
            sum_bank  := summa_oplat_bn
          endif
          fl := vozvrat_fr(sum_nal,sum_bank,@ln_chek,1,tip_banka)
          // сам чек
          if fl
            // заносим возврат
            select HUMAN
            G_RLock(forever)
            human->N_CHEK := ln_chek
            human->cena := mcena
            human->sbank := 0
            t_date := human->k_data            //25.06.08 Н
            human->k_data := c4tod(lfr_data)
            human->fr_data := lfr_data
            human->fr_time := lfr_time
            //replace ho->date_voz    with dtoc4(ldate_voz), ;
            //        ho->sum_voz     with summa_oplat
                   /* ,;
                    ho->vzfr_data   with ,;
                    ho->vzfr_time   with ,;
                    ho->vzkod_oper  with ,;
                    ho->vzfr_zavod   with
                  */
            UnLock
            stat_msg("Сумма возврата записана!") ; mybell(1,OK)
          endif
        endif
        human->(dbCommit())
      endif
    endif
    tmp_usl->(dbCloseArea())
    restscreen(buf)
    exit
  elseif j == 3
    loop
  endif
enddo
tmp->(dbCloseArea())
if is_open_u1
  u1k->(dbCloseArea())
  uk->(dbCloseArea())
  is_open_u1 := .f.
endif
perso->(dbCloseArea())
usl->(dbCloseArea())
uo->(dbCloseArea())
puc->(dbCloseArea())
pud->(dbCloseArea())
ku->(dbCloseArea())
hu->(dbCloseArea())
select HUMAN
setcolor(tmp_color)
restscreen(buf)
return fl

*****
Function fe_kp_kusl(oBrow)
Local oColumn, blk_color := {|| iif(tmp->stoim < 0, {3,4}, {1,2}) }
oColumn := TBColumnNew("   Шифр;  услуги",{|| tmp->shifr_u })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Наименование;  услуги",{|| left(tmp->name_u,34) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Врач",{|| put_val(ret_tabn(tmp->kod_vr),5) })
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
if flg_edit == 2
  status_key("^<Enter>^ ред-ие")
else
  status_key("^<Esc>^ выход для печати чека ^<Enter>^ ред-ие ^<Ins>^ добавление ^<Del>^ удаление")
endif
return NIL

*****
Function f3e_kp_kusl()
@ 23,60 say padl("Итого: "+lstr(mcena,11,2),19) color "W+/N"
return NIL

*****
Function f2e_kp_kusl(nKey,oBrow)
LOCAL flag := -1, buf := savescreen(), fl := .f., rec, ;
      i1, k, j := 0, s := 0, so := 0, adbf, adbf1, tmp_color := setcolor(), ;
      rec_tmp := tmp->(recno()), mrec_hu := tmp->rec_hu
Private r1 := 13
do case
  case (nKey == K_INS .and. flg_edit==1) .or. (nKey == K_ENTER .and. tmp->rec_hu > 0)
    chm_help_code := 1//HM_Edit1_kart
    if nKey == K_INS .and. !fl_found
      colorwin(7,0,7,79,"B/B","W+/RB")
    endif
    Private mu_kod := if(nKey == K_INS, 0, tmp->u_kod),;
            mu_cena := if(nKey == K_INS, 0, tmp->u_cena),;
            mkod_vr := if(nKey == K_INS, pr_kod_vr, tmp->kod_vr),;
            mtabn_vr := 0, mvrach := space(35),;
            mkol := if(nKey == K_INS, 0, tmp->kol),;
            mstoim := if(nKey == K_INS, 0, tmp->stoim),;
            mshifr := if(nKey == K_INS, space(10), tmp->shifr_u),;
            mname_u := if(nKey == K_INS, space(65), tmp->name_u),;
            pr_k_usl := {},;  // массив комплексных услуг
            gl_area := {1,0,23,79,0}
    if mkod_vr > 0
      select PERSO
      goto (mkod_vr)
      mvrach := padr(perso->fio,35)
      mtabn_vr := perso->tab_nom
    endif
    box_shadow(r1,0,23,79,color8,;
             if(nKey == K_INS,"Добавление новой",;
                              "Редактирование")+" платной услуги в чеке","RB+/B")
    do while .t.
      setcolor(cDataCGet)
      @ r1+2,2 say "Шифр услуги" get mshifr pict "@!" ;
               when {|g| f5e_kp_kusl(g,1,1,1) } ;
               valid {|g| f5e_kp_kusl(g,2,1,1) }
      @ r1+3,2 say "Цена услуги" get mu_cena pict pict_cena ;
               when {|g| len(pr_k_usl)==0 .and. f5e_kp_kusl(g,1,2) } ;
               valid {|g| f5e_kp_kusl(g,2,2) }
      @ r1+4,2 say "Услуга" get mname_u when .f. color color14
      @ r1+5,2 say "Таб.№ врача" get mtabn_vr pict "99999" ;
               valid {|g| f5e_kp_kusl(g,2,3) }
      @ row(),col()+3 get mvrach when .f. color color14
      @ r1+6,2 say "Количество услуг" get mkol pict "999" ;
               valid {|g| f5e_kp_kusl(g,2,5) } when iif(flg_edit==2,.f.,.t.)
      @ r1+7,2 say "Общая стоимость услуги" get mstoim pict pict_cena ;
               when .f.
      status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи")
      myread()
      if lastkey() != K_ESC
        if len(pr_k_usl) == 0 .and. emptyany(mu_kod,mstoim)
          func_error(4,"Не введена услуга!")
          loop
        elseif len(pr_k_usl) == 0 .and. empty(mstoim)
          func_error(4,"Не введена цена услуги!")
          loop
        elseif empty(mkod_vr)
          func_error(4,"Не введен врач!")
          loop
        else
          mywait()
          if nKey == K_INS .and. len(pr_k_usl) > 0
            // комплексная услуга
            for i := 1 to len(pr_k_usl)
              mshifr := pr_k_usl[i,1]
              mu_kod := pr_k_usl[i,3]
              mname_u := pr_k_usl[i,4]
              mu_cena := pr_k_usl[i,5]
              mt_edit := pr_k_usl[i,7]
              mis_nul := pr_k_usl[i,9]
              mstoim := round_5(mu_cena * mkol, 2)
              //
              select HU
              AddRec(7)
              mrec_hu := hu->(recno())
              fl_found := .t.
              select TMP
              append blank
              rec_tmp := tmp->(recno())
              //
              select HU
              replace hu->kod     with human->(recno()),;
                      hu->kod_vr  with mkod_vr,;
                      hu->stoim   with mstoim,;
                      hu->u_kod   with mu_kod,;
                      hu->u_cena  with mu_cena,;
                      hu->kol     with mkol
              UNLOCK
              select TMP
              tmp->rec_hu := mrec_hu
              tmp->KOD_VR := mkod_vr
              tmp->U_KOD := mu_kod
              tmp->U_CENA := mu_cena
              tmp->KOL := mkol
              tmp->STOIM := mstoim
              tmp->shifr_u := mshifr
              tmp->name_u := mname_u
              pr_kod_vr := tmp->kod_vr
            next
          else  // одна услуга
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
                    hu->kod_vr  with mkod_vr,;
                    hu->stoim   with mstoim,;
                    hu->u_kod   with mu_kod,;
                    hu->u_cena  with mu_cena,;
                    hu->kol     with mkol
            UNLOCK
            select TMP
            tmp->rec_hu := mrec_hu
            tmp->KOD_VR := mkod_vr
            tmp->U_KOD := mu_kod
            tmp->U_CENA := mu_cena
            tmp->KOL := mkol
            tmp->STOIM := mstoim
            tmp->shifr_u := mshifr
            tmp->name_u := mname_u
            pr_kod_vr := tmp->kod_vr
          endif
          summa_usl(@mcena)
          HU->(DBCOMMIT()) //16.06.08
        endif
      endif
      exit
    enddo
    flag := 0
    if nKey == K_INS .and. !fl_found
      flag := 1
    endif
    restscreen(buf)
    f3e_kp_kusl()
    select TMP
    oBrow:goTop()
    goto (rec_tmp)
    setcolor(tmp_color)
  case nKey == K_DEL .and. tmp->rec_hu > 0 .and. flg_edit == 1
    if f_Esc_Enter(2)
      mywait()
      select HU
      goto (tmp->rec_hu)
      DeleteRec(.t.)
      select TMP
      DeleteRec(.t.)
      summa_usl(@mcena)
      select HUMAN
      G_RLock(forever)
      replace human->cena with mcena
      UNLOCK
      COMMIT
      select TMP
      oBrow:goTop()
      go top
      if eof()
        fl_found := .f. ; keyboard chr(K_INS)
      endif
      flag := 0
      restscreen(buf)
      f3e_kp_kusl()
    endif
  otherwise
    keyboard ""
endcase
return flag

*****
Static Function summa_usl(s)
Local j := 0
s := 0
select TMP
go top
do while !eof()
  s += tmp->stoim
  skip
enddo
s := round(s,2)
return NIL

*

*****
Function f5e_kp_kusl(get,when_valid,k,ipl_ort)
Local fl := .t., s, j, old_kod, mvar, ar,;
      msg1_err := "Код врача равен коду техника! Это недопустимо.",;
      msg2_err := "Человека с таким кодом нет в базе данных персонала!",;
      blk_sum := {|| mstoim := round_5(mu_cena * mkol, 2) }
if when_valid == 1    // when
  if k == 1     // Шифр услуги
    if !empty(mshifr)
      fl := .f.
    endif
  elseif k == 2     // цена услуги
    if !empty(mu_kod)
      select KU
      find (str(mu_kod,4))
      fl := found()
    endif
  elseif k == 5 // Количество услуг
    if empty(mshifr)
      fl := .f.
    elseif mt_edit > 1
      fl := .f.
    endif
  endif
else                  // valid
  if k == 1 // Шифр услуги
    if !empty(mshifr) .and. !(mshifr == get:original)
      mshifr := transform_shifr(mshifr)
      select USL
      set order to 1
      find (mshifr)
      if found()
        mu_kod := usl->kod
        mname_u := usl->name
        mu_cena := 0
        if iif(ipl_ort==1, .t., (m1vid != LPU_KAS_B_PL))
          // сначала берем цену для платных услуг
          //mu_cena := if(smvzros_reb==0, usl->pcena, usl->pcena_d)
          if ipl_ort == 1 // для платных услуг
            ar := CenaUslDate(human->k_data,mu_kod)
          else  // для ортопедии - по дате открытия наряда
            ar := CenaUslDate(glob_nar[7],mu_kod)
          endif
          mu_cena := if(smvzros_reb==0, ar[1], ar[2])
        endif
        mkol := 1
        eval(blk_sum)
        update_gets()
      elseif ipl_ort == 1 .and. get_k_usluga(mshifr,smvzros_reb,@fl)
        box_shadow(r1-5,40,r1-3,77,cColorStMsg,;
                   "Комплексная услуга",cColorSt2Msg)
        @ r1-4,41 say padc("Количество услуг - "+lstr(len(pr_k_usl)),36) color cColorStMsg
        mkol := 1
        if fl  // сменить код врача и ассистента
          mvrach := space(35)
          mtabn_vr := ret_tabn(mkod_vr)
          if mkod_vr > 0
            select PERSO
            goto (mkod_vr)
            if !eof() .and. !deleted()
              mvrach := padr(perso->fio,35)
            endif
          endif
        endif
        fl := update_gets()
      else
        fl := func_error(4,"Такого шифра нет в базе данных услуг.")
      endif
    endif
  elseif k == 2 // цена услуги
    eval(blk_sum)
    update_gets()
  elseif k == 3 // Код врача
    old_kod := mkod_vr
    if empty(mtabn_vr)
      mkod_vr := 0
      mvrach := space(35)
    else
      select PERSO
      find (str(mtabn_vr,5))
      if found()
        if type("mkod_tex") == "N" .and. perso->kod == mkod_tex
          fl := func_error(4,msg1_err)
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
  elseif k == 4 // Код техника
    old_kod := mkod_tex
    if empty(mtabn_tex)
      mkod_tex := 0
      mtexnik := space(35)
    else
      select PERSO
      find (str(mtabn_tex,5))
      if found()
        if perso->kod == mkod_vr
          fl := func_error(4,msg1_err)
        else
          mkod_tex := perso->kod
          mtexnik := padr(perso->fio,35)
        endif
      else
        fl := func_error(4,msg2_err)
      endif
    endif
    if old_kod != mkod_tex
      update_get("mtexnik")
    endif
  elseif k == 5 // Количество услуг
    if mkol != get:original
      eval(blk_sum)
      update_gets()
    endif
  endif
  if !fl
    &(readvar()) := get:original
  endif
endif
return fl

*
*

*****
Function regi_s_plat(k)
Static si1 := 1, si2 := 1, si3 := 1, si4 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
if k == 0
    mas_pmt := {"~Персонал + услуги",;
                "Персонал + услуги + ~больные",;
                "~Услуги + персонал",;
                "~Журнал Регистрации",;
                "~Настраиваемый журнал Регистрации",; //21.05.08
                "Свод по услугам",;
                "Реестр по платным услугам"}
    mas_msg := {"Персонал + услуги (за период времени)",;
                "Персонал + услуги + больные (за период времени)",;
                "Услуги + персонал (за период времени)",;
                "Журнал регистрации договоров",;
                "Настраиваемый Журнал регистрации договоров",; //21.05.08
                "Свод по услугам",;
                "Реестр по платным услугам за период"}
    mas_fun := {"regi_s_plat(1)",;
                "regi_s_plat(2)",;
                "regi_s_plat(3)",;
                "regi_s_plat(4)",;
                "regi_s_plat(5)",;
                "regi_s_plat(6)",;
                "regi_s_plat(7)"}
  popup_prompt(T_ROW,T_COL-5,si4,mas_pmt,mas_msg,mas_fun)
else
  do case
    case k == 1
      f2r_s_plat(3)  // персонал + услуги за период времени
    case k == 2
      f2r_s_plat(5)  // персонал + услуги + больные за период времени
    case k == 3
      f2r_s_plat(4)  // услуги + персонал за период времени
    case k == 4
      pl_dogovor() //10.05
    case k == 5
      pl_2dogovor() //10.05  21.05.08
    case k == 6
      pl_priemden()
    case k == 7
      prn_k_plat(2)   //09.10.17
  endcase
endif
if k > 0
  si4 := k
endif
return NIL


*

*****
Function f2r_s_plat(reg)
Static snomer := 1, sreg1 := 1
Local i, j, k, arr[2], s, buf := save_row(maxrow()), buf1, reg1,;
      fl_exit := .f., sh, HH := 57, reg_print,;
      arr_title, name_file := "n_kvit.txt",;
      vstoim := 0, sstoim := 0, old := 0, up_usl, ;
      speriod, begin_date, end_date, cp := " "
//if input_uch(T_ROW,T_COL-5,.f.) == NIL
//  return NIL
//endif
//if (up_usl := ret_up_usl()) == NIL
//  return NIL
//endif
if (arr_m := year_month()) == NIL
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp"+sdbf)
  return NIL
endif
speriod := arr_m[4]
begin_date := arr_m[5]
end_date := arr_m[6]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
dbcreate(cur_dir+"tmp", {{"U_KOD" ,"N", 4,0},; // код услуги
                 {"KOD_VR","N", 4,0},; // код врача
                 {"KOD_B", "N", 7,0},; // код больного
                 {"KOL"   ,"N", 5,0},; // количество услуг
                 {"STOIM" ,"N",10,2}}) // итоговая стоимость услуги
use (cur_dir+"tmp") new
index on str(kod_vr,4)+str(u_kod,4)+str(kod_b,7) to (cur_dir+"tmp")
R_Use(dir_server+"uslugi",dir_server+"uslugi","USL")
R_Use(dir_server+"kas_pl",dir_server+"kas_pl2","KP")
R_Use(dir_server+"kas_pl_u",dir_server+"kas_pl1u","KPU")
select KP
dbseek(dtos(arr_m[5]),.t.)
do while kp->k_data <= arr_m[6] .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  select KPU
  find (str(kp->(recno()),7))
  do while kp->(recno()) == kpu->kod .and. !eof()
    select TMP
    find (str(kpu->kod_vr,4)+str(kpu->u_kod,4)+str(0,7))
    if !found()
      append blank
      tmp->kod_vr := kpu->kod_vr
      tmp->u_kod  := kpu->u_kod
    endif
    tmp->kol += kpu->kol
    tmp->stoim += kpu->stoim
    if reg == 5
      select TMP
      find (str(kpu->kod_vr,4)+str(kpu->u_kod,4)+str(kp->kod_k,7))
      if !found()
        append blank
        tmp->kod_vr := kpu->kod_vr
        tmp->u_kod  := kpu->u_kod
        tmp->kod_b  := kp->kod_k
      endif
      tmp->kol += kpu->kol
      tmp->stoim += kpu->stoim
    endif
    select KPU
    skip
  enddo
  select KP
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  // ничего
elseif j == 0
  func_error(4,"Нет сведений за указанный период времени")
else
  mywait()
  reg_print := 2
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"mo_pers",,"PERSO")
  use (cur_dir+"tmp") new alias TMP
  set relation to kod_vr into PERSO, to u_kod into USL
  if equalany(reg,1,3)
    index on str(kod_vr,4)+fsort_usl(usl->shifr) to (cur_dir+"tmp")
  elseif equalany(reg,2,4)
    index on str(u_kod,4)+fsort_usl(usl->shifr)+str(kod_vr,4) to (cur_dir+"tmp")
  elseif reg == 5
    cp := "."
    R_Use(dir_server+"kartotek",,"KART")
    select TMP
    set relation to kod_b into KART additive
    index on str(kod_vr,4)+fsort_usl(usl->shifr)+upper(left(kart->fio,20)) to (cur_dir+"tmp")
  endif
  arr_title := {;
"───────────────────────────────────────────────────────────┬─────┬─────────────",;
"                                                           │ Кол.│  Стоимость  ",;
"                                                           │услуг│    услуг    ",;
"───────────────────────────────────────────────────────────┴─────┴─────────────"}
  sh := len(arr_title[1])
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string(glob_uch[2])
  add_string("")
  if reg == 3
    add_string(center("Реестр доплат [ персонал + услуги ]",sh))
  elseif reg == 4
    add_string(center("Реестр доплат [ услуги + персонал ]",sh))
  elseif reg == 5
    add_string(center("Реестр доплат [ персонал + услуги + больные ]",sh))
  endif
  add_string("")
  add_string(center(speriod,sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if equalany(reg,1,3,5)
      if old != tmp->kod_vr
        if old != 0
          add_string(space(sh-20)+replicate("-",20))
          add_string(space(sh-20)+"Итого:"+padl(expand0value(vstoim,2),14))
          vstoim := 0
        endif
        add_string("")
        add_string("["+lstr(perso->tab_nom)+"] "+alltrim(perso->fio))
        old := tmp->kod_vr
      endif
      k := perenos(arr,alltrim(usl->shifr)+". "+alltrim(usl->name),55)
    else
      if old != tmp->u_kod
        if old != 0
          add_string(space(sh-20)+replicate("-",20))
          add_string(space(sh-20)+"Итого:"+padl(expand0value(vstoim,2),14))
          vstoim := 0
        endif
        add_string("")
        add_string(alltrim(usl->shifr)+". "+alltrim(usl->name))
        old := tmp->u_kod
      endif
      k := perenos(arr,"["+lstr(perso->tab_nom)+"] "+alltrim(perso->fio),55)
    endif
    if tmp->kod_b == 0
      add_string(space(4)+padr(alltrim(arr[1]),55,cp)+;
                 padl(lstr(tmp->kol),6,cp)+;
                 padl(expand0value(tmp->stoim,2),14,cp))
      for i := 2 to k
        add_string(space(4)+padl(alltrim(arr[i]),55))
      next
      vstoim += tmp->stoim ; sstoim += tmp->stoim
    else
      add_string(space(8)+padr(kart->fio,51)+;
                 str(tmp->kol,6)+padl(expand0value(tmp->stoim,2),14))
    endif
    select TMP
    skip
  enddo
  add_string(space(sh-20)+replicate("-",20))
  add_string(space(sh-20)+"Итого:"+padl(expand0value(vstoim,2),14))
  add_string(replicate("═",sh))
  add_string(space(sh-20)+"ИТОГО:"+padl(expand0value(sstoim,2),14))
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
if buf1 != NIL
  rest_box(buf1)
endif
return NIL

*

*****
Function pl_priemden()
Local fl := .t., buf := save_row(maxrow()), sm := 0, HH := 59,;
      n_file := "platn.txt", arr_m, sum3 := 0, sh
Local arr_title := {;
  "───────────────────────────────────────────────────┬────────┬───────────",;
  "                  Услуги                           │ Кол-во │   Сумма   ",;
  "───────────────────────────────────────────────────┴────────┴───────────";
  }
sh := len(arr_title[1])
if (arr_m := year_month()) == NIL
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp"+sdbf)
  return NIL
endif
//
mywait()
dbcreate(cur_dir+"tmp", {{"kod",     "N", 4,   0},;
                 {"name",    "C", 60,  0},;
                 {"kod_1",   "C", 10,  0},;
                 {"kol_vo",  "N", 10,  0},;
                 {"summa",   "N", 12,  2}})
use (cur_dir+"tmp") new
index on kod to (cur_dir+"tmp_u")
R_Use(dir_server+"kas_pl_u",dir_server+"kas_pl1u","HUM_U")
R_Use(dir_server+"kas_pl",,"HUM")
index on str(kod_oper,3) to (cur_dir+"tmp_hum") for between(k_data,arr_m[5],arr_m[6])
go top
do while !eof()
  select HUM_U
  find (str(hum->(RECNO()),7))
  do while hum->(RECNO()) == hum_u->kod .and. !eof()
    select TMP
    find (hum_u->u_kod)
    if !found()
      append blank
      tmp->kod := hum_u->u_kod
    endif
    tmp->kol_vo += hum_u->kol
    tmp->summa  += hum_u->stoim
    select HUM_U
    skip
  enddo
  select HUM
  skip
enddo
R_Use(dir_server+"uslugi",,"USL")
select TMP
set relation to kod into USL
go top
do while !eof()
  tmp->name  := usl->name
  tmp->kod_1 := usl->shifr
  skip
enddo
select TMP
index on fsort_usl(kod_1) to (cur_dir+"tmp_u")
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string(center("Оплата услуг",sh))
add_string(center("по дате НАЧАЛА лечения",sh))
add_string(center(arr_m[4],sh))
add_string("")
aeval(arr_title, {|x| add_string(x) })
go top
sm1 := sm2 := 0
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(tmp->kod_1+padr(tmp->name,40)+;
             STR(tmp->kol_vo,9)+;
             put_kope(tmp->summa,12))
  sm1 += tmp->kol_vo
  SM2 += tmp->summa
  skip
enddo
add_string(replicate("─",sh))
add_string(padR("Итого: ",50)+;
             STR(SM1,9)+;
             put_kope(SM2,12))
close databases
fclose(fp)
viewtext(n_file,,,,(sh>80),,,2)
rest_box(buf)
return NIL

*

*****
Function pl_dogovor()
Local buf := save_row(maxrow()), sh, HH := 49, arr_title, s, i, j, k, sk, ss,;
      arr2title, reg_print := 6, afio[10], lfio := 19, kfio, lsk, lss, adbf,;
      aadres[2], kadres, apolis[10], kpolis, name_file := "jurnal.txt"
arr_title := {;
"─────────────────────────────┬───────┬─────────────────────────────────────────────────────────────────┬───────┬────┬──────────┬──────────┬──────────",;
"        Ф.И.О., адрес        │ НОМЕР │                   Название медицинской услуги                   │  Цена │Кол.│ Сумма за │   Дата   │   Срок   ",;
"        застрахованного      │медицин│                                                                 │ каждой│оказ│все кол-во│  приема  │ оказания ",;
"                             │ карты │                                                                 │ услуги│ус- │оказ.услуг│   мед.   │   мед.   ",;
"                             │       │                                                                 │ (руб.)│луг │  (руб.)  │  услуги  │  услуги  ",;
"─────────────────────────────┴───────┴─────────────────────────────────────────────────────────────────┴───────┴────┴──────────┴──────────┴──────────"}
if (arr_m := year_month()) == NIL
  return NIL
endif
mywait()
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(center("Ж У Р Н А Л",sh))
add_string(center("учета заказов граждан на оказание им платных медицинских услуг(помощи)",sh))
add_string(center(arr_m[4],sh))
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"kas_pl_u",dir_server+"kas_pl1u","HPU")
R_Use(dir_server+"kas_pl",,"HU")
index on dtos(k_data)+str(n_chek,6) to (cur_dir+"tmp_hum") for between(k_data,arr_m[5],arr_m[6])
aeval(arr_title, {|x| add_string(x) } )
j := sk := ss := 0
select HU
go top
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  ss += hu->cena
  select KART
  goto hu->kod_k
  kfio := perenos(afio,alltrim(kart->fio)+" "+alltrim(kart->adres),29)
  fl_hu := .T. ; i := 0
  select HPU
  t_kod := hu->(recno())
  find (str(t_kod,7))
  do while t_kod==hpu->kod .and. !eof()
    usl->(dbGoto(hpu->u_kod))
    if fl_hu
      fl_hu := .F.
      add_string(afio[1]+" "+;
                 padr(lstr(hu->kod_k),7)+" "+;
                 padr(usl->name,65)+" "+put_kop(hpu->u_cena,7)+" "+;
                 padr(lstr(hpu->kol),4)+" "+put_kop(hpu->stoim,10)+" "+;
                 full_date(hu->k_data)+" "+full_date(hu->k_data))
      i := 1
    else
      ++i
      add_string(iif(i<=kfio,afio[i],space(29))+" "+;
                 space(7)+" "+;
                 padr(usl->name,65)+" "+put_kop(hpu->u_cena,7)+" "+;
                 padr(lstr(hpu->kol),4)+" "+put_kop(hpu->stoim,10)+" "+;
                 full_date(hu->k_data)+" "+full_date(hu->k_data))
    endif
    select HPU
    skip
  enddo
  if i == 1
    add_string(iif(1<kfio,afio[2],space(29)))
  endif
  select HU
  skip
enddo
close databases
add_string(replicate("─",sh))
add_string(padl("Итого : "+str(ss,11,2),sh-12))
add_string("")
add_string("")
add_string(center("Главный врач _________________                         Главный бухгалтер _________________",sh))
fclose(fp)
rest_box(buf)
Private yes_albom := .t.
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

*****
Function pl_2dogovor()
Local buf := save_row(maxrow()), sh, HH := 49, arr_title, s, i, k, sk, ss,;
      arr2title, reg_print := 6, afio[10], lfio := 19, kfio, lsk, lss, adbf,;
      aadres[2], kadres, apolis[10], kpolis, name_file := "jurnal1.txt",;
      t_vr, t_as, t_nvr, t_nas
arr_title := {;
"─────────────────────────────┬──────────",;
"        Ф.И.О., адрес        │   Дата   ",;
"        застрахованного      │ рождения ",;
"                             │          ",;
"                             │          ",;
"─────────────────────────────┴──────────"}
// номер карты
arr_1 := {;
 "┬───────",;
 "│ НОМЕР ",;
 "│медицин",;
 "│ карты ",;
 "│       ",;
 "┴───────"}
//номер чека
arr_2 := {;
 "┬──────",;
 "│НОМЕР ",;
 "│      ",;
 "│ чека ",;
 "│      ",;
 "┴──────"}
// дата оплаты услуги
arr_3 := {;
 "┬────────",;
 "│  Дата  ",;
 "│ оплаты ",;
 "│  мед.  ",;
 "│ услуги ",;
 "┴────────"}
// дата оказания услуги
arr_4 := {;
 "┬────────",;
 "│  Дата  ",;
 "│оказания",;
 "│  мед.  ",;
 "│ услуги ",;
 "┴────────"}
// шифр услуги
arr_5 := {;
 "┬──────────",;
 "│ Код мани-",;
 "│ пуляции  ",;
 "│          ",;
 "│          ",;
 "┴──────────"}
// наименование услуги
arr_6 := {;
 "┬──────────────────────────────────────────────────",;
 "│                                                  ",;
 "│       Вид (наименование) медицинской услуги      ",;
 "│                                                  ",;
 "│                                                  ",;
 "┴──────────────────────────────────────────────────"}
// код врач
arr_7 := {;
 "┬─────",;
 "│     ",;
 "│     ",;
 "│Врач ",;
 "│     ",;
 "┴─────"}
// код м/c
arr_8 := {;
 "┬─────",;
 "│     ",;
 "│     ",;
 "│ М/с ",;
 "│     ",;
 "┴─────"}
// фио врача+м/с
arr_9  := {;
 "┬───────────────",;
 "│               ",;
 "│     Врач      ",;
 "├───────────────",;
 "│     М/с       ",;
 "┴───────────────"}
// цена услуги
arr_10 := {;
 "┬───────",;
 "│  Цена ",;
 "│ каждой",;
 "│ услуги",;
 "│ (руб.)",;
 "┴───────"}
// количество услуг
arr_11 := {;
 "┬────",;
 "│Кол.",;
 "│оказ",;
 "│ус- ",;
 "│луг ",;
 "┴────"}
// сумма услуг
arr_00 := {;
 "┬──────────",;
 "│ Сумма за ",;
 "│все кол-во",;
 "│оказ.услуг",;
 "│  (руб.)  ",;
 "┴──────────"}
Private glob_pozic
if (glob_pozic := inputNpozic(T_ROW,T_COL+5)) == NIL
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
mywait()
// создаем заголовок
for i := 0 to 10
  if f_is_pozic(glob_pozic,i)
    for j := 1 to 6
      arr_title[j] += &("arr_"+lstr(i+1)+"[j]")
    next
  endif
next
for j := 1 to 6
  arr_title[j] += arr_00[j]
next
//
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"kas_usld",,"PUSL")
index on str(u_kod,4) to (cur_dir+"tmp_ud")
R_Use(dir_server+"mo_pers",,"P2")
R_Use(dir_server+"organiz",,"ORG")
add_string(center("Ж У Р Н А Л",sh))
add_string(center("учета заказов граждан на оказание им платных медицинских услуг(помощи)",sh))
add_string(center(arr_m[4],sh))
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"kas_pl_u",dir_server+"kas_pl1u","HPU")
R_Use(dir_server+"kas_pl",,"HU")
index on dtos(k_data)+str(n_chek,6) to (cur_dir+"tmp_hum") for between(k_data,arr_m[5],arr_m[6])
aeval(arr_title, {|x| add_string(x) } )
j := sk := ss := 0
select HU
go top
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  // проверка на услуги-продажи
  i := 0
  fl_prod :=.F.
  select HPU
  t_kod := hu->(recno())
  find (str(t_kod,7))
  do while t_kod==hpu->kod .and. !eof()
    ++i
    if i > 1
      exit //более 1 услуги
    endif
    select PUSL
    find (str(hpu->u_kod,4))
    if found()
      fl_prod := .T.
    endif
  enddo
  if fl_prod //продажи выходим на начало
    select HU
    skip
    loop
  endif
  ss += hu->cena
  select KART
  goto hu->kod_k
  kfio := perenos(afio,alltrim(kart->fio)+" "+alltrim(kart->adres),29)
  fl_hu := .T.
  select HPU
  //t_kod := hu->(recno())
  find (str(t_kod,7))
  do while t_kod==hpu->kod .and. !eof()
    usl->(dbGoto(hpu->u_kod))
    select P2
    goto (hpu->kod_vr)
    t_vr := p2->tab_nom ; t_as := 0
    t_nvr := fam_i_o(p2->fio)
    if fl_hu
      fl_hu := .F.
      //goto (hpu->kod_as)
      //t_nas := "  "//fam_i_o(p2->fio)
      //
      add_string(afio[1]+" "+;
                 full_date(kart->date_r)+" "+; //
                 iif(f_is_pozic(glob_pozic,0),padr(lstr(hu->kod_k),7)+" ","")+;
                 iif(f_is_pozic(glob_pozic,1),padr(lstr(hu->n_chek),6)+" ","")+;
                 iif(f_is_pozic(glob_pozic,2),date_8(hu->k_data)+" ","")+;
                 iif(f_is_pozic(glob_pozic,3),date_8(hu->k_data)+" ","")+;
                 iif(f_is_pozic(glob_pozic,4),usl->shifr+" ","")+;
                 iif(f_is_pozic(glob_pozic,5),padr(usl->name,50)+" ","")+;
                 iif(f_is_pozic(glob_pozic,6),iif(t_vr>0,padl(lstr(t_vr),5),space(5))+" ","")+;
                 iif(f_is_pozic(glob_pozic,7),iif(t_as>0,padl(lstr(t_as),5),space(5))+" ","")+;
                 iif(f_is_pozic(glob_pozic,8),padr(t_nvr,15)+" ","")+;
                 iif(f_is_pozic(glob_pozic,9),put_kop(hpu->u_cena,7)+" ","")+;
                 iif(f_is_pozic(glob_pozic,10),padr(lstr(hpu->kol),4)+" ","")+;
                 put_kop(hpu->stoim,10))
      i := 1
    else
      ++i
      add_string(iif(i<=kfio,afio[i],space(29))+" "+;
                 space(10)+" "+;
                 iif(f_is_pozic(glob_pozic,0),space(8),"")+;
                 iif(f_is_pozic(glob_pozic,1),space(7),"")+;
                 iif(f_is_pozic(glob_pozic,2),space(8)+" ","")+;
                 iif(f_is_pozic(glob_pozic,3),date_8(hu->k_data)+" ","")+;
                 iif(f_is_pozic(glob_pozic,4),usl->shifr+" ","")+;
                 iif(f_is_pozic(glob_pozic,5),padr(usl->name,50)+" ","")+;
                 iif(f_is_pozic(glob_pozic,6),iif(t_vr>0,padl(lstr(t_vr),5),space(5))+" ","")+;
                 iif(f_is_pozic(glob_pozic,7),iif(t_as>0,padl(lstr(t_as),5),space(5))+" ","")+;
                 iif(f_is_pozic(glob_pozic,8),padr(t_nvr,15)+" ","")+;
                 iif(f_is_pozic(glob_pozic,9),put_kop(hpu->u_cena,7)+" ","")+;
                 iif(f_is_pozic(glob_pozic,10),padr(lstr(hpu->kol),4)+" ","")+;
                 put_kop(hpu->stoim,10))
    endif
    select HPU
    skip
  enddo
  if i == 1 .and. 1<kfio
    add_string(afio[2])
  endif
  if mem_dop_st == 2
    add_string("")
  endif
  select HU
  skip
enddo
close databases
add_string(replicate("─",sh))
add_string(padl("Итого : "+lstr(ss,14,2),sh))
add_string("")
add_string("")
add_string(center("Главный врач _________________                         Главный бухгалтер _________________",sh))
fclose(fp)
rest_box(buf)
Private yes_albom := .t.
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

*****
Function inputNpozic(r,c,fl_max)
Static st_pozic := {}
Local i, k, t_mas, ;
      buf := savescreen(), l_a_pozic
Local mas_s := {"Номер карты",;
                "Номер чека",;
                "Дата оплаты мед.услуги",;
                "Дата оказания мед.услуги",;
                "Шифр мед.услуги",;
                "Наименование мед.услуги",;
                "Код Врача",;
                "Код Медсестры",;
                "ФИО врача+м/с",;
                "Цена услуги",;
                "Количество услуг"}

Local mas := {1,2,3,4,5,6,7,8,9,10,11}
DEFAULT fl_max TO .f.
if (k := r + 11) > maxrow()-2
  k := maxrow()-2
endif
if c+35 > maxcol()-2
  c := maxcol()-2-35
endif
t_mas := aclone(mas_s)
if fl_max  // принудительное полное заполнение
  aeval(mas, {|x| aadd(st_pozic,x) } )
endif
aeval(t_mas, {|x,i| ;
       t_mas[i] := if(ascan(st_pozic,mas[i]) > 0, " * ", "   ")+t_mas[i]})
status_key("^<Esc>^ - отказ ^<Enter>^ - подтверждение ^<Ins>^ - смена признака выбора")
do while .t.
  l_a_pozic := NIL
  if popup(r,c,k,c+35,t_mas,i,color0,.t.,"fmenu_reader",,"Колонки информации","B/BG") > 0
    l_a_pozic := {} ; st_pozic := {}
    for i := 1 TO 11
      if "*" == substr(t_mas[i],2,1)
        aadd(l_a_pozic, { (i-1),alltrim(mas_s[i]),})
        aadd(st_pozic, mas[i])
      endif
    next
    if empty(l_a_pozic)
      //func_error(4,"Необходимо отметить хотя бы один источник финансирования!")
      //loop
      exit
    else
      exit
    endif
  else
    exit
  endif
enddo
restscreen(buf)
return l_a_pozic

*

*****
Function f_is_pozic(arr_s,pozic)
return ( ascan(arr_s,{|x| pozic==x[1] }) > 0 )
