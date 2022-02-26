***** mo_adres.prg
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static skod_volg := "18400"
// УРОВЕНЬ-1 Ter (C-2) код территории
// Начало территории 18-000-000-000-1 - Наименование территорий

// УРОВЕНЬ-2 РАЙОН ИЛИ ГОРОД областного подчинения
// Kod1 2XX-000-000-1 РАЙОН 200- шапка
// KOD1 4XX-000-000-1 ГОРОД 400- шапка
// 110-170 - автономные округа
// 200     - районы
// 400     - города
// 500-550 - города федерального подчинения
// фролово           18-428-000-000-1 ниже нет
// УРОВЕНЬ-3 (если есть)
// внутри городов (обл подчинения только РАЙОНЫ)
// KOD2 -ХХХ
// первая цифра в порядке kod2-не нужна
// центральный (в-д) 18-401-395-000-1
// для Районов области - сельсоветы.
//
// 5xx - ПОДЧИНЕННЫЕ ГОРОДА (ПОСЁЛКИ)

/***** инициализация всех БД адресного реестра
Function main()
cls
f_first()

Private MtADRES, M1tADRES := space(11)  // адрес
m1tadres := "18401395000"
//
adrr_index()
@ 1,0 say oktAdRetS(m1tadres)
//
@ 5,5 say "ОКАТО прописки  " get mtadres reader ;
          {|x| menu_reader(x,{{|k,r,c| oktAdGet(k,r,c,{m1tadres,mtadres,1}) }},A__FUNCTION,,,.f.)}
myread()

@ 2,0 say m1tadres
inkey(0)
return NIL*/


***** переиндексировать все файлы адресного реестра ОКАТО
Function okato_index(hash_files)
  Local i, fl_index := .f., ;
    arr_f  := {"_okator","_okatoo","_okatos","_okatoo8","_okatos8"},;
    arr_i1 := {"_okatr", "_okato", "_okats", "_okato8", "_okats8"},;
    arr_i2 := {"_okatrn","_okaton","_okatsn","_okaton8","_okatsn8"}
    local sbase
    local file_index, sMD5
  
  // for i := 1 to len(arr_f)
  //   if files_time(dir_exe+arr_f[i]+sdbf,cur_dir+arr_i1[i]+sntx) .or. ;
  //       files_time(dir_exe+arr_f[i]+sdbf,cur_dir+arr_i2[i]+sntx)
  //     fl_index := .t. ; exit
  //   endif
  // next
  // if fl_index
    for i := 1 to len(arr_f)
      if hb_FileExists(dir_exe + arr_f[i] + sdbf)
        sMD5 := hb_MD5File( exe_dir + arr_f[i] + sdbf )
        if ! hb_FileExists(cur_dir + arr_i1[i] + sntx) .or. ;
              ! hb_FileExists(cur_dir + arr_i2[i] + sntx) .or. ;
              ! check_izm_file_MD5(hash_files, arr_f[i], sMD5)
          R_Use(dir_exe + arr_f[i])
          oktAdIndBase(arr_f[i])
          use
        endif
        hash_files := add_hash_row(hash_files, arr_f[i], sMD5)
      endif
    next
  // endif
  return NIL


*****
Static Function oktAdIndBase(k)
k := lower(k)
do case
  case k == "_okator"
    index on okato to (cur_dir+"_okatr") progress
    index on okato+upper(substr(name,1,30)) to (cur_dir+"_okatrn") progress
  case k == "_okatoo"
    index on okato to (cur_dir+"_okato") progress
    index on substr(okato,1,5)+upper(substr(name,1,30)) to (cur_dir+"_okaton") progress
  case k == "_okatos"
    index on okato to (cur_dir+"_okats") progress
    index on substr(okato,1,8)+upper(substr(name,1,30)) to (cur_dir+"_okatsn") progress
  case k == "_okatoo8"
    index on okato to (cur_dir+"_okato8") progress
    index on substr(okato,1,5)+upper(substr(name,1,30)) to (cur_dir+"_okaton8") progress
  case k == "_okatos8"
    index on okato to (cur_dir+"_okats8") progress
    index on substr(okato,1,8)+upper(substr(name,1,30)) to (cur_dir+"_okatsn8") progress
endcase
return NIL

*

*****
Static Function oktAdUseBase(k,_region)
k := lower(k)
if _region != NIL .and. _region == "18"
  k += "8"
endif
do case
  case k == "_okator"
    R_Use(dir_exe+"_okator",{cur_dir+"_okatr",cur_dir+"_okatrn"},"REGION")
  case k == "_okatoo"
    R_Use(dir_exe+"_okatoo",{cur_dir+"_okato",cur_dir+"_okaton"},"OBLAST")
  case k == "_okatos"
    R_Use(dir_exe+"_okatos",{cur_dir+"_okats",cur_dir+"_okatsn"},"SELO")
  case k == "_okatoo8"
    R_Use(dir_exe+"_okatoo8",{cur_dir+"_okato8",cur_dir+"_okaton8"},"OBLAST")
  case k == "_okatos8"
    R_Use(dir_exe+"_okatos8",{cur_dir+"_okats8",cur_dir+"_okatsn8"},"SELO")
endcase
return NIL

*

***** ввод адреса по ОКАТО в GET'е
Function get_okato_ulica(kod11,r,c,mas_adr)
Local ret, buf, tmp_help := chm_help_code, tmp_keys
Private madrs := space(120), m1adrs := space(11), madrs1 := space(120),;
        mulicadom
if valtype(mas_adr) == "A"
  m1adrs := kod11 // или mas_adr[1]
  madrs := madrs1 := mas_adr[2]
  mulicadom := mas_adr[3]
endif
old_adrs1 := madrs1
buf := savescreen()
tmp_keys := my_savekey()
chm_help_code := 1//H_Vvod_adrs
ret := oktAdGetSt(r,c)
chm_help_code := tmp_help
my_restkey(tmp_keys)
restscreen(buf)
if ret != NIL
  aadd(ret,mulicadom) // добавляем в возврат третим элементом улицу и дом
endif
return ret

*

***** 07.02.13 ф-ия get-а адреса
Static Function oktAdGetSt(r,c)
Local tmp_color, ret, s
Private r1, c1, r2, c2
r1 := r+1 ; r2 := r1+7
if r2 > maxrow()-2
  r2 := r-1 ; r1 := r2-7
endif
c1 := 2 ; c2 := 77
box_shadow(r1,c1,r2,c2,"N+/W","Ввод адреса по ОКАТО","GR/W")
@ r2-2,c1 say "╟"+replicate("─",c2-c1-1)+"╢" color "N+/W"
Private pr_adrs := m1adrs,;
        mregion := space(63), m1region := space(11),;
        moblast := space(50), m1oblast := space(11),;
        mnas_punkt := space(39), m1nas_punkt := space(11),;
        mstr_adrs := alltrim(madrs)
Private blk_s_adrs := {|| DevPos(r2-1,c1+1), ;
                          DevOut(padc(alltrim(mstr_adrs),c2-c1-1), "W+/W") }
if empty(m1adrs)
  madrs1 := space(120)
else  // т.е. редактирование
  m1region    := left(m1adrs,2)
  m1oblast    := left(m1adrs,5)
  m1nas_punkt := left(m1adrs,11)
endif
if !empty(m1adrs)
  oktAdUseBase("_okator")
  find (m1region)
  mregion := padr(region->name,63)
  region->(dbCloseArea())
  //
  oktAdUseBase("_okatoo")
  find (m1oblast)
  moblast := padr(oblast->name,50)
  oblast->(dbCloseArea())
  //
  oktAdUseBase("_okatos")
  find (m1nas_punkt)
  mnas_punkt := padr(selo->name,39)
  selo->(dbCloseArea())
endif
//
eval(blk_s_adrs)
//
tmp_color := setcolor("N/W,W+/N,,,B/W")
@ r1+1,c1+3 say "Регион" get mregion ;
            reader {|x| menu_reader(x,;
                  {{|k,r,c| get_region(k,r,c) },63},A__FUNCTION,,,.f.)} ;
            valid {|g,o| val_AdGetSt(g,o,1) }
@ r1+2,c1+3 say "Район области/Город" get moblast ;
            reader {|x| menu_reader(x,;
                  {{|k,r,c| get_oblast(k,r,c) },50},A__FUNCTION,,,.f.)} ;
            when when_AdGetSt(2) ;
            valid {|g,o| val_AdGetSt(g,o,2) }
@ r1+3,c1+3 say "Населенный пункт/район города" get mnas_punkt ;
            reader {|x| menu_reader(x,;
                  {{|k,r,c| get_nas_punkt(k,r,c) },39},A__FUNCTION,,,.f.)} ;
            when when_AdGetSt(3) ;
            valid {|g,o| val_AdGetSt(g,o,3) }
s := "^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода адреса"
if mulicadom != NIL
  @ r1+4,c1+3 say "Улица, дом, квартира" get mulicadom ;
            when when_AdGetSt(3) ;
            valid {|g| val_AdGetSt(g,,4) }
  set key K_F3 TO v_vvod_adres
  s += ";  ^<F3>^ - выбор улицы"
endif
status_key(s)
myread()
if mulicadom != NIL
  set key K_F3 TO
endif
if lastkey() != K_ESC
  ret := {padr(alltrim(pr_adrs),11,"0"),mstr_adrs}
endif
setcolor(tmp_color)
return ret

*

***** 31.05.15
Static Function get_region(k,r,c)
Local ret, t_arr[BR_LEN], fl := .f.
Private muslovie := ".t.", str_find := ""
if r <= maxrow()/2
  t_arr[BR_TOP] := r
  t_arr[BR_BOTTOM] := maxrow()-2
else
  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := r-1
endif
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "Выбор региона РФ"
t_arr[BR_TITUL_COLOR] := "BG+/GR"
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.f.,72}
t_arr[BR_COLUMN] := {{ center("Наименование",72),{|| (region->okato+" "+region->name)} }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке") }
t_arr[BR_EDIT] := {|nk,ob| f2_adrs(nk,ob,1,"region",1) }
t_arr[BR_ENTER] := {|| ret := {region->okato,region->name} }
//
oktAdUseBase("_okator")
if empty(m1region)
  find ('18')
else
  find (m1region)
endif
fl := found()
set order to 2
if !fl
  go top
endif
edit_browse(t_arr)
region->(dbCloseArea())
return ret

*

***** 05.06.15
Static Function get_oblast(k,r,c)
Local ret, t_arr[BR_LEN], fl := .f., blk
Private muslovie := "substr(oblast->okato,1,2)==m1region",;
                 str_find := m1region, vozvr
if r <= maxrow()/2
  t_arr[BR_TOP] := r
  t_arr[BR_BOTTOM] := maxrow()-2
else
  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := r-1
endif
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "Выбор района области/города"
t_arr[BR_TITUL_COLOR] := "BG+/GR"
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,GR+/BG,GR+/N",.t.,60}
t_arr[BR_ARR_BLOCK] := {{| | FindFirst(str_find)},;
                        {| | FindLast(str_find)},;
                        {|_n| SkipPointer(_n,muslovie)},;
                        str_find,muslovie;
                       }
blk := {|| if(oblast->fl_zagol==1, {3,4},{1,2})}
t_arr[BR_COLUMN] := {{ center("Наименование",60),{|| oblast->name},blk }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке") }
t_arr[BR_EDIT] := {|nk,ob| f2_adrs(nk,ob,1,"OBLAST",2) }
t_arr[BR_ENTER] := {|| ret := {oblast->okato,oblast->name} }
//
oktAdUseBase("_okatoo",m1region)
if empty(m1oblast)
  if !empty(okato_umolch) .and. m1region == left(okato_umolch,2)
    find (left(okato_umolch,5))
    fl := found()
  endif
else
  find (m1oblast)
  fl := found()
endif
set order to 2
if !fl
  find (str_find)
  if !found()
    fl_find := func_error(4,"Не найдено областей/городов для данного региона!")
    keyboard chr(K_ESC)
  endif
endif
edit_browse(t_arr)
ret := vozvr
oblast->(dbCloseArea())
return ret

*

*****
Static Function get_nas_punkt(k,r,c)
Local ret, t_arr[BR_LEN], fl := .f.
Private muslovie := "substr(selo->okato,1,5)==m1oblast",;
        str_find := m1oblast
if r <= maxrow()/2
  t_arr[BR_TOP] := r
  t_arr[BR_BOTTOM] := maxrow()-2
else
  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := r-1
endif
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "Выбор населенного пункта ["+alltrim(moblast)+"]"
t_arr[BR_TITUL_COLOR] := "BG+/GR"
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,GR+/BG,GR+/N",.t.,60}
t_arr[BR_ARR_BLOCK] := {{| | FindFirst(str_find)},;
                        {| | FindLast(str_find)},;
                        {|_n| SkipPointer(_n,muslovie)},;
                        str_find,muslovie;
                       }
blk := {|| if(selo->fl_zagol==1, {3,4},{1,2})}
t_arr[BR_COLUMN] := {{ center("Наименование",60),{|| selo->name},blk }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке") }
t_arr[BR_EDIT] := {|nk,ob| f2_adrs(nk,ob,1,"SELO",3) }
t_arr[BR_ENTER] := {|| ret := {selo->okato,selo->name }}
//
oktAdUseBase("_okatos",m1region)
if !empty(m1nas_punkt)
  find (m1nas_punkt)
  fl := found()
endif
set order to 2
if !fl
  find (str_find)
  if !found()
    fl_find := func_error(4,"Не найдено населенных пунктов для данного района!")
    keyboard chr(K_ESC)
  endif
endif
edit_browse(t_arr)
selo->(dbCloseArea())
return ret

*

*****
Static Function f2_adrs(nk,ob,regim,lalias,regim1)
Local ret := -1, tmp_color, i, j, lf, s, rec
if nk == K_F2
  if (ret := f_poisk_adrs(@rec,ob,regim,lalias)) == 0
    ob:goTop()
    goto (rec)
  endif
elseif nk == K_ENTER
  if &lalias.->fl_zagol == 1
    // невыбираемая
  else
    if regim1 == 2
      vozvr := {oblast->okato,oblast->name}
    elseif regim1 == 3
      vozvr := {selo->okato,selo->name}
    endif
    ret := 1
  endif
endif
return ret

*****
Static Function f_poisk_adrs(ret_rec,obrow,regim,lalias)
Static stmp1 := "", stmp2 := ""
Local rec1 := recno(), buf := savescreen(), tmp_color, ret := -1, j,;
      r1 := pr2-6, r2 := pr2-1
box_shadow(r1,pc1+1,r2,pc2-1,cDataPgDn,"Поиск по ключу",cDataCSay)
tmp_color := setcolor(cDataCGet)
@ r1+2,pc1+2 say center("Введите ключевое слово",pc2-pc1-3)
do while .t.
  setcolor(cDataCGet)
  if regim == 1
    tmp := padr(stmp1,pc2-pc1-3)
  else
    tmp := padr(stmp2,pc2-pc1-3)
  endif
  status_key("^<Esc>^ - отказ от ввода")
  @ r1+3,pc1+2 get tmp picture "@K@!"
  myread()
  setcolor(color0)
  if lastkey() == K_ESC .or. empty(tmp)
    goto (rec1)
  else
    mywait()
    tmp := alltrim(tmp)
    if regim == 1
      stmp1 := tmp
    else
      stmp2 := tmp
    endif
    Private tmp_mas := {}, tmp_kod := {}, i := 0, t_len, ;
            k1 := pr1+3, k2 := pr2-1
    oBrow:goTop()
    do while &muslovie .and. !eof()
      if tmp $ upper(&lalias.->name)
        ++i
        aadd(tmp_mas, &lalias.->name)
        aadd(tmp_kod, recno())
      endif
      skip
    enddo
    if (t_len := len(tmp_kod)) == 0
      func_error(3,"Неудачный поиск!")
      loop
    else
      box_shadow(pr1,pc1,pr2,pc2)
      SETCOLOR("B/BG")
      @ pr1+1,pc1+2 say "Ключ: "+tmp
      SETCOLOR(color0)
      if t_len < pr2-pr1-5
        k2 := k1 + t_len + 2
      endif
      @ k1,pc1+1 say padc("Найденное количество - "+lstr(i),pc2-pc1-1)
      status_key("^<Esc>^ - отказ от выбора")
      if (i := popup(k1+1,pc1+1,k2,pc2-1,tmp_mas,1,0)) > 0
        ret_rec := tmp_kod[i]
        ret := 0
      endif
    endif
  endif
  exit
enddo
goto (rec1)
restscreen(buf)
setcolor(tmp_color)
return ret

*

*****
Static Function when_AdGetSt(regim)
Local ret := .T., len_okato := len(alltrim(pr_adrs))
if regim == 2 .and. len_okato < 2 // районы
  ret := func_error(3,"Не выбран РЕГИОН!")
elseif regim == 3 .and. len_okato < 5 // нас.пункт (улица)
  ret := func_error(3,"Не выбран РАЙОН области или ГОРОД!")
endif
return ret

*****
Static Function val_AdGetSt(get,old,regim)
if regim < 4 .and. old == NIL
  return .t.
endif
do case
  case regim == 1  // районы
    if !(m1region == old) //.and. m1region > 0
      pr_adrs := padr(m1region,11,"0")
      mstr_adrs := ret_okato_ulica(mulicadom,pr_adrs)
      m1oblast := m1nas_punkt := space(11)
      moblast := space(50)
      mnas_punkt := space(39)
    endif
  case regim == 2  // районы
    if !(m1oblast == old)
      pr_adrs := padr(m1oblast,11,"0")
      mstr_adrs := ret_okato_ulica(mulicadom,pr_adrs)
      m1nas_punkt := space(11)
      mnas_punkt := space(39)
    endif
  case regim == 3  // поселки
    if !(m1nas_punkt == old)
      pr_adrs := padr(m1nas_punkt,11,"0")
      mstr_adrs := ret_okato_ulica(mulicadom,pr_adrs)
    endif
  case regim == 4  // улица
    if !(mulicadom == get:original)
      mstr_adrs := ret_okato_ulica(mulicadom,pr_adrs)
    endif
endcase
eval(blk_s_adrs)
return update_gets()

*

***** вернуть адрес в строке
Static Function oktAdRetS(kod11,is_region,open_base)
// is_region = 0 - не выводить нашу область
// is_region = 1 - не выводить нашу область для Волгограда
// is_region = 2 - выводить область
Local lregion, lnas_punkt, loblast, tmp_select := select()
DEFAULT is_region TO 0, open_base TO .t.
//
if open_base
  oktAdUseBase("_okator")
else
  select REGION
endif
find (left(kod11,2))
lregion := region->name
if open_base
  region->(dbCloseArea())
  oktAdUseBase("_okatoo")
else
  select OBLAST
endif
find (left(kod11,5))
loblast := oblast->name
if open_base
  oblast->(dbCloseArea())
  oktAdUseBase("_okatos")
else
  select SELO
endif
find (kod11)
lnas_punkt := selo->name
if open_base
  selo->(dbCloseArea())
endif
if left(kod11,2) == "18" .and. is_region == 0
  lregion := "" // не выводим наименование Волгоградской области
elseif left(kod11,5) == "18401" .and. is_region == 1
  lregion := "" // для Волгограда не выводим наименование области
endif
select (tmp_select)
return alltrim(rtrim(lregion)+" "+rtrim(loblast)+" "+lnas_punkt)

***** 11.03.15 вернуть адрес вместе с улицей
Function ret_okato_ulica(_adres,_okato,_region,_par)
Local s
DEFAULT _par TO 1
_adres := alltrim(charone(" ",_adres))
if _par == 1 // сначала улица
  s := iif(empty(_adres), "", _adres+" / ")+oktAdRetS(_okato,_region)
else // в конце улица
  s := oktAdRetS(_okato,_region)+iif(empty(_adres), "", " "+_adres)
endif
return iif(empty(s), space(10), s)

*

***** вернуть адрес в массиве
Function ret_okato_Array(kod11,open_base)
Local arr_okato := {"","","",""}
DEFAULT open_base TO .t.
//
if open_base
  oktAdUseBase("_okator")
else
  select REGION
endif
find (left(kod11,2))
arr_okato[1] := alltrim(region->name)
if left(kod11,2) == '40'
  arr_okato[1] := 'г.Санкт-Петербург'
elseif left(kod11,2) == '45'
  arr_okato[1] := 'г.Москва'
elseif left(kod11,2) == '67'
  arr_okato[1] := 'г.Севастополь'
endif
//
if open_base
  region->(dbCloseArea())
  oktAdUseBase("_okatoo")
else
  select OBLAST
endif
find (left(kod11,5))
if oblast->tip == 3 // города
  arr_okato[3] := alltrim( oblast->name)
elseif oblast->tip == 4 // федеральные города
  arr_okato[3] := alltrim( oblast->name)
else
  arr_okato[2] := alltrim( oblast->name)
endif
if open_base
  oblast->(dbCloseArea())
endif
//
if !(left(kod11,6) == "184013") // ни один из районов Волгограда
  if open_base
    oktAdUseBase("_okatos")
  else
    select SELO
  endif
  find (kod11)
  if found()
    arr_okato[4] := alltrim(selo->name)
  endif
  if open_base
    selo->(dbCloseArea())
  endif
endif
//
return arr_okato
