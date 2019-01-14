***** mo_func1.prg
#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 11.04.18 выравнивание вторичного файла базы данных до первичного
Function dbf_equalization(lalias,lkod)
Local fl := .t.
dbSelectArea(lalias)
do while lastrec() < lkod
  DO WHILE .t.
    APPEND BLANK
    fl := .f.
    IF !NETERR() ; exit ; ENDIF
  ENDDO
enddo
if fl  // т.е. нужная запись не заблокирована при добавлении
  goto (lkod)
  G_RLock(forever)
endif
return NIL

***** 18.03.13 признак села
Function f_is_selo(_gorod_selo,_okatog)
Local arr, ret := .f., fl := .f., tmp_select
DEFAULT _gorod_selo TO kart_->gorod_selo, _okatog TO kart_->okatog
if _gorod_selo == 2 // из картотеки
  fl := .t.  // нашли
  ret := .t.   // село
  //my_debug(,"село  KART_")
endif
if !fl .and. !empty(okato_rajon(_okatog,@arr))
  if arr[5] == 1 // город
    fl := .t.  // нашли
    ret := .f.   // город
    //my_debug(,"город "+arr[4]+" "+arr[1])
  endif
endif
if !fl
  tmp_select := select()
  R_Use(dir_exe+"_okatos",cur_dir+"_okats","SELO")
  find (padr(_okatog,11,'0'))
  if found()
    fl := .t.  // нашли
    ret := (selo->selo == 0)
    //my_debug(,iif(ret,"село  ","город ")+_okatog+" "+rtrim(selo->name))
  endif
  use
  if !fl
    R_Use(dir_exe+"_okatoo",cur_dir+"_okato","OBLAST")
    find (padr(_okatog,5,'0'))
    if found()
      fl := .t.  // нашли
      ret := (oblast->selo == 0)
      //my_debug(,iif(ret,"село  ","город ")+_okatog+"+"+rtrim(oblast->name))
    endif
    use
  endif
  select (tmp_select)
endif
if !fl
  //my_debug(,"город "+_okatog)
endif
return ret

***** вернуть город/область/иногородний
Function okato_mi_git(_okato)
Local s := ""
if !empty(_okato)
  if left(_okato,5) == "18401"
    s := "г.Волгоград"
  elseif left(_okato,2) == "18"
    s := "Волгоградская обл."
  else
    s := "иногородний"
  endif
endif
return s

***** вернуть район по ОКАТО
Function okato_rajon(tokato,/*@*/ret_arr)
Static arr_rajon := {;
  {"Ворошиловский"    ,0 ,11, "18401363",1},;
  {"Дзержинский"      ,0 ,12, "18401365",1},;
  {"Кировский"        ,0 ,13, "18401370",1},;
  {"Красноармейский"  ,0 ,14, "18401375",1},;
  {"Краснооктябрьский",0 ,15, "18401380",1},;
  {"Советский"        ,0 ,16, "18401385",1},;
  {"Тракторозаводской",0 ,17, "18401390",1},;
  {"Центральный"      ,0 ,18, "18401395",1},;
  {"г.Камышин"        ,1 ,21, "18415000",1},;
  {"г.Михайловка"     ,1 ,22, "18420000",1},;
  {"г.Урюпинск"       ,1 ,23, "18425000",1},;
  {"г.Фролово"        ,1 ,24, "18428000",1},;
  {"г.Волжский"       ,1 ,25, "18410000",1},;
  {"Алексеевский"     ,1 ,30, "18202000",2},;
  {"Быковский"        ,1 ,31, "18204000",2},;
  {"Городищенский"    ,1 ,32, "18205000",2},;
  {"Даниловский"      ,1 ,33, "18206000",2},;
  {"Дубовский"        ,1 ,34, "18208000",2},;
  {"Еланский"         ,1 ,35, "18210000",2},;
  {"Жирновский"       ,1 ,36, "18212000",2},;
  {"Иловлинский"      ,1 ,37, "18214000",2},;
  {"Калачевский"      ,1 ,38, "18216000",2},;
  {"Камышинский"      ,1 ,39, "18218000",2},;
  {"Киквидзенский"    ,1 ,40, "18220000",2},;
  {"Клетский"         ,1 ,41, "18222000",2},;
  {"Котельниковский"  ,1 ,42, "18224000",2},;
  {"Котовский"        ,1 ,43, "18226000",2},;
  {"Ленинский"        ,1 ,44, "18230000",2},;
  {"Михайловский"     ,1 ,45, "18232000",2},;
  {"Нехаевский"       ,1 ,46, "18234000",2},;
  {"Николаевский"     ,1 ,47, "18236000",2},;
  {"Новоаннинский"    ,1 ,48, "18238000",2},;
  {"Новониколаевский" ,1 ,49, "18240000",2},;
  {"Октябрьский"      ,1 ,50, "18242000",2},;
  {"Ольховский"       ,1 ,51, "18243000",2},;
  {"Палласовский"     ,1 ,52, "18245000",2},;
  {"Кумылженский"     ,1 ,53, "18246000",2},;
  {"Руднянский"       ,1 ,54, "18247000",2},;
  {"Светлоярский"     ,1 ,55, "18249000",2},;
  {"Серафимовический" ,1 ,56, "18250000",2},;
  {"Среднеахтубинский",1 ,57, "18251000",2},;
  {"Старополтавский"  ,1 ,58, "18252000",2},;
  {"Суровикинский"    ,1 ,59, "18253000",2},;
  {"Урюпинский"       ,1 ,60, "18254000",2},;
  {"Фроловский"       ,1 ,61, "18256000",2},;
  {"Чернышковский"    ,1 ,62, "18258000",2};
 }
Local t1okato := padr(tokato,8), vozvr := "", t1
// сначала поиск по району г.Волгограда
if (t1 := ascan(arr_rajon,{|x| padr(x[4],8) == t1okato})) > 0
  vozvr := arr_rajon[t1,1]
  ret_arr := arr_rajon[t1]
else // теперь по району области
  t1okato := padr(tokato,5)
  if (t1 := ascan(arr_rajon,{|x| padr(x[4],5) == t1okato})) > 0
    vozvr := arr_rajon[t1,1]
    ret_arr := arr_rajon[t1]
  endif
endif
return vozvr

***** работает хотя бы одно учреждение с талоном
Function ret_is_talon()
Local is_talon := .f., tmp_select := select()
R_Use(dir_server+"mo_uch",,"_UCH")
go top
do while !eof()
  if between_date(_uch->dbegin,_uch->dend,sys_date) .and. _uch->IS_TALON == 1
    is_talon := .t. ; exit
  endif
  skip
enddo
_uch->(dbCloseArea())
select (tmp_select)
return is_talon

***** в поле "диагноз" включить курсор
Function when_diag()
SETCURSOR()
return .t.

***** ввод шифра услуги
Function valid_shifr()
Private tmp := readvar()
&tmp := transform_shifr(&tmp)
return .t.

***** трансформирование шифра услуги (запятую на точку, посл.точку убрать)
Function transform_shifr(s)
Local n := len(s)  // длина поля может быть 10 или 15 символов
s := DelEndSymb(charrepl(",",s,"."),".") // запятую - на точку и удалить последнюю точку
// русскую букву А,В
if eq_any(left(s,1),"А","В") .and. substr(s,4,1) == "." ;
               .and. EMPTY(CHARREPL("0123456789", substr(s,2,2), SPACE(10)))
  s := iif(left(s,1)=="А","A","B")+substr(s,2)  // заменим на английскую A,B
endif
return padr(s,n)

***** удалить все спецсимволы из строки
Function del_spec_symbol(s)
Local i, c, s1 := ""
for i := 1 to len(s)
  c := substr(s,i,1)
  if asc(c) == 255 ; c := " " ; endif // меняем на пробел
  if asc(c) >= 32
    s1 += c
  endif
next
return s1

***** подставить впереди строки какое-то кол-во пробелов
Function st_nom_stroke(lstroke)
Local i, r := 0
lstroke := alltrim(lstroke)
for i := 1 to len(lstroke)
  if "." == substr(lstroke,i,1)
    ++r
  endif
next
if r == 1 .and. right(lstroke,2) == ".0"
  r := 0
endif
return space(r*2)

*****
Function a2default(arr,name,sDefault)
// arr - двумерный массив
// name - поиск по имени первого элемента
// sDefault - значение по умолчанию для второго элемента
Local s := "", i
if valtype(sDefault) == "C"
  s := sDefault
endif
if (i := ascan(arr, {|x| upper(x[1]) == upper(name)})) > 0
  s := arr[i,2]
endif
return s

*****
Function uk_arr_dni(nKey)
Local buf := savescreen(), arr, d, mtitle, ldate := tmp->date_u1 + 1,;
      tmp_color := setcolor(), arr1, r
if eq_any(nkey,K_F4,K_F5)
  mtitle := "Копирование услуги "+alltrim(tmp->shifr_u)+" от "+date_8(tmp->date_u1)+"г."
else
  mtitle := "Копирование всех услуг, оказанных "+date_8(tmp->date_u1)+"г."
endif
setcolor(color0+",,,N/W")
if nKey == K_F4
  if ldate > human->k_data
    ldate := human->k_data
  endif
  box_shadow(18,5,21,74,color0)
  @ 19,6 say padc(mtitle,68)
  @ 20,18 say "Введите, дату для новой услуги" get ldate ;
            valid {|| between(ldate,human->n_data,human->k_data) }
  myread()
  if lastkey() != K_ESC
    arr := {{date_8(ldate),ldate}}
  endif
else
  Private mdni := 1, mdate := human->k_data
  if ldate < mdate
    mdni := mdate - ldate + 1
  endif
  box_shadow(18,5,21,74,color0,mtitle,"B/BG")
  status_key("^<Esc>^ - отказ;  ^<PgDn>^ - копировать строки")
  do while .t.
    @ 19,9 say "Введите, сколько еще копий необходимо сделать" get mdni pict "99" ;
            valid {|| mdate := ldate + mdni - 1, .t. }
    @ 20,9 say "Введите, по какую дату (включительно) копировать" get mdate ;
            valid {|| mdni := mdate - ldate + 1, .t. }
    myread()
    if lastkey() == K_ESC
      exit
    elseif lastkey() == K_PGDN
      if mdate >= ldate
        arr1 := {}
        for d := ldate to mdate
          aadd(arr1, {date_8(d),d})
        next
        if (r := 21 - len(arr1)) < 2
          r := 2
        endif
        arr := bit_popup(r,63,arr1,,color5)
      endif
      exit
    endif
  enddo
endif
restscreen(buf)
setcolor(tmp_color)
return arr

*****
Function put_otch_period(full_year)
Local n := 5, s := strzero(schet_->nyear,4)
DEFAULT full_year TO .f.
if full_year
  n += 2
else
  s := right(s,2)
endif
s += "/"+strzero(schet_->nmonth,2)
if emptyany(schet_->nyear,schet_->nmonth)
  s := space(n)
endif
return s

***** возврат даты регистрации счёта
Function date_reg_schet()
// если нет даты регистрации, берём дату счёта
return iif(empty(schet_->dregistr), schet_->dschet, schet_->dregistr)

***** 25.01.2018
Function ret_vid_pom(k,mshifr,lk_data)
Local svp, vp := 0, lal, is_18 := .t.
if valtype(lk_data) == "D"
  is_19 := (year(lk_data) > 2018)
endif  
if select("LUSL") == 0
  Use_base("lusl")
endif
lal := iif(is_19,"lusl","lusl18")
dbSelectArea(lal)
find (padr(mshifr,10))
if found()
  svp := alltrim(&lal.->VMP_F)
  if empty(svp)
    vp := 0
  elseif k == 1
    vp := int(val(svp))
  else
    vp := 1
    if svp == '2'
      vp := 2
    elseif "3" $ svp
      vp := 3
    endif
  endif
endif
return vp

***** вернуть в массиве запись базы данных
Function get_field()
Local arr := array(fcount())
aeval(arr, {|x,i| arr[i] := fieldget(i) }  )
return arr

*****
Function get_k_usluga(lshifr,lvzros_reb,lvr_as)
Local i, buf := save_maxrow(), lu_cena, lis_nul, v, fl, arr_k_usl := {}, fl_oms
mywait()
lshifr := padr(lshifr,10)
lvr_as := .f.
pr_k_usl := {}
if !is_open_u1
  G_Use(dir_server+"uslugi1k",dir_server+"uslugi1k","U1K")
  G_Use(dir_server+"uslugi_k",dir_server+"uslugi_k","UK")
  is_open_u1 := .t.
endif
select UK
find (lshifr)
if found()
  select U1K
  find (uk->shifr)
  do while u1k->shifr == uk->shifr .and. !eof()
    aadd(arr_k_usl,{u1k->shifr1,;
                    .f.,;  // 2 все ли корректно ?
                    0,;    // 3 код услуги
                    "",;   // 4 наименование услуги
                    0,;    // 5 цена
                    0,;    // 6 коэффициент
                    0,;    // 7 %% понижения цены
                    "",;   // 8 shifr1
                    .f.,;  // 9 is_nul
                    .f.})  //10 is_oms
    skip
  enddo
  for i := 1 to len(arr_k_usl)
    fl := .f. ; fl_oms := .f.
    select USL
    set order to 1
    find (arr_k_usl[i,1])
    if found()
      fl := .t. ; lu_cena := 0
      if glob_task == X_PLATN  // для платных услуг
        lu_cena := if(lvzros_reb==0, usl->pcena, usl->pcena_d)
        if human->tip_usl==PU_D_SMO .and. usl->dms_cena > 0
          lu_cena := usl->dms_cena
        endif
        lis_nul := usl->is_nulp
      elseif glob_task == X_KASSA  // для lpukassa.exe
        v := CenaUslDate(human->k_data,usl->kod)
        lu_cena := if(lvzros_reb==0, v[1], v[2])
        lis_nul := .f.
      else  // для ОМС услуг
        lu_cena := if(lvzros_reb==0, usl->cena, usl->cena_d)
        if (v := f1cena_oms(usl->shifr,;
                            opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data),;
                            (lvzros_reb==0),;
                            human->k_data,;
                            usl->is_nul,;
                            @fl_oms)) != NIL
          lu_cena := v
        endif
        lis_nul := usl->is_nul
      endif
      if empty(lu_cena) .and. !lis_nul
        fl := func_error(1,"В услуге "+alltrim(arr_k_usl[i,1])+" не проставлена цена!")
      else
        select UO
        find (str(usl->kod,4))
        if found() .and. glob_task != X_KASSA .and. !(chr(m1otd) $ uo->otdel)
          fl := func_error(1,"Услугу "+alltrim(arr_k_usl[i,1])+" запрещено вводить в данном отделении!")
        else
          select USL
          arr_k_usl[i,3] := usl->kod
          arr_k_usl[i,4] := usl->name
          arr_k_usl[i,5] := iif(lis_nul, 0, lu_cena)
          arr_k_usl[i,6] := 1
          arr_k_usl[i,8] := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          arr_k_usl[i,9] := lis_nul
          arr_k_usl[i,10] := fl_oms
        endif
      endif
    endif
    arr_k_usl[i,2] := fl
  next
  for i := 1 to len(arr_k_usl)
    if arr_k_usl[i,2]
      aadd(pr_k_usl, aclone(arr_k_usl[i]) )
    endif
  next
  if len(pr_k_usl) > 0
    mname_u := uk->name
    if !emptyall(uk->kod_vr,uk->kod_as)
      lvr_as := .t.
      mkod_vr := uk->kod_vr
      mkod_as := uk->kod_as
    endif
  endif
endif
rest_box(buf)
return ( len(pr_k_usl) > 0 )

*****
Function CenaUslDate(ldate,lkod)
Local tmp_select := select(), rec_pud, rec_puc, arr := {0,0,0}
rec_pud := pud->(recno())
rec_puc := puc->(recno())
select PUD
dbseek(dtos(ldate),.t.)
do while !eof()
  select PUC
  find (str(pud->(recno()),4)+str(lkod,4))
  if found() .and. !emptyall(puc->pcena,puc->pcena_d,puc->dms_cena)
    arr := {puc->pcena,puc->pcena_d,puc->dms_cena}
    exit
  endif
  select PUD
  skip
enddo
if emptyall(arr[1],arr[2],arr[3])
  usl->(dbGoto(lkod))
  arr := {usl->pcena,usl->pcena_d,usl->dms_cena}
endif
pud->(dbGoto(rec_pud))
puc->(dbGoto(rec_puc))
select (tmp_select)
return arr

*****
Function get_otd(mkod,r,c,fl_usl)
Local k2, fl := .f., buf, r1, r2, c2, delta, mtitle, ;
      i, a_uch := {}, kol_uch := 1
DEFAULT fl_usl TO .f.
if len(pr_arr) == 0
  return NIL
endif
if mkod == 0
  mkod := glob_otd[1]
endif
k2 := ascan(pr_arr, {|x| x[1] == mkod } )
if len(pr_arr[1]) > 2
  for i := 1 to len(pr_arr)
    if ascan(a_uch,pr_arr[i,3]) == 0
      aadd(a_uch,pr_arr[i,3])
    endif
  next
  kol_uch := len(a_uch)
endif
if r > maxrow()-9
  r2 := r - 2
  if (r1 := r2-len(pr_arr)-1) < 2
    r1 := 2
  endif
else
  r1 := r
  if (r2 := r+len(pr_arr)+1) > maxrow()-2
    r2 := maxrow()-2
  endif
endif
delta := iif(kol_uch > 1, 41, 33)
mtitle := iif(kol_uch > 1, "Выбор отделения", alltrim(glob_uch[2]))
c2 := c + delta
if c2 > maxcol()-2
  c2 := maxcol()-2 ; c := c2 - delta
endif
buf := savescreen(r1,0,maxrow(),maxcol())
status_key("^<Esc>^ - выход без выбора;  ^<Enter>^ - выбор отделения")
if (k2 := popup(r1,c,r2,c2,pr_arr_otd,k2,color0,.t.,,,mtitle,col_tit_popup)) > 0
  fl := .t.
  if fl_usl .and. mu_kod > 0
    select UO
    find (str(mu_kod,4))
    if found() .and. !(chr(pr_arr[k2,1]) $ uo->otdel)
      fl := func_error(4,"Данную услугу запрещено вводить в данном отделении!")
    endif
  endif
  if fl
    glob_otd := { pr_arr[k2,1], pr_arr[k2,2] }
    //glob_otd := { pr_arr[k2,1], pr_arr_otd[k2] }
  endif
endif
restscreen(r1,0,maxrow(),maxcol(),buf)
return if(fl, glob_otd, NIL)

*****
Function get1_otd(_1,_2,_3,_r,_c)
Local fl
if get_otd(m1otd,_r+1,_c) != NIL
  fl := .t.
  if type("mu_kod") == "N" .and. mu_kod > 0
    select UO
    find (str(mu_kod,4))
    if found() .and. !(chr(glob_otd[1]) $ uo->otdel)
      fl := func_error(4,"Данную услугу запрещено вводить в данном отделении!")
    endif
  endif
  if fl
    m1otd := glob_otd[1] ; motd := glob_otd[2]
    update_get("m1otd") ; update_get("motd")
    keyboard chr(K_DOWN)
  endif
endif
setcursor()
return NIL

***** сохранить учреждение и отделение
Function saveuchotd()
Local arr[2]
arr[1] := aclone(glob_uch)
arr[2] := aclone(glob_otd)
return arr

***** восстановить учреждение и отделение
Function restuchotd(arr)
glob_uch := aclone(arr[1])
glob_otd := aclone(arr[2])
return NIL

***** 09.08.16 определить врача по табельному номеру при вводе листа учета, услуги,...
Function v_kart_vrach(get,is_prvs)
Local fl := .t., tmp_select
Private tmp := readvar()
if &tmp != get:original
  if &tmp == 0
    m1vrach := 0
    mvrach := space(30)
    m1prvs := 0
  elseif &tmp != 0
    DEFAULT is_prvs TO .f.
    tmp_select := select()
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","P2")
    find (str(&tmp,5))
    if found()
      m1vrach := p2->kod
      m1prvs := -ret_new_spec(p2->prvs,p2->prvs_new)
      if is_prvs
        mvrach := padr(fam_i_o(p2->fio)+" "+ret_tmp_prvs(m1prvs),36)
      else
        mvrach := padr(fam_i_o(p2->fio),30)
      endif
    else
      fl := func_error(3,"Не найден сотрудник с табельным номером "+lstr(&tmp)+" в справочнике персонала!")
    endif
    p2->(dbCloseArea())
    select (tmp_select)
  endif
  if !fl
    &tmp := get:original
    return .f.
  endif
  update_get("mvrach")
endif
return .t.

***** перечитать код МО по ТФОМС и сохранить в glob_MO
Function reRead_glob_MO()
Local i, cCode, tmp_select := select()
R_Use(dir_server+"organiz",,"ORG")
cCode := left(org->kod_tfoms,6)
ORG->(dbCloseArea())
if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode})) > 0
  glob_mo := glob_arr_mo[i]
endif
select (tmp_select)
return NIL

***** проверка правильности ввода сроков лечения
Function f_k_data(get,k)
// k = 1 - дата начала лечения
// k = 2 - дата окончания лечения
if k == 2 .and. empty(mk_data)
  mk_data := get:original
  return func_error(3,"Не введена дата окончания лечения.")
endif
if k == 2 .and. ;
    !(year(mk_data) == year(sys_date) .or. year(mk_data) == year(sys_date)-1)
  mk_data := get:original
  return func_error(3,"В дате окончания лечения неверно введен год.")
endif
if !empty(mk_data) .and. mn_data > mk_data
  if k == 1
    mn_data := get:original
  else
    mk_data := get:original
  endif
  return func_error(4,"Дата начала лечения больше даты окончания лечения. Ошибка!")
endif
if k == 1 .and. type("mdate_r") == "D"
  fv_date_r(mn_data)
endif
return .t.

***** 17.01.14 переопределение критерия "взрослый/ребёнок" по дате рождения и "_date"
Function fv_date_r(_data,fl_end)
Local k, fl, cy, ldate_r := mdate_r
DEFAULT _data TO sys_date, fl_end TO .t.
if type("M1NOVOR") == "N" .and. M1NOVOR == 1 .and. type("mdate_r2") == "D"
  ldate_r := mdate_r2
  k := 1
endif
mvozrast := cy := count_years(ldate_r,_data)
mdvozrast := year(_data) - year(ldate_r)
if k == NIL
  if cy < 14     ; k := 1  // ребенок
  elseif cy < 18 ; k := 2  // подросток
  else           ; k := 0  // взрослый
  endif
endif
if type("m1vzros_reb") == "N" .and. m1vzros_reb != k
  m1vzros_reb := k
  mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  update_get("mvzros_reb")
endif
if fl_end
  if type("M1RAB_NERAB") == "N" .and. m1vzros_reb == 1 .and. M1RAB_NERAB == 0
    M1RAB_NERAB := 1
    mrab_nerab := inieditspr(A__MENUVERT, menu_rab, m1rab_nerab)
    update_get("mrab_nerab")
  endif
  if type("m1vid_ud") == "N" .and. empty(m1vid_ud)
    m1vid_ud := iif(k == 1, 3, 14)
  endif
endif
return .t.

***** 23.12.18 количество лет, месяцев и дней в строке
Function count_ymd(_mdate, _sys_date, /*@*/y, /*@*/m, /*@*/d)
// _mdate    - дата для определения количества лет, месяцев и дней
// _sys_date - "системная" дата
Local ret_s := "", md := _mdate
y := m := d := 0
if !empty(_sys_date) .and. !empty(_mdate) .and. _sys_date > _mdate
  do while (md := addmonth(md,12)) <= _sys_date
    ++y
  enddo
  if y > 0 .and. correct_count_ym(_mdate,_sys_date)
    --y  
    //my_debug(,"исправление года")
  endif
  md := addmonth(_mdate,12*y)
  do while (md := addmonth(md,1)) <= _sys_date
    ++m
  enddo
  if m > 0 .and. correct_count_ym(_mdate,_sys_date,2)
    --m  
    //my_debug(,"исправление месяца")
  endif
  md := addmonth(_mdate,12*y+m)
  do while (md := md+1) <= _sys_date
    ++d
  enddo
  if !emptyall(y,m) .and. d > 0 // только не для новорожденного
    --d
    //my_debug(,"исправление дня")
  endif
endif
if y > 0
  ret_s := lstr(y)+" "+s_let(y)+" "
endif
if m > 0
  ret_s += lstr(m)+" "+mes_cev(m)+" "
endif
if d > 0
  ret_s += lstr(d)+" "+dnej(d)
endif
return rtrim(ret_s)

***** 23.12.18 определение количества месяцев по дате (возврат числа)
Function count_months(_mdate,_sys_date)
// _mdate    - дата для определения количества лет
// _sys_date - "системная" дата
Local k := 0, s1, s2, md := _mdate
if !empty(_sys_date) .and. !empty(_mdate) .and. _sys_date > _mdate
  do while (md := addmonth(md,1)) <= _sys_date
    k++
  enddo
  if k > 0 .and. correct_count_ym(_mdate,_sys_date,2)
    --k  
  endif
endif
return k

***** 22.07.18 определение количества лет по дате (возврат числа)
Function count_years(_mdate,_sys_date)
// _mdate    - дата для определения количества лет
// _sys_date - "системная" дата
Local k := 0, s1, s2, md := _mdate
if !empty(_sys_date) .and. !empty(_mdate) .and. _sys_date > _mdate
  do while (md := addmonth(md,12)) <= _sys_date
    k++
  enddo
  if k > 0 .and. correct_count_ym(_mdate,_sys_date)
    --k  
  endif
endif
return k

***** 14.06.13 определение количества лет по дате (возврат строки)
Function ccount_years(_mdate,_sys_date)
// _mdate    - дата для определения количества полных лет
// _sys_date - "системная" дата
Local ret_s := "", y
if (y := count_years(_mdate, _sys_date)) > 0
  ret_s := lstr(y)+" "+s_let(y)
endif
return ret_s

***** 23.12.18 лицо считается достигшим определённого возраста не в день рождения, а начиная со следующих суток
Function correct_count_ym(_mdate,_sys_date,y_m) 
Local s1 := right(dtos(_mdate),4), s2 := right(dtos(_sys_date),4), fl := .f.
DEFAULT y_m TO 1 
if s1 == s2 // проверяем равенство дня и месяца
  fl := .t.
elseif s1 == "0229" .and. s2 == "0228" .and. !IsLeap(_sys_date) //_mdate - високосный год, а _sys_date - нет
  fl := .t.
elseif y_m == 2 .and. right(s1,2) == right(s2,2) // проверяем равенство дня (для опр-ия кол-ва месяцев)
  fl := .t.
endif
return fl

***** проверка ввода диагноза в случае ОМС
Function val1_10diag(fl_search,fl_plus,fl_screen,ldate,lpol)
// fl_search - искать введённый диагноз в справочнике
// fl_plus   - допускается ли ввод первично(+)/повторно(-) в конце диагноза
// fl_screen - выводить ли на экран наименование диагноза
// ldate     - дата, по которой проверяется диагноз по ОМС
// lpol      - пол для проверки допустимости ввода диагноза по полу
Local fl := .t., mshifr, tmp_select := select(), c_plus := " ", i, arr,;
      lis_talon := .f., jt, m1, s, mshifr6, fl_4
DEFAULT fl_search TO .t., fl_plus TO .f., fl_screen TO .f., ldate TO sys_date
if type("is_talon") == "L" .and. is_talon
  lis_talon := .t.
endif
Private mvar := upper(readvar())
mshifr := alltrim(&mvar)
if lis_talon
  arr := {"MKOD_DIAG" ,;
          "MKOD_DIAG2",;
          "MKOD_DIAG3",;
          "MKOD_DIAG4",;
          "MSOPUT_B1" ,;
          "MSOPUT_B2" ,;
          "MSOPUT_B3" ,;
          "MSOPUT_B4"}
  if (jt := ascan(arr,mvar)) == 0
    lis_talon := .f.
  endif
endif
if fl_plus
  if (c_plus := right(mshifr,1)) $ yes_d_plus  // "+-"
    mshifr := alltrim(left(mshifr,len(mshifr)-1))
  else
    c_plus := " "
  endif
endif
mshifr6 := padr(mshifr,6)
mshifr := padr(mshifr,5)
if empty(mshifr)
  diag_screen(2)
elseif fl_search
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
  mshifr := mshifr6
  find (mshifr)
  if found()
    fl_4 := .f.
    if !empty(ldate) .and. !between_date(diag->dbegin,diag->dend,ldate)
      fl_4 := .t.  // Диагноз не входит в ОМС
    endif
    if fl_4 .and. mem_diag4 == 2 .and. !("." $ mshifr) // если шифр трехзначный
      m1 := alltrim(mshifr)+"."
      // теперь проверим на наличие любого четырехзначного шифра
      find (m1)
      if found()
        s := ""
        for i := 0 to 9
          find (m1+str(i,1))
          if found()
            s += alltrim(diag->shifr)+","
          endif
        next
        s := substr(s,1,len(s)-1)
        &mvar := padr(m1,5)+c_plus
        fl := func_error(4,"Доступные шифры: "+s)
      endif
    endif
    if fl .and. fl_screen .and. mem_diagno == 2
      arr := {"","","",""} ; i := 1
      find (mshifr)
      arr[1] := mshifr+" "+diag->name
      skip
      do while i < 4 .and. diag->shifr == mshifr .and. !eof()
        arr[++i] := space(6)+diag->name
        skip
      enddo
      s := ""
      find (mshifr)
      if !empty(ldate) .and. !between_date(diag->dbegin,diag->dend,ldate)
        s := "Диагноз не входит в ОМС"
      endif
      if !empty(lpol) .and. !empty(diag->pol) .and. !(diag->pol == lpol)
        if empty(s)
          s := "Н"
        else
          s += ", н"
        endif
        s += "есовместимость диагноза по полу"
      endif
      if !empty(s)
        arr[4] := padc(alltrim(s)+"!",71)
        mybell()
      endif
      diag_screen(1,arr)
    endif
  else
    if "." $ mshifr  // если шифр четырехзначный
      m1 := beforatnum(".",mshifr)
      // сначала проверим на наличие трехзначного шифра
      find (m1)
      if found()
        // теперь проверим на наличие любого четырехзначного шифра
        find (m1+".")
        if found()
          s := ""
          for i := 0 to 9
            find (m1+"."+str(i,1))
            if found()
              s += alltrim(diag->shifr)+","
            endif
          next
          s := substr(s,1,len(s)-1)
          &mvar := padr(m1+".",5)+c_plus
          fl := func_error(4,"Доступные шифры: "+s)
        else
          &mvar := padr(m1,5)+c_plus
          fl := func_error(4,"Данный диагноз присутствует только в виде ТРЕХзначного шифра!")
        endif
      endif
    endif
    if fl
      &mvar := space(if(fl_plus,6,5))
      fl := func_error(4,"Диагноз с таким шифром не найден!")
    endif
  endif
  diag->(dbCloseArea())
  if tmp_select > 0
    select (tmp_select)
  endif
endif
if fl
  if right(mshifr6,1) != " "
    &mvar := mshifr6
  else
    &mvar := padr(mshifr,5)+c_plus
  endif
endif
if lis_talon .and. type("adiag_talon")=="A"
  if empty(&mvar)  // если пустой диагноз -> обнуляем добавки к нему
    for i := jt*2-1 to jt*2
      adiag_talon[i] := 0
    next
  endif
  put_dop_diag()
endif
return fl

***** упрощённая проверка ввода диагноза
Function val2_10diag()
Local fl := .t., mshifr, tmp_select := select()
Private mvar := upper(readvar())
mshifr := alltrim(&mvar)
mshifr := padr(alltrim(&mvar),5)
if !empty(mshifr)
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
  find (mshifr)
  fl := found()
  diag->(dbCloseArea())
  if tmp_select > 0
    select (tmp_select)
  endif
  if !fl
    func_error(4,"Диагноз не соответствует МКБ-10")
  endif
endif
return fl

***** запрос на ввод диагноза
Function input_10diag()
Static sshifr := "     "
Local buf := box_shadow(18,20,20,59,color8), bg := {|o,k| get_MKB10(o,k) }
Private mshifr := sshifr, ashifr := {}, fl_F3 := .f.
@ 19,26 say "Введите шифр заболевания" color color1 ;
            get mshifr PICTURE "@K@!" ;
            reader {|o| MyGetReader(o,bg) } ;
            valid val1_10diag(.f.) color color1
status_key("^<Esc>^ - отказ от ввода;  ^<Enter>^ - подтверждение ввода;  ^<F3>^ - выбор из списка")
set key K_F3 TO f1input_10diag()
myread({"confirm"})
set key K_F3 TO
if fl_F3
  sshifr := mshifr
elseif lastkey() != K_ESC .and. !empty(mshifr)
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
  find (mshifr)
  if found()
    sshifr := mshifr ; ashifr := f2input_10diag()
  else
    mshifr := ""
    func_error(4,"Диагноз с таким шифром не найден!")
  endif
  Use
endif
rest_box(buf)
return {mshifr,ashifr}

*****
Function f1input_10diag()
Local buf := savescreen(), agets, fl := .f.
Private pregim := 1, uregim := 1
set key K_F3 TO
SAVE GETS TO agets
R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
if !empty(mshifr)
  find (alltrim(mshifr))
  fl := found()
endif
if !fl
  go top
endif
if Alpha_Browse(2,1,maxrow()-2,77,"f1_10diag",color0,,,.t.,,,,"f2_10diag",,,{,,,"N/BG,W+/N,B/BG,BG+/B"} )
  fl_F3 := .t. ; mshifr := FIELD->shifr ; ashifr := f2input_10diag()
  keyboard chr(K_ENTER)
endif
close databases
restscreen(buf)
RESTORE GETS FROM agets
set key K_F3 TO f1input_10diag()
return NIL

*****
Static Function f2input_10diag()
Local arr_t := {}
do while FIELD->ks > 0
  skip -1
enddo
aadd(arr_t, alltrim(FIELD->name))
skip
do while FIELD->ks > 0
  aadd(arr_t, alltrim(FIELD->name))
  skip
enddo
return arr_t

***** меняет русские буквы на латинские при вводе диагноза
Function get_mkb10(oGet,nKey,fl_F7)
Local cKey, arr, i, mvar, mvar_old
if nKey == K_F7 .and. fl_F7 .and. !(yes_d_plus == "+-")
  arr := {"MKOD_DIAG" ,;
          "MKOD_DIAG2",;
          "MKOD_DIAG3",;
          "MKOD_DIAG4",;
          "MSOPUT_B1" ,;
          "MSOPUT_B2" ,;
          "MSOPUT_B3" ,;
          "MSOPUT_B4" ,;
          "MKOD_DIAG0"}
  mvar := readvar()
  if (i := ascan(arr,{|x| x==mvar})) > 1
    mvar_old := arr[i-1]
    if !empty(&mvar_old)
      keyboard chr(K_HOME)+left(&mvar_old,5)
    endif
  endif
elseif between(nKey, 32, 255)
  cKey := CHR( nKey )
  ************** найти ЛАТ букву, стоящую на клавиатуре там же, где и РУС
  if oGet:pos < 4  // курсор в начале
    cKey := kb_rus_lat(ckey)  // если русская буква
  endif
  if cKey == ","
    cKey := "." // замениь запятую на точку (цифровая клавиатура под Windows)
  endif
  **************
  IF ( SET( _SET_INSERT ) )
    oGet:insert( cKey )
  ELSE
    oGet:overstrike( cKey )
  ENDIF
  IF ( oGet:typeOut )
    IF ( SET( _SET_BELL ) )
      ?? CHR(7)
    ENDIF
    IF ( !SET( _SET_CONFIRM ) )
      oGet:exitState := GE_ENTER
    ENDIF
  ENDIF
ENDIF
return NIL

***** 14.01.17 ничего не делает в GET'е
Function get_without_input(oGet,nKey)
if between(nKey, 32, 255) .or. nKey == K_DEL
  oGet:right()  // сместиться вправо
  IF ( oGet:typeOut )
    IF ( SET( _SET_BELL ) )
      ?? CHR(7)
    ENDIF
    IF ( !SET( _SET_CONFIRM ) )
      oGet:exitState := GE_ENTER
    ENDIF
  ENDIF
ENDIF
return NIL

***** вернуть массив по МО с кодом ТФОМС cCode
Function ret_mo(cCode)
// cCode - код МО по ТФОМС
Local i, arr := aclone(glob_arr_mo[1]) // возьмём первое по порядку МО
for i := 1 to len(arr)
  if valtype(arr[i]) == "C"
    arr[i] := space(6) // и очистим строковые элементы
  endif
next
if !empty(cCode)
  if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode })) > 0
    arr := glob_arr_mo[i]
  elseif (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_FFOMS] == cCode })) > 0
    arr := glob_arr_mo[i]
  endif
endif
return arr

***** 18.12.14 в GET-е вернуть {_MO_SHORT_NAME,_MO_KOD_TFOMS} и по пробелу - очистка поля
Function f_get_mo(k,r,c,lusl)
Static skodN := ""
Local arr_mo3 := {}, ret, r1, r2, i, lcolor, tmp_select := select()
Private muslovie, loc_arr_MO
if lusl != NIL
  muslovie := lusl
endif
if muslovie == NIL
  if glob_task == X_PPOKOJ
    arr_mo3 := Slist2arr(pp_KEM_NAPR)
  elseif glob_task == X_OMS
    arr_mo3 := Slist2arr(mem_KEM_NAPR)
  elseif glob_task == X_263
    arr_mo3 := p_arr_stac_VO
  endif
endif
if (r1 := r+1) > int(maxrow()/2)
  r2 := r-1 ; r1 := 2
else
  r2 := maxrow()-2
endif
Private p_mo, lmo3 := 1, pkodN := skodN, _fl_space
if valtype(k) == "C" .and. !empty(k)
  pkodN := k
  if ascan(arr_mo3,k) == 0
    lmo3 := 0
  endif
endif
if empty(arr_mo3)
  lmo3 := 0
endif
dbcreate(cur_dir+"tmp_mo",{;
  {"kodN","C", 6,0},;
  {"mo3", "N", 1,0},;
  {"name","C",72,0};
 })
use (cur_dir+"tmp_mo") new alias RG
do while .t.
  zap
  if lmo3 == 0
    lcolor := color5
    for i := 1 to len(glob_arr_mo)
      loc_arr_MO := glob_arr_mo[i]
      if iif(muslovie == NIL, .t., &muslovie)
        append blank
        rg->kodN := glob_arr_mo[i,_MO_KOD_TFOMS]
        rg->name := glob_arr_mo[i,_MO_SHORT_NAME]
        if ascan(arr_mo3,rg->kodN) > 0
          rg->mo3 := 1
        endif
      endif
    next
  else
    lcolor := "N/W*,GR+/R"
    for j := 1 to len(arr_mo3)
      if (i := ascan(glob_arr_mo,{|x| x[_MO_KOD_TFOMS] == arr_mo3[j] })) > 0
        append blank
        rg->kodN := glob_arr_mo[i,_MO_KOD_TFOMS]
        rg->name := glob_arr_mo[i,_MO_SHORT_NAME]
        rg->mo3 := 1
      endif
    next
  endif
  index on upper(name) to (cur_dir+"tmp_mo")
  go top
  if empty(pkodN)
    pkodN := glob_mo[_MO_KOD_TFOMS]
  endif
  if !empty(pkodN)
    Locate for kodN == pkodN
    if !found()
      go top
    endif
  endif
  p_mo := 0 ; _fl_space = .f.
  if Alpha_Browse(r1,2,r2,77,"f2get_mo",lcolor,,,,,,,"f3get_mo")
    if _fl_space
      skodN := rg->kodN
      ret := { "", space(10) }
      exit
    elseif p_mo == 0
      skodN := rg->kodN
      ret := { rg->kodN, alltrim(rg->name) }
      exit
    endif
  elseif p_mo == 0
    exit
  endif
enddo
rg->(dbCloseArea())
select (tmp_select)
return ret

***** 18.12.14
Function f2get_mo(oBrow)
Local n := 72
oBrow:addColumn(TBColumnNew(center("Наименование МО",n), {|| padr(rg->name,n) }) )
if lmo3 == 0
  status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор МО;  ^<Пробел>^ - очистка"+iif(glob_task==X_263.or.muslovie!=NIL,"",";  ^<F3>^ - краткий список"))
else
  status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор МО;  ^<Пробел>^ - очистка"+iif(glob_task==X_263.or.muslovie!=NIL,"",";  ^<F3>^ - все МО"))
endif
return NIL

***** 18.12.14
Function f3get_mo(nkey)
Local ret := -1
if nKey == K_F3 .and. glob_task != X_263 .and. muslovie == NIL
  ret := 1
  p_mo := 1
  pkodN := rg->kodN
  lmo3 := iif(lmo3 == 0, 1, 0)
  if lmo3 == 1 .and. rg->mo3 != lmo3
    pkodN := ""
  endif
elseif nKey == K_SPACE
  _fl_space := .t.
  ret := 1
endif
return ret

***** инициализация выборки нескольких МО
Function ini_ed_mo(lval)
Local s := ""
if empty(lval)
  s := "Все МО,"
else
  aeval(glob_arr_mo, {|x| s += iif(x[_MO_KOD_TFOMS] $ lval, alltrim(x[_MO_SHORT_NAME])+",", "") })
endif
s := substr(s,1,len(s)-1)
return s

***** выбор нескольких МО
Function inp_bit_mo(k,r,c)
Static arr
Local mlen, t_mas := {}, buf := savescreen(), ret, ;
      i, tmp_color := setcolor(), m1var := "", s := "", r1, r2,;
      top_bottom := (r < maxrow()/2)
mywait()
if arr == NIL
  arr := {}
  aeval(glob_arr_mo,{|x| aadd(arr,x[_MO_SHORT_NAME])})
endif
aeval(glob_arr_mo, {|x| aadd(t_mas,iif(x[_MO_KOD_TFOMS] $ k," * ","   ")+;
                                   x[_MO_SHORT_NAME]) })
mlen := len(t_mas)
i := 1
status_key("^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins,+,->^ - смена выбора МО")
if top_bottom     // сверху вниз
  r1 := r+1
  if (r2 := r1+mlen+1) > maxrow()-2
    r2 := maxrow()-2
  endif
else
  r2 := r-1
  if (r1 := r2-mlen-1) < 2
    r1 := 2
  endif
endif
if (ret := popup(r1,2,r2,77,t_mas,i,color0,.t.,"fmenu_reader",,;
                 "Выбор наиболее часто встречающихся направляющих МО","B/BG")) > 0
  for i := 1 to mlen
    if "*" == substr(t_mas[i],2,1)
      m1var += glob_arr_mo[i,_MO_KOD_TFOMS]+","
    endif
  next
  m1var := left(m1var,len(m1var)-1)
  s := ini_ed_mo(m1var)
endif
restscreen(buf)
setcolor(tmp_color)
return iif(ret==0, NIL, {m1var,s})

***** 04.04.18 блокировать запись, где поле KOD == 0 (иначе добавить запись)
Function Add1Rec(n,lExcluUse)
Local fl := .t., lOldDeleted := SET(_SET_DELETED, .F.)
DEFAULT lExcluUse TO .f.
find (str(0,n))
if found()
  do while kod == 0 .and. !eof()
    if iif(lExcluUse, .t., RLock())
      IF DELETED()
        RECALL
      ENDIF
      fl := .f. ; exit
    endif
    skip
  enddo
endif
if fl  // добавление записи
  if lExcluUse
    APPEND BLANK
  else
    DO WHILE .t.
      APPEND BLANK
      IF !NETERR() ; exit ; ENDIF
    ENDDO
  endif
endif
SET(_SET_DELETED, lOldDeleted)  // Восстановление среды
return NIL

***** 09.02.14 функция сортировки номера счёта (для команды INDEX)
Function fsort_schet(s1,s2)
Static cDelimiter := "-"
Local s
if empty(s1)
  s := str(val(alltrim(s2)),13)
else
  s1 := alltrim(s1)
  s := padl(alltrim(token(s1,cDelimiter,2)),6,'0')+;
       padr(alltrim(token(s1,cDelimiter,3)),2)+;
       padr(alltrim(token(s1,cDelimiter,1)),5,'9')
endif
return s

***** 15.01.14 функция сортировки шифров услуг по возрастанию (для команды INDEX)
Function fsort_usl(sh_u)
Static _sg := 5
Local i, s := "", flag_z := .f., flag_0 := .f., arr
if left(sh_u,1) == "*"
  flag_z := .t.
elseif left(sh_u,1) == "0"
  flag_0 := .t.
endif
arr := usl2arr(sh_u)
for i := 1 to len(arr)
  if i == 2 .and. flag_z
    s += "9"+strzero(arr[i],_sg)  // для удаленной услуги
  elseif i == 1 .and. flag_0
    s += " "+strzero(arr[i],_sg)  // если впереди стоит 0
  else
    s += strzero(arr[i],1+_sg)
  endif
next
return s

***** 28.01.17 превратить шифр услуги в 5-мерный числовой массив
Function usl2arr(sh_u,/*@*/j)
Local i, k, c, ascc, arr := {}, cDelimiter := ".", s := alltrim(sh_u), ;
      s1 := "", is_all_digit := .t.
if left(s,1) == "*"
  s := substr(s,2)
endif
for i := 1 to len(s)
  c := substr(s,i,1) ; ascc := asc(c)
  if between(ascc,48,57) // цифры
    s1 += c
  elseif ISLETTER(c) // буквы
    is_all_digit := .f.
    if len(s1) > 0 .and. right(s1,1) != cDelimiter
      s1 += cDelimiter // искусственно вставим разделитель
    endif
    s1 += lstr(ascc)
  else // любой разделитель
    is_all_digit := .f.
    s1 += cDelimiter
  endif
next
if is_all_digit .and. eq_any((k := len(s1)),8,7)  // КСГ
  if k == 8
    aadd(arr, int(val(substr(s1,1,1))))
    aadd(arr, int(val(substr(s1,2,1))))
    aadd(arr, int(val(substr(s1,3,1))))
    aadd(arr, int(val(substr(s1,6,3))))
    aadd(arr, int(val(substr(s1,4,1))))
  else
    aadd(arr, int(val(substr(s1,1,1))))
    aadd(arr, int(val(substr(s1,2,1))))
    aadd(arr, int(val(substr(s1,3,1))))
    aadd(arr, int(val(substr(s1,5,3))))
    aadd(arr, int(val(substr(s1,4,1))))
  endif
else // остальные услуги
  k := numtoken(alltrim(s1),cDelimiter)
  for i := 1 to k
    j := int(val(token(s1,cDelimiter,i)))
    aadd(arr,j)
  next
  if (j := len(arr)) < 5
    for i := j+1 to 5
      aadd(arr,0)
    next
  endif
endif
return arr

***** 30.01.16 ф-ия between для шифров услуг 
Function between_shifr(lshifr,lshifr1,lshifr2)
Local fl := .f.
if len(lshifr) == len(lshifr1) .and. len(lshifr) == len(lshifr2)
  fl := between(lshifr,lshifr1,lshifr2) 
endif
return fl 

***** 03.01.19 является ли шифр услуги кодом КСГ
Function is_ksg(lshifr,k)
// k = nil - любая КСГ
// k = 1 - стационар
// k = 2 - дневной стационар
Static ss := "0123456789"
Local i, fl := .f.
lshifr := alltrim(lshifr)
if left(lshifr,2) == "st"
  if valtype(k) == "N"
    fl := (int(k) == 1)
  else
    fl := .t.
  endif
elseif left(lshifr,2) == "ds"
  if valtype(k) == "N"
    fl := (int(k) == 2)
  else
    fl := .t.
  endif
endif
if fl
  return fl // для 2019 года
endif  
if left(lshifr,1) $ "12" .and. substr(lshifr,5,1) == "." .and. len(lshifr) == 6 // 2018 год
  fl := .t.
  for i := 2 to 6
    if i == 5
      loop
    elseif !(substr(lshifr,i,1) $ ss)
      fl := .f. ; exit
    endif
  next
elseif !("." $ lshifr) .and. eq_any(len(lshifr),8,7) // КСГ за прошлые годы
  fl := empty(CHARREPL(ss, lshifr, SPACE(10)))
endif
if fl .and. valtype(k) == "N"
  fl := (left(lshifr,1) == lstr(k))
endif
return fl

***** исправление введённого полиса
Function val_polis(s)
Local fl := .t., i, c, s1 := ""
s := alltrim(s)
for i := 1 to len(s)
  c := substr(s,i,1)
  if between(c,'0','9') .or. isalpha(c) .or. c $ " -"
    s1 += c
  endif
next
return ltrim(charone(" ",s1))

***** вернуть имя файла без пути и расширения
Function Name_Without_Ext(cFile)
LOCAL cName
//LOCAL cPath, cName, cExt, cDrive
//IF hb_FileExists( cFile )
  //HB_FNameSplit( cFile, @cPath, @cName, @cExt, @cDrive )
//ENDIF
HB_FNameSplit(cFile,,@cName)
return cName

***** вернуть расширение файла
Function Name_Extention(cFile)
LOCAL cExt
//LOCAL cPath, cName, cExt, cDrive
//IF hb_FileExists( cFile )
  //HB_FNameSplit( cFile, @cPath, @cName, @cExt, @cDrive )
//ENDIF
HB_FNameSplit(cFile,,,@cExt)
return cExt

***** 29.10.18 возврат кода по картотеке
Function polikl1_kart()
Static sesc := "^<Esc>^ выход  "
Static senter := "^<Enter>^ ввод  "
Static sF10p := "^<F10>^ поиск по полису  "
Static sF10f := "^<F10>^ поиск по ФИО  "
Static sF10s := "^<F10>^ поиск по СНИЛС  "
Static sF11 := "^<F11>^ читать электронный полис"
Static s_regim := 1, s_shablon := "", s_polis := "", s_snils := ""
Local tmp1, tmp_help := chm_help_code, mkod := -1, i, fl_number := .t.,;
      k1 := 0, k2 := 1, str_sem, mbukva := "", tmp_color, buf, buf24, ar, s
chm_help_code := 1//HK_shablon_fio
// обмен информацией с программой Smart Delta Systems
import_kart_from_sds()
/////////////////////////////////////////////////////
Private tmp, name_reader := ""
ar := GetIniVar(tmp_ini,{{"polikl1"  ,"s_regim"  ,"1"},;
                         {"polikl1"  ,"s_shablon","" },;
                         {"polikl1"  ,"s_polis"  ,"" },;
                         {"polikl1"  ,"s_snils"  ,"" },;
                         {"RAB_MESTO","sc_reader","" }} )
if !eq_any(s_regim := int(val(ar[1])),1,2,3)
  s_regim := 1
endif
s_shablon := ar[2]
s_polis   := ar[3]
s_snils   := ar[4]
name_reader := ar[5]
do while .t.
  buf24 := save_maxrow()
  if s_regim == 1
    if empty(s_shablon)
      s_shablon := "*"
    endif
    tmp := padr(s_shablon,20)
    tmp_color := setcolor(color1)
    buf := box_shadow(18,9,20,70)
    @ 19,11 say "Введите шаблон для поиска в картотеке" get tmp pict "@K@!"
    s := sesc+senter+sF10p
    if !empty(name_reader)
      s += sF11
    endif
    status_key(alltrim(s))
  elseif s_regim == 2
    tmp := padr(s_polis,17)
    tmp_color := setcolor(color8)
    buf := box_shadow(18,9,20,70)
    @ 19,13 say "Введите ПОЛИС для поиска в картотеке" get tmp pict "@K@!"
    s := sesc+senter+sF10s
    if !empty(name_reader)
      s += sF11
    endif
    status_key(alltrim(s))
  else
    tmp := padr(s_snils,11)
    tmp_color := setcolor(color14)
    buf := box_shadow(18,9,20,70)
    @ 19,14 say "Введите СНИЛС для поиска в картотеке" get tmp pict "@K"+picture_pf valid val_snils(tmp,1)
    s := sesc+senter+sF10f
    if !empty(name_reader)
      s += sF11
    endif
    status_key(alltrim(s))
  endif
  set key K_F10 TO clear_gets
  if !empty(name_reader)
    set key K_F11 TO clear_gets
  endif
  myread({"confirm"})
  set key K_F11 TO
  set key K_F10 TO
  setcolor(tmp_color)
  rest_box(buf24)
  rest_box(buf)
  if lastkey() == K_F10
    s_regim := iif(++s_regim == 4, 1, s_regim)
  elseif lastkey() == K_F11 .and. !empty(name_reader)
    if mo_read_el_polis()
      mkod := glob_kartotek
      exit
    endif
  else
    if lastkey() == K_ESC
      tmp := NIL
    else
      if s_regim == 1
        s_shablon := alltrim(tmp)
      elseif s_regim == 2
        s_polis := tmp
      else
        s_snils := tmp
      endif
    endif
    exit
  endif
enddo
chm_help_code := tmp_help
if tmp == NIL .or. mkod > 0
  if tmp == NIL // нажали ESC
    mkod := 0
  endif
elseif s_regim == 1
  s_shablon := alltrim(tmp)
  if empty(tmp := alltrim(tmp))
    mkod := 0
  elseif tmp == "*"
    if view_kart(0,T_ROW)
      mkod := glob_kartotek
    else
      mkod := 0
    endif
  else
    if is_uchastok == 1
      tmp1 := tmp
      if !(left(tmp,1) $ "0123456789")
        mbukva := left(tmp1,1)
        tmp1 := substr(tmp1,2)  // отбросить первую букву
      endif
      for i := 1 to len(tmp1)
        if !(substr(tmp1,i,1) $ "0123456789/")
          fl_number := .f. ; exit
        endif
      next
      if fl_number
        if (i := at("/",tmp1)) == 0
          fl_number := .f.
        else
          tmp := padl(alltrim(substr(tmp1,1,i-1)),2,"0") + ;
                 padl(alltrim(substr(tmp1,i+1)),5,"0")
        endif
      endif
    else
      for i := 1 to len(tmp)
        if !(substr(tmp,i,1) $ "0123456789")
          fl_number := .f. ; exit
        endif
      next
    endif
    if !fl_number
      if !("*" $ tmp) ; tmp += "*" ; endif
    endif
    if fvalid_fio(1,tmp,fl_number,mbukva)
      mkod := glob_kartotek
    else
      fl_bad_shablon := .t.
    endif
  endif
elseif eq_any(s_regim,2,3)  // поиск по полису/по СНИЛС
  if empty(tmp)
    mkod := 0
  else
    if fvalid_fio(s_regim,tmp,fl_number,mbukva)
      mkod := glob_kartotek
    else
      fl_bad_shablon := .t.
    endif
  endif
endif
SetIniSect(tmp_ini,"polikl1",{{"s_regim"  ,lstr(s_regim)},;
                              {"s_shablon",s_shablon    },;
                              {"s_polis"  ,s_polis      },;
                              {"s_snils"  ,s_snils      }})
return mkod

***** 26.09.13 запрос года
Function input_year()
Local ky, begin_date, end_date, r1, c1, r2, c2
Store 0 TO r1, c1, r2, c2
get_row_col_max(20,15,@r1,@c1,@r2,@c2)
if (ky := input_value(r1,c1,r2,c2,color1,"За какой год желаете получить информацию",year(sys_date),"9999")) == NIL
  return NIL
endif
begin_date := end_date := chr(int(val(left(str(ky,4),2))))+chr(int(val(substr(str(ky,4),3))))
begin_date += chr(1)+chr(1)
end_date += chr(12)+chr(1)
end_date := dtoc4(eom(c4tod(end_date)))
return {ky, 1, 12, "за"+str(ky,5)+" год", c4tod(begin_date), c4tod(end_date), begin_date, end_date}

***** 31.10.13
Function year_month(rr,cc,za_v,kmp,ch_mm,ret_time)
// kmp = от 1 до 4(5)
// za_v = .t. - строка в винит.падеже
// za_v = .f. - строка в творит.падеже
Local mas2_pmt := {"За ~день","В диапа~зоне дат","За ~месяц","За ~период"}
Local ky, km, kp, ret_arr, buf, s_mes_god, ret_year, dekad_date, blk,;
      begin_date, end_date, old_set, fl, ar, r1, c1, r2, c2
Local sy, smp, sm, mbeg, mend, sdate, sdek, s1date, s1time, s2time
ar := GetIniSect(tmp_ini,"ymonth")
sy     := int(val(a2default(ar,"sy",lstr(year(sys_date)))))
sm     := int(val(a2default(ar,"sm",lstr(month(sys_date)))))
smp    := int(val(a2default(ar,"smp","3")))
mbeg   := int(val(a2default(ar,"mbeg","1")))
mend   := int(val(a2default(ar,"mend",lstr(sm))))
sdate  := stod(a2default(ar,"sdate",dtos(sys_date)))
s1date := stod(a2default(ar,"s1date",dtos(sys_date)))
sdek   := int(val(a2default(ar,"sdek","1")))
s1time := a2default(ar,"s1time","00:00")
s2time := a2default(ar,"s2time","24:00")
DEFAULT za_v TO .t., rr TO T_ROW, cc TO T_COL-5, ch_mm TO 1
ret_time := {,}
Private k1, k2
ym_kol_mes := 0  // определить количество месяцев
if kmp == NIL .and. (kmp := popup_prompt(rr,cc,smp,mas2_pmt)) == 0
  return NIL
endif
Store 0 TO r1, c1, r2, c2
if eq_any(kmp,3,4)
  get_row_col_max(20,15,@r1,@c1,@r2,@c2)
  if (ky := input_value(r1,c1,r2,c2,color1,"За какой год желаете получить информацию",sy,"9999")) == NIL
    return NIL
  endif
  ret_year := sy := ky
endif
smp := iif(kmp == 5, 2, kmp)
if kmp == 1
  get_row_col_max(18,5,@r1,@c1,@r2,@c2)
  if (dekad_date := input_value(r1,c1,r2,c2,color1,;
        "Введите дату, за которую необходимо получить информацию",;
        ctod(left(dtoc(sdate),6)+lstr(sy)))) == NIL
    return NIL
  endif
  sdate := dekad_date
  sy := ret_year := year(sdate)
  begin_date := end_date := dtoc4(sdate)
elseif eq_any(kmp,2,5) .and. ch_mm == 1
  begin_date := if(s1date>sdate,sdate,s1date)
  if kmp == 5
    begin_date := boy(begin_date)
    kmp := 2
    if type("b_year_month")=="D" .and. type("e_year_month")=="D"
      begin_date := b_year_month ; sdate := e_year_month
    endif
    keyboard chr(K_ENTER)
  endif
  blk := {|x,y| if(x > y, func_error(4,"Начальная дата больше конечной!"),.t.) }
  get_row_col_max(18,0,@r1,@c1,@r2,@c2)
  km := input_diapazon(r1,c1,r2,c2,cDataCGet,;
           {"Введите начальную","и конечную","даты для получения инф-ии"},;
           {begin_date,sdate},, blk )
  if km == NIL
    return NIL
  endif
  s1date := km[1] ; sdate := km[2]
  sy := ret_year := year(sdate)
  begin_date := dtoc4(s1date) ; end_date := dtoc4(sdate)
elseif kmp == 2 .and. ch_mm == 2
  Private m1date := s1date, m2date := sdate, m1time := s1time, m2time := s2time
  setcolor(cDataCGet)
  get_row_col_max(18,12,@r1,@c1,@r2,@c2)
  buf := box_shadow(r1,c1,r2,c2)
  fl := .f.
  do while .t.
    @ r1+1,c1+1 say "Период времени: с" get m1date
    @ row(),col() say "/"
    @ row(),col() get m1time pict "99:99"
    @ row(),col() say " по" get m2date
    @ row(),col() say "/"
    @ row(),col() get m2time pict "99:99"
    myread({"confirm"})
    if lastkey() != K_ESC
      if !v_date_time(m1date,m1time,m2date,m2time)
        loop
      endif
      s1date := m1date ; sdate := m2date
      sy := ret_year := year(sdate)
      begin_date := dtoc4(s1date) ; end_date := dtoc4(sdate)
      s1time := m1time ; s2time := m2time
      ret_time := {s1time,s2time}
      fl := .t.
    endif
    exit
  enddo
  setcolor(color0)
  rest_box(buf)
  if !fl
    return NIL
  endif
elseif kmp == 3
  if rr+12+1 > maxrow()-2
    rr := maxrow()-12-3
  endif
  if (km := popup_prompt(rr,cc,sm,mm_month)) == 0
    return NIL
  endif
  sm := km
  k1 := k2 := km
  ym_kol_mes := 1
elseif kmp == 4
  setcolor(color1)
  get_row_col_max(20,10,@r1,@c1,@r2,@c2)
  buf := box_shadow(r1,c1,r2,c2)
  k1 := mbeg;  k2 := mend
  if k1 > k2
    k1 := k2
  endif
  @ r1+1,c1+2 say "Введите начальный и конечный месяцы для периода" get k1 picture "99" valid {|| k1 >= 0}
  @ row(),col()+1 say "-" get k2 picture "99" valid {|| k1 <= k2 .and. k2 <= 12}
  myread({"confirm"})
  rest_box(buf)
  if lastkey() == K_ESC
    setcolor(color0)
    return NIL
  endif
  mbeg := k1;  mend := k2
  ym_kol_mes := k2-k1+1
endif
if za_v
  if kmp == 1
    s_mes_god := "за "+date_month(dekad_date,.t.)
  elseif kmp == 2 .and. ch_mm == 1
    s_mes_god := "в диапазоне дат от "+date_8(s1date)+"г. по "+date_8(sdate)+"г."
  elseif kmp == 2 .and. ch_mm == 2
    s_mes_god := "с "+date_8(s1date)+"("+s1time+") по "+date_8(sdate)+"("+s2time+")"
  else
    do case
      case k1 == k2
        s_mes_god := "за "+mm_month[k1]+" месяц"
      case k1 == 1 .and. k2 == 3
        s_mes_god := "за I квартал"
      case k1 == 4 .and. k2 == 6
        s_mes_god := "за II квартал"
      case k1 == 7 .and. k2 == 9
        s_mes_god := "за III квартал"
      case k1 == 10 .and. k2 == 12
        s_mes_god := "за IV квартал"
      case k1 == 1 .and. k2 == 6
        s_mes_god := "за 1-ое полугодие"
      case k1 == 7 .and. k2 == 12
        s_mes_god := "за 2-ое полугодие"
      case k1 == 1 .and. k2 == 12
        s_mes_god := ""
      otherwise
        s_mes_god := "за период с "+lstr(k1)+"-го по "+lstr(k2)+"-й месяцы"
    endcase
    if k1 == 1 .and. k2 == 12
      s_mes_god := "за"+str(ret_year,5)+" год"
    else
      s_mes_god += str(ret_year,5)+" года"
    endif
  endif
else
  if kmp == 1
    s_mes_god := date_month(dekad_date,.t.)
  elseif kmp == 2 .and. ch_mm == 1
    s_mes_god := "в диапазоне дат от "+date_8(s1date)+"г. по "+date_8(sdate)+"г."
  elseif kmp == 2 .and. ch_mm == 2
    s_mes_god := "с "+date_8(s1date)+"("+s1time+") по "+date_8(sdate)+"("+s2time+")"
  else
    do case
      case k1 == k2
        s_mes_god := "в "+mm_monthR[k1]+" месяце"
      case k1 == 1 .and. k2 == 3
        s_mes_god := "в I квартале"
      case k1 == 4 .and. k2 == 6
        s_mes_god := "во II квартале"
      case k1 == 7 .and. k2 == 9
        s_mes_god := "в III квартале"
      case k1 == 10 .and. k2 == 12
        s_mes_god := "в IV квартале"
      case k1 == 1 .and. k2 == 6
        s_mes_god := "в 1-ом полугодии"
      case k1 == 7 .and. k2 == 12
        s_mes_god := "во 2-ом полугодии"
      case k1 == 1 .and. k2 == 12
        s_mes_god := ""
      otherwise
        s_mes_god := "в период с "+lstr(k1)+"-го по "+lstr(k2)+"-й месяцы"
    endcase
    if k1 == 1 .and. k2 == 12
      s_mes_god := "в"+str(ret_year,5)+" году"
    else
      s_mes_god += str(ret_year,5)+" года"
    endif
  endif
endif
if kmp > 2
  begin_date := end_date := chr(int(val(left(str(ret_year,4),2))))+chr(int(val(substr(str(ret_year,4),3))))
  begin_date += chr(k1)+chr(1)
  end_date += chr(k2)+chr(1)
  end_date := dtoc4(eom(c4tod(end_date)))
endif
SetIniSect(tmp_ini,"ymonth",;
           {{"sy",lstr(sy)},{"sm",lstr(sm)},{"smp",lstr(smp)},;
            {"mbeg",lstr(mbeg)},{"mend",lstr(mend)},{"sdate",dtos(sdate)},;
            {"s1date",dtos(s1date)},{"sdek",lstr(sdek)},;
            {"s1time",s1time},{"s2time",s2time}})
return {ret_year, k1, k2, s_mes_god, c4tod(begin_date), c4tod(end_date), begin_date, end_date}

***** перевод левого верхнего угла прямоугольника из координат 25х80 в "maxrow(maxcol)"
Function get_row_col_max(r,c,/*@*/r1,/*@*/c1,/*@*/r2,/*@*/c2)
Local d := 24-r
r1 := maxrow()-d ; r2 := r1+2
d := int(79-2*c)
c1 := int((maxcol()-d)/2) ; c2 := c1 + d
return NIL

***** проверить дату и время на правильность периода
function v_date_time(date1,time1,date2,time2)
Local fl := .t.
if date1 > date2
  fl := func_error(4,"Начальная дата больше конечной!")
elseif date1 == date2 .and. time1 > time2
  fl := func_error(4,"Начальное время больше конечного!")
endif
return fl

*****
Function between_time(_mdate,_mtime,date1,time1,date2,time2)
// _mdate,_mtime - проверяемое время
// date1,time1,date2,time2 - проверяемый период
Local fl
DEFAULT time1 TO "00:00", time2 TO "24:00"
if (fl := between(_mdate,date1,date2))
  if _mdate == date1 .and. _mdate == date2
    fl := (f_time(_mtime) >= f_time(time1) .and. f_time(_mtime) <= f_time(time2))
  elseif _mdate == date1
    fl := (f_time(_mtime) >= f_time(time1))
  elseif _mdate == date2
    fl := (f_time(_mtime) <= f_time(time2))
  endif
endif
return fl

*****
Static Function f_time(t)
return round_5(val(substr(t,1,2))+val(substr(t,4,2))/60,5)

***** вернуть УЕТ по дате оказания услуги
Function opr_uet(lvzros_reb,k)
Local muet,mvkoef_v,makoef_v,mvkoef_r,makoef_r,mkoef_v,mkoef_r,mdate,arr,i
DEFAULT k TO 0
Store 0 TO muet,mvkoef_v,makoef_v,mvkoef_r,makoef_r,mkoef_v,mkoef_r
if select("UU") == 0
  useUch_Usl()
endif
select UU
find (str(hu->u_kod,4))
if found()
  mvkoef_v := uu->vkoef_v // врач - УЕТ для взрослого
  makoef_v := uu->akoef_v // асс. - УЕТ для взрослого
  mvkoef_r := uu->vkoef_r // врач - УЕТ для ребенка
  makoef_r := uu->akoef_r // асс. - УЕТ для ребенка
  mkoef_v  := uu->koef_v  // итого УЕТ для взрослого
  mkoef_r  := uu->koef_r  // итого УЕТ для ребенка
  //
  mdate := c4tod(hu->date_u) ; arr := {}
  select UU1
  find (str(hu->u_kod,4))
  do while uu1->kod == hu->u_kod .and.!eof()
    aadd(arr, {uu1->date_b,uu1->(recno())})
    skip
  enddo
  if len(arr) > 0
    asort(arr,,,{|x,y| x[1] >= y[1] })
    for i := 1 to len(arr)
      if mdate >= arr[i,1]
        goto (arr[i,2])
        mvkoef_v := uu1->vkoef_v // врач - УЕТ для взрослого
        makoef_v := uu1->akoef_v // асс. - УЕТ для взрослого
        mvkoef_r := uu1->vkoef_r // врач - УЕТ для ребенка
        makoef_r := uu1->akoef_r // асс. - УЕТ для ребенка
        mkoef_v  := uu1->koef_v  // итого УЕТ для взрослого
        mkoef_r  := uu1->koef_r  // итого УЕТ для ребенка
        exit
      endif
    next
  endif
endif
if lvzros_reb == 0
  do case
    case k == 0
      muet := iif(empty(mkoef_v),mkoef_r,mkoef_v)
    case k == 1
      muet := iif(empty(mvkoef_v),mvkoef_r,mvkoef_v)
    case k == 2
      muet := iif(empty(makoef_v),makoef_r,makoef_v)
  endcase
else
  do case
    case k == 0
      muet := iif(empty(mkoef_r),mkoef_v,mkoef_r)
    case k == 1
      muet := iif(empty(mvkoef_r),mvkoef_v,mvkoef_r)
    case k == 2
      muet := iif(empty(makoef_r),makoef_v,makoef_r)
  endcase
endif
return muet

***** вернуть шифр ТФОМС по дате окончания лечения
Function opr_shifr_TFOMS(lshifr,lkod,ldate)
Local tmp_select := select()
DEFAULT ldate TO sys_date
if select("USL1") == 0
  R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                              dir_server+"uslugi1s"},"USL1")
endif
select USL1
set order to 1
find (str(lkod,4))
if found()
  lshifr := space(10)
  do while usl1->kod == lkod .and. !eof()
    if usl1->date_b > ldate
      exit
    endif
    lshifr := usl1->shifr1
    skip
  enddo
endif
select (tmp_select)
return lshifr

***** 31.12.17 найти услугу по шифру ТФОМС в нашем справочнике услуг
Function foundOurUsluga(lshifr,ldate,lprofil,lvzros_reb,/*@*/lu_cena,ipar,not_cycle)
Local au := {}, s, v1, v2, mname := space(65), fl := .t., lu_kod
DEFAULT ipar TO 1, not_cycle TO .t.
lshifr := padr(lshifr,10)
select LUSL
find (lshifr)
if found()
  mname := alltrim(lusl->name)
  if len(mname) > 65 .and. eq_any(left(lshifr,2),"2.","70","72")
    mname := right(mname,65)
  endif
endif
if ipar == 1 // сначала проверим собственный шифр услуги, равный шифру ТФОМС
  select USL
  set order to 2
  find (lshifr)
  if found()
    s := space(10)
    select USL1
    set order to 1
    find (str(usl->kod,4))
    if found()
      do while usl1->kod == usl->kod .and. !eof()
        if usl1->date_b > ldate
          exit
        endif
        s := usl1->shifr1
        skip
      enddo
    endif
    if empty(s) .or. s == lshifr // поле "шифр ТФОМС" пустое или равно "lshifr"
      fl := .f.
    endif
  endif
  if fl // проверим тех, кто пользовался шифром ТФОМС
    select USL1
    set order to 2
    find (lshifr)
    do while usl1->shifr1 == lshifr .and. !eof()
      if usl1->date_b <= ldate
        aadd(au,usl1->kod)
      endif
      skip
    enddo
    select USL1
    set order to 1
    for i := 1 to len(au) // цикл по кодам услуг, по которым стоит нужный шифр ТФОМС
      s := space(10)
      find (str(au[i],4))
      do while usl1->kod == au[i] .and. !eof()
        if usl1->date_b > ldate
          exit
        endif
        s := usl1->shifr1
        skip
      enddo
      if s == lshifr
        usl->(dbGoto(au[i]))
        fl := .f. ; exit
      endif
    next
  endif
endif
if fl
  v1 := v2 := 0 // если нет услуги в справочнике ТФОМС
  select LUSL
  find (padr(lshifr,10))
  if found()
    v1 := fcena_oms(lusl->shifr,.t.,ldate)
    v2 := fcena_oms(lusl->shifr,.f.,ldate)
  endif
  select USL
  if ipar == 1
    set order to 1
  else
    set order to 2 // т.к. при вводе листа учёта индексы открыты наоборот
  endif
  FIND (STR(-1,4))
  if found()
    G_RLock(forever)
  else
    AddRec(4)
  endif
  usl->kod := recno()
  usl->name := mname
  usl->shifr := lshifr
  usl->PROFIL := lprofil
  usl->cena   := v1
  usl->cena_d := v2
  if not_cycle
    UnLock
  endif
endif
if empty(usl->name) .and. !empty(mname)
  select USL
  G_RLock(forever)
  usl->name := mname
  if not_cycle
    UnLock
  endif
endif
lu_kod := usl->kod
lu_cena := iif(lvzros_reb==0, usl->cena, usl->cena_d)
if (v1 := f1cena_oms(usl->shifr,;
                     lshifr,;
                     (lvzros_reb==0),;
                     ldate,;
                     usl->is_nul)) != NIL
  lu_cena := v1
endif
return lu_kod

***** 07.04.14 найти все услуги по шифру ТФОМС в нашем справочнике услуг
Function foundAllShifrTF(lshifr,ldate)
Local au := {}, s, ret_u := {}
lshifr := padr(lshifr,10)
// сначала проверим собственный шифр услуги, равный шифру ТФОМС
select USL
set order to 2
find (lshifr)
if found()
  s := space(10)
  select USL1
  set order to 1
  find (str(usl->kod,4))
  if found()
    do while usl1->kod == usl->kod .and. !eof()
      if usl1->date_b > ldate
        exit
      endif
      s := usl1->shifr1
      skip
    enddo
  endif
  if empty(s) .or. s == lshifr // поле "шифр ТФОМС" пустое или равно "lshifr"
    aadd(ret_u,usl->kod)
  endif
endif
// проверим тех, кто пользовался шифром ТФОМС
select USL1
set order to 2
find (lshifr)
do while usl1->shifr1 == lshifr .and. !eof()
  if usl1->date_b <= ldate
    aadd(au,usl1->kod)
  endif
  skip
enddo
select USL1
set order to 1
for i := 1 to len(au) // цикл по кодам услуг, по которым стоит нужный шифр ТФОМС
  s := space(10)
  find (str(au[i],4))
  do while usl1->kod == au[i] .and. !eof()
    if usl1->date_b > ldate
      exit
    endif
    s := usl1->shifr1
    skip
  enddo
  if s == lshifr
    aadd(ret_u,au[i])
  endif
next
return ret_u

***** 02.02.17 вернуть строку для кода дефекта
Function ret_t005(lkod)
Local s := "", tmp_select := select()
R_Use(exe_dir+"_mo_t005",cur_dir+"_mo_t005","T005")
find (str(lkod,3))
if found()
  s := alltrim(t005->name)
endif
t005->(dbCloseArea())
select (tmp_select)
return s

***** 07.02.16 вернуть строку вида ВМП
Function ret_V018(lVIDVMP,lk_data)
Local i, s := space(10)
make_V018_V019(lk_data)
if !empty(lVIDVMP) .and. (i := ascan(glob_V018, {|x| x[1] == alltrim(lVIDVMP) })) > 0
  s := glob_V018[i,1]+"."+glob_V018[i,2]
endif
return s

***** 07.02.16 вернуть строку метода ВМП
Function ret_V019(lMETVMP,lVIDVMP,lk_data)
Local i, s := space(10)
make_V018_V019(lk_data)
if !emptyany(lMETVMP,lVIDVMP) ;
            .and. (i := ascan(glob_V019, {|x| x[1] == lMETVMP })) > 0 ;
            .and. glob_V019[i,4] == alltrim(lVIDVMP)
  s := lstr(glob_V019[i,1])+"."+glob_V019[i,2]
endif
return s

***** 06.02.17 в GET-е вернуть строку из glob_V018
Function f_get_vidvmp(k,r,c)
Static sy := 0, arr, svidvmp := ""
Local ret, ret_arr, y
if (y := year(mk_data)) > 2016
  y := 2017
elseif y  == 2016
  y := 2016
else
  y := 2015
endif
if sy != y  // при первом вызове или смене года
  make_V018_V019(mk_data)
  arr := {}
  for i := 1 to len(glob_V018)
    aadd(arr,{padr(glob_V018[i,1]+"."+glob_V018[i,2],76),glob_V018[i,1]})
  next
endif
if empty(k)
  k := svidvmp
endif
popup_2array(arr,-r,c,k,1,@ret_arr,"Выбор вида ВМП","GR+/RB","BG+/RB,N/BG")
if valtype(ret_arr) == "A"
  ret := array(2)
  svidvmp := ret_arr[2]
  ret[1] := ret_arr[2]
  ret[2] := ret_arr[1]
endif
return ret

***** 17.01.14 в GET-е вернуть строку из glob_V019
Function f_get_metvmp(k,r,c,lvidvmp)
Local arr := {}, i, ret, ret_arr
if empty(lvidvmp)
  return NIL
endif
make_V018_V019(mk_data)
for i := 1 to len(glob_V019)
  if glob_V019[i,4] == alltrim(lvidvmp)
    aadd(arr, {padr(str(glob_V019[i,1],3)+"."+glob_V019[i,2],76),glob_V019[i,1]})
  endif
next
if empty(arr)
  func_error(4,"В справочнике V019 не найдено методов для вида ВМП "+lvidvmp)
  return NIL
endif
popup_2array(arr,-r,c,k,1,@ret_arr,"Выбор метода ВМП для "+lvidvmp,"GR+/RB*","N/RB*,W+/N")
if valtype(ret_arr) == "A"
  ret := array(2)
  ret[1] := ret_arr[2]
  ret[2] := ret_arr[1]
endif
return ret

***** 23.12.15 в GET'е вернуть множественный выбор учреждений/отделений 
Function ret_Nuch_Notd(k,r,c)
Local lcount_uch, lcount_otd, s
pr_a_uch := {} ; pr_a_otd := {}
if (st_a_uch := inputN_uch(-r,c,,,@lcount_uch)) != NIL
  pr_a_uch := aclone(st_a_uch)
  if len(st_a_uch) == 1
    glob_uch := st_a_uch[1]
    if (st_a_otd := inputN_otd(-r,c,.f.,.t.,glob_uch,@lcount_otd)) != NIL
      pr_a_otd := aclone(st_a_otd)
    endif
  else
    R_Use(dir_server+"mo_otd",,"OTD")
    go top
    do while !eof()
      if f_is_uch(st_a_uch,otd->kod_lpu) 
        aadd(pr_a_otd, {otd->(recno()),otd->name})
      endif
      skip
    enddo
    otd->(dbCloseArea())
  endif
endif
if (k := len(pr_a_uch)) == 0
  s := "Ничего не выбрано"
elseif k == 1 
  if (k := len(pr_a_otd)) == 1
    s := '"'+alltrim(pr_a_otd[1,2])+'" в "'+alltrim(glob_uch[2])+'"'
  else
    s := "Выбрано отделений: "+lstr(k)+' в "'+alltrim(glob_uch[2])+'"'
  endif
else  
  s := "Выбрано учреждений: "+lstr(k)
endif
return {k,charone('"',s)} 

***** 23.12.15 инициализация выборки нескольких типов счёта
Function ini_ed_tip_schet(lval)
Local s := lval
if empty(lval)
  s := "Не выбраны типы счетов"
elseif len(lval) == 18
  s := "Все типы счетов"
endif
return s

***** 22.12.15 выбор нескольких типов счёта
Function inp_bit_tip_schet(k,r,c)
Local mlen, t_mas := {}, buf := savescreen(), ret, ;
      i, tmp_color := setcolor(), m1var := "", s := "", r1, r2,;
      top_bottom := (r < maxrow()/2)
mywait()
aeval(mm_bukva, {|x| aadd(t_mas,iif(x[2] $ k," * ","   ")+x[1]) })
mlen := len(t_mas)
i := 1
status_key("^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins,+,->^ - смена выбора типа счёта")
if top_bottom     // сверху вниз
  r1 := r+1
  if (r2 := r1+mlen+1) > maxrow()-2
    r2 := maxrow()-2
  endif
else
  r2 := r-1
  if (r1 := r2-mlen-1) < 2
    r1 := 2
  endif
endif
if (ret := popup(r1,2,r2,77,t_mas,i,color0,.t.,"fmenu_reader",,;
                 "Выбор одного/нескольких/всех типов счетов","B/BG")) > 0
  for i := 1 to mlen
    if "*" == substr(t_mas[i],2,1)
      m1var += mm_bukva[i,2]
    endif
  next
  s := ini_ed_tip_schet(m1var)
endif
restscreen(buf)
setcolor(tmp_color)
return iif(ret==0, NIL, {m1var,s})
