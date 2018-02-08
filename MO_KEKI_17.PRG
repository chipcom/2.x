***** mo_keki_17.prg - режимы информации для задачи "КЭК" с 2017 года
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 18.12.17
Function kek_svod_rez_17()
Local i, iu, su, ab, ar, adbf, sh, HH := 42, reg_print, n_file := "svod_rez_17"+stxt
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  adbf := {;
    {"otd",    "N", 3, 0},;
    {"kol1",   "N", 6, 0},;
    {"kol2",   "N", 6, 0},;
    {"kol3",   "N", 6, 0},;
    {"kold1",  "N", 6, 0},;
    {"kold2",  "N", 6, 0},;
    {"kold3",  "N", 6, 0},;
    {"koldef1","N", 6, 0},;
    {"koldef2","N", 6, 0},;
    {"koldef3","N", 6, 0}}
  dbcreate(cur_dir+"tmp",adbf)
  use (cur_dir+"tmp") new
  index on str(otd,3) to (cur_dir+"tmp")
  R_Use(dir_server+"base1",,"B1")
  R_Use(dir_server+"mo_keke",dir_server+"mo_keket","EKS")
  R_Use(dir_server+"human",,"HUMAN")
  R_Use(dir_server+"mo_kekh",,"HU")
  set relation to kod_lu into HUMAN
  go top
  do while !eof()
    if between(human->k_data,arr_m[5],arr_m[6])
      ar := {0,hu->otd}
      select EKS
      find (str(hu->(recno()),7))
      do while eks->kod == hu->(recno())
        ab := f_ball_kek(hu->ishod)
        b1->(dbGoto(eks->kod_eks))
        iu := b1->p6
        if !between(iu,1,3)
          iu := 1
        endif
        su := lstr(iu)
        for i := 1 to len(ar)
          select TMP
          find (str(ar[i],3))
          if !found()
            append blank
            tmp->otd := ar[i]
          endif
          &("tmp->kol"+su) := &("tmp->kol"+su) + 1
          if ab[3] > 0
            &("tmp->kold"+su) := &("tmp->kold"+su) + 1
            &("tmp->koldef"+su) := &("tmp->koldef"+su) + ab[3]
          endif
        next
        select EKS
        skip
      enddo
    endif
    select HU
    skip
  enddo
  arr_title := {;
"──────────────────────────────┬───────────────────────────┬───────────────────────────┬────────────────────────────",;
"                              │    Кол-во экспертиз,      │  % случаев  с  дефектами, │ Среднее кол-во дефектов на ",;                        
"                              │    в т.ч. по уровням      │     в т.ч. по уровням     │ 1 случай,в т.ч. по уровням ",;                          
" Структурные подразделения    ├──────┬──────┬──────┬──────┼──────┬──────┬──────┬──────┼──────┬──────┬──────┬───────",;
"                              │ Всего│  1   │  2   │  3   │ Всего│  1   │  2   │  3   │ Всего│  1   │  2   │  3    ",;
"──────────────────────────────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴───────"}
  reg_print := 2
  f_reg_print(arr_title,@sh)
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string(center("Сводные результаты экспертной оценки качества по учреждению",sh))
  add_string(center(arr_m[4],sh))
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+"mo_otd",,"OTD")
  select TMP
  set relation to otd into OTD 
  index on padr(iif(otd==0,"ЯЯЯЯЯЯЯЯЯЯ",upper(otd->name)),30)+str(otd,3) to (cur_dir+"tmp")
  go top
  do while !eof()
    if tmp->otd == 0
      add_string(replicate("─",sh))
      s := "ИТОГО:"
    else
      s := otd->name
    endif
    s1 := "" ; v1 := 0
    for iu := 1 to 3
      su := lstr(iu)
      v1 += &("tmp->kol"+su)
      s1 += put_val(&("tmp->kol"+su),6)+" "
    next
    s := padr(s,30)+put_val(v1,6)+" "+s1  
    s2 := "" ; v2 := 0
    for iu := 1 to 3
      su := lstr(iu)
      v2 += &("tmp->kold"+su)
      s2 += str_0(&("tmp->kold"+su)/&("tmp->kol"+su)*100,7,2,.t.)
    next
    s += str_0(v2/v1*100,7,2,.t.)+s2
    s3 := "" ; v3 := 0
    for iu := 1 to 3
      su := lstr(iu)
      v3 += &("tmp->koldef"+su)
      s3 += str_0(&("tmp->koldef"+su)/&("tmp->kold"+su),7,2,.t.)
    next
    s += str_0(v3/v2,7,2,.t.)+s3
    add_string(s)
    select TMP
    skip
  enddo
  fclose(fp)
  close databases
  Private yes_albom := .t.
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
return NIL

***** 19.12.17
Function kek_har_def_17(par,par2)
Local i, iu, su, ab, ar := {-1,0}, adbf, sh, HH := 42, reg_print, n_file := "har_def_17"+stxt
DEFAULT par2 TO 0
mywait()
adbf := {;
  {"kod",  "N", 7, 0},;
  {"kol",  "N", 6, 0},;
  {"k_1",  "N", 6, 0},;   
  {"k_2",  "N", 6, 0},;   
  {"k_3",  "N", 6, 0},;   
  {"k_4",  "N", 6, 0},;   
  {"k_5",  "N", 6, 0},;   
  {"k_6",  "N", 6, 0},;   
  {"k_d",  "N", 6, 0}}    
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
index on str(kod,7) to (cur_dir+"tmp")
R_Use(dir_server+"mo_keke",dir_server+"mo_keket","EKS")
R_Use(dir_server+"human",,"HUMAN")
R_Use(dir_server+"mo_kekh",,"HU")
set relation to kod_lu into HUMAN
go top
do while !eof()
  if (fl := between(human->k_data,arr_m[5],arr_m[6]))
    if par2 == 1
      fl := hu->otd==kek_otd[1]
    elseif par2 == 3
      fl := hu->POVOD_EKS==ke[2]
    elseif par2 == 4
      fl := hu->vrach==kek_vrach[1]
    elseif par2 == 5
      fl := left(hu->kod_diag,3)==ke[2]
    endif
  endif
  if fl
    select EKS
    find (str(hu->(recno()),7))
    do while eks->kod == hu->(recno()) .and. !eof()
      if par2 == 2
        fl := eks->kod_eks==ke[2]
      endif
      if fl
        ab := f_ball_kek(hu->ishod)
        do case
          case par == 1
            ar[2] := hu->otd
          case par == 2
            ar[2] := eks->kod_eks
          case par == 3
            ar[2] := hu->POVOD_EKS
          case par == 4
            ar[2] := hu->vrach
          case par == 5
            ar[2] := hu->(recno())
        endcase
        for j := 1 to 2
          select TMP
          find (str(ar[j],7))
          if !found()
            append blank
            tmp->kod := ar[j]
          endif
          tmp->kol ++
          for i := 1 to 6
            pole := "tmp->k_"+lstr(i)
            &pole := &pole + ab[2,i]
          next i
          tmp->k_d += ab[3]
        next j
      endif
      select EKS
      skip
    enddo
  endif
  select HU
  skip
enddo
close databases
//
s1 := "Кол-во"
s2 := "экспер"
s3 := "тиз   "
do case
  case par == 1
    s := "Структурные подразделения"
  case par == 2
    s := "Ф.И.О. эксперта"
  case par == 3
    s := "Повод экспертизы"                                                                         
  case par == 4                                                                                     
    s := "Ф.И.О. врача"                                                                             
  case par == 5                                                                                     
    s := "Ф.И.О. больного"                                                                             
    s1 := "      "
    s2 := "Диаг- "
    s3 := "ноз   "
endcase
arr_title := {;                                                                                     
"──────────────────────────────┬──────┬─────────────────────────────────────────────────────────────────┬──────────",;
"                              │      │  Количество (абсолютное число) дефектов по группам критериев    │Итого     ",;
"                              │"+s1+"├──────────┬──────────┬──────────┬──────────┬──────────┬──────────┤количество",;
             padc(s,30)      +"│"+s2+"│оформление│диагности-│ Лечение  │Экспертная│Диспансер-│дополни-  │дефектов  ",;
"                              │"+s3+"│документа-│ка        │          │работа    │ное       │тельные   │          ",;
"                              │      │ции       │          │          │          │наблюдение│критерии  │          ",;
"──────────────────────────────┴──────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────"}
reg_print := 2
f_reg_print(arr_title,@sh)
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string(center("Характеристика дефектов качества по группам критериев",sh))
if par2 == 1
  add_string(center('по отделению: "'+alltrim(kek_otd[2])+'"',sh))
elseif par2 == 2
  add_string(center('по эксперту: "'+alltrim(charone(" ",ke[1]))+'"',sh))
elseif par2 == 3
  add_string(center('по поводу экспертизы: "'+ke[1]+'"',sh))
elseif par2 == 4
  add_string(center('по врачу: "'+alltrim(kek_vrach[2])+'"',sh))
endif  
add_string(center(arr_m[4],sh))
aeval(arr_title, {|x| add_string(x) } )
//
if par == 1
  R_Use(dir_server+"mo_otd",,"OV")
elseif par == 2
  R_Use(dir_server+"base1",,"OV")
elseif par == 4
  R_Use(dir_server+"mo_pers",,"OV")
elseif par == 5
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to kod_k into KART
  R_Use(dir_server+"mo_kekh",,"OV")
  set relation to kod_lu into HUMAN
endif
use (cur_dir+"tmp") new
if par != 3
  set relation to kod into OV
endif
su := "ЯЯЯЯЯЯЯЯЯЯ"
if par == 1
  index on padr(iif(kod<0,su,upper(ov->name)),30) to (cur_dir+"tmp")
elseif par == 4
  index on padr(iif(kod<0,su,upper(ov->fio)),50) to (cur_dir+"tmp")
elseif par == 5
  index on padr(iif(kod<0,su,upper(kart->fio)),50) to (cur_dir+"tmp")
else
  index on padr(iif(kod<0,su,str(kod,7)),30) to (cur_dir+"tmp")
endif
go top
do while !eof()
  if tmp->kod < 0
    add_string(replicate("─",sh))
    s := "ИТОГО:"
  elseif par == 1
    s := ov->name
  elseif par == 2
    s := alltrim(crypt(ov->p1,gpasskod))+"/"+alltrim(crypt(ov->p5,gpasskod))
  elseif par == 3
    s := inieditspr(A__MENUVERT, menu_povod_kek, tmp->kod)
  elseif par == 4
    s := ov->fio
  elseif par == 5
    s := padr(fam_i_o(kart->fio),22)+date_8(human->k_data)
  endif
  s := padr(s,30)
  if par == 5
    if tmp->kod < 0
      s += str(tmp->kol,6)
    else
      s += " "+padr(human->kod_diag,5)
    endif
  else
    s += str(tmp->kol,6)
  endif
  for i := 1 to 6
    pole := "tmp->k_"+lstr(i)
    s += put_val(&pole,10)+" "
  next
  s += put_val(tmp->k_d,10)
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(s)
  select TMP
  skip
enddo
fclose(fp)
close databases
Private yes_albom := .t.
viewtext(n_file,,,,(sh>80),,,reg_print)
return NIL
