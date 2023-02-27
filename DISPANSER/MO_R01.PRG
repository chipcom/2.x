***** mo_r01.prg - функции для работы с информационным сопровождением по диспансеризации
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 18.12.22 инициализация всех файлов инф.сопровождения по диспансеризации
Function f_init_r01()
Local mo_dr00 := {; // пул пациентов, подлежащих диспансеризации/профосмотрам взрослого населения
   {"kod",        "N", 7,0},; // код по картотеке
   {"tip",        "N", 1,0},; // 1-диспансеризация, 2-профосмотр
   {"tip1",       "N", 1,0},; // 1-пенсионер,2-65 лет,3-66 лет и старше
   {"voz",        "N", 1,0},; // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-остальные
   {"n_m",        "N", 2,0},; // месяц для диспансеризации (1-12)
   {"n_q",        "N", 1,0},;
   {"enp",        "C",16,0},; // ЕНП
   {"smo",        "N", 1,0},; // оповещён ли СМО
   {"REESTR",     "N", 6,0};  // код реестра по файлу "mo_dr01"
  }
Local mo_dr01m := {; // пакеты по 12 реестра за год (по месяцам)
   {"REESTR01",    "N", 6,0},; // код реестра по файлу "mo_dr01"
   {"REESTR02",    "N", 6,0},; //
   {"REESTR03",    "N", 6,0},; //
   {"REESTR04",    "N", 6,0},; //
   {"REESTR05",    "N", 6,0},; //
   {"REESTR06",    "N", 6,0},; //
   {"REESTR07",    "N", 6,0},; //
   {"REESTR08",    "N", 6,0},; //
   {"REESTR09",    "N", 6,0},; //
   {"REESTR10",    "N", 6,0},; //
   {"REESTR11",    "N", 6,0},; //
   {"REESTR12",    "N", 6,0},; //
   {"DWORK",       "D", 8,0},; // дата обработки файла;
   {"TWORK1",      "C", 5,0},; // время начала обработки;
   {"TWORK2",      "C", 5,0};  // время окончания обработки;
  }
Local mo_dr01 := {; // отсылаемые файлы о будущих диспансеризациях взрослого населения
   {"KOD",         "N", 6,0},; // код реестра (номер записи)
   {"tip",         "N", 1,0},; // 0-R01, 1-R11
   {"DSCHET",      "D", 8,0},; // дата файла
   {"NYEAR",       "N", 4,0},; // отчетный год
   {"NMONTH",      "N", 2,0},; // отчетный месяц
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
   {"tip",      "N", 1,0},; // 1-диспансеризация 1 этап, 2-профосмотр
   {"tip1",     "N", 1,0},; // 1-пенсионер,2-65 лет,3-66 лет и старше
   {"voz",      "N", 1,0},; // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-прочие
   {"N_M",      "N", 2,0},; // месяц для диспансеризации (1-12)
   {"ID_PAC",   "C",36,0},; // GUID пациента в R01 (создается при добавлении записи)
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
   {"KOL",         "N", 6,0}; // количество пациентов в реестре/файле
  }
Local mo_dr05k := {; // кол-во пациентов в реестрах будущих диспансеризаций
   {"REESTR",   "N", 6,0},; // код реестра по файлу "mo_dr05"
   {"tip",      "N", 1,0},; // 1-диспансеризация 1 этап, 2-профосмотр
   {"voz",      "N", 1,0},; // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-прочие
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
   {"KOL11",     "N", 6,0},; // количество пациентов для диспансеризации на год
   {"KOL12",     "N", 6,0},; // количество пациентов для диспансеризации на год
   {"KOL13",     "N", 6,0},; // количество пациентов для диспансеризации на год
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
   {"KOL11_01",  "N", 6,0},; //
   {"KOL11_02",  "N", 6,0},; //
   {"KOL11_03",  "N", 6,0},; //
   {"KOL11_04",  "N", 6,0},; //
   {"KOL11_05",  "N", 6,0},; //
   {"KOL11_06",  "N", 6,0},; //
   {"KOL11_07",  "N", 6,0},; //
   {"KOL11_08",  "N", 6,0},; //
   {"KOL11_09",  "N", 6,0},; //
   {"KOL11_10",  "N", 6,0},; //
   {"KOL11_11",  "N", 6,0},; //
   {"KOL11_12",  "N", 6,0},; //
   {"KOL12_01",  "N", 6,0},; //
   {"KOL12_02",  "N", 6,0},; //
   {"KOL12_03",  "N", 6,0},; //
   {"KOL12_04",  "N", 6,0},; //
   {"KOL12_05",  "N", 6,0},; //
   {"KOL12_06",  "N", 6,0},; //
   {"KOL12_07",  "N", 6,0},; //
   {"KOL12_08",  "N", 6,0},; //
   {"KOL12_09",  "N", 6,0},; //
   {"KOL12_10",  "N", 6,0},; //
   {"KOL12_11",  "N", 6,0},; //
   {"KOL12_12",  "N", 6,0},; //
   {"KOL13_01",  "N", 6,0},; //
   {"KOL13_02",  "N", 6,0},; //
   {"KOL13_03",  "N", 6,0},; //
   {"KOL13_04",  "N", 6,0},; //
   {"KOL13_05",  "N", 6,0},; //
   {"KOL13_06",  "N", 6,0},; //
   {"KOL13_07",  "N", 6,0},; //
   {"KOL13_08",  "N", 6,0},; //
   {"KOL13_09",  "N", 6,0},; //
   {"KOL13_10",  "N", 6,0},; //
   {"KOL13_11",  "N", 6,0},; //
   {"KOL13_12",  "N", 6,0},; //
   {"D_KZ",     "D", 8,0};  // дата приказа КЗ ВО
  }
Local mo_dr05e := {; // список ошибок в реестрах будущих диспансеризаций
   {"REESTR",   "N", 6,0},; // код реестра;по файлу "mo_dr05"
   {"R05_ZAP",  "N", 6,0},; // номер позиции записи в реестре;"ZAP") в R05
   {"KOD_ERR",  "N", 3,0};  // код ошибки ТК
  }
Local fl
reconstruct(dir_server + "mo_dr01", mo_dr01 ,,,.t.)
reconstruct(dir_server + "mo_dr01m",mo_dr01m,,,.t.)
reconstruct(dir_server + "mo_dr01k",mo_dr01k,,,.t.)
reconstruct(dir_server + "mo_dr01e",mo_dr01e,,,.t.)
reconstruct(dir_server + "mo_dr05", mo_dr05 ,,,.t.)
reconstruct(dir_server + "mo_dr05p",mo_dr05p,,,.t.)
reconstruct(dir_server + "mo_dr05k",mo_dr05k,,,.t.)
reconstruct(dir_server + "mo_dr05e",mo_dr05e,,,.t.)
reconstruct(dir_server + "mo_dr00", mo_dr00 ,,,.t.)
//
G_Use(dir_server + "mo_dr05p",,"R05p")
Locate for n_y < 2023  // ЮЮ 12.12.22
fl := found()
Use
if fl
  f_zap_all_mo_dr()
endif
return NIL

***** 18.12.22 очистить файлы - удалить 2022 год
Function f_zap_all_mo_dr()
Local i, arrx := {}
use (dir_server + "mo_dr01") new
zap
use (dir_server + "mo_dr01m") new
zap
use (dir_server + "mo_dr01k") new
zap
use (dir_server + "mo_dr01e") new
zap
use (dir_server + "mo_dr05") new
zap
use (dir_server + "mo_dr05k") new
zap
use (dir_server + "mo_dr05e") new
zap
use (dir_server + "mo_dr00") new
zap
G_Use(dir_server + "mo_xml",,"MO_XML")
index on FNAME to (cur_dir+"tmp_xml") ;
      for eq_any(tip_in,_XML_FILE_R02,_XML_FILE_R06) .or. eq_any(TIP_OUT,_XML_FILE_R01,_XML_FILE_R05)
go top
do while !eof()
  aadd(arrx,mo_xml->(recno()))
  skip
enddo
set index to
for i := 1 to len(arrx)
  goto (arrx[i])
  DeleteRec(.t.)
next
use (dir_server + "mo_dr05p") new
zap
close databases
return NIL

Function fff_init_r01()
Local buf := save_maxrow()
R_Use(dir_server + "mo_dr05p",,"R05p")
if fieldnum("KOL11") == 0
  close databases
  myWait()
  f_init_r01() // инициализация всех файлов инф.сопровождения по диспансеризации
  close databases
  rest_box(buf)
endif
close databases
return NIL

***** 18.12.22 Создание файла обмена R05...
Function f_create_R05()
Local buf := save_maxrow(), i, fl
Private mdate, mkol1 := 0, mkol2 := 0, mkol11 := 0, mkol12 := 0, mkol13 := 0,;
        mrec, CODE_LPU := glob_mo[_MO_KOD_TFOMS]
Private sgod := 2023

//
G_Use(dir_server + "mo_dr05p",,"R05p")
if lastrec() == 0
  G_RLock(.t.,forever) // добавить 2-ую запись
endif
mrec := 1 // пока так
goto (mrec)
if empty(r05p->n_y)
  mdate := r05p->D_KZ := 0d20221214
  r05p->N_Y := sgod // год для диспансеризации
  r05p->TYPEOFREC := 0 // 0-первично представленная запись, 1-актуализированная запись
  r05p->KOL1 := 0 // количество пациентов для диспансеризации на год
  r05p->KOL2 := 0 // количество пациентов для профосмотров на год
else
  //sgod := r05p->N_Y
  mkol1 := r05p->KOL1
  mkol11 := r05p->KOL11
  mkol12 := r05p->KOL12
  mkol13 := r05p->KOL13
  mkol2 := r05p->KOL2
  mdate := r05p->D_KZ
endif
use
//
// !!! ВНИМАНИЕ
Private r05_nn := 4, write_reestr := .f., is_reestr := .f.
verify_packet_R05(1,{},@r05_nn)
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

***** 12.12.19 Ввод/редактирование плана-графика диспансеризации на год
Function f1_create_R05()
Local r1 := 13, buf, buf24 := save_maxrow(), tmp_color := setcolor(cDataCGet)
Private skol1 := 0, skol2 := 0, skol11 := 0, skol12 := 0, skol13 := 0
buf := box_shadow(r1,2,maxrow()-2,77,,"План-график на "+lstr(sgod)+" год",color8)
do while .t.
  @ r1+1,54 say "| прикреплённое" color color14
  @ r1+2,4 say "Приказ КЗ ВО №3630 от" get mdate when .f.
   @ row(),col()+12 say "_план_|_количество___" color color14
  @ r1+3,4 say "Численность лиц для диспансеризации (всего)" get mkol1  pict "99999"
   @ row(),col()+1 say "|" color color14 get skol1 color color8 pict "99999" when .f.
  @ r1+4,4 say "            в т.ч. лиц старше труд.возраста" get mkol11 pict "99999"
   @ row(),col()+1 say "|" color color14 get skol11 color color8 pict "99999" when .f.
  @ r1+5,4 say "                      лиц в возрасте 65 лет" get mkol12 pict "99999"
   @ row(),col()+1 say "|" color color14 get skol12 color color8 pict "99999" when .f.
  @ r1+6,4 say "             лиц в возрасте 66 лет и старше" get mkol13 pict "99999"
   @ row(),col()+1 say "|" color color14 get skol13 color color8 pict "99999" when .f.
  @ r1+7,4 say "Численность лиц, подлежащих профосмотрам   " get mkol2  pict "99999"
   @ row(),col()+1 say "|" color color14 get skol2 color color8 pict "99999" when .f.
  if is_reestr
    status_key("^<Esc>^ - выход из режима (файл обмена R05 уже составлен)")
    mybell(0,ERR)
    clear_gets()
    exit
  else
    status_key("^<Esc>^ выход  ^<Enter>^ подтверждение ввода  ^<F8>^ подсчёт прикреплённого количества")
    set key K_F8 TO f_pereschet_R05
    myread()
    set key K_F8 TO
    if lastkey() != K_ESC .and. f_Esc_Enter(1)
      if mkol1 > mkol11
        if mkol11 > mkol12
          if mkol11 > mkol13
            if mkol12 > mkol13
              func_error(4,"План лиц 65 лет должен быть меньше плана лиц 66 лет и старше")
              loop
            endif
          else
            func_error(4,"План лиц старше труд.возраста должен быть больше плана лиц 66 лет и старше")
            loop
          endif
        else
          func_error(4,"План лиц старше труд.возраста должен быть больше плана лиц 65 лет")
          loop
        endif
        if mkol11 > mkol12+mkol13
        else
          func_error(4,"План старше труд.возраста должен быть больше общего плана 65 + 66 лет и старше")
          loop
        endif
      else
        func_error(4,"План лиц старше труд.возраста должен быть меньше плана итого")
        loop
      endif
      G_Use(dir_server + "mo_dr05p",,"R05p")
      goto (mrec)
      G_RLock(forever)
      if empty(r05p->n_y)
        r05p->N_Y := sgod // год для диспансеризации
      endif
      r05p->KOL1 := mkol1
      r05p->KOL11 := mkol11
      r05p->KOL12 := mkol12
      r05p->KOL13 := mkol13
      r05p->KOL2 := mkol2 // количество пациентов для профосмотров на год
      use
    endif
    exit
  endif
enddo
setcolor(tmp_color)
rest_box(buf)
rest_box(buf24)
return NIL

***** 18.12.22 Ввод/редактирование плана-графика с разбивкой по месяцам
Function f_pereschet_R05
Local buf := save_maxrow(), nrow := row(), ncol := col(), icurs := setcursor(0), s,;
      _arr_vozrast_DVN := ret_arr_vozrast_DVN(0d20221201)
mywait("Ждите! Производится подсчёт прикреплённого взрослого населения.")
skol1 := skol2 := skol11 := skol12 := skol13 := 0
R_Use(dir_server + "kartote2",,"KART2")
R_Use(dir_server + "kartote_",,"KART_")
R_Use(dir_server + "kartotek",,"KART")
set relation to recno() into KART_, recno() into KART2
go top
do while !eof()
  @ maxrow(),0 say str(recno()/lastrec()*100,6,2)+"%" color cColorWait
  if (v := sgod - year(kart->date_r)) > 17 .and. v < 100 ; // взрослый
                  .and. kart2->MO_PR == glob_mo[_MO_KOD_TFOMS] ; // прикреплён к нашей МО
                  .and. !(left(kart2->PC2,1) == "1") // и не умер
    s := upper(kart->fio)+" "
    if " УМЕР " $ s .or. " УМЕРЛА " $ s
      //
    elseif ascan(_arr_vozrast_DVN,v) == 0 // профосмотр
      skol2++
    else
      skol1++
      if v >= iif(kart->POL == "М", 60, 55)
        skol11++
        if v == 65
          skol12++
        elseif v > 65
          skol13++
        endif
      endif
    endif
  endif
  select KART
  skip
enddo
close databases
rest_box(buf)
update_gets()
@ nrow,ncol say ""
if icurs != 0
  setcursor()
endif
return NIL


***** 23.12.19 Ввод/редактирование плана-графика с разбивкой по месяцам
Function f2_create_R05()
Local buf := savescreen(), tmp_color, t_arr[BR_LEN], blk, blk1, i, d, tekol[5]
Private skol[5], ekol[5]
afill(ekol,0)
//afill(tekol,0)
tmp_color := setcolor(color5)
R_Use(dir_server + "mo_dr05p",,"R05p")
goto (mrec)
skol[1] := r05p->KOL1
skol[2] := r05p->KOL2
skol[3] := r05p->KOL11
skol[4] := r05p->KOL12
skol[5] := r05p->KOL13
dbcreate("tmp1",{{"MES",   "N",2,0},;  // месяц
                 {"kol1",  "N",6,0},;
                 {"kol11",  "N",6,0},;
                 {"kol12",  "N",6,0},;
                 {"kol13",  "N",6,0},;
                 {"kol2",  "N",6,0}})
use tmp1 new
for i := 1 to 12
  append blank
  tmp1->mes := i
  tmp1->kol1 := &("r05p->kol1_"+strzero(i,2))
  tmp1->kol2 := &("r05p->kol2_"+strzero(i,2))
  tmp1->kol11 := &("r05p->kol11_"+strzero(i,2))
  tmp1->kol12 := &("r05p->kol12_"+strzero(i,2))
  tmp1->kol13 := &("r05p->kol13_"+strzero(i,2))
  ekol[1] += tmp1->kol1
  ekol[2] += tmp1->kol2
  ekol[3] += tmp1->kol11
  ekol[4] += tmp1->kol12
  ekol[5] += tmp1->kol13
//  tekol[1] += tmp1->kol1
//  tekol[2] += tmp1->kol2
//  tekol[3] += tmp1->kol11
//  tekol[4] += tmp1->kol12
//  tekol[5] += tmp1->kol13
next
//
/*if emptyall(ekol[1],ekol[2])
// записываем в запись 2 из записи 1 два месяца
// первичное заполнение
  select R05P
  goto (1)
  select TMP1
  for i := 1 to 2
    goto (i)
    tmp1->kol1 := &("r05p->kol1_"+strzero(i,2))
    tmp1->kol2 := &("r05p->kol2_"+strzero(i,2))
    tmp1->kol11 := &("r05p->kol11_"+strzero(i,2))
    tmp1->kol12 := &("r05p->kol12_"+strzero(i,2))
    tmp1->kol13 := &("r05p->kol13_"+strzero(i,2))
    ekol[1] += tmp1->kol1
    ekol[2] += tmp1->kol2
    ekol[3] += tmp1->kol11
    ekol[4] += tmp1->kol12
    ekol[5] += tmp1->kol13
    tekol[1] += tmp1->kol1
    tekol[2] += tmp1->kol2
    tekol[3] += tmp1->kol11
    tekol[4] += tmp1->kol12
    tekol[5] += tmp1->kol13
  next
  select R05P
  goto (mrec)
  select TMP1
  //
  for i := 3 to 12
    goto (i)
    tmp1->kol1 := round((skol[1]-tekol[1])/10,0)
    ekol[1] += tmp1->kol1
    tmp1->kol2 := round((skol[2]-tekol[1])/10,0)
    ekol[2] += tmp1->kol2
    tmp1->kol11 := round((skol[3]-tekol[3])/10,0)
    ekol[3] += tmp1->kol11
    tmp1->kol12 := round((skol[4]-tekol[4])/10,0)
    ekol[4] += tmp1->kol12
    tmp1->kol13 := round((skol[5]-tekol[5])/10,0)
    ekol[5] += tmp1->kol13
  next
/*  for i := 1 to 12
    goto (i)
    tmp1->kol1 := round(skol[1]/12,0)
    ekol[1] += tmp1->kol1
    tmp1->kol2 := round(skol[2]/12,0)
    ekol[2] += tmp1->kol2
    tmp1->kol11 := round(skol[3]/12,0)
    ekol[3] += tmp1->kol11
    tmp1->kol12 := round(skol[4]/12,0)
    ekol[4] += tmp1->kol12
    tmp1->kol13 := round(skol[5]/12,0)
    ekol[5] += tmp1->kol13
  next
*/
 /* d := skol[1] - ekol[1]
  if d != 0
    tmp1->kol1 += d
    ekol[1] += d
  endif
  d := skol[2] - ekol[2]
  if d != 0
    tmp1->kol2 += d
    ekol[2] += d
  endif
  d := skol[3] - ekol[3]
  if d != 0
    tmp1->kol11 += d
    ekol[3] += d
  endif
  d := skol[4] - ekol[4]
  if d != 0
    tmp1->kol12 += d
    ekol[4] += d
  endif
  d := skol[5] - ekol[5]
  if d != 0
    tmp1->kol13 += d
    ekol[5] += d
  endif
endif
*/
if emptyall(ekol[1],ekol[2])
  for i := 1 to 12
    goto (i)
    tmp1->kol1 := round(skol[1]/12,0)
    ekol[1] += tmp1->kol1
    tmp1->kol2 := round(skol[2]/12,0)
    ekol[2] += tmp1->kol2
    tmp1->kol11 := round(skol[3]/12,0)
    ekol[3] += tmp1->kol11
    tmp1->kol12 := round(skol[4]/12,0)
    ekol[4] += tmp1->kol12
    tmp1->kol13 := round(skol[5]/12,0)
    ekol[5] += tmp1->kol13
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
  d := skol[3] - ekol[3]
  if d != 0
    tmp1->kol11 += d
    ekol[3] += d
  endif
  d := skol[4] - ekol[4]
  if d != 0
    tmp1->kol12 += d
    ekol[4] += d
  endif
  d := skol[5] - ekol[5]
  if d != 0
    tmp1->kol13 += d
    ekol[5] += d
  endif
endif
r05p->(dbCloseArea())
select TMP1
go top
//
t_arr[BR_TOP] := 1
t_arr[BR_BOTTOM] := 17
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 74
t_arr[BR_COLOR] := color5
t_arr[BR_TITUL] := "План-график на "+lstr(sgod)+" год"
t_arr[BR_TITUL_COLOR] := "B/W"
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/W,W+/N,B/W,W+/B,R/W,W+/R",.t.}
blk1 := {|| iif(ver_f2_create_R05(tmp1->mes),{3,4},{5,6}) }
t_arr[BR_COLUMN] := {;
 { "  Месяц;проведения",           {|| padr(mm_month[tmp1->mes],10) }, blk },;
 { "  Количество;диспансеризаций", {|| str(tmp1->kol1,10) }, blk },;
 { "старше труд.;возраста",        {|| str(tmp1->kol11,10) }, blk },;
 { "65 лет",                       {|| str(tmp1->kol12,6) }, blk },;
 { "66 лет;и старше",              {|| str(tmp1->kol13,8) }, blk },;
 { "Про;вер",                      {|| iif(ver_f2_create_R05(tmp1->mes),"OK ","ERR") }, blk1 },;
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
// проверка
//if !(ver_f3_create_R05())
//  return NIL
//endif
//
if !is_reestr .and. f_Esc_Enter(1)
  G_Use(dir_server + "mo_dr05p",,"R05p")
  goto (mrec)
  G_RLock(forever)
  for i := 1 to 12
    select TMP1
    goto (i)
    &("r05p->kol1_"+strzero(i,2)) := tmp1->kol1
    &("r05p->kol2_"+strzero(i,2)) := tmp1->kol2
    &("r05p->kol11_"+strzero(i,2)) := tmp1->kol11
    &("r05p->kol12_"+strzero(i,2)) := tmp1->kol12
    &("r05p->kol13_"+strzero(i,2)) := tmp1->kol13
  next
endif
close databases
setcolor(tmp_color)
return NIL

***** 20.02.21 //в 2022 пока не используем
/*Function ver_f3_create_R05()
Local flag := .T., i, t[5], tt[5], j, order_t, err_mes

order_t := (select())
G_Use(dir_server + "mo_dr05p",,"R05p")
select R05P
for i := 3 to 12
  if flag
    goto (1)
    t[1] := &("r05p->kol1_"+strzero(i,2))
    t[2] := &("r05p->kol2_"+strzero(i,2))
    t[3] := &("r05p->kol11_"+strzero(i,2))
    t[4] := &("r05p->kol12_"+strzero(i,2))
    t[5] := &("r05p->kol13_"+strzero(i,2))
    select TMP1
    goto (i)
    tt[1] := tmp1->kol1
    tt[2] := tmp1->kol2
    tt[3] := tmp1->kol11
    tt[4] := tmp1->kol12
    tt[5] := tmp1->kol13
    for j := 1 to 5
      if t[j] > tt[j]
        flag := .F.
        err_mes := i
      endif
    next
  endif
next
R05P->(dbCloseArea())
select (order_t)
if !flag
  func_error(4,"Превышение текущего плана над предыдущем. Месяц "+alltrim(str(err_mes)))
endif
return flag
*/

***** 23.12.19
Function ver_f2_create_R05(lmes)
Local fl := .t.
if tmp1->kol1 >= tmp1->kol11
  if tmp1->kol11 >= tmp1->kol12
    if tmp1->kol11 >= tmp1->kol13
      if tmp1->kol12 >= tmp1->kol13
        fl := .f. //func_error(4,"План лиц 65 лет должен быть меньше плана лиц 66 лет и старше")
      endif
    else
      fl := .f. //func_error(4,"План лиц старше труд.возраста должен быть больше плана лиц 66 лет и старше")
    endif
  else
    fl := .f. //func_error(4,"План лиц старше труд.возраста должен быть больше плана лиц 65 лет")
  endif
  if tmp1->kol11 >= tmp1->kol12+tmp1->kol13
  else
    fl := .f. //func_error(4,"План старше труд.возраста должен быть больше общего плана 65 + 66 лет и старше")
  endif
else
  fl := .f. //func_error(4,"План лиц старше труд.возраста должен быть меньше плана итого")
endif
return fl

***** 23.12.19
Function f1_f2_create_R05(nKey,oBrow,regim)
Local ret := -1, rr := row()
if regim == "edit" .and. nKey == K_ENTER .and. eq_any(oBrow:colPos,2,3,4,5,7) .and. !is_reestr
  Private mkol
  if oBrow:colPos == 2
    ncol := 16
    mkol := tmp1->kol1
  elseif oBrow:colPos == 3
    ncol := 32
    mkol := tmp1->kol11
  elseif oBrow:colPos == 4
    ncol := 41
    mkol := tmp1->kol12
  elseif oBrow:colPos == 5
    ncol := 50
    mkol := tmp1->kol13
  elseif oBrow:colPos == 7
    ncol := 63
    mkol := tmp1->kol2
  endif
  //if rr == 5 .or. rr == 6
  //  @ rr,ncol get mkol color "GR+/R" pict "999999" WHEN .F.
  //else
    @ rr,ncol get mkol color "GR+/R" pict "999999"
  //endif
  myread()
  if lastkey() != K_ESC
    if oBrow:colPos == 2
      tmp1->kol1 := mkol
    elseif oBrow:colPos == 3
      tmp1->kol11 := mkol
    elseif oBrow:colPos == 4
      tmp1->kol12 := mkol
    elseif oBrow:colPos == 5
      tmp1->kol13 := mkol
    elseif oBrow:colPos == 7
      tmp1->kol2 := mkol
    endif
    f2_f2_create_R05()
    ret := 0
  endif
endif
return ret

***** 12.12.19
Function f2_f2_create_R05()
Local i, rec := tmp1->(recno()), rr := row(), cc := col(), lcolor[5]
afill(lcolor,color5)
afill(ekol,0)
for i := 1 to 12
  goto (i)
  ekol[1] += tmp1->kol1
  ekol[2] += tmp1->kol2
  ekol[3] += tmp1->kol11
  ekol[4] += tmp1->kol12
  ekol[5] += tmp1->kol13
next
goto (rec)
for i := 1 to 5
  if !(ekol[i] == skol[i])
    lcolor[i] := "R/W"
  endif
next
@ 20,15 say str(ekol[1],7) color lcolor[1]
@ 20,31 say str(ekol[3],7) color lcolor[3]
@ 20,40 say str(ekol[4],7) color lcolor[4]
@ 20,49 say str(ekol[5],7) color lcolor[5]
@ 20,62 say str(ekol[2],7) color lcolor[2]
@ 21,15 say str(skol[1],7)+str(skol[3],16)+str(skol[4],9)+str(skol[5],9)+str(skol[2],13) color color5
SetPos(rr,cc)
return NIL

***** 12.12.19
Function read_R05(full_zip)
Local arr_f, aerr := {}, name_zip := StripPath(full_zip)
Local fl := .f., n, cName := Name_Without_Ext(name_zip)
if (arr_f := Extract_Zip_XML(KeepPath(full_zip),name_zip)) != NIL
  if (n := ascan(arr_f,{|x| upper(Name_Without_Ext(x)) == upper(cName)})) > 0
    cFile := arr_f[n]
    mywait("Производится анализ файла "+cFile)
    cReadFile := Name_Without_Ext(cFile)
    cFileProtokol := cReadFile+stxt
    strfile(space(10)+"Протокол обработки файла: "+cFile+hb_eol(),cFileProtokol)
    // читаем файл в память
    oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
    if oXmlDoc == NIL .or. empty( oXmlDoc:aItems )
      aadd(aerr,"Ошибка в чтении файла "+cFile)
    else
      reestr_R05_tmpfile(oXmlDoc,aerr,cReadFile)
    endif
    if empty(aerr)
      fl := .t.
    else
      aeval(aerr,{|x| strfile(x+hb_eol(),cFileProtokol,.t.) })
      viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,2)
      delete file (cFileProtokol)
      fl := .f.
    endif
    close databases
  else
    fl := func_error(4,"В архиве "+name_zip+" нет файла "+cName+sxml)
  endif
endif
return fl

***** 23.12.19 Создание файла обмена R05
Function f3_create_R05()
Local buf := save_maxrow(), i, j, skol[5], ekol := {0,0,0,0,0}, k, n, fl := .t.
if !write_reestr
  fl := func_error(4,"Файл обмена R05 уже составлен!")
endif
Private auch := {}, ames[12,5], aumes[12,5]
if fl
  R_Use(dir_server + "mo_dr05p",,"R05p")
  goto (mrec)
  for n := 1 to 5
    if n < 3
      skol[n] := &("r05p->KOL"+lstr(n))
    else
      k := n - 2
      skol[n] := &("r05p->KOL1"+lstr(k))
    endif
  next
  if emptyall(skol[1],skol[2])
    fl := func_error(4,"Не введён план-график на "+lstr(sgod)+" год")
  endif
  for i := 1 to 12
    for j := 1 to 5
      if j < 3
        ames[i,j] := &("r05p->kol"+lstr(j)+"_"+strzero(i,2))
      else
        k := j - 2
        ames[i,j] := &("r05p->kol1"+lstr(k)+"_"+strzero(i,2))
      endif
      ekol[j] += ames[i,j]
    next
  next
  r05p->(dbCloseArea())
endif
if fl .and. emptyall(ekol[1],ekol[2])
  fl := func_error(4,"Не введена разбивка по месяцам плана-график на "+lstr(sgod)+" год")
endif
if fl .and. !(skol[1] == ekol[1] .and. skol[2] == ekol[2] .and. skol[3] == ekol[3] ;
                                 .and. skol[4] == ekol[4] .and. skol[5] == ekol[5])
  fl := func_error(4,"Разбивка по месяцам в сумме не равна плану-графику на "+lstr(sgod)+" год")
endif
if fl
  // !!! ВНИМАНИЕ

  for i := 1 to 12 //3
    if ames[i,1] >= ames[i,3]
      if ames[i,3] >= ames[i,4]
        if ames[i,3] >= ames[i,5]
          if ames[i,4] >= ames[i,5]
            fl := func_error(4,"План лиц 65 лет должен быть меньше плана лиц 66 лет и старше")
          endif
        else
          fl := func_error(4,"План лиц старше труд.возраста должен быть больше плана лиц 66 лет и старше")
        endif
      else
        fl := func_error(4,"План лиц старше труд.возраста должен быть больше плана лиц 65 лет")
      endif
      if ames[i,3] >= ames[i,4] + ames[i,5]
        //
      else
        fl := func_error(4,"План старше труд.возраста должен быть больше общего плана 65 + 66 лет и старше")
      endif
    else
      fl := func_error(4,"План лиц старше труд.возраста должен быть меньше плана итого")
    endif
    if !fl
      func_error(4,'Исправьте в плане-графике по месяцам информацию за "'+mm_month[i]+'"')
      exit
    endif
  next
endif
if fl
  waitstatus("Работа с участками...")
  R_use_base("kartotek")
  set order to 4
  R_Use(dir_server + "mo_uchvr",,"UV")
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
// !!! ВНИМАНИЕ
  for i := 1 to 12  //3
    for j := 1 to 5
      aumes[i,j] := f1_f3_create_R05(ames[i,j],k)
    next
  next
  rest_box(buf)

  if f_Esc_Enter("создания файла R05")
// !!! ВНИМАНИЕ
    mmes := 1  // менял 3
    nsh := 3
    R_Use(dir_server + "mo_dr05p",,"R05p")
    goto (mrec)
    G_Use(dir_server + "mo_dr05k",,"RHUM")
    index on str(REESTR,6) to (cur_dir+"tmp_rhum")
    G_Use(dir_server + "mo_dr05",,"REES")
    AddRecN()
    rees->KOD    := recno()
    rees->REC_5P := mrec // номер записи в файле mo_dr05p
    rees->DSCHET := sys_date
    rees->NYEAR  := sgod
    rees->NN     := r05_nn+1
    s := "R05"+"T34M"+CODE_LPU+"_"+right(strzero(rees->NYEAR,4),2)+"00"+strzero(rees->NN,nsh)
    rees->NAME_XML := s
    mkod_reestr := rees->KOD
    //
    G_Use(dir_server + "mo_xml",,"MO_XML")
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
      mo_add_xml_stroke(oXmlNode,"VERSION",'3.0')
      mo_add_xml_stroke(oXmlNode,"DATE_F",date2xml(mo_xml->DFILE))
      mo_add_xml_stroke(oXmlNode,"NAME_F",mo_xml->FNAME)
     oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "GENERAL_INFO" ) )
      mo_add_xml_stroke(oXmlNode,"CODEM",CODE_LPU)
      mo_add_xml_stroke(oXmlNode,"YEAR",lstr(rees->NYEAR))
      mo_add_xml_stroke(oXmlNode,"SIGN",lstr(r05p->TYPEOFREC))
      oVOLUMES := oXmlNode:Add( HXMLNode():New( "VOLUMES" ) )
       oVOLUME := oVOLUMES:Add( HXMLNode():New( "VOLUME" ) )
        mo_add_xml_stroke(oVOLUME,"PREVENTIVE_ACTION","R")
        mo_add_xml_stroke(oVOLUME,"QUANTITY",lstr(r05p->kol2))
       oVOLUME := oVOLUMES:Add( HXMLNode():New( "VOLUME" ) )
        mo_add_xml_stroke(oVOLUME,"PREVENTIVE_ACTION","O")
        mo_add_xml_stroke(oVOLUME,"QUANTITY",lstr(r05p->kol1))
       oVOLUME := oVOLUMES:Add( HXMLNode():New( "VOLUME" ) )
        mo_add_xml_stroke(oVOLUME,"PREVENTIVE_ACTION","D")
        mo_add_xml_stroke(oVOLUME,"QUANTITY",lstr(r05p->kol11))
       oVOLUME := oVOLUMES:Add( HXMLNode():New( "VOLUME" ) )
        mo_add_xml_stroke(oVOLUME,"PREVENTIVE_ACTION","P")
        mo_add_xml_stroke(oVOLUME,"QUANTITY",lstr(r05p->kol12))
       oVOLUME := oVOLUMES:Add( HXMLNode():New( "VOLUME" ) )
        mo_add_xml_stroke(oVOLUME,"PREVENTIVE_ACTION","Y")
        mo_add_xml_stroke(oVOLUME,"QUANTITY",lstr(r05p->kol13))
     oZAPS := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZAPS" ) )
    icode := 0
// !!! ВНИМАНИЕ
    for i := mmes to 12 // месяцы
      oZAP := oZAPS:Add( HXMLNode():New( "ZAP" ) )
       mo_add_xml_stroke(oZAP,"MONTH",lstr(i))
      for l := 1 to 5 // 1-диспансеризация 1 этап, 2-профосмотр
        j := {2,1,3,4,5}[l]
        if len(aumes[i,j]) == 0// участки
          loop
        endif
        oQUANTITY_INFO := oZAP:Add( HXMLNode():New( "QUANTITY_INFO" ) )
         mo_add_xml_stroke(oQUANTITY_INFO,"PR_ACTION",{"O","R","D","P","Y"}[j])
         if j < 3
           v := &("r05p->kol"+lstr(j)+"_"+strzero(i,2))
         else
           n := j - 2
           v := &("r05p->kol1"+lstr(n)+"_"+strzero(i,2))
         endif
         mo_add_xml_stroke(oQUANTITY_INFO,"QUANTITY_MONTH",lstr(v))
         oRECORDS := oQUANTITY_INFO:Add( HXMLNode():New( "RECORDS" ) )
        for k := 1 to len(aumes[i,j]) // участки
          ++icode
          select RHUM
          AddRec(6)
          rhum->REESTR := mkod_reestr
          rhum->tip := j  // 1-диспансеризация 1 этап, 2-профосмотр
          v := 4
          if j == 3
            v := 3
          elseif j == 4
            v := 1
          elseif j == 5
            v := 2
          endif
          rhum->voz := v // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-прочие
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

***** 11.07.18 разбиение графика за месяц по участкам
Function f1_f3_create_R05(v,su)
Local i, d, k := 0, l := len(auch)
Local arr := array(l,2)
for i := 1 to l
  arr[i,1] := auch[i,1]
  arr[i,2] := int(v*auch[i,2]/su)
  if arr[i,2] < 0  // не должно быть меньше нуля
    arr[i,2] := 0
  endif
  k += arr[i,2]
next
d := v - k
if d > 0
  asort(arr,,,{|x,y| x[2] < y[2] })
  do while d > 0
    for i := 1 to l
      arr[i,2] ++
      if --d == 0 ; exit ; endif
    next
  enddo
  asort(arr,,,{|x,y| x[1] < y[1] })
endif
return aclone(arr)

***** 12.12.19 зачитать R05 во временные файлы
Function reestr_R05_tmpfile(oXmlDoc,aerr,mname_xml)
Local i, j, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()
DEFAULT aerr TO {}, mname_xml TO ""
stat_msg("Распаковка/чтение/анализ файла "+beforatnum(".",mname_xml))
dbcreate(cur_dir+"tmp1file", {;
   {"VERSION",  "C", 5,0},;
   {"DATE_F",   "D", 8,0},;
   {"NAME_F",   "C",26,0},;
   {"codem",    "C", 6,0},;
   {"year",     "N", 4,0},;
   {"sign",     "N", 1,0},;
   {"kol1",     "N", 6,0},;
   {"kol2",     "N", 6,0},;
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
   {"KOL11_01",  "N", 6,0},; // количество пациентов для диспансеризации на 1 месяц
   {"KOL11_02",  "N", 6,0},; // количество пациентов для диспансеризации на 2 месяц
   {"KOL11_03",  "N", 6,0},; // количество пациентов для диспансеризации на 3 месяц
   {"KOL11_04",  "N", 6,0},; // количество пациентов для диспансеризации на 4 месяц
   {"KOL11_05",  "N", 6,0},; // количество пациентов для диспансеризации на 5 месяц
   {"KOL11_06",  "N", 6,0},; // количество пациентов для диспансеризации на 6 месяц
   {"KOL11_07",  "N", 6,0},; // количество пациентов для диспансеризации на 7 месяц
   {"KOL11_08",  "N", 6,0},; // количество пациентов для диспансеризации на 8 месяц
   {"KOL11_09",  "N", 6,0},; // количество пациентов для диспансеризации на 9 месяц
   {"KOL11_10",  "N", 6,0},; // количество пациентов для диспансеризации на 10 месяц
   {"KOL11_11",  "N", 6,0},; // количество пациентов для диспансеризации на 11 месяц
   {"KOL11_12",  "N", 6,0},; // количество пациентов для диспансеризации на 12 месяц
   {"KOL11_01",  "N", 6,0},; // количество пациентов для диспансеризации на 1 месяц
   {"KOL12_02",  "N", 6,0},; // количество пациентов для диспансеризации на 2 месяц
   {"KOL12_03",  "N", 6,0},; // количество пациентов для диспансеризации на 3 месяц
   {"KOL12_04",  "N", 6,0},; // количество пациентов для диспансеризации на 4 месяц
   {"KOL12_05",  "N", 6,0},; // количество пациентов для диспансеризации на 5 месяц
   {"KOL12_06",  "N", 6,0},; // количество пациентов для диспансеризации на 6 месяц
   {"KOL12_07",  "N", 6,0},; // количество пациентов для диспансеризации на 7 месяц
   {"KOL12_08",  "N", 6,0},; // количество пациентов для диспансеризации на 8 месяц
   {"KOL12_09",  "N", 6,0},; // количество пациентов для диспансеризации на 9 месяц
   {"KOL12_10",  "N", 6,0},; // количество пациентов для диспансеризации на 10 месяц
   {"KOL12_11",  "N", 6,0},; // количество пациентов для диспансеризации на 11 месяц
   {"KOL12_12",  "N", 6,0},; // количество пациентов для диспансеризации на 12 месяц
   {"KOL13_01",  "N", 6,0},; // количество пациентов для диспансеризации на 1 месяц
   {"KOL13_02",  "N", 6,0},; // количество пациентов для диспансеризации на 2 месяц
   {"KOL13_03",  "N", 6,0},; // количество пациентов для диспансеризации на 3 месяц
   {"KOL13_04",  "N", 6,0},; // количество пациентов для диспансеризации на 4 месяц
   {"KOL13_05",  "N", 6,0},; // количество пациентов для диспансеризации на 5 месяц
   {"KOL13_06",  "N", 6,0},; // количество пациентов для диспансеризации на 6 месяц
   {"KOL13_07",  "N", 6,0},; // количество пациентов для диспансеризации на 7 месяц
   {"KOL13_08",  "N", 6,0},; // количество пациентов для диспансеризации на 8 месяц
   {"KOL13_09",  "N", 6,0},; // количество пациентов для диспансеризации на 9 месяц
   {"KOL13_10",  "N", 6,0},; // количество пациентов для диспансеризации на 10 месяц
   {"KOL13_11",  "N", 6,0},; // количество пациентов для диспансеризации на 11 месяц
   {"KOL13_12",  "N", 6,0}; // количество пациентов для диспансеризации на 12 месяц
})
dbcreate(cur_dir+"tmp2file", {;
   {"tip",      "N", 1,0},; // 1-диспансеризация 1 этап, 2-профосмотр
   {"N_M",      "N", 2,0},; // месяц для диспансеризации (1-12)
   {"UCH",      "N", 2,0},; // номер участка (для отсылки в ТФОМС)
   {"R05_ZAP",  "N", 6,0},; // номер позиции записи в реестре;"CODE_R" в R05
   {"KOL",      "N", 6,0};  // количество пациентов в реестре/файле
})
use (cur_dir+"tmp1file") new alias TMP1
append blank
use (cur_dir+"tmp2file") new alias TMP2
FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
  @ maxrow(),1 say padr(lstr(j),6) color cColorSt2Msg
  oXmlNode := oXmlDoc:aItems[1]:aItems[j]
  do case
    case "ZGLV" == oXmlNode:title
      tmp1->VERSION :=          mo_read_xml_stroke(oXmlNode,"VERSION",aerr)
      tmp1->DATE_F  := xml2date(mo_read_xml_stroke(oXmlNode,"DATE_F", aerr))
      tmp1->NAME_F  :=          mo_read_xml_stroke(oXmlNode,"NAME_F", aerr)
    case "GENERAL_INFO" == oXmlNode:title
      tmp1->CODEM :=     mo_read_xml_stroke(oXmlNode,"CODEM",aerr)
      tmp1->YEAR  := val(mo_read_xml_stroke(oXmlNode,"YEAR",aerr))
      tmp1->SIGN  := val(mo_read_xml_stroke(oXmlNode,"SIGN",aerr))
      if (oNode1 := oXmlNode:Find("VOLUMES")) != NIL
        for i := 1 to len(oNode1:aitems) // последовательный просмотр
          oNode2 := oNode1:aItems[i]     // т.к. м.б. несколько
          if "VOLUME" == oNode2:title
            s := alltrim(mo_read_xml_stroke(oNode2,"PREVENTIVE_ACTION",aerr))
            if s == "O"
              s1 := "1"
            elseif s == "R"
              s1 := "2"
            elseif s == "D"
              s1 := "11"
            elseif s == "P"
              s1 := "12"
            else
              s1 := "13"
            endif
            pole := "tmp1->kol"+s1
            &pole := val(mo_read_xml_stroke(oNode2,"QUANTITY",aerr))
          endif
        next
      endif
    case "ZAPS" == oXmlNode:title
      for j1 := 1 to len(oXmlNode:aitems)
        oNode1 := oXmlNode:aItems[j1]
        if oNode1:title == "ZAP"
          im := val(mo_read_xml_stroke(oNode1,"MONTH",aerr))
          for j2 := 1 to len(oNode1:aitems)
            oNode2 := oNode1:aItems[j2]
            if oNode2:title == "QUANTITY_INFO"
              s := alltrim(mo_read_xml_stroke(oNode2,"PR_ACTION",aerr))
              if s == "O"
                s1 := "1"
              elseif s == "R"
                s1 := "2"
              elseif s == "D"
                s1 := "11"
              elseif s == "P"
                s1 := "12"
              else
                s1 := "13"
              endif
              pole := "tmp1->kol"+s1+"_"+strzero(im,2)
              &pole := val(mo_read_xml_stroke(oNode2,"QUANTITY_MONTH",aerr))
              if (oNode3 := oNode2:Find("RECORDS")) != NIL
                for j4 := 1 to len(oNode3:aitems)
                  oNode4 := oNode3:aItems[j4]
                  if "RECORD" == oNode4:title
                    select TMP2
                    append blank
                    tmp2->tip     := ip
                    tmp2->N_M     := im
                    tmp2->UCH     := val(mo_read_xml_stroke(oNode4,"NAME_DISTRICT",aerr))
                    tmp2->R05_ZAP := val(mo_read_xml_stroke(oNode4,"CODE_R",aerr))
                    tmp2->KOL     := val(mo_read_xml_stroke(oNode4,"QUANTITY_D",aerr))
                  endif
                next j4
              endif
            endif
          next j2
        endif
      next j1
  endcase
NEXT j
commit
rest_box(buf)
return NIL

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

** 26.12.22 прочитать и "разнести" по базам данных файл R06
Function read_XML_FILE_R06(arr_XML_info,aerr,/*@*/current_i2,lrec_xml)
Local count_in_schet := 0, bSaveHandler, ii1, ii2, i, j, k, t_arr[2], ldate_R06, s
DEFAULT lrec_xml TO 0
mkod_reestr := arr_XML_info[7]
use (cur_dir+"tmp1file") new alias TMP1
ldate_R06 := tmp1->_DATE_F
R_Use(dir_server + "mo_dr05",,"REES")
goto (arr_XML_info[7])
strfile("Обрабатывается ответ ТФОМС на информационный пакет "+alltrim(rees->NAME_XML)+sxml+hb_eol()+;
        "за "+lstr(rees->NYEAR)+" год от "+date_8(rees->DSCHET)+"г."+hb_eol()+hb_eol(),cFileProtokol,.t.)
//
R_Use(dir_server + "mo_dr05k",,"RHUM")
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
  G_Use(dir_server + "mo_xml",,"MO_XML")
  if empty(lrec_xml)
    AddRecN()
  else
    goto (lrec_xml)
    G_RLock(forever)
  endif
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
    G_Use(dir_server + "mo_dr05e",,"REFR")
    index on str(REESTR,6)+str(R05_ZAP,6)+str(KOD_ERR,3) to (cur_dir+"tmp_r05e")
  endif
  G_Use(dir_server + "mo_dr05k",,"RHUM")
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
      s := ""
      do case
        case rhum->tip == 1
          s := "диспансеризация (всего)"
        case rhum->tip == 2
          s := "профосмотр"
        case rhum->tip == 3
          s := "диспансеризация (пенсионеры)"
        case rhum->tip == 4
          s := "диспансеризация (65 лет)"
        case rhum->tip == 5
          s := "диспансеризация (66 лет и старше)"
      endcase
      if tmp2->_N_ZAP > 0
        strfile("CODE_R="+lstr(tmp2->_N_ZAP)+", "+s+;
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
      // if (j := ascan(getT012(), {|x| x[2] == tmp2->_ERROR })) > 0
      //   strfile(space(8) + "ошибка " + lstr(tmp2->_ERROR) + " - " + getT012()[j,1] + hb_eol(), cFileProtokol, .t.)
      // else
      //   strfile(space(8)+"ошибка "+lstr(tmp2->_ERROR)+" (неизвестная ошибка)"+hb_eol(),cFileProtokol,.t.)
      // endif
      strfile(space(8) + getError_T012(tmp2->_ERROR) + hb_eol(), cFileProtokol, .t.)
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
G_Use(dir_server + "mo_xml",,"MO_XML")
R_Use(dir_server + "mo_dr05p",,"R05p")
G_Use(dir_server + "mo_dr05",,"REES")
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
oColumn := TBColumnNew(" Наименование файла",{|| padr(rees->NAME_XML,21) })
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
      for reestr == rees->kod .and. tip_in == _XML_FILE_R06 .and. empty(TIP_OUT)
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

***** 12.12.19
Function f31_view_R05(reg,s)
Local fl, buf := save_maxrow(), i, j, v, sh := 80, HH := 60, n_file := "r05_spis"+stxt
mywait()
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string(glob_mo[_MO_SHORT_NAME])
add_string("")
add_string(center("Численность по месяцам из файла "+alltrim(rees->NAME_XML)+" от "+date_8(rees->dschet),sh))
add_string("")
add_string("Приказ Комитета здравоохранения Волгоградской области от "+full_date(r05p->d_kz)+"г.")
for j := 1 to 5
  if j < 3
    v := &("r05p->kol"+lstr(j))
  else
    v := &("r05p->kol1"+lstr(j-2))
  endif
  if v > 0
    add_string("")
    s := {"Диспансеризация",;
          "Профилактические осмотры взрослых",;
          "Диспансеризация (старше труд.возраста)",;
          "Диспансеризация (65 лет)",;
          "Диспансеризация (66 лет и старше)"}[j]
    verify_FF(HH-13,.t.,sh)
    add_string(s+" на "+lstr(r05p->n_y)+" год - "+lstr(v)+" чел.")
    fl := .t.
    for i := 1 to 12
      if j < 3
        v := &("r05p->kol"+lstr(j)+"_"+strzero(i,2))
      else
        v := &("r05p->kol1"+lstr(j-2)+"_"+strzero(i,2))
      endif
      if v > 0
        s := iif(fl, "в том числе","")+" на "+mm_month[i]
        fl := .f.
        add_string(padl(s,25)+str(v,6))
      endif
    next
  endif
next
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.t.,,,2)
return NIL

***** 22.12.19
Function verify_packet_R05(par,arr,/*@*/ret_nn)
Local fl := .t.
is_reestr := .f.
ret_nn := 0 // !!! ВНИМАНИЕ  0
R_Use(dir_server + "mo_dr05e",,"REFR")
R_Use(dir_server + "mo_xml",,"MO_XML")
index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in == _XML_FILE_R06 .and. empty(TIP_OUT)
R_Use(dir_server + "mo_dr05",,"R05")
index on str(REC_5P,3)+str(1000-nn,4) to (cur_dir+"tmp_r05") for nyear == sgod
find (str(mrec,3))
if found()
  is_reestr := .t.
  ret_nn := r05->nn
  select MO_XML
  find (str(r05->kod,6))
  if found()
    select REFR
    Locate for reestr == r05->kod
    if found()
      fl := .f.
      write_reestr := .t.
      aadd(arr,"В ответе PR05 на файл обмена R05 присутствуют ошибки")
      if refr->r05_zap == 0 .and. refr->kod_err == 510
        aadd(arr,"Ошибка 510 - отредактируйте плановое количество за год и по месяцам")
        is_reestr := .f.
      endif
    else
      write_reestr := .f.
    endif
  else
    fl := .f.
    aadd(arr,"Не получен ответ (PR05) на файл обмена R05")
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

***** 18.12.22 Создание файла обмена R01...
Function f_create_R01()
Local buf := save_maxrow(), i, j, ir, s := "", arr := {}, fl := .t., fl1 := .f., a_reestr := {},;
      azip := {}, aerr := {}, full_zip, name_zip, cFile, cName, oXmlDoc, lgod_r
Private SMONTH := 1, mdate := sys_date, mrec := 1
// !!! ВНИМАНИЕ
Private c_view := 0, c_found := 0, fl_exit := .f., pj, arr_rees := {},;
        pkol := 0, CODE_LPU := glob_mo[_MO_KOD_TFOMS], CODE_MO := glob_mo[_MO_KOD_FFOMS],;
        mkol := {0,0,0,0,0}, skol[5], ames[12,5], ame[12], bm := SMONTH,; // начальный месяц минус один
        _arr_vozrast_DVN := ret_arr_vozrast_DVN(0d20221201)
Private sgod := 2023

//
f00_create_R01()
//
mywait()
if (fl := verify_packet_R05(1,arr))
  R_Use(dir_server + "mo_dr05p",,"R05p")
  goto (mrec)
  skol[1] := r05p->KOL1
  skol[2] := r05p->KOL2
  skol[3] := r05p->KOL11
  skol[4] := r05p->KOL12
  skol[5] := r05p->KOL13
  skol[1] -= skol[3]
  skol[3] -= skol[4]
  skol[3] -= skol[5]
  for i := 1 to 12
    for j := 1 to 2
      ames[i,j] := { &("r05p->kol"+lstr(j)+"_"+strzero(i,2)), 0 }
    next
    for j := 1 to 3
      ames[i,j+2] := { &("r05p->kol1"+lstr(j)+"_"+strzero(i,2)), 0 }
    next
    ames[i,1,1] -= ames[i,3,1]
    ames[i,3,1] -= ames[i,4,1]
    ames[i,3,1] -= ames[i,5,1]
  next
  afill(ame,0)
  //
  select MO_XML
  index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in == _XML_FILE_R02 .and. empty(TIP_OUT)
  R_Use(dir_server + "mo_dr01",,"REES")
  index on str(nn,3)+str(NMONTH,2) to (cur_dir+"tmp_dr01") for NYEAR == sgod .and. tip == 0
  go top
  do while !eof()
    fl1 := .t.
    if rees->kol_err < 0
      //fl := func_error(4,"В файле R02 за "+lstr(rees->NMONTH)+"-й месяц "+;
      //                   lstr(sgod)+"г. ошибки на уровне файла! Операция запрещена")
    elseif empty(rees->answer)
      fl := func_error(4,"Файл PR01 за "+lstr(rees->NMONTH)+"-й месяц "+;
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
  //
  if fl
    if fl1 // не первый раз составляется реестр в отчётном году
      R_Use(dir_server + "mo_dr01k",,"R01k")
      index on str(reestr,6)+str(kod_k,7) to (cur_dir+"tmp_dr01k")
      Use (dir_server + "mo_dr00") new alias TMP
      index on kod to (cur_dir+"tmp_dr00") for reestr == 0
      go top
      do while !eof()
        j := tmp->tip
        if between(j,1,2)
          j1 := tmp->tip1
          tmp->n_m := tmp->n_q := 0 // если уже заходили в режим и не подтвердили создание XML
          if between(j1,1,3)
            mkol[j1+2] ++
          else
            mkol[j] ++ // подсчёт оставшегося кол-ва в пуле пациентов
          endif
        endif
        skip
      enddo
      commit
      //
      index on str(reestr,6) to (cur_dir+"tmp_dr00")
      for ir := 1 to len(arr_rees)
        select TMP
        find (str(arr_rees[ir],6))
        do while tmp->reestr == arr_rees[ir] .and. !eof()
          select R01k
          find (str(tmp->reestr,6)+str(tmp->kod,7))
          if found()
            if r01k->oplata == 1  // учтён в ТФОМС
              i := tmp->n_m
              if !between(i,1,12)
                fl := func_error(4,"Некорректный месяц в файле MO_DR00.DBF! Операция запрещена")
                exit
              endif
              j := tmp->tip
              j1 := tmp->tip1
              if !between(j,1,2)
                fl := func_error(4,"Некорректный вид осмотра в файле MO_DR00.DBF! Операция запрещена")
                exit
              endif
              if between(j1,1,3)
                ames[i,j1+2,2] ++
                skol[j1+2] --
              else
                ames[i,j,2] ++
                skol[j] --
              endif
            else
              //tp->oplata := r01k->oplata
            endif
          endif
          select TMP
          skip
        enddo
        if !fl ; exit ; endif
    next ir
      if emptyall(skol[1],skol[2],skol[3],skol[4],skol[5])
        fl := func_error(4,"Более не требуется создания файлов обмена!")
      else
        for j := 1 to 5
          if mkol[j] < skol[j]
            s := {"диспансеризаций","профосмотров","дисп.пенсионеров","дисп.65 лет","дисп.66 лет и старше"}[j]
            fl := func_error(4,"Не хватает "+lstr(skol[j]-mkol[j])+" чел. в картотеке для "+s)
          endif
        next
      endif
    else // первый раз составляется реестр в отчётном году
      Status_Key("^<Esc>^ - прервать поиск")
      hGauge := GaugeNew(,,,"Поиск пациентов, подлежащих дисп-ии/профосмотрам",.t.)
      GaugeDisplay( hGauge )
      Use (dir_server + "mo_dr00") new alias TMP
      zap  // т.к.первый раз
      R_Use(dir_server + "human_",,"HUMAN_")
      R_Use(dir_server + "human",dir_server + "humankk","HUMAN")
      set relation to recno() into HUMAN_
      R_Use(dir_server + "kartote2",,"KART2")
      R_Use(dir_server + "kartote_",,"KART_")
      R_Use(dir_server + "kartotek",,"KART")
      set relation to recno() into KART_, recno() into KART2
      go top
      do while !eof()
        GaugeUpdate( hGauge, recno()/lastrec() )
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if kart->kod > 0
          f0_create_R01(sgod,@c_view,@c_found)
        endif
        select KART
        skip
      enddo
      CloseGauge(hGauge)
      if tmp->(lastrec()) == 0
        fl := func_error(4,"При поиске пациентов для диспансеризации не обнаружено сведений!")
      elseif fl_exit
        fl := func_error(4,"Прервано пользователем!")
      endif
    endif
  endif
  //
  if fl
    mywait()
    // ставим принудительную заплатку на 3-й месяц
/*    for v := 1 to 5
      if ames[3,v,1] > ames[3,v,2]
        skol[v] -= (ames[3,v,1]-ames[3,v,2])
        ames[3,v,2] := ames[3,v,1]
      endif
    next*/
    // ЗАПЛАТКА
 /*   if emptyall(skol[1],skol[2],skol[3],skol[4],skol[5])
      for v := 4 to 12
        skol[1] += (ames[v,1,1]-ames[v,1,2])
        skol[2] += (ames[v,2,1]-ames[v,2,2])
        skol[3] += (ames[v,3,1]-ames[v,3,2])
        skol[4] += (ames[v,4,1]-ames[v,4,2])
        skol[5] += (ames[v,5,1]-ames[v,5,2])
      next
    endif */
    // конец
    for v := 1 to 5
      j := {2,4,5,3,1}[v]
      // порядок: 2-профосмотр, 4-65 лет, 5-66 и старше, 3-пенсионеры, 1-остальная дисп-ия
      if empty(skol[j])
        loop
      endif
      pj := j
      d := koef := int(mkol[j] / skol[j]) + 1 // через сколько записей прыгаем
      if d > 50
        d := koef := 33
      endif
      i := 0
      do while skol[j] > 0
        select TMP
        if j == 2 // профосмотр
          index on kod to (cur_dir+"tmp_dr00") for tmp->tip == 2 .and. tmp->n_q == 0 DESCENDING
        elseif j == 1 // работоспособного возраста
          index on kod to (cur_dir+"tmp_dr00") for tmp->tip == 1 .and. tmp->tip1 == 0 .and. tmp->n_q == 0 DESCENDING
        else  // 4-65 лет, 5-66 и старше, 3-пенсионеры
          // выборка 66 и старше
          // затем 65 лет
          // затем остатки песионеров
          index on kod to (cur_dir+"tmp_dr00") for eq_any(tmp->tip,1,2) .and. tmp->tip1 == pj-2 .and. tmp->n_q == 0 DESCENDING
        endif
        go top
        do while !eof()
          if d == koef
            if i >= 12  // месяцы
              i := 0
            endif
            do while i < 12
              ++i
              if ames[i,j,1] > ames[i,j,2] // если ещё не набрали месяц
                tmp->n_m := i
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
        //
        select TMP
        if j == 2
          index on kod to (cur_dir+"tmp_dr00") for tmp->tip == 2 .and. tmp->n_m > 0
        elseif j == 1
          index on kod to (cur_dir+"tmp_dr00") for tmp->tip == 1 .and. tmp->tip1 == 0 .and. tmp->n_m > 0
        else
          index on kod to (cur_dir+"tmp_dr00") for eq_any(tmp->tip,1,2) .and. tmp->tip1 == pj-2 .and. tmp->n_m > 0
        endif
        go top
        do while !eof()
          if tmp->n_q == 0 .and. between(tmp->n_m,1,12)
            tmp->n_q := int((tmp->n_m+2)/3) // определяем номер квартала по месяцу
            ame[tmp->n_m] ++
          endif
          skip
        enddo
        //
      enddo
    next v
  endif
else
  func_error(4,arr[1])
endif
close databases
rest_box(buf)
if fl
  if fl1
    if emptyall(ame[1],ame[2],ame[3],ame[4],ame[5],ame[6],ame[7],ame[8],ame[9],ame[10],ame[11],ame[12])
      func_error(4,"Больше нет необходимости создавать файлы R01 за "+lstr(sgod)+" год")
    else
      f1_create_R01()
    endif
  else
    f1_create_R01()
  endif
endif
close databases
rest_box(buf)
return NIL

/***** 30.09.18
Function f0_create_R01(j,bm)
Local i, d, k := 0, v := 0, fl
for i := bm to 12
  k += ames[i,j,3] // подсчёт итого план по месяцам
next
if empty(k)
  for i := bm to 12
    ames[i,j,3] := 1 // искусственно делаем план = 1
    k += ames[i,j,3] // подсчёт итого план по месяцам
  next
endif
for i := bm to 12
  if ames[i,j,3] > 0
    ames[i,j,1] := int(skol[j]*ames[i,j,3]/k)
    v += ames[i,j,1] // подсчёт итого факт по месяцам
  endif
next
d := skol[j] - v
do while d > 0
  fl := .t.
  for i := bm to 12
    if ames[i,j,3] > 0
      fl := .f.
      ames[i,j,1] ++
      if --d == 0 ; exit ; endif
    endif
  next
  if fl // наверное, не было изначально плана
    exit
  endif
enddo
return NIL*/

***** 18.12.19
Static Function f0_create_R01(sgod,cv,cf)
Local fl, v, ltip, ltip1, lvoz, ag, lgod_r, s
++cv
if (fl := (kart2->MO_PR == CODE_LPU)) // прикреплён к нашей МО
  lgod_r := year(kart->date_r)
  v := sgod - lgod_r
  if (fl := (v > 17)) // только взрослое население
    select HUMAN
    find (str(kart->kod,7))
    do while human->kod_k == kart->kod .and. !eof()
      if between(human->ishod,201,203) .and. year(human->k_data) == sgod
        fl := .f. ; exit // в этом году была диспансеризация или профилактика
      endif
      skip
    enddo
    if fl
      lvoz := 4
      ltip1 := 0
      if ascan(_arr_vozrast_DVN,v) > 0
        ltip := 1 // диспансеризация
        // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-прочие
        if v >= iif(kart->POL == "М", 60, 55)
          lvoz := 3
          ltip1 := 1
          if v == 65
            lvoz := 1
            ltip1 := 2
          elseif v > 65
            lvoz := 2
            ltip1 := 3
          endif
        endif
      else
        ltip := 2 // профосмотры
      endif
    endif
  endif
endif
if fl // За исключением умерших (по сведению ТФОМС) и моложе 100 лет
  fl := !(left(kart2->PC2,1) == "1") .or. v < 100
endif
if fl
  s := upper(kart->fio)+" "
  if " УМЕР " $ s .or. " УМЕРЛА " $ s
    fl := .f.
  endif
endif
if fl
  select TMP
  append blank
  tmp->kod := kart->kod
  tmp->tip := ltip
  tmp->tip1 := ltip1
  tmp->voz := lvoz
  if between(ltip1,1,3)
    ++mkol[ltip1+2]
  else
    ++mkol[ltip]
  endif
  if ++cf % 500 == 0
    tmp->(dbCommit())
  endif
endif
@ maxrow(),1 say lstr(cv) color cColorSt2Msg
@ row(),col() say "/" color "W/R"
@ row(),col() say lstr(cf) color cColorStMsg
return NIL

***** 22.12.22
Function f00_create_R01()
  Local fl := .f., v, t1, t2, lgod_r, ltip1, ltip, lvoz
  local sgod := 2022
  
   Status_Key("^<Esc>^ - прервать поиск")
   hGauge := GaugeNew(, , , "Проверка пациентов, подлежащих дисп-ии/профосмотрам", .t.)
   GaugeDisplay(hGauge)
   Use (dir_server + "mo_dr00") new alias TMP
   R_Use(dir_server + "kartote2", , "KART2")
   R_Use(dir_server + "kartote_", , "KART_")
   R_Use(dir_server + "kartotek", , "KART")
   set relation to recno() into KART_, recno() into KART2
   select TMP
   go top
   do while !eof()
      fl := .F.
     GaugeUpdate(hGauge, recno() / lastrec())
     if inkey() == K_ESC
       fl_exit := .t.
       exit
     endif
     if tmp->reestr == 999999
     /*
       t1 := tmp->kod
       t2 := tmp->voz
       t3 := tmp->tip
       t4 := tmp->tip1
       select KART
       goto (t1)
       // проверяем возраст
       lgod_r := year(kart->date_r)
       v := sgod - lgod_r
       if (v > 17) // только взрослое население
          lvoz := 4
          ltip1 := 0
          if ascan(_arr_vozrast_DVN,v) > 0
            ltip := 1 // диспансеризация
            // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-прочие
            if v >= iif(kart->POL == "М", 60, 55)
              lvoz := 3
              ltip1 := 1
              if v == 65
                lvoz := 1
                ltip1 := 2
              elseif v > 65
                lvoz := 2
                ltip1 := 3
              endif
            endif
          else
            ltip := 2 // профосмотры
          endif
          if t2 != lvoz .or. t3 != ltip .or. t4 != ltip1
            fl := .T.
          endif
       else
         fl := .T.
       endif
     endif
     */
      select TMP
      //if fl
       G_RLock(forever)
       tmp->reestr := 0
       UnLock
     endif
     skip
   enddo
   CloseGauge(hGauge)
   close databases
  return NIL

***** 17.12.19
Function f1_create_R01()
Local SMONTH, nsh := 3, smsg, arr_nn[12]
if !f_Esc_Enter("создания файлов R01",.t.)
  return NIL
endif
afill(arr_nn,0)
G_Use(dir_server + "mo_dr01m",,"RM")
AddRecN()
rm->DWORK := sys_date
rm->TWORK1 := hour_min(seconds())
UnLock
//
G_Use(dir_server + "mo_dr01k",,"RHUM")
index on str(REESTR,6) to (cur_dir+"tmp_rhum")
G_Use(dir_server + "mo_dr01",,"REES")
index on str(NMONTH,2)+str(nn,3) to (cur_dir+"tmp_dr01") for NYEAR == sgod .and. tip == 0
for SMONTH := 1 to 12
  find (str(SMONTH,2))
  do while SMONTH == rees->NMONTH .and. !eof()
    if arr_nn[SMONTH] < rees->nn
      arr_nn[SMONTH] := rees->nn
    endif
    skip
  enddo
next
set index to
G_Use(dir_server + "mo_xml",,"MO_XML")
R_Use(dir_server + "kartote2",,"KART2")
R_Use(dir_server + "kartote_",,"KART_")
R_Use(dir_server + "kartotek",,"KART")
set relation to recno() into KART_, recno() into KART2
G_Use(dir_server + "mo_dr00",,"TMP")
set relation to kod into KART
index on str(n_m,2)+upper(kart->fio)+dtos(kart->date_r) to (cur_dir+"tmp_dr00")
for SMONTH := 1 to 12
  if empty(ame[SMONTH])
    loop
  endif
  smsg := "Составление файла R01 за "+lstr(SMONTH)+"-й месяц"
  stat_msg(smsg)
  select REES
  AddRecN()
  rees->KOD    := recno()
  rees->DSCHET := sys_date
  rees->NYEAR  := sgod
  rees->NMONTH := SMONTH
  rees->NN     := arr_nn[SMONTH]+1
  s := "R01"+"T34M"+CODE_LPU+"_"+right(strzero(rees->NYEAR,4),2)+strzero(rees->NMONTH,2)+strzero(rees->NN,nsh)
  rees->NAME_XML := s
  mkod_reestr := rees->KOD
  //
  rm->(G_RLock(forever))
  &("rm->reestr"+strzero(SMONTH,2)) := mkod_reestr
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
  find (str(SMONTH,2))
  do while tmp->n_m == SMONTH .and. !eof()
    if tmp->reestr == 0
      ++pkol
      @ maxrow(),1 say lstr(pkol) color cColorSt2Msg
      select TMP
      G_RLock(forever)
      tmp->reestr := mkod_reestr
      //
      select RHUM
      AddRec(6)
      rhum->REESTR := mkod_reestr
      rhum->KOD_K := tmp->kod
      rhum->n_m := tmp->n_m
      rhum->tip := tmp->tip
      rhum->tip1 := tmp->tip1
      rhum->voz := tmp->voz
      rhum->R01_ZAP := pkol
      rhum->ID_PAC := mo_guid(1,tmp->kod)
      rhum->OPLATA := 0
    endif
    if pkol % 2000 == 0
      dbUnlockAll()
      dbCommitAll()
    endif
    select TMP
    skip
  enddo
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
    mo_add_xml_stroke(oXmlNode,"VERSION",'3.0')
    mo_add_xml_stroke(oXmlNode,"CODEM",CODE_LPU)
    mo_add_xml_stroke(oXmlNode,"DATE_F",date2xml(mo_xml->DFILE))
    mo_add_xml_stroke(oXmlNode,"NAME_F",mo_xml->FNAME)
    mo_add_xml_stroke(oXmlNode,"SMO",'34')
    mo_add_xml_stroke(oXmlNode,"YEAR",lstr(rees->NYEAR))
    mo_add_xml_stroke(oXmlNode,"MONTH",lstr(rees->NMONTH))
    mo_add_xml_stroke(oXmlNode,"N_PACK",lstr(rees->NN))
  //
  select RHUM
  set relation to kod_k into KART
  index on str(R01_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR == mkod_reestr
  go top
  do while !eof()
    @ maxrow(),0 say str(rhum->R01_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
    arr_fio := retFamImOt(1,.f.)
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "PERSONS" ) )
    mo_add_xml_stroke(oXmlNode,"ZAP",lstr(rhum->R01_ZAP))
    mo_add_xml_stroke(oXmlNode,"IDPAC",rhum->ID_PAC)
    mo_add_xml_stroke(oXmlNode,"SURNAME",arr_fio[1])
    mo_add_xml_stroke(oXmlNode,"NAME",arr_fio[2])
    if !empty(arr_fio[3])
      mo_add_xml_stroke(oXmlNode,"PATRONYMIC",arr_fio[3])
    endif
    mo_add_xml_stroke(oXmlNode,"BIRTHDAY",date2xml(kart->date_r))
    mo_add_xml_stroke(oXmlNode,"SEX",iif(kart->pol=="М",'1','2'))
    if !empty(kart->snils)
      mo_add_xml_stroke(oXmlNode,"SS",transform(kart->SNILS,picture_pf))
    endif
    //  проверим наличие ЕНП - иначе старый вариант
    if len(alltrim(kart2->KOD_MIS)) > 14
      mo_add_xml_stroke(oXmlNode,"TYPE_P",lstr(3)) // только НОВЫЙ
      s := alltrim(kart2->KOD_MIS)
      s := padr(s,16,"0")
      // 
      mo_add_xml_stroke(oXmlNode,"NUM_P",s)
      mo_add_xml_stroke(oXmlNode,"ENP",s)
    else
      mo_add_xml_stroke(oXmlNode,"TYPE_P",lstr(iif(between(kart_->VPOLIS,1,3),kart_->VPOLIS,1)))
      if !empty(kart_->SPOLIS)
        mo_add_xml_stroke(oXmlNode,"SER_P",kart_->SPOLIS)
      endif
      s := alltrim(kart_->NPOLIS)
      if kart_->VPOLIS == 3 .and. len(s) != 16
        s := padr(s,16,"0")
      endif
      mo_add_xml_stroke(oXmlNode,"NUM_P",s)
      if kart_->VPOLIS == 3
        mo_add_xml_stroke(oXmlNode,"ENP",s)
      endif
    endif
    mo_add_xml_stroke(oXmlNode,"DOCTYPE",lstr(kart_->vid_ud))
    if !empty(kart_->ser_ud)
      mo_add_xml_stroke(oXmlNode,"DOCSER",kart_->ser_ud)
    endif
    mo_add_xml_stroke(oXmlNode,"DOCNUM",kart_->nom_ud)
    if !empty(smr := del_spec_symbol(kart_->mesto_r))
      mo_add_xml_stroke(oXmlNode,"MR",smr)
    endif
    mo_add_xml_stroke(oXmlNode,"CATEGORY",'0')
    mo_add_xml_stroke(oXmlNode,"T_PR",{"O","R"}[rhum->tip])
    oCONTACTS := oXmlNode:Add( HXMLNode():New( "CONTACTS" ) )
     if !empty(kart_->PHONE_H)
       mo_add_xml_stroke(oCONTACTS,"TEL_F",left(kart_->PHONE_H,1)+"-"+substr(kart_->PHONE_H,2,4)+"-"+substr(kart_->PHONE_H,6))
     endif
     if !empty(kart_->PHONE_M)
       mo_add_xml_stroke(oCONTACTS,"TEL_M",left(kart_->PHONE_M,1)+"-"+substr(kart_->PHONE_M,2,3)+"-"+substr(kart_->PHONE_M,5))
     endif
     oADDRESS := oCONTACTS:Add( HXMLNode():New( "ADDRESS" ) )
      s := "18000"
      if len(alltrim(kart_->okatop)) == 11
        s := left(kart_->okatop,5)
      elseif len(alltrim(kart_->okatog)) == 11
        s := left(kart_->okatog,5)
      endif
      mo_add_xml_stroke(oADDRESS,"SUBJ",s)
      if !empty(kart->adres)
        mo_add_xml_stroke(oADDRESS,"UL",kart->adres)
      endif
    select RHUM
    skip
  enddo
  stat_msg("Запись XML-файла")
  oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
  chip_create_zipXML(alltrim(mo_xml->FNAME)+szip,{alltrim(mo_xml->FNAME)+sxml},.t.)
next SMONTH
rm->(G_RLock(forever))
rm->TWORK2 := hour_min(seconds())
close databases
keyboard chr(K_TAB)+chr(K_ENTER)
//rest_box(buf)
return NIL

/***** 13.12.17
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
return d*/

***** 29.01.20 Просмотр файлов обмена R01... и результатов работы с ними
Function f_view_R01(tip_f)
Local i, k, buf := savescreen()
DEFAULT tip_f TO _XML_FILE_R01
Private goal_dir := dir_server+dir_XML_MO+cslash, ptip_f := tip_f, pname_f := iif(tip_f==_XML_FILE_R01,"R01","R11")
G_Use(dir_server + "mo_xml",,"MO_XML")
G_Use(dir_server + "mo_dr01",,"REES")
if tip_f == _XML_FILE_R01
  index on descend(dtos(dschet))+str(NMONTH,2)+strzero(nn,3) to (cur_dir+"tmp_rees") for tip == 0
else
  index on descend(strzero(NMONTH,2)+strzero(nn,3)) to (cur_dir+"tmp_rees") for tip == 1
endif
go top
if eof()
  func_error(4,"Не было создано файлов "+pname_f)
else
  Private reg := 1
  Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1_view_R01",color0,,,,,,,;
               "f2_view_R01",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
endif
close databases
restscreen(buf)
return NIL

***** 06.02.20
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
oColumn := TBColumnNew("Период",{|| str(rees->nyear,4)+"/"+strzero(rees->NMONTH,2) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол-во;пациентов", {|| str(rees->kol,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Кол-во; ошибок", {|| iif(rees->kol_err < 0, "в файле", put_val(rees->kol_err,7)) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("От-;вет", {|| iif(rees->answer==1,"да ","нет") })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Наименование файла",{|| padr(rees->NAME_XML,21) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Примечание",{|| f11_view_R01() })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if reg == 1
  status_key("^<Esc>^ выход ^<F5>^ запись для ТФОМС ^<F3>^ информация о файле ^<F9>^ общая информация")
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

***** 06.02.20
Function f2_view_R01(nKey,oBrow)
Local ret := -1, rec := rees->(recno()), tmp_color := setcolor(), r, r1, r2,;
      s, buf := savescreen(), arr, i, k, mdate, t_arr[2], arr_pmt := {}
do case
  case nKey == K_F9
    if ptip_f == _XML_FILE_R01
      f32_view_R01()
    else
      f32_view_R11(rees->NMONTH)
    endif
    select REES
    goto (rec)
    ret := 0
  case nKey == K_F5
    mdate := rees->dschet
    R_Use(dir_server + "mo_dr01m",,"RM")
    Locate for &("rm->reestr"+strzero(rees->NMONTH,2)) == rees->kod
    if !found()
      func_error(4,"В файле MO_DR01M.DBF не найдена ссылка на данный реестр")
    else
      arr := {} ; k := 0
      for i := 1 to 12
        select REES
        Locate for &("rm->reestr"+strzero(i,2)) == rees->kod
        if found()
          aadd(arr, {str(rees->nyear,4)+"/"+strzero(rees->NMONTH,2),rees->name_xml,rees->kod_xml,rees->(recno())})
          if empty(rees->date_out)
            ++k
          endif
        endif
      next i
      if len(arr) == 0
        func_error(4,"Нечего записывать!")
      else
        s := "Количество файлов "+pname_f+" - "+lstr(len(arr))+", записываются в первый раз - "+lstr(k)+":"
        for i := 1 to len(arr)
          if i > 1
            s += ","
          endif
          s += " "+alltrim(arr[i,1])+" ("+alltrim(arr[i,2])+szip+")"
        next
        perenos(t_arr,s,74)
        f_message(t_arr,,color1,color8)
        if f_Esc_Enter("записи файлов "+pname_f)
          Private p_var_manager := "copy_schet"
          s := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,2,.f.,,,) // "norton" для выбора каталога
          if !empty(s)
            if upper(s) == upper(goal_dir)
              func_error(4,"Вы выбрали каталог, в котором уже записаны целевые файлы! Это недопустимо.")
            else
              cFileProtokol := "prot_sch"+stxt
              strfile(hb_eol()+center(glob_mo[_MO_SHORT_NAME],80)+hb_eol()+hb_eol(),cFileProtokol)
              smsg := "Файлы R01 записаны на: "+s+" ("+full_date(sys_date)+"г. "+hour_min(seconds())+")"
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
                    smsg := lstr(i)+". Пакет "+pname_f+" № "+lstr(rees->nn)+;
                            " от "+date_8(mdate)+"г. (отч.период "+;
                             lstr(rees->nyear)+"/"+strzero(rees->NMONTH,2)+;
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
    G_Use(dir_server + "mo_xml",,"MO_XML")
    G_Use(dir_server + "mo_dr01",cur_dir+"tmp_rees","REES")
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
      for reestr == rees->kod .and. tip_in == ptip_f+1 .and. empty(TIP_OUT)
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

***** 17.12.19
Function f31_view_R01(reg,s)
Local fl := .t., buf := save_maxrow(), k := 0, n_file := pname_f+"_SPIS"+stxt, tt := " "
mywait()
arr_title := {"────┬───┬───────┬───────────────────────────────────────────┬──────────┬─────────────────────────────────────────┬──────────────────",;
              " NN │У/к│  Код  │               Ф.И.О.                      │  Дата р. │                   Адрес                 │                  ",;
              "────┴───┴───────┴───────────────────────────────────────────┴──────────┴─────────────────────────────────────────┴──────────────────"}
sh := len(arr_title[1])
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Список пациентов файла "+alltrim(rees->NAME_XML)+" от "+date_8(rees->dschet),120))
if reg == 99
  s := "все пациенты"
endif
if reg == 98
  s := "пациенты без ошибок"
endif
add_string(center("[ "+s+" ]",120))
add_string("")
aeval(arr_title, {|x| add_string(x) })
// создаем для отчета
dbcreate(cur_dir + "_r01",{{"nyh","C",2,0},;
                           {"kod","C",7,0},;
                           {"fio","C",50,0},;
                           {"date_r","C",10,0},;
                           {"adres","C",50,0},;
                           {"tip","C",7,0},;
                           {"mes","C",7,0} })
use (cur_dir + "_r01") new
//
R_Use(dir_server + "kartotek",,"KART")
R_Use(dir_server + "mo_dr01k",,"RHUM")
set relation to kod_k into KART
index on str(rhum->R01_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == rees->kod
go top
do while !eof()
  if reg == 1 //98
    if rhum->OPLATA == 1
    ++k
    s := str(rhum->R01_ZAP,4)+". "
    if empty(kart->fio)
      s += "удалён дубликат в картотеке (код="+lstr(kod_k)+")"
    else
      if is_uchastok == 1
        tt := padr(lstr(kart->kod_vu),7) 
      elseif is_uchastok == 2
        tt := padr(lstr(kart->kod),7)
      else 
        tt := padr(lstr(kart->kod),7)
      endif   
      s += padr(lstr(kart->uchast),2)+" "+tt+" "+padr(upper(kart->fio),43)+" "+full_date(kart->date_r)+" "
    endif
    s += padr(kart->adres,40)+" ("+iif(rhum->tip==1,"ДИСП","проф.")+") "+str(rhum->n_m,2)+"мес."
    select _R01
    append blank
    _r01->nyh    := padr(lstr(kart->uchast),2)
    _r01->kod    := tt
    _r01->fio    := padr(upper(kart->fio),50)
    _r01->date_r := full_date(kart->date_r)
    _r01->adres  := padr(kart->adres,50) 
    _r01->tip    := iif(rhum->tip==1,"ДИСП","проф.")
    _r01->mes    := str(rhum->n_m,2)+"мес."
    select RHUM
    if verify_FF(60,.t.,120)
       aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(s)
    endif
  elseif iif(reg == 99, .t., rhum->OPLATA == reg)
    ++k
    s := str(rhum->R01_ZAP,4)+". "
    if empty(kart->fio)
      s += "удалён дубликат в картотеке (код="+lstr(kod_k)+")"
    else
      s += padr(upper(kart->fio),43)+" "+full_date(kart->date_r)
    endif
    s += " ("+iif(rhum->tip==1,"ДИСП","проф.")+") "+str(rhum->n_m,2)+"мес."
    if verify_FF(60,.t.,120)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(s)
    select _R01
    append blank
    _r01->nyh    := padr(lstr(kart->uchast),2)
    _r01->kod    := tt
    _r01->fio    := padr(upper(kart->fio),50)
    _r01->date_r := full_date(kart->date_r)
    _r01->adres  := padr(kart->adres,50) 
    _r01->tip    := iif(rhum->tip==1,"ДИСП","проф.")
    _r01->mes    := str(rhum->n_m,2)+"мес."
    select RHUM
  endif
  select RHUM
  skip
enddo
add_string("")
add_string("Всего "+lstr(k)+" чел.")
kart->(dbCloseArea())
rhum->(dbCloseArea())
_r01->(dbCloseArea())
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.t.,,,6)
n_file := "_dispr01"
copy file (cur_dir+"_r01"+sdbf) to (cur_dir+n_file+sdbf)
n_message({"В каталоге "+upper(cur_dir),;
           "создан файл "+upper(n_file+sdbf),;
           "со сведениями о планах диспансеризации пациентов."},,;
           cColorStMsg,cColorStMsg,,,cColorSt2Msg)
return NIL

***** 18.12.19
Function f32_view_R01()
Local fl := .t., buf := save_maxrow(), k := 0, skol[5,3], ames[12,5,3], mrec := 2, n_file := "r01_itog"+stxt
Private par := .f.
afillall(skol,0)
afillall(ames,0)
mywait()
R_Use(dir_server + "mo_dr05p",,"R05p")
goto (mrec)
skol[1,1] := r05p->KOL1
skol[2,1] := r05p->KOL2
skol[3,1] := r05p->KOL11
skol[4,1] := r05p->KOL12
skol[5,1] := r05p->KOL13
if par
  skol[1,1] -= skol[3,1]
  skol[3,1] -= skol[4,1]
  skol[3,1] -= skol[5,1]
endif
for i := 1 to 12
  for j := 1 to 2
    ames[i,j,1] := &("r05p->kol"+lstr(j)+"_"+strzero(i,2))
  next
  for j := 1 to 3
    ames[i,j+2,1] := &("r05p->kol1"+lstr(j)+"_"+strzero(i,2))
  next
  if par
    ames[i,1,1] -= ames[i,3,1]
    ames[i,3,1] -= ames[i,4,1]
    ames[i,3,1] -= ames[i,5,1]
  endif
next
r05p->(dbCloseArea())
R_Use(dir_server + "mo_dr01k",,"RHUM")
index on str(reestr,6)+str(rhum->R01_ZAP,6) to (cur_dir+"tmp_rhum")
R_Use(dir_server + "mo_dr01m",,"RM")
go top
do while !eof()
  for i := 1 to 12
    if (mkod_reestr := &("rm->reestr"+strzero(i,2))) > 0
      select RHUM
      find (str(mkod_reestr,6))
      do while rhum->reestr == mkod_reestr .and. !eof()
        if rhum->OPLATA < 2
          j := rhum->tip
          j1 := rhum->tip1
          if between(j1,1,3)
            ames[i,j1+2,2] ++
          elseif between(j,1,2)
            ames[i,j,2] ++
          endif
          if rhum->OPLATA == 1
            if between(j1,1,3)
              ames[i,j1+2,3] ++
            elseif between(j,1,2)
              ames[i,j,3] ++
            endif
          endif
        endif
        select RHUM
        skip
      enddo
    endif
  next
  select RM
  skip
enddo
rm->(dbCloseArea())
rhum->(dbCloseArea())
if !par
  for i := 1 to 12
    for k := 2 to 3
      ames[i,3,k] += ames[i,4,k]
      ames[i,3,k] += ames[i,5,k]
      ames[i,1,k] += ames[i,3,k]
    next
    if i < 4
      for j := 1 to 5
        ames[i,j,2] := ames[i,j,1]
        ames[i,j,3] := ames[i,j,1]
      next
    endif
  next
endif
//
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Общая информация (R01)",80))
add_string("")
mmt := {"диспансеризация","профосмотр","дисп.пенсионеры","дисп.65 лет","дисп.66 и старше"}
for i := 1 to 12
  if verify_FF(55,.t.,80) .or. i == 1
add_string("──────────────────────────┬─────────────┬─────────────┬────────────┬────────────")
add_string("     месяц                │  по плану   │  отправлено │  в ТФОМСе  │ расхождение")
add_string("──────────────────────────┴─────────────┴─────────────┴────────────┴────────────")
  endif
  n := 26
  add_string(padr(mm_month[i],n))
  for j := 1 to 5
    add_string(padl(mmt[j],n)+put_val(ames[i,j,1],11)+;
                              put_val(ames[i,j,2],14)+;
                              put_val(ames[i,j,3],13)+;
                              put_val(ames[i,j,1]-ames[i,j,3],12))
    skol[j,2] += ames[i,j,2]
    skol[j,3] += ames[i,j,3]
  next
next
add_string(padr("Итого:",n))
for j := 1 to 5
  add_string(padl(mmt[j],n)+put_val(skol[j,1],11)+;
                            put_val(skol[j,2],14)+;
                            put_val(skol[j,3],13)+;
                            put_val(skol[j,1]-skol[j,3],12))
next
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.t.,,,2)
return NIL

***** 17.12.19 зачитать R01 во временные файлы
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
 {"tip",        "N",  1,0},;
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

** 26.12.22 прочитать и "разнести" по базам данных файл R02
Function read_XML_FILE_R02(arr_XML_info,aerr,/*@*/current_i2,tip_f)
Local count_in_schet := 0, bSaveHandler, ii1, ii2, i, j, k, t_arr[2], ldate_R02, s, err_file := .f.
DEFAULT tip_f TO _XML_FILE_R02
mkod_reestr := arr_XML_info[7]
use (cur_dir+"tmp1file") new alias TMP1
ldate_R02 := tmp1->_DATE_F
R_Use(dir_server + "mo_dr01",,"REES")
goto (arr_XML_info[7])
strfile("Обрабатывается ответ ТФОМС на информационный пакет "+alltrim(rees->NAME_XML)+sxml+hb_eol()+;
        "за "+lstr(rees->NMONTH)+" мес. "+lstr(rees->NYEAR)+" года от "+date_8(rees->DSCHET)+;
        "г. ("+lstr(rees->kol)+" чел.)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
//
R_Use(dir_server + "mo_dr01k",,"RHUM")
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
  G_Use(dir_server + "mo_xml",,"MO_XML")
  AddRecN()
  mo_xml->KOD := recno()
  mo_xml->KOD := recno()
  mo_xml->FNAME := cReadFile
  mo_xml->DFILE := ldate_R02
  mo_xml->TFILE := ""
  mo_xml->DREAD := sys_date
  mo_xml->TREAD := hour_min(seconds())
  mo_xml->TIP_IN := tip_f // тип принимаемого файла
  mo_xml->DWORK  := sys_date
  mo_xml->TWORK1 := cTimeBegin
  mo_xml->REESTR := mkod_reestr
  mo_xml->KOL1 := ii1
  mo_xml->KOL2 := ii2
  //
  mXML_REESTR := mo_xml->KOD
  use
  G_Use(dir_server + "mo_dr01",,"REES")
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
    G_Use(dir_server + "mo_dr01e",,"REFR")
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
        // if (j := ascan(getT012(), {|x| x[2] == tmp3->_ERROR })) > 0
        //   strfile(space(8) + "ошибка " + lstr(tmp3->_ERROR) + " - " + getT012()[j,1] + hb_eol(), cFileProtokol, .t.)
        // else
        //   strfile(space(8)+"ошибка "+lstr(tmp3->_ERROR)+" (неизвестная ошибка)"+hb_eol(),cFileProtokol,.t.)
        // endif
        strfile(space(8) + getError_T012(tmp3->_ERROR) + hb_eol(), cFileProtokol, .t.)
        select TMP3
        skip
      enddo
    endif
    tmp3->(dbCloseArea())
  endif
  G_Use(dir_server + "kartote2",,"KART2")
  G_Use(dir_server + "kartote_",,"KART_")
  G_Use(dir_server + "kartotek",,"KART")
  G_Use(dir_server + "mo_dr01k",,"RHUM")
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
        // if (j := ascan(getT012(), {|x| x[2] == tmp3->_ERROR })) > 0
        //   strfile(space(8) + "ошибка " + lstr(tmp3->_ERROR) + " - " + getT012()[j,1] + hb_eol(), cFileProtokol, .t.)
        // else
        //   strfile(space(8)+"ошибка "+lstr(tmp3->_ERROR)+" (неизвестная ошибка)"+hb_eol(),cFileProtokol,.t.)
        // endif
        strfile(space(8) + getError_T012(tmp3->_ERROR) + hb_eol(), cFileProtokol, .t.)
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

***** 09.02.20 аннулировать чтение недочитанного реестра R02
Function delete_reestr_R02(mkod_reestr,mname_reestr)
Local i, s, r := row(), r1, r2, buf := save_maxrow(), ;
      mm_menu := {}, mm_func := {}, mm_flag := {}, mreestr_sp_tk, ;
      arr_f, cFile, oXmlDoc, aerr := {}, is_allow_delete, ;
      cFileProtokol := "tmp"+stxt
mywait()
select MO_XML
index on FNAME to (cur_dir+"tmp_xml") ;
      for reestr == mkod_reestr .and. tip_in == ptip_f+1 .and. TIP_OUT == 0
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
  func_error(4,"Не было чтения файла P"+pname_f)
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
    if oXmlDoc == NIL .or. Empty( oXmlDoc:aItems )
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
        if !is_allow_delete .and. involved_password(2,cFile,"аннулирования чтения файла P"+pname_f)
          is_allow_delete := .t.
        endif
        if is_allow_delete
          close databases
          G_Use(dir_server + "mo_dr01",,"REES")
          goto (mkod_reestr)
          use (cur_dir+"tmp1file") new alias TMP1
          use (cur_dir+"tmp2file") new alias TMP2
          arr := {}
          aadd(arr,"Информационный пакет "+alltrim(rees->NAME_XML)+sxml+" от "+date_8(rees->DSCHET)+"г.")
          aadd(arr,"за "+lstr(rees->NMONTH)+" мес. "+lstr(rees->NYEAR)+;
                   " года, кол-во пациентов "+lstr(rees->kol)+" чел.")
          aadd(arr,"")
          G_Use(dir_server + "mo_xml",,"MO_XML")
          goto (mreestr_sp_tk)
          aadd(arr,"Аннулируется файл ответа "+cFile+" от "+date_8(mo_xml->DFILE)+"г.")
          aadd(arr,"После подтверждения аннулирования все последствия чтения данного")
          aadd(arr,"файла P"+pname_f+", а также сам файл P"+pname_f+", будут удалены.")
          f_message(arr,,cColorSt2Msg,cColorSt1Msg)
          s := "Подтвердите аннулирование файла P"+pname_f
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
          f2_delete_reestr_R02(mkod_reestr,mreestr_sp_tk)
          stat_msg("Файл "+cFile+" успешно аннулирован. Можно прочитать ещё раз.") ; mybell(5)
        endif
      endif
    endif
  endif
endif
rest_box(buf)
return 0

***** 09.02.20 аннулировать чтение реестра PR01(PR11)
Function f2_delete_reestr_R02(mkod_reestr,mreestr_sp_tk)
G_Use(dir_server + "mo_dr01e",,"REFR")
index on str(REESTR,6) to (cur_dir+"tmp_r01e")
do while .t.
  find (str(mkod_reestr,6)) // удалим ошибки
  if !found() ; exit ; endif
  DeleteRec(.t.)
enddo
G_Use(dir_server + "mo_dr01k",,"RHUM")
index on str(REESTR,6) to (cur_dir+"tmp_rhum")
find (str(mkod_reestr,6))
do while rhum->reestr == mkod_reestr .and. !eof()
  G_RLock(forever)
  rhum->OPLATA := 0 // обнулим поле оплаты
  UnLock
  skip
enddo
G_Use(dir_server + "mo_dr01",,"REES")
goto (mkod_reestr)
G_RLock(forever)
rees->answer := 0
rees->kol_err := 0
G_Use(dir_server + "mo_xml",,"MO_XML")
goto (mreestr_sp_tk)
DeleteRec()
close databases
return NIL

***** 28.12.21
Function need_delete_reestr_R01()
  Local fl := .f.

  if hb_user_curUser:IsAdmin()
    R_Use(dir_server + "mo_dr01m",,"R01m")
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

***** 28.12.21
Function delete_reestr_R01()
Local t_arr[BR_LEN], blk

if ! hb_user_curUser:IsAdmin()
  return func_error(4,err_admin)
endif
G_Use(dir_server + "mo_dr01m",,"R01m")
index on descend(dtos(DWORK)+TWORK1) to (cur_dir+"tmp_dr01m")
go top
if eof()
  func_error(4,"Не было создано файлов R01...")
else
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow()-2
  t_arr[BR_LEFT] := 2
  t_arr[BR_RIGHT] := 77
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := "Список созданных пакетов реестров R01"
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
  blk := {|| iif(empty(r01m->twork2),{3,4},{1,2}) }
  t_arr[BR_COLUMN] := {;
   { "  Дата;создания",{|| date_8(r01m->dwork) }, blk },;
   { "янв;арь", {|| iif(r01m->reestr01 > 0,"да ","нет") }, blk },;
   { "фев;рал", {|| iif(r01m->reestr02 > 0,"да ","нет") }, blk },;
   { "мар;т  ", {|| iif(r01m->reestr03 > 0,"да ","нет") }, blk },;
   { "апр;ель", {|| iif(r01m->reestr04 > 0,"да ","нет") }, blk },;
   { "май;   ", {|| iif(r01m->reestr05 > 0,"да ","нет") }, blk },;
   { "июн;ь  ", {|| iif(r01m->reestr06 > 0,"да ","нет") }, blk },;
   { "июл;ь  ", {|| iif(r01m->reestr07 > 0,"да ","нет") }, blk },;
   { "авг;уст", {|| iif(r01m->reestr08 > 0,"да ","нет") }, blk },;
   { "сен;тяб", {|| iif(r01m->reestr09 > 0,"да ","нет") }, blk },;
   { "окт;ябр", {|| iif(r01m->reestr10 > 0,"да ","нет") }, blk },;
   { "ноя;брь", {|| iif(r01m->reestr11 > 0,"да ","нет") }, blk },;
   { "дек;абр", {|| iif(r01m->reestr12 > 0,"да ","нет") }, blk },;
   { "Время;начала",    {|| r01m->twork1 }, blk },;
   { "Время;окончания", {|| padr(iif(empty(r01m->twork2),"НЕ ЗАВЕРШЕНО",r01m->twork2),10) }, blk };
  }
  t_arr[BR_EDIT] := {|nk,ob| f1_delete_reestr_R01(nk,ob,"edit") }
  t_arr[BR_FL_INDEX] := .f.
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - аннулирование создания пакета реестров R01") }
  edit_browse(t_arr)
endif
close databases
return NIL

***** 17.12.19
Function f1_delete_reestr_R01(nKey,oBrow,regim)
Local ret := -1, rec := r01m->(recno()), ir, fl := .t.
if regim == "edit" .and. nKey == K_ENTER
  if empty(r01m->twork2)
    G_Use(dir_server + "mo_dr01",,"REES")
    for ir := 1 to 12
      mkod_reestr := &("r01m->reestr"+strzero(ir,2))
      if mkod_reestr > 0
        select REES
        goto (mkod_reestr)
        if rees->tip == 1
          fl := func_error(4,"Это файл R11. Операция запрещена!")
          exit
        elseif rees->ANSWER == 1
          fl := func_error(4,"Уже получен ответ PR01 за "+lstr(ir)+"-й месяц. Операция запрещена!")
          exit
        endif
      endif
    next
    REES->(dbCloseArea())
    select R01m
    if fl .and. f_Esc_Enter("аннулирования R01")
      mywait()
      G_Use(dir_server + "mo_xml",,"MO_XML")
      G_Use(dir_server + "mo_dr00",,"TMP")
      index on str(REESTR,6) to (cur_dir+"tmp_dr00")
      G_Use(dir_server + "mo_dr01k",,"RHUM")
      index on str(REESTR,6) to (cur_dir+"tmp_rhum")
      G_Use(dir_server + "mo_dr01",,"REES")
      for ir := 12 to 1 step -1
        mkod_reestr := &("r01m->reestr"+strzero(ir,2))
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
          &("r01m->reestr"+strzero(ir,2)) := 0
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

***** 21.12.21 проверить, есть ли не до конца обработанные операции с файлами R01...
Function find_unfinished_R01()

Local fl := .t., fl1, skol := 0, mkol := 0, arr := {}, rec, fl_date := .t., vrem := 0
Private sgod := 2022, mrec := 1
if glob_mo[_MO_IS_UCH]
  if (fl := verify_packet_R05(2,arr))
    R_Use(dir_server + "mo_dr05p",,"R05p")
    goto (mrec)
    //skol := r05p->KOL1 + r05p->KOL2
    for i := 4 to 12
      vrem := 0
      for j := 1 to 2
        vrem += &("r05p->kol"+lstr(j)+"_"+strzero(i,2))
      next
      skol += vrem
    next
    select MO_XML
    index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in == _XML_FILE_R02 .and. empty(TIP_OUT)
    R_Use(dir_server + "mo_dr01",,"REES")
    index on str(nn,3)+str(NMONTH,2) to (cur_dir+"tmp_dr01") for NYEAR == sgod .and. tip == 0
    go top
    do while fl .and. !eof()
      if rees->kol_err < 0
        fl := .f.
        aadd(arr,"В файле PR01 за "+lstr(rees->NMONTH)+"-й месяц "+lstr(sgod)+"г. ошибки на уровне файла")
      elseif empty(rees->answer)
        fl := .f.
        aadd(arr,"Файл PR01 за "+lstr(rees->NMONTH)+"-й месяц "+lstr(sgod)+" года не был прочитан")
      else
        if rees->NMONTH > 3
          mkol += (rees->KOL - rees->KOL_ERR)
          select MO_XML
          find (str(rees->kod,6))
          if found() .and. empty(mo_xml->TWORK2)
            fl := .f.
            aadd(arr,"Прервано чтение файла "+alltrim(mo_xml->FNAME)+"! Аннулируйте (Ctrl+F12) и прочитайте снова")
          endif
        endif
      endif
      select REES
      skip
    enddo
    if fl .and. skol != mkol
      fl := .f.
      aadd(arr,"Количество, определённое в план-графике 1-12 месяц = "+lstr(skol))
      aadd(arr,"Количество, отправленное в ТФОМС        1-12 месяц = "+lstr(mkol))
    endif
  endif
  close databases
  if !fl .and. !empty(arr)
    Ins_Array(arr,1,"")
    Ins_Array(arr,1,"-------------------------------------------------------")
    Ins_Array(arr,1,"Операции создания (обмена) файлов R01(PR01) и R05(PR05)")
    n_message(arr,,"GR+/R","W+/R",,,"G+/R")
  endif
endif
return NIL

** 29.12.22 проверить, есть ли не до конца обработанные операции с файлами R11...
Function find_unfinished_R11()
Local fl := .t., fl1, skol := 0, mkol := 0, arr := {}, rec, fl_date := .t.

  Private mrec := 2, smonth := 3
  // Private sgod := 2021
  Private sgod := 2022

  if glob_mo[_MO_IS_UCH]
    if (fl := verify_packet_R05(2,arr))
      R_Use(dir_server + "mo_dr05p",,"R05p")
      goto (mrec)
      skol := &("r05p->kol1_"+strzero(smonth,2)) + &("r05p->kol2_"+strzero(smonth,2))
      select MO_XML
      index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in == _XML_FILE_R12 .and. empty(TIP_OUT)
      R_Use(dir_server + "mo_dr01",,"REES")
      index on str(nn,3) to (cur_dir+"tmp_dr01") for NYEAR == sgod .and. NMONTH == smonth .and. tip == 1
      go top
      do while fl .and. !eof()
        if rees->kol_err < 0
          fl := .f.
          aadd(arr,"В файле PR11 за "+lstr(rees->NMONTH)+"-й месяц "+lstr(sgod)+"г. ошибки на уровне файла")
        elseif empty(rees->answer)
          fl := .f.
          aadd(arr,"Файл PR11 за "+lstr(rees->NMONTH)+"-й месяц "+lstr(sgod)+" года не был прочитан")
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
      if fl .and. skol != mkol
        fl := .f.
        aadd(arr,"Количество, определённое в план-графике = "+lstr(skol))
        aadd(arr,"Количество, отправленное в ТФОМС        = "+lstr(mkol))
      endif
    endif
    close databases
    if !fl .and. !empty(arr)
      Ins_Array(arr,1,"")
      Ins_Array(arr,1,"-------------------------------------------")
      Ins_Array(arr,1,"Операции создания (обмена) файлов R11(PR11)")
      n_message(arr,,"GR+/R","W+/R",,,"G+/R")
    endif
  endif
  return NIL