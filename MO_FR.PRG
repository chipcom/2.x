***** mo_fr.prg - работа с фискальным регистратором
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"
#include "f_fr.ch"

#require "hbwin"

static emailTemplate := "^[-._a-z0-9]+@(?:[a-z0-9][-a-z0-9]+\.)+[a-z]{2,6}$"
static phoneTemplate := "^(\s*)?(\+)?([- _():=+]?\d[- _():=+]?){10,14}(\s*)?$"


*****
Function fr_nastrojka(k)
Static si1 := 1, si2 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~Настройка работы с КАССОЙ",;
                "Снятие суточного ~отчета с гашением",;
                "Снятие суточного отчета ~без гашения",;
                "Снятие суточного отчета по ~СЕКЦИЯМ",;
                "Снятие суточного отчета по ~НАЛОГАМ",;
                "Продолжение ~печати",;
                "~Аннулирование непробитого чека",;
                "Установка ~даты в ФР",;
                "Синхронизация ~времени",;
                "~Запись КАССИРОВ в ФР"}
    mas_msg := {"Настройка работы с кассой (номер порта, сдача, протокол и т.п.)",;
                "Снятие суточного отчета c гашением",;
                "Снятие суточного отчета без гашения",;
                "Снятие суточного отчета по СЕКЦИЯМ",;
                "Снятие суточного отчета по НАЛОГАМ",;
                "Продолжение печати при обрыве ленты",;
                "Аннулирование чека при ошибке печати",;
                "Установка даты в фискальном регистраторе",;
                "Синхронизация времени между ФР и персональным компьютером",;
                "Копирование КАССИРОВ из Пользователей программы в ФР"}
    mas_fun := {"fr_nastrojka(11)",;
                "fr_nastrojka(12)",;
                "fr_nastrojka(13)",;
                "fr_nastrojka(18)",;
                "fr_nastrojka(19)",;
                "fr_nastrojka(14)",;
                "fr_nastrojka(15)",;
                "fr_nastrojka(16)",;
                "fr_nastrojka(17)",;
                "fr_nastrojka(20)"}
    if tip_polzovat != 0
      asize(mas_pmt,7)
      asize(mas_msg,7)
      asize(mas_fun,7)
    endif
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    f5_sist_fr(2)  // настройка
  case k == 12
    f3_sist_fr(1)  // отчет с гашением
  case k == 13
    f3_sist_fr(0)  // отчет без гашения
  case k == 14
    f6_sist_fr()   // продолжение печати чека
  case k == 15
    f7_sist_fr()   // аннулирование непробитого чека
  case k == 16
    f1_sist_fr()
  case k == 17
    f2_sist_fr()
  case k == 18
    f8_sist_fr()
  case k == 19
    f9_sist_fr()
  case k == 20
    f10_sist_fr()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,20)
    si1 := j
  endif
endif
return NIL

*

***** 12.08.18
Function f5_sist_fr(k)
Static mm_da_net := {{"да ",1},{"нет",2}}
Static mm_chek := {{"Сквозной номер документа ККМ",1},{"Номер чека продажи ККМ",2}}
Static n_zapusk := 0
Local mm_tmp := {}, buf, fl := .f., s

if k == 1
  Public meK_ostato := 0,;
         meK_bank   := 2,;
         meK_lof_fi := 2,;
         meK_otrez  := 1,;  // отрезка чека
         meK_kassa  := 1,;  // рабочее место кассира
         meK_pr_FIO := 1,;
         MEK_KASSIR := space(20),;
         mek_chek   := 1,;
         mek_bnbank := 2
         //meK_sdacha := 1,;
         //meK_w_sdac := 1,;

  if file("_kassa_.mem")
    restore from _kassa_ additive
  else
    save all like meK_* to _kassa_
  endif
  ***************
// контроль
  if n_zapusk == 0
    ++n_zapusk
    if iif(glob_task == X_KASSA,.T.,glob_kassa == 1) .and. mek_kassa == 1
      Private drvFR
      IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
        FR_ZAMENA_otrezka(2)
        fiskal_inf_fr()
      endif
    endif
  endif
//
elseif k == 2
  ***************
  buf := box_shadow(1,0,22,78,"B+/B")

  // Настройки убраны
  //mek_nkassa := 1 //Работаем ТОЛЬКО через драйвер
  meK_lof_fi := 2 // для СОМ
  //mek_tkassa := 2 // ККМ по 54-ФЗ

  Private mostatok := meK_ostato,;
          mmeK_bank, m1meK_bank := meK_bank,;
          mmeK_kassa, m1meK_kassa := meK_kassa,;
          mmek_pr_fio, m1mek_pr_fio := mek_pr_fio,;
          mnkassa := space(10), m1nkassa := 0,;
          mkassir := mek_kassir,;
          mmek_chek := m1mek_chek := mek_chek,;
          mmeK_bnbank, m1meK_bnbank := meK_bnbank
         // mmeK_otrez, m1meK_otrez := meK_otrez,;
         //mmeK_lof_fi, m1meK_lof_fi := meK_lof_fi,;


  mmeK_bank   := inieditspr(A__MENUVERT,mm_da_net,m1meK_bank)
  mmeK_bnbank   := inieditspr(A__MENUVERT,mm_da_net,m1meK_bnbank)
  mmeK_kassa  := inieditspr(A__MENUVERT,mm_da_net,m1meK_kassa)
  //mmeK_otrez  := inieditspr(A__MENUVERT,mm_da_net,m1meK_otrez)
  mmek_pr_fio := inieditspr(A__MENUVERT,mm_da_net,m1mek_pr_fio)
  mmek_chek   := inieditspr(A__MENUVERT,mm_chek,m1mek_chek)

    setcolor(cDataCGet)
    ix := 3
    ClrLines(1,maxrow()-1)
    if tip_polzovat == 0
      @ ++ix,3 say "Номером документа считать " get mmek_chek ;
                reader {|x|menu_reader(x,mm_chek,A__MENUVERT,,,.f.)}
      @ ++ix,3 say "Вызов драйвера ..." get mnkassa ;
                reader {|x|menu_reader(x,{{||FR_draiver()}},A__FUNCTION,,,.f.)}
    endif
    @ ++ix,3 say "Сумма денег, внесенная в кассу УТРОМ" get mostatok  pict "999999.99"
//      ++ix
//    @ ++ix,3 say "Запрашивать вносимую покупателем сумму и подсчитывать сдачу?" get msdacha ;
//                reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
//    @ ++ix,3 say "Печатать вносимую покупателем сумму и сдачу в чек?" get mw_sdacha ;
//                reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
    if tip_polzovat == 0
      ++ix
      @ ++ix,3 say "Учреждение принимает оплату банковскими переводами ?" get mmeK_bnbank ;
                  reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
//      ++ix
      @ ++ix,3 say "Работать с банковскими картами ?" get mmeK_bank ;
                  reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
//      ++ix
      @ ++ix,3 say "Это рабочее место кассира ?" get mmeK_kassa ;
                  reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
//      @ ++ix,3 say "Проводить программную отрезку чека?" get mmeK_otrez ;
//                  reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
      @ ++ix,3 say "Печатать ФИО пациента/плательщика в чеке?" get mmek_pr_fio ;
                  reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
      @ ++ix,3 say "ФИО кассира" get mkassir
    endif
    status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода")
  myread()
  if lastkey() == K_ESC
    rest_box(buf)
    return NIL
  endif
  if f_Esc_Enter(1)
    meK_ostato := mostatok
    mek_kassir := mkassir
    if tip_polzovat == 0
      mek_bank   := m1mek_bank
      mek_bnbank := m1mek_bnbank
      mek_kassa  := m1mek_kassa
//      meK_otrez  := m1meK_otrez
      mek_pr_fio := m1mek_pr_fio
      mek_chek   := m1mek_chek
    endif
    save all like meK_* to _kassa_
  endif
  rest_box(buf)
endif
//FR_LOG_FLAG := (meK_lof_fi == 1)   // !!!!!!!!!!!!
return NIL


*

***** 02.07.18
function f1_sist_fr()
// Изменение даты в ККМ
Local fl := .t.,  parol := 0, t, tt, tt1, s_err

Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  FR_ZAMENA_otrezka()
else
  return func_error(4,"Ошибка запуска драйвера КАССЫ")
endif
//
if !ret_dataedit()
  return NIL
endif
tt := FR_ret_dan()
if empty(tt)
  return func_error(4,'НЕ СЧИТАНА ДАТА ИЗ КАССЫ')
endif
tt1 := tt[FR_R_DATE]
Private mdate := tt1
keyboard ""
setcolor(cDataCGet)
buf := box_shadow(19,9,21,70,"B+/B")
@ 20,13 say " В ФР сегодня "+dtoc(tt1)+" введите новую дату" get mdate
status_key("^<Esc>^ - выход из задачи;  ^<Enter>^ - подтверждение ввода")
myread({"confirm"})
rest_box(buf)
if lastkey() == K_ESC .or. mdate == tt1
  return NIL
endif
if (fl := empty(s_err := FR_set_date(mdate)))
  stat_msg("Команда Выполнена!")
  n_message({"","Дата в ФР изменена !"},,;
            color1,cDataCSay,,,color8)
  FR_gudok()
else
  write_err_kassa(s_err,'НЕ ПРОИЗОШЛО ИЗМЕНЕНИЯ ДАТЫ')
endif
return NIL

*****
Static function ret_dataedit()
Local buf, r1 := 12, r2 := 20, i, tmp_color := setcolor(color1)
buf := box_shadow(r1,5,r2,74,,"Установка даты в кассовом аппарате","W/B")
setcolor(color8)
str_center(r1+2,"Предупреждение!")
str_center(r1+3,"Этот режим предназначен для изменения даты в кассовом аппарате.")
str_center(r1+4,'Он выполняется только на обнуленной кассе.')
setcolor(color1)
str_center(r2-2,"Выберите действие:")
setmtcolor("BG+/B,W+/R,GR+/B,GR+/R")
@ r2-1,14 prompt " ~Отказ от операции "
@ r2-1,35 prompt " ~Подтверждение изменения даты "
menu to i
setcolor(tmp_color)
rest_box(buf)
return (i == 2)

*

*****  Синхронизация времени
function f2_sist_fr()
Local fl := .t., t, tt, tt1, x, cur_time,;
      r1 := 11, r2 := 20, i, tmp_color := setcolor(color1), buf

Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  FR_Read_otrezka()
else
  return func_error(4,"Ошибка запуска драйвера КАССЫ")
endif
//
tt := FR_ret_dan()
if empty(tt)
  return func_error(4,'НЕ СЧИТАНО ВРЕМЯ ИЗ ФР')
endif
tt1 := tt[FR_R_TIME] ; cur_time := time()
buf := box_shadow(r1,5,r2,74)
setcolor(color8)
str_center(r1+2,"Предупреждение!")
str_center(r1+3,"Этот режим предназначен для синхронизации времени")
str_center(r1+4,"между персональным компьютером и фискальным регистратором.")
str_center(r1+5,"Время в ФР "+tt1+"   Время в компьютере "+cur_time)
mark_keys({tt1,cur_time},"G+/B")
setcolor(color1)
str_center(r2-2,"Выберите действие:")
setmtcolor("BG+/B,W+/R,GR+/B,GR+/R")
@ r2-1,10 prompt " ~Отказ от операции "
@ r2-1,35 prompt " ~Компьютер->ФР "
@ r2-1,55 prompt " ~ФР->Компьютер "
menu to i
setcolor(tmp_color)
rest_box(buf)
if i == 2
  t := time()
  x := val(substr(t,7,2))+30
  if x > 59
    t := substr(t,1,6)+"59"
  else
    t := substr(t,1,6)+strzero(x,2)
  endif
  mywait()
  if empty(FR_set_time(t))
    FR_gudok()
    stat_msg("Команда Выполнена!")
    n_message({"","Установка Времени в ФР произведена"},,;
              color1,cDataCSay,,,color8)
  else
    func_error(4,'НЕ ПРОИЗОШЛО УСТАНОВКИ ВРЕМЕНИ')
  endif
elseif i == 3
  tt := FR_ret_dan()
  if empty(tt)
    func_error(4,'НЕ СЧИТАНО ВРЕМЯ ИЗ ФР')
  else
    settime(tt[FR_R_TIME],.T.)
    stat_msg("Команда Выполнена!")
    n_message({"","Установка Времени в КОМПЬЮТЕРЕ произведена"},,;
                color1,cDataCSay,,,color8)
  endif
endif
rest_box(buf)
return NIL

*

*****
function f3_sist_fr(tip)
// 0 - Снятие суточного отчета без гашения
// 1 - с гашением
Local fl := .t., s_err, parol, t, tt, tt1, buf

buf := save_row(maxrow())


Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  FR_ZAMENA_otrezka()
else
  return func_error(4,"Ошибка запуска драйвера КАССЫ")
endif
//
if !ret_fsytotch(tip)
  return NIL
endif
if (fl := empty(s_err := FR_normgach(tip)))
  rest_box(buf)
  mywait()
  stat_msg("Команда выполнена!")
  if tip == 1
    n_message({"","Гашение суточного отчета выполнено!"},,;
              color1,cDataCSay,,,color8)
  endif
  FR_otrezka(1,3)
  rest_box(buf)
else
  rest_box(buf)
  if tip == 1
    write_err_kassa(s_err,'НЕ ПРОИЗОШЛО ГАШЕНИЯ СУТОЧНОГО ОТЧЕТА')
  else
    write_err_kassa(s_err,'НЕ ПРОИЗОШЛО СНЯТИЯ СУТОЧНОГО ОТЧЕТА')
  endif
endif
rest_box(buf)
return NIL

*****
function ret_fsytotch(tip)
Local buf, r1 := 12, r2 := 20, i, tmp_color := setcolor(color1)
buf := box_shadow(r1,5,r2,74,,"Снятие суточного отчета","W/B")
setcolor(color8)
str_center(r1+2,"Предупреждение!")
str_center(r1+3,"Этот режим предназначен для снятия суточного отчета")
if tip == 0
  str_center(r1+4,"без гашения.")
else
  str_center(r1+4,"с гашением.")
endif
setcolor(color1)
str_center(r2-2,"Выберите действие:")
setmtcolor("BG+/B,W+/R,GR+/B,GR+/R")
@ r2-1,14 prompt " ~Отказ от операции "
@ r2-1,35 prompt " ~Подтверждение суточного отчета "
menu to i
setcolor(tmp_color)
rest_box(buf)
return (i == 2)

*

*****
function f6_sist_fr()
//  продолжение печати
Local fl := .t., s_err, parol, t, tt, tt1, buf
buf := save_row(maxrow())

Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  FR_ZAMENA_otrezka()
else
  return func_error(4,"Ошибка запуска драйвера КАССЫ")
endif
//
if (fl := empty(s_err := FR_prodol()))
  rest_box(buf)
  mywait()
  stat_msg("Команда выполнена!")
  FR_otrezka(1,2)
  rest_box(buf)
else
  rest_box(buf)
  write_err_kassa(s_err,'НЕ ПРОИЗОШЛО ПРОДОЛЖЕНИЯ ПЕЧАТИ')
endif
rest_box(buf)
return NIL

*

*****
function f7_sist_fr()
//  аннулирование чека
Local fl := .t., s_err, parol, t, tt, tt1, buf
buf := save_row(maxrow())

Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  FR_ZAMENA_otrezka()
else
  return func_error(4,"Ошибка запуска драйвера КАССЫ")
endif
//
if (fl := empty(s_err := FRCH_annul()))
  rest_box(buf)
  mywait()
  stat_msg("Команда выполнена!")
  FR_otrezka(1,2)
  rest_box(buf)
else
  rest_box(buf)
  write_err_kassa(s_err,'НЕ ПРОИЗОШЛО АННУЛИРОВАНИЯ ЧЕКА')
endif
rest_box(buf)
return NIL


*

***** 03.09.17
function f8_sist_fr()
//  Снятие суточного отчета по СЕКЦИЯМ
Local fl := .t.,  s_err, parol, t, tt, tt1, buf

buf := save_row(maxrow())


if glob_kassa == 1 .and. mek_kassa == 1
  Private drvFR
  IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    FR_ZAMENA_otrezka()
  else
    return func_error(4,"Ошибка запуска драйвера КАССЫ")
  endif
endif
//
if !ret_PrintReport(1)
  return NIL
endif
//
if (fl := empty(s_err := FRN_PrintDepartmentReport()))
  rest_box(buf)
  mywait()
  stat_msg("Команда выполнена!")
  FR_otrezka(1,3)
  rest_box(buf)
else
  rest_box(buf)
  write_err_kassa(s_err,'НЕ ПРОИЗОШЛО ПЕЧАТИ ОТЧЕТА ПО НАЛОГАМ')
endif
rest_box(buf)
return NIL


*

***** 03.09.17
function f9_sist_fr()
//  Снятие суточного отчета по НАЛОГАМ
Local fl := .t., s_err, parol, t, tt, tt1, buf

buf := save_row(maxrow())


if glob_kassa == 1 .and. mek_kassa == 1
  Private drvFR
  IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    FR_ZAMENA_otrezka()
  else
    return func_error(4,"Ошибка запуска драйвера КАССЫ")
  endif
endif
//
if !ret_PrintReport(0)
  return NIL
endif
//
if (fl := empty(s_err := FRN_PrintTaxReport()))
  rest_box(buf)
  mywait()
  stat_msg("Команда выполнена!")
  FR_otrezka(1,3)
  rest_box(buf)
else
  rest_box(buf)
  write_err_kassa(s_err,'НЕ ПРОИЗОШЛО ПЕЧАТИ ОТЧЕТА ПО НАЛОГАМ')
endif
rest_box(buf)
return NIL


*

*****
function ret_PrintReport(tip)
Local buf, r1 := 12, r2 := 20, i, tmp_color := setcolor(color1)
buf := box_shadow(r1,5,r2,74,,"Снятие суточного отчета","W/B")
setcolor(color8)
str_center(r1+2,"Предупреждение!")
str_center(r1+3,"Этот режим предназначен для снятия суточного отчета")
if tip == 0
  str_center(r1+4,"ПО НАЛОГАМ.")
else
  str_center(r1+4,"ПО СЕКЦИЯМ.")
endif
setcolor(color1)
str_center(r2-2,"Выберите действие:")
setmtcolor("BG+/B,W+/R,GR+/B,GR+/R")
@ r2-1,14 prompt " ~Отказ от операции "
@ r2-1,35 prompt " ~Подтверждение суточного отчета "
menu to i
setcolor(tmp_color)
rest_box(buf)
return (i == 2)


*

***** 03.09.17
function f10_sist_fr()
//  Кассиры в ФР
Local fl := .t.,  s_err, parol, t, tt, tt1, buf

buf := save_row(maxrow())


Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  FR_ZAMENA_otrezka()
else
  return func_error(4,"Ошибка запуска драйвера КАССЫ")
endif
//
if !ret_WriteKassir()
  return NIL
endif
//
FRN_WritePassword()
rest_box(buf)
return NIL

*

*****
function ret_WriteKassir()
Local buf, r1 := 12, r2 := 20, i, tmp_color := setcolor(color1)
buf := box_shadow(r1,5,r2,74,,"Копирование ФИО Кассиров из Программы в ФР","W/B")
setcolor(color8)
str_center(r1+2,"Предупреждение!")
str_center(r1+3,"Этот режим предназначен для")
str_center(r1+4,"Копирования ФИО Кассиров из программы в ФР")
setcolor(color1)
str_center(r2-2,"Выберите действие:")
setmtcolor("BG+/B,W+/R,GR+/B,GR+/R")
@ r2-1,14 prompt " ~Отказ от операции "
@ r2-1,38 prompt " ~Подтверждение копирования "
menu to i
setcolor(tmp_color)
rest_box(buf)
return (i == 2)

*

*****
Static Function write_err_kassa(s1,s2)
Local _tmp, i, t_arr[2], ar := {""}

if !(valtype(s1) == "C")
  s1 := valtype(s1)+" - ОШИБКА"
endif
for i := 1 to perenos(t_arr,s1,70)
  aadd(ar, alltrim(t_arr[i]))
next
aadd(ar, s2)
//
_tmp := dtoc(date())+"  "+sectotime(seconds())+"  "+StripPath(exename())+eos
for i := 1 to len(ar)
  if !empty(ar[i])
    _tmp += ar[i]+eos
  endif
next
_tmp += replicate("*",79)+eos
strfile(_tmp,dir_server+"error.txt",.t.)
//
n_message(ar,,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
return NIL

*

*****
Static Function f_err_annul(s1)
Local _tmp, i, t_arr[2], ar := {}, ar2 := {""}
//
for i := 1 to perenos(t_arr,s1,70)
  aadd(ar, alltrim(t_arr[i]))
next
//
_tmp := dtoc(date())+"  "+sectotime(seconds())+"  "+StripPath(exename())+eos
for i := 1 to len(ar)
  if !empty(ar[i])
    _tmp += ar[i]+eos
  endif
next
_tmp += upper("Программе не удалось провести аннулирование чека!")+eos
_tmp += replicate("*",79)+eos
strfile(_tmp,dir_server+"error.txt",.t.)
//
aadd(ar2, "При печати чека возникла ошибка!")
aadd(ar2, "Программе не удалось провести аннулирование чека!")
aadd(ar2, "Проведите аннулирование вручную")
n_message(ar2,,"GR+/R","GR+/R",,,"BG+/R")
return NIL

*

***** 03.06.19
Function yes_chek(/*@*/vsum,/*@*/vsd,/*@*/vbank,rm,/*@*/address,/*@*/tip_kart)
Static spict := "9999999.99"
Local tip_bank_kart := {{"МИР",1},;
                        {"VISA",2},;
                        {"MasterCard",3},;
                        {"БАНКОВСКИЙ ПЕРЕВОД",4}}
Local j, fl := .f., tmp_color, buf, buf24, a[3], r := 16
//
if  mek_bnbank == 2
  asize(tip_bank_kart,3)
endif
if p_summa >= 0 //касса по 54-ФЗ
  tmp_color := setcolor(cDataCGet)
  Private vnos_summa := 0, bank_summa := 0,;
          mbank_kart, m1bank_kart := tip_kart,;
          maddress := padr(address,30)
  mbank_kart := inieditspr(A__MENUVERT,tip_bank_kart,m1bank_kart)
  r := 14
  do while .t.
    buf := box_shadow(r,5,r+5,74)
    buf24 := save_maxrow()
    @ r+1,7 say "Телефон или Электр.почта" get maddress pict "@S30" ;
            valid { | g | ControlAddress( g, maddress ) }
    @ r+2,7 say "Введите вносимую покупателем сумму (для подсчета сдачи)" ;
            get vnos_summa picture spict valid {|g| val_y_chek(g,1) }
    @ r+3,7 say "Сумма, вносимая безналичными (по банковской карте)     " ;
            get bank_summa picture spict valid {|g| val_y_chek(g,2) } ;
            when round_5(vnos_summa,2) < p_summa
    @ r+4,7 say "Тип банковской карты" get mbank_kart ;
            reader {|x|menu_reader(x,tip_bank_kart,A__MENUVERT,,,.f.)};
            when bank_summa > 0
    status_key("^<Esc>^ - выход без записи чека;  ^<PgDn>^ - запись чека")
    myread()
    j := f_alert({padc("Выберите действие",60,".")},;
                 {" Выход без записи "," Печать чека "," Возврат в редактирование "},;
                 iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
    if j < 2
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
    if vnos_summa >= p_summa
      a[1] := vnos_summa
      a[2] := p_summa
      a[3] := round_5(vnos_summa - p_summa, 2)
      f_message({"Вносимая сумма: "+str(a[1],10,2),;
                 "Сумма чека    : "+str(a[2],10,2),;
                 "──────────────────────────",;
                 "Сумма сдачи   : "+str(a[3],10,2)},,;
                cHelpCMain,cHelpCMain,rm)
      fl_sdacha := .t.
      vsum := a[1] ; vsd := a[3] ; vbank := 0
    else
      f_message({"Сумма наличными: "+str(vnos_summa,10,2),;
                 "Сумма по карте : "+str(bank_summa,10,2),;
                 "Сумма чека     : "+str(p_summa,   10,2)},,;
                cHelpCMain,cHelpCMain,rm)
      fl_sdacha := .f.
      vsum := vnos_summa ; vsd := 0 ; vbank := bank_summa
    endif
     address  := maddress
     tip_kart := m1bank_kart
    fl := .t.
    exit
  enddo
  setcolor(tmp_color)
elseif p_summa < 0 //касса по 54-ФЗ
  Private vnos_summa := 0, bank_summa := 0,;
          maddress := padr(address,30),;
          mbank_kart, m1bank_kart := tip_kart
  mbank_kart := inieditspr(A__MENUVERT,tip_bank_kart,m1bank_kart)
  tmp_color := setcolor(cHelpCMain)
  buf := box_shadow(r,5,r+5,74)
  buf24 := save_row(maxrow())
  @ r+1,7 say "Телефон или Электронная почта      " get maddress pict "@S30" ;
          valid { | g | ControlAddress( g, maddress ) }
  @ r+2,7 say "Введите сумму возврата                                 " ;
               get vnos_summa picture spict valid {|g| val_u_chek(g,1) }
  @ r+3,7 say "Сумма, возврата безналичными (по банковской карте)     " ;
               get bank_summa picture spict valid {|g| val_u_chek(g,2) } ;
               when round_5(vnos_summa,2) < (p_summa*(-1))
  @ r+4,7 say "Тип банковской карты" get mbank_kart ;
               reader {|x|menu_reader(x,tip_bank_kart,A__MENUVERT,,,.f.)};
               when bank_summa > 0
  status_key("^<Esc>^ - выход без записи чека;  ^<Enter>^ - запись чека")
  myread()
  rest_box(buf)
  rest_box(buf24)
  setcolor(tmp_color)
  if lastkey() != K_ESC
    if vnos_summa > 0 .or. bank_summa > 0
      a[1] := p_summa *(-1)
      a[2] := vnos_summa
      a[3] := bank_summa
      f_message({"Cумма ВОЗВРАТА  : "+str(a[1],10,2),;
                 "Сумма наличными : "+str(a[2],10,2),;
                 "Сумма по банку  : "+str(a[3],10,2)},,;
                cHelpCMain,cHelpCMain,rm)
      fl_sdacha := .t.
      vsum := vnos_summa ; vbank := bank_summa ; vsd := 0
    endif
    // /*@*/vsum,/*@*/vsd,/*@*/vbank,rm,/*@*/address,/*@*/tip_kart
    // vsum := vnos_summa ; vsd := 0 ; vbank := bank_summa
    address  := maddress
    tip_kart := m1bank_kart
    fl := .t.
  endif
else
  fl := f_Esc_Enter("печати ЧЕКА")
endif
return fl

*

***** 11.05.14
Function val_y_chek(get,n)
if n == 1  // сумма наличными
  vnos_summa := round_5(vnos_summa,2)
  if vnos_summa < p_summa
    bank_summa := round_5(p_summa - vnos_summa, 2)
  else
    bank_summa := 0
  endif
else       // сумма безналичными
  bank_summa := round_5(bank_summa,2)
  if bank_summa > p_summa
    func_error(4,"Сумма, вносимая безналичными, не может быть больше суммы покупки!")
    bank_summa := p_summa
  elseif bank_summa > 0
    vnos_summa := round_5(p_summa - bank_summa, 2)
  else
    bank_summa := 0
    if round_5(vnos_summa,2) < p_summa
      vnos_summa := p_summa
    endif
  endif
endif
return update_gets()

*

***** 02.05.18
Function val_u_chek(get,n)
if n == 1  // сумма наличными
  vnos_summa := round_5(vnos_summa,2)
  if vnos_summa < (p_summa*(-1))
    bank_summa := round_5((p_summa*(-1)) - vnos_summa, 2)
  else
    bank_summa := 0
  endif
else       // сумма безналичными
  bank_summa := round_5(bank_summa,2)
  if bank_summa > (p_summa*(-1))
    func_error(4,"Сумма, возврата безналичными, не может быть больше суммы чека!")
    bank_summa := (p_summa*(-1))
  elseif bank_summa > 0
    vnos_summa := round_5((p_summa*(-1)) - bank_summa, 2)
  else
    bank_summa := 0
    if round_5(vnos_summa,2) < (p_summa*(-1))
      vnos_summa := (p_summa*(-1))
    endif
  endif
endif
return update_gets()

*


*****  22.10.19
Function chek_fr(vsum,vsd,/*@*/cur_chek,vbank,sekcia,/*@*/fr_serial_number,address,tip_kart,tip_oplat)
Local fl := .t., name_tov, buf := save_maxrow(), ;
      s_err := "", s, last_chek := 0, fl_str := 0, fl_err_annul := .f., ;
      cs := 0, timeout := 5, tt1 := {}, sost, t_nds := 0, t_nds18 :=0,;
      t_nds10 := 0

DEFAULT sekcia TO 1

cur_chek := 0
lfr_data := ""
lfr_time := 0
fr_serial_number := ""
mywait()
//
tt1 := FR_ret_dan()
if empty(tt1)
  return func_error(4,'КАССА НЕ ОТВЕЧАЕТ')
endif
//
last_chek        := tt1[FR_R_NOMER]
cur_chek         := tt1[FR_R_NOMER]
lfr_data         := dtoc4(tt1[FR_R_DATE])
fr_serial_number := tt1[FR_R_ZAVNOMER]
lfr_time         := round_5(timetosec(tt1[FR_R_TIME]),0)
sost             := tt1[FR_R_FLAG]
if tt1[FR_R_REGIM] == 4  // смена не открыта
  // загрузка текущего кассира
  // fio_polzovat
  // oper_parol
  if oper_parol > 0 .and. oper_parol < 31
    t_vrem := FR_ReadPassword(oper_parol)
    //if substr(alltrim(t_vrem[1]),1,6) == "КАССИР" //alltrim(fio_polzovat)
    FR_WritePassword(oper_parol,fio_polzovat)
    FR_WritePassword(30,fio_polzovat)
    //endif
  endif
  if FR_Read_otrezka() > 0
    meK_otrez  := 2 // не отрезать
  else
    meK_otrez  := 1 // отрезать
  endif
  // открыть смену.
  FRCHN_OpenSession()
endif
//
s := ""
if mek_pr_fio == 1
  if type("mplat_fio") == "C" .and. !empty(mplat_fio)
    s := "Больной: "
    if empty(FR_stroka("Плательщик: "+fam_i_o(mplat_fio)))
      ++cs
    endif
    if type("mplat_inn") == "C" .and. !empty(mplat_inn)
      if empty(FR_stroka("ИНН плательщика: "+mplat_inn))
        ++cs
      endif
    endif
  endif
  name_tov := s+lstr(glob_kartotek)+"  "+fam_i_o(glob_k_fio)
else
  name_tov := s+lstr(glob_kartotek)
endif
//
if len(name_tov)>20
  FR_progon(1,1)
endif
//
if iif(len(name_tov) > 20, empty(FR_stroka(name_tov)),;
                           empty(FR_b_stroka(name_tov)))
  ++cs
endif
//
FR_progon(1,1)
//  НАЧАЛО печати услуг
select TMP
go top
do while !eof()
  if fl .and. tmp->kol > 0
    name_tov := alltrim(tmp->name)
    t_nds := 0
    if tmp->nds18 > 0 .or. tmp->nds20 > 0
      t_nds := 1
    elseif tmp->nds10 > 0
      t_nds := 2
    endif
    s_err := FRCHF_registr(tmp->cena,tmp->kol,sekcia,name_tov,t_nds,1,4,tip_oplat)
    if (fl := empty(s_err))
      ++cs //количество продаж
    else
      func_error(4,s_err)
    endif
    if !empty(tmp->vrach)
      FR_stroka(alltrim(tmp->vrach))   // печать врача
    endif
  endif
  skip
enddo
//  КОНЕЦ печати услуг
if fl .and. len(alltrim(address)) > 3
  // передача данных покупателя
  FRN_CustomerEmail(address)
endif
//
if len(alltrim(oper_fr_inn)) == 12
  FR_Write_INN_kassir(oper_fr_inn)
endif
//
if fl
  DEFAULT vbank TO 0
  if empty(vbank)
    s := round_5(p_summa,2)
    if round_5(p_summa,2) < round_5(vsum,2)
      s := vsum
    endif
  else
    s := vsum
  endif
  s_err := FRCH_close(s,vbank,,t_nds,tip_kart)
  if (fl := empty(s_err))
    ++cs //количество продаж
  else
    func_error(4,s_err)
    inkey(0)
  endif
endif
//
if fl
  //tt1 := FR_ret_dan()
  if mek_chek == 1
    //cur_chek := tt1[FR_R_NOMER]-1 //
    cur_chek := FR_ret_dok()+1
  else
    cur_chek := FR_ret_chek() //-1
  endif
  if !isbit(sost,10)
    func_error(4,"Заканчивается ЧЕКОВАЯ лента.")
  endif
  if cur_chek > 0 .and. cur_chek != last_chek
    fl := .t. ; s_err := ""
  endif
endif
// ПРОБЛЕММЫ по печати ЧЕКА
if !fl
  if FRCH_annul() == 1
    fl_err_annul := .t.
  endif
endif
rest_box(buf)
if fl_err_annul
  f_err_annul(s_err)
elseif !fl
  write_err_kassa(s_err,"ЧЕК АННУЛИРОВАН")
endif
//
FR_otrezka(1,2)
//
//if type("delta_chek") == "N"
//  cur_chek += delta_chek
//endif
return fl



*

***** 12.08.18
Function vozvrat_fr(value,bn_value,/*@*/cur_chek,sekcia,tip_banka)
Local fl := .t.,  buf := save_maxrow(), tmp_color := setcolor(color1), ;
      s_err := "", s, last_chek, fl_err_annul := .f., summa_kassa := 0,;
      sm_b1 := sm_b2 := smb3 := 0, r1 := 12, r2 := 20,;
      mas_oplat := {"МИР","VISA","MasterCard","Перевод"}
// запрашиваем наличие наличности в кассе
if valtype(summa_kassa := (FRCH_d_registr(193))) != "N"
  return func_error(4,summa_kassa)
endif
if value > summa_kassa
  return func_error(4,"Недостаточная сумма в кассе")
endif
// запрашиваем наличие БЕЗНАЛА в кассе
if bn_value > 0
  if tip_banka == 1
    if valtype(summa_kassa := (FRCH_d_registr(197))) != "N"
      return func_error(4,summa_kassa)
    endif
  elseif tip_banka == 2
    if valtype(summa_kassa := (FRCH_d_registr(201))) != "N"
      return func_error(4,summa_kassa)
    endif
  else
    if valtype(summa_kassa := (FRCH_d_registr(205))) != "N"
      return func_error(4,summa_kassa)
    endif
  endif
  //
  if bn_value > (summa_kassa)
    buf := box_shadow(r1,5,r2,74,,,"W/B")
    setcolor(color8)
    str_center(r1+2,"Предупреждение!")
    str_center(r1+3,"принятая за смену сумма по карте "+mas_oplat[tip_banka])
    str_center(r1+4,put_kop(summa_kassa,10)+"руб.")
    str_center(r1+5,"меньше, чем сумма воврата.")
    setcolor(color1)
    str_center(r2-2,"Выберите действие:")
    setmtcolor("BG+/B,W+/R,GR+/B,GR+/R")
    @ r2-1,10 prompt " ~Отказ от операции "
    @ r2-1,55 prompt " ~Провести возврат "
    menu to i
    setcolor(tmp_color)
    rest_box(buf)
    if i == 1
      return func_error(4,"Недостаточная сумма БЕЗНАЛА в кассе")
    endif
  endif
endif

mywait()

DEFAULT sekcia TO 1

cur_chek := 0
lfr_data := ""
lfr_time := 0
fr_serial_number := ""
mywait()
//
s := ""
//
FR_progon(1,1)
//  НАЧАЛО печати услуг
select TMP
go top
do while !eof()
  if fl .and. tmp->kol1 > 0
    s_err := FRCHF_registr(tmp->vz_cena,tmp->kol1,sekcia,tmp->name_u,0,2,4,4)
    // доработка 05.19
    //s_err := FRCHF_registr(tmp->u_cena,tmp->kol1,sekcia,tmp->name_u,0,2,4,4)
    if (fl := empty(s_err))
      //++cs //количество продаж
    else
      func_error(4,s_err)
    endif
  endif
  skip
enddo
//  КОНЕЦ печати услуг
if len(alltrim(oper_fr_inn)) == 12
  FR_Write_INN_kassir(oper_fr_inn)
endif
//
if fl
  s_err := FRCH_close(value,bn_value,,0,tip_banka)
  if (fl := empty(s_err))
    //количество продаж
  else
    func_error(4,s_err)
    inkey(0)
  endif
endif
FR_gudok()
//
if fl
  tt1 := FR_ret_dan()
  if mek_chek == 1
    cur_chek := tt1[FR_R_NOMER]-1 //
  else
    cur_chek := FR_ret_chek()-1
  endif
  lfr_data := dtoc4(tt1[FR_R_DATE])
  fr_serial_number := tt1[FR_R_ZAVNOMER]
  lfr_time := round_5(timetosec(tt1[FR_R_TIME]),0)
  sost := tt1[FR_R_FLAG]
  if !isbit(sost,10)
    func_error(4,"Заканчивается ЧЕКОВАЯ лента.")
  endif
  if !fl .and. last_chek > 0
    // и для СОМ
    if cur_chek > 0 .and. cur_chek != last_chek
      fl := .t. ; s_err := ""
    endif
  endif
endif
// ПРОБЛЕММЫ по печати ЧЕКА
if !fl
  if FRCH_annul() == 1
    fl_err_annul := .t.
  endif
endif
rest_box(buf)
if fl_err_annul
  f_err_annul(s_err)
elseif !fl
  write_err_kassa(s_err,"ЧЕК АННУЛИРОВАН")
endif
//
FR_otrezka(1)
//if type("delta_chek") == "N"
//  cur_chek += delta_chek
//endif
//
return fl

*


***** 16.11.18 запрос к кассовому аппарату
Function f1_inf_fr(tip)
Local arr := {}, s,  sd, buf := save_row(maxrow()),;
      c4date := dtoc4(sys_date), n_file := "_kassa.txt",;
      fr_serial_number := "", kol := 0, sum := 0,;
      lkexchangeStatus, lkmessageStatus := 0, lkmessageCount := 0,;
      lkdocumentNumber := 0, lkdateDoc, lktimeDoc, mas_sost := {}

DEFAULT tip TO 1

Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  FR_ZAMENA_otrezka()
else
  return func_error(4,"Ошибка запуска драйвера КАССЫ")
endif
//
mywait()

aadd(arr, center(date_month(sys_date,.t.),60))
if glob_kassa == 1 .and. mek_kassa == 1
 mas_sost := FR_ret_dan()
 aadd(arr, "Дата в ФР  "+full_date(mas_sost[FR_R_DATE]))
 aadd(arr, "Состояние ФР : "+alltrim(mas_sost[FR_R_PODREGIM]))
 //fr_serial_number := tt1[FR_R_ZAVNOMER]
 aadd(arr, " ")
 aadd(arr,"ПО СВЕДЕНИЮ ФИСКАЛЬНОГО РЕГИСТРАТОРА:")
 aadd(arr," -Накопление наличности в кассе             "+str(FRCH_d_registr(241),15,2))
 aadd(arr," -Продажа наличными за смену                "+str(FRCH_d_registr(193),15,2))
 aadd(arr,"  -Возврат продаж наличными за смену        "+str(FRCH_d_registr(195),15,2))
 aadd(arr," -Продажа карта МИР  за смену               "+str(FRCH_d_registr(197),15,2))
 aadd(arr,"  -Возврат продаж карта МИР  за смену       "+str(FRCH_d_registr(199),15,2))
 aadd(arr," -Продажа карта VISA за смену               "+str(FRCH_d_registr(201),15,2))
 aadd(arr,"  -Возврат продаж карта VISA за смену       "+str(FRCH_d_registr(203),15,2))
 aadd(arr," -Продажа карта MasterCard за смену         "+str(FRCH_d_registr(205),15,2))
 aadd(arr,"  -Возврат продаж карта MasterCard за смену "+str(FRCH_d_registr(207),15,2))
 aadd(arr,"НДС ")
 aadd(arr," -Продажа услуги с НДС 18% (20%)            "+str(FRCH_d_registr(209),15,2))
 //aadd(arr,"   -Возврат услуги с НДС 18%                "+str(FRCH_d_registr(211),15,2))
 aadd(arr," -Продажа НДС 18% (20%)                     "+str(FRCH_d_registr(225),15,2))
 //aadd(arr,"   -Возврат НДС 18%                         "+str(FRCH_d_registr(227),15,2))

 aadd(arr," ")
 aadd(arr,"СТАТУС ИНФОРМАЦИОННОГО ОБМЕНА")
 if empty(FRN_GetInfoExchangeStatusShtih( @lkexchangeStatus ,;
                                  @lkmessageStatus,;
                                  @lkmessageCount,;
                                  @lkdocumentNumber,;
                                  @lkdateDoc,;
                                  @lktimeDoc ))
   aadd(arr," -Сообщений для передачи в ОФД                   "+padr(str(lkmessageCount),10))
   aadd(arr," -Номер документа для ОФД первого в очереди      "+padr(str(lkdocumentNumber),10))
   aadd(arr," -Дата документа для ОФД первого в очереди       "+full_date(lkdateDoc))
 else
   aadd(arr," -ДАННЫЕ НЕ СЧИТАНЫ")
 endif
endif
if tip < 5
// для chip_mo
  aadd(arr, " ")
  aadd(arr, "ПО СВЕДЕНИЮ ПРОГРАММЫ:")
  s := sv := sd := 0
  if tip == 1
    R_Use(dir_server+"hum_p",,"HUMAN")
    index on str(kod_k,7) to (cur_dir+"tmp") ;
          for is_kas==1 .and. equalany(c4date,pdate,date_voz) ;
          progress
    go top
    do while !eof()
      if padr(human->fr_zavod,8) == padr(fr_serial_number,8)
        if c4date == human->pdate
          sd += human->cena
          s += human->cena
        endif
        if c4date == human->date_voz
          sd -= human->sum_voz
          sv += human->sum_voz
        endif
      endif
      skip
    enddo
  elseif tip == 2
    R_Use(dir_server+"hum_oro",,"HUMAN")
    index on str(kod,7) to (cur_dir+"tmp") ;
          for equalany(c4date,pdate,date_voz) ;
          progress
    go top
    do while !eof()
      if padr(human->fr_zavod,8) == padr(fr_serial_number,8)
        if c4date == human->pdate
          sd += human->cena_opl
          s += human->cena_opl
        endif
        if c4date == human->date_voz
          sd -= human->sum_voz
          sv += human->sum_voz
        endif
      endif
      skip
    enddo
  else
    R_Use(dir_server+"kas_pl",dir_server+"kas_pl2","KPL")
    find (dtos(sys_date))
    do while kpl->k_data == sys_date .and. !eof()
      if kpl->smena == glob_smena
        kol ++
        sum += kpl->cena
      endif
      skip
    enddo
    R_Use(dir_server+"kas_ort",dir_server+"kas_ort2","KOR")
    find (dtos(sys_date))
    do while kor->k_data == sys_date .and. !eof()
      if kor->smena == glob_smena .and. kor->n_chek > 0
        kol ++
        sum += kor->cena
      endif
      skip
    enddo
  endif
  close databases
  if tip < 3
    aadd(arr, " -Сумма возвратов:                          "+str(abs(sv),15,2))
    aadd(arr, " -Сумма общего итога оплат за смену:        "+str(s,15,2))
  else
    aadd(arr, " -Количество чеков за смену:                "+str(kol,15))
    aadd(arr, " -Сумма общего итога оплат за смену:        "+str(sum,15,2))
  endif
  aadd(arr, " -Сумма наличных денег в ящике ККМ:         "+str(sd,15,2))
  if meK_ostato > 0
    aadd(arr, "")
    aadd(arr, " -Сумма денег, внесенная в кассу УТРОМ:        "+str(meK_ostato,15,2))
    aadd(arr, " -Итого сумма наличных денег в ящике ККМ:      "+str(sd+meK_ostato,15,2))
  endif
endif
s := eos
aeval(arr, {|x| s += space(10)+x+eos } )
strfile(s, n_file)
rest_box(buf)
viewtext(n_file)
return NIL


*

***** 28.09.17 запрос к кассовому аппарату
Function fiskal_inf_fr()
Local lkexchangeStatus, lkmessageStatus := 0, lkmessageCount := 0,;
      lkdocumentNumber := 0, lkdateDoc, lktimeDoc

if empty(FRN_GetInfoExchangeStatusShtih( @lkexchangeStatus ,;
                                @lkmessageStatus,;
                                @lkmessageCount,;
                                @lkdocumentNumber,;
                                @lkdateDoc,;
                                @lktimeDoc ))
  if !empty(lkmessageCount)
    if lkmessageCount > 0
      func_error(4,"В ОФД не передано "+lstr(lkmessageCount)+" чеков. Документы в очереди от "+full_date(lkdateDoc))
    endif
  endif
endif
return NIL



*

***** гудок на кассовом аппарате
function FR_gudok()

IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  drvFR:Password := oper_parol
  drvFR:Beep()
endif
return


*

***** ДРАЙВЕР вывод строки на чековую ленту
function FR_stroka(stroka,flag)
/* flag - 1 печать на контрольной ленте
          2 печать на чековой ленте
   stroka - строка выводимая на чековую ленту
*/
local t, s
DEFAULT flag to 2

s := atrepl(",",alltrim(stroka),";")   // заменить ";" на "," строки
stroka := charone(" ",s)                    // удалить совмещенные пробелы


drvFR:Password := oper_parol
drvFR:StringForPrinting := stroka
if flag == 1 //контролька
  drvFR:UseJournalRibbon := .T.
else
  drvFR:UseReceiptRibbon := .T.
endif
HB_CDPSELECT("RU1251")
IF drvFR:PrintString() < 0
   t := drvFR:ResultCodeDescription
   HB_CDPSELECT("RU866")
   return alltrim(t)
endif
HB_CDPSELECT("RU866")
return NIL


*

***** ДРАЙВЕР вывод строки на чековую ленту
function FR_b_stroka(stroka,flag)
/* flag - 1 печать на контрольной ленте
          2 печать на чековой ленте
   stroka - строка выводимая на чековую ленту
*/
local t
DEFAULT flag to 2

s := atrepl(",",alltrim(stroka),";")   // заменить ";" на "," строки
stroka := charone(" ",s)                    // удалить совмещенные пробелы

drvFR:Password := oper_parol
drvFR:StringForPrinting := stroka
if flag == 1 //контролька
  drvFR:UseJournalRibbon := .T.
else
  drvFR:UseReceiptRibbon := .T.
endif
HB_CDPSELECT("RU1251")
IF drvFR:PrintWideString() < 0
   t := drvFR:ResultCodeDescription
   HB_CDPSELECT("RU866")
   return alltrim(t)
endif
HB_CDPSELECT("RU866")
return NIL


*

***** ДРАЙВЕР отрезка чековой ленты
function FR_otrezka(flag,zad_time)
/* flag - 0 полная отрезка
          1 частичный отрез
*/
DEFAULT zad_time to 0

if meK_otrez == 1
  if zad_time > 0
    mywait()
    inkey(zad_time)
  endif
  drvFR:Password := oper_parol
  if flag == 0
    drvFR:CutType := 0
  else
    drvFR:CutType := 1
  endif
  drvFR:CutCheck()
endif
return NIL



*

***** ДРАЙВЕР прогон чековой ленты
function FR_progon(flag,kol_str)
/*  flag - 0 контрольная лента
           1 чековая лента
           2 обе ленты
    kol_str количество прогоняемых строк
*/
drvFR:Password := oper_parol
drvFR:StringQuantity := kol_str
if flag == 0 .or. flag == 2 //контролька
  drvFR:UseJournalRibbon := .T.
else
  drvFR:UseReceiptRibbon := .T.
endif
drvFR:FeedDocument()
return NIL

*

***** 12.08.18 Регистрация товара
function FRCHF_registr(cena,kol_vo,sekcia,name,t_nds,Tip_operation,tip_tovar,tip_rachet)
/*  cena          - цена товара в рублях
    kol_vo        - количество товара
    sekcia        - номер секции
    name          - наименование товара
    Tip_operation - 1 == продажа 2 == возврат продажи
    tip_tovar     - тип товара 4 == услуга
    tip_rachet    - тип расчета 4 == полный
*/
local t := ""

DEFAULT tip_tovar to 4, tip_rachet to 4


if len(name) > 127
  name := substr(name,1,128)
endif
name := upper(alltrim(name))
drvFR:Password := oper_parol
drvFR:CheckType := Tip_operation // 1 - продажа 2 - возврат
drvFR:Quantity := kol_vo
drvFR:Price    := cena
drvFR:Department := sekcia
drvFR:Summ1Enabled := .F.
drvFR:StringForPrinting := name
drvFR:Tax1 := t_nds
drvFR:PaymentTypeSign := 4 //tip_tovar
drvFR:PaymentItemSign  := 4 //tip_rachet

IF drvFR:FNOperation() < 0
  t := upper(drvFR:ResultCodeDescription)
  return alltrim(t)
endif
HB_CDPSELECT("RU866")
if (t := upper(drvFR:ResultCodeDescription)) == "ОШИБОК НЕТ"
  return NIL
else
  return alltrim(t)
endif
return NIL


*


***** 10.09.18  Закрытие чека
function FRCH_close(summa,summa1,name,t_nds,tip_kart)
/*  summa  - сумма наличных
    summa1 - по кредитной карте
    name   - текст
    t_nds
*/
local  t := ""
DEFAULT name TO " "

drvFR:Password := oper_parol
//
drvFR:Summ1 := 0
drvFR:Summ2 := 0
drvFR:Summ3 := 0
drvFR:Summ4 := 0
drvFR:Summ5 := 0
drvFR:Summ6 := 0
drvFR:Summ7 := 0
drvFR:Summ8 := 0
drvFR:Summ9 := 0
drvFR:Summ10 := 0
drvFR:Summ11 := 0
drvFR:Summ12 := 0
drvFR:Summ13 := 0
drvFR:Summ14 := 0
drvFR:Summ15 := 0
drvFR:Summ16 := 0
//
drvFR:TaxValue1  := 0
drvFR:TaxValue2  := 0
drvFR:TaxValue3  := 0
drvFR:TaxValue4  := 0
drvFR:TaxValue5  := 0
drvFR:TaxValue6  := 0
//
//drvFR:RoundingSumm :=2
//
drvFR:Summ1 := summa
if tip_kart == 0 //старые кассы
  drvFR:Summ4 := summa1
elseif tip_kart == 1 //МИР
  drvFR:Summ2 := summa1
elseif tip_kart == 2 //VISA
  drvFR:Summ3 := summa1
elseif tip_kart == 3 //Masterkard
  drvFR:Summ4 := summa1
elseif tip_kart == 4 //Банковский перевлд
  drvFR:Summ5 := summa1
endif
drvFR:RoundingSumm := 0  //Сумма округления
drvFR:StringForPrinting := name
drvFR:TaxValue1 := t_nds //Налоги
!!!!!! ВНИМАНИЕ !!!!!!
if glob_mo[_MO_KOD_TFOMS] == '605301' // ЗАО Стоматолог
  drvFR:TaxType := 2 //УСН
else
  drvFR:TaxType := 1 //Основная система Налогооблажения
endif
//
IF drvFR:FNCloseCheckEx() < 0
  t := upper(drvFR:ResultCodeDescription)
  return alltrim(t)
endif
HB_CDPSELECT("RU866")
if (t := upper(drvFR:ResultCodeDescription)) == "ОШИБОК НЕТ"
  return NIL
else
  return alltrim(t)
endif
return NIL


*

***** Установка времени
function FR_set_time(time)
//  time   - время в формате ЧЧ:ММ:СС
local t := ""

drvFR:Password := oper_frparol
drvFR:Time := time
IF drvFR:SetTime() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
endif
return NIL


*

***** Программирование даты (подтверждение программирования даты)
Function FR_set_date(ldate)
/*  n_prot - номер порта
    ldate  - дата в формате даты
*/
local  t := ""

drvFR:Password := oper_frparol
drvFR:Date := ldate
IF drvFR:SetDate() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
endif
//
IF drvFR:ConfirmDate() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
endif
return NIL

*

***** Снятие суточного отчета
Function FR_normgach(flag)
Local t := ""

drvFR:Password := oper_frparol
if flag == 0 //без гашения
  IF drvFR:PrintReportWithoutCleaning() < 0
     t := drvFR:ResultCodeDescription
     return alltrim(t)
  else
     //t := drvFR:ResultCodeDescription
     return NIL
  endif
elseif flag == 1
  if len(alltrim(oper_fr_inn)) == 12
    //
    drvFR:FNBeginCloseSession()
    //
    drvFR:Password    := oper_frparol
    drvFR:TagNumber   := 1203
    drvFR:TagType     := 7
    drvFR:TagValueStr := oper_fr_inn
    //
    drvFR:FNSendTag()
    drvFR:Password    := oper_frparol
    IF drvFR:PrintReportWithCleaning() < 0
       t := drvFR:ResultCodeDescription
       return alltrim(t)
    else
       //t := drvFR:ResultCodeDescription
       return NIL
    endif
  else
    IF drvFR:PrintReportWithCleaning() < 0
       t := drvFR:ResultCodeDescription
       return alltrim(t)
    else
       //t := drvFR:ResultCodeDescription
       return NIL
    endif
  endif
else
  IF drvFR:PrintDepartmentReport() < 0
     t := drvFR:ResultCodeDescription
     return alltrim(t)
  else
     //t := drvFR:ResultCodeDescription
     return NIL
  endif
endif
return NIL

*

***** Снятие суточного отчета по НАЛОГАМ
Function FRN_PrintTaxReport()

local t := ""

IF drvFR:PrintTaxReport() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
endif
return NIL

*

***** Снятие суточного отчета по СЕКЦИЯМ
Function FRN_PrintDepartmentReport()

local t := ""

IF drvFR:PrintDepartmentReport() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
endif
return NIL


*

***** Аннулирование всего чека до его закрытия
function FRCH_annul()
/*  1 - аннулирование неудачно
    0 - аннулирование удачно завершено
*/
local t

drvFR:Password := oper_parol
IF drvFR:CancelCheck() < 0
   t := drvFR:ResultCodeDescription
   return iif(empty(alltrim(t)),0,1)
endif
return 0


*

***** продолжение печати
function FR_prodol()
local t

drvFR:Password := oper_parol
IF drvFR:ContinuePrint() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
endif
return NIL


*

***** Возвращает текущий номер чека покупки
Function FR_ret_chek()
local num_chek := 0

drvFR:Password := oper_parol
drvFR:RegisterNumber :=148
IF drvFR:GetOperationReg() < 0
   num_chek := drvFR:ResultCodeDescription
   return 0 //пока так
else
   num_chek := drvFR:ContentsOfOperationRegister
endif
return num_chek

*

***** Возвращает текущий номер документа
Function FR_ret_dok()
local num_chek := 0

drvFR:Password := oper_parol
drvFR:RegisterNumber :=152
IF drvFR:GetOperationReg() < 0
   num_chek := drvFR:ResultCodeDescription
   return 0 //пока так
else
   num_chek := drvFR:ContentsOfOperationRegister
endif
return num_chek

*

***** Запрос денежного регистра
function FRCH_d_registr(registr)
//     registr - номер регистра
Local t

drvFR:Password := oper_parol
drvFR:RegisterNumber := registr
IF drvFR:GetCashReg() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
else
   t := drvFR:ContentsOfCashRegister
endif
return t

*

***** Возвращает в виде массива состояние ФР
Function FR_ret_dan()
Local mas_vozvr := {}, t, t1, t2, i, t4
drvFR:Password := oper_parol
for i := 1 to FR_R_LEN
  t := " "
  aadd(mas_vozvr,t)
next
IF drvFR:GetECRStatus() < 0 //ошибка
   t := drvFR:ResultCodeDescription
   func_error(4,t)
   return NIL
else
   t := drvFR:ResultCodeDescription
   mas_vozvr[FR_R_NOMER] := drvFR:OpenDocumentNumber
   mas_vozvr[FR_R_DATE] := drvFR:Date
   mas_vozvr[FR_R_TIME] := drvFR:TimeStr
   mas_vozvr[FR_R_REGIM] := drvFR:ECRMode
   // 2 - смена открыта 4 - закрытая смена
   //mas_vozvr[FR_R_PORT] := drvFR:PortNumber
   t1 := drvFR:ReceiptRibbonIsPresent
   t2 := drvFR:JournalRibbonIsPresent
   mas_vozvr[FR_R_PORT] := drvFR:PortNumber
   mas_vozvr[FR_R_ZAVNOMER] := drvFR:SerialNumber
   mas_vozvr[FR_R_FLAG] := 0
   if t1
     mas_vozvr[FR_R_FLAG] := setbit(mas_vozvr[FR_R_FLAG],10)
   endif
   if t2
     mas_vozvr[FR_R_FLAG] := setbit(mas_vozvr[FR_R_FLAG],9)
   endif
   //задействуем поле заводской номер
   mas_vozvr[FR_R_PODREGIM] := alltrim(drvFR:ECRModeDescription)
   if mas_vozvr[FR_R_REGIM] == 8
     t4 := drvFR:ECRMode8Status
     if t4 == 0
       mas_vozvr[FR_R_PODREGIM] := mas_vozvr[FR_R_PODREGIM] +" Открыт чек продажи"
     elseif  t4 == 1
       mas_vozvr[FR_R_PODREGIM] := mas_vozvr[FR_R_PODREGIM] +" Открыт чек покупки"
     elseif  t4 == 2
       mas_vozvr[FR_R_PODREGIM] := mas_vozvr[FR_R_PODREGIM] +" Открыт чек возврата продажи"
     else
       mas_vozvr[FR_R_PODREGIM] := mas_vozvr[FR_R_PODREGIM] +" Открыт чек возврата покупки"
     endif
   endif
endif
return mas_vozvr


*

***** вызов драйвера
function FR_draiver()
LOCAL mas_kassa := {}, t := ""
Local mas_sp_kassa :={0,0,0,0}

Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  IF drvFR:ShowProperties()  < 0
    t := drvFR:ResultCodeDescription
    func_error(4,t)
  ENDIF
endif
return NIL

*

***** вызов драйвера
function FR_lenstring()

Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  if drvFR:GetDeviceMetrics()  < 0
    FR_ZAMENA_otrezka()
  else
    t := drvFR:UDescription
  ENDIF
endif
return NIL

*

***** 22.10.19  Открытие смены
function FRCHN_OpenSession()
Local t, tt1

if len(alltrim(oper_fr_inn)) == 12
  drvFR:Password := oper_frparol
  drvFR:FNBeginOpenSession()
  //
  drvFR:Password    := oper_frparol
  drvFR:TagNumber   := 1203
  drvFR:TagType     := 7
  drvFR:TagValueStr := oper_fr_inn
  //
  drvFR:FNSendTag()
  //
  drvFR:Password := oper_parol
  IF drvFR:FNOpenSession() < 0
     t := drvFR:ResultCodeDescription
     return alltrim(t)
  else
     t := drvFR:ContentsOfCashRegister
  endif
  waitperiod(100) // время произвольно
  do while waitperiod()
  enddo
else
  drvFR:Password := oper_parol
  IF drvFR:OpenSession() < 0
     t := drvFR:ResultCodeDescription
     return alltrim(t)
  else
     t := drvFR:ContentsOfCashRegister
  endif
  waitperiod(100) // время произвольно
  do while waitperiod()
  enddo
endif
//
waitperiod(5000)
// попытка открыть порт в течении 5 секунд
// время произвольное
do while waitperiod() // в цикле пробуем открыть с нужными параметрами
  tt1 := FR_ret_dan(1)
  if tt1[FR_R_REGIM] == 2  // смена открыта 24 часа не кончились
    return t
  endif
enddo
return t

*

***** передача телефона(электронки) покупателя
function FRN_CustomerEmail(address)
local  t

drvFR:Password := oper_parol
drvFR:CustomerEmail = address
IF drvFR:FNSendCustomerEmail() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
endif
return NIL


*

***** ДРАЙВЕР Получение статуса информационного обмена
function FRN_GetInfoExchangeStatusShtih( /*@*/exchangeStatus ,;
                                         /*@*/messageStatus,;
                                         /*@*/messageCount,;
                                         /*@*/documentNumber,;
                                         /*@*/dateDoc,;
                                         /*@*/timeDoc )

local t
drvFR:Password := oper_frparol
if drvFR:FNGetInfoExchangeStatus() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
endif
exchangeStatus := drvFR:InfoExchangeStatus
messageStatus := drvFR:MessageState
messageCount := drvFR:MessageCount
documentNumber := drvFR:DocumentNumber
dateDoc := drvFR:Date
timeDoc := drvFR:Time
return NIL

*

*****
function FR_WritePassword(N_zapis_tabl,name_kassir)
Local t1

drvFR:Password    := oper_frparol
drvFR:TableNumber := 2                // номер таблицы
drvFR:FieldNumber := 2   // номер поля
IF drvFR:GetFieldStruct() < 0
   t := drvFR:ResultCodeDescription
else
   t := drvFR:ContentsOfCashRegister
endif
drvFR:Password    := oper_frparol
drvFR:TableNumber := 2                // номер таблицы
drvFR:RowNumber   := N_zapis_tabl     // номер ряда
drvFR:FieldNumber := 2   // номер поля
drvFR:ValueOfFieldString := name_kassir //Значение СТРОКА
//drvFR:ValueOfFieldInteger := //Значение ЧИСЛО

IF drvFR:WriteTable() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
else
   t := drvFR:ContentsOfCashRegister
endif
return t

*

*****
function FR_ReadPassword(N_zapis_tabl,name_kassir)
Local t1, t

drvFR:Password    := oper_frparol
drvFR:TableNumber := 2                // номер таблицы
drvFR:FieldNumber := 2   // номер поля
IF drvFR:GetFieldStruct() < 0
   t := drvFR:ResultCodeDescription
else
   t := drvFR:ContentsOfCashRegister
endif
drvFR:ValueOfFieldString := ""
drvFR:ValueOfFieldInteger := 0
// читаем
drvFR:Password    := oper_frparol
drvFR:TableNumber := 2                // номер таблицы
drvFR:RowNumber   := N_zapis_tabl     // номер ряда
drvFR:FieldNumber := 2   // номер поля
IF drvFR:ReadTable() < 0
   t := drvFR:ResultCodeDescription
else
   t := drvFR:ContentsOfCashRegister
endif
t1 := drvFR:ValueOfFieldString
// читаем
drvFR:Password    := oper_frparol
drvFR:TableNumber := 2                // номер таблицы
drvFR:RowNumber   := N_zapis_tabl     // номер ряда
drvFR:FieldNumber := 1   // номер поля
IF drvFR:ReadTable() < 0
   t := drvFR:ResultCodeDescription
else
   t := drvFR:ContentsOfCashRegister
endif
return {t1,drvFR:ValueOfFieldInteger}

*

*****
function FRN_WritePassword()
Local name_kassir, password_kassir, T_vrem
Local arr := {}, s,buf := save_row(maxrow()),;
      n_file := "_kassa.txt"


if glob_kassa == 1 .and. mek_kassa == 1
  Private drvFR
  IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    //
  else
    return func_error(4,"Ошибка запуска драйвера КАССЫ")
  endif
endif
//
R_Use(dir_server+"base1",,"BASE1")
select BASE1
go top
do while !eof()
  if !empty(base1->p1)
    name_kassir     := alltrim(crypt(base1->p1,gpasskod))
    password_kassir := val(alltrim(crypt(base1->p7,gpasskod)))
    if password_kassir > 0 .and. password_kassir < 31
      FR_WritePassword(password_kassir,name_kassir)
    endif
  endif
  skip
enddo
aadd(arr, " ")
aadd(arr,"Установленные в ФР Кассиры:")
select BASE1
go top
do while !eof()
  if !empty(base1->p1)
    name_kassir     := alltrim(crypt(base1->p1,gpasskod))
    password_kassir := val(alltrim(crypt(base1->p7,gpasskod)))
    if password_kassir > 0 .and. password_kassir < 31
      t_vrem := FR_ReadPassword(password_kassir,name_kassir)
      aadd(arr," -Кассир: "+padr(t_vrem[1],30)+" Пароль кассы: "+lstr(t_vrem[2]))
    endif
  endif
  skip
enddo
close databases
s := eos
aeval(arr, {|x| s += space(10)+x+eos } )
strfile(s, n_file)
rest_box(buf)
viewtext(n_file)
//
return NIL

*

*****
function FRN_GetDriverFR()
// открытие и проверки
Local vozvrat := .F.

if glob_kassa == 1 .and. mek_kassa == 1
  Private drvFR
  IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  else
    func_error(4,"Ошибка запуска драйвера КАССЫ")
    vozvrat := .T.
  endif
endif
return vozvrat

*

***** Контроль адреса электронной gjxns или телефона

function ControlAddress( get, address )
	local ret := .f.

	address := alltrim( address )

	ret := hb_RegexLike( emailTemplate, address ) .or. hb_RegexLike( phoneTemplate, address ) .or. empty( address )

	if !ret
		ALERT( "Не верный формат телефона или E-mail адреса!" )
	endif
	return ret

*******************************************

* преобразование номера сотового
function TransformPhone( address )

	address := AllTrim( address )
	address := AtRepl( '-', address, '' )
	address := AtRepl( ' ', address, '' )
	address := AtRepl( '_', address, '' )
	address := AtRepl( '(', address, '' )
	address := AtRepl( ')', address, '' )
	address := AtRepl( ':', address, '' )
	address := AtRepl( '=', address, '' )
	address := AtRepl( '+', address, '' )
	if len( address ) == 10
		address := '+7' + address
	elseif len( address ) == 11
		if substr( address, 1, 1 ) != '7'
			address := '+7' + substr( address, 2 )
		else
			address := '+' + address
		endif
	else
		address := ''
	endif
	return address

*

***** 24.12.18
function FR_Read_otrezka()
Local t1, t

drvFR:Password    := oper_frparol
drvFR:TableNumber := 1   // номер таблицы
drvFR:FieldNumber := 7   // номер поля
IF drvFR:GetFieldStruct() < 0
   t := drvFR:ResultCodeDescription
else
   t := drvFR:ContentsOfCashRegister
endif
drvFR:ValueOfFieldString := ""
drvFR:ValueOfFieldInteger := 0
// читаем
drvFR:Password    := oper_frparol
drvFR:TableNumber := 1   // номер таблицы
drvFR:RowNumber   := 1   // номер ряда
drvFR:FieldNumber := 7   // номер поля
IF drvFR:ReadTable() < 0
   t := drvFR:ResultCodeDescription
else
   t := drvFR:ContentsOfCashRegister
endif
return drvFR:ValueOfFieldInteger

*

***** 24.12.18
function FR_ZAMENA_otrezka(tip)
DEFAULT tip to 1

if tip > 1
  if FR_Read_otrezka() > 0
    meK_otrez  := 2 // не отрезать
  else
    meK_otrez  := 1 // отрезать
  endif
endif
return NIL


*

***** 30.06.19
function FR_Write_INN_kassir(inn_kassir)
Local t1

//
drvFR:Password    := oper_parol
drvFR:TagNumber   := 1203
drvFR:TagType     := 7
drvFR:TagValueStr := inn_kassir
//
drvFR:FNSendTag()
return NIL


