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

***** 28.09.17
Function f5_sist_fr(k)
Static mm_da_net := {{"да ",1},{"нет",2}}
Static mm_chek := {{"Сквозной номер документа ККМ",1},{"Номер чека продажи ККМ",2}}
Static mm_tkassa := {{"ККМ c ФР",1},{"ККМ по 54-ФЗ",2}}
Static n_zapusk := 0
Local mm_tmp := {}, buf, fl := .f., s
Local COM_speed := {{"  2400",  2400},;  // 0
                    {"  4800",  4800},;  // 1
                    {"  9600",  9600},;  // 2
                    {" 19200", 19200},;  // 3
                    {" 38400", 38400},;  // 4
                    {" 57600", 57600},;  // 5
                    {"115200",115200}}   // 6
if k == 1
  Public FR_LOG_FLAG
  Public meS_speed := 115200
  Public meK_port   := 1,;      // номер порта для подключения кассового аппарата,;
         meK_ostato := 0,;
         meK_sdacha := 1,;
         meK_w_sdac := 1,;
         meK_bank   := 2,;
         meK_lof_fi := 2,;
         meK_open_p := 2,;
         meK_otrez  := 1,;
         meK_progon := 2,;
         mek_TIME_1 := 50,;
         PFR_TIME_1 := 500,;
         mek_N_chek := 1,;  // контроль номеров - убрал
         meK_kassa  := 1,;  // рабочее место кассира
         meK_pr_FIO := 1,;
         mek_nkassa := 2,;
         MEK_KASSIR := space(20),;
         mek_chek   := 1,;
         mek_tkassa := 2  // новые кассы - только новые
         //mek_lenstr := 40    //не редактируется
  if file("_kassa_.mem")
    restore from _kassa_ additive
  else
    save all like meK_* to _kassa_
  endif
  meK_open_p := 2
  mek_tkassa := 2 // ККМ по 54-ФЗ
  mek_N_chek := 1
  ***************
// контроль
  if n_zapusk == 0
    ++n_zapusk
    if iif(glob_task == X_KASSA,.T.,glob_kassa == 1) .and. mek_kassa == 1
      Private drvFR
      IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
        fiskal_inf_fr()
      endif
    endif
  endif
//
elseif k == 2
  ***************
  buf := box_shadow(1,0,22,78,"B+/B")

  // Настройки убраны
  meK_open_p := 2
  mek_nkassa := 1 //Работаем ТОЛЬКО через драйвер
  meK_lof_fi := 2 // для СОМ
  meK_port   := 1 // для СОМ
  PFR_TIME_1 := 500  // для СОМ
  meK_progon := 1
  mek_tkassa := 2 // ККМ по 54-ФЗ
  mek_N_chek := 1

  Private mnewkassa, m1newkassa := mek_nkassa,;
          mostatok := meK_ostato,;
          msdacha, m1sdacha := meK_sdacha,;
          mw_sdacha, m1w_sdacha := meK_w_sdac,;
          mmeK_bank, m1meK_bank := meK_bank,;
          mmeK_kassa, m1meK_kassa := meK_kassa,;
          mmeK_lof_fi, m1meK_lof_fi := meK_lof_fi,;
          mmeK_port := meK_port,;
          mmeK_otrez, m1meK_otrez := meK_otrez,;
          mmeK_progon, m1meK_progon := meK_progon,;
          mPFR_TIME_1 := PFR_TIME_1,;
          mmeS_speed := meS_speed,;
          mmek_pr_fio, m1mek_pr_fio := mek_pr_fio,;
          mnkassa := space(10), m1nkassa := 0,;
          mkassir := mek_kassir,;
          mmek_chek := m1mek_chek := mek_chek

//        mmek_N_chek, m1mek_N_chek := mek_N_chek,;


//  mmek_tkassa := inieditspr(A__MENUVERT,mm_tkassa,m1mek_tkassa)
//  mnewkassa   := inieditspr(A__MENUVERT,mm_da_net,m1newkassa)
  msdacha     := inieditspr(A__MENUVERT,mm_da_net,m1sdacha)
  mw_sdacha   := inieditspr(A__MENUVERT,mm_da_net,m1w_sdacha)
  mmeK_bank   := inieditspr(A__MENUVERT,mm_da_net,m1meK_bank)
  mmeK_kassa  := inieditspr(A__MENUVERT,mm_da_net,m1meK_kassa)
//  mmeK_lof_fi := inieditspr(A__MENUVERT,mm_da_net,m1meK_lof_fi)
//  mmek_N_chek := inieditspr(A__MENUVERT,mm_da_net,m1mek_N_chek)
  mmeK_otrez  := inieditspr(A__MENUVERT,mm_da_net,m1meK_otrez)
//  mmeK_progon := inieditspr(A__MENUVERT,mm_da_net,m1meK_progon)
  mmek_pr_fio := inieditspr(A__MENUVERT,mm_da_net,m1mek_pr_fio)
  mmek_chek   := inieditspr(A__MENUVERT,mm_chek,m1mek_chek)

  //do while .t.
    setcolor(cDataCGet)
    ix := 3
    ClrLines(1,maxrow()-1)
    if tip_polzovat == 0
//    @ ix,3 say "Работать с кассой через ДРАЙВЕР?" get mnewkassa ;
//              reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
      @ ++ix,3 say "Номером документа считать " get mmek_chek ;
                reader {|x|menu_reader(x,mm_chek,A__MENUVERT,,,.f.)}
      @ ++ix,3 say "Вызов драйвера ..." get mnkassa ;
                reader {|x|menu_reader(x,{{||FR_draiver()}},A__FUNCTION,,,.f.)};
                  when m1newkassa==1
//      @ ++ix,3 say "Тип кассы " get mmek_tkassa ;
//                reader {|x|menu_reader(x,mm_tkassa,A__MENUVERT,,,.f.)}
    endif

    @ ++ix,3 say "Сумма денег, внесенная в кассу УТРОМ" get mostatok  pict "999999.99"
      ++ix
    @ ++ix,3 say "Запрашивать вносимую покупателем сумму и подсчитывать сдачу?" get msdacha ;
                reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
    @ ++ix,3 say "Печатать вносимую покупателем сумму и сдачу в чек?" get mw_sdacha ;
                reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
    if tip_polzovat == 0
      ++ix
      @ ++ix,3 say "Работать с банковскими картами ?" get mmeK_bank ;
                  reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
      ++ix
      @ ++ix,3 say "Это рабочее место кассира ?" get mmeK_kassa ;
                  reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
//      @ ++ix,3 say "Вести протокол обмена с фискальным регистратором ШТРИХ-ФР?" get mmeK_lof_fi ;
//                   reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)};
//                  when m1newkassa== 2
//      @ ++ix,3 say "Номер порта для подключения кассового аппарата:" get mmeK_port  pict "9" ;
//                  when m1newkassa==2 valid eq_any(mmeK_port,1,2)
//      @ ++ix,3 say "Проводить контроль номеров чека?" get mmek_N_chek ;
//                  reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
      @ ++ix,3 say "Проводить программную отрезку чека?" get mmeK_otrez ;
                  reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
//      @ ++ix,3 say "Использовать в чеке прогон вместо пустой строки?" get mmeK_progon ;
//                  reader {|x|menu_reader(x,mm_da_net,A__MENUVERT,,,.f.)}
//      @ ++ix,3 say "Таймаут для фискального регистратора (50...9999) ?" get mPFR_TIME_1;
//                  pict "9999"  when m1newkassa== 2
//      @ ++ix,3 say "Cкорость обмена с фискальным регистратором ШТРИХ-ФР ?" get mmeS_speed;
//                  pict "999999"  when m1newkassa== 2
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
    meK_sdacha := m1sdacha
    meK_w_sdac := m1w_sdacha
    mek_kassir := mkassir
    if tip_polzovat == 0
      mek_bank   := m1mek_bank
      mek_kassa  := m1mek_kassa
      meK_otrez  := m1meK_otrez
      mek_pr_fio := m1mek_pr_fio
      mek_chek   := m1mek_chek
      //mek_tkassa := m1mek_tkassa
      //mek_n_chek := m1mek_n_chek
      //meK_progon := m1meK_progon
      //meK_lof_fi := m1meK_lof_fi
      //meK_port   := mmeK_port
      //mek_TIME_1 := mPFR_TIME_1
      //meS_speed  := mmeS_speed
      //mek_nkassa := m1newkassa
      /*if m1newkassa == 1
        mek_lenstr := FR_lenstring()
      else
        mek_lenstr := 40
      endif*/
    endif
    save all like meK_* to _kassa_
 //   save all like meS_* to _speed_
  endif
  rest_box(buf)
endif
FR_LOG_FLAG := (meK_lof_fi == 1)   // !!!!!!!!!!!!
PFR_TIME_1  := mek_TIME_1
return NIL


*

***** 17.06.15
function f1_sist_fr()
// Изменение даты в ККМ
Local fl := .t., lport := meK_port, parol := 0, t, tt, tt1, s_err

Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  //
else
  return func_error(4,"Ошибка запуска драйвера КАССЫ")
endif
//
if !ret_dataedit()
  return NIL
endif
tt := FR_ret_dan(lport)
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
if (fl := empty(s_err := FR_set_date(lport,mdate)))
  stat_msg("Команда Выполнена!")
  n_message({"","Дата в ФР изменена !"},,;
            color1,cDataCSay,,,color8)
  FR_gudok(lport)
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

***** 17.06.15 Синхронизация времени
function f2_sist_fr()
Local fl := .t., lport := meK_port, t, tt, tt1, x, cur_time,;
      r1 := 11, r2 := 20, i, tmp_color := setcolor(color1), buf

Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  //
else
  return func_error(4,"Ошибка запуска драйвера КАССЫ")
endif
//
tt := FR_ret_dan(lport)
if empty(tt)
  return func_error(4,'НЕ СЧИТАНО ВРЕМЯ ИЗ ФР')
endif
tt1 := tt[FR_R_TIME] ; cur_time := time()
buf := box_shadow(r1,5,r2,74)
setcolor(color8)
str_center(r1+2,"Предупреждение!")
str_center(r1+3,"Этот режим пердназначен для синхронизации времени")
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
  if empty(FR_set_time(lport,t))
    FR_gudok(lport)
    stat_msg("Команда Выполнена!")
    n_message({"","Установка Времени в ФР произведена"},,;
              color1,cDataCSay,,,color8)
  else
    func_error(4,'НЕ ПРОИЗОШЛО УСТАНОВКИ ВРЕМЕНИ')
  endif
elseif i == 3
  tt := FR_ret_dan(lport)
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

***** 17.06.15
function f3_sist_fr(tip)
// 0 - Снятие суточного отчета без гашения
// 1 - с гашением
Local fl := .t., lport := meK_port, s_err, parol, t, tt, tt1, buf

buf := save_row(maxrow())


Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  //
else
  return func_error(4,"Ошибка запуска драйвера КАССЫ")
endif
//
if !ret_fsytotch(tip)
  return NIL
endif
if (fl := empty(s_err := FR_normgach(lport,tip)))
  rest_box(buf)
  mywait()
  stat_msg("Команда выполнена!")
  if tip == 1
    n_message({"","Гашение суточного отчета выполнено!"},,;
              color1,cDataCSay,,,color8)
  endif
  if meK_otrez == 1
    mywait()
    inkey(3)
    FR_otrezka(lport,1,0)
  endif
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

***** 17.06.15
function f6_sist_fr()
//  продолжение печати
Local fl := .t., lport := meK_port, s_err, parol, t, tt, tt1, buf
buf := save_row(maxrow())

if glob_kassa == 1 .and. mek_kassa == 1
  Private drvFR
  IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    //
  else
    return func_error(4,"Ошибка запуска драйвера КАССЫ")
  endif
endif
//
if (fl := empty(s_err := FR_prodol(lport)))
  rest_box(buf)
  mywait()
  stat_msg("Команда выполнена!")
  mywait()
  FR_otrezka(lport,1,300)
  rest_box(buf)
else
  rest_box(buf)
  write_err_kassa(s_err,'НЕ ПРОИЗОШЛО ПРОДОЛЖЕНИЯ ПЕЧАТИ')
endif
rest_box(buf)
return NIL

*

***** 17.06.15
function f7_sist_fr()
//  аннулирование чека
Local fl := .t., lport := meK_port, s_err, parol, t, tt, tt1, buf
buf := save_row(maxrow())

Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  //
else
  return func_error(4,"Ошибка запуска драйвера КАССЫ")
endif
//
if (fl := empty(s_err := FRCH_annul(lport)))
  rest_box(buf)
  mywait()
  stat_msg("Команда выполнена!")
  mywait()
  FR_otrezka(lport,1,300)
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
Local fl := .t., lport := meK_port, s_err, parol, t, tt, tt1, buf

buf := save_row(maxrow())


if glob_kassa == 1 .and. mek_kassa == 1
  Private drvFR
  IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    //
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
  if meK_otrez == 1
    mywait()
    inkey(3)
    FR_otrezka(lport,1,0)
  endif
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
Local fl := .t., lport := meK_port, s_err, parol, t, tt, tt1, buf

buf := save_row(maxrow())


if glob_kassa == 1 .and. mek_kassa == 1
  Private drvFR
  IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
    //
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
  if meK_otrez == 1
    mywait()
    inkey(3)
    FR_otrezka(lport,1,0)
  endif
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
Local fl := .t., lport := meK_port, s_err, parol, t, tt, tt1, buf

buf := save_row(maxrow())


Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  //
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

***** 07.08.17
Function yes_chek(/*@*/vsum,/*@*/vsd,/*@*/vbank,rm,/*@*/address,/*@*/tip_kart)
Static spict := "9999999.99"
Local tip_bank_kart := {{"МИР",1},;
                        {"VISA",2},;
                        {"MasterCard",3}}
Local j, fl := .f., tmp_color, buf, buf24, a[3], r := 16
//
if mek_tkassa == 2  .and. p_summa >= 0 //касса по 54-ФЗ
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
elseif mek_tkassa == 2  .and. p_summa < 0 //касса по 54-ФЗ
  Private vnos_summa := 0, bank_summa := 0,;
          maddress := padr(address,30)
  tmp_color := setcolor(cHelpCMain)
  buf := box_shadow(r,5,r+3,74)
  buf24 := save_row(maxrow())
  @ r+1,7 say "Телефон или Электронная почта      " get maddress pict "@S30" ;
          valid { | g | ControlAddress( g, maddress ) }
  @ r+2,7 say "Введите сумму возврата             " ;
          get vnos_summa picture spict //;
          //valid iif(empty(vnos_summa), .t., p_summa <= vnos_summa)
  status_key("^<Esc>^ - выход без записи чека;  ^<Enter>^ - запись чека")
  myread()
  rest_box(buf)
  rest_box(buf24)
  setcolor(tmp_color)
  if lastkey() != K_ESC
    if vnos_summa > 0
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
    endif
    address  := maddress
    fl := .t.
  endif
elseif meK_bank == 1 .and. valtype(vbank) == "N"
  tmp_color := setcolor(cDataCGet)
  Private vnos_summa := 0, bank_summa := 0
  do while .t.
    buf := box_shadow(r,5,r+3,74)
    buf24 := save_maxrow()
    @ r+1,7 say "Введите вносимую покупателем сумму (для подсчета сдачи)" ;
            get vnos_summa picture spict valid {|g| val_y_chek(g,1) }
    @ r+2,7 say "Сумма, вносимая безналичными (по банковской карте)     " ;
            get bank_summa picture spict valid {|g| val_y_chek(g,2) } ;
            when round_5(vnos_summa,2) < p_summa
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
    fl := .t.
    exit
  enddo
  setcolor(tmp_color)
elseif meK_sdacha == 1
  tmp_color := setcolor(cHelpCMain)
  buf := box_shadow(r,5,r+2,74)
  buf24 := save_row(maxrow())
  Private vnos_summa := 0
  @ r+1,7 say "Введите вносимую человеком сумму (для подсчета сдачи)" ;
          get vnos_summa picture spict ;
          valid iif(empty(vnos_summa), .t., p_summa <= vnos_summa)
  status_key("^<Esc>^ - выход без записи чека;  ^<Enter>^ - запись чека")
  myread()
  rest_box(buf)
  rest_box(buf24)
  setcolor(tmp_color)
  if lastkey() != K_ESC
    if vnos_summa > 0
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
    endif
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

***** 17.06.15
Function chek_fr(vsum,vsd,/*@*/cur_chek,vbank,sekcia,/*@*/fr_serial_number,address,tip_kart,tip_oplat)
Local fl := .t., name_tov, lport := meK_port, buf := save_maxrow(), ;
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
tt1 := FR_ret_dan(lport)
last_chek := tt1[FR_R_NOMER]
if tt1[FR_R_REGIM] == 4  // смена не открыта
  // открыть смену.
  FRCHN_OpenSession()
endif
//if mek_N_chek == 1 .and. mek_nkassa != 1
  //контроль чека и касса через СОМ
//  last_chek := FR_ret_chek(lport)
//endif
s := ""
if mek_pr_fio == 1
  if type("mplat_fio") == "C" .and. !empty(mplat_fio)
    s := "Больной: "
    if empty(FR_stroka(lport,"Плательщик: "+fam_i_o(mplat_fio)))
      ++cs
    endif
    if type("mplat_inn") == "C" .and. !empty(mplat_inn)
      if empty(FR_stroka(lport,"ИНН плательщика: "+mplat_inn))
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
  FR_progon(lport,1,1)
endif
//
if iif(len(name_tov) > 20, empty(FR_stroka(lport,name_tov)),;
                           empty(FR_b_stroka(lport,,name_tov)))
  ++cs
endif
//
FR_progon(lport,1,1)
//  НАЧАЛО печати услуг
select TMP
go top
do while !eof()
  if fl .and. tmp->kol > 0
    name_tov := alltrim(tmp->name)
    t_nds := 0
    if tmp->nds18 > 0
      t_nds := 1
    elseif tmp->nds10 > 0
      t_nds := 2
    endif
    s_err := FRCH_registr(lport,tmp->cena,tmp->kol,sekcia,name_tov,t_nds,4,tip_oplat)
    if (fl := empty(s_err))
      ++cs //количество продаж
    else
      func_error(4,s_err)
    endif
    if !empty(tmp->vrach)
      FR_stroka(lport,tmp->vrach)   // печать врача
    endif
  endif
  skip
enddo
//  КОНЕЦ печати услуг
if fl .and. len(alltrim(address)) > 3
  // передача данных покупателя
  FRN_CustomerEmail(address)
endif
if fl
  DEFAULT vbank TO 0
  if empty(vbank)
    s := round_5(p_summa,2)
    if meK_w_sdac == 1 .and. round_5(p_summa,2) < round_5(vsum,2)
      s := vsum
    endif
  else
    s := vsum
  endif
  //if mek_tkassa == 2  //касса по 54-ФЗ
    s_err := FRCH_close(lport,s,vbank,,t_nds,tip_kart)
  //else
  //  s_err := FRCH_close(lport,s,vbank,,t_nds,0)
  //endif
  if (fl := empty(s_err))
    ++cs //количество продаж
  else
    func_error(4,s_err)
    inkey(0)
  endif
endif
//
if meK_otrez == 1
  if cs > 0
    if mek_nkassa == 2
        timeout := 55
    endif
    waitperiod(timeout)
    do while waitperiod()
      //
    enddo
  endif
endif
//
if fl
  tt1 := FR_ret_dan(lport)
  if mek_chek == 1
    cur_chek := tt1[FR_R_NOMER]-1 //
  else
    cur_chek := FR_ret_chek(lport)-1
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
  if FRCH_annul(lport) == 1
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
FR_otrezka(lport,1,timeout)
//
if type("delta_chek") == "N"
  cur_chek += delta_chek
endif
return fl

*

***** 17.06.15
Function vozv_fr(value,/*@*/cur_chek)
Local fl := .t., lport := meK_port, buf := save_maxrow(), name_tov, ;
      s_err := "", s, last_chek, fl_err_annul := .f., summa_kassa := 0

cur_chek := 0
// запрашиваем наличие наличности в кассе
if valtype(summa_kassa := (FRCH_d_registr(lport,193))) != "N"
  return func_error(4,summa_kassa)
endif
if value > summa_kassa
  return func_error(4,"Недостаточная сумма в кассе")
endif
mywait()
last_chek := FR_ret_chek(lport)
if !empty(s_err := FRCH_vozvrat(lport,value))
  fl := .f.
  func_error(4,s_err)
else
  FR_stroka(lport," ") // печать в чеке пустой строки перед ФИО больного
  name_tov := lstr(glob_kartotek)+"  "+fam_i_o(glob_k_fio)
  FR_stroka(lport,name_tov)
  if !empty(s_err := FRCH_close(lport,value,0,,0))
    fl := .f.
    func_error(4,s_err)
  endif
  cur_chek := FR_ret_chek(lport)
  if !fl .and. last_chek > 0
    if cur_chek > 0 .and. cur_chek != last_chek
      fl := .t. ; s_err := ""
    endif
  endif
endif
FR_gudok(lport)
if !fl
  if FRCH_annul(lport) == 1
    fl_err_annul := .t.
  endif
endif
rest_box(buf)
if fl_err_annul
  f_err_annul(s_err)
elseif !fl
  write_err_kassa(s_err,"ЧЕК АННУЛИРОВАН")
endif
FR_otrezka(lport,1,150)
if type("delta_chek") == "N"
  cur_chek += delta_chek
endif
return fl



*

***** 17.06.15
Function vozvrat_fr(value,bn_value,/*@*/cur_chek,sekcia,tip_banka)
Local fl := .t.,  buf := save_maxrow(), name_tov, ;
      s_err := "", s, last_chek, fl_err_annul := .f., summa_kassa := 0


// запрашиваем наличие наличности в кассе
if valtype(summa_kassa := (FRCH_d_registr(1,193))) != "N"
  return func_error(4,summa_kassa)
endif
if value > summa_kassa
  return func_error(4,"Недостаточная сумма в кассе")
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
FR_progon(1,1,1)
//  НАЧАЛО печати услуг
select TMP
go top
do while !eof()
  if fl .and. tmp->kol1 > 0
    name_tov := alltrim(tmp->name_u)
    s_err := FRCHN_vozvrat(tmp->u_cena,tmp->kol1,sekcia,name_tov)
       //cena   - цена товара в рублях
       //kol_vo - количество товара
       //sekcia - номер секции
       //name   - наименование товара
    if (fl := empty(s_err))
      //++cs //количество продаж
    else
      func_error(4,s_err)
    endif
  endif
  skip
enddo
//  КОНЕЦ печати услуг
//
if fl
  s_err := FRCH_close(1,value,bn_value,,0,tip_banka)
//  s_err := FRCH_close(lport,s,vbank,,t_nds,tip_kart)
  if (fl := empty(s_err))
    //количество продаж
  else
    func_error(4,s_err)
    inkey(0)
  endif
endif
FR_gudok(1)
//
if fl
  tt1 := FR_ret_dan(1)
  if mek_chek == 1
    cur_chek := tt1[FR_R_NOMER]-1 //
  else
    cur_chek := FR_ret_chek(lport)-1
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
  if FRCH_annul(1) == 1
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
FR_otrezka(1,1,10)
if type("delta_chek") == "N"
  cur_chek += delta_chek
endif
//
return fl

*

***** вызывается в "Платные услуги/Информация/Работа с кассой"
Function inf_fr(k)
Static si1 := 1, si2 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Информация по ~кассе",;
                "Больные без ~ЧЕКОВ",;
                "Реестр",;
                "Возвраты"}
    mas_msg := {"Получение информации по состоянию кассового аппарата",;
                "Поиск больных, у которых введены услуги, но не пробит ЧЕК",;
                "Реестр кассира",;
                "Информация по возвратам"}
    mas_fun := {"inf_fr(11)",;
                "inf_fr(12)",;
                "inf_fr(13)",;
                "inf_fr(14)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    f1_inf_fr(1)
  case k == 12
    f2_inf_fr()
  case k == 13
    pl_priemshk()
  case k == 14
    pl_vozvrat()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

*

***** 20.07.17 запрос к кассовому аппарату
Function f1_inf_fr(tip)
Local arr := {}, s, lport := meK_port, sd, buf := save_row(maxrow()),;
      c4date := dtoc4(sys_date), n_file := "_kassa.txt",;
      fr_serial_number := "", kol := 0, sum := 0,;
      lkexchangeStatus, lkmessageStatus := 0, lkmessageCount := 0,;
      lkdocumentNumber := 0, lkdateDoc, lktimeDoc

DEFAULT tip TO 1

Private drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  //
else
  return func_error(4,"Ошибка запуска драйвера КАССЫ")
endif
//
mywait()

aadd(arr, center(date_month(sys_date,.t.),60))
if glob_kassa == 1 .and. mek_kassa == 1
 //tt1 := FR_ret_dan(lport)
 //fr_serial_number := tt1[FR_R_ZAVNOMER]
 aadd(arr, " ")
 aadd(arr,"ПО СВЕДЕНИЮ ФИСКАЛЬНОГО РЕГИСТРАТОРА:")
 aadd(arr," -Накопление наличности в кассе          "+str(FRCH_d_registr(lport,241),15,2)) //наличность за смену
 aadd(arr," -Продажа наличными за смену             "+str(FRCH_d_registr(lport,193),15,2)) //наличность за смену
 aadd(arr," -Возврат продаж наличными за смену      "+str(FRCH_d_registr(lport,195),15,2)) //наличность за смену
 aadd(arr," -Продажа карта МИР  за смену            "+str(FRCH_d_registr(lport,197),15,2)) //безнал за смену
 aadd(arr," -Продажа карта VISA за смену            "+str(FRCH_d_registr(lport,201),15,2)) //безнал за смену
 aadd(arr," -Продажа карта MasterCard за смену      "+str(FRCH_d_registr(lport,205),15,2)) //безнал за смену
 aadd(arr, " ")
 aadd(arr,"СТАТУС ИНФОРМАЦИОННОГО ОБМЕНА")
 if empty(FRN_GetInfoExchangeStatusShtih( @lkexchangeStatus ,;
                                  @lkmessageStatus,;
                                  @lkmessageCount,;
                                  @lkdocumentNumber,;
                                  @lkdateDoc,;
                                  @lktimeDoc ))
   aadd(arr," -Сообщений для пердачи в ОФД                 "+str(lkmessageCount))
   aadd(arr," -Номер документа для ОФД первого в очереди   "+str(lkdocumentNumber))
   aadd(arr," -Дата документа для ОФД первого в очереди    "+full_date(lkdateDoc))
 else
   aadd(arr," -ДАННЫЕ НЕ СЧИТАНЫ")
 endif
endif
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
  aadd(arr, " -Сумма возвратов:                       "+str(abs(sv),15,2))
  aadd(arr, " -Сумма общего итога оплат за смену:     "+str(s,15,2))
else
  aadd(arr, " -Количество чеков за смену:             "+str(kol,15))
  aadd(arr, " -Сумма общего итога оплат за смену:     "+str(sum,15,2))
endif
aadd(arr,   " -Сумма наличных денег в ящике ККМ:      "+str(sd,15,2))
if meK_ostato > 0
  aadd(arr, "")
  aadd(arr, " -Сумма денег, внесенная в кассу УТРОМ:    "+str(meK_ostato,15,2))
  aadd(arr, " -Итого сумма наличных денег в ящике ККМ:   "+str(sd+meK_ostato,15,2))
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

*****
Function f2_inf_fr()
Local j := 0, s, buf := save_row(maxrow()), n_file := "_kassa1.txt", sh := 65,;
      HH := 60
Local arr_title := {;
  "─"}

mywait()
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0

add_string(padc("Список больных без чеков",sh))
add_string(padc("по состоянию на "+date_month(sys_date,.t.),sh))
add_string("")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_p",,"HUMAN")
index on dtos(k_data) to (cur_dir+"tmp") for is_kas == 2 progress
go top
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  kart->(dbGoto(human->kod_k))
  add_string(str(++j,4)+". "+kart->fio+" "+dtoc(human->k_data))
  select HUMAN
  skip
enddo
  fclose(fp)
close databases
rest_box(buf)
if j == 0
  func_error(4,"Не обнаружено больных без чеков")
else
  viewtext(n_file,,,,(sh>80),,,2)
endif
return NIL

*

***** 15.12.14
Function pl_priemshk()
Local fl := .t., buf := save_row(maxrow()), sm2 := 0, HH := 52,;
      n_file := "platn.txt", arr_m, sh, krvz, arr_dms,;
      mas_op1 := {}, mas_op2 := {}, mas_op3 := {}, i, arr[2], sm_bn := 0

Local arr_title := {;
  "───┬──────────────────────────────────────┬──────┬─────┬──────┬──────────┬────────────────────",;
  " N │           Ф.И.О. пациента            │Время │ Чек │Код П │  Сумма   │        Врач        ",;
  "───┴──────────────────────────────────────┴──────┴─────┴──────┴──────────┴────────────────────"}

sh := len(arr_title[1])
if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp"+sdbf)
  return NIL
endif
//
mywait()
dbcreate(cur_dir+"tmp", {{"kod",     "N",  4,  0},;
                 {"fio",     "C", 60,  0},;
                 {"chek",    "N", 10,  0},;
                 {"kod_hum", "N", 10,  0},;
                 {"operat",  "N", 10,  0},;
                 {"operatf", "C", 40,  0},;
                 {"operatd", "C", 40,  0},;
                 {"FR_DATA", "D",  8,  0},;
                 {"fr_time", "N",  5,  0},;
                 {"t_flag",  "N",  1,  0},;
                 {"summa",   "N", 12,  2},;
                 {"kod_vr",  "N",  4,  0},;
                 {"fio_vr",  "C", 60,  0},;
                 {"summa_bn","N", 12,  2}})
use (cur_dir+"tmp") new
if yes_parol
  R_Use(dir_server+"base1",,"BASE1")
endif
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"mo_pers",,"PERS")
R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HUM_U")
R_Use(dir_server+"hum_p",,"HUM")
go top
do while !eof()
  if !empty(hum->fr_data) .and. between(hum->fr_data,arr_m[7],arr_m[8]) ;
                          .and. ascan(krvz,hum->tip_usl) > 0
    if hum->kod_oper == asc(kod_polzovat) .or. tip_polzovat == 0
      select KART
      goto (hum->kod_k)
      select TMP
      append blank
      tmp->fio      := kart->fio
      tmp->chek     := hum->kv_cia
      tmp->kod_hum  := hum->kod_k
      tmp->fr_data  := c4tod(hum->fr_data)
      tmp->fr_time  := hum->fr_time
      tmp->summa    := hum->cena
      tmp->summa_bn := hum->sbank
      tmp->operat   := hum->kod_oper
      if c4tod(hum->fr_data) != hum->n_data .or.;
         c4tod(hum->fr_data) != hum->k_data
        tmp->t_flag := 1
      else
        tmp->t_flag := 0
      endif
      if yes_parol .and. hum->KOD_OPER > 0
        select BASE1
        goto (hum->KOD_OPER)
        if !eof() .and. !empty(base1->p1)
          tmp->operatf := alltrim(crypt(base1->p1,gpasskod))
          tmp->operatd := alltrim(crypt(base1->p5,gpasskod))
        endif
      endif
      select HUM_U
      find (str(hum->(recno()),7))
      if found()
        select PERS
        goto (hum_u->kod_vr)
        tmp->fio_vr  := pers->fio
      endif
    endif
  endif
  select HUM
  skip
enddo
close databases
use (cur_dir+"tmp") new
index on operat to (cur_dir+"tmp_u") unique
go top
do while !eof()
  aadd(mas_op1,tmp->operat)
  aadd(mas_op2,tmp->operatf)
  aadd(mas_op3,tmp->operatd)
  skip
enddo
close databases
rest_box(buf)
// запрос по операторам
if len(mas_op1) == 0
  bkol_oper := 0
  func_error(4,"Нет информации "+arr_m[4])
elseif len(mas_op1) == 1
  bkol_oper := 1
else
  bkol_oper := popup_prompt(T_ROW,T_COL+5,1,mas_op2)
endif
if bkol_oper > 0
  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string(center("Р Е Е С Т Р",sh))
  add_string(center("регистрации чеков на оплату оказанных медицинских платных услуг населению",sh))
  R_Use(dir_server+"organiz",,"ORG")
  for i := 1 to perenos(arr,alltrim(org->name),sh)
    add_string(center(alltrim(arr[i]),sh))
  next
  add_string(center(arr_m[4],sh))
  tit_tip_usl(krvz,arr_dms,sh)
  add_string("")
  aeval(arr_title, {|x| add_string(x) })
  sm2 := ii := 0
  use (cur_dir+"tmp") new
  index on fr_time to (cur_dir+"tmp_u") for operat == mas_op1[bkol_oper]
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(str(++ii,3)+" "+;
               padr(tmp->fio,38)+;
               iif(tmp->summa_bn > 1,"БН","  ")+;
               padr(sectotime(tmp->fr_time),5)+" "+;
               padl(lstr(tmp->chek),5)+" "+;
               padl(lstr(tmp->kod_hum),6)+" "+;
               iif(tmp->summa_bn > 1,put_kope(tmp->summa_bn,10),put_kope(tmp->summa,10))+" "+;
               padr(fam_i_o(tmp->fio_vr),20)+;
               iif(tmp->t_flag==1,"*"," "))
    if tmp->summa > tmp->summa_bn .and. tmp->summa_bn > 0
      add_string(str(++ii,3)+" "+;
                 padr(tmp->fio,38)+"  "+;
                 padr(sectotime(tmp->fr_time),5)+" "+;
                 padl(lstr(tmp->chek),5)+" "+;
                 padl(lstr(tmp->kod_hum),6)+" "+;
                 put_kope(tmp->summa-tmp->summa_bn,10)+" "+;
                 padr(fam_i_o(tmp->fio_vr),20)+;
                 iif(tmp->t_flag==1,"*"," "))
    endif
    sm2 += tmp->summa
    sm_bn += tmp->summa_bn
    skip
  enddo
  add_string(replicate("─",sh))
  add_string(padR("Итого: ",61)+put_kope(sm2,12))
  add_string(replicate("─",sh))
  for i := 1 to perenos(arr,"Всего на сумму: "+srub_kop(sm2,.t.),sh)
    add_string(arr[i])
  next
  if meK_bank == 1
    for i := 1 to perenos(arr,"из них в кассу: "+srub_kop(sm2-sm_bn,.t.),sh)
      add_string(arr[i])
    next
  endif
  add_string("")
  add_string("            Сдал "+padr(alltrim(mas_op3[bkol_oper])+":",21)+"                    /"+alltrim(mas_op2[bkol_oper])+"/")
  add_string("")
  add_string("            Принял кассир:                                /"+alltrim(mek_kassir)+"/")
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,3)
endif
return NIL

*

*****
Function pl_vozvrat()
Local fl := .t., buf := save_row(maxrow()), sm := 0, HH := 52,;
      n_file := "platn.txt", arr_m, sh, sm_sn := 0, krvz, arr_dms,;
      sm_usl := 0
Local arr_title := {;
  "───────────────────────────────────────────────────┬────────┬───────────",;
  "                  Услуги                           │ Кол-во │   Сумма   ",;
  "───────────────────────────────────────────────────┴────────┴───────────";
  }
sh := len(arr_title[1])
if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
//
mywait()
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string(center("ВОЗВРАТ оплаты услуг",sh))
add_string(center("(по дате начала лечения)",sh))
add_string(center(arr_m[4],sh))
tit_tip_usl(krvz,arr_dms,sh)
add_string("")
aeval(arr_title, {|x| add_string(x) })
//
R_Use(dir_server+"mo_pers",,"P2")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_p_U",dir_server+"hum_p_U","HUM_U")
R_Use(dir_server+"hum_p",,"HUM")
go top
do while !eof()
  if between(hum->n_data,arr_m[5],arr_m[6]) .and.;
                     ascan(krvz,hum->tip_usl) > 0 .and. hum->SUM_VOZ > 0
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    select KART
    goto (hum->kod_k)
    add_string(padr("--"+alltrim(kart->fio)+"  ВОЗВРАТ",59)+put_kope(hum->SUM_VOZ,12))
    sm_sn += hum->SUM_VOZ
    t := hum->(RECNO())
    select HUM_U
    find (str(t,7))
    sum_sl := 0
    do while t == hum_u->kod .and. !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      select USL
      goto (hum_u->u_kod )
      add_string(usl->shifr+padr(usl->name,40)+;
                 str(hum_u->kol,9)+;
                 put_kope(hum_u->stoim,12))
      select P2
      goto (hum_u->kod_vr)
      add_string(padr(p2->fio,50))
      sum_sl += hum_u->stoim
      sm_usl += hum_u->stoim
      select HUM_U
      skip
    enddo
    add_string(padr("     Итого оплата",59)+put_kope(sum_sl,12))
    add_string("")
  endif
  select HUM
  skip
enddo
add_string(replicate("─",sh))
add_string(padR("ИТОГО возврат: "    ,59)+put_kope(sm_sn ,12))
add_string(padR("ИТОГО сумма услуг: ",59)+put_kope(sm_usl,12))
close databases
fclose(fp)
viewtext(n_file,,,,(sh>80),,,1)
rest_box(buf)
return NIL

*

***** 18.11.14 вызывается в "Ортопедия/Информация/Работа с кассой"
Function inf_fr_orto(k)
Static si1 := 1, si2 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Информация по ~кассе",;
                "Реестр",;
                "Возвраты"}
    mas_msg := {"Получение информации по состоянию кассового аппарата",;
                "Реестр регистрации чеков на оплату",;
                "Информация по возвратам"}
    mas_fun := {"inf_fr_orto(11)",;
                "inf_fr_orto(12)",;
                "inf_fr_orto(13)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    f1_inf_fr(2)
  case k == 12
    ort_priemshk()
  case k == 13
    or_vozvrat()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL


*

***** 15.12.14
Function ort_priemshk()
Local fl := .t., buf := save_row(maxrow()), sm2 := 0, HH := 52,;
      n_file := "platn.txt", arr_m, sh, krvz, arr_dms,;
      sm_1 := 0, sm_2 := 0, sm_3 := 0, sm_bn := 0,;
      mas_op1 := {}, mas_op2 := {}, i, arr[2]
Local  arr_title := {;
  "───┬──────────────────────────────────────┬──────┬─────┬──────┬──────────┬───┬─────┬──────────────",;
  " N │           Ф.И.О. пациента            │Время │ Чек │Код П │  Сумма   │Тип│Наряд│      Врач    ",;
  "───┴──────────────────────────────────────┴──────┴─────┴──────┴──────────┴───┴─────┴──────────────"}
Local menu_opl := {{"ава",0},;
                   {"опл",1},;
                   {"нап",2}}
sh := len(arr_title[1])
//if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
//  return NIL
//endif
if (arr_m := year_month()) == NIL
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp"+sdbf)
  return NIL
endif
//
mywait()
dbcreate(cur_dir+"tmp", {{"kod",     "N",  4,  0},;
                 {"fio",     "C", 60,  0},;
                 {"chek",    "N", 10,  0},;
                 {"kod_hum", "N", 10,  0},;
                 {"operat",  "N", 10,  0},;
                 {"operatf", "C", 40,  0},;
                 {"FR_DATA", "D",  8,  0},;
                 {"fr_time", "N",  5,  0},;
                 {"t_flag",  "N",  1,  0},;
                 {"kod_vr",  "N",  4,  0},;
                 {"fio_vr",  "C", 60,  0},;
                 {"tip_op",  "N",  1,  0},;
                 {"nar_z",   "N",  5,  0},;
                 {"summa_bn","N", 12,  2},;
                 {"summaN",  "N", 12,  2},;
                 {"summa",   "N", 12,  2}})
use (cur_dir+"tmp") new
if yes_parol
  R_Use(dir_server+"base1",,"BASE1")
endif
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_ort",,"HUMAN")
R_Use(dir_server+"mo_pers",,"PERS")
use_base("hum_oro")
go top
do while !eof()
  if !empty(ho->fr_data) .and. between(ho->fr_data,arr_m[7],arr_m[8])
    select HUMAN
    goto (ho->kod)
    select KART
    goto (human->kod_k)
    select TMP
    if ho->kod_reg == asc(kod_polzovat) .or. tip_polzovat == 0
      append blank
      tmp->fio      := kart->fio
      tmp->chek     := ho->kv_cia
      tmp->kod_hum  := human->kod_k
      tmp->fr_data  := c4tod(ho->fr_data)
      tmp->fr_time  := ho->fr_time
      tmp->summa    := ho->cena_opl
      tmp->kod_vr   := human->kod_vr
      tmp->tip_op   := ho->tip_opl
      tmp->nar_z    := human->nar_z
      tmp->summa_bn := ho->sbank
      select PERS
      goto (human->kod_vr)
      tmp->fio_vr  := pers->fio
      tmp->operat  := ho->kod_reg
      tmp->t_flag := 0
      if yes_parol .and. ho->kod_reg > 0
        select BASE1
        goto (ho->kod_reg)
        if !eof() .and. !empty(base1->p1)
          tmp->operatf := alltrim(crypt(base1->p1,gpasskod))
        endif
      endif
    endif
  endif
  select HO
  skip
enddo
close databases
use (cur_dir+"tmp") new
index on operat to (cur_dir+"tmp_u") unique
go top
do while !eof()
  aadd(mas_op1,tmp->operat)
  aadd(mas_op2,tmp->operatf)
  skip
enddo
close databases
rest_box(buf)
// запрос по операторам
if len(mas_op1) == 0
  bkol_oper := 0
  func_error(4,"Нет информации "+arr_m[4])
elseif len(mas_op1) == 1
  bkol_oper := 1
else
  bkol_oper := popup_prompt(T_ROW,T_COL+5,1,mas_op2)
endif
if bkol_oper > 0
  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string(center("Р Е Е С Т Р",sh))
  add_string(center("регистрации чеков на оплату оказанных медицинских платных услуг населению",sh))
  R_Use(dir_server+"organiz",,"ORG")
  for i := 1 to perenos(arr,alltrim(org->name),sh)
    add_string(center(alltrim(arr[i]),sh))
  next
  add_string(center(arr_m[4],sh))
//  tit_tip_usl(krvz,arr_dms,sh)
  add_string("")
  aeval(arr_title, {|x| add_string(x) })
  sm2 := ii := 0
  use (cur_dir+"tmp") new
  index on fr_time to (cur_dir+"tmp_u") for operat == mas_op1[bkol_oper]
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    tt1 := inieditspr(A__MENUVERT, menu_opl, tmp->tip_op)
    add_string(str(++ii,3)+" "+;
               padr(tmp->fio,38)+;
               iif(tmp->summa_bn > 1,"БН","  ")+;
               padr(sectotime(tmp->fr_time),5)+" "+;
               padl(lstr(tmp->chek),5)+" "+;
               padl(lstr(tmp->kod_hum),6)+" "+;
               iif(tmp->summa_bn > 1,put_kope(tmp->summa_bn,10),put_kope(tmp->summa,10))+" "+;
               padr(alltrim(tt1),3)+" "+;
               padl(lstr(tmp->nar_z),5)+" "+;
               fam_i_o(tmp->fio_vr)+;
               iif(tmp->t_flag==1,"*"," "))
    if tmp->summa > tmp->summa_bn .and. tmp->summa_bn > 0
      add_string(str(++ii,3)+" "+;
                 padr(tmp->fio,38)+"  "+;
                 padr(sectotime(tmp->fr_time),5)+" "+;
                 padl(lstr(tmp->chek),5)+" "+;
                 padl(lstr(tmp->kod_hum),6)+" "+;
                 put_kope(tmp->summa-tmp->summa_bn,10)+" "+;
                 padr(alltrim(tt1),3)+" "+;
                 padl(lstr(tmp->nar_z),5)+" "+;
                 fam_i_o(tmp->fio_vr)+;
                 iif(tmp->t_flag==1,"*"," "))
    endif
    if tmp->tip_op == 0
      sm_1 += tmp->summa
    elseif tmp->tip_op == 1
      sm_2 += tmp->summa
    else
      sm_3 += tmp->summa
    endif
    sm2 += tmp->summa
    sm_bn += tmp->summa_bn
    select TMP
    skip
  enddo
  add_string(replicate("─",sh))
  add_string(padR("Итого: ",61)+put_kope(sm2,12))
  add_string(replicate("─",sh))
  for i := 1 to perenos(arr,"Всего на сумму: "+srub_kop(sm2,.t.),sh)
    add_string(arr[i])
  next
  if meK_bank == 1
    for i := 1 to perenos(arr,"из них в кассу: "+srub_kop(sm2-sm_bn,.t.),sh)
      add_string(arr[i])
    next
  endif
  //add_string(padR("Аванс:    ",61)+put_kope(sm_1,12))
  //add_string(padR("Оплата:   ",61)+put_kope(sm_2,12))
  //add_string(padR("Напылене: ",61)+put_kope(sm_3,12))
  add_string("")
  add_string("            Сдал мед.регистратор:              /"+alltrim(mas_op2[bkol_oper])+"/")
  add_string("")
  add_string("            Принял кассир:                                /"+alltrim(mek_kassir)+"/")
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,3)
endif
return NIL

*

***** 18.11.14
Function or_vozvrat()
Local fl := .t., buf := save_row(maxrow()), sm := 0, HH := 52,;
      n_file := "platn.txt", arr_m, sh, sm_sn := 0, krvz, arr_dms,;
      sm_usl := 0
Local arr_title := {;
  "────────────────────────────────────────────────────────────┬───────────",;
  "                           Пациент                          │   Сумма   ",;
  "────────────────────────────────────────────────────────────┴───────────";
  }
sh := len(arr_title[1])
//if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
//  return NIL
//endif
if (arr_m := year_month()) == NIL
  return NIL
endif
//
mywait()
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string(center("ВОЗВРАТ оплаты нарядов",sh))
add_string(center("(по дате возврата)",sh))
add_string(center(arr_m[4],sh))
//tit_tip_usl(krvz,arr_dms,sh)
add_string("")
aeval(arr_title, {|x| add_string(x) })
//
R_Use(dir_server+"mo_pers",,"P2")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_ort",,"HUM_T")
R_Use(dir_server+"hum_oro",,"HUM_O")
go top
do while !eof()
  if between(hum_o->date_voz,arr_m[7],arr_m[8]) .and.;
                                 hum_o->SUM_VOZ > 0
                    // ascan(krvz,hum_o->tip_usl) > 0 .and.
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    select HUM_T
    goto (hum_o->kod)
    select KART
    goto (hum_t->kod_k)
    add_string(padr("--"+alltrim(kart->fio)+"  ВОЗВРАТ",59)+put_kope(hum_o->SUM_VOZ,12))
    sm_sn += hum_o->SUM_VOZ
    select P2
    goto (hum_t->kod_vr)
    add_string(padr("Врач "+p2->fio,50))
    add_string("")
  endif
  select HUM_O
  skip
enddo
add_string(replicate("─",sh))
add_string(padr("ИТОГО возврат: "    ,59)+put_kope(sm_sn ,12))
close databases
fclose(fp)
viewtext(n_file,,,,(sh>80),,,1)
rest_box(buf)
return NIL

*

***** гудок на кассовом аппарате
function FR_gudok(n_port)
return FRN_gudok()

*

***** ДРАЙВЕР гудок на кассовом аппарате
function FRN_gudok()

local drvFR
IF ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
  drvFR:Password := oper_parol
  drvFR:Beep()
endif
return NIL

*

***** вывод строки на чековую ленту
function FR_stroka(n_port,stroka,flag)
/* 17H - 23
   n_port - номер порта
   flag - 1 печать на контрольной ленте
          2 печать на чековой ленте
   stroka - строка выводимая на чековую ленту
*/
local s, t1 := space(40), t2
DEFAULT flag to 2
s := atrepl(",",alltrim(stroka),";")   // заменить ";" на "," строки
s := charone(" ",s)                    // удалить совмещенные пробелы
return FRN_stroka(s,flag)

*

***** ДРАЙВЕР вывод строки на чековую ленту
function FRN_stroka(stroka,flag)
/* flag - 1 печать на контрольной ленте
          2 печать на чековой ленте
   stroka - строка выводимая на чековую ленту
*/
local t

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


***** вывод строки на чековую ленту
function FR_b_stroka(n_port,flag,stroka)
/* n_port - номер порта
   flag - 1 печать на контрольной ленте
          2 печать на чековой ленте
   stroka - строка выводимая на чековую ленту реально 18 по инстр 20
*/
local s, t1 := space(20), t2
DEFAULT flag to 2
s := atrepl(",",alltrim(stroka),";")   // заменить ";" на "," строки
s := charone(" ",s)                    // удалить совмещенные пробелы
return FRN_b_stroka(s,flag)


*

***** ДРАЙВЕР вывод строки на чековую ленту
function FRN_b_stroka(stroka,flag)
/* flag - 1 печать на контрольной ленте
          2 печать на чековой ленте
   stroka - строка выводимая на чековую ленту
*/
local t

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

***** отрезка чековой ленты
function FR_otrezka(n_port,flag,timeout)
/* n_port - номер порта
   flag - 0 полная отрезка
          1 частичный отрез
*/

return FRN_otrezka(flag)


*

***** ДРАЙВЕР отрезка чековой ленты
function FRN_otrezka(flag)
/* flag - 0 полная отрезка
          1 частичный отрез
*/
drvFR:Password := oper_parol
if flag == 0
  drvFR:CutType := 0
else
  drvFR:CutType := 1
endif
drvFR:CutCheck()
return NIL


*

***** Протяжка
function FR_progon(n_port,flag,kol_str)
/*  n_prot - номер порта
    flag - 0 контрольная лента
           1 чековая лента
           2 обе ленты
    kol_str количество прогоняемых строк
*/
return FRN_progon(flag,kol_str)


*

***** ДРАЙВЕР отрезка чековой ленты
function FRN_progon(flag,kol_str)
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

***** Продажа товара
function FRCH_registr(n_port,cena,kol_vo,sekcia,name,t_nds,tip_tovar,tip_rachet)
/*  n_prot - номер порта
    cena   - цена товара в рублях
    kol_vo - количество товара
    sekcia - номер секции
    name   - наименование товара
*/
return FRCHF_registr(cena,kol_vo,sekcia,name,t_nds,1,tip_tovar,tip_rachet)
//return FRCHN_registr(cena,kol_vo,sekcia,name,t_nds)


*

***** 03.09.17 Продажа товара
function FRCHN_registr(cena,kol_vo,sekcia,name,t_nds)
/*  cena   - цена товара в рублях
    kol_vo - количество товара
    sekcia - номер секции
    name   - наименование товара
*/
local t, t1 := space(3), t2, t3 := 0
name := alltrim(name) //48
drvFR:Password := oper_parol
drvFR:Quantity := kol_vo
drvFR:Price    := cena
drvFR:Department := sekcia
drvFR:StringForPrinting := upper(name)
drvFR:Tax1 := t_nds
// HB_CDPSELECT("RU1251")
IF drvFR:Sale() < 0
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

***** 20.09.17 Продажа товара
function FRCHF_registr(cena,kol_vo,sekcia,name,t_nds,Tip_operation,tip_tovar,tip_rachet)
/*  cena   - цена товара в рублях
    kol_vo - количество товара
    sekcia - номер секции
    name   - наименование товара
*/
local t, t1 := space(3), t2, t3 := 0

DEFAULT tip_tovar to 4, tip_rachet to 4


if len(name) > 127
  name := substr(name,1,128)
endif
//name := alltrim(padr(name,128)) //48
drvFR:Password := oper_parol
drvFR:CheckType := Tip_operation // 1 - продажа
drvFR:Quantity := kol_vo
drvFR:Price    := cena
drvFR:Department := sekcia
drvFR:Summ1Enabled := .F.
drvFR:StringForPrinting := upper(name)
drvFR:Tax1 := t_nds
drvFR:PaymentTypeSign := 4 //tip_tovar
drvFR:PaymentItemSign  := 4 //tip_rachet

// HB_CDPSELECT("RU1251")
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

***** Закрытие чека
function FRCH_close(n_port,summa,summa1,name,t_nds,tip_kart)
/*  n_port - номер порта
    summa  - сумма наличных
    summa1 - по кредитной карте
    name   - текст
*/
DEFAULT name TO " "
return FRCHN_close(summa,summa1,name,t_nds,tip_kart)

*

***** Закрытие чека
function FRCHN_close(summa,summa1,name,t_nds,tip_kart)
/*  summa  - сумма наличных
    summa1 - по кредитной карте
    name   - текст
    t_nds
*/
local  t, t1 := space(3), t2, t3 := 0

drvFR:Password := oper_parol
//
drvFR:Summ1 := 0
drvFR:Summ2 := 0
drvFR:Summ3 := 0
drvFR:Summ4 := 0
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
endif
//@ 0,10 say summa1
//@ 1,10 say summa
drvFR:StringForPrinting := upper(name)
drvFR:Tax1 := t_nds
IF drvFR:CloseCheck() < 0
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
function FR_set_time(n_port,time)
/*  n_prot - номер порта
    time   - время в формате ЧЧ:ММ:СС
*/
return FRN_set_time(time)


*

***** Установка времени
function FRN_set_time(time)
//  time   - время в формате ЧЧ:ММ:СС
local t

drvFR:Password := oper_frparol
drvFR:Time := time
IF drvFR:SetTime() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
endif
return NIL

*

***** Программирование даты (подтверждение программирования даты)
Function FR_set_date(n_port,ldate)
/*  n_prot - номер порта
    ldate  - дата в формате даты
*/
return FRN_set_date(ldate)

*

***** Программирование даты (подтверждение программирования даты)
Function FRN_set_date(ldate)
//  ldate  - дата в формате даты
local  t

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
Function FR_normgach(n_port,flag)
/*
    n_prot - номер порта
    flag == 0 - без гашения 40H - 64
            1   c гашением   41H - 65
*/
return FRN_normgach(flag)


*

***** Снятие суточного отчета
Function FRN_normgach(flag)
Local t

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
  IF drvFR:PrintReportWithCleaning() < 0
     t := drvFR:ResultCodeDescription
     return alltrim(t)
  else
     //t := drvFR:ResultCodeDescription
     return NIL
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

local t := space(3)

IF drvFR:PrintTaxReport() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
endif
return NIL

*

***** Снятие суточного отчета по СЕКЦИЯМ
Function FRN_PrintDepartmentReport()

local t := space(3)

IF drvFR:PrintDepartmentReport() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
endif
return NIL

*

***** Возврат продажи (для аннулирования чека)
function FRCH_vozvrat(n_port,cena,kol_vo,sekcia,name)
/*  n_prot - номер порта
    cena   - цена товара в рублях
    kol_vo - количество товара
    sekcia - номер секции
    name   - наименование товара
*/
DEFAULT kol_vo TO 1, sekcia TO 1, name TO ""
name := padr(name,1,90)
return FRCHN_vozvrat(cena,kol_vo,sekcia,name)


*

***** Возврат продажи (для аннулирования чека)
function FRCHN_vozvrat(cena,kol_vo,sekcia,name)
/*  cena   - цена товара в рублях
    kol_vo - количество товара
    sekcia - номер секции
    name   - наименование товара
*/
local t, t1 := space(3), t2, t3 := 0

drvFR:Password := oper_parol
drvFR:Quantity := kol_vo
drvFR:Price    := cena
drvFR:Department := sekcia
drvFR:StringForPrinting := alltrim(upper(padr(name,90)))
HB_CDPSELECT("RU1251")
IF drvFR:ReturnSale() < 0
   t := drvFR:ResultCodeDescription
   HB_CDPSELECT("RU866")
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

***** Аннулирование всего чека до его закрытия
function FRCH_annul(n_port)
/*  88H - 136
    n_prot - номер порта
    1 - аннулирование неудачно
    0 - аннулирование удачно завершено
*/
return iif(empty(FRCHN_annul()),0,1)

*

***** Аннулирование всего чека до его закрытия
function FRCHN_annul()
/*  1 - аннулирование неудачно
    0 - аннулирование удачно завершено
*/
local t1 := space(32), t2, i, t, ret := 1

drvFR:Password := oper_parol
IF drvFR:CancelCheck() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
endif
return NIL

*

***** продолжение печати
function FR_prodol(n_port)
// n_port - номер порта
return FRN_prodol()

*

***** продолжение печати
function FRN_prodol()
local  t, t2 := space(4)

drvFR:Password := oper_parol
IF drvFR:ContinuePrint() < 0
   t := drvFR:ResultCodeDescription
   return alltrim(t)
endif
return NIL

*

***** Возвращает текущий номер чека
Function FR_ret_chek(n_port)
return FRN_ret_chek()


*

***** Возвращает текущий номер чека
Function FRN_ret_chek()
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

***** Запрос денежного регистра
function FRCH_d_registr(n_port,registr)
/*  1AH - 26
    n_prot  - номер порта
    registr - номер регистра
*/
return FRCHN_d_registr(registr)

*

***** Запрос денежного регистра
function FRCHN_d_registr(registr)
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
Function FR_ret_dan(n_port)
// 11H - 17
Local t, t2, vozvrat := space(60), mas_vozvr := {}, i, vr1, vr2, vr3,;
      buf := save_maxrow()
mywait()
return FRN_ret_dan()

*

***** Возвращает в виде массива состояние ФР
Function FRN_ret_dan()
Local mas_vozvr := {}, t, t1, t2, i, lport := meK_port
drvFR:Password := oper_parol
for i := 1 to FR_R_LEN
  t := ""
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
   //
  else
    t := drvFR:UDescription
  ENDIF
endif
return NIL

*

***** Открытие смены
function FRCHN_OpenSession()
Local t, tt1

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
if meK_open_p == 1
  return func_error(4,"Ошибка включения порта COM"+lstr(lport))
endif

return vozvrat

