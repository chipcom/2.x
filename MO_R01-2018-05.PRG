***** mo_r01.prg - функции для работы с информационным сопровождением по диспансеризации
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 11.12.17 инициализация всех файлов инф.сопровождения по диспансеризации
Function f_init_r01()
Local mo_dr00 := {; // пул пациентов, подлежащих диспансеризации/профосмотрам взрослого населения
   {"kod",        "N", 7,0},;    // код по картотеке
   {"tip",        "N", 1,0},;    // 1-диспансеризация 1 этап, 2-профосмотр
   {"n_m",        "N", 2,0},;    // месяц для диспансеризации (1-12)
   {"n_q",        "N", 1,0},;    // номер квартала для диспансеризации (1-4)
   {"REESTR",     "N", 6,0};     // код реестра по файлу "mo_dr01"
  }
Local mo_dr01m := {; // пакеты по 4 реестра за год (по кварталам)
   {"REESTR1",     "N", 6,0},; // код реестра по файлу "mo_dr01" (1-й квартал)
   {"REESTR2",     "N", 6,0},; // код реестра по файлу "mo_dr01" (2-й квартал)
   {"REESTR3",     "N", 6,0},; // код реестра по файлу "mo_dr01" (3-й квартал)
   {"REESTR4",     "N", 6,0},; // код реестра по файлу "mo_dr01" (4-й квартал)
   {"DWORK",       "D", 8,0},; // дата обработки файла;
   {"TWORK1",      "C", 5,0},; // время начала обработки;
   {"TWORK2",      "C", 5,0};  // время окончания обработки;
  } 
Local mo_dr01 := {; // отсылаемые файлы о будущих диспансеризациях взрослого населения
   {"KOD",         "N", 6,0},; // код реестра (номер записи)
   {"DSCHET",      "D", 8,0},; // дата файла
   {"NYEAR",       "N", 4,0},; // отчетный год
   {"NQUARTER",    "N", 1,0},; // отчетный квартал
   {"NN",          "N", 3,0},; // порядковый номер пакета;номер по порядку пакета в данном отчетном периоде (3 знака с лидирующим нулем);
   {"NAME_XML",    "C",26,0},; // имя XML-файла без расширения (и ZIP-архива)
   {"KOD_XML",     "N", 6,0},; // ссылка на файл "mo_xml"
   {"DATE_OUT",    "D", 8,0},; // дата отправки в ТФОМС
   {"NUMB_OUT",    "N", 2,0},; // сколько раз всего записывали файл на носитель;
   {"ANSWER",      "N", 1,0},; // 0-не было ответа, 1-получен ответ (R02)
   {"KOL",         "N", 6,0},; // количество пациентов в реестре/файле
   {"KOL_ERR",     "N", 6,0};  // количество пациентов с ошибками в реестре
  }
Local mo_dr01k := {; // список пациентов в реестрах будущих диспансеризаций
   {"REESTR",   "N", 6,0},; // код реестра по файлу "mo_dr01"
   {"KOD_K",    "N", 7,0},; // код по картотеке
   {"R01_ZAP",  "N", 6,0},; // номер позиции записи в реестре;"ZAP" в R01
   {"TIP",      "N", 1,0},; // 1-диспансеризация 1 этап, 2-профосмотр
   {"N_M",      "N", 2,0},; // месяц для диспансеризации (1-12)
   {"N_Q",      "N", 1,0},; // номер квартала для диспансеризации (1-4)
   {"ID_PAC",   "C",36,0},; // GUID пациента в R01 (создается при добавлении записи)
   {"TYPEOFREC","N", 1,0},; // 0-первично представленная запись, 1-актуализированная запись
   {"OPLATA",   "N", 1,0};  // тип оплаты: сначала 0, затем из ТФОМС 1,2,3,4
  }
Local mo_dr01e := {; // список ошибок в реестрах будущих диспансеризаций
   {"REESTR",   "N", 6,0},; // код реестра;по файлу "mo_dr01"
   {"R01_ZAP",  "N", 6,0},; // номер позиции записи в реестре;"ZAP") в R01
   {"KOD_ERR",  "N", 3,0};  // код ошибки ТК
  }
//  
Local mo_dr05 := {; // отсылаемые файлы о будущих диспансеризациях взрослого населения
   {"KOD",         "N", 6,0},; // код реестра (номер записи)
   {"REC_5P",      "N", 3,0},; // номер записи в файле mo_dr05p
   {"DSCHET",      "D", 8,0},; // дата файла
   {"NYEAR",       "N", 4,0},; // отчетный год
   {"NN",          "N", 3,0},; // порядковый номер пакета в данном отчетном периоде (3 знака с лидирующим нулем)
   {"NAME_XML",    "C",26,0},; // имя XML-файла без расширения (и ZIP-архива)
   {"KOD_XML",     "N", 6,0},; // ссылка на файл "mo_xml"
   {"DATE_OUT",    "D", 8,0},; // дата отправки в ТФОМС;;
   {"NUMB_OUT",    "N", 2,0},; // номер отправки в ТФОМС;сколько раз всего записывали файл на носитель;
   {"KOL",         "N", 6,0};  // количество пациентов в реестре/файле
  }
Local mo_dr05k := {; // кол-во пациентов в реестрах будущих диспансеризаций
   {"REESTR",   "N", 6,0},; // код реестра по файлу "mo_dr05"
   {"TIP",      "N", 1,0},; // 1-диспансеризация 1 этап, 2-профосмотр
   {"N_Y",      "N", 4,0},; // год для диспансеризации
   {"N_M",      "N", 2,0},; // месяц для диспансеризации (1-12)
   {"UCH",      "N", 2,0},; // номер участка (для отсылки в ТФОМС)
   {"REC_5P",   "N", 3,0},; // номер записи в файле mo_dr05p
   {"R05_ZAP",  "N", 6,0},; // номер позиции записи в реестре;"CODE_R" в R05
   {"KOL",      "N", 6,0},; // количество пациентов в реестре/файле
   {"OPLATA",   "N", 1,0};  // тип оплаты: сначала 0, 1 - пришла ошибка
  }
Local mo_dr05p := {; // план-график
   {"N_Y",      "N", 4,0},; // год для диспансеризации
   {"TYPEOFREC","N", 1,0},; // 0-первично представленная запись, 1-актуализированная запись
   {"KOL1",     "N", 6,0},; // количество пациентов для диспансеризации на год
   {"KOL2",     "N", 6,0},; // количество пациентов для профосмотров на год
   {"KOL1_01",  "N", 6,0},; // количество пациентов для диспансеризации на 1 месяц
   {"KOL1_02",  "N", 6,0},; // количество пациентов для диспансеризации на 2 месяц
   {"KOL1_03",  "N", 6,0},; // количество пациентов для диспансеризации на 3 месяц
   {"KOL1_04",  "N", 6,0},; // количество пациентов для диспансеризации на 4 месяц
   {"KOL1_05",  "N", 6,0},; // количество пациентов для диспансеризации на 5 месяц
   {"KOL1_06",  "N", 6,0},; // количество пациентов для диспансеризации на 6 месяц
   {"KOL1_07",  "N", 6,0},; // количество пациентов для диспансеризации на 7 месяц
   {"KOL1_08",  "N", 6,0},; // количество пациентов для диспансеризации на 8 месяц
   {"KOL1_09",  "N", 6,0},; // количество пациентов для диспансеризации на 9 месяц
   {"KOL1_10",  "N", 6,0},; // количество пациентов для диспансеризации на 10 месяц
   {"KOL1_11",  "N", 6,0},; // количество пациентов для диспансеризации на 11 месяц
   {"KOL1_12",  "N", 6,0},; // количество пациентов для диспансеризации на 12 месяц
   {"KOL2_01",  "N", 6,0},; // количество пациентов для профосмотров на 1 месяц
   {"KOL2_02",  "N", 6,0},; // количество пациентов для профосмотров на 2 месяц
   {"KOL2_03",  "N", 6,0},; // количество пациентов для профосмотров на 3 месяц
   {"KOL2_04",  "N", 6,0},; // количество пациентов для профосмотров на 4 месяц
   {"KOL2_05",  "N", 6,0},; // количество пациентов для профосмотров на 5 месяц
   {"KOL2_06",  "N", 6,0},; // количество пациентов для профосмотров на 6 месяц
   {"KOL2_07",  "N", 6,0},; // количество пациентов для профосмотров на 7 месяц
   {"KOL2_08",  "N", 6,0},; // количество пациентов для профосмотров на 8 месяц
   {"KOL2_09",  "N", 6,0},; // количество пациентов для профосмотров на 9 месяц
   {"KOL2_10",  "N", 6,0},; // количество пациентов для профосмотров на 10 месяц
   {"KOL2_11",  "N", 6,0},; // количество пациентов для профосмотров на 11 месяц
   {"KOL2_12",  "N", 6,0},; // количество пациентов для профосмотров на 12 месяц
   {"D_KZ",     "D", 8,0};  // дата приказа КЗ ВО
  }
Local mo_dr05e := {; // список ошибок в реестрах будущих диспансеризаций
   {"REESTR",   "N", 6,0},; // код реестра;по файлу "mo_dr05"
   {"R05_ZAP",  "N", 6,0},; // номер позиции записи в реестре;"ZAP") в R05
   {"KOD_ERR",  "N", 3,0};  // код ошибки ТК
  }
reconstruct(dir_server+"mo_dr01", mo_dr01 ,,,.t.)
reconstruct(dir_server+"mo_dr01m",mo_dr01m,,,.t.)
reconstruct(dir_server+"mo_dr01k",mo_dr01k,,,.t.)
reconstruct(dir_server+"mo_dr01e",mo_dr01e,,,.t.)
reconstruct(dir_server+"mo_dr05", mo_dr05 ,,,.t.)
reconstruct(dir_server+"mo_dr05p",mo_dr05p,,,.t.)
reconstruct(dir_server+"mo_dr05k",mo_dr05k,,,.t.)
reconstruct(dir_server+"mo_dr05e",mo_dr05e,,,.t.)
reconstruct(dir_server+"mo_dr00", mo_dr00 ,,,.t.)
return NIL

***** 20.12.17 Создание файла обмена R05...
Function f_create_R05()
Local buf := save_maxrow(), i
Private sgod := 2018, mkol1 := 0, mkol2 := 0, mdate := sys_date, mrec, CODE_LPU := glob_mo[_MO_KOD_TFOMS]
mywait()  
G_Use(dir_server+"mo_dr05p",,"R05p")
if lastrec() == 0
  G_RLock(.t.,forever)
endif
mrec := 1 // пока так
goto (mrec)  
if empty(r05p->n_y)
  r05p->N_Y := sgod // год для диспансеризации
  r05p->TYPEOFREC := 0 // 0-первично представленная запись, 1-актуализированная запись
  r05p->KOL1 := 0 // количество пациентов для диспансеризации на год
  r05p->KOL2 := 0 // количество пациентов для профосмотров на год
else
  //sgod := r05p->N_Y
  mkol1 := r05p->KOL1
  mkol2 := r05p->KOL2
  mdate := r05p->D_KZ
endif  
use
Private r05_nn := 0, write_reestr := .f.  
verify_packet_R05(1,{},@r05_nn)
Private is_reestr := (r05_nn > 0)
close databases 
if emptyall(mkol1,mkol2)
  keyboard chr(K_HOME)+chr(K_ENTER)
endif
mas_pmt := {"План-график на ~год",;
            "План-график по ~месяцам",;
            "~Создание файла обмена"}
mas_msg := {"Ввод/редактирование плана-графика диспансеризации на "+lstr(sgod)+" год",;
            "Ввод/редактирование плана-графика с разбивкой по месяцам",;
            "Создание файла обмена R05 с планом-графиком по месяцам и участкам"}
mas_fun := {"f1_create_R05()",;
            "f2_create_R05()",;
            "f3_create_R05()"}
popup_prompt(T_ROW,T_COL-5,1,mas_pmt,mas_msg,mas_fun)
rest_box(buf)     
return NIL

***** 10.12.17 Ввод/редактирование плана-графика диспансеризации на год
Function f1_create_R05()
Local r1 := 16, buf, buf24 := save_maxrow(), tmp_color := setcolor(cDataCGet)
buf := box_shadow(r1,2,maxrow()-2,77,,"План-график на "+lstr(sgod)+" год",color8)
@ r1+2,4 say "Дата приказа Комитета здравоохранения Волгоградской области" get mdate
@ r1+3,4 say "Плановая численность лиц, подлежащих диспансеризации" get mkol1 pict "99999"
@ r1+4,4 say "Плановая численность лиц, подлежащих профилактическим осмотрам" get mkol2 pict "99999"
if is_reestr
  status_key("^<Esc>^ - выход из режима (файл обмена R05 уже составлен)")
  mybell(0,ERR)
  clear_gets()
else
  status_key("^<Esc>^ - выход из режима;  ^<Enter>^ - подтверждение ввода")
  myread()
  if lastkey() != K_ESC .and. f_Esc_Enter(1)
    G_Use(dir_server+"mo_dr05p",,"R05p")
    goto (mrec)  
    G_RLock(forever)
    if empty(r05p->n_y)
      r05p->N_Y := sgod // год для диспансеризации
    endif
    r05p->KOL1 := mkol1 // количество пациентов для диспансеризации на год
    r05p->KOL2 := mkol2 // количество пациентов для профосмотров на год
    r05p->D_KZ := mdate
    use
  endif
endif
setcolor(tmp_color)
rest_box(buf)     
rest_box(buf24)     
return NIL

***** 10.12.17 Ввод/редактирование плана-графика с разбивкой по месяцам
Function f2_create_R05()
Local buf := savescreen(), tmp_color, t_arr[BR_LEN], blk, i, d
Private skol[2], ekol := {0,0}
tmp_color := setcolor(color5)
R_Use(dir_server+"mo_dr05p",,"R05p")
goto (mrec)
skol[1] := r05p->KOL1
skol[2] := r05p->KOL2
dbcreate("tmp1",{{"MES",   "N",2,0},;  // месяц
                 {"kol1",  "N",6,0},; 
                 {"kol2",  "N",6,0}}) 
use tmp1 new
for i := 1 to 12
  append blank
  tmp1->mes := i
  tmp1->kol1 := &("r05p->kol1_"+strzero(i,2))
  tmp1->kol2 := &("r05p->kol2_"+strzero(i,2))
  ekol[1] += tmp1->kol1
  ekol[2] += tmp1->kol2
next
if emptyall(ekol[1],ekol[2])
  for i := 1 to 12
    goto (i)
    tmp1->kol1 := round(skol[1]/12,0)
    ekol[1] += tmp1->kol1
    tmp1->kol2 := round(skol[2]/12,0)
    ekol[2] += tmp1->kol2
  next
  d := skol[1] - ekol[1]
  if d != 0
    tmp1->kol1 += d
    ekol[1] += d
  endif
  d := skol[2] - ekol[2]
  if d != 0
    tmp1->kol2 += d
    ekol[2] += d
  endif
endif
r05p->(dbCloseArea())  
select TMP1
go top
//
t_arr[BR_TOP] := 1
t_arr[BR_BOTTOM] := 17
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 40
t_arr[BR_COLOR] := color5
t_arr[BR_TITUL] := "План-график на "+lstr(sgod)+" год"
t_arr[BR_TITUL_COLOR] := "B/W"
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/W,W+/N,B/W,W+/B",.t.}
t_arr[BR_COLUMN] := {;
 { "  Месяц;проведения",           {|| padr(mm_month[tmp1->mes],10) }, blk },;
 { "  Количество;диспансеризаций", {|| str(tmp1->kol1,10) }, blk },;
 { " Количество;профосмотров",     {|| str(tmp1->kol2,8) }, blk };
}
t_arr[BR_EDIT] := {|nk,ob| f1_f2_create_R05(nk,ob,"edit") }
t_arr[BR_FL_INDEX] := .f.
if is_reestr
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход (файл обмена R05 уже составлен)") }
else  
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - редактирование количества по месяцам") }
endif  
box_shadow(19,t_arr[BR_LEFT],22,t_arr[BR_RIGHT])
@ 20,t_arr[BR_LEFT]+2 say "Итого сумма"   color color5
@ 21,t_arr[BR_LEFT]+2 say "План КЗ" color color5
f2_f2_create_R05()
Private alpha_1_rect := .t.
keyboard chr(K_RIGHT)
edit_browse(t_arr)
restscreen(buf)
if !is_reestr .and. f_Esc_Enter(1)
  G_Use(dir_server+"mo_dr05p",,"R05p")
  goto (mrec)  
  G_RLock(forever)
  for i := 1 to 12
    select TMP1
    goto (i)
    &("r05p->kol1_"+strzero(i,2)) := tmp1->kol1
    &("r05p->kol2_"+strzero(i,2)) := tmp1->kol2
  next
endif
close databases
setcolor(tmp_color)
return NIL

***** 10.12.17
Function f1_f2_create_R05(nKey,oBrow,regim)
Local ret := -1, rr := row()
if regim == "edit" .and. nKey == K_ENTER .and. between(oBrow:colPos,2,3) .and. !is_reestr
  Private mkol
  if oBrow:colPos == 2 
    ncol := 16
    mkol := tmp1->kol1 
  elseif oBrow:colPos == 3 
    ncol := 30
    mkol := tmp1->kol2 
  endif
  @ rr,ncol get mkol color "GR+/R" pict "999999"
  myread()
  if lastkey() != K_ESC
    if oBrow:colPos == 2 
      tmp1->kol1 := mkol 
    elseif oBrow:colPos == 3 
      tmp1->kol2 := mkol 
    endif
    f2_f2_create_R05()
    ret := 0
  endif
endif
return ret

***** 06.12.17
Function f2_f2_create_R05()
Local i, rec := tmp1->(recno()), rr := row(), cc := col(), lcolor[2]
afill(lcolor,color5)
afill(ekol,0)
for i := 1 to 12
  goto (i)
  ekol[1] += tmp1->kol1
  ekol[2] += tmp1->kol2
next
goto (rec)
for i := 1 to 2
  if !(ekol[i] == skol[i])
    lcolor[i] := "R/W"
  endif
next  
@ 20,15 say str(ekol[1],7) color lcolor[1]
@ 20,25 say str(ekol[2],11) color lcolor[2]
@ 21,15 say str(skol[1],7)+str(skol[2],14) color color5
SetPos(rr,cc)
return NIL

***** 20.12.17 Создание файла обмена R05
Function f3_create_R05()
Local buf := save_maxrow(), i, skol[2], ekol := {0,0}, k, fl := .t.
if !write_reestr //is_reestr
  fl := func_error(4,"Файл обмена R05 уже составлен!")
endif
Private auch := {}, ames[12,2], aumes[12,2]
if fl
  R_Use(dir_server+"mo_dr05p",,"R05p")
  goto (mrec)
  skol[1] := r05p->KOL1
  skol[2] := r05p->KOL2
  if emptyany(skol[1],skol[2])
    fl := func_error(4,"Не введён план-график на "+lstr(sgod)+" год")
  endif
  for i := 1 to 12
    ames[i,1] := &("r05p->kol1_"+strzero(i,2))
    ames[i,2] := &("r05p->kol2_"+strzero(i,2))
    ekol[1] += ames[i,1]
    ekol[2] += ames[i,2]
  next
  use
endif
if fl .and. emptyany(ekol[1],ekol[2])
  fl := func_error(4,"Не введена разбивка по месяцам плана-график на "+lstr(sgod)+" год")
endif
if fl .and. !(skol[1] == ekol[1] .and. skol[2] == ekol[2])
  fl := func_error(4,"Разбивка по месяцам в сумме не равна плану-графику на "+lstr(sgod)+" год")
endif
if fl
  waitstatus("Работа с участками...")
  R_use_base("kartotek")
  set order to 4
  R_Use(dir_server+"mo_uchvr",,"UV")
  index on str(uch,2) to (cur_dir+"tmp_uv")
  go top
  do while !eof()
    if !emptyall(uv->vrach,uv->vrachv) // привязан врач к "взрослым" участкам
      aadd(auch,{uv->uch,0}) ; i := len(auch)
      select KART
      find (strzero(uv->uch,2))
      do while uv->uch == kart->uchast .and. !eof()
        UpdateStatus()
        if year(kart->date_r)+17 < sgod .and. !kart2->(eof() .and. !(left(kart2->PC2,1)=='1'));
                                        .and. kart2->MO_PR == glob_MO[_MO_KOD_TFOMS]
          auch[i,2] ++ 
        endif
        skip
      enddo
    endif
    select UV
    skip
  enddo
  close databases
  k := 0
  for i := len(auch) to 1 step -1
    if empty(auch[i,2])
      Del_Array(auch,i)
    else
      k += auch[i,2]
    endif
  next
  for i := 1 to len(auch)
    //my_debug(,print_array(auch[i]))
  next
  for i := 1 to 12
    aumes[i,1] := f1_f3_create_R05(ames[i,1],k)
    aumes[i,2] := f1_f3_create_R05(ames[i,2],k)
    //my_debug(,print_array({i,1,ames[i,1],aumes[i,1]}))
    //my_debug(,print_array({i,2,ames[i,2],aumes[i,2]}))
  next
  rest_box(buf)
  if f_Esc_Enter("создания файла R05")
    nsh := 3
    R_Use(dir_server+"mo_dr05p",,"R05p")
    goto (mrec)
    G_Use(dir_server+"mo_dr05k",,"RHUM")
    index on str(REESTR,6) to (cur_dir+"tmp_rhum")
    G_Use(dir_server+"mo_dr05",,"REES")
    AddRecN()
    rees->KOD    := recno()
    rees->REC_5P := mrec // номер записи в файле mo_dr05p
    rees->DSCHET := sys_date
    rees->NYEAR  := sgod
    rees->NN     := r05_nn+1
    s := "R05"+"T34M"+CODE_LPU+"_"+right(strzero(rees->NYEAR,4),2)+str(0,1)+strzero(rees->NN,nsh)
    rees->NAME_XML := s
    mkod_reestr := rees->KOD
    //
    G_Use(dir_server+"mo_xml",,"MO_XML")
    AddRecN()
    mo_xml->KOD    := recno()
    mo_xml->FNAME  := s
    mo_xml->FNAME2 := ""
    mo_xml->DFILE  := rees->DSCHET
    mo_xml->TFILE  := hour_min(seconds())
    mo_xml->TIP_IN := 0
    mo_xml->TIP_OUT := _XML_FILE_R05  // тип высылаемого файла
    mo_xml->REESTR := mkod_reestr
    //
    rees->KOD_XML := mo_xml->KOD
    UnLock
    Commit
    //
    oXmlDoc := HXMLDoc():New()
    oXmlDoc:Add( HXMLNode():New( "ZL_LIST") )
     oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
      mo_add_xml_stroke(oXmlNode,"VERSION",'2.0')
      mo_add_xml_stroke(oXmlNode,"DATE_F",date2xml(mo_xml->DFILE))
      mo_add_xml_stroke(oXmlNode,"NAME_F",mo_xml->FNAME)
     oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "GENERAL_INFO" ) )
      mo_add_xml_stroke(oXmlNode,"CODEM",CODE_LPU)
      mo_add_xml_stroke(oXmlNode,"YEAR",lstr(rees->NYEAR))
      mo_add_xml_stroke(oXmlNode,"SIGN",lstr(r05p->TYPEOFREC))
      oVOLUMES := oXmlNode:Add( HXMLNode():New( "VOLUMES" ) )
       oVOLUME := oVOLUMES:Add( HXMLNode():New( "VOLUME" ) )
        mo_add_xml_stroke(oVOLUME,"PREVENTIVE_ACTION","O")
        mo_add_xml_stroke(oVOLUME,"QUANTITY",lstr(r05p->kol1))
       oVOLUME := oVOLUMES:Add( HXMLNode():New( "VOLUME" ) )
        mo_add_xml_stroke(oVOLUME,"PREVENTIVE_ACTION","R")
        mo_add_xml_stroke(oVOLUME,"QUANTITY",lstr(r05p->kol2))
     oZAPS := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZAPS" ) )
    icode := 0  
    for i := 1 to 12 // месяцы
      oZAP := oZAPS:Add( HXMLNode():New( "ZAP" ) )
       mo_add_xml_stroke(oZAP,"MONTH",lstr(i))
      for j := 1 to 2 // 1-диспансеризация 1 этап, 2-профосмотр
        oQUANTITY_INFO := oZAP:Add( HXMLNode():New( "QUANTITY_INFO" ) )
         mo_add_xml_stroke(oQUANTITY_INFO,"PR_ACTION",{"O","R"}[j])
         v := &("r05p->kol"+lstr(j)+"_"+strzero(i,2))
         mo_add_xml_stroke(oQUANTITY_INFO,"QUANTITY_MONTH",lstr(v))
         oRECORDS := oQUANTITY_INFO:Add( HXMLNode():New( "RECORDS" ) )
        for k := 1 to len(aumes[i,j]) // участки
          ++icode
          select RHUM
          AddRec(6)
          rhum->REESTR := mkod_reestr
          rhum->tip := j  // 1-диспансеризация 1 этап, 2-профосмотр
          rhum->N_Y := sgod // год для диспансеризации
          rhum->N_M := i // месяц для диспансеризации (1-12)
          rhum->UCH := aumes[i,j,k,1] // номер участка (для отсылки в ТФОМС)
          rhum->REC_5P := mrec // номер записи в файле mo_dr05p
          rhum->R05_ZAP := icode // номер позиции записи в реестре;"CODE_R" в R05
          rhum->KOL := aumes[i,j,k,2] // количество пациентов в реестре/файле
          rhum->OPLATA := 0 // тип оплаты: сначала 0...
          oRECORD := oRECORDS:Add( HXMLNode():New( "RECORD" ) )
           mo_add_xml_stroke(oRECORD,"CODE_R",lstr(icode))
           //mo_add_xml_stroke(oRECORD,"CODE_DISTRICT","")
           mo_add_xml_stroke(oRECORD,"NAME_DISTRICT",lstr(rhum->UCH))
           mo_add_xml_stroke(oRECORD,"QUANTITY_D",lstr(rhum->kol))
        next k
      next j
    next i
    name_zip := alltrim(mo_xml->FNAME)+szip ; arr_zip := {}
    stat_msg("Запись XML-файла")
    oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
    aadd(arr_zip, alltrim(mo_xml->FNAME)+sxml)
    //
    close databases
    if chip_create_zipXML(name_zip,arr_zip,.t.)
      keyboard chr(K_ESC)+chr(K_END)+chr(K_ENTER)
    endif
  endif     
endif
rest_box(buf)     
return NIL

***** 21.12.17 разбиение графика за месяц по участкам
Function f1_f3_create_R05(v,su)
Local i, d, k := 0, l := len(auch)
Local arr := array(l,2)
//my_debug(,print_array(auch)) 
//my_debug(,lstr(v)+str(su,10)) 
for i := 1 to l
  arr[i,1] := auch[i,1]
  arr[i,2] := int(v*auch[i,2]/su)
  k += arr[i,2]
  //my_debug(,print_array(arr[i])) 
next
//my_debug(,lstr(k)) 
d := v - k
if d > 0
  asort(arr,,,{|x,y| x[2] < y[2] })
  do while d > 0
    for i := 1 to l
      arr[i,2] ++
      //my_debug(,print_array(arr[i]))
      if --d == 0 ; exit ; endif
    next
  enddo 
  asort(arr,,,{|x,y| x[1] < y[1] })
endif
/*k := 0
for i := 1 to l
  k += arr[i,2]
next
my_debug(,lstr(v)+str(su,10)+str(k,10))*/ 
return aclone(arr)

***** 11.12.17 зачитать R06 во временные файлы
Function reestr_R06_tmpfile(oXmlDoc,aerr,mname_xml)
Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()
DEFAULT aerr TO {}, mname_xml TO ""
stat_msg("Распаковка/чтение/анализ файла "+beforatnum(".",mname_xml))
dbcreate(cur_dir+"tmp1file", {;
 {"_VERSION",   "C",  5,0},;
 {"_DATE_F",    "D",  8,0},;
 {"_NAME_F",    "C", 26,0},;
 {"_NAME_FE",   "C", 26,0};
})
dbcreate(cur_dir+"tmp2file", {;
 {"_N_ZAP",     "N",  6,0},; // CODE_R
 {"_PR_ACTION", "C",  1,0},;
 {"_MONTH",     "N",  2,0},;
 {"_ERROR",     "N",  3,0};
})
use (cur_dir+"tmp1file") new alias TMP1
append blank
use (cur_dir+"tmp2file") new alias TMP2
FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
  @ maxrow(),1 say padr(lstr(j),6) color cColorSt2Msg
  oXmlNode := oXmlDoc:aItems[1]:aItems[j]
  //aadd(aerr,print_array({oXmlNode:title,oXmlNode:type,oXmlNode:aItems,oXmlNode:aAttr}))
  do case
    case "ZGLV" == oXmlNode:title
      tmp1->_VERSION :=          mo_read_xml_stroke(oXmlNode,"VERSION",aerr)
      tmp1->_DATE_F  := xml2date(mo_read_xml_stroke(oXmlNode,"DATE_F", aerr))
      tmp1->_NAME_F  :=          mo_read_xml_stroke(oXmlNode,"NAME_F", aerr)
      tmp1->_NAME_FE :=          mo_read_xml_stroke(oXmlNode,"NAME_FE",aerr)
    case "ERRS" == oXmlNode:title
      select TMP2
      append blank
      tmp2->_ERROR := val(mo_read_xml_tag(oXmlNode,aerr))
    case "ZAPS" == oXmlNode:title
      select TMP2
      append blank
      tmp2->_N_ZAP     := val(mo_read_xml_stroke(oXmlNode,"CODE_R",   aerr))
      tmp2->_PR_ACTION :=     mo_read_xml_stroke(oXmlNode,"PR_ACTION",aerr)
      tmp2->_MONTH     := val(mo_read_xml_stroke(oXmlNode,"MONTH",    aerr))
      tmp2->_ERROR     := val(mo_read_xml_stroke(oXmlNode,"ERROR",    aerr))
  endcase
NEXT j
commit
rest_box(buf)
return NIL

***** 10.12.17 прочитать и "разнести" по базам данных файл R06
Function read_XML_FILE_R06(arr_XML_info,aerr,/*@*/current_i2)
Local count_in_schet := 0, bSaveHandler, ii1, ii2, i, j, k, t_arr[2], ldate_R06, s
mkod_reestr := arr_XML_info[7]
use (cur_dir+"tmp1file") new alias TMP1
ldate_R06 := tmp1->_DATE_F
R_Use(dir_server+"mo_dr05",,"REES")
goto (arr_XML_info[7])
strfile("Обрабатывается ответ ТФОМС на информационный пакет "+alltrim(rees->NAME_XML)+sxml+hb_eol()+;
        "за "+lstr(rees->NYEAR)+" год от "+date_8(rees->DSCHET)+"г."+hb_eol()+hb_eol(),cFileProtokol,.t.)
//
R_Use(dir_server+"mo_dr05k",,"RHUM")
index on str(R05_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR == mkod_reestr
use (cur_dir+"tmp2file") new alias TMP2
i := 0 ; k := lastrec()
// сначала проверка
ii1 := ii2 := 0
go top
do while !eof()
  @ maxrow(),0 say str(++i/k*100,6,2)+"%" color cColorWait
  ++ii2
  if tmp2->_N_ZAP > 0 
    select RHUM
    find (str(tmp2->_N_ZAP,6))
    if !found()
      aadd(aerr,"Не найден случай с N_ZAP = "+lstr(tmp2->_N_ZAP))
    endif
  endif
  select TMP2
  skip
enddo
close databases
if empty(aerr) // если проверка прошла успешно
  // запишем принимаемый файл (реестр СП)
  //chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
  chip_copy_zipXML(full_zip,dir_server+dir_XML_TF)
  G_Use(dir_server+"mo_xml",,"MO_XML")
  AddRecN()
  mo_xml->KOD := recno()
  mo_xml->FNAME := cReadFile
  mo_xml->DFILE := ldate_R06
  mo_xml->TFILE := ""
  mo_xml->DREAD := sys_date
  mo_xml->TREAD := hour_min(seconds())
  mo_xml->TIP_IN := _XML_FILE_R06 // тип принимаемого файла
  mo_xml->TIP_OUT := 0
  mo_xml->DWORK  := sys_date
  mo_xml->TWORK1 := cTimeBegin
  mo_xml->REESTR := mkod_reestr
  //
  mXML_REESTR := mo_xml->KOD
  use
  if ii2 > 0
    G_Use(dir_server+"mo_dr05e",,"REFR")
    index on str(REESTR,6)+str(R05_ZAP,6)+str(KOD_ERR,3) to (cur_dir+"tmp_r05e")
  endif
  G_Use(dir_server+"mo_dr05k",,"RHUM")
  index on str(R05_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR == mkod_reestr
  use (cur_dir+"tmp2file") new alias TMP2
  index on str(_n_zap,6)+str(_error,3) to (cur_dir+"tmp2")
  count_in_schet := lastrec() ; current_i2 := 0
  i := 0
  go top
  do while !eof()
    @ maxrow(),0 say str(++i/k*100,6,2)+"%" color cColorWait 
    if tmp2->_N_ZAP > 0 
      select RHUM
      find (str(tmp2->_N_ZAP,6))
      G_RLock(forever)
      rhum->OPLATA := 1
    endif
    if tmp2->_error > 0
      --count_in_schet    // не включается в счет,
      if current_i2 == 0
        strfile(space(10)+"Список ошибок:"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      endif
      ++current_i2
      if tmp2->_N_ZAP > 0 
        strfile("CODE_R="+lstr(tmp2->_N_ZAP)+iif(rhum->tip==1,", диспансеризация",", профосмотр")+;
                ", год="+lstr(rhum->n_y)+", "+mm_month[rhum->n_m]+", уч-к="+lstr(rhum->uch)+hb_eol(),cFileProtokol,.t.)
      else
        strfile("Ошибка на уровне файла"+hb_eol(),cFileProtokol,.t.)
      endif
      select REFR
      do while .t.
        find (str(mkod_reestr,6)+str(tmp2->_N_ZAP,6)+str(tmp2->_error,3))
        if !found() ; exit ; endif
        DeleteRec(.t.)
      enddo
      select REFR
      AddRec(6)
      refr->reestr := mkod_reestr
      refr->R05_ZAP := tmp2->_N_ZAP
      refr->KOD_ERR := tmp2->_ERROR
      if (j := ascan(glob_T012, {|x| x[2] == tmp2->_ERROR })) > 0
        strfile(space(8)+"ошибка "+lstr(tmp2->_ERROR)+" - "+glob_T012[j,1]+hb_eol(),cFileProtokol,.t.)
      else
        strfile(space(8)+"ошибка "+lstr(tmp2->_ERROR)+" (неизвестная ошибка)"+hb_eol(),cFileProtokol,.t.)
      endif
    endif
    UnLock ALL
    select TMP2
    if recno() % 1000 == 0
      Commit
    endif
    skip
  enddo
  if ii2 == 0
    strfile("Ошибок не обнаружено."+hb_eol(),cFileProtokol,.t.)
  endif
endif
close databases
return count_in_schet

***** 10.12.17 Просмотр файлов обмена R05... и результатов работы с ними
Function f_view_R05()
Local i, k, buf := savescreen()
Private goal_dir := dir_server+dir_XML_MO+cslash
G_Use(dir_server+"mo_xml",,"MO_XML")
R_Use(dir_server+"mo_dr05p",,"R05p")
G_Use(dir_server+"mo_dr05",,"REES")
index on dtos(dschet)+str(nn,3) to (cur_dir+"tmp_rees") DESCENDING
set relation to rec_5p into R05p
go top
if eof()
  func_error(4,"Не было создано файлов R05...")
else
  Private reg := 1
  Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1_view_R05",color0,,,,,,,;
               "f2_view_R05",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
endif
close databases
restscreen(buf)
return NIL

***** 10.12.17
Function f1_view_R05(oBrow)
Local oColumn, ;
      blk := {|| iif(hb_fileExists(goal_dir+alltrim(rees->NAME_XML)+szip), ;
                     iif(empty(rees->date_out), {3,4}, {1,2}),;
                     {5,6}) }
oColumn := TBColumnNew(" №№",{|| str(rees->nn,3) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Дата",{|| date_8(rees->dschet) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Период",{|| lstr(rees->nyear,4)+" год" })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("   Дата;приказа КЗ",{|| full_date(r05p->d_kz) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Наименование файла",{|| padr(rees->NAME_XML,20) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Примечание",{|| f11_view_R05() })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if reg == 1
  status_key("^<Esc>^ выход; ^<F5>^ запись для ТФОМС; ^<F3>^ информация о файле")
else
  status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор реестра для возврата")
endif
return NIL

***** 10.12.17
Static Function f11_view_R05()
Local s := ""
if !hb_fileExists(goal_dir+alltrim(rees->NAME_XML)+szip)
  s := "нет файла"
elseif empty(rees->date_out)
  s := "не записан"
else
  s := "зап. "+lstr(rees->NUMB_OUT)+" раз"
endif
return padr(s,10)

***** 10.12.17
Function f2_view_R05(nKey,oBrow)
Local ret := -1, rec := rees->(recno()), tmp_color := setcolor(), r, r1, r2,;
      s, buf := savescreen(), arr, i, k, mdate, t_arr[2], arr_pmt := {}
do case
  case nKey == K_F5
    zip_file := alltrim(rees->NAME_XML)+szip
    if f_Esc_Enter("записи файла R05 за "+date_8(mdate))
      Private p_var_manager := "copy_schet"
      s := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,2,.f.,,,) // "norton" для выбора каталога
      if !empty(s)
        if upper(s) == upper(goal_dir)
          func_error(4,"Вы выбрали каталог, в котором уже записан данный файл! Это недопустимо.")
        elseif hb_fileExists(goal_dir+zip_file)
          mywait('Копирование "'+zip_file+'" в каталог "'+s+'"')
          //copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
          copy file (goal_dir+zip_file) to (s+zip_file)
          //if hb_fileExists(hb_OemToAnsi(s)+zip_file)
          if hb_fileExists(s+zip_file)
            rees->(G_RLock(forever))
            rees->DATE_OUT := sys_date
            if rees->NUMB_OUT < 99
              rees->NUMB_OUT ++
            endif
            //
            mo_xml->(rees->KOD_XML)
            mo_xml->(G_RLock(forever))
            mo_xml->DREAD := sys_date
            mo_xml->TREAD := hour_min(seconds())
          else
            func_error(4,"! Ошибка записи файла "+s+zip_file)
          endif
        else
          func_error(4,"! Не обнаружен файл "+goal_dir+zip_file)
        endif  
      endif
      dbUnlockAll()
      dbCommitAll()
      n_message({"Запись завершена!"},,"GR+/B","W+/B",18,,"G+/B")
    endif
    select REES
    goto (rec)
    ret := 0
  case nKey == K_F3
    f3_view_R05(oBrow)
    ret := 0
endcase
setcolor(tmp_color)
restscreen(buf)
return ret

***** 20.03.17
Function f3_view_R05(oBrow)
Static si := 1
Local i, r := row(), r1, r2, buf := save_maxrow(), fl, s,;
      mm_func := {-99},;
      mm_menu := {"~Численность по месяцам из R05"}
mywait()
select MO_XML
index on FNAME to (cur_dir+"tmp_xml") ;
      for reestr==rees->kod .and. tip_in==_XML_FILE_R06 .and. empty(TIP_OUT)
go top
do while !eof()
  s := "Протокол чтения "+rtrim(mo_xml->FNAME)+" прочитан "+date_8(mo_xml->DWORK)
  if empty(mo_xml->TWORK2)
    s += "-ПРОЦЕСС НЕ ЗАВЕРШЁН"
  else
    s += " в "+mo_xml->TWORK1
  endif
  aadd(mm_func, mo_xml->kod)
  aadd(mm_menu, s)
  skip
enddo
select MO_XML
set index to
if r <= 12
  r1 := r+1 ; r2 := r1+len(mm_menu)+1
else
  r2 := r-1 ; r1 := r2-len(mm_menu)-1
endif
rest_box(buf)
if len(mm_menu) == 1
  i := 1
  si := i
  if mm_func[i] < 0
    f31_view_R05(abs(mm_func[i]),mm_menu[i])
  endif
elseif (i := popup_prompt(r1,10,si,mm_menu,,,color5)) > 0
  si := i
  if mm_func[i] < 0
    f31_view_R05(abs(mm_func[i]),mm_menu[i])
  else
    mo_xml->(dbGoto(mm_func[i]))
    viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+alltrim(mo_xml->FNAME)+stxt,60,80),,,,.t.,,,2)
  endif
endif
select REES
return NIL

***** 10.12.17
Function f31_view_R05(reg,s)
Local fl := .t., buf := save_maxrow(), k := 0, n_file := "r05_spis"+stxt
mywait()
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string(glob_mo[_MO_SHORT_NAME])
add_string("")
add_string(center("Численность по месяцам из файла "+alltrim(rees->NAME_XML)+" от "+date_8(rees->dschet),80))
add_string("")
add_string("Приказ Комитета здравоохранения Волгоградской области от "+full_date(r05p->d_kz)+"г.")
add_string("")
add_string("Диспансеризация опр.групп взрослого населения на "+lstr(r05p->n_y)+" год - "+lstr(r05p->kol1)+" чел.")
for i := 1 to 12
  s := iif(i == 1, "в том числе","")+" на "+mm_month[i]
  add_string(padl(s,25)+str( &("r05p->kol1_"+strzero(i,2)),6))
next  
add_string("")
add_string("Профилактические осмотры взрослых на "+lstr(r05p->n_y)+" год - "+lstr(r05p->kol2)+" чел.")
for i := 1 to 12
  s := iif(i == 1, "в том числе","")+" на "+mm_month[i]
  add_string(padl(s,25)+str( &("r05p->kol2_"+strzero(i,2)),6))
next  
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.t.,,,2)
return NIL

***** 20.12.17 
Function verify_packet_R05(par,arr,/*@*/ret_nn)
Local fl := .t.
ret_nn := 0
R_Use(dir_server+"mo_dr05e",,"REFR")
R_Use(dir_server+"mo_xml",,"MO_XML")
index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in==_XML_FILE_R06 .and. empty(TIP_OUT)
R_Use(dir_server+"mo_dr05",,"R05")
index on str(REC_5P,3)+str(1000-nn,4) to (cur_dir+"tmp_r05") for nyear == sgod
find (str(mrec,3))
if found()
  ret_nn := r05->nn
  select MO_XML
  find (str(r05->kod,6))
  if found()
    select REFR
    Locate for reestr == r05->kod
    if found()
      fl := .f.
      write_reestr := .t.
      aadd(arr,"В ответе R06 на файл обмена R05 присутствуют ошибки")
    else
      write_reestr := .f.
    endif
  else
    fl := .f.
    aadd(arr,"Не получен ответ (R06) на файл обмена R05")
    write_reestr := .f.
  endif
else
  fl := .f.
  write_reestr := .t.
  if par == 1 // не выводить данное сообщение (при запуске программы)
    aadd(arr,"Не составлен файла обмена R05")
  endif
endif
return fl

********************************************************************************

***** 30.03.18 Создание файла обмена R01...
Function f_create_R01()
Local buf := save_maxrow(), i, j, ir, s := "", arr := {}, fl := .t., fl1 := .f., a_reestr := {},;
      azip := {}, aerr := {}, full_zip, name_zip, cFile, cName, oXmlDoc
Private sgod := 2018, SQUARTER := 1, mdate := sys_date, mrec := 1
Private c_view := 0, c_found := 0, fl_exit := .f., pj, arr_rees := {},;
        pkol := 0, CODE_LPU := glob_mo[_MO_KOD_TFOMS], CODE_MO := glob_mo[_MO_KOD_FFOMS],;
        skol := {0,0}, akv[4,2], ames[12,2], bm := int(SQUARTER*3) // начальный месяц минус один        
if !myFileDeleted(cur_dir+"tmp1file"+sdbf)
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp2file"+sdbf)
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp3file"+sdbf)
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp4file"+sdbf)
  return NIL
endif
mywait()  
if (fl := verify_packet_R05(1,arr))
  select MO_XML
  index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in == _XML_FILE_R02 .and. empty(TIP_OUT)
  R_Use(dir_server+"mo_dr01",,"REES")
  index on str(nn,3)+str(NQUARTER,1) to (cur_dir+"tmp_dr01") for NYEAR == sgod
  go top
  do while !eof()
    if rees->dschet > stod(strzero(sgod,4)+strzero(bm,2)+"25")
      fl := func_error(4,"Актуализированные записи за "+lstr(SQUARTER)+" квартал "+lstr(sgod)+" года уже отправлены в ТФОМС")
      exit
    endif
    aadd(a_reestr, rees->kod)
    if rees->kol_err < 0
      //fl := func_error(4,"В файле R02 за "+lstr(rees->NQUARTER)+"-й квартал "+;
      //                   lstr(sgod)+"г. ошибки на уровне файла! Операция запрещена")
    elseif empty(rees->answer)
      fl := func_error(4,"Файл R02 за "+lstr(rees->NQUARTER)+"-й квартал "+;
                         lstr(sgod)+" года не был прочитан! Операция запрещена")
    else
      select MO_XML
      find (str(rees->kod,6)) 
      if found()
        if empty(mo_xml->TWORK2)
          fl := func_error(4,"Прервано чтение файла "+alltrim(mo_xml->FNAME)+;
                             "! Аннулируйте (Ctrl+F12) и прочитайте снова")
        else
          aadd(arr_rees,rees->kod)
        endif
      endif
    endif
    select REES
    skip
  enddo
  if fl
    select MO_XML
    index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in == _XML_FILE_R02 .and. empty(TIP_OUT)
    select REES
    index on str(nn,3) to (cur_dir+"tmp_dr01") ;
          for NYEAR == sgod .and. NQUARTER == SQUARTER .and. ANSWER > 0 .and. kol > kol_err
    go top
    do while !eof()
      select MO_XML
      find (str(rees->kod,6)) 
      aadd(azip, {alltrim(rees->NAME_XML), alltrim(mo_xml->FNAME), rees->kod})
      select REES
      skip
    enddo
    delete file (cur_dir+"tmp_4"+sdbf)
    R_Use(dir_server+"mo_dr01k",,"RHUM")
    for i := 1 to len(azip)
      full_zip := dir_server+dir_XML_MO+cslash+azip[i,1]+szip
      name_zip := StripPath(full_zip)
      cName := Name_Without_Ext(name_zip)
      if (arr_f := Extract_Zip_XML(KeepPath(full_zip),name_zip)) != NIL
        if (n := ascan(arr_f,{|x| upper(Name_Without_Ext(x)) == upper(cName)})) > 0
          cFile := arr_f[n]
          // читаем файл в память
          oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
          if empty( oXmlDoc:aItems )
            aadd(aerr,"Ошибка в чтении файла "+cFile)
          else
            reestr_R01_tmpfile(oXmlDoc,aerr,Name_Without_Ext(cFile))
          endif
        else
          aadd(aerr,"В архиве "+name_zip+" нет файла "+cName+sxml)
        endif
      endif
      if empty(aerr)
        full_zip := dir_server+dir_XML_TF+cslash+azip[i,2]+szip
        name_zip := StripPath(full_zip)
        cName := Name_Without_Ext(name_zip)
        if (arr_f := Extract_Zip_XML(KeepPath(full_zip),name_zip)) != NIL
          if (n := ascan(arr_f,{|x| upper(Name_Without_Ext(x)) == upper(cName)})) > 0
            cFile := arr_f[n]
            // читаем файл в память
            oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
            if empty( oXmlDoc:aItems )
              aadd(aerr,"Ошибка в чтении файла "+cFile)
            else
              reestr_R02_tmpfile(oXmlDoc,aerr,Name_Without_Ext(cFile))
            endif
          else
            aadd(aerr,"В архиве "+name_zip+" нет файла "+cName+sxml)
          endif
        endif
        if empty(aerr)
          select RHUM
          index on str(R01_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR == azip[i,3]
          use (cur_dir+"tmp4file") new alias TMP4
          index on str(zap,6) to (cur_dir+"tmp4file")
          select TMP2
          go top
          do while !eof()
            select RHUM
            find (str(tmp2->_n_zap,6))
            select TMP4
            find (str(tmp2->_n_zap,6))
            tmp4->oplata := tmp2->_oplata
            if tmp2->_oplata == 1
              tmp4->enp := tmp2->_enp
              tmp4->kod_k := rhum->kod_k
            endif
            select TMP2
            skip
          enddo
          tmp1->(dbCloseArea())
          tmp2->(dbCloseArea())
          tmp3->(dbCloseArea())
          tmp4->(dbCloseArea())
          if hb_fileExists(cur_dir+"tmp_4"+sdbf)
            use (cur_dir+"tmp_4") new
            append from (cur_dir+"tmp4file") codepage "RU866"
            tmp_4->(dbCloseArea())
          else
            copy file (cur_dir+"tmp4file"+sdbf) to (cur_dir+"tmp_4"+sdbf)
          endif
        endif
      endif
      if !empty(aerr)
        delete file ttt.ttt
        aeval(aerr,{|x| strfile(x+hb_eol(),"ttt.ttt",.t.) })
        viewtext(Devide_Into_Pages("ttt.ttt",60,80),,,,.t.,,,2)
        fl := .f.
        exit
      endif
    next
  endif
  if fl
    R_Use(dir_server+"mo_dr05p",,"R05p")
    goto (mrec)
    for i := 1 to 12
      ames[i,1] := { 0,0,&("r05p->kol1_"+strzero(i,2)) }
      ames[i,2] := { 0,0,&("r05p->kol2_"+strzero(i,2)) }
    next
    afillall(akv,0)
    //
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    dbseek(strzero(sgod,4)+"0101",.t.)
    index on str(kod_k,7) to (cur_dir+"tmphuman") ;
          for kod > 0 .and. between(ishod,201,205) ;
          while !eof()
    R_Use(dir_server+"kartotek",,"KART")
    use (cur_dir+"tmp_4") new alias TMP4
    go top
    do while !eof()
      if tmp4->kod_k > 0
        select KART
        goto (tmp4->kod_k)
        if kart->kod == 0 // запись удалена (скорее всего, было удаление дубликатов)
          tmp4->kod_k := 0 // значит считаем, что была диспансеризация
        else
          select HUMAN
          find (str(kart->kod,7))
          if found() 
            tmp4->kod_k := 0 // в этом году была диспансеризация
          endif
        endif
        if tmp4->kod_k > 0
          if tmp4->t_pr == "O"
            skol[1] ++  // подсчёт кол-ва, которое нужно разбить по месяцам
          else
            skol[2] ++
          endif
        endif
      endif
      select TMP4
      skip
    enddo
    for j := 1 to 2
      f0_create_R01(j,bm+1)
    next
    select TMP4
    delete for empty(kod_k)
    pack
    if tmp4->(lastrec()) == 0
      fl := func_error(4,"В "+lstr(SQUARTER)+" квартале "+lstr(sgod)+" года все запланированные пациенты прошли диспансеризацию")
    endif
  endif
  if fl
    mywait()
    my_debug(,"skol"+print_array(skol))
    my_debug(,"ames"+print_array(ames))
    for j := 1 to 2
      d := koef := 2 // через сколько записей прыгаем
      my_debug(,print_array({j,koef}))      
      i := bm
      do while skol[j] > 0
        select TMP4
        if j == 1
          index on recno() to (cur_dir+"tmp_4") for tmp4->t_pr == "O" .and. tmp4->n_q == 0
        else
          index on recno() to (cur_dir+"tmp_4") for tmp4->t_pr == "R" .and. tmp4->n_q == 0
        endif 
        go top
        do while !eof()
          if d == koef
            if i >= 12
              i := bm
            endif
            do while i < 12
              ++i
              if ames[i,j,1] > ames[i,j,2] // если ещё не набрали месяц
                tmp4->n_m := i
                ames[i,j,2] ++
                skol[j] --
                exit
              endif
            enddo
            d := 0
          endif
          ++d
          if empty(skol[j])
            exit
          endif
          skip
        enddo
        select TMP4
        if j == 1
          index on recno() to (cur_dir+"tmp_4") for tmp4->t_pr == "O" .and. tmp4->n_m > bm
        else
          index on recno() to (cur_dir+"tmp_4") for tmp4->t_pr == "R" .and. tmp4->n_m > bm
        endif 
        go top
        do while !eof()
          if tmp4->n_q == 0
            tmp4->n_q := int((tmp4->n_m+2)/3) // определяем номер квартала по месяцу
            akv[tmp4->n_q,j] ++
          endif
          skip
        enddo
        //my_debug(,"-skol"+print_array(skol))
        //my_debug(,"-mkol"+print_array(mkol))
      enddo
    next j
    my_debug(,"skol"+print_array(skol))
    my_debug(,"ames"+print_array(ames))
    my_debug(,"akv"+print_array(akv))
  endif
else
  func_error(4,arr[1])  
endif
close databases
rest_box(buf)
if fl
  f1_create_R01()
endif  
close databases
rest_box(buf)
return NIL

***** 30.03.18
Function f0_create_R01(j,bm)
Local i, d, k := 0, v := 0
for i := bm to 12
  k += ames[i,j,3] // подсчёт итого план по месяцам
next
for i := bm to 12
  if ames[i,j,3] > 0
    ames[i,j,1] := int(skol[j]*ames[i,j,3]/k) 
    v += ames[i,j,1] // подсчёт итого факт по месяцам
  endif
next
d := skol[j] - v
do while d > 0
  for i := bm to 12
    if ames[i,j,3] > 0
      ames[i,j,1] ++
      if --d == 0 ; exit ; endif
    endif
  next
enddo 
return NIL

***** 30.03.18
Function f1_create_R01()
Local SQUARTER, nsh := 3, smsg, arr_nn[4]
if !f_Esc_Enter("создания файлов R01",.t.)
  return NIL
endif
afill(arr_nn,0)
G_Use(dir_server+"mo_dr01m",,"RM")
AddRecN()
rm->DWORK := sys_date
rm->TWORK1 := hour_min(seconds())
UnLock
//
G_Use(dir_server+"mo_dr01k",,"RHUM")
index on str(REESTR,6) to (cur_dir+"tmp_rhum")
G_Use(dir_server+"mo_dr01",,"REES")
index on str(NQUARTER,1)+str(nn,3) to (cur_dir+"tmp_dr01") for NYEAR == sgod
for SQUARTER := 1 to 4
  find (str(SQUARTER,1))
  do while SQUARTER == rees->NQUARTER .and. !eof()
    if arr_nn[SQUARTER] < rees->nn
      arr_nn[SQUARTER] := rees->nn
    endif
    skip
  enddo
next
set index to
G_Use(dir_server+"mo_xml",,"MO_XML")
G_Use(dir_server+"kartotek",,"KART")
use (cur_dir+"tmp_4") new alias TMP
set relation to kod_k into KART
for SQUARTER := 1 to 4
  if emptyall(akv[SQUARTER,1],akv[SQUARTER,2])
    loop
  endif
  smsg := "Составление файла R01 за "+lstr(SQUARTER)+"-й квартал"
  stat_msg(smsg) 
  select REES
  AddRecN()
  rees->KOD    := recno()
  rees->DSCHET := sys_date
  rees->NYEAR  := sgod
  rees->NQUARTER := SQUARTER
  rees->NN     := arr_nn[SQUARTER]+1
  s := "R01"+"T34M"+CODE_LPU+"_"+right(strzero(rees->NYEAR,4),2)+str(rees->NQUARTER,1)+strzero(rees->NN,nsh)
  rees->NAME_XML := s
  mkod_reestr := rees->KOD
  //
  rm->(G_RLock(forever))  
  &("rm->reestr"+lstr(SQUARTER)) := mkod_reestr 
  //
  select MO_XML
  AddRecN()
  mo_xml->KOD    := recno()
  mo_xml->FNAME  := s
  mo_xml->FNAME2 := ""
  mo_xml->DFILE  := rees->DSCHET
  mo_xml->TFILE  := hour_min(seconds())
  mo_xml->TIP_IN := 0
  mo_xml->TIP_OUT := _XML_FILE_R01  // тип высылаемого файла - R01
  mo_xml->REESTR := mkod_reestr
  //
  rees->KOD_XML := mo_xml->KOD
  UnLock
  Commit
  pkol := 0 
  select TMP
  index on upper(kart->fio)+dtos(kart->date_r) to (cur_dir+"tmp_4") for n_q == SQUARTER
  go top
  do while !eof()
    if .t. //tmp->reestr == 0
      ++pkol
      @ maxrow(),1 say lstr(pkol) color cColorSt2Msg
      //select TMP
      //G_RLock(forever)
      //tmp->reestr := mkod_reestr
      //
      select RHUM
      AddRec(6)
      rhum->REESTR := mkod_reestr
      rhum->KOD_K := tmp->kod_k
      rhum->n_q := SQUARTER
      rhum->n_m := tmp->n_m
      rhum->tip := iif(tmp->t_pr == "O", 1, 2)
      rhum->R01_ZAP := pkol
      rhum->ID_PAC := tmp->IDPAC
      rhum->TYPEOFREC := 1 // 0-первично представленная запись, 1-актуализированная запись
      rhum->OPLATA := 0
      tmp->kod_k := rhum->R01_ZAP
    endif
    if pkol % 2000 == 0
      dbUnlockAll()
      dbCommitAll()
    endif
    select TMP
    skip
  enddo
  select TMP
  index on str(kod_k,7) to (cur_dir+"tmp_4") for n_q == SQUARTER
  select REES
  G_RLock(forever)
  rees->KOL := pkol
  rees->KOL_ERR := 0
  dbUnlockAll()
  dbCommitAll()
  //
  stat_msg(smsg) 
  //
  oXmlDoc := HXMLDoc():New()
  oXmlDoc:Add( HXMLNode():New( "ZL_LIST") )
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
    mo_add_xml_stroke(oXmlNode,"VERSION",'2.0')
    mo_add_xml_stroke(oXmlNode,"CODEM",CODE_LPU)
    mo_add_xml_stroke(oXmlNode,"DATE_F",date2xml(mo_xml->DFILE))
    mo_add_xml_stroke(oXmlNode,"NAME_F",mo_xml->FNAME)
    mo_add_xml_stroke(oXmlNode,"SMO",'34')
    mo_add_xml_stroke(oXmlNode,"YEAR",lstr(rees->NYEAR))
    mo_add_xml_stroke(oXmlNode,"QUARTER",lstr(rees->NQUARTER))
    mo_add_xml_stroke(oXmlNode,"N_PACK",lstr(rees->NN))
  //
  select RHUM
  index on str(R01_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR == mkod_reestr
  go top
  do while !eof()
    @ maxrow(),0 say str(rhum->R01_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
    select TMP
    find (str(rhum->R01_ZAP,7))
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "PERSONS" ) )
    mo_add_xml_stroke(oXmlNode,"ZAP",lstr(rhum->R01_ZAP))
    mo_add_xml_stroke(oXmlNode,"IDPAC",tmp->IDPAC)
    mo_add_xml_stroke(oXmlNode,"SURNAME",tmp->SURNAME)
    mo_add_xml_stroke(oXmlNode,"NAME",tmp->name)
    if !empty(tmp->PATRONYMIC)
      mo_add_xml_stroke(oXmlNode,"PATRONYMIC",tmp->PATRONYMIC)
    endif
    mo_add_xml_stroke(oXmlNode,"BIRTHDAY",tmp->BIRTHDAY)
    mo_add_xml_stroke(oXmlNode,"SEX",tmp->sex)
    if !empty(tmp->ss)
      mo_add_xml_stroke(oXmlNode,"SS",tmp->ss)
    endif
    mo_add_xml_stroke(oXmlNode,"TYPE_P",tmp->TYPE_P)
    if !empty(tmp->SER_P)
      mo_add_xml_stroke(oXmlNode,"SER_P",tmp->SER_P)
    endif
    mo_add_xml_stroke(oXmlNode,"NUM_P",tmp->NUM_P)
    mo_add_xml_stroke(oXmlNode,"ENP",tmp->ENP)
    mo_add_xml_stroke(oXmlNode,"DOCTYPE",tmp->DOCTYPE)
    if !empty(tmp->DOCSER)
      mo_add_xml_stroke(oXmlNode,"DOCSER",tmp->DOCSER)
    endif
    mo_add_xml_stroke(oXmlNode,"DOCNUM",tmp->DOCNUM)
    if !empty(tmp->mr)
      mo_add_xml_stroke(oXmlNode,"MR",tmp->mr)
    endif
    mo_add_xml_stroke(oXmlNode,"CATEGORY",tmp->CATEGORY)
    mo_add_xml_stroke(oXmlNode,"T_PR",tmp->T_PR)
    mo_add_xml_stroke(oXmlNode,"TYPEOFRECORD","U")
    oPERIOD := oXmlNode:Add( HXMLNode():New( "PERIOD" ) )
     mo_add_xml_stroke(oPERIOD,"DATE_B",date2xml(f_date_period(rhum->n_m,1)))
     mo_add_xml_stroke(oPERIOD,"DATE_E",date2xml(f_date_period(rhum->n_m,2)))
    oCONTACTS := oXmlNode:Add( HXMLNode():New( "CONTACTS" ) )
     if !empty(tmp->TEL_F)
       mo_add_xml_stroke(oCONTACTS,"TEL_F",tmp->TEL_F)
     endif
     if !empty(tmp->TEL_M)
       mo_add_xml_stroke(oCONTACTS,"TEL_M",tmp->TEL_M)
     endif
     oADDRESS := oCONTACTS:Add( HXMLNode():New( "ADDRESS" ) )
      mo_add_xml_stroke(oADDRESS,"SUBJ",tmp->SUBJ)
      if !empty(tmp->ul)
        mo_add_xml_stroke(oADDRESS,"UL",tmp->ul)
      endif
    select RHUM
    skip
  enddo
  stat_msg("Запись XML-файла")
  oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
  chip_create_zipXML(alltrim(mo_xml->FNAME)+szip,{alltrim(mo_xml->FNAME)+sxml},.t.)
next SQUARTER
rm->(G_RLock(forever))  
rm->TWORK2 := hour_min(seconds())
close databases
keyboard chr(K_TAB)+chr(K_ENTER)
rest_box(buf)
return NIL

***** 13.12.17
Static Function f_date_period(_m,k)
Local ldate := stod(strzero(sgod,4)+strzero(_m,2)+"15")
if k == 1
  d := bom(ldate)
  do while !is_work_day(d)
    ++d
  enddo
else  
  d := eom(ldate)
  do while !is_work_day(d)
    --d
  enddo
endif  
return d

***** 15.12.17 Просмотр файлов обмена R01... и результатов работы с ними
Function f_view_R01()
Local i, k, buf := savescreen()
Private goal_dir := dir_server+dir_XML_MO+cslash
G_Use(dir_server+"mo_xml",,"MO_XML")
G_Use(dir_server+"mo_dr01",,"REES")
index on descend(str(NYEAR,4)+strzero(nn,3)+str(NQUARTER,1)) to (cur_dir+"tmp_rees") 
go top
if eof()
  func_error(4,"Не было создано файлов R01...")
else
  Private reg := 1
  Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1_view_R01",color0,,,,,,,;
               "f2_view_R01",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
endif
close databases
restscreen(buf)
return NIL

***** 14.12.17
Function f1_view_R01(oBrow)
Local oColumn, ;
      blk := {|| iif(hb_fileExists(goal_dir+alltrim(rees->NAME_XML)+szip), ;
                     iif(empty(rees->date_out), {3,4}, {1,2}),;
                     {5,6}) }
oColumn := TBColumnNew(" №№",{|| str(rees->nn,3) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Дата",{|| date_8(rees->dschet) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Период",{|| str(rees->nyear,4)+"/"+str(rees->NQUARTER,1) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол-во;пациентов", {|| str(rees->kol,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол-во;ошибок", {|| put_val(rees->kol_err,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("От-;вет", {|| iif(rees->answer==1,"да ","нет") })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Наименование файла",{|| padr(rees->NAME_XML,20) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Примечание",{|| f11_view_R01() })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if reg == 1
  status_key("^<Esc>^ выход; ^<F5>^ запись для ТФОМС; ^<F3>^ информация о файле")
else
  status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор реестра для возврата")
endif
return NIL

***** 14.12.17
Static Function f11_view_R01()
Local s := ""
if !hb_fileExists(goal_dir+alltrim(rees->NAME_XML)+szip)
  s := "нет файла"
elseif empty(rees->date_out)
  s := "не записан"
else
  s := "зап. "+lstr(rees->NUMB_OUT)+" раз"
endif
return padr(s,10)

***** 14.12.17
Function f2_view_R01(nKey,oBrow)
Local ret := -1, rec := rees->(recno()), tmp_color := setcolor(), r, r1, r2,;
      s, buf := savescreen(), arr, i, k, mdate, t_arr[2], arr_pmt := {}
do case
  case nKey == K_F5
    mdate := rees->dschet
    R_Use(dir_server+"mo_dr01m",,"RM")
    Locate for &("rm->reestr"+lstr(rees->NQUARTER)) == rees->kod
    if !found()
      func_error(4,"В файле MO_DR01M.DBF не найдена ссылка на данный реестр")
    else
      arr := {} ; k := 0
      for i := 1 to 4
        select REES 
        Locate for &("rm->reestr"+lstr(i)) == rees->kod
        if found()
          aadd(arr, {str(rees->nyear,4)+"/"+str(rees->NQUARTER,1),rees->name_xml,rees->kod_xml,rees->(recno())})
          if empty(rees->date_out)
            ++k
          endif
        endif
      next i
      if len(arr) == 0
        func_error(4,"Нечего записывать!")
      else
        s := "Количество файлов R01 - "+lstr(len(arr))+", записываются в первый раз - "+lstr(k)+":"
        for i := 1 to len(arr)
          if i > 1
            s += ","
          endif
          s += " "+alltrim(arr[i,1])+" ("+alltrim(arr[i,2])+szip+")"
        next
        perenos(t_arr,s,74)
        f_message(t_arr,,color1,color8)
        if f_Esc_Enter("записи файлов R01")
          Private p_var_manager := "copy_schet"
          s := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,2,.f.,,,) // "norton" для выбора каталога
          if !empty(s)
            if upper(s) == upper(goal_dir)
              func_error(4,"Вы выбрали каталог, в котором уже записаны целевые файлы! Это недопустимо.")
            else
              cFileProtokol := "prot_sch"+stxt
              strfile(hb_eol()+center(glob_mo[_MO_SHORT_NAME],80)+hb_eol()+hb_eol(),cFileProtokol)
              smsg := "Файлы R01 записаны на: "+s+;
                      " ("+full_date(sys_date)+"г. "+hour_min(seconds())+")"
              strfile(center(smsg,80)+hb_eol(),cFileProtokol,.t.)
              k := 0
              for i := 1 to len(arr)
                zip_file := alltrim(arr[i,2])+szip
                if hb_fileExists(goal_dir+zip_file)
                  mywait('Копирование "'+zip_file+'" в каталог "'+s+'"')
                  //copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
                  copy file (goal_dir+zip_file) to (s+zip_file)
                  //if hb_fileExists(hb_OemToAnsi(s)+zip_file)
                  if hb_fileExists(s+zip_file)
                    ++k
                    rees->(dbGoto(arr[i,4]))
                    smsg := lstr(i)+". Пакет R01 № "+lstr(rees->nn)+;
                            " от "+date_8(mdate)+"г. (отч.период "+;
                             lstr(rees->nyear)+"/"+lstr(rees->NQUARTER)+;
                             ") "+alltrim(rees->name_xml)+szip
                    strfile(hb_eol()+smsg+hb_eol(),cFileProtokol,.t.)
                    smsg := "   количество пациентов - "+lstr(rees->kol)
                    strfile(smsg+hb_eol(),cFileProtokol,.t.)
                    rees->(G_RLock(forever))
                    rees->DATE_OUT := sys_date
                    if rees->NUMB_OUT < 99
                      rees->NUMB_OUT ++
                    endif
                    //
                    mo_xml->(dbGoto(arr[i,3]))
                    mo_xml->(G_RLock(forever))
                    mo_xml->DREAD := sys_date
                    mo_xml->TREAD := hour_min(seconds())
                  else
                    smsg := "! Ошибка записи файла "+s+zip_file
                    func_error(4,smsg)
                    strfile(smsg+hb_eol(),cFileProtokol,.t.)
                  endif
                else
                  smsg := "! Не обнаружен файл "+goal_dir+zip_file
                  func_error(4,smsg)
                  strfile(smsg+hb_eol(),cFileProtokol,.t.)
                endif
              next i
              UnLock
              Commit
              viewtext(cFileProtokol,,,,.t.,,,2)
            endif
          endif
        endif
      endif
    endif
    rm->(dbCloseArea())
    select REES
    goto (rec)
    ret := 0
  case nKey == K_F3
    f3_view_R01(oBrow)
    ret := 0
  case nKey == K_CTRL_F12
    ret := delete_reestr_R02(rees->(recno()),alltrim(rees->NAME_XML))
    close databases
    G_Use(dir_server+"mo_xml",,"MO_XML")
    G_Use(dir_server+"mo_dr01",cur_dir+"tmp_rees","REES")
    goto (rec)
endcase
setcolor(tmp_color)
restscreen(buf)
return ret

***** 14.12.17
Function f3_view_R01(oBrow)
Static si := 1
Local i, r := row(), r1, r2, buf := save_maxrow(), fl, s,;
      mm_func := {-99},;
      mm_menu := {"Список ~всех пациентов из R01"}
mywait()
select MO_XML
index on FNAME to (cur_dir+"tmp_xml") ;
      for reestr==rees->kod .and. tip_in==_XML_FILE_R02 .and. empty(TIP_OUT)
go top
do while !eof()
  aadd(mm_func, -1)
  aadd(mm_menu, "1-установлена страх.принадлежность, подтверждено прикрепление к МО")
  aadd(mm_func, -2)
  aadd(mm_menu, "2-присутствуют ошибки технологического контроля")
  aadd(mm_func, -3)
  aadd(mm_menu, "3-не установлена страховая принадлежность") 
  aadd(mm_func, -4)
  aadd(mm_menu, "4-не установлена страх.принадлежность, не подтверждено прикрепление к МО")
  s := "Протокол чтения "+rtrim(mo_xml->FNAME)+" прочитан "+date_8(mo_xml->DWORK)
  if empty(mo_xml->TWORK2)
    s += "-ПРОЦЕСС НЕ ЗАВЕРШЁН"
  else
    s += " в "+mo_xml->TWORK1
  endif
  aadd(mm_func, mo_xml->kod)
  aadd(mm_menu, s)
  skip
enddo
select MO_XML
set index to
if r <= 12
  r1 := r+1 ; r2 := r1+len(mm_menu)+1
else
  r2 := r-1 ; r1 := r2-len(mm_menu)-1
endif
rest_box(buf)
if len(mm_menu) == 1
  i := 1
  si := i
  if mm_func[i] < 0
    f31_view_R01(abs(mm_func[i]),mm_menu[i])
  endif
elseif (i := popup_prompt(r1,10,si,mm_menu,,,color5)) > 0
  si := i
  if mm_func[i] < 0
    f31_view_R01(abs(mm_func[i]),mm_menu[i])
  else
    mo_xml->(dbGoto(mm_func[i]))
    viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+alltrim(mo_xml->FNAME)+stxt,60,80),,,,.t.,,,2)
  endif
endif
select REES
return NIL

***** 14.12.17
Function f31_view_R01(reg,s)
Local fl := .t., buf := save_maxrow(), k := 0, n_file := "r01_spis"+stxt
mywait()
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Список пациентов файла "+alltrim(rees->NAME_XML)+" от "+date_8(rees->dschet),80))
if reg == 99
  s := "все пациенты"
endif
add_string(center("[ "+s+" ]",80))
add_string("")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"mo_dr01k",,"RHUM")
set relation to kod_k into KART
index on str(rhum->R01_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == rees->kod
go top
do while !eof()
  if iif(reg == 99, .t., rhum->OPLATA == reg)
    ++k
    s := str(rhum->R01_ZAP,6)+". "
    if empty(kart->fio)
      s += "удалён дубликат в картотеке (код="+lstr(kod_k)+")"
    else
      s += padr(upper(kart->fio),47)+" "+full_date(kart->date_r)
    endif
    s += " ("+iif(rhum->tip==1,"ДИСП.","проф.")+") "+lstr(rhum->n_q)+"кв."
    verify_FF(60,.t.,80)
    add_string(s)
  endif
  select RHUM
  skip
enddo
add_string("")
add_string("Всего "+lstr(k)+" чел.")
kart->(dbCloseArea())
rhum->(dbCloseArea())
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.t.,,,2)
return NIL

***** 14.12.17 зачитать R02 во временные файлы
Function reestr_R02_tmpfile(oXmlDoc,aerr,mname_xml)
Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()
DEFAULT aerr TO {}, mname_xml TO ""
stat_msg("Распаковка/чтение/анализ файла "+mname_xml)
dbcreate(cur_dir+"tmp1file", {;
 {"_VERSION",   "C",  5,0},;
 {"_DATE_F",    "D",  8,0},;
 {"_NAME_F",    "C", 26,0},;
 {"_NAME_FE",   "C", 26,0},;
 {"KOL",        "N",  6,0},; // количество пациентов в реестре/файле
 {"KOL_ERR",    "N",  6,0};  // количество пациентов с ошибками в реестре
})
dbcreate(cur_dir+"tmp2file", {;
 {"_N_ZAP",     "N",  6,0},;
 {"_SMO",       "C",  5,0},;
 {"_ENP",       "C", 16,0},;
 {"_OPLATA",    "N",  1,0};
})
dbcreate(cur_dir+"tmp3file", {;
 {"_N_ZAP",     "N",  6,0},;
 {"_ERROR",     "N",  3,0};
})
use (cur_dir+"tmp1file") new alias TMP1
append blank
use (cur_dir+"tmp2file") new alias TMP2
use (cur_dir+"tmp3file") new alias TMP3
FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
  @ maxrow(),1 say padr(lstr(j),6) color cColorSt2Msg
  oXmlNode := oXmlDoc:aItems[1]:aItems[j]
  do case
    case "ZGLV" == oXmlNode:title
      tmp1->_VERSION :=          mo_read_xml_stroke(oXmlNode,"VERSION",aerr)
      tmp1->_DATE_F  := xml2date(mo_read_xml_stroke(oXmlNode,"DATE_F", aerr))
      tmp1->_NAME_F  :=          mo_read_xml_stroke(oXmlNode,"NAME_F", aerr)
      tmp1->_NAME_FE :=          mo_read_xml_stroke(oXmlNode,"NAME_FE",aerr)
    case "ERRS" == oXmlNode:title
      select TMP3
      append blank
      tmp3->_N_ZAP := 0
      tmp3->_ERROR := val(mo_read_xml_tag(oXmlNode,aerr))
    case "ZAPS" == oXmlNode:title
      select TMP2
      append blank
      tmp2->_N_ZAP  := val(mo_read_xml_stroke(oXmlNode,"ZAP",aerr))
      tmp2->_ENP    :=     mo_read_xml_stroke(oXmlNode,"ENP",aerr,.f.)
      tmp2->_SMO    :=     mo_read_xml_stroke(oXmlNode,"SMO",aerr,.f.)
      tmp2->_OPLATA := val(mo_read_xml_stroke(oXmlNode,"RESULT",aerr))
      if tmp2->_OPLATA > 1 .and. (oNode1 := oXmlNode:Find("ERRORS")) != NIL
        _ar := mo_read_xml_array(oNode1,"ERROR")
        for j1 := 1 to len(_ar)
          select TMP3
          append blank
          tmp3->_N_ZAP := tmp2->_N_ZAP
          tmp3->_ERROR := val(_ar[j1])
        next
      endif
  endcase
NEXT j
commit
rest_box(buf)
return NIL

***** 15.12.17 прочитать и "разнести" по базам данных файл R02
Function read_XML_FILE_R02(arr_XML_info,aerr,/*@*/current_i2)
Local count_in_schet := 0, bSaveHandler, ii1, ii2, i, j, k, t_arr[2], ldate_R02, s, err_file := .f.
mkod_reestr := arr_XML_info[7]
use (cur_dir+"tmp1file") new alias TMP1
ldate_R02 := tmp1->_DATE_F
R_Use(dir_server+"mo_dr01",,"REES")
goto (arr_XML_info[7])
strfile("Обрабатывается ответ ТФОМС (R02) на информационный пакет "+alltrim(rees->NAME_XML)+sxml+hb_eol()+;
        "за "+lstr(rees->NQUARTER)+" кв. "+lstr(rees->NYEAR)+" года от "+date_8(rees->DSCHET)+;
        "г. ("+lstr(rees->kol)+" чел.)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
//
R_Use(dir_server+"mo_dr01k",,"RHUM")
index on str(R01_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR == mkod_reestr
use (cur_dir+"tmp2file") new alias TMP2
i := 0 ; k := lastrec()
// сначала проверка
ii1 := ii2 := 0
go top
do while !eof()
  @ maxrow(),0 say str(++i/k*100,6,2)+"%" color cColorWait 
  if tmp2->_OPLATA == 1
    ++ii1
    if !empty(tmp2->_SMO) .and. ascan(glob_arr_smo,{|x| x[2] == int(val(tmp2->_SMO)) }) == 0
      aadd(aerr,"Некорректное значение атрибута SMO: "+tmp2->_SMO)
    endif
  elseif between(tmp2->_OPLATA,2,4)
    ++ii2
  else
    aadd(aerr,"Некорректное значение атрибута RESULT: "+lstr(tmp2->_OPLATA))
  endif
  select RHUM
  find (str(tmp2->_N_ZAP,6))
  if !found()
    aadd(aerr,"Не найден случай с N_ZAP = "+lstr(tmp2->_N_ZAP))
  endif
  select TMP2
  skip
enddo
tmp1->kol := ii1
tmp1->kol_err := ii2
if empty(ii2)
  use (cur_dir+"tmp3file") new alias TMP3
  index on str(_n_zap,6) to (cur_dir+"tmp3")
  find (str(0,6))
  err_file := found() // ошибки на уровне файла
endif  
close databases
if empty(aerr) // если проверка прошла успешно
  // запишем принимаемый файл (реестр СП)
  //chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
  chip_copy_zipXML(full_zip,dir_server+dir_XML_TF)
  G_Use(dir_server+"mo_xml",,"MO_XML")
  AddRecN()
  mo_xml->KOD := recno()
  mo_xml->FNAME := cReadFile
  mo_xml->DFILE := ldate_R02
  mo_xml->TFILE := ""
  mo_xml->DREAD := sys_date
  mo_xml->TREAD := hour_min(seconds())
  mo_xml->TIP_IN := _XML_FILE_R02 // тип принимаемого файла
  mo_xml->DWORK  := sys_date
  mo_xml->TWORK1 := cTimeBegin
  mo_xml->REESTR := mkod_reestr
  mo_xml->KOL1 := ii1
  mo_xml->KOL2 := ii2
  //
  mXML_REESTR := mo_xml->KOD
  use
  G_Use(dir_server+"mo_dr01",,"REES")
  goto (mkod_reestr)
  G_RLock(forever)
  rees->answer := 1
  if ii2 > 0 
    rees->kol_err := ii2
  elseif err_file
    rees->kol_err := -1
  endif  
  use
  if ii2 > 0 .or. err_file
    use (cur_dir+"tmp3file") new alias TMP3
    index on str(_n_zap,6) to (cur_dir+"tmp3")
    G_Use(dir_server+"mo_dr01e",,"REFR")
    index on str(REESTR,6)+str(R01_ZAP,6) to (cur_dir+"tmp_r01e")
    if err_file
      select REFR
      do while .t.
        find (str(mkod_reestr,6)+str(0,6))
        if !found() ; exit ; endif
        DeleteRec(.t.)
      enddo
      strfile("Ошибки на уровне файла:"+hb_eol(),cFileProtokol,.t.)
      select TMP3
      find (str(0,6))
      do while tmp3->_N_ZAP == 0 .and. !eof()
        select REFR
        AddRec(6)
        refr->reestr := mkod_reestr
        refr->R01_ZAP := 0
        refr->KOD_ERR := tmp3->_ERROR
        if (j := ascan(glob_T012, {|x| x[2] == tmp3->_ERROR })) > 0
          strfile(space(8)+"ошибка "+lstr(tmp3->_ERROR)+" - "+glob_T012[j,1]+hb_eol(),cFileProtokol,.t.)
        else
          strfile(space(8)+"ошибка "+lstr(tmp3->_ERROR)+" (неизвестная ошибка)"+hb_eol(),cFileProtokol,.t.)
        endif
        select TMP3
        skip
      enddo
    endif
    tmp3->(dbCloseArea())
  endif
  G_Use(dir_server+"kartote2",,"KART2")
  G_Use(dir_server+"kartote_",,"KART_")
  G_Use(dir_server+"kartotek",,"KART")
  G_Use(dir_server+"mo_dr01k",,"RHUM")
  index on str(R01_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR == mkod_reestr
  use (cur_dir+"tmp3file") new alias TMP3
  index on str(_n_zap,6) to (cur_dir+"tmp3")
  use (cur_dir+"tmp2file") new alias TMP2
  index on str(_n_zap,6) to (cur_dir+"tmp2")
  count_in_schet := lastrec() ; current_i2 := 0
  i := 0
  go top
  do while !eof()
    @ maxrow(),0 say str(++i/k*100,6,2)+"%" color cColorWait 
    select RHUM
    find (str(tmp2->_N_ZAP,6))
    G_RLock(forever)
    rhum->OPLATA := tmp2->_OPLATA
    if !empty(tmp2->_enp)
      select KART2
      do while kart2->(lastrec()) < rhum->kod_k
        APPEND BLANK
      enddo
      goto (rhum->kod_k)
      if len(alltrim(kart2->kod_mis)) != 16
        G_RLock(forever)
        kart2->kod_mis := tmp2->_enp
        dbUnLock()
      endif 
    endif
    if tmp2->_OPLATA > 1
      --count_in_schet    // не включается в счет,
      if current_i2 == 0
        strfile(space(10)+"Список случаев с ошибками:"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      endif
      ++current_i2
      kart->(dbGoto(rhum->kod_k))
      if empty(kart->fio)
        strfile(str(tmp2->_N_ZAP,6)+". Пациент с кодом по картотеке "+lstr(kart->(recno()))+hb_eol(),cFileProtokol,.t.)
      else
        strfile(str(tmp2->_N_ZAP,6)+". "+alltrim(kart->fio)+", "+full_date(kart->date_r)+hb_eol(),cFileProtokol,.t.)
      endif
      select REFR
      do while .t.
        find (str(mkod_reestr,6)+str(tmp2->_N_ZAP,6))
        if !found() ; exit ; endif
        DeleteRec(.t.)
      enddo
      select TMP3
      find (str(tmp2->_N_ZAP,6))
      do while tmp2->_N_ZAP == tmp3->_N_ZAP .and. !eof()
        select REFR
        AddRec(6)
        refr->reestr := mkod_reestr
        refr->R01_ZAP := tmp2->_N_ZAP
        refr->KOD_ERR := tmp3->_ERROR
        if (j := ascan(glob_T012, {|x| x[2] == tmp3->_ERROR })) > 0
          strfile(space(8)+"ошибка "+lstr(tmp3->_ERROR)+" - "+glob_T012[j,1]+hb_eol(),cFileProtokol,.t.)
        else
          strfile(space(8)+"ошибка "+lstr(tmp3->_ERROR)+" (неизвестная ошибка)"+hb_eol(),cFileProtokol,.t.)
        endif
        select TMP3
        skip
      enddo
      if tmp2->_OPLATA == 3
        strfile(space(8)+"не установлена страховая принадлежность"+hb_eol(),cFileProtokol,.t.)
      elseif tmp2->_OPLATA == 4
        strfile(space(8)+"не установлена страховая принадлежность, не подтверждено прикрепление к МО"+hb_eol(),cFileProtokol,.t.)
      endif
    endif
    UnLock ALL
    select TMP2
    if recno() % 1000 == 0
      Commit
    endif
    skip
  enddo
endif
close databases
return count_in_schet

***** 14.12.17 аннулировать чтение недочитанного реестра R02
Function delete_reestr_R02(mkod_reestr,mname_reestr)
Local i, s, r := row(), r1, r2, buf := save_maxrow(), ;
      mm_menu := {}, mm_func := {}, mm_flag := {}, mreestr_sp_tk, ;
      arr_f, cFile, oXmlDoc, aerr := {}, is_allow_delete, ;
      cFileProtokol := "tmp"+stxt
mywait()
select MO_XML
index on FNAME to (cur_dir+"tmp_xml") ;
      for reestr == mkod_reestr .and. tip_in == _XML_FILE_R02 .and. TIP_OUT == 0
go top
do while !eof()
  aadd(mm_func, mo_xml->kod)
  s := "Протокол чтения "+rtrim(mo_xml->FNAME)+" прочитан "+date_8(mo_xml->DWORK)
  if empty(mo_xml->TWORK2)
    aadd(mm_flag,.t.)
    s += "-ПРОЦЕСС НЕ ЗАВЕРШЁН"
  else
    aadd(mm_flag,.f.)
    s += " в "+mo_xml->TWORK1
  endif
  aadd(mm_menu,s)
  skip
enddo
select MO_XML
set index to
rest_box(buf)
if len(mm_menu) == 0
  func_error(4,"Не было чтения файла R02...")
  return 0
endif
if r <= 18
  r1 := r+1 ; r2 := r1+len(mm_menu)+1
else
  r2 := r-1 ; r1 := r2-len(mm_menu)-1
endif
if (i := popup_prompt(r1,10,1,mm_menu,,,color5)) > 0
  is_allow_delete := mm_flag[i]
  mreestr_sp_tk := mm_func[i]
  select MO_XML
  goto (mreestr_sp_tk)
  cFile := alltrim(mo_xml->FNAME)
  mtip_in := mo_xml->TIP_IN
  close databases
  if !is_allow_delete
    func_error(4,"Файл "+cFile+sxml+" корректно прочитан. Аннулирование запрещено!")
    return 0
  endif
  if (arr_f := Extract_Zip_XML(dir_server+dir_XML_TF,cFile+szip)) != NIL 
    cFile += sxml
    // читаем файл в память
    oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
    if Empty( oXmlDoc:aItems )
      func_error(4,"Ошибка в чтении файла "+cFile)
    else // читаем и записываем XML-файл во временные TMP-файлы
      reestr_R02_tmpfile(oXmlDoc,aerr,cFile)
      if !empty(aerr)
        Ins_Array(aerr,1,"")
        Ins_Array(aerr,1,center("Ошибки в чтении файла "+cFile,80))
        aeval(aerr,{|x| strfile(x+hb_eol(),cFileProtokol,.t.) })
        viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,2)
        delete file (cFileProtokol)
      else
        if !is_allow_delete .and. involved_password(2,cFile,"аннулирования чтения файла R02")
          is_allow_delete := .t.
        endif
        if is_allow_delete
          close databases
          G_Use(dir_server+"mo_dr01",,"REES")
          goto (mkod_reestr)
          use (cur_dir+"tmp1file") new alias TMP1
          use (cur_dir+"tmp2file") new alias TMP2
          arr := {}
          aadd(arr,"Информационный пакет "+alltrim(rees->NAME_XML)+sxml+" от "+date_8(rees->DSCHET)+"г.")
          aadd(arr,"за "+lstr(rees->NQUARTER)+" кв. "+lstr(rees->NYEAR)+;
                   " года, кол-во пациентов "+lstr(rees->kol)+" чел.")
          aadd(arr,"")
          G_Use(dir_server+"mo_xml",,"MO_XML")
          goto (mreestr_sp_tk)
          aadd(arr,"Аннулируется файл ответа "+cFile+" от "+date_8(mo_xml->DFILE)+"г.")
          aadd(arr,"После подтверждения аннулирования все последствия чтения данного")
          aadd(arr,"файла R02, а также сам файл R02, будут удалены.")
          f_message(arr,,cColorSt2Msg,cColorSt1Msg)
          s := "Подтвердите аннулирование файла R02"
          stat_msg(s) ; mybell(1)
          is_allow_delete := .f.
          if f_Esc_Enter("аннулирования",.t.)
            stat_msg(s+" ещё раз.") ; mybell(3)
            if f_Esc_Enter("аннулирования",.t.)
              mywait()
              is_allow_delete := .t.
            endif
          endif
          close databases
        endif
        if is_allow_delete
          G_Use(dir_server+"mo_xml",,"MO_XML")
          G_Use(dir_server+"mo_dr01",,"REES")
          goto (mkod_reestr)
          G_RLock(forever)
          rees->answer := 0
          rees->kol_err := 0
          G_Use(dir_server+"mo_dr01e",,"REFR")
          index on str(REESTR,6)+str(R01_ZAP,6) to (cur_dir+"tmp_r01e")
          select REFR
          do while .t.
            find (str(mkod_reestr,6)+str(0,6)) // удалим ошибки на уровне файла
            if !found() ; exit ; endif
            DeleteRec(.t.)
          enddo
          G_Use(dir_server+"mo_dr01k",,"RHUM")
          index on str(R01_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
          use (cur_dir+"tmp2file") new alias TMP2
          go top
          do while !eof()
            select RHUM
            find (str(tmp2->_N_ZAP,6))
            G_RLock(forever)
            rhum->OPLATA := 0
            UnLock
            select REFR
            do while .t.
              find (str(mkod_reestr,6)+str(tmp2->_N_ZAP,6))
              if !found() ; exit ; endif
              DeleteRec(.t.)
            enddo
            select TMP2
            skip
          enddo
          select MO_XML
          goto (mreestr_sp_tk)
          DeleteRec()
          close databases
          stat_msg("Файл "+cFile+" успешно аннулирован. Можно прочитать ещё раз.") ; mybell(5)
        endif
      endif
    endif
  endif
endif
rest_box(buf)
return 0

***** 18.12.17
Function need_delete_reestr_R01()
Local fl := .f.
if tip_polzovat == TIP_ADM
  R_Use(dir_server+"mo_dr01m",,"R01m")
  go top
  do while !eof()
    if empty(r01m->twork2)
      fl := .t. ; exit
    endif
    skip
  enddo
  Use
endif
return fl

***** 17.12.17
Function delete_reestr_R01()
Local t_arr[BR_LEN], blk
if tip_polzovat != TIP_ADM
  return func_error(4,err_admin)
endif
G_Use(dir_server+"mo_dr01m",,"R01m")
index on descend(dtos(DWORK)+TWORK1) to (cur_dir+"tmp_dr01m") 
go top
if eof()
  func_error(4,"Не было создано файлов R01...")
else
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow()-2
  t_arr[BR_LEFT] := 30
  t_arr[BR_RIGHT] := 77
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := "Список созданных пакетов реестров R01"
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
  blk := {|| iif(empty(r01m->twork2),{3,4},{1,2}) }
  t_arr[BR_COLUMN] := {;
   { "  Дата;создания",{|| date_8(r01m->dwork) }, blk },;
   { " I;кв.",  {|| iif(r01m->reestr1 > 0,"да ","нет") }, blk },;
   { "II;кв.",  {|| iif(r01m->reestr2 > 0,"да ","нет") }, blk },;
   { "III;кв.", {|| iif(r01m->reestr3 > 0,"да ","нет") }, blk },;
   { "IV;кв.",  {|| iif(r01m->reestr4 > 0,"да ","нет") }, blk },;
   { "Время;начала",    {|| r01m->twork1 }, blk },;
   { "Время;окончания", {|| padr(iif(empty(r01m->twork2),"НЕ ЗАВЕРШЕНО",r01m->twork2),12) }, blk };
  }
  t_arr[BR_EDIT] := {|nk,ob| f1_delete_reestr_R01(nk,ob,"edit") }
  t_arr[BR_FL_INDEX] := .f.
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - аннулирование создания пакета реестров R01") }
  edit_browse(t_arr)
endif  
close databases
return NIL

***** 17.12.17
Function f1_delete_reestr_R01(nKey,oBrow,regim)
Local ret := -1, rec := r01m->(recno()), ir, fl := .t.
if regim == "edit" .and. nKey == K_ENTER
  if empty(r01m->twork2)
    G_Use(dir_server+"mo_dr01",,"REES")
    for ir := 1 to 4
      mkod_reestr := &("r01m->reestr"+lstr(ir))
      if mkod_reestr > 0
        select REES
        goto (mkod_reestr)
        if rees->ANSWER == 1
          fl := func_error(4,"Уже получен ответ R02 за "+lstr(ir)+"-й квартал. Операция запрещена!")
          exit
        endif 
      endif
    next 
    REES->(dbCloseArea())
    select R01m
    if fl .and. f_Esc_Enter("аннулирования R01")
      mywait()
      G_Use(dir_server+"mo_xml",,"MO_XML")
      G_Use(dir_server+"mo_dr00",,"TMP")
      index on str(REESTR,6) to (cur_dir+"tmp_dr00")
      G_Use(dir_server+"mo_dr01k",,"RHUM")
      index on str(REESTR,6) to (cur_dir+"tmp_rhum")
      G_Use(dir_server+"mo_dr01",,"REES")
      for ir := 4 to 1 step -1
        mkod_reestr := &("r01m->reestr"+lstr(ir))
        if mkod_reestr > 0
          select REES
          goto (mkod_reestr) 
          select TMP
          do while .t.
            find (str(mkod_reestr,6))
            if !found() ; exit ; endif
            G_Rlock(forever)
            tmp->n_m := 0
            tmp->n_q := 0
            tmp->reestr := 0
            dbUnLock()
          enddo
          select RHUM
          do while .t.
            find (str(mkod_reestr,6))
            if !found() ; exit ; endif
            DeleteRec(.t.)
          enddo
          select MO_XML
          goto (rees->KOD_XML)
          DeleteRec(.t.)
          select REES
          DeleteRec(.t.)
          select R01m
          G_RLock(forever)
          &("r01m->reestr"+lstr(ir)) := 0
          dbUnlockAll()
          dbCommitAll()
        endif
      next
      mo_xml->(dbCloseArea())
      tmp->(dbCloseArea())
      RHUM->(dbCloseArea())
      REES->(dbCloseArea())
      select R01m
      DeleteRec()
      stat_msg("Аннулирование завершено!") ; mybell(2,OK) 
      ret := 1
    endif
  else
    func_error(4,"Процесс создания пакета реестров R01 завершён корректно. Операция запрещена!")
  endif
endif
return ret

***** 16.01.18 проверить, есть ли не до конца обработанные операции с файлами R01...
Function find_unfinished_R01()
Local fl := .t., skol, mkol := 0, arr := {}, fl_date := .t.
Private sgod := 2018, mrec := 1
if glob_mo[_MO_IS_UCH]
  if (fl := verify_packet_R05(2,arr))
    R_Use(dir_server+"mo_dr05p",,"R05p")
    goto (mrec)
    skol := r05p->KOL1 + r05p->KOL2
    select MO_XML
    index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in == _XML_FILE_R02 .and. empty(TIP_OUT)
    R_Use(dir_server+"mo_dr01",,"REES")
    index on str(nn,3)+str(NQUARTER,1) to (cur_dir+"tmp_dr01") for NYEAR == sgod
    go top
    do while fl .and. !eof()
      if rees->dschet > stod(strzero(sgod,4)+"0325")
        fl_date := .f.
      endif
      if rees->kol_err < 0
        //fl := .f.
        //aadd(arr,"В файле R02 за "+lstr(rees->NQUARTER)+"-й квартал "+lstr(sgod)+"г. ошибки на уровне файла")
      elseif empty(rees->answer)
        fl := .f.
        aadd(arr,"Файл R02 за "+lstr(rees->NQUARTER)+"-й квартал "+lstr(sgod)+" года не был прочитан")
      else
        mkol += (rees->KOL - rees->KOL_ERR)
        select MO_XML
        find (str(rees->kod,6)) 
        if found() .and. empty(mo_xml->TWORK2)
          fl := .f.
          aadd(arr,"Прервано чтение файла "+alltrim(mo_xml->FNAME)+"! Аннулируйте (Ctrl+F12) и прочитайте снова")
        endif
      endif
      select REES
      skip
    enddo
    if fl .and. skol != mkol .and. fl_date
      fl := .f.
      aadd(arr,"Количество, определённое в план-графике = "+lstr(skol))
      aadd(arr,"Количество, отправленное в ТФОМС        = "+lstr(mkol))
    endif
  endif  
  close databases
  if !fl .and. !empty(arr)
    Ins_Array(arr,1,"")
    Ins_Array(arr,1,"-----------------------------------------------------")
    Ins_Array(arr,1,"Операции создания (обмена) файлов R01(R02) и R05(R06)")
    n_message(arr,,"GR+/R","W+/R",,,"G+/R")
  endif
endif  
return NIL

***** 29.03.18 зачитать R01 во временные файлы
Function reestr_R01_tmpfile(oXmlDoc,aerr,mname_xml)
Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()
DEFAULT aerr TO {}, mname_xml TO ""
stat_msg("Распаковка/чтение/анализ файла "+mname_xml)
dbcreate(cur_dir+"tmp4file", {;
 {"ZAP",        "N",  6,0},;
 {"IDPAC",      "C", 36,0},;
 {"SURNAME",    "C", 40,0},;
 {"NAME",       "C", 40,0},;
 {"PATRONYMIC", "C", 40,0},;
 {"BIRTHDAY",   "C", 10,0},;
 {"SEX",        "C",  1,0},;
 {"SS",         "C", 14,0},;
 {"TYPE_P",     "C",  1,0},;
 {"SER_P",      "C", 10,0},;
 {"NUM_P",      "C", 20,0},;
 {"ENP",        "C", 16,0},;
 {"DOCTYPE",    "C",  2,0},;
 {"DOCSER",     "C", 10,0},;
 {"DOCNUM",     "C", 20,0},;
 {"MR",         "C",100,0},;
 {"CATEGORY",   "C",  2,0},;
 {"T_PR",       "C",  1,0},;
 {"TEL_F",      "C", 13,0},;
 {"TEL_M",      "C", 13,0},;
 {"SUBJ",       "C",  5,0},;
 {"UL",         "C",120,0},;
 {"kod_k",      "N",  7,0},;
 {"N_M",        "N",  2,0},;
 {"N_Q",        "N",  1,0},;
 {"OPLATA",     "N",  1,0};
})
use (cur_dir+"tmp4file") new alias TMP2
FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
  @ maxrow(),1 say padr(lstr(j),6) color cColorSt2Msg
  oXmlNode := oXmlDoc:aItems[1]:aItems[j]
  if "PERSONS" == oXmlNode:title
    select TMP2
    append blank
    tmp2->ZAP       := val(mo_read_xml_stroke(oXmlNode,"ZAP",aerr))
    tmp2->IDPAC     :=     mo_read_xml_stroke(oXmlNode,"IDPAC",aerr,.f.)
    tmp2->SURNAME   :=     mo_read_xml_stroke(oXmlNode,"SURNAME",aerr,.f.)
    tmp2->NAME      :=     mo_read_xml_stroke(oXmlNode,"NAME",aerr,.f.)
    tmp2->PATRONYMIC:=     mo_read_xml_stroke(oXmlNode,"PATRONYMIC",aerr,.f.)
    tmp2->BIRTHDAY  :=     mo_read_xml_stroke(oXmlNode,"BIRTHDAY",aerr,.f.)
    tmp2->SEX       :=     mo_read_xml_stroke(oXmlNode,"SEX",aerr,.f.)
    tmp2->SS        :=     mo_read_xml_stroke(oXmlNode,"SS",aerr,.f.)
    tmp2->TYPE_P    :=     mo_read_xml_stroke(oXmlNode,"TYPE_P",aerr,.f.)
    tmp2->SER_P     :=     mo_read_xml_stroke(oXmlNode,"SER_P",aerr,.f.)
    tmp2->NUM_P     :=     mo_read_xml_stroke(oXmlNode,"NUM_P",aerr,.f.)
    tmp2->ENP       :=     mo_read_xml_stroke(oXmlNode,"ENP",aerr,.f.)
    tmp2->DOCTYPE   :=     mo_read_xml_stroke(oXmlNode,"DOCTYPE",aerr,.f.)
    tmp2->DOCSER    :=     mo_read_xml_stroke(oXmlNode,"DOCSER",aerr,.f.)
    tmp2->DOCNUM    :=     mo_read_xml_stroke(oXmlNode,"DOCNUM",aerr,.f.)
    tmp2->MR        :=     mo_read_xml_stroke(oXmlNode,"MR",aerr,.f.)
    tmp2->CATEGORY  :=     mo_read_xml_stroke(oXmlNode,"CATEGORY",aerr,.f.)
    tmp2->T_PR      :=     mo_read_xml_stroke(oXmlNode,"T_PR",aerr,.f.)
    if (oNode1 := oXmlNode:Find("CONTACTS")) != NIL
      tmp2->TEL_F   :=     mo_read_xml_stroke(oNode1,"TEL_F",aerr,.f.)
      tmp2->TEL_M   :=     mo_read_xml_stroke(oNode1,"TEL_M",aerr,.f.)
      if (oNode2 := oNode1:Find("ADDRESS")) != NIL
        tmp2->SUBJ  :=     mo_read_xml_stroke(oNode2,"SUBJ",aerr,.f.)
        tmp2->UL    :=     mo_read_xml_stroke(oNode2,"UL",aerr,.f.)
      endif
    endif
  endif
NEXT j
tmp2->(dbCloseArea())
rest_box(buf)
return NIL
